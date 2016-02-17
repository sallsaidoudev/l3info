

val my_Y: int;;

type p_obj ;;


(* ----------- palka ----------------------------*)
val palki: p_obj Sprite.set;;


(*-------- obliczanie wspolczynnika odbicia --------*)
val oblicz_odbicie: 'a Sprite.t -> float * float -> p_obj Sprite.t -> float * float;;
val udezyla: 'a Sprite.t -> p_obj Sprite.t -> unit;;

val is_odbicie: 'a Sprite.t -> p_obj Sprite.t -> float * float -> bool;;

(*------- moves ----------------------------*)

val move: int -> int -> unit ;; 

val fire: int -> int -> unit ;;


(*--------- standard -----------------------------------*)
val draw: unit -> unit ;;

val frame: int -> unit ;;

val init: unit -> unit;;






