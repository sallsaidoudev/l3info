
(* [remove_elem image elem] *)
let remove_elem image elem =
  let {Element.pos = pos} = elem in
  Element.set_as_removed elem;
  Empty.put_new image pos;
;;
(* [move_dir image elem dir] [elem] wêdruje o jedno pole w kierunku [dir], w jego
    stare miejsce stawiam Empty *)
let move_dir image elem dir =
  let {Element.pos = pos} = elem in
  let new_pos = Direction.add dir pos in
  Empty.put_new image pos;
  elem.Element.pos <- new_pos;
  Level_image.put image new_pos elem;
;;

(* Metody *)
let robbo_cant _ _ _ = false;;
let robbo_cant_on _ _ _ = failwith "robbo_cant_on";;
let on_shot_destroy _ = true;;
let on_shot_resist _  = false;;
let blow_destroy image elem =
  let pos = elem.Element.pos in
  Element.set_as_removed elem;
  [Blow.put_new image pos]
;;
let blow_resist _ _ = [];;
let step_empty _ = ();;
let action_empty _ _ = [];;

(* Metody dla elementów przesuwanych *)
let movable_robbo_can image elem dir =
  let next = Element.elem_next image elem dir in
  Empty.my_kind next
;;
let movable_robbo_on image elem dir = 
  move_dir image elem dir;
  Element.set_speed_dir elem dir;
  (None, [elem])
;;
let movable_step = Element.sprite_move;;
let movable_action = action_empty;;

(* Metody dla elementów zbieranych *)
let collect_robbo_can _ _ _ = true;;
let collect_robbo_on trigger image elem _ = 
  let data = Level_image.get_data image in
  Element.set_as_removed elem;
  trigger data;
  (None, [])
;;
