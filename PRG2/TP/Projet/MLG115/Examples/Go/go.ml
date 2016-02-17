let stone_size_sqr = 138. *. 138.;;
let stone_size_sqr_2 = 138. *. 138. *. 2.;;
let stones = ref [];;

(*Parser.parse "set video_mode \"1024 768\"" ();;*)

(* stone is (x : float, y : float, player : int (0 or 1)) *)

let dist_sqr (x1, y1, _) (x2, y2, _) =
  let (dx, dy) = (x1 -. x2, y1 -. y2) in dx *. dx +. dy *. dy
;;

let may_put_stone stone = 
  let predicate estone = dist_sqr stone estone < stone_size_sqr in
  not (List.exists predicate !stones)
;;

let enemy (_, _, pl1) (_, _, pl2) = pl1 <> pl2;;

let put_stone stone = 
  stones := stone :: !stones;
  let is_captured stone =
    let folder no e_stone = 
      if dist_sqr stone e_stone < stone_size_sqr_2 
          && enemy stone e_stone then no + 1 else no
    in
    (List.fold_left folder 0 !stones) > 3
  in
  let (remove, new_stones) = List.partition is_captured !stones in
  stones := new_stones;
  remove
;;
