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

