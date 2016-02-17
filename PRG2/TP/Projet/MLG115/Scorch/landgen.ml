
(*let block_pic () = Video.load_image (Options.gfx_path^ !Options.land_block);;*)
let block_pic = Video.load_image (Options.gfx_path^"ice_block1.png");;

let tile_size = 64;;

let unoptimized_rect_block dims =
  let get_surf () =
    let surf = Video.create_surface dims in 
    Widget.tile_fill ~surf:surf block_pic (0, 0) dims;
    surf
  in
  Video.provide_image get_surf
;;

let rect_block dims = Video.optimize (unoptimized_rect_block dims);;

let make player_count (*block_pic*) =
  let margin = 40 in
  let (ww, wh) = (!Options.width, !Options.height) in
  let surf = (unoptimized_rect_block (ww, wh)).Video.surf in
  let land_line = 
    let line = Array.make ww 0 in
    let next_height (delta, last) =
      let bound (delta, vl) =
        if vl > (wh - margin) then (0, wh - margin)
        else if vl < margin then (0, margin)
        else (delta, vl)
      in
      if (Random.int 100) < !Options.bumpiness then
        let new_delta =
          max (min
	    (*(delta + (Random.int ((!Options.bumpiness *2 )+1)) - (!Options.bumpiness)) *)
            (delta + (Random.int 3) - 1)
	    !Options.slope) (- !Options.slope)
          (*delta + (Random.int 3) - 1*)
        in
        bound(new_delta, last + delta)
      else
        bound(delta, last + delta)
    in
    let rec land_line_make (delta,vl) i max =
      if i < max then
      begin
        line.(i) <- vl;
        land_line_make (next_height (delta,vl)) (i+1) max
      end
      else
        line
    in
    land_line_make (0, Random.int wh) 0 ww
  in
  let rec cut_places i max =
    if i < max then
    begin
      Video.line ~surf (i, 0) (i, land_line.(i)) (255,0,255);
      cut_places (i + 1) max
    end
    else
      surf
  in
  let rec max_in_line x1 x2 =
    let max v1 v2 = if v1 > v2 then v1 else v2 in
    if x1 = x2 then land_line.(x1)
    else max land_line.(x1) (max_in_line (x1+1) x2)
  in
  let rec locations i max = 
    if i < max then
    begin
      let rnd_loc_mod = ((Random.int 11) - 5) * 20 in
      let x = (((ww / (max + 1)) * (i+1)) - 7) + rnd_loc_mod in 
      let h = max_in_line x (x + 15) in
      Video.fill ~surf ~rect:(Sdlvideo.rect x 0 15 h) (255, 0, 255);
      (x, h - 8) :: locations (i+1) max
    end
    else
      []
  in
  let final_surf = (cut_places 0 ww) in
  let cut2tiles surf =
    let lst = ref [] in
    for i = 0 to (ww / tile_size) do
      for j = 0 to (ww / tile_size) do
        let tile = Video.create_surface (tile_size, tile_size) in
	let src_rect = Sdlvideo.rect (i*tile_size) (j*tile_size) tile_size tile_size in
	Sdlvideo.blit_surface ~src:surf ~src_rect ~dst:tile ();
	lst := (tile, (i*tile_size, j*tile_size)) :: !lst
      done
    done;
    !lst
  in
  (*Sdlvideo.set_color_key surf (Sdlvideo.map_RGB surf (255,0,255));*)
  (*let get_surf () = final_surf in
  let image = Video.optimize (Video.color_key (Video.provide_image get_surf)) in
  (image, locations 0 player_count)*)
  let locs = locations 0 player_count in
  let images =
    List.map (fun (surf, pos) ->
       (Video.color_key (Video.provide_image (fun () -> surf))), pos
    ) (cut2tiles final_surf)
  in
  (images, locs)
;;
