format ELF64 executable


include "util.inc"


segment readable executable
entry main
main:
        exit 0

segment readable writable
