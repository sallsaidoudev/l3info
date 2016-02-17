(* ROBBO
 * Tomasz Kokoszka
 *)

(** [Robbo.Die] wyj±tek rzucany w chwili ¶mierci robocika *)
exception Die;;

let id = 'R';;
let picture = Graph.load_image "robbo.png";;
let dir2frame = function
  |Direction.UP    -> 0
  |Direction.RIGHT -> 2
  |Direction.DOWN  -> 4
  |Direction.LEFT  -> 6
  |_ -> 4
;;
let turn robbo dir =
  let frame = dir2frame dir in
  Element.set_frames robbo frame (frame + 1)
;;

let user_dir  = ref Direction.STAY;;
let user_fire = ref Direction.STAY;;
let set_direction dir = user_dir := dir;;
let set_fire dir      = user_fire := dir;;

let shot image elem dir = 
  turn elem dir;
  if (Level_data.has_ammo (Level_image.get_data image)) then begin
    let data = Level_image.get_data image in
    Level_data.dec_ammo data;
    Shot.elem_shot image elem dir
  end else []
;;
let move image elem dir = 
  turn elem dir;
  let next = Element.elem_next image elem dir in
  if not (Element.robbo_can image next dir) then ((0,0), []) else begin
    let (new_pos, lst) = Element.robbo_on image next dir in
    let speed = match new_pos with
      |None -> Element.get_speed_dir dir
      |_    -> (0, 0)
    in
    begin match new_pos with
       |None     -> Elem_op.move_dir image elem dir
       |Some pos -> begin
         let old_pos = Element.get_pos elem in
         Element.set_pos elem pos;
         Empty.put_new image old_pos;
         Level_image.put image pos elem;
         Element.set_sprite_pos elem pos;
       end
    end;
    Graph.follow (Element.get_pos elem);
    (speed, lst)
  end
;;
let next_frame elem = if Element.has_speed elem then Element.set_next_frame elem;;
let action image elem =
  let (new_speed, lst) = 
    if !user_dir != Direction.STAY then move image elem !user_dir
    else if !user_fire != Direction.STAY then ((0, 0), shot image elem !user_fire)
    else ((0, 0), [])
  in
  next_frame elem;
  Element.set_speed elem new_speed;
  elem::lst
;;

let step  = Element.sprite_move;;
let blow image elem = 
  let data = Level_image.get_data image in
  ignore (Elem_op.blow_destroy image elem);
  raise Die
;;

let methods = {
  Element.robbo_can = Elem_op.robbo_cant;
  Element.robbo_on  = Elem_op.robbo_cant_on;
  Element.on_shot   = Elem_op.on_shot_destroy;
  Element.blow      = blow;
  Element.next_step   = Element.sprite_move;
  Element.next_action = action;
  Element.draw        = Element.sprite_draw
};;

(** [my_kind elem] czy element jest "mojego" rodzaju? *)
let my_kind {Element.id=eid} = eid=id;;

(** [create pos] daj nowy element i nadaj mu pozycjê [pos] *)
let create = Element.default_creator picture 4 5 ~id methods;;

(** [put_new image pos] stwórz nowy element, ustaw go na pozycji [pos] na 
    planszy [image] *)
let put_new image pos =
  let elem = create pos in
  Level_image.put image pos elem
;;

Element.register id create;;

(*
let find image = Level_image.find_first (fun e -> (Element.to_char e) = 'R') image;;
let find_list lst = List.find (fun e -> (Element.to_char e) = 'R') lst;;
*)