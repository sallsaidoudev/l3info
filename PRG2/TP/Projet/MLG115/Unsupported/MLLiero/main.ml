let contexts = ref [];;

(* A context and a stat context for each player *)
let video_change_fun () =
  let vertical_split () =
    let res_x, res_y = Video.get_resolution () in
    let local_players = List.length (Net.get_local_players ()) in
    if local_players = 0 || res_x < 3 then [] else
    let cnt_w = res_x / local_players - 2 in
    let rec set_context acc i = 
      if i = local_players then acc else
      let cnt_x = (cnt_w + 2) * i + 1 in
      let context = Video.create_context cnt_x 0 cnt_w (res_y - 100) (0, 0) 
      and stat_context = 
        Video.create_context cnt_x (res_y - 100) cnt_w 100 (0,0) 
      in
      set_context ((context, stat_context, i) :: acc) (i + 1)
    in
    set_context [] 0
  in
  contexts := vertical_split ()
;;

Helpers.add_video_mode_var video_change_fun;;
Parser.parse "exec \"Data/default.txt\"" ();;

let pl_change_fun pl_no local = function
  | true -> Player.create pl_no; if local then video_change_fun ()
  | false -> Player.delete pl_no; if local then video_change_fun ()
;;

Net.init pl_change_fun;;
Helpers.add_chat ();;

Parser.parse "exec \"Data/liero.txt\"" ();;

let draw_fun () =
  Video.fill (0, 0, 0);
  let draw_context (context, stat_context, pl_no) =
    Player.draw_stats (context, stat_context, pl_no);
    Arena.draw context;
    Player.draw (context, stat_context, pl_no);
    Sprite.Set.iter (Sprite.draw ~on:context) Explosion.explosion_set;
    Weapons.draw_all_bullets context;
  in List.iter draw_context !contexts
;;

let new_frame_fun _ =
  Sprite.Set.iter (Zimm_bullet.process) Zimm_bullet.bullet_set;
  Sprite.Set.iter Explosion.process Explosion.explosion_set;
  Weapons.Zimm.process Weapons.zimm;
  Player.frame ()
;; 

Random.self_init ();;

Helpers.main new_frame_fun draw_fun;;
