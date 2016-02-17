module type Elem = sig
  (** [id] *)
  val id : char
  
  (** [my_kind elem] czy element jest "mojego" rodzaju *)
  val my_kind : Element.t -> bool
  
  (** [create pos] Stw�rz element i nadaj mu pozycj� pos *)
  val create : int*int -> Element.t
end;;

module Ammo : Elem;;
module Key : Elem;;
module Door : Elem;;
module Screw : Elem;;