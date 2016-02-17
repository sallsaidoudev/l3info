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

type address = Unix.sockaddr;;
type socket = Unix.file_descr;;

Sys.set_signal Sys.sigpipe Sys.Signal_ignore;;

let handle_error fnctn args =
  try
    fnctn args
  with
  | Unix.Unix_error(err, fun_name, arg) ->
      let str = fun_name ^ "(" ^ arg ^ "): " ^ Unix.error_message err in
      raise (Error str)
;;

(* Internal, throws Unix_error*)
let resolve addr_or_name =
  try
    Unix.inet_addr_of_string addr_or_name
  with
  | Failure ("inet_addr_of_string") ->
      (Unix.gethostbyname addr_or_name).Unix.h_addr_list.(0)
;;

let connect host port =
  let connect_aux () =
    let host_addr = resolve host in
    let sock = Unix.socket Unix.PF_INET Unix.SOCK_DGRAM 0 in
    let sockaddr = Unix.ADDR_INET (host_addr, port) in
    Unix.connect sock sockaddr;
    sock
  in handle_error connect_aux ()
;;

let close sock =
  handle_error Unix.close sock
;;

let create_socket port =
  let new_socket_aux () = 
    let addr = Unix.ADDR_INET (Unix.inet_addr_any, port) in
    let sock = Unix.socket Unix.PF_INET Unix.SOCK_DGRAM 0 in
    Unix.setsockopt sock Unix.SO_REUSEADDR true;
    Unix.bind sock addr;
    sock
  in handle_error new_socket_aux ()
;;

let recv sock str pos len = 
  let recv_aux () =
    try
      Unix.set_nonblock sock;
      Unix.recvfrom sock str pos len []
    with 
    | Unix.Unix_error (Unix.EAGAIN, _, _) 
    | Unix.Unix_error (Unix.EWOULDBLOCK, _, _) -> (0, Unix.ADDR_UNIX "")
  in handle_error recv_aux ()
;;


let describe_connection = function
  | Unix.ADDR_INET (a, b) ->
      "Inet: " ^ (Unix.string_of_inet_addr a) ^ " Port: " ^ (string_of_int b)
  | Unix.ADDR_UNIX s -> 
      "Unix: " ^ s
;;

let send sock ?dest str pos len =
  let send_aux () =
    Unix.clear_nonblock sock;
    let rec sender pos len =
      let succes = match dest with
      | Some dst -> Unix.sendto sock str pos len [] dst
      | None -> Unix.send sock str pos len [] in
      if succes < len then sender (pos + succes) (len - succes)
    in sender pos len
  in handle_error send_aux ()
;;

let poll sock timeout =
  match Unix.select [sock] [] [] timeout with
  | [], [], [] -> false
  | _ -> true
;;
