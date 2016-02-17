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

type 'a t = {
  mutable x : int;
  mutable y : int;
  mutable w : int;
  mutable h : int;
  mutable sets : 'a set list;
  mutable frames : Video.t;
  mutable frame_count : int;
  mutable frame_num : int;
  mutable data : 'a;
  id : int;
}
and 'a set = {
  mutable boundary : (int * int * int * int) option;
  mutable set_size : int;
  mutable sprites : ('a t list) array;
  mutable buckets : 'a bucket option;
}
and 'a bucket = {
  mutable bucket_size : (int * int);
  mutable size : int;
  mutable contents : ('a t list) array;
  mutable collision_funs : ('a t -> unit) list;
}
and ('a, 'b) table = (('a, 'b t) Hashtbl.t) * ('b set);;

let rec filter_duplicates_nofun acc = function
  | s1 :: s2 :: t ->
      if s1 = s2
      then filter_duplicates_nofun acc (s2 :: t)
      else filter_duplicates_nofun (s1 :: acc) (s2 :: t)
  | [s1] -> s1 :: acc
  | [] -> acc
;;

let rec filter_duplicates_fun acc = function
  | s1 :: s2 :: t ->
      if s1 == s2
      then filter_duplicates_fun acc (s2 :: t)
      else filter_duplicates_fun (s1 :: acc) (s2 :: t)
  | [s1] -> s1 :: acc
  | [] -> acc
;;

let size_y = 12345;;

module Set = struct

  let create initial_size =
    let size = min initial_size Sys.max_array_length in
    { boundary = None;
      set_size = 0; 
      sprites = Array.make size [];
      buckets = None;
    }

  let rehash set =
    let odata = set.sprites in
    let osize = Array.length odata in
    let nsize = min (2 * osize + 1) Sys.max_array_length in
    if nsize = osize then () else
    let ndata = Array.create nsize [] in
    let insert s =
      let id_mod = s.id mod nsize in
      ndata.(id_mod) <- (s :: ndata.(id_mod))
    in
    for i = 0 to osize - 1 do
      List.iter insert odata.(i)
    done;
    set.sprites <- ndata

  let set_boundary set minx miny maxx maxy =
    set.boundary <- Some (minx, miny, maxx, maxy)

  let buckets_concerning buckets spr =
    let bucket_w, bucket_h = buckets.bucket_size in
    let min_x = spr.x / bucket_w in
    let max_x = (spr.x + spr.w ) / bucket_w in
    let min_y = spr.y / bucket_h in
    let max_y = (spr.y + spr.h) / bucket_h in
    let buks = ref [] in
    let size = Array.length buckets.contents in
    for bx = min_x to max_x do
      for by = min_y to max_y do
        let moded = (bx + by * size_y) mod size in
        buks := ((moded + size) mod size) :: !buks;
      done
    done;
    filter_duplicates_nofun [] (List.sort compare !buks)

  let buckets_rehash buckets =
    let all = List.concat (Array.to_list buckets.contents) in
    let sorted = List.sort (fun s1 s2 -> s1.id - s2.id) all in
    let odata = filter_duplicates_fun [] sorted in
    let osize = Array.length (buckets.contents) in
    let nsize = min (2 * osize + 1) Sys.max_array_length in
    if nsize = osize then () else
    let ndata = Array.create nsize [] in
    let insert s =
      let bucket_w, bucket_h = buckets.bucket_size in
      let min_x = s.x / bucket_w in
      let max_x = (s.x + s.w ) / bucket_w in
      let min_y = s.y / bucket_h in
      let max_y = (s.y + s.h) / bucket_h in
      for bx = min_x to max_x do
        for by = min_y to max_y do
          let moded = (bx + by * size_y) mod nsize in
          let moded = ((moded + nsize) mod nsize) in
          ndata.(moded) <- (s :: ndata.(moded))
        done
      done;
    in
    List.iter insert odata;
    buckets.contents <- ndata

  let buckets_add spr buckets = 
    let buks = buckets_concerning buckets spr in
    let iterator buk_mod =
      let bucket = buckets.contents.(buk_mod) in
      buckets.contents.(buk_mod) <- (spr :: bucket);
      buckets.size <- buckets.size + 1
    in List.iter iterator buks;
    if buckets.size > Array.length buckets.contents lsl 1 then 
      buckets_rehash buckets

  let buckets_del spr buckets =
    let buks = buckets_concerning buckets spr  in
    let iterator buk_mod =
      let bucket = buckets.contents.(buk_mod) in
      let filter sprite = sprite.id <> spr.id in
      buckets.contents.(buk_mod) <- (List.filter filter bucket);
      buckets.size <- buckets.size - 1
    in List.iter iterator buks

  let add set spr =
    let id_mod = spr.id mod (Array.length set.sprites) in
    let bucket = set.sprites.(id_mod) in
    set.sprites.(id_mod) <- (spr :: bucket);
    set.set_size <- set.set_size + 1;
    if set.set_size > Array.length set.sprites lsl 1 then rehash set;
    spr.sets <- set :: spr.sets;
    match set.buckets with
    | None -> ()
    | Some buckets -> buckets_add spr buckets

  let del set sprite =
    let id_mod = sprite.id mod (Array.length set.sprites) in
    let bucket = set.sprites.(id_mod) in
    let filter spr = spr.id <> sprite.id in
    set.sprites.(id_mod) <- (List.filter filter bucket);
    set.set_size <- set.set_size - 1;
    let filter aset = not (aset == set) in
    let nsets = List.filter filter sprite.sets in
    sprite.sets <- nsets;
    match set.buckets with
    | None -> ()
    | Some buckets -> buckets_del sprite buckets

  let iter fnctn set =
    let sprits = List.flatten (Array.to_list set.sprites) in
    List.iter fnctn sprits

  let iter_data fnctn set =
    let fnctn sprite = fnctn sprite sprite.data in
    Array.iter (List.iter fnctn) set.sprites

  let set_collision set bucket_w bucket_h =
    assert (bucket_w > 0 && bucket_h > 0);
    let buckets = { 
      bucket_size = (bucket_w, bucket_h);
      size = 0;
      contents = Array.create (Array.length set.sprites) [];
      collision_funs = [];
    } in
    set.buckets <- Some buckets;
    iter (fun spr -> buckets_add spr buckets) set

  let clear set =
    iter (del set) set

  let mem set sprite =
    List.exists (fun spr -> spr.id = sprite.id)
      set.sprites.(sprite.id mod (Array.length set.sprites))

  let fold fnctn set init =
    Array.fold_left (List.fold_left fnctn) init set.sprites

  let fold_data fnctn set init =
    let fnctn old sprite = fnctn old sprite sprite.data in
    Array.fold_left (List.fold_left fnctn) init set.sprites

end;;




external pixel_chk : Sdlvideo.surface -> Sdlvideo.surface -> (int * int * int * int) -> (int * int * int * int) -> int -> bool = "ml_collision";;

(*
let pixel_chk spr1frames spr2frames (minx, maxx, spr1x, spr2x)
    (miny, maxy, spr1y, spr2y) alpha_bias =
  Sdlvideo.lock spr1frames;
  Sdlvideo.lock spr2frames;
  let pink1 = Sdlvideo.get_RGB spr1frames
      (Sdlvideo.map_RGB spr1frames (255, 0, 255))
  and pink2 = Sdlvideo.get_RGB spr2frames
      (Sdlvideo.map_RGB spr2frames (255, 0, 255)) in
  try
    for x = minx to maxx - 1 do
      for y = miny to maxy - 1 do
        let px1 = x - spr1x
        and py1 = y - spr1y
        and px2 = x - spr2x
        and py2 = y - spr2y in
        if Sdlvideo.get_pixel spr1frames ~x:px1 ~y:py1 <> pink1
        && Sdlvideo.get_pixel spr2frames ~x:px2 ~y:py2 <> pink2
        then (raise Exit) else ()
      done
    done;
    Sdlvideo.unlock spr1frames;
    Sdlvideo.unlock spr2frames;
    false
  with | Exit ->
    Sdlvideo.unlock spr1frames;
    Sdlvideo.unlock spr2frames;
    true
;;
*)

let rect_collision ?(alpha_bias = 256) per_pixel spr1 spr2 =
  if (spr1.x < spr2.x + spr2.w) && (spr1.x + spr1.w > spr2.x) &&
  (spr1.y < spr2.y + spr2.h) && (spr1.y + spr1.h > spr2.y) = false then false
  else if per_pixel then begin
    let minx = max spr1.x spr2.x
    and maxx = min (spr1.x + spr1.w - 1) (spr2.x + spr2.w - 1)
    and miny = max spr1.y spr2.y
    and maxy = min (spr1.y + spr1.h - 1) (spr2.y + spr2.h - 1) in
    let s1x = spr1.x - spr1.w * spr1.frame_num
    and s2x = spr2.x - spr2.w * spr2.frame_num in
    Video.update_image spr1.frames;
    Video.update_image spr2.frames;
    pixel_chk spr1.frames.Video.surf spr2.frames.Video.surf (minx, maxx, s1x, s2x)
      (miny, maxy, spr1.y, spr2.y) alpha_bias
  end else false
;;

let collides_with spr ?alpha_bias per_pixel set =  
  match set.buckets with
  | None -> []
  | Some buckets ->
      let buks = Set.buckets_concerning buckets spr in
      let all = 
        List.concat (List.map (Array.get buckets.contents) buks) in
      let sorted = List.sort (fun s1 s2 -> s1.id - s2.id) all in
      let filtered = filter_duplicates_fun [] sorted in
      let no_self = List.filter (fun s -> s.id <> spr.id) filtered in
      List.filter (rect_collision ?alpha_bias per_pixel spr) no_self
;;



let add_collision_fun set1 set2 ?alpha_bias per_pixel collision_fun =
  let perform_collisions_with_set2 spr =
    let set2_sprites = collides_with spr ?alpha_bias per_pixel set2 in
    List.iter (collision_fun spr) set2_sprites
  in
  match set1.buckets, set2.buckets with
  | Some buckets, Some _ -> buckets.collision_funs <- 
      perform_collisions_with_set2 :: buckets.collision_funs
  | _ -> Log.fatal "Sprite.add_collision_fun called on a non colliding set"
;;


                       (* SPRITY *)
let sprite_counter = ref 0;;

let create ?set data frames ?width (x, y) = 
  let surf_info = Sdlvideo.surface_info frames.Video.surf in
  let real_width = surf_info.Sdlvideo.w in
  let h = surf_info.Sdlvideo.h in
  let w = match width with None -> real_width | Some fw -> fw in
  assert (real_width mod w = 0);
  let spr = {
    x = x; y = y; w = w; h = h; sets = [];
    frames = frames; frame_count = real_width / w;
    frame_num = 0; data = data;
    id = !sprite_counter;
  } in
  incr sprite_counter;
  match set with
  | None -> spr
  | Some set -> Set.add set spr; spr
;;

let check_collisions spr = 
  let check bucket = 
    List.iter (fun cg_fun -> cg_fun spr) bucket.collision_funs 
  in
  let check_set set = 
    match set.buckets with
    | None -> ()
    | Some bucket -> check bucket
  in
  List.iter check_set spr.sets;
;;

let buckets_iter sets fnctn =
  let buck_fun set = match set.buckets with
  | None -> ()
  | Some buckets -> fnctn buckets
  in
  List.iter buck_fun sets
;;

let set_frames sprite ?width frames =
  let old_dims = (sprite.w, sprite.h) in
  let surf_info = Sdlvideo.surface_info frames.Video.surf in
  let real_width = surf_info.Sdlvideo.w in
  sprite.h <- surf_info.Sdlvideo.h;
  sprite.w <- (match width with None -> real_width | Some fw -> fw);
  if real_width mod sprite.w <> 0 then 
    Log.fatal "Sprite.create - wrong surface width";
  if (sprite.w, sprite.h) <> old_dims then 
    buckets_iter sprite.sets (Set.buckets_del sprite);
  sprite.frames <- frames;
  sprite.frame_count <- real_width / sprite.w;
  sprite.frame_num <- 0;
  if (sprite.w, sprite.h) <> old_dims then 
    buckets_iter sprite.sets (Set.buckets_add sprite) else ()
;;

let get_frames sprite = sprite.frames;;

let delete spr =
  let deleter set =
    Set.del set spr;
    match set.buckets with
    | None -> ()
    | Some buckets -> Set.buckets_del spr buckets
  in List.iter deleter spr.sets
;;

let move_to spr (x, y) =
  buckets_iter spr.sets (Set.buckets_del spr);
  spr.x <- x;
  spr.y <- y;
  buckets_iter spr.sets (Set.buckets_add spr)
;;

let move spr (dx, dy) = move_to spr (spr.x + dx, spr.y + dy);;

let get_pos spr = (spr.x, spr.y);;

let set_data spr data = spr.data <- data;;

let get_data spr = spr.data;;

                      (********** DRAWING **********)

let set_animation_frame spr frame_num = 
  if frame_num >= spr.frame_count then 
    Log.error (Printf.sprintf "[Sprite] setting frame %i out of %i"
                 frame_num spr.frame_count)
  else spr.frame_num <- frame_num
;;

let in_bounds sprite =
  let folder aval set =
    if aval = false then false else
    match set.boundary with
    | None -> true
    | Some (minx, miny, maxx, maxy) ->
        sprite.x >= minx && sprite.y >= miny &&
        sprite.x + sprite.w <= maxx && sprite.y + sprite.h <= maxy
  in List.fold_left folder true sprite.sets
;;

let get_animation_frame spr = spr.frame_num;;

let draw ?on spr = 
  let src_rect = Sdlvideo.rect (spr.frame_num * spr.w) 0 spr.w spr.h in
  Video.blit spr.frames ~src_rect ?on spr.x spr.y
;;


let move_in_bounds sprite ?(chk=in_bounds) (dx, dy) =
  let rec movin x1 y1 x2 y2 ret =
(*    Log.debug (Printf.sprintf "<%i,%i><%i,%i>" x1 y1 x2 y2);*)
    move_to sprite (x1, y1);
    if not (chk sprite) then ret else
    if x1 = x2 && y1 = y2 then (x1, y1) else
    let dpc a1 a2 =
      let da = (a1 + a2) / 2 in
      let da = if (a1 + a2) < 0 && (a1 + a2) mod 2 <>0 then da - 1 else da in
      if da < a2 then da, da + 1
      else if da < a1 then da + 1, da
      else da, da
    in
    let nx1, nx2 = dpc x1 x2
    and ny1, ny2 = dpc y1 y2 in
    let r1 = movin x1 y1 nx1 ny1 ret in 
    if r1 <> (nx1, ny1) then begin
      r1 
    end else begin
      movin nx2 ny2 x2 y2 (nx1, ny1)
    end
  in
  let (x, y) = sprite.x, sprite.y in
  let (nx, ny) = movin x y (x + dx) (y + dy) (x, y) in
  move_to sprite (nx, ny);
  (nx - x, ny - y)
;;

let get_size spr = (spr.w, spr.h);;

external mask_cut_c : Sdlvideo.surface -> Sdlvideo.surface ->
  (int * int * int * int) -> (int * int * int * int) -> int -> unit =
    "ml_mask_cut";;

let mask_cut spr1 spr2 alpha_bias =
  if not ((spr1.x < spr2.x + spr2.w) && (spr1.x + spr1.w > spr2.x) &&
  (spr1.y < spr2.y + spr2.h) && (spr1.y + spr1.h > spr2.y)) then ()
  else begin
    let minx = max spr1.x spr2.x
    and maxx = min (spr1.x + spr1.w - 1) (spr2.x + spr2.w - 1)
    and miny = max spr1.y spr2.y
    and maxy = min (spr1.y + spr1.h - 1) (spr2.y + spr2.h - 1) in
    let s1x = spr1.x - spr1.w * spr1.frame_num
    and s2x = spr2.x - spr2.w * spr2.frame_num in
    mask_cut_c spr1.frames.Video.surf spr2.frames.Video.surf (minx, maxx, s1x, s2x)
      (miny, maxy, spr1.y, spr2.y) alpha_bias
  end
;;

module Table = struct

  let create size = (Hashtbl.create size, Set.create size)
      
  let add (table, set) key sprite =
    Hashtbl.replace table key sprite;
    Set.add set sprite

  let del (table, set) key =
    let sprite = Hashtbl.find table key in
    Hashtbl.remove table key;
    Set.del set sprite

  let clear (table, set) =
    Hashtbl.clear table;
    Set.clear set

  let iter iter_fun (table, set) = Hashtbl.iter iter_fun table

  let iter_data iter_fun (table, set) = 
    let iterator key sprite = iter_fun key sprite sprite.data in
    Hashtbl.iter iterator table

  let fold fold_fun (table, set) key = Hashtbl.fold fold_fun table key

  let fold_data fold_fun (table, set) key = 
    let folder key sprite old = fold_fun key sprite sprite.data old in
    Hashtbl.fold folder table key

  let find (table, set) key = Hashtbl.find table key

  let set_boundary (table, set) min_x max_x min_y max_y =
    Set.set_boundary set min_x max_x min_y max_y
      
  let set_collision (table, set) width height =
    Set.set_collision set width height
      
  let set table = snd table

end;;
