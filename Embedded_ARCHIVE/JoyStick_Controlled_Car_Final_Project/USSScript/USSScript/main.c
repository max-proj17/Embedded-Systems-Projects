/*
 * USSScript.c
 *
 * Created: 4/29/2023 8:15:27 PM
 * Author : Tiger Slowinski
 */ 

#include <avr/io.h>
#include <stdlib.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include "twimaster.c"

#define F_CPU 16000000

#define TRIG_PIN PD2   // Trigger pin (digital output)
#define ECHO_PIN PD3   // Echo pin (digital input)
#define MAX_DISTANCE 3050 // Maximum distance in centimeters (30.5 cm = 3050)
#define DAC 0x58

volatile uint8_t timerOverflow = 0;
volatile uint32_t pulseDuration = 0;



ISR(TIMER1_OVF_vect) {
	timerOverflow++;
	
}

void init_HC_SR04() {
	DDRD |= (1 << TRIG_PIN);   // Set trigger pin as output
	DDRD &= ~(1 << ECHO_PIN);  // Set echo pin as input
	TCCR1B |= (1 << CS10);     // Enable timer with prescaler = 1
	TIMSK1 |= (1 << TOIE1);    // Enable timer overflow interrupt
}

uint32_t pulseIn() {
	pulseDuration = 0;
	timerOverflow = 0;
	PORTD &= ~(1 << TRIG_PIN);  // Set trigger pin low
	_delay_us(2);
	PORTD |= (1 << TRIG_PIN);   // Set trigger pin high for 10 us
	_delay_us(10);
	PORTD &= ~(1 << TRIG_PIN);  // Set trigger pin low
	while (!(PIND & (1 << ECHO_PIN))) {
		 if(timerOverflow > 1) // Timeout after 100ms
		 {
			 return 0;
		 }
	}  // Wait for echo pin to go high
	TCNT1 = 0;                  // Reset timer count
	TIFR1 |= (1 << TOV1);       // Clear timer overflow flag
	TIMSK1 |= (1 << TOIE1);     // Enable timer overflow interrupt
	sei();                      // Enable global interrupts
	while ((PIND & (1 << ECHO_PIN))) {  // Wait for echo pin to go low
		if (timerOverflow > 1) {    // If no echo, exit loop after timeout
			TIMSK1 &= ~(1 << TOIE1);  // Disable timer overflow interrupt
			cli();    // Disable global interrupts
			return 0;
		}
	}
	TIMSK1 &= ~(1 << TOIE1);    // Disable timer overflow interrupt
	cli();    // Disable global interrupts
	pulseDuration = timerOverflow * 65536UL + TCNT1;
	return pulseDuration;
}

int main(void)
{
	
	init_HC_SR04();
	float voltage = 0.00;
	int distScaled = 0; 
	
	while (1) {
		uint32_t pulseDuration = pulseIn();
		uint32_t distance = pulseDuration/58/13; //70.6; // Calculate distance in centimeters
		//distance = (distance / 3050.0f) * 12.0f;
		
		//oscillator uses 0.7 to 5V input voltages from DAC, and range of accurate readings from ultrasonic sensor is 3 to 60cm. Conversions between ranges done below
		if(distance >= 60)
		{
			voltage = 0.00;
		}else
		{
			distScaled = distance - 3; //range is now from 0 to 57
			voltage = distScaled * 0.0754; //output voltage to oscillator must be between 0.7 and 5 volts, equivalent to 0 to 4.3V. Scaling distScaled down to this range => 0.43/57 = 0.0754
			voltage = voltage + 0.7; //voltage is now a range between 0.7 and 5
		}
		
		if(distance <= 3)
		{
			voltage = 0.70; //if less than 3cm from an object, pitch will not increase further
		}
		
		int final_int = voltage * 51; //scaling to an 8 bit value to be understood by DAC
		
		i2c_start(DAC);
		i2c_write(0);   //output channel
		i2c_write(final_int);
		i2c_stop();
		
		
		_delay_ms(500);   // Delay between measurements
	}
	return 0;
}

