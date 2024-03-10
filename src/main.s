.global Program.main

.include "system.i"
.include "lex.i"

.data

_hello:
	.ascii "Hello, world!\n"
_hello.len = . - _hello

_src:
	.ascii "sqrt (17 + 7) - 2"
_src.len = . - _src

_fmt1:
	.ascii "Token %x, %x%r"
_fmt1.len = . - _fmt1
_fmt2:
	.ascii "Token %x, `%s`"
_fmt2.len = . - _fmt2

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
	cmpb $TokenKind.Name, Token.kind(%rdi)
	je _loop.name

	lea _fmt1(%rip), %rax
	mov $_fmt1.len, %rbx
	jmp _loop.print
_loop.name:
	lea _fmt2(%rip), %rax
	mov $_fmt2.len, %rbx
_loop.print:
	call Dbg.println
	pop %rdi
	add $Token.size, %rdi
	
	cmpb $TokenKind.Eof, Token.kind - Token.size(%rdi)
	jne _loop

	mov $Sys.exit, %rax
	mov $0, %rdi
	syscall
