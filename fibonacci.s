.intel_syntax	noprefix

	.globl decimal
decimal:
	.asciz	"-d"

	.globl octal
octal:
	.asciz	"-o"

	.globl format
format:
	.asciz	"%s\n"

	.globl inv_err_str
inv_err_str:
	.asciz "%s [-o|-b] num\n"

	.globl	main
main:
	cmp	rdi, 2				# argc == 2 ?
	jg	invocation_err			# case: argc > 2
	jl	invocation_err			# case: argc < 2
	lea	rdi, [rip + format]		# load format string for printf
	mov	rsi, QWORD PTR [rsi+8]		# move into rsi argv[1]
	xor	al, al				# zero al before printf call
	call	printf				# printf("%s", argv[1]);

	ret

	.globl invocation_err
invocation_err:
	lea	rdi, [rip + inv_err_str]	# load inv_err string for printf
	mov	rsi, QWORD PTR [rsi]		# move into rsi argv[0]
	xor	al, al				# zero al before printf call
	call	printf				# printf("%s", argv[0]);
	mov	rax, 1				# sys_exit call value
	mov	rbx, 1				# return value 1 for failure
	int	0x80				# make syscall
	


