#include <stdio.h>

int heures = 23, minutes = 59, secondes = 59;

void afficher_heure() {
	printf("Il est %02d:%02d:%02d.\n", heures, minutes, secondes);
}

void tic() {
	if(++secondes == 60) {
		secondes = 0;
		if(++minutes == 60) {
			minutes = 0;
			if(++heures == 24) heures = 0;
		}
	}
}

void etablir_heure(int h, int m, int s) {
	heures = h; minutes = m; secondes = s;
}

int main(int argc, char* argv[]) {
	afficher_heure();
	tic();
	afficher_heure();
	etablir_heure(13, 37, 42);
	afficher_heure();

    return 0;
}
