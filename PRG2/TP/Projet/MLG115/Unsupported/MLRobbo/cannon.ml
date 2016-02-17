(* Dodaje elementy: '^', '!', '{', '}' *)

let picture = Graph.load_image "dziala.png";;

let action dir image elem = 
  let shot_now = ((Random.int 16) = 0) in
  let active = 
    if shot_now then Shot.elem_shot image elem dir
    else []
  in 
  elem::active
;;

let methods dir = {
  Element.robbo_can     = Elem_op.robbo_cant;
  Element.robbo_on      = Elem_op.robbo_cant_on;
  Element.on_shot       = Elem_op.on_shot_resist;
  Element.blow          = Elem_op.blow_destroy;
  Element.next_step     = Elem_op.step_empty;
  Element.next_action   = (action dir);
  Element.draw          = Element.sprite_draw
};;

let my_kind {Element.id=eid} = eid='^' || eid='}' || eid='!' || eid='{';;

let create dir =
  let (frame, id) = match dir with
    |Direction.UP    -> (0, '^')
    |Direction.RIGHT -> (1, '}')
    |Direction.DOWN  -> (2, '!')
    |Direction.LEFT  -> (3, '{')
    |Direction.STAY  -> failwith "Cannon.create STAY"
  in
  Element.default_creator picture frame frame ~id (methods dir)
;;

Element.register '^' (create Direction.UP);;
Element.register '}' (create Direction.RIGHT);;
Element.register '!' (create Direction.DOWN);;
Element.register '{' (create Direction.LEFT);;
