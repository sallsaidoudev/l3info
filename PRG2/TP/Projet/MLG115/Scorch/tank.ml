type t = {
  plid : int;
  mutable ready : bool;
  mutable dead : bool;
  mutable x : float;
  mutable y : float;
  mutable vx : float;
  mutable vy : float;
  mutable angle : int;
  mutable power : int;
  mutable hapeki : int;
  mutable wpid : string;
  weapons : (string, int) Hashtbl.t;
};;

let pic_tank = Video.color_key ~ck:(255, 0, 255) (Video.load_image (Options.gfx_path^"tank.png"));;
let focus_pic = Video.optimize (Video.color_key ~ck:(255, 0, 255) (Video.load_image (Options.gfx_path^"selfr2.png")));;
let small_font = Font.load ~color:(Color.colorize_gray ((0,255,0), 0)) (Options.gfx_path^"micro2.png");;

let tanks = Hashtbl.create 10;;

let focus = ref (-1);;

let set = Sprite.Set.create 10;;
Sprite.Set.set_collision set 100 100;;
Sprite.Set.set_boundary set (-1000) (-1000) 2000 1000;;

let sprite plid = Hashtbl.find tanks plid;;
let data plid = Sprite.get_data (sprite plid);;

let update sprite =
  let data = Sprite.get_data sprite in 
  Sprite.move_to sprite ( int_of_float data.x, int_of_float data.y )
;;

(* operations *)

let set_focus plid = focus := plid;;

let create plid (x, y) =
  let start_weapons =
    let new_tbl = Hashtbl.create 20 in
    Hashtbl.replace new_tbl "sm" (-1);
    new_tbl
  in
  let tankdata = {
     plid = plid;
     x = float_of_int x;
     y = float_of_int y;
     vx = 0.;
     vy = 0.;
     angle = 0 ;
     power = 30 ;
     ready = true;
     dead = false;
     wpid = "sm";
     hapeki = !Options.hitpoints;
     weapons = start_weapons;
    }
  in
  let pic =
    let color = 
      match plid with
      | 0 -> (255, 0, 0)
      | 1 -> (0, 255, 0)
      | 2 -> (0, 0, 255)
      | _ -> (255, 255, 0)
    in
    Video.optimize (Video.color_image pic_tank (Color.colorize_gray (color, 0)))
  in
  Hashtbl.replace tanks plid (Sprite.create ~set:set tankdata pic (x, y));
;;

let refresh plid (x, y) =
  let sprite = Hashtbl.find tanks plid in
  let tank = Sprite.get_data sprite in
  tank.hapeki <- !Options.hitpoints; 
  tank.x <- (float_of_int x); tank.y <- (float_of_int y);
  tank.ready <- true;
  tank.dead <- false;
  update sprite;
;;

let re_create plid pos =
  if Hashtbl.mem tanks plid then refresh plid pos
  else create plid pos
;;

(*
let new_round plid x y =
  let tank = Sprite.get_data (Hashtbl.find tanks plid) in
  tank.hapeki <- 0;
  tank.ready <- true;
  tank.dead <- false
;;
*)
let clear () =
  Sprite.Set.clear set;
  Hashtbl.clear tanks;
;;

let results () =
  let alive_tank_list =
    Hashtbl.fold (fun plid tank_spr lst ->
      let tank = Sprite.get_data tank_spr in
      if tank.hapeki > 0 then (plid, tank_spr) :: lst
      else lst ) tanks []
  in
  match alive_tank_list with
  | [(plid, tank)] -> Score.Winner plid
  | [] -> Score.Draw
  | _ -> Score.Unresolved
;;

let all_ready () = 
  let ready plid tank acc =
    let data = Sprite.get_data tank in
    if data.ready then acc
    else false
  in
  Hashtbl.fold ready tanks true
;;

let die tank_spr by =
  let tank = Sprite.get_data tank_spr in
  let die () =
    tank.hapeki <- 0;
    tank.ready <- true;
    tank.dead <- true;
    Score.killed tank.plid by;
    Log.info ("Player "^(string_of_int tank.plid)^" died");
    Explosion.make (-1) "emm" (Sprite.get_pos tank_spr);
  in
  if not tank.dead then die ()
  (*else Log.info "The dead cannot die"*)
;;

(* commands *)

let max_power = 100 ;;

let adjust_power step plid = 
  (data plid).power <- max 0 (min max_power (((data plid).power + step)));;

let adjust_angle step plid = 
  let wrap vl = if vl > 180 then vl - 181 else if vl < 0 then vl + 181 else vl in
  (data plid).angle <- wrap ((data plid).angle + step)
;;

let up = adjust_power 1;;
let dwn = adjust_power (-1);;

let lft = adjust_angle (-1);;
let rgt = adjust_angle 1;;

let nwp plid =
  let data = Sprite.get_data (Hashtbl.find tanks plid) in
  let wplist = Hashtbl.fold (fun wpid _ acc -> wpid :: acc) data.weapons [] in
  let nwpid = 
    let wpid = data.wpid in
    fst (List.fold_left (fun (ret, last) id -> 
      if last = wpid then (id, id)
      else (ret, id)) (wpid, wpid) wplist)
  in
  data.wpid <- nwpid
;;

let set_aim plid (angle, power) =
  (data plid).angle <- angle;
  (data plid).power <- min power max_power
;;

let get_aim plid = ((data plid).angle, (data plid).power);;

let set_weapon plid wpid =
(*  let tank = Sprite.get_data (Hashtbl.find tanks plid) in*)
  if Hashtbl.mem (data plid).weapons wpid then ((data plid).wpid <- wpid)
  else Log.info "You don't have that weapon"
;;

let get_weapon plid = (data plid).wpid;;
  
let power_step = 0.05 ;;

let fire plid () =
  let deg2rad v = (v -. 180. ) *. 6.28 /. 360. in
  let tank = Sprite.get_data (Hashtbl.find tanks plid) in
  let (x, y) = (tank.x +. 8., tank.y -. 2.) in
  let (a, p) = (float tank.angle, (float tank.power) *.power_step ) in
  let vx = p *. ( cos ( deg2rad a ) ) in
  let vy = p *. ( sin ( deg2rad a ) ) in
  let use wpid = 
    let quant = Hashtbl.find tank.weapons wpid in
    if quant > 1 then Hashtbl.replace tank.weapons wpid (quant - 1)
    else if quant = -1 then ()
    else begin
      Hashtbl.remove tank.weapons wpid;
      set_weapon plid "sm" end
  in
  if not (data plid).dead then begin
    Missle.create plid (Weapon.mid tank.wpid) x y vx vy;
    use tank.wpid end
;;

let add_weapon plid wpid quant =
  let tank = Sprite.get_data (Hashtbl.find tanks plid) in
  let old_quant =
    try Hashtbl.find tank.weapons wpid
    with Not_found -> 0
  in
  let new_quant =
    if old_quant = -1 then -1
    else old_quant + quant
  in
  Hashtbl.replace tank.weapons wpid new_quant
;;

let inv plid =
  let tank = Sprite.get_data (Hashtbl.find tanks plid) in
  Log.info ("-------- Inventory of player "^(string_of_int plid)^" : --------");
  Hashtbl.iter (fun wpid quant ->
    let quant_string =
      if quant = -1 then "Helluva lot"
      else string_of_int quant
    in
    Log.info (quant_string^" of "^(Weapon.name wpid))
  ) tank.weapons
;;
 
let dead plid = (data plid).dead;;

(* workhorses *)

let hit_by_missle tank missle =
  (*Log.info "Ouch! That hurts my feelinigs"*)
  let tank = Sprite.get_data tank in 
  Score.direct_hit tank.plid (Missle.plid missle)
;;

let hit_by_explosion tank_spr expl =
  let tank = Sprite.get_data tank_spr in
  let by = (Explosion.plid expl) in
  let damage = Explosion.damage expl in
  if tank.hapeki > 0 then
  begin
    tank.hapeki <- tank.hapeki - damage;
    if tank.hapeki <= 0 then die tank_spr by;
    Score.damaged tank.plid by damage;
  end
;;

let frame_small () =
  let move sprite =
    let data = Sprite.get_data sprite in
    let oldx, oldy = data.x, data.y in
    let newx, newy =(data.x +. data.vx), (data.y +. data.vy) in
    let try_move =
      Sprite.move_to sprite (int_of_float newx, int_of_float newy);
      match Sprite.collides_with sprite true Block.blocks with
        | [] -> data.x <- newx; data.y <- newy; 
        | _ -> 
           Sprite.move_to sprite (int_of_float oldx, int_of_float oldy);
	   (*if data.vy <> 0. then Log.info "Boink!";*)
           data.vy <- 0.; data.vx <- 0.;
           data.ready <- true;
    in
    data.vy <- data.vy +. !Options.gravity;
    try_move;
    Sprite.check_collisions sprite;
    if not (Sprite.in_bounds sprite) then die sprite (-1)
  in
  Sprite.Set.iter move set
;;

let frame () =
 ()
;;

let draw () = 
  let draw_barrel sprite =
    let data = Sprite.get_data sprite in
    let (x1, y1, x2, y2) =
      let deg2rad v = (v -. 180. ) *. 6.28 /. 360. in
      let (a, p) = (float data.angle, (float data.power) *.power_step ) in
      let sx = int_of_float ( 8. *. ( cos ( deg2rad a ) ) ) in
      let sy = int_of_float ( 8. *. ( sin ( deg2rad a ) ) ) in
      let tx, ty = Sprite.get_pos sprite in
      (tx + 7,ty + 3, sx + tx + 7, sy + ty + 3)
    in 
    Video.line (x1, y1) (x2, y2) (192, 192, 192);
  in 
  let draw_focus sprite =
    let data = Sprite.get_data sprite in
    let x, y = (int_of_float data.x), (int_of_float data.y) in
    let angle, power, hapeki, weapon, plid =
      string_of_int data.angle, string_of_int data.power,
      string_of_int data.hapeki, Weapon.name data.wpid, string_of_int data.plid
    in
    Video.blit focus_pic (x - 2) (y - 6);
    Widget.draw_list small_font (x, (y + 14))
      ["Player "^plid;"ang : "^angle; "pow : "^power; "hp : "^hapeki; weapon];
  in
  Hashtbl.iter ( fun plid sprite -> 
    let draw_intern () = 
      Sprite.draw sprite;
      draw_barrel sprite;
      if (!focus = plid) then draw_focus sprite
    in
    if not (Sprite.get_data sprite).dead then draw_intern ()
 ) tanks   
;;
