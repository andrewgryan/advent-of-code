format ELF64 executable


include "util.inc"


segment readable executable
entry main
main:
        ;          Load scratch card
        mov        rdi, input
        mov        rsi, winners
        call       read_winners
        int3

        mov        rdi, input
        mov        rsi, numbers
        call       read_numbers
        int3

        mov        rdi, winners
        call       encode_winners
        int3

        ;          Apply bit-mask to confirm win
        movzx      rdi, byte [numbers]
        call       confirm

        exit       0

confirm:
        cmp        rdi, 50
        jb         .lower

.upper:
        ;          Encode value to bit mask
        sub        rdi, 50
        call       encode_byte
        add        rdi, 50

        ;          Compare to mask
        mov        r8, rax
        and        r8, qword [upper]
        setnz      r8b
        movzx      rax, r8b
        ret

.lower:
        mov        rax, 0
        ret


encode_winners:
        ;          100-bit encode scratch card
        xor        rcx, rcx
.l1:
        push       rdi
        push       rcx
        movzx      rdi, byte [rdi]
        call       encode
        pop        rcx
        pop        rdi

        inc        rdi
        inc        rcx
        cmp        rcx, 10
        jb         .l1


; @param {byte} rdi - Number [0-99]
encode:
        cmp        rdi, 50
        jb         .lower
.upper:
        sub        rdi, 50
        call       encode_byte
        add        rdi, 50
        or         qword [upper], rax
        ret
.lower:
        call       encode_byte
        or         qword [lower], rax
        ret


; @param {byte} rdi - Number [0-49]
encode_byte:
        mov        rcx, rdi
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


; @param   {address} rdi - input text
; @param   {address} rsi - output data
read_winners:
        add         rdi, 10        ; Offset
        mov         rdx, 10        ; Array length
        call        read_array
        ret


; @param   {address} rdi - input text
; @param   {address} rsi - output data
read_numbers:
        add         rdi, 42        ; Offset
        mov         rdx, 25        ; Array length
        call        read_array
        ret


; @param   {address} rdi - input text
; @param   {address} rsi - output data
; @param   {int}     rdx - array length
read_array:
        ;          Prepare stack
        push       rbp
        mov        rbp, rsp
        sub        rsp, 32
        .input  equ rbp - 3 * 8
        .output equ rbp - 2 * 8
        .length equ rbp - 1 * 8

        ;          Save arguments on stack
        mov        [.input], rdi
        mov        [.output], rsi
        mov        [.length], rdx

        ;          Loop over numbers
        xor        rax, rax
        xor        rdx, rdx
        xor        rcx, rcx
.l1:
        mov        rdx, [.input]
        imul       r8, rcx, 3
        add        rdx, r8                ; input + 3*i
        movzx      rsi, byte [rdx]
        movzx      rdi, byte [rdx + 1]
        call       to_number
        mov        rdx, [.output]
        add        rdx, rcx               ; output + i
        mov        [rdx], al

        inc        rcx
        cmp        rcx, [.length]
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
lower rb 8
upper rb 8

input file "input-4"
input_len = $ - input
