#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<syr1_file.h>

int main(int argc, char **argv)
{
  SYR1_FILE * file_w = syr1_fopen("reponse", "w");
  int j=0;

  if (file_w == NULL) {
    fprintf(stderr, "Erreur à l'ouverture du fichier");
    return -1;
  }
  /* Ouverture réussie */
  char qd[14] = "gkqhqdju-tukn\n";
  for (j = 0; j < 13; j++) {
    int res = syr1_putc(qd[j], file_w);
    if (res != 0) {
      fprintf(stderr, "Erreur d'écriture pour le %d ème caractère\n",j);
      return -1;
    }
  }
  int res = syr1_fclose(file_w);
  if (res != 0) {
    fprintf(stderr, "Erreur à la fermeture du fichier");
    return -1;
  }
  return 0;
}

