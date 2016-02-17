let contexts = ref [];;

let video_change_fun () = 
  contexts := Helpers.vertical_split ()
;;
Helpers.add_video_mode_var video_change_fun;;

let img = Video.load_image "../Data/block.png";;

let spr_set = Sprite.Set.create 20;;


for i = 1 to 100 do
  let x = Random.int 2000 - 1000
  and y = Random.int 2000 - 1000 in
  ignore (Sprite.create ~set:spr_set () img (x, y))
done;


Parser.parse "exec \"../Data/default.txt\"" ();;

let create_sprite =
  let head_img = Video.optimize (Video.color_key (Video.load_image "Data/head.png"))
  and tail_img = Video.optimize (Video.color_key (Video.load_image "Data/tail.png")) in
  let img j = if j = 0 then head_img else tail_img in
  let create_aux spr_set elem =
    Sprite.create ~set:spr_set (0, 0) (img elem) ~width:32 (100, 100)
  in create_aux
;;

let snake_len = 7;;

let collision_fun spr1 _ =
  Sprite.set_animation_frame spr1 1
;;

let players = Hashtbl.create 10;;

(* <World_state> *)
let players_send =
  let players_ser = Serialize.list (Serialize.pair Serialize.int
    (Serialize.list (Serialize.pair (Serialize.pair Serialize.int
    Serialize.int) (Serialize.pair Serialize.int Serialize.int))))
  and players_recv lst =
    let iterator (pl_no, lst) =
      let (sprites, _) = Hashtbl.find players pl_no in
      let rec set elem_no = function
          [] -> ()
        | (pos, vel) :: t -> 
            Sprite.move_to sprites.(elem_no) pos;
            Sprite.set_data sprites.(elem_no) vel;
            set (elem_no + 1) t
      in set 0 lst
    in List.iter iterator lst in
  let players_info = Net.add_server_to_client players_ser players_recv in
  let players_send_aux pl_no =
    let folder pl_no spr lst = 
      let mapper spr = (Sprite.get_pos spr, Sprite.get_data spr) in
      let (sprites, _) = Hashtbl.find players pl_no in
      (pl_no, List.map mapper (Array.to_list sprites)) :: lst in
    players_info [pl_no] (Hashtbl.fold folder players [])
  in players_send_aux
;;
(* </World_state> *)

let player_change_fun pl_no local = function
  | true ->
      Log.debug (Printf.sprintf "New_pl : %i, %b" pl_no local);
      players_send pl_no;
      let start_point = (100, 100) in
      let spr_set = Sprite.Set.create 10 in
      Sprite.Set.set_collision spr_set 32 32;
      Sprite.Set.set_boundary spr_set (-1000) (-1000) 1000 1000;
      let initer j = create_sprite spr_set j in
      let sprites = Array.init snake_len initer in
      let ret = (sprites, spr_set) in
      let set_collide _ (_, a_spr_set) =
        Sprite.add_collision_fun a_spr_set spr_set true collision_fun;
        Sprite.add_collision_fun spr_set a_spr_set true collision_fun
      in
      Hashtbl.iter set_collide players;

      Hashtbl.add players pl_no ret;
      if local then video_change_fun ()
  | false ->
      Log.debug (Printf.sprintf "b:%b" local);
      Hashtbl.remove players pl_no;
      if local then video_change_fun ()
;;

Net.init player_change_fun;;
Helpers.add_chat ();;

Input.set_mode (Input.add_mode "snake" (fun _ -> ()));;

let get_acc_y = Helpers.add_action_pair true "down" "up"
and get_acc_x = Helpers.add_action_pair true "right" "left";;

Parser.parse "exec \"Data/snake.txt\"" ();;

let draw_fun () =
  let draw_on on pl_no =
    let (sprites, _) = Hashtbl.find players pl_no in
    let head_point = Sprite.get_pos sprites.(0) in
    Video.set_cam_pos_center ~on head_point;
    Video.fill ~on (0, 0, 127);
    Sprite.Set.iter (Sprite.draw ~on) spr_set;
    let draw_player _ (_, spr_set) =
      Sprite.Set.iter (Sprite.draw ~on) spr_set
    in
    Hashtbl.iter draw_player players
  in
  Video.fill (0, 0, 0);
  List.iter2 draw_on !contexts (Net.get_local_players ())
;;

let move_player pl_no (sprites, _) =
  let dist_to_force (x, y) =
    let opt_dist = 32 in
    let dtf_aux x =
      if x > 0 then x - opt_dist else if x = 0 then 0 else x + opt_dist
    in dtf_aux x, dtf_aux y
  in
  let (++) (a1, a2) (b1, b2) = (a1 + b1, a2 + b2)
  and (--) (a1, a2) (b1, b2) = (a1 - b1, a2 - b2)
  and ( ** ) (a1, a2) d = (a1 * d, a2 * d)
  and (//) (a1, a2) d = (a1 / d, a2 / d) in
  for i = 0 to snake_len - 1 do
    let pos = Sprite.get_pos sprites.(i) in
    let front_force =
      if i = 0 then (get_acc_x pl_no, get_acc_y pl_no) ** 60 else
      dist_to_force ((Sprite.get_pos sprites.(i - 1)) -- pos)
    and back_force =
      if i = snake_len - 1 then (0, 0) else
      dist_to_force (pos -- (Sprite.get_pos sprites.(i + 1)))
    in
    let force = (front_force // 2) ++ (back_force // 6) in
    let new_vel = ((Sprite.get_data sprites.(i)) ++ force) ** 4 // 5 in
    Sprite.set_data sprites.(i) new_vel;
    ignore (Sprite.move_in_bounds sprites.(i) (new_vel // 10))
  done
;;

let new_frame_fun _ =
  Hashtbl.iter move_player players;
  let iterator _ (_, spr_set) = Sprite.Set.iter 
      (fun spr -> Sprite.set_animation_frame spr 0) spr_set
  in
  Hashtbl.iter iterator players;
  let iterator _ (_, spr_set) = 
    Sprite.Set.iter Sprite.check_collisions spr_set 
  in
  Hashtbl.iter iterator players
;; 

Helpers.main new_frame_fun draw_fun;;

