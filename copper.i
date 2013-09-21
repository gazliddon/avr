

.macro  line routine, repeats
        .word pm(\routine)
        .word (\repeats - 1)
.endm

.macro jump dest
        .word  pm(copper_jump)
        .word  copper_list_buffer + (. - \dest)
.endm

.macro loop
        .word pm(copper_jump)
        .word copper_list_buffer
.endm

.macro  line2 routine, repeats
        .word pm(\routine)
        .byte repeats - 1
.endm

.macro jump2 dest
        line2   jmp, .-\dest
.endm


