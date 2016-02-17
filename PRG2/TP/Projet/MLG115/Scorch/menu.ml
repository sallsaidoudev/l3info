open Widget;;

type t_menu_cycle = ( (string -> string -> string) * (string -> string -> string) );;

type t_menu_edit_mode = View | Edit ;;
type t_menu_edit = ( (t_menu_edit_mode ref) * Input_edit.t );;

type t_menu_item =
 | Text of string
 | Command of (string * string)
 | Var of (string * string * t_menu_cycle option * t_menu_edit option)
 | Jump of (string * int)
;;

let int_step step : t_menu_cycle =
  let internal step var var_str =
    try string_of_int ((int_of_string var_str) + step)
    with Failure _ -> 
      Log.info (var ^ " seems not an integer");
      var_str
  in
  (internal (- step), internal step)
;;

let float_step step : t_menu_cycle =
  let internal step var var_str =
    try 
      string_of_float ((float_of_string var_str) +. step)
    with Failure _ -> 
      Log.info (var ^ " seems not a float");
      var_str
  in
  (internal (-. step), internal step)
;;

let bool_flip : t_menu_cycle =
  let flip vl =
    match vl with
    | true -> false
    | false -> true
    (*| _ -> raise (Failure "flip")*)
  in
  let internal var var_str =
    try 
      string_of_bool (flip (bool_of_string var_str))
    with Failure _ -> 
      Log.info (var ^ " seems not a bool");
      var_str
  in
  (internal, internal)
;;

let edit = ref View, Input_edit.create ();;

(*
let completion_step =
  let inc var var_str =
*)
  
let menu_item data : t_menu_item t =
  let txt data = 
    let label_int label var= 
      match label with
      | "" -> var
      | label -> label
    in
    let std_var label var =
      try ((label_int label var)^ " : " ^ (Parser.get var))
      with Not_found -> ("No such variable : "^var)
    in
    match data with
    | Text txt -> txt
    | Command (label, _) -> label
    | Jump (label, target) -> label (*^" "^(string_of_int target)*)
    | Var (label, var, cycle, edit) -> begin
      match edit with
      | None -> std_var label var
      | Some (mode, edit) -> begin
        match !mode with
	| View -> std_var label var
	| Edit -> (label_int label var) ^" : " ^(Input_edit.get edit) ^ "_"
      end
    end
  in
  let size_fun style data = ((Font.width (font style) (txt data), Font.height (font style))), (false, false) in
  let draw_fun (x, y) _ style data = Font.draw_string (font style) x y (txt data) in
  let handle_fun event data =
    let filter event =
      match event with
      | Ok | Left | Right -> Eno
      | event -> event
    in
    let handle_cycle var cycle event =
      match cycle with
      | None -> event
      | Some (dec, inc) ->
        try 
          match event with
          | Left -> Parser.parse ("set "^var^" "^ (dec var (Parser.get var))) (); Eno
          | Right -> Parser.parse ("set "^var^" "^ (inc var (Parser.get var))) (); Eno
          | event -> event
        with Failure txt -> Log.info ("Failure "^txt^" in cycle function"); event
    in
    let handle_edit var edit event =
      match edit with
      | None -> event
      | Some (mode, edit) -> begin
        let exit event =
	  mode := View;
 	  Parser.parse ("set "^var^" \""^ (Input_edit.get edit)^"\"") ();
	  Input_edit.enter_pressed edit; (*event*)
        in 
        match !mode, event with
	| View, Ok -> 
	  Input_edit.set edit (Parser.get var) (String.length (Parser.get var));
          mode := Edit; Eno
        | Edit, Ok -> exit Ok; Eno
        | Edit, Up -> exit Up; Eno
        | Edit, Down -> exit Down; Eno
	| Edit, Raw event -> 
	  Input_edit.handle edit event; Eno
	| _, _ -> filter event
      end
    in
    match data with
    | Var (label, var, cycle, edit) -> begin
      try filter (handle_edit var edit (handle_cycle var cycle event))
      with Parser.Error _ -> Eno end
    | Command (label, command) -> begin
      match event with
      | Ok -> Parser.parse command (); Eno
      | event -> filter event end
    | Jump (label, target) -> begin
      match event with
      | Ok -> Switch target
      | event -> filter event end
    | _ -> filter event
  in
  (size_fun, draw_fun, handle_fun, data)
;;

(* creating menu from script on runtime *)

let new_main_menu lists =
  let submenus = 
    List.map (fun item_list -> vert_focus_list (ref 0, no_deco, shd_frame, item_list)) lists 
  in
  center_box (styled_deco (shd_frame, stack (ref 0, submenus)))
;;

let menus = Hashtbl.create 10;;
(*let main_menu = ref (center_box (styled_deco (shd_frame, stack (ref 0, []))));;*)
let main_menu = ref (new_main_menu [[deco (menu_item (Command ("no menu defined!", "quit")))]]);;
let menu_index = ref (-1);;
let menu_indexer = Hashtbl.create 10;;

let old_list submenu = 
  try Hashtbl.find menus submenu
  with Not_found ->
    menu_index := !menu_index + 1;
    Hashtbl.replace menu_indexer submenu !menu_index;
    []
;;

let target_index submenu =
  try Hashtbl.find menu_indexer submenu
  with Not_found ->
    menu_index := !menu_index + 1;
    Hashtbl.replace menu_indexer submenu !menu_index;
    Hashtbl.replace menus submenu [];
    !menu_index
;;

Parser.add_command "menu_command" (Parser.triple Parser.string Parser.string Parser.string) 
  "Adds a command to submenu" (fun (submenu, label, command) ->
    Hashtbl.replace menus submenu ((old_list submenu) @ [(deco (menu_item (Command (label, command))))])
  )
;;

Parser.add_command "menu_jump" (Parser.triple Parser.string Parser.string Parser.string) 
  "Adds a jump to submenu" (fun (submenu, label, target) ->
    Hashtbl.replace menus submenu ((old_list submenu) @ [(deco (menu_item (Jump (label, (target_index target)))))])
  )
;;

let cycle_buf = ref None;;
let edit_buf = ref None;;

Parser.add_command "m_editable" Parser.unit "" (fun () -> edit_buf := Some (ref View, Input_edit.create ())) ;;

Parser.add_command "m_none" Parser.unit "" (fun () -> edit_buf := None; cycle_buf := None);;
Parser.add_command "m_no_edit" Parser.unit "" (fun () -> edit_buf := None);;

Parser.add_command "m_int" (Parser.int ()) "" (fun step -> cycle_buf := Some (int_step step));;
Parser.add_command "m_float" (Parser.float ()) "" (fun step -> cycle_buf := Some (float_step step));;
Parser.add_command "m_bool" (Parser.unit) "" (fun step -> cycle_buf := Some (bool_flip));;

Parser.add_command "menu_var" 
  (Parser.pentuple Parser.string Parser.string Parser.string Parser.command (Parser.option Parser.command)) 
  "Adds a jump to submenu" (fun (submenu, label, var_name, cycle, edit) ->
    cycle (); (match edit with | None -> edit_buf := None | Some edit -> edit () );
    Hashtbl.replace menus submenu ((old_list submenu) @ [(deco (menu_item (Var (label, var_name, !cycle_buf, !edit_buf))))])
  )
;;

Parser.add_command "menu_rebuild" Parser.unit "Rebuilds the main menu" (fun () ->
  let unordered_submenu_list = 
    Hashtbl.fold (fun name index acc ->
      (*Log.debug ("submenu: "^name^" index "^(string_of_int index));*)
      try (index, Hashtbl.find menus name) :: acc
      with Not_found -> (index, [deco (menu_item (Jump ("empty submenu!", 0)))]) :: acc
    ) menu_indexer []
  in
  let ordered_submenu_list =
    snd (List.split
      (List.sort (fun (id1, _) (id2, _) -> id1 - id2) unordered_submenu_list)
    )
  in
  main_menu := new_main_menu ordered_submenu_list
);;

let menu_mode = Utils.add_widget_mode ~super:true "menu" (fun () -> !main_menu) Utils.std_widget_mode;;

let draw_test () =
  if Input.get_real_mode () == menu_mode then
     draw (0, 0) (Video.get_resolution ()) no_deco !main_menu
  else ()
;;

let draw_fps () = draw (0, 0) (Video.get_resolution ()) shd_frame 
  ((( 
    (vert_pair (
      center_box unwidget,
      hor_pair (
        (deco (menu_item (Var ("", "fps", None, None)))),
	center_box unwidget
      )
    ))
  )));;
