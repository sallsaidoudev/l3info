val init : int -> unit;;
val draw : Video.t -> unit;;
val stop_nth : int ->  bool-> bool;;
val time_flow : int -> unit;;
val start : bool ref;;
val get_players_clocks : unit -> ((int*int*int*int*int*int) array) ;;
val reset_clocks : int -> unit;;

