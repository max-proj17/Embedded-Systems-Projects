
# Embedded Systems Projects

## Overview
This repository contains various projects and code snippets related to my Embedded Systems Projects! The projects encompass a range of applications and are developed using C, Assembly, and potentially other languages and tools related to embedded systems development.

![Project Image](/repo_images/medium-ATmega328P-TQFP-32.png)  

## General Technologies & Tools Used
- **Languages**: C, Assembly
- **Tools**: AVR Studio, Serial Monitor, Oscilloscopes, Multimeters
- **Microcontroller**: ATMEGA328P


## Projects
### Project 1: LED Toggle with Out-of-Phase Blinking [Embedded_Lab_1](https://github.com/max-proj17/Embedded-Systems-Projects/tree/main/Embedded_ARCHIVE/Embedded_Labs/Embedded_Lab_1/Embedded_Lab_1)
- **Description**: This assembly program is designed to control two LEDs connected to an AVR microcontroller (ATmega328P). It toggles the LEDs in an out-of-phase manner, meaning when one LED is ON, the other is OFF and vice versa. The program utilizes two pins (PB1 and PB2) on port B of the microcontroller to control the LEDs and implements a delay function to manage the blinking rate of the LEDs.
- **Languages Used**: Assembly
- **Hardware Used**: ATmega328P microcontroller, LEDs, current-limiting resistors.
- **Key Concepts**: I/O port manipulation, subroutine calls for delay implementation, register operations, and loop constructs.

### Project 2: Countdown Timer [Embedded_Lab_2](https://github.com/max-proj17/Embedded-Systems-Projects/tree/main/Embedded_ARCHIVE/Embedded_Labs/Embedded_Lab_2_COMPLETE/Embedded_Lab_2)
- **Description**: The goal of this lab was to create a microcontroller-based countdown timer that is able to countdown between 1 and 25 seconds. The timer utilizes two cascading 8-bit shift registers, two seven-segment displays, and two pushbuttons. Operating the first pushbutton with a short press and release increments the displayed digit by one, and operating the same pushbutton with a long press and release resets the display to zero. Operating the second pushbutton will countdown from the number displayed at a rate of 1 digit per second.
- **Languages Used**: Assembly
- **Hardware Used**: ATmega328P microcontroller, 7-segment displays, shift registers, pushbuttons.
- **Key Concepts**: I/O port manipulation, subroutine calls for delay implementation, register operations, loop constructs, user input handling, and display control.

### Project 3: Seven-Segment Display Lock System [Embedded_Lab_3](https://github.com/max-proj17/Embedded-Systems-Projects/tree/main/Embedded_ARCHIVE/Embedded_Labs/Embedded_Lab_3/Lab_3_2_28_23/AssemblerApplication1)
- **Description**: The goal of this lab is to create a lock system with a seven-segment display, push-button switch, RPG (Rotary Encoder), shift register, and ATmega328P. The RPG allows a user to increment and decrement from 0-9 and A-F where 9 jumps to A when reached. When a user presses the button the current value represented by the seven-segment display is recorded. The system waits for 5 button presses to evaluate whether the 5 character code entered was correct. If it is correct, the decimal on the seven-segment display will turn on as well as an LED on the Arduino Board for 5 seconds. If the passcode is incorrect an underscore will appear on the seven-segment display for 9 seconds. After either a correct or incorrect passcode’s animation has finished the system can accept a 5 character code again starting at a dash. The correct code for this implementation is E859A.
- **Languages Used**: Assembly
- **Hardware Used**: ATmega328P microcontroller, 7-segment display, push-button switch, RPG (Rotary Encoder), shift register.
- **Key Concepts**: I/O port manipulation, subroutine calls for delay implementation, register operations, loop constructs, user input handling, and display control.

### Project 4: Variable Speed Fan Controller [Embedded_Lab_4](https://github.com/max-proj17/Embedded-Systems-Projects/tree/main/Embedded_ARCHIVE/Embedded_Labs/Embedded_Lab_4/Embedded_Lab_4)
- **Description**: The goal of this lab is to create a variable speed fan with an interactive LCD display. The display shows the current fan speed in integer percent values from 1% to 100%, with an initial speed of 50%. A Rotary Pulse Generator (RPG) changes the fan speed and displayed value with a CW and CCW turn incrementing and decrementing the speed by 1%, respectively. A pushbutton switch (PBS) is used to turn the fan on and off, with the display’s second line appropriately displaying “ON” or “OFF”.
- **Languages Used**: Assembly
- **Hardware Used**: ATmega328P microcontroller, LCD display, RPG, PBS, Fan.
- **Key Concepts**: I/O port manipulation, PWM (Pulse Width Modulation) for fan speed control, LCD interfacing, interrupt service routines, and user input handling through RPG and PBS.

### Project 5: Variable Analog Signal Measurement and Generation System [Embedded_Lab_5](https://github.com/max-proj17/Embedded-Systems-Projects/tree/main/Embedded_ARCHIVE/Embedded_Labs/Embedded_Lab_5/Lab5CProj)
- **Description**: The project aims to develop a system capable of measuring and generating analog signals, controllable remotely. Utilizing the ATmega328P controller's internal A/D converter and an external two-channel D/A converter (MAX518) with an I2C interface, the system is equipped with an RS232 interface (9600 8N1) for remote control via a laptop or computer. Users can initiate analog voltage measurements and set the output voltage sequence for both DAC channels by sending commands through the RS232 interface. The system employs ADC for analog-digital conversion, utilizing 10-bit resolution and VCC as the reference voltage. The DAC, MAX518, communicates with the microcontroller using the I2C protocol, converting 8-bit digital values into corresponding analog voltages. The software implementation involves I2C communication, USART for sending and receiving data via the RS232 interface, and standard C libraries for data type conversions.
- **Languages Used**: C
- **Hardware Used**: ATmega328P microcontroller, MAX518 D/A converter, RS232 interface.
- **Key Concepts**: ADC (Analog Digital Conversion), DAC (Digital Analog Conversion), I2C communication protocol, USART (Universal Synchronous/Asynchronous Receiver Transmitter), RS232 interface communication, Data type conversions (atoi(), dtostrf()).


### Project 6: Joystick Controlled Car with Ultrasonic Sensor Feedback [JoyStick_Controlled_Car_Final_Project](https://github.com/max-proj17/Embedded-Systems-Projects/tree/main/Embedded_ARCHIVE/JoyStick_Controlled_Car_Final_Project)
- **Description**: This project involves the development of a joystick-controlled car that utilizes ultrasonic sensor feedback to modulate an audio signal. The car's movement is controlled by two joysticks, each responsible for one of the motors. The ultrasonic sensor provides distance feedback, which is then converted into a voltage that modulates an audio signal, altering the pitch based on the proximity to an object. The closer the object, the higher the pitch produced by the audio signal. The project is implemented using two main components: the car controls and the ultrasonic sensor script (USSScript).
- **Languages Used**: C
- **Hardware Used**: ATmega328P microcontroller, brushed dc motors, joysticks, ultrasonic sensor, DAC (Digital to Analog Converter), L298N Motor Driver.
- **Key Concepts**: PWM (Pulse Width Modulation) Smoothing for motor control, ADC (Analog to Digital Conversion) for reading joystick positions, I2C communication protocol for DAC control, interrupt service routines, and user input handling through joysticks.

#### Car Controls
The car is controlled using two joysticks, each joystick controlling one of the motors. The ADC (Analog to Digital Conversion) readings from the joysticks are converted to PWM (Pulse Width Modulation) signals to control the speed of the motors. The direction of the motors (forward or backward) is determined based on the ADC value. If the ADC value is in the middle, the motor stops; if it is less than the middle value, the motor moves forward, and if it is more, the motor moves backward. The code also includes USART (Universal Synchronous/Asynchronous Receiver Transmitter) functions for potential serial communication. The code for car controls can be found [here](https://github.com/max-proj17/Embedded-Systems-Projects/blob/main/Embedded_ARCHIVE/JoyStick_Controlled_Car_Final_Project/Car_Controls/GccApplication1/GccApplication1/main.c).

#### Ultrasonic Sensor Script (USSScript)
The ultrasonic sensor measures the distance to the nearest object and converts this distance to a voltage that modulates an audio signal. The closer the object, the higher the pitch produced by the audio signal. The ultrasonic sensor sends a trigger pulse and measures the echo pulse duration, which is converted to distance. The distance is then scaled and converted to a voltage that is sent to a DAC (Digital to Analog Converter) using the I2C communication protocol. The voltage is used to modulate an audio signal, altering its pitch based on the proximity to an object. The code for the ultrasonic sensor script can be found [here](https://github.com/max-proj17/Embedded-Systems-Projects/blob/main/Embedded_ARCHIVE/JoyStick_Controlled_Car_Final_Project/USSScript/USSScript/main.c).



## Contact
- [LinkedIn](https://www.linkedin.com/in/maxfinch2002)

## Acknowledgements
My lab partner Tiger Slowinski :)


