		  .text                   // executable code follows
          .global _start                  
_start:   
          MOV     R4, #TEST_NUM   // load the data word ...
		  MOV     R5, #0
		  MOV     R2, #0

LOOP:
		  LDR     R1, [R4], #4    // go to next word in list
		  CMP     R1, #0          // check if it is the zero bit
		  BEQ     END 
		  
          MOV     R0, #0          // make the ones count 0 again 
		  BL      ONES            
		  
		  CMP     R0, R5          // if new r0 is bigger than the old r5
		  MOVGE   R5, R0            
		  B       LOOP
		  
ONES:     CMP     R1, #0          // check if all the zeros have been pushed out
          MOVEQ   PC, LR          // if you're done go back to LOOP   
          LSR     R2, R1, #1      // perform SHIFT, followed by AND
          AND     R1, R1, R2      
		  
          ADD     R0, #1          // add to the string length so far
          B       ONES
		  
ZEROS:    

END:      B       END             

TEST_NUM: .word   0x103fe00f
          .word   0x103ff00f
		  .word   0x103ffc0f
		  .word   0
          .end     