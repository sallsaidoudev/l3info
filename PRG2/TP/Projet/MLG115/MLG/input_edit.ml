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

type t = {
    mutable str : string;
    mutable pos : int;
    mutable history_back : string list;
    mutable history_fwd  : string list;
  };;

let create () = { str = ""; pos = 0; history_back = []; history_fwd = []};;


let get {str = s} = s;;

let get_pos {pos = p} = p;;

let set box str pos = 
  box.str <- str;
  box.pos <- pos
;;

let enter_pressed box =
  box.history_back <- 
    box.str::(List.rev_append box.history_fwd box.history_back);
  box.history_fwd <- [];
  box.str <- "";
  box.pos <- 0
;;

(* Internal, puts char in box at current pos. May lenghten str *)
let put_char box chr =
  let str_len = String.length box.str in
  let new_str = String.create (str_len + 1) in
  String.blit box.str 0 new_str 0 box.pos;
  new_str.[box.pos] <- chr;
  String.blit box.str box.pos new_str (box.pos + 1) (str_len - box.pos);
  box.str <- new_str
;;

(* Internal, deletes the char at current pos in box *)
let del_char box =
  let str_len = String.length box.str in
  let new_str = String.create (str_len - 1) in
  String.blit box.str 0 new_str 0 box.pos;
  String.blit box.str (box.pos + 1) new_str box.pos (str_len - box.pos - 1);
  box.str <- new_str
;;
let repeat_latency = Parser.add_variable "repeat_latency" (Parser.int ()) 300;;
let repeat_speed = Parser.add_variable "repeat_speed" (Parser.int ()) 50;;

let handle_repeat fnctn param =
  let repeater =
    let start = ref (Sdltimer.get_ticks ()) in
    fun () ->
      let time = (Sdltimer.get_ticks ()) - !start in
      if time > !repeat_latency then begin
        fnctn param;
        start := !start + !repeat_speed;
        true
      end else false
  in
  Input.set_repeat_handler (Some repeater);
  fnctn param
;;

let handle box ?(history=true) event =
  let rec handle_keydown key =
    match key.Sdlevent.keysym with
    | Sdlkey.KEY_LEFT ->
        if box.pos > 0 then box.pos <- box.pos - 1
    | Sdlkey.KEY_RIGHT ->
        if box.pos < (String.length box.str) then box.pos <- box.pos + 1
    | Sdlkey.KEY_UP when history -> (
        match box.history_back with
	| [] -> ()
	| hd::tl -> 
	    box.history_fwd <- box.str::box.history_fwd;
            let len = (String.length hd) in
            if box.pos > len then box.pos <- len;
	    box.str <- hd;
            box.history_back <- tl )
    | Sdlkey.KEY_DOWN when history -> (
        match box.history_fwd with
	| [] -> ()
	| hd::tl -> 
      	    box.history_back <- box.str::box.history_back;
            let len = (String.length hd) in
            if box.pos > len then box.pos <- len;
 	    box.str <- hd;
            box.history_fwd <- tl )
    | Sdlkey.KEY_HOME -> box.pos <- 0
    | Sdlkey.KEY_END -> box.pos <- String.length box.str
    | Sdlkey.KEY_DELETE ->
        if box.pos < String.length box.str then
          del_char box
    | Sdlkey.KEY_BACKSPACE ->
        if box.pos > 0 then begin
          box.pos <- box.pos - 1;
          del_char box
        end
    | _ ->
        try
          let chr = Sdlkey.char_of_key key.Sdlevent.keysym in
          let shift = key.Sdlevent.keymod land Sdlkey.kmod_shift in
          let schr = if shift > 0 then Keys.shifted_char chr else chr in
          put_char box schr;
          box.pos <- box.pos + 1
        with
          Invalid_argument _ -> ()
  in
  match event with
  | Sdlevent.KEYDOWN key -> handle_repeat handle_keydown key
  | Sdlevent.KEYUP key -> Input.set_repeat_handler None
  | _ -> ()
;;

