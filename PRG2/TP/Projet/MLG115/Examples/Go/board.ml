let img = Video.optimize (Video.color_key (Video.load_image "Data/go.png"));;
let width = 139;;

let stones = Sprite.Set.create 10;;
let mouse_img = Video.optimize (Video.color_key (Video.load_image "Data/go.png"));;
let mouse_spr = Sprite.create ~width () mouse_img (-200, -200);;

let draw _ = 
  Video.fill (242, 210, 110);
  Sprite.Set.iter Sprite.draw stones;
  Sprite.draw mouse_spr
;;

let mouse_move x y player may_put =
  Sprite.set_animation_frame mouse_spr player;
  Sprite.move_to mouse_spr (x - 70, y - 69);
  Sdlvideo.set_alpha mouse_img.Video.surf (if may_put then 192 else 64)
;;

let put_stone x y player remove =
  let stone = Sprite.create ~set:stones ~width () img (x - 70, y - 69) in
  Sprite.set_animation_frame stone player;
  let remover position sprite =
    let (x, y) = Sprite.get_pos sprite in
    if (x + 70, y + 69) = position then
      Sprite.Set.del stones sprite
  in
  List.iter (fun pos -> Sprite.Set.iter (remover pos) stones) remove
;;
