
(*----------- pilka -----------------------------*)
type bonus = 
{ 
	mutable xy: float * float;
	mutable old_xy: float * float;
	mutable dxy: float * float;
}
;;

let i = int_of_float ;;
let f = float_of_int ;;

let bonusy = Sprite.Set.create 10;;


let my_bonus xy= { dxy = (0.0,-2.0); xy = xy; };;

let img_bonus1 = Video.load_image ~alpha:true "./Data/bonus1.png";;

let get_dxy pilka = (Sprite.get_data pilka).dxy;;
let set_dxy w pilka = (Sprite.get_data pilka ).dxy <- w;;
let get_xy pilka = (Sprite.get_data pilka).xy;;
let set_xy w pilka = (Sprite.get_data pilka ).xy <- w;;
let get_old_xy pilka = (Sprite.get_data pilka).old_xy;;
let set_old_xy w pilka = (Sprite.get_data pilka).old_xy <- w;;


(*------------ kolizje --------------------------*)
let ile_kolizji= ref 0;;


let c_fun is_odbicie oblicz_odbicie udezyla pilka obj =
	let (dx,dy) = get_dxy pilka in 
	let is	= is_odbicie pilka obj (dx,dy) in
	let (zx,zy) = oblicz_odbicie pilka (dx,dy) obj 
	in
		if is then 
		(
			incr ile_kolizji;
			udezyla pilka obj;
			set_dxy (zx,zy) pilka;			(* zmien kierunek lotu *)
		) else ()
;;

let sprawdz_kolizje _ =
	ile_kolizji:=0;
	Sprite.Set.iter Sprite.check_collisions pilki;
	if !ile_kolizji != 0 then true else false
;;


(* ------------ init ------------------------*)

let start_ = ref 1;;



let is_ball _ = 
	let ile = ref 0 in
	let licz spr = incr ile in
	Sprite.Set.iter licz pilki;
	(!ile + !start_ > 0)
;;

let init _ =
	start_:= 1;
	Sprite.Set.clear pilki;
	Sprite.Set.set_collision pilki 40 30;
	Sprite.Set.set_boundary pilki 0 0 Board.dimX (Board.dimY + 100);
(*	Sprite.create ~set:pilki (my_pilka()) img_pilka1 (200,400);*)
	Sprite.add_collision_fun pilki Board.sciany true (c_fun Board.is_odbicie Board.oblicz_odbicie Board.udezyla);
	Sprite.add_collision_fun pilki Board.klocki true (c_fun Board.is_odbicie Board.oblicz_odbicie Board.udezyla);
	Sprite.add_collision_fun pilki Palka.palki  true (c_fun Palka.is_odbicie Palka.oblicz_odbicie Palka.udezyla);
	()
;;

let is_start _ = (!start_ = 0);;

let start x y = 
	start_:=0;
	ignore (Sprite.create ~set:pilki (my_pilka (f x,f y)) img_pilka1 (0,0) )
;;


(*--------------------------------------------*)

let draw _ = 
	Sprite.Set.iter Sprite.draw pilki;
(*	Sprite.Set.iter Sprite.draw klocki;*)
;;

let move_pilki _ =
	let move p = 
		let (fx,fy) = (get_dxy p) in
		let (x,y) = (get_xy p) in
		let (nx,ny) = (x +. fx, y +. fy) in
		set_old_xy (x,y) p;
		set_xy (nx,ny) p;
		Sprite.move_to p (i nx,i ny);
(*		set_old_xy (get_dxy p) p;*)
		if not (Sprite.in_bounds p) then Sprite.Set.del pilki p 
	in 
		Sprite.Set.iter move pilki;
;;
let move_back_pilki _ =
	let moveback pilka =
		let (x,y) = get_old_xy pilka in
			set_xy (x,y) pilka;
			Sprite.move_to pilka (i x,i y)
	in
		Sprite.Set.iter moveback pilki;
;;


let rec frame a = 
	move_pilki();
	if sprawdz_kolizje() then (move_back_pilki(); frame a) else ()
;;



let load_level _ = init();;

init();;

