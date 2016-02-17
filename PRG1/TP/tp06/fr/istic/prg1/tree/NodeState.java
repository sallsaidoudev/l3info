package fr.istic.prg1.tree;

/**
 * @author Mickaël Foursov <foursov@univ-rennes1.fr>
 * @version 4.0
 * @since 2015-06-15
 * 
 *        Classe représentant les états des noeuds : 0 (carré/rectangle éteint),
 *        1 (carré/rectangle allumé) ou 2.
 * 
 *        Les trois objets sont non modifiables et existent en un seul
 *        exemplaire.
 * 
 */

public class NodeState {

	private static final NodeState ZERO = new NodeState(0);
	private static final NodeState ONE = new NodeState(1);
	private static final NodeState TWO = new NodeState(2);

	public final int state;

	/**
	 * Constructeur <b>privé</b> pour créer les objets
	 * @param nodeValue valeur du noeud
	 */
	private NodeState(int nodeValue) { state = nodeValue; }

	/**
	 * Usine à objets
	 * @param nodeValue valeur du noeud
	 * @return noeud avec la valeur x
	 */
	public static NodeState valueOf(int nodeValue) {
		if (nodeValue == 0)
			return ZERO;
		else if (nodeValue == 1)
			return ONE;
		else if (nodeValue == 2)
			return TWO;
		try {
			assert nodeValue == 0 || nodeValue == 1 || nodeValue == 2 : "Valeur incorrecte pour NodeState";
		} catch (AssertionError e) {
			e.printStackTrace();
			System.exit(0);
		}
		return null;
	}

	@Override
	public boolean equals(Object o) { return this == o; }

	@Override
	public int hashCode() { return state; }

	@Override
	public String toString() { return "state = " + state; }

}
