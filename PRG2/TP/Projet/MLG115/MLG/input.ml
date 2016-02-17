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

type mode = {
  name : string;
  handle_event : Sdlevent.event -> unit;
  bindings : (Sdlkey.t * bool, unit -> unit) Hashtbl.t;
  super : bool; (* Can this mode be set by the user *)
};;

let log = Parser.create_log "debug_input" "[Input] " false;;

let global_bindings = Hashtbl.create 3;;

let mode_names = Hashtbl.create 3;;

exception Quit;;

let curr_mode = ref None;;

module P = Parser;;

let mode_parser = {
  P.lex = (fun lexbuf -> try Hashtbl.find mode_names (P.string.P.lex lexbuf)
      with Not_found -> raise (P.Error "No such input mode"));
  P.deparse = (fun mode -> mode.name);
  P.complete = (fun lexbuf -> []) (*TODO*);
  P.accept = (fun x -> x);
  P.desc = "Input mode";
};;

let super_mode_parser = {mode_parser with
  P.lex = (fun lexbuf -> let ret = mode_parser.P.lex lexbuf in
    if ret.super = false then raise (P.Error "Not a super mode") else ret);
};;
  
let curr_super_mode =
  Parser.add_variable "input_super_mode" (P.option super_mode_parser) None 
;;
(*let curr_super_mode = ref None;;*)

let add_mode ?(super=false) name f = 
  let ret = 
    {name = name; handle_event = f; bindings=Hashtbl.create 16; super=super} 
  in Hashtbl.replace mode_names name ret;
  ret
;;

let set_mode m = curr_mode := Some m;;

let get_mode () = 
  match !curr_mode with
  | Some m -> m 
  | None -> failwith "MLG.Input.get_mode: no mode is set"
;;

let get_real_mode () = 
  match (!curr_super_mode, !curr_mode) with
  | (Some m, _) -> m
  | (None, Some m) -> m
  | (None, None) -> failwith "MLG.Input.get_real_mode: no mode is set"
;;

let repeat_handler = ref None;;

let set_repeat_handler f = repeat_handler := f;;

Unix.set_nonblock Unix.stdin;;

let process_events ?(events_per_frame = 20) () =
  begin 
    if Sys.os_type <> "Win32" then
      try Parser.parse (read_line ()) () with
      | Parser.Error s -> Log.error s
      | Sys_blocked_io -> ()
  end;
  Sdlevent.pump ();                    
  let handle_repeats = 
    match !repeat_handler with 
    | None -> false
    | Some (fnctn) -> fnctn ()
  in
  let handle_event event = 
    let real_mode = get_real_mode () in
    let process_key key =
      try Hashtbl.find global_bindings key ()
      with Not_found ->
        try Hashtbl.find real_mode.bindings key ()
        with Not_found -> real_mode.handle_event event
    in
    match event with
    | Sdlevent.KEYDOWN key -> process_key (key.Sdlevent.keysym, true)
    | Sdlevent.KEYUP key -> process_key (key.Sdlevent.keysym, false)
    | Sdlevent.QUIT -> raise Quit
    | _ -> real_mode.handle_event event
  in
  let event_lst = Sdlevent.get events_per_frame in
  List.iter handle_event event_lst;
  event_lst <> [] || handle_repeats
;;

let bind_global (key, cmd) =
  try 
    log ("Binding: " ^ key);
    let (key_sym, press) = Keys.key_of_string key in
    Hashtbl.add global_bindings (key_sym, press) cmd
  with
  | Keys.Unknown -> Log.error ("Incorrect key: " ^ key)
;;

let bind_mode (key, mode, command) = 
  try 
    let (key_sym, press) = Keys.key_of_string key in
    Hashtbl.replace mode.bindings (key_sym, press) command
  with
  | Keys.Unknown -> Log.error "Incorrect key."
  | Not_found -> Log.error "No such mode"
;;

let actions = Hashtbl.create 10;;

let bind_action params =
  let do_bind key action set =
    try
      let act_begin, act_end, act_mode = Hashtbl.find actions action in
      let (key_sym, _) = Keys.key_of_string key in
      let our_begin () = act_begin set
      and our_end () = act_end set in
      Hashtbl.replace act_mode.bindings (key_sym, true) our_begin;
      Hashtbl.replace act_mode.bindings (key_sym, false) our_end
    with 
    | Keys.Unknown -> raise (Parser.Error ("No such key: " ^ key))
    | Not_found -> raise (Parser.Error ("No such action: " ^ action))
  in
  match params with
  | ((key, action), Some set) -> do_bind key action set
  | ((key, action), None) -> do_bind key action 0
;;

let current () =
  match !curr_mode with
  | Some (m) -> m
  | None -> Log.fatal "Input.current"
;;

let add_action ?(mode = (current ())) action_name fun_begin fun_end =
  Hashtbl.replace actions action_name (fun_begin, fun_end, mode)
;;

let action params =
  let do_action action start set =
    try
      let act_begin, act_end, act_mode = Hashtbl.find actions action in
      if not (get_mode () == act_mode) then raise (Parser.Error "Action not available in this mode") else
      if start then act_begin set else act_end set
    with 
    | Not_found -> raise (Parser.Error ("No such action: " ^ action))
  in
  match params with
  | (action, start, Some set) -> do_action action start set
  | (action, start, None) -> do_action action start 0
;;

Parser.add_command "bind_global" (Parser.pair Parser.string Parser.command) 
  "Binds a key to a command in all modes" bind_global;;
Parser.add_command "bind_mode" (Parser.triple Parser.string mode_parser Parser.command)
  "Binds a key to a command in one mode" bind_mode;;
Parser.add_command "bind_action" 
  (Parser.pair (Parser.pair Parser.string Parser.string) (Parser.option (Parser.int ())))
   "Binds a key to an action (for local player no if given)" bind_action;;
Parser.add_command "action"
  (Parser.triple Parser.string Parser.bool (Parser.option (Parser.int ())))
   "Starts or stops an action (for local player no if given)" action;;

Parser.add_command "quit" Parser.unit "Quit to OS" (fun () -> raise Quit);;

(*
let asd (a, sth) =
  match sth with
  | None -> Log.info "none"
  | Some _ -> Log.info "some"
in
Parser.add_command "asd" (Parser.pair Parser.string (Parser.option Parser.command)) "" asd;;
*)
