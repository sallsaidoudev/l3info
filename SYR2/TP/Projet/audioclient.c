#include <errno.h>
#include <netdb.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include "audio.h"
#include "filters.h"

#define HLEN sizeof(struct sockaddr_in) // shortcut for sendto calls
#define BUFSIZE 8192 // datagram max size
#define PORT "4242" // keep coherence with audioserver.c

int want_quit = 0;
int want_pause = 0;

// Shortcut to die on an error
void die(char *s) {
	perror(s);
	exit(1);
}

// Signal handler to manage quit from play, and maybe pause
void quit_handler(int signum) {
	if (signum == SIGINT)
		want_quit = 1;
	else if (signum == SIGTSTP)
		want_pause = 1;
}

/* Audio streaming client
 * Usage: audioclient <host> <file>
 * This program implements the client part of the audio streaming protocol
 * described in protocol.pdf. It request the given file to the given host, and
 * if found begins playing it.
 * TODO: buffering?
 */
int main(int argc, char *argv[]) {
	struct timeval to;
	struct sigaction handler;
	struct addrinfo hints, *resol;
	int err, sockfd, audio, s_rate, s_size, chans, s_no = 0, alen;
	char msg[BUFSIZE], abuf[BUFSIZE-4-2*sizeof(int)];

	srand(42); // Packet loss simulation
	if (argc != 3) {
		fprintf(stderr, "Usage: audioclient <host> <file>\n");
		exit(1);
	}
	// Resolve provided hostname and open socket
	hints.ai_family = AF_INET;
	hints.ai_socktype = SOCK_DGRAM;
	hints.ai_protocol = 0;
	hints.ai_flags = 0;
	if ((err = getaddrinfo(argv[1], PORT, &hints, &resol)) < 0) {
		fprintf(stderr, "Can't resolve hostname: %s\n", gai_strerror(err));
		exit(1);
	}
	if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0)
		die("socket");
	// Set a handler for ^C
	handler.sa_handler = quit_handler;
	sigemptyset(&handler.sa_mask);
	handler.sa_flags = 0;
	if (sigaction(SIGINT, &handler, NULL) < 0)
		die("sigaction");
	if (sigaction(SIGTSTP, &handler, NULL) < 0)
		die("sigaction");
	// Send a GET[filename]
	strncpy(msg, "GET\0", 4);
	strncat(msg, argv[2], BUFSIZE-4);
	if (sendto(sockfd, msg, strlen(msg)+1, 0, resol->ai_addr, HLEN) < 0)
		die("sendto");
	// Answer is either ERR or FND[init]
	if (recvfrom(sockfd, msg, BUFSIZE, 0, NULL, NULL) < 0)
		die("recvfrom");
	if (strncmp(msg, "ERR", 3) == 0) {
		fprintf(stderr, "Server can't provide requested file (it doesn't "\
				"exist or server is crowded), try again.\n\n\n");
		exit(1);
	}
	if (strncmp(msg, "FND", 3) != 0) { // Enforcing protocol
		fprintf(stderr, "Expecting FND, got %s\n", msg);
		exit(1);
	}
	// If found, extract init parameters and init the audio output
	printf("Opening audio device...\n");
	memcpy(&s_rate, msg+3, sizeof(int));
	memcpy(&s_size, msg+3+sizeof(int), sizeof(int));
	memcpy(&chans, msg+3+2*sizeof(int), sizeof(int));
	if ((audio = aud_writeinit(s_rate, s_size, chans)) < 0)
		die("aud_writeinit");
	// Reading loop
	printf("\nReady to play file ; while listening, press ^C to quit.\n");
	to.tv_sec = 1; // Timeout is set to 1 sec
	to.tv_usec = 0;
	setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO,
			(char *) &to, sizeof(struct timeval));
	while (1) { // This loop depends on the server's answers
		// If asked, send a QUT request (see signal handler)
		if (want_pause) {
			printf("Pause.\n");
			char input[30];
			fgets(input, 29, stdin);
			want_pause = 0;
			continue;
		}
		if (want_quit) {
			strncpy(msg, "QUT", 3);
			if (sendto(sockfd, msg, 3, 0, resol->ai_addr, HLEN) < 0)
				die("sendto");
		} else { // Send a PLS[sample_no]
			strncpy(msg, "PLS", 3);
			memcpy(msg+3, &s_no, sizeof(int));
			if (sendto(sockfd, msg, 3+sizeof(int), 0, resol->ai_addr, HLEN) < 0)
				die("sendto");
		}
		// If timeout, loop must continue
		if (recvfrom(sockfd, msg, BUFSIZE, 0, NULL, NULL) < 0) {
			if (errno == EAGAIN || errno == EWOULDBLOCK) {
				fprintf(stderr, "Timeout from server, trying to recover...\n");
				continue;
			}
			die("recvfrom");
		}
		// Else answer is either EOF
		if (strncmp(msg, "EOF", 3) == 0) {
			printf("End of playing, hope you enjoyed it!\n\n\n");
			break;
		}
		if (strncmp(msg, "SMP", 3) != 0) { // or a sample
			fprintf(stderr, "Expecting SMP, got %s\n", msg);
			exit(1);
		}
		// Extract data from SMP[s_no][alen][DATA]
		memcpy(&alen, msg+3+sizeof(int), sizeof(int));
		if (alen > sizeof(abuf)) alen = sizeof(abuf); // Never trust...
		memcpy(abuf, msg+3+2*sizeof(int), alen);
		// Play!
		char *more = NULL;
		int mlen;
		slow(abuf, &alen, more, &mlen);
		write(audio, abuf, alen);
		write(audio, more, mlen);
		free(more);
		s_no++;
	}

	freeaddrinfo(resol);
	close(audio);
	close(sockfd);
	return 0;
}
