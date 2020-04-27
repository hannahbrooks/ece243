.text 
.global _start

_start:
		 MOV    R0, #0           // the value currently being displayed on the board
		 MOV    R1, #0           // extra register to hold key pressed
		 MOV    R2, #0
		 LDR    R7, =0xFF200050  // key pointer
		 LDR    R8, =0xFF200020  // hex pointer
		 
WHILE_KEY_IS_PRESSED:
	     LDR	R1, [R7]         // get the current key that r7 is pointing to
	     CMP	R1, #0           // zero means that there is no key clicked
	     BEQ	FIND_KEY          
	     MOV 	R2, R1           // put the new key value into r2 (the current key register)
		 B      WHILE_KEY_IS_PRESSED

FIND_KEY:
		 CMP    R2, #1             // if key0 is pressed
		 MOVEQ  R0, #0
		 
		 CMP    R2, #2             // if key1 is pressed
		 ADDEQ  R0, #1
		 
		 CMP    R2, #4             // if key2 is pressed
		 SUBEQ  R0, #1
		 
         CMP    R2, #8             // if key3 is pressed
		 BEQ    BLANK
		 
CHECK_COUNT:
		 CMP    R0, #10
		 MOVEQ  R0, #0
		 
		 CMP    R0, #-1
		 MOVEQ  R0, #9
		 
SEG7_CODE:
            MOV     R1, #BIT_CODES  
            ADD     R1, R0         // index into the BIT_CODES "array"
            LDRB    R2, [R1]       // load the bit pattern (to be returned)
            MOV     R3, R2          
			STR     R3, [R8]
			B       WHILE_KEY_IS_PRESSED
			
BLANK:
	     MOV 	R3, #0b00000000      
	     STR	R3, [R8]             // make all hex segments off
		 
	     LDR	R2, [R7]             // store the current value of the key
	     CMP	R2, #0               // while no new key is pressed, stay in this loop
	     BEQ	BLANK
		 MOV    R0, #-1               // make sure to reset the counter before redisplaying
		 B      WHILE_KEY_IS_PRESSED

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment
.end 