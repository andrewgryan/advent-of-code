format ELF64 executable


include "exit.asm"


segment readable executable
entry main
main:
        mov        rdi, node
        call       hash
        int3
        exit       0


; @param rdi Address of node
hash:
        xor        rax, rax
        xor        rcx, rcx
        mov        r9, 2
        mov        r10, 1
        jmp        .l1
.l2:
        movzx      r11, byte [rdi + r9]   ; Read character
        sub        r11, 'A'               ; Convert to number
        imul       r11, r10               ; Multiply by base
        add        rax, r11               ; Sum accumulator
        inc        rcx                    ; Increase counter
        dec        r9
        imul       r10, 26                ; Next power of 26
.l1:
        cmp        rcx, 3
        jb         .l2
        ret


segment readable writable
network rw 26 * 26 * 26
node db "ABC"
