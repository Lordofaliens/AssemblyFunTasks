.text

introFormat: .asciz "<---RECURSION--->\n\n*Made by: Vlad (vmaksymiuk), Pablo (Pablo's NetId)*\n\n%s"
request: .asciz "Print number: "
input: .asciz "%ld"
resultFormat: .asciz "Result: %ld\n"
exception: .asciz "InvalidInputException: %ld\n"

.global main

# Recursive factorial function
factorial: 
    # prologue
    pushq %rbp
    movq %rsp, %rbp

    # Allign the stack
    subq $8, %rsp

    # go out of recursion
    cmpq $0, %rdi
    je base_case

    # pre function routine
    pushq %rdi
    decq %rdi

    call factorial # recursion call

    # post function routine
    popq %rsi
    imulq %rsi, %rax
    jmp factorial_done

    base_case: 
        movq $1, %rax

    factorial_done:
        # Allign the stack
        addq $8, %rsp
        
        # epilogue
        movq %rbp, %rsp
        popq %rbp
        ret 

# Controller function
controller:
    # prologue
    pushq %rbp
    movq %rsp, %rbp

    # Preserve callee-saved registers
    pushq %rbx
    pushq %r12
    pushq %r13
    pushq %r14
    pushq %r15

    # check user's input
    cmpq $0, %rdi           
    jl factorial_input_handler  # handle lower boundary
    je zero_base_case       # handle base case
    cmpq $20, %rdi          
    jg factorial_input_handler  # handle higher boundary
    
    # Call the factorial subroutine and print result
    pushq %rax
    call factorial
    movq %rax, %rsi
    popq %rax
    pushq %rax
    leaq resultFormat, %rdi
    movq $0, %rax
    call printf
    popq %rax
    jmp controller_done

    # base case
    zero_base_case:
        pushq %rax
        leaq resultFormat, %rdi
        movq %rax, %rsi
        movq $0, %rax
        call printf  
        popq %rax
        jmp controller_done

    # invalid input case
    factorial_input_handler:
        pushq %rax
        movq %rdi, %rsi    
        leaq exception, %rdi  
        movq $0, %rax # Return 0 in %rax to indicate an exception
        call printf
        popq %rax
    
    controller_done:
        # Restore caller/callee-saved registers
        popq %r15
        popq %r14
        popq %r13
        popq %r12
        popq %rbx

        # epilogue
        movq %rbp, %rsp
        popq %rbp
        ret

# Main function
main:
    # prologue
    pushq %rbp
    movq %rsp, %rbp
    
    # writing data to the terminal
    movq $0, %rsi
    movq $introFormat, %rdi  # Load the address of the format string
    movq $request, %rsi # Load the variable to be inserted into the format string
    movq $0, %rax # clearing %rax before printing 
    call printf # printing

    # reading data from the terminal
    subq $16, %rsp # reserving space in the stack for user input and scanf reference
    movq $input, %rdi # input field
    leaq -8(%rbp), %rsi # get a pointer to the input and store it in %rsi
    movq $0, %rax # clearing %rax before scanning 
    call scanf # scanning
    movq -8(%rbp), %rdi # copy input data to %rdi, following the calling convention

    movq %rbp, %rsp

    # calling factorial through controller
    pushq %rax            # Save %rax on the stack
    subq $8, %rsp         # Adjust the stack pointer by 8 bytes to maintain alignment
    call controller
    addq $8, %rsp         # Restore the stack pointer after the call
    popq %rax             # Restore %rax from the stack


    # epilogue
    movq %rbp, %rsp
    popq %rbp
    movq $0, %rdi
    call exit
