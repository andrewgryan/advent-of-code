format ELF64 executable


include "util.inc"


segment readable executable
entry main
main:
        mov        rdi, 7        ; Race duration
        mov        rsi, 9        ; Distance record
        call       ways_to_win
        int3
        exit       0


ways_to_win:
        ;          Approach from below
        push       rsi
        mov        rsi, 0
        call       distance
        pop        rsi

        ;          Approach from above
        push       rsi
        mov        rsi, rdi
        call       distance
        pop        rsi
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
