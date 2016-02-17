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

(** Packing objects into net transferable buffers *)

(** Type representing a serializer of an object. 

   It is a pair ([writer, reader]). [writer] is adds the given value
   to the buffer. [reader] takes a message starting position and length of
   the message and returns the new position and the value that has been read *)
type 'a t = (Buffer.t -> 'a -> unit) * (string -> int -> int -> int * 'a);;

(** Exception raised when the message is too short for the reader to read
   it's value 

   Every serializer should check if the message is long enought to read its
   value and if not should raise this exception *)
exception Too_short of string;;

(** An empty serializer *)
val unit : unit t;;

(** Character serializer *)
val char : char t;;

(** Integer value serializer. The size of the serialized value depends on
   the integer: 
{v 1b -64 to 64
2b -8k to 8k
3b -1M to 1M
4b -128M to 128M
5b bigger v} *)
val int : int t;;

val float : float t;;

(** String serializer. Its length as {!Serialize.int} and the contents. *)
val string : string t;;

(** @deprecated 31bit integer serializer that always uses 4 bytes. *)
val int31 : int t;;

(** Concatenation of its elements *)
val pair : 'a t -> 'b t -> ('a * 'b) t;;

(** List length as {!Serialize.int} and its elements concateneted. *)
val list : 'a t -> ('a list) t;;

val map : 'a t -> ('a -> 'b) -> ('b -> 'a) -> 'b t;;

(** A marshaling serializer. Can serialize a value of any type, but is not
   safe nor optimal. Every serialization has additional header which is about
   20bytes long *)
val marshal : 'a t;;

val option : 'a t -> ('a option) t;;
