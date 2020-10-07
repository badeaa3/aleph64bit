      SUBROUTINE ICRCOO(IER)
C-----------------------------------------------------------------------
C! Create ITC coordinates from digitisings
C!
CKEY IPREDATA ITC
C!    Author     :- J. Sedgbeer   89/03/03
C!    Modified   :- J. Sedgbeer   89/04/11
C!    Modified   :- R. Johnson    89/11/02   Add bank IFCO
C!    Modified   :- J. Sedgbeer   90/01/04  Correct swapped wire numbers
C!    Modified   :- J. Sedgbeer   91/01/07 Protect for missing bank ICAE
C!    Modified   :- J. Sedgbeer   92/01/30 Remove obsolete IFCO
C!    Modified   :- J. Sedgbeer   95/04/02 Add call to RQBUNC to get
C!                                bunchtrain info - put into /IBUNCC/.
C!
C!    Input:
C!      commons:       /BCS/    => bank  IDIG, DB banks ICAE,ISFE
C!                     /ITWICC/ ITC wire geom. Filled by IGEOMW
C!      parameters:    ITCOJJ   parameters for ITCO bank
C!                     ICAEJJ   parameters for ICAE DB bank
C!                     ISFEJJ   parameters for ISFE DB bank
C!                     IDIGJP
C!                     ALCONS
C!
C!    Output:
C!      IER   /I    : Error flag:
C!                       IER = 0 if all O.K.
C!                       IER = 1 if no IDIG bank, or data not OK, or
C!                               no good bunch info.
C!                       IER = 2 if no room to create banks
C!                       IER = 3 no digits in IDIG bank
C!                       IER = 4 ITCO bank empty - no valid coords made
C!                               ITCO and IDCR dropped. (IDIG not empty)
C!                       IER = -1  bad data - wire out of range
C!                       if IER > 0  no ITCO or IDCR created.
C!                       if IER < 0 ITCO and IDCR created
C!      ITCO             bank of ITC coordinates
C!      IDCR             digit-to-coord relation bank
C!      commons:       /BCS/ for banks IDCR and ITCO
C!
C!    calls     : AUBOS  (Alephlib)
C!                ITSWCO (Alephlib)
C!                ITDRIF (Alephlib)
C!                ITROTN (Alephlib)
C!                RQBUNC
C!
C!    Libraries required: BOS
C!
C! This routine creates ITC coords. from digis.
C! The ITC Alephlib routines needed to do this are:-
C!                 ICRCOO,ITSWCO,ITDRIF and ITROTN.
C! Also, common blocks containing constants needed MUST be initialised
C! once per run by using the ITC Alephlib routine: IRDDAF.
C!
C? Get IDIG bank
C? Get bunch-train info (sub RQBUNC) put into /IBUNCC/
C? Loop over digitisings
C?   Correct for swapped channels (wire number)
C?   Find coord of hit sense wire
C?   Transform coord. to ALEPH frame
C?   Find drift distance from TDC value
C?   Form ITC coord.
C?   Add coord to ITCO bank
C?   Put digit to coord. relationship into IDCR bank
C? End Loop
C-----------------------------------------------------------------------
      SAVE
C I/O commons and parameters
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON /BCS/   IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
C! define universal constants
      REAL PI, TWOPI, PIBY2, PIBY3, PIBY4, PIBY6, PIBY8, PIBY12
      REAL RADEG, DEGRA
      REAL CLGHT, ALDEDX
      PARAMETER (PI=3.141592653589)
      PARAMETER (RADEG=180./PI, DEGRA=PI/180.)
      PARAMETER (TWOPI = 2.*PI , PIBY2 = PI/2., PIBY4 = PI/4.)
      PARAMETER (PIBY6 = PI/6. , PIBY8 = PI/8.)
      PARAMETER (PIBY12= PI/12., PIBY3 = PI/3.)
      PARAMETER (CLGHT = 29.9792458, ALDEDX = 0.000307)
      PARAMETER (JWIRIT=8,MWIRIT=960)
      COMMON/ITWICC/RWIRIT(JWIRIT),NWIRIT(JWIRIT),IWIRIT(JWIRIT),
     +              PHWRIT(JWIRIT),CELWIT(JWIRIT),WZMXIT,SGMXIT
      PARAMETER(JITCWN=1,JITCRA=2,JITCP1=3,JITCP2=4,JITCZH=5,JITCSR=6,
     +          JITCSZ=7,JITCDT=8,LITCOA=8)
      PARAMETER(JICAID=1,JICAVR=2,JICAWA=4,JICAWC=5,LICAEA=5)
      PARAMETER(JISFID=1,JISFVR=2,JISFRT=4,JISFZT=5,LISFEA=5)
      INTEGER NBITWN,NBITRP,NBITZT,NBITQR,NBITQZ,NBITAM,NBITVS
      INTEGER IBITWN,IBITRP,IBITZT,IBITQR,IBITQZ,IBITAM,IBITVS
      PARAMETER(NBITWN=10,NBITRP=9 ,NBITZT=9 ,NBITQR=1 ,NBITQZ=1,
     +          NBITAM=1 ,NBITVS=1)
      PARAMETER(IBITWN=0 ,IBITRP=10,IBITZT=19,IBITQR=28,IBITQZ=29,
     +          IBITAM=30,IBITVS=31)
      INTEGER IBUNCH
      REAL TBUNCH
      COMMON/IBUNCC/IBUNCH,TBUNCH
      LOGICAL FIRST
      INTEGER IBUN,INBU
      EXTERNAL NAMIND,MDROP
      DATA FIRST/.TRUE./
C-----------------------------------------------------------------------
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
C-----------------------------------------------------------------------
      IF(FIRST) THEN
        FIRST = .FALSE.
        NITCO = NAMIND('ITCO')
        NIDIG = NAMIND('IDIG')
        NICAE = NAMIND('ICAE')
        NISFE = NAMIND('ISFE')
        CALL BKFMT('ITCO','2I,(I,7F)')
        CALL BKFMT('IDCR','I')
      ENDIF
      IER = 0
C
C Get bunch train info. Fill /IBUNCC/. If error then cannot make coords.
C If no bunch train set default values.
C
      CALL RQBUNC(IBUN,INBU,NWAG,IQUA)
      IBUNCH = IBUN
      TBUNCH = INBU
      IF(IBUN.LT.0 .OR. INBU.LT.0) GOTO 900
      IF(IBUN.EQ.0) IBUNCH = 1

C Check that IDIG bank exists and is OK (use ISFE bank - note: if R-phi
C  TDC data not OK then cannot use Z data, therefore no coords.)
C
      KIDIG = IW(NIDIG)
      IF(KIDIG.EQ.0) GOTO 900
      IF(IW(KIDIG).LE.0) GOTO 920
      KISFE = IW(NISFE)
      IOK = IW(KISFE+LMHLEN+JISFRT)
      IF (IOK.NE.1) GOTO 900
C
C Find number of useful digits.
C
      ND  = LROWS(KIDIG)
      IF(ND.LE.0) GOTO 920
C
C Create banks for ITC coordinates.
C
      NNCO = ND*LITCOA + LMHLEN
      CALL AUBOS('ITCO',0,NNCO,KITCO,IGARB)
      IF(IGARB.EQ.2) GOTO 910
C
C Create bank for digi -> coord reln. If no space then drop previously
C                         created ITCO bank .
C
      CALL AUBOS('IDCR',0,ND+LMHLEN,KIDCR,IGARB)
      IF(IGARB.EQ.2) THEN
        IND = MDROP(IW,'ITCO',0)
        GOTO 910
      ENDIF
      IW(KIDCR+LMHCOL) = 1
      IW(KIDCR+LMHROW) = ND
      KITCO = IW(NITCO)
      KIDIG = IW(NIDIG)
      KICAE = IW(NICAE)
      NSWAP = 0
      IF(KICAE.GT.0) NSWAP = LROWS(KICAE)
C
C-----------------------------------------------------------------------
C Loop over all digits.
C
      NCO  = 0
C
      DO 100 JD =1,ND
        IWIRE = IBITS(IW(KIDIG+LMHLEN+JD),IBITWN,NBITWN)
        ITDC  = IBITS(IW(KIDIG+LMHLEN+JD),IBITRP,NBITRP)
C
C Note that the Z TDC is 10 bit; only the 9 most significant bits are
C stored in the IDIG bank (the last bit is only a phase bit). So the
C digitising must be multipled by 2 to obtain the TDC value.
C
        IZDIG = IBITS(IW(KIDIG+LMHLEN+JD),IBITZT,NBITZT)*2
C
C Correct for swapped channels (wire-numbers). Use ICAE DB bank.
C
        IF(NSWAP.GT.0) THEN
          DO 50 I=1,NSWAP
            KK = KROW(KICAE,I)
            IF(IWIRE.EQ.IW(KK+JICAWA)) THEN
              IWIRE=IW(KK+JICAWC)
              GOTO 60
            ENDIF
   50     CONTINUE
   60     CONTINUE
        ENDIF
C
        IF(IWIRE.LE.0.OR.IWIRE.GT.MWIRIT) THEN
          IER = -1
          GOTO 100
        ENDIF
        IF(IWIRE.LE.IWIRIT(5)) THEN
          IL = (IWIRE-1)/NWIRIT(1) + 1
        ELSE
          IL = (IWIRE-IWIRIT(5)-1)/NWIRIT(5) + 5
        ENDIF
C
C  Get sagged sense wire coord.
C
        CALL ITSWCO(IL,IWIRE,IZDIG,RSW,PHSW,ZSW,SIGZ)
C
C  Transform to ALEPH frame
C
        CALL ITROTN(RSW,PHSW,ZSW)
C
C  Get Drift Distance from TDC value
C
        CALL ITDRIF(IL,IWIRE,ITDC,RSW,ZSW,SIGZ,DIST1,DIST2,TIME,SIGRP)
        IF(SIGRP.LT.0.) GOTO 100
C
C Make coordinate - phi must be in range [0,2pi]
C
        DPHI1 = DIST1/RSW
        DPHI2 = DIST2/RSW
        PHI1 = PHSW + DPHI1
        PHI2 = PHSW + DPHI2
        IF(PHI1.GT.TWOPI) PHI1 = PHI1 - TWOPI
        IF(PHI1.LT. 0.0 ) PHI1 = PHI1 + TWOPI
        IF(PHI2.GT.TWOPI) PHI2 = PHI2 - TWOPI
        IF(PHI2.LT. 0.0 ) PHI2 = PHI2 + TWOPI
C
C  Add Hit to ITCO coordinates bank
C
        NCO = NCO+1
        ICO = (NCO-1)*LITCOA + LMHLEN
        IW(KITCO+ICO+JITCWN) = IWIRE+1000*IL
        RW(KITCO+ICO+JITCRA) = RSW
        RW(KITCO+ICO+JITCP1) = PHI1
        RW(KITCO+ICO+JITCP2) = PHI2
        RW(KITCO+ICO+JITCZH) = ZSW
        RW(KITCO+ICO+JITCSR) = SIGRP**2
        RW(KITCO+ICO+JITCSZ) = SIGZ**2
        RW(KITCO+ICO+JITCDT) = TIME
C
        IW(KIDCR+LMHLEN+JD) = NCO
  100 CONTINUE
C-----------------------------------------------------------------------
C Fill header words
C
      IW(KITCO+LMHCOL) = LITCOA
      IW(KITCO+LMHROW) = NCO
C
C Adjust size of ITCO bank.
C
      LEN = NCO*LITCOA + LMHLEN
      CALL AUBOS('ITCO',0,LEN,KITCO,IGARB)
      IF(IGARB.EQ.2) GOTO 910
      IF(NCO.LE.0) GOTO 930
      GOTO 999
C-----------------------------------------------------------------------
C Error returns.
C
  900 IER = 1
      GOTO 999
C
  910 IER = 2
      GOTO 999
C
  920 IER = 3
      GOTO 999
C
  930 IER = 4
      IND = MDROP(IW,'ITCO',0)
      IND = MDROP(IW,'IDCR',0)
C-----------------------------------------------------------------------
  999 CONTINUE
      END
