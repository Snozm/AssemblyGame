.text
cellTop:
    .ascii "---"
cellCorner:
    .ascii "+"
cellPadding:
    .ascii " "
cellWall:
    .ascii "|"
newline:
    .ascii "\n"
whiteText:
    .ascii "\033[38;2;255;255;255m"
lightGrayBackground:
    .ascii "\033[48;2;170;170;170m"
darkGrayBackground:
    .ascii "\033[48;2;100;100;100m"
reset:
    .ascii "\033[0m"

.global draw

draw:
    #prologue
    pushq %rbp
    movq %rsp, %rbp

    call clear

    pushq %rbx                              # Save registers
    pushq $0                                # Push 0 for stage counter

    leaq mineArray(%rip), %rbx              # Load address of mineArray in rbx

rowIterator:
    call chooseBackground

    cmpq $0, (%rsp)                         # Check if stage counter is 0
    jne middlePart

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea whiteText(%rip), %rsi               # Address of white text
    mov $19, %rdx                           # Length of message
    syscall
    
    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea cellCorner(%rip), %rsi              # Address of bottom border
    mov $1, %rdx                            # Length of message
    syscall

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea cellTop(%rip), %rsi                 # Address of top border
    mov $3, %rdx                            # Length of message
    syscall

    jmp rowCheck                            # Check if row is complete

    middlePart:
    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea whiteText(%rip), %rsi               # Address of white text
    mov $19, %rdx                           # Length of message
    syscall

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea cellWall(%rip), %rsi                # Address of cell wall
    mov $1, %rdx                            # Length of message
    syscall
    
    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea cellPadding(%rip), %rsi             # Address of empty space
    mov $1, %rdx                            # Length of message
    syscall

    incq %rbx                               # Move to flags of cell
    movb (%rbx), %al                        # Load flags of cell
    decq %rbx                               # Move back to cell

    andb $4, %al                       
    cmpb $4, %al                            # Check if cell is opened
    je openedCell

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea cellPadding(%rip), %rsi             # Address of padding
    mov $1, %rdx                            # Length of message
    syscall

    jmp finishCell

    openedCell:
    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    mov %rbx, %rsi                          # Address of character
    mov $1, %rdx                            # Length of message
    syscall

    finishCell:

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea cellPadding(%rip), %rsi             # Address of empty space
    mov $1, %rdx                            # Length of message
    syscall

    rowCheck:
    incq %rbx                               # Move to cell flags
    movb $32, %al                           # Initialize right border checker
    andb (%rbx), %al                        # Check if right border is set
    decq %rbx                               # Move back to cell
    cmpb $32, %al                           # Compare right border flag with 1
    je rowEnd

    addq $2, %rbx                           # Move to next cell in mineArray

    jmp rowIterator 

    rowEnd:
    cmpq $0, (%rsp)                         # Check if stage counter is 0
    jne pipePart

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea cellCorner(%rip), %rsi              # Address of top corner
    mov $1, %rdx                            # Length of message
    syscall

    jmp finishRow

    pipePart:
        call chooseBackground

        mov $1, %rax                        # Syscall number for write
        mov $1, %rdi                        # File descriptor 1 (stdout)
        lea whiteText(%rip), %rsi           # Address of white text
        mov $19, %rdx                       # Length of message
        syscall
        
        mov $1, %rax                        # Syscall number for write
        mov $1, %rdi                        # File descriptor 1 (stdout)
        lea cellWall(%rip), %rsi            # Address of cell wall
        mov $1, %rdx                        # Length of message
        syscall

    finishRow:
    addq $2, %rbx                           # Move to next cell in mineArray

    call newLine

    notq (%rsp)                             # Change stage counter   
    cmpq $0, (%rsp)                         # Check if stage counter was not 0 
    jne rowIteratorTemp

    decq %rbx                               # Move to previous cell flags
    movb $16, %al                           # Initialize bottom border checker
    andb (%rbx), %al                        # Check if bottom border is 1
    incq %rbx                               # Move back to cell
    cmpb $16, %al                           # Compare bottom border flag with 1
jne rowIterator

    leaq width(%rip), %rax                  # Load width address in rax
    movzb (%rax), %rax                      # Store width in rax

    subq %rax, %rbx                         # Move to start of bottom row in mineArray
    subq %rax, %rbx

bottomLoop:
    call chooseBackground
    
    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea cellCorner(%rip), %rsi              # Address of bottom corner
    mov $1, %rdx                            # Length of message
    syscall

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea cellTop(%rip), %rsi                 # Address of bottom border
    mov $3, %rdx                            # Length of message
    syscall

    incq %rbx                               # Move to cell flags
    movb $32, %al                           # Initialize right border checker
    andb (%rbx), %al                        # Check if right border is set
    decq %rbx                               # Move back to cell
    cmpb $32, %al                           # Compare right border flag with 1
    je bottomEnd

    addq $2, %rbx                           # Move to next cell in mineArray
    jmp bottomLoop

    bottomEnd:
    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea cellCorner(%rip), %rsi              # Address of bottom corner
    mov $1, %rdx                            # Length of message
    syscall

    call newLine

    subq $8, %rsp                           # Remove stage counter from stack
    popq %rbx                               # Restore registers

    #epilogue
    movq %rbp, %rsp
    popq %rbp

ret

rowIteratorTemp:
    leaq width(%rip), %rax                  # Load width address in rax
    movzb (%rax), %rax                      # Store width in rax

    subq %rax, %rbx                         # Move to start of row in mineArray
    subq %rax, %rbx
jmp rowIterator

chooseBackground:
    incq %rbx
    movb (%rbx), %al                        # Store current cell flags in temp storage
    decq %rbx
    
    andb $4, %al                            # Isolate opened flag
    cmpb $4, %al                            # Check if cell is opened
    je opened

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea lightGrayBackground(%rip), %rsi     # Address of top border
    mov $19, %rdx                           # Length of message
    syscall

ret

opened:
    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea darkGrayBackground(%rip), %rsi      # Address of top border
    mov $19, %rdx                           # Length of message
    syscall

ret

newLine:
    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea newline(%rip), %rsi                 # Address of newline
    mov $1, %rdx                            # Length of message
    syscall

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea reset(%rip), %rsi                   # Address of top border
    mov $4, %rdx                            # Length of message
    syscall

ret