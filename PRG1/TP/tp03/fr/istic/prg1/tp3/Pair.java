package fr.istic.prg1.tp3;

/**
 * Paire d'entiers non mutable, munie de l'ordre lexicographique.
 * @see InsertionPair
 * @author Leo Noel-Baron, Thierry Sampaio
 */
public class Pair {
	
	private int n1, n2;
	
	public Pair(int _n1, int _n2) {
		n1 = _n1;
		n2 = _n2;
	}

	public boolean equals(Pair p) {
		return n1 == p.n1 && n2 == p.n2;
	}

	public boolean inf(Pair p) {
		return n1 < p.n1 || (n1 == p.n1 && n2 < p.n2);
	}

	public String toString() {
		return n1 + "," + n2;
	}

}
