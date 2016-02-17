module type Elem = sig
  val id : char
  val my_kind : Element.t -> bool
  val create : int*int -> Element.t
end;;

module Wall : Elem;;
module Nothing : Elem;;
module Gum : Elem;;
