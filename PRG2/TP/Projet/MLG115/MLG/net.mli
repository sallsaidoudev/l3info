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

(** High-level networking.
   This module provides a protocol for data exchange and synchronization.*)

(** [process tick_time] Do what i mean. should be called every mainloop
   rotation in client and server.  
   @param tick_time should be true if it is time for a new frame 
   @return [true] if a new frame should happen. Whie we are the server or when
   not connected it is equal to [tick_time] whilst on a client it is [true]
   only if a new packet with messages has been received. It means that all
   events which happened have been received and processed and it is time for a
   new frame to happen. *)
val process : bool -> bool;;

(** [init pl_change_fun] adds 'connect' and 'server' to console. 
   @param pl_change_fun is the function called on each instance of the program
   when a new player comes or a player leaves. It informs the game that a
   player has connected or leaved. The game receives the number
   of player, is the player a local one and if the player is a new one. *)
val init : (int -> bool -> bool -> unit) -> unit;;

(** [add_broadcast serialize client_recv] adds an automatically broadcasted
   message. @return function used to send such this message. When any of the
   connected instances of the program calls the this function, [client_recv]
   will be called on all of them, including the one that send it and the
   server.

   Most game actions should be added with this function 
   Here and in all following functions the int param is the number of the
   player who sent the original message. *)
val add_broadcast : 'a Serialize.t -> (int -> 'a -> unit) 
  -> (int -> 'a -> unit);;

(* [add_client_to_server] like add_broadcast, but adds a message from client
   to the server.  It checks if the given player is on the client from which
   the message was sent *) 
val add_client_to_server : 'a Serialize.t -> (int -> 'a -> unit) 
  -> (int -> 'a -> unit);;

(* [add_server_to_client serializer client_recv] registers a new message
   in protocol and returns a function which sends it from the server
   to all clients on which there is least one of the given players list.
   It is never called on the server. *)
val add_server_to_client : 'a Serialize.t -> ('a -> unit) 
  -> (int list -> 'a -> unit);;

(* [add_server_broadcast serializer client_recv] registers a new message
   in protocol and returns a function which sends it from the server
   to all clients. The receiver is also called on the server once.

   Internally it uses add_server_to_client *)
val add_server_broadcast : 'a Serialize.t -> ('a -> unit) -> ('a -> unit);;

(** [check_privileged ()] @return [true] if we are privileged. At the time
   of writing this only the server is privileged. *)
val check_privileged : unit -> bool;;

(** [add_var name converter] is used to add a net changeable variable. This is
   a variable just like added by {!Parser.add_variable}, but it can be changed
   via console only on privileged clients. Every console change to such a
   variable is broadcasted to all other clients and to the server. *)
val add_var : string -> 'a Parser.t -> 'a -> 'a ref * (string -> unit);;

(** [get_local_players ()] @return the list of local player numbers *)
val get_local_players : unit -> int list;;

(** [add_synchronizer fnctn] adds a function called on the server whenever
   a new player connects. It is used to synchronize the new player with the
   current world state *)
val add_synchronizer : (int -> unit) -> unit;;
