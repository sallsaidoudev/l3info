(* Module responsible for racing-arena-from-file-creation
 * All sprite-creation and physical management in Graph module (as easily seen)
 * Here parsing only
 * *)

type dir = LEFT | RIGHT 
;;

let video_x = 640
and video_y = 480
;;

let clock_pos_x = ((-video_x)/2 + 7)
and clock_pos_y = ( (video_y)/2 - 16)
;;

let pl_clock_pos_x pl = ((-video_x)/2+7) + ((pl+1)*120)
and pl_clock_pos_y pl = ( (video_y)/2 - 16)
;;


let status_bar = Sdlvideo.rect ((-video_x)/2 + 5)  ((video_y)/2 - 19) 640 19;;
let arena_sprites = Sprite.Set.create 10;;
let put_block img pos w = ignore (Sprite.create ~set:arena_sprites () img ~width:w pos);;

let checkpoints = ref [];;

let add_checkpoint cd1 cd2 dir =
 checkpoints := (cd1, cd2, dir) :: !checkpoints
;;


(*********************************************************************************************************)
let get_pos no = (1, 30 + 43*no)
;;

let hor_image = Video.optimize (Video.color_key (Video.load_image "Data/hor_bar.png"));; 
let ver_image = Video.optimize (Video.color_key (Video.load_image "Data/ver_bar.png"));; 
let mid_image = Video.optimize (Video.color_key (Video.load_image "Data/mid_bar.png"));; 

let build_arena () =
 begin
  add_checkpoint (-  1,-5) (-  1, 240) LEFT; (* LAST CHECKPOINT*)
  add_checkpoint (-150,-5) (-320, 240) LEFT;
  add_checkpoint (-150,-5) (-320,-240) LEFT;
  add_checkpoint (  50,-5) (  50,-240) LEFT;
  add_checkpoint ( 150,-5) ( 320,-240) LEFT;
  add_checkpoint ( 150, 0) ( 320,   0) LEFT;
  add_checkpoint ( 150, 5) ( 320, 240) LEFT;
  add_checkpoint ( 100, 5) ( 200, 240) LEFT; 
  add_checkpoint (  50, 5) (  50, 240) LEFT; (* FIRST CHECKPOINT*)

 
  put_block hor_image  ((-video_x)/2, (-video_y)/2) 640; (*up*)
  put_block hor_image  ((-video_x)/2 + 5, (video_y)/2 - 24) 640; (*down*)
  put_block ver_image  ((-video_x)/2, (-video_y)/2) 5; (*left*)
  put_block ver_image  ((video_x)/2 - 5, (-video_y)/2 + 5) 5; (*right*)
  put_block mid_image  (-150, 0) 300; 
 end
;;
(*********************************************************************************************************)
  
let init () =
 begin
  checkpoints:= [];
  build_arena ();
  Sprite.Set.set_collision arena_sprites 32 32;
 end
;;

let draw onc =
  Video.fill ~on:onc (127, 127, 127);
  Video.fill ~on:onc ~rect:status_bar (0,0,0);
  Sprite.Set.iter (Sprite.draw ~on:onc) arena_sprites;
;;

