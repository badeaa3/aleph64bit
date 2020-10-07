      SUBROUTINE AMUID(ITRAC,IRUN,IBE,IBT,IM1,IM2,NEXP,NFIR,N10,N03,
     &  XMULT,RAPP,ANG,ISHAD,SUDNT,IDF,IMCF,IER)
C----------------------------------------------------------------------
C
CKEY MUONID MUON INTERFACE / INTERNAL
C
C!  - Get the muon id information from the banks MCAD,HMAD,MUID
C!
C!    Author    - G.Taylor              15-MAY-1992
C!
C!    Inputs  :  ITRAC /I = Track number in FRFT bank
C!    Outputs :  IRUN  /I = (=0)
C!               IBE   /I = Expected HCAL bit map
C!               IBT   /I = Found HCAL bit map
C!               IM1   /I = num hits in first layer of muon chambers
C!               IM2   /I = num hits in first layer of muon chambers
C!               NEXP  /I = num fired planes expected in hcal
C!               NFIR  /I = num fired planes in hcal
C!               N10   /I = num fired planes in last 10 expected
C!               N03   /I = num fired planes in last 3 expected
C!               XMULT /R = excess digital multiplicity in last 10
C!                           hcal planes
C!               RAPP  /R = (dist/dcut) for closest muon chamber hit
C!               ANG   /R = angle between shadowing track and muon
C!                          chamber track segment
C!               ISHAD /R = shadowing flag (=0 if not shadowing,
C!                          otherwise is the JULIA track number which
C!                          it was shadowing)
C!               SUDNT /R = sum of hcal residuals
C!               IDF   /I = muon id flag (see bank MUID)
C!               IMCF  /I = (=0)
C!               IER   /I = (=0)
C!======================================================================
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON /BCS/   IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
      PARAMETER(JHMANF=1,JHMANE=2,JHMANL=3,JHMAMH=4,JHMAIG=5,JHMAED=6,
     +          JHMACS=7,JHMAND=8,JHMAIE=9,JHMAIT=10,JHMAIF=11,
     +          JHMATN=12,LHMADA=12)
      PARAMETER(JMCANH=1,JMCADH=3,JMCADC=5,JMCAAM=7,JMCAAC=8,JMCATN=9,
     +          LMCADA=9)
      PARAMETER(JMUIIF=1,JMUISR=2,JMUIDM=3,JMUIST=4,JMUITN=5,LMUIDA=5)
      DATA NHMAD,NMCAD,NFRFT,NMHIT,NMTHR,NMUID /6*0/
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
C----------------------------------------------------------------------
      IF(NHMAD.EQ.0) THEN
        NHMAD = NAMIND('HMAD')
        NMCAD = NAMIND('MCAD')
        NFRFT = NAMIND('FRFT')
        NMHIT = NAMIND('MHIT')
        NMTHR = NAMIND('MTHR')
        NMUID = NAMIND('MUID')
      ENDIF
C
      KHMAD = IW(NHMAD)
      KMCAD = IW(NMCAD)
      KMTHR = IW(NMTHR)
      KMHIT = IW(NMHIT)
      KFRFT = IW(NFRFT)
      KMUID = IW(NMUID)
C
      IRUN=0
      IMCF =0
      IER =0
C
      IBE=0
      IBT=0
      MULT = 0
      IF (KHMAD.LE.0) GOTO 11
      DO 10 IMAD = 1,LROWS(KHMAD)
        IF (ITRAC.EQ.ITABL(KHMAD,IMAD,JHMATN)) THEN
          IBE = ITABL(KHMAD,IMAD,JHMAIE)
          IBT = ITABL(KHMAD,IMAD,JHMAIT)
          MULT = ITABL(KHMAD,IMAD,JHMAMH)
          GOTO 11
        ENDIF
   10 CONTINUE
   11 CONTINUE
      XMULT = FLOAT(MULT)/100.
      NFIR = 0
      N10 = 0
      NEXP = 0
      N03 = 0
      DO 12 LAY = 22,0,-1
        NEXP = IBITS(IBE,LAY,1) + NEXP
        IBTF = IBITS(IBT,LAY,1)
        IF (IBTF.NE.0) THEN
          IF (NEXP.LE.3) N03 = N03 + 1
          IF (NEXP.LE.10) N10 = N10 + 1
          NFIR = NFIR + 1
        ENDIF
   12 CONTINUE
      IF(N10.GT.10) N10=10
      IF(N03.GT.3) N03=3
C
      IM1 = 0
      IM2 = 0
      RAPP=-1.
      ANG=-1.
      IF (KMCAD.LE.0) GOTO 21
      DO 20 ICAD = 1,LROWS(KMCAD)
        IF (ITRAC.EQ.ITABL(KMCAD,ICAD,JMCATN)) THEN
          IM1 = ITABL(KMCAD,ICAD,JMCANH)
          IM2 = ITABL(KMCAD,ICAD,JMCANH+1)
          R1=1000.
          R2=1000.
          IF (IM1.GT.0.AND.RTABL(KMCAD,ICAD,JMCADC).GT..0001)THEN
            R1=RTABL(KMCAD,ICAD,JMCADH)/RTABL(KMCAD,ICAD,JMCADC)
          ENDIF
          IF (IM2.GT.0.AND.RTABL(KMCAD,ICAD,JMCADC+1).GT..0001)THEN
            R2=RTABL(KMCAD,ICAD,JMCADH+1)/RTABL(KMCAD,ICAD,JMCADC+1)
          ENDIF
          IF(IM1.GT.0.AND.IM2.GT.0.AND.RTABL(KMCAD,ICAD,JMCAAC).GT.
     &           0.00001)
     &           ANG=RTABL(KMCAD,ICAD,JMCAAM)/RTABL(KMCAD,ICAD,JMCAAC)
          IF(MIN(R1,R2).LT.999.) RAPP=MIN(R1,R2)
          GOTO 21
        ENDIF
   20 CONTINUE
   21 CONTINUE
C
      IDF=0
      ISHAD=0
      SUDNT=0.
      IF (KMUID.LE.0) GOTO 31
      DO 30 IMUID = 1,LROWS(KMUID)
        IF (ITRAC.EQ.ITABL(KMUID,IMUID,JMUITN)) THEN
          IDF = ITABL(KMUID,IMUID,JMUIIF)
          ISHAD = ITABL(KMUID,IMUID,JMUIST)
          SUDNT = RTABL(KMUID,IMUID,JMUISR)
          GOTO 31
        ENDIF
   30 CONTINUE
   31 CONTINUE
      RETURN
      END
