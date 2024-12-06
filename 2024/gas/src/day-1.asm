.data
        buf: .space 14, 0
        buf_len = 14

        fd: .quad 0
        bytes: .quad 0
        path: .ascii "src/input-1"

        left: .space 8000
        right: .space 8000


.text
.global _start


/**
 *  %rdi - buffer address
 *  %rsi - buffer length
 */
int:
	mov	%rdi, %rax
	sub	$48, %rax
	cmp	$9, %rax
	jg	1f
	cmp	$0, %rax
	jl	1f
	ret
1:
	mov	$-1, %rax
        ret

atoi:
	xor	%rax, %rax
	xor	%rcx, %rcx
	mov	%rdi, %r8
	xor	%r9, %r9
	jmp	2f
1:
	movzb	(%r8, %rcx, 1), %rdi
	mov	%r9, %rax
	mov	$10, %r10d
	mul	%r10d
	mov	%rax, %r9
	call	int
	add	%rax, %r9
	inc	%rcx
2:
	cmp	%rsi, %rcx
	jl	1b
	mov	%r9, %rax
	ret

_start:
        # Open file
        mov     $path, %rdi
        mov     $O_RDONLY, %rsi
        call    sys.open
        mov     %rax, (fd)

1:
        # Read 14 chars into buffer
        mov     (fd), %rdi
        mov     $buf, %rsi
        mov     $buf_len, %rdx
        call    sys.read
        mov     %rax, (bytes)

        # Interpret a single line
        mov     $buf, %rdi
	mov	$5, %rsi
	call	atoi

        # Interpret a single line
	mov	$7, %rsi
	mov	buf, %r8
        lea     (%r8, %rsi, 1), %rdi
	mov	$5, %rsi
	call	atoi

        # Print line
        mov     $STDOUT, %rdi
        mov     $buf, %rsi
        mov     (bytes), %rdx
        call    sys.write

        # Continue if more bytes  to read
        cmp     $0, (bytes)
        jg      1b

        # Close file
        mov     (fd), %rdi
        call    sys.close

        # Exit program
        mov     $0, %rdi
        call    sys.exit
