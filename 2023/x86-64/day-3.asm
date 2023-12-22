format ELF64 executable


include "util.inc"
include "parsers.asm"


NEWLINE = 0x0a


segment readable executable
entry main
main:
        xor        r10, r10
        mov        r8, 0        ; i = 0
.l1:
        mov        r9, 0        ; j = 0
.l2:
        ;          i + j
        inc        r10

        ;          j++
        inc        r9
        cmp        r9, 10
        jb         .l2

        ;          i++
        inc        r8
        cmp        r8, 5
        jb         .l1
        int3

        exit        0


_main:
        ;           Save stack pointer(s)
        push        rbp
        mov         rbp, rsp
        sub         rsp, 16        ; Allocate bytes

        ;           Load test data
        mov         rsi, sample
        mov         rdi, sample_len

        ;           Estimate grid width
        call        grid_width
        mov         [rsp], byte al

        ;           Parse until digit
        mov         rsi, sample
        mov         rdi, sample_len
        call        parse_until_digit

        mov         [rsp + 8], qword rsi    ; Store str pointer on stack
        xor         rsi, rsi                ; Clear str pointer register

        ;           Byte before number
        mov         r8, qword [rsp + 8]
        mov         sil, byte [r8 - 1]
        call        is_symbol

        ;           Byte after number
        mov         r8, qword [rsp + 8]
        mov         sil, byte [r8 + 1]
        call        is_symbol

        ;           Bytes below number
        mov         r10, 3                 ; Halo width
        movzx       r9d, byte [rsp]        ; Grid width
        mov         r8, qword [rsp + 8]    ; Number address
        dec         r8
        add         r8, r9                 ; Lower-left corner
.next:
        ;           Loop body
        int3
        movzx       esi, byte [r8 + rcx]
        push        r8
        call        is_symbol
        pop         r8

        ;           Loop logic
        inc         rcx
        cmp         rcx, r10               ; Check halo width
        je          .cont
        jmp         .next
.cont:


        pop         rbp        ; Restore base pointer
        exit        0




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
