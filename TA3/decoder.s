.text

formatChar: .asciz "%c"

.include "final.s"

.global main

# ************************************************************
# Subroutine: decode                                         *
# Description: decodes message as defined in Assignment 3    *
#   - 2 byte unknown                                         *
#   - 4 byte index                                           *
#   - 1 byte amount                                          *
#   - 1 byte character                                       *
# Parameters:                                                *
#   first: the address of the message to read                *
#   return: no return value                                  *
# ************************************************************
	
decode:
	# prologue
	pushq	%rbp            # save callee-saved register %rbp
	movq	%rsp, %rbp      # copy stack pointer value to base pointer
	pushq	%r12            # save callee-saved register %r12
	pushq	%r13            # save callee-saved register %r13
	pushq	%r14            # save callee-saved register %r14

	movq $0, %rdx
	# change callee and caller registers
	decode_loop:
		# storing element in %r12 
		movq $MESSAGE, %rax
		movq (%rax,%rdx,8), %r12

		# storing value of element in %r14 
		movq %r12, %r14
		and $0xFF, %r14
		shrq $8, %r12

		# storing the number of elements in %r13 
		movq %r12, %r13
		and $0xFF, %r13
		shrq $8, %r12
		
		# printing using loop
		print_char:
			pushq   %rax # Align the stack
			movq $formatChar, %rdi
			movq %r14, %rsi
			movq $0, %rax
			call printf
			popq %rax # Restore stack alignment

			# check whether element is printed the required number of times
			decq %r13
			cmp $0, %r13
			jg print_char

		# check whether element is the last in the array
		movq %r12, %rdx
		and $0xFFFFFF, %rdx
		cmp $0, %rdx
		jne decode_loop
		
	# epilogue
	decode_done:
		popq	%r14            # restore callee-saved register %r14
		popq	%r13            # restore callee-saved register %r13
		popq	%r12            # restore callee-saved register %r12
		movq	%rbp, %rsp      # clear local variables from the stack
		popq	%rbp            # restore the base pointer location
		ret

main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi	# first parameter: address of the message
	call	decode			# call decode

	popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program
