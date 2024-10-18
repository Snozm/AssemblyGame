.text
cellTop:
    .ascii "+---"
cellCorner:
    .ascii "+"
cellSideLeft:
    .ascii "| "
cellSideRight:
    .ascii " "
cellRight:
    .ascii "|"
.global draw

draw:
    #prologue
    pushq %rbp
    movq %rsp, %rbp

    

    #epilogue
    movq %rbp, %rsp
    popq %rbp

ret