/* Program that finds the largest number in a list of integers	*/

            .text                   // executable code follows
            .global _start                  
_start:     MOV     R0, #0          // Initilize R0 to 0              
            MOV     R4, #RESULT     // R4 points to result location
            LDR     R3, [R4, #4]    // R3 holds the number of elements in the list
            MOV     R1, #NUMBERS    // R1 points to the start of the list
            BL      LARGE           
            STR     R0, [R4]        // R0 holds the subroutine return value 

END:     B       END

LARGE:    SUBS     R3, #1        // decrement the loop counter
          MOVEQ    PC, LR         // if result is equal to 0, branch
          ADD      R1, #4
          LDR      R2, [R1]       // get the next number
          CMP      R0, R2         // check if larger number found
          BGE      LARGE
          MOV      R0, R2         // update the largest number
          B        LARGE

RESULT:     .word   0           
N:          .word   7            // number of entries in the list
NUMBERS:    .word   4, 5, 3, 6   // the data
            .word   1, 8, 2                 

            .end                            
