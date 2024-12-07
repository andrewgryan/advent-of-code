.data
        buf: .space 14, 0
        buf_len = 14

        i: .quad 0
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


sort:
    ret


_start:
        # Open file
        mov     $path, %rdi
        mov     $O_RDONLY, %rsi
        call    sys.open
        mov     %rax, (fd)
        movq    $0, (i)

1:
        # Read line into buffer
        mov     (fd), %rdi
        mov     $buf, %rsi
        mov     $buf_len, %rdx
        call    sys.read
        mov     %rax, (bytes)

        # Parse left integer
        mov     $buf, %rdi
	    mov	    $5, %rsi
	    call	atoi
        mov     $left, %rdi
        mov     (i), %rcx
	    movq    %rax, (%rdi, %rcx, 8)

        # Parse right integer
        mov     $buf, %rdi
        lea     0x7(%rdi), %rdi
	    mov	    $5, %rsi
	    call	atoi
        mov     $right, %rdi
        mov     (i), %rcx
	    movq    %rax, (%rdi, %rcx, 8)

        # # Print line
        # mov     $STDOUT, %rdi
        # mov     $buf, %rsi
        # mov     (bytes), %rdx
        # call    sys.write

        # Continue if more bytes  to read
        incq    (i)
        cmp     $0, (bytes)
        jg      1b

        # Close file
        mov     (fd), %rdi
        call    sys.close

        # Sort left array
        mov     $left, %rdi
        movq    $1000, %rsi
        call    sort

        # Sort right array
        mov     $right, %rdi
        movq    $1000, %rsi
        call    sort
        

        # Exit program
        mov     $0, %rdi
        call    sys.exit
