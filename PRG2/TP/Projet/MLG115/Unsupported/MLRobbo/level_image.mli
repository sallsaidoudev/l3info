(** P³aski obraz planszy
   Prezentacja obrazu planszy - co¶ jak tablica dwuwymiarowa.
   Pozycja numerowane: x=0..level_width-1, y=0..level_height-1
   W tej implementacji zak³adam, ¿e pola na krawêdziach (góra, gó³, lewy, prawy)
   nie s± zbytnio interesuj±ce...
*)

type ('a, 'b) t;;
 
(** Szeroko¶æ planszy - tak jak w Atari *)
val level_width : int;;
(** Wysoko¶æ planszy - tak jak w Atari *)
val level_height : int;;


(** {6 Zmiana i dostêp do zawarto¶ci} *)
(** [Level_image.get_data image] daje dane zwi±zane z obrazem planszy *)
val get_data : ('a, 'b) t -> 'b;;
(** [Level_image.put image pos elem] *)
val put : ('a, 'b) t -> int * int -> 'a -> unit;; 
(** [Level_image.get image pos] *)
val get : ('a, 'b) t -> int * int -> 'a;;

(** {6 Tworzenie nowej planszy} *)
(** [Level_image.create_simple elem data] tworzy obraz sk³adaj±cy siê z 
    elementów [elem], z przywi±zanymi danymi *)
val create_simple : 'a -> 'b -> ('a, 'b) t;;

(** [Level_image.create map data] tworzy obraz planszy z elementami zwrócony
    przez [map] (fun (x, y) -> 'a) *)
val create : (int * int -> 'a) -> 'b -> ('a, 'b) t;;

(** [Level_image.load char2elem unknown data stream] tworzy obraz planszy
    na podstawie zawarto¶ci strumienia wej¶ciowego [stream]. 
    Format pliku:
    Ka¿dy znak jest t³umaczony przez [char2elem] (fun char->(x, y)->'a) 
    na element planszy.
    Nowa linia to kolejny wiersz planszy.
    Pola nieokre¶lone w strumieniu tworzê konstruktorem [unknown] (x, y)->'a. *)
val load : (char -> int * int -> 'a) -> (int * int -> 'a) -> 'b -> in_channel
    -> ('a, 'b) t;;

(** [Level_image.print conv image stream] wypisuje obraz [image] na strumieñ
   [stream]. Funkcja [conv] ('a -> string) odpowiada za konwersjê obrazu do
   wypisywanego napisu. Ka¿dy wypisany wiersz planszy koñczê znakiem \n *) 
val print : out_channel -> ('a -> string) -> ('a, 'b) t -> unit;;

(** {6 Selektory} *)
(** [Level_image.neighbours7 (x, y)] daje listê pozycji 7 bezpo¶rednich s±siadów
    pola ([x], [y]) na planszy *)
val neighbours7 : int * int -> (int * int) list;;

(** [Level_image.neighbours4 (x, y)] daje listê pozycji 4 bezpo¶rednich s±siadów
    pola ([x], [y]) na planszy *)
val neighbours4 : int * int -> (int * int) list;;

(** [Level_image.get_all image] *)
val get_all : ('a, 'b) t -> 'a list;;

(** [Level_image.get_elems p image] daj listê elementów spe³niaj±cych warunek 
    [p] 'a->bool *)
val get_elems : ('a -> bool) -> ('a, 'b) t -> 'a list;;

(** [Level_image.count p image] oblicz ile elementów z [image] spe³nia warunek
    [p] 'a->bool *)
val count : ('a -> bool) -> ('a, 'b) t -> int;;

(** [Level_image.find_first p image] daj pierwszy element spe³niaj±cy p.
    Je¶li nie ma elementu spe³niaj±cego [p] rzuca wyj±tek [Not_found] *)
val find_first : ('a -> bool) -> ('a, 'b) t -> 'a;;

(** [Level_image.first_from p pos image] daj pierwszy element spe³niaj±cy p.
    Zacznij szukaæ od pozycji nastêpnej po p. Szuka cyklicznie, je¶li elementu nie
    ma zapêtli siê *)
val first_from : ('a -> bool) -> int * int -> ('a, 'b) t -> 'a;;

(** {6 Iteratory} *)
(** [Level_image.iteri p image] stosuje funkcje p do ka¿dego elementu planszy
    p:(x, y)->'a->unit *)
val iteri : (int * int -> 'a -> unit) -> ('a, 'b) t ->  unit;;

(** [Level_image.iter p image] stosuje funkcje p do ka¿dego elementu planszy
    p:'a->unit *)
val iter : ('a -> unit) -> ('a, 'b) t -> unit;;