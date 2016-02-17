(* This file is part of MLGame (OCaml Game System).

   MLGame is free software; you can redistribute it and/or modify it under the
   terms of the GNU General Public License as published by the Free Software
   Foundation; either version 2 of the License, or (at your option) any later
   version.

   MLGame is distributed in the hope that it will be useful, but WITHOUT ANY
   WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
   FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
   details.

   You should have received a copy of the GNU General Public License along
   with MLGame; if not, write to the Free Software Foundation, Inc., 59 Temple
   Place, Suite 330, Boston, MA 02111-1307 USA *)

exception Error of string;;

type 'a t = {
  lex: (Lexing.lexbuf -> 'a);
  deparse: ('a -> string);
  complete: (Lexing.lexbuf -> string list);
  accept: ('a -> 'a);
  desc: string;
};;

type variable = {
  force_set: string -> unit;
  try_set: Lexing.lexbuf -> unit;
  get: unit -> string;
};;

let variables = Hashtbl.create 10;;

let get name = (Hashtbl.find variables name).get ();;
let set name aval = (Hashtbl.find variables name).force_set aval;;

let get_word lexbuf =
  let pos = lexbuf.Lexing.lex_curr_pos in
  try match Lexer.lex lexbuf with
  | Lexer.Word word -> word
  | Lexer.Var name -> 
      begin
        try get name
        with Not_found -> raise (Error ("No such variable: " ^ name))
      end
  | _ -> 
      lexbuf.Lexing.lex_curr_pos <- pos;
      raise (Error "Unable to get word")
  with _ ->
      lexbuf.Lexing.lex_curr_pos <- pos;
      raise (Error "Unable to get word")
;;

let complete_var lexbuf = 
  let pos = lexbuf.Lexing.lex_curr_pos in
  try
    match Lexer.lex lexbuf with
    | Lexer.Var name -> 
        lexbuf.Lexing.lex_curr_pos <- pos;
        Hashtbl.fold (fun name _ acc -> (("$" ^ name) :: acc)) variables []
    | _ -> lexbuf.Lexing.lex_curr_pos <- pos; []
  with _ -> lexbuf.Lexing.lex_curr_pos <- pos; []
;;

let unit = {
  lex = (fun str -> ());
  deparse = (fun () -> "");
  complete = (fun _ -> []);
  accept = (fun x -> x);
  desc = "";
};;

let int ?max ?min () = {
  lex = (fun lexbuf -> (try int_of_string (get_word lexbuf) 
    with _ -> raise (Error "Integer required")));
  deparse = (fun x -> string_of_int x);
  complete = complete_var;
  accept = (fun x -> 
    let x = match max with Some max -> if x > max then max else x | _ -> x in
    match min with Some min -> if x < min then min else x | _ -> x
  );
  desc = "<integer>";
};;

let float () = {
  lex = (fun lexbuf -> (try float_of_string (get_word lexbuf) 
                  with _ -> raise (Error "Float required")));
  deparse = (fun x -> string_of_float x);
  complete = complete_var;
  accept = (fun x -> x);
  desc = "<float>";
};;

let bool : bool t = {
  lex = (fun lexbuf -> match get_word lexbuf with
    | "1" | "t" | "true" | "y" | "yes" -> true
    | "0" | "f" | "false" | "n" | "no" -> false
    | _ -> raise (Error "Boolean required")
    );
  deparse = (fun x -> Printf.sprintf "%b" x);
  complete = (fun _ -> ["true"; "false"]);
  accept = (fun x -> x);
  desc = "<boolean>";
};;

let string = {
  lex = (fun lexbuf -> 
    let ret = get_word lexbuf in 
    ret
  );
  deparse = (fun x -> x);
  complete = complete_var;
  accept = (fun x -> x);
  desc = "<string>";
};;


let option t = {
  lex = (fun lexbuf -> try Some (t.lex lexbuf) with Error _ -> None);
  deparse = (function None -> " " | Some aval -> t.deparse aval);
  complete = t.complete;
  accept = (function None -> None | Some aval -> Some (t.accept aval));
  desc = ("[ " ^ t.desc ^ " ]")
};;

let pair t1 t2 = {
  lex = (fun lexbuf -> let c1 = t1.lex lexbuf in (c1, t2.lex lexbuf));
  deparse = (fun (v1, v2) -> ((t1.deparse v1) ^ " " ^ (t2.deparse v2)));
  complete = (fun lexbuf ->
    let pos = lexbuf.Lexing.lex_curr_pos in
    try 
      let c1 = t1.lex lexbuf in 
      t2.complete lexbuf
    with Error _ -> 
      lexbuf.Lexing.lex_curr_pos <- pos;
      t1.complete lexbuf
  );
  accept = (fun (v1, v2) -> ((t1.accept v1), (t2.accept v2)));
  desc = (t1.desc ^ " " ^ t2.desc);
};;

let callback fnctn t = 
  {t with accept = (fun a -> fnctn a; (t.accept a))}
;;
  
let accept_only (lst : 'a list) t = {t with
  lex = (fun lexbuf -> 
      let c = t.lex lexbuf in if List.mem c lst then c 
      else raise (Error "Value not acceptable"));
  complete = (fun _ -> List.map t.deparse lst)
};;
  
let variable : string t = {
  lex = (fun lexbuf -> let word = get_word lexbuf in
      try ignore (Hashtbl.find variables word); word
      with Not_found -> raise (Error ("No such variable: " ^ word))
    );
  deparse = (fun _ -> raise (Error "Variables cannot be named"));
  complete = 
    (fun _ -> Hashtbl.fold (fun name _ acc -> name :: acc) variables []);
  accept = (fun x -> x);
  desc = "<variable>";
};;

let commands = Hashtbl.create 10;;

(* The first should always be LexerBegin. If it's not it will
   raise Error _  *)
let parse lexbuf = 
  let rec parse_cmd fnctn level =
    match Lexer.lex lexbuf with
    | Lexer.Begin -> parse_cmd fnctn (level + 1)
    | Lexer.Word word | Lexer.Var word ->
        let new_fun =
          try let (fnctn, _, _) = Hashtbl.find commands word in fnctn lexbuf
          with 
          | Not_found -> raise (Error ("No such command: " ^ word))
          | Error err -> raise (Error ("Wrong params: " ^ err))
        in
        parse_end (fun () -> fnctn (); new_fun ()) level
    | _ -> raise (Error ("Command expected"))
  and parse_end fnctn level =
    match Lexer.lex lexbuf with
    | Lexer.End -> if level = 1 then fnctn else parse_cmd fnctn (level - 1)
    | Lexer.Semi -> (try parse_cmd fnctn level with (Error "Command expected") -> fnctn)
    | Lexer.Eol -> raise (Error "Parenthesis required")
    | _ -> raise (Error ("Unended expression"))
  in 
  try parse_cmd (fun () -> ()) 0 
  with Failure _ -> raise (Error "Unable to lex, bad chars?")
;;

(* Should always get { as first sign *)
let complete lexbuf =
(*  Log.debug ("[" ^ lexbuf.Lexing.lex_buffer ^ "]");*)
  let rec complete_cmd level =
    let pos = lexbuf.Lexing.lex_curr_pos in
    match Lexer.lex lexbuf with
    | Lexer.Begin -> complete_cmd (level + 1)
    | Lexer.Word word | Lexer.Var word ->
        let npos = lexbuf.Lexing.lex_curr_pos in
        begin try 
          let (fnctn, _, _) = Hashtbl.find commands word in 
          let _ = fnctn lexbuf in (* Skip the params (may throw Error) *)
          complete_end level
        with 
        | Not_found -> (* Complete command name *)
            lexbuf.Lexing.lex_curr_pos <- pos;
(*            Log.debug "ccn";*)
            let len = String.length word in
            let folder name _ acc = name :: acc in
            Hashtbl.fold folder commands []
        | Error err -> (* Complete the params *)
            lexbuf.Lexing.lex_curr_pos <- npos;
            let (_, completer, _) = Hashtbl.find commands word in
(*            Log.debug "ctp";*)
            completer lexbuf
        end
    | Lexer.Eol -> 
        if level = 0 then ["{"] 
        else Hashtbl.fold (fun name _ acc -> name :: acc) commands []
    | _ -> []
  and complete_end level =
    match Lexer.lex lexbuf with
    | Lexer.Eol -> [";"]
    | Lexer.Semi -> complete_cmd level
    | Lexer.End -> complete_cmd (level - 1)
    | _ -> []
  in 
  let ends = 
    try complete_cmd 0 
    with Failure _ -> [] (* Lexing empty token *)
  in
  let pos = lexbuf.Lexing.lex_curr_pos in
  begin 
    try ignore (Lexer.lex_skip lexbuf) 
    with _ -> lexbuf.Lexing.lex_curr_pos <- pos 
  end;
  (String.sub lexbuf.Lexing.lex_buffer 0 (lexbuf.Lexing.lex_curr_pos), ends)
;;

let command : (unit -> unit) t = {
  lex = parse;
  deparse = (fun _ -> raise (Error "Commands cannot be named"));
  complete = (fun lexbuf -> snd (complete lexbuf));
  accept = (fun x -> x);
  desc = "<command>";
};;


let add_command name t desc handler =
  let handle lexbuf =
    let aval = t.lex lexbuf in
    fun () -> handler (t.accept aval)
  in
  let full_desc = "Command: '" ^ name ^ "'. Description: " ^ desc ^ ". Syntax: " ^ name ^ " " ^ t.desc in
  Hashtbl.replace commands name (handle, t.complete, full_desc)
;;

let add_variable name t init =
  let ret = ref init in
  let new_var = {
    force_set = (fun str -> ret := t.lex (Lexing.from_string str));
    try_set = (fun lexbuf -> ret := t.accept (t.lex lexbuf));
    get = (fun () -> t.deparse !ret)
  } in
  Hashtbl.replace variables name new_var;
  ret
;;
    
let create_log name prefix init =
  let do_log = add_variable name bool init in
  fun str -> Log.remember_debug do_log (prefix ^ str)
;;


let log = create_log "debug_parser" "[Parser] " false;;


let available_completions str =
  let lexbuf = Lexing.from_string ("{" ^ str) in
  let prefix, lst = complete lexbuf in
  let prefix = String.sub prefix 1 (String.length prefix - 1) in
(*  Log.debug ("***" ^ (String.concat " " (prefix :: lst)));*)
  let prefix_len = String.length prefix in
  let len = String.length str - prefix_len in
  let str_end = String.sub str prefix_len len in
  let folder acc elem = 
    if String.length elem >= len && String.sub elem 0 len = str_end 
    then elem :: acc else acc in
  let lst = List.fold_left folder [] lst in
  match lst with
  | [] -> []
  | (h :: t) ->
      let get_prefix str elem =
        let max_pos = min (String.length str) (String.length elem) in
        let rec tst pos =
          if pos = max_pos then String.sub str 0 max_pos else
          if str.[pos] = elem.[pos] then tst (pos + 1) else
          String.sub str 0 pos in
        tst 0 in 
      let ret = List.fold_left get_prefix h t in
      if String.length (prefix ^ ret) > String.length str then [prefix ^ ret]
      else if t = [] then [prefix ^ ret]
      else (h :: t)
;;

let parse str =
  let lexbuf = Lexing.from_string ("{" ^ str ^ "}") in
  parse lexbuf
;;


let execute script =
  log ("Executing: " ^ Filename.basename script);
  try
    let in_chann = open_in script in
    while true do
      let line = input_line in_chann in
      if String.length line > 0 && line.[0] <> '#' then 
        try parse line ()
        with Error desc -> Log.error desc
    done
  with
  | Sys_error _ -> raise (Error ("Opening script \"" ^ script ^ "\"."))
  | End_of_file -> ()
;;

let setvar (name, sth) =
  try
    log ("Setting: " ^ name ^ " to: " ^ sth);
    (Hashtbl.find variables name).try_set (Lexing.from_string sth)
  with
  | Not_found -> raise (Error ("No such variable: " ^ name))
;;

let alias (name, command) =
  add_command name unit "Aliased command" command
;;                        

add_command "exec" string "Executes the given script" execute;;
add_command "echo" string "Prints out information" (fun str -> Log.info str);;
add_command "set" (pair variable string) "Sets variable to a newvalue" setvar;;
add_command "alias" (pair string command) "Adds an alias to given command" alias;;

let toggle = function
  | (v, None) -> 
      if get v = "true" then setvar (v, "false") 
      else setvar (v, "true")
  | (v, Some aval) ->
      if get v = aval then setvar (v, "") else setvar (v, aval)
in add_command "toggle" (pair variable (option string)) 
  "Toggles the given boolean variable or clears if equal to given value" toggle

let help = function 
  | None -> 
      Log.info "This is the MLGame builtin console.";
      Log.info "Type 'help help' to see a list of available help topics.";
  | Some "help" -> 
      Log.info "Type 'help <topic>' to see help on topic.";
      Log.info "Available topics: commands"
  | Some "commands" ->
      Log.info "Type 'help <command>' to see help on given command.";
      let folder name _ acc = name :: acc in
      let cmd_lst = Hashtbl.fold folder commands [] in
      Log.info ("Available commands: " ^ (String.concat " " cmd_lst))
  | Some x -> 
      try let (_, _, desc) = Hashtbl.find commands x in Log.info desc
      with Not_found -> Log.info ("Help for '" ^ x ^ "' not available")
;;

add_command "help" (option string) "" help;;

let dump = (function None -> Log.dump "log" | Some file -> Log.dump file) in
add_command "dump_log" (option string) "Dumps log to a file"  dump;;


let triple t1 t2 t3 = 
  let temp = pair t1 (pair t2 t3) in {
  lex = (fun lexbuf -> let (l1, (l2, l3)) = temp.lex lexbuf in (l1, l2, l3));
  deparse = (fun (v1, v2, v3) -> temp.deparse (v1, (v2, v3)));
  complete = temp.complete;
  accept = (fun (v1, v2, v3) -> 
    let (t1, (t2, t3)) = temp.accept (v1, (v2, v3)) in (t1, t2, t3));
  desc = temp.desc
};;

let quadruple t1 t2 t3 t4 = 
  let temp = pair (pair t1 t2) (pair t3 t4) in {
  lex = (fun lexbuf -> let ((l1, l2), (l3, l4)) = temp.lex lexbuf in (l1, l2, l3, l4));
  deparse = (fun (v1, v2, v3, v4) -> temp.deparse ((v1, v2), (v3, v4)));
  complete = temp.complete;
  accept = (fun (v1, v2, v3, v4) -> 
    let ((t1, t2), (t3, t4)) = temp.accept ((v1, v2), (v3, v4)) in (t1, t2, t3, t4));
  desc = temp.desc
};;

let pentuple t1 t2 t3 t4 t5 = 
  let temp = pair (pair t1 t2) (triple t3 t4 t5) in {
  lex = (fun lexbuf -> let ((l1, l2), (l3, l4, l5)) = temp.lex lexbuf in (l1, l2, l3, l4, l5));
  deparse = (fun (v1, v2, v3, v4, v5) -> temp.deparse ((v1, v2), (v3, v4, v5)));
  complete = temp.complete;
  accept = (fun (v1, v2, v3, v4, v5) -> 
    let ((t1, t2), (t3, t4, t5)) = temp.accept ((v1, v2), (v3, v4, v5)) in (t1, t2, t3, t4, t5));
  desc = temp.desc
};;

let sextuple t1 t2 t3 t4 t5 t6 = 
  let temp = pair (pair t1 t2) (quadruple t3 t4 t5 t6) in {
  lex = (fun lexbuf -> let ((l1, l2), (l3, l4, l5, l6)) = temp.lex lexbuf in (l1, l2, l3, l4, l5, l6));
  deparse = (fun (v1, v2, v3, v4, v5, v6) -> temp.deparse ((v1, v2), (v3, v4, v5, v6)));
  complete = temp.complete;
  accept = (fun (v1, v2, v3, v4, v5, v6) -> 
    let ((t1, t2), (t3, t4, t5, t6)) = temp.accept ((v1, v2), (v3, v4, v5, v6)) in (t1, t2, t3, t4, t5, t6));
  desc = temp.desc
};;

let septuple t1 t2 t3 t4 t5 t6 t7 = 
  let temp = pair (pair t1 t2) (pentuple t3 t4 t5 t6 t7) in {
  lex = (fun lexbuf -> let ((l1, l2), (l3, l4, l5, l6, l7)) = temp.lex lexbuf in (l1, l2, l3, l4, l5, l6, l7));
  deparse = (fun (v1, v2, v3, v4, v5, v6, v7) -> temp.deparse ((v1, v2), (v3, v4, v5, v6, v7)));
  complete = temp.complete;
  accept = (fun (v1, v2, v3, v4, v5, v6, v7) -> 
    let ((t1, t2), (t3, t4, t5, t6, t7)) = temp.accept ((v1, v2), (v3, v4, v5, v6, v7)) in (t1, t2, t3, t4, t5, t6, t7));
  desc = temp.desc
};;

let octuple t1 t2 t3 t4 t5 t6 t7 t8 = 
  let temp = pair (pair t1 t2) (sextuple t3 t4 t5 t6 t7 t8) in {
  lex = (fun lexbuf -> let ((l1, l2), (l3, l4, l5, l6, l7, l8)) = temp.lex lexbuf in (l1, l2, l3, l4, l5, l6, l7, l8));
  deparse = (fun (v1, v2, v3, v4, v5, v6, v7, v8) -> temp.deparse ((v1, v2), (v3, v4, v5, v6, v7, v8)));
  complete = temp.complete;
  accept = (fun (v1, v2, v3, v4, v5, v6, v7, v8) -> 
    let ((t1, t2), (t3, t4, t5, t6, t7, t8)) = 
      temp.accept ((v1, v2), (v3, v4, v5, v6, v7, v8)) in (t1, t2, t3, t4, t5, t6, t7, t8));
  desc = temp.desc
};;

let nonuple t1 t2 t3 t4 t5 t6 t7 t8 t9 = 
  let temp = pair (pair t1 t2) (septuple t3 t4 t5 t6 t7 t8 t9) in {
  lex = (fun lexbuf -> let ((l1, l2), (l3, l4, l5, l6, l7, l8, l9)) = temp.lex lexbuf in (l1, l2, l3, l4, l5, l6, l7, l8, l9));
  deparse = (fun (v1, v2, v3, v4, v5, v6, v7, v8, v9) -> temp.deparse ((v1, v2), (v3, v4, v5, v6, v7, v8, v9)));
  complete = temp.complete;
  accept = (fun (v1, v2, v3, v4, v5, v6, v7, v8, v9) -> 
    let ((t1, t2), (t3, t4, t5, t6, t7, t8, t9)) = 
      temp.accept ((v1, v2), (v3, v4, v5, v6, v7, v8, v9)) in (t1, t2, t3, t4, t5, t6, t7, t8, t9));
  desc = temp.desc
};;


