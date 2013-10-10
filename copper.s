;; Copper handling routines

	.include 	"copper.i"
	.include 	"ports.i"
	.section 	.text

;; Globals
	.global 	set_copper_list
	.global 	copper_next
	.global 	copper_list_pc
	.global 	copper_list_buffer	
        .global         copper_jump

copper_jump:
	mov r28,r16
	mov r29,r17

        lds r16, frameEnd       ; bump frameend
        add r16,r1
        sts frameEnd, r16
	
        rjmp set_copper_list

;; Y (28:29) -> table
set_copper_list:
	sts copper_list_pc, r28
	sts copper_list_pc+1,r29
	ldd r16, Y+2
	sts line_count, r16
	ldd r16, Y+3
	sts line_count+1, r16
	ret

;; 39 cycles + call overhead - can call this in back porch
;; 42 = w call means 5 cycle lead in to pushing pixles :)
;; reduce cycles by assign copper_list_pc + count to regs
;; returns Y -> routine
;; r16:r17 = line count
;; X -> line_count_pc for next call

;; 40 cycles!

copper_next:
	;; this block 14 cycles

	lds 	r26,copper_list_pc       ; 2 x -> entry in table
	lds 	r27,copper_list_pc+1     ; 2

	ld 	r30,X+ 		  	; 2 get the routtine in Y
	ld 	r31,X+ 			; 2

	lds 	r16,line_count 	    	; 2 dec the count
	sub 	r16,r1                  ; 1
	lds 	r17,line_count+1        ; 2
	sbc 	r17,r0                  ; 1

	;; Both paths 19 cycles
	brcc 	normal  		; 1/2 (1/2) No need to get next command

	   ld 	 r16, X+ 	        ; 2 (3) Skip count record
	   ld 	 r17, X+                ; 2 (5)
	   sts 	 copper_list_pc, r26    ; 2 (7)
	   sts   copper_list_pc+1, r27  ; 2 (9)
           ld 	 r30, X+ 	        ; 2 (11) Get new rioutine in y
	   ld 	 r31, X+                ; 2 (13)
	   ld 	 r16, X+ 	        ; 2 (15) get new count
	   ld 	 r17, X+                ; 2 (17)
           rjmp  exit 	        	; 2 (19)

normal:
        nop             ; 1 (3)
        nop             ; 1 (4)
        nop             ; 1 (5)
        nop             ; 1 (6)
        nop             ; 1 (7)
        nop             ; 1 (8)
        nop             ; 1 (9)
        nop             ; 1 (10)
        nop             ; 1 (11)
        nop             ; 1 (12)
        nop             ; 1 (13)
        nop             ; 1 (14)
        nop             ; 1 (15)
        nop             ; 1 (16)
        nop             ; 1 (17)
        nop             ; 1 (18)
        nop             ; 1 (19)
	
exit:
	;; 7 cycles
	sts 	line_count, r16         ; 2 (2)
	sts 	line_count+1, r17       ; 2 (4)

jump_routine:
	ret                             ; 3 (7)

	ijmp                            ; 2


;; New copper

;; r6:r7 -> copper routine
;; r8 count

;; r26:r27 -> table (once a line? needed?)
;; r28:r29 -> trashed
;; r30::r31 -> trashed

;; X (r26:r27) -> table
set_copper_list2:
        ld r6, X+
        ld r7, X+
        ld r8, X+
	ret

;; r8 = count
;; r6:r7 -> copper list
;; 14 cycles from call line routine begins

X = 26
XL = X
XH = 27
Y = 28
YL = Y
YH = 29
Z = 30
ZL = Z
ZH = 31

copper_next2:
        dec     r8                              ; 0 (1) 
        brne    1f                              ; 1 (1/2)

        movw  X,r6                           ; 1 (2)
        adiw  X,3                            ; 1 (3)
        movw  r6,X                           ; 1 (4)
        ld    YL,X+                          ; 2 (5)
        ld    YH,X+                          ; 2 (7)
        ld    r6,X+                          ; 2 (9)
        ijmp                                 ; 2 (11)

1:      ;; enter @ cycle 3
        movw     Y,r6                           ; 1 (3)
        nop                                     ; 1 (4)
        nop                                     ; 1 (5)
        nop                                     ; 1 (6)
        nop                                     ; 1 (7)
        nop                                     ; 1 (8)
        nop                                     ; 1 (9)
        nop                                     ; 1 (10)
	ijmp                                    ; 2 (11)

