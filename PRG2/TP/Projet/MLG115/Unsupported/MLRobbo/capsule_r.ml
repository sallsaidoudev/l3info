exception Robbo_inside;;

let id = '$';;
let picture = Graph.load_image "kapsuly.png";;
let robbo_on image elem dir =
  raise Robbo_inside
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

let my_kind {Element.id=eid} = id=eid;;

let create = Element.default_creator picture 0 1 ~id methods;;

let put_new image pos =
  let elem = create pos in
  Level_image.put image pos elem;
  elem
;;

Element.register id create;;

let ready_to_take_off image =
  let elems = Level_image.get_elems Movable.Capsule.my_kind image in
  let activate elem =
    let pos = Element.get_pos elem in
    Element.set_as_removed elem;
    put_new image pos
  in
  List.rev_map activate elems
;;
