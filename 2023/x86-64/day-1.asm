format ELF64 executable

SYS_write = 1
SYS_exit = 60
STDOUT = 1

segment readable executable
entry main
main:
        ; Solution
        xor rcx, rcx          ; Zero register
        xor rdi, rdi          ; Zero register
        mov r8, input         ; Copy address
        mov r9, input_len     ; Copy length

.loop:
        mov dil, byte [r8]
        ; sub dil, 48
        ; cmp dil, 9

        dec r9
        jz .done

        cmp rdi, 0x0a        ; Newline
        je .loop_line

        inc r8
        jmp .loop

.loop_line:
        inc rcx        ; Increment line counter
        inc r8         ; Increment file pointer
        jmp .loop      ; Continue

.done:
        ; mov rax, 0x0a        ; rax = 10
        ; mul rdi              ; rax = rax * rdi
        ; add rax, rdi         ; rax = rax + rdi

        ; Exit system call
        mov rax, SYS_exit
        mov rdi, rcx
        syscall


segment readable writable
input file "input-1"
input_len = $ - input

