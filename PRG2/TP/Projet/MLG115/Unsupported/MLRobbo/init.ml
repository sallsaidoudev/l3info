(* Nic nie jest widoczne na zewn±trz *)
(* Domy¶lne ustawienia MLGame: tryb graficzny, mapowanie itp. *)
let video_change_fun () = 
  let (x, y) = Video.get_resolution () in
  if x != 800 || y != 600 then Log.info "Zalecana rozdzielczo¶æ to 800x600"
  else ();
  Video.fill (0, 0, 0)
;;
Helpers.add_video_mode_var video_change_fun;;
Parser.parse "exec \"Data/mlgame.txt\"" ();;
(*
Parser.add_command "full" (fun _ -> Parser.parse "set video_mode 800x600f" ());;
Parser.add_command "window" (fun _ -> Parser.parse "set video_mode 800x600" ());;
*)
(* Zapalam generator liczb losowych *)
Random.self_init ();;
