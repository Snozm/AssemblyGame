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
.global width
.global height

getDim:
    #prologue
    pushq %rbp
	movq %rsp, %rbp

invalidReturn:
    mov $1, %rax                        # Syscall number for write
    mov $1, %rdi                        # File descriptor 1 (stdout)
    lea dimension_prompt, %rsi    # Address of message
    mov $71, %rdx                       # Length of message
    syscall

    mov $0, %rax                        # Syscall number for read
    mov $0, %rdi                        # File descriptor 0 (stdin)
    lea buffer, %rsi              # Address of buffer
    mov $3, %rdx                        # Read 2 bytes
    syscall                             # Call read

    cmpb $'\n, buffer
    je invalidDimInput
    cmpb $'\n, buffer+1
    je bufferCheckedWidth
    cmpb $'\n, buffer+2
    je bufferCheckedWidth
    jmp flush


bufferCheckedWidth:
#integer conversion decision tree
    movw buffer, %ax
    movw %ax, width

    cmpb $'1, width               # Check if first character is bigger than 1
    jl invalidDimInput
    cmpb $'9, width               # Check if first character is smaller than 9
    jg invalidDimInput
    cmpb $'\n, width+1            # Check if a single character has been given
    je oneDigW
    cmpb $'0, width+1             # Check if second character is bigger than 0
    jl invalidDimInput
    cmpb $'9, width+1             # Check if second character is smaller than 9
    jg invalidDimInput
    jmp twoDigW

widthNummed:

    mov $0, %rax                        # Syscall number for read
    mov $0, %rdi                        # File descriptor 0 (stdin)
    lea buffer, %rsi              # Address of buffer
    mov $3, %rdx                        # Read 2 bytes
    syscall                             # Call read

    cmpb $'\n, buffer
    je invalidDimInput
    cmpb $'\n, buffer+1
    je bufferCheckedHeight
    cmpb $'\n, buffer+2
    je bufferCheckedHeight
    jmp flush

bufferCheckedHeight:
    movw buffer, %ax
    movw %ax, height
    
    cmpb $'1, height
    jl invalidDimInput
    cmpb $'9, height
    jg invalidDimInput
    cmpb $'\n, height+1
    je oneDigH
    cmpb $'0, height+1
    jl invalidDimInput
    cmpb $'9, height+1
    jg invalidDimInput
    cmpb $'\n, buffer+2
    jne invalidDimInput
    jmp twoDigH

heightNummed:

    mov $1, %rax                        # Syscall number for write
    mov $1, %rdi                        # File descriptor 1 (stdout)
    lea width, %rsi               # Address of message
    mov $2, %rdx                        # Length of message
    syscall

    mov $1, %rax                        # Syscall number for write
    mov $1, %rdi                        # File descriptor 1 (stdout)
    lea height, %rsi              # Address of message
    mov $2, %rdx                        # Length of message
    syscall

    #epilogue
    movq %rbp, %rsp
    popq %rbp

ret

flush:
    mov $0, %rax                             # Syscall number for write
    mov $0, %rdi                             # File descriptor 1 (stdout)
    lea buffer, %rsi                   # Address of message
    mov $1, %rdx                            # Length of message
    syscall

    cmpb $'\n, buffer                 # Check if the newline has been found
    jne flush

invalidDimInput:

    mov $1, %rax                             # Syscall number for write
    mov $1, %rdi                             # File descriptor 1 (stdout)
    lea invalidDimMessage, %rsi        # Address of message
    mov $32, %rdx                            # Length of message
    syscall

jmp invalidReturn

oneDigW:
    subb $48, width
jmp widthNummed

oneDigH:
    subb $48, height
jmp heightNummed

twoDigW:

    subb $48, width
    subb $48, width+1
    movb $10, %al
    mulb width
    movb %al, width
    movb width+1, %al
    movb $10, width+1
    addb %al, width

    cmpb $1, width
    jl invalidDimInput
    cmpb $40, width
    jg invalidDimInput

jmp widthNummed

twoDigH:
    subb $48, height
    subb $48, height+1
    movb $10, %al
    mulb height
    movb %al, height
    movb height+1, %al
    movb $10, height+1
    addb %al, height

    cmpb $1, height
    jl invalidDimInput
    cmpb $40, height
    jg invalidDimInput

jmp heightNummed
