let nicks = Hashtbl.create 10;;
let net_set_nick = Net.add_broadcast Serialize.string (Hashtbl.replace nicks);;
let set_nick args = 
  let set_nick_aux name local_no =
    try net_set_nick (List.nth (Net.get_local_players ()) local_no) name
    with Failure "nth" -> Log.error "No such player"
  in match args with
  | (name, None) -> set_nick_aux name 0
  | (name, Some i) -> set_nick_aux name i
;;
Parser.add_command "nick" (Parser.pair Parser.string (Parser.option (Parser.int ()))) 
  "Sets nick of local player with optionally given number" set_nick;;

let get n = try Hashtbl.find nicks n with Not_found -> "Player" ^ (string_of_int n);;

(* TEST *)

let chat_send =
  let log i str = Log.info ((get i) ^ " sais:" ^ str) in
  Net.add_broadcast Serialize.string log
in let chat_aux local_no word = 
  try chat_send (List.nth (Net.get_local_players ()) local_no) word
  with Failure "nth" -> Log.error "No such player"
in let chat_cmd = function
  | (word, None) -> chat_aux 0 word
  | (word, Some i) -> chat_aux i word
in
Parser.add_command "say" (Parser.pair Parser.string (Parser.option (Parser.int ())))
  "Chats with other players with optionally given player number" chat_cmd;;
