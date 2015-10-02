package fr.istic.prg1.tp3;

/**
 * Algorithme implementant la suite des fourmis.
 * La suite des fourmis est definie recursivement par
 *    u0 = "1" lu comme "un 1"
 *    u1 = "11" lu comme "deux 1"
 * et ainsi de suite. Pour un terme donne sous forme de
 * String, la methode next renvoie le suivant.
 * @author Leo Noel-Baron, Thierry Sampaio
 */
public class Fourmis {

	/**
	 * @param ui un terme de la suite des fourmis
	 * @pre      ui.length() > 0
	 * @return   le terme suivant de la suite
	 */
	public static String next(String ui) {
		String uj = "";
		int cur = Character.getNumericValue(ui.charAt(0));
		int nb_cur = 0;
		for (int k=0; k<ui.length(); ++k) {
			int nk = Character.getNumericValue(ui.charAt(k));
			if (nk == cur) {
				++nb_cur;
			} else {
				uj += nb_cur + "" + cur;
				cur = nk;
				nb_cur = 1;
			}
		}
		uj += nb_cur + "" + cur;
		return uj;
	}

}
