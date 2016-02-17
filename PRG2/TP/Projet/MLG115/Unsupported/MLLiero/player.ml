let gravity = 0.5;;
let air_viscosity = 0.93;;
let climbing_skill = 3.0;;
let move_speed = 2.5;;
let resistance = 0.8;;
let aim_speed = 0.05;;
let jump_power = 8.0;;

let pi_h = asin 1.;;

let to_int (x, y) = (int_of_float x, int_of_float y);;

let player_img = Video.load_image "Data/worms.png";;

type player_state = {
  mutable pos:float * float;
  mutable vel:float * float;
  mutable angle:float;
  mutable weapon_name : string;
  mutable reload : int;  
  health:int;
  lives:int;
  available_weapons:int list; (* TODO *)
  crosshair:unit Sprite.t;
  hook:Hook.state Sprite.t;
}

let players = Hashtbl.create 10;;


let set = Sprite.Set.create 50;;
Sprite.Set.set_collision set 32 32;;

let crosshair_img = Video.load_image "Data/krzyzyk.png";;

let create pl_no =
  let pos = (100., 100.) in
  let state =
    {pos = pos;
     vel = (0., 0.); 
     angle = 0.; 
     crosshair=Sprite.create () crosshair_img (to_int pos);
     health=200; 
     lives=12; 
     weapon_name="Zimm"; 
     reload=0;
     available_weapons=[0; 1];
     hook = Hook.new_hook (to_int pos);
   } in
  let sprite = 
    Sprite.create ~set ~width:24 state player_img (to_int pos) 
  in
  if pl_no < 0 then Sprite.set_animation_frame sprite 2 else ();
  Hashtbl.replace players pl_no sprite
;;

let delete pl_no = Hashtbl.remove players pl_no;;

let get_direction sprite =
  match Sprite.get_animation_frame sprite with 
    0 | 2 -> -1 | 1 | 3 -> 1 | _ -> assert false
;;

let update_crosshair pl_no sprite data =
  let direction = get_direction sprite in
  let angle = 
    data.angle +. (float_of_int (Controls.get_vy pl_no)) *. aim_speed in
  let angle = 
    if angle > pi_h then pi_h 
    else if angle < -. pi_h then -. pi_h
    else angle 
  in data.angle <- angle;
  let (pos_x, pos_y) = to_int data.pos in
  Sprite.move_to data.crosshair 
    (pos_x+ 10 + direction * int_of_float(30.0*.cos(angle)),
     pos_y+ 2 + int_of_float(30.0*.sin(angle)))
;;

let release_rope pl_no =
  let sprite = Hashtbl.find players pl_no in
  let data = (Sprite.get_data sprite) in
  let direction = get_direction sprite in
  update_crosshair pl_no sprite data;
  let (cx, cy) = Sprite.get_pos data.crosshair in
  let (px, py) = data.pos in
  let (dx, dy) = float_of_int cx -. px -. 10., float_of_int cy -. py -. 6. in
  let (vx, vy) = 0.4 *. dx, 0.4 *. dy in
  Hook.release data.hook (to_int (px +. 10., py +. 6.)) (vx, vy) 
;;


    
let draw_stats (cntx, stat_cntx, pl_no) = 
  let data = Sprite.get_data (Hashtbl.find players pl_no) in
  let pos = to_int data.pos in
  Video.set_cam_pos_center ~on:cntx pos;
;;

let draw (cntx, stat_cntx, pl_no) = 
  let iterator pl_no sprite =
    let data = Sprite.get_data sprite in
    Sprite.move_to sprite (to_int data.pos);
    Sprite.draw ~on:cntx sprite;
    update_crosshair pl_no sprite data;
    Sprite.draw ~on:cntx data.crosshair;
    Hook.draw cntx data.hook (Sprite.get_pos sprite);
  in
  Hashtbl.iter iterator players
;;

let can_go sprite pos =
  Sprite.move_to sprite (to_int pos);
  Sprite.in_bounds sprite && Sprite.collides_with sprite true Arena.set = []
;;

let on_ground sprite (px, py) =
  not (can_go sprite (px, py +. 1.))
;;
    
let move pl_no sprite data =
  let can_go = can_go sprite in
  let old_frame = Sprite.get_animation_frame sprite in
  let dx = Controls.get_vx pl_no in
  begin match dx with
  | 1 -> Sprite.set_animation_frame sprite (if pl_no < 0 then 3 else 1)
  | -1 -> Sprite.set_animation_frame sprite (if pl_no < 0 then 2 else 0)
  | _ -> ()
  end;
  let x, y = data.pos in
  if not (can_go (x, y)) then Sprite.set_animation_frame sprite old_frame;
  let dx = float_of_int dx *. move_speed in
  let vx, vy = data.vel in
  let rvx, rvy = Hook.rope_force data.hook (to_int (x, y)) in
  let vx, vy = vx +. rvx, vy +. rvy in
  let vy = (vy +. gravity) *. air_viscosity in
  let vy, y = if can_go (x, y +. vy) then vy, y +. vy else 0., y in
  if on_ground sprite (x, y) then begin
    let rec climb (x, y) skill = 
      if (can_go (x, y +. skill)) || skill < (-. climbing_skill) then skill
      else climb (x, y) (skill -. 0.5) 
    in let climb = climb (x +. vx +. dx, y) climbing_skill in
    if climb >= (-. climbing_skill) then begin
      data.pos <- (x +. vx +. dx, y +. climb);
      data.vel <- (vx *. resistance, 0.);
    end else begin
      data.pos <- (x, y);
      data.vel <- (0., vy)
    end
  end else begin
    let x = if can_go (x +. vx +. dx, y) then x +. vx +. dx else x in
    data.pos <- (x, y);
    data.vel <- (vx, vy)
  end;
  let (vx, vy) = data.vel in
  let vy = if Controls.get_jump pl_no && on_ground sprite data.pos then 
    vy -. jump_power else vy in
  data.vel <- (vx, vy);
(*  let (x, y) = data.pos in
  let x, y = (if x < 0. then 0. else x), (if y < 0. then 0. else y) in
  data.pos <- (x, y);*)
;;

let player_fire = ref (fun _ _ _ _ _ -> ());;

let process_player pl_no sprite data =
  move pl_no sprite data;
  let hook = data.hook in
  Hook.process hook;
  if Controls.get_change pl_no then
(*    if (not (Hook.is_released hook)) || (Hook.is_hooked hook) then *)
    release_rope pl_no;
  if Controls.get_fire pl_no then
(*    if Hook.is_hooked hook then Hook.hide hook sprite*)
    !player_fire data.weapon_name (Sprite.get_pos data.crosshair) data.vel data.angle (get_direction sprite)
;;

let frame () =
  let pl_frame pl_no sprite =
    process_player pl_no sprite (Sprite.get_data sprite)
  in Hashtbl.iter pl_frame players
;;

let rec find_min_free hashtbl i =
  if (Hashtbl.mem hashtbl i) then find_min_free hashtbl (i - 1) else i
;;

let create_ai () =
  let pl_no = find_min_free players (-1) in
  create pl_no
;;
  
Parser.add_command "comp" (Parser.unit) "" create_ai;;
