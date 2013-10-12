
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


Y_POS =      20
Y_POS_L =    20    ;; b 0 - 4 = fractional b 5 - 7 = offset into char
Y_POS_H =    21    ;; b 0 - 8 = char line

SRAM_CHARS =   22
SRAM_CHARS_L = 22
SRAM_CHARS_H = 23

FLASH_CHARS =   24
FLASH_CHARS_L = 24
FLASH_CHARS_H = 25

;; Transient / trashed
T_64 =        9
LT_0 =        10
LT_1 = 	      11
LT_2 = 	      12
LT_3 = 	      13

Y_ADD =       14

;; Reg >= 16 temp
T_CHAR_WIDTH = 16
T_1 = 17


.macro calc_scr

	mov 	T_1, Y_POS_L
	lsr     T_1
	lsr     T_1
	add 	FLASH_CHARS_L, T_1
	adc 	FLASH_CHARS_H, r0
	add 	SRAM_CHARS_L, T_1
	adc 	SRAM_CHARS_H, r0
	
	;; Work out scr line Y_POS_H
	ldi 	T_CHAR_WIDTH, 8 		; 14 (1)
	mul 	Y_POS_H, T_CHAR_WIDTH
	ldi 	XL, lo8(screen)
	ldi 	XH, hi8(screen)
	add 	XL, r0
	adc 	XH, r1
	clr r0
	clr r1
	inc r1
.endm

printScreenKernelInit:
	clr Y_POS_L
	clr Y_POS_H

	ldi SRAM_CHARS_L, lo8(characters)
	ldi SRAM_CHARS_H, hi8(characters)

	ldi FLASH_CHARS_L, lo8(characters)
	ldi FLASH_CHARS_H, hi8(characters)
	
	ret

printScreenLineKernel:
	ldi SRAM_CHARS_L, lo8(characters)
	ldi SRAM_CHARS_H, hi8(characters)

	ldi FLASH_CHARS_L, lo8(characters)
	ldi FLASH_CHARS_H, hi8(characters)
	mov 	T_1, Y_POS_L

	lsr     T_1
	lsr     T_1
	andi 	T_1, 0b00111000

	add 	FLASH_CHARS_L, T_1
	adc 	FLASH_CHARS_H, r0
	add 	SRAM_CHARS_L, T_1
	adc 	SRAM_CHARS_H, r0
	
	;; Work out scr line Y_POS_H
	ldi 	T_CHAR_WIDTH, 8 		; 14 (1)
	mul 	Y_POS_H, T_CHAR_WIDTH
	ldi 	XL, lo8(ramScreen)
	ldi 	XH, hi8(ramScreen)

;;;	add 	XL, r0
;;;	adc 	XH, r1

	ldi 	T_CHAR_WIDTH,6 		; 14 (1)

	ldi 	T_1,64 				; 1  (1)
	mov 	T_64, T_1 			; 2  (1)
	ld 	T_1, X+ 			; 3  (3)
	
	mul 	T_1,T_64 			; 6  (2)
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
                add LT_2,r0
                adc LT_3,r1
        ;; p5
        lpm LT_0,Z+
        out PORTD, LT_0
		nop
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

	clr r0
	clr r1
	inc r1

	ldi 	T_1, 1<<3
	add 	Y_POS_L, T_1
	adc 	Y_POS_H, r0
	ret

lineBufferKernelInit:
        ret

lineBufferKernel:
        ret
