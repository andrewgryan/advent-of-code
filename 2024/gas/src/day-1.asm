.text
.global _start
_start:
	mov $7, %rdi
	call sys.exit
