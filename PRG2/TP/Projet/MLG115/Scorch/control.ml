let game_mode = Input.add_mode "game" (fun _ -> ());;
Input.set_mode game_mode;;

(* local! if in game mode applies current plid and arg to command_fun, else do nothing*)
let command_filter command_fun arg =
  match !Flow.state with
  | Flow.Turn plid -> command_fun plid arg
  | Flow.Sim -> Log.error "Simulation in progress"
  | Flow.Idle -> Log.error "No game in progress"
  | Flow.Wait -> Log.error "Waiting for remote players to finish"
;;

let send_aim = (Net.add_broadcast (Serialize.pair Serialize.int Serialize.int) Tank.set_aim);;
let send_weapon = (Net.add_broadcast Serialize.string Tank.set_weapon);;

let send_pl_done =
  (Net.add_broadcast Serialize.unit Flow.remote_player_done)
;;

let pl_done plid =
  Flow.local_player_done plid;
  send_pl_done plid 
;;

(*
let console_aim = command_filter send_aim;;
let console_set_weapon = command_filter send_weapon;;
*)
let console_aim = command_filter Tank.set_aim;;
let console_set_weapon = command_filter Tank.set_weapon;;

let console_buy = 
  let buy_remote plid (quant, wpid) =
    try
      let player = Hashtbl.find Flow.players plid in
      let price = Weapon.price wpid quant  in
      if player.Flow.cash >= price then
      begin
        player.Flow.cash <- (player.Flow.cash - price);
        Tank.add_weapon plid wpid quant;
	Weapon.bought wpid quant;
        Log.info ("Bought "^(string_of_int quant)^" of "^ (Weapon.name wpid))
      end
      else
      begin
        let short_by = (string_of_int ( price - player.Flow.cash )) in
        Log.info ("You're short by: "^ short_by)
      end
    with Not_found -> Log.info "There is no such weapon"
  in 
  command_filter (Net.add_broadcast (Serialize.pair Serialize.int Serialize.string) buy_remote)
;;

let console_done _ =
  command_filter (fun plid _ -> 
    send_aim plid (Tank.get_aim plid);
    send_weapon plid (Tank.get_weapon plid);
    pl_done plid (); 
    ) []
;;

let console_inv () =
  command_filter (fun plid _ -> Tank.inv plid) ()
;;
 
let console_status _ =
  let status_internal plid =
    Log.info ("-------- Status :"^" Round "^(string_of_int !Flow.round)^" --------");
    List.iter (fun plid -> 
      Log.info ("Player "^(string_of_int plid)^" :"^
      " Cash : "^(string_of_int (Hashtbl.find Flow.players plid).Flow.cash)^" $"^
      " Points : "^(string_of_int (Score.total_points plid))^""^
      " Weight : "^(string_of_float (Score.weight plid))^"")
    ) (Flow.player_list ())
  in
  command_filter (fun plid _ ->
    status_internal plid
  ) ()
;;

Parser.add_command "all_weapons" Parser.unit "" (fun () ->
  Hashtbl.iter (fun plid _ ->
    Hashtbl.iter (fun wpid _ ->
      Tank.add_weapon plid wpid (-1)
    ) Weapon.weapons
  ) Flow.players
);;

let add_broadcast_unit recv_fun = 
  (Net.add_broadcast Serialize.unit (fun arg () -> recv_fun arg))
;;

let power_speed = Parser.add_variable "power_speed" (Parser.int ~max:50 ~min:1 ()) 1;;
let angle_speed = Parser.add_variable "angle_speed" (Parser.int ~max:50 ~min:1 ()) 1;;
let repeat rfun arg =
  for i = 1 to !angle_speed do rfun arg done
;;
(*
let send_aim_up = command_filter (add_broadcast_unit Tank.up);; 
let send_aim_down = command_filter (add_broadcast_unit Tank.dwn);; 
let send_aim_left = command_filter (add_broadcast_unit Tank.lft);; 
let send_aim_right = command_filter (add_broadcast_unit Tank.rgt);; 
let send_next_weapon = command_filter (add_broadcast_unit Tank.nwp);; 
*)
let local_aim_up = command_filter (fun plid () -> repeat Tank.up plid);; 
let local_aim_down = command_filter (fun plid () -> repeat Tank.dwn plid);;
let local_aim_left = command_filter (fun plid () -> repeat Tank.lft plid);;
let local_aim_right = command_filter (fun plid () -> repeat Tank.rgt plid);;
let local_next_weapon = command_filter (fun plid () -> Tank.nwp plid);;

let aim_up = (fun _ -> local_aim_up ());;
let aim_down = (fun _ -> local_aim_down ());;
let aim_left = (fun _ -> local_aim_left ());;
let aim_right = (fun _ -> local_aim_right ());;
let next_weapon = (fun _ -> local_next_weapon ());;

let unset _ = Input.set_repeat_handler None;;

Input.add_action ~mode:game_mode "aim_up" (Input_edit.handle_repeat aim_up) unset;;
Input.add_action ~mode:game_mode "aim_down" (Input_edit.handle_repeat aim_down) unset;;
Input.add_action ~mode:game_mode "aim_left" (Input_edit.handle_repeat aim_left) unset;;
Input.add_action ~mode:game_mode "aim_right" (Input_edit.handle_repeat aim_right) unset;;
Input.add_action ~mode:game_mode "next_weapon" (Input_edit.handle_repeat next_weapon) unset;;

Parser.add_command "aim" (Parser.pair (Parser.int ()) (Parser.int ())) "" console_aim;;
Parser.add_command "done" Parser.unit "" console_done;;
Parser.add_command "setw" Parser.string "" console_set_weapon;;
Parser.add_command "buy" (Parser.pair (Parser.int ()) Parser.string) "" console_buy;;
Parser.add_command "inv" Parser.unit "" console_inv;;
Parser.add_command "status" Parser.unit "" console_status;;

