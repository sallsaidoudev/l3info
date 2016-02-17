type t = {
  mutable score :int;
  mutable screw :int;
  mutable live  :int;
  mutable key   :int;
  mutable ammo  :int;
  mutable nr    :int;
  mutable redraw:bool
};;

(* KONSTRUKTORY ************************************)
let lives = ref 8;;(*Variable.add "lives" Variable.int 8;;*)
let ammo  = ref 0;; (*Variable.add "ammo"  Variable.int 0;;*)
let create nr = {score=0; screw=0; live= !lives; key=0; ammo= !ammo; nr=nr; redraw=true};;
let create_with data = {data with key=0; ammo= !ammo; redraw=true};;

(* MODYFIKATORY ************************************)
let update dscore data = 
  data.score <- data.score + dscore;
  data.redraw <- true;
;;
let dec_screw data = 
  data.screw <- data.screw - 1;
  update 100 data
;;
let dec_live data =
  data.live <- data.live - 1;
  update 0 data
;;
let dec_key data =
  data.key <- data.key - 1;
  update 100 data
;;
let inc_key data = 
  data.key <- data.key + 1;
  update 75 data
;;
let dec_ammo data =
  data.ammo <- data.ammo - 1;
  update 0 data
;;
let inc_ammo data =
  data.ammo <- data.ammo + 8;
  update 50 data
;;
let inc_nr data = 
  data.nr <- data.nr + 1;
  update 1000 data
;;
let set_screw data count = data.screw <- count;;

(* PYTANIA ***************************************)
let all_screws {screw=screw} = screw <= 0;;
let get_nr {nr=nr} = nr;;
let has_key  {key=k}  = k > 0;;
let has_ammo {ammo=a} = a > 0;;
let get_live {live=l} = l;;

(* PIKTOGRAMY ************************************)
let context = Graph.data_context;;
let icons = Graph.load_image "info_ico.png";;
let ico_width = 32;;
let ico_height = 32;;
(* [ico_draw nr x y] narysuj [nr] klatkê z icons na pozycji ([x], [y]) w context *)
let ico_draw nr x y = 
  let offset = nr * ico_width in
  let src_rect = Sdlvideo.rect offset 0 ico_width ico_height in
  Video.blit icons ~src_rect ~on:context x y
;;

(* WYRYSOWANIE CYFR ******************************)
let digits = Graph.load_image "cyfry.png";;
let digit_width = 16;;
let digit_height = 32;;
(* [digit_draw x y (digit, pos)] narysuj cyfrê [digit] która jest [pos] cyfr± pewnej
   liczby. Ca³a liczba jest rysowana na pozycji ([x], [y]).
   Czyli sam siê przesuwa gdzie trzeba *)
let digit_draw x y (digit, pos) =
  let offset = digit * digit_width in
  let x_pos = x + (pos * digit_width) in
  let src_rect = Sdlvideo.rect offset 0 digit_width digit_height in
  Video.blit digits ~src_rect ~on:context x_pos y;
;;
(* [number_draw d_count x y number] narysuj liczbê [number] na pozycji ([x], [y])
   w context. Liczba ma siê skad±æ z dok³adnie [d_count] cyfr, je¶li jest d³u¿sza to
   wypisz co kolwiek *)
let number_draw d_count x y number =
  let draw = digit_draw x y in
  (* lista: (cyfra, pozycja od pocz±tku=0..d_count-1) *)
  let rec digits i n = 
    if i = -1 then [] else (n mod 10, i)::(digits (i-1) (n/10)) 
  in
  let my_digits = digits (d_count - 1) number in
  List.iter draw my_digits
;;

(* RYSOWANIE **************************************)
let y = 0;;
let draw_score n =
  let x = 0 in
  number_draw 6 x y n
;;
(* [draw_op ico_num x number] na pozycji ([x], 0) w context wyrysuj: najpierw piktogram
   [ico_num], 32 piksele odstêpu, liczba [number] z dok³adno¶ci± do 2 cyfr *)
let draw_op ico_num x number =
  ico_draw ico_num x y;
  number_draw 2 (x + 32) y number
;;
let redraw {redraw = r} = r;;
let draw_all data =
  draw_score data.score;
  draw_op 0 128 data.screw;
  draw_op 1 224 data.live;
  draw_op 2 320 data.key;
  draw_op 3 416 data.ammo;
  draw_op 4 512 data.nr;
  data.redraw <- false;
;;
