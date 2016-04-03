			.equ PRINT_INT,		1
			.equ PRINT_STRING,	4
			.equ READ_INT,		5
			.equ EXIT,		10

			.text

			####################################
			# Fonction rechercheDichotomique() #
			####################################
rechercheDichotomique:
			# Sauvegarde des registres
			addi	sp, sp, 4 # de retour
			stw		ra, 0(sp)
			addi	sp, sp, 4 # utilisés par la fonction
			stw		r16, 0(sp)
			addi	sp, sp, 4
			stw		r17, 0(sp)
			
			# Si debut > fin, nombre non trouvé
			ble		r6, r7, recherche
			addi	r2, zero, -1
			br		retour
		
			# Sinon on calcule pos = debut + (fin-debut) /2
recherche:	addi	r17, zero, 2
			sub		r16, r7, r6
			div		r16, r16, r17
			add		r16, r16, r6 # r16 <- pos
			
			# On met tab[pos] dans r17
			muli	r17, r16, 4
			add		r17, r17, r5
			ldw		r17, 0(r17)
			
			# Si tab[pos] == val, nombre trouvé
			bne		r17, r4, nontrouve
			addi	r2, r16, 0
			br		retour

			# Si tab[pos] < val, recherche à droite
nontrouve:	bge		r17, r4, plusgrand
			addi	r6, r16, 1 # Le seul argument à modifier est debut
			call 	rechercheDichotomique
			br		retour
			
			# Sinon, recherche à gauche
plusgrand:	addi	r7, r16, -1 # Cette fois c'est fin
			call 	rechercheDichotomique

			# Restauration des registres mis en pile
retour:		ldw		r17, 0(sp)
			addi	sp, sp, -4
			ldw		r16, 0(sp)
			addi	sp, sp, -4
			ldw		ra, 0(sp)
			addi	sp, sp, -4
			ret

			##############################
			#       Fonction main()      #
			##############################
			.globl main
main:		
boucle:
			# Imprime "Entrez un nombre: "
			movia	r4, msgNb
			addi	r2, zero, PRINT_STRING
			trap
			
			# Lit un nombre
			addi	r2, zero, READ_INT
			trap

			# Effectue la recherche
			addi	r4, r2, 0
			movia	r5, tableau
			addi	r6, zero, 0
			addi	r7, zero, 99
			call	rechercheDichotomique
			addi	r8, r2, 0 # Sauvegarde du résultat
			
			# Si le nombre est introuvable
			bge		r8, zero, sinon
			
			# Imprime "Nombre non trouve."
			movia	r4, msgErreur
			addi	r2, zero, PRINT_STRING
			trap
			
			br		suite
			
			# Nombre trouvé, imprime "La position du nombre est: "
sinon:		movia	r4, msgPos
			addi	r2, zero, PRINT_STRING
			trap
			
			# Affiche la position trouvée
			addi	r4, r8, 0
			addi	r2, zero, PRINT_INT
			trap
	
suite:		br	boucle

			.data
	
msgNb:		.asciz "Entrez un nombre: \n"
msgErreur:	.asciz "Nombre non trouve.\n"
msgPos:		.asciz "La position du nombre est: "
