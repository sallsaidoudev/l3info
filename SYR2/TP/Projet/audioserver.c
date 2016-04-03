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
#define MAXCLIENTS 64 // max number of clients the server can accept

// Shortcut to die on an error
void die(char *s) {
	perror(s);
	exit(1);
}

struct status {
	char client[16], abuf[BUFSIZE-4-2*sizeof(int)];
	int src, sample_no, dead, alen;
};

int get_id_or_add(struct sockaddr_in c, struct status *tab, int *size) {
	int i;
	char *addr = inet_ntoa(c.sin_addr);
	for (i=0; i<*size; i++)
		if (strncmp(tab[i].client, addr, strlen(addr)) == 0) return i;
	if (i < MAXCLIENTS) {
		strncpy(tab[i].client, addr, strlen(addr)+1);
		tab[i].src = -1;
		tab[i].sample_no = 0;
		tab[i].dead = 0;
		(*size)++;
		return i;
	}
	return -1;
}

int serve(struct status *c, char *msg, int *mlen) {
	if (strncmp(msg, "GET", 3) == 0) {
		int s_rate, s_size, chans;
		char *path = msg+3; // Extract path from request
		printf("%s: Client requested file %s.\n", c->client, path);
		if ((c->src = aud_readinit(path, &s_rate, &s_size, &chans)) < 0) {
			printf("%s: File %s not found.\n", c->client, path);
			strncpy(msg, "ERR", 3); // If not found send ERR
			*mlen = 3;
		} else { // If file is open, send FND[init]
			printf("%s: Streaming file %s...\n", c->client, path);
			strncpy(msg, "FND", 3); // [init] gets the data from aud_readinit
			memcpy(msg+3, &s_rate, sizeof(int));
			memcpy(msg+3+sizeof(int), &s_size, sizeof(int));
			memcpy(msg+3+2*sizeof(int), &chans, sizeof(int));
			*mlen = 3*(sizeof(int)+1);
		}
		return 0;
	}
	if (strncmp(msg, "PLS", 3) == 0) {
		int req_no;
		if (c->src < 0) return -1;
		// Extract requested sample n°
		memcpy(&req_no, msg+3, sizeof(int));
		if (req_no == c->sample_no) { // Read the next sample if needed
			if ((c->alen = read(c->src, c->abuf, sizeof(c->abuf))) < 0)
				die("read");
			if (c->alen == 0) { // If we're at EOF
				printf("%s: End of streaming.\n", c->client);
				c->dead = 1;
				strncpy(msg, "EOF", 3);
				*mlen = 3;
				return 0;
			}
			c->sample_no++; // Keep track of the sample n°
		}
		// Send SMP[s_no][s_size][DATA]
		strncpy(msg, "SMP", 3);
		memcpy(msg+3, &c->sample_no, sizeof(int));
		memcpy(msg+3+sizeof(int), &c->alen, sizeof(int));
		memcpy(msg+3+2*sizeof(int), c->abuf, c->alen);
		*mlen = 3+2*sizeof(int)+c->alen;
		return 0;
	}
	if (strncmp(msg, "QUT", 3) == 0) {
		printf("%s: Client has quit.\n", c->client);
		c->dead = 1;
		strncpy(msg, "EOF", 3);
		*mlen = 3;
		return 0;
	}
	strncpy(msg, "ERR", 3);
	*mlen = 3;
	return -1;
}

/* Audio streaming server
 * Usage: audioclient
 * This program implements the server part of the audio streaming protocol
 * described in protocol.pdf. It loops waiting for a file request, then if this
 * file is available it streams it to the client.
 * TODO: buffering?
 */
int main(int argc, char *argv[]) {
	socklen_t flen = sizeof(struct sockaddr_in);
	struct sockaddr_in host, from;
	struct status clients[MAXCLIENTS];
	int i, sockfd, c_id, client_nb = 0, mlen;
	char msg[BUFSIZE];

	srand(42); // Packet loss simulation
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
		// Receive a request
		if (recvfrom(sockfd, msg, BUFSIZE, 0, (struct sockaddr *) &from, &flen) < 0)
			die("recvfrom");
		// Get id of client or add it, or abort if server is full
		if ((c_id = get_id_or_add(from, clients, &client_nb)) < 0) {
			strncpy(msg, "ERR", 3);
			if (sendto(sockfd, msg, 3, 0, (struct sockaddr *) &from, flen) < 0)
				die("sendto");
			continue;
		}
		// Try to serve client's request
		if (serve(clients+c_id, msg, &mlen) < 0) {
			fprintf(stderr, "Unable to answer to '%s' from %s.\n", msg, inet_ntoa(from.sin_addr));
			continue;
		}
		for (i=0; i<client_nb; i++) {
			if (clients[i].dead) {
				close(clients[i].src);
				if (client_nb > 1 && i != client_nb - 1)
					clients[i] = clients[client_nb - 1];
				client_nb--;
			}
		}
		// Send answer and loop
		//if (rand()%100<1) continue;
		if (sendto(sockfd, msg, mlen, 0, (struct sockaddr *) &from, flen) < 0)
			die("sendto");
	}

	close(sockfd);
	return 0;
}
