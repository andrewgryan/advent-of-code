format ELF64 executable


include "util.inc"


segment readable executable
entry main
main:
        mov         rdi, 79
        call        seed_to_soil
        exit        0


seed_to_soil:
        mov         rsi, 98
        mov         rdx, 2

        mov         rsi, 50
        mov         rdx, 48

        mov         rax, 81
        ret




segment readable writable
