.bss
buffer:
    .skip 3       # Reserve space for 3 characters (escape sequence)
mineArray:
    .skip 3200   # Reserve space for 40x40 mine array

.text
up_message:
    .ascii "Up arrow pressed\n"
down_message:
    .ascii "Down arrow pressed\n"
right_message:
    .ascii "Right arrow pressed\n"
left_message:
    .ascii "Left arrow pressed\n"
d_message:
    .ascii "Found D\n"
f_message:
    .ascii "Found F\n"


.global main
.global mineArray
main:
    #prologue
    pushq %rbp
	movq %rsp, %rbp

    call getDim

    call getMines

# Initialize border flags
    leaq mineArray(%rip), %rdi              # Load address of mineArray in rdi
    movq $0, %r8                            # Initialize column counter
    movq $0, %r9                            # Initialize row counter

    leaq height(%rip), %rcx                 # Load height address in rcx
    movq (%rcx), %rcx                       # Store height in rcx
    
    leaq width(%rip), %rax                  # Load width address in rax
    movq (%rax), %rax                       # Store width in rax

columnIterator:
    incq %r8                                # Increment column counter

    rowIterator:
        cmpq %rcx, %r8                      # Compare column counter with height
        jne notBottom
        orw $16, (%rdi)                     # Set bottom border flag the cell to 1

    notBottom:
        incq %r9                            # Increment row counter
        cmpq %rax, %r9                      # Compare row counter with width
        je rowEnd

        addq $2, %rdi                       # Move to next cell in mineArray       
        jmp rowIterator 

    rowEnd:
    orw $32, (%rdi)                         # Set right border flag the cell to 1
    addq $2, %rdi                           # Move to next cell in mineArray

    movq $0, %r9                            # Reset row counter

    cmpq %rcx, %r8                          # Compare column counter with height
jne columnIterator 

    call enterRaw                    

detect:
    # Read 3 bytes from stdin
    mov $0, %rdi                        # File descriptor 0 (stdin)
    lea buffer(%rip), %rsi              # Address of buffer
    mov $3, %rdx                        # Read 3 bytes (escape sequence length)
    mov $0, %rax                        # Syscall number for read
    syscall                             # Call read

    # Check for escape sequence (0x1B)
    cmpb $0x1B, buffer(%rip)            # Compare first byte with 0x1B
    jne not_arrow                       # If not 0x1B, it's not an arrow key

    # Check second byte '[' (0x5B)
    cmpb $0x5B, buffer+1(%rip)
    jne not_arrow

    # Check for the specific arrow key (third byte)
    cmpb $0x41, buffer+2(%rip)              # Up arrow: 0x41
    je up_arrow
    cmpb $0x42, buffer+2(%rip)              # Down arrow: 0x42
    je down_arrow
    cmpb $0x43, buffer+2(%rip)              # Right arrow: 0x43
    je right_arrow
    cmpb $0x44, buffer+2(%rip)              # Left arrow: 0x44
    je left_arrow

not_arrow:
    # Handle non-arrow keys
    cmpb $'d, buffer(%rip)
    jne flag
    
    call clear

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea d_message(%rip), %rsi               # Address of message
    mov $8, %rdx                            # Length of message
    syscall

    jmp done
flag:
    cmpb $'f, buffer(%rip)
    jne detect
    
    call clear

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea f_message(%rip), %rsi               # Address of message
    mov $8, %rdx                            # Length of message
    syscall

    jmp done

up_arrow:
    # Code to handle up arrow
    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea up_message(%rip), %rsi              # Address of message
    mov $17, %rdx                           # Length of message
    syscall
    jmp detect

down_arrow:
    # Code to handle down arrow
    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea down_message(%rip), %rsi            # Address of message
    mov $19, %rdx                           # Length of message
    syscall
    jmp detect

right_arrow:
    # Code to handle right arrow
    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea right_message(%rip), %rsi
    mov $20, %rdx                           # Length of message
    syscall
    jmp detect

left_arrow:
    # Code to handle left arrow
    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea left_message(%rip), %rsi
    mov $19, %rdx                           # Length of message
    syscall
    jmp detect
done:

    call enterCooked                        # Restore terminal

    #epilogue
    movq %rbp, %rsp
    popq %rbp

    movq $0, %rdi
    call exit
    
