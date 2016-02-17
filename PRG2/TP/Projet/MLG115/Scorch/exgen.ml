let move (x, y) (vx, vy) = ((x +. vx), (y +. vy));;

let slow v (x, y) = (x *. v, y *. v);;
let rot ang (x, y) =
  ( (x *. (cos ang)) -. (y *. (sin ang)), (x *. (sin ang)) +. (y *. (cos ang)) )
;;

let to_red (r, g, b ,a) = (r *. 0.92, g *. 0.80, b *. 0.75, a *. 0.90);;

let to_red_fast (r, g, b ,a) = (r *. 0.89, g *. 0.64, b *. 0.52, a *. 0.81);;

let to_blue (r, g, b ,a) = (r *. 0.75, g *. 0.80, b *. 0.92, a *. 0.90);;

let to_blue_mag (r, g, b ,a) = (r *. 0.80, g *. 0.75, b *. 0.92, a *. 0.90);;

let fade (r, g, b ,a) = (r *. 0.90, g *. 0.90, b *. 0.90, a *. 0.90);;

let frame_fun vel_fun col_fun (pos, vel, col, (size:float), frame) =
  (move pos vel, vel_fun vel, col_fun col, size, frame + 1)
;;
  
let hred = (256. , 0. , 0. , 128.);;
let hwhite = (256. , 256. , 256. , 128.);;

let part_gen_ring r1 r2 size color frame_fun (x0, y0) = 
  let vel r1 r2 =
    let ang = Random.float 6.28 in
    let v = (Random.float r2) +. r1 in
    ( (sin ang) *. v, (cos ang) *. v )
  in
  (((float_of_int x0, float_of_int y0), (vel r1 r2), color , size, 0),frame_fun ) 
;;

let part_gen_cross r1 r2 size color frame_fun (x0, y0) = 
  let vel r1 r2 =
    let ang = Random.float 6.28 in
    let v = (Random.float r1) +. r2 in
    ( ((sin ang) *. v)**3., ((cos ang) *. v)**3. )
  in
  (((float_of_int x0, float_of_int y0), (vel r1 r2), color , size, 0),frame_fun ) 
;;

let part_gen_gd r1 size color frame_fun (x0, y0) = 
  let vel r1 =
    let x0,y0 = ((sin 0.) *. r1),((cos 0.) *. r1) in
    let x1,y1 = ((sin 1.05) *. r1),((cos 1.05) *. r1) in
    let x2,y2 = ((sin 2.09) *. r1),((cos 2.09) *. r1) in
    let x3,y3 = ((sin 3.14) *. r1),((cos 3.14) *. r1) in
    let x4,y4 = ((sin 4.19) *. r1),((cos 4.19) *. r1) in
    let x5,y5 = ((sin 5.23) *. r1),((cos 5.23) *. r1) in
    let rnd1, rnd2 = Random.float 1., Random.float 1. in 
    let n = (Random.int 6) in
    if n = 0 then 
      (rnd1 *. x0) +. ((1. -. rnd1) *. x2),(rnd1 *. y0) +. ((1. -. rnd1) *. y2)
    else if n = 1 then
      (rnd1 *. x1) +. ((1. -. rnd1) *. x3),(rnd1 *. y1) +. ((1. -. rnd1) *. y3)
    else if n = 2 then
      (rnd1 *. x2) +. ((1. -. rnd1) *. x4),(rnd1 *. y2) +. ((1. -. rnd1) *. y4)
    else if n = 3 then
      (rnd1 *. x3) +. ((1. -. rnd1) *. x5),(rnd1 *. y3) +. ((1. -. rnd1) *. y5)
    else if n = 4 then
      (rnd1 *. x4) +. ((1. -. rnd1) *. x0),(rnd1 *. y4) +. ((1. -. rnd1) *. y0)
    else if n = 5 then
      (rnd1 *. x5) +. ((1. -. rnd1) *. x1),(rnd1 *. y5) +. ((1. -. rnd1) *. y1)
    else (10.,10.)
  in
  (((float_of_int x0, float_of_int y0), (vel r1), color , size, 0),frame_fun ) 
;;

let rec make_parts new_part_fun lst num max center =
  if (num < max) then 
    make_parts new_part_fun ((new_part_fun center):: lst) (num+1) max center
  else
    lst
;;

let rec cur fn i max spd dst =
  let sp (f1,s1) (f2,s2) = (f1 +. f2, s1 +. s2) in
  if i = max then dst
  else cur fn (i+1) max (fn spd) (sp spd dst)
;;

let ring r1 r2 size count frames col speed_fun col_fun =
  let max = (fst (cur speed_fun 0 frames ((r1 +. r2), 0.) (0.,0.) )) +. size in
  let dims = ((int_of_float (2. *. max))+2, (int_of_float (2. *. max))+2) in
  ((make_parts ( part_gen_ring r1 r2 size col (frame_fun speed_fun col_fun))
  [] 0 count), dims, frames)
;;

let cross r1 r2 size count frames col speed_fun col_fun =
  let max = (fst (cur speed_fun 0 frames ((r1 +. r2) ** 3., 0.) (0.,0.) )) +. size in
  let dims = ((int_of_float (2. *. max))+2, (int_of_float (2. *. max))+2) in
  ((make_parts ( part_gen_cross r1 r2 size col (frame_fun speed_fun col_fun))
  [] 0 count), dims, frames)
;;

let dstar r1 size count frames col speed_fun col_fun =
  let max = (fst (cur speed_fun 0 frames (r1, 0.) (0.,0.) )) +. size in
  let dims = ((int_of_float (2. *. max))+2, (int_of_float (2. *. max))+2) in
  ((make_parts ( part_gen_gd r1 size col (frame_fun speed_fun col_fun))
  [] 0 count), dims, frames)
;;

let fball4 = ring 8. 10. 5. 500 25 hwhite (slow 0.6) to_blue_mag;;

let fball1 = ring 0. 10. 5. 300 25 hwhite (slow 0.6) to_red;;
let fball2 = ring 0. 20. 6. 1000 25 hwhite (slow 0.6) to_red;;
let fball3 = ring 0. 30. 7. 1500 25 hwhite (slow 0.6) to_red;;

let cross1 = cross 1. 1. 7. 500 25 hwhite (slow 0.9) to_blue;;
let gd1 = dstar 20. 4. 1000 25 hwhite (slow 0.7) to_blue;;

let make_explosion (parts, (w, h), i) () =
  let surface = Video.create_surface ~alpha:true ((w*i), h) in
  let data = Sdlvideo.pixel_data_32 surface in 
  let blit matrix frame =
    Sdlvideo.lock surface;
    for x = 0 to (w-1) do
      for y = 0 to (h-1) do
        match matrix.(x + y * w) with
        (r, g, b, a) ->
          Bigarray.Array1.set
          data (y*i*w + frame*w + x)
            (Sdlvideo.map_RGB surface ~alpha:a (r, g, b))
      done
    done;
    Sdlvideo.unlock surface;
  in
  let matrix = Array.create (w * h) (0,0,0,0) in
  let putpix x y r g b a = 
    let add v1 v2 =
      let vl = v1 + v2 in
      if vl > 255 then 255 else vl
    in
(*    let add v1 v2 = min 255 (v1 + v2) in*)
    if (x >= 0) && (x < w) && (y >= 0) && (y < h) then
      let (mr, mg, mb, ma) = matrix.(x + y * w) in
      matrix.(x + y * w) <- (add mr r, add mg g, add mb b, add ma a)
  in
  let map_fun (part,gfun) = 
    let draw_part ((x, y), vel, (r,g,b,a), s, ttl) =
      let (x, y, r, g, b, a, s ) =
        ((int_of_float x), (int_of_float y), 
         (int_of_float r), (int_of_float g),
         (int_of_float b), (int_of_float a), (int_of_float s))
      in 
      let float_s = float_of_int s in
      for i=(-s) to s do
        for j=(-s) to s do
          let dst = (sqrt (float_of_int ((i * i) + (j * j)))) /. float_s in
          let dst_quot = if 1. -. dst < 0. then 0. else 1. -. dst in
          let by_dst vl =
            int_of_float ((float_of_int vl) *. dst_quot)
          in
          putpix (x+i) (y+j) (by_dst r) (by_dst g) (by_dst b) (by_dst a)
        done
      done
    in
    draw_part part;
    (gfun part, gfun)
  in
  let rec next_gen parts num max =
    Log.debug ("Generating frame "^(string_of_int num));
    Array.fill matrix 0 (w * h) (0, 0, 0, 0);
    let moved = List.map map_fun parts in
    let new_parts = List.filter (fun ((_,_,_,_,ttl) ,_)-> ttl >= 0) moved in
    blit matrix num;
    if (num < (max-1)) then next_gen new_parts (num +1) max
    else ()
  in
  Random.init 0;
  next_gen (parts (w/2, h/2)) 0 i;
  (*Sdlvideo.display_format ~alpha:true surface*)
  surface
;;

exception Force_regen;;

let get ?(force=false) (parts, (w, h), frames) filename =
  try
    if force then raise Force_regen;
    let inc = open_in_bin filename in
    let data = input_value inc in
    close_in inc;
    let ret =
      Sdlvideo.create_RGB_surface_from_32 data ~w:(w * frames) ~h 
        ~pitch:(w * frames * 4)
        ~rmask:(Int32.of_int 0xFF)
        ~gmask:(Int32.shift_left (Int32.of_int 0xFF) 8)
        ~bmask:(Int32.shift_left (Int32.of_int 0xFF) 16)
        ~amask:(Int32.shift_left (Int32.of_int 0xFF) 24)
    in ret
  with
  | Sys_error _ | Force_regen ->
      Log.info ("Generating: " ^ filename ^ " it may take a few minutes.");
      let ret = make_explosion (parts, (w, h), frames) () in
      let outc = open_out_bin filename in
      output_value outc (Sdlvideo.pixel_data_32 ret);
      close_out outc;
      ret
;;
