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

(** Medium level UDP network protocol *)

(** Exception raised when information given or received does not match protocol
 *)
exception Error of string;;

(** Type that can be transferred through net. Examples of typing:
 - "I"     -> [I]
 - "IS"    -> [I; S]
 - "S[C]"  -> [S; [C; C; ...; C]]
 - "C[IF]" -> [C; [I; F; ...; I; F]] *)
type t = I of int | C of char | F of float | S of string | List of t list;;

(** [c2s_add params recv_fun] adds a new message to the protocol. The
  * additional parameters transmitted with each message are specified in
  * [params] in format "IC[CS]". [add] also takse the fucntion called after
  * having received the message and returns the sender of the message *)
val c2s_add : string -> (Udp.address -> t list -> unit)
  -> (Udp.socket -> t list -> unit);;

(** like {!Protocol.c2s_add}, but from server to clients *)
val s2c_add : string -> (t list -> unit)
  -> (Udp.socket -> Udp.address -> t list -> unit);;

(** [client_net_check ()] checks the connection for received messages and
  * calls all receivers. *)
val client_net_check : Udp.socket -> unit;;

(** [server_net_check ()] checks the socket for new clients and for
  * received messages. It also calls all receivers. *)
val server_net_check : Udp.socket -> unit;;

