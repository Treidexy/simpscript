.global Dbg.hex

.include "system.i"

.data

.align 2
_buffer:
	.zero 2
	.zero 16
_buffer.end:
	.byte '\n'
_buffer.len = . - _buffer

.text

// (%rax) -> ()
Dbg.hex:
	// divisor
	mov $0x10, %rcx
	// pointer
	lea _buffer.end - 1(%rip), %rdi

_loop:
	xor %rdx, %rdx
	div %rcx

	cmp $10, %rdx
	jg _is_letter
_is_digit:
	add $'0', %rdx
	jmp _after
_is_letter:
	add $'A' - 10, %rdx
_after:
	mov %dl, (%rdi)
	dec %rdi
	
	cmp $0, %rax
	jg _loop

	mov %rdi, %rsi
	and $1, %rsi
	test %rsi, %rsi
	jnz _after2

	movb $'0', (%rdi)
	dec %rdi
_after2:
	movb $'x', (%rdi)
	dec %rdi
	movb $'0', (%rdi)
	dec %rdi

	mov $Sys.write, %rax
	mov $Io.stdout, %rdi
	lea _buffer(%rip), %rsi
	mov $_buffer.len, %rdx
	syscall

	ret
