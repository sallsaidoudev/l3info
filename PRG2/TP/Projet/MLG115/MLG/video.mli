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

(** Low level video routines *)

(** TODO Type t is a type which represents an image for the actual
   mode or an. Atutomagically updated on videomode change.  *)
type t = {
  mutable surf : Sdlvideo.surface;
  mutable last_mode : int;
  mutable provide : (unit -> Sdlvideo.surface);
  mutable cam_pos : int * int;
  mutable rect : Sdlvideo.rect;
  mutable vmem : bool;
};;

(** [create_surface (w, h)] returns an initially undefined surface with
   dimensions [(w, h)] *)
val create_surface : ?alpha:bool -> int * int -> Sdlvideo.surface;; 

(** Loads a given image of any type supported by SDLimage. You should consider
   using {!Video.optimize} on the loaded image to make blitting efficient. If
   the display won't be initialized (eg. on server side) it doesn't matter. *)
val load_image : string -> t;;

(** [duplicate_surface surf] creates a copy of [surf]. Since drawing on
   surfaces destroys them if you want to do so and keep the original image
   use this function *)
val duplicate_surface : Sdlvideo.surface -> Sdlvideo.surface;;

(** [create_context x y w h (cam_x, cam_y)] creates a context at [(x, y)] with
   size [(w, h)] with initial camera position set to [(cam_x, cam_y)] *)
val create_context : int -> int -> int -> int -> int * int -> t;;

(*val get_context : Sdlvideo.surface -> context;;*)

(** [get_cam_pos context ()] returns the coordinates of the world shown by
   upper left corner of [context]. *)
val get_cam_pos : ?on:t -> unit -> int * int;;

(** [set_cam_pos context (x, y)] sets the coordinates of the world shown by
   upper left corner of [context] to [(x, y)]. *)
val set_cam_pos : ?on:t -> int * int -> unit;;

(** [set_cam_pos_center context (x, y)] sets the coordinates of the world
   displayed in center point of [context] to [(x, y)]. *)
val set_cam_pos_center : ?on:t -> int * int -> unit;;

(** [move_cam context (x, y)] adds [(x, y)] to the coordinates of world
   displayed in [context]. *)
val move_cam : ?on:t -> int * int -> unit;;

(** [blit surf src_rect context x y] Copies src_rect from surf to x, y on
   context. It clips to the context. *)
val blit : t -> ?src_rect:Sdlvideo.rect -> ?on:t -> ?surf:Sdlvideo.surface -> int -> int 
  -> unit;; 

(** [fill context rect color] Fills the given rect on the given context.
   It clips to the context. *)
val fill : ?on:t -> ?surf:Sdlvideo.surface -> ?rect:Sdlvideo.rect -> ?alpha:int -> Sdlvideo.color -> unit;; 

(** [line surf x1 y1 x2 y2 color] draws a line from [(x1, y1)] to [(x2, y2)]
   using [color]. It is optimized if line is horizontal or vertical. *)
val line : ?on:t -> ?surf:Sdlvideo.surface -> int * int -> int * int -> ?alpha:int -> Sdlvideo.color -> unit;; 

val point : ?on:t -> int * int -> ?alpha:int -> Sdlvideo.color -> unit;;

(** [ellipse ?on (x, y) (rx, ry) fill color] draws an optionally filled
   ellipse at [(x, y)] with radius [(rx, ry)] using [color]. 
   @raise Invalid_argument if [rx] or [ry] is not greater than zero. *)
val ellipse : ?on:t -> int * int -> int * int -> bool -> ?alpha:int -> Sdlvideo.color
  -> unit;;

(** [get_resolution ()] returns the current video resolution *)
val get_resolution : unit -> int * int;; 

(** [set_mode full_screen (width, height) bpp] *)
val set_mode : bool -> int * int -> int -> unit;; 

(** Flips the front and back buffers *)
val flip : unit -> unit;; 

(** [quit] deinitializes video mode. [quit] should be always called, even if
   an exception occurs. *)
val quit : unit -> unit;;

val color_surface : Sdlvideo.surface -> ((Sdlvideo.color * int) -> (Sdlvideo.color * int)) -> Sdlvideo.surface;;

(** [describe_surface surf] returns a string containing all information about
   [surf] *)
val describe_surface : Sdlvideo.surface -> string;;

(** [provide_image provide_fun] Creates a Video.t image that will refresh
   itself using the given fun when needed (video mode change). *)
val provide_image : (unit -> Sdlvideo.surface) -> t;;

val optimize : ?alpha:bool -> t -> t;;

val color_key : ?ck:Sdlvideo.color -> t -> t;;

(* Always call this before accesing t.surf *)
val update_image : t -> unit;;

(** [image_size image] returns the dimensions of [image] *)
val image_size : t -> int * int;;

val color_image : t -> ((Sdlvideo.color * int) -> (Sdlvideo.color * int)) -> t;;

val tile_fill : ?on:t -> ?surf:Sdlvideo.surface -> t -> (int * int) -> (int * int) -> unit;;
val shade_tile : t;;
val shade : ?on:t -> ?surf:Sdlvideo.surface -> (int * int) -> (int * int) -> unit;;

(*val set_alpha : t -> int -> unit;;*)
