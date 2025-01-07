.data
NULL = 0x0
NULL_FD = -1

O_RDONLY = 0
O_WRONLY = 1
O_CREAT = 100 // Create and write is 101

SYS_WRITE = 64
SYS_OPENAT = 56
SYS_EXIT = 93
SYS_MMAP = 222

AT_FDCWD = -100

PROT_NONE = 0x0
PROT_READ = 0x1
PROT_WRITE = 0x2
PROT_EXEC = 0x4

MAP_SHARED = 0x01
MAP_PRIVATE = 0x02
MAP_ANONYMOUS = 0x20

KB = 1024

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
        ldr x2, =O_RDONLY
        mov x3, #400
        svc #0

        mov x0, x4
        ldr x0, =NULL
        mov x1, #14
        ldr x2, =PROT_READ
        ldr x3, =MAP_PRIVATE
        mov x5, #0x0
        ldr w8, =SYS_MMAP
        svc #0

        ldr x0, =NULL
        ldr x1, =(5 * KB)
        ldr x2, =(PROT_READ | PROT_WRITE)
        ldr x3, =(MAP_PRIVATE | MAP_ANONYMOUS)
        ldr x4, =NULL_FD
        mov x5, #0x0
        ldr w8, =SYS_MMAP
        svc #0

        mov x9, #42
        strb w9, [x0]
        ldrb w0, [x0]

        ldr w8, =SYS_EXIT
        svc #0
