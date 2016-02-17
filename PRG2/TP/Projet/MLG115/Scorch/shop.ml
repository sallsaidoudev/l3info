open Widget

let pos = ref 0

let str_lst2wid lst =
  let box4 s1 s2 s3 s4 =
    deco ( hor_pair ( hor_pair (static_text s1, static_text s2), hor_pair (static_text s3, static_text s4)))
  in
  match lst with
  | s1 :: s2 :: s3 :: [s4] -> box4 s1 s2 s3 s4
  | _ -> box4 "error" "" "" ""
;;

let str_lst2wid lst =
  let fixwd_str w s = fixed_wd_box (w, static_text s) in
  let box4 s1 s2 s3 s4 s5 =
      deco (handler ([Ok, Parser.parse ("buy 1 "^s2)],
        ( hor_pair 
          ( hor_pair (fixwd_str 30 s1, fixwd_str 200 s3), 
            hor_pair (fixwd_str 80 s4, fixwd_str 30 s5)))
      ))
  in
  match lst with (* just barfastic! *)
  | s1 :: s2 :: s3 :: s4 :: s5 :: tl -> box4 s1 s2 s3 s4 s5
  | _ -> box4 "error" "" "" "" ""
;;

let new_shop cash_str lst =
  center_box (
    vert_pair (deco (static_text ("Cash: "^cash_str)),
    (deco 
      (vert_focus_list (pos, no_deco, shd_frame,
        List.map (fun txts -> deco (str_lst2wid txts)) lst
  ))
)));;

let widget = ref (new_shop "" []);;

let mode = Utils.add_widget_mode ~super:true "shop" (fun () -> !widget) Utils.std_widget_mode;;

let draw () =
  let active_player = (*ugly hack, move to flow?*) 
    match !Flow.state with
      | Flow.Turn plid -> Some plid
      | _ -> None
  in
  let weapon_quant wpid = (*more ugly hack *)
    match active_player with
      | Some plid -> ( 
        try string_of_int(
         Hashtbl.find (Sprite.get_data (Hashtbl.find Tank.tanks plid)).Tank.weapons wpid)
        with Not_found -> "0")
      | _ -> ""
  in
  let cash_str = 
    match active_player with
      | Some plid -> string_of_int (Hashtbl.find Flow.players plid).Flow.cash
      | None -> ""
  in
  widget := new_shop cash_str (List.map 
    (fun (wpid, weapon) ->
       [string_of_int weapon.Weapon.no;
       wpid;
       weapon.Weapon.name;
       " $"^(string_of_int (int_of_float weapon.Weapon.price));
       weapon_quant wpid]
    ) (Weapon.sorted_list ()));
  if Input.get_real_mode () <> mode then () else
    draw (0, 0) (Video.get_resolution ()) shd_frame !widget
;;
