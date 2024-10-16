 .data
old_termios:
    .space 60          # Buffer for storing termios structure
new_termios:
    .space 60

.text

.global enterRaw
.global enterCooked

# Syscall: ioctl(fd, TCGETS, &old_termios)
enterRaw:
    #prologue
    pushq %rbp
	movq %rsp, %rbp

    movq $16, %rax            # syscall number for ioctl
    movq $0, %rdi             # stdin (file descriptor)
    movq $0x5401, %rsi        # TCGETS (to get terminal attributes)
    lea old_termios(%rip), %rdx # address of buffer to store the termios structure
    syscall                    # make the syscall

    # Copy old termios into new_termios
    mov $60, %rcx            # Termios struct size (60 bytes)
    lea old_termios(%rip), %rsi
    lea new_termios(%rip), %rdi
    rep movsb                # Copy old termios to new termios

    movb new_termios+12(%rip), %al # Load c_lflag (offset 12 in struct)
    andb $0xF5, %al     # Disable ICANON (0x2) and ECHO (0x8)
    movb %al, new_termios+12(%rip) # Store modified c_lflag

    movq $16, %rax            # syscall number for ioctl
    movq $0, %rdi             # stdin (file descriptor)
    movq $0x5402, %rsi        # TCsETS (to set terminal attributes)
    lea new_termios(%rip), %rdx # address of buffer to store the termios structure
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
    lea old_termios(%rip), %rdx # address of buffer to store the termios structure
    syscall                     # make the syscall

    #epilogue
    movq %rbp, %rsp
    popq %rbp

ret