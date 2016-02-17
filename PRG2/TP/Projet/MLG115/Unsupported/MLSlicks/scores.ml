exception Enter;;

let name = ref "";;

let max_results = 10;;

let add_char charr = name:= (!name)^(String.make 1 charr)
;;

let rem_char () =
  try     name:= String.sub !name 0 ((String.length !name)-1) 
  with _ -> ()
;;

let font_white = Font.load "Data/font.png";;
let font_red   = Font.load "Data/font1.png";;
let font_green = Font.load "Data/font2.png";;

let result_string (m, s, cs) = 
 let ms = if m < 10 then ("0"^string_of_int(m)) else string_of_int(m) 
 and ss = if s < 10 then ("0"^string_of_int(s)) else string_of_int(s) 
 and css = if cs < 10 then ("0"^string_of_int(cs)) else string_of_int(cs) in
 (ms^":"^ss^"."^css)
;;

let draw result player () = 
  Video.fill(0,0,0);
  Font.draw_string font_red 220 100 ("Your result: "^(result_string result)); 
  Font.draw_string font_red 205 140 ("Enter your name player "^string_of_int(player));
  Font.draw_string font_white 205 180 !name  
;;


let draw_all_scores slist () = 
  Video.fill(0,0,0);
  let rec draw score_list position = 
    match score_list with 
    | (name, m, s, cs)::tl -> 
                         draw tl (position+1);
                         Font.draw_string font_white 50  (position*35 + 80) name;
	                       Font.draw_string font_white 500 (position*35 + 80) (result_string (m, s, cs))
    | [] -> () 
  in
  Font.draw_string font_green 250 50 ("HALL OF FAME");
  draw (List.rev slist) 0 ;
;;

let load_scores file = 
  let rec load score_list ch = 
    try
      let name = input_line ch in
      let  m = int_of_string (input_line ch) in
      let  s = int_of_string (input_line ch) in
      let cs = int_of_string (input_line ch) in
      load ((name, m, s, cs) :: score_list) ch
    with End_of_file -> score_list
  in
  let channel_in = open_in file in
  let sclist = List.rev(load [] channel_in) in
  close_in channel_in;
  sclist
;;

let save_scores file score_list = 
  let rec save slist ch = 
    match slist with
      (name, m, s, cs)::tl -> 
                 output_string ch (name^"\n");
                 output_string ch ((string_of_int m)^"\n") ;
                 output_string ch ((string_of_int s)^"\n") ;
                 output_string ch ((string_of_int cs)^"\n") ;
                 save tl ch
    | [] -> ()
  in
  let channel_out = open_out file in
  save score_list channel_out;
  close_out channel_out
;;


let better (n1, m1, s1, cs1) (n2, m2, s2, cs2) =
  if m1 < m2 then true
  else if m1 > m2 then false
  else if s1 < s2 then true
  else if s1 > s2 then false
  else if cs1 < cs2 then true
  else if cs1 > cs2 then false
  else true
;;

let add_score s slist =
 let rec add score hdlist tllist = 
   match tllist with 
     hd::tl -> if better score hd then add score (hd::hdlist) tl
               else (List.rev (hdlist))@(score::tllist)
   | [] -> (List.rev hdlist)@[score]
 in
 let new_list = add s [] slist in
 if List.length new_list > max_results then List.tl(new_list) else new_list
;;


let init_event()=
  let event_fun = function
    | Sdlevent.KEYDOWN {Sdlevent.keycode = c; Sdlevent.keysym = s } ->
    	(match s with
	       Sdlkey.KEY_RETURN ->    raise Enter 
     	|  Sdlkey.KEY_BACKSPACE -> rem_char() 
	    | _	->                     add_char (try Sdlkey.char_of_key s with _ -> '0')
	    )
    | _ -> ()
  in Input.set_mode (Input.add_mode "scores" event_fun)
;;


let scores results = 
  Parser.parse "exec \"Data/mainmenu.txt\"" ();
  init_event();
  let which = ref (-1) in
  let shorten_score (dm, m, dks, s, dcs, cs) = (10*dm + m, 10*dks + s, 10*dcs + cs) in
  let non_zero_score m s cs =  not (m+s+cs = 0) in
  let write_it score score_list =
    let min sl = 
      match sl with
        hd::tl -> hd
      | [] -> ("dummy", 100, 0, 0)
    in
    (List.length score_list < 10 || (better score (min score_list))) 
  in
  let write score score_list = add_score score score_list in

  let scores_list = load_scores "Data/scores" in
  
  let save_one_score sc_list one_score = 
   which:= !which + 1;
   name:="";
   let (m, s, cs) = shorten_score one_score in
     if (non_zero_score m s cs) && (write_it ("", m, s, cs) sc_list) then 
     begin
      try begin ignore (Helpers.main_no_quit (fun _ -> ()) (draw (m, s, cs) !which)); sc_list end with
          Enter -> write (!name, m, s, cs) sc_list;
         | ex -> sc_list
     end
     else sc_list;

   
   
   in

  
  let new_list = Array.fold_left save_one_score scores_list !results in
  save_scores "Data/scores" new_list;
  try ignore (Helpers.main_no_quit (fun _ -> ()) (draw_all_scores new_list )) with
   Enter -> ()
  | ex -> raise ex;
      
;;


