package fr.istic.prg1.tree.util;

import java.util.Stack;

public class BinaryTree<T> {
	
	class Element {
		T value;
		Element left;
		Element right;
		Element() { value = null; left = null; right = null; }
		Element(T v) { value = v; left = null; right = null; }
	}

	public class TreeIterator implements Iterator<T> {
		private Element current;
		private Stack<Element> legacy;
		private TreeIterator() { current = root; legacy = new Stack<Element>(); }
		@Override
		public void goLeft() {
			if (isEmpty()) return;
			if (current.left == null) current.left = new Element();
			legacy.push(current);
			current = current.left;
		}
		@Override
		public void goRight() {
			if (isEmpty()) return;
			if (current.right == null) current.right = new Element();
			legacy.push(current);
			current = current.right;
		}
		@Override
		public void goUp() {
			if (legacy.empty()) return;
			Element father = legacy.pop();
			current = father;
		}
		@Override
		public void goRoot() { current = root; }
		@Override
		public boolean isEmpty() { return current.value == null; }
		@Override
		public NodeType nodeType() {
			System.out.println(current.value + "(" + current.left + " " + current.right + ")");
			if (current.value == null)
				return NodeType.SENTINEL;
			else if (current.left ==  null && current.right == null)
				return NodeType.LEAF;
			else if (current.right == null)
				return NodeType.SIMPLE_LEFT;
			else if (current.left == null)
				return NodeType.SIMPLE_RIGHT;
			else
				return NodeType.DOUBLE;
		}
		@Override
		public void remove() {
			if (nodeType() == NodeType.DOUBLE || nodeType() == NodeType.SENTINEL) return;
			switch (nodeType()) {
			case LEAF:
				current = new Element();
				break;
			case SIMPLE_LEFT:
				current = current.left;
				break;
			case SIMPLE_RIGHT:
				current = current.right;
				break;
			}
		}
		@Override
		public void clear() { current = new Element(); }
		@Override
		public T getValue() { return current.value; }
		@Override
		public void addValue(T v) { current = new Element(v); }
		@Override
		public void setValue(T v) { current.value = v; }
		@Override
		public void switchValue(int i) { System.out.println("not implemented"); System.exit(-1); }
	}

	private Element root;

	public BinaryTree() { root = new Element(); }

	public TreeIterator iterator() { return new TreeIterator(); }

	public boolean isEmpty() { return root.value == null; }

	public int height() { return heightRec(iterator()); }
	private int heightRec(Iterator<T> it) {
		switch (it.nodeType()) {
		case SENTINEL:
			return -1;
		case LEAF:
			return 0;
		case SIMPLE_LEFT:
			it.goLeft();
			return 1 + heightRec(it);
		case SIMPLE_RIGHT:
			it.goRight();
			return 1 + heightRec(it);
		case DOUBLE:
			it.goLeft();
			int hl = heightRec(it);
			it.goUp(); it.goRight();
			int hr = heightRec(it);
			return 1 + Math.max(hl, hr);
		}
		return -1;
	}

	public String toString() { return "binary tree (plot to display)"; }

}
