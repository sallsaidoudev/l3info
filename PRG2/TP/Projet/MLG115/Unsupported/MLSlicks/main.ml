Parser.parse "exec \"Data/default.txt\"" ();;

let max_players = 4;;

let main () = 
  let loops = 2 in
  let players = 2 in
  if players <= max_players then
   begin
    Game.init players loops;
    Info.wait2 "Data/startup.png" ();
    Game.main ();
  end
  else Log.info "Too many players connected"
;;
main ();;

