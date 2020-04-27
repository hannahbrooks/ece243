.text
.global _start 

_start:
			MOV		R5, #0                     // keeps the current count from 0-99
			LDR		R6, =0xFF200050            // key pointer
			LDR     R7, =0xFFFEC600            // base timer pointer
			LDR     R8, =0xFF200020            // hex pointer
			LDR		R10, =0xFF20005C           // edge pointer
			
			LDR     R1, =50000000              // timer value (0.25s)
			STR     R1, [R7]                   // give this value to the timer

DO_DELAY:
			LDR 	R2, [R10]                  // reset the edge value
		    STR	    R2, [R10]
			
            LDR     R7, =0xFFFEC60C            // go to the interrupt status address
		    LDR	    R2, [R7]                   // reset the timer value
		    STR	    R2,	[R7]
			
SUB_LOOP:
            LDR	    R1, [R7]                   // actually check the interrupt status
		    CMP	    R1, #1                     // check that it is activated
		    BNE     SUB_LOOP
		    B	    KEYCHECK
			
// *************************************
//          CODE FROM PART 2
// *************************************

//****** add until R5 gets to 99 *****//
INCREASE:
            ADD		R5, #1
			CMP 	R5, #100
			MOVGE	R5, #0
			B		DISPLAY

//***** checking for the first key press, come after delay is done *****//
KEYCHECK:
            LDRB	R1, [R10]                   // load R1 with whatever R10 has
			CMP		R1, #0                      // is a key pressed?
			BEQ		INCREASE                    // if no key, add a new num
			B		KEYWAIT                     // if there is a key pressed

KEYWAIT:
            LDR		R2, [R10]                   // update the flag so that we know that there could be a new flag
			STR		R2, [R10]

//***** here we're waiting for the second key press, to restart *****//
KEYLOOP:
            LDR 	R10, =0xFF20005C            // reinitialize the edge pointer
			LDR		R1, [R10]          
			CMP		R1, #1                      // make sure that is still not zero, aka new key is pressed
			BGE		DO_DELAY 
			B		KEYLOOP
			
//***** get the right bit code *****//
SEG7_CODE:  
			MOV     R1, #BIT_CODES  
            ADD     R1, R0                      // index into the BIT_CODES "array"
            LDRB    R2, [R1]                    // load the bit pattern (to be returned)
            MOV		PC, LR
			
//***** dividing stuff *****//
DIVIDE:
            MOV     R2, #0
		
CONT:
			CMP     R0, #10
			BLT     DIV_END
			SUB     R0, #10
			ADD     R2, #1
			B       CONT
		
DIV_END:
			MOV     R1, R2
			MOV     PC, LR

//***** actually put the numbers on the display *****//
DISPLAY:
            LDR     R8, =0xFF200020              // base address of HEX3-HEX0
            MOV     R0, R5                       // display R5 on HEX1-0
            BL      DIVIDE
			
            MOV     R9, R1                       // save the tens digit
            BL      SEG7_CODE       
            MOV     R4, R2                       // save bit code
            MOV     R0, R9                       // retrieve the tens digit, get bit code
			
            BL      SEG7_CODE       
            LSL     R2, #8
            ORR     R4, R2
			STR		R4, [R8]
			B	    DO_DELAY	

BIT_CODES:
            .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment