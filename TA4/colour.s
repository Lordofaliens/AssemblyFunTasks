.text
    # \x1B[1; - bold
    # \x1B[0; - stop blinking / default / reveal
    # \x1B[2; - faint
    # \x1B[5; - blink
    # \x1B[8; - conceal
formatChar: .asciz "\x1B[%d;38;5;%dm\x1B[48;5;%dm%c\x1B[0m"

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
	pushq	%rbx            # save callee-saved register %rbx
	pushq	%r12            # save callee-saved register %r12
	pushq	%r13            # save callee-saved register %r13
    pushq   %r14            # save callee-saved register %r14
    pushq   %r15            # save callee-saved register %r15

	movq $0, %rdx           # set init next element index to 0       
	pushq %rdi
    decode_loop:
		# storing element in %rbx 
		movq -48(%rbp), %rax
		movq (%rax,%rdx,8), %rbx

		# storing value of element in %r13 
		movq %rbx, %r13
		and $0xFF, %r13
		shrq $8, %rbx

		# storing the number of elements in %r12 
		movq %rbx, %r12
		and $0xFF, %r12
		shrq $8, %rbx

        # check whether element is the last in the array
		movq %rbx, %rdx
		and $0xFFFFFF, %rdx
        shrq $32, %rbx

        # storing the color of element in %r14 
		movq %rbx, %r14
		and $0xFF, %r14
		shrq $8, %rbx

        # storing the color of background in %r15 
		movq %rbx, %r15
		and $0xFF, %r15
		shrq $8, %rbx

		
		# printing using loop
		print_char:
			pushq   %rdx # Align the stack
            cmp     %r14, %r15 #  if background==color, then delete coloring, add effect
            jne insert_variables
            
            # choose effect depending on the color
            cmp $0, %r14
            jmp case1
            cmp $37, %r14
            jmp case1
            cmp $153, %r14
            jmp case1
            cmp $42, %r14
            jmp case2
            cmp $66, %r14
            jmp case3
            cmp $105, %r14
            jmp case4
            cmp $182, %r14
            jmp case5
            #  first variable (effect) 
            case1:
                movq $0, %rsi
                jmp insert_variables_effect
            case2:
                movq $1, %rsi
                jmp insert_variables_effect
            case3:
                movq $2, %rsi
                jmp insert_variables_effect
            case4:
                movq $8, %rsi
                jmp insert_variables_effect
            case5:
                movq $5, %rsi
                jmp insert_variables_effect

            # delete coloring
            insert_variables_effect:
                movq $2, %r14
                movq $0, %r15
                movq $0, %rbx

            # insert variables into the string and print it
            insert_variables:
                pushq %rax
                movq    $formatChar, %rdi  # Set format string as the first argument
                movq    %r14, %rdx  # second variable (color) 
                movq    %r15, %rcx  # third variable (background) 
                movq    %r13, %r8   # fourth variable (value) 
                movq $0, %rax
                call printf
                popq %rax
            
            popq %rdx # Restore stack alignment

			# check whether element is printed the required number of times
			decq %r12
			cmp $0, %r12
			jg print_char

		# check whether element is the last in the array
	    cmp $0, %rdx
		jne decode_loop
		
	# epilogue
	decode_done:
        popq %rdi
        popq   %r15            # restore callee-saved register %r15
        popq   %r14            # restore callee-saved register %r14
		popq	%r13            # restore callee-saved register %r13
		popq	%r12            # restore callee-saved register %r12
		popq	%rbx            # restore callee-saved register %rbx
		movq	%rbp, %rsp      # clear local variables from the stack
		popq	%rbp            # restore the base pointer location
		ret

main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer
    pushq	%rbx            # save callee-saved register %rbx
	pushq	%r12            # save callee-saved register %r12
	pushq	%r13            # save callee-saved register %r13
    pushq   %r14            # save callee-saved register %r14
    pushq   %r15            # save callee-saved register %r15
    subq $8, %rsp
	movq	$MESSAGE, %rdi	# first parameter: address of the message
	call	decode			# call decode
    addq $8, %rsp
    pushq   %r15            # restore callee-saved register %r15
    pushq   %r14            # restore callee-saved register %r14
    popq	%r13            # restore callee-saved register %r13
    popq	%r12            # restore callee-saved register %r12
    popq	%rbx            # restore callee-saved register %rbx

	popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program
