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

(** Low level UDP network access *)

(** Exception Error is raised when the operating system cannot compleat
   the requested operation, for example "Out of memory" *)
exception Error of string;;

(** Type representing either a connected or a listening (bound) UDP socket *)
type socket;;

(** Type representing the net address of a host used to recognize clients *)
type address;;

(** [connect hostname port] creates a socket ready to send to specified host. 
   You need to send without providing destination address or to use module 
   Protocol. *)
val connect : string -> int -> socket;;

(** [poll sock timeout] checks if any new messages arrived to the given 
    socket. *)
val poll : socket -> float -> bool;;

(** [send sock to msg pos len] sends given message to host connected with sock
   or to given destination. @raise Error if sock is not connected and dest is
   not given. *)
val send : socket -> ?dest:address -> string -> int -> int -> unit;;

(** [recv sock msg pos len] returns number of bytes read and who sent it.
   It mat return  (0, _) if no data recved *)
val recv : socket -> string -> int -> int -> int * address;;

(** [new_socket port] creates a listening socket on the given port. *)
val create_socket : int -> socket;;

(** [close sock] should be used to disconnect or unbind the given socket *)
val close : socket -> unit;;

(** [describe_connection address] returns a string representation of the 
   given net address [address]. *)
val describe_connection : address -> string;;

