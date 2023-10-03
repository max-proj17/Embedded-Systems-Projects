
# Embedded Systems Projects

## Overview
This repository contains various projects and code snippets related to my Embedded Systems Projects! The projects encompass a range of applications and are developed using C, Assembly, and potentially other languages and tools related to embedded systems development.

![Project Image](/repo_images/medium-ATmega328P-TQFP-32.png)  

## Projects
### Project 1: LED Toggle with Out-of-Phase Blinking (Embedded_Lab_1)
- **Description**: This assembly program is designed to control two LEDs connected to an AVR microcontroller (ATmega328P). It toggles the LEDs in an out-of-phase manner, meaning when one LED is ON, the other is OFF and vice versa. The program utilizes two pins (PB1 and PB2) on port B of the microcontroller to control the LEDs and implements a delay function to manage the blinking rate of the LEDs.
- **Languages Used**: Assembly
- **Hardware Used**: ATmega328P microcontroller, LEDs, current-limiting resistors.
- **Key Concepts**: I/O port manipulation, subroutine calls for delay implementation, register operations, and loop constructs.

### Project 2: Countdown Timer (Embedded_Lab_2)
- **Description**: The goal of this lab was to create a microcontroller-based countdown timer that is able to countdown between 1 and 25 seconds. The timer utilizes two cascading 8-bit shift registers, two seven-segment displays, and two pushbuttons. Operating the first pushbutton with a short press and release increments the displayed digit by one, and operating the same pushbutton with a long press and release resets the display to zero. Operating the second pushbutton will countdown from the number displayed at a rate of 1 digit per second.
- **Languages Used**: Assembly
- **Hardware Used**: ATmega328P microcontroller, 7-segment displays, shift registers, pushbuttons.
- **Key Concepts**: I/O port manipulation, subroutine calls for delay implementation, register operations, loop constructs, user input handling, and display control.

### Project 3: Seven-Segment Display Lock System (Embedded_Lab_3)
- **Description**: The goal of this lab is to create a lock system with a seven-segment display, push-button switch, RPG (Rotary Encoder), shift register, and ATmega328P. The RPG allows a user to increment and decrement from 0-9 and A-F where 9 jumps to A when reached. When a user presses the button the current value represented by the seven-segment display is recorded. The system waits for 5 button presses to evaluate whether the 5 character code entered was correct. If it is correct, the decimal on the seven-segment display will turn on as well as an LED on the Arduino Board for 5 seconds. If the passcode is incorrect an underscore will appear on the seven-segment display for 9 seconds. After either a correct or incorrect passcode’s animation has finished the system can accept a 5 character code again starting at a dash. The correct code for this implementation is E859A.
- **Languages Used**: Assembly
- **Hardware Used**: ATmega328P microcontroller, 7-segment display, push-button switch, RPG (Rotary Encoder), shift register.
- **Key Concepts**: I/O port manipulation, subroutine calls for delay implementation, register operations, loop constructs, user input handling, and display control.

  

## Technologies & Tools
- **Languages**: C, Assembly
- **Tools**: Mention any relevant tools or IDEs used (e.g., AVR Studio, MPLAB X, etc.)
- **Hardware**: List any microcontrollers, development boards, or other hardware that are frequently used in the projects.

## Getting Started
Provide information on how to set up the development environment and how to run or test the projects. Include any dependencies that need to be installed.

1. **Setup the Environment**: Steps to set up the development environment.
2. **Clone the Repository**: `git clone https://github.com/max-proj17/Embedded-Systems-Projects.git`
3. **Navigate to a Project**: `cd Embedded-Systems-Projects/[Project-Directory]`
4. **Compile/Build the Project**: Include steps or commands to compile or build the project.
5. **Deploy/Run**: Steps to deploy to hardware or run in a simulator.

## Contributing
Information about how others can contribute to the project. Include any guidelines you'd like contributors to follow.

## License
Include information about the licensing of your projects.

## Contact
- [LinkedIn](https://www.linkedin.com/in/maxfinch2002)

## Acknowledgements
Optional section to thank or reference individuals or resources that helped in the development of the projects.


