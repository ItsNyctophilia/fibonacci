.intel_syntax	noprefix

	.globl octal
octal:
	.asciz	"-o"

	.globl format_most_sig
format_most_sig:
	.asciz	"0x%.0lX"

	.globl format_least_sig
format_least_sig:
	.asciz "%lx\n"

	.globl o_format_most_sig
o_format_most_sig:
	.asciz	"0o%.0lo"

	.globl o_format_least_sig
o_format_least_sig:
	.asciz "%lo\n"

	.globl inv_err_str
inv_err_str:
	.asciz "%s [-o] num\n"

	.globl num_clamp_err_str
num_clamp_err_str:
	.asciz "Number must be between 0-100\n"

	.globl	main
main:
	push	rsi				# preserve argv on stack

	cmp	rdi, 3				# argc == 3 ?
	jg	invocation_err			# case: argc > 3
	cmp	rdi, 1
	je	invocation_err			# case: argc == 1

	cmp	rdi, 2
	je	arg1				# case argc == 2

arg2:
	mov	rdi, QWORD PTR[rsi+8]		# argv[1] into rdi
	lea	rsi, [rip+octal]		# Create temp pointer on stack
	call	strcmp				# strol(argv[1], &err, 10);

	cmp	rax, 0
	jne	invocation_err
	mov	r12, 8				# r12 will hold the base for printing

	pop	rsi				# return to rsi char *argv[]
	push	rsi				# preserve in rsi char *argv[] again
	mov	rdi, QWORD PTR[rsi+16]		# argv[2] into rdi
	sub	rsp, 8				# Create temp pointer on stack
	mov	rsi, rsp			# rsp points to rsi
	mov	rdx, 10				# base 10 conversion
	call	strtol				# strol(argv[1], &err, 10);
	pop	rsi				# pop temp variable off stack to rsi

	cmp	BYTE PTR[rsi], 0		# if err_ptr != 0 ('\0'), error detected
	jne	invocation_err			# return with usage statement if error
	pop	rsi				# pop unnecessary variable off stack

	jmp	post_arg_processing

arg1:
	mov	rdi, QWORD PTR[rsi+8]		# argv[1] into rdi
	sub	rsp, 8				# Create temp pointer on stack
	mov	rsi, rsp			# rsp points to rsi
	mov	rdx, 10				# base 10 conversion
	call	strtol				# strol(argv[1], &err, 10);
	pop	rsi				# pop temp variable off stack to rsi

	cmp	BYTE PTR[rsi], 0		# if err_ptr != 0 ('\0'), error detected
	jne	invocation_err			# return with usage statement if error
	pop	rsi				# pop unnecessary variable off stack

post_arg_processing:
	cmp	rax, 0
	jl	num_clamp_err			# This section just tests that input number is
	cmp	rax, 100			# (-1 < num < 101)
	jg	num_clamp_err

	mov	rcx, rax			# move return from strtol into rcx as counter

	xor	r8, r8				# zero out r8 (most significant bits for final printing)
	mov	rsi, rcx			# move num into rsi in case printing of 1/2 necessary
	cmp	rcx, 2				# num == 2 ?
	jle	post_fib			# case: num < 2

	dec	rcx				# account for off-by-one error
	xor	rdi, rdi			# zero rdi
	xor	r9, r9
	mov	rsi, 1				# set rsi to 1
	xor	r8, r8

fib:
	# Little endian storage
	# (Lower, Upper)
	# (rax, rbx) 128 bit accumulator
	# (rsi, r8)   128 bit n-1
	# (rdi, r9)   128 bit n-2

	xor	rax, rax			# zero out rax
	xor	rbx, rbx			# zero out rbx

	add	rax, rsi			# add n-1
	adc	rbx, r8

	add	rax, rdi			# add n-2
	adc	rbx, r9

	mov	rdi, rsi			# set n-2 = n-1
	mov	r9, r8

	mov	rsi, rax			# set n-1 = answer from iteration
	mov	r8, rbx

	loop	fib				# loop until complete

post_fib:					# used for nums 0/1 for explicit printing
	cmp	r12, 8				# case: octal printing
	je	octal_print

hex_print:					# default: hex printing
	push	rsi				# preserve lower-order bits of num

	lea	rdi, [rip+format_most_sig]	# load format string for printf
	mov	rsi, r8				# move value to print into rsi
	xor	al, al				# zero al before printf call
	call	printf				# print upper order bits

	lea	rdi, [rip+format_least_sig]	# load format string for printf
	pop	rsi				# load into rsi value of lower-order bits
	xor	al, al				# zero al before printf call
	call	printf				# print lower order bits

	jmp	exit_success

octal_print:
	push	rsi				# preserve least significant part

	shl	r8				# move msb of lsp to lsb of msp
						# (most/least significant bit/part)
	mov	rbx, rsi			# move rsi into rbx as tmp register
	shr	rbx, 63				# bitshift all but msb of rbx
	or	r8, rbx				# account for 64th bit being a part of 1st
						# octet of msp

	lea	rdi, [rip+o_format_most_sig]	# load format string for printf
	mov	rsi, r8				# move value to print into rsi
	xor	al, al				# zero al before printf call
	call	printf				# print upper order bits

	lea	rdi, [rip+o_format_least_sig]	# load format string for printf
	pop	rsi				# load into rsi value of lower-order bits

	shl	rsi				# shift of 64th bit
	shr	rsi				# then shift back into place

	xor	al, al				# zero al before printf call
	call	printf

exit_success:
	xor rax, rax				# zero rax
	ret					# return code 0: SUCCESS

	.globl invocation_err
invocation_err:
	pop	rsi				# load into rsi char *argv[]
	lea	rdi, [rip+inv_err_str]		# load inv_err string for printf
	mov	rsi, QWORD PTR[rsi]		# move into rsi argv[0]
	xor	al, al				# zero al before printf call
	call	printf				# printf("%s", argv[0]);
	mov	rax, 1				# return code 1: INVOCATION_ERR
	ret

	.globl number_clamp_err
num_clamp_err:
	lea	rdi, [rip+num_clamp_err_str] 	# load inv_err string for printf
	xor	al, al				# zero al before printf call
	call	printf				# call printf with error message
	mov	rax, 2				# return code 2: NUM_CLAMP_ERR
	ret
