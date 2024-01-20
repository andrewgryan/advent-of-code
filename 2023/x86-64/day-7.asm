format ELF64 executable


include "util.inc"


segment readable executable
entry main
main:
        exit 0


five_of_kind:
        movzx r8, 1
        mov sil, byte [rdi]

        cmp sil, byte [rdi + 1]
        sete al
        imul r8b, al

        cmp sil, byte [rdi + 2]
        cmp sil, byte [rdi + 3]
        cmp sil, byte [rdi + 4]
        ret


segment readable writable
order db "AKQJT98765432"
