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

(** Module providing easy access to edit input modes *)

(** type representing an edit mode *)
type t;;

(** Creates a new edit mode *)
val create : unit -> t;;

(** Gets the current contenst of edit box *)
val get : t -> string;;

(** Returns the position of the cursor *)
val get_pos : t -> int;;

(** Sets the string an the position of the cursor *)
val set : t -> string -> int -> unit;;

(** Clears the contents of the editbox and adds the line to command history *)
val enter_pressed : t -> unit;;

(** Default key handler for the editbox, to be used with {!Input.add_mode} *)
val handle : t -> ?history:bool -> Sdlevent.event -> unit;;

val handle_repeat : ('a -> unit) -> 'a -> unit;;
