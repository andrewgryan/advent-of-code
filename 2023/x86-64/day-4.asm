format ELF64 executable


include "util.inc"


segment readable executable
entry main
main:
        movzx      rsi, byte [input + 10]
        movzx      rdi, byte [input + 11]
        call       to_number
        exit       0


; @param   {byte} sil - ASCII character
; @param   {byte} dil - ASCII character
;
; @returns {byte} al - number between 0-99
to_number:
        sub        sil, '0'
        sub        dil, '0'
        movzx      rax, sil
        imul       rax, 10
        add        al, dil
        ret


segment readable writable

; Data to hold scratch card information
winners rb 10
numbers rb 25

input file "input-4"
input_len = $ - input
