(* This file is part of MLGame (OCaml Game System).

   MLGame is free software; you can redistribute it and/or modify it under the
   terms of the GNU General Public License as published by the Free Software
   Foundation; either version 2 of the License, or (at your option) any later
   version.

   MLGame is distributed in the hope that it will be useful, but WITHOUT ANY
   WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
   FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
   details.

   You should have received a copy of the GNU General Public License along
   with MLGame; if not, write to the Free Software Foundation, Inc., 59 Temple
   Place, Suite 330, Boston, MA 02111-1307 USA *)

let strs = ref [];;
let size = ref 0;;

let stderr prefix str =
  output_string stderr ("[" ^ prefix ^ "]" ^ str ^ "\n");
  flush stderr
;;

let log prefix str =
  stderr prefix str;
  strs := (None, prefix, str) :: !strs;
  incr size;
  if !size > 1000 then (strs := []; size := 0; Gc.major ())
;;

let error = log "Error";;
let info = log "Info";;
let debug = log "Debug";;
let fatal s =
  log "Fatal" s;
  Pervasives.exit 1
;;

let remember_debug var str =
  if !var then stderr "Debug" str;
  strs := (Some var, "Debug", str) :: !strs
;;

let get () = 
  let folder acc = function
    | None, prefix, str -> (prefix, str) :: acc
    | Some var, prefix, str -> 
        if !var then (prefix, str) :: acc else acc
  in
  List.rev (List.fold_left folder [] !strs)
;;

let dump file =
  let out_chan = open_out file in
  let folder acc = function
    | None, prefix, str -> (prefix, str) :: acc
    | Some var, prefix, str -> 
        if !var then (prefix, str) :: acc else acc
  in
  let iter (prefix, str) =
    output_string out_chan ("[" ^ prefix ^ "]" ^ str ^ "\n");
  in 
  List.iter iter (List.rev (List.fold_left folder [] !strs));
  close_out out_chan
;;


