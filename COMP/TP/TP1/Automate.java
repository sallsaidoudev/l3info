import java.io.*;
import java.util.ArrayList;
import java.util.Scanner;

/**
 * La classe Automate modelise un automate abstrait d'analyse syntaxique
 * @author Masson, Grazon
 *
*/
public abstract class Automate {
	/** analyseur lexical */
	protected Lex lex;	
	/** Etats specifiques de l'automate */
	protected int etatInitial;
	protected int etatFinal;
	protected int etatErreur;
	protected int etatCourant;

	/**
	 * errFatale permet d'arreter l'interpreteur avant la fin de la donnee
	 * geree par la methode getTransition si passage dans etatErreur provoque l'arret 
	 * geree par la methode faireAction si certaines actions provoquent l'arret
	 */
	protected boolean errFatale;	

	/** gestion de l'affichage sur la fenetre de trace de l'execution */
	private ArrayList<ObserverAutomate> lesObserveurs=new ArrayList<ObserverAutomate>();
	public void newObserver(ObserverAutomate obs){
		this.lesObserveurs.add(obs);
	}	
	public void notifyObservers(int etatDepart, int unite, int etatArrive, int action){
		for(ObserverAutomate o : this.lesObserveurs){
			o.notification(etatDepart, unite, etatArrive, action);
		}
	}
	/** fin gestion de l'affichage sur la fenetre de trace de l'execution */
	
	/** constructeur de classe Automate */
	public Automate() {
		initAction();
		this.errFatale = false;
	}
	
	/** interpreteur de l'automate */
	public void interpreteur() {
		etatCourant = etatInitial;
		/** Unite lexicale courante */
		int token;					
		
		while (etatCourant != etatFinal && !errFatale) {
			token = lex.lireSymb();
			int etatDepart=etatCourant;
			int action = getAction(etatCourant, token);
			faireAction(etatCourant, token);
			etatCourant = getTransition(etatCourant, token);
			this.notifyObservers(etatDepart, token, etatCourant, action);
		}
	}

	 
	abstract int getTransition(int etat, int unite);
	abstract void initAction();
	abstract void faireAction(int etat, int unite);
	abstract int getAction(int etat, int unite);

}/** Automate */
