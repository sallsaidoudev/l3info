
let level = ref 0;;
let ile_zyc = ref 2;;
let score =  ref 0;;


let get_level _ = !level;;
let load_level i = ();;
let next_level _ = level:= !level + 1 ;;
let brak_pilek _ = ile_zyc:= !ile_zyc - 1; (!ile_zyc < 0) ;;

let add_score s= score:= !score + s;;
let get_score ()= !score;;
(* --------- action  -------------  *)


let init() = 
	level:=0; ile_zyc:=2; score:=0;
	load_level 0;
;;

init();;

let draw _ =
	let sz = (string_of_int !ile_zyc) in 
	let ss = (string_of_int !score) in
	Info.draw_string ("zyc "^sz) 470 20;
	Info.draw_string ("score "^ss) 30 20;
	
 ;;
let frame _ = ();;









