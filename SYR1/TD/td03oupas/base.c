#include <stdio.h>

#define MAXSIZE 100

int ipow(int x, int n) {
	return (n==0) ? 1 : x*ipow(x, n-1);
}

int base(int* arr, int size, int base, long int* val) {
	*val = 0;
	int i;
	for (i=0; i<size; i++) {
		if (arr[i] >= base)
			return -1;
		*val += arr[i] * ipow(base, size-1-i);
	}
	return 0;
}

int main(int argc, char* argv[]) {
	int nb[] = {4, 2};
	long int val;
	if (base(nb, 2, 8, &val) != 0) printf("error");
	printf("%li", val);
	return 0;
}
