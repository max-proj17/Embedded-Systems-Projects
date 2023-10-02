;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Assembly Language file for lab 4 in ECE:3360
; Spring 2023, The University of Iowa
; Authors : Max Finch, Tiger Slowinski
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.include "m328Pdef.inc"

.cseg
.org 0x0000

; We don't want the following lines to run. They should just reserve bytes in program memory  
rjmp skip

.org 0x0002     ; Interrupt INT1
    jmp button_p
.org 0x0006     ; Interrupt PCINT0
	jmp rpg_change 
.org 0x0008
	

; indexing starts at 4 because "1" is located at 0x0004, ik it sucks ; starts at memory loc 8 ends at 107
num:   .DB "1",0, "2",0, "3",0, "4",0, "5",0, "6",0, "7",0, "8",0, "9",0, "1", "0"
    .DB "1","1", "1","2", "1","3", "1","4", "1","5", "1","6", "1","7", "1","8", "1","9"
    .DB "2","0", "2","1", "2","2", "2","3", "2","4", "2","5", "2","6", "2","7", "2","8", "2","9"
    .DB "3","0", "3","1", "3","2", "3","3", "3","4", "3","5", "3","6", "3","7", "3","8", "3","9"
    .DB "4","0", "4","1", "4","2", "4","3", "4","4", "4","5", "4","6", "4","7", "4","8", "4","9"
    .DB "5","0", "5","1", "5","2", "5","3", "5","4", "5","5", "5","6", "5","7", "5","8", "5","9"
    .DB "6","0", "6","1", "6","2", "6","3", "6","4", "6","5", "6","6", "6","7", "6","8", "6","9"
    .DB "7","0", "7","1", "7","2", "7","3", "7","4", "7","5", "7","6", "7","7", "7","8", "7","9"
    .DB "8","0", "8","1", "8","2", "8","3", "8","4", "8","5", "8","6", "8","7", "8","8", "8","9"
    .DB "9","0", "9","1", "9","2", "9","3", "9","4", "9","5", "9","6", "9","7", "9","8", "9","9"
    .DB "1","0","0", 0

; Strings to be displayed on LCD
msg: .DB " DC = " 
msgg: .DB " Fan: "
off: .DB "OFF "
on: .DB "ON  "
perc: .DB "% "
	  .DW 0 

skip:
; Grounded pins: PIN_5: R/W (Read/Write), PIN_1: GND (Ground), Vee (1K resistor)
; Powered pins: PIN_2: Vcc (Supply), Vee (10K resistor)

ldi R16, 0xFF    ; Load 0xFF (binary 11111111) into R16
out DDRC, R16    ; Set all PORTC pins as outputs
			     ; PC0 is D4, PC1 is D5, PC2 is D6, PC3 is D7
sbi   DDRB,5     ; PB5 is R/S
sbi   DDRB,3     ; PB3 is Enable 
cbi   DDRB,0     ; PB0 is (Rotary A)
cbi   DDRB,1     ; PB1 is (Rotary A)
cbi   DDRD,2     ; PD2 is pushbutton

.def numClocks = R21   ; sets the clock value for delay
.def setup_hex = R22   ; numClock values: 0x64 -> 10ms, 0xB2 -> 5ms, 0xFD -> 200us, for 100ms, do 10ms 10 times


PWM_init:
	ldi r17, (1<<COM2B1)|(1<<WGM21)|(1<<WGM20);
	sts TCCR2A,r17 ; 8 bit PWM non-inverted
	ldi r17,(1<<CS20) | (1<<WGM22)
	sts TCCR2B,r17 ; Timer clock = I/O clock
	ldi r17,50 ;50% duty cycle        3F-> 50% duty cycle
	sts OCR2B,r17 ; Set compare value/duty cycle ratio
	sbi DDRD, PORTD3 ; Set OC2B pin as output
	ldi r17,101
	sts OCR2A,r17
	
; Set pinchange interrupt for RPG
lds r16, PCICR
ori r16, 0b00000101
sts PCICR, r16
lds r16, PCMSK0
ori r16, 0b00000011
sts PCMSK0, r16

;Set Ext Int for Pushbutton
lds r16, EICRA
ori r16, 0b00000010
sts EICRA, r16 
in r16, EIMSK
ori r16, 0b00000001
out EIMSK, r16 

; This subroutine initalizes the LCD to 4-bit mode and displays the default boot
; strings. 
; DC = 1  %
; FAN = ON
start_seq:

	rcall _8bit_initialization

	rcall _4bit_initialization
	cbi PORTB, 3   ;enable
	ldi R16, 4 ; start at 1%, memory starts at  4 x (offset=2) = 0x0008
	ldi R26, 1 ; length of string for variable string
	ldi r28, 1 ; R28=1 The FAN is ON, R28=0 the FAN is OFF


	rcall update_dis

	;moves cursor to second line and displays "on"
	rcall status_cursor                                    
	ldi R30, LOW(2*on)
	ldi R31, HIGH(2*on)
	ldi R24, 2           ; Length of the string
	rcall displayCString
	rcall delay_10ms
	

sei

;This code starts the fan at 50% DC for the DISPLAY. The actual DC is set
;to 50 in PWM_init. We loop 54 times because R16 is offset by 4, and must 
;correct it.
_54_times:
ldi r23, 54
loop:
cpi r23, 1
breq main
dec r23
inc R16
rcall update_DC
rjmp loop

; main simply waits for an interrupt to be invoked
main:
	nop
	nop
	nop
	rjmp main

;Moves cursor to where percent sign should be
perc_cursor:
    cbi PORTB, 5        ; making RS -> 0 for commands
	cbi PORTB, 3        ; Enable low                                      

	; Shift cursor to home position
	ldi R17, 0b1000   
	out PORTC, R17        ; Send command to LCD (RS = 0)
	rcall strobe_enable
	rcall delay_200us       ; Wait for instruction to complete
	; Send command again to configure the high nibble
	ldi R17, 0b1001
	out PORTC, R17        
	rcall strobe_enable
	sbi PORTB, 5        ; making RS -> 1 for sending data
	ret

; Moves cursor to where the numerical value of duty cycle should be and updates it,
; We use an lsl on r16 to get the right address of the string value with the offset.
; EX: We want the character "1" which is located at 0x0008. 4 will be in r16  
; and the lsl will perform a logical shift left, which is the same as multiplying by 2
update_DC:
	rcall dc_cursor                                    

	;updates the string representation of the number by moving the pointer

	lsl r16       ; multiply by 2
    ldi r30, LOW(num)
    ldi r31, HIGH(num)
    add r30, r16 ; add index to string start address
    adc r31, r1 ; carry to high byte
	mov R24, R26
	rcall displayCString
	lsr r16          ; divide by 2
	
	rcall delay_10ms

	ret
; When button is pressed we check whether the fan was previously on or off
; with R28. R27 updates the pwm with the value of (the pointer) - (offset in memory (3))
; if the fan is being turned on. If its being turned off R27 is loaded with 0, (r7)    
button_p:
	cli
	mov r27, r16
	subi r27, 3
	inc r28 
	sbrs r28,0
	rjmp  fan_off        ;turn off fan -> set r28 to 0
	rjmp  fan_on        ;turn on fan -> set r28 to 1

fan_on:
	sts OCR2B,r27
	rcall status_cursor                                    

	ldi R30, LOW(2*on)
	ldi R31, HIGH(2*on)
	ldi R24, 3   ; Length of the string
	rcall displayCString

	rcall delay_10ms
	reti
fan_off:
	sts OCR2B, r7
	rcall status_cursor                                    

	ldi R30, LOW(2*off)
	ldi R31, HIGH(2*off)
	ldi R24, 3   ; Length of the string
	rcall displayCString

	rcall delay_10ms

	reti

; Moving cursor to where on/off is displayed
status_cursor:
	cbi PORTB, 5        ; making RS -> 0 for commands
	cbi PORTB, 3        ; Enable low                                      

	ldi R17, 0b1100   
	out PORTC, R17        ; Send command to LCD (RS = 0)
	rcall strobe_enable
	rcall delay_200us       ; Wait for instruction to complete
	; Send command again to configure the high nibble
	ldi R17, 0b0110
	out PORTC, R17      
	rcall strobe_enable
	sbi PORTB, 5        ; making RS -> 1 for commands
	ret

off_f:
sts OCR2B, r7
rjmp goto_ret
on_o:
sts OCR2B,r27
rjmp goto_ret

check_fan:
mov r27, r16
subi r27, 3
cpi r28, 0
breq off_f
cpi r28, 1
breq on_o
goto_ret:
ret

; The following is the ISR (Interrupt Service Routine) for the RPG,
; which utilizes a pin change interrupt. When a pin is changed r18
; will be updated with the new values from pins A and B from the RPG
; when r18 becomes filled with a right or left turn pattern, the subroutine
; will branch to either the CW or CCW subroutines respectively. These
; routines will update the Duty Cycle LCD value and the PWM on Timer2
; by incrementing or decrementing those values

rpg_change:
; PB0 is (Rotary A)
; PB1 is (Rotary B)
; current values of r18 are checked with the left turn or right turn bit pattern
cli
lsl r18
lsl r18
sbic PINB, 0
sbr r18, 1
sbic PINB, 1
sbr r18, 2

cpi r18, 0b00011110
breq CW
cpi r18, 0b00101101
breq CCW
reti

CW:                 ; increment
	cpi R16, 12
	breq inc_num_len
	cpi R16, 103
	breq inc_num_len
	cpi R16, 104
	breq reti_s    ;breq to a reti
mark_1:
	inc R16
	rcall check_fan
	rcall update_DC
	reti

CCW:
	cpi R16, 104
	breq dec_num_len
	cpi R16, 13   
	breq dec_num_len
	cpi R16, 4
	breq reti_s
mark_2:
	dec R16
	rcall check_fan
	rcall update_DC
	reti

inc_num_len:
	inc R26
	rjmp mark_1

dec_num_len:
	dec R26
	rjmp mark_2

reti_s:

reti

; Update display sets the strings that will be static throughout the
; program as well as the initial DC value
update_dis:
    
	ldi R30, LOW(2*msg)
	ldi R31, HIGH(2*msg)
	ldi R24, 6   ; Length of the string
	rcall displayCString

	rcall delay_10ms

	lsl r16       ; multiply by 2
    ldi r30, LOW(num)
    ldi r31, HIGH(num)
    add r30, r16 ; add index to string start address
    adc r31, r1 ; carry to high byte
	mov R24, R26
	rcall displayCString
	lsr r16          ; divide by 2
	 
	rcall delay_10ms
	rcall perc_cursor
	rcall delay_10ms

	ldi R30, LOW(2*perc) ;  Percent sign
	ldi R31, HIGH(2*perc)
	ldi R24, 1   ; Length of the string
	rcall displayCString

	rcall delay_10ms
	rcall shift_cursor
	rcall delay_10ms

	ldi R30, LOW(2*msgg)
	ldi R31, HIGH(2*msgg)
	ldi R24, 6   ; Length of the string
	rcall displayCString
	ret

; Moves the LCD cursor to where the DC value should be
dc_cursor:
    cbi PORTB, 5        ; making RS -> 0 for commands
	cbi PORTB, 3        ; Enable low                                      

	; Shift cursor to home position
	ldi R17, 0b1000   
	out PORTC, R17        ; Send command to LCD (RS = 0)
	rcall strobe_enable
	rcall delay_200us       ; Wait for instruction to complete
	; Send command again to configure the high nibble
	ldi R17, 0b0110
	out PORTC, R17        ; Send command to LCD (RS = 0)
	rcall strobe_enable
	sbi PORTB, 5        ; making RS -> 1 for data
	ret

; Moves the LCD cursor to the second line (used only for initialization)
shift_cursor:
    cbi PORTB, 5        ; making RS -> 0 for commands
	cbi PORTB, 3        ; Enable low
	
	ldi R16, 0b1100   
	out PORTC, R16        ; Send command to LCD (RS = 0)
	rcall strobe_enable
	rcall delay_200us       ; Wait for instruction to complete
	; Send command again to configure the high nibble
	ldi R16, 0b0000
	out PORTC, R16        ; Send command to LCD (RS = 0)
	rcall strobe_enable
	sbi PORTB, 5        ; making RS -> 1 for data
	
	ret
	
; DisplayCString sends the string data to the data pins of
; the LCD. It swaps twice to get the lower 4 and high 4 bits of the 
; string since the LCD is operating in 4-bit mode.
displayCString:
sbi PORTB, 5
L20:
		lpm
		swap R0
		out PORTC, R0
		rcall strobe_enable
		rcall delay_200us
		swap R0
		out PORTC, R0
		rcall strobe_enable
		rcall delay_200us
		adiw ZH:ZL,1
		dec R24
		brne L20
		ret

; This subroutine is run before _4bit_initalization as it is best
; practice (and safest) to initalize the LCD in 8-bit mode and THEN 4-bit
; mode.

_8bit_initialization:

	cbi PORTB, 5        ; making RS -> 0 for commands
	cbi PORTB, 3        ; Enable low

	rcall delay_100ms     ; 1

	ldi R16, 0x03         ; 2 and 3
	out PORTC, R16       
	rcall strobe_enable
	rcall delay_5ms 

	ldi R16, 0x03         ; 4 and 5
	out PORTC, R16       
	rcall strobe_enable
	rcall delay_200us

	ldi R16, 0x03         ; 6 and 7
	out PORTC, R16       
	rcall strobe_enable
	rcall delay_200us

	ldi R16, 0x02         ; 8 and 9
	out PORTC, R16       
	rcall strobe_enable
	rcall delay_5ms

	ret

; This subroutine initalizes the LCD into 4-bit
; mode. 
_4bit_initialization:

	cbi PORTB, 5        ; making RS -> 0 for commands
	cbi PORTB, 3        ; Enable low

	; Write command "Set interface" (Write 28 hex (4-Bits, 2-lines)
	ldi R16, 0b0010   
	out PORTC, R16        
	rcall strobe_enable
	rcall T      
	ldi R16, 0b1000
	out PORTC, R16        
	rcall strobe_enable
     
	; Write command "Enable Display/Cursor"(Write 08 hex (don't shift display, hide cursor))
	ldi R16, 0b0000      
	out PORTC, R16        
	rcall strobe_enable
	rcall delay_200us     
	ldi R16, 0b1001		
	out PORTC, R16        
	rcall strobe_enable

	; Write command "Clear and Home"(Write 01 hex (clear and home display))
	ldi R16, 0b0000  
	out PORTC, R16        
	rcall strobe_enable
	rcall delay_200us       
	ldi R16, 0b0001   
	out PORTC, R16       
	rcall strobe_enable

	; Write command "Set Cursor Move Direction" (Write 06 hex (move cursor right))
	ldi R16, 0b0000   
	out PORTC, R16        
	rcall strobe_enable
	rcall delay_200us       
	ldi R16, 0b0110   
	out PORTC, R16        
	rcall strobe_enable

	; After this the display is ready to accept data (Write 0C hex (turn on display))
	ldi R16, 0b0000   
	out PORTC, R16       
	rcall strobe_enable
	rcall delay_200us      
	ldi R16, 0b1100   
	out PORTC, R16        
	rcall strobe_enable
ret

; Strobing enable allows for new data to enter the LCD via the displayCString subroutine	
strobe_enable:
    sbi PORTB, 3          ; Enable high
	nop
	nop
	nop
	nop
	nop
    cbi PORTB, 3          ; Enable low
	rcall delay_2ms
	ret

	
delay_100ms:
	rcall delay_10ms
	rcall delay_10ms
	rcall delay_10ms
	rcall delay_10ms
	rcall delay_10ms
	rcall delay_10ms
	rcall delay_10ms
	rcall delay_10ms
	rcall delay_10ms
	rcall delay_10ms
	ret

delay_10ms:
	ldi numClocks, 0x64        ;100 (base 10) is loaded to counter register
	rcall delay
	ret
delay_5ms:
	ldi numClocks, 0xB2
	rcall delay
	ret
delay_200us:
	ldi numClocks, 0xFD
	rcall delay
	ret
delay_2ms:
	ldi numClocks, 0xE0
	rcall delay
	ret

; Base delay generator for the entire program. Uses timer0
delay:        
	out TCNT0, numClocks       
	ldi numClocks, 0b00000101  ;starts clock in normal mode, prescaler 1024
	out TCCR0B, numClocks
again:
	in numClocks, TIFR0       
	sbrs numClocks, TOV0       ;skip if overflow flag is set
	rjmp again
	ldi numClocks, 0x00       
	out TCCR0B, numClocks      ;stops timer
	ldi numClocks, (1<<TOV0)   
	out TIFR0, numClocks       ;reset flag bit
	ret



	.exit
