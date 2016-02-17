(* Module responsible for graphics. Drawing Race Arena and Cars*)

(**********                         GENERAL                          **********)
let context = ref [];;

let video_change_fun () = 
  context := [(Video.create_context 0 0 640 480 (0, 0))]
;;

let get_cur_x = ref (fun _ -> 2 ) 
and get_cur_y = ref (fun _ -> 2 )
;;



(**********                          ARENA                           **********)

  
(**********                          CARS                            **********)
let cars = Hashtbl.create 10;;
let cars_set = Sprite.Set.create 10;;

(* <World_state> *)
let players_send =
  
  let players_ser = 
    Serialize.list (
        Serialize.pair 
          Serialize.int                                        (*car number*)
         (Serialize.pair                                       (*pair*)
           
             (Serialize.pair                          (*posi*)
                Serialize.int
                Serialize.int) 
                
             (Serialize.pair                          (*data*)
                
                 (Serialize.pair             (*car engine velocity vector i both axis*)
                     Serialize.float
                     Serialize.float) 
               
                 (Serialize.pair             (*3nex*) 
                   (Serialize.pair  (*side velocity*)
                      Serialize.float
                      Serialize.float) 
                   (Serialize.pair  (*2nex*)
                    
                      (Serialize.pair 
                         Serialize.float  (*prev angle*)
                         Serialize.float) (*unused1*)
                      (Serialize.pair (*1nex*)
                         Serialize.int (*pl_no*)
                         Serialize.int) (*unused2*)
                   ))))
               ) 
  (*
   * players_ser  .........   (int, pair) list
   *        pair  .........   (posi, data)
   *        posi  .........   (int, int)          position of a car
   *        data  .........   (velo, 3nex)       
   *        velo  .........   (float, float)      velocity 
   *        3nex  .........   (acce, 2nex)    
   *        acce  .........   (float, float)      side velocity 
   *        2nex  .........   (prev, 1nex) 
   *        prev  .........   (float, float)      previous angle, unused1 
   *        1nex  .........   (int, int)          player number, unused2
   * hence:
   *  (int, ((float,float),((float,float),((float,float),(int,int)))))
   * *) 
  and players_recv lst_int_pair =
  
   let iterator (car_no, pair_posi_data) =
      let c = Hashtbl.find cars car_no in
      let (pos, data) = pair_posi_data in
       begin
         Sprite.move_to c pos;
         Sprite.set_data c data;
       end
       in
    List.iter iterator lst_int_pair
  in
   
  let players_info = Net.add_server_to_client players_ser players_recv in
  let players_send_aux pl_no =
    let folder car_no car lst = 
      let mapper c = (Sprite.get_pos c, Sprite.get_data c) in
      let sprite = Hashtbl.find cars car_no in
      (car_no, mapper sprite) :: lst in
    players_info [pl_no] (Hashtbl.fold folder cars [])
  in players_send_aux
;;
(* </World_state> *)

  
let create_car_sprite pl_n =
 let car_img =
   Video.optimize (Video.color_key (Video.load_image Car._image)) in
  let create_aux spr_set =
    Sprite.create ~set:spr_set (Car.initial_data pl_n) car_img ~width:Car._width (0, 0)
   in create_aux
;;


let move_player pl_no car =
 let new_vel = Car.move_car car (!get_cur_x pl_no, !get_cur_y pl_no) in 
    ignore (Sprite.move_in_bounds car new_vel);
    Sprite.check_collisions car 
;;

let new_frame_fun _ =
  Statusbar.time_flow (Sdltimer.get_ticks ());
  Hashtbl.iter move_player cars;
  let iterator pl_no = (fun spr -> Sprite.set_animation_frame spr (Car.get_dir spr))
  in
  Hashtbl.iter iterator cars;
;; 

  

  

let player_change_fun pl_no local = function
  | true ->
        Log.debug (Printf.sprintf "New_pl : %i, %b" pl_no local);
        players_send pl_no;
        let start_point = Arena.get_pos pl_no in
        let car = create_car_sprite pl_no cars_set in
        Sprite.move car start_point;
        Hashtbl.add cars pl_no car;
        if local && pl_no=0 then video_change_fun ()
  | false ->
      Log.debug (Printf.sprintf "b:%b" local);
      Hashtbl.remove cars pl_no;
      if local then video_change_fun ()
;;

let cars_set_init () =
  Sprite.Set.set_collision cars_set 24 24;
  Sprite.Set.set_boundary cars_set (-(Arena.video_x/2)) (-(Arena.video_y/2)) (Arena.video_x/2) (Arena.video_y/2);  (*mix miny maxx maxy*)
  Sprite.add_collision_fun cars_set cars_set true Car.collision_fun;
  Sprite.add_collision_fun cars_set Arena.arena_sprites true Car.wall_collision;
  let iterator pl_no = (fun spr -> Sprite.set_data spr (Car.initial_data pl_no); 
                                   Sprite.move_to spr (Arena.get_pos pl_no))
  in
  Hashtbl.iter iterator cars;

;;

(* Draw the scene at the moment*)
let draw_fun () =
 let draw_on on car_no =
  let sprite = Hashtbl.find cars car_no in
    Video.set_cam_pos_center ~on (0,0);
    Arena.draw on;
    Statusbar.draw on;
    let draw_player _ spr_car = Sprite.draw ~on spr_car
    in
    Hashtbl.iter draw_player cars
  in
  List.iter (draw_on (List.hd !context)) (Net.get_local_players ());
;;


let init () =
 begin
  Arena.init ();
  cars_set_init ();
 end
;;


