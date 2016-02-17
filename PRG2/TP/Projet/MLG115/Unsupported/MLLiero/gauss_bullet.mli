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

(** Does this bullet leave debris upon collision ? *)
val makes_debris : t Sprite.t -> bool

(** Function called by Sprite module when bullet hits someting *)
(*val collision : t Sprite.t ->  Collision.collision_kind ->  unit *)

(** Keeping bullets in Sprite.set set is necessary in order to get 
   collision detection from Sprite module *)
   
val bullet_set : t Sprite.set 

(** Draws all bullets from bullet_set *)
val draw_bullet : Video.t -> t Sprite.t -> unit 
