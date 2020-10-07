      SUBROUTINE NREBYT(IOSTR,ICSTR,IRET)
C----------------------------------------------------------------------
C!  -
C!
C!   Author   :- Gerrit Graefe         10-MAY-1994
C!
C!   Inputs:
C!        - IOSTR   / I        original string from input file
C!          ICSTR   / I        correct string (as it should be)
C!
C!   Outputs:
C!        - IRET / I        return code  0=found a conversion
C!                                       1=found no conversion
C!                                       2=found no swapping
C!                                       3=unknown error
C!
C!   Libraries required: ALPHA,BOS77
C!
C!   Description
C!   ===========
C!
C?   This subroutine changes character strings from ASCII to EBCDIC or
C?   vice versa and repairs byte swapping. A call to the subroutine will
C?   find out, which way to handle character strings, a call to the entr
C?   NBYTSW will do the conversion according to the settings from NREBYT
C?
C?   WARNING:
C?
C?     NREBYT has to be called before NBYTSW. Otherwise the results are
C?     unpredictable !
C?
C!======================================================================
      IMPLICIT NONE
      SAVE    IMETH,ISWAP
      INTEGER IRET
      INTEGER I,J,K
      INTEGER IOCAR(4),IEBCAR(0:255),IASCAR(0:255),IMETH
      INTEGER IOSTR,ICSTR,INR,ISWAP,ICCAR(4)
      DATA IMETH,ISWAP/-1,-1/
      DATA IEBCAR/ 32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
     &             32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
     &             32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
     &             32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
     &             32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
     &             32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
     &             32, 32, 32, 32, 32, 32, 32, 32, 32, 32,
     &             32, 32, 32, 32, 32, 46, 60, 40, 43,124,
     &             38, 32, 32, 32, 32, 32, 32, 32, 32, 32,
     &             33, 36, 42, 41, 59, 94, 45, 32, 47, 32,
     &             32, 32, 32, 32, 32, 32, 32, 44, 37, 95,
     &             62, 63, 32, 32, 32, 32, 32, 32, 32, 32,
     &             32, 96, 58, 35, 64, 39, 61, 34, 32, 97,
     &             98, 99,100,101,102,103,104,105, 32, 32,
     &             32, 32, 32, 32, 32,106,107,108,109,110,
     &            111,112,113,114, 32, 32, 32, 32, 32, 32,
     &             32,126,115,116,117,118,119,120,121,122,
     &             32, 32, 32, 91, 32, 32, 32, 32, 32, 32,
     &             32, 32, 32, 32, 32, 32, 32, 32, 32, 93,
     &             32, 32,123, 65, 66, 67, 68, 69, 70, 71,
     &             72, 73, 32, 32, 32, 32, 32, 32,125, 74,
     &             75, 76, 77, 78, 79, 80, 81, 82, 32, 32,
     &             32, 32, 32, 32, 92, 32, 83, 84, 85, 86,
     &             87, 88, 89, 90, 32, 32, 32, 32, 32, 32,
     &             48, 49, 50, 51, 52, 53, 54, 55, 56, 57,
     &             32, 32, 32, 32, 32, 32/
C----------------------------------------------------------------------
      IRET=3
C
C!..FIRST FIND OUT HOW TO HANDLE CHARACTER VARIABLES
C
      IMETH=-1
      ISWAP=-1
      IF(IOSTR.EQ.ICSTR)THEN
        IMETH=0
        ISWAP=0
        IRET=0
        GOTO 999
      ENDIF
C..FILL IASCAR
      DO 100 I=0,255
        IASCAR(IEBCAR(I))=I
  100 CONTINUE
C..SPECIAL FOR SPACE

C..SPLIT IOSTR AND ICSTR IN SINGLE CHARACTERS
      DO 200 J=1,4
        IOCAR(J)=IAND(ISHFT(IOSTR,-8*(J-1)),255)
        ICCAR(J)=IAND(ISHFT(ICSTR,-8*(J-1)),255)
  200 CONTINUE
      INR=0
      DO 210 I=1,4
        DO 220 J=I,4
          IF(IOCAR(I).EQ.ICCAR(J))INR=INR+1
  220   CONTINUE
  210 CONTINUE
C..IF INR=4,THEN PERFORM ONLY BYTE SWAPPING, OTHERWISE CONVERSION NECCES
      IF(INR.EQ.4)THEN
        IMETH=0
        GOTO 300
      ENDIF
C..FIRST TRY: CONVERT NOCAR FROM EBCDIC TO ASCII
      DO 280 I=1,4
        IOCAR(I)=IEBCAR(IOCAR(I))
  280 CONTINUE
      INR=0
      DO 230 I=1,4
        DO 240 J=I,4
          IF(IOCAR(I).EQ.ICCAR(J))INR=INR+1
  240   CONTINUE
  230 CONTINUE
C..IF INR=4,THEN CONVERT FROM EBCDIC TO ASCII
      IF(INR.EQ.4)THEN
        IMETH=1
        GOTO 300
      ENDIF
C..SECOND TRY: CONVERT NOCAR FROM ASCII TO EBCDIC
      DO 250 I=1,4
        IOCAR(I)=IASCAR(IOCAR(I))
        IOCAR(I)=IASCAR(IOCAR(I))
  250 CONTINUE
      INR=0
      DO 260 I=1,4
        DO 270 J=I,4
          IF(IOCAR(I).EQ.ICCAR(J))INR=INR+1
  270   CONTINUE
  260 CONTINUE
C..IF INR=4,THEN CONVERT FROM ASCII TO EBCDIC
      IF(INR.EQ.4)THEN
        IMETH=2
        GOTO 300
      ENDIF
C..ELSE STOP HERE WITH ERROR RETURN
      IRET=1
      GOTO 999
C..TRY TO FIND OUT HOW TO SWAP BYTES:
  300 CONTINUE
      IF(IOCAR(1).EQ.ICCAR(1).AND.IOCAR(2).EQ.ICCAR(2).AND.
     &   IOCAR(3).EQ.ICCAR(3).AND.IOCAR(4).EQ.ICCAR(4))ISWAP=0
      IF(IOCAR(1).EQ.ICCAR(2).AND.IOCAR(2).EQ.ICCAR(1).AND.
     &   IOCAR(3).EQ.ICCAR(4).AND.IOCAR(4).EQ.ICCAR(3))ISWAP=1
      IF(IOCAR(1).EQ.ICCAR(3).AND.IOCAR(2).EQ.ICCAR(4).AND.
     &   IOCAR(3).EQ.ICCAR(1).AND.IOCAR(4).EQ.ICCAR(2))ISWAP=2
      IF(IOCAR(1).EQ.ICCAR(4).AND.IOCAR(2).EQ.ICCAR(3).AND.
     &   IOCAR(3).EQ.ICCAR(2).AND.IOCAR(4).EQ.ICCAR(1))ISWAP=3
      IF(ISWAP.EQ.-1)THEN
        IRET=2
        GOTO 999
      ENDIF
      IRET=0
      goto 999
C
C..ENTRY NBYTSW
C
      ENTRY NBYTSW(IOSTR,ICSTR,IRET)
C
      IF(ISWAP.LT.0.OR.IMETH.LT.0)THEN
        IRET=3
        GOTO 999
      ENDIF
      DO 400 J=1,4
        IOCAR(J)=IAND(ISHFT(IOSTR,-8*(J-1)),255)
  400 CONTINUE
C..CHARACTER CONVERSION
      IF(IMETH.NE.0)THEN
        IF(IMETH.EQ.1)THEN
          DO 410 I=1,4
            IOCAR(I)=IEBCAR(IOCAR(I))
  410     CONTINUE
        ELSE
          DO 420 I=1,4
            IOCAR(I)=IASCAR(IOCAR(I))
  420     CONTINUE
        ENDIF
      ENDIF
C..BYTE SWAPPING
      IF(ISWAP.EQ.0)THEN
        DO 430 I=1,4
          ICCAR(I)=IOCAR(I)
  430   CONTINUE
        IRET=0
        GOTO 500
      ELSEIF(ISWAP.EQ.1)THEN
        ICCAR(2)=IOCAR(1)
        ICCAR(1)=IOCAR(2)
        ICCAR(4)=IOCAR(3)
        ICCAR(3)=IOCAR(4)
        IRET=0
        GOTO 500
      ELSEIF(ISWAP.EQ.2)THEN
        ICCAR(3)=IOCAR(1)
        ICCAR(4)=IOCAR(2)
        ICCAR(1)=IOCAR(3)
        ICCAR(2)=IOCAR(4)
        IRET=0
        GOTO 500
      ELSEIF(ISWAP.EQ.3)THEN
        ICCAR(4)=IOCAR(1)
        ICCAR(3)=IOCAR(2)
        ICCAR(2)=IOCAR(3)
        ICCAR(1)=IOCAR(4)
        IRET=0
        GOTO 500
      ENDIF
  500 CONTINUE
      ICSTR=0
      DO 440 J=1,4
        ICSTR=IOR(ICSTR,ISHFT(IAND(ICCAR(J),255),8*(J-1)))
  440 CONTINUE
  999 RETURN
      END
