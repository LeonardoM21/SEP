;
; Pianola.asm
;
; Created: 11/19/2022 2:57:34 PM
; Author :
;

;-------------------------------------------------FREQUENCIES--------------------------------------------------;
.equ DO1	= 7046 ;N° of clock (4Mhz) semi-cycles to set the counter to count to get a frequency of 261.60 Hz
.equ RE		= 6277 ;N° of clock (4Mhz) semi-cycles to set the counter to count to get a frequency of 293.66 Hz
.equ MI		= 5592 ;N° of clock (4Mhz) semi-cycles to set the counter to count to get a frequency of 329.63 Hz
.equ FA		= 5278 ;N° of clock (4Mhz) semi-cycles to set the counter to count to get a frequency of 349.23 Hz
.equ SOL	= 4702 ;N° of clock (4Mhz) semi-cycles to set the counter to count to get a frequency of 392.00 Hz
.equ LA		= 4189 ;N° of clock (4Mhz) semi-cycles to set the counter to count to get a frequency of 440.00 Hz
.equ SI		= 3732 ;N° of clock (4Mhz) semi-cycles to set the counter to count to get a frequency of 493.88 Hz
.equ DO2	= 3523 ;N° of clock (4Mhz) semi-cycles to set the counter to count to get a frequency of 523.25 Hz
.equ MUTE	= 61   ;N° of clock (4Mhz) semi-cycles to set the counter to count to get a frequency of 30 kHz
;--------------------------------------------------------------------------------------------------------------;

;----------------------------------------------------BUTTONS---------------------------------------------------;
.equ PULS0	= 0
.equ PULS1	= 1
.equ PULS2	= 2
.equ PULS3	= 3
.equ PULS4	= 4
.equ PULS5	= 5
.equ PULS6	= 6
.equ PULS7	= 7
;--------------------------------------------------------------------------------------------------------------;

; Replace with your application code

;Timer configuration
timer_config:
	;Timer configured with this settings:
	;	- Timer mode: CTC
	;	- No prescaling
	;	- Negative-edge triggered
	;	- Compare output mode: Toggle OC1A

	ldi r16, (0 << COM1A1) | (1 << COM1A0) | (0 << WGM11) | (0 << WGM10)
	out TCCR1A, r16
	clr r16

	ldi r16, (0 << ICES1) | (0 << WGM13) | (1 << WGM12) | (0 << CS12) | (0 << CS11) | (1 << CS10)
	out TCCR1B, r16
	clr r16

	;Load MUTE frequency
	ldi r17, 0x00
	ldi r16, MUTE

	out OCR1AH, r17
	out OCR1AL, r16

;Buttons configuration
buttons_config:
	
	;Buttons are ACTIVE LOW (?)

	;Set GPIO Mode to INPUT
	clr r16
	out DDRA, r16

	;PUllup resistors?? (Set PORTA to 1 in case)

button0:
	;Load DO1 frequency
	ldi r17, high(DO1)
	ldi r16, low(DO1)

	out OCR1AH, r17
	out OCR1AL, r16

	rjmp loop

button1:
	;Load RE frequency
	ldi r17, high(RE)
	ldi r16, low(RE)

	out OCR1AH, r17
	out OCR1AL, r16
	rjmp loop

button2:
	;Load MI frequency
	ldi r17, high(MI)
	ldi r16, low(MI)

	out OCR1AH, r17
	out OCR1AL, r16
	rjmp loop

button3:
	;Load FA frequency
	ldi r17, high(FA)
	ldi r16, low(FA)

	out OCR1AH, r17
	out OCR1AL, r16
	rjmp loop

button4:
	;Load SOL frequency
	ldi r17, high(SOL)
	ldi r16, low(SOL)

	out OCR1AH, r17
	out OCR1AL, r16
	rjmp loop

button5:
	;Load LA frequency
	ldi r17, high(LA)
	ldi r16, low(LA)

	out OCR1AH, r17
	out OCR1AL, r16
	rjmp loop

button6:
	;Load SI frequency
	ldi r17, high(SI)
	ldi r16, low(SI)

	out OCR1AH, r17
	out OCR1AL, r16
	rjmp loop

button7:
	;Load DO2 frequency
	ldi r17, high(DO2)
	ldi r16, low(DO2)

	out OCR1AH, r17
	out OCR1AL, r16
	rjmp loop

loop:
	;Button signal loaded in r16
	in r16, PINA
	
	sbrs r16, PULS0
	rjmp button0

	sbrs r16, PULS1
	rjmp button1

	sbrs r16, PULS2
	rjmp button2

	sbrs r16, PULS3
	rjmp button3

	sbrs r16, PULS4
	rjmp button4

	sbrs r16, PULS5
	rjmp button5

	sbrs r16, PULS6
	rjmp button6

	sbrs r16, PULS6
	rjmp button6

	;No pressed button Load MUTE frequency
		ldi r17, 0x00
		ldi r16, MUTE

		out OCR1AH, r17
		out OCR1AL, r16

	rjmp loop