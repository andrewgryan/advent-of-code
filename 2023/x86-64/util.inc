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
