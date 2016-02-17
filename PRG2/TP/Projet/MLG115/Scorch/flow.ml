type player = {
  no : int;
  local : bool;
  mutable turn_done : bool;
  mutable active : bool;
  mutable cash : int;
}

type tstate = 
  | Idle
  | Turn of int
  | Wait
  | Sim
;;

let state = ref Idle;;
let players = Hashtbl.create 10;;
let sequence = ref [];;
let round = ref 0;;

let set_state new_state =
  state := new_state;
  let new_plid =
    match new_state with
    | Turn plid -> plid
    | _ -> (-1)
  in
  Tank.set_focus new_plid
;;

let player_list () =
  Hashtbl.fold (fun plid player acc -> plid :: acc) players []
;;

let local_players_list () =
  let fold_fun plid player init =
    if (player.local && player.active) then plid :: init
    else init
  in
  Hashtbl.fold fold_fun players [];
;; 

let player_count () = Hashtbl.fold (fun _ _ acc -> acc + 1 ) players 0 ;;

let refresh_sequence () =
  sequence := (local_players_list ())
;;

let next_player curr_plid =
  try
    let rec find_next pl_list first curr_plid =
      match pl_list with
      | [ hd ] -> first
      | hd :: tl ->
        if hd = curr_plid then List.hd tl
        else find_next tl first curr_plid
      | _ -> 
        Log.error "next_player: this shouldn't have happened!";
        first
    in
    let filter plid = if (Hashtbl.find players plid).turn_done then (-1) else plid in
    filter (find_next !sequence (List.hd !sequence) curr_plid)
  with Failure _ -> (-1)
;;

let next_player curr_plid =
  let not_done_list =
    List.filter (fun plid -> not (Hashtbl.find players plid).turn_done ) !sequence
  in
  match not_done_list with
  | hd :: tl -> hd
  | [] -> (-1)
;;

let all_done () =
  let fold_fun plid player init =
    if (player.active && (not player.turn_done)) then false
    else init
  in
  Hashtbl.fold fold_fun players true
;;
(* GAMEFLOW GLOBAL FUNCTIONS *)
(* ##########################################################################*)

let end_game () =
  Missle.clear ();
  Block.clear ();
  Tank.clear ();
  set_state Idle;
  round := 0;
  Log.info "Game ended"
;;

let end_round () =
  if !round <> 0 then begin
    Hashtbl.iter (fun plid player ->
      let cash_earned = (Score.cash_earned plid !round) in
      player.cash <- player.cash + cash_earned;
      Log.info ("Player "^(string_of_int plid)^" earned "^(string_of_int cash_earned))
    ) players;
  end;
  Score.recalculate_weights ();
  Missle.clear ();
  Block.clear ();
  Log.info ("Round "^(string_of_int !round)^" ended");
;;

let new_round () =
  let new_round_for_player locations plid player =
    Tank.re_create plid (List.nth locations plid);
    player.active <- true
  in
  round := !round + 1;
  Score.set_round (!round) (player_list());
  match Landgen.make (player_count()) with (tiles, locations) ->
  List.iter (fun (tile, pos) -> Block.add tile pos true) tiles;
  Block.add (Landgen.rect_block (!Options.width, 10)) (0, !Options.height) false;
  Hashtbl.iter (new_round_for_player locations) players;
  refresh_sequence (); 
  set_state (Turn (next_player (-1)));
  Missle.wind_change ();
  Log.info ("Round "^(string_of_int !round)^" started")
;;

let next_round () =
  end_round ();
  if !round = !Options.rounds then end_game ()
  else new_round ();
;;

let end_turn () =
  let end_turn_fun plid player = Tank.fire plid () in
  Log.info "Turn completed";
  set_state Sim;
  Hashtbl.iter end_turn_fun players
;;

let end_sim () =
  let end_sim_fun plid player = 
    player.turn_done <- false;
    player.active <- not (Tank.dead plid);
    refresh_sequence ()
  in
  Log.info "Simulation completed";
  Hashtbl.iter end_sim_fun players;
  set_state (Turn (next_player (-1)));
  if !Options.turn_wind_change then Missle.wind_change ();
  Score.set_result (Tank.results ());
  match (Tank.results ()) with
  | Score.Winner plid ->
    Log.info ("The winner is player"^(string_of_int plid));
    next_round ()
  | Score.Draw ->
    Log.info "Draw round";
    next_round ()
  | Score.Unresolved -> ()
;;

(* player dependent gameflow control functions *)

let local_player_done plid =
  (Hashtbl.find players plid).turn_done <- true;
  match next_player plid with
  | (-1) -> set_state Wait
  | new_plid -> set_state (Turn new_plid);  
;;

let remote_player_done plid () =
  Log.info ("Player "^(string_of_int plid)^" done");
  (Hashtbl.find players plid).turn_done <- true;
  if (all_done ()) then end_turn ()
;;

(* GAMEFLOW CONTROL COMMANDS                                            *)
(* ##########################################################################*)

let start_game_internal =
  let start_game_local seed =
    let clean_players () =
      Hashtbl.iter (fun plid player ->
        player.cash <- !Options.cash_at_start
      ) players
    in
    match !state with
    | Idle ->
      Log.info "Game started";
      Random.init seed;
      Score.clear;
      new_round ()
    | Turn _ | Sim | Wait -> 
      Log.error "Cannot start a game. Game in progres."
  in
  (Net.add_server_broadcast Serialize.int start_game_local)
;;

let start_game () = start_game_internal (Random.int 100);;

let end_game =
  let end_game_local () =
    match !state with
    | Idle -> Log.error "No game in progress"
    | Turn _ | Sim | Wait ->
      Missle.clear ();
      Block.clear ();
      Tank.clear ();
      set_state Idle;
      round := 0;
      Log.info "Game end forced"
  in
  Net.add_server_broadcast Serialize.unit end_game_local
;;

let client_change plid local nju =
  let new_player = { 
    no = plid; local = local; 
    active = true; turn_done = false;
    cash = !Options.cash_at_start;
    } 
  in match nju, !state with
  | true, Idle -> 
      Hashtbl.add players plid new_player;
      Log.info ("Player "^(string_of_int plid)^" connected")
  | true, _ ->
      let plid_str = string_of_int plid in
      Parser.parse ("disconnect "^plid_str) ()
  | false, Idle ->
      Hashtbl.remove players plid;
      Log.info ("Player "^(string_of_int plid)^" disconnected")
  | false, _ -> 
      let player = Hashtbl.find players plid in 
      player.active <- false;
      refresh_sequence (); 
      Log.info ("Player "^(string_of_int plid)^" disconnected")
;;

(* check state *)

let frame () =
  if (not (Missle.any ())) && (not (Explosion.any ())) && 
     (!state = Sim) && (Tank.all_ready ())
  then
  end_sim ()
;;

(* debug *)

let debug_state _ =
  begin match !state with
  | Idle -> Log.debug "Idle"
  | Sim -> Log.debug "Sim"
  | Wait -> Log.debug "Wait"
  | Turn plid -> Log.debug ("Turn "^(string_of_int plid))end;
  Log.debug "sequence dump";
  List.iter (fun plid ->
    let player = Hashtbl.find players plid in
    Log.debug ("  player "^(string_of_int plid)^
      ", turn_done "^(string_of_bool player.turn_done)^
      ", active "^(string_of_bool player.active))
  ) !sequence;
;;

Parser.add_command "state" Parser.unit "" debug_state;;
Parser.add_command "start" Parser.unit "" start_game;;
Parser.add_command "end" Parser.unit "" end_game;;
