#include <stdio.h>
#include <string.h>

#define MAXSIZE 100

int search_path(char* path, char* elt, int depth) {
	char buf[MAXSIZE];
	strcpy(buf, path+1);
	char* path_elt = strtok(buf, "/");
	int i;
	for (i=depth; i>0 && path_elt!=NULL; i--)
		path_elt = strtok(NULL, "/");
	if (path_elt != NULL && strcmp(path_elt, elt) == 0)
		return 1;
	return 0;
}

int main(int argc, char* argv[]) {
	printf("%d", search_path("/usr/local/f1.txt", "usr", 0));
	printf("%d", search_path("/f1.txt", "f1", 0));
	printf("%d", search_path("/usr/leo", "local", 2));
	printf("%d", search_path("usr/leo", "usr", 0));
	printf("%d", search_path("/usr/leo", "leo", 1));
	return 0;
}
