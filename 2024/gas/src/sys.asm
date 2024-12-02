.global sys.exit

/*
 *	Exit system call
 *
 *  %rdi - Exit code
 */
sys.exit:
	mov $60, %rax
	syscall
	ret
