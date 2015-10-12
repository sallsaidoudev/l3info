package fr.istic.prg1.tp4;

/**
 * @author Mickaël Foursov <foursov@univ-rennes1.fr>
 * @version 4.0
 * @since 2015-06-15
 */

public class SmallSet {

    private static final int setSize = 256;
    private boolean[] tab = new boolean[setSize];

    public SmallSet() {
        for (int i = 0; i < setSize; ++i)
            tab[i] = false;
    }

    public SmallSet(boolean[] t) {
        for (int i = 0; i < setSize; ++i)
            tab[i] = t[i];
    }

    public int size() {
        int cpt = 0;
        for (int i=0; i<setSize; ++i)
            if (tab[i])
                ++cpt;
        return cpt;
    }

    public boolean contains(int x) {
        return tab[x];
    }

    public boolean isEmpty() {
        for (int i=0; i<setSize; ++i)
            if (tab[i])
                return false;
        return true;
    }

    public void add(int x) {
        tab[x] = true;
    }

    public void remove(int x) {
        tab[x] = false;
    }

    public void addInterval(int deb, int fin) {
        for (int i=deb; i<fin; ++i)
            tab[i] = true;
    }

    public void removeInterval(int deb, int fin) {
        for (int i=deb; i<fin; ++i)
            tab[i] = false;
    }

    public void union(SmallSet set2) {
        for (int i=0; i<setSize; ++i)
            tab[i] = tab[i] || set2.tab[i];
    }

    public void intersection(SmallSet set2) {
        for (int i=0; i<setSize; ++i)
            tab[i] = tab[i] && set2.tab[i];
    }

    public void difference(SmallSet set2) {
        for (int i=0; i<setSize; ++i)
            tab[i] = tab[i] && !set2.tab[i];
    }

    public void symmetricDifference(SmallSet set2) {
        for (int i=0; i<setSize; ++i)
            tab[i] = (tab[i] || set2.tab[i]) && !(tab[i] && set2.tab[i]);
    }

    public void complement() {
        for (int i=0; i<setSize; ++i)
            tab[i] = !tab[i];
    }

    public void clear() {
        for (int i=0; i<setSize; ++i)
            tab[i] = false;
    }

    public boolean isIncludedIn(SmallSet set2) {
        for (int i=0; i<setSize; ++i)
            if (tab[i] && !set2.tab[i])
                return false;
        return true;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (!(obj instanceof SmallSet))
            return false;
        // obj est donc un SmallSet
        for (int i=0; i<setSize; ++i)
            if (tab[i] != obj.tab[i])
                return false;
        return true;
    }

    public SmallSet clone() {
       return new SmallSet(tab);
    }

    @Override
    public String toString() {
        String s;
        s = "Eléments présents : ";
        for (int i = 0; i < setSize; ++i)
            if (tab[i])
                s = s + i + " ";
        return s;
    }
}
