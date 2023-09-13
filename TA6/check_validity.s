.text

.include "neighboringValid.s"

invalid: .asciz "invalid"
valid: .asciz "valid"

.global main

check_validity:
	# prologue
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer
    
    # Preserve callee-saved registers
    pushq %rbx
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15

    movq $0, %rbx # index of char of string
    movq $0, %r14 # counter of elements in the stack

    check_loop:
        movq (%rdi, %rbx), %r12 # Load 64 bits beginning with index
        andq $0xFF, %r12 # convert it to last 2 bytes
        testq %r12, %r12 # check if it's the end of string
        jz done 
        
        # compare char with possible opening brackets
        cmp $40, %r12
        je add_stack
        cmp $60, %r12
        je add_stack
        cmp $91, %r12
        je add_stack
        cmp $123, %r12
        je add_stack

        # compare char with possible closing brackets
        cmp $41, %r12
        je sub_stack
        cmp $62, %r12
        je sub_stack
        cmp $93, %r12
        je sub_stack
        cmp $125, %r12
        je sub_stack

        # default case
        movq $invalid, %rax
        jmp epilogue

    # bracket is opening -> push it to the stack
    add_stack:
        pushq %r12

        # change index and counter
        inc %r14
        inc %rbx

        jmp check_loop

    # bracket is closing -> pop char from the stack and check types of these brackets
    sub_stack:
        popq %r13
        subq %r13, %r12

        # change index and counter 
        dec %r14
        inc %rbx
        
        # stack is empty error (cannot get the opening bracket)
        cmp  $0, %r14
        jl failed

        # brackets  the same type -> continue
        cmp  $2, %r12
        jle check_loop

    # check whether stack is empty (every opening bracket is closed)
    done:
        cmp $0, %r14
        je success
        movq $invalid, %rax
        jmp epilogue
    
    # exit code 1
    failed: 
        movq $invalid, %rax
        jmp epilogue

    # exit code 0
    success:
        movq $valid, %rax

    # Restore caller/callee-saved registers
    epilogue:
        popq %r15
        popq %r14
        popq %r13
        popq %r12
        popq %rbx

    # epilogue
    movq	%rbp, %rsp		# clear local variables from stack
    popq	%rbp			# restore base pointer location 
    ret

main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi		# first parameter: address of the message
	call	check_validity		# call check_validity

    movq %rax, %rdi
    call printf

	popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program
