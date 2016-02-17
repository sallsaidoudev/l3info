let picture = Graph.load_image "wybuch.png";;

let next_action image elem =
  Element.set_next_frame elem;
  let {Element.frame=frame; Element.frame_min=min; Element.pos=pos} = elem in
  if frame > min then [elem] else begin
    Element.set_as_removed elem;
    Empty.put_new image pos;
    []
  end
;;
let methods = {
  Element.robbo_can     = (fun _ _ _ -> false);
  Element.robbo_on      = (fun _ _ _ -> failwith "blow:robbo_on");
  Element.on_shot       = (fun _ -> false);
  Element.blow          = (fun _ _ -> []);
  Element.next_step     = (fun _ -> ());
  Element.next_action   = next_action;
  Element.draw          = Element.sprite_draw
};;

let put_new image pos = 
  let creator = Element.default_creator picture 0 4 methods in
  let elem = creator pos in
  Level_image.put image pos elem;
  elem
;;
