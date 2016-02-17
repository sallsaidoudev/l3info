(* ROBBO
 * Tomasz Kokoszka
 *)
type t = LEFT|RIGHT|UP|DOWN|STAY;;

(** [Direction.as_vect dir] wersor opisuj±cy kierunek [dir], np (-1, 0) dla LEFT *)
val as_vect : t -> int * int;;

(** [Direction.from_vect vec] okre¶la kierunek wektora *)
val from_vect : int * int -> t;;

(** [Direction.all_from dir] daje liste kierunków w porz±dku zegarowym 
    pocz±wszy od [dir] *)
val all_from : t -> t list;;

(** [Direction.rev dir] daje kierunek przeciwny *)
val rev : t -> t;;

(** [Direction.to_string dir] *)
val to_string : t -> string;;

(** [Direction.mul dir vec] mno¿y wersor kierunku [dir] z wektorem [vec] *)
val mul : t -> int * int -> int * int;;

(** [Direction.add dir vec] dodaje do wersora kierunku [dir] wektor [vec] *)
val add : t -> int * int -> int * int;;

(** [Direction.sub dir vec] odejmuje od wektora [vec] wersor kierunku [dir] *)
val sub : t -> int * int -> int * int;;
