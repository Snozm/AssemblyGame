.text
cellTop:
    .ascii "+---"
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

    pushq %r15                              # Save registers
    pushq %r14
    pushq %r13
    pushq %r12
    pushq %rbx
    pushq $0                                # Push 0 for stage counter

    leaq mineArray(%rip), %rbx              # Load address of mineArray in rbx
    movq $0, %r15                           # Initialize column counter
    movq $0, %r14                           # Initialize row counter

    leaq height(%rip), %r13                 # Load height address in r13
    movzb (%r13), %r13                      # Store height in r13

    leaq width(%rip), %r12                  # Load width address in r12
    movzb (%r12), %r12                      # Store width in r12

columnIterator:
    incq %r15                               # Increment column counter

    rowIterator:
        cmpq $0, (%rsp)                     # Check if stage counter is 0
        jne middlePart

        call chooseBackground

        mov $1, %rax                        # Syscall number for write
        mov $1, %rdi                        # File descriptor 1 (stdout)
        lea whiteText(%rip), %rsi           # Address of white text
        mov $19, %rdx                       # Length of message
        syscall
        
        mov $1, %rax                        # Syscall number for write
        mov $1, %rdi                        # File descriptor 1 (stdout)
        lea cellTop(%rip), %rsi             # Address of top border
        mov $4, %rdx                        # Length of message
        syscall

        jmp rowCheck                        # Check if row is complete

        middlePart:
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
        
        mov $1, %rax                        # Syscall number for write
        mov $1, %rdi                        # File descriptor 1 (stdout)
        lea cellPadding(%rip), %rsi         # Address of empty space
        mov $1, %rdx                        # Length of message
        syscall

        mov $1, %rax                        # Syscall number for write
        mov $1, %rdi                        # File descriptor 1 (stdout)
        mov %rbx, %rsi                      # Address of character
        mov $1, %rdx                        # Length of message
        syscall

        mov $1, %rax                        # Syscall number for write
        mov $1, %rdi                        # File descriptor 1 (stdout)
        lea cellPadding(%rip), %rsi         # Address of empty space
        mov $1, %rdx                        # Length of message
        syscall

        rowCheck:
        incq %r14                           # Increment row counter
        cmpq %r12, %r14                     # Compare row counter with width
        je rowEnd

        addq $2, %rbx                       # Move to next cell in mineArray

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

    movq $0, %r14                           # Reset row counter

    call newLine

    notq (%rsp)                             # Change stage counter   
    cmpq $0, (%rsp)                         # Check if stage counter was not 0 
    jne rowIteratorTemp

    cmpq %r13, %r15                         # Compare column counter with height
jne columnIterator

    subq %r12, %rbx                         # Move to start of bottom row in mineArray
    subq %r12, %rbx

bottomLoop:
    call chooseBackground
    
    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea cellTop(%rip), %rsi                 # Address of bottom border
    mov $4, %rdx                            # Length of message
    syscall

    incq %r14                               # Increment row counter
    cmpq %r12, %r14                         # Compare row counter with width
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

    popq %rbx                               # Restore registers
    popq %r12
    popq %r13
    popq %r14
    popq %r15

    #epilogue
    movq %rbp, %rsp
    popq %rbp

ret

rowIteratorTemp:
    subq %r12, %rbx                         # Move to start of row in mineArray
    subq %r12, %rbx
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