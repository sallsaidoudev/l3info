package fr.istic.prg1.tp4;

import java.util.ArrayList;
import java.util.ListIterator;

public class MySet extends ArrayList<SubSet> {

	private static final int MAX_RANK = 128;
	private static final SubSet FLAG_VALUE = new SubSet(MAX_RANK, new SmallSet());

	private SubSet flag;

	public MySet() {
		super();
		flag = FLAG_VALUE;
		super.add(flag);
	}

	public boolean contains(int x) {
		int rank = x / 256;
		if (!flag.set.contains(rank))
			return false;
		for (SubSet cur : super)
			if (cur.rank==rank && cur.set.contains(x % 256))
				return true;
		return false;
	}

	public boolean add(int x) {
		int rank = x / 256;
		if (flag.set.contains(rank)) {
			for (SubSet cur : super())
				if (cur.rank==rank)
					cur.set.add(x % 256);
		} else {
			new_set = new SubSet(rank, new SmallSet());
			new_set.set.add(x % 256);
			ListIterator iter = super.listIterator();
			while (iter.hasNext())
				if (iter.next().rank > rank)
					iter.add(new_set);
			flag.set.add(rank);
		}
	}

	public void intersection(MySet set2) {
		for (SubSet cur : super())
			if (set2.flag.set.contains(cur.rank))
				for (SubSet cur2 : set2)
					if (cur2.rank==cur.rank)
						cur.intersection(cur2);
		ListIterator iter = super.listIterator();
		while (iter.hasNext())
			if (iter.next().isEmpty())
				iter.remove();
	}

// remove
// size
// difference
// symmetricDifference
// union
// equals
// isIncludeIn
// restore
// save
// print
}
