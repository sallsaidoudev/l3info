
module Zimm=Weaponf.Make (Zimm_bullet);;

let zimm = Zimm.get_weapon "Zimm" 1 200 15.0;;

let draw_all_bullets context = 
  Zimm.draw_bullets context;;

let amount_of_weapons = 1;;

let fire weapon_name pos vel angle direction =
  match weapon_name with
  | "Zimm" -> Zimm.fire zimm pos vel angle direction
  | _ -> ()
;;

Player.player_fire := fire;;
