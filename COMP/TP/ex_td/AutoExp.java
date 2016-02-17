import java.io.*;

/**
 * automate de reconnaissance des expressions du TD
 * @author Masson, Grazon
 *
 */
public class AutoExp extends Automate{
	
	/** table des transitions */
	private final int[][] transit =
    {   /* Etat       NBENT PLUS PTVIRG ETOILE  / AUTRES  */
	 	/* 0 */      {  1,   6,    6,     6,   6,   6   },
	 	/* 1 */      {  6,   3,    2,     6,   6,   6   },
	 	/* 2 */      {  1,   6,    6,     6,   7,   6   },
	 	/* 3 */      {  4,   6,    6,     6,   6,   6   },
	 	/* 4 */      {  6,   3,    2,     5,   6,   6   },
	 	/* 5 */      {  1,   6,    6,     6,   6,   6   },
	 	/* 6 */      {  6,   6,    6,     6,   6,   6   }
    } ;
	
	/** gestion de l'affichage sur la fenetre de trace de l'execution */
	public void newObserver(ObserverAutomate oAuto, ObserverLexique oLex ){
		this.newObserver(oAuto);
		this.lex.newObserver(oLex);
		lex.notifyObservers(((LexExp)lex).getCarlu());
	}
 
	/** constructeur classe AutoExp */
	public AutoExp(InputStream flot) {
		/** on utilise ici un analyseur lexical de type LexExp */
		lex = new LexExp(flot);
		/** initialisation des attributs de la classe abstraite Automate */
		this.etatInitial = 0;
		this.etatFinal = transit.length;
		this.etatErreur = transit.length - 1;
	}

	/** definition de la methode abstraite getTransition de Automate */
	int getTransition(int etat, int unite) {
		int etatSuivant = this.transit[etat][unite];
		/** ici l'arrivee dans l'etat d'erreur provoquera l'arret de l'analyse */
		if (etatSuivant == etatErreur) errFatale = true;
		return this.transit[etat][unite];
	}

	/** ici la methode abstraite initAction de Automate n'est pas encore definie */
	void initAction() {};

	/** ici la mehtode abstraite faireAction de Automate n'est pas encore definie */
	void faireAction(int etat, int unite) {};

	/** ici la methode abstraite getAction de Automate n'est pas encore definie */
	int getAction(int etat, int unite) {
		return -1;
	};

}/** class AutoExp */
