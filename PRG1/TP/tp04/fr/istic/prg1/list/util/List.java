package fr.istic.prg1.list.util;

/**
 * @author Léo Noël-Baron, Thierry Sampaio
 * @version 1.0
 * @since 2015-11-12
 */

public class List<T extends SuperT> {

    public class ListIterator implements Iterator<T> {
        private Element current;
        private ListIterator() { current = flag.right; }
        @Override
        public void goForward() { current = current.right; }
        @Override
        public void goBackward() { current = current.left; }
        @Override
        public void restart() { current = flag.right; }
        @Override
        public boolean isOnFlag() { return current == flag; }
        @Override
        public void remove() {
            if (isOnFlag())
                return;
            current.left.right = current.right;
            current.right.left = current.left;
            current = current.right;
        }
        @Override
        public T getValue() { return current.value; }
        @Override
        public T nextValue() { goForward(); return current.value; }
        @Override
        public void addLeft(T v) {
            Element elt = new Element(v);
            elt.left = current.left;
            elt.right = current;
            current.left.right = elt;
            current.left = elt;
            goBackward();
        }
        @Override
        public void addRight(T v) {
            Element elt = new Element(v);
            elt.right = current.right;
            elt.left = current;
            current.right.left = elt;
            current.right = elt;
            goForward();
        }
        @Override
        public void setValue(T v) { current.value = v; }
        @Override
        public String toString() { return "list iterator"; }
    }

    class Element {
        public T value;
        public Element left;
        public Element right;
        public Element(T val) { value = val; left = null; right = null; }
    }

    private Element flag;

    public List() {
        flag = null;
    }

    public ListIterator iterator() {
        return new ListIterator();
    }

    public boolean isEmpty() {
        return flag.right == flag && flag.left == flag;
    }

    public void clear() {
        setFlag(flag.value);
    }

    public void setFlag(T f) {
        flag = new Element(f);
        flag.left = flag;
        flag.right = flag;
    }

    public void addHead(T v) {
        Element elt = new Element(v);
        elt.right = flag.right;
        elt.left = flag;
        flag.right.left = elt;
        flag.right = elt;
    }

    public void addTail(T v) {
        Element elt = new Element(v);
        elt.left = flag.left;
        elt.right = flag;
        flag.left.right = elt;
        flag.left = elt;
    }

    @SuppressWarnings("unchecked")
    public List<T> clone() {
        List<T> c = new List<T>();
        c.setFlag(flag.value);
        ListIterator it = iterator();
        while (!it.isOnFlag()) {
            c.addTail((T) it.getValue().clone());
            it.goBackward();
        }
        return c;
    }

    @Override
    public String toString() {
        String s = "[ ";
        ListIterator it = iterator();
        while (!it.isOnFlag()) {
            s += it.getValue().toString() + " ";
        }
        return s + "]";
    }

}
