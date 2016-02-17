
let my_Y = Board.dimY - 30;;

(* ----------palka object  --------------------------*)
type p_obj = { 
	(* odbicie ja_spr -> pilka -> dxy -> w 	
		ja_spr - np.:  sprite klocek, sprite sciana
		pilka -  sprite pilka
		dxy - wartosc wektora ruchu przed odbiciem
		zwraca wektor odbicia*)
	odbicie :'b. p_obj Sprite.t -> 'b Sprite.t->  float * float -> float * float; 
	(* udezyl ja_spr -> pilka -> unit 
		funkcja wykonywana gdzy pilka udezyla dany obiekt (ja_spr) *)
	udezyl  :'b. p_obj Sprite.t -> 'b Sprite.t->  unit;
}
;;


let i = int_of_float ;;

(***************************************)
let get_center sprite = 
	let (x,y) = Sprite.get_pos  sprite in
	let (w,h) = Sprite.get_size sprite 
	in
		(x+w/2,y+h/2)
;;

(* ----------- palka ----------------------------*)
let palki = Sprite.Set.create 10;;

let img_palka1 = Video.load_image "./Data/ala.png";;
let w1 = 60;;

let odbicie mojObj ball (x,y) =
	let (bx,by) = get_center ball in
	let (ox,oy) = Sprite.get_pos  mojObj in
	let (w, h ) = Sprite.get_size mojObj in
	let f = float_of_int in
	let i = int_of_float in
	let nx = bx - ox - w / 2 in
	let t = (f nx) /. (f (w/2)) in
	let d = sqrt (x*.x +. y*.y) 
	in
		if y > 0.0 then ( (sin t) *. d , -. ((cos t) *. d)) else (x,y)
;;

let udezyl palka pilke = 
	let (ox,oy) = Sprite.get_pos pilke in
	let (ow,oh) = Sprite.get_size pilke in
	let (px,py) = Sprite.get_pos palka 
	in
		Sprite.move_to pilke (ox,py - oh)
;;

let my_palka  = { odbicie = odbicie; udezyl = udezyl;} ;;

let init_palki _ =
	ignore(
	Sprite.create ~set:palki my_palka img_palka1 ~width:w1 (Board.dimX/2,my_Y),
	Sprite.Set.set_collision palki 40 30
	)
;;



(*-------- obliczanie wspolczynnika odbicia --------*)
let oblicz_odbicie ball dxy mojObj =
	let obj = Sprite.get_data mojObj 
	in obj.odbicie mojObj ball dxy
;;
let udezyla pilka mojObj =
	let obj = Sprite.get_data mojObj 
	in obj.udezyl mojObj pilka
;; 

let is_odbicie pilka myObj (fx,fy)=
	let (dx,dy) = (i fx,i fy) in
	let (px,py) = Sprite.get_pos  pilka in
	let (w ,h ) = Sprite.get_size pilka in	
	let (nx,ny) = (px+w/2 - dx, py+h/2 -dy) in
	let (x ,y ) = Sprite.get_pos myObj 
	in
		(y>ny)
;;
(*------- moves ----------------------------*)

let move x y =
	let m spr = 
		let (ox,oy)=Sprite.get_pos spr in
		let (w,h) = Sprite.get_size spr in
		let nx = if x+w > Board.in_X + Board.in_W then Board.in_X + Board.in_W - w else
			(if x < Board.in_X then Board.in_X else x) 
		in
			Sprite.move_to spr (nx,oy)
	in
		Sprite.Set.iter m palki
;;

let fire x y =
	
	move x y
;;



(*--------- standard -----------------------------------*)
let an = ref 0;;
let draw () = 
	let anime spr = 
		Sprite.set_animation_frame spr ((!an/3) mod 3);
		incr an in
	Sprite.Set.iter Sprite.draw palki;
	Sprite.Set.iter anime palki;

;;

let frame x =  ()
;;


let init _ =
	init_palki();
;;

init();;
