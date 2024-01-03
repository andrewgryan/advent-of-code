format ELF64 executable


include "util.inc"


segment readable executable
entry main
main:
        ;          Debug information
        mov        rdi, upper
        mov        rsi, lower

        ;          100-bit mask encoding
        mov        rcx, 72
        call       encode
        mov        rcx, 28
        call       encode
        mov        rcx, 41
        call       encode
        mov        rcx, 15
        call       encode
        mov        rcx, 98
        call       encode
        mov        rcx, 13
        call       encode
        int3
        exit       0

encode:
        cmp        rcx, 50
        jb         .lower
.upper:
        sub        rcx, 50
        call       encode_byte
        or         qword [upper], rax
        ret
.lower:
        call       encode_byte
        or         qword [lower], rax
        ret

encode_byte:
        mov        rax, 1
.l1:
        cmp        rcx, 8
        jb         .d1
        shl        rax, 8
        sub        rcx, 8
        jmp        .l1
.d1:
        shl        rax, cl
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
lower rb 8
upper rb 8

input file "input-4"
input_len = $ - input
