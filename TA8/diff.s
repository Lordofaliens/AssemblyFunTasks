.section .data
str1:
    .asciz "This is a test string"
str2:
    .asciz "Test string for difference"

i_flag:
    .asciz "-i"

b_flag:
    .asciz "-B"

usage_format: 
    .asciz "usage: <program> <-i> <-B>\n"

.section .bss
flags:
    .long 0

.section .text
.global main 

main:
    # Initialize flags to 0
    pushq %rbp
	movq %rsp, %rbp
    movq $0, flags
    cmp $3, %rdi
	jg wrong_argc
    pushq %rdx
    pushq %rcx

# I DONT KNOW HOW TO PARSE THESE PARAMETERS!!!!!!!!!!!!!
parse_args:
    # Check if the argument is '-i'
    popq %r12
    movq $i_flag, %r14
    cmpq %r12, %r14
    je found_i

    # Check if the argument is '-B'
    movq $b_flag, %r13
    cmpq %r12, %r13
    je found_B

    # Argument is not a flag; move to the next argument
    jmp done

found_i:
    incq flags # Set the -i flag
    jmp next_arg

found_B:
    incq flags # Set the -B flag
    addq $8, %rcx # Move to the next argument (value of -B)
    popq %rax     # Get the value of -B
    jmp next_arg
next_arg:
    addq $8, %rsp # Move to the next argument
    jmp parse_args

done:
    # Check the flags and compute the difference
    cmpq $0, flags
    je no_flags

    # Handle -i flag (case-insensitive)
    cmpq $1, flags
    je case_insensitive

    # Handle -B flag (print B value)
    cmpq $2, flags
    je print_B

no_flags:
    leaq str1(%rip), %rdi
    leaq str2(%rip), %rsi
    call str_diff

exit:
    # Exit the program
    movq $60, %rax
    xorq %rdi, %rdi
    syscall

str_diff:
    # Arguments: (char* str1, char* str2)
    # Output: None
    movq %rdi, %rsi # str1
    movq %rsi, %rdi # str2

    xorq %rcx, %rcx # Counter for differences

    compare_loop:
        movzbq (%rsi), %rdx
        movzbq (%rdi), %rbx
        cmpq %rdx, %rbx
        jne count_diff

        incq %rsi
        incq %rdi
        cmpb $0, %al
        jne compare_loop

        jmp done_compare

    count_diff:
        incq %rcx
        incq %rsi
        incq %rdi
        cmpb $0, %al
        jne compare_loop

    done_compare:
        # %rcx now contains the number of differences
        # You can do something with it here
        pushq %rcx
        leaq format_diff(%rip), %rdi
        call printf
        addq $8, %rsp
        ret

case_insensitive:
    leaq str1(%rip), %rdi
    leaq str2(%rip), %rsi
    call str_diff_case_insensitive
    jmp exit

print_B:
    pushq %rax
    leaq format_B(%rip), %rdi
    call printf
    addq $8, %rsp
    jmp exit

str_diff_case_insensitive:
    # This function is the same as str_diff, but it's case-insensitive
    movq %rdi, %rsi
    movq %rsi, %rdi

    xorq %rcx, %rcx

    compare_loop_insensitive:
        movzbq (%rsi), %rdx
        movzbq (%rdi), %rbx
        cmpq %rdx, %rbx
        je continue_compare

        cmpb $'a', %al
        jl count_diff
        cmpb $'z', %al
        jg count_diff
        subb $'a' - 'A', %al

        cmpb $'a', %ah
        jl count_diff
        cmpb $'z', %ah
        jg count_diff
        subb $'a' - 'A', %ah

        cmpb %al, %ah
        jne count_diff

        continue_compare:
            incq %rsi
            incq %rdi
            cmpb $0, %al
            jne compare_loop_insensitive

        jmp done_compare

wrong_argc:
	movq $usage_format, %rdi
	movq (%rsi), %rsi # %rsi still hold argv up to this point
	call printf
    
    movq $1, %rax
	movq %rbp, %rsp
	popq %rbp
	ret

# Define the format strings for printing
format_B:
    .asciz "-B flag: %d\n"
format_diff:
    .asciz "Number of differences: %d\n"

# Define the format string for printing with -B and -i
format_B_i:
    .asciz "-B flag: %d\nNumber of differences (case-insensitive): %d\n"
