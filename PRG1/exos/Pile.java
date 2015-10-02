public class Pile {
	
	private class Maillon {
		int elt; Maillon suivant;
		Maillon(int _elt, Maillon _suivant) { elt = _elt; suivant = _suivant; }
		boolean equals(Maillon m) { return elt == m.elt && suivant == m.suivant; }
	}

	public class Parcours {
		private Maillon courant;
		private Pile mere;
		public Parcours() { courant = sommet; mere = Pile.this; }
		public Parcours(Parcours depuis) {
			if (mere == depuis.mere)
				courant = depuis.courant;
		}
		public void suivant() { courant = courant.suivant; }
		public int courant() { return courant.elt; }
		public boolean fin() { return courant == null; }
	}

	private Maillon sommet;

	public Pile() { sommet = null; }
	public boolean equals(Pile p) { return sommet.equals(p.sommet); }
	public void empiler(int elt) { sommet = new Maillon(elt, sommet); }
	public void depiler() { sommet = sommet.suivant; }
	public int sommet() { return sommet.elt; }

}
