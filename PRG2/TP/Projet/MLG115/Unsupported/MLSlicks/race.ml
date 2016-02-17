let total_loops = ref 0;;
let loop = ref [||];;
let spacebar_pushed = ref false;;


let init_loops () =
   loop := [|0;0;0;0;|];
;;

let init_spacebar () =
 spacebar_pushed := false
;;

let checkpoints_passed = ref [];;
let checkpoints_numbers = ref [];;

let init_checkpoints () =
 let iter_pl () = 
  let iter_chpts _ = false in
  List.map iter_chpts (!Arena.checkpoints)
 in
 let rec iter_cpts n lst =
  if n < (List.length !Arena.checkpoints) 
  then iter_cpts (n+1) (n :: lst)
  else lst
 in
 checkpoints_passed := [iter_pl(); iter_pl();iter_pl();iter_pl();];
 checkpoints_numbers := List.rev(iter_cpts 0 [])
;;

let loop_update nr =
  let iter_pl () = 
   let iter_chpts _ = false in
   List.map iter_chpts (!Arena.checkpoints)
  in
  let search n lstel = if n=nr then iter_pl() else lstel
  in
  checkpoints_passed := List.map2 search [0;1;2;3;] !checkpoints_passed
;;

let pl_stop = ref [true;true;true;true];;

let init_pl_stop () =
 if List.length (Net.get_local_players ()) = 4 then pl_stop := [false;false;false;false;]
 else if List.length (Net.get_local_players ()) = 3 then pl_stop := [false;false;false;true;]
 else if List.length (Net.get_local_players ())= 2 then pl_stop := [false;false;true;true;]
 else pl_stop := [false;true;true;true;]
 
;;


let update_pl_stop () =
 let mapper n  = 
        if (List.nth !pl_stop n) 
          then true 
          else begin
                 let newval = not (List.exists (fun x -> not x) (List.nth !checkpoints_passed n))
                 in
                 if newval then 
                   begin
                     !loop.(n) <- !loop.(n) + 1;
                     Log.info (string_of_int(n)^" Loop nr "^string_of_int(!loop.(n)));
                     if !loop.(n) >= !total_loops then 
                       Statusbar.stop_nth n true
                     else
                      begin
                        loop_update n;
                        Statusbar.stop_nth n false;
                      end
                   end
                 else false;
               end
 in
 pl_stop := (List.map mapper ([0;1;2;3;]))
;;
   
let stop = ref true ;;

let if_stop () = 
 not ( List.exists (fun x -> not x) !pl_stop)
;;



let get_car plno = Hashtbl.find Graph.cars plno;;


let previous_passed blist nr =
  let rec first_n_true lst n = 
    if n < 0 then true else (List.nth lst n) && first_n_true lst (n-1)
  in
  first_n_true blist (nr-1)
  
;;

let check_for_cpoints pl cplist boollist = 
 let car = get_car pl in

    let mapper_2 (cd1, cd2, dir) number = 
     match (List.nth boollist number) with
      false ->   
              if Car.if_car_online car cd1 cd2 dir 
                   then 
                     if previous_passed boollist number            
                        then 
                          begin 
                             let (x,y) = cd2 in
                             Log.info ("CHECKPOINT "^string_of_int(number)^" PASSED "^string_of_int(x)); 
                             true 
                            end 
                          else false
                  else false
     |true -> true
   in
   try
     List.map2 mapper_2 cplist !checkpoints_numbers;
   with
   | _ -> Log.info "MAP2 Exception"; []
;;


let update_checkpoints () =
  let check_for_car cplist cpp pl =
   let player_list = List.nth cpp pl in
   if pl < (List.length (Net.get_local_players ())) then
      check_for_cpoints pl cplist player_list
   else player_list

  in
  checkpoints_passed := List.map (check_for_car !Arena.checkpoints !checkpoints_passed) [0;1;2;3];
  update_pl_stop ();
  if_stop ();
;;

let delay = Parser.add_variable "delay" (Parser.float ()) 0.019;;
let active_wait = Parser.add_variable "active_wait" Parser.bool false;;

let slicks_mode_init _ = 
   if not !spacebar_pushed then begin
     Statusbar.init (Sdltimer.get_ticks());
     spacebar_pushed := true
   end
   else ()
;;

let slicks_mode = Input.add_mode "slicks" (slicks_mode_init);;
let wait_mode = Input.add_mode "wait" (fun _ -> ());;
let start_now = Helpers.add_action ~mode:wait_mode false "start";;
let clocks = ref [||];;


let main_no_quit new_frame_fun draw_fun =
  let frame = ref 0 in
  let rec main_loop last_frame =
    let events_happened = Input.process_events () in
    let tick_time = Unix.gettimeofday () > last_frame +. !delay in
    let new_frame = Net.process tick_time in
    let new_last_frame = 
      if new_frame then begin
        let ret = Unix.gettimeofday () in
        new_frame_fun ();
        ret
      end else last_frame
    in
    if new_frame || events_happened then begin
      draw_fun ();
      Console.draw ();
      Video.flip ();
      Gc.major ();
      incr frame
    end else begin
      Sdltimer.delay (if !active_wait then 0 else 1)
    end;
    stop := update_checkpoints ();
    if !stop then Statusbar.start := false else ();
    if (not !spacebar_pushed) && (start_now 0) then begin (*Log.info "UUU"; *)Input.set_mode slicks_mode end
    else ();
    main_loop new_last_frame
  in
  try 
    ignore(  main_loop 0. );
  with
  | Input.Quit -> clocks:= Statusbar.get_players_clocks ()
;;

let main nff df =
  try
    main_no_quit nff df;
    Video.quit ()
  with
  | x -> Video.quit (); raise x
;;


let reset () = 
  Graph.init ();
   init_checkpoints ();
   init_pl_stop ();
   init_loops ();  
   init_spacebar();
   stop:= true;
  Statusbar.reset_clocks (Sdltimer.get_ticks ());
;;

let run ()= 
 reset ();
 Input.set_mode wait_mode; 
 Parser.parse "exec \"Data/slicks.txt\"" ();
 main Graph.new_frame_fun Graph.draw_fun;
 clocks
;;


