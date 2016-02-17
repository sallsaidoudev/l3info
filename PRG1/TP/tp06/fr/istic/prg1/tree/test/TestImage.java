package fr.istic.prg1.tree.test;

import java.io.FileInputStream;
import java.io.FileNotFoundException;

import org.junit.Test;

import fr.istic.prg1.tree.Image;
import fr.istic.prg1.tree.NodeState;
import fr.istic.prg1.tree.util.Iterator;
import static org.junit.Assert.assertTrue;

/**
 * @author MickaÃ«l Foursov <foursov@univ-rennes1.fr>
 * @version 2.0
 * @since 2015-06-15
 * 
 *        Classe pour les tests unitaires de la classe Image
 */
public class TestImage {

	/**
	 * @param image1
	 *            premiÃ¨re image
	 * @param image2
	 *            deuxiÃ¨me image
	 * @return true si les deux images sont identiques comme arbres, false sinon
	 */
	public static boolean compareImages(Image image1, Image image2) {
		Iterator<NodeState> it1 = image1.iterator();
		Iterator<NodeState> it2 = image2.iterator();
		return compareImagesAux(it1, it2);
	}

	private static boolean compareImagesAux(Iterator<NodeState> it1,
			Iterator<NodeState> it2) {
		if (it1.isEmpty()) {
			return it2.isEmpty();
		}
		if (it2.isEmpty()) {
			return false;
		}
		NodeState n1 = it1.getValue();
		NodeState n2 = it2.getValue();
		if (n1.state != n2.state) {
			return false;
		}
		if (n1.state == 1 || n1.state == 0) {
			return true;
		}
		it1.goLeft();
		it2.goLeft();
		boolean bool = compareImagesAux(it1, it2);
		it1.goUp();
		it2.goUp();
		if (bool) {
			it1.goRight();
			it2.goRight();
			bool = bool && compareImagesAux(it1, it2);
			it1.goUp();
			it2.goUp();
		}
		return bool;
	}

	/**
	 * La fonction auxiliaire n'est probablement pas trÃ¨s lisible...
	 * 
	 * @param image
	 *            image Ã  tester
	 * @return true si l'arbre satisfait les spÃ©cifications, false sinon
	 */
	public static int testCorrectness(Image image) {
		Iterator<NodeState> it = image.iterator();
		return testCorrectnessAux(it);
	}

	private static int testCorrectnessAux(Iterator<NodeState> it) {
		// 0 est la reponse correcte (pas d'erreurs)
		// les autres erreurs sont numerotees
		if (it.isEmpty()) {
			return 0;
		}
		NodeState n = it.getValue();
		if (n.state == 2) {
			int tmp = 0;
			it.goLeft();
			if (it.isEmpty()) {
				it.goUp();
				return 1; // 2 a fils gauche vide
			}
			NodeState nLeft = it.getValue();
			if (nLeft.state == 2) {
				tmp = testCorrectnessAux(it);
			}
			it.goUp();
			if (nLeft.state == 2 && tmp > 0) {
				return tmp;
			}
			it.goRight();
			if (it.isEmpty()) {
				it.goUp();
				return 2; // 2 a fils droit vide
			}
			NodeState nRight = it.getValue();
			if (nRight.state == 2) {
				tmp = tmp + testCorrectnessAux(it);
			}
			it.goUp();
			if (nLeft.state != 2 && nLeft.state == nRight.state) {
				return 3; // 2 a deux fils identiques
			} else if (nLeft.state == 2) {
				return tmp;
			} else {
				return 0;
			}
		} else {
			it.goLeft();
			if (!it.isEmpty()) {
				it.goUp();
				return 4; // 0 ou 1 a fils gauche non vide
			}
			it.goUp();
			it.goRight();
			if (!it.isEmpty()) {
				it.goUp();
				return 5; // 0 ou 1 a fils droit non vide
			}
			it.goUp();
			return 0;
		}
	}

	/**
	 * @param fileName
	 *            nom du fichier Ã  lire
	 * @return Image crÃ©Ã©e Ã  partir du fichier
	 */
	public static Image readFile(String fileName) {
		Image image = new Image();
		try {
			image.xCreateTreeFromFile(new FileInputStream(fileName));
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
		return (Image) image;
	}

	@Test
	public void testPixel1() {
		Image image1 = readFile("a1.arb");
		boolean result = image1.isPixelOn(0, 128);
		assertTrue("pixel a1 0 128", result);

		result = image1.isPixelOn(128, 0);
		assertTrue("pixel a1 128 0", !result);

		result = image1.isPixelOn(192, 128);
		assertTrue("pixel a1 192 128", !result);

		result = image1.isPixelOn(128, 192);
		assertTrue("pixel a1 128 192", !result);

		result = image1.isPixelOn(255, 192);
		assertTrue("pixel a1 255 192", !result);

		result = image1.isPixelOn(192, 255);
		assertTrue("pixel a1 192 255", !result);
	}

	@Test
	public void testPixel2() {
		Image image1 = readFile("a2.arb");
		boolean result = image1.isPixelOn(0, 128);

		assertTrue("pixel a2 0 128", !result);

		result = image1.isPixelOn(128, 0);
		assertTrue("pixel a2 128 0", !result);

		result = image1.isPixelOn(192, 128);
		assertTrue("pixel a2 192 128", !result);

		result = image1.isPixelOn(128, 192);
		assertTrue("pixel a2 128 192", result);

		result = image1.isPixelOn(255, 192);
		assertTrue("pixel a2 255 192", !result);

		result = image1.isPixelOn(192, 255);
		assertTrue("pixel a2 192 255", !result);

		result = image1.isPixelOn(32, 128);
		assertTrue("pixel a2 32 128", result);
	}

	@Test
	public void testPixel3() {
		Image image = readFile("a2.arb");
		boolean bool1 = image.isPixelOn(213, 95);
		boolean bool2 = image.isPixelOn(97, 97);
		boolean bool3 = image.isPixelOn(5, 249);
		boolean bool4 = image.isPixelOn(249, 5);
		boolean bool5 = image.isPixelOn(5, 5);
		assertTrue("isPixelOn test 3", !bool1 && bool2 && !bool3 && !bool4
				&& !bool5);
	}

	@Test
	public void testUnion1() {
		Image image1 = readFile("a1.arb");
		Image image2 = readFile("a2.arb");
		Image image3 = new Image();
		Image image4 = readFile("test-u12.arb");
		image3.union(image1, image2);
		assertTrue("union a1 et a2: arbre conforme ?",
				testCorrectness(image3) == 0);
		assertTrue("union a1 et a2", compareImages(image3, image4));
	}

	@Test
	public void testUnion2() {
		Image image1 = readFile("a1.arb");
		Image image2 = readFile("a5.arb");
		Image image3 = new Image();
		Image image4 = readFile("test-u15.arb");
		image3.union(image1, image2);
		assertTrue("union a1 et a5: arbre conforme ?",
				testCorrectness(image3) == 0);
		assertTrue("union a1 et a5", compareImages(image3, image4));
	}

	@Test
	public void testIntersection1() {
		Image image1 = readFile("a1.arb");
		Image image2 = readFile("a2.arb");
		Image image3 = new Image();
		Image image4 = readFile("test-i12.arb");
		image3.intersection(image1, image2);
		assertTrue("intersection a1 et a2: arbre conforme ?",
				testCorrectness(image3) == 0);
		assertTrue("intersection a1 et a2", compareImages(image3, image4));
	}

	@Test
	public void testIntersection2() {
		Image image1 = readFile("a2.arb");
		Image image2 = readFile("a6.arb");
		Image image3 = new Image();
		Image image4 = readFile("test-i26.arb");
		image3.intersection(image1, image2);
		assertTrue("intersection a2 et a6 : arbre conforme ?",
				testCorrectness(image3) == 0);
		assertTrue("intersection a2 et a6", compareImages(image3, image4));
	}

	@Test
	public void testAffect1() {
		Image image1 = readFile("a1.arb");
		Image image2 = new Image();
		image2.affect(image1);
		assertTrue("affect a1", compareImages(image1, image2));
	}

	@Test
	public void testAffect2() {
		Image image1 = readFile("a1.arb");
		Image image2 = readFile("a2.arb");
		image2.affect(image1);
		assertTrue("affect a1", compareImages(image1, image2));
	}

	@Test
	public void testRotation() {
		Image image1 = readFile("a1.arb");
		Image image2 = new Image();
		Image image3 = readFile("test-r1.arb");
		image2.rotate180(image1);
		assertTrue("rotation a1", compareImages(image2, image3));
	}

	@Test
	public void testVideoInverse() {
		Image image1 = readFile("a2.arb");
		Image image2 = readFile("test-i2.arb");
		image1.videoInverse();
		assertTrue("videoInverse a2", compareImages(image1, image2));
	}

	// @Test
	// Fonction rotate90() n'est pas demandée pour le contrôle de TP
	public void testRotation90() {
		Image image1 = readFile("cartoon.arb");
		Image image2 = new Image();
		Image image3 = readFile("cartoon90.arb");
		image2.rotate90(image1);
		assertTrue("rotate90 cartoon", compareImages(image2, image3));
	}

	@Test
	public void testMirrorH() {
		Image image1 = readFile("cartoon.arb");
		Image image2 = new Image();
		Image image3 = readFile("cartoonh.arb");
		image2.mirrorH(image1);
		assertTrue("mirrorH cartoon", compareImages(image2, image3));
	}

	@Test
	public void testMirrorV() {
		Image image1 = readFile("cartoon.arb");
		Image image2 = new Image();
		Image image3 = readFile("cartoonv.arb");
		image2.mirrorV(image1);
		assertTrue("mirrorV cartoon", compareImages(image2, image3));
	}

	@Test
	public void testZoomIn() {
		Image image1 = readFile("cartoon.arb");
		Image image2 = new Image();
		Image image3 = readFile("cartoonin.arb");
		image2.zoomIn(image1);
		assertTrue("zoomIn cartoon", compareImages(image2, image3));
	}

	@Test
	public void testZoomOut() {
		Image image1 = readFile("cartoon.arb");
		Image image2 = new Image();
		Image image3 = readFile("cartoonout.arb");
		image2.zoomOut(image1);
		assertTrue("zoomOut cartoon", compareImages(image2, image3));
	}

	@Test
	public void testDiagonal1() {
		Image image = readFile("d2.arb");
		boolean bool = image.testDiagonal();
		assertTrue("diagonal d2", bool);
	}

	@Test
	public void testDiagonal2() {
		Image image = readFile("d3.arb");
		boolean bool = image.testDiagonal();
		assertTrue("diagonal d3", !bool);
	}

	@Test
	public void testDiagonal3() {
		Image image = readFile("a5.arb");
		boolean bool = image.testDiagonal();
		assertTrue("diagonal a5", !bool);
	}

	@Test
	public void testDiagonal4() {
		Image image = readFile("d4.arb");
		boolean bool = image.testDiagonal();
		assertTrue("diagonal d4", bool);
	}

	@Test
	public void testDiagonal5() {
		Image image = readFile("d7.arb");
		boolean bool = image.testDiagonal();
		assertTrue("diagonal d7", !bool);
	}

	@Test
	public void testDiagonal6() {
		Image image = readFile("d8.arb");
		boolean bool = image.testDiagonal();
		assertTrue("diagonal d8", !bool);
	}

	@Test
	public void testInclude1() {
		Image image1 = readFile("a2.arb");
		Image image2 = readFile("a6.arb");
		boolean bool = image1.isIncludedIn(image2);
		assertTrue("inclusion : a2 in a6", !bool);
	}

	@Test
	public void testInclude2() {
		Image image1 = readFile("a8.arb");
		Image image2 = readFile("a6.arb");
		boolean bool = image1.isIncludedIn(image2);
		assertTrue("inclusion : a8 in a6", bool);
	}

	@Test
	public void testInclude3() {
		Image image1 = readFile("a8.arb");
		Image image2 = readFile("a6.arb");
		boolean bool = image2.isIncludedIn(image1);
		assertTrue("inclusion : a6 in a8", !bool);
	}

	@Test
	public void testInclude4() {
		Image image1 = readFile("a1.arb");
		Image image2 = readFile("a4.arb");
		boolean bool = image1.isIncludedIn(image2);
		assertTrue("inclusion : a1 in a4", !bool);
	}

	@Test
	public void testSameLeaf1() {
		Image image1 = readFile("a5.arb");
		boolean result = image1.sameLeaf(0, 0, 1, 1);
		assertTrue("sameLeaf a5 0 0 1 1", result);

		result = image1.sameLeaf(255, 255, 254, 254);
		assertTrue("sameLeaf a5 255 255 254 254", !result);

		result = image1.sameLeaf(253, 253, 254, 254);
		assertTrue("sameLeaf a5 253 253 254 254", !result);

		result = image1.sameLeaf(252, 252, 253, 253);
		assertTrue("sameLeaf a5 252 252 253 253", result);

		result = image1.sameLeaf(250, 128, 128, 250);
		assertTrue("sameLeaf a5 250 128 128 250", !result);

		result = image1.sameLeaf(128, 192, 191, 255);
		assertTrue("sameLeaf a5 128 192 191 255", result);
	}

	@Test
	public void testSameLeaf2() {
		Image image1 = readFile("a2.arb");
		boolean result = image1.sameLeaf(64, 64, 127, 127);
		assertTrue("sameLeaf a2 64 64 127 127", result);

		result = image1.sameLeaf(127, 191, 128, 192);
		assertTrue("sameLeaf a2 127 191 128 192", !result);

		result = image1.sameLeaf(128, 191, 128, 192);
		assertTrue("sameLeaf a2 128 191 128 192", !result);

		result = image1.sameLeaf(127, 192, 128, 192);
		assertTrue("sameLeaf a2 127 192 128 192", !result);

		result = image1.sameLeaf(129, 193, 128, 192);
		assertTrue("sameLeaf a2 129 193 128 192", result);
	}
}