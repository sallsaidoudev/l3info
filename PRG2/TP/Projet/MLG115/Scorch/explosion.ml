type edata = {
  plid : int;
  eid : string;
  damage : int;
  mutable frame : int 
}

let expls = Sprite.Set.create 10;;
Sprite.Set.set_collision expls 100 100;;

let file filename = (Options.gfx_path^filename^".exp");;

let expl_anims = Hashtbl.create 10;;

let add_ring_expl (id, r1, r2, size, count, slow, color, (col_fun:string), (power:int)) =
  let r1, r2, size =
    float_of_int r1, float_of_int r2,
    float_of_int size
  in
  let color = 
    match Color.get color with (r, g, b) ->
    (float r, float g, float b, 128.)
  in
  let col_fun =
    match col_fun with
    | "to_red" -> Exgen.to_red
    | "to_blue" -> Exgen.to_blue
    | "to_blue_mag" -> Exgen.to_blue_mag
    | "fade" -> Exgen.fade
    | _ -> Exgen.fade
  in
  let frames =
    let surface () =
      Exgen.get
        (Exgen.ring r1 r2 size count 25 color (Exgen.slow slow) col_fun)
        (file id)
    in 
    Video.optimize ~alpha:true (Video.provide_image surface)
  in
  Hashtbl.replace expl_anims id (frames, power)
;;

let add_ring_type =
  let pint, pstring, pfloat = Parser.int (), Parser.string, Parser.float () in
  Parser.nonuple pstring pint pint pint pint pfloat pstring pstring pint
;;

Parser.add_command "ring_explosion" add_ring_type "" add_ring_expl;;

let any () = Sprite.Set.fold (fun _ _ -> true) expls false;;

let plid expl = (Sprite.get_data expl).plid;;

let damage expl = (Sprite.get_data expl).damage;;

let make plid eid (x, y) =
  try 
    let frames, damage = Hashtbl.find expl_anims eid in
    match Sdlvideo.surface_dims frames.Video.surf with (w, h, p) ->
    ignore (Sprite.create 
      ~set:expls 
      {plid = plid; eid = eid; frame = 0; damage = damage} 
      frames
      ~width:(w/25) (x - (h/2), y - (w/50)))
  with Not_found -> Log.error (eid ^ " is not a valid eid")
;;

let frame () =
  Sprite.Set.iter ( fun sprite ->
    let data = Sprite.get_data sprite in
    Sprite.set_animation_frame sprite data.frame;
    Sprite.check_collisions sprite;
    data.frame <- data.frame + 1;
    if data.frame > 24 then Sprite.delete sprite; 
  ) expls
;;

let draw () =
  Sprite.Set.iter Sprite.draw expls
;;
