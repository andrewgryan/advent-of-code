SYS_exit = 60

macro exit code {
        mov rax, SYS_exit
        mov rdi, code
        syscall
}
