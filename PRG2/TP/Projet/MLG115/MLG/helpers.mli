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

(** Nice helpers *)

(** [add_video_mode video_change_fun] adds a the variable "video_mode"
   to the parser and sets [video_change_fun] to be called whenever the video
   mode is changed. The two params received is the new resolution. *)
val add_video_mode_var : (unit -> unit) -> unit;;

(** [add_chat ()] adds command "say" to the console *)
val add_chat : unit -> unit;;

(** [vertical_split ()] returns a list of contexts for players. The screen
   is split to equal parts one for every local_player. *)
val vertical_split : unit -> Video.t list;;

(** [main frame_delay new_frame_fun draw_fun] is the mainloop *)
val main : (unit -> unit) -> (unit -> unit) -> unit;;
(** @return number of frames that happened *)
val main_no_quit : (unit -> unit) -> (unit -> unit) -> int;;

(** dalay is the reference to the delay beetween frames. It is available from
   the console *)
val delay : float ref;;

(** Adds a server action. add_action and add_action_pair are usually better *)
val add_net_action : ?mode: Input.mode -> string ->
  (int -> unit) -> (int -> unit) -> unit;;

(** [add_action ?more broadcast key] 
   adds an action that may be optionally broadcasted. Returns a function 
   taking player number and returning true if the action is performed or 
   false if it is not *)
val add_action : ?mode:Input.mode -> bool -> string -> (int -> bool);;

(** [add_action_pair ?mode broadcast start_key end_key]
   adds an action pair that may be optionally broadcasted. 
   @return a function taking player number and returning 1 if only [start_key]
   is pressed, -1 if only [end_key] is pressed and 0 in other cases *) 
val add_action_pair : ?mode:Input.mode -> bool -> string -> string -> (int ->
   int);;

(** [add_action_group ?mode broadcast keys_list]
   adds an optionally broadcasted group of actions. 
   @return a function taking player number and returning the list of actions
   that were pressed for a part of the time since the last call. *)
val add_action_group : ?mode:Input.mode -> bool -> string list 
  -> (int -> string list);;


(** [add_sprite_set_info sprite_serializer set]
   adds a net synchronization message, that will synchronize [set] in
   new connected clients. See {!Net.add_synchronizer} *)
val add_sprite_set_info : 'a Sprite.t Serialize.t -> 'a Sprite.set -> unit;;
