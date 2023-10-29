.text
introFormat: .asciz "<---POWERS--->\n\n*Made by: Vlad (vmaksymiuk), Pablo (Pablo's NetId)*\n\n%s"
baseIntro: .asciz "Print base: "
expIntro: .asciz "Print exp: "
input: .asciz "%ld"
resultFormat: .asciz "Result: %ld\n"
exception: .asciz "UnsupportedInputException: %ld\n"

.global main

pow: 
    # prologue
    pushq %rbp
    movq %rsp, %rbp
    movq $1, %rax

    pow_loop:
        # Check if exp is 0
        cmpq $0, %rsi   
        je pow_done  

        # Multiply result by base and decrement the exponent
        imulq %rdi, %rax   
        decq %rsi 

        # Repeat the loop
        jmp pow_loop        

    pow_done:
        # epilogue
        movq %rbp, %rsp
        popq %rbp
        ret


controller: 
    # prologue
    pushq %rbp
    movq %rsp, %rbp

    cmpq $0, %rsi
    jl exp_input_handler
    call pow
    jmp controller_done
    # invalid input case
    exp_input_handler:   
        lea exception, %rdi  
        movq $0, %rax
        call printf
        call after_compare_files

    controller_done:
        # epilogue
        movq %rbp, %rsp
        popq %rbp
        ret

main:
    # prologue
    pushq %rbp
    movq %rsp, %rbp
    
    pushq %r12
    pushq %r13

    # print intro and base input
    lea introFormat, %rdi  
    movq $baseIntro, %rsi 
    movq $0, %rax
    call printf

    # scan first variable
    sub $16, %rsp # reserve place in stack
    movq $input, %rdi # input field
    lea -16(%rbp), %rsi # pointer where the data will be stored
    movq $0, %rax # preparation for scanning
    call scanf
    movq -16(%rbp), %r12 # store data in register

    # print exp input
    movq $0, %rsi
    lea expIntro, %rdi  # Load the address of the format string
    movq $0, %rsi 
    movq $0, %rax
    call printf

    # scan second variable
    sub $16, %rsp
    movq $input, %rdi
    lea -16(%rbp), %rsi
    movq $0, %rax 
    call scanf
    movq -16(%rbp), %r13

    # pow function call
    movq %r12, %rdi
    movq %r13, %rsi
    call controller

    # printing the output
    lea resultFormat, %rdi
    movq %rax, %rsi
    movq $0, %rax
    call printf

    popq %r13
    popq %r12
    # epilogue
    movq %rbp, %rsp
    popq %rbp
