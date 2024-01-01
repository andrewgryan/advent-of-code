format ELF64 executable

; NOTE: System V ABI argument order is rdi, rsi ...
;       some code below uses rsi, rdi, ...
;       a refactor is in progress to correct it


include "util.inc"
include "parsers.asm"


NEWLINE = 0x0a


segment readable executable
entry main
main:
        ;           Scan int from arbitrary place
        mov         rdi, sample
        mov         rsi, 4        ; Row length including \n
        call        count_square
        int3

        exit        0


; Row length
row_length:
.l1:
        movzx       r8, byte [rdi]
        cmp         r8, NEWLINE
        jmp         .l1
        mov         rax, 0
        ret


; Count square
;
; @param {string} rdi - pointer to string
; @param {int}    rsi - row length
;
; @returns {int}  rax - number count
count_square:
        xor         rcx, rcx
        xor         r9, r9
.l1:
        ;           Save registers on stack
        push        rcx                     ; Loop index
        push        rdi                     ; Address
        push        rsi                     ; Row length
        push        r9                      ; Sum

        ;           Move pointer to start of row
        mov         rdx, rsi                ; Row length
        mov         rsi, rcx                ; Row index
        call        row_position

        ;           Count numbers on row
        mov         rdi, rax                ; Address
        call        count_row
        pop         r9

        ;           Sum numbers
        add         r9, rax

        pop         rsi
        pop         rdi

        ;           Next row index
        pop         rcx
        inc         rcx
        cmp         rcx, 2
        jle         .l1

        ;           Move sum to return register
        mov         rax, r9
        ret


; @param {string} rdi - address
; @param {int}    rsi - row index
; @param {int}    rdx - row length
row_position:
        mov         rax, rsi       ; result = index
        imul        rax, rdx       ; result = result * length
        add         rax, rdi       ; result += start
        ret


; Count numbers on row
;
; ... -> 0
; x.. -> 1
; .x. -> 1
; ..x -> 1
; xx. -> 1
; .xx -> 1
; xxx -> 1
; x.x -> 2
;
; @param {string} rdi - pointer to string
;
; @returns {int}  rax - overlapping number count
count_row:
        ;          ASCII to bool
        xor        rdx, rdx
        mov        rcx, 2
        mov        r8, 0
.l1:
        ;          Detect digit
        push       rdi
        movzx      rdi, byte [rdi + r8]
        call       is_digit
        pop        rdi

        ;          Move to binary position
        shl        al, cl
        add        rdx, rax

        ;          Next iteration
        inc        r8
        dec        rcx
        cmp        rcx, 0
        jge        .l1

        ;          Two numbers
        cmp        dl, 0101b
        je         .r2
        ;          Zero numbers
        cmp        dl, 0000b
        je         .r0
        ;          One number
        jmp        .r1
.r0:
        mov rax, 0
        ret
.r1:
        mov rax, 1
        ret
.r2:
        mov rax, 2
        ret


; Scan integer
;
; Side effect: Changes r8 and r10 registers
;
; @param {string} rsi - pointer to string
; @param {int}    rdi - length
; @param {string} rdx - string origin
;
; @returns {int}  rax - value under cursor
scan_int:
        ;           Save arguments on stack
        push        rsi
        push        rdi

        ; Scan to right
.l1:
        cmp         rdi, 0
        je          .d1

        push        rsi
        movzx       rsi, byte [rsi]
        call        is_digit
        pop         rsi
        cmp         rax, 0
        je          .d1

        inc         rsi
        dec         rdi
        jmp         .l1

.d1:

        ; Calculate from left
        xor         r8, r8           ; Total
        mov         r10, 1           ; Power of 10
.l2:
        ;           Move cursor left
        dec         rsi              ; Move str pointer left
        inc         rdi              ; Increase str length

        ;           Check inside string
        cmp         rsi, rdx
        jb          .d2

        ;           Check character represents digit
        push        rsi
        movzx       rsi, byte [rsi]
        call        is_digit
        pop         rsi
        cmp         rax, 0
        je          .d2

        ;           Continue summation
        push        rsi
        movzx       rsi, byte [rsi]
        call        to_digit
        pop         rsi

        ;           Add next term to sum
        imul        rax, r10         ; rax = rax * (10 ** i)
        add         r8, rax          ; r8 = r8 + rax

        ;           Raise power
        imul        r10, 0x0a        ; Raise power of 10
        jmp         .l2

.d2:
        ;           Fill return register
        mov         rax, r8

        ;           Restore arguments from stack
        pop         rdi
        pop         rsi
        ret


; @param rdi - ASCII character
is_digit:
        sub        dil, '0'
        cmp        dil, 9
        setna      al
        movzx      rax, al
        add        dil, '0'
        ret


; @param rdi - ASCII character [0-9]
to_digit:
        movzx      rax, dil
        sub        al, '0'
        ret


; Get a character
;
; @param rsi - address of str
; @param rdi - offset
;
; @returns rax - byte
getchar:
        movzx       rax, byte [rsi + rdi]
        ret


until_cog:
        mov         rcx, is_cog
        call        until
        ret


until:
.l1:
        cmp         rdi, 0
        jz          .done

        push        rsi
        movzx       rsi, byte [rsi]
        call        rcx
        pop         rsi
        cmp         rax, 1
        je          .done

        inc         rsi
        dec         rdi
        jmp         .l1
.done:
        ret


is_cog:
        cmp         sil, '*'
        sete        al
        movzx       rax, al
        ret


part_1:
        ; 1. Loop over numbers in string
        ; 2. Test each number for nearby symbols
        ; 3. Sum numbers which pass test
        mov         rsi, input
        mov         rdi, input_len

        ;           Grid width
        call        grid_width
        mov         r12, rax        ; NOTE: r12 not used anywhere

        ;           Algorithm
        xor         r8, r8
.l1:
        push        r8
        call        parse_until_digit
        pop         r8

        ;           Check string left to parse
        cmp         rdi, 0
        je          .done

        ;           Validate number
        push        r8
        push        rsi
        push        rdi
        mov         rcx, r12        ; Grid width
        mov         rdx, input      ; Original string
        call        is_valid
        pop         rdi
        pop         rsi
        push        rax

        ;           Read number, multiply by flag and add
        call        parse_number
        pop         r9
        pop         r8
        imul        r9, rax
        add         r8, r9
        cmp         rdi, 0
        ja          .l1

.done:
        ;           Answer stored in r8
        mov         rsi, r8
        call        print_register
        ret



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
        mov         [rsp + 4 * 8], dword 0    ; Number of digits
        mov         [rsp + 5 * 8], dword 0    ; Flag default True
        mov         [rsp + 6 * 8], dword 0    ; End of string address

        ;           End of string address
        add         rsi, rdi                  ; Add start to length
        mov         [rsp + 6 * 8], rsi        ; Save

        ;           Number of digits
        mov         rsi, [rsp + 0 * 8]        ; Address
        mov         rdi, [rsp + 1 * 8]        ; Length
        call        parse_number_length
        mov         [rsp + 4 * 8], rax

        ;           Character after
        mov         rsi, [rsp + 0 * 8]        ; Address
        mov         rdi, [rsp + 4 * 8]        ; Number width
        add         rsi, rdi                  ; End of number

        ;           Bounds-check
        mov         rdx, [rsp + 6 * 8]        ; End of string address
        cmp         rsi, rdx                  ; Check in string
        ja          .skip_1

        ;           Read and test
        movzx       rsi, byte [rsi]           ; Load byte
        call        is_symbol                 ; Check symbol

        ;           Bitwise OR flag
        movzx       r8, byte [rsp + 5 * 8]    ; Load flag
        or          r8b, al                   ; Flag OR rax
        mov         [rsp + 5 * 8], byte r8b   ; Save flag
.skip_1:

        ;           Character before
        mov         rsi, [rsp + 0 * 8]        ; Number address
        dec         rsi                       ; Subtract one

        ;           Bounds-check
        mov         rdx, [rsp + 3 * 8]        ; String start address
        cmp         rsi, rdx                  ; Check in string
        jb          .skip_2

        ;           Read and test
        movzx       rsi, byte [rsi]           ; Load byte
        call        is_symbol                 ; Check symbol

        ;           Bitwise OR flag
        movzx       r8, byte [rsp + 5 * 8]    ; Load flag
        or          r8b, al                   ; Flag OR rax
        mov         [rsp + 5 * 8], byte r8b   ; Save flag
.skip_2:

        ;           ROW BELOW
        mov         rcx, [rsp + 4 * 8]        ; Number width
        add         rcx, 1                    ; Add 1
.l1:
        mov         rsi, [rsp + 0 * 8]        ; Number address
        mov         rdi, [rsp + 2 * 8]        ; Grid width
        add         rsi, rdi                  ; Add to address

        ;           Check character
        lea         r8, [rsi + rcx]           ; Address of byte
        mov         r9, [rsp + 6 * 8]         ; End of string
        cmp         r8, r9                    ; Address > End
        ja          .skip_3

        ;           Read a byte
        movzx       rsi, byte [r8]            ; Load byte
        call        is_symbol                 ; Check symbol

        ;           Bitwise OR flag
        movzx       r8, byte [rsp + 5 * 8]    ; Load flag
        or          r8b, al                   ; Flag OR rax
        mov         [rsp + 5 * 8], byte r8b   ; Save flag

.skip_3:
        ;           Loop condition
        dec         rcx                       ; Reduce rcx
        cmp         rcx, 0                    ; Compare to 0
        jge         .l1                       ; Jump >= 0

        ;           ROW ABOVE
        mov         rcx, [rsp + 4 * 8]        ; Number width
        add         rcx, 1                    ; Add 1
.l2:
        mov         rsi, [rsp + 0 * 8]        ; Number address
        mov         rdi, [rsp + 2 * 8]        ; Grid width
        inc         rdi                       ; Add one
        sub         rsi, rdi                  ; Sub from address
        dec         rsi                       ; Top-left corner

        ;           Check character
        lea         r8, [rsi + rcx]           ; Address of byte
        mov         r9, [rsp + 3 * 8]         ; Start of string
        cmp         r8, r9                    ; Address < Start
        jb          .skip_4

        ;           Read a byte
        movzx       rsi, byte [r8]            ; Load byte
        call        is_symbol                 ; Check symbol

        ;           Bitwise OR flag
        movzx       r8, byte [rsp + 5 * 8]    ; Load flag
        or         r8b, al                   ; Flag OR rax
        mov         [rsp + 5 * 8], byte r8b   ; Save flag

.skip_4:
        ;           Loop condition
        dec         rcx                       ; Reduce rcx
        cmp         rcx, 0                    ; Compare to 0
        jge         .l2                       ; Jump >= 0

        ;           Flag indicating validity
        xor         rax, rax                  ; Clear register
        mov         al, byte [rsp + 5 * 8]    ; Load flag

        ;           Restore stack pointers
        mov         rsp, rbp
        pop         rbp
        ret


; @param rsi - byte
is_symbol:
        call        is_dot_or_newline
        cmp         rax, 1
        je          .fail
        mov         rax, 1
        ret
.fail:
        mov         rax, 0
        ret


; @param rsi - byte
is_dot_or_newline:
        call       is_dot
        mov        r8b, al
        call       is_newline
        or         al, r8b
        movzx      rax, al
        ret


; @param rsi - byte
is_newline:
        cmp        sil, NEWLINE
        sete       al
        movzx      rax, al
        ret


; @param rsi - byte
is_dot:
        cmp        sil, '.'
        sete       al
        movzx      rax, al
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

sample db "11.", NEWLINE, \
          "1.1", NEWLINE, \
          ".11"
sample_len = $ - sample
