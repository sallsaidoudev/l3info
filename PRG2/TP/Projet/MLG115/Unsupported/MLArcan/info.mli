(** [load_image file_name] daje rysunek zaladowany z pliku [file_name]
    z katalogu graph/ *)
val load_image : string -> Video.t

val load_image2 : string -> Video.t

(** [wait image ()] wyswietla rysunek [image] i czeka "ladnie" az nacisniesz 
    klawisz z akcja break *)
val wait : Video.t -> unit -> unit

(** [wait file_name ()] wyswietla rysunek z pliku [file_name] (zobacz {load_image}),
    czeka "ladnie" az nacisniesz klawisz z akcja break *)
val wait2 : string -> unit -> unit

val draw_string : string -> int -> int -> unit
val draw : int -> unit -> unit
val draw_scores : (int * string) list -> 'a -> unit
val scores : int -> unit

