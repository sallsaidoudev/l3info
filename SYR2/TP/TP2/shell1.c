#include <stdio.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
	char str_read[1024];
	// Main loop waiting for commands
	while (1) {
		printf("cmd> "); // Prompt a command
		if (fgets(str_read, 1024, stdin) == NULL) {
			fprintf(stderr, "Input error\n");
			return -1;
		} // Last character is a \n and must be erased
		str_read[strlen(str_read)-1] = '\0';
		// Exit command
		if (strcmp(str_read, "exit")  == 0) {
			printf("End of shell session\n\n\n");
			return 0;
		}
		// Fork (we'll exec given command in son thread)
		pid_t son_pid = fork();
		if (son_pid == -1) { // In case something went wrong
			fprintf(stderr, "Fork error\n");
			return -1;
		}
		if (son_pid == 0) { // Son thread executes given command
			if (execlp(str_read, str_read, (char *)NULL) == -1) {
				fprintf(stderr, "Exec error\n");
				return -1;
			}
		} else { // Parent thread waits the end to prompt a new one
			int status;
			wait(&status);
		}
	}
	return 0;
}
