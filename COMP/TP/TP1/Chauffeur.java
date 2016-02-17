
/** 
 * classe Chauffeur representant les donnees des chauffeurs
 * @author Masson, Grazon
 *
 */
public class Chauffeur {
	
	/**
	 * numchauf = numId du chauffeur 
	 * bj = quantite totale de vin beaujolais livree
	 * bg = quantite totale de vin bourgogne livree
	 * ordin = quantite totale de vin ordinaire livree
	 */
	public int numchauf, bj, bg, ordin ; 
	/** magdif = ensemble des magasins livres */
	public SmallSet magdif ;
	
	public Chauffeur(int numchauf,int bj,int bg,int ordin,SmallSet magdif) {
	    this.numchauf = numchauf ; this.bj = bj ; this.bg = bg ; 
	    this.ordin = ordin ; this.magdif = magdif.clone() ;
	}
	
	public Chauffeur copie() {return new Chauffeur(numchauf,bj,bg,ordin,magdif);}
    } /** class Chauffeur */

    