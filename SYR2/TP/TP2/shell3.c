#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
	int i, j;
	char str_read[1024];
	while (1) { // Main loop
		printf("cmd> ");
		if (fgets(str_read, 1024, stdin) == NULL) {
			fprintf(stderr, "Input error\n");
			return -1;
		}
		str_read[strlen(str_read)-1] = '\0';
		if (strcmp(str_read, "exit")  == 0) {
			printf("End of shell session\n\n\n");
			return 0;
		}
		// Count arguments (same number as spaces)
		int nb_args = 1; char *tmp = str_read;
		while ((tmp = strchr(tmp, ' ')) != NULL) { ++nb_args; ++tmp; }
		int nb_pipes = 0; tmp = str_read; // We must also count pipes
		while ((tmp = strchr(tmp, '|')) != NULL) { ++nb_pipes; ++tmp; }
		// Parse arguments (cmds stores index in args for piped commands)
		char **args = (char **)malloc(sizeof(char *) * (nb_args+1));
		int *cmds = (int *)malloc(sizeof(int) * nb_pipes);
		args[0] = strtok(str_read, " ");
		j = 0;
		for (i=1; i<nb_args+1; i++) { // Read args
			args[i] = strtok(NULL, " ");
			// Now we replace | with NULL since it's the list delimiter for execvp
			if (i < nb_args && strncmp(*(args+i), "|", 1) == 0) {
				args[i] = NULL;
				cmds[j] = i+1; // cmds[j] will be the args array for this command
				j++;
			}
		}
		// Create pipes
		int **pipes = (int **)malloc(sizeof(int[2]) * nb_pipes);
		for (i=0; i<nb_pipes; i++) {
			pipes[i] = (int *)malloc(sizeof(int[2]));
			if (pipe(pipes[i]) < 0) {
				fprintf(stderr, "Pipe error");
				return -1;
			}
		}
		// We'll fork each command in a son of this thread
		pid_t son_pid = fork();
		if (son_pid == -1) {
			fprintf(stderr, "Fork error\n");
			return -1;
		}
		if (son_pid == 0) { // First son takes the first (or only) command
			if (nb_pipes > 0) {
				close(pipes[0][0]); // Close first pipe manually
				dup2(pipes[0][1], 1); // Redirect stdout for next command
			}
			if (execvp(args[0], args) == -1) {
				fprintf(stderr, "Exec error\n");
				return -1;
			}
		} else { // Parent thread
			i = 0;
			// Fork nb_pipes times from the parent thread
			for (i=0; i<nb_pipes && (son_pid = fork()) != 0; i++) {
				if (son_pid == -1) {
					fprintf(stderr, "Fork error\n");
					return -1;
				}
			}
			if (son_pid == 0) { // i is now the "index" of current son thread
				for (j=0; j<nb_pipes; j++) { // We need to close all pipes but 2
					if (j != i)
						close(pipes[j][0]);
					if (j != i+1)
						close(pipes[j][1]);
				}
				// Redirect stdin to previous pipe, stdout to next
				dup2(pipes[i][0], 0);
				if (i<nb_pipes-1)
					dup2(pipes[i+1][1], 1);
				// Finally we can exec this thread's command
				if (execvp(args[cmds[i]], args+cmds[i]) == -1) {
					fprintf(stderr, "Exec error\n");
					return -1;
				}
			} else { // In parent thread we must close all pipes
				for (i=0; i<nb_pipes; i++) {
					close(pipes[i][0]);
					close(pipes[i][1]);
				}
				while (wait(NULL) > 0); // Wait for all sons to die
			}
		}
		free(args); // Let's not forget to let the memory as clean as we found it
		free(cmds);
		for (i=0; i<nb_pipes; i++)
			free(pipes[i]);
		free(pipes);
	}

	return 0;
}
