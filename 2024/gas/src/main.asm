.data
	pointer: .space 1024, 0

.text
.global _start
_start:
	mov	$pointer, %rdx
	movb	$60, 0x8(%rdx)
	lea	0x8(%rdx), %rcx
	mov	%rcx, 0x0(%rdx)

	mov	$60, %rax
	mov	$1, %rdi
	syscall


sum:
	ret
