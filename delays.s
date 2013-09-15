;; Main source file!

#include "stuff.i"

	.global 	delay15
	.global 	delay14
	.global 	delay12
	.global 	delay10
	.global 	delay9
	.global 	delay8
	.global 	delay7

	.global 	delay11

	.global 	delay3xplus8
	.global 	delay3xplus7
	.global 	delay3xplus6
	.global  	delayxplus161

delay15:	nop
delay14:	rjmp	.
delay12:	rjmp	.
delay10:	nop
delay9:		nop
delay8:		nop
delay7:		ret

delay11:	rjmp	delay9

delay3xplus8:	nop
delay3xplus7:	nop
delay3xplus6:
1:		subi	r16, 1			;	1
		brne	1b			;	2 in loop, 1 otherwise
		ret				;	4

; 3 x r16 + 8 including call



delayxplus161:	; 3 + 13 + x

1:		subi	r16, 3			;				1   \_ 3 * (x / 3) + 2
		brsh	1b			;				1/2 /
		neg	r16			; [1,2,3], inverse of time left	1
		sbrs	r16, 0			;				1/2 \_ 2 if set, 3 if clear
		rjmp	.			;				2   /
		sbrs	r16, 1			;				1/2 \_ 2 if set, 3 if clear
		rjmp .				;				2   /
		sbrs	r16, 1			;				1/2 \_ 2 if set, 3 if clear
		rjmp .				;				2   /
		ret				;				4

