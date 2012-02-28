# template makefile for c files
CC = gcc
CFLAGS = -fno-stack-protector -static -ggdb -w
SRCS = $(wildcard *.c)
OBJS = $(basename $(SRCS))

%: %.c
	$(CC) -o $(basename $<) $< $(CFLAGS)

all: $(OBJS)

clean:
	rm -rf $(OBJS)
