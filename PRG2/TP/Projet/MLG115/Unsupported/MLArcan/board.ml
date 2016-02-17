
let dimX = 640;;
let dimY = 480;;

let in_X = 20;;
let in_W = dimX - (20 * 2);;

let max_plansz = 3;;


let i = int_of_float;;
let f = float_of_int;;
(* ----------board object  --------------------------*)
type b_obj = { 
	(* odbicie ja_spr -> pilka -> dxy -> w 	
		ja_spr - np.:  sprite klocek, sprite sciana
		pilka -  sprite pilka
		dxy - wartosc wektora ruchu przed odbiciem
		zwraca wektor odbicia*)
	odbicie :'b. b_obj Sprite.t -> 'b Sprite.t->  float * float -> float * float; 
	(* udezyl ja_spr -> pilka -> unit 
		funkcja wykonywana gdzy pilka udezyla dany obiekt (ja_spr) *)
	udezyl  :'b. b_obj Sprite.t -> 'b Sprite.t->  unit;
}
;;


(* ----------- klocki ----------------------------*)
let klocki = Sprite.Set.create 10;;

let is_klocki _ = 
	let ile = ref 0 in
	let licz sprite = incr ile in
	Sprite.Set.iter licz klocki;
	(!ile > 0) 
;;

(*let img_klocek1 = Video.load_image ~alpha:true "./Data/ala.png";;*)
let img_klocek1 = Video.load_image  "./Data/klocek2.png";;

let odbicie_klocek klocek pilka (fx,fy)=  
(* troche dziwnie skomplikowana funkcja obliczajaca wektor odbicia o klocka *)
	let (dx,dy) = (i fx,i fy) in
	let (px,py) = Sprite.get_pos  pilka in
	let (pw,ph) = Sprite.get_size pilka in
	let (kx,ky) = Sprite.get_pos  klocek in
	let (kw,kh) = Sprite.get_size klocek in
	let (px,py) = (px + (pw/2),py + (ph/2)) in
	let (dx,dy) = (-dx,-dy) in
	let (kx,ky) = (kx - px,ky - py) in
	let spr_po_y kx (dx,dy) o1 o2  =
		let f x = float_of_int x in
		let oblicz_t a b = ( if b = 0.0 then 1000.0 else a /. b) in
		let spr_zak a o1 o2 = if (o1 > o2) then (o2 <= a && a <= o1) 
						   else (o1 <= a && a <= o2) 
		in
			let t = oblicz_t (f kx) (f dx) in
			if t < 1000.0 then spr_zak (t *. (f dy)) (f o1) (f o2) else false
	in
	let spr_po_x ky (dx,dy) o1 o2  = spr_po_y ky (dy,dx) o1 o2 
	in
		let a = -(pw/2) in
		if dx < 0 && spr_po_y kx      (dx,dy) (ky+a) (ky+kh-a) then (-.fx,fy) else (* uwaga !!!!*)
		if dx > 0 && spr_po_y (kx+kw) (dx,dy) (ky+a) (ky+kh-a) then (-.fx,fy) else (* zmiana znaku*)
		if dy < 0 && spr_po_x ky      (dx,dy) (kx+a) (kx+kw-a) then (fx,-.fy) else (* dla dx i dy *)
		if dy > 0 && spr_po_x (ky+kh) (dx,dy) (kx+a) (kx+kw-a) then (fx,-.fy) else 
		(-.fx,-.fy)
;;

let my_klocek = { 
	odbicie = odbicie_klocek; 
	udezyl = (fun a _ ->
	 Player.add_score 10;
	 Sprite.Set.del klocki a;
(*	 Sprite.set_animation_frame a ((Sprite.get_animation_frame a)+1);*) ());
};;

let init_klocki _ =
	Sprite.Set.clear klocki;
	Sprite.Set.set_collision klocki 40 30;
;;


(*----------- sciany -----------------------------*)
let sciany = Sprite.Set.create 10;;

let img_sciana1 = Video.load_image "./Data/sciana1.png";;
let img_sciana2 = Video.load_image "./Data/sciana2.png";;
let img_sciana3 = Video.load_image "./Data/sciana3.png";;


let my_sciana (wx,wy)  = { odbicie = (fun _ _ (dx,dy) -> (wx*.dx,wy*.dy)); udezyl = (fun  _ _ -> ());} ;;

let init_sciany _ =
	ignore(
	Sprite.Set.clear sciany;);
	ignore(
	Sprite.create ~set:sciany (my_sciana (-1.0,1.0)) img_sciana1 (0,0),
	Sprite.create ~set:sciany (my_sciana (-1.0,1.0)) img_sciana2 (dimX-20,0),
	Sprite.create ~set:sciany (my_sciana (1.0,-1.0)) img_sciana3 (0,0),
(*	Sprite.create ~set:sciany (my_sciana (1.0,-1.0)) img_sciana3 (0,580),*)
	Sprite.Set.set_collision sciany 40 30
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

let is_odbicie plika myObj dw= true;;


(*--------- load level -------------------------------*)


(* funkcja wgrywa plansze *)

let load_board k =
	let pin = open_in ("./Data/plansza."^(string_of_int (k mod max_plansz))) in
    let px = int_of_string (input_line pin) in
    let py = int_of_string (input_line pin) in
    let dx = int_of_string (input_line pin) in
    let dy = int_of_string (input_line pin) in
    let w = int_of_string (input_line pin) in
    let h = int_of_string (input_line pin) in
    let rec load_brd x y =
        if x>w then load_brd 1 (y+1) else
        if y>h then () else
        begin
			let nx = ref (x+1) in
            let c=input_char pin in
            if c = '.' then ()  else
            if c = '#' then ignore(Sprite.create ~set:klocki my_klocek img_klocek1 ((x-1)*dx+px,(y-1)*dy+py)) 
			else decr nx;
			load_brd !nx y;
        end
    in
        load_brd 1 1;
;;


(*--------- standard -----------------------------------*)

let draw _ = 
	Sprite.Set.iter Sprite.draw sciany;
	Sprite.Set.iter Sprite.draw klocki;

(*	Sprite.Set.iter Sprite.draw klocki;*)
;;

let frame _ = ()
;;

let load_level x = 
	init_klocki(); 
	load_board x
;;

let init _ =
	init_sciany();
	load_level 0;
;;

init();;



