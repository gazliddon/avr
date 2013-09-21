

.macro  line routine, repeats
        .word pm(\routine), \repeats
.endm

.macro jump dest
        line    copper_jump, pm(\dest)
.endm

.macro  line2 routine, repeats
        .word pm(\routine)
        .byte repeats - 1
.endm

.macro jump2 dest
        line2   jmp, .-\dest
.endm


