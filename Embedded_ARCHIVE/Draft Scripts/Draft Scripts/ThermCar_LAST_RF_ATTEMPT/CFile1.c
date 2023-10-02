#include <avr/io.h>
#include <util/delay.h>
#include <stdint.h>
#include "nrf24l01.h"
#ifndef F_CPU
#define F_CPU 16000000UL
#include <stdio.h>