format ELF64 executable


include "exit.asm"


segment readable executable
entry main
main:
        mov        rdi, node
        mov        rsi, network
        call       load_node
        int3
        exit       0


; AAA = (BBB, BBB)
; @param rdi Address of node line
load_node:
        .str equ rbp - 1 * 8
        .index equ rbp - 2 * 8
        push       rbp
        mov        rbp, rsp
        sub        rsp, 2 * 8
        mov        qword [.str], rdi

        mov        rdi, qword [.str]
        call       hash
        mov        qword [.index], rax

        mov        rdi, qword [.str]
        add        rdi, 7
        call       hash
        mov        rdx, qword [.index]
        mov        word [network + rdx * 4], ax

        mov        rdi, qword [.str]
        add        rdi, 12
        call       hash
        mov        rdx, qword [.index]
        mov        word [network + rdx * 4 + 2], ax

        mov        rsp, rbp
        pop        rbp
        ret


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
node db "AAB = (AAC, AAD)"
