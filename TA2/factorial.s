.text

introFormat: .asciz "<---RECURSION--->\n\n*Made by: Vlad (vmaksymiuk), Pablo (Pablo's NetId)*\n\n%s"
request: .asciz "Print number: "
input: .asciz "%ld"
resultFormat: .asciz "Result: %ld\n"
exception: .asciz "InvalidInputException: %ld\n"

.global main

factorial: 
    # prologue
    pushq %rbp
    movq %rsp, %rbp

    # check on base case
    cmpq    $1, %rdi
    je     factorial_done

    #pre function routine
    pushq %rdi
    decq %rdi

    call factorial # recursion call

    #post function routine
    popq %rsi
    imul %rsi, %rdi
    
    factorial_done:
        movq %rdi, %rax
        movq %rbp, %rsp
        popq %rbp
        ret 


controller:
    # prologue
    pushq %rbp
    movq %rsp, %rbp

    # check user's input
    cmpq $0, %rdi           
    jl factorial_input_handler  # handle lower boundary
    je zero_base_case       # handle base case
    cmpq $20, %rdi          
    jg factorial_input_handler  # handle higher boundary
    
    # Call the factorial subroutine
    call factorial          
    jmp controller_done

    # base case
    zero_base_case:
        movq $1, %rax       
        jmp controller_done

    # invalid input case
    factorial_input_handler:
        movq %rdi, %rsi    
        lea exception, %rdi  
        movq $0, %rax # Return 0 in %rax to indicate an exception
    
    controller_done:
        # epilogue
        movq %rbp, %rsp
        popq %rbp
        
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
    
    # printing the result of calculations 
    lea resultFormat, %rdi
    movq %rax, %rsi
    movq $0, %rax
    call printf
    
    # epilogue
    movq %rbp, %rsp
    popq %rbp
    call end

end:                # end with code 0
    movq $0, %rdi
    call exit

endErr:             # end with code 1
    call printf
    call end
