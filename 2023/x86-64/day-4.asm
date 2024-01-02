format ELF64 executable


include "util.inc"


segment readable executable
entry main
main:
        mov        si, word [input + 10]
        mov        [winners], si
        exit       0


segment readable writable

; Data to hold scratch card information
winners rw 10
numbers rw 25

input file "input-4"
input_len = $ - input
