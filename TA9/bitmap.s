.global main

.bss
    forEncodedMessage: .skip 10000
    key: .skip 10000
    lockedMessage: .skip 10000

.data
    message: .asciz "The answer for exam question 42 is not F."
    message2: .asciz "The quick brown fox jumps over the lazy dog" 
    leadtrail: .asciz "CCCCCCCCSSSSEE1111444400000000"
    barcode: .asciz "barcode.bmp"
    result: .asciz "result.bmp"

.text
    format_str: .asciz "%dx%c\n"
    debug_str: .asciz "%d "
    char_str: .asciz "%c"


encodeMessage:
    pushq %rbp
    movq %rsp, %rbp
    
    pushq %rsi
    movq $message, %rsi
    movq $leadtrail, %r8

    movq $0, %r9                #initialize our string counter
    movb (%r9, %r8), %dil       #get a character from a string
    movb %dil, 1(%r12)          #initialize first character
    movb $1, (%r12)             #initialize counter of first character

addHeadLoop:
    incq %r9
    movb (%r9, %r8), %dil       #get a character from a string
    cmpb $0, %dil               #check if's end of the string
    je addMessage               #if so, jump to next stage
    cmpb 1(%r12), %dil          #check if character sams as previous
    jne notEqualOptionHead      #if not - jump to notEqualOptionHead

equalOptionHead:                #if character is the same as previous
    incb (%r12)
    jmp addHeadLoop

notEqualOptionHead:             #if character is not the same as previous
    incq %r12
    incq %r12
    movb %dil, 1(%r12)          # write next character to array
    movb $1, (%r12)             #initialize counter of the character
    jmp addHeadLoop

addMessage:
    movq $-1, %rdx

encodeLoop:
    incq %rdx
    movb (%rdx, %rsi), %dil
    cmpb $0, %dil
    je addTail
    cmpb 1(%r12), %dil
    jne notEqualOption

equalOption:
    incb (%r12)
    jmp encodeLoop

notEqualOption:
    incq %r12                   
    incq %r12
    movb %dil, 1(%r12)
    movb $1, (%r12)
    jmp encodeLoop

addTail:
    movq $-1, %r9

addTailLoop:
    incq %r9
    movb (%r9, %r8), %dil
    cmpb $0, %dil
    je endEncoding
    cmpb 1(%r12), %dil
    jne notEqualOptionTail

equalOptionTail:
    incb (%r12)
    jmp addTailLoop

notEqualOptionTail:
    incq %r12
    incq %r12
    movb %dil, 1(%r12)
    movb $1, (%r12)
    jmp addTailLoop

endEncoding:
    movq %r12, %rax
    movq %rbp, %rsp
    popq %rbp
    ret

reformatMessage:
    pushq %rbp 
    movq %rsp, %rbp

    leaq result, %rdi
    movq $0, %rdx
    movq $2, %rax
    movq $0, %rsi
    syscall

    pushq %rax

    movq %rax, %rdi
    movq $0, %rax
    leaq forEncodedMessage(%rip), %rsi
    movq $3126, %rdx
    syscall

    popq %rdi
    movq $3, %rax
    syscall

    movq %rbp, %rsp
    popq %rbp
    ret


generateKey:
    pushq %rbp
    movq %rsp, %rbp

    leaq barcode, %rdi
    movq $0, %rdx
    movq $2, %rax
    movq $0, %rsi
    syscall

    pushq %rax

    movq %rax, %rdi
    movq $0, %rax
    leaq key(%rip), %rsi
    movq $3126, %rdx
    syscall

    popq %rdi
    movq $3, %rax
    syscall

    movq %rbp, %rsp
    popq %rbp
    ret


writeLockedMessage:
    pushq %rbp
    movq %rsp, %rbp

    leaq result, %rdi
    movq $420, %rdx
    movq $2, %rax
    movq $577, %rsi
    syscall

    pushq %rax

    movq %rax, %rdi
    movq $1, %rax
    leaq lockedMessage(%rip), %rsi
    movq $3126, %rdx
    syscall

    popq %rdi
    movq $3, %rax
    syscall

    movq %rbp, %rsp
    popq %rbp
    ret

lockMessage:
    pushq %rbp
    movq %rsp, %rbp
    pushq %rdx

    leaq lockedMessage(%rip), %rax
    movq $0, %rdx

    movb $66, (%rdx, %rax, 1)           #B
    addq $1, %rdx

    movb $77, (%rdx, %rax, 1)           #M
    addq $1, %rdx

    movl $0, (%rdx, %rax, 1)            #filesize
    addq $4, %rdx

    movl $3126, (%rdx, %rax, 1)         #reserved field
    addq $4, %rdx

    movl $0, (%rdx, %rax, 1)            #offset of pixel data
    addq $4, %rdx

    movl $40, (%rdx, %rax, 1)           #header size
    addq $4, %rdx

    movl $32, (%rdx, %rax, 1)           #width of image in pixels
    addq $4, %rdx

    movl $32, (%rdx, %rax, 1)           #height
    addq $4, %rdx

    movb $1, (%rdx, %rax, 1)            #first reserved field 
    incq %rdx

    movb $1, (%rdx, %rax, 1)            #second reserved field
    incq %rdx

    movw $24, (%rdx, %rax, 1)           #bits per pixel
    addq $2, %rdx

    movl $0, (%rdx, %rax, 1)            #compression
    addq $4, %rdx

    movl $3072, (%rdx, %rax, 1)         #pixel data (3*32*32)
    addq $4, %rdx

    movl $2835, (%rdx, %rax, 1)         #pixel per meter
    addq $4, %rdx

    movl $2835, (%rdx, %rax, 1)         #pixel per meter
    addq $4, %rdx

    movl $0, (%rdx, %rax, 1)            #color palette information
    addq $4, %rdx

    movl $0, (%rdx, %rax, 1)            #important colours
    addq $4, %rdx

    addq %rdx, %rax

    popq %rdx
    movq %rdx, %r13
    movq $-1, %r15

loop:
    incq %r15
    movb (%r15, %r13, 1), %dl           #1 byte of rdx
    xorb (%rsi), %dl
    movb %dl, (%r15, %rax, 1)
    incq %rsi
    cmpq  $3072, %r15
    jne loop 

    movq %rbp, %rsp
    popq %rbp
    ret



outputMessage:
    pushq %rbp
    movq %rsp, %rbp

    leaq lockedMessage(%rip), %rax
    addq $52, %rax                      #just skip BMP info

whileLoop:                              #loop till the end of the message
    incq %rax
    incq %rax
    cmpb $0, 1(%rax)
    jne whileLoop

    movb $0, -2(%rax)                   #ignore tail of the message
    movb $0, -4(%rax)
    movb $0, -6(%rax)
    movb $0, -8(%rax)
    movb $0, -10(%rax)
    subq $8, -12(%rax)

    leaq lockedMessage(%rip), %rax      #intialize RAX as a pointer to decrypted message
    addq $54, %rax                      #skip BMP info
    movb $0, (%rax)                     #bunch of movb in order to ignore head of the message
    movb $0, 2(%rax)
    movb $0, 4(%rax)
    movb $0, 6(%rax)
    movb $0, 8(%rax)
    subq $8, 10(%rax)

whileLoopMain:
    incq %rax                           #increase loop counter
    incq %rax
    cmpb $0, 1(%rax)                    #check if character not 0
    je endOutput                        #if so, end output
    cmpb $0, (%rax)                     #check if number of characters is 0
    je whileLoopMain                    #if so - go to next character
    movzbq (%rax), %rdx                 #set number of characters as RDX
outputCharacterLoop:
    decq %rdx                           #decq amount of characters to print
    movzbq 1(%rax), %rsi                #get value of a character  
    movq $char_str, %rdi                #assign output format
    pushq %rax
    movq $0, %rax                       #assign 0 to safely use printf
    call printf                         #output character in terminal
    popq %rax                           #restore RAX
    cmpq $0, %rdx                       #check if there are more characters to output
    jne outputCharacterLoop             
    jmp whileLoopMain                   

endOutput:
    movq %rbp, %rsp
    popq %rbp
    ret


encryptMessage:
    pushq %rbp
    movq %rsp, %rbp

    leaq forEncodedMessage(%rip), %rbx
    movq %rbx, %r12
    call encodeMessage
    movq %rax, %r12
    movq %rbx, %r13
    
    call generateKey
    leaq key(%rip), %r13
    addq $54, %r13          #beginning of the key
    movq %r13, %rdx
    movq %r12, %rdi         #beginning of the encoded message
    movq %rbx, %rsi         #end of the encoded message
    call lockMessage
    call writeLockedMessage

    movq %rbp, %rsp 
    popq %rbp
    ret

decryptMessage:
    pushq %rbp
    movq %rsp, %rbp

    call reformatMessage

    leaq forEncodedMessage(%rip), %rbx
    movq %rbx, %r12
    addq $54, %r12

    
    call generateKey
    leaq key(%rip), %r13
    addq $54, %r13                      #beginning of the key

    movq %r13, %rdx
    movq %r12, %rsi                     #beginning of the encoded message
    movq %r12, %rdi                     #end of the encoded message
    addq $3072, %rdi
    call lockMessage

    call outputMessage
    
    movq %rbp, %rsp
    popq %rbp
    ret

main:
    pushq %rbp
    movq %rsp, %rbp

    #call encryptMessage
    call decryptMessage
    
    movq %rbp, %rsp
    popq %rbp
    ret

