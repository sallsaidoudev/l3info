let img =  (Video.load_image  "Data/enemy.png");;
let img = Video.optimize ~alpha:true img;;
let enemy = Sprite.Set.create 10000;;
Sprite.Set.set_collision enemy 40 30;;
Sprite.Set.set_boundary enemy (-600) (-600) 600 300;;


let set (vel, pos) = Sprite.create vel img pos
and get spr = (Sprite.get_data spr, Sprite.get_pos spr) in
let int_pair = Serialize.pair Serialize.int Serialize.int in
let ser = Serialize.pair int_pair int_pair in
Helpers.add_sprite_set_info (Serialize.map ser set get) enemy;;

let send = Net.add_server_broadcast Serialize.int Random.init in
Net.add_synchronizer (fun pl_no -> send (Random.int 1000));;

let create (x, y) vx vy =
  ignore (Sprite.create ~set:enemy (vx, vy) img (x + 24, y))
;;

let collision_fun enemy_spr ammo =
  Sprite.Set.del enemy enemy_spr
;;

Sprite.add_collision_fun enemy Ammo.ammo true collision_fun;;

let frame fr_no =
  if fr_no mod 10 = 0 then 
    create (Random.int 600 - 300, -350) (Random.int 3 - 1) (Random.int 3 + 1);
  let move sprite = 
    let (vx, vy) = Sprite.get_data sprite in
    Sprite.move sprite (vx, vy);
    if not (Sprite.in_bounds sprite) then Sprite.Set.del enemy sprite
  in
  Sprite.Set.iter move enemy;
  Sprite.Set.iter Sprite.check_collisions enemy;
;;

let draw () = Sprite.Set.iter Sprite.draw enemy;;
