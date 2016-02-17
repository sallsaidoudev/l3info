(* Type arbre *)
type ('a, 'b) arbre_bin = Feuille of 'b | Noeud of ('a, 'b) noeud
and ('a, 'b) noeud = {gauche: ('a, 'b) arbre_bin; op: 'a; droite: ('a, 'b) arbre_bin};;

(* Fonctions génériques *)
let rec nb_noeuds a = match a with
	| Feuille _ -> 0
	| Noeud n -> 1 + (nb_noeuds n.gauche) + (nb_noeuds n.droite)
;;
let rec profondeur a = match a with
	| Feuille _ -> 0
	| Noeud n -> max (profondeur n.gauche) (profondeur n.droite)
;;
let rec miroir a = match a with
	| Feuille _ -> a
	| Noeud n -> Noeud {n with gauche = miroir n.droite; droite = miroir n.gauche}
;;
let rec ops_et_feuilles a = match a with
	| Feuille f -> [], [f]
	| Noeud n -> let op1, fe1 = ops_et_feuilles n.gauche
		and op2, fe2 = ops_et_feuilles n.droite
		in n.op :: (op1 @ op2), fe1 @ fe2
;;

(* Expressions arithmétiques *)
type op = Add | Sous | Mul | Div and expr = (op, int) arbre_bin;;
let e1 = Noeud({gauche=Feuille(3); op=Mul; droite=Noeud({gauche=Feuille(1); op=Add; droite=Feuille(4)})});;
let rec eval e = match e with
	| Feuille n -> n
	| Noeud o -> let r1 = eval o.gauche and r2 = eval o.droite in
		match o.op with
		| Add -> r1 + r2
		| Sous ->  r1 - r2
		| Mul -> r1 * r2
		| Div -> r1 / r2
;;

(* Avec variables *)
type op = Add | Sous | Mul | Div and var = I of int | V of char
and expr = (op, var) arbre_bin;;
let e2 = Noeud({
	gauche = Feuille(V('x'));
	op = Mul;
	droite = Noeud({
		gauche = Feuille(V('y'));
		op = Sous;
		droite = Noeud({gauche=Feuille(I(5)); op=Div; droite=Feuille(I(4))})
	})
});;
let rec simpl e = match e with
	| Feuille _ -> e
	| Noeud o -> let r1 = simpl o.gauche and r2 = simpl o.droite in match r1, r2 with
		| Feuille (I a), Feuille (I b) -> Feuille(I(eval {o with gauche=r1; droite=r2}))
		| Add -> r1 + r2
		| Sous ->  r1 - r2
		| Mul -> r1 * r2
		| Div -> r1 / r2
;;