public class Boules {

    private static int nombreBoules = 10;
    private static char[] tableauBoules;

    public static void main(String[] args) {
        Ecriture.ecrireString("nombre de boules : ");
        nombreBoules = Lecture.lireInt();
        Ecriture.ecrireString("suite des " + nombreBoules + " boules : ");
        tableauBoules = lireTableauBoules(); // j'ai les boules
        int r = 0, s = 0, t = nombreBoules - 1;
        while (s <= t) {
            switch (tableauBoules[s]) {
            case 'v':
                echange(r, s, tableauBoules);
                ++r; ++s;
                break;
            case 'b':
                ++s;
                break;
            case 'r':
                echange(s, t, tableauBoules);
                --t;
                break;
            default:
                Ecriture.ecrireString("erreur : s = "+s+", boule = "+tableauBoules[s]);
                System.exit(0);
            }
        }
        Ecriture.ecrireString("résultat du tri : ");
        ecrireTableauBoules(tableauBoules);
        Ecriture.ecrireStringln("");
    }

    public static char[] lireTableauBoules() {
        char[] tab = new char[nombreBoules];
        for (int i=0; i<nombreBoules; ++i) {
            char c = Lecture.lireChar();
            if (c != '\n') tab[i] = c;
            else --i;
        }
        return tab;
    }

    public static void ecrireTableauBoules(char[] tab) {
        for (int i=0; i<nombreBoules; ++i)
            Ecriture.ecrireChar(tab[i]);
    }

    public static void echange(int i, int j, char[] tab) {
        char c = tab[i];
        tab[i] = tab[j];
        tab[j] = c;
    }

}
