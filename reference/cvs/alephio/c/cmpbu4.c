#if defined(ALEPH_DEC) && defined(MACRO)
;-----------------------------------------------------------------------
;       SUBROUTINE CMPBU4(A,B,NROW,NBITS,NCOL,ILOW)
;C!     Decompress array A, convert, and store into array B
;CKEY PRESS CMPBU4 /INTERNAL
;       AUTHOR :    D.Harvatis    MAY 1989
;
;       INPUT :     A : Integer array to be compressed. (TYPE 4)
;                NROW : Number of values contained in the A
;                       array. Normaly it is the number of rows in the
;                       original BOS bank.
;                   L : number of bits for each number.
;                  NC : number of columns of the original BOS bank.
;                ILOW : conversion parameter.The conversion is
;                       done using the following formula :
;                           i = i - ILOW
;
;       OUTPUT:     B : Compressed Integer array.
;-----------------------------------------------------------------------
#ifndef DOC
        .TITLE  CMPBU4
        .IDENT  /1.0/
        .PSECT  BUNCH4
;
        .ENTRY  CMPBU4,^M<IV,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11>
        MOVL    B^4(AP), R3             ; R3 contains address of A array
        MOVL    B^8(AP), R4             ; R4 contains address of B array
        MOVL    @B^12(AP), R0           ; store NROW in R0
        MOVL    @B^16(AP), R8           ; store L in R8
        MOVL    @B^20(AP), R1           ; store NCOL in R1
        MOVL    @B^24(AP), R10          ; store ILOW in R10
        CLRL    R2                      ; R2 is A array index
        MOVZBL  #32, R5                 ; R5=32
BLOOP2: SUBL3   R10, (R3)[R2], R11      ; convert to positive integers
        ADDL2   R1, R2                  ; increase R2 by NCOL
        SUBB2   R8, R5                  ; R5=R5-NBITS
        BLSS    BL1012                  ; if NBITS>R5 goto L101
        INSV    R11, R5, R8, R7         ; insert bit field
        SOBGTR  R0, BLOOP2              ; decrease R0, if R0>0 continue
        MOVL    R7, (R4)                ; store into B array
        RET
BL1012: BICB2   #224, R5                ; R5=R5.AND.31
        INSV    R11, R5, R8, R6         ; insert bit field
        MOVL    R7, (R4)+               ; store into B array
        MOVL    R6, R7
        SOBGTR  R0, BLOOP2              ; decrease R0, if R0>0 continue
        MOVL    R7, (R4)                ; store into B array
        RET
;
#endif
#endif
#if defined(ALEPH_C)

/* CMPBU4(A,B,NROW,NBITS,NCOL,ILOW) */

#include "cfromf.h"

#define WORDLENGTH 32

FORT_CALL(cmpbu4) (a,b,nr,l,nc,ilow)

int a[];
int b[];
int *nr;
int *l;
int *nc;
int *ilow;

{

   int nrow;   /* r0 */
   int ib;     /* r2 */
   int i;      /* r5 - bit position [0..31] */
   int temp1;  /* r6 */
   int temp2;  /* r7 */
   int m;      /* r9 - extracted integer */
   int fact;   /* r11 */
   int bindex;

         ib = 0;
         bindex = 0;
         nrow = *nr;

         i = WORDLENGTH;
bloop2:  fact = a[ib] - *ilow;
         ib = ib + *nc;
         i = i - *l;
         if (0 > i) goto bl1012;
         insv(fact,i,*l,&temp2);
         nrow--;
         if (nrow > 0) goto bloop2;
         b[bindex] = temp2;
         return;

bl1012:  i = i & (WORDLENGTH - 1);
         insv(fact>>(WORDLENGTH-i),0,*l-(WORDLENGTH-i),&temp2);
         insv(fact,i,*l,&temp1);
         b[bindex++] = temp2;
         temp2 = temp1;
         nrow--;
         if (nrow > 0) goto bloop2;
         b[bindex] = temp2;
         return;

}
#endif