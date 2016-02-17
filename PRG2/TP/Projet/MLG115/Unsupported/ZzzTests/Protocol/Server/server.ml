let sock = Udp.create_socket 1234;;
let recver addr lst = 
  print_string ((Udp.describe_connection addr) ^ ": ");
  let rec parse = function
    | h :: t -> print_string (match h with
      | Protocol.S str -> "S(" ^ str ^ ") "
      | Protocol.I i   -> "I(" ^ (string_of_int i)^") "
      | Protocol.C c   -> "C(" ^ (Char.escaped c) ^ ") "
      | Protocol.F f   -> "F(" ^ (string_of_float f)^") "
      | Protocol.List l -> print_string "[ "; parse l; "] "
      ); parse t
    | _ -> ()
  in parse lst; print_endline "."
;;

Protocol.c2s_add "FI[C]S" recver;;
Protocol.c2s_add "[C[I]]" recver;;
Protocol.c2s_add "[[C][C]]" recver;;

let rec main () =
  if (Udp.poll sock 1.0) then 
    Protocol.server_net_check sock
  else
    print_char '.';
  flush stdout;
  main ()
in 
main ();;

