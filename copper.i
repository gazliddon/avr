

.macro  line routine, repeats
        .word pm(\routine), \repeats
.endm

.macro jump dest
        .word   pm(\dest + 1)
.endm


