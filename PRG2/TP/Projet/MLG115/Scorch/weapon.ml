type t = {
  name : string;
  mid : string;
  no : int;
  mutable price : float;
};;

let next_no = ref 0;;

let weapons = Hashtbl.create 20;; 
Hashtbl.replace weapons "sm" {name = "error weapon"; mid = "null"; no = 0; price = 0.};;

let con_add_weapon (wpid, name, mid, price) =
  Hashtbl.replace weapons wpid {
    name = name;
    mid = mid;
    no = (incr next_no;!next_no); 
    price = price;
  }
;;

let get wpid = Hashtbl.find weapons wpid ;;

let price wpid quant = (int_of_float (get wpid).price) * quant;;
let name wpid = (get wpid).name;;
let mid wpid = (get wpid).mid;;

let sorted_list () =
  let weap_list =
    let fold_fun wpid weapon lst = (wpid, weapon) :: lst in
    Hashtbl.fold fold_fun weapons []
  in
  (List.sort (fun w1 w2 -> (snd w1).no - (snd w2).no) weap_list)
;;

let q = 0.05

let bought wpid quant =
  let other_count =
    Hashtbl.fold (fun iwpid weapon acc ->
      if iwpid = wpid then acc
      else acc + 1) weapons 0
  in
  let obrot = (Hashtbl.find weapons wpid).price *. (float quant) in
  let mq = (1. /. ((1. +. q) ** (1. /. (float other_count)))) -. 1. in
  Hashtbl.iter (fun iwpid weapon ->
    (* bug - buying zero price weapon decreases other prices; potrzebny niezmiennik? 
     - price change should depend on price of purchased weapon
    *)
    if iwpid = wpid then
      weapon.price <- weapon.price +. (q *. obrot)
    else
      weapon.price <- weapon.price +. (mq *. obrot)
  ) weapons
;;

let console_shop _ =
  Log.info "-------- Available goods: --------";
  List.iter (fun (wpid, weapon) ->
     Log.info 
      ((string_of_int weapon.no)^" "^
       wpid^" "^
       weapon.name^
       " $"^(string_of_int (int_of_float weapon.price)))
  ) (sorted_list ())
;;

let write_prices () =
  let file = open_out "./cfg/weapon_prices.rc" in
  Hashtbl.iter (fun wpid weapon ->
    output_string file ("set_price "^wpid^" "^(string_of_float weapon.price)^"\n")
    ) weapons;
  close_out file
;;

let console_set_price (wpid, price) =
  try (Hashtbl.find weapons wpid).price <- price
  with Not_found -> Log.info ("set_price: no such weapon: "^wpid)
;;

Parser.add_command "shop" Parser.unit "" console_shop;;
Parser.add_command "add_weapon" (Parser.quadruple Parser.string Parser.string Parser.string (Parser.float ())) "" con_add_weapon;;

Parser.add_command "set_price" (Parser.pair Parser.string (Parser.float ())) "" console_set_price;;
Parser.add_command "write_prices" Parser.unit "" write_prices;;

