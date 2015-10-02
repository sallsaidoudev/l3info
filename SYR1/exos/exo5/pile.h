typedef struct ch_pile {
	char** str;
	struct ch_pile* next;
} chaine;

int pilevide();
int empiler(char* ch);
char* depiler();
