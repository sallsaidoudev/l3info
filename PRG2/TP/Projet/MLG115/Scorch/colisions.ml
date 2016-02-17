
Sprite.add_collision_fun 
  Missle.missles Tank.set true 
  (fun missle tank -> 
    Tank.hit_by_missle tank missle;
    Missle.hit_tank missle )
;;

Sprite.add_collision_fun 
  Missle.missles Block.blocks true
  (fun missle block ->
    Block.hit_by_missle block missle;
    Missle.hit_block missle;
    if Block.destr block then
    Sprite.mask_cut block missle 0)
;;

Sprite.add_collision_fun
  Explosion.expls Tank.set ~alpha_bias:320 true
  (fun expl tank ->
    Tank.hit_by_explosion tank expl)
;;

Sprite.add_collision_fun
  Explosion.expls Block.blocks ~alpha_bias:320 true
  (fun expl block ->
    if Block.destr block then
    Sprite.mask_cut block expl 128)
;;
