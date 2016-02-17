let img = Video.optimize (Video.color_key (Video.load_image "Data/ammo.png"));;

let ammo = Sprite.Set.create 1000;;
Sprite.Set.set_collision ammo 50 40;;
Sprite.Set.set_boundary ammo (-500) (-400) 500 300;;


let set (vel, pos) = Sprite.create vel img pos
and get spr = (Sprite.get_data spr, Sprite.get_pos spr) in
let int_pair = Serialize.pair Serialize.int Serialize.int in
let ser = Serialize.pair int_pair int_pair in
Helpers.add_sprite_set_info (Serialize.map ser set get) ammo;;


let create (x, y) vx vy =
  ignore (Sprite.create ~set:ammo (vx, vy) img (x + 24, y))
;;

let frame () =
  let move sprite =
    let (vx, vy) = Sprite.get_data sprite in
    Sprite.move sprite (vx, vy);
    if not (Sprite.in_bounds sprite) then Sprite.Set.del ammo sprite else ();
  in
  Sprite.Set.iter move ammo;
;;

let draw () = 
  Sprite.Set.iter Sprite.draw ammo;
;;
