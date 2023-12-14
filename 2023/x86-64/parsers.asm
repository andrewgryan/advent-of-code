; Parsers
;
; A collection of parser combinators that are useful
; for Advent of Code style problems.
;
; To save memory, parsers typically increase the
; address and reduce the length of the string as
; a side-effect of successfully parsing a value
;


; Move to first successful parse
;
; A successful parse is determined based on
; a change in the length of the input string
; before/after a parse
;
; @example
;        mov        rdx, parse_digit
;        call       parse_until
;
; @param rsi - Address of string
; @param rdi - Length of string
; @param rdx - Parser
; @returns rsi, rdi - position of string
parse_until:
.next:
        ;            Empty string
        cmp          rdi, 0
        je           .done

        ;            Save string position
        push         rsi
        push         rdi

        ;            Sub-parser
        push         rdx
        call         rdx
        pop          rdx

        ; Compare return string length
        mov          r8, rdi
        pop          rdi
        pop          rsi
        cmp          r8, rdi
        jne          .done

        ; No match, try next character
        inc          rsi
        dec          rdi
        jmp          .next
.done:
        ret


; Parse a number and move string pointer
;
; @param rsi - Address
; @param rdi - Length
parse_number:
        push rsi
        push rdi
        call number_length
        pop rdi
        pop rsi
        push rax

        ; Accumulate number
        mov         r9, rax
        mov         r8, rsi
        xor         r10, r10
        mov         r11, 1

        ; Save str properties
        push        rsi
        push        rdi
.loop:
        cmp         r9, 0
        je .done

        lea         rsi, [r8 + r9 - 1] ; Address of next digit
        call        parse_digit
        imul        rax, r11   ; Multiply digit by 10**N
        add         r10, rax   ; Add to total
        imul        r11, 0x0a  ; Next power of 10
        dec         r9         ; Move pointer left
        jmp .loop
.done:
        pop         rdi        ; Length
        pop         rsi        ; Str pointer
        pop         rax        ; N digits
        add         rsi, rax   ; Move str pointer
        sub         rdi, rax   ; Reduce length
        mov         rax, r10   ; Mov value to return register
        ret


; Parse length of sequence of digits
;
; @param rsi - Address of string
; @param rdi - Length of string
number_length:
        xor r8, r8
.next:
        cmp rdi, 0
        je .done

        call parse_digit
        cmp rax, -1
        je .done

        inc r8         ; Digit counter
        inc rsi        ; String
        dec rdi        ; Length
        jmp .next
.done:
        mov rax, r8
        ret


; Parse an ASCII character [0-9]
;
; @param rsi - Address
; @param rdi - Length
; @returns number
parse_digit:
        ;          Empty string
        cmp        rdi, 0
        je         .fail

        ;          Read byte into rax
        mov        al, byte [rsi]

        ;          Below '0' code
        cmp        al, 48
        jl         .fail

        ;          Above '9' code
        cmp        al, 57
        jg         .fail

        ;          Subtract 48 and move pointer
        sub        al, 48
        inc        rsi
        dec        rdi
        ret

.fail:
        mov rax, 0
        ret
