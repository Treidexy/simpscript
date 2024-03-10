.global Lex.from_source
.global Lex.tokens
.global Lex.tokens.count

.include "lex.i"

.data

.align 16
Lex.tokens:
	.space Token.size * _max_tokens
_max_tokens = 1024

_src.end:
	.space 8

.text

// (src: %rsi, src.len: %rbx) -> (: Lex.tokens, Lex.tokens.eof: %rdi)
Lex.from_source:
		// token ptr
		lea Lex.tokens(%rip), %rdi
		
		add %rsi, %rbx
		mov %rbx, _src.end

	_skip_whitespace:
		inc %rsi
		// for fun
		cmpb $' ', -1(%rsi)
		je _skip_whitespace
		cmpb $'\t', -1(%rsi)
		je _skip_whitespace
		cmpb $'\n', -1(%rsi)
		je _skip_whitespace 
		cmpb $'\r', -1(%rsi)
		je _skip_whitespace
	_skip_whitespace.end:
		dec %rsi

		cmp _src.end, %rsi
		je _after

	_0:
		cmpb $'+', (%rsi)
		jne _1
		inc %rsi

		movb $TokenKind.Plus, Token.kind(%rdi)
		add $Token.size, %rdi
		jmp _last
	_1:
		cmpb $'-', (%rsi)
		jne _2
		inc %rsi

		movb $TokenKind.Minus, Token.kind(%rdi)
		add $Token.size, %rdi
		jmp _last
	_2:
		cmpb $'*', (%rsi)
		jne _3
		inc %rsi

		movb $TokenKind.Star, Token.kind(%rdi)
		add $Token.size, %rdi
		jmp _last
	_3:
		cmpb $'/', (%rsi)
		jne _4
		inc %rsi

		movb $TokenKind.Slash, Token.kind(%rdi)
		add $Token.size, %rdi
		jmp _last
	_4:
		cmpb $'(', (%rsi)
		jne _5
		inc %rsi

		movb $TokenKind.LParen, Token.kind(%rdi)
		add $Token.size, %rdi
		jmp _last
	_5:
		cmpb $')', (%rsi)
		jne _6
		inc %rsi

		movb $TokenKind.RParen, Token.kind(%rdi)
		add $Token.size, %rdi
		jmp _last
	_6:
		cmpb $'0', (%rsi)
		jb _not_number
		cmpb $'9', (%rsi)
		ja _not_number

	_yes_number:
		// total
		xor %rax, %rax
		// digit
		xor %r9, %r9
		// base
		mov $10, %r8
		movb $TokenKind.Number, Token.kind(%rdi)
		
	_yes_number.loop:
		mov (%rsi), %r9b
		sub $'0', %r9b
		cmp $9, %r9b
		ja _done_number

		inc %rsi
		mul %r8
		add %r9, %rax
		jmp _yes_number.loop
	_done_number:
		mov %rax, Token.data(%rdi)
		add $Token.size, %rdi
		jmp _last
	_not_number:

		cmpb $'a', (%rsi)
		jb _maybe_name.no_lowercase
		cmpb $'z', (%rsi)
		ja _maybe_name.no_lowercase

		jmp _yes_name
	_maybe_name.no_lowercase:
		cmpb $'A', (%rsi)
		jb _not_name
		cmpb $'Z', (%rsi)
		ja _not_name

		jmp _yes_name

	_yes_name:
		movb $TokenKind.Name, Token.kind(%rdi)
		mov %rsi, Token.data(%rdi)
		incq Token.data_ext(%rdi)
		inc %rsi

		_yes_name.loop:
			cmpb $'a', (%rsi)
			jb _yes_name.loop.not_lowercase
			cmpb $'z', (%rsi)
			ja _yes_name.loop.not_lowercase

			jmp _yes_name.loop.last
		_yes_name.loop.not_lowercase:
			cmpb $'A', (%rsi)
			jb _yes_name.loop.not_uppercase
			cmpb $'Z', (%rsi)
			ja _yes_name.loop.not_uppercase

			jmp _yes_name.loop.last
		_yes_name.loop.not_uppercase:
			cmpb $'0', (%rsi)
			jb _yes_name.loop.after
			cmpb $'9', (%rsi)
			ja _yes_name.loop.after

			jmp _yes_name.loop.last

		_yes_name.loop.last:
			incq Token.data_ext(%rdi)
			inc %rsi
			jmp _yes_name.loop
		_yes_name.loop.after:
			add $Token.size, %rdi
			jmp _last


	_not_name:
		movb $TokenKind.Bad, Token.kind(%rdi)
		xor %r9, %r9
		mov (%rsi), %r9b
		inc %rsi
		mov %r9, Token.data(%rdi)
		add $Token.size, %rdi

	_last:
		jmp _skip_whitespace
	_after:
		movb $TokenKind.Eof, Token.kind(%rdi)
		ret
