format ELF64 executable


include "util.inc"


segment readable executable
entry main
main:
        mov         rdi, 79
        call        seed_to_soil
        exit        0


seed_to_soil:
        push        rbp
        mov         rbp, rsp
        sub         rsp, 8
        mov         qword [rbp - 8], rdi ; Number

        mov         rdi, qword [rbp - 8] ; Number
        mov         rsi, 50              ; Source range start
        mov         rdx, 48              ; Range length
        call        in_range

        mov         rdi, qword [rbp - 8] ; Number
        mov         rsi, 50              ; Source range start
        mov         rdx, 52              ; Destination range start
        call        apply_range

        mov         rsp, rbp
        pop         rbp
        ret


; Range start <= N < range start + length
;
; @param {int} rdi - number
; @param {int} rsi - source range start
; @param {int} rdx - range length
in_range:
        ;          range start <= N
        xor        rax, rax
        cmp        rdi, rsi
        setae      al

        ;          Number < range start + length
        xor        rdx, rdx
        sub        rdi, rsi
        cmp        rdi, rdx
        setb       dl

        ;          Range start <= N < range start + length
        and        al, dl
        ret


; @param {int} rdi - number
; @param {int} rsi - source range start
; @param {int} rdx - destination range start
apply_range:
        mov        rax, rdi
        sub        rax, rsi
        add        rax, rdx
        ret


segment readable writable
