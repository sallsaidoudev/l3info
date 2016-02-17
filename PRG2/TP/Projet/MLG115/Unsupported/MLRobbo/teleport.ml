(** Nic nie jest widoczne na zewn±trz *)
(** Dodaje elementy: '1', '2', '3', '4' *)

let picture = Graph.load_image "teleporty.png";;

(* [find_out image teli_in] daj teleport wyj¶ciowy dla teleportu [teli_in] *)
let find_out image teli_in = 
  let pos = Element.get_pos teli_in in
  let p = Element.id_equal teli_in in
  Level_image.first_from p pos image
;;
(* [find_dir dir image teli_out] daj kierunek z jakim robbo wyjdzie z teleportu 
   [teli_out], je¶li wiadomo, ¿e wszed³ z kierunku [dir] *)
let find_dir dir image teli_out =
  let all_dir = Direction.all_from dir in
  let last_good_dir = Direction.rev dir in
  let rec get_first p = function
    |h::t -> if p h then h else get_first p t
    |[]   -> last_good_dir
  in
  let p dir = 
    let elem = Element.elem_next image teli_out dir in
    Empty.my_kind elem
  in
  get_first p all_dir
;;
let robbo_on image elem dir = 
  let teli_out = find_out image elem in
  let dir_out = find_dir dir image teli_out in
  let pos = Element.elem_next_pos teli_out dir_out in
  (Some pos, [])
;;

let action _ elem = 
  Element.set_next_frame elem;
  [elem]
;;

let methods = {
  Element.robbo_can     = (fun _ _ _ -> true);
  Element.robbo_on      = robbo_on;
  Element.on_shot       = Elem_op.on_shot_resist;
  Element.blow          = Elem_op.blow_destroy;
  Element.next_step     = Elem_op.step_empty;
  Element.next_action   = action;
  Element.draw          = Element.sprite_draw
};;

(* [my_kind elem] czy element jest "mojego" rodzaju? *)
let my_kind {Element.id=eid} = eid='1' || eid='2' || eid='3' || eid='4';;

(* [create id pos] daj nowy element i nadaj mu pozycjê [pos] *)
let create id = Element.default_creator picture 0 3 ~id methods;;

Element.register '1' (create '1');;
Element.register '2' (create '2');;
Element.register '3' (create '3');;
Element.register '4' (create '4');;
