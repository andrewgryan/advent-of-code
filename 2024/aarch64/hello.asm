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
SYS_FSTATAT = 79

AT_FDCWD = -100

PROT_NONE = 0x0
PROT_READ = 0x1
PROT_WRITE = 0x2
PROT_EXEC = 0x4

MAP_SHARED = 0x01
MAP_PRIVATE = 0x02
MAP_ANONYMOUS = 0x20

KB = 1024

STDOUT = 0x1

msg:
        .ascii "Hello, World!\n"
msg_len = . - msg
fname:
        .asciz "file.txt"

stat_buf: .space 128
fd: .dword 0

.text
.global _start


stat:
        ldr x0, =AT_FDCWD
        ldr x1, =fname
        ldr x2, =stat_buf
        mov x3, #0x0
        ldr w8, =SYS_FSTATAT
        svc #0

        ldr x0, [x2, #48]
        ret

main:
        stp x29, x30, [sp, #16]

        bl open_file
        bl mmap_file

        mov x1, x0
        mov x2, #15
        bl write

        ldp x29, x30, [sp, #16]
        ret

write:
        ldr x0, =STDOUT
        ldr w8, =SYS_WRITE
        svc #0
        ret


open_file:
        ldr w8, =SYS_OPENAT
        ldr x0, =AT_FDCWD
        ldr x1, =fname
        ldr x2, =O_RDONLY
        mov x3, #400
        svc #0
        ret


mmap_file:
        mov x4, x0
        ldr x0, =NULL
        mov x1, #14
        ldr x2, =PROT_READ
        ldr x3, =MAP_PRIVATE
        mov x5, #0x0
        ldr w8, =SYS_MMAP
        svc #0
        ret

mmap_alloc:
        ldr x0, =NULL
        ldr x1, =(5 * KB)
        ldr x2, =(PROT_READ | PROT_WRITE)
        ldr x3, =(MAP_PRIVATE | MAP_ANONYMOUS)
        ldr x4, =NULL_FD
        mov x5, #0x0
        ldr w8, =SYS_MMAP
        svc #0
        ret

_start:
        bl main
        ldr w8, =SYS_EXIT
        svc #0
