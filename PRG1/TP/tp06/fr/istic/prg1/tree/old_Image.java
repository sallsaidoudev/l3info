package fr.istic.prg1.tree;

public class Image extends BinaryTree<NodeState> {

	public Image() {
		super();
	}

	public boolean isPixelOn(int x, int y) {
		Iterator<NodeState> it = iterator();
		int curx = 128, cury = 128;
		for (int cpt=1; it.getValue().state == 2; ++cpt) {
			if (y < cury)
				it.goLeft();
			else
				it.goRight();
			if (x < curx) 
				it.goLeft();
			else
				it.goRight();
			int step = 128/Math.pow(2, cpt);
			cury += Integer.signum(y - cury) * step;
			curx += Integer.signum(x - curx) * step;
		}
		return it.getValue().state == 1;
	}

	public void videoInverse() {
		Iterator<NodeState> it = iterator();
		videoInverseRec(it);
	}
	private void videoInverseRec(Iterator<NodeState> it) {
		NodeState node = it.getValue();
		if (it.isEmpty)
			return;
		if (node.state != 2) {
			node.state = 1 - node.state;
			it.setValue(node);
			return;
		}
		it.goLeft();
		videoInverseRec(it);
		it.goUp();
		it.goRight();
		videoInverseRec(it);
		it.goUp();
	}

	private void copySubTree(Iterator<NodeState> it, Iterator<NodeState> ot) {
		NodeState node = new NodeState(), other = ot.getValue();
		if (ot.isEmpty()) {
			it.clear();
			return;
		}
		if (it.isEmpty())
			it.addValue(node);
		node.state = other.state;
		if (other.state != 2)
			it.clear();
		it.setValue(node);
		if (other.state != 2)
			return;
		it.goLeft(); ot.goLeft();
		copySubTree(it, ot);
		it.goUp(); ot.goUp();
		it.goRight(); ot.goRight();
		copySubTree(it, ot);
		it.goUp(); ot.goUp();
	}

	public void union(Image img1, Image img2) {
		Iterator<NodeState> it = iterator(), it1 = img1.iterator(), it2 = img2.iterator();
		unionRec(it, it1, it2);
	}
	private void unionRec(Iterator<NodeState> it, Iterator<NodeState> it1, Iterator<NodeState> it2) {
		NodeState node1 = it1.getValue(), node2 = it2.getValue();
		NodeState update = new NodeState();
		if (it1.isEmpty() && it2.isEmpty())
			return;
		if (it.isEmpty())
			it.addValue(update);
		if (it1.isEmpty() || it2.isEmpty()) {
			if (it1.isEmpty())
				it.setValue(it2.getValue());
			else
				it.setValue(it1.getValue());
			return;
		}
		if (node1.state != 2 && node2.state != 2) {
			update.state = (node1.state + node2.state + node1.state*node2.state) % 2; // node1 U node2
		} else if (node1.state != 2 || node2.state != 2) {
			update.state = Math.abs(node1.state - node2.state); // 1 if 1, 2 if 0
			if (update.state == 2) { // we need to copy the non-2 subtree
				if (node1.state == 2)
					copySubTree(it, it1);
				else
					copySubTree(it, it2);
			}
		} else {
			update.state = 2;
		}
		it.setValue(update);
		if (node1.state != 2 || node2.state != 2)
			return;
		it.goLeft(); it1.goLeft(); it2.goLeft();
		unionRec(it, it1, it2);
		it.goUp(); it1.goUp(); it2.goUp();
		it.goRight(); it1.goRight(); it2.goRight();
		unionRec(it, it1, it2);
		it.goUp(); it1.goUp(); it2.goUp();
	}

	public void intersection(Image img1, Image img2) {
		Iterator<NodeState> it = iterator(), it1 = img1.iterator(), it2 = img2.iterator();
		interRec(it, it1, it2);
	}
	private void interRec(Iterator<NodeState> it, Iterator<NodeState> it1, Iterator<NodeState> it2) {
		NodeState node1 = it1.getValue(), node2 = it2.getValue();
		NodeState update = new NodeState();
		if (it.isEmpty())
			it.addValue(update);
		if (node1.state != 2 && node2.state != 2) {
			update.state = node1.state * node2.state; // node1 /\ node2
		} else if (node1.state != 2 || node2.state != 2) {
			update.state = Math.abs(node1.state - node2.state); // 1 if 1, 2 if 0
			if (update.state == 2) { // we need to copy the non-2 subtree
				if (node1.state == 2)
					copySubTree(it, it1);
				else
					copySubTree(it, it2);
			}
		} else {
			update.state = 2;
		}
		it.setValue(update);
		if (node1.state != 2 || node2.state != 2)
			return;
		it.goLeft(); it1.goLeft(); it2.goLeft();
		interRec(it, it1, it2);
		it.goUp(); it1.goUp(); it2.goUp();
		it.goRight(); it1.goRight(); it2.goRight();
		interRec(it, it1, it2);
		it.goUp(); it1.goUp(); it2.goUp();
	}

}
