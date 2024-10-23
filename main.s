.bss
buffer:
    .skip 3       # Reserve space for 3 characters (escape sequence)
mineArray:
    .skip 3200   # Reserve space for 40x40 mine array
.text

#testS: .asciz "test"
stngQuery: .ascii "Would you like to keep board settings? (Y/n)\n"

.global main
.global mineArray
main:
    #prologue
    pushq %rbp
	movq %rsp, %rbp
restart:
    call getDim

    call getMines
replay:

    call borderInit#segfault



    call enterRaw

    
    pushq %rbx                              # Save cursor index register
    pushq $0                                # Stack alignment

    movq $0, %rbx                           # Initialize cursor index to 1
    movq $0, %rsi

detect:
    call openMineCheck
    call draw

    cmpq $1, %r9
    je done

    cmpq $2, %r9
    je done

    # Read 3 bytes from stdin
    mov $0, %rdi                        # File descriptor 0 (stdin)
    lea buffer, %rsi              # Address of buffer
    mov $3, %rdx                        # Read 3 bytes (escape sequence length)
    mov $0, %rax                        # Syscall number for read
    syscall                             # Call read

    # Check for escape sequence (0x1B)
    cmpb $0x1B, buffer            # Compare first byte with 0x1B
    jne not_arrow                       # If not 0x1B, it's not an arrow key

    # Check second byte '[' (0x5B)
    cmpb $0x5B, buffer+1
    jne not_arrow

    leaq mineArray, %rdi
    addq %rbx, %rdi
    addq %rbx, %rdi
    incq %rdi

    andb $254, (%rdi)             

    # Check for the specific arrow key (third byte)
    cmpb $0x41, buffer+2              # Up arrow: 0x41
    je up_arrow
    cmpb $0x42, buffer+2              # Down arrow: 0x42
    je down_arrow
    cmpb $0x43, buffer+2              # Right arrow: 0x43
    je right_arrow
    cmpb $0x44, buffer+2              # Left arrow: 0x44
    je left_arrow

not_arrow:
    # Handle non-arrow keys
    cmpb $'d, buffer
    jne flag

    leaq mineArray, %rdi              
    addq %rbx, %rdi
    addq %rbx, %rdi
    incq %rdi

    movq $8, %rax
    andb (%rdi), %al                      # Load current cell flags
    
    cmpq $8, %rax
    je detect
    
    cmpq $0, (%rsp)                         # Check if dig hasn't happened 
    je initialiseMines

    movq $4, %rax
    andb (%rdi), %al                      # Load current cell flags
    cmpq $4, %rax
    je digChorder

    orb $4, (%rdi)                          # Set opened flag to 1

    decq %rdi
    cmpb $'0, (%rdi)
    jne checkMine
    call zeroChainer
    
    #movq $0, %rax
    #movq $testS, %rdi                       # LEGACY COMMENT, DO NOT TOUCH
    #call printf

    jmp detect

    checkMine:
    cmpb $'#, (%rdi)
    jne detect

    call openMineCheck

    jmp detect

    digChorder:

    call digChording
    call openMineCheck
    jmp detect

    initialiseMines:
    call mineInit                           # Initialize mines around cursor
    
    call calcNumbers                        #calc the num

    call zeroChainer
    notq (%rsp)                             # Set dig happened to 1

    jmp detect
flag:
    cmpb $'f, buffer
    jne detect
    
    leaq mineArray, %rdi
    addq %rbx, %rdi
    addq %rbx, %rdi
    incq %rdi

    movzb (%rdi), %rax                      # Load current cell flags

    andb $4, %al                            # Check if cell is opened
    cmpb $4, %al
    jne flagCell

    call flagChording
    jmp detect

    flagCell:
    movzb (%rdi), %rax                      # Load current cell flags

    andb $8, %al                            # Check if cell is flagged
    cmpb $8, %al
    jne flagSet

    andb $0b11110111, (%rdi)                # Set flagged flag to 0
    jmp detect

    flagSet:
    orb $8, (%rdi)                          # Set flagged flag to 1

    jmp detect

up_arrow:
    movq %rbx, %rax
    leaq width, %rcx                  # Load width address in rcx
    movzb (%rcx), %rcx                      # Store width in rcx
    movq $0, %rdx                           # Clear rdx

    subq %rcx, %rbx                         # Move to upper cell

    divq %rcx
    cmpq $0, %rax
    jne arrowDone
    
    leaq height, %rdx                 # Load height address in rdx
    movzb (%rdx), %rdx                      # Store height in rdx
    
    upLoop:
        decq %rdx                           # Decrement height counter

        addq %rcx, %rbx                     # Move to lower cell

        cmpq $0, %rdx                       # Check if height counter is 0
    jne upLoop

jmp arrowDone

down_arrow:
    movq %rbx, %rax
    leaq width, %rcx                  # Load width address in rcx
    movzb (%rcx), %rcx                      # Store width in rcx
    movq $0, %rdx                           # Clear rdx

    leaq height, %r8                  # Load height address in r8
    movzb (%r8), %r8                        # Store height in r8
    decq %r8                                # Decrement height 

    addq %rcx, %rbx                         # Move to lower cell

    divq %rcx
    cmpq %r8, %rax
    jne arrowDone

    incq %r8

    downLoop:
        decq %r8                            # Decrement height counter

        subq %rcx, %rbx                     # Move to lower cell

        cmpq $0, %r8                        # Check if height counter is 0
        jne downLoop

jmp arrowDone

right_arrow:

    movq %rbx, %rax
    leaq width, %rcx                  # Load width address in rcx
    movzb (%rcx), %rcx                      # Store width in rcx
    movq $0, %rdx                           # Clear rdx

    incq %rbx

    divq %rcx
    decq %rcx
    
    cmpq %rcx, %rdx
    jne arrowDone          

    subq %rcx, %rbx                         # Move cursor to left border
    decq %rbx

jmp arrowDone

left_arrow:
    movq %rbx, %rax
    leaq width, %rcx                  # Load width address in rcx
    movzb (%rcx), %rcx                      # Store width in rcx
    movq $0, %rdx                           # Clear rdx

    decq %rbx

    divq %rcx
    cmpq $0, %rdx
    jne arrowDone          

    addq %rcx, %rbx                         # Move cursor to right border

jmp arrowDone

done:

    call enterCooked                        # Restore terminal

    popq %rbx                              # Restore cursor index register
    popq %rbx                              # Restore cursor index register

    mov $0, %rax                        # Syscall number for read
    mov $0, %rdi                        # File descriptor 0 (stdin)
    lea buffer, %rsi                    # Address of buffer
    mov $1, %rdx                        # Read 3 bytes (escape sequence length)
    syscall                             # Call read

    cmpb $'Y, buffer
    jne donePlus

        flush:
            mov $0, %rax                             # Syscall number for write
            mov $0, %rdi                             # File descriptor 1 (stdout)
            lea buffer, %rsi                   # Address of message
            mov $1, %rdx                            # Length of message
            syscall

            cmpb $'\n, buffer                 # Check if the newline has been found
        jne flush

        leaq mineArray, %rax
        arrClear: #clear 400 consecutive quads
            movq $0, (%rax)
            addq $8, %rax
            cmpq mineArray+3200, %rax
        jle arrClear

        movq %rbp, %rsp

        jmp restart                         #CODE FOR REPLAY BROKEN BEYOND THIS POINT

        mov $1, %rax                             # Syscall number for write
        mov $1, %rdi                             # File descriptor 1 (stdout)
        lea stngQuery, %rsi                   # Address of message
        mov $45, %rdx                            # Length of message
        syscall

        mov $0, %rax                        # Syscall number for read
        mov $0, %rdi                        # File descriptor 0 (stdin)
        lea buffer, %rsi                    # Address of buffer
        mov $1, %rdx                        # Read 3 bytes (escape sequence length)
        syscall                             # Call read

        flushTwo:
            mov $0, %rax                             # Syscall number for write
            mov $0, %rdi                             # File descriptor 1 (stdout)
            lea buffer+2, %rsi                   # Address of message
            mov $1, %rdx                            # Length of message
            syscall

            cmpb $'\n, buffer+2                 # Check if the newline has been found
        jne flushTwo

        cmpb $'Y, buffer
        je replay

    jmp restart

donePlus:

    flushPlus:
        mov $0, %rax                             # Syscall number for write
        mov $0, %rdi                             # File descriptor 1 (stdout)
        lea buffer, %rsi                   # Address of message
        mov $1, %rdx                            # Length of message
        syscall

        cmpb $'\n, buffer                 # Check if the newline has been found
    jne flushPlus

    #epilogue
    movq %rbp, %rsp
    popq %rbp

    movq $0, %rdi
    call exit
    
arrowDone:
    leaq mineArray, %rdi              # Load address of mineArray in rdi
    addq %rbx, %rdi                         # Move to cell after cursor
    addq %rbx, %rdi

    incq %rdi                               # Move to cursor cell flags
    orb $1, (%rdi)                          # Move cursor flag

    jmp detect