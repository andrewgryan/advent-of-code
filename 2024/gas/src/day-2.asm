.data
	path: .ascii "src/input-2"
	handle: .quad 0
	buffer: .space 1024, 0
	size = 1024
	bytes_read: .quad 0
	ptr: .quad 0

	# ASCII character codes
	SPACE = 0x20
	NEWLINE = 0x0a
	

.text
.global	_start
_start:
	# Memory allocator
	mov	$32768, %rdi
	call	alloc
	mov	%rax, (ptr)

	# File I/O
	mov	$path, %rdi
	call	open
	mov	%rax, (handle)

	mov	(handle), %rdi
	mov	(ptr), %rsi
	mov	$size, %rdx
1:
	call	sys.read
	lea	(%rsi, %rax, 1), %rsi
	cmp	$0, %rax
	jne	1b

	mov	(handle), %rdi
	call	sys.close

	# Attempt a solution to part 1
	mov	(ptr), %rdi
	mov	$32768, %rsi
	call	part_1
solution:

	mov	$0, %rdi
	call	sys.exit


part_1:
	push	%rbp
	mov	%rsp, %rbp
	sub	$0x28, %rsp

	mov	%rdi, 0x00(%rsp)  # Buffer handle
	mov	%rsi, 0x08(%rsp)  # Buffer length
	movq	$0, 0x10(%rsp)    # Safe report counter
	movq	$-1, 0x18(%rsp)   # Previous level
	movq	$1, 0x20(%rsp)    # Safe flag

	xor	%r9, %r9
	xor	%r10, %r10
	mov	0x0(%rsp), %r11

	xor	%rcx, %rcx	# %rcx = 0
1:
	movzb	(%r11, %rcx), %rdi

	cmp	$SPACE, %dil
	je	2f

	cmp	$NEWLINE, %dil
	je	3f

	# 	Multiply sum by 10
	mov	$10, %r10d
	xor 	%edx, %edx
	mov 	%r9d, %eax
	mul 	%r10d
	mov	%rax, %r9

	# 	Add to sum
	call	int
	add	%rax, %r9

4:
	inc	%rcx		  # %rcx += 1
	cmp	%rcx, 0x08(%rsp)
	jg	1b		  # while (len(buf) > %rcx):

	mov	0x10(%rsp), %rax  # Safe counter
	mov	%rbp, %rsp
	pop	%rbp
	ret
2:
	#	SPACE
	cmp	$-1, 0x18(%rsp)
	jne	5f
6:
	mov	%r9, 0x18(%rsp)
	xor	%r9, %r9
	jmp 	4b
3:
	#	NEWLINE
	mov	0x18(%rsp), %rdi
	mov	%r9, %rsi
	call	is_safe
	and	%al, 0x20(%rsp)   # AND SAFE flag

	mov	0x20(%rsp), %rax  # Load SAFE flag
	add	%rax, 0x10(%rsp)  # Add to SAFE report tally

	xor	%r9, %r9          # RESET number
	movq	$-1, 0x18(%rsp)   # RESET Previous level
	movq	$1, 0x20(%rsp)    # RESET Safe flag
	jmp 	4b

5:
	mov	0x18(%rsp), %rdi
	mov	%r9, %rsi
debug:
	call	is_safe
	and	%al, 0x20(%rsp)   # AND SAFE flag
	jmp	6b

/**
 * If readings differ by two or less
 *
 * %rdi - current level
 * %rsi - previous level
 */
is_safe:
	cmp	%rdi, %rsi
	jg	1f
	jmp 	2f
3:
	cmp	$2, %rax
	setle	%al
	ret
2:
	mov	%rdi, %rax
	sub	%rsi, %rax
	jmp	3b
1:
	mov	%rsi, %rax
	sub	%rdi, %rax
	jmp	3b


/**
 *  Allocate memory using brk
 *
 *  %rdi - size in bytes
 *  %rax - return address of memory
 */
alloc:
	push	%rbp
	mov	%rsp, %rbp
	sub	$0x10, %rsp

	mov	%rdi, 0x0(%rsp)

	mov	$0x0c, %rax
	mov	$0x0, %rdi
	syscall
	mov	%rax, 0x08(%rsp)

	mov	$0x0c, %rax
	mov	0x08(%rsp), %rdi
	add	0x0(%rsp), %rdi
	syscall

	mov	0x08(%rsp), %rax

	mov	%rbp, %rsp
	pop	%rbp
	ret


/**
 * Open file in READ ONLY mode
 */
open:
	mov	$O_RDONLY, %rsi
	call	sys.open
	ret


/**
 * Read into buffer until \n character found
 */
readline:
	ret
