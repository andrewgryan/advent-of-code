format ELF64 executable


include "util.inc"

MAX_WINNERS = 10
LINE_LENGTH = 117
NUMBER_OF_CARDS = 198


segment readable executable
entry main
main:
        mov        r10, scores
        mov        r11, copies

        call       reset_copies

        ;          Loop over Cards
        xor        rcx, rcx
        xor        rdx, rdx
        mov        rdi, input
.l1:
        push       rdi
        push       rcx
        push       rdx
        mov        rsi, rcx
        call       play_scratchcard
        pop        rdx
        pop        rcx
        pop        rdi

        ;          Accumulate score
        add        rdx, rax

        ;          Next card
        add        rdi, LINE_LENGTH
        inc        rcx
        cmp        rcx, NUMBER_OF_CARDS
        jb         .l1

        ;          Print result
        mov        rsi, rdx
        call       print_register
        
        exit       0


example:
        ; Example from puzzle description
        ;
        ; Card | Score | #   | Copies
        ;    1 | 4     | 1   | 1
        ;    2 | 2     | 2   | 1, 1,
        ;    3 | 2     | 4   | 1, 1, 2
        ;    4 | 1     | 8   | 1, 1, 2, 4
        ;    5 | 0     | 14  | 1, 1,    4, 8
        ;    6 | 0     | 1   | 1,
        ; ----- -------  --
        ; Total          30

        xor        rcx, rcx

        ;          Card 1
        mov        rdi, 4
        mov        rsi, 0
        push       rcx
        call       count_copies
        pop        rcx
        add        rcx, rax

        ;          Card 2
        mov        rdi, 2
        mov        rsi, 1
        push       rcx
        call       count_copies
        pop        rcx
        add        rcx, rax

        ;          Card 3
        mov        rdi, 2
        mov        rsi, 2
        push       rcx
        call       count_copies
        pop        rcx
        add        rcx, rax

        ;          Card 4
        mov        rdi, 1
        mov        rsi, 3
        push       rcx
        call       count_copies
        pop        rcx
        add        rcx, rax

        ;          Card 5
        mov        rdi, 0
        mov        rsi, 4
        push       rcx
        call       count_copies
        pop        rcx
        add        rcx, rax

        ;          Card 6
        mov        rdi, 0
        mov        rsi, 5
        push       rcx
        call       count_copies
        pop        rcx
        add        rcx, rax

        ;          Print result
        mov        rsi, rcx
        call       print_register
        exit       0

reset_copies:
        xor        rcx, rcx
.l1:
        mov        qword [copies + 8 * rcx], 0
        inc        rcx
        cmp        rcx, NUMBER_OF_CARDS
        jb         .l1
        ret


; @params {address} rdi - Card
; @param {int}      rsi - Card index
play_scratchcard:
        push       rbp
        mov        rbp, rsp
        sub        rsp, 8
        mov        qword [rbp - 8], rsi

        ;          Load scratch card
        push       rdi
        call       read_winners
        pop        rdi

        push       rdi
        call       read_numbers
        pop        rdi

        push       rdi
        call       encode_winners
        call       check_numbers
        pop        rdi

        push       rdi
        mov        rdi, rax
        mov        rsi, qword [rbp - 8]
        call       count_copies
        pop        rdi

        mov        rsp, rbp
        pop        rbp
        ret


; Puzzle input
; Card | Score | #   | Copies
;    1 | 3     | 1   | 1
;    2 | 5     | 2   | 1, 1
;    3 | 10    | 4   | 1, 1, 2
;    4 | 7     | 8   | 1, 1, 2, 4
;    5 | 9     | 15  | 1,    2, 4, 8
;    6 | 10    | 30  | 1,    2, 4, 8, 15
;    7 | 10    | 60  | 1,    2, 4, 8, 15, 30
;    8 | 5     | 118 | 1,       4, 8, 15, 30, 60
; ----- -------  --
; Total          238
;
; @param {int} rdi - card matched numbers
; @param {int} rsi - card index
count_copies:
        ;          Sum copies contributing to current card
        xor        rcx, rcx
        mov        rdx, 1                     ; Original copy
.l1:
        ;          Logic to accumulate cards
        xor        rax, rax
        push       rsi                         ; Card index
        sub        rsi, rcx                    ; Distance = Card index - loop index
        cmp        sil, byte [scores + rcx]    ; Compare Score to Distance
        setbe      al                          ; Accumulator = Score <= Distance
        pop        rsi                         ; Card index

        imul       rax, qword [copies + 8 * rcx]
        add        rdx, rax

        inc        rcx                        ; Increment index
        cmp        rcx, rsi                   ; Below Card index
        jb         .l1

        ;          Save copies to array
        mov        qword [copies + 8 * rsi], rdx
        mov        byte [scores + rsi], dil

        ;          Return copies
        mov        rax, rdx
        ret



check_numbers:
        ;          Check numbers
        xor        rax, rax
        xor        rcx, rcx
        xor        rdx, rdx
.l1:
        ;          Count winning numbers
        push       rcx
        push       rdx
        movzx      rdi, byte [numbers + rcx]
        call       confirm
        pop        rdx
        pop        rcx
        add        rdx, rax
        inc        rcx
        cmp        rcx, 25
        jb         .l1

        mov        rax, rdx
        ret


double_points:
        ;          Double points logic
        cmp        rdx, 0
        je         .zero

        ;          1, 2, 4, 8, ...
        mov        cl, dl
        dec        cl
        mov        rax, 1
        shl        rax, cl
        ret

.zero:
        mov        rax, 0
        ret


confirm:
        cmp        rdi, 50
        jb         .lower

.upper:
        ;          Encode value to bit mask
        sub        rdi, 50
        call       encode_byte
        add        rdi, 50

        ;          Compare to mask
        mov        r8, rax
        and        r8, qword [upper]
        setnz      r8b
        movzx      rax, r8b
        ret

.lower:
        ;          Encode value to bit mask
        call       encode_byte

        ;          Compare to mask
        mov        r8, rax
        and        r8, qword [lower]
        setnz      r8b
        movzx      rax, r8b
        ret


; 100-bit encode scratch card
encode_winners:
        ;          Reset 64-bit masks
        mov        rdi, winners
        mov        qword [upper], 0
        mov        qword [lower], 0
        xor        rcx, rcx
.l1:
        push       rdi
        push       rcx
        movzx      rdi, byte [rdi]
        call       encode
        pop        rcx
        pop        rdi

        inc        rdi
        inc        rcx
        cmp        rcx, 10
        jb         .l1


; @param {byte} rdi - Number [0-99]
encode:
        cmp        rdi, 50
        jb         .lower
.upper:
        sub        rdi, 50
        call       encode_byte
        add        rdi, 50
        or         qword [upper], rax
        ret
.lower:
        call       encode_byte
        or         qword [lower], rax
        ret


; @param {byte} rdi - Number [0-49]
encode_byte:
        mov        rcx, rdi
        mov        rax, 1
.l1:
        cmp        rcx, 8
        jb         .d1
        shl        rax, 8
        sub        rcx, 8
        jmp        .l1
.d1:
        shl        rax, cl
        ret


; @param   {address} rdi - input text
read_winners:
        add         rdi, 10        ; Offset
        mov         rsi, winners
        mov         rdx, 10        ; Array length
        call        read_array
        ret


; @param   {address} rdi - input text
read_numbers:
        add         rdi, 42        ; Offset
        mov         rsi, numbers
        mov         rdx, 25        ; Array length
        call        read_array
        ret


; @param   {address} rdi - input text
; @param   {address} rsi - output data
; @param   {int}     rdx - array length
read_array:
        ;          Prepare stack
        push       rbp
        mov        rbp, rsp
        sub        rsp, 32
        .input  equ rbp - 3 * 8
        .output equ rbp - 2 * 8
        .length equ rbp - 1 * 8

        ;          Save arguments on stack
        mov        [.input], rdi
        mov        [.output], rsi
        mov        [.length], rdx

        ;          Loop over numbers
        xor        rax, rax
        xor        rdx, rdx
        xor        rcx, rcx
.l1:
        mov        rdx, [.input]
        imul       r8, rcx, 3
        add        rdx, r8                ; input + 3*i
        movzx      rsi, byte [rdx]
        movzx      rdi, byte [rdx + 1]
        call       to_number
        mov        rdx, [.output]
        add        rdx, rcx               ; output + i
        mov        [rdx], al

        inc        rcx
        cmp        rcx, [.length]
        jb         .l1

        ;          Restore stack
        mov        rsp, rbp
        pop        rbp
        ret

; @param   {byte} sil - ASCII character
; @param   {byte} dil - ASCII character
;
; @returns {byte} al - number between 0-99
to_number:
        xor        rax, rax
        cmp        sil, ' '
        je         .single

        ;          First decimal place
        sub        sil, '0'
        movzx      rax, sil
        imul       rax, 10
        add        sil, '0'

        ;          Second decimal place
.single:
        sub        dil, '0'
        add        al, dil
        add        dil, '0'
        ret


segment readable writable

; Data to hold scratch card information
winners rb 10
numbers rb 25
lower rb 8
upper rb 8

copies rq NUMBER_OF_CARDS
scores rb NUMBER_OF_CARDS

input file "input-4"
input_len = $ - input
