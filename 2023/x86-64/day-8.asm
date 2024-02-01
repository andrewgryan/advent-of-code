format ELF64 executable


include "exit.asm"


segment readable executable
entry main
main:
        exit 0

segment readable writable
