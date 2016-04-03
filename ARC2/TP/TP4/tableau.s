			##################################
			#	     L3INFO - TP ARC2        #
			# 	 Manipulation de tableaux    #
			##################################
		
			.equ PRINT_INT, 1
			.equ PRINT_STRING, 4
			.equ READ_INT, 5
			.equ EXIT,	10

			.text
			.global main

			###########################
			# Fonction lectureTableau #
			###########################			
lectureTableau:
			# Stockage des registres utilisés dans la pile
			addi	sp, sp, 4
			stw		r12, 0(sp)
			addi	sp, sp, 4
			stw		r13, 0(sp)
			
			addi	r12, r4, 0 # r12 <- &tab
			addi	r13, zero, 0 # r13 <- i
			
			# Boucle de lecture
forl:		bge		r13, r5, endforl
			# Affichage du message de prompt
			movia	r4, msgPrompt
			addi	r2,	zero, PRINT_STRING
			trap
			
			# Lecture d'un entier au clavier
			addi	r2, zero, READ_INT
			trap
			
			stw		r2, 0(r12) # tab[i] = read_int()
			addi	r12, r12, 4 # r12 avance d'une case
			addi	r13, r13, 1 # i++
			br		forl
	
			# Restauration des registres et retour
endforl:	ldw		r13, 0(sp)
			addi	sp, sp, -4
			ldw		r12, 0(sp)
			addi	sp, sp, -4
			ret
			
			#############################
			# Fonction affichageTableau #
			#############################
affichageTableau:
			addi	sp, sp, 4
			stw		r12, 0(sp)
			addi	sp, sp, 4
			stw		r13, 0(sp)
			
			addi	r12, r4, 0
			addi	r13, zero, 0
			
			# Boucle d'affichage
fora:		bge		r13, r5, endfora
			# Affichage d'un entier du tableau
			ldw		r4, 0(r12)
			addi	r2, zero, PRINT_INT
			trap
			
			# Incrémentation des indices
			addi	r12, r12, 4
			addi	r13, r13, 1
			br		fora
		
endfora:	ldw		r13, 0(sp)
			addi	sp, sp, -4
			ldw		r12, 0(sp)
			addi	sp, sp, -4
			ret
			
			#############################
			# Fonction inversionTableau #
			#############################
inversionTableau:
			addi	r12, r4, 0 # r12 <- &tab
			addi	r13, zero, 0 # r13 <- i
			addi	r14, zero, 0 # r14 sert à adresser tab[j]
			addi	r15, r5, -1 # r15 <- j
			
			# Boucle tant que i < j
whilei:		bge		r13, r15, endwhilei
			ldw		r16, 0(r12) # r16 <- tab[i]
			
			# Echange des valeurs
			muli	r14, r15, 4
			add		r14, r14, r4 # r14 <- &tab[j]
			ldw		r17, 0(r14) # r17 <- tab[j]
			stw		r17, 0(r12) # tab[i] <- r17
			stw		r16, 0(r14) # tab[j] <- r16
			
			# Progression des indices
			addi	r12, r12, 4 # r12 avance d'une case
			addi	r13, r13, 1 # i++
			addi	r15, r15, -1 # j--
			br		whilei
		
endwhilei:	ret

			###########################
			#     Fonction main()     #
			###########################
main:		# Affichage du message "Lecture du tableau"
			movia	r4, msgLecture
			addi	r2,	zero, PRINT_STRING
			trap
			
			# Lecture du tableau
			movia	r4, tableau
			addi	r5, zero, 10
			call lectureTableau
			
			# Inversion du tableau
			movia	r4, tableau
			addi	r5, zero, 10
			call inversionTableau
			
			# Affichage du message "Affichage du tableau"
			movia	r4, msgAffiche
			addi	r2,	zero, PRINT_STRING
			trap

			# Affichage du tableau
			movia	r4, tableau
			addi	r5, zero, 10
			call affichageTableau
			
			# On rend la main au système.
			addi	r2, zero, EXIT
			trap
	
			.data
msgPrompt:	.asciz "Entrez un nombre :\n"
msgLecture: .asciz "Lecture du tableau.\n"
msgAffiche: .asciz "Affichage du tableau.\n"

			# Tableau de 10 éléments
tableau:	.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0