(** Checks if given sprite can move holding given speed without hitting
    any of sprites from given list 
   
    Axiom: can_go sp (vx,vy) obstacles = true 
            implies
    	  let sp2=Sprite.move sp (vx,vy) in
	  not Sprite.Collides sp2 obstacles 
*)
val can_go: 'a Sprite.t -> float * float -> 'b Sprite.set list -> bool

(** Moves given sprite checking if it's on collision course. If collision occurs
   registered collision_fun is called *)
val move_slowly : 'a Sprite.t -> float * float -> unit


(** Tries to move given sprite with given speed without hitting any of given obstacles 
    If that's impossible - sprite is moved as close as it's possible to obstacle 
    (not further than 5 pixels)
*)
   

val move_as_possible : 'a Sprite.t -> float * float -> 'b Sprite.set list -> unit

val pi : float

(** Given sprite and his actual velocity. Returns new speed of sprite after
    bounce with given obstacle 
 
 axiom forall (s,v,obstacle,v2) =>
        bounce (s v obstacle) = v2
	implies (can_go s v2 obstacle)=true
*)
 
val bounce : 'a Sprite.t -> float * float -> 'b Sprite.set list -> float * float


(** Same as bounce - but collision doesn't cause any lost of energy *)
val ideal_bounce : 'a Sprite.t -> float * float -> 'b Sprite.set list -> float * float

(** Helper function - draws boundaries around the world *)
val draw_boundaries : Video.t -> unit
