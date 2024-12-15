.data
	path: .ascii "src/example-2"
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

	mov	$0, %rdi
	call	sys.exit


part_1:
	push	%rbp
	mov	%rsp, %rbp
	sub	$0x20, %rsp

	mov	%rdi, 0x00(%rsp)
	movq	$0x0, 0x08(%rsp)  # Safe report counter
	movq	$-1, 0x10(%rsp)   # Previous level
	movq	$-1, 0x18(%rsp)   # Current level

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

3:
	inc	%rcx		# %rcx += 1
	cmp	%rcx, %rsi
	jg	1b		# while (%rsi > %rcx):

	mov	%rbp, %rsp
	pop	%rbp
	ret
2:
	#	Reset registers
	mov	%r9, %r12
	xor	%r9, %r9
	jmp 	3b


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
	shr	$1, %rax
	cmp	$0, %rax
	sete	%al
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
