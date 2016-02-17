let picture = Graph.load_image "strzal.png";;

let action dir image elem =
  let next = Element.elem_next image elem dir in
  let speed = Element.get_speed_dir dir in
  Element.set_speed elem speed;
  Element.set_next_frame elem;
  if (Empty.my_kind next) then begin
    Elem_op.move_dir image elem dir;
    [elem]
  end else
    if Element.on_shot next then begin
      Elem_op.remove_elem image elem;
      Element.blow image next
    end else Element.blow image elem
;;

let methods dir = {
  Element.robbo_can     = Elem_op.robbo_cant;
  Element.robbo_on      = Elem_op.robbo_cant_on;
  Element.on_shot       = Elem_op.on_shot_resist;
  Element.blow          = Elem_op.blow_destroy;
  Element.next_step     = Element.sprite_move;
  Element.next_action   = (action dir);
  Element.draw          = Element.sprite_draw
};;
let shot_image = Graph.load_image "strzal.png";;

let create dir = 
  let my_methods = methods dir in
  let frame_min = match dir with
    |Direction.UP   -> 2
    |Direction.DOWN -> 2
    |_ -> 0
  in
  let frame_max = frame_min + 1 in
  let speed = Element.get_speed_dir dir in
  Element.default_creator picture frame_min frame_max my_methods
;;

let put_new dir image pos =
  let elem = create dir pos in
  Level_image.put image pos elem;
  elem
;;

let elem_shot image elem dir =
  let pos = Element.elem_next_pos elem dir in
  let next = Level_image.get image pos in
  if Empty.my_kind next then [put_new dir image pos]
  else
    if Element.on_shot next then Element.blow image next
    else []
;;
