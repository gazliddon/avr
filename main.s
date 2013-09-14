;; Main source file!

#include "stuff.i"

	.global  	delayxplus161
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

