format ELF64 executable


include "util.inc"
include "parsers.asm"


NEWLINE = 0x0a


segment readable executable
entry main
main:
        ; Load puzzle input
        mov         rsi, sample
        mov         rdi, sample_len

        ; Parse until first digit
        mov        rdx, parse_digit
        call       parse_until
        call       parse_number_length
        int3
        exit        0


grid_width:
        ;          Store string on stack
        push       rdi
        push       rsi
        xor        rax, rax
.next:
        ;          Compare length
        cmp        rdi, 0
        je         .done

        ;          Read character
        mov        r8b, [rsi]
        cmp        r8, NEWLINE
        je         .done

        ;          Advance pointer
        inc        rsi
        dec        rdi

        ;          Add one
        inc        rax
        jmp        .next

.done:
        ;          Restore string
        pop        rsi
        pop        rdi
        ret


grid_height:
        ;          Store string on stack
        push       rdi
        push       rsi
        xor        rax, rax
.next:
        ;          Compare length
        cmp        rdi, 0
        je         .done

        ;          Read character
        mov        r8b, [rsi]
        cmp        r8, NEWLINE
        je         .add_one

        ;          Advance pointer
        inc        rsi
        dec        rdi
        jmp        .next

.add_one:
        ;          Advance pointer
        inc        rsi
        dec        rdi

        ;          Add one
        inc        rax
        jmp        .next

.done:
        ;          Restore string
        pop        rsi
        pop        rdi
        inc        rax
        ret


segment readable writable
input file "input-3"
input_len = $ - input

sample db ".....123abcdefghijklmnop"
sample_len = $ - sample
