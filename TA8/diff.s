.section .data

.global main

.include "file1.s"
.include "file2.s"

main:
    # prologue
    pushq %rbp            
    movq %rsp, %rbp      

    # Parse inputs from input file and call printf subroutine
    movq $FILE1, %rdi
    movq $FILE2, %rsi
    call printf_

    # epilogue
    movq %rbp, %rsp
    popq %rbp

    # Exit the program
    movq $0, %rdi        
    movq $60, %rax        
    syscall


# pseudocode
# next steps for every file
# first push the substring of the file1 before \n to the stack
# second push the substring of the file2 before \n to the stack
# pop their values and compare strings
# if there are not the same, output these string in a format stated in the task
# repeat this for the whole file1&file2
# 
