#include <errno.h>
#include <stdio.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/sem.h>
#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>
#include <strings.h>

#define TAILLE 1024

// Structure de passage des arguments à semctl
union semun { int val; } arg;

void ecrire_tableau(int *compteur, char *tableau) {
	char message[64], *msg=message;
	snprintf(message, 64, "Je suis le processus %d!\n", getpid());

	while ((*compteur<TAILLE)&&(*msg)) {
		tableau[*compteur] = *msg;
		msg++;
		usleep(100000);
		(*compteur)++;
	}
}

int main() {
	struct sembuf up = {0, 1, 0};
	struct sembuf down = {0, -1, 0};
	int id, semaphore, *compteur;
	char *tableau;

	// On tente tout d'abord de créer le sémaphore
	errno = 0;
	semaphore = semget((key_t)7777, 1, 0600|IPC_CREAT|IPC_EXCL);
	if (semaphore>0) { // S'il vient d'être créé
		arg.val = 1; // On l'initialise à 1
		if (semctl(semaphore, 0, SETVAL, arg) < 0) {
			perror("Error semctl"); exit(1);
		}
	} else { // Sinon, il faut récupérer le sémaphore existant
		if (errno != EEXIST) { perror("Error semget"); exit(1); }
		semaphore = semget((key_t)7777, 1, 0600|IPC_CREAT);
	}

	id = shmget((key_t)1234,TAILLE+sizeof(int),0600|IPC_CREAT);
	if (id<0) { perror("Error shmget"); exit(1); }

	compteur = (int*) shmat(id,0,0);
	if (compteur==NULL) { perror("Error shmat"); exit(1); }

	tableau = (char *)(compteur + 1);

	// Section critique
	if (semop(semaphore, &down, 1) < 0) { perror("Error semop"); exit(1); }
	ecrire_tableau(compteur, tableau);
	printf("%s\n", tableau);
	if (semop(semaphore, &up, 1) < 0) { perror("Error semop"); exit(1); }

	if (shmdt(compteur)<0) { perror("Error shmdt"); exit(1); }
	return 0;
}
