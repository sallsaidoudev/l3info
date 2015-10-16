NAME = "Noël-Baron & Sampaio"
CC = gcc
CFLAGS = -g -Wall -I./include
LDFLAGS = -g

OBJ_DONNES = \
	obj/block_alloc.o \
	obj/directory.o \
	obj/file_alloc.o \
	obj/physical_io.o

OBJ_AFAIRE = \
	obj/openclose.o \
	obj/file_read.o \
	obj/file_write.o 

OBJ = $(OBJ_DONNES) $(OBJ_AFAIRE)

PROGS = \
	bin/simple_read \
	bin/simple_write \
	bin/test_read \
	bin/test_write

INC_FILES = \
	include/physical_io.h \
	include/syr1_file.h \
	include/directory.h 

all: 
	@echo "==============================================================" 
	@echo "usage : make [progs] [clean] ..."
	@echo "  "
	@echo "  progs       : compilation et édition des programmes de tests"
	@echo "  init_fs     : regénère un systeme de fichier complet"
	@echo "  inspect     : affiche le disque virtuel avec l'éditeur hexa" 
	@echo "  simple_read : lance le test de lecture simple"
	@echo "  test_read   : lance le test de lecture exhaustif"
	@echo "  simple_write: lance le test d'écriture simple"
	@echo "  test_write  : lance le test d'écriture exhaustif"
	@echo "  listing     : génère un fichier pdf (imprimable) des sources"
	@echo "  clean       : efface les fichiers objets et binaires"
	@echo "==============================================================" 
	@echo "  "

progs: $(PROGS)

# Les fichiers sources du TP à compléter (file_read.c, file_write.c)
obj/openclose.o: student/openclose.c $(INC_FILES)
	$(CC) -c $(CFLAGS) -o obj/openclose.o student/openclose.c
obj/file_read.o: student/file_read.c $(INC_FILES)
	$(CC) -c $(CFLAGS) -o obj/file_read.o student/file_read.c
obj/file_write.o: student/file_write.c $(INC_FILES)
	$(CC) -c $(CFLAGS) -o obj/file_write.o student/file_write.c

# Modules de test
bin/simple_read: tests/simple_read.c $(OBJ) $(INC_FILES)
	$(CC) -o  bin/simple_read  $(CFLAGS) $(OBJ) tests/simple_read.c 
bin/simple_write: tests/simple_write.c $(OBJ) $(INC_FILES)
	$(CC) -o bin/simple_write $(CFLAGS) $(OBJ) tests/simple_write.c 
bin/test_read: tests/test_read.c $(OBJ) $(INC_FILES)
	$(CC) -o bin/test_read  $(CFLAGS) $(OBJ) tests/test_read.c 
bin/test_write: tests/test_write.c $(OBJ) $(INC_FILES)
	$(CC) -o bin/test_write $(CFLAGS) $(OBJ) tests/test_write.c 

# Regénération du SGF
init_fs:
	cp -p ./save/disk.img ./

inspect:
	ghex disk.img

# Test simple de lecture
simple_read: $(PROGS)
	./bin/simple_read
# Test simple d'écriture 
simple_write: $(PROGS)
	./bin/simple_write
# Test poussé de lecture ; voir résultats attendus dans read.sor
test_read: $(PROGS)
	./bin/test_read
# Test poussé d'écriture ; voir résultats attendus dans write.sor
test_write: $(PROGS)
	./bin/test_write

# Génération du listing en pdf
listing:
	@a2ps --tabsize=4 --medium=A4 --title=$(NAME) -o tp_sgf.ps student/file_read.c student/file_write.c 
	@ps2pdf -sPAPERSIZE=a4 tp_sgf.ps

# Nettoyage des modules
clean:
	rm -f obj/file_read.o obj/file_write.o obj/openclose.o bin/test_* bin/simple_*
