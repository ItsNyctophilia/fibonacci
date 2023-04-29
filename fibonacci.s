.intel_syntax	noprefix

	.globl decimal
decimal:
	.asciz	"-d"

	.globl octal
octal:
	.asciz	"-o"

	.globl format_most_sig
format_most_sig:
	.asciz	"0x%.0lX"

	.globl format_least_sig
format_least_sig:
	.asciz "%lX\n"

	.globl inv_err_str
inv_err_str:
	.asciz "%s [-o|-d] num\n"

	.globl num_clamp_err_str
num_clamp_err_str:
	.asciz "Number must be between 0-100\n"

	.globl	main
main:
	cmp	rdi, 2				# argc == 2 ?
	jg	invocation_err			# case: argc > 2
	jl	invocation_err			# case: argc < 2
	mov	rdi, QWORD PTR [rsi+8]		
	mov	rbx, rdi
	push	rsi				# preserve argv[0] on stack
	sub	rsp, 8				# Create temp pointer on stack
	mov	rsi, rsp			# rsp points to rsi
	mov	rdx, 10			# base 10 conversion
	call	strtol				# strol(argv[1], &err, 10);
	pop	rsi				# pop temp variable off stack to rsi
		
	cmp	BYTE PTR[rsi], 0		# if err_ptr != 0 ('\0'), error detected
	jne	invocation_err			# return with usage statement if error
	pop	rsi				# realign stack

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

	push	rsi				# preserve upper-order bits of num

	lea	rdi, [rip+format_most_sig]	# load format string for printf
	mov	rsi, r8			# move value to print into rsi
	xor	al, al				# zero al before printf call
	call	printf				# print upper order bits

	lea	rdi, [rip+format_least_sig]	# load format string for printf
	pop	rsi				# load into rsi value of upper-order bits
	xor	al, al				# zero al before printf call
	call	printf				# print lower order bits

	xor	rax, rax			# return code 0: SUCCESS
	ret					

	.globl invocation_err
invocation_err:
	pop	rsi
	lea	rdi, [rip+inv_err_str]		# load inv_err string for printf
	mov	rsi, QWORD PTR [rsi]		# move into rsi argv[0]
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
