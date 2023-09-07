output: .asciz "//"
input: .asciz "%ld"
output2: .asciz "Hello %d!"

.global main


main:
    pushq %rbp
    movq %rsp, %rbp
    
    movq $output, %rdi
    movq $0, %rax
    call printf

    sub $16, %rsp
    movq $input, %rdi
    lea -8(%rbp), %rsi #take my pointer and save it there
    movq $0, %rax 
    call scanf

    movq $output2, %rdi
    mov -8(%rbp), %rsi
    movq $0, %rax
    call printf

    movq %rbp, %rsp
    popq %rbp

end:
    movq $0, %rdi
    call exit
