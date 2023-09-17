.section .data
minus_one: .quad  -1
minus: .asciz "-"
buffer: .space 64 

.global main

.include "input2.s"

main:
    # prologue
    pushq %rbp            
    movq %rsp, %rbp      

    # Parse inputs from input file and call printf subroutine
    movq $INPUT1, %rdi
    movq $INPUT2, %rsi
    movq $INPUT3, %rcx
    movq $INPUT4, %r8
    movq $INPUT5, %r9
    call printf_

    # epilogue
    movq %rbp, %rsp
    popq %rbp

    # Exit the program
    movq $0, %rdi        
    movq $60, %rax        
    syscall

printf_:
    # prologue
    pushq %rbp            
    movq %rsp, %rbp       
    
    # push paramets to use when needed to be inserted
    pushq %r9
    pushq %r8
    pushq %rcx
    pushq %rsi

    # ????
    movq %rdi, %rdx        # Copy format string to %rdx
    movq %rsi, %rdi        # Set pointer to variable arguments (%rsi initially points to format string)

    parse_format:
        movb (%rdx), %al        # Load the next character from the format string
        testb %al, %al          # Check for null terminator
        jz end_format           # If null terminator found, exit loop

        cmpb $'%', %al          # Check for '%'
        jne print_char          # If not '%', print it as is

        # Handle format specifier
        movb 1(%rdx), %al       # Load the character after '%' into al
        
        cmpb $'s', %al          # Check if it's 's' for string
        je handle_string
        cmpb $'d', %al          # Check if it's 'd' for signed_integer
        je handle_integer_signed
        cmpb $'u', %al          # Check if it's 'd' for signed_integer
        je handle_integer_unsigned
        cmpb $'%', %al          # Check if it's '%' for per cent
        je handle_per_cent
        
        jmp print_char

    # Format handlers

    # %s handler
    handle_string:
        popq %rdi               # Pop variable argument (string) address
        pushq %rcx
        pushq %rdx
        pushq %rdi
        pushq %rsi
        call printf_internal_string
        popq %rsi               
        popq %rdi               
        popq %rdx
        popq %rcx
        addq $2, %rdx           # Skip the '%s' specifier
        jmp parse_format

    # %d handler
    handle_integer_signed:
        popq %rdi               # Pop variable argument (number) address
        pushq %rcx
        pushq %rdx
        pushq %rdi
        pushq %rsi
        pushq %r8
        call printf_internal_number_signed
        popq %r8
        popq %rsi               
        popq %rdi               
        popq %rdx
        popq %rcx
        addq $2, %rdx           # Skip the '%d' specifier
        jmp parse_format

    # %u handler
    handle_integer_unsigned:
        popq %rdi               # Pop variable argument (number) address
        pushq %rcx
        pushq %rdx
        pushq %rdi
        pushq %rsi
        pushq %r8
        call printf_internal_number_unsigned
        popq %r8
        popq %rsi              
        popq %rdi               
        popq %rdx
        popq %rcx
        addq $2, %rdx           # Skip the '%u' specifier
        jmp parse_format

    # %% handler
    handle_per_cent:
        addq $1, %rdx
        jmp print_char

    # printing common char
    print_char:
        movq $1, %rax           
        movq $1, %rdi          
        movq %rdx, %rsi  

        pushq %rdx
        movq $1, %rdx           
        syscall
        popq %rdx

        incq %rdx               # Move to the next character
        jmp parse_format

    # end of the string
    end_format:
        movq %rbp, %rsp
        popq %rbp
        ret


    printf_internal_string:
        # prologue
        pushq %rbp            
        movq %rsp, %rbp       

        pushq %rbx

        movq $1, %rax           
        movq %rdi, %rsi         
        movq $1, %rdi     

        # calculating length
        pushq %rax
        pushq %rdx
        call output_number_string_length
        popq %rdx
        movq %rax, %rdx
        popq %rax

        # printing inserted string 
        syscall

        popq %rbx
        
        # epilogue
        movq %rbp, %rsp
        popq %rbp
        ret
    
    printf_internal_number_unsigned:
        # prologue
        pushq %rbp              
        movq %rsp, %rbp  

        # convert number to string and print it       
        jmp output_number

    printf_internal_number_signed:
        pushq %rbp              # Save callee-saved register rbp
        movq %rsp, %rbp         # Set the stack pointer as the new base pointer

        cmp $0, %rdi
        jge output_number

        # handle cases, when number is negative
        pushq %rax
        pushq %rdx
        pushq %rdi
        pushq %rsi
        movq $1, %rax
        movq $2, %rdx
        movq $1, %rdi
        movq $minus, %rsi
        syscall
        popq %rsi
        popq %rdi
        popq %rdx
        popq %rax
        
        imul minus_one, %rdi

    # output non-negative number
    output_number: 
        movq $10, %rcx          # Set divisor to 10
        movq $buffer, %rsi      # Load the address of the buffer for the string
        addq $63, %rsi          # Move the buffer pointer to the end of the buffer
        movb $0, (%rsi)         # Null-terminate the string
        movq %rdi, %rax         # Copy the integer to rax
        movq %rdi, %r8          # Copy the integer to r8
            
        convert_loop:
            decq %rsi               # Move the buffer pointer backward
            xorq %rdx, %rdx         # Clear upper 32 bits of rdx
            divq %rcx               # Divide rax by rcx, result in rax, remainder in rdx
            addb $'0', %dl          # Convert remainder to ASCII
            movb %dl, (%rsi)        # Store the ASCII character in the buffer
            testq %rax, %rax        # Check if quotient is zero
            jnz convert_loop

        movq $1, %rax           
        movq $1, %rdi           
        
        pushq %rax
        pushq %rsi
        pushq %rdi
        movq %r8, %rdi
        call output_number_length
        movq %rax, %rdx
        popq %rdi
        popq %rsi
        popq %rax

        syscall

        # epilogue
        movq %rbp, %rsp
        popq %rbp
        ret

# calculate string length
output_number_string_length:
    # prologue
    pushq %rbp            
    movq %rsp, %rbp       

    movq $0, %rdx         # Initialize %rdx to 0 (string length)
    
    count_loop:
        movb (%rsi, %rdx), %al # Load the next character into %al
        testb %al, %al          # Check for null terminator
        jz done_counting_string # If null terminator found, exit loop
        
        incq %rdx               # Increment the string length
        jmp count_loop          # Continue counting

    # finish counting length and follow calling conventions
    done_counting_string:
        movq %rdx, %rax

        # epilogue
        movq %rbp, %rsp
        popq %rbp
        ret

# calculate number length (digits)
output_number_length:
    pushq %rbp            # Save the base pointer
    movq %rsp, %rbp       # Set the stack pointer as the new base pointer
    
    movq $0, %r8          # Initialize r8 to 0 (initial number length)
    movq %rdi, %rax       # Copy the number to rax
    movq $10, %rcx        # Set divisor to 10
    
    count_number_loop:
        # check whether the number length is calculated
        cmpq $10, %rax        
        jl done_counting_number
        
        movq $0, %rdx
        divq %rcx             # Divide rax by rcx, result in rax, remainder in rdx
        incq %r8              # Increment the length counter
        jmp count_number_loop

    done_counting_number:
        # finish counting length and follow calling conventions
        movq %r8, %rax
        incq %rax

        # epilogue
        movq %rbp, %rsp
        popq %rbp
        ret
