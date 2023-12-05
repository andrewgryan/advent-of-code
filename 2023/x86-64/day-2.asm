format ELF64 executable


include "util.inc"


segment readable executable
entry main
main:
        ; Read first line
        mov rsi, input
        mov rdi, input_len
        call line_length
        mov rdx, rax

        print input, rdx

        mov rsi, input
        mov rdi, input_len
        call parse_game_id
        mov rdi, rax

        mov rsi, example
        mov rdi, example_len
        call parse_green
        mov rdi, rax
        exit rdi


; @param rsi - Address
; @param rdi - Length
parse_blue:
        mov rdx, blue
        mov rcx, blue_len
        call parse_color
        ret


; @param rsi - Address
; @param rdi - Length
parse_red:
        mov rdx, red
        mov rcx, red_len
        call parse_color
        ret


; @param rsi - Address
; @param rdi - Length
parse_green:
        mov rdx, green
        mov rcx, green_len
        call parse_color
        ret


; @param rsi - Address
; @param rdi - Length
; @param rdx - Keyword
; @param rcx - Length
parse_color:
        push rdi
        push rsi
        call parse_number
        pop rsi
        pop rdi
        push rax
        cmp rax, -1
        je .fail

        inc rsi
        dec rdi

        push rdi
        push rsi
        call parse_prefix
        pop rsi
        pop rdi
        cmp rax, 0
        je .fail

        pop rax
        ret

.fail:
        pop rax
        mov rax, -1
        ret


; @param rsi - Address
; @param rdi - Length
parse_game_id:
        mov rdx, game
        mov rcx, game_len
        call parse_prefix
        cmp rax, 1
        je .id
        mov rax, -1
        ret
.id:
        add rsi, rcx
        call parse_digit
        ret


; @param rsi - Address
; @param rdi - Length
parse_number:
        call parse_digit

        ; Multiply by 10
        imul rax, 0x0a
        ret


; @param rsi - Address
parse_digit:
        mov al, byte [rsi]

        cmp al, 48
        jl .fail

        cmp al, 57
        jg .fail

        sub al, 48
        ret

.fail:
        mov rax, -1
        ret


segment readable writable
input file "input-2"
input_len = $ - input

example db "7 green"
example_len = $ - example

game db "Game "
game_len = $ - game
red db " red"
red_len = $ - red
blue db " blue"
blue_len = $ - blue
green db " green"
green_len = $ - green
