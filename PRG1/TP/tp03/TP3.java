import java.lang.*;
import java.io.*;
import java.util.Scanner;

import fr.istic.prg1.tp3.*;

/**
 * Programme de test des exercices.
 */
public class TP3 {

	private static final Scanner stdin = new Scanner(System.in);

	public static void main(String[] args) {
		// Fourmis
		System.out.println("Suite des fourmis (10 premiers termes)");
		String ants = "1";
		for (int i=0; i<10; ++i) {
			System.out.println(ants);
			ants = Fourmis.next(ants);
		}
		System.out.println();

		// Classement par insertion
		System.out.println("Classement d'entiers par insertion");
		InsertionInteger int_arr = new InsertionInteger();
		System.out.print("Entrez une suite d'entiers et terminez par -1 : ");
		int_arr.createArray(stdin);
		System.out.println(int_arr + "\n");

		// Classement des doublets
		System.out.println("Classement de paires d'entiers");
		InsertionPair pair_arr = new InsertionPair();
		if (args.length == 0) {
			System.out.print("Entrez une suite de paires d'entiers et terminez par -1 : ");
			pair_arr.createArray(stdin);
			stdin.close(); // on n'a plus besoin de ce scanner
		} else {
			System.out.println("Tri sur le fichier donné en argument :");
			File data = new File(args[0]);
			try {
				Scanner sc_data = new Scanner(data);
				pair_arr.createArray(sc_data);
				sc_data.close();
			} catch (Exception e) { // en cas d'erreur liée au fichier
				e.printStackTrace();
			}
		}
		System.out.println(pair_arr);
	}

}
