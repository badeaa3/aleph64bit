      SUBROUTINE TIZERO ( TMEAN ,IGOO )
C-----------------------------------------------------------------------
CKEY EDIR T0 BEAM
C! Calculate T0 from Ecal wire module PASTIS.
C-
C   Input  : None
C   Output : TMEAN = -9999. Tzero not available
C                  = Otherwise average mean
C            IGOO  = 0  Not in time with beam
C                    1  GOOD beam tag
C-
C   Called by   : SELEVT,SELCAL
C   Calls  : None
C   Input banks : PEWI/PWEI, EVEH
C-
C                                   Author: M.N.Minard       date !
C - modified by : F.Ranjard - 950511
C                 use PWEI when PEWI is not there
C-----------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON /BCS/   IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
      PARAMETER(JPEWMN=1,JPEWPD=2,JPEWSS=47,JPEWTI=55,LPEWIA=55)
C --
      DIMENSION ETCAL ( 3 ) , ECAL ( 3 )
      DATA NAPEWI, NAPWEI /2*0/
C --
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
C --
      IF (NAPEWI.EQ.0) THEN
         NAPEWI = NAMIND ('PEWI')
         NAPWEI = NAMIND ('PWEI')
      ENDIF
      KPEWI = IW ( NAPEWI)
      IF (KPEWI.EQ.0) KPEWI = IW(NAPWEI)
C
      CALL VZERO (ETCAL,3)
      CALL VZERO (ECAL,3)
      IGOO = 0
      NWIRE = 0
      TMEAN = -9999.
C --
C   Exclude run range where no t0 for End cap
C --
      KEVEH = IW (NAMIND('EVEH'))
      IRUNC = IW ( KEVEH + 2 )
C --
C   Calculate weigthed mean
C --
      IF ( KPEWI.EQ.0) GO TO 980
      LCOL = LCOLS (KPEWI)
      DO 100 IPEWI = 1,LROWS(KPEWI)
      IMOD = ITABL ( KPEWI,IPEWI,JPEWMN)
      ISC = 2
      IF ( IMOD .LT.13 ) ISC = 1
      IF ( IMOD.GT.24  ) ISC = 1
      IF (IRUNC.GT.2000 .AND. IRUNC.LT.6100) THEN
         IF (IMOD.EQ.25.OR.IMOD.EQ.26) GO TO 100
      ENDIF
C --
C    Calculate wire energy
C --
      ENSUM  = 0.
      DO 50 IADC = 1, 45
      ENSUM = ENSUM + FLOAT(ITABL(KPEWI,IPEWI,IADC+1))/1000000.
 50   CONTINUE
      IF ( ENSUM.LT. .50 ) GO TO 100
      NWIRE = NWIRE + 1
      IADC0 = ITABL ( KPEWI,IPEWI,JPEWSS)
      IF ( IADC0.GT.300) GO TO 100
      ECAL ( ISC ) = ECAL ( ISC) + ENSUM
      TZER = ITABL(KPEWI,IPEWI,LCOL)
      ETCAL (ISC) = ETCAL(ISC)+(ENSUM*TZER)
 100  CONTINUE
C --
C   Calculate pastis
C --
       DO 60 ISC =1,2
       IF ( ECAL(ISC) .LT.1.) THEN
          ETCAL ( ISC) = -9999.
          GO TO 60
       ENDIF
       ETCA = ETCAL ( ISC) / ECAL (ISC)
       ETCAL ( ISC) = ETCA
       TMEAN = -9999.
 60    CONTINUE
       ITYP = 0
       DO 70 ISC = 1,2
       IF ( ABS(ETCAL(ISC)).LT.ABS(TMEAN)) THEN
          TMEAN = ETCAL (ISC)
          ITYP = ISC
       ENDIF
 70    CONTINUE
       IF ( TMEAN.LT.-9000.AND.NWIRE.EQ.0) GO TO 980
       IF ( TMEAN.LT.-9000.AND.NWIRE.NE.0) TMEAN = -9000.
       IF ( ITYP.EQ.1.AND.(ABS(TMEAN).LT.100)) IGOO = 1
       IF ( ITYP.EQ.2.AND.ABS(TMEAN).LT.100.) IGOO = 1
 980   CONTINUE
       RETURN
       END
