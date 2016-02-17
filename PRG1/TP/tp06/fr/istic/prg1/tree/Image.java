package fr.istic.prg1.tree;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Scanner;

import fr.istic.prg1.tree.util.BinaryTree;
import fr.istic.prg1.tree.util.ImageTable;
import fr.istic.prg1.tree.util.ImageWindow;
import fr.istic.prg1.tree.util.Iterator;
import fr.istic.prg1.tree.util.NodeType;
import fr.istic.prg1.tree.util.TreeFrame;

/**
 * @author Mickael Foursov <foursov@univ-rennes1.fr>
 * @version 4.0
 * @since 2015-06-15
 * 
 *        Classe decrivant les images en noir et blanc de 256 sur 256 pixels
 *        sous forme d'arbres binaires.
 * 
 */

public class Image extends BinaryTree<NodeState> {

	protected static final int WINDOW_SIZE = 256;
	protected static final Scanner standardInput = new Scanner(System.in);
	private static final ImageTable table = new ImageTable();

	public Image() { super(); }

	//////////////////////////
	// Méthodes utilitaires //
	//////////////////////////

	public static void closeAll() { standardInput.close(); }

	/**
	 * Crée this à partir d'un fichier texte (cf a1.arb, ...) et l'affiche dans
	 * une fenêtre. Chaque ligne du fichier est de la forme (e x1 y1 x2 y2) et
	 * indique si on souhaite éteindre (e=0) ou allumer (e=1) la région
	 * rectangulaire de coordonnées x1, y1, x2, y2. Le fichier se termine par un
	 * e de valeur -1.
	 */
	public void constructTreeFromFile() {
		Iterator<NodeState> it = this.iterator();
		it.clear();
		System.out.print("nom du fichier d'entree : ");
		String fileName = standardInput.nextLine();
		try {
			InputStream inFile = new FileInputStream(fileName);
			System.out.println("Corrige : createTreeFromFile");
			System.out.println("---------------------");
			xCreateTreeFromFile(inFile);
			inFile.close();
		} catch (FileNotFoundException e) {
			System.out.println("fichier " + fileName + " inexistant");
		} catch (IOException e) {
			e.printStackTrace();
			System.out.println("impossible de fermer le fichier " + fileName);
			System.exit(0);
		}
	}
	public void xCreateTreeFromFile(InputStream is) {
		xReadImageFromFile(is);
		Iterator<NodeState> it = this.iterator();
		xConstructTree(it, 0, 0, WINDOW_SIZE, true);
	}
	private static void xReadImageFromFile(InputStream is) {
		Scanner scanner = (is == System.in) ? standardInput : new Scanner(is);
		int state, x1, x2, y1, y2;
		table.clearWindow();
		state = scanner.nextInt();
		while (state != -1) {
			x1 = scanner.nextInt();
			y1 = scanner.nextInt();
			x2 = scanner.nextInt();
			y2 = scanner.nextInt();
			switch (state) {
			case 0:
				table.switchOff(x1, y1, x2, y2);
				break;
			case 1:
				table.switchOn(x1, y1, x2, y2);
				break;
			}
			state = scanner.nextInt();
		}
		if (is != System.in) {
			scanner.close();
		}
	}
	private static void xConstructTree(Iterator<NodeState> it, int x, int y, int squareWidth, boolean isSquare) {
		int rectangleWidth = squareWidth / 2;
		int state;
		if (isSquare) {
			state = table.state(x, y, x + squareWidth - 1, y + squareWidth - 1);
		} else {
			state = table.state(x, y, x + squareWidth - 1, y + rectangleWidth
					- 1);
		}
		it.addValue(NodeState.valueOf(state));
		if (state == 2) {
			it.goLeft();
			if (isSquare) {
				xConstructTree(it, x, y, squareWidth, false);
			} else {
				xConstructTree(it, x, y, rectangleWidth, true);
			}
			it.goUp();
			it.goRight();
			if (isSquare) {
				xConstructTree(it, x, y + rectangleWidth, squareWidth, false);
			} else {
				xConstructTree(it, x + rectangleWidth, y, rectangleWidth, true);
			}
			it.goUp();
		}
	}

	/**
	 * Sauvegarder, dans un fichier texte, les feuilles de this selon un format
	 * conforme aux fichiers manipulés par la commande constructTreeFromFile.
	 * 
	 * @pre !this.isEmpty()
	 */
	public void saveImage() {
		System.out.print("nom du fichier de sortie : ");
		String fileName = standardInput.next();
		OutputStream outFile;
		try {
			outFile = new FileOutputStream(fileName);
			System.out.println("Corrige : Save");
			System.out.println("----------------");
			Iterator<NodeState> it = this.iterator();
			String ch = xSave(it, 0, 0, WINDOW_SIZE, true) + "-1\n";
			outFile.write(ch.getBytes());
			outFile.flush();
			outFile.close();
		} catch (FileNotFoundException e) {
			System.out.println("probleme d'ouverture de fichier pour "
					+ fileName);
		} catch (IOException e) {
			e.printStackTrace();
			System.out.println("impossible de fermer le fichier " + fileName);
			System.exit(0);
		}
	}
	private static String xSave(Iterator<NodeState> it, int x, int y, int squareWidth, boolean isSquare) {
		int rectangleWidth = squareWidth / 2;
		NodeState node;
		String result = "";
		switch (it.nodeType()) {
		case LEAF:
			node = it.getValue();
			if (isSquare) {
				if (node.state == 1) {
					result = result + "1 " + x + " " + y + " "
							+ (x + squareWidth - 1) + " "
							+ (y + squareWidth - 1) + "\n";
				}
			} else if (node.state == 1) {
				result = result + "1 " + x + " " + y + " "
						+ (x + squareWidth - 1) + " "
						+ (y + rectangleWidth - 1) + "\n";
			}
			break;
		case DOUBLE:
			it.goLeft();
			if (isSquare) {
				result += xSave(it, x, y, squareWidth, false);
			} else {
				result += xSave(it, x, y, rectangleWidth, true);
			}
			it.goUp();
			it.goRight();
			if (isSquare) {
				result += xSave(it, x, y + rectangleWidth, squareWidth, false);
			} else {
				result += xSave(it, x + rectangleWidth, y, rectangleWidth, true);
			}
			it.goUp();
			break;
		default:
			break;
		}
		return result;
	}

	/**
	 * Afficher this sous forme d'image dans la fenêtre graphique.
	 * 
	 * @param windowNumber
	 *            numéro de la fenêtre (de 0 à 4)
	 * @param window
	 *            fenÃªtre graphique pour l'affichage des images
	 */
	public void plotImage(int windowNumber, ImageWindow window) {
		System.out.println("Corrige : plotImage");
		System.out.println("------------------");
		window.clearWindow(windowNumber);
		Iterator<NodeState> it = this.iterator();
		xPlotTree(it, 0, 0, WINDOW_SIZE, true, windowNumber, window);
	}
	private static void xPlotTree(Iterator<NodeState> it, int x, int y, int squareWidth, boolean isSquare, int windowNumber, ImageWindow window) {
		int rectangleWidth = squareWidth / 2;
		NodeState node;
		switch (it.nodeType()) {
		case LEAF:
			node = it.getValue();
			if (isSquare) {
				if (node.state == 1) {
					window.switchOn(x, y, x + squareWidth - 1, y + squareWidth
							- 1, windowNumber);
				}
			} else {
				if (node.state == 1) {
					window.switchOn(x, y, x + squareWidth - 1, y
							+ rectangleWidth - 1, windowNumber);
				}
			}
			break;
		case DOUBLE:
			it.goLeft();
			if (isSquare) {
				xPlotTree(it, x, y, squareWidth, false, windowNumber, window);
			} else {
				xPlotTree(it, x, y, rectangleWidth, true, windowNumber, window);
			}
			it.goUp();
			it.goRight();
			if (isSquare) {
				xPlotTree(it, x, y + rectangleWidth, squareWidth, false,
						windowNumber, window);
			} else {
				xPlotTree(it, x + rectangleWidth, y, rectangleWidth, true,
						windowNumber, window);
			}
			it.goUp();
			break;
		default:
			break;
		}
	}

	/**
	 * Afficher this sous forme d'arbre dans une fenêtre externe.
	 * 
	 * @pre !this.isEmpty()
	 */
	public void plotTree() {
		System.out.println("Corrige plotTree");
		System.out.println("------------------");
		TreeFrame frame = new TreeFrame(this);
		frame.setVisible(true);
	}

	/**
	 * @pre !this.isEmpty()
	 * @return hauteur de this
	 */
	public int height() {
		System.out.println("Corrige : Height");
		System.out.println("-----------------");
		return xHeight(this.iterator());
	}
	protected static int xHeight(Iterator<NodeState> it) {
		NodeType type = it.nodeType();
		assert type == NodeType.LEAF || type == NodeType.DOUBLE : "l'arbre comporte des noeuds simples";
		int leftHeight = 0;
		int rightHeight = 0;
		switch (type) {
		case LEAF:
			return 0;
		case DOUBLE:
			it.goLeft();
			leftHeight = xHeight(it);
			it.goUp();
			it.goRight();
			rightHeight = xHeight(it);
			it.goUp();
		default: /* impossible */
		}
		return (leftHeight > rightHeight) ? leftHeight + 1 : rightHeight + 1;
	}

	/**
	 * @pre !this.isEmpty()
	 * @return nombre de noeuds de this
	 */
	public int numberOfNodes() {
		System.out.println("Corrige : numbreOfNodes");
		System.out.println("-----------------");
		return xNumberOfNodes(this.iterator());
	}
	public static int xNumberOfNodes(Iterator<NodeState> it) {
		NodeType type = it.nodeType();
		assert type == NodeType.LEAF || type == NodeType.DOUBLE : "l'arbre comporte des noeuds simples";
		assert (type != NodeType.SENTINEL) : "l'iterateur est sur le butoir";
		int number = 0;
		switch (type) {
		case LEAF:
			return 1;
		case DOUBLE:
			it.goLeft();
			number = xNumberOfNodes(it);
			it.goUp();
			it.goRight();
			number += xNumberOfNodes(it);
			it.goUp();
		default: /* impossible */
		}
		return number + 1;
	}

	////////////////////////////////////////
	// Méthodes demandées au compte-rendu //
	////////////////////////////////////////

	/**
	 * Teste si un pixel est allumé ou non
	 * @param x abscisse du point
	 * @param y ordonnée du point
	 * @pre !this.isEmpty()
	 * @return true, si le point (x, y) est allumé dans this, false sinon
	 */
	public boolean isPixelOn(int x, int y) {
		Iterator<NodeState> it = iterator();
		int curx = 128, cury = 128;
		for (int cpt=1; it.getValue() == NodeState.valueOf(2); ++cpt) {
			if (y < cury)
				it.goLeft();
			else
				it.goRight();
			if (x < curx)
				it.goLeft();
			else
				it.goRight();
			int step = 128 / (int)Math.pow(2, cpt);
			if (y == cury) cury += step;
			else cury += Integer.signum(y - cury) * step;
			if (x == curx) curx += step;
			else curx += Integer.signum(x - curx) * step;
		}
		return it.getValue() == NodeState.valueOf(1);
	}

	/**
	 * this devient identique à image2
	 * @param image2  image à copier
	 * @pre !image2.isEmpty()
	 */
	public void affect(Image image2) {
		Iterator<NodeState> it = iterator();
		if (!it.isEmpty())
			it.clear();
		xAffect(it, image2.iterator());
	}
	private void xAffect(Iterator<NodeState> it, Iterator<NodeState> it1) {
		NodeType otype = it1.nodeType();
		assert otype == NodeType.LEAF || otype == NodeType.DOUBLE : "l'arbre comporte des noeuds simples";
		switch (otype) {
		case LEAF:
			it.addValue(it1.getValue());
			break;
		case DOUBLE:
			it.addValue(NodeState.valueOf(2));
			it.goLeft(); it1.goLeft();
			xAffect(it, it1);
			it.goUp(); it1.goUp();
			it.goRight(); it1.goRight();
			xAffect(it, it1);
			it.goUp(); it1.goUp();
			break;
		}
	}

	/**
	 * this devient rotation de image2 à 180 degrés.
	 * 
	 * @param image2
	 *            image pour rotation
	 * @pre !image2.isEmpty()
	 */
	public void rotate180(Image image2) {
		Iterator<NodeState> it = iterator();
		if (!it.isEmpty())
			it.clear();
		xRotate180(it, image2.iterator());
	}
	private void xRotate180(Iterator<NodeState> it, Iterator<NodeState> it1) {
		NodeType otype = it1.nodeType();
		assert otype == NodeType.LEAF || otype == NodeType.DOUBLE : "l'arbre comporte des noeuds simples";
		switch (otype) {
		case LEAF:
			it.addValue(it1.getValue());
			break;
		case DOUBLE:
			it.addValue(NodeState.valueOf(2));
			it.goLeft(); it1.goRight();
			xRotate180(it, it1);
			it.goUp(); it1.goUp();
			it.goRight(); it1.goLeft();
			xRotate180(it, it1);
			it.goUp(); it1.goUp();
			break;
		}
	}

	/**
	 * this devient inverse vidéo de this, pixel par pixel.
	 * 
	 * @pre !image.isEmpty()
	 */
	public void videoInverse() { xVideoInverse(iterator()); }
	private void xVideoInverse(Iterator<NodeState> it) {
		NodeType type = it.nodeType();
		assert type == NodeType.LEAF || type == NodeType.DOUBLE : "l'arbre comporte des noeuds simples";
		switch (type) {
		case LEAF:
			int node = (it.getValue() == NodeState.valueOf(0)) ? 1 : 0;
			it.setValue(NodeState.valueOf(node));
			break;
		case DOUBLE:
			it.goLeft();
			xVideoInverse(it);
			it.goUp(); it.goRight();
			xVideoInverse(it);
			it.goUp();
			break;
		}
	}

	/**
	 * this devient image miroir vertical de image2.
	 * 
	 * @param image2
	 *            image à agrandir
	 * @pre !image2.isEmpty()
	 */
	public void mirrorV(Image image2) {
		Iterator<NodeState> it = iterator();
		if (!it.isEmpty())
			it.clear();
		xMirrorV(it, image2.iterator(), true);
	}
	private void xMirrorV(Iterator<NodeState> it, Iterator<NodeState> it1, boolean hor) {
		NodeType otype = it1.nodeType();
		assert otype == NodeType.LEAF || otype == NodeType.DOUBLE : "l'arbre comporte des noeuds simples";
		switch (otype) {
		case LEAF:
			it.addValue(it1.getValue());
			break;
		case DOUBLE:
			it.addValue(NodeState.valueOf(2));
			it.goLeft();
			if (hor) it1.goRight();
			else it1.goLeft();
			xMirrorV(it, it1, !hor);
			it.goUp(); it1.goUp();
			it.goRight();
			if (hor) it1.goLeft();
			else it1.goRight();
			xMirrorV(it, it1, !hor);
			it.goUp(); it1.goUp();
			break;
		}
	}

	/**
	 * Le quart supérieur gauche de this devient image2, le reste de this
	 * devient éteint.
	 * 
	 * @param image2
	 *            image à réduire
	 * @pre !image2.isEmpty()
	 */
	public void zoomOut(Image image2) {
		Iterator<NodeState> it = iterator();
		if (!it.isEmpty())
			it.clear();
		it.addValue(NodeState.valueOf(2));
		it.goLeft();
		it.addValue(NodeState.valueOf(2));
		it.goRight();
		it.addValue(NodeState.valueOf(0));
		it.goUp(); it.goUp(); it.goRight();
		it.addValue(NodeState.valueOf(0));
		it.goUp(); it.goLeft(); it.goLeft();
		xAffect(it, image2.iterator());
		xTrim(iterator(), 0, true);
		xClean(iterator());
	}
	private void xTrim(Iterator<NodeState> it, int depth, boolean hor) {
		NodeType type = it.nodeType();
		assert type == NodeType.LEAF || type == NodeType.DOUBLE : "l'arbre comporte des noeuds simples";
		if (depth >= 8) {
			double on = xNbOn(it);
			it.clear();
			it.addValue(NodeState.valueOf((on>=0.5) ? 1 : 0));
		} else if (type == NodeType.DOUBLE) {
			it.goLeft();
			xTrim(it, (hor) ? depth : depth+1, !hor);
			it.goUp(); it.goRight();
			xTrim(it, (hor) ? depth : depth+1, !hor);
			it.goUp();
		}
	}
	private double xNbOn(Iterator<NodeState> it) {
		NodeType type = it.nodeType();
		assert type == NodeType.LEAF || type == NodeType.DOUBLE : "l'arbre comporte des noeuds simples";
		double on = 0;
		switch (type) {
		case LEAF:
			on = (it.getValue() == NodeState.valueOf(1)) ? 1.0 : 0.0;
			break;
		case DOUBLE:
			it.goLeft();
			on = 0.5 * xNbOn(it);
			it.goUp(); it.goRight();
			on += 0.5 * xNbOn(it);
			it.goUp();
			break;
		}
		return on;
	}
	private int xClean(Iterator<NodeState> it) {
		NodeType type = it.nodeType();
		assert type == NodeType.LEAF || type == NodeType.DOUBLE : "l'arbre comporte des noeuds simples";
		switch (type) {
		case LEAF:
			return (it.getValue() == NodeState.valueOf(1)) ? 1 : 0;
		case DOUBLE:
			it.goLeft();
			int left = xClean(it);
			it.goUp(); it.goRight();
			int right = xClean(it);
			it.goUp();
			if (left == right) {
				if (left != 2) {
					it.clear();
					it.addValue(NodeState.valueOf(left));
				}
				return left;
			}
		}
		return 2;
	}

	/**
	 * this devient l'union de image2 et image3 au sens des pixels allumés.
	 * 
	 * @pre !image2.isEmpty() && !image3.isEmpty()
	 * 
	 * @param image2
	 * @param image3
	 */
	public void union(Image image2, Image image3) {
		Iterator<NodeState> it = iterator();
		if (!it.isEmpty())
			it.clear();
		xAffect(it, image2.iterator());
		xUnion(it, image3.iterator());
		xClean(it);
	}
	private void xUnion(Iterator<NodeState> it, Iterator<NodeState> it1) {
		NodeType type = it.nodeType(), ot = it1.nodeType();
		assert type == NodeType.LEAF || type == NodeType.DOUBLE : "l'arbre 1 comporte des noeuds simples";
		assert ot == NodeType.LEAF || ot == NodeType.DOUBLE : "l'arbre 2 comporte des noeuds simples";
		switch (type) {
		case LEAF:
			if (it.getValue() == NodeState.valueOf(0))
				xAffect(it, it1);
			break;
		case DOUBLE:
			switch (ot) {
			case LEAF:
				if (it1.getValue() == NodeState.valueOf(1)) {
					it.clear();
					it.addValue(it1.getValue());
				}
				break;
			case DOUBLE:
				it.goLeft(); it1.goLeft();
				xUnion(it, it1);
				it.goUp(); it1.goUp();
				it.goRight(); it1.goRight();
				xUnion(it, it1);
				it.goUp(); it1.goUp();
				break;
			}
			break;
		}
	}

	/**
	 * Attention : cette fonction n'utilise ni la commande isPixelOn ni la
	 * méthode table.state().s
	 * 
	 * @return true si tous les points de la forme (x, x) (avec 0 <= x <= 255)
	 *         sont allumés dans this, false sinon
	 */
	public boolean testDiagonal() { return xDiagonal(iterator(), true, true); }
	private boolean xDiagonal(Iterator<NodeState> it, boolean hor, boolean top) {
		NodeType type = it.nodeType();
		assert type == NodeType.LEAF || type == NodeType.DOUBLE : "l'arbre comporte des noeuds simples";
		switch (type) {
		case LEAF:
			return (it.getValue() == NodeState.valueOf(1));
		case DOUBLE:
			boolean diag = true;
			it.goLeft();
			if (hor)
				diag &= xDiagonal(it, !hor, true);
			else
				diag &= (top) ? xDiagonal(it, !hor, true) : true;
			it.goUp(); it.goRight();
			if (hor)
				diag &= xDiagonal(it, !hor, false);
			else
				diag &= (top) ? true : xDiagonal(it, !hor, true);
			it.goUp();
			return diag;
		}
		return false;
	}

	/////////////////////
	// Autres méthodes //
	/////////////////////

	/**
	 * this devient rotation de image2 à 90 degrés dans le sens des aiguilles
	 * d'une montre.
	 * 
	 * @param image2
	 *            image pour rotation
	 * @pre !image2.isEmpty()
	 */
	public void rotate90(Image image2) { }

	/**
	 * this devient image miroir horizontal de image2.
	 * 
	 * @param image2
	 *            image à agrandir
	 * @pre !image2.isEmpty()
	 */
	public void mirrorH(Image image2) { }

	/**
	 * this devient quart supérieur gauche de image2.
	 * 
	 * @param image2
	 *            image à agrandir
	 * 
	 * @pre !image2.isEmpty()
	 */
	public void zoomIn(Image image2) { }

	/**
	 * this devient l'intersection de image2 et image3 au sens des pixels
	 * allumés.
	 * 
	 * @pre !image2.isEmpty() && !image3.isEmpty()
	 * 
	 * @param image2
	 * @param image3
	 */
	public void intersection(Image image2, Image image3) { }

	/**
	 * @param x1
	 *            abscisse du premier point
	 * @param y1
	 *            ordonnée du premier point
	 * @param x2
	 *            abscisse du deuxième point
	 * @param y2
	 *            ordonnée du deuxième point
	 * @return true si les deux points (x1, y1) et (x2, y2) sont représentés par
	 *         la même feuille de this, false sinon
	 */
	public boolean sameLeaf(int x1, int y1, int x2, int y2) { return false; }

	/**
	 * @param image2
	 *            autre image
	 * @return true si this est incluse dans image2 au sens des pixels allumés
	 *         false sinon
	 */
	public boolean isIncludedIn(Image image2) { return false; }

}
