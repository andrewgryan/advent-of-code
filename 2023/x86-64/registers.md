# Register synonyms

64-bit | 32-bit | 16-bit | 8-bit
-------|--------|--------|-------
rax    | eax    | ax     | ah, al
rbx    | ebx    | bx     | bh, bl
rcx    | ecx    | cx     | ch, cl
rdx    | edx    | dx     | dh, dl
rsi    | esi    | si     | sil
rdi    | edi    | di     | dil
rbp    | ebp    | bp     | bpl
rsp    | esp    | sp     | spl
r8     | r8d    | r8w    | r8b
r9     | r9d    | r9w    | r9b
r10    | r10d   | r10w   | r10b
r11    | r11d   | r11w   | r11b
r12    | r12d   | r12w   | r12b
r13    | r13d   | r13w   | r13b
r14    | r14d   | r14w   | r14b
r15    | r15d   | r15w   | r15b

# System V ABI
A common convention for using registers in x86-64

## Argument registers
rdi, rsi, rdx, rcx, r8, r9

## Scratch registers
rax, rdi, rsi, rdx, rcx, r8, r9, r10, r11

## Preserved registers
rbx, rsp, rbp, r12, r13, r14, r15
