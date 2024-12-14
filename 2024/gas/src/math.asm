.text
.global int

/**
 *  %rdi - buffer address
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

