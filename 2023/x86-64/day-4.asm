format ELF64 executable


include "util.inc"


segment readable executable
entry main
main:
        mov        rsi, input
        mov        rdi, winners
        call       read_winners

        int3

        exit       0

to_bitmask:
        ret

; @param   {address} rsi - input text
; @param   {address} rdi - output data
read_winners:
        ;          Prepare stack
        push       rbp
        mov        rbp, rsp
        sub        rsp, 16
        .input  equ rbp - 16
        .output equ rbp - 8

        ;          Save arguments on stack
        mov        [.input], rsi
        mov        [.output], rdi

        ;          Loop over numbers
        xor        rcx, rcx
.l1:
        mov        rdx, [.input]
        imul       r8, rcx, 3
        add        rdx, r8                ; input + 3*i
        movzx      rsi, byte [rdx + 10]
        movzx      rdi, byte [rdx + 11]
        call       to_number
        mov        rdx, [.output]
        add        rdx, rcx               ; output + i
        mov        [rdx], al

        inc        rcx
        cmp        rcx, 10
        jb         .l1

        ;          Restore stack
        mov        rsp, rbp
        pop        rbp
        ret

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
        add        sil, '0'
        add        dil, '0'
        ret


segment readable writable

; Data to hold scratch card information
winners rb 10
numbers rb 25

input file "input-4"
input_len = $ - input
