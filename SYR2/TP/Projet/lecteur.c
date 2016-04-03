#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#include "audio.h"

int main(int argc, char *argv[]) {
	char *path, buf[1024];
	int src, s_rate, s_size, chans, audio;

	if (argc < 2) {
		fprintf(stderr, "Usage: lecteur <file>\n");
		return -1;
	}

	path = argv[1];
	if ((src = aud_readinit(path, &s_rate, &s_size, &chans)) < 0) {
		perror("Error trying to open file");
		return -1;
	}
	if ((audio = aud_writeinit(s_rate, s_size, chans)) < 0) {
		perror("Error trying to open audio output");
		return -1;
	}

	int r_size;
	while ((r_size = read(src, buf, sizeof(buf))) != 0)
		write(audio, buf, r_size);
	
	return 0;
}
