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
  (* Czy robbo mo¿e wej¶æ na pole ze wskazanego kierunku *)
  robbo_can     :(t, Level_data.t) Level_image.t -> t-> Direction.t -> bool;
  (* Robbo wchodzi na pole, na pewno mo¿e to robiæ. 
     Daje: ewentuln± now± pozycjê robba, listê aktywnych elementów.
     Je¶li nowa pozycja = None to robbo po prostu wchodzi na to pole *)
  robbo_on      :(t, Level_data.t) Level_image.t -> t -> Direction.t -> 
                 (int*int) option * t list;
  (* Dzia³anie strza³u: true=reaguje; false=niezniszczalne *)
  on_shot       :t -> bool;
  (* Wybuchnij element, daje listê aktywnych elementów *)
  blow          :(t, Level_data.t) Level_image.t -> t -> t list;
  next_step     :t -> unit;
  next_action   :(t, Level_data.t) Level_image.t -> t -> t list;
  draw          :t -> unit
};;

(** {6  Rejestrowanie nowych elementów} *)

(** [Element.default_creator graph frame_min frame_max ?id ?speed methods pos]
    Najprostszy kreator elementów.
    [graph] rysunek; 
    [frame_min] [frame_max] pierwsza i ostatnia klata animacji z rysunku (0..);
    [id] identyfikator, domy¶lnie brak; 
    [methods] metody; [pos] jak± pozycjê nadaæ *)
val default_creator : Video.t -> int -> int -> 
    ?id:char -> ?speed: int*int -> methods -> int*int -> t;;

(** [Element.put_new creator image pos] kreatorem tworzy nowy element z pozycj±
    [pos] i stawia go na tej pozycji w obrazie [image], zwraca nowy element *)
val put_new : (int*int -> t) -> (t, Level_data.t) Level_image.t -> int*int -> t;;

(** [Element.register id creator] element o identyfikatorze [id] mo¿e byæ wczytywany
    z planszy; do tworzenia bêdzie u¿ywany [creator] (int*int->t) *)
val register : char -> (int*int -> t) -> unit;;


(** {6 Konstruktor} *)
(** [Element.by_char char pos] na podstawie jednego znaku [char] stwórz odpowiedni
    element i nadaj mu pozycjê [pos].
    Rzuca [Not_found] je¶li odwzorowanie nie jest mo¿liwe *)
val by_char : char -> int*int -> t;;


(** {6 Dostêp do atrybutów} *)
val def_speed     : int;;
val def_speed_vec : int*int;;
val get_id    : t -> char;;
val id_equal  : t -> t -> bool;;
val get_frame : t -> int;;
val set_next_frame : t -> unit;;
val get_frames : t -> int*int;;
val set_frames : t -> int -> int -> unit;;
val pos_removed : int*int;;
val get_pos : t -> int*int;;
val set_pos : t -> int*int -> unit;;
val set_as_removed : t -> unit;;
val set_pos_dir : t -> Direction.t -> unit;;
val get_speed : t -> int*int;;
val set_speed : t -> int*int -> unit;;
val get_speed_dir : Direction.t -> int*int;;
val set_speed_dir : t -> Direction.t -> unit;;
val has_speed : t -> bool;;
val set_sprite_pos : t -> int*int -> unit;;
val sprite_move : t -> unit;;
val sprite_draw : t -> unit;;


(** {6 S±siedzi elementu} *)
val pos_next : int*int -> Direction.t -> int*int;;
val elem_next : (t, Level_data.t) Level_image.t -> t -> Direction.t -> t;;
val elem_next_pos : t -> Direction.t -> int*int;;


(** {6 U¿ycie metod elementu} *)

(** [robbo_can image elem dir] czy robbo mo¿e wej¶æ na pole ze wskazanego kierunku *)
val robbo_can : (t, Level_data.t) Level_image.t -> t -> Direction.t -> bool;;

(** [robbo_on image elem dir] robbo wchodzi na pole, na pewno mo¿e to robiæ. 
    Daje: ewentuln± now± pozycjê robba (option of int*int), listê aktywnych elementów.
    Je¶li nowa pozycja = None to robbo po prostu wchodzi na to pole *)
val robbo_on : (t, Level_data.t) Level_image.t -> t -> Direction.t -> 
    (int*int) option * t list;;

(** [on_shot elem] dzia³anie strza³u: true=reaguje; false=niezniszczalne *)
val on_shot : t -> bool;;

(** [blow image elem] wybuchnij element, daje listê aktywnych elementów *)
val blow : (t, Level_data.t) Level_image.t -> t -> t list;;

(** [next_step elem] jeden ma³y kroczek *)
val next_step : t -> unit;;

(** [next_action image elem] du¿y krok - zmiana obrazu planszy, daje listê aktywnych
    elementów *)
val next_action : (t, Level_data.t) Level_image.t -> t -> t list;;

val draw : t -> unit;;
