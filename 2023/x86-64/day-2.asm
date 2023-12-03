format ELF64 executable


include "util.inc"


segment readable executable
entry main
main:
        print input, input_len
        exit 0


segment readable writable
input file "input-2"
input_len = $ - input
