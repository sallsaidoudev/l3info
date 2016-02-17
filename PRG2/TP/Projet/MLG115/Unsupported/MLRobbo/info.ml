(* Odst�py czasu dla kolejnych klatek, kt�re s� statyczne - wi�c poco? *)
let delay = ref 100;;(*Variable.add "info_delay" Variable.int 100;;*)

let input_mode = Input.add_mode "info" (fun _ -> ());;
(* [break_now num] daje true je�li wywo�ano akcj� break *)
let break_now = Helpers.add_action ~mode:input_mode false "break";;

let load_image file_name = Video.load_image ("graph/"^file_name);;

let wait image () =
  let rec reset () = 
    Sdltimer.delay 5;
    ignore (Input.process_events ());
    if break_now 1 then reset () else ()
  in
  
  let last_action = ref 0 in
  let rec loop () =
    let events = Input.process_events () in
    let new_action = Sdltimer.get_ticks () > !last_action + !delay in
    if new_action || events then begin
      last_action := Sdltimer.get_ticks ();
      Video.blit image 0 0;
      Console.draw ();
      Video.flip ();
      Gc.major ();
    end else
      Sdltimer.delay 20;
    if break_now 1 then () else loop ()
  in
  Input.set_mode input_mode;
  loop ();
  reset ();
;;

let wait2 file_name () = 
  let image = load_image file_name in
  wait image ()
;;