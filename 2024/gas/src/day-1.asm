.data
        buf: .space 14, 0
        buf_len = 14

        i: .quad 0
        fd: .quad 0
        bytes: .quad 0
        path: .ascii "src/input-1"

        gap: .space 8008
        left: .space 8008
        right: .space 8008
	lines = 1000

	x:
	.quad 3, 4, 2, 1, 3, 3
	y:
	.quad 4, 3, 5, 3, 9, 3
	z:
	.quad 0, 0, 0, 0, 0, 0

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

/**
 *  %rdi - u64[] array
 *  %rsi - uint sizeof array
 */
sort:
	mov	%rsi, %r11
	dec	%r11
4:
	xor	%rcx, %rcx  # Line counter
	xor	%r10, %r10  # Swap flag
2:
	mov	(%rdi, %rcx, 0x8), %r8
	mov	0x8(%rdi, %rcx, 0x8), %r9
	cmp	%r9, %r8
	jg	1f
3:
	inc	%rcx
	cmp	%r11, %rcx
	jl	2b
	cmp	$1, %r10
	je	4b
	ret
1:
	movq	$1, %r10  # Set swap flag
	movq	%r9, (%rdi, %rcx, 0x8)
	movq	%r8, 0x8(%rdi, %rcx, 0x8)
	jmp 	3b


/**
 * %rdi - left array
 * %rsi - right array
 * %rdx - gap array
 * %rcx - array length
 */
distance:
	xor	%r10, %r10  # Line counter
	xor	%r11, %r11  # Distance register
4:
	mov	(%rdi, %r10, 0x8), %r8
	mov	(%rsi, %r10, 0x8), %r9
	cmp	%r9, %r8
	jg	1f
	jmp     2f
3:
	movq	%r11, (%rdx, %r10, 0x8)
	inc	%r10
	cmp	%rcx, %r10
	jl	4b
	ret
2:
	mov	%r9, %r11
	sub	%r8, %r11
	jmp 	3b
1:
	mov	%r8, %r11
	sub	%r9, %r11
	jmp 	3b


/**
 * %rdi - Array
 * %rsi - Array length
 */
sum:
	xor	%rax, %rax  # Sum
	xor	%r8, %r8
	xor	%r10, %r10  # Line counter
1:
	movq	(%rdi, %r10, 0x8), %r8
	add	%r8, %rax
	inc	%r10
	cmp	%rsi, %r10
	jl	1b
	ret

/**
 *  Similarity
 *
 *  %rdi - left array
 *  %rsi - right array
 *  %rdx - array length
 */
similarity:
	push	%rbp
	mov	%rsp, %rbp
	sub	$24, %rsp

	mov	%rdi, 0x08(%rsp)
	mov	%rsi, 0x10(%rsp)
	mov	%rdx, 0x18(%rsp)

	xor	%rcx, %rcx
	jmp 	2f
1:
	inc	%rcx
2:
	mov	(%rdi, %rcx, 0x8), %rax
	cmp	%rdx, %rcx
	jl	1b

	mov	%rbp, %rsp
	pop	%rbp
	ret

search:
	ret

_start:
	# Example
        mov     $x, %rdi
        movq    $6, %rsi
        call    sort
        mov     $y, %rdi
        movq    $6, %rsi
        call    sort
	mov	$x, %rdi
	mov	$y, %rsi
	mov	$z, %rdx
	mov	$6, %rcx
	call	distance
        mov     $z, %rdi
        movq    $6, %rsi
        call    sum


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
	mov	$5, %rsi
	call	atoi
        mov     $left, %rdi
        mov     (i), %rcx
	movq    %rax, (%rdi, %rcx, 8)

        # Parse right integer
        mov     $buf, %rdi
        # lea     0x8(%rdi), %rdi
	add	$8, %rdi
	mov	$5, %rsi
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

	# Similarity metric
        mov     $left, %rdi
        mov     $right, %rsi
        movq    $1000, %rdx
	call	similarity

        # Sort left array
        mov     $left, %rdi
        movq    $1000, %rsi
        call    sort

        # Sort right array
        mov     $right, %rdi
        movq    $1000, %rsi
        call    sort

	# Distance between arrays
        mov     $left, %rdi
        mov     $right, %rsi
        movq    $gap, %rdx
        movq    $1000, %rcx
        call    distance

answer:
	# Sum array
        mov     $gap, %rdi
        movq    $1000, %rsi
        call    sum

        # Exit program
        mov     $0, %rdi
        call    sys.exit
