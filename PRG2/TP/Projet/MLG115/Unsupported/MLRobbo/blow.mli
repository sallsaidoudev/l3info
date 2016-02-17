(** [put_new image pos] stwórz nowy wybuch, ustaw go na pozycji [pos] na 
    planszy [image] *)
val put_new : (Element.t, 'a) Level_image.t -> int * int -> Element.t;;
