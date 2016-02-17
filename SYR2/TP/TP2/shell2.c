#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
	char str_read[1024];
	// Main loop waiting for commands
	while (1) {
		printf("cmd> ");
		if (fgets(str_read, 1024, stdin) == NULL) {
			fprintf(stderr, "Input error\n");
			return -1;
		}
		str_read[strlen(str_read)-1] = '\0';
		// Exit command
		if (strcmp(str_read, "exit")  == 0) {
			printf("End of shell session\n\n\n");
			return 0;
		}
		// Count arguments (same number as spaces)
		int nb_args = 1;
		char *tmp = str_read;
		while ((tmp = strchr(tmp, ' ')) != NULL) { ++nb_args; ++tmp; }
		// Read the name of the given command
		char *cmd = strtok(str_read, " ");
		char **args = (char **)malloc(sizeof(char *) * (nb_args+1));
		args[0] = cmd; // First arg must be the command name
		int i;
		for (i=1; i<nb_args+1; i++) // Read args
			args[i] = strtok(NULL, " ");
		// Fork and exec
		pid_t son_pid = fork();
		if (son_pid == -1) {
			fprintf(stderr, "Fork error\n");
			return -1;
		}
		if (son_pid == 0) {
			if (execvp(cmd, args) == -1) { // In this case execvp fits better
				fprintf(stderr, "Exec error\n");
				return -1;
			}
		} else {
			int status;
			wait(&status);
		}
		free(args); // Let's not forget to let the memory as clean as we found it
	}

	return 0;
}
