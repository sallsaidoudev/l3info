import java.io.InputStream;

/** 
 * gestion des actions associees a la reconnaissance des expressions
 * @author Masson, Grazon
 */
public class ActExp extends AutoExp {

	/** table des actions */
    private final int[][] action =
    {   /* Etat       NBENT PLUS PTVIRG ETOILE  / AUTRES  */
	 	/* 0 */      {  1,   8,    8,     8,   8,   8   },
	 	/* 1 */      {  8,  -1,    2,     8,   8,   8   },
	 	/* 2 */      {  1,   8,    8,     8,   3,   8   },
	 	/* 3 */      {  4,   8,    8,     8,   8,   8   },
	 	/* 4 */      {  8,   5,    7,    -1,   8,   8   },
	 	/* 5 */      {  6,   8,    8,     8,   8,   8   },
	 	/* 8 */      { -1,  -1,   -1,    -1,  -1,  -1   }
    } ;      

    /** constructeur classe ActExp */
    public ActExp(InputStream flot){
    	super(flot);
    }
    
    /** variables necessaires aux traitements effectues dans les actions */
    private int max,vExp, op;
    
    /** procedure de traitement de la fin d'une expression (cf actions) */
    private void finExp(int valeur) {
    	System.out.println("La valeur de l'expression courante est "+valeur);
    	if (valeur > max) max = valeur;
    }
    
    /** Rappel: lex defini dans la classe abstraite Automate */
    private int valNb() {
     	/** cast pour préciser que lex est ici de type LexExp */
    	return ((LexExp)lex).getValNb();
    }
 
    /** procedure d'execution d'une action
     * @param numact numero de l'action a executer
     */
    public void executer(int numact) {
    	switch (numact) {
    		case -1 : break ;
    		case 1  : vExp = valNb() ; break;
    		case 2  : finExp(vExp) ; break ;
    		case 3  : System.out.println("Le max est "+ max) ; break ;
    		case 4  : op = valNb() ; break ;
    		case 5  : vExp =vExp + op ; break ;
    		case 6  : vExp =vExp + op * valNb() ; break ;
    		case 7  : finExp(vExp + op) ; break ;
    		case 8 	: System.out.println("erreur de syntaxe"); break;
    		default : System.out.println("action " + numact + " non prévue") ;
    	}
    }
    
    /** definition methode abstraite initAction de Automate */
    public void initAction() {
   	/**  = action 0 a effectuer a l'init */
    	System.out.println("initialisation du max a la valeur -1");
    	max = -1;
    };
    
    /** definition methode abstraite faireAction de Automate */
    public void faireAction(int etat, int unite) {
    	 executer(action[etat][unite]);
     };
     
     /** definition methode abstraite getAction de Automate */
     public int getAction(int etat, int unite) {
    	 return action[etat][unite];
     };
     
    /** methode abstraite getTransition de Automate definie dans AutoExp */    

} /** class ActExp */
