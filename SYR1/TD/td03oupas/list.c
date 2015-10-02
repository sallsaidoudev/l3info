/*
 * Somme les éléments d'une liste.
 * Paramètres : list_elem_t* l pointeur vers la tête de la liste
 * Retour :     int res        somme des entiers de l
 */
int somme_element(list_elem_t* l) {
	int res = 0;
	while (l != NULL) {
		res += l->value;
		l = l->next;
	}
	return res;
}

void normalize(list_elem_t* l, int min, int max) {
	while (l != NULL) {
		if (l->value < min)
			l->value = min;
		else if (l->value > max)
			l->value = max;
		l = l->next;
	}
}
