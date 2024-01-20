format ELF64 executable


include "util.inc"


EXAMPLE_RACES = 3
INPUT_RACES = 4
RACES = INPUT_RACES

EXAMPLE_TIME = 71530
EXAMPLE_RECORD = 940200

TIME = 41667266
RECORD = 244104712281040

segment readable executable
entry main
main:
        mov        rdi, TIME   ; Race duration
        mov        rsi, RECORD ; Distance record
        call       ways_to_win
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
; Example
; time dq 7, 15, 30
; record dq 9, 40, 200

; ; Input
; time dq 41, 66, 72, 66
; record dq 244, 1047, 1228, 1040
