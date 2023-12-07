format ELF64 executable


include "util.inc"


SYS_brk = 0x0c


segment readable executable
entry main
main:
        ; Read first line
        mov rsi, input
        mov rdi, input_len
        call line_length
        mov rdx, rax

        ; print input, rdx

        mov rsi, input
        mov rdi, input_len
        call parse_game_id
        mov rdi, rax

        mov rsi, example
        mov rdi, example_len
        call parse_number

        ; Simple memory allocator
        mov rsi, 8
        call alloc

        ; Use allocated memory
        mov [rax], dword 42
        mov [rax + 4], dword 42

        mov rsi, qword [heap_start]
        call print_register

        exit 0


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
        push rsi
        call number_length
        push rax

        ; Accumulate number
        pop r9
        pop r8
        xor r10, r10
        mov r11, 1
.loop:
        cmp r9, 0
        je .done

        lea rsi, [r8 + r9 - 1]   ; Address of next digit
        call parse_digit
        imul rax, r11        ; Multiply digit by 10**N
        add r10, rax         ; Add to total
        imul r11, 0x0a       ; Next power of 10
        dec r9               ; Move pointer left
        jmp .loop
.done:
        mov rax, r10
        ret


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


; Allocator
; @param rsi - size in bytes
; @returns rax - address of memory block
alloc:
        ; Get breakpoint address
        mov rax, SYS_brk
        mov rdi, 0
        syscall

        mov [heap_start], qword rax

        ; TODO: implement an allocation algorithm

        ; Increase breakpoint address
        lea rdi, [rax + rsi]
        mov rax, SYS_brk
        syscall
        ret


segment readable writable
input file "input-2"
input_len = $ - input

example db "42"
example_len = $ - example

game db "Game "
game_len = $ - game
red db " red"
red_len = $ - red
blue db " blue"
blue_len = $ - blue
green db " green"
green_len = $ - green

; Allocator private data
heap_start rq 1
