package fr.istic.prg1.list.util;

public interface Iterator<T> {
    public abstract void goForward();
    public abstract void goBackward();
    public abstract void restart();
    public abstract boolean isOnFlag();
    public abstract void remove();
    public abstract T getValue();
    public abstract T nextValue();
    public abstract void addLeft(T o);
    public abstract void addRight(T o);
    public abstract void setValue(T o);
    public abstract String toString();
}
