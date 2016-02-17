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
let edit_box = Input_edit.create ();;

let font = ref None;;

let shade_image =
  let provide () =
    let surface = Video.create_surface ~alpha:true (800, 600) in
    Sdlvideo.display_format ~alpha:true (Video.color_surface surface (fun _ -> ((0, 0, 0), 128)))
  in Video.provide_image provide
;;
    
let shade ?on (x, y) (w, h) =
  let src_rect = Sdlvideo.rect 0 0 w h in
  Video.blit shade_image ~src_rect ?on x y
(*  let rect = Sdlvideo.rect 0 0 w h in
  Video.fill ~rect ~alpha:127 (0, 0, 0)*)
;;

let pg_ups = ref (-1);;

let console_event_handle event =
  let handle_keydown keysym =
    let complete after = function
      | [] -> ()
      | [cmd] -> Input_edit.set edit_box (cmd ^ after) (String.length cmd)
      | lst -> Log.info (String.concat " " lst)
    in
    match keysym with
    | Sdlkey.KEY_TAB -> 
        let box, pos = Input_edit.get edit_box, Input_edit.get_pos edit_box in
        let before = String.sub box 0 pos
        and after = String.sub box pos (String.length box - pos) in
        let finishes = Parser.available_completions before in
        complete after (List.sort compare finishes)
    | Sdlkey.KEY_RETURN -> 
        if (Input_edit.get edit_box) = "" then () else begin
          let command = Input_edit.get edit_box in
	  Input_edit.enter_pressed edit_box;
          try Parser.parse command ()
          with Parser.Error desc -> Log.error desc;
        end
    | Sdlkey.KEY_PAGEUP -> if !pg_ups >= 0 then pg_ups := !pg_ups + 8
    | Sdlkey.KEY_PAGEDOWN -> if !pg_ups > 0 then begin
        pg_ups := !pg_ups - 8;
        if !pg_ups < 0 then pg_ups := 0
    end
    | _ -> Input_edit.handle edit_box event
  in
  match event with
  | Sdlevent.KEYDOWN key -> handle_keydown key.Sdlevent.keysym
  | _ -> Input_edit.handle edit_box event
;;

let console_mode = Input.add_mode ~super:true "console" console_event_handle;;

let rec skip lst = function 
  | 0 -> lst
  | n -> skip (List.tl lst) (n - 1)
;;

let w, h = ref 800, ref 400;;

let real_draw (f1, f2, f3) =
  let str = Input_edit.get edit_box in
  let fnt_h = Font.height f1 in
  let screen = Sdlvideo.get_video_surface () in
  let black = Sdlvideo.map_RGB screen (0, 0, 0) in
  let yellow = (255, 127, 255) in
  let green = Sdlvideo.map_RGB screen (0, 127, 0) in
  let red = Sdlvideo.map_RGB screen (127, 0, 0) in
  let rec line_drawer y (prefix, str) =
    if y < 0 then raise Exit else ();
    let font = 
      match prefix with
      | "Error" -> f3
      | "Debug" -> f2
      | _ -> f1
    in
    let lst = Font.divide_string font str (!w - 2) in
    let folder y line =
(*      let line_len = Font.width font line in
      let rect = Sdlvideo.rect 2 y line_len fnt_h in
      Sdlvideo.fill_rect ~rect surface color;*)
      Font.draw_string (*~on:!console_context*) font 2 y line;
      y - fnt_h
    in
    List.fold_left folder y lst
  in
  let rec log_drawer y = function
    | [] -> ()
    | h :: t -> log_drawer (line_drawer y h) t
  in
  let cursor = Input_edit.get_pos edit_box in
  let y = ((!h - 8) / fnt_h) * fnt_h + 8 in
  let rect = Sdlvideo.rect 0 (y - 2) !w 2 in
  Video.fill ~rect yellow;
  let rect = Sdlvideo.rect 0 0 2 y in
  Video.fill ~rect yellow;
  let rect = Sdlvideo.rect (!w - 2) 0 2 y in
  Video.fill ~rect yellow;
  let y = y - fnt_h - 4 in
  Font.draw_string (*~on:!console_context*) f1 0 y ~cursor (">" ^ str);
  let rect = Sdlvideo.rect 0 (y - 2) !w 2 in
  Video.fill ~rect yellow;
  let rect = Sdlvideo.rect 0 0 !w 2 in
  Video.fill ~rect yellow;
  let log = 
    skip (Log.get ()) (if !pg_ups < 0 then 0 else !pg_ups) in
  log_drawer (y - fnt_h - 2) log
;;

let draw () =
  if Input.get_real_mode () == console_mode then begin
    let rec draw_aux () =
      match !font with
      | Some font -> 
          begin try real_draw font
          with 
          | Exit -> if !pg_ups < 0 then pg_ups := 0;
          | Failure "tl" -> decr pg_ups; draw_aux ()
          end
      | _ -> ()
    in 
    let cam_pos = Video.get_cam_pos () in
    Video.set_cam_pos (0, 0);
    shade (0, 0) (800, 400);
    draw_aux ();
    Video.set_cam_pos cam_pos
  end else ()
;;

Input.set_mode console_mode;;

let resize nx ny = 
  let ny = 
    match !font with
    | None -> (ny * 2) / 3
    | Some (f1, f2, f3) -> let fnt_h = Font.height f1 in
      (((ny * 2) / 3 - 8) / fnt_h) * fnt_h + 8 
  in
  w := nx; h := ny;
(*  let surface = Video.create_surface ~alpha:true (400, 400) in
  console_surface := Sdlvideo.display_format (Video.color_surface surface (fun _ -> ((0, 0, 0), 128)));

  let con_surf = Video.create_surface (x, y) in
  Sdlvideo.set_alpha con_surf 192;
  let con_surf = Sdlvideo.display_format con_surf in
  console_surface := con_surf2;
  console_context := Video.create_context 0 0 x y (0, 0)*)
;;  
    
let chg name =
  try font := Some (
      let f1 = Font.load name in
      let color (((r, g, b), a) as c) = 
        if r = g then ((r/4, r, r/4), a) else c in
      let f2 = Font.load ~color name in
      let color (((r, g, b), a) as c) = 
        if r = g then ((r, r/4, r/4), a) else c in
      let f3 = Font.load ~color name in
      (f1, f2, f3)
   )
  with
  | Font.Error s -> Log.error ("Unable to load given console font: " ^ s)
in let praser =
  Parser.callback chg Parser.string
in Parser.add_variable "console_font" praser "none";;

resize 800 600;;
