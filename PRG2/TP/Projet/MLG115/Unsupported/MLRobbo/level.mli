(** {6 Konstruktory plansz} *)

(** [Level.set_level number] plansza numer [number] staje siê aktualn± plansz±,
    ¿ycia=8, punkty=0 *)
val set_level : int -> unit;;

(** [Level.set_next_level ()] robocik przeszed³ do nastepnej planszy.
    Nast. plansza staje siê aktualna, nie zmieniam ilo¶ci ¿yæ i punktów *)
val set_next_level : unit -> unit;;

(** [print file_name] wypisujê obraz planszy do pliku [file_name] *)
val print : string -> unit;;


(** {6 Restart planszy} *)

(** [Level.next_level_exist ()] czy aktualna plansza jest ostatnia? *)
val next_level_exist : unit -> bool;;

(** [Level.restart_ok ()] czy mo¿na restartowaæ, czy te¿ straci³e¶ wszystkie 
    robociki? *)
val restart_ok : unit -> bool;;

(** [Level.restart ()] Odejmij jedno ¿ycie i zacznij planszê od pocz±tku *)
val restart : unit -> unit;;

(** [Level.blow_all ()] wszystkie elementy !=Empty,Wall zamieniam w wybuchy *)
val blow_all : unit -> unit;;

(** [Level.remove_col col] wszystkie elementy z kolumny [col] zastêpujê przez 
    Nothing *)
val remove_col : int -> unit;;


(** {6 Kroki gry} *)
type action = NOTHING|MOVE of Direction.t|FIRE of Direction.t;;

(** [Level.next_action] zrób co¶ z plansz± 
    Parametry tak czêsto siê zmieniaj±, ¿e skoda cokolwiek opisywaæ *)
val next_action : (unit -> action) -> unit;;


(** {6 Prezentacja graficzna planszy} *)
(** [Level.draw_image ()] Wyrysuj obraz planszy na odpowiednim kontek¶cie *)
val draw_image : unit -> unit;;

(** [Level.draw_info ?always ()] Wyrysuj informacje o planszy (punkty itp.)
    tylko je¶li trzeba (domy¶lnie) lub zawsze (always=true) *)
val draw_info : ?always:bool -> unit -> unit;;
