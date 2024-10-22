.text
testS: .asciz "test"
.global openMineCheck
.global revealMines

openMineCheck:
    #prologue
    pushq %rbp
    movq %rsp, %rbp

    pushq $0
    pushq %rbx

    movq $0, %rbx

    leaq width, %rdi
    movzb (%rdi), %rdi                      # Store width value into rdi

    leaq height, %rsi
    movzb (%rsi), %rsi                      # Store height value into rsi

    movq $0, %rdx
    movq %rdi, %rax
    mulq %rsi                               # Store cell count in rcx
    movq %rax, %rcx

    leaq mineArray, %r8

checkLoop:
    cmpq %rcx, %rbx                          # Check if its the final cell in the array
    jge checkDone

    cmpb $'#, (%r8)                          # Check if cell is a mine
    jne helperPlus

    incq %r8
    movq $4, %rax
    andb (%r8), %al                          # Open mine cell
    decq %r8
    cmpq $4, %rax
    jne helperPlus

    pushq %rbx
    pushq %r8
    movq $1, %rsi
    jmp revealMines

checkDone:

    popq %rbx

    #epilogue
    movq %rbp, %rsp
    popq %rbp
ret

revealMines:
    movq $0, %rbx

    leaq mineArray, %r8

loop:
    cmpq %rcx, %rbx                          # Check if its the final cell in the array
    jge done

    cmpb $'#, (%r8)                             # Check if cell is a mine
    jne helper

    incq %r8
    orb $4, (%r8)                               # Open mine cell
    decq %r8
    
    jmp helper

done:
    popq %r8
    popq %rbx
jmp helperPlus

helper:
    incq %rbx
    addq $2, %r8                            # Move to next cell
    jmp loop

helperPlus:
    incq %rbx
    addq $2, %r8                            # Move to next cell
    jmp checkLoop