; @param rdi - ASCII character [0-9] string
to_number:
        call       count_digits
        mov        rcx, rax

        ;          Sum digits by powers of ten
        mov        r10, 1                ; Base 10
        xor        rdx, rdx              ; Accumulator
        jmp        .l2
.l1:
        push       rdi
        movzx      rdi, byte [rdi + rcx]
        call       to_digit
        pop        rdi

        imul       rax, r10              ; Multiply digit by base
        add        rdx, rax              ; Add to sum

        imul       r10, 10               ; Next base

        dec        rcx
.l2:
        cmp        rcx, 0
        jne        .l1

        mov        rax, rdx
        ret


; @param rdi - ASCII character [0-9] string
count_digits:
        ;          Count digits
        xor        rcx, rcx
        jmp        .l2
.l1:
        inc        rcx
.l2:
        push       rdi
        movzx      rdi, byte [rdi + rcx]
        call       is_digit
        pop        rdi
        cmp        rax, 1
        je         .l1

        mov        rax, rcx
        ret


; @param rdi - ASCII character
is_digit:
        call       to_digit
        cmp        al, 9
        setna      al
        ret


; @param rdi - ASCII character [0-9]
to_digit:
        movzx      rax, dil
        sub        al, '0'
        ret

