format ELF64 executable


include "util.inc"

CARDS_IN_HAND = 5
NUMBER_OF_RANKS = 13
NUMBER_OF_COMBOS = 6        ; None, Single, Pair, 3, 4, 5


segment readable executable
entry main
main:
        mov        rdi, three_of_a_kind
        call       hand
        int3
        exit       0


; @param {int[]} rdi - Hand
hand:
        mov        rsi, ranks
        call       count_ranks

        mov        rdi, ranks
        mov        rsi, combos
        call       count_combos

        ;          Analyse combinations
        mov        rdi, combos
        call       is_five_of_a_kind
        cmp        rax, 1
        je         .five_of_a_kind

        mov        rdi, combos
        call       is_four_of_a_kind
        cmp        rax, 1
        je         .four_of_a_kind

        mov        rdi, combos
        call       is_full_house
        cmp        rax, 1
        je         .full_house

        mov        rdi, combos
        call       is_three_of_a_kind
        cmp        rax, 1
        je         .three_of_a_kind

        mov        rdi, combos
        call       is_two_pair
        cmp        rax, 1
        je         .two_pair

        mov        rdi, combos
        call       is_one_pair
        cmp        rax, 1
        je         .one_pair

        mov        rdi, combos
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


; @param {int[]} rdi - Combos
is_five_of_a_kind:
        xor        rax, rax
        cmp        byte [rdi + 5], 1
        sete       al
        ret


; @param {int[]} rdi - Combos
is_four_of_a_kind:
        xor        rax, rax
        cmp        byte [rdi + 4], 1
        sete       al
        ret


; @param {int[]} rdi - Combos
is_full_house:
        xor        rax, rax
        cmp        byte [rdi + 3], 1
        sete       r8b
        cmp        byte [rdi + 2], 1
        sete       al
        and        al, r8b
        ret


; @param {int[]} rdi - Combos
is_three_of_a_kind:
        xor        rax, rax
        cmp        byte [rdi + 3], 1
        sete       r8b
        cmp        byte [rdi + 1], 2
        sete       al
        and        al, r8b
        ret


; @param {int[]} rdi - Combos
is_two_pair:
        xor        rax, rax
        cmp        byte [rdi + 2], 2
        sete       al
        ret


; @param {int[]} rdi - Combos
is_one_pair:
        xor        rax, rax
        cmp        byte [rdi + 2], 1
        sete       r8b
        cmp        byte [rdi + 1], 3
        sete       al
        and        al, r8b
        ret


; @param {int[]} rdi - Combos
is_high_card:
        xor        rax, rax
        cmp        byte [rdi + 1], 5
        sete       al
        ret


; Count occurences of ones, pairs, three, four, five of a kind
;
; @param {int[]} rdi - Ranks
; @param {int[]} rsi - Combos
count_combos:
        ;          Zero array of combinations
        xor        rcx, rcx
        jmp        .l2
.l1:
        mov        byte [rsi + rcx], 0
        inc        rcx
.l2:
        cmp        rcx, NUMBER_OF_COMBOS
        jb         .l1

        ;          Count combinations
        xor        rcx, rcx
        jmp        .l4
.l3:
        ;          Read kind of combination
        movzx      r8, byte [rdi + rcx]

        ;          Increment count and index
        inc        byte [rsi + r8]
        inc        rcx
.l4:
        cmp        rcx, NUMBER_OF_RANKS
        jb         .l3
        ret


; Count occurences of 2, 3, 4, ..., T, J, K, Q, A
;
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
        cmp        rcx, NUMBER_OF_RANKS
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
        cmp        rcx, CARDS_IN_HAND
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
combos rb NUMBER_OF_COMBOS

five_of_a_kind db "AAAAA"
four_of_a_kind db "AA8AA"
full_house db "23332"
three_of_a_kind db "TTT98"
two_pair db "23432"
one_pair db "A23A4"
high_card db "23456"
