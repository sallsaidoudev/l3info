let draw_fun _ =
  Video.fill (127, 127, 0);
  Players.draw ();
  Enemy.draw ();
  Ammo.draw ()
;;

let fr_no = ref 0;;

let new_frame_fun () =
  incr fr_no;
  Players.frame !fr_no;
  Enemy.frame !fr_no;
  Ammo.frame ()
;; 

Helpers.main new_frame_fun draw_fun;;
