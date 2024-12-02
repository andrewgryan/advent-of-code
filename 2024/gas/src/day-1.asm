.data
	msg: .ascii "Hello, GAS!\n"
	msg_len = (. - msg)

.text
.global _start
_start:
	mov $STDOUT, %rdi
	mov $msg, %rsi
	mov $msg_len, %rdx
	call sys.write

	mov $7, %rdi
	call sys.exit
