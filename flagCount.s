.text
.global countFlags

countFlags:
    #prologue
    pushq %rbp
    movq %rsp, %rbp

    pushq %rbx
    pushq %rbx

    movq $0, %rbx
    movq $0, %r11

    leaq width, %rdi
    movzb (%rdi), %rdi                      # Store width value into rdi

    leaq height, %rsi
    movzb (%rsi), %rsi                      # Store height value into rsi

    movq $0, %rdx
    movq %rdi, %rax
    mulq %rsi                               # Store cell count in rcx
    movq %rax, %rcx

    leaq mineArray, %r8

loop:
    cmpq %rcx, %rbx
    jge done

    incq %r8
    movq $8, %rax
    andb (%r8), %al                          # Check if mine cell is open
    decq %r8
    cmpq $8, %rax
    jne helper

    incq %r11
    jne helper

done:
    leaq mines, %rax
    movq $0, %rdi
    movw (%rax), %di                      # Store remaining mine count in rax
    subq %r11, %rdi
    movq %rdi, %rax

    popq %rbx

    #epilogue
    movq %rbp, %rsp
    popq %rbp
ret

helper:
    incq %rbx
    addq $2, %r8                            # Move to next cell
jmp loop