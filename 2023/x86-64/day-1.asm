format ELF64 executable

SYS_brk = 0x0c
SYS_write = 1
SYS_exit = 60
STDOUT = 1

segment readable executable
entry main
main:
        lea r11, [input]
        mov r12, input_len
        xor r13, r13

        mov r14, 2
.loop:
        cmp r14, 0
        jle .done

        cmp r12, 0
        jle .done

        mov rsi, r11
        mov rdi, r12
        call line_length
        mov r8, rax

        mov rsi, r11
        mov rdi, r8
        call parse_line

        add r13, rax               ; Add value to total

        inc r8                     ; Include \n
        add r11, r8                ; Move to next line
        sub r12, r8                ; Reduce file length
        dec r14
        jmp .loop

.done:
        mov rsi, r13
        call print_register

        ; Exit system call
        mov rax, SYS_exit
        mov rdi, 0
        syscall


; @param rsi - Address of string
; @param rdi - Length
parse_line:

        push rdi
        push rsi
        call last_digit
        pop rsi
        pop rdi
        push rax

        push rdi
        push rsi
        call first_digit
        pop rsi
        pop rdi
        push rax

        pop rsi
        pop rdi
        call calibration_value
        ret


; @param rsi - Address of string
line_length:
        xor r8, r8                ; Count
        xor r9, r9                ; Character
.loop:
        mov r9b, byte [rsi]       ; Read ASCII byte
        cmp r9b, 0x0a             ; Compare \n
        je .done

        inc rsi                   ; Next byte
        inc r8                    ; Increment count
        jmp .loop
.done:
        mov rax, r8
        ret


; @param rsi - Address of string
; @param rdi - Length
first_digit:
.loop:
        xor r9, r9
        mov r9b, byte [rsi]        ; Read a character
        sub r9b, 48
        cmp r9b, 9
        jle .done

        dec rdi
        jz .done

        inc rsi
        jmp .loop
.done:
        mov rax, r9
        ret


; @param rsi - Address of string
; @param rdi - Length
last_digit:
        xor r10, r10
.loop:
        cmp rdi, 0
        je .done

        xor r9, r9
        mov r9b, byte [rsi]        ; Read a character
        sub r9b, 48                ; Remove ASCII 0
        cmp r9b, 9                 ; 0-9 check
        jle .save

        dec rdi                    ; Decrease length
        inc rsi                    ; Increase string pointer
        jmp .loop
.save:
        dec rdi                    ; Decrease length
        inc rsi                    ; Increase string pointer
        mov r10, r9                ; Save parsed digit
        jmp .loop
.done:
        mov rax, r10               ; Return last digit or 0
        ret


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

