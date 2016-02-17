import java.io.InputStream;
import java.util.ArrayList;
import java.awt.TextArea;

/**
 * Analyseur lexical pour des fiches de livraison de vin.
 * @author Boucherie, Noël-Baron, Sampaio
 */
public class LexVin extends Lex {

    // Codage des items lexicaux
    protected final int 
            BEAUJOLAIS = 0, BOURGOGNE = 1, IDENT = 2, NBENTIER = 3, 
            VIRGULE = 4, PTVIRG = 5, BARRE = 6, AUTRES = 7;
    public static final String[] images = {"BEAUJ", "BOURG", "IDENT", "NBENT",
            "  ,  ", "  ;  ", "  /  ", "AUTRE"};
    
    private final int NBRES = 2; // Nombre de mots réservés
    private int itab; // Indice de remplissage de Lex.tabid
    private int valNb, numId; // Attributs lexicaux
    private char carlu; // Caractère courant

    /**
     * Constructeur de l'analyseur lexical
     * @param flot le flot à analyser
     */
    public LexVin(InputStream flot) {
        super(flot);
        lireCarlu(); // Prélecture du premier caractère
        Lex.tabId[0] = "BEAUJOLAIS"; // Mots réservés
        Lex.tabId[1] = "BOURGOGNE";
        itab = 1;
    }

    public int getValNb() { return this.valNb; }
    public int getNumId() { return this.numId; }
    public char getCarlu() { return this.carlu; }

    /**
     * Lecture du caractère courant
     */
    private void lireCarlu() {
        carlu = Lecture.lireChar(flot);
        this.notifyObservers(carlu);
        if ((carlu == '\r') || (carlu == '\n') || (carlu == '\t'))
            carlu = ' ';
        if (Character.isWhitespace(carlu))
            carlu = ' ';
        else
            carlu = Character.toUpperCase(carlu);
    }

    @Override
    public String repId(int nId) { return tabId[nId]; }

    @Override
    public int lireSymb() {
        while (carlu == ' ')
            lireCarlu();
        // BEAUJOLAIS | BOURGOGNE | IDENT
        if (('a' <= carlu && carlu <= 'z') || ('A' <= carlu && carlu <= 'Z')) {
            // Lecture d'un ident
            String s = "";
            do {
                s += carlu;
                lireCarlu();
            } while (('a' <= carlu && carlu <= 'z')
                    || ('A' <= carlu && carlu <= 'Z'));
            s = s.toUpperCase();
            // Détection des mots-clés
            if (s.equals("BEAUJOLAIS"))
                return BEAUJOLAIS;
            if (s.equals("BOURGOGNE"))
                return BOURGOGNE;
            // Recherche ou ajout de l'ident lu
            int i;
            for (i=0; i<=itab; i++)
                if (s.equals(tabId[i]))
                    break;
            if (i>itab) {
                itab++;
                tabId[i] = s;
            }
            numId = i;
            return IDENT;
        }
        // NBENTIER
        if ('0' <= carlu && carlu <= '9') {
            String s = "";
            do {
                s = s + carlu;
                lireCarlu();
            } while ((carlu >= '0') && (carlu <= '9'));
            valNb = Integer.parseInt(s);
            return NBENTIER;
        }
        // Le reste
        switch (carlu) {
        case ',':
            lireCarlu();
            return VIRGULE;
        case ';':
            lireCarlu();
            return PTVIRG;
        case '/':
            return BARRE;
        default:
            System.out.println("Caractère non reconnu : " + carlu);
            lireCarlu();
            return AUTRES;
        }
    }

}
