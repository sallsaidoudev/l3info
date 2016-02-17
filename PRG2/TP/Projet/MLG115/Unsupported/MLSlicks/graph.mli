val draw_fun : unit -> unit;;
val init : unit -> unit;;
val new_frame_fun : unit -> unit;;
val cars :
        (int, ((float * float) * ((float * float) * ((float * float) * (int * int)))) Sprite.t)
        Hashtbl.t
;;

val video_change_fun : unit -> unit;;
val player_change_fun : int -> bool -> bool -> unit;;
val get_cur_x : (int -> int) ref;;
val get_cur_y : (int -> int) ref;;

 
