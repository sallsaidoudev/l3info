import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.awt.*;
import javax.swing.JFrame;

/**
 * La classe Vin génère un analyseur syntaxique avec actions de traitement
 * pour des fiches de livraison de vin.
 * @author Boucherie, Noël-Baron, Sampaio
 */
public class Vin {

    /**
     * Initialisation de l'entrée
     * @return flot à analyser
     */
    public static InputStream debutAnalyse() {
        String nomfich = Lecture.lireString("Fichier d'entrée : ");
        InputStream f = Lecture.ouvrir(nomfich);
        if (f == null)
            System.exit(0);
        return f;
    }

    /**
     * Fermeture de l'entrée
     * @param f flot de l'entrée
     */
    public static void finAnalyse(InputStream f) {
        Lecture.fermer(f);
        System.out.println("\n\n\nFin d'analyse");
        System.exit(0);
    }

    /**
     * Point d'entrée du programme. Il prend un argument optionnel qui
     * peut être le nom d'un fichier d'entrée ou "-" pour lire sur l'entrée
     * standard.
     */
    public static void main(String[] args) {
        FenAffichage fenetre = new FenAffichage();
        InputStream flot;
        if (args.length == 1) {
            if (args[0].equals("-")) {
                System.out.println("Donnée lue sur l'entrée standard ");
                flot = System.in;
            } else {
                System.out.println("Donnée à analyser lue dans " + args[0]);
                flot = Lecture.ouvrir(args[0]);
            }
        } else {
            flot = debutAnalyse();
        }
        ActVin analyseur = new ActVin(flot);
        analyseur.newObserver(fenetre, fenetre);
        analyseur.interpreteur();
        finAnalyse(flot);
    }

}
