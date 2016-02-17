
import java.io.*;

/**
 * quelques primitives de lecture au clavier ou dans un fichier 
 * @author Masson, Grazon
 *
 */

public class Lecture {

	/** délivre un pointeur sur le fichier de nom nomFich (null si erreur) 
	 * @param nomFich nom du fichier d'entree
	 * @return flot correspondant au fichier
	 */
	public static InputStream ouvrir(String nomFich) {
		InputStream f;
		try {
			f = new DataInputStream(new FileInputStream(nomFich));
		} catch (FileNotFoundException e) {
			System.out.println("Fichier " + nomFich + " introuvable");
			f = null;;
		}
		return f;
	}

	/**
	 * détermine si la fin de fichier est atteinte
	 * @param f fichier contenant le flot de donnee a analyser
	 * @return vrai si fin de fichier trouvee
	 */
	public static boolean finFichier(InputStream f) {
		// determine si la fin de fichier est atteinte
		try {
			return (f != System.in && f.available() == 0);
		} catch (IOException e) {
			System.out.println("pb test finFichier");
			System.exit(1);
		}
		return true;
	}

	/**
	 * ferme un fichier (affiche un message si probleme)
	 * @param f fichier contenant le flot de donnee a analyser
	 */
	public static void fermer(InputStream f) {
		// ferme un fichier (affiche un message si probleme)
		try {
			f.close();
		} catch (IOException e) {
			System.out.println("pb fermeture fichier");
		}
	}

	/**
	 *  lecture d'un octet dans la chaîne d'entrée (avec capture de l'exception)
	 * @param f fichier contenant le flot de donnee a analyser
	 * @return caractere courant lu
	 */
	public static char lireChar(InputStream f) {
		char carSuiv = ' ';
		try {
			int x = f.read();
			if (x == -1) {
				System.out.println("lecture après fin de fichier");
				System.exit(2);
			}
			carSuiv = (char) x;
		} catch (IOException e) {
			System.out.println(e.getMessage());
			System.out.println("Erreur fatale");
			System.exit(3);
		}
		return carSuiv;
	}

	/**
	 * lecture d'un octet dans la chaîne d'entrée au clavier
	 * @return caractere courant lu
	 */
	public static char lireChar() {
		return lireChar(System.in);
	}

	/** programme principal ne servant qu'au test des utilitaires*/
	public static void main(String args[]) {
		InputStream fichier;
		char carLu;
		fichier = ouvrir("test");
		while (!finFichier(fichier)) {
			carLu = lireChar(fichier);
			System.out.print(carLu);
		}
		fermer(fichier);

		/** lecture au clavier */
		carLu = lireChar();
	}
}// class Lecture
