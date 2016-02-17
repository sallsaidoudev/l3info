#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>

int retroprint(int file) {
	char c;
	int rd = read(file, &c, 1);
	if (rd != 1)
		return rd;
	retroprint(file);
	write(0, &c, 1);
}

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
	// Reading file end to start
	retroprint(file);
	return 0;
}
