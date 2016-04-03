#include <stdlib.h>
#include <string.h>

// To start abuf contains initial data, alen length of this data
// At end alen
// filter(abuf, &alen)

int mono(char abuf[], int *alen) {
	int i;
	for (i=0; i<*alen; i+=4) {
		signed short l,r;
		memcpy(&l, abuf+i, 2);
		memcpy(&r, abuf+i+2, 2);
		l = (l+r)/2;
		memcpy(abuf+i, &l, 2);
		memcpy(abuf+i+2, &l, 2);
	}
	return 0;
}

int volume(char abuf[], int *alen, float vol) {
	int i;
	for (i=0; i<*alen; i+=2) {
		signed short s;
		memcpy(&s, abuf+i, 2);
		s = s*vol;
		memcpy(abuf+i, &s, 2);
	}
	return 0;
}

int fast(char abuf[], int *alen) {
	int i;
	for (i=0; i<*alen; i+=4) {
		signed short s;
		memcpy(&s, abuf+i, 2);
		memcpy(abuf+i/2, &s, 2);
	}
	*alen /= 2;
	return 0;
}

int slow(char abuf[], int *alen, char *more, int *mlen) {
	int i;
	char *tmp = (char *) malloc(*alen*2);
	for (i=0; i<*alen; i+=2) {
		signed short s;
		memcpy(&s, abuf+i, 2);
		memcpy(tmp+2*i, &s, 2);
		memcpy(tmp+2*i+2, &s, 2);
	}
	memcpy(abuf, tmp, *alen);
	*mlen = *alen;
	more = (char *) malloc(*mlen);
	memcpy(more, tmp+*alen, *mlen);
	free(tmp);
	return 0;
}
