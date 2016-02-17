(* Obs³uga klawiszy *)
exception Fail;;

let fire_key_down = ref false;;
let fire_down _ = fire_key_down := true;;
let fire_up _   = fire_key_down := false;;

let input_mode = Input.add_mode "game" (fun _ -> ());;
Input.add_action ~mode:input_mode "die"  (fun _ -> ()) (fun _ -> raise Robbo.Die);;
Input.add_action ~mode:input_mode "fail" (fun _ -> ()) (fun _ -> raise Fail);;
Input.add_action ~mode:input_mode "print"(fun _ -> Level.print "debug.rob") (fun _ -> ());;
Input.add_action ~mode:input_mode "fire" fire_down fire_up;;

let player_actions = 
  Helpers.add_action_group ~mode:input_mode false 
  ["up"; "right"; "down"; "left"]
;;
let get_action () = 
  let now = player_actions 1 in
  try
    let dir = match now with
      |"up" :: []    -> Direction.UP
      |"right" :: [] -> Direction.RIGHT
      |"down" :: []  -> Direction.DOWN
      |"left" :: []  -> Direction.LEFT
      | _ -> raise Not_found
    in
    if !fire_key_down then Level.FIRE dir
    else Level.MOVE dir
  with
  |Not_found -> Level.NOTHING
;;

let delay = ref 30;;(*Variable.add "delay" Variable.int 30;;*)
let last_action = ref 0;;

(* [blow_all ()] wszystkie elementy planszy poza murkiem i pod³og± zamieniam
   w wybuch, po czym czekam kilka sekund a¿ siê zaanimuje co trzeba i wracam *)
let blow_all () =
  Sdltimer.delay 100;
  let start_time = Sdltimer.get_ticks () in
  let d_time = 7 * (1 + (32 / Element.def_speed)) * !delay in
  let stop_time = start_time + d_time in
  let rec loop () =
    let new_action = Sdltimer.get_ticks () > !last_action + !delay in
    if new_action then begin
      last_action := Sdltimer.get_ticks ();
      Level.next_action get_action;
      Level.draw_image ();
      Console.draw ();
      Video.flip ();
      Gc.major ();
    end else
      Sdltimer.delay 2;
    if !last_action > stop_time then () else loop ()
  in
  Level.blow_all ();
  loop ()  
;;

(* Mi³a animacja na przej¶cie planszy - przeciwieñstwo blow_all *)
let nice_delay = ref 15;;(*Variable.add "nice_delay" Variable.int 15;;*)
let nice_anim () =
  Sdltimer.delay 100;
  for col = 0 to Level_image.level_width - 1 do
    Level.remove_col col;
    Level.draw_image ();
    Console.draw ();
    Video.flip ();
    Gc.major ();
    Sdltimer.delay !nice_delay;
  done;
;;

(* Robbo straci³ wszystkie ¿ycia *)
let game_fail () =
  blow_all ();
  Info.wait2 "fail.jpg" ();
;;
(* Robbo skusi³, ale ma ¿ycia - restartujê planszê *)
let game_restart () = 
  blow_all ();
  Level.restart ();
;;
(* Przeszed³e¶ wszystkie plansze *)
let congratulations () =
  nice_anim ();
  Info.wait2 "win.jpg" ();
;;

(* G³ówna pêtelka - wykonaj akcje, odrysuj i tak ca³y czas ... *)
let rec game_loop () =
  let events = Input.process_events () in
  let new_action = Sdltimer.get_ticks () > !last_action + !delay in
  if new_action || events then begin
    last_action := Sdltimer.get_ticks ();
    Level.next_action get_action;
    (* Odrysowanie *)
    Graph.hide_console ();
    Level.draw_image ();
    Level.draw_info ();
    Console.draw ();
    Video.flip ();
    Gc.major ();
  end else
    Sdltimer.delay 1;
  game_loop ()
;;

let rec game level =
  Video.fill (0, 0, 0);
  Graph.cam_default ();
  Level.set_level (level);
  Input.set_mode input_mode;
  let rec reset_keys () = 
    Sdltimer.delay 5;
    ignore (Input.process_events ());
    if get_action () != Level.NOTHING then reset_keys () else ()
  in
  let reset () = 
    reset_keys ();
    fire_key_down := false;
  in
  let my_info f () =
    reset ();
    f ();
  in

  let rec run () = 
    try game_loop () with
      |Fail      -> my_info game_fail ()
      |Robbo.Die -> 
         if Level.restart_ok () then begin
           game_restart ();
           reset ();
           run ();
         end else my_info game_fail ()
      |Capsule_r.Robbo_inside -> 
         if Level.next_level_exist () then begin
           nice_anim ();
           Level.set_next_level ();
           Graph.cam_default ();
           reset ();
           run ();
         end else my_info congratulations ()
  in 
  run ();
;;
