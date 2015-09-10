#include <stdio.h>

int main(int argc, char* argv[]) {
    int tab[11] = {0, 3, 0, 7, 0, 0, 12, 0, 5, 4, 0};
    int *p = tab;
    while(p < tab+11) if(*p++ == 0) printf("%d ", p-tab-1);
    
    return 0;
}
