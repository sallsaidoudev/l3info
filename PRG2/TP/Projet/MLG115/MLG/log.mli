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

(** Logging info on the console.
   When console is not available (not in video mode) informations are logged
   on stderr *)

(** Information message *)
val info : string -> unit;;

(** Error message *)
val error : string -> unit;;

(** Debug message *)
val debug : string -> unit;;

(** A fatal message. Use it only if the program cannot continue.
   It uses [Pervasives.exit 1] to terminate the program with exit code 1. *)
val fatal : string -> 'a;;

(** [get ()] is used to get the contents of log.
   It can be used by a user console *)
val get : unit -> (string * string) list;;

(** Internal. Logs a debug message that is associated with a variable 
   that sais if it should be shown on the console *)
val remember_debug : bool ref -> string -> unit;;

val dump : string -> unit;;
