import java.io.*;
import java.util.ArrayList;

/**
 * La classe Lex modelise un analyseur lexical abstrait
 * @author Masson, Grazon
 *
 */
abstract class Lex {
	
	/** definition du flot d'entree a analyser */
	protected InputStream flot;
	/** definition de la table des identificateurs */
	protected static final int MAXID = 200;
	protected static String[] tabId = new String[MAXID];
	
	/** gestion de l'affichage sur la fenetre de trace de l'execution */
	private ArrayList<ObserverLexique> lesObserveurs = new ArrayList<ObserverLexique>();
	public void newObserver(ObserverLexique obs){
		this.lesObserveurs.add(obs);
	}
	public void notifyObservers(char c){
		for(ObserverLexique o : this.lesObserveurs){
			o.nouveauChar(c);
		}
	}
	/** fin gestion de l'affichage sur la fenetre de trace de l'execution */
	
	/** constructeur de classe Lex */
	public Lex (InputStream f){
		this.flot = f;
	}
	/** methode d'acces a un item lexical */
	abstract int lireSymb();
	/** methode d'acces a la chaine correspondant a un ident d'indice nId (dans tabId) **/
	abstract String repId(int nId);

}/** class Lex */
