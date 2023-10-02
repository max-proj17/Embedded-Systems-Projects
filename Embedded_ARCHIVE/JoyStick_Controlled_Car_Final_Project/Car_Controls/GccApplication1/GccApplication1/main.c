/*
 * Thermicar.c
 *
 * Created: 4/22/2023 9:23:37 PM
 * Author : maxfi
 */ 
#include <avr/io.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
//#include <nRF24L01.h>
#include <stdbool.h>
#include <util/delay.h>
#define FOSC 16000000 // Clock Speed
#define BAUD 9600
#define F_CPU 16000000
#define MYUBRR FOSC/16/BAUD-1
//


void USART_Init( unsigned int ubrr)
{
	///*Set baud rate */
	UBRR0H = (unsigned char)(ubrr>>8);
	UBRR0L = (unsigned char)ubrr;
	/*Enable receiver and transmitter */
	UCSR0B = (1<<RXEN0)|(1<<TXEN0);
	/* Set frame format: 8data, 2stop bit */
	UCSR0C = (1<<USBS0)|(3<<UCSZ00);
}
void USART_Transmit( unsigned char data )
{
	/* Wait for empty transmit buffer */
	while ( !( UCSR0A & (1<<UDRE0)) )
	;
	/* Put data into buffer, sends the data */
	UDR0 = data;
}
unsigned char USART_Receive( void )
{
	/* Wait for data to be received */
	while ( !(UCSR0A & (1<<RXC0)) );
	/* Get and return received data from buffer */
	//Dtostrf
	return UDR0;
}
void PWM_Setup(void)
{
	// Set pin 9 as output
	//DDRB |= (1 << PORTB1);

	// Set Timer1 for 8-bit Fast PWM mode
	TCCR1A |= (1<<COM1B1) | (1<<COM1A1) | (1<<WGM11) | (1<<WGM10); // set PWM mode with ICR1 as TOP and enable PWM outputs on OC1A and OC1B
	TCCR1B |= (1<<WGM12) | (1<<CS10); // set PWM mode with ICR1 as TOP and no prescaling
	// Set the prescalar to 64
	//TCCR1B |= (1 << CS11) | (1 << CS10);
	//0 duty cycle initially? A is 9 B is 10

	// Set the TOP value to 1023
	ICR1 = 400;
	// 1000-> 600 and 400
	//
	// Set the duty cycle of motor 1 to 0% 
	OCR1A = 0;
	//Set the duty cycle of motor 2 to 0%
	OCR1B = 0;


}
//80 might be motors min PWM   was 200 + 800 for 1000
int ADC_To_PWM(int x, int v) {
	
	float result;
	if(v==1)
	{
		result = 600 + 400.0 * (1.0 - exp(-4.0 * pow(x-506.0, 2.0) / pow(506.0, 2.0)));
	}else if (v==2)
	{
		result = 600 + 400.0 * (1.0 - exp(-4.0 * pow(x-510.0, 2.0) / pow(510.0, 2.0)));
	}
	
	return (int)round(result);
}
int num = 1;
void update_Motors(void)
{
	//A0 and A1 are for joystick control
	int ADC1;
	int ADC2;
	//OCR1A motor 1, OCR1B motor 2
	
	//read first joystick and get new DC
	read_ADC(0);
	ADC1 = ADC;
	OCR1A = ADC_To_PWM(ADC1, 1);
	
	//read second joystick and get new DC
	read_ADC(1);
	ADC2 = ADC;   
	OCR1B = ADC_To_PWM(ADC2, 2);
	
	//Update motor spin direction
	Motor_Direction(1, ADC1);
	Motor_Direction(2, ADC2);
	
	
	
	
}
void Motor_Direction(int motor_num, int ADCn)
{	/*
	USART_Transmit('M');
	USART_Transmit(num+'0');
	USART_Transmit(':');
	USART_Transmit(' ');
	*/
    //PB0,PD3 go to motor 1, PD6,PD7 go to motor 2, PB1 & PB2 are CLK pins
	if(((motor_num==1)&&(ADCn == 506))||((motor_num==2)&&(ADCn == 510)))
	{
		//stop motor
		if(motor_num == 1)
		{
			//USART_Transmit('1');
			//USART_Transmit('S');
			PORTB &= ~(1 << PORTB0);
			PORTD &= ~(1 << PORTD3);
		}else if(motor_num == 2)
		{
			//USART_Transmit('2');
			//USART_Transmit('S');
			PORTD &= ~((1 << PORTD6)|(1 << PORTD7));
		}
		//<
	}else if(((motor_num==1)&&(ADCn < 506))||((motor_num==2)&&(ADCn < 510)))
	{
		//USART_Transmit('F');
	
		//Go "Forward"
		if(motor_num == 1)
		{
			//USART_Transmit('1');
			//USART_Transmit('F');
			PORTD |= (1 << PORTD3);
			PORTB &= ~(1 << PORTB0);
		}else if(motor_num == 2)
		{
			//USART_Transmit('2');
			//USART_Transmit('F');
			PORTD |= (1 << PORTD6);
			PORTD &= ~(1 << PORTD7);
		}
		
	}else if(((motor_num==1)&&(ADCn > 506))||((motor_num==2)&&(ADCn > 510)))
	{
		//USART_Transmit('B');
		//Go "Backward"
		if(motor_num == 1)
		{
			//USART_Transmit('1');
			//USART_Transmit('B');
			PORTD &= ~(1 << PORTD3);
			PORTB |=  (1 << PORTB0);
			
		}else if(motor_num == 2)
		{
			//USART_Transmit('2');
			//USART_Transmit('B');
			PORTD &= ~(1 << PORTD6);
			PORTD |=  (1 << PORTD7);
		}
		
	}
	//USART_Transmit(' ');
	
}

void ADC_Init(void)
{
	//ADMUX = (1<<REFS0); //set to VCC and to A0
	ADCSRA = (1<<ADEN) | (1<<ADPS2) | (1<<ADPS1) | (1<<ADPS0);
	
}
void read_ADC(int PIN_num)
{
	if(PIN_num == 0)
	{
		ADMUX = 0x40;
	}else if(PIN_num = 1)
	{
		ADMUX = 0x41;
	}
	ADCSRA = ADCSRA | (1<<ADSC);

	while (!(ADCSRA & (1 << ADIF)));
	ADCSRA |= 1 << ADIF;
	
}



int main(void)
{
	ADC_Init();
	USART_Init(MYUBRR);
	DDRB |= 0x3F; //Pin PB0,1,2,3 are outputs
	DDRD |= 0xF8;
	PWM_Setup();
	PORTB = 0x00;
	PORTD = 0x00;
	
	while(1)
	{
		update_Motors();
		
		/*
	   unsigned char c = USART_Receive();
	   
	   if ( c == ';')
	   {
		   update_Motors();
	   }
	   
		*/	
	}
	
	
}
