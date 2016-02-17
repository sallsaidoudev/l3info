type t = {
  sprite	        :unit Sprite.t;
  id                :char;
  mutable frame_min	:int;
  mutable frame_max	:int;
  mutable frame	    :int;
  mutable speed     :int*int;
  mutable pos       :int*int;
  methods	        :methods
} and
methods = {
  robbo_can     :(t, Level_data.t) Level_image.t -> t -> Direction.t -> bool;
  robbo_on      :(t, Level_data.t) Level_image.t -> t -> Direction.t -> 
                 (int*int)option * t list;
  on_shot       :t -> bool;
  blow          :(t, Level_data.t) Level_image.t -> t -> t list;
  next_step     :t -> unit;
  next_action   :(t, Level_data.t) Level_image.t -> t -> t list;
  draw          :t -> unit
};;

(***********************************************************************************)
(* Rejestrowanie nowych elementów *)
(* [Element.default_creator graph frame_min frame_max ?id methods pos] *)
let default_creator picture frame_min frame_max ?(id='?') ?(speed=(0,0)) methods pos =
  let sprite = Graph.create_sprite picture pos in
  let gpos = Graph.pos2graph pos in
  let elem = {
    sprite=sprite;
    id    =id;
    frame_min   =frame_min;
    frame_max   =frame_max;
    frame       =frame_min;
    methods=methods;
    speed  =speed;
    pos    =pos
  } in
  Sprite.set_animation_frame sprite elem.frame;
  Sprite.move_to sprite gpos;
  elem
;;
(* [Element.put_new creator image pos] kreatorem tworzy nowy element z pozycj± *)
let put_new creator image pos = 
  let elem = creator pos in
  Level_image.put image pos elem;
  elem
;;

let all_elements = Hashtbl.create 20;;

(* [Element.register id creator] *)
let register = Hashtbl.add all_elements;;

(***********************************************************************************)
(* Konstruktor *)
(* [Element.by_char char pos] *)
let by_char char pos = 
  let creator = Hashtbl.find all_elements char in
  creator pos
;;

(***********************************************************************************)
(* Dostêp do atrybutów *)
let def_speed = 16;;
let def_speed_vec = (def_speed, def_speed);;
let get_id  {id=id} = id;;
let id_equal {id=id1} {id=id2} = id1=id2;;
let get_frame {frame=frame} = frame;;
let set_next_frame elem = 
  let frame = if elem.frame = elem.frame_max then elem.frame_min else elem.frame + 1 in
  Sprite.set_animation_frame elem.sprite frame;
  elem.frame <- frame
;;
let get_frames {frame_min=f_min; frame_max=f_max} = (f_min, f_max);;
let set_frames elem f_min f_max =
  elem.frame_min <- f_min;
  elem.frame_max <- f_max;
  if elem.frame < f_min || elem.frame > f_max then begin
    elem.frame <- f_min;
    Sprite.set_animation_frame elem.sprite f_min;
  end
;;
let pos_removed = (-1, -1);;
let get_pos {pos=pos} = pos;;
let set_pos elem pos = elem.pos <- pos;;
let set_as_removed elem = elem.pos <- pos_removed;;
let set_pos_dir elem dir =
  let pos = Direction.add dir elem.pos in
  elem.pos <- pos
;;
let get_speed {speed=speed} = speed;;
let set_speed elem speed = elem.speed <- speed;;
let get_speed_dir dir = Direction.mul dir def_speed_vec;;
let set_speed_dir elem dir =
  let speed = get_speed_dir dir in
  elem.speed <- speed
;;
let has_speed {speed = (x, y)} = (x != 0) || (y != 0);;
let dir2speed dir = Direction.mul dir def_speed_vec;;

let set_sprite_pos {sprite=sprite} pos = 
  let g = Graph.pos2graph pos in
  Sprite.move_to sprite g
;;
let sprite_move elem = Sprite.move elem.sprite elem.speed;;
let sprite_draw {sprite=sprite} = Sprite.draw ~on:Graph.level_context sprite;;

(***********************************************************************************)
(* S±siedzi elementu *)
let pos_next pos dir = Direction.add dir pos;;
let elem_next image {pos=pos} dir = 
  let n = Direction.add dir pos in
  Level_image.get image n
;;
let elem_next_pos {pos=pos} dir = Direction.add dir pos;;

(***********************************************************************************)
(* U¿ycie metod elementu *)
let robbo_can image elem = elem.methods.robbo_can image elem;;
let robbo_on image elem = elem.methods.robbo_on image elem;;
let on_shot elem = elem.methods.on_shot elem;;
let blow image elem = elem.methods.blow image elem;;
let next_step elem = elem.methods.next_step elem;;
let next_action image elem = 
  let is_playing {pos=(x, _)} = x >= 0 in
  if is_playing elem then elem.methods.next_action image elem
  else []
;;
let draw elem = elem.methods.draw elem;;
