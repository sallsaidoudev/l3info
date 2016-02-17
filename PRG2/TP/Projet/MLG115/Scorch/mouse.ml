
let center () = Video.set_cam_pos (0, 0);;

let frame () =
  let frame_internal () =
    let (ww, wh) = (!Options.width, !Options.height) in
    let (sw, sh) = Video.get_resolution () in
    let map_x x = (x * ((ww + sw) / sw)) - sw in
    let map_y y = (y * ((wh + sh) / sh)) - sh in
    (*let map_y y = (y * (wh / sh)) - sh in*)
    Sdlmouse.show_cursor false;
    match Sdlmouse.get_state () with (x, y, buttons) ->
      Video.set_cam_pos (map_x x, map_y y)
  in
  if !Options.mouse_on then frame_internal ()
;;

