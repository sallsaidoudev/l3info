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

open Unix;;

exception Lost;;
exception Error of string;;

type socket = file_descr;;

external set_nodelay : socket -> unit = "mlsetnonblock";;

let create_socket port limit =
  try
    begin 
      try Sys.set_signal Sys.sigpipe Sys.Signal_ignore;
      with _ -> ()
    end;
    let addr = ADDR_INET(inet_addr_any, port) in
    let sock = Unix.socket PF_INET SOCK_STREAM 0 in
    setsockopt sock SO_REUSEADDR true;
    bind sock addr;
    listen sock limit;
    (* Does not work on MS Windos *)
    (* Unix.set_nonblock sock; *)
    set_nodelay sock;
    sock
  with
    Unix_error _ -> raise (Error "Unable to create socket")
;;

let check_socket sock =
  let rec check_socket_aux acc =
    try
      match select [sock] [] [] (0.) with
      | [], [], [] -> acc
      | _ -> 
          let (desc, from) = accept sock in
          check_socket_aux (desc :: acc)
    with
    | Unix.Unix_error (EINTR, _, _) -> check_socket_aux acc
    | _ -> raise (Error "Error in select")
  in check_socket_aux []
;;

let resolve addr_or_name =
  try
    inet_addr_of_string addr_or_name
  with
  | Failure ("inet_addr_of_string") ->
      try
        (Unix.gethostbyname addr_or_name).h_addr_list.(0)
      with
        Not_found -> raise (Error ("Unable to resolve host: " ^ addr_or_name))
;;

let connect address port =
  try
    let sock = Unix.socket PF_INET SOCK_STREAM 0 in
    set_nodelay sock;
    Unix.connect sock (ADDR_INET (resolve address, port));
    set_nodelay sock;
    sock
  with 
    _ -> raise (Error "Connection refused") (* TODO *)
;;

let write desc str pos len =
  try
    set_nonblock desc;
    (* Does not work on MS Windos *)
    (* Log.debug (Printf.sprintf "rcv:%i,snd:%i" (Unix.getsockopt_int desc SO_RCVLOWAT) (Unix.getsockopt_int desc SO_SNDLOWAT)); *)
    (* Log.debug (Printf.sprintf "rcv:%f,snd:%f" (Unix.getsockopt_float desc SO_RCVTIMEO) (Unix.getsockopt_float desc SO_SNDTIMEO)); *)
    let rec do_write pos len =
      try
        let written = Unix.write desc str pos len in
        if written < len then do_write (pos + written) (len - written) else ""
      with
      | Unix.Unix_error (Unix.EWOULDBLOCK, _, _) 
      | Unix.Unix_error (Unix.EAGAIN, _, _) ->
          String.sub str pos len
    in do_write pos len
  with
  | _ -> raise Lost
;;

let read_buffer = String.create 4096;;

let rec read desc =
  try
    match select [desc] [] [desc] 0. with
    | _, _, [desc] -> 
        raise Lost
    | [desc], _, _ -> 
        let len = Unix.read desc read_buffer 0 4096 in
        if len = 0 then raise Lost else
        (* (String.sub read_buffer 0 len) :: read desc *)
        [String.sub read_buffer 0 len]
    | _, _, _ -> []
  with
  | Unix.Unix_error (EINTR, _, _) -> read desc
  | _ -> raise Lost
;;

let force_read desc =
  let len = Unix.read desc read_buffer 0 4096 in
  if len = 0 then raise Lost else
  (* (String.sub read_buffer 0 len) :: read desc *)
  String.sub read_buffer 0 len
;;

let close desc =
  try close desc with _ -> ()
;;
