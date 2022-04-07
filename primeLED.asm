
initialize:
	ldi r21, 0xff	;set initial value for ddrb as output
	out ddrb,r21	;set port B as a output

	;Initialize Z registry for indirect adressing
	ldi r31, 0x00
	ldi r30, 0x64

	;initialize prime number list:
	.org 0x32 ; prime lists starts at program memory adress 0x32 in 16-bit adressing and 0x64 in 8-byte adressing
		prime: .DB 2, 3, 5, 7, 11, 13, 17, 19, 23


	;Initialize stack pointer:
	ldi r16, high(ramend)
	out sph,r16
	ldi r16, low(ramend)
	out spl,r16

	;------------- Belongs to sleep_10ms subprogram ----------------------------
	; Define how many tens of ms to sleep:
	.DSEG
	msToSleep: .BYTE 1
	.CSEG
	ldi r16,101	      ; second operand is how much ms to sleep. If given 2, subprogram 
				            ; will sleep for 10ms. You can calculate how much ms program will slepp
				            ; with this formula (100 - 1)*10 = msToSleep
	sts msToSleep,r16
	;---------------------------------------------------------------------------




main:
	lpm r20, Z+				;retrive value from Z pointer then increase (prime list)
	out portb,r20			;send that value to output
	call sleep_10ms
	push r21				  ;}
	ldi r21,0x6d			;}	This part is responsible for checking if program has gone through prime list,
	cp r21,r30				;}	if yes then Z pointer is restarted to the begining adress of prime list.
	pop r21					  ;}	End value is hard coded to r21 registry, if size or location of prime list changes,
	breq restart			;}	this address needs to change accordingly 
	rjmp main				  ;}	

restart:
	ldi r31, 0x00
	ldi r30, 0x64
	rjmp main



sleep_10ms:
	push r18
	push r17
	push r16
	lds r18, msToSleep					; sleep_10ms, stops for 10ms 
	loop1:
		ldi r16,161	
		loop2:
			ldi r17,249					;takes one cycle
			nop
			loop3:
				nop						; takes one cycle
				dec r17					; takes one cycle
				brne loop3				; if jumps takes 2 cycles if no then one cycle
		
			dec r16						;takes one cycle
			brne loop2					;if jumps takes 2 cycles if no then one cycle
	
		dec r18
		brne loop1

	pop r16
	pop r17
	pop r18

	ret
