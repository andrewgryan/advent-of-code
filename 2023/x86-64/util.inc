SYS_exit = 60
SYS_brk = 0x0c
SYS_write = 1
STDOUT = 1


macro print buf, len {
        mov rax, SYS_write
        mov rdi, STDOUT
        mov rsi, buf      ; String address
        mov rdx, len      ; String length
        syscall
}

macro exit code {
        mov rax, SYS_exit
        mov rdi, code
        syscall
}


; @param rsi - Address of string
; @param rdi - Length
; @returns rax - Length of line including \n
get_line:
        xor r8, r8                ; Count
        xor r9, r9                ; Character
        xor r10, r10              ; Pointer
        xor r11, r11

        mov r10, rsi
        mov r11, rdi
.loop:
        cmp r11, 0                ; End of string
        je .done

        mov r9b, byte [r10]       ; Read ASCII byte
        cmp r9b, 0x0a             ; Compare \n
        je .newline

        inc r10                   ; Next byte
        inc r8                    ; Increment count
        dec r11                   ; Decrement length
        jmp .loop

.newline:
        inc r8
        mov rax, r8
        ret

.done:
        mov rax, r8
        ret


; @param rsi - Address of string
; @param rdi - Length
line_length:
        xor r8, r8                ; Count
        xor r9, r9                ; Character
.loop:
        cmp rdi, 0                ; End of string
        je .done

        mov r9b, byte [rsi]       ; Read ASCII byte
        cmp r9b, 0x0a             ; Compare \n
        je .done

        inc rsi                   ; Next byte
        inc r8                    ; Increment count
        dec rdi                   ; Decrement length
        jmp .loop
.done:
        mov rax, r8
        ret


; @param rsi - Address of string
; @param rdi - Length
; @param rdx - Address of pattern
; @param rcx - Length
parse_prefix:
        xor r8, r8
        xor r9, r9
        xor rax, rax
.loop:
        ; Check string characters remain
        cmp rdi, 0
        je .done

        ; Check prefix characters remain
        cmp rcx, 0
        je .done

        ; Compare characters
        mov r8b, byte [rsi]
        mov r9b, byte [rdx]
        cmp r8b, r9b
        jne .done

        ; Next characters
        inc rsi                ; Next string byte
        dec rdi                ; Reduce string length
        inc rdx                ; Next prefix byte
        dec rcx                ; Reduce prefix length

        jmp .loop
.done:
        cmp rcx, 0
        je .success

        ; Failed to find a full prefix match
        mov rax, 0
        ret

.success:
        ; Matched all prefix characters
        mov rax, 1
        ret


; @param rsi - number to print
print_register:
        ; Estimate width in base 10
        xor r8, r8           ; Set r8 to zero
        mov rcx, 0x0a        ; Set divisor to 10
        mov rax, rsi         ; Copy register
.decimal_places:
        inc r8
        xor rdx, rdx
        div rcx
        cmp rax, 0
        jnz .decimal_places
        push r8              ; Save width on stack

        ; Call brk to request memory address space
        mov rax, SYS_brk
        mov rdi, 0
        syscall

        ; Ask for a new breakpoint
        lea rdi, [rax + r8]
        mov rax, SYS_brk
        syscall

        ; Save previous breakpoint location
        mov r11, rax         ; Copy string address
        push r11             ; Save string address

        ; Copy characters
        mov rax, rsi         ; Copy register
.copy_digits:
        dec r8               ; Decrement digit counter
        lea r9, [r11 + r8]   ; Next effective address

        ; Divide number by 10
        mov rcx, 0x0a        ; Set divisor to 10
        xor rdx, rdx         ; Clear dividend register
        div rcx              ; Perform unsigned division by 10

        ; Write ASCII character
        mov r10, rax         ; Save division
        add rdx, 48          ; Convert remainder to ASCII
        mov byte [r9], dl    ; Place digit in buffer

        ; Loop condition
        cmp r10, 0           ; Check division non-zero
        jnz .copy_digits

        ; Print system call
        mov rax, SYS_write
        mov rdi, STDOUT
        pop rsi              ; String address
        pop rdx              ; Retrieve string length
        syscall
        ret
