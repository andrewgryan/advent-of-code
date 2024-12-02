.data
	msg: .ascii "Hello, GAS!\n"
	msg_len = (. - msg)

	buf: .space 1024, 0
	buf_len = 1024

	fd: .quad 0
	bytes: .quad 0
	path: .ascii "src/input-1"


.text
.global _start
_start:
		mov 	$path, %rdi
        mov     $O_RDONLY, %rsi
		call 	sys.open
        mov 	%rax, (fd)

.R1:
        mov     (fd), %rdi
        mov     $buf, %rsi
        mov     $buf_len, %rdx
        call    sys.read
        mov     %rax, (bytes)

		mov 	$STDOUT, %rdi
		mov 	$buf, %rsi
		mov 	(bytes), %rdx
		call 	sys.write

        cmp     $0, (bytes)
        jg      .R1

        mov     (fd), %rdi
		call 	sys.close

		mov 	$0, %rdi
		call 	sys.exit
