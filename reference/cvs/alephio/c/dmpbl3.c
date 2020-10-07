#if defined(ALEPH_DEC) && defined(MACRO)
;-----------------------------------------------------------------------
;       SUBROUTINE DMPBL3(A,B,NROW,L,NC,ILOW,FACT)
;C!     Decompress array A, convert to Real, and store into array B
;CKEY PRESS DMPBL3 /INTERNAL
;       AUTHOR :    D.Harvatis    MAY 1989
;
;       INPUT :     A : Integer array that contains a compressed column.
;                NROW : Number of compressed values contained in the A
;                       array. Normaly it is the number of rows in the
;                       original BOS bank.
;                   L : number of bits for each number in the compressed
;                       array.
;                  NC : number of columns of the original BOS bank.
;                ILOW : conversion parameter.
;                FACT : conversion parameter.The conversion to reals is
;                       done using the following formula :
;                           r = REAL(i + ILOW) / FACT
;
;       OUTPUT:     B : Real array. Decompressed and converted values
;                       are stored into this array by row (as in BOS
;                       arrays). That means that the first value
;                       extracted from the A array is stored in B(1),
;                       the second in B(NC+1), the Nth in B((N-1)*NC+1).
;-----------------------------------------------------------------------
#ifndef DOC
        .TITLE  DMPBL3
        .IDENT  /1.0/
        .PSECT  BLOW3
S16C:   ASHL    #-1, R0, R5             ; R5=R0/2
        BEQL    LL16C
L16C:   MOVL    (R3)+, R7               ; R7=A(IA)
        EXTZV   #16, R8, R7, R9         ; extract upper bit field
        ADDL2   R10, R9                 ; M=M+ILOW
        CVTLF   R9, R9                  ; convert to float
        DIVF3   R11, R9, (R4)[R2]       ; B(IB)=M/FACT
        ADDL2   R1, R2                  ; increase R2 by NCOL
        MOVZWL  R7, R9                  ; extract lower bit field
        ADDL2   R10, R9                 ; M=M+ILOW
        CVTLF   R9, R9                  ; convert to float
        DIVF3   R11, R9, (R4)[R2]       ; B(IB)=M/FACT
        ADDL2   R1, R2
        SOBGTR  R5, L16C                ; decrease R5, if R5>0 continue
LL16C:  BICL2   #-2, R0                 ; R0=R0.AND.1
        BEQL    RC6                     ; if R0=0 return
        MOVL    (R3)+, R7
        EXTZV   #16, R8, R7, R9         ; extract last bit field
        ADDL2   R10, R9                 ; M=M+ILOW
        CVTLF   R9, R9                  ; convert to float
        DIVF3   R11, R9, (R4)[R2]       ; B(IB)=M/FACT
RC6:    RET
;
S8C:    ASHL    #-2, R0, R5             ; R5=R0/4
        BEQL    LL8C                    ; if R5=0 go to LL8
L8C:    MOVL    (R3)+, R7               ; R7=A(IA)
        EXTZV   #24, R8, R7, R9         ; extract upper bit field
        ADDL2   R10, R9                 ; M=M+ILOW
        CVTLF   R9, R9                  ; convert to float
        DIVF3   R11, R9, (R4)[R2]       ; B(IB)=M/FACT
        ADDL2   R1, R2                  ; increase R2 by NCOL
        EXTZV   #16, R8, R7, R9
        ADDL2   R10, R9                 ; M=M+ILOW
        CVTLF   R9, R9                  ; convert to float
        DIVF3   R11, R9, (R4)[R2]       ; B(IB)=M/FACT
        ADDL2   R1, R2
        EXTZV   #8, R8, R7, R9
        ADDL2   R10, R9                 ; M=M+ILOW
        CVTLF   R9, R9                  ; convert to float
        DIVF3   R11, R9, (R4)[R2]       ; B(IB)=M/FACT
        ADDL2   R1, R2                  ; increase R2 by NCOL
        MOVZBL  R7, R9                  ; extract lower bit field
        ADDL2   R10, R9                 ; M=M+ILOW
        CVTLF   R9, R9                  ; convert to float
        DIVF3   R11, R9, (R4)[R2]       ; B(IB)=M/FACT
        ADDL2   R1, R2
        SOBGTR  R5, L8C                 ; decrease R5, if R5>0 continue
LL8C:   BICL2   #-4, R0                 ; R0=R0.AND.3
        BEQL    RTSC                    ; if R0=0 return
        MOVL    (R3)+, R7               ; R7=A(IA)
        EXTZV   #24, R8, R7, R9         ; extract upper bit field
        ADDL2   R10, R9                 ; M=M+ILOW
        CVTLF   R9, R9                  ; convert to float
        DIVF3   R11, R9, (R4)[R2]       ; B(IB)=M/FACT
        ADDL2   R1, R2                  ; increase R2 by NCOL
        DECL    R0                      ; decrease R0
        BEQL    RTSC                    ; if R0=0 return
        EXTZV   #16, R8, R7, R9
        ADDL2   R10, R9                 ; M=M+ILOW
        CVTLF   R9, R9                  ; convert to float
        DIVF3   R11, R9, (R4)[R2]       ; B(IB)=M/FACT
        ADDL2   R1, R2
        DECL    R0                      ; decrease R0
        BEQL    RTSC                    ; if R0=0 return
        EXTZV   #8, R8, R7, R9          ; extract last bit field
        ADDL2   R10, R9                 ; M=M+ILOW
        CVTLF   R9, R9                  ; convert to float
        DIVF3   R11, R9, (R4)[R2]       ; B(IB)=M/FACT
RTSC:   RET
;
        .ENTRY  DMPBL3,^M<IV,R2,R3,R4,R5,R6,R7,R8,R9,R10,R11>
        MOVL    B^4(AP), R3             ; R3 contains address of A array
        MOVL    B^8(AP), R4             ; R4 contains address of B array
        MOVL    @B^12(AP), R0           ; store NROW in R0
        MOVL    @B^16(AP), R8           ; store L in R8
        MOVL    @B^20(AP), R1           ; store NCOL in R1
        MOVL    @B^24(AP), R10          ; store ILOW in R10
        MOVF    @B^28(AP), R11          ; store FACT in R11
        CLRL    R2                      ; R2 is IB
        CMPB    R8, #16
        BNEQ    CONT3
        BRW     S16C                    ; if L=16 go to S16
CONT3:  CMPB    R8, #8
        BNEQ    CONT4
        BRW     S8C                     ; if L=8 go to S8
CONT4:  CMPB    R8, #4
        BEQL    S4C                     ; if L=4 go to S4
        MOVZBL  #32, R5                 ; R5=I=32
        MOVL    (R3)+, R7               ; R7=A(1)
        MOVL    (R3)+, R6               ; R6=A(2)
LOOP3:  SUBB2   R8, R5                  ; R5=I=I-L
        BLSS    L1013                   ; if L>I goto L101
        EXTZV   R5, R8, R7, R9          ; extract bit field
        ADDL2   R10, R9                 ; M=M+ILOW
        CVTLF   R9, R9                  ; convert to float
        DIVF3   R11, R9, (R4)[R2]       ; B(IB)=M/FACT
        ADDL2   R1, R2                  ; increase R2 by NCOL
        SOBGTR  R0, LOOP3               ; decrease R0, if R0>0 continue
        RET
L1013:  BICB2   #224, R5                ; R5=I=I.AND.31
        EXTZV   R5, R8, R6, R9
        MOVL    R6, R7
        MOVL    (R3)+, R6
        ADDL2   R10, R9                 ; M=M+ILOW
        CVTLF   R9, R9                  ; convert to float
        DIVF3   R11, R9, (R4)[R2]       ; B(IB)=M/FACT
        ADDL2   R1, R2                  ; increase R2 by NCOL
        SOBGTR  R0, LOOP3               ; decrease R0, if R0>0 continue
RTS5C:  RET
;
S4C:    ASHL    #-3, R0, R5             ; R5=R0/8
        BNEQ    L4C
        BRW     LL4C
L4C:    MOVL    (R3)+, R7               ; R7=A(IA)
        EXTZV   #28, R8, R7, R9         ; extract upper bit field
        ADDL2   R10, R9                 ; M=M+ILOW
        CVTLF   R9, R9                  ; convert to float
        DIVF3   R11, R9, (R4)[R2]       ; B(IB)=M/FACT
        ADDL2   R1, R2                  ; increase R2 by NCOL
        EXTZV   #24, R8, R7, R9
        ADDL2   R10, R9                 ; M=M+ILOW
        CVTLF   R9, R9                  ; convert to float
        DIVF3   R11, R9, (R4)[R2]       ; B(IB)=M/FACT
        ADDL2   R1, R2
        EXTZV   #20, R8, R7, R9
        ADDL2   R10, R9                 ; M=M+ILOW
        CVTLF   R9, R9                  ; convert to float
        DIVF3   R11, R9, (R4)[R2]       ; B(IB)=M/FACT
        ADDL2   R1, R2
        EXTZV   #16, R8, R7, R9
        ADDL2   R10, R9                 ; M=M+ILOW
        CVTLF   R9, R9                  ; convert to float
        DIVF3   R11, R9, (R4)[R2]       ; B(IB)=M/FACT
        ADDL2   R1, R2
        EXTZV   #12, R8, R7, R9
        ADDL2   R10, R9                 ; M=M+ILOW
        CVTLF   R9, R9                  ; convert to float
        DIVF3   R11, R9, (R4)[R2]       ; B(IB)=M/FACT
        ADDL2   R1, R2
        EXTZV   #8, R8, R7, R9
        ADDL2   R10, R9                 ; M=M+ILOW
        CVTLF   R9, R9                  ; convert to float
        DIVF3   R11, R9, (R4)[R2]       ; B(IB)=M/FACT
        ADDL2   R1, R2
        EXTZV   #4, R8, R7, R9
        ADDL2   R10, R9                 ; M=M+ILOW
        CVTLF   R9, R9                  ; convert to float
        DIVF3   R11, R9, (R4)[R2]       ; B(IB)=M/FACT
        ADDL2   R1, R2                  ; increase R2 by NCOL
        EXTZV   #0, R8, R7, R9          ; extract lower bit field
        ADDL2   R10, R9                 ; M=M+ILOW
        CVTLF   R9, R9                  ; convert to float
        DIVF3   R11, R9, (R4)[R2]       ; B(IB)=M/FACT
        ADDL2   R1, R2
        DECL    R5                      ; decrease R5
        BEQL    LL4C
        BRW     L4C                     ; if R5>0 continue
R4C:    RET
LL4C:   BICL2   #-8, R0                 ; R0=R0.AND.7
        BEQL    R4C
        MOVL    (R3)+, R7               ; R7=A(IA)
        EXTZV   #28, R8, R7, R9
        ADDL2   R10, R9                 ; M=M+ILOW
        CVTLF   R9, R9                  ; convert to float
        DIVF3   R11, R9, (R4)[R2]       ; B(IB)=M/FACT
        ADDL2   R1, R2
        DECL    R0
        BEQL    R4C
        EXTZV   #24, R8, R7, R9
        ADDL2   R10, R9                 ; M=M+ILOW
        CVTLF   R9, R9                  ; convert to float
        DIVF3   R11, R9, (R4)[R2]       ; B(IB)=M/FACT
        ADDL2   R1, R2
        DECL    R0
        BEQL    R4C
        EXTZV   #20, R8, R7, R9
        ADDL2   R10, R9                 ; M=M+ILOW
        CVTLF   R9, R9                  ; convert to float
        DIVF3   R11, R9, (R4)[R2]       ; B(IB)=M/FACT
        ADDL2   R1, R2
        DECL    R0
        BEQL    R4C
        EXTZV   #16, R8, R7, R9
        ADDL2   R10, R9                 ; M=M+ILOW
        CVTLF   R9, R9                  ; convert to float
        DIVF3   R11, R9, (R4)[R2]       ; B(IB)=M/FACT
        ADDL2   R1, R2
        DECL    R0
        BEQL    RTS4C
        EXTZV   #12, R8, R7, R9
        ADDL2   R10, R9                 ; M=M+ILOW
        CVTLF   R9, R9                  ; convert to float
        DIVF3   R11, R9, (R4)[R2]       ; B(IB)=M/FACT
        ADDL2   R1, R2
        DECL    R0
        BEQL    RTS4C
        EXTZV   #8, R8, R7, R9
        ADDL2   R10, R9                 ; M=M+ILOW
        CVTLF   R9, R9                  ; convert to float
        DIVF3   R11, R9, (R4)[R2]       ; B(IB)=M/FACT
        ADDL2   R1, R2                  ; increase R2 by NCOL
        DECL    R0
        BEQL    RTS4C
        EXTZV   #4, R8, R7, R9          ; extract lower bit field
        ADDL2   R10, R9                 ; M=M+ILOW
        CVTLF   R9, R9                  ; convert to float
        DIVF3   R11, R9, (R4)[R2]       ; B(IB)=M/FACT
RTS4C:  RET
#endif
#endif
#if defined(ALEPH_C)
#include <stdio.h>
#include "cfromf.h"
FORT_CALL(dmpbl3) () {
  fprintf(stderr,"FATAL ERROR: unsupported routine dmpbl3 called.\n");
  exit(1);
}
#endif