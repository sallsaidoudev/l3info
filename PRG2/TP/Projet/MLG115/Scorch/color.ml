let colorize_gray ((cr, cg, cb), ca) ((r, g, b), a) =
  if (r = b) && (b = g) then
    ((cr * r) / 256, (cg * r) / 256, (cb * r) / 256), a
  else
    (r, g, b), a
;;

let colors = Hashtbl.create 10;;

Hashtbl.replace colors "white" (255, 255, 255);;

let add_color (name, r, g, b) =
  Hashtbl.replace colors name (r, g, b)
;;

let pcolor = Parser.int ~max:255 ~min:0 () in
Parser.add_command 
  "color" 
  (Parser.quadruple Parser.string pcolor pcolor pcolor) 
  "Adds a new color to color table; format: r g b"
  add_color
;;

let get name =
  try Hashtbl.find colors name
  with Not_found -> (240, 0, 240)
;;

let shade_surf () = 
  let surface = Video.create_surface ~alpha:true (64, 64) in
  Video.color_surface surface (fun _ -> ((0, 0, 0), 128))
;;
let shade = Video.optimize ~alpha:true (Video.provide_image shade_surf);;
(*
let shade = Video.optimize (Video.color_key ~ck:(255, 0, 255) (Video.load_image ("./gfx/shade.png")));;
*)
(*let shade ?on (x, y) (w, h) =
  let src_rect = Sdlvideo.rect 0 0 w h in
  Video.blit shade_surf ~src_rect ?on x y
;;*)
