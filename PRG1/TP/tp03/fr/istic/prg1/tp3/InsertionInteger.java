package fr.istic.prg1.tp3;

import java.util.Scanner;

/**
 * Tableau d'insertion d'entiers.
 * Cette classe permet d'ajouter un par un des entiers a un tableau garde trie
 * par ordre croissant sans doublons.
 * @author Leo Noel-Baron, Thierry Sampaio
 */
public class InsertionInteger {
	
	private static final int SIZE_MAX = 10;
	private int size;
	private int[] array = new int[SIZE_MAX];

	public InsertionInteger() {
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
	 * @return une copie de la partie remplie du tableau
	 */
	public int[] toArray() {
		int[] cp_array = new int[size];
		for (int i=0; i<size; ++i)
			cp_array[i] = array[i];
		return cp_array;
	}

	/**
	 * Initialise le tableau d'insertion a partir d'un scanner, en envoyant les valeurs lues
	 * a la methode insert.
	 * @param scanner le scanner a partir duquel remplir le tableau
	 */
	public void createArray(Scanner scanner) {
		int x = scanner.nextInt();
		while (x != -1) {
			insert(x);
			x = scanner.nextInt();
		}
	}

	/**
	 * Insere une valeur dans le tableau ; la valeur est ignoree si elle est deja presente.
	 * Sinon, elle est inseree au bon endroit selon l'ordre croissant et size est incremente.
	 * @param value la valeur a inserer
	 * @pre         array[0..size-1] est trie par ordre croissant
	 * @return      vrai si la valeur est deja dans le tableau ou qu'il est plein, faux sinon
	 * @throws      rien mais on pourrait lever une exception en cas de depassement de taille,
	 *              plutot que de renvoyer false
	 */
	public boolean insert(int value) {
		if (size == SIZE_MAX)
			return false;
		int x = value;
		for (int i=0; i<size; ++i) {
			if (x == array[i]) {
				return false;
			} else if (x < array[i]) {
				int tmp = array[i];
				array[i] = x;
				x = tmp;
			}
		}
		array[size] = x;
		++size;
		return true;
	}

}
