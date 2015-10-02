#include <stdio.h>
#include <stdlib.h>
#include "pile.h"

int main(int argc, char* argv[]) {
	while(1) {
		char mot[30];
		if (scanf("%s", mot) == EOF) break;
		empiler(mot);
	}
	while(!pilevide()) {
		char* lu = depiler();
		printf("%s ", lu);
	}

	return 0;
}
