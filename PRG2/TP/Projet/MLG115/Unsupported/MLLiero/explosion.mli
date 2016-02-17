type t = 
{
  power : int;
}

(** Contains all active explosions i.e. those which were created by new_explosion and
    have not extinguished yet (in function process) *)
val explosion_set : t Sprite.set

(** Returns power of given explosion *)
val get_power : t Sprite.t -> int

(** Creates new explosion in given position with given power and adds it into explosion_set *)

val new_explosion : int * int -> int -> unit

(** Makes explosions explode. Explosions extinguish after 15 frames *)
val process : t Sprite.t -> unit