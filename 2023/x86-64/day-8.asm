format ELF64 executable

NEWLINE = 0x0A
NUMBER_OF_NODES = 718

include "exit.asm"


segment readable executable
entry main
main:
        mov        r9, network

        mov        rdi, input
        mov        rsi, input_len
        call       load_instructions

        ;          Skip instruction block
        add        rdi, rax
        sub        rsi, rax

        ;          Skip \n\n
        add        rdi, 2
        sub        rsi, 2

        call       load_network

        int3
        exit       0


; @param {str} rdi address of input
; @param {int} rsi length of input
; @returns {int} parsed length
load_instructions:
        xor        rcx, rcx
        jmp        .l1
.l2:
        cmp        byte [rdi + rcx], 'R'
        sete       dl
        shl        dl, 1
        mov        byte [instructions + rcx + 2], dl
        inc        word [instructions]
        inc        rcx
.l1:
        cmp        byte [rdi + rcx], NEWLINE
        jne        .l2

        mov        rax, rcx        ; Return parsed length
        ret


; @param {str} rdi Address of network string
load_network:
        xor        rcx, rcx
        jmp        .l1
.l2:
        push       rcx
        call       load_node
        pop        rcx

        ;          Skip \n
        inc        rdi
        dec        rsi

        inc        rcx
.l1:
        cmp        rcx, NUMBER_OF_NODES
        jb         .l2
        ret


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

        ;          Move pointer to end of tuple
        add        rdi, 4
        sub        rsi, 4

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
instructions rb 512

network rd 26 * 26 * 26
node db "AAB = (GGG, ZZZ)"

input file "input-8"
input_len = $ - input
