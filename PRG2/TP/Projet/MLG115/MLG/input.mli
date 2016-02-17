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

(** Module input is responsible for handling all low level input releted
   things. Input ands following commans to parser:
    - bind_action
    - bind_global
    - quit *)

(** input mode type. 
   An input mode is the state in which the game is. All input is processed
   according to this mode. Eg when the player has openede the menu all input
   is directed to the menu. It can also be used in games, eg when the player
   is in the shop other keybindings are active. *)
type mode;;

(** Exception Quit is raised when the player has requested quit either by
   pressing Ctrl-C, trying to close the window, or by non-fatal signal *)
exception Quit;;

(** [add_mode name handle_event_fun] creates new mode named [name] in
   which events are handled by [handle_event_fun]. If the mode is a super
   mode it can be set by the user and afterwards the user may cancel it *)
val add_mode : ?super:bool -> string -> (Sdlevent.event -> unit) -> mode;;

(** [set_mode m] sets current mode to m*)
val set_mode : mode -> unit;;

(** [process_events ?n ()] processes at most [n] events from a buffer. [n] is
   optional. It returns if anything has happened. *)
val process_events : ?events_per_frame:int -> unit -> bool;;

(** [add_action ?mode action_name start_fun end_fun] adds an action to the
   console (allows binding it). When a local player does "bind_action
   key_name action_name n" on the console then after pressing [key_name],
   [start_fun] will be called with param [n]. It allows you to use one action
   for several players. 
   @param mode is an optional parameter which decides in which mode the action
   should be active. If not given the action is added to current mode. *) 
val add_action : ?mode:mode -> string -> (int -> unit) -> (int -> unit) -> 
  unit;;

(** [get_real_mode] @return current privileged mode or mode if none is set*)
val get_real_mode : unit -> mode;;

(** Internal. Sets the callback for event repeating *)
val set_repeat_handler : (unit -> bool) option -> unit;;
