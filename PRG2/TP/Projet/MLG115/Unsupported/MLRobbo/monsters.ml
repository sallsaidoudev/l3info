let id_h = '-';;
let id_v = '|';;
let picture = Graph.load_image "nietoperz.png";;

let try_dirs image pos =
  let rec find = function
    |h::t ->
      let next_pos = Element.pos_next pos h in
      let elem = Level_image.get image next_pos in
      if Empty.my_kind elem then h else find t
    |[]   -> Direction.STAY
  in
  find
;;

let kill_robbo image elem = 
  let pos = Element.get_pos elem in
  let poss = Level_image.neighbours4 pos in
  let kill p = 
    let e = Level_image.get image p in
    if Robbo.my_kind e then raise Robbo.Die else ()
  in
  List.iter kill poss
;;

(** [action dirs image elem] [dirs] to lista kierunków w kolejno¶ci stosowania
    je¶li nietoperz zatrzyma³ siê *)
let action dirs image elem = 
  let cur_pos = Element.get_pos elem in
  let cur_speed = Element.get_speed elem in
  let cur_dir = Direction.from_vect cur_speed in
  let dirs = match cur_dir with
    |Direction.STAY -> dirs
    |x -> [x]
  in
  let good_dir = try_dirs image cur_pos dirs in
  Element.set_next_frame elem;
  Elem_op.move_dir image elem good_dir;
  Element.set_speed_dir elem good_dir;
  kill_robbo image elem;
  [elem]
;;

let methods dirs = {
  Element.robbo_can     = Elem_op.robbo_cant;
  Element.robbo_on      = Elem_op.robbo_cant_on;
  Element.on_shot       = Elem_op.on_shot_destroy;
  Element.blow          = Elem_op.blow_destroy;
  Element.next_step     = Element.sprite_move;
  Element.next_action   = (action dirs);
  Element.draw          = Element.sprite_draw
};;

let my_kind {Element.id=eid} = eid=id_h || eid=id_v;;

let create id dir = 
  let dirs = match dir with
    |Direction.UP    -> [Direction.UP; Direction.DOWN]
    |Direction.DOWN  -> [Direction.DOWN; Direction.UP]
    |Direction.LEFT  -> [Direction.LEFT; Direction.RIGHT]
    |Direction.RIGHT -> [Direction.RIGHT; Direction.LEFT]
    | _ -> failwith "Bats.create STAY"
  in
  let speed = Element.get_speed_dir dir in
  Element.default_creator picture 0 1 ~id ~speed (methods dirs)
;;

Element.register id_h (create id_h Direction.LEFT);;
Element.register id_v (create id_v Direction.UP);;