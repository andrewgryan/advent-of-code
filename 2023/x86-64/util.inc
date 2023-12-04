SYS_exit = 60
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
