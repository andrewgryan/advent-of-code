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
        exit rdi


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

game db "Game "
game_len = $ - game
