.data
SYS_EXIT = 93

txt:
        .ascii "127"
txt_len = . - txt

.text
.global _start

main:
        stp fp, lr, [sp, #-16]!
        mov fp, sp

        ldr x0, =txt
        ldr x1, =txt_len
        bl atoi

        mov sp, fp
        ldp fp, lr, [sp], #16
        ret

atoi:
        stp fp, lr, [sp, #-16]!
        mov fp, sp


        mov x3, #0
        mov x4, x0
        mov x5, #10
        mov x6, #0

        b 2f
1:
        ldrb w0, [x4, x3]
        bl ctoi

        mul x6, x6, x5
        add x6, x6, x0
        add x3, x3, #1
2:
        cmp x3, x1
        b.lt 1b

        mov x0, x6

        mov sp, fp
        ldp fp, lr, [sp], #16
        ret

ctoi:
        sub x0, x0, #48
        ret

_start:
        bl main
        ldr w8, =SYS_EXIT
        svc #0
