module type BulletSig =
sig
(** Type representing bullet *)
type t =
{
  velocity: (float*float);  
  lifetime: int;
  generates_debris:bool;
  power: int;
}

(** Returs actual velocity of given bullet *)
val get_speed : t Sprite.t -> float* float 

(** Sets bullet's speed to given value *)
val set_speed : t Sprite.t -> float * float -> unit

(** Creates new bullet on given position with given velocity *)
val new_bullet : int * int -> float *  float -> t Sprite.t 

(** Moves bullet adequately to its specific behavior. Checks if bullet has hit
   something. If yes - collision function is called, which responds adequately (most
   likely creates explosion and deletes bullet *)
val process : t Sprite.t ->  unit

(** Does this bullet leaves debris upon collision ? *)
val makes_debris : t Sprite.t -> bool

(** Function called by Sprite module when bullet hits someting *)
(*val collision : t Sprite.t ->  Collision.collision_kind ->  unit *)

(** Keeping bullets in Sprite.set set is necessary in order to get 
   collision detection from Sprite module *)
   
val bullet_set : t Sprite.set 

(** Draws all bullets from bullet_set *)
val draw_bullet : Video.t -> t Sprite.t -> unit 

end (*BULLETSIG*)

(** Type representing weapon *)
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
(** Returns time (in frames) left to reload given weapon *)
val get_reload_left : weapon_t -> int

(** Returns time nedded to full reload of given weapon *)
val get_reloading_time : weapon_t -> int

(** Returns name of given weapon *)
val get_name : weapon_t -> string

(** Constructs weapon of given name with given amount of bullets, reload time
    and value of initial velocity of bullets *)
val get_weapon : string -> int -> int -> float -> weapon_t

(** Shoots given weapon. Arguments are - position of player, his velocity, 
    angle of his crosshair and direction of shot *)
val fire : weapon_t -> int * int -> float * float -> float -> int -> unit

(** Mostly reloads weapon *)
val process : weapon_t -> unit

(** Draws all bullets shot from given weapon *)
val draw_bullets : Video.t -> unit
end

(** Functor making Weapon given Bullet *)
module Make (Bullet:BulletSig):WeaponSig with type t=weapon_t
