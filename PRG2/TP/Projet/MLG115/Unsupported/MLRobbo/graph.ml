(***************************************************************)
(* RYSUNKI *)
let frame_width = 32;;
let frame_height = 32;;
let pos2graph (x, y) = (x * frame_width, y * frame_height);;

let graph_dir = "graph/atari/";;
let load_image file_name = Video.optimize (Video.color_key (Video.load_image (graph_dir ^ file_name)));;
let create_sprite image pos = 
  let gpos = pos2graph pos in
  Sprite.create () image ~width:frame_width gpos
;;

let console_context = Video.create_context 0 0 800 553 (0, 0);;
let hide_console () = Video.fill ~on:console_context (0, 0, 0);;

(***************************************************************)
(* KONTEKSTY GRAFICZNE *)
let context_height = 512;;
let level_context = Video.create_context 144 14 512 context_height (0, 0);;
let data_context = Video.create_context 112 554 576 32 (0, 0);;

(***************************************************************)
(* ¦LEDZEINIE OBIEKTU NA PLANSZY *)
let followed = ref 0;;
let cam_speed = 8;;
let act_cam_speed act follow = 
  let min = 0 and max = 480 in
  let dmin = 160 in
  let dmax = context_height - dmin in
  let d = follow - act in
  if d < dmin then
    if act > min then -cam_speed
    else 0
  else if d > dmax then 
    if act < max then cam_speed
    else 0
  else 0
;;
let follow (_, y) = followed := y;;
let cam_default () = Video.set_cam_pos ~on:level_context (0, 0);;
let follow_action () =
  let (_, act) = Video.get_cam_pos ~on:level_context () in
  let (_, y) = pos2graph (0, !followed) in
  let ny = act_cam_speed act y in
  Video.move_cam ~on:level_context (0, ny);
;;
