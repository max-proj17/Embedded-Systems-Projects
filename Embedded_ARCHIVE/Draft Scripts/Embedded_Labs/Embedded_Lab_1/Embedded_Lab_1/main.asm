;
; Embedded_Lab_1.asm
;
; Created: 1/26/2023 3:32:23 PM
; Author : mfinch1
;


.include "m328Pdef.inc"
.cseg
.org 0

; Configure PB1 and PB2 as output pins.
sbi   DDRB,1      ; PB1 is now output
sbi   DDRB,2      ; PB2 is now output

; Main loop follows.  Toggle PB1 and PB2 out of phase.
; Assuming there are LEDs and current-limiting resistors
; on these pins, they will blink out of phase.
loop:
sbi   PORTB,1     ; LED at PB1 off
cbi   PORTB,2     ; LED at PB2 on
rcall delay_long  ; Wait
cbi   PORTB,1     ; LED at PB1 on
sbi   PORTB,2     ; LED at PB2 off

rcall delay_long  ; Wait
rjmp   loop


; Generate a delay using two nested loops that do "nothing".
; With a 16 MHz clock, the values below produce a ~4,194.24 ms delay.
;--------------------------------------------------------------------

.equ count = 43360				; assign a 16-bit value to symbol "count"

delay_long:
	ldi r30, low(count)	  	; r31:r30  <-- load a 16-bit value into counter register for outer loop
	ldi r31, high(count);
d1:
	ldi   r29, 49		    	; r29 <-- load a 8-bit value into counter register for inner loop
	d2:
		nop											; no operation
		dec   r29            		; r29 <-- r29 - 1
		brne  d2								; branch to d2 if result is not "0"
	sbiw r31:r30, 1					; r31:r30 <-- r31:r30 - 1
	brne d1									; branch to d1 if result is not "0"
ret											; return


.exit
