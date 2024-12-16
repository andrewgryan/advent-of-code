.text
.global Array
.global set
.global get
.global range


Array:
	mov	%rdi, %rax
	mov	%rsi, %rdi
	call	*%rax
	ret

set:
	movb	%dl, (%rdi, %rsi, 1)
	ret

get:
	movzb 	(%rdi, %rsi, 1), %rax
	ret


/**
 *  %rdi - Allocator
 *  %rsi - Size
 */
range:
	push	%rbp
	mov	%rsp, %rbp
	sub	$0x10, %rsp
	mov	%rdi, 0x00(%rsp)  # Allocator
	mov	%rsi, 0x08(%rsp)  # Array length

	call	Array
	mov	%rax, %rdi
	xor	%rcx, %rcx	# %rcx = 0
1:
	mov	%rcx, %rsi
	mov	%rcx, %rdx
	call	set
	inc	%rcx
	cmp	0x08(%rsp), %rcx
	jle 	1b

	mov	%rbp, %rsp
	pop	%rbp
	ret

