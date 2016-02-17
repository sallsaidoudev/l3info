(** Dodaje element '$' *)
(** [Robbo_inside] rzucny gdy robbo wejdzie do dzia³aj±cej kapsu³y *)
exception Robbo_inside;;

(** [my_kind elem] *)
val my_kind : Element.t -> bool;;

(** [create pos] *)
val create : int * int -> Element.t;;

(** [ready_to_take_off image] Robbo zebra³ wszystkie ¶rubki. 
    Zaznacz kapsu³ jako gotowe do startu. Zwraca zbór kapsu³ *)
val ready_to_take_off : (Element.t, 'b) Level_image.t -> Element.t list;;
