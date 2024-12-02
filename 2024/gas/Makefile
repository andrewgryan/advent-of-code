bin/day-1: obj/day-1.o obj/sys.o
	x86_64-linux-gnu-ld -o bin/day-1 obj/day-1.o obj/sys.o

obj/day-1.o: src/day-1.asm
	x86_64-linux-gnu-as -g -o obj/day-1.o src/day-1.asm

obj/sys.o: src/sys.asm
	x86_64-linux-gnu-as -g -o obj/sys.o src/sys.asm
