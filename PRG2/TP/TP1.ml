(* Fonctions sur les listes *)
let rec longueur l = match l with
	| [] -> 0
	| t::q -> 1 + (longueur q)
;;

let rec oter e l = match l with
	| [] -> []
	| t::q when t = e -> oter e q
	| t::q -> t::(oter e q)
;;

let rec nboccur e l = match l with
	| [] -> 0
	| t::q when t = e -> 1 + (nboccur e q)
	| _::q -> nboccur e q
;;

let rec remplacer x y l = match l with
	| [] -> []
	| t::q when t = x -> y::(remplacer x y q)
	| t::q -> t::(remplacer x y q)
;;

let rec nieme i l = match l with
	| [] -> failwith "index out of bounds"
	| t::q when i = 1 -> t
	| _::q -> nieme (i-1) q
;;

(* Fonctions ensemblistes*)
let rec contains x s = match s with
	| [] -> false
	| t::q when t = x -> true
	| _::q -> inset x q
;;

let rec append x s =
	if (contains x s) then s else x::s
;;

let rec union s u = match s with
	| [] -> u
	| t::q -> union q (append t u)
;;

let rec inter s u = match s with
	| [] -> []
	| t::q when contains t u -> t::(inter q u)
	| _::q -> inter q u
;;

let rec diff s u = match s with (* S\U *)
	| [] -> []
	| t::q when contains t u -> diff q u
	| t::q -> t::(diff q u)
;;

let rec isinclude s u = match s with
	| [] -> true
	| t::q when contains t u -> isinclude q u
	| _::q -> false
;;

let rec equals s u = match s with
	| [] -> u = []
	| t::q -> equals q (oter t u)
;;

(* Préfixes de listes *)
let rec prefixe l1 l2 = match (l1, l2) with
	| [], _ -> true
	| _, [] -> false
	| t1::q1, t2::q2 -> (t1 = t2) && (prefixe q1 q2)
;;

let rec plfg l1 l2 = match (l1, l2) with
	| t1::q1, t2::q2 when t1 = t2 -> t1::(plfg q1 q2)
	| _ -> []
;;
