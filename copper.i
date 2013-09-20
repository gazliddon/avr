

.macro  line routine, repeats
        .word \routine, \repeats
.endm

.macro jump dest
        .word   jmp, . - \dest
.endm


