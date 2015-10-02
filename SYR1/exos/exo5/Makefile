OBJ = test_pile.o pile.o
DEP = pile.h Makefile
CC = gcc
CFLAGS = -Wall

# Edition de lien
pile: $(OBJ) $(DEP)
	$(CC) $(CFLAGS) -o pile $(OBJ)

# Compilation des modules objets
%.o: %.c $(DEP)
	$(CC) $(CFLAGS) -o $@ -c $<

# Cibles utiles
.PHONY: clean
clean:
	rm -rf pile *.o
