type result =
  | Winner of int
  | Draw
  | Unresolved
;;

type scored_event =
  | Damage of int
  | Kill
  | Direct
  | Win
;;

type round_score = {
  mutable result : result;
  mutable events : (int * scored_event * int) list;
  scores : (int,  int) Hashtbl.t;
  player_list : int list;
} 

let log = Parser.create_log "debug_score" "[Score] " false;;

let round = ref 0;;

let scores = Hashtbl.create 10;;

let weights = Hashtbl.create 10;;

let set_round sround player_list =
  round := sround;
  Hashtbl.replace 
    scores sround 
    { result = Unresolved; 
      events = [];
      scores = Hashtbl.create 10;
      player_list = player_list };
  (*Hashtbl.replace weights (-1) 1.*)
;;

(*
let score_for round =
  try Hashtbl.find scores round 
  with Not_found -> 
    Log.error "Internal error Round not found.";
    { result = Unresolved; events = []; player_count = 0}
;;
*)

let clear = 
  Hashtbl.clear scores;
  Hashtbl.clear weights;
;;

let weight plid =
  try Hashtbl.find weights plid
  with Not_found -> 1.
;;

let calculate_points plid round =
  let score = Hashtbl.find scores round in
  let pfdam = float_of_int !Options.points_for_damage in
  let pfdir = float_of_int !Options.points_for_direct in
  let pfkill = float_of_int !Options.points_for_kill in
  let pfwin = float_of_int !Options.points_for_win in
  let points =
    let event_iter points (by, event, done_to) =
      let weights = (weight done_to) /. (weight by) in
      (*Log.debug ("("^(string_of_int by)^","^(string_of_int done_to)^")");
      Log.debug ("weights "^(string_of_float weights));*)
      if (by = plid) && (done_to <> by) then
        match event with
          | Damage amount -> points +. (pfdam *. (float_of_int amount))
          | Kill -> points +. pfkill
          | Direct -> points +. pfdir
          | Win -> points +. pfwin
      else points
    in
    List.fold_left event_iter 0. score.events
  in
  log ("player "^(string_of_int plid)^" points "^(string_of_float points));
  int_of_float points
;;

let get_points plid round =
  let score = Hashtbl.find scores round in
  try Hashtbl.find score.scores plid
  with Not_found -> -0
;;

let total_points plid = 
  let sum_fun round_num score pnts =
    pnts + (get_points plid round_num)
  in
  Hashtbl.fold sum_fun scores 0
;;

let recalculate_weights () =
  let player_list = (Hashtbl.find scores 1).player_list in
  let player_count_fl = 
    float_of_int (List.fold_left (fun acc _ -> acc + 1) 0 player_list) 
  in
  let total_points plid = float_of_int (total_points plid) in
  let grand_total =
    let sum_fun acc plid =
      acc +. (total_points plid)
    in
    List.fold_left sum_fun 0. player_list
  in
  let map_fun vl =
    let (min, max) = (0.5, 2.) in
    if vl > 1.  then ( 2. -. (1. /. vl)) *. (max -. 1.)
    else ((( 1. /. (2. -. vl) ) -. 1.) *. min ) +. 1. 
  in
  let set_fun plid =
    let weight = 
      map_fun ( ((total_points plid) *. player_count_fl)/. grand_total ) 
    in
    log (" total for player"^(string_of_float (total_points plid))^" grand_total "^(string_of_float grand_total)^" ");
    Hashtbl.replace weights plid weight;
    Log.info 
      ("New weight for player "^(string_of_int plid)^
      " is "^(string_of_float weight))
  in
  List.iter set_fun player_list
;;

let cash_earned plid round =
  let score = Hashtbl.find scores round in
  let pfdam = float_of_int !Options.points_for_damage in
  let pfdir = float_of_int !Options.points_for_direct in
  let pfkill = float_of_int !Options.points_for_kill in
  let pfwin = float_of_int !Options.points_for_win in
  let points =
    let event_iter points (by, event, done_to) =
      let weights = (weight done_to) /. (weight by) in
      (*Log.debug ("("^(string_of_int by)^","^(string_of_int done_to)^")");
      Log.debug ("weights "^(string_of_float weights));*)
      if (by = plid) && (done_to <> plid) then
        match event with
          | Damage amount -> points +. (pfdam *. weights *. (float_of_int amount))
          | Kill -> 
              log ("kill; by "^(string_of_int by)^", done_to "^
	           (string_of_int done_to)^", score "^(string_of_float pfkill)^
		   ", weight "^(string_of_float weights));
	      points +. (pfkill *. weights)
          | Direct -> points +.  (pfdir *. weights)
          | Win ->
	      log ("win; by "^(string_of_int by)^", done_to "^
	           (string_of_int done_to)^", score "^(string_of_float pfkill)^
		   ", weight "^(string_of_float weights));
              points +. (pfwin *. weights)
      else points
    in
    List.fold_left event_iter 0. score.events
  in
  log ("player "^(string_of_int plid)^" money "^(string_of_float points));
  (int_of_float points) * !Options.cashing_multiplier
;;

let direct_hit plid by =
  let score = Hashtbl.find scores !round in
  score.events <- (by, Direct, plid) :: score.events 
;;

let damaged plid by amount =
  let score = Hashtbl.find scores !round in
  score.events <- (by, Damage amount, plid) :: score.events 
;;

let killed plid by =
  let score = Hashtbl.find scores !round in
  score.events <- (by, Kill, plid) :: score.events 
;;

let set_result result =
  let score = Hashtbl.find scores !round in
  let round_end () =
    List.iter (fun plid ->
      Hashtbl.replace score.scores plid (calculate_points plid !round);
      (*ignore( cash_earned plid !round);*)
      Log.info 
        ("Score for player "^(string_of_int plid)^
        " is "^(string_of_int  (total_points plid )))
      ) score.player_list;
    (* recalculate_weights ()  (* not before earned cash is calculated! *)*)
  in
  score.result <- result;
  match result with
    | Winner winner -> 
      score.events <- (winner, Win, -1) :: score.events;
      round_end ()
    | Draw -> round_end ()
    | _ -> ()
;;
