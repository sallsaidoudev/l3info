let methods1 on_shot blow= {
  Element.robbo_can     = Elem_op.robbo_cant;
  Element.robbo_on      = Elem_op.robbo_cant_on;
  Element.on_shot       = on_shot;
  Element.blow          = blow;
  Element.next_step     = Elem_op.step_empty;
  Element.next_action   = Elem_op.action_empty;
  Element.draw          = Element.sprite_draw
};;
let methods_resist = methods1 Elem_op.on_shot_resist Elem_op.blow_resist;;

module type Elem = sig
  val id : char
  val my_kind : Element.t -> bool
  val create : int*int -> Element.t
end;;

module Wall : Elem = struct
  let id = 'M'
  let picture = Graph.load_image "murek2.png"
  let my_kind {Element.id=eid} = eid = id
  let create = Element.default_creator picture 0 0 ~id methods_resist
end;;

module Nothing : Elem = struct
  let id = 'N'
  let picture = Graph.load_image "nicosc.png"
  let my_kind {Element.id=eid} = eid = id;;
  let create = Element.default_creator picture 0 0 ~id methods_resist
end;;

module Gum : Elem = struct
  let id = '~'
  let picture = Graph.load_image "guma.png"
  let my_kind {Element.id=eid} = eid = id
  let my_methods = methods1 Elem_op.on_shot_destroy Elem_op.blow_destroy
  let create = Element.default_creator picture 0 0 ~id my_methods
end;;

Element.register Wall.id Wall.create;;
Element.register Nothing.id Nothing.create;;
Element.register Gum.id Gum.create;;
