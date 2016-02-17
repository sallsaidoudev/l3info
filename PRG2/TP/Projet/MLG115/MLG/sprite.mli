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

(** Sprites and collision *)

(** A sprite. *)
type 'a t;;

(** Type representing a set of sprites that represent the same type of 
   objects in collision and in storing information. *)
type 'a set;;

(** Hashtbl from 'a to 'b sprites *)
type ('a, 'b) table;;

(** {6 Sprites} *)

(** [create ?set data frames ?width position] Creates a sprite with frames
   from the given surface. *)
val create : ?set:'a set -> 'a -> Video.t -> ?width:int ->
  int * int -> 'a t;;

(** [move_to sprite (x, y)] Sets the position of [sprite] to [(x, y)] *)
val move_to : 'a t -> int * int -> unit;;

(** [move sprite (dx, dy)] moves sprite [spr] by [(dx, dy)] *)
val move : 'a t -> int * int -> unit;;

(** [get_pos sprite] @return the position of [sprite] *)
val get_pos : 'a t -> int * int;;

(** [set_data sprite data] sets the data of [sprite] to [data] *)
val set_data : 'a t -> 'a -> unit ;;

(** [get_data sprite] returns the data of [sprite] *)
val get_data : 'a t -> 'a;;

(** [get_size sprite] returns the size of [sprite] *)
val get_size : 'a t -> (int * int);;

(** [delete sprite] removes [sprite] from all sets it belong to *)
val delete : 'a t -> unit;;

(** {6 Sprite sets } *)

module Set : sig
  (** [create size] creates a set of sprites.
     @param size is the initially allocated size, it will grow if necessary *)
  val create : int -> 'a set;;

  (** [add set sprite] adds [sprite] to [set]. It does nothing if it was
     already in the set *)
  val add : 'a set -> 'a t -> unit;;

  (** [del set sprite] removes [sprite] from the given [set] *)
  val del : 'a set -> 'a t -> unit;;

  (** [clear set] removes all sprites from the given set. *)
  val clear : 'a set -> unit;;

  (** [iter fnctn set] iterates a function over a set. The function may
     safely remove the sprite it operates on. *)
  val iter : ('a t -> unit) -> 'a set -> unit;;
  val iter_data : ('a t -> 'a -> unit) -> 'a set -> unit;;

  (** [set_set_boundary min_x max_x min_y max_y] *)
  val set_boundary : 'a set -> int -> int -> int -> int -> unit;;

  (** [set_collision set width height] creates collision structures for 
     set [set] with bucket size set to [(width, height)]. *)
  val set_collision : 'a set -> int -> int -> unit;;

  (** [mem set sprite] @return true if [sprite] is in [set] *)
  val mem : 'a set -> 'a t -> bool;;

  (** [fold fnctn set value] folds a function through a set. The function may
     safely remove the sprite it operates on. *)
  val fold : ('a -> 'b t -> 'a) -> 'b set -> 'a -> 'a;;
  val fold_data : ('a -> 'b t -> 'b -> 'a) -> 'b set -> 'a -> 'a;;

end;;

(** {6 Collision } *)

(** [add_collison_fun set1 set2 per_pixel collision_fun] 
   adds [collision_fun] to the list of functions called when a sprite from
   set1 collides with any from set2
   @param per_pixel if set to true per_pixel collision will be checked
   @param alpha_bias see {!Sprite.collides_with}
   @raise Log.fatal when {!Sprite.Set.set_collision} was not called for any of
   any of the given sets. *)
val add_collision_fun : 'a set -> 'b set -> ?alpha_bias:int -> bool ->
  ('a t -> 'b t -> unit) -> unit;;

(** [check_collisions sprite] finds all objects that [sprite] collides with
   all sets that were registered for collision with the sets [sprite] belongs
   to. For every collision it calls the apropriate function registered by
   {!Sprite.add_collision_fun} *)
val check_collisions : 'a t -> unit;;

(** [collides_with spr per_pixel set] returns the list of all sprites from
   [set] that collide with [spr]
   @param alpha_bias is an optional parameter, that for surfaces with alpha
   channel means what sum of alpha values hast to be overcomed for collision 
   to be detected. The default is 255 (collision when sum is over 255), 
   while maximum for any surface is 255.
   If [per_pixel] is [true] per pixel collision will be checked *)
val collides_with : 'a t -> ?alpha_bias:int -> bool -> 'b set -> 'b t list;;

(** {6 World boundary } *)

(** [in_bounds sprite] checks if the sprite is ouside of world in any of the
   sets it belongs to *)
val in_bounds : 'a t -> bool;;

(** [move_in_bounds sprites (dx, dy)] moves sprite as far as possible so that
   it remains in bounds *) 
val move_in_bounds : 'a t -> ?chk: ('a t -> bool) -> int * int -> int * int;;

(** {6 Drawing} *)

(** [draw cnt sprite] draws sprite [spr] on context [cnt]. [cnt] is optional *)
val draw : ?on:Video.t -> 'a t -> unit;;

(** [set_animation_frame sprite frame_num] Sets the frame displayed by [sprite]
   to [frame_num] picture on the image. If wrong frame number is specified
   an error message is shown on the console. *)
val set_animation_frame : 'a t -> int -> unit;;

(** [get_animation_frame sprite] @return the number of frame currently 
   displayed by [sprite] *)
val get_animation_frame : 'a t -> int;;

val set_frames : 'a t -> ?width:int -> Video.t -> unit;;
val get_frames : 'a t -> Video.t;;

(** [mask_cut from_where cut_what alpha_bias] cuts all pixel's from 
   [from_where] where [cut_what] has alpha bigger than [alpha_bias] *)
val mask_cut : 'a t -> 'b t -> int -> unit;;

module Table : sig
  val create : int -> ('a, 'b) table
  val add : ('a, 'b) table -> 'a -> 'b t -> unit
  val del : ('a, 'b) table -> 'a -> unit
  val clear : ('a, 'b) table -> unit
  val iter : ('a -> 'b t -> unit) -> ('a, 'b) table -> unit
  val iter_data : ('a -> 'b t -> 'b -> unit) -> ('a, 'b) table -> unit
  val fold : ('a -> 'b t -> 'c -> 'c) -> ('a, 'b) table -> 'c -> 'c
  val fold_data : ('a -> 'b t -> 'b -> 'c -> 'c) -> ('a, 'b) table -> 'c -> 'c
  val find : ('a, 'b) table -> 'a -> 'b t
  val set : ('a, 'b) table -> 'b set
end;;
