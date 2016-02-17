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

(** Module [Font] keeps a type representing any font type and all functions
   that work with this type *)
  
(** type representing a common font type *)
type t;;

(** Exception raised when any font associated functions fail *)
exception Error of string;;

(** [load file] returns font loaded from [file] in sfont format*)
val load : ?color:((Sdlvideo.color * int) -> (Sdlvideo.color * int)) -> ?alpha:bool -> string -> t;;

(** [draw_char ?cntx font x y c] draws character [c] with font [font] on [x, y]
   coordinates on context [cntx] *)
val draw_char : ?on:Video.t -> ?surf:Sdlvideo.surface -> t -> int -> int -> char -> unit;;

(** [draw_string ?cntx fnt x y str] draws given string [str] with font [font] 
   at [x, y] coordinates on context [cntx]. This function works like
   {!Font.draw_char}, but with whole string. *)
val draw_string : ?on:Video.t -> ?surf:Sdlvideo.surface -> t -> int -> int -> ?cursor : int -> 
  string -> unit;;

(** [height font] returns height of font [font] *)
val height : t -> int;;
 
(** [width font str] returns width of string [str] written in font [font] *)
val width : t -> string -> int;;

(** [divide_string fnt str max_w] *)
val divide_string : t -> string -> int -> string list;;
