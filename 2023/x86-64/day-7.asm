format ELF64 executable


include "util.inc"


segment readable executable
entry main
main:
        mov        rdi, five_of_a_kind
        call       is_five_of_a_kind
        mov        rdi, full_house
        call       is_five_of_a_kind
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


is_four_of_a_kind:
        mov        rax, 1
        ret


is_full_house:
        mov        rax, 1
        ret


is_three_of_a_kind:
        mov        rax, 1
        ret


is_two_pair:
        mov        rax, 1
        ret


is_one_pair:
        mov        rax, 1
        ret


is_high_card:
        mov        rax, 1
        ret


segment readable writable
order db "23456789TJQKA"

five_of_a_kind db "AAAAA"
four_of_a_kind db "AA8AA"
full_house db "23332"
three_of_a_kind db "TTT98"
two_pair db "23432"
one_pair db "A23A4"
high_card db "23456"
