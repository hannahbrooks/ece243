		  .text                     // executable code follows
          .global _start                  
_start:   
          MOV     R4, #TEST_NUM     // remember where the start of the list is
		  MOV     R2, #0            // temp register
		  MOV     R5, #0            // ones count
		  MOV     R6, #0            // zeros count
		  MOV     R7, #0            // alt count
		  MOV     R11, #0           // special number register
		  MOV     R8, #0            // temp register

LOOP:
		  MOV     R3, #LIST_OF_NUMS // remember where special numbers are on each loop
		  LDR     R1, [R4], #4      // go to next word in list
		  MOV     R8, R1            // this is just an extra copy of the current word for safe keeping
		  CMP     R1, #0            // check if it is the zero bit (last bit)
		  BEQ     END
		  
		  /************** ONES ******************/
		  MOV     R0, #0            // make the temp count 0 again 
		  BL      ONES
		  CMP     R0, R5            // if new r0 is bigger than the old r5
		  MOVGE   R5, R0
		  
		  /************* ALTERNATING ********************/
		  MOV     R1, R8            // put the current word back in to r1
		  LDR     R11, [R3], #4     // get the next special number
		  EOR     R1, R11           // xor it with the current word
          MOV     R0, #0            // make the ones count 0 again 
		  BL      ONES            
		  CMP     R0, R7            // if new r0 is bigger than the old r5
		  MOVGE   R7, R0
		  
		  MOV     R1, R8            // put the current word back in to r1
		  LDR     R11, [R3], #4     // get the next special number
		  EOR     R1, R11           // xor it with the current word
          MOV     R0, #0            // make the ones count 0 again 
		  BL      ONES
		  CMP     R0, R7            // if new r0 is bigger than the old r5
		  MOVGE   R7, R0
		  
		  /****************** ZEROS **************************/
		  MOV     R1, R8            // put the current word back in to r1
		  LDR     R11, [R3], #4     // get the next special number
		  EOR     R1, R11           // xor it with the current word
          MOV     R0, #0            // make the ones count 0 again 
		  BL      ONES            
		  CMP     R0, R6            // if new r0 is bigger than the old r5
		  MOVGE   R6, R0
		  
		  B       LOOP
		  
ONES:     CMP     R1, #0            // check if all the zeros have been pushed out
          MOVEQ   PC, LR            // if you're done go back to LOOP   
          LSR     R2, R1, #1        // perform SHIFT, followed by AND
          AND     R1, R1, R2      
          ADD     R0, #1            // add to the string length so far
          B       ONES

END:      B       END             

TEST_NUM: .word   0xffffffea
		  .word   0
		  
LIST_OF_NUMS: .word 0xaaaaaaaa
              .word 0x55555555
			  .word 0xffffffff
			  .end
              