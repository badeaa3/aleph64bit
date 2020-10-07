      SUBROUTINE ECLEAN
C------------------------------------------------------------
C
C! Cleans ETDI bank using information from EGLO bank
CKEY ECAL CLEAN  / USER
C  B. Bloch -Devaux  August 29,1989
C  Structure : SUBROUTINE
C              External references:WBANK, WDROP(BOS77)
C                                  UCOPY(CERNLIB)
C              Comdecks references:BCS,BMACRO
C  Input : none
C  Output : none
C  Banks  : input  - EGLO, ETDI
C                    ETHR (data cards)
C           output - JDETDI (work bank dropped at the end)
C  Action : removes from ETDI bank addresses present in EGLO
C-----------------------------------------------------------------------
      SAVE
      LOGICAL*1 LDEAD
      DIMENSION LDEAD(228,384,3)
      COMMON /LOCAL/ JDETDI
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON /BCS/   IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
      DATA IFIR/0/
C!    set of intrinsic functions to handle BOS banks
C - # of words/row in bank with index ID
      LCOLS(ID) = IW(ID+1)
C - # of rows in bank with index ID
      LROWS(ID) = IW(ID+2)
C - index of next row in the bank with index ID
      KNEXT(ID) = ID + LMHLEN + IW(ID+1)*IW(ID+2)
C - index of row # NRBOS in the bank with index ID
      KROW(ID,NRBOS) = ID + LMHLEN + IW(ID+1)*(NRBOS-1)
C - # of free words in the bank with index ID
      LFRWRD(ID) = ID + IW(ID) - KNEXT(ID)
C - # of free rows in the bank with index ID
      LFRROW(ID) = LFRWRD(ID) / LCOLS(ID)
C - Lth integer element of the NRBOSth row of the bank with index ID
      ITABL(ID,NRBOS,L) = IW(ID+LMHLEN+(NRBOS-1)*IW(ID+1)+L)
C - Lth real element of the NRBOSth row of the bank with index ID
      RTABL(ID,NRBOS,L) = RW(ID+LMHLEN+(NRBOS-1)*IW(ID+1)+L)
C
C ---------------------------------------------------------------------
      IF (IFIR.EQ.0) THEN
         IFIR = 1
         JDETDI = 0
         NETDI = NAMIND ('ETDI')
         NEGLO = NAMIND ('EGLO')
         DO 2 II= 1,228
         DO 2 JJ= 1,384
         DO 2 KK= 1,3
 2       LDEAD(II,JJ,KK) = .FALSE.
C     set threshold: look at ETHR data card to reset the threshold
         ITHR = 20000
         JETHR = IW(NAMIND('ETHR'))
         IF (JETHR.NE.0) THEN
            IF (IW(JETHR).GE.1) ITHR = IW(JETHR+1)
         ENDIF
C     build table LDEAD
         JEGLO = IW(NEGLO)
         IF (JEGLO.LE.0) RETURN
         IF (LROWS(JEGLO).EQ.0) RETURN
         DO 1 IROW = 1,LROWS(JEGLO)
            IAD = ITABL(JEGLO,IROW,1)
            ITET = IBITS(IAD,16,8)
            IPHI = IBITS(IAD,2,9)
            ISTK = IBITS(IAD,26,2)
            LDEAD(ITET,IPHI,ISTK) = .TRUE.
  1      CONTINUE
      ENDIF
C
      JEGLO = IW(NEGLO)
      IF (JEGLO.LE.0) GOTO 999
      IF (LROWS(JEGLO).EQ.0) GOTO 999
      JETDI = IW(NETDI)
      IF (JETDI.LE.0) GO TO 999
      IF (LROWS(JETDI).EQ.0) GO TO 999
C
C   Create JDETDI work bank
      CALL WBANK (IW,JDETDI,LCOLS(JETDI)*LROWS(JETDI)+LMHLEN,*999)
      IW(JDETDI+LMHCOL) = LCOLS(JETDI)
C
C  There are towers and noisy ones
      DO 10 I = 1,LROWS(JETDI)
C      Get tower address
        IAD = ITABL(JETDI,I,1)
        ITET = IBITS(IAD,16,8)
        IPHI = IBITS(IAD,2,9)
C      Reset channel if  noisy  and count how many storeys
C      are still above threshold ITHR in this tower
        NST = 0
        DO 11 IST = 1,3
        IF ( LDEAD(ITET,IPHI,IST)) IW(KROW(JETDI,I)+1+IST) =0
        IF (ITABL(JETDI,I,IST+1).GT.ITHR) NST = NST+1
  11    CONTINUE
        IF ( NST.GT.0) THEN
C          add that line to JDETDI bank
            KETDI = KROW(JETDI,I)
            KWORK = KNEXT(JDETDI)
            CALL UCOPY(IW(KETDI+1),IW(KWORK+1),LCOLS(JETDI))
            IW(JDETDI+LMHROW) = IW(JDETDI+LMHROW)+1
        ENDIF
  10  CONTINUE
C
C   compress JDETDI and copy it to ETDI, then drop JDETDI
      IF (LROWS(JDETDI).LT.LROWS(JETDI)) THEN
         LEN = LROWS(JDETDI)*LCOLS(JDETDI)+LMHLEN
         CALL WBANK (IW,JDETDI,LEN,*998)
         CALL BKFRW (IW,'ETDI',0,IW,JDETDI,*998)
      ENDIF
 998  CALL WDROP (IW,JDETDI)
C
 999  RETURN
      END