let player = ref 0;;

let event_fun = function
  | Sdlevent.MOUSEMOTION {Sdlevent.mme_x = x; Sdlevent.mme_y = y;} -> 
      let may_put = 
        Go.may_put_stone (float_of_int x, float_of_int y, !player) 
      in
      Board.mouse_move x y !player may_put
  | Sdlevent.MOUSEBUTTONDOWN {Sdlevent.mbe_x = x; Sdlevent.mbe_y = y;} ->
      if Go.may_put_stone (float_of_int x, float_of_int y, !player) then begin
        let remove = Go.put_stone (float_of_int x, float_of_int y, !player) in
        let mapper (x, y, _) = int_of_float x, int_of_float y in
        let remove_int = List.map mapper remove in
        Board.put_stone x y !player remove_int;
        player := 1 - !player
      end
  | _ -> ()
in
Input.set_mode (Input.add_mode "go" event_fun);;

Helpers.main (fun _ -> ()) Board.draw;;
