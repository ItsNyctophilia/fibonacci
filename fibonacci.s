.intel_syntax	noprefix

	.globl decimal
decimal:
	.asciz	"-d"

	.globl octal
octal:
	.asciz	"-o"

	.globl format
format:
	.asciz	"%d\n"

	.globl inv_err_str
inv_err_str:
	.asciz "%s [-o|-b] num\n"

	.globl	main
main:
	cmp	rdi, 2				# argc == 2 ?
	jg	invocation_err			# case: argc > 2
	jl	invocation_err			# case: argc < 2
	mov	rdi, QWORD PTR [rsi+8]		
	sub	rsp, 8				# Create temp pointer on stack
	mov	rsi, rsp			# rsp points to rsi
	mov	rdx, 10			# base 10 conversion
	call strtol				# strol(argv[1], &err, 10);
	pop	rsi				# pop temp variable off stack to rsi

	cmp	BYTE PTR[rsi], 0		# if err_ptr != 0 ('\0'), error detected
	jne	invocation_err			# return with usage statement if error

	mov	rcx, rax			# move return from strtol into rcx as counter
	dec	rcx				# account for off-by-one error
	xor	rdi, rdi			# zero rdi
	mov	rsi, 1				# set rsi to 1

fib:
	xor	rax, rax			# zero out rax
	add	rax, rsi			# add n-1
	add	rax, rdi			# add n-2
	mov	rdi, rsi			# set n-2 = n-1
	mov	rsi, rax			# set n-1 = answer from iteration
	loop	fib				# loop until complete

	mov	rax, rsi			# zero rax for 0 return
	
	lea	rdi, [rip + format]		# load format string for printf
	mov	rsi, rax			# move value to print into rsi
	xor	al, al				# zero al before printf call
	call	printf				# printf("%d\n", fib_num);
	
	
	xor	rax, rax			# zero out return register
	ret					# return 0; (SUCCESS)

	

	.globl invocation_err
invocation_err:
	lea	rdi, [rip + inv_err_str]	# load inv_err string for printf
	mov	rsi, QWORD PTR [rsi]		# move into rsi argv[0]
	xor	al, al				# zero al before printf call
	call	printf				# printf("%s", argv[0]);
	mov	rax, 1				# sys_exit call value
	mov	rbx, 1				# return value 1 for failure
	int	0x80				# make syscall
	
	


