
        .global         gotoSleep
        .global         doPokes

        .include        "stuff.i"

;; Puts the machine to sleep
gotoSleep:
        cli
	out SMRC, 1
	sleep


;; Pokes stuff from a table into zero page addresses from
;; 1 -> ff inclusive
;; address 0 marks end of table
;; r30:31 (Z) -> poke table
;; trashes 1,26,27

doPokes:
	ldi r27, 0 		; X hi = 0
pokesLoop:
	lpm 	r26, Z+ 	; X lo = write address
	tst 	r26 		; Finished poke list if 0
	breq 	pokesDone
	lpm 	r1, Z+ 		; Get the val we're writing
	st 	X,r1 		; store it to *X (26:27)
	rjmp pokesLoop  	; Loop!
pokesDone:
	ret


