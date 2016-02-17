type t = 
{
  velocity: (float*float);  
  lifetime: int;
  generates_debris:bool;
  power: int;
}

let img = Video.load_image "Data/fire.png";;

let bullet_set=Sprite.Set.create 32;;

Sprite.Set.set_boundary bullet_set 0 0 800 600;;
Sprite.Set.set_collision bullet_set 32 32;;

let get_speed bullet=(Sprite.get_data bullet).velocity;;

let set_speed bullet v=let state=Sprite.get_data bullet in
   Sprite.set_data bullet {state with velocity=v};;
   
let get_lifetime bullet=(Sprite.get_data bullet).lifetime;;

let set_lifetime bullet v=let state=Sprite.get_data bullet in
   Sprite.set_data bullet {state with lifetime=v};;
   
let makes_debris bullet=(Sprite.get_data bullet).generates_debris;;

let collide_player bullet player =
  Explosion.new_explosion (Sprite.get_pos bullet) ((Sprite.get_data bullet).power);
  Sprite.Set.del bullet_set bullet
;;

let collide_wall bullet =
  let (vx,vy) = get_speed bullet in
  Sprite.move bullet (-int_of_float (1.2*.vx),-int_of_float (1.2*.vy));
  set_speed bullet (General.ideal_bounce bullet (vx,vy) [Arena.set]);
;;

Sprite.add_collision_fun bullet_set Arena.set true (fun b w -> collide_wall b);;

Sprite.add_collision_fun bullet_set Player.set true collide_player;;

let process bullet = 
  let speed=get_speed bullet in
  let lifetime=(get_lifetime bullet) in
  if lifetime = 0 then Sprite.Set.del bullet_set bullet else
  set_lifetime bullet (lifetime-1);
  General.move_slowly bullet speed;
  if Sprite.in_bounds bullet then () else
  collide_wall bullet
;;
   
let new_bullet pos initial_velocity =
  let initial_state = {
    velocity=initial_velocity; 
    generates_debris=false; 
    power=12; 
    lifetime=400;
  } in
  Sprite.create ~set:bullet_set initial_state img pos
;; 
   
let draw_bullet context bullet = 
  Sprite.draw ~on:context bullet
;;
