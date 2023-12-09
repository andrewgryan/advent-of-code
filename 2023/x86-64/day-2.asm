format ELF64 executable


include "util.inc"


SYS_brk = 0x0c


segment readable executable
entry main
main:
        mov rsi, input
        mov rdi, input_len
        mov rdx, 4
        call head

        exit 0


head:
        mov rsi, input
        mov rdi, input_len
        xor r12, r12
.loop:
        cmp rdx, 0
        je .exit

        ; Measure line
        push rdx
        call get_line
        push rax

        ; Score current line
        ; mov rsi, ???
        ; mov rdi, ???
        push rsi
        push rdi
        mov rdi, rax
        call score_line
        add r12, rax
        pop rdi
        pop rsi

        ; Print current line
        pop r9
        mov r8, rsi
        push rsi
        push rdi
        print r8, r9
        pop rdi
        pop rsi
        pop rdx

        ; Move to next line
        add rsi, r9
        sub rdi, r9

        dec rdx        ; Decrement line counter
        jmp .loop

.exit:
        push rsi
        push rdi
        mov rsi, r12
        call print_register
        pop rdi
        pop rsi
        ret


score_line:
        xor rax, rax
        call parse_game_id
        ret


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
        push rdi
        push rsi
        push rcx
        call parse_prefix
        pop rcx
        pop rsi
        pop rdi
        cmp rax, 1
        je .id
        mov rax, -1
        ret
.id:
        add rsi, rcx
        sub rdi, rcx
        call parse_number
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

        mov [heap_end], qword rax

        ret


segment readable writable
input file "input-2"
input_len = $ - input

example db "Game 42:\n"
example_len = $ - example

game db "Game "
game_len = $ - game
red db " red"
red_len = $ - red
blue db " blue"
blue_len = $ - blue
green db " green"
green_len = $ - green

newline db 0x0a

; Allocator private data
heap_start dq 0
heap_end dq 0
