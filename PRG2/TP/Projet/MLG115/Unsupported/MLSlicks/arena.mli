val video_x : int;;
val video_y : int;;
val init : unit -> unit;;
val draw : Video.t -> unit;;
val arena_sprites :  unit Sprite.set;;
val clock_pos_x : int;;
val clock_pos_y : int;;
val pl_clock_pos_x : int -> int;;
val pl_clock_pos_y : int -> int;;

type dir = LEFT | RIGHT 
;;
(** directed list of checkpoint, player has to pass to complete a loop on 
 * the arena. First pair - beginning of the line, second - the end, third
 * element specifies from which direction this vector must be passed*)
val checkpoints : ((int*int)*(int*int)*dir) list ref;;

(** [get_pos player_number] specifies the position where the player starts 
 * his race *)
val get_pos : int -> (int*int);;

