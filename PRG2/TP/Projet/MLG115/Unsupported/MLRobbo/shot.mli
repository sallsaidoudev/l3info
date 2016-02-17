(** [create dir pos] daj nowy strza³ lec±cy w kierunku [dir], 
    nadaj mu pozycjê [pos] *)
val create : Direction.t -> int * int -> Element.t;;

(** [put_new dir image pos] *)
val put_new : Direction.t -> (Element.t, 'b) Level_image.t -> int * int -> Element.t;;

(** [elem_shot image elem dir] element [elem] strzeli³ w kierunku [dir]. 
   Robi strza³ ze wszelkimi konsekwencjami.
   Daje liste aktywnych elementów *)
val elem_shot : (Element.t, Level_data.t) Level_image.t -> Element.t -> Direction.t -> 
    Element.t list;;
