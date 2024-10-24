 .data
old_termios:
    .space 60          # Buffer for storing termios structure
new_termios:
    .space 60

.text
    clearSeq:
    .ascii "\033[2J\033[H"

.global enterRaw
.global enterCooked
.global clear

# Syscall: ioctl(fd, TCGETS, &old_termios)
enterRaw:
    #prologue
    pushq %rbp
	movq %rsp, %rbp

    movq $16, %rax            # syscall number for ioctl
    movq $0, %rdi             # stdin (file descriptor)
    movq $0x5401, %rsi        # TCGETS (to get terminal attributes)
    lea old_termios, %rdx # address of buffer to store the termios structure
    syscall                    # make the syscall

    # Copy old termios into new_termios
    mov $60, %rcx            # Termios struct size (60 bytes)
    lea old_termios, %rsi
    lea new_termios, %rdi
    rep movsb                # Copy old termios to new termios

    movb new_termios+12, %al # Load c_lflag (offset 12 in struct)
    andb $0xF5, %al     # Disable ICANON (0x2) and ECHO (0x8)
    movb %al, new_termios+12 # Store modified c_lflag

    movq $16, %rax            # syscall number for ioctl
    movq $0, %rdi             # stdin (file descriptor)
    movq $0x5402, %rsi        # TCsETS (to set terminal attributes)
    lea new_termios, %rdx # address of buffer to store the termios structure
    syscall                    # make the syscall

    #epilogue
    movq %rbp, %rsp
    popq %rbp
    
ret

enterCooked:
    #prologue
    pushq %rbp
	movq %rsp, %rbp

    movq $16, %rax              # syscall number for ioctl
    movq $0, %rdi               # stdin (file descriptor)
    movq $0x5402, %rsi          # TCsETS (to set terminal attributes)
    lea old_termios, %rdx # address of buffer to store the termios structure
    syscall                     # make the syscall

    #epilogue
    movq %rbp, %rsp
    popq %rbp

ret

clear:
    #prologue
    pushq %rbp
	movq %rsp, %rbp

    mov $1, %rax                            # Syscall number for write
    mov $1, %rdi                            # File descriptor 1 (stdout)
    lea clearSeq, %rsi                   # Address of message
    mov $7, %rdx                            # Length of message
    syscall

    #epilogue
    movq %rbp, %rsp
    popq %rbp

ret