format ELF64 executable


include "util.inc"


RACES = 3


segment readable executable
entry main
main:
        xor        rcx, rcx
        mov        rdx, 1
        jmp        .l2
.l1:
        push       rdx
        push       rcx
        mov        rdi, qword [time + 8 * rcx]   ; Race duration
        mov        rsi, qword [record + 8 * rcx] ; Distance record
        call       ways_to_win
        pop        rcx
        pop        rdx

        imul       rdx, rax
        inc        rcx
.l2:
        cmp        rcx, RACES
        jb         .l1

        int3
        exit       0


; @param {int} rdi - Race duration
ways_to_win:
        call       min_button_press
        push       rax
        call       max_button_press
        push       rax

        ;          Calculate possible durations
        pop        rax
        pop        r8
        sub        rax, r8
        inc        rax
        ret


;       Approach from above
max_button_press:
        mov        rcx, rdi
.l1:
        push       rsi
        mov        rsi, rcx
        call       distance
        pop        rsi
        cmp        rax, rsi
        ja         .l2

        dec        rcx
        jmp        .l1
.l2:
        mov        rax, rcx
        ret


;       Approach from below
min_button_press:
        xor        rcx, rcx
.l1:
        push       rsi
        mov        rsi, rcx
        call       distance
        pop        rsi
        cmp        rax, rsi
        ja         .l2

        inc        rcx
        jmp        .l1
.l2:
        mov        rax, rcx
        ret



; @param {int} rdi - Race duration
; @param {int} rsi - Button held down duration
distance:
        cmp        rsi, 0
        je         .zero

        mov        rax, rdi
        sub        rax, rsi        ; Time left to race
        jz         .zero

        imul       rax, rsi        ; Distance covered in remaining time
.return:
        ret

.zero:
        mov        rax, 0
        jmp        .return


segment readable writable
time dq 7, 15, 30
record dq 9, 40, 200
