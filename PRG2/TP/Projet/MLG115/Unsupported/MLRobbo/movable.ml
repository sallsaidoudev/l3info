let methods1 on_shot blow = {
  Element.robbo_can     = Elem_op.movable_robbo_can;
  Element.robbo_on      = Elem_op.movable_robbo_on;
  Element.on_shot       = on_shot;
  Element.blow          = blow;
  Element.next_step     = Elem_op.movable_step;
  Element.next_action   = Elem_op.movable_action;
  Element.draw          = Element.sprite_draw
};;
let methods_std = methods1 Elem_op.on_shot_resist Elem_op.blow_destroy;;

module type Elem = sig
  val id : char
  val my_kind : Element.t -> bool
  val create  : int*int -> Element.t
end;;

module Box : Elem = struct
  let id = '#'
  let picture = Graph.load_image "skrzynia.png"
  let my_kind {Element.id=eid} = eid = id
  let create = Element.default_creator picture 0 0 ~id methods_std
end;;

module Bomb : Elem = struct
  let id = '*'
  let picture = Graph.load_image "bomba.png"
  let blow image elem = 
    let pos = Element.get_pos elem in
    let poss = Level_image.neighbours7 pos in
    (* JA znikam i wybucham - nie odwrotnie *)
    Element.set_as_removed elem;
    let my_blow = Blow.put_new image pos in
    (* Wybuchnij dan± pozycjê, w wyniku lista aktywnych elementów *)
    let blow_pos pos = 
      let elem = Level_image.get image pos in
      if Empty.my_kind elem then [Blow.put_new image pos]
      else Element.blow image elem
    in
    (* Lista list aktywnych elementów *)
    let ll_after_blow = List.rev_map blow_pos poss in
    let l_after_blow = List.flatten ll_after_blow in
    my_blow::l_after_blow

  let my_methods = methods1 Elem_op.on_shot_destroy blow
  let my_kind {Element.id=eid} = eid = id
  let create = Element.default_creator picture 0 0 ~id my_methods
end;;


module Capsule : Elem = struct
  let id = 'K'
  let picture = Graph.load_image "kapsuly.png"
  let my_kind {Element.id=eid} = eid = id
  let create = Element.default_creator picture 0 0 ~id methods_std
end;;

Element.register Box.id Box.create;;
Element.register Bomb.id Bomb.create;;
Element.register Capsule.id Capsule.create;;
