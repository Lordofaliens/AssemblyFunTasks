.text
    str: .string "Coati"
    hello: 
        .asciz "Hello!\n"
    helloend: 
        .equ length, helloend - hello
.global main

main:
    pushq %rbp
    movq %rsp, %rbp

    movq $1 , %rax 
    movq $1 , %rdi 
    movq $hello , %rsi 
    movq $length, %rdx 
    syscall

    
    movq %rbp, %rsp
    popq %rbp
    call exit
