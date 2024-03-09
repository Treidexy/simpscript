.global Program.main

.include "system.i"
.include "lex.i"

.data

_hello:
	.ascii "Hello, world!\n"
_hello.len = . - _hello

_src:
	.ascii "print 7 * 5"
_src.len = . - _src

.text
Program.main:
	mov $Sys.write, %rax
	mov $Io.stdout, %rdi
	lea _hello(%rip), %rsi
	mov $_hello.len, %rdx
	syscall

	mov $0x2F22, %rax
	call Dbg.hex

	mov $Sys.exit, %rax
	mov $0, %rdi
	syscall
