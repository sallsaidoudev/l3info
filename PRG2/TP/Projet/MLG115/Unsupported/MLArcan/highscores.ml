

let score _ = ();;

let draw _ =
  Board.draw ();
  Ball.draw ();
  Palka.draw ();
;;


let frame fr= 
  Board.frame fr;
  Ball.frame  fr;
  Palka.frame fr;
;;

