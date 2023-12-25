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
        mov         rsi, sample
        mov         rdi, sample_len

        ;           Grid width
        call        grid_width
        mov         r12, rax        ; NOTE: r12 not used anywhere

        ;           Algorithm
        xor         r8, r8
.l1:
        push        r8
        call        parse_until_digit

        push        rsi
        push        rdi
        mov         rcx, r12        ; Grid width
        mov         rdx, sample      ; Original string
        call        is_valid
        pop         rdi
        pop         rsi
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
        sub         rsp, 7 * 8

        ;           Local variables
        mov         [rsp + 0 * 8], rsi        ; Address
        mov         [rsp + 1 * 8], rdi        ; Length
        mov         [rsp + 2 * 8], rcx        ; Grid width
        mov         [rsp + 3 * 8], rdx        ; Global address
        mov         [rsp + 4 * 8], dword 0    ; Number width
        mov         [rsp + 5 * 8], dword 0    ; Flag
        mov         [rsp + 6 * 8], dword 0    ; End of string

        ;           End of string
        add         rsi, rdi                  ; End of string
        mov         [rsp + 6 * 8], rsi        ; Save

        call        parse_number_length
        mov         [rsp + 4 * 8], rax

        ;           Character after
        mov         rsi, [rsp + 0 * 8]        ; Address
        mov         rdi, [rsp + 4 * 8]        ; Number width
        add         rsi, rdi                  ; End of number

        ;           Bounds-check
        mov         rdx, [rsp + 3 * 8]        ; Global address
        cmp         rsi, rdx                  ; Check in string
        jb          .skip_1

        ;           Read and test
        mov         sil, byte [rsi]           ; Load byte
        call        is_symbol                 ; Check symbol

        ;           Bitwise OR flag
        xor         r8, r8                    ; Clear register
        mov         r8b, byte [rsp + 5 * 8]   ; Load flag
        or          r8b, al                   ; Flag OR rax
        mov         [rsp + 5 * 8], byte r8b   ; Save flag
.skip_1:

        ;           Character before
        mov         rsi, [rsp + 0 * 8]        ; Address
        dec         rsi                       ; Subtract one

        ;           Bounds-check
        mov         rdx, [rsp + 3 * 8]        ; Global address
        cmp         rsi, rdx                  ; Check in string
        jb          .skip_2

        ;           Read and test
        mov         sil, byte [rsi]           ; Load byte
        call        is_symbol                 ; Check symbol

        ;           Bitwise OR flag
        xor         r8, r8                    ; Clear register
        mov         r8b, byte [rsp + 5 * 8]   ; Load flag
        or          r8b, al                   ; Flag OR rax
        mov         [rsp + 5 * 8], byte r8b   ; Save flag
.skip_2:

        ;           Loop counter
        mov         rcx, [rsp + 4 * 8]        ; Number width
        add         rcx, 2                    ; Add 2
.l1:
        ;           Row below
        mov         rsi, [rsp + 0 * 8]        ; Address
        mov         rdi, [rsp + 2 * 8]        ; Grid width
        inc         rdi                       ; Add one
        add         rsi, rdi                  ; Add to address

        ;           Check character
        lea         r8, [rsi + rcx]           ; Address of byte
        mov         r9, [rsp + 6 * 8]         ; End of string
        cmp         r8, r9                    ; Address > End
        ja          .skip_3

        ;           Read a byte
        mov         sil, byte [r8]            ; Load byte
        call        is_symbol                 ; Check symbol

        ;           Bitwise OR flag
        xor         r8, r8                    ; Clear register
        mov         r8b, byte [rsp + 5 * 8]   ; Load flag
        or          r8b, al                   ; Flag OR rax
        mov         [rsp + 5 * 8], byte r8b   ; Save flag

.skip_3:
        ;           Loop condition
        dec         rcx                       ; Reduce rcx
        cmp         rcx, 0                    ; Compare to 0
        jl          .l1                       ; Jump < 0

        ;           Loop counter
        mov         rcx, [rsp + 4 * 8]        ; Number width
        add         rcx, 2                    ; Add 2
.l2:
        ;           Row above
        mov         rsi, [rsp + 0 * 8]        ; Address
        mov         rdi, [rsp + 2 * 8]        ; Grid width
        inc         rdi                       ; Add one
        sub         rsi, rdi                  ; Sub from address

        ;           Check character
        lea         r8, [rsi + rcx]           ; Address of byte
        mov         r9, [rsp + 6 * 8]         ; End of string
        cmp         r8, r9                    ; Address > End
        jb          .skip_4

        ;           Read a byte
        mov         sil, byte [r8]            ; Load byte
        call        is_symbol                 ; Check symbol

        ;           Bitwise OR flag
        xor         r8, r8                    ; Clear register
        mov         r8b, byte [rsp + 5 * 8]   ; Load flag
        or          r8b, al                   ; Flag OR rax
        mov         [rsp + 5 * 8], byte r8b   ; Save flag

.skip_4:
        ;           Loop condition
        dec         rcx                       ; Reduce rcx
        cmp         rcx, 0                    ; Compare to 0
        jl          .l2                       ; Jump < 0

        ;           Flag indicating validity
        xor         rax, rax                  ; Clear register
        mov         al, byte [rsp + 5 * 8]    ; Load flag

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
          ".9#", NEWLINE, \
          "...", NEWLINE
sample_len = $ - sample
