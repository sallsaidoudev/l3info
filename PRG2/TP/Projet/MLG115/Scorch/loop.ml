(*let img1 = Exp_gen.exp1();;
let img2 = Exp_gen.exp2();;
let img3 = Exp_gen.exp3();;*)
(*let img4 = Exp_gen.expl4;;*)

let title_img = Video.optimize ~alpha:true (Video.load_image (Options.gfx_path^"stitle.png"));;
(*let ruin_img = Video.load_image (Options.gfx_path^"ruin.png");;*)

let large_font = Font.load ~alpha:true (Options.gfx_path^"hgotic.png");;

let draw_title () =
  Mouse.center ();
  Video.fill (32, 55, 84);
  Video.blit title_img 50 50;
  (*if !Options.draw_title_pic then begin
    Video.blit ruin_img 70 120 end*)
;;  

let draw_game () =
  Video.fill (16, 27, 42)(*5,5,5*);
  Mouse.frame ();
  (*Video.blit img4 (-(!Options.d1)) 60;*)
  Block.draw ();
  Tank.draw ();
  Missle.draw ();
  Explosion.draw (); 
  Shop.draw ();
;;

let draw () =
  begin
    match !Flow.state with
    | Flow.Idle -> 
      draw_title ();
    | _ ->
      draw_game ();
  end;
  (*Menu.draw ()*)
  Menu.draw_test ();
  Menu.draw_fps ();
;;

let first = ref true;;
let try_read_rc () =
  if !first then begin
    first := false;
    Parser.parse "exec \"./cfg/scorch.rc\"" ()
  end
;;

let frame () =
  try_read_rc ();
  for i=1 to !Options.cycles_per_frame do
    Missle.frame ();
    Tank.frame_small ();
  done;
  Tank.frame ();
  (*Ghost.frame ();*)
  Explosion.frame ();
  Flow.frame ();
;;
