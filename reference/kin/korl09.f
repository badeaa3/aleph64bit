      SUBROUTINE ASKUSI(IGCOD)
C--------------------------------------------------------------------
C
C (JETSET7.4                     B Bloch april 1996
C       from KORL08  modified  by J.Boucrot and Agnieska for KORL09
C                              + some formal mods by BBL March 99
C                              + XVRT card
C--------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
      COMMON / IDPART/ IA1
      COMMON / INOUT / INUT,IOUT
      COMMON / KGCOMM / ISTA,IDPR,ECMS,WEIT,VRTEX(4),TABL(55),NEVENT(8)
      PARAMETER (L1MST=200, L1PAR=200)
      PARAMETER (L2PAR=500, L2PARF=2000 )
      PARAMETER (LJNPAR=4000)
      COMMON /LUDAT1/ MSTU(L1MST),PARU(L1PAR),MSTJ(L1MST),PARJ(L1PAR)
      COMMON /LUDAT2/ KCHG(L2PAR,3),PMAS(L2PAR,4),PARF(L2PARF),VCKM(4,4)
      COMMON /LUDAT3/ MDCY(L2PAR,3),MDME(L2PARF,2),BRAT(L2PARF),
     &                KFDP(L2PARF,5)
      COMMON /LUDAT4/ CHAF(L2PAR)
      CHARACTER*8 CHAF
      COMMON /LUJETS/ N7LU,K7LU(LJNPAR,5),P7LU(LJNPAR,5),V7LU(LJNPAR,5)
C
      COMMON / TAUBRA / GAMPRT(30),JLIST(30),NCHAN
      COMMON / TAUKLE / BRA1,BRK0,BRK0B,BRKS
      REAL*4            BRA1,BRK0,BRK0B,BRKS
      COMMON / VERTX / IFVRT,XVRT(3),SXVRT(3)
C VVVVVVVVVVVVVVVVVVVVVV  JB 970403 VVVVVVVVVVVVVVVVVVVVVVVV
C
      COMMON / KALINO / IFKALIN
      COMMON / SPECX  / IFLEPTOK,INTER,XMX,DELTA
      real*8 xmx,delta
      COMMON / JUKBOX / IBOXU
      COMMON / PHCUTS / EPHMIN,EPHMAX,XTFMIN,XTFMAX,COSTHM
C ^^^^^^^^^^^^^^^^^^^^^ JB 970403 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

      DIMENSION E1(3),E2(3),SDVRT(3),aux(100)
C
C Generator code (see KINLIB DOC)
C
      PARAMETER ( IGCO = 4010 )
      PARAMETER ( IVER = 100  )
C
      PARAMETER (LPDEC = 48)
      INTEGER NODEC(LPDEC)
      INTEGER ALTABL,ALRLEP
      EXTERNAL ALTABL ,ALRLEP
      CHARACTER TNAM*12
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
C
C   Return generator code
C
      IGCOD= IGCO
      INUT = IW(5)
      IOUT = IW(6)
      WRITE(IOUT,101) IGCOD ,IVER
 101  FORMAT(/,10X,'KORL08 - CODE NUMBER =',I4,
     &       /,10X,'**************************',
     &       /,10X,' SUBVERSION  :',I10 ,
     &   /,10x,'Last mod = March 26 ,1998  ')
C
C Input parameters for the generator (see subroutine koralz for comments
C
      ENE    = 80.5
      AMZ    = 91.18
      AMTOP  = 100.
      AMH    = 100.
      AMNUTA = 0.001
      AMNEUT = 0.010
      SINW2  = 0.2293
      GAMM   = 2.484
      KEYGSW = 4
      KEYRAD = 12                   ! warning  new default YFS3.0
      KEYWLB = 1
      ITFIN  = 1
      NNEUT  = 3
      XK0    = 0.01
      VVMIN  = 0.00001
      VVMAX  = .99100000
      KEYYFS = 1000011
C VVVVVVVVVVVVVVVVVVVVVV  JB 970403 VVVVVVVVVVVVVVVVVVVVVVVV
C Default parameters for anomalous couplings, see kzphynew for comments
      IBOXU    = 0
      IFKALIN  = 0
      IFLEPTOK = 0
      INTER    = -1
      XMX      = 1000.
      DELTA    = -0.2
C Default values for photon cuts
      EPHMIN=1.
      EPHMAX=1000.
      XTFMIN=0.
      XTFMAX=1.
      COSTHM=1.
C ^^^^^^^^^^^^^^^^^^^^^ JB 970403 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
C
C Lund7.3 identifier for electron = -11
C
      KFB =-11
      DO 10 I = 1,3
       E1(I) = 0.
   10  E2(I) = 0.
      JAK1   =  0
      JAK2   =  0
      ISPIN  =  1
      ITDKRC =  1
      XK0DEC =  .001
      GV     =  1.
      GA     = -1.
C
C  The default values can be changed by the DATA CARD GKR7
C
      NAGKOR = NAMIND('GKR7')
      JGENE = IW(NAGKOR)
      IF(JGENE.NE.0) THEN
       AMZ    = RW(JGENE+1)
       AMTOP  = RW(JGENE+2)
       AMH    = RW(JGENE+3)
       AMNUTA = RW(JGENE+4)
       AMNEUT = RW(JGENE+5)
       SINW2  = RW(JGENE+6)
       GAMM   = RW(JGENE+7)
       KEYGSW = IW(JGENE+8)
       KEYRAD = IW(JGENE+9)
       KEYWLB = IW(JGENE+10)
       ITFIN  = IW(JGENE+11)
       NNEUT  = IW(JGENE+12)
       XK0    = RW(JGENE+13)
       VVMIN  = RW(JGENE+14)
       VVMAX  = RW(JGENE+15)
       KEYYFS = IW(JGENE+16)
      ENDIF
C
C  by the DATA CARD GBEA
C
      NAGBEA = NAMIND('GBE7')
      JGBEA = IW(NAGBEA)
      IF(JGBEA.NE.0) THEN
       ENE   = RW(JGBEA+1)
       KFB   = IW(JGBEA+2)
       E1(1) = RW(JGBEA+3)
       E1(2) = RW(JGBEA+4)
       E1(3) = RW(JGBEA+5)
       E2(1) = RW(JGBEA+6)
       E2(2) = RW(JGBEA+7)
       E2(3) = RW(JGBEA+8)
      ENDIF
C
C  by the DATA CARD GTAU
C
      NAGTAU = NAMIND('GTAU')
      JGTAU = IW(NAGTAU)
      IF(JGTAU.NE.0) THEN
       JAK1   = IW(JGTAU+1)
       JAK2   = IW(JGTAU+2)
       ISPIN  = IW(JGTAU+3)
       ITDKRC = IW(JGTAU+4)
       XK0DEC = RW(JGTAU+5)
       GV     = RW(JGTAU+6)
       GA     = RW(JGTAU+7)
      ENDIF
C VVVVVVVVVVVVVVVVVVVVV JB 970403 VVVVVVVVVVVVVVVVVVVVVVV
C
C  The default values can be changed by the DATA CARD GKR9
C
      NAKOR9 = NAMIND('GKR9')
      JKOR9 = IW(NAKOR9)
      IF(JKOR9.NE.0) THEN
        IBOXU   = IW(JKOR9+1)
        IFKALIN = IW(JKOR9+2)
        IFLEPTOK= IW(JKOR9+3)
        INTER   = IW(JKOR9+4)
        XMX     = RW(JKOR9+5)
        DELTA   = RW(JKOR9+6)
      ENDIF
C
C  The default values can be changed by the DATA CARD GCUT
C
      NAPHCU = NAMIND('GCUT')
      JPHCU = IW(NAPHCU)
      IF(JPHCU.NE.0) THEN
        EPHMIN  = RW(JPHCU+1)
        EPHMAX  = RW(JPHCU+2)
        XTFMIN  = RW(JPHCU+3)
        XTFMAX  = RW(JPHCU+4)
        COSTHM  = RW(JPHCU+5)
      ENDIF
C ^^^^^^^^^^^^^^^^^^^^^ JB 970403 ^^^^^^^^^^^^^^^^^^^^^^^^^
C
C  All the parameters are stored in TABL(I)
C
CAJ 10/03/97 !!!
CC    vvmax  = 1.0 -(1.8/ENE)**2
      TABL(1)  = AMZ
      TABL(2)  = AMTOP
      TABL(3)  = AMH
      TABL(4)  = AMNUTA
      TABL(5)  = AMNEUT
      TABL(6)  = SINW2
      TABL(7)  = GAMM
      TABL(8)  = KEYGSW
      TABL(9)  = KEYRAD
      TABL(10) = KEYWLB
      TABL(11) = ITFIN
      TABL(12) = NNEUT
      TABL(13) = XK0
      TABL(14) = VVMIN
      TABL(15) = VVMAX
      TABL(34) = KEYYFS
      TABL(16) = ENE
      TABL(17) = KFB
      TABL(18) = E1(1)
      TABL(19) = E1(2)
      TABL(20) = E1(3)
      TABL(21) = E2(1)
      TABL(22) = E2(2)
      TABL(23) = E2(3)
      TABL(24) = JAK1
      TABL(25) = JAK2
      TABL(26) = ISPIN
      TABL(27) = ITDKRC
      TABL(28) = XK0DEC
      TABL(29) = GV
      TABL(30) = GA
C
C  Main vertex initialization
C
      SDVRT(1) = 0.0185
      SDVRT(2) = 0.0008
      SDVRT(3) = 1.02
      NASVRT = NAMIND('SVRT')
      JSVRT = IW(NASVRT)
      IF(JSVRT.NE.0) THEN
       SDVRT(1) = RW(JSVRT+1)
       SDVRT(2) = RW(JSVRT+2)
       SDVRT(3) = RW(JSVRT+3)
      ENDIF
      TABL(31) = SDVRT(1)
      TABL(32) = SDVRT(2)
      TABL(33) = SDVRT(3)
C   get an offset for position of interaction point
C   if needed get a smearing on this position
C   XVRT    x      y      z    ( sz    sy    sz)
C
        call vzero(XVRT,3)
        CALL VZERO(SXVRT,3)
        IFVRT = 0
        NAXVRT=NAMIND('XVRT')
        JXVRT=IW(NAXVRT)
        IF (JXVRT.NE.0) THEN
           IFVRT = 1
           XVRT(1)=RW(JXVRT+1)
           XVRT(2)=RW(JXVRT+2)
           XVRT(3)=RW(JXVRT+3)
           IF ( IW(JXVRT).gt.3) then
              IFVRT = 2
              SXVRT(1)=RW(JXVRT+4)
              SXVRT(2)=RW(JXVRT+5)
              SXVRT(3)=RW(JXVRT+6)
           ENDIF
        ENDIF
       TABL(35) = XVRT(1)
       TABL(36) = XVRT(2)
       TABL(37) = XVRT(3)
       TABL(38) = sXVRT(1)
       TABL(39) = sXVRT(2)
       TABL(40) = sXVRT(3)
C     new inputs
      TABL(41) = IBOXU
      TABL(42) = IFKALIN
      TABL(43) = IFLEPTOK
      TABL(44) = INTER
      TABL(45) = XMX
      TABL(46) =  DELTA
      TABL(47) = EPHMIN
      TABL(48) = EPHMAX
      TABL(49) = XTFMIN
      TABL(50) = XTFMAX
      TABL(51) = COSTHM
C
C  Fill the KPAR bank with the generator parameters
C
      NCOL = 51
      NROW = 1
      JKPAR = ALTABL('KPAR',NCOL,NROW,TABL,'2I,(F)','C')
c
C  Fill RLEP bank
       IEBEAM = NINT(ENE *1000  )
       JRLEP = ALRLEP(IEBEAM,'    ',0,0,0)
C
C Initialization event counters
C
      DO 20 I = 1,8
       NEVENT(I) = 0
   20 CONTINUE
C
C Initialization particle data
C
      CALL KXL74A (IPART,IKLIN)
      IF (IPART.LE.0 .OR. IKLIN.LE.0) THEN
       WRITE (IOUT,
     &   '(1X,''ASKUSI :error in PART or KLIN bank - STOP - ''
     &                 ,2I3)') IPART,IKLIN
       STOP
      ENDIF
C
CBBL + aml  modify Lund masses according to input masses
      PMAS(LUCOMP(16),1)= AMNUTA
      PMAS(LUCOMP(23),1)= AMZ
      PMAS(LUCOMP(25),1)= AMH
      PMAS(LUCOMP( 6),1)= AMTOP
      PMAS(LUCOMP( 7),1)= 150.
      PMAS(LUCOMP( 8),1)= 300.
      ia1=20213                                  !jetset7.3 code for a1
      PMAS(LUCOMP(ia1),1)= 1.251
      PMAS(LUCOMP(ia1),2)= 0.599
CBBL    aml
c
C   Make sure that masses and width in PART bank are consistent
C function KGPART returns the ALEPH code corresponding to the LUND code
C required.
C Z0(lund code=23) top (lund code=6)  Higgs (lund code=25)
C a1(lund code=20213)
      NAPAR = NAMIND('PART')
      JPART = IW(NAPAR)
      IZPART = KGPART(23)
      IF (IZPART.GT.0)  THEN
        ZMAS = PMAS(LUCOMP(23),1)
        KPART = KROW(JPART,IZPART)
        RW(KPART+6)=ZMAS
        IANTI = ITABL(JPART,IZPART,10)
        IF (IANTI.NE.IZPART) THEN
          KAPAR = KROW(JPART,IANTI)
          RW(KAPAR+6)=ZMAS
        ENDIF
      ENDIF
      ITPART = KGPART(6)
      IF (ITPART.GT.0)  THEN
        ZMAS = PMAS(LUCOMP( 6),1)
        KPART = KROW(JPART,ITPART)
        RW(KPART+6)=ZMAS
        IANTI = ITABL(JPART,ITPART,10)
        IF (IANTI.NE.ITPART) THEN
          KAPAR = KROW(JPART,IANTI)
          RW(KAPAR+6)=ZMAS
        ENDIF
      ENDIF
      IHPART = KGPART(25)
      IF (IHPART.GT.0)  THEN
        ZMAS = PMAS(LUCOMP(25),1)
        KPART = KROW(JPART,IHPART)
        RW(KPART+6)=ZMAS
        IANTI = ITABL(JPART,IHPART,10)
        IF (IANTI.NE.IHPART) THEN
          KAPAR = KROW(JPART,IANTI)
          RW(KAPAR+6)=ZMAS
        ENDIF
      ENDIF

      IHPART = KGPART(20213)
      IF (IHPART.GT.0)  THEN
        ZMAS = PMAS(LUCOMP(20213),1)
        ZWID = PMAS(LUCOMP(20213),2)
        KPART = KROW(JPART,IHPART)
        RW(KPART+6)=ZMAS
        RW(KPART+9)=ZWID
        IANTI = ITABL(JPART,IHPART,10)
        IF (IANTI.NE.IHPART) THEN
          KAPAR = KROW(JPART,IANTI)
          RW(KAPAR+6)=ZMAS
          RW(KAPAR+9)=ZWID
        ENDIF
      ENDIF
C
C
C   Inhibit decays
C
      MXDEC=KNODEC(NODEC,LPDEC)
      MXDEC=MIN(MXDEC,LPDEC)
      IF (MXDEC.GT.0) THEN
         DO 50 I=1,MXDEC
            IF (NODEC(I).GT.0) THEN
               JIDB = NLINK('MDC1',NODEC(I))
               IF (JIDB .EQ. 0) MDCY(LUCOMP(NODEC(I)),1) = 0
            ENDIF
   50    CONTINUE
      ENDIF
C
C  Generator initialization
C
      LENTRY = 1
      CALL KORL04(LENTRY)
c initialize Tau decay modes in case of qqbar final states
      if ( itfin.gt.500) call initdk
C
C    possibly update branching ratios  with card GKBR
C
      NAGKBR = NAMIND('GKBR')
      JGKBR = IW(NAGKBR)
      IF(JGKBR.NE.0) THEN
C check consitency of length
        NLEN = IW(JGKBR)
C NCHAN is defined only for Tau and quarks channels, not muons
        IF ( ITFIN.eq.1.or.itfin.gt.500) then
         IF ( NLEN .NE.NCHAN+4 ) THEN
            WRITE (IW(6),
     &        '(1X,'' Inconsistent number of Brs should be'',
     $                    I5,'' is '',I5)') NCHAN,NLEN-4
            CALL EXIT
        ENDIF
        BRA1   = RW(JGKBR+1)
        BRK0   = RW(JGKBR+2)
        BRK0B  = RW(JGKBR+3)
        BRKS   = RW(JGKBR+4)
        DO 51 I = 1,NCHAN
           GAMPRT(I) = RW(JGKBR+4+I)
 51     CONTINUE
        IF ( GAMPRT(1).NE.1.) THEN
         DO 52 I = 1, NCHAN
           GAMPRT(I) = GAMPRT(I)/GAMPRT(1)
 52      CONTINUE
        ENDIF
       ENDIF
      ENDIF
C
C   Store the version used in the job and the branching ratios in
C   header bank  KORL
      NCOL = NCHAN+5
      NROW = 1
      aux(1) = IVER
      aux(2) = BRA1
      aux(3) = BRK0
      aux(4) = BRK0B
      aux(5) = BRKS
      DO 57 IBR = 1,NCHAN
          aux(5+IBR) = GAMPRT(IBR)
 57   CONTINUE
      JKORL = ALTABL('KORL',NCOL,NROW,aux,'2I,(F)','C')

C
C  Print PART and KPAR banks
C
c     CALL LULIST(12)
c     CALL PRPART
      CALL PRTABL('RLEP',0)
      CALL PRTABL('KPAR',0)
      CALL PRTABL('KORL',0)
C
      RETURN
      END
      SUBROUTINE ASKUSE (IDP,IST,NTRK,NVRT,ECM,WEI)
C --------------------------------------------------------------------
C Generation                     G. Bonneaud August, October 1988.
C                                G. Bonneaud February 1989.
C                                "     "     June     1989.
C                                J.Boucrot april 97
C                                B.Bloch  fix some type declarations
C                                + offset for vertex position March 99
C --------------------------------------------------------------------
C--------------------------------------------------------------------
C     input     : none
C
C     output    : 6 arguments
C          IDP    : process identification
C          IST    : status flag ( 0 means ok)
C          NTRK   : number of tracks generated and kept
C          NVRT   : number of vertices generated
C          ECM    : center of mass energy for the event
C          WEI    : event weight always equal to 1
C--------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
C VVVVVVVVVVVVVVVVVVVVV JB 970403 VVVVVVVVVVVVVVVVVVVVVVV
C BBL : ECM renamed to ECMJB !!!!
      REAL*8 ECMJB , Q(4,7)
      COMMON / KGCOMM / ISTA,IDPR,ECMS,WEIT,VRTEX(4),TABL(55),NEVENT(8)
      COMMON / PHCUTS / EPHMIN,EPHMAX,XTFMIN,XTFMAX,COSTHM
C ^^^^^^^^^^^^^^^^^^^^^ JB 970403 ^^^^^^^^^^^^^^^^^^^^^^^^^

      PARAMETER (L1MST=200, L1PAR=200)
      PARAMETER (L2PAR=500, L2PARF=2000 )
      PARAMETER (LJNPAR=4000)
      COMMON /LUDAT1/ MSTU(L1MST),PARU(L1PAR),MSTJ(L1MST),PARJ(L1PAR)
      COMMON /LUDAT2/ KCHG(L2PAR,3),PMAS(L2PAR,4),PARF(L2PARF),VCKM(4,4)
      COMMON /LUDAT3/ MDCY(L2PAR,3),MDME(L2PARF,2),BRAT(L2PARF),
     &                KFDP(L2PARF,5)
      COMMON /LUDAT4/ CHAF(L2PAR)
      CHARACTER*8 CHAF
      COMMON /LUJETS/ N7LU,K7LU(LJNPAR,5),P7LU(LJNPAR,5),V7LU(LJNPAR,5)
C
      COMMON / TAUHEL / HELT1,HELT2
      REAL*4 HELT1,HELT2
      COMMON / VERTX / IFVRT,XVRT(3),SXVRT(3)
      DIMENSION E1(3),E2(3)
      PARAMETER (LWP = 4)
      common /kalinout/ wtkal(6)
      real*8 wtkal
      real weigh(6)
C
      IST  = 0
      IDP  = 0
      ECM  = 0.
      WEI  = 0.
C
C  Generate primary vertex
C
      CALL RANNOR (RN1,RN2)
      CALL RANNOR (RN3,DUM)
      VRTEX(1) = RN1*TABL(31)
      VRTEX(2) = RN2*TABL(32)
      VRTEX(3) = RN3*TABL(33)
      VRTEX(4) = 0.
      IF ( IFVRT.ge.2) then
         CALL RANNOR(RXX,RYY)
         CALL RANNOR(RZZ,DUM)
         VRTEX(1) = VRTEX(1) + RXX*SXVRT(1)
         VRTEX(2) = VRTEX(2) + RYY*SXVRT(2)
         VRTEX(3) = VRTEX(3) + RZZ*SXVRT(3)
      ENDIF
      IF ( IFVRT.ge.1) then
         VRTEX(1) = VRTEX(1) + XVRT(1)
         VRTEX(2) = VRTEX(2) + XVRT(2)
         VRTEX(3) = VRTEX(3) + XVRT(3)
      ENDIF
C
C  Event generation
C
      LENTRY = 2
      NEVENT(1) = NEVENT(1) + 1
      CALL KORL04(LENTRY)
      IDP  = IDPR
      ECM  = ECMS
      WEI  = WEIT
      IST  = ISTA
      IF(IST.NE.0) THEN
       NEVENT(4) = NEVENT(4) + 1
       GO TO 20
      ENDIF
C  decay remaining pi0's
      CALL LUEXEC
C  Book all banks
C
      CALL KXL7AL(VRTEX,ISTX,NVRT,NTRK)
      IST = ISTX
      IF(IST.NE.0) THEN
       NEVENT(5) = NEVENT(5) + 1
       GO TO 20
      ENDIF
C
C  Now book the polarization bank 'KPOL' if necessary
C
      E1(3) = TABL(20)
      E2(3) = TABL(23)
      ISPIN = TABL(26)
      ITFIN = TABL(11)
      if ( itfin.gt.1.) go to 100
      IF(E1(3).NE.0..OR.E2(3).NE.0..OR.ISPIN.EQ.1) THEN
       NPART = 4
       LE = LMHLEN + NPART*LWP
       CALL AUBOS('KPOL',0,LE,JKPOL,IGARB)
       CALL BLIST(IW,'E+','KPOL')
       CALL BKFMT('KPOL','2I,(I,3F)')
       IF(JKPOL.GT.0) THEN
        IW(JKPOL+LMHCOL) = LWP
        IW(JKPOL+LMHROW) = NPART
        IW(JKPOL+LMHLEN+1) = -1
        RW(JKPOL+LMHLEN+2) = TABL(18)
        RW(JKPOL+LMHLEN+3) = TABL(19)
        RW(JKPOL+LMHLEN+4) = TABL(20)
        IW(JKPOL+LMHLEN+LWP+1) = -2
        RW(JKPOL+LMHLEN+LWP+2) = TABL(21)
        RW(JKPOL+LMHLEN+LWP+3) = TABL(22)
        RW(JKPOL+LMHLEN+LWP+4) = -TABL(23)
        IW(JKPOL+LMHLEN+2*LWP+1) = 1
        RW(JKPOL+LMHLEN+2*LWP+2) = 0.
        RW(JKPOL+LMHLEN+2*LWP+3) = 0.
        RW(JKPOL+LMHLEN+2*LWP+4) = HELT1
        IW(JKPOL+LMHLEN+3*LWP+1) = 2
        RW(JKPOL+LMHLEN+3*LWP+2) = 0.
        RW(JKPOL+LMHLEN+3*LWP+3) = 0.
        RW(JKPOL+LMHLEN+3*LWP+4) = HELT2
       ELSE
        IST = 1
        NEVENT(6) = NEVENT(6) + 1
       ENDIF
 100  continue
      ENDIF
C ----------------------------------------------------------------------
C Keep only events with at least 1 gamma with cuts below :
      IGOK=0
      IGAMMA=22
C VVVVVVVVVVVVVVVVVVVVV JB 970403 VVVVVVVVVVVVVVVVVVVVVVV
C NOW take values initialized from data cards !
       EGMIN=EPHMIN
       EGMAX=EPHMAX
       COSMAX=COSTHM
       CMENE=2.*TABL(16)
       XTMIN=XTFMIN
       XTMAX=XTFMAX
C       write (iw(6),1234) egmin,cosmax,cmene,xtmin
 1234  format(' -- askuse egmin,cosmax,cmene,xtmin =',4e12.4)
C Loop on all LUND particles ; check photons :
      DO 271 IN=1,N7LU
         PX=P7LU(IN,1)
         PY=P7LU(IN,2)
         PZ=P7LU(IN,3)
         EN=P7LU(IN,4)
         IPA=IABS(K7LU(IN,2))
C Find photons :
         IF (IPA.EQ.IGAMMA) THEN
            ECMJB=DBLE(CMENE)
            DO IQQ=1,4
               DO IJJ=1,7
                  Q(IQQ,IJJ)=0.D0
               ENDDO
           ENDDO
           Q(1,5) = DBLE(PX)
           Q(2,5) = DBLE(PY)
           Q(3,5) = DBLE(PZ)
           Q(4,5) = DBLE(EN)
           CALL CHECK_CUTS_A(ECMJB,Q,NCUT)
           IF (NCUT.EQ.0) then
              IGOK=IGOK+1
              call pracus(0)
           endif
         ENDIF
 271   CONTINUE
C Write only events with at least a gamma inside cuts :
      IST=1
      IF (IGOK.GE.1) then
        IST=0
c        costhg = Q(3,5)/Q(4,5)
c        print *,'fkalin ',wtkal(1),wtkal(2),Q(4,5),costhg
      endif
C
C Create the bank 'KWTK' for the event weights if they exist;
C put this bank on the output event bank list:
      IF (IST.EQ.0) CALL CREKWTK
C ^^^^^^^^^^^^^^^^^^^^^ JB 970403 ^^^^^^^^^^^^^^^^^^^^^^^^^
C ----------------------------------------------------------------------
C  Event counters
C
      IF(IST.EQ.0) THEN
       NEVENT(2) = NEVENT(2) + 1
       DO 10 IP = 1,N7LU
        IF(K7LU(Ip,2).EQ.22) then
         NEVENT(8) = NEVENT(8) + 1
         GO TO 30
        ENDIF
   10  CONTINUE
       NEVENT(7) = NEVENT(7) + 1
      ENDIF
   20 IF(IST.NE.0) NEVENT(3) = NEVENT(3) + 1
C
   30 RETURN
      END
      SUBROUTINE USCJOB
C --------------------------------------------------------------------
C End of generation              G. Bonneaud August, October 1988.
C --------------------------------------------------------------------
      COMMON / INOUT / INUT,IOUT
      COMMON / KGCOMM / ISTA,IDPR,ECMS,WEIT,VRTEX(4),TABL(55),NEVENT(8)
C
C End of generation
C
      LENTRY = 3
      CALL KORL04(LENTRY)
C
C Print event counters
C
       WRITE(IOUT,101)
  101  FORMAT(//20X,'EVENTS STATISTICS',
     &         /20X,'*****************')
       WRITE(IOUT,102) NEVENT(1),NEVENT(2),NEVENT(3),
     &                 NEVENT(7),NEVENT(8)
  102  FORMAT(/5X,'# OF GENERATED EVENTS                      = ',I10,
     &        /5X,'# OF ACCEPTED  EVENTS                      = ',I10,
     &        /5X,'# OF REJECTED  EVENTS (ISTA # 0 in ASKUSE) = ',I10,
     &        /5X,'# OF EVENTS WITHOUT PHOTON                 = ',I10,
     &        /5X,'# OF EVENTS WITH PHOTON                    = ',I10)
       WRITE(IOUT,103)
  103  FORMAT(//20X,'ERRORS STATISTICS',
     &         /20X,'*****************')
       WRITE(IOUT,104) NEVENT(4),NEVENT(5),NEVENT(6)
  104  FORMAT(/10X,'ISTA # 0 FROM KORL04        # OF REJECT = ',I10,
     &        /10X,'ISTA # 0 FROM KXLUAL        # OF REJECT = ',I10,
     &        /10X,'ISTA # 0 FROM JKPOL         # OF REJECT = ',I10)
C
      RETURN
      END
      SUBROUTINE KORL04(LENTRY)
C --------------------------------------------------------------------
C similar to Korl07
C add creation of KSEC bank at the end of job B.Bloch March 99
C --------------------------------------------------------------------
C
C     MONTE CARLO EVENT GENERATOR FOR THE PROCESSES
C
C         E+(PB1) E-(PB2)   ---->  TAU+(QP) TAU-(QM)
C
C     AND
C
C         E+(PB1) E-(PB2)   ---->  TAU+(QP) TAU-(QM) PHOTON(PH)
C
C
C  THE INPUT QUANTITIES ARE
C ENE    ENERGY OF A BEAM (GEV)
C AMZ    Z0    MASS (GEV)
C AMTOP  TOP   MASS (GEV)
C AMH    HIGGS MASS (GEV)
C AMNUTA NEUTRINO TAU MASS (GEV)
C E1     =  SPIN POLARIZATION VECTOR FOR THE FIRST BEAM.
C E2     =  SPIN POLARIZATION VECTOR FOR THE SECOND BEAM,
C           BOTH IN THE CORRESPONDING BEAM PARTICLE REST FRAME
C           AND IN BOTH CASES THIRD AXIS DIRECTED ALONG FIRST BEAM,
C           I.E. EE1(3) AND -EE2(3) ARE HELICITIES.
C ISPIN  =  0,1  SPIN EFFECTS IN DECAY SWITCHED OFF,ON.
C INRAN  =  INITIALISATION CONSTANT FOR RAND. NUM. GEN. RNF100, POSITIVE
C KEYGSW,   IMPLEMENTATION LEVEL OF GLASHOW-SALAM-WEINBERG MODEL:
C        =  0,  N0 Z0, ONLY PHOTON EXCHANGE, NO Z0, NO VAC. POL.,
C        =  1,  PHOTON AND Z0, NO VACUUM POLARISATIONS,
C        =  2,  PHOTON AND Z0, GSW VACUUM POLARISATIONS INCLUDED,
C        =  3,  ALL GSW CORRECTIONS INCLUDED
C KEYRAD =  0,  NO QED BREMSSTRAHLUNG,
C        =  1,  WITH QED BREMSSTRAHLUNG.
C JAK1,JAK2, DECAY TYPE FOR TAU+ AND TAU-.
C            DECAY MODES INCLUDED ARE:
C            JAK  =  1  ELECTRON DECAY
C                 =  2  MU  DECAY,
C                 =  3  PI DECAY ,
C                 =  4  RHO DECAY,
C                 =  5  A1  DECAY,
C                 =  0  INCLUSIVE:  JAK=1,2,3,4,5
C                 = -1  NO DECAY.
C ITFIN  =  1  TAU PAIR PRODUCTION,
C        =  2  MUON PAIR PRODUCTION.
C KFB =11,-11 FLAVOUR CODE OF FIRST BEAM, KFB=11 FOR ELECTRON.
C ITDKRC=0 DECAY OF TAU USING TAUOLA,
C       >0 RESERVED FOR FUTURE DEVELOPEMENT.
C GV AND GA ARE COUPLING CONSTANTS OF W-BOSON TO TAU LEPTON,
C       GV=1,GA=-1 REPRESENT THE STANDARD V-A COUPLING.
C
C --------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
      COMMON / INOUT / INUT,IOUT
      COMMON / JAKI   /  JAK1,JAK2,JAKP,JAKM,KTOM
      COMMON / KGCOMM / ISTA,IDPR,ECMS,WEIT,VRTEX(4),TABL(55),NEVENT(8)
      COMMON / TAUHEL / HELT1,HELT2
      REAL*4 HELT1,HELT2
C
      DIMENSION PB1(4),PB2(4),XPAR(40)
      DIMENSION E1(3),E2(3)
      INTEGER NPAR(40)
      INTEGER ALTABL
      EXTERNAL ALTABL
C
C
C  INITIALIZATION            *********************
C
      IF(LENTRY.EQ.1) THEN
       NADEB = NAMIND('DEBU')
       JDEBU = IW(NADEB)
       IF(JDEBU.NE.0) THEN
        IDB1 = IW(JDEBU+1)
        IDB2 = IW(JDEBU+2)
       ENDIF
C
C Initialization of XPAR and NPAR tables : generator's parameters
C
       NPAR(1)  = TABL(26)
       NPAR(2)  = 0.
       NPAR(3)  = TABL(8)
       NPAR(4)  = TABL(9)
       NPAR(5)  = TABL(24)
       NPAR(6)  = TABL(25)
       NPAR(7)  = TABL(11)
       NPAR(8)  = TABL(27)
       NPAR(9)  = TABL(10)
       NPAR(11) = TABL(12)
       NPAR(12) = TABL(34)
       XPAR(1)  = TABL(1)
       XPAR(2)  = TABL(3)
       XPAR(3)  = TABL(2)
       XPAR(4)  = TABL(29)
       XPAR(5)  = TABL(30)
       XPAR(6)  = TABL(6)
       XPAR(7)  = TABL(7)
       XPAR(8)  = TABL(4)
       XPAR(9)  = TABL(5)
       XPAR(11) = TABL(13)
       XPAR(12) = TABL(14)
       XPAR(13) = TABL(15)
       XPAR(14) = TABL(28)
       DO 1 I = 1,3
        E1(I) = TABL(17+I)
    1   E2(I) = TABL(20+I)
       PB1(1)  = 0.
       PB1(2)  = 0.
       PB1(3)  = TABL(16)
       PB1(4)  = TABL(16)
       DO 2 I=1,3
    2  PB2(I) = -PB1(I)
       PB2(4) =  PB1(4)
       KFB    =  TABL(17)
C
C KORALZ initialization step
C
       NMODE  = -1
       CALL KORALZ(NMODE,KFB,PB1,E1,-KFB,PB2,E2,XPAR,NPAR)
C
C Booking histos
C
       ITFIN = NPAR(7)
       CALL BUKERD(NMODE,ITFIN)
C
C
       if( itfin.gt.500) then
         call lutabu(10)
         call lutabu(20)
       endif
       RETURN
      ENDIF
C
C  EVENT GENERATION          *********************
C
      IF(LENTRY.EQ.2) THEN
C
C Event generation
C
       NMODE = 0
       CALL KORALZ(NMODE,KFB,PB1,E1,-KFB,PB2,E2,XPAR,NPAR)
C
c Converts /HEPEVT/ common to LUND7.3 commons
       call LUHEPC(2)
c prepare hadronisation in quarks mode ( they are always in position 3,4
       IF(ITFIN.gt.500) then
          call qqtops(3,4)
c
          call lutabu(11)
          call lutabu(21)
       endif
       ECMS = 2.*TABL(16)
       WEIT = 1.
       ISTA = 0
C
C Update process code
C
       IF(ITFIN.EQ.1) THEN
        ID1 = JAKP
        ID2 = JAKM
        IDPR = 100*ID1+ID2
        XPR = FLOAT(IDPR)
        if(helt1.gt.0)
     &  CALL HFILL(10000,FLOAT(ID1)+.1,FLOAT(ID2)+.1,1.)
        if(helt1.lt.0)
     &  CALL HFILL(20000,FLOAT(ID1)+.1,FLOAT(ID2)+.1,1.)
       ELSE
        IDPR= ITFIN
       ENDIF
C
C Print first events depending of DEBUG option
C
       IF(NEVENT(1).GE.IDB1.AND.NEVENT(1).LE.IDB2) THEN
        CALL DUMPL8
        CALL LULIST(1)
       ENDIF
C
C Fill histos
C
       CALL BUKERD(NMODE,ITFIN)
C
       RETURN
      ENDIF
C
C  END OF GENERATION         *********************
C
      IF(LENTRY.EQ.3) THEN
C
C Generator end
C
       NMODE = 1
       NPAR1 = 0
       NPAR2 = 0
       CALL KORALZ(NMODE,NPAR1,PB1,E1,NPAR2,PB2,E2,XPAR,NPAR)
C Create cross section bank
        call ugtsec
C
       if( itfin.gt.500) then
         call lutabu(12)
         call lutabu(22)
       endif
C
C Print histos
C
       CALL BUKERD(NMODE,ITFIN)
      ENDIF
C
      RETURN
      END
      SUBROUTINE BUKERD(IMOD,ITFIN)
C --------------------------------------------------------------------
C Book histos
C
C
C                                AM.Lutz     February 1989.
C --------------------------------------------------------------------
      COMMON / JAKI   /  JAK1,JAK2,JAKP,JAKM,KTOM
      PARAMETER (L1MST=200, L1PAR=200)
      PARAMETER (L2PAR=500, L2PARF=2000 )
      PARAMETER (LJNPAR=4000)
      COMMON /LUDAT1/ MSTU(L1MST),PARU(L1PAR),MSTJ(L1MST),PARJ(L1PAR)
      COMMON /LUDAT2/ KCHG(L2PAR,3),PMAS(L2PAR,4),PARF(L2PARF),VCKM(4,4)
      COMMON /LUDAT3/ MDCY(L2PAR,3),MDME(L2PARF,2),BRAT(L2PARF),
     &                KFDP(L2PARF,5)
      COMMON /LUDAT4/ CHAF(L2PAR)
      CHARACTER*8 CHAF
      COMMON /LUJETS/ N7LU,K7LU(LJNPAR,5),P7LU(LJNPAR,5),V7LU(LJNPAR,5)
C
      COMMON / UTIL4 / AQP(4),AQM(4),APH(4)
      REAL*4           AQP   ,AQM   ,APH
      COMMON / IDFC  / IDFF
      COMMON / KGCOMM / ISTA,IDPR,ECMS,WEIT,VRTEX(4),TABL(55),NEVENT(8)
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / TAUHEL / HELT1,HELT2
      REAL*4 HELT1,HELT2
C     COMMON /PAWC/ HB(100000)
      DIMENSION PVIS(2)
c
      dimension qp(5,10,2),nch(2),nneu(2),ipfori(2),xlam(4)
      real*8 lambda
      lambda(x,y,z) = x**2+y**2+z**2-2*x*y-2*x*z-2*y*z

C
C     ====================
C
      IF(IMOD.EQ.-1) THEN
C
      EBIM = TABL(16)
      IF(ITFIN.EQ.2) THEN
       CALL HTITLE('MU+ MU- GAMMA(s) FINAL STATE')
       CALL HBOOK1(10001,'MU+ energy distribution $',50,0.,EBIM,0.)
       CALL HIDOPT(10001,'LOGY')
       CALL HBOOK1(10002,'MU+ polar angle distribution$',41,-1.,1.05,0.)
       CALL HIDOPT(10002,'LOGY')
       CALL HBOOK1(10003,'MU+ azimuthal angle distribution $',
     &                                                   40,0.,360.,0.)
       CALL HBOOK1(10004,'MU- energy distribution $',50,0.,EBIM,0.)
       CALL HIDOPT(10004,'LOGY')
       CALL HBOOK1(10005,'MU- polar angle distribution$',41,-1.,1.05,0.)
       CALL HIDOPT(10005,'LOGY')
       CALL HBOOK1(10006,'MU- azimuthal angle distribution $',
     &                                                   40,0.,360.,0.)
       CALL HBOOK1(10007,'MU+/MU- accolinearity distribution (degr.)$',
     &                                                   40,0.,180.,0.)
       CALL HIDOPT(10007,'LOGY')
       CALL HBOOK1(10008,'MU+/MU- accoplanarity distribution (degr.)$',
     &                                                   40,0.,180.,0.)
       CALL HIDOPT(10008,'LOGY')
       CALL HBOOK1(10009,'Photon multiplicity $',40,0.,40.,0.)
       CALL HBOOK1(10010,'Photon energy distribution $',50,0.,EBIM,0.)
       CALL HIDOPT(10010,'LOGY')
       CALL HBOOK1(10011,'Photon angular spectrum $', 50,-1.,1.,0.)
       CALL HIDOPT(10011,'LOGY')
C
      ELSE IF(ITFIN.EQ.4) THEN
       CALL HTITLE('e+ e- GAMMA(s) FINAL STATE s channel only')
       CALL HBOOK1(10001,'e+ energy distribution ',50,0.,EBIM,0.)
       CALL HIDOPT(10001,'LOGY')
       CALL HBOOK1(10002,'e+ polar angle distribution',41,-1.,1.05,0.)
       CALL HIDOPT(10002,'LOGY')
       CALL HBOOK1(10003,'e+ azimuthal angle distribution ',
     &                                                   40,0.,360.,0.)
       CALL HBOOK1(10004,'e- energy distribution ',50,0.,EBIM,0.)
       CALL HIDOPT(10004,'LOGY')
       CALL HBOOK1(10005,'e- polar angle distribution',41,-1.,1.05,0.)
       CALL HIDOPT(10005,'LOGY')
       CALL HBOOK1(10006,'e- azimuthal angle distribution ',
     &                                                   40,0.,360.,0.)
       CALL HBOOK1(10007,'e+/e- accolinearity distribution (degr.)',
     &                                                   40,0.,180.,0.)
       CALL HIDOPT(10007,'LOGY')
       CALL HBOOK1(10008,'e+/e- accoplanarity distribution (degr.)',
     &                                                   40,0.,180.,0.)
       CALL HIDOPT(10008,'LOGY')
       CALL HBOOK1(10009,'Photon multiplicity ',40,0.,40.,0.)
       CALL HBOOK1(10010,'Photon energy distribution ',50,0.,EBIM,0.)
       CALL HIDOPT(10010,'LOGY')
       CALL HBOOK1(10011,'Photon angular spectrum ', 50,-1.,1.,0.)
       CALL HIDOPT(10011,'LOGY')
C
      ELSE IF(ITFIN.EQ.1) THEN
       CALL HTITLE('TAU+ TAU- GAMMA(s) FINAL STATE')
       CALL HTABLE(10000,'TAU DECAY MODES P=+1$',
     & 30,0.,30.,30,.0,30.,0.)
       CALL HTABLE(20000,'TAU DECAY MODES P=-1$',
     & 30,0.,30.,30,.0,30.,0.)
       CALL HBOOK1(10001,'E/Ebeam     Photon $', 50,0.,1.,0.)
       CALL HIDOPT(10001,'LOGY')
       CALL HBOOK1(10002,'angular spectrum Photon $', 50,-1.,1.,0.)
       CALL HIDOPT(10002,'LOGY')
       CALL HBOOK1(10101,'E/Ebeam   Electron $', 50,0.,1.,0.)
       CALL HBOOK1(10201,'E/Ebeam       Muon $', 50,0.,1.,0.)
       CALL HBOOK1(10301,'E/Ebeam         pi $', 50,0.,1.,0.)
       CALL HBOOK1(10404,'mpipi0         rho $',50,.0,2.5,0.)
       CALL HBOOK1(10405,'mpipi0**2          $',71,.0,3.55,0.)
       CALL HBOOK1(10504,'m3pi      a1->3pic $',50,.68,1.68,0.)
       CALL HBOOK1(10505,'m3pi**2         a1 $',71,.0,3.55,0.)
       CALL HBOOK1(10506,'m2pi (opp sign)    $',50,.0,1.5,0.)
       CALL HBOOK1(10507,'m2pi (like sign)   $',50,.0,1.5,.0)
       CALL HBOOK1(10508,'3pic spectr.funct. $',50,.7,1.70,0.)
       CALL HBOOK1(10554,'m3pi     a1->pi2pi0$',50,.68,1.68,0.)
       CALL HBOOK1(10555,'mpi2pi0**2         $',71,.0,3.55,0.)
       CALL HBOOK1(10556,'m2pi0              $',50,.0,1.5,0.)
       CALL HBOOK1(10557,'mpipi0             $',50,.0,1.5,0.)
       CALL HBOOK1(10558,'pi2pi0 spectr.funct.$',50,.7,1.70,0.)
       CALL HBOOK1(10601,'E/Ebeam          K $', 50,0.,1.,0.)
       CALL HBOOK1(10704,'mKpi             K*$',50,.0,2.5,0.)
       CALL HBOOK1(10705,'mKpi**2            $',71,.0,3.55,0.)
       CALL HBOOK1(10804,'m4pi         3pipi0$',50,.7,2.1,0.)
       CALL HBOOK1(10805,'m4pi**2      3pipi0$',71,.0,3.55,0.)
       CALL HBOOK1(10806,'m3pi         3pipi0$',50,.0,2.5,0.)
       CALL HBOOK1(10807,'m2pi         3pipi0$',50,.0,2.5,0.)
       CALL HBOOK1(10808,'4pic spectr.funct. $',50,.7,1.70,0.)
       CALL HBOOK1(10904,'m4pi         pi3pi0$',50,.7,2.1,0.)
       CALL HBOOK1(10905,'m4pi**2      pi3pi0$',71,.0,3.55,0.)
       CALL HBOOK1(10906,'m3pi         pi3pi0$',50,.0,2.5,0.)
       CALL HBOOK1(10907,'m2pi         pi3pi0$',50,.0,2.5,0.)
       CALL HBOOK1(10908,'4pic spectr.funct. $',50,.7,1.70,0.)
       CALL HBOOK1(11004,'m5pi        3pi2pi0$',50,.0,2.5,0.)
       CALL HBOOK1(11005,'m5pi+-**2   3pi2pi0$',71,.0,3.55,0.)
       CALL HBOOK1(11006,'m3pi        3pi2pi0$',50,.0,2.5,0.)
       CALL HBOOK1(11007,'m4pi        3pi2pi0$',50,.0,2.5,0.)
       CALL HBOOK1(11008,'5pi spectr.funct.  $',50,.7,1.70,0.)
       CALL HBOOK1(11104,'m5pi          5pi+-$',50,.0,2.5,0.)
       CALL HBOOK1(11105,'m5pi**2       5pi+-$',71,.0,3.55,0.)
       CALL HBOOK1(11106,'m3pi          5pi+-$',50,.0,2.5,0.)
       CALL HBOOK1(11107,'m4pi          5pi+-$',50,.0,2.5,0.)
       CALL HBOOK1(11108,'5pi spectr.funct.  $',50,.7,1.70,0.)
       CALL HBOOK1(11204,'m6pi        5pi pi0$',50,.0,2.5,0.)
       CALL HBOOK1(11205,'m6pi**2     5pi pi0$',71,.0,3.55,0.)
       CALL HBOOK1(11206,'m3pi        5pi pi0$',50,.0,2.5,0.)
       CALL HBOOK1(11207,'m4pi        5pi pi0$',50,.0,2.5,0.)
       CALL HBOOK1(11304,'m6pi        3pi3pi0$',50,.0,2.5,0.)
       CALL HBOOK1(11305,'m6pi**2     3pi3pi0$',71,.0,3.55,0.)
       CALL HBOOK1(11306,'m3pi        3pi3pi0$',50,.0,2.5,0.)
       CALL HBOOK1(11307,'m4pi        3pi3pi0$',50,.0,2.5,0.)
       CALL HBOOK1(11404,'mKpiK       K-pi-K+$',50,.0,2.5,0.)
       CALL HBOOK1(11405,'mKpiK**2           $',71,.0,3.55,0.)
       CALL HBOOK1(11406,'mKk         K-pi-K+$',50,.0,2.0,.0)
       CALL HBOOK1(11407,'mKpi        K-pi-K $',50,.0,2.0,.0)
       CALL HBOOK1(11504,'mKpiK      K0pi-K0b$',50,.0,2.5,0.)
       CALL HBOOK1(11505,'mKpiK**2           $',71,.0,3.55,0.)
       CALL HBOOK1(11506,'mKK        K0pi-K0b$',50,.0,2.0,.0)
       CALL HBOOK1(11507,'mKpi       K0pi-K0b$',50,.0,2.0,.0)
       CALL HBOOK1(11604,'mKpiK       K-pi0K0$',50,.0,2.5,0.)
       CALL HBOOK1(11605,'mKpiK**2           $',71,.0,3.55,0.)
       CALL HBOOK1(11606,'mKK         K-pi0K0$',50,.0,2.0,.0)
       CALL HBOOK1(11607,'mKpi        K-pi0K0$',50,.0,2.0,.0)
       CALL HBOOK1(11704,'mKpipi     pi0pi0K-$',50,.0,2.5,0.)
       CALL HBOOK1(11705,'mKpipi*2           $',71,.0,3.55,0.)
       CALL HBOOK1(11706,'mKpi       pi0pi0K-$',50,.0,2.0,.0)
       CALL HBOOK1(11707,'mKpi       pi0pi0K-$',50,.0,2.0,.0)
       CALL HBOOK1(11804,'mKpipi     K-pi-pi+$',50,.0,2.5,0.)
       CALL HBOOK1(11805,'mKpipi**2          $',71,.0,3.55,0.)
       CALL HBOOK1(11806,'mKpi       K-pi-pi+$',50,.0,2.0,.0)
       CALL HBOOK1(11807,'mpipi      K-pi-pi+$',50,.0,2.0,.0)
       CALL HBOOK1(11904,'mKpipi    pi-K0bpi+$',50,.0,2.5,0.)
       CALL HBOOK1(11905,'mKpipi**2          $',71,.0,3.55,0.)
       CALL HBOOK1(11906,'mpipi     pi-K0bpi+$',50,.0,2.0,.0)
       CALL HBOOK1(11907,'mKpi      pi-K0bpi+$',50,.0,2.0,.0)
       CALL HBOOK1(12204,'K-K0 mass          $',50,.0,2.5,0.)
       CALL HBOOK1(12205,'K-K0 mass**2       $',71,.0,3.55,0.)
       CALL HBOOK1(12208,'K-K0 spectr.funct. $',50,.7,1.70,0.)
       CALL HIDOPT(0,'STAT')
       CALL HBPRO(0,.0)
       nevpr = 0
       ampi2  =  ampi**2
       amtau2 = amtau**2
      ELSE IF(ITFIN.EQ.3) THEN
       CALL HTITLE('NU NUBAR GAMMA(s) FINAL STATE')
       CALL HBOOK1(10009,'Photon multiplicity ',40,0.,40.,0.)
       CALL HBOOK1(10010,'Photon energy distribution ',50,0.,EBIM,0.)
       CALL HIDOPT(10010,'LOGY')
       CALL HBOOK1(10011,'PHOTON ANGULAR SPECTRUM ', 50,-1.,1.,0.)
       CALL HIDOPT(10011,'LOGY')
      ELSE IF(ITFIN.GT.3) THEN
       CALL HTITLE('Q QBAR  GAMMA(s) FINAL STATE')
       CALL HBOOK1(10001,'QBAR energy distribution ',50,0.,EBIM,0.)
       CALL HIDOPT(10001,'LOGY')
       CALL HBOOK1(10002,'QBAR polar angle distribution',41,-1.,1.05,0.)
       CALL HIDOPT(10002,'LOGY')
       CALL HBOOK1(10003,'QBAR azimuthal angle distribution ',
     &                                                   40,0.,360.,0.)
       CALL HBOOK1(10004,'Q   energy distribution ',50,0.,EBIM,0.)
       CALL HIDOPT(10004,'LOGY')
       CALL HBOOK1(10005,'Q   polar angle distribution',41,-1.,1.05,0.)
       CALL HIDOPT(10005,'LOGY')
       CALL HBOOK1(10006,'Q   azimuthal angle distribution ',
     &                                                   40,0.,360.,0.)
       CALL HBOOK1(10007,'QBAR/Q  accolinearity distribution (degr.)',
     &                                                   40,0.,180.,0.)
       CALL HIDOPT(10007,'LOGY')
       CALL HBOOK1(10008,'QBAR/Q  accoplanarity distribution (degr.)',
     &                                                   40,0.,180.,0.)
       CALL HIDOPT(10008,'LOGY')
       CALL HBOOK1(10009,'Photon multiplicity',40,0.,40.,0.)
       CALL HBOOK1(10010,'Photon energy distribution',50,0.,2.*EBIM,0.)
       CALL HIDOPT(10010,'LOGY')
       CALL HBOOK1(10011,'Photon angular spectrum $', 50,-1.,1.,0.)
       CALL HIDOPT(10011,'LOGY')
      ENDIF
C
C     =======================
C
      ELSE IF(IMOD.EQ.0) THEN
C
      IF(ITFIN.GE.2) THEN
       IF (ITFIN.NE.3) THEN
       CALL HFILL(10001,p7lu(3,4),0.,1.)
       THEMUP = p7lu(3,3)/p7lu(3,4)
       IF(THEMUP.GE. 1.) THEMUP =  0.999999
       IF(THEMUP.LE.-1.) THEMUP = -0.999999
       CALL HFILL(10002,THEMUP,0.,1.)
       PHIMUP = p7lu(3,2)/SQRT(p7lu(3,1)**2+p7lu(3,2)**2)
       PHIMUP = 180.*ACOS(PHIMUP)/3.14159
       IF(p7lu(3,1).LT.0.) PHIMUP = 360. - PHIMUP
       CALL HFILL(10003,PHIMUP,0.,1.)
       CALL HFILL(10004,p7lu(4,4),0.,1.)
       THEMUM = p7lu(4,3)/p7lu(4,4)
       IF(THEMUM.GE. 1.) THEMUM =  0.999999
       IF(THEMUM.LE.-1.) THEMUM = -0.999999
       CALL HFILL(10005,THEMUM,0.,1.)
       PHIMUM = p7lu(4,2)/SQRT(p7lu(4,1)**2+p7lu(4,2)**2)
       PHIMUM = ACOS(PHIMUM)
       PHIMUM = 180.*PHIMUM/3.14159
       IF(p7lu(4,1).LT.0.) PHIMUM = 360. - PHIMUM
       CALL HFILL(10006,PHIMUM,0.,1.)
       ACCOLI = p7lu(3,1)*p7lu(4,1)+p7lu(3,2)*p7lu(4,2)+
     &          p7lu(3,3)*p7lu(4,3)
       ACCOLI = ACCOLI/
     &           (SQRT(p7lu(3,1)**2+p7lu(3,2)**2+p7lu(3,3)**2)*
     &            SQRT(p7lu(4,1)**2+p7lu(4,2)**2+p7lu(4,3)**2))
       IF(ACCOLI.GE. 1.) ACCOLI =  0.999999
       IF(ACCOLI.LE.-1.) ACCOLI = -0.999999
       ACCOLI = 180.*(1.-ACOS(ACCOLI)/3.14159)
       CALL HFILL(10007,ACCOLI,0.,1.)
       ACCOPL = p7lu(3,1)*p7lu(4,1)+p7lu(3,2)*p7lu(4,2)
       ACCOPL = ACCOPL/(SQRT(p7lu(3,1)**2+p7lu(3,2)**2)*
     &                  SQRT(p7lu(4,1)**2+p7lu(4,2)**2))
       IF(ACCOPL.GE. 1.) ACCOPL =  0.999999
       IF(ACCOPL.LE.-1.) ACCOPL = -0.999999
       ACCOPL = 180.*(1.-ACOS(ACCOPL)/3.14159)
       CALL HFILL(10008,ACCOPL,0.,1.)
       ENDIF
       XPHOTON = 0.
C       IF(XPHOTON.NE.0.) THEN
        DO 10 I = 5,n7lu
         if ( k7lu(i,2).ne.22) go to 10
         IF ( k7lu(i,3).ne.1)  go to 10
         xphoton = xphoton +1.
         THEPHO = p7lu(I,3)/p7lu(I,4)
         IF(THEPHO.GE. 1.) THEPHO =  0.999999
         IF(THEPHO.LE.-1.) THEPHO = -0.999999
         CALL HFILL(10011,THEPHO,0.,1.)
   10    CALL HFILL(10010,p7lu(I,4),0.,1.)
        CALL HFILL(10009,XPHOTON,0.,1.)
C       ENDIF
C
      ELSE IF(ITFIN.EQ.1) THEN
       call vzero(nch,2)
       call vzero(nneu,2)
       call vzero(ipfori,2)
       call vzero(qp,5*10*2)
       ENE = p7lu(1,4)
C PHOTON ENERGY AND ANGULAR SPECTRUM
       IF(APH(4).GT.0.0001) THEN
        CALL HFILL(10001,APH(4)/ENE,0.,1.)
        THEPHO = APH(3)/APH(4)
        IF(THEPHO.GE. 1.) THEPHO =  0.999999
        IF(THEPHO.LE.-1.) THEPHO = -0.999999
        CALL HFILL(10002,THEPHO,0.,1.)
       ENDIF
       DO 50 IP = 5,n7lu
CAM  SKIP RADIATIVE GAMMA OR UNSTABLE PARTICLE
       IF(k7lu(IP,2).EQ.22.OR.k7lu(IP,1).ne.1) GO TO 50
C
       IPORIG=k7lu(IP,3)
       KKFORI=k7lu(IPORIG,2)
       KFORIG=ABS(KKFORI)
 20    CONTINUE
cam jetset7.3 tau id = 15
       IF(KKFORI.NE.15.AND.KKFORI.NE.-15) THEN
        IPORIG=k7lu(IPORIG,3)
        KKFORI=k7lu(IPORIG,2)
       ENDIF
       IF(ABS(KKFORI).NE.15) GO TO 20
       IF    (KKFORI.EQ.+IDFF) THEN
         JAK=JAKP
       ELSEIF(KKFORI.EQ.-IDFF) THEN
         JAK=JAKM
       ELSE
         print *,' illegal kforig in bukerd',
     &   IP,KKFORI,k7lu(IP,3),k7lu(IP,2),k7lu(k7lu(IP,3),3),
     &   k7lu(k7lu(IP,3),2),IPORIG
         STOP
       ENDIF
       it = iporig - 2
       if (it.gt.2) then
         print *,' illegal iporig in bukerd',
     &   ip,kkfori,k7lu(ip,3),k7lu(ip,2),k7lu(k7lu(ip,3),3),
     &   k7lu(k7lu(ip,3),2),iporig
         stop
       endif
c
       IH0 = 10000 + jak*100
C
       xmod = sqrt(p7lu(ip,1)*p7lu(ip,1)+
     &        p7lu(ip,2)*p7lu(ip,2)+p7lu(ip,3)*p7lu(ip,3))
       call hfill(ih0+1, p7lu(ip,4)/ene ,0.,1.)
       isgn=sign(1,k7lu(ip,2))
       call hfill(ih0+2, isgn*p7lu(ip,3)/xmod,0.,1.)
c
       ikod = abs(k7lu(ip,2))

cam jetset7.3 id's : pi = 211;  K = 321
c                    pi0= 111; K0l= 130 ; K0s= 310
       if (ikod.eq.211.or.ikod.eq.321
     & .or.ikod.eq.111.or.ikod.eq.130.or.ikod.eq.310) then
c
C multiparticle channels : store final particles for mass plots
         if (ikod.eq.211.or.ikod.eq.321) then
           nch(it) = nch(it)+1
         elseif (ikod.eq.111.or.ikod.eq.130.or.ikod.eq.310) then
           nneu(it) = nneu(it)+1
         endif
         n = nneu(it) + nch(it)
         do 53 i=1,4
 53      qp(i,n,it) = p7lu(ip,i)
         qp(5,n,it) = k7lu(ip,2)/abs(k7lu(ip,2))
         qp(5,n,it) = qp(5,n,it)
     &   *k7lu(iporig,2)/abs(k7lu(iporig,2))
         ipfori(it) = iporig
       endif
c
 50    CONTINUE
       do 60 it=1,2
       if (it.eq.1) jak = jakp
       if (it.eq.2) jak = jakm
       ih0 = 10000 + jak*100
       if (jak.eq.5.and.nneu(it).ne.0) ih0=ih0+50
       ntrt = nch(it) + nneu(it)
       if (ntrt.gt.1) then
c        call vzero (qp(1,7,it),5*4)
         do 58 itr=1,ntrt
 58      call vadd(qp(1,itr,it),qp(1,7,it),qp(1,7,it),4)
         xmb2=qp(4,7,it)**2-qp(1,7,it)**2-qp(2,7,it)**2-qp(3,7,it)**2
         xmb = sqrt(xmb2)
         call hfill(ih0+4,xmb,1.,1.)
         call hfill(ih0+5,xmb2,1.,1.)
* spectral function
         v1 = 1./( (amtau2-xmb2)**2 * (amtau2+2.*xmb2) * xmb)
         call hfill(ih0+8,xmb,1.,v1)
c
* following assumes part 1 and part 2 play similar roles
* following assumes resonances in m1x and m2x if any
         call vadd(qp(1,1,it),qp(1,2,it),qp(1,8,it),4)
         call vadd(qp(1,1,it),qp(1,3,it),qp(1,9,it),4)
         call vadd(qp(1,2,it),qp(1,3,it),qp(1,10,it),4)
         xm12=qp(4,8,it)**2-qp(1,8,it)**2-qp(2,8,it)**2-qp(3,8,it)**2
         xm12= sqrt(xm12)
         xm13=qp(4,9,it)**2-qp(1,9,it)**2-qp(2,9,it)**2-qp(3,9,it)**2
         xm13= sqrt(xm13)
         xm23=
     &   qp(4,10,it)**2-qp(1,10,it)**2-qp(2,10,it)**2-qp(3,10,it)**2
         xm23= sqrt(xm23)
         if (ntrt.ge.4) then
          call vadd(qp(1,4,it),qp(1,9,it),qp(1,9,it),4)
          call vadd(qp(1,4,it),qp(1,10,it),qp(1,10,it),4)
          xm134 =
     &    qp(4,9,it)**2-qp(1,9,it)**2-qp(2,9,it)**2-qp(3,9,it)**2
          xm134 = sqrt(xm134)
          xm234 =
     &    qp(4,10,it)**2-qp(1,10,it)**2-qp(2,10,it)**2-qp(3,10,it)**2
          xm234 = sqrt(xm234)
          if (ntrt.ge.5) then
           call vadd(qp(1,5,it),qp(1,9,it),qp(1,9,it),4)
           call vadd(qp(1,5,it),qp(1,10,it),qp(1,10,it),4)
           xm1345=
     &     qp(4,9,it)**2-qp(1,9,it)**2-qp(2,9,it)**2-qp(3,9,it)**2
           xm1345= sqrt(xm1345)
           xm2345=
     &     qp(4,10,it)**2-qp(1,10,it)**2-qp(2,10,it)**2-qp(3,10,it)**2
           xm2345= sqrt(xm2345)
          endif
         endif
c
         if      (jak.eq.5) then
c a1 channels
           call hfill( ih0+6,xm13,1.,1.)
           call hfill( ih0+6,xm23,1.,1.)
           call hfill( ih0+7,xm12,1.,1.)
c
         else if (jak.ge.8.and.jak.le.9 ) then
c 4pi channels
           call hfill( ih0+6,xm134,1.,1.)
           call hfill( ih0+6,xm234,1.,1.)
           call hfill( ih0+7,xm13,1.,1.)
           call hfill( ih0+7,xm23,1.,1.)
c
         else if (jak.ge.10.and.jak.le.13) then
c 5pi 6pi channels
           call hfill( ih0+6,xm134,1.,1.)
           call hfill( ih0+6,xm234,1.,1.)
           call hfill( ih0+7,xm1345,1.,1.)
           call hfill( ih0+7,xm2345,1.,1.)
c
         else if (jak.ge.14.and.jak.le.18) then
c KKpi and Kpipi channels
           call hfill( ih0+6,xm13,1.,1.)
           call hfill( ih0+7,xm23,1.,1.)
c
         endif
       endif
60     continue
      ENDIF
C
C     ========================
C
      ELSE IF(IMOD.EQ. 1) THEN
C
       CALL HMINIM(0,0.)
       CALL HIDOPT(0,'1EVL')
       CALL HIDOPT(0,'INTE')
       CALL HINDEX
      ENDIF
C
      RETURN
      END
      SUBROUTINE QQTOPS (i1,i2 )
C-----------------------------------------------------------------------
C   B.Bloch-Devaux April 1991
C
C        jetset 7.4 parton shower INTERFACE
C
C        prepare parton shower for fermions in positions i1,i2
C        i1    ANTIFERMION   }
C        i2    FERMION       }
C
C     comdecks referenced : LUN7COM
C-----------------------------------------------------------------------
      PARAMETER (L1MST=200, L1PAR=200)
      PARAMETER (L2PAR=500, L2PARF=2000 )
      PARAMETER (LJNPAR=4000)
      COMMON /LUDAT1/ MSTU(L1MST),PARU(L1PAR),MSTJ(L1MST),PARJ(L1PAR)
      COMMON /LUDAT2/ KCHG(L2PAR,3),PMAS(L2PAR,4),PARF(L2PARF),VCKM(4,4)
      COMMON /LUDAT3/ MDCY(L2PAR,3),MDME(L2PARF,2),BRAT(L2PARF),
     &                KFDP(L2PARF,5)
      COMMON /LUDAT4/ CHAF(L2PAR)
      CHARACTER*8 CHAF
      COMMON /LUJETS/ N7LU,K7LU(LJNPAR,5),P7LU(LJNPAR,5),V7LU(LJNPAR,5)
C
      data nev/0/
      dimension ijoin(2),z(4)
         nev = nev + 1
C  now the quarks for shower lines
         K7LU(i1,1)= 2
         K7LU(i2,1)= 1
C
C   Connect the partons in  a string configuration
C
         NJOIN = 2
         IJOIN(1) = i1
         IJOIN(2) = i2
         CALL LUJOIN( NJOIN,IJOIN)
C
C    CALCULATE THE QQBAR MASS
C
         IF( NEV.LE. 5) CALL LULIST(1)
         DO 150 I=1,4
           Z(I) = p7lu(i1,i)+p7lu(i2,i)
  150    CONTINUE
         qMAX = Z(4)**2 -Z(3)**2 -Z(2)**2 -Z(1)**2
         IF ( QMAX.GT.0.) THEN
             QMAX = SQRT(QMAX )
         ELSE
             QMAX = 0.
             PRINT * ,' WARNING QMAX = 0. AT EVENT ',NEV
             CALL LULIST(1)
         ENDIF
C
C         GENERATE PARTON SHOWER
C
         CALL LUSHOW(ijoin(1),ijoin(2),QMAX)
         IF (MSTJ(105).GT.0) CALL LUEXEC
C
         return
         end
      SUBROUTINE CREKWTK
C --------------------------------------------------------------------
C Create the bank of event weights 'KWTK'
C and put it on the event list bank
C                                J. Boucrot 02 April 1997
C--------------------------------------------------------------------
C     input     : none
C
C     output    : bank 'KWTK' with 1 row containing the
C                 6 event weights
C--------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
      DATA EPSIL / 0.01 /
      COMMON / KALINOUT /  WTKAL(6)
      real*8 wtkal
      real weigh(6)
C--------------------------------------------------------------------
      NWEIG=6
      DO 10 I=1,NWEIG
         WEIGH(I)=SNGL(WTKAL(I))
 10   CONTINUE
C Drop the previous bank, book the new one:
      CALL BDROP(IW,'KWTK')
      IF (WEIGH(1).LT.EPSIL) GO TO 999
      CALL BKFMT('KWTK','2I,(6F)')
      CALL AUBOS('KWTK',0,NWEIG+LMHLEN,JKWTK,IGARB)
      IF (IGARB.EQ.2) GO TO 999

C Fill the bank:
      IW(JKWTK+LMHCOL)=NWEIG
      IW(JKWTK+LMHROW)=1
      CALL UCOPY(WEIGH(1),RW(JKWTK+LMHLEN+1),NWEIG)
C Put the bank on the event bank list:
      CALL BLIST(IW,'E+','KWTK')
C
 999  RETURN
      END
      SUBROUTINE UGTSEC
C --------------------------------------------------------------------
C     B.Bloch vreate x-section bank January 1999
C --------------------------------------------------------------------
      COMMON / FINUS / CSTCM,ERREL
      REAL*8           CSTCM,ERREL
      COMMON / KGCOMM / ISTA,IDPR,ECMS,WEIT,VRTEX(4),TABL(55),NEVENT(8)
      PARAMETER ( IGCO = 4010 )
      PARAMETER ( IVERS = 100 )
      DATA NACCOLD/0/
      NACC = NEVENT(2)
C    do not rebook if accepted events did not change
      IF ( NACC.eq.NACCOLD) go to 100
C CALCULATE TOTAL CROSS SECTION
C with mode =1 (end) KEYYFS is not used
      KEYYFS = 0
      CALL EVENTZ(1,KEYYFS)
      CSTNB= CSTCM*1.E33
      DCSNB= ERREL*CSTNB
C Create cross section bank
      NTOT = NEVENT(1)
      XTOT = CSTNB
      RTOT = DCSNB
      IS = 1
      IDC = IGCO
      IVER = IVERS
      NACCOLD = NACC
      XACC = XTOT*float(NEVENT(2))/float(NEVENT(1))
C    attention.....pour de grands nombres , calculs pas a pas !
      ERACC = 1./float(NEVENT(2)) - 1./float(NEVENT(1))
      ERACC = ERACC + ERREL*ERREL
      ERACC = sqrt(ERACC)
      RACC = XACC*ERACC
      isec = KSECBK(IS,IDC,IVER,NTOT,NACC,XTOT,RTOT,XACC,RACC)
      CALL PRTABL('KSEC',0)
 100  RETURN
      END