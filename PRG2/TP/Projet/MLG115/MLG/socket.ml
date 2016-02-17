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

type t = int;;

let log = Parser.create_log "debug_socket" "[Socket] " true;;

let real_socks = Hashtbl.create 10;;

let rec find_first_free hashtbl i =
  if (Hashtbl.mem hashtbl i) then find_first_free hashtbl (i + 1) else i
;;

let sock_no = ref 0;;

let create sock = 
  incr sock_no;
  Hashtbl.replace real_socks !sock_no 
    (sock, Buffer.create 1024, Buffer.create 1024, Buffer.create 1024);
  !sock_no
;;

let (int_writer, int_reader) = Serialize.int;;
let sending_buf = Buffer.create 1024;;

let queue sock_no msg =
  try
    let (_, _, send_buf, _) = Hashtbl.find real_socks sock_no in
    Buffer.add_string send_buf msg
  with
  | Not_found -> Log.fatal "Socket.queue"
;;

let flush sock_no =
  try
    let (sock, _, send_buf, to_send) = Hashtbl.find real_socks sock_no in
    let len = Buffer.length send_buf in
    int_writer to_send len;
    Buffer.add_buffer to_send send_buf;
    Buffer.reset send_buf;
    let word = Buffer.contents to_send in
    let rest = Tcp.write sock word 0 (String.length word) in
    if String.length rest <> String.length word then begin
      Buffer.reset to_send;
      Buffer.add_string to_send rest
    end;
    log ("Socket " ^ (string_of_int sock_no) ^ "sending" ^ String.escaped (Buffer.contents sending_buf));
  with
  | Not_found -> Log.fatal "Socket.flush"
;;

let send sock_no msg =
  queue sock_no msg;
  flush sock_no
;;

let recv sock =
  let (socket, buf, _, _) = Hashtbl.find real_socks sock in
  List.iter (Buffer.add_string buf) (Tcp.read socket);
  let rec recv_aux acc =
    try
      let word = Buffer.contents buf in
      let len = Buffer.length buf in
      let (new_pos, want_len) = int_reader word 0 len in
      let cut = new_pos + want_len in
      if cut <= len then begin
        let ret = String.sub word new_pos want_len in
        log ("Socket->received:<" ^ (String.escaped ret) ^ ">");
        Buffer.reset buf;
        if cut < len then
          Buffer.add_string buf (String.sub word cut (len - cut));
        [ret] (*recv_aux (ret :: acc)*)
      end else [] (*acc*)
    with
    | Serialize.Too_short _ -> acc
  in
  recv_aux []
;;

let force_recv sock =
  let (socket, buf, _, _) = Hashtbl.find real_socks sock in
  let rec force_get () =
    try
      let word = Buffer.contents buf in
      let len = Buffer.length buf in
      let (new_pos, want_len) = int_reader word 0 len in
      let cut = new_pos + want_len in
      if cut <= len then begin
        let ret = String.sub word new_pos want_len in
        Buffer.reset buf;
        if cut < len then
          Buffer.add_string buf (String.sub word cut (len - cut));
        ret
      end else begin
        Buffer.add_string buf (Tcp.force_read socket);
        force_get ()
      end
    with
    | Serialize.Too_short _ -> 
        Buffer.add_string buf (Tcp.force_read socket);
        force_get ()
  in force_get ()
;;

let destroy sock_no =
  let (sock, _, _, _) = Hashtbl.find real_socks sock_no in
  Tcp.close sock;
  Hashtbl.remove real_socks sock_no
;;
