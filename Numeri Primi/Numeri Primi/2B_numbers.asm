;
;Numeri_primi.asm
;
; Created: 05/11/2022 14:49:22
; Author : giuly
;


; Replace with your application code

.include "m32def.inc"


.equ NMAX = 999
.equ START_ADDR = 0x0060
.equ START_FROM_NUM = 2

;We use r25:r24 as support register for any value to be used with SBIW or ADIW

;r25 --> HIGH
;r24 --> LOW

setup:
	;initialize stack
	ldi r16, low(RAMEND)
	ldi r17, high(RAMEND)
	out SPL, r16
	out SPH, r17

	;Used to store 0 in memory
	clr r0 

	;Current size of the number sequence is stored in r22:r21
	ldi r22, high(NMAX)
	ldi r21, low(NMAX) 

	;Using X pointer to access memory
	ldi XL, low(START_ADDR) 
	ldi XH, high(START_ADDR)

	;Multiiply NMAX by 2
	lsl r21
	rol r22
	;Calculate last address used
	add XL, r21
	adc XH, r22
	;Restore NMAX
	ldi r22, high(NMAX)
	ldi r21, low(NMAX) 
	
	movw ZH:ZL, XH:XL ;Store last address in Z
	;Reset X pointer to starting address
	ldi XL, low(START_ADDR)
	ldi XH, high(START_ADDR)
	

	;Clear NMAX memory locations
	mov r25, r22
	mov r24, r21
	rcall ram_clear 

	
	;The number sequence starts from 2.
	ldi r24, low(START_FROM_NUM)
	ldi r25, 0
	;Reset X pointer to starting address
	ldi XL, low(START_ADDR)
	ldi XH, high(START_ADDR)
	;Fill memory
	rcall ram_fill ;

	ldi XL, low(START_ADDR)
	ldi XH, high(START_ADDR)

	clr r17 ;Number of cancellations
	ldi r18, START_FROM_NUM ;Number of which the multiple is being sought

	clr r0

loop:
	clr r17
	;Clear T bit
	clt

	;Execute Sieve
	rcall sieve

	next_multiple:
		inc r18

		;Resetting X pointer to the address of the next multiple to find
		lsl r18
		ldi XL, low(START_ADDR) 
		ldi XH, high(START_ADDR)
		add XL, r18
		adc XH, r0
		lsr r18

		;Subtract (offset * Bits per number) from X
		subi XL, START_FROM_NUM
		subi XL, START_FROM_NUM
	
		ld r24, X+
		ld r25, X

		;Repoint X to the HIGH Bit
		sbiw XH:XL, 1

		;Bitwise sum r24 to r25 to check if it's all 0 (Perform a bitwise OR)
		or r24, r25
		cpi r24, 0
		breq next_multiple
	
		;If T is set, r17 is in overflow. The number of cancellations isn't 0, for sure
		brts loop
		tst r17
		breq organize_data

		rjmp loop

organize_data:
;Using r25:r24 to store data read from memory

	;Initialize pointers
	ldi XL, low(START_ADDR) 
	ldi XH, high(START_ADDR)
	ldi YL, low(START_ADDR) 
	ldi YH, high(START_ADDR)

	find_first_empty:
		;X is the pointer that points to the first empty cell

		;Increment X
		adiw XH:XL, 2 

		;Load current number from 2-bit memory to r25:r24
		ld r25, X+ ;High
		ld r24, X ;Low

		;Repoint X to the HIGH Bit
		sbiw XH:XL, 1
		
		;Bitwise sum r24 to r25 to check if it's all 0 (Perform a bitwise OR)
		or r24, r25
		cpi r24, 0
		brne find_first_empty

		movw YH:YL, XH:XL

	find_numbers:
		;Y is the pointer that finds new numbers
		adiw YH:YL, 2 

		;Check if end is reached
		cp YH, ZH
		brne continue
		cp YL, ZL
		brne continue

		rjmp end

		continue:
			;Load current number from 2-bit memory to r25:r24
			ld r25, Y+ ;High
			ld r24, Y ;Low

			;Repoint Y to the HIGH Bit
			sbiw YH:YL, 1

			;Move the number to r17:r16 to preserve it while performing the OR
			mov r16, r24
			mov r17, r25

			;Bitwise sum r16 to r17 to check if it's all 0 (Perform a bitwise OR)
			or r16, r17
			cpi r16, 0
			breq find_numbers

			rjmp move_numbers

	move_numbers:
		st X+, r25
		st X+, r24

		st Y+, r0
		st Y, r0

		movw YH:YL, XH:XL
		rjmp find_numbers
	
end:
	ret

ram_clear:
	st X+, r0
	st X+, r0
	sbiw r25:r24, 1 ;Decrement r25:r24
	brne ram_clear
	ret

ram_fill:
	st X+, r25
	st X+, r24
	adiw r25:r24, 1 ;Increment r25:r24

	;Check if last address is reached
	cp XL, ZL
	brne ram_fill
	cp XH, ZH
	brne ram_fill
	ret

sieve:
	;Increment X by the number of which the multiple is being sought
	lsl r18
	add XL, r18
	adc XH, r0
	lsr r18

	;Load current number from 2-bit memory to r25:r24
	ld r25, X+ ;High
	ld r24, X ;Low

	;Bitwise sum r24 to r25 to check if it's all 0 (Perform a bitwise OR)
	or r24, r25
	cpi r24, 0
	breq already_deleted

	;Write 0 to the current 2-bit memory location
	st -X, r0
	adiw XH:XL, 1
	st X, r0
	
	;Increment number of cancellations
	inc	r17
	
	;If r17 goes in overflow, T bit is set in SREG
	brvc already_deleted
		set

	already_deleted:
	;Repoint X to the HIGH Bit
	sbiw XH:XL, 1
		
		;Check if last address is reached
		cp XH, ZH
		brlo sieve
		cp XL, ZL
		brlo sieve
   	ret