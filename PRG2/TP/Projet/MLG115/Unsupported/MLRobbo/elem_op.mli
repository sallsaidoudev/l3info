(** [remove_elem image elem] *)
val remove_elem : (Element.t, 'a) Level_image.t -> Element.t -> unit;;

(** [move_dir image elem dir] [elem] wêdruje o jedno pole w kierunku [dir], w jego
    stare miejsce stawiam Empty *)
val move_dir : (Element.t, 'a) Level_image.t -> Element.t -> Direction.t -> unit;;


(** {5 Metody} *)
val robbo_cant    : 'a -> 'b -> 'c -> bool;;
val robbo_cant_on : 'a -> 'b -> 'c -> (int*int) option * Element.t list;;
val on_shot_destroy : 'a -> bool;;
val on_shot_resist  : 'a -> bool;;
val blow_destroy : (Element.t, 'a) Level_image.t -> Element.t -> Element.t list;;
val blow_resist  : 'a -> 'b -> Element.t list;;
val step_empty   : 'a -> unit;;
val action_empty : 'a -> 'b -> Element.t list;;


(** {5 Metody dla elementów przesuwanych} *)
(** [movable_robbo_can image elem dir] *)
val movable_robbo_can : (Element.t, Level_data.t) Level_image.t -> 
    Element.t -> Direction.t -> bool;;

(** [movable_robbo_on image elem dir] *)
val movable_robbo_on : (Element.t, 'a) Level_image.t -> Element.t -> Direction.t ->
    (int*int) option * Element.t list;;

(** [movable_step elem] *)
val movable_step : Element.t -> unit;;

(** [movable_action image elem] *)
val movable_action : 'a -> 'b -> Element.t list;;


(** {5 Metody dla elementów zbieranych} *)

(** [collect_robbo_can image elem dir] *)
val collect_robbo_can : 'a -> 'b -> 'c -> bool;;

(** [collect_robbo_on trigger image elem dir] *) 
val collect_robbo_on : (Level_data.t -> unit) -> 
    (Element.t, Level_data.t) Level_image.t -> Element.t -> 'a -> 
    (int*int) option * Element.t list;;
