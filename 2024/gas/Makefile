day = 2
bin/day-$(day): obj/day-$(day).o obj/sys.o obj/math.o
	x86_64-linux-gnu-ld -o bin/day-$(day) obj/day-$(day).o obj/sys.o obj/math.o

obj/day-$(day).o: src/day-$(day).asm
	x86_64-linux-gnu-as -g -o obj/day-$(day).o src/day-$(day).asm

obj/sys.o: src/sys.asm
	x86_64-linux-gnu-as -g -o obj/sys.o src/sys.asm

obj/math.o: src/math.asm
	x86_64-linux-gnu-as -g -o obj/math.o src/math.asm
