#include <arpa/inet.h>
#include <errno.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include "audio.h"

#define HLEN sizeof(struct sockaddr_in) // shortcut for sendto calls
#define BUFSIZE 8192 // datagram max size
#define PORT 4242 // keep coherence with audioclient.c

// Shortcut to die on an error
void die(char *s) {
	perror(s);
	exit(1);
}

/* Audio streaming server
 * Usage: audioclient
 * This program implements the server part of the audio streaming protocol
 * described in protocol.pdf. It loops waiting for a file request, then if this
 * file is available it streams it to the client.
 * TODO: multi-clients, buffering?
 */
int main(int argc, char *argv[]) {
	socklen_t flen = sizeof(struct sockaddr_in);
	struct sockaddr_in host, from;
	struct timeval to;
	int sockfd, src, s_rate, s_size, chans,
		sample_no, req_no, r_size, at_end;
	char msg[BUFSIZE], abuf[BUFSIZE-3-2*sizeof(int)], *path;;

	// srand(42); // Packet loss simulation
	// Create and bind socket
	if ((sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0)
		die("socket");
	host.sin_family = AF_INET;
	host.sin_port = htons(PORT);
	host.sin_addr.s_addr = htonl(INADDR_ANY);
	if (bind(sockfd, (struct sockaddr *) &host, sizeof(struct sockaddr_in)) < 0)
		die("bind");

	// Server loop
	printf("Server listening on port %d.\n", PORT);
	while (1) {
		// Receive a GET
		if (recvfrom(sockfd, msg, BUFSIZE, 0, (struct sockaddr *) &from, &flen) < 0)
			die("recvfrom");
		if (strncmp(msg, "GET", 3) != 0) {
			fprintf(stderr, "Expecting a GET request but got %s\n", msg);
			return -1;
		}
		// Try to open requested file
		path = msg+3;
		printf("Client %s requested file %s.\n", inet_ntoa(from.sin_addr), path);
		if ((src = aud_readinit(path, &s_rate, &s_size, &chans)) < 0) {
			printf("File %s not found.\n", path);
			strncpy(msg, "ERR\0", 4); // Send ERR
			if (sendto(sockfd, msg, strlen(msg)+1, 0, (struct sockaddr *) &from, flen) < 0)
				die("sendto");
			continue; // Get back to waiting a GET
		} else { // If file is open, send FND[init]
			printf("Streaming file %s to %s...\n", path, inet_ntoa(from.sin_addr));
			strncpy(msg, "FND", 3); // [init] gets the data from aud_readinit
			memcpy(msg+3, &s_rate, sizeof(int));
			memcpy(msg+3+sizeof(int), &s_size, sizeof(int));
			memcpy(msg+3+2*sizeof(int), &chans, sizeof(int));
			if (sendto(sockfd, msg, 3*(sizeof(int)+1), 0, (struct sockaddr *) &from, flen) < 0)
				die("sendto");
		}
		// Streaming loop
		sample_no = 0;
		at_end = 0;
		to.tv_sec = 1;
		to.tv_usec = 0;
		setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO, (char *) &to, sizeof(struct timeval));
		while (1) {
			// Receive a PLS[sample_no] (with timeout)
			if (recvfrom(sockfd, msg, BUFSIZE, 0, (struct sockaddr *) &from, &flen) < 0) {
				if (errno == EAGAIN || errno == EWOULDBLOCK) {
					printf("Client lost.\n");
					to.tv_sec = 0; // No timeout goin' back to the server loop
					setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO, (char *) &to, sizeof(struct timeval));
					continue;
				}
				die("recvfrom");
			}
			if (strncmp(msg, "QUT", 3) == 0) {
				printf("Client quit.\n");
				break;
			}
			if (strncmp(msg, "PLS", 3) != 0) {
				fprintf(stderr, "Expecting a PLS request but got %s\n", msg);
				return -1;
			}
			// Extract requested sample n°
			memcpy(&req_no, msg+3, sizeof(int));
			if (req_no == sample_no) { // Read the next sample if needed
				if (at_end) break; // If last sample has been streamed
				if ((r_size = read(src, abuf, sizeof(abuf))) < 0)
					die("read");
				if (r_size < sizeof(abuf)) at_end = 1; // If we're at EOF
				sample_no++; // Keep track of the sample n°
			}
			// Send SMP[s_no][s_size][DATA]
			strncpy(msg, "SMP", 3);
			memcpy(msg+3, &sample_no, sizeof(int));
			memcpy(msg+3+sizeof(int), &r_size, sizeof(int));
			memcpy(msg+3+2*sizeof(int), abuf, r_size);
			// if (rand()%100<1) continue; // Packet loss simulation
			if (sendto(sockfd, msg, 3+2*sizeof(int)+r_size, 0, (struct sockaddr *) &from, flen) < 0)
				die("sendto");
		}
		// Send EOF
		strncpy(msg, "EOF", 3);
		if (sendto(sockfd, msg, 3, 0, (struct sockaddr *) &from, flen) < 0)
			die("sendto");
		printf("End of streaming to %s.\n", inet_ntoa(from.sin_addr));
		to.tv_sec = 0; // No timeout goin' back to the server loop
		setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO, (char *) &to, sizeof(struct timeval));
		close(src);
	}

	close(sockfd);
	return 0;
}
