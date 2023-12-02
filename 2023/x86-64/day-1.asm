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

        ; Count line length
        mov rdi, input
        call line_length

        ; Exit system call
        mov rdi, rax
        mov rax, SYS_exit
        syscall


line_length:
        xor rsi, rsi          ; Reset rsi register
        xor r8, r8            ; Reset r8 register
.loop:
        mov sil, byte [rdi]   ; Read a byte
        cmp sil, 10           ; Compare to newline code
        je .done

        inc rdi               ; Move to next byte
        inc r8                ; Increment counter
        jmp .loop
.done:
        mov rax, r8
        ret


segment readable writable
input file "input-1"
input_len = $ - input

