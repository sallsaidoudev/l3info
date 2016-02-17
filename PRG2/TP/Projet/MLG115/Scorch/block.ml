

let blocks = Sprite.Set.create 1;;
Sprite.Set.set_collision blocks 100 100;;

let clear () = Sprite.Set.clear blocks;;

let add surface pos (destr:bool) =
  ignore (Sprite.create ~set:blocks destr surface pos)
;;

let destr block = Sprite.get_data block;;

let hit_by_missle block missle =
  ()
;;

let frame () = ();;

let draw () =
  Sprite.Set.iter Sprite.draw blocks 
;;
