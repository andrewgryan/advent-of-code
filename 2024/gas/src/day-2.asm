.data
	path: .ascii "src/input-2"
	handle: .quad 0
	buffer: .space 1024, 0
	size = 1024
	bytes_read: .quad 0
	ptr: .quad 0
	

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
	sub	$0x08, %rsp

	mov	%rdi, 0x0(%rsp)

	xor	%rcx, %rcx	# %rcx = 0
1:
	mov	0x0(%rsp), %rdi
	movzb	(%rdi, %rcx), %rdi

	call	is_space
	cmp	$1, %al
	je	2f
	

	call	is_newline
	cmp	$1, %al
	je	3f

	call	int

2:
3:
	inc	%rcx		# %rcx += 1
	cmp	%rcx, %rsi
	jg	1b		# while (%rsi > %rcx):

	mov	%rbp, %rsp
	pop	%rbp
	ret


is_space:
	xor	%rax, %rax
	cmp	$0x20, %rdi
	sete	%al
	ret


is_newline:
	xor	%rax, %rax
	cmp	$0x0a, %rdi
	sete	%al
	ret


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
