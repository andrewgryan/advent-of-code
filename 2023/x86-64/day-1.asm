format ELF64 executable

SYS_write = 1
SYS_exit = 60
STDOUT = 1

segment readable executable
entry main
main:
        ; Print
        mov rax, SYS_write
        mov rdi, STDOUT
        mov rsi, input
        mov rdx, input_len
        syscall

        ; Exit system call
        mov rax, SYS_exit
        xor rdi, rdi
        mov dil, byte [input]
        syscall


segment readable writable
input file "input-1"
input_len = $ - input

