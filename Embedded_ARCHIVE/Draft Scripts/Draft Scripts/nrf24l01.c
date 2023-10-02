/*
 * Thermicar_W_RF.c
 *
 * Created: 4/24/2023 5:36:31 PM
 * Author : maxfi
 */ 

//Okay so basically bro in tutorial is dumb basically
//all he wants to do is set register values with the functions.
// 1. Double check that you are addressing registers correctly
// 2. Make sure the data structure you are using  can store multiple
//    register values.
//3. review the difference of pointer syntax, char * data vs char data
//4. Make transmit and receive base functions loop able
//5. Review data sheet to match the commands he was continuously referencing
//6. I don't think we need to send buffer size, a function we make could use it though

#include <avr/io.h>
#include <util/delay.h>
#include <stdint.h>
#include "nrf24l01.h"

//Make sure CSS pin is sigh high always!!
#define NRF24_CE_PIN PORTD7 // Use pin PD7 as the SS (CS) pin
#define NRF24_CSN_PIN PORTB0

#define NRF24_CE_PORT PORTD
#define NRF24_CSN_PORT PORTB

#ifndef F_CPU
#define F_CPU 16000000UL
#endif
//CSN selects the device the SPI bus will send data to
//CE enables wireless communication and is used
//to indicate the start and end of transmission

void spi_init(void) {
	DDRB |= (1<<DDB3) | (1<<DDB2) | (1<<DDB5); // Set MOSI, SCK, and CS pins as outputs
	DDRB &= ~(1<<DDB4); //Set MISO as input
	SPCR |= (1<<SPE) | (1<<MSTR) | (1 << SPR0); // Enable SPI as master, set clock rate to F_CPU/4
	//set to a prescaler of 2, SPIClockFrequency = 16MHz / 2 = 8MHz
}
void CS_Select (void)
{
	NRF24_CSN_PORT &= ~(1<<NRF24_CSN_PIN);
}
void CS_UnSelect (void)
{
	NRF24_CSN_PORT |= (1<<NRF24_CSN_PIN);
	
}
void CE_Enable(void) {
	NRF24_CE_PORT |= (1<<NRF24_CE_PIN); //Enable wireless communication
}

void CE_Disable(void) {
	NRF24_CE_PORT &= ~(1<<NRF24_CE_PIN ); // Disable wireless communication
}

//uint8_t spi_transfer(uint8_t data) {
	//SPDR = data; // Start transmission
	//while (!(SPSR & (1<<SPIF))); // Wait for transmission to complete
	//return SPDR; // Return received data
//}

void SPI_Transmit(uint8_t data) {
	SPDR = data; // Start transmission
	while (!(SPSR & (1<<SPIF))); // Wait for transmission to complete
}
void SPI_Transmit_Buffer(uint8_t *data, int size) {
	
	for(int i=0; i<size; i++)
	{
		SPI_Transmit(data[i]);
	}
	
}
uint8_t SPI_Recieve()
{
	while (!(SPSR & (1<<SPIF))); // Wait for transmission to complete
	return SPDR;
}
void SPI_Recieve_Buffer(uint8_t *data, int size)
{
	for(int i=0; i<size; i++)
	{
		data[i] = SPI_Recieve();
	}
}
//write single bits?
void nrf24_WriteReg (uint8_t Reg, uint8_t Data)
{
	//Whenever we send something to a register address
	//the fifth bit must be a 1
	uint8_t buffer[2];
	buffer[0] = Reg|1<<5;  //shifts one to 5th bit position and ors result with reg "address"
	buffer[1] = Data; // the actual 2^8 data
	
	//send size as well
	CS_Select();       //Pull CS low
	SPI_Transmit_Buffer(buffer, 2);   //Send the size of two
	CS_UnSelect();     //pull CS high
	
}
//write multiple "instructions"? to register
void nrf24_WriteRegMulti (uint8_t Reg, uint8_t *data, int size)
{
	//Whenever we send something to a register address
	//the fifth bit must be a 1
	uint8_t buffer;
	buffer = Reg|1<<5;
	//buffer[1] = Data;
	
	CS_Select();       //Pull CS low
	SPI_Transmit(buffer);
	SPI_Transmit_Buffer(data, size);
	CS_UnSelect();     //pull CS high
}
uint8_t nrf24_ReadReg (uint8_t Reg)
{
	//double check if Reg has to be like &Reg
	//double check data sheet
	
	uint8_t data=0;
	CS_Select();       //Pull CS low
	
	SPI_Transmit(Reg); //send register address, receive data
	data = SPI_Recieve();  //might need to change this
	
	CS_UnSelect();     //pull CS high
	
	return data;
}

//reads multiple bytes from register
void nrf24_ReadReg_Multi (uint8_t Reg, uint8_t *data, int size) //size is num of bytes I want to read
{
	
	
	CS_Select();       //Pull CS low
	
	SPI_Transmit(Reg); //send register address, receive data
	SPI_Recieve_Buffer(data, size);
	
	CS_UnSelect();     //pull CS high
	
}

//send the command to the NRF
void nrfsendCmd (uint8_t cmd)
{
	CS_Select();
	
	SPI_Transmit(cmd);
	
	CS_UnSelect();
	
}
void NRF24_Init (void)
{
	//We must disable device to configure it
	CE_Disable();
	
	nrf24_WriteReg(CONFIG, 0);
	nrf24_WriteReg(EN_AA, 0);  //no crazy boost mode
	//nrf24_WriteReg()
	nrf24_WriteReg(EN_RXADDR, 0); //disable all pipes
	nrf24_WriteReg(SETUP_AW, 0x03); //5 bytes for TX and RX address
	nrf24_WriteReg(SETUP_RETR, 0); //No retransmission
	nrf24_WriteReg(RF_CH, 0); //Will be setup during TX or RX
	nrf24_WriteReg(RF_SETUP, 0x0E);  // Power = 0db, data rate = 2Mbps
	
	CE_Enable();

	
}

void NRF24_TxMode (uint8_t *Address, uint8_t channel)
{
	//disable the chip before configuring the device
	CE_Disable();

	nrf24_WriteReg(RF_CH, channel);  // select the channel
	nrf24_WriteRegMulti(TX_ADDR, Address, 5); // write 5 bytes of the address to TX register
	
	//power up the device
	uint8_t config = nrf24_ReadReg(CONFIG);
	config = config | (1<<1);
	nrf24_WriteReg(CONFIG, config);  
	
	CE_Enable();
	
}

// transmit data

uint8_t NRF24_Transmit (uint8_t *data)
{
	uint8_t cmdtosend = 0;
	// select the device
	CS_Select();
	
	//payload command
	cmdtosend = W_TX_PAYLOAD;
	SPI_Transmit(cmdtosend);
	
	//send the payload itself
	SPI_Transmit_Buffer(data, 32); //32 byte buffer
	
	//Un-select the device
	CS_UnSelect();
	
	//delays might not be functioning properly
	_delay_ms(1);
	
	//TX FIFO Flag set means transmission was successful
	uint8_t fifostatus = nrf24_ReadReg(FIFO_STATUS); 
	
	if((fifostatus&(1<<4)) && (!(fifostatus&(1<<3))))//If transmission was a success FLUSH the fifo
	{
		cmdtosend = FLUSH_TX; 
		nrfsendCmd(cmdtosend);
		
		return 1;
	}
	return 0;
}


