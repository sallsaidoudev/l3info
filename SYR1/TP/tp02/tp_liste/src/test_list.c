/******************************************************************************
 * L3 Informatique                                                Module SYR1 *
 *                           TP de programmation en C                         *
 *                           Test des listes chaînées                         *
 *                                                                            *
 * Groupe : 2.1                                                               *
 * Nom Prénom 1 : Noël-Baron Léo                                              *
 * Nom Prénom 2 : Sampaio Thierry                                             *
 *                                                                            *
 ******************************************************************************/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <termios.h>
#include <unistd.h>
#include "list.h"

/* Compteur du nombre d'allocations */
extern int nb_malloc;

/* Compte le nombre d'éléments de la liste */
static int list_size(list_elem_t* p_list) {
    int nb = 0;
    while (p_list != NULL) {
        nb += 1;
        p_list = p_list->next;
    }
    return nb;
}

/* Affiche le contenu de la liste */
void print_list(list_elem_t* p_list) {
    list_elem_t* pl = p_list;
    printf("%d élément(s) : ", list_size(p_list));
    while(pl != NULL) {
        printf("[%d]", pl->value);
        pl = pl->next;
        if (pl != NULL)
            printf("->");
    }
}

int main(int argc, char* argv[]) {
    list_elem_t* la_liste = NULL; // Pointeur de tête de liste
    char menu[] =
        "Programme de test de liste\n"\
        "  't/q' : ajout d'un élément en tête/queue de liste\n"\
        "  'f'   : recherche du ième élément de la liste\n"\
        "  's'   : suppression d'un élément de la liste\n"\
        "  'r'   : renverser l'ordre des éléments de la liste\n"\
        "  'x'   : quitter le programme\n"\
        "> ";
    int choice = 0; // Choix dans le menu
    int value = 0; // Valeur saisie

    printf("%s", menu);
    fflush(stdout);

    while (1) {
        fflush(stdin);
        choice = getchar();

        switch (choice) {
        case 'T' :
        case 't' :
            printf("Valeur du nouvel element : ");
            scanf("%d",&value);
            if (insert_head(&la_liste,value)!=0)
                printf("Impossible d'ajouter la valeur %d\n", value);
            break;
        case 'Q' :
        case 'q' :
            printf("Valeur du nouvel element : ");
            scanf("%d",&value);
            if (insert_tail(&la_liste,value)!=0)
                printf("Impossible d'ajouter la valeur %d\n", value);
            break;
        case 'F' :
        case 'f' :
            printf("Index à rechercher : ");
            scanf("%d",&value);
            list_elem_t* found = find_element(la_liste, value);
            if (found != NULL)
                printf("Elément trouvé : [%d]\n", found->value);
            else
                printf("Elément %d introuvable\n", value);
            break;
        case 's' :
        case 'S' :
            printf("Elément à supprimer : ");
            scanf("%d",&value);
            if (remove_element(&la_liste,value)!=0)
                printf("Impossible de supprimer la valeur %d\n", value);
            break;
        case 'r' :
        case 'R' :
            reverse_list(&la_liste);
            break;
        case 'x' :
        case 'X' :
            return 0;
        default:
            break;
        }

        print_list(la_liste);
        if (nb_malloc!=list_size(la_liste)) {
            printf("\nAttention : il y a une fuite mémoire dans votre " \
                "programme !\nLa liste contient %d élement, or il y a %d " \
                "élément alloués en mémoire !", list_size(la_liste),
                nb_malloc);
        }
        getchar(); // Consomme un RC et évite un double affichage du menu
        printf("\n\n%s",menu);
    }

    return 0;
}
