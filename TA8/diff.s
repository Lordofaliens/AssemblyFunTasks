.text
    line: .asciz "\n---\n"
    file1: .asciz "\n< "
    file2: .asciz "> "
    newline2: .asciz "\n"
    string_output: .asciz "%s"
    string_output_nl: .asciz "%s\n"

# reserved space for file descriptor
.lcomm fd, 1
.lcomm file1_name_address, 8
.lcomm file2_name_address, 8

# reserved space for files and variables
.lcomm file1_buffer, 1024
.lcomm file2_buffer, 1024
.lcomm current_character_address_file1, 8
.lcomm current_character_address_file2, 8
.lcomm length_line_file1, 8
.lcomm length_line_file2, 8
.lcomm current_line_address_file1, 8
.lcomm current_line_address_file2, 8
.lcomm flag_i, 1
.lcomm flag_B, 1

# syscall codes
.equ sys_read, 0
.equ sys_write, 1
.equ sys_open, 2
.equ sys_close, 3
.equ sys_exit, 60

.global main
main:
    # prologue
	pushq %rbp      
	movq %rsp, %rbp 

    # skip first arg (which is the program itself) & handle more arguments cases
    addq $8, %rsi 
	cmpq $3, %rdi
	jg more_args 
continue_main:
    # copy addresses of the first two arguments to variables 
	movq %rsi, %rax
	movq (%rax), %rax
	movq %rax, (file1_name_address)
	movq %rsi, %rax
	addq $8, %rax
	movq (%rax), %rax
	movq %rax, (file2_name_address)

    # open and save to memory first file
	movq $sys_open, %rax
	movq (file1_name_address), %rdi
	movq $0, %rsi 
	syscall

    # write file 1 to buffer
	movq %rax, (fd) # save file descriptor to memory
	movq $sys_read, %rax # read file from file descriptor and save it to the memory
	movq (fd), %rdi
	movq $file1_buffer, %rsi # file1_buffer is where we will store our file
	movq $1024, %rdx # we set max. file size to 1KB
	syscall
	movq $sys_close, %rax # close the file
	movq $fd, %rdi
	syscall

    # open and save to memory first file
	movq $sys_open, %rax
	movq (file2_name_address), %rdi # file adress to second argument
	movq $0, %rsi
	syscall

    # write file 2 to buffer
	movq %rax, (fd) # save file descriptor to memory
	movq $sys_read, %rax # read file from file descriptor and save it to the memory
	movq (fd), %rdi
	movq $file2_buffer, %rsi # file2_buffer is where we will store our file
	movq $1024, %rdx # we set max. file size to 1KB
	syscall
	movq $sys_close, %rax # close the file
	movq $fd, %rdi
	syscall

	movq $file1_buffer, %r13 # pointer to char, file 1
	movq $file2_buffer, %r14 # pointer to char, file 2
	movq $file1_buffer, (current_character_address_file1)
	movq $file2_buffer, (current_character_address_file2)


	movq $1, %r8 # length of line 1
	movq $1, %r9 # length of line 2
	movq $1, (length_line_file1)
	movq $1, (length_line_file2)

	movq $file1_buffer, %r11 # position of current line, file 1
	movq $file2_buffer, %r12 # position of current line, file 2
	movq $file1_buffer, (current_line_address_file1)
	movq $file2_buffer, (current_line_address_file2)

    # compare content of files
	jmp	compare_files 

after_compare_files:
    # epilogue
	movq %rbp, %rsp 
	popq %rbp      
	movq $sys_exit, %rax
	movq $0, %rdi
    syscall

compare_files:
	jmp	check_file_ended # check if one of the files has already ended
after_check_no_eof:
	jmp	check_nl # check if one of the files goes into new line
after_check_no_nl:
	movb	(%r13), %al # copy one character to the one byte register
	movb	(%r14), %bl # copy one character to the one byte register

	incq %r13 # go to the next character
	incq %r14 # go to the next character

	incq %r8 # increase line length
	incq %r9 # increase line length

    # handle i flag, so we don't care about lower/upper cases
	cmpb $1, (flag_i)
	je make_uppercase

resume_comparing:
	cmpb %al, %bl # compare two charachters, from 2 files
	je	compare_files

    # if not the same, iterate to the end of the lines, then print them
	call	go_to_end_of_line_file1
	call	go_to_end_of_line_file2

# we continue here if there is new line in one of the files
after_check_nl: 
	decq %r8 # decrease the line length so we dont print unnecessary \n
	decq %r9 # decrease the line length so we dont print unnecessary \n
	call print_diff # print the different lines

    # start new line, restore the registers
	movq $1, %r8
	movq $1, %r9
	movq %r13, %r11
	movq %r14, %r12

	jmp	compare_files # if the differences handled, then next main loop iteration

# handle ends of files
check_file_ended:
	cmpb $0, (%r13) # check if current character of file 1 is null
	je check_file_ended_file2_also
	jne	check_file_ended_file2_only

check_file_ended_file2_only:
	cmpb $0, (%r14) # check if current character of file 2 is null
	jne	after_check_no_eof # both not end, then continue 
	je print_eof # only one end, then print diff

check_file_ended_file2_also:
	cmpb $0, (%r14) 
	je after_compare_files # both end, then end
	jne	print_eof # only one end, then print diff


# the same check as for null, but now for \n
check_nl:
	cmpb	$10, (%r13) 
	je	check_nl_file2_also
	jne	check_nl_file2_only

check_nl_file2_only:
	cmpb	$10, (%r14) 
	jne	after_check_no_nl
	call	go_to_end_of_line_file1
	incq %r14	# align strings to the first character after \n
	jmp	after_check_nl

check_nl_file2_also:
	cmpb	$10, (%r14)
	je	both_nl
	call	go_to_end_of_line_file2
	incq %r13  # align strings to the first character after \n

    # handle -B flag, so jump to print the diff
	cmpb $1, (flag_B) 
	jne	after_check_nl

    # set iterators to the beginnings of line in both files
	subq $2, %r14  
	movq $1, %r8   
	movq $1, %r9    
	movq %r13, %r11

	jmp	compare_files

# both lines ended, just go to the next one
both_nl: 
	incq %r13
	incq %r14
	movq $1, %r8
	movq $1, %r9
	movq %r13, %r11
	movq %r14, %r12
	jmp	compare_files

# print differences in case that one file ended before the second one
print_eof:
    # save current state from registers to variables
	movq %r11, (current_line_address_file1)
	movq %r12, (current_line_address_file2)
	movq %r8, (length_line_file1)
	movq %r9, (length_line_file2)
	movq %r13, (current_character_address_file1)
	movq %r14, (current_character_address_file2)

    # writing, writing & again writing

    # write >
	xor	%rsi, %rsi
	movq $string_output, %rdi
	movq $file1, %rsi
	call	printf
    # write file1 (different line)
	movq (current_line_address_file1), %r11
	xor	%rsi, %rsi
	movq $string_output, %rdi
	movq %r11, %rsi
	call printf
    # write ---
	xor	%rsi, %rsi
	movq $string_output, %rdi
	movq $line, %rsi
	call printf
    # write < 
	xor	%rsi, %rsi
	movq $string_output, %rdi
	movq $file2, %rsi
	call printf
    # write file2 (different line)
	movq (current_line_address_file2), %r12
	xor	%rsi, %rsi
	movq $string_output_nl, %rdi
	movq %r12, %rsi
	call printf
	jmp	after_compare_files


# print differences in case there is \n  before there is in the second one 
# PS. the same logic as when file is ended, but don't finish the execution and continue with next line
print_diff:
    # save current state from registers to variables
	movq %r11, (current_line_address_file1)
	movq %r12, (current_line_address_file2)
	movq %r8, (length_line_file1)
	movq %r9, (length_line_file2)
	movq %r13, (current_character_address_file1)
	movq %r14, (current_character_address_file2)

	movq $sys_write, %rax
	movq $1, %rdi
	movq $file1, %rsi
	movq $3, %rdx
    syscall

	movq (length_line_file1), %r8
	movq (current_line_address_file1), %r11
	movq $sys_write, %rax
	movq $1, %rdi
	movq %r11, %rsi
	movq %r8, %rdx
    syscall

	movq $sys_write, %rax
	movq $1, %rdi
	movq $line, %rsi
	movq $5, %rdx
    syscall

	movq $sys_write, %rax
	movq $1, %rdi
	movq $file2, %rsi
	movq $2, %rdx
    syscall

	movq (length_line_file2), %r9
	movq (current_line_address_file2), %r12
	movq $sys_write, %rax
	movq $1, %rdi
	movq %r12, %rsi
	movq %r9, %rdx
    syscall

	movq $sys_write, %rax
	movq $1, %rdi
	movq $newline2, %rsi
	movq $2, %rdx
    syscall

    # restore current state from variables to registers
	movq (length_line_file1), %r8
	movq (length_line_file2), %r9
	movq (current_line_address_file1), %r11
	movq (current_line_address_file2), %r12
	movq (current_character_address_file1), %r13
	movq (current_character_address_file2), %r14
    ret

go_to_end_of_line_file1: # iterate over the current line of the first file to the next one
	cmpb	$10, (%r13)
	je	after_go_to_line1

	incq %r13
	incq %r8

	cmpb	$10, (%r13)
	je	after_go_to_line1

	cmpb	$0, (%r13)
	jne	go_to_end_of_line_file1
after_go_to_line1:
	incq %r13
    ret

go_to_end_of_line_file2: # iterate over the current line of the second file to the next one
	cmpb	$10, (%r14)
	je	after_go_to_line2

	incq %r14
	incq %r9

	cmpb	$10, (%r14)
	je	after_go_to_line2

	cmpb	$0, (%r14)
	jne	go_to_end_of_line_file2
after_go_to_line2:
	incq %r14
    ret

more_args:
	xorq %r15, %r15 # to keep track of how many args we set
	movq (%rsi), %rax # list of args to rax
	cmpb	$105, 1(%rax) # check for -i
	je i_case
	cmpb	$66, 1(%rax) # check for -B
	je b_case
arg_parse:
    addq $8, %rsi # next argument
	cmpq $5, %rdi # if less than 4 args
	jne	continue_main # then there are no further arguments to check
	movq (%rsi), %rax # move list of args to %rax
	cmpb $105, 1(%rax) # check for -i
	je i_case
	cmpb $66, 1(%rax) # check for -B
	je b_case
	jmp	continue_main

i_case:
	movb $1, (flag_i) # set global variable – ignore case
	cmpq $0, %r15 # if this is the first time we're setting an argument
	je arg_parse
	jmp	continue_main

b_case:
	movb	$1, (flag_B) # set global variable – ignore blank lines
	cmpq $0, %r15 # if this is the first time we're setting an argument
	je	arg_parse
	jmp	continue_main

make_uppercase:
	cmpb	$96, %al # if greater than small a
	jg	al_to_capital # check if smaller than small z
continue_with_bl:
	cmpb	$96, %bl # if greater than small a
	jg	bl_to_capital # check if smaller than small z
	jmp	resume_comparing

al_to_capital:
	cmpb	$122, %al # if greater than small z
	jg	continue_with_bl # not a letter
	subb	$32, %al  # else turn into a capital letter
	jmp	continue_with_bl

bl_to_capital:
	cmpb	$122, %bl # if greater than small z
	jg	resume_comparing # not a letter
	subb	$32, %bl # else turn into a capital letter
	jmp	resume_comparing
