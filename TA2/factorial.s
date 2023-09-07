.text

introFormat: .asciz "<---RECURSION--->\n\n*Made by: Vlad (vmaksymiuk), Pablo (Pablo's NetId)*\n\n%s"
request: .asciz "Print number: "
input: .asciz "%ld"
resultFormat: .asciz "Result: %ld\n"
exception: .asciz "InvalidInputException: %ld\n"

.global main

factorial: 

    # check on base case
    cmpq    $1, %rdx  
    jle     factorial_done

    imul %rdx, %rax # multiplying res by multiplier
    decq %rdx # decrementing multiplier, so we go through every number in range 1 ... n
    call factorial # recursion call

    factorial_done:
        ret 


controller: 

    cmpq $0, %rdi  # Compare a value with a register
    jl factorial_input_handler # Error handler
    cmpq $20, %rdi  # Compare a value with a register
    jg factorial_input_handler # Error handler
    movq $1, %rax # set initial %rax value
    movq %rdi, %rdx # set %rdi (multiplier) to its max value 
    call factorial
    ret

    factorial_input_handler: 
        movq %rdi, %rsi
        lea exception, %rdi 
        movq $0, %rax
        ret

    

main:

    # prologue
    pushq %rbp
    movq %rsp, %rbp
    
    # writing data to the terminal
    movq $0, %rsi
    movq $introFormat, %rdi  # Load the address of the format string
    movq $request, %rsi # Load the variable to be inserted into format string
    movq $0, %rax # clearing %rax before printing 
    call printf # printing

    # reading data from the terminal
    sub $16, %rsp # reserving data in stack for user input and scanf reference
    movq $input, %rdi # input field
    lea -8(%rbp), %rsi # get pointer to the input and store it in %rsi
    movq $0, %rax # clearing %rax before scanning 
    call scanf # scanning
    movq -8(%rbp), %rdi # copy input data to %rdi, so when we pass it to the method we follow the calling convension

    movq %rbp, %rsp

    # checking whether input is not negative
    call controller 
    cmp $0, %rax
    je endErr # skip main logic and output the exception

    call factorial # main function
    
    # printing the result of calculations
    lea resultFormat, %rdi
    movq %rax, %rsi
    call printf
    
    # epilogue
    movq %rbp, %rsp
    popq %rbp

end:                # end with code 0
    movq $0, %rdi
    call exit

endErr:             # end with code 1
    call printf
    movq $0, %rdi
    call exit
