#include <stdio.h>
#include <sys/shm.h>
#include <sys/sem.h>
#include <stdlib.h>

#define TAILLE 1024

int main(int argc, char *argv[]) {
	int id, sem;
	
	// Nettoyage du segment de mémoire partagée
	id = shmget((key_t)1234,TAILLE+sizeof(int),0600|IPC_CREAT);
	if (id<0) { perror("Error shmget"); exit(1); }
	if (shmctl(id, IPC_RMID, NULL) < 0) {
		perror("Error shmctl");
		exit(1);
	}

	// Nettoyage du sémaphore
	sem = semget((key_t)7777,1,0600|IPC_CREAT);
	if (sem<0) { perror("Error semget"); exit(1); }
	if (semctl(sem, 0, IPC_RMID) < 0) {
		perror("Error semctl");
		exit(1);
	}

	return 0;
}
