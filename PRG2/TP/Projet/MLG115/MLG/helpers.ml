(* This file is part of MLGame (OCaml Game System).

   MLGame is free software; you can redistribute it and/or modify it under the
   terms of the GNU General Public License as published by the Free Software
   Foundation; either version 2 of the License, or (at your option) any later
   version.

   MLGame is distributed in the hope that it will be useful, but WITHOUT ANY
   WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
   FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
   details.

   You should have received a copy of the GNU General Public License along
   with MLGame; if not, write to the Free Software Foundation, Inc., 59 Temple
   Place, Suite 330, Boston, MA 02111-1307 USA *)

let log = Parser.create_log "debug_helpers" "[Helpers] " false;;

let vertical_split () =
  let res_x, res_y = Video.get_resolution () in
  let local_players = List.length (Net.get_local_players ()) in
  if local_players = 0 || res_x < 3 then [] else
  let cnt_w = res_x / local_players - 2 in
  let rec set_context acc i = 
    if i = local_players then acc else
    let cnt_x = (cnt_w + 2) * i + 1 in
    let context = Video.create_context cnt_x 0 cnt_w res_y (0, 0) in
    set_context (context :: acc) (i + 1)
  in
  set_context [] 0
;;

let add_video_mode_var video_change_fun =
  log "Adding video_mode";
  let set_video_mode fs (x, y) =
    Video.set_mode fs (x, y) 16;
    video_change_fun ();
    Console.resize x y
  in
  let set_fs fs = set_video_mode fs (Video.get_resolution ()) in
  let aparser = Parser.callback set_fs Parser.bool in
  let fs = Parser.add_variable "fullscreen" aparser false in
  let aparser = 
    Parser.callback (fun res -> set_video_mode !fs res) (
    Parser.accept_only [(10, 10);(320, 240);(640, 480); (800, 600); (1024, 768); (1152, 864)] (
    Parser.pair (Parser.int ()) (Parser.int ())))
  in
  ignore (Parser.add_variable "video_mode" aparser (Video.get_resolution ()))
;;

let add_chat () =
  log "Adding chat";
  let chat_send =
    let log i str = Log.info ("Player" ^ (string_of_int i) ^ " sais:" ^ str) in
    Net.add_broadcast Serialize.string log
  in let chat_aux local_no word = 
    try chat_send (List.nth (Net.get_local_players ()) local_no) word
    with Failure "nth" -> Log.error "No such player"
  in let chat_cmd = function
    | (word, None) -> chat_aux 0 word
    | (word, Some i) -> chat_aux i word
  in
  Parser.add_command "say" (Parser.pair Parser.string (Parser.option (Parser.int ())))
    "Chats with other players with optionally given player number" chat_cmd
;;

let delay = Parser.add_variable "delay" (Parser.float ()) 0.02;;
let fps = Parser.add_variable "fps" (Parser.float ()) 0.0;;
let active_wait = Parser.add_variable "active_wait" Parser.bool false;;

let main_no_quit new_frame_fun draw_fun =
  let frame = ref 0 in
  let fps_last_tick = ref 0 in
  let fps_last_frame =  ref 0 in
  log "Entering mainloop";
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
    let calc_fps frame =
      let new_tick = Sdltimer.get_ticks () in
      let ticks = float_of_int (new_tick - !fps_last_tick ) in
      let new_fps = (float_of_int (frame - !fps_last_frame)) /. ticks *. 1000.0 in
      let frac2 vl = (float (int_of_float (vl *. 100.))) /. 100. in
      if (frame mod 20) = 0 then begin
        fps := frac2 new_fps;
        fps_last_tick := new_tick;
        fps_last_frame := frame
      end
    in
    if new_frame || events_happened then begin
      draw_fun ();
      Console.draw ();
(*      Tempmenu.draw_test ();*)
(*      Tempmenu.draw_fps ();*)
      Video.flip ();
      Gc.major ();
      calc_fps !frame;
      incr frame
    end else begin
      Sdltimer.delay (if !active_wait then 0 else 1)
    end;
    main_loop new_last_frame
  in
  try 
    main_loop 0.;
    !frame
  with
  | Input.Quit -> !frame
;;

let main new_frame_fun draw_fun =
  let log_fps frame =
    let ticks = float_of_int (Sdltimer.get_ticks ()) in
    let fps = (float_of_int (frame)) /. ticks *. 1000.0 in
    log ("Fps: " ^ (string_of_float fps))
  in
  try 
    let frame = main_no_quit new_frame_fun draw_fun in
    log "Exiting mainloop";
    log_fps frame;
    Video.quit ()
  with
  | x -> Video.quit (); raise x
;;


let add_net_action ?mode action_name press_handle release_handle =
  let net_recv_press pl_no () = press_handle pl_no
  and net_recv_release pl_no () = release_handle pl_no in
  let net_send_press = Net.add_broadcast Serialize.unit net_recv_press
  and net_send_release = Net.add_broadcast Serialize.unit net_recv_release in
  let our_send_press local_no = 
    try net_send_press (List.nth (Net.get_local_players ()) local_no) ()
    with Failure "nth" -> Log.error "No such player"
  and our_send_release local_no = 
    try net_send_release (List.nth (Net.get_local_players ()) local_no) ()
    with Failure "nth" -> Log.error "No such player" in
  Input.add_action ?mode action_name our_send_press our_send_release
;;

let actions = Hashtbl.create 50;;

module S = Serialize;;

let actions_synchronizer =
  let ser = S.list (S.pair (S.pair S.int S.string) (S.pair S.int S.int)) in
  let recv lst =
    Hashtbl.clear actions;
    List.iter (fun (p1, p2) -> Hashtbl.replace actions p1 p2) lst
  in 
  let send = Net.add_server_to_client ser recv in
  let folder p1 p2 acc = (p1, p2) :: acc in
  fun pl_no -> send [pl_no] (Hashtbl.fold folder actions []) in
Net.add_synchronizer actions_synchronizer;;
    

let add_action ?mode net name =
  let press_handle pl_no = Hashtbl.replace actions (pl_no, name) (1, 1)
  and release_handle pl_no = 
    try let (_, was) = Hashtbl.find actions (pl_no, name) in
    Hashtbl.replace actions (pl_no, name) (0, was)
    with Not_found -> () in
  if net then add_net_action ?mode name press_handle release_handle
  else Input.add_action ?mode name press_handle release_handle;
  fun pl_no -> 
    try 
      let (is, was) = Hashtbl.find actions (pl_no, name) in
      if is = 1 then true else 
      if was = 1 then begin
        Hashtbl.remove actions (pl_no, name);
        true
      end else false
    with Not_found -> false
;;

let add_action_pair ?mode net add sub =
  let get_add = add_action ?mode net add
  and get_sub = add_action ?mode net sub
  in fun pl_no -> match get_add pl_no, get_sub pl_no with
  | true, false -> 1
  | false, true -> (-1)
  | _ -> 0
;;

let add_action_group ?mode net names =
  let gets = List.map (add_action ?mode net) names in
  let folder acc name get = if get then name :: acc else acc in
  fun pl_no -> 
    let got = List.map (fun get -> get pl_no) gets in
    List.fold_left2 folder [] names got
;;


let add_sprite_set_info ser set =
  let ser = Serialize.list ser in
  let recv lst =
    Sprite.Set.clear set;
    List.iter (Sprite.Set.add set) lst
  in
  let send = Net.add_server_to_client ser recv in
  let folder lst spr = spr :: lst in
  let synchronizer pl_no = send [pl_no] (Sprite.Set.fold folder set []) in
  Net.add_synchronizer synchronizer
;;

