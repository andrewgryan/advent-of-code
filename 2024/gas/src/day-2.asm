.data
	path: .ascii "src/small"
	handle: .quad 0
	buffer: .space 1024, 0
	size = 1024
	bytes_read: .quad 0
	

.text
.global	_start
_start:
	# Memory allocator
	mov	$512, %rdi
	call	alloc

	# File I/O
	mov	$path, %rdi
	call	open
	mov	%rax, (handle)

	mov	(handle), %rdi
	mov	$buffer, %rsi
	mov	$size, %rdx
1:
	call	sys.read
	cmp	$0, %rax
	jne	1b

	mov	(handle), %rdi
	call	sys.close

	mov	$0, %rdi
	call	sys.exit


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
