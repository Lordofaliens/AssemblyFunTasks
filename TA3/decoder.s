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
	pushq	%rbp            # push the base pointer (and align the stack)
	movq	%rsp, %rbp      # copy stack pointer value to base pointer

	movq $0, %rdx
	# change callee and caller registers
	decode_loop:
		movq %rdx, %rcx
		movq $MESSAGE, %rax
		movq (%rax,%rdx,8), %r12

		movq %r12, %r14
		and $0xFF, %r14
		shrq $8, %r12

		movq %r12, %r13
		and $0xFF, %r13
		shrq $8, %r12

		print_char:
			movq $formatChar, %rdi
			movq %r14, %rsi
			movq $0, %rax
			call printf

			# Prepare for the next character
			decq %r13
			cmp $0, %r13
			jg print_char

		movq %r12, %rdx
		and $0xFFFFFF, %rdx
		cmp $0, %rdx
		je decode_done
		jmp decode_loop

	# epilogue
	decode_done:
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
