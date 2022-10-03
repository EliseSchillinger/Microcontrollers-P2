;
; Project 1.asm
;
; Created: 10/14/2021 1:00:39 PM
; Author : Tim Sallwasser, Elise Schillinger
;		   Kyle Fowler, Cameron Niemeyer
;


LDI R16, 0xFF
LDI R17, 0x00

.equ MAX = 24					//Sets a constant value MAX to 24
LDI R18, MAX					//Max value
.equ MIN = 0					//Sets a constant value MIN to 0
.def COUNTER = R19				//Renames a register to Counter so
								//it is easier to keep track of
LDI COUNTER, MIN				//counter

OUT DDRC, R16					//PC is output for LED and Speaker
//OUT PORTC, R16

OUT DDRD, R17					//PD is input for Decrement button
OUT PORTD, R16					//enable pullup resistor

OUT DDRF, R17					//PD is input for Increment button
OUT PORTD, R16					//enable pullup resistor

// Flash is contains the loops for turning on and off the LED for the correct amounts of time
FLASH:					
						MOV R20, COUNTER 

	// Sets the light to on for the value of R20 multiplied by the delay
	FLASH_LOOP_ON:		CPI R20, MIN
						BREQ END_FLASH_LOOP_ON 
						SBI PORTC,7
						CALL DELAY
						DEC R20
						BRNE FLASH_LOOP_ON
	
	END_FLASH_LOOP_ON:	CBI PORTC,7
						MOV R20, COUNTER

	// Sets the light to off for the value of MAX - R20 multiplied by the delay
	FLASH_LOOP_OFF:		CPI R20, MAX
						BREQ END_FLASH_LOOP_OFF
						CALL DELAY
						INC R20
						BRNE FLASH_LOOP_OFF	
	END_FLASH_LOOP_OFF:	RJMP FLASH

// Check and act on the status of the Decrement Button
CHECK_SW_DEC:
	SBIS PIND,4					//if PINA = 1 skip next instructon
	RJMP CHECK_SW_INC			//Jump to check next switch
	CALL RELEASE_DEC
	CPI R19, MIN
	BREQ UNDER_FLOW
	DEC COUNTER
	FINISH15: RET

// Check and act on the status of the Increment Button
CHECK_SW_INC:
	SBIS PINF,6					//if PINF = 1 skip next instructon
	RET
	CALL RELEASE_INC
	CPI R19, MAX
	BREQ OVER_FLOW
	INC COUNTER
	FINISH1:RET

OVER_FLOW:
	CALL SOUND1
	LDI R19, MIN
	RJMP FINISH1

UNDER_FLOW:
	CALL SOUND15
	LDI R19, MAX
	RJMP FINISH15



RELEASE_DEC:					//holds code until button is released
	HERE:SBIS PIND, 4
	RET
	RJMP HERE

RELEASE_INC:					//holds code until button is released
	HERE1:SBIS PINF, 6
	RET
	RJMP HERE1

DELAY:
		LDI  R21, 2
		LDI  R22, 69
		LDI  R23, 170
LOOP1:  DEC  R23
		CALL CHECK_SW_DEC
		BRNE LOOP1
		DEC  R22
		BRNE LOOP1
		DEC  R21
		BRNE LOOP1
		RET

SOUND1:		LDI R24,20		// Play overflow sound
SLOOP1:		LDI R25,20			
SLOOP2:		LDI R26,100			
SLOOP3:		LDI R27,9			
SLOOP4:		DEC R27				
		NOP					
		BRNE SLOOP4			// Sound loop 4: 4 * 900 = 3600 cycles

		DEC R26				
		NOP					
		BRNE SLOOP3			// Sound loop 3: 4 * 100 = 400 cycles

		IN R28,PORTC		
		LDI R29,0b01000000	// Every 2,800 cycles, switches between low and high
		EOR R28,R29			
		OUT PORTC,R28		

		DEC R25				
		BRNE SLOOP2			
		DEC R24				// Multiply by 400 times at 8 MHz = 1kHz sound for 0.2 seconds
		BRNE SLOOP1			
		RET			

SOUND15:	LDI R24,20		// Play underflow sound
SLOOP5:		LDI R25,20			
SLOOP6:		LDI R26,100			
SLOOP7:		LDI R27,6			
SLOOP8:		DEC R27				 
		NOP					
		BRNE SLOOP8			// Sound loop 8: 4 * 600 = 2400 cycles

		DEC R26				
		NOP					
		BRNE SLOOP7			// Sound loop 7: 4 * 100 = 400 cycles

		IN R28,PORTC		
		LDI R29,0b01000000	// Every 2,800 cycles, switches between low and high
		EOR R28,R29			
		OUT PORTC,R28		

		DEC R25				
		BRNE SLOOP6			
		DEC R24				// Multiply by 400 times at 8 MHz = 1.5KHz sound for 0.2 seconds 
		BRNE SLOOP5			
		RET			

