Input.set_mode (Input.add_mode "dummy" (fun _ -> ()));;

let contexts = ref [];;
let video_change_fun () =
  contexts := Helpers.vertical_split ()
;;
Helpers.add_video_mode_var video_change_fun;;

Parser.parse "exec \"../Data/default.txt\"" ();;

let sg = Sprite.Set.create 10;;
let corn_img = Video.load_image "../Data/block.png";;

let set (pl_no, pos) = Sprite.create pl_no corn_img pos
and get spr = (Sprite.get_data spr, Sprite.get_pos spr) in
let int_pair = Serialize.pair Serialize.int Serialize.int in
let ser = Serialize.pair Serialize.int int_pair in
Helpers.add_sprite_set_info (Serialize.map ser set get) sg;;

let pl_change_fun pl_no local = function
  | true ->
      ignore (Sprite.create ~set:sg pl_no corn_img (0, 0));
      if local then video_change_fun ()
  | false ->
      let check spr = if Sprite.get_data spr = pl_no then 
        Sprite.Set.del sg spr 
      in Sprite.Set.iter check sg
;;

Net.init pl_change_fun;;
Helpers.add_chat ();;

let get_vy = Helpers.add_action_pair true "s" "n"
and get_vx = Helpers.add_action_pair true "e" "w";;

Parser.parse "exec \"Data/dummy.txt\"" ();;

let draw_fun () =
  Video.fill (0, 0, 0);
  let draw_context on =
    Video.fill ~on (0, 127, 0);
    Sprite.Set.iter (Sprite.draw ~on) sg
  in List.iter draw_context !contexts;
;;

let new_frame_fun _ =
  let move_player sprite =
    let pl_no = Sprite.get_data sprite in
    Sprite.move sprite ((get_vx pl_no), (get_vy pl_no))
  in Sprite.Set.iter move_player sg
;; 

Helpers.main new_frame_fun draw_fun;;
