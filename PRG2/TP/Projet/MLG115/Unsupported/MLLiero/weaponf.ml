module type BulletSig =
sig
type t =
{
  velocity: (float*float);  
  lifetime: int;
  generates_debris:bool;
  power: int;
}

val get_speed : t Sprite.t -> float* float 

val set_speed : t Sprite.t -> float * float -> unit

val new_bullet : int * int -> float *  float -> t Sprite.t 

val process : t Sprite.t -> unit

val makes_debris : t Sprite.t -> bool

(*val collision : t Sprite.t ->  Collision.collision_kind ->  unit *)

val bullet_set : t Sprite.set 

val draw_bullet : Video.t -> t Sprite.t -> unit
end

type weapon_t =
{
  amount_of_bullets:int;
  reloading_time:int;
  initial_velocity:float;
  name:string;
  mutable bullets_left:int;
  mutable reloading_left:int;
}

module type WeaponSig =
sig

type t = weapon_t

val get_reload_left : weapon_t -> int
val get_reloading_time : weapon_t -> int
val get_name : weapon_t -> string
val get_weapon : string -> int -> int -> float -> weapon_t
val fire : weapon_t -> int * int -> float * float -> float -> int -> unit
val process : weapon_t -> unit
val draw_bullets : Video.t -> unit
end

module Make (Bullet:BulletSig) =
struct 

type t = weapon_t;;


let set_reloading weapon v=weapon.reloading_left <- v;;

let get_reload_left weapon=weapon.reloading_left;;
   
let get_reloading_time weapon=weapon.reloading_time;;

let fire weapon start_pos (vx,vy) angle direction =
  let (reload,bullets)=(weapon.reloading_left,weapon.bullets_left) in
  match (reload,bullets) with
  |(0,0) -> weapon.reloading_left <- weapon.reloading_time
  |(0,k) ->
      begin
        weapon.bullets_left <- (bullets-1);
        let (v2x,v2y)=(vx+.float_of_int(direction)*.weapon.initial_velocity*.cos(angle),vy+.weapon.initial_velocity*.sin(angle)) in
        ignore (Bullet.new_bullet start_pos (v2x,v2y))
      end
  | _ -> ()
;;

let get_weapon name bullets_number reload_time initial_velocity  =
  {
   reloading_time=reload_time;    
   amount_of_bullets=bullets_number;
   bullets_left=bullets_number;
   reloading_left=0;
   initial_velocity=initial_velocity;
   name=name};;
   
let get_name weapon=weapon.name;;

let process weapon = 
  let rl = weapon.reloading_left in
  Sprite.Set.iter (Bullet.process) Bullet.bullet_set;
  match rl with
  | 0 -> ()
  | 1 -> weapon.reloading_left <- 0; weapon.bullets_left <- 1
  | k -> weapon.reloading_left <- (k-1)
;;

let draw_bullets context = 
  Sprite.Set.iter (Bullet.draw_bullet context) Bullet.bullet_set;;
end (*Struct*)

