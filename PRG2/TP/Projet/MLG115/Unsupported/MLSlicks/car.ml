(* Module responsible for all car data: velocity, acceleration, vector, 
 * bouncing etc...
 * Shortly: physics ;)
 *)
 
let _frame_no = 64. (* how many car frames are there *)
and _image = "Data/heads64_24.png"
and _width = 24
and _frontcar = 12. (*Length from middle of the car to front*)
and _backcar = 10.  (*respective*)
;;


let _max_vel = 300.
and _epsilon_vel = 5.
and _ev = 1
;;

let initial_data pl_n  = ((0., 0.), ((_epsilon_vel, _epsilon_vel), ((90., 0.), (pl_n, 0))));;


let accel_level1 = 15.
and accel_level2 = 80.
and accel0 = 20.
and accel1 = 40.
and accel2 = 80.
and accel3 = 170.
and accel4 = 250.
and accpct0 = 5.
and accpct1 = 3. (*TODO*) 
and accpct2 = 1.1
and accpct3 = 0.8
and accpct4 = 0.6
;;

let turn_angle = 2.;;

let max_wall_bounce = 80.
;;


let (//) (a1, a2) d = (a1 /. d, a2 /. d)
and ( ** ) (a1, a2) d = (a1 *. d, a2 *. d)
and (++) (a1, b1) (a2, b2) = (a1 +. a2, b1 +. b2)
;;

(* radius functions concern carthesian axis *)
let to_carthesian (x, y) = if y <> 0. then (x, -. y) else (x, y);;
let from_carthesian (x, y) = if y <> 0. then (x, -. y) else (x, y);;
let to_float (x, y) = (float_of_int x, float_of_int y)
and to_int (a, b) = (int_of_float a, int_of_float b)
and to_ceil (c, d) = (ceil c, ceil d)
;;



let pi = 3.1415926 
and rad = 57.2957804904;;

let gtor grad = grad /. rad 
and rtog rads = rads *. rad;;

let sinus x = sin(gtor x)
and cosinus x = cos(gtor x)
;;

let purp x y = (sqrt((x *. x) +. (y *. y)));;

let get_angle x y p = 
  let asi =  rtog(asin(x /. (purp x y))) in
    if asi = nan then nan
    else
      if x>=0. && y>=0. then asi 
      else if x>=0. && y<0. then 180. -. asi 
      else if x<0. && y<0. then  180. -. asi 
      else mod_float (360. +. asi) 360.
;;

let vector_of_velpair (vx, vy) prev =  (* converts (vx, vy) to (angle, force) *)
 if vx = 0. && vy = 0. then (prev, 0.) else (get_angle vx vy prev, purp vx vy)
;;


let velpair_of_vector (a, f) =  (* converts (angle, force) to (vx, vy) *)
  (f *. sinus(a)  , f *. cosinus(a))
;;

let opposite (a, f) = (mod_float (a +. 180.) 360. , f)
;;

let accel factor frc = 
    if frc = 0. then if factor > 0. then _epsilon_vel else 0. else
    if frc < _epsilon_vel then 0. else
    if frc > _max_vel then _max_vel else
     let pct = 
        if frc < accel0 then accpct0 else
        if frc < accel1 then accpct1 else
        if frc < accel2 then accpct2 else
        if frc < accel3 then accpct3 else
        accpct4 
     in 
     (100. +. (factor *. pct)) *. frc /. 100.
;;

let move_car car (curx, cury) =
  let new_a_f cx cy a f = 
     match (cx, cy) with
     | (0, 0)  -> if f > 0. then (a, accel (-. 1.) f) else (a, 0.)
     | (0, 1)  -> (a, accel 2. f)
     | (0, -1) -> (a, accel (-. 2.) f)
     | (1, 0)  -> if f > 0. then (a +. turn_angle, accel (-. 1.) f) else (a, 0.)
     | (1, 1)  -> (a +. turn_angle, accel 1. f)
     | (1, -1) -> (a +. turn_angle, accel (-. 2.) f)
     | (-1, 0) -> if f > 0. then (a -. turn_angle, accel (-. 1.) f) else (a, 0.)
     | (-1, 1) -> (a -. turn_angle, accel 1. f)
     |    _    -> (a -. turn_angle, accel (-. 2.) f)
 
  in

  (*wyciagamy z samochodu jego aktualne dane*)
  let ((velxx, velyy), ((sidex, sidey), ((prevan, u1), (pn, u2))))  = Sprite.get_data car 
  in
  let (velx, vely) = to_carthesian (velxx, velyy) in 
  let (an, fo) = vector_of_velpair (velx, vely) prevan in
  let (nang, nfor) = new_a_f curx cury an fo in
  let (nvelx, nvely) = from_carthesian (velpair_of_vector (nang, nfor)) in

  let (svx, svy) = to_carthesian(sidex, sidey) in
  let (san, sfo) = vector_of_velpair(svx, svy) 0.  in
  let (nsan, nsfo) = (san, accel (-. 1.) sfo) in
  let (nsidex, nsidey) = from_carthesian (velpair_of_vector (nsan, nsfo)) in
  
  Sprite.set_data car ((nvelx, nvely), ((nsidex, nsidey),((nang, u1),(pn, u2))));
  to_int (((nvelx, nvely) ++ (nsidex, nsidey)) // 10.)
;;


let get_dir car =
   let ((vx, vy), (_, ((pa, _), _))) = Sprite.get_data car in
    
   let get_dir_from_angle ang = 
    let frame_angle =  (360. /. _frame_no) in
    if ang > (360. -. (frame_angle /. 2.)) || ang < (frame_angle /. 2.)
       then 0.
       else mod_float (((ang -. (frame_angle /. 2.)) /. frame_angle) +. 1.) _frame_no
   in
   let (an, _) = vector_of_velpair (to_carthesian (vx, vy)) pa in
   int_of_float (get_dir_from_angle an)
;;

let collision_fun car1 car2 = 
 let ((vxx1, vyy1),((sxx1, syy1),((pa1,u1),(n1,x1)))) = Sprite.get_data car1 
 and ((vxx2, vyy2),((sxx2, syy2),((pa2,u2),(n2,x2)))) = Sprite.get_data car2 
 in
 let (vx1, vy1) = to_carthesian (vxx1, vyy1) 
 and (vx2, vy2) = to_carthesian (vxx2, vyy2) 
 and (sx1, sy1) = to_carthesian (sxx1, syy1) 
 and (sx2, sy2) = to_carthesian (sxx2, syy2)
 in 
 
 
 let (a1, f1) = vector_of_velpair (vx1 +. sx1, vy1 +. sy1) pa1
 and (a2, f2) = vector_of_velpair (vx2 +. sx2, vy2 +. sy2) pa2
 in

 if not(f1 <= _epsilon_vel && f2 <= _epsilon_vel) then
 begin 
  
 let ((sx2, sy2), (sx1, sy1)) = 

   if not (f1=0. && f2=0.) then  
       (((vx1 +. sx1, vy1 +. sy1) // 1.6), velpair_of_vector (opposite (a1, f1 +. _epsilon_vel +. 1.)) // 2.3) 
   else
       (velpair_of_vector (a2, _epsilon_vel +. 2.) , velpair_of_vector (a1, _epsilon_vel +. 2.))
  
  in

  
 let (vx1 ,vy1) = (vx1, vy1) // 6. in

 let (nvx1, nvy1) = from_carthesian (vx1, vy1) 
 and (nvx2, nvy2) = from_carthesian (vx2, vy2) 
 and (nsx1, nsy1) = from_carthesian (sx1, sy1) 
 and (nsx2, nsy2) = from_carthesian (sx2, sy2) 
 in 
 
 let nvel1 = to_int (((nvx1, nvy1) ++ (nsx1, nsy1)) // 10.)
 and nvel2 = to_int (((nvx2, nvy2) ++ (nsx2, nsy2)) // 10.) in
 
 
 ignore(Sprite.move_in_bounds car2 (nvel2));
 ignore(Sprite.move_in_bounds car1 (nvel1));
 Sprite.set_data car1 ((nvx1, nvy1), ((nsx1, nsy1), ((pa1,u1),(n1,x1))));
 Sprite.set_data car2 ((nvx2, nvy2), ((nsx2, nsy2), ((pa2,u2),(n2,x2))));
 (*Log.info (string_of_int(n1)^" -> "^string_of_int(n2));*)

 end
 else 
 begin
  let (posx1, posy1) = to_carthesian (to_float (Sprite.get_pos car1))
  and (posx2, posy2) = to_carthesian (to_float (Sprite.get_pos car2))
  in
  let vector_aux = (posx2 -. posx1, posy2 -. posy1) in
  let vector = from_carthesian vector_aux in
  
  let nvel1 = to_int ((vector ** (-. 1.)) // 10.)
  and nvel2 = to_int (vector // 10.) in
 
  ignore(Sprite.move_in_bounds car2 (nvel2));
  ignore(Sprite.move_in_bounds car1 (nvel1));
  Sprite.set_data car1 ((0., 0.), ((0., 0.), ((pa1,u1),(n1,x1))));
  Sprite.set_data car2 ((0., 0.), ((0., 0.), ((pa2,u2),(n2,x2))));
 (* Log.info (string_of_int(n1)^" -> "^string_of_int(n2));*)
 
  end
;;


let wall_collision car wall = 

 
 let ((vxx, vyy),((sxx, syy),((pa,u),(n,x)))) = Sprite.get_data car in
 
 let (vx, vy) = to_carthesian (vxx, vyy) 
 and (sx, sy) = to_carthesian (sxx, syy) 
 in 
 let (a, f) = vector_of_velpair (vx +. sx, vy +. sy) pa in
 
 if f >= _epsilon_vel then
 begin
 
   let (na, nf) = 
     if f < max_wall_bounce 
       then opposite (a, f) 
       else opposite (a, max_wall_bounce)
   in

   let (sx, sy) = (velpair_of_vector (na, nf)) // 2.3
   and (vx, vy) = (0., 0.) in
   
   let (nvx, nvy) = from_carthesian (vx, vy) 
   and (nsx, nsy) = from_carthesian (sx, sy) 
   in 
   
   let nvel = to_int (((nvx, nvy) ++ (nsx, nsy)) // 10.) in

   ignore(Sprite.move_in_bounds car (nvel));
   Sprite.set_data car ((nvx, nvy), ((nsx, nsy), ((pa,u),(n,x))));
 end
 else
 begin
 
   let (carx, cary) = Sprite.get_pos car 
   and (walx, waly) = Sprite.get_pos wall in
   let (posx, posy) = (carx-walx, cary-waly) in
   let back = 
     if posx < 0 && posy < 0 then (- _ev, 0(*- _ev*)) else
     if posx < 0 && posy >= 0 then (- _ev, 0 (*_ev*)) else
     if posx >= 0 && posy < 0 then (0 (*_ev*), - _ev) else
     (_ev, _ev)
   in
   ignore(Sprite.move_in_bounds car (back));
   Sprite.set_data car ((0., 0.), ((0., 0.), ((pa,u),(n,x))));
 
 end
;;


let get_af car =
  let ((velxx, velyy), ((sidex, sidey), ((prevan, u1), (pn, u2))))  = Sprite.get_data car in
  vector_of_velpair (to_carthesian (velxx +. sidex, velyy +. sidey)) prevan
;;



let if_car_online car (x1, y1) (x2, y2) dir =


  let correct_dir (x1, y1) (x2, y2) dir ca =
    let (al, fl) = vector_of_velpair (x2 -. x1, y2 -. y1) 0. (*random - unimportant*)
    in
     if dir = Arena.LEFT then ( if al >= 180. then ((al -. ca) <= 180. && ca < al) else (ca <= al || ca >= (180. -. al)))
     else (if ca >= 180. then ((ca -. al) <= 180. && al < ca) else (al <= ca || al >= (180. -. ca)))
     
  in

  let point_from_line fa fb (px, py) x1 x2 =
   if x1 = x2  then abs_float (fb -. px)
   else if fa = 0. then abs_float (fb -. py)
   else
    let ha = -. (1. /. fa) in
    let hb = py -. (ha *. px) in 
    let crossx = (hb -. fb) /. (fa -. ha) in
    let crossy = (ha *. crossx) +. hb
    in
    let (_, dist) = vector_of_velpair ((crossx -. px), (crossy -. py)) 17. (*random - unimportant*)
    in dist
  in

  let (fx1, fy1) = to_carthesian(to_float (x1, y1))
  and (fx2, fy2) = to_carthesian(to_float (x2, y2))
  and (fcx, fcy) = to_carthesian(to_float (Sprite.get_pos car))
  and (an, fo) = get_af car in
  let (oan, ofo) = opposite (an, fo)
  in

  if fcx >= ((min fx1 fx2) -. 15.) && fcx <= ((max fx1 fx2) +. 15.) 
            && fcy >= ((min fy1 fy2) -. 15.) && fcy <= ((max fy1 fy2) +. 15.)

  then
  
    let a = if (fx1 = fx2) then nan else (fy2 -. fy1) /. (fx2 -. fx1) in
    let b = if (fx1 = fx2) then fx1 else  fy1 -. (a *. fx1) in
  
  
    let dist_from_cpt = point_from_line a b (fcx, fcy) fx1 fx2 in
     if dist_from_cpt <= (ofo +. 0.) && correct_dir (fx1, fy1) (fx2, fy2) dir an 
     then 
      true
     else false
  else false
;;

