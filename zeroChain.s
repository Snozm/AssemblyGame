.text
test: .asciz "test"
.global zeroChainer

zeroChainer:
    #prologue
    pushq %rbp
    movq %rsp, %rbp

    pushq %r15
    pushq %r14
    pushq %rbx

    leaq width(%rip), %rdi
    movzb (%rdi), %rdi                      # Store width value into rdi

    leaq height(%rip), %rsi
    movzb (%rsi), %rsi                      # Store height value into rsi

    movq $0, %rdx
    movq %rdi, %rax
    mulq %rsi                               # Store cell count in stack
    pushq %rax
    
    loopHead:
    movq $0, %rbx

    leaq mineArray(%rip), %r15
    movq $0, %r14

    loop:
        
        cmpq (%rsp), %rbx
        jge done
        
        incq %r15
        movq $4, %rax
        andb (%r15), %al
        decq %r15
        cmpq $4, %rax
        jne helper

        cmpb $'0, (%r15)
        jne helper

        
        
        
        call digChording

        addq %rax, %r14                     # Add number of opened mines in r14
        
        jmp helper

    done:
    cmpq $0, %r14                           # Repeat if mines were opened
    
    jne loopHead
    
    popq %rbx
    popq %rbx
    popq %r14
    popq %r15

    #epilogue
    movq %rbp, %rsp
    popq %rbp
ret

helper: 
    incq %rbx
    addq $2, %r15
    jmp loop