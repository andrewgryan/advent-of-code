format ELF64 executable

SYS_brk = 0x0c
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
        mov dil, byte [r8]        ; Read a character
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

        mov rsi, 9
        mov rdi, 5
        call calibration_value

        mov rsi, rax
        call print_register

        ; Exit system call
        mov rax, SYS_exit
        mov rdi, 0
        syscall


; @param rsi - First digit
; @param rdi - Second digit
calibration_value:
        mov rax, 0x0a        ; rax = 10
        mul rsi              ; rax = rax * rsi
        add rax, rdi         ; rax = rax + rdi
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


segment readable writable
input file "input-1"
input_len = $ - input

