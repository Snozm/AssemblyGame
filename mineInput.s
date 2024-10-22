.bss
buffer:
    .skip 5
mines:
    .space 2, 0
.text 
mine_prompt:
    .ascii "Input an integer from 1 to total board size for mine count\n"
invalidMineMessage:
    .ascii "Invalid mine count, try again\n\n\n"

.global getMines
.global mines
getMines:
    #prologue
    pushq %rbp
	movq %rsp, %rbp

invalidReturn:
    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea mine_prompt, %rsi             # Address of message
    mov $59, %rdx                           # Length of message
    syscall

    mov $0, %rax                            # Syscall number for read
    mov $0, %rdi                            # File descriptor 0 (stdin)
    lea buffer, %rsi                  # Address of buffer
    mov $5, %rdx                            # Read 2 bytes
    syscall                                 # Call read

    movq $0, %rax                           # Preparing registers for multiplication
    movq $0, %rdx
    lea buffer, %r8                   # Load buffer into r8 for loop usage
    movq $10, %r10                          # Store 10 into r10 for multiplication
    cmpb $'0, buffer                  # Check if first character is 0
    je invalidMineInput                     # If it is, it's invalid

#digit counting
    cmpb $'\n, buffer                 # Check if first character is newline
    je invalidMineInput                     # If it is, it's invalid
    cmpb $'\n, buffer+1               # Check if second character is newline
    movq $1, %r9                            # If it is, set digit counter to 1 and loop
    je bufferChecked
    cmpb $'\n, buffer+2               # Check if third character is newline
    movq $2, %r9                            # If it is, set digit counter to 2 and loop
    je bufferChecked
    cmpb $'\n, buffer+3               # Check if fourth character is newline
    movq $3, %r9                            # If it is, set digit counter to 3 and loop
    je bufferChecked
    cmpb $'\n, buffer+4               # Check if fifth character is newline
    movq $4, %r9                            # If it is, set digit counter to 4 and loop
    je bufferChecked
jmp flush                                   # If it doesn't include a newline, flush the buffer

bufferChecked:
    
    mulq %r10                               # Multiply current value by 10    
    movb (%r8), %dil                        # Load current character into rdi

    cmpb $'0, %dil                          # Check if character is a number
    jl invalidMineInput
    cmpb $'9, %dil
    jg invalidMineInput
    
    subb $48, %dil                          # Convert character to integer
    addb %dil, %al                          # Add it to current total
    
    incq %r8                                # Move to next character
    decq %r9                                # Decrement digit counter
    cmpq $0, %r9                            # Check if all digits have been checked
    je done
    
jmp bufferChecked

done:
    movq %rax, %r8

    movq $0, %rax                           # Preparing registers for multiplication
    movq $0, %rdx
    movb width, %al                   # Load width into rax
    mulb height                       # Multiply by height
    
    cmpq %rax, %r8                          # Check if mine count is within board size
    jg invalidMineInput
    movw %r8w, mines                   # Store mine count

    #epilogue
    movq %rbp, %rsp
    popq %rbp

ret

flush:
    mov $0, %rax                            # Syscall number for read
    mov $0, %rdi                            # File descriptor 0 (stdin)
    lea buffer, %rsi                  # Address of message
    mov $1, %rdx                            # Length of message
    syscall

    cmpb $'\n, buffer                 # Check if the newline has been found
    jne flush

invalidMineInput:

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea invalidMineMessage, %rsi      # Address of message
    mov $32, %rdx                           # Length of message
    syscall

jmp invalidReturn