Video.set_mode false (1200, 675) 16;;
Helpers.add_video_mode_var (fun () -> ());;
Parser.parse "exec \"cfg/base.cfg\"" ();;
Input.set_mode (Input.add_mode "shooter" (fun _ -> ()));;
Helpers.main (fun _ -> ()) (fun () -> Video.fill (242, 210, 110));;
