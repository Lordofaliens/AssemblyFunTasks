.section .data
separator: .asciz ": "
file1_text:
    .asciz "Hi, this is a testfile.\nTestfile 1 to be precise.\n"
file2_text:
    .asciz "Hi, this is a testfile.\nTestfile 2 to be precise.\n"

.section .text
.global main

main:
    # Compare the two files
    movq $file1_text, %rdi  # Load the address of file1_text
    movq $file2_text, %rsi  # Load the address of file2_text
    pushq %r10
    pushq %r11
    call compare_files
    popq %r11
    popq %r10

    # Exit the program
    mov $60, %rax          # syscall number for sys_exit
    xor %rdi, %rdi         # exit status
    syscall

compare_files:
    # Compare two strings line by line
    # Input: %rdi (address of file1_text), %rsi (address of file2_text)
    xor %rcx, %rcx         # Clear %rcx for line counter
.loop:
    # Load the next byte from file1_text into %al
    movb (%rsi), %al
    # Increment the source pointer
    addq $1, %rsi

    # Load the next byte from file2_text into %bl
    movb (%rdi), %bl
    # Increment the destination pointer
    addq $1, %rdi
    cmp %al, %bl            # Compare the bytes from both files
    jne .difference         # If they are not equal, go to the difference label

    test %al, %al           # Check if it's the null terminator (end of line)
    jz .next_line           # If yes, go to the next line

    jmp .loop               # Repeat the loop

    .difference:
        # Print the line number and difference
        movq $1, %rax           # syscall number for sys_write
        movq $1, %rdi           # file descriptor 1 (stdout)
        lea (%rcx), %rdx        # Load the line number into %rdx (convert from counter)
        call print_number       # Print the line number
        movq $1, %rax           # syscall number for sys_write
        movq $1, %rdi           # file descriptor 1 (stdout)
        movq $separator, %rsi        # Separator
        movq $2, %rdx           # Separator length
        syscall
        movq $1, %rax           # syscall number for sys_write
        movq $1, %rdi           # file descriptor 1 (stdout)
        movsb                   # Load the different character from file1_text into %al
        call print_char         # Print the different character

    .next_line:
        inc %rcx                # Increment the line counter
        cmp %al, %bl            # Check if the last character was null terminator (end of line)
        jnz .loop               # If not, continue the loop

    ret

print_number:
    # Input: %rdx (number to print)
    # Output: Prints the number

    movq %rdx, %rcx         # Copy the number to %rcx
    movq $10, %rax          # Set divisor to 10
    xorq %rbx, %rbx         # Clear %rbx for tracking digits
    subq %rbx, %rcx         # Initialize %rcx as zero

    .find_digits_loop:
        cmpq $0, %rdx         # Check if the number is zero
        je .found_all_digits  # If zero, we have found all digits

        incq %rbx             # Increment digit counter
        xorq %rdx, %rdx       # Clear %rdx (zero flag)
        divq %rax             # Divide %rcx by 10, result in %rax, remainder in %rdx
        addq $48, %rdx        # Convert remainder to ASCII

        pushq %rdx            # Push the ASCII digit onto the stack
        jmp .find_digits_loop # Repeat the loop

    .found_all_digits:
        # Print the digits in reverse order
        movq $1, %rax          # syscall number for sys_write
        movq $1, %rdi          # file descriptor 1 (stdout)
        movq %rsp, %rsi        # Pointer to the last digit on the stack
        movq %rbx, %rdx        # Number of digits to print

    .print_digits_loop:
        popq %r8               # Pop the next ASCII digit from the stack
        movq %r8, %rdx         # Move it into %rdx for printing
        syscall
        decq %rbx              # Decrement digit counter
        jg .print_digits_loop # Repeat if there are more digits

    ret





print_char:
    # Input: %al (character to print)
    # Output: Prints the character

    movq $1, %rax           # syscall number for sys_write
    movq $1, %rdi           # file descriptor 1 (stdout)
    movq $1, %rdx           # Number of characters to print
    syscall

    ret
