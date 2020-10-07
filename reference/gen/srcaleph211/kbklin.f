      INTEGER FUNCTION KBKLIN (IPART,IUGEN)
C -----------------------------------------------------------
C - J.Boucrot - F.Ranjard - 870423
C
C! Book and fill KLIN bank
CKEY KINE KINGAL FILL BANK /   INTERNAL
C  the KLIN bank contains the user particle# IUGEN of an ALEPH particle#
C  IPART
C
C - structure : INTEGER FUNCTION subprogram
C               User Entry Names : KBKLIN
C               External References: AUBOS (ALEPHLIB)
C                                    BLIST/BKFMT(BOS77)
C               Comdecks referenced: BCS, KIPARA, BMACRO
C
C - usage:  JKLIN = KBKLIN (IPART,IUGEN)
C - input:  IPART = ALEPH particle# (row# in PART bank)
C           IUGEN = user generator particle#
C - output: KBKLIN= index of KLIN bank
C                   0  means : PART or KLIN bank missing
C                   -N means : cannot extend KLIN after row# N
      SAVE
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON /BCS/   IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
CKEY KINE KINGAL DEFAULT
      PARAMETER (LHKIN=3, LPKIN=5, LKVX=2, LHVER=3, LPVER=5, LVKI=50)
      PARAMETER (LGDCA=32)
      PARAMETER (LRPART=200, LCKLIN=1)
      PARAMETER (LRECL=16020, LRUN=1, LEXP=1001, LRTYP=1000)
      CHARACTER*60 LTITL
      PARAMETER (LUCOD=0, LNOTRK=100, LTITL='KINGAL run')
      PARAMETER (LUTRK=350)
      PARAMETER (BFIEL=15., CFIEL=BFIEL*3.E-4)
      DATA NAPAR /0/
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
C ---------------------------------------------------------
C
      KBKLIN = 0
C
CKEY KINE PART KLIN
      IF (NAPAR .EQ. 0) THEN
         NAPAR = NAMIND ('PART')
         NAKLI = NAMIND ('KLIN')
      ENDIF
C
C - Get PART index
C
      JPART = IW(NAPAR)
      IF (JPART.EQ.0) GOTO 999
      NPART = LROWS (JPART)
C
C - Get KLIN index
C
      JKLIN = IW(NAKLI)
      IF (JKLIN .EQ.0) THEN
C     Create the KLIN bank
         CALL AUBOS ('KLIN',0,LCKLIN*NPART+LMHLEN,JKLIN,IGARB)
         IF (JKLIN.EQ.0) GOTO 999
         IW(JKLIN+LMHCOL) = LCKLIN
         IW(JKLIN+LMHROW) = NPART
         CALL BKFMT ('KLIN','I')
         CALL BLIST (IW,'C+','KLIN')
      ELSE
C     KLIN exists, test the length
         NKLIN = LROWS(JKLIN)
         IF (IPART .GT. NKLIN) THEN
            CALL AUBOS ('KLIN',0,LCKLIN*NPART+LMHLEN,JKLIN,IGARB)
            IF (JKLIN .EQ. 0) THEN
               KBKLIN = - NKLIN
               GOTO 999
            ELSE
               IW(JKLIN+LMHROW) = NPART
            ENDIF
         ENDIF
      ENDIF
C
C - Fill KLIN bank
C
      KKLIN = KROW(JKLIN,IPART)
      IW(KKLIN+1) = IUGEN
C
      KBKLIN = JKLIN
C
 999  RETURN
      END
