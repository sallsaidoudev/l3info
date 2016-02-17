
let clock_font = Font.load "Data/font.png"

let pl_clock_font = Font.load "Data/font1.png"
let pl_clock_font_finished = Font.load "Data/font2.png"

let curr_time =  ref (0, 0, 0, 0, 0, 0);;
let begin_ticks = ref 0;;

let start = ref false;;

let players_clocks = ref [| (0, 0, 0, 0, 0, 0); (0, 0, 0, 0, 0, 0); (0, 0, 0, 0, 0, 0); (0, 0, 0, 0, 0, 0); |];;
let stopped = ref[|false;false;false;false;|];;

let pl_clocks_draw oncontext players = 
 let pl_clock pl = 
   let font = if !stopped.(pl) then pl_clock_font_finished else pl_clock_font in
   let (t1, t2, t3, t4, t5, t6) =  (!players_clocks).(pl) in
   let s = (Printf.sprintf "%d: %d%d:%d%d.%d%d" (pl+1) t1 t2 t3 t4 t5 t6) in
   Font.draw_string ~on:oncontext font (Arena.pl_clock_pos_x pl) (Arena.pl_clock_pos_y pl) s
 in
 let pl_no = List.length players in
 for i=0 to pl_no-1 do
   pl_clock i; 
 done;
;;

let draw onc = 
 let (t1, t2, t3, t4, t5, t6) = !curr_time in
 let s = (Printf.sprintf "%d%d:%d%d.%d%d" t1 t2 t3 t4 t5 t6) in
  Font.draw_string ~on:onc clock_font Arena.clock_pos_x Arena.clock_pos_y s;
  pl_clocks_draw onc (Net.get_local_players ())
;;


let time ticks =
   let msecs = ticks mod 1000
   and seconds_total = ticks / 1000 in
    let sec_aux = seconds_total mod 60
    and min_aux = seconds_total / 60 in
     (min_aux/10, min_aux mod 10, sec_aux / 10, sec_aux mod 10, msecs / 100, (msecs mod 100) / 10)
;;

let init ticks =
  begin_ticks := ticks;
  start:= true
;;


let stop_nth i if_last_loop = 
 (!players_clocks).(i) <- !curr_time;
 !stopped.(i) <- if_last_loop;
 if_last_loop
;;


let time_flow ticks =
 if !start then curr_time := time (ticks - !begin_ticks)
 else ()
;;

let reset_clocks ticks = 
players_clocks := [| (0, 0, 0, 0, 0, 0); (0, 0, 0, 0, 0, 0); (0, 0, 0, 0, 0, 0); (0, 0, 0, 0, 0, 0); |];
start:=false;
curr_time := (0,0,0,0,0,0);
stopped := [|false;false;false;false;|];
;;

let get_players_clocks () =
  let mapper pl pl_clk = 
    if !stopped.(pl) then pl_clk else (0,0,0,0,0,0)
  in
  Array.mapi mapper !players_clocks
;;
