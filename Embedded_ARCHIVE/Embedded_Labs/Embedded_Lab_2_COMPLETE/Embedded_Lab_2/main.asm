;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Assembly Language file (1/2) for Lab 2 in ECE:3360
; Spring 2023, The University of Iowa
; Created: 2/4/2023 10:56:48 AM
; Author : Max Finch, Tiger Slowinski
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; put code here to configure I/O lines ; as output & connected to SN74HC595
.include "m328Pdef.inc"
.cseg
.org 0


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

ldi R24, 4
;set up 00
ldi R16, 0x3F ; right bit
ldi R19, 0x3F ; left bit


main:
ldi R24, 4
ldi R18, 0
rcall display ; call display subroutine
ldi R18, 1
rcall display

rcall delay_long

sbis PINB,3
rjmp stay_put

sbis PINB,4
rjmp stay_put_B

rjmp main

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

flash:

	ldi R20, 0
	cpi R24, 0
	breq main_set
	rcall flashing
	dec R24
	rjmp flash

main_set:
	ldi R16, 0x3F
	ldi R19, 0x3F
	rcall display_nums
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

stay_put_B:
	sbis PINB,4
	rjmp stay_put_B
	jmp check_25

reset_call_ii25:       ;reset the counter and go to is_it_25
	ldi R22, 0         ;reset counter
	rjmp is_it_25

is_it_25:              ;check if leds are at 25
	cpi R20, 25        ;if its not 25, go to switch number
	brne switch_number 
	sbis PINB,3        ;If button pressed, go to 2 second reset loop
	rjmp reset_loop
	sbic PINB,4
	rjmp is_it_25	   ;If no button pressed, infinitely loop 
	rjmp stay_put_B

reset_loop:
	sbic PINB,3		   ;If button released, go back to is_it_25
	rjmp reset_call_ii25
	rcall delay_long   ;10ms delay
	inc R22            ;Register for samples
	cpi R22, 20        ; If 20 reset
	breq set_leds_to_0 ;set leds back to 0
	rjmp reset_loop    ;continue to increment counter

set_leds_to_0:
	ldi R16, 0x3F ; right bit
	ldi R19, 0x3F ; left bit
	ldi R20, 0 ;reset counter
	ldi R22, 0 ;reset limit
	rcall delay_extra_long_2
	rjmp main


check_25:
	ldi R21,25
	cpse R20,R21
	rjmp check_24
	jmp _25
check_24:
	ldi R21,24
	cpse R20,R21
	rjmp check_23
	jmp _24
check_23:
	ldi R21,23
	cpse R20,R21
	rjmp check_22
	jmp _23
check_22:
	ldi R21,22
	cpse R20,R21
	rjmp check_21
	jmp _22
check_21:
	ldi R21,21
	cpse R20,R21
	rjmp check_20
	jmp _21
check_20:
	ldi R21,20
	cpse R20,R21
	rjmp check_19
	jmp _20
check_19:
	ldi R21,19
	cpse R20,R21
	rjmp check_18
	jmp _19
check_18:
	ldi R21,18
	cpse R20,R21
	rjmp check_17
	jmp _18
check_17:
	ldi R21,17
	cpse R20,R21
	rjmp check_16
	jmp _17
check_16:
	ldi R21,16
	cpse R20,R21
	rjmp check_15
	jmp _16
check_15:
	ldi R21,15
	cpse R20,R21
	rjmp check_14
	jmp _15
check_14:
	ldi R21,14
	cpse R20,R21
	rjmp check_13
	jmp _14
check_13:
	ldi R21,13
	cpse R20,R21
	rjmp check_12
	jmp _13
check_12:
	ldi R21,12
	cpse R20,R21
	rjmp check_11
	jmp _12
check_11:
	ldi R21,11
	cpse R20,R21
	rjmp check_10
	jmp _11
check_10:
	ldi R21,10
	cpse R20,R21
	rjmp check_9
	jmp _10
check_9:
	ldi R21,9
	cpse R20,R21
	rjmp check_8
	jmp _9
check_8:
	ldi R21,8
	cpse R20,R21
	rjmp check_7
	jmp _8
check_7:
	ldi R21,7
	cpse R20,R21
	rjmp check_6
	jmp _7
check_6:
	ldi R21,6
	cpse R20,R21
	rjmp check_5
	jmp _6
check_5:
	ldi R21,5
	cpse R20,R21
	rjmp check_4
	jmp _5
check_4:
	ldi R21,4
	cpse R20,R21
	rjmp check_3
	jmp _4
check_3:
	ldi R21,3
	cpse R20,R21
	rjmp check_2
	jmp _3
check_2:
	ldi R21,2
	cpse R20,R21
	rjmp check_1
	jmp _2
check_1:
	ldi R21,1
	cpse R20,R21
	jmp flash
	jmp _1
	
	

display_nums:
	ldi R18,0
	rcall display
	ldi R18,1
	rcall display
	ret

_25:
	ldi R16,0x5B
	ldi R19,0x6D
	call display_nums
	rcall delay_extra_long_2
	rjmp _24
_24:
	ldi R16,0x5B
	ldi R19,0x66
	call display_nums
	rcall delay_extra_long_2
	rjmp _23
_23:
	ldi R16,0x5B
	ldi R19,0x4F
	call display_nums
	rcall delay_extra_long_2
	rjmp _22
_22:
	ldi R16,0x5B
	ldi R19,0x5B
	call display_nums
	rcall delay_extra_long_2
	rjmp _21
_21:
	ldi R16,0x5B
	ldi R19,0x06
	call display_nums
	rcall delay_extra_long_2
	rjmp _20
_20:
	ldi R16,0x5B
	ldi R19,0x3F
	call display_nums
	rcall delay_extra_long_2
	rjmp _19
_19:
	ldi R16,0x06
	ldi R19,0x67
	call display_nums
	rcall delay_extra_long_2
	rjmp _18
_18:
	ldi R16,0x06
	ldi R19,0x7F
	call display_nums
	rcall delay_extra_long_2
	rjmp _17
_17:
	ldi R16,0x06
	ldi R19,0x07
	call display_nums
	rcall delay_extra_long_2
	rjmp _16
_16:
	ldi R16,0x06
	ldi R19,0x7D
	call display_nums
	rcall delay_extra_long_2
	rjmp _15
_15:
	ldi R16,0x06
	ldi R19,0x6D
	call display_nums
	rcall delay_extra_long_2
	rjmp _14
_14:
	ldi R16,0x06
	ldi R19,0x66
	call display_nums
	rcall delay_extra_long_2
	rjmp _13
_13:
	ldi R16,0x06
	ldi R19,0x4F
	call display_nums
	rcall delay_extra_long_2
	rjmp _12
_12:
	ldi R16,0x06
	ldi R19,0x5B
	call display_nums
	rcall delay_extra_long_2
	rjmp _11
_11:
	ldi R16,0x06
	ldi R19,0x06
	call display_nums
	rcall delay_extra_long_2
	rjmp _10
_10:
	ldi R16,0x06
	ldi R19,0x3F
	call display_nums
	rcall delay_extra_long_2
	rjmp _9
_9:
	ldi R16,0x3F
	ldi R19,0x67
	call display_nums
	rcall delay_extra_long_2
	rjmp _8
_8:
	ldi R16,0x3F
	ldi R19,0x7F
	call display_nums
	rcall delay_extra_long_2
	rjmp _7
_7:
	ldi R16,0x3F
	ldi R19,0x07
	call display_nums
	rcall delay_extra_long_2
	rjmp _6
_6:
	ldi R16,0x3F
	ldi R19,0x7D
	call display_nums
	rcall delay_extra_long_2
	rjmp _5
_5:
	ldi R16,0x3F
	ldi R19,0x6D
	call display_nums
	rcall delay_extra_long_2
	rjmp _4
_4:
	ldi R16,0x3F
	ldi R19,0x66
	call display_nums
	rcall delay_extra_long_2
	rjmp _3
_3:
	ldi R16,0x3F
	ldi R19,0x4F
	call display_nums
	rcall delay_extra_long_2
	rjmp _2
_2:
	ldi R16,0x3F
	ldi R19,0x5B
	call display_nums
	rcall delay_extra_long_2
	rjmp _1
_1:
	ldi R16,0x3F
	ldi R19,0x06
	call display_nums
	rcall delay_extra_long_2
	rjmp _0
_0:
	ldi R16,0x3F
	ldi R19,0x3F
	call display_nums
	rcall delay_extra_long_2
	rjmp flash



.include "AsmFile1.asm"
.exit





