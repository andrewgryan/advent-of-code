.data
STDOUT = 0

SYS_READ = 0
SYS_WRITE = 1
SYS_OPEN = 2
SYS_CLOSE = 3
SYS_EXIT = 60

O_CREAT = 0x40
O_RDONLY = 0x0
O_WRONLY = 0x1
O_RDWR = 0x2

.text
.global STDOUT
.global sys.close
.global sys.exit
.global sys.read
.global sys.write


/**
 *  Open
 *
 *  %rdi - file name string address
 *  %rsi - flags
 *  %rdx - mode
 */
sys.open:
        mov        $SYS_OPEN, %rax
        syscall
        ret


/**
 *  Read
 *
 *  %rdi - file handle
 *  %rsi - buffer address
 *  %rdx - number of bytes to read
 */
sys.read:
        mov        $SYS_READ, %rax
        syscall
        ret


/**
 *  Write
 *
 *  %rdi - file handle
 *  %rsi - buffer address
 *  %rdx - number of bytes to write
 */
sys.write:
        mov        $SYS_WRITE, %rax
        syscall
        ret


/**
 *  Close file handle
 *
 *  %rdi - file handle
 */
sys.close:
        mov        $SYS_CLOSE, %rax
        syscall
        ret

/*
 *	Exit system call
 *
 *  %rdi - Exit code
 */
sys.exit:
	mov $60, %rax
	syscall
	ret
