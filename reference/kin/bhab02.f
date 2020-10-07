cFrom BLOCH@alws.cern.ch Fri Feb 13 15:23:25 2004
cDate: Fri, 13 Feb 2004 15:21:29 +0100
cFrom: BLOCH@alws.cern.ch
cTo: BLOCH@alws.cern.ch

C*HE 01/17/91 17:53:41 C
C*DK ASKUSI
      SUBROUTINE ASKUSI(IGCOD)
C --------------------------------------------------------------------
C G. Bonneaud September 1988.
C --------------------------------------------------------------------
C*CA BCS
      PARAMETER (LBCS=1000,LCHAR=4)
      COMMON/BCS/ IW(LBCS)
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C*CC BCS
      COMMON / DTMILL / SDVRT(3),TABL(14),NEVENT(10),NEVPHO(2)
      COMMON / INPOUT / IOUT
      INTEGER ALTABL,ALRLEP
      EXTERNAL ALTABL ,ALRLEP
      PARAMETER ( IGCO = 2006)
C
C   Return the generator code as defined in the KINGAL library
C
      IGCOD = IGCO
      IOUT = IW(6)
      WRITE(IOUT,101) IGCOD
 101  FORMAT(/,10X,
     &       'BHAB02 - CODE NUMBER =',I4,' Last mod. February,1990',
     & /,10X,'***********************************************',//)
C
C   Input parameters (see description in BHAB02)
C
       EBEAM   =   46.1
       Z0MASS  =   92.0
       TPMASS  =   60.0
       HIMASS  =  100.0
       THMIN   =   10.0
       THMAX   =  170.0
       XKMAX   =    1.0
       POLP    =    0.
       POLM    =    0.
       AS      =    0.12
       INEW    =    1
C
C  The default values can be changed by the DATA CARD GENE
C
       JGENE = NLINK('GENE',0)
       IF(JGENE.NE.0) THEN
        EBEAM  = RW(JGENE+1)
        Z0MASS = RW(JGENE+2)
        TPMASS = RW(JGENE+3)
        HIMASS = RW(JGENE+4)
        THMIN  = RW(JGENE+5)
        THMAX  = RW(JGENE+6)
        XKMAX  = RW(JGENE+7)
        POLP   = RW(JGENE+8)
        POLM   = RW(JGENE+9)
        AS     = RW(JGENE+10)
        INEW   = IW(JGENE+11)
       ENDIF
       TABL(1) = EBEAM
       TABL(2) = Z0MASS
       TABL(3) = TPMASS
       TABL(4) = HIMASS
       TABL(5) = THMIN
       TABL(6) = THMAX
       TABL(7) = XKMAX
       TABL(8) = POLP
       TABL(9) = POLM
       TABL(10) = AS
       TABL(11) = INEW
C
C  Main vertex generation
C
       SDVRT(1) = 0.035
       SDVRT(2) = 0.0012
       SDVRT(3) = 1.28
       JSVRT = NLINK('SVRT',0)
       IF(JSVRT.NE.0) THEN
        SDVRT(1) = RW(JSVRT+1)
        SDVRT(2) = RW(JSVRT+2)
        SDVRT(3) = RW(JSVRT+3)
       ENDIF
       TABL(12) = SDVRT(1)
       TABL(13) = SDVRT(2)
       TABL(14) = SDVRT(3)
C
C  Fill the KPAR bank with the generator parameters
C
       NCOL = 14
       NROW = 1
       JKPAR = ALTABL('KPAR',NCOL,NROW,TABL,'2I,(F)','C')
C  Fill RLEP bank
       EB = EBEAM
       IEBEAM = NINT(EB *1000  )
       JRLEP = ALRLEP(IEBEAM,'    ',0,0,0)
C
C  Initialize events counters
       DO 10 I = 1,10
   10  NEVENT(I) = 0
       DO 11 I = 1,2
   11  NEVPHO(I) = 0
C
C Booking of some standard histogrammes
C
       CALL HBOOK1(10001,'Energy distribution : final e+$',
     &                                            30,0.,60.,0.)
       CALL HIDOPT(10001,'LOGY')
       CALL HBOOK1(10002,'Energy distribution : final e-$',
     &                                            30,0.,60.,0.)
       CALL HIDOPT(10002,'LOGY')
       CALL HBOOK1(10003,'Energy distribution : gamma$',30,0.,60.,0.)
       CALL HIDOPT(10003,'LOGY')
       CALL HBOOK1(10004,'Energy distribution : gamma < 1. GeV$',
     &                                                     40,0.,1.,0.)
       CALL HIDOPT(10004,'LOGY')
       CALL HBOOK1(10005,'Polar angle : final e+ (Degrees)$',
     &                                                   40,0.,180.,0.)
       CALL HIDOPT(10005,'LOGY')
       CALL HBOOK1(10006,'Polar angle : final e- (Degrees)$',
     &                                                   40,0.,180.,0.)
       CALL HIDOPT(10006,'LOGY')
       CALL HBOOK1(10007,'Weight distribution for hard events$',
     &                                                     40,0.,2.,0.)
       CALL HBOOK2(10008,'Hard events : weight distribution    versus
     &photon energy$',30,0.,60.,40,0.,2.,0.)
C
C  Generator initialization
C
      LENTRY = 1
      CALL BHAB02(LENTRY)
C
C  Print PART and KLIN banks
C
      CALL PRPART
      CALL PRTABL('KPAR',0)
      CALL PRTABL('RLEP',0)
C
      RETURN
      END
C*DK ASKUSE
      SUBROUTINE ASKUSE (IDPR,ISTA,NTRK,NVRT,ECMS,WEIT)
C --------------------------------------------------------------------
C G. Bonneaud September 1988.
C --------------------------------------------------------------------
C*CA BCS
      PARAMETER (LBCS=1000,LCHAR=4)
      COMMON/BCS/ IW(LBCS)
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C*CC BCS
      COMMON /KGCOMM/ IST,NTR,IDP,ECM,WEI
      COMMON / DTMILL / SDVRT(3),TABL(14),NEVENT(10),NEVPHO(2)
      COMMON / QUADRI / PP(4),PM(4),QP(4),QM(4),QK(4)
      REAL*8 PP,PM,QP,QM,QK
      DIMENSION VRTEX(4),TABK(4),ITAB(3)
      INTEGER ALTABL
      EXTERNAL ALTABL
C
C  Generate primary vertex
C
      CALL RANNOR (RN1,RN2)
      CALL RANNOR (RN3,DUM)
      VRTEX(1) = RN1*SDVRT(1)
      VRTEX(2) = RN2*SDVRT(2)
      VRTEX(3) = RN3*SDVRT(3)
      VRTEX(4) = 0.
C
C  Fill 'VERT' bank
C
      IVMAI = 1
      JVERT = KBVERT(IVMAI,VRTEX,0)
      IF(JVERT.EQ.0) THEN
       ISTA = 1
       NEVENT(2) = NEVENT(2) + 1
       GO TO 97
      ENDIF
C
C  Event generation
C
      LENTRY = 2
      NEVENT(1) = NEVENT(1) + 1
      CALL BHAB02(LENTRY)
      NVRT = 1
      ISTA = IST
      IDPR = IDP
      ECMS = ECM
      WEIT = WEI
C
C  book 'KINE' for beam electrons (-1 and -2)
C
      TABK(1) = 0.
      TABK(2) = 0.
      TABK(3) = -PP(3)
      TABK(4) = 0.
      JKINE = KBKINE(-1,TABK,2,0)
      IF(JKINE.EQ.0) THEN
       ISTA = 2
       NEVENT(3) = NEVENT(3) + 1
       GO TO 97
      ENDIF
      TABK(3) = -PM(3)
      TABK(4) = 0.
      JKINE = KBKINE(-2,TABK,3,0)
      IF(JKINE.EQ.0) THEN
       ISTA = 3
       NEVENT(4) = NEVENT(4) + 1
       GO TO 97
      ENDIF
C  book 'KINE' for final state particles
      DO 92 I = 1,3
   92  TABK(I) = ((-1.)**I)*QP(I)
      TABK(4) = 0.
      JKINE = KBKINE(1,TABK,2,IVMAI)
      IF(JKINE.EQ.0) THEN
       ISTA = 4
       NEVENT(5) = NEVENT(5) + 1
       GO TO 97
      ENDIF
      DO 93 I = 1,3
   93  TABK(I) = ((-1.)**I)*QM(I)
      TABK(4) = 0.
      JKINE = KBKINE(2,TABK,3,IVMAI)
      IF(JKINE.EQ.0) THEN
       ISTA = 5
       NEVENT(6) = NEVENT(6) + 1
       GO TO 97
      ENDIF
C We did not book the radiated photon if the energy is equal to zero
      IF(QK(4).LT.1.E-06) THEN
       NTR = 2
       GO TO 95
      ENDIF
      DO 94 I = 1,4
   94  TABK(I) = ((-1.)**I)*QK(I)
      TABK(4) = 0.
      JKINE = KBKINE(3,TABK,1,IVMAI)
      IF(JKINE.EQ.0) THEN
       ISTA = 6
       NEVENT(7) = NEVENT(7) + 1
       GO TO 97
      ENDIF
C
C  Fill history with 'KHIS' bank
C
   95 DO 96 I = 1,NTR
   96 ITAB(I) = 0
      JKHIS = ALTABL('KHIS',1,NTR,ITAB,'I','E')
      IF(JKHIS.EQ.0) THEN
       ISTA = 7
       NEVENT(8) = NEVENT(8) + 1
      ENDIF
C
   97 IF(ISTA.NE.0) NEVENT(9) = NEVENT(9) + 1
      IF(ISTA.EQ.0) THEN
       NEVENT(10) = NEVENT(10) + 1
       IF(NTR.EQ.2) NEVPHO(1) = NEVPHO(1) +1
       IF(NTR.EQ.3) NEVPHO(2) = NEVPHO(2) +1
       CALL HFILL(10001,QP(4),0.,WEIT)
       CALL HFILL(10002,QM(4),0.,WEIT)
       CALL HFILL(10003,QK(4),0.,WEIT)
       IF(QK(4).LT.1.0D0) CALL HFILL(10004,QK(4),0.,WEIT)
       QPTHET = -QP(3)/SQRT(QP(1)**2+QP(2)**2+QP(3)**2)
       QPTHET = ACOS(QPTHET)*180./3.14159
       CALL HFILL(10005,QPTHET,0.,WEIT)
       QMTHET = -QM(3)/SQRT(QM(1)**2+QM(2)**2+QM(3)**2)
       QMTHET = ACOS(QMTHET)*180./3.14159
       CALL HFILL(10006,QMTHET,0.,WEIT)
       IF(QK(4).NE.0.0D0) THEN
        CALL HFILL(10007,WEIT,0.,1.)
        CALL HFILL(10008,QK(4),WEIT,1.)
       ENDIF
      ENDIF
C
      NTRK = NTR
C
      RETURN
      END
C*DK USCJOB
      SUBROUTINE USCJOB
C --------------------------------------------------------------------
C G. Bonneaud September 1988.
C --------------------------------------------------------------------
      COMMON / DTMILL / SDVRT(3),TABL(14),NEVENT(10),NEVPHO(2)
      COMMON / INPOUT / IOUT
C
      LENTRY = 3
      CALL BHAB02(LENTRY)
C
       WRITE(IOUT,101)
  101  FORMAT(//20X,'EVENTS STATISTICS',
     &         /20X,'*****************')
       WRITE(IOUT,102)NEVENT(1),NEVENT(10),NEVPHO(1),NEVPHO(2),NEVENT(9)
  102  FORMAT(/5X,'# OF GENERATED EVENTS                = ',I10,
     &        /5X,'# OF ACCEPTED  EVENTS                = ',I10,
     &        /5X,'# OF ACCEPTED  EVENTS WITHOUT PHOTON = ',I10,
     &        /5X,'# OF ACCEPTED  EVENTS WITH PHOTON    = ',I10,
     &        /5X,'# OF REJECTED  EVENTS                = ',I10)
       WRITE(IOUT,103)
  103  FORMAT(//20X,'ERRORS STATISTICS',
     &         /20X,'*****************')
       WRITE(IOUT,104)NEVENT(2),NEVENT(3),NEVENT(4),NEVENT(5),NEVENT(6),
     &               NEVENT(7),NEVENT(8)
  104  FORMAT(/10X,'ISTA = 1 BOS ERROR VERT     # OF REJECT = ',I10,
     &        /10X,'ISTA = 2 BOS ERROR KINE e+  # OF REJECT = ',I10,
     &        /10X,'ISTA = 3 BOS ERROR KINE e-  # OF REJECT = ',I10,
     &        /10X,'ISTA = 4 BOS ERROR KINE f+  # OF REJECT = ',I10,
     &        /10X,'ISTA = 5 BOS ERROR KINE f-  # OF REJECT = ',I10,
     &        /10X,'ISTA = 6 BOS ERROR KINE gam # OF REJECT = ',I10,
     &        /10X,'ISTA = 7 BOS ERROR KHIS     # OF REJECT = ',I10)
C
      RETURN
      END
C*DK BHAB02
      SUBROUTINE BHAB02(LENTRY)
C----------------------------------------------------------------------
C!
C!   ORIGINAL PROGRAM WRITTEN BY :
C!
C!        BERENDS, HOLLIK AND KLEISS
C!
C!   MODIFICATIONS BY :
C!
C!        RAMON MIQUEL (BARCELONA) (MIQUEL@EB0UAB51) :
C!
C!        1) LONGITUDINAL POLARIZATION INCLUDED
C!        2) SELF ENERGY CORRECTIONS PUT IN THE DENOMINATORS
C!        3) Z0 WIDTH UP TO ONE LOOP GSW + QCD INCLUDED
C!
C!   IF YOU WANT TO SWITCH OFF THE MODIFICATIONS 2) AND 3), YOU JUST
C!   HAVE TO PUT THE INPUT PARAMETER INEW TO 0 AND YOU WILL OBTAIN THE
C!   SAME RESULT (FOR UNPOLARIZED BEAMS) AS THE ONE FROM BABAMC, THE
C!   ORIGINAL VERSION. NEVERTHELESS, THE RESULTS FROM THIS VERSION ARE
C!   SUPOSED TO BE MORE ACCURATE THAN THE ONES FROM THE ORIGINAL ONE
C!
C!   THE MODIFICATIONS TO EXISTING ROUTINES ARE MARKED WITH THE LINE
CC-RM
C!   FURTHERMORE, IN THE HEADER OF THE ENTERILY NEW ROUTINES IT IS
C!   STATED THE NAME OF THE AUTHOR
C!
C!   VERSION 1.1  2-JUN-1988
C!
C!   INPUTS :
C!
C!       EB : BEAM ENERGY (GEV)
C!      XMZ : Z0 MASS (GEV)
C!      XMT : TOP QUARK MASS (GEV)
C!            WARNING: THE Z0 WIDTH IS COMPUTED WITH THE NEEDED ACCURACY
C!                     ONLY IF  XMZ/2.D0 < XMT < 150 GEV
C!                     (THIS RESTRICTION WILL DISAPPEAR IN FORTHCOMING
C!                     VERSIONS OF THE PROGRAM)
C!      XMH : HIGGS BOSON MASS (GEV)
C!    THMIN : MINIMUM ELECTRON ANGLE (DEGREES)
C!    THMAX : MAXIMUM ELECTRON ANGLE (DEGREES)
C!    XKMAX : MAXIMUM PHOTON ENERGY DIVIDED BY THE BEAM ENERGY
C!      NEV : NUMBER OF EVENTS REQUESTED
C!     POLP : LONGITUDINAL DEGREE OF POLARIZATION (POSITRON)
C!     POLM : LONGITUDINAL DEGREE OF POLARIZATION (ELECTRON)
C!            WARNING: THE RESULT IS NOT COMPLETELY RELIABLE FOR DEGREES
C!                     OF POLARIZATION SUCH THAT POLP*POLM=1
C!       AS : ALPHA STRONG
C!     INEW : 0 ---> ORIGINAL VERSION OF THE PROGRAM
C!          : 1 ---> VERSION WITH R. MIQUEL'S MODIFICATIONS
C!
C!   THE MASSES OF THE FERMIONS ARE ALSO INPUT PARAMETERS AND THEIR
C!   VALUES ARE SPECIFIED BOTH IN FUNCTIONS SETUPS AND PSE0
C!
C!   MORE INFORMATION IN THE HEADER OF ROUTINE SETBAB
C!
C----------------------------------------------------------------------
C G. Bonneaud September 1988.
C----------------------------------------------------------------------
C THIS IS THE MAIN PROGRAM, CONSISTING OF:
C 1) INITIALIZATION OF THE GENERATOR;
C 2) GENERATION OF AN EVENT SAMPLE,
C    AND SUBSEQUENT ANALYSIS OF THE EVENTS;
C 3) EVALUATION OF THE TOTAL GENERATED CROSS SECTION
C
C
C*CA BCS
      PARAMETER (LBCS=1000,LCHAR=4)
      COMMON/BCS/ IW(LBCS)
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C*CC BCS
      REAL*8 EB,XMZ,S2W,XMH,XMT,THMIN,THMAX,XKMAX,POLP,POLM,AS
      REAL*8 PP,PM,QP,QM,QK,W,SIGTOT,ERRTOT
C
      COMMON / INPUT1 / EB
      COMMON / INPUT2 / XMZ,S2W,XMH,XMT
      COMMON / INPUT3 / THMIN,THMAX,XKMAX
CC-RM
      COMMON / POL    / POLP,POLM
      COMMON / QCD    / AS
      COMMON / NEWOLD / INEW
CC-RM
C
      COMMON / KGCOMM / ISTA,NTR,IDPR,ECMS,WEIT
      COMMON / DTMILL / SDVRT(3),TABL(14),NEVENT(10),NEVPHO(2)
      COMMON / QUADRI / PP(4),PM(4),QP(4),QM(4),QK(4)
      COMMON / INPOUT / IOUT
C
C  INITIALIZATION            *********************
C
      IF(LENTRY.EQ.1) THEN
C
C  Parameters initialization
C
       EB       = TABL(1)
       XMZ      = TABL(2)
       XMT      = TABL(3)
       XMH      = TABL(4)
       THMIN    = TABL(5)
       THMAX    = TABL(6)
       XKMAX    = TABL(7)
       POLP     = TABL(8)
       POLM     = TABL(9)
       AS       = TABL(10)
       INEW     = TABL(11)
C
C THE SETUP PHASE: ASK FOR THE INPUT PARAMETERS
C
       IIN=5
       IUT = 6
CC-RM
C GB  READ(33,888) EB,XMZ,XMT,XMH,THMIN,THMAX,XKMAX,NEVENT
C888  FORMAT(//,7D10.4,I8)
C GB  READ(33,458) POLP,POLM
C458  FORMAT(/,2D10.4)
C GB  READ(33,459) AS
C459  FORMAT(/,1D10.4)
C GB  READ(33,759) INEW
C759  FORMAT(/,I10)
       IF (XMT.LE.XMZ/2.D0.OR.XMT.GE.150.D0) THEN
C GB    WRITE(6,*) 'WARNING !! : THE Z0 WIDTH IS COMPUTED WITH THE'
        WRITE(IOUT,*) 'WARNING !! : THE Z0 WIDTH IS COMPUTED WITH THE'
C GB    WRITE(6,*) 'NEEDED ACCURACY ONLY WHEN XMZ/2 < XMT < 150 GEV'
        WRITE(IOUT,*) 'NEEDED ACCURACY ONLY WHEN XMZ/2 < XMT < 150 GEV'
       ENDIF
       IF (POLP*POLM.EQ.1.D0) THEN
C GB    WRITE(6,*) 'WARNING !! : THE RESULT IS NOT COMPLETELY RELIABLE'
      WRITE(IOUT,*) 'WARNING !! : THE RESULT IS NOT COMPLETELY RELIABLE'
C GB    WRITE(6,*) 'WHEN POLP*POLM = 1'
        WRITE(IOUT,*) 'WHEN POLP*POLM = 1'
       ENDIF
CC-RM
C
C THE INITIALIZATION STEP OF THE PROGRAM
C
       CALL SETBAB(EB,XMZ,XMH,XMT,THMIN,THMAX,XKMAX)
C
       CALL OUTCRY('GENBAB')
C
       RETURN
      ENDIF
C
C  EVENT GENERATION          *********************
C
      IF(LENTRY.EQ.2) THEN
C
C  EVENT STATUS (0 = O.K.)
C
       ISTA = 0
C
C  Initialize the track number (radiated photon included)
C
       NTR = 3
C
C      CALL TELLER(K,1000,'EVENT LOOP')
       CALL GENBAB(PP,PM,QP,QM,QK,W,ICON)
       CALL CANCUT(QP,QM,QK,W)
       IDPR = ICON
       WEIT = W
       ECMS = 2.*EB
C
       RETURN
      ENDIF
C
C  END OF GENERATION         *********************
C
      IF(LENTRY.EQ.3) THEN
C---------------------- END OF EVENT LOOP -----------------------------
C
C EVALUATION OF THE GENERATED CROSS SECTION
C
       CALL ENDBAB(SIGTOT,ERRTOT)
       CALL EFFCIT
       CALL ENDCUT(SIGTOT)
C
      ENDIF
C
      RETURN
      END
