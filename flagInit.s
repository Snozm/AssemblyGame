.text

 formatString:
    .asciz "%lu\n"
.global borderInit
.global mineInit


borderInit:

pushq %rbp
movq %rsp, %rbp

# Initialize border flags
    leaq mineArray(%rip), %rdi              # Load address of mineArray in rdi

    # Initialize cursor flag
        incq %rdi                           # Move to first cell flags in mineArray
        orb $1, (%rdi)                      # Set cursor flag the cell to 1
        decq %rdi                           # Move back to first cell in mineArray
    
    movq $0, %r8                            # Initialize column counter
    movq $0, %r9                            # Initialize row counter

    leaq height(%rip), %rcx                 # Load height address in rcx
    movzb (%rcx), %rcx                      # Store height in rcx

    leaq width(%rip), %rax                  # Load width address in rax
    movzb (%rax), %rax                      # Store width in rax

columnIterator:
    incq %r8                                # Increment column counter

    rowIterator:
        movb $32, (%rdi)                    # Set cell character to space
        cmpq %rcx, %r8                      # Compare column counter with height
        jne notBottom
        incq %rdi
        orb $16, (%rdi)                     # Set bottom border flag the cell to 1
        decq %rdi

        notBottom:
        incq %r9                            # Increment row counter
        cmpq %rax, %r9                      # Compare row counter with width
        je rowEnd

        addq $2, %rdi                       # Move to next cell in mineArray       
    jmp rowIterator 

    rowEnd:
    incq %rdi
    orb $32, (%rdi)                         # Set right border flag the cell to 1
    incq %rdi                               # Move to next cell in mineArray

    movq $0, %r9                            # Reset row counter

    cmpq %rcx, %r8                          # Compare column counter with height
jne columnIterator 

movq %rbp, %rsp
popq %rbp
ret

mineInit:
    pushq %rbp
    movq %rsp, %rbp

    pushq $0 #to allign stack
    pushq %r12 #save r12 to free it up


    leaq width(%rip), %rax
    movzb (%rax), %rax #load width value into rax

    leaq height(%rip), %rcx
    movzb (%rcx), %rcx #load height value into rax

    movq $0, %rdx
    mulq %rcx #multiply to get total cell count
    movq %rax, %rcx #mov count into rcx


    movq $0, %rax #set rax to all 0
    notq %rax #set rax to all 1
    movq $0, %rdx # make rdx 0 for division

    divq %rcx # divide max 64 bit number by cell number
    movq %rax, %r12 # divisor number to r12

BOUNDARY_TREE:
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
    orb $4, (%r8)                           # Open cursor cell

    subq %rdi, %r8
    subq %rdi, %r8                          # Move to top cell
    subq %rdi, %r9

    decq %rdi
    leaq mineArray(%rip), %r10              # Check if top cell exists
    cmpq %r10, %r8
    jl checkBottom

    incq %rdi
    orb $4, (%r8)                           # Open cell above cursor

    movq %r9, %rax
    movq $0, %rdx
    divq %rdi                               # Check if top cell is on left border
    cmpq $0, %rdx
    je checkUpRight

    subq $2, %r8
    orb $4, (%r8)                           # Open top left cell
    addq $2, %r8

    checkUpRight:

    movq %r9, %rax
    movq $0, %rdx
    divq %rdi                               # Check if top cell is on right border
    decq %rdi
    cmpq %rdi, %rdx
    je checkBottom

    addq $2, %r8
    orb $4, (%r8)                           # Open top right cell

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
    orb $4, (%r8)                           # Open cell below cursor

    movq %r9, %rax
    movq $0, %rdx
    divq %rdi                               # Check if bottom cell is on left border
    cmpq $0, %rdx
    je checkDownRight

    subq $2, %r8
    orb $4, (%r8)                           # Open bottom left cell
    addq $2, %r8

    checkDownRight:

        movq %r9, %rax
        movq $0, %rdx
        divq %rdi                           # Check if bottom cell is on right border
        decq %rdi
        cmpq %rdi, %rdx
        je checkLeft

        addq $2, %r8
        orb $4, (%r8)                       # Open bottom right cell


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
    orb $4, (%r8)                           # Open cell left of cursor
    addq $2, %r8

checkRight:

    movq %r9, %rax
    movq $0, %rdx
    divq %rdi                               # Check if cell is on right border
    decq %rdi
    cmpq %rdi, %rdx
    je done

    addq $2, %r8
    orb $4, (%r8)                           # Open cell right of cursor
BOUNDARY_TREE_END:

done:
    leaq mines(%rip), %rcx
    movzw (%rcx), %rcx

    loop:

        movq $0, %rdx # for division
        rdrand %rax #random 64 bit number into rax
        divq %r12 #divide by divisor

        #random cell selection is in rax
        
        leaq mineArray(%rip), %rdx

        addq %rax, %rdx
        addq %rax, %rdx
        #the random cell pointed to by %rdx

        incq %rdx
        movb $6, %al
        andb (%rdx), %al
        cmpb $0, %al
        jg loop

        decq %rcx
        orb $2, (%rdx)
        decq %rdx
        movb $'#, (%rdx)

        cmpq $0, %rcx
        jg loop
        

    
    popq %r12 #put r12 back
    movq %rbp, %rsp
    popq %rbp
ret