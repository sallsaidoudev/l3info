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
  image : Video.t;
  letters : Sdlvideo.rect array;
  height : int;
};;

exception Error of string;;
  
let load ?color ?alpha name =
  try
    let image = Video.load_image name in
    Video.update_image image;
    let surf = image.Video.surf in
    Sdlvideo.lock surf;
    let colork = Sdlvideo.get_pixel surf ~x:0 ~y:1 in
    let image = Video.color_key ~ck:(Sdlvideo.get_RGB surf colork) image in
    Sdlvideo.unlock surf;
    Sdlvideo.set_color_key surf colork;
    let surf = match color with
    | None -> surf
    | Some colorizer -> Video.color_surface surf colorizer
    in
    Sdlvideo.lock surf;
    let (width, height, _) = Sdlvideo.surface_dims surf in
    let letters = 
      let pink = Sdlvideo.get_pixel surf ~x:0 ~y:0 in
      let rec first_non_pink x =
        if x = width then raise (Error "Invalid sfont") else
        if (Sdlvideo.get_pixel surf ~x ~y:0 <> pink) then x else
        first_non_pink (x + 1)
      in
      let rec first_pink x =
        if x = width then x else
        if (Sdlvideo.get_pixel surf ~x ~y:0 = pink) then x else
        first_pink (x + 1)
      in
      let ans = Array.create 128 (Sdlvideo.rect 0 0 0 0) in
      let rec letter_creator letter_begin pos =
        let letter_end = first_pink letter_begin in
        ans.(pos) <- 
          Sdlvideo.rect letter_begin 0 (letter_end - letter_begin) height;
        if pos < 126 then letter_creator (first_non_pink letter_end) (pos + 1)
        else ()
      in
      letter_creator (first_non_pink 0) 33;
      ans
    in
    Sdlvideo.unlock surf;
    let image = match color with
    | None -> image
    | Some cfun -> Video.color_image image cfun
    in
    { image = Video.optimize ?alpha image; letters = letters; height = height;} 
  with
    Sdlloader.SDLloader_exception s | Sdlvideo.Video_exn s -> 
      raise (Error s)
;;


(* internal, returns '?' if no such char *)
let get_char_rect {letters = l} chr =
  let code = Char.code chr in
  if code >= Array.length l || code < 32 then 
    l.(63)
  else
    l.(code)
;;

let draw_char ?on ?surf font x y chr =
  let src_rect = get_char_rect font chr in 
  Video.blit font.image ~src_rect ?on ?surf x y;
;;

let draw_simple_string ?on ?surf font x y str =
  let len = String.length str in
  let rec char_drawer pos x =
    if pos = len then () else
    let src_rect = get_char_rect font str.[pos] in
    Video.blit font.image ~src_rect ?on ?surf x y;
    let new_x =
      if str.[pos] = ' ' then 
        x + (get_char_rect font '!').Sdlvideo.r_w
      else 
        x + src_rect.Sdlvideo.r_w
    in char_drawer (pos + 1) new_x
  in
  char_drawer 0 x
;;

let height font = font.height;;

let width font str =
  let len = String.length str in
  let rec char_measurer pos x =
    if pos = len then x else
    let src_rect = get_char_rect font str.[pos] in
    let new_x =
      if str.[pos] = ' ' then 
        x + (get_char_rect font '!').Sdlvideo.r_w
      else 
        x + src_rect.Sdlvideo.r_w
    in char_measurer (pos + 1) new_x
  in char_measurer 0 0
;;

let draw_string ?on ?surf fnt x y ?cursor str =
  draw_simple_string ?on ?surf fnt x y str;
  match cursor with
  | Some pos when pos < String.length str && pos >= 0 -> 
      let x = x + width fnt (String.sub str 0 (pos + 1)) in
      Video.line ?on ?surf (x, y) (x, y + (height fnt) - 1) (255, 255, 255)
  | _ -> ()
;;
  
let divide_string fnt str w =
  let rec divider acc str pos =
    if str = "" then acc else
    let str_w = width fnt str in
    if str_w <= w then (str :: acc) else
    try
      let n_pos = String.index_from str (pos + 1) ' ' in
      let n_str = String.sub str 0 n_pos in
      let n_str_w = width fnt n_str in
      if n_str_w > w then
        if pos > 0 then begin (* We can divide *)
          let rest = String.sub str (pos(* ADD SPACE + 1*)) ((String.length str) - pos(* - 1*)) in
          divider ((String.sub str 0 pos) :: acc) rest 0
        end else begin
          let rest = 
            String.sub str (n_pos + 1) ((String.length str) - n_pos - 1) 
          in
          divider ((String.sub str 0 pos) :: acc) rest 0
        end
      else divider acc str n_pos
    with Not_found -> 
      if pos > 0 then begin
          let rest = 
            String.sub str (pos + 1) ((String.length str) - pos - 1) 
          in
          divider ((String.sub str 0 pos) :: acc) rest 0
      end else (str :: acc)
  in divider [] str 0
;;      
