Helpers.prepare_video_modes Helpers.vertical_split;;
Parser.parse "exec \"../../Data/default.txt\"" ();;

let sg = Sprite.set_create 20;;
Sprite.set_set_collision sg 100 100;;

let create_sprite =
  let head_img = Video.load_image "Data/go.png" in
  let create_aux () =
    Sprite.create ~set:sg (0, 0) head_img ~width:139 (Random.int 100, Random.int 100)
  in create_aux
;;

let snake_len = 1;;

let collision_fun spr1 _ =
  Sprite.set_animation_frame spr1 1
;;

let players = Hashtbl.create 10;;
Sprite.add_collision_fun sg sg collision_fun;;

let create_player pl_no =
  let start_point = (100, 100) in
  let sprite = create_sprite () in
  let ret = (sprite, ()) in
  Hashtbl.add players pl_no ret
;;

let delete_player pl_no =
  Hashtbl.remove players pl_no;
;;

Helpers.add_net create_player delete_player true;;

Input.set_mode (Input.add_mode "snake" (fun _ -> ()));;

let get_acc_y = Helpers.add_action_pair true "down" "up"
and get_acc_x = Helpers.add_action_pair true "right" "left";;

Parser.parse "exec \"Data/snake.txt\"" ();;

let draw_fun context_list =
  let draw_context (pl_no, context) =
    let (sprites, _) = Hashtbl.find players pl_no in
    let head_point = Sprite.get_pos sprites in
    Video.set_cam_center ~context head_point;
    Video.fill ~context ((0, 0, 127) : Sdlvideo.color);
    Sprite.set_iter (Sprite.draw ~context) sg
  in
  List.iter draw_context context_list
;;

let move_player pl_no (sprite, _) =
  Sprite.move sprite (get_acc_x pl_no, get_acc_y pl_no)
;;

let new_frame_fun _ =
  Hashtbl.iter move_player players;
  Sprite.set_iter (fun spr -> Sprite.set_animation_frame spr 0) sg;
  Sprite.set_iter Sprite.check_collisions sg
;; 

Helpers.main 0.04 new_frame_fun draw_fun;;
