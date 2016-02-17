Helpers.add_video_mode_var (fun () -> ());;
Input.set_mode (Input.add_mode "shooter" (fun _ -> ()));;
Parser.parse "exec \"../Data/default.txt\"" ();;
