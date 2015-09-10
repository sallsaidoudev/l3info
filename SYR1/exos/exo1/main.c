#include <stdio.h>

int main(int argc, char* argv[]) {
    int fst = 0, snd = 0;
    while(1) {
        char op = 0;
        printf("Entrez une opération : ");
        scanf("%d %c %d", &fst, &op, &snd);
        while(getchar() != '\n');
        switch(op) {
            case '+': printf("> %d\n", fst + snd); break;
            case '-': printf("> %d\n", fst - snd); break;
            case '*': printf("> %d\n", fst * snd); break;
            case '/': if(snd) {
                printf("> %.2f\n", (float)fst / snd); break;
            }
            default: printf("***\n"); break;
        }
    }
    
    return 0;
}
