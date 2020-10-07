cFrom BLOCH@alws.cern.ch Fri Feb 13 15:23:02 2004
cDate: Fri, 13 Feb 2004 15:18:15 +0100
cFrom: BLOCH@alws.cern.ch
cTo: BLOCH@alws.cern.ch

C-----------------------------------------------------------------------
C           A L E P H   I N S T A L L A T I O N    N O T E S           |
C                                                                      |
C    Aleph    name  : BHAB02.                                          |
C    original code  : BABAMC from Kleiss, Behrends and Hollik.         |
C    transmitted by : J. Perlas September 1988.                        |
C                                                                      |
C       (see KINLIB DOC for a description of this version)             |
C                                                                      |
C ----------------------------------------------------------------------
C Modifications to the original code :                                 |
C                                                                      |
C                                                                      |
C 1. COMMON /BOS/ has been renamed COMMON / BOSON / .                  |
C 2. COMMON/ INPOUT / IOUT has been introduced and IOUT initialized to |
C    6 in the MAIN.                                                    |
C 3. ICON has been introduced in the list of arguments to call GENBAB  |
C    to keep the information of the diagram of origine contributing to |
C    an event.                                                         |
C             (G. Bonneaud September 1988).                            |
C                                                                      |
C 4. MOD in GENBAB to reject events with weight=0. (H. Burkhardt and   |
C    E. Locci, ALEPH 88-139) - (G. Bonneaud November 1988; correction  |
C    taken in BHAB01 which was done by B. Bloch November 1988).        |
C                                                                      |
C                                                                      |
C 5. Function RN replaced by RNDM (for use of RANMAR)                  |
C                                   (G. Bonneaud August 1989).         |
C                                                                      |
C 6. Variable MUM used for calculating GAM0M in subroutine ZWIDTH      |
C    doesn't exist. It is likely MUMU which is defined in the subrou-  |
C    tine itself. MUMU is used instead of MUM (G. Bonneaud August 1989)|
C                                                                      |
C 7. Replace function PIG(S) as advertised by H.Burkhardt February 1990|
C----------------------------------------------------------------------
      PROGRAM BAB10
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
C----------------------------------------------------------------------
C THIS IS THE MAIN PROGRAM, CONSISTING OF:
C 1) INITIALIZATION OF THE GENERATOR;
C 2) GENERATION OF AN EVENT SAMPLE,
C    AND SUBSEQUENT ANALYSIS OF THE EVENTS;
C 3) EVALUATION OF THE TOTAL GENERATED CROSS SECTION
C
C
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / INPOUT / IOUT
      COMMON / INPUT1 / EB
      COMMON / INPUT2 / XMZ,S2W,XMH,XMT
      COMMON / INPUT3 / THMIN,THMAX,XKMAX
      COMMON / UNICOM / IIN,IUT
CC-RM
      COMMON / POL    / POLP,POLM
      COMMON / QCD    / AS
      COMMON / NEWOLD / INEW
CC-RM
      DIMENSION PP(4),PM(4),QP(4),QM(4),QK(4)
C
C THE SETUP PHASE: ASK FOR THE INPUT PARAMETERS
      IIN=5
      IUT=6
      IOUT = 6
CC-RM
      READ(33,888) EB,XMZ,XMT,XMH,THMIN,THMAX,XKMAX,NEVENT
 888  FORMAT(//,7D10.4,I8)
      READ(33,458) POLP,POLM
 458  FORMAT(/,2D10.4)
      READ(33,459) AS
 459  FORMAT(/,1D10.4)
      READ(33,759) INEW
 759  FORMAT(/,I10)
      IF (XMT.LE.XMZ/2.D0.OR.XMT.GE.150.D0) THEN
C GB     WRITE(6,*) 'WARNING !! : THE Z0 WIDTH IS COMPUTED WITH THE'
         WRITE(IOUT,*) 'WARNING !! : THE Z0 WIDTH IS COMPUTED WITH THE'
C GB     WRITE(6,*) 'NEEDED ACCURACY ONLY WHEN XMZ/2 < XMT < 150 GEV'
         WRITE(IOUT,*) 'NEEDED ACCURACY ONLY WHEN XMZ/2 < XMT < 150 GEV'
      ENDIF
      IF (POLP*POLM.EQ.1.D0) THEN
C GB     WRITE(6,*) 'WARNING !! : THE RESULT IS NOT COMPLETELY RELIABLE'
      WRITE(IOUT,*) 'WARNING !! : THE RESULT IS NOT COMPLETELY RELIABLE'
C GB     WRITE(6,*) 'WHEN POLP*POLM = 1'
         WRITE(IOUT,*) 'WHEN POLP*POLM = 1'
      ENDIF
CC-RM
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
      COMMON / INPOUT / IOUT
      CHARACTER*10 STRING
      X1=(1.D0*K)/(1.D0*NTEL)
      X2=1.D0*(K/NTEL)
C GB  IF(X1.EQ.X2) WRITE(6,1) K,STRING
      IF(X1.EQ.X2) WRITE(IOUT,1) K,STRING
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
      COMMON / INPOUT / IOUT
      CHARACTER*1 REGEL(30),BLANK,STAR
      COMMON / HISTOC /H(100,10),HX(100),IO(100),IU(100),II(100),
     .                 Y0(100),Y1(100),IC(100)
      COMMON / UNICOM / IIN,IUT
      DATA REGEL /30*' '/,BLANK /' '/,STAR /'*'/
      X0=Y0(IH)
      X1=Y1(IH)
      IB=IC(IH)
      HX(IH)=HX(IH)*(1.D0+1.D-06)
      IF(IL.EQ.0) WRITE(IOUT,21) IH,II(IH),IU(IH),IO(IH)
      IF(IL.EQ.1) WRITE(IOUT,22) IH,II(IH),IU(IH),IO(IH)
   21 FORMAT(' NO.',I3,' LIN : INSIDE,UNDER,OVER ',3I6)
   22 FORMAT(' NO.',I3,' LOG : INSIDE,UNDER,OVER ',3I6)
      IF(II(IH).EQ.0) GOTO 28
      WRITE(IOUT,23)
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
      WRITE(IOUT,26) Z,H(IH,IV),(REGEL(I),I=1,30)
   26 FORMAT(1H ,2G15.6,4H   I,30A1,1HI)
      IF(IZ.GT.0.AND.IZ.LE.30) REGEL(IZ)=BLANK
   27 CONTINUE
      WRITE(IOUT,23)
CHBU  print before PAUSE
      IF(IUT.EQ.0) PRINT *,'PAUSE'
      IF(IUT.EQ.0) PAUSE
      RETURN
   28 WRITE(IOUT,29)
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
CC-RM      SUBROUTINE PRNVEC(QP,QM,QK,A1,A2,A3,A4,WM,EX,I)
      SUBROUTINE PRNVEC(QP,QM,QK,A1,A2,A3,A4,WM,EX,WTOT,I)
      IMPLICIT REAL*8(A-H,O-Z)
      DIMENSION QP(4),QM(4),QK(4)
      COMMON / INPOUT / IOUT
      COMMON / UNICOM / IIN,IUT
      IF(QK(4).EQ.0.D0) RETURN
      WRITE(IOUT,1) (QP(K),QM(K),QK(K),K=1,4)
    1 FORMAT('0ANOMALOUS EVENT PRINTOUT',4(/3D15.6))
      CP=QP(3)/QP(4)
      CM=QM(3)/QM(4)
      CK=QK(3)/QK(4)
      WRITE(IOUT,2) CP,CM,CK
    2 FORMAT(' COSINES OF THE SCATTERING ANGLES:'/,3D15.6)
      CPM=(QP(1)*QM(1)+QP(2)*QM(2)+QP(3)*QM(3))/QP(4)/QM(4)
      CPK=(QP(1)*QK(1)+QP(2)*QK(2)+QP(3)*QK(3))/QP(4)/QK(4)
      CMK=(QM(1)*QK(1)+QM(2)*QK(2)+QM(3)*QK(3))/QM(4)/QK(4)
      WRITE(IOUT,3) CPM,CPK,CMK
    3 FORMAT(' COSINES BETWEEN P-M, P-K, M-K :'/,3D15.6)
      XPM=2.D0*(QP(4)*QM(4)-QP(3)*QM(3)-QP(2)*QM(2)-QP(1)*QM(1))
      XPK=2.D0*(QP(4)*QK(4)-QP(3)*QK(3)-QP(2)*QK(2)-QP(1)*QK(1))
      XMK=2.D0*(QK(4)*QM(4)-QK(3)*QM(3)-QK(2)*QM(2)-QK(1)*QM(1))
      WRITE(IOUT,4) XPM,XPK,XMK
    4 FORMAT(' INVARIANT MASSES P-M, P-K, M-K :'/,3D15.6)
CC-RM      WTOT=EX*WM/(A1+A2+A3+A4)
      WRITE(IOUT,5) A1,A2,A3,A4,WM,EX,WTOT,I
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
      COMMON / INPOUT / IOUT
      COMMON / UNICOM / IIN,IUT
      WRITE(IOUT,1)
    1 FORMAT(' COMPARISON OF EXPECTED AND OBTAINED EFFICIENCIES')
      WRITE(IOUT,11) EFK1
   11 FORMAT(' GENER1 : K LOOP : ',D15.6)
      WRITE(IOUT,21) EFK2
   21 FORMAT(' GENER2 : K LOOP : ',D15.6)
      WRITE(IOUT,41) EFK4PR,EFK4PO,EFC4PR,EFC4PO
   41 FORMAT(' GENER4 : K LOOP : ',D15.6,' EXPECTED'/,
     .       '                   ',D15.6,' OBSERVED'/,
     .       '          C LOOP : ',D15.6,' EXPECTED'/,
     .       '                   ',D15.6,' OBSERVED')
      WRITE(IOUT,51) EFPR5,EFPO5
   51 FORMAT(' GENER5 : C LOOP : ',D15.6,' EXPECTED'/,
     .       '                   ',D15.6,' OBSERVED')
      END
C-----------------------------------------------------------------------
      SUBROUTINE OUTCRY(STRING)
      COMMON / INPOUT / IOUT
      CHARACTER*6 STRING
      WRITE(IOUT,1) STRING
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
      COMMON / INPOUT / IOUT
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
      WRITE(IOUT,1) AMZ,   AGZ,     E,    GA,
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
      REAL*8 XME,X
      COMPLEX*16 PIGTAB,SLFTAB
      DIMENSION PP(4),PM(4),QP(4),QM(4),QK(4)
      DIMENSION A(5),ZC(5),ZM(12)
      COMMON / AMPCOM / E3,  EG1,  EG2,  EG3,
     .                  AM2Z,  AMGZ
      COMMON / AMPCM2 / PPK,  PMK,  QPK,  QMK
      COMMON / POL    / POLP,POLM
      COMMON / NEWOLD / INEW
      DATA INIT/0/
C-----------------------------------------------------------------------
C
C THE PHOTON-CUM-Z0 PROPAGATORS
CC-RM
C  NOW WE INCLUDE THE SELF ENERGY CORRECTIONS
          Z1(S)=E3/(S*(1.D0-PIGTAB(0,S)))+EG1/(S-AM2Z+SLFTAB(0,S))
          Z2(S)=E3/(S*(1.D0-PIGTAB(0,S)))+EG2/(S-AM2Z+SLFTAB(0,S))
          Z3(S)=E3/(S*(1.D0-PIGTAB(0,S)))+EG3/(S-AM2Z+SLFTAB(0,S))
CC-RM
          Z11(S)=E3/S+EG1/DCMPLX(S-AM2Z,AMGZ)
          Z22(S)=E3/S+EG2/DCMPLX(S-AM2Z,AMGZ)
          Z33(S)=E3/S+EG3/DCMPLX(S-AM2Z,AMGZ)
C
C THE DEFINITION OF THE SPINOR PRODUCT
      ZS(I,J)=ZC(I)*A(J)-ZC(J)*A(I)
C
CC-RM
      IF (INEW.EQ.1.AND.INIT.EQ.0) THEN
          DUM1=PIGTAB(-1,DUM0)
          DUM2=SLFTAB(-1,DUM0)
          INIT=1
      ENDIF
CC-RM
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
CC-RM
      IF (INEW.EQ.1) THEN
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
      ELSE
          Z1T1=Z11(T1)
          Z2T1=Z22(T1)
          Z3T1=Z33(T1)
          Z1T0=Z11(T0)
          Z2T0=Z22(T0)
          Z3T0=Z33(T0)
          Z1S1=Z11(S1)
          Z2S1=Z22(S1)
          Z3S1=Z33(S1)
          Z1S0=Z11(S0)
          Z2S0=Z22(S0)
          Z3S0=Z33(S0)
      ENDIF
CC-RM
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
CC-RM
C
COMPUTE THE EFFECTIVE DEGREE OF LONGITUDINAL POLARIZATION (MASS EFFECT)
C FORMULAE TAKEN FROM R. KLEISS, Z. PHYS. C33 (1987) 433.
      XME    = 0.0005110034D0
      EPS    = 0.5D0*(XME/PP(4))**2
      CTG    = QK(3)/QK(4)
      X      = QK(4)/PP(4)
      R      = (1.D0-X+X*X)/(1.D0-X)
      PPDK   = PP(4)*QK(4)*(1.D0-CTG+EPS)
      PMDK   = PM(4)*QK(4)*(1.D0+CTG+EPS)
      TPPK   = XME**2/PPDK*X*(1.D0-X)/(2.D0-2.D0*X+X*X)
      TPMK   = XME**2/PMDK*X*(1.D0-X)/(2.D0-2.D0*X+X*X)
      PPEFF  =-POLP*(1.D0-R*TPPK)/(1.D0-TPPK)
      PMEFF  = POLM*(1.D0-R*TPMK)/(1.D0-TPMK)
C
C DEFINE THE RESULTING CROSS SECTION
      RESULT = (1.D0+PPEFF)*(1.D0+PMEFF)*
     .(CDABS(ZM(1))**2+CDABS(ZM(12))**2+CDABS(ZM(2))**2+CDABS(ZM(11))**2
     .)      + (1.D0+PPEFF)*(1.D0-PMEFF)*
     .(CDABS(ZM(3))**2+CDABS(ZM(10))**2)
     .       + (1.D0-PPEFF)*(1.D0+PMEFF)*
     .(CDABS(ZM(4))**2+CDABS(ZM(9))**2)
     .       + (1.D0-PPEFF)*(1.D0-PMEFF)*
     .(CDABS(ZM(5))**2+CDABS(ZM(8))**2+CDABS(ZM(6))**2+CDABS(ZM(7))**2)
      RESULT = RESULT/4.D0
CC-RM
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
      COMMON / INPOUT / IOUT
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
      WRITE(IOUT,1)   E,   XMZ,   XGZ,    GV,
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
      COMMON / INPOUT / IOUT
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
      WRITE(IOUT,1) XKMAX
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
      WRITE(IOUT,3)   E,   XK0,   XK1,   XME,   PI,
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
      COMMON / INPOUT / IOUT
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
      WRITE(IOUT,1) XME,    PI,   EEL,    XL,
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
      COMMON / INPOUT / IOUT
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
      WRITE(IOUT,1) XME,    PI,   EEL,    XL,
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
      COMMON / INPOUT / IOUT
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
      WRITE(IOUT,1) XME,    PI,   EEL,    XL,
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
      COMMON / INPOUT / IOUT
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
      WRITE(IOUT,9)
    9 FORMAT(' SETUP5 : END OF THE SOFT CROSS SECTION PART')
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
      WRITE(IOUT,3)   E, THMIN, THMAX,  XMIN,
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
      COMMON / INPOUT / IOUT
      COMMON / UNICOM / IIN,IUT
C
      CALL OUTCRY('I.I.S.')
C
C PRINT OUT THE PARAMETERS
      WRITE(IOUT,1) X1,XN,N,ITER
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
      WRITE(IOUT,3) IT,Y(M)
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
      INTEGER I,J,IIN,IUT,IOUT
      DIMENSION MF(6,2),VF(6,2),M(6,2),VF2(6,2),AF2(6,2)
      COMMON /BOSON/MZ,MW,MH/LEPT/ME,MMU,MTAU
     .       /HAD/MU,MD,MS,MC,MB,MT
     .       /COUP/SW,CW,V,A,VU,AU,VD,AD
     .       /WIDTH/GZ
     .       /ALF/AL,ALPHA,ALFA
     .       /FERMI/MF,VF,M,VF2,AF2
     .       /CONV/CST
      COMMON /SVLCOM/ SVALUE,DEL
      COMMON / INPOUT / IOUT
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
CC-RM      GZ=IMSZ(MZ**2)/MZ
      GZTOT=IMSZ(MZ**2)/MZ
      GZ=IIMSZ(MZ**2)/MZ
      XGZ=GZ
CC-RM      WRITE(IUT,1001) XGZ
      WRITE(IOUT,1001) GZTOT
 1001 FORMAT(' SETUPS : I FOUND A TOTAL Z0 WIDTH OF ',F10.4,' GEV'/,
     . ' ',50('-'))
      SETUPS=0.
      END
C-----------------------------------------------------------------------
      FUNCTION SIGSOF(C)
C GIVES THE CORRECTED FORM FOR D(SIGMA)/D(OMEGA)
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON /SVLCOM/ S,DEL
      COMMON / INPOUT / IOUT
      COMMON / UNICOM / IIN,IUT
C
      T=-.5D0*(1.D0-C)*S
      CALL BABCOR(S,T,DEL,DSIG0,DSIG)
      SIGSOF=DSIG
      IF(SIGSOF.LT.0.D0) WRITE(IOUT,4) SIGSOF,C
    4 FORMAT(' SIGSOF : VALUE =',D15.6,'    AT C = ',F8.5)
      END
C----------------------------------------------------------------------
      SUBROUTINE BABCOR (S,T,DEL,DSIG0P,DSIGP)
C----------------------------------------------------------------------
C!
C!   CREATED BY RAMON MIQUEL          22-MAR-1988
C!
C!   FORMULAE TAKEN FROM BOEHM, DENNER AND HOLLIK, DESY 86-165
C!
C!   WARNING!! : THERE IS AN ERROR IN FORMULA (3.22) IN THIS PAPER :
C!               THE LAST LINE OF PAG. 9 HAS TO BE :
C!                   SP((M^2+T)/T) - SP((M^2+U)/U)
C!               INSTEAD OF :
C!                 2*SP((M^2+T)/T) - 2*SP((M^2+U)/U)
C!
C!   PURPOSE   : THIS ROUTINE CALCULATES THE CORRECTED D(SIGMA)/D(OMEGA)
C!   INPUTS    : S,T ARE THE MANDELSTAM VARIABLES
C!               DEL IS MAXIMUM PHOTON ENERGY / BEAM ENERGY
C!   OUTPUTS   : DSIG0P: DIFFERENTIAL BORN CROSS SECTION (IN PBARN)
C!               DSIGP : DIFFERENTIAL CROSS SECTION WITH
C!                                      RAD. CORRECTIONS (IN PBARN)
C!
C!   CALLED BY : SIGSOF
C!   CALLS     : PIG,RESZ,IMSZ,SPENCE,INFRA,AGG,AGZ,D,PIGZ,FG,FZ,IZZ,AZZ
C!
C----------------------------------------------------------------------
C----------------------------------------------------------------------
C
C  MZ, MW, MH ARE THE BOSON MASSES, ME,...MT THE FERMION MASSES IN GEV.
C  SWSQ = SIN**2 THETA-W, CWSQ = COS**2 THETA-W
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
C  CST IS THE CONVERSION FACTOR TO PBARNS
C*****************************************************************
      IMPLICIT REAL*8 (A-Z)
      INTEGER*4 I,J,J1,L,INEW
      DIMENSION MF(6,2),VF(6,2),M(6,2),VF2(6,2),AF2(6,2),
     .          GW(2),DSIG0(3,2),DSIGQ(3,2),DSIGW(3,2),
     .          DSIGV(3,2)
      COMMON /BOSON/MZ,MW,MH/LEPT/ME,MMU,MTAU
     .       /HAD/MU,MD,MS,MC,MB,MT
     .       /COUP/SWSQ,CWSQ,V,A,VU,AU,VD,AD
     .       /WIDTH/GZ0
     .       /ALF/AL,ALPHA,ALFA
     .       /FERMI/MF,VF,M,VF2,AF2
     .       /CONV/CST
      COMMON /POL/PP,PM
      COMMON /KK/GG(2),GZ(2)
      COMMON / NEWOLD / INEW
      COMPLEX*16 M00SG(2,2),M00TG(2,2),M00SZ(2,2),M00TZ(2,2),
     .           M0SG(2,2),M0TG(2,2),M0SZ(2,2),M0TZ(2,2),
     .           CHI0SZ,CHISG,CHITG,CHISZ,GINT,PIZS,
     .           DQSG(2,2),DQTG(2,2),DQSZ(2,2),DQTZ(2,2),
     .           DWSGS(2,2),DWTGS(2,2),DWSZS(2,2),DWTZS(2,2),
     .           DWSGV(2,2),DWTGV(2,2),DWSZV(2,2),DWTZV(2,2),
     .           DWSGB(2,2),DWTGB(2,2),DWSZB(2,2),DWTZB(2,2),
     .           DWSG(2,2),DWTG(2,2),DWSZ(2,2),DWTZ(2,2),
     .           MM,ZS,Y,X,X1C,X2C,SP1,SP2,SPENCE,
     .           PIG,PIGS,PIGT,AGG,AGZ,D,PIGZ,PIGZS,PIGZT,FG,FZ,
     .           IZZ,AZZ,IZZSTZ,IZZSUZ,IZZTSZ,IZZTUZ,IZZSTW,IZZTSW,
     .           AZZSTZ,AZZSUZ,AZZTSZ,AZZTUZ,AZZSTW,AZZTSW
      PARAMETER(PI=3.141592654D0)
C
      U=-S-T
      SW=DSQRT(SWSQ)
      CW=DSQRT(CWSQ)
      MZSQ=MZ*MZ
      MWSQ=MW*MW
      MGZ=MZ*GZ0
      MM=DCMPLX(MZSQ,-MGZ)
C
      GG(1)=1.D0
      GG(2)=1.D0
      GZ(1)=(2.D0*SWSQ-1.D0)/(2.D0*SW*CW)
      GZ(2)=SW/CW
      GW(1)=1.D0/(DSQRT(2.D0)*SW)
      GW(2)=0.D0
C
      CHI0SG=1.D0
      CHI0TG=1.D0
      CHI0SZ=S/(S-MM)
      CHI0TZ=T/(T-MZSQ)
C
      DO 10 J=1,2
         J1=3-J
         M00SG(1,J)=2.D0*U/S*GG(J)*CHI0SG*GG(J)
         M00SZ(1,J)=2.D0*U/S*GZ(J)*CHI0SZ*GZ(J)
         M00SG(2,J)=2.D0*T/S*GG(J)*CHI0SG*GG(J1)
         M00SZ(2,J)=2.D0*T/S*GZ(J)*CHI0SZ*GZ(J1)
         M00TG(1,J)=2.D0*U/T*GG(J)*CHI0TG*GG(J)
         M00TZ(1,J)=2.D0*U/T*GZ(J)*CHI0TZ*GZ(J)
         M00TG(2,J)=2.D0*S/T*GG(J)*CHI0TG*GG(J1)
         M00TZ(2,J)=2.D0*S/T*GZ(J)*CHI0TZ*GZ(J1)
   10 CONTINUE
C
      DO 20 J=1,2
         DSIG0(1,J)=(M00SG(1,J)+M00SZ(1,J)+M00TG(1,J)+M00TZ(1,J))*
     .       DCONJG((M00SG(1,J)+M00SZ(1,J)+M00TG(1,J)+M00TZ(1,J)))
         DSIG0(2,J)=(M00SG(2,J)+M00SZ(2,J))*
     .       DCONJG((M00SG(2,J)+M00SZ(2,J)))
         DSIG0(3,J)=(M00TG(2,J)+M00TZ(2,J))*
     .       DCONJG((M00TG(2,J)+M00TZ(2,J)))
   20 CONTINUE
C
      DSIG0U=0.D0
      DO 30 I=1,3
      DO 30 J=1,2
         DSIG0U=DSIG0U+DSIG0(I,J)
   30 CONTINUE
      DSIG0U=CST*DSIG0U/4.D0
C
      DSIG0L=0.D0
      DO 40 J=1,2
         L=2*J-3
         DSIG0L=DSIG0L+L*DSIG0(1,J)
   40 CONTINUE
      DSIG0L=-CST*DSIG0L/4.D0
C
      DSIG0D=0.D0
      DO 50 J=1,2
         DSIG0D=DSIG0D+DSIG0(3,J)
   50 CONTINUE
      DSIG0D=CST*DSIG0D/2.D0
C
      DSIG0P=DSIG0U*(1.D0-PP*PM)+(PP-PM)*DSIG0L+PP*PM*DSIG0D
C
C END OF THE LOWEST ORDER CALCULATION
C
      PIGS=PIG(S)
      PIGT=PIG(T)
      CHISG=1.D0/(1.D0-PIGS)
      CHITG=1.D0/(1.D0-PIGT)
      RZS=RESZ(S)
      IZS=IMSZ(S)
      RZT=RESZ(T)
      ZS=DCMPLX(RZS,IZS)
      CHISZ=S/(S-MZSQ+ZS)
      CHITZ=T/(T-MZSQ+RZT)
C
      IF (INEW.EQ.1) THEN
         DO 60 J=1,2
            J1=3-J
            M0SG(1,J)=2.D0*U/S*GG(J)*CHISG*GG(J)
            M0SZ(1,J)=2.D0*U/S*GZ(J)*CHISZ*GZ(J)
            M0SG(2,J)=2.D0*T/S*GG(J)*CHISG*GG(J1)
            M0SZ(2,J)=2.D0*T/S*GZ(J)*CHISZ*GZ(J1)
            M0TG(1,J)=2.D0*U/T*GG(J)*CHITG*GG(J)
            M0TZ(1,J)=2.D0*U/T*GZ(J)*CHITZ*GZ(J)
            M0TG(2,J)=2.D0*S/T*GG(J)*CHITG*GG(J1)
            M0TZ(2,J)=2.D0*S/T*GZ(J)*CHITZ*GZ(J1)
   60    CONTINUE
      ELSE
         DO 61 J=1,2
         DO 61 I=1,2
            M0SG(I,J)=M00SG(I,J)
            M0SZ(I,J)=M00SZ(I,J)
            M0TG(I,J)=M00TG(I,J)
            M0TZ(I,J)=M00TZ(I,J)
   61    CONTINUE
      ENDIF
C
      DO 320 J=1,2
         DSIGV(1,J)=(M0SG(1,J)+M0SZ(1,J)+M0TG(1,J)+M0TZ(1,J))*
     .       DCONJG((M0SG(1,J)+M0SZ(1,J)+M0TG(1,J)+M0TZ(1,J)))
         DSIGV(2,J)=(M0SG(2,J)+M0SZ(2,J))*
     .       DCONJG((M0SG(2,J)+M0SZ(2,J)))
         DSIGV(3,J)=(M0TG(2,J)+M0TZ(2,J))*
     .       DCONJG((M0TG(2,J)+M0TZ(2,J)))
  320 CONTINUE
C
      DSIGVU=0.D0
      DO 330 I=1,3
      DO 330 J=1,2
         DSIGVU=DSIGVU+DSIGV(I,J)
  330 CONTINUE
      DSIGVU=CST*DSIGVU/4.D0
C
      DSIGVL=0.D0
      DO 340 J=1,2
         L=2*J-3
         DSIGVL=DSIGVL+L*DSIGV(1,J)
  340 CONTINUE
      DSIGVL=-CST*DSIGVL/4.D0
C
      DSIGVD=0.D0
      DO 350 J=1,2
         DSIGVD=DSIGVD+DSIGV(3,J)
  350 CONTINUE
      DSIGVD=CST*DSIGVD/2.D0
C
      DSIGVP=DSIGVU*(1.D0-PP*PM)+(PP-PM)*DSIGVL+PP*PM*DSIGVD
C
C END OF THE LOWEST ORDER + SELF ENERGIES CALCULATION
C
      C=1.D0+2.D0*T/S
      C1=1.D0-C
      C0=1.D0+C
      ME2=ME*ME
      BE=DLOG(S/ME2)-1.D0
      X1=C1/2.D0
      X2=C0/2.D0
      DX1=DLOG(X1)
      DX2=DLOG(X2)
      X1C=DCMPLX(X1,0.D0)
      X2C=DCMPLX(X2,0.D0)
      SP1=SPENCE(X1C)
      SP2=SPENCE(X2C)
C
      X=DX1**2-DX2**2-2.D0*SP1+2.D0*SP2
      Z= 3.D0*BE-1.D0+2.D0*PI**2/3.D0
      YRE=3.D0*DX1-DX1**2-PI**2+2.D0*DX1*DX2
      YIM=2.D0*PI*(DX2+1.5D0)
      Y=DCMPLX(YRE,YIM)
C
      CALL INFRA(DEL,S,T,GNR,GINT,GRES)
C
      DQSG(1,1)=AL/2.D0*(Z+X+2.D0*AGG(S,T))
      IF (INEW.EQ.0) DQSG(1,1)=DQSG(1,1)+PIGS
      DQSG(1,2)=DQSG(1,1)
      DQSG(2,1)=AL/2.D0*(Z+X-2.D0*AGG(S,U))
      IF (INEW.EQ.0) DQSG(2,1)=DQSG(2,1)+PIGS
      DQSG(2,2)=DQSG(2,1)
C
      DQTG(1,1)=AL/2.D0*(Z+Y+X+2.D0*AGG(T,S))
      IF (INEW.EQ.0) DQTG(1,1)=DQTG(1,1)+PIGT
      DQTG(1,2)=DQTG(1,1)
      DQTG(2,1)=AL/2.D0*(Z+Y+X-2.D0*AGG(T,U))
      IF (INEW.EQ.0) DQTG(2,1)=DQTG(2,1)+PIGT
      DQTG(2,2)=DQTG(2,1)
C
      DQSZ(1,1)=AL/2.D0*(Z+X+2.D0*AGZ(S,T)+2.D0*D(S,T))
      DQSZ(1,2)=DQSZ(1,1)
      DQSZ(2,1)=AL/2.D0*(Z+X-2.D0*AGZ(S,U)+2.D0*D(S,T))
      DQSZ(2,2)=DQSZ(2,1)
C
      DQTZ(1,1)=AL/2.D0*(Z+Y+X+2.D0*AGZ(T,S)+2.D0*D(T,S))
      DQTZ(1,2)=DQTZ(1,1)
      DQTZ(2,1)=AL/2.D0*(Z+Y+X-2.D0*AGZ(T,U)+2.D0*D(T,S))
      DQTZ(2,2)=DQTZ(2,1)
C
      DO 70 J=1,2
         DSIGQ(1,J)=
     .              DREAL(
     .   M0SZ(1,J)*DCONJG(M0SZ(1,J))*(DQSZ(1,J)+DCONJG(DQSZ(1,J))+GRES))
     .       + 2.D0*DREAL(
     .   M0SZ(1,J)*DCONJG(M0SG(1,J))*(DQSZ(1,J)+DCONJG(DQSG(1,J))+GINT)+
     .   M0SZ(1,J)*DCONJG(M0TG(1,J))*(DQSZ(1,J)+DCONJG(DQTG(1,J))+GINT)+
     .   M0SZ(1,J)*DCONJG(M0TZ(1,J))*(DQSZ(1,J)+DCONJG(DQTZ(1,J))+GINT))
     .            + DREAL(
     .   M0SG(1,J)*DCONJG(M0SG(1,J))*(DQSG(1,J)+DCONJG(DQSG(1,J))+GNR)+
     .   M0SG(1,J)*DCONJG(M0TG(1,J))*(DQSG(1,J)+DCONJG(DQTG(1,J))+GNR)+
     .   M0SG(1,J)*DCONJG(M0TZ(1,J))*(DQSG(1,J)+DCONJG(DQTZ(1,J))+GNR)+
     .   M0TG(1,J)*DCONJG(M0SG(1,J))*(DQTG(1,J)+DCONJG(DQSG(1,J))+GNR)+
     .   M0TG(1,J)*DCONJG(M0TG(1,J))*(DQTG(1,J)+DCONJG(DQTG(1,J))+GNR)+
     .   M0TG(1,J)*DCONJG(M0TZ(1,J))*(DQTG(1,J)+DCONJG(DQTZ(1,J))+GNR)+
     .   M0TZ(1,J)*DCONJG(M0SG(1,J))*(DQTZ(1,J)+DCONJG(DQSG(1,J))+GNR)+
     .   M0TZ(1,J)*DCONJG(M0TG(1,J))*(DQTZ(1,J)+DCONJG(DQTG(1,J))+GNR)+
     .   M0TZ(1,J)*DCONJG(M0TZ(1,J))*(DQTZ(1,J)+DCONJG(DQTZ(1,J))+GNR))
C
         DSIGQ(2,J)=
     .              DREAL(
     .   M0SZ(2,J)*DCONJG(M0SZ(2,J))*(DQSZ(2,J)+DCONJG(DQSZ(2,J))+GRES))
     .       + 2.D0*DREAL(
     .   M0SZ(2,J)*DCONJG(M0SG(2,J))*(DQSZ(2,J)+DCONJG(DQSG(2,J))+GINT))
     .            + DREAL(
     .   M0SG(2,J)*DCONJG(M0SG(2,J))*(DQSG(2,J)+DCONJG(DQSG(2,J))+GNR))
C
         DSIGQ(3,J)=
     .              DREAL(
     .   M0TG(2,J)*DCONJG(M0TG(2,J))*(DQTG(2,J)+DCONJG(DQTG(2,J))+GNR)+
     .   M0TG(2,J)*DCONJG(M0TZ(2,J))*(DQTG(2,J)+DCONJG(DQTZ(2,J))+GNR)+
     .   M0TZ(2,J)*DCONJG(M0TG(2,J))*(DQTZ(2,J)+DCONJG(DQTG(2,J))+GNR)+
     .   M0TZ(2,J)*DCONJG(M0TZ(2,J))*(DQTZ(2,J)+DCONJG(DQTZ(2,J))+GNR))
   70 CONTINUE
C
      DSIGQU=0.D0
      DO 130 I=1,3
      DO 130 J=1,2
         DSIGQU=DSIGQU+DSIGQ(I,J)
  130 CONTINUE
      DSIGQU=CST*DSIGQU/4.D0
C
      DSIGQL=0.D0
      DO 140 J=1,2
         L=2*J-3
         DSIGQL=DSIGQL+L*DSIGQ(1,J)
  140 CONTINUE
      DSIGQL=-CST*DSIGQL/4.D0
C
      DSIGQD=0.D0
      DO 150 J=1,2
         DSIGQD=DSIGQD+DSIGQ(3,J)
  150 CONTINUE
      DSIGQD=CST*DSIGQD/2.D0
C
      DSIGQP=DSIGQU*(1.D0-PP*PM)+(PP-PM)*DSIGQL+PP*PM*DSIGQD
C
C END OF THE QED CORRECTIONS
C
      DO 80 I=1,2
      DO 80 J=1,2
         DWSGS(I,J)=(0.D0,0.D0)
         DWTGS(I,J)=(0.D0,0.D0)
   80 CONTINUE
      PIGZS=PIGZ(S)
      PIGZT=PIGZ(T)
      IF (INEW.EQ.0) THEN
          PIZS=(S-MM)/(S-MZSQ+ZS)-1.D0
          PIZT=(T-MZSQ)/(T-MZSQ+RZT)-1.D0
      ENDIF
      DWSZS(1,1)=2.D0/GZ(1)*PIGZS
      DWSZS(1,2)=2.D0/GZ(2)*PIGZS
      DWSZS(2,1)=(1.D0/GZ(1)+1.D0/GZ(2))*PIGZS
      IF (INEW.EQ.0) THEN
          DWSZS(1,1)=DWSZS(1,1)+PIZS
          DWSZS(1,2)=DWSZS(1,2)+PIZS
          DWSZS(2,1)=DWSZS(2,1)+PIZS
      ENDIF
      DWSZS(2,2)=DWSZS(2,1)
      DWTZS(1,1)=2.D0/GZ(1)*PIGZT
      DWTZS(1,2)=2.D0/GZ(2)*PIGZT
      DWTZS(2,1)=(1.D0/GZ(1)+1.D0/GZ(2))*PIGZT
      IF (INEW.EQ.0) THEN
          DWTZS(1,1)=DWTZS(1,1)+PIZT
          DWTZS(1,2)=DWTZS(1,2)+PIZT
          DWTZS(2,1)=DWTZS(2,1)+PIZT
      ENDIF
      DWTZS(2,2)=DWTZS(2,1)
C
      DWSGV(1,1)=2.D0*FG(S,1)
      DWSGV(1,2)=2.D0*FG(S,2)
      DWSGV(2,1)=FG(S,1)+FG(S,2)
      DWSGV(2,2)=DWSGV(2,1)
      DWTGV(1,1)=2.D0*FG(T,1)
      DWTGV(1,2)=2.D0*FG(T,2)
      DWTGV(2,1)=FG(T,1)+FG(T,2)
      DWTGV(2,2)=DWTGV(2,1)
      DWSZV(1,1)=2.D0*FZ(S,1)
      DWSZV(1,2)=2.D0*FZ(S,2)
      DWSZV(2,1)=FZ(S,1)+FZ(S,2)
      DWSZV(2,2)=DWSZV(2,1)
      DWTZV(1,1)=2.D0*FZ(T,1)
      DWTZV(1,2)=2.D0*FZ(T,2)
      DWTZV(2,1)=FZ(T,1)+FZ(T,2)
      DWTZV(2,2)=DWTZV(2,1)
C
      IZZSTZ=IZZ(S,T,MZ)
      IZZSUZ=IZZ(S,U,MZ)
      IZZTSZ=IZZ(T,S,MZ)
      IZZTUZ=IZZ(T,U,MZ)
      IZZSTW=IZZ(S,T,MW)
      IZZTSW=IZZ(T,S,MW)
      AZZSTZ=AZZ(S,T,MZ)
      AZZSUZ=AZZ(S,U,MZ)
      AZZTSZ=AZZ(T,S,MZ)
      AZZTUZ=AZZ(T,U,MZ)
      AZZSTW=AZZ(S,T,MW)
      AZZTSW=AZZ(T,S,MW)
C
      DWSGB(1,1)=GZ(1)**4*AL/2.D0*(IZZSTZ-IZZSUZ+2.D0*AZZSTZ)
     .          +GW(1)**4*AL/2.D0*(IZZSTW+2.D0*AZZSTW)
      DWSGB(1,2)=GZ(2)**4*AL/2.D0*(IZZSTZ-IZZSUZ+2.D0*AZZSTZ)
     .          +GW(2)**4*AL/2.D0*(IZZSTW+2.D0*AZZSTW)
      DWSGB(2,1)=GZ(1)**2*GZ(2)**2*AL/2.D0*(IZZSTZ-IZZSUZ-2.D0*AZZSUZ)
      DWSGB(2,2)=DWSGB(2,1)
      DWTGB(1,1)=GZ(1)**4*AL/2.D0*(IZZTSZ-IZZTUZ+2.D0*AZZTSZ)
     .          +GW(1)**4*AL/2.D0*(IZZTSW+2.D0*AZZTSW)
      DWTGB(1,2)=GZ(2)**4*AL/2.D0*(IZZTSZ-IZZTUZ+2.D0*AZZTSZ)
     .          +GW(2)**4*AL/2.D0*(IZZTSW+2.D0*AZZTSW)
      DWTGB(2,1)=GZ(1)**2*GZ(2)**2*AL/2.D0*(IZZTSZ-IZZTUZ-2.D0*AZZTUZ)
      DWTGB(2,2)=DWTGB(2,1)
      DO 90 I=1,2
      DO 90 J=1,2
         DWSZB(I,J)=(0.D0,0.D0)
         DWTZB(I,J)=(0.D0,0.D0)
   90 CONTINUE
C
      DO 100 I=1,2
      DO 100 J=1,2
         DWSG(I,J)=DWSGS(I,J)+DWSGV(I,J)+DWSGB(I,J)
         DWTG(I,J)=DWTGS(I,J)+DWTGV(I,J)+DWTGB(I,J)
         DWSZ(I,J)=DWSZS(I,J)+DWSZV(I,J)+DWSZB(I,J)
         DWTZ(I,J)=DWTZS(I,J)+DWTZV(I,J)+DWTZB(I,J)
  100 CONTINUE
C
      DO 170 J=1,2
         DSIGW(1,J)=
     .              DREAL(
     .   M0SG(1,J)*DCONJG(M0SG(1,J))*(DWSG(1,J)+DCONJG(DWSG(1,J)))+
     .   M0SG(1,J)*DCONJG(M0TG(1,J))*(DWSG(1,J)+DCONJG(DWTG(1,J)))+
     .   M0SG(1,J)*DCONJG(M0SZ(1,J))*(DWSG(1,J)+DCONJG(DWSZ(1,J)))+
     .   M0SG(1,J)*DCONJG(M0TZ(1,J))*(DWSG(1,J)+DCONJG(DWTZ(1,J)))+
     .   M0TG(1,J)*DCONJG(M0SG(1,J))*(DWTG(1,J)+DCONJG(DWSG(1,J)))+
     .   M0TG(1,J)*DCONJG(M0TG(1,J))*(DWTG(1,J)+DCONJG(DWTG(1,J)))+
     .   M0TG(1,J)*DCONJG(M0SZ(1,J))*(DWTG(1,J)+DCONJG(DWSZ(1,J)))+
     .   M0TG(1,J)*DCONJG(M0TZ(1,J))*(DWTG(1,J)+DCONJG(DWTZ(1,J)))+
     .   M0SZ(1,J)*DCONJG(M0SG(1,J))*(DWSZ(1,J)+DCONJG(DWSG(1,J)))+
     .   M0SZ(1,J)*DCONJG(M0TG(1,J))*(DWSZ(1,J)+DCONJG(DWTG(1,J)))+
     .   M0SZ(1,J)*DCONJG(M0SZ(1,J))*(DWSZ(1,J)+DCONJG(DWSZ(1,J)))+
     .   M0SZ(1,J)*DCONJG(M0TZ(1,J))*(DWSZ(1,J)+DCONJG(DWTZ(1,J)))+
     .   M0TZ(1,J)*DCONJG(M0SG(1,J))*(DWTZ(1,J)+DCONJG(DWSG(1,J)))+
     .   M0TZ(1,J)*DCONJG(M0TG(1,J))*(DWTZ(1,J)+DCONJG(DWTG(1,J)))+
     .   M0TZ(1,J)*DCONJG(M0SZ(1,J))*(DWTZ(1,J)+DCONJG(DWSZ(1,J)))+
     .   M0TZ(1,J)*DCONJG(M0TZ(1,J))*(DWTZ(1,J)+DCONJG(DWTZ(1,J))))
C
         DSIGW(2,J)=
     .              DREAL(
     .   M0SG(2,J)*DCONJG(M0SG(2,J))*(DWSG(2,J)+DCONJG(DWSG(2,J)))+
     .   M0SG(2,J)*DCONJG(M0SZ(2,J))*(DWSG(2,J)+DCONJG(DWSZ(2,J)))+
     .   M0SZ(2,J)*DCONJG(M0SG(2,J))*(DWSZ(2,J)+DCONJG(DWSG(2,J)))+
     .   M0SZ(2,J)*DCONJG(M0SZ(2,J))*(DWSZ(2,J)+DCONJG(DWSZ(2,J))))
C
         DSIGW(3,J)=
     .              DREAL(
     .   M0TG(2,J)*DCONJG(M0TG(2,J))*(DWTG(2,J)+DCONJG(DWTG(2,J)))+
     .   M0TG(2,J)*DCONJG(M0TZ(2,J))*(DWTG(2,J)+DCONJG(DWTZ(2,J)))+
     .   M0TZ(2,J)*DCONJG(M0TG(2,J))*(DWTZ(2,J)+DCONJG(DWTG(2,J)))+
     .   M0TZ(2,J)*DCONJG(M0TZ(2,J))*(DWTZ(2,J)+DCONJG(DWTZ(2,J))))
  170 CONTINUE
C
      DSIGWU=0.D0
      DO 230 I=1,3
      DO 230 J=1,2
         DSIGWU=DSIGWU+DSIGW(I,J)
  230 CONTINUE
      DSIGWU=CST*DSIGWU/4.D0
C
      DSIGWL=0.D0
      DO 240 J=1,2
         L=2*J-3
         DSIGWL=DSIGWL+L*DSIGW(1,J)
  240 CONTINUE
      DSIGWL=-CST*DSIGWL/4.D0
C
      DSIGWD=0.D0
      DO 250 J=1,2
         DSIGWD=DSIGWD+DSIGW(3,J)
  250 CONTINUE
      DSIGWD=CST*DSIGWD/2.D0
C
      DSIGWP=DSIGWU*(1.D0-PP*PM)+(PP-PM)*DSIGWL+PP*PM*DSIGWD
C
C END OF THE WEAK CORRECTIONS
C
      DSIGP=DSIGVP+DSIGQP+DSIGWP
C
      END
C-----------------------------------------------------------------------
      SUBROUTINE INFRA(DEL,S,T,GNR,GINT,GRES)
C INFRARED FACTORS CALCULATION
C CREATED BY RAMON MIQUEL
C
      IMPLICIT REAL*8(A-Z)
      COMPLEX*16 GINT,M2,D1,D2,DEL2,DEL3
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
      AD1=DSQRT(DREAL(D1*DCONJG(D1)))
C
      GNR=4.D0*AL*(BE+BINT)*DEL1
      GINT=GNR+2.D0*AL*(BE+BINT)*CDLOG(D1)
C
      PHI0=DATAN((MZ**2-S)/MZ/GZ)
      PHI= DATAN((MZ**2-S+DEL*S)/MZ/GZ)
C
      GRES=GNR+2.D0*AL*((BE+2.D0*BINT)*DLOG(AD1)+BE*(S-MZ**2)/MZ/GZ
     .                                             *(PHI-PHI0))
      END
C-----------------------------------------------------------------------
      FUNCTION AGG(S,T)
C G-G BOXES CALCULATION
C CREATED BY RAMON MIQUEL
C
      IMPLICIT REAL*8 (A-Z)
      COMPLEX*16 AGG,CPI
      PARAMETER(PI=3.1415926536D0)
C
      CPI=DCMPLX(0.D0,PI)
      IF (S.GE.0.D0.AND.T.LT.0.D0) THEN
          LST=DLOG(-T/S)
          AGG=.5D0*S/(S+T)*(LST+CPI)
     .       -.25D0*S*(S+2.D0*T)/(S+T)**2*(LST**2+2.D0*CPI*LST)
      ENDIF
      IF (S.LT.0.D0.AND.T.GE.0.D0) THEN
          LST=DLOG(-T/S)
          AGG=.5D0*S/(S+T)*(LST-CPI)
     .       -.25D0*S*(S+2.D0*T)/(S+T)**2*(LST**2-2.D0*CPI*LST)
      ENDIF
      IF (S.GE.0.D0.AND.T.GE.0.D0.OR.S.LT.0.D0.AND.T.LT.0.D0) THEN
          LST=DLOG(T/S)
          AGG=.5D0*S/(S+T)*LST
     .       -.25D0*S*(S+2.D0*T)/(S+T)**2*(LST**2+PI**2)
      ENDIF
      END
C-----------------------------------------------------------------------
      FUNCTION AGZ(S,T)
C PART OF THE G-Z BOXES CALCULATION
C CREATED BY RAMON MIQUEL
C
      IMPLICIT REAL*8 (A-Z)
      COMPLEX*16 AGZ,SPENCE,M,KLAM1,KLAM2,A
      COMMON /BOSON/MZ,MW,MH/WIDTH/GZ
C
      XMZ=MZ*MZ
      IF (S.GE.0.D0) THEN
          YMZ=-MZ*GZ
      ELSE
          YMZ=-1.D-3
      ENDIF
      M=DCMPLX(XMZ,YMZ)
      KLAM1=SPENCE(S/M)-SPENCE(-T/M)
     .     +CDLOG(-T/M)*CDLOG((M-S)/(M+T))
      KLAM2=CDLOG(T/(S-M))+M/S*CDLOG((M-S)/M)
      A=(S+2.D0*T+M)/(S+T)*KLAM1+KLAM2
      AGZ=A*(S-M)/(S+T)
      END
C-----------------------------------------------------------------------
      FUNCTION D(S,T)
C PART OF THE G-Z BOXES CALCULATION
C CREATED BY RAMON MIQUEL
C
      IMPLICIT REAL*8 (A-Z)
      COMPLEX*16 D,CPI,M,LTU,SPENCE
      COMMON /BOSON/MZ,MW,MH/WIDTH/GZ
      PI=3.1415926536D0
      U=-S-T
      XM2=MZ*MZ
      YM2=-MZ*GZ
      M=DCMPLX(XM2,YM2)
      CPI=DCMPLX(0.D0,PI)
C
      IF (T/U.GE.0.D0) THEN
          LTU=DLOG(T/U)
      ELSE
          LTU=DLOG(-T/U)-CPI
      ENDIF
C
CC-ERROR      D=2.D0*SPENCE((M+T)/T)-2.D0*SPENCE((M+U)/U) -
      D=SPENCE((M+T)/T)-SPENCE((M+U)/U)-
     &  (CDLOG((M-S)/(-S))+CDLOG((M-S)/M))*LTU
      END
C-----------------------------------------------------------------------
      FUNCTION PIGZ(S)
C G-Z MIXING CALCULATION
C CREATED BY RAMON MIQUEL
C
      IMPLICIT REAL*8 (A-Z)
      COMPLEX*16 PIGZ
C
      IF (S.GE.0.D0) THEN
          PIGZ=DCMPLX(RESGZ(S),IMSGZ(S))/(-S)
      ELSE
          PIGZ=RESGZ(S)/(-S)
      ENDIF
      END
C-----------------------------------------------------------------------
      FUNCTION FG(S,J)
C PART OF THE WEAK VERTEX CORRECTIONS CALCULATION
C CREATED BY RAMON MIQUEL
C
      IMPLICIT REAL*8 (A-Z)
      INTEGER*4 J
      COMPLEX*16 FG,LAM2,LAM3
      COMMON /BOSON/MZ,MW,MH
     .       /ALF/AL,ALPHA,ALFA
     .       /COUP/SWSQ,CWSQ,V,A,VU,AU,VD,AD
      COMMON /KK/GG(2),GZ(2)
C
      FG=GZ(J)**2*LAM2(S,MZ)
      IF (J.EQ.1) FG = FG + 1.5D0/SWSQ*LAM3(S,MW)
      FG=FG*AL/4.D0
      END
C-----------------------------------------------------------------------
      FUNCTION FZ(S,J)
C PART OF THE WEAK VERTEX CORRECTIONS CALCULATION
C CREATED BY RAMON MIQUEL
C
      IMPLICIT REAL*8 (A-Z)
      INTEGER*4 J
      COMPLEX*16 FZ,LAM2,LAM3
      COMMON /BOSON/MZ,MW,MH
     .       /ALF/AL,ALPHA,ALFA
     .       /COUP/SWSQ,CWSQ,V,A,VU,AU,VD,AD
      COMMON /KK/GG(2),GZ(2)
C
      FZ=GZ(J)**2*LAM2(S,MZ)
      IF (J.EQ.1) FZ = FZ + 0.5D0/(SWSQ*(2.D0*SWSQ-1.D0))*LAM2(S,MW)
     .                - 3.D0*CWSQ/(SWSQ*(2.D0*SWSQ-1.D0))*LAM3(S,MW)
      FZ=FZ*AL/4.D0
      END
C-----------------------------------------------------------------------
      FUNCTION IZZ(S,T,M1)
C PART OF THE HEAVY BOXES CORRECTIONS
C CREATED BY RAMON MIQUEL
C
      IMPLICIT REAL*8 (A-Z)
      COMPLEX*16 IZZ,SPENCE,X1,X2,Y1,Y2,LN2,SP4,LN,SQX,SQY,Z1,Z2,Z3,Z4,
     .           XM2
      PARAMETER(EPS=1.D-4)
C
      XM2=DCMPLX(M1*M1,-EPS)
      SQY=CDSQRT(1.D0-4.D0*XM2/S)
      SQX=CDSQRT(1.D0-4.D0*XM2/S*(1.D0+XM2/T))
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
      SP4=SP4/(X1-X2)
      IZZ=2.D0*LN**2+2.D0*SP4
      END
C-----------------------------------------------------------------------
      FUNCTION AZZ(S,T,M1)
C PART OF THE HEAVY BOXES CORRECTIONS
C CREATED BY RAMON MIQUEL
C
      IMPLICIT REAL*8 (A-Z)
      COMPLEX*16 AZZ,SPENCE,X1,X2,Y1,Y2,LN2,SP4,P1,P2,K1,
     1           LN,SQX,SQY,Z1,Z2,Z3,Z4,CPI,LTM,XM2
      PARAMETER(PI=3.1415926536D0,EPS=1.D-4)
C
      XM2=DCMPLX(M1*M1,-EPS)
      SQY=CDSQRT(1.D0-4.D0*XM2/S)
      SQX=CDSQRT(1.D0-4.D0*XM2/S*(1.D0+XM2/T))
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
      SP4=SP4/(X1-X2)
      K1=SPENCE(1.D0+T/XM2)-LN**2-PI**2/6.
      P1=(2.D0*T+S+2.D0*XM2)/(S+T)/2.D0
      P2=(S+2.D0*T-4.D0*T*XM2/S+2.D0*XM2**2/T-2.D0*XM2**2/S)/(S+T)/2.D0
      LTM=CDLOG(-T/XM2)
      AZZ=S/(S+T)*(P1*K1+.5D0*LTM+(Y2-Y1)/2.D0*LN-P2*SP4)
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
CC-RM IF YOU WANT UNWEIGHTED EVENTS, YOU HAVE TO PUT IREJEC=1
C     AND TO SPECIFY THE MAXIMUM WEIGHT (WMAX)
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
      COMMON / INPOUT / IOUT
      COMMON / UNICOM / IIN,IUT
      COMMON / FINCOM / XMW,S2W
      COMMON / WDISCO / WEIDIS(6,21)
CC-RM
      COMMON / POL    / POLP,POLM
      COMMON / QCD    / AS
      COMMON / NEWOLD / INEW
CC-RM
C
      WRITE(IOUT,901)
  901 FORMAT(' ',50('-')/,' WELCOME TO BHABHA SCATTERING!'/,' ',50('-'))
C
C SIGNAL FOR START
      CALL OUTCRY('SETBAB')
C
C REPRODUCE THE INPUT PARAMETERS
CC-RM      WRITE(IUT,1) E,XMZ,XMH,XMT,THMIN,THMAX,XKMAX
      WRITE(IOUT,1) E,XMZ,XMH,XMT,AS,POLP,POLM,THMIN,THMAX,XKMAX
    1 FORMAT(
     .' YOU HAVE SUPPLIED THE FOLLOWING PARAMETERS :'/,
     .' BEAM ENERGY                     =',F10.4,' GEV'/,
     .' MASS OF THE Z0 BOSON            =',F10.4,' GEV'/,
     .' MASS OF THE HIGGS BOSON         =',F10.4,' GEV'/,
     .' MASS OF THE TOP QUARK           =',F10.4,' GEV'/,
CC-RM
     .' ALPHA STRONG                    =',F10.4,/,
     .' E+ LONG. POLARIZATION DEGREE    =',F10.4,/,
     .' E- LONG. POLARIZATION DEGREE    =',F10.4,/,
CC-RM
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
      XK0=.01D0
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
CC-RM      PRIORI(1)=1.
      PRIORI(1)=(1.D0-POLP*POLM)
CC-RM      PRIORI(2)=1.
      PRIORI(2)=(1.D0-POLP*POLM)
CC-RM      PRIORI(3)=1.
      PRIORI(3)=(1.D0-POLP*POLM)
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
      WRITE(IOUT,5) (I,SIGMA(I),PRIORI(I),DEEL(I),CUMUL(I),I=1,5)
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
      WRITE(IOUT,9)
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
      COMMON / INPOUT / IOUT
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
CC-RM   . CALL PRNVEC(QP,QM,QK,APPR1,APPR2,APPR3,APPR4,WMASS,EXACT,ICON)
     .CALL PRNVEC(QP,QM,QK,APPR1,APPR2,APPR3,APPR4,WMASS,EXACT,WEV,ICON)
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
      IF(WRP.GT.1.D0) WRITE(IOUT,106) WEV,WMAX
  106 FORMAT(' GENBAB : WARNING ! AN EVENT OCCURS WITH WEIGHT',
     .       G10.3/,
     .       ' GENBAB :           WHICH IS MORE THAN THE ESTIMATED',
     .       ' MAXIMUM ',G10.3)
C GB  IF(WRP.LT.RN(2.)) GOTO 101
      IF(WRP.LT.RNDM(2.)) GOTO 101
      WEV=1.D0
CC-RM IF YOU WANT UNWEIGHTED EVENTS, YOU CAN WRITE THE 4-MOMENTA HERE
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
      COMMON / INPOUT / IOUT
      COMMON / UNICOM / IIN,IUT
      COMMON / WDISCO / WEIDIS(6,21)
      DATA KSTR/'0.0','0.1','0.2','0.3','0.4','0.5','0.6',
     .          '0.7','0.8','0.9','1.0','1.1','1.2','1.3',
     .          '1.4','1.5','1.6','1.7','1.8','1.9','2.0','   '/
C
      CALL OUTCRY('ENDBAB')
C
      WRITE(IOUT,201) WALL(1),
     . (KSTR(K),KSTR(K+1),(WEIDIS(L,K),L=1,6),K=1,21)
  201 FORMAT(' ',50('-')/,' NUMBER OF EVENTS GENERATED SO FAR:',F10.1/,
     . ' DISTRIBUTION OF THE EVENT WEIGHTS IN WEIGHT INTERVALS:'/,
     . ' INTERVAL                    SUBGENERATORS'/,
     . ' FROM-TO         1',11X,'2',11X,'3',11X,'4',11X,'5',11X,'ALL'/,
     . (' ',A3,'-',A3,' ',6D12.4))
C
      WRITE(IOUT,202)
  202 FORMAT('0STATISTICS OF THE EVENT WEIGHTS :'/,
     .' CONTR.NO   SUM(W**0)  SUM(W**1) SUM(W**2)   MEAN',
     .'    ERROR      MAX.W.    EFFIC.')
      DO 205 I=1,5
      IF(WCON(1,I).EQ.0.D0) THEN
      WRITE(IOUT,203) I
  203 FORMAT(I7,
     .       '         0          0         0         --',
     .'     --          --        --')
      GOTO 205
      ENDIF
      WMEAN(I)=WCON(2,I)/WCON(1,I)
      WERRO(I)=DSQRT(WCON(3,I)-WCON(2,I)**2/WCON(1,I))/WCON(1,I)
      IF(WMAXI(I).NE.0.D0) WEFFI(I)=WMEAN(I)/WMAXI(I)
      WRITE(IOUT,204) I,(WCON(J,I),J=1,3),WMEAN(I),WERRO(I)
     .  ,WMAXI(I),WEFFI(I)
  204 FORMAT(I7,G14.4,2G11.4,4G10.3)
  205 CONTINUE
      WMEANT=WALL(2)/WALL(1)
      WERROT=DSQRT(WALL(3)-WALL(2)**2/WALL(1))/WALL(1)
      WEFFT=WMEANT/WMAXT
      WRITE(IOUT,206) (WALL(K),K=1,3),WMEANT,WERROT,WMAXT,WEFFT
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
      WRITE(IOUT,207) SIGTOT,ERRTOT
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
      COMMON / INPOUT / IOUT
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
      WRITE(IOUT,1) EB,XMZ,XGZ,GV,GA,THMIN,THMAX
    1 FORMAT(' BORN   : ',4D15.6)
      WRITE(IOUT,2) CROSS
CC-RM    2 FORMAT(' BORN   : THE LOWEST-ORDER CROSS SECTION IS'/,
    2 FORMAT(' BORN   : THE LOWEST-ORDER CROSS SECTION WITHOUT ',
     .                  'POLARIZATION IS'/,
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
      COMMON / INPOUT / IOUT
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
      WRITE(IOUT,11)
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
      INTEGER I,IIN,IUT,IOUT
      DIMENSION SINW(20)
      COMMON /COUP/AL
      COMMON / TOPCOM / XMT
      COMMON / INPOUT / IOUT
      COMMON / UNICOM / IIN,IUT
      COMMON / FINCOM / MW,SW
      CALL OUTCRY('FINDMW')
      WRITE(IOUT,1) MZ,MT,MH
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
      WRITE(IOUT,2) MZ
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
      WRITE(IOUT,25) I,MW,SW
25    FORMAT(' FINDMW : CONVERGED TO 4 DIGITS AFTER',I3,' STEPS :'/,
     .       ' FINDMW : RESULT FOR THE W MASS =',F10.4,' GEV'/,
     .       ' FINDMW : AND FOR SIN**2(TH_W)  =',F10.4/,' ',50('-'))
      RETURN
101   WRITE(IOUT,26)
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
C     FUNCTION PIG(S)
C     IMPLICIT REAL*8(A-Z)
C     COMPLEX*16 PIG,CPI,IPIL,IPIH,IPIT,PII
C     COMMON /LEPT/ME,MMU,MTAU/HAD/MU,MD,MS,MC,MB,MT
C    1       /ALF/AL,ALPHA,ALFA
C    2       /BOSON/MZ,MW,MH
C     PI=3.1415926536D0
C     CPI=DCMPLX(0.D0,PI)
C     QU=4.D0/3.D0
C     QD=1.D0/3.D0
C  SQUARE OF QUARK CHARGES INCLUDING COLOUR FAKTOR 3
CC-RM      X=DABS(S)
CC-RM      W=DSQRT(X)
CC-RM      L1=   DLOG(W/ME)*2.D0
C     L1= -(1.D0+2.D0*ME**2/S)  *F(S,ME,ME)+2.D0
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
      FUNCTION RESZ(X)
C   REAL PART OF THE Z SELF ENERGY
      IMPLICIT REAL*8(A-Z)
      INTEGER I,J,L
      DIMENSION M(6,2),V(6,2),A(6,2),VF(6,2),MF(6,2),T(25)
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
      FUNCTION IMSZ(S)
C  IMAGINARY PART OF THE Z SELF ENERGY (S>0)
C  CREATED BY RAMON MIQUEL
C
      IMPLICIT REAL*8(A-Z)
      INTEGER I,L,INEW,IOUT
      COMMON /BOSON/MZ,M0,MH/FERMI/MF,VF,M,V,A
      COMMON / NEWOLD / INEW
      COMMON / INPOUT / IOUT
      DATA INIT/0/
C
      IF (INEW.EQ.0) THEN
          IMSZ=IIMSZ(S)
      ELSE
          IF (INIT.EQ.0) THEN
              INIT=1
              MZ2=MZ*MZ
              IF (S.NE.MZ2) THEN
                  WRITE(IOUT,*)
     .           'WARNING : LACK OF INITIALIZATION IN IMSZ !!!'
                  STOP
              ENDIF
              IMSZMZ=IIMSZ(MZ2)
              CALL ZWIDTH(GAM0,GAM,GAMMA)
              IMSZ=MZ*GAMMA
          ELSE
              IMSZ=IIMSZ(S)+S/MZ2*(MZ*GAM-IMSZMZ)
          ENDIF
      ENDIF
      END
C----------------------------------------------------------------------
      SUBROUTINE ZWIDTH(GAM0,GAM,GAMMA)
C!
C!   CREATED BY RAMON MIQUEL          18-APR-1988
C!
C!   FORMULAE TAKEN FROM BEENAKKER AND HOLLIK, DESY 88-007
C!
C!   PURPOSE   : THIS ROUTINE COMPUTES THE Z0 WIDTH WITH ONE LOOP
C!               ELECTROWEAK PLUS QCD CORRECTIONS
C!
C!   INPUTS    : XMZ   = Z0 MASS (GEV)
C!               XMT   = TOP QUARK MASS (GEV)
C!                       WARNING: THE Z0 WIDTH IS COMPUTED WITH THE
C!                                NEEDED ACCURACY ONLY IF
C!                                     XMZ/2.D0 < XMT < 150 GEV
C!                                (THIS RESTRICTION WILL DISAPPEAR IN
C!                                FORTHCOMING VERSIONS OF THE PROGRAM)
C!               XMH   = HIGGS BOSON MASS (GEV)
C!                AS   = ALPHA_S, THE STRONG COUPLING CONSTANT
C!
C!   OUTPUTS   : GAM0  = LOWEST ORDER Z0 WIDTH
C!               GAM   = Z0 WIDTH WITH BOTH ELECTROWEAK AND QCD
C!                       CORRECTIONS (EXCLUDING THE PIZ FACTOR)
C!               GAMMA = Z0 WIDTH WITH BOTH ELECTROWEAK AND QCD
C!                       CORRECTIONS (INCLUDING THE PIZ FACTOR)
C!
C!   CALLS     : FINDMW, SETUPS, PIZ, RESGZ, FV, FA
C!
C----------------------------------------------------------------------
C----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,M,O-Z)
      DIMENSION MF(6,2),VF(6,2),M(6,2),VF2(6,2),AF2(6,2)
      COMMON /BOSON/MZ,MW,MH/LEPT/ME,MMU,MTAU
     .       /HAD/MU,MD,MS,MC,MB,MT
     .       /COUP/SW,CW,V,A,VU,AU,VD,AD
     .       /WIDTH/GZ
     .       /ALF/AL,ALPHA,ALFA
     .       /FERMI/MF,VF,M,VF2,AF2
     .       /CONV/CST
      COMMON /QCD/AS
      COMMON / FINCOM / XMW,SW2
      COMMON / INPOUT / IOUT
      PARAMETER(PI=3.141592654D0)
      DATA EPS/1.D-4/
C
      MZ2    = MZ*MZ
      CALL     PIZ(MZ2,EPS,PIZMZ)
      PIGZ   = RESGZ(MZ2)/MZ2
C
      VN     = -A
      AN     = -A
      MUN    = 0.D0
      MUE    = (ME/MZ)**2
      MUMU   = (MMU/MZ)**2
      MUTAU  = (MTAU/MZ)**2
      MUU    = (MU/MZ)**2
      MUD    = (MD/MZ)**2
      MUC    = (MC/MZ)**2
      MUS    = (MS/MZ)**2
      MUT    = (MT/MZ)**2
      MUB    = (MB/MZ)**2
C
C LOWEST ORDER PARTIAL WIDTHS
C
      GAM0N  = 3.D0*ALFA/3.D0*MZ*DSQRT(1.D0-4.D0*MUN)*
     .         (VN**2*(1.D0+2.D0*MUN)+AN**2*(1.D0-4.D0*MUN))
      GAM0E  =      ALFA/3.D0*MZ*DSQRT(1.D0-4.D0*MUE)*
     .         (V**2*(1.D0+2.D0*MUE)+A**2*(1.D0-4.D0*MUE))
C GB  GAM0M  =      ALFA/3.D0*MZ*DSQRT(1.D0-4.D0*MUM)*
C GB .         (V**2*(1.D0+2.D0*MUM)+A**2*(1.D0-4.D0*MUM))
      GAM0M  =      ALFA/3.D0*MZ*DSQRT(1.D0-4.D0*MUMU)*
     .         (V**2*(1.D0+2.D0*MUMU)+A**2*(1.D0-4.D0*MUMU))
      GAM0TA =      ALFA/3.D0*MZ*DSQRT(1.D0-4.D0*MUTAU)*
     .         (V**2*(1.D0+2.D0*MUTAU)+A**2*(1.D0-4.D0*MUTAU))
      GAM0U  = 3.D0*ALFA/3.D0*MZ*DSQRT(1.D0-4.D0*MUU)*
     .         (VU**2*(1.D0+2.D0*MUU)+AU**2*(1.D0-4.D0*MUU))
      GAM0D  = 3.D0*ALFA/3.D0*MZ*DSQRT(1.D0-4.D0*MUD)*
     .         (VD**2*(1.D0+2.D0*MUD)+AD**2*(1.D0-4.D0*MUD))
      GAM0C  = 3.D0*ALFA/3.D0*MZ*DSQRT(1.D0-4.D0*MUC)*
     .         (VU**2*(1.D0+2.D0*MUC)+AU**2*(1.D0-4.D0*MUC))
      GAM0S  = 3.D0*ALFA/3.D0*MZ*DSQRT(1.D0-4.D0*MUS)*
     .         (VD**2*(1.D0+2.D0*MUS)+AD**2*(1.D0-4.D0*MUS))
                        IF (2.D0*MT.LT.MZ) THEN
      GAM0TP = 3.D0*ALFA/3.D0*MZ*DSQRT(1.D0-4.D0*MUT)*
     .         (VU**2*(1.D0+2.D0*MUT)+AU**2*(1.D0-4.D0*MUT))
                        ELSE
      GAM0TP = 0.D0
                        ENDIF
      GAM0B  = 3.D0*ALFA/3.D0*MZ*DSQRT(1.D0-4.D0*MUB)*
     .         (VD**2*(1.D0+2.D0*MUB)+AD**2*(1.D0-4.D0*MUB))
      GAM0   = GAM0N+GAM0E+GAM0M+GAM0TA+GAM0U+GAM0D+GAM0C+GAM0S+GAM0TP+
     .                                                          GAM0B
      WRITE(IOUT,*) 'THE LOWEST ORDER Z0 WIDTH IS  ', GAM0 ,' GEV'
C
C WEAK CORRECTIONS TO THE PARTIAL WIDTHS (MASS EFFECTS NEGLECTED)
C
      DGAMN  = 3.D0*2.D0/3.D0*ALFA*MZ*(VN* FV(VN,AN)+AN*FA(VN,AN))
      DGAME  =      2.D0/3.D0*ALFA*MZ*(V *(FV(V,A)-PIGZ)+A*FA(V,A))
      DGAMU  = 3.D0*2.D0/3.D0*ALFA*MZ*(VU*(FV(VU,AU)+2.D0/3.D0*PIGZ)+
     .                                 AU* FA(VU,AU))
      DGAMD  = 3.D0*2.D0/3.D0*ALFA*MZ*(VD*(FV(VD,AD)-1.D0/3.D0*PIGZ)+
     .                                 AD* FA(VD,AD))
      DGAMB  = DGAMD
      DGAMTP = 0.D0
      TOPCOR = 0.D0
C
C ONE LOOP E.W + Q.C.D. CORRECTED PARTIAL WIDTHS
C
      GAMN   =  GAM0N +DGAMN
      GAME   = (GAM0E +DGAME) *(1.D0+0.75D0*ALFA/PI)
      GAMM   = (GAM0M +DGAME) *(1.D0+0.75D0*ALFA/PI)
      GAMTAU = (GAM0TA+DGAME) *(1.D0+0.75D0*ALFA/PI)
      GAMU   = (GAM0U +DGAMU) *(1.D0+ALFA/PI/3.D0)*(1.D0+AS/PI)
      GAMC   = (GAM0C +DGAMU) *(1.D0+ALFA/PI/3.D0)*(1.D0+AS/PI)
      GAMTOP = (GAM0TP+DGAMTP)*(1.D0+ALFA/PI/3.D0)*(1.D0+TOPCOR)
      GAMD   = (GAM0D +DGAMD) *(1.D0+ALFA/PI/12.D0)*(1.D0+AS/PI)
      GAMS   = (GAM0S +DGAMD) *(1.D0+ALFA/PI/12.D0)*(1.D0+AS/PI)
      GAMB   = (GAM0B +DGAMB) *(1.D0+ALFA/PI/12.D0)*(1.D0+AS/PI)
C
      GAM    = GAMN+GAME+GAMM+GAMTAU+GAMU+GAMD+GAMC+GAMS+GAMTOP+GAMB
      WRITE(IOUT,*) 'THE Z0 WIDTH (WITHOUT PIZ) IS ', GAM  ,' GEV'
      GAMMA  = GAM/(1.D0+PIZMZ)
      WRITE(IOUT,*) 'THE Z0 WIDTH (WITH PIZ) IS    ', GAMMA,' GEV'
      END
C-----------------------------------------------------------------------
      SUBROUTINE PIZ(XMZ2,EPS,PIZMZ)
C
CCCC DERIVATIVE OF THE REAL PART OF THE Z0 SELF ENERGY
C    CREATED BY RAMON MIQUEL
C
      IMPLICIT REAL*8 (A-H,O-Z)
      COMMON / INPOUT / IOUT
C
      S     = XMZ2*(1.D0+EPS)
      PIZMZ = RESZ(S)/EPS/XMZ2
CC      WRITE(IOUT,*) 'PIZ(MZ) = ', PIZMZ, '     WITH EPS = ', EPS
      END
C-----------------------------------------------------------------------
      FUNCTION FV(VF,AF)
C
CCCC VECTOR FORM FACTOR AT THE Z0 PEAK
C    CREATED BY RAMON MIQUEL
C
      IMPLICIT REAL*8 (A-H,M,O-Z)
      REAL*8 L2,L3
      COMMON /BOSON/MZ,MW,MH/LEPT/ME,MMU,MTAU
      COMMON /COUP/SW2,CW2,V,A,VU,AU,VD,AD
     .       /ALF/AL,ALPHA,ALFA
      PARAMETER(PI=3.141592654D0)
C
      MZ2=MZ**2
      SW=DSQRT(SW2)
      CW=DSQRT(CW2)
      T3F=AF*2.D0*SW*CW
      QF=(AF-VF)*CW/SW
      C2=((4.D0*T3F-2.D0*QF)*SW2-2.D0*T3F)/(8.D0*SW**3*CW)
      C3=T3F*1.5D0*CW/SW**3
      FV=ALFA/4.D0/PI*(VF*(VF**2+3.D0*AF**2)*L2(MZ2,MZ)+
     .                      C2*L2(MZ2,MW)+C3*L3(MZ2,MW))
      END
C-----------------------------------------------------------------------
      FUNCTION FA(VF,AF)
C
CCCC AXIAL FORM FACTOR AT THE Z0 PEAK
C    CREATED BY RAMON MIQUEL
C
      IMPLICIT REAL*8 (A-H,M,O-Z)
      REAL*8 L2,L3
      COMMON /BOSON/MZ,MW,MH/LEPT/ME,MMU,MTAU
      COMMON /COUP/SW2,CW2,V,A,VU,AU,VD,AD
     .       /ALF/AL,ALPHA,ALFA
      PARAMETER(PI=3.141592654D0)
C
      MZ2=MZ**2
      SW=DSQRT(SW2)
      CW=DSQRT(CW2)
      T3F=AF*2.D0*SW*CW
      QF=(AF-VF)*CW/SW
      C2=((4.D0*T3F-2.D0*QF)*SW2-2.D0*T3F)/(8.D0*SW**3*CW)
      C3=T3F*1.5D0*CW/SW**3
      FA=ALFA/4.D0/PI*(AF*(AF**2+3.D0*VF**2)*L2(MZ2,MZ)+
     .                      C2*L2(MZ2,MW)+C3*L3(MZ2,MW))
      END
C-----------------------------------------------------------------------
      FUNCTION L2(S,M)
C
C CREATED BY RAMON MIQUEL
C
      REAL*8 L2,S,M,W
      COMPLEX*16 SPENCE,RW
C
      W=M**2/S
      RW=DCMPLX(-1.D0/W,0.D0)
      L2=-3.5D0-2.D0*W-(2.D0*W+3.D0)*DLOG(W)+2.D0*(1.D0+W)**2*
     .   (DLOG(W)*DLOG((1.D0+W)/W)-DREAL(SPENCE(RW)))
      END
C-----------------------------------------------------------------------
      FUNCTION L3(S,M)
C
C CREATED BY RAMON MIQUEL
C
      REAL*8 L3,S,M,W,RW,DRW
C
      W=M**2/S
      RW=DSQRT(4.D0*W-1.D0)
      DRW=DATAN(1.D0/RW)
      L3=5.D0/6.D0-2.D0/3.D0*W+2.D0/3.D0*(2.D0*W+1.D0)*RW*DRW-
     .   8.D0/3.D0*W*(W+2.D0)*DRW**2
      END
C-----------------------------------------------------------------------
CC-RM      FUNCTION IMSZ(X)
      FUNCTION IIMSZ(X)
C  IMAGINARY PART OF THE Z SELF ENERGY (LOWEST ORDER)
      IMPLICIT REAL*8(A-Z)
      INTEGER I,L
      DIMENSION MF(6,2),VF(6,2),M(6,2),V(6,2),A(6,2),T(25)
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
CC-RM      IMSZ=0.D0
      IIMSZ=0.D0
      DO 100 I=1,5,1
CC-RM      IMSZ=IMSZ+T(I)
      IIMSZ=IIMSZ+T(I)
  100 CONTINUE
CC-RM      IMSZ=IMSZ*ALPHA
      IIMSZ=IIMSZ*ALPHA
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
      FUNCTION PIGTAB (MODE,S)
C----------------------------------------------------------------------
C!
C!   CREATED BY RAMON MIQUEL          12-APR-1988
C!
C!   PURPOSE   : TABULATES (MODE=0) AND COMPUTES VIA LINEAR
C!               INTERPOLATION (MODE=1) THE PHOTON VACUUM POLARIZATION
C!               AT Q**2 = S
C----------------------------------------------------------------------
C----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      COMPLEX*16 PIGTAB,PIG
      COMPLEX*16 PXX(201),PYY(201),PZZ(41)
      COMMON / INPOUT / IOUT
      DATA NPOIN0,NPOIN1,NPOIN2 /2*200,40/
      DATA INIT/0/
C
      IF (MODE.EQ.-1) THEN
         INIT=1
C IN A WIDE RANGE (S>0)
         WMIN0= 0.001D0
         WMAX0= 160.001D0
         DO 100 I=0,NPOIN0
            X=DFLOAT(I)/DFLOAT(NPOIN0)
            W =WMIN0+(WMAX0-WMIN0)*X
            SS=W*W
  100    PXX(I+1)=PIG(SS)
C IN A WIDE RANGE (S<0)
         WMIN1= -160.D0
         WMAX1= -0.001D0
         DO 110 I=0,NPOIN1
            X=DFLOAT(I)/DFLOAT(NPOIN1)
            W =WMIN1+(WMAX1-WMIN1)*X
            SS=-W*W
  110    PYY(I+1)=PIG(SS)
C NEAR Q**2 = 0 (S<0)
         WMIN2= -16.D0
         WMAX2= WMAX1
         DO 115 I=0,NPOIN2
            X=DFLOAT(I)/DFLOAT(NPOIN2)
            W =WMIN2+(WMAX2-WMIN2)*X
            SS=-W*W
  115    PZZ(I+1)=PIG(SS)
         PIGTAB=0.D0
      ELSE
         IF (INIT.EQ.0.D0) GOTO 910
         IF (S.GE.0.D0) THEN
C IN A WIDE RANGE (S>0)
             W=DSQRT(S)
             IF (W.LT.WMIN0.OR.W.GE.WMAX0) GOTO 920
             X= (W-WMIN0)/(WMAX0-WMIN0)
             I= INT(NPOIN0*X)+1
             H= X*NPOIN0-DFLOAT(I-1)
             PIGTAB=PXX(I)*(1-H)+PXX(I+1)*H
         ENDIF
         IF (S.LT.0.D0) THEN
             W=-DSQRT(-S)
             IF (W.LT.WMIN1) GOTO 920
             IF (W.GE.WMAX1) THEN
               WRITE(IOUT,*) 'WARNING!!! : W = ',W,' > WMAX1 = ',WMAX1
               W=WMAX1-0.0001
             ENDIF
             IF (W.LT.WMIN2.OR.W.GE.WMAX2) THEN
C IN A WIDE RANGE (S<0)
                 X= (W-WMIN1)/(WMAX1-WMIN1)
                 I= INT(NPOIN1*X)+1
                 H= X*NPOIN1-DFLOAT(I-1)
                 PIGTAB=PYY(I)*(1-H)+PYY(I+1)*H
             ELSE
C NEAR Q**2 = 0 (S<0)
                 X= (W-WMIN2)/(WMAX2-WMIN2)
                 I= INT(NPOIN2*X)+1
                 H= X*NPOIN2-DFLOAT(I-1)
                 PIGTAB=PZZ(I)*(1-H)+PZZ(I+1)*H
             ENDIF
         ENDIF
      ENDIF
      RETURN
  910 WRITE(IOUT,*) '   PIGTAB: LACK OF INITIALISATION IN PIGTAB'
      STOP
  920 WRITE(IOUT,*) '   PIGTAB: S OUT OF PREDEFINED RANGE '
      STOP
      END
      FUNCTION SLFTAB (MODE,S)
C----------------------------------------------------------------------
C!
C!   CREATED BY RAMON MIQUEL          11-APR-1988
C!
C!   PURPOSE   : TABULATES (MODE=0) AND COMPUTES VIA LINEAR
C!               INTERPOLATION (MODE=1) THE Z0 SELF ENERGY AT Q**2 = S
C----------------------------------------------------------------------
C----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      REAL*8 IMSZ
      COMPLEX*16 SLFTAB
      COMPLEX*16 SXX(201),SYY(201),SZZ(41)
      COMMON / INPOUT / IOUT
      COMMON / AMPCOM / E3,  EG1,  EG2,  EG3,
     .                  AM2Z,  AMGZ
      DATA NPOIN0,NPOIN1,NPOIN2 /2*200,40/
      DATA INIT/0/
C
      IF (MODE.EQ.-1) THEN
         INIT=1
C IN A WIDE RANGE (S<0)
         WMIN0= -160.001D0
         WMAX0= -0.001D0
         DO 100 I=0,NPOIN0
            X=DFLOAT(I)/DFLOAT(NPOIN0)
            W =WMIN0+(WMAX0-WMIN0)*X
            SS=-W*W
  100    SXX(I+1)=DCMPLX(RESZ(SS),0.D0)
C IN A WIDE RANGE (S>0)
         WMIN1= 0.001D0
         WMAX1= 160.001D0
         DO 110 I=0,NPOIN1
            X=DFLOAT(I)/DFLOAT(NPOIN1)
            W =WMIN1+(WMAX1-WMIN1)*X
            SS=W*W
  110    SYY(I+1)=DCMPLX(RESZ(SS),IMSZ(SS))
C NEAR Z0 RESONANCE (S>0)
         AMZ=DSQRT(AM2Z)
         GZ=AMGZ/AMZ
         WMIN2= AMZ-2.D0*GZ
         WMAX2= AMZ+2.D0*GZ
         DO 115 I=0,NPOIN2
            X=DFLOAT(I)/DFLOAT(NPOIN2)
            W =WMIN2+(WMAX2-WMIN2)*X
            SS=W*W
  115    SZZ(I+1)=DCMPLX(RESZ(SS),IMSZ(SS))
         SLFTAB=0.D0
      ELSE
         IF (INIT.EQ.0.D0) GOTO 910
         IF (S.LT.0.D0) THEN
C IN A WIDE RANGE (S<0)
             W=-DSQRT(-S)
             IF (W.LT.WMIN0) GOTO 920
             IF (W.GE.WMAX0) THEN
               WRITE(IOUT,*) 'WARNING!!! : W = ',W,' > WMAX0 = ',WMAX0
               W=WMAX0-0.0001
             ENDIF
             X= (W-WMIN0)/(WMAX0-WMIN0)
             I= INT(NPOIN0*X)+1
             H= X*NPOIN0-DFLOAT(I-1)
             SLFTAB=SXX(I)*(1-H)+SXX(I+1)*H
         ENDIF
         IF (S.GE.0.D0) THEN
             W=DSQRT(S)
             IF (W.LT.WMIN1.OR.W.GE.WMAX1) GOTO 920
             IF (W.LT.WMIN2.OR.W.GE.WMAX2) THEN
C IN A WIDE RANGE (S>0)
                 X= (W-WMIN1)/(WMAX1-WMIN1)
                 I= INT(NPOIN1*X)+1
                 H= X*NPOIN1-DFLOAT(I-1)
                 SLFTAB=SYY(I)*(1-H)+SYY(I+1)*H
             ELSE
C NEAR Z0 RESONANCE (S>0)
                 X= (W-WMIN2)/(WMAX2-WMIN2)
                 I= INT(NPOIN2*X)+1
                 H= X*NPOIN2-DFLOAT(I-1)
                 SLFTAB=SZZ(I)*(1-H)+SZZ(I+1)*H
             ENDIF
         ENDIF
      ENDIF
      RETURN
  910 WRITE(IOUT,*) '   SLFTAB: LACK OF INITIALISATION IN SLFTAB'
      STOP
  920 WRITE(IOUT,*) '   SLFTAB: S OUT OF PREDEFINED RANGE '
      STOP
      END
