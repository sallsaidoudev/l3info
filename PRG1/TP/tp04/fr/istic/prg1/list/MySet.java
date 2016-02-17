package fr.istic.prg1.list;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Scanner;

import fr.istic.prg1.list.util.Iterator;
import fr.istic.prg1.list.util.List;
import fr.istic.prg1.list.util.SmallSet;

/**
 * @author Léo Noël-Baron, Thierry Sampaio
 * @version 4.1
 * @since 2015-06-15
 */

public class MySet extends List<SubSet> {

    private static final int MAX_RANG = 128;
    private static final SubSet FLAG_VALUE = new SubSet(MAX_RANG, new SmallSet());
    private static final Scanner standardInput = new Scanner(System.in);

    public MySet() {
        super();
        setFlag(FLAG_VALUE);
    }

    public static void closeAll() {
        standardInput.close();
    }

    // Questionner l'ensemble

    /**
     * @return taille de l'ensemble this
     */
    public int size() {
        Iterator<SubSet> it = iterator();
        int count = 0;
        while (!it.isOnFlag()) {
            count += it.getValue().set.size();
            it.goForward();
        }
        return count;
    }

    /**
     * @return true si le nombre saisi appartient à this, false sinon
     */
    public boolean contains() {
        System.out.println("Valeur cherchée : ");
        int value = readValue(standardInput, 0);
        return this.contains(value);
    }
    public boolean contains(int value) {
        int rank = value / 256;
        Iterator<SubSet> it = iterator();
        while (!it.isOnFlag() && rank > it.getValue().rank)
            it.goForward();
        if (rank < it.getValue().rank)
            return false;
        return it.getValue().set.contains(value % 256);
    }

    /**
     * @return true si les ensembles this et o sont égaux, false sinon
     */
    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        } else if (o == null) {
            return false;
        } else if (!(o instanceof MySet)) {
            return false;
        } else {
            Iterator<SubSet> it = iterator();
            MySet other = (MySet) o;
            Iterator<SubSet> o_it = other.iterator();
            while (!it.isOnFlag() && !o_it.isOnFlag()) {
                if (it.getValue().rank != o_it.getValue().rank)
                    return false;
                if (!it.getValue().set.equals(o_it.getValue().set))
                    return false;
                it.goForward();
                o_it.goForward();
            }
            if (!it.isOnFlag() || !o_it.isOnFlag())
                return false;
        }
        return true;
    }

    /**
     * @return true si this est inclus dans set2, false sinon
     */
    public boolean isIncludedIn(MySet set2) {
        Iterator<SubSet> it = iterator();
        Iterator<SubSet> it2 = set2.iterator();
        while (!it.isOnFlag() && !it2.isOnFlag()) {
            while (it.getValue().rank > it2.getValue().rank)
                it2.goForward();
            if (it.getValue().rank < it2.getValue().rank)
                return false;
            if (!it.getValue().set.isIncludedIn(it2.getValue().set))
                return false;
            it.goForward();
        }
        return true;
    }

    // Ajouter ou retirer à l'ensemble

    /**
     * Ajouter à this toutes les valeurs saisies par l'utilisateur et afficher
     * le nouveau contenu (arrêt par lecture de -1).
     */
    public void add() {
        System.out.println("Valeurs à ajouter (-1 pour finir) : ");
        this.add(System.in);
        System.out.println("Nouveau contenu : ");
        this.printNewState();
    }
    public void add(InputStream is) {
        Scanner sc = new Scanner(is);
        int value = readValue(sc, -1);
        while (value != -1) {
            this.addNumber(value);
            value = readValue(sc, -1);
        }
    }
    public void addNumber(int value) {
        int rank = value / 256;
        Iterator<SubSet> it = iterator();
        while (!it.isOnFlag() && rank > it.getValue().rank)
            it.goForward();
        if (rank == it.getValue().rank) {
            it.getValue().set.add(value % 256);
        } else {
            SubSet new_set = new SubSet(rank, new SmallSet());
            new_set.set.add(value % 256);
            it.addLeft(new_set);
        }
    }

    /**
     * Supprimer de this toutes les valeurs saisies par l'utilisateur et
     * afficher le nouveau contenu (arrêt par lecture de -1).
     */
    public void remove() {
        System.out.println("Valeurs à supprimer (-1 pour finir) : ");
        this.remove(System.in);
        System.out.println("Nouveau contenu : ");
        this.printNewState();
    }
    public void remove(InputStream is) {
        Scanner sc = new Scanner(is);
        int value = readValue(sc, -1);
        while (value != -1) {
            this.removeNumber(value);
            value = readValue(sc, -1);
        }
    }
    public void removeNumber(int value) {
        int rank = value / 256;
        Iterator<SubSet> it = iterator();
        while (!it.isOnFlag() && rank > it.getValue().rank)
            it.goForward();
        SubSet cur = it.getValue();
        if (rank == cur.rank) {
            cur.set.remove(value % 256);
            if (cur.set.isEmpty())
                it.remove();
        }
    }

    // Opérations ensemblistes

    /**
     * This devient la différence de this et set2.
     */
    public void difference(MySet set2) {
        if (set2.equals(this)) {
            clear();
            return;
        }
        Iterator<SubSet> it = iterator();
        Iterator<SubSet> it2 = set2.iterator();
        while (!it.isOnFlag()) {
            SubSet cur = it.getValue();
            SubSet cur2 = it2.getValue();
            if (cur.rank == cur2.rank) {
                cur.set.difference(cur2.set);
                if (cur.set.isEmpty())
                    it.remove();
                else
                    it.goForward();
            }
            if (cur.rank < cur2.rank)
                it.goForward();
            else
                it2.goForward();
        }
    }

    /**
     * This devient la différence symétrique de this et set2.
     */
    public void symmetricDifference(MySet set2) {
        if (set2.equals(this)) {
            clear();
            return;
        }
        Iterator<SubSet> it = iterator();
        Iterator<SubSet> it2 = set2.iterator();
        while (!it.isOnFlag() || !it2.isOnFlag()) {
            SubSet cur = it.getValue();
            SubSet cur2 = it2.getValue();
            if (cur.rank == cur2.rank) {
                cur.set.symmetricDifference(cur2.set);
                if (cur.set.isEmpty())
                    it.remove();
                else
                    it.goForward();
            }
            if (cur.rank > cur2.rank)
                it.addLeft(cur2.clone());
            if (cur.rank < cur2.rank)
                it.goForward();
            else
                it2.goForward();
        }
    }

    /**
     * This devient l'intersection de this et set2.
     */
    public void intersection(MySet set2) {
        Iterator<SubSet> it = iterator();
        Iterator<SubSet> it2 = set2.iterator();
        while (!it.isOnFlag()) {
            SubSet cur = it.getValue();
            SubSet cur2 = it2.getValue();
            if (cur.rank == cur2.rank) {
                cur.set.intersection(cur2.set);
                if (cur.set.isEmpty())
                    it.remove();
                else
                    it.goForward();
            }
            if (cur.rank < cur2.rank)
                it.remove();
            else
                it2.goForward();
        }
    }

    /**
     * This devient l'union de this et set2.
     */
    public void union(MySet set2) {
        Iterator<SubSet> it = iterator();
        Iterator<SubSet> it2 = set2.iterator();
        while (!it.isOnFlag() && !it2.isOnFlag()) {
            while (it.getValue().rank < it2.getValue().rank)
                it.goForward();
            SubSet cur = it.getValue();
            SubSet cur2 = it2.getValue();
            if (cur.rank == cur2.rank)
                cur.set.union(cur2.set);
            if (cur.rank > cur2.rank)
                it.addLeft(cur2.clone());
            it2.goForward();
        }
    }

    // Utilitaires

    /**
     * @return this sous forme de chaîne de caractères
     */
    @Override
    public String toString() {
        StringBuilder result = new StringBuilder();
        int count = 0;
        SubSet subSet;
        int startValue;
        Iterator<SubSet> it = this.iterator();
        while (!it.isOnFlag()) {
            subSet = it.getValue();
            startValue = subSet.rank * 256;
            for (int i = 0; i < 256; ++i) {
                if (subSet.set.contains(i)) {
                    String number = String.valueOf(startValue + i);
                    int numberLength = number.length();
                    for (int j = 6; j > numberLength; --j)
                        number += " ";
                    result.append(number);
                    ++count;
                    if (count == 10) {
                        result.append("\n");
                        count = 0;
                    }
                }
            }
            it.goForward();
        }
        if (count > 0)
            result.append("\n");
        return result.toString();
    }

    /**
     * Afficher les rangs présents dans this.
     */
    public void printRanks() { this.printRanksAux(); }
    private void printRanksAux() {
        int count = 0;
        System.out.println("Rangs présents :");
        Iterator<SubSet> it = this.iterator();
        while (!it.isOnFlag()) {
            System.out.print("" + it.getValue().rank + "  ");
            count = count + 1;
            if (count == 10) {
                System.out.println();
                count = 0;
            }
            it.goForward();
        }
        if (count > 0) {
            System.out.println();
        }
    }

    /**
     * Afficher à l'écran les entiers appartenant à this, dix entiers par ligne
     * d'écran.
     */
    public void print() { this.print(System.out); }
    private void print(OutputStream outFile) {
        try {
            String string = this.toString();
            outFile.write(string.getBytes());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * Afficher l'ensemble avec sa taille et les rangs présents.
     */
    private void printNewState() {
        this.print(System.out);
        System.out.println("Nombre d'éléments : " + this.size());
        this.printRanksAux();
    }

    /**
     * Créer this à partir d'un fichier choisi par l'utilisateur contenant une
     * séquence d'entiers positifs terminée par -1 (cf f0.ens, f1.ens, f2.ens,
     * f3.ens et f4.ens).
     */
    public void restore() {
        String fileName = readFileName();
        InputStream inFile;
        try {
            inFile = new FileInputStream(fileName);
            this.clear();
            this.add(inFile);
            inFile.close();
            System.out.println("Nouveau contenu : ");
            this.printNewState();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            System.out.println("Fichier " + fileName + " inexistant");
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println("Problème de fermeture du fichier " + fileName);
        }
    }

    /**
     * Sauvegarder this dans un fichier d'entiers positifs terminé par -1.
     */
    public void save() {
        String fileName = readFileName();
        OutputStream outFile;
        try {
            outFile = new FileOutputStream(fileName);
            this.print(outFile);
            outFile.write("-1\n".getBytes());
            outFile.close();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
            System.out.println("Ouverture impossible : " + fileName);
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println("Problème de fermeture du fichier" + fileName);
        }
    }

    /**
     * @return l'entier lu au clavier (doit être entre min et 32767)
     */
    private static int readValue(Scanner scanner, int min) {
        int value = scanner.nextInt();
        while (value < min || value > 32767) {
            System.out.println("Valeur incorrecte");
            value = scanner.nextInt();
        }
        return value;
    }

    /**
     * @return nom de fichier saisi par l'utilisateur
     */
    private static String readFileName() {
        System.out.print("Nom du fichier : ");
        String fileName = standardInput.next();
        return fileName;
    }
}
