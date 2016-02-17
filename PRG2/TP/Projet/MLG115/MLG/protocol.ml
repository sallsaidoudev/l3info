(* This file is part of MLGame (OCaml Game System).

   MLGame is free software; you can redistribute it and/or modify it under the
   terms of the GNU General Public License as published by the Free Software
   Foundation; either version 2 of the License, or (at your option) any later
   version.

   MLGame is distributed in the hope that it will be useful, but WITHOUT ANY
   WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
   FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
   details.

   You should have received a copy of the GNU General Public License along
   with MLGame; if not, write to the Free Software Foundation, Inc., 59 Temple
   Place, Suite 330, Boston, MA 02111-1307 USA *)

exception Error of string;;

type t = I of int | C of char | F of float | S of string | List of t list;;

let buf_pos = ref 0;;
let buf_len = ref 4096;;
let buf_str = ref (String.create !buf_len);;

let buf_extend no =
  if !buf_pos + no <= !buf_len then () else
  let new_str = String.create (2 * !buf_len + no) in
  String.blit !buf_str 0 new_str 0 !buf_pos;
  buf_len := 2 * !buf_len + no;
  buf_str := new_str
;;

let buf_write = function
  | (C c) -> 
      buf_extend 1;
      !buf_str.[!buf_pos] <- c;
      buf_pos := !buf_pos + 1
  | (I i) -> 
      buf_extend 4;
      String.unsafe_blit (Obj.magic (ref i)) 0 !buf_str !buf_pos 4;
      buf_pos := !buf_pos + 4
  | (F f) ->
      buf_extend 8;
      String.unsafe_blit (Obj.magic f) 0 !buf_str !buf_pos 8;
      buf_pos := !buf_pos + 8
  | (S s) ->
      let len = String.length s in
      buf_extend (len + 4);
      String.unsafe_blit (Obj.magic (ref len)) 0 !buf_str !buf_pos 4;
      String.unsafe_blit s 0 !buf_str (!buf_pos + 4) len;
      buf_pos := !buf_pos + 4 + len
  | _ -> Log.fatal "Protocol.buf_write"
;;

let buf_check no =
  if !buf_pos + no <= !buf_len then () else
  raise (Error "Received message too short to parse")
;;

let buf_read = function
  | 'C' ->
      buf_check 1;
      let c = !buf_str.[!buf_pos] in
      buf_pos := !buf_pos + 1;
      C c
  | 'I' ->
      buf_check 4;
      let tmp_i = Int32.of_int 0 in
      String.unsafe_blit !buf_str (!buf_pos) (Obj.magic tmp_i) 0 4;
      buf_pos := !buf_pos + 4;
      I (Int32.to_int tmp_i)
  | 'F' ->
      buf_check 8;
      let tmp_f = 0.0 in
      String.unsafe_blit !buf_str !buf_pos (Obj.magic tmp_f) 0 8;
      buf_pos := !buf_pos + 8;
      F tmp_f
  | 'S' ->
      buf_check 4;
      let len = Int32.of_int 0 in
      String.unsafe_blit !buf_str !buf_pos (Obj.magic len) 0 4;
      buf_check (4 + (Int32.to_int len));
      let s = String.create (Int32.to_int len) in
      String.unsafe_blit !buf_str (!buf_pos + 4) s 0 (Int32.to_int len);
      buf_pos := !buf_pos + 4 + (Int32.to_int len);
      S s
  | _ -> Log.fatal "Protocol.buf_read"
;;

let buf_send ?dest sock = Udp.send sock ?dest !buf_str 0 !buf_pos;;

let buf_recv sock len = 
  buf_extend (len - !buf_len);
  buf_pos := 0;
  Udp.recv sock !buf_str 0 len
;;

(* Internal bierze stringa i pozycjê pierwszego nawiasu i zwraca pozycjê
   pasuj±cego do niego i ilo¶æ obiektów w ¶rodku. *)

let rec find_parenthesis str pos =
  try
    let rb = String.index_from str (pos + 1) ']' in
    try
      let lb = String.index_from str (pos + 1) '[' in
      if rb < lb then (rb, rb - pos - 1) else
      let (other_rb, _) = find_parenthesis str lb in
      let (next_rb, next_cnt) = find_parenthesis str other_rb in
      (next_rb, lb + next_cnt - pos)
    with Not_found -> (rb, rb - pos - 1)
  with Not_found -> raise (Error "Matching bracket not found")
;;

(* TODO deepeningi.. *)
let count str =
  String.length str
;;

let buf_write_list params lst = 
  let rec writer pos lst params =
    if pos = String.length params then lst else
    match params.[pos], List.hd lst with
    | 'C', C c -> buf_write (C c); writer (pos + 1) (List.tl lst) params
    | 'I', I i -> buf_write (I i); writer (pos + 1) (List.tl lst) params
    | 'F', F f -> buf_write (F f); writer (pos + 1) (List.tl lst) params
    | 'S', S s -> buf_write (S s); writer (pos + 1) (List.tl lst) params
    | '[', List l -> 
        let list_end, list_cnt = find_parenthesis params pos in
        let sub_params = String.sub params (pos + 1) (list_end - pos - 1) in
        let cnt = (List.length l) / list_cnt in
        buf_write (I cnt);
        let rec sub_writer lst =
          match lst with
          | [] -> ()
          | sth -> sub_writer (writer 0 lst sub_params)
        in sub_writer l;
        writer (list_end + 1)  (List.tl lst) params
    | _ -> raise (Error "buf_write_list type mismatch")
  in
  try
    match writer 0 lst params with
    | [] -> ()
    | _ -> raise (Error "buf_write_list length mismatch")
  with Failure _ -> raise (Error "buf_write_list length mismatch 2")
;;

let buf_read_list read_len params =
  let rec reader acc pos params =
    if pos = String.length params then acc else
    match params.[pos] with
    | ('C' | 'I' | 'F' | 'S' as chr) ->
      reader ((buf_read chr) :: acc) (pos + 1) params
    | '[' -> begin try
        let (list_end, _) = find_parenthesis params pos in
        let sub_params = String.sub params (pos + 1) (list_end - pos - 1) in
        match buf_read 'I' with
        | I i -> 
            let rec sub_reader cnt acc =
              if cnt = 0 then acc else
              sub_reader (cnt - 1) (reader acc 0 sub_params)
            in 
            let new_lst = sub_reader i [] in
            reader ((List (List.rev new_lst)) :: acc) (list_end + 1) params
        | _ -> Log.fatal "Protocol.buf_read_list"
    with Not_found -> raise (Error "List not ended by ']'.")
    end
    | _ -> raise (Error "Incorrect msg type in params")
  in
  let lst = reader [] 0 params in
  if read_len = !buf_pos then List.rev lst 
  else raise (Error "Read != Processed ")
;;

let c2s_mesg = ref 0;;
let c2s_params = Array.create 256 ("", fun _ _ -> ());;

let s2c_mesg = ref 0;;
let s2c_params = Array.create 256 ("", fun _ -> ());;

let c2s_add params recv_fun =
  if !c2s_mesg > 255 then Log.fatal "Too many messages in c2s_protocol" else
  c2s_params.(!c2s_mesg) <- (params, recv_fun);
  let my_mesg = C (Char.chr !c2s_mesg) in
  incr c2s_mesg;
  fun sock lst ->
    buf_pos := 0;
    buf_write my_mesg;
    buf_write_list params lst;
    buf_send sock
;;
    
let client_net_check sock =
  let len, _ = buf_recv sock !buf_len in
  if len = 0 then () else
  match buf_read 'C' with
  | C c -> 
      let (params, fnctn) = s2c_params.(Char.code c) in
      fnctn (buf_read_list len params)
  | _ -> Log.fatal "Protocol.client_net_check"
;;

let s2c_add params recv_fun =
  if !s2c_mesg > 255 then Log.fatal "Too many messages in s2c_protocol" else
  s2c_params.(!s2c_mesg) <- (params, recv_fun);
  let my_mesg = C (Char.chr !s2c_mesg) in
  incr s2c_mesg;
  fun sock dest lst ->
    buf_pos := 0;
    buf_write my_mesg;
    buf_write_list params lst;
    buf_send ~dest sock
;;

let server_net_check sock =
  let len, from = buf_recv sock !buf_len in
  if len = 0 then () else
  match buf_read 'C' with
  | C c -> 
      let (params, fnctn) = c2s_params.(Char.code c) in
      fnctn from (buf_read_list len params)
  | _ -> Log.fatal "Protocol.server_net_check"
;;
