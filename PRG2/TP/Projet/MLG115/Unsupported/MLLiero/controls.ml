Input.set_mode (Input.add_mode "liero" (fun _ -> ()));;

let (ai_vx, ai_vy, ai_jump, ai_fire, ai_change) as ai =
    (ref (fun _ -> 0), ref (fun _ -> 0), ref (fun _ -> false),
     ref (fun _ -> false), ref (fun _ -> false))
;;

let pl_vx = Helpers.add_action_pair true "e" "w";;
let pl_vy = Helpers.add_action_pair true "s" "n";;
let pl_jump = Helpers.add_action true "jump";;
let pl_change = Helpers.add_action true "change";;
let pl_fire = Helpers.add_action true "fire";;

let get_vx pl = if pl >= 0 then pl_vx pl else !ai_vx pl;;
let get_vy pl = if pl >= 0 then pl_vy pl else !ai_vy pl;;
let get_jump pl = if pl >= 0 then pl_jump pl else !ai_jump pl;;
let get_change pl = if pl >= 0 then pl_change pl else !ai_change pl;;
let get_fire pl = if pl >= 0 then pl_fire pl else !ai_fire pl;;

