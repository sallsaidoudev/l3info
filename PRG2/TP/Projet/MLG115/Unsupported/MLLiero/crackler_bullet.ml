type t = 
{
  velocity: (float*float);  
  lifetime: int;
  generates_debris:bool;
  power: int;
}

let img = Video.load_image "Data/fire.png";;

let human_player_set=World.human_player_set;;
let ai_player_set = World.ai_player_set;;

let stone_set=Stone.stones_set;;

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


let collision bullet kind = 
  let (vx,vy)=get_speed bullet in
   let pos=(Sprite.get_pos bullet) in
     Explosion.new_explosion (Sprite.get_pos bullet) ((Sprite.get_data bullet).power);
     Sprite.Set.del bullet_set bullet;;

Sprite.add_collision_fun bullet_set stone_set true
(fun bullet _ ->collision bullet Collision.Fixed_Object);;

Sprite.add_collision_fun bullet_set human_player_set true
(fun bullet _ ->collision bullet Collision.Player);;

Sprite.add_collision_fun bullet_set ai_player_set true
(fun bullet _ ->collision bullet Collision.Player);;

let process bullet = let (vx,vy)=get_speed bullet in
  let lifetime=(get_lifetime bullet) in
  match lifetime with
  |0 -> Sprite.Set.del bullet_set bullet
  |k -> set_lifetime bullet (lifetime-1);
  
  General.move_slowly bullet (vx,vy);
  set_speed bullet (vx/.5.0+.(2.0*.(Random.float 10.0)-.10.0),vy/.5.0+.(2.0*.Random.float 10.0)-.10.0);
  Debris.generate_debris (Sprite.get_pos bullet) (vx,vy) 2;
  if not (Sprite.in_bounds bullet) then 
    collision bullet Collision.Fixed_Object
  else
    ();;
   
let new_bullet pos initial_velocity =
   let initial_state=
   {velocity=initial_velocity; 
    generates_debris=false; 
    power=2; 
    lifetime=200;
   } in
   Sprite.create ~set:bullet_set initial_state img pos;; 
   
let draw_bullet context bullet = 
   Sprite.draw ~on:context bullet;;
