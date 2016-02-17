(** {6 Rysunki} *)
(** Szeroko¶æ elementu *)
val frame_width : int;;

(** Wysoko¶æ elementu *)
val frame_height : int;;

(** Pozycja na mapie -> pozycja w kontek¶cie graficznym *)
val pos2graph : int*int -> int*int;;

(** [Graph.load_image file_name] wczytuje rysunek z pliku [file_name] z 
    katalogu graph/atari/ i daje jego obraz (Sdlvideo.surface) *)
val load_image : string -> Video.t;;

(** [Graph.create_sprite image pos] daje nowego duszka z rysunkiem [image] na
    pozycji [pos] na planszy (wspó³rzêdne planszy) *)
val create_sprite : Video.t -> int*int -> unit Sprite.t;;

(** [Graph.hide_console ()] zamazuje konsolê *)
val hide_console : unit -> unit;;

(** {6 Konteksty graficzne} *)

(** [Graph.level_context] kontekst dla planszy gry *)
val level_context : Video.t;;

(** [Graph.data_context] kontekst dla informacji o planszy *)
val data_context : Video.t;;


(** {6 ¦ledzenie obiektu na planszy} *)

(** [Graph.follow (x, y)] element ¶ledzony jest pozycji (x, y) *)
val follow : int*int -> unit;;

(** [Graph.cam_default ()] ustaw kamerê w domy¶lnej pozycji *)
val cam_default : unit -> unit;;

(** [Graph.follow_action ()] pod±¿aj za czerwonym królikiem...
    Przesuñ kamerê o jeden kroczek *)
val follow_action : unit -> unit;;
