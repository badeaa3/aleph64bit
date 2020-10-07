C   corections from Z.Was 03.03.97 : bug in NDIST0
C   mod B.Bloch April 98 : masses in INIMAS
C   mod B.Bloch Mai   98 : KORALZ and INIREA, allows for ITFIN=4 electron s-channel
C---------------------------------------------------
      PROGRAM KORZDM
C     **************
      COMMON / INOUT / INUT,IOUT
      COMMON  / / BLAN(10000)
      REAL*4    E1(3),E2(3),PB1(4),PB2(4)
      REAL*4 XPR(40)
      INTEGER NPR(40)
C INPUT PARAMETERS OF GENERATOR
C FOR MORE COMMENTS SEE:
C   1)  KORALZ LONG WRITE UP
C   2)  CHAPTER 5 OF  TAUOLA LONG WRITE UP
C+++++++++++++++++++++++++++++++++++++++++++++++++++
C INITIALIZATION OF THE INPUT OUTPUT UNIT NUMBERS
      INUT=5
      IOUT=6
C------1
      NEVTES=15
      ENE = 57.5
      ENE =  45.075+0.5 +5
      ENE = 91.17/2
      KEYGSW=4
      KEYRAD=12
      JAK1=1
      JAK2=1
      ISPIN= 1
      INRAN= 1
      AMZ=91.17
      AMH=100
      AMTOP= 90
      XK0=0.01
      VVMIN=0.00001
      VVMAX=1.0
      vvmax=1.0 -(1.8/ENE)**2
      GV= 1
      GA=-1
      SINW2=.229
      GAMZ=2.6
      KFB=-11
      AMNUTA=0.010
      ITDKRC=1
      XK0DEC=0.001
      DO 5 I=1,3
      E1(I)=0
   5  E2(I)=0
C     E2(3)=-1.00
C     E1(3)=0.55
      PRINT 7001 ,NEVTES,ENE,KEYGSW,KEYRAD,ISPIN,INRAN,JAK1,JAK2,KFB
      PRINT 7002 , E2(1), E2(2), E2(3), E1(1), E1(2), E1(3)
C INITIALISATION OF THE GENERATOR
      NPR(1)=ISPIN
      NPR(2)=INRAN
      NPR(3)=KEYGSW
      NPR(4)=KEYRAD
      NPR(5)=JAK1
      NPR(6)=JAK2
      NPR(7)=505
      NPR(7)=1
      NPR(8)=ITDKRC
      NPR(9)=1
      IF (NPR(9).EQ.1) THEN
        PRINT *, 'FIRST LIBRARY'
      ELSE
        PRINT *, 'SECOND LIBRARY'
      ENDIF
      NPR(11)=1
C KEYRAD OF YFS3
      NPR(12)=1000011
      XPR(1)=AMZ
      XPR(2)=AMH
      XPR(3)=AMTOP
      XPR(4)=GV
      XPR(5)=GA
      XPR(6)=SINW2
      XPR(7)=GAMZ
      XPR(8)=AMNUTA
C MASS OF NEUTRIONO OR QUARK
      XPR(9)=0.1
      XPR(11)=XK0
      XPR(12)=VVMIN
      XPR(13)=VVMAX
      XPR(14)=XK0DEC
      PB1(1)=0
      PB1(2)=0
      PB1(3)=ENE
      PB1(4)=ENE
      DO 7 I=1,3
   7  PB2(I)=-PB1(I)
      PB2(4)= PB1(4)
C LUND IDENTIFIER FOR ELECTRON KF = 11
      CALL KORALZ(-1,KFB,PB1,E1,-KFB,PB2,E2,XPR,NPR)
C     **********************************************
C+++++++++++++++++++++++++++++++++++++++++++++++++++
C MAIN LOOP
      DO 300 IEV=1,NEVTES
      CALL KORALZ(0 ,KFB,PB1,E1,-KFB,PB2,E2,XPR,NPR)
C     **********************************************
      NEV=IEV
      IPRI=MOD(NEV,100)
      IF(IPRI.EQ.1) PRINT *, ' event no: ',NEV,' NEVTES: ',NEVTES
C PRINTING FIRST EVENTS
      IF(IEV.LE.5)THEN
          CALL LUHEPC(2)
          CALL LULIST(2)
      ENDIF
  300 CONTINUE
C POSTGENERATION, PRINTOUTS
      CALL KORALZ( 1,0,PB1,E1,0,PB2,E2,XPR,NPR)
C     *****************************************
 7001 FORMAT(///1X,15(5HZZZZZ)
     $ /,' Z',25X     ,'=== KORALZ; DEMONSTRATION PROGRAM ===  ',9X,1HZ,
     $ /,' Z',I20  ,5X,'NEVTES  NO. OF EVENTS                  ',9X,1HZ,
     $ /,' Z',F20.5,5X,'ENE       CMS ENERGY                   ',9X,1HZ,
     $ /,' Z',I20  ,5X,'KEYGSW    GSW LEVEL                    ',9X,1HZ,
     $ /,' Z',I20  ,5X,'KEYRAD    BREMSS. ON/OFF               ',9X,1HZ,
     $ /,' Z',I20  ,5X,'ISPIN     FINAL STATE SPIN ON/OFF      ',9X,1HZ,
     $ /,' Z',I20  ,5X,'INRAN     RAND NUMB. INITIALIZ. CONST. ',9X,1HZ,
     $ /,' Z',I20  ,5X,'JAK1   DECAY TYPE TAU+                 ',9X,1HZ,
     $ /,' Z',I20  ,5X,'JAK2   DECAY TYPE TAU-                 ',9X,1HZ,
     $ /,' Z',I20  ,5X,'KFB    BEAM IDENTIFIER (LUND =+-7)     ',9X,1HZ,
     $ /,1X,15(5HZZZZZ)/)
 7002 FORMAT(///1X,15(5HZZZZZ)
     $ /,' Z',F20.5,5X,'E2(1)  ELECTR. POLARIZ. VEC.           ',9X,1HZ,
     $ /,' Z',F20.5,5X,'E2(2)                                  ',9X,1HZ,
     $ /,' Z',F20.5,5X,'E2(3)                                  ',9X,1HZ,
     $ /,' Z',F20.5,5X,'E1(1)  POSITR. POLARIZ. VEC.           ',9X,1HZ,
     $ /,' Z',F20.5,5X,'E1(2)                                  ',9X,1HZ,
     $ /,' Z',F20.5,5X,'E1(3)                                  ',9X,1HZ,
     $ /,1X,15(5HZZZZZ)/)
      END
      SUBROUTINE TAURDF(KTO)
C THIS ROUTINE CAN BE CALLED BEFORE ANY TAU+ OR TAU- EVENT IS GENERATED
C IT CAN BE USED TO GENERATE TAU+ AND TAU- SAMPLES OF DIFFERENT
C CONTENTS
      COMMON / TAUKLE / BRA1,BRK0,BRK0B,BRKS
      REAL*4            BRA1,BRK0,BRK0B,BRKS
      COMMON / TAUBRA / GAMPRT(30),JLIST(30),NCHAN
      IF (KTO.EQ.1) THEN
C     ==================
C LIST OF BRANCHING RATIOS
      NCHAN = 19
      DO 1 I = 1,30
      IF (I.LE.NCHAN) THEN
        JLIST(I) = I
        IF(I.EQ. 1) GAMPRT(I) = .0000
        IF(I.EQ. 2) GAMPRT(I) = .0000
        IF(I.EQ. 3) GAMPRT(I) = .0000
        IF(I.EQ. 4) GAMPRT(I) = .0000
        IF(I.EQ. 5) GAMPRT(I) = .0000
        IF(I.EQ. 6) GAMPRT(I) = .0000
        IF(I.EQ. 7) GAMPRT(I) = .0000
        IF(I.EQ. 8) GAMPRT(I) = 1.0000
        IF(I.EQ. 9) GAMPRT(I) = 1.0000
        IF(I.EQ.10) GAMPRT(I) = 1.0000
        IF(I.EQ.11) GAMPRT(I) = 1.0000
        IF(I.EQ.12) GAMPRT(I) = 1.0000
        IF(I.EQ.13) GAMPRT(I) = 1.0000
        IF(I.EQ.14) GAMPRT(I) = 1.0000
        IF(I.EQ.15) GAMPRT(I) = 1.0000
        IF(I.EQ.16) GAMPRT(I) = 1.0000
        IF(I.EQ.17) GAMPRT(I) = 1.0000
        IF(I.EQ.18) GAMPRT(I) = 1.0000
        IF(I.EQ.19) GAMPRT(I) = 1.0000
      ELSE
        JLIST(I) = 0
        GAMPRT(I) = 0.
      ENDIF
   1  CONTINUE
C --- COEFFICIENTS TO FIX RATIO OF:
C --- A1 3CHARGED/ A1 1CHARGED 2 NEUTRALS MATRIX ELEMENTS (MASLESS LIM.)
C --- PROBABILITY OF K0 TO BE KS
C --- PROBABILITY OF K0B TO BE KS
C --- RATIO OF COEFFICIENTS FOR K*--> K0 PI-
C --- ALL COEFFICENTS SHOULD BE IN THE RANGE (0.0,1.0)
C --- THEY MEANING IS PROBABILITY OF THE FIRST CHOICE ONLY IF ONE
C --- NEGLECTS MASS-PHASE SPACE EFFECTS
      BRA1=0.5
      BRK0=0.5
      BRK0B=0.5
      BRKS=0.6667
      ELSE
C     ====
C LIST OF BRANCHING RATIOS
      NCHAN = 19
      DO 2 I = 1,30
      IF (I.LE.NCHAN) THEN
        JLIST(I) = I
        IF(I.EQ. 1) GAMPRT(I) = .0000
        IF(I.EQ. 2) GAMPRT(I) = .0000
        IF(I.EQ. 3) GAMPRT(I) = .0000
        IF(I.EQ. 4) GAMPRT(I) = .0000
        IF(I.EQ. 5) GAMPRT(I) = .0000
        IF(I.EQ. 6) GAMPRT(I) = .0000
        IF(I.EQ. 7) GAMPRT(I) = .0000
        IF(I.EQ. 8) GAMPRT(I) = 1.0000
        IF(I.EQ. 9) GAMPRT(I) = 1.0000
        IF(I.EQ.10) GAMPRT(I) = 1.0000
        IF(I.EQ.11) GAMPRT(I) = 1.0000
        IF(I.EQ.12) GAMPRT(I) = 1.0000
        IF(I.EQ.13) GAMPRT(I) = 1.0000
        IF(I.EQ.14) GAMPRT(I) = 1.0000
        IF(I.EQ.15) GAMPRT(I) = 1.0000
        IF(I.EQ.16) GAMPRT(I) = 1.0000
        IF(I.EQ.17) GAMPRT(I) = 1.0000
        IF(I.EQ.18) GAMPRT(I) = 1.0000
        IF(I.EQ.19) GAMPRT(I) = 1.0000
      ELSE
        JLIST(I) = 0
        GAMPRT(I) = 0.
      ENDIF
   2  CONTINUE
C --- COEFFICIENTS TO FIX RATIO OF:
C --- A1 3CHARGED/ A1 1CHARGED 2 NEUTRALS MATRIX ELEMENTS (MASLESS LIM.)
C --- PROBABILITY OF K0 TO BE KS
C --- PROBABILITY OF K0B TO BE KS
C --- RATIO OF COEFFICIENTS FOR K*--> K0 PI-
C --- ALL COEFFICENTS SHOULD BE IN THE RANGE (0.0,1.0)
C --- THEY MEANING IS PROBABILITY OF THE FIRST CHOICE ONLY IF ONE
C --- NEGLECTS MASS-PHASE SPACE EFFECTS
      BRA1=0.5
      BRK0=0.5
      BRK0B=0.5
      BRKS=0.6667
      ENDIF
C     =====
      END
C=============================================================
C=============================================================
C==== end of directory ===== =================================
C=============================================================
C=============================================================
      SUBROUTINE CHOICE(MNUM,RR,ICHAN,PROB1,PROB2,PROB3,
     $            AMRX,GAMRX,AMRA,GAMRA,AMRB,GAMRB)
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      AMROP=1.1
      GAMROP=0.36
      AMOM=.782
      GAMOM=0.0084
C     XXXXA CORRESPOND TO S2 CHANNEL !
      IF(MNUM.EQ.0) THEN
       PROB1=0.5
       PROB2=0.5
       AMRX =AMA1
       GAMRX=GAMA1
       AMRA =AMRO
       GAMRA=GAMRO
       AMRB =AMRO
       GAMRB=GAMRO
      ELSEIF(MNUM.EQ.1) THEN
       PROB1=0.5
       PROB2=0.5
       AMRX =1.57
       GAMRX=0.9
       AMRB =AMKST
       GAMRB=GAMKST
       AMRA =AMRO
       GAMRA=GAMRO
      ELSEIF(MNUM.EQ.2) THEN
       PROB1=0.5
       PROB2=0.5
       AMRX =1.57
       GAMRX=0.9
       AMRB =AMKST
       GAMRB=GAMKST
       AMRA =AMRO
       GAMRA=GAMRO
      ELSEIF(MNUM.EQ.3) THEN
       PROB1=0.5
       PROB2=0.5
       AMRX =1.27
       GAMRX=0.3
       AMRA =AMKST
       GAMRA=GAMKST
       AMRB =AMKST
       GAMRB=GAMKST
      ELSEIF(MNUM.EQ.4) THEN
       PROB1=0.5
       PROB2=0.5
       AMRX =1.27
       GAMRX=0.3
       AMRA =AMKST
       GAMRA=GAMKST
       AMRB =AMKST
       GAMRB=GAMKST
      ELSEIF(MNUM.EQ.5) THEN
       PROB1=0.5
       PROB2=0.5
       AMRX =1.27
       GAMRX=0.3
       AMRA =AMKST
       GAMRA=GAMKST
       AMRB =AMRO
       GAMRB=GAMRO
      ELSEIF(MNUM.EQ.6) THEN
       PROB1=0.4
       PROB2=0.4
       AMRX =1.27
       GAMRX=0.3
       AMRA =AMRO
       GAMRA=GAMRO
       AMRB =AMKST
       GAMRB=GAMKST
      ELSEIF(MNUM.EQ.7) THEN
       PROB1=0.0
       PROB2=1.0
       AMRX =1.27
       GAMRX=0.9
       AMRA =AMRO
       GAMRA=GAMRO
       AMRB =AMRO
       GAMRB=GAMRO
      ELSEIF(MNUM.EQ.8) THEN
       PROB1=0.0
       PROB2=1.0
       AMRX =AMROP
       GAMRX=GAMROP
       AMRB =AMOM
       GAMRB=GAMOM
       AMRA =AMRO
       GAMRA=GAMRO
      ELSEIF(MNUM.EQ.101) THEN
       PROB1=.2
       PROB2=.2
       AMRX =1.3
       GAMRX=.46
       AMRB =AMOM
       GAMRB=GAMOM
       AMRA =AMOM
       GAMRA=GAMOM
      ELSEIF(MNUM.EQ.102) THEN
       PROB1=0.0
       PROB2=0.0
       AMRX =1.42
       GAMRX=.21
       AMRB =AMOM
       GAMRB=GAMOM
       AMRA =AMOM
       GAMRA=GAMOM
      ELSE
       PROB1=0.0
       PROB2=0.0
       AMRX =AMA1
       GAMRX=GAMA1
       AMRA =AMRO
       GAMRA=GAMRO
       AMRB =AMRO
       GAMRB=GAMRO
      ENDIF
C
      IF    (RR.LE.PROB1) THEN
       ICHAN=1
      ELSEIF(RR.LE.(PROB1+PROB2)) THEN
       ICHAN=2
        AX   =AMRA
        GX   =GAMRA
        AMRA =AMRB
        GAMRA=GAMRB
        AMRB =AX
        GAMRB=GX
        PX   =PROB1
        PROB1=PROB2
        PROB2=PX
      ELSE
       ICHAN=3
      ENDIF
C
      PROB3=1.0-PROB1-PROB2
      END
      SUBROUTINE INIPHX(XK00)
C     SUBROUTINE INIPHY(XK00)
C ----------------------------------------------------------------------
C     INITIALISATION OF PARAMETERS
C     USED IN QED and/or GSW ROUTINES
C ----------------------------------------------------------------------
      COMMON / QEDPRM /ALFINV,ALFPI,XK0
      REAL*8           ALFINV,ALFPI,XK0
      REAL*8 PI8,XK00
C
      PI8    = 4.D0*DATAN(1.D0)
      ALFINV = 137.03604D0
      ALFPI  = 1D0/(ALFINV*PI8)
C---->      XK0=XK00
      END
      SUBROUTINE INITDK
C ----------------------------------------------------------------------
C     INITIALISATION OF TAU DECAY PARAMETERS  and routines
C
C     called by : KORALZ
C ----------------------------------------------------------------------
      COMMON / DECPAR / GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL*4            GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / TAUBRA / GAMPRT(30),JLIST(30),NCHAN
      COMMON / TAUKLE / BRA1,BRK0,BRK0B,BRKS
      REAL*4            BRA1,BRK0,BRK0B,BRKS
      PARAMETER (NMODE=15,NM1=0,NM2=1,NM3=8,NM4=2,NM5=1,NM6=3)
      COMMON / DECOMP /IDFFIN(9,NMODE),MULPIK(NMODE)
     &                ,NAMES
      CHARACTER NAMES(NMODE)*31
      REAL*4 PI
C
C LIST OF BRANCHING RATIOS
CAM normalised to e nu nutau channel
CAM                  enu   munu   pinu  rhonu   A1nu   Knu    K*nu   pi'
CAM   DATA JLIST  /    1,     2,     3,     4,     5,     6,     7,
CAM   DATA GAMPRT /1.000,0.9730,0.6054,1.2432,0.8432,0.0432,O.O811,0.616
CAM
CAM  multipion decays
C
C    conventions of particles names
C                 K-,P-,K+,  K0,P-,KB,  K-,P0,K0
C                  3, 1,-3  , 4, 1,-4  , 3, 2, 4  ,
C                 P0,P0,K-,  K-,P-,P+,  P-,KB,P0
C                  2, 2, 3  , 3, 1,-1  , 1,-4, 2  ,
C                 ET,P-,P0   P-,P0,GM
C                  9, 1, 2  , 1, 2, 8
C
      DIMENSION NOPIK(6,NMODE),NPIK(NMODE)
CAM   outgoing multiplicity and flavors of multi-pion /multi-K modes
      DATA   NPIK  /                4,                    4,
     1                              5,                    5,
     2                              6,                    6,
     3                              3,                    3,
     4                              3,                    3,
     5                              3,                    3,
     6                              3,                    3,
     7                              2                         /
      DATA  NOPIK / -1,-1, 1, 2, 0, 0,     2, 2, 2,-1, 0, 0,
     1              -1,-1, 1, 2, 2, 0,    -1,-1,-1, 1, 1, 0,
     2              -1,-1,-1, 1, 1, 2,    -1,-1, 1, 2, 2, 2,
     3              -3,-1, 3, 0, 0, 0,    -4,-1, 4, 0, 0, 0,
     4              -3, 2,-4, 0, 0, 0,     2, 2,-3, 0, 0, 0,
     5              -3,-1, 1, 0, 0, 0,    -1, 4, 2, 0, 0, 0,
     6               9,-1, 2, 0, 0, 0,    -1, 2, 8, 0, 0, 0,
     7              -3, 4, 0, 0, 0, 0                         /
C LIST OF BRANCHING RATIOS
      NCHAN = NMODE + 7
      DO 1 I = 1,30
      IF (I.LE.NCHAN) THEN
        JLIST(I) = I
        IF(I.EQ. 1) GAMPRT(I) = 1.0000
        IF(I.EQ. 2) GAMPRT(I) = 1.0000
        IF(I.EQ. 3) GAMPRT(I) = 1.0000
        IF(I.EQ. 4) GAMPRT(I) = 1.0000
        IF(I.EQ. 5) GAMPRT(I) = 1.0000
        IF(I.EQ. 6) GAMPRT(I) = 1.0000
        IF(I.EQ. 7) GAMPRT(I) = 1.0000
        IF(I.EQ. 8) GAMPRT(I) = 1.0000
        IF(I.EQ. 9) GAMPRT(I) = 1.0000
        IF(I.EQ.10) GAMPRT(I) = 1.0000
        IF(I.EQ.11) GAMPRT(I) = 1.0000
        IF(I.EQ.12) GAMPRT(I) = 1.0000
        IF(I.EQ.13) GAMPRT(I) = 1.0000
        IF(I.EQ.14) GAMPRT(I) = 1.0000
        IF(I.EQ.15) GAMPRT(I) = 1.0000
        IF(I.EQ.16) GAMPRT(I) = 1.0000
        IF(I.EQ.17) GAMPRT(I) = 1.0000
        IF(I.EQ.18) GAMPRT(I) = 1.0000
        IF(I.EQ.19) GAMPRT(I) = 1.0000
        IF(I.EQ.20) GAMPRT(I) = 1.0000
        IF(I.EQ.21) GAMPRT(I) = 1.0000
        IF(I.EQ.22) GAMPRT(I) = 1.0000
        IF(I.EQ. 8) NAMES(I-7)='  TAU-  --> 2PI-,  PI0,  PI+   '
        IF(I.EQ. 9) NAMES(I-7)='  TAU-  --> 3PI0,        PI-   '
        IF(I.EQ.10) NAMES(I-7)='  TAU-  --> 2PI-,  PI+, 2PI0   '
        IF(I.EQ.11) NAMES(I-7)='  TAU-  --> 3PI-, 2PI+,        '
        IF(I.EQ.12) NAMES(I-7)='  TAU-  --> 3PI-, 2PI+,  PI0   '
        IF(I.EQ.13) NAMES(I-7)='  TAU-  --> 2PI-,  PI+, 3PI0   '
        IF(I.EQ.14) NAMES(I-7)='  TAU-  -->  K-, PI-,  K+      '
        IF(I.EQ.15) NAMES(I-7)='  TAU-  -->  K0, PI-, K0B      '
        IF(I.EQ.16) NAMES(I-7)='  TAU-  -->  K-,  K0, PI0      '
        IF(I.EQ.17) NAMES(I-7)='  TAU-  --> PI0, PI0,  K-      '
        IF(I.EQ.18) NAMES(I-7)='  TAU-  -->  K-, PI-, PI+      '
        IF(I.EQ.19) NAMES(I-7)='  TAU-  --> PI-, K0B, PI0      '
        IF(I.EQ.20) NAMES(I-7)='  TAU-  --> ETA, PI-, PI0      '
        IF(I.EQ.21) NAMES(I-7)='  TAU-  --> PI-, PI0, GAM      '
        IF(I.EQ.22) NAMES(I-7)='  TAU-  -->  K-,  K0           '
      ELSE
        JLIST(I) = 0
        GAMPRT(I) = 0.
      ENDIF
   1  CONTINUE
      DO I=1,NMODE
        MULPIK(I)=NPIK(I)
        DO J=1,MULPIK(I)
         IDFFIN(J,I)=NOPIK(J,I)
        ENDDO
      ENDDO
C
C
C --- COEFFICIENTS TO FIX RATIO OF:
C --- A1 3CHARGED/ A1 1CHARGED 2 NEUTRALS MATRIX ELEMENTS (MASLESS LIM.)
C --- PROBABILITY OF K0 TO BE KS
C --- PROBABILITY OF K0B TO BE KS
C --- RATIO OF COEFFICIENTS FOR K*--> K0 PI-
C --- ALL COEFFICENTS SHOULD BE IN THE RANGE (0.0,1.0)
C --- THEY MEANING IS PROBABILITY OF THE FIRST CHOICE ONLY IF ONE
C --- NEGLECTS MASS-PHASE SPACE EFFECTS
      BRA1=0.5
      BRK0=0.5
      BRK0B=0.5
      BRKS=0.6667
C
C --- remaining constants
      PI =4.*ATAN(1.)
      GFERMI = 1.16637E-5
      CCABIB = 0.975
C      GV     = 1.0
C      GA     =-1.0
C ZW 13.04.89 HERE WAS AN ERROR
      SCABIB = SQRT(1.-CCABIB**2)
      GAMEL  = GFERMI**2*AMTAU**5/(192*PI**3)
C
      CALL DEXAY(-1)
C
      RETURN
      END
      FUNCTION DCDMAS(IDENT)
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      IF      (IDENT.EQ. 1) THEN
        APKMAS=AMPI
      ELSEIF  (IDENT.EQ.-1) THEN
        APKMAS=AMPI
      ELSEIF  (IDENT.EQ. 2) THEN
        APKMAS=AMPIZ
      ELSEIF  (IDENT.EQ.-2) THEN
        APKMAS=AMPIZ
      ELSEIF  (IDENT.EQ. 3) THEN
        APKMAS=AMK
      ELSEIF  (IDENT.EQ.-3) THEN
        APKMAS=AMK
      ELSEIF  (IDENT.EQ. 4) THEN
        APKMAS=AMKZ
      ELSEIF  (IDENT.EQ.-4) THEN
        APKMAS=AMKZ
      ELSEIF  (IDENT.EQ. 8) THEN
        APKMAS=0.0001
      ELSEIF  (IDENT.EQ.-8) THEN
        APKMAS=0.0001
      ELSEIF  (IDENT.EQ. 9) THEN
        APKMAS=0.5488
      ELSEIF  (IDENT.EQ.-9) THEN
        APKMAS=0.5488
      ELSE
        PRINT *, 'STOP IN APKMAS, WRONG IDENT=',IDENT
        STOP
      ENDIF
      DCDMAS=APKMAS
      END
      FUNCTION LUNPIK(ID,ISGN)
      COMMON / TAUKLE / BRA1,BRK0,BRK0B,BRKS
      REAL*4            BRA1,BRK0,BRK0B,BRKS
      IDENT=ID*ISGN
      IF      (IDENT.EQ. 1) THEN
        IPKDEF=-211
      ELSEIF  (IDENT.EQ.-1) THEN
        IPKDEF= 211
      ELSEIF  (IDENT.EQ. 2) THEN
        IPKDEF=111
      ELSEIF  (IDENT.EQ.-2) THEN
        IPKDEF=111
      ELSEIF  (IDENT.EQ. 3) THEN
        IPKDEF=-321
      ELSEIF  (IDENT.EQ.-3) THEN
        IPKDEF= 321
      ELSEIF  (IDENT.EQ. 4) THEN
C
C K0 --> K0_LONG (IS 130) / K0_SHORT (IS 310) = 1/1
        CALL RANMAR(XIO,1)
        IF (XIO.GT.BRK0) THEN
          IPKDEF= 130
        ELSE
          IPKDEF= 310
        ENDIF
      ELSEIF  (IDENT.EQ.-4) THEN
C
C K0B--> K0_LONG (IS 130) / K0_SHORT (IS 310) = 1/1
        CALL RANMAR(XIO,1)
        IF (XIO.GT.BRK0B) THEN
          IPKDEF= 130
        ELSE
          IPKDEF= 310
        ENDIF
      ELSEIF  (IDENT.EQ. 8) THEN
        IPKDEF= 22
      ELSEIF  (IDENT.EQ.-8) THEN
        IPKDEF= 22
      ELSEIF  (IDENT.EQ. 9) THEN
        IPKDEF= 221
      ELSEIF  (IDENT.EQ.-9) THEN
        IPKDEF= 221
      ELSE
        PRINT *, 'STOP IN IPKDEF, WRONG IDENT=',IDENT
        STOP
      ENDIF
      LUNPIK=IPKDEF
      END
      SUBROUTINE INIMAS
C ----------------------------------------------------------------------
C     INITIALISATION OF MASSES
C
C     called by : KORALZ
C ----------------------------------------------------------------------
      COMMON / IDPART/ IA1
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
C IN-COMING / OUT-GOING  FERMION MASSES
CBB      AMTAU  = 1.784197
      AMTAU  = 1.777
      AMEL   = 0.0005111
      AMNUE  = 0.0
      AMMU   = 0.105659
      AMNUMU = 0.00
C
C MASSES USED IN TAU DECAYS
      AMPIZ  = 0.134964
      AMPI   = 0.139568
      AMRO   = 0.7714
      GAMRO  = 0.153
CBB      AMRO   = 0.773
CBB      GAMRO  = 0.145
      AMA1   = 1.251
      GAMA1  = 0.599
      AMK    = 0.493667
      AMKZ   = 0.49772
      AMKST  = 0.8921
      GAMKST = 0.0513
C
      RETURN
      END
      SUBROUTINE INIVTX
C ----------------------------------------------------------------------
C
C     INITIALISATION OF COUPLING CONSTANTS AND FERMION-GAMMA / Z0 VERTEX
C
C     called by : KORALZ
C ----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      COMMON / BEAMPM / ENE ,AMIN,AMFIN,IDE,IDF
      REAL*8            ENE ,AMIN,AMFIN
      COMMON / GAUSPM /SS,POLN,T3E,QE,T3F,QF
     &                ,XUPGI   ,XUPZI   ,XUPGF   ,XUPZF
     &                ,NDIAG0,NDIAGA,KEYA,KEYZ
     &                ,ITCE,JTCE,ITCF,JTCF,KOLOR
      REAL*8           SS,POLN,T3E,QE,T3F,QF
     &                ,XUPGI(2),XUPZI(2),XUPGF(2),XUPZF(2)
      COMMON / GSWPRM /SWSQ,AMW,AMZ,AMH,AMTOP,GAMMZ
      REAL*8           SWSQ,AMW,AMZ,AMH,AMTOP,GAMMZ
C     SWSQ        = sin2 (theta Weinberg)
C     AMW,AMZ     = W & Z boson masses respectively
C     AMH         = the Higgs mass
C     AMTOP       = the top mass
C     GAMMZ       = Z0 width
      COMMON / QEDPRM /ALFINV,ALFPI,XK0
      REAL*8           ALFINV,ALFPI,XK0
C
      ITCE=IDE/IABS(IDE)
      JTCE=(1-ITCE)/2
      ITCF=IDF/IABS(IDF)
      JTCF=(1-ITCF)/2
      CALL GIVIZO( IDE, 1,AIZOR,QE,KDUMM)
      CALL GIVIZO( IDE,-1,AIZOL,QE,KDUMM)
      XUPGI(1)=QE
      XUPGI(2)=QE
      T3E    = AIZOL+AIZOR
      XUPZI(1)=(AIZOR-QE*SWSQ)/SQRT(SWSQ*(1-SWSQ))
      XUPZI(2)=(AIZOL-QE*SWSQ)/SQRT(SWSQ*(1-SWSQ))
      CALL GIVIZO( IDF, 1,AIZOR,QF,KOLOR)
      CALL GIVIZO( IDF,-1,AIZOL,QF,KOLOR)
      XUPGF(1)=QF
      XUPGF(2)=QF
      T3F    =  AIZOL+AIZOR
      XUPZF(1)=(AIZOR-QF*SWSQ)/SQRT(SWSQ*(1-SWSQ))
      XUPZF(2)=(AIZOL-QF*SWSQ)/SQRT(SWSQ*(1-SWSQ))
C
      NDIAG0=2
      NDIAGA=11
      KEYA  = 1
      KEYZ  = 1
C
C
      RETURN
      END
      SUBROUTINE INIPHY
C ----------------------------------------------------------------------
C     INITIALISATION OF PHYSICAL PARAMETERS
C     USED IN QED and/or GSW ROUTINES
C
C     called by : KORALZ
C ----------------------------------------------------------------------
      COMMON / BEAMPM / ENE ,AMIN,AMFIN,IDE,IDF
      REAL*8            ENE ,AMIN,AMFIN
      COMMON / KEYSET / KEYGSW,KEYRAD,KEYTAB
       COMMON /GSWLIB/ KEYWLB
      COMMON / GSWPRM /SWSQ,AMW,AMZ,AMH,AMTOP,GAMMZ
      REAL*8           SWSQ,AMW,AMZ,AMH,AMTOP,GAMMZ
C     SWSQ        = sin2 (theta Weinberg)
C     AMW,AMZ     = W & Z boson masses respectively
C     AMH         = the Higgs mass
C     AMTOP       = the top mass
C     GAMMZ       = Z0 width
      COMMON / QEDPRM /ALFINV,ALFPI,XK0
      REAL*8           ALFINV,ALFPI,XK0
      COMMON / INOUT / INUT,IOUT
      REAL*8   GAMW,GAMW0,GAMMZ0,GAMMX0,GAMMX,AMX,AMWW,SWSQR
      REAL*8 PI8,MZ,MT,MH
C
      PI8    = 4.D0*DATAN(1.D0)
      ALFINV = 137.03604D0
      ALFPI  = 1D0/(ALFINV*PI8)
C
C -------------------------------------------------------------------
C INITIALISATIONS OF THE GSW RAD CORR. SUBROGRAMS
C SET RELEVANT VARIABLES FOR KEYGSW>1
      IF(KEYGSW.GE.2) THEN
C       MASS OF Z     FROM INPUT       AMZ
C       MASS OF HIGGS FROM INPUT       AMH
C       MASS OF TOP   FROM INPUT       AMTOP
C**     CALCULATE W MASS OUT OF MUON LIFE TIME AND MASS OF Z0
C**     CALCULATE SIN(THETAWEINBERG) OUT OF W MASS
C**     CALCULATE Z0 WIDTH
C       -------------------------
      IF     (KEYWLB.EQ.2 ) THEN
         WRITE(IOUT,'('' ELECTROWEAK CORRECTIONS ACCORDING TO '')')
         WRITE(IOUT,'('' second library                       '')')
        CALL       HOLSTA(IDF,KEYGSW,AMZ,AMH,AMTOP)
        CALL       PRMOUT(AMX,GAMMX0,GAMMX,AMWW,GAMW0,GAMW,SWSQR)
CHBU
        AMW  =AMWW
        SWSQ =SWSQR
        GAMMZ=GAMMX
        GAMMZ0=GAMMZ
      ELSEIF (KEYWLB.EQ.1) THEN
         WRITE(IOUT,'('' ELECTROWEAK CORRECTIONS ACCORDING TO '')')
         WRITE(IOUT,'('' first library                        '')')
        KEYTAB= 1
        MZ=AMZ
        MT=AMTOP
        MH=AMH
        CALL MASET(MZ,MH,MT)
        CALL PRMOUT(AMX,GAMMZ0,GAMMX,AMWW,GAMW0,GAMW,SWSQR )
        AMW  =AMWW
        SWSQ =SWSQR
        GAMMZ=GAMMZ0
      ENDIF
C
      ENDIF
C**   INIT. OF COMMON /GAUSPM/
      CALL INIVTX
      IF(KEYGSW.GE.2.AND.KEYWLB.EQ.1) THEN
C**     PRETABULATION OF VACUUM POL. FUNCTIONS
        CALL CINT
      ENDIF
C
      RETURN
      END
      SUBROUTINE INIREA (KF1,PB1,EE1,KF2,PB2,EE2,ITFIN)
C-----------------------------------------------------
C
C INITIALISE REACTION FROM INPUT ARGUMENTS
C
C     called by : KORALZ
C
C-----------------------------------------------------
      COMMON / BEAMS / XPB1(4),XPB2(4),KFB1,KFB2
      REAL*4           XPB1   ,XPB2
      COMMON / BEAMPM / ENE ,AMIN,AMFIN,IDE,IDF
      REAL*8            ENE ,AMIN,AMFIN
      COMMON / INSPIN / SEPS1,SEPS2
      REAL*8            SEPS1,SEPS2
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / IDFC  / IDFF
      COMMON /NEWMOD/  AMNEUT,NNEUT
      REAL*8           AMNEUT
      REAL*4 PB1(4),EE1(3),PB2(4),EE2(3)
C
        KFB1=KF1
        KFB2=KF2
C       BEAM MOMENTA
        DO 15 I=1,4
        XPB1(I)=PB1(I)
   15   XPB2(I)=PB2(I)
        SEPS1=EE1(3)
        SEPS2=EE2(3)
        ENE=XPB1(4)
C
C       DETERMINE WHETHER BEAM ALONG Z-AXIS IS AN ELECTR. OR POSITRON
C       FOR IDE<0 PB1 (ALONG Z-AXIS) REPRESENTS POSITRON
        IDE= 2*KFB1/IABS(KFB1)
C
C       DETERMINE WHETHER QP REPRESENT PARTICLE OR  ANTIPART.
C                                      (IDF<0)  OR   (IDF>0
      IF ((ITFIN.LE.2).or.(itfin.eq.4)) THEN
C       ABS(IDF) = 2 MEANS THAT IT'S A LEPTON
C       IDF=-2 MEANS THAT QP IS THE 4-MOMENTUM OF TAU+ (OR MU+)
        IDF= 2*KFB1/IABS(KFB1)
      ELSEIF(ITFIN.EQ.3) THEN
C       ABS(IDF) = 1 MEANS THAT IT'S A NEUTRINO
C       IDF=-1 MEANS THAT QP IS THE 4-MOMENTUM OF NUBAR
        IDF=   KFB1/IABS(KFB1)
      ENDIF
C
C       INITIAL FERMION MASS ( ELECTRON !)
        AMIN=AMEL
C
C       FINAL FERMION  MASS ETC.
        IF(ITFIN .EQ. 1) THEN
C*MWG* TAU CASE: PDG-code of tau- is 15
          AMFIN = AMTAU
          IDFF = 15*IDF/IABS(IDF)
        ELSEIF(ITFIN .EQ. 2) THEN
C*MWG* MUON CASE: PDG-code of mu- is 13
          AMFIN = AMMU
          IDFF = 13*IDF/IABS(IDF)
C DECAY SUPRESSED
          JAK1=-1
          JAK2=-1
        ELSEIF(ITFIN .EQ. 3) THEN
C*MWG* NU CASE: PDG-code of nu_tau is 16
          AMFIN = AMNEUT
          IDFF = 16*IDF/IABS(IDF)
C DECAY SUPRESSED
          JAK1=-1
          JAK2=-1
        ELSEIF(ITFIN .EQ. 4) THEN
C*bbl* e CASE: PDG-code of el is 11 only s channel , no t channel
          AMFIN = AMEL
          IDFF = 11*IDF/IABS(IDF)
C DECAY SUPRESSED
          JAK1=-1
          JAK2=-1
Change KMO start
        ELSE
          IAA  = ABS(ITFIN)-500
          IF (IAA .EQ. 2 .OR. IAA .EQ. 4 .OR. IAA .EQ. 6) THEN
            IDF= 3*KFB1/IABS(KFB1)
          ELSE
            IDF= 4*KFB1/IABS(KFB1)
          END IF
          AMFIN = AMNEUT
          IDFF = SIGN(IAA,IDF)
Change KMO end
        ENDIF
C
      RETURN
      END
      SUBROUTINE GIVIZO(IDFERM,IHELIC,SIZO3,CHARGE,KOLOR)
C ----------------------------------------------------------------------
C PROVIDES ELECTRIC CHARGE AND WEAK IZOSPIN OF A FAMILY FERMION
C IDFERM=1,2,3,4 DENOTES NEUTRINO, LEPTON, UP AND DOWN QUARK
C NEGATIVE IDFERM=-1,-2,-3,-4, DENOTES ANTIPARTICLE
C IHELIC=+1,-1 DENOTES RIGHT AND LEFT HANDEDNES ( CHIRALITY)
C SIZO3 IS THIRD PROJECTION OF WEAK IZOSPIN (PLUS MINUS HALF)
C AND CHARGE IS ELECTRIC CHARGE IN UNITS OF ELECTRON CHARGE
C KOLOR IS A QCD COLOUR, 1 FOR LEPTON, 3 FOR QUARKS
C
C     called by : EVENTE, EVENTM, FUNTIH, .....
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
C
      IF(IDFERM.EQ.0.OR.IABS(IDFERM).GT.4) GOTO 901
      IF(IABS(IHELIC).NE.1)                GOTO 901
      IH  =IHELIC
      IDTYPE =IABS(IDFERM)
      IC  =IDFERM/IDTYPE
      LEPQUA=INT(IDTYPE*0.4999999D0)
      IUPDOW=IDTYPE-2*LEPQUA-1
      CHARGE  =(-IUPDOW+2D0/3D0*LEPQUA)*IC
      SIZO3   =0.25D0*(IC-IH)*(1-2*IUPDOW)
      KOLOR=1+2*LEPQUA
C** NOTE THAT CONVENTIONALY Z0 COUPLING IS
C** XOUPZ=(SIZO3-CHARGE*SWSQ)/SQRT(SWSQ*(1-SWSQ))
      RETURN
 901  PRINT *,' STOP IN GIVIZO: WRONG PARAMS.'
      STOP
      END
      FUNCTION BORNS(MODE,SVAR,COSTHE,TA,TB)
C ----------------------------------------------------------------------
C THIS ROUTINE PROVIDES BORN CROSS SECTION. IT HAS THE SAME         *
C STRUCTURE AS FUNTIS AND FUNTIH, THUS CAN BE USED AS SIMPLER       *
C EXAMPLE OF THE METHOD APPLIED THERE                               *
C 18.04. IT IS NOT SO SIMPLE NOW THERE ARE 2 MODES SIMPLE OLD ONE   *
C AND THE NEW ONE WHERE ALSO ELECTROWEAK CORRECTIONS ARE ADDED      *
C
C     called by : BORNY, BORAS, BORNV, WAGA, WEIGHT
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
       COMMON /GSWLIB/ KEYWLB
      IF(SVAR.LE.0.D0) THEN
       BORNS=0.D0
       RETURN
      ENDIF
      IF (KEYWLB.EQ.1) THEN
        BORNS=BORNR(MODE,SVAR,COSTHE,TA,TB)
      ELSE
        BORNS=BORNH(MODE,SVAR,COSTHE,TA,TB)
      ENDIF
      END
      SUBROUTINE PRMOUT(ZMASS,GAMZ0,GAMZ,WMASS,GAMW0,GAMW,SIN2W)
C ----------------------------------------------------------------------
C  THIS SUBROUTINE CAN BE USED TO OBTAIN PARAMETERS OF THE GSW MODEL
C  SIN2W = SIN SQUARED OF THE WEAK MIXING ANGLE
C  GAMZ0, GAMZ = LOWEST ORDER ESTIMATE, CORRECTED Z0 WIDTH
C  WMASS = THE W BOSON MASS
C  GMAW0 = LOWEST ORDER ESTIMATE OF W WIDTH
C
C     called by : KORALZ, AMPGSW,CINTAA,CINTZZ,CINTZA, (FEEBOL)
C ----------------------------------------------------------------------
      IMPLICIT REAL*8  (A-H,O-Z)
       COMMON /GSWLIB/ KEYWLB
      IF (KEYWLB.EQ.1) THEN
        CALL PRMROB(ZMASS,GAMZ0,GAMZ,WMASS,GAMW0,GAMW,SIN2W)
      ELSE
        CALL PRMHOL(ZMASS,GAMZ0,GAMZ,WMASS,GAMW0,GAMW,SIN2W)
      ENDIF
      END
C=============================================================
C=============================================================
C==== end of elementary file =================================
C=============================================================
C=============================================================
      SUBROUTINE KORALZ(MODE,KF1,PB1,EE1,KF2,PB2,EE2,XPAR,NPAR)
C=====================================================================C
C=====================================================================C
C        KK  KK    OOO    KKKKK      KKK     LL     ZZZZZZ            C
C        KK KK   OO   OO  KK  KK    KK KKK   LL        ZZ             C
C        KKK     OO   OO  KKKK     KK   KK   LL      ZZ               C
C        KK KK   OO   OO  KK KK    KKKKKKK   LL     ZZ                C
C        KK  KK    OOO    KK  KK   KK   KK   LLLLL  ZZZZZZ            C
C=====================================================================C
C=======================   VERSION 4.02 ===============================
C======================================================================
C========================= OCTOBER 1995  ==============================
C======================================================================
C       MONTE CARLO EVENT GENERATOR FOR THE COMBINED                  C
C    TAU/MU PAIR PRODUCTION AND DECAY PROCESS AT LEP/SLC              C
C    (it contains YFS3 multiphoton generator as a part)               C
C                                                                     C
C                      Authors                                        C
C  S. JADACH     /1,2/   B.F.L. WARD   /3/  Z. WAS    /1,2/           C
C                                                                     C
C      /1/  INSTITUTE OF NUCLEAR PHYS. CRACOW                         C
C      /2/  CERN, Geneva                                              C
C      /3/  Universuty of Tennessee Knoxville, Tennessee              C
C======================================================================
C======================================================================
C== ACKNOWLEDGEMENTS : AUTHORS OF THE PROGRAM ARE INDEBTED           ==
C== TO ALL USERS OF THE PROGRAM WHO PROVIDED INVALUABLE HELP         ==
C== IN DEBUGGING THE PROGRAM, SPECIAL THANKS GO TO                   ==
C== F. BOILLOT, G. BONNEAUD, A. M. LUTZ WHO HELPED TO ORGANIZE       ==
C== THE CODE AND TO PUT IT INTO HISTORIAN.                           ==
C== THE NEUTRINO MODE OF THE PROGRAM WAS DEVELOPPED WITH THE ACTIVE  ==
C== PARTICIPATION OF P. COLAS AND L. MIRABITO FROM SACLAY            ==
C== SEE MUNICH REPORT MPI-PAE-EXP-EL-211 (1989)                      ==
C======================================================================
C
C    IMPORTANT NOTE:
C    BEFORE USING THIS PROGRAM YOU MAY CONTACT Z. WAS
C       THROUGH EARNET/BITNET, WASM at CERNVM,
C    AND, PERHAPS, YOU WILL GET A BETTER VERSION!!!
C    PLEASE ALSO REPORT ANY NOTICED ERROR OR ANY OTHER PROBLEM
C                   ***
C ---------------------------------------------------------------------
C ---------------------------------------------------------------------
C KORALZ IS THE COMMUNICATION CENTER FOR THE INPUT INFORMATION,
C*MWG*  ALL OUTPUT IS CODED IN COMMON / HEPEVT /
C*MWG*  ACCORDING TO STANDARD PDG CONVENTIONS.
C
C Calling arguments
C =================
C MODE=-1 initialization or reinitialization mode,
C         prior to generation, obligatory.
C     = 0 generation mode, m.c. event is generated.
C     = 1 postgeneration mode, printouts, optional.
C
C if MODE=-1 then all parameters are input data:
C    =======
C*MWG* KF1 = 11,-11 flavour code of first beam, KF1=11 for electron.
C*MWG* KF2 = 11,-11 flavour code of second beam, KF2=-11 for positron.
C PB1 = four momentum of the first beam.
C PB2 = four momentum of the second beam.
C EE1 = spin polarization vector for the first beam.
C EE2 = spin polarization vector for the second beam,
C       both in the corresponding beam particle rest frame
C       and in both cases third axis directed along first beam,
C       i.e. EE1(3) and -EE2(3) are helicities.
C       only EE1(3) EE2(3) can be nonzero (longitudinal polarization
C                                          only)
C other input parameters are hidden in XPAR and NPAR.
C NPAR(1)          =ISPIN              spin effects in decay
C NPAR(2)          =inran (OBSOLETE!)
C NPAR(3)          =KEYGSW             level of GSW corrections
C NPAR(4)          =KEYRAD             bremsstrahlung
C NPAR(5)          =JAK1               decay type of 1-st tau
C NPAR(6)          =JAK2               decay type of 2-nd tau
C NPAR(7)          =ITFIN              type of the final fermion
C NPAR(8)          =ITDKRC             radiation in tau decay
C NPAR(9)          =KEYWLB             type of electroweak library
C NPAR(11)         =nneut : number of neutrinos in the nunubar option
C NPAR(12)         =KEYYFS steering parameter of YFS3 see routine EXPAND
C                          and its own KEYRAD.
C  (The user has to change the width himself, this parameter has no
C   effect on the other final states.)
C XPAR( 1)=AMZ     =   mass of Z0 boson
C XPAR( 2)=AMH     =   mass of Higgs boson
C XPAR( 3)=AMTOP   =   mass of top quark
C XPAR( 4)=GV      =   W-tau coupling in tau decay
C XPAR( 5)=GA      =   W-tau coupling in tau decay
C XPAR( 6)=SWSQ    =   only for KEYGSW<2,
C XPAR( 7)=GAMMZ   =   only for KEYGSW<2, Z0 width.
C XPAR( 8)=AMNUTA  =   mass of tau neutrino in decay.
C XPAR( 9)=amneut  = neutrino mass used in nu-nubar option
C                    assumed unique (= AMNUTA by default)
C                    or quark to be generated mass (in quark mode)
C XPAR(11)=XK0     =   soft/hard cut   (single bremmstrahlung)
C XPAR(12)=VVMIN   =   minimum v for YFS2, should be 1.E-5or less,
C XPAR(13)=VVMAX   =   maximum v, (v=1-s'/s, sqrt(s')=final pair mass)
C XPAR(14)=XK0DEC  =   soft/hard cut in tau decay
C
C KEYGSW=  0 Z0, NO GAMMA, BORN APPROXIMATION
C       =  1 Z0+Gamma, Born approximation
C       =  2 Z0+Gamma, vacuum polarizations ON (no more supported
C       =  3 electroweak corrections switched ON (no more supported
C       =  4 electroweak corrections switched ON in a way
C            consistent with the higher orders of QED.
C KEYRAD   The type of the QED bremsstrahlung
C KEYRAD=  0, no bremsstrahlung
C       =  1, single bremsstrahlung
C NPAR(4)= 2, single bremsstrahlung, no QED ini-fin interference
C             note that internal variable KEYRAD is set ot 1.
C KEYRAD= 10, single bremsstralung but exponentiaited spectrum
C       = 11, YFS2/YFS3 generation; backward compatibility option in TRALOR
C       = 12, YFS2/YFS3 generation; default
C       =111, backward compatibility option
C       =112, backward compatibility option
C ISPIN = 0,1  spin effects in decay switched OFF/ON
C INRAN = initialisation constant for rand. num. gen. rnf100, positive,
C         obsolent!!
C ITFIN =1 tau pair production,
C       =2 muon pair production.
C       =3 nunub pair production.
C       =501-506 quark pair production.
C ITDKRC=0 no rad. corr. in tau decay
C       =1 with rad. corr. in tau decay
C JAK1  = -1 no decay
C       =  0 inclusive decay
C       =  1,2 electron and muon decays
C       =  3 pi decay
C       =  4,5 rho and a_1 decays
C       =  6,7 K   and K*  decays
C       =  8 ...
C       ...
C JAK2  = the same as for JAK1
C KEYWLB=1,2 electroweak corrections due to first or second choice
C         ======
C else if MODE=0 then all parameters are ignored
C         ======
C else if MODE=1 then
C         ======
C NPAR(10)= nevtot, no. of generated events,
C XPAR(10)= cstcm,  integrated total cross section in cm**2 units,
C XPAR(16)= CSTCM,  integrated total cross section in cm**2 units,
C XPAR(17)= CSTNB,  integrated total cross section in nb units,
C XPAR(18)= DCSNB,  error on cross section,
C XPAR(20+I)= GAMPMC(I) branching ratios,
C are output information provided for the user.
C endif
C         ======
C the user may add other internal parameters to npar and xpar
C a possible candidate is the list of the tau decay branching
C ratios GAMPRT in  / TAUBRA / GAMPRT(30),JLIST(30),NCHAN.
C at present GAMPRT is initialised in INITDK (norm. to tau>e nu nu chan
C
C =====================================================================
C
C Modified by AM. Lutz/G.Bonneaud  (Nov 1988-Jan 1989)
C to provide unique initialisations of (almost) all parameters, masses,
C and physical constants.
C
C =====================================================================
C     called by : ASKUSI,ASKUSE
C ---------------------------------------------------------
C     IMPLICIT LOGICAL(A-H,O-Z)
      COMMON / INOUT / INUT,IOUT
      COMMON / BEAMPM / ENE ,AMIN,AMFIN,IDE,IDF
      REAL*8            ENE ,AMIN,AMFIN
      COMMON / KEYSET / KEYGSW,KEYRAD,KEYTAB
       COMMON /GSWLIB/ KEYWLB
      COMMON / GSWPRM /SWSQ,AMW,AMZ,AMH,AMTOP,GAMMZ
      REAL*8           SWSQ,AMW,AMZ,AMH,AMTOP,GAMMZ
C     SWSQ        = sin2 (theta Weinberg)
C     AMW,AMZ     = W & Z boson masses respectively
C     AMH         = the Higgs mass
C     AMTOP       = the top mass
C     GAMMZ       = Z0 width
      COMMON / QEDPRM /ALFINV,ALFPI,XK0
      REAL*8           ALFINV,ALFPI,XK0
      COMMON / VVREK  / VVMIN,VVMAX,VV,BETI
      REAL*8            VVMIN,VVMAX,VV,BETI
      COMMON / FINUS / CSTCM,ERREL
      REAL*8           CSTCM,ERREL
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / DECPAR / GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL*4            GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      COMMON / JAKI   /  JAK1,JAK2,JAKP,JAKM,KTOM
      COMMON / TAUHEL / HELT1,HELT2
      REAL*4 HELT1,HELT2
      COMMON /TAUPOS/ NP1,NP2
      COMMON / TAUBMC / GAMPMC(30),GAMPER(30),NEVDEC(30)
      REAL*4            GAMPMC    ,GAMPER
      COMMON / TAURAD / XK0DEC,ITDKRC
      REAL*8            XK0DEC
      COMMON /NEWMOD/  AMNEUT,NNEUT
      REAL*8           AMNEUT
      COMMON / KBREMS / KBRINI,KBRFIN,KBRINT
      REAL*4   PB1(4),EE1(3),PB2(4),EE2(3),XPAR(40)
      INTEGER  NPAR(40)
      REAL*4   POL1(4),POL2(4)
C
      IF(MODE.EQ.-1) THEN
C ================================================    INITIALISATIONS
C
        IEVEN = 0
C
C  DECODE INPUT PARAMETERS SET BY DATA CARDS
C  -----------------------------------------
        ISPIN = NPAR(1)
        INRAN = NPAR(2)
        KEYGSW= NPAR(3)
        IF (NPAR(4).NE.2) THEN
          KEYRAD= NPAR(4)
          KBRINI= 1
          KBRFIN= 1
          KBRINT= 1
        ELSE
          KEYRAD= 1
          KBRINI= 1
          KBRFIN= 1
          KBRINT= 0
        ENDIF
        JAK1  = NPAR(5)
        JAK2  = NPAR(6)
        ITFIN = NPAR(7)
        ITDKRC= NPAR(8)
        KEYWLB= NPAR(9)
        KEYYFS= NPAR(12)
        AMZ   = DBLE(XPAR(1))
        AMH   = DBLE(XPAR(2))
        AMTOP = DBLE(XPAR(3))
C
C         W-BOSON COUPLINGS TO FINAL STATE TAU (IN DECAY) FROM INPUT
          GV=XPAR( 4)
          GA=XPAR( 5)
C         TAUNEUTRINO MASS FROM INPUT
          AMNUTA= XPAR(8)
C         SOFT/HARD BREMMSTRAHLUNG CUT in tau decay FROM INPUT
          XK0DEC= XPAR(14)
      IF(ITFIN.EQ.3) THEN
C       Initialization related  to nu nubar option only
        NNEUT=NPAR(11)
        AMNEUT=XPAR( 9)
        ENDIF
C
      IF(ITFIN.GT.500) THEN
C       Initialization related  to quark option only
        AMNEUT=XPAR( 9)
        ENDIF
C
        IF(KEYGSW.LE.1) THEN
C         INITIALISE SIN2W AND Z WIDTH IF NOT RECOMPUTED
          SWSQ  =DBLE(XPAR(6))
          GAMMZ =DBLE(XPAR(7))
        ENDIF
C
C       INITIALISATION OF QED RAD. CORR.
C**     SOFT/HARD BREMMSTRAHLUNG CUT
        XK0   =XPAR(11)
C**     DEFINITION OF EXTRA PARAMETERS FOR EXPAND
        VVMIN =XPAR(12)
        VVMAX =XPAR(13)
C
C PRINT INPUT PARAMETERS
C ----------------------
        WRITE(IOUT,7000) KF1,KF2,PB1(3),PB1(4),PB2(3),PB2(4),
     &  EE1(3),EE2(3)
        WRITE(IOUT,7001) ISPIN,KEYGSW,KEYRAD+1-KBRINT,
     &  JAK1,JAK2,ITFIN,ITDKRC,KEYWLB,NNEUT
        WRITE(IOUT,7002) AMZ,AMH,AMTOP,
     &  GV,GA,AMNUTA,XK0DEC,
     &  XK0,VVMIN,VVMAX,AMNEUT
C
C CHECK INPUT PARAMETERS
C ----------------------
C*MWG*  BEAM IDENTIFIERS KF1=11,-11 DENOTE  ELECTRON, POSITRON
        IF(IABS(KF1).NE.11.OR.IABS(KF2).NE.11)        GOTO 900
        IF(KF1*KF2.GT.0)                              GOTO 900
        SUMPT=0
        DO 20 I=1,2
        SUMPT=SUMPT+PB1(I)
  20    SUMPT=SUMPT+PB2(I)
        IF(SUMPT.GT.0.0001)                           GOTO 902
        IF (     PB1(3) .NE. ABS(PB1(4))
     &  .OR. ABS(PB2(3)).NE. ABS(PB2(4))
     &  .OR.PB1(4).NE.PB2(4).OR.PB1(3).NE.(-PB2(3)) ) GOTO 903
        IF(PB1(4).LE.0)                               GOTO 903
C**     POLARISATION VECTORS OF BEAMS
        IF (EE1(3)*EE2(3).LT.-.5D0) THEN
          WRITE(IOUT,101)
  101     FORMAT('WARNING: PROGRAM IS NOT COMPLETELY O(ALPHA) FOR
     $    STRONGLY POLARIZED E+ AND E-')
        ENDIF
        SUMPT=0
        DO 25 I=1,2
        SUMPT=SUMPT+ ABS(EE1(I))
  25    SUMPT=SUMPT+ ABS(EE2(I))
        IF(SUMPT.GT.1D-8)                             GOTO 904
        IF( ABS(EE1(3)).GT.1.OR. ABS(EE2(3)).GT.1)    GOTO 904
C
C**     SWITCHES
        IF(KEYRAD.GT.9.AND.KEYGSW.EQ.3)               GOTO 905
        IF(KEYRAD.GT.2.AND.KEYRAD.LT.10)              GOTO 905
        IF(KEYRAD.EQ.10)                              GOTO 911
        IF(KEYGSW.LT.-1.OR.KEYGSW.GT.4)               GOTO 905
        IF(KEYGSW.EQ.2 .OR.KEYGSW.EQ.3)               GOTO 905
        IF(KEYGSW.EQ.0.AND.KEYWLB.EQ.2)               GOTO 913
        IF(KEYWLB.NE.1.AND.KEYWLB.NE.2)               GOTO 905
C
        IF(ISPIN.LT.0.OR.ISPIN.GT.1)                  GOTO 906
Change KMO start
        IF (ITFIN .LE. 500 .OR. ITFIN .GT. 506) THEN
          IF(ITFIN.EQ.0.OR.ITFIN.GT.4)                GOTO 907
        END IF
Change KMO end
C
C**     CUT OFF VALUES
        IF(KEYRAD.LE.1.AND.VVMAX.GT.1.D0)             GOTO 908
        IF(KEYRAD.LE.1.AND.XK0.LT..0005D0)            GOTO 908
      IF(ITFIN.EQ.1.AND.ITDKRC.NE.0.AND.XK0DEC.LT..00049D0)   GOTO 909
        IF(ITFIN.EQ.3.AND.KEYWLB.NE.1)                GOTO 910
        IF(ITFIN.GT.9.AND.KEYWLB.NE.1)                GOTO 910
        IF((ITFIN.GT.2).and.(itfin.ne.4)
     $               .AND.KEYYFS.NE.1000001.AND.KEYRAD.GT.10) GOTO 916
        IF(ITFIN.EQ.3.AND.AMNEUT.LT.0.08.AND.VVMAX.GT.0.9999) GOTO 917
C -------------------------------------------------------------------
C INITIALISE MASSES OF STABLE PARTICLES
C
        CALL INIMAS
C
C -------------------------------------------------------------------
C INITIALISE BEAM AND FINAL STATE PARAMETERS
C
        CALL INIREA (KF1,PB1,EE1,KF2,PB2,EE2,ITFIN)
C
C -------------------------------------------------------------------
C INITIALISE PHYSICAL CONSTANTS AND RAD.CORR. PARAMETERS
C
        CALL INIPHY
C INITIALIZE PHOTOS
        CALL PHOINI
        CALL INIPHX(XK0DEC)
C
C PRINT SOME PARAMETERS SET PRIOR TO THIS POINT
        WRITE(IOUT,7005) GAMMZ,AMW,SWSQ,AMFIN
        IF(DABS(SWSQ).GT.1D0) GOTO 905
C
C -------------------------------------------------------------------
C INITIALISATION OF TAU DECAY PACKAGE TAUOLA
C
        IF(ITFIN.EQ.1) THEN
          np1=3
          np2=4
          CALL INITDK
        ENDIF
C
C -------------------------------------------------------------------
C INITIALISE EVENTx
C
        CALL EVENTZ(-1,KEYYFS)
C
C --------------------------------------------------------------------
C
      ELSEIF(MODE.EQ.0) THEN
C ================================================    LOOP OVER EVENTS
C
        IEVEN=IEVEN+1
C --------------------------------------------------------------------
C FERMION PAIR PRODUCTION PROCESS
C
        CALL EVENTZ(0,KEYYFS)
C
C --------------------------------------------------------------------
C*MWG*  FILLING HEPEVT RECORD WITH BEAMS FERMIONS AND PHOTON  (ZTOHEP)
C
        DO 125 I=1,4
        POL1(I)=0
 125    POL2(I)=0
        CALL ZTOHEP
C*MWG*
C --------------------------------------------------------------------
C SPIN ASSIGNMENTS
        IF(ISPIN.NE.0) THEN
          CALL SPIGEN(POL1,POL2)
          HELT1= POL1(3)
          HELT2=-POL2(3)
        ENDIF
C
C --------------------------------------------------------------------
C TAU DECAYS
        IF(ITFIN .EQ. 1) THEN
          KTO=1
          CALL DEXAY(KTO,POL1)
          KTO=2
          CALL DEXAY(KTO,POL2)
        IF (ITDKRC.EQ.1) THEN
         CALL PHOTOS(3)
         CALL PHOTOS(4)
        ENDIF
        ENDIF
C
C --------------------------------------------------------------------
C
      ELSEIF(MODE.EQ.1) THEN
C ================================================    FINAL STATISTICS
C
C CALCULATE TOTAL CROSS SECTION
        CALL EVENTZ(1,KEYYFS)
        CSTNB= CSTCM*1.E33
        DCSNB= ERREL*CSTNB
        NPAR(10)=IEVEN
C ZW here input parameters were overwritten 4.06.89
        XPAR(10)=CSTCM
        XPAR(16)=CSTCM
        XPAR(17)=CSTNB
        XPAR(18)=DCSNB
C
C --------------------------------------------------------------------
C CALCULATE tau PARTIAL DECAY WIDTHS
        IF(ITFIN.EQ.1) THEN
          CALL DEXAY(100,POL1)
          DO 180 I=1,19
 180      XPAR(20+I)= GAMPMC(I)
        ENDIF
C
C --------------------------------------------------------------------
C FINAL REPORT
        WRITE(IOUT,7010) IEVEN,CSTNB,DCSNB,ERREL
C
C --------------------------------------------------------------------
      ELSE
C ======================================================= ILLEGAL MODE
        GOTO 901
      ENDIF
C     =====
C
      RETURN
C
  900 WRITE(IOUT,9900)
 9900 FORMAT(' KORALZ: NONSENSE VALUE OF BEAM IDENTIFIER')
      STOP
  901 WRITE(IOUT,9901)
 9901 FORMAT(' KORALZ: NONSENSE VALUE OF MODE ')
      STOP
  902 WRITE(IOUT,9902)
 9902 FORMAT(' KORALZ: NO TRANSV. MOM. ALLOWED FOR BEAMS ')
      STOP
  903 WRITE(IOUT,9903)
 9903 FORMAT(' KORALZ: SOME WRONG BEAM MOM. COMPONENT    ',/,
     $ 'TO FLIP BEAM DIRECTIONS USE KF1, KF2: BEAM IDENTIFIERS')
      STOP
  904 WRITE(IOUT,9904)
 9904 FORMAT(' KORALZ: WRONG BEAM POLARIZATION ')
      STOP
  905 WRITE(IOUT,9905)
 9905 FORMAT(' KORALZ: BAD KEYGSW OR KEYRAD OR KEYWLB ')
      STOP
  906 WRITE(IOUT,9906)
 9906 FORMAT(' KORALZ: BAD ISPIN ')
      STOP
  907 WRITE(IOUT,9907)
 9907 FORMAT(' KORALZ: BAD ITFIN ')
      STOP
  908 WRITE(IOUT,9908)
 9908 FORMAT(' KORALZ: XK0 AND/OR VVMAX OUT OF RANGE FOR CHOSEN KEYRAD')
      STOP
  909 WRITE(IOUT,9909) XK0DEC
 9909 FORMAT(' KORALZ: XK0DEC OUT OF RANGE ',E10.5)
      STOP
  910 WRITE(IOUT,9910)
 9910 FORMAT('KORALZ: combination of ITFIN and KEYWLB not yet possibl.')
      STOP
  913 WRITE(IOUT,9913)
 9913 FORMAT(' KORALZ: Wrong value of NPR(9)=KEYWLB ')
      STOP
  911 WRITE(IOUT,9911) KEYRAD
 9911 FORMAT('KORALZ: Obsolete value of KEYRAD=',I3, // ,' in KORALZ ',
     $'documentation Comp Phys. Comm. 1994 this explanation is missing')
      STOP
  916 WRITE(IOUT,9916)
 9916 FORMAT
     $ (' KORALZ: Wrong combination  of NPR(12)=KEYYFS, NPR(7)=ITFIN ')
      STOP
 917  WRITE(IOUT,9917)
 9917 FORMAT
     $ (' KORALZ: Classical chaos danger, unlucky combinantion of: ',
     $  ' XPR(9)=AMNEUT, NPR(7)=ITFIN, XPR(13)=VVMAX ')
      STOP
C
 7000 FORMAT(///1X,15(5HKKKKK)
     $ /,' K',     25X,'======== KORALZ VERSION 4.02 ==========',9X,1HK
     $ /,' K',     25X,'== Published in Comp Phys Comm (94) ===',9X,1HK
     $ /,' K',     25X,'=last registerd corrections Oct 12, 95=',9X,1HK
     $ /,' K',     25X,'==Authors: S. Jadach, B. Ward =========',9X,1HK
     $ /,' K',     25X,'==========      Z. Was        =========',9X,1HK
     $ /,' K',     25X,'=========== INPUT PARAMETERS ==========',9X,1HK
     $ /,' K',I20  ,5X,'KF1    =  FIRST BEAM IDENTIFIER        ',9X,1HK
     $ /,' K',I20  ,5X,'KF2    =  SECOND BEAM IDENTIFIER       ',9X,1HK
     $ /,' K',     25X,'==== FOUR MOMENTA OF THE BEAMS ========',9X,1HK
     $ /,' K',F20.9,5X,'PB1(3) =  FIRST BEAM, 3-RD COMPONENT   ',9X,1HK
     $ /,' K',F20.9,5X,'PB1(4) =              0-TH COMPONENT   ',9X,1HK
     $ /,' K',F20.9,5X,'PB2(3) = SECOND BEAM, 3-RD COMPONENT   ',9X,1HK
     $ /,' K',F20.9,5X,'PB2(4) =              0-TH COMPONENT   ',9X,1HK
     $ /,' K',     25X,'==== SPIN VECTORS OF THE BEAMS ========',9X,1HK
     $ /,' K',F20.9,5X,'E1(3)  =  FIRST BEAM, 3-RD COMPONENT   ',9X,1HK
     $ /,' K',F20.9,5X,'E2(3)  = SECOND BEAM  3-RD COMPONENT   ',9X,1HK)
 7001 FORMAT(
     $   ' K',     25X,'====== INPUT PARAMS IN NPAR ===========',9X,1HK
     $ /,' K',I20  ,5X,'ISPIN    =  SPIN EFFECTS SWITCH        ',9X,1HK
     $ /,' K',I20  ,5X,'KEYGSW   =  GSW IMPLEMENTATION LEVEL   ',9X,1HK
     $ /,' K',I20  ,5X,'KEYRAD   =  BREMSSTRAHLUNG   SWITCH    ',9X,1HK
     $ /,' K',I20  ,5X,'JAK1     =  DECAY TYPE FIRST  TAU      ',9X,1HK
     $ /,' K',I20  ,5X,'JAK2     =  DECAY TYPE SECOND TAU      ',9X,1HK
     $ /,' K',I20  ,5X,'ITFIN    =  TAU/MUON ...  PROD. SWITCH ',9X,1HK
     $ /,' K',I20  ,5X,'ITDKRC   =  SWITCH FOR RC IN TAU DECAY ',9X,1HK
     $ /,' K',I20  ,5X,'KEYWLB   =  type of electroweak library',9X,1HK
     $ /,' K',I20  ,5X,'NNEUT    =  number of neutrinos (nunu) ',9X,1HK)
 7002 FORMAT(
     $   ' K',     25X,'====== INPUT PARAMS IN XPAR ===========',9X,1HK
     $ /,' K',F20.9,5X,'AMZ  = MASS OF Z0 BOSON                ',9X,1HK
     $ /,' K',F20.9,5X,'AMH  = MASS OF HIGGS BOSON             ',9X,1HK
     $ /,' K',F20.9,5X,'AMTOP= MASS OF TOP QUARK               ',9X,1HK
     $ /,' K',F20.9,5X,'GV   = VECTOR COUPLING CONST. IN DECAY ',9X,1HK
     $ /,' K',F20.9,5X,'GA   = AXIAL  COUPLING CONST. IN DECAY ',9X,1HK
     $ /,' K',F20.9,5X,'AMNUTA= MASS OF TAU-NEUTRINO  IN DECAY ',9X,1HK
     $ /,' K',F20.9,5X,'XK0DEC= SOFT PHOTON CUTOFF IN TAU DEC. ',9X,1HK
     $ /,' K',F20.9,5X,'XK0   = SOFT PHOTON CUT OFF            ',9X,1HK
     $ /,' K',F20.9,5X,'VVMIN = MIN.VAL. OF V PARAM. IN YFS    ',9X,1HK
     $ /,' K',F20.9,5X,'VVMAX = MAX.VAL. OF V PARAM. IN YFS    ',9X,1HK
     $ /,' K',F20.9,5X,'AMNEUT= neutrino (quark) f. state mass ',9X,1HK
     $  /,1X,15(5HKKKKK)/)
 7005 FORMAT(///1X,15(5HKKKKK)
     $ /,' K',     25X,'==== OTHER PARAMETERS SET IN KORALZ====',9X,1HK
     $ /,' K',F20.9,5X,'GAMM   =  Z0 BOSON WIDTH, CALCULATED   ',9X,1HK
     $ /,' K',F20.9,5X,'AMW    =  W  BOSON MASS,  CALCULATED   ',9X,1HK
     $ /,' K',F20.9,5X,'SWSQ   =  SIN**2(THETAWEINBERG)        ',9X,1HK
     $ /,' K',F20.9,5X,'AMFIN  =  OUTGOING FERMION MASS        ',9X,1HK
     $  /,1X,15(5HKKKKK)/)
 7010 FORMAT(///1X,15(5HKKKKK)
     $ /,' K',     25X,'======== KORALZ VERSION 4.02 ==========',9X,1HK
     $ /,' K',     25X,'== Published in Comp Phys Comm (94) ===',9X,1HK
     $ /,' K',     25X,'==Authors: S. Jadach, B. Ward =========',9X,1HK
     $ /,' K',     25X,'==========      Z. Was        =========',9X,1HK
     $ /,' K',     25X,'============= FINAL REPORT ============',9X,1HK
     $ /,' K',I20  ,5X,'Number of generated events             ',9X,1HK
     $ /,' K',F20.9,5X,'Total cross sections in nanobarns      ',9X,1HK
     $ /,' K',F20.9,5X,'Absolute error                         ',9X,1HK
     $ /,' K',F20.9,5X,'Relative error                         ',9X,1HK
     $ /,1X,15(5HKKKKK)/)
      END
      SUBROUTINE ZTOHEP
C ----------------------------------------------------------------------
C
C Koral-Z to HEPEVT
C
C this routine fills the HEPEVT common block
C with event kinematics from Koral-Z:
C *  initial beam particles (positions 1,2)
C *  primary fermions of final state (3,4)
C *  radiative photons (IF NPHOTA>0) (5...4+NPHOTA)
C
C WRITTEN BY MARTIN W. GRUENEWALD AND Z. WAS (91/02/02)
C
C called by KORAL-Z
C
C ----------------------------------------------------------------------
C
      COMMON / MOMSE4 / AQF1(4),AQF2(4),ASPHUM(4),ASPHOT(100,4),NPHOTA
      REAL*4            AQF1   ,AQF2   ,ASPHUM   ,ASPHOT
      COMMON / BEAMS / XPB1(4),XPB2(4),KFB1,KFB2
      REAL*4           XPB1   ,XPB2
      COMMON / BEAMPM / ENE ,AMIN,AMFIN,IDE,IDF
      REAL*8            ENE ,AMIN,AMFIN
      COMMON / IDFC  / IDFF
C
      REAL*4 APH(4),AM
C
C initial state (1,2)
      AM=AMIN
      CALL FILHEP(1,3,KFB1,0,0,0,0,XPB1,AM,.TRUE.)
      CALL FILHEP(2,3,KFB2,0,0,0,0,XPB2,AM,.TRUE.)
C
C primary final state fermions (3,4)
      AM=AMFIN
      CALL FILHEP(3,1, IDFF,1,2,0,0,AQF1,AM,.TRUE.)
      CALL FILHEP(4,1,-IDFF,1,2,0,0,AQF2,AM,.TRUE.)
C
C radiative photons (5...4+NPHOTA) (PDG-code for gamma is 22)
      IF(NPHOTA.EQ.0)RETURN
      IP=0
      DO I=1,NPHOTA
        DO J=1,4
          APH(J)=ASPHOT(I,J)
        END DO
        IF (APH(4).GT.0.0) THEN
          IP=IP+1
          CALL FILHEP(4+IP,1,22,1,2,0,0,APH,0.0,.TRUE.)
        END IF
      END DO
C
      RETURN
      END
      SUBROUTINE EVENTZ(MODE,KEYYFS)
C ----------------------------------------------------------------------
C STEERING ROUTINE MAKES A CHOICE BETWEEN MULTIPHOTON AND SINGLE
C (OR ZERO) PHOTON GENERATOR
C
C     called by : KORALZ
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / KEYSET / KEYGSW,KEYRAD,KEYTAB
C
      IF     (KEYRAD.EQ.0.OR.KEYRAD.EQ.1.OR.KEYRAD.EQ.10) THEN
        CALL EVENTM(MODE)
      ELSEIF (KEYRAD.GT.10.AND.KEYRAD.LT.113) THEN
        CALL EVENTE(MODE,KEYYFS)
      ELSE
        PRINT *, 'STOP IN EVENTZ - WRONG KEYRAD'
        STOP
      ENDIF
      END
      SUBROUTINE SPIGEN(POL1,POL2)
C ----------------------------------------------------------------------
C THIS ROUTINE GENERATES TAU SPIN CONFIGURATION
C output arguments :
C POL1,POL2 = tau polarisation
C
C     called by : KORALZ
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / KEYSET / KEYGSW,KEYRAD,KEYTAB
      REAL*4 POL1(4),POL2(4)
      REAL*4 RRR
      DIMENSION SIGM(4)
      DATA  INIT /0/
C
      IF (INIT.EQ.0) THEN
        INIT=1
        DO 20 K=1,4
        POL1(K)=0.0
 20     POL2(K)=0.0
      ENDIF
C CALCULATE RELATIVE WEIGHTS OF TAU SPIN CONFIGURATIONS
      IF (KEYRAD.LT.11) THEN
        SIGM(1)=WEIGHT(1, 1D0, 1D0)
        SIGM(2)=WEIGHT(1,-1D0,-1D0)
        SIGM(3)=WEIGHT(1, 1D0,-1D0)
        SIGM(4)=WEIGHT(1,-1D0, 1D0)
      ELSE
        SIGM(1)=WAGA(1, 1D0, 1D0)
        SIGM(2)=WAGA(1,-1D0,-1D0)
        SIGM(3)=WAGA(1, 1D0,-1D0)
        SIGM(4)=WAGA(1,-1D0, 1D0)
      ENDIF
      XSUM=SIGM(1)+SIGM(2)+SIGM(3)+SIGM(4)
C CHOOSE RANDOMLY SPINS OF TAUS ACCORDING TO CROSS SECTION
      CALL RANMAR(RRR,1)
      R=RRR
      IF(    R.LT. SIGM(1)/XSUM) THEN
        T1= 1D0
        T2= 1D0
      ELSEIF(R.LT.(SIGM(1)+SIGM(2))/XSUM) THEN
        T1=-1D0
        T2=-1D0
      ELSEIF(R.LT.(SIGM(1)+SIGM(2)+SIGM(3))/XSUM) THEN
        T1= 1D0
        T2=-1D0
      ELSE
        T1=-1D0
        T2= 1D0
      ENDIF
      POL1(3)=T1
      POL2(3)=T2
      END
      FUNCTION WAGA(MODE,TA,TB)
C ----------------------------------------------------------------------
C THIS FUNCTION CALCULATES DIFFERENTIAL CROSS SECTION FOR EVERY EVENT
C in multiphoton case (see WEIGHT for single photon mode).
C  INPUT : MODE:
C                 0   FOR CALL FOR RAW CROSS SECTION
C                     NO VAC. POLARIZ & NO GSW &
C                     NO INTERFERENCE INIT - FINAL
C                 1   INITIALIZATION. CORRECT X. SECTION
C                 2   CORRECT X. SECTION
C          TA,TB: TWICE OF TAU+ TAU- HELICITIES
C
C     called by : SPIGEN
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / KEYSET / KEYGSW,KEYRAD,KEYTAB
C
C IF MODE=0 CALCULATION OF ANGULAR VARIABLES FROM 4-MOMENTA
      IF (MODE.EQ.0) THEN
        CALL SKONTY(0,SVAR,CTHE)
      ENDIF
      WAGA=BORNS(MODE,SVAR,CTHE,TA,TB)
      END
      FUNCTION BORNY(SVAR)
C ----------------------------------------------------------------------
C THIS ROUTINE CALCULATES TOTAL BORN CROSS SECTION.
C IT EXPLOITS THE FACT THAT BORN X. SECTION = A + B*C + D*C**2
C
C     called by : BONMA0, BONMA1, EXPAND, BREMKF, VVDIS
C ----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
C
      FL=BORNS(0,SVAR,-1.D0,0.D0,0.D0)
      FR=BORNS(0,SVAR, 1.D0,0.D0,0.D0)
      F0=BORNS(0,SVAR, 0.D0,0.D0,0.D0)
      BORNY=(FL+FR)/8.D0+ F0/2D0
      END
      FUNCTION BORAS(SVAR)
C ----------------------------------------------------------------------
C THIS ROUTINE CALCULATES  BORN ASYMMETRY.
C IT EXPLOITS THE FACT THAT BORN X. SECTION = A + B*C + D*C**2
C
C     called by : EVENTM
C ----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
C
      FL=BORNS(0,SVAR,-1.D0,0.D0,0.D0)
      FR=BORNS(0,SVAR, 1.D0,0.D0,0.D0)
      BORAS=FL/(FL+FR)
      END
      FUNCTION BORNV(SVAR,COSTHE)
C ----------------------------------------------------------------------
C     called by : GCRUDE, GBETA0, GBETA1, GBETA2
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      BORNV=   BORNS(0,SVAR,COSTHE,0D0,0.D0)
      END
      SUBROUTINE TRALO4(KTO,AP,BP,XMP)
C ----------------------------------------------------------------------
* REAL*4 VERSION OF TRALOR
C     Modified AM. Lutz October 1988
C  INPUT PARAMETERS :
C     KTO    : tau number
C     AP     : 4-momentum to be boosted/rotated
C  output parameters
C     BP     : 4-momentum after boost/rotation
C     XMP    : mass corresponding to 4-momentum BP
C              computed in double precision
C
C     called by : DWLUxx
C ----------------------------------------------------------------------
      REAL*4 AP(4),BP(4),XMP
      REAL*8 DP(4),DXMP

C
      DO 30 I=1,4
  30  DP(I)=AP(I)
      CALL TRALOR(KTO,DP,DP)
      DXMP =0D0
      DO 31 I=1,3
      DXMP =DXMP + DP(I)**2
  31  BP(I)=DP(I)
      BP(4)=DP(4)
      DXMP =DP(4)**2-DXMP
C ZW 21.03 TO AVOID AN OVERFLOW WHEN PHOTON MASS IS CALCULATED.
       IF(DXMP.NE.0D0) DXMP=DXMP / DSQRT(DABS(DXMP))
      XMP  =DXMP
      END
      SUBROUTINE TRALOR(KTO,QQ,PP)
C ----------------------------------------------------------------------
C THIS TRANSFORMS FROM FINAL FERMION REST FRAME TO LAB CMS
C KTO=1 FOR QP, KTO=2 FOR QM
C ADDITIONAL PARAMETER, NOW FROZEN AS DATA, >MODE< IF PUT TO ZERO
C SHORTENS THE TRANSFORMATION TREE. FOR MODE.NE.1, TRANSFORMATION
C GOES FROM THE REST FRAME OF THE FINAL STATE FERMION PAIR TO LAB.
C IT IS RECCOMENDED TO USE WHEN THE PROGRAM IS INTERFACED WITH THE
C QUARK FRAGMENTATION AND/OR Q-ONIA DECAY PROGRAMS.
C
C     called by : TRALO4, EVENTM
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / BEAMPM / ENE ,AMIN,AMFIN,IDE,IDF
      REAL*8            ENE ,AMIN,AMFIN
      COMMON / KEYSET / KEYGSW,KEYRAD,KEYTAB
      COMMON / UTIL2 /  XK,C,S,CG,SG
      COMMON / UTIL3 / FIG,FI,IT,IBREM
      REAL*8 PP(4),QQ(4)
      DATA PI /3.141592653589793238462643D0/
      DATA MODE /1/
      IF(KEYRAD.LE.10) THEN
C       SINGLE PHOTON CASE
        CALL TRASNG(MODE,ENE,AMFIN,AMEL,KTO,QQ,PP)
      ELSE
C       MULTIPLE PHOTON CASE
        DO 7 K=1,4
 7      PP(K)=QQ(K)
        CALL TRAMLT(MODE,KTO,PP)
      ENDIF
C     =====
      END
      SUBROUTINE TRAMLT(MODE,KTO,VEC)
C ----------------------------------------------------------------------
C     *   MULTIPHOTON KINEMATICAL TREE
C
C     called by : TRALOR
C ----------------------------------------------------------------------
C
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / KEYYFS / KEYZET,KEYBRM,KEYFIX,KEYRED,KEYWGT
      COMMON / KEYSET / KEYGSW,KEYRAD,KEYTAB
      COMMON / MOMSET / QF1(4),QF2(4),SPHUM(4),SPHOT(100,4),NPHOT
      COMMON / BEAMPM / ENE ,AMIN,AMFIN,IDE,IDF
      REAL*8            ENE ,AMIN,AMFIN
      DIMENSION VEC(4),PPB(4),PMB(4),PP(4),QQ(4)
      PARAMETER(ISWITH=1000001)
C
      DO 8 K=1,4
  8   QQ(K)=VEC(K)
      IF ((KEYRAD.EQ.12)) THEN
C       relax
      ELSE
        CALL BDRESS(1,PPB,PMB,SVARX,CTHE)
        EBEAM=SQRT(SVARX)/2D0
      ENDIF
      CALL TRASNG(MODE,EBEAM,AMFIN,AMIN,KTO,QQ,PP)
      CALL TRALOZ(1,-1,2D0*ENE  ,SPHUM,PPB,PMB,PP  ,QQ  )
C
      DO 9 L=1,4
  9   VEC(L)=QQ(L)
      END
      SUBROUTINE TRALOZ(INIT,MOD,CMSENE,PHSUM,PPB,PMB,QVEC,PVEC)
C ----------------------------------------------------------------------
C CALLED IN EVENTE
C TRANSFORMS FROM CMS TO VIRTUAL Z0 (GAMMA) REST FRAME
C FORTH (MODE= 1) OR BACK (MODE=-1)
C IN FINAL   SYSTEM Z-AXIS PARALLEL TO DRESSED POSITRON BEAM
C
C     called by : PEDYVV, TRAMLT, EVENTE
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER(ISWITH=1000001)
      REAL*8 PVEC(4),QVEC(4),PHSUM(4)
      REAL*8 PPB(4),PMB(4)
      COMMON / VVREK  / VVMIN,VVMAX,VV,BETI
      REAL*8            VVMIN,VVMAX,VV,BETI
      COMMON / KEYYFS / KEYZET,KEYBRM,KEYFIX,KEYRED,KEYWGT
      COMMON / KEYSET / KEYGSW,KEYRAD,KEYTAB
      IF (KEYRAD.EQ.12) THEN
          DO K=1,4
             PVEC(K)=QVEC(K)
          ENDDO
      ELSE
       CALL TRALOO(INIT,MOD,CMSENE,PHSUM,PPB,PMB,QVEC,PVEC)
      ENDIF
C       note that TRALOO is identical to
C       old TRALOZ backward compatible to KORALZ 3.8 may be removed
C       later after comparison tests. It cannot be used for the
C       YFS3 generating final bremsstrahlung.
      END
      SUBROUTINE TRALOO(INIT,MOD,CMSENE,PHSUM,PPB,PMB,QVEC,PVEC)
C ----------------------------------------------------------------------
C CALLED IN EVENTE
C TRANSFORMS FROM CMS TO VIRTUAL Z0 (GAMMA) REST FRAME
C FORTH (MODE= 1) OR BACK (MODE=-1)
C IN FINAL   SYSTEM Z-AXIS PARALLEL TO DRESSED POSITRON BEAM
C
C     called by : PEDYVV, TRAMLT, EVENTE
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      REAL*8 PVEC(4),QVEC(4),PHSUM(4),QSU(4)
      REAL*8 PPB(4),PMB(4),PPBT(4),PMBT(4)
      COMMON / VVREK  / VVMIN,VVMAX,VV,BETI
      REAL*8            VVMIN,VVMAX,VV,BETI
C
C ----------------------------------------------------------------------
C INITIALIZATION
      IF (INIT.EQ.0) THEN
        NPH=0
        IF (PHSUM(4).GT.VVMIN*CMSENE/2D0) THEN
C       ======================================
C
          NPH=1
          DO 10 K=1,4
          PPBT(K)=PPB(K)
          PMBT(K)=PMB(K)
   10     PVEC(K)=QVEC(K)
          CALL GIQSU(CMSENE,PHSUM,QSU)
          QSM =SQRT(QSU(4)**2-QSU(3)**2-QSU(2)**2-QSU(1)**2)
          EXE =(QSU(4)+SQRT(QSU(3)**2+QSU(2)**2+QSU(1)**2))/QSM
          FI   =ANGFI(QSU(1),QSU(2))
          TH1  =ANGXY(QSU(3),SQRT(QSU(1)**2+QSU(2)**2))
          CALL ROTOD3(    -FI,PPBT,PPBT)
          CALL ROTOD2(   -TH1,PPBT,PPBT)
          CALL BOSTD3(1D0/EXE,PPBT,PPBT)
          TH2  =-ANGXY(PPBT(3),SQRT(PPBT(1)**2+PPBT(2)**2))
C
        ENDIF
C       =====
      ENDIF
C ----------------------------------------------------------------------
C
C TRANSFORMATION
      DO 12 K=1,4
  12  PVEC(K)=QVEC(K)
      IF (NPH.EQ.1) THEN
C     ==================
        IF(    MOD.EQ.-1) THEN
          CALL ROTOD2(    TH2,PVEC,PVEC)
          CALL BOSTD3(    EXE,PVEC,PVEC)
          CALL ROTOD2(    TH1,PVEC,PVEC)
          CALL ROTOD3(     FI,PVEC,PVEC)
        ELSEIF(MOD.EQ. 1) THEN
          CALL ROTOD3(    -FI,PVEC,PVEC)
          CALL ROTOD2(   -TH1,PVEC,PVEC)
          CALL BOSTD3(1D0/EXE,PVEC,PVEC)
          CALL ROTOD2(   -TH2,PVEC,PVEC)
        ENDIF
C
      ELSE
C     ====
C
        DO 11 K=1,4
   11   PVEC(K)=QVEC(K)
C
      ENDIF
C     =====
C
      END
      SUBROUTINE TRASNG(MODE,ENE,AMFIN,AMEL,KTO,QQ,PP)
C ----------------------------------------------------------------------
C THIS TRANSFORMS FROM FINAL FERMION REST FRAME TO LAB CMS
C (OR Z0-GAMMA REST FRAME WHEN USED FOR MULTIPHOTON GENERATION)
C KTO=1 FOR QP, KTO=2 FOR QM
C SINGLE PHOTON KINEMATICAL TREE. IT IS USED FOR THE SINGLE
C OR NO PHOTON TRANSFORMATION, EITHER IN THE SINGLE BREM. MODE
C OR FOR THE FINAL STATE BREMSSTRAHLUNG BRANCH OF THE MULTIPHOTON
C GENERATION.
C
C     CALLED BY : TRAMLT, EVENTE,TRALOR
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER(ISWITH=1000001)
      COMMON / KEYYFS / KEYZET,KEYBRM,KEYFIX,KEYRED,KEYWGT
      COMMON / KEYSET / KEYGSW,KEYRAD,KEYTAB
      REAL*8 PP(4),QQ(4)
      IF (KEYRAD.EQ.12) THEN
          CALL TRANSF(KTO,QQ,PP)
      ELSE
        CALL TRASNO(MODE,ENE,AMFIN,AMEL,KTO,QQ,PP)
      ENDIF
C       note that TRASNO is identical to old TRASNG
C       old TRASNG backward compatible to KORALZ 3.8 may be removed
C       later after comparison tests. It cannot be used for the
C       YFS3 generating final bremsstrahlung.
      END
      SUBROUTINE TRANSF(KTO,QQ,PP)
C new transformation routine to be used when YFS3 with final state
C bremsstrahlung is in use.
      IMPLICIT REAL*8(A-H,O-Z)
      REAL*8 PP(4),QQ(4),RR(4),ZMS(4),F1(4),F2(4),SS(4),F0(4)
      COMMON / MOMSET / QF1(4),QF2(4),SPHUM(4),SPHOT(100,4),NPHOT
C      COMMON / MOMINI / XF1(4),XF2(4),XPHUM(4),XPHOT(100,4),NPHOX
      DATA PI /3.141592653589793238462643D0/
      DO KK=1,4
        ZMS(KK)=QF1(KK)+QF2(KK)
         F0(KK)=0.D0
      ENDDO
      IF(KTO.EQ.1) THEN
         CALL BOSTDQ( 1,ZMS,QF1,F1)
          F0(4)=F1(4)
          F0(3)= SQRT(F1(1)**2+F1(2)**2+F1(3)**2)
            FI=ANGFI(F1(1),F1(2))
          TH=ANGXY(F1(3),SQRT(F1(1)**2+F1(2)**2))
         CALL BOSTDQ(-1, F0, QQ,SS)
          CALL ROTOD2( TH,SS,SS)
          CALL ROTOD3( FI,SS,RR)
         CALL BOSTDQ(-1,ZMS, RR,PP)
      ELSE
         CALL ROTOD1(PI,QQ,SS)
         CALL BOSTDQ( 1,ZMS,QF2,F2)
          F0(4)=F2(4)
          F0(3)=SQRT(F2(1)**2+F2(2)**2+F2(3)**2)
          FI=ANGFI( F2(1), F2(2))
          TH=ANGXY( F2(3),SQRT(F2(1)**2+F2(2)**2))
         CALL BOSTDQ(-1, F0, SS,RR)
          CALL ROTOD2( TH,RR,RR)
          CALL ROTOD3( FI,RR,RR)
         CALL BOSTDQ(-1,ZMS, RR,PP)
      ENDIF
      END
      SUBROUTINE TRASNO(MODE,ENE,AMFIN,AMEL,KTO,QQ,PP)
C ----------------------------------------------------------------------
C THIS TRANSFORMS FROM FINAL FERMION REST FRAME TO LAB CMS
C (OR Z0-GAMMA REST FRAME WHEN USED FOR MULTIPHOTON GENERATION)
C KTO=1 FOR QP, KTO=2 FOR QM
C SINGLE PHOTON KINEMATICAL TREE. IT IS USED FOR THE SINGLE
C OR NO PHOTON TRANSFORMATION, EITHER IN THE SINGLE BREM. MODE
C OR FOR THE FINAL STATE BREMSSTRAHLUNG BRANCH OF THE MULTIPHOTON
C GENERATION.
C
C     CALLED BY : TRAMLT, EVENTE,TRALOR
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / UTIL2 /  XK,C,S,CG,SG
      COMMON / UTIL3 / FIG,FI,IT,IBREM
      REAL*8 PP(4),QQ(4)
      DATA PI /3.141592653589793238462643D0/

        IF(IT.EQ.3) THEN
          BET=SQRT(1-AMFIN**2/ENE**2)
          EXF=(1+BET)/SQRT(AMFIN**2/ENE**2)
        ELSE
          BET=1-AMFIN**2/(1-XK)/ENE**2
          IF(BET.LT.0D0) BET=0D0
          BET=SQRT(BET)
          EXF=(1+BET)/SQRT(AMFIN**2/(1-XK)/ENE**2)
        ENDIF
C
        IF (MODE.EQ.1) THEN
C TRANSFORMATION FROM THE TAU REST FRAME TO THE TAU-TAU SYSTEM
          IF(KTO.EQ.1) CALL ROTOD2(0D0,QQ,PP)
          IF(KTO.EQ.2) CALL ROTOD2( PI,QQ,PP)
C
          CALL BOSTD3( EXF,PP,PP)
          IF(KTO.EQ.2) CALL ROTOD2( PI,PP,PP)
        ENDIF
C
        IF(IT.EQ.1) THEN
          TH1=ANGXY(CG,SG)
          EXE=  SQRT(1-XK)
          TH2=ANGXY(C,S)
          IF(IBREM.EQ.1) THEN
            THR =ANGXY( XK+(2-XK)*CG , 2*SQRT(1-XK)*SG )
            CALL TRALOI( FI, TH1,EXE,-THR, FIG, TH2,PP)
          ELSE
            THR =ANGXY( XK-(2-XK)*CG , 2*SQRT(1-XK)*SG )
            CALL TRALOI( FI, TH1,EXE,-PI+THR, FIG,-TH2,PP)
          ENDIF
C
        ELSEIF(IT.EQ.2) THEN
          TH=ANGXY(C,S)
          EXE=  SQRT(1-XK)
          THG=ANGXY(CG,SG)
          BET=SQRT(1-AMFIN**2/ENE**2/(1-XK))
          IF(IBREM.EQ.1) THEN
            THR=ANGXY( 2*CG*BET-XK*CG*BET-XK ,2*SQRT(1-XK)*SG*BET )
            CALL TRALOF( FI,  TH, FIG, THR,EXE,-THG,PP)
          ELSE
            THR=ANGXY(-2*CG*BET+XK*CG*BET-XK ,2*SQRT(1-XK)*SG*BET )
            CALL TRALOF( FI,  TH,-FIG,-PI+THR,EXE, THG,PP)
          ENDIF
        ELSE
          TH=ANGXY(C,S)
          CALL ROTOD1(-TH,PP,PP)
          CALL ROTOD3(-FI,PP,PP)
        ENDIF
      END
      SUBROUTINE TRALOI(FI,TH1,EX,THR,PSI,TH2,PVEC)
C ----------------------------------------------------------------------
C     INITIAL  STATE RADIATION BRANCH
C
C       CALLED BY : TRASNG
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      REAL*8 PVEC(4)
C
      CALL ROTOD2( TH2,PVEC,PVEC)
      CALL ROTOD3( PSI,PVEC,PVEC)
      CALL ROTOD2( THR,PVEC,PVEC)
      CALL BOSTD3(  EX,PVEC,PVEC)
      CALL ROTOD2( TH1,PVEC,PVEC)
      CALL ROTOD3(  FI,PVEC,PVEC)
      END
      SUBROUTINE TRALOF(FI,TH1,FI2,THR,EX,THG,PVEC)
C ----------------------------------------------------------------------
C     FINAL  STATE RADIATION BRANCH
C
C       CALLED BY : TRASNG
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      REAL*8 PVEC(4)
C
      CALL ROTOD2( THG,PVEC,PVEC)
      CALL BOSTD3(  EX,PVEC,PVEC)
      CALL ROTOD2( THR,PVEC,PVEC)
      CALL ROTOD3( FI2,PVEC,PVEC)
      CALL ROTOD2( TH1,PVEC,PVEC)
      CALL ROTOD3(  FI,PVEC,PVEC)
      END
      SUBROUTINE EVENTM(MODE)
C ----------------------------------------------------------------------
C SINGLE PHOTON GENERATOR
C
C     called by : EVENTZ
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / BEAMPM / ENE ,AMIN,AMFIN,IDE,IDF
      REAL*8            ENE ,AMIN,AMFIN
      COMMON / QEDPRM /ALFINV,ALFPI,XK0
      REAL*8           ALFINV,ALFPI,XK0
      COMMON / GAUSPM /SS,POLN,T3E,QE,T3F,QF
     &                ,XUPGI   ,XUPZI   ,XUPGF   ,XUPZF
     &                ,NDIAG0,NDIAGA,KEYA,KEYZ
     &                ,ITCE,JTCE,ITCF,JTCF,KOLOR
      REAL*8           SS,POLN,T3E,QE,T3F,QF
     &                ,XUPGI(2),XUPZI(2),XUPGF(2),XUPZF(2)
      COMMON / FINUS / CSTCM,ERREL
      REAL*8           CSTCM,ERREL
      COMMON / UTIL2 /  XK,C,S,CG,SG
      COMMON / UTIL3 / FIG,FI,IT,IBREM
      COMMON / UTIL4 / AQP(4),AQM(4),APH(4)
      REAL*4           AQP   ,AQM   ,APH
      COMMON / UTIL8 / QP(4),QM(4),PH(4)
      REAL*8           QP   ,QM   ,PH
      COMMON / VVREK  / VVMIN,VVMAX,VV,BETI
      REAL*8            VVMIN,VVMAX,VV,BETI
      COMMON / MOMSET / QF1(4),QF2(4),SPHUM(4),SPHOT(100,4),NPHOT
      COMMON / MOMSE4 / AQF1(4),AQF2(4),ASPHUM(4),ASPHOT(100,4),NPHOTA
      REAL*4            AQF1   ,AQF2   ,ASPHUM   ,ASPHOT
      COMMON / KEYSET / KEYGSW,KEYRAD,KEYTAB
      REAL*8 SWT(3)
      REAL*4 RRR(4)
      COMMON / KBREMS / KBRINI,KBRFIN,KBRINT
      DATA CMTR /389.385D-30/
C
C GENERATION OF THE PHOTON MOMENTUM XK AND DECISION ABOUT THE
C TYPE OF THE RADIATION  IT=1,2,3 CORRESPONDS TO INITIAL STATE
C RADIATION, FINAL STATE RADIATION AND SOFT PHOTON (XK.LT.XK0)
C RADIATION
C
      IF (MODE.EQ.-1) THEN
C     INITIALIZATION IN EVENTM
C     ====================
CAM     VVMIN =1D-5
CAM     VVMAX =1D0
        DO 15 K=1,3
  15    SWT(K)=0.D0
        PI=4.D0*DATAN(1.D0)
        ALF1=ALFPI
        IF(KEYRAD.EQ.0.OR.KBRINI.EQ.0) THEN
          BETI=0D0
          DELI=0D0
        ELSE
          QE2=QE*QE
          BILG=DLOG(4D0*ENE**2/AMIN**2)
          BETI=2D0*QE2*ALF1*(BILG-1D0)
          DELI=ALF1*QE2*(9D0*BILG+2D0*PI**2-12D0)/6D0
     $        +BETI*LOG(XK0)
        ENDIF
        IF(KEYRAD.EQ.0.OR.KEYRAD.EQ.10.OR.KBRFIN.EQ.0) THEN
          FACTOR=0D0
        ELSE
          FACTOR=1D0/(1.D0+DELI)
          FACTOR=FACTOR*QF*QF
        ENDIF
C INITIALISE QED CORRECTIONS
        DUMMY=FUNSKA(-1,0.2D0)
        CALL VESK8A(-1,X,Y)
C
      ELSEIF (MODE.EQ.0) THEN
C     =======================
    1   CONTINUE
        CALL RANMAR(RRR,4)
C PHOTON ENERGY GENERATION - INITIAL BREMSSTRAHLUNG
        CALL VESK8A(0,XK,PAR2)
        IF (KEYRAD.EQ.10) XK=VV
        IF (XK.GT.XK0) THEN
          IT=1
        ELSE
          IT=3
        ENDIF
C
C PHOTON ENERGY GENERATION - FINAL BREMSSTRAHLUNG
        IF (XK.LE.XK0) THEN
 333      XK=ALTPAR(4D0*ENE**2,AMFIN,XK0,FACTOR)
          IF (XK.GT.1D0-AMFIN**2/ENE**2) GO TO 333
          IF(XK.GT.XK0) IT=2
        ENDIF
C
C GENERATION OF THE ANGULAR VARIABLES
        IF(IT.EQ.3) THEN
C         SOFT PHOTON CASE  XK.LT.XK0
          R=BORAS(4D0*ENE**2)
C         ANGULAR DISTRIBUTION GENERATION
          CALL RRR7(R,C,S)
        ELSEIF (IT.EQ.1) THEN
C         HARD PHOTON CASE - INITIAL STATE
C         GENERATION OF THE PHOTON ANGULAR  DISTRIBUTION
          CALL RRR6(XK,   AMIN**2/ENE**2,CG,SG,IBREM)
C         GENERATION OF THE FINAL FERMION DISTRIBUTION
          R=BORAS(4D0*ENE**2*(1D0-XK))
          CALL RRR7(R,C,S)
C         GENERATION OF THE ANGLE BETWEEN PHOTON-BEAM AND PHOTON-TAU PL
          RR1=RRR(1)
          FIG=-PI+2D0*PI*RR1
        ELSEIF ( IT.EQ.2) THEN
C         HARD PHOTON CASE - FINAL STATE
C         PHOTON ANGULAR COORDINATES GENERATION
          CALL RRR6(XK,   AMFIN**2/ENE**2/(1D0-XK),CG,SG,IBREM)
          R=BORAS(4D0*ENE**2)
C         FERMION ANGULAR COORDINATES
          CALL RRR7(R,C,S)
C         GENERATION OF THE ANGLE BETWEEN PHOTON-BEAM AND PHOTON-TAU PL
          RR2=RRR(2)
          FIG=-PI+2D0*PI*RR2
        ENDIF
C
C GENERATION OF THE ANGLE AROUND THE BEAM
        RR3=RRR(3)
        FI=-PI+2D0*PI*RR3
C CALCULATION OF 4 MOMENTA FROM ANGULAR VARIABLES
        QP(4)=AMFIN
        PH(4)=2.D0*ENE
        QM(4)=AMFIN
        DO 103 I=1,3
        PH(I)=.0D0
        QP(I)=.0D0
  103   QM(I)=.0D0
        CALL TRALOR(1,QP,QP)
        CALL TRALOR(2,QM,QM)
C
C INITIAL STATE BREMSSTRAHLUNG - PHOTON 4-MOMENTUM
        IF(IT.EQ.1) THEN
C CALCULATED DIRECTLY FROM ANGLES
          PH(4)=XK    *ENE
          PH(3)=XK*CG *ENE
          PH(2)=0.D0  *ENE
          PH(1)=XK*SG *ENE
          CFI=COS(FI)
          SFI=SIN(FI)
          PH1    =CFI*PH(1)-SFI*PH(2)
          PH(2)=SFI*PH(1)+CFI*PH(2)
          PH(1)=PH1
        ELSE
          DO 304 I=1,4
  304     PH(I)=PH(I)-QP(I)-QM(I)
        ENDIF
C FILLING EXTRA COMMONS
        NPHOT=1
        IF (IT.EQ.3) NPHOT=0
        DO 40 I=1,4
        DO 40 J=1,100
 40     SPHOT(J,I)=0.D0
        DO 30 I=1,4
        QF1(I)=QP(I)
        QF2(I)=QM(I)
        SPHUM(I)=PH(I)
        SPHOT(1,I)=PH(I)
        AQP(I)=QP(I)
        AQM(I)=QM(I)
 30     APH(I)=PH(I)
        NPHOTA=NPHOT
        DO 35 I=1,4
        AQF1(I)=QF1(I)
        AQF2(I)=QF2(I)
        ASPHUM(I)=SPHUM(I)
        DO 36 II=1,100
 36     ASPHOT(II,I)=SPHOT(II,I)
 35     CONTINUE
C
        WT =WEIGHT(0,0.0D0,0.D0)
        WT =WEIGHT(1,0.D0,0.D0)/WT
        IF (WT.GT.4.D0) THEN
         WRITE(6,*) 'KUKU FROM EVENTM WT=',WT,'IT=',IT,'XK=',XK
         IF(IT.NE.3) THEN
          FUNTA=FUNTIH(0,0.D0,0.D0)
          FUNTB=FUNTIH(1,0.D0,0.D0)
          WRITE(6,*) 'FUNT(0)=',FUNTA,'FUNT(1)=',FUNTB
         ENDIF
            CALL SANGLE(1,SVAR,CTHE)
          GSWF0=BORNS(0,SVAR,CTHE,0D0,0D0)
          GSWFA=BORNS(1,SVAR,CTHE,0D0,0D0)
          WRITE(6,*) 'nev=',swt(1),'svar=',svar,'cthe=',cthe
          WRITE(6,*) 'GSWF0=',GSWF0,'GSWFA=',GSWFA
C         STOP
        ENDIF
        SWT(1)=SWT(1)+1D0
        SWT(2)=SWT(2)+WT
        SWT(3)=SWT(3)+WT*WT
C IMPOSING INTERFERENCE TERM ON THE GENERATED DISTRIBUTION
        RN=RRR(4)
        IF(RN.GT.WT/4D0) GO TO 1
C
      ELSEIF (MODE.EQ. 1) THEN
C     ========================
        CALL VESK8A( 1,SIGT,ERR)
        AWT =SWT(2)/SWT(1)
        DWT =SQRT(SWT(3)/SWT(2)**2-1D0/SWT(1))
        WRITE(6,*) 'SIGT=',SIGT,'ERR=',ERR
        WRITE(6,*) 'AWT=',AWT,'+-',DWT
        CSTOT=SIGT*AWT
        NTOT=INT(SWT(1))
        SIG0=4.D0*PI/ALFINV**2/3.D0/(4D0*ENE**2)
        CSTCM=SIGT*AWT*SIG0*CMTR
        ERREL=SQRT(DWT**2+ERR**2)
      ENDIF
C     =====
      END
      FUNCTION ALTPAR(TRANSF,AMFERM,EPSIL,FACTOR)
C ----------------------------------------------------------------------
C THIS FUNCTION RETURNS PHOTON MOMENTUM (IN SQRT(S)/2 UNITS)
C FOR THE FINAL STATE BREMSSTRAHLUNG.
C HARD BREMSSTRAHLUNG PART OF THE DISTRIBUTION CORRESPONDS TO  PRECISE
C SINGLE BREMSSTRAHLUNG (ORDER ALPHA) RESULT AND NO-PHOTON PROBABILITY
C IS ADJUSTED SUCH THAT THE INTEGRAL OVER ENTIRE DISTRIBUTION IS EQUAL
C TO ONE PRECISELY (AS IN ALTARELLI-PARISI CASE).
C IN THE LEADING LOG THE DISTRIBUTION COINCIDES WITH THE ALTARELLI-
C PARISI DISTRIBUTION WHERE FERMION IS FRAGMENTING COLLINEARLY INTO A
C PHOTON AND FERMION.
C
C    INPUT:
C TRANSF   = TOTAL C.M. ENERGY SQUARED (GEV**2)
C EPSIL    = INFRARED CUTOFF PARAMETER, DIMENSIONLESS, SMALL.
C AMFERM   = FERMION MASS (GEV)
C FACTOR   = NORMALLY EQUAL 1, OTHERWISE IT MAY BE USED TO REGULATE
C            THE STRENGTH OF THE BREMSTRAHLUNG (IT MULTIPLIES ALPHA).
C    OUTPUT:
C RETURNED IS A FRACTION OF THE FERMION MOMENTUM  CARRIED BY PHOTON,
C DIMENSIONLESS, IN THE RANGE (0,1).
C
C     called by : EVENTE, EVENTM
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / QEDPRM /ALFINV,ALFPI,XK0
      REAL*8           ALFINV,ALFPI,XK0
      REAL*4 RRN1,RRR(2)
      DATA PI /3.141592653589793238462643D0/
C
C PROBABILITIES FOR HARD AND SOFT BREMSTRAHLUNG
      BILG= LOG(TRANSF/AMFERM**2)
      PRHARD= 2D0 *ALFPI *(BILG-1D0) *( LOG(1D0/EPSIL)-.75D0 )
C NONLEADING TERM  FROM LOG(1-XK) PART OF DISTRIBUTION
      PRHARD=PRHARD + ALFPI *( -PI**2/3D0 +1.25D0)
      PRHARD=PRHARD*FACTOR
      PRSOFT=1D0-PRHARD
      IF(PRSOFT.LT.0.10D0) GOTO 600
      CALL RANMAR(RRN1,1)
      RN1=RRN1
      IF(RN1.LT.PRSOFT) THEN
C        NO PHOTON....  (IE. PHOTON BELOW EPSILON)
         XK=0D0
      ELSE
C        HARD PHOTON...  (IE. PHOTON ABOVE EPSILON)
  200    CONTINUE
         CALL RANMAR(RRR,2)
         RN2=RRR(1)
         RN3=RRR(2)
         XK=  EXP(RN2* LOG(EPSIL))
         DIST0= 1D0/XK *(BILG-1D0)
         DIST1= (1D0+(1D0-XK)**2)/2D0/XK *(BILG +LOG(1D0-XK) -1D0)
         WEIGHT=DIST1/DIST0
         IF(RN3.GT.WEIGHT) GO TO 200
      ENDIF
      ALTPAR=XK
      RETURN
  600 PRINT 1600,TRANSF,PRSOFT
 1600 FORMAT(' ++++++++++++++  STOP IN ALTPAR:',
     $     /,'             TRANSF,PRSOFT,=' ,2F20.5)
      STOP
      END
      FUNCTION FUNSKA(MODE,X)
C ----------------------------------------------------------------------
C CALLED IN VESKO2
C PROVIDES V OR K DISTRIBUTION TO BE GENERATED
C
C     called by : EVENTM, VESK8A, DESK8A
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / KEYSET / KEYGSW,KEYRAD,KEYTAB
      COMMON / BEAMPM / ENE ,AMIN,AMFIN,IDE,IDF
      REAL*8            ENE ,AMIN,AMFIN
      COMMON / QEDPRM /ALFINV,ALFPI,XK0
      REAL*8           ALFINV,ALFPI,XK0
      COMMON / INOUT / INUT,IOUT
      COMMON / KBREMS / KBRINI,KBRFIN,KBRINT
C
      IF(KEYRAD.EQ.0) THEN
        BLE=BONMA0(MODE,X)
        IF (X.GT.XK0) BLE=0.D0
        FUNSKA=BLE
      ELSEIF(KEYRAD.EQ.1) THEN
        IF(KBRINI.EQ.0) THEN
          BLE=BONMA0(MODE,X)
          IF (X.GT.XK0) BLE=0.D0
          FUNSKA=BLE
        ELSE
          BLE=BONMA1(MODE,X)
          IF (X.GT.XK0) BLE=BLE *(1+(1-X)**2)/2D0
          FUNSKA=BLE
        ENDIF
      ELSEIF (KEYRAD.GE.10.AND.KEYRAD.LT.113) THEN
        FUNSKA=5
      ELSE
        WRITE (IOUT,*) 'STOP IN FUNSKO'
        STOP
      ENDIF
      END
      FUNCTION BONMA0(MODE,XK)
C ----------------------------------------------------------------------
C PHOTON SPECTRUM IN CASE OF NO PHOTONS - BORN ONLY
C FAKED DISTRIBUTION
C
C     called by : FUNSKO
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / KEYSET / KEYGSW,KEYRAD,KEYTAB
      COMMON / BEAMPM / ENE ,AMIN,AMFIN,IDE,IDF
      REAL*8            ENE ,AMIN,AMFIN
      COMMON / QEDPRM /ALFINV,ALFPI,XK0
      REAL*8           ALFINV,ALFPI,XK0
      COMMON / KBREMS / KBRINI,KBRFIN,KBRINT
C
      IF (MODE.EQ.-1) THEN
C     ====================
C       INITIALIZATION
        CALL GIVIZO( IDE, 1,AIZOR,QE,KDUMM)
        QE2=0.D0
        SOFT=BORNY(4D0*ENE**2)
        F0=.5D0*BORNY(4D0*ENE**2)
        F1=XK0/(EXP(SOFT/F0)-1)
C FUNCTION RETURNS RATIO OF THE BORN TO INITIAL SOFT CROSS SECTION
        BONMA0=1D0
C
C RUNNING MODE
      ELSEIF (MODE.EQ.0 ) THEN
C     ==========================
        IF     (XK.LE.0D0 ) THEN
          BONMA0=0D0
        ELSEIF (XK.LE.XK0 ) THEN
C         SOFT PHOTON CASE
          BONMA0=F0/(XK+F1)
        ELSE
          BONMA0=0D0
        ENDIF
C
      ENDIF
C     =====
      END
      FUNCTION BONMA1(MODE,XK)
C ----------------------------------------------------------------------
C DISTRIBUTION OF K-VARIABLE,
C BONNEAU MARTIN FORMULA
C
C     called by : FUNSKO
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / BEAMPM / ENE ,AMIN,AMFIN,IDE,IDF
      REAL*8            ENE ,AMIN,AMFIN
      COMMON / QEDPRM /ALFINV,ALFPI,XK0
      REAL*8           ALFINV,ALFPI,XK0
      COMMON / VVREK  / VVMIN,VVMAX,VV,BETI
      REAL*8            VVMIN,VVMAX,VV,BETI
      COMMON / INOUT / INUT,IOUT
      DATA PI /3.141592653589793238462643D0/
C
      IF(XK0.GT.VVMAX) GOTO 900
      QE=1D0
      QE2=QE**2
      SVAR=4D0*ENE**2
      ALF1=ALFPI
      BILG  =DLOG(4D0*ENE**2/AMIN**2)
      BETI  =2D0*QE2*ALF1*(BILG-1D0)
      BETIR =2D0*QE2*ALF1* BILG
      DELI  =ALF1*QE2*(1.5D0*BILG+PI**2/3D0-2D0)+ BETI*LOG(XK0)
      IF(    XK.LT.0D0) THEN
        DIST=0D0
      ELSEIF(XK.LT.XK0) THEN
C DISTRIBUTION BELOW XK0 IS DESIGNED SUCH THAT THE INTEGRAL
C FROM 0 TO XK0 IS PRECISELY (1+DELI)*BORNY(SVAR)
        EPS=XK0/(EXP((1D0+DELI)/BETI)-1D0)
        DIST=BETI/(EPS+XK)*BORNY(SVAR)
      ELSEIF(XK.LT.VVMAX) THEN
C NOTE THAT 1/(1-XK) FACTOR BECAUSE BORNY IS IN R-UNITS
        SOFDIS=    BETI/XK
C    SOFDIS=    BETIR/XK
        DIST=SOFDIS*BORNY(SVAR*(1D0-XK))/(1D0-XK)
      ELSE
        DIST=0D0
      ENDIF
      VV=XK
C
      BONMA1=DIST
      RETURN
  900 WRITE(IOUT,*) '============= STOP IN BONMAR '
      END
      FUNCTION WEIGHT(MODE,TA,TB)
C ----------------------------------------------------------------------
C THIS FUNCTION CALCULATES DIFFERENTIAL CROSS SECTION FOR EVERY EVENT
C  INPUT : MODE:
C                 0   FOR CALL FOR RAW CROSS SECTION
C                     NO VAC. POLARIZ & NO GSW &
C                     NO INTERFERENCE INIT - FINAL
C                 1   INITIALIZATION. CORECT X. SECTION
C                 2   CORRECT X. SECTION
C          TA,TB: TWICE OF TAU+ TAU- HELICITIES
C
C     called by : EVENTE, EVENTM, SPIGEN, ALTPAR
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / KEYSET / KEYGSW,KEYRAD,KEYTAB
      DATA ICONT/0/
      ICONT=ICONT+1
C IF MODE=0 CALCULATION OF ANGULAR VARIABLES FROM 4-MOMENTA
      CALL PEDYPR(MODE,XK,C1,S1,C2,S2,CF,SF,CG,SG)
      IF(XK.GT.1.D-6) THEN
C        HARD PHOTON CASE
         FUNTI=FUNTIH(MODE,TA,TB)
C         IF (TA.EQ.0.AND.TB.EQ.0) THEN
C         IF (MODE.EQ.0) BUFOR=FUNTI
C         IF (MODE.EQ.1) WRITE(6,*) 'hard=',FUNTI,' ',BUFOR
C         ENDIF
      ELSE
C        SOFT PHOTON CASE
         COSTHE=C1
         FUNTI=FUNTIS(MODE,COSTHE,TA,TB)
C         IF (TA.EQ.0.AND.TB.EQ.0) THEN
C         IF (MODE.EQ.0) BUFOR=FUNTI
C         IF (MODE.EQ.1) WRITE(6,*)  'soft=',FUNTI,' ',BUFOR
C         ENDIF
      ENDIF
C
      IF (KEYGSW.GE.0) THEN
        IF (MODE.EQ.0) THEN
            CALL SANGLE(0,SVAR,CTHE)
          GSWF0=BORNS(0,SVAR,CTHE,0D0,0D0)
          GSWF1=BORNS(0,SVAR,CTHE,1D0,1D0)
          GSWF2=BORNS(0,SVAR,CTHE,-1D0,-1D0)
        ENDIF
C THIS IS A PROTECTION AGAINST ZERO DIVIDE IN NUNUBAR CASE
        IF (DABS(GSWF0).LT.1D-12) GSWF0= 1.D0
        IF (DABS(GSWF1).LT.1D-12) GSWF1= 1.D0
        IF (DABS(GSWF2).LT.1D-12) GSWF2= 1.D0
C
C
        IF (MODE.EQ.0) THEN
          GSWFA=1D0
        ELSEIF (TA*TB.LT.-.5D0) THEN
          GSWFA=1D0
        ELSEIF ( TA*TA.LT.0.5D0) THEN
          GSWFA=BORNS(MODE,SVAR,CTHE,0D0,0D0)/GSWF0
        ELSEIF ( TA.GT.0.5D0)    THEN
          GSWFA=BORNS(MODE,SVAR,CTHE,1D0,1D0)/GSWF1
        ELSEIF ( TA.LT.-0.5D0)   THEN
          GSWFA=BORNS(MODE,SVAR,CTHE,-1D0,-1D0)/GSWF2
        ENDIF
C
        FUNTI=FUNTI*GSWFA
      ENDIF
C
      WEIGHT=FUNTI
C     PRINT *, 'MODE',MODE,'TA',TA,'TB',TB,'WEIGHT=',WEIGHT
      END
      SUBROUTINE SANGLE(MODE,SVAR,COSTHE)
C ----------------------------------------------------------------------
C THIS ROUTINE CALCULATES BORN LIKE VARIABLES FROM THE 4- MOMETA
C STORED IN UTIL. FOR MODE = 0 ANGULAR VARIABLES ARE CALCULATED
C AND MEMORIZED. FOR HIGHER MODES THEY ARE SUPPLIED.
C FOR ULTRAHARD PHOTONS (EDGE OF PHASE SPACE) THIS ROUTINE MAY
C PRODUCE COSTHE.GT.1D0 .....
C
C     called by : WEIGHT
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / BEAMPM / ENE ,AMIN,AMFIN,IDE,IDF
      REAL*8            ENE ,AMIN,AMFIN
      COMMON / UTIL8 / QP(4),QM(4),PH(4)
      REAL*8           QP   ,QM   ,PH
      COMPLEX*16 CPRZ0M
      REAL*8 PP(4),PM(4),PP1(4),PM1(4),QP1(4),QM1(4),P(4),Q(4)
      REAL*8 PP2(4),PM2(4),QP2(4),QM2(4)
      DATA  ICON /0/
C
      IF (MODE.EQ.0) THEN
C       INITIALIZATION OF THE  VARIABLES
C       ================================
C       4-MOMENTA OF BEAMS
        DO 7 K=1,4
        PP(K)=0D0
    7   PM(K)=0D0
C
        PP(4)= ENE
        PM(4)= ENE
        PP(3)= ENE
        PM(3)=-ENE
C 4-MOMENTA OF 'DRESSED' FERMIONS
        DO 9 K=1,4
        PP1(K)=PP(K)
        PM1(K)=PM(K)
        QP1(K)=QP(K)
    9   QM1(K)=QM(K)
C ADDITION OF THE PHOTON PH TO FERMION OF MINIMAL MASS OF
C FERMION PHOTON STATE
        DO 8 K=1,4
        PP2(K)=PP(K)-PH(K)
        PM2(K)=PM(K)-PH(K)
        QP2(K)=QP(K)+PH(K)
    8   QM2(K)=QM(K)+PH(K)
CC
        CALL MULSK(PP2,PP2,XM1)
        CALL MULSK(PM2,PM2,XM2)
        CALL MULSK(QP2,QP2,XM3)
        CALL MULSK(QM2,QM2,XM4)
        XXKM=1D0-PH(4)/ENE
        FACINI=CDABS(CPRZ0M(1,4D00*ENE**2*XXKM))**2
        FACFIN=CDABS(CPRZ0M(1,4D00*ENE**2))**2
        XM1=XM1/FACINI
        XM2=XM2/FACINI
        XM3=XM3/FACFIN
        XM4=XM4/FACFIN
        XM=MIN(-XM1,-XM2,XM3,XM4)
C
        DO 10 K=1,4
        IF     (XM1.EQ.-XM) THEN
          PP1(K)=PP(K)-PH(K)
        ELSEIF (XM2.EQ.-XM) THEN
          PM1(K)=PM(K)-PH(K)
        ELSEIF (XM3.EQ. XM) THEN
          QP1(K)=QP(K)+PH(K)
        ELSEIF (XM4.EQ. XM) THEN
          QM1(K)=QM(K)+PH(K)
        ELSE
          PRINT *,
     &    'SOMETHING IS STRANGE IN COMPILER MODIFY LOGIC OF SANGLE'
        ENDIF
   10   CONTINUE
C CALCULATION OF THE S AND COSTHE CORRESPONDING TO THE HARD-BORN LIKE
C KERNEL OF THE INTERACTION. USED ARE DRESSED 4-MOMENTA OF FERMIONS.
        DO 15 K=1,4
        Q(K)=QP1(K)-PP1(K)
   15   P(K)=PM1(K)+PP1(K)
C
        CALL MULSK(P,P,SVARI)
        CALL MULSK(Q,Q,T)
        CALL MULSK(PP1,PP1,XM1)
        CALL MULSK(PM1,PM1,XM2)
        CALL MULSK(QP1,QP1,XM3)
        CALL MULSK(QM1,QM1,XM4)
C
        P2=(SVARI**2+(XM1-XM2)**2-2D0*SVARI*(XM1+XM2))/4D0/SVARI
        Q2=(SVARI**2+(XM3-XM4)**2-2D0*SVARI*(XM3+XM4))/4D0/SVARI
        COST=.5D0/SQRT(P2*Q2)*(T-XM1-XM3+2D0*SQRT((P2+XM1)*(Q2+XM3)))
        IF(XM1.GE.XM2) THEN
          COST=.5D0/SQRT(P2*Q2)*(T-XM1-XM3+2D0*SQRT((P2+XM1)*(Q2+XM3)))
          COSA=.5D0/SQRT(P2*Q2)*(T-XM2-XM4+2D0*SQRT((P2+XM2)*(Q2+XM4)))
        ELSE
          COST=.5D0/SQRT(P2*Q2)*(T-XM2-XM4+2D0*SQRT((P2+XM2)*(Q2+XM4)))
          COSA=.5D0/SQRT(P2*Q2)*(T-XM1-XM3+2D0*SQRT((P2+XM1)*(Q2+XM3)))
        ENDIF
C
      ENDIF
C     =====
C* SETTING VALUES (FOR ALL MODES)
C
      COSTHE=COST
      SVAR=SVARI
C     CALL DUMPL9(PP1,PM1,PH)
C     CALL DUMPL9(QP1,QM1,PH)
      ICON=ICON+1
C ZW CORRECTION FOR SOME OVERFLOWS AT THE EDGE OF THE PHASE SPACE
      IF ( COSTHE.GE.1D0.OR.COSTHE.LE.-1D0 ) THEN
        COSTHE=COSTHE/COSTHE**2
        IF ( COSTHE.EQ.1D0.OR.COSTHE.EQ.-1D0 ) COSTHE=COSTHE*.9999999
        PRINT *, '==== WARNING ===== SUBROUTINE SANGLE',ICON
        PRINT *, 'YOU HAVE RUN INTO THE PROBLEM AT THE EDGE OF THE PHASE
     $ SPACE. AD HOC CORRECTION HAS BEEN DONE! '
      ENDIF
      IF ( SVAR.LE.4D0*AMFIN**2) THEN
        SVAR=16D0*AMFIN**4/SVAR
        IF ( SVAR.EQ.4D0*AMFIN**2 ) SVAR=SVAR*1.00000001D0
        PRINT *, '==== WARNING ===== SUBROUTINE SANGLE',ICON
        PRINT *, 'YOU HAVE RUN INTO THE PROBLEM AT THE EDGE OF THE
     $  PHASE SPACE. AD HOC CORRECTION HAS BEEN DONE! '
      ENDIF
      RETURN
      END
      SUBROUTINE SKONTY(MODE,SVAR,COSTHE)
C ----------------------------------------------------------------------
C THIS ROUTINE CALCULATES BORN LIKE VARIABLES FROM THE 4- MOMETA
C STORED IN MOMSET. FOR MODE = 0 ANGULAR VARIABLES ARE CALCULATED
C AND MEMORIZED. FOR HIGHER MODES THEY ARE SUPPLIED.
C FOR ULTRAHARD PHOTONS (EDGE OF PHASE SPACE) THIS ROUTINE MAY
C PRODUCE COSTHE.GT.1D0 .....
C
C     called by : WAGA, WEIGHT
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / MOMSET / QF1(4),QF2(4),SPHUM(4),SPHOT(100,4),NPHOT
      COMMON / MOMINI / XF1(4),XF2(4),XPHUM(4),XPHOT(100,4),NPHOX
      COMMON / MOMFIN / YF1(4),YF2(4),YPHUM(4),YPHOT(100,4),NPHOY
      COMMON / BEAMPM / ENE ,AMIN,AMFIN,IDE,IDF
      REAL*8            ENE ,AMIN,AMFIN
      REAL*8 PP(4),PM(4),PP1(4),PM1(4),QP1(4),QM1(4),P(4),Q(4)
      REAL*8 PP2(4),PM2(4),QP2(4),QM2(4)
      REAL*8 QP(4),QM(4),PH(4)
      COMPLEX*16 CPRZ0M
      LOGICAL IFINI,BETTER
C
C     BETTER=.true. denotes mode of operation when photons are
C     classified to be initial or final
      DATA  BETTER /.TRUE./
      DATA  ICON /0/
C

      IF (MODE.EQ.0) THEN
C      INITIALIZATION OF THE  VARIABLES
C      ================================
C
C 4-MOMENTA OF BEAMS
        DO 7 K=1,4
        PP(K)=0D0
    7   PM(K)=0D0
C
        PP(4)= ENE
        PM(4)= ENE
        PP(3)= ENE
        PM(3)=-ENE
C 4-MOMENTA OF 'DRESSED' FERMIONS
        DO 9 K=1,4
        QP(K) =QF1(K)
        QM(K) =QF2(K)
        PP1(K)=PP(K)
        PM1(K)=PM(K)
        QP1(K)=QP(K)
    9   QM1(K)=QM(K)
C
        DO 77 KPHOT=1,NPHOT
C       == == =============
C ADDITION OF THE PHOTON PH TO FERMION OF MINIMAL MASS OF
C FERMION PHOTON STATE
        DO 8 K=1,4
        IFINI=KPHOT.LE.NPHOX
        IF (IFINI) THEN
          PH (K)=XPHOT(KPHOT,K)
        ELSE
          PH (K)=YPHOT(KPHOT-NPHOX,K)
          IF(NPHOY.EQ.0) PH (K)=SPHOT(KPHOT,K)
        ENDIF
        PP2(K)=PP(K)-PH(K)
        PM2(K)=PM(K)-PH(K)
        QP2(K)=QP(K)+PH(K)
    8   QM2(K)=QM(K)+PH(K)
C
        CALL MULSK(PP2,PP2,XM1)
        CALL MULSK(PM2,PM2,XM2)
        CALL MULSK(QP2,QP2,XM3)
        CALL MULSK(QM2,QM2,XM4)
        XXKM=1D0-PH(4)/ENE
        FACINI=CDABS(CPRZ0M(1,4D00*ENE**2*XXKM))**2
        FACFIN=CDABS(CPRZ0M(1,4D00*ENE**2))**2
        XM1=XM1/FACINI
        XM2=XM2/FACINI
        XM3=XM3/FACFIN
        XM4=XM4/FACFIN
        IF (BETTER) THEN
          IF (IFINI) THEN
           XM=MIN(-XM1,-XM2,-XM1,-XM2)
          ELSE
           XM=MIN( XM4, XM3, XM3, XM4)
          ENDIF
        ELSE
           XM=MIN(-XM1,-XM2, XM3, XM4)
        ENDIF
C
        DO 10 K=1,4
        IF     (XM1.EQ.-XM) THEN
          PP1(K)=PP1(K)-PH(K)
        ELSEIF (XM2.EQ.-XM) THEN
          PM1(K)=PM1(K)-PH(K)
        ELSEIF (XM3.EQ. XM) THEN
          QP1(K)=QP1(K)+PH(K)
        ELSEIF (XM4.EQ. XM) THEN
          QM1(K)=QM1(K)+PH(K)
        ELSE
          PRINT *,
     &    'SOMETHING IS STRANGE IN COMPILER MODIFY LOGIC OF SANGLE'
        ENDIF
   10   CONTINUE
   77   CONTINUE
C  ==   ========
C CALCULATION OF THE S AND COSTHE CORRESPONDING TO THE HARD-BORN LIKE
C KERNEL OF THE INTERACTION. USED ARE DRESSED 4-MOMENTA OF FERMIONS.
        DO 15 K=1,4
        Q(K)=QP1(K)-PP1(K)
   15   P(K)=PM1(K)+PP1(K)
        CALL MULSK(P,P,SVARI)
        CALL MULSK(Q,Q,T)
        CALL MULSK(PP1,PP1,XM1)
        CALL MULSK(PM1,PM1,XM2)
        CALL MULSK(QP1,QP1,XM3)
        CALL MULSK(QM1,QM1,XM4)
C
        P2=(SVARI**2+(XM1-XM2)**2-2D0*SVARI*(XM1+XM2))/4D0/SVARI
        Q2=(SVARI**2+(XM3-XM4)**2-2D0*SVARI*(XM3+XM4))/4D0/SVARI
        COST=.5D0/SQRT(P2*Q2)*(T-XM1-XM3+2D0*SQRT((P2+XM1)*(Q2+XM3)))
        IF(XM1.GE.XM2) THEN
          COST=.5D0/SQRT(P2*Q2)*(T-XM1-XM3+2D0*SQRT((P2+XM1)*(Q2+XM3)))
          COSA=.5D0/SQRT(P2*Q2)*(T-XM2-XM4+2D0*SQRT((P2+XM2)*(Q2+XM4)))
        ELSE
          COST=.5D0/SQRT(P2*Q2)*(T-XM2-XM4+2D0*SQRT((P2+XM2)*(Q2+XM4)))
          COSA=.5D0/SQRT(P2*Q2)*(T-XM1-XM3+2D0*SQRT((P2+XM1)*(Q2+XM3)))
        ENDIF

C
      ENDIF
C     =====
C* SETTING VALUES (FOR ALL MODES)
C
      COSTHE=COST
      SVAR=SVARI
      ICON=ICON+1
C ZW CORRECTION FOR SOME OVERFLOWS AT THE EDGE OF THE PHASE SPACE
      IF ( COSTHE.GE.1D0.OR.COSTHE.LE.-1D0 ) THEN
        COSTHE=COSTHE/COSTHE**2
        IF ( COSTHE.EQ.1D0.OR.COSTHE.EQ.-1D0 ) COSTHE=COSTHE*.9999999
        PRINT *, '==== WARNING ===== SUBROUTINE SKONTY',ICON
        PRINT *, 'YOU HAVE RUN INTO THE PROBLEM AT THE EDGE OF THE PHASE
     $ SPACE. AD HOC CORRECTION HAS BEEN DONE! '
       CALL DUMPS(6)
      ENDIF
      IF ( SVAR.LE.4D0*AMFIN**2) THEN
        SVAR=16D0*AMFIN**4/SVAR
        IF ( SVAR.EQ.4D0*AMFIN**2 ) SVAR=SVAR*1.00000001D0
        PRINT *, '==== WARNING ===== SUBROUTINE SKONTY',ICON
        PRINT *, 'YOU HAVE RUN INTO THE PROBLEM AT THE EDGE OF THE
     $ SPACE. AD HOC CORRECTION HAS BEEN DONE! '
       CALL DUMPS(6)
      ENDIF
      RETURN
      END
      SUBROUTINE BDRESS(MODE,PPBT,PMBT,SVAR,COSTHE)
C ----------------------------------------------------------------------
C THIS ROUTINE CALCULATES DRESSED BEAMS
C FOR ULTRAHARD PHOTONS (EDGE OF PHASE SPACE) THIS ROUTINE MAY
C PRODUCE COSTHE.GT.1D0 .....
C IT SHOULD NOT BE CALLED WITH THE MODE 0 AFTER GENERATION OF FINAL
C STATE PHOTON
C
C     called by : PEDYVV, TRAAAA, EVENTE, WEIGHT
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / MOMSET / QF1(4),QF2(4),SPHUM(4),SPHOT(100,4),NPHOT
      COMMON / BEAMPM / ENE ,AMIN,AMFIN,IDE,IDF
      REAL*8            ENE ,AMIN,AMFIN
      REAL*8 PP(4),PM(4),PP1(4),PM1(4),P(4),Q(4),PH(4)
      REAL*8 PP2(4),PM2(4),PPB(4),PMB(4),PPBT(4),PMBT(4)
      DATA  ICON /0/
C
      IF (MODE.EQ.0) THEN
C       INITIALIZATION OF THE  VARIABLES
C       ================================
C
C 4-MOMENTA OF BEAMS
        DO 7 K=1,4
        PP(K)=0D0
    7   PM(K)=0D0
C
        PP(4)= ENE
        PM(4)= ENE
        PP(3)= ENE
        PM(3)=-ENE
C 4-MOMENTA OF 'DRESSED' FERMIONS
        DO 9 K=1,4
        PP1(K)=PP(K)
        PM1(K)=PM(K)
    9   CONTINUE
C
        DO 33 JPHOT=1,NPHOT
C       == == =============
C
C ADDITION OF THE PHOTON PH TO FERMION OF MINIMAL MASS OF
C FERMION PHOTON STATE
        DO 8 K=1,4
        PH(K)=SPHOT(JPHOT,K)
        PP2(K)=PP(K)-PH(K)
        PM2(K)=PM(K)-PH(K)
    8   CONTINUE
C
        CALL MULSK(PP2,PP2,XM1)
        CALL MULSK(PM2,PM2,XM2)
C
        XM=MIN(-XM1,-XM2)
C
        DO 10 K=1,4
        IF     (XM1.EQ.-XM) THEN
          PP1(K)=PP1(K)-PH(K)
        ELSEIF (XM2.EQ.-XM) THEN
          PM1(K)=PM1(K)-PH(K)
        ELSE
          PRINT *,
     &    'SOMETHING IS STRANGE IN COMPILER MODIFY LOGIC OF SANGLE'
        ENDIF
   10   CONTINUE
C
   33   CONTINUE
C  ==   ========
C
C CALCULATION OF THE S AND COSTHE CORRESPONDING TO THE HARD-BORN LIKE
C KERNEL OF THE INTERACTION. USED ARE DRESSED 4-MOMENTA OF FERMIONS.
        DO 15 K=1,4
        PPB(K)=PP1(K)
        PMB(K)=PM1(K)
        Q(K)=QF1(K)-PP1(K)
   15   P(K)=PM1(K)+PP1(K)
C
        CALL MULSK(P,P,SVARI)
        CALL MULSK(Q,Q,T)
        CALL MULSK(PP1,PP1,XM1)
        CALL MULSK(PM1,PM1,XM2)
        CALL MULSK(QF1,QF1,XM3)
        CALL MULSK(QF2,QF2,XM4)
C
        P2=(SVARI**2+(XM1-XM2)**2-2D0*SVARI*(XM1+XM2))/4D0/SVARI
        Q2=(SVARI**2+(XM3-XM4)**2-2D0*SVARI*(XM3+XM4))/4D0/SVARI
        IF(XM1.GE.XM2) THEN
          COST=.5D0/SQRT(P2*Q2)*(T-XM1-XM3+2D0*SQRT((P2+XM1)*(Q2+XM3)))
          COSA=.5D0/SQRT(P2*Q2)*(T-XM2-XM4+2D0*SQRT((P2+XM2)*(Q2+XM4)))
        ELSE
          COST=.5D0/SQRT(P2*Q2)*(T-XM2-XM4+2D0*SQRT((P2+XM2)*(Q2+XM4)))
          COSA=.5D0/SQRT(P2*Q2)*(T-XM1-XM3+2D0*SQRT((P2+XM1)*(Q2+XM3)))
        ENDIF
C
      ENDIF
C     =====
C* SETTING VALUES (FOR ALL MODES)
C
      COSTHE=COST
      SVAR=SVARI
      DO 16 K=1,4
      PPBT(K)=PPB(K)
      PMBT(K)=PMB(K)
   16 CONTINUE
C     CALL DUMPL9(PP1,PM1,PH)
C     CALL DUMPL9(QP1,QM1,PH)
      ICON=ICON+1
C ZW CORRECTION FOR SOME OVERFLOWS AT THE EDGE OF THE PHASE SPACE
      IF (COST.GE.1D0.OR.COST.LE.-1D0) THEN
        PRINT *, '=== WARNING === SUBR. BDRESS',ICON,'costhe=',costhe
        PRINT *, '=== WARNING === SUBR. BDRESS',ICON,'cosa=',cosa
        PRINT *, '==== WARNING ===== SUBR. BDRESS',ICON,'svar=',svar
       CALL DUMPZ8('PP1',PP1 )
       CALL DUMPZ8('PM1',PM1 )
       CALL DUMPZ8('P  ',P   )
       CALL DUMPZ8('QF1',QF1 )
       CALL DUMPZ8('QF2',QF2 )
       CALL DUMPZ8('Q  ',Q )
      WRITE(6,*) 'SVARI=',SVARI,'T=',T
      WRITE(6,*) 'XM1=',XM1,'XM2=',XM2,'XM3=',XM3,'XM4=',XM4
      WRITE(6,*) 'P2=',P2,'Q2=',Q2
        COSTHE=COSTHE/COSTHE**2
        IF ( COSTHE.EQ.1D0.OR.COSTHE.EQ.-1D0 ) COSTHE=COSTHE*.9999999
C       PRINT *, 'YOU HAVE RUN INTO THE PROBLEM AT THE EDGE OF THE PHASE
C     $ SPACE. AD HOC CORRECTION HAS BEEN DONE! '
      ENDIF
      IF ( SVAR.LE.4D0*AMFIN**2) THEN
        PRINT *,'==== WARNING ===== SUBROUTINE BDRESS',ICON,'svar=',svar
        SVAR=16D0*AMFIN**4/SVAR
        IF ( SVAR.EQ.4D0*AMFIN**2 ) SVAR=SVAR*1.00000001D0
      ENDIF
      RETURN
      END
      FUNCTION FUNTIH(MODE,TA,TB)
C ----------------------------------------------------------------------
C                                           *
C         HARD PHOTON CASE                  *
C                                           *
C
C     called by : WEIGHT
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / BEAMPM / ENE ,AMIN,AMFIN,IDE,IDF
      REAL*8            ENE ,AMIN,AMFIN
      COMMON / GAUSPM /SS,POLN,T3E,QE,T3F,QF
     &                ,XUPGI   ,XUPZI   ,XUPGF   ,XUPZF
     &                ,NDIAG0,NDIAGA,KEYA,KEYZ
     &                ,ITCE,JTCE,ITCF,JTCF,KOLOR
      REAL*8           SS,POLN,T3E,QE,T3F,QF
     &                ,XUPGI(2),XUPZI(2),XUPGF(2),XUPZF(2)
      COMMON / KEYSET / KEYGSW,KEYRAD,KEYTAB
      COMMON / INSPIN / SEPS1,SEPS2
      REAL*8            SEPS1,SEPS2
      COMMON / KBREMS / KBRINI,KBRFIN,KBRINT
      COMPLEX*16 CPRAM,CA0,CA1
      COMPLEX*16 CPRZ0M,CP0,CP1
      COMPLEX*16 T1(2,4,4),T2(2,4,4),ZERO
      COMPLEX*16 ONEC,IMAG,DE0,DEK,CK,CL,CN,CX,SX
      DATA INIT/0/
C
      DE0(EPS,TAU)=CA0*SVAR*QE*QF*ONEC + CP0*SVAR
     $ *XUPZI(1+INT(-EPS+1.999D0)/2)*XUPZF(1+INT(-TAU+1.999D0)/2)
      DEK(EPS,TAU)=CA1*SVAR*QE*QF*ONEC + CP1*SVAR
     $ *XUPZI(1+INT(-EPS+1.999D0)/2)*XUPZF(1+INT(-TAU+1.999D0)/2)
C
C***************************************
      IF(INIT.EQ.0) THEN
C  OFF INTERFERENCE WHEN EXPONENTIATION
        IF  (KEYRAD.GE.10) KBRINT=0
        IF  (KEYRAD.GE.10) KBRFIN=0
        ZERO=DCMPLX(0.D0,0.D0)
        IMAG=DCMPLX(0.D0,1.D0)
        ONEC=DCMPLX(1.D0,0.D0)
      ENDIF
C
C****************************************
      SVAR=4D0*ENE**2
      XMEL =AMIN/ENE
      XMFIN=AMFIN/ENE
C** CALCULATE SPIN AMPLITUDES
C** BUT RECALCULATE ONLY IF IT IS NECESSARY
      IF (MODE.LE.1) THEN
        CALL PEDYPR(1,XK,C1,S1,C2,S2,CF,SF,CG,SG)
        BB=.5D0*XK/SQRT(1D0-XK)
        GB=(1.D0-.5D0*XK)/SQRT(1D0-XK)
        HINI= QE/(XMEL**2+S1**2)
        HFIN= QF/(XMFIN**2/(1D0-XK)
     $       +ABS(1D0-XMFIN**2/(1D0-XK))*S2**2)
        POLAR1= SEPS1
        POLAR2=-SEPS2
C Z0 PROPAGATORS AND GAMMA VACUUM POLARIZATIONS
        CP0 =CPRZ0M(MODE,SVAR)
        CP1 =CPRZ0M(MODE,SVAR*(1.D0-XK))
        CA0 =CPRAM (MODE,SVAR)
        CA1 =CPRAM (MODE,SVAR*(1.D0-XK))
        DO 140 J=1,2
        DO 140 K=1,4
        DO 140 I=1,4
        T1 (J, I, K)= ZERO
  140   T2 (J, I, K)= ZERO
        DO 150 J=1,2
        GE=(3.D0-2.D0*J)
        DO 150 K=1,2
        DO 150 I=1,2
        EPS=(3.D0-2.D0*I)
        TAU=(3.D0-2.D0*K)
        CX=GB*CF*ONEC+BB*SF*GE*IMAG
        SX=BB*CF*ONEC+GB*SF*GE*IMAG
        CK=-(EPS*TAU+C1*C2)*CX+S1*S2-GE*(TAU*C1+EPS*C2)*SX
        CN=(C1+GE*EPS)*(C2-C2*GE*TAU)*ONEC
        CL=(C1-GE*EPS*C1)*(C2+GE*TAU)*ONEC
C
        T1(J,I,K)  = IMAG/2.D0/BB*(GB-BB)*S1*HINI*
     $               DEK(EPS,TAU)*CK
        T1(J,I+2,K)= 0.5D0*SQRT(1D0-XK)*XMEL*C1*HINI*
     $               (CF*ONEC+SF*GE*IMAG)*DEK(-C1*EPS,TAU)*CL
        T2(J,I,K)  = IMAG/2.D0/BB*
     $              S2*HFIN*(CF*ONEC-SF*GE*IMAG)*DE0(EPS,TAU)*CK
        T2(J,I,K+2)= 0.5D0*XMFIN/SQRT(1D0-XK)*C2*HFIN*
     $                DE0(EPS,-C2*TAU)*CN
 150    CONTINUE
      ENDIF
C
      TOTINI=0.D0
      TOTFIN=0.D0
      TOTINT=0.D0
      TOT=0.D0
C CALCULATION OF THE CROSS SECTION
      DO 50 I=1,2
      HELIC= 3-2*I
      DO 50 J=1,2
      HELIT= 3-2*J
      FACTOR=KOLOR* (1D0+HELIC*POLAR1)*(1D0-HELIC*POLAR2)
      FACTOR=FACTOR*(1D0+HELIT*TA    )*(1D0+HELIT*TB)
C
      FACTOF=KOLOR* (1D0+HELIC*POLAR1)*(1D0-HELIC*POLAR2)
      FACTOF=FACTOF*(1D0+HELIT*TA    )*(1D0-HELIT*TB)
C
      IF (MODE.EQ.0)THEN
        FACTOI=KOLOR* (1D0-HELIC*C1*POLAR1)*(1D0+HELIC*C1*POLAR2)
      ELSE
        FACTOI=KOLOR* (1D0+HELIC*POLAR1)*(1D0+HELIC*POLAR2)
      ENDIF
      FACTOI=FACTOI*(1D0+HELIT*TA    )*(1D0+HELIT*TB)
      DO 50 K=1,2
C INITIAL STATE RADIATION
      TOTINI=TOTINI+  DREAL(T1(K,I  ,J  )*DCONJG(T1(K,I  ,J  )))*FACTOR
      TOTINI=TOTINI+  DREAL(T1(K,I+2,J  )*DCONJG(T1(K,I+2,J  )))*FACTOI
C FINAL STATE RADIATION
      TOTFIN=TOTFIN+  DREAL(T2(K,I  ,J  )*DCONJG(T2(K,I  ,J  )))*FACTOR
      TOTFIN=TOTFIN+  DREAL(T2(K,I  ,J+2)*DCONJG(T2(K,I  ,J+2)))*FACTOF
C INTERFERENCE
      TOTINT=TOTINT+2*DREAL(T1(K,I  ,J  )*DCONJG(T2(K,I  ,J  )))*FACTOR
  50  CONTINUE
      TOT=TOTINI*KBRINI+TOTFIN*KBRFIN+TOTINT*KBRINT

      IF (MODE.EQ.0)
     $TOT=TOTINI*KBRINI+TOTFIN*KBRFIN
      FUNTIH=TOT*2.D0
      FUNTIN=0.0
      END
      FUNCTION FUNTIS(MODE,COSTHE,TA,TB)
C ----------------------------------------------------------------------
C                                            *
C          SOFT PHOTON CASE                  *
C
C     called by : WEIGHT
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / BEAMPM / ENE ,AMIN,AMFIN,IDE,IDF
      REAL*8            ENE ,AMIN,AMFIN
      COMMON / QEDPRM /ALFINV,ALFPI,XK0
      REAL*8           ALFINV,ALFPI,XK0
      COMMON / GSWPRM /SWSQ,AMW,AMZ,AMH,AMTOP,GAMMZ
      REAL*8           SWSQ,AMW,AMZ,AMH,AMTOP,GAMMZ
C     SWSQ        = sin2 (theta Weinberg)
C     AMW,AMZ     = W & Z boson masses respectively
C     AMH         = the Higgs mass
C     AMTOP       = the top mass
C     GAMMZ       = Z0 width
      COMMON / GAUSPM /SS,POLN,T3E,QE,T3F,QF
     &                ,XUPGI   ,XUPZI   ,XUPGF   ,XUPZF
     &                ,NDIAG0,NDIAGA,KEYA,KEYZ
     &                ,ITCE,JTCE,ITCF,JTCF,KOLOR
      REAL*8           SS,POLN,T3E,QE,T3F,QF
     &                ,XUPGI(2),XUPZI(2),XUPGF(2),XUPZF(2)
      COMMON / KEYSET / KEYGSW,KEYRAD,KEYTAB
      COMMON / INSPIN / SEPS1,SEPS2
      REAL*8            SEPS1,SEPS2
      COMMON / KBREMS / KBRINI,KBRFIN,KBRINT
      COMPLEX*16 ABORN(2,2),APHOT(2,2),AZETT(2,2),BOXGG(2,2),BOXGZ(2,2)
      COMPLEX*16 PROPA,PROPZ,CPRZ0M,ONE,XX1,XX2,ZZ1,ZZ2,COEFB,DEL2,DEL3
      COMPLEX*16 CPRAM
      DATA ONE /(1D0,0D0)/
      DATA INIT/0/
C ----------------------------------------------------------------------
C***************************************
      IF (TA*TB.LT.-0.5D0) THEN
        FUNTIS=0.D0
        RETURN
      ENDIF
C****************************************
C
      IF(INIT.EQ.0) THEN
        INIT=1
C   OFF INTERFERENCE WHEN EXPONENTIATION
        IF (KEYRAD.GE.10) KBRINT=0
        IF (KEYRAD.GE.10) KBRFIN=0
        PI=4.D0*DATAN(1.D0)
        ALF1=ALFPI
        IF(KEYRAD.EQ.0) ALF1=0D0
C CHARGES IN BREMSSTRAHLUNG VERTICES TREATED SEPARATELY
        QE2=QE**2
        QF2=QF**2
        QINFI=QE*QF
        IF(KBRINI.EQ.0) QE2=0D0
        IF(KBRFIN.EQ.0) QF2=0D0
        IF(KBRINT.EQ.0) QINFI=0D0
      ENDIF
C
      SVAR=4D0*ENE**2
      IF (MODE.EQ.0) THEN
        IF(KEYRAD.NE.0) THEN
C****************************************
C** SOFT REAL AND VIRTUAL PHOTON CORRECTIONS - INITIALIZATION
          BILG=DLOG(SVAR/AMIN**2)
          BETI=2D0*QE2*ALF1*(BILG-1D0)
          DELI=ALF1*QE2*(9D0*BILG+2D0*PI**2-12D0)/6D0
     $        +BETI*LOG(XK0)
          BILGF=DLOG(SVAR/AMFIN**2)
          BETF =2D0*QF2*ALF1*(BILGF-1D0)
          DELF =ALF1*QF2*(9D0*BILGF+2D0*PI**2-12D0)/6D0
     $        +BETF*LOG(XK0)
          DELF0=ALF1*QF2*(9D0*BILGF
     $         +2D0*PI**2-16.5D0)/6D0 +BETF*LOG(XK0)
          UP=1D0+COSTHE
          UM=1D0-COSTHE
          ALP=LOG(UP/2D0)
          ALM=LOG(UM/2D0)
          DELINT=  4D0*(ALM-ALP)*LOG(XK0)
     $           + ALM**2-ALP**2-2D0*DILOGT(UM/2D0)+2D0*DILOGT(UP/2D0)
          DELINT=       QINFI*ALF1*DELINT
C EXTRA TERMS DUE TO NARROWNES OF Z0 RESONANCE
          GM=GAMMZ*AMZ/SVAR
          ZZ=1D0-AMZ**2/SVAR
          BETINT= 2D0*ALF1*(ALM-ALP)
          DEL2=(BETI+BETINT*QINFI)*
     $         (CDLOG(DCMPLX(ZZ,GM)) -CDLOG(DCMPLX((ZZ-XK0),GM)))
          DEL3=
     $         BETI*ZZ/GM*(ATAN((XK0-ZZ)/GM)-ATAN(-ZZ/GM))
     $        -BETI*(CDLOG(DCMPLX(ZZ,GM)) -CDLOG(DCMPLX((ZZ-XK0),GM)))
C
        ELSE
          DELI=0D0
          DELF=0D0
          DELINT=0D0
          DELF0=0D0
        ENDIF
      ENDIF
      IF (MODE.LE.1) THEN
C*** PROPAGATORS AND VACUUM POLARIZATIONS
        PROPA =CPRAM (MODE,SVAR)
        PROPZ =CPRZ0M(MODE,SVAR)
C* BORN SPIN AMPLITUDES
        DO 50 I=1,2
        DO 50 J=1,2
        REGULA= (3-2*I)*(3-2*J) + COSTHE
        APHOT(I,J)=PROPA*DCMPLX(XUPGI(I)*XUPGF(J)*REGULA)
        AZETT(I,J)=PROPZ*DCMPLX(XUPZI(I)*XUPZF(J)*REGULA)
   50   ABORN(I,J)=APHOT(I,J)+AZETT(I,J)
        IF(KEYRAD.NE.0) THEN
C****************************************
C* SPIN AMPLITUDES FOR BOX GAMMA-GAMMA
          IF (MODE.EQ.0) CALL BGAM2(COSTHE,ZZ1,ZZ2)
          DO 70 I=1,2
          DO 70 J=1,2
          HELPRO= (3-2*I)*(3-2*J)
          COEFB=PROPA*DCMPLX( XUPGI(I)*XUPGF(J) *.5D0*ALF1*QINFI )
   70     BOXGG(I,J)=COEFB*(DCMPLX(HELPRO)*ZZ1 + ZZ2)
C****************************************
C* SPIN AMPLITUDES FOR BOX GAMMA-ZED
C BOX GAMMA-Z0 VERSION OF PASCHOS ET. AL.
          IF (MODE.EQ.0) CALL BZED1(SVAR,AMZ,1D0,GAMMZ,COSTHE,XX1,XX2)
          DO 75 I=1,2
          DO 75 J=1,2
          HELPRO= (3-2*I)*(3-2*J)
          COEFB= PROPZ*DCMPLX( XUPZI(I)*XUPZF(J)*ALF1*QINFI )
   75     BOXGZ(I,J)=COEFB*( DCMPLX(HELPRO)*XX1 + XX2 )
C****************************************
        ENDIF
C****************************************
      ENDIF
C
C******************
C* IN CALCULATING CROSS SECTION ONLY DIAGONAL ELEMENTS
C* OF THE SPIN DENSITY MATRICES ENTER (LONGITUD. POL. ONLY.)
C* HELICITY CONSERVATION EXPLICITLY OBEYED
      POLAR1=  (SEPS1)
      POLAR2= (-SEPS2)
      BORN=0D0
      GGBOX=0D0
      GZBOX=0D0
      SOFBRM=0D0
      DO 150 I=1,2
      HELIC= 3-2*I
      DO 150 J=1,2
      HELIT=3-2*J
      FACTOR=KOLOR*(1D0+HELIC*POLAR1)*(1D0-HELIC*POLAR2)/4D0
      FACTOR=FACTOR*(1+HELIT*TA)*(1+HELIT*TB)
      BORN=BORN+CDABS(ABORN(I,J))**2*FACTOR
      IF(KEYRAD.NE.0) THEN
        GGBOX=GGBOX+2D0*DREAL( ABORN(I,J)*DCONJG(BOXGG(I,J)) )*FACTOR
        GZBOX=GZBOX+2D0*DREAL( ABORN(I,J)*DCONJG(BOXGZ(I,J)) )*FACTOR
        SOFBRM=SOFBRM
     $          +2D0*DREAL(ABORN(I,J)*DCONJG(AZETT(I,J)*DEL2))*FACTOR
     $              +DREAL(AZETT(I,J)*DCONJG(AZETT(I,J)*DEL3))*FACTOR
      ENDIF
  150 CONTINUE
C************
      IF (KEYRAD.GE.10) SOFBRM=0D0
      FUNT=BORN*(1D0+DELI+DELF+DELINT)+SOFBRM +GGBOX + GZBOX
      IF (MODE.EQ. 0)  FUNT=BORN*(1D0+DELI+DELF0)
      IF (MODE.EQ.-1)  FUNT=BORN
      IF(TA*TA.GT.0.5D0.AND.FUNT.LE.0.D0 ) FUNT=BORN
      IF(FUNT.LT.0.D0)  FUNT=0.D0
      FUNT=FUNT *SVAR**2
      FUNTIS =FUNT
      FUNTIM=0.0
C         IF (TA.EQ.0.AND.TB.EQ.0) THEN
C         IF (MODE.EQ.0) BUFINI=BORN
C         IF (MODE.EQ.0) BUFFIN=(1D0+DELI+DELF+DELINT)
C         IF (MODE.EQ.0) BUFINT=SOFBRM +GGBOX + GZBOX
C         IF (MODE.EQ.1) WRITE(6,*) '====='
C         IF (MODE.EQ.1) WRITE(6,*) 'INI',BORN,' ',BUFINI
C         IF (MODE.EQ.1) WRITE(6,*) 'INI',(1D0+DELI+DELF+DELINT),' ',BUFFIN
C         IF (MODE.EQ.1) WRITE(6,*) 'INI',SOFBRM +GGBOX + GZBOX,' ',BUFINT
C         ENDIF
      END
      SUBROUTINE BGAM2(COSTHE,ZZ1,ZZ2)
C ----------------------------------------------------------------------
C BOX GAMMA-GAMMA AS IN MUSTRAAL AND KORAL-B
C
C     called by : FUNTIS
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      COMPLEX*16 ZZ1,ZZ2
      DATA PI /3.141592653589793238462643D0/
C
      C=COSTHE
      UP=1D0+COSTHE
      UM=1D0-COSTHE
      ALP=LOG(UP/2D0)
      ALM=LOG(UM/2D0)
      XZ1=-C/UP*ALM**2-C/UM*ALP**2+ALM-ALP
      XZ2=-C/UP*ALM**2+C/UM*ALP**2+ALM+ALP
      YZ1=-2D0*PI*C/UP*ALM-2D0*PI*C/UM*ALP
      YZ2=-2D0*PI*C/UP*ALM+2D0*PI*C/UM*ALP+2D0*PI
      ZZ1=DCMPLX(  XZ1,  YZ1+2D0*PI*(ALM-ALP)   )
      ZZ2=DCMPLX(  XZ2,  YZ2+2D0*PI*(ALM-ALP)*C )
      END
      SUBROUTINE BZED1(SVAR,AMZ,XLAM,GAMMZ,COSTHE,ZED3,ZED4)
C ----------------------------------------------------------------------
C GAMMA-Z0 BOX   FROM W.BROWN, R. DECKER, E. PASHOS
C PHYS. REV. LETT. 52(1984)1192
C CALCULATES XX1 FOR BOX GAMA-Z
C
C     called by : FUNTIS
C ----------------------------------------------------------------------
      IMPLICIT COMPLEX*16 (A-Z)
      REAL*8 SVAR,AMZ,XLAM,GAMMZ,COSTHE
C
      E=DCMPLX(1.D0,0.D0)
      F=DCMPLX(1.D0,-1.D-4)
      CC=DCMPLX(COSTHE)
      MZ=DCMPLX(AMZ**2/SVAR,-AMZ*GAMMZ/SVAR)
      MGAM=DCMPLX(XLAM/SVAR,0.D0)
      T=-(1-CC)/2
      U=-(1+CC)/2
      A=2*(1-CC)*FIU(MGAM,MZ,U,T)
      B=2*(1+CC)*FIU(MGAM,MZ,T,U)
      D=-CDLN(T/U,E)*CDLN(MGAM,E)
      ZED3= A-B+D
      ZED4=-A-B+CC*D
      END
      FUNCTION FIU(MG,MZ,T,U)
C ----------------------------------------------------------------------
C FORMULA  (11)  FROM W.BROWN, R. DECKER, E. PASHOS
C PHYS. REV. LETT., 52 (1984), 1192
C Z0 PROPAGATOR REMOVED
C
C     called by : BZED1
C ----------------------------------------------------------------------
      IMPLICIT COMPLEX*16 (A-Z)
C
      E=DCMPLX(-1.D0,0.D0)
      FIU=1/(MZ-1)*((CDLN(CDSQRT(T*U)/MG,E)
     $ +2*CDLN((1-1/MZ),E))*CDLN((U/T),E)+SP((1+U/MZ),E)-SP((1+T/MZ),E))
     $ +  (U-T-MZ)/U/U*
     $    (CDLN((1-1/MZ),E)*CDLN((-T),E)+SP((1+T/MZ),E)-SP((1-1/MZ),E))
     $ +  1/U*((MZ-1)*CDLN((1-1/MZ),E)+CDLN(-T/MZ,E))
      FIU=-.25D0*(MZ-1)*FIU
      END
      FUNCTION CPRZ0M(MODE,S)
C ----------------------------------------------------------------------
C THIS FUNCTION SUPPLIES TO THE PROGRAM Z0 PROPAGATOR
C IT USES Z0 VACUUM POLARIZATION MEMORIZED IN THE FUNCTION CINTZZ.
C INPUT : S (GEV**2)   PHOTON ENERGY TRANSFER.
C         MODE -INTERNAL KEY IN THE ALGORITHM,
C
C     called by : FUNTIH, FUNTIS, FANTIH,FANTIS, BORNS, SANGLE, BDRESS,
C                 SKONTY, AMPGSW
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / GSWPRM /SWSQ,AMW,AMZ,AMH,AMTOP,GAMMZ
      REAL*8           SWSQ,AMW,AMZ,AMH,AMTOP,GAMMZ
C     SWSQ        = sin2 (theta Weinberg)
C     AMW,AMZ     = W & Z boson masses respectively
C     AMH         = the Higgs mass
C     AMTOP       = the top mass
C     GAMMZ       = Z0 width
      COMMON / KEYSET / KEYGSW,KEYRAD,KEYTAB
      COMPLEX*16 CPRZ0,SIGMA,CPRZ0M
C
          SIGMA=DCMPLX(0D0,S/AMZ*GAMMZ)
          CPRZ0=DCMPLX((S-AMZ**2),0D0)
          CPRZ0M=1/(CPRZ0+SIGMA)
      IF (KEYGSW.EQ.0) THEN
        CPRZ0M=DCMPLX(0.D0,0.D0)
      ENDIF

      END
      FUNCTION CPRAM(MODE,S)
C ----------------------------------------------------------------------
C THIS FUNCTION SUPPLIES TO THE PROGRAM PHOTON PROPAGATOR
C IT USES PHOTON VACUUM POLARIZATION MEMORIZED IN THE FUNCTION CINTAA.
C INPUT : S (GEV**2)   PHOTON ENERGY TRANSFER.
C         MODE -INTERNAL KEY IN THE ALGORITHM,
C
C     called by : FUNTIH, ....
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / KEYSET / KEYGSW,KEYRAD,KEYTAB
      COMPLEX*16 CVPAAM,CPRAM,CSVAR
C
      CSVAR=S
C      IF (KEYGSW.EQ.0) THEN
C        CPRAM=DCMPLX(0.D0,0.D0)
C      ELSE
      CVPAAM=DCMPLX(0D0,0D0)
      CPRAM=1D0/(CVPAAM+CSVAR)
C      ENDIF
      END
      SUBROUTINE PEDYPR(MODE,XXK,CC1,SS1,CC2,SS2,CCF,SSF,CCG,SSG)
C ----------------------------------------------------------------------
C THIS ROUTINE RECONSTRUCTS ANGULAR VARIABLES FROM THE 4- MOMETA
C STORED IN UTIL. FOR MODE = 0 ANGULAR VARIABLES ARE CALCULATED
C AND MEMORIZED. FOR HIGHER MODES THEY ARE SUPPLIED.
C
C     called by : WEIGHT, FUNTIH
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / UTIL8 / QP(4),QM(4),PH(4)
      REAL*8           QP   ,QM   ,PH
      COMMON / BEAMPM / ENE ,AMIN,AMFIN,IDE,IDF
      REAL*8            ENE ,AMIN,AMFIN
      REAL*8 PI1(4),PI2(4),PIX(4),PIY(4)
C
      IF (MODE.EQ.0) THEN
C     ===================
C INITIALIZATION OF THE ANGULAR VARIABLES
        XK=PH(4)/ENE
        IF (XK.GT.1.D-6) THEN
C
C HARD PHOTON CASE
          CALL MULSK(PH,PH,AMP2)
          AMP=SQRT(ABS(AMP2))
          C1=PH(3)/SQRT(PH(4)**2-AMP**2)
          S1=SQRT(1.D0-C1**2)
C CALCULATION OF C2 ---------------------------
          DO 7 KKK=1,4
          PI1(KKK)=QP(KKK)+QM(KKK)
   7      PI2(KKK)=QP(KKK)-QM(KKK)
          CALL MULSK(PH,QM,R)
          CALL MULSK(PH,QP,R1)
          CALL MULSK(PI1,PH,RV)
          CALL MULSK(PI2,PI2,RT)
          CALL MULSK(PI1,PI1,RU)
          C2=(R-R1)/SQRT(-RT)/SQRT(RV**2/RU-AMP**2)
          S2=SQRT(1.D0-C2**2)
C REDEFINITION OF XK
          XK=1D0-RU/4D0/ENE**2
C CALCULATION OF CG , SG -----------------------
          CG= PH(2)/SQRT(PH(1)**2+PH(2)**2)
          SG=-PH(1)/SQRT(PH(1)**2+PH(2)**2)
C CALCULATION OF CF ----------------------------
          PIX(1)=0.D0
          PIX(2)=0.D0
          PIX(3)=ENE
          PIX(4)=0.D0
C
          CALL MULVX(PH,QP,PI1)
          CALL MULVX(PH,PIX,PI2)
          CALL MULSK(PI1,PI2,R)
          CALL MULSK(PI1,PI1,R1)
          CALL MULSK(PI2,PI2,R2)
          CF=R/SQRT(R1*R2)
C CALCULATION OF SF ---------------------------
          CALL MULSK3(PH,QP,R)
          CALL MULSK3(PH,PIX,R1)
          CALL MULSK3(PH,PH,R3)
          DO 9 KKK=1,4
          PI1(KKK)=QP(KKK)-R/R3*PH(KKK)
   9      PI2(KKK)=PIX(KKK)-R1/R3*PH(KKK)
C
          CALL MULVX(PI1,PI2,PIY)
          CALL MULSK3(PH,PIY,R)
          CALL MULSK3(PI1,PI1,R1)
          CALL MULSK3(PI2,PI2,R2)
          SF=-R/SQRT(-R1*R2*R3)
        ELSE
C
C* SOFT PHOTON CASE
          C1=QP(3)/SQRT(1.D0-AMFIN**2/ENE**2)/ENE
          S1=SQRT(1.D0-C1**2)
          C2=1D0
          S2=0D0
          CF=1D0
          SF=0D0
C CALCULATION OF CG , SG -----------------------
          IF (QP(1)**2+QP(2)**2.GT.0D0) THEN
            CG= QP(2)/SQRT(QP(1)**2+QP(2)**2)
            SG=-QP(1)/SQRT(QP(1)**2+QP(2)**2)
          ELSE
C ZW 31.12.88 HERE WAS AN ERROR, FOR THE VERYLONG SERIES IT COULD HAPPEN
C             THAT C1=1D0. THIS WAS A PROBLEM LATER IN THE CALCULATION.
            CG=1D0
            SG=0D0
            C1=C1*0.9999999D0
          ENDIF
        ENDIF
      ENDIF
C     =====
C* SETTING VALUES (FOR ALL MODES)
C
      XXK=XK
      CC1=C1
      SS1=S1
      CC2=C2
      SS2=S2
      CCF=CF
      SSF=SF
      CCG=CG
      SSG=SG
      END
      SUBROUTINE MULVX(X,Y,R)
C ----------------------------------------------------------------------
C ROUTINE USED IN PEDYPR.
C IT CALCULATES VECTOR PRODUCT OF SPACE LIKE PARTS OF FOUR VECTORS
C
C     called by : PEDYVV,PEDYPR
C ----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      DIMENSION X(4),Y(4),R(4)
C
      R(4)=0.D0
      R(1)=X(2)*Y(3)-X(3)*Y(2)
      R(2)=X(3)*Y(1)-X(1)*Y(3)
      R(3)=X(1)*Y(2)-X(2)*Y(1)
      END
      SUBROUTINE MULSK(X,Y,R)
C ----------------------------------------------------------------------
C USED IN PEDYPR
C IT CALCULATES SCALAR PRODUCT OF FOUR VECTORS
C
C     called by : PEDYVV,PEDYPR,SANGLE,BDRESS,SKONTY
C ----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      DIMENSION X(4),Y(4)
      R=X(4)*Y(4)-X(3)*Y(3)-X(2)*Y(2)-X(1)*Y(1)
      END
      SUBROUTINE MULSK3(X,Y,R)
C ----------------------------------------------------------------------
C USED IN PEDYPR
C IT CALCULATES SCALAR PRODUCT OF SPACE LIKE PARTS OF FOUR VECTORS
C
C     called by : PEDYVV, PEDYPR
C ----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      DIMENSION X(4),Y(4)
C
      R=-X(3)*Y(3)-X(2)*Y(2)-X(1)*Y(1)
      END
      SUBROUTINE RRR6(XK,AM2,CG,SG,IBREM)
C ----------------------------------------------------------------------
C THIS IS FUNCTIONALLY THE SAME ROUTINE RRR6 AS IN MUSTRAAL.
C IT GENERATES PHOTON ANGLE AND THE BREMSSTRAHLUNG PARAMETER IBREM.
C
C     called by : EVENTE, EVENTM
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      REAL*4  RRR(3)
C
   10 CONTINUE
      CALL RANMAR(RRR,3)
C GENERATION OF THE RAW ANGULAR PHOTON DISTRIBUTION
      RN1=RRR(1)
      CALL ANGPHO(RN1,AM2,CG,SG)
C SHAPING ---- FIRST STEP
      EPS=AM2/(1.D0+SQRT(1.D0-AM2))
      BETA=SQRT(1.D0-AM2)
      DEL1=1.D0-CG*BETA
      DEL2=1.D0+CG*BETA
      DEL12=EPS/(1.D0-XK+1.D0/(1.D0-XK))*(DEL2/DEL1+DEL1/DEL2)
      RN2=RRR(2)
      IF(RN2.GT.(1.D0-DEL12)) GO TO 10
C
C SHAPING ---- SECOND STEP
      CHI1=(1.D0-.5D0*XK*DEL1)**2
      CHI2=(1.D0-.5D0*XK*DEL2)**2
      RN3=RRR(3)
      IF(RN3.GT.(CHI1+CHI2)/2.D0) GO TO 10
C
C CHOICE OF THE KINEMATICAL MODE
      IF(RN3.GT.CHI1/2.D0) THEN
        IBREM=1
      ELSE
        IBREM=-1
      ENDIF
      END
      SUBROUTINE ANGPHO(RN1,AM2,COSTHG,SINTHG)
C ----------------------------------------------------------------------
C THIS ROUTINE GENERATES PHOTON ANGULAR DISTRIBUTION
C IN THE REST FRAME OF THE FERMION PAIR. THE DISTRIBUTION
C IS TAKEN IN THE INFRAED LIMIT.
C INPUT : AM2 = 4*MASSF**2/S WHERE MASSF IS FERMION MASS
C               AND S IS FERMION PAIR EFFECTIVE MASS.
C OUTPUT: COSTHG, SINTHG, COS AND SIN OF THE PHOTON
C         ANGLE WITH RESPECT TO FERMIONS DIRECTION
C
C     called by : RRR6
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      REAL*4 RRR
C
      BETA=SQRT(1.D0-AM2)
      EPS=AM2/(1.D0+SQRT(1.D0-AM2))
      DEL1=(2.D0-EPS)*(EPS/(2.D0-EPS))**RN1
      DEL2=2.D0-DEL1
C SYMMETRIZATION
      CALL RANMAR(RRR,1)
      RN2=RRR
      IF(RN2.LE.0.5D0) THEN
        A=DEL1
        DEL1=DEL2
        DEL2=A
      ENDIF
C CALCULATION OF SIN AND COS THETA FROM INTERNAL VARIABLES
      COSTHG=(1.D0-DEL1)/BETA
      SINTHG=SQRT(DEL1*DEL2-AM2)/BETA
      END
      SUBROUTINE RRR7(P,C,S)
C ----------------------------------------------------------------------
C THIS SUBPROGRAM GENERATES (1-C)**2 OR (1+C)**2 DISTRIBUTION
C WITH PROBABILITY  P AND  1-P
C
C     called by : EVENTM
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      REAL*4 RRR
C
 5    CONTINUE
      CALL RANMAR(RRR,1)
      X=RRR
      Z=0.D0
      IF(X.GT.P) Z=1.D0
      R=(X-Z*P)/(Z-P)
      C=(1.D0-2.D0*Z)*(1.D0-ABS(8.D0*R)**(1.D0/3.D0))
      S=SQRT(1-C*C)
      IF (S.LE.0.0) GOTO 5
      END
      SUBROUTINE GIQSU(CMSENE,PHSUM,QSU)
C ----------------------------------------------------------------------
C GIVEN CMS ENERGY (CMSENE) AND PHOTON SYSTEM TOTAL FOURMOM. (PHSUM)
C PROVIDES 4-MOMENTUM OF FERMION SYSTEM (QSU)
C
C     called by : TRALOZ
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      REAL*8 PHSUM(4),QSU(4)
C
      QSU(1)=       -PHSUM(1)
      QSU(2)=       -PHSUM(2)
      QSU(3)=       -PHSUM(3)
      QSU(4)=CMSENE -PHSUM(4)
*======================================================================
*==================END OF YFSGEN=======================================
*======================================================================
      END
      SUBROUTINE DUMPZ4(JK,PP)
C ----------------------------------------------------------------------
C PRINTS SINGLE FOUR MOMENTUM
C
C     called by :
C ----------------------------------------------------------------------
      COMMON / INOUT / INUT,IOUT
      REAL*4 PP(4)
C
      AMS=PP(4)**2
      DO 10 I=1,3
   10 AMS=AMS-PP(I)**2
      IF(AMS.GT.0.0) AMS=SQRT(AMS)
      WRITE (IOUT,1000)
      WRITE (IOUT,1502) JK,(PP(I),I=1,4),AMS
 1000 FORMAT(1X,'* DUMPZ4 *-------',8(10H----------))
 1502 FORMAT(10X,I6,3X,'FOURMOMENTUM  ',5(1X,F12.5))
C======================================================================
C================END OF JMCLIB=========================================
C======================================================================
      END
      SUBROUTINE DUMPZ8(CH,PP)
C ----------------------------------------------------------------------
C PRINTS SINGLE FOUR MOMENTUM
C
C     called by : PEDYVV, TRAAAA, EVENTE, ...
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / INOUT / INUT,IOUT
      REAL*8 PP(4)
      CHARACTER*4 CH
C
      AMS=PP(4)**2
      DO 10 I=1,3
   10 AMS=AMS-PP(I)**2
      IF(AMS.GT.0.0) AMS=SQRT(AMS)
      WRITE(IOUT,*) '--------------------------------------------------'
      WRITE(IOUT,1502) CH,(PP(I),I=1,4),AMS
 1502 FORMAT(1X,A4,1X,4F15.10,F10.6)
      END
      SUBROUTINE DUMPL9(QP,QM,PH)
C ----------------------------------------------------------------------
C FOR TESTS
C PRINT MOMENTA OF THE PRODUCTION PROCESS
C
C     called by : KORALZ, SANGLE, BDRESS, SKONTY
C ----------------------------------------------------------------------
      IMPLICIT REAL  (A-H,O-Z)
      DIMENSION QP(4),QM(4),PH(4)
      DIMENSION SUM(4)
      DATA ICONT/0/
C
      ICONT=ICONT+1
      IF (ICONT.GT.200) RETURN
      DO 30 I=1,4
  30  SUM(I)=QP(I)+QM(I)+PH(I)
      PRINT      1100,ICONT
      AQP=     QP(4)**2-QP(3)**2-QP(2)**2-QP(1)**2
      AQM=     QM(4)**2-QM(3)**2-QM(2)**2-QM(1)**2
      APH=     PH(4)**2-PH(3)**2-PH(2)**2-PH(1)**2
      IF(AQP.GT.0.) AQP=SQRT(AQP)
      IF(AQM.GT.0.) AQM=SQRT(AQM)
      PRINT 1501, (QP(I),I=1,4),AQP
      PRINT 1502, (QM(I),I=1,4),AQM
      PRINT 1503, (PH(I),I=1,4),APH
      PRINT 1600, ( SUM(I),I=1,4)
 1100 FORMAT(  /20X,'MOMENTA FROM UTIL9,     PRINT NO.  ',I5/
     &40X,'  P(1)',7X,'  P(2)',7X,'  P(3)',7X,'  P(4)',7X,'  MASS')
 1501 FORMAT(20X,'QP  ',9X,5(1X,F12.5))
 1502 FORMAT(20X,'QM  ',9X,5(1X,F12.5))
 1503 FORMAT(20X,'PH  ',9X,5(1X,F12.5))
 1600 FORMAT(20X,'SUM ',9X,5(1X,F12.5),/)
      END
      SUBROUTINE DUMPL8
C ----------------------------------------------------------------------
C FOR TESTS
C PRINT MOMENTA OF THE PRODUCTION PROCESS
C
C     called by :
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / UTIL8 / QP(4),QM(4),PH(4)
      REAL*8           QP   ,QM   ,PH
      DIMENSION SUM(4)
      DATA ICONT/0/
C
      ICONT=ICONT+1
      DO 30 I=1,4
  30  SUM(I)=QP(I)+QM(I)+PH(I)
      PRINT      1100,ICONT
      AQP=     QP(4)**2-QP(3)**2-QP(2)**2-QP(1)**2
      AQM=     QM(4)**2-QM(3)**2-QM(2)**2-QM(1)**2
      APH=     PH(4)**2-PH(3)**2-PH(2)**2-PH(1)**2
      IF(AQP.GT.0.) AQP=SQRT(AQP)
      IF(AQM.GT.0.) AQM=SQRT(AQM)
      PRINT 1501, (QP(I),I=1,4),AQP
      PRINT 1502, (QM(I),I=1,4),AQM
      PRINT 1503, (PH(I),I=1,4),APH
      PRINT 1600, ( SUM(I),I=1,4)
 1100 FORMAT(  /20X,'MOMENTA FROM UTIL8,     EVENT NO.  ',I5/
     &40X,'  P(1)',7X,'  P(2)',7X,'  P(3)',7X,'  P(4)',7X,'  MASS')
 1501 FORMAT(20X,'QP  ',9X,5(1X,F12.5))
 1502 FORMAT(20X,'QM  ',9X,5(1X,F12.5))
 1503 FORMAT(20X,'PH  ',9X,5(1X,F12.5))
 1600 FORMAT(20X,'SUM ',9X,5(1X,F12.5),/)
      END
      SUBROUTINE VESK8A(MODE,PAR1,PAR2)
C ----------------------------------------------------------------------
C======================================================================
C======================================================================
C===================*** EXPLIB ***=====================================
C=========GENERAL PURPOSE LIBRARY OF THE MONTE CARLO ==================
C================AND LORENTZ KINEMATICS================================
C============= BY  S. JADACH,  APRIL 1986==============================
C======================================================================
C===================== V E S K 8 A ====================================
C==================S. JADACH  SEPTEMBER 1985===========================
C======================================================================
C ONE DIMENSIONAL MONTE CARLO  SAMPLER.
C DOUBLE PRECISION  FUNCTION FUNSKO IS THE DISTRIBUTION TO BE GENERATED
C JLIM1 IS THE NUMBER OF ENTRIES IN THE EQUIDISTANT LATICE WHICH
C IS FORMED IN THE FIRST STAGE AND JLIM2 IS THE TOTAL MAXIMUM
C NUMBER OF ENTRIES IN THE LATTICE, NOTE THAT DIMENSIONS OF
C MATRICES IN /CESK8A/ SHOULD BE AT LEAST JLIM2+1 .
C FOR MILD FUNSKO JLIM2=128 IS ENOUGH.
C TO CREATE AN INDEPENDANT VERSION REPLACE /ESK8A/=>/ESK8B/.
C
C     called by : EVENTM, KARLUD
C ----------------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON / CESK8A / XX(1025),YY(1025),ZINT(1025),ZSUM,JMAX
      COMMON / INOUT / INUT,IOUT
      REAL*4 RRR(2)
C ZW change grid of lattice from (16, 257) to (64,1024) July 4,1997
      DATA JLIM1,JLIM2/64,1024/
      DATA IWARM/0/
C
      IF(MODE.EQ.-1) THEN
C     ===================
C INITIALISATION PART, SEE VINSKO FOR MORE COMMENTS
        INIRAN=1
        IWARM=1
        WT=0.
        SWT=0.
        SSWT=0.
        NEVS=0
C INITIALISATION PART, SAMPLING DISTRIBUTION FUNSKO
C AND FILLING MATRICES XX,YY,ZINT ETC.
        JMAX=1
        XX(1)=0.
        XX(2)=1.
        YY(1)=FUNSKA(0,XX(1))
        YY(2)=FUNSKA(0,XX(2))
        IF(YY(1).LT.0.0.OR.YY(2).LT.0.0) GO TO 999
        ZINT(1)=.5D0*(YY(2)+YY(1))*(XX(2)-XX(1))
C
        JDIV=1
        DO 200 K=1,JLIM2-1
        IF(JMAX.LT.JLIM1) THEN
C...      NOTE THAT DESK8A INCREMENTS JMAX=JMAX+1 IN EVERY CALL
          CALL DESK8A(JDIV)
          JDIV=JDIV+2
          IF(JDIV.GT.JMAX) JDIV=1
        ELSE
          JDIV=1
          ZMX=ZINT(1)
          DO 180 J=1,JMAX
          IF(ZMX.LT.ZINT(J)) THEN
            ZMX=ZINT(J)
            JDIV=J
          ENDIF
  180     CONTINUE
          CALL DESK8A(JDIV)
        ENDIF
  200   CONTINUE
C
C...    FINAL ADMINISTRATION, NORMALIZING ZINT ETC.
        ZSUM1=0.
        ZSUM =0.
        DO 220 J=1,JMAX
        ZSUM1=ZSUM1+ZINT(J)
        YMAX= MAX( YY(J+1),YY(J))
        ZINT(J)=YMAX*(XX(J+1)-XX(J))
  220   ZSUM=ZSUM+ZINT(J)
        SUM=0.
        DO 240 J=1,JMAX
        SUM=SUM+ZINT(J)
  240   ZINT(J)=SUM/ZSUM
C
      ELSE IF(MODE.EQ.0) THEN
C     =======================
C GENERATION PART
        IF(IWARM.EQ.0) GOTO 901
  222 CONTINUE
        CALL RANMAR(RRR,2)
        IF(WT.GT.1.) THEN
          WT=WT-1.D0
        ELSE
          RNUMB=RRR(1)
          DO 215 J=1,JMAX
          JSTOP=J
  215     IF(ZINT(J).GT.RNUMB) GOTO 216
  216     CONTINUE
          IF(JSTOP.EQ.1) THEN
            D=RNUMB/ZINT(1)
          ELSE
            D =(RNUMB-ZINT(JSTOP-1))/(ZINT(JSTOP)-ZINT(JSTOP-1))
          ENDIF
          X=XX(JSTOP)*(1.D0 -D )+XX(JSTOP+1)*D
          FN=FUNSKA(0,X)
          IF(FN.LT.0.) GOTO 999
          YYMAX=MAX(YY(JSTOP+1),YY(JSTOP))
          WT=FN/YYMAX
          NEVS=NEVS+1
          SWT=SWT+WT
          SSWT=SSWT+WT*WT
C         CALL HFILL(40,WT)
        ENDIF
        RNUMB=RRR(2)
        IF(RNUMB.GT.WT) GOTO 222
        PAR1=  X
        PAR2=  FN
C
      ELSE IF(MODE.EQ.1) THEN
C     =======================
C FINAL STATISTICS
        CINTEG=ZSUM*SWT/FLOAT(NEVS)
        ERRINT=SQRT(SSWT/SWT**2-1.D0/FLOAT(NEVS))
        PAR1=  CINTEG
        PAR2=  ERRINT
C
      ELSE
C     ====
        GOTO  902
      ENDIF
C     =====
C
      RETURN
 901  WRITE(IOUT,9010)
 9010 FORMAT(' **** STOP IN VESK8A, LACK OF INITIALISATION')
      STOP
 902  WRITE(IOUT,9020)
 9020 FORMAT(' **** STOP IN VESK8A, WRONG MODE ')
      STOP
 999  WRITE(IOUT,9990)
 9990 FORMAT(' **** STOP IN VESK8A, NEGATIVE VALUE OF FUNSKO ')
      STOP
      END
      SUBROUTINE DESK8A(JDIV)
C ----------------------------------------------------------------------
C THIS ROUTINE BELONGS TO VESK8A PACKAGE
C IT SUDIVIDES INTO TWO EQUAL PARTS THE INTERVAL
C (XX(JDIV),XX(JDIV+1))  IN THE LATTICE
C
C     called by : VESK8A
C ----------------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON / INOUT / INUT,IOUT
      COMMON / CESK8A / XX(1025),YY(1025),ZINT(1025),ZSUM,JMAX
C
      XNEW=.5D0*(XX(JDIV) +XX(JDIV+1))
      DO 100 J=JMAX,JDIV,-1
      XX(J+2)  =XX(J+1)
      YY(J+2)  =YY(J+1)
  100 ZINT(J+1)=ZINT(J)
      XX(JDIV+1)= XNEW
      YY(JDIV+1)= FUNSKA(0,XNEW)
      IF(YY(JDIV+1).LT.0.) GOTO 999
      ZINT(JDIV)  =.5D0*(YY(JDIV+1)+YY(JDIV)  )*(XX(JDIV+1)-XX(JDIV)  )
      ZINT(JDIV+1)=.5D0*(YY(JDIV+2)+YY(JDIV+1))*(XX(JDIV+2)-XX(JDIV+1))
      JMAX=JMAX+1
      RETURN
  999 WRITE(IOUT,9000)
 9000 FORMAT(' **** STOP IN DESK8A, NEGATIVE VALUE OF FUNSKO ')
      STOP
      END
      FUNCTION SP(Y,E)
C ----------------------------------------------------------------------
C  SPENCE FUNCTION OF Y+I*REAL(E) WHERE E IS AN INFINITESIMAL
C
C     called by : FIU, MATELM, ...
C ----------------------------------------------------------------------
C     IMPLICIT LOGICAL (A-H,O-Z)
      IMPLICIT REAL*8  (A-H,O-Z)
      COMPLEX*16 Y,E,SP
      REAL*8 B(9),FACT
      COMPLEX*16 A,CLN,PISQ6,PROD,TERM,X,Z,ZSQ
      COMPLEX*16 CDLN
C
      B(1)=1.D0/6.D0
      B(2)=-1.D0/30.D0
      B(3)=1.D0/42.D0
      B(4)=B(2)
      B(5)=5.D0/66.D0
      B(6)=-691.D0/2730.D0
      B(7)=7.D0/6.D0
      B(8)=-3617.D0/510.D0
      B(9)=43867.D0/798.D0
      PISQ6=(1.6449340668482264D0,0.D0)
      I1=0
      I2=0
      X=Y
      A=E
      IF(X.EQ.(0.D0,0.D0))THEN
        SP=(0.D0,0.D0)
        RETURN
      ENDIF
      IF(X.EQ.(1.D0,0.D0))THEN
        SP=PISQ6
        RETURN
      ENDIF
C  IF X LIES OUTSIDE THE UNIT CIRCLE THEN EVALUATE SP(1/X)
      IF(CDABS(X).GT.1.D0)THEN
        X=1.D0/X
        A=-A
        I1=1
      ENDIF
C  IF REAL(X)>1/2 THEN EVALUATE SP(1-X)
      IF(DREAL(X).GT.0.5D0)THEN
        X=1.D0-X
        A=-A
        I2=1
      ENDIF
C  EVALUATE SERIES FOR SP(X)
      Z=-CDLN(1.D0-X,-A)
      ZSQ=Z*Z
      SP=Z-ZSQ/4.D0
      PROD=Z
      FACT=1.D0
      DO 10 J=2,18,2
      FACT=FACT*DCMPLX(DBLE((J+1)*J))
      PROD=PROD*ZSQ
      TERM=B(J/2)/FACT*PROD
      SP=SP+TERM
      IF(CDABS(TERM/SP).LT.1.D-20)GO TO 20
10    CONTINUE
C  ADD APPROPRIATE LOGS TO OBTAIN SPENCE FUNCTION OF ORIGINAL ARGUEMENT
20    IF(I2.EQ.1)THEN
        SP=-SP+PISQ6-CDLN(X,A)*CDLN(1.D0-X,-A)
        X=1.D0-X
        A=-A
      ENDIF
      IF(I1.EQ.1)THEN
        CLN=CDLN(-X,-A)
        SP=-SP-PISQ6-CLN*CLN/2.D0
      ENDIF
      RETURN
      END
      DOUBLE PRECISION FUNCTION DLI2(X)
C ----------------------------------------------------------------------
C DILOGARITHM FOR X <= 1, APPROPRIATE FOR VALUES VERY CLOSE TO 0
C
C     called by : AIMPI
C ----------------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMPLEX*16 SP
C
      IF (DABS(X).LE.1.D-15) THEN
        DLI2=X
      ELSE
        DLI2=DREAL(SP(DCMPLX(X),DCMPLX(.1D1)))
      ENDIF
      RETURN
      END
      FUNCTION CDLN(X,A)
C ----------------------------------------------------------------------
C  COMPLEX FUNCTIONS THAT TAKE ACCOUNT OF THE I*EPSILON PRESCRIPTION
C              TO CALCULATE ANALYTIC STRUCTURE
C
C  COMPLEX LOGARITHM OF X+I*REAL(A) WHERE A IS AN INFINITESIMAL
C
C     called by : BZED1, FIU, MATELM, ...
C ----------------------------------------------------------------------
C     IMPLICIT LOGICAL (A-H,O-Z)
      IMPLICIT REAL*8  (A-H,O-Z)
      COMPLEX*16 A,X,CDLN
      COMPLEX*16 PI
      PI=(3.141592653589793238462643D0,0.D0)
      IF(DIMAG(X).EQ.0.D0.AND.DREAL(X).LE.0.D0)THEN
        CDLN=CDLOG(-X)+(0.D0,1.D0)*PI*DSIGN(1.D0,DREAL(A))
      ELSE
        CDLN=CDLOG(X)
      END IF
      IF(DIMAG(CDLN).GT.DREAL(PI))CDLN=CDLN-(0.D0,1.D0)*PI
      IF(DIMAG(CDLN).LT.DREAL(-PI))CDLN=CDLN+(0.D0,1.D0)*PI
      RETURN
      END

C=============================================================
C=============================================================
C==== end of elementary file =================================
C=============================================================
C=============================================================
      SUBROUTINE EVENTE(MODE,KEYYFS)
C ----------------------------------------------------------------------
C  MULTIPHOTON GENERATOR
C
C     called by : EVENTZ
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / INOUT / INUT,IOUT
      COMMON / BEAMPM / ENE ,AMIN,AMFIN,IDE,IDF
      REAL*8            ENE ,AMIN,AMFIN
      COMMON / QEDPRM /ALFINV,ALFPI,XK0
      REAL*8           ALFINV,ALFPI,XK0
      COMMON / GAUSPM /SS,POLN,T3E,QE,T3F,QF
     &                ,XUPGI   ,XUPZI   ,XUPGF   ,XUPZF
     &                ,NDIAG0,NDIAGA,KEYA,KEYZ
     &                ,ITCE,JTCE,ITCF,JTCF,KOLOR
      REAL*8           SS,POLN,T3E,QE,T3F,QF
     &                ,XUPGI(2),XUPZI(2),XUPGF(2),XUPZF(2)
      COMMON / FINUS / CSTCM,ERREL
      REAL*8           CSTCM,ERREL
      COMMON / UTIL2 /  XK,C,S,CG,SG
      COMMON / UTIL3 / FIG,FI,IT,IBREM
      COMMON / UTIL8 / QP(4),QM(4),PH(4)
      REAL*8           QP   ,QM   ,PH
      COMMON / UTIL4 / AQP(4),AQM(4),APH(4)
      REAL*4           AQP   ,AQM   ,APH
      COMMON / MOMSET / QF1(4),QF2(4),SPHUM(4),SPHOT(100,4),NPHOT
      COMMON / MOMINI / XF1(4),XF2(4),XPHUM(4),XPHOT(100,4),NPHOX
      COMMON / MOMSE4 / AQF1(4),AQF2(4),ASPHUM(4),ASPHOT(100,4),NPHOTA
      REAL*4            AQF1   ,AQF2   ,ASPHUM   ,ASPHOT
      COMMON / GSWPRM /SWSQ,AMW,AMZ,AMH,AMTOP,GAMMZ
      REAL*8           SWSQ,AMW,AMZ,AMH,AMTOP,GAMMZ
      COMMON / KEYSET / KEYGSW,KEYRAD,KEYTAB
      COMMON / VVREK  / VVMIN,VVMAX,VV,BETI
      REAL*8            VVMIN,VVMAX,VV,BETI
      DOUBLE PRECISION  WTMOD,WTCRU1,WTCRU2,WTSET
      COMMON / WGTALL / WTMOD,WTCRU1,WTCRU2,WTSET(100)
      DIMENSION  XPAR(30),NPAR(30)
      REAL*8 PPB(4),PMB(4)
      REAL*4 RRR(4)
      COMMON / KBREMS / KBRINI,KBRFIN,KBRINT
      DATA CMTR /389.385D-30/
      DATA NEXPAN /0/
C
C GENERATION OF THE PHOTON MOMENTUM XK AND DECISION ABOUT THE
C TYPE OF THE RADIATION  IT=1,2,3 CORRESPONDS TO INITIAL STATE
C RADIATION, FINAL STATE RADIATION AND SOFT PHOTON (XK.LT.XK0)
C RADIATION
C
C     INITIALIZATION IN EVENTE
      IF (MODE.EQ.-1) THEN
C       ====================
        CALL WMONIT(  -1,13,DUMM1,DUMM2,DUMM3)
        PI=4.D0*DATAN(1.D0)
        ALF1=ALFPI
        IF(KEYRAD.EQ.0.OR.KBRINI.EQ.0) THEN
          BETI=0D0
          DELI=0D0
        ELSE
          QE2=QE*QE
          BILG   = DLOG(4D0*ENE**2/AMIN**2)
          BETI=2D0*QE2*ALF1*(BILG-1D0)
          DELI=ALF1*QE2*(9D0*BILG+2D0*PI**2-12D0)/6D0
     $        +BETI*LOG(XK0)
        ENDIF
        IF(KEYRAD.EQ.0.OR.KBRFIN.EQ.0) THEN
          FACTOR=0D0
        ELSE
          FACTOR=1D0
          FACTOR=FACTOR*QF*QF
        ENDIF
C
C INITIALISE EXPAND
      IF (KEYRAD.GT.100) THEN
                  NPAR(1)=1000001
      ELSE
                  NPAR(1)=KEYYFS
      ENDIF
      KEYRED=0
              NPAR(2)=KEYRED
C KEYWGT=0 is standard choice. 1 weigted events (tests only)
      KEYWGT=0
              NPAR(3)=KEYWGT
              NPAR(4)=KEYGSW
             XPAR(1)=2D0*ENE
             XPAR(2)=AMZ
             XPAR(3)=SWSQ
             XPAR(4)=GAMMZ
             XPAR(5)=AMFIN
             XPAR(6)=VVMIN
             XPAR(7)=VVMAX
        CALL EXPAND(-1,XPAR,NPAR)
C
      ELSEIF (MODE.EQ.0) THEN
C     =======================
    1   CONTINUE
        CALL RANMAR(RRR,4)
        CALL EXPAND( 0,XPAR,NPAR)
        IF (WTMOD.LE.1D-78) goto 1
C       ---------------------------------
C
C FILLING EXTRA COMMONS
        DO 39 I=1,4
        QP(I)=QF1(I)
        QM(I)=QF2(I)
        PH(I)=SPHUM(I)
        AQP(I)=QP(I)
        AQM(I)=QM(I)
 39     APH(I)=PH(I)
        WT=1D0
        WTMAX=1.0100D0
        IF(KEYGSW.GT.1) THEN
             WT =WAGA(0,0.0D0,0.D0)
             WT =WAGA(1,0.0D0,0.D0)/WT
             WTMAX=2D0
        ELSE
             WTDUMM=WAGA(0,0.D0,0.D0)
        ENDIF
        IF (KEYRAD.GT.100) WT=WT*(1D0+0.75*ALF1*QF**2)
        RN=RRR(1)
        CALL WMONIT(0,13,WT ,WTMAX,RN)
        IF(RN.GT.WT/WTMAX) GOTO 1
C
        IF (KEYRAD.EQ.11.OR.KEYRAD.GT.100) THEN
          CALL BDRESS(0,PPB,PMB,SVARX,CTHE)
        ELSE
          SVARX=5.0
          CTHE=0.0
        ENDIF
        IF (KEYRAD.GT.100.AND.KBRFIN.NE.0) THEN
C         PHOTON ENERGY GENERATION - FINAL BREMSSTRAHLUNG
 333      XK=ALTPAR(SVARX,AMFIN,XK0,FACTOR)
          IF (XK.GT.1D0-4D0*AMFIN**2/SVARX) GO TO 333
        ELSE
          XK=0D0
        ENDIF
        IT=3
        IF (XK.GT.XK0) THEN
          IT=2
C HARD PHOTON CASE - FINAL STATE
C         PHOTON ANGULAR COORDINATES GENERATION
          CALL RRR6(XK,4D0*AMFIN**2/SVARX/(1D0-XK),CG,SG,IBREM)
C         FERMION ANGULAR COORDINATES
          C=CTHE
C         IF (ABS(CTHE).GE.1D0) PRINT *, 'DUZE CTHE',CTHE,'S=',SVARX
          IF (ABS(CTHE).GE.1D0) C=CTHE/ABS(CTHE)
          S=SQRT(1D0-C*C)
C         GENERATION OF THE ANGLE BETWEEN PHOTON-BEAM AND PHOTON-TAU PL
          RR2=RRR(2)
          FIG=-PI+2D0*PI*RR2
C
C         GENERATION OF THE ANGLE AROUND THE BEAM
          RR3=RRR(3)
          FI=-PI+2D0*PI*RR3
C         CALCULATION OF 4 MOMENTA FROM ANGULAR VARIABLES
          QP(4)=AMFIN
          PH(4)=SQRT(SVARX)
          QM(4)=AMFIN
          DO 103 I=1,3
          PH(I)=.0D0
          QP(I)=.0D0
  103     QM(I)=.0D0
          EBEAM=SQRT(SVARX)/2D0
          CALL TRASNG(1,EBEAM,AMFIN,AMIN,1,QP,QP)
          CALL TRASNG(1,EBEAM,AMFIN,AMIN,2,QM,QM)
          DO 304 I=1,4
  304     PH(I)=PH(I)-QP(I)-QM(I)
          CALL TRALOZ(0,-1,2D0*ENE    ,SPHUM,PPB,PMB,QP,QP)
          CALL TRALOZ(1,-1,2D0*ENE    ,SPHUM,PPB,PMB,QM,QM)
          CALL TRALOZ(1,-1,2D0*ENE    ,SPHUM,PPB,PMB,PH,PH)
          NPHOT=NPHOT+1
          DO 35 I=1,4
          SPHUM(I)=SPHUM(I)+PH(I)
          SPHOT(NPHOT,I)=PH(I)
          QF2(I)=QM(I)
  35      QF1(I)=QP(I)
        ELSEIF ( XK.LE.XK0) THEN
C         FERMION ANGULAR COORDINATES
          C=CTHE
        DO 49 I=1,4
        QP(I)=QF1(I)
        QM(I)=QF2(I)
 49     CONTINUE

          IF (ABS(CTHE).GE.1D0) C=CTHE/ABS(CTHE)
          S=SQRT(1D0-C*C)
C IN THE FOLLOWING WE WILL PERFORM TRANSFORMATION ON THE
C 4-MOMENTA GENERATED IN YFS-2 PROGRAM. THE PURPOSE IS TO HAVE
C 4-MOMENTA OF TAU PAIR TREATED EXACTLY THE SAME WAY AS DECAY
C PRODUCTS TO AVOID ROUNDING ERRORS.
          CALL TRALOZ(0, 1,2D0*ENE    ,SPHUM,PPB,PMB,QP,QP)
          FI =ANGXY(QP(2),QP(1))
          IF (QP(1).LT.0.D0) FI =-FI
C         CALCULATION OF 4 MOMENTA FROM ANGULAR VARIABLES
          QP(4)=AMFIN
          QM(4)=AMFIN
          DO 108 I=1,3
          QP(I)=.0D0
  108     QM(I)=.0D0
          EBEAM=SQRT(SVARX)/2D0
          CALL TRASNG(1,EBEAM,AMFIN,AMIN,1,QP,QP)
          CALL TRASNG(1,EBEAM,AMFIN,AMIN,2,QM,QM)
          CALL TRALOZ(1,-1,2D0*ENE    ,SPHUM,PPB,PMB,QP,QP)
          CALL TRALOZ(1,-1,2D0*ENE    ,SPHUM,PPB,PMB,QM,QM)
          DO 36 I=1,4
          QF2(I)=QM(I)
  36      QF1(I)=QP(I)
        ENDIF
C
C FILLING EXTRA COMMONS
        DO 30 I=1,4
        QP(I)=QF1(I)
        QM(I)=QF2(I)
        PH(I)=SPHUM(I)
        AQP(I)=QP(I)
        AQM(I)=QM(I)
 30     APH(I)=PH(I)
        NPHOTA=NPHOT
        DO 45 I=1,4
        AQF1(I)=QF1(I)
        AQF2(I)=QF2(I)
        ASPHUM(I)=SPHUM(I)
        DO 46 II=1,100
 46     ASPHOT(II,I)=SPHOT(II,I)
 45     CONTINUE
C
C for tests on bossting spinning with final state brem.
C if next line commented out no effect should be seen.
      IF (KEYRAD.GT.100) WTDUMM=WAGA(0,0.D0,0.D0)
      ELSEIF (MODE.EQ. 1) THEN
C     ========================
        IF (NEXPAN.EQ.0) THEN
          CALL EXPAND( 1,XPAR,NPAR)
          CALL EXPAND( 2,XPAR,NPAR)
          SIGT=XPAR(10)
          SIGT=XPAR(12)
          ERR=XPAR(11)
          NEXPAN=1
        ENDIF
        WRITE(IOUT,*) '=========================================='
        WRITE(IOUT,*) '========= WEIGHTS IN EVENTE =============='
        WRITE(IOUT,*) '=========================================='
        CALL WMONIT(2,13,AWT,DWT,WMX)
        CALL WMONIT(1,13,AWT,DWT,WMX)
        CSTOT=SIGT*AWT
        SIG0=4.D0*PI/ALFINV**2/3.D0/(4D0*ENE**2)
        CSTCM=SIGT*AWT*SIG0*CMTR
        ERREL=SQRT(DWT**2+ERR**2)
      ENDIF
C     =====
      END
C=============================================================
C=============================================================
C==== end of directory ===== =================================
C=============================================================
C=============================================================
C new version january 1992
C VERSION FEBRUARY 1990
C VERSION FROM CERN 28 NOV 89
C FYFS CORRECTED
C BETA1 FOR FINA STATE TO BE CORRECTED, NO MODIFICATIONS DUE E.W.
C.... XXKARL NOT A MODEL PARAMETER ANY MORE
C.....monitoring weight shifted to MONIN
C COSMETIC CHANGE IN GIFYFS
C !!!!!!!  LOGBOOK of correction !!!!
*** PRAMETER an IMPLICIT interchanged in UURHO
*** VVRHO and UURHO are made to be exactly the same as in YFSFIG

C----------------------------------------------------------------------
C---------------Model for initial + final------------------------------
C----------------------------------------------------------------------
      SUBROUTINE MODEL(MODE,PAR1,PAR2)
C     ********************************
C THIS ROUTINE DEFINES WEIGHT FOR A MODEL TO BE IMPLEMENTED
C ON TOP OF BASIC DISTRIBUTION FROM KARLUD
C Above VLIM1/2 the contribution from beta1/2 is not calculated,
C This saves time, for precision 1D-4 use VLIM1=1.D-4 and VLIM2=0.04
C              and for precision 1D-3 use VLIM1=1.D-3 and VLIM2=0.12
C     **********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER(NPMX=25)
      PARAMETER(VLIM1= 1.D-9, VLIM2= 1.D-9)
      COMMON / MOMINI / XF1(4),XF2(4),XPHUM(4),XPHOT(100,4),NPHOX
      COMMON / MOMFIN / QF1(4),QF2(4),YPHUM(4),YPHOT(100,4),NPHOY
      COMMON / WEKING / ENE,AMAZ,GAMMZ,AMEL,AMFIN,XK0,SINW2,IDE,IDF
      COMMON / KEYYFS / KEYZET,KEYBRM,KEYFIX,KEYRED,KEYWGT
      COMMON / WGTALL / WTMOD,WTCRU1,WTCRU2,WTSET(100)
      COMMON / INOUT  / NINP,NOUT
      SAVE / MOMINI /,/ MOMFIN /,/ WEKING /,/ KEYYFS /
      SAVE / WGTALL /,/ INOUT  /
C Spying on weights.........
      COMMON / BETSPY / BETA00,BETA01,BETA02,BETI01,BETI02,
     $  BETA10(NPMX),BETA11(NPMX),BETA20(NPMX,NPMX),
     $  SFACX(NPMX),SFACY(NPMX),
     $  BETX10(NPMX),BETX11(NPMX),BETY10(NPMX),BETY11(NPMX),
     $  BETXX20(NPMX,NPMX),BETXY20(NPMX,NPMX),BETYY20(NPMX,NPMX),
     $  BETI10(NPMX),BETI11(NPMX),BETI20(NPMX,NPMX),
     $  BETF10(NPMX),BETF11(NPMX),BETF20(NPMX,NPMX)
      SAVE / BETSPY /
C ...........
      DIMENSION P1(4),P2(4),QQ(4),PP(4),XX(4),XPH1(4),XPH2(4)
      SAVE KEYBIN,KEYBFI,ICONT,ICLIM,ICLIM2
C
      IF(MODE.EQ.-1) THEN
C     =================================================================
C     =====================INITIALIZATION==============================
C     =================================================================
C ...Initial/final state bremsstrahlung switches
      KEYBIN  = MOD(KEYBRM,10)
      KEYBFI  = MOD(KEYBRM,100)/10
      IF(KEYBIN.EQ.1) CALL MONIN(-1)
      ICONT =  0
      ICLIM =  0
      ICLIM2=  50
      ELSEIF(MODE.EQ.0) THEN
C     =================================================================
C     ===================MODEL X-SECTION===============================
C     =================================================================
      ICONT=ICONT+1
      WTMAX=3.5D0
      WTMDL=1D0
      DO 10 I=1,100
   10 WTSET(I)=0D0
C ...Return for events outside phase space
      IF(WTCRU1*WTCRU2.EQ.0D0) GOTO 770
      CMSENE=2D0*ENE
C define beam momenta
      CALL GIBEA(CMSENE,AMEL,P1,P2)
C define 4-mometum XX of (virtual) Z
      DO 20 K=1,4
      PP(K)= P1(K)+ P2(K)
      QQ(K)=QF1(K)+QF2(K)
   20 XX(K)=XF1(K)+XF2(K)
      SVAR  = PP(4)**2-PP(3)**2-PP(2)**2-PP(1)**2
      SVAR1 = XX(4)**2-XX(3)**2-XX(2)**2-XX(1)**2
      SVAR2 = QQ(4)**2-QQ(3)**2-QQ(2)**2-QQ(1)**2
      VV = 1D0 -SVAR1/SVAR
      UU = 1D0 -SVAR2/SVAR1
C ...Crude distribution
      CALL NCRUDE(XX,DISCRU)
C ...Beta0, up to first order
      CALL NDIST0(XX,P1,P2,QF1,QF2,ANDIS,DELI1,DELI2,DELF1,DELF2)
C ...Various versions of Beta0, initial+final
      BETA02 = ANDIS*(1D0+DELI1+DELI2)*(1D0+DELF1+DELF2)
      BETA01 = ANDIS*(1D0+DELI1)*(1D0+DELF1)
      BETA00 = ANDIS
C ...Initial only
      BETI02 = ANDIS*(1D0+DELI1+DELI2)
      BETI01 = ANDIS*(1D0+DELI1)
      BETF01 = ANDIS*(1D0+DELF1)
      IF(ICONT.LE.ICLIM) CALL NTEST0(XX,P1,P2,QF1,QF2)

C ...BETA1...BETA1...BETA1...BETA1...
C ...Contributions from beta1 (divided by S-factors)
C ...First INITIAL state radiation
      SUMX10=0D0
      SUMX11=0D0
      SUMI11=0D0
      IF(KEYBIN.EQ.1 .AND. VV.GT.VLIM1) THEN
      DO  80 JPH=1,NPHOX
        DO 50 K=1,4
   50   XPH1(K)=XPHOT(JPH,K)
        CALL SFACH0(P1,P2,XPH1,SFACJ)
        SFACX(JPH) = SFACJ
        CALL NDIST1(XX,P1,P2,QF1,QF2,XPH1,DIST,DXLI1)
        DIST11=  DIST*(1D0+DXLI1)*(1+DELF1)
        DIST10=  DIST
        DISI11=  DIST*(1D0+DXLI1)
        IF(ICONT.LE.ICLIM) CALL NTEST1(XX,P1,P2,QF1,QF2,XPH1)
C ...BETX contains virtual final state corr. while BETI does not
c;;;; in O(alf1) factor 1+defl1 helps factorization
        BETX10(JPH) = (DIST10 -BETA00*SFACJ )*(1+DELF1)
        BETX11(JPH) =  DIST11 -BETA01*SFACJ
        SUMX10      =  SUMX10 +BETX10(JPH) /SFACJ
        SUMX11      =  SUMX11 +BETX11(JPH) /SFACJ
        BETI10(JPH) =  DIST10 -BETA00*SFACJ
        BETI11(JPH) =  DISI11 -BETI01*SFACJ
        SUMI11      =  SUMI11 +BETI11(JPH) /SFACJ
   80   CONTINUE
      ELSE
        DO 90 JPH=1,NPHOX
        SFACX(JPH)  = -1D0
        BETX10(JPH) =  0D0
        BETX11(JPH) =  0D0
        BETI10(JPH) =  0D0
        BETI11(JPH) =  0D0
   90   CONTINUE
      ENDIF
C ...FINAL state - beta1
      SUMY10=0D0
      SUMY11=0D0
      IF(KEYBFI.EQ.1 .AND. UU.GT.VLIM1) THEN
      DO 120 JPH=1,NPHOY
        DO 115 K=1,4
C note minus sign here!!!!
  115   XPH1(K)=-YPHOT(JPH,K)
        CALL SFACH0(QF1,QF2,XPH1,SFACJ)
        SFACY(JPH) = SFACJ
        CALL FDIST1(XX,P1,P2,QF1,QF2,XPH1,DIST,DYLF1)
        DIST11=  DIST*(1D0+DYLF1)*(1+DELI1)
        DIST10=  DIST
        IF(ICONT.LE.ICLIM) CALL NTEST1(XX,QF1,QF2,P1,P2,XPH1)
C ...BETY comprises initial state virtual corrections!
ccc;;; in O(alf1) factor 1+deli1 helps factorization
        BETY10(JPH) = (DIST10 -BETA00*SFACJ  )*(1D0+DELI1)
        BETY11(JPH) =  DIST11 -BETA01*SFACJ
        SUMY10      =  SUMY10 +BETY10(JPH) /SFACJ
        SUMY11      =  SUMY11 +BETY11(JPH) /SFACJ
        BETF10(JPH) =  DIST10 -BETA00*SFACJ
        BETF11(JPH) =  DISI11 -BETF01*SFACJ
  120   CONTINUE
      ELSE
        DO 125 JPH=1,NPHOY
        SFACY(JPH)  = -1D0
        BETY10(JPH) =  0D0
        BETY11(JPH) =  0D0
  125   CONTINUE
      ENDIF

C ...BETA2...BETA2...BETA2...BETA2...
C contributions from beta2, pure INITIAL state
      SUMXX2=0D0
      IF(KEYBIN.EQ.1 .AND. VV.GT.VLIM2) THEN
      DO 200 JPH2=2,NPHOX
      DO 200 JPH1=1,JPH2-1
         DO 150 K=1,4
            XPH1(K)=XPHOT(JPH1,K)
  150       XPH2(K)=XPHOT(JPH2,K)
         CALL NDIST2(XX,P1,P2,QF1,QF2,XPH1,XPH2,DIST2)
         IF(ICONT.LE.ICLIM) CALL NTEST2(XX,P1,P2,QF1,QF2,XPH1,XPH2)
         BETA2 = DIST2 -BETA00*SFACX(JPH1)*SFACX(JPH2)
ccc  $          -BETX10(JPH1)*SFACX(JPH2) -BETX10(JPH2)*SFACX(JPH1)
     $          -BETI10(JPH1)*SFACX(JPH2) -BETI10(JPH2)*SFACX(JPH1)
         SUMXX2=SUMXX2 +BETA2 /SFACX(JPH1)/SFACX(JPH2)
         BETXX20(JPH1,JPH2)=BETA2
  200    CONTINUE
      ELSE
      DO 205 JPH2=2,NPHOX
      DO 205 JPH1=1,NPHOX
         BETXX20(JPH1,JPH2)= 0D0
  205 CONTINUE
      ENDIF
C
C contributions from beta2, pure FINAL state
      SUMYY2=0D0
      IF(KEYBFI.EQ.1 .AND. UU.GT.VLIM2) THEN
      DO 220 JPH2=2,NPHOY
      DO 220 JPH1=1,JPH2-1
         DO 218 K=1,4
C note minus sign here!!!!
            XPH1(K)=-YPHOT(JPH1,K)
  218       XPH2(K)=-YPHOT(JPH2,K)
         CALL FDIST2(XX,P1,P2,QF1,QF2,XPH1,XPH2,DIST2)
         IF(ICONT.LE.ICLIM) CALL NTEST2(XX,P1,P2,QF1,QF2,XPH1,XPH2)
         BETA2 = DIST2 -BETA00*SFACY(JPH1)*SFACY(JPH2)
ccc  $          -BETY10(JPH1)*SFACY(JPH2) -BETY10(JPH2)*SFACY(JPH1)
     $          -BETF10(JPH1)*SFACY(JPH2) -BETF10(JPH2)*SFACY(JPH1)
         SUMYY2=SUMYY2 +BETA2 /SFACY(JPH1)/SFACY(JPH2)
         BETYY20(JPH1,JPH2)=BETA2
  220    CONTINUE
      ELSE
      DO 222 JPH2=2,NPHOY
      DO 222 JPH1=1,NPHOY
         BETYY20(JPH1,JPH2)= 0D0
  222 CONTINUE
      ENDIF
C contributions from beta2, INITIAL/FINAL state
C or in other terminology beta1_init*beta1_final
      SUMXY2=0D0
      IF(KEYBIN*KEYBFI.EQ.1 .AND. VV.GT.VLIM1.AND.UU.GT.VLIM1) THEN
      DO 240 JPH1=1,NPHOX
      DO 240 JPH2=1,NPHOY
         DO 230 K=1,4
            XPH1(K)= XPHOT(JPH1,K)
C note minus sign here!!!!
  230       XPH2(K)=-YPHOT(JPH2,K)
         CALL NFDIST(XX,P1,P2,QF1,QF2,XPH1,XPH2,DIST2)
         BETA2 = DIST2 -BETA00*SFACX(JPH1)*SFACY(JPH2)
ccc  $          -BETX10(JPH1)*SFACY(JPH2) -BETY10(JPH2)*SFACX(JPH1)
     $          -BETI10(JPH1)*SFACY(JPH2) -BETF10(JPH2)*SFACX(JPH1)
         SUMXY2=SUMXY2 +BETA2 /SFACX(JPH1)/SFACY(JPH2)
         BETXY20(JPH1,JPH2)=BETA2
  240    CONTINUE
      ELSE
      DO 245 JPH1=1,NPHOX
      DO 245 JPH2=1,NPHOY
         BETXY20(JPH1,JPH2)= 0D0
  245 CONTINUE
      ENDIF
C
C ...Remnant of the YFS formfactor for the final/final state
      CALL GIFYFS( P1, P2,FORINI)
      CALL GIFYFS(QF1,QF2,FORFIN)
      IF(KEYBIN.EQ.0) FORINI=1D0
      IF(KEYBFI.EQ.0) FORFIN=1D0
      FYFS = FORINI*FORFIN
C
C ...And the rejection weights = (new.distr/crude.distr)
C ========== INITIAL + FINAL =================
C All beta's ---------------------------------
      WTSET(71) =   FYFS*BETA00/DISCRU
      WTSET(72) =   FYFS*(BETA01+SUMX10+SUMY10+SUMXY2)/DISCRU
      WTSET(73) =   FYFS*
     &    (BETA02+SUMX11+SUMY11+SUMXX2 +SUMXY2 +SUMYY2 )/DISCRU
C First order, individual beta's -------------
      WTSET(80) =   FYFS*BETA01/DISCRU
      WTSET(81) =   FYFS*(SUMX10+SUMY10)/DISCRU
      WTSET(82) =   FYFS*(SUMX10)/DISCRU
      WTSET(83) =   FYFS*(SUMY10)/DISCRU
      WTSET(84) =   FYFS*(SUMXY2)/DISCRU
C Second order, individual beta's ------------
      WTSET(90) =   FYFS*BETA02/DISCRU
      WTSET(91) =   FYFS*(SUMX11+SUMY11)/DISCRU
      WTSET(92) =   FYFS*(SUMXX2+SUMXY2+SUMYY2)/DISCRU
      WTSET(93) =   FYFS*(SUMX11)/DISCRU
      WTSET(94) =   FYFS*(SUMY11)/DISCRU
      WTSET(95) =   FYFS*(SUMXX2)/DISCRU
      WTSET(96) =   FYFS*(SUMXY2)/DISCRU
      WTSET(97) =   FYFS*(SUMYY2)/DISCRU
C ========= INITIAL STATE ALONE ==============
C All beta's ---------------------------------
      WTSET( 1) =   FORINI*BETA00/DISCRU
      WTSET( 2) =   FORINI*(BETI01+SUMX10)/DISCRU
      WTSET( 3) =   FORINI*(BETI02+SUMI11+SUMXX2)/DISCRU
C First order, individual beta's -------------
      WTSET(10) =   FORINI*BETI01/DISCRU
      WTSET(11) =   FORINI*SUMX10/DISCRU
C Second order, individual beta's ------------
      WTSET(20) =   FORINI*BETI02/DISCRU
      WTSET(21) =   FORINI*SUMI11/DISCRU
      WTSET(22) =   FORINI*SUMXX2/DISCRU
C     ============================================
C ...Model weight (the best)
      WTMDL     =   WTSET(73)
C ...tests on weights
CC    IF(ICONT.LE.ICLIM2) CALL DUMPBT(NOUT)
CC    IF(ICONT.LE.ICLIM2) CALL DUMPBT(   6)
c      IF(ICONT.LE.ICLIM2.AND.NPHOY.GT.3) CALL DUMPBT(NOUT)
c      IF(ICONT.LE.ICLIM2.AND.NPHOY.GT.3) CALL DUMPBT(   6)
  770 CONTINUE
      IF(KEYBIN.EQ.1) CALL MONIN(0)
      PAR1  = WTMAX
      PAR2  = WTMDL
      ELSE
C     =================================================================
C     =====================FINAL WEIGHT REPORT=========================
C     =================================================================
      IF(KEYBIN.EQ.1) CALL MONIN(1)
      IF(KEYBIN.EQ.0.AND.KEYBFI.EQ.1) CALL MONIF
      ENDIF
C     =====
      END
      SUBROUTINE MONIF
C     ****************
C  Monitornig weights and x-sections for the FINAL state bremss.
C  Second, first and zero order X-sections
C     ***********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON / CMONIT/ AVERWT,ERRELA,NEVTOT,NEVACC,NEVNEG,NEVOVE,NEVZER
      COMMON / WGTALL / WTMOD,WTCRU1,WTCRU2,WTSET(100)
      COMMON / INOUT  / NINP,NOUT
      COMMON / BXFMTS / BXOPE,BXCLO,BXTXT,BXL1I,BXL1F,BXL2F,BXL1G,BXL2G
      CHARACTER*80      BXOPE,BXCLO,BXTXT,BXL1I,BXL1F,BXL2F,BXL1G,BXL2G
      SAVE / CMONIT/,/ WGTALL /,/ INOUT  /,/ BXFMTS /
      SAVE IDYFS
C --------------------------------------------------------------------
C X-sctions in Born units (for the moment)
      XKARL = 1
      ERKARL= 0
      IDYFS = 0
      CALL GMONIT(1,IDYFS+73,DUMM1,DUMM2,DUMM3)
      XS03   =  XKARL*AVERWT
      DXS03  =  XKARL*AVERWT*SQRT(ERKARL**2+ERRELA**2)
      CALL GMONIT(1,IDYFS+72,DUMM1,DUMM2,DUMM3)
      XS02   =  XKARL*AVERWT
      DXS02  =  XKARL*AVERWT*SQRT(ERKARL**2+ERRELA**2)
      CALL GMONIT(1,IDYFS+71,DUMM1,DUMM2,DUMM3)
      XS01   =  XKARL*AVERWT
      DXS01  =  XKARL*AVERWT*SQRT(ERKARL**2+ERRELA**2)
      CALL GMONIT(1,IDYFS+75,DUMM1,DUMM2,DUMM3)
      XS05   =  XKARL*AVERWT
      DXS05  =  XKARL*AVERWT*SQRT(ERKARL**2+ERRELA**2)
      CALL GMONIT(1,IDYFS+74,DUMM1,DUMM2,DUMM3)
      XS04   =  XKARL*AVERWT
      DXS04  =  XKARL*AVERWT*SQRT(ERKARL**2+ERRELA**2)
C ...BETA CONTRIBUTIONS
      CALL GMONIT(1,IDYFS+90,DUMM1,DUMM2,DUMM3)
      XS20   =  XKARL*AVERWT
      DXS20  =  XKARL*AVERWT*SQRT(ERKARL**2+ERRELA**2)
      CALL GMONIT(1,IDYFS+91,DUMM1,DUMM2,DUMM3)
      XS21   =  XKARL*AVERWT
      DXS21  =  XKARL*AVERWT*SQRT(ERKARL**2+ERRELA**2)
      CALL GMONIT(1,IDYFS+92,DUMM1,DUMM2,DUMM3)
      XS22   =  XKARL*AVERWT
      DXS22  =  XKARL*AVERWT*SQRT(ERKARL**2+ERRELA**2)
      CALL GMONIT(1,IDYFS+80,DUMM1,DUMM2,DUMM3)
      XS10   =  XKARL*AVERWT
      DXS10  =  XKARL*AVERWT*SQRT(ERKARL**2+ERRELA**2)
      CALL GMONIT(1,IDYFS+81,DUMM1,DUMM2,DUMM3)
      XS11   =  XKARL*AVERWT
      DXS11  =  XKARL*AVERWT*SQRT(ERKARL**2+ERRELA**2)
C ......................Output window B...............................
      WRITE(NOUT,BXOPE)
      WRITE(NOUT,BXTXT) '          MODEL  output - window B'
      WRITE(NOUT,BXTXT) '          FINAL   state only      '
      WRITE(NOUT,BXTXT) 'Analytical estimates of X-sections'
      WRITE(NOUT,BXTXT) 'Units of Born X-section           '
      PREC = 1D-5
      YS00 =      BREFKF( 300,PREC)
      YS01 =      BREFKF( 301,PREC)
      YS02 =      BREFKF( 302,PREC)
      WRITE(NOUT,BXL1F) YS02,'X-section','O(alf2)','B1'
      WRITE(NOUT,BXL1F) YS01,'X-section','O(alf1)','B2'
      WRITE(NOUT,BXL1F) YS00,'X-section','O(alf0)','B3'
      WRITE(NOUT,BXL1F) YS02-YS01,'(O(alf2)-O(alf1))','/O(alf1)','B4'
      WRITE(NOUT,BXL1F) YS01-YS00,'(O(alf1)-O(alf0))','/O(alf0)','B5'
      YS20 = BREFKF( 320,PREC)
      YS21 = BREFKF( 321,PREC)
      YS22 = BREFKF( 322,PREC)
      YS10 = BREFKF( 310,PREC)
      YS11 = BREFKF( 311,PREC)
      WRITE(NOUT,BXL1F) YS20,'Beta0          ','O(alf2)','B06'
      WRITE(NOUT,BXL1F) YS21,'     Beta1     ','       ','B07'
      WRITE(NOUT,BXL1F) YS22,'          Beta2','       ','B08'
      WRITE(NOUT,BXL1F) YS10,'Beta0          ','O(alf1)','B09'
      WRITE(NOUT,BXL1F) YS11,'     Beta1     ','       ','B10'
      WRITE(NOUT,BXCLO)
C --------------------------------------------------------------------
C ......................Output window C...............................
      WRITE(NOUT,BXOPE)
      WRITE(NOUT,BXTXT) '             MODEL  output - window C'
      WRITE(NOUT,BXTXT) ' FINAL   State  only'
      WRITE(NOUT,BXTXT) 'Comparison of MC and Analytical calc.'
      WRITE(NOUT,BXTXT) '(MonteCarlo  - Analytical)/Analytical'
      RS01 = XS01/YS00 -1
      RS02 = XS02/YS01 -1
      RS03 = XS03/YS02 -1
      WRITE(NOUT,BXL2F) RS03,DXS03/YS02,'X-section','O(alf2)','C1'
      WRITE(NOUT,BXL2F) RS02,DXS02/YS01,'X-section','O(alf1)','C2'
      WRITE(NOUT,BXL2F) RS01,DXS01/YS00,'X-section','O(alf0)','C3'
      WRITE(NOUT,BXTXT) 'Beta contributions'
      RS20 = XS20/YS20 -1
      RS21 = XS21/YS21 -1
      RS22 = XS22/YS22 -1
      RS10 = XS10/YS10 -1
      RS11 = XS11/YS11 -1
      DRS20 = DXS20/YS20
      DRS21 = DXS21/YS21
      DRS22 = DXS22/YS22
      DRS10 = DXS10/YS10
      DRS11 = DXS11/YS11
      WRITE(NOUT,BXL2F) RS20,DRS20,'Beta0          ','O(alf2)','C04'
      WRITE(NOUT,BXL2F) RS21,DRS21,'     Beta1     ','       ','C05'
      WRITE(NOUT,BXL2F) RS22,DRS22,'          Beta2','       ','C06'
      WRITE(NOUT,BXL2F) RS10,DRS10,'Beta0          ','O(alf1)','C07'
      WRITE(NOUT,BXL2F) RS11,DRS11,'     Beta1     ','       ','C08'
      WRITE(NOUT,BXCLO)
C ...the end of the FINAL-state report..............................
      END


      SUBROUTINE MONIN(MODE)
C     **********************
C  Monitornig weights and x-sections for the initial state bremss.
C  Auxiliary weights on INITIAL STATE ONLY
C  Second, first and zero order X-sections
C     ***********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON / CMONIT/ AVERWT,ERRELA,NEVTOT,NEVACC,NEVNEG,NEVOVE,NEVZER
      COMMON / WGTALL / WTMOD,WTCRU1,WTCRU2,WTSET(100)
      COMMON / INOUT  / NINP,NOUT
      COMMON / BXFMTS / BXOPE,BXCLO,BXTXT,BXL1I,BXL1F,BXL2F,BXL1G,BXL2G
      CHARACTER*80      BXOPE,BXCLO,BXTXT,BXL1I,BXL1F,BXL2F,BXL1G,BXL2G
      SAVE / CMONIT/,/ WGTALL /,/ INOUT  /,/ BXFMTS /
      SAVE IDYFS

      IF(MODE.EQ.-1) THEN
C     ===================
      IDYFS = 0
      CALL GMONIT(-1,IDYFS+ 1,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+ 2,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+ 3,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+ 4,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+ 5,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+10,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+11,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+20,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+21,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+22,0D0,1D0,1D0)
      ELSEIF(MODE.EQ.0) THEN
C     ======================
      WTMAX=2.5D0
      WTCRUD = WTCRU1*WTCRU2
      CALL GMONIT(0,IDYFS+ 3,WTCRUD*WTSET( 3),WTMAX,0D0)
      CALL GMONIT(0,IDYFS+ 2,WTCRUD*WTSET( 2),WTMAX,0D0)
      CALL GMONIT(0,IDYFS+ 1,WTCRUD*WTSET( 1),WTMAX,0D0)
C ...and differences
      CALL GMONIT(0,IDYFS+ 5,WTCRUD*(WTSET(3)-WTSET(2)),WTMAX,0D0)
      CALL GMONIT(0,IDYFS+ 4,WTCRUD*(WTSET(2)-WTSET(1)),WTMAX,0D0)
C ...Second order beta0,1,2
      CALL GMONIT(0,IDYFS+20,WTCRUD*WTSET(20),WTMAX,0D0)
      CALL GMONIT(0,IDYFS+21,WTCRUD*WTSET(21),WTMAX,0D0)
      CALL GMONIT(0,IDYFS+22,WTCRUD*WTSET(22),WTMAX,0D0)
C ...First order beta0,1
      CALL GMONIT(0,IDYFS+10,WTCRUD*WTSET(10),WTMAX,0D0)
      CALL GMONIT(0,IDYFS+11,WTCRUD*WTSET(11),WTMAX,0D0)
      ELSEIF(MODE.EQ.1) THEN
C     ======================
      XKARL  = WTCRU1
      ERKARL = WTCRU2
C ........................Output window A...............................
      WRITE(NOUT,BXOPE)
      WRITE(NOUT,BXTXT) '        MODEL  output - window A '
      WRITE(NOUT,BXTXT) '  Monte Carlo INITIAL state ONLY '
      WRITE(NOUT,BXTXT) '           X-sections in R-units '
      CALL GMONIT(1,IDYFS+ 3,DUMM1,DUMM2,DUMM3)
C)))))CALL GMONIT(2,IDYFS+ 3,DUMM1,DUMM2,DUMM3)
C     WRITE(2,*) ' YFSMOD, XKARL,AVERWT',XKARL,AVERWT
C))))))))
      XS03   =  XKARL*AVERWT
      DXS03  =  XKARL*AVERWT*SQRT(ERKARL**2+ERRELA**2)
      CALL GMONIT(1,IDYFS+ 2,DUMM1,DUMM2,DUMM3)
      XS02   =  XKARL*AVERWT
      DXS02  =  XKARL*AVERWT*SQRT(ERKARL**2+ERRELA**2)
      CALL GMONIT(1,IDYFS+ 1,DUMM1,DUMM2,DUMM3)
      XS01   =  XKARL*AVERWT
      DXS01  =  XKARL*AVERWT*SQRT(ERKARL**2+ERRELA**2)
      CALL GMONIT(1,IDYFS+ 5,DUMM1,DUMM2,DUMM3)
      XS05   =  XKARL*AVERWT
      DXS05  =  XKARL*AVERWT*SQRT(ERKARL**2+ERRELA**2)
      CALL GMONIT(1,IDYFS+ 4,DUMM1,DUMM2,DUMM3)
      XS04   =  XKARL*AVERWT
      DXS04  =  XKARL*AVERWT*SQRT(ERKARL**2+ERRELA**2)
      WRITE(NOUT,BXL2F) XS03,DXS03,'X-section','O(alf2)',  'A01'
      WRITE(NOUT,BXL2F) XS02,DXS02,'X-section','O(alf1)',  'A02'
      WRITE(NOUT,BXL2F) XS01,DXS01,'X-section','O(alf0)',  'A03'
      IF(XS02.NE.0D0) WRITE(NOUT,BXL2F)
     $ XS05/XS02,DXS05/XS02,'(O(alf2)-O(alf1))','/O(alf1)','A04'
      IF(XS01.NE.0D0) WRITE(NOUT,BXL2F)
     $ XS04/XS01,DXS04/XS01,'(O(alf1)-O(alf0))','/O(alf0)','A05'
C ...Beta contributions absolute
      CALL GMONIT(1,IDYFS+20,DUMM1,DUMM2,DUMM3)
      XS20   =  XKARL*AVERWT
      DXS20  =  XKARL*AVERWT*SQRT(ERKARL**2+ERRELA**2)
      CALL GMONIT(1,IDYFS+21,DUMM1,DUMM2,DUMM3)
      XS21   =  XKARL*AVERWT
      DXS21  =  XKARL*AVERWT*SQRT(ERKARL**2+ERRELA**2)
      CALL GMONIT(1,IDYFS+22,DUMM1,DUMM2,DUMM3)
      XS22   =  XKARL*AVERWT
      DXS22  =  XKARL*AVERWT*SQRT(ERKARL**2+ERRELA**2)
      CALL GMONIT(1,IDYFS+10,DUMM1,DUMM2,DUMM3)
      XS10   =  XKARL*AVERWT
      DXS10  =  XKARL*AVERWT*SQRT(ERKARL**2+ERRELA**2)
      CALL GMONIT(1,IDYFS+11,DUMM1,DUMM2,DUMM3)
      XS11   =  XKARL*AVERWT
      DXS11  =  XKARL*AVERWT*SQRT(ERKARL**2+ERRELA**2)
      WRITE(NOUT,BXTXT) 'Beta contributions in R-units'
      WRITE(NOUT,BXL2F) XS20,DXS20,'Beta0          ','O(alf2)','A06'
      WRITE(NOUT,BXL2F) XS21,DXS21,'     Beta1     ','       ','A07'
      WRITE(NOUT,BXL2F) XS22,DXS22,'          Beta2','       ','A08'
      WRITE(NOUT,BXL2F) XS10,DXS10,'Beta0          ','O(alf1)','A09'
      WRITE(NOUT,BXL2F) XS11,DXS11,'     Beta1     ','       ','A10'
      WRITE(NOUT,BXL2F) XS01,DXS01,'Beta0          ','O(alf0)','A11'
C ...Beta contributions relative
      WRITE(NOUT,BXTXT) 'Beta contributions - relative'
      IF(XS03.NE.0D0) WRITE(NOUT,BXL2F)
     $ XS20/XS03,DXS20/XS03,'Bet0/(Bet0+1+2)','O(alf2)','A12'
      IF(XS03.NE.0D0) WRITE(NOUT,BXL2F)
     $ XS21/XS03,DXS21/XS03,'Bet1/(Bet0+1+2)','       ','A13'
      IF(XS03.NE.0D0) WRITE(NOUT,BXL2F)
     $ XS22/XS03,DXS22/XS03,'Bet2/(Bet0+1+2)','       ','A14'
      IF(XS02.NE.0D0) WRITE(NOUT,BXL2F)
     $ XS10/XS02,DXS10/XS02,'Bet0/(Bet0+1)','O(alf1)'  ,'A15'
      IF(XS02.NE.0D0) WRITE(NOUT,BXL2F)
     $ XS11/XS02,DXS11/XS02,'Bet1/(Bet0+1)','       '  ,'A16'
      WRITE(NOUT,BXCLO)
C --------------------------------------------------------------------
C ......................Output window B...............................
      WRITE(NOUT,BXOPE)
      WRITE(NOUT,BXTXT) '          MODEL  output - window B'
      WRITE(NOUT,BXTXT) '          INITIAL state only cont.'
      WRITE(NOUT,BXTXT) 'Analytical estimates of X-sections'
      PREC = 1D-5
      YS00 =      BREMKF( 300,PREC)
      YS01 =      BREMKF( 301,PREC)
      YS02 =      BREMKF( 302,PREC)
      WRITE(NOUT,BXL1F) YS02,'X-section','O(alf2)','B1'
      WRITE(NOUT,BXL1F) YS01,'X-section','O(alf1)','B2'
      WRITE(NOUT,BXL1F) YS00,'X-section','O(alf0)','B3'
      WRITE(NOUT,BXL1F) YS02-YS01,'(O(alf2)-O(alf1))','/O(alf1)','B4'
      WRITE(NOUT,BXL1F) YS01-YS00,'(O(alf1)-O(alf0))','/O(alf0)','B5'
      YS20 = BREMKF( 320,PREC)
      YS21 = BREMKF( 321,PREC)
      YS22 = BREMKF( 322,PREC)
      YS10 = BREMKF( 310,PREC)
      YS11 = BREMKF( 311,PREC)
      WRITE(NOUT,BXL1F) YS20,'Beta0          ','O(alf2)','B06'
      WRITE(NOUT,BXL1F) YS21,'     Beta1     ','       ','B07'
      WRITE(NOUT,BXL1F) YS22,'          Beta2','       ','B08'
      WRITE(NOUT,BXL1F) YS10,'Beta0          ','O(alf1)','B09'
      WRITE(NOUT,BXL1F) YS11,'     Beta1     ','       ','B10'
      WRITE(NOUT,BXCLO)
C --------------------------------------------------------------------
C ......................Output window C...............................
      WRITE(NOUT,BXOPE)
      WRITE(NOUT,BXTXT) '             MODEL  output - window C'
      WRITE(NOUT,BXTXT) '                  Initial State  only'
      WRITE(NOUT,BXTXT) 'Comparison of MC and Analytical calc.'
      WRITE(NOUT,BXTXT) '(MonteCarlo  - Analytical)/Analytical'
      RS01 = XS01/YS00 -1
      RS02 = XS02/YS01 -1
      RS03 = XS03/YS02 -1
      WRITE(NOUT,BXL2F) RS03,DXS03/YS02,'X-section','O(alf2)','C1'
      WRITE(NOUT,BXL2F) RS02,DXS02/YS01,'X-section','O(alf1)','C2'
      WRITE(NOUT,BXL2F) RS01,DXS01/YS00,'X-section','O(alf0)','C3'
      WRITE(NOUT,BXTXT) 'Beta contributions'
      RS20 = XS20/YS20 -1
      RS21 = XS21/YS21 -1
      RS22 = XS22/YS22 -1
      RS10 = XS10/YS10 -1
      RS11 = XS11/YS11 -1
      DRS20 = DXS20/YS20
      DRS21 = DXS21/YS21
      DRS22 = DXS22/YS22
      DRS10 = DXS10/YS10
      DRS11 = DXS11/YS11
      WRITE(NOUT,BXL2F) RS20,DRS20,'Beta0          ','O(alf2)','C04'
      WRITE(NOUT,BXL2F) RS21,DRS21,'     Beta1     ','       ','C05'
      WRITE(NOUT,BXL2F) RS22,DRS22,'          Beta2','       ','C06'
      WRITE(NOUT,BXL2F) RS10,DRS10,'Beta0          ','O(alf1)','C07'
      WRITE(NOUT,BXL2F) RS11,DRS11,'     Beta1     ','       ','C08'
      WRITE(NOUT,BXCLO)
C ...the end of the initial-state report..............................
      ELSE
      WRITE(NOUT,*) ' +++++ WRONG MODE IN MONIN'
      ENDIF
C     =====
      END
      SUBROUTINE DUMPBT(NOUT)
C     ***********************
C     Prints out information on beta's
C     ***********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER(NPMX=25)
C Spying on weights.........
      COMMON / BETSPY / BETA00,BETA01,BETA02,BETI01,BETI02,
     $  BETA10(NPMX),BETA11(NPMX),BETA20(NPMX,NPMX),
     $  SFACX(NPMX),SFACY(NPMX),
     $  BETX10(NPMX),BETX11(NPMX),BETY10(NPMX),BETY11(NPMX),
     $  BETXX20(NPMX,NPMX),BETXY20(NPMX,NPMX),BETYY20(NPMX,NPMX),
     $  BETI10(NPMX),BETI11(NPMX),BETI20(NPMX,NPMX),
     $  BETF10(NPMX),BETF11(NPMX),BETF20(NPMX,NPMX)
      SAVE / BETSPY /
C ...........
      COMMON / MOMINI / XF1(4),XF2(4),XPHUM(4),XPHOT(100,4),NPHOX
      COMMON / MOMFIN / QF1(4),QF2(4),YPHUM(4),YPHOT(100,4),NPHOY
      SAVE / MOMINI /,/ MOMFIN /

      WRITE(NOUT,*) '--------------------<DUMBT>----------------------'
 2000 FORMAT(A30,3F15.8/(5F15.8))
C ...Beta0
      WRITE(NOUT,2000) ' Beta00, Beta01/Beta00, Beta02/Beta00'
     & ,BETA00,BETA01/BETA00,BETA02/BETA00
C ...SFACI(i)
 2002 FORMAT(A16,4E16.7/(5E16.7))
      IF(NPHOX.GT.0) WRITE(NOUT,2002) ' SFACX(i) ',(SFACX(I),I=1,NPHOX)
      IF(NPHOY.GT.0) WRITE(NOUT,2002) ' SFACY(i) ',(SFACY(I),I=1,NPHOY)
C ...Beta1   INITIAL state ...............
      IF(NPHOX.GT.0) WRITE(NOUT,2000) ' Init. BetX10(i)/Beta00 ',
     $  ( BETX10(I)/SFACX(I)/BETA00  ,I=1,NPHOX)
      IF(NPHOX.GT.0) WRITE(NOUT,2000) ' Init. BetX11(i)/Beta00 ',
     $  ( BETX11(I)/SFACX(I)/BETA00  ,I=1,NPHOX)

C ...Beta1   final state ...............
      IF(NPHOY.GT.0) WRITE(NOUT,2000) ' Fin.  BetY10(i)/Beta00 ',
     $  ( BETY10(I)/SFACY(I)/BETA00  ,I=1,NPHOY)
      IF(NPHOY.GT.0) WRITE(NOUT,2000) ' Fin.  BetY11(i)/Beta00 ',
     $  ( BETY11(I)/SFACY(I)/BETA00  ,I=1,NPHOY)

C ...Beta2 pure initial
      IF(NPHOX.GE.2) THEN
      WRITE(NOUT,*) ' Init. state BetXX20(i,j)'
      DO 100 J=2,NPHOX
      WRITE(NOUT,'(  8F12.8)')
     $ (BETXX20(I,J)/SFACX(I)/SFACX(J)/BETA00,I=1,J-1)
  100 CONTINUE
      ENDIF
C ...Beta2 pure final
      IF(NPHOY.GE.2) THEN
      WRITE(NOUT,*) ' Final state BetYY20(i,j)'
      DO 110 J=2,NPHOY
      WRITE(NOUT,'(  8F20.16)')
     $ (BETYY20(I,J)/SFACY(I)/SFACY(J)/BETA00,I=1,J-1)
  110 CONTINUE
      ENDIF
C ...Beta2 initial/final
      IF(NPHOX.GE.1 .AND. NPHOY.GE.1) THEN
      WRITE(NOUT,*) ' In/fi state BetXY20(i,j)'
      DO 120 J=1,NPHOY
      WRITE(NOUT,'(  8F12.8)')
     $ (BETXY20(I,J)/SFACX(I)/SFACY(J)/BETA00,I=1,NPHOX)
  120 CONTINUE
      ENDIF
      END
      SUBROUTINE NTEST0(QQ,P1,P2,Q1,Q2)
C     *********************************
C ...Testing redustion for Beta0
C     *********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON / INOUT  / NINP,NOUT
      SAVE   / INOUT  /
      DIMENSION QQ(*),P1(*),P2(*),Q1(*),Q2(*)
      DIMENSION PR1(4),PR2(4),QR1(4),QR2(4)
      DIMENSION PPR(4),QQR(4),QQ1(4)
C
      WRITE(NOUT,*) '-----------NTEST0---------==========='
      CALL REDUZ0(QQ,Q1,Q2,QR1,QR2)
      CALL REDUZ0(QQ,P1,P2,PR1,PR2)
      CALL BOSTDQ(1,QQ,QQ,QQ1)
      DO 10 K=1,4
      PPR(K)=PR1(K)+PR2(K)-QQ1(K)
  10  QQR(K)=QR1(K)+QR2(K)-QQ1(K)
      call dumpt(2,' PPR    ',PPR)
      call dumpt(2,' QQR    ',QQR)
      call dumpt(2,'  PR1   ',PR1)
      call dumpt(2,'  PR2   ',PR2)
      call dumpt(2,'  QR1   ',QR1)
      call dumpt(2,'  QR2   ',QR2)
      CALL GTHET0(PR1,QR1,COSTH )
      WRITE(NOUT,'(A,3F20.12)') ' COSTH= ',COSTH
      END
      SUBROUTINE NTEST1(QQ,P1,P2,Q1,Q2,PH)
C     ************************************
C ...Testing reduction for beta1
C     ************************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON / INOUT  / NINP,NOUT
      SAVE   / INOUT  /
      DIMENSION QQ(*),P1(*),P2(*),Q1(*),Q2(*),PH(*)
      DIMENSION PR1(4),PR2(4),QR1(4),QR2(4),PHR(4)
      DIMENSION PPR(4),QQR(4),PX1(4),PX2(4),QQ1(4),PPX(4)
C
      WRITE(NOUT,*) '-----------NTEST1---------<<<<<<<<<<<'
      CALL REDUZ0(QQ,Q1,Q2,QR1,QR2)
      CALL REDUZ1(QQ,P1,P2,PH,PR1,PR2,PHR)
      CALL REDUZ0(QQ,P1,P2,PX1,PX2)
      CALL BOSTDQ(1,QQ,QQ,QQ1)
      DO 10 K=1,4
      PPX(K)=PX1(K)+PX2(K)        -QQ1(K)
      PPR(K)=PR1(K)+PR2(K)-PHR(K) -QQ1(K)
  10  QQR(K)=QR1(K)+QR2(K)        -QQ1(K)
      call dumpt(2,' PPX    ',PPX)
      call dumpt(2,' PPR    ',PPR)
      call dumpt(2,' QQR    ',QQR)
      call dumpt(2,'  PR1   ',PR1)
      call dumpt(2,'  PR2   ',PR2)
      call dumpt(2,'  PX1   ',PX1)
      call dumpt(2,'  PX2   ',PX2)
      call dumpt(2,'  QR1   ',QR1)
      call dumpt(2,'  QR2   ',QR2)
C Single bremsstrahlung Xsection
      CALL GSOFA1(P1,P2,PH,GF1,GF2)
      CALL GTHET1(PR1,PR2,QR1,COSTH1,COSTH2)
      CALL SFACH0(P1,P2, PH ,SFACJ)
      CALL GTHET0(PX1,QR1,COSTH)
      WRITE(NOUT,'(A,3F20.12)') ' PH(4)= ',PH(4)
      WRITE(NOUT,'(A,3F20.12)') ' COSTH= ',COSTH1-COSTH,COSTH2-COSTH
      WRITE(NOUT,'(A,3F20.12)') ' GF/SF= ',(GF1+GF2)/SFACJ
      END
      SUBROUTINE NTEST2(QQ,P1,P2,Q1,Q2,PH1,PH2)
C     *****************************************
C ...Testing reduction for beta2
C     ************************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON / INOUT  / NINP,NOUT
      SAVE   / INOUT  /
      DIMENSION QQ(*),P1(*),P2(*),Q1(*),Q2(*),PH1(*),PH2(*)
      DIMENSION PR1(4),PR2(4),QR1(4),QR2(4),PH1R(4),PH2R(4)
      DIMENSION PPR(4),QQR(4),PX1(4),PX2(4),QQ1(4)
C
      WRITE(NOUT,*) '-----------NTEST2---------<<<<<<<<<<<'
      CALL REDUZ0(QQ,Q1,Q2,QR1,QR2)
      CALL REDUZ2(QQ,P1,P2,PH1,PH2,PR1,PR2,PH1R,PH2R)
      CALL BOSTDQ(1,QQ,QQ,QQ1)
      DO 10 K=1,4
      PPR(K)=PR1(K)+PR2(K)-PH1R(K)-PH2R(K) -QQ1(K)
  10  QQR(K)=QR1(K)+QR2(K)                 -QQ1(K)
      call dumpt(2,' PPR    ',PPR)
      call dumpt(2,' QQR    ',QQR)
      call dumpt(2,'  PR1   ',PR1)
      call dumpt(2,'  PR2   ',PR2)
      call dumpt(2,'  QR1   ',QR1)
      call dumpt(2,'  QR2   ',QR2)
C Single bremsstrahlung Xsection
      CALL GSOFA2(P1,P2,PH1,PH2,GF1,GF2)
      CALL GTHET1(PR1,PR2,QR1,COSTH1,COSTH2)
      CALL SFACH0(P1,P2, PH1,SFAC1)
      CALL SFACH0(P1,P2, PH2,SFAC2)
      CALL REDUZ0(QQ,P1,P2,PX1,PX2)
      CALL GTHET0(PX1,QR1,COSTH)
      WRITE(NOUT,'(A,3F20.12)') 'PHi(4)= ',PH1(4),PH2(4)
      WRITE(NOUT,'(A,3F20.12)') ' COSTH= ',COSTH1-COSTH,COSTH2-COSTH
      WRITE(NOUT,'(A,3F20.12)') ' GF/SF= ',(GF1+GF2)/SFAC1/SFAC2
      END
      SUBROUTINE GIFYFS(P1,P2,FYFS)
C     *****************************
C YFS formfactor
C     *****************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION P1(*),P2(*)
      PARAMETER( PI=3.1415926535897932D0, ALFINV=137.03604D0)
      PARAMETER( ALF1=1D0/ALFINV/PI)

      SVAR   = (P1(4)+P2(4))**2-(P1(3)+P2(3))**2
     $        -(P1(2)+P2(2))**2-(P1(1)+P2(1))**2
      AMS    = P1(4)**2-P1(3)**2-P1(2)**2-P1(1)**2
      BILG  =  DLOG(SVAR/AMS)
      BETA  =  2*ALF1*(BILG-1)
      DELB  =  BETA/4 + ALF1*( -.5D0  +PI**2/3D0)
      FYFS  =  EXP(DELB)
      END
      SUBROUTINE NCRUDE(QQ,DISCRU)
C     ****************************
C provides crude distribution generated in KARLUD
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION QQ(4)
      SVAR1  =  QQ(4)**2-QQ(3)**2-QQ(2)**2-QQ(1)**2
C---      DISCRU =  BORNV(SVAR1,0D0)*4D0/3D0
      DISCRU =  BORNY(SVAR1)*4D0/3D0
      END
      SUBROUTINE NDIST0(XX,P1,P2,Q1,Q2,ANDIS,DELI1,DELI2,DELF1,DELF2)
C     ***************************************************************
C Provides elements of beta0,
C for transparency reasons the full reduction of momenta is done.
C     ***********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON / KEYYFS / KEYZET,KEYBRM,KEYFIX,KEYRED,KEYWGT
      SAVE   / KEYYFS /
      DIMENSION XX(*),P1(*),P2(*),Q1(*),Q2(*)
      DIMENSION PR1(4),PR2(4),QR1(4),QR2(4)
C
      CALL REDUZ0(XX,P1,P2,PR1,PR2)
      CALL REDUZ0(XX,Q1,Q2,QR1,QR2)
      CALL GTHET0(PR1,QR1,COSTH1)
      COSTH  = (PR1(1)*QR1(1) +PR1(2)*QR1(2) +PR1(3)*QR1(3))
     $            /SQRT((QR1(1)**2 +QR1(2)**2 +QR1(3)**2)
     $                 *(PR1(1)**2 +PR1(2)**2 +PR1(3)**2))
      SVAR1  = XX(4)**2-XX(3)**2-XX(2)**2-XX(1)**2
C ZW 03.03.97 here was bug
C      SVAR1  = XX(4)**2-XX(3)**2-XX(2)-XX(1)**2
      ANDIS  = BORNV (SVAR1,COSTH )
      CALL BVIRT0(P1,P2,DELI1,DELI2)
      CALL BVIRT0(Q1,Q2,DELF1,DELF2)
C ...Initial/final state bremsstrahlung switches
      KEYBIN  = MOD(KEYBRM,10)
      KEYBFI  = MOD(KEYBRM,100)/10
      DELI1   = DELI1*KEYBIN
      DELI2   = DELI2*KEYBIN
      DELF1   = DELF1*KEYBFI
      DELF2   = DELF2*KEYBFI
      END
      SUBROUTINE NDIST1(QQ,P1,P2,Q1,Q2,PH,DIST,DELI1)
C     *********************************** ***********
C Provides single bremsstrahlung distribution, INITIAL STATE
C INPUT:  P1,P2,Q1,Q2,PH, four momenta
C OUTPUT:
C         DIST           is first order result, exact.
C         DISI*(1+DELI1) is second erder LL+NLL result
C     ***********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON / KEYYFS / KEYZET,KEYBRM,KEYFIX,KEYRED,KEYWGT
      SAVE   / KEYYFS /
      DIMENSION QQ(*),P1(*),P2(*),Q1(*),Q2(*),PH(*)
      DIMENSION PR1(4),PR2(4),QR1(4),QR2(4),PHR(4)
C
      CALL REDUZ1(QQ,P1,P2,PH,PR1,PR2,PHR)
      CALL REDUZ0(QQ,Q1,Q2,QR1,QR2)
C Single bremsstrahlung Xsection
      CALL GSOFA1(P1,P2,PH,GF1,GF2)
      CALL GTHET1(PR1,PR2,QR1,COSTH1,COSTH2)
      SVAR1 = QQ(4)**2-QQ(3)**2-QQ(2)**2-QQ(1)**2
      ANDI11= BORNV(SVAR1,COSTH1)
      ANDI12= BORNV(SVAR1,COSTH2)
      DIST  =  GF1*ANDI11+ GF2*ANDI12
C Virtual correction in the second order case (K-factor style)
      CALL BVIRT1(P1,P2,PH,DELI1)
C ...Initial/final state bremsstrahlung switches
      KEYBIN  = MOD(KEYBRM,10)
      DELI1   = DELI1*KEYBIN
      END
      SUBROUTINE FDIST1(QQ,P1,P2,Q1,Q2,PH,DIST,DELF1)
C     ***********************************************
C Provides FIRST ORDER single FINAL state bremsstrahlung distribution
C INPUT:  QQ,P1,P2,Q1,Q2,PH, four momenta
C OUTPUT:
C         DIST           is first order result, exact.
C         DIST*(1+DELF1) is scond order result, LL + NLL
C     ***********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION QQ(*),P1(*),P2(*),Q1(*),Q2(*),PH(*)
      COMMON / KEYYFS / KEYZET,KEYBRM,KEYFIX,KEYRED,KEYWGT
      SAVE   / KEYYFS /
      DIMENSION PR1(4),PR2(4),QR1(4),QR2(4),PHR(4)
C
      CALL REDUZ1(QQ,Q1,Q2,PH,QR1,QR2,PHR)
      CALL REDUZ0(QQ,P1,P2,PR1,PR2)
      SVAR1 = QQ(4)**2-QQ(3)**2-QQ(2)**2-QQ(1)**2
C Infrared factor from reduced momenta
C Single bremsstrahlung Xsection
      CALL GSFIN1(Q1,Q2,PH,GF1,GF2)
      CALL GTHET1(QR1,QR2,PR1,COSTH1,COSTH2)
      ANDI11= BORNV(SVAR1,COSTH1)
      ANDI12= BORNV(SVAR1,COSTH2)
      DIST  = GF1*ANDI11+ GF2*ANDI12
C Virtual correction in the second order case (K-factor style)
      CALL BVIRF1(Q1,Q2,PH,DELF1)
C ...Initial/final state bremsstrahlung switches
      KEYBFI  = MOD(KEYBRM,100)/10
      DELF1   = DELF1*KEYBFI
      END
      SUBROUTINE GSFIN1(P1,P2,PH,F1,F2)
C     *********************************
C Final state now! but P <=> replacement kept
C CALCULATES INGREDIENTS FOR REAL SINGLE PHOTON DIFF. XSECTION
C     *****************************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION PH(*),P1(*),P2(*)
      AM2= P1(4)**2-P1(1)**2-P1(2)**2-P1(3)**2
      PK1= P1(4)*PH(4)-P1(1)*PH(1)-P1(2)*PH(2)-P1(3)*PH(3)
      PK2= P2(4)*PH(4)-P2(1)*PH(1)-P2(2)*PH(2)-P2(3)*PH(3)
      PP = P1(4)*P2(4)-P1(1)*P2(1)-P1(2)*P2(2)-P1(3)*P2(3)
C
      BB =  ABS(PK2)/PP
      AA =  ABS(PK1)/PP
      A  = AA/(1 +AA+BB)
      B  = BB/(1 +AA+BB)
      SFAC1  =  2D0*PP/PK1/PK2
      AM = AM2/(2D0*PP)
      WWM= 1D0-AM*2D0*(1D0-A)*(1D0-B)/((1D0-A)**2+(1D0-B)**2)*(A/B+B/A)
      F1   = 0.5D0*(1D0-A)**2*WWM *SFAC1
      F2   = 0.5D0*(1D0-B)**2*WWM *SFAC1
      END
      SUBROUTINE NDIST2(QQ,P1,P2,Q1,Q2,PH1,PH2,DIST2)
C     ***********************************************
C Provides double bremsstrahlung distribution - INITIAL state brem.
C INPUT:  P1,P2,Q1,Q2,PH1,PH2, four momenta
C OUTPUT: DIST2     double bremsstrahlung distribution
C     ***********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION QQ(*),P1(*),P2(*),Q1(*),Q2(*),PH1(*),PH2(*)
      DIMENSION PR1(4),PR2(4),PH1R(4),PH2R(4),QR1(4),QR2(4)

      CALL REDUZ2(QQ,P1,P2,PH1,PH2,PR1,PR2,PH1R,PH2R)
      CALL REDUZ0(QQ,Q1,Q2,QR1,QR2)
      SVAR1 = QQ(4)**2-QQ(3)**2-QQ(2)**2-QQ(1)**2
C infrared factors from reduced momenta
C double bremsstrahlung Xsect in next-to-leading log approx.
      CALL GSOFA2(P1,P2,PH1,PH2,GF1,GF2)
      CALL GTHET1(PR1,PR2,QR1,COSTH1,COSTH2)
      ANDI11= BORNV(SVAR1,COSTH1)
      ANDI12= BORNV(SVAR1,COSTH2)
      DIST2 =   GF1*ANDI11+   GF2*ANDI12
      END
      SUBROUTINE HSOFA2(P1,P2,PH1,PH2,F1,F2)
C     **************************************
C OLD VERSION
C CALCULATES INGREDIENTS FOR REAL DOUBLE PHOTON DIFF. XSECTION
C     *****************************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION PH1(*),PH2(*),P1(*),P2(*)
C
      WM (A  )=     (1D0-A)**2
      WMS(A,B)=     ((1D0-A)**2+(1D0-B)**2)
      WWM(A,B)=
     $   1D0-AM*2D0*(1D0-A)*(1D0-B)/((1D0-A)**2+(1D0-B)**2)*(A/B+B/A)
C
      PP = P1(4)*P2(4)-P1(1)*P2(1)-P1(2)*P2(2)-P1(3)*P2(3)
      AM2= P1(4)**2-P1(1)**2-P1(2)**2-P1(3)**2
      AM = AM2/(2D0*PP)
      B1 = (P2(4)*PH1(4)-P2(1)*PH1(1)-P2(2)*PH1(2)-P2(3)*PH1(3))/PP
      A1 = (P1(4)*PH1(4)-P1(1)*PH1(1)-P1(2)*PH1(2)-P1(3)*PH1(3))/PP
      B2 = (P2(4)*PH2(4)-P2(1)*PH2(1)-P2(2)*PH2(2)-P2(3)*PH2(3))/PP
      A2 = (P1(4)*PH2(4)-P1(1)*PH2(1)-P1(2)*PH2(2)-P1(3)*PH2(3))/PP
      SFAC1  =  2D0/(PP*A1*B1)*WWM(A1,B1)
      SFAC2  =  2D0/(PP*A2*B2)*WWM(A2,B2)
      A1P= A1/(1D0-A2)
      B1P= B1/(1D0-B2)
      A2P= A2/(1D0-A1)
      B2P= B2/(1D0-B1)
      IF((A1+B1).GT.(A2+B2)) THEN
        X1=WM (A1   )*WMS(A2P,B2P) +WM (A1P    )*WMS(A2,B2)
        X2=WM (   B1)*WMS(A2P,B2P) +WM (    B1P)*WMS(A2,B2)
      ELSE
        X1=WM (A2   )*WMS(A1P,B1P) +WM (A2P    )*WMS(A1,B1)
        X2=WM (   B2)*WMS(A1P,B1P) +WM (    B2P)*WMS(A1,B1)
      ENDIF
      F1 = X1*SFAC1*SFAC2/8D0
      F2 = X2*SFAC1*SFAC2/8D0
      END
      SUBROUTINE GSOFA2(P1,P2,PH1,PH2,F1,F2)
C     **************************************
C NEW VERSION BY ELA WAS
C CALCULATES INGREDIENTS FOR REAL DOUBLE PHOTON DIFF. XSECTION
C     *****************************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION PH1(*),PH2(*),P1(*),P2(*)
C
      WM (A  )=     (1D0-A)**2
      WMS(A,B)=     ((1D0-A)**2+(1D0-B)**2)
      WWM(A,B)=
     $   1D0-AM*2D0*(1D0-A)*(1D0-B)/((1D0-A)**2+(1D0-B)**2)*(A/B+B/A)
C
      PP = P1(4)*P2(4)-P1(1)*P2(1)-P1(2)*P2(2)-P1(3)*P2(3)
      AM2= P1(4)**2-P1(1)**2-P1(2)**2-P1(3)**2
      AM = AM2/(2D0*PP)
      B1 = (P2(4)*PH1(4)-P2(1)*PH1(1)-P2(2)*PH1(2)-P2(3)*PH1(3))/PP
      A1 = (P1(4)*PH1(4)-P1(1)*PH1(1)-P1(2)*PH1(2)-P1(3)*PH1(3))/PP
      B2 = (P2(4)*PH2(4)-P2(1)*PH2(1)-P2(2)*PH2(2)-P2(3)*PH2(3))/PP
      A2 = (P1(4)*PH2(4)-P1(1)*PH2(1)-P1(2)*PH2(2)-P1(3)*PH2(3))/PP
      SFAC1  =  2D0/(PP*A1*B1)*WWM(A1,B1)
      SFAC2  =  2D0/(PP*A2*B2)*WWM(A2,B2)
      A1P= A1/(1D0-A2)
      B1P= B1/(1D0-B2)
      A2P= A2/(1D0-A1)
      B2P= B2/(1D0-B1)
      IF((A1+B1).GT.(A2+B2)) THEN
        X1=WM (A1   )*WMS(A2P,B2P) +WM (A1P    )*WMS(A2,B2)
        X2=WM (   B1)*WMS(A2P,B2P) +WM (    B1P)*WMS(A2,B2)
      ELSE
        X1=WM (A2   )*WMS(A1P,B1P) +WM (A2P    )*WMS(A1,B1)
        X2=WM (   B2)*WMS(A1P,B1P) +WM (    B2P)*WMS(A1,B1)
      ENDIF
      F1 = X1*SFAC1*SFAC2/8D0
      F2 = X2*SFAC1*SFAC2/8D0
C.. correction ELA WAS november 1989................................
C.. this correction reconstructs properly double collinear limit
C.. and affects below photon-fermion angle  <0.1 amel/ene
      SFAC1  =  2D0/(PP*A1*B1)
      SFAC2  =  2D0/(PP*A2*B2)
      WWM1=1D0-WWM(A1,B1)
      WWM2=1D0-WWM(A2,B2)
      DELT=(B2**2*A1**2+A2**2*B1**2)/(X1+X2)*2D0*
     #  ( 1D0/(A1+A2)**2+1D0/(B1+B2)**2)
      WMINF=1D0-WWM1-WWM2+WWM1*WWM2*(1D0+DELT)
      F1 = X1*SFAC1*SFAC2/8D0*WMINF
      F2 = X2*SFAC1*SFAC2/8D0*WMINF
C...end of correction............................................
      END
      SUBROUTINE FDIST2(QQ,P1,P2,Q1,Q2,PH1,PH2,DIST2)
C     ***********************************************
C Provides double bremsstrahlung distribution - FINAL state brem.
C INPUT:  P1,P2,Q1,Q2,PH1,PH2, four momenta
C OUTPUT: DIST2     double bremsstrahlung distribution
C     ***********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION QQ(*),P1(*),P2(*),Q1(*),Q2(*),PH1(*),PH2(*)
      DIMENSION PR1(4),PR2(4),PH1R(4),PH2R(4),QR1(4),QR2(4)

      CALL REDUZ2(QQ,Q1,Q2,PH1,PH2,QR1,QR2,PH1R,PH2R)
      CALL REDUZ0(QQ,P1,P2,PR1,PR2)
      SVAR1 = QQ(4)**2-QQ(3)**2-QQ(2)**2-QQ(1)**2
C infrared factors from reduced momenta
C double bremsstrahlung Xsect in next-to-leading log approx.
      CALL GSFIN2(Q1,Q2,PH1,PH2,GF1,GF2)
      CALL GTHET1(QR1,QR2,PR1,COSTH1,COSTH2)
      ANDI11= BORNV(SVAR1,COSTH1)
      ANDI12= BORNV(SVAR1,COSTH2)
      DIST2 =   GF1*ANDI11+   GF2*ANDI12
      END
      SUBROUTINE GSFIN2(P1,P2,PH1,PH2,F1,F2)
C     **************************************
C CALCULATES INGREDIENTS FOR REAL DOUBLE PHOTON DIFF. XSECTION
C     *****************************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION PH1(*),PH2(*),P1(*),P2(*)
C
      WM (A  )=     (1D0-A)**2
      WMS(A,B)=     ((1D0-A)**2+(1D0-B)**2)
      WWM(A,B)=
     $   1D0-AM*2D0*(1D0-A)*(1D0-B)/((1D0-A)**2+(1D0-B)**2)*(A/B+B/A)
C
      PP = P1(4)*P2(4)-P1(1)*P2(1)-P1(2)*P2(2)-P1(3)*P2(3)
      AM2= P1(4)**2-P1(1)**2-P1(2)**2-P1(3)**2
      AM = AM2/(2D0*PP)
      BB1=ABS(P2(4)*PH1(4)-P2(1)*PH1(1)-P2(2)*PH1(2)-P2(3)*PH1(3))/PP
      AA1=ABS(P1(4)*PH1(4)-P1(1)*PH1(1)-P1(2)*PH1(2)-P1(3)*PH1(3))/PP
      BB2=ABS(P2(4)*PH2(4)-P2(1)*PH2(1)-P2(2)*PH2(2)-P2(3)*PH2(3))/PP
      AA2=ABS(P1(4)*PH2(4)-P1(1)*PH2(1)-P1(2)*PH2(2)-P1(3)*PH2(3))/PP
      AA1P= AA1/(1D0+AA2)
      BB1P= BB1/(1D0+BB2)
      AA2P= AA2/(1D0+AA1)
      BB2P= BB2/(1D0+BB1)
      A1  = AA1/(1+AA1+BB1)
      A2  = AA2/(1+AA2+BB2)
      B1  = BB1/(1+AA1+BB1)
      B2  = BB2/(1+AA2+BB2)
      A1P = AA1P/(1+AA1P+BB1P)
      A2P = AA2P/(1+AA2P+BB2P)
      B1P = BB1P/(1+AA1P+BB1P)
      B2P = BB2P/(1+AA2P+BB2P)
      SFAC1  =  2D0/(PP*AA1*BB1)*WWM(A1,B1)
      SFAC2  =  2D0/(PP*AA2*BB2)*WWM(A2,B2)
      IF((A1+B1).GT.(A2+B2)) THEN
        X1=WM (A1   )*WMS(A2P,B2P) +WM (A1P    )*WMS(A2,B2)
        X2=WM (   B1)*WMS(A2P,B2P) +WM (    B1P)*WMS(A2,B2)
      ELSE
        X1=WM (A2   )*WMS(A1P,B1P) +WM (A2P    )*WMS(A1,B1)
        X2=WM (   B2)*WMS(A1P,B1P) +WM (    B2P)*WMS(A1,B1)
      ENDIF
      F1 = X1*SFAC1*SFAC2/8D0
      F2 = X2*SFAC1*SFAC2/8D0
      END
      SUBROUTINE NFDIST(QQ,P1,P2,Q1,Q2,PH1,PH2,DIST2)
C     ***********************************************
C Provides distribution for simultaneous initial and final state
C single bremsstrahlung.
C INPUT:  P1,P2,Q1,Q2,PH1,PH2 four momenta
C OUTPUT: DIST2 is second order result, leading+subleading log. appr.
C     ***********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION QQ(*),P1(*),P2(*),Q1(*),Q2(*),PH1(*),PH2(*)
      DIMENSION PR1(4),PR2(4),QR1(4),QR2(4),PHR1(4),PHR2(4)
C
      CALL REDUZ1(QQ,P1,P2,PH1,PR1,PR2,PHR1)
      CALL REDUZ1(QQ,Q1,Q2,PH2,QR1,QR2,PHR2)
C Single bremsstrahlung Xsection
c;;
ccc      CALL BVIRT1(P1,P2,PH1,DELI1)
ccc      CALL BVIRF1(Q1,Q2,PH2,DELF1)
      CALL GSOFA1(P1,P2,PH1,GI1,GI2)
      CALL GSFIN1(Q1,Q2,PH2,GF1,GF2)
      CALL GTHET3(PR1,PR2,QR1,QR2,CTH11,CTH12,CTH21,CTH22)
      SVAR1 = QQ(4)**2-QQ(3)**2-QQ(2)**2-QQ(1)**2
      ANDI11= BORNV(SVAR1,CTH11)
      ANDI12= BORNV(SVAR1,CTH12)
      ANDI21= BORNV(SVAR1,CTH21)
      ANDI22= BORNV(SVAR1,CTH22)
      DIST2 =  GI1*GF1*ANDI11+ GI1*GF2*ANDI12
     &        +GI2*GF1*ANDI21+ GI2*GF2*ANDI22
      END
      SUBROUTINE BVIRT0(P1,P2,DELS1,DELS2)
C     ************************************
C Virtual corrections to beta0
C beta0 is equal Born*(1+DELS1+DELS2)
C     ***********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION P1(*),P2(*)
      PARAMETER(PI=3.1415926535897932D0, ALFINV=137.03604D0)
      PARAMETER(ZET2= PI**2/6D0)
      PARAMETER(ZET3= 1.2020569031595942854D0)
      PARAMETER(ALF1=1D0/ALFINV/PI)
      SVAR   = (P1(4)+P2(4))**2-(P1(3)+P2(3))**2
     $        -(P1(2)+P2(2))**2-(P1(1)+P2(1))**2
      AMEL2  = P1(4)**2-P1(3)**2-P1(2)**2-P1(1)**2
      BILG  =  DLOG(SVAR/AMEL2)
      DELS1 =  ALF1*(BILG-1D0)
      DELS2 =  ALF1**2 *0.5D0*BILG**2
C Subleading terms
      DELS2 =  DELS2 + ALF1**2*(
     $            -(13D0/16D0 +1.5D0*ZET2 -3D0*ZET3)*BILG
     $            -16D0/5D0*ZET2*ZET2 +51D0/8D0*ZET2 +13D0/4D0
     $            -4.5D0*ZET3 -6D0*ZET2*LOG(2D0) )
      END
      SUBROUTINE BVIRT1(P1,P2,PH,DELS1)
C     *********************************
C VIRTUAL CORRECTION TO BETA1
C     ***********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION P1(*),P2(*),PH(*),PP(4)
      PARAMETER(PI=3.1415926535897932D0, ALFINV=137.03604D0)
      PARAMETER(ALF1=1D0/ALFINV/PI)
C
      DO 20 K=1,4
  20  PP(K)=P1(K)+P2(K)
      SVAR= PP(4)**2-PP(3)**2-PP(2)**2-PP(1)**2
      XK= 2*(PH(4)*PP(4)-PH(3)*PP(3)-PH(2)*PP(2)-PH(1)*PP(1))/SVAR
      AMEL2  = P1(4)**2-P1(3)**2-P1(2)**2-P1(1)**2
      BILG  =  DLOG(SVAR/AMEL2)
      DELS1 =  ALF1*(BILG-1D0)*(1D0-0.5D0*DLOG(1D0-XK))
      END
      SUBROUTINE BVIRF1(P1,P2,PH,DELS1)
C     *********************************
C VIRTUAL CORRECTION TO BETA1
C     ***********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION P1(*),P2(*),PH(*),PP(4)
      PARAMETER(PI=3.1415926535897932D0, ALFINV=137.03604D0)
      PARAMETER(ALF1=1D0/ALFINV/PI)
C
      DO 20 K=1,4
  20  PP(K)=P1(K)+P2(K)
      SVAR= PP(4)**2-PP(3)**2-PP(2)**2-PP(1)**2
      XK= 2*(PH(4)*PP(4)-PH(3)*PP(3)-PH(2)*PP(2)-PH(1)*PP(1))/SVAR
      XK=ABS(XK)/(1+ABS(XK))
      AMEL2  = P1(4)**2-P1(3)**2-P1(2)**2-P1(1)**2
      BILG  =  DLOG(SVAR/AMEL2)
      DELS1 =  ALF1*(BILG-1D0)*(1D0+0.5D0*DLOG(1D0-XK))
      END
      SUBROUTINE GSOFA1(P1,P2,PH,F1,F2)
C     *********************************
C CALCULATES INGREDIENTS FOR REAL SINGLE PHOTON DIFF. XSECTION
C     *****************************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION PH(*),P1(*),P2(*)
      AM2= P1(4)**2-P1(1)**2-P1(2)**2-P1(3)**2
      PK1= P1(4)*PH(4)-P1(1)*PH(1)-P1(2)*PH(2)-P1(3)*PH(3)
      PK2= P2(4)*PH(4)-P2(1)*PH(1)-P2(2)*PH(2)-P2(3)*PH(3)
      PP = P1(4)*P2(4)-P1(1)*P2(1)-P1(2)*P2(2)-P1(3)*P2(3)
      B  =  PK2/PP
      A  =  PK1/PP
      SFAC1  =  2D0*PP/PK1/PK2
      AM = AM2/(2D0*PP)
      WWM= 1D0-AM*2D0*(1D0-A)*(1D0-B)/((1D0-A)**2+(1D0-B)**2)*(A/B+B/A)
      F1   = 0.5D0*(1D0-A)**2*WWM *SFAC1
      F2   = 0.5D0*(1D0-B)**2*WWM *SFAC1
      END
      SUBROUTINE SFACH0(P1,P2,PH,SFAC0)
C     *********************************
C CALCULATES SOFT FACTOR FOR REAL SOFT PHOTON.
C     *********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION PH(4),P1(4),P2(4)
      AM2= P1(4)**2-P1(1)**2-P1(2)**2-P1(3)**2
      PK1= P1(4)*PH(4)-P1(1)*PH(1)-P1(2)*PH(2)-P1(3)*PH(3)
      PK2= P2(4)*PH(4)-P2(1)*PH(1)-P2(2)*PH(2)-P2(3)*PH(3)
      PP = P1(4)*P2(4)-P1(1)*P2(1)-P1(2)*P2(2)-P1(3)*P2(3)
      SFAC0  =  2D0*PP/PK1/PK2 -AM2/PK1**2 -AM2/PK2**2
      END
      SUBROUTINE GTHET0(P1,Q1,COSTH)
C     ******************************
C Calculates CosTh between BEAM and FINAL fermion
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION P1(*),Q1(*)
      COSTH  = (P1(1)*Q1(1) +P1(2)*Q1(2) +P1(3)*Q1(3))
     $            /SQRT((Q1(1)**2 +Q1(2)**2 +Q1(3)**2)
     $                 *(P1(1)**2 +P1(2)**2 +P1(3)**2))
      END
      SUBROUTINE GTHET1(P1,P2,Q1,COSTH1,COSTH2)
C     *****************************************
C Calculates CosTh1 and CosTh2 between BEAM amd FINAL
C fermion momenta in final fermion rest frame Q1(4)+Q2(4)=0
C     ***********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION P1(*),P2(*),Q1(*)
      COSTH1 = (P1(1)*Q1(1) +P1(2)*Q1(2) +P1(3)*Q1(3))
     $            /SQRT((Q1(1)**2 +Q1(2)**2 +Q1(3)**2)
     $                 *(P1(1)**2 +P1(2)**2 +P1(3)**2))
      COSTH2 =-(P2(1)*Q1(1) +P2(2)*Q1(2) +P2(3)*Q1(3))
     $            /SQRT((Q1(1)**2 +Q1(2)**2 +Q1(3)**2)
     $                 *(P2(1)**2 +P2(2)**2 +P2(3)**2))
      END
      SUBROUTINE GTHET3(P1,P2,Q1,Q2,CTH11,CTH12,CTH21,CTH22)
C     ***************************************************
C Calculates CosTh1 and CosTh2 between BEAM amd FINAL
C fermion momenta in Z RESONANCE rest frame Q1(4)+Q2(4)=0
C     ***********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION P1(*),P2(*),Q1(*),Q2(*)
      Q1D=        SQRT(Q1(1)**2 +Q1(2)**2 +Q1(3)**2)
      Q2D=        SQRT(Q2(1)**2 +Q2(2)**2 +Q2(3)**2)
      P1D=        SQRT(P1(1)**2 +P1(2)**2 +P1(3)**2)
      P2D=        SQRT(P2(1)**2 +P2(2)**2 +P2(3)**2)
      CTH11 = (Q1(1)*P1(1) +Q1(2)*P1(2) +Q1(3)*P1(3))/Q1D/P1D
      CTH12 =-(Q1(1)*P2(1) +Q1(2)*P2(2) +Q1(3)*P2(3))/Q1D/P2D
      CTH21 =-(Q2(1)*P1(1) +Q2(2)*P1(2) +Q2(3)*P1(3))/Q2D/P1D
      CTH22 = (Q2(1)*P2(1) +Q2(2)*P2(2) +Q2(3)*P2(3))/Q2D/P2D
      END
      SUBROUTINE TRALQQ(MODE,Q,P,R)
C     *****************************
C BOOST ALONG Z AXIS TO A FRAME WHERE QQ(3)=0
C AND NEXT ALONG TRANSVERSE DIRECTION OF QQ,
C FORTH (MODE = 1) OR BACK (MODE = -1).
C Q MUST BE A TIMELIKE, P MAY BE ARBITRARY.
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION Q(*),P(*),R(*)
      DIMENSION QL(4),QT(4)
      QL(4)=Q(4)
      QL(3)=Q(3)
      QL(2)=0D0
      QL(1)=0D0
      CALL BOSTDQ(1,QL,Q,QT)
      IF(MODE.EQ.1) THEN
        CALL BOSTDQ( 1,QL,P,R)
        CALL BOSTDQ( 1,QT,R,R)
      ELSE
        CALL BOSTDQ(-1,QT,P,R)
        CALL BOSTDQ(-1,QL,R,R)
      ENDIF
      END
      SUBROUTINE REDUZ0(QQ,P1,P2,PR1,PR2)
C     ***********************************
C reduction of momenta for beta0, second one
C I.E. WE MAPP:   P1,P2 ==> PR1,PR2
C such that  PR1+PR2 = QQ
C Resulting PRi QRi are in QQ rest frame.
C     ***********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER( EPS1 =1D-15)
      DIMENSION QQ(4),P1(4),P2(4),PR1(4),PR2(4)
      DIMENSION PP(4),PX1(4),PX2(4),PPX(4)
C
      DO 20 K=1,4
 20   PP(K)=P1(K)+P2(K)
      IF((PP(1)**2+PP(2)**2+PP(3)**2)/PP(4)**2 .GT. EPS1) THEN
C transform all momenta to QQ rest-frame
         CALL BOSTDQ( 1,QQ,P1 ,PX1)
         CALL BOSTDQ( 1,QQ,P2 ,PX2)
         CALL BOSTDQ( 1,QQ,PP ,PPX)
C transform all momenta to PP rest-frame
         CALL BOSTDQ( 1,PPX,PX1,PX1)
         CALL BOSTDQ( 1,PPX,PX2,PX2)
      ELSE
C do nothing if we are already in PP rest-frame
         DO 23 K=1,4
            PX1(K)=P1(K)
   23       PX2(K)=P2(K)
      ENDIF
C construct reduced beam momenta PR1,PR2
C note: they are understood to be in QQ rest-frame
      SVAR1 = QQ(4)**2-QQ(3)**2-QQ(2)**2-QQ(1)**2
      SVAR  = PP(4)**2-PP(3)**2-PP(2)**2-PP(1)**2
      VV    = 1D0 -SVAR1/SVAR
      IF(ABS(VV).GT. EPS1) THEN
         AMEL2=  P1(4)**2-P1(3)**2-P1(2)**2-P1(1)**2
         PR1(4)= SQRT(SVAR1)/2D0
         PR2(4)= PR1(4)
         PXMOD = SQRT(PX1(1)**2+PX1(2)**2+PX1(3)**2)
         PRMOD = SQRT(PR1(4)**2-AMEL2)
         DO 30 K=1,3
         PR1(K)= PX1(K)/PXMOD*PRMOD
 30      PR2(K)= PX2(K)/PXMOD*PRMOD
      ELSE
         DO 40 K=1,4
         PR1(K)= PX1(K)
 40      PR2(K)= PX2(K)
      ENDIF
      END
      SUBROUTINE REDUZ1(QQ,P1,P2,PH,PR1,PR2,PHR)
C     ******************************************
C reduction of 4-momenta for beta1
C           P1,P2,PH ==--> PR1,PR2,PHR
C such that  PR1+PR2 = QQ+PHR
C     ***********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER( EPS1 =1D-15)
      COMMON / INOUT  / NINP,NOUT
      SAVE   / INOUT  /
      DIMENSION QQ(4), P1(4), P2(4), PH(4), PR1(4),PR2(4),PHR(4)
      DIMENSION PP(4),QQK(4),PPX(4), PPK(4)
      DIMENSION PX1(4),PX2(4),PHX(4)
C
      DO 20 K=1,4
      PP(K)   = P1(K)+P2(K)
      PPK(K)  = P1(K)+P2(K)-PH(K)
 20   QQK(K)  = QQ(K)+PH(K)
      SVAR  =  PP(4)**2 -PP(3)**2 -PP(2)**2 -PP(1)**2
      SVAR1 =  QQ(4)**2 -QQ(3)**2 -QQ(2)**2 -QQ(1)**2
      SS1   = PPK(4)**2-PPK(3)**2-PPK(2)**2-PPK(1)**2
      SS2   = QQK(4)**2-QQK(3)**2-QQK(2)**2-QQK(1)**2
      IF((PP(1)**2+PP(2)**2+PP(3)**2)/PP(4)**2 .GT. EPS1) THEN
C transform all momenta to QQ rest-frame
         CALL BOSTDQ( 1,QQ,P1 ,PX1)
         CALL BOSTDQ( 1,QQ,P2 ,PX2)
         CALL BOSTDQ( 1,QQ,PH ,PHX)
         CALL BOSTDQ( 1,QQ,PP ,PPX)
C transform all momenta to PP rest-frame
         CALL BOSTDQ( 1,PPX,PX1,PX1)
         CALL BOSTDQ( 1,PPX,PX2,PX2)
         CALL BOSTDQ( 1,PPX,PHX,PHX)
      ELSE
C do nothing if we are already in PP rest-frame
         DO 23 K=1,4
            PHX(K)=PH(K)
            PX1(K)=P1(K)
   23       PX2(K)=P2(K)
      ENDIF
C construct reduced beam momenta PR1,PR2
C note: they are understood to be in QQ rest-frame
      VV2   = 1D0 - SS2/SVAR
      IF(ABS(VV2).GT. EPS1) THEN
         PK    =  (PX1(4)+PX2(4))*PHX(4)
CCCCC    XLAM= SQRT(SVAR1/SVAR+(PK/SVAR)**2)+PK/SVAR
         XLAM= SQRT(SVAR1/SS1)
         AMEL2=  P1(4)**2-P1(3)**2-P1(2)**2-P1(1)**2
         PXMOD = SQRT(PX1(1)**2+PX1(2)**2+PX1(3)**2)
         PX1(4)= PX1(4)*XLAM
         PX2(4)= PX2(4)*XLAM
CCC      PRMOD = SQRT(PX1(4)**2-AMEL2)
         PRMOD =      PX1(4)**2-AMEL2
         IF(PRMOD.LE.0D0) WRITE(NOUT,*) ' REDUZ1: PRMOD=', PRMOD
         IF(PRMOD.LE.0D0) WRITE(   6,*) ' REDUZ1: PRMOD=', PRMOD
         PRMOD = SQRT(ABS(PRMOD))
         DO 30 K=1,3
         PX1(K)= PX1(K)/PXMOD*PRMOD
 30      PX2(K)= PX2(K)/PXMOD*PRMOD
         DO 31 K=1,4
 31      PHX(K)= PHX(K)*XLAM
      ENDIF
C then, boost away the three-vector part of P1+P2-PH
C that is transform to QQ rest frame
      DO 35 K=1,4
 35   PP(K)= PX1(K)+PX2(K)-PHX(K)
      CALL BOSTDQ( 1,PP,PX1,PR1)
      CALL BOSTDQ( 1,PP,PX2,PR2)
      CALL BOSTDQ( 1,PP,PHX,PHR)
      END
      SUBROUTINE REDUZ2(QQ,P1,P2,PH1,PH2,PR1,PR2,PH1R,PH2R)
C     *****************************************************
C Reduction for beta2
C           P1,P2,PH1,PH2 ==--> PR1,PR2,PH1R,PH2R
C such that  PR1+PR2 = PH1R+PH2R+QQ
C Input:  QQ,P1,P2,PH1,PH2
C Output: PR1,PR2,PH1R,PH2R
C     ***********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER( EPS1 =1D-15)
      COMMON / INOUT  / NINP,NOUT
      SAVE   / INOUT  /
      DIMENSION QQ(*), P1(*),  P2(*),  PH1(*),  PH2(*)
      DIMENSION        PR1(*), PR2(*), PH1R(*), PH2R(*)
      DIMENSION PP(4),QQK(4),PPK(4),PPX(4)
      DIMENSION PX1(4),PX2(4),PH1X(4),PH2X(4),SPH(4)
C
      DO 20 K=1,4
      PP(K)   = P1(K)+P2(K)
      PPK(K)  = P1(K)+P2(K)-PH1(K)-PH2(K)
 20   QQK(K)  = QQ(K)+PH1(K)+PH2(K)
      SVAR  =  PP(4)**2 -PP(3)**2 -PP(2)**2 -PP(1)**2
      SVAR1 =  QQ(4)**2 -QQ(3)**2 -QQ(2)**2 -QQ(1)**2
      SS1   = PPK(4)**2-PPK(3)**2-PPK(2)**2-PPK(1)**2
      SS2   = QQK(4)**2-QQK(3)**2-QQK(2)**2-QQK(1)**2
      IF((PP(1)**2+PP(2)**2+PP(3)**2)/PP(4)**2 .GT. EPS1) THEN
C transform all momenta to QQ rest-frame
         CALL BOSTDQ( 1,QQ,P1 ,PX1)
         CALL BOSTDQ( 1,QQ,P2 ,PX2)
         CALL BOSTDQ( 1,QQ,PH1,PH1X)
         CALL BOSTDQ( 1,QQ,PH2,PH2X)
         CALL BOSTDQ( 1,QQ,PP ,PPX)
C transform all momenta to PP rest-frame
         CALL BOSTDQ( 1,PPX,PX1,PX1)
         CALL BOSTDQ( 1,PPX,PX2,PX2)
         CALL BOSTDQ( 1,PPX,PH1X,PH1X)
         CALL BOSTDQ( 1,PPX,PH2X,PH2X)
      ELSE
C do nothing if we are already in PP rest-frame
         DO 23 K=1,4
            PH1X(K)=PH1(K)
            PH2X(K)=PH2(K)
            PX1(K)=P1(K)
   23       PX2(K)=P2(K)
      ENDIF
C construct reduced beam momenta PR1,PR2
C note: they are understood to be in QQ rest-frame
      VV2   = 1D0 - SS2/SVAR
      IF(ABS(VV2).GT.1D-6) THEN
C construct reduced beam momenta PR1,PR2
C start with dilatation of beams
         DO 24 K=1,4
         PP(K)  =  PX1(K)+PX2(K)
  24     SPH(K) =  PH1(K)+PH2(K)
         PK     =  PP(4)*SPH(4)
         SK2    =  SPH(4)**2 -SPH(3)**2 -SPH(2)**2 -SPH(1)**2
CCCC     XLAM   =  SQRT((SVAR1-SK2)/SVAR+(PK/SVAR)**2)+PK/SVAR
         XLAM   =  SQRT(SVAR1/SS1)
         AMEL2  =  P1(4)**2-P1(3)**2-P1(2)**2-P1(1)**2
         PXMOD  =  SQRT(PX1(1)**2+PX1(2)**2+PX1(3)**2)
         PX1(4) =  PX1(4)*XLAM
         PX2(4) =  PX2(4)*XLAM
CCCC     PRMOD  =  SQRT(PX1(4)**2-AMEL2)
         PRMOD  =      PX1(4)**2-AMEL2
         IF(PRMOD.LE.0D0) WRITE(NOUT,*) ' REDUZ2: PRMOD=', PRMOD
         IF(PRMOD.LE.0D0) WRITE(   6,*) ' REDUZ2: PRMOD=', PRMOD
         PRMOD  = SQRT(ABS(PRMOD))
         DO 30 K=1,3
         PX1(K) = PX1(K)/PXMOD*PRMOD
 30      PX2(K) = PX2(K)/PXMOD*PRMOD
         DO 31 K=1,4
         PH1X(K)= PH1X(K)*XLAM
 31      PH2X(K)= PH2X(K)*XLAM
      ENDIF
C then, boost away the three-vector part of P1+P2-PH1-PH2
C that is transform to QQ rest frame
      DO 35 K=1,4
 35   PP(K)= PX1(K)+PX2(K)-PH1X(K)-PH2X(K)
      CALL BOSTDQ( 1,PP,PX1,PR1)
      CALL BOSTDQ( 1,PP,PX2,PR2)
      CALL BOSTDQ( 1,PP,PH1X,PH1R)
      CALL BOSTDQ( 1,PP,PH2X,PH2R)
      END

      FUNCTION BREMKF(KEY,EREL)
C     *************************
C NON-MONTECARLO INTEGRATION OF THE V-DISTRIBUTION
C GAUSS METHOD, CHANGE OF VARIABLES WITH HELP OF CHBIN1
C SEE VVDISB
C KEY= 1,2,3,...FOR VARIOUS DISTRIBUTIONS
C KEY= 3 FOR MC GENERATION, OTHER FOR TESTS
C FOR KEYFIX=1, EXEPTIONALLY, IT PROVIDES INTEGRAND AT VV=VVMAX
C WITH BORN OMITTED
C     ************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON / KEYYFS / KEYZET,KEYBRM,KEYFIX,KEYRED,KEYWGT
C COMMON KEYDST COMMUNICATES ONLY WITH VVDISB - INTEGRAND FUNCTION
      COMMON / KEYDST / KEYDIS
      COMMON / WEKING / ENE,AMAZ,GAMMZ,AMEL,AMFIN,XK0,SINW2,IDE,IDF
      COMMON / VVREC  / VVMIN,VVMAX,VV,BETI
      SAVE / KEYYFS /,/ KEYDST /,/ WEKING /,/ VVREC  /
      EXTERNAL VVDISB
C
      KEYDIS=KEY
      IF(KEYFIX.EQ.0) THEN
         XBORN  =BORNY(4D0*ENE**2)
         PREC=  XBORN*EREL
         XA= 0D0
         XB= 1D0
         CALL GAUSJD(VVDISB,XA,XB,PREC,RESULT)
         BREMKF=RESULT
      ELSE
         SVAR  = 4D0*ENE**2
         BREMKF= VVRHO(KEYDIS,SVAR,AMEL,VVMAX,VVMIN)
     $          /VVRHO(     9,SVAR,AMEL,VVMAX,VVMIN)
      ENDIF
      END
      FUNCTION VVDISB(R)
C     ******************
C INTEGRAND FOR BREMKF
C MAPPING XX => VV CHANGE  TO IMPROVE ON EFFICIENCY
C     ************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER( FLEPS =1D-35)
      COMMON / WEKING / ENE,AMAZ,GAMMZ,AMEL,AMFIN,XK0,SINW2,IDE,IDF
      COMMON / VVREC  / VVMIN,VVMAX,VV,BETI
      COMMON / KEYDST / KEYDIS
      SAVE / WEKING /,/ VVREC  /,/ KEYDST /
C
      KEYD=KEYDIS
      X = MAX(R,FLEPS**BETI)
      ALF=  BETI
      BET=  1D0
C ...SPECIAL CASES
C ...Monte Carlo crude distr
      IF    (KEYD.EQ.1)  THEN
        BET=  -0.5D0
C ...YFS exponentiation beta0,1,2 contribs
      ELSEIF(KEYD.EQ.310)  THEN
        ALF=  BETI
      ELSEIF(KEYD.EQ.311)  THEN
        ALF=  BETI +1
      ELSEIF(KEYD.EQ.320)  THEN
        ALF=  BETI
      ELSEIF(KEYD.EQ.321)  THEN
        ALF=  BETI +1
      ELSEIF(KEYD.EQ.322)  THEN
        ALF=  BETI +2
C ...Reference distr including dilatation factor DAMEL
      ELSEIF(KEYD.EQ.12) THEN
        BET=  -0.5
      ENDIF
      CALL CHBIN1(X,ALF,BET,VVMAX,VV,RJAC)
C BORN XSECTION
C NOTE 1/(1-VV) FACTOR BECAUSE BORNY IS IN R-UNITS
      SVAR   = 4D0*ENE**2
      SVAR1  = SVAR*(1D0-VV)
      XBORN  = BORNY(SVAR1)/(1D0-VV)
      VVDISB = VVRHO(KEYD,SVAR,AMEL,VV,VVMIN) *RJAC*XBORN
      END
      FUNCTION VVRHO(KEYDIS,SVAR,AMEL,VV,VVMIN)
C     *****************************************
C-------------------------------------------------------------
C Convention for KEYDIS
C Pedagogical exercises
C     KEYDIS   =  1      crude distribution for initial state MC
C     KEYDIS   =  9      reference distr.  of YFS2 CPC paper
C     KEYDIS   =  50-52  obsolete test distr. for YFS2 CPC paper
C     KEYDIS   =  101    soft part YFS       First  Order
C     KEYDIS   =  102    soft part YFS       Second Order
C     KEYDIS   =  105    hard non-exp.       First  Order
C     KEYDIS   =  106    hard non-exp.       Second Order
C Total results
C     KEYDIS   =  0 + R*100                  Zero   Order
C     KEYDIS   =  1 + R*100                  First  Order
C     KEYDIS   =  2 + R*100                  Second Order
C     KEYDIS   = 15     reference distr. of YFS paper
C Beta contributions
C     KEYDIS   = 10 + R*100      Beta0       Zero   Order
C     KEYDIS   = 11 + R*100      Beta0       First  Order
C     KEYDIS   = 12 + R*100      Beta1
C     KEYDIS   = 20 + R*100      Beta0       Second Order
C     KEYDIS   = 21 + R*100      Beta1
C     KEYDIS   = 22 + R*100      Beta2
C     R = 200 Kuraev-Fadin
C     R = 300 YFS (pragmatic)
C     R = 400 YFS single electron LL str. funct.
C-------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER(PI= 3.1415926535897932D0, ALFINV=137.03604D0)
      PARAMETER(ALF1   = 1D0/PI/ALFINV)
      PARAMETER(CEULER =0.57721566D0)
      COMMON / INOUT  / NINP,NOUT
      SAVE   / INOUT  /
C
      KEYD = KEYDIS
      BILG   = DLOG(SVAR/AMEL**2)
      BETI   = 2D0*ALF1*(BILG-1D0)
C===================================================================
C ---------------------- KEYD = 1 ----------------------------------
C ---- Crude distribution in YFS2 initial state Monte Carlo --------
C ------------------------------------------------------------------
c dilat is related to dilatation jacobian in yfsgen
c damel is responsible for modification of photon ang. distribution
c see also weight wt=wt1 in   angbre
      IF(KEYD.GE.1.AND.KEYD.LT.100) THEN
         DILAT=1D0
         IF(VV.GT.VVMIN) DILAT=(1D0+1D0/SQRT(1D0-VV))/2D0
         BETI2  = 2D0*ALF1*BILG
         DAMEL=1D0
         IF(VV.GT.VVMIN) DAMEL=BETI2/BETI*(VV/VVMIN)**(BETI2-BETI)
C---------
         IF    (KEYD.EQ.1)  THEN
            DISTR= BETI*VV**(BETI-1D0)*DILAT*DAMEL
C ...Reference distribution used in YFS2 paper --------------------
         ELSEIF(KEYD.EQ. 9)  THEN
            DISTR= BETI*VV**(BETI-1D0)*(1+(1-VV)**2)/2
C basic reference distribution  xrefer=sigma-ref
         ELSEIF(KEYD.EQ.50) THEN
            DISTR= BETI*VV**(BETI-1D0)
C XREFER TIMES DAMEL
         ELSEIF(KEYD.EQ.51) THEN
            DISTR= BETI*VV**(BETI-1D0)*DAMEL
C XREFER TIMES DILATATION FACTOR DILAT
         ELSEIF(KEYD.EQ.52) THEN
            DISTR= BETI*VV**(BETI-1D0)*DILAT
         ENDIF
C ------------------------------------------------------------
C ------------- Soft part only  -- YFS exponentiation
C ------------------------------------------------------------
      ELSEIF(KEYD.GE. 101.AND.KEYD.LE.102) THEN
         DELB   = ALF1*(0.5D0*BILG -1D0  +PI**2/3D0)
         GAMFAC =EXP(-CEULER*BETI)/DPGAMM(1D0+BETI)
C ....first order
         IF(KEYD  .EQ. 101) THEN
            DELS = ALF1*(BILG-1D0)
C ....Second Order
         ELSEIF(KEYD  .EQ. 102) THEN
            DELS = ALF1*(BILG-1D0) +0.5D0*(ALF1*BILG)**2
         ENDIF
         DISTR=  GAMFAC*EXP(DELB)*BETI*VV**(BETI-1D0)*( 1D0+DELS)
C ---------------------------------------------------------------
C ------------- Hard part only - no exponentiation
C ---------------------------------------------------------------
      ELSEIF(KEYD.GE. 105.AND.KEYD.LE.106 ) THEN
         Z=1D0-VV
C ....First  Order
         IF(KEYD  .EQ. 105) THEN
            DISTR =  BETI*(1D0 +Z**2)/2D0/VV
C ....Second Order
         ELSEIF(KEYD  .EQ. 106) THEN
            DIST1 =  BETI*(1D0 +Z**2)/2D0/VV
            DELH2 =  (ALF1*BILG)**2*(
     $             -(1D0+Z*Z)/VV*DLOG(Z)
     $              +(1D0+Z)*(0.5D0*DLOG(Z)-2D0*DLOG(VV))
     $              -2.5D0-0.5D0*Z  )
            DIST2 =  (ALF1*BILG)**2*( 3 +4*DLOG(VV))/VV +DELH2
            DISTR =  DIST1+DIST2
         ENDIF
C ---------------------------------------------------------------
C ---------------------------------------------------------------
C ----- exponentiation following Kuraiev Fadin prescription
C ---------------------------------------------------------------
      ELSEIF(KEYD.GE.201.AND.KEYD.LE.202) THEN
C First Order  from Gerrit Burgers (POLARIZATION BOOK)
         DZ2 = PI**2/6D0
         Z=1D0-VV
         IF(KEYD  .EQ.201) THEN
            DELVS= ALF1*(1.5D0*BILG +2D0*DZ2-2D0)
            DELH=  -ALF1*(1D0+Z)*(BILG-1D0)
         ELSEIF(KEYD  .EQ.202) THEN
            DELVS= ALF1*(1.5D0*BILG +2D0*DZ2-2D0)
     $            +ALF1**2*(9D0/8D0-2D0*DZ2)*BILG**2
            DELH=  -ALF1*(1D0+Z)*(BILG-1D0)
     $      +ALF1**2*( -(1D0+Z*Z)/VV     *DLOG(Z)
     $              +(1D0+Z)*(0.5D0*DLOG(Z)-2D0*DLOG(VV))
     $              -2.5D0-0.5D0*Z)*BILG**2
         ENDIF
         DISTR=  BETI*VV**(BETI-1D0)*( 1D0+DELVS) +DELH
C ---------------------------------------------------------------
C ------------- YFS ad-hoc exponentiation -----------------------
C ---------------------------------------------------------------
      ELSEIF(KEYD.GE.300.AND.KEYD.LE.302) THEN
         DELB   = ALF1*(0.5D0*BILG -1D0  +PI**2/3D0)
         GAMFAC =EXP(-CEULER*BETI)/DPGAMM(1D0+BETI)
C ....Zero   Order
         IF(KEYD  .EQ.300)  THEN
            DELS = 0D0
            DELH = -BETI/4 *LOG(1-VV)
C ....First  Order
         ELSEIF(KEYD  .EQ.301)  THEN
            DELS = BETI/2
            DELH = VV*(-1 +VV/2)
     $      -BETI/2*VV**2 - BETI/4*(1-VV)**2*LOG(1-VV)
C ....Second Order
         ELSEIF(KEYD  .EQ.302)  THEN
            DELS = ALF1*(BILG-1D0) +0.5D0*(ALF1*BILG)**2
            DELH = VV*(-1D0+VV/2D0)
     $      +ALF1*BILG*(-0.25D0*(4D0-6D0*VV+3D0*VV**2)*DLOG(1D0-VV) -VV)
         ENDIF
         DISTR= GAMFAC*EXP(DELB)*BETI*VV**(BETI-1D0)*(1 +DELS + DELH )
C----------------------------------------------------------------
C-------------- YFS ad-hoc exponentiation -----------------------
C-------------Contributions  from various beta's ----------------
C----------------------------------------------------------------
      ELSEIF(KEYD.GE.310.AND.KEYD.LE.322)  THEN
         DELB   = ALF1*(0.5D0*BILG -1D0  +PI**2/3D0)
         GAMFAC = EXP(-CEULER*BETI)/DPGAMM(1D0+BETI)
         SOFT   = 0D0
         DELH   = 0D0
C ...Beta0 First  Order
         IF(KEYD.EQ.310) THEN
            SOFT = 1 + BETI/2
            DELH = -BETI/4 *LOG(1-VV)
C ...Beta1 First  Order
         ELSEIF(KEYD.EQ. 311)  THEN
            DELH =
     $      VV*(-1D0+VV/2/(1+BETI))*(1-0.5*BETI*LOG(1-VV))
C ...Beta0 Second Order
         ELSEIF(KEYD.EQ.320) THEN
            SOFT = 1 + BETI/2  +BETI**2/8
            DELH = -BETI/4 *LOG(1-VV)
C ...Beta1 Second Order
         ELSEIF(KEYD.EQ. 321)  THEN
            DELH = VV*(-1+VV/2)
     $      -BETI*VV/2 -BETI*VV**2/4 +BETI/8*(-2+6*VV-3*VV**2)*LOG(1-VV)
C ...Beta2 Second Order
         ELSEIF(KEYD.EQ. 322)  THEN
            DELH =    BETI*  VV**2/4D0
         ENDIF
         DISTR=  GAMFAC*EXP(DELB)*BETI*VV**(BETI-1D0)*(SOFT+DELH)
C -------------------------------------------------------------------
C -------------------YFS formula-------------------------------------
C -------------Single fermion LL fragmentation ----------------------
C -------------------------------------------------------------------
      ELSEIF(KEYD.GE.400.AND.KEYD.LE.402)  THEN
C&&&&&&  DELB   = BETI/4
         DELB   = BETI/4  +ALF1*(-0.5D0  +PI**2/3D0)
         GAMFAC = EXP(-CEULER*BETI)/DPGAMM(1D0+BETI)
         SOFT   = 0D0
         DELH   = 0D0
C ...Zero   Order
         IF(KEYD.EQ.400) THEN
            SOFT = 1
C ...First  Order
         ELSEIF(KEYD.EQ.401) THEN
            SOFT = 1 + BETI/2
            DELH =
     $      VV*(-1D0+VV/2/(1+BETI))
C ...Second Order
         ELSEIF(KEYD.EQ.402) THEN
            SOFT = 1 + BETI/2  +BETI**2/8
C           DELH =
C    $      VV*(1+0.5*BETI)*(-1D0+VV/2/(1+BETI))
C    $      -0.50*BETI*LOG(1-VV)*0.5*(1+(1-VV)**2)
C    $      + BETI/4D0*VV*(VV +(1-VV/2)*DLOG(1D0-VV))
            DELH =
     $      VV*(-1D0+VV/2)
     $      + BETI*(-VV/2 -(1+3*(1-VV)**2)/8*DLOG(1D0-VV))
         ENDIF
         DISTR=  GAMFAC*EXP(DELB)*BETI*VV**(BETI-1D0)*(SOFT+DELH)
C -------------------------------------------------------------------
C -------------Single fermion LL fragmentation ----------------------
C -------------Contributions  from various beta's -------------------
C -------------------------------------------------------------------
      ELSEIF(KEYD.GE.400.AND.KEYD.LE.422)  THEN
C&&&&&   DELB   = BETI/4
         DELB   = BETI/4  +ALF1*(-0.5D0  +PI**2/3D0)
         GAMFAC = EXP(-CEULER*BETI)/DPGAMM(1D0+BETI)
         SOFT   = 0D0
         DELH   = 0D0
C ...Beta0 zero   Order
         IF(KEYD.EQ.400) THEN
            SOFT = 1
C ...Beta0 First  Order
         ELSEIF(KEYD.EQ.410) THEN
            SOFT = 1 + BETI/2
C ...Beta1 First  Order
         ELSEIF(KEYD.EQ. 411)  THEN
            DELH =
     $      VV*(-1D0+VV/2/(1+BETI))
C ...Beta0 Second Order
         ELSEIF(KEYD.EQ.420) THEN
            SOFT = 1 + BETI/2  +BETI**2/8
C ...Beta1 Second Order
         ELSEIF(KEYD.EQ. 421)  THEN
            DELH =
     $      VV*(1+0.5*BETI)*(-1D0+VV/2/(1+BETI))
     $      -0.50*BETI*LOG(1-VV)*0.5*(1+(1-VV)**2)
C ...Beta2 Second Order
         ELSEIF(KEYD.EQ. 422)  THEN
            DELH = BETI/4D0*VV*(VV +(1-VV/2)*DLOG(1D0-VV))
         ELSE
            GOTO 900
         ENDIF
         DISTR=  GAMFAC*EXP(DELB)*BETI*VV**(BETI-1D0)*(SOFT+DELH)
C ----------------------------------------------------------------
C -------------Single fermion LL fragmentation -------------------
C -------------I N F I N I T E   O R D E R -----------------------
C ----------------------------------------------------------------
      ELSEIF(KEYD.EQ.502)  THEN
         DELB   = BETI*0.75D0
         GAMFAC = EXP(-CEULER*BETI)/DPGAMM(1D0+BETI)
         SOFT   = 1
         DELH =
     $   VV*(-1D0+VV/2)
     $   + BETI*(-VV**2/4 -(1+3*(1-VV)**2)/8*DLOG(1D0-VV))
         DISTR=  GAMFAC*EXP(DELB)*BETI*VV**(BETI-1D0)*(SOFT+DELH)
      ELSE
         GOTO 900
      ENDIF
      VVRHO = DISTR
      RETURN
 900  WRITE(6,*) ' ===--->  WRONG KEYDIS IN VVRHO',KEYD
      STOP
      END


      FUNCTION BREFKF(KEY,EREL)
C     *************************
C Non-MonteCarlo integration of the u-distribution FINAL st.bremss.
C Gauss method, change of variables with help of CHBIN1
C     ************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C COMMON KEYDST COMMUNICATES ONLY UUDISB - INTEGRAND FUNCTION
      COMMON / KEYDST / KEYDIS
      SAVE   / KEYDST /
      EXTERNAL UUDISB
C
      KEYDIS=KEY
      PREC= DABS( EREL)
      XA= 0D0
      XB= 1D0
      CALL GAUSJD(UUDISB,XA,XB,PREC,RESULT)
      BREFKF=RESULT
      END
      FUNCTION UUDISB(R)
C     ******************
C INTEGRAND FOR BREFKF
C MAPPING XX => UU CHANGE  TO IMPROVE ON EFFICIENCY
C     ************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER( FLEPS =1D-35)
      PARAMETER( PI=3.1415926535897932D0,ALFINV= 137.03604D0)
      PARAMETER( ALF1=1D0/ALFINV/PI)
      COMMON / WEKING / ENE,AMAZ,GAMMZ,AMEL,AMFIN,XK0,SINW2,IDE,IDF
      COMMON / VVREC  / VVMIN,VVMAX,VV,BETI
      COMMON / KEYDST / KEYDIS
      SAVE / WEKING /,/ VVREC  /,/ KEYDST /
C
      KEYD=KEYDIS
      BETF= 2/ALFINV/PI*(DLOG(4*ENE**2/AMFIN**2)-1)
      X = MAX(R,FLEPS**BETF)
      ALF=  BETF
      BET=  1D0
C ...YFS exponentiation beta0,1,2 contribs
      IF(KEYD.EQ.310) THEN
        ALF=  BETF
      ELSEIF(KEYD.EQ.311)  THEN
        ALF=  BETF +1
      ELSEIF(KEYD.EQ.320) THEN
        ALF=  BETF
      ELSEIF(KEYD.EQ.321)  THEN
        ALF=  BETF +1
      ELSEIF(KEYD.EQ.322)  THEN
        ALF=  BETF +2
      ENDIF
      CALL CHBIN1(X,ALF,BET,VVMAX,UU,RJAC)
      SVAR   = 4D0*ENE**2
      UUDISB=UURHO(KEYD,SVAR,AMFIN,UU)*RJAC
      END
      FUNCTION UURHO(KEYDIS,SVAR,AMFIN,UU)
C     ******************************************
C--------------------------------------------------------------
C The parametrization of the final state bremss. as in YFS3
C Various types of the rho(u) distribution
C--------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER(PI= 3.1415926535897932D0, ALFINV=137.03604D0)
      PARAMETER(CEULER =0.57721566D0)
      COMMON / INOUT  / NINP,NOUT
      SAVE   / INOUT  /
C
      KEYD   = KEYDIS
      ALF1   = 1D0/PI/ALFINV
      SPRIM  = SVAR*(1-UU)
      BILG   = DLOG(SPRIM/AMFIN**2)
      BETF   = 2D0*ALF1*(BILG-1D0)
C -------------YFS formula ------------------------------------------
      IF(KEYD.GE.300.AND.KEYD.LE.302) THEN
         DELB   = ALF1*(0.5D0*BILG -1D0  +PI**2/3D0)
         DELB   = DELB -BETF/2 *DLOG(1-UU)
         GAMFAC =EXP(-CEULER*BETF)/DPGAMM(1D0+BETF)
C ....Zero   Order
         IF(KEYD  .EQ.300)  THEN
            DELS = 0D0
            DELH = -BETF/4 *LOG(1-UU)
C ....First  Order
         ELSEIF(KEYD  .EQ.301)  THEN
            DELS = BETF/2
            DELH = UU*(-1 +UU/2)
     $       +BETF*(-UU**2/2 - 0.25D0*(1-UU)**2*LOG(1-UU) )
C final state specific contr.
     $       +BETF*UU/2*(1-UU/2)*LOG(1-UU)
C ....Second Order
         ELSEIF(KEYD  .EQ.302)  THEN
            DELS  = BETF/2D0 +BETF**2/8D0
            DELH  = UU*(-1D0+UU/2D0)
     $        +BETF*( -UU/2  +(2*UU-UU**2)/8*LOG(1-UU) )
         ENDIF
         DISTR= GAMFAC*EXP(DELB)*BETF*UU**(BETF-1D0)*(1 +DELS +DELH )
C -------------------------------------------------------------------
C -------------Contributions  from various beta's -------------------
      ELSEIF(KEYD.GE.310.AND.KEYD.LE.322)  THEN
         DELB   = ALF1*(0.5D0*BILG -1D0  +PI**2/3D0)
         DELB   = DELB -BETF/2 *DLOG(1-UU)
         GAMFAC = EXP(-CEULER*BETF)/DPGAMM(1D0+BETF)
         SOFT   = 0D0
         DELH   = 0D0
C ...Beta0 First  Order
         IF(KEYD.EQ.310) THEN
            SOFT = 1 + BETF/2
            DELH = -BETF/4 *LOG(1-UU)
C ...Beta1 First  Order
         ELSEIF(KEYD.EQ. 311)  THEN
            DELH =
     $      UU*(-1D0+UU/2/(1+BETF))*(1-0.5*BETF*LOG(1-UU))
     $       -BETF*UU/2*(-1+UU/2)*LOG(1-UU)
C ...Beta0 Second Order
         ELSEIF(KEYD.EQ.320) THEN
            SOFT = 1 + BETF/2  +BETF**2/8
            DELH = -BETF/4 *LOG(1-UU)
C ...Beta1 Second Order
         ELSEIF(KEYD.EQ. 321)  THEN
            DELH =
     $      UU*(1+0.5*BETF)*(-1D0+UU/2/(1+BETF))*(1-0.5*BETF*LOG(1-UU))
     $       +0.25*BETF*LOG(1-UU)*0.5*(1+(1-UU)**2)
C final state specific contrib.
     $       +BETF*UU/2*(1-UU/2)*LOG(1-UU)
C           DELH = UU*(-1D0+UU/2D0)
C    $       +BETF*(-UU/2 -UU**2/4 +(2+2*UU-UU**2)/8D0*LOG(1-UU))
C ...Beta2 Second Order
         ELSEIF(KEYD.EQ. 322)  THEN
            DELH =    BETF*UU/2*( UU/2  -(1-UU/2)*LOG(1-UU) )
         ENDIF
         DISTR=  GAMFAC*EXP(DELB)*BETF*UU**(BETF-1D0)*(SOFT+DELH)
      ELSE
         WRITE(NOUT,*) ' ===--->  WRONG KEYDIS IN UURHO'
         STOP
      ENDIF
      UURHO = DISTR
      END
C----------------------------------------------------------------------
C----------------------------------------------------------------------
C----------------------------------------------------------------------



C=============================================================
C=============================================================
C==== end of elementary file =================================
C=============================================================
C=============================================================
      SUBROUTINE EXPAND(MODE,XPAR,NPAR)
C     ****************************************
C  !!!!! LOGBOOK OF CORRECTIONS starting Nov. 91 !!!
C  R1 and R2 in KINEKR undefined
C  BREMKF, VVDIST moved to yfs3mod.f
C  VVDIST replaced with VVRHO from YFSFIG
C  VESK8A replaced by VESK1W
C  FUNSKO replaced by RHOSKO (change of name)
C  GAUSS replaced by GAUSJD
C  CMSENE shiftet to XPAR !!! 3 first entries in XPAR changed
C  CHBIN2 replaced by CHBIN1
C  XPAR(10,12) in output are swapped (to bhlumi convention)
*  Initialization of GLIBK in the generator
*  Bug with parameter(pi=...) corrected
C=======================================================================
C=======================================================================
C=============================YFS3======================================
C=====================FERMION PAIR PRODUCTION===========================
C===============INITIAL AND FINAL STATE EXPONENTIATION==================
C=======================================================================
C=======================================================================
C=======================YFS VERSION 3.3.0===============================
C=======================================================================
C=========================FEBRUARY  1993================================
C=======================================================================
C AUTHORS:
C    S. JADACH, JAGELLONIAN UNIVERSITY, CRACOW, POLAND
C    B.F.L. WARD, UNIVERSITY OF TENNESSEE, KNOXVILLE, TENNESSEE
C=======================================================================
C
C SOME CONTROLL HISTOGRAMING STILL IN PROGRAM
C
C generator of yennie-frautschi-suura type
C with exponentiated single bremsstrahlung
C********* input
C mode =-1/0/1/2 defines
C       initialization/generation/give-xsection/final-report
C cmsene   = centre of mass energy (gev)
C npar(1)=keyrad=1000001 initial state only
C         keyrad=1000010 final state only
C         keyrad=1000011 initial + final state
C         keyrad=1000000 born without any bremss.
C         keyrad=100n001 fixed initial state multiplicity (tests)
C         keyrad=10k0010 fixed final   state multiplicity (tests)
C npar(2)=keyred=0,1,2   three different reduction procedures
C npar(3)=keywgt=0,1   unweighted/weighted events
C xpar(1)=cmsene  =  mass of z0
C xpar(2)=amaz    =  mass of z0
C xpar(3)=sinw2   =  sin(thetaweinberg)**2
C xpar(4)=gammz   =  width of z0
C xpar(5)=amfin   =  mass of final fermion
C xpar(6)=vvmin   =  minimum v-variable (dimesionless) =epsilon
C xpar(7)=vvmax   =  maximum v-variable
C********* output
C fourmomenta and photon multiplicity in /momset/
C xpar(10)=xsecnb = cross section in nanobarns
C xpar(11)=errel  = relative error (dimensionless)
C xpar(12)=xsmc   = cross section in r-units
C npar(10)=nevacc = number of generated events
C**************************
C For advanced users only:
C (1) One may use KEYRAD < 0  for running at fixed v-variable,
C in this case all events have  v=VMAX precisely.
C (2) For KEYWGT=1 weighted events are generated and the user should
C use the weight WTMOD from the common block /WGTALL/.
C WTMOD is the actual model weight depending on other input params.
C The other interesting possibility is to use
C     WT=WTCRU1*WTCRU2*WTSET(i) where
C     WTSET(71) =   zero-th order initial+final
C     WTSET(72) =   first order   initial+final
C     WTSET(73) =   second order  initial+final
C and the following provide the corresponding components of x-section.
C     WTSET(80) =   First order, beta0 contribution alone
C     WTSET(81) =   First order, beta1 contribution alone
C     WTSET(90) =   Second order, beta0 contribution alone
C     WTSET(91) =   Second order, beta1 contribution alone
C     WTSET(92) =   Second order, beta2 contribution alone
C furthermore, for the initial state alone we provide
C     WTSET( 1) =   zero-th order initial
C     WTSET( 2) =   first order   initial
C     WTSET( 3) =   second order  initial
C and the corresponding components
C     WTSET(20) =   First order, beta0 contribution alone
C     WTSET(21) =   First order, beta1 contribution alone
C     WTSET(30) =   Second order, beta0 contribution alone
C     WTSET(31) =   Second order, beta1 contribution alone
C     WTSET(32) =   Second order, beta2 contribution alone
C N.B. WTMOD=WTCRU1*WTCRU2*WTSET(71)
C     ************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER(PI=3.1415926535897932D0,ALFINV=137.03604D0)
      DIMENSION  XPAR( *),NPAR( *)
      COMMON / CGLIB / BLIBK(20000)
      SAVE   / CGLIB /
      COMMON / CMONIT/ AVERWT,ERRELA,NEVTOT,NEVACC,NEVNEG,NEVOVE,NEVZER
      COMMON / MOMSET / QF1(4),QF2(4),SPHUM(4),SPHOT(100,4),NPHOT
      COMMON / MOMINI / XF1(4),XF2(4),XPHUM(4),XPHOT(100,4),NPHOX
      COMMON / MOMFIN / YF1(4),YF2(4),YPHUM(4),YPHOT(100,4),NPHOY
      COMMON / WEKING / ENE,AMAZ,GAMMZ,AMEL,AMFIN,XK0,SINW2,IDE,IDF
      COMMON / WGTALL / WTMOD,WTCRU1,WTCRU2,WTSET(100)
      COMMON / KEYYFS / KEYZET,KEYBRM,KEYFIX,KEYRED,KEYWGT
      COMMON / INOUT  / NINP,NOUT
      COMMON / BXFMTS / BXOPE,BXCLO,BXTXT,BXL1I,BXL1F,BXL2F,BXL1G,BXL2G
      CHARACTER*80      BXOPE,BXCLO,BXTXT,BXL1I,BXL1F,BXL2F,BXL1G,BXL2G
      DIMENSION XXF(4)
      SAVE   / CMONIT /,/ MOMSET /,/ MOMINI /,/ MOMFIN /,/ WEKING /
      SAVE   / WGTALL /,/ KEYYFS /,/ INOUT  /,/ BXFMTS /
      SAVE   NEVGEN,KEYBIN,KEYBFI,CMSENE
      SAVE   IDYFS, WTMAX
      IF(MODE.EQ.-1) THEN
C     ==================================================================
C     =====================INITIALIZATION===============================
C     ==================================================================

 6900 FORMAT('1',10(/,10X,A))
      WRITE(NOUT,6900)
     $'  *************************************************************',
     $'  *  ****   ****  **********    *******          ***********  *',
     $'  *  ****   ****  **********  **********         **********   *',
     $'  *   **** ****   ****        *****                 ******    *',
     $'  *    ******     ********      ******    *****    ******     *',
     $'  *     ****      ********         *****  *****      ******   *',
     $'  *     ****      ****        **********         ***********  *',
     $'  *     ****      ****         *******           **********   *',
     $'  *************************************************************',
     $' '

* ==========================================================
* Initialization of internal histogramming package GLIBK
* Let us keep for YFS3 the GLIBK ID-ent range from 2 to 1000
* ==========================================================
      CALL GLIMIT(20000)
      CALL GOUTPU(NOUT)

      CALL FILEXP(XPAR,NPAR)
      IDYFS = 0
      CALL GBOOK1(IDYFS +5,'WT EXPAND  NPHOT.NE.0  $', 60 ,-1D0, 5D0)
      CALL GBOOK1(IDYFS +6,'WT EXPAND  NPHOT.NE.0  $', 60 ,-1D0, 0D0)
      CALL GBOOK1(IDYFS+11,'PHOTON MULTIPLICITY    $', 50,  0D0,50D0)
C GMONIT MONITORS WEIGHTS
      CALL GMONIT(-1,IDYFS+71,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+72,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+73,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+74,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+75,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+78,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+79,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+70,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+80,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+81,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+90,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+91,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+92,0D0,1D0,1D0)
      CMSENE = 2D0*ENE
      KEYBIN = MOD(KEYBRM,10)
      KEYBFI = MOD(KEYBRM,100)/10
      IF(KEYBIN.EQ.1) CALL KARLUD(-1,DUM1,DUM2)
      IF(KEYBFI.EQ.1) CALL KARFIN(-1, XXF,DUMM1,DUMM2)
      CALL  MODEL(-1,DUM1,DUM2)
      NEVGEN=0
      ELSEIF(MODE.EQ.0) THEN
C     ==================================================================
C     =====================GENERATION===================================
C     ==================================================================
      NEVGEN=NEVGEN+1
  100 CONTINUE
C ===================
C ...Initial state YFS2 type generator
         IF(KEYBIN.EQ.1) THEN
            CALL KARLUD( 0,WTKARL,DUM2)
         ELSE
            CALL GIBEA(CMSENE,AMFIN,XF1,XF2)
            WTKARL = 1D0
            NPHOX  = 0
         ENDIF
C ...Four-momentum of virtual Z
         DO 27 K=1,4
  27     XXF(K) = XF1(K)+XF2(K)
C ===================
C ...Final state momenta in the Z frame
         IF(KEYBFI.EQ.1) THEN
            CALL KARFIN(0, XXF,AMFIN,WTCFIN)
         ELSE
C ...No final state bremss, fermion momenta defined in Z frame
            CALL KINF2( XXF,AMFIN,YF1,YF2)
            WTCFIN = 1D0
            NPHOY  = 0
         ENDIF
C ...Merging momenta and transform to CMS frame
         CALL MERGIF
C =================== All kinematics is fixed at this point =======
         WTCRU1 = WTKARL
         WTCRU2 = WTCFIN
         WTCRUD = WTKARL*WTCFIN
C =================== All weights are fixed at this point =========
CCCC     IF(NEVGEN.LE.5) CALL DUMPI(NOUT)
CCCC     IF(NEVGEN.LE.5) CALL DUMPF(NOUT)
C ...Model weight
         CALL MODEL(0,WTMAX,WTMDL)
C ...principal model weight for WT=1 events (after rejection)
         WT     = WTCRUD*WTMDL
C ...Weigt monitoring
         CALL GMONIT(0,IDYFS+73,WTCRUD*WTSET(73),WTMAX,0D0)
         CALL GMONIT(0,IDYFS+72,WTCRUD*WTSET(72),WTMAX,0D0)
         CALL GMONIT(0,IDYFS+71,WTCRUD*WTSET(71),WTMAX,0D0)
         CALL GMONIT(0,IDYFS+75,WTCRUD*(WTSET(73)-WTSET(72)),WTMAX,0D0)
         CALL GMONIT(0,IDYFS+74,WTCRUD*(WTSET(72)-WTSET(71)),WTMAX,0D0)
         CALL GMONIT(0,IDYFS+80,WTCRUD*WTSET(80),WTMAX,0D0)
         CALL GMONIT(0,IDYFS+81,WTCRUD*WTSET(81),WTMAX,0D0)
         CALL GMONIT(0,IDYFS+90,WTCRUD*WTSET(90),WTMAX,0D0)
         CALL GMONIT(0,IDYFS+91,WTCRUD*WTSET(91),WTMAX,0D0)
         CALL GMONIT(0,IDYFS+92,WTCRUD*WTSET(92),WTMAX,0D0)
C ...test histograms
         XMULT=FLOAT(NPHOT)+.1D0
         CALL GF1(IDYFS+11,XMULT,1D0)
         IF(NPHOT.GE.0) CALL GF1(IDYFS+5,WT,1D0)
         IF(WT.LT.0.)   CALL GF1(IDYFS+6,WT,1D0)
C ...Rejection according to principal weight
         IF(KEYWGT.EQ.0) THEN
C ...unweihgted events with WT=1
            CALL VARRAN(RN,1)
            CALL GMONIT(0,IDYFS+79,WT ,WTMAX,RN)
            IF(WT.LT.0D0) THEN
              RWT=-WT
            ELSEIF(WT.LT.WTMAX) THEN
              RWT=0.0
            ELSE
              RWT=WT-WTMAX
            ENDIF
            CALL GMONIT(0,IDYFS+70,RWT ,WTMAX,RN)
            IF(RN.GT.WT/WTMAX) GOTO 100
            WTMOD=1.D0
C ...WTCRU1,2  weights are RESET to one
            WTCRU1=1D0
            WTCRU2=1D0
         ELSE
C ...weighted events
            WTMOD  = WTCRUD*WTMDL
            CALL GMONIT(0,IDYFS+79,WT     ,WTMAX,0D0)
            CALL GMONIT(0,IDYFS+78,WTCRUD ,WTMAX,0D0)
         ENDIF
      ELSEIF(MODE.EQ.1.OR.MODE.EQ.2) THEN
C     ==================================================================
C     =====================FINAL WEIGHT ANALYSIS========================
C     ==================================================================
      GNANOB=389.385D-30*1.D33
      SIG0NB =  4D0*PI/(ALFINV**2*3D0*CMSENE**2)*GNANOB
      XBORNB =  BORNY(CMSENE**2)*SIG0NB
      IF(KEYBIN.EQ.1) THEN
         CALL KARLUD(MODE,XKARL,ERKARL)
      ELSE
         XKARL  = BORNY(CMSENE**2)
         ERKARL = 0D0
      ENDIF
      IF(KEYBFI.EQ.1) CALL KARFIN(MODE,XXF,DUMM1,DUMM2)
C
      CALL GMONIT(1,IDYFS+79,DUMM1,DUMM2,DUMM3)
      NPAR(10)= NEVGEN
      XSMC   =  XKARL*AVERWT
      EREL   =  SQRT(ERKARL**2+ERRELA**2)
      ERABS  =  XSMC*EREL
      XSMCNB =  XSMC*SIG0NB
      ERABS2 =  XSMCNB*EREL
      XPAR(10)= XSMCNB
      XPAR(11)= EREL
      XPAR(12)= XSMC
      IF(KEYWGT.EQ.0) THEN
C ...Weighted events, normal option
         XPAR(20)=XSMCNB
         XPAR(21)=EREL
         XPAR(22)=XSMC
      ELSE
C ...Weighted events, additional information on x-sections
         CALL GMONIT(1,IDYFS+78,DUMM1,DUMM2,DUMM3)
         XPAR(20)= XKARL*SIG0NB
         XPAR(21)= ERRELA
         XPAR(22)= XKARL
      ENDIF
C NO PRINTOUT FOR MODE =1
      IF(MODE.EQ.1) RETURN
cc    CALL GPRINT(IDYFS+11)
      CALL GPRINT(IDYFS+ 5)
      CALL GPRINT(IDYFS+ 6)
      WRITE(NOUT,BXOPE)
      WRITE(NOUT,BXTXT) 'EXPAND output - window A'
      WRITE(NOUT,BXL1F) CMSENE,     'CMS energy total   ','CMSENE','A0'
      WRITE(NOUT,BXL2F) XSMC,ERABS, 'xs_tot MC R-units  ','XSMC  ','A1'
      WRITE(NOUT,BXL1F) XSMCNB,     'xs_tot    nanob.   ','XSMCNB','A3'
      WRITE(NOUT,BXL1F) ERABS2,     'absolute error     ','ERABS2','A4'
      WRITE(NOUT,BXL1F) EREL,       'relative error     ','EREL  ','A5'
      WRITE(NOUT,BXL1I) NEVTOT,     'total no of events ','NEVTOT','A6'
      WRITE(NOUT,BXL1I) NEVACC,     'accepted    events ','NEVACC','A7'
      WRITE(NOUT,BXL1I) NEVNEG,     'WT<0        events ','NEVNEG','A8'
      WRITE(NOUT,BXL1I) NEVOVE,     'WT>WTMAX    events ','NEVOVE','A9'
      WRITE(NOUT,BXL1F) WTMAX ,     'WTMAX              ','WTMAX ','A10'
      WRITE(NOUT,BXL1F) XBORNB,     'xs_Born   nanob.   ','XBORNB','A11'
      WRITE(NOUT,BXCLO)
      IF ( (NEVNEG+NEVOVE) .GT. NEVACC/4000) THEN
        WRITE(NOUT,BXOPE)
        WRITE(NOUT,BXTXT) ' possible loss of precision !!!!!! '
        WRITE(NOUT,BXTXT) ' VVMAX too close to 1D0 ? '
        WRITE(NOUT,BXTXT) ' reduce VVMAX in KORALZ parameters!'
        WRITE(NOUT,BXTXT) ' it will faster program also !'
        WRITE(NOUT,BXTXT) ' WTMAX too small ?                 '
        WRITE(NOUT,BXTXT) ' Increase it in SUBROURTINE MODEL! '
        WRITE(NOUT,BXTXT) ' MANY events of negative weights?  '
        WRITE(NOUT,BXTXT) ' Contact JADACH at CERNVM,         '
        WRITE(NOUT,BXTXT) ' But check folowing weights first  '
        WRITE(NOUT,BXCLO)
        WRITE(NOUT,BXOPE)
        WRITE(NOUT,BXTXT) ' Rejection weight of YFS3               '
        WRITE(NOUT,BXCLO)
         CALL GMONIT(2,IDYFS+79,DUMM1,DUMM2,DUMM3)
        WRITE(NOUT,BXOPE)
        WRITE(NOUT,BXTXT) ' contribution of over and underflows    '
        WRITE(NOUT,BXCLO)
         CALL GMONIT(2,IDYFS+70,DUMM1,DUMM2,DUMM3)
        WRITE(NOUT,BXOPE)
        WRITE(NOUT,BXTXT) ' ratio averwt(id=70)/averwt(id=79)      '
        WRITE(NOUT,BXTXT) ' measures severity of error             '
        WRITE(NOUT,BXCLO)
      ENDIF
C     ==================================================================
C     =============SUPPL. FINAL WEIGHT ANALYSIS=========================
C     ==================================================================
      WRITE(NOUT,BXOPE)
      WRITE(NOUT,BXTXT) '        EXPAND output - window B '
      WRITE(NOUT,BXTXT) '           X-sections in R-units '
      CALL GMONIT(1,IDYFS+73,DUMM1,DUMM2,DUMM3)
      XS03   =  XKARL*AVERWT
      DXS03  =  XKARL*AVERWT*SQRT(ERKARL**2+ERRELA**2)
      CALL GMONIT(1,IDYFS+72,DUMM1,DUMM2,DUMM3)
      XS02   =  XKARL*AVERWT
      DXS02  =  XKARL*AVERWT*SQRT(ERKARL**2+ERRELA**2)
      CALL GMONIT(1,IDYFS+71,DUMM1,DUMM2,DUMM3)
      XS01   =  XKARL*AVERWT
      DXS01  =  XKARL*AVERWT*SQRT(ERKARL**2+ERRELA**2)
      CALL GMONIT(1,IDYFS+75,DUMM1,DUMM2,DUMM3)
      XS05   =  XKARL*AVERWT
      DXS05  =  XKARL*AVERWT*SQRT(ERKARL**2+ERRELA**2)
      CALL GMONIT(1,IDYFS+74,DUMM1,DUMM2,DUMM3)
      XS04   =  XKARL*AVERWT
      DXS04  =  XKARL*AVERWT*SQRT(ERKARL**2+ERRELA**2)
      WRITE(NOUT,BXL2F) XS03,DXS03,'X-section','O(alf2)',  'B1'
      WRITE(NOUT,BXL2F) XS02,DXS02,'X-section','O(alf1)',  'B2'
      WRITE(NOUT,BXL2F) XS01,DXS01,'X-section','O(alf0)',  'B3'
      IF(XS02.NE.0D0) WRITE(NOUT,BXL2F)
     $ XS05/XS02,DXS05/XS02,'(O(alf2)-O(alf1))','/O(alf1)','B4'
      IF(XS01.NE.0D0) WRITE(NOUT,BXL2F)
     $ XS04/XS01,DXS04/XS01,'(O(alf1)-O(alf0))','/O(alf0)','B5'
      WRITE(NOUT,BXCLO)
C -------------
      WTCRU1 = XKARL
      WTCRU2 = ERKARL
      CALL  MODEL(MODE,DUMM1,DUMM2)
C -------------
      ELSE
C     ====
      WRITE(NOUT,*) '===>EXPAND: WRONG MODE'
      STOP
      ENDIF
C     =====
      END
      SUBROUTINE MERGIF
C     *****************
C Merging two commons all photons together
C Transformation to common (CMS) trame is supposed to be already done
C     ************************************
      IMPLICIT DOUBLE PRECISION  (A-H,O-Z)
      COMMON / MOMSET / QF1(4),QF2(4),SPHUM(4),SPHOT(100,4),NPHOT
      COMMON / MOMINI / XF1(4),XF2(4),XPHUM(4),XPHOT(100,4),NPHOX
      COMMON / MOMFIN / YF1(4),YF2(4),YPHUM(4),YPHOT(100,4),NPHOY
C ...Photons
      NPHOT  = 0
      DO 130 I=1,NPHOX
        NPHOT  =NPHOT+1
        DO 130 K=1,4
  130   SPHOT(NPHOT,K)=XPHOT(I,K)
      DO 140 I=1,NPHOY
        NPHOT  =NPHOT+1
        DO 140 K=1,4
  140   SPHOT(NPHOT,K)=YPHOT(I,K)
C ...Final state fermions
      DO 145 K=1,4
        QF1(K)= YF1(K)
  145   QF2(K)= YF2(K)
C ...Axiliary
      DO 150 K=1,4
  150    SPHUM(K)= XPHUM(K)+YPHUM(K)
      END
      SUBROUTINE FILEXP(XPAR,NPAR)
C     ***********************************
C TRANSFERS AND DEFINES INPUT PARAMS, PRINTS INPUT PARAMETERS
      IMPLICIT DOUBLE PRECISION  (A-H,O-Z)
      DIMENSION  XPAR( *),NPAR( *)
      COMMON / WEKING / ENE,AMAZ,GAMMZ,AMEL,AMFIN,XK0,SINW2,IDE,IDF
      COMMON / KEYYFS / KEYZET,KEYBRM,KEYFIX,KEYRED,KEYWGT
      COMMON / SPISET / POLAR1,POLAR2,POLFI1,POLFI2
      COMMON / UUREC  / UU,EPS,DELTA
      COMMON / VVREC  / VVMIN,VVMAX,VV,BETI
      COMMON / INOUT  / NINP,NOUT
      COMMON / BXFMTS / BXOPE,BXCLO,BXTXT,BXL1I,BXL1F,BXL2F,BXL1G,BXL2G
      CHARACTER*80      BXOPE,BXCLO,BXTXT,BXL1I,BXL1F,BXL2F,BXL1G,BXL2G
      COMMON / RANPAR / KEYRND
      SAVE / WEKING /,/ KEYYFS /,/ SPISET /,/ UUREC  /,/ VVREC  /
      SAVE / INOUT  /,/ BXFMTS /,/ RANPAR /

C ...BX-formats for nice and flexible outbuts
      BXOPE =  '(//1X,15(5H*****)    )'
      BXTXT =  '(1X,1H*,                  A48,25X,    1H*)'
      BXL1I =  '(1X,1H*,I17,                 16X, A20,A12,A7, 1X,1H*)'
      BXL1F =  '(1X,1H*,F17.8,               16X, A20,A12,A7, 1X,1H*)'
      BXL2F =  '(1X,1H*,F17.8, 4H  +-, F11.8, 1X, A20,A12,A7, 1X,1H*)'
      BXL1G =  '(1X,1H*,G17.8,               16X, A20,A12,A7, 1X,1H*)'
      BXL2G =  '(1X,1H*,G17.8, 4H  +-, F11.8, 1X, A20,A12,A7, 1X,1H*)'
      BXCLO =  '(1X,15(5H*****)/   )'

C  type of the RANDOM NUMBER GENERATOR RANMAR
      KEYRND = 1
C----------
      KEYBRM= ABS(NPAR(1))
      KEYFIX= 0
      IF(NPAR(1).LT.0) KEYFIX=1
      KEYRED= NPAR(2)
      KEYWGT= NPAR(3)
      KEYZET= NPAR(4)
      CMSENE = XPAR(1)
      AMAZ   = XPAR(2)
      SINW2  = XPAR(3)
      GAMMZ  = XPAR(4)
      AMFIN  = XPAR(5)
      VVMIN  = XPAR(6)
      VVMAX  = XPAR(7)
      ENE    = CMSENE/2D0
      VVMAX  = MIN(VVMAX,1D0-(AMFIN/ENE)**2)
      EPS    = VVMIN
      DELTA  = EPS*1D-3
      POLAR1 = 0D0
      POLAR2 = 0D0
      POLFI1 = 0D0
      POLFI2 = 0D0
      AMEL   = 0.5111D-3
      IDE=2
      IDF=2
      XK0=3.D-3
C
      WRITE(NOUT,BXOPE)
      WRITE(NOUT,BXTXT) '    YFS VERSION 3.30   FEBR.  93        '
      WRITE(NOUT,BXL1F) CMSENE,     'CMS energy total   ','CMSENE','A0'
      WRITE(NOUT,BXL1I) KEYBRM,     'general QED switch ','KEYBRM','A1'
      WRITE(NOUT,BXL1F) AMFIN,      'final fermionmass  ','AMFIN ','A2'
      WRITE(NOUT,BXL1F) AMAZ,       'Z mass   [GeV]     ','AMAZ  ','A3'
      WRITE(NOUT,BXL1F) GAMMZ,      'Z width  [GeV]     ','GAMMZ ','A4'
      WRITE(NOUT,BXL1F) SINW2,      'sin(theta_W)**2    ','SINW2 ','A5'
      WRITE(NOUT,BXL1F) VVMIN,      'dummy infrared cut ','VVMIN ','A6'
      WRITE(NOUT,BXL1F) VVMAX,      'v_max ( =1 )       ','VVMAX ','A7'
      WRITE(NOUT,BXL1I) KEYRED,     'reduction  switch  ','KEYRED','A8'
      WRITE(NOUT,BXL1I) KEYWGT,     'weighting  switch  ','KEYWGT','A9'
      WRITE(NOUT,BXL1I) KEYZET,     'elect_weak switch  ','KEYZET','A10'
      WRITE(NOUT,BXCLO)
      END
      SUBROUTINE KARLUD(MODE,PAR1,PAR2)
C     *********************************
C LOW LEVEL  MONTE-CARLO GENERATOR
C ADMINISTRATES DIRECTLY GENERATION OF V-VARIABLE
C AND INDIRECTLY OF ALL OTHER VARIABLES.
C     ************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER (PI=3.1415926535897932D0,ALFINV= 137.03604D0)
      PARAMETER (CEULER =0.57721566D0)
      PARAMETER (NMAX= 40)
      COMMON / WEKING / ENE,AMAZ,GAMMZ,AMEL,AMFIN,XK0,SINW2,IDE,IDF
      COMMON / KEYYFS / KEYZET,KEYBRM,KEYFIX,KEYRED,KEYWGT
C COMMUNICATES WITH VESKO/RHOSKO
      COMMON / VVREC  / VVMIN,VVMAX,VV,BETI
      COMMON / INOUT  / NINP,NOUT
C COMMUNICATES WITH GMONIT
      COMMON / CMONIT/ AVERWT,ERRELA,NEVTOT,NEVACC,NEVNEG,NEVOVE,NEVZER
      COMMON / BXFMTS / BXOPE,BXCLO,BXTXT,BXL1I,BXL1F,BXL2F,BXL1G,BXL2G
      CHARACTER*80      BXOPE,BXCLO,BXTXT,BXL1I,BXL1F,BXL2F,BXL1G,BXL2G
      SAVE / WEKING /,/ KEYYFS /,/ VVREC  /,/ INOUT  /
      SAVE / CMONIT /,/ BXFMTS /
      SAVE SVAR,BETI2,GAMFAP,GAMFAC,GAMFA2,PREC,XCGAUS,XDEL,XCVESK
      SAVE IDYFS
      EXTERNAL RHOSKO
C MAXIMUM PHOTON MULTIPLICITY
C
      IF(MODE.EQ.-1) THEN
C     ==================================================================
C     ===================INITIALIZATION=================================
C     ==================================================================
      WRITE(NOUT,BXOPE)
      WRITE(NOUT,BXTXT) 'Initialize KARLUD  start'
      SVAR = 4D0*ENE**2
      BETI = 2D0/ALFINV/PI*(DLOG(4D0*ENE**2/AMEL**2)-1D0)
      BETI2= 2D0/ALFINV/PI* DLOG(4D0*ENE**2/AMEL**2)
      GAMFAP =1D0-PI**2*BETI**2/12D0
      GAMFAC =EXP(-CEULER*BETI)/DPGAMM(1D0+BETI)
      GAMFA2 =EXP(-CEULER*BETI2)/DPGAMM(1D0+BETI2)
      IDYFS = 0
      CALL GBOOK1(IDYFS+ 7,'WT IN KARLUD         $', 50 , 0D0,5D0)
      CALL GMONIT(-1,IDYFS+51,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+52,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+53,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+54,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+55,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+56,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+59,0D0,1D0,1D0)
      CALL VESK1W(-1,RHOSKO,XCVESK,DUM1,DUM2)
      PREC = 1D-6
      XCGAUS =BREMKF(1,PREC)
      XDEL = XCVESK/XCGAUS-1
      WRITE(NOUT,BXL1F) XCVESK,     'xs_crude  VESKO    ','XCVESK','  '
      WRITE(NOUT,BXL1F) XCGAUS,     'xs_crude  GAUSS    ','XCGAUS','  '
      WRITE(NOUT,BXL1F) XDEL       ,'XCVESK/XCGAUS-1    ','      ','  '
      WRITE(NOUT,BXTXT) 'Initialize KARLUD  end  '
      WRITE(NOUT,BXCLO)
      ELSEIF(MODE.EQ.0) THEN
C     ==================================================================
C     ====================GENERATION====================================
C     ==================================================================
   30 CONTINUE
C GENERATE VV
      IF(KEYFIX.EQ.0) THEN
        CALL VESK1W( 0,RHOSKO,DUM1,DUM2,WTVES)
      ELSE
        WTVES=1D0
        VV=VVMAX
      ENDIF
C LOW-LEVEL MULTIPHOTON GENERATOR
      CALL YFSGEN(VV,VVMIN,NMAX,WT1,WT2,WT3)
C--------------TESTS ON INTERNAL WEIGHTS
C--------------DOES NOT INTERFERE WITH THE EVENT GENERATION !!!
      REF  = VVRHO(50,SVAR,AMEL,VV,VVMIN)
      WTR  = REF/VVRHO(1,SVAR,AMEL,VV,VVMIN)
      CALL VARRAN(RN,1)
      CALL GMONIT(0,IDYFS+56,WTR,1D0,RN)
C PSEUDOREJECTION IN ORDER TO INTRODUCE REFERENCE XSECTION
      IF(KEYFIX.EQ.0 .AND. RN.GT.WTR) GOTO 110
      WF1  = WT1*VVRHO(51,SVAR,AMEL,VV,VVMIN)/REF
      WF2  = WT2*VVRHO(52,SVAR,AMEL,VV,VVMIN)/REF
      WF3  = WT3
      WF13 = WF1*WF3
      WF123= WF1*WF2*WF3
      CALL GMONIT(0,IDYFS+51,WF1,  1D0,1D0)
      CALL GMONIT(0,IDYFS+52,WF2,  1D0,1D0)
      CALL GMONIT(0,IDYFS+53,WF3,  1D0,1D0)
      CALL GMONIT(0,IDYFS+54,WF13, 1D0,1D0)
      CALL GMONIT(0,IDYFS+55,WF123,1D0,1D0)
  110 CONTINUE
C--------------
      WT=WTVES*WT1*WT2*WT3
      WTKARL=WT
      CALL GMONIT(0,IDYFS+59,WT,  1D0,1D0)
      CALL GF1(IDYFS+ 7,WT,1D0)
      PAR1=WT
      ELSE
C     ==================================================================
C     ====================FINAL WEIGHT ANALYSIS=========================
C     ==================================================================
      CALL GPRINT(IDYFS+ 7)
      CALL GMONIT(1,IDYFS+59,DUMM1,DUMM2,DUMM3)
      WTKARL = AVERWT
      ERKRL  = ERRELA
      PREC   = 1D-6
      XSGS   = BREMKF(1,PREC)
      ERGS   = XSGS*PREC
      CALL VESK1W( 1,RHOSKO,XSVE,ERELVE,XCVESK)
      ERVE   = XSVE*ERELVE
      IF(KEYFIX.EQ.1)  XCVESK=XCGAUS
C Note that since VESK1W produces weighted events we are sending
C up the crude x-section (from VESK1W) to the calling program
      PAR1   = XCVESK
      PAR2   = 0D0
C NO PRINTOUT FOR MODE = 2
      IF(MODE.EQ.1) RETURN
      DDV    = XSVE/XSGS-1D0
      DDR    = ERELVE + 1D-6
      XSKR   = XCVESK*WTKARL
      ERKR   = XSKR*ERKRL
      WRITE(NOUT,BXOPE)
      WRITE(NOUT,BXTXT) '     KARLUD  FINAL  REPORT     '
      WRITE(NOUT,BXTXT) '         window A              '
      WRITE(NOUT,BXL1I) NEVTOT,     'total no of events ','NEVTOT','A0'
      WRITE(NOUT,BXL1I) NEVNEG,     'WT<0        events ','NEVNEG','A1'
      WRITE(NOUT,BXL1F) XCVESK,     'xs_cru VESKO  [R]  ','XCVESK','A2'
      WRITE(NOUT,BXL2F) XSVE,ERVE,  'xs_est VESKO  [R]  ','XSVE  ','A3'
      WRITE(NOUT,BXL2F) XSGS,ERGS,  'xs_est Gauss  [R]  ','XSGS  ','A4'
      WRITE(NOUT,BXL2F) DDV,DDR,    'XCVE/XCGS-1        ','      ','A5'
      WRITE(NOUT,BXL2F) WTKARL,ERKRL,'   <WT>           ','WTKARL','A6'
      WRITE(NOUT,BXL2F) XSKR,ERKR,  'sigma_prim    [R]  ','XSKARL','A7'
      WRITE(NOUT,BXCLO)
C     ==================================================================
C     =============SUPPL. FINAL WEIGHT ANALYSIS=========================
C     ==================================================================
      CALL GMONIT(1,IDYFS+51,DUMM1,DUMM2,DUMM3)
      DEL1   = AVERWT-1D0
      DWT1   = ERRELA
      CALL GMONIT(1,IDYFS+52,DUMM1,DUMM2,DUMM3)
      AWF2   = AVERWT
      DWT2   = ERRELA
      CALL GMONIT(1,IDYFS+53,DUMM1,DUMM2,DUMM3)
      AWF3   = AVERWT
      DEL3   = AVERWT-GAMFA2
      DWT3   = ERRELA
      CALL GMONIT(1,IDYFS+54,DUMM1,DUMM2,DUMM3)
      AWF4   = AVERWT
      DEL4   = AVERWT-GAMFAC
      DWT4   = ERRELA
      WRITE(NOUT,BXOPE)
      WRITE(NOUT,BXTXT) '     KARLUD  FINAL  REPORT     '
      WRITE(NOUT,BXTXT) '         window B              '
      WRITE(NOUT,BXL2F) DEL1,DWT1,  '<WF1>-1  mass wt   ','DEL1  ','B1'
      WRITE(NOUT,BXL2F) AWF2,DWT2,  '<WF2> dilat. weight','AWF2  ','B2'
      WRITE(NOUT,BXL2F) AWF3,DWT3,  '<WF3> dilat. weight','AWF3  ','B3'
      WRITE(NOUT,BXL2F) DEL3,DWT3,  '<WF3>-YGF(BETI2)   ','DEL3  ','B4'
      WRITE(NOUT,BXL2F) AWF4,DWT4,  '<WF1*WF3>          ','AWF4  ','B5'
      WRITE(NOUT,BXL2F) DEL4,DWT4,  '<WF1*WF3>-YGF(BETI)','DEL4  ','B6'
      WRITE(NOUT,BXCLO)
C     ==================================================================
      CALL GMONIT(1,IDYFS+55,DUMM1,DUMM2,DUMM3)
      AWF5   = AVERWT
      DEL5   = AVERWT-GAMFAC
      DWT5   = ERRELA
      CALL GMONIT(1,IDYFS+56,DUMM1,DUMM2,DUMM3)
      AWF6   = AVERWT
      PREC = 1D-6
      XREFER = BREMKF(50,PREC)
      DELKAR = XREFER*AWF5/XSKR  -1D0
      DELREF = XCVESK*AWF6/XREFER-1D0
      WRITE(NOUT,BXOPE)
      WRITE(NOUT,BXTXT) '     KARLUD  FINAL  REPORT CONT.   '
      WRITE(NOUT,BXTXT) '         WINDOW C                  '
      WRITE(NOUT,BXTXT) 'BETI= 2*ALFA/PI*(LOG(S/MEL**2)-1)       '
      WRITE(NOUT,BXTXT) 'GAMFAP= 1-PI**2*BETI**2/12              '
      WRITE(NOUT,BXTXT) 'GAMFAC=EXP(-CEULER*BETI)/GAMMA(1+BETI)  '
      WRITE(NOUT,BXTXT) 'GAMFA2=EXP(-CEULER*BETI2)/GAMMA(1+BETI2)'
      WRITE(NOUT,BXL1F)  BETI,        '                =','BETI  ','C1'
      WRITE(NOUT,BXL1F)  GAMFAP,      '                =','GAMFAP','C2'
      WRITE(NOUT,BXL1F)  GAMFAC,      '                =','GAMFAC','C3'
      WRITE(NOUT,BXL1F)  GAMFA2,      '                =','GAMFA2','C4'
      WRITE(NOUT,BXL2F) AWF5,DWT5, ' <WF1*WF3*WF4>      ','AWF5  ','C5'
      WRITE(NOUT,BXL2F) DEL5,DWT5, ' <WF1*WF3>-YGF(BETI)','DEL5  ','C6'
      WRITE(NOUT,BXTXT) 'DELKAR=XREFER*AVER(WF1*WF1*WF3)/XSKARL-1'
      WRITE(NOUT,BXTXT) 'DELREF=XCRUDE*AVER(WTR)/XREFER-1        '
      WRITE(NOUT,BXL1F) XREFER,    'reference x_sect.   ','XREFER','C7'
      WRITE(NOUT,BXL1F) DELKAR,    'XREFER*AWF5/XSKR  -1','DELKAR','C8'
      WRITE(NOUT,BXL1F) DELREF,    'XCVESK*AWF6/XREFER-1','DELREF','C9'
      WRITE(NOUT,BXCLO)
      ENDIF
C     =====
      END
      FUNCTION RHOSKO(R)
C     ********************
C CALLED IN VESK1W
C PROVIDES V OR K DISTRIBUTION TO BE GENERATED
C     ********************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER (FLEPS = 1D-35)
      COMMON / WEKING / ENE,AMAZ,GAMMZ,AMEL,AMFIN,XK0,SINW2,IDE,IDF
      COMMON / KEYYFS / KEYZET,KEYBRM,KEYFIX,KEYRED,KEYWGT
      COMMON / VVREC  / VVMIN,VVMAX,VV,BETI
C MAPPING  R => VV CHANGE  TO IMPROVE ON EFFICIENCY
C Note that the replacement below makes program more precise
C and bulet-proof with respect numerical instabilities close to VV=0
      X = MAX(R,FLEPS**BETI)
      BBT = -0.5D0
      CALL CHBIN1(X,BETI,BBT,VVMAX,VV,RJAC)
C BORN XSECTION
C NOTE 1/(1-VV) FACTOR BECAUSE BORNY IS IN R-UNITS
      SVAR   = 4D0*ENE**2
      SVAR1  = SVAR*(1D0-VV)
      XBORN  = BORNY(SVAR1)/(1D0-VV)
C constant x-section for tests
      IF(KEYZET.EQ.-2) XBORN = XBORN * (1D0-VV)
      RHOSKO = RJAC*XBORN* VVRHO(1,SVAR,AMEL,VV,VVMIN)
      END

      SUBROUTINE YFSGEN(VV,VMIN,NMAX,WT1,WT2,WT3)
C     *******************************************
C======================================================================
C================== Y F S G E N =======================================
C======================================================================
C*********INPUT
C VV    = V VARIABLE
C VMIN  = MINIMUM V VARIABLE (INFRARED CUTOFF)
C NMAX  = MAXIMUM PHOTON MULTIPLICITY
C*********OUTPUT
C WT1  = WEIGHT DUE TO NEGLECTED MASS TERMS
C WT2  = WEIGHT DUE TO DILATATION OF PHOTON MOMENTA
C WT3  = ANOTHER DILATATION WEIGHT
C OTHER OUTPUT RESULTS IN /MOMINI/
C*****************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER( PI=3.1415926535897932D0,ALFINV= 137.03604D0)
      COMMON / WEKING / ENE,AMAZ,GAMMZ,AMEL,AMFIN,XK0,SINW2,IDE,IDF
      COMMON / MOMINI / QF1(4),QF2(4),SPHUM(4),SPHOT(100,4),NPHOT
      COMMON / KEYYFS / KEYZET,KEYBRM,KEYFIX,KEYRED,KEYWGT
      SAVE / WEKING /,/ MOMINI /,/ KEYYFS /
      DIMENSION XPH(100),RR(100)
C
C HERE BETI2 MUST BE USED INSTEAD OF BETI (MASS TERM NEGLECTED)
      BETI2 = 2D0/ALFINV/PI*DLOG(4D0*ENE**2/AMEL**2)
      AM2=(AMEL/ENE)**2
      DO 10 I=1,NMAX
      XPH(I)=0D0
      DO 10 J=1,4
   10 SPHOT(I,J)=0D0
      IF(VV.LE.VMIN) THEN
C NO PHOTON ABOVE DETECTABILITY THRESHOLD
         WT1=1D0
         WT2=1D0
         WT3=1D0
         NPHOT=0
      ELSE
C ONE OR MORE PHOTONS, GENERATE PHOTON MULTIPLICITY
C NPHOT = POISSON(WITH AVERAGE = AVERG) + 1
         AVERG=BETI2*DLOG(VV/VMIN)
  100    CALL POISSG(AVERG,NMAX,MULTP,RR)
         NPHOT = MULTP+1
C This is for tests of program at fixed multiplicity (for adv. users)
         NPHFIX =  MOD(KEYBRM,10000)/1000
         IF(NPHFIX.NE.0.AND.NPHOT.NE.NPHFIX) GOTO 100
         IF(NPHOT.EQ.1) THEN
            XPH(1)=VV
            CALL BREMUL(XPH,AM2,WT1)
            DJAC0=(1D0+1D0/SQRT(1D0-VV))/2D0
            WT2  = 1D0/DJAC0
            WT3  = 1D0
         ELSE
            XPH(1)=VV
            DO 200 I=2,NPHOT
  200       XPH(I)=VV*(VMIN/VV)**RR(I-1)
            CALL BREMUL(XPH,AM2,WT1)
            CALL RESOLH(VV,EXPY,DJAC)
            DJAC0=(1D0+1D0/SQRT(1D0-VV))/2D0
            WT2  = DJAC/DJAC0
            WT3  = 1D0
C SCALE DOWN PHOTON ENERGIES AND MOMENTA
            DO 300 I=1,NPHOT
            DO 300 K=1,4
  300       SPHOT(I,K)=SPHOT(I,K)/EXPY
C CHECK ON LOWER ENERGY CUT-OFF
            IF(SPHOT(NPHOT,4).LT.VMIN) WT3 =0D0
         ENDIF
      ENDIF
C PHOTON MOMENTA IN GEV UNITS
      DO 420 J=1,4
  420 SPHUM(J)=0D0
      DO 480 I=1,NPHOT
      DO 480 J=1,4
      SPHOT(I,J)=SPHOT(I,J)*ENE
  480 SPHUM(J)=SPHUM(J)+SPHOT(I,J)
C DEFINE FERMION MOMENTA
      CALL KINEKR
      END
      SUBROUTINE RESOLH(VV,EXPY,DJAC)
C     *******************************
C THIS SOLVES CONSTRAINT EQUATION ON PHOTON MOMENTA
C ALSO CALCULATES CORRESPONDING JACOBIAN FACTOR
C INPUT:  VV    = COSTRAINT PARAMETER V
C OUTPUT  EXPY  = RESCALING FACTOR - A SOLUTION OF THE EQUATION
C         DJAC  = JACOBIAN FACTOR
C     ************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION PP(4),PK(4)
      COMMON / MOMINI / QF1(4),QF2(4),SPHUM(4),SPHOT(100,4),NPHOT
      SAVE   / MOMINI /
C
      DO 210 K=1,4
      PK(K)=0D0
  210 PP(K)=0D0
      PP(4)=2D0
      DO 215 I=1,NPHOT
      DO 215 K=1,4
  215 PK(K)=PK(K)+SPHOT(I,K)
      PPDPP=PP(4)**2-PP(3)**2-PP(2)**2-PP(1)**2
      PKDPK=PK(4)**2-PK(3)**2-PK(2)**2-PK(1)**2
      PPDPK=PP(4)*PK(4)-PP(3)*PK(3)-PP(2)*PK(2)-PP(1)*PK(1)
      AA=PPDPP*PKDPK/(PPDPK)**2
      EXPY=2D0*PPDPK/PPDPP/VV
C SOLUTION FOR CONSTRAINT ON PHOTON FOUR MOMENTA
      EXPY=EXPY*.5D0*(1D0+SQRT(1D0-VV*AA))
C JACOBIAN FACTOR
      DJAC=(1D0+1D0/SQRT(1D0-VV*AA))/2D0
      END
      SUBROUTINE BREMUL(XPH,AM2,WT)
C     *****************************
C PROVIDES PHOTON FOURMOMENTA
C INPUT  : XPH    = LIST OF PHOTON ENERGIES
C OUTPUT : SPHOT  = LIST OF PHPTON FOUR-MOMENTA
C          WT     = WEIGHT DUE TO MASS TERMS
C     ************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER( PI =3.1415926535897932D0)
      COMMON / MOMINI / QF1(4),QF2(4),SPHUM(4),SPHOT(100,4),NPHOT
      SAVE   / MOMINI /
      DIMENSION XPH(*)

      WT=1D0
      DO 100 I=1,NPHOT
      XK=XPH(I)
      CALL VARRAN(RN,1)
      CALL ANGBRE(RN,AM2,CG,SG,DIST0,DIST1)
      WTM   =DIST1/DIST0
      WT    =WT*WTM
      CALL VARRAN(RNUMB,1)
      PHI=2D0*PI*RNUMB
      SPHOT(I,1)=XK*SG*COS(PHI)
      SPHOT(I,2)=XK*SG*SIN(PHI)
      SPHOT(I,3)=XK*CG
      SPHOT(I,4)=XK
  100 CONTINUE
      END
      SUBROUTINE KINEKR
C     *****************
C CALLED IN YFSGEN
C DEFINES FINAL STATE FERMION FOUR MOMENTA
C     ************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER( PI =3.1415926535897932D0)
      COMMON / WEKING / ENE,AMAZ,GAMMZ,AMEL,AMFIN,XK0,SINW2,IDE,IDF
      COMMON / MOMINI / QF1(4),QF2(4),SPHUM(4),SPHOT(100,4),NPHOT
      SAVE   / WEKING /,/ MOMINI /
      DIMENSION QSU(4),DRVEC(10)
C
C QSU IS FOURMOMENTUM OF FINAL STATE FERMION PAIR
      DO 10 K=1,4
   10 QSU(K)=-SPHUM(K)
      QSU(4)=QSU(4)+2D0*ENE
      QSM =SQRT(QSU(4)**2-QSU(3)**2-QSU(2)**2-QSU(1)**2)
C GENERATE MOMENTA OF FERMIONS IN THEIR REST FRAME WITH FLAT DISTR.
      QF1(4)=QSM/2D0
      QF2(4)=QSM/2D0
      QMD=SQRT(QF1(4)**2-AMFIN**2)
      CALL VARRAN(DRVEC,2)
      R1 = DRVEC(1)
      R2 = DRVEC(2)
      COSTH=-1D0+2D0*R1
      SINTH=SQRT(1D0-COSTH**2)
      QF1(1)=QMD*SINTH*COS(2D0*PI*R2)
      QF1(2)=QMD*SINTH*SIN(2D0*PI*R2)
      QF1(3)=QMD*COSTH
      DO 30 K=1,3
   30 QF2(K)=-QF1(K)
C TRANSFORM BACK TO CMS
      IF(NPHOT.GE.1) THEN
        CALL BOSTDQ(-1,QSU,QF1,QF1)
        CALL BOSTDQ(-1,QSU,QF2,QF2)
      ENDIF
C======================================================================
C==================END OF YFSGEN=======================================
C======================================================================
      END
      SUBROUTINE KARFIN(MODE, XXF,AMFIN,WT)
C     ***************************************
C ======================================================================
C ... Low level Monte Carlo for final state multibremsstrahlung
C ======================================================================
C Input:
C         XXF    = CMS four momentum of the entire final state
C  system i.e. fermions + photons
C         AMFIN  = mass of final state fermion
C Hidden input:  EPS, DELTA in /VVREC/, formats in /BXFMTS/
C Output:
C            WT  = crude MC weight
C         Momenta in /MOMFIN/
C     ***********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION XXF(4)
      COMMON / MOMFIN / QF1(4),QF2(4),SPHUM(4),SPHOT(100,4),NPHOT
      COMMON / UUREC  / UU,EPS,DELTA
C COMMUNICATES WITH GMONIT
      COMMON / CMONIT/ AVERWT,ERRELA,NEVTOT,NEVACC,NEVNEG,NEVOVE,NEVZER
      COMMON / INOUT  / NINP,NOUT
      DIMENSION  MK(100), WTMAS(100)
      COMMON / BXFMTS / BXOPE,BXCLO,BXTXT,BXL1I,BXL1F,BXL2F,BXL1G,BXL2G
      CHARACTER*80      BXOPE,BXCLO,BXTXT,BXL1I,BXL1F,BXL2F,BXL1G,BXL2G
      SAVE / MOMFIN /,/ UUREC  /,/ CMONIT/,/ INOUT  /,/ BXFMTS /
      SAVE NEVGEN,MARTOT,IDYFS
C
      IF(MODE.EQ.-1) THEN
C     ===================
      WRITE(NOUT,BXOPE)
      WRITE(NOUT,BXTXT) 'Initialize KARFIN  start'
      IDYFS = 0
      CALL GBOOK1(IDYFS+20,'KARFIN: log10(k/eps) marked $',50, 0D0, 5D0)
C ...Additional check on WTCTRL, plot of its u-dependence
      CALL GBOOK1(IDYFS+31,'KARFIN:     U  WTCTRL       $',27,.1D0, 1D0)
      CALL GBOOK1(IDYFS+32,'KARFIN:     U  WT=1         $',27,.1D0, 1D0)
      CALL GMONIT(-1,IDYFS+60,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+61,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+62,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+63,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+64,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+65,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+66,0D0,1D0,1D0)
      CALL GMONIT(-1,IDYFS+69,0D0,1D0,1D0)
      NEVGEN=0
      MARTOT=0
      WRITE(NOUT,BXTXT) 'Initialize KARFIN  end  '
      WRITE(NOUT,BXCLO)
      ELSEIF(MODE.EQ.0) THEN
C     ======================
      NEVGEN=NEVGEN+1
      SVAR = XXF(4)**2-XXF(3)**2-XXF(2)**2-XXF(1)**2
      CMSENE = SQRT(SVAR)
      EMIN = EPS*CMSENE/2
      CALL MBREF(SVAR,AMFIN,DELTA,
     $           UU,NPHOT,SPHOT,SPHUM,MK,QF1,QF2,WT1,WT2,WTMAS)
      CALL KINF1(XXF,QF1,QF2,NPHOT,SPHOT,SPHUM)
      WT3=1D0
      WCTRL=1D0
      WTREM=1D0
      IF(WT1.NE.0.D0) THEN
C ...optionally remove photons below epsilon from the record
C ...and reorganize mass weights
         CALL PIATEK(AMFIN,EMIN,DELTA,WTMAS,WTREM,WT3,WCTRL)
      ENDIF
      XMUL= NPHOT
      CALL GMONIT(0,IDYFS+64,XMUL,20D0,0D0)
      CALL GMONIT(0,IDYFS+65,WCTRL,1D0,0D0)
      CALL GF1(IDYFS+31, UU  ,WCTRL)
      CALL GF1(IDYFS+32, UU  ,  1D0)
      CALL GMONIT(0,IDYFS+66,WTREM,1D0,0D0)
C ...Monitoring weights
      XML = NPHOT
      CALL GMONIT(0,IDYFS+60,XML,20D0,0D0)
      CALL GMONIT(0,IDYFS+61,WT1,1D0,0D0)
      CALL GMONIT(0,IDYFS+62,WT2,1D0,0D0)
      CALL GMONIT(0,IDYFS+63,WT3,1D0,0D0)
C ...marked photons
      IF(NPHOT.GE.1) THEN
         DO 60 I=1,NPHOT
         XK= SPHOT(I,4)/EMIN
         UL= LOG10(XK)
         IF(MK(I).EQ.1)   CALL GF1(IDYFS+20,   UL,1.D0)
         IF(MK(I).EQ.1)   MARTOT=MARTOT+1
   60    CONTINUE
      ENDIF
C ...Main weight
      WT = WT1*WT2*WT3
      CALL GMONIT(0,IDYFS+69,WT ,1D0,0D0)
      ELSE
C     ====
C ...no printout for MODE=1
      IF(MODE.EQ.1) RETURN
C-----------------------------------------------------------------------
C.........................Output window A...............................
      CALL GMONIT(1,IDYFS+60,AVMULT,DUMM2,DUMM3)
      CALL GMONIT(1,IDYFS+61,AWT61,DWT61,DUMM3)
      CALL GMONIT(1,IDYFS+62,AWT62,DWT62,DUMM3)
      CALL GMONIT(1,IDYFS+63,AWT63,DWT63,DUMM3)
      CALL GMONIT(1,IDYFS+69,AWT69,DWT69,DUMM3)
C ...General information on weights
      WRITE(NOUT,BXOPE)
      WRITE(NOUT,BXTXT) 'KARFIN output - window A'
      WRITE(NOUT,BXTXT) '    Weight Statistics   '
      WRITE(NOUT,BXL2F) AWT69,DWT69,' general weight    ','WT    ','A1'
      WRITE(NOUT,BXL1I) NEVGEN,     ' generated events  ','NEVGEN','A2'
      WRITE(NOUT,BXL1F) AVMULT,     ' aver. ph. multi.  ','AVMULT','A3'
      WRITE(NOUT,BXL1I) MARTOT,     ' Marked photons    ','MARTOT','A4'
      WRITE(NOUT,BXL2F) AWT61,DWT61,' Kinematics, smin  ','WT1   ','A5'
      WRITE(NOUT,BXL2F) AWT62,DWT62,' Jacobian          ','WT2   ','A6'
      WRITE(NOUT,BXL2F) AWT63,DWT63,' Photon ang. dist. ','WT3   ','A7'
      WRITE(NOUT,BXCLO)
C ...Specific details on mass weight rearrangenment, and rejection
      CALL GMONIT(1,IDYFS+64,AVMLT,DWT65,DUMM3)
      CALL GMONIT(1,IDYFS+65,AWT65,DWT65,DUMM3)
      CALL GMONIT(1,IDYFS+66,AWT66,DWT66,DUMM3)
      NZER66 = NEVZER
      NTOT66 = NEVTOT
      WRITE(NOUT,BXOPE)
      WRITE(NOUT,BXTXT) 'KARFIN output - window B'
      WRITE(NOUT,BXTXT) '    on mass weights     '
      WRITE(NOUT,BXL2F) AWT66,DWT66,' removal wgt WTREM ','WT6 ','B1'
      WRITE(NOUT,BXL1I) NTOT66,     ' no. of raw events ','    ','B2'
      WRITE(NOUT,BXL1I) NZER66,     ' WT6=0      events ','    ','B3'
      WRITE(NOUT,BXL1F) AVMLT,      ' raw ph. multipl.  ','    ','B4'
      WRITE(NOUT,BXL2F) AWT65,DWT65,' control wgt WCTRL ','WT5 ','B5'
      WRITE(NOUT,BXL1G) EPS,        ' epsilon           ','    ','B6'
      WRITE(NOUT,BXL1G) DELTA,      ' delta             ','    ','B7'
      WRITE(NOUT,BXCLO)
C ...Histograms
cc      CALL GPRINT(IDYFS+20)
cc      CALL GOPERA(IDYFS+31,'/',IDYFS+32,IDYFS+33,1D0,1D0)
cc      CALL GPRINT(IDYFS+33)
      ENDIF
C     =====
      END
      SUBROUTINE PIATEK(AMFIN,EMIN,DELTA,WTMAS,WTREM,WTM3A,WCTRL)
C     ***********************************************************
C Written CERN piatek 22 sept. 89  (S.J.)
C Note the action of this routine is not Loretnz invariant !!!!
C         KEYPIA   =0,1 REMOVAL OF PHOTONS BELOW EMIN OFF/ON
C INPUT:  momenta in / MOMFIN /
C         AMFIN    = fermion mass (GEV)
C         EMIN     = Emin minimum energy of photons to be left (GEV)
C         DELTA    = infrared cut-off in generation (dimrnsionless)
C         WTMAS    = list of mass weights for all photons
C OUTPUT: WTREJ    = 1 for KEYPIA=0
C  = mass weight of removed photons for KEYPIA=1
C         WTM3T    = mass weight for all photons, see comments below
C         WCTRL    = control weight for remowed photons
C     ***********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER(PI=3.1415926535897932D0,ALFINV=137.03604D0)
      DIMENSION  WTMAS(100)
      COMMON / MOMFIN / QF1(4),QF2(4),SPHUM(4),SPHOT(100,4),NPHOT
      COMMON / KEYYFS / KEYZET,KEYBRM,KEYFIX,KEYRED,KEYWGT
      COMMON / INOUT  / NINP,NOUT
      SAVE / MOMFIN /,/ KEYYFS /,/ INOUT  /
      DIMENSION QQ(4),PP(4)

      KEYPIA = KEYRED
      DO 10 K=1,4
      PP(K) = QF1(K)+QF2(K) +SPHUM(K)
  10  QQ(K) = QF1(K)+QF2(K)
      SVAR = PP(4)**2-PP(3)**2 -PP(2)**2 -PP(1)**2
      SPRIM= QQ(4)**2-QQ(3)**2 -QQ(2)**2 -QQ(1)**2
      WTM1=1D0
      WTM2=1D0
C ...mass weight below and above epsilon calculated separately
      DO 40 I=1,NPHOT
      IF(SPHOT(I,4).LT.EMIN) THEN
         WTM1=WTM1*WTMAS(I)
         IF(WTM1.LE.1D-30) WTM1=0D0
      ELSE
         WTM2=WTM2*WTMAS(I)
         IF(WTM2.LE.1D-30) WTM2=0D0
      ENDIF
   40 CONTINUE
C ...All sort of weights
      ALF1  =  1/PI/ALFINV
      QQK  = QQ(4)*SPHUM(4)-QQ(3)*SPHUM(3)-QQ(2)*SPHUM(2)-QQ(1)*SPHUM(1)
C ...delt1 and eps1 are cutoffs which sit in YFS formfactor
      DELT1 =  DELTA*(1+ 2*QQK/SPRIM)
      EPS1  =  SQRT(EMIN**2/QF1(4)/QF2(4))
C ...YFS formfactor cut-off dependend part: delt1 = 2Emin/sqrt(s')
C ...where Emin is infrared cut-off in QMS
      FYFS  = -2*ALF1*(DLOG(SPRIM/AMFIN**2)-1)*DLOG(1/DELT1)
C ...The total phase space integral for crude x-section,
C ...Note that delta is a lower limit on y-variables used in generation
      FPHS  =  2*ALF1* DLOG(SVAR/AMFIN**2) *DLOG(1/DELTA)
      DELB  =  FYFS + FPHS
C ...The average mass weight for removed photon = EXP(DELB2)
C ...Can be calculated analyticaly as a  ratio of YFS formfactors
C ...On the other hand it is checked by MC, see control weight WTCTRL
      DELB2 = -2*ALF1*(DLOG(SVAR/SPRIM)+1) *DLOG(EPS1/DELT1)
C ...Control weight - its average should be precisely one
      WCTRL =WTM1*EXP(-DELB2)
      IF(KEYPIA.EQ.0) THEN
         IF(ABS(DELB).GT.100D0 ) WRITE(NOUT,*) ' DELB= ',DELB
         IF(ABS(DELB).GT.100D0 ) WRITE(   6,*) ' DELB= ',DELB
         WTREM = 1D0
         WTM3A = WTM1*WTM2*EXP(DELB)
      ELSE
C ...Optional removal of photons below epsilon from the record
C ...in such a case WTM3A includes exp(BELB2)= <WT3> for removed ph.
         NPH=NPHOT
         DO 100 J=NPHOT,1,-1
         IF(SPHOT(J,4).LT.EMIN) THEN
            DO 60 I=J+1,NPH
            DO 60 K=1,4
   60       SPHOT(I-1,K)=SPHOT(I,K)
            NPH=NPH-1
         ENDIF
  100    CONTINUE
         NPHOT=NPH
C ...WTMAS includes here average weight of removed photons exp(DELB2)
         WTREM = WTM1
         WTM3A = WTM2*EXP(DELB+DELB2)
      ENDIF
      END
      SUBROUTINE WFORM(CMSENE,Q1,Q2,AMF,DELTA,EPS,DYFS)
C     *************************************************
C Not used, kept for some future tests
C Yennie-Fraytschi-Suura Formfactors for the final state ferm. pair
C     ***********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER(PI=3.1415926535897932D0,ALFINV=137.03604D0)
      PARAMETER(ALF1=1/ALFINV/PI)
      DIMENSION Q1(4),Q2(4)

      SVAR  = CMSENE**2
      ENE= CMSENE/2
C ...Momenta q1,q2 should be in CMS
      E1 = Q1(4)
      E2 = Q2(4)
      BETF2 = 2*ALF1* DLOG(SVAR /AMF**2)
      DELB  = BETF2*DLOG(ENE/SQRT(E1*E2)*EPS/DELTA)
      EP    = E1+E2
      EM    = E1-E2
      Q1Q2  = Q1(4)*Q2(4)-Q1(3)*Q2(3)-Q1(2)*Q2(2)-Q1(1)*Q2(1)
      DL    = SQRT( 2*Q1Q2 +EM**2 )
      REMN  = PI**2/2
     $        -0.50*DLOG(E1/E2)**2
     $        -0.25*DLOG((DL+EM)**2/(4*E1*E2))**2
     $        -0.25*DLOG((DL-EM)**2/(4*E1*E2))**2
     $        - DILOGY((DL+EP)/(DL+EM)) -DILOGY((DL-EP)/(DL-EM))
     $        - DILOGY((DL-EP)/(DL+EM)) -DILOGY((DL+EP)/(DL-EM))
      DYFS  = EXP( DELB +ALF1*REMN )
      END
      SUBROUTINE MBREF(SVAR,AMFIN,DELTA,
     $                 UU,NPHOT,PHOT,PHSU,MK,Q1,Q2,WT1,WT2,WTM)
C     *****************************************************************
C SIMULATES FINAL STATE BREMSSTRAHLUNG (11 MARCH 1989)
C INPUT  : SVAR   = S VARIABLE  (GEV)
C          AMFIN  = MASS OF FINAL FERMION
C          DELTA  = LOWER ENERGY BOUND (DIMENSIONLESS)
C OUTPUT : UU     = 1-s'/s
C          NPHOT  = PHOTON MULTIPLICITY
C          PHOT   = PHOTON FOUR MOMENTA (GEV) IN CMS
C          PHSU   = SUM OF PHOTON MOMENTA
C          MK     = MARKS ON PHOTONS CLOSE TO LOWER ENERGY BOUND
C          Q1     = FINAL FERMION FOUR MOMENTUM (GEV)
C          Q2     = FINAL FERMION FOUR MOMENTUM
C          WT1    = THE WEIGHT - PHASE SPACE LIMITS FOR VERY HARD PHOT.
C          WT2    = THE WEIGHT - TRANSLATION JACOBIAN.
C          WTM    = The list of mass weights.
C     **************************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER(PI=3.1415926535897932D0,ALFINV=137.03604D0)
      DIMENSION PHOT(100,4),PHSU(4),MK(100),WTM(100),Q1(4),Q2(4)
      DIMENSION RR(100),XK(100),CGX(100),SGX(100)
      COMMON / INOUT  / NINP,NOUT
      COMMON / KEYYFS / KEYZET,KEYBRM,KEYFIX,KEYRED,KEYWGT
      SAVE / INOUT  /,/ KEYYFS /

C KEYCMS =0 INHIBITS TRANSFORMATION TO CMS
C INITIALIZATIONS
      UU= -1D0
      WT1=1.D0
      WT2=1.D0
      AM2= 4.D0*AMFIN**2/SVAR
      DO 10 I=1,100
      RR(I)=0.D0
   10 MK(I)=0
      DO 20 K=1,4
      PHSU(K)=0.D0
      Q1(K)=0.D0
   20 Q2(K)=0.D0
      DO 21 I=1,100
      DO 21 K=1,4
   21 PHOT(I,K)=0.D0
C GENERATE PHOTON MULTIPLICITY, AVERG = AVERAGE MULTIPLICITY (CRUDE)
      BETF2 = 2/PI/ALFINV*DLOG(SVAR/AMFIN**2)
      AVERG = BETF2*DLOG(1/DELTA)
      NMAX=50
    5 CONTINUE
      CALL POISSG(AVERG,NMAX,NPHOT,RR)
C This is for tests of program at fixed multiplicity (for adv. users)
      NPHFIX =  MOD(KEYBRM,100000)/10000
      IF(NPHFIX.NE.0.AND.NPHOT.NE.NPHFIX) GOTO 5
      IF(NPHOT.EQ.0) THEN
          SPRIM=SVAR
      ELSE
C BEGIN WITH PHOTON ENERGY
          XSUM=0.D0
          DO  50 I=1,NPHOT
          XK(I)=DELTA**RR(I)
          IF(XK(I).LT.SQRT(10.D0)*DELTA) MK(I)=1
   50     XSUM=XSUM+XK(I)
          IF(XSUM.GE.1.D0) GOTO 900
          DO 60 I=1,NPHOT
   60     XK(I)=XK(I)/(1.D0-XSUM)
          DO 100 I=1,NPHOT
C ...Photons close to low energy boundry marked for further control
          CALL VARRAN(RN1,1)
          CALL VARRAN(RN2,1)
C ...Simplified photon angular distribution,
C ...s'->s and m**2/(kp)**2 dropped
C ...CG=cos(theta) and SG=sin(theta) memorized to avoid rounding err.
          CALL ANGBRE(RN1,AM2,CG,SG,WTM(I),DIS1)
          PHI=2.D0*PI*RN2
C ...Define photon mementa (in units of sqrt(s')/2 )
          PHOT(I,1)=XK(I)*SG*COS(PHI)
          PHOT(I,2)=XK(I)*SG*SIN(PHI)
          PHOT(I,3)=XK(I)*CG
          PHOT(I,4)=XK(I)
          DO 70 K=1,4
   70     PHSU(K)=PHSU(K)+PHOT(I,K)
          CGX(I)=CG
          SGX(I)=SG
  100     CONTINUE
C ...Determine rescaling factor and s', WT2 is dilatation Jacobian
          XMK2 = PHSU(4)**2-PHSU(3)**2-PHSU(2)**2-PHSU(1)**2
          YY   = 1.D0/(1.D0 +PHSU(4) +XMK2/4.D0 )
          WT2  = YY*(1.D0+PHSU(4))
          SPRIM= SVAR*YY
C ...reject events with too hard photons
          SMINI= 4*AMFIN**2
          IF(SPRIM.LT.SMINI) GOTO 900
C ...recsale properly all photon momenta
          ENER = SQRT(SPRIM)/2.D0
          DO 120 K=1,4
          PHSU(K)= PHSU(K)*ENER
          DO 120 I=1,NPHOT
  120     PHOT(I,K)=PHOT(I,K)*ENER
C-----------Mass weight---------------------
C ...This weight compensates for s->s' and droping terms -m**2/(k.q)**2
C ...care is taken of machine rounding errors
          AMF= 4.D0*AMFIN**2/SPRIM
          BTF =SQRT(1.D0-AMF)
          DO 200 I=1,NPHOT
          IF( CGX(I).GT.0.D0 ) THEN
              DEL2=1.D0+BTF*CGX(I)
              DEL1= (SGX(I)**2 + AMF*CGX(I)**2)/DEL2
          ELSE
              DEL1=1.D0-BTF*CGX(I)
              DEL2= (SGX(I)**2 + AMF*CGX(I)**2)/DEL1
          ENDIF
          DIST1=1/DEL1/DEL2
     $            -AMF/(1.D0+BTF )/2.D0*(1.D0/DEL1**2+1.D0/DEL2**2)
          IF(DIST1.LT.0.D0) THEN
              DIST1=0D0
              WRITE(NOUT,*) ' +++++++ MBREF: NEGATIVE WTMAS =',DIST1
              WRITE(   6,*) ' +++++++ MBREF: NEGATIVE WTMAS =',DIST1
          ENDIF
          WTM(I)= DIST1/WTM(I)
          IF(WTM(I).LT. 1.D-20) WTM(I)= 0.D0
  200     CONTINUE
      ENDIF
      UU   = 1 - SPRIM/SVAR
      ENER= SQRT(SPRIM)/2.D0
C FINAL FERMION MOMENTA
      Q1(4)=ENER
      Q1(3)=SQRT(ENER**2-AMFIN**2)
      Q2(4)=ENER
      Q2(3)=-Q1(3)
      RETURN
C EVENT OUTSIDE PHASE SPACE
  900 WT1=0.D0
      WT2=1.D0
      NPHOT=-1
      END
      SUBROUTINE KINF1(XXF,Q1,Q2,NPHOT,PHOT,PHSU)
C     *******************************************
C Transforms to CMS: PHOT, PHSU, Q1,Q2
C with random Euler rotation in XXF frame (Z frame)
C     ***********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER( PI = 3.1415926535897932D0)
      DIMENSION XXF(4),PHOT(100,4),PHSU(4),Q1(4),Q2(4)
      DIMENSION PH(4),PP(4),DRVEC(10)

      IF(NPHOT.EQ.-1) RETURN
      CALL VARRAN(DRVEC,2)
      RN1 = DRVEC(1)
      RN2 = DRVEC(2)
      CTH= 1.D0 -2.D0*RN1
      THE= ACOS(CTH)
      PHI= 2.D0*PI*RN2
      DO 210 K=1,4
  210 PP(K)=Q1(K)+Q2(K)+PHSU(K)
      DO 230 I=1,NPHOT
          DO 220 K=1,4
  220     PH(K)=PHOT(I,K)
          CALL BOSTDQ(  1, PP,PH,PH)
          CALL ROTEUL(THE,PHI,PH,PH)
          CALL BOSTDQ( -1,XXF,PH,PH)
          DO 225 K=1,4
  225     PHOT(I,K)= PH(K)
  230 CONTINUE
      CALL BOSTDQ(  1, PP,Q1,Q1)
      CALL ROTEUL(THE,PHI,Q1,Q1)
      CALL BOSTDQ( -1,XXF,Q1,Q1)
      CALL BOSTDQ(  1, PP,Q2,Q2)
      CALL ROTEUL(THE,PHI,Q2,Q2)
      CALL BOSTDQ( -1,XXF,Q2,Q2)
      CALL BOSTDQ(  1, PP,PHSU,PHSU)
      CALL ROTEUL(THE,PHI,PHSU,PHSU)
      CALL BOSTDQ( -1,XXF,PHSU,PHSU)
      END
      SUBROUTINE ROTEUL(THE,PHI,PVEC,QVEC)
C     ************************************
C EULER ROTATION
      IMPLICIT REAL*8(A-H,O-Z)
      REAL*8 PVEC(4),QVEC(4)
      CALL ROTOD1(THE,PVEC,QVEC)
      CALL ROTOD3(PHI,QVEC,QVEC)
      END
      SUBROUTINE GIBEA(CMSENE,AMEL,P1,P2)
C     ***********************************
C GIVEN CMS ENERGY (CMSENE) DEFINES BEAM MOMENTA IN CMS
C     ***********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION P1(*),P2(*)
      BETEL=SQRT(1D0-4D0*AMEL**2/CMSENE**2)
      P1(1)=  0D0
      P1(2)=  0D0
      P1(3)=  CMSENE/2D0*BETEL
      P1(4)=  CMSENE/2D0
      P2(1)=  0D0
      P2(2)=  0D0
      P2(3)= -CMSENE/2D0*BETEL
      P2(4)=  CMSENE/2D0
      END
      SUBROUTINE KINF2(XXF,AMFIN,Q1,Q2)
C     ************************************
C ...Generates two body phase space with uniform spherical density
C ...For pure Born case (no bremss.)
C     ***********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER( PI = 3.1415926535897932D0)
      DIMENSION XXF(*),Q1(*),Q2(*),DRVEC(10)

      CMSENE= SQRT(XXF(4)**2-XXF(3)**2-XXF(2)**2-XXF(1)**2)
      CALL VARRAN(DRVEC,2)
      RN1 = DRVEC(1)
      RN2 = DRVEC(2)
      CTH= 1.D0 -2.D0*RN1
      THE= ACOS(CTH)
      PHI= 2.D0*PI*RN2
      CALL GIBEA(CMSENE,AMFIN,Q1,Q2)
      CALL ROTEUL(THE,PHI,Q1,Q1)
      CALL BOSTDQ( -1,XXF,Q1,Q1)
      CALL ROTEUL(THE,PHI,Q2,Q2)
      CALL BOSTDQ( -1,XXF,Q2,Q2)
C======================================================================
C=====================End of KARFIN part===============================
C======================================================================
      END
      SUBROUTINE POISSG(AVERG,NMAX,MULT,RR)
C     **************************************
C Last corr. Nov. 91
C This generates photon multipl. NPHOT according to Poisson distr.
C INPUT:  AVERG = AVERAGE MULTIPLICITY
C         NMAX  = MAXIMUM MULTIPLICITY
C OUTPUT: MULT = GENERATED MULTIPLICITY
C         RR(1:100) LIST OF ORDERED UNIFORM RANDOM NUMBERS,
C         A BYPRODUCT RESULT, TO BE EVENTUALLY USED FOR SOME FURTHER
C         PURPOSE (I.E.  GENERATION OF PHOTON ENERGIES).
C     ************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION RR(*)
      COMMON / INOUT  / NINP,NOUT
      SAVE   / INOUT  /
      SAVE NFAIL
      DATA NFAIL/0/
   50 NN=0
      SUM=0D0
      DO 100 IT=1,NMAX
      CALL VARRAN(RN,1)
      Y= LOG(RN)
      SUM=SUM+Y
      NN=NN+1
      RR(NN)=SUM/(-AVERG)
      IF(SUM.LT.-AVERG) GOTO 130
  100 CONTINUE
      NFAIL=NFAIL+1
      IF(NFAIL.GT.100) GOTO 900
      GOTO 50
  130 MULT=NN-1
      RETURN
  900 WRITE(NOUT,*) ' POISSG: TO SMALL NMAX'
      STOP
      END

      SUBROUTINE ANGBRE(RN1,AM2,COSTHG,SINTHG,DIST0,DIST1)
C     ****************************************************
C THIS ROUTINE GENERATES PHOTON ANGULAR DISTRIBUTION
C IN THE REST FRAME OF THE FERMION PAIR.
C THE DISTRIBUTION IS TAKEN IN THE INFRARED LIMIT.
C GENERATES WEIGHTED EVENTS
C INPUT:  AM2 = 4*MASSF**2/S WHERE MASSF IS FERMION MASS
C         AND S IS FERMION PAIR EFFECTIVE MASS.
C OUTPUT: COSTHG, SINTHG, COS AND SIN OF THE PHOTON
C         ANGLE WITH RESPECT TO FERMIONS DIRECTION
C         DIST0 = distribution  generated without m**2/(kp)**2 terms
C         DIST1 = distribution  with m**2/(kp)**2 terms
C     ***************************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      BETA=SQRT(1.D0-AM2)
      EPS=AM2/(1.D0+SQRT(1.D0-AM2))
      DEL1=(2.D0-EPS)*(EPS/(2.D0-EPS))**RN1
      DEL2=2.D0-DEL1
C SYMMETRIZATION
      CALL VARRAN(RN2,1)
      IF(RN2.LE.0.5D0) THEN
        A=DEL1
        DEL1=DEL2
        DEL2=A
      ENDIF
      DIST0=1D0/DEL1/DEL2
      DIST1=DIST0-EPS/2.D0*(1D0/DEL1**2+1D0/DEL2**2)
C CALCULATION OF SIN AND COS THETA FROM INTERNAL VARIABLES
      COSTHG=(1.D0-DEL1)/BETA
      SINTHG=SQRT(DEL1*DEL2-AM2)/BETA
      END

      SUBROUTINE DUMPS(NOUT)
C     **********************
C THIS PRINTS OUT FOUR MOMENTA OF PHOTONS
C ON UNIT NO. NOUT
C     **********************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON / MOMSET / QF1(4),QF2(4),SPHUM(4),SPHOT(100,4),NPHOT
      SAVE   / MOMSET /
      DIMENSION SUM(4)
      WRITE(NOUT,*) '=====================DUMPS===================='
      WRITE(NOUT,3100) 'QF1',(  QF1(  K),K=1,4)
      WRITE(NOUT,3100) 'QF2',(  QF2(  K),K=1,4)
      DO 100 I=1,NPHOT
  100 WRITE(NOUT,3100) 'PHO',(SPHOT(I,K),K=1,4)
      DO 200 K=1,4
  200 SUM(K)=QF1(K)+QF2(K)
      DO 210 I=1,NPHOT
      DO 210 K=1,4
  210 SUM(K)=SUM(K)+SPHOT(I,K)
      WRITE(NOUT,3100) 'SUM',(  SUM(  K),K=1,4)
 3100 FORMAT(1X,A3,1X,5F18.14)
      END

      SUBROUTINE DUMPF(NOUT)
C     **********************
C THIS PRINTS OUT FOUR MOMENTA OF PHOTONS
C ON UNIT NO. NOUT
C     **********************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON / MOMFIN / QF1(4),QF2(4),SPHUM(4),SPHOT(100,4),NPHOT
      SAVE   / MOMFIN /
      DIMENSION SUM(4)
      WRITE(NOUT,*) '=====================DUMPF===================='
      WRITE(NOUT,3100) 'QF1',(  QF1(  K),K=1,4)
      WRITE(NOUT,3100) 'QF2',(  QF2(  K),K=1,4)
      DO 100 I=1,NPHOT
  100 WRITE(NOUT,3100) 'PHO',(SPHOT(I,K),K=1,4)
      DO 200 K=1,4
  200 SUM(K)=QF1(K)+QF2(K)
      DO 210 I=1,NPHOT
      DO 210 K=1,4
  210 SUM(K)=SUM(K)+SPHOT(I,K)
      WRITE(NOUT,3100) 'SUM',(  SUM(  K),K=1,4)
 3100 FORMAT(1X,A3,1X,5F18.14)
      END

      SUBROUTINE DUMPI(NOUT)
C     **********************
C THIS PRINTS OUT FOUR MOMENTA OF PHOTONS
C ON UNIT NO. NOUT
C     **********************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON / MOMINI / QF1(4),QF2(4),SPHUM(4),SPHOT(100,4),NPHOT
      SAVE   / MOMINI /
      DIMENSION SUM(4)
      WRITE(NOUT,*) '=====================DUMPI===================='
      WRITE(NOUT,3100) 'QF1',(  QF1(  K),K=1,4)
      WRITE(NOUT,3100) 'QF2',(  QF2(  K),K=1,4)
      DO 100 I=1,NPHOT
  100 WRITE(NOUT,3100) 'PHO',(SPHOT(I,K),K=1,4)
      DO 200 K=1,4
  200 SUM(K)=QF1(K)+QF2(K)
      DO 210 I=1,NPHOT
      DO 210 K=1,4
  210 SUM(K)=SUM(K)+SPHOT(I,K)
      WRITE(NOUT,3100) 'SUM',(  SUM(  K),K=1,4)
 3100 FORMAT(1X,A3,1X,5F18.14)
      END

      SUBROUTINE DUMPN(NOUT,IEV)
C     **************************
C THIS PRINTS OUT FOUR MOMENTA OF final state
C and the serial number of event IEV on unit NOUT
C     **********************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON / MOMINI / QF1(4),QF2(4),SPHUM(4),SPHOT(100,4),NPHOT
      SAVE   / MOMINI /
      DIMENSION SUM(4)
      WRITE(NOUT,*) '=============DUMPNEW====================>',IEV
      WRITE(NOUT,3100) 'QF1',(  QF1(  K),K=1,4)
      WRITE(NOUT,3100) 'QF2',(  QF2(  K),K=1,4)
      DO 100 I=1,NPHOT
  100 WRITE(NOUT,3100) 'PHO',(SPHOT(I,K),K=1,4)
      DO 200 K=1,4
  200 SUM(K)=QF1(K)+QF2(K)
      DO 210 I=1,NPHOT
      DO 210 K=1,4
  210 SUM(K)=SUM(K)+SPHOT(I,K)
      WRITE(NOUT,3100) 'SUM',(  SUM(  K),K=1,4)
 3100 FORMAT(1X,A3,1X,5F18.14)
      END

C=============================================================
C=============================================================
C==== end of elementary file =================================
C=============================================================
C=============================================================
C  !!!! LOGBOOK of corrections since 24 Nov 91 !!!!
C
C * line in MARRAN to long ( in printout of ijkl)
C * CHBIN2 replaced by CHBIN1
C  !!!!!!!!!!!!!!

C Library of utilities for YFS and BHLUMI programs
C version 1.0 November 91
      SUBROUTINE CHBIN3(R,ALF,BET,X,XPRIM,DJAC)
C     *****************************************
C Written: Dec. 1991
C This routine mapps variable R into X, XPRIM=1-X.
C To be employed in the integration (either ordinary or Monte Carlo)
C of any distributions resambling the binomial distribution
C             x**(alf-1)*(1-x)**(bet-1).
C with 1> alf,bet > 0. Variables R and X are  in (0,1) range.
C Djac is the Jacobian factor d(x)/d(r).
C Mapping is such that 1/djac is very close to
C binomial distribution x**(alf-1)*(1-x)**(bet-1).
C WARNING:
C Mapping may fail very close to R=0 and R=1. User is recommended
C to assure that: fleps**alf < R < 1-fleps**bet,
C where fleps = 1.d-30.
C     ************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON / INOUT  / NINP,NOUT
      SAVE   / INOUT  /
C
      IF( ALF.LE.1D-10 .OR. ALF .GT. 3D0 ) GOTO 900
      IF( BET.LE.1D-10 .OR. BET .GT. 3D0 ) GOTO 900
      X0=(1D0-ALF)/(2D0-ALF-BET)
      X0= MIN( MAX(X0, 0.001D0), 0.999D0)
      Q1=       X0**ALF            *BET*(1D0-X0)**(BET-1D0)
      Q2=       ALF*X0**(ALF-1D0)  *((1D0-X0)**BET)
      P1= Q1/(Q1+Q2)
      IF( R.LE.P1 ) THEN
         X    =  X0*(R/P1)**(1D0/ALF)
         XPRIM=  1D0-X
         DIST =  ALF* X**(ALF-1D0)  *BET*(1D0-X0)**(BET-1D0)
ccc      write(6,*) '3A:x,x1=',x,xprim
      ELSE
         XPRIM=  (1-X0)*((1D0-R)/(1D0-P1))**(1D0/BET)
         X    =  1D0- XPRIM
         DIST =  ALF*X0**(ALF-1D0)  *BET*XPRIM**(BET-1D0)
ccc      write(6,*) '3B:x,x1=',x,xprim
      ENDIF
      DJAC    =  (Q1+Q2)/DIST
      RETURN
  900 WRITE(NOUT,*) ' ++++ STOP IN CHBIN3: wrong parameters'
      WRITE(   6,*) ' ++++ STOP IN CHBIN3: wrong parameters'
      STOP
      END

      SUBROUTINE CHBIN1(R,ALF,BET,XMAX,X,DJAC)
C     ****************************************
C     last correction Dec. 91
c this mapps variable r into x.
c to be employed in the integration (either ordinary or monte carlo)
c of distributions resambling
c the binomial distribution x**(alf-1)*(1-x)**(bet-1)
c with alf > 0 and  bet arbitrary.
c variable r is in (0,1) range and x is within (0,xmax) range.
c djac is jacobian factor d(x)/d(r).
c mapping is such that 1/djac is very close to
c binomial distribution x**(alf-1)*(1-x)**(bet-1).
c WARNING: mapping may fail very close to R=0. Practically, one is
c recommended to obey: fleps**alf < r, where fleps = 1.d-30.
c Problems may also arise for very small xmax ( below 1.d-12 ).
C     ************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON / INOUT  / NINP,NOUT
      save   / INOUT  /
C
      IF( ALF.LE.0D0 ) GOTO 900
      X0=(ALF-1D0)/(ALF+BET-2D0)
      IF(X0.GT.XMAX) X0=XMAX
      X0= MAX(X0, 0D0)
      Q1= 1D0/ALF*X0**ALF  *(1D0-X0)**(BET-1D0)
      Q2= X0**(ALF-1D0) /BET*((1D0-X0)**BET-(1D0-XMAX)**BET)
      P1= Q1/(Q1+Q2)
      IF( R.LE.P1 ) THEN
         X=X0*(R/P1)**(1D0/ALF)
         DIST= X**(ALF-1D0)*(1D0-X0)**(BET-1D0)
      ELSE
         R1= (1D0-R)/(1D0-P1)
         X = (1D0-XMAX)**BET + ((1D0-X0)**BET-(1D0-XMAX)**BET)*R1
         X = 1D0 - X**(1D0/BET)
         DIST= X0**(ALF-1D0)*(1D0-X)**(BET-1D0)
      ENDIF
      DJAC=(Q1+Q2)/DIST
      RETURN
  900 WRITE(NOUT,*) ' ========= STOP IN CHBIN1: WRONG PARAMS'
      STOP
      END


      SUBROUTINE VESK1W(MMODE,FUNSKO,PAR1,PAR2,PAR3)
C     **********************************************
C======================================================================
C======================================================================
C===================== V E S K 1 W ====================================
C==================S. JADACH  SEPTEMBER 1985===========================
C==================S. JADACH  November  1991===========================
C======================================================================
C ONE DIMENSIONAL MONTE CARLO  SAMPLER.
C Vesrion with weighted events!
C DOUBLE PRECISION  FUNCTION FUNSKO IS THE DISTRIBUTION TO BE GENERATED.
C JLIM1 IS THE NUMBER OF ENTRIES IN THE EQUIDISTANT LATICE WHICH
C IS FORMED IN THE FIRST STAGE AND JLIM2 IS THE TOTAL MAXIMUM
C NUMBER OF ENTRIES IN THE LATICE, NOTE THAT DIMENSIONS OF
C MATRICES IN /CESK8A/ SHOULD BE AT LEAST JLIM2+1 .
C FOR MILD FUNSKO JLIM2=128 IS ENOUGH.
C TO CREATE AN INDEPENDENT VERSION REPLACE /ESK8A/=>/ESK8B/.
C     **********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      save
      COMMON / CESK1W / XX(1025),YY(1025),ZINT(1025),ZSUM,JMAX
      COMMON / INOUT  / NINP,NOUT
      DATA JLIM1,JLIM2/16,257/
      EXTERNAL FUNSKO
      DATA IWARM/0/
C
      MODE=MMODE
      IF(MODE.EQ.-1) THEN
C     ===================
C INITIALISATION PART, SEE VINSKO FOR MORE COMMENTS
      INIRAN=1
      IWARM=1
      WT=0.
      SWT=0.
      SSWT=0.
      NEVS=0
C INITIALISATION PART, SAMPLING DISTRIBUTION FUNSKO
C AND FILLING MATRICES XX,YY,ZINT ETC.
      JMAX=1
      XX(1)=0.
      XX(2)=1.
      YY(1)=FUNSKO(XX(1))
      YY(2)=FUNSKO(XX(2))
      IF(YY(1).LT.0.0.OR.YY(2).LT.0.0) GO TO 999
      ZINT(1)=.5D0*(YY(2)+YY(1))*(XX(2)-XX(1))
C
      JDIV=1
      DO 200 K=1,JLIM2-1
      IF(JMAX.LT.JLIM1) THEN
C...    NOTE THAT DESK1W INCREMENTS JMAX=JMAX+1 IN EVERY CALL
        CALL DESK1W(FUNSKO,JDIV)
        JDIV=JDIV+2
        IF(JDIV.GT.JMAX) JDIV=1
      ELSE
        JDIV=1
        ZMX=ZINT(1)
        DO 180 J=1,JMAX
        IF(ZMX.LT.ZINT(J)) THEN
          ZMX=ZINT(J)
          JDIV=J
        ENDIF
  180   CONTINUE
        CALL DESK1W(FUNSKO,JDIV)
      ENDIF
  200 CONTINUE
C
C...  FINAL ADMINISTRATION, NORMALIZING ZINT ETC.
      ZSUM1=0.
      ZSUM =0.
      DO 220 J=1,JMAX
      ZSUM1=ZSUM1+ZINT(J)
      YMAX= MAX( YY(J+1),YY(J))
      ZINT(J)=YMAX*(XX(J+1)-XX(J))
  220 ZSUM=ZSUM+ZINT(J)
      SUM=0.
      DO 240 J=1,JMAX
      SUM=SUM+ZINT(J)
  240 ZINT(J)=SUM/ZSUM
C====>>>
C Crude x-section estimate
ccc      CINTEG=ZSUM
ccc      ERRINT=0D0
      PAR1=  ZSUM
      PAR2=  ZSUM
      PAR3=  ZSUM
C===<<<
      ELSE IF(MODE.EQ.0) THEN
C     =======================
C GENERATION PART
      IF(IWARM.EQ.0) GOTO 901
ccc  222 CONTINUE
ccc      IF( (WT-1D0).GT.1D-10) THEN
ccc        WT=WT-1.D0
ccc      ELSE
        CALL VARRAN(RNUMB,1)
        DO 215 J=1,JMAX
        JSTOP=J
  215   IF(ZINT(J).GT.RNUMB) GOTO 216
  216   CONTINUE
        IF(JSTOP.EQ.1) THEN
          D=RNUMB/ZINT(1)
        ELSE
          D =(RNUMB-ZINT(JSTOP-1))/(ZINT(JSTOP)-ZINT(JSTOP-1))
        ENDIF
        X=XX(JSTOP)*(1.D0 -D )+XX(JSTOP+1)*D
        FN=FUNSKO(X)
        IF(FN.LT.0.D0) GOTO 999
        YYMAX=MAX(YY(JSTOP+1),YY(JSTOP))
        WT=FN/YYMAX
        NEVS=NEVS+1
        SWT=SWT+WT
        SSWT=SSWT+WT*WT
ccc      ENDIF
ccc      CALL VARRAN(RNUMB,1)
ccc      IF(RNUMB.GT.WT) GOTO 222
      PAR1=  X
      PAR2=  FN
      PAR3=  WT
C
      ELSE IF(MODE.EQ.1) THEN
C     =======================
C FINAL STATISTICS
C STJ 24.OCT.89
      CINTEG=0D0
      ERRINT=0D0
      IF(NEVS.GT.0) CINTEG=ZSUM*SWT/FLOAT(NEVS)
      IF(NEVS.GT.0) ERRINT=SQRT(SSWT/SWT**2-1.D0/FLOAT(NEVS))
      PAR1=  CINTEG
      PAR2=  ERRINT
      PAR3=  ZSUM
C--
      ELSE
C     ====
      GOTO  902
      ENDIF
C     =====
C
      RETURN
 901  WRITE(NOUT,9010)
 9010 FORMAT(' **** STOP IN VESK8A, LACK OF INITIALISATION')
      STOP
 902  WRITE(NOUT,9020)
 9020 FORMAT(' **** STOP IN VESK8A, WRONG MODE ')
      STOP
 999  WRITE(NOUT,9990)
 9990 FORMAT(' **** STOP IN VESK8A, NEGATIVE VALUE OF FUNSKO ')
      STOP
      END
      SUBROUTINE DESK1W(FUNSKO,JDIV)
C     ******************************
C THIS ROUTINE BELONGS TO VESK8A PACKAGE
C IT SUDIVIDES INTO TWO EQUAL PARTS THE INTERVAL
C (XX(JDIV),XX(JDIV+1))  IN THE LATICE
C     ***********************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      save
      COMMON / CESK1W / XX(1025),YY(1025),ZINT(1025),ZSUM,JMAX
      COMMON / INOUT  / NINP,NOUT
      EXTERNAL FUNSKO
C
      XNEW=.5D0*(XX(JDIV) +XX(JDIV+1))
      DO 100 J=JMAX,JDIV,-1
      XX(J+2)  =XX(J+1)
      YY(J+2)  =YY(J+1)
  100 ZINT(J+1)=ZINT(J)
      XX(JDIV+1)= XNEW
      YY(JDIV+1)= FUNSKO(XNEW)
      IF(YY(JDIV+1).LT.0.) GOTO 999
      ZINT(JDIV)  =.5D0*(YY(JDIV+1)+YY(JDIV)  )*(XX(JDIV+1)-XX(JDIV)  )
      ZINT(JDIV+1)=.5D0*(YY(JDIV+2)+YY(JDIV+1))*(XX(JDIV+2)-XX(JDIV+1))
      JMAX=JMAX+1
      RETURN
  999 WRITE(NOUT,9000)
 9000 FORMAT(' **** STOP IN DESK1W, NEGATIVE VALUE OF FUNSKO ')
      STOP
      END


      SUBROUTINE VESK2W(MODE,FUNSKO,X,Y,WT)
C     *************************************
C=======================================================================
C=======================================================================
C=======================================================================
C===============TWO DIMENSIONAL SAMPLER VESK2W==========================
C=======================================================================
C=======================================================================
C=======================================================================
C                         VESK2W                                       C
C  GENERAL PURPOSE ROUTINE TO GENERATE AN ARBITRARY TWO DIMENSIONAL    C
C  DISTRIBUTION SUPPLIED BY USER IN A FORM OF FUNCTION FUNSKO(X,Y)     C
C                 WRITTEN NOVEMBER 1985                                C
C                    BY S. JADACH                                      C
C                 LAST UPDATE:  07.NOV.1990                            C
C                 version with weighted event....                      C
C======================================================================C
C VESKO2 GENERATES TWO DIMENSIONAL DISTRIBUTION DEFINED BY ARBITRARY
C FUNCTION FUNSKO(X,Y) WHERE X,Y BELONG  TO (0,1) RANGE.
C THE METHOD CONSISTS IN DIVIDING UNIT PLAQUET INTO CELLS USING
C SORT OF 'LIFE-GAME' METHOD IN WHICH THE DIVISION OF A CELLS IS MADE
C (DURING INITIALISATION) ALWAYS FOR THIS CELL WHICH CONTAINS
C A MAXIMUM VALUE OF THE INTEGRAL OVER FUNSKO IN THE CELL.
C RESULTING CELLS CONTAIN (USUALLY UP TO FACTOR TWO) EQUAL INTERGRAL
C VALUE. THE GENERATION CONSISTS IN CHOOSING RANDOMLY  A CELL
C ACCORDING TO ITS CONTENT AND THEN IN GENERATING X,Y WITHIN THE CELL.
C REJECTION METHOD IS APPLIED AT THE END OF THE PROCEDURE IN ORDER TO
C ASSURE THAT X,Y ARE DISTRIBUTED PRECISELY ACCORDING TO FUNSKO(X,Y)
C                    PARAMETERS
C -/ MODE = -1 INITIALISATION, NO (X,Y) GENERATED, CALL VESKO2(-1,D1,D2)
C    HAS TO BE MADE PRIOR  TO GENERATING FIRST (X,Y) PAIR
C -/ MODE =  0 GENERATION OF (X,Y) PAIR BY CALL VESKO2(0,X,Y)
C -/ MODE =  1 CALL VESKO2(1,VALINT,ERRINT) MAY BE DONE AFTER LAST
C    (X,Y) WAS GENERATED IN ORDER TO OBTAIN THE VALUE OF THE INTEGRAL
C    VALINT AND ITS ERROR ERRINT, INTEGRAL IS CALCULATED USING AVERAGE
C    WEIGHTS ENCOUTERED DURING GENERATION PHASE
C -/ X,Y  IF MODE=-1 THE THEY ARE DUMMY
C         IF MODE= 0 THE RESULT OF RANDOM GENERATION ACCORDING TO
C                    FUNCTION FUNSKO, X AND Y BELONG TO (0,1)
C         IF MODE= 1 X= VALUE OF INTEGRAL AND Y=ERROR (RELATIVE)
C                    WT = crude x-section
C ------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      save
      PARAMETER( JLIM1 = 64, JLIM2 = 1000 , NOUT = 6 )
      COMMON / VESW2  / XX(JLIM2,2),DX(JLIM2,2),YY(JLIM2,2,2)
     $  ,YYMX(JLIM2),ZINT(JLIM2),ZSUM,LEV(JLIM2),JMAX
      DOUBLE PRECISION DRVEC(100)
      EXTERNAL FUNSKO
      DATA IWARM/77/

      IF(MODE) 100,200,300
C...  INITIALISATION PART, SEE VINSKO FOR MORE COMMENTS
  100 CALL VINSKW(FUNSKO)
      IWARM=0
      WT=0D0
      WTMAX = 1D0
      WTMXX = WTMAX
      NEVOV=0
      SWT=0D0
      SSWT=0D0
      NEVS=0
C(((((((((((((
C     CALL HBOOK1(1, 16H WT-VESKO2     $,75,0.0D0,1.5D0)
C     CALL HMINIM(1,0)
C     CALL HBOOK2(2,16H X-Y VESKO2    $, 64,0,1, 32,0,1,0)
C     CALL HSCALE(2)
C))))))))))))
      RETURN
C...
  200 CONTINUE
C...  GENERATION PART
      IF(IWARM.EQ.77) GO TO 980
cc    IF(WT.GT.WTMAX) THEN
cc      write(6,*) ' vesko2: ev. overweighted, dont worry, wt=',wt
cc      WT=WT-WTMAX
cc      NEVOV=NEVOV+1
cc    ELSE
        CALL VARRAN(DRVEC,3)
        R = DRVEC(1)
        DO 215 J=1,JMAX
        JSTOP=J
  215   IF(ZINT(J).GT.R) GOTO 216
  216   CONTINUE
        XR=XX(JSTOP,1)+DX(JSTOP,1)*DRVEC(2)
        YR=XX(JSTOP,2)+DX(JSTOP,2)*DRVEC(3)
        FN=FUNSKO(XR,YR)
        IF(FN.LT.0.) GOTO 999
        YYMAX=YYMX(JSTOP)
        WT=FN/YYMAX
        WTMXX = MAX(WTMXX,WT)
cc      IF(NEVS.LE.(4*JLIM2).AND.WT.GT.WTMAX) THEN
cc         WTMAX=WT*1.1D0
cc         WRITE(6,*) ' VESKO2: NEVS, new WTMAX= ',NEVS,WTMAX
cc      ENDIF
        NEVS=NEVS+1
        SWT=SWT+WT
        SSWT=SSWT+WT*WT
C((((((((((
C       CALL HFILL(1,WT,0D0,1D0)
C))))))))))
ccc   ENDIF
CCC    CALL VARRAN(DRVEC,1)
ccc    RN=DRVEC(1)
ccc   IF(WTMAX*RN.GT.WT) GOTO 200
      X=XR
      Y=YR
C((((((((((
C     CALL HFILL(2,XR,YR)
C))))))))))
      RETURN
C...
  300 CONTINUE
C THIS IS THE VALUE OF THE INTEGRAL
      CINTEG=ZSUM*SWT/NEVS
C AND ITS ERROR
      ERRINT=SQRT(SSWT/SWT**2-1D0/NEVS)
      X=CINTEG
      Y=ERRINT
      WT=ZSUM
C((((((((((
C     CALL HPRINT(1)
C     CALL HDELET(1)
C     CALL HPRINT(2)
C     CALL HDELET(2)
      PRINT 7000,NEVS,NEVOV,WTMAX,WTMXX
 7000 FORMAT(' VESK2W: NEVS,NEVOV,WTMAX,WTMXX= ',2I7,2F7.3)
C))))))))))
      RETURN
  980 WRITE(NOUT,9002)
 9002 FORMAT(' **** STOP IN VESK2W, LACK OF INITIALISATION   ')
      STOP
  999 WRITE(NOUT,9004)
 9004 FORMAT(' **** STOP IN VESK2W, NEGATIVE VALUE OF FUNSKO ')
      STOP
      END

      SUBROUTINE VINSKW(FUNSKO)
C     *************************
C THIS ROUTINE BELONGS TO VESKO2 PACKAGE
C JLIM1 IS THE NUMBER OF CELLS, DIVISION OF THE UNIT PLAQUE INTO CELLS
C IS MADE IN THE FIRST STAGE.    JLIM2 IS THE TOTAL MAXIMUM
C NUMBER OF CELLS, NOTE THAT DIMENSIONS OF
C MATRICES IN /VESKOA/ SHOULD BE AT LEAST JLIM2
C     **********************************
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      save
C ------------------------------------------------------------
      PARAMETER( JLIM1 = 64, JLIM2 = 1000 , NOUT = 6 )
      COMMON / VESW2  / XX(JLIM2,2),DX(JLIM2,2),YY(JLIM2,2,2)
     $  ,YYMX(JLIM2),ZINT(JLIM2),ZSUM,LEV(JLIM2),JMAX
      EXTERNAL FUNSKO

C...  INITIALISATION PART, SAMPLING DISTRIBUTION FUNSKO
C...  AND FILLING MATRICES XX,YY,ZINT ETC.
      JMAX=1
      XX(1,1)=0D0
      XX(1,2)=0D0
      DX(1,1)=1D0
      DX(1,2)=1D0
      LEV(1)=1
      SUM=0D0
      DO 150 I=1,2
      DO 150 K=1,2
C... THIS IS NOT ELEGANT BUT SIMPLE
      YY(1,I,K)=FUNSKO(XX(1,1)+(I-1.)*DX(1,1),XX(1,2)+(K-1.)*DX(1,2))
      IF(YY(1,I,K).LT.0.0) GO TO 999
  150 SUM=SUM+YY(1,I,K)
      ZINT(1)=SUM*DX(1,1)*DX(1,2)/4D0

      JDIV=1
      DO 200 KK=1,JLIM2-1
      IF(JMAX.LT.JLIM1) THEN
C...    NOTE THAT DIVSKW INCREMENTS JMAX=JMAX+1 IN EVERY CALL
        CALL DIVSKW(JDIV,FUNSKO)
C(((((((((((
c      IF(JMAX.EQ.JLIM1) THEN
c      PRINT 9900,JMAX,(LEV(I),I=1,JMAX)
c 9900 FORMAT(///,' JMAX...  LEV LEV LEV LEV LEV',I10,/(24I5))
c      PRINT 9901,((XX(JD,I),I=1,2),JD=1,JMAX)
c 9901 FORMAT('  XX XX XX XX XX XX XX  ',/(10E12.5))
c      PRINT 9902,((DX(JD,I),I=1,2),JD=1,JMAX)
c 9902 FORMAT('  DX  DX DX DX DX DX ',/(10E12.5))
c      PRINT 9903,(((YY(JD,I,K),I=1,2),K=1,2),JD=1,JMAX)
c 9903 FORMAT('  YY  YY YY YY YY YY ',/(8E15.5))
c      PRINT 9904,(ZINT(I),I=1,JMAX)
c 9904 FORMAT('   ZINT ZINT ZINT ZINT ',/(10E12.5))
c      ENDIF
C))))))))))))
        JDIV=JDIV+2
        IF(JDIV.GT.JMAX) JDIV=1
      ELSE
        JDIV=1
        ZMX=ZINT(1)
        DO 180 J=1,JMAX
        IF(ZMX.LT.ZINT(J)) THEN
          ZMX=ZINT(J)
          JDIV=J
        ENDIF
  180   CONTINUE
        CALL DIVSKW(JDIV,FUNSKO)
      ENDIF
  200 CONTINUE

C(((((((((((
c      JPRN=64
c      PRINT 9910,JMAX,(LEV(I),I=1,JMAX)
c 9910 FORMAT(/,' JMAX...  LEV LEV LEV LEV LEV',I10,/(24I5))
c      IF(JMAX.LE.JPRN) PRINT 9911,((XX(JD,I),I=1,2),JD=1,JMAX)
c 9911 FORMAT('  XX XX XX XX XX XX XX  ',/(10E12.5))
c      IF(JMAX.LE.JPRN) PRINT 9912,((DX(JD,I),I=1,2),JD=1,JMAX)
c 9912 FORMAT('  DX  DX DX DX DX DX ',/(10E12.5))
c      IF(JMAX.LE.JPRN) PRINT 9913,(((YY(JD,I,K),I=1,2),K=1,2),JD=1,JMAX)
c 9913 FORMAT('  YY  YY YY YY YY YY ',/(8E15.5))
c      IF(JMAX.LE.JPRN) PRINT 9914,(ZINT(I),I=1,JMAX)
c 9914 FORMAT('   ZINT ZINT ZINT ZINT ',/(10E12.5))
C     DO 902 J=1,JMAX
C     Z=1D0*J-.5D0
C 902 CALL HFILL(202,Z,ZINT(J))
C))))))))))))
C...  FINAL ADMINISTRATION, NORMALIZING ZINT ETC.
      ZSUM1=0D0
      ZSUM =0D0
      DO 260 J=1,JMAX
      ZSUM1=ZSUM1+ZINT(J)
      YMAX= 0D0
      DO 250 I=1,2
      DO 250 K=1,2
  250 YMAX= MAX(YMAX,YY(J,I,K))
      YYMX(J)=YMAX
      ZINT(J)=YMAX*DX(J,1)*DX(J,2)
  260 ZSUM=ZSUM+ZINT(J)
C((((((((
      ZR=ZSUM1/ZSUM
      PRINT 7000,ZR
 7000 FORMAT(' /////// ZSUM1/ZSUM= ',F20.8)
C)))))))))
      SUM=0D0
      DO 240 J=1,JMAX
      SUM=SUM+ZINT(J)
  240 ZINT(J)=SUM/ZSUM
C(((((((((((
c     JPRN=64
c     PRINT 9932,JMAX
c9932 FORMAT(/'=====JMAX ZINT ZINT ZINT  ',I10)
c     IF(JMAX.LE.JPRN) PRINT 9935,(ZINT(I),I=1,JMAX)
c9935            FORMAT(10E12.5)
C     DO 901 J=2,JMAX
C 901 CALL HFILL(201,(ZINT(J)-ZINT(J-1))*JMAX)
C     CALL HFILL(201,ZINT(1)*JMAX)
C))))))))))))
      RETURN
  999 WRITE(NOUT,9000)
 9000 FORMAT(' **** STOP IN VINSKW, NEGATIVE VALUE OF FUNSKO ')
      STOP
      END

      SUBROUTINE DIVSKW(JD,FUNSKO)
C     ****************************
C THIS ROUTINE BELONGS TO VESKO2 PACKAGE
C IT SUBDIVIDES ONE CELL (NO. JD) INTO TWO EQUAL SIZE CELLS
C     **********************************
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      save
C ------------------------------------------------------------
      PARAMETER( JLIM1 = 64, JLIM2 = 1000 , NOUT = 6 )
      COMMON / VESW2  / XX(JLIM2,2),DX(JLIM2,2),YY(JLIM2,2,2)
     $  ,YYMX(JLIM2),ZINT(JLIM2),ZSUM,LEV(JLIM2),JMAX
      EXTERNAL FUNSKO

C...  MOOVE TO MAKE A HOLE FOR A NEW ENTRY (ONE ADDITIONAL CELL)
      DO 100 J=JMAX,JD,-1
      ZINT(J+1)=ZINT(J)
      LEV(J+1)=LEV(J)
      DO 100 I=1,2
      XX(J+1,I)  =XX(J,I)
      DX(J+1,I)  =DX(J,I)
      DO 100 K=1,2
  100 YY(J+1,I,K)  =YY(J,I,K)
C...  CREATE TWO NEW CELLS AND STORE THEM
      LL= MOD(LEV(JD),2)+1
      DX(JD,LL)=DX(JD,LL)/2D0
      DX(JD+1,LL)=DX(JD+1,LL)/2D0
      XX(JD+1,LL)=XX(JD,LL)+DX(JD,LL)
      IF(LL.EQ.1) THEN
        DO 150 I=1,2
C... THIS IS NOT ELEGANT, PROBABLY COULD BE DONE BETTER
        YY(JD,2,I)=FUNSKO(XX(JD,1)+DX(JD,1),XX(JD,2)+(I-1.)*DX(JD,2))
  150   YY(JD+1,1,I)=YY(JD,2,I)
      ELSE
        DO 152 I=1,2
        YY(JD,I,2)=FUNSKO(XX(JD,1)+(I-1.)*DX(JD,1),XX(JD,2)+DX(JD,2))
  152   YY(JD+1,I,1)=YY(JD,I,2)
      ENDIF
C...  ESTIMATE THE INTEGRALS OVER NEW CELLS RESULTING FROM DIVISION
      DO 220 JDV=JD,JD+1
      LEV(JDV)=LEV(JDV)+1
      SUM=0D0
      DO 210 I=1,2
      DO 210 K=1,2
      IF(YY(JDV,I,K).LT.0.D0) GO TO 999
  210 SUM=SUM+YY(JDV,I,K)
  220 ZINT(JDV) =SUM*DX(JDV,1)*DX(JDV,2)/4D0
      JMAX=JMAX+1
      RETURN
  999 WRITE(NOUT,9000)
 9000 FORMAT(' **** STOP IN DIVSKW, NEGATIVE VALUE OF FUNSKO ')
      STOP
      END


      SUBROUTINE GAUSJD(FUN,AA,BB,EEPS,RESULT)
C     ****************************************
C Gauss integration by S. Jadach, Oct. 90.
C This is NON-ADAPTIVE (!!!!) UNOPTIMIZED (!!!) integration subprogram.
C     *************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION WG(12),XX(12)
      COMMON / INOUT  / NINP,NOUT
      EXTERNAL FUN
      save /inout/,wg,xx,ITERMX
      DATA WG
     $/0.101228536290376D0, 0.222381034453374D0, 0.313706645877887D0,
     $ 0.362683783378362D0, 0.027152459411754D0, 0.062253523938648D0,
     $ 0.095158511682493D0, 0.124628971255534D0, 0.149595988816577D0,
     $ 0.169156519395003D0, 0.182603415044924D0, 0.189450610455069D0/
      DATA XX
     $/0.960289856497536D0, 0.796666477413627D0, 0.525532409916329D0,
     $ 0.183434642495650D0, 0.989400934991650D0, 0.944575023073233D0,
     $ 0.865631202387832D0, 0.755404408355003D0, 0.617876244402644D0,
     $ 0.458016777657227D0, 0.281603550779259D0, 0.095012509837637D0/
      DATA ITERMX / 15/
      EPS=ABS(EEPS)
      A=AA
      B=BB
      NDIVI=1
C iteration over subdivisions terminated by precision requirement
      DO 400 ITER=1,ITERMX
      CALK8  =0D0
      CALK16 =0D0
C sum over DELTA subintegrals
      DO 200 K = 1,NDIVI
      DELTA = (B-A)/NDIVI
      X1    =  A + (K-1)*DELTA
      X2    =  X1+ DELTA
      XMIDLE= 0.5D0*(X2+X1)
      RANGE = 0.5D0*(X2-X1)
      SUM8 =0D0
      SUM16=0D0
C 8- and 12-point   Gauss integration over single DELTA subinterval
      DO 100 I=1,12
      XPLUS= XMIDLE+RANGE*XX(I)
      XMINU= XMIDLE-RANGE*XX(I)
      FPLUS=FUN(XPLUS)
      FMINU=FUN(XMINU)
      IF(I.LE.4) THEN
          SUM8 =SUM8  +(FPLUS+FMINU)*WG(I)/2D0
      ELSE
          SUM16=SUM16 +(FPLUS+FMINU)*WG(I)/2D0
      ENDIF
  100 CONTINUE
      CALK8 = CALK8 + SUM8 *(X2-X1)
      CALK16= CALK16+ SUM16*(X2-X1)
  200 CONTINUE
      ERABS = ABS(CALK16-CALK8)
      ERELA = 0D0
      IF(CALK16.NE.0D0) ERELA= ERABS/ABS(CALK16)
c     write(6,*) 'gausjd: CALK8,CALK16=',ITER,CALK8,CALK16,ERELA
C precision check to terminate integration
      IF(EEPS.GT.0D0) THEN
        IF(ERABS.LT. EPS) GOTO 800
      ELSE
        IF(ERELA.LT. EPS) GOTO 800
      ENDIF
  400 NDIVI=NDIVI*2
      WRITE(NOUT,*) ' +++++ GAUSJD:  REQUIRED PRECISION TO HIGH!'
      WRITE(NOUT,*) ' +++++ GAUSJD:  ITER,ERELA=',ITER,ERELA
  800 RESULT= CALK16
      END


      SUBROUTINE WMONIT(MODE,ID,WT,WTMAX,RN)
C     **************************************
C last correction 19 sept. 89
C Utility program for monitoring M.C. rejection weights.
C ID is weight idendifier, maximum IDMX (defined below).
C WT IS WEIGHT, WTMAX IS MAXIMUM WEIGHT AND RN IS RANDOM NUMBER.
C IF(MODE.EQ.-1) THEN
C          INITALIZATION IF ENTRY ID, OTHER ARGUMENTS ARE IGNORED
C ELSEIF(MODE.EQ.0) THEN
C          SUMMING UP WEIGHTS ETC. FOR A GIVEN EVENT FOR ENTRY ID
C        - WT IS CURRENT WEIGHT.
C        - WTMAX IS MAXIMUM WEIGHT USED FOR COUTING OVERWEIGHTED
C          EVENTS WITH WT>WTMAX.
C        - RN IS RANDOM NUMBER USED IN REJECTION, IT IS USED TO
C          COUNT NO. OF ACCEPTED (RN<WT/WTMAX) AND REJECTED
C          (WT>WT/WTMAX) EVENTS,
C          IF RO REJECTION THEN PUT RN=0D0.
C ELSEIF(MODE.EQ.1) THEN
C          IN THIS MODE WMONIT REPPORTS ON ACCUMULATED STATISTICS
C          AND THE INFORMATION IS STORED IN COMMON /CMONIT/
C        - AVERWT= AVERAGE WEIGHT WT COUNTING ALL EVENT
C        - ERRELA= RELATIVE ERROR OF AVERWT
C        - NEVTOT= TOTAL NIMBER OF ACCOUNTED EVENTS
C        - NEVACC= NO. OF ACCEPTED EVENTS (RN<WT\WTMAX)
C        - NEVNEG= NO. OF EVENTS WITH NEGATIVE WEIGHT (WT<0)
C        - NEVZER= NO. OF EVENTS WITH ZERO WEIGHT (WT.EQ.0D0)
C        - NEVOVE= NO. OF OVERWEGHTED EVENTS (WT>WTMAX)
C          AND IF YOU DO NOT WANT TO USE CMONIT THEN THE VALUE
C          The value of AVERWT is assigned to WT,
C          the value of ERRELA is assigned to WTMAX and
C          the value of WTMAX  is assigned to RN in this mode.
C ELSEIF(MODEE.EQ.2) THEN
C          ALL INFORMATION DEFINED FOR ENTRY ID DEFINED ABOVE
C          FOR MODE=2 IS JUST PRINTED OF UNIT NOUT
C ENDIF
C NOTE THAT OUTPUT REPPORT (MODE=1,2) IS DONE DYNAMICALLY JUST FOR A
C GIVEN ENTRY ID ONLY AND IT MAY BE REPEATED MANY TIMES FOR ONE ID AND
C FOR VARIOUS ID'S AS WELL.
C     ************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      save
      PARAMETER(IDMX=100)
      COMMON / CMONIT/ AVERWT,ERRELA,NEVTOT,NEVACC,NEVNEG,NEVOVE,NEVZER
      COMMON / INOUT  / NINP,NOUT
      INTEGER NTOT(IDMX),NACC(IDMX),NNEG(IDMX),NOVE(IDMX),NZER(IDMX)
      DIMENSION SWT(IDMX),SSWT(IDMX),WWMX(IDMX)
      DATA NTOT /IDMX* -1/  SWT /IDMX*   0D0/
      DATA SSWT /IDMX*0D0/ WWMX /IDMX*-1D-20/
C
      IF(ID.LE.0.OR.ID.GT.IDMX) THEN
           WRITE(NOUT,*) ' =====WMONIT: WRONG ID',ID
           STOP
      ENDIF
      IF(MODE.EQ.-1) THEN
           NTOT(ID)=0
           NACC(ID)=0
           NNEG(ID)=0
           NZER(ID)=0
           NOVE(ID)=0
           SWT(ID)   =0D0
           SSWT(ID)  =0D0
           WWMX(ID)  = -1D-20
      ELSEIF(MODE.EQ.0) THEN
           IF(NTOT(ID).LT.0) THEN
              WRITE(NOUT,*) ' ==== WARNING FROM WMONIT: '
              WRITE(NOUT,*) ' LACK OF INITIALIZATION, ID=',ID
           ENDIF
           NTOT(ID)=NTOT(ID)+1
           SWT(ID)=SWT(ID)+WT
           SSWT(ID)=SSWT(ID)+WT**2
           WWMX(ID)= MAX(WWMX(ID),WT)
           IF(WT.EQ.0D0)   NZER(ID)=NZER(ID)+1
           IF(WT.LT.0D0)   NNEG(ID)=NNEG(ID)+1
           IF(WT.GT.WTMAX)      NOVE(ID)=NOVE(ID)+1
           IF(RN*WTMAX.LE.WT)   NACC(ID)=NACC(ID)+1
      ELSEIF(MODE.EQ.1) THEN
           IF(NTOT(ID).LT.0) THEN
              WRITE(NOUT,*) ' ==== WARNING FROM WMONIT: '
              WRITE(NOUT,*) ' LACK OF INITIALIZATION, ID=',ID
           ENDIF
           IF(NTOT(ID).LE.0.OR.SWT(ID).EQ.0D0)  THEN
              AVERWT=0D0
              ERRELA=0D0
           ELSE
              AVERWT=SWT(ID)/FLOAT(NTOT(ID))
              ERRELA=SQRT(ABS(SSWT(ID)/SWT(ID)**2-1D0/FLOAT(NTOT(ID))))
           ENDIF
           NEVTOT=NTOT(ID)
           NEVACC=NACC(ID)
           NEVNEG=NNEG(ID)
           NEVZER=NZER(ID)
           NEVOVE=NOVE(ID)
           WT=AVERWT
           WTMAX=ERRELA
           RN    =WWMX(ID)
      ELSEIF(MODE.EQ.2) THEN
           IF(NTOT(ID).LE.0.OR.SWT(ID).EQ.0D0)  THEN
              AVERWT=0D0
              ERRELA=0D0
           ELSE
              AVERWT=SWT(ID)/FLOAT(NTOT(ID))
              ERRELA=SQRT(ABS(SSWT(ID)/SWT(ID)**2-1D0/FLOAT(NTOT(ID))))
              WWMAX=WWMX(ID)
           ENDIF
           WRITE(NOUT,1003) ID, AVERWT, ERRELA, WWMAX
           WRITE(NOUT,1004) NTOT(ID),NACC(ID),NNEG(ID),NOVE(ID),NZER(ID)
           WT=AVERWT
           WTMAX=ERRELA
           RN    =WWMX(ID)
      ELSE
           WRITE(NOUT,*) ' =====WMONIT: WRONG MODE',MODE
           STOP
      ENDIF
 1003 FORMAT(
     $  ' =======================WMONIT========================'
     $/,'   ID           AVERWT         ERRELA            WWMAX'
     $/,    I5,           E17.7,         F15.9,           E17.7)
 1004 FORMAT(
     $  ' -----------------------------------------------------------'
     $/,'      NEVTOT      NEVACC      NEVNEG      NEVOVE      NEVZER'
     $/,   5I12)
      END

      SUBROUTINE WMONI2(MODE,ID,WT,WTMAX,RN)
C     **************************************
C -------------- SECOND COPY OF WMONIT ----------------
C last correction 19 sept. 89
C Utility program for monitoring M.C. rejection weights.
C ID is weight idendifier, maximum IDMX (defined below).
C WT IS WEIGHT, WTMAX IS MAXIMUM WEIGHT AND RN IS RANDOM NUMBER.
C IF(MODE.EQ.-1) THEN
C          INITALIZATION IF ENTRY ID, OTHER ARGUMENTS ARE IGNORED
C ELSEIF(MODE.EQ.0) THEN
C          SUMMING UP WEIGHTS ETC. FOR A GIVEN EVENT FOR ENTRY ID
C        - WT IS CURRENT WEIGHT.
C        - WTMAX IS MAXIMUM WEIGHT USED FOR COUTING OVERWEIGHTED
C          EVENTS WITH WT>WTMAX.
C        - RN IS RANDOM NUMBER USED IN REJECTION, IT IS USED TO
C          COUNT NO. OF ACCEPTED (RN<WT/WTMAX) AND REJECTED
C          (WT>WT/WTMAX) EVENTS,
C          IF RO REJECTION THEN PUT RN=0D0.
C ELSEIF(MODE.EQ.1) THEN
C          IN THIS MODE WMONIT REPPORTS ON ACCUMULATED STATISTICS
C          AND THE INFORMATION IS STORED IN COMMON /CMONIT/
C        - AVERWT= AVERAGE WEIGHT WT COUNTING ALL EVENT
C        - ERRELA= RELATIVE ERROR OF AVERWT
C        - NEVTOT= TOTAL NIMBER OF ACCOUNTED EVENTS
C        - NEVACC= NO. OF ACCEPTED EVENTS (RN<WT\WTMAX)
C        - NEVNEG= NO. OF EVENTS WITH NEGATIVE WEIGHT (WT<0)
C        - NEVZER= NO. OF EVENTS WITH ZERO WEIGHT (WT.EQ.0D0)
C        - NEVOVE= NO. OF OVERWEGHTED EVENTS (WT>WTMAX)
C          AND IF YOU DO NOT WANT TO USE CMONIT THEN THE VALUE
C          The value of AVERWT is assigned to WT,
C          the value of ERRELA is assigned to WTMAX and
C          the value of WTMAX  is assigned to RN in this mode.
C ELSEIF(MODEE.EQ.2) THEN
C          ALL INFORMATION DEFINED FOR ENTRY ID DEFINED ABOVE
C          FOR MODE=2 IS JUST PRINTED OF UNIT NOUT
C ENDIF
C NOTE THAT OUTPUT REPPORT (MODE=1,2) IS DONE DYNAMICALLY JUST FOR A
C GIVEN ENTRY ID ONLY AND IT MAY BE REPEATED MANY TIMES FOR ONE ID AND
C FOR VARIOUS ID'S AS WELL.
C     ************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      save
      PARAMETER(IDMX=100)
      COMMON / CMONI2/ AVERWT,ERRELA,NEVTOT,NEVACC,NEVNEG,NEVOVE,NEVZER
      COMMON / INOUT  / NINP,NOUT
      INTEGER NTOT(IDMX),NACC(IDMX),NNEG(IDMX),NOVE(IDMX),NZER(IDMX)
      DIMENSION SWT(IDMX),SSWT(IDMX),WWMX(IDMX)
      DATA NTOT /IDMX* -1/  SWT /IDMX*   0D0/
      DATA SSWT /IDMX*0D0/ WWMX /IDMX*-1D-20/
C
      IF(ID.LE.0.OR.ID.GT.IDMX) THEN
           WRITE(NOUT,*) ' =====WMONI2: WRONG ID',ID
           STOP
      ENDIF
      IF(MODE.EQ.-1) THEN
           NTOT(ID)=0
           NACC(ID)=0
           NNEG(ID)=0
           NZER(ID)=0
           NOVE(ID)=0
           SWT(ID)   =0D0
           SSWT(ID)  =0D0
           WWMX(ID)  = -1D-20
      ELSEIF(MODE.EQ.0) THEN
           IF(NTOT(ID).LT.0) THEN
              WRITE(NOUT,*) ' ==== WARNING FROM WMONIT: '
              WRITE(NOUT,*) ' LACK OF INITIALIZATION, ID=',ID
           ENDIF
           NTOT(ID)=NTOT(ID)+1
           SWT(ID)=SWT(ID)+WT
           SSWT(ID)=SSWT(ID)+WT**2
           WWMX(ID)= MAX(WWMX(ID),WT)
           IF(WT.EQ.0D0)   NZER(ID)=NZER(ID)+1
           IF(WT.LT.0D0)   NNEG(ID)=NNEG(ID)+1
           IF(WT.GT.WTMAX)      NOVE(ID)=NOVE(ID)+1
           IF(RN*WTMAX.LE.WT)   NACC(ID)=NACC(ID)+1
      ELSEIF(MODE.EQ.1) THEN
           IF(NTOT(ID).LT.0) THEN
              WRITE(NOUT,*) ' ==== WARNING FROM WMONI2: '
              WRITE(NOUT,*) ' LACK OF INITIALIZATION, ID=',ID
           ENDIF
           IF(NTOT(ID).LE.0.OR.SWT(ID).EQ.0D0)  THEN
              AVERWT=0D0
              ERRELA=0D0
           ELSE
              AVERWT=SWT(ID)/FLOAT(NTOT(ID))
              ERRELA=SQRT(ABS(SSWT(ID)/SWT(ID)**2-1D0/FLOAT(NTOT(ID))))
           ENDIF
           NEVTOT=NTOT(ID)
           NEVACC=NACC(ID)
           NEVNEG=NNEG(ID)
           NEVZER=NZER(ID)
           NEVOVE=NOVE(ID)
           WT=AVERWT
           WTMAX=ERRELA
           RN    =WWMX(ID)
      ELSEIF(MODE.EQ.2) THEN
           IF(NTOT(ID).LE.0.OR.SWT(ID).EQ.0D0)  THEN
              AVERWT=0D0
              ERRELA=0D0
           ELSE
              AVERWT=SWT(ID)/FLOAT(NTOT(ID))
              ERRELA=SQRT(ABS(SSWT(ID)/SWT(ID)**2-1D0/FLOAT(NTOT(ID))))
              WWMAX=WWMX(ID)
           ENDIF
           WRITE(NOUT,1003) ID, AVERWT, ERRELA, WWMAX
           WRITE(NOUT,1004) NTOT(ID),NACC(ID),NNEG(ID),NOVE(ID),NZER(ID)
           WT=AVERWT
           WTMAX=ERRELA
           RN    =WWMX(ID)
      ELSE
           WRITE(NOUT,*) ' =====WMONI2: WRONG MODE',MODE
           STOP
      ENDIF
 1003 FORMAT(
     $  ' =======================WMONI2========================'
     $/,'   ID           AVERWT         ERRELA            WWMAX'
     $/,    I5,           E17.7,         F15.9,           E17.7)
 1004 FORMAT(
     $  ' -----------------------------------------------------------'
     $/,'      NEVTOT      NEVACC      NEVNEG      NEVOVE      NEVZER'
     $/,   5I12)
      END

      FUNCTION GAUS(F,A,B,EEPS)
C     *************************
C THIS IS ITERATIVE INTEGRATION PROCEDURE
C ORIGINATES  PROBABLY FROM CERN LIBRARY
C IT SUBDIVIDES INEGRATION RANGE UNTIL REQUIRED PRECISION IS REACHED
C PRECISION IS A DIFFERENCE FROM 8 AND 16 POINT GAUSS ITEGR. RESULT
C EEPS POSITIVE TREATED AS ABSOLUTE PRECISION
C EEPS NEGATIVE TREATED AS RELATIVE PRECISION
C     *************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION W(12),X(12)
      COMMON / INOUT  / NINP,NOUT
      EXTERNAL F
      DATA CONST /1.0D-19/
      save     / INOUT/, CONST, W, X
      DATA W
     1/0.10122 85362 90376, 0.22238 10344 53374, 0.31370 66458 77887,
     2 0.36268 37833 78362, 0.02715 24594 11754, 0.06225 35239 38648,
     3 0.09515 85116 82493, 0.12462 89712 55534, 0.14959 59888 16577,
     4 0.16915 65193 95003, 0.18260 34150 44924, 0.18945 06104 55069/
      DATA X
     1/0.96028 98564 97536, 0.79666 64774 13627, 0.52553 24099 16329,
     2 0.18343 46424 95650, 0.98940 09349 91650, 0.94457 50230 73233,
     3 0.86563 12023 87832, 0.75540 44083 55003, 0.61787 62444 02644,
     4 0.45801 67776 57227, 0.28160 35507 79259, 0.09501 25098 37637/
      EPS=ABS(EEPS)
      DELTA=CONST*ABS(A-B)
      GAUS=0D0
      AA=A
    5 Y=B-AA
      IF(ABS(Y) .LE. DELTA) RETURN
    2 BB=AA+Y
      C1=0.5D0*(AA+BB)
      C2=C1-AA
      S8=0D0
      S16=0D0
      DO 1 I=1,4
      U=X(I)*C2
    1 S8=S8+W(I)*(F(C1+U)+F(C1-U))
      DO 3 I=5,12
      U=X(I)*C2
    3 S16=S16+W(I)*(F(C1+U)+F(C1-U))
      S8=S8*C2
      S16=S16*C2
      IF(EEPS.LT.0D0) THEN
        IF(ABS(S16-S8) .GT. EPS*ABS(S16)) GO TO 4
      ELSE
        IF(ABS(S16-S8) .GT. EPS) GO TO 4
      ENDIF
      GAUS=GAUS+S16
      AA=BB
      GO TO 5
    4 Y=0.5D0*Y
      IF(ABS(Y) .GT. DELTA) GOTO 2
      WRITE(NOUT,7)
      GAUS=0D0
      RETURN
    7 FORMAT(1X,36HGAUS  ... TOO HIGH ACCURACY REQUIRED)
      END


      DOUBLE PRECISION FUNCTION DILOGY(X)
C-------------------------------------------- REMARKS ---------------
C DILOGARITHM FUNCTION: DILOG(X)=INT( -LN(1-Z)/Z ) , 0 < Z < X .
C THIS IS THE CERNLIB VERSION.
C--------------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      Z=-1.644934066848226D0
      IF(X .LT.-1.D0) GO TO 1
      IF(X .LE. 0.5D0) GO TO 2
      IF(X .EQ. 1.D0) GO TO 3
      IF(X .LE. 2.D0) GO TO 4
      Z=3.289868133696453D0
    1 T=1.D0/X
      S=-0.5D0
      Z=Z-0.5D0*DLOG(DABS(X))**2
      GO TO 5
    2 T=X
      S=0.5D0
      Z=0.D0
      GO TO 5
    3 DILOGY=1.644934066848226D0
      RETURN
    4 T=1.D0-X
      S=-0.5D0
      Z=1.644934066848226D0-DLOG(X)*DLOG(DABS(T))
    5 Y=2.666666666666667D0*T+0.666666666666667D0
      B=      0.000000000000001D0
      A=Y*B  +0.000000000000004D0
      B=Y*A-B+0.000000000000011D0
      A=Y*B-A+0.000000000000037D0
      B=Y*A-B+0.000000000000121D0
      A=Y*B-A+0.000000000000398D0
      B=Y*A-B+0.000000000001312D0
      A=Y*B-A+0.000000000004342D0
      B=Y*A-B+0.000000000014437D0
      A=Y*B-A+0.000000000048274D0
      B=Y*A-B+0.000000000162421D0
      A=Y*B-A+0.000000000550291D0
      B=Y*A-B+0.000000001879117D0
      A=Y*B-A+0.000000006474338D0
      B=Y*A-B+0.000000022536705D0
      A=Y*B-A+0.000000079387055D0
      B=Y*A-B+0.000000283575385D0
      A=Y*B-A+0.000001029904264D0
      B=Y*A-B+0.000003816329463D0
      A=Y*B-A+0.000014496300557D0
      B=Y*A-B+0.000056817822718D0
      A=Y*B-A+0.000232002196094D0
      B=Y*A-B+0.001001627496164D0
      A=Y*B-A+0.004686361959447D0
      B=Y*A-B+0.024879322924228D0
      A=Y*B-A+0.166073032927855D0
      A=Y*A-B+1.935064300869969D0
      DILOGY=S*T*(A-B)+Z
      END


      DOUBLE PRECISION FUNCTION DPGAMM(Z)
C     **********************************
C Double precision Gamma function
      DOUBLE PRECISION Z,Z1,X,X1,X2,D1,D2,S1,S2,S3,PI,C(20),CONST
      save C,PI,CONST
      DATA C( 1) / 8.3333333333333333333333333332D-02/
      DATA C( 2) /-2.7777777777777777777777777777D-03/
      DATA C( 3) / 7.9365079365079365079365079364D-04/
      DATA C( 4) /-5.9523809523809523809523809523D-04/
      DATA C( 5) / 8.4175084175084175084175084175D-04/
      DATA C( 6) /-1.9175269175269175269175269175D-03/
      DATA C( 7) / 6.4102564102564102564102564102D-03/
      DATA C( 8) /-2.9550653594771241830065359477D-02/
      DATA C( 9) / 1.7964437236883057316493849001D-01/
      DATA C(10) /-1.3924322169059011164274322169D+00/
      DATA C(11) / 1.3402864044168391994478951001D+01/
      DATA C(12) /-1.5684828462600201730636513245D+02/
      DATA C(13) / 2.1931033333333333333333333333D+03/
      DATA C(14) /-3.6108771253724989357173265219D+04/
      DATA C(15) / 6.9147226885131306710839525077D+05/
      DATA C(16) /-1.5238221539407416192283364959D+07/
      DATA C(17) / 3.8290075139141414141414141414D+08/
      DATA C(18) /-1.0882266035784391089015149165D+10/
      DATA C(19) / 3.4732028376500225225225225224D+11/
      DATA C(20) /-1.2369602142269274454251710349D+13/
      DATA PI    / 3.1415926535897932384626433832D+00/
      DATA CONST / 9.1893853320467274178032973641D-01/
      IF(Z.GT.5.75D 1)                                     GOTO  6666
      NN = Z
      IF (Z  -  DBLE(FLOAT(NN)))                 3,1,3
    1 IF (Z    .LE.    0.D 0)                    GOTO 6667
      DPGAMM = 1.D 0
      IF (Z    .LE.    2.D 0)                    RETURN
      Z1 = Z
    2 Z1 = Z1  -  1.D 0
      DPGAMM = DPGAMM * Z1
      IF (Z1  -  2.D 0)                          61,61,2
    3 IF (DABS(Z)    .LT.    1.D-29)             GOTO 60
      IF (Z    .LT.    0.D 0)                    GOTO 4
      X  = Z
      KK = 1
      GOTO 10
    4 X  = 1.D 0  -  Z
      KK = 2
   10 X1 = X
      IF (X    .GT.    19.D 0)                   GOTO 13
      D1 = X
   11 X1 = X1  +  1.D 0
      IF (X1    .GE.    19.D 0)                  GOTO 12
      D1 = D1 * X1
      GOTO 11
   12 S3 = -DLOG(D1)
      GOTO 14
   13 S3 = 0.D 0
   14 D1 = X1 * X1
      S1 = (X1  -  5.D-1) * DLOG(X1)  -  X1  +  CONST
      DO 20                  K=1,20
      S2 = S1  +  C(K)/X1
      IF (DABS(S2  -  S1)    .LT.    1.D-28)     GOTO 21
      X1 = X1 * D1
   20 S1 = S2
   21 S3 = S3  +  S2
      GOTO (50,22),    KK
   22 D2 = DABS(Z  -  NN)
      D1 = D2 * PI
      IF (D1    .LT.    1.D-15)                  GOTO 31
   30 X2 =  DLOG(PI/DSIN(D1))  -  S3
      GOTO 40
   31 X2 = -DLOG(D2)
   40 MM = DABS(Z)
      IF(X2      .GT.      1.74D2)                         GO TO 6666
      DPGAMM = DEXP(X2)
      IF (MM    .NE.    (MM/2) * 2)              RETURN
      DPGAMM = -DPGAMM
      RETURN
   50 IF(S3      .GT.      1.74D2)                         GO TO 6666
      DPGAMM = DEXP(S3)
      RETURN
 6666 PRINT *, 2000
      RETURN
 6667 PRINT *, 2001
      RETURN
   60 DPGAMM = 0.D 0
      IF(DABS(Z)   .LT.   1.D-77)   RETURN
      DPGAMM = 1.D 0/Z
   61 RETURN
 2000 FORMAT (/////, 2X, 32HDPGAMM ..... ARGUMENT TOO LARGE., /////)
 2001 FORMAT (/////, 2X, 32HDPGAMM ..... ARGUMENT IS A POLE., /////)
      END




C=======================================================================
C=======================================================================
C=======================================================================
C==Received: by dxmint.cern.ch (cernvax) (5.57/3.14)
C== id AA13405; Wed, 23 Jan 91 17:19:06 +0100
C==Message-Id: <9101231619.AA13405@dxmint.cern.ch>
C==Received: by cernapo; Wed, 23 Jan 91 17:23:40 +0100
C==Received: by apojames.cern.ch; Wed, 23 Jan 91 17:05:23 CET
C==Date: Wed, 23 Jan 91 17:05:23 CET
C==From: james@cernapo.cern.ch (Frederick James)
C==To: jadach@cernvm
C==Subject: Random generators
C==
C==      PROGRAM PSEUDORAN
C==C  CPC # ABTK                                           CPC # ABTK
C==C         Pseudorandom generator demonstration (test case)
C==      DIMENSION RVEC(1000)
C==      DIMENSION VERI(5), ISD25(25)
C==C
C==C
C==C   ................................................
C==      WRITE(6,'(20X,A)') 'DEMONSTRATION OF PSEUDORANDOM GENERATORS'
C==      WRITE(6,'(20X,A)') 'MACHINE/SYSTEM: date:'
C==      WRITE(6,'(/20X,A/)') 'INITIALIZATION AND TEST OF PORTABILITY'
C==C   ................................................
C==C
C==C                   initialization and verification  RANMAR
C==        DO 40 I9= 1, 20
C==   40   CALL RANMAR(RVEC,1000)
C==      CALL RANMAR(RVEC,5)
C==      DO 41 I= 1 ,5
C==   41 VERI(I) = (4096.*RVEC(I))*(4096.)
C==      WRITE(6,'(A,5F12.1/)') '  RANMAR 20001  ',VERI
C==C
C==C                   initialization and verification  RANECU
C==      CALL RANECU(RVEC,1000)
C==      CALL RANECU(VERI,5)
C==      DO 52 I= 1 ,5
C==   52 VERI(I) = 4096.*(4096.*VERI(I))
C==      WRITE(6,'(A,5F12.1/)') '  RANECU 1001   ',VERI
C==C
C==C                   initialization and verification  RCARRY
C==      CALL RCARRY(RVEC,1000)
C==      CALL RCARRY(VERI,5)
C==      DO 62 I= 1 ,5
C==   62 VERI(I) = 4096.*(4096.*VERI(I))
C==      WRITE(6,'(A,5F12.1/)') '  RCARRY 1001   ',VERI
C==C
C==      WRITE(6,'(//20X,A/)') 'TEST OF REPEATABILITY'
C==C  .................................................
C==C                  verify restarting      RANMAR
C==      WRITE(6,'(/A)') '   THE NEXT LINE SHOULD BE REPEATED:'
C==      CALL RMARUT(IMAR1,IMAR2,IMAR3)
C==      CALL RANMAR(RVEC,777)
C==      CALL RANMAR(VERI,5)
C==      WRITE(6,'(A,5F12.9)') '       RANMAR 1 ',VERI
C==      CALL RMARIN(IMAR1,IMAR2,IMAR3)
C==      CALL RANMAR(RVEC,777)
C==      CALL RANMAR(VERI,5)
C==      WRITE(6,'(A,5F12.9)') '       RANMAR 2 ',VERI
C==C
C==C                  verify restarting      RANECU
C==      WRITE(6,'(/A)') '   THE NEXT LINE SHOULD BE REPEATED:'
C==      CALL RECUUT(IS1,IS2)
C==      CALL RANECU(RVEC,777)
C==      CALL RANECU(VERI,5)
C==      WRITE(6,'(A,5F12.9)') '       RANECU 1 ',VERI
C==      CALL RECUIN(IS1,IS2)
C==      CALL RANECU(RVEC,777)
C==      CALL RANECU(VERI,5)
C==      WRITE(6,'(A,5F12.9)') '       RANECU 2 ',VERI
C==C
C==C                  verify restarting      RCARRY
C==      WRITE(6,'(/A)') '   THE NEXT LINE SHOULD BE REPEATED:'
C==      CALL RCARUT(ISD25)
C==      CALL RCARRY(RVEC,777)
C==      CALL RCARRY(VERI,5)
C==      WRITE(6,'(A,5F12.9)') '       RCARRY 1 ',VERI
C==      CALL RCARIN(ISD25)
C==      CALL RCARRY(RVEC,777)
C==      CALL RCARRY(VERI,5)
C==      WRITE(6,'(A,5F12.9)') '       RCARRY 2 ',VERI
C==C
C==      STOP
C==      END
C=======================================================================
C=======================================================================
C=======================================================================
      SUBROUTINE MARRAN(RVEC,LENV)
C =======================S. JADACH===================================
C == This commes from F. James, The name of RANMAR is changed to   ==
C == MARRAN in order to avoid interference with the version        ==
C == already in use and the public library version (if present).   ==
C ==      THIS IS THE ONLY MODIFICATION !!!!                       ==
C ========================S. JADACH==================================
C Universal random number generator proposed by Marsaglia and Zaman
C in report FSU-SCRI-87-50
C        modified by F. James, 1988 and 1989, to generate a vector
C        of pseudorandom numbers RVEC of length LENV, and to put in
C        the COMMON block everything needed to specify currrent state,
C        and to add input and output entry points MARINI, MAROUT.
C!!! ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C!!!  Calling sequences for RANMAR:                                  ++
C!!!      CALL RANMAR (RVEC, LEN)   returns a vector RVEC of LEN     ++
C!!!                   32-bit random floating point numbers between  ++
C!!!                   zero and one.                                 ++
C!!!      CALL MARINI(I1,N1,N2)   initializes the generator from one ++
C!!!                   32-bit integer I1, and number counts N1,N2    ++
C!!!                  (for initializing, set N1=N2=0, but to restart ++
C!!!                    a previously generated sequence, use values  ++
C!!!                    output by MAROUT)                            ++
C!!!      CALL MAROUT(I1,N1,N2)   outputs the value of the original  ++
C!!!                  seed and the two number counts, to be used     ++
C!!!                  for restarting by initializing to I1 and       ++
C!!!                  skipping N2*100000000+N1 numbers.              ++
C!!! ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      DIMENSION RVEC(*)
      COMMON/RASET1/U(97),C,I97,J97
      PARAMETER (MODCNS=1000000000)
      SAVE CD, CM, TWOM24, NTOT, NTOT2, IJKL
      DATA NTOT,NTOT2,IJKL/-1,0,0/
C
      IF (NTOT .GE. 0)  GO TO 50
C
C        Default initialization. User has called RANMAR without MARINI.
      IJKL = 54217137
      NTOT = 0
      NTOT2 = 0
      KALLED = 0
      GO TO 1
C
      ENTRY      MARINI(IJKLIN, NTOTIN,NTOT2N)
C         Initializing routine for RANMAR, may be called before
C         generating pseudorandom numbers with RANMAR. The input
C         values should be in the ranges:  0<=IJKLIN<=900 OOO OOO
C                                          0<=NTOTIN<=999 999 999
C                                          0<=NTOT2N<<999 999 999!
C To get the standard values in Marsaglia's paper, IJKLIN=54217137
C                                            NTOTIN,NTOT2N=0
      IJKL = IJKLIN
      NTOT = MAX(NTOTIN,0)
      NTOT2= MAX(NTOT2N,0)
      KALLED = 1
C          always come here to initialize
    1 CONTINUE
      IJ = IJKL/30082
      KL = IJKL - 30082*IJ
      I = MOD(IJ/177, 177) + 2
      J = MOD(IJ, 177)     + 2
      K = MOD(KL/169, 178) + 1
      L = MOD(KL, 169)
      WRITE(6,'(A,5I10)')
     $' MARran INITIALIZED:IJ,KL,IJKL,NTOT,NTOT2=',IJ,KL,IJKL,NTOT,NTOT2
      DO 2 II= 1, 97
      S = 0.
      T = .5
      DO 3 JJ= 1, 24
         M = MOD(MOD(I*J,179)*K, 179)
         I = J
         J = K
         K = M
         L = MOD(53*L+1, 169)
         IF (MOD(L*M,64) .GE. 32)  S = S+T
    3    T = 0.5*T
    2 U(II) = S
      TWOM24 = 1.0
      DO 4 I24= 1, 24
    4 TWOM24 = 0.5*TWOM24
      C  =   362436.*TWOM24
      CD =  7654321.*TWOM24
      CM = 16777213.*TWOM24
      I97 = 97
      J97 = 33
C       Complete initialization by skipping
C            (NTOT2*MODCNS + NTOT) random numbers
      DO 45 LOOP2= 1, NTOT2+1
      NOW = MODCNS
      IF (LOOP2 .EQ. NTOT2+1)  NOW=NTOT
      IF (NOW .GT. 0)  THEN
        WRITE(6,'(A,I15)') ' MARINI SKIPPING OVER ',NOW
       DO 40 IDUM = 1, NTOT
       UNI = U(I97)-U(J97)
       IF (UNI .LT. 0.)  UNI=UNI+1.
       U(I97) = UNI
       I97 = I97-1
       IF (I97 .EQ. 0)  I97=97
       J97 = J97-1
       IF (J97 .EQ. 0)  J97=97
       C = C - CD
       IF (C .LT. 0.)  C=C+CM
   40  CONTINUE
      ENDIF
   45 CONTINUE
      IF (KALLED .EQ. 1)  RETURN
C
C          Normal entry to generate LENV random numbers
   50 CONTINUE
      DO 100 IVEC= 1, LENV
      UNI = U(I97)-U(J97)
      IF (UNI .LT. 0.)  UNI=UNI+1.
      U(I97) = UNI
      I97 = I97-1
      IF (I97 .EQ. 0)  I97=97
      J97 = J97-1
      IF (J97 .EQ. 0)  J97=97
      C = C - CD
      IF (C .LT. 0.)  C=C+CM
      UNI = UNI-C
      IF (UNI .LT. 0.) UNI=UNI+1.
      RVEC(IVEC) = UNI
C             Replace exact zeros by uniform distr. *2**-24
         IF (UNI .EQ. 0.)  THEN
         ZUNI = TWOM24*U(2)
C             An exact zero here is very unlikely, but let's be safe.
         IF (ZUNI .EQ. 0.) ZUNI= TWOM24*TWOM24
         RVEC(IVEC) = ZUNI
         ENDIF
  100 CONTINUE
      NTOT = NTOT + LENV
         IF (NTOT .GE. MODCNS)  THEN
         NTOT2 = NTOT2 + 1
         NTOT = NTOT - MODCNS
         ENDIF
      RETURN
C           Entry to output current status
      ENTRY MAROUT(IJKLUT,NTOTUT,NTOT2T)
      IJKLUT = IJKL
      NTOTUT = NTOT
      NTOT2T = NTOT2
      RETURN
      END
      SUBROUTINE CARRAN(RVEC,LENV)
C         Add-and-carry random number generator proposed by
C         Marsaglia and Zaman in SIAM J. Scientific and Statistical
C             Computing, to appear probably 1990.
C         modified with enhanced initialization by F. James, 1990
C!!! ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C!!!  Calling sequences for CARRAN:                                  ++
C!!!      CALL CARRAN (RVEC, LEN)   returns a vector RVEC of LEN     ++
C!!!                   32-bit random floating point numbers between  ++
C!!!                   zero and one.                                 ++
C!!!      CALL CARINI(INT)     initializes the generator from one    ++
C!!!                   32-bit integer INT                            ++
C!!!      CALL CARRES(IVEC)    restarts the generator from vector    ++
C!!!                   IVEC of 25 32-bit integers (see CAROUT)       ++
C!!!      CALL CAROUT(IVEC)    outputs the current values of the 25  ++
C!!!                 32-bit integer seeds, to be used for restarting ++
C!!! ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      DIMENSION RVEC(LENV)
      DIMENSION SEEDS(24), ISEEDS(24), ISDEXT(25)
      PARAMETER (TWOP12=4096.)
      PARAMETER (ITWO24=2**24, ICONS=2147483563)
      SAVE NOTYET, I24, J24, CARRY, SEEDS, TWOM24
      LOGICAL NOTYET
      DATA NOTYET/.TRUE./
      DATA I24,J24,CARRY/24,10,0./
C
C              Default Initialization by Multiplicative Congruential
      IF (NOTYET) THEN
         NOTYET = .FALSE.
         JSEED = 314159265
         WRITE(6,'(A,I12)') ' CARRAN DEFAULT INITIALIZATION: ',JSEED
            TWOM24 = 1.
         DO 25 I= 1, 24
            TWOM24 = TWOM24 * 0.5
         K = JSEED/53668
         JSEED = 40014*(JSEED-K*53668) -K*12211
         IF (JSEED .LT. 0)  JSEED = JSEED+ICONS
         ISEEDS(I) = MOD(JSEED,ITWO24)
   25    CONTINUE
         DO 50 I= 1,24
         SEEDS(I) = REAL(ISEEDS(I))*TWOM24
   50    CONTINUE
         I24 = 24
         J24 = 10
         CARRY = 0.
         IF (SEEDS(24) .LT. SEEDS(14)) CARRY = TWOM24
      ENDIF
C
C          The Generator proper: "Subtract-with-borrow",
C          as proposed by Marsaglia and Zaman,
C          Florida State University, March, 1989
C
      DO 100 IVEC= 1, LENV
      UNI = SEEDS(I24) - SEEDS(J24) - CARRY
      IF (UNI .LT. 0.)  THEN
         UNI = UNI + 1.0
         CARRY = TWOM24
      ELSE
         CARRY = 0.
      ENDIF
      SEEDS(I24) = UNI
      I24 = I24 - 1
      IF (I24 .EQ. 0)  I24 = 24
      J24 = J24 - 1
      IF (J24 .EQ. 0)  J24 = 24
      RVEC(IVEC) = UNI
  100 CONTINUE
      RETURN
C           Entry to input and float integer seeds from previous run
      ENTRY CARRES(ISDEXT)
         TWOM24 = 1.
         DO 195 I= 1, 24
  195    TWOM24 = TWOM24 * 0.5
      WRITE(6,'(A)') ' FULL INITIALIZATION OF CARRAN WITH 25 INTEGERS:'
      WRITE(6,'(5X,5I12)') ISDEXT
      DO 200 I= 1, 24
      SEEDS(I) = REAL(ISDEXT(I))*TWOM24
  200 CONTINUE
      CARRY = REAL(MOD(ISDEXT(25),10))*TWOM24
      ISD = ISDEXT(25)/10
      I24 = MOD(ISD,100)
      ISD = ISD/100
      J24 = ISD
      RETURN
C                    Entry to ouput seeds as integers
      ENTRY CAROUT(ISDEXT)
      DO 300 I= 1, 24
         ISDEXT(I) = INT(SEEDS(I)*TWOP12*TWOP12)
  300 CONTINUE
      ICARRY = 0
      IF (CARRY .GT. 0.)  ICARRY = 1
      ISDEXT(25) = 1000*J24 + 10*I24 + ICARRY
      RETURN
C                    Entry to initialize from one integer
      ENTRY CARINI(INSEED)
      JSEED = INSEED
      WRITE(6,'(A,I12)') ' CARRAN INITIALIZED FROM SEED ',INSEED
C      TWOM24 = 1.
         DO 325 I= 1, 24
           TWOM24 = TWOM24 * 0.5
         K = JSEED/53668
         JSEED = 40014*(JSEED-K*53668) -K*12211
         IF (JSEED .LT. 0)  JSEED = JSEED+ICONS
         ISEEDS(I) = MOD(JSEED,ITWO24)
  325    CONTINUE
         DO 350 I= 1,24
         SEEDS(I) = REAL(ISEEDS(I))*TWOM24
  350    CONTINUE
         I24 = 24
         J24 = 10
         CARRY = 0.
         IF (SEEDS(24) .LT. SEEDS(14)) CARRY = TWOM24
      RETURN
      END

      SUBROUTINE ECURAN(RVEC,LEN)
C         Random number generator given by L'Ecuyer in
C            Comm. ACM Vol 31, p.742, 1988
C            modified by F. James to return a vector of numbers
C!!! ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C!!!  Calling sequences for ECURAN:                                  ++
C!!!      CALL ECURAN (RVEC, LEN)   returns a vector RVEC of LEN     ++
C!!!                   32-bit random floating point numbers between  ++
C!!!                   zero and one.                                 ++
C!!!      CALL ECUINI(I1,I2)    initializes the generator from two   ++
C!!!                   32-bit integers I1 and I2                     ++
C!!!      CALL ECUOUT(I1,I2)    outputs the current values of the    ++
C!!!                   two integer seeds, to be used for restarting  ++
C!!! ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      DIMENSION RVEC(*)
      SAVE ISEED1,ISEED2
      DATA ISEED1,ISEED2 /12345,67890/
C
      DO 100 I= 1, LEN
      K = ISEED1/53668
      ISEED1 = 40014*(ISEED1 - K*53668) - K*12211
      IF (ISEED1 .LT. 0) ISEED1=ISEED1+2147483563
C
      K = ISEED2/52774
      ISEED2 = 40692*(ISEED2 - K*52774) - K* 3791
      IF (ISEED2 .LT. 0) ISEED2=ISEED2+2147483399
C
      IZ = ISEED1 - ISEED2
      IF (IZ .LT. 1)  IZ = IZ + 2147483562
C
      RVEC(I) = REAL(IZ) * 4.656613E-10
  100 CONTINUE
      RETURN
C
      ENTRY ECUINI(IS1,IS2)
      ISEED1 = IS1
      ISEED2 = IS2
      RETURN
C
      ENTRY ECUOUT(IS1,IS2)
      IS1 = ISEED1
      IS2 = ISEED2
      RETURN
      END

      SUBROUTINE VARRAN(DRVEC,LEN)
C     ***************************
C Switchable random number generator
C Translation to double precision
C     ***************************
      COMMON / RANPAR / KEYRND
      save   / RANPAR /
      DOUBLE PRECISION DRVEC(*)
      DIMENSION RVEC(1000)
      IF(LEN.LT.1.OR.LEN.GT.1000) GOTO 901
   10 CONTINUE
      IF(KEYRND.EQ.1) THEN
CBB         CALL MARRAN(RVEC,LEN)
          CALL RANMAR(RVEC,LEN)
      ELSEIF(KEYRND.EQ.2) THEN
         CALL ECURAN(RVEC,LEN)
      ELSEIF(KEYRND.EQ.3) THEN
         CALL CARRAN(RVEC,LEN)
      ELSE
         GOTO 902
      ENDIF
C random numbers 0 and 1 not accepted
      DO 30 I=1,LEN
      IF(RVEC(I).LE.0E0.OR.RVEC(I).GE.1E0) THEN
        WRITE(6,*) ' +++++ VARRAN: RVEC=',RVEC(I)
        GOTO 10
      ENDIF
      DRVEC(I)=RVEC(I)
   30 CONTINUE
      RETURN
  901 WRITE(6,*) ' +++++ STOP IN VARRAN: LEN=',LEN
      STOP
  902 WRITE(6,*) ' +++++ STOP IN VARRAN: WRONG KEYRND',KEYRND
      STOP
      END

      SUBROUTINE BOSTDQ(MODE,QQ,PP,R)
C     *******************************
C BOOST ALONG ARBITRARY AXIS (BY RONALD KLEISS).
C P BOOSTED INTO R  FROM ACTUAL FRAME TO REST FRAME OF Q
C FORTH (MODE = 1) OR BACK (MODE = -1).
C Q MUST BE A TIMELIKE, P MAY BE ARBITRARY.
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER ( NOUT =6 )
      DIMENSION QQ(*),PP(*),R(*)
      DIMENSION Q(4),P(4)

      DO 10 K=1,4
      P(K)=PP(K)
   10 Q(K)=QQ(K)
      AMQ =DSQRT(Q(4)**2-Q(1)**2-Q(2)**2-Q(3)**2)
      IF    (MODE.EQ.-1) THEN
         R(4) = (P(1)*Q(1)+P(2)*Q(2)+P(3)*Q(3)+P(4)*Q(4))/AMQ
         FAC  = (R(4)+P(4))/(Q(4)+AMQ)
      ELSEIF(MODE.EQ. 1) THEN
         R(4) =(-P(1)*Q(1)-P(2)*Q(2)-P(3)*Q(3)+P(4)*Q(4))/AMQ
         FAC  =-(R(4)+P(4))/(Q(4)+AMQ)
      ELSE
         WRITE(NOUT,*) ' ++++++++ WRONG MODE IN BOOST3 '
         STOP
      ENDIF
      R(1)=P(1)+FAC*Q(1)
      R(2)=P(2)+FAC*Q(2)
      R(3)=P(3)+FAC*Q(3)
      END


C BOOST ALONG X AXIS, EXE=EXP(ETA), ETA= HIPERBOLIC VELOCITY.
      SUBROUTINE BOSTD1(EXE,PVEC,QVEC)
C     ********************************
      IMPLICIT REAL*8(A-H,O-Z)
      REAL*8 PVEC(4),QVEC(4),RVEC(4)
      DO 10 I=1,4
  10  RVEC(I)=PVEC(I)
      RPL=RVEC(4)+RVEC(1)
      RMI=RVEC(4)-RVEC(1)
      QPL=RPL*EXE
      QMI=RMI/EXE
      QVEC(2)=RVEC(2)
      QVEC(3)=RVEC(3)
      QVEC(1)=(QPL-QMI)/2
      QVEC(4)=(QPL+QMI)/2
      END

      SUBROUTINE DUMPT(NUNIT,WORD,PP)
C     *******************************
      IMPLICIT REAL*8(A-H,O-Z)
      CHARACTER*8 WORD
      REAL*8 PP(4)
      AMS=PP(4)**2-PP(3)**2-PP(2)**2-PP(1)**2
      IF(AMS.GT.0.0) AMS=SQRT(AMS)
      WRITE(NUNIT,'(1X,A8,5(1X,F13.8))') WORD,(PP(I),I=1,4),AMS
C======================================================================
C================END OF YFSLIB=========================================
C======================================================================
      END
C=============================================================
C=============================================================
C==== end of directory ===== =================================
C=============================================================
C=============================================================
      FUNCTION FORMOM(XMAA,XMOM)
C     ==================================================================
C     formfactorfor pi-pi0 gamma final state
C      R. Decker, Z. Phys C36 (1987) 487.
C     ==================================================================
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / DECPAR / GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL*4            GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      COMMON /TESTA1/ KEYA1
      COMPLEX BWIGN,FORMOM
      DATA ICONT /1/
* THIS INLINE FUNCT. CALCULATES THE SCALAR PART OF THE PROPAGATOR
      BWIGN(XM,AM,GAMMA)=1./CMPLX(XM**2-AM**2,GAMMA*AM)
* HADRON CURRENT
      FRO  =0.266*AMRO**2
      ELPHA=- 0.1
      AMROP = 1.7
      GAMROP= 0.26
      AMOM  =0.782
      GAMOM =0.0085
      AROMEG= 1.0
      GCOUP=12.924
      GCOUP=GCOUP*AROMEG
      FQED  =SQRT(4.0*3.1415926535/137.03604)
      FORMOM=FQED*FRO**2/SQRT(2.0)*GCOUP**2*BWIGN(XMOM,AMOM,GAMOM)
     $     *(BWIGN(XMAA,AMRO,GAMRO)+ELPHA*BWIGN(XMAA,AMROP,GAMROP))
     $     *(BWIGN( 0.0,AMRO,GAMRO)+ELPHA*BWIGN( 0.0,AMROP,GAMROP))
      END
      FUNCTION FORM1(MNUM,QQ,S1,SDWA)
C     ==================================================================
C     formfactorfor F1 for 3 scalar final state
C     R. Fisher, J. Wess and F. Wagner Z. Phys C3 (1980) 313
C     H. Georgi, Weak interactions and modern particle theory,
C     The Benjamin/Cummings Pub. Co., Inc. 1984.
C     R. Decker, E. Mirkes, R. Sauer, Z. Was Karlsruhe preprint TTP92-25
C     and erratum !!!!!!
C     ==================================================================
C
      COMPLEX FORM1,WIGNER,WIGFOR,FPIKM,BWIGM
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      WIGNER(A,B,C)= CMPLX(1.0,0.0)/CMPLX(A-B**2,B*C)
      IF     (MNUM.EQ.0) THEN
C ------------  3 pi hadronic state (a1)
       GAMAX=GAMA1*GFUN(QQ)/GFUN(AMA1**2)
       FORM1=AMA1**2*WIGNER(QQ,AMA1,GAMAX)*FPIKM(SQRT(S1),AMPI,AMPI)
      ELSEIF (MNUM.EQ.1) THEN
C ------------ K- pi- K+
       FORM1=BWIGM(S1,AMKST,GAMKST,AMPI,AMK)
         GAMAX=GAMA1*GFUN(QQ)/GFUN(AMA1**2)
       FORM1=AMA1**2*WIGNER(QQ,AMA1,GAMAX)*FORM1
      ELSEIF (MNUM.EQ.2) THEN
C ------------ K0 pi- K0B
       FORM1=BWIGM(S1,AMKST,GAMKST,AMPI,AMK)
         GAMAX=GAMA1*GFUN(QQ)/GFUN(AMA1**2)
       FORM1=AMA1**2*WIGNER(QQ,AMA1,GAMAX)*FORM1
      ELSEIF (MNUM.EQ.3) THEN
C ------------ K- K0 pi0
       FORM1=0.0
         GAMAX=GAMA1*GFUN(QQ)/GFUN(AMA1**2)
       FORM1=AMA1**2*WIGNER(QQ,AMA1,GAMAX)*FORM1
      ELSEIF (MNUM.EQ.4) THEN
C ------------ pi0 pi0 K-
       XM2=1.402
       GAM2=0.174
       FORM1=BWIGM(S1,AMKST,GAMKST,AMK,AMPI)
       FORM1=WIGFOR(QQ,XM2,GAM2)*FORM1
      ELSEIF (MNUM.EQ.5) THEN
C ------------ K- pi- pi+
       XM2=1.402
       GAM2=0.174
       FORM1=WIGFOR(QQ,XM2,GAM2)*FPIKM(SQRT(S1),AMPI,AMPI)
      ELSEIF (MNUM.EQ.6) THEN
       FORM1=0.0
      ELSEIF (MNUM.EQ.7) THEN
C -------------- eta pi- pi0 final state
       FORM1=0.0
      ENDIF
C
      END
      FUNCTION FORM2(MNUM,QQ,S1,SDWA)
C     ==================================================================
C     formfactorfor F2 for 3 scalar final state
C     R. Fisher, J. Wess and F. Wagner Z. Phys C3 (1980) 313
C     H. Georgi, Weak interactions and modern particle theory,
C     The Benjamin/Cummings Pub. Co., Inc. 1984.
C     R. Decker, E. Mirkes, R. Sauer, Z. Was Karlsruhe preprint TTP92-25
C     and erratum !!!!!!
C     ==================================================================
C
      COMPLEX FORM2,WIGNER,WIGFOR,FPIKM,BWIGM
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      WIGNER(A,B,C)= CMPLX(1.0,0.0)/CMPLX(A-B**2,B*C)
      IF     (MNUM.EQ.0) THEN
C ------------  3 pi hadronic state (a1)
       GAMAX=GAMA1*GFUN(QQ)/GFUN(AMA1**2)
       FORM2=AMA1**2*WIGNER(QQ,AMA1,GAMAX)*FPIKM(SQRT(S1),AMPI,AMPI)
      ELSEIF (MNUM.EQ.1) THEN
C ------------ K- pi- K+
         GAMAX=GAMA1*GFUN(QQ)/GFUN(AMA1**2)
       FORM2=AMA1**2*WIGNER(QQ,AMA1,GAMAX)*FPIKM(SQRT(S1),AMPI,AMPI)
      ELSEIF (MNUM.EQ.2) THEN
C ------------ K0 pi- K0B
         GAMAX=GAMA1*GFUN(QQ)/GFUN(AMA1**2)
       FORM2=AMA1**2*WIGNER(QQ,AMA1,GAMAX)*FPIKM(SQRT(S1),AMPI,AMPI)
      ELSEIF (MNUM.EQ.3) THEN
C ------------ K- K0 pi0
         GAMAX=GAMA1*GFUN(QQ)/GFUN(AMA1**2)
       FORM2=AMA1**2*WIGNER(QQ,AMA1,GAMAX)*FPIKM(SQRT(S1),AMPI,AMPI)
      ELSEIF (MNUM.EQ.4) THEN
C ------------ pi0 pi0 K-
       XM2=1.402
       GAM2=0.174
       FORM2=BWIGM(S1,AMKST,GAMKST,AMK,AMPI)
       FORM2=WIGFOR(QQ,XM2,GAM2)*FORM2
      ELSEIF (MNUM.EQ.5) THEN
C ------------ K- pi- pi+
       XM2=1.402
       GAM2=0.174
       FORM2=BWIGM(S1,AMKST,GAMKST,AMK,AMPI)
       FORM2=WIGFOR(QQ,XM2,GAM2)*FORM2
C
      ELSEIF (MNUM.EQ.6) THEN
       XM2=1.402
       GAM2=0.174
       FORM2=WIGFOR(QQ,XM2,GAM2)*FPIKM(SQRT(S1),AMPI,AMPI)
C
      ELSEIF (MNUM.EQ.7) THEN
C -------------- eta pi- pi0 final state
       FORM2=0.0
      ENDIF
C
      END
      COMPLEX FUNCTION BWIGM(S,M,G,XM1,XM2)
C **********************************************************
C     P-WAVE BREIT-WIGNER  FOR RHO
C **********************************************************
      REAL S,M,G,XM1,XM2
      REAL PI,QS,QM,W,GS
      DATA INIT /0/
C ------------ PARAMETERS --------------------
      IF (INIT.EQ.0) THEN
      INIT=1
      PI=3.141592654
C -------  BREIT-WIGNER -----------------------
         ENDIF
       IF (S.GT.(XM1+XM2)**2) THEN
         QS=SQRT(ABS((S   -(XM1+XM2)**2)*(S   -(XM1-XM2)**2)))/SQRT(S)
         QM=SQRT(ABS((M**2-(XM1+XM2)**2)*(M**2-(XM1-XM2)**2)))/M
         W=SQRT(S)
         GS=G*(M/W)**2*(QS/QM)**3
       ELSE
         GS=0.0
       ENDIF
         BWIGM=M**2/CMPLX(M**2-S,-SQRT(S)*GS)
      RETURN
      END
      COMPLEX FUNCTION FPIKM(W,XM1,XM2)
C **********************************************************
C     PION FORM FACTOR
C **********************************************************
      COMPLEX BWIGM
      REAL ROM,ROG,ROM1,ROG1,BETA1,PI,PIM,S,W
      EXTERNAL BWIG
      DATA  INIT /0/
C
C ------------ PARAMETERS --------------------
      IF (INIT.EQ.0 ) THEN
      INIT=1
      PI=3.141592654
      PIM=.140
      ROM=0.773
      ROG=0.145
      ROM1=1.370
      ROG1=0.510
      BETA1=-0.145
      ENDIF
C -----------------------------------------------
      S=W**2
      FPIKM=(BWIGM(S,ROM,ROG,XM1,XM2)+BETA1*BWIGM(S,ROM1,ROG1,XM1,XM2))
     & /(1+BETA1)
      RETURN
      END
      COMPLEX FUNCTION FPIKMD(W,XM1,XM2)
C **********************************************************
C     PION FORM FACTOR
C **********************************************************
      COMPLEX BWIGM
      REAL ROM,ROG,ROM1,ROG1,PI,PIM,S,W
      EXTERNAL BWIG
      DATA  INIT /0/
C
C ------------ PARAMETERS --------------------
      IF (INIT.EQ.0 ) THEN
      INIT=1
      PI=3.141592654
      PIM=.140
      ROM=0.773
      ROG=0.145
      ROM1=1.500
      ROG1=0.220
      ROM2=1.750
      ROG2=0.120
      BETA=6.5
      DELTA=-26.0
      ENDIF
C -----------------------------------------------
      S=W**2
      FPIKMD=(DELTA*BWIGM(S,ROM,ROG,XM1,XM2)
     $      +BETA*BWIGM(S,ROM1,ROG1,XM1,XM2)
     $      +     BWIGM(S,ROM2,ROG2,XM1,XM2))
     & /(1+BETA+DELTA)
      RETURN
      END

      FUNCTION FORM3(MNUM,QQ,S1,SDWA)
C     ==================================================================
C     formfactorfor F3 for 3 scalar final state
C     R. Fisher, J. Wess and F. Wagner Z. Phys C3 (1980) 313
C     H. Georgi, Weak interactions and modern particle theory,
C     The Benjamin/Cummings Pub. Co., Inc. 1984.
C     R. Decker, E. Mirkes, R. Sauer, Z. Was Karlsruhe preprint TTP92-25
C     and erratum !!!!!!
C     ==================================================================
C
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMPLEX FORM3
      IF (MNUM.EQ.6) THEN
       FORM3=CMPLX(0.0)
      ELSE
       FORM3=CMPLX(0.0)
      ENDIF
        FORM3=0
      END
      FUNCTION FORM4(MNUM,QQ,S1,S2,S3)
C     ==================================================================
C     formfactorfor F4 for 3 scalar final state
C     R. Decker, in preparation
C     R. Decker, E. Mirkes, R. Sauer, Z. Was Karlsruhe preprint TTP92-25
C     and erratum !!!!!!
C     ==================================================================
C
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMPLEX FORM4,WIGNER,FPIKM
      REAL*4 M
      WIGNER(A,B,C)=CMPLX(1.0,0.0) /CMPLX(A-B**2,B*C)
      IF (MNUM.EQ.0) THEN
C ------------  3 pi hadronic state (a1)
        G1=5.8
        G2=6.08
        FPIP=0.02
        AMPIP=1.3
        GAMPIP=0.3
        S=QQ
        G=GAMPIP
        XM1=AMPIZ
        XM2=AMRO
        M  =AMPIP
         IF (S.GT.(XM1+XM2)**2) THEN
           QS=SQRT(ABS((S   -(XM1+XM2)**2)*(S   -(XM1-XM2)**2)))/SQRT(S)
           QM=SQRT(ABS((M**2-(XM1+XM2)**2)*(M**2-(XM1-XM2)**2)))/M
           W=SQRT(S)
           GS=G*(M/W)**2*(QS/QM)**5
         ELSE
           GS=0.0
         ENDIF
        GAMX=GS*W/M
        FORM4=G1*G2*FPIP/AMRO**4/AMPIP**2
     $       *AMPIP**2*WIGNER(QQ,AMPIP,GAMX)
     $       *( S1*(S2-S3)*FPIKM(SQRT(S1),AMPIZ,AMPIZ)
     $         +S2*(S1-S3)*FPIKM(SQRT(S2),AMPIZ,AMPIZ) )
      ELSEIF (MNUM.EQ.1) THEN
C ------------  3 pi hadronic state (a1)
        G1=5.8
        G2=6.08
        FPIP=0.02
        AMPIP=1.3
        GAMPIP=0.3
        S=QQ
        G=GAMPIP
        XM1=AMPIZ
        XM2=AMRO
        M  =AMPIP
         IF (S.GT.(XM1+XM2)**2) THEN
           QS=SQRT(ABS((S   -(XM1+XM2)**2)*(S   -(XM1-XM2)**2)))/SQRT(S)
           QM=SQRT(ABS((M**2-(XM1+XM2)**2)*(M**2-(XM1-XM2)**2)))/M
           W=SQRT(S)
           GS=G*(M/W)**2*(QS/QM)**5
         ELSE
           GS=0.0
         ENDIF
        GAMX=GS*W/M
        FORM4=G1*G2*FPIP/AMRO**4/AMPIP**2
     $       *AMPIP**2*WIGNER(QQ,AMPIP,GAMX)
     $       *( S1*(S2-S3)*FPIKM(SQRT(S1),AMPIZ,AMPIZ)
     $         +S2*(S1-S3)*FPIKM(SQRT(S2),AMPIZ,AMPIZ) )
      ELSE
        FORM4=CMPLX(0.0,0.0)
      ENDIF
C ---- this formfactor is switched off .. .
       FORM4=CMPLX(0.0,0.0)
      END
      FUNCTION FORM5(MNUM,QQ,S1,S2)
C     ==================================================================
C     formfactorfor F5 for 3 scalar final state
C     G. Kramer, W. Palmer, S. Pinsky, Phys. Rev. D30 (1984) 89.
C     G. Kramer, W. Palmer             Z. Phys. C25 (1984) 195.
C     R. Decker, E. Mirkes, R. Sauer, Z. Was Karlsruhe preprint TTP92-25
C     and erratum !!!!!!
C     ==================================================================
C
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMPLEX FORM5,WIGNER,FPIKM,FPIKMD,BWIGM
      WIGNER(A,B,C)=CMPLX(1.0,0.0)/CMPLX(A-B**2,B*C)
      IF     (MNUM.EQ.0) THEN
C ------------  3 pi hadronic state (a1)
        FORM5=0.0
      ELSEIF (MNUM.EQ.1) THEN
C ------------ K- pi- K+
         ELPHA=-0.2
         FORM5=FPIKMD(SQRT(QQ),AMPI,AMPI)/(1+ELPHA)
     $        *(       FPIKM(SQRT(S2),AMPI,AMPI)
     $          +ELPHA*BWIGM(S1,AMKST,GAMKST,AMPI,AMK))
      ELSEIF (MNUM.EQ.2) THEN
C ------------ K0 pi- K0B
         ELPHA=-0.2
         FORM5=FPIKMD(SQRT(QQ),AMPI,AMPI)/(1+ELPHA)
     $        *(       FPIKM(SQRT(S2),AMPI,AMPI)
     $          +ELPHA*BWIGM(S1,AMKST,GAMKST,AMPI,AMK))
      ELSEIF (MNUM.EQ.3) THEN
C ------------ K- K0 pi0
        FORM5=0.0
      ELSEIF (MNUM.EQ.4) THEN
C ------------ pi0 pi0 K-
        FORM5=0.0
      ELSEIF (MNUM.EQ.5) THEN
C ------------ K- pi- pi+
        ELPHA=-0.2
        FORM5=BWIGM(QQ,AMKST,GAMKST,AMPI,AMK)/(1+ELPHA)
     $       *(       FPIKM(SQRT(S1),AMPI,AMPI)
     $         +ELPHA*BWIGM(S2,AMKST,GAMKST,AMPI,AMK))
      ELSEIF (MNUM.EQ.6) THEN
C ------------ pi- K0B pi0
        ELPHA=-0.2
        FORM5=BWIGM(QQ,AMKST,GAMKST,AMPI,AMKZ)/(1+ELPHA)
     $       *(       FPIKM(SQRT(S2),AMPI,AMPI)
     $         +ELPHA*BWIGM(S1,AMKST,GAMKST,AMPI,AMK))
      ELSEIF (MNUM.EQ.7) THEN
C -------------- eta pi- pi0 final state
       FORM5=FPIKMD(SQRT(QQ),AMPI,AMPI)*FPIKM(SQRT(S1),AMPI,AMPI)
      ENDIF
C
      END
      SUBROUTINE CURRX(MNUM,PIM1,PIM2,PIM3,PIM4,HADCUR)
C     ==================================================================
C     hadronic current for 4 pi final state
C     R. Fisher, J. Wess and F. Wagner Z. Phys C3 (1980) 313
C     R. Decker Z. Phys C36 (1987) 487.
C     M. Gell-Mann, D. Sharp, W. Wagner Phys. Rev. Lett 8 (1962) 261.
C     ==================================================================

      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / DECPAR / GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL*4            GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
C ARBITRARY FIXING OF THE FOUR PI X-SECTION NORMALIZATION
      COMMON /ARBIT/ ARFLAT,AROMEG
      REAL  PIM1(4),PIM2(4),PIM3(4),PIM4(4),PAA(4)
      COMPLEX HADCUR(4),FORM1,FORM2,FORM3,FPIKM
      COMPLEX BWIGN
      REAL PA(4),PB(4)
      REAL AA(4,4),PP(4,4)
      DATA PI /3.141592653589793238462643/
      DATA  FPI /93.3E-3/
      BWIGN(A,XM,XG)=1.0/CMPLX(A-XM**2,XM*XG)
C
C --- masses and constants
      G1=12.924
      G2=1475.98
      G =G1*G2
      ELPHA=-.1
      AMROP=1.7
      GAMROP=0.26
      AMOM=.782
      GAMOM=0.0085
      ARFLAT=1.0
      AROMEG=1.0
C
      FRO=0.266*AMRO**2
      COEF1=2.0*SQRT(3.0)/FPI**2*ARFLAT
      COEF2=FRO*G*AROMEG
C --- initialization of four vectors
      DO 7 K=1,4
      DO 8 L=1,4
 8    AA(K,L)=0.0
      HADCUR(K)=CMPLX(0.0)
      PAA(K)=PIM1(K)+PIM2(K)+PIM3(K)+PIM4(K)
      PP(1,K)=PIM1(K)
      PP(2,K)=PIM2(K)
      PP(3,K)=PIM3(K)
 7    PP(4,K)=PIM4(K)
C
      IF (MNUM.EQ.1) THEN
C ===================================================================
C pi- pi- p0 pi+ case                                            ====
C ===================================================================
       QQ=PAA(4)**2-PAA(3)**2-PAA(2)**2-PAA(1)**2
C --- loop over thre contribution of the non-omega current
       DO 201 K=1,3
        SK=(PP(K,4)+PIM4(4))**2-(PP(K,3)+PIM4(3))**2
     $    -(PP(K,2)+PIM4(2))**2-(PP(K,1)+PIM4(1))**2
C -- definition of AA matrix
C -- cronecker delta
        DO 202 I=1,4
         DO 203 J=1,4
 203     AA(I,J)=0.0
 202    AA(I,I)=1.0
C ... and the rest ...
        DO 204 L=1,3
         IF (L.NE.K) THEN
          DENOM=(PAA(4)-PP(L,4))**2-(PAA(3)-PP(L,3))**2
     $         -(PAA(2)-PP(L,2))**2-(PAA(1)-PP(L,1))**2
          DO 205 I=1,4
          DO 205 J=1,4
                      SIG= 1.0
           IF(J.NE.4) SIG=-SIG
           AA(I,J)=AA(I,J)
     $            -SIG*(PAA(I)-2.0*PP(L,I))*(PAA(J)-PP(L,J))/DENOM
 205      CONTINUE
         ENDIF
 204    CONTINUE
C --- let's add something to HADCURR
       FORM1= FPIKM(SQRT(SK),AMPI,AMPI) *FPIKM(SQRT(QQ),AMPI,AMPI)
C       FORM1= FPIKM(SQRT(SK),AMPI,AMPI) *FPIKMD(SQRT(QQ),AMPI,AMPI)
CCCCCCCCCCCCCCCCC       FORM1=WIGFOR(SK,AMRO,GAMRO)      (tests)
C
       FIX=1.0
       IF (K.EQ.3) FIX=-2.0
       DO 206 I=1,4
       DO 206 J=1,4
        HADCUR(I)=
     $  HADCUR(I)+CMPLX(FIX*COEF1)*FORM1*AA(I,J)*(PP(K,J)-PP(4,J))
 206   CONTINUE
C --- end of the non omega current (3 possibilities)
 201   CONTINUE
C
C
C --- there are two possibilities for omega current
C --- PA PB are corresponding first and second pi-'s
       DO 301 KK=1,2
        DO 302 I=1,4
         PA(I)=PP(KK,I)
         PB(I)=PP(3-KK,I)
 302    CONTINUE
C --- lorentz invariants
         QQA=0.0
         SS23=0.0
         SS24=0.0
         SS34=0.0
         QP1P2=0.0
         QP1P3=0.0
         QP1P4=0.0
         P1P2 =0.0
         P1P3 =0.0
         P1P4 =0.0
        DO 303 K=1,4
                     SIGN=-1.0
         IF (K.EQ.4) SIGN= 1.0
         QQA=QQA+SIGN*(PAA(K)-PA(K))**2
         SS23=SS23+SIGN*(PB(K)  +PIM3(K))**2
         SS24=SS24+SIGN*(PB(K)  +PIM4(K))**2
         SS34=SS34+SIGN*(PIM3(K)+PIM4(K))**2
         QP1P2=QP1P2+SIGN*(PAA(K)-PA(K))*PB(K)
         QP1P3=QP1P3+SIGN*(PAA(K)-PA(K))*PIM3(K)
         QP1P4=QP1P4+SIGN*(PAA(K)-PA(K))*PIM4(K)
         P1P2=P1P2+SIGN*PA(K)*PB(K)
         P1P3=P1P3+SIGN*PA(K)*PIM3(K)
         P1P4=P1P4+SIGN*PA(K)*PIM4(K)
 303    CONTINUE
C
        FORM2=COEF2*(BWIGN(QQ,AMRO,GAMRO)+ELPHA*BWIGN(QQ,AMROP,GAMROP))
C        FORM3=BWIGN(QQA,AMOM,GAMOM)*(BWIGN(SS23,AMRO,GAMRO)+
C     $        BWIGN(SS24,AMRO,GAMRO)+BWIGN(SS34,AMRO,GAMRO))
        FORM3=BWIGN(QQA,AMOM,GAMOM)
C
        DO 304 K=1,4
         HADCUR(K)=HADCUR(K)+FORM2*FORM3*(
     $             PB  (K)*(QP1P3*P1P4-QP1P4*P1P3)
     $            +PIM3(K)*(QP1P4*P1P2-QP1P2*P1P4)
     $            +PIM4(K)*(QP1P2*P1P3-QP1P3*P1P2) )
 304    CONTINUE
 301   CONTINUE
C
      ELSE
C ===================================================================
C pi0 pi0 p0 pi- case                                            ====
C ===================================================================
       QQ=PAA(4)**2-PAA(3)**2-PAA(2)**2-PAA(1)**2
       DO 101 K=1,3
C --- loop over thre contribution of the non-omega current
        SK=(PP(K,4)+PIM4(4))**2-(PP(K,3)+PIM4(3))**2
     $    -(PP(K,2)+PIM4(2))**2-(PP(K,1)+PIM4(1))**2
C -- definition of AA matrix
C -- cronecker delta
        DO 102 I=1,4
         DO 103 J=1,4
 103     AA(I,J)=0.0
 102    AA(I,I)=1.0
C
C ... and the rest ...
        DO 104 L=1,3
         IF (L.NE.K) THEN
          DENOM=(PAA(4)-PP(L,4))**2-(PAA(3)-PP(L,3))**2
     $         -(PAA(2)-PP(L,2))**2-(PAA(1)-PP(L,1))**2
          DO 105 I=1,4
          DO 105 J=1,4
                      SIG=1.0
           IF(J.NE.4) SIG=-SIG
           AA(I,J)=AA(I,J)
     $            -SIG*(PAA(I)-2.0*PP(L,I))*(PAA(J)-PP(L,J))/DENOM
 105      CONTINUE
         ENDIF
 104    CONTINUE
C --- let's add something to HADCURR
       FORM1= FPIKM(SQRT(SK),AMPI,AMPI) *FPIKM(SQRT(QQ),AMPI,AMPI)
C       FORM1= FPIKM(SQRT(SK),AMPI,AMPI) *FPIKMD(SQRT(QQ),AMPI,AMPI)
CCCCCCCCCCCCC       FORM1=WIGFOR(SK,AMRO,GAMRO)        (tests)
        DO 106 I=1,4
        DO 106 J=1,4
         HADCUR(I)=
     $   HADCUR(I)+CMPLX(COEF1)*FORM1*AA(I,J)*(PP(K,J)-PP(4,J))
 106    CONTINUE
C --- end of the non omega current (3 possibilities)
 101   CONTINUE
      ENDIF
      END
      FUNCTION WIGFOR(S,XM,XGAM)
      COMPLEX WIGFOR,WIGNOR
      WIGNOR=CMPLX(-XM**2,XM*XGAM)
      WIGFOR=WIGNOR/CMPLX(S-XM**2,XM*XGAM)
      END

      SUBROUTINE CURINF
C HERE the form factors of M. Finkemeier et al. start
C it ends with the string:  M. Finkemeier et al. END
      COMMON /INOUT/ INUT, IOUT
      WRITE (UNIT = IOUT,FMT = 99)
      WRITE (UNIT = IOUT,FMT = 98)
c                    print *, 'here is curinf'
 99   FORMAT(
     . /,   ' *************************************************** ',
     . /,   '   YOU ARE USING THE 4 PION DECAY MODE FORM FACTORS    ',
     . /,   '   WHICH HAVE BEEN DESCRIBED IN:',
     . /,   '   R. DECKER, M. FINKEMEIER, P. HEILIGER AND H.H. JONSSON',
     . /,   '   "TAU DECAYS INTO FOUR PIONS" ',
     . /,   '   UNIVERSITAET KARLSRUHE PREPRINT TTP 94-13 (1994);',
     . /,   '                    LNF-94/066(IR); HEP-PH/9410260  ',
     . /,   '  ',
     . /,   ' PLEASE NOTE THAT THIS ROUTINE IS USING PARAMETERS',
     . /,   ' RELATED TO THE 3 PION DECAY MODE (A1 MODE), SUCH AS',
     . /,   ' THE A1 MASS AND WIDTH (TAKEN FROM THE COMMON /PARMAS/)',
     . /,   ' AND THE 2 PION VECTOR RESONANCE FORM FACTOR (BY USING',
     . /,   ' THE ROUTINE FPIKM)'                                   ,
     . /,   ' THUS IF YOU DECIDE TO CHANGE ANY OF THESE, YOU WILL'  ,
     . /,   ' HAVE TO REFIT THE 4 PION PARAMETERS IN THE COMMON'    )
   98   FORMAT(
     .      ' BLOCK /TAU4PI/, OR YOU MIGHT GET A BAD DISCRIPTION'   ,
     . /,   ' OF TAU -> 4 PIONS'       ,
     . /,   ' for these formfactors set in routine CHOICE for',
     . /,  ' mnum.eq.102 -- AMRX=1.42 and GAMRX=.21',
     . /,  ' mnum.eq.101 -- AMRX=1.3 and GAMRX=.46 PROB1,PROB2=0.2',
     . /,  ' to optimize phase space parametrization',
     . /,   ' *************************************************** ',
     . /,   ' coded by M. Finkemeier and P. Heiliger, 29. sept. 1994',
     . /,   ' incorporated to TAUOLA by Z. Was      17. jan. 1995',
c     . /,   ' fitted on (day/month/year) by ...  ',
c     . /,   ' to .... data ',
     . /,   ' changed by: Z. Was on 17.01.95',
     . /,   ' changes by: M. Finkemeier on 30.01.95' )
      END
C
      SUBROUTINE CURINI
      COMMON /TAU4PI/ GOMEGA,GAMMA1,GAMMA2,ROM1,ROG1,BETA1,
     .                ROM2,ROG2,BETA2
      REAL*4          GOMEGA,GAMMA1,GAMMA2,ROM1,ROG1,BETA1,
     .                ROM2,ROG2,BETA2
      GOMEGA = 1.4
      GAMMA1 = 0.38
      GAMMA2 = 0.38
      ROM1   = 1.35
      ROG1   = 0.3
      BETA1  = 0.08
      ROM2   = 1.70
      ROG2   = 0.235
      BETA2  = -0.0075
      END
      COMPLEX FUNCTION BWIGA1(QA)
C     ================================================================
C     breit-wigner enhancement of a1
C     ================================================================
      COMPLEX WIGNER
      COMMON / PARMAS/ AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU,
     %                 AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1,
     %                 AMK,AMKZ,AMKST,GAMKST

C
      REAL*4           AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU,
     %                 AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1,
     %                 AMK,AMKZ,AMKST,GAMKST

      WIGNER(A,B,C)=CMPLX(1.0,0.0)/CMPLX(A-B**2,B*C)
      GAMAX=GAMA1*GFUN(QA)/GFUN(AMA1**2)
      BWIGA1=-AMA1**2*WIGNER(QA,AMA1,GAMAX)
      RETURN
      END
      COMPLEX FUNCTION BWIGEPS(QEPS)
C     =============================================================
C     breit-wigner enhancement of epsilon
C     =============================================================
      REAL QEPS,MEPS,GEPS
      MEPS=1.300
      GEPS=.600
      BWIGEPS=CMPLX(MEPS**2,-MEPS*GEPS)/
     %        CMPLX(MEPS**2-QEPS,-MEPS*GEPS)
      RETURN
      END
      COMPLEX FUNCTION FRHO4(W,XM1,XM2)
C     ===========================================================
C     rho-type resonance factor with higher radials, to be used
C     by CURR for the four pion mode
C     ===========================================================
      COMPLEX BWIGM
      COMMON /TAU4PI/ GOMEGA,GAMMA1,GAMMA2,ROM1,ROG1,BETA1,
     .                ROM2,ROG2,BETA2
      REAL*4          GOMEGA,GAMMA1,GAMMA2,ROM1,ROG1,BETA1,
     .                ROM2,ROG2,BETA2
      REAL ROM,ROG,PI,PIM,S,W
      EXTERNAL BWIG
      DATA  INIT /0/
C
C ------------ PARAMETERS --------------------
      IF (INIT.EQ.0 ) THEN
      INIT=1
      PI=3.141592654
      PIM=.140
      ROM=0.773
      ROG=0.145
      ENDIF
C -----------------------------------------------
      S=W**2
c	       print *,'rom2,rog2 =',rom2,rog2
      FRHO4=(BWIGM(S,ROM,ROG,XM1,XM2)+BETA1*BWIGM(S,ROM1,ROG1,XM1,XM2)
     & +BETA2*BWIGM(S,ROM2,ROG2,XM1,XM2))
     & /(1+BETA1+BETA2)
      RETURN
      END
      SUBROUTINE CURR(MNUM,PIM1,PIM2,PIM3,PIM4,HADCUR)
C     ==================================================================
C     Hadronic current for 4 pi final state, according to:
C     R. Decker, M. Finkemeier, P. Heiliger, H.H.Jonsson, TTP94-13
C
C     See also:
C     R. Fisher, J. Wess and F. Wagner Z. Phys C3 (1980) 313
C     R. Decker Z. Phys C36 (1987) 487.
C     M. Gell-Mann, D. Sharp, W. Wagner Phys. Rev. Lett 8 (1962) 261.
C     ==================================================================

      COMMON /TAU4PI/ GOMEGA,GAMMA1,GAMMA2,ROM1,ROG1,BETA1,
     .                ROM2,ROG2,BETA2
      REAL*4          GOMEGA,GAMMA1,GAMMA2,ROM1,ROG1,BETA1,
     .                ROM2,ROG2,BETA2
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / DECPAR / GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL*4            GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL  PIM1(4),PIM2(4),PIM3(4),PIM4(4),PAA(4)
      COMPLEX HADCUR(4),FORM1,FORM2,FORM3,FPIKM
      COMPLEX BWIGN
      COMPLEX BWIGEPS,BWIGA1
      COMPLEX HCOMP1(4),HCOMP2(4),HCOMP3(4),HCOMP4(4)

      COMPLEX T243,T213,T143,T123,T341,T342
      COMPLEX T124,T134,T214,T234,T314,T324
      COMPLEX S2413,S2314,S1423,S1324,S34
      COMPLEX S2431,S3421
      COMPLEX BRACK1,BRACK2,BRACK3,BRACK4A,BRACK4B,BRACK4

      REAL QMP1,QMP2,QMP3,QMP4
      REAL PS43,PS41,PS42,PS34,PS14,PS13,PS24,PS23
      REAL PS21,PS31

      REAL PD243,PD241,PD213,PD143,PD142
      REAL PD123,PD341,PD342,PD413,PD423
      REAL PD124,PD134,PD214,PD234,PD314,PD324
      REAL QP1,QP2,QP3,QP4

      REAL PA(4),PB(4)
      REAL AA(4,4),PP(4,4)
      DATA PI /3.141592653589793238462643/
      DATA  FPI /93.3E-3/
      DATA INIT /0/
      BWIGN(A,XM,XG)=1.0/CMPLX(A-XM**2,XM*XG)
C
      IF (INIT.EQ.0) THEN
	CALL CURINI
	CALL CURINF
	INIT = 1
      ENDIF
C
C --- MASSES AND CONSTANTS
      G1=12.924
      G2=1475.98 * GOMEGA
      G =G1*G2
      ELPHA=-.1
      AMROP=1.7
      GAMROP=0.26
      AMOM=.782
      GAMOM=0.0085
      ARFLAT=1.0
      AROMEG=1.0
C
      FRO=0.266*AMRO**2
      COEF1=2.0*SQRT(3.0)/FPI**2*ARFLAT
      COEF2=FRO*G*AROMEG
C --- INITIALIZATION OF FOUR VECTORS
      DO 7 K=1,4
      DO 8 L=1,4
 8    AA(K,L)=0.0
      HADCUR(K)=CMPLX(0.0)
      PAA(K)=PIM1(K)+PIM2(K)+PIM3(K)+PIM4(K)
      PP(1,K)=PIM1(K)
      PP(2,K)=PIM2(K)
      PP(3,K)=PIM3(K)
 7    PP(4,K)=PIM4(K)
C
      IF (MNUM.EQ.1) THEN
C ===================================================================
C PI- PI- P0 PI+ CASE                                            ====
C ===================================================================
       QQ=PAA(4)**2-PAA(3)**2-PAA(2)**2-PAA(1)**2

C FIRST DEFINITION OF SCALAR PRODUCTS OF MOMENTUM VECTORS

C DEFINE (Q-PI)**2 AS QPI:

      QMP1=(PIM2(4)+PIM3(4)+PIM4(4))**2-(PIM2(3)+PIM3(3)+PIM4(3))**2
     %   -(PIM2(2)+PIM3(2)+PIM4(2))**2-(PIM2(1)+PIM3(1)+PIM4(1))**2

      QMP2=(PIM1(4)+PIM3(4)+PIM4(4))**2-(PIM1(3)+PIM3(3)+PIM4(3))**2
     %   -(PIM1(2)+PIM3(2)+PIM4(2))**2-(PIM1(1)+PIM3(1)+PIM4(1))**2

      QMP3=(PIM1(4)+PIM2(4)+PIM4(4))**2-(PIM1(3)+PIM2(3)+PIM4(3))**2
     %   -(PIM1(2)+PIM2(2)+PIM4(2))**2-(PIM1(1)+PIM2(1)+PIM4(1))**2

      QMP4=(PIM1(4)+PIM2(4)+PIM3(4))**2-(PIM1(3)+PIM2(3)+PIM3(3))**2
     %   -(PIM1(2)+PIM2(2)+PIM3(2))**2-(PIM1(1)+PIM2(1)+PIM3(1))**2


C DEFINE (PI+PK)**2 AS PSIK:

      PS43=(PIM4(4)+PIM3(4))**2-(PIM4(3)+PIM3(3))**2
     %    -(PIM4(2)+PIM3(2))**2-(PIM4(1)+PIM3(1))**2

      PS41=(PIM4(4)+PIM1(4))**2-(PIM4(3)+PIM1(3))**2
     %    -(PIM4(2)+PIM1(2))**2-(PIM4(1)+PIM1(1))**2

      PS42=(PIM4(4)+PIM2(4))**2-(PIM4(3)+PIM2(3))**2
     %    -(PIM4(2)+PIM2(2))**2-(PIM4(1)+PIM2(1))**2

      PS34=PS43

      PS14=PS41

      PS13=(PIM1(4)+PIM3(4))**2-(PIM1(3)+PIM3(3))**2
     %    -(PIM1(2)+PIM3(2))**2-(PIM1(1)+PIM3(1))**2

      PS24=PS42

      PS23=(PIM2(4)+PIM3(4))**2-(PIM2(3)+PIM3(3))**2
     %    -(PIM2(2)+PIM3(2))**2-(PIM2(1)+PIM3(1))**2

      PD243=PIM2(4)*(PIM4(4)-PIM3(4))-PIM2(3)*(PIM4(3)-PIM3(3))
     %     -PIM2(2)*(PIM4(2)-PIM3(2))-PIM2(1)*(PIM4(1)-PIM3(1))

      PD241=PIM2(4)*(PIM4(4)-PIM1(4))-PIM2(3)*(PIM4(3)-PIM1(3))
     %     -PIM2(2)*(PIM4(2)-PIM1(2))-PIM2(1)*(PIM4(1)-PIM1(1))

      PD213=PIM2(4)*(PIM1(4)-PIM3(4))-PIM2(3)*(PIM1(3)-PIM3(3))
     %     -PIM2(2)*(PIM1(2)-PIM3(2))-PIM2(1)*(PIM1(1)-PIM3(1))

      PD143=PIM1(4)*(PIM4(4)-PIM3(4))-PIM1(3)*(PIM4(3)-PIM3(3))
     %     -PIM1(2)*(PIM4(2)-PIM3(2))-PIM1(1)*(PIM4(1)-PIM3(1))

      PD142=PIM1(4)*(PIM4(4)-PIM2(4))-PIM1(3)*(PIM4(3)-PIM2(3))
     %     -PIM1(2)*(PIM4(2)-PIM2(2))-PIM1(1)*(PIM4(1)-PIM2(1))

      PD123=PIM1(4)*(PIM2(4)-PIM3(4))-PIM1(3)*(PIM2(3)-PIM3(3))
     %     -PIM1(2)*(PIM2(2)-PIM3(2))-PIM1(1)*(PIM2(1)-PIM3(1))

      PD341=PIM3(4)*(PIM4(4)-PIM1(4))-PIM3(3)*(PIM4(3)-PIM1(3))
     %     -PIM3(2)*(PIM4(2)-PIM1(2))-PIM3(1)*(PIM4(1)-PIM1(1))

      PD342=PIM3(4)*(PIM4(4)-PIM2(4))-PIM3(3)*(PIM4(3)-PIM2(3))
     %     -PIM3(2)*(PIM4(2)-PIM2(2))-PIM3(1)*(PIM4(1)-PIM2(1))

      PD413=PIM4(4)*(PIM1(4)-PIM3(4))-PIM4(3)*(PIM1(3)-PIM3(3))
     %     -PIM4(2)*(PIM1(2)-PIM3(2))-PIM4(1)*(PIM1(1)-PIM3(1))

      PD423=PIM4(4)*(PIM2(4)-PIM3(4))-PIM4(3)*(PIM2(3)-PIM3(3))
     %     -PIM4(2)*(PIM2(2)-PIM3(2))-PIM4(1)*(PIM2(1)-PIM3(1))

C DEFINE Q*PI = QPI:

      QP1=PIM1(4)*(PIM1(4)+PIM2(4)+PIM3(4)+PIM4(4))
     %   -PIM1(3)*(PIM1(3)+PIM2(3)+PIM3(3)+PIM4(3))
     %   -PIM1(2)*(PIM1(2)+PIM2(2)+PIM3(2)+PIM4(2))
     %   -PIM1(1)*(PIM1(1)+PIM2(1)+PIM3(1)+PIM4(1))

      QP2=PIM2(4)*(PIM1(4)+PIM2(4)+PIM3(4)+PIM4(4))
     %   -PIM2(3)*(PIM1(3)+PIM2(3)+PIM3(3)+PIM4(3))
     %   -PIM2(2)*(PIM1(2)+PIM2(2)+PIM3(2)+PIM4(2))
     %   -PIM2(1)*(PIM1(1)+PIM2(1)+PIM3(1)+PIM4(1))

      QP3=PIM3(4)*(PIM1(4)+PIM2(4)+PIM3(4)+PIM4(4))
     %   -PIM3(3)*(PIM1(3)+PIM2(3)+PIM3(3)+PIM4(3))
     %   -PIM3(2)*(PIM1(2)+PIM2(2)+PIM3(2)+PIM4(2))
     %   -PIM3(1)*(PIM1(1)+PIM2(1)+PIM3(1)+PIM4(1))

      QP4=PIM4(4)*(PIM1(4)+PIM2(4)+PIM3(4)+PIM4(4))
     %   -PIM4(3)*(PIM1(3)+PIM2(3)+PIM3(3)+PIM4(3))
     %   -PIM4(2)*(PIM1(2)+PIM2(2)+PIM3(2)+PIM4(2))
     %   -PIM4(1)*(PIM1(1)+PIM2(1)+PIM3(1)+PIM4(1))



C DEFINE T(PI;PJ,PK)= TIJK:

      T243=BWIGA1(QMP2)*FPIKM(SQRT(PS43),AMPI,AMPI)*GAMMA1
      T213=BWIGA1(QMP2)*FPIKM(SQRT(PS13),AMPI,AMPI)*GAMMA1
      T143=BWIGA1(QMP1)*FPIKM(SQRT(PS43),AMPI,AMPI)*GAMMA1
      T123=BWIGA1(QMP1)*FPIKM(SQRT(PS23),AMPI,AMPI)*GAMMA1
      T341=BWIGA1(QMP3)*FPIKM(SQRT(PS41),AMPI,AMPI)*GAMMA1
      T342=BWIGA1(QMP3)*FPIKM(SQRT(PS42),AMPI,AMPI)*GAMMA1

C DEFINE S(I,J;K,L)= SIJKL:

      S2413=FRHO4(SQRT(PS24),AMPI,AMPI)*GAMMA2
      S2314=FRHO4(SQRT(PS23),AMPI,AMPI)*BWIGEPS(PS14)*GAMMA2
      S1423=FRHO4(SQRT(PS14),AMPI,AMPI)*GAMMA2
      S1324=FRHO4(SQRT(PS13),AMPI,AMPI)*BWIGEPS(PS24)*GAMMA2
      S34=FRHO4(SQRT(PS34),AMPI,AMPI)*GAMMA2

C DEFINITION OF AMPLITUDE, FIRST THE [] BRACKETS:

      BRACK1=2.*T143+2.*T243+T123+T213
     %    +T341*(PD241/QMP3-1.)+T342*(PD142/QMP3-1.)
     %    +3./4.*(S1423+S2413-S2314-S1324)-3.*S34

      BRACK2=2.*T143*PD243/QMP1+3.*T213
     %    +T123*(2.*PD423/QMP1+1.)+T341*(PD241/QMP3+3.)
     %    +T342*(PD142/QMP3+1.)
     %    -3./4.*(S2314+3.*S1324+3.*S1423+S2413)

      BRACK3=2.*T243*PD143/QMP2+3.*T123
     %    +T213*(2.*PD413/QMP2+1.)+T341*(PD241/QMP3+1.)
     %    +T342*(PD142/QMP3+3.)
     %    -3./4.*(3.*S2314+S1324+S1423+3.*S2413)

      BRACK4A=2.*T143*(PD243/QQ*(QP1/QMP1+1.)+PD143/QQ)
     %     +2.*T243*(PD143/QQ*(QP2/QMP2+1.)+PD243/QQ)
     %     +T123+T213
     %     +2.*T123*(PD423/QQ*(QP1/QMP1+1.)+PD123/QQ)
     %     +2.*T213*(PD413/QQ*(QP2/QMP2+1.)+PD213/QQ)
     %     +T341*(PD241/QMP3+1.-2.*PD241/QQ*(QP3/QMP3+1.)
     %           -2.*PD341/QQ)
     %     +T342*(PD142/QMP3+1.-2.*PD142/QQ*(QP3/QMP3+1.)
     %           -2.*PD342/QQ)

      BRACK4B=-3./4.*(S2314*(2.*(QP2-QP3)/QQ+1.)
     %             +S1324*(2.*(QP1-QP3)/QQ+1.)
     %             +S1423*(2.*(QP1-QP4)/QQ+1.)
     %             +S2413*(2.*(QP2-QP4)/QQ+1.)
     %             +4.*S34*(QP4-QP3)/QQ)

      BRACK4=BRACK4A+BRACK4B

      DO 208 K=1,4

      HCOMP1(K)=(PIM3(K)-PIM4(K))*BRACK1
      HCOMP2(K)=PIM1(K)*BRACK2
      HCOMP3(K)=PIM2(K)*BRACK3
      HCOMP4(K)=(PIM1(K)+PIM2(K)+PIM3(K)+PIM4(K))*BRACK4

 208  CONTINUE

      DO 209 I=1,4

      HADCUR(I)=HCOMP1(I)-HCOMP2(I)-HCOMP3(I)+HCOMP4(I)
      HADCUR(I)=-COEF1*FRHO4(SQRT(QQ),AMPI,AMPI)*HADCUR(I)

 209  CONTINUE


C --- END OF THE NON OMEGA CURRENT (3 POSSIBILITIES)
 201   CONTINUE
C
C
C --- THERE ARE TWO POSSIBILITIES FOR OMEGA CURRENT
C --- PA PB ARE CORRESPONDING FIRST AND SECOND PI-'S
       DO 301 KK=1,2
        DO 302 I=1,4
         PA(I)=PP(KK,I)
         PB(I)=PP(3-KK,I)
 302    CONTINUE
C --- LORENTZ INVARIANTS
         QQA=0.0
         SS23=0.0
         SS24=0.0
         SS34=0.0
         QP1P2=0.0
         QP1P3=0.0
         QP1P4=0.0
         P1P2 =0.0
         P1P3 =0.0
         P1P4 =0.0
        DO 303 K=1,4
                     SIGN=-1.0
         IF (K.EQ.4) SIGN= 1.0
         QQA=QQA+SIGN*(PAA(K)-PA(K))**2
         SS23=SS23+SIGN*(PB(K)  +PIM3(K))**2
         SS24=SS24+SIGN*(PB(K)  +PIM4(K))**2
         SS34=SS34+SIGN*(PIM3(K)+PIM4(K))**2
         QP1P2=QP1P2+SIGN*(PAA(K)-PA(K))*PB(K)
         QP1P3=QP1P3+SIGN*(PAA(K)-PA(K))*PIM3(K)
         QP1P4=QP1P4+SIGN*(PAA(K)-PA(K))*PIM4(K)
         P1P2=P1P2+SIGN*PA(K)*PB(K)
         P1P3=P1P3+SIGN*PA(K)*PIM3(K)
         P1P4=P1P4+SIGN*PA(K)*PIM4(K)
 303    CONTINUE
C
        FORM2=COEF2*(BWIGN(QQ,AMRO,GAMRO)+ELPHA*BWIGN(QQ,AMROP,GAMROP))
C        FORM3=BWIGN(QQA,AMOM,GAMOM)*(BWIGN(SS23,AMRO,GAMRO)+
C     $        BWIGN(SS24,AMRO,GAMRO)+BWIGN(SS34,AMRO,GAMRO))
        FORM3=BWIGN(QQA,AMOM,GAMOM)
C
        DO 304 K=1,4
          HADCUR(K)=HADCUR(K)+FORM2*FORM3*(
     $              PB  (K)*(QP1P3*P1P4-QP1P4*P1P3)
     $             +PIM3(K)*(QP1P4*P1P2-QP1P2*P1P4)
     $             +PIM4(K)*(QP1P2*P1P3-QP1P3*P1P2) )
 304    CONTINUE
 301   CONTINUE
C
      ELSE
C ===================================================================
C PI0 PI0 P0 PI- CASE                                            ====
C ===================================================================
       QQ=PAA(4)**2-PAA(3)**2-PAA(2)**2-PAA(1)**2


C FIRST DEFINITION OF SCALAR PRODUCTS OF MOMENTUM VECTORS

C DEFINE (Q-PI)**2 AS QPI:

      QMP1=(PIM2(4)+PIM3(4)+PIM4(4))**2-(PIM2(3)+PIM3(3)+PIM4(3))**2
     %   -(PIM2(2)+PIM3(2)+PIM4(2))**2-(PIM2(1)+PIM3(1)+PIM4(1))**2

      QMP2=(PIM1(4)+PIM3(4)+PIM4(4))**2-(PIM1(3)+PIM3(3)+PIM4(3))**2
     %   -(PIM1(2)+PIM3(2)+PIM4(2))**2-(PIM1(1)+PIM3(1)+PIM4(1))**2

      QMP3=(PIM1(4)+PIM2(4)+PIM4(4))**2-(PIM1(3)+PIM2(3)+PIM4(3))**2
     %   -(PIM1(2)+PIM2(2)+PIM4(2))**2-(PIM1(1)+PIM2(1)+PIM4(1))**2

      QMP4=(PIM1(4)+PIM2(4)+PIM3(4))**2-(PIM1(3)+PIM2(3)+PIM3(3))**2
     %   -(PIM1(2)+PIM2(2)+PIM3(2))**2-(PIM1(1)+PIM2(1)+PIM3(1))**2


C DEFINE (PI+PK)**2 AS PSIK:

      PS14=(PIM1(4)+PIM4(4))**2-(PIM1(3)+PIM4(3))**2
     %    -(PIM1(2)+PIM4(2))**2-(PIM1(1)+PIM4(1))**2

      PS21=(PIM2(4)+PIM1(4))**2-(PIM2(3)+PIM1(3))**2
     %    -(PIM2(2)+PIM1(2))**2-(PIM2(1)+PIM1(1))**2

      PS23=(PIM2(4)+PIM3(4))**2-(PIM2(3)+PIM3(3))**2
     %    -(PIM2(2)+PIM3(2))**2-(PIM2(1)+PIM3(1))**2

      PS24=(PIM2(4)+PIM4(4))**2-(PIM2(3)+PIM4(3))**2
     %    -(PIM2(2)+PIM4(2))**2-(PIM2(1)+PIM4(1))**2

      PS31=(PIM3(4)+PIM1(4))**2-(PIM3(3)+PIM1(3))**2
     %    -(PIM3(2)+PIM1(2))**2-(PIM3(1)+PIM1(1))**2

      PS34=(PIM3(4)+PIM4(4))**2-(PIM3(3)+PIM4(3))**2
     %    -(PIM3(2)+PIM4(2))**2-(PIM3(1)+PIM4(1))**2



      PD324=PIM3(4)*(PIM2(4)-PIM4(4))-PIM3(3)*(PIM2(3)-PIM4(3))
     %     -PIM3(2)*(PIM2(2)-PIM4(2))-PIM3(1)*(PIM2(1)-PIM4(1))

      PD314=PIM3(4)*(PIM1(4)-PIM4(4))-PIM3(3)*(PIM1(3)-PIM4(3))
     %     -PIM3(2)*(PIM1(2)-PIM4(2))-PIM3(1)*(PIM1(1)-PIM4(1))

      PD234=PIM2(4)*(PIM3(4)-PIM4(4))-PIM2(3)*(PIM3(3)-PIM4(3))
     %     -PIM2(2)*(PIM3(2)-PIM4(2))-PIM2(1)*(PIM3(1)-PIM4(1))

      PD214=PIM2(4)*(PIM1(4)-PIM4(4))-PIM2(3)*(PIM1(3)-PIM4(3))
     %     -PIM2(2)*(PIM1(2)-PIM4(2))-PIM2(1)*(PIM1(1)-PIM4(1))

      PD134=PIM1(4)*(PIM3(4)-PIM4(4))-PIM1(3)*(PIM3(3)-PIM4(3))
     %     -PIM1(2)*(PIM3(2)-PIM4(2))-PIM1(1)*(PIM3(1)-PIM4(1))

      PD124=PIM1(4)*(PIM2(4)-PIM4(4))-PIM1(3)*(PIM2(3)-PIM4(3))
     %     -PIM1(2)*(PIM2(2)-PIM4(2))-PIM1(1)*(PIM2(1)-PIM4(1))

C DEFINE Q*PI = QPI:

      QP1=PIM1(4)*(PIM1(4)+PIM2(4)+PIM3(4)+PIM4(4))
     %   -PIM1(3)*(PIM1(3)+PIM2(3)+PIM3(3)+PIM4(3))
     %   -PIM1(2)*(PIM1(2)+PIM2(2)+PIM3(2)+PIM4(2))
     %   -PIM1(1)*(PIM1(1)+PIM2(1)+PIM3(1)+PIM4(1))

      QP2=PIM2(4)*(PIM1(4)+PIM2(4)+PIM3(4)+PIM4(4))
     %   -PIM2(3)*(PIM1(3)+PIM2(3)+PIM3(3)+PIM4(3))
     %   -PIM2(2)*(PIM1(2)+PIM2(2)+PIM3(2)+PIM4(2))
     %   -PIM2(1)*(PIM1(1)+PIM2(1)+PIM3(1)+PIM4(1))

      QP3=PIM3(4)*(PIM1(4)+PIM2(4)+PIM3(4)+PIM4(4))
     %   -PIM3(3)*(PIM1(3)+PIM2(3)+PIM3(3)+PIM4(3))
     %   -PIM3(2)*(PIM1(2)+PIM2(2)+PIM3(2)+PIM4(2))
     %   -PIM3(1)*(PIM1(1)+PIM2(1)+PIM3(1)+PIM4(1))

      QP4=PIM4(4)*(PIM1(4)+PIM2(4)+PIM3(4)+PIM4(4))
     %   -PIM4(3)*(PIM1(3)+PIM2(3)+PIM3(3)+PIM4(3))
     %   -PIM4(2)*(PIM1(2)+PIM2(2)+PIM3(2)+PIM4(2))
     %   -PIM4(1)*(PIM1(1)+PIM2(1)+PIM3(1)+PIM4(1))


C DEFINE T(PI;PJ,PK)= TIJK:

      T324=BWIGA1(QMP3)*FPIKM(SQRT(PS24),AMPI,AMPI)*GAMMA1
      T314=BWIGA1(QMP3)*FPIKM(SQRT(PS14),AMPI,AMPI)*GAMMA1
      T234=BWIGA1(QMP2)*FPIKM(SQRT(PS34),AMPI,AMPI)*GAMMA1
      T214=BWIGA1(QMP2)*FPIKM(SQRT(PS14),AMPI,AMPI)*GAMMA1
      T134=BWIGA1(QMP1)*FPIKM(SQRT(PS34),AMPI,AMPI)*GAMMA1
      T124=BWIGA1(QMP1)*FPIKM(SQRT(PS24),AMPI,AMPI)*GAMMA1

C DEFINE S(I,J;K,L)= SIJKL:

      S1423=FRHO4(SQRT(PS14),AMPI,AMPI)*BWIGEPS(PS23)*GAMMA2
      S2431=FRHO4(SQRT(PS24),AMPI,AMPI)*BWIGEPS(PS31)*GAMMA2
      S3421=FRHO4(SQRT(PS34),AMPI,AMPI)*BWIGEPS(PS21)*GAMMA2


C DEFINITION OF AMPLITUDE, FIRST THE [] BRACKETS:

      BRACK1=T234+T324+2.*T314+T134+2.*T214+T124
     %    +T134*PD234/QMP1+T124*PD324/QMP1
     %    -3./2.*(S3421+S2431+2.*S1423)


      BRACK2=T234*(1.+2.*PD134/QMP2)+3.*T324+3.*T124
     %    +T134*(1.-PD234/QMP1)+2.*T214*PD314/QMP2
     %    -T124*PD324/QMP1
     %    -3./2.*(S3421+3.*S2431)

      BRACK3=T324*(1.+2.*PD124/QMP3)+3.*T234+3.*T134
     %    +T124*(1.-PD324/QMP1)+2.*T314*PD214/QMP3
     %    -T134*PD234/QMP1
     %    -3./2.*(3.*S3421+S2431)

      BRACK4A=2.*T234*(1./2.+PD134/QQ*(QP2/QMP2+1.)+PD234/QQ)
     %     +2.*T324*(1./2.+PD124/QQ*(QP3/QMP3+1.)+PD324/QQ)
     %     +2.*T134*(1./2.+PD234/QQ*(QP1/QMP1+1.)
     %              -1./2.*PD234/QMP1+PD134/QQ)
     %     +2.*T124*(1./2.+PD324/QQ*(QP1/QMP1+1.)
     %              -1./2.*PD324/QMP1+PD124/QQ)
     %     +2.*T214*(PD314/QQ*(QP2/QMP2+1.)+PD214/QQ)
     %     +2.*T314*(PD214/QQ*(QP3/QMP3+1.)+PD314/QQ)

      BRACK4B=-3./2.*(S3421*(2.*(QP3-QP4)/QQ+1.)
     %             +S2431*(2.*(QP2-QP4)/QQ+1.)
     %             +S1423*2.*(QP1-QP4)/QQ)


      BRACK4=BRACK4A+BRACK4B

      DO 308 K=1,4

      HCOMP1(K)=(PIM1(K)-PIM4(K))*BRACK1
      HCOMP2(K)=PIM2(K)*BRACK2
      HCOMP3(K)=PIM3(K)*BRACK3
      HCOMP4(K)=(PIM1(K)+PIM2(K)+PIM3(K)+PIM4(K))*BRACK4

 308  CONTINUE

      DO 309 I=1,4

      HADCUR(I)=HCOMP1(I)+HCOMP2(I)+HCOMP3(I)-HCOMP4(I)
      HADCUR(I)=COEF1*FRHO4(SQRT(QQ),AMPI,AMPI)*HADCUR(I)

 309  CONTINUE

 101   CONTINUE
      ENDIF
C M. Finkemeier et al. END
      END













C=============================================================
C=============================================================
C==== end of elementary file =================================
C=============================================================
C=============================================================
      SUBROUTINE JAKER(JAK)
C     *********************
C
C **********************************************************************
C                                                                      *
C           *********TAUOLA LIBRARY: VERSION 2.6 ********              *
C           **************August   1995******************              *
C           **      AUTHORS: S.JADACH, Z.WAS        *****              *
C           **  R. DECKER, M. JEZABEK, J.H.KUEHN,   *****              *
C           ********AVAILABLE FROM: WASM AT CERNVM ******              *
C           *******PUBLISHED IN COMP. PHYS. COMM.********              *
C           *** PREPRINT CERN-TH-5856 SEPTEMBER 1990 ****              *
C           *** PREPRINT CERN-TH-6195 OCTOBER   1991 ****              *
C           *** PREPRINT CERN-TH-6793 NOVEMBER  1992 ****              *
C **********************************************************************
C
C ----------------------------------------------------------------------
c SUBROUTINE JAKER,
C CHOOSES DECAY MODE ACCORDING TO LIST OF BRANCHING RATIOS
C JAK=1 ELECTRON MODE
C JAK=2 MUON MODE
C JAK=3 PION MODE
C JAK=4 RHO  MODE
C JAK=5 A1   MODE
C JAK=6 K    MODE
C JAK=7 K*   MODE
C JAK=8 nPI  MODE
C
C     called by : DEXAY
C ----------------------------------------------------------------------
      COMMON / TAUBRA / GAMPRT(30),JLIST(30),NCHAN
C      REAL   CUMUL(20)
      REAL   CUMUL(30)
C
      IF(NCHAN.LE.0.OR.NCHAN.GT.30) GOTO 902
      CALL RANMAR(RRR,1)
      SUM=0
      DO 20 I=1,NCHAN
      SUM=SUM+GAMPRT(I)
  20  CUMUL(I)=SUM
      DO 25 I=NCHAN,1,-1
      IF(RRR.LT.CUMUL(I)/CUMUL(NCHAN)) JI=I
  25  CONTINUE
      JAK=JLIST(JI)
      RETURN
 902  PRINT 9020
 9020 FORMAT(' ----- JAKER: WRONG NCHAN')
      STOP
      END
      SUBROUTINE DEKAY(KTO,HX)
C     ***********************
C THIS DEKAY IS IN SPIRIT OF THE 'DECAY' WHICH
C WAS INCLUDED IN KORAL-B PROGRAM, COMP. PHYS. COMMUN.
C VOL. 36 (1985) 191, SEE COMMENTS  ON GENERAL PHILOSOPHY THERE.
C KTO=0 INITIALISATION (OBLIGATORY)
C KTO=1,11 DENOTES TAU+ AND KTO=2,12 TAU-
C DEKAY(1,H) AND DEKAY(2,H) IS CALLED INTERNALLY BY MC GENERATOR.
C H DENOTES THE POLARIMETRIC VECTOR, USED BY THE HOST PROGRAM FOR
C CALCULATION OF THE SPIN WEIGHT.
C USER MAY OPTIONALLY CALL DEKAY(11,H) DEKAY(12,H) IN ORDER
C TO TRANSFORM DECAY PRODUCTS TO CMS AND WRITE LUND RECORD IN /LUJETS/.
C KTO=100, PRINT FINAL REPORT  (OPTIONAL).
C DECAY MODES:
C JAK=1 ELECTRON DECAY
C JAK=2 MU  DECAY
C JAK=3 PI  DECAY
C JAK=4 RHO DECAY
C JAK=5 A1  DECAY
C JAK=6 K   DECAY
C JAK=7 K*  DECAY
C JAK=8 NPI DECAY
C JAK=0 INCLUSIVE:  JAK=1,2,3,4,5,6,7,8
      REAL  H(4)
      REAL*8 HX(4)
      COMMON / JAKI   /  JAK1,JAK2,JAKP,JAKM,KTOM
      COMMON / IDFC  / IDF
      COMMON /TAUPOS/ NP1,NP2
      COMMON / TAUBMC / GAMPMC(30),GAMPER(30),NEVDEC(30)
      REAL*4            GAMPMC    ,GAMPER
      PARAMETER (NMODE=15,NM1=0,NM2=1,NM3=8,NM4=2,NM5=1,NM6=3)
      COMMON / DECOMP /IDFFIN(9,NMODE),MULPIK(NMODE)
     &                ,NAMES
      CHARACTER NAMES(NMODE)*31
      COMMON / INOUT / INUT,IOUT
      REAL  PDUM1(4),PDUM2(4),PDUM3(4),PDUM4(4),PDUM5(4),HDUM(4)
      REAL  PDUMX(4,9)
      DATA IWARM/0/
      KTOM=KTO
      IF(KTO.EQ.-1) THEN
C     ==================
C       INITIALISATION OR REINITIALISATION
C       first or second tau positions in HEPEVT as in KORALB/Z
        NP1=3
        NP2=4
        KTOM=1
        IF (IWARM.EQ.1) X=5/(IWARM-1)
        IWARM=1
        WRITE(IOUT,7001) JAK1,JAK2
        NEVTOT=0
        NEV1=0
        NEV2=0
        IF(JAK1.NE.-1.OR.JAK2.NE.-1) THEN
          CALL DADMEL(-1,IDUM,HDUM,PDUM1,PDUM2,PDUM3,PDUM4,PDUM5)
          CALL DADMMU(-1,IDUM,HDUM,PDUM1,PDUM2,PDUM3,PDUM4,PDUM5)
          CALL DADMPI(-1,IDUM,PDUM,PDUM1,PDUM2)
          CALL DADMRO(-1,IDUM,HDUM,PDUM1,PDUM2,PDUM3,PDUM4)
          CALL DADMAA(-1,IDUM,HDUM,PDUM1,PDUM2,PDUM3,PDUM4,PDUM5,JDUM)
          CALL DADMKK(-1,IDUM,PDUM,PDUM1,PDUM2)
          CALL DADMKS(-1,IDUM,HDUM,PDUM1,PDUM2,PDUM3,PDUM4,JDUM)
          CALL DADNEW(-1,IDUM,HDUM,PDUM1,PDUM2,PDUMX,JDUM)
        ENDIF
        DO 21 I=1,30
        NEVDEC(I)=0
        GAMPMC(I)=0
 21     GAMPER(I)=0
      ELSEIF(KTO.EQ.1) THEN
C     =====================
C DECAY OF TAU+ IN THE TAU REST FRAME
        NEVTOT=NEVTOT+1
        IF(IWARM.EQ.0) GOTO 902
        ISGN= IDF/IABS(IDF)
        CALL DEKAY1(0,H,ISGN)
      ELSEIF(KTO.EQ.2) THEN
C     =================================
C DECAY OF TAU- IN THE TAU REST FRAME
        NEVTOT=NEVTOT+1
        IF(IWARM.EQ.0) GOTO 902
        ISGN=-IDF/IABS(IDF)
        CALL DEKAY2(0,H,ISGN)
      ELSEIF(KTO.EQ.11) THEN
C     ======================
C REST OF DECAY PROCEDURE FOR ACCEPTED TAU+ DECAY
        NEV1=NEV1+1
        ISGN= IDF/IABS(IDF)
        CALL DEKAY1(1,H,ISGN)
      ELSEIF(KTO.EQ.12) THEN
C     ======================
C REST OF DECAY PROCEDURE FOR ACCEPTED TAU- DECAY
        NEV2=NEV2+1
        ISGN=-IDF/IABS(IDF)
        CALL DEKAY2(1,H,ISGN)
      ELSEIF(KTO.EQ.100) THEN
C     =======================
        IF(JAK1.NE.-1.OR.JAK2.NE.-1) THEN
          CALL DADMEL( 1,IDUM,HDUM,PDUM1,PDUM2,PDUM3,PDUM4,PDUM5)
          CALL DADMMU( 1,IDUM,HDUM,PDUM1,PDUM2,PDUM3,PDUM4,PDUM5)
          CALL DADMPI( 1,IDUM,PDUM,PDUM1,PDUM2)
          CALL DADMRO( 1,IDUM,HDUM,PDUM1,PDUM2,PDUM3,PDUM4)
          CALL DADMAA( 1,IDUM,HDUM,PDUM1,PDUM2,PDUM3,PDUM4,PDUM5,JDUM)
          CALL DADMKK( 1,IDUM,PDUM,PDUM1,PDUM2)
          CALL DADMKS( 1,IDUM,HDUM,PDUM1,PDUM2,PDUM3,PDUM4,JDUM)
          CALL DADNEW( 1,IDUM,HDUM,PDUM1,PDUM2,PDUMX,JDUM)
          WRITE(IOUT,7010) NEV1,NEV2,NEVTOT
          WRITE(IOUT,7011) (NEVDEC(I),GAMPMC(I),GAMPER(I),I= 1,7)
          WRITE(IOUT,7012)
     $         (NEVDEC(I),GAMPMC(I),GAMPER(I),NAMES(I-7),I=8,7+NMODE)
          WRITE(IOUT,7013)
        ENDIF
      ELSE
C     ====
        GOTO 910
      ENDIF
C     =====
        DO 78 K=1,4
 78     HX(K)=H(K)
      RETURN

 7001 FORMAT(///1X,15(5H*****)
     $ /,' *',     25X,'*****TAUOLA LIBRARY: VERSION 2.6 ******',9X,1H*,
     $ /,' *',     25X,'***********August   1995***************',9X,1H*,
     $ /,' *',     25X,'**AUTHORS: S.JADACH, Z.WAS*************',9X,1H*,
     $ /,' *',     25X,'**R. DECKER, M. JEZABEK, J.H.KUEHN*****',9X,1H*,
     $ /,' *',     25X,'**AVAILABLE FROM: WASM AT CERNVM ******',9X,1H*,
     $ /,' *',     25X,'***** PUBLISHED IN COMP. PHYS. COMM.***',9X,1H*,
     $ /,' *',     25X,'*******CERN-TH-5856 SEPTEMBER 1990*****',9X,1H*,
     $ /,' *',     25X,'*******CERN-TH-6195 SEPTEMBER 1991*****',9X,1H*,
     $ /,' *',     25X,'*******CERN TH-6793 NOVEMBER  1992*****',9X,1H*,
     $ /,' *',     25X,'**5 or more pi dec.: precision limited ',9X,1H*,
     $ /,' *',     25X,'****DEKAY ROUTINE: INITIALIZATION******',9X,1H*,
     $ /,' *',I20  ,5X,'JAK1   = DECAY MODE TAU+               ',9X,1H*,
     $ /,' *',I20  ,5X,'JAK2   = DECAY MODE TAU-               ',9X,1H*,
     $  /,1X,15(5H*****)/)
 7010 FORMAT(///1X,15(5H*****)
     $ /,' *',     25X,'*****TAUOLA LIBRARY: VERSION 2.6 ******',9X,1H*,
     $ /,' *',     25X,'***********August   1995***************',9X,1H*,
     $ /,' *',     25X,'**AUTHORS: S.JADACH, Z.WAS*************',9X,1H*,
     $ /,' *',     25X,'**R. DECKER, M. JEZABEK, J.H.KUEHN*****',9X,1H*,
     $ /,' *',     25X,'**AVAILABLE FROM: WASM AT CERNVM ******',9X,1H*,
     $ /,' *',     25X,'***** PUBLISHED IN COMP. PHYS. COMM.***',9X,1H*,
     $ /,' *',     25X,'*******CERN-TH-5856 SEPTEMBER 1990*****',9X,1H*,
     $ /,' *',     25X,'*******CERN-TH-6195 SEPTEMBER 1991*****',9X,1H*,
     $ /,' *',     25X,'*******CERN TH-6793 NOVEMBER  1992*****',9X,1H*,
     $ /,' *',     25X,'*****DEKAY ROUTINE: FINAL REPORT*******',9X,1H*,
     $ /,' *',I20  ,5X,'NEV1   = NO. OF TAU+ DECS. ACCEPTED    ',9X,1H*,
     $ /,' *',I20  ,5X,'NEV2   = NO. OF TAU- DECS. ACCEPTED    ',9X,1H*,
     $ /,' *',I20  ,5X,'NEVTOT = SUM                           ',9X,1H*,
     $ /,' *','    NOEVTS ',
     $   ' PART.WIDTH     ERROR       ROUTINE    DECAY MODE    ',9X,1H*)
 7011 FORMAT(1X,'*'
     $       ,I10,2F12.7       ,'     DADMEL     ELECTRON      ',9X,1H*
     $ /,' *',I10,2F12.7       ,'     DADMMU     MUON          ',9X,1H*
     $ /,' *',I10,2F12.7       ,'     DADMPI     PION          ',9X,1H*
     $ /,' *',I10,2F12.7,       '     DADMRO     RHO (->2PI)   ',9X,1H*
     $ /,' *',I10,2F12.7,       '     DADMAA     A1  (->3PI)   ',9X,1H*
     $ /,' *',I10,2F12.7,       '     DADMKK     KAON          ',9X,1H*
     $ /,' *',I10,2F12.7,       '     DADMKS     K*            ',9X,1H*)
 7012 FORMAT(1X,'*'
     $       ,I10,2F12.7,A31                                    ,8X,1H*)
 7013 FORMAT(1X,'*'
     $       ,20X,'THE ERROR IS RELATIVE AND  PART.WIDTH      ',10X,1H*
     $ /,' *',20X,'IN UNITS GFERMI**2*MASS**5/192/PI**3       ',10X,1H*
     $  /,1X,15(5H*****)/)
 902  PRINT 9020
 9020 FORMAT(' ----- DEKAY: LACK OF INITIALISATION')
      STOP
 910  PRINT 9100
 9100 FORMAT(' ----- DEKAY: WRONG VALUE OF KTO ')
      STOP
      END
      SUBROUTINE DEKAY1(IMOD,HH,ISGN)
C     *******************************
C THIS ROUTINE  SIMULATES TAU+  DECAY
      COMMON / DECP4 / PP1(4),PP2(4),KF1,KF2
      COMMON / JAKI   /  JAK1,JAK2,JAKP,JAKM,KTOM
      COMMON / TAUBMC / GAMPMC(30),GAMPER(30),NEVDEC(30)
      REAL*4            GAMPMC    ,GAMPER
      REAL  HH(4)
      REAL  HV(4),PNU(4),PPI(4)
      REAL  PWB(4),PMU(4),PNM(4)
      REAL  PRHO(4),PIC(4),PIZ(4)
      REAL  PAA(4),PIM1(4),PIM2(4),PIPL(4)
      REAL  PKK(4),PKS(4)
      REAL  PNPI(4,9)
      REAL  PHOT(4)
      REAL  PDUM(4)
      DATA NEV,NPRIN/0,10/
      KTO=1
      IF(JAK1.EQ.-1) RETURN
      IMD=IMOD
      IF(IMD.EQ.0) THEN
C     =================
      JAK=JAK1
      IF(JAK1.EQ.0) CALL JAKER(JAK)
      IF(JAK.EQ.1) THEN
        CALL DADMEL(0, ISGN,HV,PNU,PWB,PMU,PNM,PHOT)
      ELSEIF(JAK.EQ.2) THEN
        CALL DADMMU(0, ISGN,HV,PNU,PWB,PMU,PNM,PHOT)
      ELSEIF(JAK.EQ.3) THEN
        CALL DADMPI(0, ISGN,HV,PPI,PNU)
      ELSEIF(JAK.EQ.4) THEN
        CALL DADMRO(0, ISGN,HV,PNU,PRHO,PIC,PIZ)
      ELSEIF(JAK.EQ.5) THEN
        CALL DADMAA(0, ISGN,HV,PNU,PAA,PIM1,PIM2,PIPL,JAA)
      ELSEIF(JAK.EQ.6) THEN
        CALL DADMKK(0, ISGN,HV,PKK,PNU)
      ELSEIF(JAK.EQ.7) THEN
        CALL DADMKS(0, ISGN,HV,PNU,PKS ,PKK,PPI,JKST)
      ELSE
        CALL DADNEW(0, ISGN,HV,PNU,PWB,PNPI,JAK-7)
      ENDIF
      DO 33 I=1,3
 33   HH(I)=HV(I)
      HH(4)=1.0

      ELSEIF(IMD.EQ.1) THEN
C     =====================
      NEV=NEV+1
        IF (JAK.LT.31) THEN
           NEVDEC(JAK)=NEVDEC(JAK)+1
         ENDIF
      DO 34 I=1,4
 34   PDUM(I)=.0
      IF(JAK.EQ.1) THEN
        CALL DWLUEL(1,ISGN,PNU,PWB,PMU,PNM)
        CALL DWRPH(KTOM,PHOT)
        DO 10 I=1,4
 10     PP1(I)=PMU(I)

      ELSEIF(JAK.EQ.2) THEN
        CALL DWLUMU(1,ISGN,PNU,PWB,PMU,PNM)
        CALL DWRPH(KTOM,PHOT)
        DO 20 I=1,4
 20     PP1(I)=PMU(I)

      ELSEIF(JAK.EQ.3) THEN
        CALL DWLUPI(1,ISGN,PPI,PNU)
        DO 30 I=1,4
 30     PP1(I)=PPI(I)

      ELSEIF(JAK.EQ.4) THEN
        CALL DWLURO(1,ISGN,PNU,PRHO,PIC,PIZ)
        DO 40 I=1,4
 40     PP1(I)=PRHO(I)

      ELSEIF(JAK.EQ.5) THEN
        CALL DWLUAA(1,ISGN,PNU,PAA,PIM1,PIM2,PIPL,JAA)
        DO 50 I=1,4
 50     PP1(I)=PAA(I)
      ELSEIF(JAK.EQ.6) THEN
        CALL DWLUKK(1,ISGN,PKK,PNU)
        DO 60 I=1,4
 60     PP1(I)=PKK(I)
      ELSEIF(JAK.EQ.7) THEN
        CALL DWLUKS(1,ISGN,PNU,PKS,PKK,PPI,JKST)
        DO 70 I=1,4
 70     PP1(I)=PKS(I)
      ELSE
CAM     MULTIPION DECAY
        CALL DWLNEW(1,ISGN,PNU,PWB,PNPI,JAK)
        DO 80 I=1,4
 80     PP1(I)=PWB(I)
      ENDIF

      ENDIF
C     =====
      END
      SUBROUTINE DEKAY2(IMOD,HH,ISGN)
C     *******************************
C THIS ROUTINE  SIMULATES TAU-  DECAY
      COMMON / DECP4 / PP1(4),PP2(4),KF1,KF2
      COMMON / JAKI   /  JAK1,JAK2,JAKP,JAKM,KTOM
      COMMON / TAUBMC / GAMPMC(30),GAMPER(30),NEVDEC(30)
      REAL*4            GAMPMC    ,GAMPER
      REAL  HH(4)
      REAL  HV(4),PNU(4),PPI(4)
      REAL  PWB(4),PMU(4),PNM(4)
      REAL  PRHO(4),PIC(4),PIZ(4)
      REAL  PAA(4),PIM1(4),PIM2(4),PIPL(4)
      REAL  PKK(4),PKS(4)
      REAL  PNPI(4,9)
      REAL  PHOT(4)
      REAL  PDUM(4)
      DATA NEV,NPRIN/0,10/
      KTO=2
      IF(JAK2.EQ.-1) RETURN
      IMD=IMOD
      IF(IMD.EQ.0) THEN
C     =================
      JAK=JAK2
      IF(JAK2.EQ.0) CALL JAKER(JAK)
      IF(JAK.EQ.1) THEN
        CALL DADMEL(0, ISGN,HV,PNU,PWB,PMU,PNM,PHOT)
      ELSEIF(JAK.EQ.2) THEN
        CALL DADMMU(0, ISGN,HV,PNU,PWB,PMU,PNM,PHOT)
      ELSEIF(JAK.EQ.3) THEN
        CALL DADMPI(0, ISGN,HV,PPI,PNU)
      ELSEIF(JAK.EQ.4) THEN
        CALL DADMRO(0, ISGN,HV,PNU,PRHO,PIC,PIZ)
      ELSEIF(JAK.EQ.5) THEN
        CALL DADMAA(0, ISGN,HV,PNU,PAA,PIM1,PIM2,PIPL,JAA)
      ELSEIF(JAK.EQ.6) THEN
        CALL DADMKK(0, ISGN,HV,PKK,PNU)
      ELSEIF(JAK.EQ.7) THEN
        CALL DADMKS(0, ISGN,HV,PNU,PKS ,PKK,PPI,JKST)
      ELSE
        CALL DADNEW(0, ISGN,HV,PNU,PWB,PNPI,JAK-7)
      ENDIF
      DO 33 I=1,3
 33   HH(I)=HV(I)
      HH(4)=1.0
      ELSEIF(IMD.EQ.1) THEN
C     =====================
      NEV=NEV+1
        IF (JAK.LT.31) THEN
           NEVDEC(JAK)=NEVDEC(JAK)+1
         ENDIF
      DO 34 I=1,4
 34   PDUM(I)=.0
      IF(JAK.EQ.1) THEN
        CALL DWLUEL(2,ISGN,PNU,PWB,PMU,PNM)
        CALL DWRPH(KTOM,PHOT)
        DO 10 I=1,4
 10     PP2(I)=PMU(I)

      ELSEIF(JAK.EQ.2) THEN
        CALL DWLUMU(2,ISGN,PNU,PWB,PMU,PNM)
        CALL DWRPH(KTOM,PHOT)
        DO 20 I=1,4
 20     PP2(I)=PMU(I)

      ELSEIF(JAK.EQ.3) THEN
        CALL DWLUPI(2,ISGN,PPI,PNU)
        DO 30 I=1,4
 30     PP2(I)=PPI(I)

      ELSEIF(JAK.EQ.4) THEN
        CALL DWLURO(2,ISGN,PNU,PRHO,PIC,PIZ)
        DO 40 I=1,4
 40     PP2(I)=PRHO(I)

      ELSEIF(JAK.EQ.5) THEN
        CALL DWLUAA(2,ISGN,PNU,PAA,PIM1,PIM2,PIPL,JAA)
        DO 50 I=1,4
 50     PP2(I)=PAA(I)
      ELSEIF(JAK.EQ.6) THEN
        CALL DWLUKK(2,ISGN,PKK,PNU)
        DO 60 I=1,4
 60     PP1(I)=PKK(I)
      ELSEIF(JAK.EQ.7) THEN
        CALL DWLUKS(2,ISGN,PNU,PKS,PKK,PPI,JKST)
        DO 70 I=1,4
 70     PP1(I)=PKS(I)
      ELSE
CAM     MULTIPION DECAY
        CALL DWLNEW(2,ISGN,PNU,PWB,PNPI,JAK)
        DO 80 I=1,4
 80     PP1(I)=PWB(I)
      ENDIF
C
      ENDIF
C     =====
      END
      SUBROUTINE DEXAY(KTO,POL)
C ----------------------------------------------------------------------
C THIS 'DEXAY' IS A ROUTINE WHICH GENERATES DECAY OF THE SINGLE
C POLARIZED TAU,  POL IS A POLARIZATION VECTOR (NOT A POLARIMETER
C VECTOR AS IN DEKAY) OF THE TAU AND IT IS AN INPUT PARAMETER.
C KTO=0 INITIALISATION (OBLIGATORY)
C KTO=1 DENOTES TAU+ AND KTO=2 TAU-
C DEXAY(1,POL) AND DEXAY(2,POL) ARE CALLED INTERNALLY BY MC GENERATOR.
C DECAY PRODUCTS ARE TRANSFORMED READILY
C TO CMS AND WRITEN IN THE  LUND RECORD IN /LUJETS/
C KTO=100, PRINT FINAL REPORT (OPTIONAL).
C
C     called by : KORALZ
C ----------------------------------------------------------------------
      COMMON / TAUBMC / GAMPMC(30),GAMPER(30),NEVDEC(30)
      REAL*4            GAMPMC    ,GAMPER
      COMMON / JAKI   /  JAK1,JAK2,JAKP,JAKM,KTOM
      COMMON / IDFC  / IDFF
      COMMON /TAUPOS/ NP1,NP2
      PARAMETER (NMODE=15,NM1=0,NM2=1,NM3=8,NM4=2,NM5=1,NM6=3)
      COMMON / DECOMP /IDFFIN(9,NMODE),MULPIK(NMODE)
     &                ,NAMES
      CHARACTER NAMES(NMODE)*31
      COMMON / INOUT / INUT,IOUT
      REAL  POL(4)
      REAL  PDUM1(4),PDUM2(4),PDUM3(4),PDUM4(4),PDUM5(4)
      REAL  PDUM(4)
      REAL  PDUMI(4,9)
      DATA IWARM/0/
      KTOM=KTO
C
      IF(KTO.EQ.-1) THEN
C     ==================

C       INITIALISATION OR REINITIALISATION
C       first or second tau positions in HEPEVT as in KORALB/Z
        NP1=3
        NP2=4
        IWARM=1
        WRITE(IOUT, 7001) JAK1,JAK2
        NEVTOT=0
        NEV1=0
        NEV2=0
        IF(JAK1.NE.-1.OR.JAK2.NE.-1) THEN
          CALL DEXEL(-1,IDUM,PDUM,PDUM1,PDUM2,PDUM3,PDUM4,PDUM5)
          CALL DEXMU(-1,IDUM,PDUM,PDUM1,PDUM2,PDUM3,PDUM4,PDUM5)
          CALL DEXPI(-1,IDUM,PDUM,PDUM1,PDUM2)
          CALL DEXRO(-1,IDUM,PDUM,PDUM1,PDUM2,PDUM3,PDUM4)
          CALL DEXAA(-1,IDUM,PDUM,PDUM1,PDUM2,PDUM3,PDUM4,PDUM5,IDUM)
          CALL DEXKK(-1,IDUM,PDUM,PDUM1,PDUM2)
          CALL DEXKS(-1,IDUM,PDUM,PDUM1,PDUM2,PDUM3,PDUM4,IDUM)
          CALL DEXNEW(-1,IDUM,PDUM,PDUM1,PDUM2,PDUMI,IDUM)
        ENDIF
        DO 21 I=1,30
        NEVDEC(I)=0
        GAMPMC(I)=0
 21     GAMPER(I)=0
      ELSEIF(KTO.EQ.1) THEN
C     =====================
C DECAY OF TAU+ IN THE TAU REST FRAME
        NEVTOT=NEVTOT+1
        NEV1=NEV1+1
        IF(IWARM.EQ.0) GOTO 902
        ISGN=IDFF/IABS(IDFF)
CAM     CALL DEXAY1(POL,ISGN)
        CALL DEXAY1(KTO,JAK1,JAKP,POL,ISGN)
      ELSEIF(KTO.EQ.2) THEN
C     =================================
C DECAY OF TAU- IN THE TAU REST FRAME
        NEVTOT=NEVTOT+1
        NEV2=NEV2+1
        IF(IWARM.EQ.0) GOTO 902
        ISGN=-IDFF/IABS(IDFF)
CAM     CALL DEXAY2(POL,ISGN)
        CALL DEXAY1(KTO,JAK2,JAKM,POL,ISGN)
      ELSEIF(KTO.EQ.100) THEN
C     =======================
        IF(JAK1.NE.-1.OR.JAK2.NE.-1) THEN
          CALL DEXEL( 1,IDUM,PDUM,PDUM1,PDUM2,PDUM3,PDUM4,PDUM5)
          CALL DEXMU( 1,IDUM,PDUM,PDUM1,PDUM2,PDUM3,PDUM4,PDUM5)
          CALL DEXPI( 1,IDUM,PDUM,PDUM1,PDUM2)
          CALL DEXRO( 1,IDUM,PDUM,PDUM1,PDUM2,PDUM3,PDUM4)
          CALL DEXAA( 1,IDUM,PDUM,PDUM1,PDUM2,PDUM3,PDUM4,PDUM5,IDUM)
          CALL DEXKK( 1,IDUM,PDUM,PDUM1,PDUM2)
          CALL DEXKS( 1,IDUM,PDUM,PDUM1,PDUM2,PDUM3,PDUM4,IDUM)
          CALL DEXNEW( 1,IDUM,PDUM,PDUM1,PDUM2,PDUMI,IDUM)
          WRITE(IOUT,7010) NEV1,NEV2,NEVTOT
          WRITE(IOUT,7011) (NEVDEC(I),GAMPMC(I),GAMPER(I),I= 1,7)
          WRITE(IOUT,7012)
     $         (NEVDEC(I),GAMPMC(I),GAMPER(I),NAMES(I-7),I=8,7+NMODE)
          WRITE(IOUT,7013)
        ENDIF
      ELSE
        GOTO 910
      ENDIF
      RETURN
 7001 FORMAT(///1X,15(5H*****)
     $ /,' *',     25X,'*****TAUOLA LIBRARY: VERSION 2.6 ******',9X,1H*,
     $ /,' *',     25X,'***********August   1995***************',9X,1H*,
     $ /,' *',     25X,'**AUTHORS: S.JADACH, Z.WAS*************',9X,1H*,
     $ /,' *',     25X,'**R. DECKER, M. JEZABEK, J.H.KUEHN*****',9X,1H*,
     $ /,' *',     25X,'**AVAILABLE FROM: WASM AT CERNVM ******',9X,1H*,
     $ /,' *',     25X,'***** PUBLISHED IN COMP. PHYS. COMM.***',9X,1H*,
     $ /,' *',     25X,'*******CERN-TH-5856 SEPTEMBER 1990*****',9X,1H*,
     $ /,' *',     25X,'*******CERN-TH-6195 SEPTEMBER 1991*****',9X,1H*,
     $ /,' *',     25X,'*******CERN-TH-6793 NOVEMBER  1992*****',9X,1H*,
     $ /,' *',     25X,'**5 or more pi dec.: precision limited ',9X,1H*,
     $ /,' *',     25X,'******DEXAY ROUTINE: INITIALIZATION****',9X,1H*
     $ /,' *',I20  ,5X,'JAK1   = DECAY MODE FERMION1 (TAU+)    ',9X,1H*
     $ /,' *',I20  ,5X,'JAK2   = DECAY MODE FERMION2 (TAU-)    ',9X,1H*
     $  /,1X,15(5H*****)/)
CHBU  format 7010 had more than 19 continuation lines
CHBU  split into two
 7010 FORMAT(///1X,15(5H*****)
     $ /,' *',     25X,'*****TAUOLA LIBRARY: VERSION 2.6 ******',9X,1H*,
     $ /,' *',     25X,'***********August   1995***************',9X,1H*,
     $ /,' *',     25X,'**AUTHORS: S.JADACH, Z.WAS*************',9X,1H*,
     $ /,' *',     25X,'**R. DECKER, M. JEZABEK, J.H.KUEHN*****',9X,1H*,
     $ /,' *',     25X,'**AVAILABLE FROM: WASM AT CERNVM ******',9X,1H*,
     $ /,' *',     25X,'***** PUBLISHED IN COMP. PHYS. COMM.***',9X,1H*,
     $ /,' *',     25X,'*******CERN-TH-5856 SEPTEMBER 1990*****',9X,1H*,
     $ /,' *',     25X,'*******CERN-TH-6195 SEPTEMBER 1991*****',9X,1H*,
     $ /,' *',     25X,'*******CERN-TH-6793 NOVEMBER  1992*****',9X,1H*,
     $ /,' *',     25X,'******DEXAY ROUTINE: FINAL REPORT******',9X,1H*
     $ /,' *',I20  ,5X,'NEV1   = NO. OF TAU+ DECS. ACCEPTED    ',9X,1H*
     $ /,' *',I20  ,5X,'NEV2   = NO. OF TAU- DECS. ACCEPTED    ',9X,1H*
     $ /,' *',I20  ,5X,'NEVTOT = SUM                           ',9X,1H*
     $ /,' *','    NOEVTS ',
     $   ' PART.WIDTH     ERROR       ROUTINE    DECAY MODE    ',9X,1H*)
 7011 FORMAT(1X,'*'
     $       ,I10,2F12.7       ,'     DADMEL     ELECTRON      ',9X,1H*
     $ /,' *',I10,2F12.7       ,'     DADMMU     MUON          ',9X,1H*
     $ /,' *',I10,2F12.7       ,'     DADMPI     PION          ',9X,1H*
     $ /,' *',I10,2F12.7,       '     DADMRO     RHO (->2PI)   ',9X,1H*
     $ /,' *',I10,2F12.7,       '     DADMAA     A1  (->3PI)   ',9X,1H*
     $ /,' *',I10,2F12.7,       '     DADMKK     KAON          ',9X,1H*
     $ /,' *',I10,2F12.7,       '     DADMKS     K*            ',9X,1H*)
 7012 FORMAT(1X,'*'
     $       ,I10,2F12.7,A31                                    ,8X,1H*)
 7013 FORMAT(1X,'*'
     $       ,20X,'THE ERROR IS RELATIVE AND  PART.WIDTH      ',10X,1H*
     $ /,' *',20X,'IN UNITS GFERMI**2*MASS**5/192/PI**3       ',10X,1H*
     $  /,1X,15(5H*****)/)
 902  WRITE(IOUT, 9020)
 9020 FORMAT(' ----- DEXAY: LACK OF INITIALISATION')
      STOP
 910  WRITE(IOUT, 9100)
 9100 FORMAT(' ----- DEXAY: WRONG VALUE OF KTO ')
      STOP
      END
      SUBROUTINE DEXAY1(KTO,JAKIN,JAK,POL,ISGN)
C ---------------------------------------------------------------------
C THIS ROUTINE  SIMULATES TAU+-  DECAY
C
C     called by : DEXAY
C ---------------------------------------------------------------------
      COMMON / TAUBMC / GAMPMC(30),GAMPER(30),NEVDEC(30)
      REAL*4            GAMPMC    ,GAMPER
      COMMON / INOUT / INUT,IOUT
      REAL  POL(4),POLAR(4)
      REAL  PNU(4),PPI(4)
      REAL  PRHO(4),PIC(4),PIZ(4)
      REAL  PWB(4),PMU(4),PNM(4)
      REAL  PAA(4),PIM1(4),PIM2(4),PIPL(4)
      REAL  PKK(4),PKS(4)
      REAL  PNPI(4,9)
      REAL PHOT(4)
      REAL PDUM(4)
C
      IF(JAKIN.EQ.-1) RETURN
      DO 33 I=1,3
 33   POLAR(I)=POL(I)
      POLAR(4)=0.
      DO 34 I=1,4
 34   PDUM(I)=.0
      JAK=JAKIN
      IF(JAK.EQ.0) CALL JAKER(JAK)
CAM
      IF(JAK.EQ.1) THEN
        CALL DEXEL(0, ISGN,POLAR,PNU,PWB,PMU,PNM,PHOT)
        CALL DWLUEL(KTO,ISGN,PNU,PWB,PMU,PNM)
        CALL DWRPH(KTO,PHOT )
      ELSEIF(JAK.EQ.2) THEN
        CALL DEXMU(0, ISGN,POLAR,PNU,PWB,PMU,PNM,PHOT)
        CALL DWLUMU(KTO,ISGN,PNU,PWB,PMU,PNM)
        CALL DWRPH(KTO,PHOT )
      ELSEIF(JAK.EQ.3) THEN
        CALL DEXPI(0, ISGN,POLAR,PPI,PNU)
        CALL DWLUPI(KTO,ISGN,PPI,PNU)
      ELSEIF(JAK.EQ.4) THEN
        CALL DEXRO(0, ISGN,POLAR,PNU,PRHO,PIC,PIZ)
        CALL DWLURO(KTO,ISGN,PNU,PRHO,PIC,PIZ)
      ELSEIF(JAK.EQ.5) THEN
        CALL DEXAA(0, ISGN,POLAR,PNU,PAA,PIM1,PIM2,PIPL,JAA)
        CALL DWLUAA(KTO,ISGN,PNU,PAA,PIM1,PIM2,PIPL,JAA)
      ELSEIF(JAK.EQ.6) THEN
        CALL DEXKK(0, ISGN,POLAR,PKK,PNU)
        CALL DWLUKK(KTO,ISGN,PKK,PNU)
      ELSEIF(JAK.EQ.7) THEN
        CALL DEXKS(0, ISGN,POLAR,PNU,PKS,PKK,PPI,JKST)
        CALL DWLUKS(KTO,ISGN,PNU,PKS,PKK,PPI,JKST)
      ELSE
        JNPI=JAK-7
        CALL DEXNEW(0, ISGN,POLAR,PNU,PWB,PNPI,JNPI)
        CALL DWLNEW(KTO,ISGN,PNU,PWB,PNPI,JAK)
      ENDIF
      NEVDEC(JAK)=NEVDEC(JAK)+1
      END
      SUBROUTINE DEXEL(MODE,ISGN,POL,PNU,PWB,Q1,Q2,PH)
C ----------------------------------------------------------------------
C THIS SIMULATES TAU DECAY IN TAU REST FRAME
C INTO ELECTRON AND TWO NEUTRINOS
C
C     called by : DEXAY,DEXAY1
C ----------------------------------------------------------------------
      REAL  POL(4),HV(4),PWB(4),PNU(4),Q1(4),Q2(4),PH(4)
      DATA IWARM/0/
C
      IF(MODE.EQ.-1) THEN
C     ===================
        IWARM=1
        CALL DADMEL( -1,ISGN,HV,PNU,PWB,Q1,Q2,PH)
CC      CALL HBOOK1(813,'WEIGHT DISTRIBUTION  DEXEL    $',100,0,2)
C
      ELSEIF(MODE.EQ. 0) THEN
C     =======================
300     CONTINUE
        IF(IWARM.EQ.0) GOTO 902
        CALL DADMEL(  0,ISGN,HV,PNU,PWB,Q1,Q2,PH)
        WT=(1+POL(1)*HV(1)+POL(2)*HV(2)+POL(3)*HV(3))/2.
CC      CALL HFILL(813,WT)
        CALL RANMAR(RN,1)
        IF(RN.GT.WT) GOTO 300
C
      ELSEIF(MODE.EQ. 1) THEN
C     =======================
        CALL DADMEL(  1,ISGN,HV,PNU,PWB,Q1,Q2,PH)
CC      CALL HPRINT(813)
      ENDIF
C     =====
      RETURN
 902  PRINT 9020
 9020 FORMAT(' ----- DEXEL: LACK OF INITIALISATION')
      STOP
      END
      SUBROUTINE DEXMU(MODE,ISGN,POL,PNU,PWB,Q1,Q2,PH)
C ----------------------------------------------------------------------
C THIS SIMULATES TAU DECAY IN ITS REST FRAME
C INTO MUON AND TWO NEUTRINOS
C OUTPUT FOUR MOMENTA: PNU   TAUNEUTRINO,
C                      PWB   W-BOSON
C                      Q1    MUON
C                      Q2    MUON-NEUTRINO
C ----------------------------------------------------------------------
      COMMON / INOUT / INUT,IOUT
      REAL  POL(4),HV(4),PWB(4),PNU(4),Q1(4),Q2(4),PH(4)
      DATA IWARM/0/
C
      IF(MODE.EQ.-1) THEN
C     ===================
        IWARM=1
        CALL DADMMU( -1,ISGN,HV,PNU,PWB,Q1,Q2,PH)
CC      CALL HBOOK1(814,'WEIGHT DISTRIBUTION  DEXMU    $',100,0,2)
C
      ELSEIF(MODE.EQ. 0) THEN
C     =======================
300     CONTINUE
        IF(IWARM.EQ.0) GOTO 902
        CALL DADMMU(  0,ISGN,HV,PNU,PWB,Q1,Q2,PH)
        WT=(1+POL(1)*HV(1)+POL(2)*HV(2)+POL(3)*HV(3))/2.
CC      CALL HFILL(814,WT)
        CALL RANMAR(RN,1)
        IF(RN.GT.WT) GOTO 300
C
      ELSEIF(MODE.EQ. 1) THEN
C     =======================
        CALL DADMMU(  1,ISGN,HV,PNU,PWB,Q1,Q2,PH)
CC      CALL HPRINT(814)
      ENDIF
C     =====
      RETURN
 902  WRITE(IOUT, 9020)
 9020 FORMAT(' ----- DEXMU: LACK OF INITIALISATION')
      STOP
      END
      SUBROUTINE DADMEL(MODE,ISGN,HHV,PNU,PWB,Q1,Q2,PHX)
C ----------------------------------------------------------------------
C
C     called by : DEXEL,(DEKAY,DEKAY1)
C ----------------------------------------------------------------------
      COMMON / DECPAR / GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL*4            GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / TAUBMC / GAMPMC(30),GAMPER(30),NEVDEC(30)
      REAL*4            GAMPMC    ,GAMPER
      REAL*4         PHX(4)
      COMMON / INOUT / INUT,IOUT
      REAL  HHV(4),HV(4),PWB(4),PNU(4),Q1(4),Q2(4)
      REAL  PDUM1(4),PDUM2(4),PDUM3(4),PDUM4(4),PDUM5(4)
      REAL*4 RRR(3)
      REAL*8 SWT, SSWT
      DATA PI /3.141592653589793238462643/
      DATA IWARM/0/
C
      IF(MODE.EQ.-1) THEN
C     ===================
        IWARM=1
        NEVRAW=0
        NEVACC=0
        NEVOVR=0
        SWT=0
        SSWT=0
        WTMAX=1E-20
        DO 15 I=1,500
        CALL DPHSEL(WT,HV,PDUM1,PDUM2,PDUM3,PDUM4,PDUM5)
        IF(WT.GT.WTMAX/1.2) WTMAX=WT*1.2
15      CONTINUE
CC      CALL HBOOK1(803,'WEIGHT DISTRIBUTION  DADMEL    $',100,0,2)
C
      ELSEIF(MODE.EQ. 0) THEN
C     =======================
300     CONTINUE
        IF(IWARM.EQ.0) GOTO 902
        NEVRAW=NEVRAW+1
        CALL DPHSEL(WT,HV,PNU,PWB,Q1,Q2,PHX)
CC      CALL HFILL(803,WT/WTMAX)
        SWT=SWT+WT
        SSWT=SSWT+WT**2
        CALL RANMAR(RRR,3)
        RN=RRR(1)
        IF(WT.GT.WTMAX) NEVOVR=NEVOVR+1
        IF(RN*WTMAX.GT.WT) GOTO 300
C ROTATIONS TO BASIC TAU REST FRAME
        RR2=RRR(2)
        COSTHE=-1.+2.*RR2
        THET=ACOS(COSTHE)
        RR3=RRR(3)
        PHI =2*PI*RR3
        CALL ROTOR2(THET,PNU,PNU)
        CALL ROTOR3( PHI,PNU,PNU)
        CALL ROTOR2(THET,PWB,PWB)
        CALL ROTOR3( PHI,PWB,PWB)
        CALL ROTOR2(THET,Q1,Q1)
        CALL ROTOR3( PHI,Q1,Q1)
        CALL ROTOR2(THET,Q2,Q2)
        CALL ROTOR3( PHI,Q2,Q2)
        CALL ROTOR2(THET,HV,HV)
        CALL ROTOR3( PHI,HV,HV)
        CALL ROTOR2(THET,PHX,PHX)
        CALL ROTOR3( PHI,PHX,PHX)
        DO 44,I=1,3
 44     HHV(I)=-ISGN*HV(I)
        NEVACC=NEVACC+1
C
      ELSEIF(MODE.EQ. 1) THEN
C     =======================
        IF(NEVRAW.EQ.0) RETURN
        PARGAM=SWT/FLOAT(NEVRAW+1)
        ERROR=0
        IF(NEVRAW.NE.0) ERROR=SQRT(SSWT/SWT**2-1./FLOAT(NEVRAW))
        RAT=PARGAM/GAMEL
        WRITE(IOUT, 7010) NEVRAW,NEVACC,NEVOVR,PARGAM,RAT,ERROR
CC      CALL HPRINT(803)
        GAMPMC(1)=RAT
        GAMPER(1)=ERROR
CAM     NEVDEC(1)=NEVACC
      ENDIF
C     =====
      RETURN
 7010 FORMAT(///1X,15(5H*****)
     $ /,' *',     25X,'******** DADMEL FINAL REPORT  ******** ',9X,1H*
     $ /,' *',I20  ,5X,'NEVRAW = NO. OF EL  DECAYS TOTAL       ',9X,1H*
     $ /,' *',I20  ,5X,'NEVACC = NO. OF EL   DECS. ACCEPTED    ',9X,1H*
     $ /,' *',I20  ,5X,'NEVOVR = NO. OF OVERWEIGHTED EVENTS    ',9X,1H*
     $ /,' *',E20.5,5X,'PARTIAL WTDTH ( ELECTRON) IN GEV UNITS ',9X,1H*
     $ /,' *',F20.9,5X,'IN UNITS GFERMI**2*MASS**5/192/PI**3   ',9X,1H*
     $ /,' *',F20.9,5X,'RELATIVE ERROR OF PARTIAL WIDTH        ',9X,1H*
     $ /,' *',25X,     'COMPLETE QED CORRECTIONS INCLUDED      ',9X,1H*
     $ /,' *',25X,     'BUT ONLY V-A CUPLINGS                  ',9X,1H*
     $  /,1X,15(5H*****)/)
 902  WRITE(IOUT, 9020)
 9020 FORMAT(' ----- DADMEL: LACK OF INITIALISATION')
      STOP
      END
      SUBROUTINE DADMMU(MODE,ISGN,HHV,PNU,PWB,Q1,Q2,PHX)
C ----------------------------------------------------------------------
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / DECPAR / GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL*4            GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      COMMON / TAUBMC / GAMPMC(30),GAMPER(30),NEVDEC(30)
      REAL*4            GAMPMC    ,GAMPER
      COMMON / INOUT / INUT,IOUT
      REAL*4         PHX(4)
      REAL  HHV(4),HV(4),PNU(4),PWB(4),Q1(4),Q2(4)
      REAL  PDUM1(4),PDUM2(4),PDUM3(4),PDUM4(4),PDUM5(4)
      REAL*4 RRR(3)
      REAL*8 SWT, SSWT
      DATA PI /3.141592653589793238462643/
      DATA IWARM /0/
C
      IF(MODE.EQ.-1) THEN
C     ===================
        IWARM=1
        NEVRAW=0
        NEVACC=0
        NEVOVR=0
        SWT=0
        SSWT=0
        WTMAX=1E-20
        DO 15 I=1,500
        CALL DPHSMU(WT,HV,PDUM1,PDUM2,PDUM3,PDUM4,PDUM5)
        IF(WT.GT.WTMAX/1.2) WTMAX=WT*1.2
15      CONTINUE
CC      CALL HBOOK1(802,'WEIGHT DISTRIBUTION  DADMMU    $',100,0,2)
C
      ELSEIF(MODE.EQ. 0) THEN
C     =======================
300     CONTINUE
        IF(IWARM.EQ.0) GOTO 902
        NEVRAW=NEVRAW+1
        CALL DPHSMU(WT,HV,PNU,PWB,Q1,Q2,PHX)
CC      CALL HFILL(802,WT/WTMAX)
        SWT=SWT+WT
        SSWT=SSWT+WT**2
        CALL RANMAR(RRR,3)
        RN=RRR(1)
        IF(WT.GT.WTMAX) NEVOVR=NEVOVR+1
        IF(RN*WTMAX.GT.WT) GOTO 300
C ROTATIONS TO BASIC TAU REST FRAME
        COSTHE=-1.+2.*RRR(2)
        THET=ACOS(COSTHE)
        PHI =2*PI*RRR(3)
        CALL ROTOR2(THET,PNU,PNU)
        CALL ROTOR3( PHI,PNU,PNU)
        CALL ROTOR2(THET,PWB,PWB)
        CALL ROTOR3( PHI,PWB,PWB)
        CALL ROTOR2(THET,Q1,Q1)
        CALL ROTOR3( PHI,Q1,Q1)
        CALL ROTOR2(THET,Q2,Q2)
        CALL ROTOR3( PHI,Q2,Q2)
        CALL ROTOR2(THET,HV,HV)
        CALL ROTOR3( PHI,HV,HV)
        CALL ROTOR2(THET,PHX,PHX)
        CALL ROTOR3( PHI,PHX,PHX)
        DO 44,I=1,3
 44     HHV(I)=-ISGN*HV(I)
        NEVACC=NEVACC+1
C
      ELSEIF(MODE.EQ. 1) THEN
C     =======================
        IF(NEVRAW.EQ.0) RETURN
        PARGAM=SWT/FLOAT(NEVRAW+1)
        ERROR=0
        IF(NEVRAW.NE.0) ERROR=SQRT(SSWT/SWT**2-1./FLOAT(NEVRAW))
        RAT=PARGAM/GAMEL
        WRITE(IOUT, 7010) NEVRAW,NEVACC,NEVOVR,PARGAM,RAT,ERROR
CC      CALL HPRINT(802)
        GAMPMC(2)=RAT
        GAMPER(2)=ERROR
CAM     NEVDEC(2)=NEVACC
      ENDIF
C     =====
      RETURN
 7010 FORMAT(///1X,15(5H*****)
     $ /,' *',     25X,'******** DADMMU FINAL REPORT  ******** ',9X,1H*
     $ /,' *',I20  ,5X,'NEVRAW = NO. OF MU  DECAYS TOTAL       ',9X,1H*
     $ /,' *',I20  ,5X,'NEVACC = NO. OF MU   DECS. ACCEPTED    ',9X,1H*
     $ /,' *',I20  ,5X,'NEVOVR = NO. OF OVERWEIGHTED EVENTS    ',9X,1H*
     $ /,' *',E20.5,5X,'PARTIAL WTDTH (MU  DECAY) IN GEV UNITS ',9X,1H*
     $ /,' *',F20.9,5X,'IN UNITS GFERMI**2*MASS**5/192/PI**3   ',9X,1H*
     $ /,' *',F20.9,5X,'RELATIVE ERROR OF PARTIAL WIDTH        ',9X,1H*
     $ /,' *',25X,     'COMPLETE QED CORRECTIONS INCLUDED      ',9X,1H*
     $ /,' *',25X,     'BUT ONLY V-A CUPLINGS                  ',9X,1H*
     $  /,1X,15(5H*****)/)
 902  WRITE(IOUT, 9020)
 9020 FORMAT(' ----- DADMMU: LACK OF INITIALISATION')
      STOP
      END
      SUBROUTINE DPHSEL(DGAMX,HVX,XNX,PAAX,QPX,XAX,PHX)
C XNX,XNA was flipped in parameters of dphsel and dphsmu
C *********************************************************************
C *   ELECTRON DECAY MODE                                             *
C *********************************************************************
      REAL*4         PHX(4)
      REAL*4  HVX(4),PAAX(4),XAX(4),QPX(4),XNX(4)
      REAL*8  HV(4),PH(4),PAA(4),XA(4),QP(4),XN(4)
      REAL*8  DGAMT
      IELMU=1
      CALL DRCMU(DGAMT,HV,PH,PAA,XA,QP,XN,IELMU)
      DO 7 K=1,4
        HVX(K)=HV(K)
        PHX(K)=PH(K)
        PAAX(K)=PAA(K)
        XAX(K)=XA(K)
        QPX(K)=QP(K)
        XNX(K)=XN(K)
  7   CONTINUE
      DGAMX=DGAMT
      END
      SUBROUTINE DPHSMU(DGAMX,HVX,XNX,PAAX,QPX,XAX,PHX)
C XNX,XNA was flipped in parameters of dphsel and dphsmu
C *********************************************************************
C *   MUON     DECAY MODE                                             *
C *********************************************************************
      REAL*4         PHX(4)
      REAL*4  HVX(4),PAAX(4),XAX(4),QPX(4),XNX(4)
      REAL*8  HV(4),PH(4),PAA(4),XA(4),QP(4),XN(4)
      REAL*8  DGAMT
      IELMU=2
      CALL DRCMU(DGAMT,HV,PH,PAA,XA,QP,XN,IELMU)
      DO 7 K=1,4
        HVX(K)=HV(K)
        PHX(K)=PH(K)
        PAAX(K)=PAA(K)
        XAX(K)=XA(K)
        QPX(K)=QP(K)
        XNX(K)=XN(K)
  7   CONTINUE
      DGAMX=DGAMT
      END
      SUBROUTINE DRCMU(DGAMT,HV,PH,PAA,XA,QP,XN,IELMU)
      IMPLICIT REAL*8 (A-H,O-Z)
C ----------------------------------------------------------------------
* IT SIMULATES E,MU CHANNELS OF TAU  DECAY IN ITS REST FRAME WITH
* QED ORDER ALPHA CORRECTIONS
C ----------------------------------------------------------------------
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / DECPAR / GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL*4            GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      COMMON / INOUT / INUT,IOUT
      COMMON / TAURAD / XK0DEC,ITDKRC
      REAL*8            XK0DEC
      REAL*8  HV(4),PT(4),PH(4),PAA(4),XA(4),QP(4),XN(4)
      REAL*8  PR(4)
      REAL*4 RRR(6)
      LOGICAL IHARD
      DATA PI /3.141592653589793238462643D0/
      XLAM(X,Y,Z)=SQRT((X-Y-Z)**2-4.0*Y*Z)
C AMRO, GAMRO IS ONLY A PARAMETER FOR GETING HIGHT EFFICIENCY
C
C THREE BODY PHASE SPACE NORMALISED AS IN BJORKEN-DRELL
C D**3 P /2E/(2PI)**3 (2PI)**4 DELTA4(SUM P)
      PHSPAC=1./2**17/PI**8
      AMTAX=AMTAU
C TAU MOMENTUM
      PT(1)=0.D0
      PT(2)=0.D0
      PT(3)=0.D0
      PT(4)=AMTAX
C
      CALL RANMAR(RRR,6)
C
        IF (IELMU.EQ.1) THEN
          AMU=AMEL
        ELSE
          AMU=AMMU
        ENDIF
C
        PRHARD=0.30D0
        IF (  ITDKRC.EQ.0) PRHARD=0D0
        PRSOFT=1.-PRHARD
         IF(PRSOFT.LT.0.1) THEN
           PRINT *, 'ERROR IN DRCMU; PRSOFT=',PRSOFT
           STOP
         ENDIF
C
        RR5=RRR(5)
        IHARD=(RR5.GT.PRSOFT)
       IF (IHARD) THEN
C                     TAU DECAY TO `TAU+photon'
          RR1=RRR(1)
          AMS1=(AMU+AMNUTA)**2
          AMS2=(AMTAX)**2
          XK1=1-AMS1/AMS2
          XL1=LOG(XK1/2/XK0DEC)
          XL0=LOG(2*XK0DEC)
          XK=EXP(XL1*RR1+XL0)
          AM3SQ=(1-XK)*AMS2
          AM3 =SQRT(AM3SQ)
          PHSPAC=PHSPAC*AMS2*XL1*XK
          PHSPAC=PHSPAC/PRHARD
        ELSE
          AM3=AMTAX
          PHSPAC=PHSPAC*2**6*PI**3
          PHSPAC=PHSPAC/PRSOFT
        ENDIF
C MASS OF NEUTRINA SYSTEM
        RR2=RRR(2)
        AMS1=(AMNUTA)**2
        AMS2=(AM3-AMU)**2
CAM
CAM
* FLAT PHASE SPACE;
      AM2SQ=AMS1+   RR2*(AMS2-AMS1)
      AM2 =SQRT(AM2SQ)
      PHSPAC=PHSPAC*(AMS2-AMS1)
* NEUTRINA REST FRAME, DEFINE XN AND XA
        ENQ1=(AM2SQ+AMNUTA**2)/(2*AM2)
        ENQ2=(AM2SQ-AMNUTA**2)/(2*AM2)
        PPI=         ENQ1**2-AMNUTA**2
        PPPI=SQRT(ABS(ENQ1**2-AMNUTA**2))
        PHSPAC=PHSPAC*(4*PI)*(2*PPPI/AM2)
* NU TAU IN NUNU REST FRAME
        CALL SPHERD(PPPI,XN)
        XN(4)=ENQ1
* NU LIGHT IN NUNU REST FRAME
        DO 30 I=1,3
 30     XA(I)=-XN(I)
        XA(4)=ENQ2
* TAU' REST FRAME, DEFINE QP (muon
*       NUNU  MOMENTUM
        PR(1)=0
        PR(2)=0
        PR(4)=1.D0/(2*AM3)*(AM3**2+AM2**2-AMU**2)
        PR(3)= SQRT(ABS(PR(4)**2-AM2**2))
        PPI  =          PR(4)**2-AM2**2
*       MUON MOMENTUM
        QP(1)=0
        QP(2)=0
        QP(4)=1.D0/(2*AM3)*(AM3**2-AM2**2+AMU**2)
        QP(3)=-PR(3)
      PHSPAC=PHSPAC*(4*PI)*(2*PR(3)/AM3)
* NEUTRINA BOOSTED FROM THEIR FRAME TO TAU' REST FRAME
      EXE=(PR(4)+PR(3))/AM2
      CALL BOSTD3(EXE,XN,XN)
      CALL BOSTD3(EXE,XA,XA)
      RR3=RRR(3)
      RR4=RRR(4)
      IF (IHARD) THEN
        EPS=4*(AMU/AMTAX)**2
        XL1=LOG((2+EPS)/EPS)
        XL0=LOG(EPS)
        ETA  =EXP(XL1*RR3+XL0)
        CTHET=1+EPS-ETA
        THET =ACOS(CTHET)
        PHSPAC=PHSPAC*XL1/2*ETA
        PHI = 2*PI*RR4
        CALL ROTPOX(THET,PHI,XN)
        CALL ROTPOX(THET,PHI,XA)
        CALL ROTPOX(THET,PHI,QP)
        CALL ROTPOX(THET,PHI,PR)
C
* NOW TO THE TAU REST FRAME, DEFINE TAU' AND GAMMA MOMENTA
* tau'  MOMENTUM
        PAA(1)=0
        PAA(2)=0
        PAA(4)=1/(2*AMTAX)*(AMTAX**2+AM3**2)
        PAA(3)= SQRT(ABS(PAA(4)**2-AM3**2))
        PPI   =          PAA(4)**2-AM3**2
        PHSPAC=PHSPAC*(4*PI)*(2*PAA(3)/AMTAX)
* GAMMA MOMENTUM
        PH(1)=0
        PH(2)=0
        PH(4)=PAA(3)
        PH(3)=-PAA(3)
* ALL MOMENTA BOOSTED FROM TAU' REST FRAME TO TAU REST FRAME
* Z-AXIS ANTIPARALLEL TO PHOTON MOMENTUM
        EXE=(PAA(4)+PAA(3))/AM3
        CALL BOSTD3(EXE,XN,XN)
        CALL BOSTD3(EXE,XA,XA)
        CALL BOSTD3(EXE,QP,QP)
        CALL BOSTD3(EXE,PR,PR)
      ELSE
        THET =ACOS(-1.+2*RR3)
        PHI = 2*PI*RR4
        CALL ROTPOX(THET,PHI,XN)
        CALL ROTPOX(THET,PHI,XA)
        CALL ROTPOX(THET,PHI,QP)
        CALL ROTPOX(THET,PHI,PR)
C
* NOW TO THE TAU REST FRAME, DEFINE TAU' AND GAMMA MOMENTA
* tau'  MOMENTUM
        PAA(1)=0
        PAA(2)=0
        PAA(4)=AMTAX
        PAA(3)=0
* GAMMA MOMENTUM
        PH(1)=0
        PH(2)=0
        PH(4)=0
        PH(3)=0
      ENDIF
C PARTIAL WIDTH CONSISTS OF PHASE SPACE AND AMPLITUDE
      CALL DAMPRY(ITDKRC,XK0DEC,PH,XA,QP,XN,AMPLIT,HV)
      DGAMT=1/(2.*AMTAX)*AMPLIT*PHSPAC
      END
      SUBROUTINE DAMPRY(ITDKRC,XK0DEC,XK,XA,QP,XN,AMPLIT,HV)
      IMPLICIT REAL*8 (A-H,O-Z)
C ----------------------------------------------------------------------
C IT CALCULATES MATRIX ELEMENT FOR THE
C TAU --> MU(E) NU NUBAR DECAY MODE
C INCLUDING COMPLETE ORDER ALPHA QED CORRECTIONS.
C ----------------------------------------------------------------------
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      REAL*8  HV(4),QP(4),XN(4),XA(4),XK(4)
C
      HV(4)=1.D0
      AK0=XK0DEC*AMTAU
      IF(XK(4).LT.0.1D0*AK0) THEN
        AMPLIT=THB(ITDKRC,QP,XN,XA,AK0,HV)
      ELSE
        AMPLIT=SQM2(ITDKRC,QP,XN,XA,XK,AK0,HV)
      ENDIF
      RETURN
      END
      FUNCTION SQM2(ITDKRC,QP,XN,XA,XK,AK0,HV)
C
C **********************************************************************
C     REAL PHOTON MATRIX ELEMENT SQUARED                               *
C     PARAMETERS:                                                      *
C     HV- POLARIMETRIC FOUR-VECTOR OF TAU                              *
C     QP,XN,XA,XK - 4-momenta of electron (muon), NU, NUBAR and PHOTON *
C                   All four-vectors in TAU rest frame (in GeV)        *
C     AK0 - INFRARED CUTOFF, MINIMAL ENERGY OF HARD PHOTONS (GEV)      *
C     SQM2 - value for S=0                                             *
C     see Eqs. (2.9)-(2.10) from CJK ( Nucl.Phys.B(1991) )             *
C **********************************************************************
C
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / DECPAR / GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL*4            GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      COMMON / QEDPRM /ALFINV,ALFPI,XK0
      REAL*8           ALFINV,ALFPI,XK0
      REAL*8    QP(4),XN(4),XA(4),XK(4)
      REAL*8    R(4)
      REAL*8   HV(4)
      REAL*8 S0(3),RXA(3),RXK(3),RQP(3)
      DATA PI /3.141592653589793238462643D0/
C
      TMASS=AMTAU
      GF=GFERMI
      ALPHAI=ALFINV
      TMASS2=TMASS**2
      EMASS2=QP(4)**2-QP(1)**2-QP(2)**2-QP(3)**2
      R(4)=TMASS
C     SCALAR PRODUCTS OF FOUR-MOMENTA
      DO 7 I=1,3
        R(1)=0.D0
        R(2)=0.D0
        R(3)=0.D0
        R(I)=TMASS
        RXA(I)=R(4)*XA(4)-R(1)*XA(1)-R(2)*XA(2)-R(3)*XA(3)
C       RXN(I)=R(4)*XN(4)-R(1)*XN(1)-R(2)*XN(2)-R(3)*XN(3)
        RXK(I)=R(4)*XK(4)-R(1)*XK(1)-R(2)*XK(2)-R(3)*XK(3)
        RQP(I)=R(4)*QP(4)-R(1)*QP(1)-R(2)*QP(2)-R(3)*QP(3)
  7   CONTINUE
      QPXN=QP(4)*XN(4)-QP(1)*XN(1)-QP(2)*XN(2)-QP(3)*XN(3)
      QPXA=QP(4)*XA(4)-QP(1)*XA(1)-QP(2)*XA(2)-QP(3)*XA(3)
      QPXK=QP(4)*XK(4)-QP(1)*XK(1)-QP(2)*XK(2)-QP(3)*XK(3)
c     XNXA=XN(4)*XA(4)-XN(1)*XA(1)-XN(2)*XA(2)-XN(3)*XA(3)
      XNXK=XN(4)*XK(4)-XN(1)*XK(1)-XN(2)*XK(2)-XN(3)*XK(3)
      XAXK=XA(4)*XK(4)-XA(1)*XK(1)-XA(2)*XK(2)-XA(3)*XK(3)
      TXN=TMASS*XN(4)
      TXA=TMASS*XA(4)
      TQP=TMASS*QP(4)
      TXK=TMASS*XK(4)
C
      X= XNXK/QPXN
      Z= TXK/TQP
      A= 1+X
      B= 1+ X*(1+Z)/2+Z/2
      S1= QPXN*TXA*( -EMASS2/QPXK**2*A + 2*TQP/(QPXK*TXK)*B-
     $TMASS2/TXK**2)  +
     $QPXN/TXK**2* ( TMASS2*XAXK - TXA*TXK+ XAXK*TXK) -
     $TXA*TXN/TXK - QPXN/(QPXK*TXK)* (TQP*XAXK-TXK*QPXA)
      CONST4=256*PI/ALPHAI*GF**2
      IF (ITDKRC.EQ.0) CONST4=0D0
      SQM2=S1*CONST4
      DO 5 I=1,3
        S0(I) = QPXN*RXA(I)*(-EMASS2/QPXK**2*A + 2*TQP/(QPXK*TXK)*B-
     $  TMASS2/TXK**2) +
     $  QPXN/TXK**2* (TMASS2*XAXK - TXA*RXK(I)+ XAXK*RXK(I))-
     $  RXA(I)*TXN/TXK - QPXN/(QPXK*TXK)*(RQP(I)*XAXK- RXK(I)*QPXA)
  5     HV(I)=S0(I)/S1-1.D0
      RETURN
      END
      FUNCTION THB(ITDKRC,QP,XN,XA,AK0,HV)
C
C **********************************************************************
C     BORN +VIRTUAL+SOFT PHOTON MATRIX ELEMENT**2  O(ALPHA)            *
C     PARAMETERS:                                                      *
C     HV- POLARIMETRIC FOUR-VECTOR OF TAU                              *
C     QP,XN,XA - FOUR-MOMENTA OF ELECTRON (MUON), NU AND NUBAR IN GEV  *
C     ALL FOUR-VECTORS IN TAU REST FRAME                               *
C     AK0 - INFRARED CUTOFF, MINIMAL ENERGY OF HARD PHOTONS            *
C     THB - VALUE FOR S=0                                              *
C     SEE EQS. (2.2),(2.4)-(2.5) FROM CJK (NUCL.PHYS.B351(1991)70      *
C     AND (C.2) FROM JK (NUCL.PHYS.B320(1991)20 )                      *
C **********************************************************************
C
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / DECPAR / GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL*4            GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      COMMON / QEDPRM /ALFINV,ALFPI,XK0
      REAL*8           ALFINV,ALFPI,XK0
      DIMENSION QP(4),XN(4),XA(4)
      REAL*8 HV(4)
      DIMENSION R(4)
      REAL*8 RXA(3),RXN(3),RQP(3)
      REAL*8 BORNPL(3),AM3POL(3),XM3POL(3)
      DATA PI /3.141592653589793238462643D0/
C
      TMASS=AMTAU
      GF=GFERMI
      ALPHAI=ALFINV
C
      TMASS2=TMASS**2
      R(4)=TMASS
      DO 7 I=1,3
        R(1)=0.D0
        R(2)=0.D0
        R(3)=0.D0
        R(I)=TMASS
        RXA(I)=R(4)*XA(4)-R(1)*XA(1)-R(2)*XA(2)-R(3)*XA(3)
        RXN(I)=R(4)*XN(4)-R(1)*XN(1)-R(2)*XN(2)-R(3)*XN(3)
C       RXK(I)=R(4)*XK(4)-R(1)*XK(1)-R(2)*XK(2)-R(3)*XK(3)
        RQP(I)=R(4)*QP(4)-R(1)*QP(1)-R(2)*QP(2)-R(3)*QP(3)
  7   CONTINUE
C     QUASI TWO-BODY VARIABLES
      U0=QP(4)/TMASS
      U3=SQRT(QP(1)**2+QP(2)**2+QP(3)**2)/TMASS
      W3=U3
      W0=(XN(4)+XA(4))/TMASS
      UP=U0+U3
      UM=U0-U3
      WP=W0+W3
      WM=W0-W3
      YU=LOG(UP/UM)/2
      YW=LOG(WP/WM)/2
      EPS2=U0**2-U3**2
      EPS=SQRT(EPS2)
      Y=W0**2-W3**2
      AL=AK0/TMASS
C     FORMFACTORS
      F0=2*U0/U3*(  DILOGT(1-(UM*WM/(UP*WP)))- DILOGT(1-WM/WP) +
     $DILOGT(1-UM/UP) -2*YU+ 2*LOG(UP)*(YW+YU) ) +
     $1/Y* ( 2*U3*YU + (1-EPS2- 2*Y)*LOG(EPS) ) +
     $ 2 - 4*(U0/U3*YU -1)* LOG(2*AL)
      FP= YU/(2*U3)*(1 + (1-EPS2)/Y ) + LOG(EPS)/Y
      FM= YU/(2*U3)*(1 - (1-EPS2)/Y ) - LOG(EPS)/Y
      F3= EPS2*(FP+FM)/2
C     SCALAR PRODUCTS OF FOUR-MOMENTA
      QPXN=QP(4)*XN(4)-QP(1)*XN(1)-QP(2)*XN(2)-QP(3)*XN(3)
      QPXA=QP(4)*XA(4)-QP(1)*XA(1)-QP(2)*XA(2)-QP(3)*XA(3)
      XNXA=XN(4)*XA(4)-XN(1)*XA(1)-XN(2)*XA(2)-XN(3)*XA(3)
      TXN=TMASS*XN(4)
      TXA=TMASS*XA(4)
      TQP=TMASS*QP(4)
C     DECAY DIFFERENTIAL WIDTH WITHOUT AND WITH POLARIZATION
      CONST3=1/(2*ALPHAI*PI)*64*GF**2
      IF (ITDKRC.EQ.0) CONST3=0D0
      XM3= -( F0* QPXN*TXA +  FP*EPS2* TXN*TXA +
     $FM* QPXN*QPXA + F3* TMASS2*XNXA )
      AM3=XM3*CONST3
C V-A  AND  V+A COUPLINGS, BUT IN THE BORN PART ONLY
      BRAK= (GV+GA)**2*TQP*XNXA+(GV-GA)**2*TXA*QPXN
     &     -(GV**2-GA**2)*TMASS*AMNUTA*QPXA
      BORN= 32*(GFERMI**2/2.)*BRAK
      DO 5 I=1,3
        XM3POL(I)= -( F0* QPXN*RXA(I) +  FP*EPS2* TXN*RXA(I) +
     $  FM* QPXN* (QPXA + (RXA(I)*TQP-TXA*RQP(I))/TMASS2 ) +
     $  F3* (TMASS2*XNXA +TXN*RXA(I) -RXN(I)*TXA)  )
        AM3POL(I)=XM3POL(I)*CONST3
C V-A  AND  V+A COUPLINGS, BUT IN THE BORN PART ONLY
        BORNPL(I)=BORN+(
     &            (GV+GA)**2*TMASS*XNXA*QP(I)
     &           -(GV-GA)**2*TMASS*QPXN*XA(I)
     &           +(GV**2-GA**2)*AMNUTA*TXA*QP(I)
     &           -(GV**2-GA**2)*AMNUTA*TQP*XA(I) )*
     &                                             32*(GFERMI**2/2.)
  5     HV(I)=(BORNPL(I)+AM3POL(I))/(BORN+AM3)-1.D0
      THB=BORN+AM3
      IF (THB/BORN.LT.0.1D0) THEN
        PRINT *, 'ERROR IN THB, THB/BORN=',THB/BORN
        STOP
      ENDIF
      RETURN
      END
      SUBROUTINE DEXPI(MODE,ISGN,POL,PPI,PNU)
C ----------------------------------------------------------------------
C TAU DECAY INTO PION AND TAU-NEUTRINO
C IN TAU REST FRAME
C OUTPUT FOUR MOMENTA: PNU   TAUNEUTRINO,
C                      PPI   PION CHARGED
C ----------------------------------------------------------------------
      REAL  POL(4),HV(4),PNU(4),PPI(4)
CC
      IF(MODE.EQ.-1) THEN
C     ===================
        CALL DADMPI(-1,ISGN,HV,PPI,PNU)
CC      CALL HBOOK1(815,'WEIGHT DISTRIBUTION  DEXPI    $',100,0,2)

      ELSEIF(MODE.EQ. 0) THEN
C     =======================
300     CONTINUE
        CALL DADMPI( 0,ISGN,HV,PPI,PNU)
        WT=(1+POL(1)*HV(1)+POL(2)*HV(2)+POL(3)*HV(3))/2.
CC      CALL HFILL(815,WT)
        CALL RANMAR(RN,1)
        IF(RN.GT.WT) GOTO 300
C
      ELSEIF(MODE.EQ. 1) THEN
C     =======================
        CALL DADMPI( 1,ISGN,HV,PPI,PNU)
CC      CALL HPRINT(815)
      ENDIF
C     =====
      RETURN
      END
      SUBROUTINE DADMPI(MODE,ISGN,HV,PPI,PNU)
C ----------------------------------------------------------------------
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / DECPAR / GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL*4            GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      COMMON / TAUBMC / GAMPMC(30),GAMPER(30),NEVDEC(30)
      REAL*4            GAMPMC    ,GAMPER
      COMMON / INOUT / INUT,IOUT
      REAL  PPI(4),PNU(4),HV(4)
      DATA PI /3.141592653589793238462643/
C
      IF(MODE.EQ.-1) THEN
C     ===================
        NEVTOT=0
      ELSEIF(MODE.EQ. 0) THEN
C     =======================
        NEVTOT=NEVTOT+1
        EPI= (AMTAU**2+AMPI**2-AMNUTA**2)/(2*AMTAU)
        ENU= (AMTAU**2-AMPI**2+AMNUTA**2)/(2*AMTAU)
        XPI= SQRT(EPI**2-AMPI**2)
C PI MOMENTUM
        CALL SPHERA(XPI,PPI)
        PPI(4)=EPI
C TAU-NEUTRINO MOMENTUM
        DO 30 I=1,3
30      PNU(I)=-PPI(I)
        PNU(4)=ENU
        PXQ=AMTAU*EPI
        PXN=AMTAU*ENU
        QXN=PPI(4)*PNU(4)-PPI(1)*PNU(1)-PPI(2)*PNU(2)-PPI(3)*PNU(3)
        BRAK=(GV**2+GA**2)*(2*PXQ*QXN-AMPI**2*PXN)
     &      +(GV**2-GA**2)*AMTAU*AMNUTA*AMPI**2
        DO 40 I=1,3
40      HV(I)=-ISGN*2*GA*GV*AMTAU*(2*PPI(I)*QXN-PNU(I)*AMPI**2)/BRAK
        HV(4)=1
C
      ELSEIF(MODE.EQ. 1) THEN
C     =======================
        IF(NEVTOT.EQ.0) RETURN
        FPI=0.1284
C        GAMM=(GFERMI*FPI)**2/(16.*PI)*AMTAU**3*
C     *       (BRAK/AMTAU**4)**2
CZW 7.02.93 here was an error affecting non standard model
C       configurations only
        GAMM=(GFERMI*FPI)**2/(16.*PI)*AMTAU**3*
     $       (BRAK/AMTAU**4)*
     $       SQRT((AMTAU**2-AMPI**2-AMNUTA**2)**2
     $            -4*AMPI**2*AMNUTA**2           )/AMTAU**2
        ERROR=0
        RAT=GAMM/GAMEL
        WRITE(IOUT, 7010) NEVTOT,GAMM,RAT,ERROR
        GAMPMC(3)=RAT
        GAMPER(3)=ERROR
CAM     NEVDEC(3)=NEVTOT
      ENDIF
C     =====
      RETURN
 7010 FORMAT(///1X,15(5H*****)
     $ /,' *',     25X,'******** DADMPI FINAL REPORT  ******** ',9X,1H*
     $ /,' *',I20  ,5X,'NEVTOT = NO. OF PI  DECAYS TOTAL       ',9X,1H*
     $ /,' *',E20.5,5X,'PARTIAL WTDTH ( PI DECAY) IN GEV UNITS ',9X,1H*
     $ /,' *',F20.9,5X,'IN UNITS GFERMI**2*MASS**5/192/PI**3   ',9X,1H*
     $ /,' *',F20.8,5X,'RELATIVE ERROR OF PARTIAL WIDTH (STAT.)',9X,1H*
     $  /,1X,15(5H*****)/)
      END
      SUBROUTINE DEXRO(MODE,ISGN,POL,PNU,PRO,PIC,PIZ)
C ----------------------------------------------------------------------
C THIS SIMULATES TAU DECAY IN TAU REST FRAME
C INTO NU RHO, NEXT RHO DECAYS INTO PION PAIR.
C OUTPUT FOUR MOMENTA: PNU   TAUNEUTRINO,
C                      PRO   RHO
C                      PIC   PION CHARGED
C                      PIZ   PION ZERO
C ----------------------------------------------------------------------
      COMMON / INOUT / INUT,IOUT
      REAL  POL(4),HV(4),PRO(4),PNU(4),PIC(4),PIZ(4)
      DATA IWARM/0/
C
      IF(MODE.EQ.-1) THEN
C     ===================
        IWARM=1
        CALL DADMRO( -1,ISGN,HV,PNU,PRO,PIC,PIZ)
CC      CALL HBOOK1(816,'WEIGHT DISTRIBUTION  DEXRO    $',100,0,2)
CC      CALL HBOOK1(916,'ABS2 OF HV IN ROUTINE DEXRO   $',100,0,2)
C
      ELSEIF(MODE.EQ. 0) THEN
C     =======================
300     CONTINUE
        IF(IWARM.EQ.0) GOTO 902
        CALL DADMRO(  0,ISGN,HV,PNU,PRO,PIC,PIZ)
        WT=(1+POL(1)*HV(1)+POL(2)*HV(2)+POL(3)*HV(3))/2.
CC      CALL HFILL(816,WT)
CC      XHELP=HV(1)**2+HV(2)**2+HV(3)**2
CC      CALL HFILL(916,XHELP)
        CALL RANMAR(RN,1)
        IF(RN.GT.WT) GOTO 300
C
      ELSEIF(MODE.EQ. 1) THEN
C     =======================
        CALL DADMRO(  1,ISGN,HV,PNU,PRO,PIC,PIZ)
CC      CALL HPRINT(816)
CC      CALL HPRINT(916)
      ENDIF
C     =====
      RETURN
 902  WRITE(IOUT, 9020)
 9020 FORMAT(' ----- DEXRO: LACK OF INITIALISATION')
      STOP
      END
      SUBROUTINE DADMRO(MODE,ISGN,HHV,PNU,PRO,PIC,PIZ)
C ----------------------------------------------------------------------
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / DECPAR / GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL*4            GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      COMMON / TAUBMC / GAMPMC(30),GAMPER(30),NEVDEC(30)
      REAL*4            GAMPMC    ,GAMPER
      COMMON / INOUT / INUT,IOUT
      REAL  HHV(4)
      REAL  HV(4),PRO(4),PNU(4),PIC(4),PIZ(4)
      REAL  PDUM1(4),PDUM2(4),PDUM3(4),PDUM4(4)
      REAL*4 RRR(3)
      REAL*8 SWT, SSWT
      DATA PI /3.141592653589793238462643/
      DATA IWARM/0/
C
      IF(MODE.EQ.-1) THEN
C     ===================
        IWARM=1
        NEVRAW=0
        NEVACC=0
        NEVOVR=0
        SWT=0
        SSWT=0
        WTMAX=1E-20
        DO 15 I=1,500
        CALL DPHSRO(WT,HV,PDUM1,PDUM2,PDUM3,PDUM4)
        IF(WT.GT.WTMAX/1.2) WTMAX=WT*1.2
15      CONTINUE
CC      CALL HBOOK1(801,'WEIGHT DISTRIBUTION  DADMRO    $',100,0,2)
CC      PRINT 7003,WTMAX
C
      ELSEIF(MODE.EQ. 0) THEN
C     =======================
300     CONTINUE
        IF(IWARM.EQ.0) GOTO 902
        CALL DPHSRO(WT,HV,PNU,PRO,PIC,PIZ)
CC      CALL HFILL(801,WT/WTMAX)
        NEVRAW=NEVRAW+1
        SWT=SWT+WT
        SSWT=SSWT+WT**2
        CALL RANMAR(RRR,3)
        RN=RRR(1)
        IF(WT.GT.WTMAX) NEVOVR=NEVOVR+1
        IF(RN*WTMAX.GT.WT) GOTO 300
C ROTATIONS TO BASIC TAU REST FRAME
        COSTHE=-1.+2.*RRR(2)
        THET=ACOS(COSTHE)
        PHI =2*PI*RRR(3)
        CALL ROTOR2(THET,PNU,PNU)
        CALL ROTOR3( PHI,PNU,PNU)
        CALL ROTOR2(THET,PRO,PRO)
        CALL ROTOR3( PHI,PRO,PRO)
        CALL ROTOR2(THET,PIC,PIC)
        CALL ROTOR3( PHI,PIC,PIC)
        CALL ROTOR2(THET,PIZ,PIZ)
        CALL ROTOR3( PHI,PIZ,PIZ)
        CALL ROTOR2(THET,HV,HV)
        CALL ROTOR3( PHI,HV,HV)
        DO 44 I=1,3
 44     HHV(I)=-ISGN*HV(I)
        NEVACC=NEVACC+1
C
      ELSEIF(MODE.EQ. 1) THEN
C     =======================
        IF(NEVRAW.EQ.0) RETURN
        PARGAM=SWT/FLOAT(NEVRAW+1)
        ERROR=0
        IF(NEVRAW.NE.0) ERROR=SQRT(SSWT/SWT**2-1./FLOAT(NEVRAW))
        RAT=PARGAM/GAMEL
        WRITE(IOUT, 7010) NEVRAW,NEVACC,NEVOVR,PARGAM,RAT,ERROR
CC      CALL HPRINT(801)
        GAMPMC(4)=RAT
        GAMPER(4)=ERROR
CAM     NEVDEC(4)=NEVACC
      ENDIF
C     =====
      RETURN
 7003 FORMAT(///1X,15(5H*****)
     $ /,' *',     25X,'******** DADMRO INITIALISATION ********',9X,1H*
     $ /,' *',E20.5,5X,'WTMAX  = MAXIMUM WEIGHT                ',9X,1H*
     $  /,1X,15(5H*****)/)
 7010 FORMAT(///1X,15(5H*****)
     $ /,' *',     25X,'******** DADMRO FINAL REPORT  ******** ',9X,1H*
     $ /,' *',I20  ,5X,'NEVRAW = NO. OF RHO DECAYS TOTAL       ',9X,1H*
     $ /,' *',I20  ,5X,'NEVACC = NO. OF RHO  DECS. ACCEPTED    ',9X,1H*
     $ /,' *',I20  ,5X,'NEVOVR = NO. OF OVERWEIGHTED EVENTS    ',9X,1H*
     $ /,' *',E20.5,5X,'PARTIAL WTDTH (RHO DECAY) IN GEV UNITS ',9X,1H*
     $ /,' *',F20.9,5X,'IN UNITS GFERMI**2*MASS**5/192/PI**3   ',9X,1H*
     $ /,' *',F20.8,5X,'RELATIVE ERROR OF PARTIAL WIDTH        ',9X,1H*
     $  /,1X,15(5H*****)/)
 902  WRITE(IOUT, 9020)
 9020 FORMAT(' ----- DADMRO: LACK OF INITIALISATION')
      STOP
      END
      SUBROUTINE DPHSRO(DGAMT,HV,PN,PR,PIC,PIZ)
C ----------------------------------------------------------------------
C IT SIMULATES RHO DECAY IN TAU REST FRAME WITH
C Z-AXIS ALONG RHO MOMENTUM
C ----------------------------------------------------------------------
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / DECPAR / GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL*4            GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL  HV(4),PT(4),PN(4),PR(4),PIC(4),PIZ(4),QQ(4)
      DATA PI /3.141592653589793238462643/
      DATA ICONT /0/
C
C THREE BODY PHASE SPACE NORMALISED AS IN BJORKEN-DRELL
      PHSPAC=1./2**11/PI**5
C TAU MOMENTUM
      PT(1)=0.
      PT(2)=0.
      PT(3)=0.
      PT(4)=AMTAU
C MASS OF (REAL/VIRTUAL) RHO
      AMS1=(AMPI+AMPIZ)**2
      AMS2=(AMTAU-AMNUTA)**2
C FLAT PHASE SPACE
C     AMX2=AMS1+   RR1*(AMS2-AMS1)
C     AMX=SQRT(AMX2)
C     PHSPAC=PHSPAC*(AMS2-AMS1)
C PHASE SPACE WITH SAMPLING FOR RHO RESONANCE
      ALP1=ATAN((AMS1-AMRO**2)/AMRO/GAMRO)
      ALP2=ATAN((AMS2-AMRO**2)/AMRO/GAMRO)
CAM
 100  CONTINUE
      CALL RANMAR(RR1,1)
      ALP=ALP1+RR1*(ALP2-ALP1)
      AMX2=AMRO**2+AMRO*GAMRO*TAN(ALP)
      AMX=SQRT(AMX2)
      IF(AMX.LT.2.*AMPI) GO TO 100
CAM
      PHSPAC=PHSPAC*((AMX2-AMRO**2)**2+(AMRO*GAMRO)**2)/(AMRO*GAMRO)
      PHSPAC=PHSPAC*(ALP2-ALP1)
C
C TAU-NEUTRINO MOMENTUM
      PN(1)=0
      PN(2)=0
      PN(4)=1./(2*AMTAU)*(AMTAU**2+AMNUTA**2-AMX**2)
      PN(3)=-SQRT((PN(4)-AMNUTA)*(PN(4)+AMNUTA))
C RHO MOMENTUM
      PR(1)=0
      PR(2)=0
      PR(4)=1./(2*AMTAU)*(AMTAU**2-AMNUTA**2+AMX**2)
      PR(3)=-PN(3)
      PHSPAC=PHSPAC*(4*PI)*(2*PR(3)/AMTAU)
C
CAM
      ENQ1=(AMX2+AMPI**2-AMPIZ**2)/(2.*AMX)
      ENQ2=(AMX2-AMPI**2+AMPIZ**2)/(2.*AMX)
      PPPI=SQRT((ENQ1-AMPI)*(ENQ1+AMPI))
      PHSPAC=PHSPAC*(4*PI)*(2*PPPI/AMX)
C CHARGED PI MOMENTUM IN RHO REST FRAME
      CALL SPHERA(PPPI,PIC)
      PIC(4)=ENQ1
C NEUTRAL PI MOMENTUM IN RHO REST FRAME
      DO 20 I=1,3
20    PIZ(I)=-PIC(I)
      PIZ(4)=ENQ2
      EXE=(PR(4)+PR(3))/AMX
C PIONS BOOSTED FROM RHO REST FRAME TO TAU REST FRAME
      CALL BOSTR3(EXE,PIC,PIC)
      CALL BOSTR3(EXE,PIZ,PIZ)
      DO 30 I=1,4
30    QQ(I)=PIC(I)-PIZ(I)
C AMPLITUDE
      PRODPQ=PT(4)*QQ(4)
      PRODNQ=PN(4)*QQ(4)-PN(1)*QQ(1)-PN(2)*QQ(2)-PN(3)*QQ(3)
      PRODPN=PT(4)*PN(4)
      QQ2= QQ(4)**2-QQ(1)**2-QQ(2)**2-QQ(3)**2
      BRAK=(GV**2+GA**2)*(2*PRODPQ*PRODNQ-PRODPN*QQ2)
     &    +(GV**2-GA**2)*AMTAU*AMNUTA*QQ2
      AMPLIT=(GFERMI*CCABIB)**2*BRAK*2*FPIRHO(AMX)
      DGAMT=1/(2.*AMTAU)*AMPLIT*PHSPAC
      DO 40 I=1,3
 40   HV(I)=2*GV*GA*AMTAU*(2*PRODNQ*QQ(I)-QQ2*PN(I))/BRAK
      RETURN
      END
      SUBROUTINE DEXAA(MODE,ISGN,POL,PNU,PAA,PIM1,PIM2,PIPL,JAA)
C ----------------------------------------------------------------------
* THIS SIMULATES TAU DECAY IN TAU REST FRAME
* INTO NU A1, NEXT A1 DECAYS INTO RHO PI AND FINALLY RHO INTO PI PI.
* OUTPUT FOUR MOMENTA: PNU   TAUNEUTRINO,
*                      PAA   A1
*                      PIM1  PION MINUS (OR PI0) 1      (FOR TAU MINUS)
*                      PIM2  PION MINUS (OR PI0) 2
*                      PIPL  PION PLUS  (OR PI-)
*                      (PIPL,PIM1) FORM A RHO
C ----------------------------------------------------------------------
      COMMON / INOUT / INUT,IOUT
      REAL  POL(4),HV(4),PAA(4),PNU(4),PIM1(4),PIM2(4),PIPL(4)
      DATA IWARM/0/
C
      IF(MODE.EQ.-1) THEN
C     ===================
        IWARM=1
        CALL DADMAA( -1,ISGN,HV,PNU,PAA,PIM1,PIM2,PIPL,JAA)
CC      CALL HBOOK1(816,'WEIGHT DISTRIBUTION  DEXAA    $',100,-2.,2.)
C
      ELSEIF(MODE.EQ. 0) THEN
*     =======================
 300    CONTINUE
        IF(IWARM.EQ.0) GOTO 902
        CALL DADMAA(  0,ISGN,HV,PNU,PAA,PIM1,PIM2,PIPL,JAA)
        WT=(1+POL(1)*HV(1)+POL(2)*HV(2)+POL(3)*HV(3))/2.
CC      CALL HFILL(816,WT)
        CALL RANMAR(RN,1)
        IF(RN.GT.WT) GOTO 300
C
      ELSEIF(MODE.EQ. 1) THEN
*     =======================
        CALL DADMAA(  1,ISGN,HV,PNU,PAA,PIM1,PIM2,PIPL,JAA)
CC      CALL HPRINT(816)
      ENDIF
C     =====
      RETURN
 902  WRITE(IOUT, 9020)
 9020 FORMAT(' ----- DEXAA: LACK OF INITIALISATION')
      STOP
      END
      SUBROUTINE DADMAA(MODE,ISGN,HHV,PNU,PAA,PIM1,PIM2,PIPL,JAA)
C ----------------------------------------------------------------------
* A1 DECAY UNWEIGHTED EVENTS
C ----------------------------------------------------------------------
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / DECPAR / GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL*4            GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      COMMON / TAUBMC / GAMPMC(30),GAMPER(30),NEVDEC(30)
      REAL*4            GAMPMC    ,GAMPER
      COMMON / INOUT / INUT,IOUT
      REAL  HHV(4)
      REAL  HV(4),PAA(4),PNU(4),PIM1(4),PIM2(4),PIPL(4)
      REAL  PDUM1(4),PDUM2(4),PDUM3(4),PDUM4(4),PDUM5(4)
      REAL*4 RRR(3)
      REAL*8 SWT, SSWT
      DATA PI /3.141592653589793238462643/
      DATA IWARM/0/
C
      IF(MODE.EQ.-1) THEN
C     ===================
        IWARM=1
        NEVRAW=0
        NEVACC=0
        NEVOVR=0
        SWT=0
        SSWT=0
        WTMAX=1E-20
        DO 15 I=1,500
        CALL DPHSAA(WT,HV,PDUM1,PDUM2,PDUM3,PDUM4,PDUM5,JAA)
        IF(WT.GT.WTMAX/1.2) WTMAX=WT*1.2
15      CONTINUE
CC      CALL HBOOK1(801,'WEIGHT DISTRIBUTION  DADMAA    $',100,0,2)
C
      ELSEIF(MODE.EQ. 0) THEN
C     =======================
300     CONTINUE
        IF(IWARM.EQ.0) GOTO 902
        CALL DPHSAA(WT,HV,PNU,PAA,PIM1,PIM2,PIPL,JAA)
CC      CALL HFILL(801,WT/WTMAX)
        NEVRAW=NEVRAW+1
        SWT=SWT+WT
ccM.S.>>>>>>
cc        SSWT=SSWT+WT**2
        SSWT=SSWT+dble(WT)**2
ccM.S.<<<<<<
        CALL RANMAR(RRR,3)
        RN=RRR(1)
        IF(WT.GT.WTMAX) NEVOVR=NEVOVR+1
        IF(RN*WTMAX.GT.WT) GOTO 300
C ROTATIONS TO BASIC TAU REST FRAME
        COSTHE=-1.+2.*RRR(2)
        THET=ACOS(COSTHE)
        PHI =2*PI*RRR(3)
        CALL ROTPOL(THET,PHI,PNU)
        CALL ROTPOL(THET,PHI,PAA)
        CALL ROTPOL(THET,PHI,PIM1)
        CALL ROTPOL(THET,PHI,PIM2)
        CALL ROTPOL(THET,PHI,PIPL)
        CALL ROTPOL(THET,PHI,HV)
        DO 44 I=1,3
 44     HHV(I)=-ISGN*HV(I)
        NEVACC=NEVACC+1
C
      ELSEIF(MODE.EQ. 1) THEN
C     =======================
        IF(NEVRAW.EQ.0) RETURN
        PARGAM=SWT/FLOAT(NEVRAW+1)
        ERROR=0
        IF(NEVRAW.NE.0) ERROR=SQRT(SSWT/SWT**2-1./FLOAT(NEVRAW))
        RAT=PARGAM/GAMEL
        WRITE(IOUT, 7010) NEVRAW,NEVACC,NEVOVR,PARGAM,RAT,ERROR
CC      CALL HPRINT(801)
        GAMPMC(5)=RAT
        GAMPER(5)=ERROR
CAM     NEVDEC(5)=NEVACC
      ENDIF
C     =====
      RETURN
 7003 FORMAT(///1X,15(5H*****)
     $ /,' *',     25X,'******** DADMAA INITIALISATION ********',9X,1H*
     $ /,' *',E20.5,5X,'WTMAX  = MAXIMUM WEIGHT                ',9X,1H*
     $  /,1X,15(5H*****)/)
 7010 FORMAT(///1X,15(5H*****)
     $ /,' *',     25X,'******** DADMAA FINAL REPORT  ******** ',9X,1H*
     $ /,' *',I20  ,5X,'NEVRAW = NO. OF A1  DECAYS TOTAL       ',9X,1H*
     $ /,' *',I20  ,5X,'NEVACC = NO. OF A1   DECS. ACCEPTED    ',9X,1H*
     $ /,' *',I20  ,5X,'NEVOVR = NO. OF OVERWEIGHTED EVENTS    ',9X,1H*
     $ /,' *',E20.5,5X,'PARTIAL WTDTH (A1  DECAY) IN GEV UNITS ',9X,1H*
     $ /,' *',F20.9,5X,'IN UNITS GFERMI**2*MASS**5/192/PI**3   ',9X,1H*
     $ /,' *',F20.8,5X,'RELATIVE ERROR OF PARTIAL WIDTH        ',9X,1H*
     $  /,1X,15(5H*****)/)
 902  WRITE(IOUT, 9020)
 9020 FORMAT(' ----- DADMAA: LACK OF INITIALISATION')
      STOP
      END
      SUBROUTINE DPHSAA(DGAMT,HV,PN,PAA,PIM1,PIM2,PIPL,JAA)
C ----------------------------------------------------------------------
* IT SIMULATES A1  DECAY IN TAU REST FRAME WITH
* Z-AXIS ALONG A1  MOMENTUM
C ----------------------------------------------------------------------
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / TAUKLE / BRA1,BRK0,BRK0B,BRKS
      REAL*4            BRA1,BRK0,BRK0B,BRKS
      REAL  HV(4),PN(4),PAA(4),PIM1(4),PIM2(4),PIPL(4)


      REAL*4 RRR(1)
C MATRIX ELEMENT NUMBER:
      MNUM=0
C TYPE OF THE GENERATION:
      KEYT=1
      CALL RANMAR(RRR,1)
      RMOD=RRR(1)
      IF (RMOD.LT.BRA1) THEN
       JAA=1
       AMP1=AMPI
       AMP2=AMPI
       AMP3=AMPI
      ELSE
       JAA=2
       AMP1=AMPIZ
       AMP2=AMPIZ
       AMP3=AMPI
      ENDIF
      CALL
     $   DPHTRE(DGAMT,HV,PN,PAA,PIM1,AMP1,PIM2,AMP2,PIPL,AMP3,KEYT,MNUM)
      END
      SUBROUTINE DEXKK(MODE,ISGN,POL,PKK,PNU)
C ----------------------------------------------------------------------
C TAU DECAY INTO KAON  AND TAU-NEUTRINO
C IN TAU REST FRAME
C OUTPUT FOUR MOMENTA: PNU   TAUNEUTRINO,
C                      PKK   KAON CHARGED
C ----------------------------------------------------------------------
      REAL  POL(4),HV(4),PNU(4),PKK(4)
C
      IF(MODE.EQ.-1) THEN
C     ===================
        CALL DADMKK(-1,ISGN,HV,PKK,PNU)
CC      CALL HBOOK1(815,'WEIGHT DISTRIBUTION  DEXPI    $',100,0,2)
C
      ELSEIF(MODE.EQ. 0) THEN
C     =======================
300     CONTINUE
        CALL DADMKK( 0,ISGN,HV,PKK,PNU)
        WT=(1+POL(1)*HV(1)+POL(2)*HV(2)+POL(3)*HV(3))/2.
CC      CALL HFILL(815,WT)
        CALL RANMAR(RN,1)
        IF(RN.GT.WT) GOTO 300
C
      ELSEIF(MODE.EQ. 1) THEN
C     =======================
        CALL DADMKK( 1,ISGN,HV,PKK,PNU)
CC      CALL HPRINT(815)
      ENDIF
C     =====
      RETURN
      END
      SUBROUTINE DADMKK(MODE,ISGN,HV,PKK,PNU)
C ----------------------------------------------------------------------
C FZ
      COMMON / DECPAR / GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL*4            GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / TAUBMC / GAMPMC(30),GAMPER(30),NEVDEC(30)
      REAL*4            GAMPMC    ,GAMPER
      COMMON / INOUT / INUT,IOUT
      REAL  PKK(4),PNU(4),HV(4)
      DATA PI /3.141592653589793238462643/
C
      IF(MODE.EQ.-1) THEN
C     ===================
        NEVTOT=0
      ELSEIF(MODE.EQ. 0) THEN
C     =======================
        NEVTOT=NEVTOT+1
        EKK= (AMTAU**2+AMK**2-AMNUTA**2)/(2*AMTAU)
        ENU= (AMTAU**2-AMK**2+AMNUTA**2)/(2*AMTAU)
        XKK= SQRT(EKK**2-AMK**2)
C K MOMENTUM
        CALL SPHERA(XKK,PKK)
        PKK(4)=EKK
C TAU-NEUTRINO MOMENTUM
        DO 30 I=1,3
30      PNU(I)=-PKK(I)
        PNU(4)=ENU
        PXQ=AMTAU*EKK
        PXN=AMTAU*ENU
        QXN=PKK(4)*PNU(4)-PKK(1)*PNU(1)-PKK(2)*PNU(2)-PKK(3)*PNU(3)
        BRAK=(GV**2+GA**2)*(2*PXQ*QXN-AMK**2*PXN)
     &      +(GV**2-GA**2)*AMTAU*AMNUTA*AMK**2
        DO 40 I=1,3
40      HV(I)=-ISGN*2*GA*GV*AMTAU*(2*PKK(I)*QXN-PNU(I)*AMK**2)/BRAK
        HV(4)=1
C
      ELSEIF(MODE.EQ. 1) THEN
C     =======================
        IF(NEVTOT.EQ.0) RETURN
        FKK=0.0354
CFZ THERE WAS BRAK/AMTAU**4 BEFORE
C        GAMM=(GFERMI*FKK)**2/(16.*PI)*AMTAU**3*
C     *       (BRAK/AMTAU**4)**2
CZW 7.02.93 here was an error affecting non standard model
C       configurations only
        GAMM=(GFERMI*FKK)**2/(16.*PI)*AMTAU**3*
     $       (BRAK/AMTAU**4)*
     $       SQRT((AMTAU**2-AMK**2-AMNUTA**2)**2
     $            -4*AMK**2*AMNUTA**2           )/AMTAU**2
        ERROR=0

        ERROR=0
        RAT=GAMM/GAMEL
        WRITE(IOUT, 7010) NEVTOT,GAMM,RAT,ERROR
        GAMPMC(6)=RAT
        GAMPER(6)=ERROR
CAM     NEVDEC(6)=NEVTOT
      ENDIF
C     =====
      RETURN
 7010 FORMAT(///1X,15(5H*****)
     $ /,' *',     25X,'******** DADMKK FINAL REPORT   ********',9X,1H*
     $ /,' *',I20  ,5X,'NEVTOT = NO. OF K  DECAYS TOTAL        ',9X,1H*,
     $ /,' *',E20.5,5X,'PARTIAL WTDTH ( K DECAY) IN GEV UNITS  ',9X,1H*,
     $ /,' *',F20.9,5X,'IN UNITS GFERMI**2*MASS**5/192/PI**3   ',9X,1H*
     $ /,' *',F20.8,5X,'RELATIVE ERROR OF PARTIAL WIDTH (STAT.)',9X,1H*
     $  /,1X,15(5H*****)/)
      END
      SUBROUTINE DEXKS(MODE,ISGN,POL,PNU,PKS,PKK,PPI,JKST)
C ----------------------------------------------------------------------
C THIS SIMULATES TAU DECAY IN TAU REST FRAME
C INTO NU K*, THEN K* DECAYS INTO PI0,K+-(JKST=20)
C OR PI+-,K0(JKST=10).
C OUTPUT FOUR MOMENTA: PNU   TAUNEUTRINO,
C                      PKS   K* CHARGED
C                      PK0   K ZERO
C                      PKC   K CHARGED
C                      PIC   PION CHARGED
C                      PIZ   PION ZERO
C ----------------------------------------------------------------------
      COMMON / INOUT / INUT,IOUT
      REAL  POL(4),HV(4),PKS(4),PNU(4),PKK(4),PPI(4)
      DATA IWARM/0/
C
      IF(MODE.EQ.-1) THEN
C     ===================
        IWARM=1
CFZ INITIALISATION DONE WITH THE GHARGED PION NEUTRAL KAON MODE(JKST=10
        CALL DADMKS( -1,ISGN,HV,PNU,PKS,PKK,PPI,JKST)
CC      CALL HBOOK1(816,'WEIGHT DISTRIBUTION  DEXKS    $',100,0,2)
CC      CALL HBOOK1(916,'ABS2 OF HV IN ROUTINE DEXKS   $',100,0,2)
C
      ELSEIF(MODE.EQ. 0) THEN
C     =======================
300     CONTINUE
        IF(IWARM.EQ.0) GOTO 902
        CALL DADMKS(  0,ISGN,HV,PNU,PKS,PKK,PPI,JKST)
        WT=(1+POL(1)*HV(1)+POL(2)*HV(2)+POL(3)*HV(3))/2.
CC      CALL HFILL(816,WT)
CC      XHELP=HV(1)**2+HV(2)**2+HV(3)**2
CC      CALL HFILL(916,XHELP)
        CALL RANMAR(RN,1)
        IF(RN.GT.WT) GOTO 300
C
      ELSEIF(MODE.EQ. 1) THEN
C     ======================================
        CALL DADMKS( 1,ISGN,HV,PNU,PKS,PKK,PPI,JKST)
CC      CALL HPRINT(816)
CC      CALL HPRINT(916)
      ENDIF
C     =====
      RETURN
 902  WRITE(IOUT, 9020)
 9020 FORMAT(' ----- DEXKS: LACK OF INITIALISATION')
      STOP
      END
      SUBROUTINE DADMKS(MODE,ISGN,HHV,PNU,PKS,PKK,PPI,JKST)
C ----------------------------------------------------------------------
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / DECPAR / GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL*4            GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      COMMON / TAUBMC / GAMPMC(30),GAMPER(30),NEVDEC(30)
      REAL*4            GAMPMC    ,GAMPER
      COMMON / TAUKLE / BRA1,BRK0,BRK0B,BRKS
      REAL*4            BRA1,BRK0,BRK0B,BRKS
      COMMON / INOUT / INUT,IOUT
      REAL  HHV(4)
      REAL  HV(4),PKS(4),PNU(4),PKK(4),PPI(4)
      REAL  PDUM1(4),PDUM2(4),PDUM3(4),PDUM4(4)
      REAL*4 RRR(3)
      REAL*8 SWT, SSWT
      DATA PI /3.141592653589793238462643/
      DATA IWARM/0/
C
      IF(MODE.EQ.-1) THEN
C     ===================
        IWARM=1
        NEVRAW=0
        NEVACC=0
        NEVOVR=0
        SWT=0
        SSWT=0
        WTMAX=1E-20
        DO 15 I=1,500
C THE INITIALISATION IS DONE WITH THE 66.7% MODE
        JKST=10
        CALL DPHSKS(WT,HV,PDUM1,PDUM2,PDUM3,PDUM4,JKST)
        IF(WT.GT.WTMAX/1.2) WTMAX=WT*1.2
15      CONTINUE
CC      CALL HBOOK1(801,'WEIGHT DISTRIBUTION  DADMKS    $',100,0,2)
CC      PRINT 7003,WTMAX
CC      CALL HBOOK1(112,'-------- K* MASS -------- $',100,0.,2.)
      ELSEIF(MODE.EQ. 0) THEN
C     =====================================
        IF(IWARM.EQ.0) GOTO 902
C  HERE WE CHOOSE RANDOMLY BETWEEN K0 PI+_ (66.7%)
C  AND K+_ PI0 (33.3%)
        DEC1=BRKS
400     CONTINUE
        CALL RANMAR(RMOD,1)
        IF(RMOD.LT.DEC1) THEN
          JKST=10
        ELSE
          JKST=20
        ENDIF
        CALL DPHSKS(WT,HV,PNU,PKS,PKK,PPI,JKST)
        CALL RANMAR(RRR,3)
        RN=RRR(1)
        IF(WT.GT.WTMAX) NEVOVR=NEVOVR+1
        NEVRAW=NEVRAW+1
        SWT=SWT+WT
        SSWT=SSWT+WT**2
        IF(RN*WTMAX.GT.WT) GOTO 400
C ROTATIONS TO BASIC TAU REST FRAME
        COSTHE=-1.+2.*RRR(2)
        THET=ACOS(COSTHE)
        PHI =2*PI*RRR(3)
        CALL ROTOR2(THET,PNU,PNU)
        CALL ROTOR3( PHI,PNU,PNU)
        CALL ROTOR2(THET,PKS,PKS)
        CALL ROTOR3( PHI,PKS,PKS)
        CALL ROTOR2(THET,PKK,PKK)
        CALL ROTOR3(PHI,PKK,PKK)
        CALL ROTOR2(THET,PPI,PPI)
        CALL ROTOR3( PHI,PPI,PPI)
        CALL ROTOR2(THET,HV,HV)
        CALL ROTOR3( PHI,HV,HV)
        DO 44 I=1,3
 44     HHV(I)=-ISGN*HV(I)
        NEVACC=NEVACC+1
C
      ELSEIF(MODE.EQ. 1) THEN
C     =======================
        IF(NEVRAW.EQ.0) RETURN
        PARGAM=SWT/FLOAT(NEVRAW+1)
        ERROR=0
        IF(NEVRAW.NE.0) ERROR=SQRT(SSWT/SWT**2-1./FLOAT(NEVRAW))
        RAT=PARGAM/GAMEL
        WRITE(IOUT, 7010) NEVRAW,NEVACC,NEVOVR,PARGAM,RAT,ERROR
CC      CALL HPRINT(801)
        GAMPMC(7)=RAT
        GAMPER(7)=ERROR
CAM     NEVDEC(7)=NEVACC
      ENDIF
C     =====
      RETURN
 7003 FORMAT(///1X,15(5H*****)
     $ /,' *',     25X,'******** DADMKS INITIALISATION ********',9X,1H*
     $ /,' *',E20.5,5X,'WTMAX  = MAXIMUM WEIGHT                ',9X,1H*
     $  /,1X,15(5H*****)/)
 7010 FORMAT(///1X,15(5H*****)
     $ /,' *',     25X,'******** DADMKS FINAL REPORT   ********',9X,1H*
     $ /,' *',I20  ,5X,'NEVRAW = NO. OF K* DECAYS TOTAL        ',9X,1H*,
     $ /,' *',I20  ,5X,'NEVACC = NO. OF K*  DECS. ACCEPTED     ',9X,1H*,
     $ /,' *',I20  ,5X,'NEVOVR = NO. OF OVERWEIGHTED EVENTS    ',9X,1H*
     $ /,' *',E20.5,5X,'PARTIAL WTDTH (K* DECAY) IN GEV UNITS  ',9X,1H*,
     $ /,' *',F20.9,5X,'IN UNITS GFERMI**2*MASS**5/192/PI**3   ',9X,1H*
     $ /,' *',F20.8,5X,'RELATIVE ERROR OF PARTIAL WIDTH        ',9X,1H*
     $  /,1X,15(5H*****)/)
 902  WRITE(IOUT, 9020)
 9020 FORMAT(' ----- DADMKS: LACK OF INITIALISATION')
      STOP
      END
      SUBROUTINE DPHSKS(DGAMT,HV,PN,PKS,PKK,PPI,JKST)
C ----------------------------------------------------------------------
C IT SIMULATES KAON* DECAY IN TAU REST FRAME WITH
C Z-AXIS ALONG KAON* MOMENTUM
C     JKST=10 FOR K* --->K0 + PI+-
C     JKST=20 FOR K* --->K+- + PI0
C ----------------------------------------------------------------------
      COMMON / DECPAR / GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL*4            GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      REAL  HV(4),PT(4),PN(4),PKS(4),PKK(4),PPI(4),QQ(4)
      COMPLEX BWIGS
      DATA PI /3.141592653589793238462643/
C
      DATA ICONT /0/
C THREE BODY PHASE SPACE NORMALISED AS IN BJORKEN-DRELL
      PHSPAC=1./2**11/PI**5
C TAU MOMENTUM
      PT(1)=0.
      PT(2)=0.
      PT(3)=0.
      PT(4)=AMTAU
      CALL RANMAR(RR1,1)
C HERE BEGIN THE K0,PI+_ DECAY
      IF(JKST.EQ.10)THEN
C     ==================
C MASS OF (REAL/VIRTUAL) K*
        AMS1=(AMPI+AMKZ)**2
        AMS2=(AMTAU-AMNUTA)**2
C FLAT PHASE SPACE
C       AMX2=AMS1+   RR1*(AMS2-AMS1)
C       AMX=SQRT(AMX2)
C       PHSPAC=PHSPAC*(AMS2-AMS1)
C PHASE SPACE WITH SAMPLING FOR K* RESONANCE
        ALP1=ATAN((AMS1-AMKST**2)/AMKST/GAMKST)
        ALP2=ATAN((AMS2-AMKST**2)/AMKST/GAMKST)
        ALP=ALP1+RR1*(ALP2-ALP1)
        AMX2=AMKST**2+AMKST*GAMKST*TAN(ALP)
        AMX=SQRT(AMX2)
        PHSPAC=PHSPAC*((AMX2-AMKST**2)**2+(AMKST*GAMKST)**2)
     &                /(AMKST*GAMKST)
        PHSPAC=PHSPAC*(ALP2-ALP1)
C
C TAU-NEUTRINO MOMENTUM
        PN(1)=0
        PN(2)=0
        PN(4)=1./(2*AMTAU)*(AMTAU**2+AMNUTA**2-AMX**2)
        PN(3)=-SQRT((PN(4)-AMNUTA)*(PN(4)+AMNUTA))
C
C K* MOMENTUM
        PKS(1)=0
        PKS(2)=0
        PKS(4)=1./(2*AMTAU)*(AMTAU**2-AMNUTA**2+AMX**2)
        PKS(3)=-PN(3)
        PHSPAC=PHSPAC*(4*PI)*(2*PKS(3)/AMTAU)
C
CAM
        ENPI=( AMX**2+AMPI**2-AMKZ**2 ) / ( 2*AMX )
        PPPI=SQRT((ENPI-AMPI)*(ENPI+AMPI))
        PHSPAC=PHSPAC*(4*PI)*(2*PPPI/AMX)
C CHARGED PI MOMENTUM IN KAON* REST FRAME
        CALL SPHERA(PPPI,PPI)
        PPI(4)=ENPI
C NEUTRAL KAON MOMENTUM IN K* REST FRAME
        DO 20 I=1,3
20      PKK(I)=-PPI(I)
        PKK(4)=( AMX**2+AMKZ**2-AMPI**2 ) / ( 2*AMX )
        EXE=(PKS(4)+PKS(3))/AMX
C PION AND K  BOOSTED FROM K* REST FRAME TO TAU REST FRAME
        CALL BOSTR3(EXE,PPI,PPI)
        CALL BOSTR3(EXE,PKK,PKK)
        DO 30 I=1,4
30      QQ(I)=PPI(I)-PKK(I)
C QQ transverse to PKS
        PKSD =PKS(4)*PKS(4)-PKS(3)*PKS(3)-PKS(2)*PKS(2)-PKS(1)*PKS(1)
        QQPKS=PKS(4)* QQ(4)-PKS(3)* QQ(3)-PKS(2)* QQ(2)-PKS(1)* QQ(1)
        DO 31 I=1,4
31      QQ(I)=QQ(I)-PKS(I)*QQPKS/PKSD
C AMPLITUDE
        PRODPQ=PT(4)*QQ(4)
        PRODNQ=PN(4)*QQ(4)-PN(1)*QQ(1)-PN(2)*QQ(2)-PN(3)*QQ(3)
        PRODPN=PT(4)*PN(4)
        QQ2= QQ(4)**2-QQ(1)**2-QQ(2)**2-QQ(3)**2
        BRAK=(GV**2+GA**2)*(2*PRODPQ*PRODNQ-PRODPN*QQ2)
     &      +(GV**2-GA**2)*AMTAU*AMNUTA*QQ2
C A SIMPLE BREIT-WIGNER IS CHOSEN FOR K* RESONANCE
        FKS=CABS(BWIGS(AMX2,AMKST,GAMKST))**2
        AMPLIT=(GFERMI*SCABIB)**2*BRAK*2*FKS
        DGAMT=1/(2.*AMTAU)*AMPLIT*PHSPAC
        DO 40 I=1,3
 40     HV(I)=2*GV*GA*AMTAU*(2*PRODNQ*QQ(I)-QQ2*PN(I))/BRAK
C
C HERE BEGIN THE K+-,PI0 DECAY
      ELSEIF(JKST.EQ.20)THEN
C     ======================
C MASS OF (REAL/VIRTUAL) K*
        AMS1=(AMPIZ+AMK)**2
        AMS2=(AMTAU-AMNUTA)**2
C FLAT PHASE SPACE
C       AMX2=AMS1+   RR1*(AMS2-AMS1)
C       AMX=SQRT(AMX2)
C       PHSPAC=PHSPAC*(AMS2-AMS1)
C PHASE SPACE WITH SAMPLING FOR K* RESONANCE
        ALP1=ATAN((AMS1-AMKST**2)/AMKST/GAMKST)
        ALP2=ATAN((AMS2-AMKST**2)/AMKST/GAMKST)
        ALP=ALP1+RR1*(ALP2-ALP1)
        AMX2=AMKST**2+AMKST*GAMKST*TAN(ALP)
        AMX=SQRT(AMX2)
        PHSPAC=PHSPAC*((AMX2-AMKST**2)**2+(AMKST*GAMKST)**2)
     &                /(AMKST*GAMKST)
        PHSPAC=PHSPAC*(ALP2-ALP1)
C
C TAU-NEUTRINO MOMENTUM
        PN(1)=0
        PN(2)=0
        PN(4)=1./(2*AMTAU)*(AMTAU**2+AMNUTA**2-AMX**2)
        PN(3)=-SQRT((PN(4)-AMNUTA)*(PN(4)+AMNUTA))
C KAON* MOMENTUM
        PKS(1)=0
        PKS(2)=0
        PKS(4)=1./(2*AMTAU)*(AMTAU**2-AMNUTA**2+AMX**2)
        PKS(3)=-PN(3)
        PHSPAC=PHSPAC*(4*PI)*(2*PKS(3)/AMTAU)
C
CAM
        ENPI=( AMX**2+AMPIZ**2-AMK**2 ) / ( 2*AMX )
        PPPI=SQRT((ENPI-AMPIZ)*(ENPI+AMPIZ))
        PHSPAC=PHSPAC*(4*PI)*(2*PPPI/AMX)
C NEUTRAL PI MOMENTUM IN K* REST FRAME
        CALL SPHERA(PPPI,PPI)
        PPI(4)=ENPI
C CHARGED KAON MOMENTUM IN K* REST FRAME
        DO 50 I=1,3
50      PKK(I)=-PPI(I)
        PKK(4)=( AMX**2+AMK**2-AMPIZ**2 ) / ( 2*AMX )
        EXE=(PKS(4)+PKS(3))/AMX
C PION AND K  BOOSTED FROM K* REST FRAME TO TAU REST FRAME
        CALL BOSTR3(EXE,PPI,PPI)
        CALL BOSTR3(EXE,PKK,PKK)
        DO 60 I=1,4
60      QQ(I)=PKK(I)-PPI(I)
C QQ transverse to PKS
        PKSD =PKS(4)*PKS(4)-PKS(3)*PKS(3)-PKS(2)*PKS(2)-PKS(1)*PKS(1)
        QQPKS=PKS(4)* QQ(4)-PKS(3)* QQ(3)-PKS(2)* QQ(2)-PKS(1)* QQ(1)
        DO 61 I=1,4
61      QQ(I)=QQ(I)-PKS(I)*QQPKS/PKSD
C AMPLITUDE
        PRODPQ=PT(4)*QQ(4)
        PRODNQ=PN(4)*QQ(4)-PN(1)*QQ(1)-PN(2)*QQ(2)-PN(3)*QQ(3)
        PRODPN=PT(4)*PN(4)
        QQ2= QQ(4)**2-QQ(1)**2-QQ(2)**2-QQ(3)**2
        BRAK=(GV**2+GA**2)*(2*PRODPQ*PRODNQ-PRODPN*QQ2)
     &      +(GV**2-GA**2)*AMTAU*AMNUTA*QQ2
C A SIMPLE BREIT-WIGNER IS CHOSEN FOR THE K* RESONANCE
        FKS=CABS(BWIGS(AMX2,AMKST,GAMKST))**2
        AMPLIT=(GFERMI*SCABIB)**2*BRAK*2*FKS
        DGAMT=1/(2.*AMTAU)*AMPLIT*PHSPAC
        DO 70 I=1,3
 70     HV(I)=2*GV*GA*AMTAU*(2*PRODNQ*QQ(I)-QQ2*PN(I))/BRAK
      ENDIF
      RETURN
      END




      SUBROUTINE DPHNPI(DGAMT,HVX,PNX,PRX,PPIX,JNPI)
C ----------------------------------------------------------------------
C IT SIMULATES MULTIPI DECAY IN TAU REST FRAME WITH
C Z-AXIS OPPOSITE TO NEUTRINO MOMENTUM
C ----------------------------------------------------------------------
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / DECPAR / GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL*4            GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      PARAMETER (NMODE=15,NM1=0,NM2=1,NM3=8,NM4=2,NM5=1,NM6=3)
      COMMON / DECOMP /IDFFIN(9,NMODE),MULPIK(NMODE)
     &                ,NAMES
      CHARACTER NAMES(NMODE)*31
      REAL*8 WETMAX(20)
C
      REAL*8  PN(4),PR(4),PPI(4,9),HV(4)
      REAL*4  PNX(4),PRX(4),PPIX(4,9),HVX(4)
      REAL*8  PV(5,9),PT(4),UE(3),BE(3)
      REAL*8  PAWT,AMX,AMS1,AMS2,PA,PHS,PHSMAX,PMIN,PMAX
!!! M.S. to fix underflow >>>
      REAL*8  PHSPAC
!!! M.S. to fix underflow <<<
      REAL*8  GAM,BEP,PHI,A,B,C
      REAL*8  AMPIK
      REAL*4 RRR(9),RRX(2)
C
      DATA PI /3.141592653589793238462643/
      DATA WETMAX /20*1D-15/
C
CC--      PAWT(A,B,C)=SQRT((A**2-(B+C)**2)*(A**2-(B-C)**2))/(2.*A)
C
      PAWT(A,B,C)=
     $  SQRT(MAX(0.D0,(A**2-(B+C)**2)*(A**2-(B-C)**2)))/(2.D0*A)
C
      AMPIK(I,J)=DCDMAS(IDFFIN(I,J))
C
C
      IF ((JNPI.LE.0).OR.JNPI.GT.20) THEN
       WRITE(6,*) 'JNPI OUTSIDE RANGE DEFINED BY WETMAX; JNPI=',JNPI
       STOP
      ENDIF

C TAU MOMENTUM
      PT(1)=0.
      PT(2)=0.
      PT(3)=0.
      PT(4)=AMTAU
C
 500  CONTINUE
C MASS OF VIRTUAL W
      ND=MULPIK(JNPI)
      PS=0.
      PHSPAC = 1./2.**5 /PI**2
      DO 4 I=1,ND
4     PS  =PS+AMPIK(I,JNPI)
      CALL RANMAR(RR1,1)
      AMS1=PS**2
      AMS2=(AMTAU-AMNUTA)**2
C
C
      AMX2=AMS1+   RR1*(AMS2-AMS1)
      AMX =SQRT(AMX2)
      AMW =AMX
      PHSPAC=PHSPAC * (AMS2-AMS1)
C
C TAU-NEUTRINO MOMENTUM
      PN(1)=0
      PN(2)=0
      PN(4)=1./(2*AMTAU)*(AMTAU**2+AMNUTA**2-AMX2)
      PN(3)=-SQRT((PN(4)-AMNUTA)*(PN(4)+AMNUTA))
C W MOMENTUM
      PR(1)=0
      PR(2)=0
      PR(4)=1./(2*AMTAU)*(AMTAU**2-AMNUTA**2+AMX2)
      PR(3)=-PN(3)
      PHSPAC=PHSPAC * (4.*PI) * (2.*PR(3)/AMTAU)
C
C AMPLITUDE  (cf YS.Tsai Phys.Rev.D4,2821(1971)
C    or F.Gilman SH.Rhie Phys.Rev.D31,1066(1985)
C
        PXQ=AMTAU*PR(4)
        PXN=AMTAU*PN(4)
        QXN=PR(4)*PN(4)-PR(1)*PN(1)-PR(2)*PN(2)-PR(3)*PN(3)
C HERE WAS AN ERROR. 20.10.91 (ZW)
C       BRAK=2*(GV**2+GA**2)*(2*PXQ*PXN+AMX2*QXN)
        BRAK=2*(GV**2+GA**2)*(2*PXQ*QXN+AMX2*PXN)
     &      -6*(GV**2-GA**2)*AMTAU*AMNUTA*AMX2
CAM     Assume neutrino mass=0. and sum over final polarisation
C     BRAK= 2*(AMTAU**2-AMX2) * (AMTAU**2+2.*AMX2)
      AMPLIT=CCABIB**2*GFERMI**2/2. * BRAK * AMX2*SIGEE(AMX2,JNPI)
      DGAMT=1./(2.*AMTAU)*AMPLIT*PHSPAC
C
C   ISOTROPIC W DECAY IN W REST FRAME
      PHSMAX = 1.
      DO 200 I=1,4
  200 PV(I,1)=PR(I)
      PV(5,1)=AMW
      PV(5,ND)=AMPIK(ND,JNPI)
C    COMPUTE MAX. PHASE SPACE FACTOR
      PMAX=AMW-PS+AMPIK(ND,JNPI)
      PMIN=.0
      DO 220 IL=ND-1,1,-1
      PMAX=PMAX+AMPIK(IL,JNPI)
      PMIN=PMIN+AMPIK(IL+1,JNPI)
  220 PHSMAX=PHSMAX*PAWT(PMAX,PMIN,AMPIK(IL,JNPI))/PMAX

C --- 2.02.94 ZW  9 lines
      AMX=AMW
      DO 222 IL=1,ND-2
      AMS1=.0
      DO 223 JL=IL+1,ND
 223  AMS1=AMS1+AMPIK(JL,JNPI)
      AMS1=AMS1**2
      AMX =(AMX-AMPIK(IL,JNPI))
      AMS2=(AMX)**2
      PHSMAX=PHSMAX * (AMS2-AMS1)
 222  CONTINUE
      NCONT=0
  100 CONTINUE
      NCONT=NCONT+1
CAM  GENERATE ND-2 EFFECTIVE MASSES
      PHS=1.D0
      PHSPAC = 1./2.**(6*ND-7) /PI**(3*ND-4)
      AMX=AMW
      CALL RANMAR(RRR,ND-2)
      DO 230 IL=1,ND-2
      AMS1=.0D0
      DO 231 JL=IL+1,ND
  231 AMS1=AMS1+AMPIK(JL,JNPI)
      AMS1=AMS1**2
      AMS2=(AMX-AMPIK(IL,JNPI))**2
      RR1=RRR(IL)
      AMX2=AMS1+  RR1*(AMS2-AMS1)
      AMX=SQRT(AMX2)
      PV(5,IL+1)=AMX
      PHSPAC=PHSPAC * (AMS2-AMS1)
C ---  2.02.94 ZW 1 line
      PHS=PHS* (AMS2-AMS1)
      PA=PAWT(PV(5,IL),PV(5,IL+1),AMPIK(IL,JNPI))
      PHS   =PHS    *PA/PV(5,IL)
  230 CONTINUE
      PA=PAWT(PV(5,ND-1),AMPIK(ND-1,JNPI),AMPIK(ND,JNPI))
      PHS   =PHS    *PA/PV(5,ND-1)
      CALL RANMAR(RN,1)
      WETMAX(JNPI)=1.2D0*MAX(WETMAX(JNPI)/1.2D0,PHS/PHSMAX)
      IF (NCONT.EQ.500 000) THEN
          XNPI=0.0
          DO KK=1,ND
            XNPI=XNPI+AMPIK(KK,JNPI)
          ENDDO
       WRITE(6,*) 'ROUNDING INSTABILITY IN DPHNPI ?'
       WRITE(6,*) 'AMW=',AMW,'XNPI=',XNPI
       WRITE(6,*) 'IF =AMW= IS NEARLY EQUAL =XNPI= THAT IS IT'
       WRITE(6,*) 'PHS=',PHS,'PHSMAX=',PHSMAX
       GOTO 500
      ENDIF
      IF(RN*PHSMAX*WETMAX(JNPI).GT.PHS) GO TO 100
C...PERFORM SUCCESSIVE TWO-PARTICLE DECAYS IN RESPECTIVE CM FRAME
  280 DO 300 IL=1,ND-1
      PA=PAWT(PV(5,IL),PV(5,IL+1),AMPIK(IL,JNPI))
      CALL RANMAR(RRX,2)
      UE(3)=2.*RRX(1)-1.
      PHI=2.*PI*RRX(2)
      UE(1)=SQRT(1.D0-UE(3)**2)*COS(PHI)
      UE(2)=SQRT(1.D0-UE(3)**2)*SIN(PHI)
      DO 290 J=1,3
      PPI(J,IL)=PA*UE(J)
  290 PV(J,IL+1)=-PA*UE(J)
      PPI(4,IL)=SQRT(PA**2+AMPIK(IL,JNPI)**2)
      PV(4,IL+1)=SQRT(PA**2+PV(5,IL+1)**2)
      PHSPAC=PHSPAC *(4.*PI)*(2.*PA/PV(5,IL))
  300 CONTINUE
C...LORENTZ TRANSFORM DECAY PRODUCTS TO TAU FRAME
      DO 310 J=1,4
  310 PPI(J,ND)=PV(J,ND)
      DO 340 IL=ND-1,1,-1
      DO 320 J=1,3
  320 BE(J)=PV(J,IL)/PV(4,IL)
      GAM=PV(4,IL)/PV(5,IL)
      DO 340 I=IL,ND
      BEP=BE(1)*PPI(1,I)+BE(2)*PPI(2,I)+BE(3)*PPI(3,I)
      DO 330 J=1,3
  330 PPI(J,I)=PPI(J,I)+GAM*(GAM*BEP/(1.D0+GAM)+PPI(4,I))*BE(J)
      PPI(4,I)=GAM*(PPI(4,I)+BEP)
  340 CONTINUE
C
            HV(4)=1.
            HV(3)=0.
            HV(2)=0.
            HV(1)=0.
      DO K=1,4
        PNX(K)=PN(K)
        PRX(K)=PR(K)
        HVX(K)=HV(K)
        DO L=1,ND
          PPIX(K,L)=PPI(K,L)
        ENDDO
      ENDDO
      RETURN
      END
      FUNCTION SIGEE(Q2,JNP)
C ----------------------------------------------------------------------
C  e+e- cross section in the (1.GEV2,AMTAU**2) region
C  normalised to sig0 = 4/3 pi alfa2
C  used in matrix element for multipion tau decays
C  cf YS.Tsai        Phys.Rev D4 ,2821(1971)
C     F.Gilman et al Phys.Rev D17,1846(1978)
C     C.Kiesling, to be pub. in High Energy e+e- Physics (1988)
C  DATSIG(*,1) = e+e- -> pi+pi-2pi0
C  DATSIG(*,2) = e+e- -> 2pi+2pi-
C  DATSIG(*,3) = 5-pion contribution (a la TN.Pham et al)
C                (Phys Lett 78B,623(1978)
C  DATSIG(*,5) = e+e- -> 6pi
C
C  4- and 6-pion cross sections from data
C  5-pion contribution related to 4-pion cross section
C
C     Called by DPHNPI
C ----------------------------------------------------------------------
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
        REAL*4 DATSIG(17,6)
C
      DATA DATSIG/
     1  7.40,12.00,16.15,21.25,24.90,29.55,34.15,37.40,37.85,37.40,
     2 36.00,33.25,30.50,27.70,24.50,21.25,18.90,
     3  1.24, 2.50, 3.70, 5.40, 7.45,10.75,14.50,18.20,22.30,28.90,
     4 29.35,25.60,22.30,18.60,14.05,11.60, 9.10,
     5 17*.0,
     6 17*.0,
     7 9*.0,.65,1.25,2.20,3.15,5.00,5.75,7.80,8.25,
     8 17*.0/
      DATA SIG0 / 86.8 /
      DATA PI /3.141592653589793238462643/
      DATA INIT / 0 /
C
        JNPI=JNP
        IF(JNP.EQ.4) JNPI=3
        IF(JNP.EQ.3) JNPI=4
      IF(INIT.EQ.0) THEN
        INIT=1
        AMPI2=AMPI**2
        FPI = .943*AMPI
        DO 100 I=1,17
        DATSIG(I,2) = DATSIG(I,2)/2.
        DATSIG(I,1) = DATSIG(I,1) + DATSIG(I,2)
        S = 1.025+(I-1)*.05
        FACT=0.
        S2=S**2
        DO 200 J=1,17
        T= 1.025+(J-1)*.05
        IF(T . GT. S-AMPI ) GO TO 201
        T2=T**2
        FACT=(T2/S2)**2*SQRT((S2-T2-AMPI2)**2-4.*T2*AMPI2)/S2 *2.*T*.05
        FACT = FACT * (DATSIG(J,1)+DATSIG(J+1,1))
 200    DATSIG(I,3) = DATSIG(I,3) + FACT
 201    DATSIG(I,3) = DATSIG(I,3) /(2*PI*FPI)**2
        DATSIG(I,4) = DATSIG(I,3)
        DATSIG(I,6) = DATSIG(I,5)
 100    CONTINUE
C       WRITE(6,1000) DATSIG
 1000   FORMAT(///1X,' EE SIGMA USED IN MULTIPI DECAYS'/
     %        (17F7.2/))
      ENDIF
      Q=SQRT(Q2)
      QMIN=1.
      IF(Q.LT.QMIN) THEN
        SIGEE=DATSIG(1,JNPI)+
     &       (DATSIG(2,JNPI)-DATSIG(1,JNPI))*(Q-1.)/.05
      ELSEIF(Q.LT.1.8) THEN
        DO 1 I=1,16
        QMAX = QMIN + .05
        IF(Q.LT.QMAX) GO TO 2
        QMIN = QMIN + .05
 1      CONTINUE
 2      SIGEE=DATSIG(I,JNPI)+
     &       (DATSIG(I+1,JNPI)-DATSIG(I,JNPI)) * (Q-QMIN)/.05
      ELSEIF(Q.GT.1.8) THEN
        SIGEE=DATSIG(17,JNPI)+
     &       (DATSIG(17,JNPI)-DATSIG(16,JNPI)) * (Q-1.8)/.05
      ENDIF
      IF(SIGEE.LT..0) SIGEE=0.
C
      SIGEE = SIGEE/(6.*PI**2*SIG0)
C
      RETURN
      END

      FUNCTION SIGOLD(Q2,JNPI)
C ----------------------------------------------------------------------
C  e+e- cross section in the (1.GEV2,AMTAU**2) region
C  normalised to sig0 = 4/3 pi alfa2
C  used in matrix element for multipion tau decays
C  cf YS.Tsai        Phys.Rev D4 ,2821(1971)
C     F.Gilman et al Phys.Rev D17,1846(1978)
C     C.Kiesling, to be pub. in High Energy e+e- Physics (1988)
C  DATSIG(*,1) = e+e- -> pi+pi-2pi0
C  DATSIG(*,2) = e+e- -> 2pi+2pi-
C  DATSIG(*,3) = 5-pion contribution (a la TN.Pham et al)
C                (Phys Lett 78B,623(1978)
C  DATSIG(*,4) = e+e- -> 6pi
C
C  4- and 6-pion cross sections from data
C  5-pion contribution related to 4-pion cross section
C
C     Called by DPHNPI
C ----------------------------------------------------------------------
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      REAL*4 DATSIG(17,4)
C
      DATA DATSIG/
     1  7.40,12.00,16.15,21.25,24.90,29.55,34.15,37.40,37.85,37.40,
     2 36.00,33.25,30.50,27.70,24.50,21.25,18.90,
     3  1.24, 2.50, 3.70, 5.40, 7.45,10.75,14.50,18.20,22.30,28.90,
     4 29.35,25.60,22.30,18.60,14.05,11.60, 9.10,
     5 17*.0,
     6 9*.0,.65,1.25,2.20,3.15,5.00,5.75,7.80,8.25/
      DATA SIG0 / 86.8 /
      DATA PI /3.141592653589793238462643/
      DATA INIT / 0 /
C
      IF(INIT.EQ.0) THEN
        INIT=1
        AMPI2=AMPI**2
        FPI = .943*AMPI
        DO 100 I=1,17
        DATSIG(I,2) = DATSIG(I,2)/2.
        DATSIG(I,1) = DATSIG(I,1) + DATSIG(I,2)
        S = 1.025+(I-1)*.05
        FACT=0.
        S2=S**2
        DO 200 J=1,17
        T= 1.025+(J-1)*.05
        IF(T . GT. S-AMPI ) GO TO 201
        T2=T**2
        FACT=(T2/S2)**2*SQRT((S2-T2-AMPI2)**2-4.*T2*AMPI2)/S2 *2.*T*.05
        FACT = FACT * (DATSIG(J,1)+DATSIG(J+1,1))
 200    DATSIG(I,3) = DATSIG(I,3) + FACT
 201    DATSIG(I,3) = DATSIG(I,3) /(2*PI*FPI)**2
 100    CONTINUE
C       WRITE(6,1000) DATSIG
 1000   FORMAT(///1X,' EE SIGMA USED IN MULTIPI DECAYS'/
     %        (17F7.2/))
      ENDIF
      Q=SQRT(Q2)
      QMIN=1.
      IF(Q.LT.QMIN) THEN
        SIGEE=DATSIG(1,JNPI)+
     &       (DATSIG(2,JNPI)-DATSIG(1,JNPI))*(Q-1.)/.05
      ELSEIF(Q.LT.1.8) THEN
        DO 1 I=1,16
        QMAX = QMIN + .05
        IF(Q.LT.QMAX) GO TO 2
        QMIN = QMIN + .05
 1      CONTINUE
 2      SIGEE=DATSIG(I,JNPI)+
     &       (DATSIG(I+1,JNPI)-DATSIG(I,JNPI)) * (Q-QMIN)/.05
      ELSEIF(Q.GT.1.8) THEN
        SIGEE=DATSIG(17,JNPI)+
     &       (DATSIG(17,JNPI)-DATSIG(16,JNPI)) * (Q-1.8)/.05
      ENDIF
      IF(SIGEE.LT..0) SIGEE=0.
C
      SIGEE = SIGEE/(6.*PI**2*SIG0)
      SIGOLD=SIGEE
C
      RETURN
      END
      SUBROUTINE DPHSPK(DGAMT,HV,PN,PAA,PNPI,JAA)
C ----------------------------------------------------------------------
* IT SIMULATES THREE PI (K) DECAY IN THE TAU REST FRAME
* Z-AXIS ALONG HADRONIC SYSTEM
C ----------------------------------------------------------------------
      PARAMETER (NMODE=15,NM1=0,NM2=1,NM3=8,NM4=2,NM5=1,NM6=3)
      COMMON / DECOMP /IDFFIN(9,NMODE),MULPIK(NMODE)
     &                ,NAMES
      CHARACTER NAMES(NMODE)*31

      REAL  HV(4),PN(4),PAA(4),PIM1(4),PIM2(4),PIPL(4),PNPI(4,9)
C MATRIX ELEMENT NUMBER:
      MNUM=JAA
C TYPE OF THE GENERATION:
      KEYT=4
      IF(JAA.EQ.7) KEYT=3
C --- MASSES OF THE DECAY PRODUCTS
       AMP1=DCDMAS(IDFFIN(1,JAA+NM4+NM5+NM6))
       AMP2=DCDMAS(IDFFIN(2,JAA+NM4+NM5+NM6))
       AMP3=DCDMAS(IDFFIN(3,JAA+NM4+NM5+NM6))
      CALL
     $   DPHTRE(DGAMT,HV,PN,PAA,PIM1,AMP1,PIM2,AMP2,PIPL,AMP3,KEYT,MNUM)
            DO I=1,4
              PNPI(I,1)=PIM1(I)
              PNPI(I,2)=PIM2(I)
              PNPI(I,3)=PIPL(I)
            ENDDO
      END




      SUBROUTINE DPHTRE(DGAMT,HV,PN,PAA,PIM1,AMPA,PIM2,AMPB,PIPL,AMP3,
     &                                                      KEYT,MNUM)
C ----------------------------------------------------------------------
* IT SIMULATES A1  DECAY IN TAU REST FRAME WITH
* Z-AXIS ALONG A1  MOMENTUM
* it can be also used to generate K K pi and K pi pi tau decays.
* INPUT PARAMETERS
* KEYT - algorithm controlling switch
*  2   - flat phase space PIM1 PIM2 symmetrized statistical factor 1/2
*  1   - like 1 but peaked around a1 and rho (two channels) masses.
*  3   - peaked around omega, all particles different
* other- flat phase space, all particles different
* AMP1 - mass of first pi, etc. (1-3)
* MNUM - matrix element type
*  0   - a1 matrix element
* 1-6  - matrix element for K pi pi, K K pi decay modes
*  7   - pi- pi0 gamma matrix element
C ----------------------------------------------------------------------
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / DECPAR / GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL*4            GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL  HV(4),PT(4),PN(4),PAA(4),PIM1(4),PIM2(4),PIPL(4)
      REAL  PR(4)
      REAL*4 RRR(5)
      DATA PI /3.141592653589793238462643/
      DATA ICONT /0/
      XLAM(X,Y,Z)=SQRT(ABS((X-Y-Z)**2-4.0*Y*Z))
C AMRO, GAMRO IS ONLY A PARAMETER FOR GETING HIGHT EFFICIENCY
C
C THREE BODY PHASE SPACE NORMALISED AS IN BJORKEN-DRELL
C D**3 P /2E/(2PI)**3 (2PI)**4 DELTA4(SUM P)
      PHSPAC=1./2**17/PI**8
C TAU MOMENTUM
      PT(1)=0.
      PT(2)=0.
      PT(3)=0.
      PT(4)=AMTAU
C
      CALL RANMAR(RRR,5)
      RR=RRR(5)
C
      CALL CHOICE(MNUM,RR,ICHAN,PROB1,PROB2,PROB3,
     $            AMRX,GAMRX,AMRA,GAMRA,AMRB,GAMRB)
      IF     (ICHAN.EQ.1) THEN
        AMP1=AMPB
        AMP2=AMPA
      ELSEIF (ICHAN.EQ.2) THEN
        AMP1=AMPA
        AMP2=AMPB
      ELSE
        AMP1=AMPB
        AMP2=AMPA
      ENDIF
CAM
        RR1=RRR(1)
        AMS1=(AMP1+AMP2+AMP3)**2
        AMS2=(AMTAU-AMNUTA)**2
* PHASE SPACE WITH SAMPLING FOR A1  RESONANCE
        ALP1=ATAN((AMS1-AMRX**2)/AMRX/GAMRX)
        ALP2=ATAN((AMS2-AMRX**2)/AMRX/GAMRX)
        ALP=ALP1+RR1*(ALP2-ALP1)
        AM3SQ =AMRX**2+AMRX*GAMRX*TAN(ALP)
        AM3 =SQRT(AM3SQ)
        PHSPAC=PHSPAC*((AM3SQ-AMRX**2)**2+(AMRX*GAMRX)**2)/(AMRX*GAMRX)
        PHSPAC=PHSPAC*(ALP2-ALP1)
C MASS OF (REAL/VIRTUAL) RHO -
        RR2=RRR(2)
        AMS1=(AMP2+AMP3)**2
        AMS2=(AM3-AMP1)**2
      IF (ICHAN.LE.2) THEN
* PHASE SPACE WITH SAMPLING FOR RHO RESONANCE,
        ALP1=ATAN((AMS1-AMRA**2)/AMRA/GAMRA)
        ALP2=ATAN((AMS2-AMRA**2)/AMRA/GAMRA)
        ALP=ALP1+RR2*(ALP2-ALP1)
        AM2SQ =AMRA**2+AMRA*GAMRA*TAN(ALP)
        AM2 =SQRT(AM2SQ)
C --- THIS PART OF THE JACOBIAN WILL BE RECOVERED LATER ---------------
C     PHSPAC=PHSPAC*(ALP2-ALP1)
C     PHSPAC=PHSPAC*((AM2SQ-AMRA**2)**2+(AMRA*GAMRA)**2)/(AMRA*GAMRA)
C----------------------------------------------------------------------
      ELSE
* FLAT PHASE SPACE;
        AM2SQ=AMS1+   RR2*(AMS2-AMS1)
        AM2 =SQRT(AM2SQ)
        PHF0=(AMS2-AMS1)
      ENDIF
* RHO RESTFRAME, DEFINE PIPL AND PIM1
        ENQ1=(AM2SQ-AMP2**2+AMP3**2)/(2*AM2)
        ENQ2=(AM2SQ+AMP2**2-AMP3**2)/(2*AM2)
        PPI=         ENQ1**2-AMP3**2
        PPPI=SQRT(ABS(ENQ1**2-AMP3**2))
C --- this part of jacobian will be recovered later
        PHF1=(4*PI)*(2*PPPI/AM2)
* PI MINUS MOMENTUM IN RHO REST FRAME
        CALL SPHERA(PPPI,PIPL)
        PIPL(4)=ENQ1
* PI0 1 MOMENTUM IN RHO REST FRAME
        DO 30 I=1,3
 30     PIM1(I)=-PIPL(I)
        PIM1(4)=ENQ2
* A1 REST FRAME, DEFINE PIM2
*       RHO  MOMENTUM
        PR(1)=0
        PR(2)=0
        PR(4)=1./(2*AM3)*(AM3**2+AM2**2-AMP1**2)
        PR(3)= SQRT(ABS(PR(4)**2-AM2**2))
        PPI  =          PR(4)**2-AM2**2
*       PI0 2 MOMENTUM
        PIM2(1)=0
        PIM2(2)=0
        PIM2(4)=1./(2*AM3)*(AM3**2-AM2**2+AMP1**2)
        PIM2(3)=-PR(3)
      PHF2=(4*PI)*(2*PR(3)/AM3)
* OLD PIONS BOOSTED FROM RHO REST FRAME TO A1 REST FRAME
      EXE=(PR(4)+PR(3))/AM2
      CALL BOSTR3(EXE,PIPL,PIPL)
      CALL BOSTR3(EXE,PIM1,PIM1)
      RR3=RRR(3)
      RR4=RRR(4)
CAM   THET =PI*RR3
      THET =ACOS(-1.+2*RR3)
      PHI = 2*PI*RR4
      CALL ROTPOL(THET,PHI,PIPL)
      CALL ROTPOL(THET,PHI,PIM1)
      CALL ROTPOL(THET,PHI,PIM2)
      CALL ROTPOL(THET,PHI,PR)
C
* NOW TO THE TAU REST FRAME, DEFINE A1 AND NEUTRINO MOMENTA
* A1  MOMENTUM
      PAA(1)=0
      PAA(2)=0
      PAA(4)=1./(2*AMTAU)*(AMTAU**2-AMNUTA**2+AM3**2)
      PAA(3)= SQRT(ABS(PAA(4)**2-AM3**2))
      PPI   =          PAA(4)**2-AM3**2
      PHSPAC=PHSPAC*(4*PI)*(2*PAA(3)/AMTAU)
* TAU-NEUTRINO MOMENTUM
      PN(1)=0
      PN(2)=0
      PN(4)=1./(2*AMTAU)*(AMTAU**2+AMNUTA**2-AM3**2)
      PN(3)=-PAA(3)
C HERE WE CORRECT FOR THE JACOBIANS OF THE TWO CHAINS
C ---FIRST CHANNEL ------- PIM1+PIPL
        AMS1=(AMP2+AMP3)**2
        AMS2=(AM3-AMP1)**2
        ALP1=ATAN((AMS1-AMRA**2)/AMRA/GAMRA)
        ALP2=ATAN((AMS2-AMRA**2)/AMRA/GAMRA)
       XPRO =      (PIM1(3)+PIPL(3))**2
     $            +(PIM1(2)+PIPL(2))**2+(PIM1(1)+PIPL(1))**2
       AM2SQ=-XPRO+(PIM1(4)+PIPL(4))**2
C JACOBIAN OF SPEEDING
       FF1   =       ((AM2SQ-AMRA**2)**2+(AMRA*GAMRA)**2)/(AMRA*GAMRA)
       FF1   =FF1     *(ALP2-ALP1)
C LAMBDA OF RHO DECAY
       GG1   =       (4*PI)*(XLAM(AM2SQ,AMP2**2,AMP3**2)/AM2SQ)
C LAMBDA OF A1 DECAY
       GG1   =GG1   *(4*PI)*SQRT(4*XPRO/AM3SQ)
       XJAJE=GG1*(AMS2-AMS1)
C ---SECOND CHANNEL ------ PIM2+PIPL
       AMS1=(AMP1+AMP3)**2
       AMS2=(AM3-AMP2)**2
        ALP1=ATAN((AMS1-AMRB**2)/AMRB/GAMRB)
        ALP2=ATAN((AMS2-AMRB**2)/AMRB/GAMRB)
       XPRO =      (PIM2(3)+PIPL(3))**2
     $            +(PIM2(2)+PIPL(2))**2+(PIM2(1)+PIPL(1))**2
       AM2SQ=-XPRO+(PIM2(4)+PIPL(4))**2
       FF2   =       ((AM2SQ-AMRB**2)**2+(AMRB*GAMRB)**2)/(AMRB*GAMRB)
       FF2   =FF2     *(ALP2-ALP1)
       GG2   =       (4*PI)*(XLAM(AM2SQ,AMP1**2,AMP3**2)/AM2SQ)
       GG2   =GG2   *(4*PI)*SQRT(4*XPRO/AM3SQ)
       XJADW=GG2*(AMS2-AMS1)
C
       A1=0.0
       A2=0.0
       A3=0.0
       XJAC1=FF1*GG1
       XJAC2=FF2*GG2
       IF (ICHAN.EQ.2) THEN
         XJAC3=XJADW
       ELSE
         XJAC3=XJAJE
       ENDIF
       IF (XJAC1.NE.0.0) A1=PROB1/XJAC1
       IF (XJAC2.NE.0.0) A2=PROB2/XJAC2
       IF (XJAC3.NE.0.0) A3=PROB3/XJAC3
C
       IF (A1+A2+A3.NE.0.0) THEN
         PHSPAC=PHSPAC/(A1+A2+A3)
       ELSE
         PHSPAC=0.0
       ENDIF
       IF(ICHAN.EQ.2) THEN
        DO 70 I=1,4
        X=PIM1(I)
        PIM1(I)=PIM2(I)
 70     PIM2(I)=X
       ENDIF
* ALL PIONS BOOSTED FROM A1  REST FRAME TO TAU REST FRAME
* Z-AXIS ANTIPARALLEL TO NEUTRINO MOMENTUM
      EXE=(PAA(4)+PAA(3))/AM3
      CALL BOSTR3(EXE,PIPL,PIPL)
      CALL BOSTR3(EXE,PIM1,PIM1)
      CALL BOSTR3(EXE,PIM2,PIM2)
      CALL BOSTR3(EXE,PR,PR)
C PARTIAL WIDTH CONSISTS OF PHASE SPACE AND AMPLITUDE
      IF (MNUM.EQ.8) THEN
        CALL DAMPOG(PT,PN,PIM1,PIM2,PIPL,AMPLIT,HV)
C      ELSEIF (MNUM.EQ.0) THEN
C        CALL DAMPAA(PT,PN,PIM1,PIM2,PIPL,AMPLIT,HV)
      ELSE
        CALL DAMPPK(MNUM,PT,PN,PIM1,PIM2,PIPL,AMPLIT,HV)
      ENDIF
      IF (KEYT.EQ.1.OR.KEYT.EQ.2) THEN
C THE STATISTICAL FACTOR FOR IDENTICAL PI'S IS CANCELLED WITH
C TWO, FOR TWO MODES OF A1 DECAY NAMELLY PI+PI-PI- AND PI-PI0PI0
        PHSPAC=PHSPAC*2.0
        PHSPAC=PHSPAC/2.
      ENDIF
      DGAMT=1/(2.*AMTAU)*AMPLIT*PHSPAC
      END
      SUBROUTINE DAMPAA(PT,PN,PIM1,PIM2,PIPL,AMPLIT,HV)
C ----------------------------------------------------------------------
* CALCULATES DIFFERENTIAL CROSS SECTION AND POLARIMETER VECTOR
* FOR TAU DECAY INTO A1, A1 DECAYS NEXT INTO RHO+PI AND RHO INTO PI+PI.
* ALL SPIN EFFECTS IN THE FULL DECAY CHAIN ARE TAKEN INTO ACCOUNT.
* CALCULATIONS DONE IN TAU REST FRAME WITH Z-AXIS ALONG NEUTRINO MOMENT
* THE ROUTINE IS WRITEN FOR ZERO NEUTRINO MASS.
C
C     called by : DPHSAA
C ----------------------------------------------------------------------
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / DECPAR / GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL*4            GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      COMMON /TESTA1/ KEYA1
      REAL  HV(4),PT(4),PN(4),PIM1(4),PIM2(4),PIPL(4)
      REAL  PAA(4),VEC1(4),VEC2(4)
      REAL  PIVEC(4),PIAKS(4),HVM(4)
      COMPLEX BWIGN,HADCUR(4),FPIK
      DATA ICONT /1/
C
* F CONSTANTS FOR A1, A1-RHO-PI, AND RHO-PI-PI
*
      DATA  FPI /93.3E-3/
* THIS INLINE FUNCT. CALCULATES THE SCALAR PART OF THE PROPAGATOR
      BWIGN(XM,AM,GAMMA)=1./CMPLX(XM**2-AM**2,GAMMA*AM)
C
* FOUR MOMENTUM OF A1
      DO 10 I=1,4
   10 PAA(I)=PIM1(I)+PIM2(I)+PIPL(I)
* MASSES OF A1, AND OF TWO PI-PAIRS WHICH MAY FORM RHO
      XMAA   =SQRT(ABS(PAA(4)**2-PAA(3)**2-PAA(2)**2-PAA(1)**2))
      XMRO1  =SQRT(ABS((PIPL(4)+PIM1(4))**2-(PIPL(1)+PIM1(1))**2
     $                -(PIPL(2)+PIM1(2))**2-(PIPL(3)+PIM1(3))**2))
      XMRO2  =SQRT(ABS((PIPL(4)+PIM2(4))**2-(PIPL(1)+PIM2(1))**2
     $                -(PIPL(2)+PIM2(2))**2-(PIPL(3)+PIM2(3))**2))
* ELEMENTS OF HADRON CURRENT
      PROD1  =PAA(4)*(PIM1(4)-PIPL(4))-PAA(1)*(PIM1(1)-PIPL(1))
     $       -PAA(2)*(PIM1(2)-PIPL(2))-PAA(3)*(PIM1(3)-PIPL(3))
      PROD2  =PAA(4)*(PIM2(4)-PIPL(4))-PAA(1)*(PIM2(1)-PIPL(1))
     $       -PAA(2)*(PIM2(2)-PIPL(2))-PAA(3)*(PIM2(3)-PIPL(3))
      DO 40 I=1,4
      VEC1(I)= PIM1(I)-PIPL(I) -PAA(I)*PROD1/XMAA**2
 40   VEC2(I)= PIM2(I)-PIPL(I) -PAA(I)*PROD2/XMAA**2
* HADRON CURRENT SATURATED WITH A1 AND RHO RESONANCES
      IF (KEYA1.EQ.1) THEN
        FA1=9.87
        FAROPI=1.0
        FRO2PI=1.0
        FNORM=FA1/SQRT(2.)*FAROPI*FRO2PI
        DO 45 I=1,4
        HADCUR(I)= CMPLX(FNORM) *AMA1**2*BWIGN(XMAA,AMA1,GAMA1)
     $              *(CMPLX(VEC1(I))*AMRO**2*BWIGN(XMRO1,AMRO,GAMRO)
     $               +CMPLX(VEC2(I))*AMRO**2*BWIGN(XMRO2,AMRO,GAMRO))
 45     CONTINUE
      ELSE
        FNORM=2.0*SQRT(2.)/3.0/FPI
        GAMAX=GAMA1*GFUN(XMAA**2)/GFUN(AMA1**2)
        DO 46 I=1,4
        HADCUR(I)= CMPLX(FNORM) *AMA1**2*BWIGN(XMAA,AMA1,GAMAX)
     $              *(CMPLX(VEC1(I))*FPIK(XMRO1)
     $               +CMPLX(VEC2(I))*FPIK(XMRO2))
 46     CONTINUE
      ENDIF
C
* CALCULATE PI-VECTORS: VECTOR AND AXIAL
      CALL CLVEC(HADCUR,PN,PIVEC)
      CALL CLAXI(HADCUR,PN,PIAKS)
      CALL CLNUT(HADCUR,BRAKM,HVM)
* SPIN INDEPENDENT PART OF DECAY DIFF-CROSS-SECT. IN TAU REST  FRAME
      BRAK= (GV**2+GA**2)*PT(4)*PIVEC(4) +2.*GV*GA*PT(4)*PIAKS(4)
     &     +2.*(GV**2-GA**2)*AMNUTA*AMTAU*BRAKM
      AMPLIT=(GFERMI*CCABIB)**2*BRAK/2.
C THE STATISTICAL FACTOR FOR IDENTICAL PI'S WAS CANCELLED WITH
C TWO, FOR TWO MODES OF A1 DECAY NAMELLY PI+PI-PI- AND PI-PI0PI0
C POLARIMETER VECTOR IN TAU REST FRAME
      DO 90 I=1,3
      HV(I)=-(AMTAU*((GV**2+GA**2)*PIAKS(I)+2.*GV*GA*PIVEC(I)))
     &      +(GV**2-GA**2)*AMNUTA*AMTAU*HVM(I)
C HV IS DEFINED FOR TAU-    WITH GAMMA=B+HV*POL
      HV(I)=-HV(I)/BRAK
 90   CONTINUE
      END

      FUNCTION GFUN(QKWA)
C ****************************************************************
C     G-FUNCTION USED TO INRODUCE ENERGY DEPENDENCE IN A1 WIDTH
C ****************************************************************
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
       IF (QKWA.LT.(AMRO+AMPI)**2) THEN
          GFUN=4.1*(QKWA-9*AMPIZ**2)**3
     $        *(1.-3.3*(QKWA-9*AMPIZ**2)+5.8*(QKWA-9*AMPIZ**2)**2)
       ELSE
          GFUN=QKWA*(1.623+10.38/QKWA-9.32/QKWA**2+0.65/QKWA**3)
       ENDIF
      END
      COMPLEX FUNCTION BWIGS(S,M,G)
C **********************************************************
C     P-WAVE BREIT-WIGNER  FOR K*
C **********************************************************
      REAL S,M,G
      REAL PI,PIM,QS,QM,W,GS,MK
      DATA INIT /0/
      P(A,B,C)=SQRT(ABS(ABS(((A+B-C)**2-4.*A*B)/4./A)
     $                    +(((A+B-C)**2-4.*A*B)/4./A))/2.0)
C ------------ PARAMETERS --------------------
      IF (INIT.EQ.0) THEN
      INIT=1
      PI=3.141592654
      PIM=.139
      MK=.493667
C -------  BREIT-WIGNER -----------------------
         ENDIF
         QS=P(S,PIM**2,MK**2)
         QM=P(M**2,PIM**2,MK**2)
         W=SQRT(S)
         GS=G*(M/W)*(QS/QM)**3
         BWIGS=M**2/CMPLX(M**2-S,-M*GS)
      RETURN
      END
      COMPLEX FUNCTION BWIG(S,M,G)
C **********************************************************
C     P-WAVE BREIT-WIGNER  FOR RHO
C **********************************************************
      REAL S,M,G
      REAL PI,PIM,QS,QM,W,GS
      DATA INIT /0/
C ------------ PARAMETERS --------------------
      IF (INIT.EQ.0) THEN
      INIT=1
      PI=3.141592654
      PIM=.139
C -------  BREIT-WIGNER -----------------------
         ENDIF
       IF (S.GT.4.*PIM**2) THEN
         QS=SQRT(ABS(ABS(S/4.-PIM**2)+(S/4.-PIM**2))/2.0)
         QM=SQRT(M**2/4.-PIM**2)
         W=SQRT(S)
         GS=G*(M/W)*(QS/QM)**3
       ELSE
         GS=0.0
       ENDIF
         BWIG=M**2/CMPLX(M**2-S,-M*GS)
      RETURN
      END
      COMPLEX FUNCTION FPIK(W)
C **********************************************************
C     PION FORM FACTOR
C **********************************************************
      COMPLEX BWIG
      REAL ROM,ROG,ROM1,ROG1,BETA1,PI,PIM,S,W
      EXTERNAL BWIG
      DATA  INIT /0/
C
C ------------ PARAMETERS --------------------
      IF (INIT.EQ.0 ) THEN
      INIT=1
      PI=3.141592654
      PIM=.140
      ROM=0.773
      ROG=0.145
      ROM1=1.370
      ROG1=0.510
      BETA1=-0.145
      ENDIF
C -----------------------------------------------
      S=W**2
      FPIK= (BWIG(S,ROM,ROG)+BETA1*BWIG(S,ROM1,ROG1))
     & /(1+BETA1)
      RETURN
      END
      FUNCTION FPIRHO(W)
C **********************************************************
C     SQUARE OF PION FORM FACTOR
C **********************************************************
      COMPLEX FPIK
      FPIRHO=CABS(FPIK(W))**2
      END
      SUBROUTINE CLVEC(HJ,PN,PIV)
C ----------------------------------------------------------------------
* CALCULATES THE "VECTOR TYPE"  PI-VECTOR  PIV
* NOTE THAT THE NEUTRINO MOM. PN IS ASSUMED TO BE ALONG Z-AXIS
C
C     called by : DAMPAA
C ----------------------------------------------------------------------
      REAL PIV(4),PN(4)
      COMPLEX HJ(4),HN
C
      HN= HJ(4)*CMPLX(PN(4))-HJ(3)*CMPLX(PN(3))
      HH= REAL(HJ(4)*CONJG(HJ(4))-HJ(3)*CONJG(HJ(3))
     $        -HJ(2)*CONJG(HJ(2))-HJ(1)*CONJG(HJ(1)))
      DO 10 I=1,4
   10 PIV(I)=4.*REAL(HN*CONJG(HJ(I)))-2.*HH*PN(I)
      RETURN
      END
      SUBROUTINE CLAXI(HJ,PN,PIA)
C ----------------------------------------------------------------------
* CALCULATES THE "AXIAL TYPE"  PI-VECTOR  PIA
* NOTE THAT THE NEUTRINO MOM. PN IS ASSUMED TO BE ALONG Z-AXIS
C SIGN is chosen +/- for decay of TAU +/- respectively
C     called by : DAMPAA, CLNUT
C ----------------------------------------------------------------------
      COMMON / JAKI   /  JAK1,JAK2,JAKP,JAKM,KTOM
      COMMON / IDFC  / IDFF
      REAL PIA(4),PN(4)
      COMPLEX HJ(4),HJC(4)
C     DET2(I,J)=AIMAG(HJ(I)*HJC(J)-HJ(J)*HJC(I))
C -- here was an error (ZW, 21.11.1991)
      DET2(I,J)=AIMAG(HJC(I)*HJ(J)-HJC(J)*HJ(I))
C -- it was affecting sign of A_LR asymmetry in a1 decay.
C -- note also collision of notation of gamma_va as defined in
C -- TAUOLA paper and J.H. Kuhn and Santamaria Z. Phys C 48 (1990) 445
* -----------------------------------
      IF     (KTOM.EQ.1.OR.KTOM.EQ.-1) THEN
        SIGN= IDFF/ABS(IDFF)
      ELSEIF (KTOM.EQ.2) THEN
        SIGN=-IDFF/ABS(IDFF)
      ELSE
        PRINT *, 'STOP IN CLAXI: KTOM=',KTOM
        STOP
      ENDIF
C
      DO 10 I=1,4
 10   HJC(I)=CONJG(HJ(I))
      PIA(1)= -2.*PN(3)*DET2(2,4)+2.*PN(4)*DET2(2,3)
      PIA(2)= -2.*PN(4)*DET2(1,3)+2.*PN(3)*DET2(1,4)
      PIA(3)=  2.*PN(4)*DET2(1,2)
      PIA(4)=  2.*PN(3)*DET2(1,2)
C ALL FOUR INDICES ARE UP SO  PIA(3) AND PIA(4) HAVE SAME SIGN
      DO 20 I=1,4
  20  PIA(I)=PIA(I)*SIGN
      END
      SUBROUTINE CLNUT(HJ,B,HV)
C ----------------------------------------------------------------------
* CALCULATES THE CONTRIBUTION BY NEUTRINO MASS
* NOTE THE TAU IS ASSUMED TO BE AT REST
C
C     called by : DAMPAA
C ----------------------------------------------------------------------
      COMPLEX HJ(4)
      REAL HV(4),P(4)
      DATA P /3*0.,1.0/
C
      CALL CLAXI(HJ,P,HV)
      B=REAL( HJ(4)*AIMAG(HJ(4)) - HJ(3)*AIMAG(HJ(3))
     &      - HJ(2)*AIMAG(HJ(2)) - HJ(1)*AIMAG(HJ(1))  )
      RETURN
      END
      SUBROUTINE DAMPOG(PT,PN,PIM1,PIM2,PIPL,AMPLIT,HV)
C ----------------------------------------------------------------------
* CALCULATES DIFFERENTIAL CROSS SECTION AND POLARIMETER VECTOR
* FOR TAU DECAY INTO A1, A1 DECAYS NEXT INTO RHO+PI AND RHO INTO PI+PI.
* ALL SPIN EFFECTS IN THE FULL DECAY CHAIN ARE TAKEN INTO ACCOUNT.
* CALCULATIONS DONE IN TAU REST FRAME WITH Z-AXIS ALONG NEUTRINO MOMENT
* THE ROUTINE IS WRITEN FOR ZERO NEUTRINO MASS.
C
C     called by : DPHSAA
C ----------------------------------------------------------------------
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / DECPAR / GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL*4            GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      COMMON /TESTA1/ KEYA1
      REAL  HV(4),PT(4),PN(4),PIM1(4),PIM2(4),PIPL(4)
      REAL  PAA(4),VEC1(4),VEC2(4)
      REAL  PIVEC(4),PIAKS(4),HVM(4)
      COMPLEX BWIGN,HADCUR(4),FNORM,FORMOM
      DATA ICONT /1/
* THIS INLINE FUNCT. CALCULATES THE SCALAR PART OF THE PROPAGATOR
      BWIGN(XM,AM,GAMMA)=1./CMPLX(XM**2-AM**2,GAMMA*AM)
C
* FOUR MOMENTUM OF A1
      DO 10 I=1,4
      VEC1(I)=0.0
      VEC2(I)=0.0
      HV(I)  =0.0
   10 PAA(I)=PIM1(I)+PIM2(I)+PIPL(I)
      VEC1(1)=1.0
* MASSES OF A1, AND OF TWO PI-PAIRS WHICH MAY FORM RHO
      XMAA   =SQRT(ABS(PAA(4)**2-PAA(3)**2-PAA(2)**2-PAA(1)**2))
      XMOM   =SQRT(ABS( (PIM2(4)+PIPL(4))**2-(PIM2(3)+PIPL(3))**2
     $                 -(PIM2(2)+PIPL(2))**2-(PIM2(1)+PIPL(1))**2   ))
      XMRO2  =(PIPL(1))**2 +(PIPL(2))**2 +(PIPL(3))**2
* ELEMENTS OF HADRON CURRENT
      PROD1  =VEC1(1)*PIPL(1)
      PROD2  =VEC2(2)*PIPL(2)
      P12    =PIM1(4)*PIM2(4)-PIM1(1)*PIM2(1)
     $       -PIM1(2)*PIM2(2)-PIM1(3)*PIM2(3)
      P1PL   =PIM1(4)*PIPL(4)-PIM1(1)*PIPL(1)
     $       -PIM1(2)*PIPL(2)-PIM1(3)*PIPL(3)
      P2PL   =PIPL(4)*PIM2(4)-PIPL(1)*PIM2(1)
     $       -PIPL(2)*PIM2(2)-PIPL(3)*PIM2(3)
      DO 40 I=1,3
        VEC1(I)= (VEC1(I)-PROD1/XMRO2*PIPL(I))
 40   CONTINUE
        GNORM=SQRT(VEC1(1)**2+VEC1(2)**2+VEC1(3)**2)
      DO 41 I=1,3
        VEC1(I)= VEC1(I)/GNORM
 41   CONTINUE
      VEC2(1)=(VEC1(2)*PIPL(3)-VEC1(3)*PIPL(2))/SQRT(XMRO2)
      VEC2(2)=(VEC1(3)*PIPL(1)-VEC1(1)*PIPL(3))/SQRT(XMRO2)
      VEC2(3)=(VEC1(1)*PIPL(2)-VEC1(2)*PIPL(1))/SQRT(XMRO2)
      P1VEC1   =PIM1(4)*VEC1(4)-PIM1(1)*VEC1(1)
     $         -PIM1(2)*VEC1(2)-PIM1(3)*VEC1(3)
      P2VEC1   =VEC1(4)*PIM2(4)-VEC1(1)*PIM2(1)
     $         -VEC1(2)*PIM2(2)-VEC1(3)*PIM2(3)
      P1VEC2   =PIM1(4)*VEC2(4)-PIM1(1)*VEC2(1)
     $         -PIM1(2)*VEC2(2)-PIM1(3)*VEC2(3)
      P2VEC2   =VEC2(4)*PIM2(4)-VEC2(1)*PIM2(1)
     $         -VEC2(2)*PIM2(2)-VEC2(3)*PIM2(3)
* HADRON CURRENT
      FNORM=FORMOM(XMAA,XMOM)
      BRAK=0.0
      DO 120 JJ=1,2
        DO 45 I=1,4
       IF (JJ.EQ.1) THEN
        HADCUR(I) = FNORM *(
     $             VEC1(I)*(AMPI**2*P1PL-P2PL*(P12-P1PL))
     $            -PIM2(I)*(P2VEC1*P1PL-P1VEC1*P2PL)
     $            +PIPL(I)*(P2VEC1*P12 -P1VEC1*(AMPI**2+P2PL))  )
       ELSE
        HADCUR(I) = FNORM *(
     $             VEC2(I)*(AMPI**2*P1PL-P2PL*(P12-P1PL))
     $            -PIM2(I)*(P2VEC2*P1PL-P1VEC2*P2PL)
     $            +PIPL(I)*(P2VEC2*P12 -P1VEC2*(AMPI**2+P2PL))  )
       ENDIF
 45     CONTINUE
C
* CALCULATE PI-VECTORS: VECTOR AND AXIAL
      CALL CLVEC(HADCUR,PN,PIVEC)
      CALL CLAXI(HADCUR,PN,PIAKS)
      CALL CLNUT(HADCUR,BRAKM,HVM)
* SPIN INDEPENDENT PART OF DECAY DIFF-CROSS-SECT. IN TAU REST  FRAME
      BRAK=BRAK+(GV**2+GA**2)*PT(4)*PIVEC(4) +2.*GV*GA*PT(4)*PIAKS(4)
     &         +2.*(GV**2-GA**2)*AMNUTA*AMTAU*BRAKM
      DO 90 I=1,3
      HV(I)=HV(I)-(AMTAU*((GV**2+GA**2)*PIAKS(I)+2.*GV*GA*PIVEC(I)))
     &      +(GV**2-GA**2)*AMNUTA*AMTAU*HVM(I)
  90  CONTINUE
C HV IS DEFINED FOR TAU-    WITH GAMMA=B+HV*POL
 120  CONTINUE
      AMPLIT=(GFERMI*CCABIB)**2*BRAK/2.
C THE STATISTICAL FACTOR FOR IDENTICAL PI'S WAS CANCELLED WITH
C TWO, FOR TWO MODES OF A1 DECAY NAMELLY PI+PI-PI- AND PI-PI0PI0
C POLARIMETER VECTOR IN TAU REST FRAME
      DO 91 I=1,3
      HV(I)=-HV(I)/BRAK
 91   CONTINUE

      END
      SUBROUTINE DAMPPK(MNUM,PT,PN,PIM1,PIM2,PIM3,AMPLIT,HV)
C ----------------------------------------------------------------------
* CALCULATES DIFFERENTIAL CROSS SECTION AND POLARIMETER VECTOR
* FOR TAU DECAY INTO K K pi, K pi pi.
* ALL SPIN EFFECTS IN THE FULL DECAY CHAIN ARE TAKEN INTO ACCOUNT.
* CALCULATIONS DONE IN TAU REST FRAME WITH Z-AXIS ALONG NEUTRINO MOMENT
C MNUM DECAY MODE IDENTIFIER.
C
C     called by : DPHSAA
C ----------------------------------------------------------------------
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / DECPAR / GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL*4            GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL  HV(4),PT(4),PN(4),PIM1(4),PIM2(4),PIM3(4)
      REAL  PAA(4),VEC1(4),VEC2(4),VEC3(4),VEC4(4),VEC5(4)
      REAL  PIVEC(4),PIAKS(4),HVM(4)
      REAL FNORM(0:7),COEF(1:5,0:7)
      COMPLEX HADCUR(4),FORM1,FORM2,FORM3,FORM4,FORM5,UROJ
      EXTERNAL FORM1,FORM2,FORM3,FORM4,FORM5
      DATA PI /3.141592653589793238462643/
      DATA ICONT /0/
C
      DATA  FPI /93.3E-3/
      IF (ICONT.EQ.0) THEN
       ICONT=1
       UROJ=CMPLX(0.0,1.0)
       DWAPI0=SQRT(2.0)
       FNORM(0)=CCABIB/FPI
       FNORM(1)=CCABIB/FPI
       FNORM(2)=CCABIB/FPI
       FNORM(3)=CCABIB/FPI
       FNORM(4)=SCABIB/FPI/DWAPI0
       FNORM(5)=SCABIB/FPI
       FNORM(6)=SCABIB/FPI
       FNORM(7)=CCABIB/FPI
C
       COEF(1,0)= 2.0*SQRT(2.)/3.0
       COEF(2,0)=-2.0*SQRT(2.)/3.0
       COEF(3,0)= 0.0
       COEF(4,0)= FPI
       COEF(5,0)= 0.0
C
       COEF(1,1)=-SQRT(2.)/3.0
       COEF(2,1)= SQRT(2.)/3.0
       COEF(3,1)= 0.0
       COEF(4,1)= FPI
       COEF(5,1)= SQRT(2.)
C
       COEF(1,2)=-SQRT(2.)/3.0
       COEF(2,2)= SQRT(2.)/3.0
       COEF(3,2)= 0.0
       COEF(4,2)= 0.0
       COEF(5,2)=-SQRT(2.)
C
       COEF(1,3)= 0.0
       COEF(2,3)=-1.0
       COEF(3,3)= 0.0
       COEF(4,3)= 0.0
       COEF(5,3)= 0.0
C
       COEF(1,4)= 1.0/SQRT(2.)/3.0
       COEF(2,4)=-1.0/SQRT(2.)/3.0
       COEF(3,4)= 0.0
       COEF(4,4)= 0.0
       COEF(5,4)= 0.0
C
       COEF(1,5)=-SQRT(2.)/3.0
       COEF(2,5)= SQRT(2.)/3.0
       COEF(3,5)= 0.0
       COEF(4,5)= 0.0
       COEF(5,5)=-SQRT(2.)
C
       COEF(1,6)= 0.0
       COEF(2,6)=-1.0
       COEF(3,6)= 0.0
       COEF(4,6)= 0.0
       COEF(5,6)=-2.0
C
       COEF(1,7)= 0.0
       COEF(2,7)= 0.0
       COEF(3,7)= 0.0
       COEF(4,7)= 0.0
       COEF(5,7)=-SQRT(2.0/3.0)
C
      ENDIF
C
      DO 10 I=1,4
   10 PAA(I)=PIM1(I)+PIM2(I)+PIM3(I)
      XMAA   =SQRT(ABS(PAA(4)**2-PAA(3)**2-PAA(2)**2-PAA(1)**2))
      XMRO1  =SQRT(ABS((PIM3(4)+PIM2(4))**2-(PIM3(1)+PIM2(1))**2
     $                -(PIM3(2)+PIM2(2))**2-(PIM3(3)+PIM2(3))**2))
      XMRO2  =SQRT(ABS((PIM3(4)+PIM1(4))**2-(PIM3(1)+PIM1(1))**2
     $                -(PIM3(2)+PIM1(2))**2-(PIM3(3)+PIM1(3))**2))
      XMRO3  =SQRT(ABS((PIM1(4)+PIM2(4))**2-(PIM1(1)+PIM2(1))**2
     $                -(PIM1(2)+PIM2(2))**2-(PIM1(3)+PIM2(3))**2))
* ELEMENTS OF HADRON CURRENT
      PROD1  =PAA(4)*(PIM2(4)-PIM3(4))-PAA(1)*(PIM2(1)-PIM3(1))
     $       -PAA(2)*(PIM2(2)-PIM3(2))-PAA(3)*(PIM2(3)-PIM3(3))
      PROD2  =PAA(4)*(PIM3(4)-PIM1(4))-PAA(1)*(PIM3(1)-PIM1(1))
     $       -PAA(2)*(PIM3(2)-PIM1(2))-PAA(3)*(PIM3(3)-PIM1(3))
      PROD3  =PAA(4)*(PIM1(4)-PIM2(4))-PAA(1)*(PIM1(1)-PIM2(1))
     $       -PAA(2)*(PIM1(2)-PIM2(2))-PAA(3)*(PIM1(3)-PIM2(3))
      DO 40 I=1,4
      VEC1(I)= PIM2(I)-PIM3(I) -PAA(I)*PROD1/XMAA**2
      VEC2(I)= PIM3(I)-PIM1(I) -PAA(I)*PROD2/XMAA**2
      VEC3(I)= PIM1(I)-PIM2(I) -PAA(I)*PROD3/XMAA**2
 40   VEC4(I)= PIM1(I)+PIM2(I)+PIM3(I)
      CALL PROD5(PIM1,PIM2,PIM3,VEC5)
* HADRON CURRENT
C be aware that sign of vec2 is opposite to sign of vec1 in a1 case
      DO 45 I=1,4
      HADCUR(I)= CMPLX(FNORM(MNUM)) * (
     $CMPLX(VEC1(I)*COEF(1,MNUM))*FORM1(MNUM,XMAA**2,XMRO1**2,XMRO2**2)+
     $CMPLX(VEC2(I)*COEF(2,MNUM))*FORM2(MNUM,XMAA**2,XMRO2**2,XMRO1**2)+
     $CMPLX(VEC3(I)*COEF(3,MNUM))*FORM3(MNUM,XMAA**2,XMRO3**2,XMRO1**2)+
     *(-1.0*UROJ)*
     $CMPLX(VEC4(I)*COEF(4,MNUM))*FORM4(MNUM,XMAA**2,XMRO1**2,
     $                                      XMRO2**2,XMRO3**2)         +
     $(-1.0)*UROJ/4.0/PI**2/FPI**2*
     $CMPLX(VEC5(I)*COEF(5,MNUM))*FORM5(MNUM,XMAA**2,XMRO1**2,XMRO2**2))
 45   CONTINUE
C
* CALCULATE PI-VECTORS: VECTOR AND AXIAL
      CALL CLVEC(HADCUR,PN,PIVEC)
      CALL CLAXI(HADCUR,PN,PIAKS)
      CALL CLNUT(HADCUR,BRAKM,HVM)
* SPIN INDEPENDENT PART OF DECAY DIFF-CROSS-SECT. IN TAU REST  FRAME
      BRAK= (GV**2+GA**2)*PT(4)*PIVEC(4) +2.*GV*GA*PT(4)*PIAKS(4)
     &     +2.*(GV**2-GA**2)*AMNUTA*AMTAU*BRAKM
      AMPLIT=(GFERMI)**2*BRAK/2.
      IF (MNUM.GE.9) THEN
        PRINT *, 'MNUM=',MNUM
        ZNAK=-1.0
        XM1=0.0
        XM2=0.0
        XM3=0.0
        DO 77 K=1,4
        IF (K.EQ.4) ZNAK=1.0
        XM1=ZNAK*PIM1(K)**2+XM1
        XM2=ZNAK*PIM2(K)**2+XM2
        XM3=ZNAK*PIM3(K)**2+XM3
 77     PRINT *, 'PIM1=',PIM1(K),'PIM2=',PIM2(K),'PIM3=',PIM3(K)
        PRINT *, 'XM1=',SQRT(XM1),'XM2=',SQRT(XM2),'XM3=',SQRT(XM3)
        PRINT *, '************************************************'
      ENDIF
C POLARIMETER VECTOR IN TAU REST FRAME
      DO 90 I=1,3
      HV(I)=-(AMTAU*((GV**2+GA**2)*PIAKS(I)+2.*GV*GA*PIVEC(I)))
     &      +(GV**2-GA**2)*AMNUTA*AMTAU*HVM(I)
C HV IS DEFINED FOR TAU-    WITH GAMMA=B+HV*POL
      HV(I)=-HV(I)/BRAK
 90   CONTINUE
      END
      SUBROUTINE PROD5(P1,P2,P3,PIA)
C ----------------------------------------------------------------------
C external product of P1, P2, P3 4-momenta.
C SIGN is chosen +/- for decay of TAU +/- respectively
C     called by : DAMPAA, CLNUT
C ----------------------------------------------------------------------
      COMMON / JAKI   /  JAK1,JAK2,JAKP,JAKM,KTOM
      COMMON / IDFC  / IDFF
      REAL PIA(4),P1(4),P2(4),P3(4)
      DET2(I,J)=P1(I)*P2(J)-P2(I)*P1(J)
* -----------------------------------
      IF     (KTOM.EQ.1.OR.KTOM.EQ.-1) THEN
        SIGN= IDFF/ABS(IDFF)
      ELSEIF (KTOM.EQ.2) THEN
        SIGN=-IDFF/ABS(IDFF)
      ELSE
        PRINT *, 'STOP IN PROD5: KTOM=',KTOM
        STOP
      ENDIF
C
C EPSILON( p1(1), p2(2), p3(3), (4) ) = 1
C
      PIA(1)= -P3(3)*DET2(2,4)+P3(4)*DET2(2,3)+P3(2)*DET2(3,4)
      PIA(2)= -P3(4)*DET2(1,3)+P3(3)*DET2(1,4)-P3(1)*DET2(3,4)
      PIA(3)=  P3(4)*DET2(1,2)-P3(2)*DET2(1,4)+P3(1)*DET2(2,4)
      PIA(4)=  P3(3)*DET2(1,2)-P3(2)*DET2(1,3)+P3(1)*DET2(2,3)
C ALL FOUR INDICES ARE UP SO  PIA(3) AND PIA(4) HAVE SAME SIGN
      DO 20 I=1,4
  20  PIA(I)=PIA(I)*SIGN
      END

      SUBROUTINE DEXNEW(MODE,ISGN,POL,PNU,PAA,PNPI,JNPI)
C ----------------------------------------------------------------------
* THIS SIMULATES TAU DECAY IN TAU REST FRAME
* INTO NU A1, NEXT A1 DECAYS INTO RHO PI AND FINALLY RHO INTO PI PI.
* OUTPUT FOUR MOMENTA: PNU   TAUNEUTRINO,
*                      PAA   A1
*                      PIM1  PION MINUS (OR PI0) 1      (FOR TAU MINUS)
*                      PIM2  PION MINUS (OR PI0) 2
*                      PIPL  PION PLUS  (OR PI-)
*                      (PIPL,PIM1) FORM A RHO
C ----------------------------------------------------------------------
      COMMON / INOUT / INUT,IOUT
      REAL  POL(4),HV(4),PAA(4),PNU(4),PNPI(4,9)
      DATA IWARM/0/
C
      IF(MODE.EQ.-1) THEN
C     ===================
        IWARM=1
        CALL DADNEW( -1,ISGN,HV,PNU,PAA,PNPI,JDUMM)
CC      CALL HBOOK1(816,'WEIGHT DISTRIBUTION  DEXAA    $',100,-2.,2.)
C
      ELSEIF(MODE.EQ. 0) THEN
*     =======================
 300    CONTINUE
        IF(IWARM.EQ.0) GOTO 902
        CALL DADNEW( 0,ISGN,HV,PNU,PAA,PNPI,JNPI)
        WT=(1+POL(1)*HV(1)+POL(2)*HV(2)+POL(3)*HV(3))/2.
CC      CALL HFILL(816,WT)
          CALL RANMAR(RN,1)
          IF(RN.GT.WT) GOTO 300
C
      ELSEIF(MODE.EQ. 1) THEN
*     =======================
        CALL DADNEW( 1,ISGN,HV,PNU,PAA,PNPI,JDUMM)
CC      CALL HPRINT(816)
      ENDIF
C     =====
      RETURN
 902  WRITE(IOUT, 9020)
 9020 FORMAT(' ----- DEXNEW: LACK OF INITIALISATION')
      STOP
      END
      SUBROUTINE DADNEW(MODE,ISGN,HV,PNU,PWB,PNPI,JNPI)
C ----------------------------------------------------------------------
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / DECPAR / GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL*4            GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      COMMON / TAUBMC / GAMPMC(30),GAMPER(30),NEVDEC(30)
      REAL*4            GAMPMC    ,GAMPER
      COMMON / INOUT / INUT,IOUT
      PARAMETER (NMODE=15,NM1=0,NM2=1,NM3=8,NM4=2,NM5=1,NM6=3)
      COMMON / DECOMP /IDFFIN(9,NMODE),MULPIK(NMODE)
     &                ,NAMES
      CHARACTER NAMES(NMODE)*31

      REAL*4 PNU(4),PWB(4),PNPI(4,9),HV(4),HHV(4)
      REAL*4 PDUM1(4),PDUM2(4),PDUMI(4,9)
      REAL*4 RRR(3)
      REAL*4 WTMAX(NMODE)
      REAL*8              SWT(NMODE),SSWT(NMODE)
      DIMENSION NEVRAW(NMODE),NEVOVR(NMODE),NEVACC(NMODE)
C
      DATA PI /3.141592653589793238462643/
      DATA IWARM/0/
C
      IF(MODE.EQ.-1) THEN
C     ===================
C -- AT THE MOMENT ONLY TWO DECAY MODES OF MULTIPIONS HAVE M. ELEM
        NMOD=NMODE
        IWARM=1
C       PRINT 7003
        DO 1 JNPI=1,NMOD
        NEVRAW(JNPI)=0
        NEVACC(JNPI)=0
        NEVOVR(JNPI)=0
        SWT(JNPI)=0
        SSWT(JNPI)=0
        WTMAX(JNPI)=-1.
        DO  I=1,500
          IF    (JNPI.LE.0) THEN
            GOTO 903
          ELSEIF(JNPI.LE.NM4) THEN
            CALL DPH4PI(WT,HV,PDUM1,PDUM2,PDUMI,JNPI)
          ELSEIF(JNPI.LE.NM4+NM5) THEN
             CALL DPH5PI(WT,HV,PDUM1,PDUM2,PDUMI,JNPI)
          ELSEIF(JNPI.LE.NM4+NM5+NM6) THEN
            CALL DPHNPI(WT,HV,PDUM1,PDUM2,PDUMI,JNPI)
          ELSEIF(JNPI.LE.NM4+NM5+NM6+NM3) THEN
            INUM=JNPI-NM4-NM5-NM6
            CALL DPHSPK(WT,HV,PDUM1,PDUM2,PDUMI,INUM)
          ELSEIF(JNPI.LE.NM4+NM5+NM6+NM3+NM2) THEN
            INUM=JNPI-NM4-NM5-NM6-NM3
            CALL DPHSRK(WT,HV,PDUM1,PDUM2,PDUMI,INUM)
          ELSE
           GOTO 903
          ENDIF
        IF(WT.GT.WTMAX(JNPI)/1.2) WTMAX(JNPI)=WT*1.2
        ENDDO
C       CALL HBOOK1(801,'WEIGHT DISTRIBUTION  DADNPI    $',100,0.,2.,.0)
C       PRINT 7004,WTMAX(JNPI)
1       CONTINUE
        WRITE(IOUT,7005)
C
      ELSEIF(MODE.EQ. 0) THEN
C     =======================
        IF(IWARM.EQ.0) GOTO 902
C
300     CONTINUE
          IF    (JNPI.LE.0) THEN
            GOTO 903
          ELSEIF(JNPI.LE.NM4) THEN
             CALL DPH4PI(WT,HHV,PNU,PWB,PNPI,JNPI)
          ELSEIF(JNPI.LE.NM4+NM5) THEN
             CALL DPH5PI(WT,HHV,PNU,PWB,PNPI,JNPI)
          ELSEIF(JNPI.LE.NM4+NM5+NM6) THEN
            CALL DPHNPI(WT,HHV,PNU,PWB,PNPI,JNPI)
          ELSEIF(JNPI.LE.NM4+NM5+NM6+NM3) THEN
            INUM=JNPI-NM4-NM5-NM6
            CALL DPHSPK(WT,HHV,PNU,PWB,PNPI,INUM)
          ELSEIF(JNPI.LE.NM4+NM5+NM6+NM3+NM2) THEN
            INUM=JNPI-NM4-NM5-NM6-NM3
            CALL DPHSRK(WT,HHV,PNU,PWB,PNPI,INUM)
          ELSE
           GOTO 903
          ENDIF
            DO I=1,4
              HV(I)=-ISGN*HHV(I)
            ENDDO
C       CALL HFILL(801,WT/WTMAX(JNPI))
        NEVRAW(JNPI)=NEVRAW(JNPI)+1
        SWT(JNPI)=SWT(JNPI)+WT
cccM.S.>>>>>>
cc        SSWT(JNPI)=SSWT(JNPI)+WT**2
        SSWT(JNPI)=SSWT(JNPI)+dble(WT)**2
cccM.S.<<<<<<
        CALL RANMAR(RRR,3)
        RN=RRR(1)
        IF(WT.GT.WTMAX(JNPI)) NEVOVR(JNPI)=NEVOVR(JNPI)+1
        IF(RN*WTMAX(JNPI).GT.WT) GOTO 300
C ROTATIONS TO BASIC TAU REST FRAME
        COSTHE=-1.+2.*RRR(2)
        THET=ACOS(COSTHE)
        PHI =2*PI*RRR(3)
        CALL ROTOR2(THET,PNU,PNU)
        CALL ROTOR3( PHI,PNU,PNU)
        CALL ROTOR2(THET,PWB,PWB)
        CALL ROTOR3( PHI,PWB,PWB)
        CALL ROTOR2(THET,HV,HV)
        CALL ROTOR3( PHI,HV,HV)
        ND=MULPIK(JNPI)
        DO 301 I=1,ND
        CALL ROTOR2(THET,PNPI(1,I),PNPI(1,I))
        CALL ROTOR3( PHI,PNPI(1,I),PNPI(1,I))
301     CONTINUE
        NEVACC(JNPI)=NEVACC(JNPI)+1
C
      ELSEIF(MODE.EQ. 1) THEN
C     =======================
        DO 500 JNPI=1,NMOD
          IF(NEVRAW(JNPI).EQ.0) GOTO 500
          PARGAM=SWT(JNPI)/FLOAT(NEVRAW(JNPI)+1)
          ERROR=0
          IF(NEVRAW(JNPI).NE.0)
     &    ERROR=SQRT(SSWT(JNPI)/SWT(JNPI)**2-1./FLOAT(NEVRAW(JNPI)))
          RAT=PARGAM/GAMEL
          WRITE(IOUT, 7010) NAMES(JNPI),
     &     NEVRAW(JNPI),NEVACC(JNPI),NEVOVR(JNPI),PARGAM,RAT,ERROR
CC        CALL HPRINT(801)
          GAMPMC(8+JNPI-1)=RAT
          GAMPER(8+JNPI-1)=ERROR
CAM       NEVDEC(8+JNPI-1)=NEVACC(JNPI)
  500     CONTINUE
      ENDIF
C     =====
      RETURN
 7003 FORMAT(///1X,15(5H*****)
     $ /,' *',     25X,'******** DADNEW INITIALISATION ********',9X,1H*
     $ )
 7004 FORMAT(' *',E20.5,5X,'WTMAX  = MAXIMUM WEIGHT  ',9X,1H*/)
 7005 FORMAT(
     $  /,1X,15(5H*****)/)
 7010 FORMAT(///1X,15(5H*****)
     $ /,' *',     25X,'******** DADNEW FINAL REPORT  ******** ',9X,1H*
     $ /,' *',     25X,'CHANNEL:',A31                           ,9X,1H*
     $ /,' *',I20  ,5X,'NEVRAW = NO. OF DECAYS TOTAL           ',9X,1H*
     $ /,' *',I20  ,5X,'NEVACC = NO. OF DECAYS ACCEPTED        ',9X,1H*
     $ /,' *',I20  ,5X,'NEVOVR = NO. OF OVERWEIGHTED EVENTS    ',9X,1H*
     $ /,' *',E20.5,5X,'PARTIAL WTDTH IN GEV UNITS             ',9X,1H*
     $ /,' *',F20.9,5X,'IN UNITS GFERMI**2*MASS**5/192/PI**3   ',9X,1H*
     $ /,' *',F20.8,5X,'RELATIVE ERROR OF PARTIAL WIDTH        ',9X,1H*
     $  /,1X,15(5H*****)/)
 902  WRITE(IOUT, 9020)
 9020 FORMAT(' ----- DADNEW: LACK OF INITIALISATION')
      STOP
 903  WRITE(IOUT, 9030) JNPI,MODE
 9030 FORMAT(' ----- DADNEW: WRONG JNPI',2I5)
      STOP
      END


      SUBROUTINE DPH4PI(DGAMT,HV,PN,PAA,PMULT,JNPI)
C ----------------------------------------------------------------------
* IT SIMULATES A1  DECAY IN TAU REST FRAME WITH
* Z-AXIS ALONG A1  MOMENTUM
C ----------------------------------------------------------------------
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / DECPAR / GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL*4            GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL  HV(4),PT(4),PN(4),PAA(4),PIM1(4),PIM2(4),PIPL(4),PMULT(4,9)
      REAL  PR(4),PIZ(4)
      REAL*4 RRR(9)
      REAL*8 UU,FF,FF1,FF2,FF3,FF4,GG1,GG2,GG3,GG4,RR
      DATA PI /3.141592653589793238462643/
      DATA ICONT /0/
      XLAM(X,Y,Z)=SQRT(ABS((X-Y-Z)**2-4.0*Y*Z))
C AMRO, GAMRO IS ONLY A PARAMETER FOR GETING HIGHT EFFICIENCY
C
C THREE BODY PHASE SPACE NORMALISED AS IN BJORKEN-DRELL
C D**3 P /2E/(2PI)**3 (2PI)**4 DELTA4(SUM P)
      PHSPAC=1./2**23/PI**11
      PHSP=1./2**5/PI**2
      IF (JNPI.EQ.1) THEN
       PREZ=0.7
       AMP1=AMPI
       AMP2=AMPI
       AMP3=AMPI
       AMP4=AMPIZ
       AMRX=0.782
       GAMRX=0.0084
        AMROP =1.2
        GAMROP=.46

      ELSE
       PREZ=0.0
       AMP1=AMPIZ
       AMP2=AMPIZ
       AMP3=AMPIZ
       AMP4=AMPI
       AMRX=1.4
       GAMRX=.6
        AMROP =AMRX
        GAMROP=GAMRX

      ENDIF
      RR=0.3
      CALL CHOICE(100+JNPI,RR,ICHAN,PROB1,PROB2,PROB3,
     $            AMROP,GAMROP,AMRX,GAMRX,AMRB,GAMRB)
      PREZ=PROB1+PROB2
C TAU MOMENTUM
      PT(1)=0.
      PT(2)=0.
      PT(3)=0.
      PT(4)=AMTAU
C
      CALL RANMAR(RRR,9)
C
* MASSES OF 4, 3 AND 2 PI SYSTEMS
C 3 PI WITH SAMPLING FOR RESONANCE
CAM
        RR1=RRR(6)
        AMS1=(AMP1+AMP2+AMP3+AMP4)**2
        AMS2=(AMTAU-AMNUTA)**2
        ALP1=ATAN((AMS1-AMROP**2)/AMROP/GAMROP)
        ALP2=ATAN((AMS2-AMROP**2)/AMROP/GAMROP)
        ALP=ALP1+RR1*(ALP2-ALP1)
        AM4SQ =AMROP**2+AMROP*GAMROP*TAN(ALP)
        AM4 =SQRT(AM4SQ)
        PHSPAC=PHSPAC*
     $         ((AM4SQ-AMROP**2)**2+(AMROP*GAMROP)**2)/(AMROP*GAMROP)
        PHSPAC=PHSPAC*(ALP2-ALP1)

C
        RR1=RRR(1)
        AMS1=(AMP2+AMP3+AMP4)**2
        AMS2=(AM4-AMP1)**2
        IF (RRR(9).GT.PREZ) THEN
          AM3SQ=AMS1+   RR1*(AMS2-AMS1)
          AM3 =SQRT(AM3SQ)
C --- this part of jacobian will be recovered later
          FF1=AMS2-AMS1
        ELSE
* PHASE SPACE WITH SAMPLING FOR OMEGA RESONANCE,
        ALP1=ATAN((AMS1-AMRX**2)/AMRX/GAMRX)
        ALP2=ATAN((AMS2-AMRX**2)/AMRX/GAMRX)
        ALP=ALP1+RR1*(ALP2-ALP1)
        AM3SQ =AMRX**2+AMRX*GAMRX*TAN(ALP)
        AM3 =SQRT(AM3SQ)
C --- THIS PART OF THE JACOBIAN WILL BE RECOVERED LATER ---------------
        FF1=((AM3SQ-AMRX**2)**2+(AMRX*GAMRX)**2)/(AMRX*GAMRX)
        FF1=FF1*(ALP2-ALP1)
        ENDIF
C MASS OF 2
        RR2=RRR(2)
        AMS1=(AMP3+AMP4)**2
        AMS2=(AM3-AMP2)**2
* FLAT PHASE SPACE;
        AM2SQ=AMS1+   RR2*(AMS2-AMS1)
        AM2 =SQRT(AM2SQ)
C --- this part of jacobian will be recovered later
        FF2=(AMS2-AMS1)
*  2 RESTFRAME, DEFINE PIZ AND PIPL
        ENQ1=(AM2SQ-AMP3**2+AMP4**2)/(2*AM2)
        ENQ2=(AM2SQ+AMP3**2-AMP4**2)/(2*AM2)
        PPI=         ENQ1**2-AMP4**2
        PPPI=SQRT(ABS(ENQ1**2-AMP4**2))
        PHSPAC=PHSPAC*(4*PI)*(2*PPPI/AM2)
* PIZ   MOMENTUM IN 2 REST FRAME
        CALL SPHERA(PPPI,PIZ)
        PIZ(4)=ENQ1
* PIPL  MOMENTUM IN 2 REST FRAME
        DO 30 I=1,3
 30     PIPL(I)=-PIZ(I)
        PIPL(4)=ENQ2
* 3 REST FRAME, DEFINE PIM1
*       PR   MOMENTUM
        PR(1)=0
        PR(2)=0
        PR(4)=1./(2*AM3)*(AM3**2+AM2**2-AMP2**2)
        PR(3)= SQRT(ABS(PR(4)**2-AM2**2))
        PPI  =          PR(4)**2-AM2**2
*       PIM1  MOMENTUM
        PIM1(1)=0
        PIM1(2)=0
        PIM1(4)=1./(2*AM3)*(AM3**2-AM2**2+AMP2**2)
        PIM1(3)=-PR(3)
C --- this part of jacobian will be recovered later
        FF3=(4*PI)*(2*PR(3)/AM3)
* OLD PIONS BOOSTED FROM 2 REST FRAME TO 3 REST FRAME
      EXE=(PR(4)+PR(3))/AM2
      CALL BOSTR3(EXE,PIZ,PIZ)
      CALL BOSTR3(EXE,PIPL,PIPL)
      RR3=RRR(3)
      RR4=RRR(4)
      THET =ACOS(-1.+2*RR3)
      PHI = 2*PI*RR4
      CALL ROTPOL(THET,PHI,PIPL)
      CALL ROTPOL(THET,PHI,PIM1)
      CALL ROTPOL(THET,PHI,PIZ)
      CALL ROTPOL(THET,PHI,PR)
* 4  REST FRAME, DEFINE PIM2
*       PR   MOMENTUM
        PR(1)=0
        PR(2)=0
        PR(4)=1./(2*AM4)*(AM4**2+AM3**2-AMP1**2)
        PR(3)= SQRT(ABS(PR(4)**2-AM3**2))
        PPI  =          PR(4)**2-AM3**2
*       PIM2 MOMENTUM
        PIM2(1)=0
        PIM2(2)=0
        PIM2(4)=1./(2*AM4)*(AM4**2-AM3**2+AMP1**2)
        PIM2(3)=-PR(3)
C --- this part of jacobian will be recovered later
        FF4=(4*PI)*(2*PR(3)/AM4)
* OLD PIONS BOOSTED FROM 3 REST FRAME TO 4 REST FRAME
      EXE=(PR(4)+PR(3))/AM3
      CALL BOSTR3(EXE,PIZ,PIZ)
      CALL BOSTR3(EXE,PIPL,PIPL)
      CALL BOSTR3(EXE,PIM1,PIM1)
      RR3=RRR(7)
      RR4=RRR(8)
      THET =ACOS(-1.+2*RR3)
      PHI = 2*PI*RR4
      CALL ROTPOL(THET,PHI,PIPL)
      CALL ROTPOL(THET,PHI,PIM1)
      CALL ROTPOL(THET,PHI,PIM2)
      CALL ROTPOL(THET,PHI,PIZ)
      CALL ROTPOL(THET,PHI,PR)
C
* NOW TO THE TAU REST FRAME, DEFINE PAA AND NEUTRINO MOMENTA
* PAA  MOMENTUM
      PAA(1)=0
      PAA(2)=0
      PAA(4)=1./(2*AMTAU)*(AMTAU**2-AMNUTA**2+AM4**2)
      PAA(3)= SQRT(ABS(PAA(4)**2-AM4**2))
      PPI   =          PAA(4)**2-AM4**2
      PHSPAC=PHSPAC*(4*PI)*(2*PAA(3)/AMTAU)
      PHSP=PHSP*(4*PI)*(2*PAA(3)/AMTAU)
* TAU-NEUTRINO MOMENTUM
      PN(1)=0
      PN(2)=0
      PN(4)=1./(2*AMTAU)*(AMTAU**2+AMNUTA**2-AM4**2)
      PN(3)=-PAA(3)
C WE INCLUDE REMAINING PART OF THE JACOBIAN
C --- FLAT CHANNEL
        AM3SQ=(PIM1(4)+PIZ(4)+PIPL(4))**2-(PIM1(3)+PIZ(3)+PIPL(3))**2
     $       -(PIM1(2)+PIZ(2)+PIPL(2))**2-(PIM1(1)+PIZ(1)+PIPL(1))**2
        AMS2=(AM4-AMP2)**2
        AMS1=(AMP1+AMP3+AMP4)**2
        FF1=(AMS2-AMS1)
        AMS1=(AMP3+AMP4)**2
        AMS2=(SQRT(AM3SQ)-AMP1)**2
        FF2=AMS2-AMS1
        FF3=(4*PI)*(XLAM(AM2**2,AMP1**2,AM3SQ)/AM3SQ)
        FF4=(4*PI)*(XLAM(AM3SQ,AMP2**2,AM4**2)/AM4**2)
        UU=FF1*FF2*FF3*FF4
C --- FIRST CHANNEL
        AM3SQ=(PIM1(4)+PIZ(4)+PIPL(4))**2-(PIM1(3)+PIZ(3)+PIPL(3))**2
     $       -(PIM1(2)+PIZ(2)+PIPL(2))**2-(PIM1(1)+PIZ(1)+PIPL(1))**2
        AMS2=(AM4-AMP2)**2
        AMS1=(AMP1+AMP3+AMP4)**2
        ALP1=ATAN((AMS1-AMRX**2)/AMRX/GAMRX)
        ALP2=ATAN((AMS2-AMRX**2)/AMRX/GAMRX)
        FF1=((AM3SQ-AMRX**2)**2+(AMRX*GAMRX)**2)/(AMRX*GAMRX)
        FF1=FF1*(ALP2-ALP1)
        AMS1=(AMP3+AMP4)**2
        AMS2=(SQRT(AM3SQ)-AMP1)**2
        FF2=AMS2-AMS1
        FF3=(4*PI)*(XLAM(AM2**2,AMP1**2,AM3SQ)/AM3SQ)
        FF4=(4*PI)*(XLAM(AM3SQ,AMP2**2,AM4**2)/AM4**2)
        FF=FF1*FF2*FF3*FF4
C --- SECOND CHANNEL
        AM3SQ=(PIM2(4)+PIZ(4)+PIPL(4))**2-(PIM2(3)+PIZ(3)+PIPL(3))**2
     $       -(PIM2(2)+PIZ(2)+PIPL(2))**2-(PIM2(1)+PIZ(1)+PIPL(1))**2
        AMS2=(AM4-AMP1)**2
        AMS1=(AMP2+AMP3+AMP4)**2
        ALP1=ATAN((AMS1-AMRX**2)/AMRX/GAMRX)
        ALP2=ATAN((AMS2-AMRX**2)/AMRX/GAMRX)
        GG1=((AM3SQ-AMRX**2)**2+(AMRX*GAMRX)**2)/(AMRX*GAMRX)
        GG1=GG1*(ALP2-ALP1)
        AMS1=(AMP3+AMP4)**2
        AMS2=(SQRT(AM3SQ)-AMP2)**2
        GG2=AMS2-AMS1
        GG3=(4*PI)*(XLAM(AM2**2,AMP2**2,AM3SQ)/AM3SQ)
        GG4=(4*PI)*(XLAM(AM3SQ,AMP1**2,AM4**2)/AM4**2)
        GG=GG1*GG2*GG3*GG4
C --- JACOBIAN AVERAGED OVER THE TWO
        IF ( ( (FF+GG)*UU+FF*GG ).GT.0.0D0) THEN
          RR=FF*GG*UU/(0.5*PREZ*(FF+GG)*UU+(1.0-PREZ)*FF*GG)
          PHSPAC=PHSPAC*RR
        ELSE
          PHSPAC=0.0
        ENDIF
* MOMENTA OF THE TWO PI-MINUS ARE RANDOMLY SYMMETRISED
       IF (JNPI.EQ.1) THEN
        RR5= RRR(5)
        IF(RR5.LE.0.5) THEN
         DO 70 I=1,4
         X=PIM1(I)
         PIM1(I)=PIM2(I)
 70      PIM2(I)=X
        ENDIF
        PHSPAC=PHSPAC/2.
       ELSE
C MOMENTA OF PI0'S ARE GENERATED UNIFORMLY ONLY IF PREZ=0.0
        RR5= RRR(5)
        IF(RR5.LE.0.5) THEN
         DO 71 I=1,4
         X=PIM1(I)
         PIM1(I)=PIM2(I)
 71      PIM2(I)=X
        ENDIF
        PHSPAC=PHSPAC/6.
       ENDIF
* ALL PIONS BOOSTED FROM  4  REST FRAME TO TAU REST FRAME
* Z-AXIS ANTIPARALLEL TO NEUTRINO MOMENTUM
      EXE=(PAA(4)+PAA(3))/AM4
      CALL BOSTR3(EXE,PIZ,PIZ)
      CALL BOSTR3(EXE,PIPL,PIPL)
      CALL BOSTR3(EXE,PIM1,PIM1)
      CALL BOSTR3(EXE,PIM2,PIM2)
      CALL BOSTR3(EXE,PR,PR)
C PARTIAL WIDTH CONSISTS OF PHASE SPACE AND AMPLITUDE
C CHECK ON CONSISTENCY WITH DADNPI, THEN, CODE BREAKES UNIFORM PION
C DISTRIBUTION IN HADRONIC SYSTEM
CAM     Assume neutrino mass=0. and sum over final polarisation
C      AMX2=AM4**2
C      BRAK= 2*(AMTAU**2-AMX2) * (AMTAU**2+2.*AMX2)
C      AMPLIT=CCABIB**2*GFERMI**2/2. * BRAK * AMX2*SIGEE(AMX2,1)
      IF     (JNPI.EQ.1) THEN
        CALL DAM4PI(JNPI,PT,PN,PIM1,PIM2,PIZ,PIPL,AMPLIT,HV)
      ELSEIF (JNPI.EQ.2) THEN
        CALL DAM4PI(JNPI,PT,PN,PIM1,PIM2,PIPL,PIZ,AMPLIT,HV)
      ENDIF
      DGAMT=1/(2.*AMTAU)*AMPLIT*PHSPAC
C PHASE SPACE CHECK
C      DGAMT=PHSPAC
      DO 77 K=1,4
        PMULT(K,1)=PIM1(K)
        PMULT(K,2)=PIM2(K)
        PMULT(K,3)=PIPL(K)
        PMULT(K,4)=PIZ (K)
 77   CONTINUE
      END
      SUBROUTINE DAM4PI(MNUM,PT,PN,PIM1,PIM2,PIM3,PIM4,AMPLIT,HV)
C ----------------------------------------------------------------------
* CALCULATES DIFFERENTIAL CROSS SECTION AND POLARIMETER VECTOR
* FOR TAU DECAY INTO 4 PI MODES
* ALL SPIN EFFECTS IN THE FULL DECAY CHAIN ARE TAKEN INTO ACCOUNT.
* CALCULATIONS DONE IN TAU REST FRAME WITH Z-AXIS ALONG NEUTRINO MOMENT
C MNUM DECAY MODE IDENTIFIER.
C
C     called by : DPHSAA
C ----------------------------------------------------------------------
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / DECPAR / GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL*4            GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL  HV(4),PT(4),PN(4),PIM1(4),PIM2(4),PIM3(4),PIM4(4)
      REAL  PIVEC(4),PIAKS(4),HVM(4)
      COMPLEX HADCUR(4),FORM1,FORM2,FORM3,FORM4,FORM5
      EXTERNAL FORM1,FORM2,FORM3,FORM4,FORM5
      DATA PI /3.141592653589793238462643/
      DATA ICONT /0/
C
      CALL CURR(MNUM,PIM1,PIM2,PIM3,PIM4,HADCUR)
C
* CALCULATE PI-VECTORS: VECTOR AND AXIAL
      CALL CLVEC(HADCUR,PN,PIVEC)
      CALL CLAXI(HADCUR,PN,PIAKS)
      CALL CLNUT(HADCUR,BRAKM,HVM)
* SPIN INDEPENDENT PART OF DECAY DIFF-CROSS-SECT. IN TAU REST  FRAME
      BRAK= (GV**2+GA**2)*PT(4)*PIVEC(4) +2.*GV*GA*PT(4)*PIAKS(4)
     &     +2.*(GV**2-GA**2)*AMNUTA*AMTAU*BRAKM
      AMPLIT=(CCABIB*GFERMI)**2*BRAK/2.
C POLARIMETER VECTOR IN TAU REST FRAME
      DO 90 I=1,3
      HV(I)=-(AMTAU*((GV**2+GA**2)*PIAKS(I)+2.*GV*GA*PIVEC(I)))
     &      +(GV**2-GA**2)*AMNUTA*AMTAU*HVM(I)
C HV IS DEFINED FOR TAU-    WITH GAMMA=B+HV*POL
      IF (BRAK.NE.0.0)
     &HV(I)=-HV(I)/BRAK
 90   CONTINUE
      END
       SUBROUTINE DPH5PI(DGAMT,HV,PN,PAA,PMULT,JNPI)
C ----------------------------------------------------------------------
* IT SIMULATES 5pi DECAY IN TAU REST FRAME WITH
* Z-AXIS ALONG 5pi MOMENTUM
C ----------------------------------------------------------------------
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1


     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / DECPAR / GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL*4            GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      PARAMETER (NMODE=15,NM1=0,NM2=1,NM3=8,NM4=2,NM5=1,NM6=3)
      COMMON / DECOMP /IDFFIN(9,NMODE),MULPIK(NMODE)
     &                ,NAMES
      CHARACTER NAMES(NMODE)*31
      REAL  HV(4),PT(4),PN(4),PAA(4),PMULT(4,9)
      REAL*4 PR(4),PI1(4),PI2(4),PI3(4),PI4(4),PI5(4)
      REAL*8 AMP1,AMP2,AMP3,AMP4,AMP5,ams1,ams2,amom,gamom
      REAL*8 AM5SQ,AM4SQ,AM3SQ,AM2SQ,AM5,AM4,AM3
      REAL*4 RRR(10)
      REAL*8 gg1,gg2,gg3,ff1,ff2,ff3,ff4,alp,alp1,alp2
      REAL*8 XM,AM,GAMMA
ccM.S.>>>>>>
      real*8 phspac
ccM.S.<<<<<<
      DATA PI /3.141592653589793238462643/
      DATA ICONT /0/
      data fpi /93.3e-3/
c
      COMPLEX BWIGN
C
      BWIGN(XM,AM,GAMMA)=XM**2/CMPLX(XM**2-AM**2,GAMMA*AM)
C
      AMOM=.782
      GAMOM=0.0085
c
C 6 BODY PHASE SPACE NORMALISED AS IN BJORKEN-DRELL
C D**3 P /2E/(2PI)**3 (2PI)**4 DELTA4(SUM P)
      PHSPAC=1./2**29/PI**14
c     PHSPAC=1./2**5/PI**2
C init 5pi decay mode (JNPI)
      AMP1=DCDMAS(IDFFIN(1,JNPI))
      AMP2=DCDMAS(IDFFIN(2,JNPI))
      AMP3=DCDMAS(IDFFIN(3,JNPI))
      AMP4=DCDMAS(IDFFIN(4,JNPI))
      AMP5=DCDMAS(IDFFIN(5,JNPI))
c
C TAU MOMENTUM
      PT(1)=0.
      PT(2)=0.
      PT(3)=0.
      PT(4)=AMTAU
C
      CALL RANMAR(RRR,10)
C
c masses of 5, 4, 3 and 2 pi systems
c 3 pi with sampling for omega resonance
cam
c mass of 5   (12345)
      rr1=rrr(10)
      ams1=(amp1+amp2+amp3+amp4+amp5)**2
      ams2=(amtau-amnuta)**2
      am5sq=ams1+   rr1*(ams2-ams1)
      am5 =sqrt(am5sq)
      phspac=phspac*(ams2-ams1)
c
c mass of 4   (2345)
c flat phase space
      rr1=rrr(9)
      ams1=(amp2+amp3+amp4+amp5)**2
      ams2=(am5-amp1)**2
      am4sq=ams1+   rr1*(ams2-ams1)
      am4 =sqrt(am4sq)
      gg1=ams2-ams1
c
c mass of 3   (234)
C phase space with sampling for omega resonance
      rr1=rrr(1)
      ams1=(amp2+amp3+amp4)**2
      ams2=(am4-amp5)**2
      alp1=atan((ams1-amom**2)/amom/gamom)
      alp2=atan((ams2-amom**2)/amom/gamom)
      alp=alp1+rr1*(alp2-alp1)
      am3sq =amom**2+amom*gamom*tan(alp)
      am3 =sqrt(am3sq)
c --- this part of the jacobian will be recovered later ---------------
      gg2=((am3sq-amom**2)**2+(amom*gamom)**2)/(amom*gamom)
      gg2=gg2*(alp2-alp1)
c flat phase space;
C      am3sq=ams1+   rr1*(ams2-ams1)
C      am3 =sqrt(am3sq)
c --- this part of jacobian will be recovered later
C      gg2=ams2-ams1
c
C mass of 2  (34)
      rr2=rrr(2)
      ams1=(amp3+amp4)**2
      ams2=(am3-amp2)**2
c flat phase space;
      am2sq=ams1+   rr2*(ams2-ams1)
      am2 =sqrt(am2sq)
c --- this part of jacobian will be recovered later
      gg3=ams2-ams1
c
c (34) restframe, define pi3 and pi4
      enq1=(am2sq+amp3**2-amp4**2)/(2*am2)
      enq2=(am2sq-amp3**2+amp4**2)/(2*am2)
      ppi=          enq1**2-amp3**2
      pppi=sqrt(abs(enq1**2-amp3**2))
      ff1=(4*pi)*(2*pppi/am2)
c pi3   momentum in (34) rest frame
      call sphera(pppi,pi3)
      pi3(4)=enq1
c pi4   momentum in (34) rest frame
      do 30 i=1,3
 30   pi4(i)=-pi3(i)
      pi4(4)=enq2
c
c (234) rest frame, define pi2
c pr   momentum
      pr(1)=0
      pr(2)=0
      pr(4)=1./(2*am3)*(am3**2+am2**2-amp2**2)
      pr(3)= sqrt(abs(pr(4)**2-am2**2))
      ppi  =          pr(4)**2-am2**2
c pi2   momentum
      pi2(1)=0
      pi2(2)=0
      pi2(4)=1./(2*am3)*(am3**2-am2**2+amp2**2)
      pi2(3)=-pr(3)
c --- this part of jacobian will be recovered later
      ff2=(4*pi)*(2*pr(3)/am3)
c old pions boosted from 2 rest frame to 3 rest frame
      exe=(pr(4)+pr(3))/am2
      call bostr3(exe,pi3,pi3)
      call bostr3(exe,pi4,pi4)
      rr3=rrr(3)
      rr4=rrr(4)
      thet =acos(-1.+2*rr3)
      phi = 2*pi*rr4
      call rotpol(thet,phi,pi2)
      call rotpol(thet,phi,pi3)
      call rotpol(thet,phi,pi4)
C
C (2345)  rest frame, define pi5
c pr   momentum
      pr(1)=0
      pr(2)=0
      pr(4)=1./(2*am4)*(am4**2+am3**2-amp5**2)
      pr(3)= sqrt(abs(pr(4)**2-am3**2))
      ppi  =          pr(4)**2-am3**2
c pi5  momentum
      pi5(1)=0
      pi5(2)=0
      pi5(4)=1./(2*am4)*(am4**2-am3**2+amp5**2)
      pi5(3)=-pr(3)
c --- this part of jacobian will be recovered later
      ff3=(4*pi)*(2*pr(3)/am4)
c old pions boosted from 3 rest frame to 4 rest frame
      exe=(pr(4)+pr(3))/am3
      call bostr3(exe,pi2,pi2)
      call bostr3(exe,pi3,pi3)
      call bostr3(exe,pi4,pi4)
      rr3=rrr(5)
      rr4=rrr(6)
      thet =acos(-1.+2*rr3)
      phi = 2*pi*rr4
      call rotpol(thet,phi,pi2)
      call rotpol(thet,phi,pi3)
      call rotpol(thet,phi,pi4)
      call rotpol(thet,phi,pi5)
C
C (12345)  rest frame, define pi1
c pr   momentum
      pr(1)=0
      pr(2)=0
      pr(4)=1./(2*am5)*(am5**2+am4**2-amp1**2)
      pr(3)= sqrt(abs(pr(4)**2-am4**2))
      ppi  =          pr(4)**2-am4**2
c pi1  momentum
      pi1(1)=0
      pi1(2)=0
      pi1(4)=1./(2*am5)*(am5**2-am4**2+amp1**2)
      pi1(3)=-pr(3)
c --- this part of jacobian will be recovered later
      ff4=(4*pi)*(2*pr(3)/am5)
c old pions boosted from 4 rest frame to 5 rest frame
      exe=(pr(4)+pr(3))/am4
      call bostr3(exe,pi2,pi2)
      call bostr3(exe,pi3,pi3)
      call bostr3(exe,pi4,pi4)
      call bostr3(exe,pi5,pi5)
      rr3=rrr(7)
      rr4=rrr(8)
      thet =acos(-1.+2*rr3)
      phi = 2*pi*rr4
      call rotpol(thet,phi,pi1)
      call rotpol(thet,phi,pi2)
      call rotpol(thet,phi,pi3)
      call rotpol(thet,phi,pi4)
      call rotpol(thet,phi,pi5)
c
* now to the tau rest frame, define paa and neutrino momenta
* paa  momentum
      paa(1)=0
      paa(2)=0
c     paa(4)=1./(2*amtau)*(amtau**2-amnuta**2+am5**2)
c     paa(3)= sqrt(abs(paa(4)**2-am5**2))
c     ppi   =          paa(4)**2-am5**2
      paa(4)=1./(2*amtau)*(amtau**2-amnuta**2+am5sq)
      paa(3)= sqrt(abs(paa(4)**2-am5sq))
      ppi   =          paa(4)**2-am5sq
      phspac=phspac*(4*pi)*(2*paa(3)/amtau)
* tau-neutrino momentum
      pn(1)=0
      pn(2)=0
      pn(4)=1./(2*amtau)*(amtau**2+amnuta**2-am5**2)
      pn(3)=-paa(3)
c
      phspac=phspac * gg1*gg2*gg3*ff1*ff2*ff3*ff4
c
C all pions boosted from  5  rest frame to tau rest frame
C z-axis antiparallel to neutrino momentum
      exe=(paa(4)+paa(3))/am5
      call bostr3(exe,pi1,pi1)
      call bostr3(exe,pi2,pi2)
      call bostr3(exe,pi3,pi3)
      call bostr3(exe,pi4,pi4)
      call bostr3(exe,pi5,pi5)
c
C partial width consists of phase space and amplitude
C AMPLITUDE  (cf YS.Tsai Phys.Rev.D4,2821(1971)
C    or F.Gilman SH.Rhie Phys.Rev.D31,1066(1985)
C
      PXQ=AMTAU*PAA(4)
      PXN=AMTAU*PN(4)
      QXN=PAA(4)*PN(4)-PAA(1)*PN(1)-PAA(2)*PN(2)-PAA(3)*PN(3)
      BRAK=2*(GV**2+GA**2)*(2*PXQ*QXN+AM5SQ*PXN)
     &    -6*(GV**2-GA**2)*AMTAU*AMNUTA*AM5SQ
      fompp = cabs(bwign(am3,amom,gamom))**2
c normalisation factor (to some numerical undimensioned factor;
c cf R.Fischer et al ZPhys C3, 313 (1980))
      fnorm = 1/fpi**6
c     AMPLIT=CCABIB**2*GFERMI**2/2. * BRAK * AM5SQ*SIGEE(AM5SQ,JNPI)
      AMPLIT=CCABIB**2*GFERMI**2/2. * BRAK
      amplit = amplit * fompp * fnorm
c phase space test
c     amplit = amplit * fnorm
      DGAMT=1/(2.*AMTAU)*AMPLIT*PHSPAC
c ignore spin terms
      DO 40 I=1,3
 40   HV(I)=0.
c
      do 77 k=1,4
        pmult(k,1)=pi1(k)
        pmult(k,2)=pi2(k)
        pmult(k,3)=pi3(k)
        pmult(k,4)=pi4(k)
        pmult(k,5)=pi5(k)
 77   continue
      return
C missing: transposition of identical particles, startistical factors
C for identical matrices, polarimetric vector. Matrix element rather naive.
C flat phase space in pion system + with breit wigner for omega
C anyway it is better than nothing, and code is improvable.
      end
      SUBROUTINE DPHSRK(DGAMT,HV,PN,PR,PMULT,INUM)
C ----------------------------------------------------------------------
C IT SIMULATES RHO DECAY IN TAU REST FRAME WITH
C Z-AXIS ALONG RHO MOMENTUM
C Rho decays to K Kbar
C ----------------------------------------------------------------------
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
      COMMON / DECPAR / GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL*4            GFERMI,GV,GA,CCABIB,SCABIB,GAMEL
      REAL  HV(4),PT(4),PN(4),PR(4),PKC(4),PKZ(4),QQ(4),PMULT(4,9)
      DATA PI /3.141592653589793238462643/
      DATA ICONT /0/
C
C THREE BODY PHASE SPACE NORMALISED AS IN BJORKEN-DRELL
      PHSPAC=1./2**11/PI**5
C TAU MOMENTUM
      PT(1)=0.
      PT(2)=0.
      PT(3)=0.
      PT(4)=AMTAU
C MASS OF (REAL/VIRTUAL) RHO
      AMS1=(AMK+AMKZ)**2
      AMS2=(AMTAU-AMNUTA)**2
C FLAT PHASE SPACE
      CALL RANMAR(RR1,1)
      AMX2=AMS1+   RR1*(AMS2-AMS1)
      AMX=SQRT(AMX2)
      PHSPAC=PHSPAC*(AMS2-AMS1)
C PHASE SPACE WITH SAMPLING FOR RHO RESONANCE
c     ALP1=ATAN((AMS1-AMRO**2)/AMRO/GAMRO)
c     ALP2=ATAN((AMS2-AMRO**2)/AMRO/GAMRO)
CAM
 100  CONTINUE
c     CALL RANMAR(RR1,1)
c     ALP=ALP1+RR1*(ALP2-ALP1)
c     AMX2=AMRO**2+AMRO*GAMRO*TAN(ALP)
c     AMX=SQRT(AMX2)
c     IF(AMX.LT.(AMK+AMKZ)) GO TO 100
CAM
c     PHSPAC=PHSPAC*((AMX2-AMRO**2)**2+(AMRO*GAMRO)**2)/(AMRO*GAMRO)
c     PHSPAC=PHSPAC*(ALP2-ALP1)
C
C TAU-NEUTRINO MOMENTUM
      PN(1)=0
      PN(2)=0
      PN(4)=1./(2*AMTAU)*(AMTAU**2+AMNUTA**2-AMX**2)
      PN(3)=-SQRT((PN(4)-AMNUTA)*(PN(4)+AMNUTA))
C RHO MOMENTUM
      PR(1)=0
      PR(2)=0
      PR(4)=1./(2*AMTAU)*(AMTAU**2-AMNUTA**2+AMX**2)
      PR(3)=-PN(3)
      PHSPAC=PHSPAC*(4*PI)*(2*PR(3)/AMTAU)
C
CAM
      ENQ1=(AMX2+AMK**2-AMKZ**2)/(2.*AMX)
      ENQ2=(AMX2-AMK**2+AMKZ**2)/(2.*AMX)
      PPPI=SQRT((ENQ1-AMK)*(ENQ1+AMK))
      PHSPAC=PHSPAC*(4*PI)*(2*PPPI/AMX)
C CHARGED PI MOMENTUM IN RHO REST FRAME
      CALL SPHERA(PPPI,PKC)
      PKC(4)=ENQ1
C NEUTRAL PI MOMENTUM IN RHO REST FRAME
      DO 20 I=1,3
20    PKZ(I)=-PKC(I)
      PKZ(4)=ENQ2
      EXE=(PR(4)+PR(3))/AMX
C PIONS BOOSTED FROM RHO REST FRAME TO TAU REST FRAME
      CALL BOSTR3(EXE,PKC,PKC)
      CALL BOSTR3(EXE,PKZ,PKZ)
      DO 30 I=1,4
 30      QQ(I)=PKC(I)-PKZ(I)
C QQ transverse to PR
        PKSD =PR(4)*PR(4)-PR(3)*PR(3)-PR(2)*PR(2)-PR(1)*PR(1)
        QQPKS=PR(4)* QQ(4)-PR(3)* QQ(3)-PR(2)* QQ(2)-PR(1)* QQ(1)
        DO 31 I=1,4
31      QQ(I)=QQ(I)-PR(I)*QQPKS/PKSD
C AMPLITUDE
      PRODPQ=PT(4)*QQ(4)
      PRODNQ=PN(4)*QQ(4)-PN(1)*QQ(1)-PN(2)*QQ(2)-PN(3)*QQ(3)
      PRODPN=PT(4)*PN(4)
      QQ2= QQ(4)**2-QQ(1)**2-QQ(2)**2-QQ(3)**2
      BRAK=(GV**2+GA**2)*(2*PRODPQ*PRODNQ-PRODPN*QQ2)
     &    +(GV**2-GA**2)*AMTAU*AMNUTA*QQ2
      AMPLIT=(GFERMI*CCABIB)**2*BRAK*2*FPIRK(AMX)
      DGAMT=1/(2.*AMTAU)*AMPLIT*PHSPAC
      DO 40 I=1,3
 40   HV(I)=2*GV*GA*AMTAU*(2*PRODNQ*QQ(I)-QQ2*PN(I))/BRAK
      do 77 k=1,4
        pmult(k,1)=pkc(k)
        pmult(k,2)=pkz(k)
 77   continue
      RETURN
      END
      FUNCTION FPIRK(W)
C ----------------------------------------------------------
c     square of pion form factor
C ----------------------------------------------------------
      COMMON / PARMAS / AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
C
      REAL*4            AMTAU,AMNUTA,AMEL,AMNUE,AMMU,AMNUMU
     *                 ,AMPIZ,AMPI,AMRO,GAMRO,AMA1,GAMA1
     *                 ,AMK,AMKZ,AMKST,GAMKST
c     COMPLEX FPIKMK
      COMPLEX FPIKM
      FPIRK=CABS(FPIKM(W,AMK,AMKZ))**2
c     FPIRK=CABS(FPIKMK(W,AMK,AMKZ))**2
      END
      COMPLEX FUNCTION FPIKMK(W,XM1,XM2)
C **********************************************************
C     Kaon form factor
C **********************************************************
      COMPLEX BWIGM
      REAL ROM,ROG,ROM1,ROG1,BETA1,PI,PIM,S,W
      EXTERNAL BWIG
      DATA  INIT /0/
C
C ------------ PARAMETERS --------------------
      IF (INIT.EQ.0 ) THEN
      INIT=1
      PI=3.141592654
      PIM=.140
      ROM=0.773
      ROG=0.145
      ROM1=1.570
      ROG1=0.510
c     BETA1=-0.111
      BETA1=-0.221
      ENDIF
C -----------------------------------------------
      S=W**2
      FPIKMK=(BWIGM(S,ROM,ROG,XM1,XM2)+BETA1*BWIGM(S,ROM1,ROG1,XM1,XM2))
     & /(1+BETA1)
      RETURN
      END
      SUBROUTINE RESLU
C     ****************
C INITIALIZE LUND COMMON
      PARAMETER (NMXHEP=2000)
      COMMON/HEPEVT/NEVHEP,NHEP,ISTHEP(NMXHEP),IDHEP(NMXHEP),
     &JMOHEP(2,NMXHEP),JDAHEP(2,NMXHEP),PHEP(5,NMXHEP),VHEP(4,NMXHEP)
      SAVE  /HEPEVT/
      NHEP=0
      END
      SUBROUTINE DWRPH(KTO,PHX)
C
C -------------------------
C
      IMPLICIT REAL*8 (A-H,O-Z)
      REAL*4         PHX(4)
      REAL*4 QHOT(4)
C
      DO  9 K=1,4
      QHOT(K)  =0.0
  9   CONTINUE
C CASE OF TAU RADIATIVE DECAYS.
C FILLING OF THE LUND COMMON BLOCK.
        DO 1002 I=1,4
 1002   QHOT(I)=PHX(I)
        IF (QHOT(4).GT.1.E-5) CALL DWLUPH(KTO,QHOT)
        RETURN
      END
      SUBROUTINE DWLUPH(KTO,PHOT)
C---------------------------------------------------------------------
C Lorentz transformation to CMsystem and
C Updating of HEPEVT record
C
C     called by : DEXAY1,(DEKAY1,DEKAY2)
C
C used when radiative corrections in decays are generated
C---------------------------------------------------------------------
C
      REAL  PHOT(4)
      COMMON /TAUPOS/ NP1,NP2
C
C check energy
      IF (PHOT(4).LE.0.0) RETURN
C
C position of decaying particle:
      IF((KTO.EQ. 1).OR.(KTO.EQ.11)) THEN
        NPS=NP1
      ELSE
        NPS=NP2
      ENDIF
C
      KTOS=KTO
      IF(KTOS.GT.10) KTOS=KTOS-10
C boost and append photon (gamma is 22)
      CALL TRALO4(KTOS,PHOT,PHOT,AM)
      CALL FILHEP(0,1,22,NPS,NPS,0,0,PHOT,0.0,.TRUE.)
C
      RETURN
      END

      SUBROUTINE DWLUEL(KTO,ISGN,PNU,PWB,PEL,PNE)
C ----------------------------------------------------------------------
C Lorentz transformation to CMsystem and
C Updating of HEPEVT record
C
C ISGN = 1/-1 for tau-/tau+
C
C     called by : DEXAY,(DEKAY1,DEKAY2)
C ----------------------------------------------------------------------
C
      REAL  PNU(4),PWB(4),PEL(4),PNE(4)
      COMMON /TAUPOS/ NP1,NP2
C
C position of decaying particle:
      IF(KTO.EQ. 1) THEN
        NPS=NP1
      ELSE
        NPS=NP2
      ENDIF
C
C tau neutrino (nu_tau is 16)
      CALL TRALO4(KTO,PNU,PNU,AM)
      CALL FILHEP(0,1,16*ISGN,NPS,NPS,0,0,PNU,AM,.TRUE.)
C
C W boson (W+ is 24)
      CALL TRALO4(KTO,PWB,PWB,AM)
C     CALL FILHEP(0,2,-24*ISGN,NPS,NPS,0,0,PWB,AM,.TRUE.)
C
C electron (e- is 11)
      CALL TRALO4(KTO,PEL,PEL,AM)
      CALL FILHEP(0,1,11*ISGN,NPS,NPS,0,0,PEL,AM,.FALSE.)
C
C anti electron neutrino (nu_e is 12)
      CALL TRALO4(KTO,PNE,PNE,AM)
      CALL FILHEP(0,1,-12*ISGN,NPS,NPS,0,0,PNE,AM,.TRUE.)
C
      RETURN
      END
      SUBROUTINE DWLUMU(KTO,ISGN,PNU,PWB,PMU,PNM)
C ----------------------------------------------------------------------
C Lorentz transformation to CMsystem and
C Updating of HEPEVT record
C
C ISGN = 1/-1 for tau-/tau+
C
C     called by : DEXAY,(DEKAY1,DEKAY2)
C ----------------------------------------------------------------------
C
      REAL  PNU(4),PWB(4),PMU(4),PNM(4)
      COMMON /TAUPOS/ NP1,NP2
C
C position of decaying particle:
      IF(KTO.EQ. 1) THEN
        NPS=NP1
      ELSE
        NPS=NP2
      ENDIF
C
C tau neutrino (nu_tau is 16)
      CALL TRALO4(KTO,PNU,PNU,AM)
      CALL FILHEP(0,1,16*ISGN,NPS,NPS,0,0,PNU,AM,.TRUE.)
C
C W boson (W+ is 24)
      CALL TRALO4(KTO,PWB,PWB,AM)
C     CALL FILHEP(0,2,-24*ISGN,NPS,NPS,0,0,PWB,AM,.TRUE.)
C
C muon (mu- is 13)
      CALL TRALO4(KTO,PMU,PMU,AM)
      CALL FILHEP(0,1,13*ISGN,NPS,NPS,0,0,PMU,AM,.FALSE.)
C
C anti muon neutrino (nu_mu is 14)
      CALL TRALO4(KTO,PNM,PNM,AM)
      CALL FILHEP(0,1,-14*ISGN,NPS,NPS,0,0,PNM,AM,.TRUE.)
C
      RETURN
      END
      SUBROUTINE DWLUPI(KTO,ISGN,PPI,PNU)
C ----------------------------------------------------------------------
C Lorentz transformation to CMsystem and
C Updating of HEPEVT record
C
C ISGN = 1/-1 for tau-/tau+
C
C     called by : DEXAY,(DEKAY1,DEKAY2)
C ----------------------------------------------------------------------
C
      REAL  PNU(4),PPI(4)
      COMMON /TAUPOS/ NP1,NP2
C
C position of decaying particle:
      IF(KTO.EQ. 1) THEN
        NPS=NP1
      ELSE
        NPS=NP2
      ENDIF
C
C tau neutrino (nu_tau is 16)
      CALL TRALO4(KTO,PNU,PNU,AM)
      CALL FILHEP(0,1,16*ISGN,NPS,NPS,0,0,PNU,AM,.TRUE.)
C
C charged pi meson (pi+ is 211)
      CALL TRALO4(KTO,PPI,PPI,AM)
      CALL FILHEP(0,1,-211*ISGN,NPS,NPS,0,0,PPI,AM,.TRUE.)
C
      RETURN
      END
      SUBROUTINE DWLURO(KTO,ISGN,PNU,PRHO,PIC,PIZ)
C ----------------------------------------------------------------------
C Lorentz transformation to CMsystem and
C Updating of HEPEVT record
C
C ISGN = 1/-1 for tau-/tau+
C
C     called by : DEXAY,(DEKAY1,DEKAY2)
C ----------------------------------------------------------------------
C
      REAL  PNU(4),PRHO(4),PIC(4),PIZ(4)
      COMMON /TAUPOS/ NP1,NP2
C
C position of decaying particle:
      IF(KTO.EQ. 1) THEN
        NPS=NP1
      ELSE
        NPS=NP2
      ENDIF
C
C tau neutrino (nu_tau is 16)
      CALL TRALO4(KTO,PNU,PNU,AM)
      CALL FILHEP(0,1,16*ISGN,NPS,NPS,0,0,PNU,AM,.TRUE.)
C
C charged rho meson (rho+ is 213)
      CALL TRALO4(KTO,PRHO,PRHO,AM)
      CALL FILHEP(0,2,-213*ISGN,NPS,NPS,0,0,PRHO,AM,.TRUE.)
C
C charged pi meson (pi+ is 211)
      CALL TRALO4(KTO,PIC,PIC,AM)
      CALL FILHEP(0,1,-211*ISGN,-1,-1,0,0,PIC,AM,.TRUE.)
C
C pi0 meson (pi0 is 111)
      CALL TRALO4(KTO,PIZ,PIZ,AM)
      CALL FILHEP(0,1,111,-2,-2,0,0,PIZ,AM,.TRUE.)
C
      RETURN
      END
      SUBROUTINE DWLUAA(KTO,ISGN,PNU,PAA,PIM1,PIM2,PIPL,JAA)
C ----------------------------------------------------------------------
C Lorentz transformation to CMsystem and
C Updating of HEPEVT record
C
C ISGN = 1/-1 for tau-/tau+
C JAA  = 1 (2) FOR A_1- DECAY TO PI+ 2PI- (PI- 2PI0)
C
C     called by : DEXAY,(DEKAY1,DEKAY2)
C ----------------------------------------------------------------------
C
      REAL  PNU(4),PAA(4),PIM1(4),PIM2(4),PIPL(4)
      COMMON /TAUPOS/ NP1,NP2
C
C position of decaying particle:
      IF(KTO.EQ. 1) THEN
        NPS=NP1
      ELSE
        NPS=NP2
      ENDIF
C
C tau neutrino (nu_tau is 16)
      CALL TRALO4(KTO,PNU,PNU,AM)
      CALL FILHEP(0,1,16*ISGN,NPS,NPS,0,0,PNU,AM,.TRUE.)
C
C charged a_1 meson (a_1+ is 20213)
      CALL TRALO4(KTO,PAA,PAA,AM)
      CALL FILHEP(0,1,-20213*ISGN,NPS,NPS,0,0,PAA,AM,.TRUE.)
C
C two possible decays of the charged a1 meson
      IF(JAA.EQ.1) THEN
C
C A1  --> PI+ PI-  PI- (or charged conjugate)
C
C pi minus (or c.c.) (pi+ is 211)
        CALL TRALO4(KTO,PIM2,PIM2,AM)
        CALL FILHEP(0,1,-211*ISGN,-1,-1,0,0,PIM2,AM,.TRUE.)
C
C pi minus (or c.c.) (pi+ is 211)
        CALL TRALO4(KTO,PIM1,PIM1,AM)
        CALL FILHEP(0,1,-211*ISGN,-2,-2,0,0,PIM1,AM,.TRUE.)
C
C pi plus (or c.c.) (pi+ is 211)
        CALL TRALO4(KTO,PIPL,PIPL,AM)
        CALL FILHEP(0,1, 211*ISGN,-3,-3,0,0,PIPL,AM,.TRUE.)
C
      ELSE IF (JAA.EQ.2) THEN
C
C A1  --> PI- PI0  PI0 (or charged conjugate)
C
C pi zero (pi0 is 111)
        CALL TRALO4(KTO,PIM2,PIM2,AM)
        CALL FILHEP(0,1,111,-1,-1,0,0,PIM2,AM,.TRUE.)
C
C pi zero (pi0 is 111)
        CALL TRALO4(KTO,PIM1,PIM1,AM)
        CALL FILHEP(0,1,111,-2,-2,0,0,PIM1,AM,.TRUE.)
C
C pi minus (or c.c.) (pi+ is 211)
        CALL TRALO4(KTO,PIPL,PIPL,AM)
        CALL FILHEP(0,1,-211*ISGN,-3,-3,0,0,PIPL,AM,.TRUE.)
C
      ENDIF
C
      RETURN
      END
      SUBROUTINE DWLUKK (KTO,ISGN,PKK,PNU)
C ----------------------------------------------------------------------
C Lorentz transformation to CMsystem and
C Updating of HEPEVT record
C
C ISGN = 1/-1 for tau-/tau+
C
C ----------------------------------------------------------------------
C
      REAL PKK(4),PNU(4)
      COMMON /TAUPOS/ NP1,NP2
C
C position of decaying particle
      IF (KTO.EQ.1) THEN
        NPS=NP1
      ELSE
        NPS=NP2
      ENDIF
C
C tau neutrino (nu_tau is 16)
      CALL TRALO4 (KTO,PNU,PNU,AM)
      CALL FILHEP(0,1,16*ISGN,NPS,NPS,0,0,PNU,AM,.TRUE.)
C
C K meson (K+ is 321)
      CALL TRALO4 (KTO,PKK,PKK,AM)
      CALL FILHEP(0,1,-321*ISGN,NPS,NPS,0,0,PKK,AM,.TRUE.)
C
      RETURN
      END
      SUBROUTINE DWLUKS(KTO,ISGN,PNU,PKS,PKK,PPI,JKST)
      COMMON / TAUKLE / BRA1,BRK0,BRK0B,BRKS
      REAL*4            BRA1,BRK0,BRK0B,BRKS
C ----------------------------------------------------------------------
C Lorentz transformation to CMsystem and
C Updating of HEPEVT record
C
C ISGN = 1/-1 for tau-/tau+
C JKST=10 (20) corresponds to K0B pi- (K- pi0) decay
C
C ----------------------------------------------------------------------
C
      REAL  PNU(4),PKS(4),PKK(4),PPI(4)
      COMMON /TAUPOS/ NP1,NP2
C
C position of decaying particle
      IF(KTO.EQ. 1) THEN
        NPS=NP1
      ELSE
        NPS=NP2
      ENDIF
C
C tau neutrino (nu_tau is 16)
      CALL TRALO4(KTO,PNU,PNU,AM)
      CALL FILHEP(0,1,16*ISGN,NPS,NPS,0,0,PNU,AM,.TRUE.)
C
C charged K* meson (K*+ is 323)
      CALL TRALO4(KTO,PKS,PKS,AM)
      CALL FILHEP(0,1,-323*ISGN,NPS,NPS,0,0,PKS,AM,.TRUE.)
C
C two possible decay modes of charged K*
      IF(JKST.EQ.10) THEN
C
C K*- --> pi- K0B (or charged conjugate)
C
C charged pi meson  (pi+ is 211)
        CALL TRALO4(KTO,PPI,PPI,AM)
        CALL FILHEP(0,1,-211*ISGN,-1,-1,0,0,PPI,AM,.TRUE.)
C
        BRAN=BRK0B
        IF (ISGN.EQ.-1) BRAN=BRK0
C K0 --> K0_long (is 130) / K0_short (is 310) = 1/1
        CALL RANMAR(XIO,1)
        IF(XIO.GT.BRAN) THEN
          K0TYPE = 130
        ELSE
          K0TYPE = 310
        ENDIF
C
        CALL TRALO4(KTO,PKK,PKK,AM)
        CALL FILHEP(0,1,K0TYPE,-2,-2,0,0,PKK,AM,.TRUE.)
C
      ELSE IF(JKST.EQ.20) THEN
C
C K*- --> pi0 K-
C
C pi zero (pi0 is 111)
        CALL TRALO4(KTO,PPI,PPI,AM)
        CALL FILHEP(0,1,111,-1,-1,0,0,PPI,AM,.TRUE.)
C
C charged K meson (K+ is 321)
        CALL TRALO4(KTO,PKK,PKK,AM)
        CALL FILHEP(0,1,-321*ISGN,-2,-2,0,0,PKK,AM,.TRUE.)
C
      ENDIF
C
      RETURN
      END
      SUBROUTINE DWLNEW(KTO,ISGN,PNU,PWB,PNPI,MODE)
C ----------------------------------------------------------------------
C Lorentz transformation to CMsystem and
C Updating of HEPEVT record
C
C ISGN = 1/-1 for tau-/tau+
C
C     called by : DEXAY,(DEKAY1,DEKAY2)
C ----------------------------------------------------------------------
C
      PARAMETER (NMODE=15,NM1=0,NM2=1,NM3=8,NM4=2,NM5=1,NM6=3)
      COMMON / DECOMP /IDFFIN(9,NMODE),MULPIK(NMODE)
     &                ,NAMES
      COMMON /TAUPOS/ NP1,NP2
      CHARACTER NAMES(NMODE)*31
      REAL  PNU(4),PWB(4),PNPI(4,9)
      REAL  PPI(4)
C
      JNPI=MODE-7
C position of decaying particle
      IF(KTO.EQ. 1) THEN
        NPS=NP1
      ELSE
        NPS=NP2
      ENDIF
C
C tau neutrino (nu_tau is 16)
      CALL TRALO4(KTO,PNU,PNU,AM)
      CALL FILHEP(0,1,16*ISGN,NPS,NPS,0,0,PNU,AM,.TRUE.)
C
C W boson (W+ is 24)
      CALL TRALO4(KTO,PWB,PWB,AM)
      CALL FILHEP(0,1,-24*ISGN,NPS,NPS,0,0,PWB,AM,.TRUE.)
C
C multi pi mode JNPI
C
C get multiplicity of mode JNPI
      ND=MULPIK(JNPI)
      DO I=1,ND
        KFPI=LUNPIK(IDFFIN(I,JNPI),-ISGN)
C for charged conjugate case, change charged pions only
C        IF(KFPI.NE.111)KFPI=KFPI*ISGN
        DO J=1,4
          PPI(J)=PNPI(J,I)
        END DO
        CALL TRALO4(KTO,PPI,PPI,AM)
        CALL FILHEP(0,1,KFPI,-I,-I,0,0,PPI,AM,.TRUE.)
      END DO
C
      RETURN
      END
      SUBROUTINE FILHEP(N,IST,ID,JMO1,JMO2,JDA1,JDA2,P4,PINV,PHFLAG)
C ----------------------------------------------------------------------
C this subroutine fills one entry into the HEPEVT common
C and updates the information for affected mother entries
C
C written by Martin W. Gruenewald (91/01/28)
C
C     called by : ZTOHEP,BTOHEP,DWLUxy
C ----------------------------------------------------------------------
C
      PARAMETER (NMXHEP=2000)
      COMMON/HEPEVT/NEVHEP,NHEP,ISTHEP(NMXHEP),IDHEP(NMXHEP),
     &JMOHEP(2,NMXHEP),JDAHEP(2,NMXHEP),PHEP(5,NMXHEP),VHEP(4,NMXHEP)
      SAVE  /HEPEVT/
      COMMON/PHOQED/QEDRAD(NMXHEP)
      LOGICAL QEDRAD
      SAVE /PHOQED/
      LOGICAL PHFLAG
C
      REAL*4  P4(4)
C
C check address mode
      IF (N.EQ.0) THEN
C
C append mode
        IHEP=NHEP+1
      ELSE IF (N.GT.0) THEN
C
C absolute position
        IHEP=N
      ELSE
C
C relative position
        IHEP=NHEP+N
      END IF
C
C check on IHEP
      IF ((IHEP.LE.0).OR.(IHEP.GT.NMXHEP)) RETURN
C
C add entry
      NHEP=IHEP
      ISTHEP(IHEP)=IST
      IDHEP(IHEP)=ID
      JMOHEP(1,IHEP)=JMO1
      IF(JMO1.LT.0)JMOHEP(1,IHEP)=JMOHEP(1,IHEP)+IHEP
      JMOHEP(2,IHEP)=JMO2
      IF(JMO2.LT.0)JMOHEP(2,IHEP)=JMOHEP(2,IHEP)+IHEP
      JDAHEP(1,IHEP)=JDA1
      JDAHEP(2,IHEP)=JDA2
C
      DO I=1,4
        PHEP(I,IHEP)=P4(I)
C
C KORAL-B and KORAL-Z do not provide vertex and/or lifetime informations
        VHEP(I,IHEP)=0.0
      END DO
      PHEP(5,IHEP)=PINV
C FLAG FOR PHOTOS...
      QEDRAD(IHEP)=PHFLAG
C
C update process:
      DO IP=JMOHEP(1,IHEP),JMOHEP(2,IHEP)
        IF(IP.GT.0)THEN
C
C if there is a daughter at IHEP, mother entry at IP has decayed
          IF(ISTHEP(IP).EQ.1)ISTHEP(IP)=2
C
C and daughter pointers of mother entry must be updated
          IF(JDAHEP(1,IP).EQ.0)THEN
            JDAHEP(1,IP)=IHEP
            JDAHEP(2,IP)=IHEP
          ELSE
            JDAHEP(2,IP)=MAX(IHEP,JDAHEP(2,IP))
          END IF
        END IF
      END DO
C
      RETURN
      END

      FUNCTION AMAST(PP)
C ----------------------------------------------------------------------
C CALCULATES MASS OF PP (DOUBLE PRECISION)
C
C     USED BY : RADKOR
C ----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      REAL*8  PP(4)
      AAA=PP(4)**2-PP(3)**2-PP(2)**2-PP(1)**2
C
      IF(AAA.NE.0.0) AAA=AAA/SQRT(ABS(AAA))
      AMAST=AAA
      RETURN
      END
      FUNCTION AMAS4(PP)
C     ******************
C ----------------------------------------------------------------------
C CALCULATES MASS OF PP
C
C     USED BY :
C ----------------------------------------------------------------------
      REAL  PP(4)
      AAA=PP(4)**2-PP(3)**2-PP(2)**2-PP(1)**2
      IF(AAA.NE.0.0) AAA=AAA/SQRT(ABS(AAA))
      AMAS4=AAA
      RETURN
      END
      FUNCTION ANGXY(X,Y)
C ----------------------------------------------------------------------
C
C     USED BY : KORALZ RADKOR
C ----------------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DATA PI /3.141592653589793238462643D0/
C
      IF(ABS(Y).LT.ABS(X)) THEN
        THE=ATAN(ABS(Y/X))
        IF(X.LE.0D0) THE=PI-THE
      ELSE
        THE=ACOS(X/SQRT(X**2+Y**2))
      ENDIF
      ANGXY=THE
      RETURN
      END
      FUNCTION ANGFI(X,Y)
C ----------------------------------------------------------------------
* CALCULATES ANGLE IN (0,2*PI) RANGE OUT OF X-Y
C
C     USED BY : KORALZ RADKOR
C ----------------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DATA PI /3.141592653589793238462643D0/
C
      IF(ABS(Y).LT.ABS(X)) THEN
        THE=ATAN(ABS(Y/X))
        IF(X.LE.0D0) THE=PI-THE
      ELSE
        THE=ACOS(X/SQRT(X**2+Y**2))
      ENDIF
      IF(Y.LT.0D0) THE=2D0*PI-THE
      ANGFI=THE
      END
      SUBROUTINE ROTOD1(PH1,PVEC,QVEC)
C ----------------------------------------------------------------------
C
C     USED BY : KORALZ
C ----------------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION PVEC(4),QVEC(4),RVEC(4)
C
      PHI=PH1
      CS=COS(PHI)
      SN=SIN(PHI)
      DO 10 I=1,4
  10  RVEC(I)=PVEC(I)
      QVEC(1)=RVEC(1)
      QVEC(2)= CS*RVEC(2)-SN*RVEC(3)
      QVEC(3)= SN*RVEC(2)+CS*RVEC(3)
      QVEC(4)=RVEC(4)
      RETURN
      END
      SUBROUTINE ROTOD2(PH1,PVEC,QVEC)
C ----------------------------------------------------------------------
C
C     USED BY : KORALZ RADKOR
C ----------------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION PVEC(4),QVEC(4),RVEC(4)
C
      PHI=PH1
      CS=COS(PHI)
      SN=SIN(PHI)
      DO 10 I=1,4
  10  RVEC(I)=PVEC(I)
      QVEC(1)= CS*RVEC(1)+SN*RVEC(3)
      QVEC(2)=RVEC(2)
      QVEC(3)=-SN*RVEC(1)+CS*RVEC(3)
      QVEC(4)=RVEC(4)
      RETURN
      END
      SUBROUTINE ROTOD3(PH1,PVEC,QVEC)
C ----------------------------------------------------------------------
C
C     USED BY : KORALZ RADKOR
C ----------------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C
      DIMENSION PVEC(4),QVEC(4),RVEC(4)
      PHI=PH1
      CS=COS(PHI)
      SN=SIN(PHI)
      DO 10 I=1,4
  10  RVEC(I)=PVEC(I)
      QVEC(1)= CS*RVEC(1)-SN*RVEC(2)
      QVEC(2)= SN*RVEC(1)+CS*RVEC(2)
      QVEC(3)=RVEC(3)
      QVEC(4)=RVEC(4)
      END
      SUBROUTINE BOSTR3(EXE,PVEC,QVEC)
C ----------------------------------------------------------------------
C BOOST ALONG Z AXIS, EXE=EXP(ETA), ETA= HIPERBOLIC VELOCITY.
C
C     USED BY : TAUOLA KORALZ (?)
C ----------------------------------------------------------------------
      REAL*4 PVEC(4),QVEC(4),RVEC(4)
C
      DO 10 I=1,4
  10  RVEC(I)=PVEC(I)
      RPL=RVEC(4)+RVEC(3)
      RMI=RVEC(4)-RVEC(3)
      QPL=RPL*EXE
      QMI=RMI/EXE
      QVEC(1)=RVEC(1)
      QVEC(2)=RVEC(2)
      QVEC(3)=(QPL-QMI)/2
      QVEC(4)=(QPL+QMI)/2
      END
      SUBROUTINE BOSTD3(EXE,PVEC,QVEC)
C ----------------------------------------------------------------------
C BOOST ALONG Z AXIS, EXE=EXP(ETA), ETA= HIPERBOLIC VELOCITY.
C
C     USED BY : KORALZ RADKOR
C ----------------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION PVEC(4),QVEC(4),RVEC(4)
C
      DO 10 I=1,4
  10  RVEC(I)=PVEC(I)
      RPL=RVEC(4)+RVEC(3)
      RMI=RVEC(4)-RVEC(3)
      QPL=RPL*EXE
      QMI=RMI/EXE
      QVEC(1)=RVEC(1)
      QVEC(2)=RVEC(2)
      QVEC(3)=(QPL-QMI)/2
      QVEC(4)=(QPL+QMI)/2
      RETURN
      END
      SUBROUTINE ROTOR1(PH1,PVEC,QVEC)
C ----------------------------------------------------------------------
C
C     called by :
C ----------------------------------------------------------------------
      REAL*4 PVEC(4),QVEC(4),RVEC(4)
C
      PHI=PH1
      CS=COS(PHI)
      SN=SIN(PHI)
      DO 10 I=1,4
  10  RVEC(I)=PVEC(I)
      QVEC(1)=RVEC(1)
      QVEC(2)= CS*RVEC(2)-SN*RVEC(3)
      QVEC(3)= SN*RVEC(2)+CS*RVEC(3)
      QVEC(4)=RVEC(4)
      END
      SUBROUTINE ROTOR2(PH1,PVEC,QVEC)
C ----------------------------------------------------------------------
C
C     USED BY : TAUOLA
C ----------------------------------------------------------------------
      IMPLICIT REAL*4(A-H,O-Z)
      REAL*4 PVEC(4),QVEC(4),RVEC(4)
C
      PHI=PH1
      CS=COS(PHI)
      SN=SIN(PHI)
      DO 10 I=1,4
  10  RVEC(I)=PVEC(I)
      QVEC(1)= CS*RVEC(1)+SN*RVEC(3)
      QVEC(2)=RVEC(2)
      QVEC(3)=-SN*RVEC(1)+CS*RVEC(3)
      QVEC(4)=RVEC(4)
      END
      SUBROUTINE ROTOR3(PHI,PVEC,QVEC)
C ----------------------------------------------------------------------
C
C     USED BY : TAUOLA
C ----------------------------------------------------------------------
      REAL*4 PVEC(4),QVEC(4),RVEC(4)
C
      CS=COS(PHI)
      SN=SIN(PHI)
      DO 10 I=1,4
  10  RVEC(I)=PVEC(I)
      QVEC(1)= CS*RVEC(1)-SN*RVEC(2)
      QVEC(2)= SN*RVEC(1)+CS*RVEC(2)
      QVEC(3)=RVEC(3)
      QVEC(4)=RVEC(4)
      END
      SUBROUTINE SPHERD(R,X)
C ----------------------------------------------------------------------
C GENERATES UNIFORMLY THREE-VECTOR X ON SPHERE  OF RADIUS R
C DOUBLE PRECISON VERSION OF SPHERA
C ----------------------------------------------------------------------
      REAL*8  R,X(4),PI,COSTH,SINTH
      REAL*4 RRR(2)
      DATA PI /3.141592653589793238462643D0/
C
      CALL RANMAR(RRR,2)
      COSTH=-1+2*RRR(1)
      SINTH=SQRT(1 -COSTH**2)
      X(1)=R*SINTH*COS(2*PI*RRR(2))
      X(2)=R*SINTH*SIN(2*PI*RRR(2))
      X(3)=R*COSTH
      RETURN
      END
      SUBROUTINE ROTPOX(THET,PHI,PP)
      IMPLICIT REAL*8 (A-H,O-Z)
C ----------------------------------------------------------------------
C
C ----------------------------------------------------------------------
      DIMENSION PP(4)
C
      CALL ROTOD2(THET,PP,PP)
      CALL ROTOD3( PHI,PP,PP)
      RETURN
      END
      SUBROUTINE SPHERA(R,X)
C ----------------------------------------------------------------------
C GENERATES UNIFORMLY THREE-VECTOR X ON SPHERE  OF RADIUS R
C
C     called by : DPHSxx,DADMPI,DADMKK
C ----------------------------------------------------------------------
      REAL  X(4)
      REAL*4 RRR(2)
      DATA PI /3.141592653589793238462643/
C
      CALL RANMAR(RRR,2)
      COSTH=-1.+2.*RRR(1)
      SINTH=SQRT(1.-COSTH**2)
      X(1)=R*SINTH*COS(2*PI*RRR(2))
      X(2)=R*SINTH*SIN(2*PI*RRR(2))
      X(3)=R*COSTH
      RETURN
      END
      SUBROUTINE ROTPOL(THET,PHI,PP)
C ----------------------------------------------------------------------
C
C     called by : DADMAA,DPHSAA
C ----------------------------------------------------------------------
      REAL  PP(4)
C
      CALL ROTOR2(THET,PP,PP)
      CALL ROTOR3( PHI,PP,PP)
      RETURN
      END
      SUBROUTINE WANMAR(RVEC,LENV)
C ----------------------------------------------------------------------
C<<<<<FUNCTION RANMAR(IDUMM)
C CERNLIB V113, VERSION WITH AUTOMATIC DEFAULT INITIALIZATION
C     Transformed to SUBROUTINE to be as in CERNLIB
C     AM.Lutz   November 1988, Feb. 1989
C
C!Universal random number generator proposed by Marsaglia and Zaman
C in report FSU-SCRI-87-50
C        modified by F. James, 1988 and 1989, to generate a vector
C        of pseudorandom numbers RVEC of length LENV, and to put in
C        the COMMON block everything needed to specify currrent state,
C        and to add input and output entry points RMARIN, RMARUT.
C
C     Unique random number used in the program
C ----------------------------------------------------------------------
      COMMON / INOUT / INUT,IOUT
      DIMENSION RVEC(*)
      COMMON/RASET1/U(97),C,I97,J97
      PARAMETER (MODCNS=1000000000)
      DATA NTOT,NTOT2,IJKL/-1,0,0/
C
      IF (NTOT .GE. 0)  GO TO 50
C
C        Default initialization. User has called RANMAR without RMARIN.
      IJKL = 54217137
      NTOT = 0
      NTOT2 = 0
      KALLED = 0
      GO TO 1
C
      ENTRY      RMARIN(IJKLIN, NTOTIN,NTOT2N)
C         Initializing routine for RANMAR, may be called before
C         generating pseudorandom numbers with RANMAR. The input
C         values should be in the ranges:  0<=IJKLIN<=900 OOO OOO
C                                          0<=NTOTIN<=999 999 999
C                                          0<=NTOT2N<<999 999 999!
C To get the standard values in Marsaglia's paper, IJKLIN=54217137
C                                            NTOTIN,NTOT2N=0
      IJKL = IJKLIN
      NTOT = MAX(NTOTIN,0)
      NTOT2= MAX(NTOT2N,0)
      KALLED = 1
C          always come here to initialize
    1 CONTINUE
      IJ = IJKL/30082
      KL = IJKL - 30082*IJ
      I = MOD(IJ/177, 177) + 2
      J = MOD(IJ, 177)     + 2
      K = MOD(KL/169, 178) + 1
      L = MOD(KL, 169)
      WRITE(IOUT,201) IJKL,NTOT,NTOT2
 201  FORMAT(1X,' RANMAR INITIALIZED: ',I10,2X,2I10)
      DO 2 II= 1, 97
      S = 0.
      T = .5
      DO 3 JJ= 1, 24
         M = MOD(MOD(I*J,179)*K, 179)
         I = J
         J = K
         K = M
         L = MOD(53*L+1, 169)
         IF (MOD(L*M,64) .GE. 32)  S = S+T
    3    T = 0.5*T
    2 U(II) = S
      TWOM24 = 1.0
      DO 4 I24= 1, 24
    4 TWOM24 = 0.5*TWOM24
      C  =   362436.*TWOM24
      CD =  7654321.*TWOM24
      CM = 16777213.*TWOM24
      I97 = 97
      J97 = 33
C       Complete initialization by skipping
C            (NTOT2*MODCNS + NTOT) random numbers
      DO 45 LOOP2= 1, NTOT2+1
      NOW = MODCNS
      IF (LOOP2 .EQ. NTOT2+1)  NOW=NTOT
      IF (NOW .GT. 0)  THEN
       WRITE (IOUT,'(A,I15)') ' RMARIN SKIPPING OVER ',NOW
       DO 40 IDUM = 1, NTOT
       UNI = U(I97)-U(J97)
       IF (UNI .LT. 0.)  UNI=UNI+1.
       U(I97) = UNI
       I97 = I97-1
       IF (I97 .EQ. 0)  I97=97
       J97 = J97-1
       IF (J97 .EQ. 0)  J97=97
       C = C - CD
       IF (C .LT. 0.)  C=C+CM
   40  CONTINUE
      ENDIF
   45 CONTINUE
      IF (KALLED .EQ. 1)  RETURN
C
C          Normal entry to generate LENV random numbers
   50 CONTINUE
      DO 100 IVEC= 1, LENV
      UNI = U(I97)-U(J97)
      IF (UNI .LT. 0.)  UNI=UNI+1.
      U(I97) = UNI
      I97 = I97-1
      IF (I97 .EQ. 0)  I97=97
      J97 = J97-1
      IF (J97 .EQ. 0)  J97=97
      C = C - CD
      IF (C .LT. 0.)  C=C+CM
      UNI = UNI-C
      IF (UNI .LT. 0.) UNI=UNI+1.
C        Replace exact zeroes by uniform distr. *2**-24
         IF (UNI .EQ. 0.)  THEN
         UNI = TWOM24*U(2)
C             An exact zero here is very unlikely, but let's be safe.
         IF (UNI .EQ. 0.) UNI= TWOM24*TWOM24
         ENDIF
      RVEC(IVEC) = UNI
  100 CONTINUE
      NTOT = NTOT + LENV
         IF (NTOT .GE. MODCNS)  THEN
         NTOT2 = NTOT2 + 1
         NTOT = NTOT - MODCNS
         ENDIF
      RETURN
C           Entry to output current status
      ENTRY RMARUT(IJKLUT,NTOTUT,NTOT2T)
      IJKLUT = IJKL
      NTOTUT = NTOT
      NTOT2T = NTOT2
      RETURN
      END
      FUNCTION DILOGT(X)
C     *****************
      IMPLICIT REAL*8(A-H,O-Z)
CERN      C304      VERSION    29/07/71 DILOG        59                C
      Z=-1.64493406684822
      IF(X .LT.-1.0) GO TO 1
      IF(X .LE. 0.5) GO TO 2
      IF(X .EQ. 1.0) GO TO 3
      IF(X .LE. 2.0) GO TO 4
      Z=3.2898681336964
    1 T=1.0/X
      S=-0.5
      Z=Z-0.5* LOG(ABS(X))**2
      GO TO 5
    2 T=X
      S=0.5
      Z=0.
      GO TO 5
    3 DILOGT=1.64493406684822
      RETURN
    4 T=1.0-X
      S=-0.5
      Z=1.64493406684822 - LOG(X)* LOG(ABS(T))
    5 Y=2.66666666666666 *T+0.66666666666666
      B=      0.00000 00000 00001
      A=Y*B  +0.00000 00000 00004
      B=Y*A-B+0.00000 00000 00011
      A=Y*B-A+0.00000 00000 00037
      B=Y*A-B+0.00000 00000 00121
      A=Y*B-A+0.00000 00000 00398
      B=Y*A-B+0.00000 00000 01312
      A=Y*B-A+0.00000 00000 04342
      B=Y*A-B+0.00000 00000 14437
      A=Y*B-A+0.00000 00000 48274
      B=Y*A-B+0.00000 00001 62421
      A=Y*B-A+0.00000 00005 50291
      B=Y*A-B+0.00000 00018 79117
      A=Y*B-A+0.00000 00064 74338
      B=Y*A-B+0.00000 00225 36705
      A=Y*B-A+0.00000 00793 87055
      B=Y*A-B+0.00000 02835 75385
      A=Y*B-A+0.00000 10299 04264
      B=Y*A-B+0.00000 38163 29463
      A=Y*B-A+0.00001 44963 00557
      B=Y*A-B+0.00005 68178 22718
      A=Y*B-A+0.00023 20021 96094
      B=Y*A-B+0.00100 16274 96164
      A=Y*B-A+0.00468 63619 59447
      B=Y*A-B+0.02487 93229 24228
      A=Y*B-A+0.16607 30329 27855
      A=Y*A-B+1.93506 43008 6996
      DILOGT=S*T*(A-B)+Z
      RETURN
C=======================================================================
C===================END OF CPC PART ====================================
C=======================================================================
      END
C=============================================================
C=============================================================
C==== end of directory ===== =================================
C=============================================================
C=============================================================

C======================================================================
C======================= G L I B K  ===================================
C==================General Library of utilities========================
C===========It is imilar but not identical to HBOOK and HPLOT==========
C======================================================================
C
C                      Version:    1.04
C              Last correction:    March 1992
C
C
C  Installation remarks:
C  (1) printing backslash character depends on F77 compilator,
C      user may need to modify definition of BS variable in HPLCAP
C
C  Usage of the program:
C  (1) In most cases names and meanings of programs and their
C      parameters is the same as in original CERN libraries HBOOK
C  (2) Unlike to original HBOOK and HPLOT, all floating parameters
C      of the programs are in double precision!
C  (3) GLIBK stores histograms in double precision and always with
C      errors. REAL*8 storage is essential for 10**7 events statistics!
C  (4) Output from GLIBK is a picture recorded as regular a LaTeX file
C      with frame and curves/histograms, it is easy to change fonts
C      add captions, merge plots, etc. by normal ediding. Finally,
C      picture may be inserted in any place into LaTeX source of the
C      article.
C
C  ********************************************************************
C  *  History of the program:                                         *
C  *  MINI-HBOOK writen by S. Jadach, Rutherford Lab. 1976            *
C  *  Rewritten December 1989 (S.J.)                                  *
C  *  Version with DOUBLE PRECISION ARGUMENTS ONLY!                   *
C  *  Subrogram names start with G instead of H letter!               *
C  *  Entries:   Obligatory:  GLIMIT                                  *
C  *             Optional: see table below                            *
C  *  non-user subprograms in brackets                                *
C  ********************************************************************
C    SUBR/FUNC  1 PAR. 2 PAR. 3 PAR. 4 PAR. 5 PAR. 6 PAR.
C  ====================================================================
*     (GINIT)   ----   ----    ----   ----   ----   ----
*      GI       INT    INT     ----   ----   ----   ----
*      GIE      INT    INT     ----   ----   ----   ----
*      GF1      INT    DBL     DBL    ----   ----   ----
*      GFILL    INT    DBL     DBL    DBL    ----   ----
*      GBOOK1   INT    CHR*80  INT    DBL    DBL    ----
*     (GOPTOU)  INT    INT     INT    INT    INT     INT
* (L.F. GEXIST) INT    -----  ------  ----   ----   ----
*      GIDOPT   INT    CHR*4   -----  ----   ----   ----
*      GBFUN1   INT    CHR*80   INT   DBL    DBL  DP-FUNC
*      GIDOPT   INT    CHR*4   -----  ----   ----   ----
*      GBOOK2   INT    CHR*80   INT   DBL    DBL     INT   DBL   DBL
*      GISTDO     ---   ----   ----   ----   ----   ----
*      GOUTPU   INT     ----   ----   ----   ----   ----
*      GPRINT   INT     ----   ----   ----   ----   ----
*      GOPERA   INT    CHR*1   INT    INT    DBL    DBL
*      GINBO1   INT    CHR*8   INT    DBL    DBL    ----
*      GUNPAK   INT    DBL(*) CHR*(*) INT    ---    ----
*      GPAK     INT    DBL(*)  ----   ----   ---    ----
*      GPAKE    INT    DBL(*)  ----   ----   ---    ----
*      GRANG1   INT    DBL     DBL    ----   ---    ----
*      GINBO2   INT    INT     DBL    DBL    INT    DBL   DBL
*      GMAXIM   INT    DBL     ----   ----   ---    ----
*      GMINIM   INT    DBL     ----   ----   ---    ----
*      GRESET   INT   CHR*(*)  ----   ----   ---    ----
*      GDELET   INT     ----   ----   ----   ----   ----
*      GLIMIT   INT     ----   ----   ----   ----   ----
*     (COPCH)   CHR*80 CHR*80  ----   ----   ----   ----
* (F. JADRES)   INT     ----   ----   ----   ----   ----
*      GRFILE   INT   CHR*(*) CHR*(*) ----   ----   ----
*      GROUT    INT    INT    CHR*8   ----   ----   ----
*      GRIN     INT    INT     INT    ----   ----   ----
*      GREND   CHR*(*) ----    ----   ----   ----   ----
C  *******************  HPLOT entries ******************
*      GPLINT   INT    ----    ----   ----   ----   ----
*      GPLCAP   INT    ----    ----   ----   ----   ----
*      GPLEND   ----   ----    ----   ----   ----   ----
*      GPLOT    INT    CHR*1   CHR*1   INT   ----   ----
*     (LFRAM1)  INT      INT     INT  ----   ----   ----
*     (SAXIX)   INT      DBL     DBL   INT    DBL   ----
*     (SAXIY)   INT      DBL     DBL   INT    DBL   ----
*     (PLHIST)  INT      INT     DBL   DBL    INT    INT
*     (PLHIS2)  INT      INT     DBL   DBL    INT    INT
*     (PLCIRC)  INT      INT     INT   DBL    DBL    DBL
*     (APROF)   DBL      INT     DBL  ----   ----   ----
*      GPLSET   INT      DBL    ----  ----   ----   ----
*      GPLTIT   INT    CHR*80   ----  ----   ----   ----
C  *******************  WMONIT entries ******************
*      GMONIT   INT ???
C  *******************************************************************
C                         END OF TABLE
C  *******************************************************************
*          Map of memory for single histogram
*          ----------------------------------
*  (1-7) Header
*  ist +1   mark      9999999999999
*  ist +2   mark      9d12 + id*10 + 9
*  ist +3   iflag1    9d12 + iflag1*10 +9
*  ist +4   iflag2    9d12 + iflag2*10 +9
*  ist +5   scamin    minimum y-scale
*  ist +6   scamax    maximum y-scale
*  ist +7   reserve   9999999999999
*  One dimensional histogram            Two dimensional histog.
*  -------------------------            ----------------------
*  (8-11) Binning information           (8-15) Binning information
*  ist2 +1    NCHX                          ist2 +5   NCHY
*  ist2 +2      XL                          ist2 +6     YL
*  ist2 +3      XU                          ist2 +7     YU
*  ist2 +4   FACTX                          ist2 +8  FACTY
*
*  (12-24) Under/over-flow average x    (16-24)
*  ist3 +1   Underflow                     All nine combinations
*  ist3 +2   Normal                        (U,N,O) x (U,N,O)
*  ist3 +3   Overerflow                    sum wt only (no errors)
*  ist3 +4   U  sum w**2
*  ist3 +5   N  sum w**2
*  ist3 +6   O  sum w**2
*  ist3 +7   Sum 1
*  ist3 +8   Sum wt*x
*  ist3 +9   Sum wt*x*x
*  ist3 +10  nevzer    (gmonit)
*  ist3 +11  nevove    (gmonit)
*  ist3 +12  nevacc    (gmonit)
*  ist3 +13  maxwt     (gmonit)
*  -----------------------Bin content
*  (25 to 24+2*nchx)                     (25 to 24 +nchx*nchy)
*     sum wt and sum wt**2            sum wt only (no errors)
*  ----------------------------------------------------------------
      subroutine ginit
*     ****************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      character*80 titlc
      data init/0/
*
      if(init.ne.0) return
      init=1
c this is version version number
      nvrs=104
c default output unit
      nout=16
      lenmax=0
      length=0
      do 100 i=1,idmx
      do 40 k=1,3
   40 index(i,k)=0
      do 50 k=1,80
   50 titlc(i)(k:k)=' '
  100 continue
      end

      function gi(id,ib)
*     ******************
C getting out bin content
C S.J. 18-Nov. 90
*     ***********************************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      common / cglib / b(20000)
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      character*80 titlc
      save ist,nch
      data idmem / -1256765/
c
      if(id.eq.idmem) goto 100
      idmem=id
c some checks, not repeated if id the same as previously
      lact=jadres(id)
      if(lact.eq.0) then
        write(nout,*) ' gi: nonexisting histo id=',id
        gi= 0d0
        return
      endif
      ist  = index(lact,2)
      ist2 = ist+7
      ist3 = ist+11
c checking if histo is of proper type
      iflag2   = nint(b(ist+4)-9d0-9d12)/10
      ityphi   = mod(iflag2,10)
      if(ityphi.ne.1) then
        write(nout,*) ' gi: 1-dim histos only !!! id=',id
        gi= 0d0
        return
      endif
  100 continue
      nch  = nint(b(ist2+1))
      if(ib.eq.0) then
c underflow
         gi=   b(ist3 +1)
      elseif(ib.ge.1.and.ib.le.nch) then
c normal bin
         gi=   b(ist +nbuf+ib)
      elseif(ib.eq.nch+1) then
c overflow
         gi=   b(ist3 +3)
      else
c abnormal exit
         write(nout,*) ' gi: wrong binning id,ib=',id,ib
         gi=0d0
         return
      endif
      end

      function  gie(id,ib)
*     ********************
c getting out error of the bin
c s.j. 18-nov. 90
*     ***********************************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      common / cglib / b(20000)
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      character*80 titlc
      save ist,nch
      data idmem / -1256765/
c
      if(id.eq.idmem) goto 100
      idmem=id
c some checks, not repeated if id the same as previously
      lact=jadres(id)
      if(lact.eq.0) then
        write(nout,*) ' gie: nonexisting histo id=',id
        gie= 0d0
        return
      endif
      ist  = index(lact,2)
      ist2 = ist+7
      ist3 = ist+11
c checking if histo is of proper type
      iflag2   = nint(b(ist+4)-9d0-9d12)/10
      ityphi   = mod(iflag2,10)
      if(ityphi.ne.1) then
        write(nout,*) ' gie: 1-dim histos only !!! id=',id
        gie= 0d0
        return
      endif
  100 continue
      nch  = b(ist2+1)
      if(ib.eq.0) then
c underflow
         gie=   dsqrt( dabs(b(ist3 +4)))
      elseif(ib.ge.1.and.ib.le.nch) then
c...normal bin, error content
         gie=   dsqrt( dabs(b(ist+nbuf+nch+ib)) )
      elseif(ib.eq.nch+1) then
c overflow
         gie=   dsqrt( dabs(b(ist3 +6)))
      else
c abnormal exit
         write(nout,*) ' gie: wrong binning id, ib=',id,ib
         gie=0d0
         return
      endif
      end

      subroutine gf1(id,x,wtw)
*     ************************
c recommended fast filling 1-dim. histogram
c s.j. 18 nov. 90
*     ***********************************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      common / cglib / b(20000)
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      character*80 titlc
c
      lact=jadres(id)
c exit for non-existig histo
      if(lact.eq.0)  return
      ist  = index(lact,2)
      ist2 = ist+7
      ist3 = ist+11
c one-dim. histo only
      iflag2   = nint(b(ist+4)-9d0-9d12)/10
      ityphi   = mod(iflag2,10)
      if(ityphi.ne.1) return
      xx= x
CBB      yy= y
      wt= wtw
      index(lact,3)=index(lact,3)+1
c for average x
      b(ist3 +7)  =b(ist3 +7)   +1
      b(ist3 +8)  =b(ist3 +8)  +wt*xx
      b(ist3 +9)  =b(ist3 +9)  +wt*xx*xx
c filling bins
      nchx  =b(ist2 +1)
      xl    =b(ist2 +2)
      factx =b(ist2 +4)
      kx = (xx-xl)*factx+1d0
      if(kx.lt.1) then
c underflow
         b(ist3 +1)    = b(ist3 +1)         +wt
         b(ist3 +4)    = b(ist3 +4)         +wt*wt
      elseif(kx.gt.nchx) then
c overflow
         b(ist3 +3)    = b(ist3 +3)         +wt
         b(ist3 +6)    = b(ist3 +6)         +wt*wt
      else
c normal bin
         b(ist3 +2)    = b(ist3 +2)         +wt
         b(ist +nbuf+kx) = b(ist+nbuf+kx)   +wt
c error bin
         b(ist3 +5)    = b(ist3 +5)         +wt*wt
         b(ist +nbuf+nchx+kx) = b(ist+nbuf+nchx+kx)   +wt**2
      endif
      end

      subroutine gfill(id,x,y,wtw)
*     ****************************
c this routine not finished, 1-dim only!
*     ***********************************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      common / cglib / b(20000)
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      character*80 titlc
c
      lact=jadres(id)
      if(lact.eq.0)  return
      ist  = index(lact,2)
c one-dim. histo
      iflag2   = nint(b(ist+4)-9d0-9d12)/10
      ityphi   = mod(iflag2,10)
      if(ityphi.eq.1) then
c...one-dim. histogram
        call gf1(id,x,wtw)
        return
      endif
c...two-dim. scattergram, no errors!
      ist2 = ist+7
      ist3 = ist+15
      xx= x
      yy= y
      wt= wtw
      index(lact,3)=index(lact,3)+1
c x-axis
      nchx  =b(ist2 +1)
      xl    =b(ist2 +2)
      factx =b(ist2 +4)
      kx=(xx-xl)*factx+1d0
      lx=2
      if(kx.lt.1)     lx=1
      if(kx.gt.nchx)  lx=3
      l     = ist+34  +lx
      b(l)  = b(l)    +wt
      k     = ist+nbuf2  +kx
      if(lx.eq.2) b(k)  =b(k)  +wt
      k2    = ist+nbuf2  +nchx+kx
      if(lx.eq.2) b(k2) =b(k2) +wt**2
c y-axix
      nchy  =b(ist2 +5)
      yl    =b(ist2 +6)
      facty =b(ist2 +8)
      ky=(yy-yl)*facty+1d0
      ly=2
      if(ky.lt.1)    ly=1
      if(ky.gt.nchy) ly=3
c under/over-flow
      l = ist3  +lx +3*(ly-1)
      b(l) =b(l)+wt
c regular bin
      k = ist+nbuf2 +kx +nchx*(ky-1)
      if(lx.eq.2.and.ly.eq.2) b(k)=b(k)+wt
      end

      subroutine gbook1(id,title,nnchx,xxl,xxu)
*     *****************************************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      common / cglib / b(20000)
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      character*80 titlc
      character*80 title
      logical gexist
c
      call ginit
      if(gexist(id)) goto 900
      ist=length
      lact=jadres(0)
c the case of no free entry in the index
      if(lact.eq.0) goto 901
      index(lact,1)=id
      index(lact,2)=length
      index(lact,3)=0
c -------
      call copch(title,titlc(lact))
      nchx =nnchx
      xl   =xxl
      xu   =xxu
c ---------- title and bin content ----------
      lengt2 = length +2*nchx +nbuf+1
      if(lengt2.ge.lenmax) goto 902
      do 10 j=length+1,lengt2+1
  10  b(j) = 0d0
      length=lengt2
c... default flags
      ioplog   = 1
      iopsla   = 1
      ioperb   = 1
      iopsc1   = 1
      iopsc2   = 1
      iflag1   =
     $ ioplog+10*iopsla+100*ioperb+1000*iopsc1+10000*iopsc2
      ityphi   = 1
      iflag2   = ityphi
C examples of decoding flags
c      iflag1   = nint(b(ist+3)-9d0-9d12)/10
c      ioplog = mod(iflag1,10)
c      iopsla = mod(iflag1,100)/10
c      ioperb = mod(iflag1,1000)/100
c      iopsc1 = mod(iflag1,10000)/1000
c      iopsc2 = mod(iflag1,100000)/10000
c      iflag2   = nint(b(ist+4)-9d0-9d12)/10
c      ityphi = mod(iflag2,10)
c--------- buffer -----------------
c header
      b(ist +1)  = 9999999999999d0
      b(ist +2)  = 9d12 +id*10 +9d0
      b(ist +3)  = 9d12 + iflag1*10 +9d0
      b(ist +4)  = 9d12 + iflag2*10 +9d0
c dummy vertical scale
      b(ist +5)  =  -100d0
      b(ist +6)  =   100d0
c reserve
      b(ist +7)  = 9999999999999d0
c information on binning
      ist2       = ist+7
      b(ist2 +1) = nchx
      b(ist2 +2) = xl
      b(ist2 +3) = xu
      ddx = xu-xl
      if(ddx.eq.0d0) goto 903
      b(ist2 +4) = float(nchx)/ddx
c under/over-flow etc.
      ist3       = ist+11
      do 100  j=1,13
 100  b(ist3 +j)=0d0
c
      return
 900  write(nout,*) ' gbook1: histo already exists!!!! id=',id
      return
 901  write(nout,*) ' gbook1: to many histos !!!!!, id=',id
      stop
 902  write(nout,*) ' gbook1: to litle storage!!!!, lenmax=',lenmax
      stop
 903  write(nout,*) ' gbook1: xl=xu, id=',id
      stop
      end

      logical function gexist(id)
c     ***************************
c this function is true when id  exists !!!!
c     ***************************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      common / cglib / b(20000)
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      character*80 titlc
c
      lact=jadres(id)
      gexist = lact.ne.0
      end

      subroutine goptou(id,ioplog,iopsla,ioperb,iopsc1,iopsc2)
c     ********************************************************
c decoding option flags
c     **********************************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      common / cglib / b(20000)
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      character*80 titlc

      lact=jadres(id)
      if(lact.eq.0) return
      ist=index(lact,2)
c decoding flags
      iflag1   = nint(b(ist+3)-9d0-9d12)/10
      ioplog = mod(iflag1,10)
      iopsla = mod(iflag1,100)/10
      ioperb = mod(iflag1,1000)/100
      iopsc1 = mod(iflag1,10000)/1000
      iopsc2 = mod(iflag1,100000)/10000
      end

      subroutine gidopt(id,ch)
c     ************************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      common / cglib / b(20000)
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      character*80 titlc
      character*4 ch
c
      lact=jadres(id)
      if(lact.eq.0) return
      ist=index(lact,2)
C decoding flags
      call goptou(id,ioplog,iopsla,ioperb,iopsc1,iopsc2)
      if(ch.eq.      'LOGY'  ) then
c log scale for print
        ioplog = 2
      elseif(ch.eq.  'ERRO'  ) then
C errors in printing/plotting
       ioperb  = 2
      elseif(ch.eq.  'SLAN'  ) then
c slanted line in plotting
       iopsla  = 2
      elseif(ch.eq.  'YMIN'  ) then
       iopsc1  = 2
      elseif(ch.eq.  'YMAX'  ) then
       iopsc2  = 2
      ENDIF
c encoding back
      iflag1   =
     $ ioplog+10*iopsla+100*ioperb+1000*iopsc1+10000*iopsc2
      b(ist+3) = 9d12 + iflag1*10 +9d0
      end

      subroutine gbfun1(id,title,nchx,xmin,xmax,func)
c     ***********************************************
c ...fills histogram with function func(x)
c     ***********************************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      character*80 titlc
      dimension yy(200)
      external func
      character*80 title
      logical gexist
c
      call ginit
      if(gexist(id)) goto 900
 15   xl=xmin
      xu=xmax
      call gbook1(id,title,nchx,xl,xu)
c...slanted line in plotting
      call gidopt(id,'SLAN')
      if(nchx.gt.200) goto 901
      do 20 ib=1,nchx
      x= xmin +(xmax-xmin)/nchx*(ib-0.5d0)
      yy(ib) = func(x)
   20 continue
      call gpak(id,yy)
      return
 900  write(nout,*) ' +++gbfun1: already exists id=',id
      write(6   ,*) ' +++gbfun1: already exists id=',id
      call gdelet(id)
      go to 15
 901  write(nout,*) ' +++gbfun1: to many bins'
      end

      SUBROUTINE GBOOK2(ID,TITLE,NCHX,XL,XU,NCHY,YL,YU)
*     *************************************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER( IDMX=400,NBUF=24,NBUF2=24)
      COMMON / Cglib / B(20000)
      COMMON /GIND/ NVRS,NOUT,LENMAX,LENGTH,INDEX(IDMX,3),TITLC(IDMX)
      CHARACTER*80 TITLC
      CHARACTER*80 TITLE
      LOGICAL GEXIST
c
      CALL GINIT
      IF(GEXIST(ID)) GOTO 900
      ist=length
      LACT=JADRES(0)
      IF(LACT.EQ.0) GOTO 901
      index(LACT,1)=ID
      index(LACT,2)=length
      CALL COPCH(TITLE,TITLC(LACT))
      nnchx=NCHX
      nnchy=NCHY
      LENGT2 = LENGTH  +44+nnchx*nnchy
      IF(LENGT2.GE.LENMAX) GOTO 902
      DO 10 J=LENGTH+1,LENGT2+1
   10 B(J) = 0D0
      LENGTH=LENGT2
      B(ist+1)=nnchx
      B(ist+2)=XL
      B(ist+3)=XU
      B(ist+4)=float(nnchx)/(b(ist+3)-b(ist+2))
      B(ist+5)=nnchy
      B(ist+6)=YL
      B(ist+7)=YU
      B(ist+8)=float(nnchy)/(b(ist+7)-b(ist+6))
      RETURN
  900 WRITE(NOUT,*) ' GBOOK1: HISTO ALREADY EXISTS!!!! ID=',ID
      RETURN
  901 WRITE(NOUT,*) ' GBOOK1: TO MANY HISTOS !!!!!',LACT
      STOP
  902 WRITE(NOUT,*) ' GBOOK1: TO LITLE STORAGE!!!!',LENMAX
      STOP
      END

      subroutine gistdo
*     *****************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      character*80 titlc
      do 10 i=1,idmx
      id=index(i,1)
      if(id.gt.0) call gprint(id)
   10 continue
      end

      subroutine goutpu(ilun)
*     ***********************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      character*80 titlc
      call ginit
      nout=ilun
      end


      subroutine gprint(id)
*     *********************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      common / cglib / b(20000)
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      character*80 titlc
      character*1 line(105),lchr(22),lb,lx,li,l0
      data lb,lx,li,l0 /' ','X','I','0'/
      data lchr/' ','1','2','3','4','5','6','7','8','9',
     $      'A','B','C','D','E','F','G','H','I','J','K','*'/
      logical llg

      lact=jadres(id)
      if(lact.eq.0) goto 900
      ist  = index(lact,2)
      ist2 = ist+7
      ist3 = ist+11

      call goptou(id,ioplog,iopsla,ioperb,iopsc1,iopsc2)
      ker    =  ioperb-1
      lmx = 57
      if(ker.eq.1) lmx=44
      nent=index(lact,3)
      if(nent.eq.0) goto 901
      write(nout,1000) id,titlc(lact)
 1000 FORMAT('1',/,1X,I6,10X,A)
c
c one-dim. histo
      iflag2   = nint(b(ist+4)-9d0-9d12)/10
      ityphi   = mod(iflag2,10)
      if(ityphi.ne.1) goto 200
      nchx =   b(ist2 +1)
      xl   =   b(ist2 +2)
      dx   =  (  b(ist2 +3)-b(ist2 +2)  )/float(nchx)
c fixing vertical scale
      istr=ist+nbuf+1
      bmax = b(istr)
      bmin = b(istr)
      do 15 ibn=istr,istr+nchx-1
      bmax = max(bmax,b(ibn))
      bmin = min(bmin,b(ibn))
  15  continue
      if(bmin.eq.bmax) goto 901
      if(iopsc1.eq.2) bmin=b(ist +5)
      if(iopsc2.eq.2) bmax=b(ist +6)
c
      llg=ioplog.eq.2
      if(llg.and.bmin.le.0d0) bmin=bmax/10000.d0
c
      deltb = bmax-bmin
      if(deltb.eq.0d0) goto 902
      fact  = (lmx-1)/deltb
      kzer  = -bmin*fact+1.00001d0
      if(llg) fact=(lmx-1)/(log(bmax)-log(bmin))
      if(llg) kzer=-log(bmin)*fact+1.00001d0
c
      undf = b(ist3 +1)
      ovef = b(ist3 +3)
      avex = 0d0
      sum  = b(ist3 +8)
      if(nent.ne.0) avex = sum/nent
      write(nout,'(4a15      )')  'nent','sum','bmin','bmax'
      write(nout,'(i15,3e15.5)')   nent,  sum,  bmin,  bmax
      write(nout,'(4a15  )')      'undf','ovef','avex'
      write(nout,'(4e15.5)')       undf,  ovef,  avex
c
      if(llg) write(nout,1105)
 1105 format(35x,17hlogarithmic scale)
c
      kzer=max0(kzer,0)
      kzer=min0(kzer,lmx)
      xlow=xl
      do 100 k=1,nchx
c first fill with blanks
      do  45 j=1,105
   45 line(j)  =lb
c then fill upper and lower boundry
      line(1)  =li
      line(lmx)=li
      ind=istr+k-1
      bind=b(ind)
      bind= max(bind,bmin)
      bind= min(bind,bmax)
      kros=(bind-bmin)*fact+1.0001d0
      if(llg) kros=log(bind/bmin)*fact+1.0001d0
      k2=max0(kros,kzer)
      k2=min0(lmx,max0(1,k2))
      k1=min0(kros,kzer)
      k1=min0(lmx,max0(1,k1))
      do 50 j=k1,k2
   50 line(j)=lx
      line(kzer)=l0
      z=b(ind)
      if(ker.ne.1) then
        write(nout,'(a, f7.4,  a, d12.4,  132a1)')
     $             ' ', xlow,' ',     z,' ',(line(i),i=1,lmx)
      else
        er=dsqrt(dabs(b(ind+nchx)))
        write(nout,'(a,f7.4,  a,d12.4,  a,d12.4, 132a1 )')
     $             ' ',xlow,' ',    z,' ',   er,' ',(line(i),i=1,lmx)
      endif
      xlow=xlow+dx
  100 continue
      return
C------------- two dimensional requires restoration!!!----------------
  200 continue
      nchy=B(ist+5)
      write(nout,2000) (lx,i=1,nchy)
 2000 format(1h ,10x,2hxx,100a1)
      do 300 kx=1,nchx
      do 250 ky=1,nchy
      k=ist +NBUF2 +kx+nchx*(ky-1)
      N=B(K)+1.99999D0
      n=max0(n,1)
      n=min0(n,22)
      if(DABS(b(k)).lt.1D-20) n=1
      line(ky)=lchr(n)
  250 continue
      line(nchy+1)=lx
      i1=nchy+1
      write(nout,2100) (line(i),i=1,i1)
 2100 format(1h ,10x,1hx,100a1)
  300 continue
      write(nout,2000) (lx,i=1,nchy)
      RETURN
  900 WRITE(NOUT,*) ' +++GPRINT: NONEXISTING HISTO',ID
      WRITE(6   ,*) ' +++GPRINT: NONEXISTING HISTO',ID
      RETURN
 901  WRITE(NOUT,*) ' +++GPRINT: NO ENTRIES  HISTO',ID
      WRITE(   6,*) ' +++GPRINT: NO ENTRIES  HISTO',ID
      RETURN
 902  WRITE(NOUT,*) ' +++GPRINT: wrong plotting limits',ID
      WRITE(   6,*) ' +++GPRINT: wrong plotting limits',ID
      END

      subroutine gopera(ida,chr,idb,idc,coef1,coef2)
*     **********************************************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      common / cglib / b(20000)
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      character*80 titlc
      character*80 title
      character*1  chr
c
      lacta=jadres(ida)
      if(lacta.eq.0) return
      ista  = index(lacta,2)
      ista2 = ista+7
      ncha  = b(ista2+1)
c
      lactb =jadres(idb)
      if(lactb.eq.0) return
      istb  = index(lactb,2)
      istb2 = istb+7
      nchb  = b(istb2+1)
      if(nchb.ne.ncha) goto 900
c
      lactc=jadres(idc)
      if(lactc.eq.0) then
c ...if nonexistent, histo idc is here defined
        call ginbo1(ida,title,nchx,xl,xu)
        call gbook1(idc,title,nchx,xl,xu)
        lactc = jadres(idc)
        istc  = index(lactc,2)
c...option copied from ida
        b(istc+ 3)= b(ista +3)
      endif
c...one nominal entry recorded
      index(lactc,3) = 1
c
      istc  =  index(lactc,2)
      istc2 =  istc+7
      nchc  =  b(istc2+1)
c
      if(nchc.ne.ncha) goto 900
      if(ncha.ne.nchb.or.nchb.ne.nchc) goto 900
      do 30 k=1,ncha
      i1 = ista+nbuf+k
      i2 = istb+nbuf+k
      i3 = istc+nbuf+k
      j1 = ista+nbuf+ncha+k
      j2 = istb+nbuf+ncha+k
      j3 = istc+nbuf+ncha+k
      if    (chr.eq.'+')   then
        b(i3) =    coef1*b(i1) +    coef2*b(i2)
        b(j3) = coef1**2*b(j1) + coef2**2*b(j2)
      elseif(chr.eq.'-')   then
        b(i3) = coef1*b(i1) - coef2*b(i2)
        b(j3) = coef1**2*b(j1) + coef2**2*b(j2)
      elseif(chr.eq.'*')   then
        b(j3) = (coef1*coef2)**2
     $          *(b(j1)*b(i2)**2 + b(j2)*b(i1)**2)
        b(i3) = coef1*b(i1) * coef2*b(i2)
      elseif(chr.eq.'/')   then
        if(b(i2).eq.0d0) then
          b(i3) = 0d0
          b(j3) = 0d0
        else
          b(j3) = (coef1/coef2)**2/b(i2)**4
     $          *(b(j1)*b(i2)**2 + b(j2)*b(i1)**2)
          b(i3) = (coef1*b(i1) )/( coef2*b(i2))
        endif
      else
        goto 901
      endif
   30 continue
      return
  900 write(nout,*) '+++++ gopera: non-equal no. bins ',ida,idb,idc
      write(   6,*) '+++++ gopera: non-equal no. bins ',ida,idb,idc
      return
  901 write(nout,*) '+++++ gopera: wrong chr=',chr
      end

      subroutine ginbo1(id,title,nchx,xl,xu)
*     **************************************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      common / cglib / b(20000)
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      character*80 titlc
      character*80 title
c
      lact=jadres(id)
      if(lact.eq.0) return
      ist=index(lact,2)
      ist2   = ist+7
      nchx   = b(ist2 +1)
      xl     = b(ist2 +2)
      xu     = b(ist2 +3)
      title  = titlc(lact)
      end

      subroutine gunpak(id,a,chd1,idum)
*     *********************************
c getting out histogram content (and error)
c chd1= 'ERRO' is nonstandard option (unpack errors)
*     ***********************************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      character*(*) chd1
      dimension a(*)
      common / cglib / b(20000)
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      character*80 titlc
c
      lact=jadres(id)
      if(lact.eq.0) goto 900
      ist   = index(lact,2)
      ist2  = ist+7
      nch   = b(ist2 +1)
      local = ist +nbuf
      iflag2   = nint(b(ist+4)-9d0-9d12)/10
      ityphi   = mod(iflag2,10)
      if(ityphi.eq.2) then
        nchy  = b(ist2+5)
        nch   = nch*nchy
        local = ist+ nbuf2
      endif
      do 10 ib=1,nch
      if(chd1.ne.'ERRO') then
c normal bin
        a(ib) = b(local+ib)
      else
c error content
        if(ityphi.eq.2) goto 901
        a(ib) = dsqrt( dabs(b(local+nch+ib) ))
      endif
   10 continue
      return
 900  write(nout,*) '+++gunpak: nonexisting id=',id
      write(6   ,*) '+++gunpak: nonexisting id=',id
      return
 901  write(nout,*) '+++gunpak: no errors, two-dim, id=',id
      end

      subroutine gpak(id,a)
*     *********************
c getting in histogram content
*     ***********************************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      dimension  a(*)
      common / cglib / b(20000)
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      character*80 titlc
c
      lact=jadres(id)
      if(lact.eq.0) goto 900
      ist  = index(lact,2)
      ist2 = ist+7
      nch=b(ist2 +1)
      local = ist+nbuf
c 2-dimens histo alowed
      iflag2   = nint(b(ist+4)-9d0-9d12)/10
      ityphi   = mod(iflag2,10)
      if(ityphi.eq.2) then
        nchy  = b(ist2+5)
        nch   = nch*nchy
        local = ist+nbuf2
      endif
      do 10 ib=1,nch
   10 b(local +ib) = a(ib)
c one nominal entry recorded
      index(lact,3)  = 1
      return
  900 write(nout,*) '+++gpak: nonexisting id=',id
      write(6   ,*) '+++gpak: nonexisting id=',id
      end

      subroutine gpake(id,a)
*     **********************
c getting in error content
*     ***********************************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      dimension  a(*)
      common / cglib / b(20000)
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      character*80 titlc
c
      lact=jadres(id)
      if(lact.eq.0) goto 901
      ist  = index(lact,2)
      ist2 = ist+7
      nch=b(ist2+1)
c 2-dimens histo NOT alowed
      iflag2   = nint(b(ist+4)-9d0-9d12)/10
      ityphi   = mod(iflag2,10)
      if(ityphi.eq.2) goto 900
      do 10 ib=1,nch
   10 b(ist+nbuf+nch+ib) = a(ib)**2
      return
  900 write(nout,*) ' +++++ gpake: only for one-dim histos'
      return
  901 write(nout,*) '+++ gpake: nonexisting id=',id
      write(6   ,*) '+++ gpake: nonexisting id=',id
      end


      subroutine grang1(id,ylr,yur)
*     *****************************
c provides y-scale for 1-dim plots
*     ***********************************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      common / cglib / b(20000)
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      character*80 titlc
c
      lact=jadres(id)
      if(lact.eq.0) return
      ist  = index(lact,2)
      ist2 = ist+7
      nch  = b(ist2 +1)
      yl   = b(ist+nbuf+1)
      yu   = b(ist+nbuf+1)
      do 10 ib=1,nch
      yl = min(yl,b(ist+nbuf+ib))
      yu = max(yu,b(ist+nbuf+ib))
   10 continue
      call goptou(id,ioplog,iopsla,ioperb,iopsc1,iopsc2)
      if(iopsc1.eq.2) yl= b( ist +5)
      if(iopsc2.eq.2) yu= b( ist +6)
      ylr = yl
      yur = yu
      end

      subroutine ginbo2(id,nchx,xl,xu,nchy,yl,yu)
*     *******************************************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      common / cglib / b(20000)
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      character*80 titlc
c
      lact=jadres(id)
      if(lact.eq.0) goto 900
      ist  = index(lact,2)
      ist2 = ist+7
      nchx = b(ist2 +1)
      xl   = b(ist2 +2)
      xu   = b(ist2 +3)
      nchy = b(ist2 +5)
      yl   = b(ist2 +6)
      yu   = b(ist2 +7)
      return
  900 write(nout,*) ' +++ginbo2: nonexisting histo id= ',id
      write(   6,*) ' +++ginbo2: nonexisting histo id= ',id
      end


      subroutine gmaxim(id,wmax)
*     **************************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      common / cglib / b(20000)
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      character*80 titlc
c
      if(id.ne.0) then
        lact=jadres(id)
        if(lact.eq.0) return
        ist= index(lact,2)
        b(ist+6) =wmax
        call gidopt(id,'YMAX')
      else
        do 20 k=1,idmx
        if(index(k,1).eq.0) goto 20
        ist=index(k,2)
        jd =index(k,1)
        b(ist+6) =wmax
        call gidopt(jd,'YMAX')
   20   continue
      endif
      end

      subroutine gminim(id,wmin)
*     **************************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      common / cglib / b(20000)
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      character*80 titlc
c
      if(id.ne.0) then
        lact=jadres(id)
        if(lact.eq.0) return
        ist =index(lact,2)
        b(ist+5) =wmin
        call gidopt(id,'YMIN')
      else
        do 20 k=1,idmx
        if(index(k,1).eq.0) goto 20
        ist=index(k,2)
        jd =index(k,1)
        b(ist+5) =wmin
        call gidopt(jd,'YMIN')
   20   continue
      endif
      end

      subroutine greset(id,chd1)
*     **************************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      character*(*) chd1
      common / cglib / b(20000)
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      character*80 titlc
c
      lact=jadres(id)
      if(lact.le.0) return
      ist  =index(lact,2)
      ist2 = ist+7
c
      iflag2   = nint(b(ist+4)-9d0-9d12)/10
      ityphi   = mod(iflag2,10)
      if(ityphi.eq.1) then
c one-dim.
        ist3  = ist+11
        nchx  = b(ist2 +1)
        nch   = 2*nchx
        local = ist + nbuf
      elseif(ityphi.eq.2) then
c two-dim.
        ist3  = ist+15
        nchx  = b(ist2 +1)
        nchy  = b(ist2 +5)
        nch   = nchx*nchy
        local = ist +nbuf2
      else
         write(nout,*) '+++greset: wrong type id=',id
         write(6   ,*) '+++greset: wrong type id=',id
        return
      endif
c reset miscaelaneous entries and bins
      do 10 j=ist3+1,local +nch
  10  b(j)    = 0d0
c and no. of entries in index
      index(lact,3) = 0
      end

      SUBROUTINE GDELET(ID)
*     *********************
C Now it should work (stj Nov. 91) but watch out!
C should works for 2-dim histos, please check this!
*     ***********************************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      common / cglib / b(20000)
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      character*80 titlc
      logical gexist
c
      if(id.eq.0) goto 300
      if(.not.gexist(id)) goto 900
      lact = jadres(id)
      ist  = index(lact,2)
      ist2 = ist+7
      nch  = b(ist2 +1)
      iflag2   = nint(b(ist+4)-9d0-9d12)/10
      ityphi   = mod(iflag2,10)
      if(ityphi.eq.1) then
c one-dim.
        nchx  = b(ist2 +1)
        nch   = 2*nchx
c lenght of local histo to be removed
        local = nch+nbuf+1
      elseif(ityphi.eq.2) then
c two-dim.
        nchx  = b(ist2 +1)
        nchy  = b(ist2 +5)
        nch   = nchx*nchy
c lenght of local histo to be removed
        local = nch+nbuf2+1
      else
         write(nout,*) '+++gdelet: wrong type id=',id
         write(6   ,*) '+++gdelet: wrong type id=',id
        return
      endif
c starting position of next histo in storage b
      next = ist+1 +local
c move down all histos above this one
      do 15 k =next,length
      b(k-local)=b(k)
   15 continue
c define new end of storage
      length=length-local
c clean free space at the end of storage b
      do 20 k=length+1, length+local
   20 b(k)=0d0
c shift adresses of all displaced histos
      do 25 l=lact+1,idmx
      if(index(l,1).ne.0) index(l,2)=index(l,2)-local
   25 continue
c move entries in index down by one and remove id=lact entry
      do 30 l=lact+1,idmx
      index(l-1,1)=index(l,1)
      index(l-1,2)=index(l,2)
      index(l-1,3)=index(l,3)
      titlc(l-1)=titlc(l)
   30 continue
c last entry should be always empty
      index(idmx,1)=0
      index(idmx,2)=0
      index(idmx,3)=0
      do 50 k=1,80
   50 titlc(idmx)(k:k)=' '
      return
C -----------------------------------
C Deleting all histos at once!!!
  300 length=0
      do 400 i=1,idmx
      do 340 k=1,3
  340 index(i,k)=0
      do 350 k=1,80
  350 titlc(i)(k:k)=' '
  400 continue
      return
  900 write(nout,*) ' +++gdelet: nonexisting histo id= ',id
      end


      subroutine glimit(lenmx)
*     ************************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      character*80 titlc
      call ginit
      if(lenmx.ge.lenmax) then
         lenmax=lenmx
      else
         write(nout,*) ' +++++ glimit: you cannot decrease storage'
         stop
      endif
      end

      subroutine copch(ch1,ch2)
*     *************************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
* copies character*80 ch1 into ch2 up to a first $ sign
      character*80 ch1,ch2
      logical met
      met = .false.
      do 10 i=1,80
      if( ch1(i:i).eq.'$' .or. met )   then
        ch2(i:i)=' '
        met=.true.
      else
        ch2(i:i)=ch1(i:i)
      endif
  10  continue
      end

      function jadres(id)
*     *********************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      character*80 titlc
      jadres=0
      do 1 i=1,idmx
      if(index(i,1).eq.id) goto 2
    1 continue
      return
    2 jadres=i
      end


C--------------------------------------------------------------
C ----------- storing histograms in the disk file -------------
C--------------------------------------------------------------
      subroutine grfile(nhruni,dname,chd2)
c     ***********************************
      implicit double precision (a-h,o-z)
      character*(*) chd2, dname
      common / hruni / nhist
      nhist=nhruni
      end

      subroutine grout(idum1,idum2,chdum)
c     ***********************************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      common / cglib / b(20000)
      character*8 chdum
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      common / hruni / nhist
      character*80 titlc
c
      call ginit
      nouth=nhist
      write(nouth,'(6i10)')   nvrs,nout,lenmax,length
      write(nouth,'(6i10)')   ((index(i,k),k=1,3),i=1,idmx)
      write(nouth,'(a80)')    titlc
      write(nouth,'(3d24.16)') (b(i),i=1,length)
      end


      SUBROUTINE GRIN(IDUM1,IDUM2,IDUM3)
C     **********************************
C New version which has possibility to ADD histograms
C identical ID is changed by adding 100000 !!!!
C compatible with GDELET which makes holes in INDEX
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      common / cglib / b(20000)
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      character*80 titlc
      common / hruni / nhist
c copy from disk
      dimension lndex(idmx,3),titld(idmx)
      character*80 titld
      logical gexist
c
      call ginit
      nouth=nhist
      read(nouth,'(6i10)')   nvrs3,nout3,lenma3,lengt3
      if(length+lengt3.ge.lenmax) goto 900
      if(nvrs.ne.nvrs3) write(nout,*)
     $ '  +++++ warning (grin): histos produced by older version',nvrs3
      read(nouth,'(6i10)')  ((lndex(i,k),k=1,3),i=1,idmx)
      read(nouth,'(a80)')    titld
c modify index and titlc
      lact = jadres(0)
      do 100 l=1,idmx
      if(lact.eq.0) goto 901
      idn= lndex(l,1)
      if(idn.eq.0) goto 100
c identical id is changed by adding 100000 !!!!
      if( gexist(idn) ) idn = idn +100000
      index(lact,1)=idn
      index(lact,2)=lndex(l,2)+length
      index(lact,3)=lndex(l,3)
      titlc(lact)  =titld(l)
      lact=lact+1
  100 continue
c add content of new histos
      lenold=length
      length=length+lengt3
      read(nouth,'(3d24.16)') (b(i),i=lenold+1,length)
      return
  900 write(nout,*) ' ++++ stop in grin: to litle space '
      stop
  901 write(nout,*) ' ++++ stop in grin: to many histos '
      stop
      end

      subroutine grend(chdum)
c     ***********************
      implicit double precision (a-h,o-z)
      common / hruni / nhist
      character*(*) chdum
      close(nhist)
c======================================================================
c======================end of gbook====================================
c======================================================================
      end

C======================================================================
C======================Mini-GPLOT======================================
C======================================================================
C... Plotting using LATeX
      SUBROUTINE GPLINT(IDUM)
C     ***********************
C ...dummy routine
      END
      SUBROUTINE GPLCAP(IFILE)
C     ***********************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON / LPLDAT / NOUH1,NOUH2,ILINE
      COMMON / LPLTIT / TITCH,KEYTIT
      CHARACTER*80 TITCH
C Note that backslash definition is varying from one
C instalation/compiler to another, you have to figure out by yourself
C how to fill backslash code into BS
      COMMON / BSLASH / BS
      CHARACTER*1 BS,BBS
C     DATA BBS / 1H\ /
      DATA BBS / '\\' /
      BS = BBS
cc      BS = '\\'
C---
      KEYTIT= 0
      ILINE = 1
      NOUH1=IABS(IFILE)
      NOUH2=NOUH1+1
      WRITE(NOUH1,'(A,A)') BS,'voffset =  1.0cm'
      WRITE(NOUH1,'(A,A)') BS,'hoffset = -1cm'
      WRITE(NOUH1,'(A,A)') BS,'documentstyle[12pt]{article}'
      WRITE(NOUH1,'(A,A)') BS,'textwidth  = 16cm'
      WRITE(NOUH1,'(A,A)') BS,'textheight = 24cm'
      WRITE(NOUH1,'(A,A)') BS,'begin{document}'
      WRITE(NOUH1,'(A)') '  '
      WRITE(NOUH1,'(A)') '  '
      END

      SUBROUTINE GPLEND
C     *****************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON / LPLDAT / NOUH1,NOUH2,ILINE
      COMMON / BSLASH / BS
      CHARACTER*1 BS
      WRITE(NOUH1,'(2A)') BS,'end{document}'
      CLOSE(NOUH1)
      END

      SUBROUTINE GPLOT(ID,CH1,CH2,KDUM)
C     *********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION YY(200),YER(200)
      CHARACTER CH1,CH2,CHR
      CHARACTER*80 TITLE
      LOGICAL GEXIST
      COMMON / LPLDAT / NOUH1,NOUH2,ILINE
      COMMON / BSLASH / BS
      CHARACTER*1 BS
      DATA CHR /' '/
C return if histo non-existing
      IF(.NOT.GEXIST(ID)) GOTO 900
C ...unpack histogram
      CALL GUNPAK(ID,YY ,'    ',IDUM)
      CALL GUNPAK(ID,YER,'ERRO',IDUM)
      CALL GINBO1(ID,TITLE,NCHX,DXL,DXU)
      XL = DXL
      XU = DXU
      CALL GRANG1(ID,YL,YU)
      KAX=1200
      KAY=1200
      IF(CH1.EQ.'S') THEN
C ...superimpose plot
        BACKSPACE(NOUH1)
      ELSE
C ...new frame only
        CHR=CH1
        CALL LFRAM1(ID,KAX,KAY)
      ENDIF
      WRITE(NOUH1,'(A)')    '%========== next plot (line) =========='
      WRITE(NOUH1,'(A,I6)') '%==== HISTOGRAM ID=',ID
      WRITE(NOUH1,'(A,A70 )') '% ',TITLE
C...cont. line for functions
      call goptou(id,ioplog,iopsla,ioperb,iopsc1,iopsc2)
      ker = ioperb-1
      IF (iopsla.eq.2)  CHR='C'
C...suppress GPLOT assignments
      IF (CH2.EQ.'B')   CHR=' '
      IF (CH2.EQ.'*')   CHR='*'
      IF (CH2.EQ.'C')   CHR='C'
C...various types of lines
      IF     (CHR.EQ.' ') THEN
C...contour line used for histogram
          CALL PLHIST(KAX,KAY,NCHX,YL,YU,YY,KER,YER)
      ELSE IF(CHR.EQ.'*') THEN
C...marks in the midle of the bin
          CALL PLHIS2(KAX,KAY,NCHX,YL,YU,YY,KER,YER)
      ELSE IF(CHR.EQ.'C') THEN
C...slanted (dotted) line in plotting non-MC functions
          CALL PLCIRC(KAX,KAY,NCHX,YL,YU,YY)
      ENDIF
      WRITE(NOUH1,'(2A)') BS,'end{picture} % close entire picture '
      RETURN
  900 WRITE(*,*) ' ++++ GPLOT: NONEXISTIG HISTO ' ,ID
      END
      SUBROUTINE LFRAM1(ID,KAX,KAY)
C     *****************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      CHARACTER*80 TITLE
      COMMON / LPLTIT / TITCH,KEYTIT
      CHARACTER*80 TITCH
      DIMENSION TIPSY(20),TIPSX(20)
      COMMON / LPLDAT / NOUH1,NOUH2,ILINE
      DOUBLE PRECISION DXL,DXU
      COMMON / BSLASH / BS
      CHARACTER*1 BS
      DATA ICONT/0/
      ICONT=ICONT+1
      CALL GINBO1(ID,TITLE,NCHX,DXL,DXU)
      XL = DXL
      XU = DXU
      CALL GRANG1(ID,YL,YU)
      IF(ICONT.GT.1) WRITE(NOUH1,'(2A)') BS,'newpage'
      WRITE(NOUH1,'(A)') '% =========== big frame, title etc. ======='
      WRITE(NOUH1,'(2A)') BS,'begin{center}'
      IF(KEYTIT.EQ.0) THEN
        WRITE(NOUH1,'(A)')     TITLE
      ELSE
        WRITE(NOUH1,'(A)')     TITCH
      ENDIF
      WRITE(NOUH1,'(2A)') BS,'end{center}'
      WRITE(NOUH1,'(4A)') BS,'setlength{',BS,'unitlength}{0.1mm}'
      WRITE(NOUH1,'(2A)') BS,'begin{picture}(1600,1500)'
      WRITE(NOUH1,'(4A)') BS,'put(0,0){',BS,'framebox(1600,1500){ }}'
      WRITE(NOUH1,'(A)') '% =========== small frame, labeled axis ==='
      WRITE(NOUH1,'(4A,I4,A,I4,A)')
     $    BS,'put(300,250){',BS,'begin{picture}( ',KAX,',',KAY,')'
      WRITE(NOUH1,'(4A,I4,A,I4,A)')
     $    BS,'put(0,0){',BS,'framebox( ',KAX,',',KAY,'){ }}'
      WRITE(NOUH1,'(A)') '% =========== x and y axis ================'
      CALL SAXIX(KAX,XL,XU,NTIPX,TIPSX)
      CALL SAXIY(KAY,YL,YU,NTIPY,TIPSY)
      WRITE(NOUH1,'(3A)') BS,'end{picture}}'
     $                ,'% end of plotting labeled axis'
      END
      SUBROUTINE SAXIX(KAY,YL,YU,NLT,TIPSY)
C     ***************************************
C plotting x-axis with long and short tips
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION TIPSY(20)
      COMMON / LPLDAT / NOUH1,NOUH2,ILINE
      COMMON / BSLASH / BS
      CHARACTER*1 BS
      DY= ABS(YU-YL)
      LY = NINT( LOG10(DY) -0.49999 )
      JY = NINT(DY/10.**LY)
      DDYL = DY*10.**(-LY)
      IF( JY.EQ.1)             DDYL = 10.**LY*0.25
      IF( JY.GE.2.AND.JY.LE.3) DDYL = 10.**LY*0.5
      IF( JY.GE.4.AND.JY.LE.6) DDYL = 10.**LY*1.0
      IF( JY.GE.7)             DDYL = 10.**LY*2.0
      WRITE(NOUH1,'(A)') '% .......SAXIX........ '
      WRITE(NOUH1,'(A,I4)') '%  JY= ',JY
C-------
      NLT = INT(DY/DDYL)
      NLT = MAX0(MIN0(NLT,20),1)+1
      YY0L = NINT(YL/DDYL+0.5)*DDYL
      DO 41 N=1,NLT
      TIPSY(N) =YY0L+ DDYL*(N-1)
  41  CONTINUE
      DDYS = DDYL/10.
      YY0S = NINT(YL/DDYS+0.49999)*DDYS
      P0L = KAY*(YY0L-YL)/(YU-YL)
      PDL = KAY*DDYL/(YU-YL)
      P0S = KAY*(YY0S-YL)/(YU-YL)
      PDS = KAY*DDYS/(YU-YL)
      NLT = INT(ABS(YU-YY0L)/DDYL+0.00001)+1
      NTS = INT(ABS(YU-YY0S)/DDYS+0.00001)+1
      WRITE(NOUH1,1000)
     $ BS,'multiput('  ,P0L,  ',0)('  ,PDL,  ',0){'  ,NLT,  '}{',
     $ BS,'line(0,1){25}}',
     $ BS,'multiput('  ,P0S,  ',0)('  ,PDS,  ',0){'  ,NTS,  '}{',
     $ BS,'line(0,1){10}}'
      WRITE(NOUH1,1001)
     $ BS,'multiput('  ,P0L,  ','  ,KAY,  ')('  ,PDL,  ',0){'  ,NLT,
     $ '}{'  ,BS,  'line(0,-1){25}}',
     $ BS,'multiput('  ,P0S,  ','  ,KAY,  ')('  ,PDS,  ',0){'  ,NTS,
     $ '}{'  ,BS,  'line(0,-1){10}}'
 1000 FORMAT(2A,F8.2,A,F8.2,A,I4,3A)
 1001 FORMAT(2A,F8.2,A,I4,A,F8.2,A,I4,3A)
C ...labeling of axis
      SCMX = DMAX1(DABS(YL),DABS(YU))
      LEX  = NINT( LOG10(SCMX) -0.50001)
      DO 45 N=1,NLT
      K = KAY*(TIPSY(N)-YL)/(YU-YL)
      IF(LEX.LT.2.AND.LEX.GT.-1) THEN
C ...without exponent
      WRITE(NOUH1,'(2A,I4,5A,F8.3,A)')
     $ BS,'put(',K,',-25){',BS,'makebox(0,0)[t]{',BS,'large $ ',
     $ TIPSY(N), ' $}}'
      ELSE
C ...with exponent
      WRITE(NOUH1,'(2A,I4,5A,F8.3,2A,I4,A)')
     $ BS,'put('  ,K,  ',-25){',BS,'makebox(0,0)[t]{',BS,'large $ ',
     $ TIPSY(N)/(10.**LEX),BS,'cdot 10^{',LEX,'} $}}'
      ENDIF
  45  CONTINUE
      END
      SUBROUTINE SAXIY(KAY,YL,YU,NLT,TIPSY)
C     ***************************************
C plotting y-axis with long and short tips
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION TIPSY(20)
      COMMON / LPLDAT / NOUH1,NOUH2,ILINE
      COMMON / BSLASH / BS
      CHARACTER*1 BS
      DY= ABS(YU-YL)
      LY = NINT( LOG10(DY) -0.49999 )
      JY = NINT(DY/10.**LY)
      DDYL = DY*10.**(-LY)
      IF( JY.EQ.1)             DDYL = 10.**LY*0.25
      IF( JY.GE.2.AND.JY.LE.3) DDYL = 10.**LY*0.5
      IF( JY.GE.4.AND.JY.LE.6) DDYL = 10.**LY*1.0
      IF( JY.GE.7)             DDYL = 10.**LY*2.0
      WRITE(NOUH1,'(A)') '% .......SAXIY........ '
      WRITE(NOUH1,'(A,I4)') '%  JY= ',JY
C-------
      NLT = INT(DY/DDYL)
      NLT = MAX0(MIN0(NLT,20),1)+1
      YY0L = NINT(YL/DDYL+0.49999)*DDYL
      DO 41 N=1,NLT
      TIPSY(N) =YY0L+ DDYL*(N-1)
  41  CONTINUE
      DDYS = DDYL/10.
      YY0S = NINT(YL/DDYS+0.5)*DDYS
      P0L = KAY*(YY0L-YL)/(YU-YL)
      PDL = KAY*DDYL/(YU-YL)
      P0S = KAY*(YY0S-YL)/(YU-YL)
      PDS = KAY*DDYS/(YU-YL)
      NLT= INT(ABS(YU-YY0L)/DDYL+0.00001) +1
      NTS= INT(ABS(YU-YY0S)/DDYS+0.00001) +1
C plotting tics on vertical axis
      WRITE(NOUH1,1000)
     $ BS,'multiput(0,'  ,P0L,  ')(0,'  ,PDL  ,'){'  ,NLT,  '}{',
     $ BS,'line(1,0){25}}',
     $ BS,'multiput(0,'  ,P0S,  ')(0,'  ,PDS,  '){'  ,NTS,  '}{',
     $ BS,'line(1,0){10}}'
      WRITE(NOUH1,1001)
     $ BS,'multiput('  ,KAY,  ','  ,P0L,  ')(0,'  ,PDL,  '){'  ,NLT,
     $ '}{',BS,'line(-1,0){25}}',
     $ BS,'multiput('  ,KAY,  ','  ,P0S,  ')(0,'  ,PDS,  '){'  ,NTS,
     $ '}{',BS,'line(-1,0){10}}'
 1000 FORMAT(2A,F8.2,A,F8.2,A,I4,3A)
 1001 FORMAT(2A,I4,A,F8.2,A,F8.2,A,I4,3A)
C ...Zero line if necessary
      Z0L = KAY*(-YL)/(YU-YL)
      IF(Z0L.GT.0D0.AND.Z0L.LT.FLOAT(KAY))
     $      WRITE(NOUH1,'(2A,F8.2,3A,I4,A)')
     $       BS,'put(0,'  ,Z0L,  '){',BS,'line(1,0){'  ,KAY,  '}}'
C ...labeling of axis
      SCMX = DMAX1(DABS(YL),DABS(YU))
      LEX  = NINT( LOG10(SCMX) -0.50001)
      DO 45 N=1,NLT
      K = KAY*(TIPSY(N)-YL)/(YU-YL)
      IF(LEX.LT.2.AND.LEX.GT.-1) THEN
C ...without exponent
      WRITE(NOUH1,'(2A,I4,5A,F8.3,A)')
     $  BS,'put(-25,'  ,K,  '){',BS,'makebox(0,0)[r]{',
     $  BS,'large $ '  ,TIPSY(N),  ' $}}'
      ELSE
C ...with exponent
      WRITE(NOUH1,'(2A,I4,5A,F8.3,2A,I4,A)')
     $ BS,'put(-25,'  ,K,  '){',BS,'makebox(0,0)[r]{',
     $ BS,'large $ '
     $ ,TIPSY(N)/(10.**LEX),  BS,'cdot 10^{'  ,LEX,  '} $}}'
      ENDIF
  45  CONTINUE
      END
      SUBROUTINE PLHIST(KAX,KAY,NCHX,YL,YU,YY,KER,YER)
C     ************************************************
C plotting contour line for histogram
C     ***********************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION YY(*),YER(*)
      CHARACTER*80 FMT1
      COMMON / LPLDAT / NOUH1,NOUH2,ILINE
      COMMON / BSLASH / BS
      CHARACTER*1 BS
      WRITE(NOUH1,'(4A,I4,A,I4,A)')
     $  BS,'put(300,250){',BS,'begin{picture}( ',KAX,',',KAY,')'
      WRITE(NOUH1,'(A)') '% ========== plotting primitives =========='
C...various types of line
      IF(ILINE.EQ.1) THEN
         WRITE(NOUH1,'(2A)') BS,'thicklines '
      ELSE
         WRITE(NOUH1,'(2A)') BS,'thinlines '
      ENDIF
C...short macros for vertical/horizontal straight lines
      WRITE(NOUH1,'(8A)')
     $ BS,'newcommand{',BS,'x}[3]{',BS,'put(#1,#2){',
     $ BS,'line(1,0){#3}}}'
      WRITE(NOUH1,'(8A)')
     $ BS,'newcommand{',BS,'y}[3]{',BS,'put(#1,#2){',
     $ BS,'line(0,1){#3}}}'
      WRITE(NOUH1,'(8A)')
     $ BS,'newcommand{',BS,'z}[3]{',BS,'put(#1,#2){',
     $ BS,'line(0,-1){#3}}}'
C   error bars
      WRITE(NOUH1,'(8A)')
     $   BS,'newcommand{',BS,'e}[3]{',
     $   BS,'put(#1,#2){',BS,'line(0,1){#3}}}'
      IX0=0
      IY0=0
      DO 100 IB=1,NCHX
      IX1 = KAX*(IB-0.00001)/NCHX
      IY1 = KAY*(YY(IB)-YL)/(YU-YL)
      IY1 = MAX0(MIN0(IY1,KAY),0)
      IDY = IY1-IY0
      IDX = IX1-IX0
      FMT1 = '(2(2A,I4,A,I4,A,I4,A))'
      IF( IDY.GE.0) THEN
         WRITE(NOUH1,FMT1) BS,'y{',IX0,'}{',IY0,'}{',IDY,'}',
     $                     BS,'x{',IX0,'}{',IY1,'}{',IDX,'}'
      ELSE
         WRITE(NOUH1,FMT1) BS,'z{',IX0,'}{',IY0,'}{',-IDY,'}',
     $                     BS,'x{',IX0,'}{',IY1,'}{',IDX,'}'
      ENDIF
      IX0=IX1
      IY0=IY1
      IF(KER.EQ.1) THEN
        IX2 = KAX*(IB-0.5000)/NCHX
        IERR = KAY*((YY(IB)-YER(IB))-YL)/(YU-YL)
        IE = KAY*YER(IB)/(YU-YL)
        IF(IY1.GE.0.AND.IY1.LE.KAY) WRITE(NOUH1,8000) BS,IX2,IERR,IE*2
      ENDIF
 100  CONTINUE
8000  FORMAT(4(A1,2He{,I4,2H}{,I4,2H}{,I4,1H}:1X ))
      WRITE(NOUH1,'(3A)') BS,'end{picture}}',
     $       ' % end of plotting histogram'
C change line-style
      ILINE= ILINE+1
      IF(ILINE.GT.2) ILINE=1
      END
      SUBROUTINE PLHIS2(KAX,KAY,NCHX,YL,YU,YY,KER,YER)
C     ************************************************
C marks in the midle of the bin
C     **********************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION YY(*),YER(*)
      COMMON / LPLDAT / NOUH1,NOUH2,ILINE
      COMMON / BSLASH / BS
      CHARACTER*1 BS
      WRITE(NOUH1,'(4A,I4,A,I4,A)')
     $ BS,'put(300,250){',BS,'begin{picture}( ',KAX,',',KAY,')'
      WRITE(NOUH1,'(A)') '% ========== plotting primitives =========='
C...various types of mark
      IRAD1= 6
      IRAD2=10
      IF(ILINE.EQ.1) THEN
C   small filled circle
       WRITE(NOUH1,'(8A,I3,A)')
     $   BS,'newcommand{',BS,'r}[2]{',
     $   BS,'put(#1,#2){',BS,'circle*{',IRAD1,'}}}'
      ELSEIF(ILINE.EQ.2) THEN
C   small open circle
       WRITE(NOUH1,'(8A,I3,A)')
     $   BS,'newcommand{',BS,'r}[2]{',
     $   BS,'put(#1,#2){',BS,'circle{',IRAD1,'}}}'
      ELSEIF(ILINE.EQ.3) THEN
C   big filled circle
       WRITE(NOUH1,'(8A,I3,A)')
     $   BS,'newcommand{',BS,'r}[2]{',
     $   BS,'put(#1,#2){',BS,'circle*{',IRAD2,'}}}'
      ELSEIF(ILINE.EQ.4) THEN
C   big open circle
       WRITE(NOUH1,'(8A,I3,A)')
     $   BS,'newcommand{',BS,'r}[2]{',
     $   BS,'put(#1,#2){',BS,'circle{',IRAD2,'}}}'
C Other symbols
      ELSEIF(ILINE.EQ.5) THEN
       WRITE(NOUH1,'(10A)')
     $   BS,'newcommand{',BS,'r}[2]{',
     $   BS,'put(#1,#2){',BS,'makebox(0,0){$',BS,'diamond$}}}'
      ELSE
       WRITE(NOUH1,'(10A)')
     $   BS,'newcommand{',BS,'r}[2]{',
     $   BS,'put(#1,#2){',BS,'makebox(0,0){$',BS,'star$}}}'
      ENDIF
C   error bars
      WRITE(NOUH1,'(8A)')
     $   BS,'newcommand{',BS,'e}[3]{',
     $   BS,'put(#1,#2){',BS,'line(0,1){#3}}}'
      DO 100 IB=1,NCHX
      IX1 = KAX*(IB-0.5000)/NCHX
      IY1 = KAY*(YY(IB)-YL)/(YU-YL)
      IF(IY1.GE.0.AND.IY1.LE.KAY) WRITE(NOUH1,7000) BS,IX1,IY1
      IF(KER.EQ.1) THEN
        IERR = KAY*((YY(IB)-YER(IB))-YL)/(YU-YL)
        IE = KAY*YER(IB)/(YU-YL)
        IF(IY1.GE.0.AND.IY1.LE.KAY) WRITE(NOUH1,8000) BS,IX1,IERR,IE*2
      ENDIF
 100  CONTINUE
7000  FORMAT(4(A1,2Hr{,I4,2H}{,I4,1H}:1X ))
8000  FORMAT(4(A1,2He{,I4,2H}{,I4,2H}{,I4,1H}:1X ))
      WRITE(NOUH1,'(3A)') BS,'end{picture}}',
     $    ' % end of plotting histogram'
C change line-style
      ILINE= ILINE+1
      IF(ILINE.GT.6) ILINE=1
      END
      SUBROUTINE PLCIRC(KAX,KAY,NCHX,YL,YU,YY)
C     ****************************************
C plots equidistant points, four-point interpolation,
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION YY(*),IX(3000),IY(3000)
      COMMON / LPLDAT / NOUH1,NOUH2,ILINE
      COMMON / BSLASH / BS
      CHARACTER*1 BS
      SAVE DS
C ...various types of line
C ...distance between points is DS, radius of a point is IRAD
      IRAD2=6
      IRAD1=3
C .............
      WRITE(NOUH1,'(4A,I4,A,I4,A)')
     $  BS,'put(300,250){',BS,'begin{picture}( ',KAX,',',KAY,')'
      WRITE(NOUH1,'(A)') '% ========== plotting primitives =========='
      IF(ILINE.EQ.1) THEN
C   small filled circle
       DS = 10
       WRITE(NOUH1,'(8A,I3,A)')
     $   BS,'newcommand{',BS,'r}[2]{',
     $   BS,'put(#1,#2){',BS,'circle*{',IRAD1,'}}}'
      ELSEIF(ILINE.EQ.2) THEN
C   small open circle
       DS = 10
       WRITE(NOUH1,'(8A,I3,A)')
     $   BS,'newcommand{',BS,'r}[2]{',
     $   BS,'put(#1,#2){',BS,'circle{',IRAD1,'}}}'
      ELSEIF(ILINE.EQ.3) THEN
C   big filled circle
       DS = 20
       WRITE(NOUH1,'(8A,I3,A)')
     $   BS,'newcommand{',BS,'r}[2]{',
     $   BS,'put(#1,#2){',BS,'circle*{',IRAD2,'}}}'
      ELSEIF(ILINE.EQ.4) THEN
C   big open circle
       DS = 20
       WRITE(NOUH1,'(8A,I3,A)')
     $   BS,'newcommand{',BS,'r}[2]{',
     $   BS,'put(#1,#2){',BS,'circle{',IRAD2,'}}}'
C Other symbols
      ELSEIF(ILINE.EQ.5) THEN
       DS = 20
       WRITE(NOUH1,'(10A)')
     $   BS,'newcommand{',BS,'r}[2]{',
     $   BS,'put(#1,#2){',BS,'makebox(0,0){$',BS,'diamond$}}}'
      ELSE
       DS = 20
       WRITE(NOUH1,'(10A)')
     $   BS,'newcommand{',BS,'r}[2]{',
     $   BS,'put(#1,#2){',BS,'makebox(0,0){$',BS,'star$}}}'
      ENDIF
      FACY = KAY/(YU-YL)
C plot first point
      AI  = 0.
      AJ  = (APROF((AI/KAX)*NCHX+0.5, NCHX, YY) -YL)*FACY
      IPNT =1
      IX(IPNT) = INT(AI)
      IY(IPNT) = INT(AJ)
      DX =  DS
      AI0 = AI
      AJ0 = AJ
C plot next points
      DO 100 IPOIN=2,3000
C iteration to get (approximately) equal distance among ploted points
      DO  50 ITER=1,3
      AI  = AI0+DX
      AJ  = (APROF((AI/KAX)*NCHX+0.5, NCHX, YY) -YL)*FACY
      DX  = DX *DS/SQRT(DX**2 + (AJ-AJ0)**2)
  50  CONTINUE
      IF(INT(AJ).GE.0.AND.INT(AJ).LE.KAY.AND.INT(AI).LE.KAX) THEN
         IPNT = IPNT+1
         IX(IPNT) = INT(AI)
         IY(IPNT) = INT(AJ)
      ENDIF
      AI0 = AI
      AJ0 = AJ
      IF(INT(AI).GT.KAX) GOTO 101
 100  CONTINUE
 101  CONTINUE
      WRITE(NOUH1,7000) (BS,IX(I),IY(I), I=1,IPNT)
7000  FORMAT(4(A1,2Hr{,I4,2H}{,I4,1H}:1X ))
      WRITE(NOUH1,'(2A)') BS,'end{picture}} % end of plotting line'
C change line-style
      ILINE= ILINE+1
      IF(ILINE.GT.2) ILINE=1
      END
      FUNCTION APROF(PX,NCH,YY)
C     *************************
C PX is a continuous extension of the index in array YY
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION YY(*)
      X=PX
      IF(X.LT.0.0.OR.X.GT.FLOAT(NCH+1)) THEN
        APROF= -1E-20
        RETURN
      ENDIF
      IP=INT(X)
      IF(IP.LT.2)     IP=2
      IF(IP.GT.NCH-2) IP=NCH-2
      P=X-IP
      APROF = -(1./6.)*P*(P-1)*(P-2)  *YY(IP-1)
     $        +(1./2.)*(P*P-1)*(P-2)  *YY(IP  )
     $        -(1./2.)*P*(P+1)*(P-2)  *YY(IP+1)
     $        +(1./6.)*P*(P*P-1)      *YY(IP+2)
      END
      SUBROUTINE GPLSET(CH,XX)
*     ************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON / LPLDAT / NOUH1,NOUH2,ILINE
      CHARACTER*4 CH
      KTY=NINT(XX)
      IF(CH.EQ.'DMOD') THEN
        ILINE=KTY
      ENDIF
      END
      SUBROUTINE GPLTIT(TITLE)
*     ************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      CHARACTER*80 TITLE
      COMMON / LPLTIT / TITCH,KEYTIT
      CHARACTER*80 TITCH
      KEYTIT=1
      DO 50 K=1,80
   50 TITCH(K:K)=' '
      CALL COPCH(TITLE,TITCH)
      END



      subroutine gmonit(mode,id,wt,wtmax,rn)
c     **************************************
c Utility program for monitoring m.c. rejection weights.
c ---------------------------------------------------------
C It is backward compatible with WMONIT except:
c  (1) for id=-1 one  should call as follows:
c      call(-1,id,0d0,1d0,1d0) or skip initialisation completely!
c  (2) maximum absolute weight is looked for,
c  (3) gprint(-id) prints weight distribution, net profit!
c  (4) no restriction id<100 any more!
c ---------------------------------------------------------
c wt is weight, wtmax is maximum weight and rn is random number.
c if(mode.eq.-1) then
c          initalization if entry id,
c        - wtmax is maximum weight used for couting overweighted
c          other arguments are ignored
c elseif(mode.eq.0) then
c          summing up weights etc. for a given event for entry id
c        - wt is current weight.
c        - wtmax is maximum weight used for couting overweighted
c          events with wt>wtmax.
c        - rn is random number used in rejection, it is used to
c          count no. of accepted (rn<wt/wtmax) and rejected
c          (wt>wt/wtmax) events,
c          if ro rejection then put rn=0d0.
c elseif(mode.eq.1) then
c          in this mode wmonit repports on accumulated statistics
c          and the information is stored in common /cmonit/
c        - averwt= average weight wt counting all event
c        - errela= relative error of averwt
c        - nevtot= total nimber of accounted events
c        - nevacc= no. of accepted events (rn<wt\wtmax)
c        - nevneg= no. of events with negative weight (wt<0)
c        - nevzer= no. of events with zero weight (wt.eq.0d0)
c        - nevove= no. of overweghted events (wt>wtmax)
c          and if you do not want to use cmonit then the value
c          the value of averwt is assigned to wt,
c          the value of errela is assigned to wtmax and
c          the value of wtmax  is assigned to rn in this mode.
c elseif(mode.eq.2) then
c          all information defined for entry id defined above
c          for mode=2 is just printed of unit nout
c endif
c note that output repport (mode=1,2) is done dynamically just for a
c given entry id only and it may be repeated many times for one id and
c for various id's as well.
c     ************************
      implicit double precision (a-h,o-z)
      parameter( idmx=400,nbuf=24,nbuf2=24)
      common / cglib / b(20000)
      common /gind/ nvrs,nout,lenmax,length,index(idmx,3),titlc(idmx)
      character*80 titlc
c special gmonit common
      common / cmonit/ averwt,errela,nevtot,nevacc,nevneg,nevove,nevzer
c
      idg = -id
      if(id.le.0) then
           write(nout,*) ' =====wmonit: wrong id',id
           stop
      endif
      if(mode.eq.-1) then
c     *******************
           nbin = nint(dabs(rn))
           if(nbin.gt.100) nbin =100
           if(nbin.eq.0)   nbin =1
           xl   =  wt
           xu   =  wtmax
           if(xu.le.xl) then
             xl = 0d0
             xu = 1d0
           endif
           lact=jadres(idg)
           if(lact.eq.0) then
              call gbook1(idg,' gmonit $',nbin,xl,xu)
           else
              call greset(idg,'  ')
           endif
      elseif(mode.eq.0) then
c     **********************
           lact=jadres(idg)
           if(lact.eq.0) then
              write(nout,*) ' ***** Gmonit initialized, id=',id
              call gbook1(idg,' gmonit $',1,0d0,1d0)
           endif
c     standard entries
           call gf1(idg,wt,1d0)
c     additional goodies
           ist  = index(lact,2)
           ist2 = ist+7
           ist3 = ist+11
c    maximum weight -- maximum by absolute value but keeping sign
           IF(  dabs(b(ist3+13)).LT.dabs(wt)) THEN
             b(ist3+13)    = max( dabs(b(ist3+13)) ,dabs(wt))
             if(wt.ne.0d0) b(ist3+13)=b(ist3+13) *wt/dabs(wt)
           ENDIF
c    nevzer,nevove,nevacc
           if(wt.eq.0d0)        b(ist3+10) =b(ist3+10) +1d0
           if(wt.gt.wtmax)      b(ist3+11) =b(ist3+11) +1d0
           if(rn*wtmax.le.wt)   b(ist3+12) =b(ist3+12) +1d0
      elseif(mode.ge.1.or.mode.le.3) then
c     ***********************************
           lact=jadres(idg)
           if(lact.eq.0) then
              write(nout,*) ' ==== warning from wmonit: '
              write(nout,*) ' lack of initialization, id=',id
              return
           endif
           ist    = index(lact,2)
           ist2   = ist+7
           ist3   = ist+11
           ntot = nint(b(ist3 +7))
           swt    =    b(ist3 +8)
           sswt   =    b(ist3 +9)
           if(ntot.le.0 .or. swt .eq. 0d0 )  then
              averwt=0d0
              errela=0d0
           else
              averwt=swt/float(ntot)
              errela=sqrt(abs(sswt/swt**2-1d0/float(ntot)))
           endif
c   output through common
           nevtot = ntot
           nevacc = b(ist3 +12)
           nevneg = b(ist3  +1)
           nevzer = b(ist3 +10)
           nevove = b(ist3 +11)
           wwmax  = b(ist3 +13)
c   output through parameters
           wt     = averwt
           wtmax  = errela
           rn     = wwmax
c  no printout for mode > 1
c  ************************
           if(mode.eq.1) return
           write(nout,1003) id, averwt, errela, wwmax
           write(nout,1004) nevtot,nevacc,nevneg,nevove,nevzer
           if(mode.eq.2) return
           call gprint(idg)
      else
c     ****
           write(nout,*) ' =====wmonit: wrong mode',mode
           stop
      endif
c     *****
 1003 format(
     $  ' =======================gmonit========================'
     $/,'   id           averwt         errela            wwmax'
     $/,    i5,           e17.7,         f15.9,           e17.7)
 1004 format(
     $  ' -----------------------------------------------------------'
     $/,'      nevtot      nevacc      nevneg      nevove      nevzer'
     $/,   5i12)
      end
C=============================================================
C=============================================================
C==== end of elementary file =================================
C=============================================================
C=============================================================
C.----------------------------------------------------------------------
C.
C.    PHOTOS:   PHOtos CDE's
C.
C.    Purpose:  Keep definitions  for PHOTOS QED correction Monte Carlo.
C.
C.    Input Parameters:   None
C.
C.    Output Parameters:  None
C.
C.    Author(s):  Z. Was, B. van Eijk             Created at:  29/11/89
C.                                                Last Update: 10/08/93
C.
C. =========================================================
C.    General Structure Information:                       =
C. =========================================================
C:   ROUTINES:
C.             1) INITIALIZATION:
C.                                      PHOCDE
C.                                      PHOINI
C.                                      PHOCIN
C.                                      PHOINF
C.             2) GENERAL INTERFACE:
C.                                      PHOTOS
C.                                      PHOBOS
C.                                      PHOIN
C.                                      PHOTWO (specific interface
C.                                      PHOOUT
C.                                      PHOCHK
C.                                      PHTYPE (specific interface
C.                                      PHOMAK (specific interface
C.             3) QED PHOTON GENERATION:
C.                                      PHINT
C.                                      PHOPRE
C.                                      PHOOMA
C.                                      PHOENE
C.                                      PHOCOR
C.                                      PHOFAC
C.                                      PHODO
C.             4) UTILITIES:
C.                                      PHOTRI
C.                                      PHOAN1
C.                                      PHOAN2
C.                                      PHOBO3
C.                                      PHORO2
C.                                      PHORO3
C.                                      PHORIN
C.                                      PHORAN
C.                                      PHOCHA
C.                                      PHOSPI
C.                                      PHOERR
C.                                      PHOREP
C.                                      PHLUPA
C.   COMMONS:
C.   NAME     USED IN SECT. # OF OCC.     Comment
C.   PHOQED   1) 2)            3      Flags whether emisson to be gener.
C.   PHOLUN   1) 4)            5      Output device number
C.   PHOCOP   1) 3)            4      photon coupling & min energy
C.   PHPICO   1) 3) 4)         5      PI & 2*PI
C.   PHSEED   1) 4)            3      RN seed
C.   PHOSTA   1) 4)            3      Status information
C.   PHOKEY   1) 2) 3)         7      Keys for nonstandard application
C.   PHOVER   1)               1      Version info for outside
C.   HEPEVT   2)               6      PDG common
C.   PHOEVT   2) 3)            9      PDG branch
C.   PHOIF    2) 3)            2      emission flags for PDG branch
C.   PHOMOM   3)               5      param of char-neutr system
C.   PHOPHS   3)               5      photon momentum parameters
C.   PHOPRO   3)               4      var. for photon rep. (in branch)
C.   PHOCMS   2)               3      parameters of boost to branch CMS
C.   PHNUM    4)               1      event number from outside
C.----------------------------------------------------------------------
      SUBROUTINE PHOINI
C.----------------------------------------------------------------------
C.
C.    PHOTOS:   PHOton radiation in decays INItialisation
C.
C.    Purpose:  Initialisation  routine  for  the  PHOTOS  QED radiation
C.              package.  Should be called  at least once  before a call
C.              to the steering program 'PHOTOS' is made.
C.
C.    Input Parameters:   None
C.
C.    Output Parameters:  None
C.
C.    Author(s):  Z. Was, B. van Eijk             Created at:  26/11/89
C.                                                Last Update: 12/04/90
C.
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      INTEGER INIT
      SAVE INIT
      DATA INIT/ 0/
C--
C--   Return if already initialized...
      IF (INIT.NE.0) RETURN
      INIT=1
C--
C--   Preset parameters in PHOTOS commons
      CALL PHOCIN
C--
C--   Print info
      CALL PHOINF
C--
C--   Initialize Marsaglia and Zaman random number generator
      CALL PHORIN
      RETURN
      END
      SUBROUTINE PHOCIN
C.----------------------------------------------------------------------
C.
C.    PHOTOS:   PHOton Common INitialisation
C.
C.    Purpose:  Initialisation of parameters in common blocks.
C.
C.    Input Parameters:   None
C.
C.    Output Parameters:  Commons /PHOLUN/, /PHOPHO/, /PHOCOP/, /PHPICO/
C.                                and /PHSEED/.
C.
C.    Author(s):  B. van Eijk                     Created at:  26/11/89
C.                Z. Was                          Last Update: 10/08/93
C.
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      INTEGER NMXHEP
      PARAMETER (NMXHEP=2000)
      LOGICAL QEDRAD
      COMMON/PHOQED/QEDRAD(NMXHEP)
      INTEGER PHLUN
      COMMON/PHOLUN/PHLUN
      REAL ALPHA,XPHCUT
      COMMON/PHOCOP/ALPHA,XPHCUT
      REAL PI,TWOPI
      COMMON/PHPICO/PI,TWOPI
      INTEGER ISEED,I97,J97
      REAL URAN,CRAN,CDRAN,CMRAN
      COMMON/PHSEED/ISEED(2),I97,J97,URAN(97),CRAN,CDRAN,CMRAN
      INTEGER PHOMES
      PARAMETER (PHOMES=10)
      INTEGER STATUS
      COMMON/PHOSTA/STATUS(PHOMES)
      LOGICAL INTERF,ISEC,IFTOP
      REAL FINT,FSEC
      COMMON /PHOKEY/ INTERF,FINT,ISEC,FSEC,IFTOP
      INTEGER INIT,I
      SAVE INIT
      DATA INIT/ 0/
C--
C--   Return if already initialized...
      IF (INIT.NE.0) RETURN
      INIT=1
C--
C--   Preset switch  for  photon emission to 'TRUE' for each particle in
C--   /HEPEVT/, this interface is needed for KORALB and KORALZ...
      DO 10 I=1,NMXHEP
   10 QEDRAD(I)=.TRUE.
C--
C--   Logical output unit for printing of PHOTOS error messages
      PHLUN=6
C--
C--   Set cut parameter for photon radiation
      XPHCUT=0.01
C--
C--   Define some constants
      ALPHA=0.00729735039
      PI=3.14159265358979324
      TWOPI=6.28318530717958648
C--
C--   Default seeds Marsaglia and Zaman random number generator
      ISEED(1)=1802
      ISEED(2)=9373
C--
C--   Iitialization for extra options
C--   (1)
C--   Interference weight for two body symmetric channels only.
      INTERF=.TRUE.
C--   (2)
C--   Second order - double photon switch
      ISEC=.TRUE.
C--   (3)
C--   Emision in the hard process g g (q qbar) --> t tbar
C--                                 t          --> W b
      IFTOP=.TRUE.
C--
C--   further initialization done automatically
      IF (INTERF) THEN
C--   best choice is if FINT=2**N where N+1 is maximal number of charged daughters
C--   see report on overweihted events
        FINT=2.0
      ELSE
        FINT=1.0
      ENDIF
C--   Initialise status counter for warning messages
      DO 20 I=1,PHOMES
   20 STATUS(I)=0
      RETURN
      END
      SUBROUTINE PHOINF
C.----------------------------------------------------------------------
C.
C.    PHOTOS:   PHOton radiation in decays general INFo
C.
C.    Purpose:  Print PHOTOS info
C.
C.    Input Parameters:   PHOLUN
C.
C.    Output Parameters:  PHOVN1, PHOVN2
C.
C.    Author(s):  B. van Eijk                     Created at:  12/04/90
C.                                                Last Update: 02/10/93
C.
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      INTEGER IV1,IV2,IV3
      INTEGER PHOVN1,PHOVN2
      COMMON/PHOVER/PHOVN1,PHOVN2
      INTEGER PHLUN
      COMMON/PHOLUN/PHLUN
      LOGICAL INTERF,ISEC,IFTOP
      REAL FINT,FSEC
      COMMON /PHOKEY/ INTERF,FINT,ISEC,FSEC,IFTOP
      REAL ALPHA,XPHCUT
      COMMON/PHOCOP/ALPHA,XPHCUT
C--
C--   PHOTOS version number and release date
      PHOVN1=200
      PHOVN2=161193
C--
C--   Print info
      WRITE(PHLUN,9000)
      WRITE(PHLUN,9020)
      WRITE(PHLUN,9010)
      WRITE(PHLUN,9030)
      IV1=PHOVN1/100
      IV2=PHOVN1-IV1*100
      WRITE(PHLUN,9040) IV1,IV2
      IV1=PHOVN2/10000
      IV2=(PHOVN2-IV1*10000)/100
      IV3=PHOVN2-IV1*10000-IV2*100
      WRITE(PHLUN,9050) IV1,IV2,IV3
      WRITE(PHLUN,9030)
      WRITE(PHLUN,9010)
      WRITE(PHLUN,9060)
      WRITE(PHLUN,9010)
      WRITE(PHLUN,9070)
      WRITE(PHLUN,9010)
      WRITE(PHLUN,9020)
      WRITE(PHLUN,9010)
      WRITE(PHLUN,9064) INTERF,ISEC,IFTOP,ALPHA,XPHCUT
      WRITE(PHLUN,9010)
      IF (INTERF) WRITE(PHLUN,9061)
      IF (ISEC)   WRITE(PHLUN,9062)
      IF (IFTOP)  WRITE(PHLUN,9063)
      WRITE(PHLUN,9010)
      WRITE(PHLUN,9020)
      RETURN
 9000 FORMAT(1H1)
 9010 FORMAT(1H ,'*',T81,'*')
 9020 FORMAT(1H ,80('*'))
 9030 FORMAT(1H ,'*',26X,26('='),T81,'*')
 9040 FORMAT(1H ,'*',28X,'PHOTOS, Version: ',I2,'.',I2,T81,'*')
 9050 FORMAT(1H ,'*',28X,'Released at:  ',I2,'/',I2,'/',I2,T81,'*')
 9060 FORMAT(1H ,'*',18X,'PHOTOS QED Corrections in Particle Decays',
     &T81,'*')
 9061 FORMAT(1H ,'*',18X,'option with interference is active       ',
     &T81,'*')
 9062 FORMAT(1H ,'*',18X,'option with double photons is active     ',
     &T81,'*')
 9063 FORMAT(1H ,'*',18X,'emision in t tbar production is active   ',
     &T81,'*')
 9064 FORMAT(1H ,'*',18X,'Internal input parameters:',T81,'*'
     &,/,    1H ,'*',T81,'*'
     &,/,    1H ,'*',18X,'INTERF=',L2,'  ISEC=',L2,'  IFTOP=',L2,T81,'*'
     &,/,    1H ,'*',18X,'ALPHA_QED=',F8.5,'   XPHCUT=',F8.5,T81,'*')
 9070 FORMAT(1H ,'*',9X,'Monte Carlo Program - by E. Barberio, B. van Ei
     &jk and Z. Was',T81,'*',/,
     &      1H ,'*',9X,'From version 2.0 on - by E.B. and Z.W.',T81,'*')
      END
      SUBROUTINE PHOTOS(IPARR)
C.----------------------------------------------------------------------
C.
C.    PHOTOS:   General search routine
C.
C.    Purpose:  Search through the /HEPEVT/ standard HEP common,  star-
C.              ting  from  the IPPAR-th  particle.  Whenevr  branching
C     .         point is found routine PHTYPE(IP) is called.
C.              Finally if calls on PHTYPE(IP) modified entries, common
C               /HEPEVT/ is ordered.
C.
C.    Input Parameter:    IPPAR:  Pointer   to   decaying  particle  in
C.                                /HEPEVT/ and the common itself,
C.
C.    Output Parameters:  Common  /HEPEVT/, either with or without  new
C.                                particles added.
C.
C.    Author(s):  Z. Was, B. van Eijk             Created at:  26/11/89
C.                                                Last Update: 30/08/93
C.
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      REAL PHOTON(5)
      INTEGER IP,IPARR,IPPAR,I,J,K,L,NLAST
      DOUBLE PRECISION DATA
      INTEGER MOTHER,POSPHO
      LOGICAL CASCAD
      INTEGER NMXHEP
      PARAMETER (NMXHEP=2000)
      INTEGER IDHEP,ISTHEP,JDAHEP,JMOHEP,NEVHEP,NHEP
      REAL PHEP,VHEP
      COMMON/HEPEVT/NEVHEP,NHEP,ISTHEP(NMXHEP),IDHEP(NMXHEP),
     &JMOHEP(2,NMXHEP),JDAHEP(2,NMXHEP),PHEP(5,NMXHEP),VHEP(4,NMXHEP)
      LOGICAL QEDRAD
      COMMON/PHOQED/QEDRAD(NMXHEP)
      INTEGER NMXPHO
      PARAMETER (NMXPHO=2000)
      INTEGER ISTACK(0:NMXPHO),NUMIT,NTRY,KK,LL,II,NA,FIRST,LAST
      INTEGER FIRSTA,LASTA,IPP,IDA1,IDA2,MOTHER2,IDPHO,ISPHO
      REAL PORIG(5,NMXPHO)
C--
      IPPAR=ABS(IPARR)
C--   Store pointers for cascade treatement...
      IP=IPPAR
      NLAST=NHEP
      CASCAD=.FALSE.
C--
C--   Check decay multiplicity and minimum of correctness..
      IF ((JDAHEP(1,IP).EQ.0).OR.(JMOHEP(1,JDAHEP(1,IP)).NE.IP)) RETURN
C--
C-- single branch mode
C-- we start looking for the decay points in the cascade
C-- IPPAR is original position where the program was called
      ISTACK(0)=IPPAR
C--   NUMIT denotes number of secondary decay branches
      NUMIT=0
C--   NTRY denotes number of secondary branches already checked for
C--        for existence of further branches
      NTRY=0
C-- let's search if IPARR does not prevent searching.
      IF (IPARR.GT.0)  THEN
 30    CONTINUE
         DO I=JDAHEP(1,IP),JDAHEP(2,IP)
          IF (JDAHEP(1,I).NE.0.AND.JMOHEP(1,JDAHEP(1,I)).EQ.I) THEN
            NUMIT=NUMIT+1
              IF (NUMIT.GT.NMXPHO) THEN
               DATA=NUMIT
               CALL PHOERR(7,'PHOTOS',DATA)
              ENDIF
            ISTACK(NUMIT)=I
          ENDIF
         ENDDO
      IF(NUMIT.GT.NTRY) THEN
       NTRY=NTRY+1
       IP=ISTACK(NTRY)
       GOTO 30
      ENDIF
      ENDIF
C-- let's do generation
      DO 25 KK=0,NUMIT
        NA=NHEP
        FIRST=JDAHEP(1,ISTACK(KK))
        LAST=JDAHEP(2,ISTACK(KK))
        DO II=1,LAST-FIRST+1
         DO LL=1,5
          PORIG(LL,II)=PHEP(LL,FIRST+II-1)
         ENDDO
        ENDDO
C--
        CALL PHTYPE(ISTACK(KK))
C--
C--  Correct energy/momentum of cascade daughters
        IF(NHEP.GT.NA) THEN
        DO II=1,LAST-FIRST+1
          IPP=FIRST+II-1
          FIRSTA=JDAHEP(1,IPP)
          LASTA=JDAHEP(2,IPP)
          IF(JMOHEP(1,IPP).EQ.ISTACK(KK))
     $      CALL PHOBOS(IPP,PORIG(1,II),PHEP(1,IPP),FIRSTA,LASTA)
        ENDDO
        ENDIF
 25   CONTINUE
C--
C--   rearrange  /HEPEVT/  to get correct order..
        IF (NHEP.GT.NLAST) THEN
          DO 160 I=NLAST+1,NHEP
C--
C--   Photon mother and position...
            MOTHER=JMOHEP(1,I)
            POSPHO=JDAHEP(2,MOTHER)+1
C--   Intermediate save of photon energy/momentum and pointers
              DO 90 J=1,5
   90         PHOTON(J)=PHEP(J,I)
              ISPHO =ISTHEP(I)
              IDPHO =IDHEP(I)
              MOTHER2 =JMOHEP(2,I)
              IDA1 =JDAHEP(1,I)
              IDA2 =JDAHEP(2,I)
C--
C--   Exclude photon in sequence !
            IF (POSPHO.NE.NHEP) THEN
C--
C--
C--   Order /HEPEVT/
              DO 120 K=I,POSPHO+1,-1
                ISTHEP(K)=ISTHEP(K-1)
                QEDRAD(K)=QEDRAD(K-1)
                IDHEP(K)=IDHEP(K-1)
                DO 100 L=1,2
                JMOHEP(L,K)=JMOHEP(L,K-1)
  100           JDAHEP(L,K)=JDAHEP(L,K-1)
                DO 110 L=1,5
  110           PHEP(L,K)=PHEP(L,K-1)
                DO 120 L=1,4
  120         VHEP(L,K)=VHEP(L,K-1)
C--
C--   Correct pointers assuming most dirty /HEPEVT/...
              DO 130 K=1,NHEP
                DO 130 L=1,2
                  IF ((JMOHEP(L,K).NE.0).AND.(JMOHEP(L,K).GE.
     &            POSPHO)) JMOHEP(L,K)=JMOHEP(L,K)+1
                  IF ((JDAHEP(L,K).NE.0).AND.(JDAHEP(L,K).GE.
     &            POSPHO)) JDAHEP(L,K)=JDAHEP(L,K)+1
  130         CONTINUE
C--
C--   Store photon energy/momentum
              DO 140 J=1,5
  140         PHEP(J,POSPHO)=PHOTON(J)
            ENDIF
C--
C--   Store pointers for the photon...
            JDAHEP(2,MOTHER)=POSPHO
            ISTHEP(POSPHO)=ISPHO
            IDHEP(POSPHO)=IDPHO
            JMOHEP(1,POSPHO)=MOTHER
            JMOHEP(2,POSPHO)=MOTHER2
            JDAHEP(1,POSPHO)=IDA1
            JDAHEP(2,POSPHO)=IDA2
C--
C--   Get photon production vertex position
            DO 150 J=1,4
  150       VHEP(J,POSPHO)=VHEP(J,POSPHO-1)
  160     CONTINUE
        ENDIF
      RETURN
      END
      SUBROUTINE PHOBOS(IP,PBOOS1,PBOOS2,FIRST,LAST)
C.----------------------------------------------------------------------
C.
C.    PHOBOS:   PHOton radiation in decays BOoSt routine
C.
C.    Purpose:  Boost particles  in  cascade decay  to parent rest frame
C.              and boost back with modified boost vector.
C.
C.    Input Parameters:       IP:  pointer of particle starting chain
C.                                 to be boosted
C.                        PBOOS1:  Boost vector to rest frame,
C.                        PBOOS2:  Boost vector to modified frame,
C.                        FIRST:   Pointer to first particle to be boos-
C.                                 ted (/HEPEVT/),
C.                        LAST:    Pointer to last  particle to be boos-
C.                                 ted (/HEPEVT/).
C.
C.    Output Parameters:  Common /HEPEVT/.
C.
C.    Author(s):  B. van Eijk                     Created at:  13/02/90
C.                Z. Was                          Last Update: 16/11/93
C.
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      DOUBLE PRECISION BET1(3),BET2(3),GAM1,GAM2,PB,DATA
      INTEGER I,J,FIRST,LAST,MAXSTA,NSTACK,IP
      PARAMETER (MAXSTA=2000)
      INTEGER STACK(MAXSTA)
      REAL PBOOS1(5),PBOOS2(5)
      INTEGER NMXHEP
      PARAMETER (NMXHEP=2000)
      INTEGER IDHEP,ISTHEP,JDAHEP,JMOHEP,NEVHEP,NHEP
      REAL PHEP,VHEP
      COMMON/HEPEVT/NEVHEP,NHEP,ISTHEP(NMXHEP),IDHEP(NMXHEP),
     &JMOHEP(2,NMXHEP),JDAHEP(2,NMXHEP),PHEP(5,NMXHEP),VHEP(4,NMXHEP)
      IF ((LAST.EQ.0).OR.(LAST.LT.FIRST)) RETURN
      NSTACK=0
      DO 10 J=1,3
        BET1(J)=-PBOOS1(J)/PBOOS1(5)
   10 BET2(J)=PBOOS2(J)/PBOOS2(5)
      GAM1=PBOOS1(4)/PBOOS1(5)
      GAM2=PBOOS2(4)/PBOOS2(5)
C--
C--   Boost vector to parent rest frame...
   20 DO 50 I=FIRST,LAST
        PB=BET1(1)*PHEP(1,I)+BET1(2)*PHEP(2,I)+BET1(3)*PHEP(3,I)
        IF (JMOHEP(1,I).EQ.IP) THEN
         DO 30 J=1,3
   30    PHEP(J,I)=PHEP(J,I)+BET1(J)*(PHEP(4,I)+PB/(GAM1+1.))
         PHEP(4,I)=GAM1*PHEP(4,I)+PB
C--
C--    ...and boost back to modified parent frame.
         PB=BET2(1)*PHEP(1,I)+BET2(2)*PHEP(2,I)+BET2(3)*PHEP(3,I)
         DO 40 J=1,3
   40    PHEP(J,I)=PHEP(J,I)+BET2(J)*(PHEP(4,I)+PB/(GAM2+1.))
         PHEP(4,I)=GAM2*PHEP(4,I)+PB
         IF (JDAHEP(1,I).NE.0) THEN
           NSTACK=NSTACK+1
C--
C--    Check on stack length...
           IF (NSTACK.GT.MAXSTA) THEN
             DATA=NSTACK
             CALL PHOERR(7,'PHOBOS',DATA)
           ENDIF
           STACK(NSTACK)=I
         ENDIF
        ENDIF
   50 CONTINUE
      IF (NSTACK.NE.0) THEN
C--
C--   Now go one step further in the decay tree...
        FIRST=JDAHEP(1,STACK(NSTACK))
        LAST=JDAHEP(2,STACK(NSTACK))
        IP=STACK(NSTACK)
        NSTACK=NSTACK-1
        GOTO 20
      ENDIF
      RETURN
      END
      SUBROUTINE PHOIN(IP,BOOST,NHEP0)
C.----------------------------------------------------------------------
C.
C.    PHOIN:   PHOtos INput
C.
C.    Purpose:  copies IP branch of the common /HEPEVT/ into /PHOEVT/
C.              moves branch into its CMS system.
C.
C.    Input Parameters:       IP:  pointer of particle starting branch
C.                                 to be copied
C.                        BOOST:   Flag whether boost to CMS was or was
C     .                            not performed.
C.
C.    Output Parameters:  Commons: /PHOEVT/, /PHOCMS/
C.
C.    Author(s):  Z. Was                          Created at:  24/05/93
C.                                                Last Update: 16/11/93
C.
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      INTEGER NMXHEP
      PARAMETER (NMXHEP=2000)
      INTEGER IDHEP,ISTHEP,JDAHEP,JMOHEP,NEVHEP,NHEP
      REAL PHEP,VHEP
      COMMON/HEPEVT/NEVHEP,NHEP,ISTHEP(NMXHEP),IDHEP(NMXHEP),
     &JMOHEP(2,NMXHEP),JDAHEP(2,NMXHEP),PHEP(5,NMXHEP),VHEP(4,NMXHEP)
      INTEGER NMXPHO
      PARAMETER (NMXPHO=2000)
      INTEGER IDPHO,ISTPHO,JDAPHO,JMOPHO,NEVPHO,NPHO
      REAL PPHO,VPHO
      COMMON/PHOEVT/NEVPHO,NPHO,ISTPHO(NMXPHO),IDPHO(NMXPHO),
     &JMOPHO(2,NMXPHO),JDAPHO(2,NMXPHO),PPHO(5,NMXPHO),VPHO(4,NMXPHO)
      INTEGER IP,IP2,I,FIRST,LAST,LL,NA
      LOGICAL BOOST
      INTEGER J,NHEP0
      DOUBLE PRECISION BET(3),GAM,PB
      COMMON /PHOCMS/ BET,GAM
      LOGICAL INTERF,ISEC,IFTOP
      REAL FINT,FSEC
      COMMON /PHOKEY/ INTERF,FINT,ISEC,FSEC,IFTOP
C--
C let's calculate size of the little common entry
        FIRST=JDAHEP(1,IP)
        LAST =JDAHEP(2,IP)
        NPHO=3+LAST-FIRST+NHEP-NHEP0
        NEVPHO=NPHO
C let's take in decaying particle
           IDPHO(1)=IDHEP(IP)
           JDAPHO(1,1)=3
           JDAPHO(2,1)=3+LAST-FIRST
           DO I=1,5
             PPHO(I,1)=PHEP(I,IP)
           ENDDO
C let's take in eventual second mother
         IP2=JMOHEP(2,JDAHEP(1,IP))
         IF((IP2.NE.0).AND.(IP2.NE.IP)) THEN
           IDPHO(2)=IDHEP(IP2)
           JDAPHO(1,2)=3
           JDAPHO(2,2)=3+LAST-FIRST
           DO I=1,5
             PPHO(I,2)=PHEP(I,IP2)
           ENDDO
         ELSE
           IDPHO(2)=0
           DO I=1,5
             PPHO(I,2)=0.0
           ENDDO
         ENDIF
C let's take in daughters
        DO LL=0,LAST-FIRST
           IDPHO(3+LL)=IDHEP(FIRST+LL)
           JMOPHO(1,3+LL)=JMOHEP(1,FIRST+LL)
           IF (JMOHEP(1,FIRST+LL).EQ.IP) JMOPHO(1,3+LL)=1
           DO I=1,5
             PPHO(I,3+LL)=PHEP(I,FIRST+LL)
           ENDDO
        ENDDO
        IF (NHEP.GT.NHEP0) THEN
C let's take in illegitimate daughters
        NA=3+LAST-FIRST
        DO LL=1,NHEP-NHEP0
           IDPHO(NA+LL)=IDHEP(NHEP0+LL)
           JMOPHO(1,NA+LL)=JMOHEP(1,NHEP0+LL)
           IF (JMOHEP(1,NHEP0+LL).EQ.IP) JMOPHO(1,NA+LL)=1
           DO I=1,5
             PPHO(I,NA+LL)=PHEP(I,NHEP0+LL)
           ENDDO
        ENDDO
C--        there is NHEP-NHEP0 daugters more.
           JDAPHO(2,1)=3+LAST-FIRST+NHEP-NHEP0
        ENDIF
        CALL PHLUPA(1)
C special case of t tbar production process
        IF(IFTOP) CALL PHOTWO(0)
        BOOST=.FALSE.
C--   Check whether parent is in its rest frame...
      IF (     (ABS(PPHO(4,1)-PPHO(5,1)).GT.PPHO(5,1)*1.E-8)
     $    .AND.(PPHO(5,1).NE.0))                            THEN
        BOOST=.TRUE.
C--
C--   Boost daughter particles to rest frame of parent...
C--   Resultant neutral system already calculated in rest frame !
        DO 10 J=1,3
   10   BET(J)=-PPHO(J,1)/PPHO(5,1)
        GAM=PPHO(4,1)/PPHO(5,1)
        DO 30 I=JDAPHO(1,1),JDAPHO(2,1)
          PB=BET(1)*PPHO(1,I)+BET(2)*PPHO(2,I)+BET(3)*PPHO(3,I)
          DO 20 J=1,3
   20     PPHO(J,I)=PPHO(J,I)+BET(J)*(PPHO(4,I)+PB/(GAM+1.))
   30   PPHO(4,I)=GAM*PPHO(4,I)+PB
C--    Finally boost mother as well
          I=1
          PB=BET(1)*PPHO(1,I)+BET(2)*PPHO(2,I)+BET(3)*PPHO(3,I)
          DO J=1,3
            PPHO(J,I)=PPHO(J,I)+BET(J)*(PPHO(4,I)+PB/(GAM+1.))
          ENDDO
          PPHO(4,I)=GAM*PPHO(4,I)+PB
      ENDIF
C special case of t tbar production process
        IF(IFTOP) CALL PHOTWO(1)
      CALL PHLUPA(2)
      END
      SUBROUTINE PHOTWO(MODE)
C.----------------------------------------------------------------------
C.
C.    PHOTWO:   PHOtos but TWO mothers allowed
C.
C.    Purpose:  Combines two mothers into one in /PHOEVT/
C.              necessary eg in case of g g (q qbar) --> t tbar
C.
C.    Input Parameters: Common /PHOEVT/ (/PHOCMS/)
C.
C.    Output Parameters:  Common /PHOEVT/, (stored mothers)
C.
C.    Author(s):  Z. Was                          Created at:  5/08/93
C.                                                Last Update:10/08/93
C.
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      INTEGER NMXPHO
      PARAMETER (NMXPHO=2000)
      INTEGER IDPHO,ISTPHO,JDAPHO,JMOPHO,NEVPHO,NPHO
      REAL PPHO,VPHO
      COMMON/PHOEVT/NEVPHO,NPHO,ISTPHO(NMXPHO),IDPHO(NMXPHO),
     &JMOPHO(2,NMXPHO),JDAPHO(2,NMXPHO),PPHO(5,NMXPHO),VPHO(4,NMXPHO)
      DOUBLE PRECISION BET(3),GAM
      COMMON /PHOCMS/ BET,GAM
      INTEGER I,MODE
      REAL MPASQR
      LOGICAL IFRAD
C logical IFRAD is used to tag cases when two mothers may be
C merged to the sole one.
C So far used in case:
C                      1) of t tbar production
C
C t tbar case
      IF(MODE.EQ.0) THEN
       IFRAD=(IDPHO(1).EQ.21).AND.(IDPHO(2).EQ.21)
       IFRAD=IFRAD.OR.(IDPHO(1).EQ.-IDPHO(2).AND.ABS(IDPHO(1)).LE.6)
       IFRAD=IFRAD
     &       .AND.(ABS(IDPHO(3)).EQ.6).AND.(ABS(IDPHO(4)).EQ.6)
        MPASQR= (PPHO(4,1)+PPHO(4,2))**2-(PPHO(3,1)+PPHO(3,2))**2
     &          -(PPHO(2,1)+PPHO(2,2))**2-(PPHO(1,1)+PPHO(1,2))**2
       IFRAD=IFRAD.AND.(MPASQR.GT.0.0)
       IF(IFRAD) THEN
c.....combining first and second mother
            DO I=1,4
            PPHO(I,1)=PPHO(I,1)+PPHO(I,2)
            ENDDO
            PPHO(5,1)=SQRT(MPASQR)
c.....removing second mother,
            DO I=1,5
              PPHO(I,2)=0.0
            ENDDO
       ENDIF
      ELSE
C boosting of the mothers to the reaction frame not implemented yet.
C to do it in mode 0 original mothers have to be stored in new common (?)
C and in mode 1 boosted to cms.
      ENDIF
      END
      SUBROUTINE PHOOUT(IP,BOOST,NHEP0)
C.----------------------------------------------------------------------
C.
C.    PHOOUT:   PHOtos OUTput
C.
C.    Purpose:  copies back IP branch of the common /HEPEVT/ from /PHOEVT/
C.              moves branch back from its CMS system.
C.
C.    Input Parameters:       IP:  pointer of particle starting branch
C.                                 to be given back.
C.                        BOOST:   Flag whether boost to CMS was or was
C     .                            not performed.
C.
C.    Output Parameters:  Common /PHOEVT/,
C.
C.    Author(s):  Z. Was                          Created at:  24/05/93
C.                                                Last Update:
C.
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      INTEGER NMXHEP
      PARAMETER (NMXHEP=2000)
      INTEGER IDHEP,ISTHEP,JDAHEP,JMOHEP,NEVHEP,NHEP
      REAL PHEP,VHEP
      COMMON/HEPEVT/NEVHEP,NHEP,ISTHEP(NMXHEP),IDHEP(NMXHEP),
     &JMOHEP(2,NMXHEP),JDAHEP(2,NMXHEP),PHEP(5,NMXHEP),VHEP(4,NMXHEP)
      INTEGER NMXPHO
      PARAMETER (NMXPHO=2000)
      INTEGER IDPHO,ISTPHO,JDAPHO,JMOPHO,NEVPHO,NPHO
      REAL PPHO,VPHO
      COMMON/PHOEVT/NEVPHO,NPHO,ISTPHO(NMXPHO),IDPHO(NMXPHO),
     &JMOPHO(2,NMXPHO),JDAPHO(2,NMXPHO),PPHO(5,NMXPHO),VPHO(4,NMXPHO)
      INTEGER IP,LL,FIRST,LAST,I
      LOGICAL BOOST
      INTEGER NN,J,K,NHEP0,NA
      DOUBLE PRECISION BET(3),GAM,PB
      COMMON /PHOCMS/ BET,GAM
      IF(NPHO.EQ.NEVPHO) RETURN
C--   When parent was not in its rest-frame, boost back...
      CALL PHLUPA(10)
      IF (BOOST) THEN
        DO 110 J=JDAPHO(1,1),JDAPHO(2,1)
          PB=-BET(1)*PPHO(1,J)-BET(2)*PPHO(2,J)-BET(3)*PPHO(3,J)
          DO 100 K=1,3
  100     PPHO(K,J)=PPHO(K,J)-BET(K)*(PPHO(4,J)+PB/(GAM+1.))
  110   PPHO(4,J)=GAM*PPHO(4,J)+PB
C--   ...boost photon, or whatever else has shown up
        DO NN=NEVPHO+1,NPHO
          PB=-BET(1)*PPHO(1,NN)-BET(2)*PPHO(2,NN)-BET(3)*PPHO(3,NN)
          DO 120 K=1,3
  120     PPHO(K,NN)=PPHO(K,NN)-BET(K)*(PPHO(4,NN)+PB/(GAM+1.))
          PPHO(4,NN)=GAM*PPHO(4,NN)+PB
        ENDDO
      ENDIF
        FIRST=JDAHEP(1,IP)
        LAST =JDAHEP(2,IP)
C let's take in original daughters
        DO LL=0,LAST-FIRST
         IDHEP(FIRST+LL) = IDPHO(3+LL)
           DO I=1,5
             PHEP(I,FIRST+LL) = PPHO(I,3+LL)
           ENDDO
        ENDDO
C let's take newcomers to the end of HEPEVT.
        NA=3+LAST-FIRST
        DO LL=1,NPHO-NA
         IDHEP(NHEP0+LL) = IDPHO(NA+LL)
         ISTHEP(NHEP0+LL)=ISTPHO(NA+LL)
         JMOHEP(1,NHEP0+LL)=IP
         JMOHEP(2,NHEP0+LL)=JMOHEP(2,JDAHEP(1,IP))
         JDAHEP(1,NHEP0+LL)=0
         JDAHEP(2,NHEP0+LL)=0
           DO I=1,5
             PHEP(I,NHEP0+LL) = PPHO(I,NA+LL)
           ENDDO
        ENDDO
        NHEP=NHEP+NPHO-NEVPHO
        CALL PHLUPA(20)
      END
      SUBROUTINE PHOCHK(JFIRST)
C.----------------------------------------------------------------------
C.
C.    PHOCHK:   checking branch.
C.
C.    Purpose:  checks whether particles in the common block /PHOEVT/
C.              can be served by PHOMAK.
C.              JFIRST is the position in /HEPEVT/ (!) of the first daughter
C.              of sub-branch under action.
C.
C.
C.    Author(s):  Z. Was                           Created at: 22/10/92
C.                                                Last Update: 16/10/93
C.
C.----------------------------------------------------------------------
C     ********************
C--   IMPLICIT NONE
      INTEGER NMXPHO
      PARAMETER (NMXPHO=2000)
      INTEGER IDPHO,ISTPHO,JDAPHO,JMOPHO,NEVPHO,NPHO
      REAL PPHO,VPHO
      COMMON/PHOEVT/NEVPHO,NPHO,ISTPHO(NMXPHO),IDPHO(NMXPHO),
     &JMOPHO(2,NMXPHO),JDAPHO(2,NMXPHO),PPHO(5,NMXPHO),VPHO(4,NMXPHO)
      LOGICAL CHKIF
      COMMON/PHOIF/CHKIF(NMXPHO)
      INTEGER NMXHEP
      PARAMETER (NMXHEP=2000)
      LOGICAL QEDRAD
      COMMON/PHOQED/QEDRAD(NMXHEP)
      INTEGER JFIRST
      LOGICAL F
      INTEGER IDABS,NLAST,I,IPPAR
      LOGICAL INTERF,ISEC,IFTOP
      REAL FINT,FSEC
      COMMON /PHOKEY/ INTERF,FINT,ISEC,FSEC,IFTOP
      LOGICAL IFRAD
      INTEGER IDENT,K
C these are OK .... if you do not like somebody else, add here.
      F(IDABS)=
     &     ( ((IDABS.GT.9).AND.(IDABS.LE.40)) .OR. (IDABS.GT.100) )
     & .AND.(IDABS.NE.21)
     $ .AND.(IDABS.NE.2101).AND.(IDABS.NE.3101).AND.(IDABS.NE.3201)
     & .AND.(IDABS.NE.1103).AND.(IDABS.NE.2103).AND.(IDABS.NE.2203)
     & .AND.(IDABS.NE.3103).AND.(IDABS.NE.3203).AND.(IDABS.NE.3303)
C
      NLAST = NPHO
C
      IPPAR=1
C checking for good particles
      DO 10 I=IPPAR,NLAST
      IDABS    = ABS(IDPHO(I))
C possibly call on PHZODE is a dead (to be omitted) code.
      CHKIF(I)= F(IDABS)       .AND.F(ABS(IDPHO(1)))
     &  .AND.   (IDPHO(2).EQ.0)
      IF(I.GT.2) CHKIF(I)=CHKIF(I).AND.QEDRAD(JFIRST+I-IPPAR-2)
 10   CONTINUE
C--
C now we go to special cases, where CHKIF(I) will be overwritten
C--
      IF(IFTOP) THEN
C special case of top pair production
        DO  K=JDAPHO(2,1),JDAPHO(1,1),-1
           IF(IDPHO(K).NE.22) THEN
             IDENT=K
             GOTO 15
           ENDIF
        ENDDO
 15     CONTINUE
        IFRAD=((IDPHO(1).EQ.21).AND.(IDPHO(2).EQ.21))
     &  .OR. ((ABS(IDPHO(1)).LE.6).AND.((IDPHO(2)).EQ.(-IDPHO(1))))
        IFRAD=IFRAD
     &        .AND.(ABS(IDPHO(3)).EQ.6).AND.((IDPHO(4)).EQ.(-IDPHO(3)))
     &        .AND.(IDENT.EQ.4)
        IF(IFRAD) THEN
           DO 20 I=IPPAR,NLAST
           CHKIF(I)= .TRUE.
           IF(I.GT.2) CHKIF(I)=CHKIF(I).AND.QEDRAD(JFIRST+I-IPPAR-2)
 20        CONTINUE
        ENDIF
      ENDIF
C--
C--
      IF(IFTOP) THEN
C special case of top decay
        DO  K=JDAPHO(2,1),JDAPHO(1,1),-1
           IF(IDPHO(K).NE.22) THEN
             IDENT=K
             GOTO 25
           ENDIF
        ENDDO
 25     CONTINUE
        IFRAD=((ABS(IDPHO(1)).EQ.6).AND.(IDPHO(2).EQ.0))
        IFRAD=IFRAD
     &        .AND.((ABS(IDPHO(3)).EQ.24).AND.(ABS(IDPHO(4)).EQ.5)
     &        .OR.(ABS(IDPHO(3)).EQ.5).AND.(ABS(IDPHO(4)).EQ.24))
     &        .AND.(IDENT.EQ.4)
        IF(IFRAD) THEN
           DO 30 I=IPPAR,NLAST
           CHKIF(I)= .TRUE.
           IF(I.GT.2) CHKIF(I)=CHKIF(I).AND.QEDRAD(JFIRST+I-IPPAR-2)
 30        CONTINUE
        ENDIF
      ENDIF
C--
C--
      END
      SUBROUTINE PHTYPE(ID)
C.----------------------------------------------------------------------
C.
C.    PHTYPE:   Central manadgement routine.
C.
C.    Purpose:   defines what kind of the
C.              actions will be performed at point ID.
C.
C.    Input Parameters:       ID:  pointer of particle starting branch
C.                                 in /HEPEVT/ to be treated.
C.
C.    Output Parameters:  Common /HEPEVT/.
C.
C.    Author(s):  Z. Was                          Created at:  24/05/93
C.                                                Last Update: 01/10/93
C.
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      INTEGER NMXHEP
      PARAMETER (NMXHEP=2000)
      INTEGER IDHEP,ISTHEP,JDAHEP,JMOHEP,NEVHEP,NHEP
      REAL PHEP,VHEP
      COMMON/HEPEVT/NEVHEP,NHEP,ISTHEP(NMXHEP),IDHEP(NMXHEP),
     &JMOHEP(2,NMXHEP),JDAHEP(2,NMXHEP),PHEP(5,NMXHEP),VHEP(4,NMXHEP)
      LOGICAL INTERF,ISEC,IFTOP
      REAL FINT,FSEC
      COMMON /PHOKEY/ INTERF,FINT,ISEC,FSEC,IFTOP
      INTEGER ID,NHEP0
      LOGICAL IPAIR
      REAL RN,PHORAN
      INTEGER WTDUM
C--
      IPAIR=.TRUE.
C--   Check decay multiplicity..
      IF (JDAHEP(1,ID).EQ.0) RETURN
C      IF (JDAHEP(1,ID).EQ.JDAHEP(2,ID)) RETURN
C--
      NHEP0=NHEP
C--
      IF(ISEC) THEN
C-- double photon emission
        FSEC=1.0
        RN=PHORAN(WTDUM)
        IF (RN.GE.0.5) THEN
          CALL PHOMAK(ID,NHEP0)
          CALL PHOMAK(ID,NHEP0)
        ENDIF
      ELSE
C-- single photon emission
        FSEC=1.0
        CALL PHOMAK(ID,NHEP0)
      ENDIF
C--
C-- electron positron pair (coomented out for a while
C      IF (IPAIR) CALL PHOPAR(ID,NHEP0)
      END
      SUBROUTINE PHOMAK(IPPAR,NHEP0)
C.----------------------------------------------------------------------
C.
C.    PHOMAK:   PHOtos MAKe
C.
C.    Purpose:  Single or double bremstrahlung radiative corrections
C.              are generated in  the decay of the IPPAR-th particle in
C.              the  HEP common /HEPEVT/. Example of the use of
C.              general tools.
C.
C.    Input Parameter:    IPPAR:  Pointer   to   decaying  particle  in
C.                                /HEPEVT/ and the common itself
C.
C.    Output Parameters:  Common  /HEPEVT/, either  with  or  without a
C.                                particles added.
C.
C.    Author(s):  Z. Was,                         Created at:  26/05/93
C.                                                Last Update:
C.
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      DOUBLE PRECISION DATA
      REAL PHORAN
      INTEGER IP,IPPAR,NCHARG
      INTEGER WTDUM,IDUM,NHEP0
      INTEGER NCHARB,NEUDAU
      REAL RN,WT,PHINT
      LOGICAL BOOST
      INTEGER NMXHEP
      PARAMETER (NMXHEP=2000)
      INTEGER IDHEP,ISTHEP,JDAHEP,JMOHEP,NEVHEP,NHEP
      REAL PHEP,VHEP
      COMMON/HEPEVT/NEVHEP,NHEP,ISTHEP(NMXHEP),IDHEP(NMXHEP),
     &JMOHEP(2,NMXHEP),JDAHEP(2,NMXHEP),PHEP(5,NMXHEP),VHEP(4,NMXHEP)
      LOGICAL INTERF,ISEC,IFTOP
      REAL FINT,FSEC
      COMMON /PHOKEY/ INTERF,FINT,ISEC,FSEC,IFTOP
C--
      IP=IPPAR
      IDUM=1
      NCHARG=0
C--
        CALL PHOIN(IP,BOOST,NHEP0)
        CALL PHOCHK(JDAHEP(1,IP))
        WT=0.0
        CALL PHOPRE(1,WT,NEUDAU,NCHARB)
        IF (WT.EQ.0.0) RETURN
        RN=PHORAN(WTDUM)
C PHODO is calling PHORAN, thus change of series if it is moved before if.
        CALL PHODO(1,NCHARB,NEUDAU)
        IF (INTERF) WT=WT*PHINT(IDUM)/FINT
        DATA=WT
        IF (WT.GT.1.0) CALL PHOERR(3,'WT_INT',DATA)
      IF (RN.LE.WT) THEN
        CALL PHOOUT(IP,BOOST,NHEP0)
      ENDIF
      RETURN
      END
      FUNCTION PHINT(IDUM)
C.----------------------------------------------------------------------
C.
C.    PHINT:   PHotos INTerference
C.
C.    Purpose:  Calculates interference between emission of photons from
C.              different possible chaged daughters stored in
C.              the  HEP common /PHOEVT/.
C.
C.    Input Parameter:    commons /PHOEVT/ /PHOMOM/ /PHOPHS/
C.
C.
C.    Output Parameters:
C.
C.
C.    Author(s):  Z. Was,                         Created at:  10/08/93
C.                                                Last Update:
C.
C.----------------------------------------------------------------------

C--   IMPLICIT NONE
      REAL PHINT
      REAL PHOCHA
      INTEGER IDUM
      INTEGER NMXPHO
      PARAMETER (NMXPHO=2000)
      INTEGER IDPHO,ISTPHO,JDAPHO,JMOPHO,NEVPHO,NPHO
      REAL PPHO,VPHO
      COMMON/PHOEVT/NEVPHO,NPHO,ISTPHO(NMXPHO),IDPHO(NMXPHO),
     &JMOPHO(2,NMXPHO),JDAPHO(2,NMXPHO),PPHO(5,NMXPHO),VPHO(4,NMXPHO)
      DOUBLE PRECISION MCHSQR,MNESQR
      REAL PNEUTR
      COMMON/PHOMOM/MCHSQR,MNESQR,PNEUTR(5)
      DOUBLE PRECISION COSTHG,SINTHG
      REAL XPHMAX,XPHOTO
      COMMON/PHOPHS/XPHMAX,XPHOTO,COSTHG,SINTHG
      REAL MPASQR,XX,BETA
      LOGICAL IFINT
      INTEGER K,IDENT
C
      DO  K=JDAPHO(2,1),JDAPHO(1,1),-1
         IF(IDPHO(K).NE.22) THEN
           IDENT=K
           GOTO 20
         ENDIF
      ENDDO
 20   CONTINUE
C check if there is a photon
      IFINT= NPHO.GT.IDENT
C check if it is two body + gammas reaction
      IFINT= IFINT.AND.(IDENT-JDAPHO(1,1)).EQ.1
C check if two body was particle antiparticle
      IFINT= IFINT.AND.IDPHO(JDAPHO(1,1)).EQ.-IDPHO(IDENT)
C check if particles were charged
      IFINT= IFINT.AND.PHOCHA(IDENT).NE.0
C calculates interference weight contribution
      IF(IFINT) THEN
        MPASQR = PPHO(5,1)**2
        XX=4.*MCHSQR/MPASQR*(1.-XPHOTO)/(1.-XPHOTO+(MCHSQR-MNESQR)/
     &     MPASQR)**2
         BETA=SQRT(1.-XX)
         PHINT  = 2D0/(1D0+COSTHG**2*BETA**2)
      ELSE
         PHINT  = 1D0
      ENDIF
      END
      SUBROUTINE PHOPRE(IPARR,WT,NEUDAU,NCHARB)
C.----------------------------------------------------------------------
C.
C.    PHOTOS:   Photon radiation in decays
C.
C.    Purpose:  Order (alpha) radiative corrections  are  generated  in
C.              the decay of the IPPAR-th particle in the HEP-like
C.              common /PHOEVT/.  Photon radiation takes place from one
C.              of the charged daughters of the decaying particle IPPAR
C.              WT is calculated, eventual rejection will be performed
C.              later after inclusion of interference weight.
C.
C.    Input Parameter:    IPPAR:  Pointer   to   decaying  particle  in
C.                                /PHOEVT/ and the common itself,
C.
C.    Output Parameters:  Common  /PHOEVT/, either  with  or  without a
C.                                photon(s) added.
C.                        WT      weight of the configuration
C.
C.    Author(s):  Z. Was, B. van Eijk             Created at:  26/11/89
C.                                                Last Update: 26/05/93
C.
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      DOUBLE PRECISION MINMAS,MPASQR,MCHREN
      DOUBLE PRECISION BETA,EPS,DEL1,DEL2,DATA
      REAL PHOCHA,PHOSPI,PHORAN,PHOCOR,MASSUM
      INTEGER IP,IPARR,IPPAR,I,J,ME,NCHARG,NEUPOI,NLAST,THEDUM
      INTEGER IDABS,IDUM
      INTEGER NCHARB,NEUDAU
      REAL WT
      INTEGER NMXPHO
      PARAMETER (NMXPHO=2000)
      INTEGER IDPHO,ISTPHO,JDAPHO,JMOPHO,NEVPHO,NPHO
      REAL PPHO,VPHO
      COMMON/PHOEVT/NEVPHO,NPHO,ISTPHO(NMXPHO),IDPHO(NMXPHO),
     &JMOPHO(2,NMXPHO),JDAPHO(2,NMXPHO),PPHO(5,NMXPHO),VPHO(4,NMXPHO)
      LOGICAL CHKIF
      COMMON/PHOIF/CHKIF(NMXPHO)
      INTEGER CHAPOI(NMXPHO)
      DOUBLE PRECISION MCHSQR,MNESQR
      REAL PNEUTR
      COMMON/PHOMOM/MCHSQR,MNESQR,PNEUTR(5)
      DOUBLE PRECISION COSTHG,SINTHG
      REAL XPHMAX,XPHOTO
      COMMON/PHOPHS/XPHMAX,XPHOTO,COSTHG,SINTHG
      REAL ALPHA,XPHCUT
      COMMON/PHOCOP/ALPHA,XPHCUT
      INTEGER IREP
      REAL PROBH,CORWT,XF
      COMMON/PHOPRO/IREP,PROBH,CORWT,XF
C--
      IPPAR=IPARR
C--   Store pointers for cascade treatement...
      IP=IPPAR
      NLAST=NPHO
      IDUM=1
C--
C--   Check decay multiplicity..
      IF (JDAPHO(1,IP).EQ.0) RETURN
C--
C--   Loop over daughters, determine charge multiplicity
   10 NCHARG=0
      IREP=0
      MINMAS=0.
      MASSUM=0.
      DO 20 I=JDAPHO(1,IP),JDAPHO(2,IP)
C--
C--
C--   Exclude marked particles, quarks and gluons etc...
        IDABS=ABS(IDPHO(I))
        IF (CHKIF(I-JDAPHO(1,IP)+3)) THEN
          IF (PHOCHA(IDPHO(I)).NE.0) THEN
            NCHARG=NCHARG+1
            IF (NCHARG.GT.NMXPHO) THEN
              DATA=NCHARG
              CALL PHOERR(1,'PHOTOS',DATA)
            ENDIF
            CHAPOI(NCHARG)=I
          ENDIF
          MINMAS=MINMAS+PPHO(5,I)**2
        ENDIF
        MASSUM=MASSUM+PPHO(5,I)
   20 CONTINUE
      IF (NCHARG.NE.0) THEN
C--
C--   Check that sum of daughter masses does not exceed parent mass
        IF ((PPHO(5,IP)-MASSUM)/PPHO(5,IP).GT.2.*XPHCUT) THEN
C--
C--   Order  charged  particles  according  to decreasing mass, this  to
C--   increase efficiency (smallest mass is treated first).
          IF (NCHARG.GT.1) CALL PHOOMA(1,NCHARG,CHAPOI)
C--
   30       CONTINUE
            DO 70 J=1,3
   70       PNEUTR(J)=-PPHO(J,CHAPOI(NCHARG))
            PNEUTR(4)=PPHO(5,IP)-PPHO(4,CHAPOI(NCHARG))
C--
C--   Calculate  invariant  mass of 'neutral' etc. systems
          MPASQR=PPHO(5,IP)**2
          MCHSQR=PPHO(5,CHAPOI(NCHARG))**2
          IF ((JDAPHO(2,IP)-JDAPHO(1,IP)).EQ.1) THEN
            NEUPOI=JDAPHO(1,IP)
            IF (NEUPOI.EQ.CHAPOI(NCHARG)) NEUPOI=JDAPHO(2,IP)
            MNESQR=PPHO(5,NEUPOI)**2
            PNEUTR(5)=PPHO(5,NEUPOI)
          ELSE
            MNESQR=PNEUTR(4)**2-PNEUTR(1)**2-PNEUTR(2)**2-PNEUTR(3)**2
            MNESQR=MAX(MNESQR,MINMAS-MCHSQR)
            PNEUTR(5)=SQRT(MNESQR)
          ENDIF
C--
C--   Determine kinematical limit...
          XPHMAX=(MPASQR-(PNEUTR(5)+PPHO(5,CHAPOI(NCHARG)))**2)/MPASQR
C--
C--   Photon energy fraction...
          CALL PHOENE(MPASQR,MCHREN,BETA,IDPHO(CHAPOI(NCHARG)))
C--
C--   Energy fraction not too large (very seldom) ? Define angle.
          IF ((XPHOTO.LT.XPHCUT).OR.(XPHOTO.GT.XPHMAX)) THEN
C--
C--   No radiation was accepted, check  for more daughters  that may ra-
C--   diate and correct radiation probability...
            NCHARG=NCHARG-1
            IF (NCHARG.GT.0) THEN
              IREP=IREP+1
              GOTO 30
            ENDIF
          ELSE
C--
C--   Angle is generated  in  the  frame defined  by  charged vector and
C--   PNEUTR, distribution is taken in the infrared limit...
            EPS=MCHREN/(1.+BETA)
C--
C--   Calculate sin(theta) and cos(theta) from interval variables
            DEL1=(2.-EPS)*(EPS/(2.-EPS))**PHORAN(THEDUM)
            DEL2=2.-DEL1
            COSTHG=(1.-DEL1)/BETA
            SINTHG=SQRT(DEL1*DEL2-MCHREN)/BETA
C--
C--   Determine spin of  particle and construct code  for matrix element
            ME=2.*PHOSPI(IDPHO(CHAPOI(NCHARG)))+1.
C--
C--   Weighting procedure with 'exact' matrix element, reconstruct kine-
C--   matics for photon, neutral and charged system and update /PHOEVT/.
C--   Find pointer to the first component of 'neutral' system
      DO  I=JDAPHO(1,IP),JDAPHO(2,IP)
        IF (I.NE.CHAPOI(NCHARG)) THEN
          NEUDAU=I
          GOTO 51
        ENDIF
      ENDDO
C--
C--   Pointer not found...
      DATA=NCHARG
      CALL PHOERR(5,'PHOKIN',DATA)
 51   CONTINUE
      NCHARB=CHAPOI(NCHARG)
      NCHARB=NCHARB-JDAPHO(1,IP)+3
      NEUDAU=NEUDAU-JDAPHO(1,IP)+3
        WT=PHOCOR(MPASQR,MCHREN,ME)

          ENDIF
        ELSE
          DATA=PPHO(5,IP)-MASSUM
          CALL PHOERR(10,'PHOTOS',DATA)
        ENDIF
      ENDIF
C--
      RETURN
      END
      SUBROUTINE PHOOMA(IFIRST,ILAST,POINTR)
C.----------------------------------------------------------------------
C.
C.    PHOTOS:   PHOton radiation in decays Order MAss vector
C.
C.    Purpose:  Order  the  contents  of array 'POINTR' according to the
C.              decreasing value in the array 'MASS'.
C.
C.    Input Parameters:  IFIRST, ILAST:  Pointers  to  the  vector loca-
C.                                       tion be sorted,
C.                       POINTR:         Unsorted array with pointers to
C.                                       /PHOEVT/.
C.
C.    Output Parameter:  POINTR:         Sorted arrays  with  respect to
C.                                       particle mass 'PPHO(5,*)'.
C.
C.    Author(s):  B. van Eijk                     Created at:  28/11/89
C.                                                Last Update: 27/05/93
C.
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      INTEGER NMXPHO
      PARAMETER (NMXPHO=2000)
      INTEGER IDPHO,ISTPHO,JDAPHO,JMOPHO,NEVPHO,NPHO
      REAL PPHO,VPHO
      COMMON/PHOEVT/NEVPHO,NPHO,ISTPHO(NMXPHO),IDPHO(NMXPHO),
     &JMOPHO(2,NMXPHO),JDAPHO(2,NMXPHO),PPHO(5,NMXPHO),VPHO(4,NMXPHO)
      INTEGER IFIRST,ILAST,I,J,BUFPOI,POINTR(NMXPHO)
      REAL BUFMAS,MASS(NMXPHO)
      IF (IFIRST.EQ.ILAST) RETURN
C--
C--   Copy particle masses
      DO 10 I=IFIRST,ILAST
   10 MASS(I)=PPHO(5,POINTR(I))
C--
C--   Order the masses in a decreasing series
      DO 30 I=IFIRST,ILAST-1
        DO 20 J=I+1,ILAST
          IF (MASS(J).LE.MASS(I)) GOTO 20
          BUFPOI=POINTR(J)
          POINTR(J)=POINTR(I)
          POINTR(I)=BUFPOI
          BUFMAS=MASS(J)
          MASS(J)=MASS(I)
          MASS(I)=BUFMAS
   20   CONTINUE
   30 CONTINUE
      RETURN
      END
      SUBROUTINE PHOENE(MPASQR,MCHREN,BETA,IDENT)
C.----------------------------------------------------------------------
C.
C.    PHOTOS:   PHOton radiation in decays calculation  of photon ENErgy
C.              fraction
C.
C.    Purpose:  Subroutine  returns  photon  energy fraction (in (parent
C.              mass)/2 units) for the decay bremsstrahlung.
C.
C.    Input Parameters:  MPASQR:  Mass of decaying system squared,
C.                       XPHCUT:  Minimum energy fraction of photon,
C.                       XPHMAX:  Maximum energy fraction of photon.
C.
C.    Output Parameter:  MCHREN:  Renormalised mass squared,
C.                       BETA:    Beta factor due to renormalisation,
C.                       XPHOTO:  Photon energy fraction,
C.                       XF:      Correction factor for PHOFAC.
C.
C.    Author(s):  S. Jadach, Z. Was               Created at:  01/01/89
C.                B. van Eijk                     Last Update: 26/03/93
C.
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      DOUBLE PRECISION MPASQR,MCHREN,BIGLOG,BETA,DATA
      INTEGER IWT1,IRN,IWT2
      REAL PRSOFT,PRHARD,PHORAN,PHOFAC
      DOUBLE PRECISION MCHSQR,MNESQR
      REAL PNEUTR
      INTEGER IDENT
      REAL PHOCHA
      COMMON/PHOMOM/MCHSQR,MNESQR,PNEUTR(5)
      DOUBLE PRECISION COSTHG,SINTHG
      REAL XPHMAX,XPHOTO
      COMMON/PHOPHS/XPHMAX,XPHOTO,COSTHG,SINTHG
      REAL ALPHA,XPHCUT
      COMMON/PHOCOP/ALPHA,XPHCUT
      REAL PI,TWOPI
      COMMON/PHPICO/PI,TWOPI
      INTEGER IREP
      REAL PROBH,CORWT,XF
      COMMON/PHOPRO/IREP,PROBH,CORWT,XF
      LOGICAL INTERF,ISEC,IFTOP
      REAL FINT,FSEC
      COMMON /PHOKEY/ INTERF,FINT,ISEC,FSEC,IFTOP
C--
      IF (XPHMAX.LE.XPHCUT) THEN
        XPHOTO=0.0
        RETURN
      ENDIF
C--   Probabilities for hard and soft bremstrahlung...
      MCHREN=4.*MCHSQR/MPASQR/(1.+MCHSQR/MPASQR)**2
      BETA=SQRT(1.-MCHREN)
      BIGLOG=LOG(MPASQR/MCHSQR*(1.+BETA)**2/4.*(1.+MCHSQR/MPASQR)**2)
      PRHARD=ALPHA/PI/BETA*BIGLOG*(LOG(XPHMAX/XPHCUT)-.75+XPHCUT/
     &XPHMAX-.25*XPHCUT**2/XPHMAX**2)
      PRHARD=PRHARD*PHOCHA(IDENT)**2*FINT*FSEC
      IF (IREP.EQ.0) PROBH=0.
      PRHARD=PRHARD*PHOFAC(0)
      PROBH=PRHARD
      PRSOFT=1.-PRHARD
C--
C--   Check on kinematical bounds
      IF (PRSOFT.LT.0.1) THEN
        DATA=PRSOFT
        CALL PHOERR(2,'PHOENE',DATA)
      ENDIF
      IF (PHORAN(IWT1).LT.PRSOFT) THEN
C--
C--   No photon... (ie. photon too soft)
        XPHOTO=0.
      ELSE
C--
C--   Hard  photon... (ie.  photon  hard enough).
C--   Calculate  Altarelli-Parisi Kernel
   10   XPHOTO=EXP(PHORAN(IRN)*LOG(XPHCUT/XPHMAX))
        XPHOTO=XPHOTO*XPHMAX
        IF (PHORAN(IWT2).GT.((1.+(1.-XPHOTO/XPHMAX)**2)/2.)) GOTO 10
      ENDIF
C--
C--   Calculate parameter for PHOFAC function
      XF=4.*MCHSQR*MPASQR/(MPASQR+MCHSQR-MNESQR)**2
      RETURN
      END
      FUNCTION PHOCOR(MPASQR,MCHREN,ME)
C.----------------------------------------------------------------------
C.
C.    PHOTOS:   PHOton radiation in decays CORrection weight from
C.              matrix elements
C.
C.    Purpose:  Calculate  photon  angle.  The reshaping functions  will
C.              have  to  depend  on the spin S of the charged particle.
C.              We define:  ME = 2 * S + 1 !
C.
C.    Input Parameters:  MPASQR:  Parent mass squared,
C.                       MCHREN:  Renormalised mass of charged system,
C.                       ME:      2 * spin + 1 determines matrix element
C.
C.    Output Parameter:  Function value.
C.
C.    Author(s):  Z. Was, B. van Eijk             Created at:  26/11/89
C.                                                Last Update: 21/03/93
C.
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      DOUBLE PRECISION MPASQR,MCHREN,BETA,XX,YY,DATA
      INTEGER ME
      REAL PHOCOR,PHOFAC,WT1,WT2,WT3
      DOUBLE PRECISION MCHSQR,MNESQR
      REAL PNEUTR
      COMMON/PHOMOM/MCHSQR,MNESQR,PNEUTR(5)
      DOUBLE PRECISION COSTHG,SINTHG
      REAL XPHMAX,XPHOTO
      COMMON/PHOPHS/XPHMAX,XPHOTO,COSTHG,SINTHG
      INTEGER IREP
      REAL PROBH,CORWT,XF
      COMMON/PHOPRO/IREP,PROBH,CORWT,XF
C--
C--   Shaping (modified by ZW)...
      XX=4.*MCHSQR/MPASQR*(1.-XPHOTO)/(1.-XPHOTO+(MCHSQR-MNESQR)/
     &MPASQR)**2
      IF (ME.EQ.1) THEN
        YY=1.
        WT3=(1.-XPHOTO/XPHMAX)/((1.+(1.-XPHOTO/XPHMAX)**2)/2.)
      ELSEIF (ME.EQ.2) THEN
        YY=0.5*(1.-XPHOTO/XPHMAX+1./(1.-XPHOTO/XPHMAX))
        WT3=1.
      ELSEIF ((ME.EQ.3).OR.(ME.EQ.4).OR.(ME.EQ.5)) THEN
        YY=1.
        WT3=(1.+(1.-XPHOTO/XPHMAX)**2-(XPHOTO/XPHMAX)**3)/(1.+(1.
     &  -XPHOTO/XPHMAX)** 2)
      ELSE
        DATA=(ME-1.)/2.
        CALL PHOERR(6,'PHOCOR',DATA)
        YY=1.
        WT3=1.
      ENDIF
      BETA=SQRT(1.-XX)
      WT1=(1.-COSTHG*SQRT(1.-MCHREN))/(1.-COSTHG*BETA)
      WT2=(1.-XX/YY/(1.-BETA**2*COSTHG**2))*(1.+COSTHG*BETA)/2.
      WT2=WT2*PHOFAC(1)
      PHOCOR=WT1*WT2*WT3
      CORWT=PHOCOR
      IF (PHOCOR.GT.1.) THEN
        DATA=PHOCOR
        CALL PHOERR(3,'PHOCOR',DATA)
      ENDIF
      RETURN
      END
      FUNCTION PHOFAC(MODE)
C.----------------------------------------------------------------------
C.
C.    PHOTOS:   PHOton radiation in decays control FACtor
C.
C.    Purpose:  This is the control function for the photon spectrum and
C.              final weighting.  It is  called  from PHOENE for genera-
C.              ting the raw photon energy spectrum (MODE=0) and in PHO-
C.              COR to scale the final weight (MODE=1).  The factor con-
C.              sists of 3 terms.  Addition of  the factor FF which mul-
C.              tiplies PHOFAC for MODE=0 and divides PHOFAC for MODE=1,
C.              does not affect  the results for  the MC generation.  An
C.              appropriate choice  for FF can speed up the calculation.
C.              Note that a too small value of FF may cause weight over-
C.              flow in PHOCOR  and will generate a warning, halting the
C.              execution.  PRX  should  be  included for repeated calls
C.              for  the  same event, allowing more particles to radiate
C.              photons.  At  the  first  call IREP=0, for  more  than 1
C.              charged  decay  products, IREP >= 1.  Thus,  PRSOFT  (no
C.              photon radiation  probability  in  the  previous  calls)
C.              appropriately scales the strength of the bremsstrahlung.
C.
C.    Input Parameters:  MODE, PROBH, XF
C.
C.    Output Parameter:  Function value
C.
C.    Author(s):  S. Jadach, Z. Was               Created at:  01/01/89
C.                B. van Eijk                     Last Update: 13/02/90
C.
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      REAL PHOFAC,FF,PRX
      INTEGER MODE
      INTEGER IREP
      REAL PROBH,CORWT,XF
      COMMON/PHOPRO/IREP,PROBH,CORWT,XF
      SAVE PRX,FF
      DATA PRX,FF/ 0., 0./
      IF (MODE.EQ.0) THEN
        IF (IREP.EQ.0) PRX=1.
        PRX=PRX/(1.-PROBH)
        FF=1.
C--
C--   Following options are not considered for the time being...
C--   (1) Good choice, but does not save very much time:
C--       FF=(1.0-SQRT(XF)/2.0)/(1.0+SQRT(XF)/2.0)
C--   (2) Taken from the blue, but works without weight overflows...
C--       FF=(1.-XF/(1-(1-SQRT(XF))**2))*(1+(1-SQRT(XF))/SQRT(1-XF))/2
        PHOFAC=FF*PRX
      ELSE
        PHOFAC=1./FF
      ENDIF
      END
      SUBROUTINE PHODO(IP,NCHARB,NEUDAU)
C.----------------------------------------------------------------------
C.
C.    PHOTOS:   PHOton radiation in  decays DOing of KINematics
C.
C.    Purpose:  Starting  from   the  charged  particle energy/momentum,
C.              PNEUTR, photon  energy  fraction and photon  angle  with
C.              respect  to  the axis formed by charged particle energy/
C.              momentum  vector  and PNEUTR, scale the energy/momentum,
C.              keeping the original direction of the neutral system  in
C.              the lab. frame untouched.
C.
C.    Input Parameters:   IP:      Pointer  to   decaying  particle   in
C.                                 /PHOEVT/  and   the   common   itself
C.                        NCHARB:  pointer to the charged radiating
C.                                 daughter in /PHOEVT/.
C.                        NEUDAU:  pointer to the first neutral daughter
C.    Output Parameters:  Common /PHOEVT/, with photon added.
C.
C.    Author(s):  Z. Was, B. van Eijk             Created at:  26/11/89
C.                                                Last Update: 27/05/93
C.
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      DOUBLE PRECISION PHOAN1,PHOAN2,ANGLE,FI1,FI3,FI4,FI5,TH1,TH3,TH4
      DOUBLE PRECISION PARNE,QNEW,QOLD,DATA
      INTEGER IP,FI3DUM,I,J,NEUDAU,FIRST,LAST
      INTEGER NCHARB
      REAL EPHOTO,PMAVIR,PHOTRI
      REAL GNEUT,PHORAN,CCOSTH,SSINTH,PVEC(4)
      INTEGER NMXPHO
      PARAMETER (NMXPHO=2000)
      INTEGER IDPHO,ISTPHO,JDAPHO,JMOPHO,NEVPHO,NPHO
      REAL PPHO,VPHO
      COMMON/PHOEVT/NEVPHO,NPHO,ISTPHO(NMXPHO),IDPHO(NMXPHO),
     &JMOPHO(2,NMXPHO),JDAPHO(2,NMXPHO),PPHO(5,NMXPHO),VPHO(4,NMXPHO)
      DOUBLE PRECISION MCHSQR,MNESQR
      REAL PNEUTR
      COMMON/PHOMOM/MCHSQR,MNESQR,PNEUTR(5)
      DOUBLE PRECISION COSTHG,SINTHG
      REAL XPHMAX,XPHOTO
      COMMON/PHOPHS/XPHMAX,XPHOTO,COSTHG,SINTHG
      REAL PI,TWOPI
      COMMON/PHPICO/PI,TWOPI
C--
      EPHOTO=XPHOTO*PPHO(5,IP)/2.
      PMAVIR=SQRT(PPHO(5,IP)*(PPHO(5,IP)-2.*EPHOTO))
C--
C--   Reconstruct  kinematics  of  charged particle  and  neutral system
      FI1=PHOAN1(PNEUTR(1),PNEUTR(2))
C--
C--   Choose axis along  z of  PNEUTR, calculate  angle  between x and y
C--   components  and z  and x-y plane and  perform Lorentz transform...
      TH1=PHOAN2(PNEUTR(3),SQRT(PNEUTR(1)**2+PNEUTR(2)**2))
      CALL PHORO3(-FI1,PNEUTR(1))
      CALL PHORO2(-TH1,PNEUTR(1))
C--
C--   Take  away  photon energy from charged particle and PNEUTR !  Thus
C--   the onshell charged particle  decays into virtual charged particle
C--   and photon.  The virtual charged  particle mass becomes:
C--   SQRT(PPHO(5,IP)*(PPHO(5,IP)-2*EPHOTO)).  Construct  new PNEUTR mo-
C--   mentum in the rest frame of the parent:
C--   1) Scaling parameters...
      QNEW=PHOTRI(PMAVIR,PNEUTR(5),PPHO(5,NCHARB))
      QOLD=PNEUTR(3)
      GNEUT=(QNEW**2+QOLD**2+MNESQR)/(QNEW*QOLD+SQRT((QNEW**2+MNESQR)*
     &(QOLD**2+MNESQR)))
      IF (GNEUT.LT.1.) THEN
        DATA=0.
        CALL PHOERR(4,'PHOKIN',DATA)
      ENDIF
      PARNE=GNEUT-SQRT(MAX(GNEUT**2-1.0,0.))
C--
C--   2) ...reductive boost...
      CALL PHOBO3(PARNE,PNEUTR)
C--
C--   ...calculate photon energy in the reduced system...
      NPHO=NPHO+1
      ISTPHO(NPHO)=1
      IDPHO(NPHO) =22
C--   Photon mother and daughter pointers !
      JMOPHO(1,NPHO)=IP
      JMOPHO(2,NPHO)=0
      JDAPHO(1,NPHO)=0
      JDAPHO(2,NPHO)=0
      PPHO(4,NPHO)=EPHOTO*PPHO(5,IP)/PMAVIR
C--
C--   ...and photon momenta
      CCOSTH=-COSTHG
      SSINTH=SINTHG
      TH3=PHOAN2(CCOSTH,SSINTH)
      FI3=TWOPI*PHORAN(FI3DUM)
      PPHO(1,NPHO)=PPHO(4,NPHO)*SINTHG*COS(FI3)
      PPHO(2,NPHO)=PPHO(4,NPHO)*SINTHG*SIN(FI3)
C--
C--   Minus sign because axis opposite direction of charged particle !
      PPHO(3,NPHO)=-PPHO(4,NPHO)*COSTHG
      PPHO(5,NPHO)=0.
C--
C--   Rotate in order to get photon along z-axis
      CALL PHORO3(-FI3,PNEUTR(1))
      CALL PHORO3(-FI3,PPHO(1,NPHO))
      CALL PHORO2(-TH3,PNEUTR(1))
      CALL PHORO2(-TH3,PPHO(1,NPHO))
      ANGLE=EPHOTO/PPHO(4,NPHO)
C--
C--   Boost to the rest frame of decaying particle
      CALL PHOBO3(ANGLE,PNEUTR(1))
      CALL PHOBO3(ANGLE,PPHO(1,NPHO))
C--
C--   Back in the parent rest frame but PNEUTR not yet oriented !
      FI4=PHOAN1(PNEUTR(1),PNEUTR(2))
      TH4=PHOAN2(PNEUTR(3),SQRT(PNEUTR(1)**2+PNEUTR(2)**2))
      CALL PHORO3(FI4,PNEUTR(1))
      CALL PHORO3(FI4,PPHO(1,NPHO))
C--
        DO 60 I=2,4
   60   PVEC(I)=0.
        PVEC(1)=1.
        CALL PHORO3(-FI3,PVEC)
        CALL PHORO2(-TH3,PVEC)
        CALL PHOBO3(ANGLE,PVEC)
        CALL PHORO3(FI4,PVEC)
        CALL PHORO2(-TH4,PNEUTR)
        CALL PHORO2(-TH4,PPHO(1,NPHO))
        CALL PHORO2(-TH4,PVEC)
        FI5=PHOAN1(PVEC(1),PVEC(2))
C--
C--   Charged particle restores original direction
        CALL PHORO3(-FI5,PNEUTR)
        CALL PHORO3(-FI5,PPHO(1,NPHO))
        CALL PHORO2(TH1,PNEUTR(1))
        CALL PHORO2(TH1,PPHO(1,NPHO))
        CALL PHORO3(FI1,PNEUTR)
        CALL PHORO3(FI1,PPHO(1,NPHO))
C--   See whether neutral system has multiplicity larger than 1...
      IF ((JDAPHO(2,IP)-JDAPHO(1,IP)).GT.1) THEN
C--   Find pointers to components of 'neutral' system
C--
        FIRST=NEUDAU
        LAST=JDAPHO(2,IP)
        DO 70 I=FIRST,LAST
          IF (I.NE.NCHARB.AND.(JMOPHO(1,I).EQ.IP)) THEN
C--
C--   Reconstruct kinematics...
            CALL PHORO3(-FI1,PPHO(1,I))
            CALL PHORO2(-TH1,PPHO(1,I))
C--
C--   ...reductive boost
            CALL PHOBO3(PARNE,PPHO(1,I))
C--
C--   Rotate in order to get photon along z-axis
            CALL PHORO3(-FI3,PPHO(1,I))
            CALL PHORO2(-TH3,PPHO(1,I))
C--
C--   Boost to the rest frame of decaying particle
            CALL PHOBO3(ANGLE,PPHO(1,I))
C--
C--   Back in the parent rest-frame but PNEUTR not yet oriented.
            CALL PHORO3(FI4,PPHO(1,I))
            CALL PHORO2(-TH4,PPHO(1,I))
C--
C--   Charged particle restores original direction
            CALL PHORO3(-FI5,PPHO(1,I))
            CALL PHORO2(TH1,PPHO(1,I))
            CALL PHORO3(FI1,PPHO(1,I))
          ENDIF
   70   CONTINUE
      ELSE
C--
C--   ...only one 'neutral' particle in addition to photon!
        DO 80 J=1,4
   80   PPHO(J,NEUDAU)=PNEUTR(J)
      ENDIF
C--
C--   All 'neutrals' treated, fill /PHOEVT/ for charged particle...
      DO 90 J=1,3
   90 PPHO(J,NCHARB)=-(PPHO(J,NPHO)+PNEUTR(J))
      PPHO(4,NCHARB)=PPHO(5,IP)-(PPHO(4,NPHO)+PNEUTR(4))
C--
      END
      FUNCTION PHOTRI(A,B,C)
C.----------------------------------------------------------------------
C.
C.    PHOTOS:   PHOton radiation in decays calculation of TRIangle fie
C.
C.    Purpose:  Calculation of triangle function for phase space.
C.
C.    Input Parameters:  A, B, C (Virtual) particle masses.
C.
C.    Output Parameter:  Function value =
C.                       SQRT(LAMBDA(A**2,B**2,C**2))/(2*A)
C.
C.    Author(s):  B. van Eijk                     Created at:  15/11/89
C.                                                Last Update: 02/01/90
C.
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      DOUBLE PRECISION DA,DB,DC,DAPB,DAMB,DTRIAN
      REAL A,B,C,PHOTRI
      DA=A
      DB=B
      DC=C
      DAPB=DA+DB
      DAMB=DA-DB
      DTRIAN=SQRT((DAMB-DC)*(DAPB+DC)*(DAMB+DC)*(DAPB-DC))
      PHOTRI=DTRIAN/(DA+DA)
      RETURN
      END
      FUNCTION PHOAN1(X,Y)
C.----------------------------------------------------------------------
C.
C.    PHOTOS:   PHOton radiation in decays calculation of ANgle '1'
C.
C.    Purpose:  Calculate angle from X and Y
C.
C.    Input Parameters:  X, Y
C.
C.    Output Parameter:  Function value
C.
C.    Author(s):  S. Jadach                       Created at:  01/01/89
C.                B. van Eijk                     Last Update: 02/01/90
C.
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      DOUBLE PRECISION PHOAN1
      REAL X,Y
      REAL PI,TWOPI
      COMMON/PHPICO/PI,TWOPI
      IF (ABS(Y).LT.ABS(X)) THEN
        PHOAN1=ATAN(ABS(Y/X))
        IF (X.LE.0.) PHOAN1=PI-PHOAN1
      ELSE
        PHOAN1=ACOS(X/SQRT(X**2+Y**2))
      ENDIF
      IF (Y.LT.0.) PHOAN1=TWOPI-PHOAN1
      RETURN
      END
      FUNCTION PHOAN2(X,Y)
C.----------------------------------------------------------------------
C.
C.    PHOTOS:   PHOton radiation in decays calculation of ANgle '2'
C.
C.    Purpose:  Calculate angle from X and Y
C.
C.    Input Parameters:  X, Y
C.
C.    Output Parameter:  Function value
C.
C.    Author(s):  S. Jadach                       Created at:  01/01/89
C.                B. van Eijk                     Last Update: 02/01/90
C.
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      DOUBLE PRECISION PHOAN2
      REAL X,Y
      REAL PI,TWOPI
      COMMON/PHPICO/PI,TWOPI
      IF (ABS(Y).LT.ABS(X)) THEN
        PHOAN2=ATAN(ABS(Y/X))
        IF (X.LE.0.) PHOAN2=PI-PHOAN2
      ELSE
        PHOAN2=ACOS(X/SQRT(X**2+Y**2))
      ENDIF
      RETURN
      END
      SUBROUTINE PHOBO3(ANGLE,PVEC)
C.----------------------------------------------------------------------
C.
C.    PHOTOS:   PHOton radiation in decays BOost routine '3'
C.
C.    Purpose:  Boost  vector PVEC  along z-axis where ANGLE = EXP(ETA),
C.              ETA is the hyperbolic velocity.
C.
C.    Input Parameters:  ANGLE, PVEC
C.
C.    Output Parameter:  PVEC
C.
C.    Author(s):  S. Jadach                       Created at:  01/01/89
C.                B. van Eijk                     Last Update: 02/01/90
C.
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      DOUBLE PRECISION QPL,QMI,ANGLE
      REAL PVEC(4)
      QPL=(PVEC(4)+PVEC(3))*ANGLE
      QMI=(PVEC(4)-PVEC(3))/ANGLE
      PVEC(3)=(QPL-QMI)/2.
      PVEC(4)=(QPL+QMI)/2.
      RETURN
      END
      SUBROUTINE PHORO2(ANGLE,PVEC)
C.----------------------------------------------------------------------
C.
C.    PHOTOS:   PHOton radiation in decays ROtation routine '2'
C.
C.    Purpose:  Rotate  x and z components  of vector PVEC  around angle
C.              'ANGLE'.
C.
C.    Input Parameters:  ANGLE, PVEC
C.
C.    Output Parameter:  PVEC
C.
C.    Author(s):  S. Jadach                       Created at:  01/01/89
C.                B. van Eijk                     Last Update: 02/01/90
C.
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      DOUBLE PRECISION CS,SN,ANGLE
      REAL PVEC(4)
      CS=COS(ANGLE)*PVEC(1)+SIN(ANGLE)*PVEC(3)
      SN=-SIN(ANGLE)*PVEC(1)+COS(ANGLE)*PVEC(3)
      PVEC(1)=CS
      PVEC(3)=SN
      RETURN
      END
      SUBROUTINE PHORO3(ANGLE,PVEC)
C.----------------------------------------------------------------------
C.
C.    PHOTOS:   PHOton radiation in decays ROtation routine '3'
C.
C.    Purpose:  Rotate  x and y components  of vector PVEC  around angle
C.              'ANGLE'.
C.
C.    Input Parameters:  ANGLE, PVEC
C.
C.    Output Parameter:  PVEC
C.
C.    Author(s):  S. Jadach                       Created at:  01/01/89
C.                B. van Eijk                     Last Update: 02/01/90
C.
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      DOUBLE PRECISION CS,SN,ANGLE
      REAL PVEC(4)
      CS=COS(ANGLE)*PVEC(1)-SIN(ANGLE)*PVEC(2)
      SN=SIN(ANGLE)*PVEC(1)+COS(ANGLE)*PVEC(2)
      PVEC(1)=CS
      PVEC(2)=SN
      RETURN
      END
      SUBROUTINE PHORIN
C.----------------------------------------------------------------------
C.
C.    PHOTOS:   PHOton radiation  in decays RANdom number generator init
C.
C.    Purpose:  Initialse PHORAN  with  the user  specified seeds in the
C.              array ISEED.  For details  see also:  F. James  CERN DD-
C.              Report November 1988.
C.
C.    Input Parameters:   ISEED(*)
C.
C.    Output Parameters:  URAN, CRAN, CDRAN, CMRAN, I97, J97
C.
C.    Author(s):  B. van Eijk and F. James        Created at:  27/09/89
C.                                                Last Update: 22/02/90
C.
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      DOUBLE PRECISION DATA
      REAL S,T
      INTEGER I,IS1,IS2,IS3,IS4,IS5,J
      INTEGER ISEED,I97,J97
      REAL URAN,CRAN,CDRAN,CMRAN
      COMMON/PHSEED/ISEED(2),I97,J97,URAN(97),CRAN,CDRAN,CMRAN
C--
C--   Check value range of seeds
      IF ((ISEED(1).LT.0).OR.(ISEED(1).GE.31328)) THEN
        DATA=ISEED(1)
        CALL PHOERR(8,'PHORIN',DATA)
      ENDIF
      IF ((ISEED(2).LT.0).OR.(ISEED(2).GE.30081)) THEN
        DATA=ISEED(2)
        CALL PHOERR(9,'PHORIN',DATA)
      ENDIF
C--
C--   Calculate Marsaglia and Zaman seeds (by F. James)
      IS1=MOD(ISEED(1)/177,177)+2
      IS2=MOD(ISEED(1),177)+2
      IS3=MOD(ISEED(2)/169,178)+1
      IS4=MOD(ISEED(2),169)
      DO 20 I=1,97
        S=0.
        T=0.5
        DO 10 J=1,24
          IS5=MOD (MOD(IS1*IS2,179)*IS3,179)
          IS1=IS2
          IS2=IS3
          IS3=IS5
          IS4=MOD(53*IS4+1,169)
          IF (MOD(IS4*IS5,64).GE.32) S=S+T
   10   T=0.5*T
   20 URAN(I)=S
      CRAN=362436./16777216.
      CDRAN=7654321./16777216.
      CMRAN=16777213./16777216.
      I97=97
      J97=33
      RETURN
      END
      FUNCTION PHORAN(IDUM)
C.----------------------------------------------------------------------
C.
C.    PHOTOS:   PHOton radiation in decays RANdom number generator based
C.              on Marsaglia Algorithm
C.
C.    Purpose:  Generate  uniformly  distributed  random numbers between
C.              0 and 1.  Super long period:  2**144.  See also:
C.              G. Marsaglia and A. Zaman,  FSU-SCR-87-50,  for seed mo-
C.              difications  to  this version  see:  F. James DD-Report,
C.              November 1988.  The generator  has  to be initialized by
C.              a call to PHORIN.
C.
C.    Input Parameters:   IDUM (integer dummy)
C.
C.    Output Parameters:  Function value
C.
C.    Author(s):  B. van Eijk, G. Marsaglia and   Created at:  27/09/89
C.                A. Zaman                        Last Update: 27/09/89
C.
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      REAL PHORAN
      INTEGER IDUM
      INTEGER ISEED,I97,J97
      REAL URAN,CRAN,CDRAN,CMRAN
      COMMON/PHSEED/ISEED(2),I97,J97,URAN(97),CRAN,CDRAN,CMRAN
   10 PHORAN=URAN(I97)-URAN(J97)
      IF (PHORAN.LT.0.) PHORAN=PHORAN+1.
      URAN(I97)=PHORAN
      I97=I97-1
      IF (I97.EQ.0) I97=97
      J97=J97-1
      IF (J97.EQ.0) J97=97
      CRAN=CRAN-CDRAN
      IF (CRAN.LT.0.) CRAN=CRAN+CMRAN
      PHORAN=PHORAN-CRAN
      IF (PHORAN.LT.0.) PHORAN=PHORAN+1.
      IF (PHORAN.LE.0.) GOTO 10
      RETURN
      END
      FUNCTION PHOCHA(IDHEP)
C.----------------------------------------------------------------------
C.
C.    PHOTOS:   PHOton radiation in decays CHArge determination
C.
C.    Purpose:  Calculate the charge  of particle  with code IDHEP.  The
C.              code  of the  particle  is  defined by the Particle Data
C.              Group in Phys. Lett. B204 (1988) 1.
C.
C.    Input Parameter:   IDHEP
C.
C.    Output Parameter:  Funtion value = charge  of  particle  with code
C.                       IDHEP
C.
C.    Author(s):  E. Barberio and B. van Eijk     Created at:  29/11/89
C.                                                Last update: 02/01/90
C.
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      REAL PHOCHA
      INTEGER IDHEP,IDABS,Q1,Q2,Q3
C--
C--   Array 'CHARGE' contains the charge  of the first 101 particles ac-
C--   cording  to  the PDG particle code... (0 is added for convenience)
      REAL CHARGE(0:100)
      DATA CHARGE/ 0.,
     &-0.3333333333,  0.6666666667, -0.3333333333, 0.6666666667,
     &-0.3333333333,  0.6666666667, -0.3333333333, 0.6666666667,
     & 2*0., -1., 0., -1., 0., -1., 0., -1., 6*0., 1., 12*0., 1., 63*0./
      IDABS=ABS(IDHEP)
      IF (IDABS.LE.100) THEN
C--
C--   Charge of quark, lepton, boson etc....
        PHOCHA = CHARGE(IDABS)
      ELSE
C--
C--   Check on particle build out of quarks, unpack its code...
        Q3=MOD(IDABS/1000,10)
        Q2=MOD(IDABS/100,10)
        Q1=MOD(IDABS/10,10)
        IF (Q3.EQ.0) THEN
C--
C--   ...meson...
          IF(MOD(Q2,2).EQ.0) THEN
            PHOCHA=CHARGE(Q2)-CHARGE(Q1)
          ELSE
            PHOCHA=CHARGE(Q1)-CHARGE(Q2)
          ENDIF
        ELSE
C--
C--   ...diquarks or baryon.
          PHOCHA=CHARGE(Q1)+CHARGE(Q2)+CHARGE(Q3)
        ENDIF
      ENDIF
C--
C--   Find the sign of the charge...
      IF (IDHEP.LT.0.) PHOCHA=-PHOCHA
      RETURN
      END
      FUNCTION PHOSPI(IDHEP)
C.----------------------------------------------------------------------
C.
C.    PHOTOS:   PHOton radiation  in decays function for SPIn determina-
C.              tion
C.
C.    Purpose:  Calculate  the spin  of particle  with  code IDHEP.  The
C.              code  of the particle  is  defined  by the Particle Data
C.              Group in Phys. Lett. B204 (1988) 1.
C.
C.    Input Parameter:   IDHEP
C.
C.    Output Parameter:  Funtion  value = spin  of  particle  with  code
C.                       IDHEP
C.
C.    Author(s):  E. Barberio and B. van Eijk     Created at:  29/11/89
C.                                                Last update: 02/01/90
C.
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      REAL PHOSPI
      INTEGER IDHEP,IDABS
C--
C--   Array 'SPIN' contains the spin  of  the first 100 particles accor-
C--   ding to the PDG particle code...
      REAL SPIN(100)
      DATA SPIN/ 8*.5, 1., 0., 8*.5, 2*0., 4*1., 76*0./
      IDABS=ABS(IDHEP)
C--
C--   Spin of quark, lepton, boson etc....
      IF (IDABS.LE.100) THEN
        PHOSPI=SPIN(IDABS)
      ELSE
C--
C--   ...other particles, however...
        PHOSPI=(MOD(IDABS,10)-1.)/2.
C--
C--   ...K_short and K_long are special !!
        PHOSPI=MAX(PHOSPI,0.)
      ENDIF
      RETURN
      END
      SUBROUTINE PHOERR(IMES,TEXT,DATA)
C.----------------------------------------------------------------------
C.
C.    PHOTOS:   PHOton radiation in decays ERRror handling
C.
C.    Purpose:  Inform user  about (fatal) errors and warnings generated
C.              by either the user or the program.
C.
C.    Input Parameters:   IMES, TEXT, DATA
C.
C.    Output Parameters:  None
C.
C.    Author(s):  B. van Eijk                     Created at:  29/11/89
C.                                                Last Update: 10/01/92
C.
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      DOUBLE PRECISION DATA
      INTEGER IMES,IERROR
      REAL SDATA
      INTEGER PHLUN
      COMMON/PHOLUN/PHLUN
      INTEGER PHOMES
      PARAMETER (PHOMES=10)
      INTEGER STATUS
      COMMON/PHOSTA/STATUS(PHOMES)
      CHARACTER TEXT*(*)
      SAVE IERROR
      DATA IERROR/ 0/
C--   security STOP switch
      LOGICAL ISEC
      SAVE ISEC
      DATA ISEC /.TRUE./
      IF (IMES.LE.PHOMES) STATUS(IMES)=STATUS(IMES)+1
C--
C--   Count number of non-fatal errors...
      IF ((IMES.EQ. 6).AND.(STATUS(IMES).GE.2)) RETURN
      IF ((IMES.EQ.10).AND.(STATUS(IMES).GE.2)) RETURN
      SDATA=DATA
      WRITE(PHLUN,9000)
      WRITE(PHLUN,9120)
      GOTO (10,20,30,40,50,60,70,80,90,100),IMES
      WRITE(PHLUN,9130) IMES
      GOTO 120
   10 WRITE(PHLUN,9010) TEXT,INT(SDATA)
      GOTO 110
   20 WRITE(PHLUN,9020) TEXT,SDATA
      GOTO 110
   30 WRITE(PHLUN,9030) TEXT,SDATA
      GOTO 110
   40 WRITE(PHLUN,9040) TEXT
      GOTO 110
   50 WRITE(PHLUN,9050) TEXT,INT(SDATA)
      GOTO 110
   60 WRITE(PHLUN,9060) TEXT,SDATA
      GOTO 130
   70 WRITE(PHLUN,9070) TEXT,INT(SDATA)
      GOTO 110
   80 WRITE(PHLUN,9080) TEXT,INT(SDATA)
      GOTO 110
   90 WRITE(PHLUN,9090) TEXT,INT(SDATA)
      GOTO 110
  100 WRITE(PHLUN,9100) TEXT,SDATA
      GOTO 130
  110 CONTINUE
      WRITE(PHLUN,9140)
      WRITE(PHLUN,9120)
      WRITE(PHLUN,9000)
      IF (ISEC) THEN
        STOP
      ELSE
        GOTO 130
      ENDIF
  120 IERROR=IERROR+1
      IF (IERROR.GE.10) THEN
        WRITE(PHLUN,9150)
        WRITE(PHLUN,9120)
        WRITE(PHLUN,9000)
        IF (ISEC) THEN
          STOP
        ELSE
          GOTO 130
        ENDIF
      ENDIF
  130 WRITE(PHLUN,9120)
      WRITE(PHLUN,9000)
      RETURN
 9000 FORMAT(1H ,80('*'))
 9010 FORMAT(1H ,'* ',A,': Too many charged Particles, NCHARG =',I6,T81,
     &'*')
 9020 FORMAT(1H ,'* ',A,': Too much Bremsstrahlung required, PRSOFT = ',
     &F15.6,T81,'*')
 9030 FORMAT(1H ,'* ',A,': Combined Weight is exceeding 1., Weight = ',
     &F15.6,T81,'*')
 9040 FORMAT(1H ,'* ',A,
     &': Error in Rescaling charged and neutral Vectors',T81,'*')
 9050 FORMAT(1H ,'* ',A,
     &': Non matching charged Particle Pointer, NCHARG = ',I5,T81,'*')
 9060 FORMAT(1H ,'* ',A,
     &': Do you really work with a Particle of Spin: ',F4.1,' ?',T81,
     &'*')
 9070 FORMAT(1H ,'* ',A, ': Stack Length exceeded, NSTACK = ',I5 ,T81,
     &'*')
 9080 FORMAT(1H ,'* ',A,
     &': Random Number Generator Seed(1) out of Range: ',I8,T81,'*')
 9090 FORMAT(1H ,'* ',A,
     &': Random Number Generator Seed(2) out of Range: ',I8,T81,'*')
 9100 FORMAT(1H ,'* ',A,
     &': Available Phase Space below Cut-off: ',F15.6,' GeV/c^2',T81,
     &'*')
 9120 FORMAT(1H ,'*',T81,'*')
 9130 FORMAT(1H ,'* Funny Error Message: ',I4,' ! What to do ?',T81,'*')
 9140 FORMAT(1H ,'* Fatal Error Message, I stop this Run !',T81,'*')
 9150 FORMAT(1H ,'* 10 Error Messages generated, I stop this Run !',T81,
     &'*')
      END
      SUBROUTINE PHOREP
C.----------------------------------------------------------------------
C.
C.    PHOTOS:   PHOton radiation in decays run summary REPort
C.
C.    Purpose:  Inform user about success and/or restrictions of PHOTOS
C.              encountered during execution.
C.
C.    Input Parameters:   Common /PHOSTA/
C.
C.    Output Parameters:  None
C.
C.    Author(s):  B. van Eijk                     Created at:  10/01/92
C.                                                Last Update: 10/01/92
C.
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      INTEGER PHLUN
      COMMON/PHOLUN/PHLUN
      INTEGER PHOMES
      PARAMETER (PHOMES=10)
      INTEGER STATUS
      COMMON/PHOSTA/STATUS(PHOMES)
      INTEGER I
      LOGICAL ERROR
      ERROR=.FALSE.
      WRITE(PHLUN,9000)
      WRITE(PHLUN,9010)
      WRITE(PHLUN,9020)
      WRITE(PHLUN,9030)
      WRITE(PHLUN,9040)
      WRITE(PHLUN,9030)
      WRITE(PHLUN,9020)
      DO 10 I=1,PHOMES
        IF (STATUS(I).EQ.0) GOTO 10
        IF ((I.EQ.6).OR.(I.EQ.10)) THEN
          WRITE(PHLUN,9050) I,STATUS(I)
        ELSE
          ERROR=.TRUE.
          WRITE(PHLUN,9060) I,STATUS(I)
        ENDIF
   10 CONTINUE
      IF (.NOT.ERROR) WRITE(PHLUN,9070)
      WRITE(PHLUN,9020)
      WRITE(PHLUN,9010)
      RETURN
 9000 FORMAT(1H1)
 9010 FORMAT(1H ,80('*'))
 9020 FORMAT(1H ,'*',T81,'*')
 9030 FORMAT(1H ,'*',26X,25('='),T81,'*')
 9040 FORMAT(1H ,'*',30X,'PHOTOS Run Summary',T81,'*')
 9050 FORMAT(1H ,'*',22X,'Warning #',I2,' occured',I6,' times',T81,'*')
 9060 FORMAT(1H ,'*',23X,'Error #',I2,' occured',I6,' times',T81,'*')
 9070 FORMAT(1H ,'*',16X,'PHOTOS Execution has successfully terminated',
     &T81,'*')
      END
      SUBROUTINE PHLUPA(IPOINT)
C.----------------------------------------------------------------------
C.
C.    PHLUPA:   debugging tool
C.
C.    Purpose:  NONE, eventually may printout content of the
C.              /PHOEVT/ common
C.
C.    Input Parameters:   Common /PHOEVT/ and /PHNUM/
C.                        latter may have number of the event.
C.
C.    Output Parameters:  None
C.
C.    Author(s):  Z. Was                          Created at:  30/05/93
C.                                                Last Update: 10/08/93
C.
C.----------------------------------------------------------------------
      INTEGER NMXPHO
      PARAMETER (NMXPHO=2000)
      INTEGER IDPHO,ISTPHO,JDAPHO,JMOPHO,NEVPHO,NPHO
      REAL PPHO,VPHO
      COMMON/PHOEVT/NEVPHO,NPHO,ISTPHO(NMXPHO),IDPHO(NMXPHO),
     &JMOPHO(2,NMXPHO),JDAPHO(2,NMXPHO),PPHO(5,NMXPHO),VPHO(4,NMXPHO)
      COMMON /PHNUM/ IEV
      INTEGER PHLUN
      COMMON/PHOLUN/PHLUN
      DIMENSION SUM(5)
      IF (IPOINT.LT.3000) RETURN
      IOUT=56
      IF (IEV.LT.1000) THEN
      DO I=1,5
        SUM(I)=0.0
      ENDDO
      WRITE(PHLUN,*) 'EVENT NR=',IEV,
     $            'WE ARE TESTING /PHOEVT/ at IPOINT=',IPOINT
      WRITE(PHLUN,10)
      I=1
      WRITE(PHLUN,20) IDPHO(I),PPHO(1,I),PPHO(2,I),PPHO(3,I),
     $                      PPHO(4,I),PPHO(5,I),JDAPHO(1,I),JDAPHO(2,I)
      I=2
      WRITE(PHLUN,20) IDPHO(I),PPHO(1,I),PPHO(2,I),PPHO(3,I),
     $                      PPHO(4,I),PPHO(5,I),JDAPHO(1,I),JDAPHO(2,I)
      WRITE(PHLUN,*) ' '
      DO I=3,NPHO
      WRITE(PHLUN,20) IDPHO(I),PPHO(1,I),PPHO(2,I),PPHO(3,I),
     $                      PPHO(4,I),PPHO(5,I),JMOPHO(1,I),JMOPHO(2,I)
        DO J=1,4
          SUM(J)=SUM(J)+PPHO(J,I)
        ENDDO
      ENDDO
      SUM(5)=SQRT(ABS(SUM(4)**2-SUM(1)**2-SUM(2)**2-SUM(3)**2))
      WRITE(PHLUN,30) SUM
 10   FORMAT(1X,'  ID      ','p_x      ','p_y      ','p_z      ',
     $                   'E        ','m        ',
     $                   'ID-MO_DA1','ID-MO DA2' )
 20   FORMAT(1X,I4,5(F9.3),2I9)
 30   FORMAT(1X,' SUM',5(F9.3))
      ENDIF
      END
C=============================================================
C=============================================================
C==== end of directory ===== =================================
C=============================================================
C=============================================================
