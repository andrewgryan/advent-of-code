format ELF64 executable


include "util.inc"
include "parsers.asm"


NEWLINE = 0x0a


segment readable executable
entry main
main:
        ; Load puzzle input
        mov         rsi, input
        mov         rdi, input_len

        call        grid_width
        push        rax
        int3

        call        grid_height
        push        rax
        int3

        xor        r8, r8
.next:
        ;          Empty string
        cmp        rdi, 0
        je         .done

        ;          Parse until digit
        push       r8
        mov        rdx, parse_digit
        call       parse_until
        pop        r8

        ;          Empty string
        cmp        rdi, 0
        je         .done

        push       r8
        call       parse_number
        pop        r8
        add        r8, rax

        jmp        .next

.done:
        int3
        exit        0


search_perimeter:
        mov        rax, 1
        ret


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

sample db ".....123.....456.....Hello, World!"
sample_len = $ - sample
