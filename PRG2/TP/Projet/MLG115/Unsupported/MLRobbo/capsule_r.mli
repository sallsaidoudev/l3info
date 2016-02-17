(** Dodaje element '$' *)
(** [Robbo_inside] rzucny gdy robbo wejdzie do dzia�aj�cej kapsu�y *)
exception Robbo_inside;;

(** [my_kind elem] *)
val my_kind : Element.t -> bool;;

(** [create pos] *)
val create : int * int -> Element.t;;

(** [ready_to_take_off image] Robbo zebra� wszystkie �rubki. 
    Zaznacz kapsu� jako gotowe do startu. Zwraca zb�r kapsu� *)
val ready_to_take_off : (Element.t, 'b) Level_image.t -> Element.t list;;
