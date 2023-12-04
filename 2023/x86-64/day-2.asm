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

        call parse_game_id
        mov rdi, rax
        exit rdi


parse_game_id:
        mov rax, 1
        ret


segment readable writable
input file "input-2"
input_len = $ - input
