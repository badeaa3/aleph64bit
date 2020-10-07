      subroutine ugtsec
      return
      end
C*HE 03/03/95 16:35:37 C
C*DK ASKUSI
      SUBROUTINE ASKUSI(IGCOD)
C--------------------------------------------------------------------
C
C                G. Bonneaud  June 1989
C
C                       Initialisation
C
C--------------------------------------------------------------------
C*CA BCS
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      PARAMETER (LBCS=50000,LCHAR=4)
      COMMON/BCS/ IW(LBCS)
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C*CC BCS
C*CA COUNTR
      COMMON / COUNTR / NEVENT(11),NEVPHO(2)
C*CC COUNTR
C*CA INPOUT
      COMMON / INPOUT / LWRITE
C*CC INPOUT
C
      PARAMETER ( IGCO = 7002)
C
      DIMENSION SVRT(3),GPAR(23)
      INTEGER ALTABL
C
C   Return the generator code as defined in the KINGAL library
C
      IGCOD = IGCO
      LWRITE = IW(6)
      WRITE(LWRITE,101) IGCOD
 101  FORMAT(/,10X,
     &       'ESTA01 - CODE NUMBER =',I4,' Last mod. April  1999',
     & /,10X,'***********************************************',//)
C
C   Get Generator parameters
C
C...  Monte carlo parameters :
C CME    : center of mass energy (GeV);
C XMZ    : Z0 mass (in GeV);
C SW2    : Sin(theta-w)**2;
C NF     : Number of fermion families;
C ... for the standard model diagrams the options are the following:
C NWEAK  = 0 ===> QED,
C        = 1 ===> Electroweak;
C NFAST  = 0 ===> complete matrix element squared,
C        = 1 ===> Z0 t-channel diagrams neglected,
C        = 2 ===> only photon t-channel diagrams included,
C        = 3 ===> no standard model diagrams taken into account;
C ... for the e* diagrams the options are given by:
C IFULL  = 0 ===> no e* diagrams taken into account,
C        = 1 ===> only photon t-channel diagrams included,
C        = 2 ===> photon and Z0 s-channel diagrams also included,
C        = 3 ===> complete matrix element squared;
C ... other generation parameters:
C PLP    : positron longitudinal polarization;
C PLM    : electron longitudinal polarization;
C XLAM   : lambda cut-off in the lagrangian of the e*-e-gamma and
C          e*-e-Z0 interactions (GeV);
C CL,CR  : left and right handed parts of the e*-e-gamma coupling
C          ((G-2) experiments indicate that CL*CR has to be 0);
C XMEST  : e* mass (GeV);
C EDL    : minimum detectable photon (electron) energy (GeV);
C ACD    : minimum detectable photon (electron) angle (degrees);
C ... missing particles:
C ACV    : veto angle (degrees) for the missing final state e- (e+);
C ... integration parameters:
C WAPE   : weight factor for sub-generator "e" (e*);
C WAPQ   : weight factor for sub-generator "Q" (QED);
C
C defaults values
C
      CME   = 92.2
      XMZ   = 92.
      SW2   = 0.2293
      NF    = 3
      NWEAK = 1
      NFAST = 0
      IFULL = 3
      PLP   = 0.
      PLM   = 0.
      XLAM  = 100.
      CL    = -0.5
      CR    = 0.
      XMEST = 40.
      EDL   = 0.5
      ACD   = 15.
      ACV   = 2.5
      WAPE  = 1.
      WAPQ  = 1.
      KWEIT = 1
      WTMAX = 3100.
      JGENE=NLINK('GENE',0)
      IF (JGENE.NE.0) THEN
       CME   = RW(JGENE+1)
       XMZ   = RW(JGENE+2)
       SW2   = RW(JGENE+3)
       NF    = IW(JGENE+4)
       NWEAK = IW(JGENE+5)
       NFAST = IW(JGENE+6)
       IFULL = IW(JGENE+7)
       PLP   = RW(JGENE+8)
       PLM   = RW(JGENE+9)
       XLAM  = RW(JGENE+10)
       CL    = RW(JGENE+11)
       CR    = RW(JGENE+12)
       XMEST = RW(JGENE+13)
       EDL   = RW(JGENE+14)
       ACD   = RW(JGENE+15)
       ACV   = RW(JGENE+16)
       WAPE  = RW(JGENE+17)
       WAPQ  = RW(JGENE+18)
       if (iw(jgene).gt.18) KWEIT = IW(JGENE+19)
       if (iw(jgene).gt.19) WTMAX = RW(JGENE+20)
      ENDIF
      GPAR(1) = CME
      GPAR(2) = XMZ
      GPAR(3) = SW2
      GPAR(4) = NF
      GPAR(5) = NWEAK
      GPAR(6) = NFAST
      GPAR(7) = IFULL
      GPAR(8) = PLP
      GPAR(9) = PLM
      GPAR(10) = XLAM
      GPAR(11) = CL
      GPAR(12) = CR
      GPAR(13) = XMEST
      GPAR(14) = EDL
      GPAR(15) = ACD
      GPAR(16) = ACV
      GPAR(17) = WAPE
      GPAR(18) = WAPQ
C
C  Main vertex smearing
C
      SVRT(1) = 0.035
      SVRT(2) = 0.0012
      SVRT(3) = 1.28
      JSVRT=NLINK('SVRT',0)
      IF (JSVRT.NE.0) THEN
       SVRT(1)=RW(JSVRT+1)
       SVRT(2)=RW(JSVRT+2)
       SVRT(3)=RW(JSVRT+3)
      ENDIF
      GPAR(19) = SVRT(1)
      GPAR(20) = SVRT(2)
      GPAR(21) = SVRT(3)
      GPAR(22) = KWEIT
      GPAR(23) = WTMAX
C
C  Fill the KPAR bank
      NCOL = 23
      NROW = 1
      JKPAR = ALTABL('KPAR',NCOL,NROW,GPAR,'2I,(F)','C')
C
C  Initialize event counters
C
      DO 10 I = 1,11
   10  NEVENT(I) = 0
      DO 11 I = 1,2
   11  NEVPHO(I) = 0
C
C Booking of some standard histogrammes
C
      EBEAM = CME/2.
      IEBEAM = NINT(EBEAM*1000)
      JRLEP = ALRLEP(IEBEAM,'   ',0,0,0)
      CALL PRTABL('RLEP',0)
      CALL HBOOK1(10000,'Total weight distribution$',40,0.,0.,0.)
      CALL HBOOK1(10001,'GEN_E weight distribution$',40,0.,0.,0.)
      CALL HBOOK1(10002,'GEN_Q weight distribution$',40,0.,0.,0.)
      CALL HBOOK1(10011,'Positron - Polar angle (Degrees)$',
     &                                                40,170.,180.,0.)
      CALL HIDOPT(10011,'LOGY')
      CALL HBOOK1(10012,'Positron - Energy (GeV)$',40,0.,EBEAM,0.)
      CALL HIDOPT(10012,'LOGY')
      CALL HBOOK1(10021,'Electron - Polar angle (Degrees)$',
     &                                                  40,0.,180.,0.)
      CALL HBOOK1(10022,'Electron - Energy (GeV)$',40,0.,EBEAM,0.)
      CALL HBOOK1(10031,'Photon - Polar angle (Degrees)$',
     &                                                  40,0.,180.,0.)
      CALL HBOOK1(10032,'Photon - Energy (GeV)$',40,0.,EBEAM,0.)
      CALL HBOOK1(10041,'Angle between electron and photon (Degrees)$',
     &                                                  40,0.,180.,0.)
      CALL HBOOK1(10042,'Electron-Photon invariant mass (GeV)$',
     &                                              40,RSMIN,RSMAX,0.)
      CALL HIDOPT(10042,'LOGY')
      IF ( KWEIT.eq.1) then
      CALL HBOOK1(20011,'Positron - Polar angle (Degrees)$',
     &                                                40,170.,180.,0.)
      CALL HIDOPT(20011,'LOGY')
      CALL HBOOK1(20012,'Positron - Energy (GeV)$',40,0.,EBEAM,0.)
      CALL HIDOPT(20012,'LOGY')
      CALL HBOOK1(20021,'Electron - Polar angle (Degrees)$',
     &                                                  40,0.,180.,0.)
      CALL HBOOK1(20022,'Electron - Energy (GeV)$',40,0.,EBEAM,0.)
      CALL HBOOK1(20031,'Photon - Polar angle (Degrees)$',
     &                                                  40,0.,180.,0.)
      CALL HBOOK1(20032,'Photon - Energy (GeV)$',40,0.,EBEAM,0.)
      CALL HBOOK1(20041,'Angle between electron and photon (Degrees)$',
     &                                                  40,0.,180.,0.)
      CALL HBOOK1(20042,'Electron-Photon invariant mass (GeV)$',
     &                                              40,RSMIN,RSMAX,0.)
      CALL HIDOPT(20042,'LOGY')
      endif
C
C  Generator initialization
C
      LENTRY = 1
      CALL ESTA01(LENTRY)
C
C  Print PART and KLIN banks
C
      CALL PRPART
C
      CALL PRTABL('KPAR',0)
C
      RETURN
      END
C*DK ASKUSE
      SUBROUTINE ASKUSE (IDPR,ISTA,NTRK,NVRT,ECMS,WEIT)
C--------------------------------------------------------------------
C
C                 G. Bonneaud  June 1989
C
C     output    : 6 arguments
C          IDPR   : process identification
C          ISTA   : status flag ( 0 means ok)
C          NTRK   : number of tracks generated and kept
C                  (i.e. # KINE banks  written)
C          NVRT   : number of vertices generated
C                   (i.e. # VERT banks written)
C          ECMS   : center of mass energy for the event (may be
C                   different from nominal cms energy)
C          WEIT   : event weight ( not 1 if a weighting method is used)
C--------------------------------------------------------------------
C*CA BCS
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      PARAMETER (LBCS=50000,LCHAR=4)
      COMMON/BCS/ IW(LBCS)
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C*CC BCS
C*CA COUNTR
      COMMON / COUNTR / NEVENT(11),NEVPHO(2)
C*CC COUNTR
C*CA INPOUT
      COMMON / INPOUT / LWRITE
C*CC INPOUT
C*CA KGCOMM
      COMMON /KGCOMM/ IST,NTR,IDP,ECM,WEI
C*CC KGCOMM
C
      COMMON /MOMENZ/ Q1(5),Q2(5),Q5(5),Q3(5),Q4(5)
      REAL*8 Q1,Q2,Q3,Q4,Q5
C
      DIMENSION SVRT(3),VERT(4),TABL(4)
      INTEGER ALTABL
      DATA IFIRST / 0 /
C
C  Generate vertex position
C
   10 CALL RANNOR(RX,RY)
      CALL RANNOR(RZ,DUM)
      IF(IFIRST.EQ.0) THEN
       IFIRST = 1
       JKPAR = NLINK('KPAR',0)
       CME   = RW(JKPAR+1+LMHLEN)
       SVRT(1)=RW(JKPAR+19+LMHLEN)
       SVRT(2)=RW(JKPAR+20+LMHLEN)
       SVRT(3)=RW(JKPAR+21+LMHLEN)
      ENDIF
      VERT(1)=RX*SVRT(1)
      VERT(2)=RY*SVRT(2)
      VERT(3)=RZ*SVRT(3)
      VERT(4)=0.
C
C  Book 'VERT' bank
C
      IVMAI = 1
      JVERT = KBVERT(IVMAI,VERT,0)
      IF(JVERT.EQ.0) THEN
       ISTA = 1
       NEVENT(2) = NEVENT(2) + 1
       GO TO 70
      ENDIF
C
C   Event generation
C
      LENTRY = 2
      NEVENT(1) = NEVENT(1) + 1
      CALL ESTA01(LENTRY)
C
      IDPR = IDP
      NTRK = NTR
      NVRT = 1
      ISTA = IST
      ECMS = ECM
      WEIT = WEI
C
C  Reject event if non physical (ISTA = 2 and WEIT = 0.) and restart
C  generation right away
C
      IF(ISTA.EQ.2) THEN
       NEVENT(3) = NEVENT(3) + 1
       GO TO 70
      ENDIF
C
C   Book KINE banks for beam electrons
C
      TABL(1) = 0.
      TABL(2) = 0.
      TABL(3) = Q2(3)
      TABL(4) = 0.
      JKINE = KBKINE(-1,TABL,2,0)
      IF(JKINE.EQ.0) THEN
       ISTA = 3
       NEVENT(4) = NEVENT(4) + 1
       GO TO 70
      ENDIF
      TABL(3) = Q1(3)
      JKINE = KBKINE(-2,TABL,3,0)
      IF(JKINE.EQ.0) THEN
       ISTA = 4
       NEVENT(5) = NEVENT(5) + 1
       GO TO 70
      ENDIF
C
C   Book KINE banks for outgoing particles
C
      DO 20 I = 1,3
  20  TABL(I) = Q4(I)
      TABL(4) = 0.
      JKINE = KBKINE(1,TABL,2,IVMAI)
      IF(JKINE.EQ.0) THEN
       ISTA = 5
       NEVENT(6) = NEVENT(6) + 1
       GO TO 70
      ENDIF
      DO 30 I = 1,3
  30  TABL(I) = Q3(I)
      TABL(4) = 0.
      JKINE = KBKINE(2,TABL,3,IVMAI)
      IF(JKINE.EQ.0) THEN
       ISTA = 6
       NEVENT(7) = NEVENT(7) + 1
       GO TO 70
      ENDIF
C
C We did not book the photon if the energy is almost equal to zero
C
      IF(Q5(4).LT.1.E-06) THEN
       NTRK = 2
       GO TO 50
      ENDIF
      DO 40 I = 1,3
  40  TABL(I) = Q5(I)
      TABL(4) = 0.
      JKINE = KBKINE(3,TABL,1,IVMAI)
      IF(JKINE.EQ.0) THEN
       ISTA = 7
       NEVENT(8) = NEVENT(8) + 1
       GO TO 70
      ENDIF
C
C  Fill history with 'KHIS' bank
C
   50 DO 60 I = 1,NTR
   60 TABL(I) = 0.
      JKHIS = ALTABL('KHIS',1,NTR,TABL,'I','E')
      IF(JKHIS.EQ.0) THEN
       ISTA = 8
       NEVENT(9) = NEVENT(9) + 1
      ENDIF
C
   70 IF(ISTA.NE.0) THEN
       NEVENT(10) = NEVENT(10) + 1
       IF(WEIT.EQ.0.) GO TO 10
      ENDIF
      IF(ISTA.EQ.0) THEN
       NEVENT(11) = NEVENT(11) + 1
       IF(NTR.EQ.2) NEVPHO(1) = NEVPHO(1) +1
       IF(NTR.EQ.3) NEVPHO(2) = NEVPHO(2) +1
      ENDIF
C
      RETURN
      END
C*DK USCJOB
      SUBROUTINE USCJOB
C-------------------------------------------------------------------
C
C                 G. Bonneaud June 1989
C
C                       End of job routine
C
C------------------------------------------------------------------
C*CA COUNTR
      COMMON / COUNTR / NEVENT(11),NEVPHO(2)
C*CC COUNTR
C*CA INPOUT
      COMMON / INPOUT / LWRITE
C*CC INPOUT
C
C  Final printout
C
      LENTRY = 3
      CALL ESTA01(LENTRY)
C
      WRITE(LWRITE,101)
  101 FORMAT(//20X,'EVENTS STATISTICS',
     &         /20X,'*****************')
      WRITE(LWRITE,102)NEVENT(1),NEVENT(11),NEVPHO(1),NEVPHO(2),
     &NEVENT(10)
  102  FORMAT(/5X,'# OF GENERATED EVENTS                = ',I10,
     &        /5X,'# OF ACCEPTED  EVENTS                = ',I10,
     &        /5X,'# OF ACCEPTED  EVENTS WITHOUT PHOTON = ',I10,
     &        /5X,'# OF ACCEPTED  EVENTS WITH PHOTON    = ',I10,
     &        /5X,'# OF REJECTED  EVENTS                = ',I10)
      WRITE(LWRITE,103)
  103 FORMAT(//20X,'ERRORS STATISTICS',
     &         /20X,'*****************')
      WRITE(LWRITE,104)NEVENT(2),NEVENT(3),NEVENT(4),NEVENT(5),
     &NEVENT(6),NEVENT(7),NEVENT(8),NEVENT(9)
  104 FORMAT(/10X,'ISTA = 1 BOS ERROR VERT     # OF REJECT = ',I10,
     &        /10X,'ISTA = 2 NON PHYSICAL EVENT # OF REJECT = ',I10,
     &        /10X,'ISTA = 3 BOS ERROR KINE e+  # OF REJECT = ',I10,
     &        /10X,'ISTA = 4 BOS ERROR KINE e-  # OF REJECT = ',I10,
     &        /10X,'ISTA = 5 BOS ERROR KINE f+  # OF REJECT = ',I10,
     &        /10X,'ISTA = 6 BOS ERROR KINE f-  # OF REJECT = ',I10,
     &        /10X,'ISTA = 7 BOS ERROR KINE gam # OF REJECT = ',I10,
     &        /10X,'ISTA = 8 BOS ERROR KHIS     # OF REJECT = ',I10)
      RETURN
      END
C*DK ESTA01
      SUBROUTINE ESTA01(LENTRY)
C ====================================================================
C THIS PROGRAM COMPUTES THE CROSS-SECTION FOR E-E-GAMMA FINAL STATES
C INCLUDING DIAGRAMS WITH E* PROPAGATORS
C
C          M. MARTINEZ AND R. MIQUEL (BARCELONA)
C                      AND
C                   C. MANA (CERN)
C
C THE INPUT PARAMETRES ARE MARKED WITH THE LINE :
C INPUT
C
C THIS PROGRAM IS OPTIMISED TO LOOK FOR E-GAMMA FINAL STATES,
C MISSING THE OTHER ELECTRON
C IT ALLOWS THE ELECTRON AND THE POSITRON TO BE LONGITUDINALLY POLARISED
C ======================================================================
      IMPLICIT REAL*8(A-H,M,O-Z)
C*CA BCS
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      PARAMETER (LBCS=50000,LCHAR=4)
      COMMON/BCS/ IW(LBCS)
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C*CC BCS
C*CA INPOUT
      COMMON / INPOUT / LWRITE
C*CC INPOUT
C*CA KGCOMM
      COMMON /KGCOMM/ IST,NTR,IDP,ECM,WEI
C*CC KGCOMM
      EXTERNAL RNDM
      REAL*4 RNDM,DUMMY,ECM,WEI
      COMMON /MOMENZ/ Q1(5),Q2(5),Q5(5),Q3(5),Q4(5)
      COMMON /DETCUT/XDL,CD,CV,XDE,CE,CTMIN,CTMAX,SSMIN,SSMAX
      COMMON /SAP/SAPE,SAPQ
      COMMON /WAP/WAPE,WAPQ
      COMMON /CONST/PI,DR,SR2,PB
      COMMON /FAST/NWEAK,NFAST,IFULL
      COMMON /PARA  / FCTR,M,M2,GES,MGES,MM(5),CL,CR,RATIO,XLAM
      COMMON /FORHIS/ CT3,E3,CT4,E4,CT5,E5,C35,C45,RSDOT
      COMMON /POLARI/ PLM,PLP
      COMMON /CMS/EB,CME,S,BE,BE2
     .       /NFAM/NF
     .       /HARSOF/DC
      COMMON /BOSON1/MZ,GZ,MW,GW,MH
     .       /BOSON2/MZ2,MW2,MH2
     .       /LEPT1/ME,ME2
     .       /LEPT2/MMU,MTAU,MHEAVY
     .       /HAD/MU,MD,MS,MC,MB,MT
      COMMON /WEAK/SW2,CW2,A2,V2,VU2,VD2
     .       /QED/ALF,ALF2,ALDPI
      DIMENSION X(5)
      DIMENSION NPG(2),WSG(2),WS2G(2),WMAXG(2),
     .          SIGG(2),ERRG(2),EFFG(2)
C
C ==========================================================
C ==  INITIALIZATION
C ==========================================================
C
      DATA X/5*0.D0/
      DATA NP,NPG/0,0,0/
      DATA WS,WS2,WMAX,SIG,ERR,EFF/6*0.D0/
      DATA WSG,WS2G,WMAXG,SIGG,ERRG,EFFG/12*0.D0/
C
C  INITIALIZATION            *********************
C
      IF(LENTRY.EQ.1) THEN
C
       WRITE(LWRITE,998)
998    FORMAT('1    ',60('*')/
     . '          E+ E-  ---->  E+ E- GAMMA (INCLUDING VIRTUAL E_STAR)'/
     . '     ',60('*')////)
C
C.. A) PHYSIC PARAMETERS:
C
C INPUT : CME  = CENTER OF MASS ENERGY (GEV)
C         MZ   = Z0 mass (in GeV);
C         SW2  = Sin(theta-w)**2;
C         NF   = Number of fermion families;
C         NFAST= SEE HEADER OF ROUTINE ELEMAT
C         NWEAK=   ""
C         IFULL=   ""
C         PLP  = POSITRON LONGITUDINAL POLARIZATION
C         PLM  = ELECTRON LONGITUDINAL POLARIZATION
C
       JKPAR  = NLINK('KPAR',0)
       KWEIT  = RW(JKPAR+22+LMHLEN)
       WMAX   = RW(JKPAR+23+LMHLEN)
       CME    = RW(JKPAR+1+LMHLEN)
       MZ     = RW(JKPAR+2+LMHLEN)
       SW2    = RW(JKPAR+3+LMHLEN)
       NF     = RW(JKPAR+4+LMHLEN)
       NWEAK  = RW(JKPAR+5+LMHLEN)
       NFAST  = RW(JKPAR+6+LMHLEN)
       IFULL  = RW(JKPAR+7+LMHLEN)
       PLP    = RW(JKPAR+8+LMHLEN)
       PLM    = RW(JKPAR+9+LMHLEN)
C
C INPUT : XLAM = LAMBDA CUT-OFF IN THE LAGRANGIAN OF THE E*-E-GAMMA AND
C                E*-E-Z0 INTERACTIONS (GEV)
C         CL,CR= LEFT AND RIGHT HANDED PARTS OF THE E*-E-GAMMA COUPLING.
C                (G-2) EXPERIMENTS INDICATE THAT CL*CR HAS TO BE 0
C         M    = E* MASS (GEV)
C
       XLAM   = RW(JKPAR+10+LMHLEN)
       CL     = RW(JKPAR+11+LMHLEN)
       CR     = RW(JKPAR+12+LMHLEN)
       M      = RW(JKPAR+13+LMHLEN)
C
       CALL PARAMS
C.. B) CUTS
C.. DETECTED PARTICLES
C
C INPUT : EDL = MINIMUM DETECTABLE PHOTON (ELECTRON) ENERGY (GEV)
C         ACD = MINIMUM (SYMMETRIC) DETECTABLE PHOTON (ELECTRON)
C               ANGLE (DEGREES)
C
       EDL    = RW(JKPAR+14+LMHLEN)
       XDL    = EDL/EB
       XDE    = XDL
       ACD    = RW(JKPAR+15+LMHLEN)
       CD     = DCOS(ACD*DR)
       CE     = CD
C
C.. MISSING PARTICLES
C
C INPUT : ACV = VETO ANGLE (DEGREES)
C
       ACV    = RW(JKPAR+16+LMHLEN)
       CV     = DCOS(ACV*DR)
       CTMIN  = 1.D0
       CTMAX  = CV
C
C SSMIN (SSMAX) = MINIMUM (MAXIMUM) E-GAMMA INVARIANT MASS
C
       SSMIN  = ME2 + 2.D0*S*(0.5-CD/(CV+CD))
       IF ( SSMIN.GT.M2 ) THEN
          WRITE(LWRITE,996) SQRT(SSMIN)
          CALL EXIT
       ENDIF
       SSMAX  = (CME-ME)**2
       IF ( SSMAX.LT.M2 ) THEN
          WRITE(LWRITE,997) SQRT(SSMAX)
          CALL EXIT
       ENDIF
       RSMIN  = DSQRT(SSMIN)
       RSMAX  = DSQRT(SSMAX)
C
C.. C) INTEGRATION PARAMETERS
C
C INPUT : NP     = TOTAL NUMBER OF INTEGRATION POINTS
C         WAPE   = WEIGHT FACTOR FOR SUB-GENERATOR "E" (E*)
C         WAPQ   = WEIGHT FACTOR FOR SUB-GENERATOR "Q" (QED)
C
       WAPE  = RW(JKPAR+17+LMHLEN)
       WAPQ  = RW(JKPAR+18+LMHLEN)
C
       IF ( KWEIT.EQ.0) then
          WRITE(LWRITE,995) 
       else
          WRITE(LWRITE,994) wmax
       endif
       WRITE(LWRITE,999) CME,CD,XDL,SSMIN,SSMAX,CV
994    FORMAT(' ===> UNWEIGHTED events generated with max weight',G11.2)
995    FORMAT(' ===> WEIGHTED events generated')
996    FORMAT('  Minimum ESTAR mass allowed is ',G11.2)
997    FORMAT('  Maximum ESTAR mass allowed is ',G11.2)
999    FORMAT('  =====>  INPUT PARAMETERS:'//
     . ' ==  A) GENERAL:'/
     . '  CME =',G10.4,'GEV '//
     . ' ==  B) DETECTION CUTS:'/
     . '  DETECTED PARTICLES: ',
     .      ' ABS(CT) < ',G11.6,
     .      '  X > ',G10.4,
     .      ' SS IN (',G10.4,' /',G10.4,')'/
     . '   MISSING PARTICLES: ',
     .      ' ABS(CT) > ',G11.6/)
       JTRIG = NLINK('TRIG',0)
       NPM   = IW(JTRIG+2)
       WRITE(LWRITE,1000) NPM,WAPE,WAPQ
1000   FORMAT(' ==  C) INTEGRATION:'/
     . '  # INTEGRATION POINTS =',I8/
     . '    IMPORTANCE FACTORS :'/
     . '         GENERATOR_E =',G12.5,'  GENERATOR_Q =',G12.5///)
C
C =================================================================
C ==  X-SECTION ESTIMATION
C =================================================================
C
       CALL MCE(X,IOUT)
       CALL MCQ(X,IOUT)
       SAPT = SAPE + SAPQ
       PE = SAPE/SAPT
       PQ = 1.D0 - PE
       WRITE(LWRITE,1001) SAPE,SAPQ,PE,PQ,SAPT
1001   FORMAT(
     .'  =====>  INITIAL ESTIMATIONS:....SAP_E.........SAP_Q...'
     . //23X,'X-SEC. = ',G12.5,'  ',G12.5,' PB'/
     . 14X,'  INITIAL PROB. = ',G12.5,'  ',G12.5//
     .'  =====>  ESTIMATED TOTAL X-SECTION =',G12.5,' PB'///)
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
 1     continue
       IST = 0
C
C  Initialize the track number (radiated photon excluded)
C
       NTR = 3
       IDP = 0
       ECM = CME
C
C GENERATE EVENTS
C
C =================================================================
C ==  INTEGRATION LOOP
C =================================================================
C
C....
       DO 20 I=1,5
        X(I) = RNDM(DUMMY)
20     CONTINUE
C....
       ETA=RNDM(DUMMY)
       IF(ETA.LT.PE)THEN
        CALL MCE(X,IOUT)
        IG = 1
       ELSE
        CALL MCQ(X,IOUT)
        IG = 2
       ENDIF
       IF(IOUT.GT.0.)THEN
        W = 0.D0
        IST = 2
       ELSE
        W = F(IDUMMY)
       ENDIF
       IDP = IG
       WEI = W
       IF(WEI.EQ.0.) RETURN
C....
       NP  = NP + 1
       NPG(IG) = NPG(IG) + 1
       WS = WS + W
       WSG(IG) = WSG(IG) + W
       WS2 = WS2 + W*W
       WS2G(IG) = WS2G(IG) + W*W
       IF(W.GT.WMAX) then
          WMAX = W
          WRITE(LWRITE,1011) wmax
       endif
       IF(W.GT.WMAXG(IG)) WMAXG(IG) = W
       CALL HFILL(10000,WEI,0.,1.)
       CALL HFILL(10000+IG,WEI,0.,1.)
C
C FILLING HISTOGRAMS WITH THE WEIGHTED EVENTS
C
       THEPOS = CT4
       THEPOS = ACOS(THEPOS)*180./3.14159
       CALL HFILL(10011,sngl(THEPOS),0.,WEI)
       ENEPOS = E4
       CALL HFILL(10012,sngl(ENEPOS),0.,WEI)
       THEELE = CT3
       THEELE = ACOS(THEELE)*180./3.14159
       CALL HFILL(10021,sngl(THEELE),0.,WEI)
       ENEELE = E3
       CALL HFILL(10022,sngl(ENEELE),0.,WEI)
       THEPHO = CT5
       THEPHO = ACOS(THEPHO)*180./3.14159
       CALL HFILL(10031,sngl(THEPHO),0.,WEI)
       ENEPHO = E5
       CALL HFILL(10032,sngl(ENEPHO),0.,WEI)
       THEOPN = C35
       THEOPN = ACOS(THEOPN)*180./3.14159
       CALL HFILL(10041,sngl(THEOPN),0.,WEI)
       XMINVA = RSDOT
       CALL HFILL(10042,sngl(XMINVA),0.,WEI)
C
C   now give the possibility to generate unweighted events
       If ( kweit.eq.1) then
            pp = rndm(xdummy)
            if ( pp.gt.w/WMAX) go to 1
            wei = 1.
            CALL HFILL(20011,sngl(THEPOS),0.,WEI)
            CALL HFILL(20012,sngl(ENEPOS),0.,WEI)
            CALL HFILL(20021,sngl(THEELE),0.,WEI)
            CALL HFILL(20022,sngl(ENEELE),0.,WEI)
            CALL HFILL(20031,sngl(THEPHO),0.,WEI)
            CALL HFILL(20032,sngl(ENEPHO),0.,WEI)
            CALL HFILL(20041,sngl(THEOPN),0.,WEI)
            CALL HFILL(20042,sngl(XMINVA),0.,WEI)
       endif
       RETURN
      ENDIF
C
C  END OF GENERATION         *********************
C
      IF(LENTRY.EQ.3) THEN
C
C ==========================================================
C ==  STATISTICS
C ==========================================================
C
       WRITE(LWRITE,1010)
1010   FORMAT('1 ',52('*')/
     . '  ',18('*'),'>    RESULTS   <',18('*')/'  ',52('*')///)
       DO 44 I=1,2
        IF(NPG(I).EQ.0)GO TO 44
        SIGG(I) = WSG(I)/NPG(I)
        ERRG(I) = DSQRT(WS2G(I)-NPG(I)*SIGG(I)**2) / NPG(I)
        IF(WMAXG(I).NE.0.)EFFG(I) = 100.*SIGG(I)/WMAXG(I)
44     CONTINUE
       SIG = WS/NP
       ERR = DSQRT(WS2-NP*SIG**2) / NP
       IF(WMAX.NE.0.)EFF = 100.*SIG/WMAX
C
       WRITE(LWRITE,1002)
1002   FORMAT('  ',18('-'),'>   SUBGEN_E     <',18('-')/)
       WRITE(LWRITE,1012) NPG(1),SIGG(1),ERRG(1),EFFG(1)
       WRITE(LWRITE,1003)
1012   FORMAT('   # POINTS =',I8,
     .         '    AVERAGE =',G12.5,' +/- ',G12.5,/,
     .         ' WEIGHT EFF.=',G10.4,' %',///)
1003   FORMAT('  ',18('-'),'>   SUBGEN_Q     <',18('-')/)
       WRITE(LWRITE,1012) NPG(2),SIGG(2),ERRG(2),EFFG(2)
       WRITE(LWRITE,1004)
1004   FORMAT('  ',55('=')/18('='),'>     TOTAL      <',18('=')/
     .   55('=')/)
1011   FORMAT(' warning... weight max increased to ',G12.5)
       WRITE(LWRITE,1014) NP,SIG,ERR,EFF
1014   FORMAT('   # POINTS =',I8,
     .         '  X-SECTION =',G12.5,' +/- ',G12.5,' PB',/,
     .         ' WEIGHT EFF.=',G10.4,' %',///)
C
      ENDIF
C
      RETURN
      END
