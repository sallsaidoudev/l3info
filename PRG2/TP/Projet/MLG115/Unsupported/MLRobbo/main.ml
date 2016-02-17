(* Plansza pocz±tkowa *)
let level = ref 1;;(*Variable.add "level" Variable.int 1;;*)

let main_menu () = 
  Info.wait2 "title.png" ();
  !level
;;

let rec main_loop () =
  Game.game (main_menu ());
  main_loop ()
;;

let main () =
  begin try 
    main_loop () with
    | Input.Quit -> ()
    | x -> Video.quit (); raise x
  end;
  Video.quit ();
;;

Parser.parse "exec \"Data/robbo.txt\"" ();;
(*Parser.add_command "next" (fun _ -> raise Capsule_r.Robbo_inside);;*)

main ();;
