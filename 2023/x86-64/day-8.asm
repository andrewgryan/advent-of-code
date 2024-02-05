format ELF64 executable

NEWLINE = 0x0A
NUMBER_OF_NODES = 718

include "exit.asm"

START = 0                         ; AAA
DESTINATION = 26 * 26 * 26 - 1    ; ZZZ


segment readable executable
entry main
main:
        mov        r9, ghosts

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

        ;          Loop over network
        call       find_route

        int3
        exit       0


find_route:
        xor        rcx, rcx                          ; Route counter
        xor        r9, r9                            ; Instruction index
        mov        rdx, START                        ; Network start point
        movzx      r11, word [instructions]          ; Instruction length
        jmp        .l1
.l2:
        xor        rax, rax                          ; Zero 64-bit rax register
        cmp        r9, r11                           ; Compare instruction index to length
        setae      al                                ; 0 or 1
        imul       rax, r11                          ; rax = (0 or 1) * N
        sub        r9, rax                           ; Subtract 0 or N

        movzx      r8, byte [instructions + r9 + 2]  ; L/R offset
        movzx      rdx, word [network + rdx*4 + r8]  ; Next address

        inc        r9                                ; Instruction counter
        inc        rcx                               ; Route counter
.l1:
        cmp        rdx, DESTINATION
        jne        .l2
        
        mov        rax, rcx
        ret


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

        mov        rdi, rax
        call       detect_ghost

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


; @param {int} rdi Number representing node
endswith_a:
        xor        rsi, rsi
        call       endswith
        ret


; @param {int} rdi Number representing node
endswith_z:
        mov        rsi, 25
        call       endswith
        ret


; @param {int} rdi Number representing node
; @param {int} rsi Letter index {0-25}
endswith:
        mov        eax, edi      ; Copy word width register
        cdq
        mov        r8w, 26       ; Register containing 26
        div        r8w           ; Divide rax by 26
        xor        rax, rax      ; Clear rax
        cmp        dx, si        ; Compare remainder to letter
        sete       al            ; Bool
        ret


detect_ghost:
        push        rdi
        call        endswith_a
        pop         rdi
        cmp         rax, 1
        je          .found
.return:
        ret
.found:
        movzx       rcx, word [ghosts]
        mov         word [ghosts + rcx * 2 + 2], di
        inc         word [ghosts]
        jmp         .return


segment readable writable
ghosts rd 512
instructions rb 512

network rd 26 * 26 * 26

code db "ZZZ"

input file "input-8"
input_len = $ - input
