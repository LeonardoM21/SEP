;
;Numeri_primi.asm
;
; Created: 05/11/2022 14:49:22
; Author : giuly
;


; Replace with your application code

.include "m32def.inc"


.equ NMAX = 99
.equ START_ADDR = 0x0060
.equ START_FROM_NUM = 2

setup:
	;initialize stack
	ldi r16, low(RAMEND)
	ldi r17, high(RAMEND)
	out SPL, r16
	out SPH, r17

	clr r0 ;Used to store 0 in memory

	ldi r16, NMAX ;Current size of the number sequence is stored in r16

	ldi XL, low(START_ADDR) ;Using X pointer to access memory
	ldi XH, high(START_ADDR)

	ldi r21, high(NMAX);Calculate last address used
	ldi r22, low(NMAX)
	add XH, r21
	add XL, r22
	clr r21
	clr r22
	movw ZH:ZL, XH:XL ;Store last address in Z

	ldi XL, low(START_ADDR)
	ldi XH, high(START_ADDR)
	

	;Clear NMAX memory locations
	mov r1, r16 ;Using r1 as support register
	rcall ram_clear 

	;The number sequence starts from 2. Using r21 as support register to fill ram
	ldi r21, START_FROM_NUM 
	ldi XL, low(START_ADDR)
	ldi XH, high(START_ADDR)

	rcall ram_fill ;

	ldi XL, low(START_ADDR)
	ldi XH, high(START_ADDR)

	clr r17 ;number of cancellations
	ldi r18, START_FROM_NUM ;numero di cui si sta cercando il multiplo

	clr r0

loop:
	rcall sieve
next_multiple:
	inc r18
	;Resetting X pointer to the address of the next multiple to find
	ldi XL, low(START_ADDR) 
	ldi XH, high(START_ADDR)
	add XL, r18
	subi XL, START_FROM_NUM
	
	ld r19, X
	tst r19
	breq next_multiple

	tst r17
	breq organize_data

	clr r17

	rjmp loop

organize_data:
;Using r16 to store data read from memory

	;Initialize pointers
	ldi XL, low(START_ADDR) 
	ldi XH, high(START_ADDR)
	ldi YL, low(START_ADDR) 
	ldi YH, high(START_ADDR)

	find_first_empty:
		adiw XH:XL, 1 ;X is the pointer that points to the first empty cell
		ld r16, X
		tst r16
		brne find_first_empty

		movw YH:YL, XH:XL

	find_numbers:
		adiw YH:YL, 1 ;Y is the pointer that finds new numbers
		cp YL, ZL
		breq end
		ld r16, Y
		tst r16
		breq find_numbers

	move_numbers:
		st X+, r16
		st Y, r0
		movw YH:YL, XH:XL
		rjmp find_numbers
	
end:
	ret

ram_clear:
	st X+, r0
	dec r1
	brne ram_clear
	ret

ram_fill:
	st X+, r21
	inc r21
	cp XL, ZL 
	brne ram_fill
	ret

sieve:
	add XL, r18
	adc XH, r0

	ld r20, X
	cpi r20, 0
	breq already_deleted

	st X, r0
	inc	r17

	already_deleted:			
		cp XL, ZL
		brlo sieve
   	ret


	