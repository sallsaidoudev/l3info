type state =
{
  v:(float*float);
  hooked:bool;
  released:bool;
}

let hook_img=Video.load_image "Data/pixel.png";;

let hook_set=Sprite.Set.create 32;;

Sprite.Set.set_boundary hook_set 0 0 1600 1200;;

let hide hook player =
  Sprite.set_data hook {released=false;hooked=false; v=(0.0,0.0);};
  Sprite.move_to hook (Sprite.get_pos player)
;;
    
let release hook pos speed = 
  Sprite.move_to hook pos;
  Sprite.set_data hook {v=speed; hooked=false; released=true}
;;

let new_hook pos =
  let initial_state={v=(0.0,0.0);hooked=false;released=false;} in
  Sprite.create ~set:hook_set initial_state hook_img pos
;;

let is_released hook =(Sprite.get_data hook).released;;
let is_hooked hook =(Sprite.get_data hook).hooked;;

let set_hooked hook = 
  let state=(Sprite.get_data hook) in
  Sprite.set_data hook {state with hooked=true}
;;

let draw context hook player_pos=
  let (x2,y2)=Sprite.get_pos hook 
  and (x1,y1)=player_pos in
  if is_released hook then begin
    Video.line ~on:context (x1+9,y1+8) (x2+1,y2) (0,127,0);
    Video.line ~on:context (x1+8,y1+8) (x2,y2) (0,127,0);
    Sprite.draw ~on:context hook
  end
;;

let rope_force hook (px,py) =
  if not (is_hooked hook) then (0.0,0.0) else
  let (hx,hy)=(Sprite.get_pos hook) in
  let rope_vector = (float_of_int(hx-px),float_of_int(hy-py)) in
  let length (x,y)=sqrt (x*.x+.y*.y) in
  let rope_length  = length rope_vector in
  let bungee_length = if rope_length<200.0 then 20.0 else rope_length/.6.0 in
  let force_value = 
    if rope_length<bungee_length then (0.0) else
    if rope_length<8.0*.bungee_length then (0.22*.(rope_length/.bungee_length))
    else (2.0) 
  in
  let normalize (x,y)= let norm = length (x,y) in (x/.norm,y/.norm) in
  let scale a (x,y) = (a*.x,a*.y) in
  let (rx,ry)=scale (force_value*.force_value) (normalize rope_vector) 
  in (rx,ry)
;;
    
let process hook =
  if (not (is_released hook)) || (is_hooked hook) then () else
  let (vx, vy) = (Sprite.get_data hook).v in
  let (nx, ny) = (int_of_float(vx), int_of_float(vy)) in
  let chk hook = 
    Sprite.in_bounds hook && Sprite.collides_with hook true Arena.set = [] in
  let moved = Sprite.move_in_bounds hook ~chk (nx, ny) in
  if moved <> (nx, ny) then set_hooked hook
;;

