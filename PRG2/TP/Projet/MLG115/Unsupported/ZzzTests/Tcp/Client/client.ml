let con = Tcp.connect "localhost" 1234;;
Tcp.write con "qwe" 0 3;;
Unix.sleep 1;;
List.iter print_endline (Tcp.read con);;
