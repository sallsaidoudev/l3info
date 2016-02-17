#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>

typedef struct fchunk {
	struct fchunk *prev;
	char buf[1024];
} chunk;

int main(int argc, char *argv[]) {
	int file = -1; // file descriptor
	// Opening file
	if (argc != 2) {
		fprintf(stderr, "Usage: reverse <file>\n");
		exit(1);
	}
	file = open(argv[1], O_RDONLY);
	if (file < 0) {
		fprintf(stderr, "Error: can't open file %s\n", argv[1]);
		exit(1);
	}
	// Reading file
	chunk *prev, *c = NULL;
	int rd = 1024;
	while (rd == 1024) {
		prev = c;
		c = (chunk *)malloc(sizeof(chunk));
		c->prev = prev;
		rd = read(file, c->buf, 1024);
	}
	// Reverse writing
	char rev[1024];
	int i;
	for (i=0; i<rd; i++)
		rev[i] = c->buf[rd - (i+1)];
	write(0, rev, rd);
	free(c);
	c = c->prev;
	while (c != NULL) {
		for (i=0; i<1024; i++)
			rev[i] = c->buf[1024 - (i+1)];
		write(0, rev, 1024);
		free(c);
		c = c->prev;
	}
	return 0;
}
