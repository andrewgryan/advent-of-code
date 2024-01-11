format ELF64 executable


include "util.inc"


segment readable executable
entry main
main:
        mov         rdi, 14
        call        seed_to_soil

        mov         rdi, rax
        call        soil_to_fertilizer
        int3

        exit        0


; @param {int}  rdi - Number
seed_to_soil:
        mov         rsi, seed_to_soil_map
        call        apply_map
        ret


; @param {int}  rdi - Number
soil_to_fertilizer:
        mov         rsi, soil_to_fertilizer_map
        call        apply_map
        ret


; @param {int}  rdi - Number
; @param {*map} rsi - address of Map
apply_map:
        push        rbp
        mov         rbp, rsp
        sub         rsp, 3 * 8
        .number equ rbp - 1 * 8
        .range  equ rbp - 2 * 8
        .length equ rbp - 3 * 8
        ; TODO: Use the length of the Map to loop
        mov         qword [.number], rdi     ; Number
        mov         qword [.range], rsi      ; Range address
        mov         qword [.length], rsi     ; Length of Map

        mov         rcx, 0
.l1:
        ;           Next range
        xor         r8, r8
        imul        r8, rcx, 24              ; r8 = i * 24 bytes
        add         qword [.range], r8       ; Address += i * 24 bytes

        ;           Range check
        mov         r8, qword [.range]       ; Range address
        mov         rdi, qword [rbp - 8]     ; Number
        mov         rsi, qword [r8 + 1 * 8]  ; Source range start
        mov         rdx, qword [r8 + 2 * 8]  ; Range length
        call        in_range
        cmp         al, 1
        je          .apply

        inc         rcx
        cmp         rcx, 2
        jb          .l1

        ;           Default case
        mov         rdi, qword [.number]     ; Number
        mov         rax, rdi                 ; Number

.return:
        mov         rsp, rbp
        pop         rbp
        ret

.apply:
        mov         r8, qword [.range]       ; Range address
        mov         rdi, qword [.number]     ; Number
        mov         rsi, qword [r8 + 8]      ; Source range start
        mov         rdx, qword [r8]          ; Destination range start
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
seed_to_soil_map dq 2, 50, 98, 2, 52, 50, 48
soil_to_fertilizer_map dq 3, 0, 15, 37, 37, 52, 2, 39, 0, 15
