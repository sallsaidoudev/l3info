(** [put_new image pos] stw�rz nowy wybuch, ustaw go na pozycji [pos] na 
    planszy [image] *)
val put_new : (Element.t, 'a) Level_image.t -> int * int -> Element.t;;
