type t=
{
  power:int;
};;

let explosion_set=Sprite.Set.create 32;;

Sprite.Set.set_collision explosion_set 16 16;;

let explosion_img=Video.load_image "Data/explosion.png";;

let get_power explosion=(Sprite.get_data explosion).power;;

let new_explosion pos power =
  let explosion=Sprite.create ~set:explosion_set {power=power} ~width:16 explosion_img pos in
    Sprite.set_animation_frame explosion 15;;

let process explosion=
   let animation_frame=Sprite.get_animation_frame explosion in
     if animation_frame>2 then 
       Sprite.set_animation_frame explosion (animation_frame-1)
     else
       Sprite.Set.del explosion_set explosion;;
