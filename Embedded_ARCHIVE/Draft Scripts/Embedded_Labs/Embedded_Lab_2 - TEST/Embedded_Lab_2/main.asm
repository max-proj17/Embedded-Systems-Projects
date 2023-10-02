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
ldi R16, 0x3F ; left bit
ldi R19, 0x3F ; right bit



main:
;ldi R24, 1 ;1 is dec on, 0 is dec off
rcall display_nums
   

;if first button pressed (increment or reset)
sbis PINB,3
rjmp stay_put

;if second button pressed (decrement)
sbis PINB,4
rjmp stay_put_2

rjmp main

switch_number:

	;increment register limit counter
	inc R20      
	cpi R19, 0x3F ;If 0 make 1
	breq become_1
	cpi R19, 0x06 ;If 1 make 2
	breq become_2
	cpi R19, 0x5B ;If 2 make 3
	breq become_3
	cpi R19, 0x4F ;If 3 make 4
	breq become_4
	cpi R19, 0x66 ;If 4 make 5
	breq become_5
	cpi R19, 0x6D ;If 5 make 6
	breq become_6
	cpi R19, 0x7D ;If 6 make 7
	breq become_7
	cpi R19, 0x07 ;If 7 make 8
	breq become_8
	cpi R19, 0x7F ;If 8 make 9
	breq become_9
	cpi R19, 0x67 ;If 9 make 0
	breq become_0

become_0:
	ldi R19, 0x3F
	rjmp switch_left
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

;check if leds are at 25
is_it_25:       
	
	cpi R20, 25        ;if its not 25, go to switch number
	brne switch_number 
	sbis PINB,3        ;If button pressed, go to 2 second reset loop
	rjmp reset_loop
	rjmp is_it_25	; If no button pressed, infinitely loop 

switch_left: ;Left digit
	;If 0 make 1
	cpi R16, 0x3F
	breq become_left_1
	;If 1 make 2
	cpi R16, 0x06
	breq become_left_2

stay_put_2:
	rcall delay_long      ;10ms delay
	cpi R24, 0
	breq main
	sbic PINB,4
	rcall decrement_call
	rjmp stay_put_2

become_left_1:
	ldi R16, 0x06
	rjmp main

become_left_2:
	ldi R16, 0x5B
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



.include "functions.asm"
.exit
