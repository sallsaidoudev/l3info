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

(** Medium level TCP interface.

   The sockets offered by this module are comparable. 

   Every send message is read as a whole. 
   (They are not divided and do not concatenate).

   Operations provided by this module should not be mixed with the ones 
   provided by {!Tcp}*)

(** Type representing a single socket *)
type t;;

(** @return a socket associated with the given {!Tcp.socket}. *)
val create : Tcp.socket -> t;;

(** [send socket message] sends the given [message] *)
val send : t -> string -> unit;;

(** [queue socket message] adds the given [message] to send queue of [socket]*)
val queue : t -> string -> unit;;

(** [flush socket] sends whole send queue of [socket] *)
val flush : t -> unit;;

(** [recv socket message] returns a list of messages received.
   (max 1 per call) *)
val recv : t -> string list;;

(** [force_recv socket] is a blocking version of {!Socket.recv} that waits
   for a message. *)
val force_recv : t -> string;;

(** [destroy socket] closes the socket and deletes its buffer at all *)
val destroy : t -> unit;;
