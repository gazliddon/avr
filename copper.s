;; Copper handling routines

	.include 	"copper.i"
	.section 	.text

;; Globals
	.global 	set_copper_list
	.global 	copper_next
	.global 	copper_list_pc
	.global 	copper_list_buffer	

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
copper_next:
	;; this block 14 cycles

	lds 	r26,copper_list_pc       ; 2 x -> entry in table
	lds 	r27,copper_list_pc+1     ; 2

	ld 	r30,X+ 		  	; 2 get the routtine in Y
	ld 	r31,X+ 			; 2

	lds 	r16,line_count 	    	; 2 bump the count
	sub 	r16,r1                  ; 1
	lds 	r17,line_count+1        ; 2
	sbc 	r17,r0                  ; 1

	;; Both paths 15 cycles
	brcc 	normal  		; 1/2 (1/2) No need to get next command

	   ld 	 r16, X+ 	        ; 2 (3) Skip count record
	   ld 	 r17, X+                ; 2 (5)
	   ld 	 r30, X+ 	        ; 2 (7) Get new routine
	   ld 	 r31, X+                ; 2 (9)
	   ld 	 r16, X+ 	        ; 2 (11) get new count
	   ld 	 r17, X+                ; 2 (13)
	   rjmp  exit 			; 2 (15)

normal:
	   nop                          ; 1 (3)
	   nop                          ; 1 (4)
	   nop                          ; 1 (5)
	   nop                          ; 1 (6)
	   nop                          ; 1 (7)
	   nop                          ; 1 (8)
	   nop                          ; 1 (9)
	   nop                          ; 1 (10)
	   nop                          ; 1 (11)
	   nop                          ; 1 (12)
	   nop                          ; 1 (13)
	   nop                          ; 1 (14)
	   nop                          ; 1 (15)
	
exit:
	;; 8 cycles
	sts 	copper_list_pc, r30      ; 2
	sts 	copper_list_pc+1, r31    ; 2
	sts 	line_count, r16              ; 2
	sts 	line_count+1, r17              ; 2

jump_routine:
	ret

	ijmp                            ; 2



