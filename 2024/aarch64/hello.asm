.data
O_RDONLY = 0
O_WRONLY = 1
O_CREAT = 100 // Create and write is 101

SYS_WRITE = 64
SYS_OPENAT = 56
SYS_EXIT = 93

AT_FDCWD = -100
msg:
        .ascii "Hello, World!\n"
msg_len = . - msg
fname:
        .asciz "file.txt"

.text
.global _start
_start:
        mov x0, #1
        ldr x1, =msg
        ldr x2, =msg_len
        ldr w8, =SYS_WRITE
        svc #0

        ldr w8, =SYS_OPENAT
        ldr x0, =AT_FDCWD
        ldr x1, =fname
        mov x2, #101
        mov x3, #400
        svc #0

        ldr x1, =msg
        ldr x2, =msg_len
        ldr w8, =SYS_WRITE
        svc #0

        ldr w8, =SYS_EXIT
        # mov x0, #0
        svc #0
