      SUBROUTINE MASET(AMZ,AMH,AMT)
C======================================================================
C============WE START WITH ROUTINES RENAMING ENTRIES===================
C======================================================================
C
      IMPLICIT REAL*8 (A-H,O-Z)
      CALL DZINI (AMZ,AMH,AMT)
      END
      FUNCTION BORNR (MODE,SVAR,COSTHE,TA,TB)
      IMPLICIT REAL*8 (A-H,O-Z)
      COMMON / BEAMPM / ENE ,AMIN,AMFIN,IDE,IDF
      REAL*8            ENE ,AMIN,AMFIN
      COMMON / KEYSET / KEYGSW,KEYRAD,KEYTAB
C
      BORNR=   BORNDZ(MODE,SVAR,COSTHE,TA,TB)
C
        IF ((ABS(IDF) .GE. 3).AND.(KEYGSW.GT.1)) THEN
C         QCD correction for quarks (not only alpha_s but 
C         note that there is no SVAR dependence !!!
          CORQCD = 1.D0+ALFSPI(4.D0*ENE*ENE)
          BORNR = BORNR*CORQCD
        END IF
      END
      SUBROUTINE PRMROB(ZMASS,GAMZ0,GAMZ,WMASS,GAMW0,GAMW,SIN2W)
      IMPLICIT REAL*8 (A-H,O-Z)
      CALL       DZEWZW(AMW,SW2,GAMZF,GAMWF)
      ZMASS=AMW/SQRT(1D0-SW2)
      GAMZ0=GAMZF
      GAMZ =GAMZF
      WMASS=AMW
      GAMW0=GAMWF
      GAMW =GAMWF
      SIN2W=SW2
      END
       SUBROUTINE DZEWZW (AMW,SW2,GAMZF,GAMWF)
*
      IMPLICIT REAL*8   (A-H,O-Z)
*     REAL*4            AMW,SW2,GAMZF,GAMWF
*
      COMMON/CDZZWG/CAMZ,CAMH,GMU,A0,GAMZ,GAMW,CALSZ,CALST,CALXI,CALQED
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
C
      AMW=DSQRT(AMW2)
      SW2=R1
      GAMZF=GAMZ
      GAMWF=GAMW
      END
      SUBROUTINE  DZOVRI(NPARD,WMASS,ZMASS,TMASS,HMASS,ALQED,ALFAS,
     $                                            ZPARD,PARTZ,PARTW)
C THIS ROUTINE CAN BE USED TO OVERWRITE INPUT FOR THE ELECTROWEAK
C LIBRAY (DEFINED BELOW IN DZINI)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
*
      DIMENSION PARTZ(0:11),PARTW(3)
      DIMENSION NPARD(15),ZPARD(30)
      END
      SUBROUTINE DZINI (XMZ,XMH,XMT)
*     *****************************************
C======================================================================
C============INTEFACE STARTS HERE =====================================
C======================================================================
************************************************************************
* Interface to DIZET of the Dubna-Zeuthen EWRC group in KORALZ         *
* refer to C.P.C 1990,***                                              *
* initialization of the package                                        *
************************************************************************
*
      IMPLICIT REAL*8   (A-H,O-Z)
      COMMON / BEAMPM / ENE ,AMIN,AMFIN,IDE,IDF
      REAL*8            ENE ,AMIN,AMFIN
      COMMON / INOUT / INUT,IOUT
      COMMON/JAKBOX/IBOX
      COMMON / KEYSET / KEYGSW,KEYRAD,KEYTAB
      DIMENSION PARTZ(0:11),PARTW(3)
      DIMENSION NPARD(15),ZPARD(30)

*
      CALL GIVIZO( IDE, 1,AIZOR,QE,KDUMM)
      CALL GIVIZO( IDF, 1,AIZOR,QF,KOLOR)
      TMASS=XMT
      HMASS=XMH
      WMASS=   80D0
      ZMASS=XMZ
      ALFAS=0.125D0
      XKOLOR=KOLOR
*



*
*----------------------------------------------------------------------*
* CHOICE OF HADRONIC VACUUM POLARISATION:                              *
* IHVP :    IHVP=1: HADR. VAC. POLARIZATION OF JEGERLEHNER, REF. 11    *
*      I         2:       OF JEGERLEHNER(1988)                         *
*      I         3:       OF BURKHARDT ET AL., REF. 10                 *
*----------------------------------------------------------------------*
      IFVPOL=3
      NPARD(1) = IFVPOL
*----------------------------------------------------------------------*
* HANDLING OF ALPHA**2 T-MASS TERMS:                                   *
* IAMT4: IAMT4 = 0: NO  MT**4 CORRECTIONS,                             *
*      I       = 1: WITH MT**4 CORRECTIONS RESUMED, SEE REF. 7.        *
*                   IN ORDER TO HAVE COMPLETE BACKWARD COMPATIBILITY,  *
*                   NO COMMON RESUMMATION WITH IQCD.NE.0 TERMS IS DONE *
*      I       = 2: WITH RESUMMATION RECIPE DUE TO BARDIN/KNIEHL,      *
*                   SIMILAR TO THAT OF REF. 12                         *
*      I       = 3: WITH RESUMMATION RECIPE OF REFS. 13-15             *
*----------------------------------------------------------------------*
      IFAMT4=3
      NPARD(2) = IFAMT4
*----------------------------------------------------------------------*
* HANDLING OF HIGHER ORDER (ALPHA*ALPHA.S) T-MASS TERMS:               *
* IQCD :    THE Z-WIDTH HAS FIXED QCD FACTOR (1+ALFAS/PI).             *
*      I    ADDITIONAL OPTIONS ARE FROM REF.8, WITH RUNNING ALPHA.S    *
*      I    IQCD=0: NO QCD CORRS. TO VECTOR BOSON SELF ENERGIES        *
*      I    IN DELTA-R, WIDTHS, CROSS SECTION                          *
*      I         3: APPROXIM. FAST QCD CORRS. (REALISED FOR  Z-WIDTH   *
*      I            AND LEP PROCESSES)                                 *
*      I            IMPORTANT NOTICE: THESE ARE RELIABLE ONLY FOR LEP-I*
*      I         4: EXACT FORMULAE                                     *
*----------------------------------------------------------------------*
      IFQCDC=1
      NPARD(3) = IFQCDC
*----------------------------------------------------------------------*
* CHOICE OF INPUT PARAMETERS BESIDES AMT, AMH, ALPHA.S:                *
* IMOMS: IMOMS = 1: (CONVENTIONAL)    ALPHA, G.MU, AMZ (OUTPUT: AMW)   *
*      I       = 2: INPUT INSTEAD IS: ALPHA, G.MU, AMW (OUTPUT: AMZ)   *
*      I       = 3:                   ALPHA,  AMZ, AMW (OUTPUT: GMU)   *
* WHERE                                                                *
*      I G.MU..... MUON DECAY CONSTANT                                 *
*      I AMT...... T-QUARK MASS                                        *
*      I AMH...... HIGGS BOSON MASS                                    *
*      I ALST..... STRONG COUPLING CONSTANT ALPHA.S (.11)              *
*----------------------------------------------------------------------*

      NPARD(4) = 1
*----------------------------------------------------------------------*
* HANDLING OF HADRONIC VACUUM POLARISATION IN DELTA.R AND RUNNING ALPHA*
* IMASS: IMASS = 0: DEFAULT, USES A FIT TO DATA                        *
*      I       = 1: USES EFFECTIVE QUARK MASSES.OPTION EXISTS FOR TESTS*
*----------------------------------------------------------------------*
      IMASS =0
      NPARD(5) = IMASS
*----------------------------------------------------------------------*
* IALST: IALST = 0: QCDCOR AND QCDCOB WILL BE CALCULATED USING         *
*      I            LAMBDA(QCD)                                        *
*      I       = 1: THEY WILL BE CALCULATED IN TERMS OF ALPHA_STRONG   *
*      I            AS GIVEN BY THE USER (QCDVAR AT IALST=1)           *
*----------------------------------------------------------------------*
      IFALST=1
      NPARD(6) = IFALST
*----------------------------------------------------------------------*
* IQCD3: IQCD3 = 0: NO THIRD ORDER QCD CORRECTION IN QCDCOR AND QCDCOB *
*      I       = 1:  A THIRD ORDER QCD CORRECTION IN QCDCOR AND QCDCOB *
*----------------------------------------------------------------------*
      IFQCD3=1
      NPARD(7) = IFQCD3
*----------------------------------------------------------------------*
* IF IMASK=0: QUARK MASSES ARE USED EVERYWHERE                         *
*         =1: PHYSICAL THRESHOLD ARE USED IN THE PHASE SPACE           *
*----------------------------------------------------------------------*
      IMASK =0
      NPARD(8) = IMASK
*----------------------------------------------------------------------*
* IF IALPH=0: ALMSB4 IS INPUT FOR ALPHAS                               *
*         =1: ALMSB5 IS INPUT FOR ALPHAS                               *
*----------------------------------------------------------------------*
      IFALPH=0
      NPARD(9) = IFALPH
*----------------------------------------------------------------------*
* VERSION 4_6  OF THE PACKAGE INCLUDES R.BARBIERI AND UPDATE OF QCDCOF *
*                                      TO KUENH & CHETYRKIN CORRECTIONS*
*----------------------------------------------------------------------*
      IFBARB=2
      NPARD(10)= IFBARB

*------------------------------------------------------------------------
* THE PROGRAM DIZET IS A WEAK LIBRARY. IT CALCULATES ELECTROWEAK
* RADIATIVE CORRECTIONS IN THE STANDARD THEORY.
* ----------------------------------------------------------------------
* FOR THE CALCULATION OF
*       W-BOSON MASS AND WEAK MIXING ANGLE,
*       Z-BOSON WIDTH,
*       W-BOSON WIDTH,
* --- CALL DIZET(...).
* ----------------------------------------------------------------------
* FOR THE CALCULATION OF
*       WEAK FORM FACTORS
*       FOR 2-FERMION INTO 2-FERMION NEUTRAL CURRENT PROCESSES
*       AND OF RUNNING ALPHA.QED,
* --- CALL ROKANC(...).
* FOR THE CALCULATION OF
*       WEAK FORM FACTORS
*       FOR 2-FERMION INTO 2-FERMION CHARGED CURRENT PROCESSES,
* --- CALL RHOCC(...).
* IN BOTH CASES, AN EARLIER CALL OF DIZET(...) IS NECESSARY.
*------------------------------------------------------------------------
*         SOME RELEVANT REFERENCES:
*-----------------------------------------------------------------------
*     BASICS OF THE ONE-LOOP CALCULATIONS IN THE UNITARY GAUGE, DELTA.R:
*  1. D.BARDIN, P.CHRISTOVA, O.FEDORENKO:    NUCL. PHYS. B175 (1980) 435
*                                            NUCL. PHYS. B197 (1982) 1
* ----------------------------------------------------------------------
*     CALCULATION OF THE Z WIDTH:
*  2. A.AKHUNDOV, D.BARDIN, T.RIEMANN:       NUCL. PHYS. B276 (1986) 1
* ----------------------------------------------------------------------
*     CALCULATION OF THE W WIDTH:
*  3. D.BARDIN, S.RIEMANN, T.RIEMANN:        Z. PHYSIK C32 (1986) 121
* ----------------------------------------------------------------------
*     EWRC FOR FERMION PAIR PRODUCTION IN THE ANNIHILATION CHANNEL:
*  4. D.BARDIN, S.BILENKY, G.MITSELMAKHER,T.RIEMANN, M.SACHWITZ:
*                                            Z. PHYSIK C44 (1989) 493
*     ADDITIONAL TBW-VERTEX CORRECTIONS IN B-QUARK PRODUCTION DUE TO
*     T-MASS: SEE REF. 2.
* ---------------------------------------------------------------------
*     EWRC FOR NC AND CC DEEP INELASTIC EP SCATTERING:
*     D.BARDIN, C.BURDIK, P.CHRISTOVA, T.RIEMANN:
*  5.                                        Z. PHYSIK C42 (1989) 679
*  6.                                        Z. PHYSIK C44 (1989) 149
* ----------------------------------------------------------------------
*     EWRC FOR BHABHA SCATTERING AND HIGHER ORDER (IN ALPHA.QED)
*     T-MASS EFFECTS:
*  7. D.BARDIN, W.HOLLIK, T.RIEMANN:         Z. PHYSIK C49 (1991) 485
* ----------------------------------------------------------------------
*     HIGHER ORDER (IN ALPHA.STRONG) T-MASS EFFECTS:
*  8. D.BARDIN, S.TSCHISHOV:              PROC. SEMINAR "PHYSICS OF E+E-
*                                         INTERACTIONS", DUBNA 1988;
*                                         DUBNA, E2-89-525 (1989)
*  9. SEE ALSO: A.DJOUADI,C.VERZEGNASSI:  PHYS. LETTERS B195 (1987) 265
*               A. DJOUADI:               NUOVO CIM. 100A (1988) 357
* ----------------------------------------------------------------------
*     CALCULATION OF RUNNING ALPHA.QED, SEE:
* 10. H.BURKHARDT, F.JEGERLEHNER, G.PENSO, C.VERZEGNASSI:
*                                         Z. PHYSIK C43 (1989) 497
* 11. F. JEGERLEHNER:                     PSI-PR-91-16 (1991)
*                    TO APPEAR IN: PROGRESS IN PARTICLE AND NUCLEAR
*                    PHYSICS, ED. A. FASSLER, PERGAMON PRESS, OXFORD,U.K
* ----------------------------------------------------------------------
*     COMMON RESUMMATION OF THE HIGHER ORDER TERMS FOLLOWS:
* 12. F.HALZEN, B. KNIEHL:                   NUCL. PHYS. B353 (1991) 567
* ----------------------------------------------------------------------
*     FOR A VARIATION OF HANDLING OF REMAINDER TERMS IN THIS SUMMATION,
*     SEE ALSO REF. 13
* ----------------------------------------------------------------------
*     ANOTHER RECIPE FOR THE RESUMMATION OF HIGHER ORDERS IS DUE TO:
* 13. S.FANCHIOTTI,A.SIRLIN: NYU PREPR.(FEB 1990), IN MEMORIAM M.A.B.BEG
* 14. G.DEGRASSI, S.FANCHIOTTI, A.SIRLIN:    NUCL. PHYS. B351 (1991) 49
* 15. G. DEGRASSI, A.SIRLIN:                 NUCL. PHYS. B352 (1991) 342
* =====================================================================*
*
*
* IF THE CALL WAS 'CALL DIZET(...)':                                   *
*-------------------------------------                                 *
*         FLAGS TO BE SET BY THE USER, EXPLAINED BELOW                 *
*       ------------------------------------------------               *
* NPAR(1) = IHVP                                                       *
* NPAR(2) = IAMT4                                                      *
* NPAR(3) = IQCD                                                       *
* NPAR(4) = IMOMS                                                      *
* NPAR(5) = IMASS                                                      *
* NPAR(6) = ISCRE                                                      *
* NPAR(7) = IALEM                                                      *
* NPAR(8) = IMASK                                                      *
* NPAR(9) = ISCAL                                                     *
* NPAR(10)= IBARB                                                      *
* NPAR(11)= IFTJR                                                      *
* NPAR(12)= IFACR                                                     *
* NPAR(13)= IFACT                                                      *
* NPAR(14)= IHIGS                                                      *
* NPAR(15)= IAFMT                                                      *
* ---------------------------------------------------------------------*
*         INPUT PARAMETERS TO BE SET BY THE USER                       *
*       ------------------------------------------                     *
* AMW  -  W-BOSON MASS (BUT IS BEING CALCULATED FOR NPAR(4)=1)         *
* AMZ  -  Z-BOSON MASS (BUT IS BEING CALCULATED FOR NPAR(4)=2)         *
*    NOTE: DUE TO A POSSIBLE RECALCULATION, THE AMZ, AMW CANNOT BE     *
*         ASSIGNED BY A PARAMETER STATEMENT (INPUT/OUTPUT VARIABLES)   *
* AMT  -  T-QUARK MASS                                                 *
* AMH  -  HIGGS BOSON MASS                                             *
* ALQED - ALPHA_EM(MZ)                                                 *
* ---------------------------------------------------------------------*
*         OUTPUT OF THE DIZET PACKAGE                                  *
*       --------------------------------                               *
* ZPAR(1) = DR                                                         *
* ZPAR(2) = DRREM                                                      *
* ZPAR(3) = SW2                                                        *
* ZPAR(4) = GMUC                                                       *
* ZPAR(5-14) = STORES EFFECTIVE SIN'S FOR ALL PARTIAL Z-DECAY CHANNELS *
* 5- NEUTRINO,  6-ELECTRON,  7-MUON, 8-TAU, 9-UP, 10-DOWN, 11-CHARM,   *
* 12-STRANGE , 13-TOP     , 14-BOTTOM.                                 *
* ZPAR(15)= ALPHST                                                     *
* ZPAR(16-30)= QCDCOR(0-14)                                            *
*                                                                      *
* AMW  -  W-BOSON MASS (BUT IS INPUT IF NPAR(4)=2,3)                   *
* AMZ  -  Z-BOSON MASS (BUT IS INPUT IF NPAR(4)=1,3)                   *
* GMUC -  MUON DECAY CONSTANT (IT IS SET TO GMU IF NPAR(4)=1,2)        *
* GMUC -  MUON DECAY CONSTANT (IT IS CALCULATED IF NPAR(4)=3  )        *
*         IF GMU IS CALCULATED FROM AMZ, AMW, IT DEVIATES FROM THE     *
*         EXPERIMENTAL VALUE!                                          *
* DR   -  DELTA.R, THE LOOP CORRECTION TO THE MUON DECAY CONSTANT G.MU *
* DRREM - THE REMAINDER CONTRIBUTION OF THE ORDER ALPHA CALCULATION    *
*         OF DELTA.R AFTER SEPARATION OF THE RESUMMED TERMS            *
* SW2  -  WEAK MIXING ANGLE DEFINED BY WEAK BOSON MASSES               *
* ALPHST - THE QCD COUPLING CONSTANT AS USED IN THE HADRONIC (QUARK)   *
*         DECAY CHANNELS OF THE GAUGE BOSON WIDTHS.                    *
* QCDCOR(I) - QCD CORRECTION FACTOR FOR QUARK PRODUCTION PROCESSES AND *
*         Z - BOSON I-th PARTIAL WIDTHS INTO QUARKS.                   *
*                                                                      *
* PARTZ(I) - PARTIAL DECAY WIDTHS OF THE Z-BOSON FOR THE CHANNELS:     *
*        I=0: NEUTRINO              I= 7: STRANGE                      *
*        I=1: ELECTRON              I= 8: TOP (NOT PART OF WIDTH)      *
*        I=2: MUON                  I= 9: BOTTOM                       *
*        I=3: TAU                   I=10: ALL HADRONS                  *
*        I=4: UP                    I=11: TOTAL                        *
*        I=5: DOWN                                                     *
*        I=6: CHARM                                                    *
* PARTW(I) - PARTIAL DECAY WIDTHS OF THE W-BOSON FOR THE CHANNELS:     *
*        I=1: ONE OF LEPTONIC              I= 2: ONE OF QUARKONIC      *
*        I=3: TOTAL                                                    *
*======================================================================*
* THE OTHER TWO POSSIBLE CALLS HAVE FLAGS, INPUT AND OUTPUT WHICH ARE  *
* COMMENTED AT THE BEGINNING OF THE SUBROUTINES ROKANC AND RHOCC.      *
*======================================================================*
*                                                                      *
* THE FLAGS INTRODUCED ABOVE HAVE THE FOLLOWING MEANING:               *
*----------------------------------------------------------------------*
* CHOICE OF HADRONIC VACUUM POLARISATION:                              *
* IHVP :    IHVP=1: HADR. VAC. POLARIZATION OF JEGERLEHNER, REF. 11    *
*      I         2:       OF JEGERLEHNER(1988)                         *
*      I         3:       OF BURKHARDT ET AL., REF. 10                 *
*----------------------------------------------------------------------*
* HANDLING OF HIGHER ORDER (ALPHA*ALPHA.S) T-MASS TERMS:               *
* IQCD :    THE Z-WIDTH HAS FIXED QCD FACTOR (1+ALFAS/PI).             *
*      I    ADDITIONAL OPTIONS ARE FROM REF.8, WITH RUNNING ALPHA.S    *
*      I    IQCD=0: NO QCD CORRS. TO VECTOR BOSON SELF ENERGIES        *
*      I    IN DELTA-R, WIDTHS, CROSS SECTION                          *
*      I         3: APPROXIM. FAST QCD CORRS. (REALISED FOR  Z-WIDTH   *
*      I            AND LEP PROCESSES)                                 *
*      I            IMPORTANT NOTICE: THESE ARE RELIABLE ONLY FOR LEP-I*
*      I         4: EXACT FORMULAE                                     *
*----------------------------------------------------------------------*
* HANDLING OF ALPHA**2 T-MASS TERMS:                                   *
* IAMT4: IAMT4 = 0: NO  MT**4 CORRECTIONS,                             *
*      I       = 1: WITH MT**4 CORRECTIONS RESUMED, SEE REF. 7.        *
*                   IN ORDER TO HAVE COMPLETE BACKWARD COMPATIBILITY,  *
*                   NO COMMON RESUMMATION WITH IQCD.NE.0 TERMS IS DONE *
*      I       = 2: WITH RESUMMATION RECIPE DUE TO BARDIN/KNIEHL,      *
*                   SIMILAR TO THAT OF REF. 12                         *
*      I       = 3: WITH RESUMMATION RECIPE OF REFS. 13-15             *
*----------------------------------------------------------------------*
* HANDLING OF HADRONIC VACUUM POLARISATION IN DELTA.R AND RUNNING ALPHA*
* IMASS: IMASS = 0: DEFAULT, USES A FIT TO DATA                        *
*      I       = 1: USES EFFECTIVE QUARK MASSES.OPTION EXISTS FOR TESTS*
*----------------------------------------------------------------------*
* IF IMASK=0: QUARK MASSES ARE USED EVERYWHERE                         *
*         =1: PHYSICAL THRESHOLD ARE USED IN THE PHASE SPACE           *
*----------------------------------------------------------------------*
* IF ISCRE=0: SCALE OF THE REMAINDER TERMS = 1                         *
*         =1: ------------------------------ RENORD                    *
*         =2: ------------------------------ RENORM (not recommended)  *
*----------------------------------------------------------------------*
* IF ISCAL=0: SCALET=1                                                 *
*         =1: SCALET=SCLAVR+SCTPLU     |                               *
*         =2: SCALET=SCLAVR            | Kniehl's                      *
*         =3: SCALET=SCLAVR-SCTMIN     |                               *
*         =4: SCALET=SIRLIN'S 0.204    |                               *
*----------------------------------------------------------------------*
* IF IFACR=0: NON   -EXPANDED DR                                       *
*         =1: PARTLY-EXPANDED DR, RESPECTING DRL*DRR-ORDER             *
*         =2: PARTLY-EXPANDED DR, VIOLATING  DRL*DRR-ORDER       (n.r.)*
*         =3: FULLY -EXPANDED DR, DOUBLE VIOLATING DRL*DRR-ORDER (n.r.)*
*----------------------------------------------------------------------*
* IF IFACT=0: NON   -EXPANDED RHO AND KAPPA    analogs      ff level   *
*         =1: PARTLY-EXPANDED RHO AND KAPPA       of        ff level   *
*         =2: PARTLY-EXPANDED RHO AND KAPPA     those       ff level   *
*         =3: FULLY -EXPANDED RHO AND KAPPA    in IFACR     ff level   *
*         =4: FULLY -NEGLECTED REM^2 TERMS               width level   *
*         =5:       -FAMOUS EW/QCD NON FACTORIZATION     width level   *
*----------------------------------------------------------------------*
* IHIGS: IHIGS = 0: LEADING HIGGS CONTRIBUTION IS NOT RESUMMED         *
*      I       = 1: LEADING HIGGS CONTRIBUTION IS     RESUMMED         *
*----------------------------------------------------------------------*
* IALEM: IALEM = 0: RELEASES ALQED FOR THE FIT, IT MUST BE GIVEN THEN  *
*      I       = 1: ALQED IS CALCULATED FROM A PARAMETRIZATION - IVPOL *
*----------------------------------------------------------------------*
* CHOICE OF INPUT PARAMETERS BESIDES AMT, AMH, ALPHA.S:                *
* IMOMS: IMOMS = 1: (CONVENTIONAL)    ALPHA, G.MU, AMZ (OUTPUT: AMW)   *
*      I       = 2: INPUT INSTEAD IS: ALPHA, G.MU, AMW (OUTPUT: AMZ)   *
*      I       = 3:                   ALPHA,  AMZ, AMW (OUTPUT: GMU)   *
* WHERE                                                                *
*      I G.MU..... MUON DECAY CONSTANT                                 *
*      I AMT...... T-QUARK MASS                                        *
*      I AMH...... HIGGS BOSON MASS                                    *
*      I ALST..... STRONG COUPLING CONSTANT ALPHA.S (.11)              *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* IF IBOX=0, heavy box contribution is neglected                       *
* IF IBOX=1, heavy box contribution is included                        *
*----------------------------------------------------------------------*
      IBOX=0

* Default setting of integer flags
      IHVP =1
      IAMT4=3
      IQCDD=2
      IMOMS=1
      IMASS=0
      ISCRE=0
      IALEM=1
      IMASK=0
      ISCAL=0
      IBARB=2
      IFTJR=1
      IFACR=0
      IFACT=0
      IHIGS=0
      IAFMT=1
*
* Preferrred setting of parameter vector NPAR
      NPARD(1)=IHVP
      NPARD(2)=IAMT4
      NPARD(3)=IQCDD
      NPARD(4)=IMOMS
      NPARD(5)=IMASS
      NPARD(6)=ISCRE
      NPARD(7)=IALEM
      NPARD(8)=IMASK
      NPARD(9)=ISCAL
      NPARD(10)=IBARB
      NPARD(11)=IFTJR
      NPARD(12)=IFACR
      NPARD(13)=IFACT
      NPARD(14)=IHIGS
      NPARD(15)=IAFMT

      ALPHQED=1D0/128.86674175D0

      IF (ENE.GT.60) THEN 
        IBOX=0
        keytab=1
        WRITE(IOUT,*) 'INTERFACE TO ELECTROWEAK LIBRARY:',
     $              ' your center of mass energy is high'  
        WRITE(IOUT,*) 'HEAVY BOXES are set on, '
        WRITE(IOUT,*) 'NOTE THAT above 146 GeV CMS energy,  ', 
     $                'tests of the interface were not done'
      ENDIF
*
      CALL DZOVRI(
     $ NPARD,WMASS,ZMASS,TMASS,HMASS,alphqed,ALFAS,ZPARD,PARTZ,PARTW)
      CALL DIZET (
     $ NPARD,WMASS,ZMASS,TMASS,HMASS,alphqed,ALFAS,ZPARD,PARTZ,PARTW)
      CALL QRKFIX (IDF,ZPARD(20)-1.0,ZPARD(25)-1.0)
      WRITE(IOUT,1000) IBOX,QE,QF,XKOLOR,AMFIN,ZMASS,TMASS,HMASS,ALFAS,
     $                 ALPHQED,ZPARD(20),ZPARD(25)
      WRITE(IOUT,1001) (NPARD(I),I=1,15)
        WRITE(IOUT,*) 'ZPAR-MATRIX: standard output of DIZET:'
        WRITE(IOUT,*) '- . - . - . - . - . - . - . - . - . - .' 
       DO II=1,30 
        WRITE(IOUT,1033) II,ZPARD(II)
        IF(II.EQ.3) WRITE(IOUT,*) '---------' 
        IF(II.EQ.14) WRITE(IOUT,*) ' '
        IF(II.EQ.4) WRITE(IOUT,*) ' '
       ENDDO
C
 1033 FORMAT(1x,'ZPAR(',I2,')=',F12.8)
 1000 FORMAT(/
     +, ' ELEKTROWEAK LIBRARY DIZET (4.9;5.0) BY DUBNA/ZEUTHEN GROUP',/
     +, ' INTERFACE TO THE KORALZ PROGRAM.             ',/
     +, ' LAST UPDATE: OCTOBER 1995.                 ',//
     +, ' START PARAMETERS (MASSES, WIDTHS ARE IN GEV):',//
     +, ' note that DIZET has its own all fermion masses',/
     +, ' these may be different from the final state mass',/
     +, ' defined below:',//
     +, ' heavy box switch: IBOX=',I2,/,/
     +, ' INITIAL CHARGE=',F8.4,/' FINAL CHARGE  =',F8.4,/
     +, ' FINAL COLOR   =',F8.4,/' FINAL MASS    =',F8.4,/
     +, ' Z BOSON MASS  =',F8.4,/' T QUARK MASS  =',F8.4,/
     +, ' HIGGS MASS    =',F8.2,/' ALFA STRONG   =',F8.4,/
     +, ' ALPHA-QED     =',F8.6,/
     +, ' QCD CORR.FACTOR TO Z-WIDTH CHANNELS (NO B) =',F15.10
     +, /
     +, ' QCD CORR.FACTOR TO Z-WIDTH CHANNEL (INTO B)=',F15.10
     +, //)
 1001 FORMAT(/
     +, ' furter flags, see routine DIZET for explanation',/
     +, '  IHVP =',I2,'       IAMT4 =',I2,/
     +, '  IQCD =',I2,'       IMOMS =',I2,/
     +, ' IMASS =',I2,'       ISCRE =',I2,/
     +, ' IALEM =',I2,'       IMASK =',I2,/
     +, ' ISCAL =',I2,'       IBARB =',I2,/
     +, ' IFTJR =',I2,'       IFACR =',I2,/
     +, ' IFACT =',I2,'       IHIGS =',I2,/
     +, ' IAFMT =',I2,'              ',   /
     +, //)
*
*
      END
      SUBROUTINE CZYBOX(IIBOX)
C THIS ROUTINE TRANSFORMS TO THE BORNDZ WHETHER BOXES HAVE TO BE
C CALCULATED (IIBOX=1) OR NOT (IIBOX=0)
      IMPLICIT REAL*8 (A-H,O-Z)
      COMMON/JAKBOX/IBOX
      IIBOX=IBOX
      END
      SUBROUTINE QRKFIX (AMASS,ALFA1,ALFA2)
      IMPLICIT REAL*8 (A-H,O-Z)
C THIS ROUTINE TAKES THE VALUE OF ALPHA_QCD FROM DIZET
      COMMON / BEAMPM / ENE ,AMIN,AMFIN,IDE,IDF
      REAL*8            ENE ,AMIN,AMFIN
      COMMON / IDFC  / IDFF
      COMMON / DZQCDT/  ALFA
C alpha_QCD included in formfacors ?
      IF (ABS(IDFF).EQ.5)  THEN
          ALFA=ALFA1
       ELSE
          ALFA=ALFA2
       ENDIF
      END

      FUNCTION ALFSPI(S)
C THIS FUNCTION TRANSMITS TO KORALZ VALUE OF THE QCD correction factor
C USED IN DZ-LIBRARY.
      IMPLICIT REAL*8 (A-H,O-Z)
      COMMON / DZQCDT/  ALFA
      ALFSPI=ALFA
      END
      FUNCTION BORNDZ(MODE,SVAR,COSTHE,TA,TB)
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
      COMMON / BEAMPM / ENE ,AMIN,AMFIN,IDE,IDF
      REAL*8            ENE ,AMIN,AMFIN
      COMMON / IDFC  / IDFF
      COMMON / GAUSPM /SS,POLN,T3E,QE,T3F,QF
     &                ,XUPGI   ,XUPZI   ,XUPGF   ,XUPZF
     &                ,NDIAG0,NDIAGA,KEYA,KEYZ
     &                ,ITCE,JTCE,ITCF,JTCF,KOLOR
      REAL*8           SS,POLN,T3E,QE,T3F,QF
     &                ,XUPGI(2),XUPZI(2),XUPGF(2),XUPZF(2)
      COMMON / QEDPRM /ALFINV,ALFPI,XK0
      REAL*8           ALFINV,ALFPI,XK0
      COMMON / INSPIN / SEPS1,SEPS2
      REAL*8            SEPS1,SEPS2
C=====================================================================
      COMMON / GSWPRM /SWSQ,AMW,AMZ,AMH,AMTOP,GAMMZ
      REAL*8           SWSQ,AMW,AMZ,AMH,AMTOP,GAMMZ
C     SWSQ        = sin2 (theta Weinberg)
C     AMW,AMZ     = W & Z boson masses respectively
C     AMH         = the Higgs mass
C     AMTOP       = the top mass
C     GAMMZ       = Z0 width
      COMMON / KEYSET / KEYGSW,KEYRAD,KEYTAB
      COMMON /NEWMOD/  AMNEUT,NNEUT
      REAL*8           AMNEUT
      COMPLEX*16 GSW(7)
      COMPLEX*16 ABORN(2,2),APHOT(2,2),AZETT(2,2)
      COMPLEX*16 XUPZFP(2),XUPZIP(2)
      COMPLEX*16 ABORNM(2,2),APHOTM(2,2),AZETTM(2,2)
      COMPLEX*16 PROPA,PROPZ
      COMPLEX*16 XR,XI,PROPW,AW(2,2)
      COMPLEX*16 XUPF,XUPI,XFF(4),XFEM,XFOTA,XRHO,XKE,XKF,XKEF
      COMPLEX*16 XTHING,XVE,XVF,XVEF
      REAL*8 XM2,XP2
      DATA AW/4*(0.D0,0.D0)/,XI/(0.D0,1.D0)/,XR/(1.D0,0.D0)/
      DATA XGW/2.5D0/
      DATA MODE0 /-5/
      DATA SVAR0,COST0 /-5.D0,-6.D0/
      DATA PI /3.141592653589793238462643D0/
C
C MEMORIZATION =========================================================
      IF ( MODE.NE.MODE0.OR.SVAR.NE.SVAR0.OR.COSTHE.NE.COST0) THEN
C ** PROPAGATORS
        MODE0=MODE
        SVAR0=SVAR
        COST0=COSTHE
        SINTHE=SQRT(1.D0-COSTHE**2)
        BETA=SQRT(MAX(0D0,1D0-4D0*AMFIN**2/SVAR))
        CALL CZYBOX(IBOX)
C I MULTIPLY AXIAL COUPLING BY BETA FACTOR.
        XUPZFP(1)=0.5D0*(XUPZF(1)+XUPZF(2))+0.5*BETA*(XUPZF(1)-XUPZF(2))
        XUPZFP(2)=0.5D0*(XUPZF(1)+XUPZF(2))-0.5*BETA*(XUPZF(1)-XUPZF(2))
        XUPZIP(1)=0.5D0*(XUPZI(1)+XUPZI(2))+0.5*(XUPZI(1)-XUPZI(2))
        XUPZIP(2)=0.5D0*(XUPZI(1)+XUPZI(2))-0.5*(XUPZI(1)-XUPZI(2))
C FINAL STATE VECTOR COUPLING
        XUPF     =0.5D0*(XUPZF(1)+XUPZF(2))
        XUPI     =0.5D0*(XUPZI(1)+XUPZI(2))
        XTHING   =0D0
      IF (MODE.GT.0.AND.KEYGSW.GT.1) THEN
C I MULTIPLY AXIAL COUPLING BY BETA FACTOR.
C I ADD ALSO FORMFACTORS
*********************************************************
*
* INITIALISATION OF S-DEPENDENT WEAK FORM FACTORS AND
* PHOTONIC VACUUM POLARISATION (WEAK BOX CONTRIBUTIONS
* LEFT OUT HERE, THEY DEPEND ON ACOS)
*
           IF (KEYTAB.EQ.0) THEN
             SV=SVAR/2D0
             SVT=-SV*(1-COSTHE)
             SVU=-SV*(1+COSTHE)
             IF (ABS(IDFF).EQ.5) THEN
                IBFLA=1
             ELSE
                IBFLA=0
             ENDIF
            CALL ROKANC(IBOX,IBFLA, SVU,-SVAR, SVT,QE,QF,XFF,XFEM,XFOTA)
           ELSEIF (KEYTAB.EQ.1) THEN
             CALL TABLUJ(0,SVAR,costhe,GSW)
             XFF(1)=GSW(1)
             XFF(2)=GSW(2)
             XFF(3)=GSW(3)
             XFF(4)=GSW(4)
C            XFFA  =UNDEFINED !
             XFEM  =GSW(6)
             XFOTA =GSW(7)
           ELSE
             PRINT *, 'STOP IN BORNDZ: UNDEFINED KEYTAB, KEYTAB=',KEYTAB
             STOP
           ENDIF
*
*********************************************************
              XRHO =XFF(1)
              XKE  =XFF(2)
              XKF  =XFF(3)
              XKEF =XFF(4)
              QFM=DABS(QF)
              QEM=DABS(QE)
              XE  =1.D0-4.D0*SWSQ*QEM
              XF  =1.D0-4.D0*SWSQ*QFM
              XEF =-1.D0+XE+XF+16.D0*QEM*QFM*SWSQ*SWSQ
              XVE  =1.D0-4.D0*SWSQ*QEM*XKE
              XVF  =1.D0-4.D0*SWSQ*QFM*XKF
              XVEF =-1.D0+XVE+XVF+16.D0*QEM*QFM*SWSQ*SWSQ*XKEF
C I MULTIPLY AXIAL  COUPLING BY BETA FACTOR.
C I MULTIPLY VECTOR COUPLING BY FORM-FACTOR.
        XUPZFP(1)=0.5D0*(XUPZF(1)+XUPZF(2))*XVF/XF
     &           +0.5*BETA*(XUPZF(1)-XUPZF(2))
        XUPZFP(2)=0.5D0*(XUPZF(1)+XUPZF(2))*XVF/XF
     &           -0.5*BETA*(XUPZF(1)-XUPZF(2))
        XUPZIP(1)=0.5D0*(XUPZI(1)+XUPZI(2))*XVE/XE
     &           +0.5*(XUPZI(1)-XUPZI(2))
        XUPZIP(2)=0.5D0*(XUPZI(1)+XUPZI(2))*XVE/XE
     &           -0.5*(XUPZI(1)-XUPZI(2))
C FINAL STATE VECTOR COUPLING
        XUPF     =0.5D0*(XUPZF(1)+XUPZF(2))*XVF/XF
C DOUBLE VECTOR FORMFACTOR THING
        XTHING=0.25D0*(XUPZF(1)+XUPZF(2))*(XUPZI(1)+XUPZI(2))*
     &         (XVEF/XEF-XVF*XVE/XE/XF)
        PROPA =1D0/SVAR/(2D0-XFEM)
        PROPZ =1D0/DCMPLX(SVAR-AMZ**2,SVAR/AMZ*GAMMZ)
C I REPLACE BORN NORMALIZATION OF Z PROPAGATOR BY THE BETTER ONE
        GMU  = 1.16637D-5
        DEL1 =GMU*AMZ**2*ALFINV/(DSQRT(2.D0)*8.D0*PI)
        DEL0 =1./(SWSQ*(1.-SWSQ))/16.
        PROPZ = PROPZ*DEL1/DEL0*XRHO
      ELSE
        PROPA =1D0/SVAR
        PROPZ =1D0/DCMPLX(SVAR-AMZ**2,SVAR/AMZ*GAMMZ)
        IF (KEYGSW.EQ.0) PROPZ=0.D0
      ENDIF
      IF (IABS(IDF).EQ.1) THEN
C*** NUNUB SPECIAL : W PROPAGATOR IN t-CHANNEL
      DO 15 I=1,2
      DO 15 J=1,2
      AW(I,J)=(0.D0,0.D0)
  15  CONTINUE
        IF(MODE.NE.1) THEN
        XMW=AMZ*DSQRT(1D0-SWSQ)
        XCOUP=1.D0/2.D0/SWSQ
         IF (IDE.LT.0) THEN
           AW(2,1)=- DCMPLX(XCOUP*(1.D0-COSTHE))/XMW/XMW
         ELSE
           AW(1,2)=- DCMPLX(XCOUP*(1.D0-COSTHE))/XMW/XMW
         ENDIF
        ELSE
        XMW=AMZ*DSQRT(1D0-SWSQ)
        XP2=(SVAR*(1.D0+COSTHE)/2.+XMW*XMW)**2+(XMW*XGW)**2
        PROPW=DCMPLX(-(SVAR*(1.D0+COSTHE)/2+XMW*XMW)/XP2)
        PROPW=PROPW-XI*DCMPLX(XMW*XGW/XP2)
        XCOUP=1.D0/2.D0/SWSQ
          IF (IDE.LT.0) THEN
           AW(2,1)= PROPW*DCMPLX(XCOUP*(1.D0-COSTHE))
          ELSE
           AW(1,2)= PROPW*DCMPLX(XCOUP*(1.D0-COSTHE))
          ENDIF
C disputable lines .....
C          IF(KEYGSW.GT.1) THEN
C           AW(1,2)=AW(1,2)*DEL1/DEL0
C           AW(2,1)=AW(2,1)*DEL1/DEL0
C          ENDIF
C end of disputable lines
        ENDIF
      ENDIF
      DO 50 I=1,2
      DO 50 J=1,2
      REGULA= (3-2*I)*(3-2*J) + COSTHE
      REGULM=-(3-2*I)*(3-2*J) * SINTHE *2.D0*AMFIN/SQRT(SVAR)
      APHOT(I,J)=PROPA*(XUPGI(I)*XUPGF(J)*REGULA)
      AZETT(I,J)=PROPZ*(XUPZIP(I)*XUPZFP(J)+XTHING)*REGULA
       ABORN(I,J)=APHOT(I,J)+AZETT(I,J)+AW(I,J)
      APHOTM(I,J)=PROPA*DCMPLX(0D0,1D0)*XUPGI(I)*XUPGF(J)*REGULM
      AZETTM(I,J)=PROPZ*DCMPLX(0D0,1D0)*(XUPZIP(I)*XUPF+XTHING)*REGULM
       ABORNM(I,J)=APHOTM(I,J)+AZETTM(I,J)
   50 CONTINUE
      ENDIF
C
C******************
C* IN CALCULATING CROSS SECTION ONLY DIAGONAL ELEMENTS
C* OF THE SPIN DENSITY MATRICES ENTER (LONGITUD. POL. ONLY.)
C* HELICITY CONSERVATION EXPLICITLY OBEYED
      POLAR1=  (SEPS1)
      POLAR2= (-SEPS2)
      BORN=0D0
      DO 150 I=1,2
      HELIC= 3-2*I
      DO 150 J=1,2
      HELIT=3-2*J
      FACTOR=KOLOR*(1D0+HELIC*POLAR1)*(1D0-HELIC*POLAR2)/4D0
      FACTOM=FACTOR*(1+HELIT*TA)*(1-HELIT*TB)
      FACTOR=FACTOR*(1+HELIT*TA)*(1+HELIT*TB)
      IF(IABS(IDF).NE.1) THEN
      BORN=BORN+CDABS(ABORN(I,J))**2*FACTOR
C MASS TERM IN BORN
       IF (MODE.GE.1) THEN
C mass terms included in BORN. Is it better ?
C--       IF (MODE.GE.5) THEN
       BORN=BORN+CDABS(ABORNM(I,J))**2*FACTOM
      ENDIF
      ELSE
        XM2=CDABS(ABORN(I,J))**2+(NNEUT-1)*CDABS(AZETT(I,J))**2
        XM3=CDABS(ABORNM(I,J))**2+(NNEUT-1)*CDABS(AZETTM(I,J))**2
        BORN=BORN+(XM2+XM3)*FACTOR
      ENDIF
  150 CONTINUE
C************
      FUNT=BORN
      IF(FUNT.LT.0.D0)  FUNT=BORN
C
      IF (SVAR.GT.4D0*AMFIN**2) THEN
C PHASE SPACE THRESHOLD FACTOR
        THRESH=SQRT(1-4D0*AMFIN**2/SVAR)
        BORNDZ= FUNT*SVAR**2*THRESH
      ELSE
        THRESH=0.D0
        BORNDZ=0.D0
      ENDIF
C ZW HERE WAS AN ERROR 19. 05. 1989
      END
      SUBROUTINE CINT
C======================================================================
C============TABULATION OF THE FORMFACTORS=============================
C======================================================================
C ----------------------------------------------------------------------
* THIS IS AN ENTRY OF EASY INITIALISATION OF FORMFACTORS
* CALCULATED IN ROUTINE ROKAP AND TABULATED IN ROUTINE TABLUJ
C
C     called by : KORALZ
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / KEYSET / KEYGSW,KEYRAD,KEYTAB
      COMPLEX*16 GSW(7)
      COMMON / INOUT / INUT,IOUT
*
      IF (KEYTAB.EQ.1.AND.KEYGSW.GT.1)
     $CALL TABLUJ(-1,0D0,0D0,GSW)
      END
      SUBROUTINE TABLUJ(MODE,S,COSTHE,GSW)
C ----------------------------------------------------------------------
* FAST ROUTINE FOR EVALUATION OF ELECTROWEAK FORMFACTORS
* IT PROVIDES FORMFACTORS FOR POSITIVE SS, TABULATED IN
* LOOK UP TABLES, AND THEN CALCULATED BY LINEAR INTERPOLATION.
* PRIOR TO ITS NORMAL USE, IT SHOULD BE CALLED LIKE CALL TABLUJ(-1,0.,..
C
C     CALLED BY : CINT, BORN(DZ)
C ----------------------------------------------------------------------
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON / BEAMPM / ENE ,AMIN,AMFIN,IDE,IDF
      REAL*8            ENE ,AMIN,AMFIN
      COMMON / IDFC  / IDFF
      COMMON / INOUT / INUT,IOUT
      COMPLEX*16 GSW(7)
      COMPLEX*16 CYY(201,7),CZZ(41,7),CTT(201,41,7)
      COMPLEX*16 XFF(4),XFEM,XFOTA 
      DATA NPOIN,NPOIN2,NPOIN3,NPOIN4 /120,20,120,14/
      DATA INIT/0/
      data nev/0/
      DATA WMAX,WMBOX/120.001D0,240.001D0/ 
C
      IF (MODE.EQ.-1) THEN
* INITIALISATION MODE
        CALL CZYBOX(IBOX)
        INIT=INIT+1
        CALL PRMOUT(AMZ,GAMMZ,GAMMZ1,WMASS,GAMMW,GAMMW1,SWSQ)
        CALL GIVIZO( IDE, 1,AIZOR,QE,KDUMM)
        CALL GIVIZO( IDF, 1,AIZOR,QF,KOLOR)
             IF (ABS(IDFF).EQ.5) THEN
                IBFLA=1
             ELSE
                IBFLA=0
             ENDIF
* IN WIDE S RANGE
        WMIN=0.010D0
        WRITE(IOUT,*) 'PRETABULATION, section a:'
C

        DO 110 I=0,NPOIN
        X=DFLOAT(I)/DFLOAT(NPOIN)
        WW =WMIN*(WMAX/WMIN)**X
        SSS=WW*WW
        SV=SSS/2D0
        CALL ROKANC(0,IBFLA,-SV,-SSS,SV,QE,QF,XFF,XFEM,XFOTA)
        DO 51 KK=1,4
   51   CYY(I+1,KK)=XFF(KK)
        CYY(I+1,5 )=123.456
        CYY(I+1,6 )=XFEM
        CYY(I+1,7 )=XFOTA
  110   CONTINUE
* NEAR Z0 RESONANCE 
       WRITE(IOUT,*) 'PRETABULATION,section b:'
        WMIN2=AMZ-2D0*GAMMZ
        WMAX2=AMZ+2D0*GAMMZ
        DO 115 I=0,NPOIN2
        X=DFLOAT(I)/DFLOAT(NPOIN2)
        WW =WMIN2+(WMAX2-WMIN2)*X
        SSS=WW*WW
        CALL ROKANC(0,IBFLA,-SV,-SSS,SV,QE,QF,XFF,XFEM,XFOTA)
        DO 52 KK=1,4
   52   CZZ(I+1,KK)=XFF(KK)
        CZZ(I+1,5 )=123.456
        CZZ(I+1,6 )=XFEM
        CZZ(I+1,7 )=XFOTA
  115   CONTINUE
C
        IF (2*ENE.GT.WMAX) THEN 
* In the region of boxes
        WRITE(IOUT,*) 'INTERFACE TO ELECTROWEAK LIBRARY: CINT'
        WRITE(IOUT,*) 'heavy box energy zone: pretabulation enlarged'
        WRITE(IOUT,*) 'WARNING: initialization will take long time'
        WRITE(IOUT,*) 'lets count ...'
        WMIN3=(WMAX)
        WMAX3=(WMBOX)
        DO  I=0,NPOIN3
        IF(MOD(I,10).EQ.0) WRITE(IOUT,*) 'I=',I,' IMAX=',NPOIN3        
        DO  J=0,NPOIN4
         X=DFLOAT(I)/DFLOAT(NPOIN3)
         WW =WMIN3+(WMAX3-WMIN3)*X
         SSS=WW*WW
         COSI=-1D0+2D0*DFLOAT(J)/DFLOAT(NPOIN4)
         COSI=COSI*(1D0-1D-8)
         IF(J.EQ.     0) COSI=COSI+.3D0/DFLOAT(NPOIN4)
         IF(J.EQ.NPOIN4) COSI=COSI-.3D0/DFLOAT(NPOIN4)
         ST=SSS*(1D0-COSI)/2D0
         SU=SSS*(1D0+COSI)/2D0
         CALL ROKANC(IBOX,IBFLA,-SU,-SSS,-ST,QE,QF,XFF,XFEM,XFOTA)
         DO  KK=1,4
          CTT(I+1,J+1,KK)=XFF(KK)
         ENDDO
         CTT(I+1,J+1,5 )=123.456
         CTT(I+1,J+1,6 )=XFEM
         CTT(I+1,J+1,7 )=XFOTA
C         WRITE(6,*) 'I=',I+1,'j=',j+1,'s=',sss,'costhe=',cosi
C         write(6,*) CTT(I+1,J+1,6 ),CTT(I+1,J+1,7 )
C         write(6,*) CTT(I+1,J+1,1 ),CTT(I+1,J+1,2 )
C         write(6,*) CTT(I+1,J+1,3 ),CTT(I+1,J+1,4 )
        ENDDO
        ENDDO

        ENDIF
       WRITE(IOUT,*) '... PRETABULATIN finished  now !'
C
      ELSE
* OPERATIONAL MODE
        IF(INIT.EQ.0) GOTO 910
        W=(SQRT(S))
        IF(W.GT.WMAX) THEN
* in the region of boxes
          X= (W-WMIN3)/(WMAX3-WMIN3)
          I= INT(NPOIN3*X)+1
          H= X*NPOIN3-DFLOAT(I-1)

          X= (1D0+COSTHE)/2D0
          J= INT(NPOIN4*X)+1
          H1= X*NPOIN4-DFLOAT(J-1)
          DO  KK=1,7
           GSW(KK)=(CTT(I,J  ,KK)*(1-H)+CTT(I+1,J  ,KK)*H)*(1D0-H1)
     $            +(CTT(I,J+1,KK)*(1-H)+CTT(I+1,J+1,KK)*H)*H1
          ENDDO
C         nev=nev+1
C         if (nev.lt.20) then
C          WRITE(6,*) 'I=',I,'j=',j,'s=',s,'costhe=',costhe
C          write(6,*) gsw(6),gsw(7)
C          write(6,*) gsw(1),gsw(2)
C          write(6,*) gsw(3),gsw(4)
C         endif

        ELSEIF(W.LT.WMIN2.OR.W.GT.WMAX2) THEN
* IN A WIDE RANGE
          IF(W.LT.WMIN.OR.W.GT.WMAX) GOTO 920
          X= LOG( W/WMIN)/LOG(WMAX/WMIN)
          I= INT(NPOIN*X)+1
          H= X*NPOIN-DFLOAT(I-1)
          DO 53 KK=1,7
   53     GSW(KK)=CYY(I,KK)*(1-H)+CYY(I+1,KK)*H
        ELSE
* NEAR Z0 RESONANCE
          X= (W-WMIN2)/(WMAX2-WMIN2)
          I= INT(NPOIN2*X)+1
          H= X*NPOIN2-DFLOAT(I-1)
          DO 54 KK=1,7
   54     GSW(KK)=CZZ(I,KK)*(1-H)+CZZ(I+1,KK)*H
        ENDIF
      ENDIF
      RETURN
  910 PRINT *,'   TABLUJ: LACK OF INITIALISATION.'
      STOP
  920 PRINT *,'   TABLUJ: S OUT OF PREDEFINED RANGE '
      STOP
      END
      FUNCTION BORNH(MODE,SVAR,COSTHE,TA,TB)
C======================================================================
C============ROUTINES TO DETACH SECOND ELECTROWEAK LIBRARY=============
C======================================================================
      IMPLICIT REAL*8(A-H,O-Z)
      PRINT *, 'SORRY, SECOND ELECTROWEAK LIBRARY IS NOT INTERFACED'
      BORNH=5.
      STOP
      END
      SUBROUTINE PRMHOL(ZMASS,GAMZ0,GAMMZ,WMASS,GAMW0,GAMW,SIN2W)
      IMPLICIT REAL*8(A-H,O-Z)
      PRINT *, 'SORRY, SECOND ELECTROWEAK LIBRARY IS NOT INTERFACED'
      STOP
      END
      SUBROUTINE HOLSTA(IDF,KEYGSW,YMZ,YMH,YMT)
      IMPLICIT REAL*8(A-H,O-Z)
      PRINT *, 'SORRY, SECOND ELECTROWEAK LIBRARY IS NOT INTERFACED'
      STOP
      END


 
      SUBROUTINE DZERO(A,B,X0,R,EPS,MXF,F)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      LOGICAL MFLAG,RFLAG
      EXTERNAL F
      DATA RFLAG /.FALSE./
CBB   Mflag and LGFILE were not defined
      DATA MFLAG /.FALSE./
      DATA LGFILE /0/
      PARAMETER (ONE = 1, HALF = ONE/2)
 
      XA=MIN(A,B)
      XB=MAX(A,B)
      FA=F(XA,1)
      FB=F(XB,2)
      IF(FA*FB .GT. 0) GO TO 5
      MC=0
 
    1 X0=HALF*(XA+XB)
      R=X0-XA
      EE=EPS*(ABS(X0)+1)
      IF(R .LE. EE) GO TO 4
      F1=FA
      X1=XA
      F2=FB
      X2=XB
 
    2 FX=F(X0,2)
      MC=MC+1
      IF(MC .GT. MXF) GO TO 6
      IF(FX*FA .GT. 0) THEN
       XA=X0
       FA=FX
      ELSE
       XB=X0
       FB=FX
      END IF
 
    3 U1=F1-F2
      U2=X1-X2
      U3=F2-FX
      U4=X2-X0
      IF(U2 .EQ. 0 .OR. U4 .EQ. 0) GO TO 1
      F3=FX
      X3=X0
      U1=U1/U2
      U2=U3/U4
      CA=U1-U2
      CB=(X1+X2)*U2-(X2+X0)*U1
      CC=(X1-X0)*F1-X1*(CA*X1+CB)
      IF(CA .EQ. 0) THEN
       IF(CB .EQ. 0) GO TO 1
       X0=-CC/CB
      ELSE
       U3=CB/(2*CA)
       U4=U3*U3-CC/CA
       IF(U4 .LT. 0) GO TO 1
       X0=-U3+SIGN(SQRT(U4),X0+U3)
      END IF
      IF(X0 .LT. XA .OR. X0 .GT. XB) GO TO 1
 
      R=MIN(ABS(X0-X3),ABS(X0-X2))
      EE=EPS*(ABS(X0)+1)
      IF(R .GT. EE) THEN
       F1=F2
       X1=X2
       F2=F3
       X2=X3
       GO TO 2
      END IF
 
      FX=F(X0,2)
      IF(FX .EQ. 0) GO TO 4
      IF(FX*FA .LT. 0) THEN
       XX=X0-EE
       IF(XX .LE. XA) GO TO 4
       FF=F(XX,2)
       FB=FF
       XB=XX
      ELSE
       XX=X0+EE
       IF(XX .GE. XB) GO TO 4
       FF=F(XX,2)
       FA=FF
       XA=XX
      END IF
      IF(FX*FF .GT. 0) THEN
       MC=MC+2
       IF(MC .GT. MXF) GO TO 6
       F1=F3
       X1=X3
       F2=FX
       X2=X0
       X0=XX
       FX=FF
       GO TO 3
      END IF
 
    4 R=EE
      FF=F(X0,3)
      RETURN
    5 WRITE(6,*) 'C205.1',LGFILE,MFLAG,RFLAG
      IF(MFLAG) THEN
       IF(LGFILE .EQ. 0) WRITE(*,100)
       IF(LGFILE .NE. 0) WRITE(LGFILE,100)
      END IF
      IF(.NOT.RFLAG) STOP
      R=-2*(XB-XA)
      X0=0
      RETURN
    6 WRITE(6,*) 'C205.2',LGFILE,MFLAG,RFLAG
      IF(MFLAG) THEN
       IF(LGFILE .EQ. 0) WRITE(*,101)
       IF(LGFILE .NE. 0) WRITE(LGFILE,101)
      END IF
      IF(.NOT.RFLAG) STOP
      R=-HALF*ABS(XB-XA)
      X0=0
      RETURN
  100 FORMAT(1X,'***** CERN C205 DZERO ... F(A) AND F(B)',
     1          ' HAVE THE SAME SIGN')
  101 FORMAT(1X,'***** CERN C205 DZERO ... TOO MANY FUNCTION CALLS')
      END




C=============================================================
C=============================================================
C==== end of elementary file =================================
C=============================================================
C=============================================================
      SUBROUTINE DIZET(NPAR,AMW,AMZ,AMT,AMH,ALQED,ALSTR,ZPAR,PARTZ,
     $  PARTW)
*=======================================================================
*
* The authors of DIZET are:
*
*                          A. Akhundov,  D. Bardin,  M. Bilenky,
*                          P. Christova, S. Riemann, T. Riemann,
*                          M. Sachwitz,  H. Vogt
*
*
*=======================================================================
*
* VERSION 4.04 OF THE PACKAGE IS TO SOME EXTENT DESCRIBED IN:
* D. BARDIN ET AL.,
* ZFITTER - AN ANALYTICAL PROGRAM FOR FERMION PAIR PRODUCTION IN
* e+e-  ANNIHILATION,
* CERN-TH.6443/92 (March 1992)
*
*------------------------------------------------------------------------
* VERSION 4_6  OF THE PACKAGE INCLUDES R.BARBIERI AND UPDATE OF QCDCOF
*                                      TO KUENH & CHETYRKIN CORRECTIONS.
*------------------------------------------------------------------------
* VERSION 4_61 - THE BUG IN IM_PART OF XFOTF1 FOR VPOL=1 IS FIXED
*------------------------------------------------------------------------
* VERSION 4_7  - MODIFICATIONS IN FRAMEWORK OF JANUARY '1994 WORKSHOP:
*                1) DIFFERENT QCD CORRECTIONS FOR VARIOUS QUARK CHANNELS
*                ARE IMPLEMENTED;
*------------------------------------------------------------------------
* VERSION 4_8  - COMPLETE UPDATE WITHIN LEP-I PRECISION CALCULATIONS WG
*                JANUARY-JULY 1994
*------------------------------------------------------------------------
* VERSION 4_9  - IMPLEMENTATION OR REACTIVATION OF `OPTIONS'
*                JULY-AUGUST 1994
*------------------------------------------------------------------------
* DIZET   VERSION:  4_9
*         AUTHORS:  DUBNA/ZEUTHEN EWRC GROUP
* SUPPORT:
*         BARDINDY @ CERNVM
*         RIEMANN  @ CERNVM
*------------------------------------------------------------------------
* THE PROGRAM DIZET IS A WEAK LIBRARY. IT CALCULATES ELECTROWEAK
* RADIATIVE CORRECTIONS IN THE STANDARD THEORY.
* ----------------------------------------------------------------------
* FOR THE CALCULATION OF
*       W-BOSON MASS AND WEAK MIXING ANGLE,
*       Z-BOSON WIDTH,
*       W-BOSON WIDTH,
* --- CALL DIZET(...).
* ----------------------------------------------------------------------
* FOR THE CALCULATION OF
*       WEAK FORM FACTORS
*       FOR 2-FERMION INTO 2-FERMION NEUTRAL CURRENT PROCESSES
*       AND OF RUNNING ALPHA.QED,
* --- CALL ROKANC(...).
* FOR THE CALCULATION OF
*       WEAK FORM FACTORS
*       FOR 2-FERMION INTO 2-FERMION CHARGED CURRENT PROCESSES,
* --- CALL RHOCC(...).
* IN BOTH CASES, AN EARLIER CALL OF DIZET(...) IS NECESSARY.
*------------------------------------------------------------------------
*         SOME RELEVANT REFERENCES:
*-----------------------------------------------------------------------
*     BASICS OF THE ONE-LOOP CALCULATIONS IN THE UNITARY GAUGE, DELTA.R:
*  1. D.BARDIN, P.CHRISTOVA, O.FEDORENKO:    NUCL. PHYS. B175 (1980) 435
*                                            NUCL. PHYS. B197 (1982) 1
* ----------------------------------------------------------------------
*     CALCULATION OF THE Z WIDTH:
*  2. A.AKHUNDOV, D.BARDIN, T.RIEMANN:       NUCL. PHYS. B276 (1986) 1
* ----------------------------------------------------------------------
*     CALCULATION OF THE W WIDTH:
*  3. D.BARDIN, S.RIEMANN, T.RIEMANN:        Z. PHYSIK C32 (1986) 121
* ----------------------------------------------------------------------
*     EWRC FOR FERMION PAIR PRODUCTION IN THE ANNIHILATION CHANNEL:
*  4. D.BARDIN, S.BILENKY, G.MITSELMAKHER,T.RIEMANN, M.SACHWITZ:
*                                            Z. PHYSIK C44 (1989) 493
*     ADDITIONAL TBW-VERTEX CORRECTIONS IN B-QUARK PRODUCTION DUE TO
*     T-MASS: SEE REF. 2.
* ---------------------------------------------------------------------
*     EWRC FOR NC AND CC DEEP INELASTIC EP SCATTERING:
*     D.BARDIN, C.BURDIK, P.CHRISTOVA, T.RIEMANN:
*  5.                                        Z. PHYSIK C42 (1989) 679
*  6.                                        Z. PHYSIK C44 (1989) 149
* ----------------------------------------------------------------------
*     EWRC FOR BHABHA SCATTERING AND HIGHER ORDER (IN ALPHA.QED)
*     T-MASS EFFECTS:
*  7. D.BARDIN, W.HOLLIK, T.RIEMANN:         Z. PHYSIK C49 (1991) 485
* ----------------------------------------------------------------------
*     HIGHER ORDER (IN ALPHA.STRONG) T-MASS EFFECTS:
*  8. D.BARDIN, S.TSCHISHOV:              PROC. SEMINAR "PHYSICS OF E+E-
*                                         INTERACTIONS", DUBNA 1988;
*                                         DUBNA, E2-89-525 (1989)
*  9. SEE ALSO: A.DJOUADI,C.VERZEGNASSI:  PHYS. LETTERS B195 (1987) 265
*               A. DJOUADI:               NUOVO CIM. 100A (1988) 357
* ----------------------------------------------------------------------
*     CALCULATION OF RUNNING ALPHA.QED, SEE:
* 10. H.BURKHARDT, F.JEGERLEHNER, G.PENSO, C.VERZEGNASSI:
*                                         Z. PHYSIK C43 (1989) 497
* 11. F. JEGERLEHNER:                     PSI-PR-91-16 (1991)
*                    TO APPEAR IN: PROGRESS IN PARTICLE AND NUCLEAR
*                    PHYSICS, ED. A. FASSLER, PERGAMON PRESS, OXFORD,U.K
* ----------------------------------------------------------------------
*     COMMON RESUMMATION OF THE HIGHER ORDER TERMS FOLLOWS:
* 12. F.HALZEN, B. KNIEHL:                   NUCL. PHYS. B353 (1991) 567
* ----------------------------------------------------------------------
*     FOR A VARIATION OF HANDLING OF REMAINDER TERMS IN THIS SUMMATION,
*     SEE ALSO REF. 13
* ----------------------------------------------------------------------
*     ANOTHER RECIPE FOR THE RESUMMATION OF HIGHER ORDERS IS DUE TO:
* 13. S.FANCHIOTTI,A.SIRLIN: NYU PREPR.(FEB 1990), IN MEMORIAM M.A.B.BEG
* 14. G.DEGRASSI, S.FANCHIOTTI, A.SIRLIN:    NUCL. PHYS. B351 (1991) 49
* 15. G. DEGRASSI, A.SIRLIN:                 NUCL. PHYS. B352 (1991) 342
* =====================================================================*
*
*
* IF THE CALL WAS 'CALL DIZET(...)':                                   *
*-------------------------------------                                 *
*         FLAGS TO BE SET BY THE USER, EXPLAINED BELOW                 *
*       ------------------------------------------------               *
* NPAR(1) = IHVP                                                       *
* NPAR(2) = IAMT4                                                      *
* NPAR(3) = IQCD                                                       *
* NPAR(4) = IMOMS                                                      *
* NPAR(5) = IMASS                                                      *
* NPAR(6) = ISCRE                                                      *
* NPAR(7) = IALEM                                                      *
* NPAR(8) = IMASK                                                      *
* NPAR(9) = ISCAL                                                     *
* NPAR(10)= IBARB                                                      *
* NPAR(11)= IFTJR                                                      *
* NPAR(12)= IFACR                                                     *
* NPAR(13)= IFACT                                                      *
* NPAR(14)= IHIGS                                                      *
* NPAR(15)= IAFMT                                                      *
* ---------------------------------------------------------------------*
*         INPUT PARAMETERS TO BE SET BY THE USER                       *
*       ------------------------------------------                     *
* AMW  -  W-BOSON MASS (BUT IS BEING CALCULATED FOR NPAR(4)=1)         *
* AMZ  -  Z-BOSON MASS (BUT IS BEING CALCULATED FOR NPAR(4)=2)         *
*    NOTE: DUE TO A POSSIBLE RECALCULATION, THE AMZ, AMW CANNOT BE     *
*         ASSIGNED BY A PARAMETER STATEMENT (INPUT/OUTPUT VARIABLES)   *
* AMT  -  T-QUARK MASS                                                 *
* AMH  -  HIGGS BOSON MASS                                             *
* ALQED - ALPHA_EM(MZ)                                                 *
* ---------------------------------------------------------------------*
*         OUTPUT OF THE DIZET PACKAGE                                  *
*       --------------------------------                               *
* ZPAR(1) = DR                                                         *
* ZPAR(2) = DRREM                                                      *
* ZPAR(3) = SW2                                                        *
* ZPAR(4) = GMUC                                                       *
* ZPAR(5-14) = STORES EFFECTIVE SIN'S FOR ALL PARTIAL Z-DECAY CHANNELS *
* 5- NEUTRINO,  6-ELECTRON,  7-MUON, 8-TAU, 9-UP, 10-DOWN, 11-CHARM,   *
* 12-STRANGE , 13-TOP     , 14-BOTTOM.                                 *
* ZPAR(15)= ALPHST                                                     *
* ZPAR(16-30)= QCDCOR(0-14)                                            *
*                                                                      *
* AMW  -  W-BOSON MASS (BUT IS INPUT IF NPAR(4)=2,3)                   *
* AMZ  -  Z-BOSON MASS (BUT IS INPUT IF NPAR(4)=1,3)                   *
* GMUC -  MUON DECAY CONSTANT (IT IS SET TO GMU IF NPAR(4)=1,2)        *
* GMUC -  MUON DECAY CONSTANT (IT IS CALCULATED IF NPAR(4)=3  )        *
*         IF GMU IS CALCULATED FROM AMZ, AMW, IT DEVIATES FROM THE     *
*         EXPERIMENTAL VALUE!                                          *
* DR   -  DELTA.R, THE LOOP CORRECTION TO THE MUON DECAY CONSTANT G.MU *
* DRREM - THE REMAINDER CONTRIBUTION OF THE ORDER ALPHA CALCULATION    *
*         OF DELTA.R AFTER SEPARATION OF THE RESUMMED TERMS            *
* SW2  -  WEAK MIXING ANGLE DEFINED BY WEAK BOSON MASSES               *
* ALPHST - THE QCD COUPLING CONSTANT AS USED IN THE HADRONIC (QUARK)   *
*         DECAY CHANNELS OF THE GAUGE BOSON WIDTHS.                    *
* QCDCOR(I) - QCD CORRECTION FACTOR FOR QUARK PRODUCTION PROCESSES AND *
*         Z - BOSON I-th PARTIAL WIDTHS INTO QUARKS.                   *
*                                                                      *
* PARTZ(I) - PARTIAL DECAY WIDTHS OF THE Z-BOSON FOR THE CHANNELS:     *
*        I=0: NEUTRINO              I= 7: STRANGE                      *
*        I=1: ELECTRON              I= 8: TOP (NOT PART OF WIDTH)      *
*        I=2: MUON                  I= 9: BOTTOM                       *
*        I=3: TAU                   I=10: ALL HADRONS                  *
*        I=4: UP                    I=11: TOTAL                        *
*        I=5: DOWN                                                     *
*        I=6: CHARM                                                    *
* PARTW(I) - PARTIAL DECAY WIDTHS OF THE W-BOSON FOR THE CHANNELS:     *
*        I=1: ONE OF LEPTONIC              I= 2: ONE OF QUARKONIC      *
*        I=3: TOTAL                                                    *
*======================================================================*
* THE OTHER TWO POSSIBLE CALLS HAVE FLAGS, INPUT AND OUTPUT WHICH ARE  *
* COMMENTED AT THE BEGINNING OF THE SUBROUTINES ROKANC AND RHOCC.      *
*======================================================================*
*                                                                      *
* THE FLAGS INTRODUCED ABOVE HAVE THE FOLLOWING MEANING:               *
*----------------------------------------------------------------------*
* CHOICE OF HADRONIC VACUUM POLARISATION:                              *
* IHVP :    IHVP=1: HADR. VAC. POLARIZATION OF JEGERLEHNER, REF. 11    *
*      I         2:       OF JEGERLEHNER(1988)                         *
*      I         3:       OF BURKHARDT ET AL., REF. 10                 *
*----------------------------------------------------------------------*
* HANDLING OF HIGHER ORDER (ALPHA*ALPHA.S) T-MASS TERMS:               *
* IQCD :    THE Z-WIDTH HAS FIXED QCD FACTOR (1+ALFAS/PI).             *
*      I    ADDITIONAL OPTIONS ARE FROM REF.8, WITH RUNNING ALPHA.S    *
*      I    IQCD=0: NO QCD CORRS. TO VECTOR BOSON SELF ENERGIES        *
*      I    IN DELTA-R, WIDTHS, CROSS SECTION                          *
*      I         3: APPROXIM. FAST QCD CORRS. (REALISED FOR  Z-WIDTH   *
*      I            AND LEP PROCESSES)                                 *
*      I            IMPORTANT NOTICE: THESE ARE RELIABLE ONLY FOR LEP-I*
*      I         4: EXACT FORMULAE                                     *
*----------------------------------------------------------------------*
* HANDLING OF ALPHA**2 T-MASS TERMS:                                   *
* IAMT4: IAMT4 = 0: NO  MT**4 CORRECTIONS,                             *
*      I       = 1: WITH MT**4 CORRECTIONS RESUMED, SEE REF. 7.        *
*                   IN ORDER TO HAVE COMPLETE BACKWARD COMPATIBILITY,  *
*                   NO COMMON RESUMMATION WITH IQCD.NE.0 TERMS IS DONE *
*      I       = 2: WITH RESUMMATION RECIPE DUE TO BARDIN/KNIEHL,      *
*                   SIMILAR TO THAT OF REF. 12                         *
*      I       = 3: WITH RESUMMATION RECIPE OF REFS. 13-15             *
*----------------------------------------------------------------------*
* HANDLING OF HADRONIC VACUUM POLARISATION IN DELTA.R AND RUNNING ALPHA*
* IMASS: IMASS = 0: DEFAULT, USES A FIT TO DATA                        *
*      I       = 1: USES EFFECTIVE QUARK MASSES.OPTION EXISTS FOR TESTS*
*----------------------------------------------------------------------*
* IF IMASK=0: QUARK MASSES ARE USED EVERYWHERE                         *
*         =1: PHYSICAL THRESHOLD ARE USED IN THE PHASE SPACE           *
*----------------------------------------------------------------------*
* IF ISCRE=0: SCALE OF THE REMAINDER TERMS = 1                         *
*         =1: ------------------------------ RENORD                    *
*         =2: ------------------------------ RENORM (not recommended)  *
*----------------------------------------------------------------------*
* IF ISCAL=0: SCALET=1                                                 *
*         =1: SCALET=SCLAVR+SCTPLU     |                               *
*         =2: SCALET=SCLAVR            | Kniehl's                      *
*         =3: SCALET=SCLAVR-SCTMIN     |                               *
*         =4: SCALET=SIRLIN'S 0.204    |                               *
*----------------------------------------------------------------------*
* IF IFACR=0: NON   -EXPANDED DR                                       *
*         =1: PARTLY-EXPANDED DR, RESPECTING DRL*DRR-ORDER             *
*         =2: PARTLY-EXPANDED DR, VIOLATING  DRL*DRR-ORDER       (n.r.)*
*         =3: FULLY -EXPANDED DR, DOUBLE VIOLATING DRL*DRR-ORDER (n.r.)*
*----------------------------------------------------------------------*
* IF IFACT=0: NON   -EXPANDED RHO AND KAPPA    analogs      ff level   *
*         =1: PARTLY-EXPANDED RHO AND KAPPA       of        ff level   *
*         =2: PARTLY-EXPANDED RHO AND KAPPA     those       ff level   *
*         =3: FULLY -EXPANDED RHO AND KAPPA    in IFACR     ff level   *
*         =4: FULLY -NEGLECTED REM^2 TERMS               width level   *
*         =5:       -FAMOUS EW/QCD NON FACTORIZATION     width level   *
*----------------------------------------------------------------------*
* IHIGS: IHIGS = 0: LEADING HIGGS CONTRIBUTION IS NOT RESUMMED         *
*      I       = 1: LEADING HIGGS CONTRIBUTION IS     RESUMMED         *
*----------------------------------------------------------------------*
* IALEM: IALEM = 0: RELEASES ALQED FOR THE FIT, IT MUST BE GIVEN THEN  *
*      I       = 1: ALQED IS CALCULATED FROM A PARAMETRIZATION - IVPOL *
*----------------------------------------------------------------------*
* CHOICE OF INPUT PARAMETERS BESIDES AMT, AMH, ALPHA.S:                *
* IMOMS: IMOMS = 1: (CONVENTIONAL)    ALPHA, G.MU, AMZ (OUTPUT: AMW)   *
*      I       = 2: INPUT INSTEAD IS: ALPHA, G.MU, AMW (OUTPUT: AMZ)   *
*      I       = 3:                   ALPHA,  AMZ, AMW (OUTPUT: GMU)   *
* WHERE                                                                *
*      I G.MU..... MUON DECAY CONSTANT                                 *
*      I AMT...... T-QUARK MASS                                        *
*      I AMH...... HIGGS BOSON MASS                                    *
*      I ALST..... STRONG COUPLING CONSTANT ALPHA.S (.11)              *
*----------------------------------------------------------------------*
*
      IMPLICIT REAL*8(A-H,O-Z)
      COMPLEX*16 XFOTF1
*
      COMMON/CDZFLG/IHVP,IAMT4,IQCD,IMOMS,IMASS,IALEM,IMASK,IBARB,IFTJR
      COMMON/CDZSCT/ISCRE,ISCAL,IAFMT,IFACR,IFACT,IHIGS
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZZWG/CAMZ,CAMH,GMU,A0,GAMZ,GAMW,CALSZ,CALST,CALXI,CALQED
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZRKZ/ARROFZ(0:10),ARKAFZ(0:10),ARVEFZ(0:10),ARSEFZ(0:10)
      DIMENSION NPAR(15),PARTZ(0:11),PARTW(3),ZPAR(30),QCDCOR(0:14)
*
* FLAGS SETTING
       IHVP=NPAR(1)
      IAMT4=NPAR(2)
       IQCD=NPAR(3)
      IMOMS=NPAR(4)
      IMASS=NPAR(5)
      ISCRE=NPAR(6)
      IALEM=NPAR(7)
      IMASK=NPAR(8)
      ISCAL=NPAR(9)
      IBARB=NPAR(10)
      IFTJR=NPAR(11)
      IFACR=NPAR(12)
      IFACT=NPAR(13)
      IHIGS=NPAR(14)
      IAFMT=NPAR(15)
      ITQ=2-IHVP
*
      CALL CONST1(ITQ,AMT,AMH)
*
      ALFAS = ALSTR
*
*----------------------------------------------------------------------
* CALCULATION 0F ALPHST=ALPHAS(AMZ**2) AND ALPHTT=ALPHAS(AMT**2)
* FOR THE HIGHER ORDER ALPHA*ALPHA.S CORRECTIONS WITH T-MASS AS USED
* IN THE CALCULATIONS OF DELTA.R AND THE GAUGE BOSON WIDTHS
*
*-----------------------------------------------------------------------
      CAMZ=AMZ
      CAMH=AMH
*-----------------------------------------------------------------------
      IF(IALEM.EQ.0) THEN
        CALQED=ALQED
         ELSE
        DALFA=DREAL(XFOTF1(IHVP,0,0,-AMZ**2))*AL4PI
        ALQED=1D0/ALFAI/(1D0-DALFA)
        CALQED=ALQED
      ENDIF
      SW2=.2325D0
      ALPHST=ALFAS
      CALL QCDCOF(AMZ,AMT,SW2,ALQED,ALPHST,ALPHTT,ALPHXI,QCDCOR)
      CALSZ=ALPHST
      CALST=ALPHTT
      CALXI=ALPHXI
       ALSZ=ALPHST
       ALST=ALPHTT
       ALSX=ALPHXI
*
* ITERATIVE PROCEDURE FOR THE CALCULATION OF IVB- MASSES
      CALL SETCON(AMW,AMZ,AMT,AMH,DR,DRBIG,DRREM)
*
      AMW=DSQRT(AMW2)
      SW2=R1
      IF(IMOMS.EQ.2) AMZ=AMW/SQRT(1D0-SW2)
*-----------------------------------------------------------------------
* CALCULATION OF FINAL STATE QCD-FACTORS FOR Z,W - DECAYS INTO QUARKS
*-----------------------------------------------------------------------
      IF(IAMT4.EQ.-1) THEN
       IF(ALFAS.LE.1D-10) THEN
        DO IQCDC=0,14
        QCDCOR(IQCDC)=1.000D0
        ENDDO
         ELSE
        QCDCOR(0)=1.000D0
        DO IQCDC=1,10
        QCDCOR(IQCDC)=1.040D0
        ENDDO
        QCDCOR(11)=1.045D0
        QCDCOR(12)=1.045D0
        QCDCOR(13)=1.040D0
        QCDCOR(14)=1.040D0
       ENDIF
        ELSE
        CALL QCDCOF(AMZ,AMT,SW2,ALQED,ALPHST,ALPHTT,ALFAXI,QCDCOR)
      ENDIF
*
* CALCULATION OF Z- AND W- WIDTHS
      CALL ZWRATE(DR,DRBIG,DRREM,QCDCOR,PARTZ,PARTW)
* FILLING OF OUTPUT VECTOR
      ZPAR(1)=DR
      ZPAR(2)=DRREM
      ZPAR(3)=SW2
      GMUC   =PI/ALFAI/AMW2/SW2/(1D0-DR)*1D5/SQRT(2D0)
      ZPAR(4)=GMUC
      DO 3 IZ=5,14
      ZPAR(IZ)=ARSEFZ(IZ-5)
  3   CONTINUE
      ZPAR(15)=ALPHST
      DO IQCDC=0,14
      ZPAR(16+IQCDC)=QCDCOR(IQCDC)
      ENDDO
*-----------------------------------------------------------------------
      END
 
      FUNCTION DZEWBX (RACOS)
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZZWG/AMZ,AMH,GMU,A0,GAMZ,GAMW,CALSZ,CALST,CALXI,CALQED
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFLG/IHVP,IAMT4,IQCD,IMOMS,IMASS,IALEM,IMASK,IBARB,IFTJR
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZBOX/QE,QF,ALAM1,ALAM2,HELI1,HELI2,SC,VE,VF,CRFAC
      COMMON/FORCHI/XKAPP,XKAPPC,XMZ2,XMZ2C
      COMMON/XFORMZ/XFZ(4),XFZT,XFZTA
*
      ACOS=RACOS
      S=SC
      GMU2=GMU*GMU
      AMZ4=AMZ2*AMZ2
      AMW4=AMW2*AMW2
      PI3=PI*PI2
      CNST=PI/(2.D0*S*ALFAI*ALFAI)
      CBXWW=CNST*GMU2*AMW4*ALFAI/(4.D0*PI3)
*IAMT4=-1
C       BACKWARD COMPATIBILITY TO YR 1989, LIN.ZWRATE,SOME BUGS
      IF(IAMT4.EQ.-1) THEN
      CBXZZ=CNST*GMU2*AMZ4*ALFAI/(64.D0*PI3)
      ELSE
      CBXZZ=CNST*GMU2*AMZ4*ALFAI/(256.D0*PI3)
      ENDIF
      COMPL=ALAM1+ALAM2
      COMMI=ALAM1-ALAM2
      HOMPL=HELI1+HELI2
      HOMMI=HELI1-HELI2
      QEM=DABS(QE)
      QFM=DABS(QF)
C AVOID THAT AI11,AI12 IS ZERO: MULTIPLY ACOS BY (1. - 2*ME**2/S)
      ACOSM=ACOS*(1.D0-0.0000005D0/S)
      IF (ABS(ACOSM) .EQ. 1.D0)  ACOSM = DSIGN(0.9999999999999D0,ACOS)
      AI11=S/2.D0*(1.D0+ACOSM)
      AI12=S/2.D0*(1.D0-ACOSM)
      VEP1=VE+1.D0
      VEM1=VE-1.D0
      VFP1=VF+1.D0
      VFM1=VF-1.D0
      VEP2=VEP1*VEP1
      VEM2=VEM1*VEM1
      VFP2=VFP1*VFP1
      VFM2=VFM1*VFM1
      VEP3=VEP1*VEP2
      VEM3=VEM1*VEM2
      VFP3=VFP1*VFP2
      VFM3=VFM1*VFM2
      VZP1=COMPL*HOMPL*VEP2*VFP2+COMMI*HOMMI*VEM2*VFM2
      VZP2=COMPL*HOMPL*VEP3*VFP3+COMMI*HOMMI*VEM3*VFM3
      VZM1=COMPL*HOMMI*VEP2*VFM2+COMMI*HOMPL*VEM2*VFP2
      VZM2=COMPL*HOMMI*VEP3*VFM3+COMMI*HOMPL*VEM3*VFP3
      XCHI=XKAPP*S/(S-XMZ2)
      XCHIG=DCONJG(XCHI)
cbard XFZTG=DCONJG(1.D0/(2.D0-XFZT))
      XFZTG=(1.D0,0.D0)
      SE=1D0
      SF=1D0
      IF(QE.NE.0D0) SE=QE/QEM
      IF(QF.NE.0D0) SF=QF/QFM
      XCHIGF=XCHIG*SF
      BOXWW=-COMPL*HOMPL*DREAL(
     & +(QF*XFZTG+XCHIGF*VEP1*VFP1)*
     &  (+(1D0+SE*SF)/2D0*(XBOX(AI11,AI12,AMW2)
     &   +4.D0*(AI11/S)**2*XJ3(S,AMW2))
     &   -(1D0-SE*SF)/2.D0*2.D0*(AI11/S)**2
     &   *(AI11/S*XJ4(S,AI11,AMW2)+2.D0*XJ3(S,AMW2)) ))
      BOXZZ=-DREAL(
     & +(QF*XFZTG*VZP1+XCHIGF*VZP2)
     & *(XBOX(AI11,AI12,AMZ2)-(2.D0*(AI11/S)**3)*XJ4(S,AI11,AMZ2))
     & -(QF*XFZTG*VZM1+XCHIGF*VZM2)
     & *(XBOX(AI12,AI11,AMZ2)-(2.D0*(AI12/S)**3)*XJ4(S,AI12,AMZ2)))
* BOX CROSS SECTION TAKES INTO ACCOUNT
* ARBITRARY BEAM POLARIZATIONS AND DEFINITE FINAL HELICITIES
* COLORF IS TAKEN INTO ACCOUNT IN ZFITTER VIA CORINT
      DZEWBX=CRFAC*(CBXWW*BOXWW+CBXZZ*BOXZZ)
      END
 
      FUNCTION XJ2(S,AMV2)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
*
      RMV=AMV2/S
      REJ2=S*FJJ(-S,AMV2,AMV2)
      AIJ2=0.D0
      IF(1.D0.LE.4.D0*RMV.OR.S.LT.0D0) GO TO 1
      SLAMS=SQRT(1.D0-4.D0*RMV)
      AIJ2=2.D0*PI/SLAMS
1     XJ2=DCMPLX(REJ2,AIJ2)
      END
 
      FUNCTION XJ3(S,AMV2)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      DATA EPS/1.D-20/
*
      XI=DCMPLX(0.D0,1.D0)
      XMV2E=AMV2-XI*EPS
      XALF=(-S)/XMV2E
      XS12=SQRT(1.D0+4.D0/XALF)
      XY1=(1.D0-XS12)/2.D0
      XY2=(1.D0+XS12)/2.D0
      XJ3=(LOG(-XY1/XY2))**2
      END
 
      FUNCTION XJ4(S,AI,AMV2)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      DATA EPS/1.D-20/
*
      XI  =DCMPLX(0.D0,1.D0)
      XMV2=AMV2-XI*EPS
      XALF=(-S)/XMV2
      XBET=  AI/XMV2
      XS12=SQRT(1.D0+4.D0/XALF)
      XY1 =(1.D0-XS12)/2.D0
      XY2 =(1.D0+XS12)/2.D0
      XS34=SQRT(1.D0-4.D0*(1.D0-XBET)/(XALF*XBET))
      XY3 =(1.D0-XS34)/2.D0
      XY4 =(1.D0+XS34)/2.D0
      XNOR=(-XALF)*XBET*XS34
      XJ4A=2.D0*(S/AMV2)**2/XNOR*
     &(XSPENZ(-XY4/(XY2-XY4))-XSPENZ(-XY3/(XY1-XY3))
     &+XSPENZ(-XY4/(XY1-XY4))-XSPENZ(-XY3/(XY2-XY3)))
      REJ4=DREAL(XJ4A)
      AIJ4=0D0
      IF(S.GT.0D0) AIJ4=DIMAG(XJ4A)
      XJ4=DCMPLX(REJ4,AIJ4)
      END
 
      FUNCTION XBOX(AI11,AI12,AMV2)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZFLG/IHVP,IAMT4,IQCD,IMOMS,IMASS,IALEM,IMASK,IBARB,IFTJR
*
      S=AI11+AI12
      RI1S=AI11/S
      RI2S=AI12/S
      RMV=AMV2/S
C THE ABS SHOULD BE FURTHER INVESTIGATED
*     XBOX=2.D0*RI1S*LOG(RI2S/RMV)+RI1S*(1.D0-4.D0*RMV)*XJ2(S,AMV2)
*IAMT4=-1
      IF(IAMT4.EQ.-1) THEN
      XBOX=2.D0*RI1S*LOG(ABS(RI2S/RMV))+RI1S*(1.D0-4.D0*RMV)*XJ2(S,AMV2)
     *+2.D0*(RI2S-RI1S-2.D0*RMV)*(F1-SPENCE(1.D0-RI2S)+XJ3(S,AMV2))
     *+(2.D0*RMV**2*RI1S+RI1S**2*RI2S+RI2S*(RI2S-2.D0*RMV)**2)
     **XJ4(S,AI12,AMV2)
       ELSE
      XBOX=2.D0*RI1S*LOG(ABS(RI2S/RMV))+RI1S*(1.D0-4.D0*RMV)*XJ2(S,AMV2)
     * +2.D0*(RI2S-RI1S-2.D0*RMV)*(F1-SPENCE(1.D0-RI2S/RMV)+XJ3(S,AMV2))
     *+(2.D0*RMV**2*RI1S+RI1S**2*RI2S+RI2S*(RI2S-2.D0*RMV)**2)
     **XJ4(S,AI12,AMV2)
       ENDIF
*
      END
 
      SUBROUTINE ROKAPN(INL,T,QFER,DROV,ROFAC,AKFAC)
C
C INL=1 FOR ELECTRON NEUTRINO
C INL=2 FOR MUON     NEUTRINO
C T=Q^2
C QFER=-1   FOR NEUTRINO-ELECTRON SCATTERING
C QFER=-1/3 FOR NEUTRINO-DOWN     SCATTERING
C QFER= 2/3 FOR NEUTRINO-UP       SCATTERING
C ROFAC, AKFAC ARE CALCULATED EWFF RHO AND KAPPA
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      COMMON/CDZFLG/IHVP,IAMT4,IQCD,IMOMS,IMASS,IALEM,IMASK,IBARB,IFTJR
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
      COMMON/CDZZWG/AMZ,AMH,GMU,A0,GAMZ,GAMW,CALSZ,CALST,CALXI,CALQED
      COMMON/CDZWSC/SL2,SQ2,W0,W0F,Z0,Z0F,DWZ0R1,DWZ0F,XWM1,XWM1F,XZM1,
     &      XZM1F,XWZ1R1,XDWZ1F,XZFM1,XZFM1F,XAMM1,XAMM1F,XWFM1,XWFM1F
      CALL FORMFN(INL,T,QFER,DDROV,RO1,AK1)
      DROV=AL4PI*DDROV
      AMT =AMQ(5)
      AMT2=AMT*AMT
      RMTW=AMT2/AMW2
      RTT=T/AMT2
      Q2M=ABS(T)
      ALSZ=CALSZ
      ALST=CALXI
      SW2=R1
      AMT2=AMQ(5)**2
      XZERO=DCMPLX(0.D0,0.D0)
      XRQCD=XZERO
      XKQCD=XZERO
      IF(IQCD-1) 1,2,3
2     XRQCD=AL4PI*XRQCDS(ALST,SW2,AMT2,Q2M)
      XKQCD=AL4PI*XKQCDS(ALST,SW2,AMT2,Q2M)
      GOTO 1
 3    XRQCD=AL4PI*XROQCD(ALSZ,ALST,SW2,AMT2,Q2M)
      XKQCD=AL4PI*XKAQCD(ALST,SW2,AMT2,Q2M)
1     CONTINUE
      IF(RTT-.1D0)4,4,5
4     ROFACT=AL4PI/R1*3.D0*RMTW*(1.D0/4.D0-5.D0/12.D0*RTT
     *     +19.D0/120.D0*RTT*RTT)
      GO TO 10
5     ROFACT=AL4PI/R1*3.D0*RMTW*(.5D0*DREAL(XI0(AMW2,T,AMT2,AMT2))
     +     -DREAL(XI1(AMW2,T,AMT2,0.D0)))
10    CONTINUE
      ROFAC=1.D0+RO1*AL4PI/R1+ROFACT+DREAL(XRQCD)
      AKFAC=1.D0+AK1*AL4PI/R1       +DREAL(XKQCD)
C--------------------------------------------------------------------
      IF(IBARB.EQ.0) THEN
       AMT4C=19-2D0*PI2
        ELSEIF(IBARB.EQ.1) THEN
       RBTH=AMT2/AMH2
       ALRB=LOG(RBTH)
       AMT4C=49D0/4D0+PI2+27D0/2D0*ALRB+3D0/2D0*ALRB**2
     &      +RBTH/3D0*(2D0-12D0*PI2+12D0*ALRB-27D0*ALRB**2)
     &  +RBTH**2/48D0*(1613-240*PI2-1500*ALRB-720 *ALRB**2)
        ELSEIF(IBARB.EQ.2) THEN
       RBARB=SQRT(AMH2/AMT2)
       AMT4C=FBARB(RBARB)
      ENDIF
C--------------------------------------------------------------------
      IF (IAMT4 .EQ. 1 ) THEN
       SW2 = R1
       AMT2  = AMQ(5)**2
       DRHOT = .75D0*AL4PI/SW2/R*AMT2/AMZ2
       TOPX2 = GMU*AMT2/DSQRT(2.D0)/8.D0/PI2
       DRHOT4= 3.D0*TOPX2*(1.D0+TOPX2*AMT4C)
       ROFAC =(ROFAC-DRHOT)/(1.D0-DRHOT4)
       AKFAC =(AKFAC-R/SW2*DRHOT)*(1.D0+R/SW2*DRHOT4)
      ELSEIF(IAMT4 .EQ. 2 ) THEN
       SW2 = R1
       AMT2  = AMQ(5)**2
       DRHOT = .75D0*AL4PI/SW2/R*AMT2/AMZ2
       TOPX2 = GMU*AMT2/DSQRT(2.D0)/8.D0/PI2
       DRHOT4= 3.D0*TOPX2*(1.D0+TOPX2*AMT4C)
       IF(IQCD.EQ.0) THEN
        TBQCD0= 0D0
        TBQCDL= 0D0
         ELSE
        TBQCD0= TOPX2*ALST/PI*2D0*(1D0+PI2/3D0)
        TBQCDL= AL4PI*ALST/PI*AMT2/AMW2/R1*(.5D0+PI2/6D0)
       ENDIF
       ROFAC =(ROFAC-DRHOT-TBQCDL)/(1.D0-DRHOT4-TBQCD0)
       AKFAC =(AKFAC-R/SW2*(DRHOT+TBQCDL))*(1D0+R/SW2*(DRHOT4+TBQCD0))
      ELSEIF(IAMT4 .EQ. 3 ) THEN
       DWZ1AL=R/R1*DREAL(XWZ1R1+XDWZ1F)
       RENORM=SQRT(2D0)*GMU*AMZ2*R1*R/PI*ALFAI
       SCALE = AL4PI/R1*(-ALR*(41D0/6D0-11D0/3D0*R))
       CORKAP=AL4PI*DWZ1AL-SCALE+.75D0*AL4PI/SW2**2*AMT2/AMZ2
*
       SW2 = R1
       AMT2  = AMQ(5)**2
       DRHOT = .75D0*AL4PI/SW2/R*AMT2/AMZ2
       TOPX2 = GMU*AMT2/DSQRT(2.D0)/8.D0/PI2
       DRHOT4= 3.D0*TOPX2*(1.D0+TOPX2*AMT4C)
       IF(IQCD.EQ.0) THEN
        TBQCD0=0D0
        TBQCDL=0D0
         ELSE
        TBQCD0=TOPX2*ALST/PI*2D0*(1D0+PI2/3D0)
        TBQCDL=AL4PI*ALST/PI*AMT2/AMW2/R1*(.5D0+PI2/6D0)
       ENDIF
       ROFAC=(ROFAC-DRHOT-TBQCDL)/(1.D0-DRHOT4-TBQCD0)
       AKFAC=(AKFAC-R/SW2*(DRHOT+TBQCDL)+CORKAP)
     &      *(1D0+R/SW2*(DRHOT4+TBQCD0)-CORKAP*RENORM)
      ENDIF
C-------------------------------------------------------------------
      END
 
      SUBROUTINE FORMFN(INL,Q2,QFER,DDROV,RO1,AK1)
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      COMMON/CDZFLG/IHVP,IAMT4,IQCD,IMOMS,IMASS,IALEM,IMASK,IBARB,IFTJR
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
      COMMON/CDZZWG/AMZ,AMH,GMU,A0,GAMZ,GAMW,CALSZ,CALST,CALXI,CALQED
      COMMON/CDZWSC/SL2,SQ2,W0,W0F,Z0,Z0F,DWZ0R1,DWZ0F,XWM1,XWM1F,XZM1,
     &      XZM1F,XWZ1R1,XDWZ1F,XZFM1,XZFM1F,XAMM1,XAMM1F,XWFM1,XWFM1F
      COMMON/CDZFNE/RNU,ZGM
      AQFER=ABS(QFER)
      QFER2=QFER*QFER
      SI=QFER/AQFER
      RO1=3.D0/4.D0*ALR/R1+9.D0/4.D0
     *   +3.D0/4.D0*RZ*(ALRZ/R/RZ1-ALRW/(R-RZ))
     *   -3.D0/2.D0*(1.D0+SI)
     *   -3.D0/2.D0/R*SI*(1.D0/2.D0-2.D0*R1*AQFER+4.D0*R12*QFER2)
      IND=2*INL
1     V1B1W=4.D0*DREAL(XI3(AMW2,Q2,AML(IND)**2,AML(IND)**2))
      RNU=AL4PI/R1*V1B1W
      CHQ21=DREAL(XI3(AMW2,Q2,AML(2)**2,AML(2)**2)
     *     +XI3(AMW2,Q2,AML(4)**2,AML(4)**2)
     *     +XI3(AMW2,Q2,AML(6)**2,AML(6)**2))
      CHMQ1=CHQ21
      DO 201 I=1,6
      AMQ2=AMQ(I)**2
      CHMQ1=CHMQ1+3.*CQM(I)   *DREAL(XI3(AMW2,Q2,AMQ2,AMQ2))
      CHQ21=CHQ21+3.*CQM(I)**2*DREAL(XI3(AMW2,Q2,AMQ2,AMQ2))
201   CONTINUE
      XWZ1AL=R*XWZ1R1+R*XDWZ1F
      DWZ1AL=DREAL(XWZ1AL)
      ZGM=AL4PI/R1*(+8.D0*R1*CHQ21-2.D0*CHMQ1)
      AK1=-DWZ1AL+3.D0/2.D0*(1.D0+SI)-5.D0-2.D0/3.D0*R
     *    +3.D0/2.D0/R*SI*(1.D0/2.D0-3.D0*R1*AQFER+4.D0*R12*QFER2)+V1B1W
     *    +8.D0*R1*CHQ21-2.D0*CHMQ1
      DDROV=-DWZ1AL/R
      END
 
      FUNCTION XV1B(Q2,AMV2)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
*
      AL=Q2/AMV2
      ALA=LOG(ABS(AL))
      REV1B=-3.5D0+2.D0/AL+(3.D0-2.D0/AL)*ALA
     *     +2.D0*(1.D0-1.D0/AL)**2*(SPENCE(1.D0-AL)-F1)
      AIV1B=0.D0
      IF(Q2.LT.0.D0)
     &AIV1B=PI*(-3.D0+2.D0/AL+2.D0*(1.D0-1.D0/AL)**2*LOG(1.D0-AL))
      XV1B=DCMPLX(REV1B,AIV1B)
      END
 
      FUNCTION XA1B(Q2,AMV2)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      RMV=AMV2/Q2
      XA1B=-8.D0*RMV+32.D0/3.D0
     *    +(2.D0*RMV-17.D0/6.D0)/Q2*XL(Q2,AMV2,AMV2)
      END
 
      FUNCTION XROB(Q2,AMV2)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
* ROB(Q2,AMW2,AMW2)=-R*(Q2+AMZ2)*OMEGA(Q2,AMW2,AMW2)-BAR
* FK3 IS NOT CONTAINED NOW IN XROB AS IT IS GENUINE BOX CONTRIBUTION
      XROB=17.D0/6.D0-5.D0/6.D0/Q2*XL(Q2,AMV2,AMV2)
      END
 
      FUNCTION XV2B(Q2,AMV2)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      RMV=AMV2/Q2
      XV2B=5.D0/2.D0-8.D0/3.D0+2.D0*RMV
     *    +(5.D0/12.D0+3.D0/4.D0-RMV)/Q2*XL(Q2,AMV2,AMV2)
     *    +2.D0*(-2.D0*RMV+RMV**2)*XJ3(-Q2,AMV2)
      END
 
      FUNCTION XDZB(Q2)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
*
      XDRZH=XDL(Q2,-AMZ2,AMZ2,AMH2)
      XDRWW=XDL(Q2,-AMZ2,AMW2,AMW2)
      AQ=AMZ2/Q2
      XZH=-1.D0/12.D0*RZ12*AQ+1.D0/24.D0
     *   *(1.D0+RZ1*(-10.D0+5.D0*RZ-RZ2)*AQ+RZ1*RZ12*AQ**2)*ALRZ
     *   +(-11.D0+4.D0*RZ-RZ2+RZ12*AQ)/24.D0/Q2*XL(Q2,AMZ2,AMH2)
     *   +(1.D0/2.D0-RZ/6.D0+RZ2/24.D0)*XDRZH
      XZH1=-1.D0/12.D0*RZ12*AQ+1.D0/24.D0
     *    *(1.D0+RZ1*(-10.D0+5.D0*RZ-RZ2)*AQ+RZ1*RZ12*AQ**2)*ALRZ
     *    +(-11.D0+4.D0*RZ-RZ2+RZ12*AQ)/24.D0/Q2*XL(Q2,AMZ2,AMH2)
      XZH2=(1.D0/2.D0-RZ/6.D0+RZ2/24.D0)*XDRZH
      XZL=2.D0*R2/Q2*XL(Q2,AMW2,AMW2)
     *   +(-2.D0*R2-17.D0/6.D0*R+2.D0/3.D0+1.D0/24.D0/R)*XDRWW
      XDZB=34.D0/3.D0*R-35.D0/18.D0-4.D0/9.D0/R-ALR/R/12.D0+XZL+XZH/R
      END
 
      FUNCTION XDL(Q2,Q2SBT,AM12,AM22)
*
* XDL(Q2,AMQ2,AM12,AM22)=(L(Q2,AM12,AM22)-L(Q2SBT,AM12,AM22))/(Q2-Q2SBT)
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      DATA EPS/1.D-3/
*
      Q2S=Q2SBT+AM12+AM22
      ALAM=Q2S**2-4.D0*AM12*AM22
      DSLAM=DSQRT(DABS(ALAM))
      QD=Q2-Q2SBT
      RQD=DABS(QD/DSLAM)
      IF(RQD.LE.EPS) GO TO 1
      XDL=(XL(Q2,AM12,AM22)-XL(Q2SBT,AM12,AM22))/QD
      RETURN
1     R=4.D0*AM12/AM22
      IF(R-1.D0)2,3,2
2     XJS=XJ(Q2SBT,AM12,AM22)
      XDL=2.D0+Q2S*XJS+QD/ALAM*(Q2S-2.D0*AM12*AM22*XJS)
     *   +(QD/ALAM)**2*(-Q2S**2/3.D0-8.D0/3.D0*AM12*AM22*Q2S*XJS)
      RETURN
3     CONTINUE
      RAT=QD/AM22
      XDL=4.D0+2.D0/3.D0*RAT-2.D0/15.D0*RAT*RAT
*
      END
 
      FUNCTION XJ(Q2,AM12,AM22)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
*
* XJ(Q2,M12,M22)=J(Q2,M12,M22)
*
      ALAM=(Q2+AM12+AM22)**2-4.D0*AM12*AM22
      REJ=FJJ(Q2,AM12,AM22)
      AIJ=0.D0
      TRES=SQRT(AM12)+SQRT(AM22)
      IF(-Q2.LE.TRES**2) GO TO 1
      SLAM=SQRT(ALAM)
      AIJ=2.D0*PI/SLAM
1     XJ=DCMPLX(REJ,AIJ)
*
      END
 
      FUNCTION XL(Q2,AM12,AM22)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
*
* XL(Q2,M12,M22)=L(Q2,M12,M22)
*               =ALAM(Q2,-M12,-M22)*J(Q2,M12,M22)
*
      ALAM=(Q2+AM12+AM22)**2-4.D0*AM12*AM22
      REL=ALAM*FJJ(Q2,AM12,AM22)
      AIL=0.D0
      TRES=SQRT(AM12)+SQRT(AM22)
      IF(-Q2.LE.TRES**2.OR.ALAM.LT.0D0) GO TO 1
      SLAM=SQRT(ALAM)
      AIL=2.D0*PI*SLAM
1     XL=DCMPLX(REL,AIL)
*
      END
 
      FUNCTION FJJ(Q2,AM12,AM22)
*
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
*
      Q2M=Q2+AM12+AM22
      Q2L=4.D0*AM12*AM22
      ALAM=Q2M*Q2M-Q2L
      IF(ALAM)1,5,6
1     SLAM=SQRT(-ALAM)
      IF(Q2M)2,3,4
2     CONTINUE
      R1=2.D0/SLAM*ATAN(SLAM/Q2M)
      FJJ=R1+2.D0*PI/SLAM
      RETURN
3     FJJ=0.5D0*PI/SQRT(AM12*AM22)
      RETURN
4     CONTINUE
      R1=2.D0/SLAM*ATAN(SLAM/Q2M)
      FJJ=R1
      RETURN
5     FJJ=2.D0/Q2M
      RETURN
6     SLAM=SQRT(ALAM)
      IF(Q2M)7,8,8
7     FJJ=LOG(Q2L/(Q2M-SLAM)**2)/SLAM
      RETURN
8     FJJ=LOG((Q2M+SLAM)**2/Q2L)/SLAM
*
      END
 
      FUNCTION XI0(AMW2,Q2,AM12,AM22)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      DATA EPS/1.D-4/
*
***** XI0(MW2,Q2,M12,M22)=I0(Q2,M12,M22)
*
      AL1W=LOG(AM12/AMW2)
      IF(AM22/AM12.LT.EPS) GO TO 1
      AL12=LOG(AM12/AM22)
      DM12=(AM12-AM22)/Q2
      XI0=AL1W-2.D0-(1.D0+DM12)/2.D0*AL12+XL(Q2,AM12,AM22)/2.D0/Q2
      RETURN
1     AQ=AM12/Q2
      RELQ=LOG(ABS(1.D0+1.D0/AQ))
      AILQ=0.D0
      IF(-Q2.GT.AM12) AILQ=-PI
      XLQ=DCMPLX(RELQ,AILQ)
      XI0=AL1W-2.D0+(1.D0+AQ)*XLQ
*
      END
 
      FUNCTION XI1(AMW2,Q2,AM12,AM22)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      DATA EPS/1.D-4/
*
***** XI1(MW2,Q2,M12,M22)=I1(Q2,M12,M22)
*
      AL1W=LOG(AM12/AMW2)
      IF(AM22/AM12.LT.EPS) GO TO 1
      AL12=LOG(AM12/AM22)
      DM12=(AM12-AM22)/Q2
      XI1=AL1W/2D0-1.D0-DM12/2.D0
     *   -(1.D0+2.D0*AM12/Q2+DM12**2)/4.D0*AL12
     *   +(1.D0+DM12)/4.D0*XL(Q2,AM12,AM22)/Q2
      RETURN
1     AQ=AM12/Q2
      RELQ=LOG(ABS(1.D0+1.D0/AQ))
      AILQ=0.D0
      IF(-Q2.GT.AM12) AILQ=-PI
      XLQ=DCMPLX(RELQ,AILQ)
      XI1=AL1W/2D0-1.D0-AQ/2.D0+(1.D0+AQ)**2/2.D0*XLQ
*
      END
 
      FUNCTION XI3(AMW2,Q2,AM12,AM22)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      DATA EPS/1.D-4/
*
***** XI3(MW2,Q2,M12,M22)=I3(Q2,M12,M22)=INT(Y*(1-Y)*LN...)
*
      AL1W=LOG(AM12/AMW2)
      IF(AM22/AM12.LT.EPS) GO TO 1
      AL12=LOG(AM12/AM22)
      DM12=(AM12-AM22)/Q2
      SM12=(AM12+AM22)/Q2
      XI3=AL1W/6D0-5.D0/18.D0+SM12/3.D0+DM12**2/3.D0
     *   +(-0.5D0+3.D0/2.D0*SM12*DM12+DM12**3)/6.D0*AL12
     *   +(0.5D0-SM12/2.D0-DM12**2)/6.D0*XL(Q2,AM12,AM22)/Q2
      RETURN
1     AQ=AM12/Q2
      RELQ=LOG(ABS(1.D0+1.D0/AQ))
      AILQ=0.D0
      IF(-Q2.GT.AM12) AILQ=-PI
      XLQ=DCMPLX(RELQ,AILQ)
      XI3=AL1W/6D0-5.D0/18.D0+AQ/3.D0+AQ**2/3.D0
     *   +(1.D0-2.D0*AQ)*(1.D0+AQ)**2/6.D0*XLQ
*
      END
 
      FUNCTION XDI0(Q2,AMV2,AM12,AM22)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      RAT=DABS(AM12/AMV2)
      AL12=LOG(AM12/AM22)
      XDI0=(XL(Q2,AM12,AM22)-(AM12-AM22)*AL12)/2.D0/Q2
     *    -XDL(Q2,-AMV2,AM12,AM22)/2.D0
*
      END
 
      FUNCTION XDI1(Q2,AMV2,AM12,AM22)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      DATA EPS/1.D-4/
*
      IF(AM22.LT.1.D-10) GO TO 1
      AL12=LOG(AM12/AM22)
      DM12=(AM12-AM22)/Q2
      AQ=Q2/AMV2
      SMV1=1.D0-AQ
      XDI1=-DM12/2.D0-(2.D0*AM12/Q2+DM12**2*SMV1)*AL12/4.D0
     *    +(1.D0+DM12*SMV1)/4.D0/Q2*XL(Q2,AM12,AM22)
     *    -(1.D0-(AM12-AM22)/AMV2)/4.D0*XDL(Q2,-AMV2,AM12,AM22)
      RETURN
* CHAIN1 WILL BE USED ONLY FOR W-WIDTH
1     QV=(Q2+AMV2)/AMV2
      IF(ABS(QV).LT.EPS) GO TO 2
      XDI1=(XI1(AMW2,Q2,AM12,AM22)-XI1(AMW2,-AMV2,AM12,AM22))/QV
      RETURN
2     R1V=AM12/AMV2
      VQ=AMV2/Q2
      AQ=AM12/Q2
      RDI1=0.5D0*(-1.D0+R1V*(1.D0-VQ)-0.5D0*QV
     *    +(2.D0*AQ+VQ*(VQ-1.D0)*R1V**2)*LOG(ABS(1.D0+1.D0/AQ)))
      XDI1=DCMPLX(RDI1,0.D0)
*
      END
 
      FUNCTION XDI3(Q2,AMV2,AM12,AM22)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      DATA EPS/1.D-4/
*
      IF(AM22.LT.1.D-10) GO TO 1
      AL12=LOG(AM12/AM22)
      DM12=(AM12-AM22)/Q2
      SM12=(AM12+AM22)/Q2
      AQ=Q2/AMV2
      SMV1=1.D0-AQ
      SMV2=1.D0-AQ+AQ*AQ
      XDI3=SM12/3.D0+DM12**2/3.D0*SMV1
     *    +(SM12*DM12/4.D0*SMV1+DM12**3/6.D0*SMV2)*AL12
     *    +(0.5D0-SM12/2.D0*SMV1-DM12**2*SMV2)/6.D0/Q2*XL(Q2,AM12,AM22)
     *    -(0.5D0+0.5D0*(AM12+AM22)/AMV2
     *    -((AM12-AM22)/AMV2)**2)/6.D0*XDL(Q2,-AMV2,AM12,AM22)
      RETURN
* CHAIN1 WILL BE USED ONLY FOR W-WIDTH
1     QV=(Q2+AMV2)/AMV2
      IF(ABS(QV).LT.EPS) GO TO 2
      XDI3=(XI3(AMW2,Q2,AM12,AM22)-XI3(AMW2,-AMV2,AM12,AM22))/QV
      RETURN
2     R1V=AM12/AMV2
      VQ=AMV2/Q2
      VQ2=1.D0-VQ+VQ**2
      AQ=AM12/Q2
      RDI3=-1.D0/6.D0+(VQ-0.5D0)/3.D0*R1V+VQ2/3.D0*R1V**2
     *    -QV*(0.5D0+R1V)/6.D0-VQ*R1V**2*((VQ-1.D0)/2.D0
     *    +VQ2/3.D0*R1V)*LOG(ABS(1.D0+1.D0/AQ))
      XDI3=DCMPLX(RDI3,0.D0)
*
      END
 
      FUNCTION XDWF(Q2)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
      COMMON/CDZWSC/SL2,SQ2,W0,W0F,Z0,Z0F,DWZ0R1,DWZ0F,XWM1,XWM1F,XZM1,
     &      XZM1F,XWZ1R1,XDWZ1F,XZFM1,XZFM1F,XAMM1,XAMM1F,XWFM1,XWFM1F
*
      NG=3
      XSI3  =DCMPLX(0D0,0D0)
      XSDI1U=DCMPLX(0D0,0D0)
      XSDI1D=DCMPLX(0D0,0D0)
      DO 1 I=1,NG
      AML2=AML(2*I)**2
      XI31=XI3 (AMW2,Q2,AML2,0D0)
      XI32=XDI3(Q2,AMW2,AML2,0D0)
      XSI3=XSI3+XI3(AMW2,Q2,AML2,0D0)-XDI3(Q2,AMW2,AML2,0D0)
      XSDI1D=XSDI1D+AML2/AMW2*XDI1(Q2,AMW2,AML2,0D0)
1     CONTINUE
      DO 2 I=1,NG
      AMU2=AMQ(2*I-1)**2
      AMD2=AMQ(2*I  )**2
      XSI3=XSI3+3D0*(XI3(AMW2,Q2,AMU2,AMD2)-XDI3(Q2,AMW2,AMU2,AMD2))
      XSDI1U=XSDI1U+3D0*AMU2/AMW2*XDI1(Q2,AMW2,AMU2,AMD2)
      XSDI1D=XSDI1D+3D0*AMD2/AMW2*XDI1(Q2,AMW2,AMD2,AMU2)
2     CONTINUE
      XDWF=2D0*XSI3+XSDI1U+XSDI1D
*
      END
 
      FUNCTION XDZF(Q2)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      DATA EPS/1.D-3/
*
      NG=3
      ALQ=LOG(ABS(Q2/AMZ2))
      AIL1=0.D0
      AIL2=0.D0
      IF(Q2.LT.0.D0) AIL1=-PI
      IF(Q2.GT.0.D0) AIL2=-PI
      XL1=DCMPLX(ALQ,AIL1)
      XL2=DCMPLX(ALQ,AIL2)
      QD=AMZ2+Q2
      RQD=QD/AMZ2
      XLQ=XL1+1.D0+RQD/2.D0+RQD*RQD/3.D0
      IF(DABS(RQD).GT.EPS) XLQ=XL1-AMZ2/(AMZ2+Q2)*XL2
      XSNU=NG/R/6.D0*(-5.D0/3.D0-ALR+XLQ)
      XSI3=DCMPLX(0.D0,0.D0)
      XSQMI3=DCMPLX(0.D0,0.D0)
      XSQ2I3=DCMPLX(0.D0,0.D0)
      XSDI0=DCMPLX(0.D0,0.D0)
      DO 1 I=1,NG
      AML2=AML(2*I)**2
      XSI3=XSI3+XI3(AMW2,Q2,AML2,AML2)-XDI3(Q2,AMZ2,AML2,AML2)
      XSDI0=XSDI0+AML2/AMW2*XDI0(Q2,AMZ2,AML2,AML2)
1     CONTINUE
      XSQMI3=XSI3
      XSQ2I3=XSI3
      INQ=2*NG
      DO 2 I=1,INQ
      AMQ2=AMQ(I)**2
      XSI3=XSI3+3.D0*(XI3(AMW2,Q2,AMQ2,AMQ2)-XDI3(Q2,AMZ2,AMQ2,AMQ2))
      XSQMI3=XSQMI3+3.D0*CQM(I)*(XI3(AMW2,Q2,AMQ2,AMQ2)
     *      -XDI3(Q2,AMZ2,AMQ2,AMQ2))
      XSQ2I3=XSQ2I3+3.D0*CQM(I)**2*(XI3(AMW2,Q2,AMQ2,AMQ2)
     *      -XDI3(Q2,AMZ2,AMQ2,AMQ2))
      XSDI0=XSDI0+3.D0*AMQ2/AMW2*XDI0(Q2,AMZ2,AMQ2,AMQ2)
2     CONTINUE
      XDZF=(8.D0*R12*XSQ2I3-4.D0*R1*XSQMI3+XSI3)/R+XSDI0/2.D0+XSNU
*
      END
 
      FUNCTION XAMF(Q2)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
*
      NG=3
      XCHMQ1=DCMPLX(0.D0,0.D0)
      DO 1 I=1,NG
      AML2=AML(2*I)**2
      XCHMQ1=XCHMQ1+XI3(AMW2,Q2,AML2,AML2)
1     CONTINUE
      XCHQ21=XCHMQ1
      INQ=2*NG
      DO 2 I=1,INQ
      AMQ2=AMQ(I)**2
      XCHMQ1=XCHMQ1+3.D0*CQM(I)*XI3(AMW2,Q2,AMQ2,AMQ2)
      XCHQ21=XCHQ21+3.D0*CQM(I)**2*XI3(AMW2,Q2,AMQ2,AMQ2)
2     CONTINUE
      XAMF=8.D0*R1*XCHQ21-2.D0*XCHMQ1
      END
 
      FUNCTION XFOTF(Q2)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
*
      NG=3
      XCHQ21=DCMPLX(0.D0,0.D0)
      DO 1 I=1,NG
      AML2=AML(2*I)**2
      XCHQ21=XCHQ21+XI3(AML2,Q2,AML2,AML2)
1     CONTINUE
      INQ=2*NG
      DO 2 I=1,INQ
      AMQ2=AMQ(I)**2
      XCHQ21=XCHQ21+3.D0*CQM(I)**2*XI3(AMQ2,Q2,AMQ2,AMQ2)
2     CONTINUE
      XFOTF=8.D0*XCHQ21
      END
 
      FUNCTION XFOTF1(IHVP,IQCD,ITOP,Q2)
*
* NEG.Q2 IS S-CHANNEL, POS. T-CHANNEL
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZZWG/AMZ,AMH,GMU,A0,GAMZ,GAMW,CALSZ,CALST,CALXI,CALQED
*
      NG=3
      XCHQ21=DCMPLX(0D0,0D0)
C********* LEPTONIC PART OF VACUUM POLARISATION ********************
      DO 1 I=1,NG
      AML2=AML(2*I)**2
      XCHQLL=XI3(AML2,Q2,AML2,AML2)
      XCHQ21=XCHQ21+XCHQLL
 1    continue
      AMT2=AMQ(5)**2
      ALSZ=CALSZ
      ALST=CALXI
      SW2=R1
* AL4PI is removed from ALFQCD as Tord suggested
      IF(IQCD-1) 2,3,4
 2    ALFQCD=0D0
      GO TO 5
 3    ALFQCD=ALQCDS(ALST,SW2,AMT2)
      GO TO 5
 4    ALFQCD=ALQCD (ALST,SW2,AMT2)
 5    CONTINUE
      IF (IHVP - 2) 6,7,9
 6    CONTINUE
      XCHQ25=3D0*CQM(5)**2*XI3(AMT2,Q2,AMT2,AMT2)
      XCHQ21=XCHQ21+XCHQ25*ITOP
cbard  print *,'Mass =',AML(2),AML(4),AML(6),SQRT(ABS(Q2))
cbard  print *,'DALFL=',DREAL(8*XCHQ21)*AL4PI
*
      S0=91.176D0**2
      AMQ2=ABS(Q2)
      UDCSB = 0.0282D0+0.002980*(LOG(AMQ2/S0)+0.005696*(AMQ2/S0-1D0))
      INQ=2*NG
      XCHQQQ=DCMPLX(0.D0,0.D0)
      DO 61 I=1,INQ
      IF(ITOP.EQ.0.AND.I.EQ.5) GOTO 61
      AMQ2=AMQ(I)**2
      XCHQQQ=XCHQQQ+3D0*CQM(I)**2*XI3(AMQ2,Q2,AMQ2,AMQ2)
 61   CONTINUE
C UDCSB BY JEGERLEHNER (FROM B.KNIEHLS MAIL)
CBARDINN
      XFOTF1=8*XCHQ21+DCMPLX(UDCSB/AL4PI,8*DIMAG(XCHQQQ))+ALFQCD*ITOP
      XFOTF1=8*XCHQ21+DCMPLX(0.0280d0/AL4PI,8*DIMAG(XCHQQQ))+ALFQCD*ITOP
cbard  print *,'ITOP =',ITOP
cbard  print *,'DALFH=',UDCSB
cbard  print *,'DALFS=',DREAL(XFOTF1)*AL4PI
cbard  print *,'itop,mt =',itop,sqrt(amt2)
cbard  print *,'leptonic=',sqrt(-Q2),DREAL(8*XCHQ21)*AL4PI
cbard  print *,'top-appr=',sqrt(-Q2),-AL4PI*16d0/45*amz2/amt2
cbard  print *,'top-c 8*=',sqrt(-Q2),DREAL(8*XCHQ25)*AL4PI
* this is a correction to Im part of \alpha_em, which improved
* the agreement with TOPAZ0
cbard XFOTF1=8*XCHQ21
cbard&     +DCMPLX(UDCSB/AL4PI,8*DIMAG(XCHQQQ*(1+CALSZ/PI)))+ALFQCD*ITOP
      RETURN
C****** THIS HADRONIC PART WAS USED IN THE 1989 Z PHYSICS WORKSHOP **
 7    INQ=2*NG
      XCHQQQ=DCMPLX(0.D0,0.D0)
      DO 8 I=1,INQ
      IF(ITOP.EQ.0.AND.I.EQ.5) GOTO8
      AMQ2=AMQ(I)**2
      XCHQQQ=XCHQQQ+3D0*CQM(I)**2*XI3(AMQ2,Q2,AMQ2,AMQ2)
 8    CONTINUE
      XCHQ21=XCHQ21+XCHQQQ
      XFOTF1=8D0*XCHQ21+ALFQCD*ITOP
      RETURN
 9    CONTINUE
      XCHQ25=+3.D0*CQM(5)**2*XI3(AMT2,Q2,AMT2,AMT2)
      XCHQ21=XCHQ21+XCHQ25*ITOP
      XUDSCB = XADRQQ(-Q2)/AL4PI
      XFOTF1 = 8D0*XCHQ21 + XUDSCB +ALFQCD*ITOP
*
      END
 
      SUBROUTINE SETCON(AMW,AMZ,AMT,AMH,DR,DRBIG,DRREM)
*
************************************************************************
*   THIS SUBROUTINE WRITTEN BY D.BARDIN, S.&T. RIEMANN AND P.CHRISTOVA *
*   CALCULATES GAUGE BOSON MASSES, DELTA.R, AND THE WEAK MIXING ANGLE  *
*   OF THE ELECTROWEAK THEORY FOR GIVEN INPUT VALUES, DEPENDING ON IMOMS
*   ( ALL QUANTITIES SHOULD BE GIVEN IN GEV )                          *
*     DIFFERENCE DMZW=MZ-MW. MW0,... MEANS THAT CORRESPONDING          *
*     QUANTITIES ARE CALCULATED AT DR=0, I.E. WITHOUT ELECTROWEAK      *
*     RADIATIVE CORRECTIONS.                                           *
************************************************************************
*
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON/CDZZWG/FMZ,FMH,GMU,A0,GAMZ,GAMW,CALSZ,CALST,CALXI,CALQED
      COMMON/CDZFLG/IHVP,IAMT4,IQCD,IMOMS,IMASS,IALEM,IMASK,IBARB,IFTJR
*
      IF(IMOMS.EQ.1) THEN
       AMZ2=AMZ**2
       AMW2=AMZ2*(1D0+SQRT(1D0-4D0*A0**2/AMZ2))/2D0
       DRP=0D0
       DO 1 ITER=1,20
       CALL CONST2(3,AMW2,AMZ2)
       CALL
     &    SEARCH(IHVP,IAMT4,IQCD,IMASS,IALEM,IBARB,AAFAC,DR,DRBIG,DRREM)
       DRF=DR
       IF(ABS(DRF-DRP).LE.1D-10) GO TO 11
       DRP=DRF
       AMW2=AMZ2*(1D0+SQRT(1D0-4D0*AAFAC**2/AMZ2))/2D0
 1     CONTINUE
 11    DMZW=AMZ-SQRT(AMW2)
       CALL CONST2(3,AMW2,AMZ2)
       SW2=1D0-AMW2/AMZ2
      ELSEIF(IMOMS.EQ.2) THEN
       AMW2=AMW**2
       AMZ2=AMW2/(1D0-A0**2/AMW2)
       DO 2 ITER=1,20
       CALL CONST2(3,AMW2,AMZ2)
       CALL
     &    SEARCH(IHVP,IAMT4,IQCD,IMASS,IALEM,IBARB,AAFAC,DR,DRBIG,DRREM)
       DRF=DR
       IF(ABS(DRF-DRP).LE.1D-7) GO TO 21
       DRP=DRF
       AMZ2=AMW2/(1D0-AAFAC**2/AMW2)
 2     CONTINUE
 21    DMZW=SQRT(AMZ2)-AMW
       CALL CONST2(3,AMW2,AMZ2)
       SW2=1D0-AMW2/AMZ2
      ELSE
       AMW2=AMW**2
       AMZ2=AMZ**2
       CALL CONST2(3,AMW2,AMZ2)
       CALL
     &    SEARCH(IHVP,IAMT4,IQCD,IMASS,IALEM,IBARB,AAFAC,DR,DRBIG,DRREM)
       DMZW=AMZ-AMW
       SW2=1D0-AMW2/AMZ2
      ENDIF
      END
 
      SUBROUTINE CONST1(MQ,FPMT,FPMH)
*
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZZWG/AMZ,AMH,GMU,A0,GAMZ,GAMW,CALSZ,CALST,CALXI,CALQED
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
      COMMON/CDZTHR/AMTH(6)
      DIMENSION AMHF(4),CLMI(8),AMLI(8),AMTI(6)
      DATA CLMI/0.D0,1.D0,0.D0,1.D0,0.D0,1.D0,0.D0,1.D0/
      DATA AMLI/0D0,.51099906D-3,0D0,.105658389D0,0D0,1.7771D0,0D0,0D0/
      DATA AMHF/  1.D0,5.D1,  2.D2,  7.D1/
*                  HNU HLE    TP     BP
      DATA AMTI/2*.134974D0,1.548465D0,.493646D0,0D0,4.73016D0/
*
* NUMERICAL CONSTANTS
      PI=ATAN(1D0)*4D0
      ALFAI=137.035 989 5 D0
      D3=1.2020569031596D0
      PI2=PI**2
      F1=PI2/6D0
      AL1PI=1D0/PI/ALFAI
      AL2PI=AL1PI/2D0
      AL4PI=AL1PI/4D0
* WS-PARAMETERS
      AMH=FPMH
CBARD GMU=1.16637D-5
CBARD GMU=1.166388D-5
      GMU=1.16639D-5
      A0=SQRT(PI/ALFAI/SQRT(2D0)/GMU)
*
C     FERMION PARAMETERS (SEE ALSO DATA)
*
      DO 2 I2=1,6
      CLM(I2) =CLMI(I2)
      AML(I2) =AMLI(I2)
      AMTH(I2)=AMTI(I2)
2     CONTINUE
      AML(7)=AMHF(1)
      AML(8)=AMHF(2)
      DO 1 I=1,4
      CQM(2*I-1)=2.D0/3.D0
1     CQM(2*I)=1.D0/3.D0
      IF(MQ)102,101,100
C IHVP=1 USES THIS SET TOGETHER WITH THE JEGERLEHNER FIT WITH KNIEHL
100   AMQ(1)=.062D0
      AMQ(2)=.083D0
      AMQ(3)=1.50D0
      AMQ(4)=.215D0
      AMQ(5)=FPMT
      AMQ(6)=4.70D0
      AMQ(7)=AMHF(3)
      AMQ(8)=AMHF(4)
      GO TO 103
C FOR YB. MASSES ARE INFLUENTIAL
101   AMQ(1)=.04145D0
      AMQ(2)=.04146D0
      AMQ(3)=1.50D0
      AMQ(4)=0.15D0
      AMQ(5)=FPMT
      AMQ(6)=4.70D0
      AMQ(7)=AMHF(3)
      AMQ(8)=AMHF(4)
      GO TO 103
C USED WITH BURKHARDT'S ROUTINE HADRQQ, XADRQQ
102   AMQ(1)=.04145
      AMQ(2)=.04146
      AMQ(3)=1.50D0
      AMQ(4)=0.15D0
      AMQ(5)=FPMT
      AMQ(6)=4.70D0
      AMQ(7)=AMHF(3)
      AMQ(8)=AMHF(4)
103   CONTINUE
      END
 
      SUBROUTINE CONST2 (NG,FPMW2,FPMZ2)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZZWG/AMZ,AMH,GMU,A0,GAMZ,GAMW,CALSZ,CALST,CALXI,CALQED
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
      COMMON/CDZWSC/SL2,SQ2,W0,W0F,Z0,Z0F,DWZ0R1,DWZ0F,XWM1,XWM1F,XZM1,
     &      XZM1F,XWZ1R1,XDWZ1F,XZFM1,XZFM1F,XAMM1,XAMM1F,XWFM1,XWFM1F
*
* FILL CDZWSM
*
      AMW2=FPMW2
      AMZ2=FPMZ2
      AMH2=AMH**2
      AKSX=AMH/AMZ
      CW2M=AMW2/AMZ2
      SW2M=1.D0-CW2M
      R=AMW2/AMZ2
      R1=1.D0-R
* VECTOR COUPLINGS FOR QCDCOR
      VB=1D0-4D0*CQM(6)*R1
      VT=1D0-4D0*CQM(5)*R1
      VB2=VB**2
      VB2T=1D0-8D0*CQM(6)*R1
      VT2=VT**2
      VT2T=1D0-8D0*CQM(5)*R1
* VECTOR COUPLINGS FOR QCDCOR
      R12=R1**2
      R2=R**2
      R1W=1.D0+R
      R1W2=R1W*R1W
      RW=AMH2/AMW2
      RW1=1.D0-RW
      RW12=RW1**2
      RW2=RW**2
      RZ=AMH2/AMZ2
      RZ1=1.D0-RZ
      RZ12=RZ1**2
      RZ2=RZ**2
      ALR=LOG(R)
      ALRW=LOG(RW)
      ALRZ=LOG(RZ)
*
* FILL FERMIONIC PARTS
*
      SL2=0D0
      SQ2=0D0
      NQ=2*NG
      W0F=0D0
      Z0F=0D0
      XWM1F=(0D0,0D0)
C     T'HOOFT SCALE NOW APPLIED ONLY FOR FERMIONS, CANCELS IN DELTA_R
      AMW2MU=AMW2
C     NEUTRINO PART
      ALRNOR=LOG(AMW2MU/AMZ2)
      XALR=DCMPLX(ALRNOR,PI)
      XZM1F=3D0/R/6D0*(XALR+5D0/3D0)
*
      DO 1 I=1,NG
      AL=LOG(AMW2MU/AML(2*I)**2)
      SL2=SL2+CLM(2*I)**2*AL
      AL=LOG(AMW2MU/AMQ(2*I)**2)
      SQ2=SQ2+3D0*CQM(2*I)**2*AL
      AL=LOG(AMW2MU/AMQ(2*I-1)**2)
      SQ2=SQ2+3D0*CQM(2*I-1)**2*AL
*
      AML2=AML(2*I  )**2
      AMT2=AMQ(2*I-1)**2
      AMB2=AMQ(2*I  )**2
*
      RMLW=AML2/AMW2
      RMTW=AMT2/AMW2
      RMBW=AMB2/AMW2
      ALLW=LOG(AML2/AMW2MU)
      ALTW=LOG(AMT2/AMW2MU)
      ALBW=LOG(AMB2/AMW2MU)
*
      W0F=W0F+1D0/2D0*(RMLW*ALLW-RMLW/2D0)
      Z0F=Z0F+1D0/2D0*RMLW*ALLW
      IF(RMTW.NE.RMBW) THEN
       W0F=W0F+3D0/2D0*((RMTW**2*ALTW-RMBW**2*ALBW)/(RMTW-RMBW)
     *    -(RMTW+RMBW)/2D0)
      ELSE
       W0F=W0F+3D0*(RMTW*ALTW-RMTW/2D0)
      ENDIF
      Z0F=Z0F+3D0/2D0*(RMTW*ALTW+RMBW*ALBW)
*
      XWM1F=XWM1F-2D0*XI3(AMW2MU,-AMW2,AML2,0D0 )
     *     +     RMLW*XI1(AMW2MU,-AMW2,AML2,0D0 )
      XWM1F=XWM1F-6D0*XI3(AMW2MU,-AMW2,AMT2,AMB2)
     *     +3D0*(RMTW*XI1(AMW2MU,-AMW2,AMT2,AMB2)
     *     +     RMBW*XI1(AMW2MU,-AMW2,AMB2,AMT2))
*
      V2PA2L=1D0+(1D0-4D0*R1*CLM(2*I  ))**2
      XZM1F=XZM1F-1D0/2D0*V2PA2L/R*XI3(AMW2MU,-AMZ2,AML2,AML2)
     *     +          1D0/2D0*RMLW*XI0(AMW2MU,-AMZ2,AML2,AML2)
      V2PA2T=1D0+(1D0-4D0*R1*CQM(2*I-1))**2
      V2PA2B=1D0+(1D0-4D0*R1*CQM(2*I  ))**2
      XZM1F=XZM1F-3D0/2D0*V2PA2T/R*XI3(AMW2MU,-AMZ2,AMT2,AMT2)
     *     +          3D0/2D0*RMTW*XI0(AMW2MU,-AMZ2,AMT2,AMT2)
      XZM1F=XZM1F-3D0/2D0*V2PA2B/R*XI3(AMW2MU,-AMZ2,AMB2,AMB2)
     *     +          3D0/2D0*RMBW*XI0(AMW2MU,-AMZ2,AMB2,AMB2)
 1    CONTINUE
*
      DWZ0F =( W0F - Z0F )/R1
      XDWZ1F=(XWM1F-XZM1F)/R1
*
C     DERIVATIVES, USED ONLY IN FORMFACTORS AND PARTIAL WIDTHS
      XWFM1F=XDWF(-AMW2)
      XZFM1F=XDZF(-AMZ2)
      XAMM1F=XAMF(-AMZ2)
*
C     FILL BOSONIC PARTS
*
      XL1=XL(-AMW2,AMH2,AMW2)/AMW2
      XJ1=XJ(-AMW2,AMH2,AMW2)*AMH2
      XL2=XL(-AMW2,AMW2,AMZ2)/AMW2
      XL3=XL(-AMZ2,AMH2,AMZ2)/AMW2
      XJ3=XJ(-AMZ2,AMH2,AMZ2)*AMH2/R
      XL4=XL(-AMZ2,AMW2,AMW2)/AMW2
      R3=R2*R
      W0=5.D0/8.D0/R-17.D0/4.D0+5.D0/8.D0*R*(1.D0+R)-RW/8.D0
     *  +3.D0/4.D0*RW/RW1*ALRW+(3.D0/4.D0/R+9.D0/4.D0-3.D0/R1)*ALR
      Z0=5.D0/8.D0/R-RW/8.D0+3.D0/4.D0/R*ALR+3.D0/4.D0*RW/RZ1*ALRZ
      XWM1=1.D0/12.D0/R2+23.D0/12.D0/R-157.D0/9.D0-RW/2.D0+RW2/12.D0
     *    -RW*(3.D0/4.D0-RW/4.D0+RW2/24.D0)*ALRW
     *    +(1.D0/24.D0/R3+7.D0/12.D0/R2-7.D0/2.D0/R)*ALR
     *    +(0.5D0-RW/6.D0+RW2/24.D0)*XL1
     *    +(1.D0/24.D0/R2+2.D0/3.D0/R-17.D0/6.D0-2.D0*R)*XL2
      XZM1=35.D0/18.D0/R+35.D0/18.D0-34.D0/3.D0*R-8.D0*R2-RW/2.D0
     *    +RW2*R/12.D0+RW*(-3.D0/4.D0+RZ/4.D0-RZ2/24.D0)*ALRZ
     *    +5.D0/6.D0/R*ALR+(0.5D0-RZ/6.D0+RZ2/24.D0)*XL3
     *    +(1.D0/24.D0+2.D0/3.D0*R-17.D0/6.D0*R2-2.D0*R3)*XL4
      DWZ0R1=(W0-Z0)/R1
      XWZ1R1=(XWM1-XZM1)/R1
      XZFM1=-4.D0*R2+17.D0/3.D0*R-23.D0/9.D0+5.D0/18.D0/R-RW/2.D0
     *     +RW*RZ/6.D0-ALR/12.D0/R
     *     +RW*(-3.D0/4.D0+3.D0/8.D0*RZ-RZ2/12.D0)*ALRZ+0.5D0/R*ALRZ
     *     +(-R*R2+7.D0/6.D0*R2-17.D0/12.D0*R-1.D0/8.D0)*XL4
     *     +(0.5D0-5.D0/24.D0*RZ+1.D0/12.D0*RZ2)*XL3+0.5D0*XJ3
      XAMM1=2.D0/9.D0/R+35.D0/18.D0-34.D0/3.D0*R-8.D0*R2
     *     +(1.D0/24.D0+2.D0/3.D0*R-17.D0/6.D0*R2-2.D0*R*R2)*XL4
      XWFM1=R-34.D0/9.D0+2.D0/R+1.D0/6.D0/R2-RW/2.D0+RW**2/6.D0
     *     +(3.D0*R+5.D0/2.D0-17.D0/4.D0/R+7.D0/8.D0/R2+1.D0/12.D0/R3)
     *     *ALR+(0.5D0-3.D0*RW/4.D0+3.D0*RW2/8.D0-RW**3/12.D0)*ALRW
     *     +(-R/2.D0-2.D0+25.D0/24.D0/R+1.D0/12.D0/R2)*XL2
     *     +(0.5D0-5.D0*RW/24.D0+RW2/12.D0)*XL1+0.5D0*XJ1
*
      END
 
      SUBROUTINE SEARCH(IHVP,IAMT4,IQCD,IMASS,IALEM,IBARB,AAFAC,DR,
     $                                                   DRBIG,DRREM)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON /CDZSCT/ ISCRE,ISCAL,IAFMT,IFACR,IFACT,IHIGS
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZZWG/AMZ,AMH,GMU,A0,GAMZ,GAMW,CALSZ,CALST,CALXI,CALQED
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
      COMMON/CDZWSC/SL2,SQ2,W0,W0F,Z0,Z0F,DWZ0R1,DWZ0F,XWM1,XWM1F,XZM1,
     &      XZM1F,XWZ1R1,XDWZ1F,XZFM1,XZFM1F,XAMM1,XAMM1F,XWFM1,XWFM1F
*
      W0AL=W0+W0F
      WM1AL=DREAL(XWM1+XWM1F)
      DWZ1F =R/R1*DREAL(XDWZ1F)
      DWZ1B =R/R1*DREAL(XWZ1R1)
      DWZ1AL=R/R1*DREAL(XWZ1R1+XDWZ1F)
      RXX=-2D0/3D0+4D0/3D0*(SL2+SQ2)+DWZ1AL
     *   +(W0AL-WM1AL-5D0/8D0*R2-5D0/8D0*R+11D0/2D0+9D0/4D0*R/R1*ALR)/R1
      RXXFER=4D0/3D0*(SL2+SQ2)+R/R1*DREAL(XDWZ1F)+(W0F-DREAL(XWM1F))/R1
      RXXBOS=-2D0/3D0+R/R1*DREAL(XWZ1R1)+(W0
     &   -DREAL(XWM1)-5D0/8D0*R2-5D0/8D0*R+11D0/2D0+9D0/4D0*R/R1*ALR)/R1
      AMH=SQRT(AMH2)
      AMW=SQRT(AMW2)
      CLQQCD=0D0
      XTBQCD=DCMPLX(0D0,0D0)
      ALFQCD=0D0
      AMT2=AMQ(5)**2
      SW2=R1
      IF(IQCD.EQ.0) GO TO 4
      ALSZ=CALSZ
      ALST=CALST
      CLQQCD=-AL4PI*(R/R1-1D0)/R1*ALR*ALSZ/PI*(1D0+1.409*ALSZ/PI
     &       -12.805*(ALSZ/PI)**2)
      IF(IQCD-1) 1,2,3
 1    XTBQCD=DCMPLX(0D0,0D0)
      ALFQCD=0D0
      GO TO 4
 2    XTBQCD=AL4PI*DCMPLX(RXQCDS(ALST,SW2,AMT2),0D0)
      XTBQCD=AL4PI*DCMPLX(RXQCDS(ALST,SW2,AMT2),0D0)
      ALFQCD=AL4PI*ALQCDS(ALST,SW2,AMT2)
      GO TO 4
 3    XTBQCD=AL4PI*DCMPLX( RXQCD(ALST,SW2,AMT2),0D0)
      ALFQCD=AL4PI*ALQCD (ALST,SW2,AMT2)
 4    CONTINUE
*
      IF(IHVP-2)5,7,8
*
 5    CONTINUE
      XQQ15=(0D0,0D0)
      DO 6 IQ=1,6
      AMQ2 = AMQ(IQ)*AMQ(IQ)
      IF(IQ.EQ.5) GO TO 6
      XQQ15=XQQ15 + 6D0*XI3(AMQ2,-AMZ2,AMQ2,AMQ2) * 3D0 *CQM(IQ)**2
 6    CONTINUE
      S0=91.176D0**2
cbardin .0273 - .0282 - .0291
cbardin
cbard UDCSB = 0.0282D0+0.002980*(LOG(AMZ2/S0)+0.005696*(AMZ2/S0-1D0))
      UDCSB = 0.0280D0
      IF(IMASS.EQ.0) THEN
       IF(IALEM.EQ.0) THEN
        DR1FER=DREAL(AL4PI*RXXFER - AL4PI*4D0/3D0*XQQ15)
     &        +1-1/ALFAI/CALQED-.0314122001032021937d0
         ELSE
        DR1FER=DREAL(AL4PI*RXXFER - AL4PI*4D0/3D0*XQQ15 + UDCSB )
       ENDIF
       DR1BOS=      AL4PI*RXXBOS
      ELSE
       DR1FER=AL4PI*RXXFER
       DR1BOS=AL4PI*RXXBOS
      ENDIF
      GO TO 10
*
 7    CONTINUE
      DR1FER=AL4PI*RXXFER
      DR1BOS=AL4PI*RXXBOS
      GOTO 10
*
 8    CONTINUE
      XQQ15=(0D0,0D0)
      DO 9 IQ=1,6
      AMQ2 = AMQ(IQ)*AMQ(IQ)
      IF(IQ.EQ.5) GO TO 9
      XQQ15=XQQ15 + 6D0*XI3(AMQ2,-AMZ2,AMQ2,AMQ2) * 3D0 *CQM(IQ)**2
 9    CONTINUE
      XUDSCB = XADRQQ(AMZ2)
*IN XADRQQ FROM H.BURKHARDT: NEG. ARGUMENT=T-CHANL, POSIT. ARG.=S-CHANNE
      IF(IMASS.EQ.0) THEN
       IF(IALEM.EQ.0) THEN
        DR1FER=DREAL(AL4PI*RXXFER - AL4PI*4D0/3D0*XQQ15)
     &        +1-1/ALFAI/CALQED-.0314122001032021937d0
         ELSE
        DR1FER=DREAL(AL4PI*RXXFER - AL4PI*4D0/3D0*XQQ15 + XUDSCB )
       ENDIF
       DR1BOS=      AL4PI*RXXBOS
      ELSE
       DR1FER=AL4PI*RXXFER
       DR1BOS=AL4PI*RXXBOS
      ENDIF
 10   CONTINUE
*
      TBQCDL=0D0
      TBQCD0=0D0
      TBQCD3=0D0
      CORRDR=0D0
      IF(IQCD.NE.0) THEN
       IF(IAFMT.EQ.0) THEN
* Below is the leading term as it is given in \zf (3.73)
        TBQCD0=-CALXI/PI*2D0/3D0*(1D0+PI2/3D0)
        TBQCD3=0D0
        CORRDR=AL4PI/R1**2*AMT2/AMZ2*
     &  (-ALST/PI*(.5D0+PI2/6D0)-.75D0*TBQCD0)
         ELSE
* This coincides with TBQCD0 above if O(\alpha\alpha^2_s)=0
        TBQCD0=AFMT3(CALST)
* Below is pure AFMT-correction to \Delta r (see p.18 PCWG-notebook)
        TBQCD3=-.75D0*AL4PI/R1**2*AMT2/AMZ2
     &          *(TBQCD0-(-ALST/PI*2D0/3D0*(1D0+PI2/3D0)))
        CORRDR=0D0
       ENDIF
       TBQCD = DREAL(XTBQCD)
* Below is -c^2_W/s^2_W \Delta \rho
       TBQCDL= AL4PI*ALST/PI*AMT2/AMW2*R/R1**2*(.5D0+PI2/6D0)
       DR1FER=DR1FER+TBQCD+2D0*CLQQCD+ALFQCD
      ENDIF
*
      DR1=DR1FER+DR1BOS
      DR =DR1
      DRREM = 0D0
C--------------------------------------------------------------------
      IF(IBARB.EQ.0) THEN
       AMT4C=19-2D0*PI2
        ELSEIF(IBARB.EQ.1) THEN
       RBTH=AMT2/AMH2
       ALRB=LOG(RBTH)
       AMT4C=49D0/4D0+PI2+27D0/2D0*ALRB+3D0/2D0*ALRB**2
     &      +RBTH/3D0*(2D0-12D0*PI2+12D0*ALRB-27D0*ALRB**2)
     &  +RBTH**2/48D0*(1613-240*PI2-1500*ALRB-720 *ALRB**2)
        ELSEIF(IBARB.EQ.2) THEN
       RBARB=SQRT(AMH2/AMT2)
       AMT4C=FBARB(RBARB)
      ENDIF
*-----------------------------------------------------------------------
      IF (IAMT4 .EQ. 1) THEN
       IF(IALEM.EQ.0) THEN
        DALFA1=1-1/ALFAI/CALQED
         ELSE
        DALFA1=DREAL(XFOTF1(IHVP,IQCD,0,-AMZ2))*AL4PI
       ENDIF
       DALFA2=AL1PI*AL4PI*(LOG(AMZ2**3/(AML(2)*AML(4)*AML(6))**2)
     &       + 12*D3-5D0/2D0 )
       DALFA = DALFA1+DALFA2
       DRHO1 = .75D0*AL4PI/SW2/R*AMT2/AMZ2
       AXF   = AMT2*GMU/(8D0*PI2*SQRT(2D0))
       DRIRR = 3D0*AXF*(1D0+AMT4C*AXF)
* the leading HIGGS-contribution
       DRHIG1= 0d0
       DRHIGS= 0d0
       fachig= log(amh2/amw2)-5d0/6
       if(ihigs.eq.1.and.fachig.gt.0d0) then
        DRHIG1= al4pi/4/sw2                *11d0/3*fachig
        DRHIGS= sqrt(2d0)*gmu*amw2/16/pi**2*11d0/3*fachig
       endif
* See p.18 of PCWG-notebook
       DRREMF= DR1FER+R/SW2*DRHO1-DALFA1+TBQCD3+CORRDR
       DRREMB= DR1BOS-DRHIG1
       DRREM = DRREMF+DRREMB
       DRBIG=1-(1+R/SW2*DRIRR-DRHIGS)*(1D0-DALFA)
* end of HIGGS-modification
       DR=DRBIG+DRREM
       RENORD=SQRT(2D0)*GMU*AMZ2*R1*R*(1D0-DRBIG)/PI*ALFAI
       RENORM=SQRT(2D0)*GMU*AMZ2*R1*R*(1D0-DALFA)/PI*ALFAI
       IF(ISCRE.EQ.0) SCALER=1.00D0
       IF(ISCRE.EQ.1) SCALER=RENORD
       IF(ISCRE.EQ.2) SCALER=RENORM
       DR=DRBIG+SCALER*DRREM
cbardin
cbard  print *,'DALFA1=',dalfa1
cbard  print *,'DALFA2=',dalfa2
cbard  print *,'DALFA =',dalfa
cbard  print *,'DRRHO =',-R/SW2*DRIRR
cbard  print *,'DRBIG =',drbig
cbard  print *,'DRREM =',drrem
cbard  print *,'DRRES =',-R/SW2*DRIRR+DRHIGS+SCALER*DRREM/(1D0-DALFA)
cbard  print *,'DR    =',dr
*-----------------------------------------------------------------------
      ELSEIF(IAMT4 .EQ. 2) THEN
       IF(IALEM.EQ.0) THEN
        DALFA1=1-1/ALFAI/CALQED
         ELSE
        DALFA1=DREAL(XFOTF1(IHVP,IQCD,0,-AMZ2))*AL4PI
       ENDIF
       DALFA2=AL1PI*AL4PI*(LOG(AMZ2**3/(AML(2)*AML(4)*AML(6))**2)
     &       + 12*D3-5D0/2D0 )
       DALFA = DALFA1+DALFA2
       DRHO1 = .75D0*AL4PI/SW2/R*AMT2/AMZ2
       AXF   = AMT2*GMU/(8D0*PI2*SQRT(2D0))
       DRIRR = 3D0*AXF*(1D0+AMT4C*AXF+TBQCD0)
* the leading HIGGS-contribution
       DRHIG1= 0d0
       DRHIGS= 0d0
       fachig= log(amh2/amw2)-5d0/6
       if(ihigs.eq.1.and.fachig.gt.0d0) then
        DRHIG1= al4pi/4/sw2                *11d0/3*fachig
        DRHIGS= sqrt(2d0)*gmu*amw2/16/pi**2*11d0/3*fachig
       endif
       DRREMF= DR1FER+R/SW2*DRHO1-DALFA1-TBQCDL
       DRREMB= DR1BOS-DRHIG1
       DRREM = DRREMF+DRREMB
       DRHHS = -.005832*(AL1PI)**2/SW2**2*AMH2/AMW2
       DRREM = DRREM+DRHHS
       DRBIG=1D0-(1D0+R/SW2*DRIRR-DRHIGS)*(1D0-DALFA)
* end of HIGGS-modification
       DR=DRBIG+DRREM
       RENORM=SQRT(2D0)*GMU*AMZ2*R1*R*(1D0-DALFA)/PI*ALFAI
       RENORD=SQRT(2D0)*GMU*AMZ2*R1*R*(1D0-DRBIG)/PI*ALFAI
       IF(ISCRE.EQ.0) SCALER=1.00D0
       IF(ISCRE.EQ.1) SCALER=RENORD
       IF(ISCRE.EQ.2) SCALER=RENORM
       DR=DRBIG+SCALER*DRREM
*-----------------------------------------------------------------------
      ELSEIF(IAMT4 .EQ. 3) THEN
       IF(IALEM.EQ.0) THEN
        DALFA1=1-1/ALFAI/CALQED
         ELSE
        DALFA1=DREAL(XFOTF1(IHVP,IQCD,0,-AMZ2))*AL4PI
       ENDIF
       DALFA2=AL1PI*AL4PI*(LOG(AMZ2**3/(AML(2)*AML(4)*AML(6))**2)
     &       + 12*D3-5D0/2D0 )
       DALFA =DALFA1+DALFA2
       DRHO1 = .75D0*AL4PI/SW2/R*AMT2/AMZ2
       AXF   = AMT2*GMU/(8D0*PI2*SQRT(2D0))
       DRIRR = 3D0*AXF*(1D0+AMT4C*AXF+TBQCD0)
       SCALE = AL4PI/R1*(-ALR*(41D0/6D0-11D0/3D0*R))
* the leading HIGGS-contribution  (FOR IAMT4=3 11/12 --> 1/12)
       DRHIG1= 0d0
       DRHIGS= 0d0
       fachig= log(amh2/amw2)-5d0/6
       if(ihigs.eq.1.and.fachig.gt.0d0) then
        DRHIG1= al4pi/4/sw2                * 1d0/3*fachig
        DRHIGS= sqrt(2d0)*gmu*amw2/16/pi**2* 1d0/3*fachig
       endif
       DRREM = DR1FER+DR1BOS-DALFA1-TBQCDL-DWZ1AL*AL4PI+SCALE-DRHIG1
       DRHHS = -.005832*(AL1PI)**2/SW2**2*AMH2/AMW2
       DRREM = DRREM+DRHHS
       RENORM=SQRT(2D0)*GMU*AMZ2*R1*R*(1D0-DALFA)/PI*ALFAI
       DRBIG=1D0-(1D0+R/SW2*DRIRR-DRHIGS)*(1D0-DALFA)
     &   +(AL4PI*DWZ1AL-SCALE+R/SW2*DRHO1)*RENORM
* end of HIGGS-modification
       DR=DRBIG+SCALER*DRREM
       RENORD=SQRT(2D0)*GMU*AMZ2*R1*R*(1D0-DRBIG)/PI*ALFAI
       IF(ISCRE.EQ.0) SCALER=1.00D0
       IF(ISCRE.EQ.1) SCALER=RENORD
       IF(ISCRE.EQ.2) SCALER=RENORM
       DR=DRBIG+SCALER*DRREM
cbardin
cbard  print *,'DALFA1=',dalfa1
cbard  print *,'DALFA2=',dalfa2
cbard  print *,'DALFA =',dalfa
cbard  print *,'DRRHO =',-R/SW2*DRIRR
cbard  print *,'DRBIG =',drbig
cbard  print *,'DRREM =',drrem
cbard  print *,'DRRES =',-R/SW2*DRIRR+DRHIGS+SCALER*DRREM/(1D0-DALFA)
cbard  print *,'DR    =',dr
      ENDIF
      IF(IFACR.EQ.0) THEN
       AAFAC=A0/SQRT(1D0-DR)
      ELSEIF(IFACR.EQ.1) THEN
       AAFAC=A0*SQRT(1/(1-DRBIG)*(1+SCALER*DRREM/(1-DRBIG)))
      ELSEIF(IFACR.EQ.2) THEN
       AAFAC=A0*SQRT((1+SCALER*DRREM)/(1D0-DRBIG))
      ELSEIF(IFACR.EQ.3) THEN
       AAFAC=A0*SQRT(1/(1D0-DRBIG)+SCALER*DRREM)
        ELSE
cbard  PRINT *,'WRONG IFACR'
      ENDIF
*
      END
 
      FUNCTION XADRQQ(S)
C  HADRONIC IRREDUCIBLE QQ SELF-ENERGY: TRANSVERSE
C     PARAMETRIZE THE REAL PART OF THE PHOTON SELF ENERGY FUNCTION
C     BY  A + B LN(1+C*:S:) , AS IN MY 1981 TASSO NOTE BUT USING
C     UPDATED VALUES, EXTENDED USING RQCD UP TO 100 TEV
C     FOR DETAILS SEE:
C     H.BURKHARDT, F.JEGERLEHNER, G.PENSO AND C.VERZEGNASSI
C     IN CERN YELLOW REPORT ON "POLARIZATION AT LEP" 1988
C     H.BURKHARDT, CERN/ALEPH, AUGUST 1988
C     NEGATIVE VALUES MEAN T - CHANNEL (SPACELIKE)
C     POSITIVE VALUES MEAN S - CHANNEL (TIMELIKE )
C     IN THE SPACE LIKE VALUES AROUND 1 GEV ARE TYPICAL FOR LUMINOSITY
C     THE VALUES AT 92 GEV ( Z MASS ) GIVE THE LIGHT QUARK CONTRIBUTION
C     TO DELTA R
C     TAKE CARE OF THE SIGN OF REPI WHEN USING THIS IN DIFFERENT
C     PROGRAMS
C     HERE REPI WAS CHOSEN TO
C     BE POSITIVE (SO THAT IT CORRESPONDS DIRECTLY TO DELTA ALPHA)
C     OFTEN ITS ASSUMED TO BE NEGATIVE.
C
C     THE IMAGINARY PART IS PROPORTIONAL TO R (HAD / MU CROSS SECTION)
C     AND IS THEREFORE 0 BELOW THRESHOLD ( IN ALL THE SPACELIKE REGION)
C     NOTE ALSO THAT ALPHA_S USUALLY HAS BEEN DERIVED FROM THE MEASURED
C     VALUES OF R.
C     CHANGING ALPHA_S TO VALUES INCOMPATIBLE WITH CURRENT DATA
C     WOULD IMPLY TO BE ALSO INCONSISTENT WITH RE,IM PI
C     DEFINED HERE
C
C     H.BURKHARDT
C
      IMPLICIT REAL*8(A-H,O-Z)
      COMPLEX*16 XADRQQ
C
      DATA A1,B1,C1/   0.0   ,  0.00835,  1.0  /
      DATA A2,B2,C2/   0.0   ,  0.00238,  3.927 /
      DATA A3,B3,C3/ 0.00165 ,  0.00300,  1.0  /
      DATA A4,B4,C4/ 0.00221 ,  0.00293,  1.0  /
C
      DATA PI/3.141592653589793D0/,ALFAIN/137.0359895D0/,INIT/0/
C
      IF(INIT.EQ.0) THEN
        INIT=1
        ALFA=1./ALFAIN
        ALFAPI=1./PI/ALFAIN
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
C     AS IMAGINARY PART TAKE -I ALFA/3 REXP
      XADRQQ=REPIAA-(0.,1.)*ALFA/3.*REXP(S)
CEXPO HADRQQ=HADRQQ/(4.D0*PI*ALFA)  ! EXPOSTAR DIVIDES BY 4 PI ALFA
      END
 
      FUNCTION REXP(S)
C  HADRONIC IRREDUCIBLE QQ SELF-ENERGY: IMAGINARY
      IMPLICIT REAL*8(A-H,O-Z)
C     CONTINUUM R = AI+BI W ,  THIS + RESONANCES WAS USED TO CALCULATE
C     THE DISPERSION INTEGRAL. USED IN THE IMAG PART OF HADRQQ
      PARAMETER (NDIM=18)
      DIMENSION WW(NDIM),RR(NDIM),AA(NDIM),BB(NDIM)
      DATA WW/1.,1.5,2.0,2.3,3.73,4.0,4.5,5.0,7.0,8.0,9.,10.55,
     . 12.,50.,100.,1000.,10 000.,100 000./
      DATA RR/0.,2.3,1.5,2.7,2.7,3.6,3.6,4.0,4.0,3.66,3.66,3.66,
     .  4.,3.87,3.84, 3.79, 3.76,    3.75/
      DATA INIT/0/
      IF(INIT.EQ.0) THEN
        INIT=1
C CALCULATE A,B FROM STRAIGHT LINES BETWEEN R MEASUREMENTS
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
C      FIND OUT BETWEEN WHICH POINTS OF THE RR ARRAY W IS
       K=I
       IF(I.LT.NDIM) THEN
       IF(W.LT.WW(I+1)) GOTO 3
       ENDIF
    2  CONTINUE
    3  CONTINUE
       REXP=AA(K)+BB(K)*W
C   WRITE(6,'('' K='',I2,'' AA='',F10.2,'' BB='',F10.3)')
C    .   K,AA(K),BB(K)
       ENDIF
      ENDIF
      END
 
      SUBROUTINE ZWRATE(DR,DRBIG,DRREM,QCDCOR,PARTZ,PARTW)
************************************************************************
*  ZWRATE - Z- AND W- BOSONS DECAY RATES, CALCULATES PARTIAL AND TOTAL *
*  WIDTHS OF Z- AND W- BOSONS WITH ACCOUNT OF ALL 1-LOOP ELECTROWEAK   *
*  AND QED CORRECTIONS (QCD CORRECTIONS ARE ALSO INCLUDED).            *
*  FORTRAN CODES ARE WRITTEN BY D. YU. BARDIN, S.&T. RIEMANN ON THE    *
*  BASIS OF TWO PAPERS:                                                *
*  1) A.A.AKHUNDOV, D.YU.BARDIN AND T.RIEMANN                          *
*     "ELECTROWEAK ONE-LOOP CORRECTIONS TO THE DECAY OF THE NEUTRAL    *
*      VECTOR BOSON", NUCLEAR PHYSICS B276 (1986) P1;                  *
*  2) D.YU.BARDIN, S.RIEMANN AND T.RIEMANN                             *
*     "ELECTROWEAK ONE-LOOP CORRECTIONS TO THE DECAY OF THE CHARGED    *
*      VECTOR BOSON", Z.PHYS.C 32 (1986) P121.                         *
*  (FOR MORE DETAILS SEE REFERRED PAPERS AND COMMENTS IN THE BODIES OF *
*  PROGRAM ZWRATE AND SUBROUTINE SETCON.                               *
************************************************************************
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      DIMENSION AQFI(10),MCOLFZ(10),PARTZ(0:11),PARTW(3),QCDCOR(0:14)
      DIMENSION INDF(10),INDL(10),INDQ(10)
      DIMENSION MWFAC(2),AQFW(2)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZFLG/IHVP,IAMT4,IQCD,IMOMS,IMASS,IALEM,IMASK,IBARB,IFTJR
      COMMON /CDZSCT/ ISCRE,ISCAL,IAFMT,IFACR,IFACT,IHIGS
      COMMON/CDZZWG/AMZ,AMH,GMU,A0,GAMZ,GAMW,CALSZ,CALST,CALXI,CALQED
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
      COMMON/CDZTHR/AMTH(6)
      COMMON/CDZRKZ/ARROFZ(0:10),ARKAFZ(0:10),ARVEFZ(0:10),ARSEFZ(0:10)
      DATA MWFAC/3,6/
      DATA INDF /2,1,1,1,4,3,4,3,4,5/
      DATA INDL /1,2,4,6,0,0,0,0,0,0/
      DATA INDQ /0,0,0,0,1,2,3,4,5,6/
      DATA MCOLFZ/1,1,1,1,3,3,3,3,3,3/
* MWFAC AND MZFAC - FLAVOUR*COLOR FACTORS FOR W- AND Z- DECAYS
*
      AQFI(1)=0.D0
      AQFI(2)=1.D0
      AQFI(3)=1.D0
      AQFI(4)=1.D0
      AQFI(5)=2.D0/3.D0
      AQFI(6)=1.D0/3.D0
      AQFI(7)=2.D0/3.D0
      AQFI(8)=1.D0/3.D0
      AQFI(9)=2.D0/3.D0
      AQFI(10)=1.D0/3.D0
* AQFI - ARRAY OF FINAL PARTICLE CHARGES FOR PARTIAL Z- WIDTHS%
* T,TBAR DECAY CHANNEL IS ASSUMED TO BE ABOVE Z- THRESHOLD AND IS
* NOT ADDED TO THE TOTAL Z- WIDTH
      AQFW(1)=1.D0
      AQFW(2)=2.D0/3.D0
* THE SAME FOR PARTIAL W- WIDTHS, HERE ONLY TWO CHANNELS EXIST IF ONE
* NEGLECTS FERMION MASSES. AGAIN T,BBBAR DECAY CHANNEL IS ASSUMED TO BE
      GAM0T=0.D0
      GAM0H=0.D0
      GAMWT=0.D0
      GAM1H=0.D0
      GAM1T=0.D0
      CONSTZ=GMU*AMZ**3/12.D0/PI/SQRT(2.D0)
* LOOP ON FERMIONS IN Z DECAY
*
      DO 3 INF=1,10
      CALL VERTZW(1,INDF(INF))
* THIS IS SOME INITIALIZATION SUBROUTINE FOR SUBSEQUENT CALCULATION
* OF THE ELECTROWEAK FORMFACTORS (SEE BELOW)
      IBFLA=0
      IF(INF.EQ.10) IBFLA=1
      CALL ROKAPP(AQFI(INF),IBFLA,DR,DRBIG,DRREM,ROFACI,ROFACL,ROFACR,
     &                                    SCALER,AKFACI,AKFACL,AKFACR)
* SUBROUTINE RETURNS EW-FORMFACTORS RO AND KAPPA (FOR THEIR DEFINITIONS
* SEE REF.1) )
      RAT=0D0
      SQR=1D0
      IF(INF.LE.4) THEN
       RAT=AML(INDL(INF))**2/AMZ2
      ELSEIF(INF.NE.9.AND.
     &  INF.GT.4.AND.ABS(QCDCOR((MAX(0,2*INDQ(INF)-1)))-1).LT.1D-8) THEN
       RAT=AMQ(INDQ(INF))**2/AMZ2
      ENDIF
      SQR=SQRT(1-4*RAT)
      IF(INF.EQ.9) SQR=0D0
      IF(INF.LE.4.OR.ABS(QCDCOR((MAX(0,2*INDQ(INF)-1)))-1).LT.1D-8) THEN
       RQCDV=1D0+0.75D0*CALQED/PI*AQFI(INF)**2
       RQCDA=RQCDV
        ELSE
       RQCDV=QCDCOR(MAX(0,2*INDQ(INF)-1))
       RQCDA=QCDCOR(MAX(0,2*INDQ(INF)  ))
      ENDIF
* GAM0I - PARTIAL WIDTH FOR I-TH CHANNEL IN THE BORN APPROXIMATION
cbardinVF0L=1-4*SW2M*AQFI(INF)
       VF0L=1-4*.23118d0*AQFI(INF)
       GAM0I=CONSTZ*SQR*((1+2*RAT)*(VF0L**2*RQCDV+RQCDA)/2-3*RAT*RQCDA)
* GAMWI - THE SAME BUT INCLUDING NON QED ELECTROWEAK 1-LOOP CORRECTIONS
* GAM1I - THE SAME BUT INCLUDING QED AND QCD CORRECTIONS TOO
      IF(IFACT.LE.3) THEN
       VF1L=1-4*SW2M*AQFI(INF)*AKFACI
       GAMWI=CONSTZ*ROFACI*SQR*((1+2*RAT)*(VF1L**2+1)/2-3*RAT)
       GAM1I=CONSTZ*ROFACI*SQR*((1+2*RAT)*(VF1L**2*RQCDV+RQCDA)/2
     &                            -3*RAT*RQCDA)
c      if(inf.eq.2) then
c       sineff=sw2m*akfaci
c       sinbor=sw2m*akfacl
c       seff =1-4*sineff
c       sbor =1-4*sinbor
c       s11=(seff-sbor)*pi/calqed
c       amtop=amq(5)
c    &                      SCALER,AKFACI,AKFACL,AKFACR
12319 format(1x,10(d12.5,1x))
12320 format(1x,'ISCRE,ISCAL,IAFMT,IFACR,IFACT,IHIGS=',6i2)
12321 format(1x,'IAMT4,m_t,s_eff,s_bor,X,X_0,X_1=',i1,2x,f5.1,5(f11.5))
c      endif
      ELSEIF(IFACT.EQ.4) THEN
       ROFACL=ROFACI
       AKFACL=AKFACI
       ROFACR=SCALER*ROFACR
       AKFACR=SCALER*AKFACR
       AKFACI=AKFACL+AKFACR
       VF1LL=1-4*SW2M*AQFI(INF)*AKFACL
       VF1LR= -4*SW2M*AQFI(INF)*AKFACR
       GAMWI=CONSTZ*SQR*(ROFACL*((1+2*RAT)*( VF1LL**2+2*VF1LL*VF1LR+1)/2
     &                                                      -3*RAT)
     &                  +ROFACR*((1+2*RAT)*( VF1LL**2+1 )/2 -3*RAT)    )
       GAM1I=CONSTZ*SQR*(ROFACL*((1+2*RAT)*((VF1LL**2+2*VF1LL*VF1LR)/2
     &                                    *RQCDV+RQCDA/2)-3*RAT*RQCDA)
     &                  +ROFACR*((1+2*RAT)*( VF1LL**2/2
     &                                    *RQCDV+RQCDA/2)-3*RAT*RQCDA) )
      ELSEIF(IFACT.EQ.5) THEN
       ROFACL=ROFACI
       AKFACL=AKFACI
       ROFACR=SCALER*ROFACR
       AKFACR=SCALER*AKFACR
       AKFACI=AKFACL+AKFACR
       VF1LL=1-4*SW2M*AQFI(INF)*AKFACL
       VF1LR= -4*SW2M*AQFI(INF)*AKFACR
       GAMWI=CONSTZ*SQR*(ROFACL*((1+2*RAT)*( VF1LL**2+2*VF1LL*VF1LR+1)/2
     &                                                      -3*RAT)
     &                  +ROFACR*((1+2*RAT)*( VF1LL**2+1 )/2 -3*RAT)    )
       GAM1I=CONSTZ*SQR*(ROFACL*((1+2*RAT)*((VF1LL**2              )/2
     &                                      *RQCDV+RQCDA/2)-3*RAT*RQCDA)
     &                  +ROFACL*((1+2*RAT)*VF1LL*VF1LR)
     &                  +ROFACR*((1+2*RAT)*( VF1LL**2+1)/2 -3*RAT)     )
      ENDIF
      NCF=1
      IF(INF.EQ.1) NCF=3
      GAM0T=GAM0T+GAM0I*MCOLFZ(INF)*NCF
      GAMWT=GAMWT+GAMWI*MCOLFZ(INF)*NCF
      IF(INF.GT.4) GAM0H=GAM0H+GAM0I*MCOLFZ(INF)*NCF
      IF(INF.GT.4) GAM1H=GAM1H+GAM1I*MCOLFZ(INF)*NCF
      GAM1T=GAM1T+GAM1I*MCOLFZ(INF)*NCF
cbardin PARTZ(INF-1)=GAM1I*1D3*MCOLFZ(INF)
cb    ARROFZ(INF-1)=ROFACI
cb    ARVEFZ(INF-1)=1D0-4D0*SW2M*AKFACI*AQFI(INF)
cb    ARSEFZ(INF-1)=AKFACI*SW2M
cb    ARKAFZ(INF-1)=AKFACI
cbardin
      PARTZ(INF-1)=GAM0I*1D3*MCOLFZ(INF)
      ARROFZ(INF-1)=1D0
      ARVEFZ(INF-1)=1D0-4D0*.23118d0*AQFI(INF)
      ARSEFZ(INF-1)=.23118d0
      ARKAFZ(INF-1)=1D0
* GAM.T - CORRESPONDING TOTAL Z- WIDTHS WITHIN DIFFERENT APPROXIMATIONS
3     CONTINUE
*
* END LOOP ON FERMIONS IN Z DECAY
*
      GAMZ = GAM1T
      GAM1TZ=GAM1T
      CORVEC=CONSTZ*3D0/2*(QCDCOR(13)-1)*1D3
cb    PARTZ(10)=GAM1H*1D3
cb    PARTZ(11)=GAM1T*1D3
      PARTZ(10)=GAM0H*1D3
      PARTZ(11)=GAM0T*1D3
* END OF Z- WIDTHS CALCULATION
*
************************************************************************
*
* W- CHAIN STARTS HERE, IT IS QUITE SIMILAR TO Z- CHAIN, FOR THIS
* REASON ONLY BRIEF ADDITIONAL COMMENTS ARE ADDED BELOW
*
      CALL VERTZW(0,0)
      AMW=SQRT(AMW2)
      CONSTW=GMU*AMW**3/6.D0/PI/SQRT(2.D0)
      GAM0T=0.D0
      GAM1T=0.D0
      DO 7 IND=1,2
      CALL PROW (AQFW(IND),ROW)
* THIS SUBROUTINE RETURNS THE ONLY ONE ELECTROWEAK FORMFACTOR ROW
* (FOR ITS DEFINITION SEE REF.2) ) EXISTING IN THE W- DECAY CASE.
* THE OTHER IMPORTANT DIFFERENCE FROM Z- CASE IS THAT IT IS IMPOSSIBLE T
* DEFINE HERE QED- GAUGE INVARIANT SUBSET OF DIAGRAMS, FOR THIS REASON
* ONLY TOTAL 1-LOOP GAMMAS AND WIDTHS ARE CALCULATED FOR W- DECAY
* (FOR PHYSICAL EXPLANATION OF THIS PHENOMENA SEE AGAIN REF.2) )
      GAM0I=CONSTW
      GAM1I=CONSTW*ROW
      DELT1I=(GAM1I/GAM0I-1.D0)*100.D0
      GAM0T=GAM0T+GAM0I*MWFAC(IND)
      GAM1T=GAM1T+GAM1I*MWFAC(IND)*QCDCOR(IND-1)
      PARTW(IND)=GAM1I*(2*IND-1)*1D3
7     CONTINUE
      DELT1T=(GAM1T/GAM0T-1.D0)*100.D0
10    CONTINUE
      GAMW = GAM1T
      PARTW(3)=GAMW*1D3
      END
 
      SUBROUTINE ROKAPP(CH ,IBFLA,DR,DRBIG,DRREM,ROFACI,ROFACL,ROFACR,
     & SCALER,AKFACI,AKFACL,AKFACR)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZFLG/IHVP,IAMT4,IQCD,IMOMS,IMASS,IALEM,IMASK,IBARB,IFTJR
      COMMON /CDZSCT/ ISCRE,ISCAL,IAFMT,IFACR,IFACT,IHIGS
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
      COMMON/CDZZWG/AMZ,AMH,GMU,A0,GAMZ,GAMW,CALSZ,CALST,CALXI,CALQED
      COMMON/CDZWSC/SL2,SQ2,W0,W0F,Z0,Z0F,DWZ0R1,DWZ0F,XWM1,XWM1F,XZM1,
     &      XZM1F,XWZ1R1,XDWZ1F,XZFM1,XZFM1F,XAMM1,XAMM1F,XWFM1,XWFM1F
      COMMON/CDZVZW/V1,V2,CT,VTB,V1ZZ,V1ZW,V2ZWW,VCT0,
     *      V1ZZC,V1ZWC,V2ZWWC,VCT0C,V1WZ,V2WWZ
*
      CH2=CH*CH
      ZM1A=DREAL(XZM1+XZM1F)
      ZFM1A=DREAL(XZFM1+XZFM1F)
      W0A=W0+W0F
      RO1=AL4PI*((ZM1A+ZFM1A)/R1-(W0A-5.D0/8.D0*R2-5.D0/8.D0*R
     *   +11.D0/2.D0+9.D0/4.D0*R/R1*ALR)/R1
     *   +(0.5D0/R/R1-3.D0/R*CH+6.D0*R1/R*CH2)*V1ZZC
     *   +((1.D0-2.D0*R)/R1-2.D0*CH)*V1ZWC+2.D0*R/R1*V2ZWWC
     *   +2.D0*VCT0C/R1)
      WM1A=DREAL(XWM1+XWM1F)
      AMM1A=DREAL(XAMM1+XAMM1F)
      AK1=-AL4PI*(R/R12*(WM1A-ZM1A)-AMM1A/R1
     *   +(0.25D0/R/R1-1.5D0/R*CH+2.*R1/R*CH2)*V1ZZC
     *   +((0.5D0-R)/R1-CH)*V1ZWC+R/R1*V2ZWWC+VCT0C/R1)
* QCD-CORRECTIONS TO Z-WIDTH
      ALSZ=CALSZ
      ALST=CALST
      SW2=R1
      SSZ =AMZ2
      ROQCD = 0D0
      AKQCD = 0D0
      AMT2=AMQ(5)**2
      ROQCD=0D0
      AKQCD=0D0
      IF(IQCD-1) 3,1,2
 1    ROQCD=AL4PI*DREAL(XRQCDS(ALST,SW2,AMT2,SSZ))
      AKQCD=AL4PI*DREAL(XKQCDS(ALST,SW2,AMT2,SSZ))
      GOTO 3
 2    ROQCD=AL4PI*DREAL(XROQCD(ALSZ,ALST,SW2,AMT2,SSZ))
      AKQCD=AL4PI*DREAL(XKAQCD(ALST,SW2,AMT2,SSZ))
 3    CONTINUE
C-----------------------------------------------------------------------
C 13/10/1992 - Barbieri's m_t^4 are implemented
      IF(IBARB.EQ.0) THEN
       AMT4C=19-2D0*PI2
       AMT4B=(27-PI2)/3
        ELSEIF(IBARB.EQ.1) THEN
       RBTH=AMT2/AMH2
       ALRB=LOG(RBTH)
       AMT4C=49D0/4D0+PI2+27D0/2D0*ALRB+3D0/2D0*ALRB**2
     &      +RBTH/3D0*(2D0-12D0*PI2+12D0*ALRB-27D0*ALRB**2)
     &  +RBTH**2/48D0*(1613-240*PI2-1500*ALRB-720 *ALRB**2)
       AMT4B=1D0/144*(311D0+24*PI2+282*ALRB+90*ALRB**2
     &      -4D0*RBTH*(40D0+ 6*PI2+ 15*ALRB+18*ALRB**2)
     &      +3D0*RBTH**2*(242.09D0-60*PI2-454.2D0*ALRB-180*ALRB**2))
        ELSEIF(IBARB.EQ.2) THEN
       RBARB=SQRT(AMH2/AMT2)
       AMT4C=FBARB (RBARB)
       AMT4B=FBARBB(RBARB)
      ENDIF
C---- CORBB =-2*TOPX2*(1+TOPX2*AMT4B)+AL1PI/8/SW2*AMT2/AMW2
      TOPX2 = GMU*AMT2/DSQRT(2.D0)/8.D0/PI2
      TAUBB1=-2*TOPX2*(1-PI/3*CALST*IFTJR)
      TAUBB2=-2*TOPX2*( +TOPX2*AMT4B)
      CORBB =+AL1PI/8/SW2*AMT2/AMW2
      ROFACI=1D0+RO1+ROQCD
      AKFACI=1D0+AK1+AKQCD
      ROFACM=ROFACI
      AKFACM=AKFACI
      IF(IALEM.EQ.0) THEN
       DALFA=1-1/ALFAI/CALQED
        ELSE
       DALFA1=DREAL(XFOTF1(IHVP,IQCD,0,-AMZ2))*AL4PI
       DALFA2=AL1PI*AL4PI*(LOG(AMZ2**3/(AML(2)*AML(4)*AML(6))**2)
     &       + 12*D3-5D0/2D0 )
       DALFA =DALFA1+DALFA2
      ENDIF
      RENORD=SQRT(2D0)*GMU*AMZ2*R1*R/PI*ALFAI
      RENORM=SQRT(2D0)*GMU*AMZ2*R1*R/PI*ALFAI
      IF(ISCRE.EQ.0) SCALER=1.00D0
      IF(ISCRE.EQ.1) SCALER=RENORD
      IF(ISCRE.EQ.2) SCALER=RENORM
C---- without Zbb-vertex -----------------------------------------------
      ROFACI=1D0+RO1+ROQCD+2*CORBB*IBFLA
      AKFACI=1D0+AK1+AKQCD-  CORBB*IBFLA
      IF (IAMT4 .EQ. 1) THEN
       DRHOT = .75D0*AL4PI/SW2/R*AMT2/AMZ2
       TOPX2 = GMU*AMT2/DSQRT(2.D0)/8.D0/PI2
       DRHOT4=3D0*TOPX2*(1D0+TOPX2*AMT4C)
       IF(IQCD.EQ.0) THEN
        TBQCD0=0D0
        TBQCD3=0D0
        CORRXI=0D0
         ELSE
          IF(IAFMT.EQ.0) THEN
* Below is the leading term as it is given in \zf (3.71)
           TBQCD0=.75D0*AL4PI/R/SW2*AMT2/AMZ2
     &           *(-CALXI/PI*2D0/3D0*(1D0+PI2/3D0))
           TBQCDL=.75D0*AL4PI/R/SW2*AMT2/AMZ2
     &           *(-CALST/PI*2D0/3D0*(1D0+PI2/3D0))
           CORRXI=-TBQCDL+TBQCD0
           TBQCD3=0D0
            ELSE
* This coincides with TBQCD0 above if O(\alpha\alpha^2_s)=0
           TBQCD0=AFMT3(CALST)
* Below is pure AFMT-correction to \Delta \rho (see p.18 PCWG-notebook)
           TBQCD3=.75D0*AL4PI/R/SW2*AMT2/AMZ2
     &          *(TBQCD0-(-CALST/PI*2D0/3D0*(1D0+PI2/3D0)))
           CORRXI=0D0
          ENDIF
       ENDIF
       ROFACL=1/(1-DRHOT4)
       AKFACL=(1+R/SW2*DRHOT4)
       ROFACR=ROFACI-      DRHOT-1 +       TBQCD3+CORRXI
       AKFACR=AKFACI-R/SW2*DRHOT-1 +R/SW2*(TBQCD3+CORRXI)
c      if(ch.gt..7d0) then
c      endif
      ELSEIF(IAMT4 .EQ. 2) THEN
       DRHOT = .75D0*AL4PI/SW2/R*AMT2/AMZ2
       TOPX2 = GMU*AMT2/DSQRT(2.D0)/8.D0/PI2
       DRHOT4=3D0*TOPX2*(1D0+TOPX2*AMT4C)
       IF(IQCD.EQ.0) THEN
        TBQCD0=0D0
        TBQCDL=0D0
         ELSE
          IF(IAFMT.EQ.0) THEN
           TBQCD0=-TOPX2*CALXI/PI*2D0*(1D0+PI2/3D0)
            ELSE
           TBQCD0=3*TOPX2*AFMT3(CALST)
          ENDIF
        TBQCDL=-AL4PI*ALST/PI*AMT2/AMW2/R1*(.5D0+PI2/6D0)
       ENDIF
       ROFACL=1/(1-DRHOT4-TBQCD0)
       AKFACL=(1+R/SW2*(DRHOT4+TBQCD0))
       ROFACR=ROFACI       -DRHOT-TBQCDL -1
       AKFACR=AKFACI-R/SW2*(DRHOT+TBQCDL)-1
      ELSEIF(IAMT4 .EQ. 3) THEN
       DWZ1AL=R/R1*DREAL(XWZ1R1+XDWZ1F)
       RENORM=SQRT(2D0)*GMU*AMZ2*R1*R/PI*ALFAI
       SCALE = AL4PI/R1*(-ALR*(41D0/6D0-11D0/3D0*R))
       CORKAP=AL4PI*DWZ1AL-SCALE+.75D0*AL4PI/SW2**2*AMT2/AMZ2
       DRHOT =.75D0*AL4PI/SW2/R*AMT2/AMZ2
       TOPX2 =GMU*AMT2/DSQRT(2.D0)/8.D0/PI2
       DRHOT4=3D0*TOPX2*(1D0+TOPX2*AMT4C)
       IF(IQCD.EQ.0) THEN
        TBQCD0=0D0
        TBQCDL=0D0
         ELSE
          IF(IAFMT.EQ.0) THEN
           TBQCD0=-TOPX2*CALXI/PI*2D0*(1D0+PI2/3D0)
            ELSE
           TBQCD0=3*TOPX2*AFMT3(CALST)
          ENDIF
        TBQCDL=-AL4PI*ALST/PI*AMT2/AMW2/R1*(.5D0+PI2/6D0)
       ENDIF
       ROFACL=1/(1-DRHOT4-TBQCD0)
       AKFACL=(1+R/SW2*(DRHOT4+TBQCD0)-CORKAP*RENORM)
       ROFACR=ROFACI       -DRHOT-TBQCDL        -1
       AKFACR=AKFACI-R/SW2*(DRHOT+TBQCDL)+CORKAP-1
      ENDIF
C-----------------------------------------------------------------------
      IF(IBFLA.EQ.1) THEN
       ROFACL=ROFACL*(1+(TAUBB1+TAUBB2)*IBFLA)**2
       AKFACL=AKFACL/(1+(TAUBB1+TAUBB2)*IBFLA)
      ENDIF
C-----------------------------------------------------------------------
      IF(IFACT.EQ.0) THEN
       ROFACI=1/(1/ROFACL-SCALER*ROFACR)
       AKFACI=AKFACL*(1+SCALER*AKFACR)
      ELSEIF(IFACT.EQ.1) THEN
       ROFACI=ROFACL*(1+SCALER*ROFACR*ROFACL)
       AKFACI=AKFACL+SCALER*AKFACR
      ELSEIF(IFACT.EQ.2) THEN
       ROFACI=ROFACL*(1+SCALER*ROFACR)
       AKFACI=AKFACL+SCALER*AKFACR
      ELSEIF(IFACT.EQ.3) THEN
       ROFACI=ROFACL+SCALER*ROFACR
       AKFACI=AKFACL+SCALER*AKFACR
        ELSE
       ROFACI=ROFACL
       AKFACI=AKFACL
      ENDIF
cbardin
cbard  print *,'ROFACL,ROFACR=',ROFACL,ROFACR
cbard  print *,'AKFACL,AKFACR=',AKFACL,AKFACR
cbard  print *,'ROFACI=',ROFACI
cbard  print *,'AKFACI=',AKFACI
*
      END
 
      SUBROUTINE VERTZW (MZ,INDF)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZVZW/V1,V2,CT,VTB,V1ZZ,V1ZW,V2ZWW,VCT0,
     *      V1ZZC,V1ZWC,V2ZWWC,VCT0C,V1WZ,V2WWZ
*
      IF(MZ) 5,8,5
*
* Z-BOSON CHAIN *********************
* FILLS CDZVZW (Z PART)
*
5     SR=SQRT(4.D0*R-1.D0)
      AT=ATAN(SR/(2.D0*R-1.D0))
      V1ZZ=-5.5D0-8.D0*(F1-SPENCE(2.D0))
      SPERR=SPENCE(1.D0+1./R)
      V1ZW=-3.5D0-2.D0*R-(3.D0+2.D0*R)*ALR-2.D0*(1.D0+R)**2*(F1-SPERR)
      V2ZWW=2.D0/9.D0/R2+43.D0/18.D0/R-1.D0/6.D0-2.D0*R
     *     +(-1.D0/12.D0/R2-1.5D0/R+7.D0/3.D0+2.D0*R)*SR*AT
     *     -2.D0*R*(2.D0+R)*AT**2
      IF(INDF-5) 2,3,2
3     CALL F1ZBT
      GOTO 4
2     V1=0.D0
      V2=0.D0
      VCT=0.D0
      CT=0.D0
4     V1ZZC=V1ZZ
      V1ZWC=V1ZW+V1
      V2ZWWC=V2ZWW+V2
      VCT=CT
      VCT0C=CT
      GO TO 9
*
* W-BOSON CHAIN ***********************
* FILLS CDZVZW (W PART)
*
8     ALAM=AMZ2*AMZ2-4.D0*AMW2*AMZ2
      V1WZ=-5.D0-2.D0/R+(3.D0+2.D0/R)*ALR
     *    -2.D0*R1W2/R2*(SPENCE(1.D0)-SPENCE(R1W))
      V2WWZ=-9.D0/4.D0/R-1.D0/12.D0/R2+23.D0/18.D0
     *     +(1.D0/2.D0/R-3.D0/4.D0/R2
     *     -1.D0/24.D0/R/R2+1.D0)*ALR
     *     -DREAL(XL(-AMW2,AMW2,AMZ2))
     *     *(5.D0/6.D0/R+1.D0/24.D0/R2+1.D0/2.D0)/AMW2
     *     +(1.D0/2.D0+1.D0/R)*ALAM*DREAL(XJ(-AMW2,AMW2,AMZ2))
     *     *DREAL(XJ(-AMW2,AMW2,AMZ2))-(1.D0/2.D0+1.D0/R)*ALR*ALR
9     CONTINUE
      END
 
      SUBROUTINE F1ZBT
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      EXTERNAL VZBT
      COMMON/CDZFLG/IHVP,IAMT4,IQCD,IMOMS,IMASS,IALEM,IMASK,IBARB,IFTJR
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZVZW/V1,V2,CT,VTB,V1ZZ,V1ZW,V2ZWW,VCT0,
     *      V1ZZC,V1ZWC,V2ZWWC,VCT0C,V1WZ,V2WWZ
      COMMON/CDZTMP/CDZT(5),ICDZ
      COMMON/CDZZWG/CAMZ,CAMH,GMU,A0,GAMZ,GAMW,CALSZ,CALST,CALXI,CALQED
      DIMENSION V(4)
      EQUIVALENCE (ICDZ,NN)
      DATA EPSL/1.D-7/,EPSI/1.D-5/
*
* FILLS CDZVZT
*
c Implementatiom of FTJR-corrections: 19/07/1993
c
c     IF(IFTJR.EQ.0) THEN
       AKBV=1D0
c       ELSE
c      AKBV=1-(PI2-3)/3*CALSZ/PI
c     ENDIF
*
      UL=1.D0-EPSL
      ST=.1D0*(UL-EPSL)
      DO 1  I=1,4
      NN=I
      CALL SIMPU(EPSL,UL,ST,EPSI,1D-30,VZBT,AR,RES,RES2,RES3)
      V(I)=RES
1     CONTINUE
      V1 =V(1)*AKBV
      V2 =V(2)*AKBV
      CT =V(3)*AKBV
      VTB=V(4)*AKBV
      END
 
      FUNCTION VZBT(Y)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
      COMMON/CDZTMP/CDZT(5),ICDZ
      EQUIVALENCE (CDZT(3),SY),(ICDZ,NN)
*
      HHRW=RW
      HHRW1=RW1
      HHALRW=ALRW
      RW=AMQ(5)**2/AMW2
      SY=Y
      RW1=1.D0-RW
      RM1=1.D0/R
      Y1=1.D0-Y
      YY1=Y*Y1
      AL1=LOG(ABS((R*RW-YY1)/YY1))
      AL2=LOG(ABS(RW-RM1*YY1))
      AL3=LOG(Y+RW*Y1)
      AL4=LOG(1.D0-RM1*YY1)
      ALRW=LOG(RW)
      F1TB=F1(RW,1.D0)
      F10B=F1(0.D0,1.D0)
      F2TB=F2(RW,1.D0)
      F20B=F2(0.D0,1.D0)
      F1T =F1(1.D0,RW)
      F10 =F1(1.D0,0.D0)
      F2T =F2(1.D0,RW)
      F20 =F2(1.D0,0.D0)
      V1=(1.D0/6.D0-2.D0/3.D0*R)*((0.5D0-3.D0*YY1)*RM1*AL1
     *  +2.D0*RW*AL2-RW+(1.D0+2.D0*RM1)*(F1TB-F10B)
     *  -(1.D0+1.5D0*RM1)*(F2TB-F20B)+RW*(1.D0+0.5D0*RM1)*F2TB)
     *  -2.D0/3.D0*RW*R1*(0.5D0+0.5D0*AL2-2.D0*F1TB+0.5D0*RW1*F2TB)
      V1=V1/(1.D0/6.D0-2.D0/3.D0*R)
      CT=-(1.D0/6.D0+1.D0/3.D0*R)*RW/RW1*((5.D0*RW-11.D0)/4.D0
     *  +(3.D0*RW-6.D0)/2.D0/RW1*RW*ALRW)
      V21=-(2.D0+R)*(F2T-F20)+RW*(2.D0*R*AL3+(0.25D0-0.5D0*R)*(AL4-1.D0)
     *   +(0.5D0*RW-R*RW-2.D0*R-2.D0)*F1T
     *   +(0.25D0*RW1+0.5D0*R*(1.D0+RW))*F2T)
      V2=V21/R
      GOTO  (1,2,3,4) NN
1     VZBT=V1
      GOTO77
2     VZBT=V2
      GOTO 77
3     VZBT=CT
      GOTO 77
4     VZBT=V1*(1.D0/6.D0-2.D0/3.D0*R)+V2*R+CT
77    CONTINUE
      RW=HHRW
      RW1=HHRW1
      ALRW=HHALRW
      END
 
      FUNCTION F1(A,B)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZTMP/CDZT(5),ICDZ
      EQUIVALENCE (CDZT(3),SY)
      DATA EPS/1.D-6/
*
      Y=SY
      DEL=A-B-Y/R
      Y1=1.D0-Y
      YY1=Y*Y1
      D=A*Y+B*Y1
      IF(ABS(DEL).LT.EPS) GO TO 1
      F1=1.D0/DEL*LOG(ABS(A-YY1/R)/D)
      GO TO 2
1     F1=Y1/D*(1.D0-0.5D0*Y1*DEL/D)
2     CONTINUE
      END
 
      FUNCTION F2(A,B)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZTMP/CDZT(5),ICDZ
      EQUIVALENCE (CDZT(3),SY)
      DATA EPS/1.D-6/
*
      Y=SY
      DEL=A-B-Y/R
      Y1=1.D0-Y
      YY1=Y*Y1
      D=A*Y+B*Y1
      E=B+Y*Y/R
      IF(ABS(DEL).LT.EPS) GO TO 1
      F2=1.D0/DEL*(Y1-E/DEL*LOG(ABS(A-YY1/R)/D))
      GO TO 2
1     F2=Y1/D*(Y+E*Y1/D*(1.D0/2.D0-Y1/3.D0*DEL/D))
2     CONTINUE
      END
 
      SUBROUTINE PROW (QI,ROW)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZWSC/SL2,SQ2,W0,W0F,Z0,Z0F,DWZ0R1,DWZ0F,XWM1,XWM1F,XZM1,
     &      XZM1F,XWZ1R1,XDWZ1F,XZFM1,XZFM1F,XAMM1,XAMM1F,XWFM1,XWFM1F
      COMMON/CDZVZW/V1,V2,CT,VTB,V1ZZ,V1ZW,V2ZWW,VCT0,
     *      V1ZZC,V1ZWC,V2ZWWC,VCT0C,V1WZ,V2WWZ
*
      QIQJ=QI*(1.D0-QI)
      WM1A=DREAL(XWM1+XWM1F)
      W0A=W0+W0F
      WFM1A=DREAL(XWFM1+XWFM1F)
      ROW=1.D0+AL4PI/R1*(WM1A-W0A+WFM1A-7.D0/1.D0+5.D0/8.D0*R*R1W
     *   -9.D0/4.D0*R/R1*ALR+3.D0/4.D0/R+3.D0*R-3.D0/R*R12*QIQJ
     *   +(1.D0/2.D0/R-1.D0-2.D0*R12/R*QIQJ)*V1WZ
     *   +2.D0*V2WWZ+2.D0*R1*(77.D0/12.D0-2.D0/3.D0*PI2+109.D0/36.D0
     *   -3.D0/2.D0*QIQJ))
      PROW1=100.D0*(ROW-1.D0)
      END
 
      FUNCTION RXQCDS(ALST,SW2,AMT2)
 
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
*
* WITHOUT FACTOR ALPI/4/PI
*
      ALTW=-AMT2/AMW2
      ALTZ=-AMT2/AMZ2
      PVFBW=ALTW*DREAL(XPVF0(ALTW))
      PVFBZ=ALTZ*DREAL(XPVF0(ALTZ))
      PVFTW=ALTW*DREAL(XPVFI(ALTW))
      PVFTZ=ALTZ*DREAL(XPVFI(ALTZ))
      PAFTZ=ALTZ*DREAL(XPAFI(ALTZ))
      PWFTW=ALTW*DREAL(XPWFI(ALTW))
      PWF0  =PI2/2D0+105D0/8D0
      RXQCDT=ALST/3D0/PI/SW2*(4D0*SW2*CQM(5)**2*(PVFTZ-PVFBZ)
     &      -1D0/4D0/SW2*(VT2*(PVFTZ-PVFBZ)+PAFTZ-PVFBZ)
     &      +(R-SW2)/SW2*(PWFTW-PVFBW)+AMT2/AMW2*PWF0)
      RXQCDB=ALST/PI/SW2**2*(R-SW2)*LOG(AMZ2/AMW2)
      RXQCDS=RXQCDT+RXQCDB
*
      END
 
      FUNCTION RXQCD(ALST,SW2,AMT2)
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
*
* WITHOUT FACTOR ALPI/4/PI
*
      ALTW=-AMT2/AMW2
      ALTZ=-AMT2/AMZ2
      PVFBW=ALTW*DREAL(XPVF0(ALTW))
      PVFBZ=ALTZ*DREAL(XPVF0(ALTZ))
      PVFTW=ALTW*DREAL(XPVF (ALTW))
      PVFTZ=ALTZ*DREAL(XPVF (ALTZ))
      PAFTZ=ALTZ*DREAL(XPAF (ALTZ))
      PWFTW=ALTW*DREAL(XPWF (ALTW))
      PWF0 =PI2/2D0+105D0/8D0
      RXQCDT=ALST/3D0/PI/SW2*(4D0*SW2*CQM(5)**2*(PVFTZ-PVFBZ)
     &      -1D0/4D0/SW2*(VT2*(PVFTZ-PVFBZ)+PAFTZ-PVFBZ)
     &      +(R-SW2)/SW2*(PWFTW-PVFBW)+AMT2/AMW2*PWF0)
* COMPARISON WITH KNIEHL'S COEFFICIENTS
*     RXQCD1=1D0/4D0/3D0/SW2*4D0*SW2*(PVFTZ-PVFBZ)
*     RXQCD2=1D0/4D0/3D0/SW2*(-1D0/4D0/SW2*(PVFTZ-PVFBZ)) *16D0*R*SW2
*     RXQCD3=1D0/4D0/3D0/SW2*(-1D0/4D0/SW2*(+93D0/2D0*ALTZ+PAFTZ-PVFBZ))
*    &                                                    *16D0*R*SW2
*     RXQCD4=1D0/4D0/3D0/SW2*(+(R-SW2)/SW2*((+105D0/8D0+PI2/2D0)*ALTW
*    &                        +PWFTW-PVFBW))
* THE END OF COMPARISON
      RXQCDB=ALST/PI/SW2**2*(R-SW2)*LOG(AMZ2/AMW2)
      RXQCD =RXQCDT+RXQCDB
*
      END
 
      FUNCTION ALQCDS(ALST,SW2,AMT2)
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
*
* WITHOUT FACTOR ALPI/4/PI
*
      ALTZ=-AMT2/AMZ2
      PVFTZ=ALTZ*DREAL(XPVFI(ALTZ))
      ALQCDS=-ALST/3D0/PI/SW2*( 4D0*SW2*CQM(5)**2*(PVFTZ-45D0/4D0) )
*
      END
 
      FUNCTION ALQCD(ALST,SW2,AMT2)
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
*
* WITHOUT FACTOR ALPI/4/PI
*
      ALTZ=-AMT2/AMZ2
      PVFTZ=ALTZ*DREAL(XPVF (ALTZ))
      ALQCD=-ALST/3D0/PI/SW2*( 4D0*SW2*CQM(5)**2*(PVFTZ-45D0/4D0) )
*
      END
 
      FUNCTION XKQCDS(ALST,SW2,AMT2,S)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
*
* CALPI/4 IS OMITTED
*
      ALTW=-AMT2/AMW2
      ALTZ=-AMT2/AMZ2
      ALTS=-AMT2/S
      XPVFBS=ALTS*XPVF0(ALTS)
      XPVFTS=ALTS*XPVFI(ALTS)
      XPVFBZ=ALTZ*XPVF0(ALTZ)
      XPVFTZ=ALTZ*XPVFI(ALTZ)
      XPAFTZ=ALTZ*XPAFI(ALTZ)
      XPWFW =ALTW*XPWFI(ALTW)
      XKQCDS=ALST/(3.D0*PI*SW2)*(1.D0/4.D0/SW2*((VB2+1.D0)*XPVFBZ
     *      +VT2*XPVFTZ+XPAFTZ)-R/SW2*XPWFW+VB*CQM(6)*XPVFBS
     *      +VT*CQM(5)*XPVFTS)
      END
 
      FUNCTION XKAQCD(ALST,SW2,AMT2,S)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
*
* CALPI/4 IS OMITTED
*
      ALTW=-AMT2/AMW2
      ALTZ=-AMT2/AMZ2
      ALTS=-AMT2/S
      XPVFBS=ALTS*XPVF0(ALTS)
      XPVFTS=ALTS*XPVF (ALTS)
      XPVFBZ=ALTZ*XPVF0(ALTZ)
      XPVFTZ=ALTZ*XPVF (ALTZ)
      XPAFTZ=ALTZ*XPAF (ALTZ)
      XPWFW =ALTW*XPWF (ALTW)
      XKAQCD=ALST/(3.D0*PI*SW2)*(1.D0/4.D0/SW2*((VB2+1.D0)*XPVFBZ
     *      +VT2*XPVFTZ+XPAFTZ)-R/SW2*XPWFW+VB*CQM(6)*XPVFBS
     *      +VT*CQM(5)*XPVFTS)
      END
 
      FUNCTION XRQCDS(ALST,SW2,AMT2,S)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
*
* CALPI/4 IS OMITTED
*
      DATA EPS/1.D-3/
      ALTZ=-AMT2/AMZ2
      ALTS=-AMT2/S
      SMZ2=S/AMZ2
      DMZ2=1.D0-SMZ2
      XPVFTS=XPVFI(ALTS)
      XPVFTZ=XPVFI(ALTZ)
      XPAFTS=XPAFI(ALTS)
      XPAFTZ=XPAFI(ALTZ)
      IF(ABS(DMZ2).LT.EPS) GO TO 1
      XRQCDS=ALST/(3.D0*PI*SW2)*(-S/4.D0/AMW2*(VB2+1.D0)*RFL(SMZ2)
     *      +AMT2/4.D0/AMW2*(1.D0/DMZ2*(VT2*(XPVFTZ-XPVFTS)+XPAFTZ
     *      -XPAFTS)-(VT2*XPVFTZ+XPAFTZ))
     *      -AMT2/AMW2*(PI2/2.D0+105.D0/8.D0))
      GOTO 99
1     XDVFTZ=XDPVFI(ALTZ)
      XDAFTZ=XDPAFI(ALTZ)
      XRQCDS=ALST/(3.D0*PI*SW2)*(1.D0/4.D0/R*(VB2+1.D0)
     *      +AMT2/4.D0/AMW2*(VT2*(XDVFTZ/ALTZ-XPVFTZ)
     *      +XDAFTZ/ALTZ-XPAFTZ)-AMT2/AMW2*(PI2/2.D0+105.D0/8.D0))
  99  CONTINUE
      END
 
      FUNCTION XROQCD(ALSZ,ALST,SW2,AMT2,S)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
*
* CALPI/4 IS OMITTED
*
      DATA EPS/1.D-3/
      ALTZ=-AMT2/AMZ2
      ALTS=-AMT2/S
      SMZ2=S/AMZ2
      DMZ2=1.D0-SMZ2
      XPVFTS=XPVF(ALTS)
      XPVFTZ=XPVF(ALTZ)
      XPAFTS=XPAF(ALTS)
      XPAFTZ=XPAF(ALTZ)
      IF(ABS(DMZ2).LT.EPS) GO TO 1
CBARDIN: light quarks in rho, here and 8 rows below
      XROQCD=ALSZ/(3D0*PI*SW2)*(-S*3D0/2D0/AMW2*(2+VT2+VB2)*RFL(SMZ2))
     *      +ALST/(3D0*PI*SW2)*(-S*3D0/4D0/AMW2*(+VB2+1.D0)*RFL(SMZ2)
     *      +AMT2/4.D0/AMW2*(1.D0/DMZ2*(VT2*(XPVFTZ-XPVFTS)+XPAFTZ
     *      -XPAFTS)-(VT2*XPVFTZ+XPAFTZ))
     *      -AMT2/AMW2*(PI2/2.D0+105.D0/8.D0))
      RETURN
1     XDVFTZ=XDPVF(ALTZ)
      XDAFTZ=XDPAF(ALTZ)
      XROQCD=ALST/(3D0*PI*SW2)*(3D0/2D0/R*(2+VT2+VB2))
     *      +ALST/(3D0*PI*SW2)*(3D0/4D0/R*(+VB2+1.D0)
     *      +AMT2/4.D0/AMW2*(VT2*(XDVFTZ/ALTZ-XPVFTZ)
     *      +XDAFTZ/ALTZ-XPAFTZ)-AMT2/AMW2*(PI2/2.D0+105.D0/8.D0))
      END
 
      FUNCTION XPVF0(AL)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
*
      XPVF0=(55.D0/4.D0-12.D0*D3+3.D0*DCMPLX(LOG(ABS(AL)),PI))/AL
      END
 
      FUNCTION PVF0G(AL)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
*
      PVF0G=(55D0/4D0-12D0*D3)/AL
      END
 
      FUNCTION XPVFI(AL)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      RPVFI=45.D0/4.D0/AL-82.D0/27.D0/AL**2+449.D0/900.D0/AL**3
     *     -62479.D0/661500.D0/AL**4
      XPVFI=DCMPLX(RPVFI,.0D0)
      END
 
      FUNCTION XPVF(AL)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      DATA EPS/2.D-3/
*
      FFHH11=F1
      F1=6.*D3
      ASQ=1.D0+4.D0*AL
      IF(ASQ.GE.0.D0) XSQ=DCMPLX(SQRT(ASQ),0.D0)
      IF(ASQ.LT.0.D0) XSQ=DCMPLX(0.D0,SQRT(ABS(ASQ)))
      XD=1.D0+2.D0*AL+XSQ
      XA=2.D0*AL/XD
      XFLXA=XFL(XA)
      XA2=XA**2
      ALI=ABS(1.D0/AL)
      IF(ALI.GT.EPS) GO TO 2
1     XGIN1=XGS1(XA)
      XGIN2=XGS1(XA2)
      XFIN1=XFS1(XA)
      XFIN2=XFS1(XA2)
      GO TO 3
2     XGIN1=XGIN(XA)
      XGIN2=XGIN(XA2)
      XFIN1=XFIN(XA)
      XFIN2=XFIN(XA2)
3     XIA=F1+XFIN2-2.D0*XFIN1
      IF(ASQ.EQ.0.D0) XJA=0.D0
      IF(ASQ.NE.0.D0) XJA=(1.D0-XA)/(1.D0+XA)/AL*(XGIN2-XGIN1)
      XPV=55.D0/4.D0-26.D0*AL+3.D0*(1.D0+XA)*((1.D0-6.D0*AL)*XFLXA)
      XPV=XPV
     *   -2.D0*(AL*(2.D0*XA2-3.D0*XA+2.D0)+2.D0*XA)*(XFLXA*XFLXA)
      XPV=XPV
     *   +2.D0*(4.D0*AL**2-1.D0)*XIA+4.D0*AL*(2.D0*AL-1.D0)
     *   *(4.D0*AL+1.D0)*XJA
      XPVF=XPV/AL
      F1=FFHH11
      END
 
      FUNCTION XDPVFI(AL)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      RDPVFI=45.D0/4.D0-164.D0/27.D0/AL+449.D0/300.D0/AL**2
     *      -62479.D0/165375.D0/AL**3+9.55063D-2/AL**4
      XDPVFI=DCMPLX(RDPVFI,.0D0)
      END
 
      FUNCTION XDPVF(AL)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      DATA EPS/2.D-3/
*
      FFHH11=F1
      F1=6.D0*D3
      ASQ=1.D0+4.D0*AL
      IF(ASQ.GE.0.D0) XSQ=DCMPLX(SQRT(ASQ),0.D0)
      IF(ASQ.LT.0.D0) XSQ=DCMPLX(0.D0,SQRT(ABS(ASQ)))
      XD=1.D0+2.D0*AL+XSQ
      XA=2.D0*AL/XD
      XFLXA=XFL(XA)
      XA2=XA**2
      XFLXA2=(XFL(XA2))**2
      ALI=ABS(1.D0/AL)
      IF(ALI-EPS)1,1,2
1     XGIN1=XGS1(XA)
      XGIN2=XGS1(XA2)
      XFIN1=XFS1(XA)
      XFIN2=XFS1(XA2)
      GO TO 3
2     XGIN1=XGIN(XA)
      XGIN2=XGIN(XA2)
      XFIN1=XFIN(XA)
      XFIN2=XFIN(XA2)
3     XIA=F1+XFIN2-2.D0*XFIN1
      IF(ASQ.EQ.0.D0) XJA=0.D0
      IF(ASQ.NE.0.D0) XJA=(1.D0-XA)/(1.D0+XA)/AL*(XGIN2-XGIN1)
      XDPVF=43.D0/4.D0+18.D0*AL+(1.D0+XA)*(3.D0+10.D0*AL)*XFLXA
     *     -2.D0*XA*(2.D0-5.D0*AL)*XFLXA**2
     *     +8.D0*XA2*(1.D0-2.D0*AL)*XFLXA2
      XDPVF=XDPVF
     *     -2.D0*(4.D0*AL**2+1.D0)*XIA-8.D0*AL**2*(4.D0*AL+1.D0)*XJA
      F1=FFHH11
      END
 
      FUNCTION XPAFI(AL)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      RPAFI=-93.D0/2.D0+67.D0/12.D0/AL-689.D0/540.D0/AL**2
     *     +1691.D0/12600.D0/AL**3-1.8599D-2/AL**4
      XPAFI=DCMPLX(RPAFI,.0D0)
      END
 
      FUNCTION XPAF(AL)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      DATA EPS/2.D-3/
*
      FFHH11=F1
      F1=6.D0*D3
      ASQ=1.D0+4.D0*AL
      IF(ASQ.GE.0.D0) XSQ=DCMPLX(SQRT(ASQ),0.D0)
      IF(ASQ.LT.0.D0) XSQ=DCMPLX(0.D0,SQRT(ABS(ASQ)))
      XD=1.D0+2.D0*AL+XSQ
      XA=2.D0*AL/XD
      XFLXA=XFL(XA)
      XA2=XA**2
      ALI=ABS(1.D0/AL)
      IF(ALI-EPS)1,1,2
1     XGIN1=XGS1(XA)
      XGIN2=XGS1(XA2)
      XFIN1=XFS1(XA)
      XFIN2=XFS1(XA2)
      GO TO 3
2     XGIN1=XGIN(XA)
      XGIN2=XGIN(XA2)
      XFIN1=XFIN(XA)
      XFIN2=XFIN(XA2)
3     XIA=F1+XFIN2-2.D0*XFIN1
      IF(ASQ.EQ.0.D0) XJA=0.D0
      IF(ASQ.NE.0.D0) XJA=(1.D0-XA)/(1.D0+XA)/AL*(XGIN2-XGIN1)
      XPA=55.D0/4.D0-19.D0/2.D0*AL+12.D0*AL**2
     *   +3.D0*(1.D0+XA)*(1.D0+12.D0*AL+4.D0*AL**2)*XFLXA
     *   +2.D0*(2.D0*XA*(3.D0*AL**2-1.D0)
     *   +AL*(7.D0*XA2-3.D0*XA+7.D0))*XFLXA**2
      XPA=XPA
     *   -2.D0*(1.D0+2.D0*AL)*(1.D0+4.D0*AL)*XIA
     *   -4.D0*AL*(4.D0*AL+1.D0)**2*XJA
      XPAF=XPA/AL
      F1=FFHH11
      END
 
      FUNCTION XDPAFI(AL)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      RDPAFI=67.D0/12.D0-689.D0/270.D0/AL+1691.D0/4200.D0/AL**2
     *      -7.43961D-2/AL**3+275205680132.D0/18606865047887.D0/AL**4
      XDPAFI=DCMPLX(RDPAFI,.0D0)
      END
 
      FUNCTION XDPAF(AL)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
      DATA EPS/2.D-3/
*
      FFHH11=F1
      F1=6.D0*D3
      ASQ=1.D0+4.D0*AL
      IF(ASQ.GE.0.D0) XSQ=DCMPLX(SQRT(ASQ),0.D0)
      IF(ASQ.LT.0.D0) XSQ=DCMPLX(0.D0,SQRT(ABS(ASQ)))
      XD=1.D0+2.D0*AL+XSQ
      XA=2.D0*AL/XD
      XFLXA=XFL(XA)
      XA2=XA**2
      XFLXA2=(XFL(XA2))**2
      ALI=ABS(1.D0/AL)
      IF(ALI-EPS)1,1,2
1     XGIN1=XGS1(XA)
      XGIN2=XGS1(XA2)
      XFIN1=XFS1(XA)
      XFIN2=XFS1(XA2)
      GO TO 3
2     XGIN1=XGIN(XA)
      XGIN2=XGIN(XA2)
      XFIN1=XFIN(XA)
      XFIN2=XFIN(XA2)
3     XIA=F1+XFIN2-2.D0*XFIN1
      IF(ASQ.EQ.0.D0) XJA=0.D0
      IF(ASQ.NE.0.D0) XJA=(1.D0-XA)/(1.D0+XA)/AL*(XGIN2-XGIN1)
      XDPAF=43.D0/4.D0-12.D0*AL*(3.D0+2.D0*AL)
     *     +(1.D0+XA)*(3.D0-26.D0*AL-24.D0*AL**2)*XFLXA
      XDPAF=XDPAF
     *     -2.D0*XA*(2.D0+19.D0*AL+12.D0*AL**2)*XFLXA**2
     *     +8.D0*XA2*(1.D0+4.D0*AL)*XFLXA2
     *     -2.D0*(1.D0-8.D0*AL**2)*XIA+16.D0*AL**2*(4.D0*AL+1.D0)*XJA
      F1=FFHH11
      END
 
      FUNCTION XPWFI(AL)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
*
      FFHH11=F1
      F1=6.D0*D3
      G1=PI2/3.D0
      RPWFI=-105.D0/8.D0-3.D0/2.D0*G1+(115.D0/12.D0-2.D0/3.D0*G1)/AL
     *     +(-25.D0/16.D0-3.D0/4.D0)/AL**2
      XPWFI=DCMPLX(RPWFI,.0D0)
      F1=FFHH11
      END
 
      FUNCTION XPWF(AL)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      DATA EPS/2.D-3/
*
      FFHH11=F1
      F1=6.D0*D3
      G1=PI2/3.D0
      IF(AL.EQ.-1.D0) GO TO 10
      XB=DCMPLX(AL/(1.D0+AL),.0D0)
      IF(AL.GE.-1.D0) XB=DCMPLX(AL/(1.D0+AL),EPS**2)
      XFLXB=XFL(XB)
      ALI=ABS(1.D0/AL)
      IF(ALI-EPS)1,1,2
1     XGIN1=XGS1(XB)
      XFIN1=XFS1(XB)
      GO TO 3
2     XGIN1=XGIN(XB)
      XFIN1=XFIN(XB)
3     XIB=F1-XFIN1
      XJB=-1.D0/2.D0/AL*XGIN1
      XPW=55.D0/4.D0-71.D0/8.D0*AL-5.D0/2.D0*AL**2-2.D0*AL*XGIN1
     *   +0.5D0*(6.D0+9.D0*AL-5.D0*AL**2)*XFLXB
     *   +0.5D0*(4.D0*XB*(AL**2-AL-1.D0)+AL*(5.D0-4.D0*AL))*XFLXB**2
      XPW=XPW
     *   +(AL-2.D0)*(AL+1.D0)**2*XIB+2.D0*AL*(AL-2.D0)*(AL+1.D0)*XJB
      XPWF=XPW/AL
      GOTO 99
10    XPWF=DCMPLX(-161.D0/8.D0-4.D0*G1,.0D7)
 99   CONTINUE
      F1=FFHH11
      END
 
      FUNCTION XFL(X)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      DATA EPS/1.D-3/
*
      X1=1.D0-X
      AB=CDABS(X1)
      IF(AB.LT.EPS) GO TO 1
      XFL=LOG(X)/X1
      RETURN
1     XFL=-(1.D0+X1/2.D0+X1**2/3.D0+X1**3/4.D0+X1**4/5.D0)
      END
 
      FUNCTION RFL(X)
*
      IMPLICIT REAL*8(A-H,O-X)
      DATA EPS/1.D-3/
*
      X1=1.D0-X
      AB=ABS(X1)
      IF(AB.LT.EPS) GO TO 1
      RFL=LOG(X)/X1
      RETURN
1     RFL=-(1.D0+X1/2.D0+X1**2/3.D0+X1**3/4.D0+X1**4/5.D0)
      END
 
      FUNCTION XGS1(X)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
*
      X1=X-1.D0
      G1=PI2/3.D0
      XGS1=G1+X1-1.D0/2.D0*X1**2+11.D0/36.D0*X1**3
     *    -5.D0/24.D0*X1**4+137.D0/900.D0*X1**5-7.D0/60.D0*X1**6
      END
 
      FUNCTION XGIN(X)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      EXTERNAL RGIN,AGIN
      COMMON/CDZTMP/CDZT(5),ICDZ
      EQUIVALENCE (CDZT(1),XC)
      DATA EPS/1D-4/,EPSL/1D-14/
*
      XC=X
      CALL SIMPU(EPSL,1D0,.25D0,EPS,1D-30,RGIN,AR,RG,R2,R3)
      CALL SIMPU(EPSL,1D0,.25D0,EPS,1D-30,AGIN,AR,AG,R2,R3)
      XGIN=X*DCMPLX(RG,AG)
      END
 
      FUNCTION RGIN(T)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZTMP/CDZT(5),ICDZ
      EQUIVALENCE (CDZT(1),XC)
      DATA EPS/1.D-3/
*
      X=XC
      X1=1.D0-T*X
      AB=CDABS(X1)
      IF(AB.LT.EPS) GO TO 1
      RGIN=DREAL((LOG(T*X)/X1)**2)
      RETURN
1     RGIN=DREAL((1.D0+X1/2.D0+X1**2/3.D0+X1**3/4.D0+X1**4/5.D0)**2)
      END
 
      FUNCTION AGIN(T)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZTMP/CDZT(5),ICDZ
      EQUIVALENCE (CDZT(1),XC)
      DATA EPS/1.D-3/
*
      X=XC
      X1=1.D0-T*X
      AB=CDABS(X1)
      IF(AB.LT.EPS) GO TO 1
      AGIN=DIMAG((LOG(T*X)/X1)**2)
      RETURN
1     AGIN=DIMAG((1.D0+X1/2.D0+X1**2/3.D0+X1**3/4.D0+X1**4/5.D0)**2)
      END
 
      FUNCTION XFS1(X)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
*
      FFHH11=F1
      F1=6.D0*D3
      G1=PI2/3.D0
      X1=X-1.D0
      XFS1=F1+G1*X1+(1.D0-G1)/2.D0*X1**2+(2.D0*G1-3.D0)/6.D0*X1**3
     *    +(65.D0-36.D0*G1)/144.D0*X1**4+(G1/5.D0-29.D0/72.D0)*X1**5
     *    +(3899.D0/1800.D0/6.D0-G1/6.D0)*X1**6
      F1=FFHH11
      END
 
      FUNCTION XFIN(X)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      EXTERNAL RFIN,AFIN
      COMMON/CDZTMP/CDZT(5),ICDZ
      EQUIVALENCE (CDZT(1),XC)
      DATA EPS/1.D-4/,EPSL/1.D-14/
*
      XC=X
      CALL SIMPU(EPSL,1D0,.25D0,EPS,1D-30,RFIN,AR,RF,R2,R3)
      CALL SIMPU(EPSL,1D0,.25D0,EPS,1D-30,AFIN,AR,AF,R2,R3)
      XFIN=X*DCMPLX(RF,AF)
      XFIN=X*DCMPLX(RF,AF)
      END
 
      FUNCTION RFIN(T)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZTMP/CDZT(5),ICDZ
      EQUIVALENCE (CDZT(1),XC)
      DATA EPS/1.D-3/
*
      X=XC
      X1=1.D0-T*X
      AB=CDABS(X1)
      IF(AB.LT.EPS) GO TO 1
      RFIN=-DREAL((LOG(T*X)/X1)**2)*LOG(T)
      RETURN
1     RFIN=-DREAL((1.D0+X1/2.D0+X1**2/3.D0+X1**3/4.D0+X1**4/5.D0)**2)
     *    *LOG(T)
      END
 
      FUNCTION AFIN(T)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZTMP/CDZT(5),ICDZ
      EQUIVALENCE (CDZT(1),XC)
      DATA EPS/1.D-3/
*
      X=XC
      X1=1.D0-T*X
      AB=CDABS(X1)
      IF(AB.LT.EPS) GO TO 1
      AFIN=-DIMAG((LOG(T*X)/X1)**2)*LOG(T)
      RETURN
1     AFIN=-DIMAG((1.D0+X1/2.D0+X1**2/3.D0+X1**3/4.D0+X1**4/5.D0)**2)
     *    *LOG(T)
      END
 
      FUNCTION XSPENZ(Z)
C================================================================
C
      IMPLICIT COMPLEX*16(X,Y)
      IMPLICIT REAL*8(A-H,O-W,Z)
      COMPLEX*16 Z,XCDIL,CSPENZ
      COMMON/CDZPIF/PI,F1
      EXTERNAL XCDIL
      DATA N/0/
C
      JPRINT=0
C
      N=N+1
      IF(N-1) 71,71,72
 71   PI=2.*(ACOS(0.D0)+ASIN(0.D0))
      F1=PI**2/6.
 72   CONTINUE
      REZ=DREAL(Z)
      AIZ=DIMAG(Z)
      AAZ=CDABS(Z)
      IF(AAZ) 11,9,11
 9    CSPENZ=DCMPLX(0.D0,0.D0)
      GOTO 99
 11   IF(AAZ-1.) 6,4,1
 1    RE1=DREAL(1./Z)
      IF(RE1-.5) 3,3,2
2     CONTINUE
      CSPENZ=XCDIL(1.-1./Z)-2.*F1-LOG(Z)*LOG(1.-1./Z)
     U      -.5*(LOG(-Z))**2
      GOTO 99
3     CONTINUE
      CSPENZ=-XCDIL(1./Z)-F1-.5*LOG(-Z)**2
      GOTO 99
 4    IF(REZ-1.) 6,5,1
 5    CSPENZ=DCMPLX(F1,0.D0)
      GOTO 99
 6    IF(REZ-.5) 7,7,8
7     CONTINUE
      CSPENZ=XCDIL(Z)
      GOTO 99
8     CONTINUE
      CSPENZ=-XCDIL(1.-Z)+F1-LOG(Z)*LOG(1.-Z)
 99   CONTINUE
      AAS= CDABS(CSPENZ)
      RES=DREAL(CSPENZ)
      AIS=DIMAG(CSPENZ)
      IF(JPRINT) 97,97,98
 98   CONTINUE
 97   CONTINUE
      XSPENZ=CSPENZ
      END
 
      FUNCTION XCDIL(Z)
C================================================================
      IMPLICIT COMPLEX*16(X,Y)
      IMPLICIT REAL*8(A-H,O-W,Z)
C
      COMPLEX*16 Z,Z1,CLZ,CLZP,CADD
      COMMON/CDZPIF/PI,F1
      DIMENSION ZETA(15)
      EXTERNAL FZETA
      DATA N/0/,TCH/1.D-16/
C
      JPRINT=0
C
      PI2=PI*PI
      PI4=PI2*PI2
      AAZ=CDABS(Z)
      REZ=DREAL(Z)
      IF(AAZ-1.) 4,2,3
 3    PRINT 1000
 1000 FORMAT(3X,6 (15HERROR MODULUS Z) )
      GOTO 881
 2    IF(REZ-.5) 4,4,3
 4    CONTINUE
      N=N+1
      IF(N-1) 5,5,6
 5    DO 11 I=4,15
      ZETA(I)=0.D0
 11   CONTINUE
      ZETA(1)=F1
      ZETA(2)=PI4/90.
      ZETA(3)=PI4*PI2/945.
 6    CONTINUE
      Z1=DCMPLX(1.D0,0.D0)-Z
      CLZ=LOG(Z1)
      XCDIL=-CLZ-.25*(CLZ)**2
      M=0
      CLZP=CLZ/(2.*PI)
 88   M=M+1
      IF(M-15) 882,882,883
 883  PRINT 1001
 1001 FORMAT(2X,3 (24HERROR-YOU NEED MORE ZETA) )
      GOTO 881
 882  IF(ZETA(M)) 884,884,885
 884  ZETA(M)=FZETA(2*M)
 885  HZETA=ZETA(M)
      CLZP=CLZP*(CLZ/(2.*PI))**2
      CADD=(-1.)**M/(2.*M+1)*CLZP*HZETA
      XCDIL=XCDIL+4.*PI*CADD
      ACL=CDABS(CLZP)
      IF(ACL-TCH) 881,881,88
 881  CONTINUE
      IF(JPRINT) 626,626,625
 625  CONTINUE
      DO 10 I10=1,15
      PRINT 1002,I10,ZETA(I10)
 1002 FORMAT(2X,2HI=,I4,5X,9HZETA(2I)=,D16.8)
 10   CONTINUE
 626  CONTINUE
      RETURN
      END
 
      FUNCTION FZETA(K)
C================================================================
C
      IMPLICIT REAL*8(A-H,O-Z)
      IF(K.GT.1) GOTO 10
*USOUT PRINT 1000
1000  FORMAT(18H ERROR IN FZETA** )
      STOP
10    F=0.D0
      AN=0.D0
      TCH=1.D-16
 1    AN=AN+1
      B=1./AN**K
      F=F+B
      IF(B-TCH) 2,2,1
 2    FZETA=F
      END
 
      SUBROUTINE ROKANC(IBOXF,IBFLA,S,Q2,U,QI,QJ,XROK,XFOT,XFOT5)
*
* BEFORE USE OF ROKANC, AT LEAST ONE CALL OF DIZET MUST BE DONE.
* SEE ALSO THE COMMENTS THERE.
*---------------------------------------------------------------------
* THIS ROUTINE CALCULATES THE WEAK NEUTRAL CURRENT FORM FACTORS FOR
* THE 4-FERMION SCATTERING CROSS SECTION. ALSO: THE RUNNING ALPHA.QED.
* EXPLANATIONS OF THEIR DEFINITION AND USE MAY BE FOUND IN REFS.4,5,7.
* (GIVEN IN ROUTINE DIZET).
*----------------------------------------------------------------------
* EXAMPLES OF THE USE OF THIS ROUTINE MAY BE FOUND IN THE PACKAGE
* ZFITTER.
*----------------------------------------------------------------------
* INPUT FROM USER:
*            S,Q2,U - THE KINEMATIC INVARIANTS FOR THE QUARK PROCESS
*                     (S+T-U=0)
*             QI,QJ - THE CHARGES OF THE FERMION PAIRS IN THE PROCESS
*             IBOXF -    FLAG FOR THE WW,ZZ-BOX CONTRIBUTIONS
*             IBOXF = 0: THEY ARE SET EQUAL ZERO. NOT BAD FOR LEP100.
*                     1: THEY ARE CALCULATED.
* SPECIAL HANDLING OF WEAK CROSS SECTION FORM FACTORS IN CASE OF B-QUARK
*             IBFLA = 0: ALL OTHER CHANNELS
*                   = 1: THE B-QUARK PRODUCTION CHANNEL IN ANNIHILATION
*                      WITH THIS FLAG, THE ADDITIONAL VERTEX CORRECTIONS
*                      DUE TO THE T-QUARK MASS ARE TAKEN INTO ACCOUNT
*                      FOR LEP PHYSICS. SEE REF. 2.
*-----------------------------------------------------------------------
* OUTPUT OF THE ROUTINE:
*               XROK - THE FOUR COMPLEX NEUTRAL CURRENT FORM FACTORS
*                      RHO, KAPPA.I, KAPPA.J, KAPPA.IJ
*               XFOT - THE COMPLEX RUNNING QED COUPLING CONSTANT AT
*                      SCALE Q2
*              XFOT5 - THE XFOT, BUT TAKING INTO ACCOUNT ONLY 5 QUARKS
*-----------------------------------------------------------------------
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      COMMON/CDZFLG/IHVP,IAMT4,IQCD,IMOMS,IMASS,IALEM,IMASK,IBARB,IFTJR
      COMMON /CDZSCT/ ISCRE,ISCAL,IAFMT,IFACR,IFACT,IHIGS
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
      COMMON/CDZZWG/AMZ,AMH,GMU,A0,GAMZ,GAMW,CALSZ,CALST,CALXI,CALQED
      COMMON/CDZWSC/SL2,SQ2,W0,W0F,Z0,Z0F,DWZ0R1,DWZ0F,XWM1,XWM1F,XZM1,
     &      XZM1F,XWZ1R1,XDWZ1F,XZFM1,XZFM1F,XAMM1,XAMM1F,XWFM1,XWFM1F
      COMMON/CDZVZW/V1,V2,CT,VTB,V1ZZ,V1ZW,V2ZWW,VCT0,
     &      V1ZZC,V1ZWC,V2ZWWC,VCT0C,V1WZ,V2WWZ
      COMMON/CDZXKF/XROKF
      DIMENSION XROK(4)
      COMMON/CDZRLR/ROKL(4),ROKR(4),AROK(4)
*
      QIM=ABS(QI)
      QJM=ABS(QJ)
      SI=1.D0
      SJ=1.D0
      IF(QIM.NE.0.D0)  SI=QI/QIM
      IF(QJM.NE.0.D0)  SJ=QJ/QJM
      VI=1.D0-4.D0*R1*QIM
      VJ=1.D0-4.D0*R1*QJM
      XDF=DREAL(XDZF(Q2))
      XDB=XDZB(Q2)
      XDBAL=XDF+XDB
      XZM1AL=XZM1+XZM1F
      XWZ1AL=R*XWZ1R1+R*XDWZ1F
      XFMF=XAMF(Q2)
      XV1BW=XV1B(Q2,AMW2)
      XV1BZ=XV1B(Q2,AMZ2)
      XA1BW=XA1B(Q2,AMW2)
      XV2BW=XV2B(Q2,AMW2)
      XROBZ=XROB(Q2,AMW2)
      XRFL3=XL(Q2,AMW2,AMW2)/Q2
      Q2M=ABS(Q2)
      ALSZ=CALSZ
      ALST=CALST
      SW2=R1
      AMT2=AMQ(5)**2
      XZERO=DCMPLX(0.D0,0.D0)
      XRQCD=XZERO
      XKQCD=XZERO
      IF(IQCD-1) 1,2,3
2     XRQCD=AL4PI*XRQCDS(ALST,SW2,AMT2,Q2M)
      XKQCD=AL4PI*XKQCDS(ALST,SW2,AMT2,Q2M)
      GOTO 1
 3    XRQCD=AL4PI*XROQCD(ALSZ,ALST,SW2,AMT2,Q2M)
      XKQCD=AL4PI*XKAQCD(ALST,SW2,AMT2,Q2M)
1     CONTINUE
*
*  XROK(1)=RO WITH INDEXES I AND J
*
*  FROW BOXZZ
      AI11=-S
      AI12=-U
      SB=-Q2
      IF (IBOXF.EQ.0) THEN
       XWWRO=0.D0
       XZZRO=0.D0
       XZZI =0.D0
       XZZJ =0.D0
       XZZIJ=0.D0
        ELSE
      XWWP= (1D0+SI*SJ)/2D0*(XBOX(AI11,AI12,AMW2)
     &     +4.D0*(AI11/SB)**2*XJ3(SB,AMW2) )
      XWWM=-(1D0-SI*SJ)/2D0*2.D0*(AI11/SB)**2
     &     *(AI11/SB*XJ4(SB,AI11,AMW2)+2.D0*XJ3(SB,AMW2))
      XZZP=  XBOX(AI11,AI12,AMZ2)-2.D0*(AI11/SB)**3*XJ4(SB,AI11,AMZ2)
      XZZM=-(XBOX(AI12,AI11,AMZ2)-2.D0*(AI12/SB)**3*XJ4(SB,AI12,AMZ2))
      XWWPL=(-Q2)/AI11**2*XWWP
      XWWMI=(-Q2)/AI11**2*XWWM
      XZZPL=(-Q2)/AI11**2*XZZP
      XZZMI=(-Q2)/AI12**2*XZZM
      XWWRO=-SI*SJ*R*(Q2+AMZ2)*(XWWMI+XWWPL)
      XZZRO=-SI*SJ/32D0/R*(Q2+AMZ2)*
     &                 (((1D0+VI**2)*(1D0+VJ**2)+4D0*VI*VJ)*XZZPL
     &                 -((1D0+VI**2)*(1D0+VJ**2)-4D0*VI*VJ)*XZZMI)
      XZZI =-SI*SJ/32D0/R*(Q2+AMZ2)*(VI-1D0)*
     &         ((1D0+VJ)**2*XZZMI-(1D0-VJ)**2*XZZPL)       -XZZRO
      XZZJ =-SI*SJ/32D0/R*(Q2+AMZ2)*(VJ-1D0)*
     &         ((1D0+VI)**2*XZZMI-(1D0-VI)**2*XZZPL)       -XZZRO
      XZZIJ=-SI*SJ/16D0/R*(Q2+AMZ2)*(VI-1D0)*(VJ-1D0)*XZZPL-XZZRO
      ENDIF
*
      CONST=DREAL(XZM1AL)
     *     -W0F-5.D0/4.D0-5.D0/8.D0/R+RW/8.D0
     *     +3.D0/4.D0*((1.D0/R1-1.D0/R)*ALR-RW*ALRW/RW1)
      XROK(1)=1.D0+AL4PI/R1*(CONST+XDBAL+2.D0*R*XV2BW+XROBZ
     *       +(-2.D0*R+0.5D0+(VI+VJ)/4.D0)*XV1BW
     *       +(1.D0+3.D0/2.D0*(VI**2+VJ**2))/8.D0/R*XV1BZ)
     *       +XRQCD
      XROK(1)=XROK(1) + IBOXF*AL4PI/R1*(XZZRO+XWWRO)
cbard IF(IBOXF.EQ.1) print *,'XWWRO=',XWWRO
*-------------------
      GAUGE=AL4PI/R1*(-ALR*(41D0/6D0-11D0/3D0*R)+2D0/3D0*R1)
      XROKF=1D0+AL4PI/R1*(-XWZ1AL)+GAUGE+XKQCD
*-------------------
*  XROK(2)=KAPPA WITH INDEX I
      WZ1AL=DREAL(XWZ1AL)
      XROK(2)=1.D0+AL4PI/R1*(-WZ1AL+XFMF-R*XA1BW-2.D0/3.D0*R
     *       +43.D0/18.D0-3.D0/4.D0*XRFL3-(2.D0*R+AMW2/Q2)*XV2BW
     *       -XROBZ+(2.D0*R-QJM-(VI+VJ)/4.D0+(1.D0-QJM)*AMW2/Q2)*XV1BW
     *       +(-VI*(1.D0+VI)/8.D0/R-QJM*VJ/2.D0*(1.D0+AMZ2/Q2))*XV1BZ)
     *       +XKQCD
      XROK(2)=XROK(2) + IBOXF*AL4PI/R1*(XZZI-XWWRO)
*
*  XROK(3)=KAPPA WITH INDEX J
      XROK(3)=1.D0+AL4PI/R1*(-WZ1AL+XFMF-R*XA1BW-2.D0/3.D0*R
     *       +43.D0/18.D0-3.D0/4.D0*XRFL3-(2.D0*R+AMW2/Q2)*XV2BW
     *       -XROBZ+(2.D0*R-QIM-(VI+VJ)/4.D0+(1.D0-QIM)*AMW2/Q2)*XV1BW
     *       +(-VJ*(1.D0+VJ)/8.D0/R-QIM*VI/2.D0*(1.D0+AMZ2/Q2))*XV1BZ)
     *       +XKQCD
      XROK(3)=XROK(3) + IBOXF*AL4PI/R1*(XZZJ-XWWRO)
*
*  XROK(4)=KAPPA WITH INDEXES I AND J
      XROK(4)=1.D0+AL4PI/R1*(-2.D0*WZ1AL+2.D0*XFMF+(-R+AMW2/Q2)*XA1BW
     *       -4.D0/3.D0*R+35.D0/18.D0-2.D0/3.D0*XRFL3-2.D0*R*XV2BW
     *       -XROBZ+(2.D0*R-0.5D0-(VI+VJ)/4.D0)*XV1BW
     *       +(-1.D0/8.D0/R-3.D0*(VI**2+VJ**2)/16.D0/R
     *       +(QI**2+QJ**2)*R1/R*(1.D0+AMW2/Q2))*XV1BZ)
     *       +2.D0*XKQCD
      XROK(4)=XROK(4) + IBOXF*AL4PI/R1*(XZZIJ-XWWRO)
*
C-----------------------------------------------------------------------
      IF(IBARB.EQ.0) THEN
       AMT4C=19-2D0*PI2
        ELSEIF(IBARB.EQ.1) THEN
       RBTH=AMT2/AMH2
       ALRB=LOG(RBTH)
       AMT4C=49D0/4D0+PI2+27D0/2D0*ALRB+3D0/2D0*ALRB**2
     &      +RBTH/3D0*(2D0-12D0*PI2+12D0*ALRB-27D0*ALRB**2)
     &  +RBTH**2/48D0*(1613-240*PI2-1500*ALRB-720 *ALRB**2)
        ELSEIF(IBARB.EQ.2) THEN
       RBARB=SQRT(AMH2/AMT2)
       AMT4C=FBARB(RBARB)
      ENDIF
C--------------------------------------------------------------------
      RENORM=SQRT(2D0)*GMU*AMZ2*R1*R/PI*ALFAI
      IF(ISCRE.EQ.0) SCALER=1.00D0
      IF(ISCRE.GE.1) SCALER=RENORM
C--------------------------------------------------------------------
      IF (IAMT4 .EQ. 1 ) THEN
       DRHOT = .75D0*AL4PI/SW2/R*AMT2/AMZ2
       TOPX2 = GMU*AMT2/DSQRT(2.D0)/8.D0/PI2
       DRHOT4=3D0*TOPX2*(1D0+TOPX2*AMT4C)
       IF(IQCD.EQ.0) THEN
        TBQCD0=0D0
        TBQCD3=0D0
        CORRXI=0D0
         ELSE
          IF(IAFMT.EQ.0) THEN
* Below is the leading term as it is given in \zf (3.71)
           TBQCD0=.75D0*AL4PI/R/SW2*AMT2/AMZ2
     &           *(-CALXI/PI*2D0/3D0*(1D0+PI2/3D0))
           TBQCDL=.75D0*AL4PI/R/SW2*AMT2/AMZ2
     &           *(-CALST/PI*2D0/3D0*(1D0+PI2/3D0))
           CORRXI=-TBQCDL+TBQCD0
           TBQCD3=0D0
            ELSE
* This coincides with TBQCD0 above if O(\alpha\alpha^2_s)=0
           TBQCD0=AFMT3(CALST)
* Below is pure AFMT-correction to \Delta \rho (see p.18 PCWG-notebook)
           TBQCD3=.75D0*AL4PI/R/SW2*AMT2/AMZ2
     &          *(TBQCD0-(-CALST/PI*2D0/3D0*(1D0+PI2/3D0)))
           CORRXI=0D0
          ENDIF
       ENDIF
*
       ROKR(1)=DREAL(XROK(1))-1-        DRHOT+         TBQCD3+CORRXI
       ROKR(2)=DREAL(XROK(2))-1-  R/SW2*DRHOT+  R/SW2*(TBQCD3+CORRXI)
       ROKR(3)=DREAL(XROK(3))-1-  R/SW2*DRHOT+  R/SW2*(TBQCD3+CORRXI)
       ROKR(4)=DREAL(XROK(4))-1-2*R/SW2*DRHOT+2*R/SW2*(TBQCD3+CORRXI)
       AROK(1)=DIMAG(XROK(1))
       AROK(2)=DIMAG(XROK(2))
       AROK(3)=DIMAG(XROK(3))
       AROK(4)=DIMAG(XROK(4))
       ROKL(1)= 1/(1-DRHOT4)
       ROKL(2)=(1+R/SW2*DRHOT4)
       ROKL(3)=(1+R/SW2*DRHOT4)
       ROKL(4)=(1+R/SW2*DRHOT4)**2
C      XROK(1)= DCMPLX(DREAL(XROK(1)-DRHOT)/
C    &         (1D0-DRHOT4),DIMAG(XROK(1)))
C      XROKF  = DCMPLX(DREAL(XROKF  -R/SW2*DRHOT)*
C    &         (1D0+R/SW2*DRHOT4),DIMAG(XROK(2)))
C      XROK(2)= DCMPLX(DREAL(XROK(2)-R/SW2*DRHOT)*
C    &         (1D0+R/SW2*DRHOT4),DIMAG(XROK(2)))
C      XROK(3)= DCMPLX(DREAL(XROK(3)-R/SW2*DRHOT)*
C    &         (1D0+R/SW2*DRHOT4),DIMAG(XROK(3)))
C      XROK(4)= DCMPLX(DREAL(XROK(4)-2D0*R/SW2*DRHOT)*
C    &         (1D0+R/SW2*DRHOT4)**2,DIMAG(XROK(4)))
      ELSEIF(IAMT4 .EQ. 2 ) THEN
       DRHOT = .75D0*AL4PI/SW2/R*AMT2/AMZ2
       TOPX2 = GMU*AMT2/DSQRT(2.D0)/8.D0/PI2
       DRHOT4=3D0*TOPX2*(1D0+TOPX2*AMT4C)
       IF(IQCD.EQ.0) THEN
        TBQCD0= 0D0
        TBQCDL= 0D0
         ELSE
          IF(IAFMT.EQ.0) THEN
           TBQCD0=-TOPX2*CALXI/PI*2D0*(1D0+PI2/3D0)
            ELSE
           TBQCD0=3*TOPX2*AFMT3(CALST)
          ENDIF
        TBQCDL=-AL4PI*ALST/PI*AMT2/AMW2/R1*(.5D0+PI2/6D0)
       ENDIF
       ROKR(1)=DREAL(XROK(1))-1-         DRHOT-TBQCDL
       ROKR(2)=DREAL(XROK(2))-1-  R/SW2*(DRHOT+TBQCDL)
       ROKR(3)=DREAL(XROK(3))-1-  R/SW2*(DRHOT+TBQCDL)
       ROKR(4)=DREAL(XROK(4))-1-2*R/SW2*(DRHOT+TBQCDL)
       AROK(1)=DIMAG(XROK(1))
       AROK(2)=DIMAG(XROK(2))
       AROK(3)=DIMAG(XROK(3))
       AROK(4)=DIMAG(XROK(4))
       ROKL(1)=1/(1-DRHOT4-TBQCD0)
       ROKL(2)=(1+R/SW2*(DRHOT4+TBQCD0))
       ROKL(3)=(1+R/SW2*(DRHOT4+TBQCD0))
       ROKL(4)=(1+R/SW2*(DRHOT4+TBQCD0))**2
C      XROK(1) = DCMPLX(DREAL(XROK(1)-DRHOT-TBQCDL)/
C    &          (1.D0-DRHOT4-TBQCD0),DIMAG(XROK(1)))
C      XROK(2) = DCMPLX(DREAL(XROK(2)-R/SW2*(DRHOT+TBQCDL))*
C    &          (1.D0+R/SW2*(DRHOT4+TBQCD0)),DIMAG(XROK(2)))
C      XROKF   = DCMPLX(DREAL(XROKF  -R/SW2*(DRHOT+TBQCDL))*
C    &          (1.D0+R/SW2*(DRHOT4+TBQCD0)),DIMAG(XROK(2)))
C      XROK(3) = DCMPLX(DREAL(XROK(3)-R/SW2*(DRHOT+TBQCDL))*
C    &          (1.D0+R/SW2*(DRHOT4+TBQCD0)),DIMAG(XROK(3)))
C      XROK(4) = DCMPLX(DREAL(XROK(4)-2D0*R/SW2*(DRHOT+TBQCDL))*
C    &          (1.D0+R/SW2*(DRHOT4+TBQCD0))**2,DIMAG(XROK(4)))
      ELSEIF(IAMT4 .EQ. 3 ) THEN
       DWZ1AL=R/R1*DREAL(XWZ1R1+XDWZ1F)
       RENORM=SQRT(2D0)*GMU*AMZ2*R1*R/PI*ALFAI
       SCALE = AL4PI/R1*(-ALR*(41D0/6D0-11D0/3D0*R))
       CORKAP=AL4PI*DWZ1AL-SCALE+.75D0*AL4PI/SW2**2*AMT2/AMZ2
*
       DRHOT = .75D0*AL4PI/SW2/R*AMT2/AMZ2
       TOPX2 = GMU*AMT2/DSQRT(2.D0)/8.D0/PI2
       DRHOT4=3D0*TOPX2*(1D0+TOPX2*AMT4C)
       IF(IQCD.EQ.0) THEN
        TBQCD0= 0D0
        TBQCDL= 0D0
         ELSE
          IF(IAFMT.EQ.0) THEN
           TBQCD0=-TOPX2*CALXI/PI*2D0*(1D0+PI2/3D0)
            ELSE
           TBQCD0=3*TOPX2*AFMT3(CALST)
          ENDIF
        TBQCDL=-AL4PI*ALST/PI*AMT2/AMW2/R1*(.5D0+PI2/6D0)
       ENDIF
       ROKR(1)=DREAL(XROK(1))-1-         DRHOT-TBQCDL
       ROKR(2)=DREAL(XROK(2))-1-  R/SW2*(DRHOT+TBQCDL)+  CORKAP
       ROKR(3)=DREAL(XROK(3))-1-  R/SW2*(DRHOT+TBQCDL)+  CORKAP
       ROKR(4)=DREAL(XROK(4))-1-2*R/SW2*(DRHOT+TBQCDL)+2*CORKAP
       AROK(1)=DIMAG(XROK(1))
       AROK(2)=DIMAG(XROK(2))
       AROK(3)=DIMAG(XROK(3))
       AROK(4)=DIMAG(XROK(4))
       ROKL(1)=1/(1-DRHOT4-TBQCD0)
       ROKL(2)=(1+R/SW2*(DRHOT4+TBQCD0)-CORKAP*RENORM)
       ROKL(3)=(1+R/SW2*(DRHOT4+TBQCD0)-CORKAP*RENORM)
       ROKL(4)=(1+R/SW2*(DRHOT4+TBQCD0)-CORKAP*RENORM)**2
C      XROK(1)=DCMPLX(DREAL(XROK(1)-DRHOT-TBQCDL)/
C    &        (1D0-DRHOT4-TBQCD0),DIMAG(XROK(1)))
C      XROK(2)=DCMPLX(DREAL(XROK(2)-R/SW2*(DRHOT+TBQCDL)+CORKAP)*
C    &        (1D0+R/SW2*(DRHOT4+TBQCD0)-CORKAP*RENORM),DIMAG(XROK(2)))
C      XROKF  =DCMPLX(DREAL(XROKF-R/SW2*(DRHOT+TBQCDL)+CORKAP)*
C    &     (1D0+R/SW2*(DRHOT4+TBQCD0)-CORKAP*RENORM),DIMAG(XROK(2)))
C      XROK(3)=DCMPLX(DREAL(XROK(3)-R/SW2*(DRHOT+TBQCDL)+CORKAP)*
C    &        (1D0+R/SW2*(DRHOT4+TBQCD0)-CORKAP*RENORM),DIMAG(XROK(3)))
C      XROK(4)=DCMPLX(DREAL(XROK(4)-2D0*R/SW2*(DRHOT+TBQCDL)+2D0*CORKAP)
C    &     *(1D0+R/SW2*(DRHOT4+TBQCD0)-CORKAP*RENORM)**2,DIMAG(XROK(4)))
      ENDIF
C-----------------------------------------------------------------------
      IF(IBFLA.EQ.1) THEN
************************************************************************
*     APPROX. CORRECTION FOR FINITE T-MASS IN B CHANNEL
*     I.E. : NO T-QUARK MASS IN BOXES AND IN PHOTON VERTICES
*          THE T- QUARK MASS EFFECT IN THE Z VERTICES HAS BEEN
*          CALCULATED PRELIMINARY FOR S = MZ**2 ONLY.THIS IS
*          ACCURATE AT LEP I.
*     WE ASSUME THAT MT IS LARGER THAN SQRT(S)/2
*     COMMENT : COMMON CDZVZW IS FILLED IN Z- DECAY CHAIN
*          THE VALUE VTB IS GIVEN BY SR F1ZBT
************************************************************************
C 13/10/1992 - Barbieri's m_t^4 are implemented
      IF(IBARB.EQ.0) THEN
       AMT4B=(27-PI2)/3
        ELSEIF(IBARB.EQ.1) THEN
       RBTH=AMT2/AMH2
       ALRB=LOG(RBTH)
       AMT4B=1D0/144*(311D0+24*PI2+282*ALRB+90*ALRB**2
     &      -4D0*RBTH*(40D0+ 6*PI2+ 15*ALRB+18*ALRB**2)
     &      +3D0*RBTH**2*(242.09D0-60*PI2-454.2D0*ALRB-180*ALRB**2))
        ELSEIF(IBARB.EQ.2) THEN
       RBARB=SQRT(AMH2/AMT2)
       AMT4B=FBARBB(RBARB)
      ENDIF
C VTB is asymptotically -AMT2/AMW2/2
      TOPX2 = GMU*AMT2/DSQRT(2.D0)/8.D0/PI2
      TAUBB1=-2*TOPX2*(1-PI/3*CALST*IFTJR)
      TAUBB2=-2*TOPX2*( +TOPX2*AMT4B)
      DVTBB=AL4PI*VTB/R1+AL1PI/8/SW2*AMT2/AMW2
      ROKR(1)=ROKR(1)+DVTBB
      ROKR(3)=ROKR(3)-DVTBB
      ROKR(4)=ROKR(4)-DVTBB
      ROKL(1)=ROKL(1)*(1+(TAUBB1+TAUBB2)*IBFLA)
*     ROKL(2)=ROKL(2)/(1+(TAUBB1+TAUBB2)*IBFLA)
      ROKL(3)=ROKL(3)/(1+(TAUBB1+TAUBB2)*IBFLA)
      ROKL(4)=ROKL(4)/(1+(TAUBB1+TAUBB2)*IBFLA)
      ENDIF
C-----------------------------------------------------------------------
      IF(IFACT.EQ.0) THEN
       XROK(1)= DCMPLX(1/(1/ROKL(1)-SCALER*ROKR(1)),AROK(1))
       XROK(2)= DCMPLX(ROKL(2)*(1+SCALER*ROKR(2))  ,AROK(2))
       XROK(3)= DCMPLX(ROKL(3)*(1+SCALER*ROKR(3))  ,AROK(3))
       XROK(4)= DCMPLX(ROKL(4)*(1+SCALER*ROKR(4))  ,AROK(4))
      ELSEIF(IFACT.EQ.1) THEN
       XROK(1)= DCMPLX(ROKL(1)*(1+SCALER*ROKR(1)*ROKL(1)),AROK(1))
       XROK(2)= DCMPLX(ROKL(2)+SCALER*ROKR(2),AROK(2))
       XROK(3)= DCMPLX(ROKL(3)+SCALER*ROKR(3),AROK(3))
       XROK(4)= DCMPLX(ROKL(4)+SCALER*ROKR(4),AROK(4))
      ELSEIF(IFACT.EQ.2) THEN
       XROK(1)= DCMPLX(ROKL(1)*(1+SCALER*ROKR(1)),AROK(1))
       XROK(2)= DCMPLX(ROKL(2)+SCALER*ROKR(2),AROK(2))
       XROK(3)= DCMPLX(ROKL(3)+SCALER*ROKR(3),AROK(3))
       XROK(4)= DCMPLX(ROKL(4)+SCALER*ROKR(4),AROK(4))
      ELSEIF(IFACT.EQ.3) THEN
       XROK(1)= DCMPLX(ROKL(1)+SCALER*ROKR(1),AROK(1))
       XROK(2)= DCMPLX(ROKL(2)+SCALER*ROKR(2),AROK(2))
       XROK(3)= DCMPLX(ROKL(3)+SCALER*ROKR(3),AROK(3))
       XROK(4)= DCMPLX(ROKL(4)+SCALER*ROKR(4),AROK(4))
        ELSE
       XROK(1)= DCMPLX(ROKL(1),AROK(1))
       XROK(2)= DCMPLX(ROKL(2),AROK(2))
       XROK(3)= DCMPLX(ROKL(3),AROK(3))
       XROK(4)= DCMPLX(ROKL(4),AROK(4))
       ROKR(1)= SCALER*ROKR(1)
       ROKR(2)= SCALER*ROKR(2)
       ROKR(3)= SCALER*ROKR(3)
       ROKR(4)= SCALER*ROKR(4)
      ENDIF
C-----------------------------------------------------------------------
*     XROKMS = XROKF *     SIN^2_W(MS.BAR) = SIN^2_W * DREAL(XROKMS)
* PHOTON FORMFACTOR
CB    IF(IHVP.EQ.1) THEN
CB     XFOT =1D0+AL4PI*XFOTF(Q2)
CB     XFOT5=1D0+AL4PI*XFOTF(Q2)
CB      ELSE
       XFOT =1D0+AL4PI*XFOTF1(IHVP,IQCD,1,Q2)
       IF(IALEM.EQ.0) THEN
        XFOT5=1D0+AL4PI*XFOTF1(IHVP,IQCD,0,Q2)
     &      -AL4PI*REAL(XFOTF1(IHVP,0,0,-AMZ2))+1-1/ALFAI/CALQED
CBBL     &      -AL4PI*RXFOTF1(IHVP,0,0,-AMZ2))+1-1/ALFAI/CALQED
         ELSE
        XFOT5=1D0+AL4PI*XFOTF1(IHVP,IQCD,0,Q2)
       ENDIF
CB    ENDIF
*
      END
 
      SUBROUTINE SIMPS(A1,B1,H1,REPS1,AEPS1,FUNCT,X,AI,AIH,AIABS)
C SIMPS
C A1,B1 -THE LIMITS OF INTEGRATION
C H1 -AN INITIAL STEP OF INTEGRATION
C REPS1,AEPS1 - RELATIVE AND ABSOLUTE PRECISION OF INTEGRATION
C FUNCT -A NAME OF FUNCTION SUBPROGRAM FOR CALCULATION OF INTEGRAND +
C X - AN ARGUMENT OF THE INTEGRAND
C AI - THE VALUE OF INTEGRAL
C AIH- THE VALUE OF INTEGRAL WITH THE STEP OF INTEGRATION
C AIABS- THE VALUE OF INTEGRAL FOR MODULE OF THE INTEGRAND
C THIS SUBROGRAM CALCULATES THE DEFINITE INTEGRAL WITH THE RELATIVE OR
C ABSOLUTE PRECISION BY SIMPSON+S METHOD WITH THE AUTOMATICAL CHOICE
C OF THE STEP OF INTEGRATION
C IF AEPS1    IS VERY SMALL(LIKE 1.E-17),THEN CALCULATION OF INTEGRAL
C WITH REPS1,AND IF REPS1 IS VERY SMALL (LIKE 1.E-10),THEN CALCULATION
C OF INTEGRAL WITH AEPS1
C WHEN AEPS1=REPS1=0. THEN CALCULATION WITH THE CONSTANT STEP H1
C
      IMPLICIT REAL*8(A-H,O-Z)
      DIMENSION F(7),P(5)
      H=DSIGN(H1,B1-A1)
      S=DSIGN(1.D0,H)
      A=A1
      B=B1
      AI=0.D0
      AIH=0.D0
      AIABS=0.D0
      P(2)=4.D0
      P(4)=4.D0
      P(3)=2.D0
      P(5)=1.D0
      IF(B-A) 1,2,1
    1 REPS=DABS(REPS1)
      AEPS=DABS(AEPS1)
      DO 3 K=1,7
  3   F(K)=10.D16
      X=A
      C=0.D0
      F(1)=FUNCT(X)/3.
    4 X0=X
      IF((X0+4.*H-B)*S) 5,5,6
    6 H=(B-X0)/4.
      IF(H) 7,2,7
    7 DO 8 K=2,7
  8   F(K)=10.D16
      C=1.D0
    5 DI2=F(1)
      DI3=DABS(F(1))
      DO 9 K=2,5
      X=X+H
      IF((X-B)*S) 23,24,24
   24 X=B
   23 IF(F(K)-10.D16) 10,11,10
   11 F(K)=FUNCT(X)/3.
   10 DI2=DI2+P(K)*F(K)
    9 DI3=DI3+P(K)*ABS(F(K))
      DI1=(F(1)+4.*F(3)+F(5))*2.*H
      DI2=DI2*H
      DI3=DI3*H
      IF(REPS) 12,13,12
   13 IF(AEPS) 12,14,12
   12 EPS=DABS((AIABS+DI3)*REPS)
      IF(EPS-AEPS) 15,16,16
   15 EPS=AEPS
   16 DELTA=DABS(DI2-DI1)
      IF(DELTA-EPS) 20,21,21
   20 IF(DELTA-EPS/8.) 17,14,14
   17 H=2.*H
      F(1)=F(5)
      F(2)=F(6)
      F(3)=F(7)
      DO 19 K=4,7
  19  F(K)=10.D16
      GO TO 18
   14 F(1)=F(5)
      F(3)=F(6)
      F(5)=F(7)
      F(2)=10.D16
      F(4)=10.D16
      F(6)=10.D16
      F(7)=10.D16
   18 DI1=DI2+(DI2-DI1)/15.
      AI=AI+DI1
      AIH=AIH+DI2
      AIABS=AIABS+DI3
      GO TO 22
   21 H=H/2.
      F(7)=F(5)
      F(6)=F(4)
      F(5)=F(3)
      F(3)=F(2)
      F(2)=10.D16
      F(4)=10.D16
      X=X0
      C=0.D0
      GO TO 5
   22 IF(C) 2,4,2
    2 RETURN
      END
 
      SUBROUTINE SIMPT(A1,B1,H1,REPS1,AEPS1,FUNCT,X,AI,AIH,AIABS)
C SIMPT
C A1,B1 -THE LIMITS OF INTEGRATION
C H1 -AN INITIAL STEP OF INTEGRATION
C REPS1,AEPS1 - RELATIVE AND ABSOLUTE PRECISION OF INTEGRATION
C FUNCT -A NAME OF FUNCTION SUBPROGRAM FOR CALCULATION OF INTEGRAND +
C X - AN ARGUMENT OF THE INTEGRAND
C AI - THE VALUE OF INTEGRAL
C AIH- THE VALUE OF INTEGRAL WITH THE STEP OF INTEGRATION
C AIABS- THE VALUE OF INTEGRAL FOR MODULE OF THE INTEGRAND
C THIS SUBROGRAM CALCULATES THE DEFINITE INTEGRAL WITH THE RELATIVE OR
C ABSOLUTE PRECISION BY SIMPSON+S METHOD WITH THE AUTOMATICAL CHOICE
C OF THE STEP OF INTEGRATION
C IF AEPS1    IS VERY SMALL(LIKE 1.E-17),THEN CALCULATION OF INTEGRAL
C WITH REPS1,AND IF REPS1 IS VERY SMALL (LIKE 1.E-10),THEN CALCULATION
C OF INTEGRAL WITH AEPS1
C WHEN AEPS1=REPS1=0. THEN CALCULATION WITH THE CONSTANT STEP H1
C
      IMPLICIT REAL*8(A-H,O-Z)
      DIMENSION F(7),P(5)
      H=DSIGN(H1,B1-A1)
      S=DSIGN(1.D0,H)
      A=A1
      B=B1
      AI=0.D0
      AIH=0.D0
      AIABS=0.D0
      P(2)=4.D0
      P(4)=4.D0
      P(3)=2.D0
      P(5)=1.D0
      IF(B-A) 1,2,1
    1 REPS=DABS(REPS1)
      AEPS=DABS(AEPS1)
      DO 3 K=1,7
  3   F(K)=10.D16
      X=A
      C=0.D0
      F(1)=FUNCT(X)/3.
    4 X0=X
      IF((X0+4.*H-B)*S) 5,5,6
    6 H=(B-X0)/4.
      IF(H) 7,2,7
    7 DO 8 K=2,7
  8   F(K)=10.D16
      C=1.D0
    5 DI2=F(1)
      DI3=DABS(F(1))
      DO 9 K=2,5
      X=X+H
      IF((X-B)*S) 23,24,24
   24 X=B
   23 IF(F(K)-10.D16) 10,11,10
   11 F(K)=FUNCT(X)/3.
   10 DI2=DI2+P(K)*F(K)
    9 DI3=DI3+P(K)*ABS(F(K))
      DI1=(F(1)+4.*F(3)+F(5))*2.*H
      DI2=DI2*H
      DI3=DI3*H
      IF(REPS) 12,13,12
   13 IF(AEPS) 12,14,12
   12 EPS=DABS((AIABS+DI3)*REPS)
      IF(EPS-AEPS) 15,16,16
   15 EPS=AEPS
   16 DELTA=DABS(DI2-DI1)
      IF(DELTA-EPS) 20,21,21
   20 IF(DELTA-EPS/8.) 17,14,14
   17 H=2.*H
      F(1)=F(5)
      F(2)=F(6)
      F(3)=F(7)
      DO 19 K=4,7
  19  F(K)=10.D16
      GO TO 18
   14 F(1)=F(5)
      F(3)=F(6)
      F(5)=F(7)
      F(2)=10.D16
      F(4)=10.D16
      F(6)=10.D16
      F(7)=10.D16
   18 DI1=DI2+(DI2-DI1)/15.
      AI=AI+DI1
      AIH=AIH+DI2
      AIABS=AIABS+DI3
      GO TO 22
   21 H=H/2.
      F(7)=F(5)
      F(6)=F(4)
      F(5)=F(3)
      F(3)=F(2)
      F(2)=10.D16
      F(4)=10.D16
      X=X0
      C=0.D0
      GO TO 5
   22 IF(C) 2,4,2
    2 RETURN
      END
 
      SUBROUTINE SIMPU(A1,B1,H1,REPS1,AEPS1,FUNCT,X,AI,AIH,AIABS)
C SIMPT
C A1,B1 -THE LIMITS OF INTEGRATION
C H1 -AN INITIAL STEP OF INTEGRATION
C REPS1,AEPS1 - RELATIVE AND ABSOLUTE PRECISION OF INTEGRATION
C FUNCT -A NAME OF FUNCTION SUBPROGRAM FOR CALCULATION OF INTEGRAND +
C X - AN ARGUMENT OF THE INTEGRAND
C AI - THE VALUE OF INTEGRAL
C AIH- THE VALUE OF INTEGRAL WITH THE STEP OF INTEGRATION
C AIABS- THE VALUE OF INTEGRAL FOR MODULE OF THE INTEGRAND
C THIS SUBROGRAM CALCULATES THE DEFINITE INTEGRAL WITH THE RELATIVE OR
C ABSOLUTE PRECISION BY SIMPSON+S METHOD WITH THE AUTOMATICAL CHOICE
C OF THE STEP OF INTEGRATION
C IF AEPS1    IS VERY SMALL(LIKE 1.E-17),THEN CALCULATION OF INTEGRAL
C WITH REPS1,AND IF REPS1 IS VERY SMALL (LIKE 1.E-10),THEN CALCULATION
C OF INTEGRAL WITH AEPS1
C WHEN AEPS1=REPS1=0. THEN CALCULATION WITH THE CONSTANT STEP H1
C
      IMPLICIT REAL*8(A-H,O-Z)
      DIMENSION F(7),P(5)
      H=DSIGN(H1,B1-A1)
      S=DSIGN(1.D0,H)
      A=A1
      B=B1
      AI=0.D0
      AIH=0.D0
      AIABS=0.D0
      P(2)=4.D0
      P(4)=4.D0
      P(3)=2.D0
      P(5)=1.D0
      IF(B-A) 1,2,1
    1 REPS=DABS(REPS1)
      AEPS=DABS(AEPS1)
      DO 3 K=1,7
  3   F(K)=10.D16
      X=A
      C=0.D0
      F(1)=FUNCT(X)/3.
    4 X0=X
      IF((X0+4.*H-B)*S) 5,5,6
    6 H=(B-X0)/4.
      IF(H) 7,2,7
    7 DO 8 K=2,7
  8   F(K)=10.D16
      C=1.D0
    5 DI2=F(1)
      DI3=DABS(F(1))
      DO 9 K=2,5
      X=X+H
      IF((X-B)*S) 23,24,24
   24 X=B
   23 IF(F(K)-10.D16) 10,11,10
   11 F(K)=FUNCT(X)/3.
   10 DI2=DI2+P(K)*F(K)
    9 DI3=DI3+P(K)*ABS(F(K))
      DI1=(F(1)+4.*F(3)+F(5))*2.*H
      DI2=DI2*H
      DI3=DI3*H
      IF(REPS) 12,13,12
   13 IF(AEPS) 12,14,12
   12 EPS=DABS((AIABS+DI3)*REPS)
      IF(EPS-AEPS) 15,16,16
   15 EPS=AEPS
   16 DELTA=DABS(DI2-DI1)
      IF(DELTA-EPS) 20,21,21
   20 IF(DELTA-EPS/8.) 17,14,14
   17 H=2.*H
      F(1)=F(5)
      F(2)=F(6)
      F(3)=F(7)
      DO 19 K=4,7
  19  F(K)=10.D16
      GO TO 18
   14 F(1)=F(5)
      F(3)=F(6)
      F(5)=F(7)
      F(2)=10.D16
      F(4)=10.D16
      F(6)=10.D16
      F(7)=10.D16
   18 DI1=DI2+(DI2-DI1)/15.
      AI=AI+DI1
      AIH=AIH+DI2
      AIABS=AIABS+DI3
      GO TO 22
   21 H=H/2.
      F(7)=F(5)
      F(6)=F(4)
      F(5)=F(3)
      F(3)=F(2)
      F(2)=10.D16
      F(4)=10.D16
      X=X0
      C=0.D0
      GO TO 5
   22 IF(C) 2,4,2
    2 RETURN
      END
 
      FUNCTION SPENCE(X)
*
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER (F1=1.64493406684822618D0)
*
      IF(X)8,1,1
1     IF(X-.5D0)2,2,3
2     SPENCE=FSPENS(X)
      RETURN
3     IF(X-1.D0)4,4,5
4     SPENCE=F1-LOG(X)*LOG(1D0-X+1D-15)-FSPENS(1D0-X)
      RETURN
5     IF(X-2.D0)6,6,7
6     SPENCE=F1-.5D0*LOG(X)*LOG((X-1D0)**2/X)+FSPENS(1D0-1D0/X)
      RETURN
7     SPENCE=2D0*F1-.5D0*LOG(X)**2-FSPENS(1D0/X)
      RETURN
8     IF(X+1.D0)10,9,9
9     SPENCE=-.5D0*LOG(1D0-X)**2-FSPENS(X/(X-1D0))
      RETURN
10    SPENCE=-.5D0*LOG(1D0-X)*LOG(X**2/(1D0-X))-F1+FSPENS(1D0/(1D0-X))
      END
 
      FUNCTION FSPENS(X)
*
      IMPLICIT REAL*8(A-H,O-Z)
*
      A=1D0
      F=0D0
      AN=0D0
      TCH=1D-16
1     AN=AN+1D0
      A=A*X
      B=A/AN**2
      F=F+B
      IF(B-TCH)2,2,1
2     FSPENS=F
      END
 
      FUNCTION TET(X)
*
      IMPLICIT REAL*8(A-H,O-Z)
*
      IF(X.LT.0D0) THEN
        TET=0D0
      ELSE
        TET=1D0
      ENDIF
*
      END
 
      SUBROUTINE RHOCC(S,Q2,U,QI,QJ,QK,QL,ROW)
* ------ FORMER NAME OF THE ROUTINE: ROWAL
* BEFORE USE OF RHOCC AT LEAST ONE CALL OF DIZET MUST BE DONE.
* SEE ALSO THE COMMENTS THERE.
*---------------------------------------------------------------------
* THIS ROUTINE CALCULATES THE WEAK CHARGED CURRENT FORM FACTOR FOR
* THE 4-FERMION SCATTERING CROSS SECTION. THE PROBLEMS CONNECTED WITH
* THE SEPARATION OF SOMETHING WHICH ONE CAN CALL QED-PART ARE DISCUSSED
* IN REF. 6, SEE ALSO REF. 3. (BOTH GIVEN IN ROUTINE DIZET).
*----------------------------------------------------------------------
* EXAMPLES OF THE USE OF THIS ROUTINE MAY BE FOUND IN THE PACKAGE
* TERAD91, SEE ALSO DISEPCC.
*----------------------------------------------------------------------
* INPUT FROM USER:
*            S,Q2,U - THE KINEMATIC INVARIANTS FOR THE QUARK PROCESS
*                     (S+T-U=0)
*       QI,QJ,QK,QL - THE CHARGES OF THE FOUR FERMIONS IN THE PROCESS
* OUTPUT OF THE ROUTINE:
*               ROW - THE FORM FACTOR
*---------------------------------------------------------------------
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      COMMON/CDZFLG/IHVP,IAMT4,IQCD,IMOMS,IMASS,IALEM,IMASK,IBARB,IFTJR
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZWSC/SL2,SQ2,W0,W0F,Z0,Z0F,DWZ0R1,DWZ0F,XWM1,XWM1F,XZM1,
     &      XZM1F,XWZ1R1,XDWZ1F,XZFM1,XZFM1F,XAMM1,XAMM1F,XWFM1,XWFM1F
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
      COMMON/CDZZWG/AMZ,AMH,GMU,A0,GAMZ,GAMW,CALSZ,CALST,CALXI,CALQED
*
      SI=1D0
      SJ=1D0
      SK=1D0
      SL=1D0
      QIM=ABS(QI)
       IF(QIM.NE.0)  SI=QI/QIM
      QJM=ABS(QJ)
       IF(QJM.NE.0)  SJ=QJ/QJM
      QKM=ABS(QK)
       IF(QKM.NE.0)  SK=QK/QKM
      QLM=ABS(QL)
       IF(QLM.NE.0)  SL=QL/QLM
      RDWB=DREAL(XDWB(Q2))
      RDWF=DREAL(XDWF(Q2))
      DBAL=RDWB+RDWF
      W0AL =W0+W0F
      WM1AL=DREAL(XWM1+XWM1F)
      QMIJ =QIM*QJM+QKM*QLM
      QMIK =QIM*QKM+QJM*QLM
      QMIL =QIM*QLM+QJM*QKM
      V1BZ =DREAL(XV1B(Q2,AMZ2))
      UBW  =UB(Q2,AMW2)
      V2BWZ=V2B(Q2,AMW2,AMZ2)
      ROBW =DREAL(XROBW(Q2,AMW2,AMZ2))
      BQSWZ=BF(Q2,S,AMW2,AMZ2)
      BQUWZ=BF(Q2,U,AMW2,AMZ2)
      AQUSWZ=AF(Q2,U,S,AMW2,AMZ2)
      AL4PI=1D0/ALFAI/PI/4D0
      ROW=1D0+AL4PI/R1*(DBAL-W0AL+WM1AL+5D0/8D0*R*(1D0+R)-11D0/2D0
     &-9D0/4D0*R*ALR/R1+(-1D0+1D0/2D0/R-R12/R*QMIJ)*V1BZ+2D0*R*V2BWZ
     &-R1*UBW+ROBW+(2D0-1D0/R+2D0*R12/R*QMIK)*S*(Q2+AMW2)*BQSWZ
     &+(2D0-1D0/R+2D0*R12/R*QMIL)*(Q2+AMW2)*(U*BQUWZ-AQUSWZ))
C****************************************************************
      SM=ABS(S)
      UM=ABS(U)
      Q2M =ABS(Q2)
      ALQW=LOG(Q2M/AMW2)
      ALSW=LOG(SM/AMW2)
      ALUW=LOG(UM/AMW2)
C****************************************************************
      PI2=PI**2
      FF1=PI2/6D0
      SW=S/AMW2
      UW=U/AMW2
      QW=Q2/AMW2
      ROWADD=AL4PI*(QMIJ*(4D0 -2D0*FF1-PI2*TET(-Q2))
     & -QMIK*((LOG(SM/Q2M))**2-2D0*FF1-PI2*TET(S))
     & -QMIL*((LOG(UM/Q2M))**2-2D0*FF1-PI2*TET(U))
     & -.5D0+2D0*(FF1-SPENCE(1D0+SW)-4D0*SPENCE(-QW)
     & -4D0*LOG(ABS(1D0+QW))*LOG(ABS(SW)))
     & -2D0*QMIL*(SPENCE(1D0+UW)-SPENCE(1D0+SW)+2D0*
     & LOG(ABS(1D0+QW))*LOG(ABS(U/S))+(Q2+AMW2)*AA00(Q2,U,S,AMW2)))
      ROW=ROW+ROWADD
*
      Q2M=-Q2
      ALST=CALXI
      SW2=R1
      AMT2=AMQ(5)**2
      XZERO=DCMPLX(0D0,0D0)
      XRQCD=XZERO
      IF(IQCD-1) 1,2,3
2     XRQCD=AL4PI*XCQCDS(ALST,SW2,AMT2,Q2M)
      GOTO 1
3     XRQCD=AL4PI*XRCQCD(ALST,SW2,AMT2,Q2M)
1     CONTINUE
      ROW=ROW+DREAL(XRQCD)
*
      END
 
      FUNCTION XCQCDS(ALST,SW2,AMT2,S)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
*
* CALPI/4 IS OMITTED
*
      DATA EPS/1.D-3/
      ALTW=-AMT2/AMW2
      ALTS=-AMT2/S
      SMW2=S/AMW2
      DMW2=1D0-SMW2
      XPWFTS=XPWFI(ALTS)
      XPWFTW=XPWFI(ALTW)
      IF(ABS(DMW2).LT.EPS) GO TO 1
      XCQCDS=ALST/(3D0*PI*SW2)*(
     *      +AMT2/4D0/AMW2*(1D0/DMW2*(XPWFTW-XPWFTS)-XPWFTW)
     *      -AMT2/AMW2*(PI2/2D0+105D0/8D0))
      RETURN
1     XDWFTW=XDPWFI(ALTW)
      XCQCDS=ALST/(3D0*PI*SW2)*(AMT2/4D0/AMW2*(
     *      +XDWFTW/ALTW-XPWFTW)-AMT2/AMW2*(PI2/2D0+105D0/8.D0))
*
      END
 
      FUNCTION XRCQCD(ALST,SW2,AMT2,S)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
*
* CALPI/4 IS OMITTED
*
      DATA EPS/1.D-3/
      ALTW=-AMT2/AMW2
      ALTS=-AMT2/S
      SMW2=S/AMW2
      DMW2=1D0-SMW2
      XPWFTS=XPWF(ALTS)
      XPWFTW=XPWF(ALTW)
      IF(ABS(DMW2).LT.EPS) GO TO 1
      XRCQCD=ALST/(3D0*PI*SW2)*
     &      (AMT2/4D0/AMW2*(1D0/DMW2*(XPWFTW-XPWFTS)-XPWFTW)
     *      -AMT2/AMW2*(PI2/2D0+105D0/8D0))
      RETURN
1     XDWFTW=XDPWF(ALTW)
      XRCQCD=ALST/(3D0*PI*SW2)*(AMT2/4D0/AMW2*(
     *      +XDWFTW/ALTW-XPWFTW)-AMT2/AMW2*(PI2/2D0+105D0/8D0))
*
      END
 
      FUNCTION XDPWF(ALTW)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
* DERIVATIVE OF XPDF IS STILL MISSING HERE
      XDPWF=(0D0,0D0)
*
      END
 
      FUNCTION XDPWFI(ALTW)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
* DERIVATIVE OF XPDFI IS STILL MISSING HERE
      XDPWFI=(0D0,0D0)
*
      END
 
      FUNCTION AA00(Q2,U,S,AMW2)
      IMPLICIT REAL*8(A-H,O-Z)
*
      SW=S/AMW2
      UW=U/AMW2
      QW=Q2/AMW2
      AA00=1D0/S*(-LOG(ABS(UW))+(1D0+1D0/QW)*LOG(ABS(1D0+QW))
     & +(2D0-Q2/S-1D0/SW)*(SPENCE(1D0+QW)-SPENCE(1D0+UW)
     & +LOG(ABS(1D0+QW))*LOG(ABS(Q2/U))))
*
      END
 
      FUNCTION XK3(Q2,AM12,AM22)
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      PI=4D0*ATAN(1D0)
      PI2=PI**2
      Q2M=Q2+AM12+AM22
      Q2TR=Q2M+2D0*SQRT(AM12*AM22)
      ALAM=Q2M*Q2M-4D0*AM12*AM22
      XDL2=ALAM*(XJ(Q2,AM12,AM22))**2-(LOG(AM12/AM22))**2
      IF(Q2TR)1,1,2
1     XK3=.25D0*XDL2-PI2
      RETURN
2     XK3=.25D0*XDL2
*
      END
 
      FUNCTION UB(Q2,AMV2)
      IMPLICIT REAL*8(A-H,O-Z)
      DATA EPS/1D-3/
*
C  FUNCTION UB(Q2,AMW2) IS EQUAL TO 2.*UBAR+(1.+AIN)*LOG(ABS(1.+A))
      A=Q2/AMV2
      AIN=1D0/A
      IF(ABS(A).LT.EPS) GO TO 3
      UB=-43D0/6D0-13D0/6D0*AIN
     &+(-2D0/3D0+13D0/6D0*AIN)*(1D0+AIN)*LOG(ABS(1D0+A))
      RETURN
3     UB=-27D0/4D0-25D0/36D0*A
*
      END
 
      FUNCTION BF(Q2,X,AM12,AM22)
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON/CDZFBF/CQ2,CX,CM12,CM22
      EXTERNAL BFIND
      DATA EPS/.001D0/
*
      RQ1=Q2/AM12
      RX1=X/AM12
      IF(ABS(RQ1).LT.EPS.AND.ABS(RX1).LT.EPS) GO TO 11
      CQ2=Q2
      CX=X
      CM12=AM12
      CM22=AM22
      CALL SIMPS(0D0,1D0,.1D0,EPS,1D-30,BFIND,Y,R1,R2,R3)
      BF=R1
      RETURN
11    AR=AM12/AM22
      AR1=1D0-AR
      ALR=LOG(AR)
      ALX=LOG(ABS(RX1))
      IF(AR1)12,13,12
12    BF=
     &(1D0-ALX+AR/AR1*ALR+RQ1/(AR1**2)*(-.5D0*AR*(1D0+AR)-AR**2/AR1*ALR)
     *+RX1*((1D0+AR)*(-.5D0+ALX)/2D0-.5D0*AR**2/AR1*ALR))/AM12/AM22
      RETURN
13    BF=(-ALX+RX1*ALX-RQ1/6D0)/(AM12**2)
*
      END
 
      FUNCTION BFIND(Y)
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON/CDZFBF/Q2,X,AM12,AM22
      DATA EPS/1D-8/
*
      Y1=1D0-Y
      AMY2=Y*AM12+Y1*AM22
      AMY4=AMY2**2
      AKY2=Y*Y1*Q2+AMY2
      D=X*AKY2+AMY4
      R=X*AKY2/AMY4
      IF(ABS(R+1D0).GT.EPS) GO TO 1
      BFIND=1D0/AMY4
      RETURN
1     BFIND=-LOG(ABS(R))/D
*
      END
 
      FUNCTION AF(Q2,AX,AY,AM12,AM22)
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
*
      DATA EPS/1D-3/,EPSVAX/5D-39/
      F1=PI**2/6D0
      RQ1=Q2/AM12
      RX1=AX/AM12
      AR=AM12/AM22
      AR1=1D0-AR
      ALR=LOG(AR)
      IF(ABS(RQ1).LT.EPS.AND.ABS(RX1).LT.EPSVAX) GO TO 1
C--
      ALX=LOG(ABS(RX1))
      BFX=BF(Q2,AX,AM12,AM22)
      CFX=2D0*F1-SPENCE(1D0+AX/AM12)-SPENCE(1D0+AX/AM22)
     &+2D0*DREAL(XK3(Q2,AM12,AM22))+(Q2+AM12+AM22)*AX*BFX
      AF=(-ALX+(-1D0+AR1/AR/RQ1)/2D0*ALR+DREAL(XL(Q2,AM12,AM22))/Q2/2D0
     &-AM12*AM22*BFX+(1D0-(Q2+AM12+AM22)/AY/2D0)*CFX)/AY
      RETURN
1     IF(AR1)2,3,2
2     AF=(-3D0/2D0*ALR/AR1+RX1*(7D0/18D0 + 2D0/3D0*AR/AR1*ALR)+
     *5D0/6D0*RQ1*AR/(AR1**2)*(2D0+(1D0+AR)/AR1*ALR))/AM22
      RETURN
3     AF=(3D0/2D0-5D0/18D0*RX1-5D0/36D0*RQ1)/AM12
*
      END
 
      FUNCTION XROBW(Q2,AM12,AM22)
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
C  ROB(Q2,AM12,AM22)=-R*(Q2+AMV2)*OMEGA(Q2,AM12,AM22)-BAR
      COMMON/CDZWSM/AMW2,AMZ2,RC,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      DATA EPS/1D-3/
*
      R=AM12/AM22
      R1=1D0-R
      R12=R1**2
      R13=R1**3
      A1=Q2/AM12
      IF(ABS(A1).LT.EPS) GO TO 1
      XROBW=4D0/3D0*R**2+19D0/12D0*R-1D0/12D0-1D0/12D0*R12*AM12/Q2
     &+(3D0/8D0*R**2+R/3D0+1D0/24D0
     &+R1*(-R/3D0-11D0/24D0+1D0/24D0/R)*AM12/Q2+1D0/24D0/R*R13*
     &(AM12/Q2)**2)*LOG(R)+(-3D0/8D0*R**2-R/2D0+1D0/24D0+1D0/24D0*R12*
     &AM12/Q2)/Q2*XL(Q2,AM12,AM22)+4D0*(RC+R*AM12/Q2)*XK3(Q2,AM12,AM22)
      RETURN
1     IF(R1)2,3,2
2     XROBW=5D0/8D0*R*(1D0+R)
     &+A1*(-7D0/18D0*R**2+R/24D0+13D0/6D0*R**3/R12)
     &+(3D0*R-9D0/4D0*R/R1+A1*(-4D0*RC*R/R1+R**2/R1/12D0
     &+13D0/12D0*R**3*(1D0+R)/R13))*LOG(R)
      RETURN
3     XROBW=3.5D0+A1*(4D0*RC-11D0/18D0)
*
      END
 
      FUNCTION V2B(Q2,AM12,AM22)
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      DATA EPS/1D-3/
*
      R=AM12/AM22
      R1=1D0-R
      R12=R1*R1
      R13=R12*R1
      RA=(1D0+10D0/R+1D0/R**2)*(1D0+R)/24D0
      AQ=AM12/Q2
      A1=Q2/AM12
      IF(ABS(A1).LT.EPS) GO TO 1
      V2B=-4D0/3D0*R+5D0/2D0-4D0/3D0/R+2*RA*AQ
     &+R1*(-3D0/8D0*R1/R+1D0/3D0*(1D0-1D0/2D0/R+1D0/R**2)*AQ-RA/R*AQ**2)
     &*LOG(R)+(3D0/8D0*R+5D0/12D0+3D0/8D0/R-RA*AQ)/Q2
     &*DREAL(XL(Q2,AM12,AM22))
     &+2D0/R*(-(1D0+R)*AQ+AQ**2)*DREAL(XK3(Q2,AM12,AM22))
      RETURN
1     IF(R1)2,3,2
2     V2B=-5D0/8D0*R+11D0/4D0-5D0/8D0/R+A1*(1D0+R)/R12/18D0*(7D0*R**2
     &-23D0*R+7D0)+(-3D0/4D0/R+3D0/2D0/R1-R*(R**2+4D0*R+1D0)/R13/6D0*A1)
     &*LOG(R)
      RETURN
3     V2B=7D0/9D0*A1
*
      END
 
      FUNCTION XDWB(Q2)
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZWSC/SL2,SQ2,W0,W0F,Z0,Z0F,DWZ0R1,DWZ0F,XWM1,XWM1F,XZM1,
     &      XZM1F,XWZ1R1,XDWZ1F,XZFM1,XZFM1F,XAMM1,XAMM1F,XWFM1,XWFM1F
      DATA EPS/1D-3/
*
      QW=(Q2+AMW2)/AMW2
      IF(ABS(QW-1D0).LT.EPS) GO TO 3
      IF(ABS(QW).LT.EPS) GO TO 1
      XDRWH=(XL(Q2,AMW2,AMH2)-XL(-AMW2,AMW2,AMH2))/QW/AMW2
      XDRWZ=(XL(Q2,AMW2,AMZ2)-XL(-AMW2,AMW2,AMZ2))/QW/AMW2
      GO TO 2
1     XDRWH=2D0+QW/(RW-4D0)
     &         +(RW-2D0*QW/(RW-4D0))*AMW2*XJ(-AMW2,AMW2,AMH2)
      XDRWZ=2D0+QW*R/(1D0-4D0*R)
     &         +(1D0/R-2D0*QW*R/(1D0-4D0*R))*AMW2*XJ(-AMW2,AMW2,AMZ2)
2     CONTINUE
      AQ=AMW2/Q2
      XWH=-1D0/12D0*RW12*AQ+1D0/24D0*(1D0+RW1*(-10D0+5D0*RW-RW2)*AQ
     &+RW1*RW12*AQ**2)*ALRW+(-11D0+4D0*RW-RW2+RW12*AQ)/24D0/Q2
     &*XL(Q2,AMW2,AMH2)+(1D0/2D0-RW/6D0+RW2/24D0)*XDRWH
      XWL=(-3D0/8D0*R2+R+25D0/12D0-2D0/3D0/R-1D0/24D0/R2
     &+R12*(1D0+10D0/R+1D0/R2)*AQ/24D0)/Q2*XL(Q2,AMW2,AMZ2)
     &+(-2D0*R-17D0/6D0+2D0/3D0/R+1D0/24D0/R2)*XDRWZ
      XDWB=4D0/3D0*R2+7D0/12D0*R+253D0/36D0
     &+(-R2+2D0*R+8D0-8D0/R-1D0/R2)/12D0*AQ
     &+(3D0/8D0*R2+11D0/6D0*R+2D0/3D0
     &+R1*(-8D0*R+35D0+61D0/R-15D0/R2-1D0/R**3)/24D0*AQ
     &+R1*R12*(1D0/R+10D0/R2+1D0/R**3)/24D0*AQ**2)*ALR
     &+R1*(-2D0+17D0/6D0*AQ+5D0/6D0*AQ**2)*LOG(ABS(1D0+1D0/AQ))+XWL+XWH
      RETURN
3     XDWB=W0-XWM1+Q2/AMW2*(XWM1-7D0/18D0*R2-31D0/24D0*R+319D0/36D0
     &-5D0/8D0/R+RW/8D0+2D0*R2/R12-(RW/3D0+.5D0)/RW12
     &+(5D0/6D0*R-43D0/12D0-3D0/4D0/R+23D0/4D0/R1
     &+(1D0+R)*R2/R12/R1)*ALR-(7D0/4D0+5D0*RW2/6D0/RW1)*RW/RW12*ALRW)
*
      END
 
      FUNCTION FBARB(X)
      IMPLICIT REAL*8(A-Z)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      DATA P1/-0.74141D0/,P2/ -11.483D0  /,P3/  9.6577D0/,
     &     P4/ -6.7270D0/,P5/  3.0659D0  /,P6/-0.82053D0/,
     &     P7/ 0.11659D0/,P8/-0.67712D-02/
      IF(X.LE.4D0) THEN
        FBARB=P1+P2*X+P3*X**2+P4*X**3+P5*X**4+P6*X**5+P7*X**6+P8*X**7
         ELSE
        RBTH=1/X**2
        ALRB=LOG(RBTH)
        FBARB=49D0/4D0+PI2+27D0/2D0*ALRB+3D0/2D0*ALRB**2
     &       +RBTH/3D0*(2D0-12D0*PI2+12D0*ALRB-27D0*ALRB**2)
     &       +RBTH**2/48D0*(1613-240*PI2-1500*ALRB-720 *ALRB**2)
      ENDIF
*
      END
 
      FUNCTION FBARBB(X)
C 13/10/1992 - Barbieri's m_t^4 are implemented
      IMPLICIT REAL*8(A-Z)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
* Approximation from 0 to 4 (Mhiggs/mtop)
      DATA P1/ 5.6807D0/,P2/ -11.015D0  /,P3/ 12.814D0/,
     &     P4/-9.2954D0/,P5/  4.3305D0  /,P6/-1.2125D0/,
     &     P7/0.18402D0/,P8/-0.11582D-01/
      IF(X.LE.4D0) THEN
        FBARBB=P1+P2*X+P3*X**2+P4*X**3+P5*X**4+P6*X**5+P7*X**6+P8*X**7
         ELSE
        RBTH=1/X**2
        ALRB=LOG(RBTH)
        FBARBB=1D0/144*(311D0+24*PI2+282*ALRB+90*ALRB**2
     &        -4D0*RBTH*(40D0+ 6*PI2+ 15*ALRB+18*ALRB**2)
     &        +3D0*RBTH**2*(242.09D0-60*PI2-454.2D0*ALRB-180*ALRB**2))
      ENDIF
*
      END
 
      SUBROUTINE QCDCOF(SQS,AMT,SW2,ALQED,ALFAS,ALFAT,ALFAXI,QCDCOR)
      IMPLICIT REAL*8(A-H,J-Z)
*
      COMMON /CDZSCT/ ISCRE,ISCAL,IAFMT,IFACR,IFACT,IHIGS
      COMMON /CDZZER/ PI,ALPHAQ,ANF
      COMMON /CDZPHM/ CMASS,BMASS,TMASS
      COMMON /CDZINP/ BMASSI
      COMMON /CDZRUN/ CMQRUN(8)
      DIMENSION QCDCOR(0:14)
      DIMENSION AMQRUN(6),CHARQU(6)
      DIMENSION SCTAVR(6),SCTPLU(6),SCTMIN(6)
      EXTERNAL  ZALPHAS
      DATA AMQRUN/0D0,0D0,.750D0,.075D0,0D0,2.40D0/
      DATA SCTAVR/.20D0,.19D0,.18D0,.17D0,.15D0,.13D0/
      DATA SCTPLU/.09D0,.10D0,.10D0,.10D0,.09D0,.08D0/
      DATA SCTMIN/.05D0,.04D0,.04D0,.04D0,.04D0,.04D0/
* ISCAL=1,2,3 ARE NOT UP TO DATE, SEE KNIEHL's CONTRIBUTION:
* GAMES WITH THE SCALE FOR THE ALFA*ALFAS(SCALET*AMT) CORRECTIONS
      SCALET=1D0
      IF(ISCAL.NE.0) THEN
       IF(AMT.LE.126D0                 ) INDSCT=1
       IF(AMT.GT.126D0.AND.AMT.LE.151D0) INDSCT=2
       IF(AMT.GT.151D0.AND.AMT.LE.176D0) INDSCT=3
       IF(AMT.GT.176D0.AND.AMT.LE.201D0) INDSCT=4
       IF(AMT.GT.201D0.AND.AMT.LE.226D0) INDSCT=5
       IF(AMT.GT.226D0                 ) INDSCT=6
      ENDIF
      IF(ISCAL.EQ.1    ) THEN
       SCALET=SCTAVR(INDSCT)+SCTPLU(INDSCT)
      ELSEIF(ISCAL.EQ.2) THEN
       SCALET=SCTAVR(INDSCT)
      ELSEIF(ISCAL.EQ.3) THEN
       SCALET=SCTAVR(INDSCT)-SCTMIN(INDSCT)
      ELSEIF(ISCAL.EQ.4) THEN
       SCALET=.204D0
      ENDIF
*
* PHYSICAL QUARK MASSES, ACCORDING TO OKUN@VOLOSHIN (1.3 and 4.8).
      CMASS=1.5D0
      BMASS=4.7D0
      TMASS=AMT
      ALFAT=0D0
      ALFAXI=0D0
*
      DO IQ=0,14
      QCDCOR(IQ)=1D0
      ENDDO
      DO IQ=1,3
      CHARQU(2*IQ-1)=2D0/3
      CHARQU(2*IQ  )=1D0/3
      ENDDO
      DO IMQ=1,6
      CMQRUN(IMQ)=AMQRUN(IMQ)
      ENDDO
      CMQRUN(3)=CMASS
      CMQRUN(6)=BMASS
      IF(ALFAS.LT.1D-10) RETURN
*
* NUMERICAL CONSTANTS
      PI=4D0*ATAN(1D0)
      PI2=PI**2
      D2=PI2/6D0
      D3=1.2020569031596D0
*
* COEFFICIENTS OF BETA AND GAMA FUNCTIONS
      IF (SQS.LE.CMASS) THEN
       ANF=3D0
        ELSEIF(SQS.LE.BMASS) THEN
       ANF=4D0
        ELSEIF(SQS.LE.TMASS) THEN
       ANF=5D0
        ELSE
       ANF=6D0
      END IF
      B0=11D0-2D0/3D0*ANF
      B1=102D0-38D0/3D0*ANF
      B2=.5D0*(2857D0-5033D0/9D0*ANF+325D0/27D0*ANF**2)
      ANF4=4D0
      B04=11D0-2D0/3D0*ANF4
      B14=102D0-38D0/3D0*ANF4
      B24=.5D0*(2857D0-5033D0/9D0*ANF4+325D0/27D0*ANF4**2)
*
      AMIN=LOG(SQS**2/1D-3)
      AMAX=LOG(SQS**2/1D+1)
      ALPHAQ=ALFAS
      CALL DZERO(AMIN,AMAX,ROOT,DUM,1D-3,100,ZALPHAS)
      ALMSB5=SQS*EXP(-ROOT/2)
      ALMSB4=ALMSB5*(BMASS/ALMSB5)**(2D0/25)
     &      *(2*LOG(BMASS/ALMSB5))**(963D0/14375)
      ALMSB6=ALMSB5*(ALMSB5/TMASS)**(2D0/21)
     &      *(2*LOG(TMASS/ALMSB5))**(-107D0/1127)
      ALMC2=LOG(CMASS**2/ALMSB4**2)
      ALMB2=LOG(BMASS**2/ALMSB5**2)
      ALMS2=LOG(SQS**2  /ALMSB5**2)
      ALMT2=LOG((       TMASS)**2/ALMSB5**2)
      ALMX2=LOG((SCALET*TMASS)**2/ALMSB5**2)
      ALFAPI=ALFAS/PI
*
*
* BETA/GAMA - COEFFICIENTS FROM CHE., KUE., KWI., PL,B282(1992)221-227.
      BETA0=B0/4
      BETA1=B1/16
      BETA2=B2/64
      GAMA0=1
      GAMA1=(202D0/3-20D0/9*ANF)/16
      GAMA2=(1249-(2216D0/27+160D0/3*D3)*ANF-140D0/81*ANF**2)/64
      GAMA2=(1249-(2216D0/27+160D0/3*D3)*ANF-140D0/81*ANF**2)/64
*
* BETA/GAMA - COEFFICIENTS FOR ANF=4
      BETA04=B04/4
      BETA14=B14/16
      BETA24=B24/64
      GAMA04=1
      GAMA14=(202D0/3-20D0/9*ANF4)/16
      GAMA24=(1249-(2216D0/27+160D0/3*D3)*ANF4-140D0/81*ANF4**2)/64
      GAMA24=(1249-(2216D0/27+160D0/3*D3)*ANF4-140D0/81*ANF4**2)/64
*
* RUNNING C-MASS, EQS(28-29) FROM CHE., KWI., PL,B305(1993)285-294.
* TREATMENT ACCORGING TO GIAMPIERO PASSARINO
      ALFBPI=ALPHAS(ALMB2)/PI
      ALFSPI=ALPHAS(ALMS2)/PI
      ANF=4D0
      ALFCPI=ALPHAS(ALMC2)/PI
      ANF=5D0
      ALFTPI=ALPHAS(ALMT2)/PI
      ALFXPI=ALPHAS(ALMX2)/PI
      ALFAT =ALFTPI*PI
      ALFAXI=ALFXPI*PI
*
CBARD AMCAMC=CMASS*(1-4D0/3*ALFCPI-(13.3D0-16D0/9)*ALFCPI**2)
      AMCAMC=CMASS/(1+4D0/3*ALFCPI+13.3D0*ALFCPI**2)
*
      COEF1=GAMA1/BETA0-BETA1*GAMA0/BETA0**2
      COEF2=GAMA2/BETA0-BETA1*GAMA1/BETA0**2-BETA2*GAMA0/BETA0**2
     &                                      +BETA1**2*GAMA0/BETA0**3
      COEF14=GAMA14/BETA04-BETA14*GAMA04/BETA04**2
      COEF24=GAMA24/BETA04-BETA14*GAMA14/BETA04**2
     &      -BETA24*GAMA04/BETA04**2+BETA14**2*GAMA04/BETA04**3
      AMCRUB=AMCAMC*(ALFBPI/ALFCPI)**(GAMA04/BETA04)
     &      *(1+COEF14*(ALFBPI-ALFCPI)+.5D0*COEF14**2*(ALFBPI-ALFCPI)**2
     &         +.5D0*COEF24*(ALFBPI**2-ALFCPI**2))
      AMCRUN=AMCRUB*(ALFAPI/ALFBPI)**(GAMA0/BETA0)
     &      *(1+COEF1*(ALFAPI-ALFBPI)+.5D0*COEF1**2*(ALFAPI-ALFBPI)**2
     &         +.5D0*COEF2*(ALFAPI**2-ALFBPI**2))
      AMQRUN(3)=AMCRUN
*
* RUNNING B-MASS, EQS(28-29) FROM CHE., KWI., PL,B305(1993)285-294.
      AMBAMB=BMASS*(1-4D0/3*ALFBPI-(12.4D0-16D0/9)*ALFBPI**2)
*
      COEF1=GAMA1/BETA0-BETA1*GAMA0/BETA0**2
      COEF2=GAMA2/BETA0-BETA1*GAMA1/BETA0**2-BETA2*GAMA0/BETA0**2
     &                                      +BETA1**2*GAMA0/BETA0**3
      AMBRUN=AMBAMB*(ALFAPI/ALFBPI)**(GAMA0/BETA0)
     &      *(1+COEF1*(ALFAPI-ALFBPI)+.5D0*COEF1**2*(ALFAPI-ALFBPI)**2
     &         +.5D0*COEF2*(ALFAPI**2-ALFBPI**2))
      AMQRUN(6)=AMBRUN
*
      DO IMQ=1,6
      CMQRUN(IMQ)=AMQRUN(IMQ)
      ENDDO
*
      IF(SQS.LT.20D0) SQS=20D0
*
      RATU=-(1D0+4D0/3*SW2)/(1-8D0/3*SW2)
      RATD=+(1D0+4D0/3*SW2)/(1-4D0/3*SW2)
      RATV=+(1D0+4D0/3*SW2)**2
*
      DO 10 IQ=1,6
      SINS=(-1)**IQ
      IF(SINS.LT.0D0) THEN
        RAT=RATU
          ELSE
        RAT=RATD
      ENDIF
      RAT=0d0
cb    if(iq.ne.6) sins=0
      AMRUN=AMQRUN(IQ)
      RLMT=SQS**2/AMT**2
      ALMT=LOG(RLMT)
      CAI2=-37D0/12+ALMT+7D0/81*RLMT+.0132*RLMT**2
      CAI3=-5651D0/216+8D0/3+23D0/6*D2+D3+67D0/18*ALMT+23D0/12*ALMT**2
      QCDCOR(2*IQ-1)=1+ALFAPI+1D0/4*ALQED/PI*CHARQU(IQ)**2*(3-ALFAPI)
     &          +(1.40923D0+(44D0/675-2D0/135*ALMT)*RLMT)*ALFAPI**2
     &          +(-12.76706D0-0.41318*RAT)*ALFAPI**3
     &+12*AMQRUN(IQ)**2/SQS**2*ALFAPI*(1+8.7D0*ALFAPI+45.15D0*ALFAPI**2)
      QCDCOR(2*IQ  )=1+ALFAPI+1D0/4*ALQED/PI*CHARQU(IQ)**2*(3-ALFAPI)
     &   +(1.40923D0+(44D0/675-2D0/135*ALMT)*RLMT+SINS*CAI2)*ALFAPI**2
     &   +(-12.76706+SINS*CAI3)*ALFAPI**3
     &   -6*AMQRUN(IQ)**2/SQS**2*
     &                      (1+11D0/3*ALFAPI+(11.286D0+ALMT)*ALFAPI**2)
     &         -10*AMQRUN(IQ)**2/AMT**2*(8D0/81-1D0/54*ALMT)*ALFAPI**2
  10  CONTINUE
      RAT=(1+4D0/3*SW2)**2
      QCDCOR(13)=1+(-0.41318*RAT)*ALFAPI**3
      QCDCOR(14)=1
*
      END
 
      FUNCTION ZALPHAS(A)
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON /CDZZER/ PI,ALPHAQ,ANF
      B=LOG(A)
      B0=11D0-2D0/3D0*ANF
      B1=102D0-38D0/3D0*ANF
      B2=.5D0*(2857D0-5033D0/9D0*ANF+325D0/27D0*ANF**2)
      C=B1/(B0**2*A)
      ZALPHAS=ALPHAQ-
     &     4D0*PI/(B0*A)*(1D0-C*B+C**2*((B-.5D0)**2+B2*B0/B1**2-1.25D0))
      END
 
      FUNCTION ALPHAS(A)
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON /CDZZER/ PI,ALPHAQ,ANF
      B=LOG(A)
      B0=11D0-2D0/3D0*ANF
      B1=102D0-38D0/3D0*ANF
      B2=.5D0*(2857D0-5033D0/9D0*ANF+325D0/27D0*ANF**2)
      C=B1/(B0**2*A)
      ALPHAS=
     &     4D0*PI/(B0*A)*(1D0-C*B+C**2*((B-.5D0)**2+B2*B0/B1**2-1.25D0))
      END
 
      FUNCTION AFMT3(ALST)
*
      IMPLICIT REAL*8(A-H,O-Z)
*
* NUMERICAL CONSTANTS
      PI=ATAN(1D0)*4D0
      PI2=PI**2
      D2=PI2/6D0
      D3=1.2020569031596D0
      D4=PI2**2/90
      AL2=LOG(2D0)
      TS2=+0.2604341376322D0
      TD3=-3.0270094939877D0
      TB4=-1.7628000870738D0
      AMT2=(175D0)**2
      AMU2=AMT2
      ALMU=LOG(AMU2/AMT2)
      NF=6
      CA1=-2D0/3*(1+2*D2)
      CA2=157D0/648-3313D0/162*D2-308D0/27*D3+143D0/18*D4-4D0/3*D2*AL2
     & +441D0/8*TS2-1D0/9*TB4-1D0/18*TD3-(1D0/18-13D0/9*D2+4D0/9*D3)*NF
     & -(11D0/6-1D0/9*NF)*(1+2*D2)*ALMU
      AFMT3=CA1*ALST/PI+CA2*(ALST/PI)**2
*
      END