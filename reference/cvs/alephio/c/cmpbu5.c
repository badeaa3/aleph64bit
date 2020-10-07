#if defined(ALEPH_DEC) && defined(MACRO)
;-----------------------------------------------------------------------
;       SUBROUTINE CMPBU5(A,B,NROW,NBITS,NCOL)
;C!     Compress array A and store into array B
;CKEY PRESS CMPBU5 COMPRESS /INTERNAL
;
;       AUTHOR :    D.Harvatis    JUL 1989
;
;       INPUT :     A : Integer array to be compressed. (TYPE 5)
;                NROW : Number of compressed values contained in the A
;                       array. Normaly it is the number of rows in the
;                       original BOS bank.
;                   L : number of bits for each number in the compressed
;                       array.
;                  NC : number of columns of the original BOS bank.
;
;       OUTPUT:     B : Compressed Integer array.
;
; Registers used :
;
;       R0  ->  NROW
;       R1  ->  NCOL
;       R2  ->  IB
;       R3  ->  A       (address of 1st array)
;       R4  ->  B       (address of 2nd array)
;       R5  ->  I       (bit possition) [0..31]
;       R6  ->  temporary storage
;       R7  ->  temporary storage
;       R8  ->  L       (field size)    [1..31]
;       R9  ->  M       (extracted integer)      [in CMPBU3 AND 4]
;       R10 ->  ILOW                             [in CMPBU3 AND 4]
;       R11 ->  FACT                             [in CMPBU4]
;
;-----------------------------------------------------------------------
#ifndef DOC
        .TITLE  CMPBU5
        .IDENT  /1.0/
        .PSECT  BUNCH5
;
        .ENTRY  CMPBU5,^M<IV,R2,R3,R4,R5,R6,R7,R8>
        MOVL    B^4(AP), R3             ; R3 contains address of A array
        MOVL    B^8(AP), R4             ; R4 contains address of B array
        MOVL    @B^12(AP), R0           ; store NROW in R0
        MOVL    @B^16(AP), R8           ; store L in R8
        MOVL    @B^20(AP), R1           ; store NCOL in R1
        CLRL    R2                      ; R2 is A array index
        MOVZBL  #32, R5                 ; R5=32
BLOOP:  SUBB2   R8, R5                  ; R5=R5-NBITS
        BLSS    BL101                   ; if L>I goto L101
        INSV    (R3)[R2], R5, R8, R7    ; insert bit field
        ADDL2   R1, R2                  ; increase R2 by NCOL
        SOBGTR  R0, BLOOP               ; decrease R0, if R0>0 continue
        MOVL    R7, (R4)                ; store into B array
        RET
BL101:  BICB2   #224, R5                ; R5=R5.AND.31
        INSV    (R3)[R2], R5, R8, R6    ; insert bit field
        ADDL2   R1, R2                  ; increase R2 by NCOL
        MOVL    R7, (R4)+               ; store into B array
        MOVL    R6, R7
        SOBGTR  R0, BLOOP               ; decrease R0, if R0>0 continue
        MOVL    R7, (R4)                ; store into B array
        RET
;
#endif
#endif
#if defined(ALEPH_C)

/* CMPBU5(A,B,NROW,NBITS,NCOL) */

#include "cfromf.h"

#define WORDLENGTH 32

FORT_CALL(cmpbu5) (a,b,nr,l,nc)

int a[];
int b[];
int *nr;
int *l;
int *nc;

{

   int nrow;   /* r0 */
   int ib;     /* r2 */
   int i;      /* r5 - bit position [0..31] */
   int temp1;  /* r6 */
   int temp2;  /* r7 */
   int m;      /* r9 - extracted integer */
   int ilow;   /* r10 */
   int fact;   /* r11 */
   int bindex;

         ib = 0;
         bindex = 0;
         nrow = *nr;

         i = WORDLENGTH;
bloop:   i = i - *l;
         if (0 > i) goto bl101;
         insv(a[ib],i,*l,&temp2);
         ib = ib + *nc;
         nrow--;
         if (nrow > 0) goto bloop;
         b[bindex++] = temp2;
         return;

bl101:   i = i & (WORDLENGTH - 1);
         insv(a[ib]>>(WORDLENGTH-i),0,*l-(WORDLENGTH-i),&temp2);
         insv(a[ib],i,*l,&temp1);
         ib = ib + *nc;
         b[bindex++] = temp2;
         temp2 = temp1;
         nrow--;
         if (nrow > 0) goto bloop;
         b[bindex] = temp2;
         return;

}
#endif
