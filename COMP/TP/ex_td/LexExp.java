import java.awt.TextArea;
import java.io.InputStream;
import java.util.ArrayList;

/** Analyseur lexical pour les expressions du TD 
 * @author Masson, Grazon
 *
 */
public class LexExp extends Lex {
	
	/** codage des items */
	protected final int 
			NBENTIER = 0,
			PLUS = 1, PTVIRG = 2, ETOILE = 3, BARRE = 4, AUTRES = 5;
	/** pour affichage dans fenetre de trace d'execution */
	public static String[] images={"NBENTIER","PLUS","PTVIRG","ETOILE","BARRE","AUTRES"};

	/** attribut lexical pour item NBENTIER */
	private int valNb; 

	/** caractère courant */
	private char carlu; 
	
	public char getCarlu(){
		return this.carlu;
	}

	/** constructeur de classe LexExp */
	public LexExp(InputStream flot) {
		/** initialisation du flot par la classe abstraite */
		super(flot);
		/** prelecture du premier caractere de la donnee */
		lireCarlu();
	}

	/** lecture caractere suivant de la donnee */
	private void lireCarlu() {
		carlu = Lecture.lireChar(flot);
		this.notifyObservers(carlu);
		/** transformation des retours a la ligne et tabulations en espaces */
		if ((carlu == '\r') || (carlu == '\n') || (carlu == '\t'))
			carlu = ' ';
	} /** lireCarlu */

	/** determination de l'item lexical
	 * definition de la methode abstraite lireSymb de Lex  
	 * @return code entier de l'item lexical reconnu
	 * */
	public int lireSymb() {
		
		/** espaces (ou assimiles) sont "avales" */
		while (carlu == ' ')
			lireCarlu();
		/** detection item lexical NBENTIER */
		if ((carlu >= '0') && (carlu <= '9')) {
			String s = "";
			do {
				s = s + carlu;
				lireCarlu();
			} while ((carlu >= '0') && (carlu <= '9'));
			valNb = Integer.parseInt(s);
			return NBENTIER;
		}
		/** detection autres items lexicaux */
		switch (carlu) {
		case '+':
			lireCarlu();
			return PLUS;
		case ';':
			lireCarlu();
			return PTVIRG;
		case '*':
			lireCarlu();
			return ETOILE;
		case '/':
			return BARRE;
		default: {
			System.out.println("LexExp : caractère incorrect : " + carlu);
			lireCarlu();
			return AUTRES;
		}
		}
	} /** liresymb */

	/** methodes d'acces aux attributs lexicaux */
	public int getValNb() {
		return this.valNb;
	}

	/** definition de la methode abstraite repId de Lex */
	public String repId(int nId) {
		return "";
	} /** methode repId inutile dans le cadre des exp */

	
	/** main de test de la classe LexExp */
	public static void main(String args[]) {
		InputStream fichier;
		char carLu;
		fichier = Lecture.ouvrir("test");
		while (!Lecture.finFichier(fichier)) {
			carLu = Lecture.lireChar(fichier);
			System.out.print(carLu);
		}
		Lecture.fermer(fichier);

		/** lecture au clavier */
		carLu = Lecture.lireChar();
	}
	
	
} // class LexExp
