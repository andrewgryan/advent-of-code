day = 1
bin/day-$(day): obj/day-$(day).o obj/sys.o
	x86_64-linux-gnu-ld -o bin/day-$(day) obj/day-$(day).o obj/sys.o

obj/day-$(day).o: src/day-$(day).asm
	x86_64-linux-gnu-as -g -o obj/day-$(day).o src/day-$(day).asm

obj/sys.o: src/sys.asm
	x86_64-linux-gnu-as -g -o obj/sys.o src/sys.asm
