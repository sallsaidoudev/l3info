#include <stdio.h>

int main(int argc, char* argv[]) {
    int x = 42;
    int *p = &x;
    int **pp = &p;
    printf("x<%d> **pp<%d>\n", x, **pp);
    **pp -= 1;
    printf("x<%d> **pp<%d>\n", x, **pp);
    
    return 0;
}
