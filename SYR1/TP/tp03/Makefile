NAME = "Noel-Baron & Sampaio"
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
	@echo "  progs       : compilation et édition des programmes de test"
	@echo "  init_fs     : regénère un systeme de fichier sain"
	@echo "  inspect     : affiche le disque virtuel avec l'éditeur hexa" 
	@echo "  simple_read : lance le test de lecture avec simple_read"
	@echo "  test_read   : lance le test de lecture avec test_read"
	@echo "  simple_write: lance le test d'écriture avec simple_write"
	@echo "  test_write  : lance le test d'écriture avec test_write"
	@echo "  listing     : génère un fichier pdf (imprimable) des sources"
	@echo "  clean       : efface les fichiers objets et binaires"
	@echo "==============================================================" 
	@echo "  "

progs: $(PROGS)

# les fichiers sources du TP à compléter (file_read.c, file_write.c)
obj/openclose.o: student/openclose.c $(INC_FILES)
	$(CC) -c $(CFLAGS) -o obj/openclose.o student/openclose.c
obj/file_read.o: student/file_read.c $(INC_FILES)
	$(CC) -c $(CFLAGS) -o obj/file_read.o student/file_read.c
obj/file_write.o: student/file_write.c $(INC_FILES)
	$(CC) -c $(CFLAGS) -o obj/file_write.o student/file_write.c

# modules de test
bin/simple_read: tests/simple_read.c $(OBJ) $(INC_FILES)
	$(CC) -o  bin/simple_read  $(CFLAGS) $(OBJ) tests/simple_read.c 
bin/simple_write : tests/simple_write.c $(OBJ) $(INC_FILES)
	$(CC) -o bin/simple_write $(CFLAGS) $(OBJ) tests/simple_write.c 
bin/test_read: tests/test_read.c $(OBJ) $(INC_FILES)
	$(CC) -o bin/test_read  $(CFLAGS) $(OBJ) tests/test_read.c 
bin/test_write : tests/test_write.c $(OBJ) $(INC_FILES)
	$(CC) -o bin/test_write $(CFLAGS) $(OBJ) tests/test_write.c 

# regénération du SGF
init_fs:
	cp -p /share/l3info/syr1/tp_sgf/disk.img ./

inspect:
	ghex disk.img

# génération du listing en pdf
listing:
	a2ps --tabsize=4 --medium=A4 --title="SYR1 - TP3" \
		--left-footer="" --footer="" --right-footer="Page %s." \
		-o tp_sgf.ps lecture ecriture 
	@ps2pdf -sPAPERSIZE=a4 tp_sgf.ps
	@rm -rf tp_sgf.ps

# tests
simple_read: $(PROGS)
	./bin/simple_read
simple_write: $(PROGS)
	./bin/simple_write
test_read: $(PROGS)
	./bin/test_read
test_write: $(PROGS)
	./bin/test_write

# nettoyage des modules
clean :
	rm -f obj/file_read.o obj/file_write.o obj/openclose.o bin/test_* bin/simple_*
