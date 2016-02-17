
val dimX: int;;
val dimY: int;;

val in_X: int;;
val in_W: int;;

val max_plansz: int;;


type b_obj;;

(* klocki *)
val klocki: b_obj Sprite.set;;

val is_klocki: unit -> bool;;


(*----------- sciany -----------------------------*)
val sciany: b_obj Sprite.set;;


(*-------- obliczanie wspolczynnika odbicia --------*)
val oblicz_odbicie: 'a Sprite.t -> float * float -> b_obj Sprite.t -> float * float;;
val udezyla: 'a Sprite.t -> b_obj Sprite.t -> unit;;

val is_odbicie: 'a Sprite.t -> b_obj Sprite.t -> float * float -> bool;;


(*--------- load level -------------------------------*)

val load_level: int -> unit;;

(*--------- standard -----------------------------------*)

val draw: unit -> unit ;; 

val frame: int -> unit ;;

val init: unit -> unit;;
