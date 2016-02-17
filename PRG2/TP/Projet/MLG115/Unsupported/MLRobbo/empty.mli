(** Dodaje nowy element ' ' *)

(** [my_kind elem] czy element jest pustk±? *)
val my_kind : Element.t -> bool;;

(** [create pos] daj nowe puste pole i nadaj mu pozycjê [pos] *)
val create : int * int -> Element.t;;

(** [put_new image pos] stwórz nowy element, ustaw go na pozycji [pos] na 
    planszy [image] *)
val put_new : (Element.t, 'b) Level_image.t -> int * int -> unit;;
