.text
baseIntro: .asciz "Print base: "
expIntro: .asciz "Print exp: "
name: .asciz "made by: Vlad (vmaksymiuk), Pablo( Pablo's NetId)"
base: .quad 6
exp: .quad 5
resultFormat: .asciz "Result: %ld\n"
signFormat: .asciz "POWERS: \n%s\n"
input: .asciz "%ld"

output2: .asciz "Hello %d!"

.global main

pow: 
    movq %r8, %rsi
    movq base(%rip), %rdi
    movq $1, %rax
    pow_loop:
        testq %rsi, %rsi   # Check if exp is 0
        jz pow_done         # If exp is 0, exit the loop
        IMUL %rdi, %rax   # Multiply result by base
        decq %rsi           # Decrement exp
        jmp pow_loop        # Repeat the loop

    pow_done:
        ret


main:
    pushq %rbp
    movq %rsp, %rbp

    movq $0, %rsi
    movq $baseIntro, %rdi  # Load the address of the format string
    movq $0, %rsi 
    movq $0, %rax
    call printf

    sub $16, %rsp
    movq $input, %rdi
    lea -8(%rbp), %rsi #take my pointer and save it there
    movq $0, %rax 
    call scanf
    movq -8(%rbp), %r8

    sub $16, %rsp
    movq $input, %rdi
    lea -8(%rbp), %rsi #take my pointer and save it there
    movq $0, %rax 
    call scanf
    movq -8(%rbp), %r9

    movq $0, %rsi
    movq $expIntro, %rdi  # Load the address of the format string
    movq $0, %rsi 
    movq $0, %rax
    call printf

    movq %rbp, %rsp

    #sub $16, %rsp
    #movq $input, %rdi
    #lea -8(%rbp), %rsi #take my pointer and save it there
    #movq $0, %rax 
    #call scanf
    #movq -8(%rbp), %r9

    call pow
    lea resultFormat, %rdi  # Load the address of the format string
    
    movq %rax, %rsi
    call printf
    
    movq $0, %rsi
    movq $signFormat, %rdi  # Load the address of the format string
    movq $name, %rsi 
    movq $0, %rax
    call printf

    movq %rbp, %rsp
    popq %rbp

end:
    movq $0, %rdi
    call exit
