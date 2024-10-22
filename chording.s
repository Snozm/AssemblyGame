.text
.global flagChording
.global digChording

digChording:
    #prologue
    pushq %rbp
    movq %rsp, %rbp

    BOUNDARY_TREE:
    movq $0, %r11                           # Initialize flag counter

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

    leaq mineArray, %r8
    addq %rbx, %r8                          # Store cursor address in %r8
    addq %rbx, %r8

    movq %r11, %rdx
    movq $0, %r11

    movzb (%r8), %rax
    subq $48, %rax

    cmpq %rdx, %rax
    jne end

OPEN_CELLS:
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
    leaq mineArray, %r10              # open if top cell exists
    cmpq %r10, %r8
    jl openBottom

    incq %rdi

    movq $8, %rax 
    andb (%r8), %al
    cmpq $8, %rax
    je openUpLeft

    movq $4, %rax 
    andb (%r8), %al
    cmpq $4, %rax
    je openUpLeft
    orb $4, (%r8)                           # Open cell above cursor
    incq %r11

    movzb -1(%r8), %rax
    cmpq $'0, %rax
    jne openUpLeft

    call zeroDigger

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
    movq $4, %rax 
    andb (%r8), %al
    addq $2, %r8
    cmpq $4, %rax
    je openUpRight

    subq $2, %r8
    orb $4, (%r8)                           # Open top left cell
    incq %r11
    addq $2, %r8
    movzb -3(%r8), %rax
    cmpq $'0, %rax
    jne openUpRight

    call zeroDigger

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

    movq $4, %rax 
    andb (%r8), %al
    cmpq $4, %rax
    je openBottom

    orb $4, (%r8)
    incq %r11

    movzb -1(%r8), %rax
    cmpq $'0, %rax
    jne openBottom

    call zeroDigger

openBottom:
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
    cmpq %rcx, %r9                          # open if bottom cell exists
    jge openLeft

    incq %rdi
    
    movq $8, %rax 
    andb (%r8), %al
    cmpq $8, %rax
    je openDownLeft

    movq $4, %rax 
    andb (%r8), %al
    cmpq $4, %rax
    je openDownLeft

    orb $4, (%r8)                           # Open cell below cursor
    incq %r11

    movzb -1(%r8), %rax
    cmpq $'0, %rax
    jne openDownLeft

    call zeroDigger

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
    movq $4, %rax 
    andb (%r8), %al
    addq $2, %r8
    cmpq $4, %rax
    je openDownRight
    
    subq $2, %r8
    orb $4, (%r8)                           # Open top left cell
    incq %r11
    addq $2, %r8

    movzb -3(%r8), %rax
    cmpq $'0, %rax
    jne openDownRight

    call zeroDigger

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

        movq $4, %rax 
        andb (%r8), %al
        cmpq $4, %rax
        je openLeft

        orb $4, (%r8)
        incq %r11

        movzb -1(%r8), %rax
        cmpq $'0, %rax
        jne openLeft

        call zeroDigger


openLeft:
    incq %rdi
    movq %rbx, %r9                          # Store cursor in r9
    
    leaq mineArray, %r8
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
    movq $4, %rax 
    andb (%r8), %al
    addq $2, %r8
    cmpq $4, %rax
    je openRight
    
    subq $2, %r8
    orb $4, (%r8)                           # Open top left cell
    incq %r11
    addq $2, %r8

    movzb -3(%r8), %rax
    cmpq $'0, %rax
    jne openRight

    call zeroDigger

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

    movq $4, %rax 
    andb (%r8), %al
    cmpq $4, %rax
    je end

    orb $4, (%r8)                           # Open cell right of cursor
    incq %r11

    movzb -1(%r8), %rax
    cmpq $'0, %rax
    jne end

    call zeroDigger
    

end:
    movq %r11, %rax

    #epilogue
    movq %rbp, %rsp
    popq %rbp
ret


zeroDigger:
    #prologue
    pushq %rbp
    movq %rsp, %rbp

    pushq %r8
    pushq %r9
    pushq %r11
    pushq %rsi
    pushq %rdi
    pushq %rcx

    call zeroChainer

    popq %rcx
    popq %rdi
    popq %rsi
    popq %r11
    popq %r9
    popq %r8

    #epilogue
    movq %rbp, %rsp
    popq %rbp
ret

flagChording:
    #prologue
    pushq %rbp
    movq %rsp, %rbp

    movq $0, %r11                           # Initialize closed cell counter

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
    jl checkClosedBottom

    incq %rdi

    movq $4, %rax                           # Check if cell above cursor is closed
    andb (%r8), %al
    cmpq $4, %rax
    je checkClosedUpLeft
    incq %r11


    checkClosedUpLeft:
    movq %r9, %rax
    movq $0, %rdx
    divq %rdi                               # Check if top cell is on left border
    cmpq $0, %rdx
    je checkClosedUpRight

    subq $2, %r8
    movq $4, %rax                           # Check if top left cell is closed
    andb (%r8), %al
    addq $2, %r8
    cmpq $4, %rax
    je checkClosedUpRight
    incq %r11

    checkClosedUpRight:

    movq %r9, %rax
    movq $0, %rdx
    divq %rdi                               # Check if top cell is on right border
    decq %rdi
    cmpq %rdi, %rdx
    je checkClosedBottom

    addq $2, %r8
    
    movq $4, %rax 
    andb (%r8), %al                        # Check if top right cell is closed
    cmpq $4, %rax
    je checkClosedBottom
    incq %r11

checkClosedBottom:
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
    jge checkClosedLeft

    incq %rdi

    movq $4, %rax 
    andb (%r8), %al
    cmpq $4, %rax                           # Check if cell below cursor is closed
    je checkClosedDownLeft
    incq %r11

    checkClosedDownLeft:

    movq %r9, %rax
    movq $0, %rdx
    divq %rdi                               # Check if bottom cell is on left border
    cmpq $0, %rdx
    je checkClosedDownRight

    subq $2, %r8
    movq $4, %rax 
    andb (%r8), %al
    addq $2, %r8                            # Check if bottom left cell is closed
    cmpq $4, %rax
    je checkClosedDownRight
    incq %r11
    

    checkClosedDownRight:

        movq %r9, %rax
        movq $0, %rdx
        divq %rdi                           # Check if bottom cell is on right border
        decq %rdi
        cmpq %rdi, %rdx
        je checkClosedLeft

        addq $2, %r8

        movq $4, %rax 
        andb (%r8), %al
        cmpq $4, %rax                       # Check if bottom right cell is closed
        je checkClosedLeft
        incq %r11

checkClosedLeft:
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
    je checkClosedRight

    subq $2, %r8
    movq $4, %rax 
    andb (%r8), %al
    addq $2, %r8                            # Check if cell left of cursor is closed
    cmpq $4, %rax
    je checkClosedRight
    incq %r11    

checkClosedRight:

    movq %r9, %rax
    movq $0, %rdx
    divq %rdi                               # Check if cell is on right border
    decq %rdi
    cmpq %rdi, %rdx
    je closedEnd

    addq $2, %r8
    movq $4, %rax 
    andb (%r8), %al                         # Check if cell right of cursor is closed
    cmpq $4, %rax
    je closedEnd
    incq %r11

closedEnd:

    leaq mineArray, %r8
    addq %rbx, %r8                          # Store cursor address in %r8
    addq %rbx, %r8
    
    
    movzb (%r8), %rax
    subq $48, %rax                          # Check if closed neighbours are the same number as cell
    cmpq %r11, %rax
    jne endFlag


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
    leaq mineArray, %r10              # flag if top cell exists
    cmpq %r10, %r8
    jl flagClosedBottom

    incq %rdi

    movq $4, %rax                           # flag if cell above cursor is closed
    andb (%r8), %al
    cmpq $4, %rax
    je flagClosedUpLeft
    orb $8, (%r8)                           # Flag cell above cursor


    flagClosedUpLeft:
    movq %r9, %rax
    movq $0, %rdx
    divq %rdi                               # flag if top cell is on left border
    cmpq $0, %rdx
    je flagClosedUpRight

    subq $2, %r8
    movq $4, %rax                           # flag if top left cell is closed
    andb (%r8), %al
    addq $2, %r8
    cmpq $4, %rax
    je flagClosedUpRight
    subq $2, %r8
    orb $8, (%r8)
    addq $2, %r8

    flagClosedUpRight:

    movq %r9, %rax
    movq $0, %rdx
    divq %rdi                               # flag if top cell is on right border
    decq %rdi
    cmpq %rdi, %rdx
    je flagClosedBottom

    addq $2, %r8
    
    movq $4, %rax 
    andb (%r8), %al                        # flag if top right cell is closed
    cmpq $4, %rax
    je flagClosedBottom
    orb $8, (%r8)                        

flagClosedBottom:
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
    cmpq %rcx, %r9                          # flag if bottom cell exists
    jge flagClosedLeft

    incq %rdi

    movq $4, %rax 
    andb (%r8), %al
    cmpq $4, %rax                           # flag if cell below cursor is closed
    je flagClosedDownLeft
    orb $8, (%r8)                           

    flagClosedDownLeft:

    movq %r9, %rax
    movq $0, %rdx
    divq %rdi                               # flag if bottom cell is on left border
    cmpq $0, %rdx
    je flagClosedDownRight

    subq $2, %r8
    movq $4, %rax 
    andb (%r8), %al
    addq $2, %r8                            # flag if bottom left cell is closed
    cmpq $4, %rax
    je flagClosedDownRight
    subq $2, %r8
    orb $8, (%r8)
    addq $2, %r8
    

    flagClosedDownRight:

        movq %r9, %rax
        movq $0, %rdx
        divq %rdi                           # flag if bottom cell is on right border
        decq %rdi
        cmpq %rdi, %rdx
        je flagClosedLeft

        addq $2, %r8

        movq $4, %rax 
        andb (%r8), %al
        cmpq $4, %rax                       # flag if bottom right cell is closed
        je flagClosedLeft
        orb $8, (%r8)

flagClosedLeft:
    incq %rdi
    movq %rbx, %r9                          # Store cursor in r9
    
    leaq mineArray, %r8
    addq %rbx, %r8                          # Store cursor address in %r8
    addq %rbx, %r8
    incq %r8

    movq %r9, %rax
    movq $0, %rdx
    divq %rdi                               # flag if cell is on left border
    cmpq $0, %rdx
    je flagClosedRight

    subq $2, %r8
    movq $4, %rax 
    andb (%r8), %al
    addq $2, %r8                            # flag if cell left of cursor is closed
    cmpq $4, %rax
    je flagClosedRight
    subq $2, %r8
    orb $8, (%r8)
    addq $2, %r8   

flagClosedRight:

    movq %r9, %rax
    movq $0, %rdx
    divq %rdi                               # flag if cell is on right border
    decq %rdi
    cmpq %rdi, %rdx
    je endFlag

    addq $2, %r8
    movq $4, %rax 
    andb (%r8), %al                         # flag if cell right of cursor is closed
    cmpq $4, %rax
    je endFlag
    orb $8, (%r8)
    


endFlag:
    #epilogue
    movq %rbp, %rsp
    popq %rbp
ret