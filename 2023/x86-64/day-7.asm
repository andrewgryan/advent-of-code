format ELF64 executable


include "util.inc"

NUMBER_OF_RANKS = 13


segment readable executable
entry main
main:
        mov        rdi, full_house
        call       is_full_house
        mov        rdi, three_of_a_kind
        call       is_full_house
        int3
        exit       0


hand:
        call       is_five_of_a_kind
        cmp        rax, 1
        je         .five_of_a_kind

        call       is_four_of_a_kind
        cmp        rax, 1
        je         .four_of_a_kind

        call       is_full_house
        cmp        rax, 1
        je         .full_house

        call       is_three_of_a_kind
        cmp        rax, 1
        je         .three_of_a_kind

        call       is_two_pair
        cmp        rax, 1
        je         .two_pair

        call       is_one_pair
        cmp        rax, 1
        je         .one_pair

        call       is_high_card
        cmp        rax, 1
        je         .high_card

.five_of_a_kind:
        mov        rax, 6
        ret

.four_of_a_kind:
        mov        rax, 5
        ret

.full_house:
        mov        rax, 4
        ret

.three_of_a_kind:
        mov        rax, 3
        ret

.two_pair:
        mov        rax, 2
        ret

.one_pair:
        mov        rax, 1
        ret

.high_card:
        mov        rax, 0
        ret


; @param {*Hand} - Address of hand
is_five_of_a_kind:
        xor        r9, r9
        mov        rax, 1
        movzx      r8, byte [rdi]

        cmp        r8b, byte [rdi + 1]
        sete       r9b
        imul       rax, r9

        cmp        r8b, byte [rdi + 2]
        sete       r9b
        imul       rax, r9

        cmp        r8b, byte [rdi + 3]
        sete       r9b
        imul       rax, r9

        cmp        r8b, byte [rdi + 4]
        sete       r9b
        imul       rax, r9
        ret


; @param {int[]} rdi - Hand
is_four_of_a_kind:
        mov         rsi, 4
        call        of_a_kind
        ret


; @param {int[]} rdi - Hand
; @param {int}   rsi - Count
of_a_kind:
        push       rsi
        mov        rsi, ranks
        call       count_ranks
        pop        rsi

        ;          Detect a 4
        xor        rcx, rcx
        jmp        .l2
.l1:
        cmp        byte [ranks + rcx], sil
        je         .found

        inc        rcx
.l2:
        cmp        rcx, NUMBER_OF_RANKS
        jb         .l1
        mov        rax, 0
        ret

.found:
        mov        rax, 1
        ret


is_full_house:
        push        rdi
        mov         rsi, 3
        call        of_a_kind
        pop         rdi
        push        rax

        push        rdi
        mov         rsi, 2
        call        of_a_kind
        pop         rdi
        push        rax

        pop         rax
        pop         r8
        imul        rax, r8
        ret


is_three_of_a_kind:
        mov         rsi, 3
        call        of_a_kind
        ret


is_two_pair:
        mov        rax, 1
        ret


is_one_pair:
        mov         rsi, 2
        call        of_a_kind
        ret


is_high_card:
        mov        rax, 1
        ret


; @param {int[]} rdi - Hand
; @param {int[]} rsi - Ranks
count_ranks:
        ;          Zero array of ranks
        xor        rcx, rcx
        jmp        .l2
.l1:
        mov        byte [rsi + rcx], 0
        inc        rcx
.l2:
        cmp        rcx, 5
        jb         .l1

        ;          Count ranks
        xor        rcx, rcx
        jmp        .l4
.l3:
        ;          Hash ASCII character
        push       rcx
        push       rdi
        movzx      rdi, byte [rdi + rcx]
        call       hash
        pop        rdi
        pop        rcx

        ;          Increment count and index
        inc        byte [rsi + rax]
        inc        rcx
.l4:
        cmp        rcx, 5
        jb         .l3
        ret


; Map from card rank to array index
;
; @param {int} - ASCII character
; @returns {int}
hash:
        xor        rcx, rcx
.l1:
        cmp        dil, byte[order + rcx]
        je         .l2

        inc        rcx
        jmp        .l1
.l2:
        mov        rax, rcx
        ret


segment readable writable
order db "23456789TJQKA"
ranks rb NUMBER_OF_RANKS

five_of_a_kind db "AAAAA"
four_of_a_kind db "AA8AA"
full_house db "23332"
three_of_a_kind db "TTT98"
two_pair db "23432"
one_pair db "A23A4"
high_card db "23456"
