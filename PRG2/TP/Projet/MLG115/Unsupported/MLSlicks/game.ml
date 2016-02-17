

let init n l = 
 Helpers.add_video_mode_var Graph.video_change_fun;
 Net.init Graph.player_change_fun;
 let create_server = Parser.parse "server" in
 create_server ();
 let new_player = Parser.parse "connect" in
   for i=1 to (n) do
       new_player ()
   done;
 Race.total_loops := l;
 Graph.get_cur_x := Helpers.add_action_pair ~mode:Race.slicks_mode false "right" "left";
 Graph.get_cur_y := Helpers.add_action_pair ~mode:Race.slicks_mode false "up" "down";
;;

let rec main () = 

  let clocks = Race.run () in 
  Scores.scores clocks;
  Info.wait2 "Data/again.png" ();
  main(); 
;;
