(*
Some docs:

Size and drawing procedure:

First a parent widget gets the size. The size is a pair, 
the requested dimensions and a pair of bools than define if the child widget wants
this dimensions to be exact or if they are just minimum and widget is stretchable.
The child widget performs no checking on dimensions passed to its draw function.
It's its parent widget duty to feed it with right dimensions. They should never be 
less than the requested. Some widgets requesting exact size can handle being fed with
larger, and will just draw themselves in upper left corner of space they get, but they
children look may become garbled. So don't do that.

Event handling:

Events first go from parent widget to a child, then they return. This way every
widget can decide whether it handles the event, discards it or passes it down to its
children, and then processes the events returned by its children. After evaluation it 
returns some events, discarding means it Eno event, handling may return Eno, or some 
other, which can be handled by its parent on its way up. The general rule is that 
events are first passed down to children, and handled when returned from them, but at 
this point it is not clear if some exceptions are necessary.

Example: the vert_focus_list passes all events to its focused child, then through all
its unfocused children, and then handles Up and Down, returning Eno; other events are
passed up unchanged.

When a widget has focused and unfocused children it is important to divide events
handled by a focused widget i.e. Ok. and other events, usually passed by all widgets
Every child widget must handle or discard (returning Eno) all of them, to make sure 
only the first one (focused) gets them.

*)

let tile_fill ?on ?surf tile (x, y) (w, h) =
  match Video.image_size tile with (tw, th) ->
  for xx = 0 to (w / tw) do
    for yy = 0 to (h / th) do
      let bx, by = (x + (xx*tw)), (y + (yy*th)) in
      let w, h = min (w - (xx*tw)) tw, min (h - (yy*th)) th in
      let src_rect = Sdlvideo.rect 0 0 w h in
      Video.blit tile ?on ?surf ~src_rect (x + (xx*tw)) (y + (yy*th))
    done
  done;
;;

type ('a, 'b) dyn_adapt = A of 'a | B of 'b;;
let adapt a b = A a, B b;;

type t_pos = int * int;;
type t_style = ((bool * (int * int * int) * int) * (Video.t option) * Font.t);;
type t_event = Eno | Up | Down | Left | Right | Ok | Switch of int | Raw of Sdlevent.event;;
type t_size = t_pos * (bool * bool);;

type 'a t_size_fun = t_style -> 'a -> t_size ;;
type 'a t_draw_fun = t_pos -> t_pos -> t_style -> 'a -> unit;;
type 'a t_handle_fun = t_event -> 'a -> t_event;;

type 'a t = ('a t_size_fun) * ('a t_draw_fun) * ('a t_handle_fun ) * 'a;;

let large_font = Font.load ~alpha:true "./gfx/hgotic.png";;
(*let large_font = Font.load ~alpha:true "./gfx/fixed13s.png";;*)
(*let large_font = Font.display_format ~alpha:true large_font;;*)

let size style (size_fun, draw_fun, event_fun, properties) = size_fun style properties;;
let draw pos dims style (size_fun, draw_fun, event_fun, properties) = draw_fun pos dims style properties;;
let handle event (size_fun, draw_fun, event_fun, properties) = event_fun event properties;;

let frame (frame_, background, font) = frame_;;
let back (frame, background, font) = background;;
let font (frame, background, font_) = font_;;

let dims (dims, stretch) : t_pos = dims;;
let stretch (dims, stretch) : bool * bool = stretch;;

let pass_handler event widget = handle event widget;;
let null_handler : 'a t_handle_fun = fun _ _ -> Eno;;
let back_handler : 'a t_handle_fun = fun event _ -> event;;

let no_deco:t_style = ((false, (0,0,0), 1), None, large_font);;
let shd_frame:t_style = ((true, (128,128,128), 1), Some Color.shade, large_font);;
let frame_only:t_style = ((true, (128,128,128), 1), None, large_font);;

let unwidget: unit t = (
  (fun (style:t_style) () -> ((0, 0), (false, false))),
  (fun (x, y) (h, w) (style:t_style) () -> ()), 
  (fun (event:t_event) () -> event), 
  ()
);;

let static_text txt : string t = (
  (fun style txt -> (((Font.width (font style) txt), Font.height (font style)) ), (false, false)),
  (fun (x, y) _ style txt -> (Font.draw_string (font style) x y txt) ),
  ((fun event txt -> event ): string t_handle_fun),
  txt)
;;

(*
let dynamic_text (font, txt) =
  let txt = txt () in (
   (fun (font, txt) -> ((Font.width font txt), Font.height font) ),
  (fun (x, y) (font, txt) -> (Font.draw_string font x y txt) ),
  (fun _ properties -> () ),
  (font, txt) )
;;
*)

let fixed_size_box (w, h, (widget: 'a t)) : 'b t = (
   (fun style (w, h, widget) -> ((w, h), (false, false))),
   (fun (x, y) _ style (w, h, widget) -> 
     let (ww, wh), _ = size style widget in
     draw (x + ((w - ww) / 2), y + ((h - wh) / 2)) (ww, wh) style widget),
   (fun event (w, h, widget) -> handle event widget),
   (w, h, widget) )
;;

let fixed_wd_box (w, (widget: 'a t)) : 'b t = (
   (fun style (w, widget) -> 
     let (_, wh), (_, vs) = size style widget in
     ((w, wh), (false, vs))),
   (fun (x, y) _ style (w, widget) -> 
     let (ww, wh), _ = size style widget in
     draw (x, y) (w, wh) style widget),
   (fun event (w, widget) -> handle event widget),
   (w, widget) )
;; 

let h_center_box widget : ('a t) t = (
  (fun style widget -> 
    let (ww, wh), (hs, vs) = size style widget in
    (ww, wh), (true, vs)),
  (fun (x, y) (w, h) style widget -> 
     let (ww, wh), _ = size style widget in
     draw (x + ((w - ww) / 2), y) (ww, h) style widget),
  pass_handler,
  widget)
;;

let v_center_box widget : ('a t) t = (
  (fun style widget -> 
    let (ww, wh), (hs, vs) = size style widget in
    (ww, wh), (hs, true)),
  (fun (x, y) (w, h) style widget -> 
     let (ww, wh), _ = size style widget in
     draw (x, y + ((h - wh) / 2)) (w, wh) style widget),
  pass_handler,
  widget)
;;
(*
let center_box widget : ('a t) t = (
  (fun style widget -> 
    let (ww, wh), (hs, vs) = size style widget in
    (ww, wh), (true, true)),
  (fun (x, y) (w, h) style widget -> 
     let (ww, wh), _ = size style widget in
     draw (x + ((w - ww) / 2), y + ((h - wh) / 2)) (ww, wh) style widget),
  pass_handler,
  widget)
;;
*)
let center_box widget = v_center_box (h_center_box widget);;

(* strechability and sizing may be wrong with this one!*)
let vert_list lst : (('a t) list) t =
  let size_fun style lst : t_size = 
    List.fold_left (fun ((ow, oh), (hs, vs)) elem ->
      let (ew, eh), (ehs, evs) = size style elem in
      (max ew ow, oh + eh), (*hs && ehs, vs || evs*) (false, false)
    ) ((0, 0), (false, false)) lst
  in
  let draw_fun (x, y) _ style lst =
    ignore (
    List.fold_left (fun y elem ->
      draw (x, y) (fst (size style elem)) style elem;
      y + (snd (fst (size style elem))) ) y lst )
  in
  let handle_fun event lst = event in
  (size_fun, draw_fun, handle_fun, lst)
;;

(* strechability and sizing may be wrong with this one!*)
let vert_focus_list (focus, ustyle, fstyle, lst) =
  let size_fun style (focus, ustyle, fstyle, lst) = 
    fst (
    List.fold_left (fun (((ow, oh), _ ),nth) elem ->
      let style = if nth = !focus then fstyle else ustyle in
      let (ew, eh), _ = size style elem in
      (((max ew ow, oh + eh), (false, false)), nth + 1)) (((0, 0), (false, false)), 0) lst)
  in
  let draw_fun (x, y) _ style (focus, ustyle, fstyle, lst) =
    ignore (
    List.fold_left (fun (y, nth) elem ->
      let style = if nth = !focus then fstyle else ustyle in
      let dims =
        (fst (fst (size_fun style (focus, ustyle, fstyle, lst))),
        snd (fst (size style elem)))
      in
      draw (x, y) dims style elem;
      (y + (snd (fst (size style elem))), nth + 1) ) (y, 0) lst )
  in
  let handle_fun event (focus, ustyle, fstyle, lst) =
    let cascade_handle event =
      fst (
      List.fold_left (fun (event, nth) elem ->
       if nth <> !focus then (handle event elem), nth + 1
       else event, nth + 1)
       (event, 0) lst )
    in
    let norm vl = 
      if vl < 0 then (List.length lst) - 1 else
      if vl >= (List.length lst) then 0
      else vl
    in
    match cascade_handle (handle event (List.nth lst !focus)) with
    | Up -> focus := norm (!focus - 1); Eno
    | Down -> focus := norm (!focus + 1); Eno
    | event -> event
  in
  (size_fun, draw_fun, handle_fun, (focus, ustyle, fstyle, lst))
;;

let stack (focus, lst) : 'a t =
  let size_fun style (focus, lst) =
    size style (List.nth lst !focus)
  in
  let draw_fun (x, y) dims style (focus, lst) =
    draw (x, y) dims style (List.nth lst !focus)
  in
  let handle_fun event (focus, lst) =
    match (handle event (List.nth lst !focus)) with
    | Switch n -> focus := min (max n 0) ((List.length lst) - 1); Eno
    | event -> event
  in
  (size_fun, draw_fun, handle_fun, (focus, lst))
;;

let raw_vert_pair handler (top, bottom) : ('a t * 'b t) t =
  let size_fun style (top, bottom) : t_size =
    let (tw, th), (ths, tvs) = size style top in 
    let (bw, bh), (bhs, bvs) = size style bottom in
    ((max tw bw), (th + bh)), (ths && bhs, tvs || bvs)
  in
  let draw_fun (x, y) (w, h) style (top, bottom) : unit =
    let (ww, wh), (hs, vs) = size_fun style (top, bottom) in
    let (tw, th), (ths, tvs) = size style top in 
    let (bw, bh), (bhs, bvs) = size style bottom in
    let dw = if hs then w else ww in
    let dth, dbh = 
      match tvs, bvs with
      | true, true -> ((h - wh) / 2) + th, ((h - wh) / 2) + bh
      | false, true -> th, h - th
      | true, false -> h - bh, bh
      | false, false -> th, bh 
    in
    draw (x, y) (dw, dth) style top;
    draw (x, y + dth) (dw, dbh) style bottom
  in
  (size_fun, draw_fun, handler, (top, bottom))
;;

let vert_pair arg  = raw_vert_pair back_handler arg ;;

let raw_hor_pair handler (top, bottom) : ('a t * 'b t) t =
  let size_fun style (top, bottom) : t_size =
    let (tw, th), (ths, tvs) = size style top in 
    let (bw, bh), (bhs, bvs) = size style bottom in
    ((tw + bw), (max th bh)), (ths || bhs, tvs && bvs)
  in
  let draw_fun (x, y) (w, h) style (top, bottom) : unit =
    let (ww, wh), (hs, vs) = size_fun style (top, bottom) in
    let (tw, th), (ths, tvs) = size style top in 
    let (bw, bh), (bhs, bvs) = size style bottom in
    let dh = if vs then h else wh in
    let dtw, dbw = 
      match ths, bhs with
      |   true, true -> ((w - ww) / 2) + tw, ((w - ww) / 2) + bw
      | false, true -> tw, w - tw
      | true, false -> w - bw, bw
      | false, false -> tw, bw 
    in
    draw (x, y) (dtw, dh) style top;
    draw (x + dtw, y) (dbw, dh) style bottom
  in
  (size_fun, draw_fun, handler, (top, bottom))
;;

let hor_pair arg = raw_hor_pair back_handler arg;;

let pair_pass_handler event (w1, w2) =
  handle (handle event w1) w2
;;

let hor_pair arg = raw_hor_pair pair_pass_handler arg;;
let vert_pair arg = raw_vert_pair pair_pass_handler arg;;

let simple_frame widget : 'a t =
  let size_fun style widget =
    let (w, h), str = size style widget in
    let on, color, width = frame style in
    (w + (2 * width), h + (2 * width)), str
  in
  let draw_fun (x, y) (w, h) style widget =
    let (ww, wh), str = size style widget in
    let on, color, width = frame style in
    let p1, p2, p3, p4 = 
      (x, y), (x + w - 1(*+ width*), y), 
      (x + w - 1(*+ width*), y + h - 1(*+ width*)), (x, y + h - 1(* + width*)) 
      in 
    if on then begin
      Video.line p1 p2 color; Video.line p2 p3 color;
      Video.line p3 p4 color; Video.line p4 p1 color; end;
    draw (x + width, y + width) (w - (2*width), h - (2*width)) style widget
  in
  (size_fun, draw_fun, pass_handler, widget)
;;

let shade widget : 'a t =
  ((fun style widget -> size style widget),
  (fun (x, y) dims style widget ->
    (*if back style then tile_fill Color.shade (x, y) dims;*)
    begin match back style with
    | None -> ()
    | Some image -> tile_fill image (x, y) dims end;
    draw (x, y) dims style widget),
  (fun event widget -> handle event widget),
  widget)
;;

let styler (style, widget) : 'a t=
  ((fun _ (style, widget) -> size style widget),
  (fun (x, y) dims _ (style, widget) -> draw (x, y) dims style widget),
  (fun event (style, widget) -> handle event widget),
  (style, widget))
;;

let deco widget : 'a t =
  simple_frame (shade widget)
;;

let styled_deco (style, widget) : 'a t =
  styler (style, (deco widget))
;;

let draw_list ?on font (x, y) lst =
  let widget = deco (vert_list (List.map (fun txt -> static_text txt) lst)) in
  let style = ((true, (128,128,128), 1), Some Color.shade, font) in
  draw (x, y) (fst (size style widget)) style widget
;;

let handler (lst, widget) : 'a t = (
  (fun style (lst, widget) -> size style widget),
  (fun (x, y) dims style (lst, widget) -> draw (x, y) dims style widget),
  (fun event (lst, widget) ->
     List.fold_left (fun event (trig, act) -> if event = trig then (act (); Eno) else event)
       event lst ),
  (lst, widget))
;;
