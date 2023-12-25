format ELF64 executable


include "util.inc"
include "parsers.asm"


NEWLINE = 0x0a


segment readable executable
entry main
main:
        ; 1. Loop over numbers in string
        ; 2. Test each number for nearby symbols
        ; 3. Sum numbers which pass test
        mov         rsi, input
        mov         rdi, input_len
        xor         r8, r8
.l1:
        push        r8
        call        parse_until_digit

        call        is_valid
        push        rax

        call        parse_number
        pop         r9
        pop         r8
        imul        r9, rax
        add         r8, r9
        cmp         rdi, 0
        ja          .l1
        int3

        exit        0


; Detect a valid digit by examining it's surrounding chars
;
; @param rsi: remaining str address
; @param rdi: remaining str length
; @param rcx: grid width
; @param rdx: origin str address
; @returns rax: bool indicating validity
is_valid:
        ;           Allocate stack
        push        rbp
        mov         rbp, rsp
        sub         rsp, 16

        ;           Flag
        mov         [rsp + 8], dword 0

        ;           Save number length on stack
        call        parse_number_length
        mov         [rsp], rax

        ;           Character after
        push        rsi
        mov         r8, [rsp]                 ; load len(s)
        xor         rsi, rsi
        mov         sil, byte [rsi + r8 + 1]  ; *str + len(s) + 1
        call        is_symbol
        pop         rsi

        ;           Accumulate flag
        xor         r8, r8
        mov         r8b, byte [rsp + 8]
        and         r8b, al
        mov         [rsp + 8], byte al

        ;           Character before
        push        rsi
        dec         rsi
        mov         sil, byte [rsi]           ; *str - 1
        call        is_symbol
        pop         rsi

        ;           Accumulate flag
        xor         r8, r8
        mov         r8b, byte [rsp + 8]
        and         r8b, al
        mov         [rsp + 8], byte al

        ;           Row below
        mov         rcx, [rsp]
.l1:
        dec         rcx
        cmp         rcx, 0
        ja          .l1

        ;           Row above
        mov         rcx, [rsp]
.l2:
        dec         rcx
        cmp         rcx, 0
        ja          .l2

        ;           Flag indicating validity
        xor         rax, rax
        mov         al, byte [rsp + 8]

        ;           Restore stack pointers
        mov         rsp, rbp
        pop         rbp
        ret


; @param rsi - byte
is_symbol:
        call        is_digit
        push        rax

        call        is_dot
        push        rax

        ;           Compare digit(c) and dot(c)
        pop         r8
        pop         r9
        add         r8, r9
        cmp         r8, 0
        je          .succeed
        mov         rax, 0
        ret
.succeed:
        mov         rax, 1
        ret


; @param rsi - byte
is_digit:
        sub        sil, '0'
        cmp        sil, 9
        ja         .fail
        add        sil, '0'
        mov        rax, 1
        ret
.fail:
        add        sil, '0'
        mov        rax, 0
        ret


; @param rsi - byte
is_dot:
        cmp        sil, '.'
        jne        .fail
        mov        rax, 1
        ret
.fail:
        mov        rax, 0
        ret


; SOLUTION
solution:
        ; Load puzzle input
        mov         rsi, input
        mov         rdi, input_len

        call        grid_width
        push        rax

        call        grid_height
        push        rax

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
        ret


parse_until_digit:
        mov        rdx, parse_digit
        call       parse_until
        ret


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

sample db "...", NEWLINE, \
          ".9.", NEWLINE, \
          "...", NEWLINE
sample_len = $ - sample
