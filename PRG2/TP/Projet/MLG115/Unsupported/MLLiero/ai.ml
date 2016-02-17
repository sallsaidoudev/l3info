let pi = 2. *. asin 1.;;

let (get_vx, get_vy, get_jump, get_change, get_fire) = Controls.ai;;

let rec get_opponent pl_no =
  let no = Random.int 20 - 10 in
  try if no <> pl_no then Hashtbl.find Player.players no
  else get_opponent pl_no
  with Not_found -> get_opponent pl_no
;;
    
let sgn = function
  |0 -> 0
  |k -> if k<0 then -1 else 1
;;

(*  | -1 -> Opponent is on my left *)
(*  |  1 -> Opponent is on my right *)

let ai_vx pl_no =
  let sprite = Hashtbl.find Player.players pl_no 
  and opponent = get_opponent pl_no in
  let (ox, _) = Sprite.get_pos opponent
  and (mx, _) = Sprite.get_pos sprite in
  let direction = Player.get_direction sprite in
  if abs (ox - direction * 50 - mx) < 50 then 0 else
    sgn (ox - direction * 50 - mx)
;;
    
(** Calculates angle between myself and my opponent *)
let calculate_angle pl_no =
  let sprite = Hashtbl.find Player.players pl_no 
  and opponent = get_opponent pl_no in
  let (ox,oy)=Sprite.get_pos opponent
  and (mx,my)=Sprite.get_pos sprite in
  try atan ((float_of_int(my)-.float_of_int(oy))/.float_of_int (abs (mx-ox)))
  with Division_by_zero -> pi /. 2.0
;;

(** Aiming: If angle between me and my oponnent don't match my crosshair - correct it*) 
let ai_vy pl_no = 
  let sprite = Hashtbl.find Player.players pl_no in
  let angle = (Sprite.get_data sprite).Player.angle in
  let direction = Player.get_direction sprite in
    if angle +. (calculate_angle pl_no)>0.0 then -1 else 1
;;

let wants_to_jump pl_no = if Random.int 100 < 10 then true else false;;

let change_weapon pl_no = if Random.int 200 <10 then true else false;;

let fire pl_no = if Random.int 1000 < 50 then true else false;;

get_vx := ai_vx;;
get_vy := ai_vy;;
get_jump := wants_to_jump;;
get_change := change_weapon;;
get_fire := fire;;
