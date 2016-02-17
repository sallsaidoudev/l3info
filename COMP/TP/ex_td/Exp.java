import java.awt.*;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;

import javax.swing.JFrame;

/**
 * programme principal de l'analyse d'une expression par automate a nombre fini d'etats 
 * @author Masson, Grazon
 *
*/

public class Exp {

	public static void main(String args[]) {
		/** fenetre de trace d'execution */
		FenAffichage fenetre = new FenAffichage();

		ActExp analyseur;
		InputStream flot = null;

		if (args.length == 0) {
			System.out.println("Donnee a analyser lue sur entree standard ");
			flot = System.in;
		} else if (args.length == 1) {
			System.out.println("Donnee a analyser lue dans fichier " + args[0]);
			flot = Lecture.ouvrir(args[0]);

		}

		analyseur = new ActExp(flot);
		analyseur.newObserver(fenetre, fenetre);
		analyseur.interpreteur();
		System.out.println("Fin d'analyse");

		if (args.length == 1)
			Lecture.fermer(flot);

	}

} /** class Exp */

