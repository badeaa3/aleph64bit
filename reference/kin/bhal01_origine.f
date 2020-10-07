cFrom BLOCH@alws.cern.ch Fri Feb 13 15:48:41 2004
cDate: Fri, 13 Feb 2004 15:47:40 +0100
cFrom: BLOCH@alws.cern.ch
cTo: BLOCH@alws.cern.ch

C-----------------------------------------------------------------------
C           A L E P H   I N S T A L L A T I O N    N O T E S           |
C                                                                      |
C    Aleph    name  : BHAL01.                                          |
C    original code  : BABAMC from Kleiss, Behrends and Hollik.         |
C    transmitted by : H. Burkhardt September 15, 1987.                 |
C                                                                      |
C       (see KINLIB DOC for a description of this version)             |
C                                                                      |
C ----------------------------------------------------------------------
C Modifications to the original code :                                 |
C                                                                      |
C                                                                      |
C 1. COMMON/BOS/ -- /BOSON/                                            |
C    SUBROUTINE INT -- SUBROUTINE INTE                                 |
C    SUBROUTINE TELLER and OUTCRY : COMMON/UNICOM/ has been introduced |
C                                WRITE(7 has been changed for WRITE(IUT|
C    SUBROUTINE SETUP5 : WRITE(* changed to WRITE(IUT                  |
C    All the lines commented as C GB were taken out by G.B. and B.B.   |
C                                      (G. Bonneaud November 13, 1987).|
C                                                                      |
C 2. MOD in GENBAB to reject events with weight=0. as proposed by H.   |
C    Burkhardt et al., Aleph 88-139 (B. Bloch November 8, 1988).       |
C                                                                      |
C 3. Function RN replaced by RNDM (for use of RANMAR)                  |
C                                   (G. Bonneaud August 1989).         |
C                                                                      |
C 4. NEW function PIG(s) introduced as advertised by H.Burkhardt Feb90 |
C 5. ******************************************************************|
C    FOR LUMINOSITY CALCULATION ONLY                                   |
C**********************************************************************|
C    XK0 (famous k0 parameter) changed from 0.01 to 0.001 by Bolek     |
C    Pietrzyk. This version has been checked against analytical        |
C    calculations of S. Jadach, E. Richter-Was, Z. Was and B.F.L. Ward |
C    Phys. Lett. B253(1991) 469 with  vacuum polarisation and Z        |
C    contribution switched off. Comparison was done for typical Aleph
C    luminosity cuts, agreement was found to be better than 10-3.      |
C                                    (Bolek Pietrzyk)                  |
C----------------------------------------------------------------------
C
C THIS IS THE MAIN PROGRAM, CONSISTING OF:
C 1) INITIALIZATION OF THE GENERATOR;
C 2) GENERATION OF AN EVENT SAMPLE,
C    AND SUBSEQUENT ANALYSIS OF THE EVENTS;
C 3) EVALUATION OF THE TOTAL GENERATED CROSS SECTION
C
C
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / INPUT1 / EB
      COMMON / INPUT2 / XMZ,S2W,XMH,XMT
      COMMON / INPUT3 / THMIN,THMAX,XKMAX
      COMMON / UNICOM / IIN,IUT
      DIMENSION PP(4),PM(4),QP(4),QM(4),QK(4)
C
C THE SETUP PHASE: ASK FOR THE INPUT PARAMETERS
      IIN=5
      IUT=6
CHBU  READ(IIN,*) EB
CHBU  READ(IIN,*) XMZ
CHBU  READ(IIN,*) XMT
CHBU  READ(IIN,*) XMH
CHBU  READ(IIN,*) THMIN
CHBU  READ(IIN,*) THMAX
CHBU  READ(IIN,*) XKMAX
CHBU  READ(IIN,*) NEVENT
      EB      =  50.
      XMZ     =  92.
      XMT     =  70.
      XMH     =  10.
      THMIN   =  30.
      THMAX   =  150.
      XKMAX   =  1.
      NEVENT  =  100
C
C THE INITIALIZATION STEP OF THE PROGRAM
      CALL SETBAB(EB,XMZ,XMH,XMT,THMIN,THMAX,XKMAX)
C
C THE EVENT LOOP
      CALL OUTCRY('GENBAB')
      DO 900 K=1,NEVENT
      CALL TELLER(K,1000,'EVENT LOOP')
      CALL GENBAB(PP,PM,QP,QM,QK,W,ICON)
      CALL CANCUT(QP,QM,QK,W)
  900 CONTINUE
C
C EVALUATION OF THE GENERATED CROSS SECTION
      CALL ENDBAB(SIGTOT,ERRTOT)
      CALL EFFCIT
      CALL ENDCUT(SIGTOT)
      END
C-----------------------------------------------------------------------
      SUBROUTINE TELLER(K,NTEL,STRING)
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / UNICOM / IIN,IUT
      CHARACTER*10 STRING
      X1=(1.D0*K)/(1.D0*NTEL)
      X2=1.D0*(K/NTEL)
      IF(X1.EQ.X2) WRITE(IUT,1) K,STRING
    1 FORMAT(' EVENT COUNTER AT',I10,' AT LOCATION  ',A10)
      END
C-----------------------------------------------------------------------
      SUBROUTINE HISTO1(IH,IB,X0,X1,X,W)
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / HISTOC /H(100,10),HX(100),IO(100),IU(100),II(100),
     .                 Y0(100),Y1(100),IC(100)
      DATA ISTART/0/
      IF(ISTART.EQ.0) THEN
                      DO 102 NH=1,100
                      DO 101 NB=1,10
  101                 H(NH,NB)=0.D0
                      HX(NH)=0.D0
                      IO(NH)=0
                      IU(NH)=0
                      II(NH)=0
                      Y0(NH)=1.D0
                      Y1(NH)=0.D0
  102                 IC(NH)=0
                      ISTART=1
      ENDIF
      Y0(IH)=X0
      Y1(IH)=X1
      IC(IH)=IB
      IF(X.LT.X0) GOTO 11
      IF(X.GT.X1) GOTO 12
      IX=IDINT((X-X0)/(X1-X0)*1.D0*(IB))+1
      H(IH,IX)=H(IH,IX)+W
      IF(H(IH,IX).GT.HX(IH)) HX(IH)=H(IH,IX)
      II(IH)=II(IH)+1
      RETURN
   11 IU(IH)=IU(IH)+1
      RETURN
   12 IO(IH)=IO(IH)+1
      END
C-----------------------------------------------------------------------
      SUBROUTINE HISTO2(IH,IL)
      IMPLICIT REAL*8(A-H,O-Z)
      CHARACTER*1 REGEL(30),BLANK,STAR
      COMMON / HISTOC /H(100,10),HX(100),IO(100),IU(100),II(100),
     .                 Y0(100),Y1(100),IC(100)
      COMMON / UNICOM / IIN,IUT
      DATA REGEL /30*' '/,BLANK /' '/,STAR /'*'/
      X0=Y0(IH)
      X1=Y1(IH)
      IB=IC(IH)
      HX(IH)=HX(IH)*(1.D0+1.D-06)
      IF(IL.EQ.0) WRITE(IUT,21) IH,II(IH),IU(IH),IO(IH)
      IF(IL.EQ.1) WRITE(IUT,22) IH,II(IH),IU(IH),IO(IH)
   21 FORMAT(' NO.',I3,' LIN : INSIDE,UNDER,OVER ',3I6)
   22 FORMAT(' NO.',I3,' LOG : INSIDE,UNDER,OVER ',3I6)
      IF(II(IH).EQ.0) GOTO 28
      WRITE(IUT,23)
   23 FORMAT(35(1H ),3(10H----+----I))
      DO 27 IV=1,IB
      Z=1.D0*(IV)/(1.D0*(IB))*(X1-X0)+X0
      IF(IL.EQ.1) GOTO 24
      IZ=IDINT(H(IH,IV)/HX(IH)*30.)+1
      GOTO 25
   24 IZ=-1
      IF(H(IH,IV).GT.0.D0)
     .IZ=IDINT(DLOG(H(IH,IV))/DLOG(HX(IH))*30.)+1
   25 IF(IZ.GT.0.AND.IZ.LE.30) REGEL(IZ)=STAR
      WRITE(IUT,26) Z,H(IH,IV),(REGEL(I),I=1,30)
   26 FORMAT(1H ,2G15.6,4H   I,30A1,1HI)
      IF(IZ.GT.0.AND.IZ.LE.30) REGEL(IZ)=BLANK
   27 CONTINUE
      WRITE(IUT,23)
CHBU  print before PAUSE
C GB  IF(IUT.EQ.0) PRINT *,'PAUSE'
C GB  IF(IUT.EQ.0) PAUSE
      RETURN
   28 WRITE(IUT,29)
   29 FORMAT('0 NO ENTRIES INSIDE HISTOGRAM')
      END
C-----------------------------------------------------------------------
      SUBROUTINE HISTO3(IH)
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / HISTOC /H(100,10),HX(100),IO(100),IU(100),II(100),
     .                 Y0(100),Y1(100),IC(100)
      DO 31 I=1,10
   31 H(IH,I)=0.D0
      HX(IH)=0.D0
      II(IH)=0
      IU(IH)=0
      IO(IH)=0
      END
C-----------------------------------------------------------------------
      FUNCTION RN(DUMMY)
      IMPLICIT REAL*8(A-H,O-Z)
      DATA P/390625D+00/
      DATA Q/9179D+00/
      DATA U/2.147483648D+09/
      DATA S/1234567.D0/
      S=DMOD(P*S + Q  , U)
      RN=(S/U)
      END
C-----------------------------------------------------------------------
      SUBROUTINE PRNVEC(QP,QM,QK,A1,A2,A3,A4,WM,EX,I)
      IMPLICIT REAL*8(A-H,O-Z)
      DIMENSION QP(4),QM(4),QK(4)
      COMMON / UNICOM / IIN,IUT
      IF(QK(4).EQ.0.D0) RETURN
      WRITE(IUT,1) (QP(K),QM(K),QK(K),K=1,4)
    1 FORMAT('0ANOMALOUS EVENT PRINTOUT',4(/3D15.6))
      CP=QP(3)/QP(4)
      CM=QM(3)/QM(4)
      CK=QK(3)/QK(4)
      WRITE(IUT,2) CP,CM,CK
    2 FORMAT(' COSINES OF THE SCATTERING ANGLES:'/,3D15.6)
      CPM=(QP(1)*QM(1)+QP(2)*QM(2)+QP(3)*QM(3))/QP(4)/QM(4)
      CPK=(QP(1)*QK(1)+QP(2)*QK(2)+QP(3)*QK(3))/QP(4)/QK(4)
      CMK=(QM(1)*QK(1)+QM(2)*QK(2)+QM(3)*QK(3))/QM(4)/QK(4)
      WRITE(IUT,3) CPM,CPK,CMK
    3 FORMAT(' COSINES BETWEEN P-M, P-K, M-K :'/,3D15.6)
      XPM=2.D0*(QP(4)*QM(4)-QP(3)*QM(3)-QP(2)*QM(2)-QP(1)*QM(1))
      XPK=2.D0*(QP(4)*QK(4)-QP(3)*QK(3)-QP(2)*QK(2)-QP(1)*QK(1))
      XMK=2.D0*(QK(4)*QM(4)-QK(3)*QM(3)-QK(2)*QM(2)-QK(1)*QM(1))
      WRITE(IUT,4) XPM,XPK,XMK
    4 FORMAT(' INVARIANT MASSES P-M, P-K, M-K :'/,3D15.6)
      WTOT=EX*WM/(A1+A2+A3+A4)
      WRITE(IUT,5) A1,A2,A3,A4,WM,EX,WTOT,I
    5 FORMAT(' THE APPROXIMANTS:',4D15.6/,
     . ' THE MASS EFFECT FACTOR:',D15.6/,
     . ' THE EXACT CROSS SECTION:',D15.6/,
     . ' THE RESULTING WEIGHT:',D15.6/,
     . ' OBTAINED IN CHANNEL NO.',I2)
      END
C----------------------------------------------------------------------
      SUBROUTINE EFFCIT
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / EFFIC1 / EFK1
      COMMON / EFFIC2 / EFK2
      COMMON / EFFIC4 / EFK4PR,EFK4PO,EFC4PR,EFC4PO
      COMMON / EFFIC5 / EFPR5,EFPO5
      COMMON / UNICOM / IIN,IUT
      WRITE(IUT,1)
    1 FORMAT(' COMPARISON OF EXPECTED AND OBTAINED EFFICIENCIES')
      WRITE(IUT,11) EFK1
   11 FORMAT(' GENER1 : K LOOP : ',D15.6)
      WRITE(IUT,21) EFK2
   21 FORMAT(' GENER2 : K LOOP : ',D15.6)
      WRITE(IUT,41) EFK4PR,EFK4PO,EFC4PR,EFC4PO
   41 FORMAT(' GENER4 : K LOOP : ',D15.6,' EXPECTED'/,
     .       '                   ',D15.6,' OBSERVED'/,
     .       '          C LOOP : ',D15.6,' EXPECTED'/,
     .       '                   ',D15.6,' OBSERVED')
      WRITE(IUT,51) EFPR5,EFPO5
   51 FORMAT(' GENER5 : C LOOP : ',D15.6,' EXPECTED'/,
     .       '                   ',D15.6,' OBSERVED')
      END
C-----------------------------------------------------------------------
      SUBROUTINE OUTCRY(STRING)
      COMMON / UNICOM / IIN,IUT
      CHARACTER*6 STRING
      WRITE(IUT,1) STRING
    1 FORMAT(' ROUTINE "',A6,'" STARTING NOW ... GO!')
      END
C-----------------------------------------------------------------------
      SUBROUTINE SETUPM(AMZ,AGZ,GV,GA)
C
C SETUP FOR CALCULATION OF THE RADIATIVE BHABHA AMPLITUDE
C SIN2W = SIN**2 OF THE WEAK MIXING ANGLE
C AMZ = MASS OF THE Z0 IN GEV
C AGZ = WIDTH OF THE Z0 IN GEV
      IMPLICIT REAL*8(A-H,O-U),COMPLEX*16(V-Z)
      COMMON / AMPCOM / E3,  EG1,  EG2,  EG3,
     .                  AM2Z,  AMGZ
      COMMON / UNICOM / IIN,IUT
C
      CALL OUTCRY('SETUPM')
C
C CALCULATE THE VARIOUS CONSTANTS
      ROOT8=DSQRT(8.D0)
      E=DSQRT(4.*3.1415926536D0/137.036D0)
      AM2Z=AMZ**2
      AMGZ=AMZ*AGZ
      E3=E**3*ROOT8
      EG1=E*(GV-GA)**2*ROOT8
      EG2=E*(GV**2-GA**2)*ROOT8
      EG3=E*(GV+GA)**2*ROOT8
C
C PRINT THE RESULTS SO FAR
      WRITE(IUT,1) AMZ,   AGZ,     E,    GA,
     .            GV,  AM2Z,  AMGZ,    E3,
     .           EG1,   EG2,   EG3
    1 FORMAT(' SETUPM :',4D14.6)
      END
C-----------------------------------------------------------------------
      SUBROUTINE AMPLIT(PP,PM,QP,QM,QK,RESULT)
C
C CALCULATION OF THE AMPLITUDES FOR MASSLESS MOMENTA
C PP = INCOMING POSITRON
C PM = INCOMING ELECTRON
C QP = OUTGOING POSITRON
C QM = OUTGOING ELECTRON
C QK = BREMSSTRAHLUNG PHOTON
      IMPLICIT REAL*8(A-H,O-U),COMPLEX*16(V-Z)
      DIMENSION PP(4),PM(4),QP(4),QM(4),QK(4)
      DIMENSION A(5),ZC(5),ZM(12)
      COMMON / AMPCOM / E3,  EG1,  EG2,  EG3,
     .                  AM2Z,  AMGZ
      COMMON / AMPCM2 / PPK,  PMK,  QPK,  QMK
C
C THE PHOTON-CUM-Z0 PROPAGATORS
      Z1(S)=E3/S+EG1/DCMPLX(S-AM2Z,AMGZ)
      Z2(S)=E3/S+EG2/DCMPLX(S-AM2Z,AMGZ)
      Z3(S)=E3/S+EG3/DCMPLX(S-AM2Z,AMGZ)
C
C THE DEFINITION OF THE SPINOR PRODUCT
      ZS(I,J)=ZC(I)*A(J)-ZC(J)*A(I)
C
      A(1)=DSQRT(PP(4)-PP(1))
      A(2)=DSQRT(PM(4)-PM(1))
      A(3)=DSQRT(QP(4)-QP(1))
      A(4)=DSQRT(QM(4)-QM(1))
      A(5)=DSQRT(QK(4)-QK(1))
      ZC(1)=DCMPLX(PP(2),PP(3))/A(1)
      ZC(2)=DCMPLX(PM(2),PM(3))/A(2)
      ZC(3)=DCMPLX(QP(2),QP(3))/A(3)
      ZC(4)=DCMPLX(QM(2),QM(3))/A(4)
      ZC(5)=DCMPLX(QK(2),QK(3))/A(5)
C
C DEFINE THE NECESSARY SPINOR PRODUCTS
      X51=ZS(5,1)
      X25=ZS(2,5)
      X54=ZS(5,4)
      X35=ZS(3,5)
      X13=ZS(1,3)
      X12=ZS(1,2)
      X43=ZS(4,3)
      X42=ZS(4,2)
      X14=ZS(1,4)
      X32=ZS(3,2)
C
C COMPUTE THE FERMION PROPAGATORS IN THE MASSLESS LIMIT
      PPK=.5D0*CDABS(X51)**2
      PMK=.5D0*CDABS(X25)**2
      QPK=.5D0*CDABS(X35)**2
      QMK=.5D0*CDABS(X54)**2
C
C DEFINE THE COMPONENTS OF THE INFRARED FACTORS
      V1=-DCONJG(X42)/(X51*X35)
      V2=-DCONJG(X13)/(X54*X25)
      V3=-DCONJG(X43)/(X51*X25)
      V4=-DCONJG(X12)/(X54*X35)
      V5=-DCONJG(V1)
      V6=-DCONJG(V2)
      V7=-DCONJG(V3)
      V8=-DCONJG(V4)
C
C DEFINE THE WELL-KNOWN INVARIANT MASSES
      S0= CDABS(X12)**2
      S1= CDABS(X43)**2
      T0=-CDABS(X13)**2
      T1=-CDABS(X42)**2
      U0=-CDABS(X14)**2
      U1=-CDABS(X32)**2
C
C DEFINE THE BOSON PROPAGATORS
      Z1T1=Z1(T1)
      Z2T1=Z2(T1)
      Z3T1=Z3(T1)
      Z1T0=Z1(T0)
      Z2T0=Z2(T0)
      Z3T0=Z3(T0)
      Z1S1=Z1(S1)
      Z2S1=Z2(S1)
      Z3S1=Z3(S1)
      Z1S0=Z1(S0)
      Z2S0=Z2(S0)
      Z3S0=Z3(S0)
C
C DEFINE THE TWELVE HELICITY AMPLITUDES
      ZM( 1)=U0*( Z1T1*V1 + Z1T0*V2 + Z1S1*V3 + Z1S0*V4 )
      ZM( 2)=T0*(                     Z2S1*V3 + Z2S0*V4 )
      ZM( 3)=S0*( Z2T1*V1 + Z2T0*V2                     )
      ZM( 4)=S1*ZM(3)/S0
      ZM( 5)=T1*ZM(2)/T0
      ZM( 6)=U1*( Z3T1*V1 + Z3T0*V2 + Z3S1*V3 + Z3S0*V4 )
      ZM( 7)=U0*( Z3T1*V5 + Z3T0*V6 + Z3S1*V7 + Z3S0*V8 )
      ZM( 8)=T0*(                     Z2S1*V7 + Z2S0*V8 )
      ZM( 9)=S0*( Z2T1*V5 + Z2T0*V6                     )
      ZM(10)=S1*ZM(9)/S0
      ZM(11)=T1*ZM(8)/T0
      ZM(12)=U1*( Z1T1*V5 + Z1T0*V6 + Z1S1*V7 + Z1S0*V8 )
C
C DEFINE THE RESULTING CROSS SECTION
      RESULT=0.
      DO 102 I=1,12
      RESULT=RESULT+CDABS(ZM(I))**2
  102 CONTINUE
      RESULT=RESULT/4.
C
      END
C-----------------------------------------------------------------------
      SUBROUTINE SETUPW(E,XMZ,XGZ,GV,GA)
C
C SETUP FOR CALCULATING THE APPROXIMATIONS TO THE RADIATIVE
C CROSS SECTION.
C E = BEAM ENERGY IN GEV;
C XMZ = Z0 MASS IN GEV;
C XGZ = Z0 TOTAL WIDTH IN GEV;
C GV(GA) = (AXIAL-) VECTOR COUPLING BETWEEN ELECTRON AND Z0.
C
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / WGTCOM / EBEAM,S,S2,F1,F2,F3,F4,XM2,XMG2
      COMMON / UNICOM / IIN,IUT
C
C THE BREIT-WIGNER PROPAGATOR
      B(X)=(X-XM2)**2+XMG2
C
      CALL OUTCRY('SETUPW')
C
C CONSTANTS
      EBEAM=E
      S=4.*E**2
      S2=S**2
      E2=4.*3.1415926536D0/137.036D0
      G=GV**4+6.*GV**2*GA**2+GA**4
      XM2=XMZ**2
      XMG2=XMZ**2*XGZ**2
C
C THE CONSTANT FACTORS OF THE FOUR APPROXIMANTS
      F1=E2**3
      F2=E2*G*S/B(S)+2.*E2**2*(GV**2+GA**2)*(S-XM2)/B(S)+E2**3/S
      F3=E2*G
      F4=E2**3*2.
C
C PRINT THE RESULTS SO FAR
      WRITE(IUT,1)   E,   XMZ,   XGZ,    GV,
     .            GA,     S,    S2,    E2,
     .             G,   XM2,  XMG2,    F1,
     .            F2,    F3,    F4
    1 FORMAT(' SETUPW :',4D14.6)
      END
C-----------------------------------------------------------------------
      SUBROUTINE APROXS(QP,QM,QK,A1,A2,A3,A4)
C
C CALCULATE THE FOUR APPROXIMATE CROSS SECTIONS
C QP = MOMENTUM OF THE OUTGOING POSITRON
C QM = MOMENTUM OF THE OUTGOING ELECTRON
C QK = MOMENTUM OF THE BREMSSTRAHLUNG PHOTON
C THE INCOMING POSITRON IS ALONG THE POSITIVE Z-AXIS.
C A1 : INITIAL-STATE RADIATION IN THE PHOTON S-CHANNEL
C A2 : FINAL-STATE RADIATION IN THE Z0 S-CHANNEL
C A3 : INITIAL-STATE RADIATION IN THE Z0 S-CHANNEL
C A4 : RADIATION IN THE PHOTON T-CHANNEL
C
      IMPLICIT REAL*8(A-H,O-Z)
      DIMENSION QP(4),QM(4),QK(4)
      COMMON / WGTCOM / E,S,S2,F1,F2,F3,F4,XM2,XMG2
      COMMON / AMPCM2 / PPK,  PMK,  QPK,  QMK
C
C THE BREIT-WIGNER PROPAGATOR
      B(X)=(X-XM2)**2+XMG2
C
      S1=S*(1.-QK(4)/E)
      T =-2.*E*(QP(4)-QP(3))
      T1=-2.*E*(QM(4)+QM(3))
      SFAC=S2+S1**2
      A1=F1*SFAC/(S1*PPK*PMK)
      A2=F2*SFAC/(QPK*QMK)
      A3=F3*SFAC*S1/(B(S1)*PPK*PMK)
      A4=F4*SFAC*(-1./(T1*PPK*QPK)-1./(T*PMK*QMK))
      END
C-----------------------------------------------------------------------
      SUBROUTINE SETUP1(E,XK0,XK1,SIGMA)
C
C SUBGENERATOR 1:
C INITIAL-STATE RADIATION IN QED S-CHANNEL GRAPHS
C E = BEAM ENERGY IN GEV
C XK0 = MINIMUM PHOTON ENERGY (FRACTION OF E)
C XK1 = MAXIMUM PHOTON ENERGY (FRACTION OF E)
C
      IMPLICIT REAL*8(A-H,O-Z)
C
C COMMON BLOCK FOR TRANSFER TO 'GENER1'
      COMMON / G1COM / EBEAM,   EPS,
     .                 YK1,  YK2,  YK3,  YZ1,  YZ2,  YF1,
     .                 TRYK,  PASK
      COMMON / UNICOM / IIN,IUT
C
      CALL OUTCRY('SETUP1')
 
C
C CHECK ON PHOTON ENERGIES
      IF(XK1.LE.XK0) THEN
                     SIGMA=0.D0
                     RETURN
                     ENDIF
C
C DEFINE CONSTANTS
      EBEAM=E
      XME=0.000511D0
      PI=3.1415926536D0
      EEL=DSQRT(4.*PI/137.036D0)
      FAC=4970.392/E**2*2.*EEL**6*PI**2
      EPS=(XME/E)**2*.5D0
      XKMAX=1.-DEXP(5.D0/3.)/2.*EPS
C
C TOTAL APPROXIMATE CROSS SECTION
      E0=E*XK0
      IF(XK1.LE.XKMAX) GOTO 2
      WRITE(IUT,1) XKMAX
    1 FORMAT(' SETUP1 : THE MAXIMUM PHOTON ENERGY IS TOO HIGH;'/,
     .       ' SETUP1 : I CHANGE ITS VALUE TO',D30.20)
      XK1=XKMAX
    2 CONTINUE
      EMAX=XK1*E
      SIGMA=FAC*DLOG(4.*E**2/XME**2)*
     . (2.*DLOG(EMAX/E0) + DLOG((E-E0)/(E-EMAX))
     . -(EMAX-E0)/E )
C
C INITIALIZE CONSTANTS FOR EVENT GENERATION
      YK1=DLOG(E0/(E-E0))
      YK2=DLOG(EMAX/E0*(E-E0)/(E-EMAX))
      YK3=E**2+(E-E0)**2
      YZ1=DLOG(EPS)
      YZ2=DLOG((2.+EPS)/EPS)
      YF1=2.*PI
C
C THE EFFICIENCY OF THE PHOTON ENERGY LOOP
      EFFK=(2.*DLOG(EMAX/E0)+DLOG((E-E0)/(E-EMAX))
     . -(EMAX-E0)/E )/(1.+(1.-E0/E)**2)
     . /DLOG(EMAX*(E-E0)/E0/(E-EMAX))
      TRYK=0.
      PASK=0.
C
C PRINT THE RESULTS SO FAR
      WRITE(IUT,3)   E,   XK0,   XK1,   XME,   PI,
     .           EEL,   FAC,   EPS, XKMAX,   E0,
     .          EMAX, SIGMA,   YK1,   YK2,  YK3,
     .           YZ1,   YZ2,   YF1,  EFFK, TRYK,
     .          PASK
    3 FORMAT(' SETUP1 :',4D14.6)
      END
C-----------------------------------------------------------------------
      SUBROUTINE GENER1(QP,QM,QK,WM)
C
C GENERATION OF THE FINAL-STATE MOMENTA
      IMPLICIT REAL*8(A-H,O-Z)
      DIMENSION QP(4),QM(4),QK(4),H(4)
      COMMON / EFFIC1 / EFFK
      COMMON / G1COM / E,  EPS,
     .                 YK1,  YK2,  YK3,  YZ1,  YZ2,  YF1,
     .                 TRYK,  PASK
      EXTERNAL RNDM
      REAL*4 RNDM
C
C GENERATE THE PHOTON ENERGY BY MAPPING AND W.R.P.
    4 TRYK=TRYK+1.
C GB  QK(4)=E/(1.+1./DEXP(YK1+RN(1.)*YK2))
      QK(4)=E/(1.+1./DEXP(YK1+RNDM(1.)*YK2))
      W=(E**2+(E-QK(4))**2)/YK3
C GB  IF(W.LT.RN(2.)) GOTO 4
      IF(W.LT.RNDM(2.)) GOTO 4
      PASK=PASK+1.
      EFFK=PASK/TRYK
C
C GENERATE THE PHOTON POLAR ANGLE (N.B. STABILITY)
C GB  V=DEXP(YZ1+RN(3.)*YZ2)-EPS
      V=DEXP(YZ1+RNDM(3.)*YZ2)-EPS
      ZG=1.-V
      SG=DSQRT(V*(2.-V))
C GB  IF(RN(4.).GT..5D0) ZG=-ZG
      IF(RNDM(4.).GT..5D0) ZG=-ZG
C
C GENERATE THE OTHER TRIVIAL VARIABLES
C GB  FG=YF1*RN(5.)
      FG=YF1*RNDM(5.)
C GB  FR=YF1*RN(6.)
      FR=YF1*RNDM(6.)
C GB  CR=-1.+2.*RN(7.)
      CR=-1.+2.*RNDM(7.)
      SR=DSQRT(1.-CR*CR)
C
C CALCULATE THE MASS EFFECT FACTOR
      WM=1.-EPS/(EPS+V)*2.*E*(E-QK(4))/(E**2+(E-QK(4))**2)
C
C CONSTRUCT THE PHOTON MOMENTUM IN THE LAB
      QK(1)=QK(4)*SG*DSIN(FG)
      QK(2)=QK(4)*SG*DCOS(FG)
      QK(3)=QK(4)*ZG
C
C CONSTRUCT THE E+ MOMENTUM IN THE E+E- REST FRAME
      H(4)=E*DSQRT(1.-QK(4)/E)
      H(1)=H(4)*SR*DSIN(FR)
      H(2)=H(4)*SR*DCOS(FR)
      H(3)=H(4)*CR
      XH=H(4)**2-H(3)**2-H(2)**2-H(1)**2
C
C BOOST TO OBTAIN THE LAB FRAME VALUE
      QP(4)=((2.*E-QK(4))*H(4)
     .       -H(3)*QK(3)-H(2)*QK(2)-H(1)*QK(1))/(2.*H(4))
      R=(QP(4)+H(4))/(2.*E-QK(4)+2.*H(4))
      DO 5 I=1,3
    5 QP(I)=H(I)-QK(I)*R
C
C CONSTRUCT THE E- MOMENTUM FROM CONSERVATION
      QM(4)=2.*E-QP(4)-QK(4)
      DO 6 I=1,3
    6 QM(I)=-QP(I)-QK(I)
C
      END
C-----------------------------------------------------------------------
      SUBROUTINE SETUP2(E,XK0,XK1,XMZ,XGZ,GV,GA,SIGMA)
C
C SUBGENERATOR 2:
C FINAL-STATE RADIATION IN Z0 ANNIHILATION GRAPHS
C E = BEAM ENERGY IN GEV
C XK0 = MINIMUM PHOTON ENERGY (FRACTION OF E)
C XK1 = MAXIMUM PHOTON ENERGY (FRACTION OF E)
C XMZ = Z0 MASS IN GEV
C XGZ = Z0 WIDTH IN GEV
C GV = VECTOR COUPLING BETWEEN E AND Z0
C GA = AXIAL VECTOR COUPLING BETWEEN E AND Z0
C
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / G2COM / EBEAM,  XME,  E0,  EMAX,
     .                 YK1,  YK2,  YV1,  YF1,
     .                 TRYK,  PASK
      COMMON / UNICOM / IIN,IUT
      EXTERNAL RNDM
      REAL*4 RNDM
C
C THE INTEGRATED PHOTON SPECTRUM
      H(X)=XL*(2.*DLOG(X)-2.*X+X**2/2.)-2.*DILOG(X)
     . +(1.-X)*(3.-X)*DLOG(1.-X)/2.
     . -(1.-X)*(5.-X)/4.
C
      CALL OUTCRY('SETUP2')
C
C CHECK ON PHOTON ENERGIES
      IF(XK1.LE.XK0) THEN
                     SIGMA=0.D0
                     RETURN
                     ENDIF
C
C DEFINE CONSTANTS
      EBEAM=E
      XME=0.511D-03
      PI=3.1415926536D0
      EEL=DSQRT(4.*PI/137.036)
      XL=DLOG(4.*E**2/XME**2)
C
C TOTAL APPROXIMATE CROSS SECTION
      E0=XK0*E
      EMAX=XK1*E
      HXK1=H(XK1)
      HXK0=H(XK0)
      SIGMA=4970.392/E**2
     . *8.*PI**2*E**2*(HXK1-HXK0)
     . *    (( EEL**2*(GV**4+6.*GV**2*GA**2+GA**4)*4.*E**2
     .        +EEL**4*(GV**2+GA**2)*(8.*E**2-2.*XMZ**2)   )/
     .                  ((4.*E**2-XMZ**2)**2+XMZ**2*XGZ**2)
     .                                    +EEL**6/(4.*E**2)   )
C
C INITIALIZE CONSTANTS FOR EVENT GENERATION
      YK1=XL
      YK2=(E**2+(E-E0)**2)*DLOG(4.*E*(E-E0)/XME**2)
      YV1=XME**2/4./E
      YF1=2.*PI
C
C THE EFFICIENCY OF THE PHOTON ENERGY LOOP
      TRYK=0.
      PASK=0.
C
C PRINT THE RESULTS SO FAR
      WRITE(IUT,1) XME,    PI,   EEL,    XL,
     .            E0,  EMAX, SIGMA,   YK1,
     .           YK2,   YV1,   YF1,  TRYK,
     .          PASK
    1 FORMAT(' SETUP2 :',4D14.6)
      END
C-----------------------------------------------------------------------
      SUBROUTINE GENER2(QP,QM,QK,WM)
C
C GENERATION OF THE FINAL-STATE MOMENTA
      IMPLICIT REAL*8(A-H,O-Z)
      DIMENSION QP(4),QM(4),QK(4)
      COMMON / EFFIC2 / EFFK
      COMMON / G2COM / E,  XME,  E0,  EMAX,
     .                 YK1,  YK2,  YV1,  YF1,
     .                 TRYK,  PASK
      EXTERNAL RNDM
      REAL*4 RNDM
C
C GENERATE THE PHOTON ENERGY BY MAPPING AND W.R.P.
    2 TRYK=TRYK+1.
C GB  QK(4)=(EMAX/E0)**RN(1.)*E0
      QK(4)=(EMAX/E0)**RNDM(1.)*E0
      W=(E**2+(E-QK(4))**2)*(YK1+DLOG(1.-QK(4)/E))/YK2
C GB  IF(W.LT.RN(2.)) GOTO 2
      IF(W.LT.RNDM(2.)) GOTO 2
      PASK=PASK+1.
      EFFK=PASK/TRYK
C
C GENERATE THE E+ ENERGY (N.B. NUMERICAL STABILITY)
      D=YV1*QK(4)/(E-QK(4))
C GB  V=DEXP(DLOG(D)+RN(3.)*DLOG(1.+QK(4)/D))-D
      V=DEXP(DLOG(D)+RNDM(3.)*DLOG(1.+QK(4)/D))-D
      QP(4)=E-V
C
C GENERATE THE OTHER TRIVIAL VARIABLES
C GB  FG=YF1*RN(4.)
      FG=YF1*RNDM(4.)
C GB  C=-1.+2.*RN(5.)
      C=-1.+2.*RNDM(5.)
C GB  FC=YF1*RN(6.)
      FC=YF1*RNDM(6.)
C
C CALCULATE THE MASS EFFECT FACTOR
      WM=1.-XME**2/2./(V+D)*QK(4)/(E**2+(E-QK(4))**2)
C
C CONSTRUCT THE E+ MOMENTUM
      SC=DSQRT(1.-C*C)
      C1=DCOS(FC)
      S1=DSIN(FC)
      QP(1)=QP(4)*SC*S1
      QP(2)=QP(4)*SC*C1
      QP(3)=QP(4)*C
C
C CONSTRUCT THE PHOTON MOMENTUM
      VG=2.*(E-QK(4))*V/(QK(4)*(E-V))
      CG=VG-1.
      SG=DSQRT(VG*(2.-VG))
      HX=QK(4)*SG*DSIN(FG)
      HY=QK(4)*SG*DCOS(FG)
      HZ=QK(4)*CG
      XH=QK(4)**2-HX**2-HY**2-HZ**2
      QK(1)=  C1*HX + S1*C*HY + S1*SC*HZ
      QK(2)= -S1*HX + C1*C*HY + C1*SC*HZ
      QK(3)=           -SC*HY      +C*HZ
C
C CONSTRUCT E- MOMENTUM FROM CONSERVATION
      QM(4)=2.*E-QP(4)-QK(4)
      DO 3 I=1,3
    3 QM(I)=-QP(I)-QK(I)
C
C SYMMETRIZE THE E+ AND E- MOMENTA
C GB  IF(RN(8.).LT..5D0) RETURN
      IF(RNDM(8.).LT..5D0) RETURN
      DO 4 I=1,4
      X=QP(I)
      QP(I)=QM(I)
    4 QM(I)=X
      END
C-----------------------------------------------------------------------
      SUBROUTINE SETUP3(E,XK0,XK1,XMZ,XGZ,GV,GA,SIGMA)
C
C SUBGENERATOR 3:
C INITIAL-STATE RADIATION IN Z0 ANNIHILATION GRAPH
C E = BEAM ENERGY IN GEV
C XK0 = MINIMUM PHOTON ENERGY (FRACTION OF E)
C XK1 = MAXIMUM PHOTON ENERGY (FRACTION OF E)
C XMZ = Z0 MASS IN GEV
C XGZ = Z0 WIDTH IN GEV
C GV = VECTOR COUPLING BETWEEN EN AND Z0
C GA = AXIAL VECTOR COUPLING BETWEEN E AND Z0
C
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / PARAM3 / Z,G2
      COMMON / G3COM / EBEAM,  EPS,
     .                 YZ1,  YZ2,  YF1
      COMMON / UNICOM / IIN,IUT
      EXTERNAL FOT
      EXTERNAL RNDM
      REAL*4 RNDM
C
C THE INTEGRATED PHOTON SPECTRUM
      HFUN(X)=H1*DLOG(X)+H2*DLOG((X-Z)**2+G2)/2.
     .    +H3*DATAN((X-Z)/G)+H4*X
C
      CALL OUTCRY('SETUP3')
C
C CHECK PHOTON ENERGIES
      IF(XK1.LE.XK0) THEN
                     SIGMA=0.D0
                     RETURN
                     ENDIF
C
C DEFINE CONSTANTS
      EBEAM=E
      XME=0.511D-03
      PI=3.1415926536D0
      EEL=DSQRT(4.*PI/137.036D0)
      XL=DLOG(4.*E**2/XME**2)
C
C DEFINE SPECTRUM PARAMETERS; TOTAL APPROXIMATE CROSS SECTION
      Z=1.-XMZ**2/4./E**2
      G=XMZ*XGZ/4./E**2
      G2=G**2
      H1=2./(Z**2+G2)
      H2=-H1+3.-2.*Z
      H3=Z/G*H1+(-4.+3.*Z-Z**2+G2)/G
      H4=-1.
      HFAC=HFUN(XK1)-HFUN(XK0)
      SIGMA=4970.392/E**2
     . *EEL**2/4.*(GV**4+6.*GV**2*GA**2+GA**4)*8.D0*PI*PI
     . *XL*HFAC
C
C SET UP THE PHOTON SPECTRUM WITH ITERATED INTERVAL STRETCHING
      CALL IIS(1000,10,XK0,XK1,FOT)
C
C INITIALZIE CONSTANTS FOR THE EVENT GENERATION
      EPS=XME**2/2./E**2
      YZ1=DLOG(EPS)
      YZ2=DLOG((2.+EPS)/EPS)
      YF1=2.*PI
C
C PRINT THE RESULTS SO FAR
      WRITE(IUT,1) XME,    PI,   EEL,    XL,
     .             Z,     G,    G2,    H1,
     .            H2,    H3,    H4,  HFAC,
     .         SIGMA,   EPS,   YZ1,   YZ2,
     .           YF1
    1 FORMAT(' SETUP3 :',4D14.6)
      END
C-----------------------------------------------------------------------
      SUBROUTINE GENER3(QP,QM,QK,WM)
C
C GENERATION OF THE FINAL-STATE MOMENTA
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / G3COM / E,  EPS,
     .                 YZ1,  YZ2,  YF1
      DIMENSION QP(4),QM(4),QK(4),H(4)
      EXTERNAL RNDM
      REAL*4 RNDM
C
C GENERATE THE PHOTON ENERGY BY USING THE SET-UP HISTOGRAM
      CALL PAK(XK)
      QK(4)=E*XK
C
C GENERATE THE PHOTON POLAR ANGLE (N.B. STABILITY)
C GB  V=DEXP(YZ1+RN(3.)*YZ2)-EPS
      V=DEXP(YZ1+RNDM(3.)*YZ2)-EPS
      ZG=1.-V
      SG=DSQRT(V*(2.-V))
C GB  IF(RN(4.).GT..5D0) ZG=-ZG
      IF(RNDM(4.).GT..5D0) ZG=-ZG
C
C GENERATE THE OTHER TRIVIAL VARIABLES
C GB  FG=YF1*RN(5.)
      FG=YF1*RNDM(5.)
C GB  FR=YF1*RN(6.)
      FR=YF1*RNDM(6.)
C GB  CR=-1.+2.*RN(7.)
      CR=-1.+2.*RNDM(7.)
      SR=DSQRT(1.-CR*CR)
C
C CALCULATE THE MASS EFFECT FACTOR
      WM=1.-EPS/(EPS+V)*2.*E*(E-QK(4))/(E**2+(E-QK(4))**2)
C
C CONSTRUCT THE PHOTON MOMENTUM IN THE LAB
      QK(1)=QK(4)*SG*DSIN(FG)
      QK(2)=QK(4)*SG*DCOS(FG)
      QK(3)=QK(4)*ZG
C
C CONSTRUCT THE E+ MOMENTUM IN THE E+E- REST FRAME
      H(4)=E*DSQRT(1.-QK(4)/E)
      H(1)=H(4)*SR*DSIN(FR)
      H(2)=H(4)*SR*DCOS(FR)
      H(3)=H(4)*CR
C
C BOOST TO OBTAIN THE LAB FRAME VALUE
      QP(4)=((2.*E-QK(4))*H(4)
     .       -H(3)*QK(3)-H(2)*QK(2)-H(1)*QK(1))/(2.*H(4))
      R=(QP(4)+H(4))/(2.*E-QK(4)+2.*H(4))
      DO 4 I=1,3
    4 QP(I)=H(I)-QK(I)*R
C
C CONSTRUCT THE E- MOMENTUM FROM CONSERVATION
      QM(4)=2.*E-QP(4)-QK(4)
      DO 5 I=1,3
    5 QM(I)=-QP(I)-QK(I)
C
      END
C-----------------------------------------------------------------------
      SUBROUTINE SETUP4(E,XK0,XK1,THMIN,THMAX,SIGMA)
C
C SUBGENERATOR 4:
C RADIATION IN QED T-CHANNEL GRAPHS
C E=BEAM ENERGY IN GEV
C XK0 = MINIMUM PHOTON ENERGY (FRACTION OF E)
C XK1 = MAXIMUM PHOTON ENERGY (FRACTION OF E)
C THMIN = MINIMUM SCATTERING ANGLE OF E+,E- (DEGREES)
C THMAX = MAXIMUM SCATTERING ANGLE OF E+,E- (DEGREES)
C
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / G4COM / EBEAM, E0,  XL,  EPS,
     .                 YK1,  YK2,  YK3,  YC1,  YC2,  YC3,
     .                 YF1,  YV1,  TRYK,  PASK,  TRYC,  PASC
      COMMON / EFFIC4 / EFKPR,EFKPO,EFCPR,EFCPO
      COMMON / UNICOM / IIN,IUT
      EXTERNAL RNDM
      REAL*4 RNDM
C
C INTEGRATED PHOTON SPECTRUM
      H4(X)=2.*DLOG(X)-2.*X+X**2/2.
C
C INTEGRATED ANGULAR DISTRIBUTION
      C4(X)=(DLOG((1.-X)/2.)+XL+1.)/(1.-X)
C
      CALL OUTCRY('SETUP4')
C
C CHECK PHOTON ENERGIES
      IF(XK1.LE.XK0) THEN
                     SIGMA=0.D0
                     RETURN
                     ENDIF
C
C INITIALIZE CONSTANTS
      EBEAM=E
      XME=0.511D-03
      PI=3.1415926536D0
      EEL=DSQRT(4.*PI/137.036D0)
      XL=DLOG(4.*E**2/XME**2)
C
C TOTAL APPROXIMATE CROSS SECTION
      CMAX=DCOS(THMAX*PI/180.D0)
      CMIN=DCOS(THMIN*PI/180.D0)
      CFAC=C4(CMIN)-C4(CMAX)
      HFAC=H4(XK1)-H4(XK0)
      SIGMA=4970.392/E**2
     . *16.*PI**2*EEL**6*HFAC*CFAC
C
C INITIALIZE CONSTANTS FOR EVENT GENERATION
      E0=E*XK0
      EMAX=E*XK1
      YK1=EMAX/E0
      YK2=E**2
      YK3=E**2+(E-E0)**2
      YC1=1./(1.-CMAX)
      YC2=1./(1.-CMIN)-1./(1.-CMAX)
      YC3=XL+DLOG((1.-CMAX)/2.)
      YF1=2.*PI
      EPS=XME**2/2./E**2
      YV1=1.+XME**2/E**2
C
C THE EFFICIENCY OF THE PHOTON ENERGY LOOP
      EFKPR=HFAC/(1.+(1.-E0/E)**2)/DLOG(EMAX/E0)
      TRYK=0.
      PASK=0.
C
C THE EFFICIENCY OF THE SCATTERING ANGLE LOOP
      EFCPR=CFAC/(YC3*(1./(1.-CMIN)-1./(1.-CMAX)))
      TRYC=0.
      PASC=0.
C
C PRINT THE RESULTS SO FAR
      WRITE(IUT,1) XME,    PI,   EEL,    XL,
     .          CMAX,  CMIN,  HFAC,  CFAC,
     .         SIGMA,    E0,  EMAX,   YK1,
     .           YK2,   YK3,   YC1,   YC2,
     .           YC3,   YF1,   EPS,   YV1,
     .          EFKPR, TRYK,  PASK, EFCPR,
     .          TRYC,  PASC
    1 FORMAT(' SETUP4 :',4D14.6)
      END
C-----------------------------------------------------------------------
      SUBROUTINE GENER4(QP,QM,QK,WM)
C
C GENERATION OF THE FINAL-STATE MOMENTA
      IMPLICIT REAL*8(A-H,O-Z)
      DIMENSION QP(4),QM(4),QK(4)
      COMMON / EFFIC4 / EFKPR,EFKPO,EFCPR,EFCPO
      COMMON / G4COM / E, E0,  XL,  EPS,
     .                 YK1,  YK2,  YK3,  YC1,  YC2,  YC3,
     .                 YF1,  YV1,  TRYK,  PASK,  TRYC,  PASC
      EXTERNAL RNDM
      REAL*4 RNDM
C
C GENERATE THE PHOTON SPECTRUM BY MAPPING AND W.R.P.
    2 CONTINUE
      TRYK=TRYK+1.
C GB  QK(4)=E0*YK1**RN(1.)
      QK(4)=E0*YK1**RNDM(1.)
      W=(YK2+(E-QK(4))**2)/YK3
C GB  IF(W.LT.RN(2.)) GOTO 2
      IF(W.LT.RNDM(2.)) GOTO 2
      PASK=PASK+1.
      EFKPO=PASK/TRYK
C
C GENERATE THE SCATTERING ANGLE BY MAPPING AND W.R.P.
    3 CONTINUE
      TRYC=TRYC+1.
C GB  C=1.-1./(YC1+RN(3.)*YC2)
      C=1.-1./(YC1+RNDM(3.)*YC2)
      W=(DLOG((1.-C)/2.)+XL)/YC3
C GB  IF(W.LT.RN(4.)) GOTO 3
      IF(W.LT.RNDM(4.)) GOTO 3
      PASC=PASC+1.
      EFCPO=PASC/TRYC
      SC=DSQRT(1.-C*C)
C
C GENERATE THE U VALUE FOR THE FEYNMAN TRICK
      U0=EPS/(1.-C)
      U1=1.+U0
C GB  VU=(U1/U0)**RN(5.)*U0-U0
      VU=(U1/U0)**RNDM(5.)*U0-U0
      U=VU
C GB  IF(RN(6.).GT.0.5D0) U=1.-VU
      IF(RNDM(6.).GT.0.5D0) U=1.-VU
C
C GENERATE THE ANGLE OF THE PHOTON WRT THE VECTOR E(U)
      EU2=2.*(1.-C)*(VU+U0)*(U1-VU)
      EUV=DSQRT(YV1-EU2)
C GB  R=RN(7.)
      R=RNDM(7.)
      V1=2.*EU2*(1.-R)/(EU2+2.*R*EUV*(1.+EPS+EUV))
      C1=1.-V1
      SC1=DSQRT(V1*(2.-V1))
C GB  F1=YF1*RN(8.)
      F1=YF1*RNDM(8.)
      CF1=DCOS(F1)
      SF1=DSIN(F1)
C
C CALCULATE THE MASS EFFECT FACTOR
      R=VU*(SC*SC1*CF1+(1.-C)*C1)+V1
      R=(R+(2.*EPS-EU2)/(EUV+1.))/EUV
      WM=1.-2.*E*(E-QK(4))/(E**2+(E-QK(4))**2)*EPS/(EPS+R)
C
C ROTATE THE PHOTON MOMENTUM TO ACCOUNT FOR THE E(U) DIRECTION
      UU=U-1.-U*C
      XK1X=(SC1*CF1*UU-U*C1*SC)/EUV
      XK1Y=SC1*SF1
      XK1Z=(U*SC*SC1*CF1+UU*C1)/EUV
      XKX=XK1X**2+XK1Y**2+XK1Z**2-1.D0
C
C CONSTRUCT THE E+ MOMENTUM
      CG=SC*XK1X+C*XK1Z
      QP(4)=2.*E*(E-QK(4))/(2.*E-QK(4)*(1.-CG))
C GB  F=YF1*RN(9.)
      F=YF1*RNDM(9.)
      CF=DCOS(F)
      SF=DSIN(F)
      QP(1)=QP(4)*SC*SF
      QP(2)=QP(4)*SC*CF
      QP(3)=QP(4)*C
C
C CONSTRUCT THE PHOTON MOMENTUM
      QK(1)=QK(4)*(XK1X*SF-XK1Y*CF)
      QK(2)=QK(4)*(XK1X*CF+XK1Y*SF)
      QK(3)=QK(4)*(XK1Z           )
C
C CONSTRUCT THE E- MOMENTUM
      QM(4)=2.*E-QP(4)-QK(4)
      DO 4 I=1,3
    4 QM(I)=-QP(I)-QK(I)
C
C SYMMETRIZE BETWEEN "E+" AND "E-" IN 50% OF THE CASES
C GB  IF(RN(10.).LT.0.5D0) RETURN
      IF(RNDM(10.).LT.0.5D0) RETURN
      DO 5 I=1,3
      QK(I)=-QK(I)
      R=QP(I)
      QP(I)=-QM(I)
    5 QM(I)=-R
      R=QP(4)
      QP(4)=QM(4)
      QM(4)=R
C
      END
C-----------------------------------------------------------------------
      SUBROUTINE SETUP5(E,XMZ,XGZ,THMIN,THMAX,SIGMA)
C
C SUBGENERATOR 5:
C SOFT BREMSSTRAHLUNG AND VIRTUAL CORRECTIONS
C E = BEAM ENERGY IN GEV
C THMIN = MINIMUM E+E- POLAR SCATTERING ANGLE
C THMAX = MAXIMUM E+E- POLAR SCATTERING ANGLE
C
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / G5COM / EBEAM,XMIN,XRAN,HM,TRY,PAS,H(1000),AZ
      COMMON / EFFIC5 / EFPRIO,EFPOST
      COMMON / UNICOM / IIN,IUT
      EXTERNAL RNDM
      REAL*4 RNDM
      DATA PI/3.1415926536D0/
C
      CALL OUTCRY('SETUP5')
C
      EBEAM=E
C
C PARAMETERS OF THE NUMERICAL EXAMINATION STEP
      S=4.D0*E**2
      AEMP=1.D-02
      AZ=AEMP*S**2/((S-XMZ**2)**2+XMZ**2*XGZ**2)
      CMIN=DCOS(PI*THMAX/180.D0)
      CMAX=DCOS(PI*THMIN/180.D0)
      XMIN=AZ*CMIN+1.D0/(1.D0-CMIN)
      XMAX=AZ*CMAX+1.D0/(1.D0-CMAX)
      NP=1000
      NP1=NP-1
      XP1=1.D0*NP1
      XRAN=XMAX-XMIN
C
C PREPARE THE SPLINE INTERPOLATIONS
      THJUMP=20.D0
      IF(THMIN.GE.THJUMP.OR.THMAX.LE.THJUMP)
     .    THJUMP=(THMIN+THMAX)/2.D0
      CALL STUDYF(THMIN,THMAX,THJUMP,40,20)
C
C COMPUTE THE SOFT CROSS SECTION USING THE TRAPEZOIDAL RULE
      HM=0.D0
      DO 1 J=1,NP
      CALL TELLER(J,100,'SOFT INT. ')
      H(J)=SOFT(  XMIN+XRAN*(1.D0*J-1.D0)/(1.D0*NP-1.D0)  )
    1 HM=DMAX1(HM,H(J))
      HM=HM*1.01D0
      WRITE(IUT,9)
    9 FORMAT(' SETUP5: END OF THE SOFT CROSS SECTION PART')
C
C COMPUTE THE TOTAL SOFT CROSS SECTION
      SIGMA=0.
      DO 2 J=1,NP
    2 SIGMA=SIGMA+H(J)
      SIGMA=SIGMA-(H(1)+H(NP))/2.
      SIGMA=SIGMA*XRAN/(1.D0*NP-1.D0)
      TRY=0.
      PAS=0.
C
C ESTIMATED EFFICIENCY OF THE ANGLE GENERATION LOOP
      EFPRIO=SIGMA/(HM*XRAN)
C
C PRINT THE RESULTS SO FAR
      WRITE(IUT,3)   E, THMIN, THMAX,  XMIN,
     .          XMAX,  XRAN,      HM, SIGMA,
     .          TRY,   PAS,   EFPRIO,    AZ
    3 FORMAT(' SETUP5 :',4D14.6)
      END
C-----------------------------------------------------------------------
      SUBROUTINE GENER5(QP,QM,QK)
C
C GENERATION OF THE FINAL-STATE MOMENTA
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / EFFIC5 / EFPRIO,EFPOST
      COMMON / G5COM / E,XMIN,XRAN,HM,TRY,PAS,H(1000),AZ
      DIMENSION QP(4),QM(4),QK(4)
      EXTERNAL RNDM
      REAL*4 RNDM
C
C GENERATE THE SCATTERING ANGLE BY W.R.P. AND MAPPING
    4 TRY=TRY+1.
C GB  X=XMIN+XRAN*RN(1.)
      X=XMIN+XRAN*RNDM(1.)
      HX=SOFT(X)
      WX=HX/HM
C GB  IF(WX.LT.RN(2.)) GOTO 4
      IF(WX.LT.RNDM(2.)) GOTO 4
      C=2.D0*(X-1.D0)/(AZ+X+DSQRT((AZ-X)**2+4.D0*AZ))
      PAS=PAS+1.
      EFPOST=PAS/TRY
C
C GENERATE THE AZIMUTHAL ANGLE
C GB  FI=2.*3.1415926536D0*RN(3.)
      FI=2.*3.1415926536D0*RNDM(3.)
      S=DSQRT(1.-C**2)
C
C CONSTRUCT THE E+ MOMENTUM
      QP(4)=E
      QP(3)=E*C
      QP(2)=E*S*DCOS(FI)
      QP(1)=E*S*DSIN(FI)
C
C CONSTRUCT THE E- MOMENTUM
      DO 5 J=1,3
    5 QM(J)=-QP(J)
      QM(4)=E
C
C THE PHOTON MOMENTUM IS SET TO ZERO IN THE SOFT CASE
      DO 6 J=1,4
    6 QK(J)=0.
      END
C-----------------------------------------------------------------------
      FUNCTION DILOG(X)
      IMPLICIT REAL*8(A-H,O-Z)
      Z=-1.644934066848226D0
      IF(X .LT.-1.D0) GO TO 1
      IF(X .LE. 0.5D0) GO TO 2
      IF(X .EQ. 1.D0) GO TO 3
      IF(X .LE. 2.D0) GO TO 4
C
      Z=3.289868133696453D0
    1 T=1.D0/X
      S=-0.5D0
      Z=Z-0.5D0*DLOG(DABS(X))**2
      GO TO 5
C
    2 T=X
      S=0.5D0
      Z=0.D0
      GO TO 5
C
    3 DILOG=1.644934066848226D0
      RETURN
C
    4 T=1.D0-X
      S=-0.5D0
      Z=1.644934066848226D0-DLOG(X)*DLOG(DABS(T))
C
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
      DILOG=S*T*(A-B)+Z
C
      END
C-----------------------------------------------------------------------
      SUBROUTINE IIS(N,ITER,X1,XN,FUNC)
C
C ITERATED INTERVAL STRETCHING ROUTINE.
C IT TRIES TO PUT THE FUNCTION F ON THE INTERVAL [X0,X1]
C INTO A HISTOGRAM WITH N BINS. USINF ITER ITERATIONS
C IT TRIES TO MAKE ALL BINS HAVE THE SAME AREA.
C
      IMPLICIT REAL*8(A-H,O-Z)
      DIMENSION F(1000),A(1000),Y(1000),Z(1000),XNEW(1000)
      COMMON / IISCOM / X(1000),M
      COMMON / UNICOM / IIN,IUT
C
      CALL OUTCRY('I.I.S.')
C
C PRINT OUT THE PARAMETERS
      WRITE(IUT,1) X1,XN,N,ITER
    1 FORMAT(' I.I.S. : PARAMETERS OF INTERVAL STRETCHING:',/,
     .       ' I.I.S. : LOWEST  VARIABLE VALUE   : ',D10.3,/,
     .       ' I.I.S. : HIGHEST VARIABLE VALUE   : ',D10.3,/,
     .       ' I.I.S. : NO. OF POINTS            : ',I5,/,
     .       ' I.I.S. : NO. OF ITERATIONS        : ',I3)
C
C INITIALIZE BY CHOOSING EQUIDISTANT X VALUES
      IT=0
      M=N-1
      DX=(XN-X1)/(1.D0*M)
      X(1)=X1
      DO 101 I=2,N
  101 X(I)=X(I-1)+DX
C
C STARTING POINT FOR ITERATIONS
  100 CONTINUE
C
C CALCULATE FUNCTION VALUES
      DO 102 I=1,N
  102 F(I)=FUNC(X(I))
C
C CALCULATE BIN AREAS
      DO 103 I=1,M
  103 A(I)=(X(I+1)-X(I))*(F(I+1)+F(I))/2.
C
C CALCULATE CUMULATIVE SPECTRUM Y VALUES
      Y(1)=0.D0
      DO 104 I=2,N
  104 Y(I)=Y(I-1)+A(I-1)
C
C PUT EQUIDISTANT POINTS ON Y SCALE
      DZ=Y(N)/(1.D0*M)
      Z(1)=0.D0
      DO 105 I=2,N
  105 Z(I)=Z(I-1)+DZ
C
C DETERMINE SPACING OF Z POINTS IN BETWEEN Y POINTS
C FROM THIS, DETERMINE NEW X VALUES AND FINALLY REPLACE OLD VALUES
      XNEW(1)=X(1)
      XNEW(N)=X(N)
      K=1
      DO 108 I=2,M
  106 IF( Y(K+1) .GT. Z(I) ) GOTO 107
      K=K+1
      GOTO 106
  107 R= ( Z(I) - Y(K) ) / ( Y(K+1) - Y(K) )
  108 XNEW(I) = X(K) + ( X(K+1)-X(K) )*R
      DO 109 I=1,N
  109 X(I)=XNEW(I)
C
C CHECK ON END OF ITERATIONS AND RETURN
      IT=IT+1
      CALL TELLER(IT,1,'I.I.S.LOOP')
      WRITE(IUT,3) IT,Y(M)
    3 FORMAT(' I.I.S. : ITERATION ',I3,'  RESULT =',D15.6)
      IF(IT.LT.ITER) GOTO 100
      END
C-----------------------------------------------------------------------
      SUBROUTINE PAK(VALUE)
C
C GENERATOR OF NUMBER 'VALUE' DISTRIBUTED ACCORDING TO THE
C HISTOGRAM. IT IS OBTAINED ASSUMING THAT ALL BINS HAVE THE
C SAME AREA.
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / IISCOM / X(1000),M
      EXTERNAL RNDM
      REAL*4 RNDM
C
C GENERATE VALUE FROM CUMULATIVE SPECTRUM BINS
C GB  R=M*RN(1.D0)
      R=M*RNDM(1.D0)
      I=IDINT(R)
      S=R-I
      VALUE = X(I+1) + S*( X(I+2)-X(I+1) )
C
      END
C-----------------------------------------------------------------------
      FUNCTION FOT(X)
C
C THE PHOTON SPECTRUM
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / PARAM3 / Z,G2
      FOT=(1.-X)*(1.+(1.-X)**2)/X/((X-Z)**2+G2)
      END
C-----------------------------------------------------------------------
      SUBROUTINE STUDYF(THMIN,THMAX,THJUMP,NOP1,NOP2)
C SETS UP TWO UNIFORM GRIDS OF C VALUES AND OBTAINS
C THE VALUES OF THE FUNCTIONS D(SIGMA)/D(OMEGA) WITH THE
C CONTRIBUTION OF THE RUTHERFORD POLE DIVIDED OUT
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / NTPLCM / C(2,100),F(2,100),DEL(2),DEN(2),N(2)
      CALL OUTCRY('STUDYF')
      PI=4.D0*DATAN(1.D0)
      CMIN=DCOS(PI*THMAX/180.D0)
      CMAX=DCOS(PI*THMIN/180.D0)
      CJUMP=DCOS(PI*THJUMP/180.D0)
      N(1)=NOP1-1
      N(2)=NOP2-1
      DEL(1)=(CJUMP-CMIN)/(1.D0*N(1))
      DEL(2)=(CMAX-CJUMP)/(1.D0*N(2))
      DEN(1)=1.D0/(6.D0*DEL(1)**3)
      DEN(2)=1.D0/(6.D0*DEL(2)**3)
      DO 1 K=1,NOP1
      CALL TELLER(K,1,'SPLINELOOP')
      C(1,K)=CMIN+(K-1)*DEL(1)
    1 F(1,K)=SIGSOF(C(1,K))*(1.D0-C(1,K))**2
      DO 2 K=1,NOP2
      CALL TELLER(K,1,'SPLINELOOP')
      C(2,K)=CJUMP+(K-1)*DEL(2)
    2 F(2,K)=SIGSOF(C(2,K))*(1.D0-C(2,K))**2
      END
C-----------------------------------------------------------------------
      FUNCTION OBTANF(X)
C THE INTERPOLATION FORMULA FOR THE FUNCTION D(SIGMA)/D(OMEGA)
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / NTPLCM / C(2,100),F(2,100),DEL(2),DEN(2),N(2)
                      J=1
      IF(X.GE.C(2,1)) J=2
      K=IDINT((X-C(J,1))/DEL(J))+1
      IF(K.EQ.1) K=2
      IF(K.EQ.N(J)) K=N(J)-1
      X1=X-C(J,K-1)
      X2=X-C(J,K)
      X3=X-C(J,K+1)
      X4=X-C(J,K+2)
      OBTANF=(      X1*X2*X3*F(J,K+2)
     .        -3.D0*X1*X2*X4*F(J,K+1)
     .        +3.D0*X1*X3*X4*F(J,K)
     .             -X2*X3*X4*F(J,K-1))*DEN(J)/(1.D0-X)**2
      END
C-----------------------------------------------------------------------
      FUNCTION SOFT(U)
C PREPARES THE VALUES D(SIGMA)/D(OMEGA) GIVEN BY
C THE FUNCTION 'SIGSOF' FOR USE IN ROUTINE 'SETUP5'
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / G5COM / EBEAM,XMIN,XRAN,HM,TRY,PAS,H(1000),AZ
      COMMON / UNICOM / IIN,IUT
      DATA PI/3.1415926536D0/
      C=2.D0*(U-1.D0)/(AZ+U+DSQRT((AZ-U)**2+4.D0*AZ))
      F=OBTANF(C)
      SOFT=2.*PI*F/(AZ+1.D0/(1.D0-C)**2)
      END
C-----------------------------------------------------------------------
      FUNCTION SETUPS(E,XMZ,XGZ,SW2,XMH,XMT,XK0)
C
C   VIRTUAL AND SOFT PHOTON CORRECTIONS TO
C   BHABHA SCATTERING , QED CORRECTIONS + WEAK CORRECTIONS
C
C     (CORRECTED VERSION, 15 NOV 85)
C
      IMPLICIT REAL*8(A-Z)
      INTEGER I,J,IIN,IUT
      DIMENSION MF(6,2),VF(6,2),M(6,2),VF2(6,2),AF2(6,2)
C GB  COMMON /BOS/MZ,MW,MH/LEPT/ME,MMU,MTAU
      COMMON /BOSON/MZ,MW,MH/LEPT/ME,MMU,MTAU
     .       /HAD/MU,MD,MS,MC,MB,MT
     .       /COUP/SW,CW,V,A,VU,AU,VD,AD
     .       /WIDTH/GZ
     .       /ALF/AL,ALPHA,ALFA
     .       /FERMI/MF,VF,M,VF2,AF2
     .       /CONV/CST
      COMMON /SVLCOM/ SVALUE,DEL
      COMMON / UNICOM / IIN,IUT
C
      CALL OUTCRY('SETUPS')
C
C START OF THE INPUT DATA AND ARGUMENT TRANSFER
C
C THE TOTAL INVARIANT MASS SQUARED
      SVALUE=4.*E*E
C
C MASS OF THE Z0
      MZ=XMZ
C
C SIN**2 OF THE ELECTROWEAK MIXING ANGLE
      SW=SW2
C
C MASS OF THE W BOSON
      CW=1.-SW
      MW=MZ*DSQRT(CW)
C
C MASS OF THE HIGGS BOSON
      MH=XMH
C
C MASSES OF THE FERMIONS: LEPTONS...
      ME=.511D-3
      MMU=.106D0
      MTAU=1.785D0
C
C ...AND QUARKS (THE TOP QUARK MASS IS STILL A FREE PARAMETER)
      MU=.032D0
      MD=.0321D0
      MS=.15D0
      MC=1.5D0
      MB=4.5D0
      MT=XMT
C
C PUT THE MASSES IN ARRAY FORM
      MF(1,1)=0.D0
      MF(2,1)=0.D0
      MF(3,1)=0.D0
      MF(1,2)=ME
      MF(2,2)=MMU
      MF(3,2)=MTAU
      MF(4,1)=MU
      MF(4,2)=MD
      MF(5,1)=MC
      MF(5,2)=MS
      MF(6,1)=MT
      MF(6,2)=MB
C
C THE COUPLING CONSTANTS
      SW1=DSQRT(SW)
      CW1=DSQRT(CW)
      A=-1.D0/(4.D0*SW1*CW1)
      V=(1.D0-4.D0*SW)*A
      VU=(8.D0/3.D0*SW-1.D0)*A
      VD=(1.D0-4.D0/3.D0*SW)*A
      AU=-A
      AD=A
C
C PUT THE COUPLING CONSTANTS IN ARRAY FORM
      VF(1,1)=-A
      VF(2,1)=-A
      VF(3,1)=-A
      VF(1,2)=V
      VF(2,2)=V
      VF(3,2)=V
      VF(4,1)=VU
      VF(5,1)=VU
      VF(6,1)=VU
      VF(4,2)=VD
      VF(5,2)=VD
      VF(6,2)=VD
C
C SQUARES OF COUPLINGS AMD MASSES
      DO 1 I=1,6
      DO 1 J=1,2
      M(I,J)=MF(I,J)**2
      VF2(I,J)=VF(I,J)**2
      AF2(I,J)=A*A
    1 CONTINUE
C
C KINEMATICAL VARIABLES : E IS THE BEAM ENERGY IN GEV
      W=2.D0*E
      S=W*W
      E=W/2.D0
C
C MAXIMUM ENERGY OF THE SOFT PHOTON, AS FRACTION OF THE BEAM ENERGY
      DEL=XK0
C
C NUMERICAL CONSTANTS
      ALFA=1./137.036D0
      PI=3.1415926536D0
      AL=ALFA/PI
      ALPHA=AL/4.
      CST=ALFA*ALFA/4.D0/S*389385.7D03
C
C END OF THE INPUT STEP
C
C CALCULATE THE Z0 WIDTH:
    3 A2=A*A
      MTZ=(MT/MZ)**2
      GZ=IMSZ(MZ**2)/MZ
      XGZ=GZ
      WRITE(IUT,1001) XGZ
 1001 FORMAT(' SETUPS : I FOUND A TOTAL Z0 WIDTH OF ',F10.4,' GEV'/,
     . ' ',50('-'))
      SETUPS=0.
      END
C-----------------------------------------------------------------------
      FUNCTION SIGSOF(C)
C GIVES THE CORRECTED FORM FOR D(SIGMA)/D(OMEGA)
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON /SVLCOM/ S,DEL
      COMMON / UNICOM / IIN,IUT
C
      T=-.5D0*(1.D0-C)*S
      CALL BABCOR(S,T,DEL,DSIG0,DSIG)
      SIGSOF=DSIG
      IF(SIGSOF.LT.0.D0) WRITE(IUT,4) SIGSOF,C
    4 FORMAT(' SIGSOF : VALUE =',D15.6,'    AT C = ',F8.5)
      END
C-----------------------------------------------------------------------
      SUBROUTINE BABCOR(S,T,DEL, DSIG0,DSIG)
C
C THE 'WORKING HORSE' THAT CALCULATES THE CORRECTED D(SIGMA)/D(OMEGA)
C
C   S,T ARE THE MANDELSTAM VARIABLES
C   DEL IS MAXIMUM PHOTON ENERGY / BEAM ENERGY
C   DSIG0: DIFFERENTIAL BORN CROSS SECTION (IN PBARN)
C   DSIG : DIFFERENTIAL CROSS SECTION WITH RAD. CORRECTIONS (PBARN)
C
C  MZ, MW, MH ARE THE BOSON MASSES, ME,...MT THE FERMION MASSES IN GEV.
C  SW = SIN**2 THETA-W, CW = COS**2 THETA-W, THETA-W = WEINBERG ANGLE.
C  V,A ARE THE LEPTONIC VECTOR AND AXIALVECTOR COUPLING CONSTANTS;
C  VU,AU THOSE OF I=1/2 QUARKS; VD,AD THOSE OF I=-1/2 QUARKS
C  (ALL NORMALIZED TO E=SQRT(4*PI*ALFA)).
C  GZ IS THE WIDTH OF THE Z IN GEV.
C  MF(I,J) IS THE ARRAY OF FERMION MASSES, WHERE I =1,..6 AND J=1,2;
C  LEPTONS(I=1,2,3) AND QUARKS(I=4,5,6);  J=1: UP,  J=2: DOWN MEMBERS.
C  VF IS THE CORRESPONDING ARRAY OF THE FERMION VECTOR COUPLINGS,
C  VF2, AF2 ARE THE CORRESPONDING ARRAYS OF THE VECTOR AND AXIALVECTOR
C  COUPLINGS SQUARED.
C  M IS THE ARRAY OF THE FERMION MASSES SQUARED.
C  ALFA = 1/137.036, ALPHA = ALFA/4*PI, AL = ALFA/PI
C*****************************************************************
      IMPLICIT REAL*8(A-Z)
      COMPLEX*16   CIR1,PIGS,PIGT,PIG,X1C,X2C,SP1,SP2,SPENCE,CHIS,
     1             TGZS,TGZTS,TZZTS,TZBZS,TZBZTS,TWZS,TWZTS,TGVZS,
     2             TGZ5S,TZZZ5S,TGGZS,TGGZTS,TGZZST,TGZZTS,TGGVT,
     3             TGGVS,TGVZST,TGVZTS,TGVZT,TGZVS,TGZVST,TGZVTS,
     4             TGZVT,TZVZS,TZVZST,TZVZTS,TZVZT,TGGVST,TGGVTS,
     5             FZVS,FZAS,FZVT,FZAT,FGVS,FGAS,FGVT,FGAT,
     6             CFZVS,CFZAS,CFGVS,CFGAS,FS1,FS2,FT1,FT2,
     7             ZS,PROP,PIZS,CHITC,TGZST,TGZT
      DIMENSION MF(6,2),VF(6,2),M(6,2),VF2(6,2),AF2(6,2)
C GB  COMMON /BOS/MZ,MW,MH/LEPT/ME,MMU,MTAU
      COMMON /BOSON/MZ,MW,MH/LEPT/ME,MMU,MTAU
     1       /HAD/MU,MD,MS,MC,MB,MT
     2       /COUP/SW,CW,V,A,VU,AU,VD,AD
     3       /WIDTH/GZ
     4       /ALF/AL,ALPHA,ALFA
     5       /FERMI/MF,VF,M,VF2,AF2
     6       /CONV/CST
C
C  LEPTONIC COUPLING CONSTANTS
      SW1=DSQRT(SW)
      CW1=DSQRT(CW)
      A2=A*A
      V2=V*V
      W=V2+A2
      U=2.D0*V*A
C  Z PROPAGATOR
      MZ2=MZ**2
      G2=GZ**2
      SM=S-MZ2
      TM=T-MZ2
      DS=SM**2+MZ2*G2
      DT=TM**2+MZ2*G2
      CHISR=S*SM/DS
      CHITR=T*TM/DT
      CHISI=-MZ*GZ/DS*S
      CHITI=0.D0
      CHITC=DCMPLX(CHITR,CHITI)
      CHIT=T/TM
      CHIS=DCMPLX(CHISR,CHISI)
      CHIS2=S*S/DS
      CHIT2=(T/TM)**2
C   COMBINATION OF ANGLES
      C=1.D0+2.D0*T/S
      C2=1.D0+C*C
      C1=1.D0-C
      C0=1.D0+C
      C3=C0**2/C1
      C4=(C0**2+4.D0)/C1**2
      C5=(C0**2-4.D0)/C1**2
C
      PI=3.1415926536D0
C
C  NOW THE TIJ... ARE SPECIFIED        ********************
C
C  1) BORN TERMS:
      TGZS=(V2*C2+2.D0*A2*C)*CHIS
      TGZST=-W*C3*CHITC
      TGZTS=-W*C3*CHIS
      TGZT=(V2*C4+A2*C5)*2.D0*CHITC
C
      TZZS=(W*W*C2+U*U*2.D0*C)*CHIS2
      TZZTS=-(W*W+U*U)*C3*CHIS*CHITC
      TZZT=(W*W*C4+U*U*C5)*2.D0*CHIT2
C
C  2) TERMS APPEARING IN THE PHOTON-Z-MIXING PART
C
      TGGZS=2.D0*V*C2*CHIS
      TGGZST=-2.D0*V*C3*CHIT
      TGGZTS=-2.D0*V*C3*CHIS
      TGGZT=4.D0*V*C4*CHIT
C
      TGZZS=2.D0*(V*W*C2+A*U*2.D0*C)*CHIS2
      TGZZST=-2.D0*(V*W+A*U)*DCONJG(CHIS)*CHIT*C3
      TGZZTS=-2.D0*(V*W+A*U)*CHIS*CHIT*C3
      TGZZT=4.D0*(V*W*C4+A*U*C5)*CHIT2
C
C  3) TERMS WITH WEAK VERTEX CORRECTIONS
C
      CALL FGAM(S,FGVS,FGAS)
      CALL FGAM(T,FGVT,FGAT)
      CALL FZ(S,FZVS,FZAS)
      CALL FZ(T,FZVT,FZAT)
      CFGVS=DCONJG(FGVS)
      CFGAS=DCONJG(FGAS)
      CFZVS=DCONJG(FZVS)
      CFZAS=DCONJG(FZAS)
C
      TGGVS=2.D0*FGVS*C2
      TGGVST=-2.D0*FGVT*C3
      TGGVTS=-2.D0*FGVS*C3
      TGGVT=4.D0*FGVT*C4
C
      TGVZS= 2.D0*(V*(V*CFGVS+A*CFGAS)*C2+A*(V*CFGAS+A*CFGVS)*2.D0*C)
     1      *CHIS
      TGVZST=-2.D0*(W*CFGVS+U*CFGAS)*C3*CHIT
      TGVZTS=-2.D0*(W*FGVT+U*FGAT)*C3*CHIS
      TGVZT=4.D0*(V*(V*FGVT+A*FGAT)*C4+A*(V*FGAT+A*FGVT)*C5)*CHIT
C
      TGZVS=2.D0*(V*FZVS*C2+A*FZAS*2.D0*C)*CHIS
      TGZVST=-2.D0*(V*FZVT+A*FZAT)*C3*CHIT
      TGZVTS=-2.D0*(V*FZVS+A*FZAS)*C3*CHIS
      TGZVT=  (V*FZVT*C4+   A*FZAT*C5)*4.D0*CHIT
C
      FS1=V*CFZVS+A*CFZAS
      FS2=V*CFZAS+A*CFZVS
      FT1=V*FZVT+A*FZAT
      FT2=V*FZAT+A*FZVT
C
      TZVZS=2.D0*(W*FS1*C2+U*FS2*2.D0*C)*CHIS2
      TZVZST=-2.D0*(W*FS1+U*FS2)*C3*CHIT*DCONJG(CHIS)
      TZVZTS=-2.D0*(W*FT1+U*FT2)*C3*CHIT*CHIS
      TZVZT=4.D0*(W*FT1*C4+U*FT2*C5)*CHIT2
C
C
C  4) TERMS WHICH APPEAR WITH BOX DIAGRAMS
C
      TGZB=W*W*C2+U*U*2.D0*C
      TGZBST=-(W**2+U**2)*C3
      TGZBT=2.D0*(W*W*C4+U*U*C5)
C
      S16=16.D0*SW**2
      TGWS=C0*C0/S16
      TGWST=-2.D0*C3/S16
      TGWT=4.D0*(C0/C1)**2/S16
C
      W3=V2+3.D0*A2
      U3=3.D0*V2+A2
      TZBZS=(V2*W3*W3*C2+A2*U3*U3*2.D0*C)*CHIS
      TZBZST=-(V2*W3*W3+A2*U3*U3)*CHIT
      TZBZTS=TZBZST/CHIT*CHIS
      TZBZT=2.D0*(V2*W3*W3*C4+A2*U3*U3*C5)*CHIT
C
      VA2=(V+A)**2/S16
      TWZS=VA2*C0*C0*CHIS
      TWZST=-2.D0*VA2*C3*CHIT
      TWZTS=TWZST/CHIT*CHIS
      TWZT=4.D0*VA2*(C0/C1)**2*CHIT
C
      TGZ5S=(A2*C2+V2*2.D0*C)*CHIS
      TGZ5T =2.D0 *(A2*C4+V2*C5)*CHIT
      TZZ5S=(U*U*C2+W*W*2.D0*C)*CHIS2
      TZZ5T=2.D0*(U*U*C4+W*W*C5)*CHIT2
C
      TGZZ5S=U*U*C2+W*W*C*2.
      TGZZ5T=2.D0*(U*U*C4+W*W*C5)
      TZZZ5S=(A2*U3*U3*C2+V2*W3*W3*2.D0*C)*CHIS
      TZZZ5T=2.D0*(A2*U3*U3*C4+V2*W3*W3*C5)*CHIT
C
C END OF DEFINITION OF THE TIJ... TERMS      **************
C
C  NOW THE INFRARED CORRECTIONS ARE CALLED:
C  CIR: NON RESONANT
C  CIR1: INTERFERENCE RESONANT - NON RESONANT
C  CIR2: RESONANT
      CALL INFRA(DEL,S,T,CIR,CIR1,CIR2)
C  DEL: MAX. PHOTONENERGY/BEAM ENERGY
C  CIR1 COMPLEX, OTHERS REAL
C
C  SPECIFICATION OF THE FINITE QED CORRECTIONS:
      ME2=ME*ME
      BE=   DLOG(S/ME2)-1.D0
      X1=C1/2.D0
      X2=C0/2.D0
      DX1=DLOG(X1)
      DX2=DLOG(X2)
      X1C=DCMPLX(X1,0.D0)
      X2C=DCMPLX(X2,0.D0)
      SP1=SPENCE(X1C)
      SP2=SPENCE(X2C)
      X=DX1**2-DX2**2-2.D0*DREAL(SP1)+2.D0*DREAL(SP2)
      Z= 3.D0*BE-1.D0+2.D0*PI**2/3.D0
      Y=1.5D0*DX1-.5D0*DX1**2-PI**2/2.D0
C  TWO PHOTON BOXES
      CALL GBOX(S,T,V1S,V2S,A1S,A2S,V1T,V2T,A1T,A2T)
C  PHOTON-Z BOXES
      CALL GZBOX(S,T,V1ZS,V2ZS,A1ZS,A2ZS,V1ZT,V2ZT,A1ZT,A2ZT)
C  PHOTON VACUUM POLARIZATION
      PIGS=PIG(S)
      PIGT=PIG(T)
      RPIGS=DREAL(PIGS)
      IPIGS=DIMAG(PIGS)
      RPIGT=DREAL(PIGT)
C  SPECIFICATION OF THE WEAK CORRECTIONS:
C  Z BOSON SELF ENERGY
      RZS=RESZ(S)
      IZS=IMSZ(S)
      RZT=RESZ(T)
      ZS=DCMPLX(RZS,IZS)
      GM= MZ*GZ
      PROP= DCMPLX(SM,GM)
      PIZS=PROP/(SM+ZS)-1.D0
      PIZT=TM/(TM+RZT)-1.D0
      RPIZT=PIZT
      RPIZS=DREAL(PIZS)
      IPIZS=DIMAG(PIZS)
C  PHOTON-Z MIXING ENERGY
      RPIGZS=-RESGZ(S)/S
      IPIGZS=-IMSGZ(S)/S
      RPIGZT=-RESGZ(T)/T
C  HEAVY BOX DIAGRAMS
      CALL BOX(S,T,V1ZZS,V2ZZS,A1ZZS,A2ZZS,
     1             V1ZZT,V2ZZT,A1ZZT,A2ZZT,
     2             V1WS,V2WS,V1WT,V2WT)
C  COMPOSITION OF THE "REDUCED CROSS SECTIONS"     ***********
C  PHOTON-PHOTON
      DEL1=CIR+2.D0*RPIGS+AL*(X+Z+V1S+A1S*2.D0*C/C2)
      DEL2=CIR+RPIGS+RPIGT+AL*(X+Y+Z+.5D0*(V1S+V1T+A1S+A1T))
      DEL3=CIR+2.D0*RPIGT+AL*(X+2.D0*Y+Z+V1T+A1T*C5/C4)
      SGGS=C2*(1.D0+DEL1)+2.D0*DREAL(TGGVS)
     1    +AL*(TGZB*V1ZZS+TGZZ5S*A1ZZS+TGWS*V1WS)
      SGGST=-2.D0*C3*(1.D0+DEL2)
     1    +2.D0*DREAL(TGGVTS+TGGVST)
     2     +AL*(TGZBST*(V1ZZS+A1ZZS+V1ZZT+A1ZZT)
     3          +TGWST*(V1WS+V1WT))
      SGGT=2.D0*C4*(1.D0+DEL3)
     1     +2.D0*DREAL(TGGVT)
     2     +AL*(TGZBT*V1ZZT+TGZZ5T*A1ZZT+TGWT*V1WT)
C  PHOTON-Z-INTERFERENCE
      RCIR=DREAL(CIR1)
      ICIR=DIMAG(CIR1)
      DEL11=RCIR+RPIGS+AL*(X+Z+.5D0*(V1S+V1ZS))+RPIZS
      DEL12=ICIR-IPIGS+ALFA*(V2ZS-V2S)+IPIZS
      SGZS=2.D0*DREAL(TGZS)*(1.+DEL11)-DIMAG(TGZS)*DEL12*2.D0
     1    +AL*DREAL(TGZ5S)*(A1S+A1ZS)-2.D0*ALFA*DIMAG(TGZ5S)
     &                              *(A2ZS-A2S)
     2    +2.D0*DREAL(TGGZS)*RPIGZS -2.D0*DIMAG(TGGZS)*IPIGZS
     3    +2.D0*DREAL(TGVZS+TGZVS)
     4    +AL*(DREAL(TZBZS)*V1ZZS+DREAL(TZZZ5S)*A1ZZS
     5         +DREAL(TWZS)*V1WS)
     6    +2.D0*ALFA*(DIMAG(TZBZS)*V2ZZS+DIMAG(TZZZ5S)*A2ZZS
     7              +DIMAG(TWZS)*V2WS)
C
      DEL21=CIR+RPIGS+AL*(X+Y+Z+.5D0*(V1S+A1S+V1ZT+A1ZT))+RPIZT
      DEL22=IPIGS-ALFA*(1.5D0-V2S-A2S+V2ZT+A2ZT)
      SGZST=  DREAL(TGZST)*(1.D0+DEL21)*2.D0
     1      +2.D0*TGGZST*RPIGZT +2.D0*DREAL(TGVZST+TGZVST)
     2      +AL*(TZBZST*(V1ZZS+A1ZZS)+TWZST*V1WS)
      DEL31=RCIR+RPIGT+AL*(X+Y+Z+.5D0*(V1T+A1T+V1ZS+A1ZS))+RPIZS
      DEL32=ICIR-ALFA *(1.5D0 +A2T-V2ZS-A2ZS+V2T)+IPIZS
      SGZTS=2.D0*DREAL(TGZTS)*(1.D0+DEL31)-2.D0*DIMAG(TGZTS)*DEL32
     1     +2.D0*DREAL(TGGZTS)*RPIGZS-2.D0*DIMAG(TGGZTS)*IPIGZS
     2     +2.D0 *DREAL(TGVZTS+TGZVTS)
     3     +AL*(DREAL(TZBZTS)*(V1ZZT+A1ZZT)+DREAL(TWZTS)*V1WT)
     4     +2.D0*ALFA*(DIMAG(TZBZTS)*(V2ZZT+A2ZZT)
     5               +DIMAG(TWZTS)*V2WT)
      DEL41=CIR+RPIGT+AL*(X+2.D0*Y+Z+.5D0*(V1T+V1ZT))+RPIZT
      SGZT=2.D0*DREAL(TGZT)*(1.D0+DEL41)+    TGZ5T *AL*(A1T+A1ZT)
     1     +2.D0*TGGZT*RPIGZT+2.D0*DREAL(TGZVT+TGVZT)
     2     +AL*(TZBZT*V1ZZT+TZZZ5T*A1ZZT+TWZT*V1WT)
C  Z-Z TERMS
      DEL51=CIR2+AL*(X+Z+V1ZS)+2.D0*RPIZS
      SZZS=TZZS*(1.D0+DEL51)+TZZ5S*AL*A1ZS
     1    +2.D0*TGZZS*RPIGZS+2.D0*DREAL(TZVZS)
      DEL61=RCIR+AL*(X+Y+Z+.5D0*(V1ZS+V1ZT+A1ZS+A1ZT))+RPIZS+PIZT
      DEL62=ICIR-ALFA*(1.5D0+V2ZT-V2ZS+A2ZT-A2ZS)+IPIZS
      SZZST=2.D0*DREAL(TZZTS)*(1.+DEL61)-2.*DIMAG(TZZTS)*DEL62
     1     +2.D0*DREAL(TGZZTS)*(RPIGZS+RPIGZT)
     2     +2.D0*DREAL(TZVZTS+TZVZST)-2.D0*DIMAG(TGZZTS) *IPIGZS
      DEL71=CIR+AL*(X+2.D0*Y+Z +V1ZT )+2.D0*PIZT
      SZZT=TZZT*(1.D0+DEL71)+TZZ5T*AL*A1ZT
     1    +2.D0*TGZZT*RPIGZT+2.D0*DREAL(TZVZT)
C  RADIATIVELY CORRECTED CROSS SECTION
      DSIG=SGGS+SGZS+SZZS
     1    +SGGST+SGZST+SGZTS+SZZST
     3    +SGGT+SGZT+SZZT
      DSIG=DSIG*CST
C  CROSS SECTION IN LOWEST ORDER IN NBARN
      DSIG0=C2-2.D0*C3+2.D0*C4
     1     +2.D0*DREAL(TGZS+TGZTS)+(TGZT+TGZST)*2.D0
     2     +TZZS+2.D0*DREAL(TZZTS)+TZZT
      DSIG0=DSIG0*CST
      END
C-----------------------------------------------------------------------
      SUBROUTINE SETBAB(E,XMZ,XMH,XMT,THMIN,THMAX,XKMAX)
C***************************************************************
C
C     MONTE CARLO EVENT GENERATOR FOR THE PROCESSES
C
C         E+(PP) E-(PM)   ---->  E+(QP) E-(QM)
C
C     AND
C
C         E+(PP) E-(PM)   ----> E+(QP) E-(QM) PHOTON(QK)
C
C
C  AUTHORS: R. KLEISS, CERN
C           F.A. BERENDS, LEIDEN UNIVERSITY, LEIDEN, HOLLAND
C           W. HOLLIK, HAMBURG UNIVERSITY, HAMBURG, GERMANY
C
C
C  THE INPUT QUANTITIES ARE
C  E     = BEAM ENERGY, IN GEV;
C  XMZ   = MASS OF THE Z0 BOSON, IN GEV;
C  XMH   = MASS OF THE HIGGS BOSON, IN GEV;
C  XMT   = MASS OF THE TOP QUARK, IN GEV;
C  THMIN = MINIMUM POLAR SCATTERING ANGLE OF THE E+,E-, IN
C          DEGREES: IT MUST BE LARGER THAN 0 DEGREES BUT
C          SMALLER THAN THMAX;
C  THMAX = MAXIMUM POLAR SCATTERING ANGLE OF THE E+,E-, IN
C          DEGREES: IT MUST BE SMALLER THAN 180 DEGREES BUT
C          LARGER THAN THMIN;
C  XKMAX = MAXIMUM ENERGY OF THE BREMSSTRAHLUNG PHOTON, AS A
C          FRACTION OF THE BEAM ENERGY E: IT MAY BE SET
C          TO 1, IN WHICH CASE THE PROGRAM CHANGES ITS VALUE
C          TO THE ACTUAL KINEMATIC LIMIT.
C
C
C  IN THE PRESENT PROGRAM THE W MASS AND THE ELECTROWEAK MIXING ANGLE
C  ARE CALCULATED FROM THE (AS YET) MORE ACCURATELY KNOWN VALUE
C  OF THEMUON LIFETIME. THIS IS DONE BY ROUTINE FINDMW
C
C***************************************************************
      IMPLICIT REAL*8(A-H,O-Z)
      DIMENSION SIGMA(5),DEEL(5)
      COMMON / SB1COM / EBEAM,  CMIN,  CMAX
      COMMON / SB2COM / PRIORI(5),CUMUL(5)
      COMMON / SB3COM / WMEAN(5),WERRO(5),WMAXI(5),WEFFI(5)
      COMMON / SB4COM / WALL(3),WCON(3,5)
      COMMON / SB5COM / SIGAPP,  WMAXT,  NEV
      COMMON / WMXCOM / WMAX
      COMMON / REJCOM / IREJEC
      COMMON / UNICOM / IIN,IUT
      COMMON / FINCOM / XMW,S2W
      COMMON / WDISCO / WEIDIS(6,21)
C
      WRITE(IUT,901)
  901 FORMAT(' ',50('-')/,' WELCOME TO BHAHBA SCATTERING!'/,' ',50('-'))
C
C SIGNAL FOR START
      CALL OUTCRY('SETBAB')
C
C REPRODUCE THE INPUT PARAMETERS
      WRITE(IUT,1) E,XMZ,XMH,XMT,THMIN,THMAX,XKMAX
    1 FORMAT(
     .' YOU HAVE SUPPLIED THE FOLLOWING PARAMETERS :'/,
     .' BEAM ENERGY                     =',F10.4,' GEV'/,
     .' MASS OF THE Z0 BOSON            =',F10.4,' GEV'/,
     .' MASS OF THE HIGGS BOSON         =',F10.4,' GEV'/,
     .' MASS OF THE TOP QUARK           =',F10.4,' GEV'/,
     .' MINIMUM E+,E- SCATTERING ANGLE  =',F10.4,' DEGREES'/,
     .' MAXIMUM E+,E- SCATTERING ANGLE  =',F10.4,' DEGREES'/,
     .' MAXIMUM PHOTON ENERGY           =',F10.4,
     .' OF THE BEAM ENERGY'/,
     .' I AM NOW READY TO START THE INITIALIZATION.'/,' ',50(1H-))
C
C THE W MASS AND THE MIXING ANGLE
      CALL FINDMW(XMZ,XMT,XMH)
C
C THE LIMITS ON THE COSINES OF THE E+,- SCATTERING ANGLES
      EBEAM=E
      CMIN=DCOS(THMAX*3.1415926536D0/180.D0)
      CMAX=DCOS(THMIN*3.1415926536D0/180.D0)
C
C THE COUPLINGS IN THE STANDARD MODEL
      GA= - DSQRT(3.1415926536D0/137.036D0/4.D0/S2W/(1.-S2W))
      GV=GA*(1.-4.*S2W)
      SINK=S2W
C
C THE BOUNDARY BETWEEN SOFT AND HARD  BREMSSTRAHLUNG
      XK0=.001D0
C
C INITIALIZE THE SUBPROGRAMS
      CAL= SETUPS(E,XMZ,XGZ,SINK,XMH,XMT,XK0)
      CALL SETUP1(E,XK0,XKMAX,SIGMA(1))
      CALL SETUP2(E,XK0,XKMAX,XMZ,XGZ,GV,GA,SIGMA(2))
      CALL SETUP3(E,XK0,XKMAX,XMZ,XGZ,GV,GA,SIGMA(3))
      CALL SETUP4(E,XK0,XKMAX,THMIN,THMAX,SIGMA(4))
      CALL SETUP5(E,XMZ,XGZ,THMIN,THMAX,SIGMA(5))
      CALL SETUPW(E,XMZ,XGZ,GV,GA)
      CALL SETUPM(XMZ,XGZ,GV,GA)
C
C THE BORN LEVEL CROSS SECTION
      CALL BORN(E,XMZ,XGZ,GV,GA,THMIN,THMAX,CRBORN)
C
C THE TOTAL APPROXIMATE CROSS SECTION
      PRIORI(1)=1.
      PRIORI(2)=1.
      PRIORI(3)=1.
      PRIORI(4)=1.
      PRIORI(5)=1.
      SIGAPP=0.
      DO 2 I=1,5
    2 SIGAPP=SIGAPP+SIGMA(I)*PRIORI(I)
      DO 3 I=1,5
    3 DEEL(I)=SIGMA(I)*PRIORI(I)/SIGAPP
      CUMUL(1)=DEEL(1)
      DO 4 I=2,5
    4 CUMUL(I)=CUMUL(I-1)+DEEL(I)
      WRITE(IUT,5) (I,SIGMA(I),PRIORI(I),DEEL(I),CUMUL(I),I=1,5)
    5 FORMAT(' ',50(1H-)/,
     .' I HAVE NOW FINISHED THE INITIALIZATION STEP.'/,
     . ' THE CONTRIBUTIONS ARE THE FOLLOWING:'/,
     . ' 1: INITIAL-STATE RADIATION IN THE PHOTON S-CHANNEL,'/,
     . ' 2: FINAL-STATE RADIATION IN THE Z0 S-CHANNEL,'/,
     . ' 3: INITIAL-STATE RADIATION IN THE Z0 S-CHANNEL,'/,
     . ' 4: BREMSSTRAHLUNG IN THE PHOTON T-CHANNEL,'/,
     . ' 5: THE CONTRIBUTIONS FROM LOOPS AND SOFT PHOTONS.'/,
     . ' MY RESULTS SO FAR ARE:'/,
     . ' CONTR.NO.   APPR.XSEC.   WEIGHT    FRACTION    CUMUL.FR.'/,
     .  5(I7,D15.6,G13.3,G10.3,G12.3/ ),
     . ' WHERE:'/,
     . ' CONTR.NO. = THE NUMBER OF A PARTICULAR CONTRIBUTION,'/,
     . ' APPR.XSEC.= IS THE INTEGRAL OF THAT CONTRIBUTION,'/,
     . ' WEIGHT    = ITS ASSIGNED A-PRIORI WEIGHT,'/,
     . ' FRACTION  = ITS FRACTION OF THE TOTAL INTEGRAL, AND'/,
     . ' CUMUL.FR. = IS THE CUMULATIVE FRACTION.'/,' ',50(1H-))
C
C INITIALIZE THE BOOKKEEPING QUANTITIES
      NEV=0
      WMAXT=0.
      DO 7 I=1,3
      WALL(I)=0.
      DO 6 J=1,5
      WMEAN(J)=0.
      WERRO(J)=0.
      WMAXI(J)=0.
      WEFFI(J)=0.
      WCON(I,J)=0.
    6 CONTINUE
    7 CONTINUE
      DO 8 K=1,6
      DO 8 L=1,21
    8 WEIDIS(K,L)=0.D0
C
C DEFINE THE W.R.P. PROCEDURE DEFAULTS
      IREJEC=0
      WMAX=0.01D0
C
C END OF THE INITIALIZATION PROCEDURE
      WRITE(IUT,9)
    9 FORMAT(' READY TO START GENERATION   - - - -')
      END
C-----------------------------------------------------------------------
      SUBROUTINE GENBAB(PP,PM,QP,QM,QK,WEV,ICON)
C
C GENERATION OF THE PARTICLE MOMENTA.
C WEV = THE WEIGHT OF THE EVENT.
      IMPLICIT REAL*8(A-H,O-Z)
      DIMENSION PP(4),PM(4),QP(4),QM(4),QK(4)
      COMMON / WMXCOM / WMAX
      COMMON / REJCOM / IREJEC
      COMMON / SB1COM / E,  CMIN,  CMAX
      COMMON / SB2COM / PRIORI(5),CUMUL(5)
      COMMON / SB3COM / WMEAN(5),WERRO(5),WMAXI(5),WEFFI(5)
      COMMON / SB4COM / WALL(3),WCON(3,5)
      COMMON / SB5COM / SIGAPP,  WMAXT,  NEV
      COMMON / UNICOM / IIN,IUT
      COMMON / WDISCO / WEIDIS(6,21)
      EXTERNAL RNDM
      REAL*4 RNDM
C
C DEFINE THE BEAM MOMENTA
      PP(4)=E
      PP(3)=E
      PP(2)=0.
      PP(1)=0.
      PM(4)=E
      PM(3)=-E
      PM(2)=0.
      PM(1)=0.
C
C DECIDE ON THE CONTRIBUTION THAT WILL SUPPLY THIS EVENT
  101 CONTINUE
C GB  CHOOSE=RN(1.)
      CHOOSE=RNDM(1.)
                             ICON=1
      IF(CHOOSE.GT.CUMUL(1)) ICON=2
      IF(CHOOSE.GT.CUMUL(2)) ICON=3
      IF(CHOOSE.GT.CUMUL(3)) ICON=4
      IF(CHOOSE.GT.CUMUL(4)) ICON=5
C
C GENERATE THE TRIAL EVENT
      IF(ICON.EQ.1) CALL GENER1(QP,QM,QK,WMASS)
      IF(ICON.EQ.2) CALL GENER2(QP,QM,QK,WMASS)
      IF(ICON.EQ.3) CALL GENER3(QP,QM,QK,WMASS)
      IF(ICON.EQ.4) CALL GENER4(QP,QM,QK,WMASS)
      IF(ICON.EQ.5) CALL GENER5(QP,QM,QK)
C
C DEFINE THE EVENT WEIGHT. THERE ARE THREE POSSIBILITIES:
C A) EVENT OUTSIDE ACCEPTANCE FOR THE E+,- ANGLES: WEIGHT=0
C B) SOFT EVENT, I.E. FROM GENER5: WEIGHT=1
C C) HARD EVENT, I.E. FROM GENER1,2,3,4: NOW THE WEIGHT IS
C    THE RATIO OF THE EXACT MATRIX ELEMENT SQUARED OVER THE
C    SUM OF THE APPROXIMATE CONTRIBUTIONS (TAKING THEIR
C    A-PRIORI WEIGHTS INTO ACCOUNT)
C
C CHECK ON ACCEPTABILITY
      CP=QP(3)/QP(4)
      CM=-QM(3)/QM(4)
      IF(     CP.GT.CMIN. AND. CP.LT.CMAX
     .  .AND. CM.GT.CMIN. AND. CM.LT.CMAX ) GOTO 102
C
C CASE A: EVENT OUTSIDE THE DEFINED PHASE SPACE
      W=0.
      GOTO 105
C
C EVENT INSIDE ACCEPTED PHASE SPACE
  102 CONTINUE
      IF(ICON.NE.5) GOTO 103
C
C CASE B: SOFT PHOTON EVENT
      W=1./PRIORI(5)
      GOTO 105
C
C CASE C: HARD PHOTON EVENT
  103 CONTINUE
C
C THE EXACT MATRIX ELEMENT SQUARED
      CALL AMPLIT(PP,PM,QP,QM,QK,EXACT)
C
C THE SUM OF THE APPROXIMATIONS
      CALL APROXS(QP,QM,QK,APPR1,APPR2,APPR3,APPR4)
      APPROX= APPR1*PRIORI(1) + APPR2*PRIORI(2)
     .      + APPR3*PRIORI(3) + APPR4*PRIORI(4)
C
C THE EVENT WEIGHT: N.B. ALSO FINITE-MASS EFFECTS INCLUDED.
      W=EXACT*WMASS/APPROX
C THE EVENTY WEIGHT IS NOW DEFINED IN EVERY CASE
  105 WEV=W
C
C CHECK ON ANOMALOUS WEIGHT
      IF(WEV.GT.10.D0)
     . CALL PRNVEC(QP,QM,QK,APPR1,APPR2,APPR3,APPR4,WMASS,EXACT,ICON)
C
C DO THE BOOKKEEPING TO FIND THE EXACT CROSS SECTION,
C AND SOME HISTOGRAMMING OF THE EVENT WEIGHTS.
      WMAXT=DMAX1(WMAXT,WEV)
      WMAXI(ICON)=DMAX1(WMAXI(ICON),WEV)
      WALL(1)=WALL(1)+1.D0
      WALL(2)=WALL(2)+WEV
      WALL(3)=WALL(3)+WEV**2
      WCON(1,ICON)=WCON(1,ICON)+1.D0
      WCON(2,ICON)=WCON(2,ICON)+WEV
      WCON(3,ICON)=WCON(3,ICON)+WEV**2
C
C ADD TO THE COUNTER OF SUCCESFUL EVENTS
      NEV=NEV+1
C  IN ALL CASES REJECT EVENTS WITH 0 WEIGHT
      IF( WEV.EQ.0.D0) GO TO 101
C
C IF NO REJECTION IS ASKED FOR, RETURN; ELSE, APPLY REJECTION.
      IF(IREJEC.EQ.0) GOTO 107
      WRP=WEV/WMAX
      IF(WRP.GT.1.D0) WRITE(IUT,106) WEV,WMAX
  106 FORMAT(' GENBAB : WARNING ! AN EVENT OCCURS WITH WEIGHT',
     .       G10.3/,
     .       ' GENBAB :           WHICH IS MORE THAN THE ESTIMATED',
     .       ' MAXIMUM ',G10.3)
C GB  IF(WRP.LT.RN(2.)) GOTO 101
      IF(WRP.LT.RNDM(2.)) GOTO 101
      WEV=1.D0
  107 KWEIDI=IDINT(10.D0*WEV)+1
      IF(KWEIDI.GT.20) KWEIDI=21
      WEIDIS(ICON,KWEIDI)=WEIDIS(ICON,KWEIDI)+1.D0
      WEIDIS( 6  ,KWEIDI)=WEIDIS( 6  ,KWEIDI)+1.D0
      END
C-----------------------------------------------------------------------
      SUBROUTINE ENDBAB(SIGTOT,ERRTOT)
C
C ANALYSIS OF THE GENERATED EVENT WEIGHTS IN ORDER TO FIND THE
C EXACT TOTAL CROSS SECTION.
      IMPLICIT REAL*8(A-H,O-Z)
      LOGICAL HISTOS,REJECT
      CHARACTER*3 KSTR(22)
      COMMON / FLGCOM / HISTOS,REJECT
      COMMON / SB1COM / E,  CMIN,  CMAX
      COMMON / SB2COM / PRIORI(5),CUMUL(5)
      COMMON / SB3COM / WMEAN(5),WERRO(5),WMAXI(5),WEFFI(5)
      COMMON / SB4COM / WALL(3),WCON(3,5)
      COMMON / SB5COM / SIGAPP,  WMAXT,  NEV
      COMMON / UNICOM / IIN,IUT
      COMMON / WDISCO / WEIDIS(6,21)
      DATA KSTR/'0.0','0.1','0.2','0.3','0.4','0.5','0.6',
     .          '0.7','0.8','0.9','1.0','1.1','1.2','1.3',
     .          '1.4','1.5','1.6','1.7','1.8','1.9','2.0','   '/
C
      CALL OUTCRY('ENDBAB')
C
      WRITE(IUT,201) WALL(1),
     . (KSTR(K),KSTR(K+1),(WEIDIS(L,K),L=1,6),K=1,21)
  201 FORMAT(' ',50('-')/,' NUMBER OF EVENTS GENERATED SO FAR:',F10.1/,
     . ' DISTRIBUTION OF THE EVENT WEIGHTS IN WEIGHT INTERVALS:'/,
     . ' INTERVAL                    SUBGENERATORS'/,
     . ' FROM-TO         1',11X,'2',11X,'3',11X,'4',11X,'5',11X,'ALL'/,
     . (' ',A3,'-',A3,' ',6D12.4))
C
      WRITE(IUT,202)
  202 FORMAT('0STATISTICS OF THE EVENT WEIGHTS :'/,
     .' CONTR.NO   SUM(W**0)  SUM(W**1) SUM(W**2)   MEAN',
     .'    ERROR      MAX.W.    EFFIC.')
      DO 205 I=1,5
      IF(WCON(1,I).EQ.0.D0) THEN
      WRITE(IUT,203) I
  203 FORMAT(I7,
     .       '         0          0         0         --',
     .'     --          --        --')
      GOTO 205
      ENDIF
      WMEAN(I)=WCON(2,I)/WCON(1,I)
      WERRO(I)=DSQRT(WCON(3,I)-WCON(2,I)**2/WCON(1,I))/WCON(1,I)
      IF(WMAXI(I).NE.0.D0) WEFFI(I)=WMEAN(I)/WMAXI(I)
      WRITE(IUT,204) I,(WCON(J,I),J=1,3),WMEAN(I),WERRO(I)
     .  ,WMAXI(I),WEFFI(I)
  204 FORMAT(I7,G14.4,2G11.4,4G10.3)
  205 CONTINUE
      WMEANT=WALL(2)/WALL(1)
      WERROT=DSQRT(WALL(3)-WALL(2)**2/WALL(1))/WALL(1)
      WEFFT=WMEANT/WMAXT
      WRITE(IUT,206) (WALL(K),K=1,3),WMEANT,WERROT,WMAXT,WEFFT
  206 FORMAT(
     .'  TOTAL',G14.4,2G11.4,4G10.3/,
     .' WHERE:'/,
     .' CONTR.NO = THE CONTRIBUTION NUMBER AS BEFORE,'/,
     .' SUM(W**K)= THE K-TH MOMENT OF THE WEIGHT DISTRIBUTION,'/,
     .' MEAN     = THE MEAN WEIGHT FOR THIS CONTRIBUTION,'/,
     .' ERROR    = THE ESTIMATED ERROR ON THIS MEAN,'/,
     .' MAX.W.   = THE MAXIMUM WEIGHT THAT OCCURRED,'/,
     .' EFFIC.   = THE ALGORITHM EFFICIENCY = MEAN/MAX.W.')
C
C THE FINAL RESULT: THE TOTAL CROSS SECTION (IN PICOBARN)
      SIGTOT=WMEANT*SIGAPP
      ERRTOT=WERROT*SIGAPP
      WRITE(IUT,207) SIGTOT,ERRTOT
  207 FORMAT(' ',50(1H-)/,
     . ' THE CROSS SECTION CORRESPONDING TO THE GENERATED'/,
     . ' EVENT SAMPLE IS',D15.6,' +/-',D15.6,
     . ' PICOBARN'/,' ',50(1H-))
C
      END
C-----------------------------------------------------------------------
      SUBROUTINE BORN(EB,XMZ,XGZ,GV,GA,THMIN,THMAX,CROSS)
      IMPLICIT REAL*8(A-H,O-Z)
      COMPLEX*16 ZS,SP,SM,SX
      COMMON / UNICOM / IIN,IUT
C
      F1(V)=-4.D0/V-4.D0*DLOG(V)+V
      F2(C)=S**2/4.D0*(C+C**2+C**3/3.D0)
      F3(W)=-(2.D0+U)**2/W-2.D0*(2.D0+U)*DLOG(W)+W
      F4(V)=-S/2.D0*(4.D0*DLOG(V)-4.D0*V+V**2/2.D0)
      F5(W)=-S/2.D0*((2.D0+U)**2*DLOG(W)-2.D0*(2.D0+U)*W+W**2/2.D0)
C F6=(F5-F4)/MZ**2
      F7(C)=S**2/4.D0*(C-C**2+C**3/3.D0)
      F8(V)=4.D0/S**2*(-1.D0/V)
      F9(W)=4.D0/S**2*(-1.D0/W)
      F10(C)=4.D0/U/S**2*DLOG((1.D0+U-C)/(1.D0-C))
C
      PI=4.D0*DATAN(1.D0)
      C0=DCOS(PI*THMAX/180.D0)
      C1=DCOS(PI*THMIN/180.D0)
      V0=1.D0-C1
      V1=1.D0-C0
      S=4.D0*EB**2
      U=XMZ**2/(S/2.D0)
      W0=V0+U
      W1=V1+U
C
      H1=F1(V1)-F1(V0)
      H2=F2(C1)-F2(C0)
      H3=F3(W1)-F3(W0)
      H4=F4(V1)-F4(V0)
      H5=F5(W1)-F5(W0)
      H6=1.D0/XMZ**2*(H5-H4)
      H7=F7(C1)-F7(C0)
      H8=F8(V1)-F8(V0)
      H9=F9(W1)-F9(W0)
      H10=F10(C1)-F10(C0)
C
      ZS=DCMPLX(S-XMZ**2,XMZ*XGZ)
C
      E=DSQRT(4.D0*PI/137.036D0)
      SP=E**2/S+(GV+GA)**2/ZS
      SM=E**2/S+(GV-GA)**2/ZS
      SX=E**2/S+(GV**2-GA**2)/ZS
C
      B1=2.D0*E**4
      B2=CDABS(SP)**2+CDABS(SM)**2
      B3=(GV+GA)**4+(GV-GA)**4
      B4=DREAL(2.D0*E**2*(SP+SM))
      B5=DREAL(2.D0*(GV+GA)**2*SP+2.D0*(GV-GA)**2*SM)
      B6=2.D0*E**2*((GV+GA)**2+(GV-GA)**2)
      B7=2.D0*CDABS(SX)**2
      B8=2.D0*S**2*E**4
      B9=2.D0*S**2*(GV**2-GA**2)**2
      B10=4.D0*S**2*E**2*(GV**2-GA**2)
C
      CROSS= B1*H1 + B2*H2 + B3*H3 + B4*H4 + B5*H5 +
     .       B6*H6 + B7*H7 + B8*H8 + B9*H9 + B10*H10
      CROSS= CROSS/(32.D0*PI*S)*3.8937D8
C
      WRITE(IUT,1) EB,XMZ,XGZ,GV,GA,THMIN,THMAX
    1 FORMAT(' BORN   : ',4D15.6)
      WRITE(IUT,2) CROSS
    2 FORMAT(' BORN   : THE LOWEST-ORDER CROSS SECTION IS'/,
     .       '          ',D15.6,'   PICOBARN')
      END
C-----------------------------------------------------------------------
      SUBROUTINE CANCUT(QP,QM,QK,W)
*
* CANCONICAL CUTS: ACOLINEARITY AND THRESHOLD ENERGY
* THE THRESHOLD ENERGY IS ALWAYS 1/2 OF THE BEAM ENERGY
*
      IMPLICIT REAL*8(A-H,O-Z)
      DIMENSION CCUT(31),QP(4),QM(4),QK(4)
      COMMON / CUTCOM / W1(31),W2(31),WA0,WA1
      COMMON / ACOLCO / ACOL(31)
      DATA INIT/0/
*
      IF(INIT.EQ.0) THEN
      CALL OUTCRY('CANCUT')
      INIT=1
      ECUT=(QP(4)+QM(4)+QK(4))/2.D0*( 0.5D0)
      ACOL(1)=1.D0
      ACOL(2)=2.D0
      ACOL(3)=3.D0
      ACOL(4)=4.D0
      ACOL(5)=5.D0
      ACOL(6)=6.D0
      ACOL(7)=7.D0
      ACOL(8)=8.D0
      ACOL(9)=9.D0
      ACOL(10)=10.D0
      ACOL(11)=12.D0
      ACOL(12)=14.D0
      ACOL(13)=16.D0
      ACOL(14)=18.D0
      ACOL(15)=20.D0
      ACOL(16)=25.D0
      ACOL(17)=30.D0
      ACOL(18)=35.D0
      ACOL(19)=40.D0
      ACOL(20)=45.D0
      ACOL(21)=50.D0
      ACOL(22)=55.D0
      ACOL(23)=60.D0
      ACOL(24)=70.D0
      ACOL(25)=80.D0
      ACOL(26)=90.D0
      ACOL(27)=100.D0
      ACOL(28)=120.D0
      ACOL(29)=140.D0
      ACOL(30)=160.D0
      ACOL(31)=180.D0
      PI=4.D0*DATAN(1.D0)
      DO 1 K=1,31
      CCUT(K)=DCOS(ACOL(K)*PI/180.D0)
      W1(K)=0.D0
    1 W2(K)=0.D0
      WA0=0.D0
      WA1=0.D0
      ENDIF
*
* DETERMINE ACOLLINEARITY ANGLE BETWEEN QP AND QM
      C=-(QP(1)*QM(1)+QP(2)*QM(2)+QP(3)*QM(3))/(QP(4)*QM(4))
*
* ADD TO COUNTERS FOR ALL EVENTS
      WA0=WA0+1.D0
      WA1=WA1+W
*
* CHECK ON THRESHOLD ENERGIES
      IF(QP(4).LT.ECUT) RETURN
      IF(QM(4).LT.ECUT) RETURN
      WSQ=W*W
*
* CHECK ON THE VARIOUS ACOLLINEARITY CUTS
      DO 2 K=1,31
      IF(C.GT.CCUT(K)) THEN
                       W1(K)=W1(K)+W
                       W2(K)=W2(K)+WSQ
                       ENDIF
    2 CONTINUE
      END
C-----------------------------------------------------------------------
      SUBROUTINE ENDCUT(SIGTOT)
*
* EVALUATE THE CROSS SECTION AFTER CUTS: SIGTOT IS THE
* GENERATED TOTAL CROSS SECTION, PUT EQUAL TO WA1/WA0
      IMPLICIT REAL*8(A-H,O-Z)
      DIMENSION SIG(31),ERR(31),AV(31),DE(31)
      COMMON / CUTCOM / W1(31),W2(31),WA0,WA1
      COMMON / ACOLCO / ACOL(31)
      COMMON / UNICOM / IIN,IUT
      CALL OUTCRY('ENDCUT')
*
*     COMPUTE THE MEAN WEIGHTS AND THEIR DEVIATION
      CONVER=SIGTOT/(WA1/WA0)
      DO 2 K=1,31
      IF(W1(K).EQ.0.D0) THEN
                        SIG(K)=0.D0
                        ERR(K)=0.D0
                        GOTO 2
                        ENDIF
      SIG(K)=CONVER*W1(K)/WA0
      ERR(K)=CONVER*DSQRT(W2(K)-W1(K)**2/WA0)/WA0
    2 CONTINUE
      WRITE(IUT,11)
     .   (ACOL(K),W1(K),W2(K),SIG(K),ERR(K),K=1,31)
   11 FORMAT(' RESULTS FROM THE CANONICAL CUTS FOR THE'/,
     . ' GENERATED SAMPLE INSIDE THE 50% ENERGY THRESHOLDS:'/,
     . '  ACOLL.   SUM(W**1)   SUM(W**2)       XSECTION        ERROR'/,
     . (' ',F6.1,2D12.4,2D15.6))
      END
C-----------------------------------------------------------------------
      SUBROUTINE FINDMW(MZ,MT,MH)
C
C   DETERMINE SW**2 AND MW FOR GIVEN MZ VIA MU-LIFETIME
C   W. HOLLIK, HAMBURG UNIV.,  DATE APRIL 29, 1987
C   IMPLEMENTED AS SUBROUTINE BY RONALD 29-4
C   MZ = Z0 MASS IN GEV;
C   MT = TOP MASS IN GEV
C   MH = HIGGS MASS IN GEV
C
      IMPLICIT REAL*8(A-Z)
      INTEGER I,IIN,IUT
      DIMENSION SINW(20)
      COMMON /COUP/AL
      COMMON / TOPCOM / XMT
      COMMON / UNICOM / IIN,IUT
      COMMON / FINCOM / MW,SW
      CALL OUTCRY('FINDMW')
      WRITE(IUT,1) MZ,MT,MH
    1 FORMAT(' FINDMW : MZ,MT,MH =',3F13.4)
      XMZ=MZ*MZ
      XMT=MT
      PI=3.14159265D0
      ALFA=1.D0/137.036D0
      AL=ALFA/4.D0/PI
      A0=37.281D0**2
      I=1
C  SW = SIN**2 THETA-W, START WITH APPROXIMATE VALUE
      SQ=1.D0-4.D0*A0/XMZ/(1.D0-.07D0)
      IF(SQ.LE.0.D0) THEN
      WRITE(IUT,2) MZ
    2 FORMAT(' FINDMW : Z0 MASS ',F9.4,'  IS TOO LOW')
      STOP
      ENDIF
      SQ=DSQRT(SQ)
      SW=(1.D0-SQ)/2.D0
      SINW(1)=SW
      CW=1.D0-SW
      SW1=DSQRT(SW)
      CW1=DSQRT(CW)
      MW=MZ*CW1
C  CORR MEANS THE QUANTITY 'DELTA R' IN MU LIFETIME FORMULA
51    STD=PSE0(MZ,MW,MH)
      CORR=-STD
      SQ=DSQRT(1.D0-4.D0*A0/XMZ/(1.D0+STD))
C  THE CORRECTED VALUE FOR SIN**2 THETA-W
      SW=(1.D0-SQ)/2.D0
      SINW(I+1)=SW
      DSIN=DABS(SINW(I+1)-SINW(I))
      CW1=DSQRT(1.D0-SW)
C  THE CORRECTED VALUE FOR THE W MASS
      MW=MZ*CW1
      IF(DSIN.LT.1D-5) GOTO 100
      I=I+1
      IF(I.GT.10) GOTO 101
      GOTO 51
100   CONTINUE
      WRITE(IUT,25) I,MW,SW
25    FORMAT(' FINDMW : CONVERGED TO 4 DIGITS AFTER',I3,' STEPS :'/,
     .       ' FINDMW : RESULT FOR THE W MASS =',F10.4,' GEV'/,
     .       ' FINDMW : AND FOR SIN**2(TH_W)  =',F10.4/,' ',50('-'))
      RETURN
101   WRITE(IUT,26)
26    FORMAT(' FINDMW : NO SUFFICIENT CONVERGENCE IN 10 STEPS')
      END
C-----------------------------------------------------------------------
      DOUBLE PRECISION FUNCTION FFUNCT(Y,A,B)
      IMPLICIT REAL*8(A-Z)
      IF(A.LT.1.0D-05) GO TO 50
      F1=2.D0
      IF(A.EQ.B) GO TO 10
      F1=1.D0+((A*A-B*B)/Y-(A*A+B*B)/(A*A-B*B))*DLOG(B/A)
   10 CONTINUE
      Q=(A+B)*(A+B)
      P=(A-B)*(A-B)
      IF(Y.LT.P) GO TO 20
      IF(Y.GE.Q) GO TO 30
      F2=DSQRT((Q-Y)*(Y-P))*(-2.D0)*DATAN(DSQRT((Y-P)/(Q-Y)))
      GO TO 40
   20 CONTINUE
      F2=DSQRT((Q-Y)*(P-Y))*DLOG((DSQRT(Q-Y)+DSQRT(P-Y))**2/
     &                                               (4.D0*A*B))
      GO TO 40
   30 CONTINUE
      F2=DSQRT((Y-Q)*(Y-P))*(-1.D0)*DLOG((DSQRT(Y-P)+DSQRT(Y-Q))**2/
     &(4.D0*A*B))
   40 CONTINUE
      F=F1+F2/Y
      GO TO 70
   50 CONTINUE
      IF(Y.EQ.(B*B)) GO TO 65
      IF(Y.LT.(B*B)) GO TO 60
      F=1.D0+(1.D0-B*B/Y)*DLOG(B*B/(Y-B*B))
      GO TO 70
   60 CONTINUE
      F=1.D0+(1.D0-B*B/Y)*DLOG(B*B/(B*B-Y))
      GO TO 70
   65 CONTINUE
      F=1.D0
   70 FFUNCT=F
      END
C-----------------------------------------------------------------------
      DOUBLE PRECISION FUNCTION PSE0(MZ,M0,MH)
C  STANDARD W-SELF ENERGY AT K**2 = 0 , VERTEX AND BOX DIAGRAMS.
C  MZ = Z-MASS, M0 = W-MASS, MH = HIGGS-MASS
      IMPLICIT REAL*8(A-Z)
      INTEGER I,J,L,RS
      DIMENSION M(6,2),MF(6,2),V(6,2),A(6,2),VF(6,2),T(25)
      COMMON /COUP/ALPHA
      COMMON / TOPCOM / MT
      PI=3.14159265D0
      Z=MZ*MZ
      W=M0*M0
      H=MH*MH
      S=1D0-W/Z
      C=1D0-S
C  FERMION MASSES
      MF(1,1)=0.D0
      MF(1,2)=.5110034D-3
      MF(2,1)=0.D0
      MF(2,2)=.10565943D0
      MF(3,1)=0.D0
      MF(3,2)=1.7842D0
      MF(4,1)=.032D0
      MF(4,2)=.0321D0
      MF(5,1)=1.5D0
      MF(5,2)=.15D0
      MF(6,1)=MT
      MF(6,2)=4.5D0
      M(1,1)=0.D0
      M(2,1)=0.D0
      M(3,1)=0.D0
      M(1,2)=MF(1,2)**2
      M(2,2)=MF(2,2)**2
      M(3,2)=MF(3,2)**2
      M(4,1)=MF(4,1)**2
      M(4,2)=MF(4,2)**2
      M(5,1)=MF(5,1)**2
      M(5,2)=MF(5,2)**2
      M(6,1)=MF(6,1)**2
      M(6,2)=MF(6,2)**2
C  FERMION COUPLING CONSTANTS
      A1=DSQRT(1.D0/(16.D0*C*S))
      VL=(4.D0*S-1.D0)*A1
      AL=-A1
      VU=-(8.D0/3.D0*S-1.D0)*A1
      VD=(4.D0/3.D0*S-1.D0)*A1
      VF(1,1)=A1
      VF(2,1)=A1
      VF(3,1)=A1
      VF(1,2)=VL
      VF(2,2)=VL
      VF(3,2)=VL
      VF(4,1)=VU
      VF(5,1)=VU
      VF(6,1)=VU
      VF(4,2)=VD
      VF(5,2)=VD
      VF(6,2)=VD
      DO 2 I=1,6
      DO 1 J=1,2
      V(I,J)=VF(I,J)**2
      A(I,J)=A1*A1
1     CONTINUE
2     CONTINUE
C
C ON SHELL SELFENERGY (START)
      T(1)=0D0
      DO 71 J=1,3,1
      T(1)=T(1)-M(J,2)/2D0-M(J,2)/4D0
   71 CONTINUE
      T(1)=T(1)/(3D0*S)
      T(2)=0D0
      DO 72 L=4,6,1
      T(2)=T(2)-(M(L,1)+M(L,2))/2D0*(1D0-(M(L,1)+M(L,2))/
     &  (M(L,1)-M(L,2))*DLOG(MF(L,1)/MF(L,2)))-
     &  (M(L,1)+M(L,2))/4D0 - M(L,1)*M(L,2)/(M(L,1)-M(L,2))*
     &  DLOG(M(L,2)/M(L,1))/2D0
   72 CONTINUE
      T(2)=T(2)/S
      T(3)=(7D0*Z+7D0*W)*(1D0-Z/(Z-W)*DLOG(Z/W))-
     &  Z-W - Z*W/(Z-W)*DLOG(W/Z)*2D0
      T(3)=T(3)*C/(-3D0*S)
      T(4)=W/3D0
      T(5)=(Z+W)/24D0 + Z*W/(Z-W)*DLOG(W/Z)/12D0+
     &  (H+W)/24D0 + H*W/(H-W)*DLOG(W/H)/12D0
      T(5)=T(5)/S
C SUBSTITUTIONS X>W , FACTOR (-1)
      T(6)=0D0
      DO 76 J=1,3,1
      T(6)=T(6)+(W-M(J,2)/2D0)*(1D0+FFUNCT(W,0D0,MF(J,2)))-
     &   W/3.D0 - M(J,2)*M(J,2)/(2D0*W)*FFUNCT(W,0D0,MF(J,2))
   76 CONTINUE
      T(6)=T(6)/(3D0*S)*(-1D0)
      T(7)=0D0
      DO 77 L=4,6,1
      T(7)=T(7)+(W-(M(L,1)+M(L,2))/2D0)*(1D0-(M(L,1)+M(L,2))/
     &  (M(L,1)-M(L,2))*DLOG(MF(L,1)/MF(L,2))+
     &  FFUNCT(W,MF(L,1),MF(L,2))) -
     &  W/3D0-(M(L,1)-M(L,2))*(M(L,1)-M(L,2))/(2D0*W)*
     &  FFUNCT(W,MF(L,1),MF(L,2))
   77 CONTINUE
      T(7)=T(7)/S*(-1D0)
      T(8)=(7D0*Z+7D0*W+10D0*W)*(1D0-Z/(Z-W)*DLOG(Z/W)+
     &  FFUNCT(W,MZ,M0)) +
     &  2D0*W/3D0-2D0*(Z-W)*(Z-W)/W*FFUNCT(W,MZ,M0)
      T(8)=T(8)*C/(-3D0*S)*(-1D0)
      T(9)=(-32D0)*W/9D0-(4D0*W+10D0*W)/3D0*FFUNCT(W,0D0,M0)+
     &  2D0/3D0*W*FFUNCT(W,0D0,M0)+S/C*W*FFUNCT(W,MZ,M0)+
     &  W/S*FFUNCT(W,MH,M0)
      T(9)=T(9)*(-1D0)
      T(10)=5D0/18D0*W-W/12D0*(Z/(Z-W)*DLOG(Z/W)+H/(H-W)*DLOG(H/W))+
     &  ((Z-W)*(Z-W)/(2D0*W)-(W+Z-W/2D0))/6D0*FFUNCT(W,MZ,M0)+
     &  ((H-W)*(H-W)/(2D0*W)-(W+H-W/2D0))/6D0*FFUNCT(W,MH,M0)
      T(10)=T(10)/S*(-1D0)
C
      DO 7 I=1,10
      T(I)=T(I)/(-W)
    7 CONTINUE
C
      T(11)=0D0
      DO 711 J=1,3,1
      T(11)=T(11)+(FFUNCT(Z,MF(J,2),MF(J,2))-1D0/3D0)*
     &  (V(J,1)+V(J,2)+A(J,1)+A(J,2)) +
     &  (2D0*(V(J,2)+A(J,2))-3D0/(8D0*C*S))*M(J,2)/Z*
     &  FFUNCT(Z,MF(J,2),MF(J,2))
  711 CONTINUE
      T(11)=T(11)*C/S*4D0/3D0
      T(12)=0D0
      DO 712 L=4,6,1
      DO 172 I=1,2,1
      FZLI=FFUNCT(Z,MF(L,I),MF(L,I))
      T(12)=T(12)+(FFUNCT(Z,MF(L,I),MF(L,I))-1D0/3D0)*
     &  (V(L,I)+A(L,I)) +
     &  (2D0*(V(L,I)+A(L,I))-3D0/(8D0*C*S))*M(L,I)/Z*FZLI
  172 CONTINUE
  712 CONTINUE
      T(12)=T(12)*4D0*C/S
      T(13)=(C/(3D0*S)*(10D0+20D0*C)-1D0/S-(C-S)*(C-S)/(12D0*S*C)*
     &  (1D0+8D0*C))*FFUNCT(Z,M0,M0)
      T(13)=T(13)*C/S*(-1D0)
      T(14)=(1D0/(12D0*S*C)*(2D0*H/Z-11D0) - 1D0/(12D0*S*C)*(H-Z)*
     &  (H-Z)/(Z*Z))*FFUNCT(Z,MH,MZ)
      T(14)=T(14)*C/S*(-1D0)
      T(15)=(11D0-2D0*H/Z)*(1D0-(H+Z)/(2D0*(H-Z))*
     &  DLOG(H/Z)-DLOG(MH*MZ/W))
      T(15)=T(15)/(12D0*S*C)*C/S
      T(16)=(-1D0)/(6D0*S*C)*(H/Z*DLOG(H/W) + DLOG(Z/W)) - 2D0*C/
     &  (9D0*S) + 1D0/(18D0*S*C) + (C-S)*(C-S)/(18D0*S*C)
      T(16)=T(16)*C/S
C END OF COMPUTATION OF RE(SIGMA(Z))
C
      T(17)=0D0
      DO 717 J=1,3,1
      T(17)=T(17)+(1D0-M(J,2)/(2D0*W))*(1D0+FFUNCT(W,0D0,MF(J,2)))-
     &  1D0/3D0 - 0.5D0*M(J,2)*M(J,2)/(W*W)*FFUNCT(W,0D0,MF(J,2))
  717 CONTINUE
      T(17)=T(17)/(3D0*S)*C/S*(-1D0)
      T(18)=0D0
      DO 718 L=4,6,1
      T(18)=T(18)+(1D0-(M(L,1)+M(L,2))/(2D0*W))*(1D0-(M(L,1)+M(L,2))/
     &  (M(L,1)-M(L,2))*DLOG(MF(L,1)/MF(L,2)) +
     &  FFUNCT(W,MF(L,1),MF(L,2))) -
     &  1D0/3D0 - 0.5D0*(M(L,1)-M(L,2))*(M(L,1)-M(L,2))/(W*W)*
     &  FFUNCT(W,MF(L,1),MF(L,2))
  718 CONTINUE
      T(18)=T(18)/S*C/S*(-1D0)
      T(19)=(5D0*S/(3D0*C)-7D0/3D0-8D0*C/S+1D0/(12D0*S)*Z/W*(Z/W-4D0))*
     &  FFUNCT(W,MZ,M0)
      T(19)=T(19)*C/S*(-1D0)
      T(20)=(1D0/S+1D0/(12D0*S)*H/W*(H/W-4D0))*FFUNCT(W,MH,M0)
     &  - 4D0*FFUNCT(W,0D0,M0)
      T(20)=T(20)*C/S*(-1D0)
      T(21)=(1D0+8D0*C/S-S/C+1D0/(4D0*S))*Z/(Z-W)*DLOG(Z/W)
      T(21)=T(21)*C/S*(-1D0)
      T(22)=(-3D0)/(4D0*S)*H/(H-W)*DLOG(H/W) +
     &  (17D0/18D0-(Z+H)/(6D0*W))/S + S/C - 2D0*C/(9D0*S) - 8D0*C/S
     &  - 44D0/9D0 - 7D0/3D0
      T(22)=T(22)*C/S*(-1D0)
C END OF COMPUTATION OF -RE(SIGMA(W))
C
      T(23)=0D0
      DO 723 L=4,6,1
      T(23)=T(23)+(4D0/3D0 + (M(L,1)-M(L,2))/(Z-W))*DLOG(M(L,1)/
     &  M(L,2))
  723 CONTINUE
      T(23)=(T(23)/(4D0*S) + 2D0/3D0)
C
      SIG0=0D0
      DO 700 I=1,23,1
      SIG0=SIG0+T(I)
  700 CONTINUE
      SIG0=SIG0*ALPHA
      PSE0=SIG0-ALPHA/S*(6.D0+(7.D0-4.D0*S)/2.D0/S *DLOG(C))
C
      END
C-----------------------------------------------------------------------
      SUBROUTINE GBOX(S,T,V1S,V2S,A1S,A2S,V1T,V2T,A1T,A2T)
      IMPLICIT REAL*8(A-Z)
      COMPLEX*16 VS,VT,AS,AT,CPI,MST,MSU,MTS,MTU
      PI=3.1415926536D0
      CPI=DCMPLX(0.D0,PI)
      LST=DLOG(-T/S)
      U=-S-T
      LSU=DLOG(-U/S)
      MST=.5D0*S/(S+T)*(LST+CPI)
     1  -.25D0*S*(S+2.D0*T)/(S+T)**2*(LST**2+2.D0*CPI*LST)
      MSU=.5D0*S/(S+U)*(LSU+CPI)
     1  -.25D0*S*(S+2.D0*U)/(S+U)**2*(LSU**2+2.D0*CPI*LSU)
      LTS=-LST
      LTU=DLOG(T/U)
      MTS=.5D0*T/(S+T)*(LTS-CPI)
     1  -.25D0* T*(T+2.D0*S)/(S+T)**2*(LTS**2-2.D0*CPI*LTS)
      MTU=-.5D0*T/(T+U)*LTU
     1  -.25D0*T*(T+2.D0*U)/(T+U)**2*(LTU**2+PI**2)
      VS=MST-MSU+2.D0*CPI*LTU
      VT=MTS-MTU+2.D0*LST*(LSU+CPI)
      AS=MST+MSU
      AT=MTS+MTU
      PI2=2.D0*PI
C
      V1S=DREAL(VS)
      V2S=DIMAG(VS)/PI2
      A1S=DREAL(AS)
      A2S=DIMAG(AS)/PI2
      V1T=DREAL(VT)
      V2T=DIMAG(VT)/PI2
      A1T=DREAL(AT)
      A2T=DIMAG(AT)/PI2
      END
C-----------------------------------------------------------------------
       SUBROUTINE GZBOX(S,T,V1ZS,V2ZS,A1ZS,A2ZS,V1ZT,V2ZT,A1ZT,A2ZT)
       IMPLICIT REAL*8(A-Z)
       COMPLEX*16 VS,VT,AS,AT,M,ABOX,     CPI,SPENCE,
     1            LMSS,LMSM,CDLOG,VST,VSU,AST,ASU,VTS,VTU,
     2            ATS,ATU,LMT,LMTM
C GB   COMMON /BOS/MZ,MW,MH/WIDTH/GZ
       COMMON /BOSON/MZ,MW,MH/WIDTH/GZ
       U=-S-T
       XM2=MZ*MZ
       YM2=-MZ*GZ
       M=DCMPLX(XM2,YM2)
       PI=3.1415926536D0
       CPI=DCMPLX(0.D0,PI)
       PI2=2.D0*PI
       AST=ABOX(S,T)
       ASU=ABOX(S,U)
       ATS=ABOX(T,S)
       ATU=ABOX(T,U)
       LMSS=CDLOG((M-S)/S)
       LMSM=CDLOG(M/(M-S))
       LMTM=CDLOG(M/(M-T))
       LMT=CDLOG((M-T)/S)
       VST=AST+  (SPENCE((M+T)/T)+   LMSM*DLOG(-T/S))*2.D0
       VSU=ASU+  (SPENCE((M+U)/U)+   LMSM*DLOG(-U/S))*2.D0
       VTS=ATS+  (SPENCE((M+S)/S)+   LMTM*DLOG(-S/T))*2.D0
       VTU=ATU+  (SPENCE((M+U)/U)+   LMTM*(DLOG(U/T)+CPI))*2.D0
C
       VS=VST-VSU-   DLOG(U/T)*LMSS*2.D0
       VT=VTS-VTU+   (DLOG(-U/S)+CPI)*LMT*2.D0
       AS=AST+ASU
       AT=ATS+ATU
C
       V1ZS=DREAL(VS)
       A1ZS=DREAL(AS)
       V1ZT=DREAL(VT)
       A1ZT=DREAL(AT)
       V2ZS=DIMAG(VS)/PI2
       A2ZS=DIMAG(AS)/PI2
       V2ZT=DIMAG(VT)/PI2
       A2ZT=DIMAG(AT)/PI2
       END
C-----------------------------------------------------------------------
      FUNCTION ABOX(S,T)
      IMPLICIT REAL*8(A-Z)
      COMPLEX*16 ABOX,SPENCE,CDLOG,M,KLAM1,KLAM2,A
C GB  COMMON /BOS/MZ,MW,MH/WIDTH/GZ
      COMMON /BOSON/MZ,MW,MH/WIDTH/GZ
      XMZ=MZ*MZ
      YMZ=-MZ*GZ
      M=DCMPLX(XMZ,YMZ)
      KLAM1=SPENCE(S/M)-SPENCE(-T/M)
     1     +CDLOG(-T/M)*CDLOG((M-S)/(M+T))
      KLAM2=CDLOG(T/(S-M))+M/S*CDLOG((M-S)/M)
      A=(S+2.D0*T+M)/(S+T)*KLAM1+KLAM2
      ABOX=A*(S-M)/(S+T)
      END
C-----------------------------------------------------------------------
C     FUNCTION PIG(S)
C     IMPLICIT REAL*8(A-Z)
C     COMPLEX*16 PIG,CPI,IPIL,IPIH,IPIT,PII
C     COMMON /LEPT/ME,MMU,MTAU/HAD/MU,MD,MS,MC,MB,MT
C    1       /ALF/AL,ALPHA,ALFA
C    2       /BOSON/MZ,MW,MH
C GB 2       /BOS/MZ,MW,MH
C     PI=3.1415926536D0
C     CPI=DCMPLX(0.D0,PI)
C     QU=4.D0/3.D0
C     QD=1.D0/3.D0
C  SQUARE OF QUARK CHARGES INCLUDING COLOUR FAKTOR 3
C     X=DABS(S)
C     W=DSQRT(X)
C     L1=   DLOG(W/ME)*2.D0
C     L2= -(1.D0+2.D0*MMU**2/S) *F(S,MMU,MMU)+2.D0
C     L3= -(1.D0+2.D0*MTAU**2/S)*F(S,MTAU,MTAU)+2.D0
C     H1= -(1.D0+2.D0*MU**2/S)*F(S,MU,MU)+2.D0
C     H2= -(1.D0+2.D0*MD**2/S)*F(S,MD,MD)+2.D0
C     H3= -(1.D0+2.D0*MS**2/S)*F(S,MS,MS)+2.D0
C     H4= -(1.D0+2.D0*MC**2/S)*F(S,MC,MC)+2.D0
C     H5= -(1.D0+2.D0*MB**2/S)*F(S,MB,MB)+1.D0/3.D0
C     H6= -(1.D0+2.D0*MT**2/S)*F(S,MT,MT)+1.D0/3.D0
C     PIL=(L1+L2+L3-5.D0)*AL/3.D0
C     PIH=(QU*(H1+H4+H6-10.D0/3.D0)+QD*(H2+H3+H5-10.D0/3.D0))*AL/3.D0
C   GAUGE AND HIGGS PART
C     PIW=(3.D0+4.D0*MW*MW/S)*F(S,MW,MW)-2.D0/3.D0
C     PIW= ALPHA*PIW
C     PIR=PIL+PIH+PIW
C     IPIL=-CPI*AL
C     IPIH=-CPI*(2.D0*QU+3.D0*QD)
C     MTH=4.D0*MT*MT
C     IF(S.LT.MTH) GOTO 5
C     SQ=DSQRT(1.D0-MTH/S)
C     IPIT=-CPI*SQ*(1.D0+MTH/2.D0/S)*QU
C     IPIH=(IPIH+IPIT)*AL/3.D0
C     PII=IPIL+IPIH
C     PIG=DCMPLX(PIR,0.D0)+PII
C     GOTO 7
C5    IF(S.LT.0.) GOTO 6
C     PII= IPIL+IPIH *AL/3.D0
C     PIG=DCMPLX(PIR,0.D0)+PII
C     GOTO 7
C6    PIG=DCMPLX(PIR,0.D0)
C7    CONTINUE
C     END
      FUNCTION PIG(S)
CHBU  routine for BABAMC/MUONMC
CHBU  modified to use the hadron vacuum polarization as described in :
CHBU  H.Burkhardt et al. Pol. at Lep CERN 88-06 VOL I
CHBU  the old result, thats known to be inadequate for small q**2
CHBU  like in forward Bhabha scattering, can still be obtained
CHBU  by putting DISPFL to false
CHBU  Uses the complex function FC(s,m1,m2) for leptons,top
CHBU  to get the threshold behaviour consistent in the imaginary part
CHBU  (and to write the routine more compact)
CHBU  timing : old pig  .15 msec /call
CHBU           new pig  .27 msec /call    DISPFL FALSE
CHBU           new pig  .15 msec /call    DISPFL TRUE
CHBU                                   H.Burkhardt, June 1989
      IMPLICIT REAL*8(A-Z)
      COMPLEX*16 P,PIG,PIL,PIH,HADRQQ,FC
      COMMON /LEPT/ME,MMU,MTAU/HAD/MU,MD,MS,MC,MB,MT
      COMMON /ALF/AL,ALPHA,ALFA
      COMMON /BOSON/MZ,MW,MH
      LOGICAL DISPFL
      DATA DISPFL/.TRUE./
C     statement function P(s,m):
      P(S,XM)=1.D0/3.D0-(1.D0+2.D0*XM**2/S)*FC(S,XM,XM)
C  square of quark charges including colour faktor 3
      QU=4.D0/3.D0
      QD=1.D0/3.D0
      X=DABS(S)
      W=DSQRT(X)
C     lepton contribution
      PIL=AL/3.D0*(P(S,ME)+P(S,MMU)+P(S,MTAU))
C     hadron contribution
      IF(DISPFL) THEN
C       use dispersion relation result for udscb
        PIH=HADRQQ(S)
     .     + QU*AL/3.D0*P(S,MT)
      ELSE
C       use free field result with udscbt masses
        PIH=AL/3.D0*(QU*(P(S,MU)+P(S,MC)+P(S,MT))
     .              +QD*(P(S,MD)+P(S,MS)+P(S,MB)))
      ENDIF
C     gauge dependent W loop contribution
      PIW=ALPHA*((3.D0+4.D0*MW*MW/S)*FC(S,MW,MW)-2.D0/3.D0)
      PIG=PIL+PIH+PIW
      END
C--------+---------+---------+---------+---------+---------+---------+--
      FUNCTION HADRQQ(S)
C  HADRONIC IRREDUCIBLE QQ SELF-ENERGY: TRANSVERSE
C     parametrize the real part of the photon self energy function
C     by  a + b ln(1+C*|S|) , as in my 1981 TASSO note but using
C     updated values, extended using RQCD up to 100 TeV
C     for details see:
C     H.Burkhardt, F.Jegerlehner, G.Penso and C.Verzegnassi
C     in CERN Yellow Report on "Polarization at LEP" 1988
C               H.BURKHARDT, CERN/ALEPH, AUGUST 1988
C
      IMPLICIT REAL*8(A-H,O-Z)
      COMPLEX*16 HADRQQ
C
      DATA A1,B1,C1/   0.0   ,   0.00835,  1.0   /
      DATA A2,B2,C2/   0.0   ,   0.00238,  3.927 /
      DATA A3,B3,C3/ 0.00165 ,   0.00300,  1.0   /
      DATA A4,B4,C4/ 0.00221 ,   0.00293,  1.0   /
C
      DATA PI/3.141592653589793/,ALFAIN/137.0359895D0/,INIT/0/
C
      IF(INIT.EQ.0) THEN
        INIT=1
        ALFA=1./ALFAIN
      ENDIF
      T=ABS(S)
      IF(T.LT.0.3**2) THEN
        REPIAA=A1+B1*LOG(1.+C1*T)
      ELSEIF(T.LT.3.**2) THEN
        REPIAA=A2+B2*LOG(1.+C2*T)
      ELSEIF(T.LT.100.**2) THEN
        REPIAA=A3+B3*LOG(1.+C3*T)
      ELSE
        REPIAA=A4+B4*LOG(1.+C4*T)
      ENDIF
C     as imaginary part take -i alfa/3 Rexp
      HADRQQ=REPIAA-(0.,1.)*ALFA/3.*REXP(S)
CEXPO HADRQQ=HADRQQ/(4.D0*PI*ALFA)  ! expostar divides by 4 pi alfa
      END
C--------+---------+---------+---------+---------+---------+---------+--
      FUNCTION REXP(S)
C  HADRONIC IRREDUCIBLE QQ SELF-ENERGY: IMAGINARY
      IMPLICIT REAL*8(A-H,O-Z)
C     continuum R = Ai+Bi W ,  this + resonances was used to calculate
C     the dispersion integral. Used in the imag part of HADRQQ
      PARAMETER (NDIM=18)
      DIMENSION WW(NDIM),RR(NDIM),AA(NDIM),BB(NDIM)
      DATA WW/1.,1.5,2.0,2.3,3.73,4.0,4.5,5.0,7.0,8.0,9.,10.55,
     .  12.,50.,100.,1000.,10 000.,100 000./
      DATA RR/0.,2.3,1.5,2.7,2.7,3.6,3.6,4.0,4.0,3.66,3.66,3.66,
     .   4.,3.87,3.84, 3.79, 3.76,    3.75/
      DATA INIT/0/
      IF(INIT.EQ.0) THEN
        INIT=1
C       calculate A,B from straight lines between R measurements
        BB(NDIM)=0.
        DO 4 I=1,NDIM
          IF(I.LT.NDIM) BB(I)=(RR(I)-RR(I+1))/(WW(I)-WW(I+1))
          AA(I)=RR(I)-BB(I)*WW(I)
    4   CONTINUE
      ENDIF
      REXP=0.D0
      IF(S.GT.0.D0) THEN
        W=REAL(SQRT(S))
        IF(W.GT.WW(1)) THEN
          DO 2 I=1,NDIM
C           find out between which points of the RR array W is
            K=I
            IF(I.LT.NDIM) THEN
              IF(W.LT.WW(I+1)) GOTO 3
            ENDIF
    2     CONTINUE
    3     CONTINUE
          REXP=AA(K)+BB(K)*W
C         WRITE(6,'('' K='',I2,'' AA='',F10.2,'' BB='',F10.3)')
C    .    K,AA(K),BB(K)
        ENDIF
      ENDIF
      END
C--------+---------+---------+---------+---------+---------+---------+--
      FUNCTION FC(S,A,B)
C     complex function F(S,m1,m2)          H.Burkhardt 13-6-89
      IMPLICIT REAL*8(A-Z)
      COMPLEX*16 R,T,FC,F2,DIF
      Q=(A+B)**2
      P=(A-B)**2
      F1=(A-B)*(A**2-B**2)/S - (A**2+B**2)/(A+B)
      IF(1.D6*ABS(A-B).LT.A+B) THEN ! masses about equal
        F1=1.D0-F1/A
      ELSE
        F1=1.D0+F1*LOG(B/A)/(A-B)
      ENDIF
CSLOW R=SQRT(DCMPLX(S-Q))
CSLOW T=SQRT(DCMPLX(S-P))
C     to be faster use real arithmetic in this step
      IF(S-Q.GT.0.D0) THEN
        R=SQRT(S-Q)
      ELSE
        R=(0.D0,1.D0)*SQRT(Q-S)
      ENDIF
      IF(S-P.GT.0.D0) THEN
        T=SQRT(S-P)
      ELSE
        T=(0.D0,1.D0)*SQRT(P-S)
      ENDIF
C
      EPS=2.D0*A*B/(S-A**2-B**2)
      IF(ABS(EPS).LT.1.D-6) THEN
        DIF=-EPS*SQRT(DCMPLX(S-A**2-B**2))
      ELSE
        DIF=R-T
      ENDIF
      F2= R*T * LOG( DIF/(R+T) ) / S
      FC=F1+F2
      END
C-----------------------------------------------------------------------
      DOUBLE PRECISION FUNCTION F(Y,A,B)
      IMPLICIT REAL*8(A-Z)
      IF(A.LT.1.0D-05) GO TO 50
      F1=2.D0
      IF(A.EQ.B) GO TO 10
      F1=1.D0+((A*A-B*B)/Y-(A*A+B*B)/(A*A-B*B))*DLOG(B/A)
   10 CONTINUE
      Q=(A+B)*(A+B)
      P=(A-B)*(A-B)
      IF(Y.LT.P) GO TO 20
      IF(Y.GE.Q) GO TO 30
      F2=DSQRT((Q-Y)*(Y-P))*(-2.D0)*DATAN(DSQRT((Y-P)/(Q-Y)))
      GO TO 40
   20 CONTINUE
      F2=DSQRT((Q-Y)*(P-Y))*DLOG((DSQRT(Q-Y)+DSQRT(P-Y))**2/
     &                                               (4.D0*A*B))
      GO TO 40
   30 CONTINUE
      F2=DSQRT((Y-Q)*(Y-P))*(-1.D0)*DLOG((DSQRT(Y-P)+DSQRT(Y-Q))**2/
     &(4.D0*A*B))
   40 CONTINUE
      F=F1+F2/Y
      GO TO 70
   50 CONTINUE
      IF(Y.EQ.(B*B)) GO TO 65
      IF(Y.LT.(B*B)) GO TO 60
      F=1.D0+(1.D0-B*B/Y)*DLOG(B*B/(Y-B*B))
      GO TO 70
   60 CONTINUE
      F=1.D0+(1.D0-B*B/Y)*DLOG(B*B/(B*B-Y))
      GO TO 70
   65 CONTINUE
      F=1.D0
   70 CONTINUE
      END
C-----------------------------------------------------------------------
      SUBROUTINE INTE(S,T,M1,IST,I5ST)
      IMPLICIT REAL*8(A-Z)
      COMPLEX*16 IST,I5ST,SPENCE,CDLOG,X1,X2,Y1,Y2,LN2,SP4,P1,P2,K1,
     1           LN,SQX,SQY,Z1,Z2,Z3,Z4,M
      COMMON /WIDTH/GZ
      XM2=M1*M1
      YM2=-M1*GZ
      M=DCMPLX(XM2,YM2)
      SQY=CDSQRT(1.D0-4.D0*M/S)
      SQX=CDSQRT(1.D0-4.D0*M/S*(1.D0+M/T))
      Y1=(1.D0+SQY)*.5D0
      Y2=(1.D0-SQY)*.5D0
      X1=(1.D0+SQX)*.5D0
      X2=(1.D0-SQX)*.5D0
      Z1=X1/(X1-Y1)
      Z2=X1/(X1-Y2)
      Z3=X2/(X2-Y1)
      Z4=X2/(X2-Y2)
      SP4=SPENCE(Z1)+SPENCE(Z2)-SPENCE(Z3)-SPENCE(Z4)
      LN=CDLOG(-Y1/Y2)
      LN2=LN*LN
      SP4=SP4/(X1-X2)
      K1=SPENCE(1.D0+T/M)-LN2-3.1415926536D0**2/6.
      P1=(2.D0*T+S+2.D0*M)/(S+T)/2.D0
      P2=(S+2.D0*T-4.D0*T*M/S+2.D0*M*M/T-2.D0*M*M/S)/(S+T)/2.D0
      I5ST=S/(S+T)*(P1*K1+.5D0*CDLOG(-T/M)+(Y2-Y1)/2.D0*LN-P2*SP4)
      IST =I5ST+2.D0*LN2+2.D0*SP4
      END
C-----------------------------------------------------------------------
      FUNCTION RESZ(X)
C   REAL PART OF THE Z SELF ENERGY
      IMPLICIT REAL*8(A-Z)
      INTEGER I,J,L
      DIMENSION M(6,2),V(6,2),A(6,2),VF(6,2),MF(6,2),T(25)
C GB  COMMON /BOS/MZ,M0,MH/FERMI/MF,VF,M,V,A
      COMMON /BOSON/MZ,M0,MH/FERMI/MF,VF,M,V,A
     1       /ALF/AL,ALPHA,ALFA
     2       /COUP/SW,CW,VL,A1,VU,AU,VD,AD
C  MF IS THE ARRAY OF FERMION MASSES, M THAT OF FERMION MASS SQUARED
C  I = FAMILY INDEX (1...6); J = 1,2 DENOTES UP AND DOWN MEMBERS
C  VF IS THE ARRAY OF CORRESPONDING VECTOR COUPLINGS
C  V,A ARE THE ARRAYS OF THE SQUARES OF V AND A COUPLINGS
      PI=3.1415926536D0
      GF=1.6632D-5
      Z=MZ*MZ
      W=M0*M0
      H=MH*MH
      C=CW
      S=SW
      DO 111 L=1,25,1
      T(L)=0.D0
  111 CONTINUE
      T(1)=0.D0
      C13=1.D0/3.D0
      C38=3.D0/8.D0
      DO 71 I=1,3,1
      T(1)=T(1) + (V(I,1)+A(I,1))*(X*(F(X,MF(I,2),MF(I,2))-C13)-
     &Z*(F(Z,MF(I,2),MF(I,2))-C13))
   71 CONTINUE
      T(1)=T(1)*4.D0/3.D0
      T(2)=0.D0
      DO 72 I=1,3,1
      T(2)=T(2) + (V(I,2)+A(I,2))*(X*(F(X,MF(I,2),MF(I,2))-C13)-
     &Z*(F(Z,MF(I,2),MF(I,2))-C13)  +2.D0 *M(I,2)*(F(X,MF(I,2),MF(I,2))-
     &F(Z,MF(I,2),MF(I,2))))-C38*M(I,2)/(    C*S)*(F(X,MF(I,2),MF(I,2))-
     &F(Z,MF(I,2),MF(I,2)))
   72 CONTINUE
      T(2)=T(2)*4.D0/3.D0
      T(3)=0.D0
      DO 73 L=4,6,1
      DO 173 I=1,2,1
      T(3)=T(3) + (V(L,I)+A(L,I))*(X*(F(X,MF(L,I),MF(L,I))-C13)-
     &Z*(F(Z,MF(L,I),MF(L,I))-C13)   +2.D0*M(L,I)*(F(X,MF(L,I),MF(L,I))-
     &F(Z,MF(L,I),MF(L,I))))-C38*M(L,I)*(F(X,MF(L,I),MF(L,I))-
     &F(Z,MF(L,I),MF(L,I)))/(    C*S)
  173 CONTINUE
   73 CONTINUE
      T(3)=T(3)*4.D0
      T(4)=2.D0*(X-Z)/3.D0+(10.D0*X+20.D0*W)*F(X,M0,M0)
     &    -(10.D0*Z+20.D0*W)*F(Z,M0,M0)
      T(4)=T(4)*(-C)/(3.D0*S)
      T(5)=3.D0*W*(F(X,M0,M0)-F(Z,M0,M0))+(X-Z)*(1.D0  - DLOG(MH*MZ/W)/
     &4.D0-(H+Z)/(H-Z)*DLOG(MH/MZ))+(10.D0*Z-2.D0*H+X)/4.D0*F(X,MH,MZ)-
     &(11.D0*Z-2.0*H)/4.D0*F(Z,MH,MZ)
      T(5)=T(5)/(3.D0*S*C)
      T(6)=(X-Z)/6.D0+(H-Z)*(H-Z)/4.D0*(F(X,MZ,MH)/X - F(Z,MZ,MH)/Z)
      T(6)=T(6)/(3.D0*S*C)
      T(7)=(X-Z)/6.D0+(2.0*W+X/4.D0)*F(X,M0,M0)-(2.D0*W+Z/4.D0)
     &     *F(Z,M0,M0)
      T(7)=T(7)*(C-S)*(C-S)/(3.D0*S*C)
      T(8)=0.D0
      DO 78 J=1,3,1
      T(8)=T(8)+(F(Z,MF(J,2),MF(J,2))-    C13)*(V(J,1)+V(J,2)+A(J,1)+
     &A(J,2)) +(2.D0*(V(J,2)+A(J,2))- C38/(   C*S))*M(J,2)/Z*
     &F(Z,MF(J,2),MF(J,2))
   78 CONTINUE
      T(8)=T(8)*(X-Z)*(C-S)/S*4.D0/3.D0
      T(9)=0.D0
      DO 79 L=4,6,1
      DO 719 I=1,2,1
      FZLI=F(Z,MF(L,I),MF(L,I))
      T(9)=T(9)+(FZLI -C13)                   *(V(L,I)+A(L,I)) +
     &(2.D0*(V(L,I)+A(L,I))-C38/(    C*S))*M(L,I)/Z*FZLI
  719 CONTINUE
   79 CONTINUE
      T(9)=T(9)*4.D0*(X-Z)*(C-S)/S
      T(10)=(C/(3.D0*S)*(10.D0+20.D0*C)-1.D0/S-(C-S)*(C-S)/(12.D0*S*C)*
     &(1.D0+8.D0*C))*F(Z,M0,M0)
      T(10)=T(10)*(X-Z)*(C-S)/S*(-1.D0)
      T(11)=(1.D0/(12.0*S*C)*(2.D0*H/Z-11.D0)-1.D0/(12.D0*S*C)*(H-Z)*
     &(H-Z)/(Z*Z))*F(Z,MH,MZ)
      T(11)=T(11)*(X-Z)*(C-S)/S*(-1.D0)
      T(12)=(-1.D0)/(12.D0*S*C)*(2.D0*H/Z-11.D0)*(1.D0-(H+Z)/(H-Z)*
     &DLOG(MH/MZ) - DLOG(MH*MZ/W))
      T(12)=T(12)*(X-Z)*(C-S)/S
      T(13)=(-1.D0)/(6.D0*S*C)*(H/Z*DLOG(H/W) + DLOG(Z/W)) -2.D0*C/
     &(9.D0*S)+1.D0/(18.D0*S*C) + (C-S)*(C-S)/(18.D0*S*C)
      T(13)=T(13)*(X-Z)*(C-S)/S
      T(14)=0.D0
      DO 714 J=1,3,1
      T(14)=T(14)+(1.D0-M(J,2)/(2.D0*W))*(1.D0+F(W,0.D0,MF(J,2)))-C13-
     &0.5D0*M(J,2)*M(J,2)/(W*W)*F(W,0.D0,MF(J,2))
  714 CONTINUE
      T(14)=T(14)/(3.D0*S)*(X-Z)*(C-S)/S*(-1.D0)
      T(15)=0.D0
      DO 715 L=4,6,1
      T(15)=T(15)
     & +(1.D0-(M(L,1)+M(L,2))/(2.D0*W))*(1.D0-(M(L,1)+M(L,2))/
     &(M(L,1)-M(L,2))*DLOG(MF(L,1)/MF(L,2)) + F(W,MF(L,1),MF(L,2))) -
     &    C13 -.5D0*(M(L,1)-M(L,2))*(M(L,1)-M(L,2))/(W*W)*
     &F(W,MF(L,1),MF(L,2))
  715 CONTINUE
      T(15)=T(15)/S*(X-Z)*(C-S)/S*(-1.D0)
      T(16)=(5.D0*S/(3.D0*C)-7.D0/3.D0-8.D0*C/S+1.D0/(12.D0*S)*Z/W
     &     *(Z/W-4.D0))*F(W,MZ,M0)
      T(16)=T(16)*(X-Z)*(C-S)/S*(-1.D0)
      T(17)=(1.D0/S+1.D0/(12.D0*S)*H/W*(H/W-4.D0))*F(W,MH,M0)
     &- 4.D0*F(W,0.D0,M0)
      T(17)=T(17)*(X-Z)*(C-S)/S*(-1.D0)
      T(18)=(1.D0+8.D0*C/S-S/C+1.D0/(4.D0*S))*Z/(Z-W)*DLOG(Z/W)
      T(18)=T(18)*(X-Z)*(C-S)/S*(-1.D0)
      T(19)=(-3.D0)/(4.D0*S)*H/(H-W)*DLOG(H/W) +
     &(17.D0/18.D0-(Z+H)/(6.0*W))/S + S/C -2.D0*C/(9.D0*S)-8.D0*C/S
     &- 44.D0/9.D0-7.D0/3.D0
      T(19)=T(19)*(X-Z)*(C-S)/S*(-1.D0)
      T(20)=0.D0
      DO 720 L=4,6,1
      T(20)=T(20)+(4.D0/3.D0+(C-S)/C*(M(L,1)-M(L,2))/(Z-W))*
     &DLOG(M(L,1)/M(L,2))
  720 CONTINUE
      T(20)=(T(20)/(4.D0*S)+2.D0/3.D0)*(X-Z)
      RESZ=0.D0
      DO 700 I=1,20,1
      RESZ=RESZ+T(I)
  700 CONTINUE
      RESZ=RESZ*ALPHA
      END
C-----------------------------------------------------------------------
      FUNCTION IMSZ(X)
C  IMAGINARY PART OF THE Z SELF ENERGY
      IMPLICIT REAL*8(A-Z)
      INTEGER I,L
      DIMENSION MF(6,2),VF(6,2),M(6,2),V(6,2),A(6,2),T(25)
C GB  COMMON /BOS/MZ,M0,MH/FERMI/MF,VF,M,V,A
      COMMON /BOSON/MZ,M0,MH/FERMI/MF,VF,M,V,A
     1       /ALF/AL,ALPHA,ALFA
     2       /COUP/SW,CW,VL,A1,VU,AU,VD,AD
      PI=3.1415926536D0
      Z=MZ*MZ
      W=M0*M0
      H=MH*MH
      S=SW
      C=CW
      DO 111 L=1,20,1
      T(L)=0.D0
  111 CONTINUE
      T(1)=0.D0
      DO 1 I=1,3,1
      T(1)=T(1) + (V(I,1)+A(I,1))*X*G(X,MF(I,2),MF(I,2))
    1 CONTINUE
      T(1)=T(1)*4.D0/3.D0
      T(2)=0.D0
      DO 2 I=1,3,1
      T(2)=T(2) + (V(I,2)+A(I,2))*(X+2.D0*M(I,2))*G(X,MF(I,2),MF(I,2))
     &-3.D0*M(I,2)/(8.D0*C*S)*G(X,MF(I,2),MF(I,2))
    2 CONTINUE
      T(2)=T(2)*4.D0/3.D0
      T(3)=0.D0
      DO 311 L=4,6,1
      DO 113 I=1,2,1
      T(3)=T(3) + (V(L,I)+A(L,I))*(X+2.D0*M(L,I))*G(X,MF(L,I),MF(L,I))
     &-3.D0*M(L,I)/(8.D0*C*S)*G(X,MF(L,I),MF(L,I))
  113 CONTINUE
  311 CONTINUE
      T(3)=T(3)*4.D0
      T(4)=(10.D0*X+20.D0*W)*(-C)*C+3.D0*W+(2.D0*W+X/4.D0)*(C-S)*(C-S)
      T(4)=T(4)*G(X,M0,M0)/(3.D0*S*C)
      T(5)=10.D0*Z-2.D0*H+X + (H-Z)*(H-Z)/X
      T(5)=T(5)*G(X,MH,MZ)/(12.D0*S*C)
      IMSZ=0.D0
      DO 100 I=1,5,1
      IMSZ=IMSZ+T(I)
  100 CONTINUE
      IMSZ=IMSZ*ALPHA
      END
C-----------------------------------------------------------------------
      FUNCTION G(Y,A,B)
C  IMAGINARY PART OF THE COMPLEX FUNCTION F
      IMPLICIT REAL*8(A-Z)
      PI=3.1415927
C     G(Y,M1,M2) = IM F(Y,M1,M2)
      P=(A+B)*(A+B)
      Q=(A-B)*(A-B)
      IF ( Y .LE. P ) GO TO 10
      G=DSQRT(Y-P)*DSQRT(Y-Q)*PI/Y
      GO TO 20
   10 CONTINUE
      G=0.0
   20 CONTINUE
      END
C-----------------------------------------------------------------------
      FUNCTION RESGZ(X)
C  REAL PART OF THE PHOTON-Z MIXING ENERGY
      IMPLICIT REAL*8(A-Z)
      INTEGER I,J,L
      DIMENSION M(6,2),V(6,2),A(6,2),VF(6,2),MF(6,2),T(20)
C GB  COMMON /BOS/MZ,M0,MH/FERMI/MF,VF,M,V,A
      COMMON /BOSON/MZ,M0,MH/FERMI/MF,VF,M,V,A
     1       /ALF/AL,ALPHA,ALFA
     2       /COUP/SW,CW,VL,A1,VU,AU,VD,AD
C  MF IS THE ARRAY OF FERMION MASSES, M THAT OF F MASS SQUARED
C  I = FAMILY INDEX (1...6); J = 1,2 DENOTES UP AND DOWN MEMBERS
C  VF IS THE ARRAY OF CORRESPONDING VECTOR COUPLINGS
C  V,A ARE THE ARRAYS OF THE SQUARES OF V AND A COUPLINGS
      PI=3.1415926536D0
      GF=1.16634D-5
      Z=MZ*MZ
      W=M0*M0
      H=MH*MH
      C=CW
      S=SW
      CS=DSQRT(C*S)
      C13=1.D0/3.D0
      C38=3.D0/8.D0
      DO 333 J=1,20,1
      T(J)=0.D0
  333 CONTINUE
      T(1)=0.D0
      DO 71 I=1,3,1
      T(1)=T(1) + VF(I,2)*(X*(F(X,MF(I,2),MF(I,2))-C13)   +2.D0*M(I,2)*
     &F(X,MF(I,2),MF(I,2)))
   71 CONTINUE
      T(1)=T(1)*4.*C13
      T(2)=0.D0
      DO 72 I=4,6,1
      T(2)=T(2)+VF(I,1)*(X*(F(X,MF(I,1),MF(I,1))-C13)   +2.D0*M(I,1)*
     &F(X,MF(I,1),MF(I,1)))
   72 CONTINUE
      T(2)=T(2)*(-8.D0)/3.D0
      T(3)=0.D0
      DO 73 I=4,6,1
      T(3)=T(3)+VF(I,2)*(X*(F(X,MF(I,2),MF(I,2))-   C13)+2.D0*M(I,2)*
     &F(X,MF(I,2),MF(I,2)))
   73 CONTINUE
      T(3)=T(3)*4.D0*C13
      T(4)=(X*(3.D0*C+1.D0/6.D0)+W*(4.D0*C+4.D0*C13))*F(X,M0,M0)/CS
      T(5)=X/(9.D0*CS)
      T(8)=0.D0
      DO 78 J=1,3,1
      T(8)=T(8)+(F(Z,MF(J,2),MF(J,2))-    C13)*(V(J,1)+V(J,2)+A(J,1)+
     &A(J,2)) +(2.D0*(V(J,2)+A(J,2))-3.D0/(8.D0*C*S))*M(J,2)/Z*
     &F(Z,MF(J,2),MF(J,2))
   78 CONTINUE
      T(8)=T(8)*(-X)*CS/S*4.D0*C13
      T(9)=0.D0
      DO 79 L=4,6,1
      DO 719 I=1,2,1
      FZLI=F(Z,MF(L,I),MF(L,I))
      T(9)=T(9)+( FZLI -C13)                  *(V(L,I)+A(L,I)) +
     &(2.D0*(V(L,I)+A(L,I))-C38/(    C*S))*M(L,I)/Z*FZLI
  719 CONTINUE
   79 CONTINUE
      T(9)=T(9)*4.D0*(-X)*CS/S
      T(10)=(C/(3.D0*S)*(10.D0+20.D0*C)-1.D0/S-(C-S)**2/(12.D0*S*C)*
     &(1.D0+8.D0*C))*F(Z,M0,M0)
      T(10)=T(10)*X*CS/S
      T(11)=(1.D0/(12.D0*S*C)*(2.D0*H/Z-11.D0)-1.D0/(12.D0*S*C)*(H-Z)*
     &(H-Z)/(Z*Z))*F(Z,MH,MZ)
      T(11)=T(11)*X*CS/S
      T(12)=(-1.D0)/(12.D0*S*C)*(2.D0*H/Z-11.D0)*(1.D0-(H+Z)/(H-Z)*
     &DLOG(MH/MZ) - DLOG(MH*MZ/W))
      T(12)=T(12)*(-X)*CS/S
      T(13)=(-1.D0)/(6.D0*S*C)*(H/Z*DLOG(H/W) + DLOG(Z/W)) -2.D0*C/
     &(9.D0*S)+1.D0/(18.D0*S*C) + (C-S)*(C-S)/(18.D0*S*C)
      T(13)=T(13)*(-X)*CS/S
      T(14)=0.D0
      DO 714 J=1,3,1
      T(14)=T(14)+(1.D0-M(J,2)/(2.D0*W))*(1.D0+F(W,0.D0,MF(J,2)))-C13-
     &0.5D0*M(J,2)*M(J,2)/(W*W)*F(W,0.D0,MF(J,2))
  714 CONTINUE
      T(14)=T(14)/(3.D0*S)*(-X)*CS/S*(-1.D0)
      T(15)=0.D0
      DO 715 L=4,6,1
      T(15)=T(15)
     &     + (1.D0-(M(L,1)+M(L,2))/(2.D0*W))*(1.D0-(M(L,1)+M(L,2))/
     &(M(L,1)-M(L,2))*DLOG(MF(L,1)/MF(L,2)) + F(W,MF(L,1),MF(L,2))) -
     &  C13   -.5D0*(M(L,1)-M(L,2))*(M(L,1)-M(L,2))/(W*W)*
     &F(W,MF(L,1),MF(L,2))
  715 CONTINUE
      T(15)=T(15)/S*(-X)*CS/S*(-1.D0)
      T(16)=(5.D0*S/(3.D0*C)-7.D0*C13-8.D0*C/S+1.D0/(12.D0*S)*Z/W
     &     *(Z/W-4.D0))*F(W,MZ,M0)
      T(16)=T(16)*(-X)*CS/S*(-1.D0)
      T(17)=(1.D0/S+1.D0/(12.D0*S)*H/W*(H/W-4.D0))*F(W,MH,M0)
     &- 4.D0*F(W,0.D0,M0)
      T(17)=T(17)*(-X)*CS/S*(-1.D0)
      T(18)=(1.D0+8.D0*C/S-S/C+1.D0/(4.D0*S))*Z/(Z-W)*DLOG(Z/W)
      T(18)=T(18)*(-X)*CS/S*(-1.D0)
      T(19)=(-3.D0)/(4.D0*S)*H/(H-W)*DLOG(H/W) +
     &(17.D0/18.D0-(Z+H)/(6.D0*W))/S + S/C-2.D0*C/(9.D0*S)-8.D0*C/S
     &- 44.D0/9.D0-7.D0/3.D0
      T(19)=T(19)*(-X)*CS/S*(-1.D0)
      T(20)=0.D0
      DO 720 L=4,6,1
      T(20)=T(20)+(2.D0/3.D0+(M(L,1)-M(L,2))/(Z-W))*
     &DLOG(M(L,1)/M(L,2))
CCC   T(20)=T(20)+2.D0/3.D0*DLOG(M(L,1)/M(L,2))
  720 CONTINUE
      T(20)=T(20)*(-X)/(4.D0*CS)
      RESGZ=0.D0
      DO 70 I=1,20,1
      RESGZ=RESGZ + T(I)
   70 CONTINUE
      RESGZ=RESGZ*ALPHA
      END
C-----------------------------------------------------------------------
      FUNCTION IMSGZ(X)
C  IMAGINARY PART OF PHOTON-Z MIXING ENERGY
      IMPLICIT REAL*8(A-Z)
      INTEGER I
      DIMENSION  T(25), VF(6,2),M(6,2),V(6,2),A(6,2),MF(6,2)
C GB  COMMON /BOS/MZ,M0,MH/FERMI/MF,VF,M,V,A
      COMMON /BOSON/MZ,M0,MH/FERMI/MF,VF,M,V,A
     1       /ALF/AL,ALPHA,ALFA
     2       /COUP/SW,CW,VL,A1,VU,AU,VD,AD
      C=CW
      S=SW
      Z=MZ*MZ
      W=M0*M0
      H=MH*MH
      PI=3.1415926536D0
      CS=DSQRT(C*S)
      C13=1.D0/3.D0
      T(1)=0.D0
      DO 1 I=1,3,1
      T(1)=T(1) + VF(I,2)*(X*G(X,MF(I,2),MF(I,2))+2.D0*M(I,2)*
     &G(X,MF(I,2),MF(I,2)))
    1 CONTINUE
      T(1)=T(1)*4.D0*C13
      T(2)=0.D0
      DO 2 I=4,6,1
      T(2)=T(2) + VF(I,1)*(X*G(X,MF(I,1),MF(I,1))+2.D0*M(I,1)*
     &G(X,MF(I,1),MF(I,1)))
    2 CONTINUE
      T(2)=T(2)*(-8.D0)/3.D0
      T(3)=0.D0
      DO 3 I=4,6,1
      T(3)=T(3) + VF(I,2)*(X*G(X,MF(I,2),MF(I,2))+2.D0*M(I,2)*
     &G(X,MF(I,2),MF(I,2)))
    3 CONTINUE
      T(3)=T(3)*4.D0*C13
      T(4)=(X*(3.D0*C+1.D0/6.D0)+W*(4.D0*C+4.D0*C13))*G(X,M0,M0)/CS
      IMSGZ=0.D0
      DO 30 I=1,4,1
      IMSGZ=IMSGZ + T(I)
   30 CONTINUE
      IMSGZ=IMSGZ*ALPHA
      END
C-----------------------------------------------------------------------
      SUBROUTINE INFRA(DEL,S,T,CIR,CIR1,CIR2)
      IMPLICIT REAL*8(A-Z)
      COMPLEX*16 CIR1,M2,CDABS,CDLOG,D1,D2,DEL2,DEL3
C GB  COMMON /BOS/MZ,MW,MH/LEPT/ME,MMU,MTAU/WIDTH/GZ
      COMMON /BOSON/MZ,MW,MH/LEPT/ME,MMU,MTAU/WIDTH/GZ
     1       /ALF/AL,ALPHA,ALFA
      XM2=MZ*MZ
      YM2=-MZ*GZ
      M2=DCMPLX(XM2,YM2)
      W=DSQRT(S)
      E=W/2.D0
      U=-S-T
      BE=DLOG(W/ME)*2-1.D0
      BINT=DLOG(T/U)
      DEL1=DLOG(DEL)
      D1=(S-M2)/(S-M2-S*DEL)
      D2=S/(M2-S+S*DEL)
      AD1=CDABS(D1)
      AD2=CDABS(D2)
      CIR=4.D0*AL*(BE+BINT)*DEL1
      DEL2=CDLOG(DEL*DEL*D1)
      DEL3=CDLOG(DEL*DEL*D2)
      CIR1=2.D0*AL*(BE*DEL2+BINT*DEL3)
      DEL4=DLOG(DEL*DEL*AD1)
      DEL5=DLOG(DEL*AD2)
      PHI0=DATAN((MZ**2-S)/MZ/GZ)
      PHI= DATAN((MZ**2-S+DEL*S)/MZ/GZ)
      CIR2=2.D0*AL*(BE*DEL4+2.D0*BINT*DEL5+BE*(S-MZ**2)/MZ/GZ
     1                                        *(PHI-PHI0))
      END
C-----------------------------------------------------------------------
      FUNCTION SPENCE(XX)
      IMPLICIT REAL*8(A-Z)
      INTEGER N
      COMPLEX*16 XX,X,Z,D,P,SPENCE,CDLOG
      DIMENSION A(19)
      PI=3.1415926536D0
      X=XX
      XR=DREAL(X)
      XI=DIMAG(X)
      IF(XR.NE.1.) GOTO 111
      IF(XI.EQ.0.) GOTO 20
111   CONTINUE
C    PROJEKTION IN DEN KONVERGENZKREIS
      VOR=1.D0
      P=DCMPLX(0.D0,0.D0)
      R=DREAL(X)
      IF (R .LE. 0.5D0) GOTO 1
      P=PI*PI/6.D0- CDLOG(X)*CDLOG(1.D0-X)
      VOR=-1.D0
      X=1.D0-X
    1 CONTINUE
      B=CDABS(X)
      IF (B .LT. 1.D0) GOTO 2
      P=P - (PI*PI/6.D0+ CDLOG(-X)*CDLOG(-X)/2.D0)*VOR
      VOR=VOR*(-1.D0)
      X=1.D0/X
    2 CONTINUE
C    BERECHNUNG DER SPENCE-FUNCTION
      A(1)=1.D0
      A(2)=-0.5D0
      A(3)=1.D0/6.D0
      A(5)=-1.D0/30.D0
      A(7)=1.D0/42.D0
      A(9)=-1.D0/30.D0
      A(11)=5.D0/66.D0
      A(13)=-691.D0/2730.D0
      A(15)=7.D0/6.D0
      A(17)=-3617.D0/510.D0
      A(19)=43867.D0/798.D0
      DO 5 N=2,9,1
      A(2*N)=0.D0
    5 CONTINUE
      Z=(-1.D0)*CDLOG(1.D0-X)
      D=DCMPLX(A(19),0.D0)
      DO 10 N=1,18,1
      D=D*Z/(20.D0-N) + A(19-N)
   10 CONTINUE
      D=D*Z
      SPENCE=D*VOR + P
      GOTO 30
   20 CONTINUE
      SPENCE=PI*PI/6.D0
   30 CONTINUE
      END
C-----------------------------------------------------------------------
      SUBROUTINE FGAM(S,FGVS,FGAS)
C  FORM FACTOR OF THE PHOTON
C  FGVS: VECTOR,  FGAS: AXIALVECTOR,  S = Q**2
      IMPLICIT REAL*8(A-Z)
      COMPLEX*16 FGVS,FGAS,LAM2,L2,LAM3,G1
C GB  COMMON /BOS/MZ,MW,MH/COUP/SW,CW,V,A,VU,AU,VD,AD
      COMMON /BOSON/MZ,MW,MH/COUP/SW,CW,V,A,VU,AU,VD,AD
     1       /ALF/AL,ALPHA,ALFA
C  WEAK CORRECTIONS TO PHOTON-LEPTON VERTEX
      W=V*V+A*A
      U=2.D0*V*A
      G1=.75D0/SW*LAM3(S,MW)
      L2=LAM2(S,MZ)
      FGVS=ALPHA*(W*L2+G1)
      FGAS=ALPHA*(U*L2+G1)
      END
C-----------------------------------------------------------------------
      SUBROUTINE FZ(S,FZVS,FZAS)
C   FORMFACTOR OF THE Z BOSON
C   FZVS: VECTOR,  FZAS: AXIALVECTOR,  S = Q**2
      IMPLICIT REAL*8(A-Z)
      COMPLEX*16 FZVS,FZAS,LAM2,L2Z,L2W,LAM3,L3W
C GB  COMMON /BOS/MZ,MW,MH/COUP/SW,CW,V,A,VU,AU,VD,AD
      COMMON /BOSON/MZ,MW,MH/COUP/SW,CW,V,A,VU,AU,VD,AD
     1       /ALF/AL,ALPHA,ALFA
C  WEAK CORRECTIONS TO Z-LEPTON VERTEX
      L2Z=LAM2(S,MZ)
      SW1=DSQRT(SW)
      CW1=DSQRT(CW)
      L2W=LAM2(S,MW)/(8.D0*SW1*CW1*SW)
      L3W=LAM3(S,MW)*.75D0*CW1/(SW1*SW)
      V2=V*V
      A2=A*A
      W3=V2+3.D0*A2
      U3=3.D0*V2+A2
      FZVS=ALPHA*(V*W3*L2Z+L2W-L3W)
      FZAS=ALPHA*(A*U3*L2Z+L2W-L3W)
      END
C-----------------------------------------------------------------------
      FUNCTION LAM2(S,M)
      IMPLICIT REAL*8(A-Z)
      COMPLEX*16 LAM2,SPENCE,      X1,X2,R3
      X=M*M/S
      R1=-3.5D0-2.D0*X-(2.D0*X+3.D0)*DLOG(DABS(X))
      PI=3.1415926536D0
      IF(X.LT.0.D0) GOTO 10
      L1=DLOG(1.D0+1.D0/X)
      W1=(1.D0+X)**2
      X1=DCMPLX(-1.D0/X,0.D0)
      R3=2.D0*W1*(DLOG(X)*L1-SPENCE(X1))
      R2=DREAL(R3)
      IM=3.D0+2.D0*X-2.D0*W1*L1
      RLAM=R1+R2
      ILAM=-IM*PI
      LAM2=DCMPLX(RLAM,ILAM)
      GOTO 20
10    W1=(1.D0+X)**2
      RX2=1.D0+1.D0/X
      X2=DCMPLX(RX2,0.D0)
      PI2=PI*PI
      R3=2.D0*W1*(SPENCE(X2)-PI2/6.D0)
      R2=DREAL(R3)
      LAM2=DCMPLX(R1+R2,0.D0)
20    CONTINUE
      END
C-----------------------------------------------------------------------
      FUNCTION LAM3(S,M)
      IMPLICIT REAL*8(A-Z)
      COMPLEX*16 CPI,LAM3
      X=M*M/S
C  VALID ALSO FOR S GREATER THAN 4*M**2
      IF(X.GT.0.D0) GOTO 10
      SQ=DSQRT(1.D0-4.D0*X)
      LN=DLOG((SQ+1.D0)/(SQ-1.D0))
      LN2=LN*LN
      LA3 =5.D0/6.D0-2.D0/3.D0*X+(2.D0*X+1.D0)/3.D0*SQ*LN
     1    +2.D0/3.D0*X*(X+2.D0)*LN2
      LAM3=DCMPLX(LA3,0.D0)
      GOTO 20
10    DISC=4.D0*X-1.D0
      IF (DISC.LT.0.D0) GOTO 11
      SQ=DSQRT(DISC)
      A=DATAN(1.D0/SQ)
      A2=A*A
      LA3 =5.D0/6.D0-2.D0/3.D0*X+2.D0/3.D0*(2.D0*X+1.D0)*SQ*A
     1     -8.D0/3.D0*X*(X+2.D0)*A2
      LAM3=DCMPLX(LA3,0.D0)
      GOTO 20
11    DISC=-DISC
      SQ=DSQRT(DISC)
      PI=3.1415926536D0
      CPI=DCMPLX(0.D0,PI)
      LN=DLOG((1.D0+SQ)/(1.D0-SQ))
      LAM3=5.D0/6.D0-2.D0*X/3.D0+(2.D0*X+1.D0)/3.D0*SQ*LN
     1    +2.D0/3.D0*X*(X+2.D0)*(LN*LN-PI*PI)
     2    -CPI*((2.D0*X+1.D0)/3.D0*SQ+2.D0*LN)
20    CONTINUE
      END
C-----------------------------------------------------------------------
      SUBROUTINE   BOX(S,T,V1ZZS,V2ZZS,A1ZZS,A2ZZS,
     1                     V1ZZT,V2ZZT,A1ZZT,A2ZZT,
     2                     V1WS,V2WS,V1WT,V2WT)
C  HEAVY BOX DIAGRAMS
C  1:REAL PARTS,  2: IMAGINARY PARTS
      IMPLICIT REAL*8(A-Z)
      COMPLEX*16      IST,ISU,ITS,ITU,I5ST,I5SU,I5TS,I5TU,CPI,
     1           VS,AS,VT,AT,VWS,VWT
C GB  COMMON /BOS/MZ,MW,MH/WIDTH/GZ
      COMMON /BOSON/MZ,MW,MH/WIDTH/GZ
      PI2=2.*3.1415926536D0
      CPI=DCMPLX(0.D0,PI2)
      CALL INTE(S,T,MZ,IST,I5ST)
      U=-S-T
      CALL INTE(S,U,MZ,ISU,I5SU)
      CALL INTE(T,S,MZ,ITS,I5TS)
      CALL INTE(T,U,MZ,ITU,I5TU)
C
      VS=IST-ISU
      AS=I5ST+I5SU
      VT=ITS-ITU
      AT=I5TS+I5TU
C
      CALL INTE(S,T,MW,IST,I5ST)
      VWS=IST+I5ST
      CALL INTE(T,S,MW,ITS,I5TS)
      VWT=ITS+I5TS
C
      V1ZZS=DREAL(VS)
      A1ZZS=DREAL(AS)
      V1ZZT=DREAL(VT)
      A1ZZT=DREAL(AT)
      V2ZZS=DIMAG(VS)/PI2
      A2ZZS=DIMAG(AS)/PI2
      V2ZZT=DIMAG(VT)/PI2
      A2ZZT=DIMAG(AT)/PI2
      V1WS=DREAL(VWS)
      V1WT=DREAL(VWT)
      V2WS=DIMAG(VWS)/PI2
      V2WT=DIMAG(VWT)/PI2
      END
