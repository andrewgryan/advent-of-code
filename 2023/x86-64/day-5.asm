format ELF64 executable


include "util.inc"


segment readable executable
entry main
main:
        mov         rdi, 79
        call        seed_to_soil
        int3

        mov         rdi, 9
        call        seed_to_soil
        int3

        exit        0


seed_to_soil:
        push        rbp
        mov         rbp, rsp
        sub         rsp, 8
        mov         qword [rbp - 8], rdi               ; Number

        ;           Range check
        mov         rdi, qword [rbp - 8]               ; Number
        mov         rsi, qword [seed_to_soil_map + 8]  ; Source range start
        mov         rdx, qword [seed_to_soil_map + 16] ; Range length
        call        in_range
        cmp         al, 1
        je          .apply

        ;           Default case
        mov         rdi, qword [rbp - 8]               ; Number
        mov         rax, rdi                           ; Number

.return:
        mov         rsp, rbp
        pop         rbp
        ret

.apply:
        mov         rdi, qword [rbp - 8]               ; Number
        mov         rsi, qword [seed_to_soil_map + 8]  ; Source range start
        mov         rdx, qword [seed_to_soil_map]      ; Destination range start
        call        apply_range
        jmp         .return



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
        xor        r8, r8
        sub        rdi, rsi
        cmp        rdi, rdx
        setb       r8b

        ;          Range start <= N < range start + length
        and        al, r8b
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
seed_to_soil_map dq 52, 50, 48
