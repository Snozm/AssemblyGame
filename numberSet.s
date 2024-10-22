.text
.global calcNumbers

calcNumbers:

pushq %rbp
movq %rsp, %rbp
pushq $0
pushq %rbx

movq $0, %rbx

BOUNDARY_TREE:
    movq $48, %r11                           #init mine counter

    leaq width, %rdi
    movzb (%rdi), %rdi                      # Store width value into rdi

    leaq height, %rsi
    movzb (%rsi), %rsi                      # Store height value into rsi

    movq $0, %rdx
    movq %rdi, %rax
    mulq %rsi                               # Store cell count in rcx
    movq %rax, %rcx 

    movq %rbx, %r9                          # Store cursor in r9
    
    leaq mineArray, %r8
    addq %rbx, %r8
    addq %rbx, %r8                          # Store cursor address in %r8

    incq %r8

    subq %rdi, %r8
    subq %rdi, %r8                          # Move to top cell
    subq %rdi, %r9
    
    

    decq %rdi
    leaq mineArray, %r10              # Check if top cell exists
    cmpq %r10, %r8
    jl checkBottom

    incq %rdi

    movq $2, %rax                           # Open cell above cursor
    andb (%r8), %al
    cmpq $2, %rax
    jne checkUpLeft
    incq %r11


    checkUpLeft:
    movq %r9, %rax
    movq $0, %rdx
    divq %rdi                               # Check if top cell is on left border
    cmpq $0, %rdx
    je checkUpRight

    subq $2, %r8
    movq $2, %rax                           # Open cell above cursor
    andb (%r8), %al
    addq $2, %r8
    cmpq $2, %rax
    jne checkUpRight
    incq %r11

    checkUpRight:

    movq %r9, %rax
    movq $0, %rdx
    divq %rdi                               # Check if top cell is on right border
    decq %rdi
    cmpq %rdi, %rdx
    je checkBottom

    addq $2, %r8
    
    movq $2, %rax 
    andb (%r8), %al
    cmpq $2, %rax
    jne checkBottom
    incq %r11

checkBottom:
    incq %rdi

    movq %rbx, %r9                          # Store cursor in r9
    
    leaq mineArray, %r8
    addq %rbx, %r8
    addq %rbx, %r8                          # Store cursor address in %r8
    incq %r8

    addq %rdi, %r8
    addq %rdi, %r8                          # Move to bottom cell
    addq %rdi, %r9

    decq %rdi
    cmpq %rcx, %r9                          # Check if bottom cell exists
    jge checkLeft

    incq %rdi

    movq $2, %rax 
    andb (%r8), %al
    cmpq $2, %rax
    jne checkDownLeft
    incq %r11

    checkDownLeft:

    movq %r9, %rax
    movq $0, %rdx
    divq %rdi                               # Check if bottom cell is on left border
    cmpq $0, %rdx
    je checkDownRight

    subq $2, %r8
    movq $2, %rax 
    andb (%r8), %al
    addq $2, %r8
    cmpq $2, %rax
    jne checkDownRight
    incq %r11
    

    checkDownRight:

        movq %r9, %rax
        movq $0, %rdx
        divq %rdi                           # Check if bottom cell is on right border
        decq %rdi
        cmpq %rdi, %rdx
        je checkLeft

        addq $2, %r8

        movq $2, %rax 
        andb (%r8), %al
        cmpq $2, %rax
        jne checkLeft
        incq %r11

checkLeft:
    incq %rdi
    movq %rbx, %r9                          # Store cursor in r9
    
    leaq mineArray, %r8
    addq %rbx, %r8                          # Store cursor address in %r8
    addq %rbx, %r8
    incq %r8

    movq %r9, %rax
    movq $0, %rdx
    divq %rdi                               # Check if cell is on left border
    cmpq $0, %rdx
    je checkRight

    subq $2, %r8
    movq $2, %rax 
    andb (%r8), %al
    addq $2, %r8
    cmpq $2, %rax
    jne checkRight
    incq %r11    

checkRight:

    movq %r9, %rax
    movq $0, %rdx
    divq %rdi                               # Check if cell is on right border
    decq %rdi
    cmpq %rdi, %rdx
    je BOUNDARY_TREE_END

    addq $2, %r8
    movq $2, %rax 
    andb (%r8), %al
    cmpq $2, %rax
    jne BOUNDARY_TREE_END
    incq %r11

BOUNDARY_TREE_END:
    leaq mineArray, %r8
    addq %rbx, %r8                          # Store cursor address in %r8
    addq %rbx, %r8

    incq %rbx

    incq %r8
    movq $2, %rax
    andb (%r8), %al
    decq %r8
    cmpq $2, %rax
    je BOUNDARY_TREE

    movq %r11, %rax
    movb %al, (%r8)

    cmpq %rcx, %rbx
    jl BOUNDARY_TREE

popq %rbx
movq %rbp, %rsp
popq %rbp
ret