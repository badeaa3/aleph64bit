      SUBROUTINE ARIAIN
C ------------------------------------------------------------------
C - B. Bloch  - APRIL 1991
C! Initialization routine of ARIADNE 3.3  generator
C  upgraded for ARIADNE 4.10 ==> change common and calls 01/99
C  comdecks referenced : LUN7COM , BCS ,ARIACOM ,BASCOM
C ------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      COMMON /ARDAT1/ PARA(40),MSTA(40)
Cold      COMMON /AROPTN/ IAR(10),KAR(10),VAR(10)
Cold      COMMON /TEST/ ISPLIC
      PARAMETER ( ICOZ = 23 , ICOH = 25 , ICOT = 6 )
      DIMENSION KFL(8)
      DATA NIT/0/
C  Set up some default values for masses and initial conditions
C select no fragmentation from producer LUEEVT/DYMUEV
      msta(7) = iw(6)
      msta(8) = iw(6)
      MSTJ(105)=0
C do not select final state photon emission in jetset
      MSTJ(41)=0
C select final state photon emission in ariadne
      msta(20) = 1
C constant alpha_em or running alpha_em
C      msta(12) = 0    msta(12) = 1
C select cutoff photon emission when secondary q-qb are produced
C      msta(20) = 2
C select setting of parameters in ariadne calls
C      msta(3) = 1
C set parameters in jetset according to ALEPH fit
C      PARJ( 41) =  0.40      ! A
C      PARJ( 54) = -0.040     ! eps_c
C      PARJ( 55) = -0.0035    ! eps_b
C      PARJ( 11) = 0.5716     ! V_u,d
C      PARJ( 12) = 0.4648     ! V_s
C      PARJ( 13) = 0.65       ! V_c,b
C      PARJ( 17) = 0.20       ! JP=2+ L=1
C      PARJ( 16) = 0.12       ! JP=1+
C      PARJ( 15) = 0.04       ! JP=0+
C      PARJ( 14) = 0.12       ! JP=1+
C      PARJ( 26) = 0.2884     ! eta' suppress.
C      PARJ( 1 ) = 0.1154     ! qq/q
C      PARJ( 2 ) = 0.2863     ! s/d
C      PARJ( 3 ) = 0.6507     ! su/du
C      PARJ( 19) = 0.52       ! 1st rank baryon suppress.
C      MSTA( 35) = 0          ! color reconnection mode (off)
C      PARA( 1 ) = 0.2297     ! Lambda_QCD
C      PARA( 3 ) = 0.7907     ! ptmin cut
C      PARJ( 21) = 0.3577     ! sigma
C      PARJ( 42) = 0.823      ! B
C     all this can be modified from data cards
      CALL KXARCO(LAPAR)
      CALL ARINIT('JETSET')
      CALL HBOOK1(10018,' # OF GENERATED PHOTONS(ISR+FSR) PER EVENT',
     $    30,0.,30.,0.)
      RETURN
      ENTRY ARIAEV
C----------------------------------------
C    partons must be status codes 2 and 1 for ARIADNE :
C    they come out as status code 3 from lushow ....
      do 10 I= 1,N7LU
         if (K7LU(I,1).eq.3) then
           K7LU(I,1)=2
           ilast = i
         endif
 10   CONTINUE
      K7LU(ilast,1)=1
      CALL AREXEC
      NPH = 0
      NIT = NIT +1
C     ECMS = ECM
C count number of photons emitted
      DO 200 I=1,N7LU
        IF(K7LU(I,2).EQ.22) NPH=NPH+1
200   CONTINUE
      CALL HFILL(10018,FLOAT(NPH),0.,1.)
C do fragmentation
      CALL LUEXEC
      IF (NIT.LE.5) CALL LULIST(1)
      RETURN
      END
      SUBROUTINE ASKUSE (IDPR,ISTA,NTRK,NVRT,ECMS,WEIT)
C--------------------------------------------------------------------
C      B. Bloch -Devaux November 1994 IMPLEMENTATION OF HVFL05
C!   Steering of HVFL various steps
C     structure : subroutine
C
C     input     : none
C
C     output    : 6 arguments
C          IDPR   : process identification if meaningful
C          ISTA   : status flag ( 0 means ok), use it to reject
C                   unwanted events
C          NTRK   : number of tracks generated and kept
C                  (i.e. # KINE banks  written)
C          NVRT   : number of vertices generated
C                   (i.e. # VERT banks written)
C          ECMS   : center of mass energy for the event (may be
C                   different from nominal cms energy)
C          WEIT   : event weight ( not 1 if a weighting method is used)
C     comdecks referenced : LUN7COM ,BCS ,BCODES ,BMACRO ,DCODES ,LCODES
C                           MASTER ,HVFPRNT ,TPOLAR,VERTX
C--------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      COMMON / MASTER / IGENE,IWEIT,IMIX,IVBU,IFL,IEV1,IEV2,ISEM,IDEC,
     $   IPHO,ILAM,IPRJ,IDDC,IBDK,ICDK,ITDK,ECM,WTMAX,SVRT(3),ICOULU(10)
      COMMON / VERTX / IFVRT,XVRT(3),SXVRT(3)
      COMMON/HVFPRNT/IPPRI
      REAL*4 TPOL
      COMMON/TPOLAR/TPOL
C    Tau polarization
      PARAMETER (NBU=521,NBD=511,NBS=531,NBC=541)
      PARAMETER (NLB=5122,NXB= 5132)
      PARAMETER (NXB0=5232,NOB= 5332)
C     NBU    = internal JETSET 7.4 code for Bu meson
C     NBD    = internal JETSET 7.4 code for Bd meson
C     NBS    = internal JETSET 7.4 code for Bs meson
C     NBC    = internal JETSET 7.4 code for Bc meson
C     NLB    = internal JETSET 7.4 code for /\B BARYON
C     NXB    = internal JETSET 7.4 code for XIB BARYON
C     NXB0   = internal JETSET 7.4 code for XIB0 BARYON
C     NOB    = internal JETSET 7.4 code for OMEGAB BARYON
      PARAMETER (NDU=421,NDD=411,NDS=431)
      PARAMETER (NLC=4122,NXC= 4132)
C     NDU    = internal JETSET 7.3 code for Du meson
C     NDD    = internal JETSET 7.3 code for Dd meson
C     NDS    = internal JETSET 7.3 code for Ds meson
C     NLC    = internal JETSET 7.3 code for /\C BARYON
C     NXC    = internal JETSET 7.3 code for XIC BARYON
      PARAMETER (NNUEL=12,NNUMU=14,NNUTO=16,NEL=11,NMU=13,NTO=15)
C     NNUEL  = internal JETSET 7.4 code for neutrino electron
C     NNUMU  = internal JETSET 7.4 code for neutrino mu
C     NNUTO  = internal JETSET 7.4 code for neutrino tau
C     NEL    = internal JETSET 7.4 code for electron
C     NMU    = internal JETSET 7.4 code for muon
C     NTO    = internal JETSET 7.4 code for tau
      INTEGER ALTABL,NAMIND
      EXTERNAL ALTABL,NAMIND
      COMMON/ZDUMP/IDEBU,NEVT
      DIMENSION VERT(4),TABL(3),ITAU(10),PTAU(10)
      DIMENSION ZB(LJNPAR)
      PARAMETER ( LWP=4)
      DATA NIT/0/,WM /0./
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
C  Reset ZB storage  and entries in /LUJETS/
      CALL VZERO(ZB,LJNPAR)
      N7LU = 0
C Reset fragmentation storage in common
      MSTU(90) = 0
      NIT=NIT+1
C  DISABLE B mesons decay
      DO 10 KF = NBD,NBC,10
         KC = LUCOMP(KF)
         IF (KC.GT.0) MDCY(KC,1) = 0
  10  CONTINUE
C  DISABLE D mesons decay
      DO 12 KF = NDD,NDS,10
      DO 12 KL = 1,5,2
         KC = LUCOMP(KF+KL-1)
         IF (KC.GT.0) MDCY(KC,1) = 0
  12  CONTINUE
      KCI = LUCOMP(413)
C  Disable B baryons decay and D baryons decays
      DO 11 KE = 4000,5000,1000
      DO 11 KF = 100,300,100
      DO 11 KL = 10,30,10
      DO 11 KM = 2,4,2
         KC = LUCOMP(KE+KF+KL+KM)
         IF (KC.GT.0) MDCY(KC,1) = 0
  11  CONTINUE
C  Disable Tau decay if external decay package requested
      IF (ITDK . GT. 0) THEN
         KC = LUCOMP(NTO)
         IF (KC.GT.0) MDCY(KC,1) = 0
      ENDIF
      IF (IGENE.EQ.-1) THEN
        CALL SIGENE(IDPR,ISTAT,ECMS)
        WEIT = 1.
      ELSEIF ( IGENE.EQ.1.OR. IGENE.EQ.11) THEN
        ECMS = ECM
        WEIT = 1.
        ISTAT = 0
        CALL LUGENE(IFL,ECM,IDPR)
        IDPR = 1000*IDPR
      ELSE IF (IGENE.EQ.3 .OR. IGENE.EQ.13) THEN
        IF ( NIT.GT.5 ) IDEBU =0
        CALL DYMUEV(IDPR,ISTAT,ECMS,WEIT)
        IDPR = IDPR-10000
      ENDIF
      IF (IGENE.GT.10) CALL ARIAEV
      CALL FILBOK(WEIT)
C
C  generate vertex position
C
      CALL RANNOR(RX,RY)
      CALL RANNOR(RZ,DUM)
      VERT(1)=RX*SVRT(1)
      VERT(2)=RY*SVRT(2)
      VERT(3)=RZ*SVRT(3)
      VERT(4)=0.
      IF ( IFVRT.ge.2) then
         CALL RANNOR(RXX,RYY)
         CALL RANNOR(RZZ,DUM)
         VERT(1)=VERT(1) + RXX*SXVRT(1)
         VERT(2)=VERT(2) + RYY*SXVRT(2)
         VERT(3)=VERT(3) + RZZ*SXVRT(3)
      ENDIF
      IF ( IFVRT.ge.1) then
         VERT(1)=VERT(1) + XVRT(1)
         VERT(2)=VERT(2) + XVRT(2)
         VERT(3)=VERT(3) + XVRT(3)
      ENDIF
C
      IFMI = 0
      IFVB = 0
      IF (IMIX.GT.0) CALL LUNMIX(IFMI)
C    REACTIVATE B meson decays
      DO 20 KF = NBD,NBC,10
         KC = LUCOMP(KF)
         IF (KC.GT.0) MDCY(KC,1) = 1
  20  CONTINUE
C  REACTIVATE B baryons decay
C  except if special decay required
      DO 21 KF = 5100,5300,100
      DO 21 KL = 10,30,10
      DO 21 KM = 2,4,2
         KC = LUCOMP(KF+KL+KM)
         KBAR = KF+KL+KM
         IF ( ILAM.GT.0 .AND.(KBAR.EQ.NLB .OR. KBAR.EQ.NXB .OR. KBAR.EQ.
     $        NXB0 .OR. KBAR.EQ.NOB ) ) GO TO 21
         IF (KC.GT.0) MDCY(KC,1) = 1
  21  CONTINUE
C  Update s/u and T/V fraction for b decays
      IF (IBDK.GT.0) CALL SETBDK
      IF (IDEC.GT.0) CALL LUNDEC(IFDC)
      IF (IVBU.GT.0) CALL LUNVBU(IFVB)
      IDPR = IDPR+10*IFMI+100*IFVB
      EE = FLOAT(IFVB)
      FF = FLOAT(IFMI)
      CALL HFILL(10030,EE,FF,1.)
C    LETS LUND FINISH
      IF (N7LU.GT.0) CALL LUZETA(ZB)
      CALL LUEXEC
C     look for special b baryons decays if requested
      IF(ILAM.GT.0) CALL LULAMB
C     look for semileptonic B decays if requested  ( and internal brem)
      IF(ISEM.GT.0) CALL LUNSEM
C     apply internal Brem to semi-lep B decays if not yet done
      IF(IPHO.GT.0 .AND. ISEM.EQ.0 ) CALL LUNPHO(5)
      IF(IPHO.GT.0) CALL LUNPHO(15)
C  Restore s/u fraction for fragmentation
      IF (IBDK.GT.0) CALL SETFRA
C  update s/u and T/V fraction for c decays
      IF (ICDK.GT.0) CALL SETCDK
C  Reactivate c_meson decays
      DO 22 KF = NDD,NDS,10
      DO 22 KL = 1,5,2
         KC = LUCOMP(KF+KL-1)
         IF (KC.GT.0) MDCY(KC,1) = 1
  22  CONTINUE
C  REACTIVATE c_baryons decay
      DO 23 KF = 4100,4300,100
      DO 23 KL = 10,30,10
      DO 23 KM = 2,4,2
         KC = LUCOMP(KF+KL+KM)
         IF (KC.GT.0) MDCY(KC,1) = 1
  23  CONTINUE
C  Select special chain if needed
      IF (IDDC.GT.0) CALL LUNDDC(IFDD)
      CALL LUEXEC
C  Generate radiative decays for semi lept ( D decays ) or leptonic (Psi
      IF(IPHO.GT.0)  THEN
         CALL LUNPHO(4)
         CALL LUNPHO(14)
         CALL LUNPHO(44)
      ENDIF
      CALL LUEXEC
C  Restore s/u fraction for fragmentation
      IF (ICDK.GT.0) CALL SETFRA
C  Reactivate tau decay  if necessary
      NTAU = 0
      IF (ITDK . GT. 0) THEN
         KC = LUCOMP(NTO)
         IF (KC.GT.0) MDCY(KC,1) = 1
         CALL LUTODK(NTAU,ITAU,PTAU)
         IF(ITDK.GT.1) CALL LUNPHO(55)
         CALL LUEXEC
      ENDIF
      IF ( IPPRI/10 .GT.0) THEN
         CALL LUTABU(11)
         CALL LUTABU(21)
         IF (IGENE.EQ.-1) CALL LUTABU(51)
      ENDIF
C   That's it !......
      CALL KXL7MI(VERT,IST,NVRT,NTRK)
      IF (IST.NE.0) THEN
         WRITE(IW(6),'('' ++++WARNING PROBLEME AT EVENT '',I10,'' IER ''
     $   ,I8)') NIT , IST
         CALL LULIST(1)
      ENDIF
C   Set the ZB value according to KINE numbering, i.e. remove beam part.
C   and transmit z of mother to subsequent heavy baryons and mesons
      IBEA = 0
      IITAU = 0
      DO 27 ITR=1,N7LU
      KS = K7LU(ITR,1)
      KM = K7LU(ITR,3)
C  Give same z to all daughters  of a mother
      IF (KM.GT.IBEA .AND. ZB(KM-IBEA).GT.0. ) ZB(ITR) = ZB(KM-IBEA)
      IF ( KS.EQ.21 .AND. ABS(K7LU(ITR,2)).EQ.11 ) THEN
       IBEA = IBEA +1
      ELSE
       ZB(ITR-IBEA) = ZB (ITR)
       KF = ABS(K7LU(ITR,2))
       IF ( KF.NE.NTO) GO TO 27
       IITAU = IITAU+1
       ITAU(IITAU) = ITR-IBEA
      ENDIF
 27   CONTINUE
C
C   Book & fill the bank KZFR with info on fragmentation
C
      NP = N7LU-IBEA
      JKZFR = ALTABL('KZFR',1,NP,ZB,'2I,(F)','E')
      IF(JKZFR.LE.0) ISTAT = -1
      IF (MSTU(24).GT.0) THEN
        IST   = -8
        CALL LULIST(1)
      ENDIF
C   Book polarisation bank if any needed
      IF ( NTAU.GT.0) THEN
         LE = LMHLEN+NTAU*LWP
         CALL AUBOS('KPOL',0,LE,JKPOL,IGARB)
         CALL BLIST(IW,'E+','KPOL')
         CALL BKFMT('KPOL','2I,(I,3F)')
         IF (JKPOL.GT.0) THEN
           IW(JKPOL+LMHCOL) = LWP
           IW(JKPOL+LMHROW) = NTAU
           DO  31 I=1,NTAU
             KKPOL = KROW(JKPOL,I)
             IW(KKPOL+1) = ITAU(I)
             RW(KKPOL+4) = PTAU(I)
 31        CONTINUE
         ELSE
           IST = -8
         ENDIF
      ENDIF
      IF ( IDDC.GT.0) THEN
         IF ( IFDD .EQ.0) ISTAT = -2
      ENDIF
      IF (IST.EQ.0 .AND. ISTAT.EQ.0) THEN
         ICOULU(10) = ICOULU(10)+1
      ELSEIF (IST.GT.0) THEN
         ICOULU(1) = ICOULU(1) +1
         ICOULU(9) = ICOULU(9) +1
      ELSEIF ( IST.LT.0) THEN
         ICOULU(-IST) = ICOULU(-IST) +1
         ICOULU(9) = ICOULU(9) +1
      ELSEIF ( ISTAT.GT.0) THEN
         ICOULU(6) = ICOULU(6) +1
         ICOULU(9) = ICOULU(9) +1
      ELSEIF ( ISTAT.EQ.-1) THEN
         ICOULU(7) = ICOULU(7) +1
         ICOULU(9) = ICOULU(9) +1
      ELSEIF ( ISTAT.EQ.-2) THEN
         ICOULU(8) = ICOULU(8) +1
         ICOULU(9) = ICOULU(9) +1
      ENDIF
C
      ISTA = IST+ISTAT*1000
      EE = KLU(0,2)
      CALL HFILL(10007,EE,DUM,WEIT)
      RETURN
      END
      SUBROUTINE ASKUSI(IGCOD)
C--------------------------------------------------------------------
C      B.BLOCH-DEVAUX NOVEMBER 94 IMPLEMENTATION OF HVFL05
C
C!   Steering of HVFL initialisation steps
C     structure : subroutine
C
C     input     : none
C
C     output    : generator code as define in the KINGAL library
C     comdecks referenced : LUN7COM ,BCS ,MASTER ,MIXING ,USERCP,HVFPRNT
C                           VERTX
C--------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      COMMON / MASTER / IGENE,IWEIT,IMIX,IVBU,IFL,IEV1,IEV2,ISEM,IDEC,
     $   IPHO,ILAM,IPRJ,IDDC,IBDK,ICDK,ITDK,ECM,WTMAX,SVRT(3),ICOULU(10)
      COMMON / VERTX / IFVRT,XVRT(3),SXVRT(3)
      COMMON/HVFPRNT/IPPRI
      COMPLEX PSQD,PSQS
      COMMON/ MIXING /XD,YD,CHID,RD,XS,YS,CHIS,RS,PSQD,PSQS
      COMMON/ PROBMI /CDCPBA,CDCPB,CSCPBA,CSCPB
      PARAMETER (LNBRCP=4)
      COMMON/USERCP/NPARCP,JCODCP(LNBRCP),RHOCPM
      COMPLEX RHOCPM
      PARAMETER ( NCOHF= 23)
      DIMENSION TABL(NCOHF)
      PARAMETER ( IGCO = 5030)
C
      PARAMETER (LPDEC=48)
      INTEGER NODEC(LPDEC)
      INTEGER ALTABL,ALRLEP
      EXTERNAL ALTABL ,ALRLEP
      CHARACTER*10 NAME(20),SINGN
      CHARACTER*30 DATE
      DATA FVERS/
     $1.07
     $/
      DATA DATE/
     $'January 15, 1999'
     $/
      DATA NAME/'LUND 7.4  ','OBSOLETE  ','DYMU3     ',
     $          7*' ',
     $           'NO WEIGHT ','WEIGHTED  ','JETSET7.4',
     $           'ARIADNE4.1',6*' '/
      DATA SINGN/'SINGLE GEN'/
C
C   RETURN THE GENERATOR CODE
C
      IGCOD=IGCO
C RESET ERROR COUNTERS
      DO 5 K=1,10
 5    ICOULU(K)=0
      JHVF=IW(NAMIND('GHVF'))
      WTMAX = 1.E-10
      IF(JHVF.GT.0)THEN
         IGENE=IW(JHVF+1)
         IWEIT=IW(JHVF+2)
         WTMAX=RW(JHVF+3)
         IPPART=IW(JHVF+4)
       ELSE
C default is JETSET 7.4 without weights
         IGENE=1
         IWEIT=0
         WTMAX=1.02
         IPPART=0
       ENDIF
       IPPRI = IPPART
       IUT = IW(6)
       JTRIG=NLINK('TRIG',0)
       IF ( JTRIG.GT.0) THEN
          IEV1=IW(JTRIG+1)
          IEV2=IW(JTRIG+2)
       ELSE
          IEV1 = 1
          IEV2 = 1000
       ENDIF
C  if you need the standard interaction point
C  you may get the sigmas of the gaussion smearing
C  from a data card if you like it
C  SVRT   SIGMAX  SIGMAY  SIGMAZ
C
        NASVRT=NAMIND('SVRT')
        JSVRT=IW(NASVRT)
        IF (JSVRT.NE.0) THEN
           SVRT(1)=RW(JSVRT+1)
           SVRT(2)=RW(JSVRT+2)
           SVRT(3)=RW(JSVRT+3)
        ELSE
           SVRT(1)=0.0110
           SVRT(2)=0.0005
           SVRT(3)=0.7000
        ENDIF
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
C
C     Necessary to keep info on fragmentation
C
      MSTU(17) = 1
C
C  Set up some default values for masses and initial conditions
C   Higgs, top, Z0 masses ...4th generation masses
      PMAS(LUCOMP(25),1)= 100.
      PMAS(LUCOMP( 6),1)= 174.
      PMAS(LUCOMP(23),1)= 91.2
      PMAS(LUCOMP( 7),1)= 150.
      PMAS(LUCOMP( 8),1)= 200.
C   store beam electrons  and Z0
      MSTJ(115) = 3
C   initial state radiation
      MSTJ(107)   = 1
C   Final   state radiation
      MSTJ( 41)   = 2
C  use non discrete masses for resonnances
      MSTJ( 24) =  2
C   SLAC fragm. functions for b,c  Symetric LUND for u,d,s
      MSTJ( 11)   = 3
C   mod to lund fragm. functions params
      PARJ ( 21)  =0.358
      PARJ  (41)  =0.500
      PARJ  (42)  =0.840
      PARJ  (81)  =0.310
      PARJ  (82)  =1.500
C  mod Peterson's fragm. functions params
      PARJ  (54)  = -0.200
      PARJ  (55)  = -0.006
      PARU (102)  =  0.232
      PARJ (123)  =  91.17
      PARU (124)  =  2.5
C    book some general histos
       CALL INIBOK
C    Init generator
       IF     (IGENE.EQ.1 .OR. IGENE.EQ.11) THEN
          CALL INILUN(IFLV,ECMS)
       ELSEIF (IGENE.EQ.2 .OR. IGENE.EQ.12) THEN
          CALL EXIT
       ELSEIF (IGENE.EQ.-1) THEN
          CALL INISIN(IFLV,ECMS)
       ELSEIF (IGENE.EQ.3 .OR. IGENE.EQ.13) THEN
          CALL INIDY3(IFLV,ECMS)
       ENDIF
       ECM =ECMS
       IFL =IFLV
       IF ( ECM .LT.0.) CALL LUKFDI(KFL1,KFL2,KFL3,KF)
C
C   Issue the relevant parameters
C
      WRITE (IUT,999) IGCOD
      WRITE(IUT,1000) FVERS,DATE
      IF (IGENE.GT.0) THEN
        IF ( IGENE.LT.10 ) THEN
           WRITE (IUT,1001) IGENE,NAME(IGENE)
           WRITE (IUT,1003) NAME(13)
        ELSE IF (IGENE.GT.10) THEN
           WRITE (IUT,1001) IGENE-10,NAME(IGENE-10)
           WRITE (IUT,1003) NAME(14)
        ENDIF
      ELSE
        WRITE (IUT,1001) IGENE,SINGN
      ENDIF
      WRITE (IUT,1002) IWEIT,NAME(IWEIT+11),WTMAX
      IF (IGENE.GT.10) CALL INIARI(IFLV,ECMS)
C EXTEND PART BANK
      CALL KXL74A(IPART,IKLIN)
      IF (IPART.LE.0 .OR. IKLIN.LE.0) THEN
         WRITE (IW(6), '(1X,''error in PART or KLIN bank -RETURN- ''
     +                  ,2I3)') IPART,IKLIN
         GOTO 20
      ENDIF
      CALL INIVBU(IFVBU)
      CALL INIMIX(IFMIX)
      CALL INISEM(IFSEM)
      CALL INIDEC(IFDEC)
      CALL INIDDC(IFDDC)
      CALL INILAM(IFLAM)
      CALL INIPRJ(IFPRJ)
      CALL INIBCDK(IFBDK,IFCDK)
      WRITE (IUT,1010)
      CALL INIPHO(IFPHO)
      IFTDK=0
      IF ( MSTJ(28).GT.0) CALL INITODK(IFTDK)
      IBDK = IFBDK
      ICDK = IFCDK
      ITDK = IFTDK
      IMIX = IFMIX
      ISEM=IFSEM
      IPHO=IFPHO
      IVBU = IFVBU
      ILAM = IFLAM
      IPRJ = IFPRJ
      IDEC = IFDEC
      IDDC = IFDDC
C
C   Inhibit decays
C
      MXDEC=KNODEC(NODEC,LPDEC)
      MXDEC=MIN(MXDEC,LPDEC)
      IF (MXDEC.GT.0) THEN
         DO 10 I=1,MXDEC
            IF (NODEC(I).GT.0) THEN
               JIDB = NLINK('MDC1',NODEC(I))
               IF (JIDB .EQ. 0) MDCY(LUCOMP(NODEC(I)),1) = 0
            ENDIF
   10    CONTINUE
      ENDIF
C
C  Print PART and KLIN banks
C
      IF ( MOD(IPPART,10).GT.0) THEN
         CALL LULIST(12)
         CALL PRPART
      ELSE
         CALL LULIST(13)
         CALL LUTABU(10)
         CALL LUTABU(20)
         IF (IGENE.EQ.-1) CALL LUTABU(50)
      ENDIF
C   BUILD KHVF BANK
      TABL(1) = IGENE
      TABL(2) = IFL
      TABL(3) = IWEIT
      TABL(4) = IMIX
      TABL(5) = IVBU
      TABL(6) = ECMS
      TABL(7) = SVRT(1)
      TABL(8) = SVRT(2)
      TABL(9) = SVRT(3)
      TABL(10) = ISEM
      TABL(11) = FVERS*100.
      TABL(12) = IPHO
      TABL(13) = ILAM
      TABL(14) = IPRJ
      TABL(15) = IBDK
      TABL(16) = ICDK
      TABL(17) = ITDK
      TABL(18) = XVRT(1)
      TABL(19) = XVRT(2)
      TABL(20) = XVRT(3)
      TABL(21) = sXVRT(1)
      TABL(22) = sXVRT(2)
      TABL(23) = sXVRT(3)
      NWB = NCOHF
      IND = ALTABL('KHVF',NWB,1,TABL,'2I,(F)','C')
      CALL PRTABL('KHVF',0)
      IF (IGENE.EQ.3 .OR. IGENE.EQ.13) CALL PRTABL('KDYM',0)
      CALL PRTABL('KMIX',0)
      CALL PRTABL('KVBU',0)
      CALL PRTABL('KPRJ',0)
      CALL PRTABL('KSEM',0)
      CALL PRTABL('KDSS',0)
      CALL PRTABL('KLAM',0)
      IF(IDEC.GT.0) CALL PRTABL('KDEC',0)
      IF(IDDC.GT.0) CALL PRTABL('KDDC',0)
C  Fill RLEP bank
      IEBEAM = NINT(ECMS* 500  )
      JRLEP = ALRLEP(IEBEAM,'    ',0,0,0)
      CALL PRTABL('RLEP',0)
   20 RETURN
 999  FORMAT (30X,78('*'),/,40X,'WELCOME TO THE HEAVY FLAVOR MC HVFL05'
     $    ,/,50X,'GENERATOR CODE IS :',I10)
 1000 FORMAT (30X,'*  VERSION ',F6.2,'-LAST MODIFIED ON   ',A30)
 1001 FORMAT (30X,'*  You choose Generator #',I5,1X,A10)
 1003 FORMAT (30X,'*  You Choose as Final State Radiation:   ',A10)
 1002 FORMAT (30X,'*  Weight Flag is',I5,1X,A10,' Max Weight =',F10.5,/,
     $30X,'*    IRRELEVANT FOR LUND',/)
 1010  FORMAT (30X,78('*'))
      END
      REAL FUNCTION CPDECL(P,AM,T0,IOSCI)
C----------------------------------------------------------------------
C! Generates the decay length DCL in case of B decay into a
C! CP eigenstate final state
C  AUTHORS: A. Falvard -B.Bloch-Devaux        881024
C
C     INPUT :    P = momentum in gev
C               AM = mass in gev/c**2
C               T0 = Proper life time
C            IOSCI = status versus oscillaton
C     OUTPUT:
C            CPDECL = decay length
C     Comdecks referenced: ALCONS ,MIXING ,USERCP
C----------------------------------------------------------------------
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
      PARAMETER (LNBRCP=4)
      COMMON/USERCP/NPARCP,JCODCP(LNBRCP),RHOCPM
      COMPLEX RHOCPM
      COMPLEX PSQD,PSQS
      COMMON/ MIXING /XD,YD,CHID,RD,XS,YS,CHIS,RS,PSQD,PSQS
      COMMON/ PROBMI /CDCPBA,CDCPB,CSCPBA,CSCPB
      PARAMETER (CLITS = CLGHT * 1.E+09)
      COMPLEX R
      EXTERNAL RNDM
 1     Z=RNDM(DUM)
      IF(Z.EQ.0.)Z=1.
      AL=ALOG(Z)
      DCL=-T0*AL
      X=XD
      Y=YD
      R=RHOCPM/PSQD
      IF(IOSCI.EQ.3.OR.IOSCI.EQ.4)THEN
      X=XS
      Y=YS
      R=RHOCPM/PSQS
      ENDIF
      AS=AIMAG(R)
      ICP = 1 -2*MOD(IOSCI,2)
      FCON=1.+ICP*AS*SIN(-X*AL)
      F1MAX=2.
      IF(F1MAX*RNDM(DUM).GT.FCON)GOTO 1
      CPDECL=P*DCL/AM*CLITS
      RETURN
      END
      SUBROUTINE DECSTA
C-------------------------------------------------------------
C! Termination routine for selected B mesons decays
C! and requested decay chains
C  B. Bloch -Devaux March 94
C     comdecks referenced : LUN7COM , BCS ,BCODES ,CHAINS ,MASTER
C--------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      COMMON / MASTER / IGENE,IWEIT,IMIX,IVBU,IFL,IEV1,IEV2,ISEM,IDEC,
     $   IPHO,ILAM,IPRJ,IDDC,IBDK,ICDK,ITDK,ECM,WTMAX,SVRT(3),ICOULU(10)
      COMMON /CHAINS/ KFDAU,KFMOTH,KFCOMP(2)
C   KFDAU  = internal JETSET 7.4 code for daughter decayed particle
C   KFMOTH = internal JETSET 7.4 code for mother of decayed particle
C   KFCOMP(2)internal JETSET 7.4 code for companions of decayed particle
      PARAMETER (NBU=521,NBD=511,NBS=531,NBC=541)
      PARAMETER (NLB=5122,NXB= 5132)
      PARAMETER (NXB0=5232,NOB= 5332)
C     NBU    = internal JETSET 7.4 code for Bu meson
C     NBD    = internal JETSET 7.4 code for Bd meson
C     NBS    = internal JETSET 7.4 code for Bs meson
C     NBC    = internal JETSET 7.4 code for Bc meson
C     NLB    = internal JETSET 7.4 code for /\B BARYON
C     NXB    = internal JETSET 7.4 code for XIB BARYON
C     NXB0   = internal JETSET 7.4 code for XIB0 BARYON
C     NOB    = internal JETSET 7.4 code for OMEGAB BARYON
      IUT=IW(6)
      IF ( IDEC.LE.0) GO TO 500
      WRITE(IUT,101)
      KC = LUCOMP(LBPOS)
      IF ( KC.LE.0 ) GO TO 500
      NDEC=MDCY(KC,3)
      IDC=MDCY(KC,2)
      NOPE=0
      BRSU=0.
      DO 120 IDL=IDC,IDC+NDEC-1
      IF(MDME(IDL,1).NE.1) GOTO 120
      IF(MDME(IDL,2).GT.100) GOTO 120
      NOPE=NOPE+1
      BRSU=BRSU+BRAT(IDL)
  120 CONTINUE
      NOP1=NOPE
      BRS1=BRSU
      NOP2=NOPE
      BRS2=BRSU
      IF ( IDEC.EQ.1 .OR. IDEC.EQ.3) THEN
         NOP1=0
         BRS1=0.
         JDEC=IW(NAMIND('GDC1'))
         IF(JDEC.GT.0)THEN
           DO 121 IDL=1,NDEC
             IF(IW(JDEC+IDL).NE.1) GOTO 121
             NOP1=NOP1+1
             BRS1=BRS1+BRAT(IDC+IDL-1)
  121      CONTINUE
         ENDIF
      ENDIF
      IF ( IDEC.GE.2) THEN
         NOP2=0
         BRS2=0.
         JDEC=IW(NAMIND('GDC2'))
         IF(JDEC.GT.0)THEN
           DO 122 IDL=1,NDEC
             IF(IW(JDEC+IDL).NE.1) GOTO 122
             NOP2=NOP2+1
             BRS2=BRS2+BRAT(IDC+IDL-1)
  122      CONTINUE
         ENDIF
      ENDIF
      WRITE(IUT,102) NOPE,BRSU,NOP1,BRS1,NOP2,BRS2
      WRITE(IUT,105) BRS1/BRSU,BRS2/BRSU
  500 CONTINUE
      IF ( IDDC.LE.0) GO TO 600
      WRITE(IUT,103)  KFDAU,KFMOTH,KFCOMP
      KC = LUCOMP(KFDAU)
      NDEC=MDCY(KC,3)
      IDC=MDCY(KC,2)
      NOPE=0
      BRSU=0.
      DO 130 IDL=IDC,IDC+NDEC-1
         IF(MDME(IDL,1).NE.1) GOTO 130
         IF(MDME(IDL,2).GT.100) GOTO 130
         NOPE=NOPE+1
         BRSU=BRSU+BRAT(IDL)
  130 CONTINUE
      NOP1=NOPE
      BRS1=BRSU
      IF ( IDDC.EQ.1 ) THEN
         NOP1=0
         BRS1=0.
         JDEC=IW(NAMIND('GDDC'))
         IF(JDEC.GT.0)THEN
           DO 131 IDL=1,NDEC
             IF(IW(JDEC+IDL+3).NE.1) GOTO 131
             NOP1=NOP1+1
             BRS1=BRS1+BRAT(IDC+IDL-1)
  131      CONTINUE
         ENDIF
      ENDIF
      WRITE(IUT,104) NOPE,BRSU,NOP1,BRS1
      WRITE(IUT,105) BRS1/BRSU
  600 CONTINUE
  101 FORMAT(//20X,'B decay  STATISTICS',/,20X,'*******************')
  102 FORMAT(//20X,'B decay  total decay modes :          ',I10,F12.5,
     $      //,20X,'First  B decay selected decay modes : ',I10,F12.5,
     $      //,20X,'Second B decay selected decay modes : ',I10,F12.5)
  103 FORMAT(//20X,'Special decay  chain STATISTICS',/,20X,
     $             '*******************************',/,20X,
     $ ' for particle code ',I5,' coming from mother code ',I5,
     $ ' and with at least one of the companions ',2I5)
  104 FORMAT(//20X,'Special decay  chain total modes :    ',I10,F12.5,
     $      //,20X,'First    decay selected decay modes : ',I10,F12.5)
  105 FORMAT(//20X,'Cross-section must be multiplied by : ',2F12.5)
      RETURN
      END
      REAL FUNCTION DSMALL (AJ,AM,AN,BETA)
C--------------------------------------------------------------------
C      B.Bloch-Devaux  November 1989  IMPLEMENTATION OF DDJMNB
C! LUNSEM  implementation of DDJMNB
C
C     structure : function
C
C     input     : same arguments as DDJMNB but REAL*4
C
C     output    : return value of DDJMNB but REAL*4
C--------------------------------------------------------------------
      REAL*8 DDJMNB,DAM,DAN,DAJ,DBETA
      EXTERNAL DDJMNB
      DAM = DBLE(AM)
      DAN = DBLE(AN)
      DAJ = DBLE(AJ)
      DBETA= DBLE(BETA)
      DSMALL = SNGL(DDJMNB(DAJ,DAM,DAN,DBETA))
      RETURN
      END
      SUBROUTINE DYMUIN(NTYP)
C-----------------------------------------------------------------------
C    B.Bloch -Devaux APRIL 1991
C         ORIGINAL VERSION OF DYMU3 AS PROVIDED BY J.E.Campagne
C                       June 1989
C  This is a subset of original subroutine INIRUN to compute secondary
C  quantities according to requested final state.
C     comdecks referenced :  BCS , DYMUCOM
C-----------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
      COMMON /CONST/ ALFA,PI,ALFA1
      COMMON /RUNPAR/ SOLD,ID2,ID3,FINEXP,POIDS,INTERF,XK0
      COMMON /WEAK/ AEL,AMU,AMZ,GAMM,SW2,CA2,CV2,CA2CV2,COL,T3,QI
      COMMON /BEAM/ S0,EBEAM
      COMMON /TAU / TAUV,CPTAU,HEL,PITAU(4)
      COMMON/WEAKQ/WEAKC(11,6),XSECT(6),XTOT,ersec(6),nevsec(6)
      COMMON/ZDUMP / IDEBU , NEVT
      COMMON/RESULT/ SIGBOR,SIGTOT,ERRSIG,ASYTOT,ERRASY
C   DYMU3 internal commons
      COMMON / VECLAB / PFP(4),PFM(4),GAP(4),GAM(4),GAF(4)
      COMMON /COUNTS/ SIG,SIG2,SECFWD,SECBKW,SCFWD2,SCBKW2
      COMMON /EVTS/ NEVT1,NEVT2,NFWD,NBKW
      REAL*8 SIG,SIG2,SECFWD,SECBKW,SCFWD2,SCBKW2
C
      DIMENSION PBEA(4)
      DIMENSION ISEED(3)
      LOGICAL FIRST
      DATA FIRST/.TRUE./
      IOUT = IW(6)
      IF(FIRST)THEN
        FIRST = .FALSE.
        WRITE(IOUT,*)'*****************************************'
        WRITE(IOUT,*)'*         WELCOME    TO    DYMU3        *'
        WRITE(IOUT,*)'*                                       *'
        WRITE(IOUT,*)'*         AUTHORS: J.E.CAMPAGNE         *'
        WRITE(IOUT,*)'*                  R.ZITOUN             *'
        WRITE(IOUT,*)'*                                       *'
        WRITE(IOUT,*)'*         19 nov  89 RELEASE            *'
        WRITE(IOUT,*)'*                                       *'
        WRITE(IOUT,*)'*****************************************'
        WRITE(IOUT,*)' '
*----
       CALL HBOOK1(10047,'WEIGHT DISTRIBUTION  ',50,0.,2.,0.)
C
      ENDIF
C
      ITYP = NTYP
      NTYPO = NTYP
C
       WRITE(IOUT,1533) ITYP
 1533 FORMAT( 30X,'**************************************************',
     &/,30X,'* D Y M U 3     A D A P T E D   T O   K I N G A L  : '/
     X ,30X,'*   GENERATING FERMION TYPE:',I3,/,
     &30X,'*****************************************************')
*---- BEAM ENERGY
*
*
      ECMS = 2.*EBEAM
      S0 = 4.*EBEAM**2
*
*----  COUPLING CONSTANTS
*
      CV    = (-1.+4.*SW2)/4./SQRT(SW2*(1.-SW2))
      CA    = -1./4./SQRT(SW2*(1.-SW2))
      CVPRI = (-2*T3/QI+4.*SW2)/4./SQRT(SW2*(1.-SW2))
      CAPRI = -T3/QI/2./SQRT(SW2*(1.-SW2))
      CV2 = CVPRI*CV
      CA2 = CAPRI*CA
      CA2CV2 = ( CV**2+CA**2 )*( CVPRI**2+CAPRI**2 )
      CALL DYMUSI
*
*---- CONST1
*
      ALFA  = 1./137.036
      PI    = 3.14159265
      ALFA1 = ALFA/PI
*
*----
*
      WRITE(IOUT,*)'*************************************************'
      WRITE(IOUT,*)'*     RUN PARAMETERS FOR RUN',ITYP
      WRITE(IOUT,*)'******                                 **********'
      WRITE(IOUT,1000) AMZ,GAMM,SW2
      WRITE(IOUT,1003) ECMS,EBEAM
 1000   FORMAT('     Z MASS =',F8.3,' GEV ,      Z WIDTH =',F6.3,
     &         ' GEV ,  SIN2 TETA =',F7.4)
 1003   FORMAT(' CMS ENERGY =',F8.3,' GEV ,  BEAM ENERGY =',F8.3)
*
      IF(POIDS.EQ.1)THEN
        WRITE(IOUT,*)'UNWEIGHTED EVENTS'
      ELSE
        WRITE(IOUT,*)'WEIGHTED EVENTS'
      ENDIF
      WRITE(IOUT,*)'INITIAL STATE EXPONENTIATION'
      IF(FINEXP.EQ.1)THEN
        WRITE(IOUT,*)'FINAL STATE EXPONENTIATION'
      ELSE IF(FINEXP.EQ.0) THEN
        WRITE(IOUT,*)'NO FINAL STATE EXPONENTIATION.'
      ELSE IF(FINEXP.EQ.-1) THEN
        WRITE(IOUT,*)'NO FINAL STATE PHOTON'
      ENDIF
      IF(ID2.EQ.1)THEN
        WRITE(IOUT,*)'DII IN D(X)'
      ELSE
        WRITE(IOUT,*)'DII NOT IN D(X)'
      ENDIF
      IF(ID3.EQ.1)THEN
        WRITE(IOUT,*)'DIII IN D(X)'
      ELSE
        WRITE(IOUT,*)'DIII NOT IN D(X)'
      ENDIF
      IF(INTERF.EQ.0)THEN
        WRITE(IOUT,*)'NO INTERFERENCE'
      ELSE
        WRITE(IOUT,*)'INTERFERENCE WITH K0 =',XK0
      ENDIF
*
      CALL RDMOUT(ISEED)
      WRITE(IOUT,*)'INITIAL SEEDS ARE',ISEED
      WRITE(IOUT,*)'*************************************************'
*
*---- SET TO ZERO
*
      SIG    = 0.
      SIG2   = 0.
      SECFWD = 0.
      SECBKW = 0.
      SCFWD2 = 0.
      SCBKW2 = 0.
      NEVT1  = 0
      NEVT2  = 0
      NFWD   = 0
      NBKW   = 0
C
      RETURN
C ----------------------------------------------------------------------
C
      ENTRY DYMUEV(IDPR,ISTAT,ECMM,WEIT)
C
      IF (NTYPO.EQ.10 ) THEN
C   Decide which flavor to generate
        XX = RNDM(DUM)
        DO 30 I=1,6
          IF (XX.LT.XSECT(I)) GO TO 40
  30    CONTINUE
  40    ITYP = I
C   Copy corresponding coupling constants
        CALL UCOPY(WEAKC(1,I),AEL,11)
        CALL DYMUSI
        ITYP= ITYP+NTYPO
      ENDIF
C
      CALL DYMUS (WE)
      IDPR=ITYP*1000
      ECMM=ECMS
      WEIT=WE
      ISTAT=0
C                                LUND INTERFACE
C Fill beam electrons ,Z0,photons
      PBEA(1)=0.
      PBEA(2) = 0.
      PBEA(3) = EBEAM
      PBEA(4) = EBEAM
      CALL KXL7FL(21,-11,0,0,0,PBEA,NLA)
      PBEA(3) = -EBEAM
      CALL KXL7FL(21, 11,0,0,0,PBEA,NLA)
      IF (GAP(4).GT.1.E-06) THEN
         CALL KXL7FL( 1, 22,1,0,0,GAP,NLA)
      ENDIF
      IF (GAM(4).GT.1.E-06) THEN
         CALL KXL7FL( 1, 22,2,0,0,GAM,NLA)
      ENDIF
      DO 35 I=1,4
        PBEA(I)=-(GAP(I)+GAM(I))
   35 CONTINUE
      PBEA(4)= PBEA(4)+2.*EBEAM
      CALL KXL7FL(21, 23,1,0,0,PBEA,NLA)
      IZLU = NLA
      IF (GAF(4).GT.1.E-06) THEN
         CALL KXL7FL( 1, 22,IZLU,0,0,GAF,NLA)
      ENDIF
      CALL KXLUPJ(ITYP-NTYPO)
      CALL QQTOPS(PFP,PFM,ITYP,IZLU)
      EE=FLOAT(ITYP)
      CALL HFILL(10006,EE,DUM,WEIT)
      CALL HFILL(10047,WEIT,DUM,1.)
C
  100 CONTINUE
      RETURN
C
C-----------------------------------------------------------------------
      ENTRY DYMUND
C
      CALL FINISH(NTYPO,NEVT)
C
      RETURN
      END
      SUBROUTINE FILBOK(WEI)
C--------------------------------------------------------------------
C      B. BLOCH-DEVAUX April  1991
C
C!   Fill some standard histos from JETSET 7.4 common
C    WEI is the weight to be used in filling
C     comdecks referenced : LUN7COM
C--------------------------------------------------------------------
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      DO 30 ITR = 1 , N7LU
        IMOTH = K7LU(ITR,3)
        IMTYP = IABS(K7LU(IMOTH,2))
        ILUN = K7LU(ITR,2)
C   Final state radiation photon comes from a quark
        IF (ILUN.EQ.22 .AND. IMTYP.GE.1 .AND. IMTYP.LE.6)
     &       CALL HFILL(10008,P7LU(ITR,4),DUM,WEI)
C  Main vertex particles
        IF (IMOTH.LE.1.AND. (ILUN.EQ.22))THEN
C    There is a photon
           CALL HFILL(10003,P7LU(ITR,4),DUM,WEI)
        ELSEIF (ILUN.GT.0 .AND. ILUN.LE.6.AND.IMTYP.EQ.23) THEN
C   fermion
           CALL HFILL(10001,P7LU(ITR,4),DUM,WEI)
           EE=P7LU(ITR,3)/SQRT(P7LU(ITR,1)**2+P7LU(ITR,2)**2+
     $       P7LU(ITR,3)**2)
           CALL HFILL(10004,EE,DUM,WEI)
        ELSEIF (ILUN.LT.0 .AND. ILUN.GE.-6.AND.IMTYP.EQ.23)  THEN
C   anti-fermion
           CALL HFILL(10002,P7LU(ITR,4),DUM,WEI)
           EE= P7LU(ITR,3)/SQRT(P7LU(ITR,1)**2+P7LU(ITR,2)**2+
     &     P7LU(ITR,3)**2)
           CALL HFILL(10005,EE,DUM,WEI)
        ENDIF
  30  CONTINUE
      RETURN
      END
      SUBROUTINE HEPFIL(IM,JF,JL)
C------------------------------------------------------------------
C...Purpose: to convert JETSET event record contents to or from
C...the standard event record commonblock.
C     comdecks referenced : LUN7COM , HEPEVT
C------------------------------------------------------------------
      PARAMETER (NMXHEP=2000)
      COMMON/HEPEVT/NEVHEP,NHEP,ISTHEP(NMXHEP),IDHEP(NMXHEP),
     &JMOHEP(2,NMXHEP),JDAHEP(2,NMXHEP),PHEP(5,NMXHEP),VHEP(4,NMXHEP)
      SAVE /HEPEVT/
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
C...Conversion from JETSET to standard, the easy part.
        NEVHEP=0
        NHEP=0
        IF(N7LU.GT.NMXHEP) CALL LUERRM(8,
     &  '(LUHEPC:) no more space in /HEPEVT/')
        DO 140 I=IM,JL
        IF((I.GT.IM).AND.(I.LT.JF)) GO TO 140
        NHEP=NHEP+1
        ISTHEP(NHEP)=0
        IF(K7LU(I,1).GE.1.AND.K7LU(I,1).LE.10) ISTHEP(NHEP)=1
        IF(K7LU(I,1).GE.11.AND.K7LU(I,1).LE.20) ISTHEP(NHEP)=2
        IF(K7LU(I,1).GE.21.AND.K7LU(I,1).LE.30) ISTHEP(NHEP)=3
        IF(K7LU(I,1).GE.31.AND.K7LU(I,1).LE.100) ISTHEP(NHEP)=K7LU(I,1)
        IDHEP(NHEP)=K7LU(I,2)
        JMOHEP(1,NHEP)=K7LU(I,3)
        IF ( I.EQ.IM) THEN
           JMOHEP(1,NHEP)=0
           JMOTH = NHEP
        ELSE IF ( I.GE.JF .AND. I.LE.JL) THEN
           JMOHEP(1,NHEP)= JMOTH
           ISTHEP(NHEP)= 1
        ENDIF
        JMOHEP(2,NHEP)=0
        IF(K7LU(I,1).NE.3.AND.K7LU(I,1).NE.13.AND.K7LU(I,1).NE.14
     $  .AND.I.EQ.IM )THEN
          JDAHEP(1,NHEP)=K7LU(I,4)-JF+NHEP+1
          JDAHEP(2,NHEP)=K7LU(I,5)-JF+NHEP+1
        ELSE
          JDAHEP(1,NHEP)=0
          JDAHEP(2,NHEP)=0
        ENDIF
        DO 100 J=1,5
  100   PHEP(J,NHEP)=P7LU(I,J)
        DO 110 J=1,4
  110   VHEP(J,NHEP)=V7LU(I,J)
  140   CONTINUE
      RETURN
      END
      SUBROUTINE HEPLIS(IFLAG)
C------------------------------------------------------------------
C...Purpose: print the standard event record commonblock.
C     comdecks referenced :  BCS , HEPEVT
C------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
      PARAMETER (NMXHEP=2000)
      COMMON/HEPEVT/NEVHEP,NHEP,ISTHEP(NMXHEP),IDHEP(NMXHEP),
     &JMOHEP(2,NMXHEP),JDAHEP(2,NMXHEP),PHEP(5,NMXHEP),VHEP(4,NMXHEP)
      SAVE /HEPEVT/
      WRITE(IW(6),10)
      DO 140 I=1,NHEP
        WRITE(IW(6),100)I,ISTHEP(I),IDHEP(I),(JMOHEP(JB,I),JB=1,2),
     $  (JDAHEP(JB,I),JB=1,2),(PHEP(JB,I),JB=1,5)
  140 CONTINUE
 10   FORMAT (10X,' NHEP ISTHEP IDHEP JMOHEP  JDAHEP  PHEP  ')
 100  FORMAT (7I6,5F10.4)
      RETURN
      END
      FUNCTION HIMAX (IMODEL,J,M1,M2)
C---------------------------------------------------------------------
C     A. FALVARD   -   130189
C
C! Computes maximal value of Q2 distribution for semileptonic decay
C             B OR D ----> EL + NEUT + M2
C     THE EXPRESSIONS AND FORTRAN CODE FOR MODELS 1,2,3,4 WERE
C     GIVEN BY G. SCHULER.
C     comdecks referenced :  SEMLEP
C---------------------------------------------------------------------
      REAL M1,M2
      PARAMETER (NCUT=100)
      PARAMETER (NMODEL=5,NDECAY=11)
      COMMON/SEMLEP/IMOSEM,WTM(NMODEL,NDECAY),IHEL,KHEL,PRM1,PR0,PRP1,
     $          BBDAT(NDECAY),BXDAT(NDECAY)  ,
     $          NO1(NDECAY),NO2(NDECAY),OVER(NMODEL,NDECAY)
     $          , IMODSS,R1,R2,R3
      REAL MFF,MFF2,MFF3,MFF4
      COMMON/MFFX/MFF(NMODEL,NDECAY),MFF2(NMODEL,NDECAY),
     $            MFF3(NMODEL,NDECAY),MFF4(NMODEL,NDECAY)
      REAL MB,MD,MQ,MBOT,MX,MUP,MUM,MS,MSQ,MRSQ,KSQ
      COMMON /SCORA/MB,MD,MQ,MBOT,MX,MUP,MUM,MS,MSQ,MRSQ,KSQ
     *,BM,BMSQ,XMTSQ,BB,BX,XMT,BBX,BR,BRX
      COMMON /SCOROU/AL,CP,Q,QV
      HIMAX=0.
      Q2MAX=(M1-M2)**2
      DO 1 K=1,NCUT
      Q2=Q2MAX*K/NCUT
      T=Q2
      IF(IMODEL.LE.4)THEN
         VM=MFF(IMODEL,J)**2/(MFF(IMODEL,J)**2-Q2)
         VM2=MFF2(IMODEL,J)**2/(MFF2(IMODEL,J)**2-Q2)
         VM3=MFF3(IMODEL,J)**2/(MFF3(IMODEL,J)**2-Q2)
         VM4=MFF4(IMODEL,J)**2/(MFF4(IMODEL,J)**2-Q2)
         OVER1=OVER(IMODEL,J)
      ENDIF
      PI=4.*ATAN(1.)
      QPLUS=(M1+M2)**2-Q2
      QMINS=(M1-M2)**2-Q2
      IF(QMINS.LT.0.)GOTO 1
      PC=SQRT(QPLUS*QMINS)/(2.*M1)
      IF(IMODEL.EQ.5)THEN
        Y=Q2/M1**2
        PX=PC
        TM=(BM-XMT)**2
        T=TM-Y*BMSQ
        FEX=EXP(-MSQ*T/(4.*KSQ*BBX))
      FEX1=FEX*((BB*BX/BBX)**1.5)*SQRT(MX/MBOT)
      GV1=0.5*(1./MQ-MD*BR/(2.*MUM*MX))
      F1=2.*MBOT
      GV=GV1*FEX1
      F=F1*FEX1
      AP=-0.5*FEX1/MX*(1.+MD/MB*((BB**2-BX**2)/(BB**2+BX**2))
     *-MD**2/(4.*MUM*MBOT)*BX**4/BBX**2)
      AMSQ=MSQ/(4.*KSQ*BBX)
      FEX5=FEX*((BB*BX/BBX)**2.5)*SQRT(MX/MBOT)
      QV=0.5*FEX5*MD/(MX*BB)
      AL=-FEX5*MBOT*BB*((1./MUM)+0.5*(MD/(MBOT*KSQ*
     &(BB**2)))*T*((1./MQ)-MD*BR/(2.*MUM*MX)))
      CP=FEX5*(MD*MB/(4.*BB*MBOT))*((1./MUM)-(MD*
     &MQ/(2.*MX*(MUM**2)))*BR)
      R=FEX5*MBOT*BB/(SQRT(2.)*MUP)
      SP=FEX5*MD/(SQRT(2.)*BB*MBOT)*(1.+MB/(2.*MUM)-MB*MD*MQ
     &/(4.*MUP*MUM*MX)*BR)
      V=FEX5*MBOT*BB/(4.*SQRT(2.)*MB*MQ*MX)
      FEX2=FEX1
      UP=FEX5*MD*MQ*MB/(SQRT(6.)*BB*MX*MUM)
        Q=FEX2*(1.+(MB/(2.*MUM))-MB*MQ*MD*BR/(4.*MUP*MUM*MX))
      ENDIF
      XH1=0.
      XH2=0.
      XH3=0.
      IF(MOD(J,2).EQ.0)GOTO 201
C.. +* DECAY
      IF (IMODEL.EQ.1) THEN
C..SEMILEPTONIC B-->D,D* DECAY.
      IF(J.LT.7)THEN
          XH1 = SQRT(T) * VM * OVER1  *
     &    ( M1 + M2 - IHEL * 2.*M1 * PC * VM /(M1+M2)  )
        ELSE
          XH1 = SQRT(T) * VM * OVER1 *
     &    ( M1 + M2 - IHEL * 2.*M1 * PC * VM3 /(M1+M2)  )
        ENDIF
      ELSEIF (IMODEL.EQ.2) THEN
        XH1 = SQRT(T) *( 10.9 - M1*PC*0.521) *0.6269*
C    &  EXP( -0.0296*( Q2MAX - T) )
     &  EXP( -0.0145*( Q2MAX - T) )
      ELSEIF (IMODEL.EQ.3) THEN
        XH1 = SQRT(2.*T)*SQRT( M1**2+M2**2-T )
      ELSEIF (IMODEL.EQ.4) THEN
        XH1 = SQRT(T) * OVER1 *
     &  ( (M1 + M2)*VM2 - IHEL * 2.*M1 * PC * VM /(M1+M2)  )
        ELSEIF (IMODEL.EQ.5) THEN
        IF(J.LT.9)THEN
           XH1 = SQRT(Q2)*(F-IHEL*M1*PC*2.*GV)
        ELSEIF(J.EQ.9)THEN
           XH1 = SQRT(Q2)*(AL-IHEL*M1*PC*2.*QV)
        ELSEIF(J.EQ.11)THEN
           XH1 = SQRT(Q2)*(R-IHEL*M1*PC*2.*V)
        ENDIF
      ENDIF
C.. -* DECAY
      IF (IMODEL.EQ.1) THEN
        IF(J.LT.7) THEN
C..SEMILEPTONIC B-->D,D* DECAY.
          XH2 = SQRT(T) * VM * OVER1 *
     &    ( M1 + M2 + IHEL * 2.*M1 * PC * VM /(M1+M2)  )
        ELSE
          XH2 = SQRT(T) * VM * OVER1 *
     &    ( M1 + M2 + IHEL * 2.*M1 * PC * VM3 /(M1+M2)  )
        ENDIF
      ELSEIF (IMODEL.EQ.2) THEN
        XH2 = SQRT(T) *( 10.9 + M1*PC*0.521) *0.6269*
C    &  EXP( -0.0296*( Q2MAX - T) )
     &  EXP( -0.0145*( Q2MAX - T) )
      ELSEIF (IMODEL.EQ.3) THEN
        XH2 = SQRT(2.*T)*SQRT( M1**2+M2**2-T )
      ELSEIF (IMODEL.EQ.4) THEN
        XH2 = SQRT(T) * OVER1 *
     &  ( (M1 + M2)*VM2 + IHEL * 2.*M1 * PC * VM /(M1+M2)  )
      ELSEIF (IMODEL.EQ.5) THEN
        IF(J.LT.9)THEN
           XH2 = SQRT(Q2)*(F+IHEL*M1*PC*2.*GV)
        ELSEIF(J.EQ.9)THEN
           XH2 = SQRT(Q2)*(AL+IHEL*M1*PC*2.*QV)
        ELSEIF(J.EQ.11)THEN
           XH2 = SQRT(Q2)*(R+IHEL*M1*PC*2.*V)
        ENDIF
      ENDIF
C.. 0* DECAY
      IF (IMODEL.EQ.1) THEN
        IF(J.LT.7) THEN
C..SEMILEPTONIC B-->D,D* DECAY.
          XH3 = VM * OVER1 / M2 *
     &    ( (M1**2 - M2**2 -T) * (M1 + M2) /2. - 2. * M1**2 * PC**2
     &     * VM /(M1+M2))
        ELSE
          XH3 = VM * OVER1 / M2 *
     &    ( (M1**2 - M2**2 -T) * (M1 + M2) /2. - 2. * M1**2 * PC**2
     &     * VM3 /(M1+M2))
        ENDIF
      ELSEIF (IMODEL.EQ.2) THEN
        XH3 = 1./(2.*M2) * ( M1**2 - M2**2 - T) *10.90 *0.6269*
C    &   EXP( -0.0296*( Q2MAX - T) )
     &   EXP( -0.0145*( Q2MAX - T) )
      ELSEIF (IMODEL.EQ.3) THEN
        XH3 = ( M1**2-M2**2-T) * SQRT(M1**2+M2**2-T) / (SQRT(2.)*M2)
      ELSEIF (IMODEL.EQ.4) THEN
        XH3 = OVER1 / M2 *
     &  ( (M1**2 - M2**2 -T) * (M1 + M2)*VM2 / 2. - 2. * M1**2 * PC**2
     &   * VM4 /(M1+M2))
      ELSEIF (IMODEL.EQ.5) THEN
        IF(J.LT.9)THEN
           XH3 = 1./(2.*M2)*((M1**2-M2**2-Q2)*F
     &    +4.*M1**2*PC**2*AP)
        ELSEIF(J.EQ.9)THEN
           XH3 = 1./(2.*M2)*((M1**2-M2**2-Q2)*AL
     &     +4.*M1**2*PC**2*CP)
        ELSEIF(J.EQ.11)THEN
           XH3 = 1./(2.*M2)*((M1**2-M2**2-Q2)*R
     &     +4.*M1**2*PC**2*SP)
        ENDIF
      ENDIF
      GOTO 200
 201  CONTINUE
C.. 0 DECAY
      IF (IMODEL.EQ.1) THEN
        XH3 = 2. * M1 * PC * VM * OVER1
      ELSEIF (IMODEL.EQ.2) THEN
C       XH3 = 2.*M1*PC*1.8075*0.6269*EXP(-0.0296*(Q2MAX-T))
        XH3 = 2.*M1*PC*1.8075*0.6269*EXP(-0.0145*(Q2MAX-T))
      ELSEIF (IMODEL.EQ.3) THEN
        XH3 = SQRT(2.)*PC*SQRT( M1**2+M2**2-T )
      ELSEIF (IMODEL.EQ.4) THEN
        XH3 = 2. * M1 * PC * VM * OVER1
      ELSEIF (IMODEL.EQ.5) THEN
        IF(J.LT.10)XH3 = 2.*M1*PC*2.*Q
        IF(J.EQ.10)XH3 = 2.*M1*PC*2.*UP
      ENDIF
 200  H1MAX=(XH1**2+XH2**2+XH3**2)*PC
      IF(H1MAX.GT.HIMAX)HIMAX=H1MAX
 1    CONTINUE
      RETURN
      END
      SUBROUTINE INIARI(IFLV,ECMS)
C--------------------------------------------------------------------
C    B.Bloch-Devaux  April 1991 Implementation of ARIADNE inside HVFL05
C!  initialisation routine for ARIADNE generator
C
C     structure : subroutine
C
C     input     : IFLV : flavor code to be generated
C                 ECMS : center of mass energy
C
C     output    : none
C     comdecks referenced : LUN7COM , BCS ,ARIACOM
C--------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      COMMON /ARDAT1/ PARA(40),MSTA(40)
Cold      COMMON /AROPTN/ IAR(10),KAR(10),VAR(10)
Cold      COMMON /TEST/ ISPLIC
C    init gene
      CALL ARIAIN
C  Suppress call to LUEXEC in QQTOPS and LUEEVT
C   Print out ARIADNE parameters values
      CALL ARPRDA
      IFL  = IFLV
      ECM  = ECMS
      RETURN
      END
      SUBROUTINE INIBCDK(IBDC,ICDC)
C ------------------------------------------------------------------
C - B. Bloch  - September  1994
C! Initialization routine to set up s/u and V/T fraction in B decays
C  IBDC = 0  NO special set up required
C  IBDC = 1  special set up activated for b decays
C  entry SETBDK: replace PARJ(2) ,PARJ(17) by required value for b decay
C  entry SETCDK: replace PARJ(2) ,PARJ(17) by required value for c decay
C  entry SETFRA: restore PARJ(2) ,PARJ(17) to fragmentaion value
C     comdecks referenced : LUN7COM , BCS
C ------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      PARAMETER ( LPAR = 20)
      COMMON/PARJDEF/PARJO(LPAR)
      COMMON/PARJBDK/PARJB(LPAR)
      COMMON/PARJCDK/PARJC(LPAR)
C
      IBDC = 0
      ICDC = 0
      IUT = IW(6)
C   Keep the standard values of first 20 parameters
      DO 5 IPAR = 1,LPAR
         PARJO(IPAR) = PARJ(IPAR)
         PARJB(IPAR) = PARJO(IPAR)
         PARJC(IPAR) = PARJO(IPAR)
  5   CONTINUE
C Get required setting for s/u and T/V fraction in b decays :card GBDK
      JPJ2=IW(NAMIND('GBDK'))
      IF(JPJ2.GT.0)THEN
        NCARB = IW(JPJ2)/2
        II = 1
        DO 10 ICAR = 1,NCARB
            IJ = IW(JPJ2+II)
            PARJB(IJ)  = RW(JPJ2+II+1)
            II = II+2
  10    CONTINUE
        IBDC = 1
      ENDIF
C Get required setting for s/u and T/V fraction in b decays :card GCDK
      JPJ2=IW(NAMIND('GCDK'))
      IF(JPJ2.GT.0)THEN
        NCARB = IW(JPJ2)/2
        II = 1
        DO 20 ICAR = 1,NCARB
            IJ = IW(JPJ2+II)
            PARJC(IJ)  = RW(JPJ2+II+1)
            II = II+2
  20    CONTINUE
        ICDC = 1
      ENDIF
C
C   Issue the relevant parameters
C
      IF (IBDC+ICDC.GT.0) THEN
        WRITE (IUT,1000) PARJB,PARJC,PARJO
 1000 FORMAT(30X,'* b and c Decay Diagrams Parameters : ',/
     $30X,'* First 20 values of PARJ  ',/,
     $30X,'* For b-Decays     : ',10F8.4,/,51X,10F8.4,/,
     $30X,'* For c-Decays     : ',10F8.4,/,51X,10F8.4,/,
     $30X,'* For Fragmentation: ',10F8.4,/,51X,10F8.4,/)
      ENDIF
      RETURN
C
      ENTRY SETBDK
C
      CALL UCOPY ( PARJB,PARJ,20)
      RETURN
C
      ENTRY SETCDK
C
      CALL UCOPY ( PARJC,PARJ,20)
      RETURN
C
      ENTRY SETFRA
C
      CALL UCOPY ( PARJO,PARJ,20)
      RETURN
      END
      SUBROUTINE INIBOK
C------------------------------------------------------------------
C! Book some general standard histos
C    B.Bloch-Devaux April 1991
C------------------------------------------------------------------
      CALL HBOOK1(10001,'Outgoing Fermion Energy$',100,0.,50.,0.)
      CALL HBOOK1(10002,'Outgoing Antifermion Energy$',100,0.,50.,0.)
      CALL HBOOK1(10004,'Polar Angle FERMION$',50,-1.,1.,0.)
      CALL HBOOK1(10005,'Polar Angle ANTIFERMION$',50,-1.,1.,0.)
      CALL HBOOK1(10003,'ISR PHOTON Energy IF ANY$',50,0.,25.,0.)
      CALL HBOOK1(10008,'FSR PHOTON Energy IF ANY$',60,0.,30.,0.)
      CALL HBOOK1(10006,'event type produced',60,0.,60.,0.)
      CALL HBOOK1(10007,'Final Multiplicity',50,0.,100.,0.)
      RETURN
      END
      SUBROUTINE INIDDC(IDEC)
C ------------------------------------------------------------------
C - B. Bloch  - March  1994
C! Initialization routine of selected decay modes for a given chain
C  IDEC = 0  NO selected modes required
C  IDEC = 1  selected modes required for first chain
C     comdecks referenced : LUN7COM , BCS ,CHAINS
C ------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      COMMON /CHAINS/ KFDAU,KFMOTH,KFCOMP(2)
C   KFDAU  = internal JETSET 7.4 code for daughter decayed particle
C   KFMOTH = internal JETSET 7.4 code for mother of decayed particle
C   KFCOMP(2)internal JETSET 7.4 code for companions of decayed particle
      DIMENSION ITABL(200)
      INTEGER ALTABL
C
      IDEC = 0
      IUT = IW(6)
C GET selected decay modes for the KF decay  scheme GDDC CARD
      JDEC=IW(NAMIND('GDDC'))
      IF(JDEC.GT.0)THEN
        KFDAU = IW(JDEC+1)
        KFMOTH = IW(JDEC+2)
        KFCOMP(1) = IW(JDEC+3)
        KFCOMP(2) = IW(JDEC+4)
        KC = LUCOMP(KFDAU)
        IF ( KC.GT.0) THEN
C   Check length consistency
           NDEC  = MDCY(KC,3)
           IF(IW(JDEC)-4.NE.NDEC) GO TO 99
           IDEC = IDEC +1
           JDEC1 = JDEC
           CALL UCOPY ( IW(JDEC+1),ITABL(1),NDEC+4)
        ELSE
           GO TO 98
        ENDIF
      ELSE
         CALL UFILL (ITABL,1,NDEC+4,1)
      ENDIF
C
C   Issue the relevant parameters
C
      IF (IDEC.GT.0) THEN
        CALL HBOOK1(10040,'NUMBER OF DECAY CHAIN PER EVENT ',5,0.,5.,0.)
        WRITE (IUT,1000) KFDAU,KFMOTH,KFCOMP
        IF (IDEC.GT.0) WRITE(IUT,1005) (IW(JDEC1+K),K=5,NDEC+4)
 1000 FORMAT(30X,'* SELECTED decay chain option :',/,30X,
     $'*Particle code from decay of mother with companions ',/,30X,4I10)
 1005 FORMAT(30X,'* First chain selected decays : ',/,32X,50I2)
C   dump the selected decay modes for this run in a bank  KDDC
C  all parameters are integer and stored as 1 row
        IND = ALTABL('KDDC',NDEC+4,1,ITABL,'2I,(I)','C')
C
      ENDIF
      RETURN
 99   WRITE(IUT,'('' ===INIDDC  : INCONSISTENT DECAY MODES NUMBERS :'',
     $ 2I10)') IW(JDEC),NDEC
      RETURN
 98   WRITE(IUT,'('' ===INIDDC  : UNKNOWN PARTICLE CODE :'',I10)') KFDAU
      END
      SUBROUTINE INIDEC(IDEC)
C ------------------------------------------------------------------
C - B. Bloch  - February 1991
C! Initialization routine of selected decay modes for B's
C  IDEC = 0  NO selected modes required
C  IDEC = 1  selected modes required for first B meson
C  IDEC = 2  selected modes required for second B meson
C  IDEC = 3  selected modes required for both B mesons
C     comdecks referenced : LUN7COM , BCS ,BCODES
C ------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      PARAMETER (NBU=521,NBD=511,NBS=531,NBC=541)
      PARAMETER (NLB=5122,NXB= 5132)
      PARAMETER (NXB0=5232,NOB= 5332)
C     NBU    = internal JETSET 7.4 code for Bu meson
C     NBD    = internal JETSET 7.4 code for Bd meson
C     NBS    = internal JETSET 7.4 code for Bs meson
C     NBC    = internal JETSET 7.4 code for Bc meson
C     NLB    = internal JETSET 7.4 code for /\B BARYON
C     NXB    = internal JETSET 7.4 code for XIB BARYON
C     NXB0   = internal JETSET 7.4 code for XIB0 BARYON
C     NOB    = internal JETSET 7.4 code for OMEGAB BARYON
      DIMENSION ITABL(200)
      INTEGER ALTABL
C
      IDEC = 0
      IUT = IW(6)
C GET selected decay modes for each of the B decays  GDC1,GDC2 CARDS
      KC = LUCOMP(LBPOS)
      IF (KC.GT.0) THEN
         NDEC=MDCY(KC,3)
         JDEC=IW(NAMIND('GDC1'))
         IF(JDEC.GT.0)THEN
C   Check length consistency
            IF(IW(JDEC).NE.NDEC) GO TO 99
            IDEC = IDEC +1
            JDEC1 = JDEC
            CALL UCOPY ( IW(JDEC+1),ITABL(1),NDEC)
         ELSE
            CALL UFILL (ITABL,1,NDEC,1)
         ENDIF
         JDEC=IW(NAMIND('GDC2'))
         IF(JDEC.GT.0)THEN
            IF(IW(JDEC).NE.NDEC) GO TO 99
            IDEC = IDEC +2
            JDEC2 = JDEC
            CALL UCOPY ( IW(JDEC+1),ITABL(NDEC+1),NDEC)
         ELSE
            CALL UFILL (ITABL,NDEC+1,2*NDEC,1)
         ENDIF
      ENDIF
C
C   Issue the relevant parameters
C
      IF (IDEC.GT.0) THEN
        WRITE (IUT,1000)
      IF (IDEC.EQ.1.OR.IDEC.EQ.3) WRITE(IUT,1005) (IW(JDEC1+K),K=1,NDEC)
      IF (IDEC.GE.2) WRITE (IUT,1006) (IW(JDEC2+K),K=1,NDEC)
 1000 FORMAT (30X,'* Selected B Meson decays ',/)
 1005 FORMAT (30X,'* First  B meson selected decays : ',40I2)
 1006 FORMAT (30X,'* Second B meson selected decays : ',40I2)
C
C   dump the selected decay modes for this run in a bank  KDEC
C  all parameters are integer and stored as 2 rows ( one for each B)
      IND = ALTABL('KDEC',NDEC,2,ITABL,'2I,(I)','C')
C
      CALL HBOOK1(10009,' # B MESONS produced per event',5,0.,5.,0.)
      CALL HTABLE(10019,' # BD VS BU  produced per event',5,0.,5.,5,0.,
     $5., 0.)
      CALL HBPRO(10019,0.)
      CALL HBOOK1(10039,' # BS MESONS produced per event',5,0.,5.,0.)
      CALL HBOOK1(10049,' # BC MESONS produced per event',5,0.,5.,0.)
      CALL HTABLE(10059,' # BD FIRST VS #BU FIRST per event',5,0.,5.,
     $ 5,0.,5., 0.)
      ENDIF
      RETURN
 99   WRITE(IUT,'('' ===INIDEC  : INCONSISTENT DECAY MODES NUMBERS :'',
     $ 2I10)') IW(JDEC),NDEC
      END
      SUBROUTINE INIDY3(IFLV,ECMS)
C--------------------------------------------------------------------
C    B.Bloch-Devaux  April 1991 Implementation of DYMU3 inside HVFL05
C!  initialisation routine for DYMU3 generator
C
C     structure : subroutine
C
C     input     : none
C
C     output    : IFLV : flavor code to be generated
C                 ECMS : center of mass energy
C  comdecks referenced : LUN7COM , BCS ,BASCOM ,DYMUCOM
C--------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
      DATA FVERS/
     $1.07
     $/
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      PARAMETER ( ICOZ = 23 , ICOH = 25 , ICOT = 6 )
      COMMON /CONST/ ALFA,PI,ALFA1
      COMMON /RUNPAR/ SOLD,ID2,ID3,FINEXP,POIDS,INTERF,XK0
      COMMON /WEAK/ AEL,AMU,AMZ,GAMM,SW2,CA2,CV2,CA2CV2,COL,T3,QI
      COMMON /BEAM/ S0,EBEAM
      COMMON /TAU / TAUV,CPTAU,HEL,PITAU(4)
      COMMON/WEAKQ/WEAKC(11,6),XSECT(6),XTOT,ersec(6),nevsec(6)
      COMMON/ZDUMP / IDEBU , NEVT
      COMMON/RESULT/ SIGBOR,SIGTOT,ERRSIG,ASYTOT,ERRASY
C   DYMU3 internal commons
      DIMENSION TABL(25),ISEED(3)
      INTEGER ALTABL
      XTOT = 0.
C
C      DYMU3 PARAMETERS     DEFAULT VALUES
C                         BEAM ENERGY
      EBEAM    =46.1
C                         MZ,GAMZ,SIN2 (EFFECTIVE)
      AMZ      =91.2
      GAMM = 2.56
      SW2 = .2293
      SOLD = -1.
      ID2 = 0
      ID3 = 0
      IEXPO = 1
      FINEXP =-1.
      POIDS = 1.
      INTERF = 0
      IDEBU = 0
      NEVT = 0
      TAUV = 0.
C                         K0 MINIMUM HARD PHOTON ENERGY/EBEAM
      XK0 = 0.003
C                         WEAK ISOSPIN AND CHARGE OF OUTGOING FERMION
      QCDFAC = 1.04
      T3  =-0.5
      QI =  -1./3.
      COL = 3.*QCDFAC
      ITYPE = 15
      NQUA = 0
C   DEFAULT SETUP IS BB BAR PAIR PRODUCTION
C
      NAGDYM=NAMIND('GDYM')
      ID=IW(NAGDYM)
      IF (ID.NE.0) THEN
          ITYPE = NINT(RW(ID+1))
          EBEAM     = RW(ID+2)
          AMZ       = RW(ID+3)
          GAMM      = RW(ID+4)
          SW2       = RW(ID+5)
          IDEBU     = IW(ID+6)
          ID2       = RW(ID+7)
          TAUV       = RW(ID+8)
          FINEXP    = RW(ID+9)
          POIDS     = RW(ID+10)
          XK0       = RW(ID+11)
          QCDFAC    = RW(ID+12)
          NQUA      = IW(ID+13)
          IFIRST    = IW(ID+14)
          NEVMA     = IW(ID+15)
      ENDIF
      IF (FINEXP.NE.0.) THEN
        WRITE(IW(6),'(1X,''++++++YOU SHOULD NOT REQUEST FINAL STATE RADI
     &ATION BY DYMU3'',/,'', IT WILL BE GENERATED WITHIN PARTON SHOWER
     &BY JETSET 7.4 OR QCD CASCADE DIPOLE BY ARIADNE 4.10'')')
        FINEXP = -1.
      ENDIF
C
C    SEt up default masses for LUND : Z0
C
      PMAS(LUCOMP(ICOZ),1) = AMZ
      AEL = ULMASS(11)
C         Leptons
          IF (ITYPE.LE.3) THEN
             WRITE(IW(6),'(1X,''++++++YOU REQUESTED TO GENERATE LEPTONS.
     & ..STOP  !! PLEASE USE ANOTHER GENERATOR THAN HVFL05!  ++++++'')')
             CALL EXIT
          ELSEIF ( ITYPE.GT.10) THEN
C    Quarks
              ITY=ITYPE-10
              QI         = LUCHGE(ITY)/3.
              T3         = SIGN(0.5,QI)
              COL        = 3.*QCDFAC
              AMU        = PMAS(LUCOMP(ITY),1)
          ELSEIF ( ITYPE.EQ.10)  THEN
C    Save initial seeds to start the real events
           CALL RDMOUT(ISEED)
           I1 = ISEED(1)
           I2 = ISEED(2)
           I3 = ISEED(3)
C    Quarks mixture
           DO 15  II=1,6
            NEVSEC(II) = 0.
            ERSEC(II)=0.
 15         XSECT(II)=0.
C   No DEBUG needed here!
             IDEBU = 0
             DO 6 II = 1,NQUA
                KTY = IFIRST+II-1
                NEVT = 0
                ITY=KTY-10
                QI     = LUCHGE(ITY)/3.
                T3     = SIGN(0.5,QI)
                COL    = 3.*QCDFAC
                AMU    = PMAS(LUCOMP(ITY),1)
                CALL DYMUIN(KTY)
C    COPY coupling constants for this type in an array
                CALL UCOPY(AEL,WEAKC(1,KTY-10),11)
                DO 66 KEV=1,NEVMA
                   CALL DYMUS(WEI)
  66            CONTINUE
                CALL FINISH(KTY,NEVMA)
C   Store cross-sections for each process
                XSECT(KTY-10) = SIGTOT
                ERSEC(KTY-10) = ERRSIG
                NEVSEC(KTY-10)= NEVMA
  6          CONTINUE
C   Store total cross-section
             XTOT = XSECT(1)
             ERTOT = ERSEC(1)*ERSEC(1)
             DO 75 II = 2,NQUA
             ERTOT = ERTOT+ERSEC(II)*ERSEC(II)
  75         XTOT = XTOT+XSECT(II)
             KAUX = IFIRST-10
             DO 7 II=2,NQUA
  7          XSECT(KAUX+II-1) = XSECT(KAUX+II-1-1)+XSECT(KAUX+II-1)
C     Normalize
             DO 8 II = 1,NQUA
  8          XSECT(KAUX+II-1) = XSECT(KAUX+II-1)/XSECT(KAUX+NQUA-1)
             WRITE(IW(6),100)   XSECT
 100         FORMAT('       INTEGRATED CROSS SECTIONS FOR QUARKS ',
     $              /,9X,6F10.4)
C    book cross-section bank KSEC
             CALL UGTSEC
C    Restore initial seed
             CALL RMARIN(I1,I2,I3)
          ENDIF
C   Restore DEBUG if any
        IDEBU     = IW(ID+6)
      IFLV = ITYPE-10
      ECMS = 2.*EBEAM
C
C       INITIALIZE DYMU3
C
        CALL DYMUIN(ITYPE)
C
C   dump the generator parameters for this run in a bank
C assume all parameters are real and stored as a single row
      TABL(1) = FLOAT(ITYPE)
      TABL(2) = EBEAM
      TABL(3) = AMZ
      TABL(4) = GAMM
      TABL(5) = SW2
      TABL(6) = FLOAT(ID2)
      TABL(7) = FLOAT(IEXPO)
      TABL(8) = FINEXP
      TABL(9) = POIDS
      TABL(10) = XK0
      TABL(11) = QCDFAC
      TABL(12) = FLOAT(NQUA)
      TABL(13) = FLOAT(IFIRST)
      TABL(14) = FLOAT(NEVMA)
      TABL(15) = TAUV
      NWB = 15
      IND = ALTABL('KDYM',NWB,1,TABL,'2I,(F)','C')
C
      RETURN
      END
      SUBROUTINE INILAM(ILAM)
C ------------------------------------------------------------------
C - B. Bloch  - NOVEMBER 1993
C! initialization routine of special decay dynamics for b baryons
C     comdecks referenced :  BCS ,POLAMB
C ------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
      COMMON/POLAMB/ISPINL,IFORML,W0LAMB
C ISPINL : Switch on/off spin effects in semileptonic B_Baryons decays
C IFORML : Switch on/off form factor  in semileptonic B_Baryons decays
C W0LAMB : form factor value if used
      DIMENSION TABL(10)
      INTEGER ALTABL
C
C GET B BARYON DECAY PARAMETERS
          ILAM = 1
          JLAM=IW(NAMIND('GLAM'))
          IF(JLAM.GT.0)THEN
            ISPINL = IW(JLAM+1)
            IFORML = IW(JLAM+2)
            W0LAMB = RW(JLAM+3)
            IF ( ISPINL+IFORML.EQ.0) ILAM = 0
          ELSE
            ISPINL = 0
            IFORML = 1
            W0LAMB = 0.89
          ENDIF
C
C   Issue the relevant parameters
C
      IUT = IW(6)
      WRITE (IUT,1000)
      WRITE (IUT,1001) ISPINL,IFORML,W0LAMB
 1000 FORMAT(30X,'* BBaryons decays parameters :')
 1001 FORMAT (30X,'*  SPIN effects on/off , Form factor on/off , value '
     $ ,/,31X,10X,I10,10X,I10,F10.4)
C
      CALL HBOOK1(10031,'Electron spectrum b baryon decay',50,0.,50.,0.)
      CALL HBOOK1(10032,'Muon     spectrum b baryon decay',50,0.,50.,0.)
      CALL HBOOK1(10033,'Tau      spectrum b baryon decay',50,0.,50.,0.)
C
C   dump the generator parameters for this run in a bank
C        all parameters are real and stored as a single row
      TABL(1) = FLOAT(ISPINL)
      TABL(2) = FLOAT(IFORML)
      TABL(3) = W0LAMB
      NWB = 3
      IND = ALTABL('KLAM',NWB,1,TABL,'2I,(F)','C')
C
      RETURN
      END
      SUBROUTINE INILUN(IFL,ECMS)
C ------------------------------------------------------------------
C - B. Bloch  - November 1990
C! Initialization routine of LUND 7.4 generator
C     comdecks referenced : BCS
C ------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
C -----------------------------------------------------------------
C - get the LUND flavour IFL if given on data card
         NLUND = NAMIND ('GLUN')
         JLUND = IW(NLUND)
         IF (JLUND .NE. 0) THEN
            IFL = IW(JLUND+1)
            ECMS =  RW(JLUND+2)
         ELSE
            IFL = 0
            ECMS = 92.2
         ENDIF
      RETURN
      END
      SUBROUTINE INIMIX(IMIX)
C ------------------------------------------------------------------
C - B. Bloch  - DECEMBER 1988
C! Initialization routine of MIXING and CPV constants
C     comdecks referenced :  BCS  ,MIXING  ,USERCP
C ------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
      COMPLEX PSQD,PSQS
      COMMON/ MIXING /XD,YD,CHID,RD,XS,YS,CHIS,RS,PSQD,PSQS
      COMMON/ PROBMI /CDCPBA,CDCPB,CSCPBA,CSCPB
      PARAMETER (LNBRCP=4)
      COMMON/USERCP/NPARCP,JCODCP(LNBRCP),RHOCPM
      COMPLEX RHOCPM
      DIMENSION TABL(20)
      INTEGER ALTABL
C
C GET MIXING PARAMETERS IF GIVEN IN STEERING DATA CARDS   881024
C LOOK AT A.FALVARD AND B.BLOCH-DEVAUX- ALEPH NOTE # ?
C FOR DEFINITIONS
          IMIX = 0
          JMIX=IW(NAMIND('GMIX'))
          IF(JMIX.GT.0)THEN
            XD=RW(JMIX+1)
            YD=RW(JMIX+2)
            XS=RW(JMIX+3)
            YS=RW(JMIX+4)
            IMIX = 1
          ELSE
            XD=0.
            YD=0.
            XS=0.
            YS=0.
          ENDIF
C GET CP VIOLATION PARAMETERS IN DB=2 TRANSITIONS
          JCPV=IW(NAMIND('GCPV'))
          IF(JCPV.GT.0)THEN
            PMOD=RW(JCPV+1)
            PHAD=RW(JCPV+2)
            PMOS=RW(JCPV+3)
            PHAS=RW(JCPV+4)
            IMIX = 1
          ELSE
            PMOD = 1.
            PMOS = 1.
            PHAD = 0.
            PHAS = 0.
          ENDIF
            PSQD=CMPLX(PMOD*COS(PHAD),PMOD*SIN(PHAD))
            PSQS=CMPLX(PMOS*COS(PHAS),PMOS*SIN(PHAS))
C GET CP VIOLATION IN A SPECIFIC B DECAY WITH A CP EIGENSTATE
          JSTA=IW(NAMIND('GSTA'))
          NPARCP=0
          IF(JSTA.NE.0)THEN
            NPARCP=IW(JSTA+1)
            IF (NPARCP.GT.4) THEN
             WRITE (IW(6),'(1X,''error in GSTA more than 4 part STOP- ''
     +                 ,I3)') NPARCP
             CALL EXIT
            ENDIF
            IF(NPARCP.GT.0)THEN
              DO 1 IS=1,NPARCP
              JCODCP(IS)=IW(JSTA+1+IS)
 1            CONTINUE
              ROMOD=RW(JSTA+1+NPARCP+1)
              ROPHA=RW(JSTA+1+NPARCP+2)
              RHOCPM=CMPLX(ROMOD*COS(ROPHA),ROMOD*SIN(ROPHA))
              IMIX =1
            ENDIF
          ENDIF
C
C  MIXING PARAMETERS WITHOUT CP VIOLATION
C
            RD=(XD**2+YD**2)/(2.+XD**2-YD**2)
            RS=(XS**2+YS**2)/(2.+XS**2-YS**2)
            CHID=RD/(1.+RD)
            CHIS=RS/(1.+RS)
C
C ONE COMPUTES THE MIXING PROBABILITIES OF B AND BBAR
C TAKING INTO ACCOUNT CP VIOLATION.
C
            PSQDM=CABS(PSQD)
            PSQSM=CABS(PSQS)
            QSPDM=1./PSQDM
            QSPSM=1./PSQSM
            CDCPB=(QSPDM**2*(XD**2+YD**2))/(2.+XD**2-YD**2+
     *      QSPDM**2*(XD**2+YD**2))
            CSCPB=(QSPSM**2*(XS**2+YS**2))/(2.+XS**2-YS**2+
     *      QSPSM**2*(XS**2+YS**2))
            CDCPBA=(PSQDM**2*(XD**2+YD**2))/(2.+XD**2-YD**2+
     *      PSQDM**2*(XD**2+YD**2))
            CSCPBA=(PSQSM**2*(XS**2+YS**2))/(2.+XS**2-YS**2+
     *      PSQSM**2*(XS**2+YS**2))
C
C   Issue the relevant parameters
C
      IUT = IW(6)
      WRITE (IUT,1000)
      WRITE (IUT,1001) XD,YD,XS,YS
      WRITE (IUT,1002) PMOD ,PHAD,PMOS ,PHAS
      WRITE (IUT,1003) CDCPB,CDCPBA,CSCPB,CSCPBA
      WRITE (IUT,1004) NPARCP
      IF (NPARCP.GT.0) WRITE (IUT,1005) (JCODCP(K),K=1,NPARCP)
      IF (NPARCP.GT.0) WRITE (IUT,1006) ROMOD,ROPHA
 1000 FORMAT(30X,'* BBbar Mixing parameters :',/,
     $ 30X,'*               BD                      BS')
 1001 FORMAT (30X,'*  XQ  ,YQ',4F11.4)
 1002 FORMAT (30X,'*  CPV p/q , phase',11X,4F12.4)
 1003 FORMAT (30X,'* Resulting prob. Pq , Pqbar ',4F12.4)
 1004 FORMAT (30X,'* Final state requested with ',I10,'  particles ')
 1005 FORMAT (30X,'* LUND codes to be selected : ',4I10)
 1006 FORMAT (30X,'* Module and phase          : ',2F12.4)
C
      CALL HBOOK1(10010,'DECAY PATH (tau unit) Bd->Bd$',50,0.,10.,0.)
      CALL HBOOK1(10011,'DECAY PATH (tau unit) Bd->BdBAR$',50,0.,10.,0.)
      CALL HBOOK1(10012,'DECAY PATH (tau unit) Bs->Bs$',50,0.,10.,0.)
      CALL HBOOK1(10013,'DECAY PATH (tau unit) Bs->BsBAR$',50,0.,10.,0.)
      CALL HBOOK1(10014,'TRUE Decaylength (CM) Bd->Bd$',50,0.,1.5,0.)
      CALL HBOOK1(10015,'TRUE Decaylength (CM) Bd->BdBAR$',50,0.,1.5,0.)
      CALL HBOOK1(10016,'TRUE Decaylength (CM) Bs->Bs$',50,0.,1.5,0.)
      CALL HBOOK1(10017,'TRUE Decaylength (CM) Bs->BsBar$',50,0.,1.5,0.)
C
C   dump the generator parameters for this run in a bank
C assume all parameters are real and stored as a single row
      TABL(1) = XD
      TABL(2) = YD
      TABL(3) = XS
      TABL(4) = YS
      TABL(5) = PMOD
      TABL(6) = PHAD
      TABL(7) = PMOS
      TABL(8) = PHAS
      TABL(9) = CDCPB
      TABL(10)= CDCPBA
      TABL(11)= CSCPB
      TABL(12)= CSCPBA
      TABL(13)= FLOAT(NPARCP)
      IF(NPARCP.GT.0) THEN
       DO 30 II=1,NPARCP
 30    TABL(13+II)= FLOAT(JCODCP(II))
       TABL(13+NPARCP+1)= ROMOD
       TABL(13+NPARCP+2)= ROPHA
       NWB = 15+NPARCP
      ELSE
        NWB = 13
      ENDIF
      IND = ALTABL('KMIX',NWB,1,TABL,'2I,(F)','C')
C
      RETURN
      END
      SUBROUTINE INIPHO(IPHO)
C ------------------------------------------------------------------
C - B. Bloch  - JUNE 1992
C! Initialization routine for internal brem in B and D meson semi-lep
C  IPHO = 0  no internal brem
C       =x1  internal brems on D meson semi lep decay only
C       =x2  internal brems on B meson semi lep decay only
C       =x3  internal brems on both Meson types
C       =1x  internal brems on D baryon semi lep decay only
C       =2x  internal brems on B baryon semi lep decay only
C       =3x  internal brems on both Baryon types
C     comdecks referenced :  BCS
C ------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
      IPHO =0
      JPHO=IW(NAMIND('GPHO'))
      IF(JPHO.GT.0)THEN
         IPHO = IW(JPHO+1)
         IMES = MOD ( IPHO,10)
         IBAR = MOD(IPHO/10,10)
         IPSI = IPHO/100
         IF ( IPHO.GT.0)  CALL PHOINI
         IF ( IPHO.GT.0 .AND. IMES.GT.0 ) THEN
            CALL HBOOK1(10050,'PHOTON Energy from Dmeso SEMI LEP DECAY',
     $      50 ,0.,15.,0.)
            CALL HBOOK1(10052,'PHOTON Energy from Bmeso SEMI LEP DECAY',
     $      50 ,0.,20.,0.)
         ENDIF
         IF ( IPHO.GT.0 .AND. IBAR.GT.0 ) THEN
            CALL HBOOK1(10051,'PHOTON Energy from Dbary SEMI LEP DECAY',
     $      50 ,0.,15.,0.)
            CALL HBOOK1(10053,'PHOTON Energy from Bbary SEMI LEP DECAY',
     $      50 ,0.,20.,0.)
         ENDIF
         IF ( IPHO.GT.0 .AND. IPSI.GT.0 ) THEN
            CALL HBOOK1(10054,'PHOTON Energy from Psi lepto DECAY',
     $      50 ,0.,15.,0.)
            CALL HBOOK1(10055,'PHOTON Energy from Psi_2s lepto DECAY',
     $      50 ,0.,20.,0.)
         ENDIF
         IF ( IPHO.GT.0 ) THEN
            CALL HBOOK1(10056,'PHOTON ENERGY FROM TAU DECAYS',
     $      50 ,0.,15.,0.)
         ENDIF
      ENDIF
      RETURN
      END
      SUBROUTINE INIPRJ(IPRJ)
C ------------------------------------------------------------------
C - B. Bloch  - NOVEMBER 1993
C! initialization routine for flavour dependent PARJ(17) and PARJ(2)
C     comdecks referenced : LUN7COM , BCS ,PARJCO
C ------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      COMMON/PARJCO/P02(5),P13(5),P14(5),P15(5),P16(5),P17(5)
C P02  fraction of s/u for flavor 1...5  from GP02 card
C P13  fraction of V/V+P for flavor 1...5  from GP13 card ( PARJ(11,12))
C P14-16  fraction of Tensor types for flavor 1...5  from GP14-16 card
C P17  fraction of T/T+V for flavor 1...5  from GP17 card
      DIMENSION TABL(50)
      INTEGER ALTABL
C
      IPRJ = 0
C GET FLAVOUR DEPENDANT FRACTION OF V/V+P
          JP13=IW(NAMIND('GP13'))
          IF(JP13.GT.0)THEN
            P13(2) = PARJ(11)
            P13(3) = PARJ(12)
            P13(4) = RW(JP13+1)
            P13(5) = RW(JP13+2)
            P13(1) = P13(2)
            IPRJ = IPRJ + 1
          ELSE
            P13(1) = PARJ(11)
            P13(2) = PARJ(11)
            P13(3) = PARJ(12)
            P13(4) = PARJ(13)
            P13(5) = PARJ(13)
          ENDIF
C GET flavour dependant fraction of S=0,L=1,J=1
          JP14=IW(NAMIND('GP14'))
          IF(JP14.GT.0)THEN
            P14(2) = RW(JP14+1)
            P14(3) = RW(JP14+2)
            P14(4) = RW(JP14+3)
            P14(5) = RW(JP14+4)
            P14(1) = P14(2)
            IPRJ = IPRJ + 1
          ELSE
            P14(1) = PARJ(14)
            P14(2) = PARJ(14)
            P14(3) = PARJ(14)
            P14(4) = PARJ(14)
            P14(5) = PARJ(14)
          ENDIF
C GET flavour dependant fraction of S=1,L=1,J=0
          JP15=IW(NAMIND('GP15'))
          IF(JP15.GT.0)THEN
            P15(2) = RW(JP15+1)
            P15(3) = RW(JP15+2)
            P15(4) = RW(JP15+3)
            P15(5) = RW(JP15+4)
            P15(1) = P15(2)
            IPRJ = IPRJ + 1
          ELSE
            P15(1) = PARJ(15)
            P15(2) = PARJ(15)
            P15(3) = PARJ(15)
            P15(4) = PARJ(15)
            P15(5) = PARJ(15)
          ENDIF
C GET flavour dependant fraction of S=1,L=1,J=1
          JP16=IW(NAMIND('GP16'))
          IF(JP16.GT.0)THEN
            P16(2) = RW(JP16+1)
            P16(3) = RW(JP16+2)
            P16(4) = RW(JP16+3)
            P16(5) = RW(JP16+4)
            P16(1) = P16(2)
            IPRJ = IPRJ + 1
          ELSE
            P16(1) = PARJ(16)
            P16(2) = PARJ(16)
            P16(3) = PARJ(16)
            P16(4) = PARJ(16)
            P16(5) = PARJ(16)
          ENDIF
C GET flavour dependant fraction of tensor mesons among vector mesons
          IPRJ = 0
          JP17=IW(NAMIND('GP17'))
          IF(JP17.GT.0)THEN
            P17(2) = RW(JP17+1)
            P17(3) = RW(JP17+2)
            P17(4) = RW(JP17+3)
            P17(5) = RW(JP17+4)
            P17(1) = P17(2)
            IPRJ = IPRJ + 1
          ELSE
            P17(1) = PARJ(17)
            P17(2) = PARJ(17)
            P17(3) = PARJ(17)
            P17(4) = PARJ(17)
            P17(5) = PARJ(17)
          ENDIF
C
C GET flavour dependant fraction of s/u
          JP02=IW(NAMIND('GP02'))
          IF(JP02.GT.0)THEN
            P02(2) = RW(JP02+1)
            P02(3) = RW(JP02+2)
            P02(4) = RW(JP02+3)
            P02(5) = RW(JP02+4)
            P02(1) = P02(2)
            IPRJ = IPRJ + 1
          ELSE
            P02(1) = PARJ(2)
            P02(2) = PARJ(2)
            P02(3) = PARJ(2)
            P02(4) = PARJ(2)
            P02(5) = PARJ(2)
          ENDIF
C
C   Issue the relevant parameters
C
      IUT = IW(6)
      WRITE (IUT,1000)
      WRITE (IUT,1002) (P02(I),I=2,5)
      WRITE (IUT,1013) (P13(I),I=2,5)
      WRITE (IUT,1014) (P14(I),I=2,5)
      WRITE (IUT,1015) (P15(I),I=2,5)
      WRITE (IUT,1016) (P16(I),I=2,5)
      WRITE (IUT,1017) (P17(I),I=2,5)
 1002 FORMAT (30X,'* s / u  ',4F10.4)
 1013 FORMAT (30X,'* PJ11,13',4F10.4)
 1014 FORMAT (30X,'* PJ14   ',4F10.4)
 1015 FORMAT (30X,'* PJ15   ',4F10.4)
 1016 FORMAT (30X,'* PJ16   ',4F10.4)
 1017 FORMAT (30X,'* PJ17   ',4F10.4)
 1000 FORMAT (30X,'* You will use the following fractions ',/,30X,
     $'*            ud         s         c         b    ')
C
C   dump the generator parameters for this run in a bank
C   all parameters are real and stored as a single row per parameter
      TABL(1) = 2.
      TABL(2) = P02(1)
      TABL(3) = P02(2)
      TABL(4) = P02(3)
      TABL(5) = P02(4)
      TABL(6) = P02(5)
      TABL(7) = 13.
      TABL(8) = P13(1)
      TABL(9) = P13(2)
      TABL(10)= P13(3)
      TABL(11)= P13(4)
      TABL(12)= P13(5)
      TABL(13)= 14.
      TABL(14)= P14(1)
      TABL(15)= P14(2)
      TABL(16)= P14(3)
      TABL(17)= P14(4)
      TABL(18)= P14(5)
      TABL(19)= 15.
      TABL(20)= P15(1)
      TABL(21)= P15(2)
      TABL(22)= P15(3)
      TABL(23)= P15(4)
      TABL(24)= P15(5)
      TABL(25)= 16.
      TABL(26)= P16(1)
      TABL(27)= P16(2)
      TABL(28)= P16(3)
      TABL(29)= P16(4)
      TABL(30)= P16(5)
      TABL(31)= 17.
      TABL(32)= P17(1)
      TABL(33)= P17(2)
      TABL(34)= P17(3)
      TABL(35)= P17(4)
      TABL(36)= P17(5)
      NWB = 6
      NRO = 6
      IND = ALTABL('KPRJ',NWB,NRO,TABL,'2I,(F)','C')
C
      RETURN
      END
      SUBROUTINE INISEM(ISEM)
C----------------------------------------------------------------------
C     A. Falvard , B.Bloch-  October 1990
C     Modified B.Bloch 02/98 to add some control histos
C
C! Initialisation for all B  SemiLeptonic decays
C  Creates KSEM bank with relevant input data
C  ISEM : MODEL used for semileptonic decays
C         0= no model required,>0 model # required
C     comdecks referenced : LUN7COM , BCS ,BCODES ,SEMLEP
C----------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      PARAMETER (NMODEL=5,NDECAY=11)
      COMMON/SEMLEP/IMOSEM,WTM(NMODEL,NDECAY),IHEL,KHEL,PRM1,PR0,PRP1,
     $          BBDAT(NDECAY),BXDAT(NDECAY)  ,
     $          NO1(NDECAY),NO2(NDECAY),OVER(NMODEL,NDECAY)
     $          , IMODSS,R1,R2,R3
      REAL MFF,MFF2,MFF3,MFF4
      COMMON/MFFX/MFF(NMODEL,NDECAY),MFF2(NMODEL,NDECAY),
     $            MFF3(NMODEL,NDECAY),MFF4(NMODEL,NDECAY)
      REAL MB,MD,MQ,MBOT,MX,MUP,MUM,MS,MSQ,MRSQ,KSQ
      COMMON /SCORA/MB,MD,MQ,MBOT,MX,MUP,MUM,MS,MSQ,MRSQ,KSQ
     *,BM,BMSQ,XMTSQ,BB,BX,XMT,BBX,BR,BRX
      COMMON /SCOROU/AL,CP,Q,QV
      DIMENSION TABL(5)
      INTEGER ALTABL
      DIMENSION BDAT(NDECAY),XDAT(NDECAY)
      DIMENSION NNO1(NDECAY),NNO2(NDECAY),OOVER(NMODEL,NDECAY)
      DIMENSION XMFF(NMODEL,NDECAY),XMFF2(NMODEL,NDECAY),
     $         XMFF3(NMODEL,NDECAY),XMFF4(NMODEL,NDECAY)
      PARAMETER (NBU=521,NBD=511,NBS=531,NBC=541)
      PARAMETER (NLB=5122,NXB= 5132)
      PARAMETER (NXB0=5232,NOB= 5332)
C     NBU    = internal JETSET 7.4 code for Bu meson
C     NBD    = internal JETSET 7.4 code for Bd meson
C     NBS    = internal JETSET 7.4 code for Bs meson
C     NBC    = internal JETSET 7.4 code for Bc meson
C     NLB    = internal JETSET 7.4 code for /\B BARYON
C     NXB    = internal JETSET 7.4 code for XIB BARYON
C     NXB0   = internal JETSET 7.4 code for XIB0 BARYON
C     NOB    = internal JETSET 7.4 code for OMEGAB BARYON
      DATA NNO1/6*NBU,2*421,3*NBU/
      DATA NNO2/423,421,213,211,323,321,323,321,3*425/
      DATA BDAT/6*0.41,2*0.39,3*0.41/
      DATA XDAT/2*0.39,2*0.31,4*0.34,3*0.39/
C
C     IMODEL=1  KORNER-SCHULER         IDECAY=1    B--> D*
C            2  GRINSTEIN ET AL.              2    B--> D
C            3  PIETSCHMANN ET AL.            3    B--> RHO
C            4  BAUER, STECH, WIRBEL          4    B--> PI
C            5  ISGUR, SCUORA, GRINSTEIN      5    B--> K*
C                                             6    B--> K
C                                             7    D--> K*
C                                             8    D--> K
C                                             9    B-->D** (PSEU. V 1)
C                                            10    B-->D** (SCALAIRE)
C                                            11    B-->D** (PSEU. V 2)
C
C OVER
      DATA (OOVER(1,I),I=1,NDECAY)/2*0.7,4*0.33,5*0.82/
      DATA (OOVER(2,I),I=1,NDECAY)/2*0.7,4*0.33,5*0.82/
      DATA (OOVER(3,I),I=1,NDECAY)/2*0.7,4*0.33,5*0.82/
      DATA (OOVER(4,I),I=1,NDECAY)/2*0.7,4*0.33,5*0.82/
      DATA (OOVER(5,I),I=1,NDECAY)/11*0./
C MFF
      DATA (XMFF(1,I),I=1,NDECAY)/2*6.34,4*5.33,5*2.11/
      DATA (XMFF(2,I),I=1,NDECAY)/2*6.34,4*5.33,5*2.11/
      DATA (XMFF(3,I),I=1,NDECAY)/2*6.34,4*5.33,5*2.11/
      DATA (XMFF(4,I),I=1,NDECAY)/2*6.34,4*5.33,5*2.11/
      DATA (XMFF(5,I),I=1,NDECAY)/11*0./
C MFF2
      DATA (XMFF2(1,I),I=1,NDECAY)/2*6.8,4*5.8,5*2.6/
      DATA (XMFF2(2,I),I=1,NDECAY)/2*6.8,4*5.8,5*2.6/
      DATA (XMFF2(3,I),I=1,NDECAY)/2*6.8,4*5.8,5*2.6/
      DATA (XMFF2(4,I),I=1,NDECAY)/2*6.8,4*5.8,5*2.6/
      DATA (XMFF2(5,I),I=1,NDECAY)/11*0./
C MFF3
      DATA (XMFF3(1,I),I=1,NDECAY)/2*6.34,4*5.33,5*2.71/
      DATA (XMFF3(2,I),I=1,NDECAY)/2*6.34,4*5.33,5*2.71/
      DATA (XMFF3(3,I),I=1,NDECAY)/2*6.34,4*5.33,5*2.71/
      DATA (XMFF3(4,I),I=1,NDECAY)/2*6.34,4*5.33,5*2.71/
      DATA (XMFF3(5,I),I=1,NDECAY)/11*0./
C MFF4
      DATA (XMFF4(1,I),I=1,NDECAY)/2*6.73,4*5.5,5*2.53/
      DATA (XMFF4(2,I),I=1,NDECAY)/2*6.73,4*5.5,5*2.53/
      DATA (XMFF4(3,I),I=1,NDECAY)/2*6.73,4*5.5,5*2.53/
      DATA (XMFF4(4,I),I=1,NDECAY)/2*6.73,4*5.5,5*2.53/
      DATA (XMFF4(5,I),I=1,NDECAY)/11*0./
C-------------------------------------------------------------
C   Init common variables
C
      DO 10 II = 1,NDECAY
         NO1(II) = NNO1(II)
         NO2(II) = NNO2(II)
         BBDAT(II) = BDAT(II)
         BXDAT(II) = XDAT(II)
         DO 20 IJ = 1,NMODEL
           OVER(IJ,II) = OOVER(IJ,II)
           MFF (IJ,II) = XMFF (IJ,II)
           MFF2(IJ,II) = XMFF2(IJ,II)
           MFF3(IJ,II) = XMFF3(IJ,II)
           MFF4(IJ,II) = XMFF4(IJ,II)
  20     CONTINUE
  10  CONTINUE
C---------------------------------------------------------
      ISEM=0
      KHEL=0
      IHEL=0
      CALL VZERO(WTM,NMODEL*NDECAY)
      JSEM=IW(NAMIND('GSEM'))
      IF(JSEM.NE.0)THEN
         IMOSEM=IW(JSEM+1)
         IF (IMOSEM.LE.0) GO TO 999
         JDSS=IW(NAMIND('GDSS'))
         IMODSS=0
         IF(JDSS.NE.0)THEN
           IMODSS=IW(JDSS+1)
           IF(IMODSS.EQ.4)THEN
             NDADSS=IW(JDSS)
             IF(NDADSS.NE.4)THEN
              WRITE(IW(6),'(''ERROR D** - YOU  HAVE A WRONG # OF '',
     *   ''  PARAMETERS IN GDSS'',I3)') NDADSS
              CALL EXIT
             ENDIF
             R1=RW(JDSS+2)
             R2=RW(JDSS+3)
             R3=RW(JDSS+4)
           ENDIF
         ENDIF
         MSTSO=MSTJ(24)
         MSTJ(24)=0
         IHEL=IW(JSEM+2)
         ISEM=IMOSEM
         CALL HBOOK1(10020,'LEPTON E SPECTRUM IN CMS B-> D',50,0.,5.,0.)
         CALL HBOOK1(10021,'LEPTON E BOOSTED IN LAB B-> D',50,0.,35.,0.)
         CALL HBOOK1(10022,'LEPTON E SPECTRUM IN CMS B->D*',50,0.,5.,0.)
         CALL HBOOK1(10023,'LEPTON E BOOSTED IN LAB B->D*',50,0.,35.,0.)
         CALL HBOOK1(10024,'LEPTO E SPECTRUM IN CMS B->D_1',50,0.,5.,0.)
         CALL HBOOK1(10025,'LEPTO E BOOSTED IN LAB B->D_1',50,0.,35.,0.)
         CALL HBOOK1(10026,'LEPTO E SPECTRUM IN CMS B->D*0',50,0.,5.,0.)
         CALL HBOOK1(10027,'LEPTO E BOOSTED IN LAB B->D*0',50,0.,35.,0.)
         CALL HBOOK1(10028,'LEPTO E SPECTRUM IN CMS B->D*1',50,0.,5.,0.)
         CALL HBOOK1(10029,'LEPTO E BOOSTED IN LAB B->D*1',50,0.,35.,0.)
         CALL HBOOK1(10034,'LEPTO E SPECTRUM IN CMS B->D*2',50,0.,5.,0.)
         CALL HBOOK1(10035,'LEPTO E BOOSTED IN LAB B->D*2',50,0.,35.,0.)
         DO 2 J=1,NDECAY
         AM1=ULMASS(NO1(J))
         AM2=ULMASS(NO2(J))
         IF(J.GE.9.AND.IMODSS.EQ.0)GOTO 2
         IMOSIM=IMOSEM
         IF(J.GE.9)IMOSEM=5
         IF(IMOSEM.EQ.5)THEN
           CALL LUIFLV (NO1(J),IFLA,IFLB,IFLC,KSP)
           CALL LUIFLV (NO2(J),IFLA1,IFLB1,IFLC1,KSP1)
           MB=ULMASS(IFLA)
           MD=ULMASS(IFLB)
           MQ=ULMASS(IFLA1)
           IF(IFLA.EQ.4)MB=1.82
           IF(IFLA.EQ.5)MB=5.12
           IF(IFLB.EQ.1.OR.IFLB.EQ.2)MD=0.33
           IF(IFLB.EQ.3)MD=0.55
           IF(IFLB.EQ.4)MD=1.82
           IF(IFLA1.EQ.3)MQ=0.55
           IF(IFLA1.EQ.4)MQ=1.82
           BM=AM1
           BMSQ=BM**2
           XMT=AM2
           XMTSQ=XMT**2
           BB=BBDAT(J)
           BX=BXDAT(J)
           MBOT=MB+MD
           MX=MD+MQ
           MUP=(MB*MQ)/(MB+MQ)
           MUM=(MB*MQ)/(MB-MQ)
           MS=MBOT-MX
           MSQ=(MD**2)/(MX*MBOT)
           MRSQ=BMSQ/XMTSQ
           BBX=(BB**2+BX**2)/2.
           BR=BB**2/BBX
           BRX=BX**2/BBX
           KSQ=0.7**2
         ENDIF
C
C  CHECK OF F , ETC....
C
C  WHAT DO WE WANT FOR RHO AND K*?
C
         WTM(IMOSEM,J)=HIMAX(IMOSEM,J,AM1,AM2)*1.3
         IF(J.GE.9.AND.IMODSS.NE.0)IMOSEM=IMOSIM
 2       CONTINUE
         MSTJ(24)=MSTSO
         NDASEM=IW(JSEM)
         IF(NDASEM.GT.2.AND.NDASEM.LT.5)THEN
           WRITE(IW(6),100) NDASEM
 100       FORMAT(1X,'GSEM DATA CARD : WARNING - YOU SHOULD PROVIDE
     *   2 OR 5 DATA : NOT',I4)
         ELSEIF (NDASEM.EQ.5) THEN
           PRM11=RW(JSEM+3)
           PR01=RW(JSEM+4)
           PRP11=RW(JSEM+5)
           PRM1=PRM11
           PR0=PRM1+PR01
           PRP1=PR0+PRP11
           IF(PRP1.GT.1.)WRITE(IW(6),'(1X,''***WARNING**** PROBABILITIES
     $ IN GSEM CARD DO NOT ADD TO 1. ****CHANGE IT!'' )')
           KHEL=1
         ENDIF
C
C  Create KSEM bank
C
          TABL(1) = FLOAT(ISEM)
          TABL(2) = FLOAT(IHEL)
          IF (NDASEM.EQ.5) THEN
            TABL(3) = PRM11
            TABL(4) = PR01
            TABL(5) = PRP11
          ENDIF
          NWB = NDASEM
          IND = ALTABL('KSEM',NWB,1,TABL,'2I,(F)','C')
          IF ( IMODSS.NE.0) THEN
             TABL(1) = FLOAT(IMODSS)
             NWB = 1
             IF ( IMODSS.EQ.4) THEN
                NWB = 4
                TABL(2) = R1
                TABL(3) = R2
                TABL(4) = R3
             ENDIF
             IND = ALTABL('KDSS',NWB,1,TABL,'2I,(F)','C')
          ENDIF
      ENDIF
999   RETURN
      END
      SUBROUTINE INISIN(IFLV,ECMS)
C ------------------------------------------------------------------
C - B. Bloch  - October 1990
C! Init single particle generation  jetset 7.4
C
C     comdecks referenced :  BCS ,SINGEN
C ------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
      COMMON/SINGEN/ITYPSI,PMINSI,PMAXSI,COMISI,COMASI,PHMISI,PHMASI
C   single particle settings
      JSIN=IW(NAMIND('GSIN'))
      IF(JSIN.NE.0)THEN
         ITYPSI=IW(JSIN+1)
         PMINSI=RW(JSIN+2)
         PMAXSI=RW(JSIN+3)
         COMISI=RW(JSIN+4)
         COMASI=RW(JSIN+5)
         PHMISI=RW(JSIN+6)
         PHMASI=RW(JSIN+7)
      ELSE
         WRITE(IW(6),100)
         CALL EXIT
      ENDIF
 100  FORMAT (1X,'YOU DID NOT GIVE ANY INPUT CARD GSIN !!!!! STOP-')
      IFLV = ITYPSI
      ECMS = 2.*ULMASS(ITYPSI)
      RETURN
      END
      SUBROUTINE INITODK(ITDC)
C ------------------------------------------------------------------
C - B. Bloch  - September  1994
C! INITIALIZATION ROUTINE TO SET UP THE TAU DECAY INTERFACE TO TAUOLA
C  ITDC = 0  NO SPECIAL SET UP REQUIRED
C  ITDC = 1  SPECIAL SET UP ACTIVATED FOR TAU DECAYS
C     comdecks referenced : LUN7COM , BCS
C ------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      ITDC =0
      JTDC=IW(NAMIND('GTAU'))
      IF(JTDC.NE.0)THEN
         JAK1  =IW(JTDC+1)
         JAK2  =IW(JTDC+2)
         ISPIN =IW(JTDC+3)
         ITDKRC=IW(JTDC+4)
         XK0DEC=RW(JTDC+5)
         GV    =RW(JTDC+6)
         GA    =RW(JTDC+7)
      ELSE
         JAK1 = 0
         JAK2 = 0
         ISPIN = 1
         ITDKRC = 1
         XK0DEC = 0.001
         GV = 1.
         GA =-1.
      ENDIF
      IF  ( ISPIN.GT.0) ITDC = ITDC + 1
      IF  ( ITDKRC.GT.0) ITDC = ITDC + 2
      CALL TAUOLAI
      RETURN
      END
      SUBROUTINE INIVBU(IVBU)
C ------------------------------------------------------------------
C - B. Bloch  - OCTOBER  1994 - JETSET 7.4 version
C   All B's may have have differnet decay schemes. No more generic B
C                                                            ENTRY point
C! Initialization routine of Vbu transitions                 INIVBU
C  Implement b-->u transition according to requested model   VBCVBU
C  Restore   b-->c transition as defined primarily           VBUVBC
C
C     comdecks referenced : LUN7COM , BCS ,BCODES ,LCODES ,VBUCOM
C ------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      COMMON/VBUCOM/ IMATBU,PRBUBC,PARDBU,ITYPBU
      PARAMETER (NBU=521,NBD=511,NBS=531,NBC=541)
      PARAMETER (NLB=5122,NXB= 5132)
      PARAMETER (NXB0=5232,NOB= 5332)
C     NBU    = internal JETSET 7.4 code for Bu meson
C     NBD    = internal JETSET 7.4 code for Bd meson
C     NBS    = internal JETSET 7.4 code for Bs meson
C     NBC    = internal JETSET 7.4 code for Bc meson
C     NLB    = internal JETSET 7.4 code for /\B BARYON
C     NXB    = internal JETSET 7.4 code for XIB BARYON
C     NXB0   = internal JETSET 7.4 code for XIB0 BARYON
C     NOB    = internal JETSET 7.4 code for OMEGAB BARYON
      PARAMETER (NLEPTO=3,LMATHA=42)
      PARAMETER(LTHRES=32,LBMAX=5,LBROW=4,NTYPBU=4)
      DIMENSION CBRBU(LBMAX,NTYPBU)
C     NLEPTO  = number of semi-leptonic modes
C     LMATHA  = matrix element type for Hadronic modes
C     LTHRESH = index of PARJ location corresponding to threshold
C     LBPOS   = B meson flavor location
C     LBMAX   = # of transitions for b quark
C     LBROW   = max number of particles in a final state
C     NTYPBU  = # of Vbu transition types implemented
      DIMENSION KDPSTO(LBMAX,LBROW),CBRSTO(LBMAX),MDMSTO(LBMAX,2)
      DIMENSION ICHBU1(LBMAX,LBROW),IMATB1(LBMAX)
      DIMENSION ICHABU(LBMAX,LBROW),LBMOD(NTYPBU),TABL(50)
      INTEGER ALTABL
      PARAMETER (NNUEL=12,NNUMU=14,NNUTO=16,NEL=11,NMU=13,NTO=15)
C     NNUEL  = internal JETSET 7.4 code for neutrino electron
C     NNUMU  = internal JETSET 7.4 code for neutrino mu
C     NNUTO  = internal JETSET 7.4 code for neutrino tau
C     NEL    = internal JETSET 7.4 code for electron
C     NMU    = internal JETSET 7.4 code for muon
C     NTO    = internal JETSET 7.4 code for tau
      DATA ICHABU/12,14,16,2,4,-11,-13,-15,-1,-3,5*-2,5*81/
      DATA ICHBU1/12,4*0,-11,4*0,-2,4*0,81,4*0/ IMATB1/42,4*0/
      DATA LBMOD/5,5,5,0/
C ----BR's are now non cumulative!!
      DATA (CBRBU(IU,1),IU=1,5)/0.143,0.143,0.071,0.429,0.214/
      DATA (CBRBU(IU,2),IU=1,5)/0.134,0.134,0.052,0.49,0.19/
      DATA (CBRBU(IU,3),IU=1,5)/0.117,0.117,0.043,0.465,0.258/
      DATA (CBRBU(IU,4),IU=1,5)/5*0./
C
C  Get B-->U transitions parameters
C   IMATBU: LUND Matrix Element (42 or 44)
C       42 the u and spectator collapse --> meson
C       44 other mesonic systems can be produced if the available
C          invariant mass is large enough
C
C   PARDBU: PARJ(32) can be modified to produce more realistic features
C           when IMATBU=44
C
C   ITYPBU: = 1 Free Quark Model
C             2  NLL QCD CORRECTIONS WITH CONSTITUENT MASS FOR QUARKS
C             3     "     "     "     "   CURRENT       "       "
C             4  user defined transition
C            other models may be provided later
      IVBU =0
      JVBU=IW(NAMIND('GVBU'))
      IF(JVBU.NE.0)THEN
         IMATBU=IW(JVBU+1)
         PRBUBC=RW(JVBU+2)
         PARDBU=RW(JVBU+3)
         ITYPBU=IW(JVBU+4)
         IF (PRBUBC.GT.0.) IVBU = ITYPBU
      ELSE
         IMATBU=42
         PRBUBC=0.
         PARDBU=1.0
         ITYPBU=1
      ENDIF
      CALL HTABLE(10030,'b->u transition codes/event VS mixing code',
     $   6,0., 6., 8,0., 8.,0.)
      CALL HBPRO(0,0.)
      IF ( IVBU.GT.0) THEN
C
C   This modifies the LUND decay table of the B mesons.
C   Free Quark Model expectation is introduced as a first approximation
C
        CALL VZERO(CBRSTO,LBMAX)
        CALL VZERO(KDPSTO,LBMAX*LBROW)
        CALL VZERO(MDMSTO,LBMAX*2)
C
C  The original B Decays (Decay Mode and Branching Ratios) are stored
C
        IF(ITYPBU.LT.1.OR.ITYPBU.GT.NTYPBU)THEN
          WRITE(IW(6),102)
 102      FORMAT(1X,'THE TYPE FOR B-->U TRANSITION IS UNCORRECT')
          CALL EXIT
        ENDIF
        JBUS = 0
        IF(ITYPBU.EQ.4)THEN
C
C  B-->U  TRANSITION INTRODUCED BY USERS
C  (NOT MORE THAN 4 DECAY CHAINS)
C
          JBUS=IW(NAMIND('GBUS'))
          IF(JBUS.NE.0)THEN
            NCOM=IW(JBUS)/6
            IF(NCOM.EQ.0)GOTO 30
            DO 17 IBU=1,NCOM
            CBRBU(IBU,ITYPBU)=RW(JBUS+(IBU-1)*6+6)
            DO 18 JBU=1,LBROW
            IF(IBU.EQ.1)THEN
              IF(IW(JBUS+1+JBU).NE.ICHBU1(1,JBU) .OR.
     $                  (IW(JBUS+1).NE.IMATB1(1)))THEN
              WRITE(IW(6),103) IMATB1(1),(ICHBU1(1,JJBU),JJBU=1,LBROW)
 103          FORMAT(1X,'INIVBU : WARNING -  YOUR FIRST DECAY CHANNEL
     * FOR B-->U TRANSITION IS UNCORRECT: IT SHOULD BE:',5I5)
              GOTO 17
              ENDIF
            ENDIF
            ICHBU1(IBU,JBU)=IW(JBUS+(IBU-1)*6+1+JBU)
 18         CONTINUE
            IMATB1(IBU)=IW(JBUS+(IBU-1)*6+1)
 17         CONTINUE
            LBMOD(ITYPBU)=LBMOD(ITYPBU)+NCOM
 30         CONTINUE
          ENDIF
        ENDIF
C   Fill bank KVBU
        TABL(1) = FLOAT(IVBU)
        TABL(2) = FLOAT(ITYPBU)
        TABL(3) = PRBUBC
        TABL(4) = FLOAT(IMATBU)
        TABL(5) = PARDBU
        NWB = 5
        IF (JBUS.NE.0) THEN
          DO 56 ICO = 1,NCOM
          DO 55 II= 1,5
 55       TABL(5+II+6*(ICO-1)) = FLOAT(IW(JBUS+II+6*(ICO-1)))
          TABL(5+6+6*(ICO-1)) = RW(JBUS+6+6*(ICO-1))
 56       CONTINUE
          NWB = NWB +IW(JBUS)
        ENDIF
        IND = ALTABL('KVBU',NWB,1,TABL,'2I,(F)','C')
      ENDIF
      RETURN
C
      ENTRY VBCVBU  (KF)
C  IMPLEMENT B-->U TRANSITIONS
      PARJ(LTHRES)=PARDBU
      KC = LUCOMP(KF)
      IENTRY=MDCY(KC,2)
      LBMIN=LBMOD(ITYPBU)
      NMBR = MIN(MDCY(KC,3),LBMIN)
C  Store the current decay scheme
      IF ( NMBR.GT.0) THEN
          DO 11 NBR = 1,NMBR
            IF(NBR.GT.LBMIN)GOTO 12
            CBRSTO(NBR)=BRAT(IENTRY)
            MDMSTO(NBR,2)=MDME(IENTRY,2)
            MDMSTO(NBR,1)=MDME(IENTRY,1)
            DO 13 I=1,LBROW
            KDPSTO(NBR,I)=KFDP(IENTRY,I)
 13         CONTINUE
            IENTRY=IENTRY+1
 11       CONTINUE
        ENDIF
 12     CONTINUE
        NBR=NMBR
        PARSTO=PARJ(LTHRES)
        IF(NBR.LT.LBMIN)THEN
         WRITE(IW(6),100) KF
 100     FORMAT(1X,'YOU DO NOT HAVE ENOUGH SPACE TO IMPLEMENT VBU transi
     $tions for particle ',I10)
C
C  PREVOIR DE CREER (LBMIN-NBR)LIGNES
C
         CALL EXIT
        ENDIF
C
C  Free Quark Model expectation for Branching ratios
C
      ISPEC = MOD(KF/10,10)
      IENTRY=MDCY(KC,2)
      IF(ITYPBU.LE.3)THEN
C
C  New Decay Modes are built
C
        DO 4 I=1,LBMIN
        IMATT=IMATBU
        IF(I.GT.NLEPTO)IMATT=LMATHA
        MDME(IENTRY,2) =IMATT
        MDME(IENTRY,1) =1
        BRAT(IENTRY)=CBRBU(I,ITYPBU)
        DO 5 J=1,LBROW-1
         KFDP(IENTRY,J)=ICHABU(I,J)
  5     CONTINUE
        KFDP(IENTRY,LBROW)= ISPEC
        IENTRY=IENTRY+1
  4     CONTINUE
      ELSEIF (ITYPBU.EQ.4)THEN
          DO 19 IEN=1,NCOM
            BRAT(IENTRY-1+IEN)=CBRBU(IEN,ITYPBU)
            MDME(IENTRY-1+IEN,2) = IMATB1(IEN)
            MDME(IENTRY-1+IEN,1) =1
            DO 20 JEN=1,LBROW-1
              KFDP(IENTRY-1+IEN,JEN)=ICHBU1(IEN,JEN)
 20         CONTINUE
            KFDP(IENTRY-1+IEN,LBROW)= ISPEC
 19       CONTINUE
      ELSE
        WRITE(IW(6),101)
 101   FORMAT(1X,'YOU DID NOT IMPLEMENT CORRECTLY B-->U TRANSITION ')
      ENDIF
      NTOT = MDCY(KC,3)-LBMIN
      IF ( NTOT .GT. 0) THEN
        DO 3 IJ = 1,NTOT
          MDME(MDCY(KC,2)+LBMIN+IJ-1,1) =0
  3     CONTINUE
      ENDIF
      RETURN
      ENTRY VBUVBC (KF)
C---------------------------------------------------------------------
C   Routine to restore b->c transition in B decays
C---------------------------------------------------------------------
      KC =LUCOMP(KF)
      IENTRY = MDCY(KC,2)
      DO 1 I=1,NBR
      BRAT(IENTRY)=CBRSTO(I)
      MDME(IENTRY,1)=MDMSTO(I,1)
      MDME(IENTRY,2)=MDMSTO(I,2)
        DO 2 J=1,LBROW
        KFDP(IENTRY,J)=KDPSTO(I,J)
 2      CONTINUE
      IENTRY=IENTRY+1
 1    CONTINUE
      PARJ(LTHRES)=PARSTO
      NTOT = MDCY(KC,3)-LBMIN
      IF ( NTOT .GT. 0) THEN
        DO 23 IJ = 1,NTOT
          MDME(MDCY(KC,2)+LBMIN+IJ-1,1) =1
 23     CONTINUE
      ENDIF
      RETURN
      END
      INTEGER FUNCTION KBCP(NT)
C---------------------------------------------------------------------
C!  Analyse event history to determine if event corresponds to B decay
C into the user specified final state  (as defined in the GSTA card)
C AUTHOR: B. Bloch-Devaux           881110
C
C   Input : NT track number
C
C   Output:  KBCP = status versus Final state of decaying track NT
C           0 means not a B meson or B meson not decaying into
C                     specified final state (GSTA card)
C           +1 means B meson (d or s ) decaying into specified channel
C           -1 means Bbar meson (d or s) decaying into specified channel
C
C     comdecks referenced :  BCS ,BCODES , USERCP,BMACRO ,KMACRO
C---------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
      PARAMETER (LNBRCP=4)
      COMMON/USERCP/NPARCP,JCODCP(LNBRCP),RHOCPM
      COMPLEX RHOCPM
      DIMENSION NIDEN(LNBRCP)
      PARAMETER (NBU=521,NBD=511,NBS=531,NBC=541)
      PARAMETER (NLB=5122,NXB= 5132)
      PARAMETER (NXB0=5232,NOB= 5332)
C     NBU    = internal JETSET 7.4 code for Bu meson
C     NBD    = internal JETSET 7.4 code for Bd meson
C     NBS    = internal JETSET 7.4 code for Bs meson
C     NBC    = internal JETSET 7.4 code for Bc meson
C     NLB    = internal JETSET 7.4 code for /\B BARYON
C     NXB    = internal JETSET 7.4 code for XIB BARYON
C     NXB0   = internal JETSET 7.4 code for XIB0 BARYON
C     NOB    = internal JETSET 7.4 code for OMEGAB BARYON
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
C - index of the next vertex/track to be stored in KINE/VERT
C   bank known by its index JVK
      KNEXVK(JVK) = JVK + IW(JVK+1)+IW(JVK+2)+IW(JVK+3)
C - # of vertices/tracks which could be stored in KINE/VERT
C   bank known by its index JVK
      LFRVK(JVK)  = IW(JVK) - (IW(JVK+1)+IW(JVK+2)+IW(JVK+3))
C - index of the 1st parameter of KINE/VERT bank known by its
C   index JVK
      KPARVK(JVK) = JVK + IW(JVK+1)
C - index of 1st vertex/track # contained into the list of
C   bank KINE/VERT known by its index JVK
      KLISVK(JVK) = JVK + IW(JVK+1) + IW(JVK+2)
C - charge of ALEPH particle# JPA
      CHARGE(JPA) = RTABL(IW(NAPAR),JPA,7)
C - mass of ALEPH particle# JPA
      PARMAS(JPA) = RTABL(IW(NAPAR),JPA,6)
C - time of life of ALEPH particle# JPA
      TIMLIF(JPA) = RTABL(IW(NAPAR),JPA,8)
C - # of vertices on a track known by its BOS index JVK /
C   # of outgoing tracks of a vertex known by its BOS index JVK
      NOFVK(JVK)  = IW(JVK+3)
C - Particle type of a track known by its BOS index JVK
      KINTYP(JVK) = IW(KPARVK(JVK)+5)
C - incoming track # of a vertex known by its BOS index JVK
      INPTRK(JVK) = IW(KPARVK(JVK)+5)
C - origin vertex # of a track known by its BOS index JVK
      INPVRT(JVK) = IW(KLISVK(JVK)+1)
C - momentum of a track known by its BOS index JVK
      PMODVK(JVK) = SQRT (RW(KPARVK(JVK)+1)**2 + RW(KPARVK(JVK)+2)**2
     &                   +RW(KPARVK(JVK)+3)**2)
C - energy of a track known by its BOS index JVK
      ENERVK(JVK) = SQRT( PMODVK(JVK)*PMODVK(JVK)+RW(KPARVK(JVK)+4)**2)
C - time of flight of the icoming particle to the vertex known by its
C   BOS index JVK
      TOFLIT(JVK) = RW(KPARVK(JVK)+4)
C - radius of the vertex known by its BOS index
      RADVK(JVK)  = SQRT (RW(KPARVK(JVK)+1)**2 + RW(KPARVK(JVK)+2)**2)
C - mother track # of a track known by its BOS index
      MOTHVK(JVK) = INPTRK (NLINK('VERT',INPVRT(JVK)))
C.......................................................
      KBCP=0
      IF( NPARCP.LE.0 ) GOTO 999
      JKHIS = IW (NAMIND('KHIS'))
      JKLIN = IW (NAMIND('KLIN'))
C  IF KLIN OR KHIS BANK NOT HERE NO ANALYSIS CAN BE DONE
      IF (JKHIS*JKLIN.NE.0) THEN
      NPAR = IW(JKHIS+LMHROW)
      IF (NPAR.GT.0) THEN
      JKINM = NLINK('KINE',NT)
      IF (JKINM.NE.0) THEN
      DO 1 K = 1,LNBRCP
 1    NIDEN(K)=0
      ICODM = KINTYP(JKINM)
      LCODM = ITABL(JKLIN,ICODM,1)
      KCODM = ABS (LCODM)
C  ICODM IS ALEPH CODE, LCODM THE GENERATOR(LUND) CORRESPONDING CODE
      IF (KCODM.EQ.NBD .OR. KCODM.EQ.NBS) THEN
C  WE HAVE A Bd OR A Bs   ...look for daughters
      DO 10 I = NT+1,NPAR
        IMOTH = MOD(ITABL(JKHIS,I,1),10000)
        IF (IMOTH.NE.NT) GO TO 10
C  Mother is the right one
C  Look if daughter's type is among the requested ones
C  Daughter's KINE has NR =I
      JKINF = NLINK('KINE',I)
      IF (JKINF.NE.0 ) THEN
        ICODF = KINTYP(JKINF)
        LCODF = ITABL(JKLIN,ICODF,1)
        DO 20 K = 1,NPARCP
          IF (LCODF.EQ.JCODCP(K)) THEN
             NIDEN(K) = NIDEN(K) +1
          ENDIF
  20    CONTINUE
      ENDIF
  10  CONTINUE
      ENDIF
C  Look if we get all particles required as final state
      KBCP = 1
      DO 30 K = 1,NPARCP
      IF (NIDEN(K).NE.1) KBCP=0
 30   CONTINUE
      KBCP = KBCP * SIGN(1 , LCODM)
      ENDIF
      ENDIF
      ENDIF
 999  CONTINUE
      RETURN
      END
      INTEGER FUNCTION KBOSCI(NT)
C----------------------------------------------------------------------
C! Gives status of track # NT versus B osccillation from KINE and KHIS
C! banks analysis
C  AUTHOR:  A.FALVARD                 881024
C           B.Bloch-Devaux            900926
C
C     =1       BD-->BD        ( +C.C.)
C     =2       BD-->BDBAR     ( +C.C.)
C     =3       BS-->BS        ( +C.C.)
C     =4       BS-->BSBAR     ( +C.C.)
C     comdecks referenced : BCS ,BCODES ,BMACRO ,KMACRO
C---------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
      PARAMETER (NBU=521,NBD=511,NBS=531,NBC=541)
      PARAMETER (NLB=5122,NXB= 5132)
      PARAMETER (NXB0=5232,NOB= 5332)
C     NBU    = internal JETSET 7.4 code for Bu meson
C     NBD    = internal JETSET 7.4 code for Bd meson
C     NBS    = internal JETSET 7.4 code for Bs meson
C     NBC    = internal JETSET 7.4 code for Bc meson
C     NLB    = internal JETSET 7.4 code for /\B BARYON
C     NXB    = internal JETSET 7.4 code for XIB BARYON
C     NXB0   = internal JETSET 7.4 code for XIB0 BARYON
C     NOB    = internal JETSET 7.4 code for OMEGAB BARYON
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
C - index of the next vertex/track to be stored in KINE/VERT
C   bank known by its index JVK
      KNEXVK(JVK) = JVK + IW(JVK+1)+IW(JVK+2)+IW(JVK+3)
C - # of vertices/tracks which could be stored in KINE/VERT
C   bank known by its index JVK
      LFRVK(JVK)  = IW(JVK) - (IW(JVK+1)+IW(JVK+2)+IW(JVK+3))
C - index of the 1st parameter of KINE/VERT bank known by its
C   index JVK
      KPARVK(JVK) = JVK + IW(JVK+1)
C - index of 1st vertex/track # contained into the list of
C   bank KINE/VERT known by its index JVK
      KLISVK(JVK) = JVK + IW(JVK+1) + IW(JVK+2)
C - charge of ALEPH particle# JPA
      CHARGE(JPA) = RTABL(IW(NAPAR),JPA,7)
C - mass of ALEPH particle# JPA
      PARMAS(JPA) = RTABL(IW(NAPAR),JPA,6)
C - time of life of ALEPH particle# JPA
      TIMLIF(JPA) = RTABL(IW(NAPAR),JPA,8)
C - # of vertices on a track known by its BOS index JVK /
C   # of outgoing tracks of a vertex known by its BOS index JVK
      NOFVK(JVK)  = IW(JVK+3)
C - Particle type of a track known by its BOS index JVK
      KINTYP(JVK) = IW(KPARVK(JVK)+5)
C - incoming track # of a vertex known by its BOS index JVK
      INPTRK(JVK) = IW(KPARVK(JVK)+5)
C - origin vertex # of a track known by its BOS index JVK
      INPVRT(JVK) = IW(KLISVK(JVK)+1)
C - momentum of a track known by its BOS index JVK
      PMODVK(JVK) = SQRT (RW(KPARVK(JVK)+1)**2 + RW(KPARVK(JVK)+2)**2
     &                   +RW(KPARVK(JVK)+3)**2)
C - energy of a track known by its BOS index JVK
      ENERVK(JVK) = SQRT( PMODVK(JVK)*PMODVK(JVK)+RW(KPARVK(JVK)+4)**2)
C - time of flight of the icoming particle to the vertex known by its
C   BOS index JVK
      TOFLIT(JVK) = RW(KPARVK(JVK)+4)
C - radius of the vertex known by its BOS index
      RADVK(JVK)  = SQRT (RW(KPARVK(JVK)+1)**2 + RW(KPARVK(JVK)+2)**2)
C - mother track # of a track known by its BOS index
      MOTHVK(JVK) = INPTRK (NLINK('VERT',INPVRT(JVK)))
C.......................................................
      KBOSCI=0
      IF(NT.EQ.1)GOTO 999
      JKINE=NLINK('KINE',NT)
      JNAME=KINTYP(JKINE)
      JKLIN = NLINK('KLIN',0)
      IF (JKLIN.EQ.0) GO TO 999
      LNAME = ITABL(JKLIN,JNAME,1)
      KNAME = ABS ( LNAME)
      IF(KNAME.NE.NBD.AND.KNAME.NE.NBS)GOTO 999
      IKHIS=NLINK('KHIS',0)
      IF(IKHIS.EQ.0)GOTO 999
      IMOTH=MOD(IW(IKHIS+LMHLEN+NT),10000)
      JKINE=NLINK('KINE',IMOTH)
      JNAME1=KINTYP(JKINE)
      LNAME1 = ITABL(JKLIN,JNAME1,1)
      KNAME1 = ABS ( LNAME1)
      IF(KNAME1.NE.NBD.AND.KNAME1.NE.NBS)GOTO 999
      IF (LNAME . EQ. LNAME1 ) THEN
         KBOSCI = 1
      ELSEIF (LNAME.EQ.-LNAME1) THEN
         KBOSCI = 2
      ENDIF
      IF (KNAME1.EQ.NBS) KBOSCI=KBOSCI+2
C
C  KBOSCI=1      BD-->BD      (+ C.C.)
C  KBOSCI=2      BD-->BDB     (+ C.C.)
C  KBOSCI=3      BS-->BS      (+ C.C.)
C  KBOSCI=4      BS-->BSB     (+ C.C.)
C
 999  CONTINUE
      RETURN
      END
      INTEGER FUNCTION KB7MIX(ITR)
C---------------------------------------------------------------------
C! Check if track is result of B mixing  LUND 7.4 version
C  AUTHOR: B. BLOCH-DEVAUX AND A. FALVARD          881024 900926
C  works from quantities in the lund coomon
C  =0:  THE ITR TRACK IS NOT THE RESULT OF B-BBAR OSCILLATION
C  =1:  "     "    "  IS THE RESULT OF B-BBAR OSCILLATION
C     comdecks referenced : LUN7COM  ,BCODES
C---------------------------------------------------------------------
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      PARAMETER (NBU=521,NBD=511,NBS=531,NBC=541)
      PARAMETER (NLB=5122,NXB= 5132)
      PARAMETER (NXB0=5232,NOB= 5332)
C     NBU    = internal JETSET 7.4 code for Bu meson
C     NBD    = internal JETSET 7.4 code for Bd meson
C     NBS    = internal JETSET 7.4 code for Bs meson
C     NBC    = internal JETSET 7.4 code for Bc meson
C     NLB    = internal JETSET 7.4 code for /\B BARYON
C     NXB    = internal JETSET 7.4 code for XIB BARYON
C     NXB0   = internal JETSET 7.4 code for XIB0 BARYON
C     NOB    = internal JETSET 7.4 code for OMEGAB BARYON
      ILUN=ABS(K7LU(ITR,2))
      KB7MIX=0
      IF(ITR.EQ.N7LU)RETURN
      IF(ILUN.EQ.NBD.OR.ILUN.EQ.NBS)THEN
C  WE HAVE A BD MESON OR A BS MESON ,  LOOK IF DAUGHTER IS ONE ALSO
        IDAUG = K7LU(ITR,4)
        ILAST = K7LU(ITR,5)
        IF (IDAUG.GT.0 .AND.ILAST.EQ.IDAUG) THEN
C  ARE MOTHER AND DAUGHTER B MESONS?
          ILUM=ABS(K7LU(IDAUG,2))
          IF(ILUN.EQ.ILUM)THEN
            KB7MIX=1
C  MIXING OCCURED IN THE PROCESS
          ENDIF
C  ONE DAUGHTER FOUND BUT NOT A B MESON:  NO MIXING AND RETURN
        ENDIF
      ENDIF
      RETURN
      END
      SUBROUTINE KFMIBK (VMAIN,RPARA,IPARA,MTRAK,ISTAT)
C -----------------------------------------------------------
C   A. FALVARD and B. Bloch to include mixing and CP violation Oct.88
C (from KFEVBK  from J.Boucrot - B.Bloch - F.Ranjard - 870515  )
C! Fill event banks KINE VERT KHIS
C  first KINE and VERT banks are booked and filled with parameters
C        sent as arguments (all vertices at the same position).
C  then  depending on the decay length of secondary particles , the
C        secondary vertices are displaced from the main vertex . The
C        propagation follows a straight line for neutral generating a
C        secondary vertec, and a simple helix for charged particles.
C        In case of charge particles generating a secondary vertex,
C        swim Px and Py of all secondaries up to decay vertex. Then
C        store the time of flight.
C        The magnetic field is assumed to be 15.0 Kgauss.
C
C - structure: SUBROUTINE subprogram
C              USER ENTRY NAME: KFMIBK
C              External References: KBVERT/KBKINE/KGPART/KGDECL(ALEPHLIB
C                                   KBOSCI/MIDECL/CPUSER(THIS LIB)
C              Comdecks referenced: BCS, ALCONS, KIPARA, BMACRO, KMACRO
C
C - USAGE   : CALL KFMIBK (VMAIN,RPARA,IPARA,MTRAK,ISTAT)
C - Input   : VMAIN          = vx,vy,vz of the main vertex
C             RPARA (1-4,k)  = px,py,pz,(E) of track(k)
C                              if RPARA(4,k)=0. then the Energy is
C                              computed by the package itself
C             IPARA (1,k)    = vertex# of the origin of the track(k)
C                   (2,k)    = vertex# of the decay of the track(k)
C                                0 if there is no decay
C                   (3,k)    = ALEPH particle#
C             MTRAK          = # of tracks
C             ISTAT          = return code  ( 0 means OK)
C                              -1 means too many particles
C                              -2 means wrong KINE/VERT booking
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
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
      PARAMETER (LHKIN=3, LPKIN=5, LKVX=2, LHVER=3, LPVER=5, LVKI=50)
      PARAMETER (LGDCA=32)
      PARAMETER (LRPART=200, LCKLIN=1)
      PARAMETER (LRECL=16380, LRUN=1, LEXP=1001, LRTYP=1000)
      CHARACTER*60 LTITL
      PARAMETER (LUCOD=0, LNOTRK=100, LTITL='KINGAL run')
      PARAMETER (LUTRK=350)
      PARAMETER (BFIEL=15., CFIEL=BFIEL*3.E-4)
      PARAMETER (CLITS = CLGHT * 1.E+09)
      INTEGER IPARA(3,*)
      REAL RPARA(4,*),VMAIN(3)
      REAL KGDECL,MIDECL,CPDECL
      EXTERNAL KBOSCI
      LOGICAL FDECAY,FNEUTR
      DATA NAPAR /0/
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
C - index of the next vertex/track to be stored in KINE/VERT
C   bank known by its index JVK
      KNEXVK(JVK) = JVK + IW(JVK+1)+IW(JVK+2)+IW(JVK+3)
C - # of vertices/tracks which could be stored in KINE/VERT
C   bank known by its index JVK
      LFRVK(JVK)  = IW(JVK) - (IW(JVK+1)+IW(JVK+2)+IW(JVK+3))
C - index of the 1st parameter of KINE/VERT bank known by its
C   index JVK
      KPARVK(JVK) = JVK + IW(JVK+1)
C - index of 1st vertex/track # contained into the list of
C   bank KINE/VERT known by its index JVK
      KLISVK(JVK) = JVK + IW(JVK+1) + IW(JVK+2)
C - charge of ALEPH particle# JPA
      CHARGE(JPA) = RTABL(IW(NAPAR),JPA,7)
C - mass of ALEPH particle# JPA
      PARMAS(JPA) = RTABL(IW(NAPAR),JPA,6)
C - time of life of ALEPH particle# JPA
      TIMLIF(JPA) = RTABL(IW(NAPAR),JPA,8)
C - # of vertices on a track known by its BOS index JVK /
C   # of outgoing tracks of a vertex known by its BOS index JVK
      NOFVK(JVK)  = IW(JVK+3)
C - Particle type of a track known by its BOS index JVK
      KINTYP(JVK) = IW(KPARVK(JVK)+5)
C - incoming track # of a vertex known by its BOS index JVK
      INPTRK(JVK) = IW(KPARVK(JVK)+5)
C - origin vertex # of a track known by its BOS index JVK
      INPVRT(JVK) = IW(KLISVK(JVK)+1)
C - momentum of a track known by its BOS index JVK
      PMODVK(JVK) = SQRT (RW(KPARVK(JVK)+1)**2 + RW(KPARVK(JVK)+2)**2
     &                   +RW(KPARVK(JVK)+3)**2)
C - energy of a track known by its BOS index JVK
      ENERVK(JVK) = SQRT( PMODVK(JVK)*PMODVK(JVK)+RW(KPARVK(JVK)+4)**2)
C - time of flight of the icoming particle to the vertex known by its
C   BOS index JVK
      TOFLIT(JVK) = RW(KPARVK(JVK)+4)
C - radius of the vertex known by its BOS index
      RADVK(JVK)  = SQRT (RW(KPARVK(JVK)+1)**2 + RW(KPARVK(JVK)+2)**2)
C - mother track # of a track known by its BOS index
      MOTHVK(JVK) = INPTRK (NLINK('VERT',INPVRT(JVK)))
      FDECAY(JTR) = IPARA(2,JTR).GT.1 .AND. IPARA(2,JTR).NE.IPARA(1,JTR)
      FNEUTR(JPA) = ABS (CHARGE(JPA)) .LT. .1
C -------------------------------------------------------
      ISTAT = 0
C
C - Get 'PART' name-index at the 1st entry
      IF (NAPAR .EQ. 0) NAPAR = NAMIND ('PART')
C
C - Create main vertex bank
      IVMAI = 1
      JVERT = KBVERT (IVMAI,VMAIN,0)
C
C - Fill VERT and KINE banks
      DO 1 NT = 1,MTRAK
         JKINE = KBKINE (NT,RPARA(1,NT),IPARA(3,NT),IPARA(1,NT))
         IF (JKINE.LE.0) GOTO 998
         IF (IPARA(2,NT).GT.0) THEN
            JVERT = KBVERT (IPARA(2,NT),VMAIN,NT)
            IF (JVERT.LE.0) GOTO 998
         ENDIF
 1    CONTINUE
C
C - Propagate secondary vertices if any
C
      DO 100 NT = 1,MTRAK
         IPART = IPARA(3,NT)
         PMOD = SQRT (RPARA(1,NT)**2+RPARA(2,NT)**2+RPARA(3,NT)**2)
         TLIF = TIMLIF (IPART)
         ZMAS = PARMAS (IPART)
         IF (FDECAY(NT)) THEN
           JKINE=NLINK('KINE',NT)
           IKHIS=NLINK('KHIS',0)
           IOSCI=KBOSCI(NT)
           IF(IOSCI.EQ.0)THEN
             DCLEN=KGDECL(PMOD,ZMAS,TLIF)
           ELSE
C
C Take into account  B MIXING - 881024
C
             ICP = KBCP(NT)
C LOOKS FOR SPECIFIC DECAYS FOR CP VIOLATION
C
             IF(ICP.NE.0)THEN
                DCLEN=CPDECL(PMOD,ZMAS,TLIF,IOSCI)
             ELSE
                DCLEN=MIDECL(PMOD,ZMAS,TLIF,IOSCI)
             ENDIF
             CALL HFILL(10013+IOSCI,DCLEN,0.,1.)
           ENDIF
C----------------------------------------------------------------------
            IF (DCLEN .LE. 0.) GOTO 100
C           get the origin vertex
            IVOR = IPARA(1,NT)
            JVOR = NLINK ('VERT',IVOR)
            KVO  = KPARVK (JVOR)
C           get the decay vertex
            IVOUT = IPARA(2,NT)
            JVERT = NLINK ('VERT',IVOUT)
            KVX   = KPARVK (JVERT)
            KVTR  = KLISVK (JVERT)
C
C           straight line for neutral generating a secondary vx
            IF (FNEUTR(IPART)) THEN
               DO 102 IX = 1,3
                  RW(KVX+IX) = RW(KVO+IX) + RPARA(IX,NT)*DCLEN/PMOD
 102           CONTINUE
            ELSE
C
C           propagation according to asimple helix for charged
               PT = SQRT (RPARA(1,NT)**2+RPARA(2,NT)**2)
               RAD = PT / (CFIEL*CHARGE(IPART))
               DPSI = DCLEN / RAD
               DXDS = RPARA(1,NT) / PMOD
               DYDS = RPARA(2,NT) / PMOD
               DZDS = RPARA(3,NT) / PMOD
               CPSI = COS (DPSI)
               SPSI = SIN (DPSI)
               DX = RAD * (DXDS*SPSI - DYDS*CPSI + DYDS)
               DY = RAD * (DYDS*SPSI + DXDS*CPSI - DXDS)
               DZ = DCLEN * DZDS
               RW(KVX+1)  = RW(KVO+1) + DX
               RW(KVX+2)  = RW(KVO+2) + DY
               RW(KVX+3)  = RW(KVO+3) + DZ
C           swim Px and Py of all secondaries up to decay vertex
               MTVX = IW(JVERT+3)
               IF (MTVX .GT. 0) THEN
                  DO 103 N=1,MTVX
                     NS = IW (KVTR+N)
                     JKINE = NLINK ('KINE',NS)
                     IF (JKINE.EQ.0) GOTO 998
                     KTR = KPARVK (JKINE)
                     RW(KTR+1) = RPARA(1,NS)*CPSI - RPARA(2,NS)*SPSI
                     RW(KTR+2) = RPARA(1,NS)*SPSI + RPARA(2,NS)*CPSI
 103              CONTINUE
               ENDIF
            ENDIF
C           Store the time of flight
            RW(KVX+4)  = RW(KVO+4) + DCLEN/CLITS
         ENDIF
C
 100   CONTINUE
C
       GOTO 999
C
C - Error
C      unsuccessfull booking of VERT or KINE
 998   ISTAT = -2
C
C - End
 999   CONTINUE
       END
       SUBROUTINE KXLUPJ(IFL)
C ------------------------------------------------------------------
C - B. Bloch  - September  1994
C! routine to set up s/u depending on falvour IFL
C      this routine dummied  now April 18 . 1995 !
C     comdecks referenced : LUN7COM ,PARJCO
C ------------------------------------------------------------------
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      COMMON/PARJCO/P02(5),P13(5),P14(5),P15(5),P16(5),P17(5)
C P02  fraction of s/u for flavor 1...5  from GP02 card
C P13  fraction of V/V+P for flavor 1...5  from GP13 card ( PARJ(11,12))
C P14-16  fraction of Tensor types for flavor 1...5  from GP14-16 card
C P17  fraction of T/T+V for flavor 1...5  from GP17 card
C
      IF ( IFL.LT.0 .OR. IFL.GT.5) go to 99
C      PARJ(2) = P02(IFL)
  99  RETURN
      END
      SUBROUTINE KXL7FL(KS,KF,KM,KFD,KLD,P,NLA)
C--------------------------------------------------------------------
C      B. BLOCH-DEVAUX April  1991
C
C!   Add an entry in LUJETS common JETSET 7.4 version
C     structure : subroutine
C
C     input     : KS  : STATUS CODE
C                 KF  : PARTICLE CODE
C                 KM  : MOTHER NUMBER
C                 KFD : FIRST DAUGHTER ( 0 IF NO)
C                 KFL : LAST  DAUGHTER ( 0 IF NO)
C    output     : NLA : entry filled
C     comdecks referenced : LUN7COM
C--------------------------------------------------------------------
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      DIMENSION P(4)
      N7LU = N7LU+1
      NLA = N7LU
      K7LU(N7LU,1) = KS
      K7LU(N7LU,2) = KF
      K7LU(N7LU,3) = KM
      K7LU(N7LU,4) = KFD
      K7LU(N7LU,5) = KLD
      DO 10 I=1,4
        P7LU(N7LU,I) = P(I)
 10   CONTINUE
      IF (KF.NE.23) THEN
         P7LU(N7LU,5)=ULMASS(KF)
      ELSE
         P7LU(N7LU,5)=SQRT(ABS(P7LU(N7LU,4)**2-P7LU(N7LU,3)**2-
     $  P7LU(N7LU,2)**2-P7LU(N7LU,1)**2 ))
      ENDIF
      RETURN
      END
      SUBROUTINE KXL7MI (VMAIN,ISTAT,MVX,MTRK)
C ---------------------------------------------------------
C   B. Bloch -Devaux September 1990 from KXLUMI
C! Build the event interface LUND7.4-Aleph  including mixing effects
C - Fill    : PTRAK(ix,n)  = px,py,pz,E( or Mass from Alephlib 9.0) of
C                            track(n)
C                            if E or M=0.it will be filled by the system
C             IPVNU(1,n)   = origin vertex # of track(n)
C                  (2,n)   = decay vertex # of track(n)
C                             0 if no decay
C                  (3,n)   = ALEPH particle #
C             IPCOD(n)     = LUND history code of track(n)
C - Book    : KHIS bank filled with IPCOD(n)
C - CALL    : KFMIBK (VMAIN,PTRAK,IPVNU,MTRK,JSTAT)
C             to book propagate the decay and fill VERT and KINE
C
C - structure: SUBROUTINE subprogram
C              User Entry Name: KXLUMI
C              External Regerences: NAMIND(BOS77)
C                                   ALTABL/ALVERS/KFMIBK(ALEPHLIB)
C                                   KB7MIX (THIS LIB)
C              Comdecks referenced: BCS, LUN7COM, ALCONS, KIPARA ,BMACRO
C                                   KMACRO
C
C - usage   : CALL KXL7MI (VMAIN,ISTAT,MVX,MTRK)
C - Input   : VMAIN = vx,vy,vz,tof of the primary vertex
C - Output  : ISTAT = status word ( = 0 means OK)
C                     - 1 means VERT or KINE bank missing
C                     - 2 means not enough space for VERT or KINE
C                     - 3 means too many tracks
C                     - 4 electrons beams not stored as lines 1 and 2
C                     - 5 means Lund status code larger than 4 found
C                     > 0 means unknown LUND particle# ISTAT
C             MVX   = # of vertices
C             MTRK  = # of tracks to be propagated ( no beam electrons )
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
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
      PARAMETER (LHKIN=3, LPKIN=5, LKVX=2, LHVER=3, LPVER=5, LVKI=50)
      PARAMETER (LGDCA=32)
      PARAMETER (LRPART=200, LCKLIN=1)
      PARAMETER (LRECL=16380, LRUN=1, LEXP=1001, LRTYP=1000)
      CHARACTER*60 LTITL
      PARAMETER (LUCOD=0, LNOTRK=100, LTITL='KINGAL run')
      PARAMETER (LUTRK=350)
      PARAMETER (BFIEL=15., CFIEL=BFIEL*3.E-4)
      PARAMETER ( TLIMI=1.E-15)
      REAL PTRAK(4,LUTRK),VMAIN(4)
      INTEGER IPVNU(3,LUTRK),IPCOD(LUTRK)
      INTEGER ALTABL
      DATA NAPAR/0/
      DATA IFIR/0/
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
C - index of the next vertex/track to be stored in KINE/VERT
C   bank known by its index JVK
      KNEXVK(JVK) = JVK + IW(JVK+1)+IW(JVK+2)+IW(JVK+3)
C - # of vertices/tracks which could be stored in KINE/VERT
C   bank known by its index JVK
      LFRVK(JVK)  = IW(JVK) - (IW(JVK+1)+IW(JVK+2)+IW(JVK+3))
C - index of the 1st parameter of KINE/VERT bank known by its
C   index JVK
      KPARVK(JVK) = JVK + IW(JVK+1)
C - index of 1st vertex/track # contained into the list of
C   bank KINE/VERT known by its index JVK
      KLISVK(JVK) = JVK + IW(JVK+1) + IW(JVK+2)
C - charge of ALEPH particle# JPA
      CHARGE(JPA) = RTABL(IW(NAPAR),JPA,7)
C - mass of ALEPH particle# JPA
      PARMAS(JPA) = RTABL(IW(NAPAR),JPA,6)
C - time of life of ALEPH particle# JPA
      TIMLIF(JPA) = RTABL(IW(NAPAR),JPA,8)
C - # of vertices on a track known by its BOS index JVK /
C   # of outgoing tracks of a vertex known by its BOS index JVK
      NOFVK(JVK)  = IW(JVK+3)
C - Particle type of a track known by its BOS index JVK
      KINTYP(JVK) = IW(KPARVK(JVK)+5)
C - incoming track # of a vertex known by its BOS index JVK
      INPTRK(JVK) = IW(KPARVK(JVK)+5)
C - origin vertex # of a track known by its BOS index JVK
      INPVRT(JVK) = IW(KLISVK(JVK)+1)
C - momentum of a track known by its BOS index JVK
      PMODVK(JVK) = SQRT (RW(KPARVK(JVK)+1)**2 + RW(KPARVK(JVK)+2)**2
     &                   +RW(KPARVK(JVK)+3)**2)
C - energy of a track known by its BOS index JVK
      ENERVK(JVK) = SQRT( PMODVK(JVK)*PMODVK(JVK)+RW(KPARVK(JVK)+4)**2)
C - time of flight of the icoming particle to the vertex known by its
C   BOS index JVK
      TOFLIT(JVK) = RW(KPARVK(JVK)+4)
C - radius of the vertex known by its BOS index
      RADVK(JVK)  = SQRT (RW(KPARVK(JVK)+1)**2 + RW(KPARVK(JVK)+2)**2)
C - mother track # of a track known by its BOS index
      MOTHVK(JVK) = INPTRK (NLINK('VERT',INPVRT(JVK)))
C.......................................................
      IF (NAPAR .EQ. 0) NAPAR = NAMIND ('PART')
      IF (IFIR.EQ.0) THEN
         IFIR = IFIR+1
         CALL ALVERS(ALEFV)
      ENDIF
C
C - Check particle buffer length
      IF (N7LU .GT. LUTRK) THEN
         WRITE (IW(6),'(/1X,''+++KXL7MI+++ not enough space to save''
     &         ,'' the event :# of tracks = '',I2,2X,''allowed = '',I2
     &         /13X,''==>increase LUTRK in *CD KIPARA'')') N7LU,LUTRK
         ISTAT = - 3
         GOTO 999
      ENDIF
C
C - Build array containing vertex # and particle # of each track
C
      IBEA=0
      NVER = 1
      DO 10 ITR=1,N7LU
C Look for "mother" particle
         ILUN  = K7LU(ITR,2)
         IPART = KGPART(ILUN)
         IF (IPART .LE. 0) GOTO 998
         KS = K7LU(ITR,1)
         IF ( KS.EQ.21 .AND. ILUN.EQ.23 ) KS = 11
         IMOTH = K7LU(ITR,3)
C
C Store now momentum components and codes of the track :
          DO 9 I=1,3
 9        PTRAK(I,ITR-IBEA) = P7LU(ITR,I)
          IF (ALEFV.LT.9.0) THEN
             PTRAK(4,ITR-IBEA) = P7LU(ITR,4)
          ELSE
             PTRAK(4,ITR-IBEA) = P7LU(ITR,5)
          ENDIF
          IPVNU(3,ITR-IBEA)=IPART
          IPCOD(ITR-IBEA)=KS*10000+K7LU(ITR,3)
             IF (KS.LE.5) THEN
C            Particle not decayed in LUND
C            if stable particle created in initial state ,IMOTH=0
                 IF (IMOTH-IBEA.LE.0 ) THEN
                   IPVNU(1,ITR-IBEA)=1
                ELSE
                   IPVNU(1,ITR-IBEA)=IPVNU(2,IMOTH-IBEA)
                ENDIF
                IPVNU(2,ITR-IBEA)=0
             ELSE IF ( KS.GE.11 .AND. KS.LE.15 ) THEN
C            Particle has decayed in LUND
                 IF (IMOTH-IBEA.LE.0 ) THEN
C               Primary parton
                   IPVNU(1,ITR-IBEA)=1
                ELSE
                   IPVNU(1,ITR-IBEA)=IPVNU(2,IMOTH-IBEA)
                ENDIF
C               Decay inside LUND and finite lifetime :
C               this track will be propagated in KFMIBK until its decay
                TLIF = TIMLIF (IPART)
C
C In case of mixing  , do not propagate the original B
C
                IF(KB7MIX(ITR).EQ.1)TLIF=0.
                IF (TLIF.GT.TLIMI .AND. MDCY(LUCOMP(ILUN),1).GT.0) THEN
                   NVER=NVER+1
                   IPVNU(2,ITR-IBEA)=NVER
                ELSE
C               Decay is immediate ( will not be propagated)
                   IPVNU(2,ITR-IBEA)=IPVNU(1,ITR-IBEA)
                ENDIF
             ELSE IF (KS.EQ.21) THEN
C            electron beams were stored as well
C            check that they appear only on lines 1 or 2
                ILUN=-4
                IF (ITR.GT.2) GO TO 998
                IST=KBKINE(-ITR,PTRAK(1,ITR-IBEA),IPART,0)
                IF (IST.LE.0) THEN
                   ILUN=-2
                   GO TO 998
                ENDIF
                IBEA=IBEA+1
             ELSE IF (KS.GE.30) THEN
                ILUN=-5
                GO TO 998
             ENDIF
C
C         Update history code
          IF (IMOTH.GT.IBEA) THEN
             IPCOD(ITR-IBEA)=IPCOD(ITR-IBEA)-IBEA
           ELSE
             IPCOD(ITR-IBEA)=IPCOD(ITR-IBEA)-IMOTH
           ENDIF
 10    CONTINUE
C
       NPARL = N7LU-IBEA
C - Fill history bank KHIS
       JKHIS = ALTABL ('KHIS',1,NPARL,IPCOD,'I','E')
C - Propagate decays and fill KINE and VERT banks
       CALL KFMIBK(VMAIN,PTRAK,IPVNU,NPARL,IFAIL)
C
       MVX = NVER
       MTRK = NPARL
       ISTAT = IFAIL
       GOTO 999
C
C - Error
C      unknown LUND particle
 998   ISTAT = ILUN
C
 999   RETURN
       END
      SUBROUTINE LUGENE(IFL,ECM,IDPR)
C------------------------------------------------------------------
C! Generate LUND event, fill some histos   JETSET 7.4 version
C    IFL : FLAVOR CODE TO BE GENERATED
C    ECM : ENERGY C.M. AVAILABLE
C    IDPR: RETURNED PROCESS CODE (1-5)
C     comdecks referenced : LUN7COM
C------------------------------------------------------------------
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      DIMENSION KFL(8)
      DATA NIT/0/
      NIT = NIT +1
      CALL LUEEVT(IFL,ECM)
      IF (NIT.LE.5) CALL LULIST(1)
C
C   Update IDPR
C
        IDPR = 0
C Look for flavor generated
        DO 5 I=1,8
 5      KFL(I)=0
        NFL=0
        DO 40 I=1,N7LU
           ITYP=ABS(KLU(I,9))
           IF (ITYP.GT.8 .OR. ITYP.EQ.0) GO TO 40
           IF ( NFL.GT.0) THEN
              DO 41 J=1,NFL
              IF (ITYP.EQ.KFL(J)) GO TO 40
  41          CONTINUE
           ENDIF
           NFL=NFL+1
           KFL(NFL)=ITYP
           IDPR=10*IDPR+ITYP
  40    CONTINUE
        EE=FLOAT(IDPR)
        CALL HFILL(10006,EE,DUM,1.)
        WEI = 1.
        RETURN
        END
      SUBROUTINE LUIFLV(KFLA,IFLA,IFLB,IFLC,KSP)
C--------------------------------------------------------------------
C
C! Give the quark content of a meson (flavor KFLA) from the higher to
C! the lighter
C
C  AUTHOR :  A. Falvard - B.Bloch-Devaux January 1991
C
C--------------------------------------------------------------------
      KFLA1=IABS(KFLA)
      ISFLA=KFLA/KFLA1
      IFLA=KFLA1/100
      IFLB=-MOD(KFLA1,100)/10
      IFLC=0
      KSP=(MOD(KFLA1,10)-1)/2
C
C  WE STRIP A MESON
C
      IFLA1=IFLA
      IFLA=IFLA*(-1)**IFLA1
      IFLB=IFLB*(-1)**IFLA1
C   Make the light quark flavor compatible with the b decay table
      IF(MOD(ABS(IFLA),2).EQ.1) THEN
       IFLB = -IFLB
       IFLA = -IFLA
      ENDIF
      IFLA=IFLA*ISFLA
      IFLB=IFLB*ISFLA
      IFLC=IFLC*ISFLA
      RETURN
      END
      SUBROUTINE LUJFIL(IM,ID)
C-----------------------------------------------------------
C...Purpose: to convert to JETSET event record contents from
C...the standard event record commonblock.
C     comdecks referenced : LUN7COM , HEPEVT
C-----------------------------------------------------------
      PARAMETER (NMXHEP=2000)
      COMMON/HEPEVT/NEVHEP,NHEP,ISTHEP(NMXHEP),IDHEP(NMXHEP),
     &JMOHEP(2,NMXHEP),JDAHEP(2,NMXHEP),PHEP(5,NMXHEP),VHEP(4,NMXHEP)
      SAVE /HEPEVT/
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
C...Conversion from standard to JETSET, the easy part.
        IF(NHEP.GT.MSTU(4)) CALL LUERRM(8,
     &  '(LUHEPC:) no more space in /LUJETS/')
        NN=NHEP
        DO 180 I=1,NN
        IF ( I.EQ.1 ) THEN
          II = IM+I-1
        ELSE
          II = ID+I-2
        ENDIF
        K7LU(II,1)=0
        IF(ISTHEP(I).EQ.1) K7LU(II,1)=1
        IF(ISTHEP(I).EQ.2) K7LU(II,1)=11
        IF(ISTHEP(I).EQ.3) K7LU(II,1)=21
        IF ( I.GT.1 ) THEN
           K7LU(II,2)=IDHEP(I)
           K7LU(II,3)= IM
           DO 160 J=1,5
  160      P7LU(II,J)=PHEP(J,I)
        ENDIF
        IF ( JDAHEP(1,I).GT.0) THEN
           K7LU(II,4)=JDAHEP(1,I)+ID-2
           K7LU(II,5)=JDAHEP(2,I)+ID-2
        ELSE
           K7LU(II,4)=0
           K7LU(II,5)=0
        ENDIF
  180   CONTINUE
      N7LU = II
      RETURN
      END
      SUBROUTINE LUKFDI(KFL1,KFL2,KFL3,KF)
C...Purpose: to generate a new flavour pair and combine off a hadron.
CBBl for HVFL05 : allow to change PARJ(13:17) according to flavour
C    February 1995
      COMMON/LUDAT1/MSTU(200),PARU(200),MSTJ(200),PARJ(200)
      COMMON/LUDAT2/KCHG(500,3),PMAS(500,4),PARF(2000),VCKM(4,4)
      SAVE /LUDAT1/,/LUDAT2/
      COMMON/PARJCO/P02(5),P13(5),P14(5),P15(5),P16(5),P17(5)
C P02  fraction of s/u for flavor 1...5  from GP02 card
C P13  fraction of V/V+P for flavor 1...5  from GP13 card ( PARJ(11,12))
C P14-16  fraction of Tensor types for flavor 1...5  from GP14-16 card
C P17  fraction of T/T+V for flavor 1...5  from GP17 card
C...Default flavour values. Input consistency checks.
      KF1A=IABS(KFL1)
      KF2A=IABS(KFL2)
      KFL3=0
      KF=0
      IF(KF1A.EQ.0) RETURN
      IF(KF2A.NE.0) THEN
        IF(KF1A.LE.10.AND.KF2A.LE.10.AND.KFL1*KFL2.GT.0) RETURN
        IF(KF1A.GT.10.AND.KF2A.GT.10) RETURN
        IF((KF1A.GT.10.OR.KF2A.GT.10).AND.KFL1*KFL2.LT.0) RETURN
      ENDIF

C...Check if tabulated flavour probabilities are to be used.
      IF(MSTJ(15).EQ.1) THEN
        KTAB1=-1
        IF(KF1A.GE.1.AND.KF1A.LE.6) KTAB1=KF1A
        KFL1A=MOD(KF1A/1000,10)
        KFL1B=MOD(KF1A/100,10)
        KFL1S=MOD(KF1A,10)
        IF(KFL1A.GE.1.AND.KFL1A.LE.4.AND.KFL1B.GE.1.AND.KFL1B.LE.4)
     &  KTAB1=6+KFL1A*(KFL1A-2)+2*KFL1B+(KFL1S-1)/2
        IF(KFL1A.GE.1.AND.KFL1A.LE.4.AND.KFL1A.EQ.KFL1B) KTAB1=KTAB1-1
        IF(KF1A.GE.1.AND.KF1A.LE.6) KFL1A=KF1A
        KTAB2=0
        IF(KF2A.NE.0) THEN
          KTAB2=-1
          IF(KF2A.GE.1.AND.KF2A.LE.6) KTAB2=KF2A
          KFL2A=MOD(KF2A/1000,10)
          KFL2B=MOD(KF2A/100,10)
          KFL2S=MOD(KF2A,10)
          IF(KFL2A.GE.1.AND.KFL2A.LE.4.AND.KFL2B.GE.1.AND.KFL2B.LE.4)
     &    KTAB2=6+KFL2A*(KFL2A-2)+2*KFL2B+(KFL2S-1)/2
          IF(KFL2A.GE.1.AND.KFL2A.LE.4.AND.KFL2A.EQ.KFL2B) KTAB2=KTAB2-1
        ENDIF
        IF(KTAB1.GE.0.AND.KTAB2.GE.0) GOTO 150
      ENDIF

C...Parameters and breaking diquark parameter combinations.
  100 PAR2=PARJ(2)
      PAR3=PARJ(3)
      PAR4=3.*PARJ(4)
      IF(MSTJ(12).GE.2) THEN
        PAR3M=SQRT(PARJ(3))
        PAR4M=1./(3.*SQRT(PARJ(4)))
        PARDM=PARJ(7)/(PARJ(7)+PAR3M*PARJ(6))
        PARS0=PARJ(5)*(2.+(1.+PAR2*PAR3M*PARJ(7))*(1.+PAR4M))
        PARS1=PARJ(7)*PARS0/(2.*PAR3M)+PARJ(5)*(PARJ(6)*(1.+PAR4M)+
     &  PAR2*PAR3M*PARJ(6)*PARJ(7))
        PARS2=PARJ(5)*2.*PARJ(6)*PARJ(7)*(PAR2*PARJ(7)+(1.+PAR4M)/PAR3M)
        PARSM=MAX(PARS0,PARS1,PARS2)
        PAR4=PAR4*(1.+PARSM)/(1.+PARSM/(3.*PAR4M))
      ENDIF

C...Choice of whether to generate meson or baryon.
  110 MBARY=0
      KFDA=0
      IF(KF1A.LE.10) THEN
        IF(KF2A.EQ.0.AND.MSTJ(12).GE.1.AND.(1.+PARJ(1))*RLU(0).GT.1.)
     &  MBARY=1
        IF(KF2A.GT.10) MBARY=2
        IF(KF2A.GT.10.AND.KF2A.LE.10000) KFDA=KF2A
      ELSE
        MBARY=2
        IF(KF1A.LE.10000) KFDA=KF1A
      ENDIF

C...Possibility of process diquark -> meson + new diquark.
      IF(KFDA.NE.0.AND.MSTJ(12).GE.2) THEN
        KFLDA=MOD(KFDA/1000,10)
        KFLDB=MOD(KFDA/100,10)
        KFLDS=MOD(KFDA,10)
        WTDQ=PARS0
        IF(MAX(KFLDA,KFLDB).EQ.3) WTDQ=PARS1
        IF(MIN(KFLDA,KFLDB).EQ.3) WTDQ=PARS2
        IF(KFLDS.EQ.1) WTDQ=WTDQ/(3.*PAR4M)
        IF((1.+WTDQ)*RLU(0).GT.1.) MBARY=-1
        IF(MBARY.EQ.-1.AND.KF2A.NE.0) RETURN
      ENDIF

C...Flavour for meson, possibly with new flavour.
      IF(MBARY.LE.0) THEN
        KFS=ISIGN(1,KFL1)
        IF(MBARY.EQ.0) THEN
          IF(KF2A.EQ.0) KFL3=ISIGN(1+INT((2.+PAR2)*RLU(0)),-KFL1)
          KFLA=MAX(KF1A,KF2A+IABS(KFL3))
          KFLB=MIN(KF1A,KF2A+IABS(KFL3))
          IF(KFLA.NE.KF1A) KFS=-KFS

C...Splitting of diquark into meson plus new diquark.
        ELSE
          KFL1A=MOD(KF1A/1000,10)
          KFL1B=MOD(KF1A/100,10)
  120     KFL1D=KFL1A+INT(RLU(0)+0.5)*(KFL1B-KFL1A)
          KFL1E=KFL1A+KFL1B-KFL1D
          IF((KFL1D.EQ.3.AND.RLU(0).GT.PARDM).OR.(KFL1E.EQ.3.AND.
     &    RLU(0).LT.PARDM)) THEN
            KFL1D=KFL1A+KFL1B-KFL1D
            KFL1E=KFL1A+KFL1B-KFL1E
          ENDIF
          KFL3A=1+INT((2.+PAR2*PAR3M*PARJ(7))*RLU(0))
          IF((KFL1E.NE.KFL3A.AND.RLU(0).GT.(1.+PAR4M)/MAX(2.,1.+PAR4M))
     &    .OR.(KFL1E.EQ.KFL3A.AND.RLU(0).GT.2./MAX(2.,1.+PAR4M)))
     &    GOTO 120
          KFLDS=3
          IF(KFL1E.NE.KFL3A) KFLDS=2*INT(RLU(0)+1./(1.+PAR4M))+1
          KFL3=ISIGN(10000+1000*MAX(KFL1E,KFL3A)+100*MIN(KFL1E,KFL3A)+
     &    KFLDS,-KFL1)
          KFLA=MAX(KFL1D,KFL3A)
          KFLB=MIN(KFL1D,KFL3A)
          IF(KFLA.NE.KFL1D) KFS=-KFS
        ENDIF

C...Form meson, with spin and flavour mixing for diagonal states.
CC HVFL .... set up fractions depending upon flavour
        IF ( KFLA.LE.5 ) THEN
           PARJ13 = PARJ(13)
           PARJ14 = PARJ(14)
           PARJ15 = PARJ(15)
           PARJ16 = PARJ(16)
           PARJ17 = PARJ(17)
           PARJ(13) = P13(KFLA)
           PARJ(14) = P14(KFLA)
           PARJ(15) = P15(KFLA)
           PARJ(16) = P16(KFLA)
           PARJ(17) = P17(KFLA)
        ENDIF
CC HVFL .... END  set up
        IF(KFLA.LE.2) KMUL=INT(PARJ(11)+RLU(0))
        IF(KFLA.EQ.3) KMUL=INT(PARJ(12)+RLU(0))
        IF(KFLA.GE.4) KMUL=INT(PARJ(13)+RLU(0))
        IF(KMUL.EQ.0.AND.PARJ(14).GT.0.) THEN
          IF(RLU(0).LT.PARJ(14)) KMUL=2
        ELSEIF(KMUL.EQ.1.AND.PARJ(15)+PARJ(16)+PARJ(17).GT.0.) THEN
          RMUL=RLU(0)
          IF(RMUL.LT.PARJ(15)) KMUL=3
          IF(KMUL.EQ.1.AND.RMUL.LT.PARJ(15)+PARJ(16)) KMUL=4
          IF(KMUL.EQ.1.AND.RMUL.LT.PARJ(15)+PARJ(16)+PARJ(17)) KMUL=5
        ENDIF
CC HVFL ....restore fractions as originally
        IF ( KFLA.LE.5 ) THEN
           PARJ(13) = PARJ13
           PARJ(14) = PARJ14
           PARJ(15) = PARJ15
           PARJ(16) = PARJ16
           PARJ(17) = PARJ17
        ENDIF
CC HVFL .... END  restore
        KFLS=3
        IF(KMUL.EQ.0.OR.KMUL.EQ.3) KFLS=1
        IF(KMUL.EQ.5) KFLS=5
        IF(KFLA.NE.KFLB) THEN
          KF=(100*KFLA+10*KFLB+KFLS)*KFS*(-1)**KFLA
        ELSE
          RMIX=RLU(0)
          IMIX=2*KFLA+10*KMUL
          IF(KFLA.LE.3) KF=110*(1+INT(RMIX+PARF(IMIX-1))+
     &    INT(RMIX+PARF(IMIX)))+KFLS
          IF(KFLA.GE.4) KF=110*KFLA+KFLS
        ENDIF
        IF(KMUL.EQ.2.OR.KMUL.EQ.3) KF=KF+ISIGN(10000,KF)
        IF(KMUL.EQ.4) KF=KF+ISIGN(20000,KF)

C...Optional extra suppression of eta and eta'.
        IF(KF.EQ.221) THEN
          IF(RLU(0).GT.PARJ(25)) GOTO 110
        ELSEIF(KF.EQ.331) THEN
          IF(RLU(0).GT.PARJ(26)) GOTO 110
        ENDIF

C...Generate diquark flavour.
      ELSE
  130   IF(KF1A.LE.10.AND.KF2A.EQ.0) THEN
          KFLA=KF1A
  140     KFLB=1+INT((2.+PAR2*PAR3)*RLU(0))
          KFLC=1+INT((2.+PAR2*PAR3)*RLU(0))
          KFLDS=1
          IF(KFLB.GE.KFLC) KFLDS=3
          IF(KFLDS.EQ.1.AND.PAR4*RLU(0).GT.1.) GOTO 140
          IF(KFLDS.EQ.3.AND.PAR4.LT.RLU(0)) GOTO 140
          KFL3=ISIGN(1000*MAX(KFLB,KFLC)+100*MIN(KFLB,KFLC)+KFLDS,KFL1)

C...Take diquark flavour from input.
        ELSEIF(KF1A.LE.10) THEN
          KFLA=KF1A
          KFLB=MOD(KF2A/1000,10)
          KFLC=MOD(KF2A/100,10)
          KFLDS=MOD(KF2A,10)

C...Generate (or take from input) quark to go with diquark.
        ELSE
          IF(KF2A.EQ.0) KFL3=ISIGN(1+INT((2.+PAR2)*RLU(0)),KFL1)
          KFLA=KF2A+IABS(KFL3)
          KFLB=MOD(KF1A/1000,10)
          KFLC=MOD(KF1A/100,10)
          KFLDS=MOD(KF1A,10)
        ENDIF

C...SU(6) factors for formation of baryon. Try again if fails.
        KBARY=KFLDS
        IF(KFLDS.EQ.3.AND.KFLB.NE.KFLC) KBARY=5
        IF(KFLA.NE.KFLB.AND.KFLA.NE.KFLC) KBARY=KBARY+1
        WT=PARF(60+KBARY)+PARJ(18)*PARF(70+KBARY)
        IF(MBARY.EQ.1.AND.MSTJ(12).GE.2) THEN
          WTDQ=PARS0
          IF(MAX(KFLB,KFLC).EQ.3) WTDQ=PARS1
          IF(MIN(KFLB,KFLC).EQ.3) WTDQ=PARS2
          IF(KFLDS.EQ.1) WTDQ=WTDQ/(3.*PAR4M)
          IF(KFLDS.EQ.1) WT=WT*(1.+WTDQ)/(1.+PARSM/(3.*PAR4M))
          IF(KFLDS.EQ.3) WT=WT*(1.+WTDQ)/(1.+PARSM)
        ENDIF
        IF(KF2A.EQ.0.AND.WT.LT.RLU(0)) GOTO 130

C...Form baryon. Distinguish Lambda- and Sigmalike baryons.
        KFLD=MAX(KFLA,KFLB,KFLC)
        KFLF=MIN(KFLA,KFLB,KFLC)
        KFLE=KFLA+KFLB+KFLC-KFLD-KFLF
        KFLS=2
        IF((PARF(60+KBARY)+PARJ(18)*PARF(70+KBARY))*RLU(0).GT.
     &  PARF(60+KBARY)) KFLS=4
        KFLL=0
        IF(KFLS.EQ.2.AND.KFLD.GT.KFLE.AND.KFLE.GT.KFLF) THEN
          IF(KFLDS.EQ.1.AND.KFLA.EQ.KFLD) KFLL=1
          IF(KFLDS.EQ.1.AND.KFLA.NE.KFLD) KFLL=INT(0.25+RLU(0))
          IF(KFLDS.EQ.3.AND.KFLA.NE.KFLD) KFLL=INT(0.75+RLU(0))
        ENDIF
        IF(KFLL.EQ.0) KF=ISIGN(1000*KFLD+100*KFLE+10*KFLF+KFLS,KFL1)
        IF(KFLL.EQ.1) KF=ISIGN(1000*KFLD+100*KFLF+10*KFLE+KFLS,KFL1)
      ENDIF
      RETURN

C...Use tabulated probabilities to select new flavour and hadron.
  150 IF(KTAB2.EQ.0.AND.MSTJ(12).LE.0) THEN
        KT3L=1
        KT3U=6
      ELSEIF(KTAB2.EQ.0.AND.KTAB1.GE.7.AND.MSTJ(12).LE.1) THEN
        KT3L=1
        KT3U=6
      ELSEIF(KTAB2.EQ.0) THEN
        KT3L=1
        KT3U=22
      ELSE
        KT3L=KTAB2
        KT3U=KTAB2
      ENDIF
      RFL=0.
      DO 170 KTS=0,2
      DO 160 KT3=KT3L,KT3U
      RFL=RFL+PARF(120+80*KTAB1+25*KTS+KT3)
  160 CONTINUE
  170 CONTINUE
      RFL=RLU(0)*RFL
      DO 190 KTS=0,2
      KTABS=KTS
      DO 180 KT3=KT3L,KT3U
      KTAB3=KT3
      RFL=RFL-PARF(120+80*KTAB1+25*KTS+KT3)
      IF(RFL.LE.0.) GOTO 200
  180 CONTINUE
  190 CONTINUE
  200 CONTINUE

C...Reconstruct flavour of produced quark/diquark.
      IF(KTAB3.LE.6) THEN
        KFL3A=KTAB3
        KFL3B=0
        KFL3=ISIGN(KFL3A,KFL1*(2*KTAB1-13))
      ELSE
        KFL3A=1
        IF(KTAB3.GE.8) KFL3A=2
        IF(KTAB3.GE.11) KFL3A=3
        IF(KTAB3.GE.16) KFL3A=4
        KFL3B=(KTAB3-6-KFL3A*(KFL3A-2))/2
        KFL3=1000*KFL3A+100*KFL3B+1
        IF(KFL3A.EQ.KFL3B.OR.KTAB3.NE.6+KFL3A*(KFL3A-2)+2*KFL3B) KFL3=
     &  KFL3+2
        KFL3=ISIGN(KFL3,KFL1*(13-2*KTAB1))
      ENDIF

C...Reconstruct meson code.
      IF(KFL3A.EQ.KFL1A.AND.KFL3B.EQ.KFL1B.AND.(KFL3A.LE.3.OR.
     &KFL3B.NE.0)) THEN
        RFL=RLU(0)*(PARF(143+80*KTAB1+25*KTABS)+PARF(144+80*KTAB1+
     &  25*KTABS)+PARF(145+80*KTAB1+25*KTABS))
        KF=110+2*KTABS+1
        IF(RFL.GT.PARF(143+80*KTAB1+25*KTABS)) KF=220+2*KTABS+1
        IF(RFL.GT.PARF(143+80*KTAB1+25*KTABS)+PARF(144+80*KTAB1+
     &  25*KTABS)) KF=330+2*KTABS+1
      ELSEIF(KTAB1.LE.6.AND.KTAB3.LE.6) THEN
        KFLA=MAX(KTAB1,KTAB3)
        KFLB=MIN(KTAB1,KTAB3)
        KFS=ISIGN(1,KFL1)
        IF(KFLA.NE.KF1A) KFS=-KFS
        KF=(100*KFLA+10*KFLB+2*KTABS+1)*KFS*(-1)**KFLA
      ELSEIF(KTAB1.GE.7.AND.KTAB3.GE.7) THEN
        KFS=ISIGN(1,KFL1)
        IF(KFL1A.EQ.KFL3A) THEN
          KFLA=MAX(KFL1B,KFL3B)
          KFLB=MIN(KFL1B,KFL3B)
          IF(KFLA.NE.KFL1B) KFS=-KFS
        ELSEIF(KFL1A.EQ.KFL3B) THEN
          KFLA=KFL3A
          KFLB=KFL1B
          KFS=-KFS
        ELSEIF(KFL1B.EQ.KFL3A) THEN
          KFLA=KFL1A
          KFLB=KFL3B
        ELSEIF(KFL1B.EQ.KFL3B) THEN
          KFLA=MAX(KFL1A,KFL3A)
          KFLB=MIN(KFL1A,KFL3A)
          IF(KFLA.NE.KFL1A) KFS=-KFS
        ELSE
          CALL LUERRM(2,'(LUKFDI:) no matching flavours for qq -> qq')
          GOTO 100
        ENDIF
        KF=(100*KFLA+10*KFLB+2*KTABS+1)*KFS*(-1)**KFLA

C...Reconstruct baryon code.
      ELSE
        IF(KTAB1.GE.7) THEN
          KFLA=KFL3A
          KFLB=KFL1A
          KFLC=KFL1B
        ELSE
          KFLA=KFL1A
          KFLB=KFL3A
          KFLC=KFL3B
        ENDIF
        KFLD=MAX(KFLA,KFLB,KFLC)
        KFLF=MIN(KFLA,KFLB,KFLC)
        KFLE=KFLA+KFLB+KFLC-KFLD-KFLF
        IF(KTABS.EQ.0) KF=ISIGN(1000*KFLD+100*KFLF+10*KFLE+2,KFL1)
        IF(KTABS.GE.1) KF=ISIGN(1000*KFLD+100*KFLE+10*KFLF+2*KTABS,KFL1)
      ENDIF

C...Check that constructed flavour code is an allowed one.
      IF(KFL2.NE.0) KFL3=0
      KC=LUCOMP(KF)
      IF(KC.EQ.0) THEN
        CALL LUERRM(2,'(LUKFDI:) user-defined flavour probabilities '//
     &  'failed')
        GOTO 100
      ENDIF

      RETURN
      END
      SUBROUTINE LULAMB
C----------------------------------------------------------------------
C     B.Bloch   : November 1993 inspired by code from Sjostrand
C! Apply sipin effects and/or form factor effect to semi leptonic
C! decays of B Baryons into Lambdac lepton neutrino
C     Comdecks referenced: BCS, LUN7COM, ALCONS ,BCODES ,DCODES ,LCODES
C                          MASTER ,POLAMB
C----------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
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
      PARAMETER (NBU=521,NBD=511,NBS=531,NBC=541)
      PARAMETER (NLB=5122,NXB= 5132)
      PARAMETER (NXB0=5232,NOB= 5332)
C     NBU    = internal JETSET 7.4 code for Bu meson
C     NBD    = internal JETSET 7.4 code for Bd meson
C     NBS    = internal JETSET 7.4 code for Bs meson
C     NBC    = internal JETSET 7.4 code for Bc meson
C     NLB    = internal JETSET 7.4 code for /\B BARYON
C     NXB    = internal JETSET 7.4 code for XIB BARYON
C     NXB0   = internal JETSET 7.4 code for XIB0 BARYON
C     NOB    = internal JETSET 7.4 code for OMEGAB BARYON
      PARAMETER (NDU=421,NDD=411,NDS=431)
      PARAMETER (NLC=4122,NXC= 4132)
C     NDU    = internal JETSET 7.3 code for Du meson
C     NDD    = internal JETSET 7.3 code for Dd meson
C     NDS    = internal JETSET 7.3 code for Ds meson
C     NLC    = internal JETSET 7.3 code for /\C BARYON
C     NXC    = internal JETSET 7.3 code for XIC BARYON
      PARAMETER (NNUEL=12,NNUMU=14,NNUTO=16,NEL=11,NMU=13,NTO=15)
C     NNUEL  = internal JETSET 7.4 code for neutrino electron
C     NNUMU  = internal JETSET 7.4 code for neutrino mu
C     NNUTO  = internal JETSET 7.4 code for neutrino tau
C     NEL    = internal JETSET 7.4 code for electron
C     NMU    = internal JETSET 7.4 code for muon
C     NTO    = internal JETSET 7.4 code for tau
      COMMON / MASTER / IGENE,IWEIT,IMIX,IVBU,IFL,IEV1,IEV2,ISEM,IDEC,
     $   IPHO,ILAM,IPRJ,IDDC,IBDK,ICDK,ITDK,ECM,WTMAX,SVRT(3),ICOULU(10)
      COMMON/POLAMB/ISPINL,IFORML,W0LAMB
C ISPINL : Switch on/off spin effects in semileptonic B_Baryons decays
C IFORML : Switch on/off form factor  in semileptonic B_Baryons decays
C W0LAMB : form factor value if used
      PARAMETER (NBRMX=20)
      DIMENSION MDMSTO(NBRMX)
      SAVE MDMSTO
C...Loop over event to find all Lambda_b.
      NLAMB=0
      IDCK =0
      DO 130 I=1,N7LU
         KF=ABS(K7LU(I,2))
C  We have b baryon /\b,Xb or Omegab
         IF ((KF.EQ.NLB).OR.(KF.EQ.NXB).OR.(KF.EQ.NXB0).OR.(KF.EQ.NOB))
     $    THEN
C... Allow the decay
         KC = LUCOMP(KF)
         MDCY(KC,1) = 1
C...Store orginal possible decay schemes
         If( kf.eq.nlb) then
            NMBR = MDCY(kc,3)
            ikc = kc
         else
            NMBR = MDCY(85,3)
            ikc = 85
         endif
         IF (NMBR.GT.NBRMX)THEN
            WRITE(6,'('' YOU SHOULD ENLARGE NBRMX IN LULAMB TO '',I10)')
     $      NMBR
            CALL EXIT
         ENDIF
         DO 22 II= 1,NMBR
           MDMSTO(II) = MDME(MDCY(ikc,2)+II-1,1)
   22    CONTINUE
         XLB=2.*P7LU(I,4)/ECM
C...Rotate Lambda_b to sit along z axis and then boost back to rest.
         PHILB=ULANGL(P7LU(I,1),P7LU(I,2))
         CALL LUDBRB(I,I,0.,-PHILB,0D0,0D0,0D0)
         THELB=ULANGL(P7LU(I,3),P7LU(I,1))
         CALL LUDBRB(I,I,-THELB,0.,0D0,0D0,0D0)
         BEZLB=P7LU(I,3)/P7LU(I,4)
         CALL LUDBRB(I,I,0.,0.,0D0,0D0,-DBLE(BEZLB))
C...Select z component of b spin in its rest frame.
       IF(ISPINL.EQ.1) THEN
C...Construct propagators.
          SFF=1./(16.*PARU(102)*(1.-PARU(102)))
          SFW=ECM**4/((ECM**2-PARJ(123)**2)**2+(PARJ(123)*PARJ(124))**2)
          SFI=SFW*(1.-(PARJ(123)/ECM)**2)
          QE=-1.
          AE=-1.
          VE=-1.+4.*PARU(102)
          QF=-1./3.
          AF=-1.
          VF=-1.+(4./3.)*PARU(102)
          F0=QE**2*QF**2+2.*QE*VE*QF*VF*SFI*SFF+
     &   (VE**2+AE**2)*(VF**2+AF**2)*SFW*SFF**2
          F1=2.*QE*AE*QF*AF*SFI*SFF+4.*VE*AE*VF*AF*SFW*SFF**2
          F2=2.*QE*VE*QF*AF*SFI*SFF+2.*(VE**2+AE**2)*VF*AF*SFW*SFF**2
          F3=2.*QE*AE*QF*VF*SFI*SFF+2.*VE*AE*(VF**2+AF**2)*SFW*SFF**2
C...Pick s_z = +-1 according to relative probabilities.
          CTHE=COS(THELB)
          FUNPOL=(1.+CTHE**2)*F0+2.*CTHE*F1
          FPOL=(1.+CTHE**2)*F2+2.*CTHE*F3
          SPINZB=1.
          IF(FUNPOL-FPOL.GT.2.*FUNPOL*RLU(0)) SPINZB=-1.
       ENDIF
C...Do decay and set initial weight of decay.
       NSAV=N7LU
       ISDEC = 0
  110  CALL LUDECY(I)
C      KS=K7LU(I,1)
       IF ( ISDEC.EQ.0) THEN
C  Decay is a SEMI lep decay ?
         JF=K7LU(I,4)
         JL=K7LU(I,5)
C  Semileptonic e,mu,tau  only with neutrino , lepton AND c baryon
         NLEPN = 0
         NLEPC = 0
         DO 2 JJ = JF,JL
           KFJJ = ABS(K7LU(JJ,2))
           IF( KFJJ.EQ.NNUEL .OR. KFJJ.EQ.NNUMU .OR. KFJJ.EQ.NNUTO)
     $     NLEPN = NLEPN+KFJJ-10
           IF( KFJJ.EQ.NEL .OR. KFJJ.EQ.NMU .OR. KFJJ.EQ.NTO)
     $     NLEPC = NLEPC+KFJJ-10
  2      CONTINUE
         NLAMB=NLAMB+1
         IF (NLEPN*NLEPC.EQ.0) GO TO 140
         IDCK = NLEPN/2
         ILAMB=I
         IDLAMB=NSAV+1
         ISGNLB=ISIGN(1,K7LU(I,2))
       ENDIF
       WTLB=1.
C...Construct spin-dependent weight.
       IF(ISPINL.EQ.1) THEN
          WTSPIN=0.5*(1.-SPINZB*P7LU(NSAV+1,3)/P7LU(NSAV+1,4))
          WTLB=WTLB*WTSPIN
       ENDIF
C...Construct form factor weight.
       IF(IFORML.EQ.1) THEN
         W=P7LU(NSAV+3,4)/P7LU(NSAV+3,5)
         WTFORM=W0LAMB**2/(W0LAMB**2-2.+2.*W)
         WTLB=WTLB*WTFORM**2
       ENDIF
C...Reject kinematics according to total weight, go back for new.
       IF(WTLB.LT.RLU(0)) THEN
          K7LU(I,1)=1
          N7LU=NSAV
          ISDEC = ISDEC + 1
C... Set up decay mode as the only one
          DO 23 II= 1,NMBR
              MDME(MDCY(ikc,2)+II-1,1)= 0
   23     CONTINUE
          MDME(MDCY(ikc,2)+IDCK-1,1)= 1
          GOTO 110
       ENDIF
C...Boost and rotate back Lambda_b and its products.
 140   CALL LUDBRB(I,I,0.,0.,0D0,0D0,DBLE(BEZLB))
       CALL LUDBRB(NSAV+1,N7LU,0.,0.,0D0,0D0,DBLE(BEZLB))
       CALL LUDBRB(I,I,THELB,PHILB,0D0,0D0,0D0)
       CALL LUDBRB(NSAV+1,N7LU,THELB,PHILB,0D0,0D0,0D0)
C... Restore full list of decays
       DO 24 II= 1,NMBR
           MDME(MDCY(ikc,2)+II-1,1)=MDMSTO(II)
   24  CONTINUE
C...histogram E lepton if semi lep
      IF ( IDCK.GT.0) THEN
        ELEPT=P7LU(IDLAMB+1,4)
        CALL HF1(10030+IDCK,ELEPT,1.)
      ENDIF
C...End loop over Lambda_b;
      ENDIF
  130 CONTINUE
      IF(NLAMB.GE.1) CALL LUEXEC
 111  CONTINUE
 999  RETURN
      END
      SUBROUTINE LUNDDC(IDDC)
C------------------------------------------------------------------
C! Performs Particle decay with selected decay modes if it is the
C! right decay chain
C  B.Bloch-Devaux March  1994
C    IDDC : SELECTED DECAYFLAG 0 NO SELECTED DECAY DONE
C                              1 SELECTED DECAY FOR FIRST chain
C     comdecks referenced : LUN7COM , BCS ,CHAINS
C------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      COMMON /CHAINS/ KFDAU,KFMOTH,KFCOMP(2)
C   KFDAU  = internal JETSET 7.4 code for daughter decayed particle
C   KFMOTH = internal JETSET 7.4 code for mother of decayed particle
C   KFCOMP(2)internal JETSET 7.4 code for companions of decayed particle
      IDDC = 0
      KC = LUCOMP(KFDAU)
      NDEC=MDCY(KC,3)
      IDC=MDCY(KC,2)
      DO 100 I=1,N7LU
         KFB = ABS(K7LU(I,2))
C Look for daughter KFDAU
         IF (KFB.EQ.KFDAU) THEN
C Look for mother   KFMOTH
            KFM = K7LU(I,3)
            IF ( ABS(K7LU(KFM,2)).EQ.KFMOTH) THEN
C Look for daughter companions KFCOMP
              IOK = 1
              DO 101 J = 1,2
                 KFC = KFCOMP(J)
                 IF ( KFC.GT.0) THEN
                    DO 102 KK = K7LU(KFM,4),K7LU(KFM,5)
                       IF ( ABS(K7LU(KK,2)).EQ.KFC ) GO TO 103
 102                CONTINUE
                 ENDIF
 101          CONTINUE
              IF ( KFCOMP(1)+KFCOMP(2).EQ.0) GO TO 103
              IOK = 0
 103          CONTINUE
C  set up the requested decay modes for the daughter and perform decay
              IF ( IOK.GT.0) THEN
                 JDEC=IW(NAMIND('GDDC'))
                 IF(JDEC.GT.0) THEN
                    CALL UCOPY (IW(JDEC+5),MDME(IDC,1),NDEC)
                    IDDC = IDDC + 1
                 ENDIF
                 CALL LUDECY(I)
                 CALL UFILL (MDME(IDC,1),1,NDEC,1)
                 GO TO 500
                 ENDIF
            ENDIF
         ENDIF
C
 100  CONTINUE
 500  CALL HFILL(10040,FLOAT(IDDC),DUM,1.)
      RETURN
      END
      SUBROUTINE LUNDEC(IFDC)
C------------------------------------------------------------------
C! Performs B meson decay one at a time with selected decay modes
C  B.Bloch-Devaux February 1991
C  Modified September 1994 to symetrize first/second meson selection.
C  any meson of higher rank will use the full decay scheme
C    IFDC : SELECTED DECAYFLAG 0 NO SELECTED DECAY DONE
C                              1 SELECTED DECAY FOR FIRST B MESON
C                              2 SELECTED DECAY FOR SECOND B MESON
C                              3 SELECTED DECAY FOR BOTH B MESONS
C     comdecks referenced : LUN7COM , BCS ,BCODES
C------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
       LOGICAL BMES,BMESS,BMEST
      PARAMETER (NBU=521,NBD=511,NBS=531,NBC=541)
      PARAMETER (NLB=5122,NXB= 5132)
      PARAMETER (NXB0=5232,NOB= 5332)
C     NBU    = internal JETSET 7.4 code for Bu meson
C     NBD    = internal JETSET 7.4 code for Bd meson
C     NBS    = internal JETSET 7.4 code for Bs meson
C     NBC    = internal JETSET 7.4 code for Bc meson
C     NLB    = internal JETSET 7.4 code for /\B BARYON
C     NXB    = internal JETSET 7.4 code for XIB BARYON
C     NXB0   = internal JETSET 7.4 code for XIB0 BARYON
C     NOB    = internal JETSET 7.4 code for OMEGAB BARYON
      PARAMETER ( LSTR = 92)
      IFDC = 0
      KC = LUCOMP(LBPOS)
      IF ( KC.LE.0) GO TO 99
      NDEC=MDCY(KC,3)
      IDC=MDCY(KC,2)
      IMES =0
      IBD =0
      IBU =0
      IBS =0
      IBC =0
      IBU1 =0
      IBD1 =0
      IMMOD = INT( RNDM(DUM)+1.5)
      DO 100 I=1,N7LU
         KFB = ABS(K7LU(I,2))
C Look for string and its daughters
         IF (KFB.EQ.LSTR) THEN
            DO 101 J= K7LU(I,4),K7LU(I,5)
              KFA = ABS(K7LU(J,2))
              BMES =(KFA.EQ.NBD).OR.(KFA.EQ.NBS).OR.( KFA.EQ.NBU).OR.
     $        (KFA.EQ.NBC)
              BMESS=(KFA.EQ.NBD+2).OR.(KFA.EQ.NBS+2).OR.
     $        ( KFA.EQ.NBU+2).OR.(KFA.EQ.NBC+2).OR.BMES
              BMEST=(KFA.EQ.NBD+4).OR.(KFA.EQ.NBU+4).OR.(KFA.EQ.NBS+4)
     $        .OR.(KFA.EQ.NBC+4).OR.BMESS
C  Look for undecayed B mesons
              IF (BMEST) THEN
C
C  SET UP THE REQUESTED DECAY MODES FOR THE SUCCESSIVE B MESONS
C  AND PERFORM DECAY OF B IF UNDECAYED ( OR ITS DAUGHTER IF DECAYED :
C  THAT IS WHEN IT IS A B0 WHICH IS COPIED FOR MIXING AND/OR A B*)
C
                 JP = J
                 IF(K7LU(J,1).GT.10) THEN
                    IMOTH = J
    5               JP = K7LU(IMOTH,4)
                    IF ( K7LU(JP,1).GT.10) THEN
                      IMOTH = JP
                      GO TO 5
                    ENDIF
                 ENDIF
                 KFF = ABS(K7LU(JP,2))
                 IMES = IMES +1
                 IMMOD = IMMOD+1
                 IF (KFF.EQ.NBD) IBD = IBD +1
                 IF (KFF.EQ.NBU) IBU = IBU +1
                 IF (KFF.EQ.NBS) IBS = IBS +1
                 IF (KFF.EQ.NBC) IBC = IBC +1
                 IF ((MOD(IMMOD,2).EQ.0).AND.(IMES.LE.2)) THEN
                   JDEC=IW(NAMIND('GDC1'))
                   IF(JDEC.GT.0) THEN
                      CALL UCOPY (IW(JDEC+1),MDME(IDC,1),NDEC)
                      IFDC = IFDC + 1
                   ENDIF
                   CALL LUDECY(JP)
                   CALL UFILL (MDME(IDC,1),1,NDEC,1)
                   IF ( KFF.EQ.NBD) IBD1 = IBD1+1
                   IF ( KFF.EQ.NBU) IBU1 = IBU1+1
                   IF ((MOD(IMMOD,2).EQ.1).AND.(IMES.LE.2)) THEN
                     JDEC=IW(NAMIND('GDC2'))
                     IF(JDEC.GT.0) THEN
                        CALL UCOPY (IW(JDEC+1),MDME(IDC,1),NDEC)
                        IFDC = IFDC + 2
                     ENDIF
                     CALL LUDECY(JP)
                     CALL UFILL (MDME(IDC,1),1,NDEC,1)
                   ENDIF
                ENDIF
             ELSE
               CALL LUDECY(JP)
             ENDIF
C
 101        CONTINUE
         ENDIF
C
 100  CONTINUE
      X = FLOAT(IMES)
      IF (IMES.GT.2) CALL LULIST(1)
      CALL HFILL(10009,X,DUM,1.)
      X = FLOAT(IBD)
      Y = FLOAT(IBU)
      CALL HFILL(10019,X,Y,1.)
      X = FLOAT(IBS)
      CALL HFILL(10039,X,DUM,1.)
      X = FLOAT(IBC)
      CALL HFILL(10049,X,DUM,1.)
      X = FLOAT(IBD1)
      Y = FLOAT(IBU1)
      CALL HFILL(10059,X,Y,1.)
 99   RETURN
      END
      SUBROUTINE LUNMIX(IFMI)
C------------------------------------------------------------------
C!   Performs B Bbar mixing
C  Include  INTEGRAL B MIXING (24/10/88)
C    IFMI : MIXING FLAG  0 NO MIXING DONE , 1 MIXING ON INITIAL B
C                        2 MIXING ON INITIAL BBAR, 3 MIXING ON BOTH
C     comdecks referenced : LUN7COM , BCODES ,MIXING ,USERCP
C------------------------------------------------------------------
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      COMPLEX PSQD,PSQS
      COMMON/ MIXING /XD,YD,CHID,RD,XS,YS,CHIS,RS,PSQD,PSQS
      COMMON/ PROBMI /CDCPBA,CDCPB,CSCPBA,CSCPB
      PARAMETER (LNBRCP=4)
      COMMON/USERCP/NPARCP,JCODCP(LNBRCP),RHOCPM
      COMPLEX RHOCPM
      PARAMETER (NBU=521,NBD=511,NBS=531,NBC=541)
      PARAMETER (NLB=5122,NXB= 5132)
      PARAMETER (NXB0=5232,NOB= 5332)
C     NBU    = internal JETSET 7.4 code for Bu meson
C     NBD    = internal JETSET 7.4 code for Bd meson
C     NBS    = internal JETSET 7.4 code for Bs meson
C     NBC    = internal JETSET 7.4 code for Bc meson
C     NLB    = internal JETSET 7.4 code for /\B BARYON
C     NXB    = internal JETSET 7.4 code for XIB BARYON
C     NXB0   = internal JETSET 7.4 code for XIB0 BARYON
C     NOB    = internal JETSET 7.4 code for OMEGAB BARYON
      IFMI = 0
      NPAR=N7LU
      DO 100 I=1,NPAR
      IF(ABS(K7LU(I,2)).EQ.NBD.OR.ABS(K7LU(I,2)).EQ.NBS)THEN
C
C  ADD A NEW B MESON RESULTING FROM MIXING WITH SAME
C  KINEMATICAL PARAMETERS THAN THE ORIGINAL B AND APPROPRIATE LUND CODE
C
         K7LU(I,1)=K7LU(I,1)+10
         K7LU(I,4)=N7LU+1
         K7LU(I,5)=N7LU+1
         N7LU=N7LU+1
         K7LU(N7LU,1)=1
         K7LU(N7LU,3)=I
         K7LU(N7LU,4)=0
         K7LU(N7LU,5)=0
         DO 101 J=1,5
          P7LU(N7LU,J)=P7LU(I,J)
          V7LU(N7LU,J)=V7LU(I,J)
 101     CONTINUE
C
C  ISIGN=1 : NO B OSCILLATION   ;   ISIGN=-1  : B OSCILLATION
C
         ISIGN=1
         IF(K7LU(I,2).EQ.NBD.AND.RNDM(DUM).LT.CDCPB)THEN
           ISIGN=-1
           IFMI = IFMI +1
         ELSEIF (K7LU(I,2).EQ.-NBD.AND.RNDM(DUM).LT.CDCPBA)THEN
           ISIGN =-1
           IFMI = IFMI +2
         ELSEIF(K7LU(I,2).EQ.NBS.AND.RNDM(DUM).LT.CSCPB)THEN
           ISIGN=-1
           IFMI = IFMI +1
         ELSEIF(K7LU(I,2).EQ.-NBS.AND.RNDM(DUM).LT.CSCPBA)THEN
           ISIGN=-1
           IFMI = IFMI +2
         ENDIF
         K7LU(N7LU,2)=ISIGN*K7LU(I,2)
       ENDIF
 100  CONTINUE
      RETURN
      END
      SUBROUTINE LUNPHO(JFLA)
C----------------------------------------------------------------------
C     B.Bloch & D.Colling : June   1992 for use of PHOTOS to generate
C                         internal brem in B and D meson semi-lep decays
C! Steering for radiative Semileptonic decays of Heavy Mesons (B and D )
C    Input :
C    JFLA = heavy flavor to be considered   4 = D MESONS  5= B MESONS
C                                          14 = D Baryon 15= B Baryon
C                                          44 = Psi and Psi' leptonic
C    JFLA <0 only particle #-JFLA must be considered ( B meson)
C    Comdecks referenced: BCS, LUN7COM, ALCONS ,BCODES ,PSCODES,DCODES
C                         LCODES ,MASTER
C----------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      COMMON / MASTER / IGENE,IWEIT,IMIX,IVBU,IFL,IEV1,IEV2,ISEM,IDEC,
     $   IPHO,ILAM,IPRJ,IDDC,IBDK,ICDK,ITDK,ECM,WTMAX,SVRT(3),ICOULU(10)
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
      PARAMETER (NDU=421,NDD=411,NDS=431)
      PARAMETER (NLC=4122,NXC= 4132)
C     NDU    = internal JETSET 7.3 code for Du meson
C     NDD    = internal JETSET 7.3 code for Dd meson
C     NDS    = internal JETSET 7.3 code for Ds meson
C     NLC    = internal JETSET 7.3 code for /\C BARYON
C     NXC    = internal JETSET 7.3 code for XIC BARYON
      PARAMETER (NNUEL=12,NNUMU=14,NNUTO=16,NEL=11,NMU=13,NTO=15)
C     NNUEL  = internal JETSET 7.4 code for neutrino electron
C     NNUMU  = internal JETSET 7.4 code for neutrino mu
C     NNUTO  = internal JETSET 7.4 code for neutrino tau
C     NEL    = internal JETSET 7.4 code for electron
C     NMU    = internal JETSET 7.4 code for muon
C     NTO    = internal JETSET 7.4 code for tau
      PARAMETER (ICOPSI=443,ICOPSIP=30443)
C    LUND 7.4 codes Psi   and Psi'
      PARAMETER (NBU=521,NBD=511,NBS=531,NBC=541)
      PARAMETER (NLB=5122,NXB= 5132)
      PARAMETER (NXB0=5232,NOB= 5332)
C     NBU    = internal JETSET 7.4 code for Bu meson
C     NBD    = internal JETSET 7.4 code for Bd meson
C     NBS    = internal JETSET 7.4 code for Bs meson
C     NBC    = internal JETSET 7.4 code for Bc meson
C     NLB    = internal JETSET 7.4 code for /\B BARYON
C     NXB    = internal JETSET 7.4 code for XIB BARYON
C     NXB0   = internal JETSET 7.4 code for XIB0 BARYON
C     NOB    = internal JETSET 7.4 code for OMEGAB BARYON
      DATA  IFIR / 0/
      IF ( IFIR.EQ.0) THEN
          IMES = MOD(IPHO,10)
          IBAR = MOD(IPHO/10,10)
          IPSI = MOD(IPHO/100,10)
      ENDIF
      IF ( JFLA.GT.0) THEN
         IFLA = JFLA
         I0 = 0
      ELSE IF ( JFLA.LT.0) THEN
         IFLA = 5
         I0 = -JFLA-1
      ELSE
         GO TO 999
      ENDIF
      IF ( IFLA.EQ.4) THEN
         NFIR = NDD
         NSEC = NFIR
         INC = 10
         IF ( IAND(IMES,1).EQ.0) GO TO 999
      ELSE IF ( IFLA.EQ.5) THEN
         NFIR = NBD
         NSEC = NBU
         INC = 10
         IF ( IAND(IMES,2).EQ.0) GO TO 999
      ELSE IF ( IFLA.EQ.14) THEN
         NFIR = NLC
         NSEC = NXC
         INC = 100
         IF ( IAND(IBAR,1).EQ.0) GO TO 999
      ELSE IF ( IFLA.EQ.15) THEN
         NFIR = NLB
         NSEC = NXB
         INC = 100
         IF ( IAND(IBAR,2).EQ.0) GO TO 999
      ELSE IF ( IFLA.EQ.44) THEN
         NFIR = ICOPSI
         NSEC = ICOPSIP
         INC = 0
         IF(IPSI.LE.0) GO TO 999
      ELSE IF ( IFLA.EQ.55) THEN
         NFIR = NTO
         NSEC = NFIR
         INC =  0
      ELSE
         GO TO 999
      ENDIF
      I = I0
1     I = I+1
         IF (JFLA.LT.0 .AND. I.GT.-JFLA) GO TO 111
         IF ( I.GT.N7LU ) GO TO 111
         KF=ABS(K7LU(I,2))
C  We have a Bd,Bu Bs or Bc,D0,D+- or Ds,/\b type,/\c type..,Psi('),tau
         IF ((KF.EQ.NFIR).OR.(KF.EQ.NSEC).OR.(KF.EQ.NSEC+INC).OR.
     $    (KF.EQ.NSEC+2*INC)) THEN
            KS=K7LU(I,1)
C  It is a decayed particle
            IF(KS.LT.10) GO TO 1
C  decay is a semi lep decay or a tau decay
            JF=K7LU(I,4)
            JL=K7LU(I,5)
C  Semileptonic e,mu only with neutrino  and lepton or pure leptonic
            NLEPN = 0
            NLEPC = 0
            DO 2 JJ = JF,JL
              KFJJ = ABS(K7LU(JJ,2))
              IF( KFJJ.EQ.NNUEL .OR. KFJJ.EQ.NNUMU) NLEPN = NLEPN + 1
              IF( KFJJ.EQ.NEL .OR. KFJJ.EQ.NMU) NLEPC =NLEPC +1
  2        CONTINUE
           IF((NLEPN+NLEPC.NE.2).AND.(KF.NE.NTO))  GO TO 1
C  Transfer the decay to HEPEVT common
           CALL HEPFIL(I,JF,JL)
C        CALL HEPLIS(1)
C  CALL PHOTOS for mother particle
         CALL PHOCAL(IMOD)
C        CALL HEPLIS(1)
C   IF no extra photon added nothing to do
         IF ( IMOD.EQ.0) GO TO 1
C
C  KILL THE DECAY PRODUCTS OF B/D
C
         NPARI=N7LU
         IGARB0 = I
         K7LU(IGARB0,1) = KS -10
         K7LU(IGARB0,4)=0
         K7LU(IGARB0,5)=0
C  Identify in the remaining list the successive daughters
         DO 6 IGARB= I+1,NPARI
           IGARB1=IGARB
 7         IGARB1=K7LU(IGARB1,3)
           IF(IGARB1.EQ.IGARB0.OR.IGARB1.EQ.1000)THEN
              K7LU(IGARB,3)=1000
              K7LU(IGARB,4)=0
              K7LU(IGARB,5)=0
              GOTO 6
           ENDIF
           IF(IGARB1.LT.IGARB0)THEN
              GOTO 6
           ELSE
              GOTO 7
           ENDIF
 6       CONTINUE
C   Compress the remaining entries
         N7LU=JF-1
         IMOT0 = -1
         DO 8 IGARB= JF ,NPARI
            IF(K7LU(IGARB,3).EQ.1000)GOTO 8
            N7LU=N7LU+1
            K7LU(N7LU,1)=K7LU(IGARB,1)
            K7LU(N7LU,2)=K7LU(IGARB,2)
            K7LU(N7LU,3)=K7LU(IGARB,3)
            K7LU(N7LU,4)=K7LU(IGARB,4)
            K7LU(N7LU,5)=K7LU(IGARB,5)
            DO 9 IGARB2=1,5
              P7LU(N7LU,IGARB2)=P7LU(IGARB,IGARB2)
 9          CONTINUE
C   Update current daughter number for the mother
            IMOTH = K7LU(N7LU,3)
            IF (IMOTH.EQ.IMOT0) GOTO 10
              IMOT0 = IMOTH
              K7LU(IMOTH,4) = K7LU(IMOTH,4)+N7LU-IGARB
              K7LU(IMOTH,5) = K7LU(IMOTH,5)+N7LU-IGARB
 10         CONTINUE
C   Update current mother number for the daughters
            IF (K7LU(IGARB,5).LE.0) GOTO 8
            DO 11 IGARB2= K7LU(IGARB,4),K7LU(IGARB,5)
               K7LU(IGARB2,3)=N7LU
 11         CONTINUE
 8       CONTINUE
C  WE HAVE NOW A LIST WITH B/D MOTHER IN I AND DAUGHTERS CAN BE FILLED
C FROM POSITION N7LU+1
         CALL LUJFIL(I,N7LU+1)
         IF (IFLA.EQ.4 ) IDD = 10050
         IF (IFLA.EQ.14) IDD = 10051
         IF (IFLA.EQ.5 ) IDD = 10052
         IF (IFLA.EQ.15) IDD = 10053
         IF((IFLA.EQ.44).AND.(KF.EQ.ICOPSI))  IDD = 10054
         IF((IFLA.EQ.44).AND.(KF.EQ.ICOPSIP))  IDD = 10055
         IF (IFLA.EQ.55) IDD = 10056
         CALL HFILL(IDD,P7LU(N7LU,4),DUM,1.)
        ENDIF
      GO TO 1
 111  CONTINUE
 999  RETURN
      END
      SUBROUTINE LUNSEM
C----------------------------------------------------------------------
C     A. FALVARD   -   130389   in HVFL01
C                  -   Modified :  november 1990 for HVFL02
C     B.Bloch      -   Modified : January  1991 for JETSET73
C     B.Bloch      02/98 fix handling of D** with degenerated codes
C! Steering for Semileptonic decays of Heavy Mesons. (B ONLY for now)
C     Comdecks referenced: BCS, LUN7COM, ALCONS ,BCODES ,LCODES ,MASTER
C                          SEMLEP
C----------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      PARAMETER (NMODEL=5,NDECAY=11)
      COMMON/SEMLEP/IMOSEM,WTM(NMODEL,NDECAY),IHEL,KHEL,PRM1,PR0,PRP1,
     $          BBDAT(NDECAY),BXDAT(NDECAY)  ,
     $          NO1(NDECAY),NO2(NDECAY),OVER(NMODEL,NDECAY)
     $          , IMODSS,R1,R2,R3
      REAL MFF,MFF2,MFF3,MFF4
      COMMON/MFFX/MFF(NMODEL,NDECAY),MFF2(NMODEL,NDECAY),
     $            MFF3(NMODEL,NDECAY),MFF4(NMODEL,NDECAY)
      REAL MB,MD,MQ,MBOT,MX,MUP,MUM,MS,MSQ,MRSQ,KSQ
      COMMON /SCORA/MB,MD,MQ,MBOT,MX,MUP,MUM,MS,MSQ,MRSQ,KSQ
     *,BM,BMSQ,XMTSQ,BB,BX,XMT,BBX,BR,BRX
      COMMON /SCOROU/AL,CP,Q,QV
      COMMON / MASTER / IGENE,IWEIT,IMIX,IVBU,IFL,IEV1,IEV2,ISEM,IDEC,
     $   IPHO,ILAM,IPRJ,IDDC,IBDK,ICDK,ITDK,ECM,WTMAX,SVRT(3),ICOULU(10)
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
      PARAMETER (NBU=521,NBD=511,NBS=531,NBC=541)
      PARAMETER (NLB=5122,NXB= 5132)
      PARAMETER (NXB0=5232,NOB= 5332)
C     NBU    = internal JETSET 7.4 code for Bu meson
C     NBD    = internal JETSET 7.4 code for Bd meson
C     NBS    = internal JETSET 7.4 code for Bs meson
C     NBC    = internal JETSET 7.4 code for Bc meson
C     NLB    = internal JETSET 7.4 code for /\B BARYON
C     NXB    = internal JETSET 7.4 code for XIB BARYON
C     NXB0   = internal JETSET 7.4 code for XIB0 BARYON
C     NOB    = internal JETSET 7.4 code for OMEGAB BARYON
      PARAMETER (NNUEL=12,NNUMU=14,NNUTO=16,NEL=11,NMU=13,NTO=15)
C     NNUEL  = internal JETSET 7.4 code for neutrino electron
C     NNUMU  = internal JETSET 7.4 code for neutrino mu
C     NNUTO  = internal JETSET 7.4 code for neutrino tau
C     NEL    = internal JETSET 7.4 code for electron
C     NMU    = internal JETSET 7.4 code for muon
C     NTO    = internal JETSET 7.4 code for tau
      DO 1 I=1,N7LU
         KF=ABS(K7LU(I,2))
C  We have a Bd,Bu or Bs
         IF(KF.NE.NBD .AND. KF.NE.NBU .AND. KF.NE.NBS) GO TO 1
         KS=K7LU(I,1)
C  It is a decayed particle
         IF(KS.LT.10) GO TO 1
C  Decay is a 3 body decay
         JF=K7LU(I,4)
         JL=K7LU(I,5)
C define helicity as unknown
         IWHELI = 99
         NDEC = JL-JF+1
C  Semileptonic e,mu only with neutrino first, then lepton
         NLEPN = 0
         NLEPC = 0
         KFNU = ABS(K7LU(JF,2))
         IF( KFNU.EQ.NNUEL .OR. KFNU.EQ.NNUMU) NLEPN = 1
         KFLE = ABS(K7LU(JF+1,2))
         IF( KFLE.EQ.NEL .OR. KFLE.EQ.NMU) NLEPC =1
         IF (NLEPN*NLEPC.NE.1) GO TO 1
         IF ( NDEC.NE.3 ) GO TO 90
C
C  Q2 GENERATION
C
         KD1=ABS(K7LU(JF  ,2))
         KD2=ABS(K7LU(JF+1,2))
         KD3=ABS(K7LU(JF+2,2))
         IDECAY=0
         KHIGH = KD3/100
         KLOW  = MOD(KD3,10)
         KEXC = 0
         IF ( KHIGH.GT.10) THEN
            KEXC = KHIGH/100
            KHIGH = MOD(KEXC,100)
         ENDIF
         id = 10000
         if ( klow.eq.1 .and.kexc.eq.0) id = 10020
         if ( klow.eq.1 .and.kexc.eq.1) id = 10026
         if ( klow.eq.3 .and.kexc.eq.0) id = 10022
         if ( klow.eq.3 .and.kexc.eq.1) id = 10024
         if ( klow.eq.3 .and.kexc.eq.2) id = 10028
         if ( klow.eq.5 .and.kexc.eq.0) id = 10034
         imodif = 0
C Identify which decay from third particle
C   KHIGH = 4 ---> D* (KLOW = 3) OR  D (KLOW = 1)    IDECAY = 1 , 2
C   KHIGH = 3 ---> K* (KLOW = 3) OR  K (KLOW = 1)    IDECAY = 5 , 6
C   KHIGH = 1,2--> RHO(KLOW = 3) OR  PI(KLOW = 1)    IDECAY = 3 , 4
C   KEXC = 1,2 KHIGH = 4  D**   IDECAY = 9,10,11
C   or KHIGH = 4 and KLOW = 5
         IF (KHIGH.LE.0) GO TO 90
         IF(KLOW.GT.3.AND.IMODSS.EQ.0)GOTO 90
         IF(KEXC.GT.0.AND.IMODSS.EQ.0)GOTO 90
         IF(KLOW.GT.5)GOTO 90
         IF (KHIGH.LE.2) IDECAY = 3
         IF (KHIGH.EQ.3) IDECAY = 5
         IF (KHIGH.EQ.4) IDECAY = 1
         IF (KLOW.LE.1) IDECAY =IDECAY+1
         IF(KLOW.EQ.5 .or. kexc.gt.0)THEN
C    to be worked on as we have 4 D** types well identified
           IMODS1=IMODSS
           IF(IMODSS.EQ.4)THEN
             XRD=RNDM(dum)
             IF(XRD.LT.R1)IMODSS=1
             IF(XRD.GE.R1.AND.XRD.LT.(R1+R2))IMODSS=2
             IF(XRD.GE.(R1+R2).AND.XRD.LE.(R1+R2+R3))IMODSS=3
           ENDIF
           IF(IMODSS.EQ.1)IDECAY=9
           IF(IMODSS.EQ.2)IDECAY=10
           IF(IMODSS.EQ.3)IDECAY=11
         ENDIF
         IMOSIM=IMOSEM
         IF(IDECAY.GE.9)IMOSEM=5
         IF(IDECAY.EQ.0)GOTO 90
         AM1=P7LU(I,5)
         AM2=P7LU(JL,5)
         IF(IMOSEM.EQ.5)THEN
           KD3=ABS(K7LU(JF+2,2))
           CALL LUIFLV (KF,IFLA,IFLB,IFLC,KSP)
           CALL LUIFLV (KD3,IFLA1,IFLB1,IFLC1,KSP1)
           IFLA=ABS(IFLA)
           IFLB=ABS(IFLB)
           IFLA1=ABS(IFLA1)
           MB=ULMASS(IFLA)
           MD=ULMASS(IFLB)
           MQ=ULMASS(IFLA1)
           IF(IFLA.EQ.4)MB=1.82
           IF(IFLA.EQ.5)MB=5.12
           IF(IFLB.EQ.1.OR.IFLB.EQ.2)MD=0.33
           IF(IFLB.EQ.3)MD=0.55
           IF(IFLB.EQ.4)MD=1.82
           IF(IFLA1.EQ.3)MQ=0.55
           IF(IFLA1.EQ.4)MQ=1.82
           BM=AM1
           BMSQ=BM**2
           XMT=AM2
           XMTSQ=XMT**2
           BB=BBDAT(IDECAY)
           BX=BXDAT(IDECAY)
           MBOT=MB+MD
           MX=MD+MQ
           MUP=(MB*MQ)/(MB+MQ)
           MUM=(MB*MQ)/(MB-MQ)
           MS=MBOT-MX
           MSQ=(MD**2)/(MX*MBOT)
           MRSQ=BMSQ/XMTSQ
           BBX=(BB**2+BX**2)/2.
           BR=BB**2/BBX
           BRX=BX**2/BBX
           KSQ=0.7**2
         ENDIF
         Q2MIN=P7LU(JF+1,5)**2
         Q2MAX=(AM1-AM2)**2
         IF(KHEL.EQ.0.OR.IDECAY.NE.1)THEN
 3         Q2=Q2MIN+RNDM(DUM)*(Q2MAX-Q2MIN)
           QPLUS=(AM1+AM2)**2-Q2
           QMINS=(AM1-AM2)**2-Q2
           PC=SQRT(QPLUS*QMINS)/(2.*AM1)
           IF (MOD(IDECAY,2).EQ.0)THEN
              XF=XDZERO(IMOSEM,IDECAY,AM1,AM2,Q2)**2*PC
           ELSE
              XF=(XHPLUS(IMOSEM,IDECAY,AM1,AM2,Q2)**2+XHMOINS(IMOSEM,
     *        IDECAY,AM1,AM2,Q2)**2+XHZERO(IMOSEM,IDECAY,AM1,AM2,Q2)**2)
     *        *PC
           ENDIF
           XQ2RAN=RNDM(DUM)
           IF(XQ2RAN.GT.XF/WTM(IMOSEM,IDECAY))GOTO 3
C
C  W HELICITY GENERATION
C
           IF(MOD(IDECAY,2).EQ.0)THEN
             IWHELI=0
           ELSE
             XHRAN=RNDM(dum)
             XHP=XHPLUS(IMOSEM,IDECAY,AM1,AM2,Q2)**2*PC/XF
             XHM=XHMOINS(IMOSEM,IDECAY,AM1,AM2,Q2)**2*PC/XF
             XHZ=XHZERO(IMOSEM,IDECAY,AM1,AM2,Q2)**2*PC/XF
             IWHELI=1
             IF(XHRAN.GT.XHP)IWHELI=-1
             IF(XHRAN.GT.(XHP+XHM))IWHELI=0
           ENDIF
         ELSE
           XHRAN=RNDM(DUM)
           IF(XHRAN.LE.PRM1)IWHELI=-1
           IF(XHRAN.GT.PRM1.AND.XHRAN.LE.PR0)IWHELI=0
           IF(XHRAN.GT.PR0)IWHELI=1
 100       Q2=Q2MIN+RNDM(DUM)*(Q2MAX-Q2MIN)
           QPLUS=(AM1+AM2)**2-Q2
           QMINS=(AM1-AM2)**2-Q2
           PC=SQRT(QPLUS*QMINS)/(2.*AM1)
           IF(IWHELI.EQ.-1)XF=XHMOINS(IMOSEM,IDECAY,AM1,AM2,Q2)**2*PC
           IF(IWHELI.EQ.0)XF=XHZERO(IMOSEM,IDECAY,AM1,AM2,Q2)**2*PC
           IF(IWHELI.EQ.1)XF=XHPLUS(IMOSEM,IDECAY,AM1,AM2,Q2)**2*PC
           XQ2RAN=RNDM(DUM)
           IF(XQ2RAN.GT.XF/WTM(IMOSEM,IDECAY))GOTO 100
         ENDIF
         IF(IDECAY.GE.9)THEN
           IMOSEM=IMOSIM
           IMODSS=IMODS1
         ENDIF
C
C  BOOST BACK B DECAY PRODUCES AT REST
C
         BXB=-P7LU(I,1)/P7LU(I,4)
         BYB=-P7LU(I,2)/P7LU(I,4)
         BZB=-P7LU(I,3)/P7LU(I,4)
         MSTU(1)=JF
         MSTU(2)=JL
         PX3=P7LU(JL,1)
         PY3=P7LU(JL,2)
         PZ3=P7LU(JL,3)
         E3=P7LU(JL,4)
         CALL LUROBO(0.,0.,BXB,BYB,BZB)
         COTH3=-1.+2*RNDM(DUM)
         THE3=ACOS(COTH3)
         THEW=PI-THE3
         PHI3=2.*PI*RNDM(DUM)
         PHIW=PI+PHI3
         P7LU(JL,1)=PC*SIN(THE3)*COS(PHI3)
         P7LU(JL,2)=PC*SIN(THE3)*SIN(PHI3)
         P7LU(JL,3)=PC*COS(THE3)
         P7LU(JL,4)=SQRT(PC**2+P7LU(JL,5)**2)
         PXW=-P7LU(JL,1)
         PYW=-P7LU(JL,2)
         PZW=-P7LU(JL,3)
         EW=SQRT(Q2+PC**2)
C
C  GENERATION OF LEPTONIC W DECAY
C
         DMAX=1.
         IF(IWHELI.EQ.0)DMAX=0.5
 4       THELEP=ACOS(-1.+2.*RNDM(dum))*180./PI
         RTHLEP=RNDM(dum)
         IF(RTHLEP.GT.DSMALL(1.,FLOAT(IWHELI),-1.,THELEP)**2/DMAX)GOTO 4
         THELEP=THELEP*PI/180.
         PHILEP=2.*PI*RNDM(dum)
         PLEP=(Q2-Q2MIN)/(2.*SQRT(Q2))
         P7LU(JF+1,1)=PLEP*SIN(THELEP)*COS(PHILEP)
         P7LU(JF+1,2)=PLEP*SIN(THELEP)*SIN(PHILEP)
         P7LU(JF+1,3)=PLEP*COS(THELEP)
         P7LU(JF+1,4)=SQRT(P7LU(JF+1,1)**2+P7LU(JF+1,2)**2
     *   +P7LU(JF+1,3)**2+P7LU(JF+1,5)**2)
         P7LU(JF,1)=-P7LU(JF+1,1)
         P7LU(JF,2)=-P7LU(JF+1,2)
         P7LU(JF,3)=-P7LU(JF+1,3)
         P7LU(JF,4)=SQRT(P7LU(JF,1)**2+P7LU(JF,2)**2
     *   +P7LU(JF,3)**2+P7LU(JF,5)**2)
         MSTU(2)=JF+1
         CALL LUROBO(0.,0.,0.,0.,PC/EW)
         CALL LUROBO(THEW,PHIW,0.,0.,0.)
         CALL HFILL(id,P7LU(JF+1,4),0.,1.)
         MSTU(2)=JL
         CALL LUROBO(0.,0.,-BXB,-BYB,-BZB)
C LEPTON ENERGY AFTER BOOST.
         CALL HFILL(id+1,P7LU(JF+1,4),0.,1.)
         imodif = 1
         MSTU(1)=1
         MSTU(2)=N7LU
C
C  KILL THE DECAY PRODUCTS OF B DAUGHTERS
C
         NPARI=N7LU
         N7LU=JL
         DO 5 IGARB0=JF,JL
           KST = K7LU(IGARB0,1)
           IF ( KST.GT.10 .AND. KST.LT.20 ) THEN
              K7LU(IGARB0,1) = KST-10
              K7LU(IGARB0,4)=0
              K7LU(IGARB0,5)=0
           ELSE
              GO TO 5
           ENDIF
C  Identify in the remaining list the successive daughters
         DO 6 IGARB=JL+1,NPARI
           IGARB1=IGARB
 7         IGARB1=K7LU(IGARB1,3)
           IF(IGARB1.EQ.IGARB0.OR.IGARB1.EQ.1000)THEN
              K7LU(IGARB,3)=1000
              K7LU(IGARB,4)=0
              K7LU(IGARB,5)=0
              GOTO 6
           ENDIF
           IF(IGARB1.LT.IGARB0)THEN
              GOTO 6
           ELSE
              GOTO 7
           ENDIF
 6       CONTINUE
 5       CONTINUE
C   Compress the remaining entries
         IMOT0 = -1
         DO 8 IGARB=JL+1,NPARI
            IF(K7LU(IGARB,3).EQ.1000)GOTO 8
            N7LU=N7LU+1
            K7LU(N7LU,1)=K7LU(IGARB,1)
            K7LU(N7LU,2)=K7LU(IGARB,2)
            K7LU(N7LU,3)=K7LU(IGARB,3)
            K7LU(N7LU,4)=K7LU(IGARB,4)
            K7LU(N7LU,5)=K7LU(IGARB,5)
            DO 9 IGARB2=1,5
              P7LU(N7LU,IGARB2)=P7LU(IGARB,IGARB2)
 9          CONTINUE
C   Update current daughter number for the mother
            IMOTH = K7LU(N7LU,3)
            IF (IMOTH.EQ.IMOT0) GOTO 10
              IMOT0 = IMOTH
              K7LU(IMOTH,4) = K7LU(IMOTH,4)+N7LU-IGARB
              K7LU(IMOTH,5) = K7LU(IMOTH,5)+N7LU-IGARB
 10         CONTINUE
C   Update current mother number for the daughters
            IF (K7LU(IGARB,5).LE.0) GOTO 8
            DO 11 IGARB2= K7LU(IGARB,4),K7LU(IGARB,5)
               K7LU(IGARB2,3)=N7LU
 11         CONTINUE
 8       CONTINUE
         MSTU(2)=N7LU
C   Apply intern Brem if needed
 90      CONTINUE
         if ( imodif.eq.0 ) CALL HFILL(id+1,P7LU(JF+1,4),0.,1.)
         IF(IPHO.GT.0) CALL LUNPHO(-I)
         IF ( IWHELI.EQ.99) GO TO 1
         LF=K7LU(I,4)
         LL=K7LU(I,5)
         DO 14 JL = LF,LL
         IFLAV3=ABS(K7LU(JL,2))
         IF ( IFLAV3.LE.100) GO TO 14
         CALL LUIFLV(IFLAV3,IFLA3,IFLB3,IFLC3,KSP3)
C
C  PRODUCE ANGULAR DISTRIBUTION FOR VECTOR --> PSEUDO. + PSEUDO.
C  DECAY D* , K* AND RHO  , THEN MODIFY ANGULAR DISTRIBUTION
         IF(IABS(KSP3).EQ.1)THEN
            N7LU1=N7LU
            CALL LUDECY(JL)
            DNPAR=N7LU-N7LU1
            IF(DNPAR.NE.2)GOTO 12
            KFA1=ABS(K7LU(N7LU1+1,2))
            KFA2=ABS(K7LU(N7LU1+2,2))
            CALL LUIFLV(KFA1,IFLA1,IFLB1,IFLC1,KSP1)
            CALL LUIFLV(KFA2,IFLA2,IFLB2,IFLC2,KSP2)
            IF(KSP1.NE.0.OR.KSP2.NE.0)GOTO 12
            BXB=-P7LU(JL,1)/P7LU(JL,4)
            BYB=-P7LU(JL,2)/P7LU(JL,4)
            BZB=-P7LU(JL,3)/P7LU(JL,4)
            MSTU(1)=N7LU1+1
            MSTU(2)=N7LU
            CALL LUROBO(0.,0.,BXB,BYB,BZB)
            PHID=2*PI*RNDM(DUM)
 13         COTHED=-1.+2.*RNDM(DUM)
            THED=ACOS(COTHED)*180./PI
            IF(RNDM(DUM).GT.DSMALL(1.,FLOAT(IWHELI),0.,THED)**2)GOTO 13
            THED=THED*PI/180.
            PD=SQRT(P7LU(N7LU1+1,1)**2+P7LU(N7LU1+1,2)**2
     *      +P7LU(N7LU1+1,3)**2)
            P7LU(N7LU1+1,1)=PD*SIN(THED)*COS(PHID)
            P7LU(N7LU1+1,2)=PD*SIN(THED)*SIN(PHID)
            P7LU(N7LU1+1,3)=PD*COS(THED)
            P7LU(N7LU,1)=-P7LU(N7LU1+1,1)
            P7LU(N7LU,2)=-P7LU(N7LU1+1,2)
            P7LU(N7LU,3)=-P7LU(N7LU1+1,3)
            BB=SQRT(BXB**2+BYB**2+BZB**2)
            CALL LUROBO(0.,0.,0.,0.,BB)
            PHIDST=ACOS(-BXB/SQRT(BXB**2+BYB**2))
            IF(-BYB.LT.0.)PHIDST=2*PI-PHIDST
            THEDST=ACOS(-BZB/BB)
            CALL LUROBO(THEDST,PHIDST,0.,0.,0.)
 12         CONTINUE
            MSTU(1)=1
            MSTU(2)=N7LU
         ENDIF
 14      CONTINUE
 1    CONTINUE
      RETURN
      END
      SUBROUTINE LUTODK(NTAU,ITAU,PTAU)
C------------------------------------------------------------------
C! Perform tau decays including polarisation effects
C  B.Bloch November 94
C   Output :
C   NTAU : number of tau's found in the event [0,10]
C   ITAU(n): position of the tau's in the jetset event record
C   PTAU(n): Polarisation value for each Tau found
C     Comdecks referenced: LUN7COM, LCODES ,TPOLAR
C------------------------------------------------------------------
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      REAL*4 TPOL
      COMMON/TPOLAR/TPOL
C    Tau polarization
      DIMENSION ITAU(10),PTAU(10)
      PARAMETER (NNUEL=12,NNUMU=14,NNUTO=16,NEL=11,NMU=13,NTO=15)
C     NNUEL  = internal JETSET 7.4 code for neutrino electron
C     NNUMU  = internal JETSET 7.4 code for neutrino mu
C     NNUTO  = internal JETSET 7.4 code for neutrino tau
C     NEL    = internal JETSET 7.4 code for electron
C     NMU    = internal JETSET 7.4 code for muon
C     NTO    = internal JETSET 7.4 code for tau
      NTAU = 0
      DO 1 I=1,N7LU
         KF=ABS(K7LU(I,2))
C  We have a Tau
         IF(KF.NE.NTO  ) GO TO 1
         KS=K7LU(I,1)
C  It is a undecayed particle
         IF(KS.GT.10) GO TO 1
C  Let's decay it and get its polarization
         CALL LUDECY(I)
         NTAU = NTAU + 1
         ITAU(NTAU) = I
         PTAU(NTAU) = TPOL
 1    continue
      RETURN
      END
      SUBROUTINE LUNVBU(IFVB)
C------------------------------------------------------------------
C! Include  VBU transitions if any
C  B.Bloch November 90
C   IFVB : Vbu transition flag  0= no Vbu occured , 1= Vbu on initial B
C                               2= Vbu on initial Bbar, 3= Vbu on both
C     comdecks referenced : LUN7COM , BCODES ,VBUCOM
C------------------------------------------------------------------
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      COMMON/VBUCOM/ IMATBU,PRBUBC,PARDBU,ITYPBU
      PARAMETER (NBU=521,NBD=511,NBS=531,NBC=541)
      PARAMETER (NLB=5122,NXB= 5132)
      PARAMETER (NXB0=5232,NOB= 5332)
C     NBU    = internal JETSET 7.4 code for Bu meson
C     NBD    = internal JETSET 7.4 code for Bd meson
C     NBS    = internal JETSET 7.4 code for Bs meson
C     NBC    = internal JETSET 7.4 code for Bc meson
C     NLB    = internal JETSET 7.4 code for /\B BARYON
C     NXB    = internal JETSET 7.4 code for XIB BARYON
C     NXB0   = internal JETSET 7.4 code for XIB0 BARYON
C     NOB    = internal JETSET 7.4 code for OMEGAB BARYON
C Introduce Vbu transitions if needed for non yet decayed B meson
      IFVB = 0
      DO 102 I=1,N7LU
       IF(K7LU(I,1).LT.10)THEN
       KF=ABS(K7LU(I,2))
       IF ( KF.EQ.NBU .OR. KF.EQ.NBD .OR. KF.EQ.NBS .OR. KF.EQ.NBC) THEN
        IF(RNDM(DUM).LT.PRBUBC)THEN
          CALL VBCVBU (KF)
          CALL LUDECY(I)
          CALL VBUVBC (KF)
          IF (K7LU(I,2).GT.0) THEN
              IFVB = IFVB +1
          ELSEIF (K7LU(I,2).LT.0) THEN
              IFVB = IFVB +2
          ENDIF
        ENDIF
       ENDIF
       ENDIF
 102  CONTINUE
      RETURN
      END
      SUBROUTINE LUZETA(ZB)
C------------------------------------------------------------------
C! Transfer the content of fragmention information  to ZB array
C    B.Bloch-Devaux January   1991
C     comdecks referenced : LUN7COM
C----------------------------------------------------------------------
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      DIMENSION ZB(LJNPAR)
      IF (MSTU(90).GT.0) THEN
         DO 10 I = 1,MSTU(90)
         J = MSTU(91+I-1)
 10      ZB(J) = PARU(91+I-1)
      ENDIF
      RETURN
      END
      REAL FUNCTION MIDECL(P,AM,T0,IOSCI)
C---------------------------------------------------------------------
C  GENERATES THE CORRECT DECAY LENGTH FOR MIXING      881024
C  AUTHOR: A. FALVARD
C             INPUTS:
C                    -P            :MOMENTUM
C                    -AM           :MASS
C                    -T0           :INTRINSEQ LIFE TIME
C                    -IOSCI        :STATUS OF THE PARTICLE VERSUS MIXING
C                                   LOOK AT KBOSCI FOR DEFINITION
C             Comdecks referenced: ALCONS ,MIXING
C----------------------------------------------------------------------
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
      COMPLEX PSQD,PSQS
      COMMON/ MIXING /XD,YD,CHID,RD,XS,YS,CHIS,RS,PSQD,PSQS
      COMMON/ PROBMI /CDCPBA,CDCPB,CSCPBA,CSCPB
      PARAMETER (CLITS = CLGHT * 1.E+09)
      EXTERNAL RNDM
      X=XD
      Y=YD
      IF(IOSCI.EQ.3.OR.IOSCI.EQ.4)THEN
      X=XS
      Y=YS
      ENDIF
 1    Z=RNDM(DUM)
      IF(Z.EQ.0.)Z=1.
      AL=ALOG(Z)
      MIDECL=-T0*AL
C      SIGN=1.
C      IF(IOSCI.EQ.2.OR.IOSCI.EQ.4)SIGN=-1.
      II= MOD(IOSCI,2)
      FCON=COSH(-Y*AL)+(2*II-1)*COS(-X*AL)
      F1MAX=1.+COSH(14.*Y)
      IF(F1MAX*RNDM(DUM).GT.FCON)GOTO 1
      CALL HFILL(10009+IOSCI,-AL,0.,1.)
      MIDECL=P*MIDECL/AM*CLITS
      RETURN
      END
      SUBROUTINE PHOCAL(IMOD)
C-----------------------------------------------------------
C...Purpose: call photos and check if any extra photon added
C     comdecks referenced : HEPEVT
C-----------------------------------------------------------
      PARAMETER (NMXHEP=2000)
      COMMON/HEPEVT/NEVHEP,NHEP,ISTHEP(NMXHEP),IDHEP(NMXHEP),
     &JMOHEP(2,NMXHEP),JDAHEP(2,NMXHEP),PHEP(5,NMXHEP),VHEP(4,NMXHEP)
      SAVE /HEPEVT/
      IMOD = 0
      NHEPI = NHEP
      CALL PHOTOS(1)
      NHEPF = NHEP
      IMOD=NHEPF-NHEPI
      RETURN
      END
      SUBROUTINE QQTOPS (BQP,BQM,ITYP2,IZLU)
C-----------------------------------------------------------------------
C   B.Bloch-Devaux April 1991
C
C        jetset 7.4 parton shower INTERFACE
C
C        SET UP THE LUND COMMON   WITH NEXT POSITIONS
C        N+1    ANTIFERMION   }                    ( BQP)
C        N+2    FERMION       }   OF FLAVOR ITYP2  ( BQM)
C       ITYP2   1=E, 2=MU, 3=TAU, 11=d, 12=u, 13=s, 14=c, 15=b, 16=t
C        IZLU   is the mother of the fermion pair
C          THEN following particles are those after parton shower evol.
C          the original fermions are artificially kept in the two above
C          lines.
C
C     comdecks referenced : LUN7COM
C-----------------------------------------------------------------------
      DIMENSION BQP(4),BQM(4),Z(4),IJOIN(2)
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      DATA NEV/0/
C
       IF(ITYP2.LT.10) THEN
C
C        THESE ARE LEPTONS  NO SHOWER  LINES NEEDED
C          THIS REPRODUCES THE LUND7.4 LEPTON FLAVOR CODE
C
         KMASS=9+2*ITYP2
         K7LU(N7LU+1,1)= 1
         K7LU(N7LU+2,1)= 1
         K7LU(N7LU+1,3)= IZLU
         K7LU(N7LU+2,3)= IZLU
         K7LU(N7LU+1,2)= -KMASS
         K7LU(N7LU+2,2)= KMASS
         P7LU(N7LU+1,5)= ULMASS(KMASS)
         P7LU(N7LU+2,5)= ULMASS(KMASS)
         DO 40 I=1,4
           P7LU(N7LU+1,I)=BQP(I)
           P7LU(N7LU+2,I)=BQM(I)
   40    CONTINUE
         N7LU=N7LU+2
         CALL LUEXEC
      ELSE
C
C     QUARKS
C

         KMASS=ITYP2 -10
C  now the quarks for shower lines
         K7LU(N7LU+1,1)= 3
         K7LU(N7LU+1,2)=-KMASS
         K7LU(N7LU+1,3)= IZLU
         K7LU(N7LU+2,1)= 3
         K7LU(N7LU+2,2)= KMASS
         K7LU(N7LU+2,3)= IZLU
         P7LU(N7LU+1,5)=ULMASS(KMASS)
         P7LU(N7LU+2,5)=ULMASS(KMASS)
         DO 140 I=1,4
           P7LU(N7LU+1,I)=BQP(I)
           P7LU(N7LU+2,I)=BQM(I)
  140    CONTINUE
C
C   Connect the partons in  a string configuration
C
         NJOIN = 2
         IJOIN(1) = N7LU+1
         IJOIN(2) = N7LU+2
         N7LU=N7LU+2
         CALL LUJOIN( NJOIN,IJOIN)
C
C    CALCULATE THE QQBAR MASS
C
         N=N7LU
         DO 150 I=1,4
           Z(I)=BQP(I)+BQM(I)
  150    CONTINUE
         QMAX= SQRT( Z(4)**2- Z(3)**2-Z(2)**2-Z(1)**2 )
C
C         GENERATE PARTON SHOWER
C
         IF( NEV.LE. 5)CALL LULIST(1)
         CALL LUSHOW(N,N-1,QMAX)
         IF (MSTJ(105).GT.0) CALL LUEXEC
C
C
      ENDIF
C
C   Now check if the initial electron was along positive Z axis.
C   If not reverse Px and Pz components for all particles
C
      IF ( P7LU(1,3)*K7LU(1,2).LT.0..AND. ABS(K7LU(1,2)).EQ.11) THEN
         DO 201 IP=1,N7LU
         DO 202 JJ=1,3,2
 202       P7LU(IP,JJ) = -P7LU(IP,JJ)
 201     CONTINUE
      ENDIF
      NEV=NEV+1
      IF(NEV.LE. 5)CALL LULIST(1)
      RETURN
      END
      SUBROUTINE SIGENE(IDPR,ISTAT,ECMS)
C-------------------------------------------------------------
C! Generate single particle and fill lund common with it
C  B. Bloch November 90 for JETSET 7.4 version
C     comdecks referenced : LUN7COM ,SINGEN
C--------------------------------------------------------------
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      COMMON/SINGEN/ITYPSI,PMINSI,PMAXSI,COMISI,COMASI,PHMISI,PHMASI
C   single particle settings
      DATA NIT /0/
      NIT = NIT + 1
      PMOD = PMINSI + (PMAXSI-PMINSI)*RNDM(DUM)
      COST = COMISI + (COMASI-COMISI)*RNDM(DUM)
      PHI  = PHMISI + (PHMASI-PHMISI)*RNDM(DUM)
      SINT = SQRT(1.-COST*COST)
      XMAS = ULMASS(ITYPSI)
      N7LU = 1
      K7LU(1,1) = 1
      K7LU(1,2) = ITYPSI
      K7LU(1,3) = 0
      K7LU(1,4) = 0
      K7LU(1,5) = 0
      P7LU(1,1) = PMOD*COS(PHI)*SINT
      P7LU(1,2) = PMOD*SIN(PHI)*SINT
      P7LU(1,3) = PMOD*COST
      P7LU(1,4) = SQRT(PMOD*PMOD+XMAS*XMAS)
      P7LU(1,5) = XMAS
      IDPR = ITYPSI*1000
      ISTAT = 0
      ECMS = PMOD
      IF( NIT.LE.5 ) CALL LULIST(1)
      RETURN
      END
      SUBROUTINE UGTSEC
C--------------------------------------------------------------------
C    B.Bloch-Devaux  January 99 create cross section bank
C--------------------------------------------------------------------
      PARAMETER ( IDCO = 5030)
      COMMON / MASTER / IGENE,IWEIT,IMIX,IVBU,IFL,IEV1,IEV2,ISEM,IDEC,
     $   IPHO,ILAM,IPRJ,IDDC,IBDK,ICDK,ITDK,ECM,WTMAX,SVRT(3),ICOULU(10)
      COMMON /CONST/ ALFA,PI,ALFA1
      COMMON /RUNPAR/ SOLD,ID2,ID3,FINEXP,POIDS,INTERF,XK0
      COMMON /WEAK/ AEL,AMU,AMZ,GAMM,SW2,CA2,CV2,CA2CV2,COL,T3,QI
      COMMON /BEAM/ S0,EBEAM
      COMMON /TAU / TAUV,CPTAU,HEL,PITAU(4)
      COMMON/WEAKQ/WEAKC(11,6),XSECT(6),XTOT,ersec(6),nevsec(6)
      COMMON/ZDUMP / IDEBU , NEVT
      COMMON/RESULT/ SIGBOR,SIGTOT,ERRSIG,ASYTOT,ERRASY
C   DYMU3 internal commons
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      DATA FVERS/
     $1.07
     $/
      IF (IGENE.EQ.3 .OR. IGENE.EQ.13) THEN
          ertot = 0.
          nqua = 0
          nevma = 0
          do 5 i= 1,5
            if (xsect(i).le.0.) go to 5
            ertot = ertot + ersec(i)*ersec(i)
            nqua = nqua + 1
            nevma = nevsec(i)
   5      continue
          nevma = nevma * nqua
C    book cross-section bank KSEC
         IDC = IDCO
         IVER = ifix(100.*FVERS)
         NTOT = NEVMA
         NACC = NEVMA
         if (nqua.gt.0) then
           XTOTL = XTOT
           RTOT = sqrt(ERTOT)
           XACC = XTOT
           RACC = RTOT
           is =1
C
           ISEC =  KSECBK(IS,IDC,IVER,NTOT,NACC,XTOTL,RTOT,XACC,RACC)
           DO 200 I=1,5
            IF(XSECT(i).EQ.0) GOTO 200
            IS = IS + 1
            XTOTL = XSECT(i)*XTOT
            if (i.ge.2) XTOTL = XTOTL-XSECT(i-1)*XTOT
            RTOT = ERSEC(i)
            XACC = XTOTL
            RACC = RTOT
            NTOT = nevsec(i)
            ISEC =  KSECBK(IS,IDC,I,NTOT,NTOT,XTOTL,RTOT,XACC,RACC)
  200     CONTINUE
         else
          call dymund
C   if KSEC not already created ( mixed flavour mode ) create it
          NTOT = ICOULU(10)
          NACC = NTOT
          XTOTL = SIGTOT
          RTOT = ERRSIG
          XACC = SIGTOT
          RACC = RTOT
          is =1
C
          ISEC =  KSECBK(IS,IDC,IVER,NTOT,NACC,XTOTL,RTOT,XACC,RACC)
         endif
      ELSE IF (IGENE.EQ.1 .OR. IGENE.EQ.11) THEN
         IDC = IDCO
         IVER = ifix(100.*FVERS)
         NTOT = ICOULU(10)
         NACC = NTOT
         XTOTL = PARJ(148)
         RTOT = xtotl/sqrt(float(nacc))
         XACC = XTOTL
         RACC = RTOT
         is =1
C
         ISEC =  KSECBK(IS,IDC,IVER,NTOT,NACC,XTOTL,RTOT,XACC,RACC)

      ENDIF
      CALL PRTABL('KSEC',0)
      RETURN
      END
      SUBROUTINE USCJOB
C-------------------------------------------------------------
C! Termination routine JETSET 7.4 version
C     comdecks referenced : LUN7COM ,BCS ,DYMUCOM ,MASTER ,HVFPRNT
C   build KSEC bank if not yet done b.bloch 01/99
C--------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
      DATA FVERS /
     $1.07
     $/
      COMMON / MASTER / IGENE,IWEIT,IMIX,IVBU,IFL,IEV1,IEV2,ISEM,IDEC,
     $   IPHO,ILAM,IPRJ,IDDC,IBDK,ICDK,ITDK,ECM,WTMAX,SVRT(3),ICOULU(10)
      COMMON/HVFPRNT/IPPRI
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
      SAVE /LUJETS/,/LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/
C
      COMMON /CONST/ ALFA,PI,ALFA1
      COMMON /RUNPAR/ SOLD,ID2,ID3,FINEXP,POIDS,INTERF,XK0
      COMMON /WEAK/ AEL,AMU,AMZ,GAMM,SW2,CA2,CV2,CA2CV2,COL,T3,QI
      COMMON /BEAM/ S0,EBEAM
      COMMON /TAU / TAUV,CPTAU,HEL,PITAU(4)
      COMMON/WEAKQ/WEAKC(11,6),XSECT(6),XTOT,ersec(6),nevsec(6)
      COMMON/ZDUMP / IDEBU , NEVT
      COMMON/RESULT/ SIGBOR,SIGTOT,ERRSIG,ASYTOT,ERRASY
C   DYMU3 internal commons
C.......................................................................
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
     &        /10X,'IR= 6 USER reject in BRGENE      # OF REJECT =',I10,
     &        /10X,'IR= 7 BOS ERROR KZFR/KPOL BANK   # OF REJECT =',I10,
     &        /10X,'IR= 8 User selected decay chain  # OF REJECT =',I10)
      IF (IGENE.EQ.3 .OR. IGENE.EQ.13) THEN
        CALL DYMUND
        IF ( XTOT.NE.0.) WRITE(IUT,106) XTOT
  106   FORMAT (/10X,' CORRESPONDING TOTAL CROSS SECTION (NANOBARN):',
     $  F12.4)
C   if KSEC not already created ( mixed flavour mode ) create it
         CALL UGTSEC
      ELSEIF (IGENE.EQ.1.OR.IGENE.EQ.11) THEN
        WRITE (IUT,105) (PARJ(II),II=141,148)
 105    FORMAT(//,20X,'FINAL RESULTS FROM LUND GENERATION',
     $          /,20X,'**********************************',
     $          /,10X,'R value as given in massless QED   :',F10.5,
     $          /,10X,'R value including weak effects     :',F10.5,
     $          /,10X,'R value including QCD corrections  :',F10.5,
     $          /,10X,'R value including I.S.R. effects   :',F10.5,
     $          /,10X,'Absolute cross sections in nb      :',
     $          /,10X,'As given  in massless QED   :',F10.5,
     $          /,10X,'Including  weak effects     :',F10.5,
     $          /,10X,'Including  QCD corrections  :',F10.5,
     $          /,10X,'Including  I.S.R. effects   :',F10.5)
         CALL UGTSEC
      ENDIF
C
      IF ( IDEC+IDDC.GT.0) CALL DECSTA
      IF ( ITDK.GT.0)   THEN
       NMODE = 100
       NPAR1 = 0
       NPAR2 = 0
       CALL TAUDKAY(NPAR1,NPAR2,NMODE)
C
      ENDIF
      IF ( IPPRI/10 .GT.0) THEN
         CALL LUTABU(12)
         CALL LUTABU(22)
         IF (IGENE.EQ.-1) CALL LUTABU(52)
      ENDIF
      RETURN
      END
      FUNCTION XDZERO (IMODEL,J,M1,M2,Q2)
C----------------------------------------------------------------------
C     A. FALVARD   -   130389
C
C! H0 HELICITY AMPLITUDE FOR B OR D --> EL + NEUT + PSEUDOSCALAR
C     comdecks referenced :  SEMLEP
C---------------------------------------------------------------------
      REAL M1,M2
      PARAMETER (NMODEL=5,NDECAY=11)
      COMMON/SEMLEP/IMOSEM,WTM(NMODEL,NDECAY),IHEL,KHEL,PRM1,PR0,PRP1,
     $          BBDAT(NDECAY),BXDAT(NDECAY)  ,
     $          NO1(NDECAY),NO2(NDECAY),OVER(NMODEL,NDECAY)
     $          , IMODSS,R1,R2,R3
      REAL MFF,MFF2,MFF3,MFF4
      COMMON/MFFX/MFF(NMODEL,NDECAY),MFF2(NMODEL,NDECAY),
     $            MFF3(NMODEL,NDECAY),MFF4(NMODEL,NDECAY)
      REAL MB,MD,MQ,MBOT,MX,MUP,MUM,MS,MSQ,MRSQ,KSQ
      COMMON /SCORA/MB,MD,MQ,MBOT,MX,MUP,MUM,MS,MSQ,MRSQ,KSQ
     *,BM,BMSQ,XMTSQ,BB,BX,XMT,BBX,BR,BRX
      COMMON /SCOROU/AL,CP,Q,QV
      XDZERO=0.
      T=Q2
      Q2MAX = (M1-M2)**2
      IF(IMODEL.LE.4)THEN
         VM=MFF(IMODEL,J)**2/(MFF(IMODEL,J)**2-Q2)
         VM2=MFF2(IMODEL,J)**2/(MFF2(IMODEL,J)**2-Q2)
         VM3=MFF3(IMODEL,J)**2/(MFF3(IMODEL,J)**2-Q2)
         VM4=MFF4(IMODEL,J)**2/(MFF4(IMODEL,J)**2-Q2)
         OVER1=OVER(IMODEL,J)
      ENDIF
      PI=4.*ATAN(1.)
      QPLUS=(M1+M2)**2-Q2
      QMINS=(M1-M2)**2-Q2
      IF(QMINS.LT.0.)GOTO 1
      PC=SQRT(QPLUS*QMINS)/(2.*M1)
      IF(IMODEL.EQ.5)THEN
        Y=Q2/M1**2
        PX=PC
        TM=(BM-XMT)**2
        T=TM-Y*BMSQ
        FEX=EXP(-MSQ*T/(4.*KSQ*BBX))
        FEX1=FEX*((BB*BX/BBX)**2.5)*SQRT(MX/MBOT)
        QV=0.5*FEX1*MD/(MX*BB)
        AL=-FEX1*MBOT*BB*((1./MUM)+0.5*(MD/(MBOT*KSQ*
     &  (BB**2)))*T*((1./MQ)-MD*BR/(2.*MUM*MX)))
        CP=FEX1*(MD*MB/(4.*BB*MBOT))*((1./MUM)-(MD*
     &  MQ/(2.*MX*(MUM**2)))*BR)
        FEX2=FEX*((BB*BX/BBX)**1.5)
        Q=FEX2*(1.+(MB/(2.*MUM))-MB*MQ*MD*BR/(4.*MUP*MUM*MX))
        FEX5=FEX*((BB*BX/BBX)**2.5)*SQRT(MX/MBOT)
        UP=FEX5*MD*MQ*MB/(SQRT(6.)*BB*MX*MUM)
      ENDIF
C.. 0 DECAY
      IF (IMODEL.EQ.1) THEN
        XDZERO = 2. * M1 * PC * VM * OVER1
      ELSEIF (IMODEL.EQ.2) THEN
C       XDZERO = 2.*M1*PC*1.8075*0.6269*EXP(-0.0296*(Q2MAX-T))
        XDZERO = 2.*M1*PC*1.8075*0.6269*EXP(-0.0145*(Q2MAX-T))
      ELSEIF (IMODEL.EQ.3) THEN
        XDZERO = SQRT(2.)*PC*SQRT( M1**2+M2**2-T )
      ELSEIF (IMODEL.EQ.4) THEN
        XDZERO = 2. * M1 * PC * VM * OVER1
      ELSEIF (IMODEL.EQ.5) THEN
        IF(J.LT.10)XDZERO = PC*2.*M1*2.*Q
        IF(J.EQ.10)XDZERO = PC*2.*M1*2.*UP
      ENDIF
 200  CONTINUE
 1    CONTINUE
      RETURN
      END
      FUNCTION XHMOINS (IMODEL,J,M1,M2,Q2)
C-----------------------------------------------------------------------
C     A. FALVARD   -   130389
C
C! H- HELICITY AMPLITUDE FOR B OR D --> EL + NEUT + VECTOR MESON
C     comdecks referenced :  SEMLEP
C-----------------------------------------------------------------------
      REAL M1,M2
      PARAMETER (NMODEL=5,NDECAY=11)
      COMMON/SEMLEP/IMOSEM,WTM(NMODEL,NDECAY),IHEL,KHEL,PRM1,PR0,PRP1,
     $          BBDAT(NDECAY),BXDAT(NDECAY)  ,
     $          NO1(NDECAY),NO2(NDECAY),OVER(NMODEL,NDECAY)
     $          , IMODSS,R1,R2,R3
      REAL MFF,MFF2,MFF3,MFF4
      COMMON/MFFX/MFF(NMODEL,NDECAY),MFF2(NMODEL,NDECAY),
     $            MFF3(NMODEL,NDECAY),MFF4(NMODEL,NDECAY)
      REAL MB,MD,MQ,MBOT,MX,MUP,MUM,MS,MSQ,MRSQ,KSQ
      COMMON /SCORA/MB,MD,MQ,MBOT,MX,MUP,MUM,MS,MSQ,MRSQ,KSQ
     *,BM,BMSQ,XMTSQ,BB,BX,XMT,BBX,BR,BRX
      COMMON /SCOROU/AL,CP,Q,QV
      XHMOINS=0.
      T=Q2
      Q2MAX = (M1-M2)**2
      IF(IMODEL.LE.4)THEN
         VM=MFF(IMODEL,J)**2/(MFF(IMODEL,J)**2-Q2)
         VM2=MFF2(IMODEL,J)**2/(MFF2(IMODEL,J)**2-Q2)
         VM3=MFF3(IMODEL,J)**2/(MFF3(IMODEL,J)**2-Q2)
         VM4=MFF4(IMODEL,J)**2/(MFF4(IMODEL,J)**2-Q2)
         OVER1=OVER(IMODEL,J)
      ENDIF
      PI=4.*ATAN(1.)
      QPLUS=(M1+M2)**2-Q2
      QMINS=(M1-M2)**2-Q2
      IF(QMINS.LT.0.)GOTO 1
      PC=SQRT(QPLUS*QMINS)/(2.*M1)
      IF(IMODEL.EQ.5)THEN
        Y=Q2/M1**2
        PX=PC
        TM=(BM-XMT)**2
        T=TM-Y*BMSQ
        FEX=EXP(-MSQ*T/(4.*KSQ*BBX))
      FEX1=FEX*((BB*BX/BBX)**1.5)*SQRT(MX/MBOT)
      GV1=0.5*(1./MQ-MD*BR/(2.*MUM*MX))
      F1=2.*MBOT
      GV=GV1*FEX1
      F=F1*FEX1
      AP=-0.5*FEX1/MX*(1.+MD/MB*((BB**2-BX**2)/(BB**2+BX**2))
     *-MD**2/(4.*MUM*MBOT)*BX**4/BBX**2)
      AMSQ=MSQ/(4.*KSQ*BBX)
      FEX5=FEX*((BB*BX/BBX)**2.5)*SQRT(MX/MBOT)
      QV=0.5*FEX5*MD/(MX*BB)
      AL=-FEX5*MBOT*BB*((1./MUM)+0.5*(MD/(MBOT*KSQ*
     &(BB**2)))*T*((1./MQ)-MD*BR/(2.*MUM*MX)))
      CP=FEX5*(MD*MB/(4.*BB*MBOT))*((1./MUM)-(MD*
     &MQ/(2.*MX*(MUM**2)))*BR)
      R=FEX5*MBOT*BB/(SQRT(2.)*MUP)
      SP=FEX5*MD/(SQRT(2.)*BB*MBOT)*(1.+MB/(2.*MUM)-MB*MD*MQ
     &/(4.*MUP*MUM*MX)*BR)
      V=FEX5*MBOT*BB/(4.*SQRT(2.)*MB*MQ*MX)
      FEX2=FEX1
      UP=FEX5*MD*MQ*MB/(SQRT(6.)*BB*MX*MUM)
        Q=FEX2*(1.+(MB/(2.*MUM))-MB*MQ*MD*BR/(4.*MUP*MUM*MX))
      ENDIF
C.. -* DECAY

      IF (IMODEL.EQ.1) THEN
        IF(J.LT.7) THEN
C..SEMILEPTONIC B-->D,D* DECAY.
          XHMOINS = SQRT(T) * VM * OVER1 *
     &    ( M1 + M2 + IHEL * 2.*M1 * PC * VM /(M1+M2)  )
        ELSE
          XHMOINS = SQRT(T) * VM * OVER1 *
     &    ( M1 + M2 + IHEL * 2.*M1 * PC * VM3 /(M1+M2)  )
        ENDIF
      ELSEIF (IMODEL.EQ.2) THEN
        XHMOINS = SQRT(T) *( 10.9 + M1*PC*0.521) *0.6269*
C    &  EXP( -0.0296*( Q2MAX - T) )
     &  EXP( -0.0145*( Q2MAX - T) )
      ELSEIF (IMODEL.EQ.3) THEN
        XHMOINS = SQRT(2.*T)*SQRT( M1**2+M2**2-T )
      ELSEIF (IMODEL.EQ.4) THEN
        XHMOINS = SQRT(T) * OVER1 *
     &  ( (M1 + M2)*VM2 + IHEL * 2.*M1 * PC * VM /(M1+M2)  )
      ELSEIF (IMODEL.EQ.5)THEN
      IF(J.LT.9)THEN
         XHMOINS=SQRT(Q2)*(F+IHEL*M1*PC*2.*GV)
      ELSEIF(J.EQ.9)THEN
         XHMOINS = SQRT(Q2)*(AL+IHEL*M1*PC*2.*QV)
      ELSEIF(J.EQ.11)THEN
         XHMOINS = SQRT(Q2)*(R+IHEL*M1*PC*2.*V)
      ENDIF
      ENDIF
 200  CONTINUE
 1    CONTINUE
      RETURN
      END
      FUNCTION XHPLUS (IMODEL,J,M1,M2,Q2)
C----------------------------------------------------------------------
C     A. FALVARD   -   130389
C
C!  H+ HELICITY AMPLITUDE FOR B OR D --> EL + NEUT +VECTOR MESON
C     comdecks referenced :  SEMLEP
C----------------------------------------------------------------------
      REAL M1,M2
      PARAMETER (NMODEL=5,NDECAY=11)
      COMMON/SEMLEP/IMOSEM,WTM(NMODEL,NDECAY),IHEL,KHEL,PRM1,PR0,PRP1,
     $          BBDAT(NDECAY),BXDAT(NDECAY)  ,
     $          NO1(NDECAY),NO2(NDECAY),OVER(NMODEL,NDECAY)
     $          , IMODSS,R1,R2,R3
      REAL MFF,MFF2,MFF3,MFF4
      COMMON/MFFX/MFF(NMODEL,NDECAY),MFF2(NMODEL,NDECAY),
     $            MFF3(NMODEL,NDECAY),MFF4(NMODEL,NDECAY)
      REAL MB,MD,MQ,MBOT,MX,MUP,MUM,MS,MSQ,MRSQ,KSQ
      COMMON /SCORA/MB,MD,MQ,MBOT,MX,MUP,MUM,MS,MSQ,MRSQ,KSQ
     *,BM,BMSQ,XMTSQ,BB,BX,XMT,BBX,BR,BRX
      COMMON /SCOROU/AL,CP,Q,QV
      XHPLUS=0.
      T=Q2
      Q2MAX = (M1-M2)**2
      IF(IMODEL.LE.4)THEN
         VM=MFF(IMODEL,J)**2/(MFF(IMODEL,J)**2-Q2)
         VM2=MFF2(IMODEL,J)**2/(MFF2(IMODEL,J)**2-Q2)
         VM3=MFF3(IMODEL,J)**2/(MFF3(IMODEL,J)**2-Q2)
         VM4=MFF4(IMODEL,J)**2/(MFF4(IMODEL,J)**2-Q2)
         OVER1=OVER(IMODEL,J)
      ENDIF
      PI=4.*ATAN(1.)
      QPLUS=(M1+M2)**2-Q2
      QMINS=(M1-M2)**2-Q2
      IF(QMINS.LT.0.)GOTO 1
      PC=SQRT(QPLUS*QMINS)/(2.*M1)
      IF(IMODEL.EQ.5)THEN
        Y=Q2/M1**2
        PX=PC
        TM=(BM-XMT)**2
        T=TM-Y*BMSQ
        FEX=EXP(-MSQ*T/(4.*KSQ*BBX))
      FEX1=FEX*((BB*BX/BBX)**1.5)*SQRT(MX/MBOT)
      GV1=0.5*(1./MQ-MD*BR/(2.*MUM*MX))
      F1=2.*MBOT
      GV=GV1*FEX1
      F=F1*FEX1
      AP=-0.5*FEX1/MX*(1.+MD/MB*((BB**2-BX**2)/(BB**2+BX**2))
     *-MD**2/(4.*MUM*MBOT)*BX**4/BBX**2)
      FEX5=FEX*((BB*BX/BBX)**2.5)*SQRT(MX/MBOT)
      QV=0.5*FEX5*MD/(MX*BB)
      AL=-FEX5*MBOT*BB*((1./MUM)+0.5*(MD/(MBOT*KSQ*
     &(BB**2)))*T*((1./MQ)-MD*BR/(2.*MUM*MX)))
      CP=FEX5*(MD*MB/(4.*BB*MBOT))*((1./MUM)-(MD*
     &MQ/(2.*MX*(MUM**2)))*BR)
      R=FEX5*MBOT*BB/(SQRT(2.)*MUP)
      SP=FEX5*MD/(SQRT(2.)*BB*MBOT)*(1.+MB/(2.*MUM)-MB*MD*MQ
     &/(4.*MUP*MUM*MX)*BR)
      V=FEX5*MBOT*BB/(4.*SQRT(2.)*MB*MQ*MX)
      FEX2=FEX1
      UP=FEX5*MD*MQ*MB/(SQRT(6.)*BB*MX*MUM)
        Q=FEX2*(1.+(MB/(2.*MUM))-MB*MQ*MD*BR/(4.*MUP*MUM*MX))
      ENDIF
C.. +* DECAY
C..SEMILEPTONIC B-->D,D* DECAY.
      IF(IMODEL.EQ.1) THEN
      IF(J.LT.7)THEN
          XHPLUS = SQRT(T) * VM * OVER1  *
     &    ( M1 + M2 - IHEL * 2.*M1 * PC * VM /(M1+M2)  )
        ELSE
          XHPLUS = SQRT(T) * VM * OVER1 *
     &    ( M1 + M2 - IHEL * 2.*M1 * PC * VM3 /(M1+M2)  )
        ENDIF
      ELSEIF (IMODEL.EQ.2) THEN
        XHPLUS = SQRT(T) *( 10.9 - M1*PC*0.521) *0.6269*
C    &  EXP( -0.0296*( Q2MAX - T) )
     &  EXP( -0.0145*( Q2MAX - T) )
      ELSEIF (IMODEL.EQ.3) THEN
        XHPLUS = SQRT(2.*T)*SQRT( M1**2+M2**2-T )
      ELSEIF (IMODEL.EQ.4) THEN
        XHPLUS = SQRT(T) * OVER1 *
     &  ( (M1 + M2)*VM2 - IHEL * 2.*M1 * PC * VM /(M1+M2)  )
      ELSEIF (IMODEL.EQ.5)THEN
      IF(J.LT.9)THEN
         XHPLUS=SQRT(Q2)*(F-IHEL*M1*PC*2.*GV)
      ELSEIF(J.EQ.9)THEN
         XHPLUS=SQRT(Q2)*(AL-IHEL*M1*PC*2.*QV)
      ELSEIF(J.EQ.11)THEN
         XHPLUS=SQRT(Q2)*(R-IHEL*M1*PC*2*V)
      ENDIF
      ENDIF
 200  CONTINUE
 1    CONTINUE
      RETURN
      END
      FUNCTION XHZERO (IMODEL,J,M1,M2,Q2)
C---------------------------------------------------------------------
C     A. FALVARD - 130389
C
C! H0 HELICITY AMPLITUDE FOR B OR D --> EL + NEUT + VECTOR MESON
C     comdecks referenced :  SEMLEP
C---------------------------------------------------------------------
      REAL M1,M2
      PARAMETER (NCUT=100)
      PARAMETER (NMODEL=5,NDECAY=11)
      COMMON/SEMLEP/IMOSEM,WTM(NMODEL,NDECAY),IHEL,KHEL,PRM1,PR0,PRP1,
     $          BBDAT(NDECAY),BXDAT(NDECAY)  ,
     $          NO1(NDECAY),NO2(NDECAY),OVER(NMODEL,NDECAY)
     $          , IMODSS,R1,R2,R3
      REAL MFF,MFF2,MFF3,MFF4
      COMMON/MFFX/MFF(NMODEL,NDECAY),MFF2(NMODEL,NDECAY),
     $            MFF3(NMODEL,NDECAY),MFF4(NMODEL,NDECAY)
      REAL MB,MD,MQ,MBOT,MX,MUP,MUM,MS,MSQ,MRSQ,KSQ
      COMMON /SCORA/MB,MD,MQ,MBOT,MX,MUP,MUM,MS,MSQ,MRSQ,KSQ
     *,BM,BMSQ,XMTSQ,BB,BX,XMT,BBX,BR,BRX
      COMMON /SCOROU/AL,CP,Q,QV
      XHZERO=0.
      Q2MAX = (M1-M2)**2
      T=Q2
      IF(IMODEL.LE.4)THEN
         VM=MFF(IMODEL,J)**2/(MFF(IMODEL,J)**2-Q2)
         VM2=MFF2(IMODEL,J)**2/(MFF2(IMODEL,J)**2-Q2)
         VM3=MFF3(IMODEL,J)**2/(MFF3(IMODEL,J)**2-Q2)
         VM4=MFF4(IMODEL,J)**2/(MFF4(IMODEL,J)**2-Q2)
         OVER1=OVER(IMODEL,J)
      ENDIF
      PI=4.*ATAN(1.)
      QPLUS=(M1+M2)**2-Q2
      QMINS=(M1-M2)**2-Q2
      IF(QMINS.LT.0.)GOTO 1
      PC=SQRT(QPLUS*QMINS)/(2.*M1)
      IF(IMODEL.EQ.5)THEN
        Y=Q2/M1**2
        PX=PC
        TM=(BM-XMT)**2
        T=TM-Y*BMSQ
        FEX=EXP(-MSQ*T/(4.*KSQ*BBX))
      FEX1=FEX*((BB*BX/BBX)**1.5)*SQRT(MX/MBOT)
      GV1=0.5*(1./MQ-MD*BR/(2.*MUM*MX))
      F1=2.*MBOT
      GV=GV1*FEX1
      F=F1*FEX1
      AP=-0.5*FEX1/MX*(1.+MD/MB*((BB**2-BX**2)/(BB**2+BX**2))
     *-MD**2/(4.*MUM*MBOT)*BX**4/BBX**2)
      FEX5=FEX*((BB*BX/BBX)**2.5)*SQRT(MX/MBOT)
      QV=0.5*FEX5*MD/(MX*BB)
      AL=-FEX5*MBOT*BB*((1./MUM)+0.5*(MD/(MBOT*KSQ*
     &(BB**2)))*T*((1./MQ)-MD*BR/(2.*MUM*MX)))
      CP=FEX5*(MD*MB/(4.*BB*MBOT))*((1./MUM)-(MD*
     &MQ/(2.*MX*(MUM**2)))*BR)
      R=FEX5*MBOT*BB/(SQRT(2.)*MUP)
      SP=FEX5*MD/(SQRT(2.)*BB*MBOT)*(1.+MB/(2.*MUM)-MB*MD*MQ
     &/(4.*MUP*MUM*MX)*BR)
      V=FEX5*MBOT*BB/(4.*SQRT(2.)*MB*MQ*MX)
      FEX2=FEX1
      UP=FEX5*MD*MQ*MB/(SQRT(6.)*BB*MX*MUM)
        Q=FEX2*(1.+(MB/(2.*MUM))-MB*MQ*MD*BR/(4.*MUP*MUM*MX))
      ENDIF
C.. 0* DECAY
      IF (IMODEL.EQ.1) THEN
        IF(J.LT.7) THEN
C..SEMILEPTONIC B-->D,D* DECAY.
          XHZERO = VM * OVER1 / M2 *
     &    ( (M1**2 - M2**2 -T) * (M1 + M2) /2. - 2. * M1**2 * PC**2
     &     * VM /(M1+M2))
        ELSE
          XHZERO = VM * OVER1 / M2 *
     &    ( (M1**2 - M2**2 -T) * (M1 + M2) /2. - 2. * M1**2 * PC**2
     &     * VM3 /(M1+M2))
        ENDIF
      ELSEIF (IMODEL.EQ.2) THEN
        XHZERO = 1./(2.*M2) * ( M1**2 - M2**2 - T) *10.90 *0.6269*
C    &   EXP( -0.0296*( Q2MAX - T) )
     &   EXP( -0.0145*( Q2MAX - T) )
      ELSEIF (IMODEL.EQ.3) THEN
        XHZERO = ( M1**2-M2**2-T) * SQRT(M1**2+M2**2-T) / (SQRT(2.)*M2)
      ELSEIF (IMODEL.EQ.4) THEN
        XHZERO = OVER1 / M2 *
     &  ( (M1**2 - M2**2 -T) * (M1 + M2)*VM2 / 2. - 2. * M1**2 * PC**2
     &   * VM4 /(M1+M2))
      ELSEIF(IMODEL.EQ.5)THEN
      IF(J.LT.9)THEN
          XHZERO=1./(2.*M2)*((M1**2-M2**2-Q2)*F
     *  +4.*M1**2*PC**2*AP)
      ELSEIF(J.EQ.9)THEN
          XHZERO=1./(2.*M2)*((M1**2-M2**2-Q2)*AL
     *    +4.*M1**2*PC**2*CP)
      ELSEIF(J.EQ.11)THEN
          XHZERO=1./(2.*M2)*((M1**2-M2**2-Q2)*R
     *    +4.*M1**2*PC**2*SP)
      ENDIF
      ENDIF
 200  CONTINUE
 1    CONTINUE
      RETURN
      END
