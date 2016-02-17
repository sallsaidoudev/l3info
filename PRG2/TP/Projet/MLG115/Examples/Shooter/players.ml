let hero_img = Video.optimize ~alpha:true (Video.load_image "Data/hero.png");;
Video.set_cam_pos (-400, -300);;

let table = Sprite.Table.create 10;;
let set = Sprite.Table.set table;;
Sprite.Set.set_collision set 40 30;;
Sprite.Set.set_boundary set (-400) (-300) 400 300;;

let pl_change_fun pl_no _ = function
  | true -> 
      let sprite = Sprite.create (0, 0) hero_img (0, 0) in
      Sprite.Table.add table pl_no sprite
  | false ->
      Sprite.Table.del table pl_no
;;

Net.init pl_change_fun;;

let get_ay = Helpers.add_action_pair true "s" "n"
and get_ax = Helpers.add_action_pair true "e" "w";;

let fire_pressed = Helpers.add_action true "fire";;

Parser.parse "exec \"Data/shooter.txt\"" ();;

let draw () =
  Sprite.Set.iter Sprite.draw set
;;

let frame fr_no =
  let move pl_no sprite (vx, vy) =
    let vx, vy = (vx + 2 * (get_ax pl_no)), (vy + 2 * (get_ay pl_no)) in
    let dec i = if i > 0 then i - 1 else if i < 0 then i + 1 else 0 in
    let vx, vy = dec vx, dec vy in
    let vx, vy = Sprite.move_in_bounds sprite (vx, vy) in
    Sprite.set_data sprite (vx, vy);
    if fire_pressed pl_no then begin
      let (x, y) = Sprite.get_pos sprite in
      Ammo.create (x - 16, y) 0 (-16);
      Ammo.create (x + 16, y) 0 (-16);
      Ammo.create (x - 16, y) (-12) (-8);
      Ammo.create (x + 16, y) 12 (-8);
    end
  in
  Sprite.Table.iter_data move table
;; 
