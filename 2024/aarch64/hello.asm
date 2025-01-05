.data
msg:
        .ascii "Hello, World!\n"
msg_len = . - msg

.text
.global _start
_start:
        mov x0, #1
        ldr x1, =msg
        ldr x2, =msg_len
        mov w8, #64
        svc #0

        mov w8, #93
        mov x0, #0
        svc #0
