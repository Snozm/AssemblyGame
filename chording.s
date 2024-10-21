.text

.global flagChording
.global digChording

digChording:
    #prologue
    pushq %rbp
    movq %rsp, %rbp

    BOUNDARY_TREE:
    movq $0, %r11                           # Initialize flag counter

    leaq width(%rip), %rdi
    movzb (%rdi), %rdi                      # Store width value into rdi

    leaq height(%rip), %rsi
    movzb (%rsi), %rsi                      # Store height value into rsi

    movq $0, %rdx
    movq %rdi, %rax
    mulq %rsi                               # Store cell count in rcx
    movq %rax, %rcx 

    movq %rbx, %r9                          # Store cursor in r9
    
    leaq mineArray(%rip), %r8
    addq %rbx, %r8
    addq %rbx, %r8                          # Store cursor address in %r8

    incq %r8


    subq %rdi, %r8
    subq %rdi, %r8                          # Move to top cell
    subq %rdi, %r9
    
    

    decq %rdi
    leaq mineArray(%rip), %r10              # Check if top cell exists
    cmpq %r10, %r8
    jl checkBottom

    incq %rdi

    movq $8, %rax                           # Open cell above cursor
    andb (%r8), %al
    cmpq $8, %rax
    jne checkUpLeft
    incq %r11


    checkUpLeft:
    movq %r9, %rax
    movq $0, %rdx
    divq %rdi                               # Check if top cell is on left border
    cmpq $0, %rdx
    je checkUpRight

    subq $2, %r8
    movq $8, %rax                           # Open cell above cursor
    andb (%r8), %al
    addq $2, %r8
    cmpq $8, %rax
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
    
    movq $8, %rax 
    andb (%r8), %al
    cmpq $8, %rax
    jne checkBottom
    incq %r11

checkBottom:
    incq %rdi

    movq %rbx, %r9                          # Store cursor in r9
    
    leaq mineArray(%rip), %r8
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

    movq $8, %rax 
    andb (%r8), %al
    cmpq $8, %rax
    jne checkDownLeft
    incq %r11

    checkDownLeft:

    movq %r9, %rax
    movq $0, %rdx
    divq %rdi                               # Check if bottom cell is on left border
    cmpq $0, %rdx
    je checkDownRight

    subq $2, %r8
    movq $8, %rax 
    andb (%r8), %al
    addq $2, %r8
    cmpq $8, %rax
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

        movq $8, %rax 
        andb (%r8), %al
        cmpq $8, %rax
        jne checkLeft
        incq %r11

checkLeft:
    incq %rdi
    movq %rbx, %r9                          # Store cursor in r9
    
    leaq mineArray(%rip), %r8
    addq %rbx, %r8                          # Store cursor address in %r8
    addq %rbx, %r8
    incq %r8

    movq %r9, %rax
    movq $0, %rdx
    divq %rdi                               # Check if cell is on left border
    cmpq $0, %rdx
    je checkRight

    subq $2, %r8
    movq $8, %rax 
    andb (%r8), %al
    addq $2, %r8
    cmpq $8, %rax
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
    movq $8, %rax 
    andb (%r8), %al
    cmpq $8, %rax
    jne BOUNDARY_TREE_END
    incq %r11

BOUNDARY_TREE_END:

    leaq mineArray(%rip), %r8
    addq %rbx, %r8                          # Store cursor address in %r8
    addq %rbx, %r8

    movzb (%r8), %rax
    subq $48, %rax
    cmpq %r11, %rax
    jne end



    leaq width(%rip), %rdi
    movzb (%rdi), %rdi                      # Store width value into rdi

    leaq height(%rip), %rsi
    movzb (%rsi), %rsi                      # Store height value into rsi

    movq $0, %rdx
    movq %rdi, %rax
    mulq %rsi                               # Store cell count in rcx
    movq %rax, %rcx 

    movq %rbx, %r9                          # Store cursor in r9
    
    leaq mineArray(%rip), %r8
    addq %rbx, %r8
    addq %rbx, %r8                          # Store cursor address in %r8

    incq %r8

    subq %rdi, %r8
    subq %rdi, %r8                          # Move to top cell
    subq %rdi, %r9

    decq %rdi
    leaq mineArray(%rip), %r10              # open if top cell exists
    cmpq %r10, %r8
    jl openBottom

    incq %rdi

    movq $8, %rax 
    andb (%r8), %al
    cmpq $8, %rax
    je openUpLeft
    orb $4, (%r8)                           # Open cell above cursor

    openUpLeft:
    movq %r9, %rax
    movq $0, %rdx
    divq %rdi                               # open if top cell is on left border
    cmpq $0, %rdx
    je openUpRight

    subq $2, %r8
    movq $8, %rax 
    andb (%r8), %al
    addq $2, %r8
    cmpq $8, %rax
    je openUpRight

    subq $2, %r8
    orb $4, (%r8)                           # Open top left cell
    addq $2, %r8

    openUpRight:


    movq %r9, %rax
    movq $0, %rdx
    divq %rdi                               # open if top cell is on right border
    decq %rdi
    cmpq %rdi, %rdx
    je openBottom

    addq $2, %r8
    movq $8, %rax 
    andb (%r8), %al
    cmpq $8, %rax
    je openBottom

    orb $4, (%r8)

openBottom:
    incq %rdi

    movq %rbx, %r9                          # Store cursor in r9
    
    leaq mineArray(%rip), %r8
    addq %rbx, %r8
    addq %rbx, %r8                          # Store cursor address in %r8
    incq %r8

    addq %rdi, %r8
    addq %rdi, %r8                          # Move to bottom cell
    addq %rdi, %r9

    decq %rdi
    cmpq %rcx, %r9                          # open if bottom cell exists
    jge openLeft

    incq %rdi
    
    movq $8, %rax 
    andb (%r8), %al
    cmpq $8, %rax
    je openDownLeft

    orb $4, (%r8)                           # Open cell below cursor

    openDownLeft:
    movq %r9, %rax
    movq $0, %rdx
    divq %rdi                               # open if bottom cell is on left border
    cmpq $0, %rdx
    je openDownRight

    subq $2, %r8
    movq $8, %rax 
    andb (%r8), %al
    addq $2, %r8
    cmpq $8, %rax
    je openDownRight
    
    subq $2, %r8
    orb $4, (%r8)                           # Open top left cell
    addq $2, %r8

    openDownRight:

        movq %r9, %rax
        movq $0, %rdx
        divq %rdi                           # open if bottom cell is on right border
        decq %rdi
        cmpq %rdi, %rdx
        je openLeft

        addq $2, %r8
        movq $8, %rax 
        andb (%r8), %al
        cmpq $8, %rax
        je openLeft

        orb $4, (%r8)


openLeft:
    incq %rdi
    movq %rbx, %r9                          # Store cursor in r9
    
    leaq mineArray(%rip), %r8
    addq %rbx, %r8                          # Store cursor address in %r8
    addq %rbx, %r8
    incq %r8

    movq %r9, %rax
    movq $0, %rdx
    divq %rdi                               # open if cell is on left border
    cmpq $0, %rdx
    je openRight

    subq $2, %r8
    movq $8, %rax 
    andb (%r8), %al
    addq $2, %r8
    cmpq $8, %rax
    je openRight
    
    subq $2, %r8
    orb $4, (%r8)                           # Open top left cell
    addq $2, %r8

openRight:

    movq %r9, %rax
    movq $0, %rdx
    divq %rdi                               # open if cell is on right border
    decq %rdi
    cmpq %rdi, %rdx
    je end

    addq $2, %r8
    movq $8, %rax 
    andb (%r8), %al
    cmpq $8, %rax
    je end

    orb $4, (%r8)                           # Open cell right of cursor



end:
    #epilogue
    movq %rbp, %rsp
    popq %rbp
ret

flagChording:
    #prologue
    pushq %rbp
    movq %rsp, %rbp

    #epilogue
    movq %rbp, %rsp
    popq %rbp
ret