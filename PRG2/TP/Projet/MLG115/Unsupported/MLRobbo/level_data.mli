type t;;


(** {6 Kontruktory} *)

(** Dodaje do parsera:
    lives - pocz±tkowa ilo¶æ ¿yæ (domy¶lnie 8)
    ammo  - pocz±tkowa amunicja  (domy¶lnie 0)
*)
(** [Level_data.create nr] dane dla planszy [nr] *)
val create : int -> t;;
(** [Level_data.create_with data] rozpoczynasz planszê, nowe dane an podstawie [data] *)
val create_with : t -> t;;


(** {6 Modyfikatory} Zmieniam warto¶æ i dodajê odpowiedni± ilo¶æ punktów *)

(** [Level_data.dec_screw data] zebra³e¶ ¶rubkê *)
val dec_screw : t -> unit;; 
(** [Level_data.dec_live data] kucha - biedny robbo *)
val dec_live : t -> unit;;
(** [Level_data.dec_key data] drzwi otwarte *)
val dec_key : t -> unit;;
(** [Level_data.inc_key data] znalaz³e¶ klucz do drzwi *)
val inc_key : t -> unit;;
(** [Level_data.dec_ammo data] strza³ *)
val dec_ammo : t -> unit;;
(** [Level_data.inc_ammo data] masz bateryjkê *)
val inc_ammo : t -> unit;;
(** [Level_data.inc_nr data] prawo - planeta ukoñczona *)
val inc_nr : t -> unit;;
(** [Level_data.set_screw data count] plansza ma [count] ¶rubek *)
val set_screw : t -> int -> unit;;


(** {6 Pytania} *)

(** [Level_data data] zebrano wszystkie ¶rubki *)
val all_screws : t -> bool;;
(** [Level_data.get_nr data] *)
val get_nr : t -> int;;
(** [Level_data.has_key data] *)
val has_key : t -> bool;;
(** [Level_data.has_ammo data] *)
val has_ammo : t -> bool;;
(** [Level_data.get_live data] *)
val get_live : t -> int;;


(** {6 Rysowanie} *)

(** [Level_data.redraw data] czy trzeba odrysowaæ bo nastapi³a zmiana? *)
val redraw : t -> bool;;
(** [Level_data.draw_all data] odrysuj informacje w Graph.data_context *)
val draw_all : t -> unit;;
