      SUBROUTINE ASKUSE (IDPR,ISTA,NTRK,NVRT,ECMS,WEIT)
C ------------------------------------------------------------
C -  B. Bloch  - January 1998
C! GET AN EVENT FROM PYTHIA 6.1
C! clean it to keep fermion decay products from Z0, W+- and H0
C! then transfer the information into kine and vert banks.
C
C  PYTHIA 6.1 contains THE FULL STUFF OF JETSET 7.4
C
C     structure : subroutine
C     output arguments :
C          IDPR   : process identification,each digit corresponds to
C          the flavor of the evnt ( several flavors /event is possible)
C          ISTA   : status flag ( 0 means ok), use it to reject
C                   unwanted events
C          NTRK   : number of tracks generated and kept
C                  (i.e. # KINE banks  written)
C          NVRT   : number of vertices generated
C                   (i.e. # VERT banks written)
C          ECMS   : center of mass energy for the event (may be
C                   different from nominal cms energy)
C          WEIT   : event weight ( not 1 if a weighting method is used)
C -----------------------------------------------------------------
C*CA pyt6com
C...Double precision and integer declarations.
      IMPLICIT DOUBLE PRECISION(A-H, O-Z)
      INTEGER PYK,PYCHGE,PYCOMP
C...Commonblocks.
      PARAMETER (L1MST=200, L1PAR=200)
      PARAMETER (L2PAR=500, L2PARF=2000 )
      PARAMETER (LJNPAR=4000)

      COMMON/PYJETS/N7LU,NPAD,K7LU(LJNPAR,5),P7LU(LJNPAR,5),
     $              V7LU(LJNPAR,5)
      COMMON/PYDAT1/MSTU(L1MST),PARU(L1PAR),MSTJ(L1MST),PARJ(L1PAR)
      COMMON/PYDAT2/KCHG(L2PAR,4),PMAS(L2PAR,4),PARF(L2PARF),VCKM(4,4)
      COMMON/PYDAT3/MDCY(L2PAR,3),MDME(LJNPAR,2),BRAT(LJNPAR),
     $              KFDP(LJNPAR,5)
      COMMON/PYDAT4/CHAF(L2PAR,2)
      CHARACTER CHAF*16
C
      COMMON/PYSUBS/MSEL,MSELPD,MSUB(L2PAR),KFIN(2,-40:40),CKIN(L1MST)
      COMMON/PYPARS/MSTP(L1MST),PARP(L1MST),MSTI(L1MST),PARI(L1MST)
      COMMON/PYINT1/MINT(400),VINT(400)
      COMMON/PYINT2/ISET(500),KFPR(500,2),COEF(500,20),ICOL(40,4,2)
      COMMON/PYINT3/XSFX(2,-40:40),ISIG(1000,3),SIGH(1000)
      COMMON/PYINT4/MWID(500),WIDS(500,5)
      COMMON/PYINT5/NGENPD,NGEN(0:500,3),XSEC(0:500,3)
      COMMON/PYINT6/PROC(0:500)
      CHARACTER PROC*28
      COMMON/PYINT7/SIGT(0:6,0:6,0:5)
C
      REAL*4 VRTX(4),PTRAK(4,2)
      INTEGER KFL(8)
C
C*CA bcs
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
      COMMON / GLUPAR / SVERT(3),ECM,EGGMIN,LUMIF,IFL,IFLAG
      REAL*4 LUMIF,eggmin,ecm,svert
C     IFL      : LUND flavour , set to 0 by default, can be changed
C     ECM      : nominal cms energy
C     SVERT    : vertex smearing, set to 0. by default, can be changed
C     EGGMIN   : minimum invariant mass for gamma gamma
C     LUMIF    : luminosity function
C     IFLAG    : if on , apply VDM form factor at generation

      COMMON / GLUSTA / ICOULU(10)
      REAL*4 PP,XX(2),et,ect,ent,thr
      REAL*8 TMIN,TMAX,YY,TT,DX
      LOGICAL KEEP
C
      REAL PI, TWOPI, PIBY2, PIBY3, PIBY4, PIBY6, PIBY8, PIBY12
      REAL RADEG, DEGRA
      REAL CLGHT
      INTEGER NBITW, NBYTW, LCHAR
      PARAMETER (PI=3.141592653589)
      PARAMETER (RADEG=180./PI, DEGRA=PI/180.)
      PARAMETER (TWOPI = 2.*PI , PIBY2 = PI/2., PIBY4 = PI/4.)
      PARAMETER (PIBY6 = PI/6. , PIBY8 = PI/8.)
      PARAMETER (PIBY12= PI/12., PIBY3 = PI/3.)
      PARAMETER (CLGHT = 29.9792458)
      PARAMETER (NBITW = 32 , NBYTW = NBITW/8 , LCHAR = 4)
C
      real*4 ecms,weit,ebeam,rx,ry,rz,dum,pt,eb
      DATA IFI / 0/
C ------------------------------------------------------------------
C
      ISTA = 0
      IFI  =  IFI + 1
      NTRK = 0
      NVRT = 0
C - SET THE CMS ENERGY FOR THIS EVENT ECMS = ECM
      ECMS = ECM
      EBEAM = ECM*0.5
      WEIT = 1.
      IDPR = 0
      IFL1 = 0
C reset entries and fragmentation info
      N7LU = 0
      MSTU(90) = 0
C
C - GET AN EVENT FROM PYTHIA
C
  1   CONTINUE
      IF ((MINT(1).GE.19 .AND. MINT(1).LE.27).or.(mint(1).eq.141)) THEN
C     this is a W pair production or combination of Z0, W and/or H0
          MSTP111 = MSTP(111)
          MSTP(111)=0
          MSTP(125)=1
          CALL PYEVNT
          CALL PYTCLR
          CALL PYEXEC
          MSTP(111)=MSTP111
      ELSE
          IF(IFL.NE.14) THEN
            MSTP(125)=0
            CALL PYEVNT
          ELSE
            CALL GAMGAM
          ENDIF
C
C - STORE BEAM PARTICLES ALSO IN BOS BANKS
C
          IPART = KGPART(11)
          DO 2 ITR = 1,2
             DO 9 I=1,4
 9              PTRAK(I,ITR) = 0.
             IPART = KGPART(11)
             PTRAK(3,ITR) = 0.5*ECM
             IF ( ITR.EQ.2) THEN
                IPART = KGPART(-11)
                PTRAK(3,ITR) =- 0.5*ECM
             ENDIF
             ITRK= ITR
C             if ( ifl.eq.14 ) itrk = itr+2
             IST=KBKINE(-ITRK,PTRAK(1,ITR),IPART,0)
             IF (IST.LE.0) THEN
                   ISTA=-2
                   GO TO 998
                ENDIF
  2        CONTINUE
      ENDIF
C
C   FILL BOS BANKS
C  
C
C - GET THE PRIMARY VERTEX
      CALL RANNOR (RX,RY)
      CALL RANNOR (RZ,DUM)
      VRTX(1) = RX*SVERT(1)
      VRTX(2) = RY*SVERT(2)
      VRTX(3) = RZ*SVERT(3)
      VRTX(4) = 0.
C
C     DEBUGGING FIRST FIVE EVENTS:
C
      IF (IFI.LE.5) CALL PYLIST(1)
C
C    look at event content
      CALL PYTABU(11)
      CALL PYTABU(21)
C
C      Call the specific routine KXP6AL to fill BOS banks
C      the secondary vertices are propagated
      CALL KXP6AL (VRTX,ISTA,NVRT,NTRK)
C -   book fragmentation info
      CALL KP6ZFR (IST)
      IF ( IST.ne.0) ista = ista+ist
C
C Look for flavor generated
        DO 11 I=1,8
 11      KFL(I)=0
        NFL=0
        DO 20 I=1,N7LU
           ITYP=ABS(PYK(I,9))
           IF (ITYP.GT.8 .OR. ITYP.EQ.0) GO TO 20
           IF ( NFL.GT.0) THEN
              DO 19 J=1,NFL
              IF (ITYP.EQ.KFL(J)) GO TO 20
  19          CONTINUE
           ENDIF
           NFL=NFL+1
           KFL(NFL)=ITYP
           IDPR=10*IDPR+ITYP
  20    CONTINUE
C
C  Add the original subprocess requested
C
      IF (MSTU(24).NE.0) THEN
        WRITE(iw(6),'(''  ---ERROR PYEXEC AT EVENT #  '',I10)') IFI
        CALL PYLIST(1)
        ISTA = -8
      ENDIF
 998  IF (ISTA.EQ.0 ) THEN
         ICOULU(10) = ICOULU(10)+1
      ELSEIF (ISTA.GT.0) THEN
         ICOULU(1) = ICOULU(1) +1
         ICOULU(9) = ICOULU(9) +1
      ELSEIF ( ISTA.LT.0) THEN
         ICOULU(-ISTA) = ICOULU(-ISTA) +1
         ICOULU(9) = ICOULU(9) +1
      ENDIF
C
C  -  FILLING HISTOGRAMS
C
      IF(IFL.NE.14) THEN
          id1=1
       IF((MINT(1).GE.19 .AND. MINT(1).LE.27).or.(mint(1).eq.141)) id1=3
           id2 =id1+1
           CALL HFILL(10001,FLOAT(N7LU),0.,1.)
           CALL HFILL(10002,real(P7LU(id1,4)),0.,1.)
           CALL HFILL(10003,real(P7LU(id2,4)),0.,1.)
           ET = SQRT(P7LU(id1,1)**2+P7LU(id1,2)**2 +P7LU(id1,3)**2)
         IF (ET.GT.0.0001) CALL HFILL(10004,real(P7LU(id1,3))/ET,0.,1.)
           ET = SQRT(P7LU(id2,1)**2+P7LU(id2,2)**2+P7LU(id2,3)**2)
         IF (ET.GT.0.0001) CALL HFILL(10005,real(P7LU(id2,3))/ET,0.,1.)
           DO 10 I=1,N7LU
            IF(K7LU(I,2).LT.40)CALL HFILL(10006,FLOAT(K7LU(I,2)),0.,1.)
 10        CONTINUE
           if (id1.eq.3) then
              call hfill(10007,real(P7LU(id1,5)),0.,1.)
              call hfill(10008,real(P7LU(id2,5)),0.,1.)
           endif
      ENDIF
C
C -  ANALYSE TREE INFORMATION:
C
      CALL PYEDIT(2)
      if(ifl.eq.14) n7lu=n7lu-2
      NT=0
      NTC=0
      NNT=0
      ET=0.
      ECT=0.
      ENT=0.
      DO 30 I=1,N7LU
       if ( ifl.eq.14 .and. i.lt.3) go to 30
       NT=NT+1
       ET=ET+P7LU(I,4)
       IF(ABS(PYP(I,6)).GT.0.1)THEN
        NTC=NTC+1
        ECT=ECT+P7LU(I,4)
       ELSE
        NNT=NNT+1
        ENT=ENT+P7LU(I,4)
        pt = sqrt(P7LU(I,1)**2+P7LU(I,2)**2)
        IF(pt.LT.0.0001)THEN
          CALL HFILL(10016,real(P7LU(I,4)),0.,1.)
          ENT=ENT-P7LU(I,4)
        ENDIF
       ENDIF
 30   CONTINUE
      CALL HFILL(10010,FLOAT(NT),0.,1.)
      CALL HFILL(10011,ET,0.,1.)
      CALL HFILL(10012,FLOAT(NTC),0.,1.)
      CALL HFILL(10013,ECT,0.,1.)
      CALL HFILL(10014,FLOAT(NNT),0.,1.)
      CALL HFILL(10015,ENT,0.,1.)
C
C - THRUST:
C
      CALL PYTHRU(DTHR,DOBL)
      CALL HFILL(10017,real(DTHR),0.,1.)
C
C gamma-gamma histos
C
      if(ifl.eq.14)  CALL GAMFIL
      call usrfill
      RETURN
      END
      SUBROUTINE ASKUSI(IGCOD)
C ------------------------------------------------------------------
C - B. Bloch  - January   1998
C! Initialization routine of PHYTIA 6.1 generator
C ------------------------------------------------------------------
C*CA PYT6COM
C...Double precision and integer declarations.
      IMPLICIT DOUBLE PRECISION(A-H, O-Z)
      INTEGER PYK,PYCHGE,PYCOMP
C...Commonblocks.
      PARAMETER (L1MST=200, L1PAR=200)
      PARAMETER (L2PAR=500, L2PARF=2000 )
      PARAMETER (LJNPAR=4000)

      COMMON/PYJETS/N7LU,NPAD,K7LU(LJNPAR,5),P7LU(LJNPAR,5),
     $              V7LU(LJNPAR,5)
      COMMON/PYDAT1/MSTU(L1MST),PARU(L1PAR),MSTJ(L1MST),PARJ(L1PAR)
      COMMON/PYDAT2/KCHG(L2PAR,4),PMAS(L2PAR,4),PARF(L2PARF),VCKM(4,4)
      COMMON/PYDAT3/MDCY(L2PAR,3),MDME(LJNPAR,2),BRAT(LJNPAR),
     $              KFDP(LJNPAR,5)
      COMMON/PYDAT4/CHAF(L2PAR,2)
      CHARACTER CHAF*16
C
      COMMON/PYSUBS/MSEL,MSELPD,MSUB(L2PAR),KFIN(2,-40:40),CKIN(L1MST)
      COMMON/PYPARS/MSTP(L1MST),PARP(L1MST),MSTI(L1MST),PARI(L1MST)
      COMMON/PYINT1/MINT(400),VINT(400)
      COMMON/PYINT2/ISET(500),KFPR(500,2),COEF(500,20),ICOL(40,4,2)
      COMMON/PYINT3/XSFX(2,-40:40),ISIG(1000,3),SIGH(1000)
      COMMON/PYINT4/MWID(500),WIDS(500,5)
      COMMON/PYINT5/NGENPD,NGEN(0:500,3),XSEC(0:500,3)
      COMMON/PYINT6/PROC(0:500)
      CHARACTER PROC*28
      COMMON/PYINT7/SIGT(0:6,0:6,0:5)
C
C*CA BCS
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
      COMMON / GLUPAR / SVERT(3),ECM,EGGMIN,LUMIF,IFL,IFLAG
      REAL*4 LUMIF,ECM,EGGMIN,SVERT
C     IFL      : LUND flavour , set to 0 by default, can be changed
C     ECM      : nominal cms energy
C     SVERT    : vertex smearing, set to 0. by default, can be changed
C     EGGMIN   :minimum invariant mass for gamma gamma
C     LUMIF    :luminosity function
C     IFLAG    : if on , apply VDM form factor at generation

      COMMON / GLUSTA / ICOULU(10)
C
      REAL*4 TABL(25)
C
      PARAMETER (LPDEC=48)
      INTEGER NODEC(LPDEC)
      INTEGER ALTABL,ALRLEP
      EXTERNAL ALTABL,ALRLEP
      REAL*4 zmas,ebeam,wtev,wtmx,eb
C  maximum code value for IFL parameter
      PARAMETER ( IFLMX = 13 )
C    IGCOD  for PYTHIA 6.1
      PARAMETER ( IGCO  =  5041)
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
C -----------------------------------------------------------------
C
      IUT = IW(6)
C
C   Return generator code IGCOD
C
      IGCOD = IGCO
      WRITE(IUT,101) IGCOD
 101  FORMAT(/,10X,
     &       'PYTH05    CODE NUMBER =',I4,' LAST MODIFICATION ',
     $  ' November 27 , 2000 '
     & ,/,10X,'***********************************************',//)
         NLUND = NAMIND ('GPYT')
         JLUND = IW(NLUND)
         i1 = 0
         i2 = 0
         IF (JLUND .NE. 0) THEN
            IFL  = IW(JLUND+1)
            IF(IFL.GE.0 .AND. IFL.LE.IFLMX) MSEL=0
*   6 FLAVOUR HADRON PRODUCTION
            IF(IFL.EQ.0)THEN
             MSUB(1)=1
             DO 9 IL=MDCY(23,2),MDCY(23,2)+MDCY(23,3)-1
              IKFDP=KFDP(IL,1)
C        EXCLUDE ALL EXCEPT OF U,D,C,S,B,T
              IF(IKFDP.LT.1 .OR. IKFDP.GT.6)MDME(IL,1)=MIN(0,MDME(IL,1))
 9           CONTINUE
             I1= 23
C   5 FLAVOUR HADRON PRODUCTION
            ELSEIF(IFL.EQ.1)THEN
             KC = PYCOMP(23)
             DO 10 IL=MDCY(KC,2),MDCY(KC,2)+MDCY(KC,3)-1
              IKFDP=KFDP(IL,1)
C        EXCLUDE ALL EXCEPT OF U,D,C,S,B
              IF(IKFDP.LT.1 .OR. IKFDP.GT.5)MDME(IL,1)=MIN(0,MDME(IL,1))
 10          CONTINUE
             MSUB(1)=1
             i1 = 23
C   ONLY T TBAR PRODUCTION
            ELSEIF(IFL.EQ.2)THEN
             KC = PYCOMP(23)
             DO 20 IL=MDCY(KC,2),MDCY(KC,2)+MDCY(KC,3)-1
               IF(KFDP(IL,1).NE.6)MDME(IL,1)=MIN(0,MDME(IL,1))
 20          CONTINUE
             MSUB(1)=1
             i1 = 23
C   W+ W-   PRODUCTION
            ELSEIF(IFL.EQ.3)THEN
             MSUB(25)=1
             i1 = 24
C   Z0 Z0 PRODUCTION
            ELSEIF(IFL.EQ.4)THEN
             MSUB(22)=1
             i1 = 23
C   Z0 GAMMA PRODUCTION
            ELSEIF(IFL.EQ.5)THEN
             MSUB(19)=1
             i1 = 22
             i2 = 23
C   GAMMA GAMMA PRODUCTION
            ELSEIF(IFL.EQ.6)THEN
             MSUB(18)=1
C   GAMMA H0    PRODUCTION
            ELSEIF(IFL.EQ.7)THEN
             MSUB(21)=1
             i1 = 25
C   H0    H0    PRODUCTION
            ELSEIF(IFL.EQ.8)THEN
             MSUB(27)=1
             i1 = 25
C   Z0    H0    PRODUCTION
            ELSEIF(IFL.EQ.9)THEN
             MSUB(24)=1
             i1 = 23
             i2 = 25
C   NEUTRINO     PRODUCTION
            ELSEIF(IFL.EQ.10)THEN
             MSUB(1)=1
             DO 30 IL=MDCY(23,2),MDCY(23,2)+MDCY(23,3)-1
               IKFDP=KFDP(IL,1)
C              EXCLUDE quark and lepton decays
               IF(.NOT. (IKFDP.EQ.12.OR.IKFDP.EQ.14.OR.IKFDP.EQ.16))
     $              MDME(IL,1)=MIN(0,MDME(IL,1))
 30          CONTINUE
             i1 = 23
C   LEPTON     PRODUCTION
            ELSEIF(IFL.EQ.11)THEN
             MSUB(1)=1
             DO 31 IL=MDCY(23,2),MDCY(23,2)+MDCY(23,3)-1
               IKFDP=KFDP(IL,1)
C              EXCLUDE quark and neutrino decays
               IF(.NOT.(IKFDP.EQ.11.OR.IKFDP.EQ.13.OR.IKFDP.EQ.15))
     $              MDME(IL,1)=MIN(0,MDME(IL,1))
 31          CONTINUE
             i1 = 23
C   Photoproduction with qcd jets only
            ELSEIF(IFL.EQ.12)THEN
              MSUB(11) =1
              MSUB(12) =1
              MSUB(13) =1
              MSUB(28) =1
              MSUB(33) =1
              MSUB(53) =1
              MSUB(54) =1
              MSUB(68) =1
C   Photoproduction with high pt photons only
            ELSEIF(IFL.EQ.13)THEN
              MSUB(14) =1
              MSUB(18) =1
              MSUB(29) =1
              MSUB(34) =1
              MSUB(114) =1
              MSUB(115) =1
            ELSEIF(IFL.EQ.14)THEN
C...Range of invariant masses to consider for gamma-gamma.
              EGGMIN=20.
              INTS = IW(NAMIND('GGEM'))
              IF(INTS.GT.0) EGGMIN=RW(INTS+1)
              PARP(2)=EGGMIN
C...Generate combinations of resolved, anomalous and direct components.
              MSEL=2
              MSTP(14)=10
C...Allow for variable energies in gamma-gamma collision.
              MSTP(171)=1
            ENDIF
C*******
            ECM  = RW(JLUND+2)
            IPRT = IW(JLUND+3)
         ELSE
            IFL = 0
            ECM = 91.2
            IPRT = 0
         ENDIF
C - make use of a smearing of the vertex  if it is given
         NSVER = NAMIND ('SVRT')
         JSVER = IW(NSVER)
         IF (JSVER .NE. 0) THEN
            SVERT(1) = RW(JSVER+1)
            SVERT(2) = RW(JSVER+2)
            SVERT(3) = RW(JSVER+3)
         ELSE
            SVERT(1) = 0.0180
            SVERT(2) = 0.0010
            SVERT(3) = 1.00
         ENDIF
C
C   Issue the relevant parameters
C
      WRITE (IUT,1000)
      WRITE (IUT,1007)
 1000 FORMAT(1X,78('*'),/,/,10X,'WELCOME TO PYTHIA 6.1 & JETSET 7.4'/
     $                      10X,'                                   '/)
 1007 FORMAT (1X,78('*') )
C
      DO 5  K=1,10
 5    ICOULU(K)=0
C
C  Set up some default values for masses and initial conditions
C
      PMAS(PYCOMP(25),1)= 100.
      PMAS(PYCOMP( 6),1)= 176.
      PMAS(PYCOMP(23),1)= 91.2
C
C -- complete PART bank with LUND  particles
C    use the library routine KXP6IN
      CALL KXP6IN (IPART,IKLIN)
      IF (IPART.LE.0 .OR. IKLIN.LE.0) THEN
         WRITE (IW(6),'(1X,''error in PART or KLIN bank - STOP - ''
     +                 ,2I3)') IPART,IKLIN
         CALL EXIT
      ENDIF
C at the moment we cannot use yet the external Tau decay library ...
      MSTJ(28) = 0
C   Make sure that masses in PART bank are consistent
C   in case they have been modified by data cards
      NAPAR = NAMIND('PART')
C This is the aleph number of the Z0(lund code=23),top (6) and Higgs(25)
C function KGPART returns the ALEPH code corresponding to the LUND code
C required.
      JPART = IW(NAPAR)
      IZPART = KGPART(23)
      IF (IZPART.GT.0)  THEN
        ZMAS = PMAS(PYCOMP(23),1)
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
        ZMAS = PMAS(PYCOMP( 6),1)
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
        ZMAS = PMAS(PYCOMP(25),1)
        KPART = KROW(JPART,IHPART)
        RW(KPART+6)=ZMAS
        IANTI = ITABL(JPART,IHPART,10)
        IF (IANTI.NE.IHPART) THEN
          KAPAR = KROW(JPART,IANTI)
          RW(KAPAR+6)=ZMAS
        ENDIF
      ENDIF
C
C - Print PART and KLIN banks
      IF (IPRT.GT.0) CALL PRPART
      IF (IPRT.GT.1) CALL PYLIST(12)
      IF (IPRT.LE.1) then
C        if ( i1.gt.0) call kxp6st(i1)
C        if ( i2.gt.0) call kxp6st(i2)
        call kxp6st(22)
        call kxp6st(23)
        call kxp6st(24)
      endif
C  book event content machinery
      CALL PYTABU(10)
      CALL PYTABU(20)
C
C -- get list of  particle# which should not be decayed
C    in LUND  because they are decayed in GALEPH.
C    the routines uses the KLIN bank and fills the user array
C    NODEC in the range [1-LPDEC]
      MXDEC = KNODEC (NODEC,LPDEC)
      MXDEC = MIN (MXDEC,LPDEC)
C
C -- inhibit decays in LUND
C    If the user has set some decay channels by data cards they will
C    will not be overwritten
      IF (MXDEC .GT. 0) THEN
         DO 40 I=1,MXDEC
            IF (NODEC(I).GT.0) THEN
               JIDB = NLINK('MDC1',NODEC(I))
               IF (JIDB .EQ. 0) MDCY(PYCOMP(NODEC(I)),1) = 0
            ENDIF
   40    CONTINUE
      ENDIF
C
C   dump the generator parameters for this run in a bank
C assume all parameters are real and stored as a single row
      TABL(1) = FLOAT(IFL)
      TABL(2) = ECM
      DO 11 I=1,3
 11   TABL(2+I) = SVERT(I)
      NWB =  5
      IND = ALTABL('KPAR',NWB,1,TABL,'2I,(F)','C')
C
C  Fill RLEP bank
      IEBEAM = NINT(ECM* 500. )
      JRLEP = ALRLEP(IEBEAM,'    ',0,0,0)
      CALL PRTABL('RLEP',0)
      CALL PRTABL('KPAR',0)
C
C -   keep fragmentation info
      MSTU(17) = 1
C   Force non storage of documentation as this could give troubles to
C   the interface : one needs MSTP(125)=1 for history of W decays
C   so set up the value dynamically.....
C      MSTP(125)=0
C
C    set up PYTHIA job with phyinit for e+e- anihilation in aleph
C
      WRITE(iw(6),999)
 999  FORMAT(//
     .20X,' P Y T H I A  WILL BE INITIALIZED FOR THE'//
     .20X,'       A L E P H - BEAM DIRECTIONS   '//
     .20X,'        E-  IN   +Z     DIRECTION'/
     .20X,'        E+  IN   -Z     DIRECTION'//)
C
      IF(IFL.NE.14) THEN
        WCM = DBLE(ECM)
        CALL PYINIT('CMS','E-','E+',WCM)
      ELSE
CAST gamma-gamma generation, variable energy gamma beams
        CALL GAMINI
      ENDIF
C
C  -  BOOKING HISTOGRAMS
C
       EB = 0.5*ECM
       CALL HBOOK1(10001,'TOTAL MULTIPLICITY GENERATED',50,0.,250.,0.)
       CALL HBOOK1(10002,'ENERGY OF OUTGOING PARTICLE',50,0.,ECM,0.)
       CALL HIDOPT(10002,'LOGY')
       CALL HBOOK1(10003,'ENERGY OF OUTGOING ANTIPARTICLE',50,0.,ECM,0.)
       CALL HIDOPT(10003,'LOGY')
       CALL HBOOK1(10004,'COS(THETA) OF OUTGOING PARTICLE',51,-1.,1.04,
     $ 0.)
       CALL HBOOK1(10005,'COS(THETA) OF ANTI-PARTICLE',51,-1.,1.04,0.)
       CALL HBOOK1(10006,'PRIMARY PARTICLES PRODUCED (FERMIONS + BOSONS'
     $            ,40,0.,40.,0.)
       CALL HBOOK1(10010,'STABLE PART.: MULTIPLICITY',50,0.,150.,0.)
       CALL HBOOK1(10011,'STABLE PART.: SUM OF ENERGY',50,0.,ECM,0.)
       CALL HIDOPT(10011,'LOGY')
       CALL HBOOK1(10012,'STABLE PART.: CHAR. MULTIPL.',50,0.,100.,0.)
       CALL HBOOK1(10013,'STABLE PART.: CHAR. ENERGY',50,0.,ECM,0.)
       CALL HBOOK1(10014,'STABLE PART.: NEUTRAL MULTIPL.',50,0.,100.,0.)
       CALL HBOOK1(10015,'STABLE PART.: NEUTRAL ENERGY',50,0.,ECM,0.)
       CALL HBOOK1(10016,'STABLE PART.: NEUTR.ENERGY OF LOW PT TRACKS',
     .             50,0.,ECM,0.)
       CALL HIDOPT(10016,'LOGY')
       CALL HBOOK1(10017,'STABLE PART.: THRUST',50,0.,1.,0.)
       do 41 i = 10,80
         if ( msub(i).gt.0) go to 42
 41    continue
       go to 99
 42    continue
c book resonnance mass produced
       call hbook1(10007,'1st resonnance mass produced',50,0.,ECM,0.)
       call hbook1(10008,'2nd resonnance mass produced',50,0.,ECM,0.)
 99   CONTINUE
      call usrbook
      RETURN
      END
      subroutine usrbook
      return
      end
      subroutine usrfill
      return
      end
      subroutine usrend
      return
      end
      SUBROUTINE USCJOB
C-------------------------------------------------------------------
C! End of job routine    Pythia 6.1
C
C   Author   :- B.Bloch              Nov 2000
C   print any relevant info
C
C------------------------------------------------------------------
C...Double precision and integer declarations.
      IMPLICIT DOUBLE PRECISION(A-H, O-Z)
      INTEGER PYK,PYCHGE,PYCOMP
C...Commonblocks.
      PARAMETER (L1MST=200, L1PAR=200)
      PARAMETER (L2PAR=500, L2PARF=2000 )
      PARAMETER (LJNPAR=4000)

      COMMON/PYJETS/N7LU,NPAD,K7LU(LJNPAR,5),P7LU(LJNPAR,5),
     $              V7LU(LJNPAR,5)
      COMMON/PYDAT1/MSTU(L1MST),PARU(L1PAR),MSTJ(L1MST),PARJ(L1PAR)
      COMMON/PYDAT2/KCHG(L2PAR,4),PMAS(L2PAR,4),PARF(L2PARF),VCKM(4,4)
      COMMON/PYDAT3/MDCY(L2PAR,3),MDME(LJNPAR,2),BRAT(LJNPAR),
     $              KFDP(LJNPAR,5)
      COMMON/PYDAT4/CHAF(L2PAR,2)
      CHARACTER CHAF*16
C
      COMMON/PYSUBS/MSEL,MSELPD,MSUB(L2PAR),KFIN(2,-40:40),CKIN(L1MST)
      COMMON/PYPARS/MSTP(L1MST),PARP(L1MST),MSTI(L1MST),PARI(L1MST)
      COMMON/PYINT1/MINT(400),VINT(400)
      COMMON/PYINT2/ISET(500),KFPR(500,2),COEF(500,20),ICOL(40,4,2)
      COMMON/PYINT3/XSFX(2,-40:40),ISIG(1000,3),SIGH(1000)
      COMMON/PYINT4/MWID(500),WIDS(500,5)
      COMMON/PYINT5/NGENPD,NGEN(0:500,3),XSEC(0:500,3)
      COMMON/PYINT6/PROC(0:500)
      CHARACTER PROC*28
      COMMON/PYINT7/SIGT(0:6,0:6,0:5)
C
C
      COMMON / GLUPAR / SVERT(3),ECM,EGGMIN,LUMIF,IFL,IFLAG
      REAL*4 LUMIF,ecm,svert,eggmin
C     IFL      : LUND flavour , set to 0 by default, can be changed
C     ECM      : nominal cms energy
C     SVERT    : vertex smearing, set to 0. by default, can be changed
C     EGGMIN   :minimum invariant mass for gamma gamma
C     LUMIF    :luminosity function
C     IFLAG    : if on , apply VDM form factor at generation

      COMMON / GLUSTA / ICOULU(10)
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
C.......................................................................
C
C   PRINTOUT OF STSTISTICS DONE BY PYTHIA
C
       CALL PYSTAT(1)
       CALL UGTSEC
C
C   PRINTOUT OF DECAY CHANNELS,PARTIAL WIDTHS.... USED BY PYTHIA
C
C      CALL PYSTAT(2)
C
C AJF addition for gamma-gamma events
      IF(IFL.EQ.14) CALL GAMEND
       IUT=IW(6)
       WRITE(IUT,101)
  101  FORMAT(//20X,'EVENTS STATISTICS',
     &         /20X,'*****************')
       WRITE(IUT,102) ICOULU(9)+ICOULU(10),ICOULU(10),ICOULU(9)
  102  FORMAT(/5X,'# OF GENERATED EVENTS                = ',I10,
     &        /5X,'# OF ACCEPTED  EVENTS                = ',I10,
     &        /5X,'# OF REJECTED  EVENTS                = ',I10)
       WRITE(IUT,103)
  103  FORMAT(//20X,'REJECT STATISTICS',
     &         /20X,'*****************')
       WRITE(IUT,104) (ICOULU(I),I=1,8)
  104  FORMAT(/10X,'IR= 1 LUND ERROR unknown part    # OF REJECT =',I10,
     &        /10X,'IR= 2 BOS  ERROR KINE/VERT       # OF REJECT =',I10,
     &        /10X,'IR= 3 LUND ERROR too many tracks # OF REJECT =',I10,
     &        /10X,'IR= 4 LUND ERROR Beam wrong pos  # OF REJECT =',I10,
     &        /10X,'IR= 5 LUND ERROR status code >5  # OF REJECT =',I10,
     &        /10X,'IR= 6 free for user              # OF REJECT =',I10,
     &        /10X,'IR= 7 free for user              # OF REJECT =',I10,
     &        /10X,'IR= 8 LUND error in PYEXEC       # OF REJECT =',I10)
      call usrend
C   print out event content summary
      CALL PYTABU(12)
      CALL PYTABU(22)
      RETURN
      END
      SUBROUTINE UGTSEC
C
C-----------------------------------------
C
C   Author   :- B.Bloch              Nov 2000
C
C=========================================
C...Commonblocks.
      PARAMETER (L1MST=200, L1PAR=200)
      PARAMETER (L2PAR=500, L2PARF=2000 )
      PARAMETER (LJNPAR=4000)
      REAL*8 PARP,PARI,XSEC,CKIN
C
      COMMON/PYSUBS/MSEL,MSELPD,MSUB(L2PAR),KFIN(2,-40:40),CKIN(L1MST)
      COMMON/PYPARS/MSTP(L1MST),PARP(L1MST),MSTI(L1MST),PARI(L1MST)
      COMMON/PYINT5/NGENPD,NGEN(0:500,3),XSEC(0:500,3)
C
      data big/ 1000000./   !   mb to nb ......
C + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + +
      IDC = 5041
      IVER = 1000*MSTP(181)+MSTP(182)
      NTOT = NGEN(0,1)
      NACC = NGEN(0,3)
      XTOT = XSEC(0,1)*big
      RTOT = xtot /sqrt(float(ntot))
      XACC = XSEC(0,3)*big
      RACC = xacc/sqrt(float(nacc))
      is =1
C
      ISEC =  KSECBK(IS,IDC,IVER,NTOT,NACC,XTOT,RTOT,XACC,RACC)
      DO 100 I=1,L2PAR
        IF(MSUB(I).NE.1) GOTO 100
        IS = IS + 1
        NTOT = NGEN(i,1)
        NACC = NGEN(i,3)
        XTOT = XSEC(i,1)*big
        RTOT = xtot /sqrt(float(ntot))
        XACC = XSEC(i,3)*big
        RACC = xacc/sqrt(float(nacc))
        ISEC =  KSECBK(IS,IDC,I,NGEN(I,1),NGEN(I,3),XTOT,RTOT,XACC,RACC)
  100 CONTINUE
      CALL PRTABL('KSEC',0)
  999 RETURN
      END
      SUBROUTINE PYTCLR
C ------------------------------------------------------------
C -  B. Bloch  - January 1998
C
C  store the history of w decays in a usable format for the interface
C
C...Double precision and integer declarations.
      IMPLICIT DOUBLE PRECISION(A-H, O-Z)
      INTEGER PYK,PYCHGE,PYCOMP
C...Commonblocks.
      PARAMETER (L1MST=200, L1PAR=200)
      PARAMETER (L2PAR=500, L2PARF=2000 )
      PARAMETER (LJNPAR=4000)

      COMMON/PYJETS/N7LU,NPAD,K7LU(LJNPAR,5),P7LU(LJNPAR,5),
     $              V7LU(LJNPAR,5)
      COMMON/PYDAT1/MSTU(L1MST),PARU(L1PAR),MSTJ(L1MST),PARJ(L1PAR)
      COMMON/PYDAT2/KCHG(L2PAR,4),PMAS(L2PAR,4),PARF(L2PARF),VCKM(4,4)
      COMMON /PYDAT3/ MDCY(L2PAR,3),MDME(LJNPAR,2),BRAT(LJNPAR),
     &                KFDP(LJNPAR,5)
      COMMON/PYDAT4/CHAF(L2PAR,2)
      CHARACTER CHAF*16
C
      COMMON/PYSUBS/MSEL,MSELPD,MSUB(L2PAR),KFIN(2,-40:40),CKIN(L1MST)
      COMMON/PYPARS/MSTP(L1MST),PARP(L1MST),MSTI(L1MST),PARI(L1MST)
      COMMON/PYINT1/MINT(400),VINT(400)
      COMMON/PYINT2/ISET(500),KFPR(500,2),COEF(500,20),ICOL(40,4,2)
      COMMON/PYINT3/XSFX(2,-40:40),ISIG(1000,3),SIGH(1000)
      COMMON/PYINT4/MWID(500),WIDS(500,5)
      COMMON/PYINT5/NGENPD,NGEN(0:500,3),XSEC(0:500,3)
      COMMON/PYINT6/PROC(0:500)
      CHARACTER PROC*28
C
      INEW = 0
      DO 100 ILU = 5,N7LU
         KF = ABS(K7LU(ILU,2))
         KS = K7LU(ILU,1)
         KM = K7LU(ILU,3)
         K1 = K7LU(ILU,4)
         K2 = K7LU(ILU,5)
C incoming beams keep the last copy
         IF ( KS.EQ.21 .AND. KF.EQ.11 .AND. KM.LT.7) THEN
           INEW = INEW+1
           K7LU(INEW,1) = K7LU(ILU,1)
           K7LU(INEW,2) = K7LU(ILU,2)
           K7LU(INEW,3) = 0
           K7LU(INEW,4) = 0
           K7LU(INEW,5) = 0
C Other documenation label them as 15
         ELSE IF ( KS.EQ.21) THEN
           INEW = INEW+1
           K7LU(INEW,1) = 15
           K7LU(INEW,2) = K7LU(ILU,2)
           K7LU(INEW,3) = 0
           K7LU(INEW,4) = 0
           K7LU(INEW,5) = 0
           if ( KM .ge.4) K7LU(INEW,3) = KM-4
           if ( K1 .ge.4) K7LU(INEW,4) = K1-4
           if ( K2 .ge.4) K7LU(INEW,5) = K2-4
C relevant lines
         ELSE
           INEW = INEW +1
           K7LU(INEW,1) = K7LU(ILU,1)
           K7LU(INEW,2) = K7LU(ILU,2)
           K7LU(INEW,3) = K7LU(ILU,3)
           K7LU(INEW,4) = 0
           K7LU(INEW,5) = 0
           if ( KM .ge.4) K7LU(INEW,3) = KM-4
           if ( K1 .ge.4) K7LU(INEW,4) = K1-4
           if ( K2 .ge.4) K7LU(INEW,5) = K2-4
         ENDIF
         DO 10 I=1,5
           P7LU(INEW,I) = P7LU(ILU,I)
   10    CONTINUE
 100  CONTINUE
      N7LU = INEW
      MSTU(70)=1
      RETURN
      END
      SUBROUTINE GAMGAM
C-------------------------------------------------------------
CAST gamma-gamma events, generate variable energy gamma beams
C
C-------------------------------------------------------------
C*CA pyt6com
C...Double precision and integer declarations.
      IMPLICIT DOUBLE PRECISION(A-H, O-Z)
      INTEGER PYK,PYCHGE,PYCOMP
C...Commonblocks.
      PARAMETER (L1MST=200, L1PAR=200)
      PARAMETER (L2PAR=500, L2PARF=2000 )
      PARAMETER (LJNPAR=4000)

      COMMON/PYJETS/N7LU,NPAD,K7LU(LJNPAR,5),P7LU(LJNPAR,5),
     $              V7LU(LJNPAR,5)
      COMMON/PYDAT1/MSTU(L1MST),PARU(L1PAR),MSTJ(L1MST),PARJ(L1PAR)
      COMMON/PYDAT2/KCHG(L2PAR,4),PMAS(L2PAR,4),PARF(L2PARF),VCKM(4,4)
      COMMON/PYDAT3/MDCY(L2PAR,3),MDME(LJNPAR,2),BRAT(LJNPAR),
     $              KFDP(LJNPAR,5)
      COMMON/PYDAT4/CHAF(L2PAR,2)
      CHARACTER CHAF*16
C
      COMMON/PYSUBS/MSEL,MSELPD,MSUB(L2PAR),KFIN(2,-40:40),CKIN(L1MST)
      COMMON/PYPARS/MSTP(L1MST),PARP(L1MST),MSTI(L1MST),PARI(L1MST)
      COMMON/PYINT1/MINT(400),VINT(400)
      COMMON/PYINT2/ISET(500),KFPR(500,2),COEF(500,20),ICOL(40,4,2)
      COMMON/PYINT3/XSFX(2,-40:40),ISIG(1000,3),SIGH(1000)
      COMMON/PYINT4/MWID(500),WIDS(500,5)
      COMMON/PYINT5/NGENPD,NGEN(0:500,3),XSEC(0:500,3)
      COMMON/PYINT6/PROC(0:500)
      CHARACTER PROC*28
      COMMON/PYINT7/SIGT(0:6,0:6,0:5)
C
      COMMON / GLUPAR / SVERT(3),ECM,EGGMIN,LUMIF,IFL,IFLAG
      REAL*4 LUMIF,eggmin,ecm,svert
C     IFL      : LUND flavour , set to 0 by default, can be changed
C     ECM      : nominal cms energy
C     SVERT    : vertex smearing, set to 0. by default, can be changed
C     EGGMIN   : minimum invariant mass for gamma gamma
C     LUMIF    : luminosity function
C
      COMMON / GLUSTA / ICOULU(10)
C
      REAL PI, TWOPI, PIBY2, PIBY3, PIBY4, PIBY6, PIBY8, PIBY12
      REAL RADEG, DEGRA
      REAL CLGHT
      INTEGER NBITW, NBYTW, LCHAR
      PARAMETER (PI=3.141592653589)
      PARAMETER (RADEG=180./PI, DEGRA=PI/180.)
      PARAMETER (TWOPI = 2.*PI , PIBY2 = PI/2., PIBY4 = PI/4.)
      PARAMETER (PIBY6 = PI/6. , PIBY8 = PI/8.)
      PARAMETER (PIBY12= PI/12., PIBY3 = PI/3.)
      PARAMETER (CLGHT = 29.9792458)
      PARAMETER (NBITW = 32 , NBYTW = NBITW/8 , LCHAR = 4)
C
      REAL*4 elec(5),posi(5),ebeam,wtev,wtmx
      DIMENSION wh(4)
      LOGICAL KEEP
C---------------------------------------------------------------------
      EBEAM = ECM*0.5
      parp(2)=eggmin
C now use routines from Alex Finch for electron/positron scattering
C iflag=1 means apply GVDM form factor
C           iflag=1     ! now stored in common
  1   CONTINUE
      call genlum(iflag,EBEAM,EGGMIN,POSI,ELEC,LUMIF,wtev,wtmx)
      p7lu(1,1)=-elec(1)
      p7lu(1,2)=-elec(2)
      p7lu(1,3)=ebeam-elec(3)
      p7lu(1,4)=0.
      p7lu(1,5)=0.
      pp1=p7lu(1,1)**2+p7lu(1,2)**2+p7lu(1,3)**2
      p7lu(2,1)=-posi(1)
      p7lu(2,2)=-posi(2)
      p7lu(2,3)=-ebeam-posi(3)
      p7lu(2,4)=0.
      p7lu(2,5)=0.
      pp2=p7lu(2,1)**2+p7lu(2,2)**2+p7lu(2,3)**2
C invariant mass of gamma-gamma system
      wh(1) = p7lu(1,1) + p7lu(2,1)
      wh(2) = p7lu(1,2) + p7lu(2,2)
      wh(3) = p7lu(1,3) + p7lu(2,3)
      wh(4) = sqrt(pp1)+sqrt(pp2)
      wh2=wh(4)**2 - wh(1)**2 - wh(2)**2 - wh(3)**2
      if(wh2.gt.0.) wh2=sqrt(wh2)
      call hf1(10022,real(wh2),1.)
C pass to PYTHIA
            PARP(173)=WTEV
            CALL PYEVNT
C           WEIT = WTEV
C...Note that rejection here is IMPORTANT ingredient.
            IF(MSTI(61).ge.1) THEN
              ICOULU(6) = ICOULU(6) + 1
              GO TO 1
            ENDIF
            call hf1(10023,real(wh2),1.)
C documention lines give problems to KXL7AL apart from the beams
            do i=3,n7lu
              if(k7lu(i,1).eq.21) THEN
                 k7lu(i,1) = 15
                 if ( k7lu(i,3).le.2) K7LU(I,3) = 0
              ELSE
                IF ( K7LU(I,3).LE.2) K7LU(I,3)= 0
              ENDIF
            enddo
C...Here one can add scattered electron/positron by hand in positions 1
CC            DO 130 I=N7LU+1,N7LU+2
            do 130 i=1,2
            DO 130 J=1,5
            K7LU(I,J)=0
            P7LU(I,J)=0.
  130       V7LU(I,J)=0.
            K7LU(1,1)=1
            K7LU(2,1)=1
            K7LU(1,2)=11
            K7LU(2,2)=-11
            P7LU(1,3)=ELEC(3)
            P7LU(2,3)=POSI(3)
            P7LU(1,4)=ELEC(4)
            P7LU(2,4)=POSI(4)
            P7LU(1,5) = PYMASS(11)
            P7LU(2,5) = PYMASS(11)
            DO I=1,2
              P7LU(1,i) = ELEC(I)
              P7LU(2,i) = POSI(I)
              costh = P7LU(I,3)/P7LU(I,4)
              theta = acos(costh)*180./pi
              CALL HF1(10001+I,real(P7LU(I,4)),1.)
              CALL HF1(10003+I,real(costh),1.)
              CALL HF1(11003+I,real(theta),1.)
            ENDDO
C            N7LU=N7LU+2
C Tagging selection and minimum number of detectable tracks required
            CALL AMCSEL(KEEP)
            IF(.NOT.KEEP) THEN
              ICOULU(7) = ICOULU(7) + 1
              ISTA = 9
              RETURN
            ENDIF
C   Get event class generated
            IFL1 = MSTI(9)
            call hf1(10006,float(ifl1),1.)

      RETURN
      END
      SUBROUTINE GAMFIL
C----------------------------------------
C     fill gammma gamma histos
C------------------------------------------
C*CA pyt6com
C...Double precision and integer declarations.
      IMPLICIT DOUBLE PRECISION(A-H, O-Z)
      INTEGER PYK,PYCHGE,PYCOMP
C...Commonblocks.
      PARAMETER (L1MST=200, L1PAR=200)
      PARAMETER (L2PAR=500, L2PARF=2000 )
      PARAMETER (LJNPAR=4000)

      COMMON/PYJETS/N7LU,NPAD,K7LU(LJNPAR,5),P7LU(LJNPAR,5),
     $              V7LU(LJNPAR,5)
      COMMON/PYDAT1/MSTU(L1MST),PARU(L1PAR),MSTJ(L1MST),PARJ(L1PAR)
      COMMON/PYDAT2/KCHG(L2PAR,4),PMAS(L2PAR,4),PARF(L2PARF),VCKM(4,4)
      COMMON/PYDAT3/MDCY(L2PAR,3),MDME(LJNPAR,2),BRAT(LJNPAR),
     $              KFDP(LJNPAR,5)
      COMMON/PYDAT4/CHAF(L2PAR,2)
      CHARACTER CHAF*16
C
      COMMON/PYSUBS/MSEL,MSELPD,MSUB(L2PAR),KFIN(2,-40:40),CKIN(L1MST)
      COMMON/PYPARS/MSTP(L1MST),PARP(L1MST),MSTI(L1MST),PARI(L1MST)
      COMMON/PYINT1/MINT(400),VINT(400)
      COMMON/PYINT2/ISET(500),KFPR(500,2),COEF(500,20),ICOL(40,4,2)
      COMMON/PYINT3/XSFX(2,-40:40),ISIG(1000,3),SIGH(1000)
      COMMON/PYINT4/MWID(500),WIDS(500,5)
      COMMON/PYINT5/NGENPD,NGEN(0:500,3),XSEC(0:500,3)
      COMMON/PYINT6/PROC(0:500)
      CHARACTER PROC*28
      COMMON/PYINT7/SIGT(0:6,0:6,0:5)
C
      COMMON / GLUPAR / SVERT(3),ECM,EGGMIN,LUMIF,IFL,IFLAG
      REAL*4 LUMIF,eggmin,ecm,svert
C     IFL      : LUND flavour , set to 0 by default, can be changed
C     ECM      : nominal cms energy
C     SVERT    : vertex smearing, set to 0. by default, can be changed
C     EGGMIN   : minimum invariant mass for gamma gamma
C     LUMIF    : luminosity function
C     IFLAG    : if on , apply VDM form factor at generation
C*CA bcs
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
      REAL*4 wh(4),wp(4),epart,pttot,wp2
      DATA IFI / 0/
C-------------------------------------------------
        IFI  =  IFI + 1
        IFL1 = MSTI(9)

        CALL HFILL(10001,FLOAT(N7LU),0.,1.)
        IDPR = IDPR+10000*IFL+1000000*IFL1
        IF (IFI.LE.5) then
          WRITE(iw(6),*) 'Event type = ',IFL1
        endif
        call vzero(wh,4)
        epart=0.
        pttot = 0.
        call vzero(wp,4)
        do i=1,n7lu
          kk = pyk(i,9)
          ITYP=ABS(pyk(I,9))
          if(kk.eq.0) then
C hadrons
            if((k7lu(i,2)).ne.11) then
              wp(1) = wp(1) + p7lu(i,1)
              wp(2) = wp(2) + p7lu(i,2)
              wp(3) = wp(3) + p7lu(i,3)
              wp(4) = wp(4) + p7lu(i,4)
            endif
          endif
        enddo
        wp2=wp(4)**2 - wp(1)**2 - wp(2)**2 - wp(3)**2
        if(wp2.gt.0.) wp2=sqrt(wp2)
        pttot = sqrt(wp(1)**2 + wp(2)**2)
        call hf1(10025,real(wp2),1.)
        call hf1(10026,real(pttot),1.)
      RETURN
      END
      subroutine gamini
C-----------------------------------------
C   init gamma gamma interaction process
CAST gamma-gamma from Lonnblad's example
C-----------------------------------------
C*CA pyt6com
C...Double precision and integer declarations.
      IMPLICIT DOUBLE PRECISION(A-H, O-Z)
      INTEGER PYK,PYCHGE,PYCOMP
C...Commonblocks.
      PARAMETER (L1MST=200, L1PAR=200)
      PARAMETER (L2PAR=500, L2PARF=2000 )
      PARAMETER (LJNPAR=4000)

      COMMON/PYJETS/N7LU,NPAD,K7LU(LJNPAR,5),P7LU(LJNPAR,5),
     $              V7LU(LJNPAR,5)
      COMMON/PYDAT1/MSTU(L1MST),PARU(L1PAR),MSTJ(L1MST),PARJ(L1PAR)
      COMMON/PYDAT2/KCHG(L2PAR,4),PMAS(L2PAR,4),PARF(L2PARF),VCKM(4,4)
      COMMON/PYDAT3/MDCY(L2PAR,3),MDME(LJNPAR,2),BRAT(LJNPAR),
     $              KFDP(LJNPAR,5)
      COMMON/PYDAT4/CHAF(L2PAR,2)
      CHARACTER CHAF*16
C
      COMMON/PYSUBS/MSEL,MSELPD,MSUB(L2PAR),KFIN(2,-40:40),CKIN(L1MST)
      COMMON/PYPARS/MSTP(L1MST),PARP(L1MST),MSTI(L1MST),PARI(L1MST)
      COMMON/PYINT1/MINT(400),VINT(400)
      COMMON/PYINT2/ISET(500),KFPR(500,2),COEF(500,20),ICOL(40,4,2)
      COMMON/PYINT3/XSFX(2,-40:40),ISIG(1000,3),SIGH(1000)
      COMMON/PYINT4/MWID(500),WIDS(500,5)
      COMMON/PYINT5/NGENPD,NGEN(0:500,3),XSEC(0:500,3)
      COMMON/PYINT6/PROC(0:500)
      CHARACTER PROC*28
      COMMON/PYINT7/SIGT(0:6,0:6,0:5)
C
C*CA bcs
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
      COMMON / GLUPAR / SVERT(3),ECM,EGGMIN,LUMIF,IFL,IFLAG
      REAL*4 LUMIF,eggmin,ecm,svert
C     IFL      : LUND flavour , set to 0 by default, can be changed
C     ECM      : nominal cms energy
C     SVERT    : vertex smearing, set to 0. by default, can be changed
C     EGGMIN   : minimum invariant mass for gamma gamma
C     LUMIF    : luminosity function
C     IFLAG    : if on , apply VDM form factor at generation

      REAL*4 ebeam,wtev,wtmx
      REAL*4 elec(5),posi(5)
CAST gamma-gamma generation, variable energy gamma beams
C stop various gamma decays , 144-149 d,u,s,c,b,t ; 150-155 leptons
        do i=144,155
          mdme(i,1)=1
          if(i.gt.148) mdme(i,1)=0
        enddo
        iggmd = NLINK('GGMD',0)
        if(iggmd.gt.0) then
          nggmd = iw(iggmd)
          if(nggmd.eq.12) then
            do i=1,12
              mdme(i+143,1) = iw(iggmd+i)
            enddo
          else
            write(iw(6),*) 'ASKUSI - GGMD NOT 12 parameters',nggmd
          endif
        endif
C...Give maximum weight of photon spectrum.
        MSTP(173)=1
C... decide if VDM from factor to be used
        iflag=1
        NVDM = NAMIND('GFVD')
        JVDM = IW(NVDM)
        if ( JVDM.ne.0) then
          iflag = iw(JVDM+1)
        endif
        ebeam=0.5*ecm
        call genlum(iflag,EBEAM,EGGMIN,POSI,ELEC,LUMIF,wtev,wtmx)
        PARP(174)=WTMX
C...Initialize.
        DO 100 I=1,2
        DO 100 J=1,5
  100   P7LU(I,J)=0.
        P7LU(1,3)=ebeam
        P7LU(2,3)=-ebeam

        wcm = ecm
        CALL PYINIT('user','gamma','gamma',WCM)
        WRITE(iw(6),1008) EGGMIN,WTMX
 1008   FORMAT(/1X,'Minimum invariant mass for the hadronic system',
     &   F10.3 /1X,'Maximum weight for this system                ',
     &   E10.3 )
         CALL HBOOK1(11004,'THETA OF OUTGOING PARTICLE',60,0.,60.,0.)
         CALL HIDOPT(11004,'LOGY')
         CALL HBOOK1(11005,'THETA OF ANTI-PARTICLE',60,120.,180.,0.)
         CALL HIDOPT(11005,'LOGY')

         CALL HBOOK1(10022,' GAMMAS RAW: W',50,0.,50.,0.)
         CALL HBOOK1(10023,' GAMMAS CUT: W',50,0.,50.,0.)
         CALL HBOOK1(10025,'STABLE PART.: W',50,0.,50.,0.)
         CALL HBOOK1(10026,'STABLE PART.: Pt total',50,0.,5.,0.)

      RETURN
      END
      SUBROUTINE GAMEND
C---------------------------------------
C    gamma gamma end routine
C---------------------------------------
C...Double precision and integer declarations.
      IMPLICIT DOUBLE PRECISION(A-H, O-Z)
      INTEGER PYK,PYCHGE,PYCOMP
C...Commonblocks.
      PARAMETER (L1MST=200, L1PAR=200)
      PARAMETER (L2PAR=500, L2PARF=2000 )
      PARAMETER (LJNPAR=4000)

      COMMON/PYJETS/N7LU,NPAD,K7LU(LJNPAR,5),P7LU(LJNPAR,5),
     $              V7LU(LJNPAR,5)
      COMMON/PYDAT1/MSTU(L1MST),PARU(L1PAR),MSTJ(L1MST),PARJ(L1PAR)
      COMMON/PYDAT2/KCHG(L2PAR,4),PMAS(L2PAR,4),PARF(L2PARF),VCKM(4,4)
      COMMON/PYDAT3/MDCY(L2PAR,3),MDME(LJNPAR,2),BRAT(LJNPAR),
     $              KFDP(LJNPAR,5)
      COMMON/PYDAT4/CHAF(L2PAR,2)
      CHARACTER CHAF*16
C
      COMMON/PYSUBS/MSEL,MSELPD,MSUB(L2PAR),KFIN(2,-40:40),CKIN(L1MST)
      COMMON/PYPARS/MSTP(L1MST),PARP(L1MST),MSTI(L1MST),PARI(L1MST)
      COMMON/PYINT1/MINT(400),VINT(400)
      COMMON/PYINT2/ISET(500),KFPR(500,2),COEF(500,20),ICOL(40,4,2)
      COMMON/PYINT3/XSFX(2,-40:40),ISIG(1000,3),SIGH(1000)
      COMMON/PYINT4/MWID(500),WIDS(500,5)
      COMMON/PYINT5/NGENPD,NGEN(0:500,3),XSEC(0:500,3)
      COMMON/PYINT6/PROC(0:500)
      CHARACTER PROC*28
      COMMON/PYINT7/SIGT(0:6,0:6,0:5)
C
      COMMON / GLUPAR / SVERT(3),ECM,EGGMIN,LUMIF,IFL,IFLAG
      REAL*4 LUMIF,ecm,svert,eggmin
C     IFL      : LUND flavour , set to 0 by default, can be changed
C     ECM      : nominal cms energy
C     SVERT    : vertex smearing, set to 0. by default, can be changed
C     EGGMIN   :minimum invariant mass for gamma gamma
C     LUMIF    :luminosity function
C     IFLAG    : if on , apply VDM form factor at generation

C*CA BCS
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
      REAL*4 XSTOT,XSTOT2
C
C...Now calculate the luminosity function for this process using
C   simple Weizsacker Williams approach
C
        WRITE(iw(6),62)
62      FORMAT(//' Cross Section information for gamma-gamma events')
        XSTOT = sigt(0,0,0)
        XSTOT2 = pari(1)
        WRITE(iw(6),60)ECM,EGGMIN,LUMIF
60      FORMAT(/' Luminosity function for ECM = ',F8.3,
     1          ' and Wmin = ',F8.3,' = ',F8.3)
        WRITE(iw(6),61)XSTOT2,XSTOT2*LUMIF
61      FORMAT(/' Total gamma gamma cross section = ',E10.2,
     1   'mb.  so total e+e- cross section = ',E10.2,' mb. ')
      RETURN
      END
C*DK AMCSEL
      SUBROUTINE AMCSEL(KEEP)
*-----------------------------------------------------------------------
*  AMCSEL         Demand a minimum tag energy and two particle in the
*                 the detector (angle greater than 20 mr). Single tag.
*  Author:        M H Lehto
*  Version:       1.00
*  Lastmod:       18-02-93
*  Modification Log:
*
*-----------------------------------------------------------------------
      IMPLICIT NONE
C*CA BCS
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
C*CC BCS
*
      INTEGER JPART,JJ,NTAG,NTRK,ITKCUT,KF,KOR
      REAL FDCUT(3),TKCUT,ABSP,ABSE,COSTHETA,THETA
      LOGICAL TAG,LTAG,LTRK,KEEP,FIRST
*
      INTEGER INTS,NAMIND
      EXTERNAL NAMIND
      INTEGER N,K,V,N7lu,Npad,K7lu,ljnpar
      PARAMETER (LJNPAR=4000)
      DOUBLE PRECISION P7LU,V7LU
      COMMON/PYJETS/N7LU,NPAD,K7LU(LJNPAR,5),P7LU(LJNPAR,5),
     $              V7LU(LJNPAR,5)
      DATA FIRST/.TRUE./
*
      IF(FIRST) THEN
        tag = .false.
        itkcut = 0
        fdcut(3) = 0.
        INTS=IW(NAMIND('GCUT'))
        IF (INTS.NE.0) THEN
           TAG = IW(INTS+1).NE.0
           FDCUT(1) = RW(INTS+2)
           FDCUT(2) = RW(INTS+3)
        ENDIF
        INTS=IW(NAMIND('ETAG'))
        IF (INTS.NE.0) FDCUT(3) = RW(INTS+1)
        IF(TAG) WRITE(iw(6),6000) FDCUT
 6000   FORMAT(' Amcsel: Tag between',2f10.3,' radians, energy >',f10.3)
*
        INTS=IW(NAMIND('TKCU'))
        IF (INTS.NE.0) THEN
           ITKCUT = IW(INTS+1)
           TKCUT = RW(INTS+2)
        ENDIF
        write(iw(6),*) 'Amcsel: No. of good tracks',itkcut
        FIRST = .FALSE.
      ENDIF
      KEEP = .FALSE.
      LTAG = .FALSE.
      LTRK = .FALSE.
      NTRK = 0
      NTAG = 0
*
      DO 10 JJ=1,N7lu
         JPART=ABS(K7lu(JJ,2))
         KF=K7lu(JJ,1)
         KOR=K7lu(JJ,3)
         IF(JPART.EQ.8.OR.JPART.EQ.10.OR.JPART.EQ.12) GOTO 10  !neutrino
         IF (KF .NE. 1) GOTO 10 ! Not final state
         ABSP=SQRT(P7lu(JJ,1)*P7lu(JJ,1)+P7lu(JJ,2)*P7lu(JJ,2)+
     +             P7lu(JJ,3)*P7lu(JJ,3))
         ABSE=P7lu(JJ,4)
         COSTHETA=P7lu(JJ,3)/ABSP
         THETA=ACOS(ABS(COSTHETA))
         IF(JJ.le.2  ) THEN
            IF (TAG) THEN
               IF ((THETA.GT.FDCUT(1)).AND.
     +            (THETA.LT.FDCUT(2)).AND.(ABSE.GT.FDCUT(3))) THEN
                  LTAG = .TRUE.
                  NTAG=NTAG+1
               ENDIF
            ELSE
               LTAG = .TRUE.
               IF(THETA.GT.TKCUT) NTRK=NTRK+1
            ENDIF
         ELSE
            IF(THETA.GT.TKCUT) NTRK=NTRK+1
         ENDIF
 10   CONTINUE
*
      IF (NTRK.GE.ITKCUT) LTRK = .TRUE.
*
      IF (LTRK .AND. LTAG) KEEP = .TRUE.
      RETURN
      END
C*DK GENLUM
      subroutine genLUM(iflag,EBEAM,WMIN,elec,posi,TOTAL,TEST,FMAX)
C
c control program for FUNGG
c
      REAL ELEC(5),POSI(5)
      DIMENSION X(10)
      REAL STEP(10)
      LOGICAL FIRST
      DATA FIRST/.TRUE./
      SAVE First
      PARAMETER(NDIM=5)
      PARAMETER(xmin = 0.0)
      PARAMETER(xmax = 1.0)
      PARAMETER(sstart=(xmax-xmin)/14)
C
C
C ON THE FIRST CALL INTEGRATE THE FUNCTION
C AND IN THE PROCESS FIND FMAX
C
      if(first)then
       first=.false.
       fmax   = 0.0
c
c integrate function
c
       total = 0.0
       do i = 1,ndim
         x(i) = 0.0
         STEP(I)=sstart
       enddo
       volume=1.0
       do i = 1,ndim
         volume=volume*step(i)
       enddo
       idim = 1
C       step = (xmax-xmin)/float(nloop)

98     call FUNGG(X,EBEAM,WMIN,FX,ELEC,POSI,qq1,qq2)
       test=fX
       IF(IFLAG.EQ.1)TEST = TEST*FGVDM(QQ1)*FGVDM(QQ2)
       if(test.gt.fmax)then
           fmax =test
       endif
c
c for debug only
c
c       do i = 1,ndim
c           call hfill(i,x(i),0.0,test*volume)
c       enddo
       total = total + test*volume
C
C INCREMENT STEPS THROUGH THE VOLUME
C
99     x(idim) = x(idim) + step(idim)
       if(x(idim).gt.xmax)then
        x(idim)=xmin
        step(idim)=sstart
        if(idim.eq.5)step(idim)=sstart/2.
        idim = idim + 1
        if(idim.gt.ndim)goto 1000
        goto 99
       endif
       idim = 1
       goto 98
1000  continue
c
c      write(6,*)'total cross section = ',total
C
      ENDIF
c
c generate ONE event
c
C lines commented with x should be removed
c when replacing GAGAEN in pythia
Cx        ntrial = 0
Cx1       continue
Cx        ntrial = ntrial + 1
        do j = 1,ndim
           x(j) = rndm(j)
        enddo
        call FUNGG(X,EBEAM,WMIN,FX,ELEC,POSI,QQ1,QQ2)
        test=fX
        IF(IFLAG.EQ.1)TEST = TEST*FGVDM(QQ1)*FGVDM(QQ2)
        if(test.gt.fmax)then
           fmax =test
        endif
Cx        if(rndm(21)*fmax.gt.test)goto 1
c for pythia just return values of test and fmax
c
      RETURN
      end
C*DK FUNGG
      SUBROUTINE FUNGG(Y,EBEAM,WMIN,FX,ELEC,POSI,QQ1,QQ2)
C
C! Calculate the Luminosity Function in gamma gamma event
C
C INPUT  parameters :
C                     Y : random variables
C                EBEAM  : beam energy
C                WMIN   : minimum invariant mass
C
C
C OUTPUT parameters :
C                    NERR : error code 0 = success
C                                      1 = failure
C                    FX   : value of lumi function at these x
C            ELEC,POSI    : array of scattered electron and positron
C                            4-momenta,mass
C                    QQ1,QQ2 : Qsquareds of photons
C CALLS     - MAPVAR
C  A.J.Finch February 1993 adapted to PHOT02 from PHOT01 version
C  A.J.Finch April    1996 cleaned up for stand alone use
C----------------------------------------------------------------

C      THIS PROGRAM CALCULATES DL/DZ OF LUMINOSITY FUNCTION
C      WRITTEN BY S.KAWABATA
C      MODIFIED BY H.WRIEDT     COPIED     12.03.81   19:55
C      MODIFIED BY H.WRIEDT     LAST MOD   14.03.81   16:15
C
       IMPLICIT DOUBLE PRECISION (A-H,O-Z)
       DOUBLE PRECISION ME,ME2,MU,MU2

       REAL*4 ELEC(5),POSI(5)
       REAL*4 QQ1,QQ2,Y(10),DJDX,SIG,EBEAM,ZS4,W,WMIN,FX
c
C            X1    : Y(1)
C            TH1   : Y(2)
C            TH2   : Y(3)
C            PH    : Y(4)
C            W     : Y(5)

C
      LOGICAL FIRST
C
      DATA XMAX / 1./
      DATA FIRST/.TRUE./
      SAVE    FIRST,ALF,CONST,ZMIN,ZMAX,PI,PIDEG,RADDEG,
     1        ME,ME2,TMIN,TMAX,DJ

       IF(FIRST)THEN
          ALF    = 1.0 / 137.04
          PI     = ACOS(-1.0)
          CONST  =  ( ALF**2 )  /  ( 32.0 * PI**3 )
          ZMIN   = WMIN / EBEAM * 0.5
          ZMAX   = 1.0
          PIDEG  = 180
          RADDEG = PIDEG / PI
          ME     = 0.000511
          ME2    = ME*ME
          TMIN  = 1.0E-10
          TMAX   =DBLE( PI)
          DJ    = 2.*PI
          FIRST = .FALSE.
       ENDIF
       X8    =DBLE( y(5))
       CALL MAPVAR(ZS,X8,ZMIN,ZMAX,PROB)
c
      NERR  = 0
      E     = DBLE( EBEAM)
      E2    = E*E
      FME   = ME/E
      FME2  = FME*FME
      FMA   = (1.-FME)*(1.+FME)
      XMAX  = 1.D0-FME
      PB    = (E-ME)*(E+ME)
      PB    = SQRT(PB)
      PB    = E- ME2/(E+PB)
      S     = 4.0 * EBEAM * EBEAM
      RAMD  = S*(S-4.*ME2)
      RAMD  = 1./SQRT(RAMD)
      Z2    = ZS*ZS
      XMIN  = (Z2+0.5*FME+0.5*FME2)/(1.D0-0.5*FME)
C
C
C==========> SAMPLE X1
C FOR CONSISTENCY WITH EEMUMU USE ALL DOUBLE PRECISION ARGUMENTS
C ( YTEMP - DOUBLE PRECISION, Y - REAL*4)
      YTEMP =DBLE( Y(1))
      CALL MAPX1(X1,YTEMP,XMIN,XMAX,DX1)
C==========> SAMPLE THETA 1
      YTEMP =DBLE( Y(2))
      CALL MAPX1(TH1,YTEMP,TMIN,TMAX,DT1)
      CT1   = COS(TH1)
      ST1   = SIN(TH1)
      DT1   = DT1*ST1
C++++++++++++++++++++++++++++++++
C==========> SAMPLE THETA 2
      YTEMP =DBLE( Y(3))
      CALL MAPX1(TH2,YTEMP,TMIN,TMAX,DT2)
      CT2   = COS(TH2)
      ST2   = SIN(TH2)
      DT2   = DT2*ST2
C++++++++++++++++++++++++++++++++
C==========> SAMPLE PHI
      PH    = 2.*PI*DBLE(Y(4))
      CPH   = COS(PH)
C==========> DEFINE X2
      CT    = ST1*ST2*CPH-CT1*CT2
      alimit = 1 - 1e-10
      IF(ABS(CT).GT.alimit) GO TO 1000
      CTSQ  = CT*CT
      X1MM  = (1.-X1)
      X1MP  = (1.+X1)
      FAC1  = (X1MM+FME)*(X1MM-FME)
      FAC2  = 1.-X1+2.*Z2-FME2
      A     = FAC1*CTSQ - X1MP*X1MP
      B     = FAC1*CTSQ - X1MP*FAC2
      C     = FMA*FAC1*CTSQ - FAC2*FAC2
      D     = B*B - A*C
C-----------------------------------------
      IF(D.LT.0.) GO TO 1000
      PXX   = (1.-X1)**2-FME2
      IF(PXX.LT.0.) GO TO 1000
      PX1   = SQRT(PXX)*CT
      PY1   = X1-1.-2.*Z2+FME2
      SD    = SQRT(D)
      X2    = (B + SD)/A
      IF(X2.LT.XMIN.OR.X2.GT.XMAX) GO TO 500
      PXX   = (1.-X2)**2-FME2
      IF(PXX.LT.0.) GO TO 1000
      PXT   = SQRT(PXX)*PX1
      PYT   = X2+X1*X2+PY1
      IF(PXT*PYT.GE.0.) GO TO 600
  500 X2    = (B - SD)/A
      PXX   = (1.-X2)**2-FME2
      IF(PXX.LT.0.) GO TO 1000
      PXT   = SQRT(PXX)*PX1
      PYT   = X2+X1*X2+PY1
      IF(PXT*PYT.LT.0.) GO TO 1000
  600 CONTINUE
C------------------------------
      E3    = E-E*X1
      P3    = (E3-ME)*(E3+ME)
      IF(P3.LT.0.) GO TO 1000
      P3    = SQRT(P3)
      P3    = E3- ME2/(E3+P3)
      CT3   = CT1
      ST3   = ST1
      CP3   = 1.
      SP3   = 0.
      E5    = E-E*X2
      P5    = (E5-ME)*(E5+ME)
      IF(P5.LT.0.) GO TO 1000
      P5    = SQRT(P5)
      P5    = E5- ME2/(E5+P5)
      CT5   = -CT2
      ST5   = ST2
      CP5   = CPH
      SP5   = SIN(PH)
C-----------------------
      EW    = 2.*E-E3-E5
      W2    = 4.*E2*Z2
      PW    = EW*EW-W2
      IF(PW.LT.0.) GO TO 1000
      PW    = SQRT(PW)
      PW    = EW-W2/(EW+PW)
      W     = SQRT(W2)
      PWX   = -(P3*ST3*CP3+P5*ST5*CP5)
      PWY   = -(P3*ST3*SP3+P5*ST5*SP5)
      PWZ   = -(P3*CT3+P5*CT5)
      CTW   = PWZ/PW
      IF(ABS(CTW).GT.alimit) GO TO 1000
      STW   = SQRT((1.-CTW)*(1.+CTW))
      PWXY  = PW*STW
      IF(PWXY.NE.0.) GO TO 700
      CPW   = 1.D0
      SPW   = 0.D0
      GO TO 750
  700 CPW   = PWX/PWXY
      SPW   = PWY/PWXY
C-----------------------
  750 Q12   = -2.*E*E3+2.*PB*P3*CT3
      Q12   = Q12+2.*ME2
      QQ1 = -Q12
      IF(Q12.GE.0.) GO TO 1000
      Q22   = -2.*E*E5-2.*PB*P5*CT5
      Q22   = Q22+2.*ME2
      QQ2 = -1.0*sngl(Q22)
      IF(Q22.GE.0.) GO TO 1000
      Q12 = -0.25*Q12/E2
      Q22 = -0.25*Q22/E2
C======================================================================
      XK = Z2 + Q12 + Q22
      CH12 = XK*XK - 4.*Q12*Q22
  101 CH = SQRT(CH12)
      XMEQ1 = ME2/(E2*Q12)
      XMEQ2 = ME2/(E2*Q22)
      C1 = 1. - XMEQ1
      C2 = 1. - XMEQ2
      FR1 = XK - 2.*(X2 + Q22)
      FR2 = XK - 2.*(X1 + Q12)
      FR11 = FR1*FR1
      FR22 = FR2*FR2
      BRA1 = FR11/CH12 + C1
      BRA2 = FR22/CH12 + C2
      COT1   = P3*DT1/Q12
      COT2   = P5*DT2/Q22
      X2MM  = 1.-X2
      FAC   = SQRT(FAC1/((X2MM-FME)*(X2MM+FME)))
      FAC   = X1MP+X2MM*FAC*CT
      FACT  = 4.*ZS*RAMD/FAC
      FL1 = CH*COT1*BRA1
      FL2 = FACT*COT2*BRA2
      SIG = FL1*FL2
C======================================================================
      IF(SIG.LE.0.) GO TO 1000
      DJDX  = DX1*DJ
C
C--- scattered electron/positron
C--- decide on phi for electrons
C
c       PHI = PI*( 1. - 2.*RNDM( 0 ) )
       SPH = SIN( PH )
       CPH = COS( PH )
C
       R3   = P3
       PX   = R3*ST3*CP3
       PY   = R3*ST3*SP3
       POSI( 1 ) = PX*CPH - PY*SPH
       POSI( 2 ) = PX*SPH + PY*CPH
       POSI( 3 ) = R3*CT3
       POSI( 4 ) = E3
       POSI( 5 ) = ME
       R5   = P5
       PX   = R5*ST5*CP5
       PY   = R5*ST5*SP5
       ELEC( 1 ) = PX*CPH - PY*SPH
       ELEC( 2 ) = PX*SPH + PY*CPH
       ELEC( 3 ) = R5*CT5
       ELEC( 4 ) = E5
       ELEC( 5 ) = ME
       FX = DJDX * CONST * PROB * SIG
       RETURN
 1000 NERR  = 1
      FX = 0.0
      RETURN
      END
C*DK FGVDM
      REAL FUNCTION FGVDM(QQ)
C---------------------------------------------------------------
C! Return the GVDM form factor (PHOT02)
C  <purpose>
C
C INPUT  parameters :
C                      QQ : Q squared of photon
C OUTPUT parameters :
C                   FGVDM : Value of form factor
C---------------------------------------------------------------
       LOGICAL FIRST,LKEEP
       DATA    FIRST/.TRUE./
       SAVE    FIRST
C
C---  CALCULATE THE GVDM-FF ACCORDING TO GINZBURG & SERBO,
C     PHYS. LETT. 109B(1982), NO.3, P.231FF, EQ.(2)
C     H.WRIEDT    25.11.82    11:45
C     LAST MOD    25.11.82    11:45
C
      DIMENSION R(3),XMQ(3)
      DATA R/0.65,0.08,0.05/,XMQ/0.591,0.612,1.04/
C
      FGVDM = 1.
      IF (QQ.EQ.0.) RETURN
      SUM = 0.
        DO 10 I = 1,3
        F = QQ/XMQ(I)
        T = R(I)*(1.+0.25*F)/((1.+F)*(1.+F))
   10   SUM = SUM + T
      T0 = 0.22/(1.+QQ/1.96)
      FGVDM = SUM + T0
      RETURN
      END
C*DK MAPVAR
      SUBROUTINE MAPVAR(T,X,XMIN,XMAX,DX)
C---------------------------------------------------------------
C! MAP routine for integrating an exponential (PHOT02)
C
C INPUT  parameters : X,XMIN,XMAX
C
C OUTPUT parameters : T,DX
C
C CALLED BY - various
C  A.J.Finch February 1993 adapted to PHOT02 from PHOT01 version
C----------------------------------------------------------------
      ENTRY      MAPX1 (T,X,XMIN,XMAX,DX)
      ENTRY      MAPS2 (T,X,XMIN,XMAX,DX)
      ENTRY      MAPW2 (T,X,XMIN,XMAX,DX)
      IMPLICIT DOUBLE PRECISION (A-Z)
      Y     = XMAX/XMIN
      T     = XMIN*Y**X
      DX    = T*DLOG(Y)
      RETURN
      END
C*DK MAPT1
      SUBROUTINE MAPT1(T,X,XMIN,XMAX,DX)
      ENTRY      MAPT2(T,X,XMIN,XMAX,DX)
C---------------------------------------------------------------
C! MAP routine for integrating an exponential (PHOT02)
C
C INPUT  parameters : X,XMIN,XMAX
C
C OUTPUT parameters : T,DX
C
C CALLED BY - INITIA
C  A.J.Finch February 1993 adapted to PHOT02 from PHOT01 version
C----------------------------------------------------------------

      IMPLICIT DOUBLE PRECISION (A-Z)
      Y     = XMAX/XMIN
      T     = XMIN*Y**X
      DX    = -T*DLOG(Y)
      RETURN
      END

