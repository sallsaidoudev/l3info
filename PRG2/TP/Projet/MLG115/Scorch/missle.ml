type t_trigger =
  Null | Hit | Hit_block | Hit_tank | Apogee | Time_once of int | Time_every of int | Stop
;;

type t_action = (t Sprite.t) -> unit
and t = {
  plid : int;
  mid : string;
  mutable x : float;
  mutable y : float;
  mutable vx : float;
  mutable vy : float;
  mutable time : int;
  mutable actions : (t_trigger * t_action) list;
};;

let missle_table = Hashtbl.create 10;;

let pic_pixel = Video.load_image (Options.gfx_path^"pixel.png");;

let wind = Parser.add_variable "wind" (Parser.int ()) 0;;
let wind_change () = wind := Random.int (!Options.max_wind + 1) ;;

(*edge should be odd!*)
let frames, edge = 64, 11;;
let o = (edge - 1) / 2;;

let missle_frames =
  Video.optimize (Video.color_key (Video.provide_image 
  (fun () ->
    let d1, d2 = 4. , (-4.) in
    let dims = edge * frames, edge in
    let surf = Video.create_surface dims in
    (*Sdlvideo.set_color_key surf (Sdlvideo.map_RGB surf (255,0,255));*)
    Video.fill ~surf (255, 0, 255);
    for i = 0 to (frames - 1) do
      let angle = ( 6.28 /. (float frames) ) *. (float i) in
      let front = o + (int_of_float ((sin angle) *. d1)) + (edge * i), o + int_of_float ((cos angle) *. d1)  in
      let p2 = o + (int_of_float ((sin angle) *. d2)) + (edge * i), o + int_of_float ((cos angle) *. d2)  in
      let p3 = o + (edge * i), o in 
      Video.line ~surf front p3 (128, 128, 128);
      Video.line ~surf p3 p2 (255, 255, 255)
    done;
    surf
  )))
;;

let missles = Sprite.Set.create 10;;
Sprite.Set.set_collision missles 100 100;;
Sprite.Set.set_boundary missles (-1000) (-1000) 1000 1000;;

(* commands *)

let any () =
  Sprite.Set.fold (fun _ _ -> true) missles false
;;

let plid missle = (Sprite.get_data missle).plid;;

let clear () =
  Sprite.Set.clear missles
;;

let create_internal plid mid x y vx vy = 
  let actions = 
    try Hashtbl.find missle_table mid
    with Not_found -> []
  in
  let data = {
     plid = plid;
     mid = mid;
     x = x; y = y;
     vx = vx; vy = vy;
     time = 0;
     actions = actions;
    }
  in
  ignore (Sprite.create ~set:missles data missle_frames ~width:edge (int_of_float x, int_of_float y))
;;

let create plid mid x y vx vy = 
  create_internal plid mid (x -. (float o)) (y -. (float o)) vx vy
;;

(* workhorses *)

(* actions *)

let explode eid sprite =
  let offset_pos (x, y) = (x + o, y + o) in
  Explosion.make (plid sprite) eid (offset_pos (Sprite.get_pos sprite));
  Sprite.delete sprite
;;

let explode_nondel eid sprite =
  let offset_pos (x, y) = (x + o, y + o) in
  Explosion.make (plid sprite) eid (offset_pos (Sprite.get_pos sprite));
;;

let rot ang (x, y) =
  ( (x *. (cos ang)) -. (y *. (sin ang)), (x *. (sin ang)) +. (y *. (cos ang)) )
;;

let fan_split mid cnt width offset sprite = 
  let data = Sprite.get_data sprite in
    let step = width /. (float cnt) in
    for i = 0 to (cnt - 1) do
      let vx, vy = rot ( offset -. (width /. 2.) +. (step *. (float i))) (data.vx, data.vy) in
      create_internal data.plid mid data.x data.y vx vy
    done;
  Sprite.delete sprite
;;

let abs_fan_split mid cnt width offset power sprite =
  let data = Sprite.get_data sprite in
    let step = width /. (float cnt) in
    for i = 0 to (cnt - 1) do
      let vx, vy = rot ( offset -. (width /. 2.) +. (step *. (float i))) (0. , -. power) in
      create_internal data.plid mid data.x data.y vx vy
    done; 
  Sprite.delete sprite
;;

let speed q sprite =
  let data = Sprite.get_data sprite in
  data.vx <- data.vx *. q;
  data.vy <- data.vy *. q
;;

(* triggers *)

let activate_trigger sprite act_trigger =
  let data = Sprite.get_data sprite in
  List.iter (fun (trigger, action) ->
    match act_trigger, trigger with
    | Time_every act_time, Time_every time -> 
      if ((act_time + 1) mod time = 0) then action sprite
    | act_trigger, trigger ->
      if act_trigger = trigger then action sprite
  ) data.actions
;;

let hit_block sprite =
  activate_trigger sprite Hit_block;
  activate_trigger sprite Hit
;;

let hit_tank sprite =
  activate_trigger sprite Hit_tank;
  activate_trigger sprite Hit
;;

(* parser commands *)

let trigger_buf = ref Null;;
let action_buf = ref (fun (spr: t Sprite.t) -> ());;
let list_buf = ref [];;

Parser.add_command "missle" Parser.unit "Begins missle definition"
  (fun () -> list_buf := []);;
  
Parser.add_command "end_missle" Parser.string "ends missle definition"
  (fun mid ->
    Hashtbl.replace missle_table mid !list_buf;
    Log.info ("Added missle "^mid);
    list_buf := [])
;;

Parser.add_command "trigger" (Parser.pair Parser.command Parser.command) 
  "adds a trigger - action pair to missle"
  (fun (trig, act) ->
    trig (); 
    act ();
    list_buf := (!trigger_buf, !action_buf) :: !list_buf)
;;

Parser.add_command "t_hit" Parser.unit "" (fun () -> trigger_buf := Hit);;
Parser.add_command "t_hit_tank" Parser.unit "" (fun () -> trigger_buf := Hit_tank);;
Parser.add_command "t_hit_block" Parser.unit "" (fun () -> trigger_buf := Hit_block);;
Parser.add_command "t_apogee" Parser.unit "" (fun () -> trigger_buf := Apogee);;
Parser.add_command "t_time_once" (Parser.int ()) ""
  (fun time -> trigger_buf := Time_once time);; 
Parser.add_command "t_time_every" (Parser.int ()) ""
  (fun time -> trigger_buf := Time_every time);; 
Parser.add_command "t_stop" (Parser.int ()) ""
  (fun time -> trigger_buf := Stop);;

Parser.add_command "a_explode" (Parser.string) ""
  (fun eid -> action_buf := explode eid);;
Parser.add_command "a_explode_nondel" (Parser.string) ""
  (fun eid -> action_buf := explode_nondel eid);;
Parser.add_command "a_fan_split" 
  (Parser.quadruple Parser.string (Parser.int ()) (Parser.float ()) (Parser.float ()) ) ""
  (fun (eid, cnt, width, offset) -> action_buf := fan_split eid cnt width offset);;
Parser.add_command "a_abs_fan_split" 
  (Parser.pentuple Parser.string (Parser.int ()) (Parser.float ()) (Parser.float ()) (Parser.float ())) ""
  (fun (eid, cnt, width, offset, power) -> action_buf := abs_fan_split eid cnt width offset power);;
Parser.add_command "a_speed" (Parser.float ()) ""
  (fun q -> action_buf := speed q);;

(* frame & draw *)

let frame () =
  let move sprite =
    let frame vx vy =
      let angle = 
        if (vy > 0.) then atan (vx /. vy) 
 	      else ((atan (vx /. vy)) +. 3.16  )
        in
      let frame = int_of_float ((angle *. (float frames)) /. 6.28) in
      if frame >= 0 then frame else frame + frames
    in
    let data = Sprite.get_data sprite in
    if (!Options.gravity > data.vy) && ( data.vy > 0. ) then 
      (activate_trigger sprite Apogee);
    data.vy <- data.vy +. !Options.gravity;
    data.vx <- data.vx +. ((float !wind) /. 50000.);
    data.x <- data.x +. data.vx;
    data.y <- data.y +. data.vy;
    activate_trigger sprite (Time_once data.time);
    activate_trigger sprite (Time_every data.time);
    if (data.vx = 0.) && (data.vy = 0.) then 
      activate_trigger sprite Stop;
    data.time <- data.time + 1;
    Sprite.set_animation_frame sprite (frame data.vx data.vy);
    Sprite.move_to sprite ( int_of_float data.x, int_of_float data.y );
    Sprite.check_collisions sprite;
    if not (Sprite.in_bounds sprite) then 
    begin 
      Sprite.delete sprite;
      Log.info "Missle outside world, deleted"
    end
  in 
  Sprite.Set.iter move missles
;;

let draw () = 
  Sprite.Set.iter Sprite.draw missles
;;
