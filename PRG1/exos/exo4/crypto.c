#include <stdio.h>

unsigned char texte[100] = "Ceci est un texte crypté.";

void crypter_char(int cle, unsigned char* c) {
	if(65 <= *c && *c <= 90) {
		*c += cle;
		if(*c > 90) *c = 64 + (*c % 90);
	} else if(97 <= *c && *c <= 122) {
		*c += cle;
		if(*c > 122) *c = 96 + (*c % 122);
	}
}

void crypter_txt(int cle, unsigned char* txt) {
	int i;
	for(i=0; txt[i] != '\0'; i++)
		crypter_char(cle, txt+i);
}

int main(int argc, char* argv) {
	crypter_txt(12, texte);
	printf("%s\n", texte);

	return 0;
}
