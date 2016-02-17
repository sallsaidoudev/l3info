(***************************************************)
(*       termodynamiczna gra zrecznosciowa         *)
(*        wykonana przez Pawla Findeisena          *)
(*   na laboratorium z programowania funkcyjnego   *)
(*           na III roku studiow na UW             *)
(***************************************************)

(*****************  konfiguracja  *****************)
module type KONFIGURACJA =
  sig
    val resx : int (* szerokosc planszy *) (* res - resolution*)
    val resy : int (* wysokosc planszy *)
    val moc : int (* moc pola silowego *)
    val dmin : float (* odleglosc najmniejszego potencjalu *)
    val coddz : float (* wspolczynnik sily oddzialywania *)
    val codp : float (* wspolczynnik sily odpychajacej *)
    val cprzy : float (* wspolczynnik sily przyciagajacej *)
    val masa : float (* poczatkowa! *)
    val dmasa : float (* przyrost *)
    val umasa : float (* ubytek *)
    val opor : float
    val coin_max : int 
    val trap_max : int 
  end;; (* wspolczynniki w stylu valdorfa sie nie nadaja... *)

module Konfiguracja : KONFIGURACJA =
  struct
    let resx = 800
    and resy = 600
    and moc = 1
    and dmin = 100.
    and coddz = 0.05
    and codp = 1.
    and cprzy = 1.
    and masa = 5.
    and dmasa = 5.
    and umasa = 0.001
    and coin_max = 3
    and trap_max = 1
    and opor = 0.35
  end;;


(*****************  model danych  *****************)

module type BASE_POINT = 
(* statyczne pojecie czastki-obiektu *)
  sig
    type t
    val newt : float -> float -> float -> t (* x y r *)
    val x : t -> float
    val y : t -> float
    val m : t -> float
    val r : t -> float (* potrzebny tak naprawde dopiero przy odbijaniu sie od scian *)
    val setx : t -> float -> unit
    val sety : t -> float -> unit
    val interact : t -> t -> float * float
    val utyj : t -> unit
    val schudnij : t -> unit
    (* liczy sie kolejnosc argumentow! *)
    (* zwraca skladowe prostopadle wektora sily *)
    (* dzialajacej na PIERWSZY t. *)
  end;;


module Base_point (Konf : KONFIGURACJA): BASE_POINT =
  struct
    type t = {
      mutable x : float; (* prawie statyczne *)
      mutable y : float;
      mutable m : float;
      r : float;
      sila : t -> t -> float -> float;
    };;
    
    (* Pitagoras *)
    let odleglosc (a,b) (c,d) =
      sqrt((a-.c)*.(a-.c) +. (b-.d)*.(b-.d));;
      
    
    let odpychanie t1 t2 odl =
	-. (odl ** (-2.));;
    let przyciaganie t1 t2 odl =
	(3.14159265358979323 /. 2. -. (atan odl));;
    let grawitacja t1 t2 odl =
        t1.m *. t2.m *. ((odl +. t1.r +. t2.r) ** (-2.)) /. 120.;; 
    let normalnie t1 t2 odl =
	let f = (odpychanie t1 t2 odl)
                *. Konf.codp
                +. (przyciaganie t1 t2 odl)
                *. Konf.cprzy in
	f *. Konf.coddz;;


    let interact t1 t2 =
      if t1.x = t2.x && t1.y = t2.y then
        (0.,0.)
      else
        let odl = odleglosc (t1.x, t1.y) (t2.x, t2.y) in
	let odl = odl /. Konf.dmin in
	let f = ((t1.sila t1 t2 odl)
                +. (t2.sila t1 t2 odl)) /. 2. in
	(* rozkladamy na skladowe, z pkt widzenia t1 *)
	let fx = f *. (t2.x -. t1.x) /. odl
	and fy = f *. (t2.y -. t1.y) /. odl in
	(fx,fy);;

    let newt x y r =
       let s = match Random.int 5 with
           0 -> odpychanie |
           1 -> przyciaganie |
           2 -> grawitacja |
           _ -> normalnie
       in {x=x; y=y; m=Konf.masa; r=r; sila=s};;
    let setx t x =
      t.x <- x; ();;
    let sety t y =
      t.y <- y; ();;
      
    let x t = t.x;;
    let y t = t.y;;
    let m t = t.m;;
    let r t = t.r;;

    let utyj t =
      t.m <- t.m +. Konf.dmasa;;
    let schudnij t =
      t.m <- t.m +. Konf.umasa;;
  end;;

module type POINT = 
(* obiekt w ruchu *)
  sig
    type t
    val newt : float -> float -> float -> t (* x y r *)
    (* masa i promien sa wyznaczane przez POINT *)
    val x : t -> float
    val y : t -> float
    val r : t -> float
    (* masa jest czyms ukrytym *)
    val compute_mv : t -> t -> unit
    val force : t -> float -> float -> unit (* do dodawania sily zewnetrznej *)
    val do_mv : t -> unit
    (* force skutkuje przy nastepnym do_mv *)
    val utyj : t -> unit
    val schudnij : t -> unit
  end;;
  
module Point (Bp : BASE_POINT) (Konf : KONFIGURACJA) : POINT =
  struct
    type t = {
      bp : Bp.t;
      mutable fx : float;
      mutable fy : float;
      mutable vx : float;
      mutable vy : float;
    }

    (* przeliczanie wspolrzednej a obiektu o promieniu r ktory wypadl z przedzialu d *)
    (* zwraca poprawiona wspolrzedna, oraz parzystosc liczby odbic. *)
    let pingpong =
      let rec pp acc a r d =
        if a < r then
          pp (-.acc) (r +. r -. a) r d
        else if (a +. r) > d then
          pp (-.acc) (d -. r -. (a +. r -. d)) r d
        else (a, acc)
      in pp 1.;;
    
    let newt x y r =
     {
       bp = Bp.newt x y r;
       fx = 0.;
       fy = 0.;
       vx = 0.;
       vy = 0.;
     }
     let x t = Bp.x t.bp;;
     let y t = Bp.y t.bp;;
     let r t = Bp.r t.bp;;

     let compute_mv t1 t2 =
         let (a,b) = Bp.interact t1.bp t2.bp in
         t1.fx <- t1.fx +. a;
         t1.fy <- t1.fy +. b;
         t2.fx <- t2.fx -. a;
         t2.fy <- t2.fy -. b;
         ();;
       
     let force t ix iy =
       t.fx <- t.fx +. ix *. Bp.m t.bp;
       t.fy <- t.fy +. iy *. Bp.m t.bp;
       ();;

     let uwzglednij_sciany t =
       let (nx,sgnx) = pingpong (Bp.x t.bp) (Bp.r t.bp) (float_of_int Konf.resx)
       and (ny,sgny) = pingpong (Bp.y t.bp) (Bp.r t.bp) (float_of_int Konf.resy) in
       begin
         Bp.setx t.bp nx;
         Bp.sety t.bp ny;
	 t.vx <- t.vx *. sgnx;
	 t.vy <- t.vy *. sgny;
       end;;

     let do_mv t =
       (* opor powietrza *)
       t.fx <- t.fx -. t.vx *. Konf.opor;
       t.fy <- t.fy -. t.vy *. Konf.opor;
       (* przeliczenie *)
       t.vx <- t.vx +. t.fx /. 2. /. (Bp.m t.bp); (* pol sily przez mase *)
       t.vy <- t.vy +. t.fy /. 2. /. (Bp.m t.bp);
       t.fx <- 0.; (* zerujemy dla nastepnych obliczen *)
       t.fy <- 0.;    
       (* przesuniecie *)
       Bp.setx t.bp ((Bp.x t.bp) +. t.vx);
       Bp.sety t.bp ((Bp.y t.bp) +. t.vy);
       (* poprawka *)
       uwzglednij_sciany t;
       ();;

       let utyj t = Bp.utyj t.bp;;
       let schudnij t = Bp.schudnij t.bp;;
    end;;

module IntPoint (P : POINT) =
  struct
    type t = P.t;;
    let newt x y r = P.newt (float_of_int x) (float_of_int y) (float_of_int r);;
    let force t x y = P.force t (float_of_int x) (float_of_int y);;
    let x t = (int_of_float (P.x t));;
    let y t = (int_of_float (P.y t));;
    let r t = (int_of_float (P.r t));;
    let compute_mv = P.compute_mv;;
    let do_mv = P.do_mv;;
    let utyj = P.utyj;;
    let schudnij = P.schudnij;;
  end;;

(* o to Polska walczyla: *)
module Pnt = IntPoint (Point (Base_point(Konfiguracja)) (Konfiguracja));;

(* jeszcze typ danych dla obiektu w grze: *)
type gracz = {
 pnt : Pnt.t;
 id : int;
 mutable score : int
};;


(*************   prezentacja  ******************)
Random.self_init ();;

let gra_mode = Input.add_mode "termo" (function _ -> ());;
Input.set_mode gra_mode;;

let wyniki = ref [];;
let contexts = ref [];; (* nie ma zadnych ekranow *)
let zmiana_wyswietlania _ =
  if List.length !contexts = 0 then
    contexts := Helpers.vertical_split ();;
Helpers.add_video_mode_var zmiana_wyswietlania;;

Parser.parse "exec \"../Data/default.txt\"" ();;
(* przypisanie podstawowych funkcji klawiszom *)



let plset = Sprite.Set.create 4
and trapset = (Sprite.Set.create Konfiguracja.trap_max)
and coinset = (Sprite.Set.create Konfiguracja.coin_max);;

(* Video.optimize? nie dziala... *)
let img0 = Video.load_image "Data/imgGNB3D.png"
and img1 = Video.load_image "Data/imgGW3D.png"
and img2 = Video.load_image "Data/imgGR3D.png"
and img3 = Video.load_image "Data/imgGB3D.png"

and imgT = Video.load_image "Data/imgT.png"
and imgC = Video.load_image "Data/imgC.png";;

let przydziel_obrazek num =
  match (num mod 4) with
    0 -> img0 |
    1 -> img1 |
    2 -> img2 |
    3 -> img3;;
    
let coinNb = ref 0 (* ilosc zetonow na planszy *)
and trapNb = ref 0;; (* ilosc pulapek na planszy *)


(* wejscie wyjscie gracza *)
let pl_change_fun pl_number pl_local pl_new =
  if pl_new then (* dodajemy *)
    if pl_number > 3 then ()
    else begin
      let img = przydziel_obrazek pl_number in
      let r = (fst (Video.image_size img)) / 2 in
      let x = r + Random.int (Konfiguracja.resx - 2*r)
      and y = r + Random.int (Konfiguracja.resy - 2*r) in
      let pnt = Pnt.newt x y r in
      let gracz = {pnt=pnt; id=pl_number; score=0} in
        ignore (Sprite.create ~set:plset gracz img (x-r,y-r));
      if pl_local then
        zmiana_wyswietlania ();
    end
  else (* usuwamy *)
    let cond_rmv spr =
      if (Sprite.get_data spr).id = pl_number then
        let gracz = Sprite.get_data spr in
        begin
          print_string (string_of_int gracz.id);
	  print_string " ";
	  print_string (string_of_int gracz.score);
          print_string "\n";
	  wyniki := (pl_number, gracz.score)::!wyniki;
          Sprite.Set.del plset spr;
        end
    in Sprite.Set.iter cond_rmv plset;;

Net.init pl_change_fun;;
Helpers.add_chat ();;

let polex = Helpers.add_action_pair true "e" "w" 
and poley = Helpers.add_action_pair true "s" "n";;

Parser.parse "exec \"Data/termo.txt\"" ();;


Sprite.Set.set_collision coinset (Konfiguracja.resx/4) (Konfiguracja.resy/4);
Sprite.Set.set_collision plset (Konfiguracja.resx/4) (Konfiguracja.resy/4);
Sprite.Set.set_collision trapset (Konfiguracja.resx/4) (Konfiguracja.resy/4);
let bingo coinspr plspr =
  Sprite.Set.del coinset coinspr;
  coinNb := !coinNb - 1;
  let gracz = Sprite.get_data plspr
  in begin
     Pnt.utyj gracz.pnt;
     gracz.score <- gracz.score + 1;
  end
in Sprite.add_collision_fun coinset plset true bingo;;
let fault trapspr plspr =
  Sprite.Set.del plset plspr
in Sprite.add_collision_fun trapset plset true fault;;
  

let frame_fun _ = 
  if !coinNb < Konfiguracja.coin_max then
    begin
      coinNb := !coinNb + 1;
      let r = fst (Video.image_size imgC) in
      ignore (Sprite.create ~set:coinset () imgC (Random.int (Konfiguracja.resx - 2*r), Random.int (Konfiguracja.resy - 2*r)));
    end;
  if !trapNb < Konfiguracja.trap_max then
    begin
      trapNb := !trapNb + 1;
      let r = fst (Video.image_size imgT) in
      ignore (Sprite.create ~set:trapset () imgT (Random.int (Konfiguracja.resx - 2*r), Random.int (Konfiguracja.resy - 2*r)));
    end;
  let comp spr =
    let do_comp spr1 spr2 =
      Pnt.compute_mv (Sprite.get_data spr1).pnt (Sprite.get_data spr2).pnt
    in Sprite.Set.iter (do_comp spr) plset
  and move spr =
    let pnt = (Sprite.get_data spr).pnt in
    Pnt.do_mv pnt;
    Sprite.move_to spr (Pnt.x pnt - Pnt.r pnt, Pnt.y pnt - Pnt.r pnt)
  and pole spr =
    let gracz = Sprite.get_data spr in
    Pnt.force gracz.pnt
              (Konfiguracja.moc * polex gracz.id)
              (Konfiguracja.moc * poley gracz.id);  
  in
    Sprite.Set.iter comp plset;
    Sprite.Set.iter pole plset;
    Sprite.Set.iter move plset;
    Sprite.Set.iter (fun s -> Pnt.schudnij (Sprite.get_data s).pnt) plset;
    Sprite.Set.iter Sprite.check_collisions coinset;
    Sprite.Set.iter Sprite.check_collisions trapset;
  ();;
  
let font =
 let color_transform ((r,g,b),i) =
   ((r,g,b),2*i+100) 
 in Font.load ~color:color_transform "Data/font.png";;
  
let draw_fun _ = 
  Video.fill (0,0,0);
  let draw_context cnt =
    Video.fill ~on:cnt (207,127,67);
    Sprite.Set.iter (Sprite.draw ~on:cnt) coinset;
    Sprite.Set.iter (Sprite.draw ~on:cnt) trapset;
    let maluj_plspr spr =
      Sprite.draw ~on:cnt spr;
      let str = string_of_int (Sprite.get_data spr).score in
      let h = Font.height font
      and v = Font.width font str in
        match (Sprite.get_data spr).id with
	 0 -> Font.draw_string ~on:cnt font (Konfiguracja.resx-5-v) 5 str |
	 1 -> Font.draw_string ~on:cnt font 5 5 str |
	 2 -> Font.draw_string ~on:cnt font 5 (Konfiguracja.resy-5-h) str |
	 3 -> Font.draw_string ~on:cnt font (Konfiguracja.resx-5-v) (Konfiguracja.resy-5-h) str |
         _ -> print_string "obcy gracz?\n"
    in Sprite.Set.iter maluj_plspr plset;
  in List.iter draw_context !contexts;;

(*******************************)
Helpers.main frame_fun draw_fun;;
(*******************************)

print_string "koniec gry \n";;


let wynik plspr =
  let pl = (Sprite.get_data plspr) in
  begin
    print_string (string_of_int pl.id);
    print_string " ";
    print_string (string_of_int pl.score);
    print_string "\n";
  end
in Sprite.Set.iter wynik plset;;

(*let rec wypisz x y = function
   []  -> ()
  |h::t-> Font.draw_string font x y h;  
          wypisz (x+Font.width font h) y t
	  
in let h = Font.height font
in let wynik y (no, sc) =
   wypisz (resx/3) y ("Gracz numer "::string_of_int no::"zdobyl punktow: "::[string_of_int sc]);
   (y+h+10)
in List.fold_left wynik (resy / 3) !wyniki;;*)
