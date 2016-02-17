let methods1 on_shot robbo_on = {
  Element.robbo_can     = Elem_op.collect_robbo_can;
  Element.robbo_on      = robbo_on;
  Element.on_shot       = on_shot;
  Element.blow          = Elem_op.blow_destroy;
  Element.next_step     = Elem_op.step_empty;
  Element.next_action   = Elem_op.action_empty;
  Element.draw          = Element.sprite_draw
};;
let methods on_shot trigger =
  let robbo_on = Elem_op.collect_robbo_on trigger in
  methods1 on_shot robbo_on
;;
let methods_resist = methods Elem_op.on_shot_resist;;

module type Elem = sig
  val id : char
  val my_kind : Element.t -> bool
  val create : int*int -> Element.t
end;;

module Ammo : Elem = struct 
  let id = 'a'
  let picture = Graph.load_image "amunicja.png"
  let my_kind {Element.id=eid} = eid = id
  let my_methods = methods Elem_op.on_shot_destroy Level_data.inc_ammo
  let create = Element.default_creator picture 0 0 ~id my_methods
end;;

module Key : Elem = struct
  let id = 'k'
  let picture = Graph.load_image "klucz.png"
  let my_kind {Element.id=eid} = eid = id
  let create = Element.default_creator picture 0 0 ~id (methods_resist Level_data.inc_key)
end;;

module Door : Elem = struct
  let id = 'D'
  let picture = Graph.load_image "drzwi.png"
  let robbo_can image _ _ =
    let data = Level_image.get_data image in
    Level_data.has_key data
  
  let my_methods = 
    let m = methods_resist Level_data.dec_key in
    {m with Element.robbo_can = robbo_can;}
 
  let my_kind {Element.id=eid} = eid = id
  let create = Element.default_creator picture 0 0 ~id my_methods
end;;

module Screw : Elem = struct
  let id = 's'
  let picture = Graph.load_image "srubka.png"
  let robbo_on image elem dir =
    let (_, act) = Elem_op.collect_robbo_on Level_data.dec_screw image elem dir in
    let data = Level_image.get_data image in
    let thats_all = Level_data.all_screws data in
    if thats_all then begin
      let act2 = Capsule_r.ready_to_take_off image in
      (None, List.rev_append act2 act)
    end else (None, act)
    
  let my_methods = methods1 Elem_op.on_shot_resist robbo_on
 
  let my_kind {Element.id=eid} = eid = id
  let create = Element.default_creator picture 0 0 ~id my_methods
end;;

Element.register Ammo.id Ammo.create;;
Element.register Key.id Key.create;;
Element.register Door.id Door.create;;
Element.register Screw.id Screw.create;;
