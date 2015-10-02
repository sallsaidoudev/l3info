#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "pile.h"

chaine* sommet = NULL;

static chaine* creer_chaine(char ch[]) {
    chaine* new_ch = malloc(sizeof(chaine));
    if (new_ch != NULL) {
        new_ch->str = &ch;
        new_ch->next = NULL;
    }
    return new_ch;
}

int pilevide() {
	return sommet == NULL;
}

int empiler(char* ch) {
	chaine* new_ch = creer_chaine(ch);
	if (new_ch == NULL)
		return -1;
	new_ch->next = sommet;
	sommet = new_ch;
	return 0;
}

char* depiler() {
	if (pilevide())
		return NULL;
	chaine* s = sommet;
	char* str = *(s->str);
	sommet = s->next;
	free(s);
	return str;
}
