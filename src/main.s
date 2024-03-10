.global Program.main

.include "system.i"
.include "lex.i"

.data

_hello:
	.ascii "Hello, world!\n"
_hello.len = . - _hello

_src:
	.ascii "+-- 7 * 5"
_src.len = . - _src

_fmt:
	.ascii "Token %x, %x"
_fmt.len = . - _fmt

.text
Program.main:
	mov $Sys.write, %rax
	mov $Io.stdout, %rdi
	lea _hello(%rip), %rsi
	mov $_hello.len, %rdx
	syscall
	
	lea _src(%rip), %rsi
	mov $_src.len, %rbx
	call Lex.from_source

	lea Lex.tokens(%rip), %rdi
_loop:
	push %rdi
	lea _fmt(%rip), %rax
	mov $_fmt.len, %rbx
	call Dbg.println
	pop %rdi
	add $Token.size, %rdi
	
	cmpb $TokenKind.Eof, Token.kind - Token.size(%rdi)
	jne _loop

	mov $Sys.exit, %rax
	mov $0, %rdi
	syscall
