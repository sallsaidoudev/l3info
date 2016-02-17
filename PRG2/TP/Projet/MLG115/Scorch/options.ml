(* GAMEWIDE OPTIONS *)
(* Gameplay options*)
let tanks_per_player = Parser.add_variable "tanks_per_player" (Parser.int ()) 1;;
let rounds = Parser.add_variable "rounds" (Parser.int ()) 10;;
let width = Parser.add_variable "width" (Parser.int ()) 800;;
let height = Parser.add_variable "heigth" (Parser.int ()) 600;;
let hitpoints = Parser.add_variable "hitpoints" (Parser.int ()) 100;;

(* Economic options*)
let cash_at_start = Parser.add_variable "cash_at_start" (Parser.int ()) 2000;;

(* Scoring options *)
let points_for_kill = 
  Parser.add_variable "points_for_kill" (Parser.int ()) 10;;
let points_for_damage = 
  Parser.add_variable "points_for_damage" (Parser.int ()) 0;;
let points_for_direct = 
  Parser.add_variable "points_for_direct" (Parser.int ()) 0;;
let points_for_win = 
  Parser.add_variable "points_for_win" (Parser.int ()) 10;;
let cashing_multiplier = 
  Parser.add_variable "cashing_multiplier" (Parser.int ()) 10;;

(* Physics options*)
(*let gravity = fst (Net.add_var "gravity" (Parser.float ()) 0.005);;*)

let gravity = Parser.add_variable "gravity" (Parser.float ()) 0.05;;
let max_wind = Parser.add_variable "max_wind" (Parser.int ()) 100;;
let turn_wind_change = Parser.add_variable "wind_change" (Parser.bool) false;;

(* Land generator options*)
let slope = Parser.add_variable "slope" (Parser.int ()) 5;;
let bumpiness = Parser.add_variable "bumpiness" (Parser.int ()) 30;;
let land_block = Parser.add_variable "land_block" (Parser.string) "ice_block1.png";;

(* LOCAL OPTIONS *)
(* Control_options *)
let mouse_on = Parser.add_variable "mouse_on" Parser.bool true;;

(* Other options*)
let cycles_per_frame = Parser.add_variable "cycles_per_frame" (Parser.int ()) 15;;
let draw_title_pic = Parser.add_variable "draw_title_pic" Parser.bool true;;

(* debug *)
(*let d1 = Parser.add_variable "d1" (Parser.int ()) 0;;*)

let gfx_path = "./gfx/";;
let font_path = "./gfx/";;

(* initialization *)
Helpers.add_video_mode_var (fun () -> ());;
Parser.parse "exec \"./cfg/mlgame.rc\"" ();;

(*
let incd1 _ = d1 := !d1 + 200;;
let decd1 _ = d1 := !d1 - 200;;
Parser.add_command "incd1" Parser.unit "" incd1;;
Parser.add_command "decd1" Parser.unit "" decd1;;*)
