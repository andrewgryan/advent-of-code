.data
SYS_EXIT = 93

.text
.global _start

main:
        mov x0, #0
        ret

_start:
        bl main
        ldr w8, =SYS_EXIT
        svc #0
