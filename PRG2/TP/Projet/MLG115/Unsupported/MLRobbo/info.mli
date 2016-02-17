(** [load_image file_name] daje rysunek zaladowany z pliku [file_name]
    z katalogu graph *)
val load_image : string -> Video.t;;

(** [wait image ()] wyswietla rysunek [image] i czeka "ladnie" az nacisniesz 
    klawisz z akcja break *)
val wait : Video.t -> unit -> unit;;

(** [wait file_name ()] wyswietla rysunek z pliku [file_name] (zobacz {!Info.load_image}),
    czeka "ladnie" az nacisniesz klawisz z akcja break *)
val wait2 : string -> unit -> unit;;
