.bss
buffer:
    .skip 3
width:
    .skip 2
height:
    .skip 2
.text 
dimension_prompt:
    .ascii "Input an integer from 1 to 40 for width followed by another for height\n"
invalidDimMessage:
    .ascii "Invalid dimensions, try again\n\n\n"

.global getDim

getDim:
    #prologue
    pushq %rbp
	movq %rsp, %rbp
invalidReturn:
    mov $1, %rax                        # Syscall number for write
    mov $1, %rdi                        # File descriptor 1 (stdout)
    lea dimension_prompt(%rip), %rsi    # Address of message
    mov $71, %rdx                       # Length of message
    syscall

    mov $0, %rax                        # Syscall number for read
    mov $0, %rdi                        # File descriptor 0 (stdin)
    lea buffer(%rip), %rsi              # Address of buffer
    mov $3, %rdx                        # Read 2 bytes
    syscall                             # Call read

    cmpb $'\n, buffer(%rip)
    je invalidDimInput
    cmpb $'\n, buffer+1(%rip)
    je bufferCheckedWidth
    cmpb $'\n, buffer+2(%rip)
    je bufferCheckedWidth
    jmp flush


bufferCheckedWidth:
#integer conversion decision tree
    movw buffer(%rip), %ax
    movw %ax, width(%rip)

    cmpb $'1, width(%rip)               # Check if first character is bigger than 1
    jl invalidDimInput
    cmpb $'9, width(%rip)               # Check if first character is smaller than 9
    jg invalidDimInput
    cmpb $'\n, width+1(%rip)            # Check if a single character has been given
    je oneDigW
    cmpb $'0, width+1(%rip)             # Check if second character is bigger than 0
    jl invalidDimInput
    cmpb $'9, width+1(%rip)             # Check if second character is smaller than 9
    jg invalidDimInput
    jmp twoDigW

widthNummed:

    addb $48, width(%rip)

    mov $0, %rax                        # Syscall number for read
    mov $0, %rdi                        # File descriptor 0 (stdin)
    lea buffer(%rip), %rsi              # Address of buffer
    mov $3, %rdx                        # Read 2 bytes
    syscall                             # Call read

    cmpb $'\n, buffer(%rip)
    je invalidDimInput
    cmpb $'\n, buffer+1(%rip)
    je bufferCheckedHeight
    cmpb $'\n, buffer+2(%rip)
    je bufferCheckedHeight
    jmp flush

bufferCheckedHeight:
    movw buffer(%rip), %ax
    movw %ax, height(%rip)
    
    cmpb $'1, height(%rip)
    jl invalidDimInput
    cmpb $'9, height(%rip)
    jg invalidDimInput
    cmpb $'\n, height+1(%rip)
    je oneDigH
    cmpb $'0, height+1(%rip)
    jl invalidDimInput
    cmpb $'9, height+1(%rip)
    jg invalidDimInput
    cmpb $'\n, buffer+2(%rip)
    jne invalidDimInput
    jmp twoDigH

heightNummed:

    addb $48, height(%rip)

    mov $1, %rax                        # Syscall number for write
    mov $1, %rdi                        # File descriptor 1 (stdout)
    lea width(%rip), %rsi               # Address of message
    mov $2, %rdx                        # Length of message
    syscall

    mov $1, %rax                        # Syscall number for write
    mov $1, %rdi                        # File descriptor 1 (stdout)
    lea height(%rip), %rsi              # Address of message
    mov $2, %rdx                        # Length of message
    syscall

    #epilogue
    movq %rbp, %rsp
    popq %rbp

    ret
flush:
    mov $0, %rax                             # Syscall number for write
    mov $0, %rdi                             # File descriptor 1 (stdout)
    lea buffer(%rip), %rsi                   # Address of message
    mov $1, %rdx                            # Length of message
    syscall

    cmpb $'\n, buffer(%rip)
    jne flush

invalidDimInput:

    mov $1, %rax                             # Syscall number for write
    mov $1, %rdi                             # File descriptor 1 (stdout)
    lea invalidDimMessage(%rip), %rsi        # Address of message
    mov $32, %rdx                            # Length of message
    syscall

jmp invalidReturn

oneDigW:
    subb $48, width(%rip)
jmp widthNummed

oneDigH:
    subb $48, height(%rip)
jmp heightNummed

twoDigW:

    subb $48, width(%rip)
    subb $48, width+1(%rip)
    movb $10, %al
    mulb width(%rip)
    movb %al, width(%rip)
    movb width+1(%rip), %al
    movb $10, width+1(%rip)
    addb %al, width(%rip)

    cmpb $1, width(%rip)
    jl invalidDimInput
    cmpb $40, width(%rip)
    jg invalidDimInput

jmp widthNummed

twoDigH:
    subb $48, height(%rip)
    subb $48, height+1(%rip)
    movb $10, %al
    mulb height(%rip)
    movb %al, height(%rip)
    movb height+1(%rip), %al
    movb $10, height+1(%rip)
    addb %al, height(%rip)

    cmpb $1, height(%rip)
    jl invalidDimInput
    cmpb $40, height(%rip)
    jg invalidDimInput

jmp heightNummed
