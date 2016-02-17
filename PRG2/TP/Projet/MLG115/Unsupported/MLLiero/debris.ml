type t = 
{
  velocity: (float*float);  
  lifetime: int;
  generates_debris:bool;
  power: int;
}

let img = Video.load_image "Data/debris.png";;

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


let rec generate_velocities (vx,vy) vel_list how_many =
   match how_many with
   |0 -> vel_list
   |k -> let new_vel=(vx*.2.0*.((Random.float 0.25)-.0.25) , vy*.(2.0*.(Random.float 0.25)-.0.25)) in
             generate_velocities (vx,vy) (new_vel::vel_list) (how_many-1);;
	     
let collision bullet kind = 
  let (vx,vy)=get_speed bullet in
   let pos=(Sprite.get_pos bullet) in
     Sprite.move bullet (-int_of_float vx,-int_of_float vy);
     Explosion.new_explosion (Sprite.get_pos bullet) ((Sprite.get_data bullet).power);
     Sprite.Set.del bullet_set bullet;;

Sprite.add_collision_fun bullet_set stone_set true
(fun bullet _ ->collision bullet Collision.Fixed_Object);;

Sprite.add_collision_fun bullet_set human_player_set true
(fun bullet _ ->collision bullet Collision.Player);;

Sprite.add_collision_fun bullet_set ai_player_set true
(fun bullet _ ->collision bullet Collision.Player);;

let process bullet = let (vx,vy)=get_speed bullet in
  General.move_slowly bullet (vx,vy);
  set_speed bullet (0.99*.vx,0.99*.vy+.0.2);
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
   
  
let generate_debris pos (vx,vy) how_much =
   let list_of_velocities=generate_velocities (vx,vy) [] (Random.int how_much) in
   List.iter (fun vel -> ignore (new_bullet pos vel)) list_of_velocities;;

   
let draw_bullet context bullet = 
   Sprite.draw ~on:context bullet;;
   
let draw_bullets context = Sprite.Set.iter (draw_bullet context) bullet_set;;
