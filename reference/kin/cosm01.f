cFrom BLOCH@alws.cern.ch Fri Feb 13 16:02:49 2004
cDate: Fri, 13 Feb 2004 16:01:38 +0100
cFrom: BLOCH@alws.cern.ch
cTo: BLOCH@alws.cern.ch

C*HE 03/26/92 17:23:22 C
C*DK ASKUSE
      SUBROUTINE ASKUSE (IDPR,ISTA,NTRK,NVRT,ECMS,WEIT)
C --------------------------------------------------------------------
C!  Generate one muon and propagate down to ALEPH volume
C --------------------------------------------------------------------
C*CA BCS
      PARAMETER (LBCS=1000,LCHAR=4,LMHLEN=2)
      COMMON/BCS/ IW(LBCS)
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C*CC BCS
      COMMON /COSPAR/ EMIN,EMAX,ECUT, RVRT , ZVRT
      COMMON /COSEVT/ ENER, EOUT , COSTH , PHI , CHRG
      COMMON /COSTAT/ NEVENT(5)
      COMMON /COSIO/ IOU,IDB
      DIMENSION PTAB(4),VRTEX(4),PAR(6),PAREX(6)
      DATA IFI /0/ ,DEPTH/ 13000./,ZOUT,ROUT/650.,600./
C-------------------------------------------------------------
      IF ( IFI.EQ.0 ) THEN
         NAPAR=NAMIND('PART')
         ID=IW(NAPAR)
         NR=5
         AMU  =RW(ID+LMHLEN+(NR-1)*IW(ID+1)+6)
         IDB1=1
         IDB2=10
         JDEBU=IW(NAMIND('DEBU'))
         IF (JDEBU.NE.0) THEN
            IDB1=IW(JDEBU+1)
            IDB2=IW(JDEBU+2)
         ENDIF
         IFI=IFI+1
      ENDIF
      IDB=0
      IF (NEVENT(2).GE.IDB1-1 .AND. NEVENT(2).LE.IDB2) IDB =1
 1    CALL COSGEN ( EMIN , EMAX , IACC )
      NEVENT(1) = NEVENT(1) + 1
      IDPR = 0
      NTRK = 1
      NVRT = 1
      ISTA = 0
      ECMS = EOUT
      WEIT = 1.
C
C   Look if accepted
C
      IF (IACC.NE.1 ) THEN
        NEVENT(3)= NEVENT(3) + 1
        ISTA =1
        GO TO 1
      ENDIF
      IF (EOUT.LT.ECUT ) THEN
         NEVENT(4)= NEVENT(4) + 1
         ISTA =2
         GO TO 1
      ENDIF
C
C  Now fill 'KINE' and 'VERT' banks
C
C
C   Generate a surface point such it intercepts the ALEPH cylinder
C
      PMOD = SQRT (EOUT*EOUT - AMU*AMU)
      SINT = SQRT ( 1.-COSTH*COSTH)
C       BE CAREFULL  cosmics have a different reference system!
C
      PTAB(1) = -PMOD*SINT*COS(PHI)
      PTAB(2) = -PMOD*COSTH
      PTAB(3) = PMOD*SINT*SIN(PHI)
      RR=PTAB(2)/PTAB(1)
      AA=1.+RR*RR
      BB=RVRT*SQRT(1.+RR*RR)
      X1 = (DEPTH+BB)/RR
      X2 = (DEPTH-BB)/RR
      PAR(4)=PTAB(1)/PMOD
      PAR(5)=PTAB(2)/PMOD
      PAR(6)=PTAB(3)/PMOD
 2    PAR(1) = (X1-X2)*RNDM(DUM)+X2
      PAR(2) = DEPTH
      PAR(3) =  DEPTH*PTAB(3)/PTAB(2)+1.5*ZVRT*(2.*RNDM(DAM)-1.)
      CALL AULCYL(RVRT,ZVRT,PAR,PAREX,ICODE)
      CALL HFILL(10015,PAR(1),PAR(3),1.)
      IF (ICODE.EQ.0) GO TO 2
      CALL AULCYL(ROUT,ZOUT,PAR,PAREX,ICODE)
      IF (ICODE.EQ.0) GO TO 2
      CALL HFILL(10016,PAR(1),PAR(3),1.)
      VRTEX(1) = PAREX(1)
      VRTEX(2) = PAREX(2)
      VRTEX(3) = PAREX(3)
      VRTEX(4) = 0.
      JVERT = KBVERT(NVRT,VRTEX,0)
      IF(JVERT.EQ.0) THEN
        ISTA = 3
        NEVENT(5) = NEVENT(5) + 1
        GO TO 99
      ENDIF
      JT = 5
      IF (CHRG.LT.0.) JT=6
      PTAB(4)= 0.
      JKINE = KBKINE(NTRK,PTAB,JT,NVRT)
      IF(JKINE.EQ.0) THEN
        ISTA = 3
        NEVENT(5) = NEVENT(5) + 1
        GO TO 99
      ENDIF
C
      NEVENT(2) = NEVENT(2) + 1
      CALL HFILL(10011,SQRT(VRTEX(1)**2+VRTEX(2)**2),VRTEX(3),1.)
      CALL HFILL(10012,VRTEX(1),VRTEX(2),1.)
      IF (CHRG.GT.0.) CALL HFILL(10013,EOUT,0.,1.)
      IF (CHRG.LT.0.) CALL HFILL(10014,EOUT,0.,1.)
 99   RETURN
      END
C*DK ASKUSI
      SUBROUTINE ASKUSI(IGCOD)
C --------------------------------------------------------------------
C! Init generator parameters
C --------------------------------------------------------------------
C*CA BCS
      PARAMETER (LBCS=1000,LCHAR=4,LMHLEN=2)
      COMMON/BCS/ IW(LBCS)
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C*CC BCS
      COMMON /COSIO/ IOU,IDB
      COMMON /COSPAR/ EMIN,EMAX,ECUT, RVRT , ZVRT
      COMMON /COSTAT/ NEVENT(5)
      DIMENSION TABL(5)
      INTEGER ALTABL
      EXTERNAL ALTABL
      PARAMETER ( IGCO = 8001)
C
C   Return the generator code as defined in the KINGAL library
C
      IGCOD = IGCO
C   Default values
      EMIN = 70.
      EMAX = 1000.
      ECUT = 1.
      IOU = IW(6)
      RVRT = 650.
      ZVRT = 600.
C   READ here input parameters
C
C  The default values can be changed by the DATA CARD GLIM
       JGLIM = NLINK('GLIM',0)
       IF(JGLIM.NE.0) THEN
        EMIN = RW(JGLIM+1)
        EMAX = RW(JGLIM+2)
        ECUT = RW(JGLIM+3)
       ENDIF
       TABL(1) = EMIN
       TABL(2) = EMAX
       TABL(3) = ECUT
C  Main vertex generation parameters ( R ,Z ) card GVRT
       JGVRT = NLINK('GVRT',0)
       IF(JGVRT.NE.0) THEN
        RVRT = RW(JGVRT+1)
        ZVRT = RW(JGVRT+2)
       ENDIF
       TABL(4) = RVRT
       TABL(5) = ZVRT
C
C  Fill the KPAR bank with the generator parameters
C
       NCOL = 5
       NROW = 1
       JKPAR = ALTABL('KPAR',NCOL,NROW,TABL,'2I,(F)','C')
C
C  Initialize event counters
C
        DO 10 I=1,5
          NEVENT(I)=0
 10     CONTINUE
        WRITE (IW(6),1000) IGCOD
 1000   FORMAT(30X,78('*'),/40X,'This is the cosmics generator COSM01'
     $      ,/,70X,'Generator code is : ',I10,/,
     $         40x,'last date of modification is ',
     $      'March 26 , 1992',
     $      /,30x,78('*'),/)
C
C   Print flux tables
C
      CALL COSIPR
C
C  Initialize generator
C
      CALL COSGIN(EMIN,EMAX)
C
C  Print PART and KLIN banks
C
      CALL PRPART
      CALL PRTABL('KPAR',0)
C
      CALL HBOOK2(10015,'X VS Z SURFGENERE$',50,-15000.,15000.,
     &       50,-15000.,15000.,0.)
      CALL HBOOK2(10016,'X VS Z SURFACEPTE$',50,-15000.,15000.,
     &   50,-15000.,15000.,0.)
      RETURN
      END
C*DK USCJOB
      SUBROUTINE USCJOB
C --------------------------------------------------------------------
C
C --------------------------------------------------------------------
      COMMON /COSTAT/ NEVENT(5)
      COMMON /COSPAR/ EMIN,EMAX,ECUT, RVRT , ZVRT
      COMMON /COSIO/ IOU,IDB
      CALL COSGFI ( EMIN,EMAX,NEVENT(1),NEVENT(2))
       WRITE(IOU,101)
  101  FORMAT(//20X,'EVENTS STATISTICS',
     &         /20X,'*****************')
       WRITE(IOU,102)NEVENT(1),NEVENT(2),NEVENT(1)-NEVENT(2)
  102  FORMAT(/5X,'# OF GENERATED EVENTS                = ',I10,
     &        /5X,'# OF ACCEPTED  EVENTS                = ',I10,
     &        /5X,'# OF REJECTED  EVENTS                = ',I10)
       WRITE(IOU,103)
  103  FORMAT(//20X,'REJECT STATISTICS',
     &         /20X,'*****************')
       WRITE(IOU,104)NEVENT(3),NEVENT(4),NEVENT(5)
  104  FORMAT(/10X,'ISTA = 1 COSGEN REJECT, # OF  EVENTS = ',I10,
     &        /10X,'ISTA = 2 ECUT   REJECT, # OF  EVENTS = ',I10,
     &        /10X,'ISTA = 3 BOS    REJECT, # OF  EVENTS = ',I10)
C
      RETURN
      END
