open Protocol;;

let con = Udp.connect "localhost" 1234;;
let send3 = Protocol.c2s_add "FI[C]S" (fun _ _ -> ());;
let send4 = Protocol.c2s_add "[C[I]]" (fun _ _ -> ());;
let send5 = Protocol.c2s_add "[[C][C]]" (fun _ _ -> ());;

send3 con [F 5.23; I 47; List []; S "qwe"];;
send3 con [F 3.14; I 17; List [C '^'; C '&'; C '('; C '*'; ]; S "asd"];;

send4 con [List []];;
send4 con [List [C 'a'; List []; C 'b'; List [I 5; I 8; I 9]]];;

send5 con [List [List [C 'a'; C 'b']; List []; List []; List [C '*']]];;

if Udp.poll con 100.0 then ignore (Udp.recv con (String.create 3) 0 3);;



