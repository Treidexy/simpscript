.global Lex.from_source
.global Lex.tokens
.global Lex.tokens.count

.include "lex.i"

.data

.align 16
Lex.tokens:
	.space Token.size * _max_tokens
Lex.tokens.count:
	.space 8
_max_tokens = 1024

.text

// (%rsi) -> (Lex.tokens)
Lex.from_source:
		// token ptr
		lea Lex.tokens(%rip), %rdi

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
		cmpb $'0', (%rsi)
		jnge _not_number
		je _yes_number.maybe_hex
		cmpb $'9', (%rsi)
		jnle _not_number
	
	_yes_number.not_hex:
		mov $10, %rcx
		jmp _yes_number	
	_yes_number.maybe_hex:
		inc %rsi
		cmpb $'x', (%rsi)
		jne _yes_number.not_hex

		inc $rsi
		mov $0x10, %rcx

	_yes_number:
		movb $TokenKind.Number, Token.kind(%rdi)
		mov (%rsi), %r9b
		sub $'0', %r9b
		cmp %cl, %r9b
		jg 

	_not_number:

	_last:
		jmp _0
