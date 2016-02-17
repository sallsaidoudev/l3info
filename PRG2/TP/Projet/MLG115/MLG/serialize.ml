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

type 'a t = (Buffer.t -> 'a -> unit) * (string -> int -> int -> int * 'a);;

exception Too_short of string;;

let unsafe_add_buffer buf str cnt =
  let anew = String.create cnt in
  String.unsafe_blit str 0 anew 0 cnt;
  Buffer.add_string buf anew
;;

let unsafe_read_buffer src pos cnt =
  let ret = String.create cnt in
  String.unsafe_blit src pos ret 0 cnt;
  ret
;;

let unit =
  let unit_writer _ () = ()
  and unit_reader src pos len = (pos, ())
  in unit_writer, unit_reader
;;

let char =
  let char_writer buf achar =
    Buffer.add_char buf achar
  and char_reader src pos len =
    if pos + 1 > len then raise (Too_short "char_reader");
    (pos + 1, src.[pos])
  in char_writer, char_reader
;;

let int31 = 
  let int_writer buf aint =
    unsafe_add_buffer buf (Obj.magic (Int32.of_int aint)) 4
  and int_reader src pos len =
    if pos + 4 > len then raise (Too_short "int_reader");
    (pos + 4, Int32.to_int (Obj.magic (unsafe_read_buffer src pos 4)))
  in int_writer, int_reader
;;

let pair (a_write, a_read) (b_write, b_read) =
  let pair_writer buf (a, b) =
    a_write buf a;
    b_write buf b
  and pair_reader src pos len =
    let (apos, a) = a_read src pos len in
    let (bpos, b) = b_read src apos len in
    (bpos, (a, b))
  in pair_writer, pair_reader
;;

  
let int = 
  let flag = 0b10000000 in
  let mask = 0b01111111 in
  let small_int_writer buf aint =
    let rec int_writer_aux i = 
      let code = if i < flag then i else i land mask lor flag in
      Buffer.add_char buf (Char.chr code);
      let rest = i lsr 7 in
      if rest > 0 then int_writer_aux rest
    in
    int_writer_aux (if aint < 0 then (-2) * aint  -1 else 2 * aint )
  and small_int_reader src pos len =
    let rec int_reader_aux pos =
      if pos > len - 1 then raise (Too_short "small_int_reader");
      let code = Char.code src.[pos] in
      if code land flag = 0 then (pos+1, code) else
        let (new_pos, rest) = int_reader_aux (pos + 1) in
        (new_pos, rest lsl 7 + (code land mask))
    in
    let (new_pos, aint) = int_reader_aux pos in
    (new_pos, (if aint mod 2 = 0 then aint / 2 else (aint + 1) / (-2)))
  in 
  (small_int_writer, small_int_reader)
;;



let string =
  let (int_writer, int_reader) = int in
  let string_writer buf astr =
    let slen = String.length astr in
    int_writer buf slen;
    Buffer.add_string buf astr
  and string_reader src pos len =
    let (pos, slen) = int_reader src pos len in
    if pos + slen > len then raise (Too_short "string_contents_reader");
    (pos + slen, String.sub src pos slen)
  in string_writer, string_reader
;;



let list (a_write, a_read) =
  let (int_writer, int_reader) = int in
  let list_writer buf a_list =
    let len = List.length a_list in
    int_writer buf len;
    List.iter (a_write buf) a_list
  and list_reader src pos len =
    let (npos, llen) = int_reader src pos len in
    let rec creator acc n pos =
      if n = 0 then (pos, List.rev acc) else
      let (npos, a) = a_read src pos len in
      creator (a :: acc) (n - 1) npos
    in creator [] llen npos
  in list_writer, list_reader
;;

let marshal =
  let string_writer, string_reader = string in
  let any_writer buf any =
    string_writer buf (Marshal.to_string any [])
  and any_reader src pos len =
    let (npos, str) = string_reader src pos len in
    (npos, Marshal.from_string str 0)
  in any_writer, any_reader
;;

(*
external float_of_bytes : string -> float = "float_of_bytes";;
external bytes_of_float : float -> string = "bytes_of_float";;
  and float_reader src pos len =
    if pos + 8 > len then raise (Too_short "float_reader");
    let sub = String.sub src pos 8 in
    (pos + 8, float_of_bytes sub)
*)

let float =
  let string_writer, string_reader = string in
  let float_writer buf afloat =
    string_writer buf (string_of_float afloat)
  and float_reader src pos len =
    let (npos, str) = string_reader src pos len in
    (npos, float_of_string str)
  in float_writer, float_reader
;;


let map (a_writer, a_reader) a2b b2a = 
  (fun buf b -> a_writer buf (b2a b)),
  (fun word pos len -> let (pos, a) = (a_reader word pos len) in (pos, a2b a))
;;

let option (a_writer, a_reader) =
  let writer buf value =
    match value with
    | None -> Buffer.add_char buf 'n'
    | Some value ->
       Buffer.add_char buf 's';
       a_writer buf value
  and reader src pos len =
    if pos + 1 > len then raise (Too_short "char_reader in option reader");
    match src.[pos] with
    | 'n' -> (pos + 1, None)
    | 's' -> let (np, sth) = a_reader src (pos + 1) len in (np, Some sth)
    | _ -> raise (Too_short "wrong char in option_reader")
  in (writer, reader)
;;
