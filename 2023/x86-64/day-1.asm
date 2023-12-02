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

        ; Detect first number
        xor rdi, rdi  ; Reset rdi buffer
        mov r8, input ; Copy address
.loop:
        mov dil, byte [r8]
        sub dil, 48
        cmp dil, 9
        jle .done

        inc r8
        jmp .loop
.done:

        ; Exit system call
        mov rax, SYS_exit
        ; mov rdi, 0
        syscall


segment readable writable
input file "input-1"
input_len = $ - input

