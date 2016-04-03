LIB=./syr2-audio-lib

all: server client

server: audioserver.c audio.o
	gcc -I$(LIB) -g -Wall $(LIB)/audio.o audioserver.c -o audioserver

client: audioclient.c filters.o audio.o
	gcc -I$(LIB) -g -Wall $(LIB)/filters.o $(LIB)/audio.o audioclient.c -o audioclient

filters.o: $(LIB)/filters.c
	gcc -g -Wall -c $(LIB)/filters.c -o $(LIB)/filters.o

audio.o: $(LIB)/audio.c
	gcc -g -Wall -c $(LIB)/audio.c -o $(LIB)/audio.o

.PHONY: clean
clean:
	rm -rf $(LIB)/*.o
	rm -rf audioserver
	rm -rf audioclient
