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

(** Parser *)

(** Parser raises Error if it is unable to parse the given string. *)
exception Error of string;;

(** A type of information that can be processed by the parser. It knows which
   values are acceptable and sometimes knows how to complete a word. Some
   such types will also know how to display themselves in the menu. *) 
type 'a t = {
  lex: (Lexing.lexbuf -> 'a);
  deparse: ('a -> string);
  complete: (Lexing.lexbuf -> string list);
  accept: ('a -> 'a);
  desc: string;
};;

(** Simple command and variable params *)
val int : ?max:int -> ?min:int -> unit -> int t;;
val float : unit -> float t;;
val unit : unit t;;
val bool : bool t;;
val string : string t;;

(** For optional parameters in commands *)
val option : 'a t -> 'a option t;;

(** For functions with more arguments *)
val pair : 'a t -> 'b t -> ('a * 'b) t;;
val triple : 'a t -> 'b t -> 'c t -> ('a * 'b * 'c) t;;
val quadruple : 'a t -> 'b t -> 'c t -> 'd t -> ('a * 'b * 'c * 'd) t;;
val pentuple : 'a t -> 'b t -> 'c t -> 'd t -> 'e t -> ('a * 'b * 'c * 'd * 'e) t;;
				    
(** If we want to accept only some arguments of the given type *)
val accept_only : 'a list -> 'a t -> 'a t;;

(** Adds a callback to a change. *)
val callback : ('a -> unit) -> 'a t -> 'a t;;

(** For commands or variables taking commands as parameters. The command
   can be a simple command (not taking arguments) or a one in \{such\} 
   brackets with params inside. Completes to a command and returns the 
   parsed command as argument *)
val command : (unit -> unit) t;;

(** For commands that can take variable names as parameters. *)
val variable : string t;;

(** [add_command name type description handler] adds the command to the list
   of commands. Examples of usage in MLGame:

   Parser.add_command "exec" Parser.string "executes the given script" exec

   Parser.add_command "bind_global" (Parser.pair Key.parser Parser.command)
     "Bind_global binds..." my_function;;

   Parser.add_command "disconnect" Net.local_player_parser "This fun.." fun;;*)
val add_command : string -> 'a t -> string -> ('a -> unit) -> unit;;

val add_variable : string -> 'a t -> 'a -> 'a ref;;

(* @raise Not_found *)
val get : string -> string;;
val set : string -> string -> unit;;

(** [parse expression] Parses a given string and returns a simple function
   that executes the parsed [expression].
   @raise Error if something went wrong. *)
val parse : string -> unit -> unit;;

(** Returns available command completions of given string *)
val available_completions : string -> string list;;

(** [create_log name prefix init] creates a debug logger that can be switched
   on and off via the parser. *)
val create_log : string -> string -> bool -> (string -> unit);;

val sextuple :
  'a t ->
  'b t -> 'c t -> 'd t -> 'e t -> 'f t -> ('a * 'b * 'c * 'd * 'e * 'f) t;;
val septuple :
  'a t -> 'b t -> 'c t ->
  'd t -> 'e t -> 'f t -> 'g t -> ('a * 'b * 'c * 'd * 'e * 'f * 'g) t;;
val octuple :
  'a t -> 'b t -> 'c t -> 'd t ->
  'e t -> 'f t -> 'g t -> 'h t -> ('a * 'b * 'c * 'd * 'e * 'f * 'g * 'h) t;;
val nonuple :
  'a t -> 'b t -> 'c t -> 'd t -> 'e t -> 'f t ->
  'g t -> 'h t -> 'i t -> ('a * 'b * 'c * 'd * 'e * 'f * 'g * 'h * 'i) t;;
