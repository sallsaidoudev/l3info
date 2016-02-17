import java.io.*;

/**
 * Automate de reconnaissance des fiches de livraison de vin.
 * @author Boucherie, Noël-Baron, Sampaio
 */
public class AutoVin extends Automate {

    // Table des transitions
    private final int[][] transit =
    {   /* Etat        BJ   BG   IDENT  NBENT  ,    ;    /  AUTRES  */
        /* 0 */      {  6,   6,    1,     6,   6,   6,   7,    6   },
        /* 1 */      {  3,   3,    4,     2,   6,   6,   6,    6   },
        /* 2 */      {  3,   3,    4,     6,   6,   6,   6,    6   },
        /* 3 */      {  6,   6,    4,     6,   6,   6,   6,    6   },
        /* 4 */      {  6,   6,    6,     5,   6,   6,   6,    6   },
        /* 5 */      {  6,   6,    4,     6,   2,   0,   6,    6   },
        /* 6 */      {  6,   6,    6,     6,   0,   0,   0,    6   },
    };

    /**
     * Constructeur de l'automate
     * @param f flot d'entrée à analyser
     */
    public AutoVin(InputStream f) {
        lex = new LexVin(f);
        this.etatInitial = 0;
        this.etatFinal = transit.length;
        this.etatErreur = transit.length - 1;
    }

    /**
     * Suivi des modifications pour l'affichage
     */
    public void newObserver(ObserverAutomate oAuto, ObserverLexique oLex) {
        this.newObserver(oAuto);
        this.lex.newObserver(oLex);
        lex.notifyObservers(((LexVin) lex).getCarlu());
    }

    @Override
    int getTransition(int etat, int unite) { return this.transit[etat][unite]; }

    @Override
    void faireAction(int etat, int unite) {}

    @Override
    void initAction() {}

    @Override
    int getAction(int etat, int unite) { return 0; }

}
