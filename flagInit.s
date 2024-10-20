.text
.global borderInit


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
        #movb $32, (%rdi)                    # Set cell character to space
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