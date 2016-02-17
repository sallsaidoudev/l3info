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

let log = Parser.create_log "debug_video" "[Video] " true;;

let mode = ref 0;;

let try_set_driver name =
  if Sdl.was_init () <> [] then Sdl.quit ();
  let store =  
    try Sdl.getenv "SDL_VIDEODRIVER" 
    with Not_found -> ""
  in
  Sdl.putenv "SDL_VIDEODRIVER" name;
  try Sdl.init [`VIDEO; `TIMER];
    Sdl.putenv "SDL_VIDEODRIVER" store;
    log ("Sdl "^(Sdl.string_of_version (Sdl.version ()))^
         " driver " ^ name ^ " initialized ok.");
    incr mode;
  with x -> Sdl.putenv "SDL_VIDEODRIVER" store; raise x
;;

try Sdl.init [`VIDEO; `TIMER]; with 
Sdl.SDL_init_exception s -> Log.error ("Sdl dummy driver not available: " ^ s);;

Parser.add_command "video_set_driver" Parser.string "sets video driver" 
(fun s -> try try_set_driver s with Sdl.SDL_init_exception s -> 
  Log.error ("Unable to initialize sdl: " ^ s))
;;

let quit () = Sdl.quit ();;

(* Initial resolution, in dummy mode *)
let w, h, bpp, fs = ref 800, ref 600, ref 16, ref false;;

type t = {
  mutable surf : Sdlvideo.surface;
  mutable last_mode : int;
  mutable provide : (unit -> Sdlvideo.surface);
  mutable cam_pos : int * int;
  mutable rect : Sdlvideo.rect;
  mutable vmem : bool;
};;

let describe_video () =
  let info = Sdlvideo.get_video_info () in
  log (Printf.sprintf "Driver: %s Hardware: %b HWBlit: %b HWBlitCK: %b WHBlitAlpha: %b HWFill: %b Mem: %i"
    (Sdlvideo.driver_name ()) 
    info.Sdlvideo.hw_available info.Sdlvideo.blit_hw info.Sdlvideo.blit_hw_color_key
    info.Sdlvideo.blit_hw_alpha info.Sdlvideo.blit_fill info.Sdlvideo.video_mem)
;;

let screen = {
  surf = Sdlvideo.set_video_mode ~bpp:!bpp ~w:!w ~h:!h [`DOUBLEBUF; `HWSURFACE];
  last_mode = 0;
  provide = (fun () -> 
    let flags = 
      if !fs then [`DOUBLEBUF; `HWSURFACE; `FULLSCREEN] else [`DOUBLEBUF; `HWSURFACE]
    in
    let ret = Sdlvideo.set_video_mode ~bpp:!bpp ~w:!w ~h:!h flags in
    log (Printf.sprintf "Mode changed to %ix%i@%i fullscreen: %b" !w !h !bpp !fs);
    describe_video ();
    ret
  );
  cam_pos = (0, 0);
  rect = Sdlvideo.rect 0 0 !w !h;
  vmem = true;
};;

describe_video ();;

let flip () = (*log "flip";*) Sdlvideo.flip screen.surf;;

let provide_image fnctn =
  let surface = fnctn () in
  let (w, h, bpp) = Sdlvideo.surface_dims surface in
  { 
    surf = surface;
    last_mode = !mode;
    provide = fnctn;
    cam_pos = (0, 0);
    rect = Sdlvideo.rect 0 0 w h;
    vmem = false;
  }
;;

let update_image image =
  if image.last_mode < !mode then begin
    image.surf <- image.provide ();
    image.last_mode <- !mode;
    if image.surf = screen.surf then image.rect <- Sdlvideo.rect 0 0 !w !h;
  end
;;

let load_image file_name = 
  let provider () = Sdlloader.load_image file_name in 
  provide_image provider
;;

let optimize ?alpha image =
  update_image screen;
  {image with provide = (fun () -> Sdlvideo.display_format ?alpha (image.provide ()));
   surf = if !mode = image.last_mode then Sdlvideo.display_format ?alpha image.surf else image.surf;
   vmem = true}
;;

let color_key ?(ck=(255,0,255)) image =
  update_image screen;
  if !mode = image.last_mode then Sdlvideo.set_color_key image.surf (Sdlvideo.map_RGB image.surf ck);
  {image with provide = (fun () ->
    let surf = image.provide () in
    let mapped = Sdlvideo.map_RGB surf ck in
    Sdlvideo.set_color_key surf mapped;
    surf);
   last_mode = !mode - 1;
  }
;;

let image_of_surface surface = 
  let (w, h, bpp) = Sdlvideo.surface_dims surface in
  {
    surf = surface;
    last_mode = !mode;
    provide = (fun () -> failwith "Video.image_of_surface provider called");
    cam_pos = (0, 0);
    rect = Sdlvideo.rect 0 0 w h;
    vmem = false;
  }
;;

let blit image ?src_rect ?on ?surf x y =
  (*log (Printf.sprintf "blit: %i %i" x y);*)
  update_image screen;
  update_image image;
  let blitter dest =
    update_image dest;
    let dst_x = x + dest.rect.Sdlvideo.r_x - (fst dest.cam_pos)
    and dst_y = y + dest.rect.Sdlvideo.r_y - (snd dest.cam_pos) in
    let dst_rect = Sdlvideo.rect dst_x dst_y 0 0 in
    Sdlvideo.set_clip_rect dest.surf dest.rect;
    Sdlvideo.blit_surface ~src:image.surf ?src_rect ~dst:dest.surf ~dst_rect ();
    Sdlvideo.unset_clip_rect dest.surf;
  in match on, surf with
  | None, None -> blitter screen
  | Some on, None -> blitter on
  | None, Some surf -> blitter (image_of_surface surf)
  | _ -> failwith "Video.blit called with both ~on and ~surf"
;;

let fill ?on ?surf ?rect ?alpha color =
  update_image screen;
  let filler dest =
    update_image dest;
    Sdlvideo.set_clip_rect dest.surf dest.rect;
    match rect with
    | None ->
        Sdlvideo.fill_rect dest.surf (Sdlvideo.map_RGB dest.surf ?alpha color);
        Sdlvideo.unset_clip_rect dest.surf
    | Some rect ->
        let dst_x = rect.Sdlvideo.r_x + dest.rect.Sdlvideo.r_x - (fst dest.cam_pos)
        and dst_y = rect.Sdlvideo.r_y + dest.rect.Sdlvideo.r_y - (snd dest.cam_pos) in
        let rect = {rect with Sdlvideo.r_x = dst_x; Sdlvideo.r_y = dst_y} in
        Sdlvideo.fill_rect dest.surf ~rect (Sdlvideo.map_RGB dest.surf ?alpha color);
        Sdlvideo.unset_clip_rect dest.surf
  in match on, surf with
  | None, None -> filler screen
  | Some on, None -> filler on
  | None, Some surf -> filler (image_of_surface surf)
  | _ -> failwith "Video.blit called with both ~on and ~surf"
;;

let get_cam_pos ?(on=screen) () = on.cam_pos;;

let set_cam_pos ?(on=screen) cam_pos = on.cam_pos <- cam_pos;;

let set_cam_pos_center ?(on=screen) cam_pos =
  let cnt_w, cnt_h = (on.rect.Sdlvideo.r_w, on.rect.Sdlvideo.r_h) in
  let (x, y) = cam_pos in
  set_cam_pos ~on (x - (cnt_w / 2), y - (cnt_h / 2))
;;

let move_cam ?(on=screen) (dx, dy) =
  let (x, y) = on.cam_pos in
  set_cam_pos ~on (x + dx, y + dy)
;;

let set_mode nfs (nw, nh) nbpp =
  fs := nfs; w := nw; h := nh; bpp := nbpp; incr mode;
;;


let quit () = Sdl.quit ();;
  
let get_resolution () = update_image screen; !w, !h;;
let get_depth () = update_image screen; !bpp;;

let image_size image =
  update_image screen; 
  update_image image;
  let w, h, _ = Sdlvideo.surface_dims image.surf in
  w, h
;;

let describe_surface surf =
  update_image screen;
  let surf_flags = Sdlvideo.surface_flags surf in
  let (w, h, p) = Sdlvideo.surface_dims surf in
  let bpp = Sdlvideo.surface_bpp surf in
  let alpha = 
    if List.mem `SRCALPHA surf_flags 
    then " Alpha: " ^ (string_of_int (Sdlvideo.get_alpha surf)) else ""
  and color_key = 
    if List.mem `SRCCOLORKEY surf_flags 
    then " ColorKey: " ^ 
      (string_of_int (Int32.to_int (Sdlvideo.get_color_key surf))) else ""
  and flags = List.length (Sdlvideo.surface_flags surf)
  and hwa = if List.mem `HWACCEL surf_flags then " HWA" else "" 
  and rle = if List.mem `RLEACCEL surf_flags then " RLE" else "" 
  and pre = if List.mem `PREALLOC surf_flags then " PRE" else ""
  and asy = if List.mem `ASYNCBLIT surf_flags then " ASY" else ""
  and sws = if List.mem `SWSURFACE surf_flags then " SWS" else ""
  and hws = if List.mem `HWSURFACE surf_flags then " HWS" else "" in
  Printf.sprintf "[%ix%i@%i(%i)%s%s%s%s%s%s%s%s Flags:%i]" 
    w h bpp p alpha color_key hwa rle pre sws hws asy flags
;;

(* TODO bigendian *)

let create_surface ?(alpha=false) (w, h) =
  update_image screen;
  if alpha then
    Sdlvideo.create_RGB_surface [`SWSURFACE; `SRCALPHA]
      ~w ~h ~bpp:32
      ~rmask:(Int32.of_int 0xFF)
      ~gmask:(Int32.shift_left (Int32.of_int 0xFF) 8)
      ~bmask:(Int32.shift_left (Int32.of_int 0xFF) 16)
      ~amask:(Int32.shift_left (Int32.of_int 0xFF) 24)
  else
    Sdlvideo.create_RGB_surface [`SWSURFACE; `SRCCOLORKEY]
      ~w ~h ~bpp:16
      ~rmask:Int32.zero ~gmask:Int32.zero ~bmask:Int32.zero ~amask:Int32.zero
;;

let duplicate_surface src =
  update_image screen;
  let bpp = Sdlvideo.surface_bpp src in
  let src_flags = Sdlvideo.surface_flags src in
  let alpha = 
    if List.mem `SRCALPHA src_flags then Some (Sdlvideo.get_alpha src)
    else None
  and color_key = 
    if List.mem `SRCCOLORKEY src_flags then Some (Sdlvideo.get_color_key src)
    else None
  in
  let flags = [`SWSURFACE] in
  let (w, h, p) = Sdlvideo.surface_dims src in
  let dst = Sdlvideo.create_RGB_surface_format src flags w h in
  begin match color_key with
  | Some ck -> Sdlvideo.set_color_key dst ck; Sdlvideo.unset_color_key src
  | None -> ()
  end;
  begin match alpha with
  | Some alph -> Sdlvideo.set_alpha dst alph; Sdlvideo.unset_alpha src
  | None -> ()
  end;
  Sdlvideo.blit_surface ~src ~dst ();
  begin match color_key with
  | Some ck -> Sdlvideo.set_color_key src ck
  | None -> ()
  end;
  begin match alpha with
  | Some alph -> Sdlvideo.set_alpha src alph
  | None -> ()
  end;
  dst
;;

let line ?on ?surf (x1, y1) (x2, y2) ?alpha color =
  update_image screen;
  let liner dest =
    let color = Sdlvideo.map_RGB dest.surf ?alpha color in
    let (cx, cy) = dest.cam_pos in
    if dest.vmem = false then begin
      update_image dest;
      Sdlvideo.lock dest.surf;
      begin
        let pixel x y =
          if x - cx >= 0 && x - cx < dest.rect.Sdlvideo.r_w && 
            y - cy >= 0 && y - cy < dest.rect.Sdlvideo.r_h 
          then 
            let x = x - cx + dest.rect.Sdlvideo.r_x 
            and y = y - cy + dest.rect.Sdlvideo.r_y in
            Sdlvideo.put_pixel dest.surf ~x ~y color
        in
        let rec draw x1 y1 x2 y2 =
          if x1 = x2 && y1 = y2 then pixel x1 y1 else
          let dpc a1 a2 =
            let da = (a1 + a2) / 2 in
            let da = if (a1 + a2) < 0 && (a1 + a2) mod 2 <>0 then da - 1 else da in
            if da < a2 then da, da + 1
            else if da < a1 then da + 1, da
            else da, da
          in
          let nx1, nx2 = dpc x1 x2
          and ny1, ny2 = dpc y1 y2 in
          draw x1 y1 nx1 ny1;
          draw nx2 ny2 x2 y2
        in
        draw x1 y1 x2 y2;
        Sdlvideo.unlock dest.surf;
      end 
    end else begin
      if x1 = x2 then begin 
        Sdlvideo.set_clip_rect dest.surf dest.rect;
        let rect = Sdlvideo.rect (x1 - cx + dest.rect.Sdlvideo.r_x) 
            ((min y1 y2) - cy + dest.rect.Sdlvideo.r_y) 1 (1 + abs (y1 - y2))
        in Sdlvideo.fill_rect ~rect dest.surf color;
        Sdlvideo.unset_clip_rect dest.surf
      end else if y1 = y2 then begin
        Sdlvideo.set_clip_rect dest.surf dest.rect;
        let rect = Sdlvideo.rect ((min x1 x2) - cx + dest.rect.Sdlvideo.r_x) 
            (y1 - cy + dest.rect.Sdlvideo.r_y) (1 + abs (x1 - x2)) 1
        in Sdlvideo.fill_rect ~rect dest.surf color;
        Sdlvideo.unset_clip_rect dest.surf
      end else begin
        let pixel x y =
          if x - cx >= 0 && x - cx < dest.rect.Sdlvideo.r_w && 
            y - cy >= 0 && y - cy < dest.rect.Sdlvideo.r_h 
          then 
            let x = x - cx + dest.rect.Sdlvideo.r_x 
            and y = y - cy + dest.rect.Sdlvideo.r_y in
            let rect = Sdlvideo.rect x y 1 1 in
            Sdlvideo.fill_rect ~rect dest.surf color
        in
        let rec draw x1 y1 x2 y2 =
          if x1 = x2 && y1 = y2 then pixel x1 y1 else
          let dpc a1 a2 =
            let da = (a1 + a2) / 2 in
            let da = if (a1 + a2) < 0 && (a1 + a2) mod 2 <>0 then da - 1 else da in
            if da < a2 then da, da + 1
            else if da < a1 then da + 1, da
            else da, da
          in
          let nx1, nx2 = dpc x1 x2
          and ny1, ny2 = dpc y1 y2 in
          draw x1 y1 nx1 ny1;
          draw nx2 ny2 x2 y2
        in
        draw x1 y1 x2 y2;
      end
    end
  in match on, surf with
  | None, None -> liner screen
  | Some on, None -> liner on
  | None, Some surf -> liner (image_of_surface surf)
  | _ -> failwith "Video.blit called with both ~on and ~surf"
;;

let point ?on (x, y) ?alpha color =
  line ?on (x, y) (x, y) ?alpha color
;;


let ellipse ?on (x, y) (rx, ry) fill ?alpha color =
  if (rx <= 0 || ry <= 0) then raise (Invalid_argument "Gs.Video.ellipse") else
  let scale = (float_of_int ry) /. (float_of_int rx) in
  let rec draw_vert ax =
    if ax = rx then () else
    let ay = int_of_float (sqrt (float_of_int (rx * rx - ax * ax)) *. scale) in
    if fill then
      line ?on ((x + ax), (y - ay)) ((x + ax), (y + ay)) ?alpha color
    else begin
      point ?on ((x + ax), (y - ay)) ?alpha color;
      point ?on ((x + ax), (y + ay)) ?alpha color
    end;
    draw_vert (ax + 1)
  in
  draw_vert (1 - rx);
;;


let color_surface surf fnctn =
  update_image screen;
  let csurf = duplicate_surface surf in
  let (w,h,p) = Sdlvideo.surface_dims surf in
  Sdlvideo.lock csurf;
  Sdlvideo.lock surf;
  for y = 0 to (h - 1) do
    for x = 0 to (w - 1) do
      let (rgb, a) = Sdlvideo.get_RGBA surf (Sdlvideo.get_pixel surf ~x ~y) in
      let (rgb, a) = fnctn (rgb, a) in
      let col = Sdlvideo.map_RGB csurf ~alpha:a rgb in
      Sdlvideo.put_pixel csurf ~x ~y col
    done
  done;
  Sdlvideo.unlock csurf;
  Sdlvideo.unlock surf;
  csurf
;;

let color_image image fnctn = {
  image with provide = (fun () -> color_surface (image.provide ()) fnctn);
  surf = if !mode = image.last_mode then color_surface image.surf fnctn else image.surf;
}

let create_context x y w h (cx, cy) = {
  screen with rect = Sdlvideo.rect x y w h; 
  cam_pos = (cx, cy); 
  provide = (fun () -> if screen.last_mode = !mode then screen.surf else
                       (screen.last_mode <- !mode; screen.provide ()))
};;

let screenshot file_opt = 
  update_image screen;
  match file_opt with
  | Some name -> Sdlvideo.save_BMP screen.surf name
  | None -> Sdlvideo.save_BMP screen.surf "screenshot.bmp" in
Parser.add_command "screenshot" (Parser.option Parser.string) "Save screenshot" screenshot;;

let update_image image = update_image screen; update_image image;;




(* TODO check all dims *)
let tile_fill ?on ?surf tile (x, y) (w, h) =
  let tw, th = image_size tile in
  for xx = 0 to (w / tw) do
    for yy = 0 to (h / th) do
      let bx, by = (x + (xx*tw)), (y + (yy*th)) in
      let w, h = min (w - (xx*tw)) tw, min (h - (yy*th)) th in
      let src_rect = Sdlvideo.rect 0 0 w h in
      blit tile ?on ?surf ~src_rect (x + (xx*tw)) (y + (yy*th))
    done
  done;
;;

let shade_tile =
  let provide () =
    let surface = create_surface ~alpha:true (40, 40) in
    Sdlvideo.display_format ~alpha:true (color_surface surface (fun _ -> ((0, 0, 0), 128)))
  in provide_image provide
;;
let shade ?on ?surf (x, y) (w, h) = tile_fill ?on ?surf shade_tile (x, y) (w, h);;
