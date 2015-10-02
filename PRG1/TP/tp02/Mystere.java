import java.lang.*;

public class Mystere {
	
	public static boolean[] digits = new boolean[10];

	public static boolean found() {
		boolean all_true = true;
		for (int i=0; i<10; ++i) all_true &= digits[i];
		return all_true;
	}

	public static boolean write_digits(int n) {
		while (n != 0) {
			if (digits[n%10])
				return false;
			digits[n%10] = true;
			n /= 10;
		}
		return true;
	}

	public static void main(String[] args) {
		int n = 0;
		while (!found()) {
			++n;
			for (int i=0; i<10; ++i)
				digits[i] = false;
			if (write_digits(n*n))
				write_digits(n*n*n);
		}
		System.out.println("Le nombre mystère est... suspense... " + n + " !");
	}

}
