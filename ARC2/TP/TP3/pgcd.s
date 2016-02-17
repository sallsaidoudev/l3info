			########################
			#	L3INFO - TP ARC2   #
			# 	 Calcul de PGCD    #
			########################
		
			.equ PRINT_INT, 1
			.equ PRINT_STRING, 4
			.equ READ_INT, 5
			.equ EXIT,	10

			.text
			.global main
		
main:
			# Lecture de l'entier "a"
			movia		r4,	invite_a
			addi		r2, zero, PRINT_STRING
			trap
			
			addi		r2, zero, READ_INT
			trap
			
			movia		r3, a
			stw			r2, 0(r3)
			
			# Lecture de l'entier "b"
			movia		r4,	invite_b
			addi		r2, zero, PRINT_STRING
			trap
			
			addi		r2, zero, READ_INT
			trap
			
			movia		r3, b
			stw			r2, 0(r3)

			# Calcul du PGCD
			
			# while (a != b)
while:		movia		r3, a
			ldw			r9, 0(r3)
			movia		r3, b
			ldw			r10, 0(r3)
			beq			r9, r10, endwhile # si a = b on sort de la boucle
			
			#	if (b>a)
			movia		r3, a
			ldw			r9, 0(r3)
			movia		r3, b
			ldw			r10, 0(r3)
			ble			r10, r9, else # si b <= a on va au "sinon"
			
			#		b = b-a
			movia		r3, a
			ldw			r9, 0(r3)
			movia		r3, b
			ldw			r10, 0(r3)
			sub			r10, r10, r9
			movia		r3, b
			stw			r10, 0(r3)
			br			endif
			
			#	else
			#		a = a-b
else:		movia		r3, a
			ldw			r9, 0(r3)
			movia		r3, b
			ldw			r10, 0(r3)
			sub			r9, r9, r10
			movia		r3, a
			stw			r9, 0(r3)
endif:		br			while # branchement la boucle

			# resultat = a
endwhile:	movia		r3, a
			ldw			r9, 0(r3)
			movia		r3, resultat
			stw			r9, 0(r3)
			
			# Affichage du résultat
			movia		r4, msg_res
			addi		r2, zero, PRINT_STRING
			trap
			
			movia		r3, resultat
			ldw			r4, 0(r3)
			addi		r2, zero, PRINT_INT
			trap
			
			addi		r2, zero, EXIT
			trap

.data
			
a:			.skip 4
b:			.skip 4
resultat:	.word 5
invite_a:	.asciz "Entrez un entier (a): "
invite_b:	.asciz "Entrez un entier (b): "
msg_res:	.asciz "Le PGCD de a et b est: "
