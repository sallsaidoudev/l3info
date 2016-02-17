let sock = Tcp.create_socket 1234 10;;

let rec main () =
  let new_connections = Tcp.check_socket sock in
  let iterator sock =
    List.iter print_endline (Tcp.read sock);
    flush stdout;
    Tcp.write sock "Asd" 0 3;
    Unix.sleep 1;
    Tcp.close sock
  in
  List.iter iterator new_connections;
  main ()
in 
main ();;

