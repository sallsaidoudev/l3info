(* Odstêpy czasu dla kolejnych klatek, które s± statyczne - wiêc poco? *)
let delay = ref 100;;(*Variable.add "info_delay" Variable.int 100;;*)

let input_mode = Input.add_mode "info" (fun _ -> ());;
(* [break_now num] daje true je¶li wywo³ano akcjê break *)
let break_now = Helpers.add_action ~mode:input_mode false "break";;

let load_image  file_name = Video.load_image ("Data/"^file_name);;
let load_image2 file_name = Video.load_image ("Data/"^file_name);;

let wait image () =
  let rec reset () = 
    Sdltimer.delay 5;
    ignore (Input.process_events ());
    if break_now 1 then reset () else ()
  in
  
  let last_action = ref 0 in
  let rec loop () =
    let events = Input.process_events () in
    let new_action = Sdltimer.get_ticks () > !last_action + !delay in
    if new_action || events then begin
      last_action := Sdltimer.get_ticks ();
      Video.blit image 0 0;
      Console.draw ();
      Video.flip ();
      Gc.major ();
    end else
      Sdltimer.delay 20;
    if break_now 1 then () else loop ()
  in
  Input.set_mode input_mode;
  loop ();
  reset ();
;;

let wait2 file_name () = 
  let image = load_image file_name in
  wait image ()
;;

(* --------------- SCORES --------------*)
let list_to_string x= 
  let rec lis l s= match l with
    [] 	->	s |
    p::r->	lis r (s^(String.make 1 p))
  in lis x ""
;;

let list_of_string s=
  let rec los s l n=
    if n<0 then l else los s (s.[n]::l) (n-1)
  in
  los s [] ((String.length s)-1)
;;

exception Koniec;;


let bgnd_img = load_image "highscor.png";;
let bgnd = Sprite.create () bgnd_img (0,0);;
let name = ref [];;
let max_lng = 10;;


let add_char c = 
  if List.length (!name)> max_lng then () 
  else name:= c::(!name)
;;
let rem_char ()=
  match !name with
    [] -> ()
  | p::r -> name:= r	
;;

let init_event()=
  let event_fun = function
    | Sdlevent.KEYDOWN {Sdlevent.keycode = c; Sdlevent.keysym = s } ->
	(match s with
	  Sdlkey.KEY_RETURN -> raise Koniec |
	  Sdlkey.KEY_BACKSPACE -> rem_char() |
	  _	->     add_char (try Sdlkey.char_of_key s with _ -> '0')
	)
    | _ -> ()
  in Input.set_mode (Input.add_mode "go" event_fun)
;;

let fonts_img = load_image2 "fonty2.png" ;;
let fonts = Sprite.create () fonts_img ~width:24 (0,0) ;;
let frame ()=();;

let rec draw_list l x y=
  let i = int_of_char in
  match l with 
    [] 	-> 	() |
    ' '::r -> draw_list r (x+24) y |
    p::r-> 	let f =	if p >= '0' && p <= '9' then (i p) - (i '0') else
    if p >= 'a' && p <= 'z' then (i p) - (i 'a') + 10 else
    if p >= 'A' && p <= 'Z' then (i p) - (i 'A') + 36 else 0
    in	
(*				print_char p;*)
    Sprite.set_animation_frame fonts f;
    Sprite.move_to fonts (x,y);
    Sprite.draw fonts;
    draw_list r (x+24) y;
;;


let draw_string s x y= draw_list (list_of_string s) x y;;

let draw w () = 
  Video.fill(0,0,0);
  Sprite.draw bgnd;
  draw_string ("Twoj wynik "^(string_of_int w)) 100 200;
  draw_string " podaj imie "  100 250;
  draw_list (List.rev !name) 100 300;
;;


let draw_scores s _= 
  Video.fill(0,0,0);	
  Sprite.draw bgnd;
  let rec dr s y ile= 
    if ile <= 0 then () else
    match s with 
    | [] -> () 
    | (w,n)::r -> 
	draw_string n 50 (y*40 + 10 );
	let sw = (string_of_int w) in
	draw_string sw (600-24*(String.length sw)) (y*40 + 10 );
	dr r (y+1) (ile-1)
  in
  dr s 3 8;
;;

(*------------load, save scores -----------------*)
(*exception Wynik of 'a;;*)

let add_score scores w n =
  let cmp (w1,n) (w2,n) = w2 - w1 in
  let l = (w,n)::scores in
  List.sort cmp l
;;

let load_scores file = 
  let pin = open_in file in
  let rec load scores = 
    try
      let w= int_of_string (input_line pin) in
      let n = input_line pin in
      load (add_score scores w n) 
    with End_of_file -> scores
  in
  load []
;;

let save_scores file scores= 
  let pout = open_out file in
  let rec save scores = match scores with
  | [] -> ()
  | (w,n)::r -> 
      output_string pout ((string_of_int w)^"\n") ;
      output_string pout (n^"\n");
      save r
  in
  save scores;
  close_out pout;
;;

let min_score = function
  | [] -> -1 
  | (w,n)::r -> w
;;

(*88888888888888888*)

let scores wynik= 
  init_event();
  name:=[];
  let scores = load_scores "Data/scores" in
  let min = min_score scores in
  let nscores = 
    if -1 < wynik then begin
      begin try ignore (Helpers.main_no_quit frame (draw wynik)) with
      | Koniec -> ();
      | w -> (); raise w
      end;
      add_score scores wynik (list_to_string (List.rev !name))
    end else scores;
  in
  save_scores "Data/scores" nscores;
  
  try ignore (Helpers.main_no_quit frame (draw_scores nscores)) with
  | Koniec -> ()
  | w -> raise w;
;;




