;
; Embedded_Lab_2.asm
;
; Created: 2/4/2023 10:56:48 AM
; Author : mfinch1
;

; put code here to configure I/O lines ; as output & connected to SN74HC595
.include "m328Pdef.inc"
.cseg
.org 0


;equ defines names for shit

; Configure I/O lines.
sbi   DDRB,0      ; PB0 is now output (SER)
sbi   DDRB,1      ; PB1 is now output (SRCLK)
sbi   DDRB,2      ; PB2 is now output (RCLK)
cbi   DDRB,3      ; PB3 is now input (BUTTON)
cbi   DDRB,4	  ; PB4 is now input (BUTTON)

;R18 trigger bit
;R19 left bit
;R16 right bit

;set up limit
ldi R20, 0x00

;set up 00
ldi R16, 0x3F ; right bit
ldi R19, 0x3F ; left bit


main:

ldi R18, 0
rcall display ; call display subroutine
ldi R18, 1
rcall display

rcall delay_long

sbis PINB,3
rjmp stay_put


rjmp main



pulse_clock:
	sbi   PORTB,1
	cbi   PORTB,1
ret

pulse_latch:
	sbi   PORTB,2
	cbi   PORTB,2
ret

switch_left: ;Left digit
	;If 0 make 1
	cpi R16, 0x3F
	breq become_left_1
	;If 1 make 2
	cpi R16, 0x06
	breq become_left_2

become_left_1:
	ldi R16, 0x06
	rjmp main
become_left_2:
	ldi R16, 0x5B
	rjmp main


switch_number:

	;increment register limit counter
	inc R20

	;If 0 make 1
	cpi R19, 0x3F
	breq become_1

	;If 1 make 2
	cpi R19, 0x06
	breq become_2

	;If 2 make 3
	cpi R19, 0x5B
	breq become_3

	;If 3 make 4
	cpi R19, 0x4F
	breq become_4

	;If 4 make 5
	cpi R19, 0x66
	breq become_5

	;If 5 make 6
	cpi R19, 0x6D
	breq become_6

	;If 6 make 7
	cpi R19, 0x7D
	breq become_7

	;If 7 make 8
	cpi R19, 0x07
	breq become_8

	;If 8 make 9
	cpi R19, 0x7F
	breq become_9

	;If 9 make 0
	cpi R19, 0x67
	breq become_0




become_0:
	ldi R19, 0x3F
	rjmp switch_left
	rjmp main

become_1:
	ldi R19, 0x06
	rjmp main

become_2:
	ldi R19, 0x5B
	rjmp main

become_3:
	ldi R19, 0x4F
	rjmp main

become_4:
	ldi R19, 0x66
	rjmp main

become_5:
	ldi R19, 0x6D
	rjmp main

become_6:
	ldi R19, 0x7D
	rjmp main

become_7:
	ldi R19, 0x07
	rjmp main

become_8:
	ldi R19, 0x7F
	rjmp main

become_9:
	ldi R19, 0x67
	rjmp main

stay_put:
	rcall delay_long      ;10ms delay
	inc R22               ;Register for samples
	cpi R22, 20           ; If 20 reset
	breq set_leds_to_0    ;set leds back to 0
	sbic PINB,3           ;If button released continue to check if 25
	rjmp reset_call_ii25  ; If its released reset the counter and go to is_it_25
	rjmp stay_put         ;If no button released loop stay_put

;reset the counter and go to is_it_25
reset_call_ii25:
	ldi R22, 0 ;reset counter
	rjmp is_it_25


;check if leds are at 25
is_it_25:       
	
	cpi R20, 25        ;if its not 25, go to switch number
	brne switch_number 
	sbis PINB,3        ;If button pressed, go to 2 second reset loop
	rjmp reset_loop
	rjmp is_it_25	; If no button pressed, infinitely loop 



reset_loop:
	sbic PINB,3    ;If button released, go back to is_it_25
	rjmp reset_call_ii25
	rcall delay_long ;10ms delay
	inc R22          ;Register for samples
	cpi R22, 20       ; If 20 reset
	breq set_leds_to_0  ;set leds back to 0
	rjmp reset_loop  ;continue to increment counter


set_leds_to_0:
	ldi R16, 0x3F ; right bit
	ldi R19, 0x3F ; left bit
	ldi R20, 0 ;reset counter
	ldi R22, 0 ;reset limit
	rcall delay_extra_long
	rjmp main



delay_extra_long:
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	rcall delay_long
	ret



display: ; backup used registers on stack
	sbrs R18, 0
	mov R13, R19 
	sbrc R18, 0
	mov R13, R16
	;Change all R16 below to R13

	push R13
	push R17
	in R17, SREG
	push R17
	ldi R17, 8 ; loop --> test all 8 bits
loop:
	rol R13 ; rotate left trough Carry
	BRCS set_ser_in_1 ; branch if Carry is set
	; put code here to set SER to 0
	cbi PORTB,0
	rjmp end
set_ser_in_1:
    ; put code here to set SER to 1...
	sbi PORTB,0
end:
	; put code here to generate SRCLK pulse...
	rcall pulse_clock
	dec R17
	brne loop
	; put code here to generate RCLK pulse
	rcall pulse_latch
	; restore registers from stack
	pop R17
	out SREG, R17
	pop R17
	pop R13
	ret  


.equ count = 8502				; assign a 16-bit value to symbol "count"

delay_long:
	ldi r30, low(count)	  	; r31:r30  <-- load a 16-bit value into counter register for outer loop
	ldi r31, high(count);
d1:
	ldi   r29, 31		    	; r29 <-- load a 8-bit value into counter register for inner loop
	d2:
		nop											; no operation
		dec   r29            		; r29 <-- r29 - 1
		brne  d2								; branch to d2 if result is not "0"
	sbiw r31:r30, 1					; r31:r30 <-- r31:r30 - 1
	brne d1									; branch to d1 if result is not "0"
ret											; return


.exit





