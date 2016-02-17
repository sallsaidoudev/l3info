let id = ' ';;
let picture = Graph.load_image "podloga.png";;
let methods = {
  Element.robbo_can   = (fun _ _ _ -> true);
  Element.robbo_on    = (fun _ _ _ -> (None, []));
  Element.on_shot     = (fun _ -> failwith "empty:on_shot");
  Element.blow        = (fun _ _ -> failwith "empty:blow");
  Element.next_step   = (fun _ -> ());
  Element.next_action = (fun _ _ -> []);
  Element.draw        = (fun _ -> ())
};;

let my_kind {Element.id=eid} = eid = id;;

let create = Element.default_creator picture 0 0 ~id methods;;

let put_new image pos =
  let elem = create pos in
  Level_image.put image pos elem
  (* Tu jest pewna niekonsekwencja - inne elementy zwracaj± siebie *)
;;

Element.register id create;;