.global Program.main

.include "system.i"
.include "lex.i"

.data

_hello:
	.ascii "Hello, world!\n"
_hello.len = . - _hello

_src:
	.asciz "print 7 * 5"
_src.len = . - _src

_fmt:
	.asciz "Test fmt: %x, %x."
_fmt.len = . - _fmt

_args:
	.quad 0xFF22
	.quad 0xDEADBEEF

.text
Program.main:
	mov $Sys.write, %rax
	mov $Io.stdout, %rdi
	lea _hello(%rip), %rsi
	mov $_hello.len, %rdx
	syscall

	mov $0xDEADBEEF, %rax
	call Dbg.hex

	lea _fmt(%rip), %rax
	lea _args(%rip), %rdi
	call Dbg.println

	mov $Sys.exit, %rax
	mov $0, %rdi
	syscall
