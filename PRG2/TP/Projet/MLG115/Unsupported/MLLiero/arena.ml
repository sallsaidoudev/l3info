let set = Sprite.Set.create 64;;
Sprite.Set.set_collision set 64 64;;
let stone_img = Video.optimize (Video.color_key (Video.load_image "Data/stone_big-t.png"));;


for i = 1 to 50 do
  let new_stone = (*Video.duplicate_surface*) stone_img in
  ignore (Sprite.create ~set () new_stone (Random.int 800, Random.int 600))
done;;

let draw on =
  Sprite.Set.iter (Sprite.draw ~on) set
;;
