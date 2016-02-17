type ('a, 'b) t = {
  arr:'a array;
  dat:'b
};;
 
let level_width = 16;;
let level_height = 31;;

let pos2array (x, y) = y * level_width + x;;
let array2pos i = (i mod level_width, i / level_width);;
let array_size = 1 + pos2array (level_width - 1, level_height - 1);;

(* ZMIANA I DOSTEP DO ZAWARTO¦CI ***************************)
let get_data {dat=d} = d;;
let put {arr=level} pos elem = 
  let i = pos2array pos in
    Array.set level i elem
;;
let get {arr=level} pos = 
  let i = pos2array pos in
    Array.get level i
;;

(* TWORZENEI NOWEJ PLANSZY **********************************)
let create_simple elem data = 
  let arr = Array.make array_size elem in
  {arr=arr; dat=data}
;;
let create map data = 
  let f pos = map (array2pos pos) in
  let arr = Array.init array_size f in
  {arr=arr; dat=data}
;;
let load char2elem unknown data stream =
  let tab =
    let arr = Array.make level_height "" in
      try 
        for num = 0 to level_height - 1 do
          Array.set arr num (input_line stream);
        done;
        arr
      with End_of_file -> arr 
  in
  let get_char (x, y) = 
    let str = Array.get tab y in
    String.get str x
  in    
  let my_map pos = 
    try
      let char = get_char pos in
      char2elem char pos
    with Invalid_argument _ -> unknown pos
  in
  create my_map data
;;
let print stream conv {arr=level} =
  let maper i elem =
    output_string stream (conv elem);
    if (i mod level_width) = level_width - 1 then output_string stream "\n";
  in
  Array.iteri maper level
;;

(* SELEKTORY **************************************)
let neighbours7 (x, y) = 
  let s (x2, y2) = (x + x2, y + y2) in
  [s(-1,-1); s(0,-1); s(1,-1); s(-1,0); s(1,0); s(-1,1); s(0,1); s(1,1)]
;;
let neighbours4 (x, y) = 
  let s (x2, y2) = (x + x2, y + y2) in
  [s(0,-1); s(1,0); s(0,1); s(-1,0)]
;;
let get_all {arr=image} = Array.to_list image;;
let get_elems p image = 
  let all = get_all image in
  List.find_all p all
;;
let count p {arr=arr} =
  let rec my_count i acc =
    if i >= array_size then acc else
      let elem = Array.get arr i in
      if p elem then my_count (i+1) (acc+1) else my_count (i+1) acc
  in
  my_count 0 0
;;
let find_first p image = 
  let all = get_all image in
  List.find p all
;;
let first_from p pos {arr=image} = 
  let succ i = (i + 1) mod array_size in
  let i = pos2array pos in
  let start = succ i in
  let rec find i = 
    let elem = Array.get image i in
    if p elem then elem else find (succ i)
  in
  find start
;;

(* ITERATORY *****************************************)
let iteri p image = 
  let my_p i elem = 
    let pos = array2pos i in
    p pos elem
  in
  Array.iteri my_p image.arr
;;
let iter p image = Array.iter p image.arr;;