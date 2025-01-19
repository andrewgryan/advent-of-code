all: hello split

hello: hello.o
	ld -o hello hello.o

hello.o: hello.asm
	as -g -o hello.o hello.asm

split: split.o
	ld -o split split.o

split.o: split.asm
	as -g -o split.o split.asm
