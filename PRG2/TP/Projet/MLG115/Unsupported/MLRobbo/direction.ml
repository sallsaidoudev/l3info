type t = LEFT|RIGHT|UP|DOWN|STAY;;

let as_vect = function
  |UP    -> (0, -1)
  |DOWN  -> (0,  1)
  |LEFT  -> (-1, 0)
  |RIGHT -> ( 1, 0)
  |STAY  -> ( 0, 0)
;;
let from_vect (x, y) = 
  if x > 0 then RIGHT else
  if x < 0 then LEFT else
  if y > 0 then DOWN else
  if y < 0 then UP else
  STAY
;;
let all_from = function
  |UP    -> [UP; RIGHT; DOWN; LEFT]
  |DOWN  -> [DOWN; LEFT; UP; RIGHT]
  |LEFT  -> [LEFT; UP; RIGHT; DOWN]
  |RIGHT -> [RIGHT; DOWN; LEFT; UP]
  |_  -> failwith "all_from STAY"
;;
let rev = function
  |UP    -> DOWN
  |DOWN  -> UP
  |LEFT  -> RIGHT
  |RIGHT -> LEFT
  |STAY  -> failwith "rev from STAY"
;;
let to_string = function
  |UP    -> "up"
  |DOWN  -> "down"
  |LEFT  -> "left"
  |RIGHT -> "right"
  |STAY  -> "stay"
;;
let oper f (x1, y1) (x2, y2) = (f x1 x2, f y1 y2);;
let mul dir = oper ( * ) (as_vect dir);;
let add dir = oper ( + ) (as_vect dir);;
let sub dir vec = oper ( - ) vec (as_vect dir);;