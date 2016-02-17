import java.io.InputStream;

/**
 * Actions associées à l'analyse des fiches de livraison de vin.
 * @author Boucherie, Noël-Baron, Sampaio
 */
public class ActVin extends AutoVin {

    // Table des actions
    private final int[][] action =
    {   /* état        BJ    BG   IDENT  NBENT   ,     ;     /  AUTRES  */
        /* 0 */      { -1,   -1,    0,    -1,   -1,   -1,    8,   -1   },
        /* 1 */      {  2,    3,    4,     1,   -1,   -1,   -1,   -1   },
        /* 2 */      {  2,    3,    4,    -1,   -1,   -1,   -1,   -1   },
        /* 3 */      { -1,   -1,    4,    -1,   -1,   -1,   -1,   -1   },
        /* 4 */      { -1,   -1,   -1,     5,   -1,   -1,   -1,   -1   },
        /* 5 */      { -1,   -1,    4,    -1,    6,    7,   -1,   -1   },
        /* 6 */      { -1,   -1,   -1,    -1,   -1,   -1,   -1,   -1   },
    };

    private static final int FATALE = 0, NONFATALE = 1; // Types d'erreur
    private static final int MAXLGID = 20; // Largeur d'une colonne d'affichage
    private static final int MAXCHAUF = 10; // Nombre max de chauffeurs
    private Chauffeur[] tabChauf = new Chauffeur[MAXCHAUF];
    
    // Variables manipulées par les actions
    private int ichauf;
    private int curchauf;
    private int volcit;
    private int curvol;
    private int[] volliv = new int[3];
    private int qualite;
    private SmallSet magdif = new SmallSet();

    /**
     * Constructeur du gestionnaire d'actions
     * @param flot le flot à analyser
     */
    public ActVin(InputStream flot) { super(flot); }

    /**
     * Formatage (justifié à gauche) d'une chaîne de caractères
     * @param ch est une chaîne de longueur quelconque
     * @return la chaîne cadrée à gauche sur MAXLGID caractères
     */
    private String chaineCadrageGauche(String ch) {
        int lgch = Math.min(MAXLGID, ch.length());
        String chres = ch.substring(0, lgch);
        for (int k = lgch; k < MAXLGID; k++)
            chres = chres + " ";
        return chres;
    } 

    /**
     * Affichage de tout le tableau des chauffeurs à l'écran
     */
    private void afficherChauf() {
        String idchaufcour, ch;
        Ecriture.ecrireStringln("");
        ch = "CHAUFFEUR                   BJ        BG       ORD     NBMAG\n"
           + "---------                   --        --       ---     -----";
        Ecriture.ecrireStringln(ch);
        for (int i = 0; i <= ichauf; i++) {
            idchaufcour = ((LexVin)lex).repId(tabChauf[i].numchauf);
            Ecriture.ecrireString(chaineCadrageGauche(idchaufcour));
            Ecriture.ecrireInt(tabChauf[i].bj, 10);
            Ecriture.ecrireInt(tabChauf[i].bg, 10);
            Ecriture.ecrireInt(tabChauf[i].ordin, 10);
            Ecriture.ecrireInt(tabChauf[i].magdif.size(), 10);
            Ecriture.ecrireStringln("");
        }
    }
    
    /**
     * Gestion des erreurs 
     * @param te type de l'erreur
     * @param messErr message associé à l'erreur
     */
    private void erreur(int te, String messErr) {
        Lecture.attenteSurLecture(messErr);
        switch (te) {
        case FATALE:
            errFatale = true;
            break;
        case NONFATALE:
            etatCourant = etatErreur;
            break;
        default:
            Lecture.attenteSurLecture("Paramètre d'erreur incorrect");
        }
    }

    /**
     * Initialisation des variables manipulées par les actions
     */
    private void initialisations() {
        ichauf = -1;
        curchauf = -1;
        volcit = 100;
        curvol = 0;
        qualite = 0;
    } 

    private int valNb() { return ((LexVin) lex).getValNb(); }
    private int numId() { return ((LexVin) lex).getNumId(); }
    /**
     * Exécution d'une action
     * @param numact numéro de l'action à éxécuter
     */
    public void executer(int numact) {
        switch (numact) {
        case -1: // action vide
            break;
        case 0:
            curchauf = numId();
            volcit = 100;
            curvol = 0;
            for (int i=0; i<3; i++) volliv[i] = 0;
            qualite = 0;
            magdif = new SmallSet();
            break;
        case 1:
            volcit = valNb();
            if (100 > volcit || volcit > 200)
                volcit = 100;
            break;
        case 2:
            qualite = 1;
            break;
        case 3:
            qualite = 2;
            break;
        case 4:
            magdif.add(numId());
            break;
        case 5:
            curvol += valNb();
            if (valNb() == 0)
                erreur(NONFATALE, "Volume livré nul");
            else if (curvol > volcit)
                erreur(NONFATALE, "Volume livré supérieur à la capacité");
            else
                volliv[qualite] += valNb();
            break;
        case 6:
            curvol = 0;
            qualite = 0;
            break;
        case 7:
            int i;
            for (i=0; i<=ichauf; i++)
                if (tabChauf[i].numchauf == curchauf) {
                    tabChauf[i].bj += volliv[1];
                    tabChauf[i].bg += volliv[2];
                    tabChauf[i].ordin += volliv[0];
                    tabChauf[i].magdif.union(magdif);
                    break;
                }
            if (i > ichauf) { // nouveau chauffeur
                ichauf++;
                if (ichauf >= MAXCHAUF) {
                    erreur(FATALE, "Trop de chauffeurs, licenciez !");
                    System.err.println("\n\n\nFin d'analyse (erreur fatale)");
                    System.exit(1);
                }
                tabChauf[i] = new Chauffeur(curchauf, volliv[1], volliv[2],
                        volliv[0], magdif);
            }
            afficherChauf();
            break;
        case 8:
            Chauffeur maxchauf = tabChauf[0];
            for (i=1; i<=ichauf; i++)
                if (tabChauf[i].magdif.size() > maxchauf.magdif.size())
                    maxchauf = tabChauf[i];
            if (maxchauf != null)
                Ecriture.ecrireStringln("Le chauffeur ayant livré le plus de "
                    + "magasins est " + ((LexVin)lex).repId(maxchauf.numchauf));
            break;
        default:
            Lecture.attenteSurLecture("Action " + numact + " non prévue");
        }
    }
     
    @Override
    public void initAction() { initialisations(); }

    @Override
    public int getAction(int etat, int unite) { return action[etat][unite]; }
    
    @Override
    public void faireAction(int etat, int unite) {
        executer(action[etat][unite]);
    }

}
