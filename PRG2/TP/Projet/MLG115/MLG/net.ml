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

(* TODO send ip's to be able to rtansfer the server *)

let mlgame_default_port = 1234;;

let log = Parser.create_log "debug_net" "[Net] " false;;

(* Type representing the net state of an instance of the program. *)
type socks = 
  | No_connection (* No connection *)
  | Client of Socket.t (* Client with connection_to_server *)
  | Server of (Tcp.socket * (int, Socket.t option) Hashtbl.t)
  (* Server of (accept_socket, players) where players are pairs 
     (pl_no, Socket.t option). None means a local player, and Some sock means
     the connection to the player. If two players are on the same client both
     have the same sock *)
;;

(* All information about an instance *)
type state = {
  mutable socks : socks; (* As above *)
  mutable local_players : int list; (* Numbers of local players *)
  mutable pl_change_fun : (int -> bool -> bool -> unit);
  (* pl_change_fun is set by the game. It is the function called on each
  instance of the program when a new player comes or a player leaves. It
  informs the game that a player has connected or leaved. The game receives
  the number of player, is the player a local one and if the player is a new
  one. *) 
};;

(* The initial state of an instance *)
let state = {
  socks = No_connection;
  local_players = [];
  pl_change_fun = fun pl_no local conn -> ();
};;

(* C2S_Protocol is the hashtable pointing from protocol_id to functions
   responsible for handling received messages coming from clients on the
   server.
   
   These functions are set by the game when it uses add_broadcast or 
   add_client_to_server.

   The exact type is: (int, (Socket.t -> str -> int -> int -> int) Hashtbl.t)
   Where params are: prot_id, socket -> word -> pos -> len -> new_pos
*)
let c2s_protocol = Hashtbl.create 10;; 
let s2c_protocol = Hashtbl.create 10;; 

(* Will be handy *)
let (int_writer, int_reader) = Serialize.int;; 

(* Finds the smallest free binding in an int indexed hashtbl starting from i *)
let rec find_first_free hashtbl i =
  if (Hashtbl.mem hashtbl i) then find_first_free hashtbl (i + 1) else i
;;

let add_client_to_server (writer, reader) server_recv =
  let protocol_pos = find_first_free c2s_protocol 0 in
  let client_send pl_no alpha =
    match state.socks with
    | Server _ -> server_recv pl_no alpha (* We do it on the server *)
    | Client socket -> 
        let buf = Buffer.create 10 in
        int_writer buf protocol_pos;
        int_writer buf pl_no;
        writer buf alpha;
        Socket.send socket (Buffer.contents buf)
    | No_connection -> ()
  and our_server_recv sock word pos len =
    let (pos, pl_no) = int_reader word pos len in
    let (new_pos, alpha) = reader word pos len in
    server_recv pl_no alpha;
    new_pos
  in Hashtbl.replace c2s_protocol protocol_pos our_server_recv;
  client_send
;;

let rec filter_duplicates acc = function
  | s1 :: s2 :: t ->
      if s1 = s2
      then filter_duplicates acc (s2 :: t)
      else filter_duplicates (s1 :: acc) (s2 :: t)
  | [s1] -> s1 :: acc
  | [] -> acc
;;

let add_server_to_client (writer, reader) client_recv =
  let protocol_pos = find_first_free s2c_protocol 0 in
  let server_send pl_list alpha =
    match state.socks with
    | Server (_, clients) -> 
        let sock_list = 
          let folder acc elem = 
            match Hashtbl.find clients elem with
            | None -> acc 
            | Some sock -> sock :: acc
          in
          try List.fold_left folder [] pl_list
          with Not_found -> failwith "Net.add_server_to_client.server_send"
        in
        let single_list = filter_duplicates [] (List.sort compare sock_list) in
        let buf = Buffer.create 10 in
        int_writer buf protocol_pos;
        writer buf alpha;
        let sender sock = Socket.queue sock (Buffer.contents buf) in
        List.iter sender single_list
    | _ -> ()
  and our_client_recv word pos len =
    let (new_pos, alpha) = reader word pos len in
    client_recv alpha;
    new_pos
  in Hashtbl.replace s2c_protocol protocol_pos our_client_recv;
  server_send
;;  

let add_server_broadcast serialize client_recv =
  let server_send = add_server_to_client serialize client_recv in
  let server_send alpha =
    match state.socks with
    | Server (_, clients) -> 
        let folder pl_no _ acc = pl_no :: acc in
        let pl_nos = Hashtbl.fold folder clients [] in
        server_send pl_nos alpha;
        client_recv alpha
    | _ -> ()
  in server_send
;;

let add_broadcast serialize client_recv =
  let pl_serialize = Serialize.pair Serialize.int serialize in
  let server_send = add_server_broadcast pl_serialize 
      (fun (pl_no, alpha) -> client_recv pl_no alpha)
  in
  add_client_to_server serialize (fun pl_no alpha ->server_send (pl_no, alpha))
;;

let server_del_player_send =
  let del_player_recv pl_no =
    let local = List.mem pl_no state.local_players in
    log (Printf.sprintf "Player deleted: %i, local: %b" pl_no local);
    if local then state.local_players <- 
      List.filter (fun i -> i <> pl_no) state.local_players ;
    state.pl_change_fun pl_no local false
  in add_server_broadcast Serialize.int del_player_recv
;;

let del_player_send = 
  let server_del_player_recv pl_no () =
    match state.socks with
    | Server (_, clients) ->
        server_del_player_send pl_no;
        Hashtbl.remove clients pl_no
    | _ -> Log.fatal "Net.del_player_send"
  in
  add_client_to_server Serialize.unit server_del_player_recv
;;

let server_players_send =
  (* TODO maybe differ local players from nonlocal ones *)
  let serialize = Serialize.list Serialize.int in
  let clnt_recv_players pl_list =
    state.local_players <- state.local_players @ [List.hd pl_list];
    let new_pl_fun pl_no = state.pl_change_fun pl_no false true in
    List.iter new_pl_fun (List.tl pl_list)
  in add_server_to_client serialize clnt_recv_players
;;

let server_new_player_send =
  let new_player_recv pl_no =
    let local = List.mem pl_no state.local_players in
    log (Printf.sprintf "Player connected: %i, local: %b" pl_no local);
    state.pl_change_fun pl_no local true
  in add_server_broadcast Serialize.int new_player_recv
;;

let new_player_send = 
  let server_new_player_recv pl_no () =
    match state.socks with
    | Server (_, clients) ->
        begin 
          try match Hashtbl.find clients pl_no with
          | Some sock -> 
              let pl_no = find_first_free clients 0 in
              Hashtbl.add clients pl_no (Some sock);
              server_players_send [pl_no] [pl_no];
              server_new_player_send pl_no
          | None -> Log.fatal "Net.new_player_send.1"
          with | Not_found -> Log.fatal "Net.new_player_send.2"
        end
    | _ -> Log.fatal "Net.new_player_send.3"
  in add_client_to_server Serialize.unit server_new_player_recv
;;

let synchronizers = ref [];;

let add_synchronizer fnctn = synchronizers := fnctn :: !synchronizers;;

(* The order of actions here is really important *)
let add_client clients socket = 
  let pl_no = find_first_free clients 0 in
  let folder pl_no _ lst = pl_no :: lst in
  (* A list of player numbers where head is the new number *)
  let cli_list = pl_no :: (Hashtbl.fold folder clients []) in
  Hashtbl.add clients pl_no (Some socket);
  server_players_send [pl_no] cli_list;
  List.iter (fun fnctn -> fnctn pl_no) !synchronizers;
  server_new_player_send pl_no
;;

let server_check_all_clients clients =
  let to_del = ref [] in
  let check_client cli_no sock_opt =
    try
      match sock_opt with
      | Some socket ->
          let process_action word =
            let len = String.length word in
            let (new_pos, proto_pos) = int_reader word 0 len in
            begin try
              let server_recv = Hashtbl.find c2s_protocol proto_pos in
              ignore (server_recv socket word new_pos len)
            with 
            | Not_found -> Log.fatal "Net.server_check_all_clients"
            end
          in List.iter process_action (Socket.recv socket)
      | None -> () (* We do not need to check local players *)
    with Tcp.Lost ->
      server_del_player_send cli_no;
      to_del := cli_no :: !to_del
  in
  Hashtbl.iter check_client clients;
  List.iter (Hashtbl.remove clients) !to_del
;;

let client_process word =
  let len = String.length word in
  if len = 0 then () else
  let rec processor pos len =
    let (pos, proto_pos) = int_reader word pos len in
    let client_recv = 
      try Hashtbl.find s2c_protocol proto_pos
      with Not_found -> Log.fatal "Net.client_process"
    in let pos = client_recv word pos len in
    if pos < len - 1 then processor pos len
  in processor 0 len
;;

let process tick_time =
  match state.socks with
  | Server (accept_sock, clients) -> 
      let add_client_tcp sock = add_client clients (Socket.create sock) in
      List.iter add_client_tcp (Tcp.check_socket accept_sock);
      server_check_all_clients clients;
      if tick_time then begin
        let folder _ sock acc = match sock with
        | None -> acc
        | Some sock -> sock :: acc
        in
        let lst = Hashtbl.fold folder clients [] in
        let lst = List.sort compare lst in
        let lst = filter_duplicates [] lst in
        List.iter Socket.flush lst
      end;
      tick_time
  | Client socket ->
      let lst = Socket.recv socket in
      List.iter client_process lst;
      lst <> []
  | No_connection -> tick_time
;;

let connect arg =
  let server_connect_local clients =
    let pl_no = find_first_free clients 0 in
    Hashtbl.add clients pl_no None;
    state.local_players <- state.local_players @ [pl_no];
    server_new_player_send pl_no;
  and client_connect_first () =
    let hostname, port =
      match arg with
      | None -> "localhost", mlgame_default_port
      | Some (host, None) -> host, mlgame_default_port
      | Some (host, Some port) -> host, port
    in
    let sock = Tcp.connect hostname port in
    let socket = Socket.create sock in
    state.socks <- Client socket;
    log "Connection to server established"
  and client_connect_more sock =
    new_player_send (List.hd state.local_players) ();
  in
  try
    match state.socks with
    | Server (sock, clients) -> server_connect_local clients
    | Client sock -> client_connect_more sock
    | No_connection -> client_connect_first ()
  with
  | Tcp.Error str -> Log.error ("Connect: Tcp: " ^ str)
;;

let server port_opt =
  try
    let port = 
      match port_opt with
      | None -> mlgame_default_port
      | Some port -> port
    in
    let sock = Tcp.create_socket port 10 in
    state.socks <- Server (sock, (Hashtbl.create 10));
    log "Server established"
  with
  | Tcp.Error str -> Log.error ("Server: Tcp: " ^ str)
;;

let disconnect arg =
  let disconnect_pl pl_no =
    match state.socks with
    | Client sock -> 
        if List.length state.local_players > 1 then
          del_player_send pl_no ()
        else begin
          log "Closing connection";
          Socket.destroy sock;
          state.socks <- No_connection;
          state.local_players <- []
        end
    | Server _ -> 
        server_del_player_send pl_no
    | No_connection -> Log.error "Net.Disconnect: Not connected"
  in
  match arg with
  | None -> 
      begin match state.local_players with
      | [pl_no] -> disconnect_pl pl_no
      | [] -> Log.error "Net.Disconnect: Not connected"
      | _ -> Log.error "Net.Disconnect: Disconnect which player?"
      end
  | Some pl_no -> 
      let lst = [pl_no] in (* TODO maybe process more at a time? *)
      let iterator local_pl_no = 
        disconnect_pl (List.nth state.local_players local_pl_no)
      in 
      try 
        List.iter iterator lst
      with 
      | Failure "nth" -> Log.error "Net.Disconnect: No such player"
      | Failure "int_of_string" -> 
          Log.error "Net.Disconnect: player_no must be integer"
;;

let init pl_change_fun =
  state.pl_change_fun <- pl_change_fun;
  Parser.add_command "server" (Parser.option (Parser.int ())) 
    ("Establishes server (on given port or "^(string_of_int mlgame_default_port)^
     " if not given)") server;
  Parser.add_command "connect" (Parser.option (Parser.pair Parser.string
    (Parser.option (Parser.int ())))) "Connects and creates a new pl" connect;
  Parser.add_command "disconnect" (Parser.option (Parser.int ())) 
    "Disconnects the player from server" disconnect
;;

let check_privileged () =
  match state.socks with
    Client _ -> false
  | Server _ -> true
  | No_connection -> false
;;

let net_vars = Hashtbl.create 10;;

let var_chg_send = 
  let var_chg_recv (avar, aval) = 
    try Parser.set avar aval
    with Not_found -> failwith "MLG.Net.var_chg_recv received nonexisting var"
  and string_pair = Serialize.pair Serialize.string Serialize.string in
  add_server_broadcast string_pair var_chg_recv
;;

let add_var name aparser init =
  let callback alpha =
    if check_privileged () then 
      var_chg_send (name, aparser.Parser.deparse alpha)
    else raise (Parser.Error "Not privilaged")
  in
  ((Parser.add_variable name (Parser.callback callback aparser) init,
   fun str -> var_chg_send (name, str)))
;;

let get_local_players () = state.local_players;;
