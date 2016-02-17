val move_car : 
       ((float * float) * ((float * float) * ((float * float) * (int * int))))
       Sprite.t -> (int*int) -> (int*int) 
;;
val get_dir : 
      ((float * float) * ((float * float) * ((float * float) * (int * int)))) 
      Sprite.t -> int
;;

val collision_fun :        
      ((float * float) * ((float * float) * ((float * float) * (int * int)))) 
      Sprite.t ->
      ((float * float) * ((float * float) * ((float * float) * (int * int)))) 
      Sprite.t ->  unit
;;
val wall_collision :        
      ((float * float) * ((float * float) * ((float * float) * (int * int)))) 
      Sprite.t ->  unit Sprite.t ->  unit
;;

val if_car_online  : 
      ((float * float) * ((float * float) * ((float * float) * (int * int)))) 
      Sprite.t ->
      (int*int) -> (int*int) -> Arena.dir -> bool
;;                  

val _image : string;;
val _width : int;;
val _epsilon_vel : float;;
val initial_data : 
int -> ((float * float) * ((float * float) * ((float * float) * (int * int))));;
