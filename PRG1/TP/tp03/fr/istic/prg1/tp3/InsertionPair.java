package fr.istic.prg1.tp3;

import java.util.Scanner;

/**
 * Tableau d'insertion de paires d'entiers.
 * Cette classe permet d'ajouter une par une des paires d'entiers a un tableau garde trie
 * par ordre lexicographique sans doublons.
 * Ah, une recopie de code pareille, ca donne envie de resoudre l'exercice en utilisant
 * le polymorphisme et la surchage d'operateurs, mais l'un n'est pas demande dans l'enonce
 * et l'autre n'existe pas en Java, malheur.
 * @see InsertionInteger
 * @author Leo Noel-Baron, Thierry Sampaio
 */
public class InsertionPair {
	
	/*
	Cet exercice a d'abord ete resolu en utilisant la classe interne privee suivante :

	private class Pair {
		int n1, n2;
		Pair(int _n1, int _n2) { n1 = _n1; n2 = _n2; }
		boolean equals(Pair p) { return n1 == p.n1 && n2 == p.n2; }
		boolean inf(Pair p) { return n1 < p.n1 || (n1 == p.n1 && n2 < p.n2); }
		public String toString() { return n1 + "," + n2; }
	}

	et ca marchait tres bien (et le sujet de TP ne l'interdisait pas), mais ce n'etait pas
	compatible avec les tests unitaires decouverts par la suite. L'implementation a donc
	ete corrigee pour une classe publique visible dans le fichier associe.
	*/

	private static final int SIZE_MAX = 10;
	private int size;
	private Pair[] array = new Pair[SIZE_MAX];

	public InsertionPair() {
		size = 0;
	}

	@Override
	public String toString() {
		String str = "";
		for (int i=0; i<size; ++i)
			str += array[i] + " ";
		return str;
	}

	/**
	 * Copie le tableau ; comme cette methode est destinee a un usage externe, on prefere
	 * renvoyer un tableau de tableaux de taille 2 plutot qu'un tableau de Pair, cette classe
	 * etant privee car interne au fonctionnement du tableau d'insertion.
	 * @return une copie de la partie remplie du tableau
	 */
	public Pair[] toArray() {
	 	Pair[] cp_array = new Pair[size];
	 	for (int i=0; i<size; ++i)
	 		cp_array[i] = array[i];
	 	return cp_array;
	}

	/**
	 * Initialise le tableau d'insertion a partir d'un scanner, en envoyant les paires lues
	 * a la methode insert.
	 * @param scanner le scanner a partir duquel remplir le tableau
	 */
	public void createArray(Scanner scanner) {
		int x = scanner.nextInt();
		int y = scanner.nextInt();
		while (x != -1 && y != -1) {
			insert(new Pair(x, y));
			x = scanner.nextInt();
			if (scanner.hasNextInt())
				y = scanner.nextInt();
		}
	}

	/**
	 * Insere une paire dans le tableau ; la paire est ignoree si elle est deja presente.
	 * Sinon, elle est inseree au bon endroit selon l'ordre lexicographique défini dans la 
	 * classe interne Pair, et size est incremente.
	 * @param pair  la paire a inserer
	 * @pre         array[0..size-1] est trie par ordre croissant
	 * @return      vrai si la paire est deja dans le tableau ou qu'il est plein, faux sinon
	 */
	public boolean insert(Pair pair) {
		if (size == SIZE_MAX)
			return false;
		Pair p = pair;
		for (int i=0; i<size; ++i) {
			if (p.equals(array[i])) {
				return false;
			} else if (p.inf(array[i])) {
				Pair tmp = array[i];
				array[i] = p;
				p = tmp;
			}
		}
		array[size] = p;
		++size;
		return true;
	}

}
