.text
flagSymbol:
    .ascii "P"
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
    .ascii "\033[38;2;255;255;255m\033[25m"
yellowText:
    .ascii "\033[38;2;255;255;0m\033[1m\033[5m"
blueText:
    .ascii "\033[38;2;0;0;255m\033[25m"
greenText:
    .ascii "\033[38;2;0;255;0m\033[25m"
redText:
    .ascii "\033[38;2;255;0;0m\033[25m"
purpleText:
    .ascii "\033[38;2;255;0;255m\033[25m"
pinkText:
    .ascii "\033[38;2;255;130;130m\033[25m"
cyanText:
    .ascii "\033[38;2;0;255;255m\033[25m"
brownText:
    .ascii "\033[38;2;150;55;20m\033[25m"
lightGrayBackground:
    .ascii "\033[48;2;170;170;170m"
darkGrayBackground:
    .ascii "\033[48;2;100;100;100m"
orangeBackground:
    .ascii "\033[48;2;255;140;0m"
reset:
    .ascii "\033[0m"

.global draw

draw:
    #prologue
    pushq %rbp
    movq %rsp, %rbp

    call clear

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea whiteText(%rip), %rsi               # Address of white text
    mov $24, %rdx                           # Length of message
    syscall

    pushq %rbx                              # Save registers
    pushq $0                                # Push 0 for stage counter

    leaq mineArray(%rip), %rbx              # Load address of mineArray in rbx

rowIterator:
    cmpq $0, (%rsp)                         # Check if stage counter is 0
    jne middlePart

    call cursorTopLogic

    jmp rowCheck                            # Check if row is complete

    middlePart:
    call chooseBackground

    incq %rbx                               # Move to flags of cell
    movzb (%rbx), %rax                      # Load flags of cell
    decq %rbx                               # Move back to cell

    andb $1, %al                       
    cmpb $1, %al                            # Check if cell has cursor
    jne notCursorMiddle

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea yellowText(%rip), %rsi              # Address of yellow text
    mov $25, %rdx                           # Length of message
    syscall

    notCursorMiddle:
    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea cellWall(%rip), %rsi                # Address of cell wall
    mov $1, %rdx                            # Length of message
    syscall

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea whiteText(%rip), %rsi               # Address of white text
    mov $24, %rdx                           # Length of message
    syscall
    
    incq %rbx                               # Move to flags of cell
    movb (%rbx), %al                        # Load flags of cell
    decq %rbx                               # Move back to cell

    andb $4, %al                       
    cmpb $4, %al                            # Check if cell is opened
    je openedCell

    incq %rbx                               # Move to flags of cell
    movb (%rbx), %al                        # Load flags of cell
    decq %rbx                               # Move back to cell

    andb $8, %al                       
    cmpb $8, %al                            # Check if cell is flagged
    je flaggedCell

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea cellPadding(%rip), %rsi             # Address of empty space
    mov $1, %rdx                            # Length of message
    syscall

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea cellPadding(%rip), %rsi             # Address of padding
    mov $1, %rdx                            # Length of message
    syscall

    jmp finishCell

    flaggedCell:
    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea redText(%rip), %rsi                 # Address of red text
    mov $20, %rdx                           # Length of message
    syscall

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea orangeBackground(%rip), %rsi        # Address of orange background
    mov $17, %rdx                           # Length of message
    syscall

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea cellPadding(%rip), %rsi             # Address of empty space
    mov $1, %rdx                            # Length of message
    syscall

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea flagSymbol(%rip), %rsi              # Address of flag
    mov $1, %rdx                            # Length of message
    syscall

    incq %rbx                           # Move to flags of cell
    movzb (%rbx), %rax                  # Load flags of cell
    decq %rbx                           # Move back to cell

    andb $1, %al                       
    cmpb $1, %al                        # Check if cell has cursor
    je flaggedCursor

    mov $1, %rax                        # Syscall number for write
    mov $1, %rdi                        # File descriptor 1 (stdout)
    lea whiteText(%rip), %rsi           # Address of white text
    mov $24, %rdx                       # Length of message
    syscall

    jmp finishCell

    flaggedCursor:
    mov $1, %rax                        # Syscall number for write
    mov $1, %rdi                        # File descriptor 1 (stdout)
    lea yellowText(%rip), %rsi          # Address of yellow text
    mov $25, %rdx                       # Length of message
    syscall

    jmp finishCell


    openedCell:
    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea cellPadding(%rip), %rsi             # Address of empty space
    mov $1, %rdx                            # Length of message
    syscall
    
    movzb (%rbx), %rax                      # Load cell value
    cmpq $'0, %rax                          # Check if cell is empty
    jne check1

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea cellPadding(%rip), %rsi             # Address of empty space
    mov $1, %rdx                            # Length of message
    syscall

    jmp finishCell

    check1:
    movzb (%rbx), %rax                      # Load cell value
    cmpq $'1, %rax                        # Check if cell has 1 mine
    jne check2

    mov $1, %rax                        # Syscall number for write
    mov $1, %rdi                        # File descriptor 1 (stdout)
    lea blueText(%rip), %rsi            # Address of blue text
    mov $20, %rdx                       # Length of message
    syscall

    jmp finishNumber

    check2:
    movzb (%rbx), %rax                      # Load cell value
    cmpq $'2, %rax                        # Check if cell has 2 mines
    jne check3

    mov $1, %rax                        # Syscall number for write
    mov $1, %rdi                        # File descriptor 1 (stdout)
    lea greenText(%rip), %rsi           # Address of green text
    mov $20, %rdx                       # Length of message
    syscall

    jmp finishNumber

    check3:
    movzb (%rbx), %rax                      # Load cell value
    cmpq $'3, %rax                        # Check if cell has 3 mines
    jne check4

    mov $1, %rax                        # Syscall number for write
    mov $1, %rdi                        # File descriptor 1 (stdout)
    lea redText(%rip), %rsi             # Address of red text
    mov $20, %rdx                       # Length of message
    syscall

    jmp finishNumber

    check4:
    movzb (%rbx), %rax                      # Load cell value
    cmpq $'4, %rax                        # Check if cell has 4 mines
    jne check5

    mov $1, %rax                        # Syscall number for write
    mov $1, %rdi                        # File descriptor 1 (stdout)
    lea purpleText(%rip), %rsi          # Address of purple text
    mov $22, %rdx                       # Length of message
    syscall

    jmp finishNumber

    check5:
    movzb (%rbx), %rax                      # Load cell value
    cmpq $'5, %rax                        # Check if cell has 5 mines
    jne check6

    mov $1, %rax                        # Syscall number for write
    mov $1, %rdi                        # File descriptor 1 (stdout)
    lea pinkText(%rip), %rsi            # Address of pink text
    mov $24, %rdx                       # Length of message
    syscall

    jmp finishNumber

    check6:
    movzb (%rbx), %rax                      # Load cell value
    cmpq $'6, %rax                        # Check if cell has 6 mines
    jne check7

    mov $1, %rax                        # Syscall number for write
    mov $1, %rdi                        # File descriptor 1 (stdout)
    lea cyanText(%rip), %rsi          # Address of cyan text
    mov $22, %rdx                       # Length of message
    syscall

    jmp finishNumber

    check7:
    movzb (%rbx), %rax                      # Load cell value
    cmpq $'7, %rax                        # Check if cell has 7 mines
    jne check8

    mov $1, %rax                        # Syscall number for write
    mov $1, %rdi                        # File descriptor 1 (stdout)
    lea whiteText(%rip), %rsi           # Address of white text
    mov $24, %rdx                       # Length of message
    syscall

    jmp finishNumber

    check8:
    movzb (%rbx), %rax                      # Load cell value
    cmpq $'8, %rax                        # Check if cell has 8 mines
    jne finishNumber

    mov $1, %rax                        # Syscall number for write
    mov $1, %rdi                        # File descriptor 1 (stdout)
    lea brownText(%rip), %rsi           # Address of brown text
    mov $22, %rdx                       # Length of message
    syscall

    finishNumber:
    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    mov %rbx, %rsi                          # Address of character
    mov $1, %rdx                            # Length of message
    syscall

    incq %rbx                           # Move to flags of cell
    movzb (%rbx), %rax                  # Load flags of cell
    decq %rbx                           # Move back to cell

    andb $1, %al                       
    cmpb $1, %al                        # Check if cell has cursor
    je openCursor

    mov $1, %rax                        # Syscall number for write
    mov $1, %rdi                        # File descriptor 1 (stdout)
    lea whiteText(%rip), %rsi           # Address of white text
    mov $24, %rdx                       # Length of message
    syscall

    jmp finishCell

    openCursor:
    mov $1, %rax                        # Syscall number for write
    mov $1, %rdi                        # File descriptor 1 (stdout)
    lea yellowText(%rip), %rsi          # Address of yellow text
    mov $25, %rdx                       # Length of message
    syscall

    finishCell:

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea cellPadding(%rip), %rsi             # Address of empty space
    mov $1, %rdx                            # Length of message
    syscall

    incq %rbx                           # Move to flags of cell
    movzb (%rbx), %rax                  # Load flags of cell
    decq %rbx                           # Move back to cell

    andb $1, %al                       
    cmpb $1, %al                        # Check if cell has cursor
    jne rowCheck

    mov $1, %rax                        # Syscall number for write
    mov $1, %rdi                        # File descriptor 1 (stdout)
    lea yellowText(%rip), %rsi          # Address of yellow text
    mov $25, %rdx                       # Length of message
    syscall

    rowCheck:
    incq %rbx                               # Move to cell flags
    movzb (%rbx), %rax                      # Check if right border is set
    decq %rbx                               # Move back to cell

    andb $32, %al                           # Initialize right border checker
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

        incq %rbx                           # Move to flags of cell
        movzb (%rbx), %rax                  # Load flags of cell
        decq %rbx                           # Move back to cell

        andb $1, %al                       
        cmpb $1, %al                        # Check if cell has cursor
        jne notCursorRowEnd

        mov $1, %rax                        # Syscall number for write
        mov $1, %rdi                        # File descriptor 1 (stdout)
        lea yellowText(%rip), %rsi          # Address of yellow text
        mov $25, %rdx                       # Length of message
        syscall
        
        jmp cursorRowEnd

        notCursorRowEnd:
        mov $1, %rax                        # Syscall number for write
        mov $1, %rdi                        # File descriptor 1 (stdout)
        lea whiteText(%rip), %rsi           # Address of white text
        mov $24, %rdx                       # Length of message
        syscall

        cursorRowEnd:
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

    incq %rbx                               # Move to flags of cell
    movzb (%rbx), %rax                      # Load flags of cell
    decq %rbx                               # Move back to cell

    andb $1, %al                       
    cmpb $1, %al                            # Check if cell has cursor
    jne notCursorBottom

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea yellowText(%rip), %rsi               # Address of white text
    mov $25, %rdx                           # Length of message
    syscall

    jmp printBottom

    notCursorBottom:
    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea cellCorner(%rip), %rsi              # Address of bottom border
    mov $1, %rdx                            # Length of message
    syscall

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea reset(%rip), %rsi                   # Address of top border
    mov $4, %rdx                            # Length of message
    syscall

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea whiteText(%rip), %rsi               # Address of white text
    mov $24, %rdx                           # Length of message
    syscall

    call chooseBackground

    jmp printBottomHalf

    printBottom:
    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea cellCorner(%rip), %rsi              # Address of bottom border
    mov $1, %rdx                            # Length of message
    syscall

    printBottomHalf:
    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea cellTop(%rip), %rsi                 # Address of top border
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

    popq %rbx                               # Restore registers
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
    #prologue
    pushq %rbp
    movq %rsp, %rbp

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

    #epilogue
    movq %rbp, %rsp
    popq %rbp

ret

opened:
    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea darkGrayBackground(%rip), %rsi      # Address of top border
    mov $19, %rdx                           # Length of message
    syscall

    #epilogue
    movq %rbp, %rsp
    popq %rbp

ret

newLine:
    #prologue
    pushq %rbp
    movq %rsp, %rbp

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

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea whiteText(%rip), %rsi               # Address of white text
    mov $24, %rdx                           # Length of message
    syscall

    #epilogue
    movq %rbp, %rsp
    popq %rbp

ret

cursorTopLogic:
    #prologue
    pushq %rbp
    movq %rsp, %rbp

    call chooseBackground

    incq %rbx                               # Move to flags of cell
    movzb (%rbx), %rax                      # Load flags of cell
    decq %rbx                               # Move back to cell

    andb $1, %al                       
    cmpb $1, %al                            # Check if cell has cursor
    jne notCursor

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea yellowText(%rip), %rsi               # Address of white text
    mov $25, %rdx                           # Length of message
    syscall

    jmp printTop

    notCursor:
    leaq width(%rip), %rax                  # Load width address in rax
    movzb (%rax), %rax                      # Store width in rax

    movq %rbx, %rcx                         # Store top cell address in rcx

    subq %rax, %rcx                         # Check if cell is in top row
    subq %rax, %rcx

    leaq mineArray(%rip), %rdx              # Load mineArray address in rdx
    cmpq %rdx, %rcx              # Compare cell with first cell in mineArray
    
    jl printTopWhite

    incq %rcx                               # Move to top cell flags
    movzb (%rcx), %rcx                      # Load top cell flags    

    andb $1, %cl                            # Check if top cell has cursor
    cmpb $1, %cl                            
    je printTopYellow

    printTopWhite:
    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea cellCorner(%rip), %rsi              # Address of bottom border
    mov $1, %rdx                            # Length of message
    syscall

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea reset(%rip), %rsi                   # Address of top border
    mov $4, %rdx                            # Length of message
    syscall

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea whiteText(%rip), %rsi               # Address of white text
    mov $24, %rdx                           # Length of message
    syscall

    call chooseBackground

    jmp printTopHalf

    printTopYellow:

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea yellowText(%rip), %rsi               # Address of white text
    mov $25, %rdx                           # Length of message
    syscall

    printTop:
    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea cellCorner(%rip), %rsi              # Address of bottom border
    mov $1, %rdx                            # Length of message
    syscall

    printTopHalf:
    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea cellTop(%rip), %rsi                 # Address of top border
    mov $3, %rdx                            # Length of message
    syscall

    #epilogue
    movq %rbp, %rsp
    popq %rbp

ret 