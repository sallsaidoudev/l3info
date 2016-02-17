open Widget

let std_widget_mode = [
  ("up", Up); ("down", Down); ("left", Left); ("right", Right); 
  ("ok", Ok)
];;

let add_widget_mode ?(super=false) name widget lst =
  List.iter (fun (suffix, event) -> 
    Parser.add_command (name^"_"^suffix) Parser.unit "" (fun () -> ignore (handle event (widget ())))
  ) lst;
  Input.add_mode ~super name (fun event -> ignore (handle (Raw event) (widget())))
;;

Parser.add_command "int_var" (Parser.pair Parser.string (Parser.int ())) ""
  (fun (name, init_val) -> ignore (Parser.add_variable name (Parser.int ()) init_val));;

(*
Parser.add_command "repeat" (Parser.pair (Parser.int ()) Parser.command) ""
  (fun (times, what) -> for i = 1 to times do what () done);;*)
