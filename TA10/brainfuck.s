.global brainfuck

.bss
	array: .zero 30000

.text
format_str: .asciz "We should be executing the following code:\n%s\n"
char_str: .asciz "%c"
input_str: .asciz "%c"

# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.

# RAX - input index
# RDI - current cell index
# RSI - current character
# RDX - brackets balance
brainfuck:
	pushq %rbp
	movq %rsp, %rbp

	movq %rdi, %rsi
	movq %rsi, %rbx
	movq $0, %rax
	movq $format_str, %rdi
	call printf

	movq $0, %rdx
	movq $30000, %rax
memoryLoop:
	subq $1, %rsp
	movb $0, (%rsp)
	decq %rax
	cmpq $0, %rax
	jne memoryLoop

#output for debug
	#movzbq (%rax, %rbx, 1), %rsi
	#pushq %rax
	#pushq %rdi
	#pushq %r8
	#pushq %rdx
	#movq $char_str, %rdi
	#movq $0, %rax
	#call printf
	#popq %rdx
	#popq %r8
	#popq %rdi
	#popq %rax	

	movq $-1, %rax				#init loop counter
	#movq %rbp, %rdi
	#subq $1, %rdi

	leaq array(%rip), %rdi		#init pointer to cell array	

mainLoop:
	incq %rax					#increase loop counter

#output for debug
	#movzbq (%rax, %rbx, 1), %rsi
	#pushq %rax
	#pushq %rdi
	#pushq %r8
	#pushq %rdx
	#movq $char_str, %rdi
	#movq $0, %rax
	#call printf
	#popq %rdx
	#popq %r8
	#popq %rdi
	#popq %rax
	
	movzbq (%rax, %rbx, 1), %rsi	#get next character in program

	cmpq $43, %rsi					#if + instruction
	je plusOperand

	cmpq $45, %rsi					#if - instruction
	je minusOperand

	cmpq $62, %rsi					#if > instruction
	je arrowRightOperand

	cmpq $60, %rsi					#if < instruction
	je arrowLeftOperand

	cmpq $91, %rsi					#if [ instruction
	je openBracket

	cmpq $93, %rsi					#if ] instruction
	je closeBracket

	cmpq $46, %rsi					#if . instruction
	je printCell
	
	cmpq $44, %rsi					#if , instruction
	je comaOperand

	cmpq $0, %rsi					#if EOF
	je endBrainfuck

	jmp mainLoop					#if any other character jump back to loop
	
endBrainfuck:
	movq %rbp, %rsp
	popq %rbp
	ret

plusOperand:
	incb (%rdi)						#incrimnets value in selected cell by one
	jmp mainLoop					#jumps back

minusOperand:
	decb (%rdi)						#decrease value in selected cell by one
	jmp mainLoop					#jumps back

arrowLeftOperand:
	decq %rdi						#decrease cell pointer by one
	jmp mainLoop					#jumps back

arrowRightOperand:
	incq %rdi						#increase cell pointer by one
	jmp mainLoop					#jumps back

openBracket:
	movzbq (%rdi), %rsi				#gets value in selected cell
	cmpq $0, %rsi					#checks if it is not zero
	jne mainLoop					#if so, jums back to loop
	movq $1, %rdx					#set value of RDX as 1, if value is zero (RDX - "Bracket balance")
openedBracketLoop:					#loop to find closing bracket that corresponds to this opening brakcet
	incq %rax						#increase program pointer by one
	movzbq (%rax, %rbx, 1), %rsi	#get value of instruction
	cmpq $93, %rsi					#check if it's [
	je openedBracketLoopOptionClosed
	cmpq $91, %rsi					#check if it's ]
	je openedBracketLoopOptionOpened
	jmp openedBracketLoop			#if it is not a bracket - continue on looping

openedBracketLoopOptionClosed:
	decq %rdx						#decrease bracket balance by one
	cmpq  $0, %rdx					#check if balance is zero	
	je mainLoop						#if it is - we found bracket that corresponds to that opening bracket
	jmp openedBracketLoop			#if no - continue on looping

openedBracketLoopOptionOpened:
	incq %rdx						#increase bracket balance by one
	jmp openedBracketLoop			#continue on looping

closeBracket:
	movzbq (%rdi), %rsi
	cmpq $0, %rsi
	je mainLoop
	movq $0, %rdx
closedBracketLoop:
	decq %rax
	movzbq (%rax, %rbx, 1), %rsi
	cmpq $91, %rsi
	je closedBracketLoopOptionOpened
	cmpq $93, %rsi
	je closedBracketLoopOptionClosed
	jmp closedBracketLoop

closedBracketLoopOptionOpened:
	incq %rdx
	cmpq $1, %rdx 
	je mainLoop
	jmp closedBracketLoop

closedBracketLoopOptionClosed:
	decq %rdx
	jmp closedBracketLoop

comaOperand:
	movq %rdi, %rsi
	pushq %rax
	pushq %rdi
	movq $input_str, %rdi
	movq $0, %rax
	call scanf
	popq %rdi
	popq %rax
	jmp mainLoop

printCell:
	movq %rdi, %rsi
	pushq %rax
	pushq %rdi
	movq $1, %rax
	movq $1, %rdi
	movq $1, %rdx
	syscall
	popq %rdi
	popq %rax
	jmp mainLoop
