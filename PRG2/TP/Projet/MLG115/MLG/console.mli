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

(** Module responsible for the builtin console *)

(** Default function drawing the console. It only draws it if it is open.
   The game should use it if it doesn't have it's own. The mainloop given
   in {!Helpers.main} uses it. *)
val draw : unit -> unit;;

(** Function that should be called to tell the console to resize itself.
   Should be called after every change of video resolution eg by 
   {!Video.set_mode} *)
val resize : int -> int -> unit;;
