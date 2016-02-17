type level = {
  bg_color      :int*int*int;
  image         :(Element.t, Level_data.t) Level_image.t;
  active        :Element.t list;
  count         :int
};;

(***********************************************************)
(* Konstruktory plansz *)
let level_name number = "Data/level_" ^ (string_of_int number) ^ ".rob";;

(* Daj planszê numer [number] z danymi równymi [data], w wyniku typ level *)
let get_level data number =
  let bg_color = (3, 150, 5) in
  let stream = open_in (level_name number) in
  let image = Level_image.load Element.by_char Empty.create data stream in
  let screw_count = Level_image.count Collected.Screw.my_kind image in
  let active = Level_image.get_all image in
  let robbo_pos = 
    let robbo = Level_image.find_first Robbo.my_kind image in
    Element.get_pos robbo
  in
  close_in stream;
  if screw_count <= 0 then ignore (Capsule_r.ready_to_take_off image) else ();
  Level_data.set_screw data screw_count;
  Graph.follow robbo_pos;
  {bg_color = bg_color; image = image; active = active; count=0}
;;
let default_level = get_level (Level_data.create 1) 1;;

(* Referencja do aktualnej planszy - nie chcia³o mi siê robiæ tego "³adnie" *)
let my_level = ref default_level;;

let set_level number = 
  let data = Level_data.create number in
  my_level := (get_level data number)
;;

let set_next_level () =
  let cur_data = Level_image.get_data !my_level.image in
  let cur_nr = Level_data.get_nr cur_data in
  let data = Level_data.create_with cur_data in
  Level_data.inc_nr data;
  my_level := (get_level data (cur_nr + 1))
;;
let print file_name = 
  let stream = open_out file_name in
  let my_map e = Char.escaped (Element.get_id e) in
  Level_image.print stream my_map !my_level.image;
  close_out stream
;;

(***********************************************************)
(* Restart planszy *)
let next_level_exist () = 
  let image = !my_level.image in
  let data = Level_image.get_data image in
  let nr = Level_data.get_nr data in
  let file_name = level_name (nr + 1) in
  let file_exists name = 
    try 
      let stream = open_in name in
      close_in stream;
      true
    with Sys_error _ -> false
  in
  file_exists file_name
;;
let restart_ok () =
  let data = Level_image.get_data !my_level.image in
  let live = Level_data.get_live data in
  live > 0
;;
let restart () =
  let data = Level_image.get_data !my_level.image in
  let new_data = Level_data.create_with data in
  let nr = Level_data.get_nr new_data in
  Level_data.dec_live new_data;
  my_level := (get_level new_data nr)
;;
let blow_all () =
  let image = !my_level.image in
  let elems = 
    let kind_ok elem = not 
      (Empty.my_kind elem || Static.Wall.my_kind elem || Static.Nothing.my_kind elem) in
    Level_image.get_elems kind_ok image
  in
  let rec switch_to_blows acc = function
    |h::t -> begin
               let pos = Element.get_pos h in
               let b = Blow.put_new image pos in
               switch_to_blows (b::acc) t
             end
    |[]   -> acc
  in
  let blows = switch_to_blows [] elems in
  my_level := {!my_level with image=image; active=blows; count=0};
;;
let remove_col col =
  let image = !my_level.image in
  for row = 0 to Level_image.level_height - 1 do
    let pos = (col, row) in
    let elem = Level_image.get image pos in
    Element.set_as_removed elem;
    ignore (Element.put_new Static.Nothing.create image pos);
  done;
;;

(***********************************************************)
(* Kroki gry *)
type action = NOTHING|MOVE of Direction.t|FIRE of Direction.t;;
let by_step () =
  List.iter Element.next_step !my_level.active;
  !my_level.active
;;

let act_robbo = function
  |MOVE d  -> Robbo.set_direction d
  |FIRE d  -> Robbo.set_fire d
  |NOTHING -> begin Robbo.set_direction Direction.STAY; Robbo.set_fire Direction.STAY end
;;

let by_action () =
  let lst = !my_level.active in
  let play = Element.next_action !my_level.image in
  let ll = List.rev_map play lst in
  List.flatten ll
;;

let next_action get_action =
  let last_count = !my_level.count in
  let count = if last_count = 0 then Graph.frame_height else last_count - Element.def_speed in
  let 
    lst = 
    if !my_level.count = 0 then begin
      act_robbo (get_action ());
      by_action ()
    end else begin ignore (get_action ()); by_step () end
  in
  my_level := 
  {bg_color = !my_level.bg_color; image = !my_level.image; active = lst; count=count};
(*
  let l = List.length lst in
  Log.info ("Aktywnych: "^(string_of_int l));
*)
;;

(***********************************************************)
(* Prezentacja graficzna *)
let draw_image () =
  Graph.follow_action ();
  let level = !my_level in
  Video.fill ~on:Graph.level_context level.bg_color;
  Level_image.iter Element.draw level.image
;;
let draw_info ?(always=false) () =
  let data = Level_image.get_data !my_level.image in
  if always || Level_data.redraw data then Level_data.draw_all data else ();
;;
