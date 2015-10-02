INC = include
OBJ = obj/test_list.o obj/list.o
DEP = $(INC)/list.h Makefile
CC = gcc
CFLAGS = -Wall -I$(INC) -g

# Edition de lien
bin/test_list: $(OBJ) $(DEP)
	$(CC) $(CFLAGS) -o bin/test_list obj/test_list.o obj/list.o

# Compilation des modules objets
obj/%.o: src/%.c $(DEP)
	$(CC) $(CFLAGS) -o $@ -c $<

# Cibles utiles
.PHONY: test
test:
	@echo "Fichier de test : "
	@read F; bin/test_list < $$F

.PHONY: listing
listing:
	iconv -c -t ISO-8859-1 -f utf-8 -o list.h include/list.h
	iconv -c -t ISO-8859-1 -f utf-8 -o list.c src/list.c
	iconv -c -t ISO-8859-1 -f utf-8 -o test_list.c src/test_list.c 
	a2ps -o - list.h list.c test_list.c | ps2pdf - > listing.pdf
	rm list.h list.c test_list.c

.PHONY: clean
clean:
	rm -rf obj/* bin/* listing.pdf
