#if defined(ALEPH_DEC) && defined(MACRO)
;-----------------------------------------------------------------------
;       SUBROUTINE CMPBU3(A,B,NROW,L,NC,ILOW,FACT)
;C!     Decompress array A, convert to Real, and store into array B
;CKEY PRESS CMPBU3 /INTERNAL
;       AUTHOR :    D.Harvatis    MAY 1989
;
;       INPUT :     A : Real array to be compressed. (TYPE 3)
;                NROW : Number of values contained in the A array.
;                       Normaly it is the number of rows in the
;                       original BOS bank.
;                   L : number of bits
;                  NC : number of columns of the original BOS bank.
;                ILOW : conversion parameter.
;                FACT : conversion parameter.The conversion is
;                       done using the following formula :
;                           i = NINT( FACT * r ) - ILOW
;
;       OUTPUT:     B : Compressed array.
;-----------------------------------------------------------------------
#ifndef DOC
        .TITLE  CMPBU3
        .IDENT  /1.0/
        .PSECT  BUNCH3
;
        .ENTRY  CMPBU3,^M<IV,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11>
        MOVL    B^4(AP), R3             ; R3 contains address of A array
        MOVL    B^8(AP), R4             ; R4 contains address of B array
        MOVL    @B^12(AP), R0           ; store NROW in R0
        MOVL    @B^16(AP), R8           ; store L in R8
        MOVL    @B^20(AP), R1           ; store NCOL in R1
        MOVL    @B^24(AP), R10          ; store ILOW in R10
        MOVF    @B^28(AP), R11          ; store FACT in R11
        CLRL    R2                      ; R2 is A array index
        MOVZBL  #32, R5                 ; R5=32
BLOOP3: MULF3   (R3)[R2], R11, R12      ; R12=FACT*A(R2)
        CVTRFL  R12, R12                ; R12=NINT(R12)
        SUBL2   R10, R12                ; R12=R12-ILOW
        ADDL2   R1, R2                  ; increase R2 by NCOL
        SUBB2   R8, R5                  ; R5=R5-NBITS
        BLSS    BL1013                  ; if NBITS>R5 goto L101
        INSV    R12, R5, R8, R7         ; insert bit field
        SOBGTR  R0, BLOOP3              ; decrease R0, if R0>0 continue
        MOVL    R7, (R4)                ; store into B array
        RET
BL1013: BICB2   #224, R5                ; R5=R5.AND.31
        INSV    R12, R5, R8, R6         ; insert bit field
        MOVL    R7, (R4)+               ; store into B array
        MOVL    R6, R7
        SOBGTR  R0, BLOOP3              ; decrease R0, if R0>0 continue
        MOVL    R7, (R4)                ; store into B array
        RET
;
#endif
#endif
#if defined(ALEPH_C)

/* CMPBU3(A,B,NROW,NBITS,NCOL,ILOW,FACT) */

#include "cfromf.h"

#define WORDLENGTH 32

FORT_CALL(cmpbu3) (a,b,nr,l,nc,ilow,fact)

float *a[];
int *b[];
int *nr;
int *l;
int *nc;
int *ilow;
float *fact;

{

   int nrow;   /* r0 */
   int ib;     /* r2 */
   int i;      /* r5 - bit position [0..31] */
   int temp1;  /* r6 */
   int temp2;  /* r7 */
   int m;      /* r9 - extracted integer */
   int r12;    /* r12 */
   int bindex;

         ib = 0;
         bindex = 0;
         nrow = *nr;

bloop3:  r12 = *fact * *a[ib];
         r12 - r12 - *ilow;
         ib = ib + *nc;
         i = WORDLENGTH - *l;
         if (*l > i) goto bl1013;
         insv(r12,i,*l,&temp2);
         nrow--;
         if (nrow > 0) goto bloop3;
         *b[bindex] = temp2;
         return;

bl1013:  i = i & (WORDLENGTH - 1);
         insv(r12,i,*l,&temp1);
         *b[bindex++] = temp2;
         temp2 = temp1;
         nrow--;
         if (nrow > 0) goto bloop3;
         *b[bindex] = temp2;
         return;

}
#endif
