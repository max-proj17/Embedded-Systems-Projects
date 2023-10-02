/*
 * Lab5CProj.c
 *
 * Created: 4/17/2023 4:17:00 PM
 * Author : tslowinski
 */ 


/*
 * LAB5.cpp
 *
 * Created: 4/10/2023 12:52:52 PM
 * Author : mfinch1
 */ 

#include <avr/io.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "twimaster.c"
#include <util/delay.h>

#define FOSC 16000000 // Clock Speed
#define BAUD 9600
#define MYUBRR FOSC/16/BAUD-1
#define DAC 0x58


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

void ADC_Init(void)
{
	ADMUX = (1<<REFS0); //set to VCC and to A0
	ADCSRA = (1<<ADEN) | (1<<ADPS2) | (1<<ADPS1) | (1<<ADPS0);
	
	
}
void get_ADC(void)
{
	ADCSRA = ADCSRA | (1<<ADSC);
	//while(ADSC == 1){};

	while (!(ADCSRA & (1 << ADIF)));
	ADCSRA |= 1 << ADIF;
	
	float ADC_val = (ADC*5.0/1024.0);
	char buffer[7];
	dtostrf(ADC_val,4,2,buffer);
	USART_Transmit('v');
	USART_Transmit('=');
	for(int i = 0; i < sizeof(buffer); i++){
		USART_Transmit(buffer[i]);
	}
	USART_Transmit(' ');
	USART_Transmit('V');
	USART_Transmit(' ');
}
unsigned char data[11];
int sinn[] = {128,141,153,165,177,188,199,209,219,227,234,241,246,250,254,255,255,255,254,250,246,241,234,227,219,209,199,188,177,165,153,141,128,115,103,91,79,68,57,47,37,29,22,15,10,6,2,1,0,1,2,6,10,15,22,29,37,47,57,68,79,91,103,115};

void W_command()
{
	//USART_Transmit('s');
	//USART_Transmit('u');
	int out = data[2]-'0';
	int x = 0;
	int r;
	if(data[8] == ' ') //single digit
	{
		r = data[7]-'0';
		x =1;
		//USART_Transmit(r + '0');
		
	}else if(data[9] == ' ') //two digits
	{
		int i = data[7]-'0';
		i = i*10;
		int j = data[8]-'0';
		r = i+j;
		x = 2;
		
	}else  //else three digits
	{
		int i = (data[7]-'0')*100;
		int j = (data[7]-'0')*10;
		int k = data[8] - '0';
		r = i+j+k;
		x = 3;
	}
	
	char msg [] = {'G','e','n','e','r','a','t','i','n','g',' ' };
	for(int i = 0; i < sizeof(msg); i++){
		USART_Transmit(msg[i]);
	}
	char msggg [x];
	itoa(r, msggg, 10);
	for(int i = 0; i < sizeof(msggg); i++){
		USART_Transmit(msggg[i]);
	}
	char msgg[] = {' ','s','i','n','e',' ','w','a','v','e',' ','c','y','c','l','e','s',' ','w','i','t','h',' ','f','='};
	for(int i = 0; i < sizeof(msgg); i++){
		USART_Transmit(msgg[i]);
	}
	USART_Transmit(data[4]);
	USART_Transmit(data[5]);
	USART_Transmit(' ');
	char msgggg[] = {'H','z',' ','o','n',' ','D','A','C',' ','c','h','a','n','n','e','l',' '};	
	for(int i = 0; i < sizeof(msgggg); i++){
		USART_Transmit(msgggg[i]);
	}
	USART_Transmit(data[2]);
	for(int i=0; i<r; i++)
	{
		//USART_Transmit('u');
		for(int j=0; j<(sizeof(sinn)/2); j++)
		{
			i2c_start(DAC);
			i2c_write(out);
			i2c_write(sinn[j]);
			if(data[4] == '1'){_delay_us(1250);} //was 1250
			if(data[4] == '2'){_delay_us(500);}  //was 500
			//_delay_ms(dms);
			i2c_stop();
		}
	}
	//USART_Transmit('a');
	//i2c_stop();
	
}

void S_command()
{

	int out = data[2]-'0';
	
	char fltstr[5];
	strncpy(fltstr, data + 4, 4);
	fltstr[4] = 0;
	//float final_val = atof(fltstr);
	
	//float num1 = data[4]-'0';
	//float num2 = (data[6]-'0')/10.0;
	//float num3 = (data[7]-'0')/100.0;

	//float final_val = num1 + num2 + num3;
	float final_val = atof(fltstr);
	int final_int = final_val*51;
	
	i2c_start(DAC);
	i2c_write(out);   //0 or 1
	i2c_write(final_int);
	i2c_stop();
	char msg [] = {'D','A','C',' ','c','h','a','n','n','e','l',' '};
	for(int i = 0; i < sizeof(msg); i++){
		USART_Transmit(msg[i]);
	}
	USART_Transmit(data[2]);
	char msgg [] = {' ','s','e','t',' ', 't', 'o',' '};
	for(int i = 0; i < sizeof(msgg); i++){
		USART_Transmit(msgg[i]);
	}
	USART_Transmit(data[4]);
	USART_Transmit(data[5]);
	USART_Transmit(data[6]);
	USART_Transmit(data[7]);	
	USART_Transmit(' ');
	USART_Transmit('V'); 
	USART_Transmit(' ');
	USART_Transmit('(');
	char msggg [3];
	itoa(final_int, msggg, 10);
	for(int i = 0; i < sizeof(msggg); i++){
		USART_Transmit(msggg[i]);
	}
	USART_Transmit('d');
	USART_Transmit(')');
	USART_Transmit(' ');
}


int main(void)
{
	
	USART_Init(MYUBRR);
	ADC_Init();
	i2c_init();
	
	while(1)
	{
		//get_String();
		/* Wait for data to be received */
		int i = 0;
		int len = 0;
		//USART_Transmit('p');
		unsigned char c = USART_Receive();
		//USART_Transmit(c);
		if ( c == 'G')
		{
			get_ADC();
		}
		//goto G function
		else if(c == 'S')
		{
			len = 8;
			data[0] = c;
			i=1;
			while(i != len)
			{
				data[i] = USART_Receive();
				i++;
			}
			S_command();
		}else if(c == 'W')
		{
			len = 50;
			data[0] = c;
			i=1;
			bool done = false;
			while(i != len)
			{
				//USART_Transmit('u');
				data[i] = USART_Receive();
				if(data[i] == ' ')
				{
					//done = true;
					i = len;
					}else{
					//USART_Transmit(data[i]);
					i++;
				}
			}
			W_command();
		}
	}
	
	
}



