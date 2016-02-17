(** {6 Rysunki} *)
(** Szeroko�� elementu *)
val frame_width : int;;

(** Wysoko�� elementu *)
val frame_height : int;;

(** Pozycja na mapie -> pozycja w kontek�cie graficznym *)
val pos2graph : int*int -> int*int;;

(** [Graph.load_image file_name] wczytuje rysunek z pliku [file_name] z 
    katalogu graph/atari/ i daje jego obraz (Sdlvideo.surface) *)
val load_image : string -> Video.t;;

(** [Graph.create_sprite image pos] daje nowego duszka z rysunkiem [image] na
    pozycji [pos] na planszy (wsp�rz�dne planszy) *)
val create_sprite : Video.t -> int*int -> unit Sprite.t;;

(** [Graph.hide_console ()] zamazuje konsol� *)
val hide_console : unit -> unit;;

(** {6 Konteksty graficzne} *)

(** [Graph.level_context] kontekst dla planszy gry *)
val level_context : Video.t;;

(** [Graph.data_context] kontekst dla informacji o planszy *)
val data_context : Video.t;;


(** {6 �ledzenie obiektu na planszy} *)

(** [Graph.follow (x, y)] element �ledzony jest pozycji (x, y) *)
val follow : int*int -> unit;;

(** [Graph.cam_default ()] ustaw kamer� w domy�lnej pozycji *)
val cam_default : unit -> unit;;

(** [Graph.follow_action ()] pod��aj za czerwonym kr�likiem...
    Przesu� kamer� o jeden kroczek *)
val follow_action : unit -> unit;;
