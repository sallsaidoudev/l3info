/******************************************************************************
 * L3 Informatique                                                Module SYR1 *
 *                           TP de programmation en C                         *
 *                      Mise en oeuvre des listes chaînées                    *
 *                                                                            *
 * Groupe : 2.1                                                               *
 * Nom Prénom 1 : Noël-Baron Léo                                              *
 * Nom Prénom 2 : Sampaio Thierry                                             *
 *                                                                            *
 ******************************************************************************/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "list.h"

int nb_malloc = 0; // compteur global du nombre d'allocations

/*
 * SYNOPSIS :
 *   list_elem_t* create_element(int value)
 * DESCRIPTION :
 *   crée un nouveau maillon de liste, dont le champ next a été initialisé à
 *   NULL, et dont le champ value contient l'entier passé en paramètre.
 * PARAMETRES :
 *   int value : valeur de l'élément
 * RESULTAT :
 *   NULL en cas d'échec, sinon un pointeur sur une structure list_elem_t
 */
static list_elem_t* create_element(int value) {
    list_elem_t* new_elt = malloc(sizeof(list_elem_t));
    if (new_elt != NULL) {
        ++nb_malloc;
        new_elt->value = value;
        new_elt->next = NULL;
    }
    return new_elt;
}

/*
 * SYNOPSIS :
 *   void free_element(list_elem_t* l)
 * DESCRIPTION :
 *   libère un maillon de liste.
 * PARAMETRES :
 *   list_elem_t* l : pointeur sur le maillon à libérer
 * RESULTAT :
 *   rien
 */
static void free_element(list_elem_t* l) {
    --nb_malloc;
    free(l);
}

/*
 * SYNOPSIS :
 *   int insert_head(list_elem_t** l, int value)
 * DESCRIPTION :
 *   ajoute un élément en tête de liste ; à l'issue de l'exécution de la
 *   fonction, *l désigne la nouvelle tête de liste.
 * PARAMETRES :
 *   list_elem_t** l : pointeur sur le pointeur de tête de liste
 *   int value : valeur de l'élément à ajouter
 * RESULTAT :
 *    0 en cas de succès, -1 si l'ajout est impossible
 */
int insert_head(list_elem_t** l, int value) {
    if (l == NULL)
        return -1;
    list_elem_t* new_elt = create_element(value);
    if (new_elt == NULL)
        return -1;

    new_elt->next = *l;
    *l = new_elt;
    return 0;
}

/*
 * SYNOPSIS :
 *   int insert_tail(list_elem_t** l, int value)
 * DESCRIPTION :
 *   ajoute un élément en queue de la liste (*l désigne la tête de liste).
 * PARAMETRES :
 *   list_elem_t** l : pointeur sur le pointeur de tête de liste
 *   int value : valeur de l'élément à ajouter
 * RESULTAT :
 *    0 en cas de succès, -1 si l'ajout est impossible
 */
int insert_tail(list_elem_t** l, int value) {
    if (l == NULL)
        return -1;
    list_elem_t* new_elt = create_element(value);
    if (new_elt == NULL)
        return -1;

    if (*l == NULL) { // Si la liste est vide on redirige le pointeur de tête
        *l = new_elt;
        return 0;
    }
    list_elem_t* tail = *l;
    // Sinon on parcourt jusqu'à la queue, puis on branche le nouvel élément
    // au dernier
    while (tail->next != NULL)
        tail = tail->next;
    tail->next = new_elt;
    return 0;
}

/*
 * SYNOPSYS :
 *   list_elem_t* find_element(list_elem_t* l, int index)
 * DESCRIPTION :
 *   retourne un pointeur sur le maillon à la position n°i de la liste (le 1er
 *   élément est situé à la position 0)
 * PARAMETRES :
 *   int index : position de l'élément à retrouver
 *   list_elem_t* l : pointeur sur la tête de liste
 * RESULTAT :
 *   NULL en cas d'erreur, sinon un pointeur sur le maillon de la liste
 */
list_elem_t* find_element(list_elem_t* l, int index) {
    if (l == NULL)
        return NULL;

    list_elem_t* found = l;
    int i = 0;
    // On parcourt la liste en décrémentant un compteur jusqu'à arriver
    // à la case voulue
    for (i=index-1; i>0 && found->next!=NULL; i--)
        found = found->next;
    if (i != 0)
        return NULL;
    else
        return found;
}

/*
 * SYNOPSIS :
 *   int remove_element(list_elem_t** l, int value)
 * DESCRIPTION :
 *   supprime de la liste (dont la tête a été passée en paramètre) le premier
 *   élément de valeur value, et libère l'espace mémoire utilisé par le maillon
 *   ainsi supprimé. Attention, à l'issue de la fonction la tête de liste
 *   peut avoir été modifiée.
 * PARAMETRES :
 *   list_elem_t** l : pointeur sur le  pointeur de tête de liste
 *   int value : valeur à supprimer de la liste
 * RESULTAT :
 *    0 en cas de succès, -1 en cas d'erreur
 */
int remove_element(list_elem_t** l, int value) {
    if (l == NULL || *l == NULL)
        return -1;

    // On parcourt la liste jusqu'à l'élément à détruire, tout en maintenant
    // un pointeur vers l'élément précédent
    list_elem_t* pre = NULL;
    list_elem_t* del = *l;
    while (del->value != value && del->next != NULL) {
        pre = del;
        del = del->next;
    }
    if (del->value != value) // Si la valeur n'a pas été trouvée, erreur
        return -1;

    if (del == *l)
        *l = del->next;
    else
        pre->next = del->next;
    free_element(del);
    return 0;
}

/*
 * SYNOPSIS :
 *   void reverse_list(list_elem_t** l)
 * DESCRIPTION :
 *   modifie la liste en renversant l'ordre de ses élements (le 1er élément est
 *   placé en dernière position, le 2nd en avant-dernière, etc).
 * PARAMETRES :
 *   list_elem_t** l : pointeur sur le pointeur de tête de liste
 * RESULTAT :
 *   rien
 */
void reverse_list(list_elem_t** l) {
    if (l == NULL || *l == NULL)
        return;

    // On maintient trois pointeurs vers trois éléments successifs de la liste
    // pour pouvoir renverser les pointeurs en un seul parcours sans perdre
    // d'information
    list_elem_t* pre = NULL;
    list_elem_t* cur = *l;
    list_elem_t* next = NULL;
    while (cur != NULL) {
        next = cur->next;
        cur->next = pre;
        pre = cur;
        cur = next;
    }

    *l = pre;
}
