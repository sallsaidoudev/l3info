
exception Wynik of int;;


let brak_pilek _ =
	Unix.sleep 1;
	let w = Player.brak_pilek() in
	let l = if w then 0 else Player.get_level() in
	if w  then raise (Wynik (Player.get_score())) else ();
	Ball.load_level 	l;
;;



let draw _ =
	Video.fill(0,0,0);
	Board.draw ();
	Ball.draw ();
	Palka.draw ();
	Player.draw ();
;;



let brak_klockow () =
	Video.fill(0,0,0);
	draw();
	Video.flip();
	Unix.sleep 1;
	Player.next_level();
	let l = Player.get_level() in
	Player.load_level 	l;
	Ball.load_level 	l;	
	Board.load_level 	l;
;;

(*8888888888888888888888888888888888888888888888888888*)



let frame fr= 
	Board.frame fr;
	Ball.frame  fr;
	Palka.frame fr;
	Player.frame fr;

	if Ball.is_ball() = false then brak_pilek()
	else if Board.is_klocki() = false then brak_klockow() else ()
;;



let init ()=
	Player.init();
	Board.init();
	Palka.init();
	Ball.init();
;;

let init_event()=
    let event_fun = function
      | Sdlevent.MOUSEMOTION {Sdlevent.mme_x = x; Sdlevent.mme_y = y;} ->
          Palka.move x y
      | Sdlevent.MOUSEBUTTONDOWN {Sdlevent.mbe_x = x; Sdlevent.mbe_y = y;} ->
          if not (Ball.is_start()) then Ball.start x (Palka.my_Y) else ();
          Palka.fire x y
      | _ -> ()
    in Input.set_mode (Input.add_mode "go" event_fun);;




let run () =
    init();
	init_event();
	try ( Helpers.main_no_quit (fun () -> frame 1) draw )with
	       | Wynik(w) -> w
	       | w -> raise w;							
;;


