let vec_length (x, y) = sqrt (x*.x+.y*.y);;

let can_go sprite (sx,sy) obstacle_types =
  Sprite.move sprite (int_of_float sx,int_of_float sy);
  let does_collide_with sprite obstacle=
    (List.length(Sprite.collides_with sprite true obstacle)>0) in
  let wynik=not (List.fold_left (||) (not (Sprite.in_bounds sprite)) (List.map (does_collide_with sprite) obstacle_types)) in
  Sprite.move sprite (-int_of_float(sx),-int_of_float(sy)); wynik;;

let rec move_slowly sp (vx,vy)=
    let (vx,vy)=(int_of_float(vx),int_of_float(vy)) in
    let vx2=if (abs vx) > 5 then if vx>0 then vx-5 else vx+5 
                            else 0 
    in
    let vy2=if (abs vy) >5 then if vy>0 then vy-5 else vy+5 
                           else 0 
    in
    if (abs vx2)>0 or (abs vy2)>0 then
    begin
      Sprite.move sp (vx-vx2,vy-vy2); Sprite.check_collisions sp; move_slowly sp (float_of_int(vx2),float_of_int(vy2))
    end 
    
    else 
    begin
      Sprite.move sp (vx,vy); Sprite.check_collisions sp;
    end;;

let rec move_as_possible sprite (vx,vy) obstacles =
   if (vec_length (vx,vy))<0.5 then ()
     else
   if (can_go sprite (vx,vy) obstacles) then 
     Sprite.move sprite (int_of_float(vx-.0.5),int_of_float(vy-.0.5)) 
   else
     move_as_possible sprite (vx*.0.5,vy*.0.5) obstacles;;
     
let pi=3.14;;


let bounce sprite (sx,sy) obstacles =

  if vec_length (sx,sy)<10.0 then (0.0, 0.0) else
  let new_vel = (sx,-.0.3*.sy) in 
  if can_go sprite new_vel obstacles then new_vel else 
  let new_vel = (-.0.3*.sx,sy) in 
  if can_go sprite new_vel obstacles then new_vel else
  (-.0.3*.sx,-.0.3*.sy);;   

let ideal_bounce sprite (sx,sy) obstacles =
  let new_vel = (sx,-.sy) in 
  if can_go sprite new_vel obstacles then new_vel else 
  let new_vel = (-.sx,sy) in 
  if can_go sprite new_vel obstacles then new_vel else
  (-.sx,-.sy);;   

let draw_boundaries context=
  Video.fill ~on:context ~rect:(Sdlvideo.rect 0 1 800 2) (127,127,127);
  Video.fill ~on:context ~rect:(Sdlvideo.rect 0 0 2 600) (127,127,127);
  Video.fill ~on:context ~rect:(Sdlvideo.rect 797 0 2 600) (127,127,127);
  Video.fill ~on:context ~rect:(Sdlvideo.rect 0 598 800 2) (127,127,127)
;;
