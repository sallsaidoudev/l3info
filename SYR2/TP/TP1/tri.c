#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>

typedef struct nbl {
	struct nbl *next;
	int val;
} nb_list;

int readint(int file, int *n) {
	char c, buf[1024];
	int i = 0, rd = read(file, &c, 1);
	while (rd == 1 && c != '\n') {
		buf[i] = c;
		rd = read(file, &c, 1);
		i++;
	}
	if (rd == 0)
		return -1;
	if (rd < 0)
		return -2;
	buf[i+1] = '\0';
	*n = atoi(buf);
	return 0;
}

int main(int argc, char *argv[]) {
	int file = -1; // file descriptor
	// Opening file
	if (argc != 2) {
		fprintf(stderr, "Usage: reverse <file>\n");
		exit(1);
	}
	file = open(argv[1], O_RDONLY);
	if (file < 0) {
		fprintf(stderr, "Error: can't open file %s\n", argv[1]);
		exit(1);
	}
	// Reading file
	int n;
	nb_list *l = NULL;
	while (readint(file, &n) == 0) {
		nb_list *cur = (nb_list *)malloc(sizeof(nb_list));
		cur->val = n; cur->next = NULL;
		if (l == NULL) {
			l = cur;
			continue;
		}
		if (n < l->val) {
			cur->next = l;
			l = cur;
			continue;
		}
		nb_list *p = l;
		while (p != NULL) {
			if (p->next != NULL && n < p->next->val) {
				cur->next = p->next;
				p->next = cur;
			}
			if (p->next == NULL)
				p->next = cur;
			p = p->next;
		}
	}
	return 0;
}
