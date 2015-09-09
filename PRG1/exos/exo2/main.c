#include <stdio.h>

void insert(int* t, int i, int n) {
	int k, cur = n;
	for(k=0; k<=i; k++) {
		if(k == i) t[k] = cur;
	 	else if(cur < t[k]) {
	 		t[k] += cur;
	 		cur = t[k] - cur;
	 		t[k] -= cur;
	 	}
	}
}

int main(int argc, char* argv[]) {
	int arr[50];
	int n = 0, i = 0, k;
	while(scanf("%d", &n) != EOF && i < 50) {
		insert(arr, i, n);
		i++;
		for(k=0; k<i; k++) printf("%d ", arr[k]);
		printf("\n");
	}

	return 0;
}
