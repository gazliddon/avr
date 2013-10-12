
	.include 	"ports.i"
	.include 	"avr.i"
;; ----------------------------------------------------------------------------
;; Globals
	.global 	printScreenKernelInit
	.global 	printScreenLineKernel

;; ----------------------------------------------------------------------------
;; Equates
WIDTH_CHARS =     16
WIDTH_PIXELS =    WIDTH_CHARS * 8

;; ----------------------------------------------------------------------------
;; Vars
        .section        .bss

;; Line bufffers
        .comm ramScreen, WIDTH_CHARS * WIDTH_CHARS

;; ----------------------------------------------------------------------------
;; Code
        .section 	.text

MAX_CHARS = 128

;; Register Allocations

;; Presistent

T_64 = 18
C_ADD = 19
Y_POS =      20
Y_POS_L =    20    ;; b 0 - 4 = fractional b 5 - 7 = offset into char
Y_POS_H =    21    ;; b 0 - 8 = char line

SCR = 	     22
SCR_L =      22
SCR_H =      23

T_CHAR_WIDTH = 24

SRAM_CHARS =   6
SRAM_CHARS_L = 6
SRAM_CHARS_H = 7

FLASH_CHARS =   8
FLASH_CHARS_L = 8
FLASH_CHARS_H = 9

;; Transient / trashed

LT_0 =        10
LT_1 = 	      11
LT_2 = 	      12
LT_3 = 	      13
Y_ADD =       14
ZERO_2 =      15

;; Reg >= 16 temp
T_1 = 17


WIDTH_IN_CHARS = 7

printScreenKernelInit:
	clr Y_POS_L
	clr Y_POS_H
	
	ldi r16, lo8(characters)
	ldi r17, hi8(characters)
	movw SRAM_CHARS, r16

	ldi r16, lo8(characters)
	ldi r17, hi8(characters)
	movw FLASH_CHARS, r16
	ldi 	T_64,64 			; 1  (1)

	ldi T_1, 9 
	mov Y_ADD, T_1

	ldi 	SCR_L, lo8(ramScreen)
	ldi 	SCR_H, hi8(ramScreen)
	clr 	ZERO_2	
	ldi 	T_CHAR_WIDTH, WIDTH_IN_CHARS

	ret

printScreenLineKernel:
	mul 	Y_POS_L,T_64
	mov 	C_ADD,r1
	andi 	C_ADD,0b11111000
	
	;; Work out scr line Y_POS_H
	mul 	Y_POS_H, T_CHAR_WIDTH
	movw 	X,SCR

	add 	XL, r0
	adc 	XH, r1

	ld 	T_1, X+ 			; 3  (3)
	mul 	T_1,T_64 			; 6  (2)
	or      r0,C_ADD

	movw 	Z,SRAM_CHARS 			; 8  (1)
	cpi 	T_1,MAX_CHARS 			; 9  (1)
	brsh    .+2 				; 10 (2/1)
	movw 	Z,FLASH_CHARS 			; 10 (1)

	add 	ZL, r0 				; 12 (1)
	adc 	ZH, r1 				; 13 (1)

renderFromFlash:
        ;; p0
        lpm LT_0,Z+
        out PORTD, LT_0
                ld T_1, X+
        ;; p1
        lpm LT_0,Z+
        out PORTD, LT_0
                cpi     T_1, MAX_CHARS
                movw    LT_2, FLASH_CHARS
        ;; p2
        lpm LT_0,Z+
        out PORTD, LT_0
                mul T_1,T_64
        ;; p3
        lpm LT_0,Z+
        out PORTD, LT_0
		brsh .+2
                movw    LT_2,SRAM_CHARS
        ;; p4
        lpm LT_0,Z+
        out PORTD, LT_0
		or r0,C_ADD
                add LT_2,r0
        ;; p5
        lpm LT_0,Z+
        out PORTD, LT_0
                adc LT_3,r1
		nop
        ;; p6
        lpm LT_0,Z+
        out PORTD, LT_0
                dec T_CHAR_WIDTH
        ;; p7
        lpm LT_0,Z+
		movw Z, LT_2
        out PORTD, LT_0
                brne renderFromFlash  ;; 2 if take 
	
	add 	Y_POS_L, Y_ADD
	adc 	Y_POS_H, ZERO_2
	ldi 	T_CHAR_WIDTH, WIDTH_IN_CHARS

	clr r0
	clr r1
	inc r1
	ret

lineBufferKernelInit:
        ret

lineBufferKernel:
        ret
