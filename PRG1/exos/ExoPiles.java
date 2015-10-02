import java.lang.*;

public class ExoPiles {
	
	public static void main(String[] args) {
		// Création de la pile
		Pile pile = new Pile();
		pile.empiler(7);
		pile.empiler(5);
		pile.empiler(4);
		pile.empiler(6);
		pile.empiler(5);
		pile.empiler(2);
		pile.empiler(3);
		System.out.print("Pile enregistrée : ");
		Pile.Parcours aff = pile.new Parcours();
		while (!aff.fin()) {
			System.out.print(aff.courant() + " ");
			aff.suivant();
		} System.out.print("\n");
		// Recherche du premier doublon
		Pile.Parcours p1 = pile.new Parcours();
		while (!p1.fin()) {
			Pile.Parcours p2 = pile.new Parcours(p1);
			while (!p2.fin()) {
				p2.suivant();
				if (!p2.fin() && p2.courant() == p1.courant()) {
					System.out.println("Le premier double est " + p2.courant());
					break;
				}
			}
			p1.suivant();
		}
	}

}
