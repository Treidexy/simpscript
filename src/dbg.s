.global Dbg.hex
.global Dbg.println

.include "system.i"

.data

.align 2
_hex.buffer.len = _hex.buffer.end - _hex.buffer
_hex.buffer:
	.zero 2
	.zero 16
_hex.buffer.end:
	.byte '\n' # ye, ik I'm clever

_buffer:
	.zero 1024
_buffer.len = . - _buffer

.text

// (%rax) -> (str: %rsi, len: %rdx)
_fmthex:
		// divisor
		mov $0x10, %rcx
		// pointer
		lea _hex.buffer.end - 1(%rip), %rsi

	_hex.loop:
		xor %rdx, %rdx
		div %rcx

		cmp $10, %rdx
		jae _hex.is_letter
	_hex.is_digit:
		add $'0', %rdx
		jmp _hex.after
	_hex.is_letter:
		add $'A' - 10, %rdx
	_hex.after:
		mov %dl, (%rsi)
		dec %rsi
		
		cmp $0, %rax
		ja _hex.loop

		mov %rsi, %rdx
		and $1, %rdx
		test %rdx, %rdx
		jnz _hex.after2

		movb $'0', (%rsi)
		dec %rsi
	_hex.after2:
		movb $'x', (%rsi)
		dec %rsi
		movb $'0', (%rsi)

		lea _hex.buffer.end(%rip), %rdx
		sub %rsi, %rdx
		ret

// (%rax) -> ()
Dbg.hex:
		call _fmthex

		mov $Sys.write, %rax
		mov $Io.stdout, %rdi
		inc %rdx
		syscall

		ret

/*

ej.

"The number is %x" -> %rax, %rbx
[ 17, ] ~> %rdi
Dbg.println()

%r - skips 8 bytes
%x - prints 8 byte in hex
%s - prints string (8 bytes ptr, 8 bytes len)

*/
// (fmt: %rax, fmt.len: %rbx, args: (%rdi)) -> ()
Dbg.println:
		// write pointer
		lea _buffer(%rip), %rsi
		
		add %rax, %rbx

	_loop:
		cmpb $'%', (%rax)
		jne _copy
		inc %rax

		cmpb $'%', (%rax)
		je _copy

		cmpb $'r', (%rax)
		jne _0
		inc %rax
			add $8, %rdi
			jmp _after

	_0:
		cmpb $'x', (%rax)
		jne _1
		inc %rax
			push %rax
			push %rbx
			push %rdi
			push %rsi
				mov (%rdi), %rax
				call _fmthex
				mov %rsi, %rdi
			pop %rsi
			_inner_loop:
				mov (%rdi), %cl
				mov %cl, (%rsi)
				inc %rdi
				inc %rsi
				dec %rdx
				test %rdx, %rdx
				jnz _inner_loop
			pop %rdi
			pop %rbx
			pop %rax

			add $8, %rdi
			jmp _after
	_1:
		cmpb $'s', (%rax)
		jne _1
		inc %rax
			// string ptr
			mov (%rdi), %r8
			mov 8(%rdi), %r9
			add $16, %rdi
			// string ptr.end
			add %r8, %r9

		_1.loop:
			mov (%r8), %cl
			mov %cl, (%rsi)
			inc %rsi
			inc %r8

			cmp %r9, %r8
			jb _1.loop
			jmp _after

	_copy:
		mov (%rax), %cl
		mov %cl, (%rsi)
		inc %rax
		inc %rsi
	_after:
		cmp %rbx, %rax
		jb _loop

		movb $'\n', (%rsi)
		inc %rsi

		mov $Sys.write, %rax
		mov $Io.stdout, %rdi
		mov %rsi, %rdx
		lea _buffer(%rip), %rsi
		sub %rsi, %rdx
		syscall

		ret
