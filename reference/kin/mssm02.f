      SUBROUTINE ASKUSE (IDPR,ISTA,NTRK,NVRT,ECSS,WEIT)
C ------------------------------------------------------------
C -  B. Bloch  - March 1994
C! get an event from LUND 7.4
C  then transfer the information into KINE and VERT banks.
C -  Y. Gao    - Jan   1996
C! modified to be used to get an event from SUSYGEN & JETSET74
C  the argument of ECMS changed to ECSS
C
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
      Implicit None
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
      INTEGER    L1MST,L1PAR
     &          ,L2PAR,L2PARF
     &          ,LJNPAR
      PARAMETER (L1MST=200, L1PAR=200)
      PARAMETER (L2PAR=500, L2PARF=2000)
      PARAMETER (LJNPAR=4000)
      COMMON /LUDAT1/ MSTU(L1MST),PARU(L1PAR),MSTJ(L1MST),PARJ(L1PAR)
      INTEGER         MSTU,MSTJ
      REAL            PARU,PARJ
      COMMON /LUDAT2/ KCHG(L2PAR,3),PMAS(L2PAR,4),PARF(L2PARF),VCKM(4,4)
      INTEGER         KCHG
      REAL            PMAS,PARF,VCKM
      COMMON /LUDAT3/ MDCY(L2PAR,3),MDME(L2PARF,2),BRAT(L2PARF),
     &                KFDP(L2PARF,5)
      INTEGER         MDCY,MDME,KFDP
      REAL            BRAT
      COMMON /LUDAT4/ CHAF(L2PAR)
      CHARACTER*8     CHAF
      COMMON /LUJETS/ N7LU,K7LU(LJNPAR,5),P7LU(LJNPAR,5),V7LU(LJNPAR,5)
      INTEGER         N7LU,K7LU
      REAL            P7LU,V7LU
********************* start of commons of SUSYGEN **********************
      integer ievent
      common /eve/ ievent
      real*4  rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan(6)
      common /rkey/rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan

      real*8  gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu
      common/steer/gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu

      Integer modes,MIX
      common/mds/modes,MIX
      logical zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,higgs
      common/sparc/ zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,
     + higgs
      logical wrt,scan,lepi
      common/str/wrt,scan,lepi
      real*8  flum,ecm,s,roots,T,Q,Q2,EN
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
      real*8  QK
      COMMON/ISR/ QK(4)
      real erad,srad
      common/srada/erad(100),srad(100)
      integer  idbg,igener,irad
      COMMON /CONST/ idbg,igener,irad
      integer  index,index1,index2,nevt
      COMMON/INDEXX/index,index1,index2,nevt
      real*8   fmpr1,fmpr2,XCROST,APRO
      COMMON/FINDEX/fmpr1,fmpr2,XCROST,APRO
      real*8   cosphimix,facqcd,fgama,spartmas,ratq
      common/mixings/cosphimix,facqcd,fgama,spartmas,ratq
      real*8   FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +         FLC,FRC,gms,echar
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
      real*8      TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      real*8   fmal,fmar,ratqa,fgamc,fgamcr,cosmi
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)

      real*4 gmas,phimx
      common/stopmix/gmas(3),phimx(3)
      real*4 phimix1,stop1,phimix2,sbot1,phimix3,stau1
      equivalence (gmas(1),stop1)
      equivalence (gmas(2),sbot1)
      equivalence (gmas(3),stau1)
      equivalence (phimx(1),phimix1)
      equivalence (phimx(2),phimix2)
      equivalence (phimx(3),phimix3)
      real*4 gmas2
      common/stopmix2/gmas2(3)
      real*4 stop2,sbot2,stau2
      equivalence (gmas2(1),stop2)
      equivalence (gmas2(2),sbot2)
      equivalence (gmas2(3),stau2)
      real*4 rscale
      common/sscale/rscale
      logical imsg                      !Added by S.A. for use in the
      common/imessage/imsg              !NTONPH routine

      double precision sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      common/higgses/sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      logical fix_higgs_masses
      common/ steerhiggs / fix_higgs_masses

      integer jdebu,idb1,idb2,lout
      common /debuc/ jdebu,idb1,idb2,lout

      real*8   xgaug,xeta
      COMMON/XCROS/xgaug(8),xeta(8)

      integer  ispa,kl,klap,idecs,klr
      common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
C 04/96 P.Morawitz & M.Williams introduce klr for Rpv gaugino decays
      common/reord2/klr(3,24)
c klr(1,n), klr(2,n) and klr(3,n) are the particles produced in
c R-parity violating decays of gauginos...
C n=1..4 , 5..8	 LLE neutralino,gaugino decays
C n=9..12,13..16 LQD neutralino,gaugino decays
C n=17.20,21..24 UDD neutralino,gaugino decays

      Integer  idecsel,ihigsel
      common/decsel/idecsel(23)
      common/higsel/ihigsel(5)
C 05/96 P.Morawitz
C ...   NOTE: the logical below is used in SUSYGEN V1.5 (April 96)
C       MSSM has its own implementation of R-parity violation.
C       The logical rpar is therefore always set to TRUE which avoids
C       the SUSYGEN R-parity code.
        logical rpar
        common/rpari/rpar
      real*8   brsum,brsuma
CPM      common/brsum/ brsum(5,6,6),brsuma(6)
C 04/96 P.Morawitz & M.Williams  changed brsum to allow for r-parity dec
      common/brsum/ brsum(13,7,6),brsuma(6)
************************************************************************
c EXPLANATION OF INDICES IN BRSUM(itype,igout,igin)
c
c igin  = 1,6 initial gaugino (neutralinos 1..4, charginos 1,2)
c igout = 1,7 outgoing gaugino
c ........where 7 => no outgoing gaugino ie. R-parity violating process
c itype = types of particles produced
c     1 - l+ l-    6 - l q qbar   10 - q q q'         12 - l+ l+ l-
c     2 - v vbar   7 - l q' qbar  11 - qbar qbar qbar 13 - l v v
c     3 - q qbar   8 - v q qbar
c     4 - l v      9 - v q' qbar
c     5 - q' qbar
************************************************************************
      real*8   fms,fmi,fmk,fml1,fml2,etai,etak,brspa
     +        ,brgaug,fmelt,fmert,fmelu,fmeru
      Integer  lind
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
CPM     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
     +lind(6,6,6),brgaug(6,7,11,3),fmelt,fmert,fmelu,fmeru
C 04/96 P.Morawitz & M.Williams  changed brgaug to allow for r-parity de

************************************************************************
c     EXPLANATIONS OF INDICES IN BRGAUG AND BRSPA
c
c BRSPA::
c kgaug =1,6 produced gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c kspar =1,24 initial sparticle
c     1,12  : left-handed sparticle  (u,d,v,e,c,s,v,mu,t,b,v,tau)
c     12,24 : right handed sparticle (u,d,v,e,c,s,v,mu,t,b,v,tau)
c
c BRGAUG::
c igin =1,6 parent gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c igout =1,7 daughter gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c     7    : none (ie. R-parity violating process)
c ipart =1,6 for produced particles .....
c     R-parity conserving decays
c     1,4  : uu,dd,vv,ee                                  - 'like to lik
c     5,6  : ud,ev                                        - 'like to unl
C ipart =7,11 for the 5 diagrams which involve
C             gaugino -> gaugino' gamma
C	      gaugino -> Higgs X
C
C
C ipart =1,8 for Rp-violating!!!! decays (igout=7)
c     R-parity violating decays via LLE operator
c     1,4 :                                               - for neutrali
c     5,8 : l+ l+ l, v v l+, vbar l+ v, l+ vbar v         - for chargino
c     R-parity violating decays via LQD operator
c     1,4  : e+ u dbar, e- ubar d, v d dbar, vbar dbar d  - for neutrali
c     5,8  : v u dbar, e+ dbar d, e+ ubar u, vbar dbar u  - for chargino
c     R-parity violating decays via UDD operator
c     1,4  :						  - for neutralinos
c     5,8  : u u d, u d u, dbar dbar dbar                 - for chargino
c igen =1,3
c     R-parity conserving decays : generation of produced particles
c     R-parity violating decays  : meaningless, i.e. only igen=1 used
************************************************************************
      Real*8   zr,was,esa
      Real*8   VOIJL,VOIJR,gfir,gfil
      COMMON/NEUMIX/ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
      real*8   OIJL,OIJR,V,U,FM,ETA
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      real*8   oijlp,oijrp
      COMMON/CHANEU/oijlp(4,2),oijrp(4,2)
      Integer       ILOOP
      COMMON/SFLOOP/ILOOP
      Real*8   PV
      Integer  IFLAV,NFLAV
CPM      COMMON /PARTC / PV(5,20),IFLAV(20,2),NFLAV
CPM      update to SUSYGEN V1.5
      COMMON /PARTC / pv(5,30)
      COMMON /PARTC1 / iflav(30,2),nflav


      real*8   gw,widfl,widfr,fmeltw,fmertw,fmeluw,fmeruw,gent,gentl
      integer  linda
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,7,6)
CPM     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
C 04/96 P.Morawitz & M.Williams  changed linda to allow for r-parity dec

      integer topo_charg,topo_neut
      common /topocom/ topo_charg,topo_neut

********************* end  of commons of SUSYGEN ***********************

      Integer       IPRI,IHST
      Real          ECMS,SVERT
      Integer       mact
      Parameter    (mact=100)
      Integer       nact,iact
      Real          sact,wact
      common/SUWGHT/IPRI,ECMS,SVERT(3)
     &             ,nact,iact(mact)
     &                  ,sact(mact)
     &                  ,wact(mact)


      Integer       IDPR,ISTA,NTRK,NVRT,IST
      Real          ECSS,WEIT

      Real          RTEST,IDUMM
      Real          RX,RY,RZ,RE
      Real          VRTX(4)
      Integer       i
      Integer       IG,JG
      Real          XC
      Integer       IFI
      Data          IFI/0/
      Save          IFI
      Real          RNDM
      External      RNDM
      real pmax
C ------------------------------------------------------------------
C
      ISTA = 0
C
C     Reset entries in /LUJETS/
C     =========================================
      N7LU = 0
C
C     Reset fragmentation storage in common
C     =====================================
      MSTU(90) = 0
C
C     get the process number
C     ======================
10    continue
      RTEST=RNDM(IDUMM)
      i=1
      do while(RTEST.gt.wact(i).and.i.lt.nact)
        i=i+1
      enddo
      IDPR=iact(i)
C
C     get one event from SUSYGEN
C     ==========================
      IG=1
      ievent=ifi+1
      call SUMSSM(IDPR,IG,JG,XC)
      if( JG.eq.0 ) goto 10

      ECSS = ECM
      WEIT = 1.0
      IFI  = IFI +1

      IF((IFI.ge.IDB1).and.(IFI.le.IDB2))    call LULIST(1)
C ... now check that all the particles give non non-sense momentum
      pmax=ECMS/2.
      DO I= 1,N7LU
      if ((P7LU(I,1).gt.pmax).or.((P7LU(I,2).gt.pmax)
     +                  .or.(P7LU(I,3).gt.pmax))) then
         call LULIST(2)
         write (*,*) ' screwed up event - ',IFI
         write (*,*) 'event info - (p)',P7LU(I,1),P7LU(I,2),P7LU(I,3)
         stop
      endif
      ENDDO
C ...
C
C     fill BOS banks
C     ==============
C -   get the primary vertex
      CALL RANNOR (RX,RY)
      CALL RANNOR (RZ,RE)
      VRTX(1) = RX*SVERT(1)
      VRTX(2) = RY*SVERT(2)
      VRTX(3) = RZ*SVERT(3)
      VRTX(4) = 0.
C -   Call the specific routine KXL7AL to fill BOS banks
      CALL KZFRBK (IST)
      CALL KXL7AL (VRTX,ISTA,NVRT,NTRK)
C -   book fragmentation info
      CALL KZFRBK (IST)
      IF ( IST.ne.0) ista = ista+ist
      END
      SUBROUTINE ASKUSI(IGCOD)
C ------------------------------------------------------------------
C - Y. GAO    - Jan 1996
C! Initialization routine of SUSYGEN & JETSET7.4  generator
C
C ------------------------------------------------------------------
      Implicit None

C     IGCOD  for MSSM01
      Integer       IGCO
      PARAMETER    (IGCO=7021)
      Integer       IGCOD

      Real          FVERS
      DATA          FVERS/
     $2.01

     $                   /
      CHARACTER*30  DATE
      DATA DATE/
     $ 'January 8 ,1998'
     $/
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
      Integer       MXIDHS
      Parameter    (MXIDHS=500)
      Integer       NIDOLD,IIDOLD,NIDNEW,IIDNEW
      Logical       HSKEEP
      Common/WORKHS/HSKEEP,NIDOLD,IIDOLD(MXIDHS),NIDNEW,IIDNEW(MXIDHS)
      INTEGER    L1MST,L1PAR
     &          ,L2PAR,L2PARF
     &          ,LJNPAR
      PARAMETER (L1MST=200, L1PAR=200)
      PARAMETER (L2PAR=500, L2PARF=2000)
      PARAMETER (LJNPAR=4000)
      COMMON /LUDAT1/ MSTU(L1MST),PARU(L1PAR),MSTJ(L1MST),PARJ(L1PAR)
      INTEGER         MSTU,MSTJ
      REAL            PARU,PARJ
      COMMON /LUDAT2/ KCHG(L2PAR,3),PMAS(L2PAR,4),PARF(L2PARF),VCKM(4,4)
      INTEGER         KCHG
      REAL            PMAS,PARF,VCKM
      COMMON /LUDAT3/ MDCY(L2PAR,3),MDME(L2PARF,2),BRAT(L2PARF),
     &                KFDP(L2PARF,5)
      INTEGER         MDCY,MDME,KFDP
      REAL            BRAT
      COMMON /LUDAT4/ CHAF(L2PAR)
      CHARACTER*8     CHAF
      COMMON /LUJETS/ N7LU,K7LU(LJNPAR,5),P7LU(LJNPAR,5),V7LU(LJNPAR,5)
      INTEGER         N7LU,K7LU
      REAL            P7LU,V7LU
********************* start of commons of SUSYGEN **********************
      integer ievent
      common /eve/ ievent
      real*4  rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan(6)
      common /rkey/rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan

      real*8  gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu
      common/steer/gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu

      Integer modes,MIX
      common/mds/modes,MIX
      logical zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,higgs
      common/sparc/ zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,
     + higgs
      logical wrt,scan,lepi
      common/str/wrt,scan,lepi
      real*8  flum,ecm,s,roots,T,Q,Q2,EN
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
      real*8  QK
      COMMON/ISR/ QK(4)
      real erad,srad
      common/srada/erad(100),srad(100)
      integer  idbg,igener,irad
      COMMON /CONST/ idbg,igener,irad
      integer  index,index1,index2,nevt
      COMMON/INDEXX/index,index1,index2,nevt
      real*8   fmpr1,fmpr2,XCROST,APRO
      COMMON/FINDEX/fmpr1,fmpr2,XCROST,APRO
      real*8   cosphimix,facqcd,fgama,spartmas,ratq
      common/mixings/cosphimix,facqcd,fgama,spartmas,ratq
      real*8   FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +         FLC,FRC,gms,echar
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
      real*8      TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      real*8   fmal,fmar,ratqa,fgamc,fgamcr,cosmi
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)

      real*4 gmas,phimx
      common/stopmix/gmas(3),phimx(3)
      real*4 phimix1,stop1,phimix2,sbot1,phimix3,stau1
      equivalence (gmas(1),stop1)
      equivalence (gmas(2),sbot1)
      equivalence (gmas(3),stau1)
      equivalence (phimx(1),phimix1)
      equivalence (phimx(2),phimix2)
      equivalence (phimx(3),phimix3)
      real*4 gmas2
      common/stopmix2/gmas2(3)
      real*4 stop2,sbot2,stau2
      equivalence (gmas2(1),stop2)
      equivalence (gmas2(2),sbot2)
      equivalence (gmas2(3),stau2)
      real*4 rscale
      common/sscale/rscale
      logical imsg                      !Added by S.A. for use in the
      common/imessage/imsg              !NTONPH routine

      double precision sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      common/higgses/sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      logical fix_higgs_masses
      common/ steerhiggs / fix_higgs_masses

      integer jdebu,idb1,idb2,lout
      common /debuc/ jdebu,idb1,idb2,lout

      real*8   xgaug,xeta
      COMMON/XCROS/xgaug(8),xeta(8)

      integer  ispa,kl,klap,idecs,klr
      common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
C 04/96 P.Morawitz & M.Williams introduce klr for Rpv gaugino decays
      common/reord2/klr(3,24)
c klr(1,n), klr(2,n) and klr(3,n) are the particles produced in
c R-parity violating decays of gauginos...
C n=1..4 , 5..8	 LLE neutralino,gaugino decays
C n=9..12,13..16 LQD neutralino,gaugino decays
C n=17.20,21..24 UDD neutralino,gaugino decays

      Integer  idecsel,ihigsel
      common/decsel/idecsel(23)
      common/higsel/ihigsel(5)
C 05/96 P.Morawitz
C ...   NOTE: the logical below is used in SUSYGEN V1.5 (April 96)
C       MSSM has its own implementation of R-parity violation.
C       The logical rpar is therefore always set to TRUE which avoids
C       the SUSYGEN R-parity code.
        logical rpar
        common/rpari/rpar
      real*8   brsum,brsuma
CPM      common/brsum/ brsum(5,6,6),brsuma(6)
C 04/96 P.Morawitz & M.Williams  changed brsum to allow for r-parity dec
      common/brsum/ brsum(13,7,6),brsuma(6)
************************************************************************
c EXPLANATION OF INDICES IN BRSUM(itype,igout,igin)
c
c igin  = 1,6 initial gaugino (neutralinos 1..4, charginos 1,2)
c igout = 1,7 outgoing gaugino
c ........where 7 => no outgoing gaugino ie. R-parity violating process
c itype = types of particles produced
c     1 - l+ l-    6 - l q qbar   10 - q q q'         12 - l+ l+ l-
c     2 - v vbar   7 - l q' qbar  11 - qbar qbar qbar 13 - l v v
c     3 - q qbar   8 - v q qbar
c     4 - l v      9 - v q' qbar
c     5 - q' qbar
************************************************************************
      real*8   fms,fmi,fmk,fml1,fml2,etai,etak,brspa
     +        ,brgaug,fmelt,fmert,fmelu,fmeru
      Integer  lind
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
CPM     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
     +lind(6,6,6),brgaug(6,7,11,3),fmelt,fmert,fmelu,fmeru
C 04/96 P.Morawitz & M.Williams  changed brgaug to allow for r-parity de

************************************************************************
c     EXPLANATIONS OF INDICES IN BRGAUG AND BRSPA
c
c BRSPA::
c kgaug =1,6 produced gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c kspar =1,24 initial sparticle
c     1,12  : left-handed sparticle  (u,d,v,e,c,s,v,mu,t,b,v,tau)
c     12,24 : right handed sparticle (u,d,v,e,c,s,v,mu,t,b,v,tau)
c
c BRGAUG::
c igin =1,6 parent gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c igout =1,7 daughter gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c     7    : none (ie. R-parity violating process)
c ipart =1,6 for produced particles .....
c     R-parity conserving decays
c     1,4  : uu,dd,vv,ee                                  - 'like to lik
c     5,6  : ud,ev                                        - 'like to unl
C ipart =7,11 for the 5 diagrams which involve
C             gaugino -> gaugino' gamma
C	      gaugino -> Higgs X
C
C
C ipart =1,8 for Rp-violating!!!! decays (igout=7)
c     R-parity violating decays via LLE operator
c     1,4 :                                               - for neutrali
c     5,8 : l+ l+ l, v v l+, vbar l+ v, l+ vbar v         - for chargino
c     R-parity violating decays via LQD operator
c     1,4  : e+ u dbar, e- ubar d, v d dbar, vbar dbar d  - for neutrali
c     5,8  : v u dbar, e+ dbar d, e+ ubar u, vbar dbar u  - for chargino
c     R-parity violating decays via UDD operator
c     1,4  :						  - for neutralinos
c     5,8  : u u d, u d u, dbar dbar dbar                 - for chargino
c igen =1,3
c     R-parity conserving decays : generation of produced particles
c     R-parity violating decays  : meaningless, i.e. only igen=1 used
************************************************************************
      Real*8   zr,was,esa
      Real*8   VOIJL,VOIJR,gfir,gfil
      COMMON/NEUMIX/ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
      real*8   OIJL,OIJR,V,U,FM,ETA
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      real*8   oijlp,oijrp
      COMMON/CHANEU/oijlp(4,2),oijrp(4,2)
      Integer       ILOOP
      COMMON/SFLOOP/ILOOP
      Real*8   PV
      Integer  IFLAV,NFLAV
CPM      COMMON /PARTC / PV(5,20),IFLAV(20,2),NFLAV
CPM      update to SUSYGEN V1.5
      COMMON /PARTC / pv(5,30)
      COMMON /PARTC1 / iflav(30,2),nflav


      real*8   gw,widfl,widfr,fmeltw,fmertw,fmeluw,fmeruw,gent,gentl
      integer  linda
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,7,6)
CPM     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
C 04/96 P.Morawitz & M.Williams  changed linda to allow for r-parity dec

      integer topo_charg,topo_neut
      common /topocom/ topo_charg,topo_neut

********************* end  of commons of SUSYGEN ***********************

      Integer       mproc
      Parameter    (mproc=35)
      Integer       iproc,iprod,ipar1,ipar2,ihand,isusy,iopen,ievnt
      Real          xproc
      common/SUPROC/iproc(mproc),iprod(mproc)
     &             ,ipar1(mproc),ipar2(mproc)
     &             ,ihand(mproc),isusy(mproc)
     &             ,iopen(mproc),ievnt(mproc)
     &             ,xproc(mproc)
      Integer       IPRI,IHST
      Real          ECMS,SVERT
      Integer       mact
      Parameter    (mact=100)
      Integer       nact,iact
      Real          sact,wact
      common/SUWGHT/IPRI,ECMS,SVERT(3)
     &             ,nact,iact(mact)
     &                  ,sact(mact)
     &                  ,wact(mact)


      Integer       IUT
      Real          TABL(100)
      Integer       NWBL,INDL
      Integer       IEBEAM,JRLEP,ALTABL,ALRLEP
      External                   ALTABL,ALRLEP
      Integer       IPART,IKLIN,IDBNK
      Integer       NLINK,NAMIND
      External      NLINK,NAMIND
      Integer       LUCOMP
      External      LUCOMP

      Integer       mfail,i,j
      Real          XC,XT,PHOCHA,CHA,PHOSPI,SPI
      Integer       IG,JG

      Integer       ID

      INTEGER LPDEC,MXDEC,JIDB
      PARAMETER (LPDEC=48)
      INTEGER NODEC(LPDEC),KNODEC
      EXTERNAL KNODEC,PHOCHA,PHOSPI
      CHARACTER*16 CHAU
C      fsr ntuple ...
      CHARACTER*8 ZCVAR(5)
      DATA ZCVAR / 'ENERGY','IDMOTHER','CHAMOT','MAMOTH','KEVT'/
C*CA BDECL
C*CA BMACRO
C
C     LOG unit
C     ========
      IUT = IW(6)
C
C     Return generator code IGCOD
C     ===========================
      IGCOD = IGCO
      WRITE(IUT,1002)
      WRITE(IUT,1000)
      WRITE(IUT,1001) FVERS,DATE
      WRITE(IUT,1003) IGCOD
      WRITE(IUT,1002)
C force to load modified codes from photos
      IF ( IGCOD.lt.7000) then
         call luname(75,chau)
         call phochk(75)
         cha = phocha(75)
         spi = phospi(75)
      ENDIF
C      DEBU card
      JDEBU = IW(NAMIND('DEBU'))
      IF(JDEBU.NE.0) THEN
         IDB1 = IW(JDEBU+1)
         IDB2 = IW(JDEBU+2)
         LOUT = IW(JDEBU-2)
      ENDIF
C
C     GENE card
C     =========
      IDBNK = NLINK('GENE',0)
      if( IDBNK.gt.0 ) then
        ECMS = RW(IDBNK+1)
        IPRI = IW(IDBNK+2)
        IHST = IW(IDBNK+3)
      else
        write(IUT,*) 'ASKUSI: no GENE card given',
     &               'default values are taken'
        ECMS = 200.0
        IPRI = 10
        IHST =  0
      endif
      HSKEEP=.false.
      if( IHST.eq.1 )   HSKEEP=.true.
      recm  = ECMS
      rflum = 0.0      ! we don't use luminosity but no. of events
C
C     make use of a smearing of the vertex
C     ====================================
      IDBNK = NLINK('SVRT',0)
      IF( IDBNK.gt.0 ) then
         SVERT(1) = RW(IDBNK+1)
         SVERT(2) = RW(IDBNK+2)
         SVERT(3) = RW(IDBNK+3)
      ELSE
         SVERT(1) = 0.018
         SVERT(2) = 0.001
         SVERT(3) = 0.7
      ENDIF
C
C     initialize LUND
C     ===============
C -   keep fragmentation info
      MSTU(17) = 1
C -   Final   state radiation
      MSTJ(41) = 2
C -   use non discrete masses for resonnances
      MSTJ(24) = 2
C -   SLAC fragm. functions for b,c  Symetric LUND for u,d,s
      MSTJ(11) = 3
C -   mod to lund fragm. functions params
      PARJ ( 21)  =0.358
      PARJ  (41)  =0.500
      PARJ  (42)  =0.840
      PARJ  (81)  =0.310
      PARJ  (82)  =1.500
C -   mod Peterson's fragm. functions params
      PARJ  (54)  = -0.200
      PARJ  (55)  = -0.006
      PARU (102)  =  0.232
      PARJ (123)  =  91.17
      PARU (124)  =  2.5
C -   Set up some default values for masses and initial conditions
C -   HIGGS Mass , TOP Mass and Z0 mass defined, can be overwritten by
C -   a PMA1 card
      PMAS(LUCOMP(25),1)= 100.
      PMAS(LUCOMP( 6),1)= 174.
      PMAS(LUCOMP(23),1)= 91.2
C
C ... book the FSR ntuple
      CALL HBOOKN(5010,'gammas',5,' ',4000,ZCVAR)
C     save the histo-ids have been booked
C     ===================================
      call HIDALL(IIDOLD,NIDOLD)
C
C     get the SUSYGEN parameters from data card
C     =========================================
      CALL SUSYGDAT
      call SUCARD
C
C     set SUSY-particle's name, charge etc
C     ====================================
      call SUPART
C
C     generate mass & decay branching ratios etc
C     ==========================================
      call SUSANA(IUT,mfail)
      if( mfail.ne.0 ) then
        write(IUT,*) 'ASKUSI: SUSANA error, -stop-'
        call EXIT
      endif
      call SUSETM

C
C     complete PART bank with LUND  particles
C     use the library routine KXL74A
C     it should work even for the SUSYGEN particles included
C     ======================================================
      CALL KXL74A (IPART,IKLIN)
      IF (IPART.LE.0 .OR. IKLIN.LE.0) THEN
        WRITE(IUT,*) 'ASKUSI: error in PART or KLIN bank -STOP -'
        CALL EXIT
      ENDIF

      IF ( MOD(IPRI,10).GT.0) THEN
         CALL PRPART
      ENDIF
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
         DO 10 I=1,MXDEC
            IF (NODEC(I).GT.0) THEN
               JIDB = NLINK('MDC1',NODEC(I))
               IF (JIDB .EQ. 0) MDCY(LUCOMP(NODEC(I)),1) = 0
            ENDIF
   10    CONTINUE
      ENDIF
C
C     save the working histograms created by SUSYGEN
C     ==============================================
      call HIDALL(IIDNEW,NIDNEW)
C
C     calculate cross-sections for each process
C     =========================================
      nact=0
      IG  =0
      XT  =0.0
      do i=1,mproc
        call SUMSSM(i,IG,JG,XC)
        xproc(i)=XC
        if( xproc(i).gt.0.0 .and. iopen(i).eq.1 ) then
          nact      =nact+1
          iact(nact)=i
          sact(nact)=xproc(i)
          XT        =XT+sact(nact)
        endif
      enddo
C
C     give a summary of initialization
C     ================================
      call SUPRNT(1)
C
C     no active process
C     =================
      if( nact.eq.0 ) then
        write(IUT,*) 'ASKUSI: all processes have been switched off'
        write(IUT,*) '            or the ECMS below threshold     '
        write(IUT,*) '               stop after the summary       '
        call SUPRNT(2)
        write(IUT,*) '                      -STOP-                '
        call EXIT
      endif
C
C     check the parameter space has been excluded by LEPI searches or no
C     ==================================================================
      call LEPLIM(mfail)
      if( mfail.ne.0 ) then
        write(IUT,*) 'Warning: The parameters chosen for this run '
        write(IUT,*) '         has been excluded by LEPI searches '
        if( LEPI ) then
        write(IUT,*) '              stop after the summary        '
        call SUPRNT(2)
        write(IUT,*) '                      -STOP-                '
        call EXIT
        else
        write(IUT,*) '                    _CONTINUE-              '
        endif
      endif
C
C     get the generation weights
C     ==========================
      wact(1)=sact(1)/XT
      do i=2,nact
        wact(i)=sact(i)/XT+wact(i-1)
      enddo
C
C     dump the generator parameters for this run in a bank
C     assume all parameters are real and stored as a single row
C     =========================================================
      call VZERO(TABL,100)
      NWBL = 0
C -   1:35 cross sections for process 1-35. =0 if not permitted or off
      do i=1,nact
        TABL(iact(i)) = sact(i)
      enddo
      NWBL = NWBL+35
C -   MSSM parameters: 5 words
      TABL(NWBL+ 1) = TANB
      TABL(NWBL+ 2) = FMGAUG
      TABL(NWBL+ 3) = FMR
      TABL(NWBL+ 4) = FM0
      TABL(NWBL+ 5) = ATRI
      NWBL = NWBL+ 5
C -   neutralino mass matrix: 16 words
      do i=1,4
      do j=1,4
        NWBL = NWBL+1
        TABL(NWBL) = zr(j,i)
      enddo
      enddo
C -   chargino mass matrix u,v : 8 words
      do i=1,2
      do j=1,2
        NWBL = NWBL+1
        TABL(NWBL) = U(j,i)
      enddo
      enddo

      do i=1,2
      do j=1,2
        NWBL = NWBL+1
        TABL(NWBL) = V(j,i)
      enddo
      enddo
C -   finally the smearing vertex
      TABL(NWBL+1) = SVERT(1)
      TABL(NWBL+2) = SVERT(2)
      TABL(NWBL+3) = SVERT(3)
      NWBL = NWBL + 3
      TABL(NWBL+1) = ECMS
      NWBL = NWBL + 1
      INDL = ALTABL('KPAR',NWBL,1,TABL,'2I,(F)','C')
C
C     Fill RLEP bank
C     ==============
      IEBEAM = NINT(ECM* 500  )
      JRLEP  = ALRLEP(IEBEAM,'    ',0,0,0)
      CALL PRTABL('RLEP',0)
      IF ( IPRI.GT.0 ) CALL PRTABL('KPAR',0)
1000  FORMAT(/,10X,'* WELCOME TO SUSYGEN/JETSET7.4 as MSSM02',
     &       /,10X,'*   (Ref: ALEPH 97-045 MCARLO 97-002 ) ' )
1001  FORMAT(  10X,'* ','Version ',F6.2,' -Last modified on   ',A30)
1002  FORMAT(  10X,72('*'))
1003  FORMAT(/,10X,'* MSSM02 - CODE NUMBER = ',I10)
      RETURN
      END
      SUBROUTINE UGTSEC
C-----------------------------------------
C
C   Author   :- bloch                 28-APR-1995
C
C=========================================
C
C   Purpose   : DUMMY ROUTINE FOR SOME UNIX MACHINES
C   Inputs    :
C   Outputs   :
C
C=========================================
C +
C Declarations.
C -
      IMPLICIT NONE
C + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + + +
C Entry Point.
C - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      PRINT * ,
     &
     &  '   UGTSEC : THIS IS A DUMMY ROUTINE ',
     &  ' may be replaced by a piece of code someday ... '
C
  999 RETURN
      END
      subroutine interf
****$****|****$****|****$****|****$****|****$****|****$****|****$****|**
*-- Author :    Stavros Katsanevas   14/04/95                          *
*-- 01/02/96 modified by Y.GAO
*     - bugfixes
*
*-- ../04/96 P.Morawitz & M.Williams
*--   - modified to include R-parity violating decays
*
*-- 22/05/96 P.Morawitz
*     - updated to SUSYGEN_V1.5 (April 96 release)
*       now includes gaugino -> gamma,higgs gaugino' decays and
*       mod. for 3-rd generation scalar decays
*
*     - Bugfix "For down-type squark and for slepton decay,
*              the wrong charginos sign is selected."
****$****|****$****|****$****|****$****|****$****|****$****|****$****|**
      PARAMETER (NOUT=33)
      INTEGER IDOUT(NOUT)

      SAVE /SSMODE/
C          SM ( JETSET 7.03 ) ident code definitions.
      INTEGER IDUP,IDDN,IDST,IDCH,IDBT,IDTP
      INTEGER IDNE,IDE,IDNM,IDMU,IDNT,IDTAU
      INTEGER IDGL,IDGM,IDW,IDZ

      PARAMETER (IDUP=2,IDDN=1,IDST=3,IDCH=4,IDBT=5,IDTP=6)
      PARAMETER (IDNE=12,IDE=11,IDNM=14,IDMU=13,IDNT=16,IDTAU=15)
      PARAMETER (IDGL=21,IDGM=22,IDW=24,IDZ=23)

      PARAMETER (ISUPL=42,ISDNL=41,ISSTL=43,ISCHL=44,ISBTL=45,ISTPL=46)
      PARAMETER (ISNEL=52,ISEL=51,ISNML=54,ISMUL=53,ISNTL=56,ISTAUL=55)
      PARAMETER (ISUPR=48,ISDNR=47,ISSTR=49,ISCHR=50,ISBTR=61,ISTPR=62)
      PARAMETER (ISER=57,ISMUR=58,ISTAUR=59)
      PARAMETER (ISGL=70)
      PARAMETER (ISZ1=71,ISZ2=72,ISZ3=73,ISZ4=74,ISW1=75,ISW2=76)
      PARAMETER (ISWN1=77,ISWN2=78,ISHL=25,ISHH=35,ISHA=36,ISHC=37)

      DATA IDOUT/
     +ISZ1,ISZ2,ISZ3,ISZ4,ISW1,ISW2,
     +ISGL,ISUPL,ISDNL,ISSTL,ISCHL,ISBTL,ISTPL,ISUPR,ISDNR,
     +ISSTR,ISCHR,ISBTR,ISTPR,ISEL,ISMUL,ISTAUL,ISNEL,ISNML,ISNTL,
     +ISER,ISMUR,ISTAUR,ISHL,ISHH,ISHA,ISHC,IDTP/

C          MXSS                 = maximum number of modes
C          NSSMOD               = number of modes
C          ISSMOD               = initial particle
C          JSSMOD               = final particles
C          GSSMOD               = width
C          BSSMOD               = branching ratio
      INTEGER MXSS
      PARAMETER (MXSS=2000)
      COMMON/SSMODE/NSSMOD,ISSMOD(MXSS),JSSMOD(5,MXSS)
      COMMON/SSMOD1/GSSMOD(MXSS),BSSMOD(MXSS)
      INTEGER NSSMOD,ISSMOD,JSSMOD
      DOUBLE PRECISION GSSMOD,BSSMOD


********************* start of commons of SUSYGEN **********************
      integer ievent
      common /eve/ ievent
      real*4  rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan(6)
      common /rkey/rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan

      real*8  gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu
      common/steer/gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu

      Integer modes,MIX
      common/mds/modes,MIX
      logical zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,higgs
      common/sparc/ zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,
     + higgs
      logical wrt,scan,lepi
      common/str/wrt,scan,lepi
      real*8  flum,ecm,s,roots,T,Q,Q2,EN
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
      real*8  QK
      COMMON/ISR/ QK(4)
      real erad,srad
      common/srada/erad(100),srad(100)
      integer  idbg,igener,irad
      COMMON /CONST/ idbg,igener,irad
      integer  index,index1,index2,nevt
      COMMON/INDEXX/index,index1,index2,nevt
      real*8   fmpr1,fmpr2,XCROST,APRO
      COMMON/FINDEX/fmpr1,fmpr2,XCROST,APRO
      real*8   cosphimix,facqcd,fgama,spartmas,ratq
      common/mixings/cosphimix,facqcd,fgama,spartmas,ratq
      real*8   FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +         FLC,FRC,gms,echar
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
      real*8      TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      real*8   fmal,fmar,ratqa,fgamc,fgamcr,cosmi
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)

      real*4 gmas,phimx
      common/stopmix/gmas(3),phimx(3)
      real*4 phimix1,stop1,phimix2,sbot1,phimix3,stau1
      equivalence (gmas(1),stop1)
      equivalence (gmas(2),sbot1)
      equivalence (gmas(3),stau1)
      equivalence (phimx(1),phimix1)
      equivalence (phimx(2),phimix2)
      equivalence (phimx(3),phimix3)
      real*4 gmas2
      common/stopmix2/gmas2(3)
      real*4 stop2,sbot2,stau2
      equivalence (gmas2(1),stop2)
      equivalence (gmas2(2),sbot2)
      equivalence (gmas2(3),stau2)
      real*4 rscale
      common/sscale/rscale
      logical imsg                      !Added by S.A. for use in the
      common/imessage/imsg              !NTONPH routine

      double precision sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      common/higgses/sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      logical fix_higgs_masses
      common/ steerhiggs / fix_higgs_masses

      integer jdebu,idb1,idb2,lout
      common /debuc/ jdebu,idb1,idb2,lout

      real*8   xgaug,xeta
      COMMON/XCROS/xgaug(8),xeta(8)

      integer  ispa,kl,klap,idecs,klr
      common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
C 04/96 P.Morawitz & M.Williams introduce klr for Rpv gaugino decays
      common/reord2/klr(3,24)
c klr(1,n), klr(2,n) and klr(3,n) are the particles produced in
c R-parity violating decays of gauginos...
C n=1..4 , 5..8	 LLE neutralino,gaugino decays
C n=9..12,13..16 LQD neutralino,gaugino decays
C n=17.20,21..24 UDD neutralino,gaugino decays

      Integer  idecsel,ihigsel
      common/decsel/idecsel(23)
      common/higsel/ihigsel(5)
C 05/96 P.Morawitz
C ...   NOTE: the logical below is used in SUSYGEN V1.5 (April 96)
C       MSSM has its own implementation of R-parity violation.
C       The logical rpar is therefore always set to TRUE which avoids
C       the SUSYGEN R-parity code.
        logical rpar
        common/rpari/rpar
      real*8   brsum,brsuma
CPM      common/brsum/ brsum(5,6,6),brsuma(6)
C 04/96 P.Morawitz & M.Williams  changed brsum to allow for r-parity dec
      common/brsum/ brsum(13,7,6),brsuma(6)
************************************************************************
c EXPLANATION OF INDICES IN BRSUM(itype,igout,igin)
c
c igin  = 1,6 initial gaugino (neutralinos 1..4, charginos 1,2)
c igout = 1,7 outgoing gaugino
c ........where 7 => no outgoing gaugino ie. R-parity violating process
c itype = types of particles produced
c     1 - l+ l-    6 - l q qbar   10 - q q q'         12 - l+ l+ l-
c     2 - v vbar   7 - l q' qbar  11 - qbar qbar qbar 13 - l v v
c     3 - q qbar   8 - v q qbar
c     4 - l v      9 - v q' qbar
c     5 - q' qbar
************************************************************************
      real*8   fms,fmi,fmk,fml1,fml2,etai,etak,brspa
     +        ,brgaug,fmelt,fmert,fmelu,fmeru
      Integer  lind
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
CPM     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
     +lind(6,6,6),brgaug(6,7,11,3),fmelt,fmert,fmelu,fmeru
C 04/96 P.Morawitz & M.Williams  changed brgaug to allow for r-parity de

************************************************************************
c     EXPLANATIONS OF INDICES IN BRGAUG AND BRSPA
c
c BRSPA::
c kgaug =1,6 produced gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c kspar =1,24 initial sparticle
c     1,12  : left-handed sparticle  (u,d,v,e,c,s,v,mu,t,b,v,tau)
c     12,24 : right handed sparticle (u,d,v,e,c,s,v,mu,t,b,v,tau)
c
c BRGAUG::
c igin =1,6 parent gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c igout =1,7 daughter gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c     7    : none (ie. R-parity violating process)
c ipart =1,6 for produced particles .....
c     R-parity conserving decays
c     1,4  : uu,dd,vv,ee                                  - 'like to lik
c     5,6  : ud,ev                                        - 'like to unl
C ipart =7,11 for the 5 diagrams which involve
C             gaugino -> gaugino' gamma
C	      gaugino -> Higgs X
C
C
C ipart =1,8 for Rp-violating!!!! decays (igout=7)
c     R-parity violating decays via LLE operator
c     1,4 :                                               - for neutrali
c     5,8 : l+ l+ l, v v l+, vbar l+ v, l+ vbar v         - for chargino
c     R-parity violating decays via LQD operator
c     1,4  : e+ u dbar, e- ubar d, v d dbar, vbar dbar d  - for neutrali
c     5,8  : v u dbar, e+ dbar d, e+ ubar u, vbar dbar u  - for chargino
c     R-parity violating decays via UDD operator
c     1,4  :						  - for neutralinos
c     5,8  : u u d, u d u, dbar dbar dbar                 - for chargino
c igen =1,3
c     R-parity conserving decays : generation of produced particles
c     R-parity violating decays  : meaningless, i.e. only igen=1 used
************************************************************************
      Real*8   zr,was,esa
      Real*8   VOIJL,VOIJR,gfir,gfil
      COMMON/NEUMIX/ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
      real*8   OIJL,OIJR,V,U,FM,ETA
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      real*8   oijlp,oijrp
      COMMON/CHANEU/oijlp(4,2),oijrp(4,2)
      Integer       ILOOP
      COMMON/SFLOOP/ILOOP
      Real*8   PV
      Integer  IFLAV,NFLAV
CPM      COMMON /PARTC / PV(5,20),IFLAV(20,2),NFLAV
CPM      update to SUSYGEN V1.5
      COMMON /PARTC / pv(5,30)
      COMMON /PARTC1 / iflav(30,2),nflav


      real*8   gw,widfl,widfr,fmeltw,fmertw,fmeluw,fmeruw,gent,gentl
      integer  linda
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,7,6)
CPM     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
C 04/96 P.Morawitz & M.Williams  changed linda to allow for r-parity dec

      integer topo_charg,topo_neut
      common /topocom/ topo_charg,topo_neut

********************* end  of commons of SUSYGEN ***********************

C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------


      common/ubra/ndeca(-80:80)
      common/ubra1/brtot(2,100,-80:80)
C
c First consider R-parity conserving decays
C    and only the 3-body gaugino decays
      n=0
      do 30 k=1,6
        do 20 j=1,6
          do 10 igen=1,3
             do 10 ipart=1,6
CMW       do loop modified to allow R-parity decays
            if(brgaug(k,j,ipart,igen).eq.0)go to 10
              i= ipart + (igen-1)*6
              if(idecsel(i).eq.0)go to 10
              n=n+1
              issmod(n)=70+k
              jssmod(1,n)=70+j
              jssmod(2,n)=-kl(2,i)
              jssmod(3,n)=-kl(1,i)
              if(k.eq.5.or.k.eq.6)jssmod(2,n)=kl(1,i)
              if(k.eq.5.or.k.eq.6)jssmod(3,n)=kl(2,i)
              gssmod(n)=brgaug(k,j,ipart,igen)

   10     continue
   20   continue
   30 continue
C
c R-parity conserving decays continued ...
C   And now for the gaugino -> gamma gaugino'
C             and   gaugino -> Higgs gaugino' decays
      do 31 k=2,4
        do 21 j=1,(k-1)
          do 11 igen=1,1
             do 11 ipart=7,11
                if(ipart.eq.7)then
                  n=n+1
                  issmod(n)=70+k
                  jssmod(1,n)=70+j
                  jssmod(2,n)=22
                  gssmod(n)=brgaug(k,j,ipart,igen)
                elseif(ipart.eq.8)then
                  n=n+1
                  issmod(n)=70+k
                  jssmod(1,n)=70+j
                  jssmod(2,n)=25
                  gssmod(n)=brgaug(k,j,ipart,igen)
                elseif(ipart.eq.9)then
                  n=n+1
                  issmod(n)=70+k
                  jssmod(1,n)=70+j
                  jssmod(2,n)=35
                  gssmod(n)=brgaug(k,j,ipart,igen)
                elseif(ipart.eq.10)then
                  n=n+1
                  issmod(n)=70+k
                  jssmod(1,n)=70+j
                  jssmod(2,n)=36
                  gssmod(n)=brgaug(k,j,ipart,igen)
                elseif(ipart.eq.11)then
                  n=n+1
                  issmod(n)=70+k
                  jssmod(1,n)=70+j
                  jssmod(2,n)=37
                  gssmod(n)=brgaug(k,j,ipart,igen)
              else
               stop ' fatal in interf'
                endif

 11           continue
 21     continue
 31   continue
c
c Now the R-parity violating gaugino decays
c
      do igin=1,6
         do ipart=1,8
            if(brgaug(igin,7,ipart,1).ne.0) then
               n=n+1
               i = ipart + (Coupl_i(1)-1)*8
               issmod(n)=70+igin
               jssmod(1,n)=klr(1,i)
               jssmod(2,n)=klr(2,i)
               jssmod(3,n)=klr(3,i)
               gssmod(n)=brgaug(igin,7,ipart,1)
            end if
         end do
      end do
C
C      brspa(i,j) is the integrated branching ratios for sparticles
C      i is one of the 8 gaugino decays
C      j are the sparticle codes 12 left + 12 right
      do 50 j=1,24
        do 40 i=1,6
          if(brspa(i,j).eq.0.)go to 40
          n=n+1
          il=mod(j-1,12)+1
          kla=(j-1)/12+1
          issmod(n) =ispa(il,kla)
          jssmod(1,n)=70+i
CPM Below bugfix "for down-type squark and for slepton decay,
C                    the wrong charginos sign is selected."
C.. ld
C... bug sign of chargino
          if ( i .ge. 5 .and. mod(j,2).eq.0 ) jssmod(1,n)=-jssmod(1,n)
C.. ld

          jssmod(2,n)=idecs(il,1)
c
c jongling with stop below top
c
          if(i.le.4)then

          if(j.eq.9.and.(fmal(il).lt.gms(9)+xgaug(i)))then
          jssmod(2,n)=4
          endif

          if(j.eq.21.and.(fmar(il).lt.gms(9)+xgaug(i)))then
          jssmod(2,n)=4
          endif

          endif

          if(i.gt.4)jssmod(2,n)=idecs(il,2)
          jssmod(3,n)=0
          gssmod(n)=brspa(i,j)

   40   continue
C ... and the direct R-parity decays of the sleptons
        if (brspa_rpv(j).eq.0.) goto 50
        n=n+1
        il=mod(j-1,12)+1
        kla=(j-1)/12+1
        issmod(n) =ispa(il,kla)
        jssmod(1,n)=rparsletondecaymatrix(j,1)
        jssmod(2,n)=rparsletondecaymatrix(j,2)
C ? well not that easy, 'caus for stau,stop,sbottom -> mixing
        jssmod(3,n)=0
        gssmod(n)=brspa_rpv(j)

   50 continue
      nssmod=n
CYG       WRITE(1,10000)
10000 FORMAT(/' PARENT -->     DAUGHTERS',14X,'WIDTH (KeV) ',7X,
     +'BRANCHING RATIO'/)
C          Write all modes
      DO 60  J=1,NOUT
        call ssnorm(idout(j))
        CALL SSPRT(IDOUT(J))
   60 CONTINUE
      CALL NEWSUM
c
c integrate the branching ratios
c
      do 70  k=41,76
   70 call sstot(k)
      return
      end
      SUBROUTINE SFERMION(mfail)
****$****|****$****|****$****|****$****|****$****|****$****|****$****|**
*                                                                      *
*-- Author :    Stavros Katsanevas   14/04/95                          *
*-- Modified by Y.GAO     1/02/96                                      *
*        quite a lot has been changed, refer the original code to see
*        the differences.
*
*-- P.Morawitz 20/05/96 updated to SUSYGEN V1.5
*--                  now correct treatment of the 3rd generation
*--                  and mixing
*
*-- P.Morawitz 20/04/97 Bug fixes
*                                                                      *
*   mfail=1   L mass negative                                          *
*        =2   R mass negative                                          *
*        =3   1 mass negative after mixing                             *
*        =4   2 mass negative after mixing                             *
****$****|****$****|****$****|****$****|****$****|****$****|****$****|**
      IMPLICIT NONE
      INTEGER mfail,k,i
      double precision fm1,fm2,costh,ctanb,alt,sums,difs,delta
      double precision phimix,phamix,tanth,cos2b,cos2th
********************* start of commons of SUSYGEN **********************
      integer ievent
      common /eve/ ievent
      real*4  rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan(6)
      common /rkey/rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan

      real*8  gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu
      common/steer/gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu

      Integer modes,MIX
      common/mds/modes,MIX
      logical zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,higgs
      common/sparc/ zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,
     + higgs
      logical wrt,scan,lepi
      common/str/wrt,scan,lepi
      real*8  flum,ecm,s,roots,T,Q,Q2,EN
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
      real*8  QK
      COMMON/ISR/ QK(4)
      real erad,srad
      common/srada/erad(100),srad(100)
      integer  idbg,igener,irad
      COMMON /CONST/ idbg,igener,irad
      integer  index,index1,index2,nevt
      COMMON/INDEXX/index,index1,index2,nevt
      real*8   fmpr1,fmpr2,XCROST,APRO
      COMMON/FINDEX/fmpr1,fmpr2,XCROST,APRO
      real*8   cosphimix,facqcd,fgama,spartmas,ratq
      common/mixings/cosphimix,facqcd,fgama,spartmas,ratq
      real*8   FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +         FLC,FRC,gms,echar
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
      real*8      TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      real*8   fmal,fmar,ratqa,fgamc,fgamcr,cosmi
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)

      real*4 gmas,phimx
      common/stopmix/gmas(3),phimx(3)
      real*4 phimix1,stop1,phimix2,sbot1,phimix3,stau1
      equivalence (gmas(1),stop1)
      equivalence (gmas(2),sbot1)
      equivalence (gmas(3),stau1)
      equivalence (phimx(1),phimix1)
      equivalence (phimx(2),phimix2)
      equivalence (phimx(3),phimix3)
      real*4 gmas2
      common/stopmix2/gmas2(3)
      real*4 stop2,sbot2,stau2
      equivalence (gmas2(1),stop2)
      equivalence (gmas2(2),sbot2)
      equivalence (gmas2(3),stau2)
      real*4 rscale
      common/sscale/rscale
      logical imsg                      !Added by S.A. for use in the
      common/imessage/imsg              !NTONPH routine

      double precision sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      common/higgses/sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      logical fix_higgs_masses
      common/ steerhiggs / fix_higgs_masses

      integer jdebu,idb1,idb2,lout
      common /debuc/ jdebu,idb1,idb2,lout

      real*8   xgaug,xeta
      COMMON/XCROS/xgaug(8),xeta(8)

      integer  ispa,kl,klap,idecs,klr
      common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
C 04/96 P.Morawitz & M.Williams introduce klr for Rpv gaugino decays
      common/reord2/klr(3,24)
c klr(1,n), klr(2,n) and klr(3,n) are the particles produced in
c R-parity violating decays of gauginos...
C n=1..4 , 5..8	 LLE neutralino,gaugino decays
C n=9..12,13..16 LQD neutralino,gaugino decays
C n=17.20,21..24 UDD neutralino,gaugino decays

      Integer  idecsel,ihigsel
      common/decsel/idecsel(23)
      common/higsel/ihigsel(5)
C 05/96 P.Morawitz
C ...   NOTE: the logical below is used in SUSYGEN V1.5 (April 96)
C       MSSM has its own implementation of R-parity violation.
C       The logical rpar is therefore always set to TRUE which avoids
C       the SUSYGEN R-parity code.
        logical rpar
        common/rpari/rpar
      real*8   brsum,brsuma
CPM      common/brsum/ brsum(5,6,6),brsuma(6)
C 04/96 P.Morawitz & M.Williams  changed brsum to allow for r-parity dec
      common/brsum/ brsum(13,7,6),brsuma(6)
************************************************************************
c EXPLANATION OF INDICES IN BRSUM(itype,igout,igin)
c
c igin  = 1,6 initial gaugino (neutralinos 1..4, charginos 1,2)
c igout = 1,7 outgoing gaugino
c ........where 7 => no outgoing gaugino ie. R-parity violating process
c itype = types of particles produced
c     1 - l+ l-    6 - l q qbar   10 - q q q'         12 - l+ l+ l-
c     2 - v vbar   7 - l q' qbar  11 - qbar qbar qbar 13 - l v v
c     3 - q qbar   8 - v q qbar
c     4 - l v      9 - v q' qbar
c     5 - q' qbar
************************************************************************
      real*8   fms,fmi,fmk,fml1,fml2,etai,etak,brspa
     +        ,brgaug,fmelt,fmert,fmelu,fmeru
      Integer  lind
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
CPM     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
     +lind(6,6,6),brgaug(6,7,11,3),fmelt,fmert,fmelu,fmeru
C 04/96 P.Morawitz & M.Williams  changed brgaug to allow for r-parity de

************************************************************************
c     EXPLANATIONS OF INDICES IN BRGAUG AND BRSPA
c
c BRSPA::
c kgaug =1,6 produced gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c kspar =1,24 initial sparticle
c     1,12  : left-handed sparticle  (u,d,v,e,c,s,v,mu,t,b,v,tau)
c     12,24 : right handed sparticle (u,d,v,e,c,s,v,mu,t,b,v,tau)
c
c BRGAUG::
c igin =1,6 parent gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c igout =1,7 daughter gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c     7    : none (ie. R-parity violating process)
c ipart =1,6 for produced particles .....
c     R-parity conserving decays
c     1,4  : uu,dd,vv,ee                                  - 'like to lik
c     5,6  : ud,ev                                        - 'like to unl
C ipart =7,11 for the 5 diagrams which involve
C             gaugino -> gaugino' gamma
C	      gaugino -> Higgs X
C
C
C ipart =1,8 for Rp-violating!!!! decays (igout=7)
c     R-parity violating decays via LLE operator
c     1,4 :                                               - for neutrali
c     5,8 : l+ l+ l, v v l+, vbar l+ v, l+ vbar v         - for chargino
c     R-parity violating decays via LQD operator
c     1,4  : e+ u dbar, e- ubar d, v d dbar, vbar dbar d  - for neutrali
c     5,8  : v u dbar, e+ dbar d, e+ ubar u, vbar dbar u  - for chargino
c     R-parity violating decays via UDD operator
c     1,4  :						  - for neutralinos
c     5,8  : u u d, u d u, dbar dbar dbar                 - for chargino
c igen =1,3
c     R-parity conserving decays : generation of produced particles
c     R-parity violating decays  : meaningless, i.e. only igen=1 used
************************************************************************
      Real*8   zr,was,esa
      Real*8   VOIJL,VOIJR,gfir,gfil
      COMMON/NEUMIX/ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
      real*8   OIJL,OIJR,V,U,FM,ETA
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      real*8   oijlp,oijrp
      COMMON/CHANEU/oijlp(4,2),oijrp(4,2)
      Integer       ILOOP
      COMMON/SFLOOP/ILOOP
      Real*8   PV
      Integer  IFLAV,NFLAV
CPM      COMMON /PARTC / PV(5,20),IFLAV(20,2),NFLAV
CPM      update to SUSYGEN V1.5
      COMMON /PARTC / pv(5,30)
      COMMON /PARTC1 / iflav(30,2),nflav


      real*8   gw,widfl,widfr,fmeltw,fmertw,fmeluw,fmeruw,gent,gentl
      integer  linda
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,7,6)
CPM     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
C 04/96 P.Morawitz & M.Williams  changed linda to allow for r-parity dec

      integer topo_charg,topo_neut
      common /topocom/ topo_charg,topo_neut

********************* end  of commons of SUSYGEN ***********************

C
C     decide if we should call SMGUT, all the s-fermion masses will be
C     overwritten after the calling
C     =============================
      mfail=0
      if( modes.eq.1 ) call SMGUT
C
C     inexistent snu right
C     ====================
      fmar( 3) = 10000.
      fmar( 7) = 10000.
      fmar(11) = 10000.
C
C     checking
C     ========
      do 10 k=1,12
        IF(FMAL(k).LE.0.) mfail=1
        IF(FMAR(k).LE.0.) mfail=2

        if(fmal(k).lt.1.) fmal(k)=1.
        if(fmar(k).lt.1.) fmar(k)=1.
   10 continue


      do 25 I=1,12
      cosmi(I)=1.
      ratqa(i)=-(ECHAR(I))
      FGAMC(i) =(FLC(I)-FRC(I))*COSMI(I)**2+FRC(I)
      FGAMCR(i)=(FRC(I)-FLC(I))*COSMI(I)**2+FLC(I)
 25   continue
c
c mixings for 3d family
c
      IF(MIX.NE.0)THEN

      DO 40 i=9,12

C
C GUT type mixing
C
          FM1=fmal(i)**2
          FM2=fmar(i)**2
          ctanb=tanb
          if(i.eq.9)ctanb=1./tanb

          ALT=gms(i)*(ATRI-FMR*CTANB)

          sums=fmal(i)**2+fmar(i)**2+2.d0*gms(i)**2
          difs=fmal(i)**2-fmar(i)**2
          delta=difs**2+4.d0*alt**2

          if(delta.ne.0.)then

            FM1=0.5D0*(sums-dsqrt(delta))
            FM2=0.5D0*(sums+dsqrt(delta))

            cos2th=difs/dsqrt(delta)
            costh=(1+COS2TH)/2.
            if(costh.ne.0.)costh=dsqrt(costh)

          endif

c
c overwrite stop mixing angle
c
c provision to read in stop mass and mixing
c
        if(stop1.gt.0.)THEN
            phimix1=phimix1*3.1415926535/180.
            phamix=dble(phimix1)
            costh=cos(phamix)
            tanth=tan(phamix)
            fm1=stop1**2
            fm2=stop2**2
          endif

          if(sbot1.gt.0.)then
            phimix2=phimix2*3.1415926535/180.
            phamix=dble(phimix2)
            costh=cos(phamix)
            tanth=tan(phamix)
            fm1=sbot1**2
            fm2=sbot2**2
          endif

          if(stau1.gt.0.)then
            phimix3=phimix3*3.1415926535/180.
            phamix=dble(phimix3)
            costh=cos(phamix)
            tanth=tan(phamix)
            fm1=stau1**2
            fm2=stau2**2
           endif

           COSMI(I)=costh
           ratqa(i)=-(ECHAR(I))
           FGAMC(i) =(FLC(I)-FRC(I))*COSMI(I)**2+FRC(I)
           FGAMCR(i)=(FRC(I)-FLC(I))*COSMI(I)**2+FLC(I)

           IF(FM1.gt.0.)FMAL(I)=DSQRT(FM1)
           IF(FM2.gt.0.)FMAR(I)=DSQRT(FM2)

           IF(FM1.LE.0.)then
             mfail=3
           endif

           IF(FM2.LE.0.)then
             mfail=4
           endif

   40 CONTINUE
      ENDIF
      end
      SUBROUTINE SUCARD
C----------------------------------------------------------------------
C!  -
C!
C!   Author   :- Y. Gao                 1-FEB-1996
C!
C    Modified: 22/05/96 P.Morawitz  updated to read in R-parity paramete
C                                   plus others required by SUSYGEN_V1.5
C                                   Also: set rpar=.TRUE. to deactivate
C                                         SUSYGEN's own rpv code
C!   Inputs:
C!        - none
C!
C!   Outputs:
C!        - none
C!
C!   Libraries required:
C!
C!   Description
C!   ===========
C!   set the SUSY parameters by data cards. Modified from the original
C!   SCARDS,SUSANA,and part of SFERMION
C?
C!======================================================================
      Implicit None
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
********************* start of commons of SUSYGEN **********************
      integer ievent
      common /eve/ ievent
      real*4  rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan(6)
      common /rkey/rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan

      real*8  gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu
      common/steer/gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu

      Integer modes,MIX
      common/mds/modes,MIX
      logical zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,higgs
      common/sparc/ zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,
     + higgs
      logical wrt,scan,lepi
      common/str/wrt,scan,lepi
      real*8  flum,ecm,s,roots,T,Q,Q2,EN
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
      real*8  QK
      COMMON/ISR/ QK(4)
      real erad,srad
      common/srada/erad(100),srad(100)
      integer  idbg,igener,irad
      COMMON /CONST/ idbg,igener,irad
      integer  index,index1,index2,nevt
      COMMON/INDEXX/index,index1,index2,nevt
      real*8   fmpr1,fmpr2,XCROST,APRO
      COMMON/FINDEX/fmpr1,fmpr2,XCROST,APRO
      real*8   cosphimix,facqcd,fgama,spartmas,ratq
      common/mixings/cosphimix,facqcd,fgama,spartmas,ratq
      real*8   FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +         FLC,FRC,gms,echar
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
      real*8      TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      real*8   fmal,fmar,ratqa,fgamc,fgamcr,cosmi
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)

      real*4 gmas,phimx
      common/stopmix/gmas(3),phimx(3)
      real*4 phimix1,stop1,phimix2,sbot1,phimix3,stau1
      equivalence (gmas(1),stop1)
      equivalence (gmas(2),sbot1)
      equivalence (gmas(3),stau1)
      equivalence (phimx(1),phimix1)
      equivalence (phimx(2),phimix2)
      equivalence (phimx(3),phimix3)
      real*4 gmas2
      common/stopmix2/gmas2(3)
      real*4 stop2,sbot2,stau2
      equivalence (gmas2(1),stop2)
      equivalence (gmas2(2),sbot2)
      equivalence (gmas2(3),stau2)
      real*4 rscale
      common/sscale/rscale
      logical imsg                      !Added by S.A. for use in the
      common/imessage/imsg              !NTONPH routine

      double precision sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      common/higgses/sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      logical fix_higgs_masses
      common/ steerhiggs / fix_higgs_masses

      integer jdebu,idb1,idb2,lout
      common /debuc/ jdebu,idb1,idb2,lout

      real*8   xgaug,xeta
      COMMON/XCROS/xgaug(8),xeta(8)

      integer  ispa,kl,klap,idecs,klr
      common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
C 04/96 P.Morawitz & M.Williams introduce klr for Rpv gaugino decays
      common/reord2/klr(3,24)
c klr(1,n), klr(2,n) and klr(3,n) are the particles produced in
c R-parity violating decays of gauginos...
C n=1..4 , 5..8	 LLE neutralino,gaugino decays
C n=9..12,13..16 LQD neutralino,gaugino decays
C n=17.20,21..24 UDD neutralino,gaugino decays

      Integer  idecsel,ihigsel
      common/decsel/idecsel(23)
      common/higsel/ihigsel(5)
C 05/96 P.Morawitz
C ...   NOTE: the logical below is used in SUSYGEN V1.5 (April 96)
C       MSSM has its own implementation of R-parity violation.
C       The logical rpar is therefore always set to TRUE which avoids
C       the SUSYGEN R-parity code.
        logical rpar
        common/rpari/rpar
      real*8   brsum,brsuma
CPM      common/brsum/ brsum(5,6,6),brsuma(6)
C 04/96 P.Morawitz & M.Williams  changed brsum to allow for r-parity dec
      common/brsum/ brsum(13,7,6),brsuma(6)
************************************************************************
c EXPLANATION OF INDICES IN BRSUM(itype,igout,igin)
c
c igin  = 1,6 initial gaugino (neutralinos 1..4, charginos 1,2)
c igout = 1,7 outgoing gaugino
c ........where 7 => no outgoing gaugino ie. R-parity violating process
c itype = types of particles produced
c     1 - l+ l-    6 - l q qbar   10 - q q q'         12 - l+ l+ l-
c     2 - v vbar   7 - l q' qbar  11 - qbar qbar qbar 13 - l v v
c     3 - q qbar   8 - v q qbar
c     4 - l v      9 - v q' qbar
c     5 - q' qbar
************************************************************************
      real*8   fms,fmi,fmk,fml1,fml2,etai,etak,brspa
     +        ,brgaug,fmelt,fmert,fmelu,fmeru
      Integer  lind
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
CPM     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
     +lind(6,6,6),brgaug(6,7,11,3),fmelt,fmert,fmelu,fmeru
C 04/96 P.Morawitz & M.Williams  changed brgaug to allow for r-parity de

************************************************************************
c     EXPLANATIONS OF INDICES IN BRGAUG AND BRSPA
c
c BRSPA::
c kgaug =1,6 produced gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c kspar =1,24 initial sparticle
c     1,12  : left-handed sparticle  (u,d,v,e,c,s,v,mu,t,b,v,tau)
c     12,24 : right handed sparticle (u,d,v,e,c,s,v,mu,t,b,v,tau)
c
c BRGAUG::
c igin =1,6 parent gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c igout =1,7 daughter gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c     7    : none (ie. R-parity violating process)
c ipart =1,6 for produced particles .....
c     R-parity conserving decays
c     1,4  : uu,dd,vv,ee                                  - 'like to lik
c     5,6  : ud,ev                                        - 'like to unl
C ipart =7,11 for the 5 diagrams which involve
C             gaugino -> gaugino' gamma
C	      gaugino -> Higgs X
C
C
C ipart =1,8 for Rp-violating!!!! decays (igout=7)
c     R-parity violating decays via LLE operator
c     1,4 :                                               - for neutrali
c     5,8 : l+ l+ l, v v l+, vbar l+ v, l+ vbar v         - for chargino
c     R-parity violating decays via LQD operator
c     1,4  : e+ u dbar, e- ubar d, v d dbar, vbar dbar d  - for neutrali
c     5,8  : v u dbar, e+ dbar d, e+ ubar u, vbar dbar u  - for chargino
c     R-parity violating decays via UDD operator
c     1,4  :						  - for neutralinos
c     5,8  : u u d, u d u, dbar dbar dbar                 - for chargino
c igen =1,3
c     R-parity conserving decays : generation of produced particles
c     R-parity violating decays  : meaningless, i.e. only igen=1 used
************************************************************************
      Real*8   zr,was,esa
      Real*8   VOIJL,VOIJR,gfir,gfil
      COMMON/NEUMIX/ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
      real*8   OIJL,OIJR,V,U,FM,ETA
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      real*8   oijlp,oijrp
      COMMON/CHANEU/oijlp(4,2),oijrp(4,2)
      Integer       ILOOP
      COMMON/SFLOOP/ILOOP
      Real*8   PV
      Integer  IFLAV,NFLAV
CPM      COMMON /PARTC / PV(5,20),IFLAV(20,2),NFLAV
CPM      update to SUSYGEN V1.5
      COMMON /PARTC / pv(5,30)
      COMMON /PARTC1 / iflav(30,2),nflav


      real*8   gw,widfl,widfr,fmeltw,fmertw,fmeluw,fmeruw,gent,gentl
      integer  linda
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,7,6)
CPM     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
C 04/96 P.Morawitz & M.Williams  changed linda to allow for r-parity dec

      integer topo_charg,topo_neut
      common /topocom/ topo_charg,topo_neut

********************* end  of commons of SUSYGEN ***********************

      INTEGER    L1MST,L1PAR
     &          ,L2PAR,L2PARF
     &          ,LJNPAR
      PARAMETER (L1MST=200, L1PAR=200)
      PARAMETER (L2PAR=500, L2PARF=2000)
      PARAMETER (LJNPAR=4000)
      COMMON /LUDAT1/ MSTU(L1MST),PARU(L1PAR),MSTJ(L1MST),PARJ(L1PAR)
      INTEGER         MSTU,MSTJ
      REAL            PARU,PARJ
      COMMON /LUDAT2/ KCHG(L2PAR,3),PMAS(L2PAR,4),PARF(L2PARF),VCKM(4,4)
      INTEGER         KCHG
      REAL            PMAS,PARF,VCKM
      COMMON /LUDAT3/ MDCY(L2PAR,3),MDME(L2PARF,2),BRAT(L2PARF),
     &                KFDP(L2PARF,5)
      INTEGER         MDCY,MDME,KFDP
      REAL            BRAT
      COMMON /LUDAT4/ CHAF(L2PAR)
      CHARACTER*8     CHAF
      COMMON /LUJETS/ N7LU,K7LU(LJNPAR,5),P7LU(LJNPAR,5),V7LU(LJNPAR,5)
      INTEGER         N7LU,K7LU
      REAL            P7LU,V7LU
      Integer       mproc
      Parameter    (mproc=35)
      Integer       iproc,iprod,ipar1,ipar2,ihand,isusy,iopen,ievnt
      Real          xproc
      common/SUPROC/iproc(mproc),iprod(mproc)
     &             ,ipar1(mproc),ipar2(mproc)
     &             ,ihand(mproc),isusy(mproc)
     &             ,iopen(mproc),ievnt(mproc)
     &             ,xproc(mproc)
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------

        LOGICAL Rparity
        COMMON/RpaSwi/ Rparity

      Integer       IPRI,IHST
      Real          ECMS,SVERT
      Integer       mact
      Parameter    (mact=100)
      Integer       nact,iact
      Real          sact,wact
      common/SUWGHT/IPRI,ECMS,SVERT(3)
     &             ,nact,iact(mact)
     &                  ,sact(mact)
     &                  ,wact(mact)


      integer frad
      common /fsr/ frad

      integer ifsrph
      real*8  pfsrphot
      integer imothfsr

      common /FPHOTONS/ pfsrphot(5,100),imothfsr(100),ifsrph
      integer i_sq_had
      common /sqhdcom/ i_sq_had
      integer ispart,ksusy,ispart2,nsusy,ninit,nprod
      common /fcomm/ nsusy,ninit,nprod,ispart(100),ispart2(100)
     &     ,ksusy(100)
      INTEGER      NP,KP(10),NG,KG(10)
      REAL*8       PP(5),PG(5)
      COMMON /FRAGCOM/PP,PG,NP,KP,NG,KG
C-   LOCAL
      Real*8        one_third,two_thirds,one_half,one,zero
      Parameter    (one_third =1.0d0/3.0d0
     &             ,two_thirds=one_third+one_third
     &             ,one_half  =0.5d0
     &             ,one       =1.0d0
     &             ,zero      =0.0d0)
      Real*8        Tev,Pev
      Parameter    (Tev       =1.0D+03)
      Parameter    (Pev       =1.0D+06)

      Integer       NLINK,NAMIND,IDBNK,NMBNK
      External      NLINK,NAMIND

      Real*8        SIN2W,T3(12)
      Integer       I,ipet
C
C --  dummy out the SUSYGEN R-parity code
      rpar=.TRUE. ! i.e. no Rparity violation

C
C     standard model constants
C     ========================
C -   sinW
      IDBNK = NLINK('SW2 ',0)
      if( IDBNK.gt.0 ) then
        SIN2W = RW(IDBNK+1)
      else
        SIN2W = 0.231243d0
      endif
C -   coupling
      IDBNK = NLINK('ALPH',0)
      if( IDBNK.gt.0 ) then
        ALPHA = RW(IDBNK+1)
      else
        ALPHA = 1.0d0/128.0d0
      endif

      PI    = 3.1415926535d0
      TWOPI = PI+PI
      e2    = 4.0d0*PI*ALPHA
      SINW  = DSQRT(SIN2W)
      COSW  = DSQRT(1.0d0-SIN2W)
      G2    = e2/SIN2W
      do I=1,12
        IF(MOD(I-1,4).EQ.0) ECHAR(I) = two_thirds
        IF(MOD(I-1,4).EQ.1) ECHAR(I) =-one_third
        IF(MOD(I-1,4).EQ.2) ECHAR(I) = zero
        IF(MOD(I-1,4).EQ.3) ECHAR(I) =-one

        IF(MOD(I-1,2).EQ.0) T3(I) = one_half
        IF(MOD(I-1,2).EQ.1) T3(I) =-one_half

        FLC(I) = T3(I)-ECHAR(I)*SIN2W
        FRC(I) =-ECHAR(I)*SIN2W
      enddo

C -   mass and width should be consistent with LUND
C -   z0 mass & width
      FMZ     = PMAS(23,1)
      GAMMAZ  = PMAS(23,2)
      FMW     = PMAS(24,1)
      GAMMAW  = PMAS(24,2)
      GMS( 4) = PMAS(11,1)  ! e
      GMS( 3) = PMAS(12,1)  ! nu_e
      GMS( 8) = PMAS(13,1)  ! mu
      GMS( 7) = PMAS(14,1)  ! nu_mu
      GMS(12) = PMAS(15,1)  ! tau
      GMS(11) = PMAS(16,1)  ! nu_tau
      GMS( 2) = PMAS( 1,1)  ! d
      GMS( 1) = PMAS( 2,1)  ! u
      GMS( 6) = PMAS( 3,1)  ! s
      GMS( 5) = PMAS( 4,1)  ! c
      GMS(10) = PMAS( 5,1)  ! b
      GMS( 9) = PMAS( 6,1)  ! t
C
C     switch on/off virtual Z and W decay channels
C     ============================================
      IDBNK=NLINK('DESC',0)
      if( IDBNK.gt.0 ) then
        do i=1,23
        idecsel(i) = IW(IDBNK+i)
        enddo
      else
        do i=1,23
        idecsel(i) = 1
        enddo
      endif
C
C     topology switch for chi+1 chi-1 ... 1=2l, 2=ljj, 3=4j 4=all, 5=onl
C     ============================================
      IDBNK=NLINK('TOC1',0)
      if( IDBNK.gt.0 ) then
      topo_charg=IW(IDBNK+1)
      else
      topo_charg=4 ! all topologies
      endif
C
C     topology switch for chi01 chi02 ... 1=l lbar, 2=j jbar, 3=nu nubar
C     ============================================
      IDBNK=NLINK('TON1',0)
      if( IDBNK.gt.0 ) then
      topo_neut=IW(IDBNK+1)
      else
      topo_neut=4 ! all topologies
      endif

C     switch on/off the HIGGS decay channels
C     ============================================
      IDBNK=NLINK('HDES',0)
      if( IDBNK.gt.0 ) then
        do i=1,5
        ihigsel(i) = IW(IDBNK+i)
        enddo
      else
        do i=1,5
        ihigsel(i) = 1
        enddo
      endif
      IF ( IPRI.GT.0 ) imsg = .true.
C
C     SUSY parameters
C     ===============
      IDBNK=NLINK('SUPA',0)
      rgmaum = 90.0
      rgmaur = 90.0
      rgm0   = 90.0
      rgtanb =  4.0
      rgatri =  0.0
      rscale =  1.0
      rgma =  300.0
      if( IDBNK.gt.0 ) then
        rgmaum = RW(IDBNK+1)
        rgmaur = RW(IDBNK+2)
        rgm0   = RW(IDBNK+3)
        rgtanb = RW(IDBNK+4)
        rgatri = RW(IDBNK+5)
        rscale = RW(IDBNK+6)
        rgma   = RW(IDBNK+7)
      endif
      sfma=dble(rgma)
C -   gluino mass
      IDBNK=NLINK('MGLU',0)
      if( IDBNK.gt.0 ) then
        rfmglu = RW(IDBNK+1)
      else
        rfmglu = Tev
      endif
C -   the masses setup here are useless, because we'll set them later
      rfmstopl = Tev
      rfmstopr = Tev
      rfmsell  = Tev
      rfmselr  = Tev
      rfmsnu   = Tev

       gmaum   = dble(rgmaum)
       gmaur   = dble(rgmaur)
       gm0     = dble(rgm0)
       gtanb   = dble(rgtanb)
       gatri   = dble(rgatri)
       fmsq    = dble(rfmsq)
       fmstopl = dble(rfmstopl)
       fmstopr = dble(rfmstopr)
       fmsell  = dble(rfmsell)
       fmselr  = dble(rfmselr)
       fmsnu   = dble(rfmsnu)
       fmglu   = dble(rfmglu)

       ecm     = dble(recm)
       flum    = dble(rflum)

      FMGAUG = gmaum
      FMR    = gmaur
      FM0    = gm0
      TANB   = gtanb
      COSB   = 1.0D0/DSQRT(1.0D0+TANB**2)
      SINB   = TANB*COSB
      ATRI   = gatri
C
C     the masses of S-particles
C     =========================
C -   sleptons
      IDBNK=NLINK('MLSL',0)
      if( IDBNK.gt.0 ) then
        fmal( 4) = RW(IDBNK+1)
        fmal( 3) = RW(IDBNK+2)
        fmal( 8) = RW(IDBNK+3)
        fmal( 7) = RW(IDBNK+4)
        fmal(12) = RW(IDBNK+5)
        fmal(11) = RW(IDBNK+6)
      else
        fmal( 4) = Tev
        fmal( 3) = Tev
        fmal( 8) = Tev
        fmal( 7) = Tev
        fmal(12) = Tev
        fmal(11) = Tev
      endif
      IDBNK=NLINK('MRSL',0)
      if( IDBNK.gt.0 ) then
        fmar( 4) = RW(IDBNK+1)
        fmar( 3) = RW(IDBNK+2)
        fmar( 8) = RW(IDBNK+3)
        fmar( 7) = RW(IDBNK+4)
        fmar(12) = RW(IDBNK+5)
        fmar(11) = RW(IDBNK+6)
      else
        fmar( 4) = Tev
        fmar( 3) = Pev
        fmar( 8) = Tev
        fmar( 7) = Pev
        fmar(12) = Tev
        fmar(11) = Pev
      endif
C -   squarks
      IDBNK=NLINK('MLSQ',0)
      if( IDBNK.gt.0 ) then
        fmal( 2) = RW(IDBNK+1)
        fmal( 1) = RW(IDBNK+2)
        fmal( 6) = RW(IDBNK+3)
        fmal( 5) = RW(IDBNK+4)
        fmal( 10) = RW(IDBNK+5)
        fmal( 9) = RW(IDBNK+6)
      else
        fmal( 2) = Tev
        fmal( 1) = Tev
        fmal( 6) = Tev
        fmal( 5) = Tev
        fmal( 10) = Tev
        fmal( 9) = Tev
      endif
      IDBNK=NLINK('MRSQ',0)
      if( IDBNK.gt.0 ) then
        fmar( 2) = RW(IDBNK+1)
        fmar( 1) = RW(IDBNK+2)
        fmar( 6) = RW(IDBNK+3)
        fmar( 5) = RW(IDBNK+4)
        fmar( 10) = RW(IDBNK+5)
        fmar( 9) = RW(IDBNK+6)
      else
        fmar( 2) = Tev
        fmar( 1) = Tev
        fmar( 6) = Tev
        fmar( 5) = Tev
        fmar( 10) = Tev
        fmar( 9) = Tev
      endif

C Masses of higges
      IDBNK = NLINK('MHIG',0)
      fix_higgs_masses = IDBNK.gt.0
      if ( fix_higgs_masses ) then
        sfmh   = RW(IDBNK+1)
        sfmhp  = RW(IDBNK+2)
        sfmhpc = RW(IDBNK+3)
        cosa   = RW(IDBNK+4)
        sina   = RW(IDBNK+5)
        write(iw(6),*) ' '
        write(iw(6),*) ' '
        write(iw(6),*) ' HIGGS masses set by user : '
        write(iw(6),*) ' '
        WRITE(iw(6),3500) SNGL(sfMh), SNGL(sfmhp), rgMA,
     &                  SNGL(sfmhpc),SNGL(sina),SNGL(cosa)
3500  FORMAT(/' Light CP-even Higgs =',F10.3,
     +       /' Heavy CP-even Higgs =',F10.3,
     +       /'       CP-odd  Higgs =',F10.3,
     +       /'       Charged Higgs =',F10.3,
     +       /'       sin(a-b)      =',F10.3,
     +       /'       cos(a-b)      =',F10.3)
      endif
C
C     which mode
C     ==========
      IDBNK=NLINK('MODE',0)
      if( IDBNK.gt.0 ) then
        modes=IW(IDBNK+1)
      else
        modes=1
      endif
C
C     mixing
C     ======
      IDBNK=NLINK('MIX ',0)
      if( IDBNK.gt.0 ) then
        MIX = IW(IDBNK+1)
      else
        MIX = 0
      endif

      IDBNK=NLINK('PMIX',0)
      if( IDBNK.gt.0 ) then
        phimx(1) = RW(IDBNK+1)
        phimx(2) = RW(IDBNK+2)
        phimx(3) = RW(IDBNK+3)
      else
        phimx(1)=0.
        phimx(2)=0.
        phimx(3)=0.
      endif
      gmas(1) = 0.
      gmas(2) = 0.
      gmas(3) = 0.
      gmas2(1) = 0.
      gmas2(2) = 0.
      gmas2(3) = 0.
      IDBNK=NLINK('GMAS',0)
      if( IDBNK.gt.0 ) then
        gmas(1)=RW(IDBNK+1)
        gmas(2)=RW(IDBNK+2)
        gmas(3)=RW(IDBNK+3)

        IDBNK=NLINK('GMA2',0)
        if((IDBNK.gt.0 ))then
           gmas2(1)=RW(IDBNK+1)
           gmas2(2)=RW(IDBNK+2)
           gmas2(3)=RW(IDBNK+3)
        else
           IF (((gmas(1).ne.0.).or.(gmas(2).ne.0.)).or
     +       .(gmas(3).ne.0.)) THEN
           write (*,*)
     +          'Please note that a new card GMA2 has been introduced.'
           write (*,*) 'GMAS x,y,z (and GMA2 x,y,z) specify the'
           write (*,*)
     +          ' stop,sbot,stau mass_1 (and mass_2) respectively.'
           write (*,*) 'If you are using the GMAS card you must also'
           write (*,*) ' use GMA2! This is new (20.5.97) PPM.'
           stop
           ENDIF
        endif
      ENDIF

C
C     if SCAN? it is not allowed to scan
C     ==================================
      scan      = .false.
      rvscan(1) =  3.0
      rvscan(2) = 80.0
      rvscan(3) =100.0
      rvscan(4) =  3.0
      rvscan(5) = 80.0
      rvscan(6) =100.0
C
C     use LEPI limit
C     ==============
      IDBNK=NLINK('LEPI',0)
      if( IDBNK.gt.0 ) then
        lepi = IW(IDBNK+1).gt.0
      else
        lepi = .false.
      endif
C
C     ISR
C     ===
      IDBNK=NLINK('IRAD',0)
      if( IDBNK.gt.0 ) then
        irad = IW(IDBNK+1)
      else
        irad = 1
      endif
C
C     FSR
C     ===
      IDBNK=NLINK('FRAD',0)
      if( IDBNK.gt.0 ) then
        frad = IW(IDBNK+1)
      else
        frad = 1
      endif

C     Squark hadronisation
C     ==============================
      IDBNK=NLINK('SHAD',0)
      if( IDBNK.gt.0 ) then
         i_sq_had = IW(IDBNK+1)
      else
         i_sq_had = 0
      endif
C
C     don't write to FOR012
C     =====================
      wrt = .false.
C
C     we have to always set igener to 1
C     =================================
      igener=1
C.. ld
      NMBNK=NAMIND('TRIG')
      IDBNK=NMBNK+1
      IDBNK=IW(IDBNK-1)
      if( IDBNK.gt.0 ) then
         if ( IW(IDBNK+1).gt.IW(IDBNK+2)+1 .or.
     &      (IW(IDBNK+1).eq.0 .and. IW(IDBNK
     +        +2).eq.0) ) igener = 0
      endif
C.. ld
C
C     PROC: which process to be generated
C     ===================================
      do I=1,mproc
        iopen(I)=1
      enddo
      NMBNK=NAMIND('PROC')
      IDBNK=NMBNK+1
80    IDBNK=IW(IDBNK-1)
      if( IDBNK.gt.0 ) then
        I       =IW(IDBNK-2)
        iopen(I)=IW(IDBNK+1)
        goto 80
      endif
      higgs=.false.

C     Rparity violation
C     ==============================
      IDBNK=NLINK('RPAR',0)
      Rparity = .FALSE.
      if( IDBNK.gt.0 ) then
         Rparity= (IW(IDBNK+1).EQ.1)
       COUPL_I(1) = IW(IDBNK+2)
       COUPL_I(2) = IW(IDBNK+3)
       COUPL_I(3) = IW(IDBNK+4)
       COUPL_I(4) = IW(IDBNK+5)
      endif

      XLAM=0.3
      IDBNK=NLINK('RLAM',0)
      if( IDBNK.gt.0 ) then
         XLAM= RW(IDBNK+1)
      endif
      RBOD=.FALSE.
      IDBNK=NLINK('RBOD',0)
      if( IDBNK.gt.0 ) then
       RBOD=.TRUE.
         RBOD_G(1)= RW(IDBNK+1)
         RBOD_G(2)= RW(IDBNK+2)
         RBOD_G(3)= RW(IDBNK+3)
         RBOD_G(4)= RW(IDBNK+4)
      endif
      RBOD2=.FALSE.
      IDBNK=NLINK('RBO2',0)
      if( IDBNK.gt.0 ) then
       RBOD2=.TRUE.
         RBOD2_G(1)= RW(IDBNK+1)
         RBOD2_G(2)= RW(IDBNK+2)
         RBOD2_G(3)= RW(IDBNK+3)
         RBOD2_G(4)= RW(IDBNK+4)
      endif
      RBOD3=.FALSE.
      IDBNK=NLINK('RBO3',0)
      if( IDBNK.gt.0 ) then
       RBOD3=.TRUE.
      endif
      RBOD4=.FALSE.
      IDBNK=NLINK('RBO4',0)
      if( IDBNK.gt.0 ) then
       RBOD4=.TRUE.
         RBOD4_M(1)= RW(IDBNK+1)
         RBOD4_M(2)= RW(IDBNK+2)
      endif
      do ipet=1,24
         brspa_rpv(ipet)=0.
C ... argh bug , i should be ipet
         rparsletondecaymatrix(ipet,1)=0
         rparsletondecaymatrix(ipet,2)=0
      enddo
      IDBNK=NLINK('RPW1',0)
      if( IDBNK.gt.0 ) then
         do ipet=1,12
            brspa_rpv(ipet)=RW(IDBNK+ipet)
         enddo
      endif
      IDBNK=NLINK('RPW2',0)
      if( IDBNK.gt.0 ) then
         do ipet=1,12
            brspa_rpv(ipet+12)=RW(IDBNK+ipet)
         enddo
      endif
      IDBNK=NLINK('RPD1',0)
      if( IDBNK.gt.0 ) then
         do ipet=1,12
            rparsletondecaymatrix(ipet,1)=IW(IDBNK+(ipet-1)*2+1)
            rparsletondecaymatrix(ipet,2)=IW(IDBNK+(ipet-1)*2+2)
         enddo
      endif
      IDBNK=NLINK('RPD2',0)
      if( IDBNK.gt.0 ) then
         do ipet=1,12
            rparsletondecaymatrix(ipet+12,1)=IW(IDBNK+(ipet-1)*2+1)
            rparsletondecaymatrix(ipet+12,2)=IW(IDBNK+(ipet-1)*2+2)
         enddo
      endif

      END
      SUBROUTINE SUMSSM(NP,IG,JG,XC)
C----------------------------------------------------------------------
C!  -
C!
C!   Author   :- Y. Gao                 2-FEB-1996
C!
C!   Inputs:
C!        - NP process number
C!        - IG calculate cross-section & generate IG events
C!
C!   Outputs:
C!        - JG number of nevets generated
C!        - XC cross-section
C!
C!   Libraries required:
C!
C!   Description
C!   ===========
C!   modified from MSSMSUSY
C?
C!======================================================================
      Implicit None
********************* start of commons of SUSYGEN **********************
      integer ievent
      common /eve/ ievent
      real*4  rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan(6)
      common /rkey/rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan

      real*8  gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu
      common/steer/gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu

      Integer modes,MIX
      common/mds/modes,MIX
      logical zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,higgs
      common/sparc/ zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,
     + higgs
      logical wrt,scan,lepi
      common/str/wrt,scan,lepi
      real*8  flum,ecm,s,roots,T,Q,Q2,EN
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
      real*8  QK
      COMMON/ISR/ QK(4)
      real erad,srad
      common/srada/erad(100),srad(100)
      integer  idbg,igener,irad
      COMMON /CONST/ idbg,igener,irad
      integer  index,index1,index2,nevt
      COMMON/INDEXX/index,index1,index2,nevt
      real*8   fmpr1,fmpr2,XCROST,APRO
      COMMON/FINDEX/fmpr1,fmpr2,XCROST,APRO
      real*8   cosphimix,facqcd,fgama,spartmas,ratq
      common/mixings/cosphimix,facqcd,fgama,spartmas,ratq
      real*8   FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +         FLC,FRC,gms,echar
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
      real*8      TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      real*8   fmal,fmar,ratqa,fgamc,fgamcr,cosmi
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)

      real*4 gmas,phimx
      common/stopmix/gmas(3),phimx(3)
      real*4 phimix1,stop1,phimix2,sbot1,phimix3,stau1
      equivalence (gmas(1),stop1)
      equivalence (gmas(2),sbot1)
      equivalence (gmas(3),stau1)
      equivalence (phimx(1),phimix1)
      equivalence (phimx(2),phimix2)
      equivalence (phimx(3),phimix3)
      real*4 gmas2
      common/stopmix2/gmas2(3)
      real*4 stop2,sbot2,stau2
      equivalence (gmas2(1),stop2)
      equivalence (gmas2(2),sbot2)
      equivalence (gmas2(3),stau2)
      real*4 rscale
      common/sscale/rscale
      logical imsg                      !Added by S.A. for use in the
      common/imessage/imsg              !NTONPH routine

      double precision sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      common/higgses/sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      logical fix_higgs_masses
      common/ steerhiggs / fix_higgs_masses

      integer jdebu,idb1,idb2,lout
      common /debuc/ jdebu,idb1,idb2,lout

      real*8   xgaug,xeta
      COMMON/XCROS/xgaug(8),xeta(8)

      integer  ispa,kl,klap,idecs,klr
      common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
C 04/96 P.Morawitz & M.Williams introduce klr for Rpv gaugino decays
      common/reord2/klr(3,24)
c klr(1,n), klr(2,n) and klr(3,n) are the particles produced in
c R-parity violating decays of gauginos...
C n=1..4 , 5..8	 LLE neutralino,gaugino decays
C n=9..12,13..16 LQD neutralino,gaugino decays
C n=17.20,21..24 UDD neutralino,gaugino decays

      Integer  idecsel,ihigsel
      common/decsel/idecsel(23)
      common/higsel/ihigsel(5)
C 05/96 P.Morawitz
C ...   NOTE: the logical below is used in SUSYGEN V1.5 (April 96)
C       MSSM has its own implementation of R-parity violation.
C       The logical rpar is therefore always set to TRUE which avoids
C       the SUSYGEN R-parity code.
        logical rpar
        common/rpari/rpar
      real*8   brsum,brsuma
CPM      common/brsum/ brsum(5,6,6),brsuma(6)
C 04/96 P.Morawitz & M.Williams  changed brsum to allow for r-parity dec
      common/brsum/ brsum(13,7,6),brsuma(6)
************************************************************************
c EXPLANATION OF INDICES IN BRSUM(itype,igout,igin)
c
c igin  = 1,6 initial gaugino (neutralinos 1..4, charginos 1,2)
c igout = 1,7 outgoing gaugino
c ........where 7 => no outgoing gaugino ie. R-parity violating process
c itype = types of particles produced
c     1 - l+ l-    6 - l q qbar   10 - q q q'         12 - l+ l+ l-
c     2 - v vbar   7 - l q' qbar  11 - qbar qbar qbar 13 - l v v
c     3 - q qbar   8 - v q qbar
c     4 - l v      9 - v q' qbar
c     5 - q' qbar
************************************************************************
      real*8   fms,fmi,fmk,fml1,fml2,etai,etak,brspa
     +        ,brgaug,fmelt,fmert,fmelu,fmeru
      Integer  lind
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
CPM     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
     +lind(6,6,6),brgaug(6,7,11,3),fmelt,fmert,fmelu,fmeru
C 04/96 P.Morawitz & M.Williams  changed brgaug to allow for r-parity de

************************************************************************
c     EXPLANATIONS OF INDICES IN BRGAUG AND BRSPA
c
c BRSPA::
c kgaug =1,6 produced gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c kspar =1,24 initial sparticle
c     1,12  : left-handed sparticle  (u,d,v,e,c,s,v,mu,t,b,v,tau)
c     12,24 : right handed sparticle (u,d,v,e,c,s,v,mu,t,b,v,tau)
c
c BRGAUG::
c igin =1,6 parent gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c igout =1,7 daughter gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c     7    : none (ie. R-parity violating process)
c ipart =1,6 for produced particles .....
c     R-parity conserving decays
c     1,4  : uu,dd,vv,ee                                  - 'like to lik
c     5,6  : ud,ev                                        - 'like to unl
C ipart =7,11 for the 5 diagrams which involve
C             gaugino -> gaugino' gamma
C	      gaugino -> Higgs X
C
C
C ipart =1,8 for Rp-violating!!!! decays (igout=7)
c     R-parity violating decays via LLE operator
c     1,4 :                                               - for neutrali
c     5,8 : l+ l+ l, v v l+, vbar l+ v, l+ vbar v         - for chargino
c     R-parity violating decays via LQD operator
c     1,4  : e+ u dbar, e- ubar d, v d dbar, vbar dbar d  - for neutrali
c     5,8  : v u dbar, e+ dbar d, e+ ubar u, vbar dbar u  - for chargino
c     R-parity violating decays via UDD operator
c     1,4  :						  - for neutralinos
c     5,8  : u u d, u d u, dbar dbar dbar                 - for chargino
c igen =1,3
c     R-parity conserving decays : generation of produced particles
c     R-parity violating decays  : meaningless, i.e. only igen=1 used
************************************************************************
      Real*8   zr,was,esa
      Real*8   VOIJL,VOIJR,gfir,gfil
      COMMON/NEUMIX/ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
      real*8   OIJL,OIJR,V,U,FM,ETA
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      real*8   oijlp,oijrp
      COMMON/CHANEU/oijlp(4,2),oijrp(4,2)
      Integer       ILOOP
      COMMON/SFLOOP/ILOOP
      Real*8   PV
      Integer  IFLAV,NFLAV
CPM      COMMON /PARTC / PV(5,20),IFLAV(20,2),NFLAV
CPM      update to SUSYGEN V1.5
      COMMON /PARTC / pv(5,30)
      COMMON /PARTC1 / iflav(30,2),nflav


      real*8   gw,widfl,widfr,fmeltw,fmertw,fmeluw,fmeruw,gent,gentl
      integer  linda
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,7,6)
CPM     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
C 04/96 P.Morawitz & M.Williams  changed linda to allow for r-parity dec

      integer topo_charg,topo_neut
      common /topocom/ topo_charg,topo_neut

********************* end  of commons of SUSYGEN ***********************

      Integer       mproc
      Parameter    (mproc=35)
      Integer       iproc,iprod,ipar1,ipar2,ihand,isusy,iopen,ievnt
      Real          xproc
      common/SUPROC/iproc(mproc),iprod(mproc)
     &             ,ipar1(mproc),ipar2(mproc)
     &             ,ihand(mproc),isusy(mproc)
     &             ,iopen(mproc),ievnt(mproc)
     &             ,xproc(mproc)
      Integer       NP,IG,JG
      Real          XC
      Integer       l,k
      Real*8        f

      Integer       l_np
      Real          l_xc
      Data          l_np,l_xc/0,0.0/

      Real*8        Shat,EBEAM
      Real*8        SIGMA,ssmass
      External      SIGMA,ssmass
      SAVE
C
C     check if it is the same as the last one
C     =======================================
      if( NP.eq.l_np ) then
        XC = l_xc
        goto 40
      endif
C
C     get the index and hand
C     ======================
      index  = iprod(NP)
      index1 = ipar1(NP)
      index2 = ipar2(NP)
      l      = ihand(NP)
      k      = isusy(NP)
C
C     QCD factor
C     ==========
      if( NP.le.23 ) then
        f=0.0d0
      else
        f=1.0d0
      endif
C
C     choose the specific process
C     ===========================
      s    =ecm*ecm
      roots=sqrt(s)
      EBEAM=ecm/2.0d0
      Shat =ecm*ecm
      JG   =0
      XC   =0.0
C
C     calculate cross-sections
C     ========================
      if( index .eq. 1 ) then
C
C       NEUTRALINOS
C       ------------
        fmpr1=ssmass(index1)
        fmpr2=ssmass(index2)
        if(fmpr1+fmpr2.gt.ECM)  goto 50
        if(irad.eq.0) then
          XC = SIGMA(Shat)
        else
          call REMT1(EBEAM,SIGMA)
          XC = xcrost
        endif

      elseif( index.eq.2 ) then
C
C       CHARGINOS
C       ---------
        fmpr1=ssmass(index1)
        fmpr2=ssmass(index2)
        if(fmpr1+fmpr2.gt.ECM) goto 50
        if(irad.eq.0) then
          XC = SIGMA(Shat)
        else
          call REMT1(EBEAM,SIGMA)
          XC = xcrost
        endif

      elseif( index.eq.3 ) then
C
C       SPARTICLES
C       ----------
        fmpr1=ssmass(index1)
        fmpr2=ssmass(index2)
        if(fmpr1+fmpr2.gt.ECM) goto 50

        spartmas=fmpr1
        ratq=ratqa(k)
        facqcd=f
        if(l.eq.1)then
          fgama=fgamc(k)
          cosphimix=1.d0
        else
          fgama=fgamcr(k)
          cosphimix=0.
        endif

        if(irad.eq.0) then
          XC = SIGMA(Shat)
        else
          call REMT1(EBEAM,SIGMA)
          XC = xcrost
        endif

      endif
C
C     generate events
C     ===============
40    continue
      nevt = IG
      call MSSM_GENE
      JG   = IG

      ievnt(NP) = ievnt(NP)+IG

50    continue
      l_np = NP
      l_xc = XC
      end
      SUBROUTINE SUPART
C----------------------------------------------------------------------
C!  -
C!
C!   Author   :- Y. Gao                 1-FEB-1996
C!
C!   Inputs:
C!        - none
C!
C!   Outputs:
C!        - none
C!
C!   Libraries required:
C!
C!   Description
C!   ===========
C!   set the SUSY-particle name, charge etc
C?
C!======================================================================
      Implicit None
      INTEGER    L1MST,L1PAR
     &          ,L2PAR,L2PARF
     &          ,LJNPAR
      PARAMETER (L1MST=200, L1PAR=200)
      PARAMETER (L2PAR=500, L2PARF=2000)
      PARAMETER (LJNPAR=4000)
      COMMON /LUDAT1/ MSTU(L1MST),PARU(L1PAR),MSTJ(L1MST),PARJ(L1PAR)
      INTEGER         MSTU,MSTJ
      REAL            PARU,PARJ
      COMMON /LUDAT2/ KCHG(L2PAR,3),PMAS(L2PAR,4),PARF(L2PARF),VCKM(4,4)
      INTEGER         KCHG
      REAL            PMAS,PARF,VCKM
      COMMON /LUDAT3/ MDCY(L2PAR,3),MDME(L2PARF,2),BRAT(L2PARF),
     &                KFDP(L2PARF,5)
      INTEGER         MDCY,MDME,KFDP
      REAL            BRAT
      COMMON /LUDAT4/ CHAF(L2PAR)
      CHARACTER*8     CHAF
      COMMON /LUJETS/ N7LU,K7LU(LJNPAR,5),P7LU(LJNPAR,5),V7LU(LJNPAR,5)
      INTEGER         N7LU,K7LU
      REAL            P7LU,V7LU
      Integer       I,J
C
C     set the charges
C     ===============
      Integer       JCHG(500,3)
      DATA ( JCHG(I,1),I=41,79 )
     +/-1, 2,-1, 2,-1, 2,-1, 2,-1, 2
     +,-3, 0,-3, 0,-3, 0,-3,-3,-3, 0
     +,-1, 2,-1, 2,-3,-1, 2,-3, 0
     +, 0, 0, 0, 0, 0, 3, 3,-3,-3, 0/
      DATA ( JCHG(I,2),I=41,79 )
     +/10*1,10*0, 2*1, 2*1, 0, 2*1, 0, 0, 2, 9*0/
      DATA ( JCHG(I,3),I=41,79 )
     +/19*1, 0,8*1,6*0,4*0,0/
      SAVE
*
*     SSID from SUSYGEN, used to set the particle name
*     ================================================
      Character*5 SSID,NAME
      External    SSID
C
C     set names
C     =========
      DO I=41,78
        NAME=SSID(I)
        DO J=5,1,-1
          IF(NAME(J:J).NE.' ') GOTO 10
        ENDDO
10      IF( NAME(J:J).EQ.'+' .OR. NAME(J:J).EQ.'-' ) NAME(J:J)=' '
        CHAF(I)=NAME
      ENDDO
      CHAF(79)='SusyProd'
C
C     set charges
C     ===========
      DO I=41,79
      DO J=1,3
        KCHG(I,J)=JCHG(I,J)
      ENDDO
      ENDDO
      END
      SUBROUTINE SUPRNT(IPRINT)
C----------------------------------------------------------------------
C!  -
C!
C!   Author   :- Y. Gao                 5-FEB-1996
C!
C!   Inputs:
C!        - IPRINT
C!
C!   Outputs:
C!        - none
C!
C!   Libraries required:
C!
C!   Description
C!   ===========
C!
C?
C!======================================================================
      Implicit None
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
********************* start of commons of SUSYGEN **********************
      integer ievent
      common /eve/ ievent
      real*4  rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan(6)
      common /rkey/rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan

      real*8  gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu
      common/steer/gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu

      Integer modes,MIX
      common/mds/modes,MIX
      logical zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,higgs
      common/sparc/ zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,
     + higgs
      logical wrt,scan,lepi
      common/str/wrt,scan,lepi
      real*8  flum,ecm,s,roots,T,Q,Q2,EN
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
      real*8  QK
      COMMON/ISR/ QK(4)
      real erad,srad
      common/srada/erad(100),srad(100)
      integer  idbg,igener,irad
      COMMON /CONST/ idbg,igener,irad
      integer  index,index1,index2,nevt
      COMMON/INDEXX/index,index1,index2,nevt
      real*8   fmpr1,fmpr2,XCROST,APRO
      COMMON/FINDEX/fmpr1,fmpr2,XCROST,APRO
      real*8   cosphimix,facqcd,fgama,spartmas,ratq
      common/mixings/cosphimix,facqcd,fgama,spartmas,ratq
      real*8   FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +         FLC,FRC,gms,echar
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
      real*8      TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      real*8   fmal,fmar,ratqa,fgamc,fgamcr,cosmi
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)

      real*4 gmas,phimx
      common/stopmix/gmas(3),phimx(3)
      real*4 phimix1,stop1,phimix2,sbot1,phimix3,stau1
      equivalence (gmas(1),stop1)
      equivalence (gmas(2),sbot1)
      equivalence (gmas(3),stau1)
      equivalence (phimx(1),phimix1)
      equivalence (phimx(2),phimix2)
      equivalence (phimx(3),phimix3)
      real*4 gmas2
      common/stopmix2/gmas2(3)
      real*4 stop2,sbot2,stau2
      equivalence (gmas2(1),stop2)
      equivalence (gmas2(2),sbot2)
      equivalence (gmas2(3),stau2)
      real*4 rscale
      common/sscale/rscale
      logical imsg                      !Added by S.A. for use in the
      common/imessage/imsg              !NTONPH routine

      double precision sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      common/higgses/sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      logical fix_higgs_masses
      common/ steerhiggs / fix_higgs_masses

      integer jdebu,idb1,idb2,lout
      common /debuc/ jdebu,idb1,idb2,lout

      real*8   xgaug,xeta
      COMMON/XCROS/xgaug(8),xeta(8)

      integer  ispa,kl,klap,idecs,klr
      common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
C 04/96 P.Morawitz & M.Williams introduce klr for Rpv gaugino decays
      common/reord2/klr(3,24)
c klr(1,n), klr(2,n) and klr(3,n) are the particles produced in
c R-parity violating decays of gauginos...
C n=1..4 , 5..8	 LLE neutralino,gaugino decays
C n=9..12,13..16 LQD neutralino,gaugino decays
C n=17.20,21..24 UDD neutralino,gaugino decays

      Integer  idecsel,ihigsel
      common/decsel/idecsel(23)
      common/higsel/ihigsel(5)
C 05/96 P.Morawitz
C ...   NOTE: the logical below is used in SUSYGEN V1.5 (April 96)
C       MSSM has its own implementation of R-parity violation.
C       The logical rpar is therefore always set to TRUE which avoids
C       the SUSYGEN R-parity code.
        logical rpar
        common/rpari/rpar
      real*8   brsum,brsuma
CPM      common/brsum/ brsum(5,6,6),brsuma(6)
C 04/96 P.Morawitz & M.Williams  changed brsum to allow for r-parity dec
      common/brsum/ brsum(13,7,6),brsuma(6)
************************************************************************
c EXPLANATION OF INDICES IN BRSUM(itype,igout,igin)
c
c igin  = 1,6 initial gaugino (neutralinos 1..4, charginos 1,2)
c igout = 1,7 outgoing gaugino
c ........where 7 => no outgoing gaugino ie. R-parity violating process
c itype = types of particles produced
c     1 - l+ l-    6 - l q qbar   10 - q q q'         12 - l+ l+ l-
c     2 - v vbar   7 - l q' qbar  11 - qbar qbar qbar 13 - l v v
c     3 - q qbar   8 - v q qbar
c     4 - l v      9 - v q' qbar
c     5 - q' qbar
************************************************************************
      real*8   fms,fmi,fmk,fml1,fml2,etai,etak,brspa
     +        ,brgaug,fmelt,fmert,fmelu,fmeru
      Integer  lind
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
CPM     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
     +lind(6,6,6),brgaug(6,7,11,3),fmelt,fmert,fmelu,fmeru
C 04/96 P.Morawitz & M.Williams  changed brgaug to allow for r-parity de

************************************************************************
c     EXPLANATIONS OF INDICES IN BRGAUG AND BRSPA
c
c BRSPA::
c kgaug =1,6 produced gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c kspar =1,24 initial sparticle
c     1,12  : left-handed sparticle  (u,d,v,e,c,s,v,mu,t,b,v,tau)
c     12,24 : right handed sparticle (u,d,v,e,c,s,v,mu,t,b,v,tau)
c
c BRGAUG::
c igin =1,6 parent gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c igout =1,7 daughter gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c     7    : none (ie. R-parity violating process)
c ipart =1,6 for produced particles .....
c     R-parity conserving decays
c     1,4  : uu,dd,vv,ee                                  - 'like to lik
c     5,6  : ud,ev                                        - 'like to unl
C ipart =7,11 for the 5 diagrams which involve
C             gaugino -> gaugino' gamma
C	      gaugino -> Higgs X
C
C
C ipart =1,8 for Rp-violating!!!! decays (igout=7)
c     R-parity violating decays via LLE operator
c     1,4 :                                               - for neutrali
c     5,8 : l+ l+ l, v v l+, vbar l+ v, l+ vbar v         - for chargino
c     R-parity violating decays via LQD operator
c     1,4  : e+ u dbar, e- ubar d, v d dbar, vbar dbar d  - for neutrali
c     5,8  : v u dbar, e+ dbar d, e+ ubar u, vbar dbar u  - for chargino
c     R-parity violating decays via UDD operator
c     1,4  :						  - for neutralinos
c     5,8  : u u d, u d u, dbar dbar dbar                 - for chargino
c igen =1,3
c     R-parity conserving decays : generation of produced particles
c     R-parity violating decays  : meaningless, i.e. only igen=1 used
************************************************************************
      Real*8   zr,was,esa
      Real*8   VOIJL,VOIJR,gfir,gfil
      COMMON/NEUMIX/ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
      real*8   OIJL,OIJR,V,U,FM,ETA
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      real*8   oijlp,oijrp
      COMMON/CHANEU/oijlp(4,2),oijrp(4,2)
      Integer       ILOOP
      COMMON/SFLOOP/ILOOP
      Real*8   PV
      Integer  IFLAV,NFLAV
CPM      COMMON /PARTC / PV(5,20),IFLAV(20,2),NFLAV
CPM      update to SUSYGEN V1.5
      COMMON /PARTC / pv(5,30)
      COMMON /PARTC1 / iflav(30,2),nflav


      real*8   gw,widfl,widfr,fmeltw,fmertw,fmeluw,fmeruw,gent,gentl
      integer  linda
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,7,6)
CPM     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
C 04/96 P.Morawitz & M.Williams  changed linda to allow for r-parity dec

      integer topo_charg,topo_neut
      common /topocom/ topo_charg,topo_neut

********************* end  of commons of SUSYGEN ***********************

      Integer       mproc
      Parameter    (mproc=35)
      Integer       iproc,iprod,ipar1,ipar2,ihand,isusy,iopen,ievnt
      Real          xproc
      common/SUPROC/iproc(mproc),iprod(mproc)
     &             ,ipar1(mproc),ipar2(mproc)
     &             ,ihand(mproc),isusy(mproc)
     &             ,iopen(mproc),ievnt(mproc)
     &             ,xproc(mproc)

      Integer       IPRINT
      Integer       IUT,i,j

      Integer       number,iname1,iname2
      Character*8   pname1,pname2
      Character*16  cname1,cname2
      Real          xsecti
      Character*3   switch
      Integer       nevent


      Integer       kf
      Character*8   cf
      Real          mf,wf
      Integer       md
      Parameter    (md=100)
      Integer       nd
      Character*8   cd(3,md)
      Real          wd(md),bd(md)
      Character*4   ch(md)
*-----------------------------------------------------------------------
      IUT=IW(6)
      if( IPRINT.eq.2 ) goto 200
C
C     print out basic parameters & mass matrice etc
C     =============================================
      WRITE(IUT,1001) rgtanb,TANB,FMGAUG,FMR,FM0,ATRI
      WRITE(IUT,1002) (was(i),NINT(esa(i)),(zr(j,i),j=1,4),i=1,4)
c wrong order  WRITE(IUT,1003) (FM(i),NINT(ETA(i)),U(1,i),U(2,i),i=1,2),
      WRITE(IUT,1003)(FM(i),NINT(ETA(i)),U(i,1),U(i,2),i=1,2),
     &               V(1,1),V(1,2),V(2,1),V(2,2)

1003  FORMAT(
     &10x,'Chargino mass matrix:',/,
     &10x,60('-'),/,
     &10x,'mass (Gev)',5x,' eta',5x,'U-MATRIX  ','  Wino  Higgsino',/,
     &10x,f8.2,7x,I3,6x,            '   W1SS+ (',F8.3,F8.3,' )',/,
     &10x,f8.2,7x,I3,6x,            '   W2SS+ (',F8.3,F8.3,' )',//,
     &10x,24x,                      'V-MATRIX  ','  Wino  Higgsino',/,
     &10x,24x,                      '   W1SS- (',F8.3,F8.3,' )',/,
     &10x,24x,                      '   W2SS- (',F8.3,F8.3,' )',/,
     &10x,70('='))
1002  FORMAT(
     &10x,'Neutralino mass matrix:',/,
     &10X,60('-'),/,
     &10x,'mass (Gev)',5x,' eta',5x,12x,'eigenvector',/,
     &10x,F8.2,7x,I3,6x,'(',F8.3,F8.3,F8.3,F8.3,' )',/,
     &10x,F8.2,7x,I3,6x,'(',F8.3,F8.3,F8.3,F8.3,' )',/,
     &10x,F8.2,7x,I3,6x,'(',F8.3,F8.3,F8.3,F8.3,' )',/,
     &10x,F8.2,7x,I3,6x,'(',F8.3,F8.3,F8.3,F8.3,' )',/,
     &10X,70('='))

1001  FORMAT(//,
     &10X,70('='),/,
     &10x,'MSSM  Parameters:',/,
     &10X,50('-'),/,
     &     10x,'                     tan(beta) = ', F8.2 ,/,
     &     10x,'     value of tan(beta) at Mtop= ',F8.2 ,/,
     &10x,'SU(2) gaugino mass   M         = ', F8.2 ,/,
     &10x,'Higgs mixing term    mu        = ', F8.2 ,/,
     &10x,'Common scalar mass   m0        = ', F8.2 ,/,
     &10x,'trilinear coupling   A         = ', F8.2 ,/,
     &10x,70('='))
C
C     print out masses etc
C     ====================
100   continue

      write(IUT,5001)
      do kf=71,76
        call SUTABL(kf,cf,mf,wf,nd,cd,wd,bd,ch,1)
      enddo
      write(IUT,5002)
      do i=1,12
      do j=1,2
        kf=ispa(i,j)
        if( kf.ne.0 )
     &  call SUTABL(kf,cf,mf,wf,nd,cd,wd,bd,ch,1)
      enddo
      enddo

5001  format(10x,//,
     &       10x,'Gaugino  Summary Table',/,
     &       10x,'Gaugino  Summary Table',/,
     &       10x,'Gaugino  Summary Table')
5002  format(10x,//,
     &       10x,'Sfermion Summary Table',/,
     &       10x,'Sfermion Summary Table',/,
     &       10x,'Sfermion Summary Table')
      return
C
C     end of job summary
C     ==================
200   continue
      write(IUT,*) ' '
      write(IUT,*) ' '
      write(IUT,1)
      do i=1,mproc
        iname1=ipar1(i)
        iname2=ipar2(i)
        if( iname1.eq.-75 ) iname1=77
        if( iname1.eq.-76 ) iname1=78
        if( iname2.eq.-75 ) iname2=77
        if( iname2.eq.-76 ) iname2=78
        call LUNAME(iname1,cname1)
        call LUNAME(iname2,cname2)
        pname1=cname1(1:8)
        pname2=cname2(1:8)
        number=i
        xsecti=xproc(i)
        if( iopen(i).eq.0 ) switch='OFF'
        if( iopen(i).eq.1 ) switch='ON '
        nevent=ievnt(i)

        write(IUT,3) number,pname1,pname2,xsecti,switch,nevent
        write(IUT,2)
      enddo

1     format(
     &8x,'------------------ Generation  Summary --------------------'
     &,/,
     &8x,'| PROC ||     e+e- -->     || cross-sect || ON  || events |'
     &,/,
     &8x,'|      ||                  ||   (pb)     || OFF ||        |'
     &,/,
     &8x,'-----------------------------------------------------------'
     &)
2     format(
     &8x,'-----------------------------------------------------------'
     &)
3     format(
     &8x,'|  ',I2,'  || '
     &   ,a8,1x,a8,'|| ',e10.4,' || ',a3,' || ',I6,' |')
      end
      SUBROUTINE SUSANA(IUT,mfail)
****$****|****$****|****$****|****$****|****$****|****$****|****$****|**
*                                                                      *
*-- Author :    Stavros Katsanevas   14/04/95                          *
*                                                                      *
*-- Modified by Y.GAO  1/02/96                                         *
*   quite a lot changes, refer to the original code for differences    *
*
*-- Modified by P.Morawitz 22/05/96
*   update to SUSYGEN_V1.5: in mode=3 the parameters for a given MLSP ar
*                         calculated
*                                                                      *
****$****|****$****|****$****|****$****|****$****|****$****|****$****|**
      Implicit None
********************* start of commons of SUSYGEN **********************
      integer ievent
      common /eve/ ievent
      real*4  rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan(6)
      common /rkey/rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan

      real*8  gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu
      common/steer/gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu

      Integer modes,MIX
      common/mds/modes,MIX
      logical zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,higgs
      common/sparc/ zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,
     + higgs
      logical wrt,scan,lepi
      common/str/wrt,scan,lepi
      real*8  flum,ecm,s,roots,T,Q,Q2,EN
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
      real*8  QK
      COMMON/ISR/ QK(4)
      real erad,srad
      common/srada/erad(100),srad(100)
      integer  idbg,igener,irad
      COMMON /CONST/ idbg,igener,irad
      integer  index,index1,index2,nevt
      COMMON/INDEXX/index,index1,index2,nevt
      real*8   fmpr1,fmpr2,XCROST,APRO
      COMMON/FINDEX/fmpr1,fmpr2,XCROST,APRO
      real*8   cosphimix,facqcd,fgama,spartmas,ratq
      common/mixings/cosphimix,facqcd,fgama,spartmas,ratq
      real*8   FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +         FLC,FRC,gms,echar
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
      real*8      TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      real*8   fmal,fmar,ratqa,fgamc,fgamcr,cosmi
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)

      real*4 gmas,phimx
      common/stopmix/gmas(3),phimx(3)
      real*4 phimix1,stop1,phimix2,sbot1,phimix3,stau1
      equivalence (gmas(1),stop1)
      equivalence (gmas(2),sbot1)
      equivalence (gmas(3),stau1)
      equivalence (phimx(1),phimix1)
      equivalence (phimx(2),phimix2)
      equivalence (phimx(3),phimix3)
      real*4 gmas2
      common/stopmix2/gmas2(3)
      real*4 stop2,sbot2,stau2
      equivalence (gmas2(1),stop2)
      equivalence (gmas2(2),sbot2)
      equivalence (gmas2(3),stau2)
      real*4 rscale
      common/sscale/rscale
      logical imsg                      !Added by S.A. for use in the
      common/imessage/imsg              !NTONPH routine

      double precision sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      common/higgses/sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      logical fix_higgs_masses
      common/ steerhiggs / fix_higgs_masses

      integer jdebu,idb1,idb2,lout
      common /debuc/ jdebu,idb1,idb2,lout

      real*8   xgaug,xeta
      COMMON/XCROS/xgaug(8),xeta(8)

      integer  ispa,kl,klap,idecs,klr
      common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
C 04/96 P.Morawitz & M.Williams introduce klr for Rpv gaugino decays
      common/reord2/klr(3,24)
c klr(1,n), klr(2,n) and klr(3,n) are the particles produced in
c R-parity violating decays of gauginos...
C n=1..4 , 5..8	 LLE neutralino,gaugino decays
C n=9..12,13..16 LQD neutralino,gaugino decays
C n=17.20,21..24 UDD neutralino,gaugino decays

      Integer  idecsel,ihigsel
      common/decsel/idecsel(23)
      common/higsel/ihigsel(5)
C 05/96 P.Morawitz
C ...   NOTE: the logical below is used in SUSYGEN V1.5 (April 96)
C       MSSM has its own implementation of R-parity violation.
C       The logical rpar is therefore always set to TRUE which avoids
C       the SUSYGEN R-parity code.
        logical rpar
        common/rpari/rpar
      real*8   brsum,brsuma
CPM      common/brsum/ brsum(5,6,6),brsuma(6)
C 04/96 P.Morawitz & M.Williams  changed brsum to allow for r-parity dec
      common/brsum/ brsum(13,7,6),brsuma(6)
************************************************************************
c EXPLANATION OF INDICES IN BRSUM(itype,igout,igin)
c
c igin  = 1,6 initial gaugino (neutralinos 1..4, charginos 1,2)
c igout = 1,7 outgoing gaugino
c ........where 7 => no outgoing gaugino ie. R-parity violating process
c itype = types of particles produced
c     1 - l+ l-    6 - l q qbar   10 - q q q'         12 - l+ l+ l-
c     2 - v vbar   7 - l q' qbar  11 - qbar qbar qbar 13 - l v v
c     3 - q qbar   8 - v q qbar
c     4 - l v      9 - v q' qbar
c     5 - q' qbar
************************************************************************
      real*8   fms,fmi,fmk,fml1,fml2,etai,etak,brspa
     +        ,brgaug,fmelt,fmert,fmelu,fmeru
      Integer  lind
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
CPM     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
     +lind(6,6,6),brgaug(6,7,11,3),fmelt,fmert,fmelu,fmeru
C 04/96 P.Morawitz & M.Williams  changed brgaug to allow for r-parity de

************************************************************************
c     EXPLANATIONS OF INDICES IN BRGAUG AND BRSPA
c
c BRSPA::
c kgaug =1,6 produced gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c kspar =1,24 initial sparticle
c     1,12  : left-handed sparticle  (u,d,v,e,c,s,v,mu,t,b,v,tau)
c     12,24 : right handed sparticle (u,d,v,e,c,s,v,mu,t,b,v,tau)
c
c BRGAUG::
c igin =1,6 parent gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c igout =1,7 daughter gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c     7    : none (ie. R-parity violating process)
c ipart =1,6 for produced particles .....
c     R-parity conserving decays
c     1,4  : uu,dd,vv,ee                                  - 'like to lik
c     5,6  : ud,ev                                        - 'like to unl
C ipart =7,11 for the 5 diagrams which involve
C             gaugino -> gaugino' gamma
C	      gaugino -> Higgs X
C
C
C ipart =1,8 for Rp-violating!!!! decays (igout=7)
c     R-parity violating decays via LLE operator
c     1,4 :                                               - for neutrali
c     5,8 : l+ l+ l, v v l+, vbar l+ v, l+ vbar v         - for chargino
c     R-parity violating decays via LQD operator
c     1,4  : e+ u dbar, e- ubar d, v d dbar, vbar dbar d  - for neutrali
c     5,8  : v u dbar, e+ dbar d, e+ ubar u, vbar dbar u  - for chargino
c     R-parity violating decays via UDD operator
c     1,4  :						  - for neutralinos
c     5,8  : u u d, u d u, dbar dbar dbar                 - for chargino
c igen =1,3
c     R-parity conserving decays : generation of produced particles
c     R-parity violating decays  : meaningless, i.e. only igen=1 used
************************************************************************
      Real*8   zr,was,esa
      Real*8   VOIJL,VOIJR,gfir,gfil
      COMMON/NEUMIX/ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
      real*8   OIJL,OIJR,V,U,FM,ETA
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      real*8   oijlp,oijrp
      COMMON/CHANEU/oijlp(4,2),oijrp(4,2)
      Integer       ILOOP
      COMMON/SFLOOP/ILOOP
      Real*8   PV
      Integer  IFLAV,NFLAV
CPM      COMMON /PARTC / PV(5,20),IFLAV(20,2),NFLAV
CPM      update to SUSYGEN V1.5
      COMMON /PARTC / pv(5,30)
      COMMON /PARTC1 / iflav(30,2),nflav


      real*8   gw,widfl,widfr,fmeltw,fmertw,fmeluw,fmeruw,gent,gentl
      integer  linda
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,7,6)
CPM     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
C 04/96 P.Morawitz & M.Williams  changed linda to allow for r-parity dec

      integer topo_charg,topo_neut
      common /topocom/ topo_charg,topo_neut

********************* end  of commons of SUSYGEN ***********************

      Double Precision au,ad
      Integer       IUT,mfail
C
C     set the flag
C     ============
      mfail=0

C
c s.k change 9 Aug 1995
c     in third mode the neutralino LSP mass is = fmglu

      if(modes.eq.3)then
        call sucalc(mfail)
        if (mfail.ne.0) then
             write(IUT,*) 'SUSANA: error in SUCALC'
             return
        endif
      endif

C
C     calculate the mass and mixings of the sparticles
C     ================================================

      CALL sfermion(mfail)
      if( mfail.ne.0 ) then
        write(IUT,*) 'SUSANA: error in SFERMION'
        write(IUT,*) '        return code =    ',mfail
        mfail=1
        return
      endif
C
C     calculate the mass and mixings of gauginos
C     ==========================================
      CALL gaugino(mfail)
      if( mfail.ne.0 ) then
        write(IUT,*) 'SUSANA: Warning in GAUGINO'
C        mfail=2
C        return
        write(IUT,*) 'SUSANA: LSP is not the neutralino'
        mfail=0
      endif
c
c calculate higgs masses
c
      if ( .NOT. fix_higgs_masses ) then
        au=atri
        ad=atri
        CALL SUBH (sfmA,tanb,fm0,fm0,gms(9),Au,Ad,fm0,
     *           sfmh,sfmhp,sfmhpc,sina,cosa)
      endif
c
c pythia interface
c
      call pinterf
c
c
C
C
C     LEP limits: move this part to ASKUSI   Y.GAO 25/02/96
C     =====================================================
C      if(LEPI) call leplim(mfail)
C      if( mfail.ne.0 ) then
C        write(IUT,*) 'SUSANA: exclude by LEP I limit'
C        mfail=3
C        return
C      endif
C
C     calculate decay BR
C     ==================
      CALL branch
      end
      SUBROUTINE SUSETM
C----------------------------------------------------------------------
C!  -
C!
C!   Author   :- Y. Gao                 6-FEB-1996
C!
C!   Inputs:
C!        - none
C!
C!   Outputs:
C!        - none
C!
C!   Libraries required:
C!
C!   Description
C!   ===========
C!   set the mass & width of sparticles in LUND common block.
C?
C!======================================================================
      Implicit None
      INTEGER    L1MST,L1PAR
     &          ,L2PAR,L2PARF
     &          ,LJNPAR
      PARAMETER (L1MST=200, L1PAR=200)
      PARAMETER (L2PAR=500, L2PARF=2000)
      PARAMETER (LJNPAR=4000)
      COMMON /LUDAT1/ MSTU(L1MST),PARU(L1PAR),MSTJ(L1MST),PARJ(L1PAR)
      INTEGER         MSTU,MSTJ
      REAL            PARU,PARJ
      COMMON /LUDAT2/ KCHG(L2PAR,3),PMAS(L2PAR,4),PARF(L2PARF),VCKM(4,4)
      INTEGER         KCHG
      REAL            PMAS,PARF,VCKM
      COMMON /LUDAT3/ MDCY(L2PAR,3),MDME(L2PARF,2),BRAT(L2PARF),
     &                KFDP(L2PARF,5)
      INTEGER         MDCY,MDME,KFDP
      REAL            BRAT
      COMMON /LUDAT4/ CHAF(L2PAR)
      CHARACTER*8     CHAF
      COMMON /LUJETS/ N7LU,K7LU(LJNPAR,5),P7LU(LJNPAR,5),V7LU(LJNPAR,5)
      INTEGER         N7LU,K7LU
      REAL            P7LU,V7LU

      Integer       kf,ki
      Character*8   cf
      Real          mf,wf
      Integer       md
      Parameter    (md=100)
      Integer       nd
      Character*8   cd(3,md)
      Real          wd(md),bd(md)
      Character*4   ch(md)
C ---------------------------------------------------------------------
      do 10 kf=41,78
        if( kf.eq.60 ) goto 10
        if( kf.eq.69 ) goto 10
        if( kf.eq.70 ) goto 10

        ki=0
        if( kf.eq.63 ) ki=45
        if( kf.eq.64 ) ki=46
        if( kf.eq.65 ) ki=55
        if( kf.eq.66 ) ki=61
        if( kf.eq.67 ) ki=62
        if( kf.eq.68 ) ki=59
        if( kf.eq.77 ) ki=75
        if( kf.eq.78 ) ki=76
        if( ki.gt.0 ) then
          PMAS(kf,1)=PMAS(ki,1)
          PMAS(kf,2)=PMAS(ki,2)
        else
          call SUTABL(kf,cf,mf,wf,nd,cd,wd,bd,ch,0)
          PMAS(kf,1)=mf
          PMAS(kf,2)=wf
        endif
10    continue
      END
      SUBROUTINE SUTABL(k,c,m,w,nd,cd,wd,bd,ch,IPRINT)
C----------------------------------------------------------------------
C!  -
C!
C!   Author   :- Y. Gao                 5-FEB-1996
C!
C    Modified: P.Morawitz 22/05/96 include printout of Rpv processes
C              +update to SUSYGEN_V1.5
C!   Inputs:
C!        - k        LUND code of S-particle
C!        - IPRINT   1=PRINT/0=NOPRINT particle table
C!
C!   Outputs:
C!        - c        particle name
C!        - m        particle mass
C!        - w        total width (kev)
C!        -nd        total number of decay modes
C!        -cd(3,*)   the name of daughter particles
C!        -wd        partial widthes
C!        -bd        branching ratios*100
C!        -ch        '    ' if no charged conj. mode
C!                   '+cc.' if charged conj. mode
C!
C!   Libraries required:
C!
C!   Description
C!   ===========
C!
C?
C!======================================================================
      Implicit None

      Integer       k
      Character*8   c
      Real          m,w
      Integer       nd
      Character*8   cd(3,*)
      Real          wd(*),bd(*)
      Character*4   ch(*)
      Integer       IPRINT

      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
********************* start of commons of SUSYGEN **********************
      integer ievent
      common /eve/ ievent
      real*4  rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan(6)
      common /rkey/rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan

      real*8  gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu
      common/steer/gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu

      Integer modes,MIX
      common/mds/modes,MIX
      logical zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,higgs
      common/sparc/ zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,
     + higgs
      logical wrt,scan,lepi
      common/str/wrt,scan,lepi
      real*8  flum,ecm,s,roots,T,Q,Q2,EN
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
      real*8  QK
      COMMON/ISR/ QK(4)
      real erad,srad
      common/srada/erad(100),srad(100)
      integer  idbg,igener,irad
      COMMON /CONST/ idbg,igener,irad
      integer  index,index1,index2,nevt
      COMMON/INDEXX/index,index1,index2,nevt
      real*8   fmpr1,fmpr2,XCROST,APRO
      COMMON/FINDEX/fmpr1,fmpr2,XCROST,APRO
      real*8   cosphimix,facqcd,fgama,spartmas,ratq
      common/mixings/cosphimix,facqcd,fgama,spartmas,ratq
      real*8   FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +         FLC,FRC,gms,echar
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
      real*8      TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      real*8   fmal,fmar,ratqa,fgamc,fgamcr,cosmi
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)

      real*4 gmas,phimx
      common/stopmix/gmas(3),phimx(3)
      real*4 phimix1,stop1,phimix2,sbot1,phimix3,stau1
      equivalence (gmas(1),stop1)
      equivalence (gmas(2),sbot1)
      equivalence (gmas(3),stau1)
      equivalence (phimx(1),phimix1)
      equivalence (phimx(2),phimix2)
      equivalence (phimx(3),phimix3)
      real*4 gmas2
      common/stopmix2/gmas2(3)
      real*4 stop2,sbot2,stau2
      equivalence (gmas2(1),stop2)
      equivalence (gmas2(2),sbot2)
      equivalence (gmas2(3),stau2)
      real*4 rscale
      common/sscale/rscale
      logical imsg                      !Added by S.A. for use in the
      common/imessage/imsg              !NTONPH routine

      double precision sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      common/higgses/sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      logical fix_higgs_masses
      common/ steerhiggs / fix_higgs_masses

      integer jdebu,idb1,idb2,lout
      common /debuc/ jdebu,idb1,idb2,lout

      real*8   xgaug,xeta
      COMMON/XCROS/xgaug(8),xeta(8)

      integer  ispa,kl,klap,idecs,klr
      common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
C 04/96 P.Morawitz & M.Williams introduce klr for Rpv gaugino decays
      common/reord2/klr(3,24)
c klr(1,n), klr(2,n) and klr(3,n) are the particles produced in
c R-parity violating decays of gauginos...
C n=1..4 , 5..8	 LLE neutralino,gaugino decays
C n=9..12,13..16 LQD neutralino,gaugino decays
C n=17.20,21..24 UDD neutralino,gaugino decays

      Integer  idecsel,ihigsel
      common/decsel/idecsel(23)
      common/higsel/ihigsel(5)
C 05/96 P.Morawitz
C ...   NOTE: the logical below is used in SUSYGEN V1.5 (April 96)
C       MSSM has its own implementation of R-parity violation.
C       The logical rpar is therefore always set to TRUE which avoids
C       the SUSYGEN R-parity code.
        logical rpar
        common/rpari/rpar
      real*8   brsum,brsuma
CPM      common/brsum/ brsum(5,6,6),brsuma(6)
C 04/96 P.Morawitz & M.Williams  changed brsum to allow for r-parity dec
      common/brsum/ brsum(13,7,6),brsuma(6)
************************************************************************
c EXPLANATION OF INDICES IN BRSUM(itype,igout,igin)
c
c igin  = 1,6 initial gaugino (neutralinos 1..4, charginos 1,2)
c igout = 1,7 outgoing gaugino
c ........where 7 => no outgoing gaugino ie. R-parity violating process
c itype = types of particles produced
c     1 - l+ l-    6 - l q qbar   10 - q q q'         12 - l+ l+ l-
c     2 - v vbar   7 - l q' qbar  11 - qbar qbar qbar 13 - l v v
c     3 - q qbar   8 - v q qbar
c     4 - l v      9 - v q' qbar
c     5 - q' qbar
************************************************************************
      real*8   fms,fmi,fmk,fml1,fml2,etai,etak,brspa
     +        ,brgaug,fmelt,fmert,fmelu,fmeru
      Integer  lind
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
CPM     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
     +lind(6,6,6),brgaug(6,7,11,3),fmelt,fmert,fmelu,fmeru
C 04/96 P.Morawitz & M.Williams  changed brgaug to allow for r-parity de

************************************************************************
c     EXPLANATIONS OF INDICES IN BRGAUG AND BRSPA
c
c BRSPA::
c kgaug =1,6 produced gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c kspar =1,24 initial sparticle
c     1,12  : left-handed sparticle  (u,d,v,e,c,s,v,mu,t,b,v,tau)
c     12,24 : right handed sparticle (u,d,v,e,c,s,v,mu,t,b,v,tau)
c
c BRGAUG::
c igin =1,6 parent gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c igout =1,7 daughter gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c     7    : none (ie. R-parity violating process)
c ipart =1,6 for produced particles .....
c     R-parity conserving decays
c     1,4  : uu,dd,vv,ee                                  - 'like to lik
c     5,6  : ud,ev                                        - 'like to unl
C ipart =7,11 for the 5 diagrams which involve
C             gaugino -> gaugino' gamma
C	      gaugino -> Higgs X
C
C
C ipart =1,8 for Rp-violating!!!! decays (igout=7)
c     R-parity violating decays via LLE operator
c     1,4 :                                               - for neutrali
c     5,8 : l+ l+ l, v v l+, vbar l+ v, l+ vbar v         - for chargino
c     R-parity violating decays via LQD operator
c     1,4  : e+ u dbar, e- ubar d, v d dbar, vbar dbar d  - for neutrali
c     5,8  : v u dbar, e+ dbar d, e+ ubar u, vbar dbar u  - for chargino
c     R-parity violating decays via UDD operator
c     1,4  :						  - for neutralinos
c     5,8  : u u d, u d u, dbar dbar dbar                 - for chargino
c igen =1,3
c     R-parity conserving decays : generation of produced particles
c     R-parity violating decays  : meaningless, i.e. only igen=1 used
************************************************************************
      Real*8   zr,was,esa
      Real*8   VOIJL,VOIJR,gfir,gfil
      COMMON/NEUMIX/ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
      real*8   OIJL,OIJR,V,U,FM,ETA
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      real*8   oijlp,oijrp
      COMMON/CHANEU/oijlp(4,2),oijrp(4,2)
      Integer       ILOOP
      COMMON/SFLOOP/ILOOP
      Real*8   PV
      Integer  IFLAV,NFLAV
CPM      COMMON /PARTC / PV(5,20),IFLAV(20,2),NFLAV
CPM      update to SUSYGEN V1.5
      COMMON /PARTC / pv(5,30)
      COMMON /PARTC1 / iflav(30,2),nflav


      real*8   gw,widfl,widfr,fmeltw,fmertw,fmeluw,fmeruw,gent,gentl
      integer  linda
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,7,6)
CPM     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
C 04/96 P.Morawitz & M.Williams  changed linda to allow for r-parity dec

      integer topo_charg,topo_neut
      common /topocom/ topo_charg,topo_neut

********************* end  of commons of SUSYGEN ***********************


      Integer       klund
      Character*16  clund

      Integer       ksusy,fsusy
      Integer       id1,id2,id3

      Integer       i,j,l,ll,la,charge
      Integer       IUT

      Real          g_to_k,g_to_m
      Parameter    (g_to_k=1.0E+06,g_to_m=1.0E+03)

      Integer       LUCHGE
      Real*8        SSMASS
      External      LUCHGE,SSMASS

      Integer       igin,igout,igen,ipart

C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------


C
C     output unit
C     ===========
      IUT=IW(6)
C
C     get the particle name
C     =====================
      klund=k
      if( k.eq.-75 ) klund=77
      if( k.eq.-76 ) klund=78
      if( k.eq.-77 ) klund=75
      if( k.eq.-78 ) klund=76
      if( abs(k).ge.71 .or.abs(k).le.74 ) klund=abs(klund)
      call LUNAME(klund,clund)
      c      = clund(1:8)
      m      = ssmass(klund)
      charge = LUCHGE(klund)
      fsusy  = charge/3
C
C     gaugino
C     =======
      if( abs(k).ge.71 .and. abs(k).le.78 ) then
        ksusy=abs(k)-70
        if( ksusy.gt.6 ) ksusy=ksusy-2
        w    =brsuma(ksusy)

        nd=0

        do 11 igout=1,7
           do 12 igen=1,3
              do 13 ipart=1,11

                 if (brgaug(ksusy,igout,ipart,igen).le.0.0) goto 13

                 nd  = nd + 1
             IF (igout.lt.7) then
C...                R-parity conserving decays
                    i = ipart + (igen-1)*6
             ELSE
C...                R-parity breaking decays
                    i = ipart + (COUPL_I(1)-1)*8
             ENDIF

                 if(igout.le.6) then
                 if (ipart.eq.7) then
                   id1 = igout+70  ! the chi' -> chi gamma type decays
                   id2 = 22
                   id3 = 0
                 elseif (ipart.eq.8) then
                   id1 = igout+70
                   id2 = 25
                   id3 = 0
                 elseif (ipart.eq.9) then
                   id1 = igout+70
                   id2 = 35
                   id3 = 0
                 elseif (ipart.eq.10) then
                   id1 = igout+70
                   id2 = 36
                   id3 = 0
                 elseif (ipart.eq.11) then
                   id1 = igout+70
                   id2 = 37
                   id3 = 0
                 else ! normal gaugino decay
                    if( ksusy.le.4 ) then
                       id1 = -(igout+70)
                       id2 = kl(1,i)
                       id3 = kl(2,i)
                    else
                       id1 = fsusy*(igout+70)
                       id2 = fsusy*kl(1,i)
                       id3 = fsusy*kl(2,i)
                    endif
                    if( abs(id1).le.74 ) id1=abs(id1)
                    if( id1.eq.-75 ) id1=77
                    if( id1.eq.-76 ) id1=78
               endif
                 else
                    id1 = klr(1,i)
                    id2 = klr(2,i)
                    id3 = klr(3,i)
                 end if

                 call LUNAME(id1,clund)
                 cd(1,nd)=clund(1:8)
                 call LUNAME(id2,clund)
                 cd(2,nd)=clund(1:8)
               if (id3.eq.0) then
                  cd(3,nd)=' '
             else
                    call LUNAME(id3,clund)
                    cd(3,nd)=clund(1:8)
             endif

                 if( (igout.eq.5 .or. igout.eq.6)
     +                .and.(ipart.eq.5.or.ipart.eq.6)) then
                    ch(nd)='+cc.'
                    wd(nd)=brgaug(ksusy,igout,ipart,igen)*2.0d0
                    bd(nd)=brgaug(ksusy,igout,ipart,igen)*2.0d0/w
                 else
                    ch(nd)='    '
                    wd(nd)=brgaug(ksusy,igout,ipart,igen)
                    bd(nd)=brgaug(ksusy,igout,ipart,igen)/w
                 endif
 13           end do
 12        end do
 11     end do
C
C     sFermion
C     ========
      elseif( (abs(k).ge.41 .and. abs(k).le.59)
     &    .or.(abs(k).ge.61 .and. abs(k).le.62) ) then
        do i=1,12
        do j=1,2
          if( abs(k).eq.ispa(i,j) ) then
            ll=i
            la=j
          endif
        enddo
        enddo

        if( la.eq.1 ) w=widfl(ll)
        if( la.eq.2 ) w=widfr(ll)

        ksusy=12*(la-1)+ll
        nd  =0
        do 20 i=1,6
          if( brspa(i,ksusy).le.0.0d0 ) goto 20

          nd=nd+1
          ch(nd)='    '
          wd(nd)=brspa(i,ksusy)
          bd(nd)=brspa(i,ksusy)/w

          id1=70+i
          id2=idecs(ll,1)
c
c jongling with stop below top
c
          if((i.le.4).and.(((abs(k).eq.46).or.(abs(k).eq.62)).or.((abs(k
     +         ).eq.63).or.(abs(k).eq.64)))) then
             id2=4
          endif

          if(i.gt.4) then
            id2=idecs(ll,2)
            if( charge.lt.0 ) id1=-id1
          endif
          if( id1.eq.-75 ) id1=77
          if( id1.eq.-76 ) id1=78

          call LUNAME(id1,clund)
          cd(1,nd)=clund(1:8)
          call LUNAME(id2,clund)
          cd(2,nd)=clund(1:8)
          cd(3,nd)=' '
20      continue
C
C     unknown code
C     ============
      else
        write(IUT,*) 'SUTABL: unknown code = ',k
        return
      endif

      if( IPRINT.lt.1 ) RETURN
C
C     print a table for this particle
C     ===============================

      write(IUT,1)
      write(IUT,2) c
      write(IUT,3) m,w*g_to_k
      write(IUT,4)
      if( nd.eq.0 ) then
        write(IUT,5)
      else
        do i=1,nd
        if    ( bd(i).gt.1.0E-04 ) then
          write(IUT,6) cd(1,i),cd(2,i),cd(3,i),ch(i)
     &                ,wd(i)*g_to_k,bd(i)*100.0
        elseif( bd(i).gt.1.0E-07 ) then
          write(IUT,7) cd(1,i),cd(2,i),cd(3,i),ch(i)
     &                ,wd(i)*g_to_k*1000.0,bd(i)*100.0*1000.0
        else
          write(IUT,8) cd(1,i),cd(2,i),cd(3,i),ch(i)
     &                ,wd(i)*g_to_k*1000000.0,bd(i)*100.0*1000000.0
        endif
        enddo
      endif
      write(IUT,1)
1     format(10x,85('='))
2     format(10x,a8,/)
3     format(10x,10x,'Mass  = ',f12.2,'      Gev',/,
     &       10x,10x,'Width = ',f12.2,'      Kev',/)
4     format(10x,'MODE',26x
     &          ,8x
     &          ,'partial width (kev)',6x
     &          ,'Branching ratio (%)',/,10x,85('-'))
5     format(10x,'stable')
6     format(10x,a8,1x,a8,1x,a8,4x
     &          ,a4,4x
     &          ,f15.4,10x,f15.4,10x)
7     format(10x,a8,1x,a8,1x,a8,4x
     &          ,a4,4x
     &          ,f15.4,'E-03',6x,f15.4,'E-03',6x)
8     format(10x,a8,1x,a8,1x,a8,4x
     &          ,a4,4x
     &          ,f15.4,'E-06',6x,f15.4,'E-06',6x)
      END
      SUBROUTINE USCJOB
C-------------------------------------------------------------------
C! End of job routine    SUSYGEN & Lund 7.4
C
C   To be filled by user to print any relevant info
C
C------------------------------------------------------------------
      Implicit None
      Integer       MXIDHS
      Parameter    (MXIDHS=500)
      Integer       NIDOLD,IIDOLD,NIDNEW,IIDNEW
      Logical       HSKEEP
      Common/WORKHS/HSKEEP,NIDOLD,IIDOLD(MXIDHS),NIDNEW,IIDNEW(MXIDHS)
      Logical       HEXIST,XWORKH
      External      HEXIST
      Integer       i,j,icycle,istat
C
C     delete working histograms
C     =========================
      if( .not.HSKEEP ) then
        do i=1,NIDNEW
          XWORKH=.true.
          do j=1,NIDOLD
            if( IIDOLD(j).eq.IIDNEW(i) ) XWORKH=.false.
          enddo

          if( XWORKH.and.HEXIST(IIDNEW(i)) ) call HDELET(IIDNEW(i))
        enddo
      endif
C
C     end of job summary
C     ==================
      call SUPRNT(2)

C ... and write fsr histogram to disk
      IF (HSKEEP) then
      CALL HROPEN (59,'FSR','mssmfsr.his','N',1024,ISTAT)
      CALL HROUT(5010,icycle,' ')
      CALL HREND('FSR')
      endif

      RETURN
      END
      SUBROUTINE LUNAME(KF,CHAU)

C...Purpose: to give the particle/parton name as a character string.
      COMMON/LUDAT1/MSTU(200),PARU(200),MSTJ(200),PARJ(200)
      COMMON/LUDAT2/KCHG(500,3),PMAS(500,4),PARF(2000),VCKM(4,4)
      COMMON/LUDAT4/CHAF(500)
      CHARACTER CHAF*8
      SAVE /LUDAT1/,/LUDAT2/,/LUDAT4/
      CHARACTER CHAU*16

C...Initial values. Charge. Subdivide code.
      CHAU=' '
      KFA=IABS(KF)
      KC=LUCOMP(KF)
      IF(KC.EQ.0) RETURN
      KQ=LUCHGE(KF)
      KFLA=MOD(KFA/1000,10)
      KFLB=MOD(KFA/100,10)
      KFLC=MOD(KFA/10,10)
      KFLS=MOD(KFA,10)
      KFLR=MOD(KFA/10000,10)

C...Read out root name and spin for simple particle.
      IF(KFA.LE.100.OR.(KFA.GT.100.AND.KC.GT.100)) THEN
        CHAU=CHAF(KC)
        LEN=0
        DO 100 LEM=1,8
        IF(CHAU(LEM:LEM).NE.' ') LEN=LEM
  100   CONTINUE

C...Construct root name for diquark. Add on spin.
      ELSEIF(KFLC.EQ.0) THEN
        CHAU(1:2)=CHAF(KFLA)(1:1)//CHAF(KFLB)(1:1)
        IF(KFLS.EQ.1) CHAU(3:4)='_0'
        IF(KFLS.EQ.3) CHAU(3:4)='_1'
        LEN=4

C...Construct root name for heavy meson. Add on spin and heavy flavour.
      ELSEIF(KFLA.EQ.0) THEN
        IF(KFLB.EQ.5) CHAU(1:1)='B'
        IF(KFLB.EQ.6) CHAU(1:1)='T'
        IF(KFLB.EQ.7) CHAU(1:1)='L'
        IF(KFLB.EQ.8) CHAU(1:1)='H'
        LEN=1
        IF(KFLR.EQ.0.AND.KFLS.EQ.1) THEN
        ELSEIF(KFLR.EQ.0.AND.KFLS.EQ.3) THEN
          CHAU(2:2)='*'
          LEN=2
        ELSEIF(KFLR.EQ.1.AND.KFLS.EQ.3) THEN
          CHAU(2:3)='_1'
          LEN=3
        ELSEIF(KFLR.EQ.1.AND.KFLS.EQ.1) THEN
          CHAU(2:4)='*_0'
          LEN=4
        ELSEIF(KFLR.EQ.2) THEN
          CHAU(2:4)='*_1'
          LEN=4
        ELSEIF(KFLS.EQ.5) THEN
          CHAU(2:4)='*_2'
          LEN=4
        ENDIF
        IF(KFLC.GE.3.AND.KFLR.EQ.0.AND.KFLS.LE.3) THEN
          CHAU(LEN+1:LEN+2)='_'//CHAF(KFLC)(1:1)
          LEN=LEN+2
        ELSEIF(KFLC.GE.3) THEN
          CHAU(LEN+1:LEN+1)=CHAF(KFLC)(1:1)
          LEN=LEN+1
        ENDIF

C...Construct root name and spin for heavy baryon.
      ELSE
        IF(KFLB.LE.2.AND.KFLC.LE.2) THEN
          CHAU='Sigma '
          IF(KFLC.GT.KFLB) CHAU='Lambda'
          IF(KFLS.EQ.4) CHAU='Sigma*'
          LEN=5
          IF(CHAU(6:6).NE.' ') LEN=6
        ELSEIF(KFLB.LE.2.OR.KFLC.LE.2) THEN
          CHAU='Xi '
          IF(KFLA.GT.KFLB.AND.KFLB.GT.KFLC) CHAU='Xi'''
          IF(KFLS.EQ.4) CHAU='Xi*'
          LEN=2
          IF(CHAU(3:3).NE.' ') LEN=3
        ELSE
          CHAU='Omega '
          IF(KFLA.GT.KFLB.AND.KFLB.GT.KFLC) CHAU='Omega'''
          IF(KFLS.EQ.4) CHAU='Omega*'
          LEN=5
          IF(CHAU(6:6).NE.' ') LEN=6
        ENDIF

C...Add on heavy flavour content for heavy baryon.
        CHAU(LEN+1:LEN+2)='_'//CHAF(KFLA)(1:1)
        LEN=LEN+2
        IF(KFLB.GE.KFLC.AND.KFLC.GE.4) THEN
          CHAU(LEN+1:LEN+2)=CHAF(KFLB)(1:1)//CHAF(KFLC)(1:1)
          LEN=LEN+2
        ELSEIF(KFLB.GE.KFLC.AND.KFLB.GE.4) THEN
          CHAU(LEN+1:LEN+1)=CHAF(KFLB)(1:1)
          LEN=LEN+1
        ELSEIF(KFLC.GT.KFLB.AND.KFLB.GE.4) THEN
          CHAU(LEN+1:LEN+2)=CHAF(KFLC)(1:1)//CHAF(KFLB)(1:1)
          LEN=LEN+2
        ELSEIF(KFLC.GT.KFLB.AND.KFLC.GE.4) THEN
          CHAU(LEN+1:LEN+1)=CHAF(KFLC)(1:1)
          LEN=LEN+1
        ENDIF
      ENDIF

C...Add on bar sign for antiparticle (where necessary).
      IF(KF.GT.0.OR.LEN.EQ.0) THEN
      ELSEIF(KFA.GT.10.AND.KFA.LE.40.AND.KQ.NE.0.AND.MOD(KQ,3).EQ.0)
     &THEN
CYG
      ELSEIF(KFA.GT.40.AND.KFA.LE.80.AND.KQ.NE.0.AND.MOD(KQ,3).EQ.0)
     &THEN
CYG
      ELSEIF(KFA.EQ.89.OR.(KFA.GE.91.AND.KFA.LE.99)) THEN
      ELSEIF(KFA.GT.100.AND.KFLA.EQ.0.AND.KQ.NE.0) THEN
      ELSEIF(MSTU(15).LE.1) THEN
        CHAU(LEN+1:LEN+1)='~'
        LEN=LEN+1
      ELSE
        CHAU(LEN+1:LEN+3)='bar'
        LEN=LEN+3
      ENDIF

C...Add on charge where applicable (conventional cases skipped).
      IF(KQ.EQ.6) CHAU(LEN+1:LEN+2)='++'
      IF(KQ.EQ.-6) CHAU(LEN+1:LEN+2)='--'
      IF(KQ.EQ.3) CHAU(LEN+1:LEN+1)='+'
      IF(KQ.EQ.-3) CHAU(LEN+1:LEN+1)='-'
      IF(KQ.EQ.0.AND.(KFA.LE.22.OR.LEN.EQ.0)) THEN
      ELSEIF(KQ.EQ.0.AND.(KFA.GE.81.AND.KFA.LE.100)) THEN
      ELSEIF(KFA.EQ.28.OR.KFA.EQ.29) THEN
      ELSEIF(KFA.GT.100.AND.KFLA.EQ.0.AND.KFLB.EQ.KFLC.AND.
     &KFLB.NE.1) THEN
      ELSEIF(KQ.EQ.0) THEN
        CHAU(LEN+1:LEN+1)='0'
      ENDIF

      RETURN
      END
      CHARACTER*5 FUNCTION SSID(ID)
C-----------------------------------------------------------------------
C
C     Return character name for ID, assuming the default IDENT codes
C     are used in /SSTYPE/.
C                                      modified ISAJET
C-----------------------------------------------------------------------

      common/ludat4/chaf(500)
      character chaf*8

      CHARACTER*5 LABEL(-80:80)
      SAVE LABEL


      DATA LABEL(0)/'     '/

      DATA (LABEL(J),J=1,10)
     +/'DN   ','UP   ','ST   ','CH   ','BT   ','TP   '
     +,'ERROR','ERROR','ERROR','ERROR'/
      DATA (LABEL(J),J=-1,-10,-1)
     +/'DB   ','UB   ','SB   ','CB   ','BB   ','TB   '
     +,'ERROR','ERROR','ERROR','ERROR'/

      DATA (LABEL(J),J=11,20)
     +/'E-   ','NUE  ','MU-  ','NUM  ','TAU- ','NUT  '
     +,'ERROR','ERROR','ERROR','ERROR'/
      DATA (LABEL(J),J=-11,-20,-1)
     +/'E+   ','ANUE ','MU+  ','ANUM ','TAU+ ','ANUT '
     +,'ERROR','ERROR','ERROR','ERROR'/

      DATA (LABEL(J),J=21,30)
     +/'GLUON','GAMMA','Z0   ','W+   ','H0L  ','ERROR'
     +,'ERROR','ERROR','ERROR','ERROR'/
      DATA (LABEL(J),J=-21,-30,-1)
     +/'GLUON','GAMMA','Z0   ','W-   ','H0L  ','ERROR'
     +,'ERROR','ERROR','ERROR','ERROR'/

      DATA (LABEL(J),J=31,40)
     +/'ERROR','ERROR','ERROR','ERROR','H0H  ','A0   '
     +,'H+   ','ERROR','ERROR','ERROR'/
      DATA (LABEL(J),J=-31,-40,-1)
     +/'ERROR','ERROR','ERROR','ERROR','H0H  ','A0   '
     +,'H-   ','ERROR','ERROR','ERROR'/

      DATA (LABEL(J),J=41,50)
     +/'DNL  ','UPL  ','STL ','CHL  ','BT1  ','TP1  '
     +,'DNR  ','UPR  ','STR  ','CHR  '/
      DATA (LABEL(J),J=-41,-50,-1)
     +/'DNLb ','UPLb ','STLb ','CHLb ','BT1b ','TP1b '
     +,'DNRb ','UPRb ','STRb ','CHRb '/

      DATA (LABEL(J),J=51,60)
     +     /'EL-  ','NUEL ','MUL- ','NUML ','TAU1-','NUTL '
     +     ,'ER-  ','MUR- ','TAU2-','ERROR'/
      DATA (LABEL(J),J=-51,-60,-1)
     +     /'EL+  ','ANUEL','MUL+ ','ANUML','TAU1+','ANUTL'
     +     ,'ER+  ','MUR+ ','TAU2+','ERROR'/

      DATA (LABEL(J),J=61,70)
     +/'BT2  ','TP2  ','BTL  ','TPL  ','TAUL ','BTR  '
     +,'TPR  ','TAUR ','ERROR','GLSS '/
      DATA (LABEL(J),J=-61,-70,-1)
     +/'BT2b ','TP2b ','BTLb ','TPLb ','TAULb','BTRb '
     +,'TPRb ','TAURb','ERROR','GLSS '/

      DATA (LABEL(J),J=71,80)
     +/'Z1SS ','Z2SS ','Z3SS ','Z4SS ','W1SS+','W2SS+'
     +,'W1SS-','W2SS-','ERROR','ERROR'/
      DATA (LABEL(J),J=-71,-80,-1)
     +/'Z1SS ','Z2SS ','Z3SS ','Z4SS ','W1SS-','W2SS-'
     +,'W1SS+','W2SS+','ERROR','ERROR'/

      IF(IABS(ID).GT.80) THEN
CYG        WRITE(1,*) 'SSID: ID = ',ID
        STOP99
      ENDIF

CYG      if(id.ne.0)then
CYG        id1=iabs(id)
CYG        chaf(id1)=label(id1)
CYG      endif

      SSID=LABEL(ID)
      RETURN
      END
      SUBROUTINE mssm_gene
****$****|****$****|****$****|****$****|****$****|****$****|****$****|**
*-- Author :    Stavros Katsanevas   14/04/95                          *
*                                                                      *
*-- Modified by Y.GAO    5/02/96                                       *
*                                                                      *
****$****|****$****|****$****|****$****|****$****|****$****|****$****|**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)


      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
      COMMON/INDEXX/index,index1,index2,nevt
      COMMON/FINDEX/fmpr1,fmpr2,XCROST,APRO


      COMMON/ISR/ QK(4)
      COMMON /CONST/ idbg,igener,irad

      real erad,srad
      common/srada/erad(100),srad(100)
      logical wrt,scan,lepi
      common/str/wrt,scan,lepi

      external gensel,gensmu,gensnue,gensnu,photi

      common/kev/jev
C
C       MAXIMUM OF  PRODUCTION, UNIFORM STEP SAMPLING
C
      if(nevt.lt.1)return

CYG      if(irad.eq.1)then
CYG        STEP = 2.
CYG        NSORT =ecm/step
CYG        ZSLEPT = 0.
CYG        DO 10 J=1,NSORT
CYG          ZSLEPT = ZSLEPT+STEP
CYG          s=zslept**2
CYG          roots=dsqrt(s)
CYG          if(index.eq.1)amplit=photi(index1,index2)
CYG          if(index.eq.2)amplit=chargi(index1,index2)
CYG          if(index.eq.3)then
CYG            IF(INDEX1.EQ.51.or.index1.eq.57)then
CYG              if(index1.eq.-index2)amplit=ssdint(-1.d0,gensel,1.d0)
CYG              if(index1.ne.-index2)amplit=genselrs(dummy)
CYG            elseif(index1.eq.52)then
CYG              amplit=ssdint(-1.d0,gensnue,1.d0)
CYG            elseif(index1.eq.54.or.index1.eq.56)then
CYG              amplit=ssdint(-1.d0,gensnu,1.d0)
CYG            else
CYG              amplit=gensmus(dummy)
CYG            endif
CYG          endif
CYG          erad(j)=real(roots)
CYG          srad(j)=real(amplit)
CYG          if(srad(j).ne.0.)write(1,10000) erad(j),srad(j)
CYG10000 format('  ECM =  ',f10.3,'  CROSS SECTION =  ',f10.3)
CYG   10   CONTINUE
CYG      endif


      s=ecm**2

      nfail=0

      DO 30 JEV=1,NEVT

   20   continue

        CALL suseve(ifail)

        if(ifail.eq.1)then
          nfail=nfail+1
          if(nfail.gt.1000)then
            print *,' warning nfail = ',nfail,' event = ',jev
            print *,' ********  Event skipped  ******** '
            nfail=0
            goto 30
          endif
          go to 20
        endif

c
c
c write Lund common LUJETS to LUNIT
c
        if(wrt) CALL SXWRLU(12)

        call user

   30 CONTINUE


      RETURN
      END
      subroutine branch
****$****|****$****|****$****|****$****|****$****|****$****|****$****|**
*-- Author :    Stavros Katsanevas   14/04/95                          *
*-- Modified by Y. Gao               06/02/96                          *
*
*-- Modified by P.Morawitz & M.Williams ../04/96
*       to allow inclusion of R-parity violation
*
*-- Modified by P.Morawitz 20/05/96 updated to SUSYGEN V1.5 which simula
*--            gaugino ->  gaugino' gamma
*--            gaugino ->  Higgs + X
****$****|****$****|****$****|****$****|****$****|****$****|****$****|**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)


      COMMON/OUTMAP/ND,NDIM0,XI(50,10)


      COMMON/SDECAY/DAS,DBS,DCS,DATL,DAUL,DATUL,DASTL,DBSTL,DASUL,
     +DBSUL,DATR,DAUR,DATUR,DASTR,DBSTR,DASUR,DBSUR,xdec(17,64)
      DIMENSION CURRENT(17)
      EQUIVALENCE (CURRENT(1),DAS)


      logical logvar
      logical hexist
      external hexist
      external sbrdec
      real sbrdec
      external wsc,brodec1,brodec2,brodec3
      real pmsb,pmub

      character*80 histtit
********************* start of commons of SUSYGEN **********************
      integer ievent
      common /eve/ ievent
      real*4  rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan(6)
      common /rkey/rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan

      real*8  gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu
      common/steer/gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu

      Integer modes,MIX
      common/mds/modes,MIX
      logical zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,higgs
      common/sparc/ zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,
     + higgs
      logical wrt,scan,lepi
      common/str/wrt,scan,lepi
      real*8  flum,ecm,s,roots,T,Q,Q2,EN
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
      real*8  QK
      COMMON/ISR/ QK(4)
      real erad,srad
      common/srada/erad(100),srad(100)
      integer  idbg,igener,irad
      COMMON /CONST/ idbg,igener,irad
      integer  index,index1,index2,nevt
      COMMON/INDEXX/index,index1,index2,nevt
      real*8   fmpr1,fmpr2,XCROST,APRO
      COMMON/FINDEX/fmpr1,fmpr2,XCROST,APRO
      real*8   cosphimix,facqcd,fgama,spartmas,ratq
      common/mixings/cosphimix,facqcd,fgama,spartmas,ratq
      real*8   FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +         FLC,FRC,gms,echar
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
      real*8      TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      real*8   fmal,fmar,ratqa,fgamc,fgamcr,cosmi
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)

      real*4 gmas,phimx
      common/stopmix/gmas(3),phimx(3)
      real*4 phimix1,stop1,phimix2,sbot1,phimix3,stau1
      equivalence (gmas(1),stop1)
      equivalence (gmas(2),sbot1)
      equivalence (gmas(3),stau1)
      equivalence (phimx(1),phimix1)
      equivalence (phimx(2),phimix2)
      equivalence (phimx(3),phimix3)
      real*4 gmas2
      common/stopmix2/gmas2(3)
      real*4 stop2,sbot2,stau2
      equivalence (gmas2(1),stop2)
      equivalence (gmas2(2),sbot2)
      equivalence (gmas2(3),stau2)
      real*4 rscale
      common/sscale/rscale
      logical imsg                      !Added by S.A. for use in the
      common/imessage/imsg              !NTONPH routine

      double precision sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      common/higgses/sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      logical fix_higgs_masses
      common/ steerhiggs / fix_higgs_masses

      integer jdebu,idb1,idb2,lout
      common /debuc/ jdebu,idb1,idb2,lout

      real*8   xgaug,xeta
      COMMON/XCROS/xgaug(8),xeta(8)

      integer  ispa,kl,klap,idecs,klr
      common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
C 04/96 P.Morawitz & M.Williams introduce klr for Rpv gaugino decays
      common/reord2/klr(3,24)
c klr(1,n), klr(2,n) and klr(3,n) are the particles produced in
c R-parity violating decays of gauginos...
C n=1..4 , 5..8	 LLE neutralino,gaugino decays
C n=9..12,13..16 LQD neutralino,gaugino decays
C n=17.20,21..24 UDD neutralino,gaugino decays

      Integer  idecsel,ihigsel
      common/decsel/idecsel(23)
      common/higsel/ihigsel(5)
C 05/96 P.Morawitz
C ...   NOTE: the logical below is used in SUSYGEN V1.5 (April 96)
C       MSSM has its own implementation of R-parity violation.
C       The logical rpar is therefore always set to TRUE which avoids
C       the SUSYGEN R-parity code.
        logical rpar
        common/rpari/rpar
      real*8   brsum,brsuma
CPM      common/brsum/ brsum(5,6,6),brsuma(6)
C 04/96 P.Morawitz & M.Williams  changed brsum to allow for r-parity dec
      common/brsum/ brsum(13,7,6),brsuma(6)
************************************************************************
c EXPLANATION OF INDICES IN BRSUM(itype,igout,igin)
c
c igin  = 1,6 initial gaugino (neutralinos 1..4, charginos 1,2)
c igout = 1,7 outgoing gaugino
c ........where 7 => no outgoing gaugino ie. R-parity violating process
c itype = types of particles produced
c     1 - l+ l-    6 - l q qbar   10 - q q q'         12 - l+ l+ l-
c     2 - v vbar   7 - l q' qbar  11 - qbar qbar qbar 13 - l v v
c     3 - q qbar   8 - v q qbar
c     4 - l v      9 - v q' qbar
c     5 - q' qbar
************************************************************************
      real*8   fms,fmi,fmk,fml1,fml2,etai,etak,brspa
     +        ,brgaug,fmelt,fmert,fmelu,fmeru
      Integer  lind
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
CPM     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
     +lind(6,6,6),brgaug(6,7,11,3),fmelt,fmert,fmelu,fmeru
C 04/96 P.Morawitz & M.Williams  changed brgaug to allow for r-parity de

************************************************************************
c     EXPLANATIONS OF INDICES IN BRGAUG AND BRSPA
c
c BRSPA::
c kgaug =1,6 produced gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c kspar =1,24 initial sparticle
c     1,12  : left-handed sparticle  (u,d,v,e,c,s,v,mu,t,b,v,tau)
c     12,24 : right handed sparticle (u,d,v,e,c,s,v,mu,t,b,v,tau)
c
c BRGAUG::
c igin =1,6 parent gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c igout =1,7 daughter gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c     7    : none (ie. R-parity violating process)
c ipart =1,6 for produced particles .....
c     R-parity conserving decays
c     1,4  : uu,dd,vv,ee                                  - 'like to lik
c     5,6  : ud,ev                                        - 'like to unl
C ipart =7,11 for the 5 diagrams which involve
C             gaugino -> gaugino' gamma
C	      gaugino -> Higgs X
C
C
C ipart =1,8 for Rp-violating!!!! decays (igout=7)
c     R-parity violating decays via LLE operator
c     1,4 :                                               - for neutrali
c     5,8 : l+ l+ l, v v l+, vbar l+ v, l+ vbar v         - for chargino
c     R-parity violating decays via LQD operator
c     1,4  : e+ u dbar, e- ubar d, v d dbar, vbar dbar d  - for neutrali
c     5,8  : v u dbar, e+ dbar d, e+ ubar u, vbar dbar u  - for chargino
c     R-parity violating decays via UDD operator
c     1,4  :						  - for neutralinos
c     5,8  : u u d, u d u, dbar dbar dbar                 - for chargino
c igen =1,3
c     R-parity conserving decays : generation of produced particles
c     R-parity violating decays  : meaningless, i.e. only igen=1 used
************************************************************************
      Real*8   zr,was,esa
      Real*8   VOIJL,VOIJR,gfir,gfil
      COMMON/NEUMIX/ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
      real*8   OIJL,OIJR,V,U,FM,ETA
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      real*8   oijlp,oijrp
      COMMON/CHANEU/oijlp(4,2),oijrp(4,2)
      Integer       ILOOP
      COMMON/SFLOOP/ILOOP
      Real*8   PV
      Integer  IFLAV,NFLAV
CPM      COMMON /PARTC / PV(5,20),IFLAV(20,2),NFLAV
CPM      update to SUSYGEN V1.5
      COMMON /PARTC / pv(5,30)
      COMMON /PARTC1 / iflav(30,2),nflav


      real*8   gw,widfl,widfr,fmeltw,fmertw,fmeluw,fmeruw,gent,gentl
      integer  linda
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,7,6)
CPM     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
C 04/96 P.Morawitz & M.Williams  changed linda to allow for r-parity dec

      integer topo_charg,topo_neut
      common /topocom/ topo_charg,topo_neut

********************* end  of commons of SUSYGEN ***********************

C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------

        LOGICAL Rparity
        COMMON/RpaSwi/ Rparity

      Integer       MXIDHS
      Parameter    (MXIDHS=500)
      Integer       NIDOLD,IIDOLD,NIDNEW,IIDNEW
      Logical       HSKEEP
      Common/WORKHS/HSKEEP,NIDOLD,IIDOLD(MXIDHS),NIDNEW,IIDNEW(MXIDHS)
      double precision hfil,hfir,yuk
      dimension hfil(4,12),hfir(4,12),yuk(12)

C     PM     ... bug : ulmass is real in jetset
      real ulmass

      IF (RPARITY) CALL RPARINIT
      IF (RPARITY) CALL RPARBRANCH
      IF ((RPARITY).and.HSKEEP) CALL RPARHISTO

c
c  sparticle widths
c

        do 51  l=1,12
          yuk(l)= gms(l)/dsqrt(2.d0)/fmw/sinb
      DO 51  i=1,4
          HFIL(i,l)= -yuk(l)*(-zr(3,i)*sinb+zr(4,i)*cosb)
          HFIR(i,l)= HFIL(i,l)
   51 CONTINUE

      do 50 k=1,12

        cos2=cosmi(k)**2
        sin2=1.d0-cos2

        widfr(k)=0.
        widfl(k)=0.

        do 10 l=1,6

          index=70+l
          fmii=ssmass(index)

          ik1=idecs(k,1)
          if(l.gt.4)ik1=idecs(k,2)
          fmpart=ssmass(ik1)

          brspa(l,k)=0
          brspa(l,k+12)=0
          k1=mod(k-1,4)+1
          k2=mod(k-1,2)+1

          if(fmal(k).gt.(fmii+fmpart))then
c
c         zero quark mass approximation
c
          fla=xlamda(fmal(k)**2,fmpart**2,fmii**2)
      const=g2*fla/16.d0/pi/fmal(k)**3*(fmal(k)**2-fmii**2-fmpart**2)
          if(const.eq.0.)go to 10
          rat=4.*xeta(l)*fmpart*fmii/(fmal(k)**2-fmii**2-fmpart**2)

          if(l.lt.5)then
          a1=hfil(l,k)**2+gfil(l,k1)**2
          a2=-rat*gfil(l,k1)*hfil(l,k)
          else
          if(k2.eq.1)then
          a1=v(l-4,1)**2+u(l-4,2)**2*yuk(k)**2
          a2=+rat*v(l-4,1)*u(l-4,2)*yuk(k)
          else
          a1=u(l-4,1)**2+v(l-4,2)**2*yuk(k)**2
          a2=+rat*u(l-4,1)*v(l-4,2)*yuk(k)
          endif
          endif

          brspa(l,k)=const*(a1+a2*rat)

          endif

          if(fmar(k).gt.(fmii+fmpart))then
c
c         zero quark mass approximation
c
          fla=xlamda(fmar(k)**2,fmpart**2,fmii**2)
      const=g2*fla/16.d0/pi/fmar(k)**3*(fmar(k)**2-fmii**2-fmpart**2)
          if(const.eq.0.)go to 10
          rat=4.*xeta(l)*fmpart*fmii/(fmar(k)**2-fmii**2-fmpart**2)

          if(l.lt.5)then
          a1=hfir(l,k)**2+gfir(l,k1)**2
          a2=-rat*gfir(l,k1)*hfir(l,k)
          else
          if(k2.eq.1)then
          a1=v(l-4,2)**2*yuk(k)**2
          a2=0.
          else
          a1=u(l-4,2)**2*yuk(k)**2
          a2=0.
          endif
          endif

          brspa(l,k+12)=const*(a1+a2*rat)

          endif


c stop below top

        if(k.eq.9.and.l.lt.5)then
        if((fmal(k).lt.gms(9)+fmii).and.fmal(k).gt.fmii)then
      brspa(l,k)=0.0000000003d0/fmal(k)**3*(fmal(k)**2-fmii**2)**2
        endif
        if((fmar(k).lt.gms(9)+fmii).and.fmar(k).gt.fmii)then
      brspa(l,k+12)=0.0000000003d0/fmar(k)**3*(fmar(k)**2-fmii**2)**2
        endif
        endif

        widfl(k)=widfl(k)+brspa(l,k)
        widfr(k)=widfr(k)+brspa(l,k+12)

c
c take into accout the mixing
c
        br1=brspa(l,k)*cos2+brspa(l,k+12)*sin2
        br2=brspa(l,k)*sin2+brspa(l,k+12)*cos2
        brspa(l,k)=br1
        brspa(l,k+12)=br2

   10   continue
   50 continue

      call wiconst

      fma=ssmass(71)
      fmb=ssmass(75)

      indx=0

c
c initialise all widths to zero
c
      do index1=1,6
         do index2=1,7
            do ipart=1,11
               do igen=1,3
                  brgaug(index1,index2,ipart,igen) = 0.
               end do
            end do
         end do
      end do

CMW ====================================================================
CMW   Now the Chargino decays, Rparity conserving ...
CMW ====================================================================
      do 80 index1=1,6
        do 80 index2=1,6
          do 80 igen=1,3
             do 80 ipart=1,11
c
c products
c
            if(index1.gt.4)call absalom

            if (ipart.gt.6) goto 88
C ...       skip pointer assignment of 3-body decay index if decay is no
C           a genuine gaugino decay but a Z2 -> Z1 gamma decay for examp

            nc=lind(ipart,index2,index1)
            if(nc.eq.0)go to 80
c
 88         fmi=ssmass(70+index1)
            fmk=ssmass(70+index2)


CYG get them all
CYG            if(index1.le.4.and.(fmi+fma).gt.ecm)go to 80
CYG            if(index1.gt.4.and.(fmi+fmb).gt.ecm)go to 80
CYG
          IF (igen.eq.1) then
C ...          If the decay is a Gaugino -> Gaugino Higgs or Gaugino gam
C             then go to end of loop
               if(ipart.eq.7)go to 44
               if(ipart.gt.7.and.ipart.le.10)go to 444
               if(ipart.eq.11)go to 4444
            ELSEIF (ipart.gt.6) then
C ...             not a valid decay - skip
               GOTO 80
            ENDIF
c
c find mass of 2 fermion products
c
            i1 = ipart + (igen-1)*6
            imk1=kl(1,i1)
            imk2=kl(2,i1)

            fml1=ssmass(imk1)
            fml2=ssmass(imk2)

c
c permit the creation of true particles, so at least 2 hadrons
c must be formed
c
            if(iabs(imk1).eq.1)fml1=ulmass(211)
            if(iabs(imk1).eq.2)fml1=ulmass(211)
            if(iabs(imk1).eq.3)fml1=ulmass(321)
            if(iabs(imk1).eq.4)fml1=ulmass(411)
            if(iabs(imk1).eq.5)fml1=ulmass(521)

            if(iabs(imk2).eq.1)fml2=ulmass(211)
            if(iabs(imk2).eq.2)fml2=ulmass(211)
            if(iabs(imk2).eq.3)fml2=ulmass(321)
            if(iabs(imk2).eq.4)fml2=ulmass(411)
            if(iabs(imk2).eq.5)fml2=ulmass(521)

c
c check whether I have enough energy to produce them
c
            q=fmi-fmk-fml1-fml2
            if(q.lt.0.)go to 80

            smin=(fml1+fml2)**2
            smax=(fmi-fmk)**2

            umin=(fmk+fml2)**2
            umax=(fmi-fml1)**2

            tmin=(fmk+fml1)**2
            tmax=(fmi-fml2)**2


            if(smin.ge.smax)go to 80
            if(umin.ge.umax)go to 80
            if(tmin.ge.tmax)go to 80

c
c intermediate particles
c

            fms=fmz
            gw=fmz*gammaz

            if(index1.gt.4.and.index2.le.4)then
              fms=fmw
              gw=fmw*gammaw
            endif

            if(index2.gt.4.and.index1.le.4)then
              fms=fmw
              gw=fmw*gammaw
            endif

c
c     sparticles....
c
            lk1= klap(1,i1)
            lk2= klap(2,i1)


            do 60 k=1,12
              if(ispa(k,1).eq.lk1)then

                fmelt=fmal(k)
                fmert=fmar(k)
                fmeltw=widfl(k)*fmelt
                fmertw=widfr(k)*fmert
c
c different for 3d generation because of mixing.
c
                if(k.ge.9)then
                  cos2=cosmi(k)**2
                  sin2=1.d0-cos2
C.. ld correction Stavros 1/05/97
C                  fmelt=dsqrt(fmal(k)**2*cos2+fmar(k)*sin2)
C                  fmert=dsqrt(fmar(k)**2*cos2+fmal(k)*sin2)
                  fmelt=dsqrt(fmal(k)**2*cos2+fmar(k)**2*sin2)
                  fmert=dsqrt(fmar(k)**2*cos2+fmal(k)**2*sin2)
                endif

              endif
              if(ispa(k,1).eq.lk2)then
                fmelu=fmal(k)
                fmeru=fmar(k)
                fmeluw=widfl(k)*fmelu
                fmeruw=widfr(k)*fmeru
c
c different for 3d generation because of mixing.
c
                if(k.ge.9)then
                  cos2=cosmi(k)**2
                  sin2=1.d0-cos2
C.. ld correction Stavros 1/05/97
C                  fmelu=dsqrt(fmal(k)**2*cos2+fmar(k)*sin2)
C                  fmeru=dsqrt(fmar(k)**2*cos2+fmal(k)*sin2)
                  fmelu=dsqrt(fmal(k)**2*cos2+fmar(k)**2*sin2)
                  fmeru=dsqrt(fmar(k)**2*cos2+fmal(k)**2*sin2)
                  fmeluw=(widfl(k)*cos2+widfr(k)*sin2)*fmelu
                  fmeruw=(widfr(k)*cos2+widfl(k)*sin2)*fmeru
                endif
              endif

   60       continue


            etai=xeta(index1)
            etak=xeta(index2)
c
c decay constants
c
            do 70 j=1,17
   70       current(j)=xdec(j,nc)

C
C -- Integration of the partial widths
C
            if((smax-smin).gt.1.)then
               fa1=ssdint(smin,wsc,smax)
               if(fa1.lt.0.) then
                  write (*,*) ' BRANCH: Warning, fa1 negative = '
     +                ,fa1,' pars=',index1,index2,ipart,igen,i1
                  fa1=0.
               endif
            else
               sb=(smax-smin)/2.
               fa1=wsc(sb)*(smax-smin)
               if(fa1.lt.0.) then
                  write (*,*) ' BRANCH: Warning2, fa1 negative = '
     +                  ,fa1,' pars=',index1,index2,ipart,igen,i1
                  fa1=0.
               endif
               write (*,801) index2, index1, ipart,igen,i1
 801      format(' small q value for ',3i5,' approximation taken')
            endif

c      call VEGAS(brodec1,0.005d0,2,5000,20,0,0,avgi1,SD1,IT1)
c      call VEGAS(brodec2,0.005d0,2,5000,20,0,0,avgi2,SD2,IT2)
c      call VEGAS(brodec3,0.005d0,2,5000,20,0,0,avgi3,SD3,IT3)
c      avgi=avgi1+avgi2+avgi3
c      if(avgi.eq.0.)go to 4
c      diff=(avgi-fa1)/fa1*100.
c      idiff=diff
c      if(dabs(diff).gt.2.d0)then
c      print *,' WARNING '
c      print *,' vegas differs from analytical by ',idiff,'%'
c      print *,' vegas ',avgi,it1,it2,it3
c      print *,' analytical ',fa1
c      print *,' decay type  ',index1,index2,i1
c      endif

          write (*,*) index1,index2,ipart,igen,fa1
            brgaug(index1,index2,ipart,igen)=fa1

            if(igener.eq.0)go to 80
c
c prepare throwing matrix
c
            indx=indx+1
            if(indx.gt.168)then
              print *,' error more than 168 BR '
              stop 99
            endif

            linda(i1,index2,index1)=indx

c      gentl(1,1,indx)=smin
c      gentl(2,1,indx)=smax
c      gentl(1,2,indx)=umin
c      gentl(2,2,indx)=umax
c      do 441 li=1,50
c      sb=xi(li,1)*(smax-smin)+smin
c      ub=xi(li,2)*(umax-umin)+umin
c      gent(li,1,indx)=sb
c      gent(li,2,indx)=ub
c 441  continue

            nbin1=100
            nbin2=100
            logvar=hexist(indx)
            if(logvar)call hdelet(indx)
            write (histtit,11) index1,index2,ipart,igen
 11         format('chi',i1,' -> chi',i1,' + f.s.',i2,' (generation=',i1
     +           ,')')
            call hbfun2(indx,histtit,nbin1,sngl(smin),sngl(smax) ,nbin2,
     +      sngl(umin),sngl(umax),sbrdec)

C ... check the e-dis of charginos (light sneutrinos)
            if ((((index1.eq.5).and.(index2.eq.1)).and.(igen.eq.1)).and
     +           .(ipart.eq.5)) then
               call hbook1(8889
     +         ,'Check histo / Edis(snu) for chi+1->snu+l->chi0+nu+l ',
     +               100,0.,100.,0.)
               call hbfun2(8888,histtit,nbin1,sngl(smin),sngl(smax)
     +              ,nbin2,sngl(umin),sngl(umax),sbrdec)
               do ipm=1,1000000
                  call hrndm2(indx,pmsb,pmub)
                  call hf1(8889,
     +                 real((fmi**2+fmk**2-pmsb)/2./fmi),1.)
               enddo
            endif


       goto 80


C ---------------------------------------------------------------------
C And now for the decays Gaugino -> Gaugino' X where X=Higgs,gamma
C ---------------------------------------------------------------------
  44  continue

      if(index1.gt.4.or.index2.gt.3)go to 4
      if(index1.eq.1)go to 4
      if(index1.le.index2)go to 4

      ogntonp = 0.0d0
      call  NTONPH(index1,index2,FM0,FMGAUG,FMR,TANB,GMS(9),
     + oGNTONP)

      brgaug(index1,index2,7,1)=ogntonp
      go to 4

 444  continue

      if(index1.gt.4.or.index2.gt.3)go to 4
      if(index1.eq.1)go to 4
      if(index1.le.index2)go to 4

      ogntonlh  = 0.0d0
      ogntonhh  = 0.0d0
      ogntona   = 0.0d0
      ogntochpm = 0.0d0
      call  NTOXH(index1,index2,FM0,FMGAUG,FMR,TANB,GMS(9),
     + oGNTONLH, oGNTONHH, oGNTONA, oGNTOCHPM)

      if(ipart.eq.8)then
       brgaug(index1,index2,8,1)=ogntonlh
      else if(ipart.eq.9)then
       brgaug(index1,index2,9,1)=ogntonhh
      else if(ipart.eq.10)then
       brgaug(index1,index2,10,1)=ogntona
      endif
      go to 4

 4444 continue

      if(index1.eq.1.or.index1.gt.4)go to 4
      if(index2.lt.5)go to 4

      ogntonlh  = 0.0d0
      ogntonhh  = 0.0d0
      ogntona   = 0.0d0
      ogntochpm = 0.0d0
      call  NTOXH(index1,index2,FM0,FMGAUG,FMR,TANB,GMS(9),
     + oGNTONLH, oGNTONHH, oGNTONA, oGNTOCHPM)

      brgaug(index1,index2,11,1)=ogntochpm

   4  continue

   80 continue


CMW ====================================================================
CMW   Now the Chargino decays, Rparity violating ...
CMW ====================================================================
      do 90 index1=1,6
        do 90 index2=7,7
          do 90 igen=1,1
             do 90 ipart=1,4

             i1=ipart
             if (index1.gt.4) i1=i1+4

             if (index1.le.4) fa1=ngamma(index1,ipart)
             if (index1.gt.4) fa1=cgamma(index1-4,ipart)
               brgaug(index1,index2,i1,igen)=fa1
               if(igener.eq.0)go to 90
c
c prepare throwing matrix
c
             if (fa1.gt.0.) then
                  indx=indx+1
C ... Neut,Chargino LLE,LQD,UDD decays are 4+4 4+4 2+3 => 168+21
                  if(indx.gt.189)then
                    print *,' error more than 189 BR '
                    stop 99
                  endif

                  linda(i1,index2,index1)=indx

                  nbin1=100
                  nbin2=100
                  logvar=hexist(indx)
                  if(logvar)call hdelet(indx)

C              call tmkrparh(indx,5,1,
C     +                                          nbin1,nbin2)
              call mkrparh(indx,index1,ipart,
     +                                          nbin1,nbin2)
             endif

   90 continue



      CALL INTERF

      IF (RPARITY) CALL RPARPRINT

      return
      end
      double precision FUNCTION wsc(sb)
****$****|****$****|****$****|****$****|****$****|****$****|****$****|**
*                                                                      *
*-- Author :    Stavros Katsanevas   14/04/95                          *
*-- Modified by Y.GAO to deal the crash with right sneutrinos  6/02/96 *
*
*-- Modified by P.Morawitz 22/05/96
*       modification no longer needed as it is already implemented
*       in SUSYGEN_V1.5
*
*-- Modified by P.Morawitz 5/07/96 fixed bug (missaligned commons)
*   which resulted in wrong BRs for gauginos !!!
*-- But still need to include in mssm02.input - as common blocks have
*   changed
****$****|****$****|****$****|****$****|****$****|****$****|****$****|**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)

      COMMON/SDECAY/DAS,DBS,DCS,DATL,DAUL,DATUL,DASTL,DBSTL,DASUL,
     +DBSUL,DATR,DAUR,DATUR,DASTR,DBSTR,DASUR,DBSUR,xdec(17,64)

      common/mass/sfmi,sfmk,sfms,sgw,sfmelt,sfmelu,alt,alu,c0

********************* start of commons of SUSYGEN **********************
      integer ievent
      common /eve/ ievent
      real*4  rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan(6)
      common /rkey/rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan

      real*8  gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu
      common/steer/gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu

      Integer modes,MIX
      common/mds/modes,MIX
      logical zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,higgs
      common/sparc/ zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,
     + higgs
      logical wrt,scan,lepi
      common/str/wrt,scan,lepi
      real*8  flum,ecm,s,roots,T,Q,Q2,EN
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
      real*8  QK
      COMMON/ISR/ QK(4)
      real erad,srad
      common/srada/erad(100),srad(100)
      integer  idbg,igener,irad
      COMMON /CONST/ idbg,igener,irad
      integer  index,index1,index2,nevt
      COMMON/INDEXX/index,index1,index2,nevt
      real*8   fmpr1,fmpr2,XCROST,APRO
      COMMON/FINDEX/fmpr1,fmpr2,XCROST,APRO
      real*8   cosphimix,facqcd,fgama,spartmas,ratq
      common/mixings/cosphimix,facqcd,fgama,spartmas,ratq
      real*8   FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +         FLC,FRC,gms,echar
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
      real*8      TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      real*8   fmal,fmar,ratqa,fgamc,fgamcr,cosmi
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)

      real*4 gmas,phimx
      common/stopmix/gmas(3),phimx(3)
      real*4 phimix1,stop1,phimix2,sbot1,phimix3,stau1
      equivalence (gmas(1),stop1)
      equivalence (gmas(2),sbot1)
      equivalence (gmas(3),stau1)
      equivalence (phimx(1),phimix1)
      equivalence (phimx(2),phimix2)
      equivalence (phimx(3),phimix3)
      real*4 gmas2
      common/stopmix2/gmas2(3)
      real*4 stop2,sbot2,stau2
      equivalence (gmas2(1),stop2)
      equivalence (gmas2(2),sbot2)
      equivalence (gmas2(3),stau2)
      real*4 rscale
      common/sscale/rscale
      logical imsg                      !Added by S.A. for use in the
      common/imessage/imsg              !NTONPH routine

      double precision sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      common/higgses/sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      logical fix_higgs_masses
      common/ steerhiggs / fix_higgs_masses

      integer jdebu,idb1,idb2,lout
      common /debuc/ jdebu,idb1,idb2,lout

      real*8   xgaug,xeta
      COMMON/XCROS/xgaug(8),xeta(8)

      integer  ispa,kl,klap,idecs,klr
      common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
C 04/96 P.Morawitz & M.Williams introduce klr for Rpv gaugino decays
      common/reord2/klr(3,24)
c klr(1,n), klr(2,n) and klr(3,n) are the particles produced in
c R-parity violating decays of gauginos...
C n=1..4 , 5..8	 LLE neutralino,gaugino decays
C n=9..12,13..16 LQD neutralino,gaugino decays
C n=17.20,21..24 UDD neutralino,gaugino decays

      Integer  idecsel,ihigsel
      common/decsel/idecsel(23)
      common/higsel/ihigsel(5)
C 05/96 P.Morawitz
C ...   NOTE: the logical below is used in SUSYGEN V1.5 (April 96)
C       MSSM has its own implementation of R-parity violation.
C       The logical rpar is therefore always set to TRUE which avoids
C       the SUSYGEN R-parity code.
        logical rpar
        common/rpari/rpar
      real*8   brsum,brsuma
CPM      common/brsum/ brsum(5,6,6),brsuma(6)
C 04/96 P.Morawitz & M.Williams  changed brsum to allow for r-parity dec
      common/brsum/ brsum(13,7,6),brsuma(6)
************************************************************************
c EXPLANATION OF INDICES IN BRSUM(itype,igout,igin)
c
c igin  = 1,6 initial gaugino (neutralinos 1..4, charginos 1,2)
c igout = 1,7 outgoing gaugino
c ........where 7 => no outgoing gaugino ie. R-parity violating process
c itype = types of particles produced
c     1 - l+ l-    6 - l q qbar   10 - q q q'         12 - l+ l+ l-
c     2 - v vbar   7 - l q' qbar  11 - qbar qbar qbar 13 - l v v
c     3 - q qbar   8 - v q qbar
c     4 - l v      9 - v q' qbar
c     5 - q' qbar
************************************************************************
      real*8   fms,fmi,fmk,fml1,fml2,etai,etak,brspa
     +        ,brgaug,fmelt,fmert,fmelu,fmeru
      Integer  lind
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
CPM     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
     +lind(6,6,6),brgaug(6,7,11,3),fmelt,fmert,fmelu,fmeru
C 04/96 P.Morawitz & M.Williams  changed brgaug to allow for r-parity de

************************************************************************
c     EXPLANATIONS OF INDICES IN BRGAUG AND BRSPA
c
c BRSPA::
c kgaug =1,6 produced gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c kspar =1,24 initial sparticle
c     1,12  : left-handed sparticle  (u,d,v,e,c,s,v,mu,t,b,v,tau)
c     12,24 : right handed sparticle (u,d,v,e,c,s,v,mu,t,b,v,tau)
c
c BRGAUG::
c igin =1,6 parent gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c igout =1,7 daughter gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c     7    : none (ie. R-parity violating process)
c ipart =1,6 for produced particles .....
c     R-parity conserving decays
c     1,4  : uu,dd,vv,ee                                  - 'like to lik
c     5,6  : ud,ev                                        - 'like to unl
C ipart =7,11 for the 5 diagrams which involve
C             gaugino -> gaugino' gamma
C	      gaugino -> Higgs X
C
C
C ipart =1,8 for Rp-violating!!!! decays (igout=7)
c     R-parity violating decays via LLE operator
c     1,4 :                                               - for neutrali
c     5,8 : l+ l+ l, v v l+, vbar l+ v, l+ vbar v         - for chargino
c     R-parity violating decays via LQD operator
c     1,4  : e+ u dbar, e- ubar d, v d dbar, vbar dbar d  - for neutrali
c     5,8  : v u dbar, e+ dbar d, e+ ubar u, vbar dbar u  - for chargino
c     R-parity violating decays via UDD operator
c     1,4  :						  - for neutralinos
c     5,8  : u u d, u d u, dbar dbar dbar                 - for chargino
c igen =1,3
c     R-parity conserving decays : generation of produced particles
c     R-parity violating decays  : meaningless, i.e. only igen=1 used
************************************************************************
      Real*8   zr,was,esa
      Real*8   VOIJL,VOIJR,gfir,gfil
      COMMON/NEUMIX/ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
      real*8   OIJL,OIJR,V,U,FM,ETA
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      real*8   oijlp,oijrp
      COMMON/CHANEU/oijlp(4,2),oijrp(4,2)
      Integer       ILOOP
      COMMON/SFLOOP/ILOOP
      Real*8   PV
      Integer  IFLAV,NFLAV
CPM      COMMON /PARTC / PV(5,20),IFLAV(20,2),NFLAV
CPM      update to SUSYGEN V1.5
      COMMON /PARTC / pv(5,30)
      COMMON /PARTC1 / iflav(30,2),nflav


      real*8   gw,widfl,widfr,fmeltw,fmertw,fmeluw,fmeruw,gent,gentl
      integer  linda
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,7,6)
CPM     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
C 04/96 P.Morawitz & M.Williams  changed linda to allow for r-parity dec

      integer topo_charg,topo_neut
      common /topocom/ topo_charg,topo_neut

********************* end  of commons of SUSYGEN ***********************


      wsc=0.

      sfmi=fmi
      sfmk=fmk
      sfms=fms
      sgw=gw

      c0=fmi**2+fmk**2+fml1**2+fml2**2
c
c t sneutrino
c
      GW1 = ((SB+FML1**2-FML2**2)/(2.*DSQRT(SB))+
     +        (FMI**2-FMK**2-SB) /(2.*DSQRT(SB)))**2
      GW2 = ((SB+FML1**2-FML2**2)**2/(4.*SB)-FML1**2)
      GW3 = ((FMI**2-SB-FMK**2)**2/(4.*SB)-FMK**2)
      if(GW2.le.0..or.GW3.le.0.)return
      GW2 = DSQRT(GW2)
      GW3 = DSQRT(GW3)
      TMIN = GW1-(GW2+GW3)**2
      TMAX = GW1-(GW2-GW3)**2
c
c  u= charged slepton
c
      GW1 = ((SB+FML2**2-FML1**2)/(2.*DSQRT(SB))+
     +        (FMI**2-FMK**2-SB) /(2.*DSQRT(SB)))**2
      GW2 = ((SB+FML2**2-FML1**2)**2/(4.*SB)-FML2**2)
      GW3 = ((FMI**2-SB-FMK**2)**2/(4.*SB)-FMK**2)
      if(GW2.le.0..or.GW3.le.0.)return
      GW2 = DSQRT(GW2)
      GW3 = DSQRT(GW3)
      UMIN = GW1-(GW2+GW3)**2
      UMAX = GW1-(GW2-GW3)**2

c
c s channel integrals
c

      f1=ff1(sb,tmax)-ff1(sb,tmin)
      f2=ff1(sb,umax)-ff1(sb,umin)
      f3=ff2(sb,tmax)-ff2(sb,tmin)

      wsc1=das*f1+dbs*f2+2.*dcs*etai*etak*fmi*fmk*f3
c
c t channel
c

      sfmelt=fmelt
      alt=fmeltw
      f4l=ff3(sb,tmax)-ff3(sb,tmin)

      sfmelt=fmert
      alt=fmertw
      f4r=ff3(sb,tmax)-ff3(sb,tmin)

      wsc2=datl*f4l+datr*f4r
c
c u channel
c
      sfmelt=fmelu
      alt=fmeluw
      f5l=ff3(sb,umax)-ff3(sb,umin)

      sfmelt=fmeru
      alt=fmeruw
      f5r=ff3(sb,umax)-ff3(sb,umin)

      wsc3=daul*f5l+daur*f5r

c
c st channel
c

      sfmelt=fmelt
      alt=fmeltw
      f4l=ff3(sb,tmax)-ff3(sb,tmin)
      f6l=ff4(sb,tmax)-ff4(sb,tmin)
      f7l=ff5(sb,tmax)-ff5(sb,tmin)

      sfmelt=fmert
      alt=fmertw
      f4r=ff3(sb,tmax)-ff3(sb,tmin)
      f6r=ff4(sb,tmax)-ff4(sb,tmin)
      f7r=ff5(sb,tmax)-ff5(sb,tmin)

      wsc4=2.*dastl*f7l+dastl*gw*f4l/((sb-fms**2)**2+gw**2)
     +    +2.*dbstl*etai*etak*fmi*fmk*sb*f6l
     +    +2.*dastr*f7r+dastr*gw*f4r/((sb-fms**2)**2+gw**2)
     +    +2.*dbstr*etai*etak*fmi*fmk*sb*f6r
c
c su channel
c

      sfmelt=fmelu
      alt=fmeluw
      f5l=ff3(sb,umax)-ff3(sb,umin)
      f8l=ff4(sb,umax)-ff4(sb,umin)
      f9l=ff5(sb,umax)-ff5(sb,umin)

      sfmelt=fmeru
      alt=fmeruw
      f5r=ff3(sb,umax)-ff3(sb,umin)
      f8r=ff4(sb,umax)-ff4(sb,umin)
      f9r=ff5(sb,umax)-ff5(sb,umin)

      wsc5=2.*dasul*f9l+dasul*gw*f5l/((sb-fms**2)**2+gw**2)
     +    +2.*dbsul*etai*etak*fmi*fmk*sb*f8l
     +    +2.*dasur*f9r+dasur*gw*f5r/((sb-fms**2)**2+gw**2)
     +    +2.*dbsur*etai*etak*fmi*fmk*sb*f8r


c
c tu channel integrals
c
      sfmelt=fmelt
      alt=fmeltw
      sfmelu=fmelu
      alu=fmeluw
      altl=alt
      alul=alu
      f01l=ff6(sb,tmax)-ff6(sb,tmin)
      f02l=ff7(sb,tmax)-ff7(sb,tmin)

      sfmelt=fmert
      alt=fmertw
      sfmelu=fmeru
      alu=fmeruw
      altr=alt
      alur=alu
      f01r=ff6(sb,tmax)-ff6(sb,tmin)
      f02r=ff7(sb,tmax)-ff7(sb,tmin)

      wsc6=2.*datul*etai*etak*fmi*fmk*sb*(altl*alul*f01l+f02l)
     +    +2.*datur*etai*etak*fmi*fmk*sb*(altr*alur*f01r+f02r)

      wsc=wsc1+wsc2+wsc3+wsc4+wsc5+wsc6
      wsc=wsc*alpha**2/32./pi/sinw**4/fmi**3

      RETURN
      END

      subroutine newsum
****$****|****$****|****$****|****$****|****$****|****$****|****$****|**
*-- Author :    Stavros Katsanevas   14/04/95                          *
*
*-- ../04/96 P.Morawitz & M.Williams
*--   - modified to include R-parity violating decays
*
****$****|****$****|****$****|****$****|****$****|****$****|****$****|**
C

      IMPLICIT DOUBLE PRECISION (A-H,O-Z)

********************* start of commons of SUSYGEN **********************
      integer ievent
      common /eve/ ievent
      real*4  rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan(6)
      common /rkey/rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan

      real*8  gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu
      common/steer/gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu

      Integer modes,MIX
      common/mds/modes,MIX
      logical zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,higgs
      common/sparc/ zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,
     + higgs
      logical wrt,scan,lepi
      common/str/wrt,scan,lepi
      real*8  flum,ecm,s,roots,T,Q,Q2,EN
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
      real*8  QK
      COMMON/ISR/ QK(4)
      real erad,srad
      common/srada/erad(100),srad(100)
      integer  idbg,igener,irad
      COMMON /CONST/ idbg,igener,irad
      integer  index,index1,index2,nevt
      COMMON/INDEXX/index,index1,index2,nevt
      real*8   fmpr1,fmpr2,XCROST,APRO
      COMMON/FINDEX/fmpr1,fmpr2,XCROST,APRO
      real*8   cosphimix,facqcd,fgama,spartmas,ratq
      common/mixings/cosphimix,facqcd,fgama,spartmas,ratq
      real*8   FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +         FLC,FRC,gms,echar
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
      real*8      TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      real*8   fmal,fmar,ratqa,fgamc,fgamcr,cosmi
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)

      real*4 gmas,phimx
      common/stopmix/gmas(3),phimx(3)
      real*4 phimix1,stop1,phimix2,sbot1,phimix3,stau1
      equivalence (gmas(1),stop1)
      equivalence (gmas(2),sbot1)
      equivalence (gmas(3),stau1)
      equivalence (phimx(1),phimix1)
      equivalence (phimx(2),phimix2)
      equivalence (phimx(3),phimix3)
      real*4 gmas2
      common/stopmix2/gmas2(3)
      real*4 stop2,sbot2,stau2
      equivalence (gmas2(1),stop2)
      equivalence (gmas2(2),sbot2)
      equivalence (gmas2(3),stau2)
      real*4 rscale
      common/sscale/rscale
      logical imsg                      !Added by S.A. for use in the
      common/imessage/imsg              !NTONPH routine

      double precision sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      common/higgses/sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      logical fix_higgs_masses
      common/ steerhiggs / fix_higgs_masses

      integer jdebu,idb1,idb2,lout
      common /debuc/ jdebu,idb1,idb2,lout

      real*8   xgaug,xeta
      COMMON/XCROS/xgaug(8),xeta(8)

      integer  ispa,kl,klap,idecs,klr
      common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
C 04/96 P.Morawitz & M.Williams introduce klr for Rpv gaugino decays
      common/reord2/klr(3,24)
c klr(1,n), klr(2,n) and klr(3,n) are the particles produced in
c R-parity violating decays of gauginos...
C n=1..4 , 5..8	 LLE neutralino,gaugino decays
C n=9..12,13..16 LQD neutralino,gaugino decays
C n=17.20,21..24 UDD neutralino,gaugino decays

      Integer  idecsel,ihigsel
      common/decsel/idecsel(23)
      common/higsel/ihigsel(5)
C 05/96 P.Morawitz
C ...   NOTE: the logical below is used in SUSYGEN V1.5 (April 96)
C       MSSM has its own implementation of R-parity violation.
C       The logical rpar is therefore always set to TRUE which avoids
C       the SUSYGEN R-parity code.
        logical rpar
        common/rpari/rpar
      real*8   brsum,brsuma
CPM      common/brsum/ brsum(5,6,6),brsuma(6)
C 04/96 P.Morawitz & M.Williams  changed brsum to allow for r-parity dec
      common/brsum/ brsum(13,7,6),brsuma(6)
************************************************************************
c EXPLANATION OF INDICES IN BRSUM(itype,igout,igin)
c
c igin  = 1,6 initial gaugino (neutralinos 1..4, charginos 1,2)
c igout = 1,7 outgoing gaugino
c ........where 7 => no outgoing gaugino ie. R-parity violating process
c itype = types of particles produced
c     1 - l+ l-    6 - l q qbar   10 - q q q'         12 - l+ l+ l-
c     2 - v vbar   7 - l q' qbar  11 - qbar qbar qbar 13 - l v v
c     3 - q qbar   8 - v q qbar
c     4 - l v      9 - v q' qbar
c     5 - q' qbar
************************************************************************
      real*8   fms,fmi,fmk,fml1,fml2,etai,etak,brspa
     +        ,brgaug,fmelt,fmert,fmelu,fmeru
      Integer  lind
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
CPM     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
     +lind(6,6,6),brgaug(6,7,11,3),fmelt,fmert,fmelu,fmeru
C 04/96 P.Morawitz & M.Williams  changed brgaug to allow for r-parity de

************************************************************************
c     EXPLANATIONS OF INDICES IN BRGAUG AND BRSPA
c
c BRSPA::
c kgaug =1,6 produced gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c kspar =1,24 initial sparticle
c     1,12  : left-handed sparticle  (u,d,v,e,c,s,v,mu,t,b,v,tau)
c     12,24 : right handed sparticle (u,d,v,e,c,s,v,mu,t,b,v,tau)
c
c BRGAUG::
c igin =1,6 parent gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c igout =1,7 daughter gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c     7    : none (ie. R-parity violating process)
c ipart =1,6 for produced particles .....
c     R-parity conserving decays
c     1,4  : uu,dd,vv,ee                                  - 'like to lik
c     5,6  : ud,ev                                        - 'like to unl
C ipart =7,11 for the 5 diagrams which involve
C             gaugino -> gaugino' gamma
C	      gaugino -> Higgs X
C
C
C ipart =1,8 for Rp-violating!!!! decays (igout=7)
c     R-parity violating decays via LLE operator
c     1,4 :                                               - for neutrali
c     5,8 : l+ l+ l, v v l+, vbar l+ v, l+ vbar v         - for chargino
c     R-parity violating decays via LQD operator
c     1,4  : e+ u dbar, e- ubar d, v d dbar, vbar dbar d  - for neutrali
c     5,8  : v u dbar, e+ dbar d, e+ ubar u, vbar dbar u  - for chargino
c     R-parity violating decays via UDD operator
c     1,4  :						  - for neutralinos
c     5,8  : u u d, u d u, dbar dbar dbar                 - for chargino
c igen =1,3
c     R-parity conserving decays : generation of produced particles
c     R-parity violating decays  : meaningless, i.e. only igen=1 used
************************************************************************
      Real*8   zr,was,esa
      Real*8   VOIJL,VOIJR,gfir,gfil
      COMMON/NEUMIX/ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
      real*8   OIJL,OIJR,V,U,FM,ETA
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      real*8   oijlp,oijrp
      COMMON/CHANEU/oijlp(4,2),oijrp(4,2)
      Integer       ILOOP
      COMMON/SFLOOP/ILOOP
      Real*8   PV
      Integer  IFLAV,NFLAV
CPM      COMMON /PARTC / PV(5,20),IFLAV(20,2),NFLAV
CPM      update to SUSYGEN V1.5
      COMMON /PARTC / pv(5,30)
      COMMON /PARTC1 / iflav(30,2),nflav


      real*8   gw,widfl,widfr,fmeltw,fmertw,fmeluw,fmeruw,gent,gentl
      integer  linda
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,7,6)
CPM     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
C 04/96 P.Morawitz & M.Williams  changed linda to allow for r-parity dec

      integer topo_charg,topo_neut
      common /topocom/ topo_charg,topo_neut

********************* end  of commons of SUSYGEN ***********************

C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------

      Integer i1

      do 10 k1=1,6
         do 10 k2=1,7
            do 10 k3=1,13
               brsum(k3,k2,k1)=0.
 10   continue


      do 60 igin=1,6
         brsuma(igin)=0.

         do 30 igout=1,7
            if (igout.lt.7) then
              do 20 ipart=1,11
                 if(ipart.eq.1.or.ipart.eq.2)itype=3
                 if(ipart.eq.3)itype=2
                 if(ipart.eq.4)itype=1
                 if(ipart.eq.6)itype=4
                 if(ipart.eq.5)itype=5
C ... and the chi' -> chi gamma type decays
             if(ipart.gt.6)itype=ipart

                 fact=1.

                 if(igout.eq.5.or.igout.eq.6) then
                    if(ipart.eq.5.or.ipart.eq.6) then
                       fact=2.
                    end if
                 end if

                 do 15 igen=1,3
                   brsum(itype,igout,igin) = brsum(itype,igout,igin) +
     +                 brgaug(igin,igout,ipart,igen)*fact
                   brsuma(igin) = brsuma(igin) +
     +                 brgaug(igin,igout,ipart,igen)*fact
 15                 continue
 20           continue

c
c
C     ...   Rparity violating decays
            else
               do  ipart=1,4
              i1=ipart
              if (igin.gt.4) i1=i1+4
                  if (coupl_i(1).eq.2) then
C LQD
                     if(i1.eq.1.or.i1.eq.2)itype=7
                     if(i1.eq.3.or.i1.eq.4)itype=8

                     if(i1.eq.5)itype=9
                     if(i1.eq.6)itype=6
                     if(i1.eq.7)itype=6
                     if(i1.eq.8)itype=9
                  elseif (coupl_i(1).eq.3) then
C UDD
                     if(i1.eq.5.or.i1.eq.6)itype=10
                     if(i1.eq.7)itype=11
                  elseif (coupl_i(1).eq.1) then
C LLE
                     if(i1.eq.5)itype=12
                     if(i1.gt.5)itype=13
                  end if

                fact=1.
                  brsum(itype,igout,igin) = brsum(itype,igout,igin) +
     +                 brgaug(igin,igout,i1,1)*fact
                  brsuma(igin) = brsuma(igin) +
     +                 brgaug(igin,igout,i1,1)*fact
               enddo
            end if
c
c
 30      continue

         if(brsuma(igin).gt.0.)then
            do 50 igout=1,7
               do 40 itype=1,13
                  brsum(itype,igout,igin) = brsum(itype,igout,igin)
     +                 / brsuma(igin)
 40            continue
 50         continue
         endif

 60   continue


      return
      end


      SUBROUTINE SUSYGDAT
****$****|****$****|****$****|****$****|****$****|****$****|****$****|**
*                                                                      *
*-- Author :    Stavros Katsanevas   14/04/95                          *
*                                                                      *
*-- modified by Y.GAO  1/02/96                                         *
*
*-- change it from BLOCK DATA to SUBROUTINE  Y.GAO 6/03/96             *
*
*-- modified by P.Morawitz & M.Williams ../04/96
*       include R-parity violation
*                                                                      *
****$****|****$****|****$****|****$****|****$****|****$****|****$****|**
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C
C     common blocks
C     =============
*     reorder sparticles and particles
********************* start of commons of SUSYGEN **********************
      integer ievent
      common /eve/ ievent
      real*4  rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan(6)
      common /rkey/rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan

      real*8  gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu
      common/steer/gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu

      Integer modes,MIX
      common/mds/modes,MIX
      logical zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,higgs
      common/sparc/ zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,
     + higgs
      logical wrt,scan,lepi
      common/str/wrt,scan,lepi
      real*8  flum,ecm,s,roots,T,Q,Q2,EN
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
      real*8  QK
      COMMON/ISR/ QK(4)
      real erad,srad
      common/srada/erad(100),srad(100)
      integer  idbg,igener,irad
      COMMON /CONST/ idbg,igener,irad
      integer  index,index1,index2,nevt
      COMMON/INDEXX/index,index1,index2,nevt
      real*8   fmpr1,fmpr2,XCROST,APRO
      COMMON/FINDEX/fmpr1,fmpr2,XCROST,APRO
      real*8   cosphimix,facqcd,fgama,spartmas,ratq
      common/mixings/cosphimix,facqcd,fgama,spartmas,ratq
      real*8   FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +         FLC,FRC,gms,echar
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
      real*8      TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      real*8   fmal,fmar,ratqa,fgamc,fgamcr,cosmi
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)

      real*4 gmas,phimx
      common/stopmix/gmas(3),phimx(3)
      real*4 phimix1,stop1,phimix2,sbot1,phimix3,stau1
      equivalence (gmas(1),stop1)
      equivalence (gmas(2),sbot1)
      equivalence (gmas(3),stau1)
      equivalence (phimx(1),phimix1)
      equivalence (phimx(2),phimix2)
      equivalence (phimx(3),phimix3)
      real*4 gmas2
      common/stopmix2/gmas2(3)
      real*4 stop2,sbot2,stau2
      equivalence (gmas2(1),stop2)
      equivalence (gmas2(2),sbot2)
      equivalence (gmas2(3),stau2)
      real*4 rscale
      common/sscale/rscale
      logical imsg                      !Added by S.A. for use in the
      common/imessage/imsg              !NTONPH routine

      double precision sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      common/higgses/sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      logical fix_higgs_masses
      common/ steerhiggs / fix_higgs_masses

      integer jdebu,idb1,idb2,lout
      common /debuc/ jdebu,idb1,idb2,lout

      real*8   xgaug,xeta
      COMMON/XCROS/xgaug(8),xeta(8)

      integer  ispa,kl,klap,idecs,klr
      common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
C 04/96 P.Morawitz & M.Williams introduce klr for Rpv gaugino decays
      common/reord2/klr(3,24)
c klr(1,n), klr(2,n) and klr(3,n) are the particles produced in
c R-parity violating decays of gauginos...
C n=1..4 , 5..8	 LLE neutralino,gaugino decays
C n=9..12,13..16 LQD neutralino,gaugino decays
C n=17.20,21..24 UDD neutralino,gaugino decays

      Integer  idecsel,ihigsel
      common/decsel/idecsel(23)
      common/higsel/ihigsel(5)
C 05/96 P.Morawitz
C ...   NOTE: the logical below is used in SUSYGEN V1.5 (April 96)
C       MSSM has its own implementation of R-parity violation.
C       The logical rpar is therefore always set to TRUE which avoids
C       the SUSYGEN R-parity code.
        logical rpar
        common/rpari/rpar
      real*8   brsum,brsuma
CPM      common/brsum/ brsum(5,6,6),brsuma(6)
C 04/96 P.Morawitz & M.Williams  changed brsum to allow for r-parity dec
      common/brsum/ brsum(13,7,6),brsuma(6)
************************************************************************
c EXPLANATION OF INDICES IN BRSUM(itype,igout,igin)
c
c igin  = 1,6 initial gaugino (neutralinos 1..4, charginos 1,2)
c igout = 1,7 outgoing gaugino
c ........where 7 => no outgoing gaugino ie. R-parity violating process
c itype = types of particles produced
c     1 - l+ l-    6 - l q qbar   10 - q q q'         12 - l+ l+ l-
c     2 - v vbar   7 - l q' qbar  11 - qbar qbar qbar 13 - l v v
c     3 - q qbar   8 - v q qbar
c     4 - l v      9 - v q' qbar
c     5 - q' qbar
************************************************************************
      real*8   fms,fmi,fmk,fml1,fml2,etai,etak,brspa
     +        ,brgaug,fmelt,fmert,fmelu,fmeru
      Integer  lind
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
CPM     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
     +lind(6,6,6),brgaug(6,7,11,3),fmelt,fmert,fmelu,fmeru
C 04/96 P.Morawitz & M.Williams  changed brgaug to allow for r-parity de

************************************************************************
c     EXPLANATIONS OF INDICES IN BRGAUG AND BRSPA
c
c BRSPA::
c kgaug =1,6 produced gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c kspar =1,24 initial sparticle
c     1,12  : left-handed sparticle  (u,d,v,e,c,s,v,mu,t,b,v,tau)
c     12,24 : right handed sparticle (u,d,v,e,c,s,v,mu,t,b,v,tau)
c
c BRGAUG::
c igin =1,6 parent gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c igout =1,7 daughter gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c     7    : none (ie. R-parity violating process)
c ipart =1,6 for produced particles .....
c     R-parity conserving decays
c     1,4  : uu,dd,vv,ee                                  - 'like to lik
c     5,6  : ud,ev                                        - 'like to unl
C ipart =7,11 for the 5 diagrams which involve
C             gaugino -> gaugino' gamma
C	      gaugino -> Higgs X
C
C
C ipart =1,8 for Rp-violating!!!! decays (igout=7)
c     R-parity violating decays via LLE operator
c     1,4 :                                               - for neutrali
c     5,8 : l+ l+ l, v v l+, vbar l+ v, l+ vbar v         - for chargino
c     R-parity violating decays via LQD operator
c     1,4  : e+ u dbar, e- ubar d, v d dbar, vbar dbar d  - for neutrali
c     5,8  : v u dbar, e+ dbar d, e+ ubar u, vbar dbar u  - for chargino
c     R-parity violating decays via UDD operator
c     1,4  :						  - for neutralinos
c     5,8  : u u d, u d u, dbar dbar dbar                 - for chargino
c igen =1,3
c     R-parity conserving decays : generation of produced particles
c     R-parity violating decays  : meaningless, i.e. only igen=1 used
************************************************************************
      Real*8   zr,was,esa
      Real*8   VOIJL,VOIJR,gfir,gfil
      COMMON/NEUMIX/ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
      real*8   OIJL,OIJR,V,U,FM,ETA
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      real*8   oijlp,oijrp
      COMMON/CHANEU/oijlp(4,2),oijrp(4,2)
      Integer       ILOOP
      COMMON/SFLOOP/ILOOP
      Real*8   PV
      Integer  IFLAV,NFLAV
CPM      COMMON /PARTC / PV(5,20),IFLAV(20,2),NFLAV
CPM      update to SUSYGEN V1.5
      COMMON /PARTC / pv(5,30)
      COMMON /PARTC1 / iflav(30,2),nflav


      real*8   gw,widfl,widfr,fmeltw,fmertw,fmeluw,fmeruw,gent,gentl
      integer  linda
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,7,6)
CPM     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
C 04/96 P.Morawitz & M.Williams  changed linda to allow for r-parity dec

      integer topo_charg,topo_neut
      common /topocom/ topo_charg,topo_neut

********************* end  of commons of SUSYGEN ***********************

      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
      Integer       IUT,i,j
      Integer       mproc
      Parameter    (mproc=35)
      Integer       iproc,iprod,ipar1,ipar2,ihand,isusy,iopen,ievnt
      Real          xproc
      common/SUPROC/iproc(mproc),iprod(mproc)
     &             ,ipar1(mproc),ipar2(mproc)
     &             ,ihand(mproc),isusy(mproc)
     &             ,iopen(mproc),ievnt(mproc)
     &             ,xproc(mproc)
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------

C
C     data statements are only for local variables
C     ============================================
c
c kl(1,n) and kl(2,n) are the particles produced in R-parity
c conserving gaugino decays..... n = ipart + (igen-1)*6
c
      Integer       kl_loc(2,18)
      data kl_loc/2,-2,1,-1,12,-12,11,-11,2,-1,12,-11,
     +            4,-4,3,-3,14,-14,13,-13,4,-3,14,-13,
     +            6,-6,5,-5,16,-16,15,-15,6,-5,16,-15/


C ... and construct klr, the table used for looking up the R-parity deca
c klr(1,n), klr(2,n) and klr(3,n) are the particles produced in
c R-parity violating decays of gauginos....
C n=1..4 , 5..8       LLE neutralino,gaugino decays
C n=9..12,13..16 LQD neutralino,gaugino decays
C n=17.20,21..24 UDD neutralino,gaugino decays
      Integer       klr_loc(3,24)
      data klr_loc/
C LLE decays
     +    11,-12,-11, -11,12,11, -12,11,-11, 12,-11,11,
     +    12,12,-11,  -11,-11,11, -11,12,12, 12,-11,12,
C LQD decays
     +   -11,-2,1, 11,2,-1, -12,1,-1,  12,-1,1,
     +   12,2,-1, -11,-1,1, -11,-2,2, -12,-1,2,
C UDD decays
     +   2,1,1, -2,-1,-1, 0,0,0, 0,0,0,
     +   2,2,1, 2,1,2, -1,-1,-1, 0,0,0/

c
c ispa(n,1) gives the ptcle numbers for  left-handed sparticles
c ispa(n,2) gives the ptcle numbers for right-handed sparticles
c
      Integer       ispa_loc(12,2)
      data ispa_loc/42,41,52,51,44,43,54,53,46,45,56,55,
     +              48,47, 0,57,50,49, 0,58,62,61, 0,59/

c
c klap(1,n) and klap(2,n) are the sparticle propagators in R-parity
c conserving gaugino decays.... n = ipart + (igen-1)*6
c

      Integer       klap_loc(2,18)
      data klap_loc/42,42,41,41,52,52,51,51,42,41,52,51,
     +              44,44,43,43,54,54,53,53,44,43,54,53,
     +              46,46,45,45,56,56,55,55,46,45,56,55/

CPM   update to SUSYGEN V1.5 ... now it is ..6,5,16,15.. 'caus of mods t
      Integer       idecs_loc(12,2)
      data idecs_loc/2,1,12,11,4,3,14,13,6,5,16,15,
     +               1,2,11,12,3,4,13,14,5,6,15,16/

      Integer       iloop_loc
      data iloop_loc/1/

      Integer       jproc
      Integer       iproc_loc(mproc),iprod_loc(mproc)
     &             ,ipar1_loc(mproc),ipar2_loc(mproc)
     &             ,ihand_loc(mproc),isusy_loc(mproc)
      DATA ( iproc_loc(jproc),iprod_loc(jproc)
     &      ,ipar1_loc(jproc),ipar2_loc(jproc)
     &      ,ihand_loc(jproc),isusy_loc(jproc),jproc=1,mproc ) /
*    -------------------------------
*    spar1,spar2 here are LUND codes
*    -------------------------------
     &   1,  1,  71,  71,   0,   0,
     &   2,  1,  72,  71,   0,   0,
     &   3,  1,  72,  72,   0,   0,
     &   4,  1,  73,  71,   0,   0,
     &   5,  1,  73,  72,   0,   0,
     &   6,  1,  73,  73,   0,   0,
     &   7,  1,  74,  71,   0,   0,
     &   8,  1,  74,  72,   0,   0,
     &   9,  1,  74,  73,   0,   0,
     &  10,  1,  74,  74,   0,   0,
     &  11,  2,  75, -75,   0,   0,
     &  12,  2,  76, -75,   0,   0,
     &  13,  2,  76, -76,   0,   0,
     &  14,  3,  52, -52,   1,   3,
     &  15,  3,  54, -54,   1,   7,
     &  16,  3,  56, -56,   1,  11,
     &  17,  3,  51, -51,   1,   4,
     &  18,  3,  51, -57,   1,   4,
     &  19,  3,  57, -57,   2,   4,
     &  20,  3,  53, -53,   1,   8,
     &  21,  3,  58, -58,   2,   8,
     &  22,  3,  55, -55,   1,  12,
     &  23,  3,  59, -59,   2,  12,
     &  24,  3,  42, -42,   1,   1,
     &  25,  3,  48, -48,   2,   1,
     &  26,  3,  41, -41,   1,   2,
     &  27,  3,  47, -47,   2,   2,
     &  28,  3,  44, -44,   1,   5,
     &  29,  3,  50, -50,   2,   5,
     &  30,  3,  43, -43,   1,   6,
     &  31,  3,  49, -49,   2,   6,
     &  32,  3,  45, -45,   1,   9,
     &  33,  3,  61, -61,   2,   9,
     &  34,  3,  46, -46,   1,  10,
     &  35,  3,  62, -62,   2,  10/
C
C     transfer the value of local variables to global, painful...
C     ===========================================================
      do i=1,18
      do j=1, 2
        kl(j,i)  =kl_loc(j,i)
        klap(j,i)=klap_loc(j,i)
      enddo
      enddo

      do i=1,24
      do j=1,3
        klr(j,i)=  klr_loc(j,i)
C ... since coupl_i is not available yet
C ... the generations ijk will be set properly in RPARINIT, i.e.
C        klr(j,i)=  klr(j,i)+sign(1,klr(j,i))*2*(coupl_i(j+1)-1)
      end do
      end do

      do i=1, 2
      do j=1,12
        ispa(j,i) =ispa_loc(j,i)
        idecs(j,i)=idecs_loc(j,i)
      enddo
      enddo

      iloop=iloop_loc

      do j=1,mproc
        iproc(j)=iproc_loc(j)
        iprod(j)=iprod_loc(j)
        ipar1(j)=ipar1_loc(j)
        ipar2(j)=ipar2_loc(j)
        ihand(j)=ihand_loc(j)
        isusy(j)=isusy_loc(j)
      enddo
C
C     write a message
C     ===============
      IUT=IW(6)
      write(IUT,*) ' SUSYGDAT has been called '
      end


      SUBROUTINE smbod3(PIN,indin,PP1,PP2,PP3,IND,adeca,ifail)
****$****|****$****|****$****|****$****|****$****|****$****|****$****|**
*-- Author :    Stavros Katsanevas   14/04/95                          *
*
*-- Modified: ../04/96 P.Morawitz
*                     include R-parity violating gaugino decays
*
****$****|****$****|****$****|****$****|****$****|****$****|****$****|**
*
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)

C      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
C     +FLC(12),FRC(12),gms(12),echar(12)

      integer ind(3)
      DOUBLE PRECISION BETA(3)
      DOUBLE PRECISION PIN(5),P1(5),P2(5),P3(5)
      DOUBLE PRECISION        PP1(5),PP2(5),PP3(5)
      DOUBLE PRECISION adeca

C      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
C     +gent(50,2,168),gentl(2,2,168),linda(18,7,6)
CPM     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
CPM modified to accomodate R-parity gaugino decays

      real*4 rndm,rsb,rub


C      common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)

********************* start of commons of SUSYGEN **********************
      integer ievent
      common /eve/ ievent
      real*4  rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan(6)
      common /rkey/rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan

      real*8  gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu
      common/steer/gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu

      Integer modes,MIX
      common/mds/modes,MIX
      logical zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,higgs
      common/sparc/ zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,
     + higgs
      logical wrt,scan,lepi
      common/str/wrt,scan,lepi
      real*8  flum,ecm,s,roots,T,Q,Q2,EN
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
      real*8  QK
      COMMON/ISR/ QK(4)
      real erad,srad
      common/srada/erad(100),srad(100)
      integer  idbg,igener,irad
      COMMON /CONST/ idbg,igener,irad
      integer  index,index1,index2,nevt
      COMMON/INDEXX/index,index1,index2,nevt
      real*8   fmpr1,fmpr2,XCROST,APRO
      COMMON/FINDEX/fmpr1,fmpr2,XCROST,APRO
      real*8   cosphimix,facqcd,fgama,spartmas,ratq
      common/mixings/cosphimix,facqcd,fgama,spartmas,ratq
      real*8   FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +         FLC,FRC,gms,echar
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
      real*8      TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      real*8   fmal,fmar,ratqa,fgamc,fgamcr,cosmi
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)

      real*4 gmas,phimx
      common/stopmix/gmas(3),phimx(3)
      real*4 phimix1,stop1,phimix2,sbot1,phimix3,stau1
      equivalence (gmas(1),stop1)
      equivalence (gmas(2),sbot1)
      equivalence (gmas(3),stau1)
      equivalence (phimx(1),phimix1)
      equivalence (phimx(2),phimix2)
      equivalence (phimx(3),phimix3)
      real*4 gmas2
      common/stopmix2/gmas2(3)
      real*4 stop2,sbot2,stau2
      equivalence (gmas2(1),stop2)
      equivalence (gmas2(2),sbot2)
      equivalence (gmas2(3),stau2)
      real*4 rscale
      common/sscale/rscale
      logical imsg                      !Added by S.A. for use in the
      common/imessage/imsg              !NTONPH routine

      double precision sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      common/higgses/sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      logical fix_higgs_masses
      common/ steerhiggs / fix_higgs_masses

      integer jdebu,idb1,idb2,lout
      common /debuc/ jdebu,idb1,idb2,lout

      real*8   xgaug,xeta
      COMMON/XCROS/xgaug(8),xeta(8)

      integer  ispa,kl,klap,idecs,klr
      common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
C 04/96 P.Morawitz & M.Williams introduce klr for Rpv gaugino decays
      common/reord2/klr(3,24)
c klr(1,n), klr(2,n) and klr(3,n) are the particles produced in
c R-parity violating decays of gauginos...
C n=1..4 , 5..8	 LLE neutralino,gaugino decays
C n=9..12,13..16 LQD neutralino,gaugino decays
C n=17.20,21..24 UDD neutralino,gaugino decays

      Integer  idecsel,ihigsel
      common/decsel/idecsel(23)
      common/higsel/ihigsel(5)
C 05/96 P.Morawitz
C ...   NOTE: the logical below is used in SUSYGEN V1.5 (April 96)
C       MSSM has its own implementation of R-parity violation.
C       The logical rpar is therefore always set to TRUE which avoids
C       the SUSYGEN R-parity code.
        logical rpar
        common/rpari/rpar
      real*8   brsum,brsuma
CPM      common/brsum/ brsum(5,6,6),brsuma(6)
C 04/96 P.Morawitz & M.Williams  changed brsum to allow for r-parity dec
      common/brsum/ brsum(13,7,6),brsuma(6)
************************************************************************
c EXPLANATION OF INDICES IN BRSUM(itype,igout,igin)
c
c igin  = 1,6 initial gaugino (neutralinos 1..4, charginos 1,2)
c igout = 1,7 outgoing gaugino
c ........where 7 => no outgoing gaugino ie. R-parity violating process
c itype = types of particles produced
c     1 - l+ l-    6 - l q qbar   10 - q q q'         12 - l+ l+ l-
c     2 - v vbar   7 - l q' qbar  11 - qbar qbar qbar 13 - l v v
c     3 - q qbar   8 - v q qbar
c     4 - l v      9 - v q' qbar
c     5 - q' qbar
************************************************************************
      real*8   fms,fmi,fmk,fml1,fml2,etai,etak,brspa
     +        ,brgaug,fmelt,fmert,fmelu,fmeru
      Integer  lind
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
CPM     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
     +lind(6,6,6),brgaug(6,7,11,3),fmelt,fmert,fmelu,fmeru
C 04/96 P.Morawitz & M.Williams  changed brgaug to allow for r-parity de

************************************************************************
c     EXPLANATIONS OF INDICES IN BRGAUG AND BRSPA
c
c BRSPA::
c kgaug =1,6 produced gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c kspar =1,24 initial sparticle
c     1,12  : left-handed sparticle  (u,d,v,e,c,s,v,mu,t,b,v,tau)
c     12,24 : right handed sparticle (u,d,v,e,c,s,v,mu,t,b,v,tau)
c
c BRGAUG::
c igin =1,6 parent gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c igout =1,7 daughter gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c     7    : none (ie. R-parity violating process)
c ipart =1,6 for produced particles .....
c     R-parity conserving decays
c     1,4  : uu,dd,vv,ee                                  - 'like to lik
c     5,6  : ud,ev                                        - 'like to unl
C ipart =7,11 for the 5 diagrams which involve
C             gaugino -> gaugino' gamma
C	      gaugino -> Higgs X
C
C
C ipart =1,8 for Rp-violating!!!! decays (igout=7)
c     R-parity violating decays via LLE operator
c     1,4 :                                               - for neutrali
c     5,8 : l+ l+ l, v v l+, vbar l+ v, l+ vbar v         - for chargino
c     R-parity violating decays via LQD operator
c     1,4  : e+ u dbar, e- ubar d, v d dbar, vbar dbar d  - for neutrali
c     5,8  : v u dbar, e+ dbar d, e+ ubar u, vbar dbar u  - for chargino
c     R-parity violating decays via UDD operator
c     1,4  :						  - for neutralinos
c     5,8  : u u d, u d u, dbar dbar dbar                 - for chargino
c igen =1,3
c     R-parity conserving decays : generation of produced particles
c     R-parity violating decays  : meaningless, i.e. only igen=1 used
************************************************************************
      Real*8   zr,was,esa
      Real*8   VOIJL,VOIJR,gfir,gfil
      COMMON/NEUMIX/ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
      real*8   OIJL,OIJR,V,U,FM,ETA
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      real*8   oijlp,oijrp
      COMMON/CHANEU/oijlp(4,2),oijrp(4,2)
      Integer       ILOOP
      COMMON/SFLOOP/ILOOP
      Real*8   PV
      Integer  IFLAV,NFLAV
CPM      COMMON /PARTC / PV(5,20),IFLAV(20,2),NFLAV
CPM      update to SUSYGEN V1.5
      COMMON /PARTC / pv(5,30)
      COMMON /PARTC1 / iflav(30,2),nflav


      real*8   gw,widfl,widfr,fmeltw,fmertw,fmeluw,fmeruw,gent,gentl
      integer  linda
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,7,6)
CPM     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
C 04/96 P.Morawitz & M.Williams  changed linda to allow for r-parity dec

      integer topo_charg,topo_neut
      common /topocom/ topo_charg,topo_neut

********************* end  of commons of SUSYGEN ***********************

         REAL x1,x2
       REAL RP1(4),RP2(4),RP3(4), PGAUG(4)
       REAL mop1,mop2,mop3,temp
       real rbeta,alph,theta(3)
       REAL ECMS,ps(4)
       INTEGER i,offset
c
c s = the W*,Z* combination
c t = the up combination
c u = the down combination
c
       integer tmpindex1,tmpindex2

      ifail=1

      fmi=ssmass(indin)
      fml1=ssmass(ind(1))
      fml2=ssmass(ind(2))
      fmk=ssmass(ind(3))


      IF (iabs(ind(3)).gt.40) then
C --------------------------------------------
C ...      R-parity conserving 3-body  decays
C --------------------------------------------
c
c translete back codes to kfcur
c
         tmpindex1=iabs(indin)-70
         k1=iabs(ind(1))
         k2=iabs(ind(2))
         tmpindex2=iabs(ind(3))-70


         do 10 kfcur=1,18
           ik1=iabs(kl(1,kfcur))
           ik2=iabs(kl(2,kfcur))
           if((k1.eq.ik1.and.k2.eq.ik2).or. (k1.eq.ik2.and.k2.eq.ik1))
     +       goto 20
   10    continue
   20    continue



         ntry=0
   30    continue

         ntry=ntry+1
         if(ntry.gt.1000)then
CYG         write (1,*) ' Warning > 1000 in smbod3 '
           return
         endif

         if(kfcur.gt.18)then
CYG         write(1,*)' error in branch logic kf ',kfcur,indin,ind(3)
CYG         write(1,*)' error in branch logic kf ',ind(1),ind(2)
           stop99
         endif

         indx=linda(kfcur,tmpindex2,tmpindex1)

c         call  gveg(z,gent(1,1,indx),gentl(1,1,indx))
c         sb=z(1)
c         ub=z(2)


         call hrndm2(indx,rsb,rub)
         sb=dble(rsb)
         ub=dble(rub)

c
c  u= charged slepton
c
         GW1 = ((SB+FML2**2-FML1**2)/(2.*DSQRT(SB))+
     +        (FMI**2-FMK**2-SB) /(2.*DSQRT(SB)))**2
         GW2 = ((SB+FML2**2-FML1**2)**2/(4.*SB)-FML2**2)
         GW3 = ((FMI**2-SB-FMK**2)**2/(4.*SB)-FMK**2)
         if(GW2.le.0..or.GW3.le.0)go to 30
         GW2 = DSQRT(GW2)
         GW3 = DSQRT(GW3)
         UMIN = GW1-(GW2+GW3)**2
         UMAX = GW1-(GW2-GW3)**2
         if(umin.ge.umax)go to 30
         if(ub.lt.umin.or.ub.gt.umax)go to 30

*
         TB=FMI**2+FMK**2+fml1**2+fml2**2-SB-UB

         P1(4)=(FMI**2+fml1**2-UB)/2./fmi
         P2(4)=(FMI**2+fml2**2-TB)/2./fmi
*
         C12    = fmi**2-fmk**2-2.*fmi*(P1(4)+P2(4))
         C12    = .5*C12/(P1(4)*P2(4))+1.
         IF(ABS(C12).GT.1.)GO TO 30
         CT1    = -1.+2.*dble(RNDM(0))
         FI2    = TWOPI*dble(RNDM(0))

         CF2    = COS(FI2)
         SF2    = SIN(FI2)
         ST1    = SQRT(1.D0-CT1**2)
         S12    = SQRT(1.D0-C12**2)
         PP=(P1(4)**2-fml1**2)

         IF(PP.LT.0.)GO TO 30
         PP=SQRT(PP)
         P1(1)  = PP*ST1
         P1(2)  = 0.0
         P1(3)  = PP*CT1
         P1(5)  = fml1
C
         PP=(P2(4)**2-fml2**2)
         IF(PP.LT.0.)GO TO 30
         PP=SQRT(PP)
         P2(1)  = PP*(S12*CF2*CT1+C12*ST1)
         P2(2)  = PP*S12*SF2
         P2(3)  = PP*(C12*CT1-S12*CF2*ST1)
         P2(5)  = fml2
C
         P3(4)  = fmi-P1(4)-P2(4)
         P3(1)  = -P1(1)-P2(1)
         P3(2)  = -P2(2)
         P3(3)  = -P1(3)-P2(3)
         P3(5)  = fmk

C
C      Here we rotate of phi1 the particles from the gaugino decay.
C

         FI    = TWOPI*dble(RNDM(0))
         CF    = COS( FI )
         SF    = SIN( FI )
         CALL TRASQU(P1,PP1,CF,SF)
         CALL TRASQU(P2,PP2,CF,SF)
         CALL TRASQU(P3,PP3,CF,SF)
C
C      Here we rotate the GAUGINO vector of theta and phi
C
         pmom=sqrt(pin(1)**2+pin(2)**2+pin(3)**2)
         px=pin(1)/pmom
         py=pin(2)/pmom
         CTHCM=pin(3)/pmom
         PHCM  = atan2(py,px)

         STHCM = SQRT( 1. - CTHCM**2 )
         CPHCM = COS( PHCM )
         SPHCM = SIN( PHCM )

         CALL TRASLA( PP1,CTHCM,STHCM,CPHCM,SPHCM )
         CALL TRASLA( PP2,CTHCM,STHCM,CPHCM,SPHCM )
         CALL TRASLA( PP3,CTHCM,STHCM,CPHCM,SPHCM )
C
C      Here we boost the particles from the wino to the c. of m. frame.
C
         BETA(1) = Pin(1) / Pin(4)
         BETA(2) = Pin(2) / Pin(4)
         BETA(3) = Pin(3) / Pin(4)

         CALL BOOSTSUSY (PP1,BETA)
         CALL BOOSTSUSY (PP2,BETA)
         CALL BOOSTSUSY (PP3,BETA)

      else
C --------------------------------------------
C      R-parity violating 3-body decay
C --------------------------------------------
c
c translete back codes to kfcur
c
         tmpindex1=iabs(indin)-70
         k1=iabs(ind(1))
         k2=iabs(ind(2))
         k3=iabs(ind(3))


         do 100 kfcur=1,24
           ik1=iabs(klr(1,kfcur))
           ik2=iabs(klr(2,kfcur))
           ik3=iabs(klr(3,kfcur))
           if((k1.eq.ik1.and.k2.eq.ik2).and.k3.eq.ik3)
     +       goto 200
 100     continue
 200     continue

         if(kfcur.gt.24)then
CYG         write(1,*)' error in branch logic kf ',kfcur,indin,ind(3)
CYG         write(1,*)' error in branch logic kf ',ind(1),ind(2)
           stop99
         endif


         ntry=0
 333     continue
         ntry=ntry+1
         if(ntry.gt.1000)then
           write (*,*) ' Warning > 1000 in smbod3 - 2'
           return
         endif

         indx=linda(mod(kfcur-1,8)+1,7,tmpindex1)

 888     call hrndm2(indx,x1,x2)

         P1(4)=x1/2.0 * fmi
         P2(4)=x2/2.0 * fmi

         C12    = fmi**2-fmk**2-2.*fmi*(P1(4)+P2(4))
         C12    = .5*C12/(P1(4)*P2(4))+1.
         IF(ABS(C12).GT.1.)GO TO 333
         CT1    = -1.+2.*dble(RNDM(0))
         FI2    = TWOPI*dble(RNDM(0))

         CF2    = COS(FI2)
         SF2    = SIN(FI2)
         ST1    = SQRT(1.D0-CT1**2)
         S12    = SQRT(1.D0-C12**2)
         PP=(P1(4)**2-fml1**2)

         IF(PP.LT.0.)GO TO 333
         PP=SQRT(PP)
         P1(1)  = PP*ST1
         P1(2)  = 0.0
         P1(3)  = PP*CT1
         P1(5)  = fml1
C
         PP=(P2(4)**2-fml2**2)
         IF(PP.LT.0.)GO TO 333
         PP=SQRT(PP)
         P2(1)  = PP*(S12*CF2*CT1+C12*ST1)
         P2(2)  = PP*S12*SF2
         P2(3)  = PP*(C12*CT1-S12*CF2*ST1)
         P2(5)  = fml2
C
         P3(4)  = fmi-P1(4)-P2(4)
         P3(1)  = -P1(1)-P2(1)
         P3(2)  = -P2(2)
         P3(3)  = -P1(3)-P2(3)
         P3(5)  = fmk
         PP=(P3(4)**2-fmk**2)
         IF(PP.LT.0.)GO TO 333
C
C      Here we rotate of phi1 the particles from the gaugino decay.
C

         FI    = TWOPI*dble(RNDM(0))
         CF    = COS( FI )
         SF    = SIN( FI )
         CALL TRASQU(P1,PP1,CF,SF)
         CALL TRASQU(P2,PP2,CF,SF)
         CALL TRASQU(P3,PP3,CF,SF)
C
C      Here we rotate the GAUGINO vector of theta and phi
C
         pmom=sqrt(pin(1)**2+pin(2)**2+pin(3)**2)
         px=pin(1)/pmom
         py=pin(2)/pmom
         CTHCM=pin(3)/pmom
         PHCM  = atan2(py,px)

         STHCM = SQRT( 1. - CTHCM**2 )
         CPHCM = COS( PHCM )
         SPHCM = SIN( PHCM )

         CALL TRASLA( PP1,CTHCM,STHCM,CPHCM,SPHCM )
         CALL TRASLA( PP2,CTHCM,STHCM,CPHCM,SPHCM )
         CALL TRASLA( PP3,CTHCM,STHCM,CPHCM,SPHCM )
C
C      Here we boost the particles from the wino to the c. of m. frame.
C
         BETA(1) = Pin(1) / Pin(4)
         BETA(2) = Pin(2) / Pin(4)
         BETA(3) = Pin(3) / Pin(4)

         CALL BOOSTSUSY (PP1,BETA)
         CALL BOOSTSUSY (PP2,BETA)
         CALL BOOSTSUSY (PP3,BETA)

C       and histogram the decay
       IF (indin.gt.0) then
           offset=0
       else
         offset=10
       ENDIF
       call hf1((13001+offset),sngl(PP1(4)),1.)
         call hf1((13002+offset),
     +      sngl(pp1(3)/SQRT(ABS((PP1(4)**2-PP1(5)**2)))),1.)
       call hf1((13003+offset),sngl(PP2(4)),1.)
         call hf1((13004+offset),
     +      sngl(pp2(3)/SQRT(ABS(PP2(4)**2-PP2(5)**2))),1.)
       call hf1((13005+offset),sngl(PP3(4)),1.)
         call hf1((13006+offset),
     +      sngl(pp3(3)/SQRT(ABS(PP3(4)**2-PP3(5)**2))),1.)

      ENDIF

      ifail=0

      return


      END

      SUBROUTINE DECABR(lindex1,nbod,lindex2,adeca)
****$****|****$****|****$****|****$****|****$****|****$****|****$****|**
*-- Author :    Stavros Katsanevas   14/04/95                          *
*
*-- Modified: 27/08/96 P.Morawitz bugfix - local variable index renamed
*                  to tmpindex. Variable index is a global var in
*                   SUSCOM.
*-- Modified: ../04/96 P.Morawitz to allow for R-parity violating decays
*-- Modified: 01/07/96 P.Morawitz introduce topology switches for
*                        chi+1chi+2 and neu1neu2
*
****$****|****$****|****$****|****$****|****$****|****$****|****$****|**
C
C randomly generates a gaugino or spaticle decay to a nbod=1,2,3 mode
C nbod=1 means no decay
C lindex2 contains the decay particles list
C

C          MXSS                 = maximum number of modes
C          NSSMOD               = number of modes
C          ISSMOD               = initial particle
C          JSSMOD               = final particles
C          GSSMOD               = width
C          BSSMOD               = branching ratio
C          MXSS                 = maximum number of modes
C          NSSMOD               = number of modes
C          ISSMOD               = initial particle
C          JSSMOD               = final particles
C          GSSMOD               = width
C          BSSMOD               = branching ratio
      INTEGER MXSS
      PARAMETER (MXSS=2000)
      COMMON/SSMODE/NSSMOD,ISSMOD(MXSS),JSSMOD(5,MXSS)
      COMMON/SSMOD1/GSSMOD(MXSS),BSSMOD(MXSS)
      INTEGER NSSMOD,ISSMOD,JSSMOD
      DOUBLE PRECISION GSSMOD,BSSMOD



      integer*4 kindex(3),lindex2(3)
      integer tmpindex
      real fmass(3)

      DOUBLE PRECISION brtot,adeca
      common/ubra/ndeca(-80:80)
      common/ubra1/brtot(2,100,-80:80)

********************* start of commons of SUSYGEN **********************
      integer ievent
      common /eve/ ievent
      real*4  rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan(6)
      common /rkey/rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan

      real*8  gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu
      common/steer/gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu

      Integer modes,MIX
      common/mds/modes,MIX
      logical zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,higgs
      common/sparc/ zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,
     + higgs
      logical wrt,scan,lepi
      common/str/wrt,scan,lepi
      real*8  flum,ecm,s,roots,T,Q,Q2,EN
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
      real*8  QK
      COMMON/ISR/ QK(4)
      real erad,srad
      common/srada/erad(100),srad(100)
      integer  idbg,igener,irad
      COMMON /CONST/ idbg,igener,irad
      integer  index,index1,index2,nevt
      COMMON/INDEXX/index,index1,index2,nevt
      real*8   fmpr1,fmpr2,XCROST,APRO
      COMMON/FINDEX/fmpr1,fmpr2,XCROST,APRO
      real*8   cosphimix,facqcd,fgama,spartmas,ratq
      common/mixings/cosphimix,facqcd,fgama,spartmas,ratq
      real*8   FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +         FLC,FRC,gms,echar
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
      real*8      TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      real*8   fmal,fmar,ratqa,fgamc,fgamcr,cosmi
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)

      real*4 gmas,phimx
      common/stopmix/gmas(3),phimx(3)
      real*4 phimix1,stop1,phimix2,sbot1,phimix3,stau1
      equivalence (gmas(1),stop1)
      equivalence (gmas(2),sbot1)
      equivalence (gmas(3),stau1)
      equivalence (phimx(1),phimix1)
      equivalence (phimx(2),phimix2)
      equivalence (phimx(3),phimix3)
      real*4 gmas2
      common/stopmix2/gmas2(3)
      real*4 stop2,sbot2,stau2
      equivalence (gmas2(1),stop2)
      equivalence (gmas2(2),sbot2)
      equivalence (gmas2(3),stau2)
      real*4 rscale
      common/sscale/rscale
      logical imsg                      !Added by S.A. for use in the
      common/imessage/imsg              !NTONPH routine

      double precision sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      common/higgses/sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      logical fix_higgs_masses
      common/ steerhiggs / fix_higgs_masses

      integer jdebu,idb1,idb2,lout
      common /debuc/ jdebu,idb1,idb2,lout

      real*8   xgaug,xeta
      COMMON/XCROS/xgaug(8),xeta(8)

      integer  ispa,kl,klap,idecs,klr
      common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
C 04/96 P.Morawitz & M.Williams introduce klr for Rpv gaugino decays
      common/reord2/klr(3,24)
c klr(1,n), klr(2,n) and klr(3,n) are the particles produced in
c R-parity violating decays of gauginos...
C n=1..4 , 5..8	 LLE neutralino,gaugino decays
C n=9..12,13..16 LQD neutralino,gaugino decays
C n=17.20,21..24 UDD neutralino,gaugino decays

      Integer  idecsel,ihigsel
      common/decsel/idecsel(23)
      common/higsel/ihigsel(5)
C 05/96 P.Morawitz
C ...   NOTE: the logical below is used in SUSYGEN V1.5 (April 96)
C       MSSM has its own implementation of R-parity violation.
C       The logical rpar is therefore always set to TRUE which avoids
C       the SUSYGEN R-parity code.
        logical rpar
        common/rpari/rpar
      real*8   brsum,brsuma
CPM      common/brsum/ brsum(5,6,6),brsuma(6)
C 04/96 P.Morawitz & M.Williams  changed brsum to allow for r-parity dec
      common/brsum/ brsum(13,7,6),brsuma(6)
************************************************************************
c EXPLANATION OF INDICES IN BRSUM(itype,igout,igin)
c
c igin  = 1,6 initial gaugino (neutralinos 1..4, charginos 1,2)
c igout = 1,7 outgoing gaugino
c ........where 7 => no outgoing gaugino ie. R-parity violating process
c itype = types of particles produced
c     1 - l+ l-    6 - l q qbar   10 - q q q'         12 - l+ l+ l-
c     2 - v vbar   7 - l q' qbar  11 - qbar qbar qbar 13 - l v v
c     3 - q qbar   8 - v q qbar
c     4 - l v      9 - v q' qbar
c     5 - q' qbar
************************************************************************
      real*8   fms,fmi,fmk,fml1,fml2,etai,etak,brspa
     +        ,brgaug,fmelt,fmert,fmelu,fmeru
      Integer  lind
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
CPM     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
     +lind(6,6,6),brgaug(6,7,11,3),fmelt,fmert,fmelu,fmeru
C 04/96 P.Morawitz & M.Williams  changed brgaug to allow for r-parity de

************************************************************************
c     EXPLANATIONS OF INDICES IN BRGAUG AND BRSPA
c
c BRSPA::
c kgaug =1,6 produced gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c kspar =1,24 initial sparticle
c     1,12  : left-handed sparticle  (u,d,v,e,c,s,v,mu,t,b,v,tau)
c     12,24 : right handed sparticle (u,d,v,e,c,s,v,mu,t,b,v,tau)
c
c BRGAUG::
c igin =1,6 parent gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c igout =1,7 daughter gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c     7    : none (ie. R-parity violating process)
c ipart =1,6 for produced particles .....
c     R-parity conserving decays
c     1,4  : uu,dd,vv,ee                                  - 'like to lik
c     5,6  : ud,ev                                        - 'like to unl
C ipart =7,11 for the 5 diagrams which involve
C             gaugino -> gaugino' gamma
C	      gaugino -> Higgs X
C
C
C ipart =1,8 for Rp-violating!!!! decays (igout=7)
c     R-parity violating decays via LLE operator
c     1,4 :                                               - for neutrali
c     5,8 : l+ l+ l, v v l+, vbar l+ v, l+ vbar v         - for chargino
c     R-parity violating decays via LQD operator
c     1,4  : e+ u dbar, e- ubar d, v d dbar, vbar dbar d  - for neutrali
c     5,8  : v u dbar, e+ dbar d, e+ ubar u, vbar dbar u  - for chargino
c     R-parity violating decays via UDD operator
c     1,4  :						  - for neutralinos
c     5,8  : u u d, u d u, dbar dbar dbar                 - for chargino
c igen =1,3
c     R-parity conserving decays : generation of produced particles
c     R-parity violating decays  : meaningless, i.e. only igen=1 used
************************************************************************
      Real*8   zr,was,esa
      Real*8   VOIJL,VOIJR,gfir,gfil
      COMMON/NEUMIX/ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
      real*8   OIJL,OIJR,V,U,FM,ETA
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      real*8   oijlp,oijrp
      COMMON/CHANEU/oijlp(4,2),oijrp(4,2)
      Integer       ILOOP
      COMMON/SFLOOP/ILOOP
      Real*8   PV
      Integer  IFLAV,NFLAV
CPM      COMMON /PARTC / PV(5,20),IFLAV(20,2),NFLAV
CPM      update to SUSYGEN V1.5
      COMMON /PARTC / pv(5,30)
      COMMON /PARTC1 / iflav(30,2),nflav


      real*8   gw,widfl,widfr,fmeltw,fmertw,fmeluw,fmeruw,gent,gentl
      integer  linda
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,7,6)
CPM     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
C 04/96 P.Morawitz & M.Williams  changed linda to allow for r-parity dec

      integer topo_charg,topo_neut
      common /topocom/ topo_charg,topo_neut

********************* end  of commons of SUSYGEN ***********************


      call vzero(lindex2,3)
      kin=0

      mindex1=iabs(lindex1)

      if(mindex1.lt.1.or.mindex1.gt.80)then
CYG         write(1,*)' error in lindex1 in decabr ',mindex1
        stop99
      endif

      nbod=1
      nm=ndeca(mindex1)
      lindex2(1)=lindex1
      if(nm.lt.1)return

   77 CHAN=RNDM(0)*brtot(2,nm,mindex1)

      do 10 j=1,nm
        if(chan.lt.brtot(2,j,mindex1))go to 20
   10 continue
   20 continue

      tmpindex=brtot(1,j,mindex1)

CYG      if(issmod(tmpindex).ne.mindex1)
CYG      +write(1,*)' error lindex1/issmod in decabr ',issmod(tmpindex),

      adeca=brtot(2,j,mindex1)

      nbod=3
      call ucopy(jssmod(1,tmpindex),kindex,3)
      if(kindex(3).eq.0)nbod=2

C ... see if we have the wright topology  - otherwise regenerate ...
C ... charginos
      IF (((((abs(index1).eq.75).or.(abs(index1).eq.77)).and.
     +   ((abs(index2).eq.75).or.(abs(index2).eq.77))))
     +           .and.(topo_charg.lt.4)) then
       IF ((mindex1.eq.75).or.(mindex1.eq.77)) then
       IF (topo_charg.eq.1) then
C ...          only select lnulnu events
        if (.not.(((abs(kindex(2)).ge.11)
     +        .and.(abs(kindex(2)).le.16))
     +        .and.((abs(kindex(3)).ge.11)
     +            .and.(abs(kindex(3)).le.16)))) goto 77
         ELSEIF (topo_charg.eq.2) then
C ...          only select lnujj events
          if (index1.eq.lindex1) then
           if (.not.(((abs(kindex(2)).ge.11)
     +            .and.(abs(kindex(2)).le.16))
     +            .and.((abs(kindex(3)).ge.11)
     +            .and.(abs(kindex(3)).le.16)))) goto 77
            else
           if (.not.(((abs(kindex(2)).ge.1)
     +            .and.(abs(kindex(2)).le.6))
     +            .and.((abs(kindex(3)).ge.1)
     +            .and.(abs(kindex(3)).le.6)))) goto 77
            endif
       ELSEIF (topo_charg.eq.3) then
C ...          only select 4j events
        if (.not.(((abs(kindex(2)).ge.1)
     +          .and.(abs(kindex(2)).le.6))
     +              .and.((abs(kindex(3)).ge.1)
     +          .and.(abs(kindex(3)).le.6)))) goto 77
       ENDIF
       ENDIF
      ENDIF


C ... see if we have the wright topology  - otherwise regenerate ...
C ... charginos
      IF (((((abs(index1).eq.75).or.(abs(index1).eq.77)).and.
     +   ((abs(index2).eq.75).or.(abs(index2).eq.77))))
     +           .and.(topo_charg.eq.5)) then
           IF ((mindex1.eq.75).or.(mindex1.eq.77)) then
C ... only chi+ -> neu2 + x cascades
        if (.not.(((abs(kindex(1)).eq.72)))) goto 77
        endif
      ENDIF


C ... see if we have the wright topology  - otherwise regenerate ...
C ... neutralino1 neutralino2 channels
      IF (((((abs(index1).eq.71).and.(abs(index2).eq.72)).or.
     +   ((abs(index1).eq.72).and.(abs(index2).eq.71))))
     +           .and.(topo_neut.lt.4)) then
          if (abs(lindex1).eq.72) then
           IF (topo_neut.eq.1) then
C ...          only select l lbar events
             if (.not.((abs(kindex(2)).eq.11).or.
     +   (abs(kindex(2)).eq.13).or.(abs(kindex(2)).eq.15))) then
                goto 77
               endif
           ELSEIF (topo_neut.eq.2) then
C ...          only select q qbar events
             if (.not.((abs(kindex(2)).ge.1).and.
     +                   (abs(kindex(2)).le.6))) then
                goto 77
               endif
           ELSEIF (topo_neut.eq.3) then
C ...          only select nu nubar events
             if (.not.((abs(kindex(2)).eq.12).or.
     +   (abs(kindex(2)).eq.14).or.(abs(kindex(2)).eq.16))) then
                goto 77
               endif
            endif
            endif
      ENDIF


      kferm=0
      kin=0
      do 40 k=1,nbod
        if(iabs(kindex(k)).gt.40)go to 30
        kferm=kferm+1
        fmass(kferm)=ssmass(kindex(k))
        lindex2(kferm)=kindex(k)
        if(lindex1.lt.0)lindex2(kferm)=-kindex(k)
        go to 40
   30   kin=k
   40 continue

      If (kin.ne.0) then
C     ... Rparity conserving decay, the last particle in the list is a g
         fmass(kferm+1)=ssmass(kindex(kin))
         lindex2(kferm+1)=kindex(kin)
         if(lindex1.lt.0)lindex2(kferm+1)=-kindex(kin)
      Endif

      RETURN
      END

      SUBROUTINE USER
      END


CPM      SUBROUTINE SFRAGMENT_new(IFLAG)
CPMC
CPMC-----------------------------------------
CPMC
CPMC     Author   :- Y. Gao + P.Morawitz
CPMC
CPMC=========================================
CPMC
CPMC     Purpose   : interface with LUND, the original code in SUSYGEN
CPMC     .           has been rewritten.
CPMC     Inputs    : none
CPMC     Outputs   : IFLAG=0 success
CPMC     .                =1 cannot find the colour partner
CPMC
CPMC=========================================
CPM
CPM      implicit none
CPM*CA SUWGHT
CPM
CPM      integer iflag
CPM
CPM      real P,V
CPM      INTEGER N,K
CPM      COMMON/LUJETS/N,K(4000,5),P(4000,5),V(4000,5)
CPM
CPM      DOUBLE PRECISION PV
CPM      COMMON /PARTC / pv(5,30)
CPM      INTEGER iflav,nflav,idbg,igener,irad
CPM      COMMON /PARTC1 / iflav(30,2),nflav
CPM      COMMON /CONST/ idbg,igener,irad
CPM      integer jev
CPM      common/kev/jev
CPM
CPM      INTEGER I
CPM
CPM      INTEGER      NP,KP(10),NG,KG(10)
CPM      REAL*8       PP(5),PG(5)
CPM
CPM      INTEGER      NMOT,IMOT(100,2)
CPM      REAL*4       QMX
CPM
CPM      real*8  flum,ecm,s,roots,T,Q,Q2,EN
CPM      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
CPM
CPM      INTEGER sprodind,quarkind
CPM      integer ijoin(3),skip
CPM
CPM      integer listshowerind(10,2),nshowers,ishowers
CPM      real    listqmx(10)
CPM      common/lushowers/listqmx
CPM      common/lushowers2/listshowerind,nshowers
CPM
CPM      integer j,offset
CPM
CPM      integer nm,jmot
CPM
CPM      real Minv12,Minv13,Minv23
CPM      integer diqu(3)
CPM      real psav(3,5),vsav(3,5)
CPM      integer ksav(3,5)
CPM      integer j1,j2
CPM
CPM      logical first
CPM      data first /.true./
CPM
CPM      logical asquark
CPM      external asquark
CPM
CPM      integer q1,q22,q3,q4,decprod1,decprod2
CPM      integer searchq
CPM
CPMC      if (first) then
CPMC           call pinterf
CPMC           first=.false.
CPMC        endif
CPM
CPM      nshowers = 0
CPM
CPMC*
CPMC*    pre-treatment, careful on the particle-antiparticle
CPMc     relationship
CPMC*    ==========================================================
CPMc     ======
CPM      IFLAG=0
CPM      DO I=1,NFLAV
CPM        IF( IFLAV(I,1).EQ.-71 ) IFLAV(I,1)=71
CPM        IF( IFLAV(I,1).EQ.-72 ) IFLAV(I,1)=72
CPM        IF( IFLAV(I,1).EQ.-73 ) IFLAV(I,1)=73
CPM        IF( IFLAV(I,1).EQ.-74 ) IFLAV(I,1)=74
CPM        IF( IFLAV(I,1).EQ.-75 ) IFLAV(I,1)=77
CPM        IF( IFLAV(I,1).EQ.-76 ) IFLAV(I,1)=78
CPM      ENDDO
CPMC*
CPMC*    original particles and gamma
CPMC*    ============================
CPM      N=0
CPM      if(NFLAV.EQ.0) then
CPM       write (*,*) ' SFRAGMENT info nflav returns',nflav
CPM         RETURN
CPM      endif
CPM
CPM      NP=0
CPM      NG=0
CPM      DO I=1,5
CPM        PG(I)=0.0D0
CPM        PP(I)=0.0D0
CPM      ENDDO
CPM      DO 10 I=1,NFLAV
CPM        IF( IFLAV(I,1).EQ.0 ) GOTO 10        ! empty line
CPM        IF( IFLAV(I,2).NE.0 ) GOTO 10        ! not the original
CPM        IF( IFLAV(I,1).EQ.22) THEN           ! ISR photon
CPM           NG=NG+1
CPM           PG(1)=PG(1)+PV(1,I)
CPM           PG(2)=PG(2)+PV(2,I)
CPM           PG(3)=PG(3)+PV(3,I)
CPM           PG(4)=PG(4)+PV(4,I)
CPM           KG(NG)=I
CPM        ELSE                                 ! other originals
CPM           NP=NP+1
CPM           PP(1)=PP(1)+PV(1,I)
CPM           PP(2)=PP(2)+PV(2,I)
CPM           PP(3)=PP(3)+PV(3,I)
CPM           PP(4)=PP(4)+PV(4,I)
CPM           KP(NP)=I
CPM        ENDIF
CPM10    CONTINUE
CPM      PP(5)=PP(4)**2-PP(1)**2-PP(2)**2-PP(3)**2
CPM      PP(5)=DSIGN(1.0D0,PP(5))*DSQRT(DABS(PP(5)))
CPM      PG(5)=PG(4)**2-PG(1)**2-PG(2)**2-PG(3)**2
CPM      PG(5)=DSIGN(1.0D0,PG(5))*DSQRT(DABS(PG(5)))
CPMC*
CPMC*    save beam particles in the first two lines (ALEPH e- ->+z)
CPMC*    ==========================================================
CPM      K(N+1,1)= 21
CPM      K(N+1,2)= 11
CPM      K(N+1,3)=  0
CPM      K(N+1,4)=  0
CPM      K(N+1,5)=  0
CPM      P(N+1,1)=  0.0
CPM      P(N+1,2)=  0.0
CPM      P(N+1,3)=  ECM/2.0D0
CPM      P(N+1,4)=  ECM/2.0D0
CPM      P(N+1,5)=  0.0
CPM      V(N+1,1)=  0.0
CPM      V(N+1,2)=  0.0
CPM      V(N+1,3)=  0.0
CPM      V(N+1,4)=  0.0
CPM      V(N+1,5)=  0.0
CPM
CPM      K(N+2,1)= 21
CPM      K(N+2,2)=-11
CPM      K(N+2,3)=  0
CPM      K(N+2,4)=  0
CPM      K(N+2,5)=  0
CPM      P(N+2,1)=  0.0
CPM      P(N+2,2)=  0.0
CPM      P(N+2,3)= -ECM/2.0D0
CPM      P(N+2,4)=  ECM/2.0D0
CPM      P(N+2,5)=  0.0
CPM      V(N+2,1)=  0.0
CPM      V(N+2,2)=  0.0
CPM      V(N+2,3)=  0.0
CPM      V(N+2,4)=  0.0
CPM      V(N+2,5)=  0.0
CPM
CPM      N=N+2
CPMC*
CPMC*    ISR GAMMAS
CPMC*    ==========
CPM      DO 20 I=1,NG
CPM        N      =  N+1
CPM        K(N,1) =  1
CPM        K(N,2) = 22
CPM        K(N,3) =  0
CPM        K(N,4) =  0
CPM        K(N,5) =  0
CPM        P(N,1) =  PV(1,KG(I))
CPM        P(N,2) =  PV(2,KG(I))
CPM        P(N,3) =  PV(3,KG(I))
CPM        P(N,4) =  PV(4,KG(I))
CPM        P(N,5) =  PV(5,KG(I))
CPM        V(N,1) =  0.0
CPM        V(N,2) =  0.0
CPM        V(N,3) =  0.0
CPM        V(N,4) =  0.0
CPM        V(N,5) =  0.0
CPM20    CONTINUE
CPMC*
CPMC*    mediate state: SUSY st
CPMC*    ======================
CPM      N      =  N+1
CPM      K(N,1) = 11
CPM      K(N,2) = 79
CPM      K(N,3) =  0
CPM      K(N,4) =  N+1
CPM      K(N,5) =  N+NP
CPM      P(N,1) =  PP(1)
CPM      P(N,2) =  PP(2)
CPM      P(N,3) =  PP(3)
CPM      P(N,4) =  PP(4)
CPM      P(N,5) =  PP(5)
CPM      V(N,1) =  0.0
CPM      V(N,2) =  0.0
CPM      V(N,3) =  0.0
CPM      V(N,4) =  0.0
CPM      V(N,5) =  0.0
CPM
CPM      NM=N
CPMC*
CPMC*    Store original particles
CPMC*    ========================
CPM      NMOT=0
CPM      DO 30 I=1,NP
CPM        N      =  N+1
CPM        K(N,1) =  1
CPM        K(N,2) =  IFLAV(KP(I),1)
CPM        K(N,3) =  NM
CPM        K(N,4) =  0
CPM        K(N,5) =  0
CPM        P(N,1) =  PV(1,KP(I))
CPM        P(N,2) =  PV(2,KP(I))
CPM        P(N,3) =  PV(3,KP(I))
CPM        P(N,4) =  PV(4,KP(I))
CPM        P(N,5) =  PV(5,KP(I))
CPM        V(N,1) =  0.
CPM        V(N,2) =  0.
CPM        V(N,3) =  0.
CPM        V(N,4) =  0.
CPM        V(N,5) =  0.
CPM
CPM        NMOT        =NMOT+1
CPM        IMOT(NMOT,1)=KP(I)
CPM        IMOT(NMOT,2)=N
CPM30    CONTINUE
CPMC*
CPMC*    Other particles, by order
CPMC*    =========================
CPM      JMOT=0
CPM41    JMOT=JMOT+1
CPM      IF(JMOT.GT.NMOT) GOTO 40
CPM
CPM      DO 42 I=1,NFLAV
CPM        IF( IFLAV(I,2).NE.IMOT(JMOT,1) ) GOTO 42
CPM
CPM        N      =  N+1
CPM        K(N,1) =  1
CPM        K(N,2) =  IFLAV(I,1)
CPM        K(N,3) =  IMOT(JMOT,2)
CPM        K(N,4) =  0
CPM        K(N,5) =  0
CPM        P(N,1) =  PV(1,I)
CPM        P(N,2) =  PV(2,I)
CPM        P(N,3) =  PV(3,I)
CPM        P(N,4) =  PV(4,I)
CPM        P(N,5) =  PV(5,I)
CPM        V(N,1) =  0.
CPM        V(N,2) =  0.
CPM        V(N,3) =  0.
CPM        V(N,4) =  0.
CPM        V(N,5) =  0.
CPM
CPM        IF( K(IMOT(JMOT,2),4).EQ.0 ) THEN
CPM          K(IMOT(JMOT,2),1)=11
CPM          K(IMOT(JMOT,2),4)= N
CPM          K(IMOT(JMOT,2),5)= N
CPM        ELSE
CPM          K(IMOT(JMOT,2),5)=K(IMOT(JMOT,2),5)+1
CPM        ENDIF
CPM
CPM        NMOT         = NMOT+1
CPM        IMOT(NMOT,1) = I
CPM        IMOT(NMOT,2) = N
CPM42    CONTINUE
CPM      GOTO 41
CPM 40   CONTINUE
CPM
CPMC     --- now loop over particles to determine their correct vertices
CPM      DO I=1,N
CPM         IF (K(I,3).ne.0) then
CPM            DO J=1,4
CPM               V(I,J) =  V(I,J)+V(K(I,3),J)
CPM            ENDDO
CPM         ENDIF
CPM      ENDDO
CPM
CPMc
CPM      IF (IPRI.ge.10) write (*,*) ' before colour assignments'
CPM      IF (IPRI.ge.10) CALL LULIST(3)
CPM
CPM
CPMC*
CPMC*    check the colour string
CPMC*    =======================
CPMC
CPMC ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CPMC ... find the (decayed) pairproduced squarks
CPMC ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CPM      DO sprodind=1,N
CPM         if (K(sprodind,2).eq.79) goto 33
CPM      ENDDO
CPM      STOP 'SFRAGMENT: No SusyProd0 found - fatal'
CPM 33   CONTINUE
CPM
CPM      IF (ASQUARK(K(sprodind+1,2))) THEN
CPMC     ...what's it decayed into
CPM         IF (K(sprodind+1,1).eq.11) THEN
CPM            CALL SQUARKDECAY(sprodind+1,decprod1,q1,q22)
CPM            CALL SQUARKDECAY(sprodind+2,decprod2,q3,q4)
CPM            IF ((decprod1.eq.1).and.(decprod2.eq.1)) THEN
CPM               CALL CONNECT2(q1,q3)
CPM            ELSEIF ((decprod1.eq.2).and.(decprod2.eq.1)) THEN
CPM               CALL CONNECT3(q3,q1,q22)
CPM            ELSEIF ((decprod1.eq.1).and.(decprod2.eq.2)) THEN
CPM               CALL CONNECT3(q1,q3,q4)
CPM            ELSEIF ((decprod1.eq.2).and.(decprod2.eq.2)) THEN
CPM               CALL CONNECT2(q1,q22)
CPM               CALL CONNECT2(q3,q4)
CPM            ELSE
CPM               STOP 'SFRAGMENT: squark does not decay to quark ???'
CPM            ENDIF
CPM         ENDIF
CPM      ENDIF
CPM
CPM
CPMC ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CPMC ... find the other (decayed) squarks
CPMC ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CPM      DO I=sprodind+3,N
CPM         IF ((ABS(K(I,1)).eq.11).and.(ASQUARK(K(I,2)))) then
CPMC     ...   was it a gaugino -> q squark decay?
CPM            q1=0
CPM            DO searchq=N,sprodind+3,-1
CPM               IF (ABS(K(searchq,1)).eq.1) then
CPM                  IF ((ABS(K(searchq,2)).le.10).AND.
CPM     +                (K(searchq,3).EQ.K(I,3))) THEN
CPM                    q1=searchq
CPM                    GOTO 71
CPM                  ENDIF
CPM               ENDIF
CPM            ENDDO
CPM
CPM            STOP 'SFRAGMENT: ghost squark ???'
CPM
CPM 71         CONTINUE
CPM
CPMC     ....  get the decay products from the squark
CPM            CALL SQUARKDECAY(I,decprod1,q22,q3)
CPM            IF (decprod1.eq.1) THEN
CPM               CALL CONNECT2(q1,q22)
CPM            ELSEIF (decprod1.eq.2) THEN
CPM               CALL CONNECT3(q1,q22,q3)
CPM            ELSE
CPM               STOP 'SFRAGMENT: squark does not decay to quark ???'
CPM            ENDIF
CPM
CPM         ENDIF
CPM      ENDDO
CPM
CPM
CPMC ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CPMC ... and connect q q' or q q' q'' type events
CPMC ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CPM      DO I=sprodind+3,N-1
CPMC     ...
CPM         IF ((ABS(K(I,1)).eq.1).and.(ABS(K(I,2)).LE.10)) THEN
CPM            CALL FINDotherquarks(I,decprod1,q1,q22)
CPM            IF (decprod1.eq.1) CALL CONNECT2(I,q1)
CPM            IF (decprod1.eq.2) CALL CONNECT3(I,q1,q22)
CPM         ENDIF
CPM      ENDDO
CPM
CPM      DO I=1,N
CPM         IF (K(I,1).eq.77) K(I,1)=1
CPM      ENDDO
CPM
CPM
CPMC      now the final state part ...
CPMC      must be done before LUEXEC, otherwise PHOTOS gets
CPMc     confused
CPMC     and final state radiation
CPM      IF (IPRI.gt.10) write (*,*)
CPM     +     ' after colour assignments, before fsr'
CPM      IF (IPRI.gt.10)        CALL LULIST(3)
CPM      IF (ifrad.eq.1) then
CPM        call fsradd(jev)
CPM      endif
CPM      IF (IPRI.gt.10)        write (*,*) ' after fsr, before showerin
CPM      IF (IPRI.gt.10)        CALL LULIST(3)
CPM
CPM
CPM      DO ishowers=1,nshowers
CPM         CALL LUSHOW(listshowerind(ishowers,1),
CPM     +            listshowerind(ishowers,2),listqmx(ishowers))
CPM      ENDDO
CPM
CPMC*
CPMC*    Finally, LUEXEC
CPMC*    ===============
CPMc
CPM      CALL LUEXEC
CPM      IF (IPRI.ge.10)       CALL LULIST(3)
CPM
CPMC     and clean up event
CPM      DO I=1,N
CPM 66      if         (((((((((((((((P(I,1).eq.0.).and.(P(I,2).eq.0.)).
CPM     +        .(P(I,3).eq.0.)).and.(P(I,4).eq.0.)).and.(P(I,5).eq.0.)
CPM     +        .and.(V(I,1).eq.0.)).and.(V(I,2).eq.0.)).and.(V(I,3).eq
CPM     +        )).and.(V(I,4).eq.0.)).and.(V(I,5).eq.0.)).and.(K(I,1)
CPM     +        .eq.0)).and.(K(I,2).eq.0)).and.(K(I,3).eq.0)).and.(K(I,
CPM     +        .eq.0)).and.(K(I,5).eq.0)) then
CPM            call ludelete(I)
CPM            goto 66
CPM         endif
CPM      ENDDO
CPM
CPMC     and delete the diquark systems, which KINGAL can't cope with
CPM      DO I=1,N
CPM 67      if         (((((P(I,1).eq.0.).and.(P(I,2).eq.0.)).and
CPM     +        .(P(I,3).eq.0.)).and.(P(I,4).eq.0.)).and.(P(I,5).eq.0.)
CPM     +         then
CPM            call ludelete(I)
CPM            goto 67
CPM         endif
CPM      ENDDO
CPM
CPM      IF (IPRI.ge.1)       CALL LULIST(3)
CPM
CPM      END

*DL LUTOOLS
      subroutine luinsert(I)
C     --------------------------
C     Author Peter Morawitz Nov 96
C     insert a particle into JETSET common + update all
C     mother/daughter relationships

      implicit none
      integer j,k1,icfr,icto,i

      integer n,k
      real p,v
      COMMON/LUJETS/N,K(4000,5),P(4000,5),V(4000,5)

      DO j=N,I,-1
       DO k1=1,5
            P(J+1,k1)=P(J,k1)
          K(J+1,k1)=K(J,k1)
          V(J+1,k1)=V(J,k1)
       ENDDO

C ...    update mother / daughter relationships

         IF (K(J+1,3).ge.I) K(J+1,3)=K(J+1,3)+1
       icfr=K(J+1,4)/10000
         icto=MOD(K(J+1,4),10000)
       if (icfr.ge.I) icfr=icfr+1
       if (icto.ge.I) icto=icto+1
       K(J+1,4)=10000*icfr+icto
      ENDDO
      N=N+1
      end

      subroutine connect2(i1,i2)
      implicit none
C     Author:     Peter Morawitz Dec96
C     Purpose:    Connect 2 quarks in JETSET
C     .         results are stored in listshowerind(10,2),nshowers
c     .         ,listqmx(10)
      integer i1,i2

      integer listshowerind(10,2),nshowers,ishowers
      real    listqmx(10)
      common/lushowers/listqmx
      common/lushowers2/listshowerind,nshowers

      real P,V
      INTEGER N,K
      COMMON/LUJETS/N,K(4000,5),P(4000,5),V(4000,5)

      real qmx
      integer diquark
      external diquark

      real psav(3,5),vsav(3,5)
      integer ksav(3,5)
      integer j1,j2,i3

C     ... first check if it is a squark -> q q' type event where
C     ... q q'  forms a diquark
      I3=diquark(K(I1,2),K(I2,2))
      IF (I3.ne.0) Then
C     ... Jetset can't handle the above type of event
C     => fragment independently
         continue
      ELSE
C     .an ordianry q q' vertex
         K(I1  ,1)=3
         K(I1  ,4)=10000*(I2)
         K(I1  ,5)=10000*(I2)
         K(I2,1)=3
         K(I2,4)=10000*I1
         K(I2,5)=10000*I1
         QMX=(P(I1,4)+P(I2,4))**2
     &        -(P(I1,3)+P(I2,3))**2
     &        -(P(I1,2)+P(I2,2))**2
     &        -(P(I1,1)+P(I2,1))**2
         QMX=SIGN(1.0,QMX)*SQRT(ABS(QMX))

         nshowers=nshowers+1
         listshowerind(nshowers,1)=I1
         listshowerind(nshowers,2)=I2
         listqmx(nshowers)=QMX
      ENDIF
      END

      subroutine connect3(i1,i2,i3)
C     Author:     Peter Morawitz Dec96
C     Purpose:    Connect 3 quarks in JETSET using Tjorborn's
c     .           prescription. i2i3 form a diquark
C     Sideeffect: the new particles are added at the end of the
C     .           JETSET record
      implicit none
      integer i1,i2,i3
      integer diqu(3)
      real psav(3,5),vsav(3,5)
      integer ksav(3,5)
      integer j1,j2

      real P,V
      INTEGER N,K
      COMMON/LUJETS/N,K(4000,5),P(4000,5),V(4000,5)

      diqu(1)=2
      diqu(2)=3
      diqu(3)=1

      do j1=1,5
         psav(1,j1)=P(i1,j1)
         ksav(1,j1)=K(i1,j1)
         vsav(1,j1)=V(i1,j1)
         psav(2,j1)=P(i2,j1)
         ksav(2,j1)=K(i2,j1)
         vsav(2,j1)=V(i2,j1)
         psav(3,j1)=P(i3,j1)
         ksav(3,j1)=K(i3,j1)
         vsav(3,j1)=V(i3,j1)
      enddo

C     ...  Kill the quarks i1,i2,i3
      CALL LUKILL(i1)
      CALL LUKILL(i2)
      CALL LUKILL(i3)
C     ...  and insert 4 lines
      N=N+4

C ...         fill the diquark system
      do j2=1,2
         do j1=1,5
            P(N-4+j2,j1)=psav(diqu(j2),j1)
            K(N-4+j2,j1)=ksav(diqu(j2),j1)
            V(N-4+j2,j1)=vsav(diqu(j2),j1)
         enddo
      enddo
      k(N-4+1,1)=2
      k(N-4+2,1)=2
      k(N-4+1,4)=0
      k(N-4+2,4)=0
      k(N-4+1,5)=0
      k(N-4+2,5)=0

C ...         fill the null junction / with correct diquark flavour
      do j1=1,5
         P(N-4+3,j1)=0.
         V(N-4+3,j1)=vsav(diqu(1),j1)
         K(N-4+3,j1)=ksav(diqu(1),j1)
      enddo
      K(N-4+3,1)=41

C         build a diquark
      K(N-4+3,2)=(1000*Max(ABS(K(N-4+1,2)),ABS(K(N-4+2,2)))+
     +     100*Min(ABS(K(N-4+1,2)),ABS(K(N-4+2,2)))+2+1)*
     +     sign(1,K(N-4+1,2))
      K(N-4+3,4)=0
      K(N-4+3,5)=0
C
C ...         and fill the third quark
c
      do j1=1,5
         P(N,j1)=psav(diqu(3),j1)
         K(N,j1)=ksav(diqu(3),j1)
         V(N,j1)=vsav(diqu(3),j1)
      enddo
      K(N,1)=77               ! special code, convert to 1 at the end
      K(N,4)=0
      K(N,5)=0

C ... and delete the mother->daughter relation ship, which is no longer
      K(ksav(1,3),4)=0
      K(ksav(1,3),5)=0
      K(ksav(2,3),4)=0
      K(ksav(2,3),5)=0
      K(ksav(3,3),4)=0
      K(ksav(3,3),5)=0

      END

      SUBROUTINE LUKILL(i1)
C     Author:  Peter Morawitz Dec96
C     Purpose: kill a line in the JETSET common
C
      IMPLICIT NONE
      integer i1,j

      real P,V
      INTEGER N,K
      COMMON/LUJETS/N,K(4000,5),P(4000,5),V(4000,5)

      DO j=1,5
         P(i1,j)=0.
         K(i1,j)=0
         V(i1,j)=0.
      ENDDO

      K(i1,1)=0
      END

      LOGICAL FUNCTION ASQUARK(i)
C     Author:  Peter Morawitz Dec96
C     Purpose: is it a squark?
      implicit none
      integer i

      IF ((((ABS(I).ge.41).and.(ABS(I).le.50)).or.((ABS(I).ge.61).and
     +     .(ABS(I).le.64))).or.((ABS(I).eq.66).or.(ABS(I).eq.67))) then
         ASQUARK=.true.
      ELSE
         ASQUARK=.FALSE.
      ENDIF
      END

      Subroutine Findqurk(I,decprod1,q1,q2)
C     Author:  Peter Morawitz Dec96
C     Purpose: Find other quarks which have the same parent as particle
c     and have not yet decayed
      implicit none
      real P,V
      INTEGER N,K
      COMMON/LUJETS/N,K(4000,5),P(4000,5),V(4000,5)

      integer decprod1,q1,q2,j,I
      q1=0
      q2=0
      decprod1=0
      DO j=1,N
         IF (I.ne.J) THEN
            IF ((ABS(K(j,1)).eq.1).AND.(ABS(K(J,2)).LE.10)) Then
               IF (K(j,3).eq.K(i,3)) Then
                  decprod1=decprod1+1
                  if (decprod1.gt.2)
     +                 STOP 'Findqurk: too many quarks'

                  if (decprod1.eq.1) q1=j
                  if (decprod1.eq.2) q2=j
               ENDIF
            ENDIF
         ENDIF
      ENDDO
      END

      SUBROUTINE squdecay(squark,decprod1,q1,q2)
C     Author:  Peter Morawitz Dec96
C     Purpose: Find decay products of squark
      implicit none
      real P,V
      INTEGER N,K
      COMMON/LUJETS/N,K(4000,5),P(4000,5),V(4000,5)

      integer squark,decprod1,q1,q2
      integer i

      decprod1=0
      q1=0
      q2=0

      DO I=1,N
         IF (I.ne.squark) THEN
            IF (((ABS(K(I,3)).eq.squark).AND.(K(I,1).EQ.1)).AND.(ABS(K(I
     +           ,2)).LE.10)) THEN
               decprod1=decprod1+1
               if (decprod1.gt.2)
     +              STOP 'squdecay: too many quarks'

               if (decprod1.eq.1) q1=i
               if (decprod1.eq.2) q2=i
            ENDIF
         ENDIF
      ENDDO
      END

      INTEGER FUNCTION DIQUARK(I1,I2)
C     Author:  Peter Morawitz Dec96
C     Purpose: Find out if flavours I1,I2 form a valid diquark
C     .        returns flavour "I3" which makes the system I1,I2,I3
C     .        carry integer net charge
C     .        IF I3=0 then I1,I2 do not form a valid diquark
      Implicit none
      Integer I1,I2,I
      INTEGER c1,c2,c

      INTEGER diqm(4,4)
      DATA diqm /-1,0,-1,0, 0,2,0,1, -1,0,-2,0, 0,1,0,1/


      integer jj1,jj2

      DIQUARK=0

      c1=INT(SIGN(1.0,REAL(I1)))
      c2=INT(SIGN(1.0,REAL(I2)))

      I=I1
      IF (((ABS(I).eq.1).or.(ABS(I).eq.3)).or.(ABS(I).eq.5)) THEN
         c=-1
      ELSEIF (((ABS(I).eq.2).or.(ABS(I).eq.4)).or.(ABS(I).eq.6)) THEN
         c=2
      ELSE
         return
      ENDIF
      c1=c1*c

      I=I2
      IF (((ABS(I).eq.1).or.(ABS(I).eq.3)).or.(ABS(I).eq.5)) THEN
         c=-1
      ELSEIF (((ABS(I).eq.2).or.(ABS(I).eq.4)).or.(ABS(I).eq.6)) THEN
         c=2
      ELSE
         return
      ENDIF
      c2=c2*c

      IF (c1.gt.0) c1=c1-1
      IF (c2.gt.0) c2=c2-1


      diquark=diqm(c1+3,c2+3)
      END

      subroutine ludelete(I)
C     --------------------------
C     Author Peter Morawitz Nov 96
C     delete a particle from JETSET common + update all
C     mother/daughter relationships

      implicit none
      integer j,k1,icfr,icto,i

      integer n,k
      real p,v
      COMMON/LUJETS/N,K(4000,5),P(4000,5),V(4000,5)

      DO j=I+1,N
       DO k1=1,5
            P(J-1,k1)=P(J,k1)
          K(J-1,k1)=K(J,k1)
          V(J-1,k1)=V(J,k1)
       ENDDO

C ...    update mother / daughter relationships

         IF (K(J-1,3).gt.I) K(J-1,3)=K(J-1,3)-1
       icfr=K(J-1,4)/10000
         icto=MOD(K(J-1,4),10000)
       if (icfr.gt.I) icfr=icfr-1
       if (icto.gt.I) icto=icto-1
       K(J-1,4)=10000*icfr+icto
      ENDDO
      N=N-1
      end

      SUBROUTINE suseve(ifail)
C
C  Modified quite extensively by M.Williams   Dec 96 - Mar 97
C  Squark hadronisation now a possibility
C-----------------------------------------------------------------------
C-
C-   GENERATE AN EVENT
C-
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
********************* start of commons of SUSYGEN **********************
      integer ievent
      common /eve/ ievent
      real*4  rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan(6)
      common /rkey/rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan

      real*8  gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu
      common/steer/gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu

      Integer modes,MIX
      common/mds/modes,MIX
      logical zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,higgs
      common/sparc/ zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,
     + higgs
      logical wrt,scan,lepi
      common/str/wrt,scan,lepi
      real*8  flum,ecm,s,roots,T,Q,Q2,EN
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
      real*8  QK
      COMMON/ISR/ QK(4)
      real erad,srad
      common/srada/erad(100),srad(100)
      integer  idbg,igener,irad
      COMMON /CONST/ idbg,igener,irad
      integer  index,index1,index2,nevt
      COMMON/INDEXX/index,index1,index2,nevt
      real*8   fmpr1,fmpr2,XCROST,APRO
      COMMON/FINDEX/fmpr1,fmpr2,XCROST,APRO
      real*8   cosphimix,facqcd,fgama,spartmas,ratq
      common/mixings/cosphimix,facqcd,fgama,spartmas,ratq
      real*8   FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +         FLC,FRC,gms,echar
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
      real*8      TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      real*8   fmal,fmar,ratqa,fgamc,fgamcr,cosmi
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)

      real*4 gmas,phimx
      common/stopmix/gmas(3),phimx(3)
      real*4 phimix1,stop1,phimix2,sbot1,phimix3,stau1
      equivalence (gmas(1),stop1)
      equivalence (gmas(2),sbot1)
      equivalence (gmas(3),stau1)
      equivalence (phimx(1),phimix1)
      equivalence (phimx(2),phimix2)
      equivalence (phimx(3),phimix3)
      real*4 gmas2
      common/stopmix2/gmas2(3)
      real*4 stop2,sbot2,stau2
      equivalence (gmas2(1),stop2)
      equivalence (gmas2(2),sbot2)
      equivalence (gmas2(3),stau2)
      real*4 rscale
      common/sscale/rscale
      logical imsg                      !Added by S.A. for use in the
      common/imessage/imsg              !NTONPH routine

      double precision sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      common/higgses/sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      logical fix_higgs_masses
      common/ steerhiggs / fix_higgs_masses

      integer jdebu,idb1,idb2,lout
      common /debuc/ jdebu,idb1,idb2,lout

      real*8   xgaug,xeta
      COMMON/XCROS/xgaug(8),xeta(8)

      integer  ispa,kl,klap,idecs,klr
      common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
C 04/96 P.Morawitz & M.Williams introduce klr for Rpv gaugino decays
      common/reord2/klr(3,24)
c klr(1,n), klr(2,n) and klr(3,n) are the particles produced in
c R-parity violating decays of gauginos...
C n=1..4 , 5..8	 LLE neutralino,gaugino decays
C n=9..12,13..16 LQD neutralino,gaugino decays
C n=17.20,21..24 UDD neutralino,gaugino decays

      Integer  idecsel,ihigsel
      common/decsel/idecsel(23)
      common/higsel/ihigsel(5)
C 05/96 P.Morawitz
C ...   NOTE: the logical below is used in SUSYGEN V1.5 (April 96)
C       MSSM has its own implementation of R-parity violation.
C       The logical rpar is therefore always set to TRUE which avoids
C       the SUSYGEN R-parity code.
        logical rpar
        common/rpari/rpar
      real*8   brsum,brsuma
CPM      common/brsum/ brsum(5,6,6),brsuma(6)
C 04/96 P.Morawitz & M.Williams  changed brsum to allow for r-parity dec
      common/brsum/ brsum(13,7,6),brsuma(6)
************************************************************************
c EXPLANATION OF INDICES IN BRSUM(itype,igout,igin)
c
c igin  = 1,6 initial gaugino (neutralinos 1..4, charginos 1,2)
c igout = 1,7 outgoing gaugino
c ........where 7 => no outgoing gaugino ie. R-parity violating process
c itype = types of particles produced
c     1 - l+ l-    6 - l q qbar   10 - q q q'         12 - l+ l+ l-
c     2 - v vbar   7 - l q' qbar  11 - qbar qbar qbar 13 - l v v
c     3 - q qbar   8 - v q qbar
c     4 - l v      9 - v q' qbar
c     5 - q' qbar
************************************************************************
      real*8   fms,fmi,fmk,fml1,fml2,etai,etak,brspa
     +        ,brgaug,fmelt,fmert,fmelu,fmeru
      Integer  lind
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
CPM     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
     +lind(6,6,6),brgaug(6,7,11,3),fmelt,fmert,fmelu,fmeru
C 04/96 P.Morawitz & M.Williams  changed brgaug to allow for r-parity de

************************************************************************
c     EXPLANATIONS OF INDICES IN BRGAUG AND BRSPA
c
c BRSPA::
c kgaug =1,6 produced gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c kspar =1,24 initial sparticle
c     1,12  : left-handed sparticle  (u,d,v,e,c,s,v,mu,t,b,v,tau)
c     12,24 : right handed sparticle (u,d,v,e,c,s,v,mu,t,b,v,tau)
c
c BRGAUG::
c igin =1,6 parent gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c igout =1,7 daughter gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c     7    : none (ie. R-parity violating process)
c ipart =1,6 for produced particles .....
c     R-parity conserving decays
c     1,4  : uu,dd,vv,ee                                  - 'like to lik
c     5,6  : ud,ev                                        - 'like to unl
C ipart =7,11 for the 5 diagrams which involve
C             gaugino -> gaugino' gamma
C	      gaugino -> Higgs X
C
C
C ipart =1,8 for Rp-violating!!!! decays (igout=7)
c     R-parity violating decays via LLE operator
c     1,4 :                                               - for neutrali
c     5,8 : l+ l+ l, v v l+, vbar l+ v, l+ vbar v         - for chargino
c     R-parity violating decays via LQD operator
c     1,4  : e+ u dbar, e- ubar d, v d dbar, vbar dbar d  - for neutrali
c     5,8  : v u dbar, e+ dbar d, e+ ubar u, vbar dbar u  - for chargino
c     R-parity violating decays via UDD operator
c     1,4  :						  - for neutralinos
c     5,8  : u u d, u d u, dbar dbar dbar                 - for chargino
c igen =1,3
c     R-parity conserving decays : generation of produced particles
c     R-parity violating decays  : meaningless, i.e. only igen=1 used
************************************************************************
      Real*8   zr,was,esa
      Real*8   VOIJL,VOIJR,gfir,gfil
      COMMON/NEUMIX/ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
      real*8   OIJL,OIJR,V,U,FM,ETA
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      real*8   oijlp,oijrp
      COMMON/CHANEU/oijlp(4,2),oijrp(4,2)
      Integer       ILOOP
      COMMON/SFLOOP/ILOOP
      Real*8   PV
      Integer  IFLAV,NFLAV
CPM      COMMON /PARTC / PV(5,20),IFLAV(20,2),NFLAV
CPM      update to SUSYGEN V1.5
      COMMON /PARTC / pv(5,30)
      COMMON /PARTC1 / iflav(30,2),nflav


      real*8   gw,widfl,widfr,fmeltw,fmertw,fmeluw,fmeruw,gent,gentl
      integer  linda
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,7,6)
CPM     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
C 04/96 P.Morawitz & M.Williams  changed linda to allow for r-parity dec

      integer topo_charg,topo_neut
      common /topocom/ topo_charg,topo_neut

********************* end  of commons of SUSYGEN ***********************

      INTEGER    L1MST,L1PAR
     &          ,L2PAR,L2PARF
     &          ,LJNPAR
      PARAMETER (L1MST=200, L1PAR=200)
      PARAMETER (L2PAR=500, L2PARF=2000)
      PARAMETER (LJNPAR=4000)
      COMMON /LUDAT1/ MSTU(L1MST),PARU(L1PAR),MSTJ(L1MST),PARJ(L1PAR)
      INTEGER         MSTU,MSTJ
      REAL            PARU,PARJ
      COMMON /LUDAT2/ KCHG(L2PAR,3),PMAS(L2PAR,4),PARF(L2PARF),VCKM(4,4)
      INTEGER         KCHG
      REAL            PMAS,PARF,VCKM
      COMMON /LUDAT3/ MDCY(L2PAR,3),MDME(L2PARF,2),BRAT(L2PARF),
     &                KFDP(L2PARF,5)
      INTEGER         MDCY,MDME,KFDP
      REAL            BRAT
      COMMON /LUDAT4/ CHAF(L2PAR)
      CHARACTER*8     CHAF
      COMMON /LUJETS/ N7LU,K7LU(LJNPAR,5),P7LU(LJNPAR,5),V7LU(LJNPAR,5)
      INTEGER         N7LU,K7LU
      REAL            P7LU,V7LU

      REAL*4 RNDM

      integer*4 lindex(3)

      CHARACTER*5 LBLIN,SSID

      logical sq_logic

      real as,ampl,hrndm1
      external ampl

      real*8 dummyar(5)
      integer i_sq_had
      common /sqhdcom/ i_sq_had
      integer ispart,ksusy,ispart2,nsusy,ninit,nprod
      common /fcomm/ nsusy,ninit,nprod,ispart(100),ispart2(100)
     &     ,ksusy(100)
      INTEGER      NP,KP(10),NG,KG(10)
      REAL*8       PP(5),PG(5)
      COMMON /FRAGCOM/PP,PG,NP,KP,NG,KG
      integer frad
      common /fsr/ frad

      integer ifsrph
      real*8  pfsrphot
      integer imothfsr

      common /FPHOTONS/ pfsrphot(5,100),imothfsr(100),ifsrph

*     first reset the colour coherence effect switch to the
*     default (gets modified in squark_frag)
      MSTJ(50)=3

* and set FSR photon counter to 0
      ifsrph=0

      ifail=1

      ntry=0

   10 continue
*
* Generate event with or without ISR
*
      IF(IRAD.EQ.1) THEN
        CALL REMT2(QK)
        E=ecm/2.D0
        s=ecm**2*(1.-QK(4)/E)
        ROOTS=DSQRT(S)
      ELSE
        s=ECM**2
        ROOTS=ECM
        QK(1) = 0.0000D0
        QK(2) = 0.0000D0
        QK(3) = 0.0001D0
        QK(4) = 0.0001D0
      ENDIF
*
* Now sort out the two initially produced particles
*
      IFLAG=0
      nflav=2

      XPCM = XLAMDA (roots**2,fmpr1**2,fmpr2**2)/ (2. * roots)

      ntry=ntry+1
      if(ntry.gt.10000)then
        write(*,*) ' more than 10000 tries in REMT2 loop '
        return
      endif
      if(xpcm.eq.0..and.irad.eq.1)go to 10
*
* Generate ds/dcostheta
*
      call hbfun1(9999,' ',50,-1.,1.,ampl)
      cthcm=hrndm1(9999)
      call hdelet(9999)

      PHCM  = TWOPI * dble(RNDM(0))
      STHCM = DSQRT( 1. - CTHCM**2 )
      CPHCM = DCOS( PHCM )
      SPHCM = DSIN( PHCM )
*
* The first produced particle
*
      CALL sdecay2 ( XPCM,CTHCM,PHCM,fmpr1,PV(1,1))
      lblin=ssid(index1)
      IFLAV(1,1)=INDEX1
      IFLAV(1,2)=0
*
* The second produced particle
*
      CALL sdecay2 (-XPCM,CTHCM,PHCM,fmpr2,PV(1,2))
      lblin=ssid(index2)
      IFLAV(2,1)=INDEX2
      IFLAV(2,2)=0
*
* And include the effect of ISR on these particles
*
      IF(IRAD.EQ.1.and.qk(4).gt.0.001)THEN
         do 60  lp=1,3
 60      qk(lp)=-qk(lp)
*
         do 70  j=1,2
            CALL REMT3(QK,PV(1,j),PV(1,j))
 70      continue
*
* Store the info. on the ISR photon and increment particle count
*
         nflav=nflav+1
*
         do 80 j=1,4
 80      pv(j,3)=qk(j)
         pv(5,3)=0.
         iflav(3,1)=22
         iflav(3,2)=0
      END IF
*
* Now store these initial particles in the event record
*
      call sfrag_init(ifail)
*
* Have we produced squarks?
*
      sq_logic = .false.
      if (index1.le.50.or.index1.ge.61) then
         if (index1.le.67.and.index1.ne.65) then
            sq_logic = .true.
         end if
      end if
*
      nsusy = 0
      nprod = 0
      ninit = 0
      if (i_sq_had.eq.1.and.sq_logic) then
*
* Perform squark hadronisation
*
         call squark_frag(ifail)
      else
*
* Without squark hadronisation all we need to do is set up the
* correct values of the variables below....
*
         nsusy = 2
         ninit = 2
         ksusy(1) = index1
         ksusy(2) = index2
         ispart2(1) = 1
 7       ispart2(2) = 2
      end if
*
* If there aren't any undecayed SUSY ptcles then pack up and go home
*
      if (nsusy.eq.0) goto 97
*
* TRY decaying the products in a nice loop....
*
      do i=1,nsusy
*
         nc1 = ispart2(i)
         lindex1 = ksusy(i)

 20      continue

         call decabr(lindex1,nbod,lindex,adeca)

         if(nbod.ne.1)then

            if(nbod.eq.3)then
               CALL smbod3(PV(1,nc1),lindex1,PV(1,nflav+1),PV(1,nflav+2)
     &              ,PV(1,nflav+3),lindex,adeca,kfail)
               if(kfail.eq.1)return
               IF (frad.eq.1)
     +              CALL finrad_new(3,PV(1,nc1),lindex1,nc1,PV(1,nflav+1
     +              ),lindex(1),PV(1,nflav+2),lindex(2),PV(1,nflav+3)
     +              ,lindex(3))
            endif

            if(nbod.eq.2)then
               CALL smbod2(PV(1,nc1),lindex1,PV(1,nflav+1),PV(1,nflav+2)
     &              ,lindex,kfail)
               if(kfail.eq.1)return
               IF (frad.eq.1)
     +              CALL finrad_new(2,PV(1,nc1),lindex1,nc1,PV(1,nflav+1
     +              ),lindex(1),PV(1,nflav+2),lindex(2),dummyar,0)
            endif
*
* Sort out IFLAV array
*
            do 30 j=1,nbod
               lblin=ssid(LINDEX(j))
               IFLAV(nflav+j,1)=lindex(j)
               IFLAV(nflav+j,2)=nc1
 30         continue
*
* Increment particle count and properly specify next
* particle to decay.
*
            nflav=nflav+nbod
            nc1=nflav
            lindex1=lindex(nbod)
*
* Cascade the decays...
*
            go to 20
         endif
      end do
*
* And hadronise everything as required
*
      call sfrag_main(ifail)
*
*     now reset the colour coherence effect switch to the
*     default (gets modified in squark_frag)
      MSTJ(50)=3
*
 97   continue
*
      END
      SUBROUTINE SFRAG_INIT(IFLAG)
C=========================================================
C   Modified from SFRAGMENT by M.Williams  Dec 96
C   SFRAGMENT authors  :- Y. Gao, P. Morawitz  30-JAN-1996
C
C   Stores beam particles, ISR photons and the SusyProd
C=========================================================
C
      real*8  flum,ecm,s,roots,T,Q,Q2,EN
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)

      COMMON/LUJETS/N,K(4000,5),P(4000,5),V(4000,5)

      Real*8   PV
      Integer  IFLAV,NFLAV
CPM      COMMON /PARTC / PV(5,20),IFLAV(20,2),NFLAV
CPM      update to SUSYGEN V1.5
      COMMON /PARTC / pv(5,30)
      COMMON /PARTC1 / iflav(30,2),nflav

      integer i_sq_had
      common /sqhdcom/ i_sq_had
      integer ispart,ksusy,ispart2,nsusy,ninit,nprod
      common /fcomm/ nsusy,ninit,nprod,ispart(100),ispart2(100)
     &     ,ksusy(100)
      INTEGER      NP,KP(10),NG,KG(10)
      REAL*8       PP(5),PG(5)
      COMMON /FRAGCOM/PP,PG,NP,KP,NG,KG

      Integer       IPRI,IHST
      Real          ECMS,SVERT
      Integer       mact
      Parameter    (mact=100)
      Integer       nact,iact
      Real          sact,wact
      common/SUWGHT/IPRI,ECMS,SVERT(3)
     &             ,nact,iact(mact)
     &                  ,sact(mact)
     &                  ,wact(mact)



      INTEGER sprodind,quarkind
      integer ijoin(3),skip
*
      IFLAG=0
C*
C*    initial particles and ISR gammas only
C*    ====================================
      N=0
      if(NFLAV.EQ.0) then
       write (*,*) ' SFRAGMENT info nflav returns',nflav
         RETURN
      endif

      NP=0
      NG=0
      DO I=1,5
        PG(I)=0.0D0
        PP(I)=0.0D0
      ENDDO
*
* As now set up nflav should be 2 or 3
* ie. 2 initial ptcles (+ 1 ISR gamma)
*
      DO 10 I=1,NFLAV
        IF( IFLAV(I,1).EQ.0 ) GOTO 10        ! empty line
        IF( IFLAV(I,2).NE.0 ) GOTO 10        ! not the original
        IF( IFLAV(I,1).EQ.22) THEN           ! ISR photon
           NG=NG+1
           PG(1)=PG(1)+PV(1,I)
           PG(2)=PG(2)+PV(2,I)
           PG(3)=PG(3)+PV(3,I)
           PG(4)=PG(4)+PV(4,I)
           KG(NG)=I
        ELSE                                 ! other originals
           NP=NP+1
           PP(1)=PP(1)+PV(1,I)
           PP(2)=PP(2)+PV(2,I)
           PP(3)=PP(3)+PV(3,I)
           PP(4)=PP(4)+PV(4,I)
           KP(NP)=I
        ENDIF
10    CONTINUE

      PP(5)=PP(4)**2-PP(1)**2-PP(2)**2-PP(3)**2
      PP(5)=DSIGN(1.0D0,PP(5))*DSQRT(DABS(PP(5)))
      PG(5)=PG(4)**2-PG(1)**2-PG(2)**2-PG(3)**2
      PG(5)=DSIGN(1.0D0,PG(5))*DSQRT(DABS(PG(5)))
C*
C*    save beam particles in the first two lines (ALEPH e- ->+z)
C*    ==========================================================
      K(N+1,1)= 21
      K(N+1,2)= 11
      K(N+1,3)=  0
      K(N+1,4)=  0
      K(N+1,5)=  0
      P(N+1,1)=  0.0
      P(N+1,2)=  0.0
      P(N+1,3)=  ECM/2.0D0
      P(N+1,4)=  ECM/2.0D0
      P(N+1,5)=  0.0
      V(N+1,1)=  0.0
      V(N+1,2)=  0.0
      V(N+1,3)=  0.0
      V(N+1,4)=  0.0
      V(N+1,5)=  0.0

      K(N+2,1)= 21
      K(N+2,2)=-11
      K(N+2,3)=  0
      K(N+2,4)=  0
      K(N+2,5)=  0
      P(N+2,1)=  0.0
      P(N+2,2)=  0.0
      P(N+2,3)= -ECM/2.0D0
      P(N+2,4)=  ECM/2.0D0
      P(N+2,5)=  0.0
      V(N+2,1)=  0.0
      V(N+2,2)=  0.0
      V(N+2,3)=  0.0
      V(N+2,4)=  0.0
      V(N+2,5)=  0.0

      N=N+2
C*
C*    ISR GAMMAS
C*    ==========
      DO 20 I=1,NG
        N      =  N+1
        K(N,1) =  1
        K(N,2) = 22
        K(N,3) =  0
        K(N,4) =  0
        K(N,5) =  0
        P(N,1) =  PV(1,KG(I))
        P(N,2) =  PV(2,KG(I))
        P(N,3) =  PV(3,KG(I))
        P(N,4) =  PV(4,KG(I))
        P(N,5) =  PV(5,KG(I))
        V(N,1) =  0.0
        V(N,2) =  0.0
        V(N,3) =  0.0
        V(N,4) =  0.0
        V(N,5) =  0.0
20    CONTINUE
C*
C*    mediate state: SUSY st
C*    ======================
      N      =  N+1
      K(N,1) = 11
      K(N,2) = 79
      K(N,3) =  0
      K(N,4) =  N+1
      K(N,5) =  N+NP
      P(N,1) =  PP(1)
      P(N,2) =  PP(2)
      P(N,3) =  PP(3)
      P(N,4) =  PP(4)
      P(N,5) =  PP(5)
      V(N,1) =  0.0
      V(N,2) =  0.0
      V(N,3) =  0.0
      V(N,4) =  0.0
      V(N,5) =  0.0
*
      END

      SUBROUTINE SFRAG_MAIN(IFLAG)
C=====================================================
C   Authors   :- Y. Gao, P.Morawitz        30-JAN-1996
C   Modified by M.Williams             Dec 96 - Mar 97
C
C   The main interface with JETSET
C=====================================================
      integer iflag

      real P,V
      INTEGER N,K
      COMMON/LUJETS/N,K(4000,5),P(4000,5),V(4000,5)

      DOUBLE PRECISION PV
      COMMON /PARTC / pv(5,30)
      INTEGER iflav,nflav,idbg,igener,irad
      COMMON /PARTC1 / iflav(30,2),nflav
      COMMON /CONST/ idbg,igener,irad
      integer jev
      common/kev/jev

      integer frad
      common /fsr/ frad

      integer ifsrph
      real*8  pfsrphot
      integer imothfsr

      common /FPHOTONS/ pfsrphot(5,100),imothfsr(100),ifsrph
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------


      INTEGER I

      INTEGER      NP,KP(10),NG,KG(10)
      REAL*8       PP(5),PG(5)
      COMMON /FRAGCOM/PP,PG,NP,KP,NG,KG

      INTEGER      NMOT,IMOT(100,2)
      REAL*4       QMX

      real*8  flum,ecm,s,roots,T,Q,Q2,EN
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)

      INTEGER sprodind,quarkind
      integer ijoin(3),skip

      integer listshowerind(10,2),nshowers,ishowers
      real    listqmx(10)
      common/lushowers/listqmx
      common/lushowers2/listshowerind,nshowers

      integer j,offset

      integer nm,jmot

      real Minv12,Minv13,Minv23
      integer diqu(3)
      real psav(3,5),vsav(3,5)
      integer ksav(3,5)
      integer j1,j2

      logical first
      data first /.true./

      logical asquark
      external asquark

      integer iq1,iq2,iq3,iq4,decprod1,decprod2
      integer searchq
*
      integer ispart,ksusy,ispart2
      common /fcomm/ nsusy,ninit,nprod,ispart(100),ispart2(100)
     &     ,ksusy(100)
*
      Integer       IPRI,IHST
      Real          ECMS,SVERT
      Integer       mact
      Parameter    (mact=100)
      Integer       nact,iact
      Real          sact,wact
      common/SUWGHT/IPRI,ECMS,SVERT(3)
     &             ,nact,iact(mact)
     &                  ,sact(mact)
     &                  ,wact(mact)
*
      integer k_lop

      integer kkk,kkkk
      data kkk /0/


      if (IPRI.gt.0) then
         do i=1,ifsrph
            write (*,*) ' FSR photons ->',imothfsr(i),pfsrphot(1,i)
     +           ,pfsrphot(2,i),pfsrphot(3,i),pfsrphot(4,i),pfsrphot(5,i
     +           )
         enddo
      endif

      nshowers = 0
      NM=N
      IFLAG = 0
C*
C*    pre-treatment, careful on the particle-antiparticle relationship
C*    ================================================================
      DO I=1,NFLAV
        IF( IFLAV(I,1).EQ.-71 ) IFLAV(I,1)=71
        IF( IFLAV(I,1).EQ.-72 ) IFLAV(I,1)=72
        IF( IFLAV(I,1).EQ.-73 ) IFLAV(I,1)=73
        IF( IFLAV(I,1).EQ.-74 ) IFLAV(I,1)=74
        IF( IFLAV(I,1).EQ.-75 ) IFLAV(I,1)=77
        IF( IFLAV(I,1).EQ.-76 ) IFLAV(I,1)=78
        IF( IFLAV(I,1).EQ.-22 ) IFLAV(I,1)=22
        IF( IFLAV(I,1).EQ.-25 ) IFLAV(I,1)=25

      ENDDO
C*
C*    Store original particles
C*    ========================
      NMOT=0
      DO 30 I=1,ninit
        N      =  N+1
        K(N,1) =  1
        K(N,2) =  IFLAV(KP(I),1)
        K(N,3) =  NM
        K(N,4) =  0
        K(N,5) =  0
        P(N,1) =  PV(1,KP(I))
        P(N,2) =  PV(2,KP(I))
        P(N,3) =  PV(3,KP(I))
        P(N,4) =  PV(4,KP(I))
        P(N,5) =  PV(5,KP(I))
        V(N,1) =  0.0
        V(N,2) =  0.0
        V(N,3) =  0.0
        V(N,4) =  0.0
        V(N,5) =  0.0

        NMOT        =NMOT+1
        IMOT(NMOT,1)=KP(I)
        IMOT(NMOT,2)=N
30    CONTINUE
*
* And sort out imot information for other SUSY ptcles
*
      do i=1,nprod
         nmot = nmot + 1
         imot(nmot,1) = i + np + ng
         imot(nmot,2) = ispart(i+ninit)
      end do
C*
C*    Other particles, by order
C*    =========================
      JMOT=0
41    JMOT=JMOT+1
      IF(JMOT.GT.NMOT) GOTO 40

      DO 42 I=1,NFLAV
         IF( IFLAV(I,2).NE.IMOT(JMOT,1) ) GOTO 42

         N      =  N+1
         K(N,1) =  1
         K(N,2) =  IFLAV(I,1)
         K(N,3) =  IMOT(JMOT,2)
         K(N,4) =  0
         K(N,5) =  0
         P(N,1) =  PV(1,I)
         P(N,2) =  PV(2,I)
         P(N,3) =  PV(3,I)
         P(N,4) =  PV(4,I)
         P(N,5) =  PV(5,I)
         V(N,1) =  0.0
         V(N,2) =  0.0
         V(N,3) =  0.0
         V(N,4) =  0.0
         V(N,5) =  0.0

         IF( K(IMOT(JMOT,2),4).EQ.0 ) THEN
            K(IMOT(JMOT,2),1)=11
            K(IMOT(JMOT,2),4)= N
            K(IMOT(JMOT,2),5)= N
         ELSE
            K(IMOT(JMOT,2),5)=K(IMOT(JMOT,2),5)+1
         ENDIF

         NMOT         = NMOT+1
         IMOT(NMOT,1) = I
         IMOT(NMOT,2) = N
42    CONTINUE


C     ... see if the sparticle in question has emitted a FSR photon down
c     the event tree.
      DO k_lop=1,ifsrph
         IF (IMOT(JMOT,1).EQ.IMOTHFSR(k_lop)) THEN
C     ... add this FSR photon
         N      =  N+1
         K(N,1) =  1
         K(N,2) =  22
         K(N,3) =  IMOT(JMOT,2)
         K(N,4) =  0
         K(N,5) =  0
         P(N,1) =  PFSRPHOT(1,k_lop)
         P(N,2) =  PFSRPHOT(2,k_lop)
         P(N,3) =  PFSRPHOT(3,k_lop)
         P(N,4) =  PFSRPHOT(4,k_lop)
         P(N,5) =  PFSRPHOT(5,k_lop)
         V(N,1) =  0.0
         V(N,2) =  0.0
         V(N,3) =  0.0
         V(N,4) =  0.0
         V(N,5) =  0.0

         IF( K(IMOT(JMOT,2),4).EQ.0 ) THEN
            K(IMOT(JMOT,2),1)=11
            K(IMOT(JMOT,2),4)= N
            K(IMOT(JMOT,2),5)= N
         ELSE
            K(IMOT(JMOT,2),5)=K(IMOT(JMOT,2),5)+1
         ENDIF
         ENDIF
      ENDDO

      GOTO 41
40    CONTINUE
C     --- now loop over particles to determine their correct vertices
      DO I=1,N
         IF (K(I,3).ne.0) then
            DO J=1,4
               V(I,J) =  V(I,J)+V(K(I,3),J)
            ENDDO
         ENDIF
      ENDDO


C     --- bodge for mixed direct chargino decays
      IF (RBOD3) THEN
      kkk=kkk+1
      if (kkk.gt.3) kkk=1
C     1=emu 2=mutau 3=taue
C
      kkkk=kkk+1
      if (kkkk.gt.3) kkkk=1

      DO  I=1,N
         IF( ABS(K(I,2)).eq.75 ) then
            K(I+4,2)=-11-(kkk-1)*2
            P(I+4,5) =  ssmass(ABS(K(I+4,2)))
            P(I+4,4) = SQRT(P(I+4,3)**2+P(I+4,2)**2+P(I+4,1)**2+P(I+4,5)
     +           **2)
         ELSEIF (ABS(K(I,2)).eq.77) then
            K(I+6,2)=11+(kkkk-1)*2
            P(I+6,5) =  ssmass(ABS(K(I+6,2)))
            P(I+6,4) = SQRT(P(I+6,3)**2+P(I+6,2)**2+P(I+6,1)**2+P(I+6,5)
     +           **2)
         ENDIF
      ENDDO
      ENDIF


C     --- bodge for mixed direct slepton decays
      IF (RBOD3) THEN
C      kkk=kkk+1
C      if (kkk.gt.3) kkk=1
C     1=emu 2=mutau 3=taue
C
C      kkkk=kkk+1
C      if (kkkk.gt.3) kkkk=1

      DO  I=1,N
         IF((((((((K(I,2)).eq.57).or.((K(I,2)).eq.51)).or.((K(I
     +        ,2)).eq.53)).or.((K(I,2)).eq.55)).or.((K(I,2)).eq.58
     +        )).or.((K(I,2)).eq.59))) then
            K(I+2,2)=11+(kkk-1)*2
            P(I+2,5) =  ssmass(ABS(K(I+2,2)))
            P(I+2,4) = SQRT(P(I+2,3)**2+P(I+2,2)**2+P(I+2,1)**2+P(I+2,5)
     +           **2)
         ELSEIF((((((((K(I,2)).eq.-57).or.((K(I,2)).eq.-51)).or.((K(I
     +           ,2)).eq.-53)).or.((K(I,2)).eq.-55)).or.((K(I,2)).eq.-58
     +           )).or.((K(I,2)).eq.-59))) then
            write (*,*) ' i = ',i,k(I+3,2),K(I+4,2)
            K(I+3,2)=-11-(kkkk-1)*2
            write (*,*) ' i = ',i,k(I+3,2),K(I+4,2)
            P(I+3,5) =  ssmass(ABS(K(I+3,2)))
            P(I+3,4) = SQRT(P(I+3,3)**2+P(I+3,2)**2+P(I+3,1)**2+P(I+3,5)
     +           **2)
         ENDIF
      ENDDO
      ENDIF

C*
C*    check the colour string
C*    =======================
C
C ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C ... find the (decayed) pairproduced squarks
C ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      DO sprodind=1,N
         if (K(sprodind,2).eq.79) goto 33
      ENDDO
      STOP 'SFRAGMENT: No SusyProd0 found - fatal'
 33   CONTINUE

      IF (ASQUARK(K(sprodind+1,2))) THEN
C     ...what's it decayed into
         IF (K(sprodind+1,1).eq.11) THEN
            CALL squdecay(sprodind+1,decprod1,iq1,iq2)
            CALL squdecay(sprodind+2,decprod2,iq3,iq4)
            IF ((decprod1.eq.1).and.(decprod2.eq.1)) THEN
               CALL CONNECT2(iq1,iq3)
            ELSEIF ((decprod1.eq.2).and.(decprod2.eq.1)) THEN
               CALL CONNECT3(iq3,iq1,iq2)
            ELSEIF ((decprod1.eq.1).and.(decprod2.eq.2)) THEN
               CALL CONNECT3(iq1,iq3,iq4)
            ELSEIF ((decprod1.eq.2).and.(decprod2.eq.2)) THEN
               CALL CONNECT2(iq1,iq2)
               CALL CONNECT2(iq3,iq4)
            ELSE
               STOP 'SFRAGMENT: squark does not decay to quark ???'
            ENDIF
         END IF
      ENDIF


C ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C ... find the other (decayed) squarks
C ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      ioffset = 3
c     ... careful with hadronised squarks
      if (K(sprodind+1,1).eq.13) ioffset = 5
c
      DO I=sprodind+ioffset,N
         IF ((ABS(K(I,1)).eq.11).and.(ASQUARK(K(I,2)))) then
C     ...   was it a gaugino -> q squark decay?
            q1=0
            DO searchq=N,sprodind+ioffset,-1
               IF (ABS(K(searchq,1)).eq.1) then
                  IF ((ABS(K(searchq,2)).le.10).AND.
     +                (K(searchq,3).EQ.K(I,3))) THEN
                    q1=searchq
                    GOTO 71
                  ENDIF
               ENDIF
            ENDDO

            STOP 'SFRAGMENT: ghost squark ???'

 71         CONTINUE

C     ....  get the decay products from the squark
            CALL squdecay(I,decprod1,iq2,iq3)
            IF (decprod1.eq.1) THEN
               CALL CONNECT2(iq1,iq2)
            ELSEIF (decprod1.eq.2) THEN
               CALL CONNECT3(iq1,iq2,iq3)
            ELSE
               STOP 'SFRAGMENT: squark does not decay to quark ???'
            ENDIF

         ENDIF
      ENDDO

 72   CONTINUE

C ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C ... and connect q q' or q q' q'' type events
C ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      DO I=sprodind+ioffset,N-1
C     ...
         IF (ABS(K(I,1)).eq.1.and.ABS(K(I,2)).LE.10) THEN
            CALL Findqurk(I,decprod1,iq1,iq2)
            IF (decprod1.eq.1) CALL CONNECT2(I,iq1)
            IF (decprod1.eq.2) CALL CONNECT3(I,iq1,iq2)
         ENDIF
      ENDDO

      DO I=1,N
         IF (K(I,1).eq.77) K(I,1)=1
      ENDDO


C      now the final state part ...
C      must be done before LUEXEC, otherwise PHOTOS gets
c     confused
C     and final state radiation
      IF (IPRI.gt.10) write (*,*)
     +     ' after colour assignments, before showering'
      IF (IPRI.gt.10)        CALL LULIST(3)

      DO ishowers=1,nshowers
         CALL LUSHOW(listshowerind(ishowers,1),
     +            listshowerind(ishowers,2),listqmx(ishowers))
      ENDDO
C*
C*    Finally, LUEXEC
C*    ===============
      IF (IPRI.ge.10) CALL LULIST(2)
      CALL LUEXEC

C     and clean up event
      DO I=1,N
 66      if         (((((((((((((((P(I,1).eq.0.).and.(P(I,2).eq.0.)).and
     +        .(P(I,3).eq.0.)).and.(P(I,4).eq.0.)).and.(P(I,5).eq.0.))
     +        .and.(V(I,1).eq.0.)).and.(V(I,2).eq.0.)).and.(V(I,3).eq.0.
     +        )).and.(V(I,4).eq.0.)).and.(V(I,5).eq.0.)).and.(K(I,1)
     +        .eq.0)).and.(K(I,2).eq.0)).and.(K(I,3).eq.0)).and.(K(I,4)
     +        .eq.0)).and.(K(I,5).eq.0)) then
            call ludelete(I)
            goto 66
         endif
      ENDDO

C     and delete the diquark systems, which KINGAL can't cope with
      DO I=1,N
 67      if         (((((P(I,1).eq.0.).and.(P(I,2).eq.0.)).and
     +        .(P(I,3).eq.0.)).and.(P(I,4).eq.0.)).and.(P(I,5).eq.0.))
     +         then
            call ludelete(I)
            goto 67
         endif
      ENDDO

      IF (IPRI.ge.1)       CALL LULIST(3)
*
      END

      SUBROUTINE SQUARK_FRAG(IFLAG)
C================================================================
C Author:- M.Williams   Dec 96 - Mar 97
C
C Hadronises pair-produced squarks and decays them inside JETSET
C Because JETSET only has one extra quark generation and SUSYGEN
C is capable of generating many different squark types the
C JETSET parameters must be set up for each event.
C Only one additional decay channel can be defined inside JETSET
C so the decays of the squark and squark~ are performed one by one
C according to the branching ratios of unhadronised squarks.
C================================================================
      INTEGER    L1MST,L1PAR
     &          ,L2PAR,L2PARF
     &          ,LJNPAR
      PARAMETER (L1MST=200, L1PAR=200)
      PARAMETER (L2PAR=500, L2PARF=2000)
      PARAMETER (LJNPAR=4000)
      COMMON /LUDAT1/ MSTU(L1MST),PARU(L1PAR),MSTJ(L1MST),PARJ(L1PAR)
      INTEGER         MSTU,MSTJ
      REAL            PARU,PARJ
      COMMON /LUDAT2/ KCHG(L2PAR,3),PMAS(L2PAR,4),PARF(L2PARF),VCKM(4,4)
      INTEGER         KCHG
      REAL            PMAS,PARF,VCKM
      COMMON /LUDAT3/ MDCY(L2PAR,3),MDME(L2PARF,2),BRAT(L2PARF),
     &                KFDP(L2PARF,5)
      INTEGER         MDCY,MDME,KFDP
      REAL            BRAT
      COMMON /LUDAT4/ CHAF(L2PAR)
      CHARACTER*8     CHAF
      COMMON /LUJETS/ N7LU,K7LU(LJNPAR,5),P7LU(LJNPAR,5),V7LU(LJNPAR,5)
      INTEGER         N7LU,K7LU
      REAL            P7LU,V7LU
*
*
********************* start of commons of SUSYGEN **********************
      integer ievent
      common /eve/ ievent
      real*4  rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan(6)
      common /rkey/rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan

      real*8  gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu
      common/steer/gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu

      Integer modes,MIX
      common/mds/modes,MIX
      logical zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,higgs
      common/sparc/ zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,
     + higgs
      logical wrt,scan,lepi
      common/str/wrt,scan,lepi
      real*8  flum,ecm,s,roots,T,Q,Q2,EN
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
      real*8  QK
      COMMON/ISR/ QK(4)
      real erad,srad
      common/srada/erad(100),srad(100)
      integer  idbg,igener,irad
      COMMON /CONST/ idbg,igener,irad
      integer  index,index1,index2,nevt
      COMMON/INDEXX/index,index1,index2,nevt
      real*8   fmpr1,fmpr2,XCROST,APRO
      COMMON/FINDEX/fmpr1,fmpr2,XCROST,APRO
      real*8   cosphimix,facqcd,fgama,spartmas,ratq
      common/mixings/cosphimix,facqcd,fgama,spartmas,ratq
      real*8   FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +         FLC,FRC,gms,echar
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
      real*8      TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      real*8   fmal,fmar,ratqa,fgamc,fgamcr,cosmi
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)

      real*4 gmas,phimx
      common/stopmix/gmas(3),phimx(3)
      real*4 phimix1,stop1,phimix2,sbot1,phimix3,stau1
      equivalence (gmas(1),stop1)
      equivalence (gmas(2),sbot1)
      equivalence (gmas(3),stau1)
      equivalence (phimx(1),phimix1)
      equivalence (phimx(2),phimix2)
      equivalence (phimx(3),phimix3)
      real*4 gmas2
      common/stopmix2/gmas2(3)
      real*4 stop2,sbot2,stau2
      equivalence (gmas2(1),stop2)
      equivalence (gmas2(2),sbot2)
      equivalence (gmas2(3),stau2)
      real*4 rscale
      common/sscale/rscale
      logical imsg                      !Added by S.A. for use in the
      common/imessage/imsg              !NTONPH routine

      double precision sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      common/higgses/sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      logical fix_higgs_masses
      common/ steerhiggs / fix_higgs_masses

      integer jdebu,idb1,idb2,lout
      common /debuc/ jdebu,idb1,idb2,lout

      real*8   xgaug,xeta
      COMMON/XCROS/xgaug(8),xeta(8)

      integer  ispa,kl,klap,idecs,klr
      common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
C 04/96 P.Morawitz & M.Williams introduce klr for Rpv gaugino decays
      common/reord2/klr(3,24)
c klr(1,n), klr(2,n) and klr(3,n) are the particles produced in
c R-parity violating decays of gauginos...
C n=1..4 , 5..8	 LLE neutralino,gaugino decays
C n=9..12,13..16 LQD neutralino,gaugino decays
C n=17.20,21..24 UDD neutralino,gaugino decays

      Integer  idecsel,ihigsel
      common/decsel/idecsel(23)
      common/higsel/ihigsel(5)
C 05/96 P.Morawitz
C ...   NOTE: the logical below is used in SUSYGEN V1.5 (April 96)
C       MSSM has its own implementation of R-parity violation.
C       The logical rpar is therefore always set to TRUE which avoids
C       the SUSYGEN R-parity code.
        logical rpar
        common/rpari/rpar
      real*8   brsum,brsuma
CPM      common/brsum/ brsum(5,6,6),brsuma(6)
C 04/96 P.Morawitz & M.Williams  changed brsum to allow for r-parity dec
      common/brsum/ brsum(13,7,6),brsuma(6)
************************************************************************
c EXPLANATION OF INDICES IN BRSUM(itype,igout,igin)
c
c igin  = 1,6 initial gaugino (neutralinos 1..4, charginos 1,2)
c igout = 1,7 outgoing gaugino
c ........where 7 => no outgoing gaugino ie. R-parity violating process
c itype = types of particles produced
c     1 - l+ l-    6 - l q qbar   10 - q q q'         12 - l+ l+ l-
c     2 - v vbar   7 - l q' qbar  11 - qbar qbar qbar 13 - l v v
c     3 - q qbar   8 - v q qbar
c     4 - l v      9 - v q' qbar
c     5 - q' qbar
************************************************************************
      real*8   fms,fmi,fmk,fml1,fml2,etai,etak,brspa
     +        ,brgaug,fmelt,fmert,fmelu,fmeru
      Integer  lind
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
CPM     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
     +lind(6,6,6),brgaug(6,7,11,3),fmelt,fmert,fmelu,fmeru
C 04/96 P.Morawitz & M.Williams  changed brgaug to allow for r-parity de

************************************************************************
c     EXPLANATIONS OF INDICES IN BRGAUG AND BRSPA
c
c BRSPA::
c kgaug =1,6 produced gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c kspar =1,24 initial sparticle
c     1,12  : left-handed sparticle  (u,d,v,e,c,s,v,mu,t,b,v,tau)
c     12,24 : right handed sparticle (u,d,v,e,c,s,v,mu,t,b,v,tau)
c
c BRGAUG::
c igin =1,6 parent gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c igout =1,7 daughter gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c     7    : none (ie. R-parity violating process)
c ipart =1,6 for produced particles .....
c     R-parity conserving decays
c     1,4  : uu,dd,vv,ee                                  - 'like to lik
c     5,6  : ud,ev                                        - 'like to unl
C ipart =7,11 for the 5 diagrams which involve
C             gaugino -> gaugino' gamma
C	      gaugino -> Higgs X
C
C
C ipart =1,8 for Rp-violating!!!! decays (igout=7)
c     R-parity violating decays via LLE operator
c     1,4 :                                               - for neutrali
c     5,8 : l+ l+ l, v v l+, vbar l+ v, l+ vbar v         - for chargino
c     R-parity violating decays via LQD operator
c     1,4  : e+ u dbar, e- ubar d, v d dbar, vbar dbar d  - for neutrali
c     5,8  : v u dbar, e+ dbar d, e+ ubar u, vbar dbar u  - for chargino
c     R-parity violating decays via UDD operator
c     1,4  :						  - for neutralinos
c     5,8  : u u d, u d u, dbar dbar dbar                 - for chargino
c igen =1,3
c     R-parity conserving decays : generation of produced particles
c     R-parity violating decays  : meaningless, i.e. only igen=1 used
************************************************************************
      Real*8   zr,was,esa
      Real*8   VOIJL,VOIJR,gfir,gfil
      COMMON/NEUMIX/ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
      real*8   OIJL,OIJR,V,U,FM,ETA
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      real*8   oijlp,oijrp
      COMMON/CHANEU/oijlp(4,2),oijrp(4,2)
      Integer       ILOOP
      COMMON/SFLOOP/ILOOP
      Real*8   PV
      Integer  IFLAV,NFLAV
CPM      COMMON /PARTC / PV(5,20),IFLAV(20,2),NFLAV
CPM      update to SUSYGEN V1.5
      COMMON /PARTC / pv(5,30)
      COMMON /PARTC1 / iflav(30,2),nflav


      real*8   gw,widfl,widfr,fmeltw,fmertw,fmeluw,fmeruw,gent,gentl
      integer  linda
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,7,6)
CPM     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
C 04/96 P.Morawitz & M.Williams  changed linda to allow for r-parity dec

      integer topo_charg,topo_neut
      common /topocom/ topo_charg,topo_neut

********************* end  of commons of SUSYGEN ***********************

C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------

      integer i_sq_had
      common /sqhdcom/ i_sq_had
      integer ispart,ksusy,ispart2,nsusy,ninit,nprod
      common /fcomm/ nsusy,ninit,nprod,ispart(100),ispart2(100)
     &     ,ksusy(100)
      INTEGER      NP,KP(10),NG,KG(10)
      REAL*8       PP(5),PG(5)
      COMMON /FRAGCOM/PP,PG,NP,KP,NG,KG
*
      integer isquark,imatch(6),isqprod(2),itemp,idm,itype
      integer lindex(3),lindex1(2),iprod(2,2)
      INTEGER sprodind,quarkind
      integer ijoin(2),skip
      real sqmass,branch,w
      double precision adeca
      data imatch/2,1,6,5,10,9/
*
*
      Integer       IPRI,IHST
      Real          ECMS,SVERT
      Integer       mact
      Parameter    (mact=100)
      Integer       nact,iact
      Real          sact,wact
      common/SUWGHT/IPRI,ECMS,SVERT(3)
     &             ,nact,iact(mact)
     &                  ,sact(mact)
     &                  ,wact(mact)


        LOGICAL Rparity
        COMMON/RpaSwi/ Rparity

      INTEGER      NMOT,IMOT(100,2)
      REAL*4       QMX

* Some basic setup stuff
*
*   switch off colour coherence effects according to T.Sjoerstrand
      MSTJ(50) = 0
*
* In case we have a cascade decay to a chargino set the antiparticle
* flag for JETSET.... Avoids problems with charge conservation.
*
      do I = 75,78
         KCHG(I,3) = 1
      end do
*
* Make sure we have the right squark mass
*
      isquark = index1
      if (isquark.gt.60) isquark=isquark-10
      isquark = isquark-40
      if (isquark.le.6) then
         ihand = 1
         sqmass = fmal(imatch(isquark))
      else if (isquark.le.12) then
         ihand = 2
         isquark = isquark-6
         sqmass = fmar(imatch(isquark))
      else
         write(*,*)
     &        'FATAL: YOU ARE TRYING TO USE THE WRONG SQUARK TYPE'
         stop
      end if
*
* Delete fourth generation quark decays via W and Higgs bosons
*
      call delsquad
*
      if (IPRI.ge.20) then
         write(*,*) 'FULL DECAY LISTING AFTER SWITCHING DECAYS OFF'
         call lulist(12)
      end if
*
* The squarks are introduced as the 4th generation quark
* Set the unproduced squarks mass high... just for JETSET
* itype=1 for d-type, 2 for u-type
*
      igen = ((isquark+1)/2)
      itype = isquark - 2*(igen-1)
      iquark = itype + 6
      if (itype.eq.1) then
         PMAS(8,1) = 500.
         PMAS(7,1) = sqmass
      else
         PMAS(8,1) = sqmass
         PMAS(7,1) = 500.
      end if
*
* Modify Peterson's fragm. functions params for these quarks (scale like
*
      PARJ(58) = PARJ(55)*(PMAS(5,1)/PMAS(8,1))**2
      PARJ(57) = PARJ(55)*(PMAS(5,1)/PMAS(7,1))**2
*
* Right, we want to put the squarks in the event record as
* fourth generation quarks for handling by JETSET.
*
      NM = N7LU
      NMOT=0
      DO 30 I=1,2
*
* Get charge of squark correct....
*
         if (i.eq.2) iquark = (-1) * iquark
*
* Put all the relevant info. into the event record
*
         N7LU      =  N7LU+1
         K7LU(N7LU,1) =  1
         K7LU(N7LU,2) =  iquark
         K7LU(N7LU,3) =  NM
         K7LU(N7LU,4) =  0
         K7LU(N7LU,5) =  0
         P7LU(N7LU,1) =  PV(1,KP(I))
         P7LU(N7LU,2) =  PV(2,KP(I))
         P7LU(N7LU,3) =  PV(3,KP(I))
         P7LU(N7LU,4) =  PV(4,KP(I))
         P7LU(N7LU,5) =  PV(5,KP(I))
         V7LU(N7LU,1) =  0.0
         V7LU(N7LU,2) =  0.0
         V7LU(N7LU,3) =  0.0
         V7LU(N7LU,4) =  0.0
         V7LU(N7LU,5) =  0.0
         NMOT        =NMOT+1
         IMOT(NMOT,1)=KP(I)
         IMOT(NMOT,2)=N7LU
*
30    CONTINUE
*
* Join the squarks with a string and hadronise
* They should not yet decay
*
      ijoin(1) = N7LU - 1
      ijoin(2) = N7LU
      call lujoin(2,ijoin)
*
      if (IPRI.ge.10) then
         write(*,*) '*********BEFORE HADRONISATION'
         CALL LULIST(1)
      end if
*
      call luexec
*
      if (IPRI.ge.10) then
         write(*,*) '*********AFTER HADRONISATION BUT BEFORE DECAY'
         CALL LULIST(1)
      end if
*
* Randomly pick decays according to branching fraction
* Always get decays of the particle not the anti-particle
* otherwise JETSET will get confused.
*
      do i=1,2
         call decabr(index1,nbod,lindex,adeca)
         iprod(i,1) = lindex(1)
         iprod(i,2) = lindex(2)
      end do
*
* Ensure proper treatment of neutralinos
*
      do i=1,2
         do j=1,2
            if (iprod(i,j).le.-71.and.iprod(i,j).ge.-74)
     .           iprod(i,j) = abs(iprod(i,j))
         end do
      end do
*
* Check that the decay products are sensible and properly ordered
*
      do i=1,2
         if ((abs(iprod(i,1)).lt.10.and.abs(iprod(i,2)).lt.10) .or.
     .        (abs(iprod(i,1)).ge.10.and.abs(iprod(i,2)).ge.10)) then
            write(*,*) 'FATAL: CANNOT HANDLE THESE DECAY PRODUCTS'
            stop
         else if (abs(iprod(i,1)).ge.10.and.abs(iprod(i,2)).lt.10) then
            itemp = iprod(i,1)
            iprod(i,1) = iprod(i,2)
            iprod(i,2) = itemp
         end if
      end do
*
* DO THE SQUARK HADRON DECAYS... ONE BY ONE
*
      do ipart=1,2
         isqprod(1) = iprod(ipart,1)
         isqprod(2) = iprod(ipart,2)
         call addsqdec(isqprod,itype,ipart+1)
         call luexec
         if (IPRI.ge.20) then
            write(*,*) '******DECAY TABLE FOR DECAY',ipart
            call lulist(12)
         end if
         if (IPRI.ge.10) call lulist(1)
      end do
*
* For decays to a chargino we need to fix the chargino charge
*
      do I=1,N7LU
         if (K7LU(I,2).eq.-75.or.K7LU(I,2).eq.-76) K7LU(I,2) =
     +        abs(K7LU(I,2)) + 2
         if (K7LU(I,2).eq.-77.or.K7LU(I,2).eq.-78) K7LU(I,2) =
     +        abs(K7LU(I,2)) - 2
      end do
*
      if (IPRI.ge.10) then
         write(*,*) 'AFTER SQUARK FRAGMENTATION:'
         call lulist(1)
      end if
*
* Replace fourth generation quarks with the original produced particles
*
      DO I=1,N7LU
         if (abs(K7LU(I,2)).eq.8.or.abs(K7LU(I,2)).eq.7) then
            tsign = K7LU(I,2) / abs(K7LU(I,2))
            K7LU(I,2) = tsign * abs(index1)
         end if
      ENDDO
*
* Remove fourth generation mesons and baryons
*
      DO I=1,N7LU
         ibary = (abs(K7LU(I,2))/1000) - (abs(K7LU(I,2))/10000)*10
         if  (ibary.eq.8.or.ibary.eq.7) then
            K7LU(I,1) = 0
         end if
         imeson = (abs(K7LU(I,2))/100) - (abs(K7LU(I,2))/10000)*100
         if  (imeson.eq.8.or.imeson.eq.7) then
            K7LU(I,1) = 0
         end if
      ENDDO
      call LUEDIT(12)
*
      if (IPRI.ge.10) then
         write(*,*) 'REMOVING THE FOURTH GENERATION'
         CALL LULIST(1)
      end if
*
* Restore chargino anti-particle flag and 4th gen. quark masses
*
      do I = 75,78
         KCHG(I,3) = 0
      end do
      PMAS(7,1) = 500.
      PMAS(8,1) = 500.
*
* Find all SUSY particles in the LUND common
* that have not been decayed...
*
      do i=1,N7LU
         ikf = K7LU(i,2)
         istat = K7LU(i,1)
         if (ikf.ge.41.and.ikf.le.78.and.istat.le.10) then
            nsusy = nsusy + 1
            ispart(nsusy) = i
            ksusy(nsusy) = ikf
            if (ksusy(nsusy).eq.77) ksusy(nsusy) = -75
            if (ksusy(nsusy).eq.78) ksusy(nsusy) = -76
         end if
      end do
*
* Load all the necessary particles into PV and IFLAV arrays
*
      do i=1,nsusy
         kmoth = K7LU(ispart(i),3)
         if (kmoth.eq.0) then
            imoth = 0
         else
            imoth = K7LU(kmoth,2)
         end if
         if (imoth.eq.79) then
            stop 'WHY HAVE I FOUND AN INITIAL PTCLE?'
         else
            nprod = nprod + 1
            nflav = nflav + 1
            ispart2(i) = nflav
            do j=1,5
               PV(j,nflav) = P7LU(ispart(i),j)
            end do
            iflav(nflav,1) = K7LU(ispart(i),2)
            iflav(nflav,2) = 0
         end if
      end do
*
      END

      subroutine delsquad
C============================================================
C Implemented in SUSYGEN by M.Williams   Dec 96 - Mar 97
C Based on stop01 and further mods by L.Duflot,F.Cerutti,etc.
C
C Switches off all decays via W or Higgs bosons
C============================================================
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
*
* h and l quarks
*
      MDCY(8,1) = 1
      if ( MDCY(8,3) .lt. 4 ) then
        print *,' something wrong in decay table of h !',MDCY(8,3)
        call lulist(12)
        stop
      endif
      do i = MDCY(8,2)+3,MDCY(8,2)+MDCY(8,3)-1
        MDME(i,1) = -1
      enddo
*
      MDCY(7,1) = 1
      if ( MDCY(7,3) .lt. 4 ) then
        print *,' something wrong in decay table of l !',MDCY(8,3)
        call lulist(12)
        stop
      endif
      do i = MDCY(7,2)+3,MDCY(7,2)+MDCY(7,3)-1
        MDME(i,1) = -1
      enddo
*
* h and l mesons and baryons
*
      MDCY(88,1) = 1
      if ( MDCY(88,3) .lt. 1 ) then
        print *,' something wrong in decay table of h baryons !'
        stop
      endif
      do i = MDCY(88,2),MDCY(88,2)+MDCY(88,3)-1
        MDME(i,1) = -1
      enddo
*
      MDCY(87,1) = 1
      if ( MDCY(87,3) .lt. 1 ) then
        print *,' something wrong in decay table of l baryons !'
        stop
      endif
      do i = MDCY(87,2),MDCY(87,2)+MDCY(87,3)-1
        MDME(i,1) = -1
      enddo
*
* Special case for hh and ll mesons
*
      do imes = 118 , 218 , 20
        MDCY(imes,1) = 1
        if ( MDCY(imes,3) .lt. 1 ) then
          print *,' something wrong in decay table of h h meson  !',imes
          stop
        endif
        do i = MDCY(imes,2),MDCY(imes,2)+MDCY(imes,3)-1
          MDME(i,1) = -1
        enddo
      enddo
*
      do imes = 117 , 217 , 20
        MDCY(imes,1) = 1
        if ( MDCY(imes,3) .lt. 1 ) then
          print *,' something wrong in decay table of l l meson  !',imes
          stop
        endif
        do i = MDCY(imes,2),MDCY(imes,2)+MDCY(imes,3)-1
          MDME(i,1) = -1
        enddo
      enddo
*
      end
      subroutine addsqdec(isqprod,itype,ipart)
C================================================================
C Implemented in SUSYGEN by M.Williams   Dec 96 - Mar 97
C Based on stop01 and further mods by L.Duflot,F.Cerutti,etc.
C
C Adds a squark decay channel
C
C Inputs: isqprod - 2D array containing decay products
C         itype   - =1 for d-type, =2 for u-type
C         ipart   - which particles do we want the decay on for?
C                   =1 for both particle and anti-particle
C                   =2 for particle only
C                   =3 for anti-particle only
C               NB: Particles which are their own anti-particle
C                   eg. h h mesons will decay if ipart=2
C================================================================
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
*
      integer isqprod(2),itype,ipart,isquark,ihadron,ispec1,ispec2
*
      isquark = itype + 6
      ihadron = itype + 86
      ispec1 = itype + 116
      ispec2 = itype + 216
*
* Add h or l decays
*
      index =  MDCY(isquark,2)+3
      MDME(index,1) = ipart
      MDME(index,2) = 33   ! phase space for the 2 first part
      KFDP(index,1) = isqprod(1)
      KFDP(index,2) = isqprod(2)
*
* Add h or l hadron decays
*
      index =  MDCY(ihadron,2)
      MDME(index,1) = ipart
      MDME(index,2) = 33
      KFDP(index,1) = isqprod(1)
      KFDP(index,2) = isqprod(2)
*
* Special case for h h or l l mesons
*
      do imes = ispec1 , ispec2 , 20
        index =  MDCY(imes,2)
        MDME(index,1) = ipart
        MDME(index,2) = 33   ! phase space for the 2 first part
        KFDP(index,1) = isqprod(1)
        KFDP(index,2) = -1 * isqprod(1)
        KFDP(index,3) = isqprod(2)
        if (isqprod(2).ge.71.and.isqprod(2).le.78) then
           KFDP(index,4) = isqprod(2)
        else
           KFDP(index,4) = -1 * isqprod(2)
        end if
      enddo
*
      end

C ------------------------------------------------------------
C             Rparity violation routines
C ------------------------------------------------------------

        Subroutine RPARBRANCH
        Implicit none
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------

      double precision Cf
        double precision CLQDFM1,CLQDFM2,CLQDFM3,CLQDFM4
      EXTERNAL CLQDFM1,CLQDFM2,CLQDFM3,CLQDFM4
      double precision integral
        External integral
      INTEGER i1,i2 , err
      LOGICAL CPROP_OK,NPROP_OK,  kine_ok
      EXTERNAL CPROP_OK,NPROP_OK, kine_ok
      INTEGER ii

C... neutralino LQD decays

        DO i1=1,4
           DO i2=1,4
              ngamma(i1,i2)=0.
           ENDDO
        ENDDO

        DO INEUT=1,4

          IF (.NOT.NPROP_OK()) THEN
           goto 998
C ...        Neutralino decay not allowed 'caus the
C           the exchanged sparticle is real, and thus the
C           neutralino would have decayed to it first ...
          ENDIF

C... two diagrams, but init has only to be done once
          CALL LSPCPL
          CALL PSPXMS

          IF (COUPL_I(1).EQ.2) then
C ... LQD
            Cf=3.
C   ...     e-type coupling
            fntype=121
            IF (kine_ok(1)) then
              ngamma(INEUT,1)=XMNEU(INEUT)/(256.*Dpi**3)
     +             *(Cf*8.*G**2*XLAM**2)*integral()
              ngamma(INEUT,2)=ngamma(INEUT,1)
          ENDIF

C ...       nu-type coupling
            fntype=122
            IF (kine_ok(1)) then
              ngamma(INEUT,3)=XMNEU(INEUT)/(256.*Dpi**3)
     +             *(Cf*8.*G**2*XLAM**2)*integral()
            ngamma(INEUT,4)=ngamma(INEUT,3)
          ENDIF
          ELSEIF (COUPL_I(1).EQ.1) then
C ... LLE
            Cf=1.
C   ...     e-type coupling
            fntype=111
            IF (kine_ok(1)) then
              ngamma(INEUT,1)=XMNEU(INEUT)/(256.*Dpi**3)
     +             *(Cf*8.*G**2*XLAM**2)*integral()
              ngamma(INEUT,2)=ngamma(INEUT,1)
            ENDIF

C ...       nu-type coupling
            fntype=112
            IF (kine_ok(1)) then
              ngamma(INEUT,3)=XMNEU(INEUT)/(256.*Dpi**3)
     +             *(Cf*8.*G**2*XLAM**2)*integral()
              ngamma(INEUT,4)=ngamma(INEUT,3)
            ENDIF
          ELSEIF (COUPL_I(1).EQ.3) then
C ... UDD
            Cf=6.
C   ...     e-type coupling
            fntype=131
            IF (kine_ok(1)) then
              ngamma(INEUT,1)=XMNEU(INEUT)/(256.*Dpi**3)
     +             *(Cf*8.*G**2*XLAM**2)*integral()
              ngamma(INEUT,2)=ngamma(INEUT,1)
            ENDIF

C ...       nu-type coupling
            ngamma(INEUT,3)=0.
            ngamma(INEUT,4)=0.

          ELSE
            stop ' fatal in rparbranch'
          ENDIF

 998      ngamma_tot(INEUT)=ngamma(INEUT,1)+ngamma(INEUT,2)+
     +                      ngamma(INEUT,3)+ngamma(INEUT,4)

        ENDDO

C... chargino R-parity decays
      DO i1=1,2
        cgamma_tot(I1)=0.
        DO i2=1,4
          cgamma(i1,i2)=0.
        ENDDO
      ENDDO

      DO ICHAR=1,2

       IF (.NOT.CPROP_OK()) THEN
        goto 999
C ...     Chargino decay not allowed 'caus the
C        the exchanged sparticle is real, and thus the
C        chargino would have decayed to it first ...
       ENDIF

       IF (COUPL_I(1).EQ.2) then
C ...    four LQD diagrams for EACH chargino
        Cf=3.

        CALL CLSPCPL(1)
        CALL CPSPXMS(1)
        fntype=221
        IF (kine_ok(2))
     +  cgamma(ICHAR,1) = XMCHAR(ICHAR)/(256.
     +      *(Dpi**3))*(Cf*1./8.*G**2*XLAM**2)*integral()

        CALL CLSPCPL(2)
        CALL CPSPXMS(2)
        fntype=222
        IF (kine_ok(2))
     +  cgamma(ICHAR,2) = XMCHAR(ICHAR)/(256.
     +      *(Dpi**3))*(Cf*1./8.*G**2*XLAM**2)*integral()

        CALL CLSPCPL(3)
        CALL CPSPXMS(3)
        fntype=223
        IF (kine_ok(2))
     +  cgamma(ICHAR,3) = XMCHAR(ICHAR)/(256.
     +      *(Dpi**3))*(Cf*1./8.*G**2*XLAM**2)*integral()

        CALL CLSPCPL(4)
        CALL CPSPXMS(4)
        fntype=224
        IF (kine_ok(2))
     +  cgamma(ICHAR,4) = XMCHAR(ICHAR)/(256.
     +      *(Dpi**3))*(Cf*1./8.*G**2*XLAM**2)*integral()

        cgamma_tot(ICHAR)= cgamma(ICHAR,1)+cgamma(ICHAR,2)+
     +       cgamma(ICHAR,3)+cgamma(ICHAR,4)


       ELSEIF (COUPL_I(1).EQ.1) then
C ...    two LLE diagrams for EACH chargino
        Cf=1.

        CALL CLSPCPL(1)
        CALL CPSPXMS(1)
        fntype=211
        IF (kine_ok(2))
     +  cgamma(ICHAR,1) = XMCHAR(ICHAR)/(256.
     +      *(Dpi**3))*(Cf*1./8.*G**2*XLAM**2)*integral()

        CALL CLSPCPL(2)
        CALL CPSPXMS(2)
        fntype=212
        IF (kine_ok(2))
     +  cgamma(ICHAR,2) = XMCHAR(ICHAR)/(256.
     +      *(Dpi**3))*(Cf*1./8.*G**2*XLAM**2)*integral()


        cgamma_tot(ICHAR)= cgamma(ICHAR,1)+cgamma(ICHAR,2)

       ELSE
         cgamma(ICHAR,1) = 0.
        cgamma(ICHAR,2) = 0.
        cgamma(ICHAR,3) = 0.
        cgamma(ICHAR,4) = 0.
          cgamma_tot(ICHAR)= 0.
        write (*,*) ' RPARBRANCH: Warning, Only C->LLE,LQD implemented'
       ENDIF
 999   continue
      ENDDO


      IF (RBOD) then
      write (*,*)
     +      ' Warning !!! - RBOD card given, overwriting ngamma calc'
      do ii=1,4
            ngamma(ii,1)=rbod_g(1)
            ngamma(ii,2)=rbod_g(2)
            ngamma(ii,3)=rbod_g(3)
            ngamma(ii,4)=rbod_g(4)
      enddo
      ENDIF
      IF (RBOD2) then
      write (*,*)
     +      ' Warning !!! - RBOD2 card given, overwriting cgamma calc'
      do ii=1,2
            cgamma(ii,1)=rbod2_g(1)
            cgamma(ii,2)=rbod2_g(2)
            cgamma(ii,3)=rbod2_g(3)
            cgamma(ii,4)=rbod2_g(4)
      enddo
      ENDIF
      END


        Subroutine RPARPRINT
        Implicit none
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------

********************* start of commons of SUSYGEN **********************
      integer ievent
      common /eve/ ievent
      real*4  rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan(6)
      common /rkey/rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan

      real*8  gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu
      common/steer/gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu

      Integer modes,MIX
      common/mds/modes,MIX
      logical zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,higgs
      common/sparc/ zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,
     + higgs
      logical wrt,scan,lepi
      common/str/wrt,scan,lepi
      real*8  flum,ecm,s,roots,T,Q,Q2,EN
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
      real*8  QK
      COMMON/ISR/ QK(4)
      real erad,srad
      common/srada/erad(100),srad(100)
      integer  idbg,igener,irad
      COMMON /CONST/ idbg,igener,irad
      integer  index,index1,index2,nevt
      COMMON/INDEXX/index,index1,index2,nevt
      real*8   fmpr1,fmpr2,XCROST,APRO
      COMMON/FINDEX/fmpr1,fmpr2,XCROST,APRO
      real*8   cosphimix,facqcd,fgama,spartmas,ratq
      common/mixings/cosphimix,facqcd,fgama,spartmas,ratq
      real*8   FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +         FLC,FRC,gms,echar
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
      real*8      TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      real*8   fmal,fmar,ratqa,fgamc,fgamcr,cosmi
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)

      real*4 gmas,phimx
      common/stopmix/gmas(3),phimx(3)
      real*4 phimix1,stop1,phimix2,sbot1,phimix3,stau1
      equivalence (gmas(1),stop1)
      equivalence (gmas(2),sbot1)
      equivalence (gmas(3),stau1)
      equivalence (phimx(1),phimix1)
      equivalence (phimx(2),phimix2)
      equivalence (phimx(3),phimix3)
      real*4 gmas2
      common/stopmix2/gmas2(3)
      real*4 stop2,sbot2,stau2
      equivalence (gmas2(1),stop2)
      equivalence (gmas2(2),sbot2)
      equivalence (gmas2(3),stau2)
      real*4 rscale
      common/sscale/rscale
      logical imsg                      !Added by S.A. for use in the
      common/imessage/imsg              !NTONPH routine

      double precision sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      common/higgses/sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      logical fix_higgs_masses
      common/ steerhiggs / fix_higgs_masses

      integer jdebu,idb1,idb2,lout
      common /debuc/ jdebu,idb1,idb2,lout

      real*8   xgaug,xeta
      COMMON/XCROS/xgaug(8),xeta(8)

      integer  ispa,kl,klap,idecs,klr
      common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
C 04/96 P.Morawitz & M.Williams introduce klr for Rpv gaugino decays
      common/reord2/klr(3,24)
c klr(1,n), klr(2,n) and klr(3,n) are the particles produced in
c R-parity violating decays of gauginos...
C n=1..4 , 5..8	 LLE neutralino,gaugino decays
C n=9..12,13..16 LQD neutralino,gaugino decays
C n=17.20,21..24 UDD neutralino,gaugino decays

      Integer  idecsel,ihigsel
      common/decsel/idecsel(23)
      common/higsel/ihigsel(5)
C 05/96 P.Morawitz
C ...   NOTE: the logical below is used in SUSYGEN V1.5 (April 96)
C       MSSM has its own implementation of R-parity violation.
C       The logical rpar is therefore always set to TRUE which avoids
C       the SUSYGEN R-parity code.
        logical rpar
        common/rpari/rpar
      real*8   brsum,brsuma
CPM      common/brsum/ brsum(5,6,6),brsuma(6)
C 04/96 P.Morawitz & M.Williams  changed brsum to allow for r-parity dec
      common/brsum/ brsum(13,7,6),brsuma(6)
************************************************************************
c EXPLANATION OF INDICES IN BRSUM(itype,igout,igin)
c
c igin  = 1,6 initial gaugino (neutralinos 1..4, charginos 1,2)
c igout = 1,7 outgoing gaugino
c ........where 7 => no outgoing gaugino ie. R-parity violating process
c itype = types of particles produced
c     1 - l+ l-    6 - l q qbar   10 - q q q'         12 - l+ l+ l-
c     2 - v vbar   7 - l q' qbar  11 - qbar qbar qbar 13 - l v v
c     3 - q qbar   8 - v q qbar
c     4 - l v      9 - v q' qbar
c     5 - q' qbar
************************************************************************
      real*8   fms,fmi,fmk,fml1,fml2,etai,etak,brspa
     +        ,brgaug,fmelt,fmert,fmelu,fmeru
      Integer  lind
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
CPM     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
     +lind(6,6,6),brgaug(6,7,11,3),fmelt,fmert,fmelu,fmeru
C 04/96 P.Morawitz & M.Williams  changed brgaug to allow for r-parity de

************************************************************************
c     EXPLANATIONS OF INDICES IN BRGAUG AND BRSPA
c
c BRSPA::
c kgaug =1,6 produced gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c kspar =1,24 initial sparticle
c     1,12  : left-handed sparticle  (u,d,v,e,c,s,v,mu,t,b,v,tau)
c     12,24 : right handed sparticle (u,d,v,e,c,s,v,mu,t,b,v,tau)
c
c BRGAUG::
c igin =1,6 parent gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c igout =1,7 daughter gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c     7    : none (ie. R-parity violating process)
c ipart =1,6 for produced particles .....
c     R-parity conserving decays
c     1,4  : uu,dd,vv,ee                                  - 'like to lik
c     5,6  : ud,ev                                        - 'like to unl
C ipart =7,11 for the 5 diagrams which involve
C             gaugino -> gaugino' gamma
C	      gaugino -> Higgs X
C
C
C ipart =1,8 for Rp-violating!!!! decays (igout=7)
c     R-parity violating decays via LLE operator
c     1,4 :                                               - for neutrali
c     5,8 : l+ l+ l, v v l+, vbar l+ v, l+ vbar v         - for chargino
c     R-parity violating decays via LQD operator
c     1,4  : e+ u dbar, e- ubar d, v d dbar, vbar dbar d  - for neutrali
c     5,8  : v u dbar, e+ dbar d, e+ ubar u, vbar dbar u  - for chargino
c     R-parity violating decays via UDD operator
c     1,4  :						  - for neutralinos
c     5,8  : u u d, u d u, dbar dbar dbar                 - for chargino
c igen =1,3
c     R-parity conserving decays : generation of produced particles
c     R-parity violating decays  : meaningless, i.e. only igen=1 used
************************************************************************
      Real*8   zr,was,esa
      Real*8   VOIJL,VOIJR,gfir,gfil
      COMMON/NEUMIX/ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
      real*8   OIJL,OIJR,V,U,FM,ETA
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      real*8   oijlp,oijrp
      COMMON/CHANEU/oijlp(4,2),oijrp(4,2)
      Integer       ILOOP
      COMMON/SFLOOP/ILOOP
      Real*8   PV
      Integer  IFLAV,NFLAV
CPM      COMMON /PARTC / PV(5,20),IFLAV(20,2),NFLAV
CPM      update to SUSYGEN V1.5
      COMMON /PARTC / pv(5,30)
      COMMON /PARTC1 / iflav(30,2),nflav


      real*8   gw,widfl,widfr,fmeltw,fmertw,fmeluw,fmeruw,gent,gentl
      integer  linda
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,7,6)
CPM     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
C 04/96 P.Morawitz & M.Williams  changed linda to allow for r-parity dec

      integer topo_charg,topo_neut
      common /topocom/ topo_charg,topo_neut

********************* end  of commons of SUSYGEN ***********************

      integer pet_i,pet_j,pet_k,k,pet_h
      double precision gneut(4),gchar(2)

       IF (Coupl_i(1).eq.2) then
           write (*,*) ' Rparity LQD decays enabled'
         ENDIF
       write (*,100) COUPL_I(2),COUPL_I(3),COUPL_I(4),XLAM
 100       FORMAT (' lambda(',I1,',',I1,',',I1,') = ', F10.6)


C... chargino LQD decays

       write (*,*) ' ====================================='
      DO ICHAR=1,2
       write (*,*) '   R-parity Decays of Chargino',ICHAR
       write (*,*) '      with mass ',XMCHAR(ICHAR)
       do k=1,4
       write (*,*) '         G Diagram(',k,')=',cgamma(ICHAR,k)
       enddo
       write (*,*) '         G Total   =',cgamma_tot(ICHAR)
      ENDDO
       write (*,*) ' ====================================='
      DO INEUT=1,4
       write (*,*) '   R-parity Decays of Neutralino',INEUT
       write (*,*) '      with mass ',XMNEU(INEUT)
       do k=1,4
       write (*,*) '         G Diagram(',k,')=',ngamma(INEUT,k)
       enddo
       write (*,*) '         G Total   =',ngamma_tot(INEUT)
      ENDDO

       write (*,*) ' ====================================='



      do pet_i=1,2
         write (*,*) ' Rpar-conserving Char',pet_i,' width =',
     +                  brsuma(4+pet_i)-cgamma_tot(pet_i)
      enddo
      do pet_i=1,4
         write (*,*) ' Rpar-conserving Neut',pet_i,' width =',
     +                  brsuma(pet_i)-ngamma_tot(pet_i)
      enddo

      END


      Subroutine RPARINIT
C     init the Rparity constants etc. Only needs to be called once
C     per set of gaugino/SUSY paramters.
C
      IMPLICIT NONE
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------

********************* start of commons of SUSYGEN **********************
      integer ievent
      common /eve/ ievent
      real*4  rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan(6)
      common /rkey/rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan

      real*8  gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu
      common/steer/gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu

      Integer modes,MIX
      common/mds/modes,MIX
      logical zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,higgs
      common/sparc/ zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,
     + higgs
      logical wrt,scan,lepi
      common/str/wrt,scan,lepi
      real*8  flum,ecm,s,roots,T,Q,Q2,EN
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
      real*8  QK
      COMMON/ISR/ QK(4)
      real erad,srad
      common/srada/erad(100),srad(100)
      integer  idbg,igener,irad
      COMMON /CONST/ idbg,igener,irad
      integer  index,index1,index2,nevt
      COMMON/INDEXX/index,index1,index2,nevt
      real*8   fmpr1,fmpr2,XCROST,APRO
      COMMON/FINDEX/fmpr1,fmpr2,XCROST,APRO
      real*8   cosphimix,facqcd,fgama,spartmas,ratq
      common/mixings/cosphimix,facqcd,fgama,spartmas,ratq
      real*8   FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +         FLC,FRC,gms,echar
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
      real*8      TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      real*8   fmal,fmar,ratqa,fgamc,fgamcr,cosmi
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)

      real*4 gmas,phimx
      common/stopmix/gmas(3),phimx(3)
      real*4 phimix1,stop1,phimix2,sbot1,phimix3,stau1
      equivalence (gmas(1),stop1)
      equivalence (gmas(2),sbot1)
      equivalence (gmas(3),stau1)
      equivalence (phimx(1),phimix1)
      equivalence (phimx(2),phimix2)
      equivalence (phimx(3),phimix3)
      real*4 gmas2
      common/stopmix2/gmas2(3)
      real*4 stop2,sbot2,stau2
      equivalence (gmas2(1),stop2)
      equivalence (gmas2(2),sbot2)
      equivalence (gmas2(3),stau2)
      real*4 rscale
      common/sscale/rscale
      logical imsg                      !Added by S.A. for use in the
      common/imessage/imsg              !NTONPH routine

      double precision sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      common/higgses/sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      logical fix_higgs_masses
      common/ steerhiggs / fix_higgs_masses

      integer jdebu,idb1,idb2,lout
      common /debuc/ jdebu,idb1,idb2,lout

      real*8   xgaug,xeta
      COMMON/XCROS/xgaug(8),xeta(8)

      integer  ispa,kl,klap,idecs,klr
      common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
C 04/96 P.Morawitz & M.Williams introduce klr for Rpv gaugino decays
      common/reord2/klr(3,24)
c klr(1,n), klr(2,n) and klr(3,n) are the particles produced in
c R-parity violating decays of gauginos...
C n=1..4 , 5..8	 LLE neutralino,gaugino decays
C n=9..12,13..16 LQD neutralino,gaugino decays
C n=17.20,21..24 UDD neutralino,gaugino decays

      Integer  idecsel,ihigsel
      common/decsel/idecsel(23)
      common/higsel/ihigsel(5)
C 05/96 P.Morawitz
C ...   NOTE: the logical below is used in SUSYGEN V1.5 (April 96)
C       MSSM has its own implementation of R-parity violation.
C       The logical rpar is therefore always set to TRUE which avoids
C       the SUSYGEN R-parity code.
        logical rpar
        common/rpari/rpar
      real*8   brsum,brsuma
CPM      common/brsum/ brsum(5,6,6),brsuma(6)
C 04/96 P.Morawitz & M.Williams  changed brsum to allow for r-parity dec
      common/brsum/ brsum(13,7,6),brsuma(6)
************************************************************************
c EXPLANATION OF INDICES IN BRSUM(itype,igout,igin)
c
c igin  = 1,6 initial gaugino (neutralinos 1..4, charginos 1,2)
c igout = 1,7 outgoing gaugino
c ........where 7 => no outgoing gaugino ie. R-parity violating process
c itype = types of particles produced
c     1 - l+ l-    6 - l q qbar   10 - q q q'         12 - l+ l+ l-
c     2 - v vbar   7 - l q' qbar  11 - qbar qbar qbar 13 - l v v
c     3 - q qbar   8 - v q qbar
c     4 - l v      9 - v q' qbar
c     5 - q' qbar
************************************************************************
      real*8   fms,fmi,fmk,fml1,fml2,etai,etak,brspa
     +        ,brgaug,fmelt,fmert,fmelu,fmeru
      Integer  lind
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
CPM     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
     +lind(6,6,6),brgaug(6,7,11,3),fmelt,fmert,fmelu,fmeru
C 04/96 P.Morawitz & M.Williams  changed brgaug to allow for r-parity de

************************************************************************
c     EXPLANATIONS OF INDICES IN BRGAUG AND BRSPA
c
c BRSPA::
c kgaug =1,6 produced gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c kspar =1,24 initial sparticle
c     1,12  : left-handed sparticle  (u,d,v,e,c,s,v,mu,t,b,v,tau)
c     12,24 : right handed sparticle (u,d,v,e,c,s,v,mu,t,b,v,tau)
c
c BRGAUG::
c igin =1,6 parent gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c igout =1,7 daughter gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c     7    : none (ie. R-parity violating process)
c ipart =1,6 for produced particles .....
c     R-parity conserving decays
c     1,4  : uu,dd,vv,ee                                  - 'like to lik
c     5,6  : ud,ev                                        - 'like to unl
C ipart =7,11 for the 5 diagrams which involve
C             gaugino -> gaugino' gamma
C	      gaugino -> Higgs X
C
C
C ipart =1,8 for Rp-violating!!!! decays (igout=7)
c     R-parity violating decays via LLE operator
c     1,4 :                                               - for neutrali
c     5,8 : l+ l+ l, v v l+, vbar l+ v, l+ vbar v         - for chargino
c     R-parity violating decays via LQD operator
c     1,4  : e+ u dbar, e- ubar d, v d dbar, vbar dbar d  - for neutrali
c     5,8  : v u dbar, e+ dbar d, e+ ubar u, vbar dbar u  - for chargino
c     R-parity violating decays via UDD operator
c     1,4  :						  - for neutralinos
c     5,8  : u u d, u d u, dbar dbar dbar                 - for chargino
c igen =1,3
c     R-parity conserving decays : generation of produced particles
c     R-parity violating decays  : meaningless, i.e. only igen=1 used
************************************************************************
      Real*8   zr,was,esa
      Real*8   VOIJL,VOIJR,gfir,gfil
      COMMON/NEUMIX/ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
      real*8   OIJL,OIJR,V,U,FM,ETA
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      real*8   oijlp,oijrp
      COMMON/CHANEU/oijlp(4,2),oijrp(4,2)
      Integer       ILOOP
      COMMON/SFLOOP/ILOOP
      Real*8   PV
      Integer  IFLAV,NFLAV
CPM      COMMON /PARTC / PV(5,20),IFLAV(20,2),NFLAV
CPM      update to SUSYGEN V1.5
      COMMON /PARTC / pv(5,30)
      COMMON /PARTC1 / iflav(30,2),nflav


      real*8   gw,widfl,widfr,fmeltw,fmertw,fmeluw,fmeruw,gent,gentl
      integer  linda
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,7,6)
CPM     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
C 04/96 P.Morawitz & M.Williams  changed linda to allow for r-parity dec

      integer topo_charg,topo_neut
      common /topocom/ topo_charg,topo_neut

********************* end  of commons of SUSYGEN ***********************


      Integer j,i
      DOUBLE PRECISION SSMASS
      EXTERNAL SSMASS

C ... set correct ijk generations in the klr-decay products
      do i=1,24
      do j=1,3
        klr(j,i)=  klr(j,i)+sign(1,klr(j,i))*2*(coupl_i(j+1)-1)
      enddo
      enddo


C     First convert the Neutralino basis of SUSYGEN to
C     the Neutralino basis of Gunion+Haber,Nucl.Phys.B272(86) p57-60

        do j=1,4
          N_GH(j,1)=ZR(1,j)*cosw - ZR(2,j)*sinw

          N_GH(j,2)=ZR(1,j)*sinw + ZR(2,j)*cosw
          N_GH(j,3)=ZR(3,j)*cosb + ZR(4,j)*sinb
          N_GH(j,4)=-ZR(3,j)*sinb + ZR(4,j)*cosb
        enddo

C   *******************************
C
C       FERMION MASSES IN GEV
C   **********************************
        XMELEC(1)= ssmass(11)
        XMELEC(2)= ssmass(13)
        XMELEC(3)= ssmass(15)
        XMUP(1)=   ssmass(2)
        XMUP(2)=   ssmass(4)
        XMUP(3)=   ssmass(6)
        XMDOWN(1)= ssmass(1)
        XMDOWN(2)= ssmass(3)
        XMDOWN(3)= ssmass(5)

C***************************************
C
C       Left-handed SFERMION MASSES IN GEV
C**************************************

      XMSCALELEC(1) =ssmass(11+40)
      XMSCALELEC(2) =ssmass(13+40)
      XMSCALELEC(3) =ssmass(15+40)
      XMSCALNEUT(1) =ssmass(12+40)
      XMSCALNEUT(2) =ssmass(14+40)
      XMSCALNEUT(3) =ssmass(16+40)
      XMSCALUP(1)   =ssmass(2+40)
      XMSCALUP(2)   =ssmass(4+40)
      XMSCALUP(3)   =ssmass(6+40)
      XMSCALDOWN(1) =ssmass(1+40)
      XMSCALDOWN(2) =ssmass(3+40)
      XMSCALDOWN(3) =ssmass(5+40)

C**************************************
C       Right-handed SFERMION MASSES IN GEV
C**************************************
        XMSCALELECR(1) = ssmass(57)
        XMSCALELECR(2) = ssmass(58)
        XMSCALELECR(3) = ssmass(59)
      XMSCALUPR(1)   =ssmass(48)
      XMSCALUPR(2)   =ssmass(50)
      XMSCALUPR(3)   =ssmass(62)
      XMSCALDOWNR(1) =ssmass(47)
      XMSCALDOWNR(2) =ssmass(49)
      XMSCALDOWNR(3) =ssmass(61)

C**************************************
C       GAuginos
C**************************************
        Do j=1,4
           XMNEU(j)=ssmass(j+70)
        Enddo
        Do j=1,2
           XMCHAR(j)=ssmass(j+74)
           ETACHAR(j)=xeta(j+4)
        Enddo

C******************************************
C   W-BOSON, LSP-MASS IN GEV, EW-COUPLING
C****************************************
      XMW=fmw
C      E=0.303
        G=DSQRT(G2)
        TANTHW=SINW/COSW
        SIN2THW=SINW**2

        RETURN
        END


CPMC---------------------------------------------------
CPM      Double Precision Function MY_CLQDFM1()
CPMC---------------------------------------------------
CPM      Implicit none
CPMC     P.Morawitz, 7.3.96
CPMC     matrix element for Chi+(p) -> nu_i(k1) u_j(k2) db_k(k3)
CPMC         via L Q Dbar couplings
CPMC     Coupling factor 0.5*Coulfac*g**2*lambda**2/4 not included
CPM
CPM*CA HDSUSY
CPM      DOUBLE PRECISION D(3),PGFUNC
CPM      EXTERNAL PGFUNC
CPM      INTEGER K
CPM
CPM      LOGICAL clims_ok
CPM      EXTERNAL clims_ok
CPM
CPM      MY_CLQDFM1=0.
CPM      IF (.not.(clims_ok())) return
CPM
CPM      CALL LSPDOT
CPM
CPM      DO 63 K=1,2
CPM      D(K)=1./(1.+XMU(K)-XMUTILDE(K)-2*PPP(0,K))
CPM   63 CONTINUE
CPM
CPM      MY_CLQDFM1 = D(1)**2 * 32. * A(1)**2 * PPP(0,1) *
CPM     +            (PPP(2,3) - SQRT(XMU(2)*XMU(3)))
CPM     +    +     D(2)**2 * 32. * PPP(1,3) *
CPM     +            ((A(2)**2+B(2)**2)*PPP(0,2)
CPM     +                     +2.*A(2)*B(2)*(SQRT(XMU(2))))
CPM     +    -  2.*D(1)*D(2)*8. * A(1)*
CPM     +           (a(2)*(PGFUNC(1,0,2,3)
CPM     +                 -PPP(0,1)*SQRT(XMU(2)*XMU(3)))
CPM     +           +b(2)*(PPP(1,3)*SQRT(XMU(2))
CPM     +                 -PPP(1,2)*SQRT(XMU(3))))
CPM
CPM      RETURN
CPM      END
CPM
CPM
CPMC---------------------------------------------------
CPM      Double Precision Function MY_CLQDFM2()
CPMC---------------------------------------------------
CPM      Implicit none
CPMC     P.Morawitz, 7.3.96
CPMC     matrix element for Chi+(p) -> e+_i(k1) dbar_j(k2) d_k(k3)
CPMC         via L Q Dbar couplings
CPMC     Coupling factor 0.5*Coulfac*g**2*lambda**2/4 not included
CPM
CPM*CA HDSUSY
CPM      DOUBLE PRECISION D(3),PGFUNC
CPM      EXTERNAL PGFUNC
CPM      INTEGER K
CPM
CPM      LOGICAL clims_ok
CPM      EXTERNAL clims_ok
CPM
CPM      MY_CLQDFM2=0.
CPM      IF (.not.(clims_ok())) return
CPM
CPM      CALL LSPDOT
CPM
CPM      DO 63 K=1,2
CPM      D(K)=1./(1.+XMU(K)-XMUTILDE(K)-2*PPP(0,K))
CPM   63 CONTINUE
CPM
CPM      MY_CLQDFM2 =
CPM     +   D(2)**2 * 32. * (PPP(1,3)-SQRT(XMU(1)*XMU(3))) *
CPM     +      ((a(2)**2+b(2)**2)*PPP(0,2)
CPM     +       +2.*a(2)*b(2)*SQRT(xmu(2)))
CPM     +  +D(1)**2 * 32. * (PPP(2,3)-SQRT(xmu(2)*xmu(3))) *
CPM     +      ((a(1)**2+b(1)**2)*PPP(0,1)
CPM     +       +2.*a(1)*b(1)*SQRT(xmu(1)))
CPM     + -2.*D(2)*D(1)*8.*(
CPM     +      (a(2)*a(1)+b(2)*b(1))*
CPM     +       (PGFUNC(0,1,2,3)-PPP(0,1)*SQRT(xmu(2)*xmu(3))
CPM     +        -PPP(0,2)*SQRT(XMU(1)*XMU(3))
CPM     +        +PPP(0,3)*SQRT(XMU(1)*XMU(2)))
CPM     +       +2.*((a(2)*b(1)+b(2)*a(1))*
CPM     +        (PPP(1,3)*SQRT(XMU(2))-PPP(1,2)*SQRT(XMU(3))
CPM     +         +PPP(2,3)*SQRT(XMU(1))-
CPM     +         DSQRT(XMU(1)*XMU(2)*XMU(3)))))
CPM
CPM      RETURN
CPM      END
CPM
CPM
CPM
CPMC---------------------------------------------------
CPM      Double Precision Function MY_CLQDFM3()
CPMC---------------------------------------------------
CPM      Implicit none
CPMC     P.Morawitz, 7.3.96
CPMC     matrix element for Chi+(p) -> e+_i(k1) ubar_j(k2) u_k(k3)
CPMC         via L Q Dbar couplings
CPMC     Coupling factor 0.5*Coulfac*g**2*lambda**2/4 not included
CPM
CPM*CA HDSUSY
CPM      DOUBLE PRECISION D(3),PGFUNC
CPM      EXTERNAL PGFUNC
CPM      INTEGER K
CPM
CPM      LOGICAL clims_ok
CPM      EXTERNAL clims_ok
CPM
CPM      MY_CLQDFM3=0.
CPM      IF (.not.(clims_ok())) return
CPM
CPM      CALL LSPDOT
CPM
CPM      DO 63 K=3,3
CPM      D(K)=1./(1.+XMU(K)-XMUTILDE(K)-2*PPP(0,K))
CPM   63 CONTINUE
CPM
CPM      MY_CLQDFM3 =
CPM     +  D(3)**2 * 32. * b(3)**2 *PPP(0,3)*
CPM     +     (PPP(1,2)-SQRT(XMU(1)*XMU(2)))
CPM
CPM      RETURN
CPM      END
CPM
CPM
CPMC---------------------------------------------------
CPM      Double Precision Function MY_CLQDFM4()
CPMC---------------------------------------------------
CPM      Implicit none
CPMC     P.Morawitz, 7.3.96
CPMC     matrix element for Chi+(p) -> nubar_i(k1) dbar_j(k2) u_k(k3)
CPMC         via L Q Dbar couplings
CPMC     Coupling factor 0.5*Coulfac*g**2*lambda**2/4 not included
CPM
CPM*CA HDSUSY
CPM      DOUBLE PRECISION D(3),PGFUNC
CPM      EXTERNAL PGFUNC
CPM      INTEGER K
CPM
CPM      LOGICAL clims_ok
CPM      EXTERNAL clims_ok
CPM
CPM      MY_CLQDFM4=0.
CPM      IF (.not.(clims_ok())) return
CPM
CPM      CALL LSPDOT
CPM
CPM      DO 63 K=3,3
CPM      D(K)=1./(1.+XMU(K)-XMUTILDE(K)-2*PPP(0,K))
CPM   63 CONTINUE
CPM
CPM      MY_CLQDFM4 =
CPM     +  D(3)**2 * 32. * b(3)**2 *PPP(0,3)*
CPM     +     (PPP(1,2))
CPM
CPM      RETURN
CPM      END
CPM
CPM
C---------------------------------------------------
      Double Precision Function CLQDFM1()
C---------------------------------------------------
      Implicit none
C     P.Morawitz, 7.3.96
C     matrix element for Chi+(p) -> nu_i(k1) u_j(k2) db_k(k3)
C         via L Q Dbar couplings
C     Coupling factor 0.5*Coulfac*g**2*lambda**2/4 not included

C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------

      DOUBLE PRECISION D(3),PGFUNC
      EXTERNAL PGFUNC
      INTEGER K

      LOGICAL clims_ok
      EXTERNAL clims_ok

      CLQDFM1=0.
      IF (.not.(clims_ok())) return

      CALL LSPDOT

      DO 63 K=1,2
      D(K)=1./(1.+XMU(K)-XMUTILDE(K)-2*PPP(0,K))
   63 CONTINUE

      CLQDFM1 = 4.*(
C ... the F term
     +       ( b(1)**2  * ( 4*PPP(0,1)*PPP(2,3) )
     +      +  a(1)*b(1)* ( 8*PPP(2,3)*SQRT(xmu(1)))
     +      +  a(1)**2  * ( 4*PPP(0,1)*PPP(2,3) ))*D(1)**2
C ... the G term
     +      +( b(2)**2  * ( 4*PPP(0,2)*PPP(1,3))
     +      +  a(2)*b(2)* ( 8*PPP(1,3)*SQRT(XMU(2)))
     +      +  a(2)**2  * ( 4*PPP(0,2)*PPP(1,3)))*D(2)**2
C ... the T1 term
     +      + 2.*(b(1)*b(2) * (2*PPP(0,3)*SQRT(XMU(1)*XMU(2)))
     +      +     b(1)*a(2) * (2*PPP(2,3)*SQRT(XMU(1)))
     +      +     a(1)*b(2) * (2*PPP(1,3)*SQRT(XMU(2)))
     +      +     a(1)*a(2) * 2*(
     +  PPP(0,1)*PPP(2,3)+PPP(0,2)*PPP(1,3)-PPP(0,3)*PPP(1,2)))
     +  *D(1)*D(2))

      RETURN
      END

      Double Precision Function CLQDFM2()
C---------------------------------------------------
      Implicit none
C     P.Morawitz, 7.3.96
C     matrix element for Chi+(p) -> e+_i(k1) dbar_j(k2) d_k(k3)
C         via L Q Dbar couplings
C     Coupling factor 0.5*Coulfac*g**2*lambda**2/4 not included

C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------

      DOUBLE PRECISION D(3),PGFUNC
      EXTERNAL PGFUNC
      INTEGER K

      LOGICAL clims_ok
      EXTERNAL clims_ok

      CLQDFM2=0.
      IF (.not.(clims_ok())) return

      CALL LSPDOT

      DO 63 K=1,2
      D(K)=1./(1.+XMU(K)-XMUTILDE(K)-2*PPP(0,K))
   63 CONTINUE

      CLQDFM2 =4.*(
C ... the F term
     +       ( a(1)**2 *   ( 4*PPP(0,1)*PPP(2,3) )
     +       + a(1)*b(1) * ( - 8*PPP(2,3)*SQRT(xmu(1)))
     +       + b(1)**2 *   ( 4*PPP(0,1)*PPP(2,3)))*D(1)**2
C ... the G term
     +     + ( a(2)**2 *   ( 4*PPP(0,2)*PPP(1,3))
     +     +   a(2)*b(2) * ( - 8*PPP(1,3)*SQRT(XMU(2)) )
     +     +   b(2)**2 *   ( 4*PPP(0,2)*PPP(1,3)))*D(2)**2
C ... the T1 term
     +     + 2*( a(1)*a(2) * ( 2*PPP(0,1)*PPP(2,3) +
     +           2*PPP(0,2)*PPP(1,3) - 2*PPP(0,3)*PPP(1,2))
     +     +   a(2)*b(1) * ( - 2*PPP(2,3)*SQRT(XMU(1)))
     +     +   a(1)*b(2) * ( - 2*PPP(1,3)*SQRT(XMU(2)))
     +     +   b(1)*b(2) * ( 2*PPP(0,3)*SQRT(XMU(1)*XMU(2))))
     +                       *D(1)*D(2))



      RETURN
      END



      Double Precision Function CLQDFM3()
C---------------------------------------------------
      Implicit none
C     P.Morawitz, 7.3.96
C     matrix element for Chi+(p) -> e+_i(k1) ubar_j(k2) u_k(k3)
C         via L Q Dbar couplings
C     Coupling factor 0.5*Coulfac*g**2*lambda**2/4 not included

C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------

      DOUBLE PRECISION D(3),PGFUNC
      EXTERNAL PGFUNC
      INTEGER K

      LOGICAL clims_ok
      EXTERNAL clims_ok

      CLQDFM3=0.
      IF (.not.(clims_ok())) return

      CALL LSPDOT

      DO 63 K=3,3
      D(K)=1./(1.+XMU(K)-XMUTILDE(K)-2*PPP(0,K))
   63 CONTINUE

      CLQDFM3 = 0.5*(
     +  D(3)**2 * 32. * b(3)**2 *PPP(0,3)*(PPP(1,2)))

      RETURN
      END

      Double Precision Function CLQDFM4()
C---------------------------------------------------
      Implicit none
C     P.Morawitz, 7.3.96
C     matrix element for Chi+(p) -> nubar_i(k1) dbar_j(k2) u_k(k3)
C         via L Q Dbar couplings
C     Coupling factor 0.5*Coulfac*g**2*lambda**2/4 not included

C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------

      DOUBLE PRECISION D(3),PGFUNC
      EXTERNAL PGFUNC
      INTEGER K

      LOGICAL clims_ok
      EXTERNAL clims_ok

      CLQDFM4=0.
      IF (.not.(clims_ok())) return

      CALL LSPDOT

      DO 63 K=3,3
      D(K)=1./(1.+XMU(K)-XMUTILDE(K)-2*PPP(0,K))
   63 CONTINUE

      CLQDFM4 = 0.5*(
     +  D(3)**2 * 32. * b(3)**2 *PPP(0,3)*(PPP(1,2)))

      RETURN
      END

      Double Precision Function CLLEFM1()
C---------------------------------------------------
      Implicit none
C     P.Morawitz, 13.6.96
C     matrix element for Chi+(p) -> nu_i(k1) nu_j(k2) e+_k(k3)
C         via L L E couplings
C     Coupling factor 0.5*Coulfac*g**2*lambda**2/4 not included

C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------

      DOUBLE PRECISION D(3),PGFUNC
      EXTERNAL PGFUNC
      INTEGER K

      LOGICAL clims_ok
      EXTERNAL clims_ok

      CLLEFM1=0.
      IF (.not.(clims_ok())) return

      CALL LSPDOT

      DO 63 K=1,2
      D(K)=1./(1.+XMU(K)-XMUTILDE(K)-2*PPP(0,K))
   63 CONTINUE

      CLLEFM1 = -2*((-a(2)**2 * D(1)**2 *(PPP(0,1))*(PPP(2,3))) +
     +             (-b(2)**2 * D(2)**2 *(PPP(0,2))*(PPP(1,3))) -
     +             (a(2)*b(2)*D(1)*D(2)*PGFUNC(0,1,3,2)))

      RETURN
      END

      Double Precision Function CLLEFM2()
C---------------------------------------------------
      Implicit none
C     P.Morawitz, 13.6.96
C     matrix element for Chi+(p) -> e+_i(k1) e+_j(k2) e-_k(k3)
C         via L L E couplings
C     Coupling factor 0.5*Coulfac*g**2*lambda**2/4 not included

C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------

      DOUBLE PRECISION D(3),PGFUNC
      EXTERNAL PGFUNC
      INTEGER K

      LOGICAL clims_ok
      EXTERNAL clims_ok

      CLLEFM2=0.
      IF (.not.(clims_ok())) return

      CALL LSPDOT

      DO 63 K=1,2
      D(K)=1./(1.+XMU(K)-XMUTILDE(K)-2*PPP(0,K))
   63 CONTINUE

      CLLEFM2 = -2*(
     + D(1)**2*PPP(2,3)* ((-a(1)**2-a(2)**2)*PPP(0,1) +
     +                    2*(-a(1)*a(2)*SQRT(XMU(1)))) +
     + D(2)**2*PPP(1,3)* ((-b(1)**2-b(2)**2)*PPP(0,2) +
     +                    2*(-b(1)*b(2)*SQRT(XMU(2)))) -
     + D(1)*D(2)*(a(1)*b(1)*PGFUNC(0,1,3,2)-
     +            a(1)*b(2)*SQRT(XMU(2))*PPP(1,3) -
     +            a(2)*b(1)*SQRT(XMU(1))*PPP(2,3) +
     +            a(2)*b(2)*SQRT(XMU(1))*SQRT(XMU(2))*PPP(0,3)))
      RETURN
      END

      SUBROUTINE LSPDOT
        IMPLICIT NONE
C   Author: H.Dreiner and P.Morawitz
C**************************************************************
C This subroutine calculates all the 4-dotproducts which can
C appear in the matrix element. For COUPL_I(1)=1,
C     LSP(0)--> e_i(1)+nu_j(2)+e_k(3), nu_i(4)+e_j(5)+e_k(6),
C and PPP(0,4)= (LSP.nu_i); PPP(4,6)=(nu_i.e_k), etc
C The dotproducts are given as in Barger and Phillips B2.2
C second part.
C*************************************************************

C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------

      INTEGER J,K,L1,L2
      X(3)= 2 - X(1) - X(2)
      X(6)= 2 - X(4) - X(5)
      PPP(0,0)=1.0
      DO 20 J=1,6
            PPP(J,J) = XMU(J)*XMU(J)
   20      CONTINUE

      PPP(1,2) = 0.5* (1+ XMU(3) - XMU(1) - XMU(2) - X(3))
      PPP(1,3) = 0.5* (1+ XMU(2) - XMU(1) - XMU(3) - X(2))
      PPP(2,3) = 0.5* (1+ XMU(1) - XMU(2) - XMU(3) - X(1))
      PPP(4,5) = 0.5* (1+ XMU(6) - XMU(4) - XMU(5) - X(6))
      PPP(4,6) = 0.5* (1+ XMU(5) - XMU(4) - XMU(6) - X(5))
      PPP(5,6) = 0.5* (1+ XMU(4) - XMU(5) - XMU(6) - X(4))

      DO 30 J=1,3
            DO 40 K=4,6
                  PPP(J,K)=0.0
   40             CONTINUE
   30      CONTINUE

      DO 50 J=1,6
            PPP(0,J)= 0.5 * X(J)
   50      CONTINUE


      DO 41 L1=0,5
            DO 42 L2=L1+1,6
                  PPP(L2,L1)=PPP(L1,L2)
   42             CONTINUE
   41      CONTINUE

        RETURN
        END

      DOUBLE PRECISION FUNCTION  LSPFM1()
C   Author: H.Dreiner and P.Morawitz
C   LLE type charged lepton (first L) decay Matrix element
        IMPLICIT NONE
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------


      DOUBLE PRECISION D(6),PGFUNC
        EXTERNAL PGFUNC

        INTEGER K

        LOGICAL clims_ok
        EXTERNAL clims_ok
        LSPFM1=0.
        IF (.not.(clims_ok())) return

      CALL LSPDOT
      DO 64 K=1,3
            D(K)=1./(1.+XMU(K)-XMUTILDE(K)-2*PPP(0,K))
   64      CONTINUE
      LSPFM1=D(2)**2 * PPP(1,3) * ( (A(2)**2 + B(2)**2 ) * PPP(0,2)+
     *               2* A(2)* B(2) * DSQRT(XMU(2)) )
     *     + D(3)**2 * PPP(1,2) * ( (A(3)**2 + B(3)**2) * PPP(0,3)+
     *               2* A(3)*(-B(3))* DSQRT(XMU(3)) )
     *     + D(1)**2 * PPP(2,3) * ((A(1)**2 + B(1)**2) * PPP(0,1) +
     *               2* A(1)*B(1) * DSQRT(XMU(1)) )
     *  -D(1)*D(2) * ( A(2)*A(1) * DSQRT(XMU(1) * XMU(2)) * PPP(0,3)
     *     + A(2) * B(1) * DSQRT( XMU(2) ) * PPP(1,3)
     *     + A(1) * B(2) * DSQRT( XMU(1) ) * PPP(2,3)
     *     + B(1) * B(2) * PGFUNC(2,0,1,3) )
     *  -D(2)* D(3)* (A(2)* A(3) * DSQRT(XMU(2)*XMU(3))* PPP(0,1)
     *     + A(2) * (-B(3)) * DSQRT(XMU(2)) * PPP(1,3)
     *     + A(3) * B(2) * DSQRT(XMU(3)) * PPP(1,2)
     *     + B(2) * (-B(3)) * PGFUNC(2,0,3,1))
     *  -D(1)*D(3)* (A(1) * (-B(3))* DSQRT(XMU(1)) * PPP(2,3)
     *     + A(1) * A(3) * DSQRT(XMU(1)*XMU(3)) * PPP(0,2)
     *     + A(3) * B(1) * DSQRT(XMU(3)) * PPP(1,2)
     *     + B(1) * (-B(3)) * PGFUNC(0,1,2,3) )

      RETURN
      END

      DOUBLE PRECISION FUNCTION  LSPFM2()
C   Author: H.Dreiner and P.Morawitz
C   LQD type charged lepton (L) decay Matrix element
        IMPLICIT NONE
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------


      DOUBLE PRECISION D(6),PGFUNC
        EXTERNAL PGFUNC

        INTEGER K

        LOGICAL clims_ok
        EXTERNAL clims_ok
        LSPFM2=0.
        IF (.not.(clims_ok())) return

      CALL LSPDOT
      DO 63 K=1,3
            D(K)=1./(1.+XMU(K)-XMUTILDE(K)-2*PPP(0,K))
   63      CONTINUE
      LSPFM2=(D(2)**2 * PPP(1,3)* ( (A(2)**2 + B(2)**2 ) * PPP(0,2)
     *            +   2* A(2)* B(2) * DSQRT(XMU(2)) )
     *     + D(3)**2 * PPP(1,2) * ( (A(3)**2 + B(3)**2) * PPP(0,3)+
     *               2* A(3)*(-B(3))* DSQRT(XMU(3)) )
     *     + D(1)**2 * PPP(2,3) * ((A(1)**2 + B(1)**2) * PPP(0,1) +
     *               2* A(1)*B(1) * DSQRT(XMU(1)) )
     *  -D(1)*D(2)* ( A(2)*A(1) * DSQRT(XMU(1) * XMU(2)) * PPP(0,3)
     *     + A(2) * B(1) * DSQRT( XMU(2) ) * PPP(1,3)
     *     + A(1) * B(2) * DSQRT( XMU(1) ) * PPP(2,3)
     *     + B(1) * B(2) * PGFUNC(2,0,1,3) )
     *  -D(2)* D(3)* (A(2)* A(3) * DSQRT(XMU(2)*XMU(3))* PPP(0,1)
     *     + A(2) * (-B(3)) * DSQRT(XMU(2)) * PPP(1,3)
     *     + A(3) * B(2) * DSQRT(XMU(3)) * PPP(1,2)
     *     + B(2) * (-B(3)) * PGFUNC(2,0,3,1))
     *  -D(1)*D(3)* (A(1) * (-B(3))* DSQRT(XMU(1)) * PPP(2,3)
     *     + A(1) * A(3) * DSQRT(XMU(1)*XMU(3)) * PPP(0,2)
     *     + A(3) * B(1) * DSQRT(XMU(3)) * PPP(1,2)
     *     + B(1) * (-B(3)) * PGFUNC(0,1,2,3) ))

      RETURN
      END

      DOUBLE PRECISION FUNCTION  LSPFM3()
C   Author: H.Dreiner and P.Morawitz
C   UDD u-type quark (first U) decay Matrix element
C   Note: there is no LSPFM6 (obviously, 'caus U is a singlet)
        IMPLICIT NONE
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------


      DOUBLE PRECISION D(6),PGFUNC
        EXTERNAL PGFUNC

        INTEGER K

        LOGICAL clims_ok
        EXTERNAL clims_ok
        LSPFM3=0.
        IF (.not.(clims_ok())) return

      CALL LSPDOT
      DO 62 K=1,3
            D(K)=1./(1.+XMU(K)-XMUTILDE(K)-2*PPP(0,K))
   62      CONTINUE

      LSPFM3=
     *   D(1) * D(1) * PPP(2,3) * ( ( B(1)**2 + A(1)**2 ) *PPP(0,1)
     *      +2 * (-B(1)) * A(1) * DSQRT( XMU(1) ) )
     *  +D(2) * D(2) * PPP(1,3) * ( (A(2)**2 + B(2)**2) * PPP(0,2)
     *      +2 * (-B(2)) * A(2) * DSQRT( XMU(2) ) )
     *  +D(3) * D(3) * PPP(1,2) * ( ( A(3)**2 + B(3)**2 ) * PPP(0,3)
     *      +2 * (-B(3)) * A(3) * DSQRT( XMU(3) )  )
     *  + D(1)*D(2)* ( A(1)*A(2)*PGFUNC(1,0,2,3)
     *    + B(1) * B(2) * DSQRT( XMU(1)* XMU(3) ) * PPP(0,3)
     *    + (-B(1)) * A(2) * DSQRT( XMU(1) ) * PPP(2,3)
     *    + (-B(2)) * A(1) * DSQRT( XMU(2) ) * PPP(1,3)  )
     *  + D(1) * D(3) * ( A(1)*A(3)*PGFUNC(1,0,3,2)
     *    + B(1) * B(3) * DSQRT( XMU(1) * XMU(3)) * PPP(0,2)
     *    + (-B(1)) * A(3) * DSQRT( XMU(1) ) * PPP(2,3)
     *    + (-B(3)) * A(1) * DSQRT( XMU(3) ) * PPP(1,2)  )
     *  + D(2) * D(3) * ( A(2) * A(3) * PGFUNC(2,0,3,1)
     *    + B(2) * B(3) * DSQRT(XMU(2) * XMU(3)) * PPP(0,1)
     *    + (-B(2)) * A(3) * DSQRT(XMU(2)) * PPP(1,3)
     *    + (-B(3)) * A(2) * DSQRT(XMU(3)) * PPP(1,2)  )


      RETURN
      END

      DOUBLE PRECISION FUNCTION  LSPFM4()
C   Author: H.Dreiner and P.Morawitz
C   LLE type neutrino (L) decay Matrix element
        IMPLICIT NONE
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------


      DOUBLE PRECISION D(6),PGFUNC
        EXTERNAL PGFUNC

        INTEGER K

        LOGICAL clims_ok
        EXTERNAL clims_ok
        LSPFM4=0.
        IF (.not.(clims_ok())) return

      CALL LSPDOT
      DO 60 K=4,6
            D(K)=1./(1.+XMU(K)-XMUTILDE(K)-2*PPP(0,K))
   60      CONTINUE

      LSPFM4= D(5)**2 * PPP(4,6) * ( (A(5)**2 + B(5)**2 ) * PPP(0,5)+
     *               2* A(5)* B(5) * DSQRT(XMU(5)) )
     *     + D(6)**2 * PPP(4,5) * ( (A(6)**2 + B(6)**2) * PPP(0,6)+
     *               2* A(6)*(-B(6))* DSQRT(XMU(6)) )
     *     + D(4)**2 * PPP(5,6) * ((A(4)**2 + B(4)**2) * PPP(0,4) +
     *               2* A(4)*B(4) * DSQRT(XMU(4)) )
     *  -D(4)*D(5) * ( A(5)*A(4) * DSQRT(XMU(4) * XMU(5)) * PPP(0,6)
     *     + A(5) * B(4) * DSQRT( XMU(5) ) * PPP(4,6)
     *     + A(4) * B(5) * DSQRT( XMU(4) ) * PPP(5,6)
     *     + B(4) * B(5) * PGFUNC(5,0,4,6) )
     *  -D(5)* D(6)* (A(5)* A(6) * DSQRT(XMU(5)*XMU(6))* PPP(0,4)
     *     + A(5) * (-B(6)) * DSQRT(XMU(5)) * PPP(4,6)
     *     + A(6) * B(5) * DSQRT(XMU(6)) * PPP(4,5)
     *     + B(5) * (-B(6)) * PGFUNC(5,0,6,4))
     *  -D(4)*D(6)* (A(4) * (-B(6))* DSQRT(XMU(4)) * PPP(5,6)
     *     + A(4) * A(6) * DSQRT(XMU(4)*XMU(6)) * PPP(0,5)
     *     + A(6) * B(4) * DSQRT(XMU(6)) * PPP(4,5)
     *     + B(4) * (-B(6)) * PGFUNC(0,4,5,6) )
      RETURN
      END

      DOUBLE PRECISION FUNCTION  LSPFM5()
C   Author: H.Dreiner and P.Morawitz
C   LQD type neutrino (L) decay Matrix element
        IMPLICIT NONE
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------


      DOUBLE PRECISION D(6),PGFUNC
        EXTERNAL PGFUNC

        INTEGER K

        LOGICAL clims_ok
        EXTERNAL clims_ok
        LSPFM5=0.
        IF (.not.(clims_ok())) return

      CALL LSPDOT
      DO 61 K=4,6
            D(K)=1./(1.+XMU(K)-XMUTILDE(K)-2*PPP(0,K))
   61      CONTINUE
      LSPFM5=(D(5)**2* PPP(4,6)* ( (A(5)**2 + B(5)**2) * PPP(0,5)+
     *               2* A(5)* B(5) * DSQRT(XMU(5)) )
     *     + D(6)**2 * PPP(4,5) * ( (A(6)**2 + B(6)**2) * PPP(0,6)+
     *               2* A(6)*(-B(6))* DSQRT(XMU(6)) )
     *     + D(4)**2 * PPP(5,6) * ((A(4)**2 + B(4)**2) * PPP(0,4) +
     *               2* A(4)*B(4) * DSQRT(XMU(4)) )
     *  -D(4)*D(5) * ( A(5)*A(4) * DSQRT(XMU(4) * XMU(5)) * PPP(0,6)
     *     + A(5) * B(4) * DSQRT( XMU(5) ) * PPP(4,6)
     *     + A(4) * B(5) * DSQRT( XMU(4) ) * PPP(5,6)
     *     + B(4) * B(5) * PGFUNC(5,0,4,6) )
     *  -D(5)* D(6)* (A(5)* A(6) * DSQRT(XMU(5)*XMU(6))* PPP(0,4)
     *     + A(5) * (-B(6)) * DSQRT(XMU(5)) * PPP(4,6)
     *     + A(6) * B(5) * DSQRT(XMU(6)) * PPP(4,5)
     *     + B(5) * (-B(6)) * PGFUNC(5,0,6,4))
     *  -D(4)*D(6)* (A(4) * (-B(6))* DSQRT(XMU(4)) * PPP(5,6)
     *     + A(4) * A(6) * DSQRT(XMU(4)*XMU(6)) * PPP(0,5)
     *     + A(6) * B(4) * DSQRT(XMU(6)) * PPP(4,5)
     *     + B(4) * (-B(6)) * PGFUNC(0,4,5,6) ) )

      RETURN
      END
      DOUBLE PRECISION FUNCTION LSPPS(W1,W2,W3)
C   Author: H.Dreiner and P.Morawitz
C**************************************************************
C LSPPS is the Phase space function given at the beginning of appendix
C B in Barger and Phillips as \lambda(x,y,z).
C****************************************************************

        IMPLICIT NONE

      DOUBLE PRECISION W1,W2,W3

      LSPPS= W1**2+ W2**2+ W3**2- 2*(W1*W2+ W1*W3+ W2*W3)

      RETURN
      END
C
      DOUBLE PRECISION FUNCTION PGFUNC(J1,J2,J3,J4)
C   Author: H.Dreiner and P.Morawitz
C************************************************************
C PGFUNC is a recurring expression in the matrix elements for the trace
C of four gamma matrices divided by 4.
C***************************************************************

        IMPLICIT NONE
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------

      INTEGER J1,J2,J3,J4

      PGFUNC= PPP(J1,J2)*PPP(J3,J4) - PPP(J1,J3)*PPP(J2,J4)
     *        + PPP(J1,J4) * PPP(J2,J3)

      RETURN
      END

      SUBROUTINE LSPDKL( decay_length, distance, IErr )
C ----------------------------------------------------------------------
C   Purpose: Determine how far a particle of given decay length
C            travels before decaying.
C
C            The equation governing the decay is:
C               N = N_o * exp( -x/decay_length)
C            Thus probabilty of decay in interval x -> x + dx is:
C               abs(dN/N_o)  =  exp( -x/decay_length) * dx/decay_length
C
C       IErr = 1  -----> too many loops. gave up. In this case a random
C                        within the decay length is generated.
C
C ----------------------------------------------------------------------
C
      IMPLICIT NONE
C
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------

      REAL randum, gone, LSP_dx
      REAL decay_length, prob, distance
      INTEGER nloop, IErr, LSP_MAXN

      Real          RNDM
      External      RNDM
C
C --  Initialise
C
      ierr     = 0
      nloop    = 0
      distance = 0.0
      prob=0.0
C
C     make it a tenth of the decay_length
      LSP_dx   = decay_length/10.
      LSP_MAXN = 100
C
      gone = rndm(randum)
C
 1    CONTINUE
C
        IF (nloop .GT. LSP_MAXN) THEN
          IErr = 1
          GOTO 7900
        ENDIF
C
        nloop = nloop + 1
        distance = distance + LSP_dx
C
        prob = prob +
     +         LSP_dx/decay_length*exp(-1.0*distance/decay_length)
C
      IF ( gone .GT. prob) GOTO 1
C
 7900 CONTINUE
      distance = rndm(randum)*decay_length
C
 8900 CONTINUE
      RETURN
      END

        SUBROUTINE PSPXMS
C   Neutralino coupling constants
C   Author: H.Dreiner
C
C******************************************************************

        IMPLICIT NONE
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------

      INTEGER j,k2

          IF (COUPL_I(1).EQ.1) THEN
                  XM(1)=XMELEC(COUPL_I(2))
                  XM(2)=0.0
                  XM(3)=XMELEC(COUPL_I(4))
                  XM(4)=0.0
                  XM(5)=XMELEC(COUPL_I(3))
                  XM(6)=XM(3)
                  XMTILDE(1)= XMSCALELEC(COUPL_I(2))
                  XMTILDE(2)= XMSCALNEUT(COUPL_I(3))
                  XMTILDE(3)= XMSCALELEC(COUPL_I(4))
                  XMTILDE(4)= XMSCALNEUT(COUPL_I(2))
                  XMTILDE(5)= XMSCALELEC(COUPL_I(3))
                  XMTILDE(6)= XMTILDE(3)
            ELSE IF (COUPL_I(1).EQ.2) THEN
                  XM(1)=XMELEC(COUPL_I(2))
                  XM(2)=XMUP(COUPL_I(3))
                  XM(3)=XMDOWN(COUPL_I(4))
                  XM(4)=0.0
                  XM(5)=XMDOWN(COUPL_I(3))
                  XM(6)=XM(3)
                  XMTILDE(1)= XMSCALELEC(COUPL_I(2))
                  XMTILDE(2)= XMSCALUP(COUPL_I(3))
                  XMTILDE(3)= XMSCALDOWN(COUPL_I(4))
                  XMTILDE(4)= XMSCALNEUT(COUPL_I(2))
                  XMTILDE(5)= XMSCALDOWN(COUPL_I(3))
                  XMTILDE(6)= XMTILDE(3)
             ELSE IF (COUPL_I(1).EQ.3) THEN
                  XM(1)=XMUP(COUPL_I(2))
                  XM(2)=XMDOWN(COUPL_I(3))
                  XM(3)=XMDOWN(COUPL_I(4))
                  XM(4)=0.0
                  XM(5)=0.0
                  XM(6)=0.0
                  XMTILDE(1)= XMSCALUP(COUPL_I(2))
                  XMTILDE(2)= XMSCALDOWN(COUPL_I(3))
                  XMTILDE(3)= XMSCALDOWN(COUPL_I(4))
                  XMTILDE(4)= 0.0
                  XMTILDE(5)= 0.0
                  XMTILDE(6)= 0.0

        ENDIF

         DO J=1,6
            XMU(J)= (XM(J)/XMNEU(INEUT))**2
          ENDDO
        DO K2=1,6
              XMUTILDE(K2)= (XMTILDE(K2)/XMNEU(INEUT))**2
          ENDDO

      END

        SUBROUTINE CPSPXMS(Diagram)
C   Chargino coupling constants
C   Author: P.Morawitz
C
C******************************************************************

      IMPLICIT NONE
      INTEGER Diagram,err
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------


      INTEGER i,j,k2

      DO i=1,6
         XM(i)=-1D49
         XMTILDE(i)=-1D49
      ENDDO

      IF (COUPL_I(1).EQ.1) THEN
         IF (diagram.eq.1) then
                XM(1)=0.0
                XM(2)=0.0
                XM(3)=XMELEC(COUPL_I(4))
                XMTILDE(1)= XMSCALELEC(COUPL_I(2))
                XMTILDE(2)= XMSCALELEC(COUPL_I(3))
         ELSEIF (diagram.eq.2) then
                XM(1)=XMELEC(COUPL_I(2))
                XM(2)=XMELEC(COUPL_I(3))
                XM(3)=XMELEC(COUPL_I(4))
                XMTILDE(1)= XMSCALNEUT(COUPL_I(2))
                XMTILDE(2)= XMSCALNEUT(COUPL_I(3))
         ELSE
                stop 'fatal bye '
         ENDIF

      ELSE IF (COUPL_I(1).EQ.2) THEN
         IF (diagram.eq.1) then
                XM(1)=0.0
                XM(2)=XMUP(COUPL_I(3))
                XM(3)=XMDOWN(COUPL_I(4))
                XMTILDE(1)= XMSCALELEC(COUPL_I(2))
                XMTILDE(2)= XMSCALDOWN(COUPL_I(3))
         ELSEIF (diagram.eq.2) then
                XM(1)=XMELEC(COUPL_I(2))
                XM(2)=XMDOWN(COUPL_I(3))
                XM(3)=XMDOWN(COUPL_I(4))
                XMTILDE(1)= XMSCALNEUT(COUPL_I(2))
                XMTILDE(2)= XMSCALUP(COUPL_I(3))
         ELSEIF (diagram.eq.3) then
                XM(1)=XMELEC(COUPL_I(2))
                XM(2)=XMUP(COUPL_I(3))
                XM(3)=XMUP(COUPL_I(4))
                XMTILDE(3)= XMSCALDOWNR(COUPL_I(4))
         ELSEIF (diagram.eq.4) then
                XM(1)=0.0
                XM(2)=XMDOWN(COUPL_I(3))
                XM(3)=XMUP(COUPL_I(4))
                XMTILDE(3)= XMSCALDOWNR(COUPL_I(4))
         ELSE
                stop 'fatal bye '
         ENDIF
       ELSE IF (COUPL_I(1).EQ.3) THEN
         write (*,*)
     + ' CPSXMS:Warning: Chargino UDD decays not yet implemented'
       return
       ELSE
          stop 'CPSXMS: fatal bye '
       ENDIF

       DO J=1,3
          XMU(J)= (XM(J)/XMCHAR(ICHAR))**2
       ENDDO
       DO K2=1,3
          XMUTILDE(K2)= (XMTILDE(K2)/XMCHAR(ICHAR))**2
       ENDDO

       END

        SUBROUTINE LSPCPL
C   Author: H.Dreiner
C
C*************************************************************
        IMPLICIT NONE
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------

********************* start of commons of SUSYGEN **********************
      integer ievent
      common /eve/ ievent
      real*4  rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan(6)
      common /rkey/rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan

      real*8  gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu
      common/steer/gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu

      Integer modes,MIX
      common/mds/modes,MIX
      logical zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,higgs
      common/sparc/ zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,
     + higgs
      logical wrt,scan,lepi
      common/str/wrt,scan,lepi
      real*8  flum,ecm,s,roots,T,Q,Q2,EN
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
      real*8  QK
      COMMON/ISR/ QK(4)
      real erad,srad
      common/srada/erad(100),srad(100)
      integer  idbg,igener,irad
      COMMON /CONST/ idbg,igener,irad
      integer  index,index1,index2,nevt
      COMMON/INDEXX/index,index1,index2,nevt
      real*8   fmpr1,fmpr2,XCROST,APRO
      COMMON/FINDEX/fmpr1,fmpr2,XCROST,APRO
      real*8   cosphimix,facqcd,fgama,spartmas,ratq
      common/mixings/cosphimix,facqcd,fgama,spartmas,ratq
      real*8   FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +         FLC,FRC,gms,echar
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
      real*8      TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      real*8   fmal,fmar,ratqa,fgamc,fgamcr,cosmi
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)

      real*4 gmas,phimx
      common/stopmix/gmas(3),phimx(3)
      real*4 phimix1,stop1,phimix2,sbot1,phimix3,stau1
      equivalence (gmas(1),stop1)
      equivalence (gmas(2),sbot1)
      equivalence (gmas(3),stau1)
      equivalence (phimx(1),phimix1)
      equivalence (phimx(2),phimix2)
      equivalence (phimx(3),phimix3)
      real*4 gmas2
      common/stopmix2/gmas2(3)
      real*4 stop2,sbot2,stau2
      equivalence (gmas2(1),stop2)
      equivalence (gmas2(2),sbot2)
      equivalence (gmas2(3),stau2)
      real*4 rscale
      common/sscale/rscale
      logical imsg                      !Added by S.A. for use in the
      common/imessage/imsg              !NTONPH routine

      double precision sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      common/higgses/sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      logical fix_higgs_masses
      common/ steerhiggs / fix_higgs_masses

      integer jdebu,idb1,idb2,lout
      common /debuc/ jdebu,idb1,idb2,lout

      real*8   xgaug,xeta
      COMMON/XCROS/xgaug(8),xeta(8)

      integer  ispa,kl,klap,idecs,klr
      common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
C 04/96 P.Morawitz & M.Williams introduce klr for Rpv gaugino decays
      common/reord2/klr(3,24)
c klr(1,n), klr(2,n) and klr(3,n) are the particles produced in
c R-parity violating decays of gauginos...
C n=1..4 , 5..8	 LLE neutralino,gaugino decays
C n=9..12,13..16 LQD neutralino,gaugino decays
C n=17.20,21..24 UDD neutralino,gaugino decays

      Integer  idecsel,ihigsel
      common/decsel/idecsel(23)
      common/higsel/ihigsel(5)
C 05/96 P.Morawitz
C ...   NOTE: the logical below is used in SUSYGEN V1.5 (April 96)
C       MSSM has its own implementation of R-parity violation.
C       The logical rpar is therefore always set to TRUE which avoids
C       the SUSYGEN R-parity code.
        logical rpar
        common/rpari/rpar
      real*8   brsum,brsuma
CPM      common/brsum/ brsum(5,6,6),brsuma(6)
C 04/96 P.Morawitz & M.Williams  changed brsum to allow for r-parity dec
      common/brsum/ brsum(13,7,6),brsuma(6)
************************************************************************
c EXPLANATION OF INDICES IN BRSUM(itype,igout,igin)
c
c igin  = 1,6 initial gaugino (neutralinos 1..4, charginos 1,2)
c igout = 1,7 outgoing gaugino
c ........where 7 => no outgoing gaugino ie. R-parity violating process
c itype = types of particles produced
c     1 - l+ l-    6 - l q qbar   10 - q q q'         12 - l+ l+ l-
c     2 - v vbar   7 - l q' qbar  11 - qbar qbar qbar 13 - l v v
c     3 - q qbar   8 - v q qbar
c     4 - l v      9 - v q' qbar
c     5 - q' qbar
************************************************************************
      real*8   fms,fmi,fmk,fml1,fml2,etai,etak,brspa
     +        ,brgaug,fmelt,fmert,fmelu,fmeru
      Integer  lind
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
CPM     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
     +lind(6,6,6),brgaug(6,7,11,3),fmelt,fmert,fmelu,fmeru
C 04/96 P.Morawitz & M.Williams  changed brgaug to allow for r-parity de

************************************************************************
c     EXPLANATIONS OF INDICES IN BRGAUG AND BRSPA
c
c BRSPA::
c kgaug =1,6 produced gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c kspar =1,24 initial sparticle
c     1,12  : left-handed sparticle  (u,d,v,e,c,s,v,mu,t,b,v,tau)
c     12,24 : right handed sparticle (u,d,v,e,c,s,v,mu,t,b,v,tau)
c
c BRGAUG::
c igin =1,6 parent gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c igout =1,7 daughter gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c     7    : none (ie. R-parity violating process)
c ipart =1,6 for produced particles .....
c     R-parity conserving decays
c     1,4  : uu,dd,vv,ee                                  - 'like to lik
c     5,6  : ud,ev                                        - 'like to unl
C ipart =7,11 for the 5 diagrams which involve
C             gaugino -> gaugino' gamma
C	      gaugino -> Higgs X
C
C
C ipart =1,8 for Rp-violating!!!! decays (igout=7)
c     R-parity violating decays via LLE operator
c     1,4 :                                               - for neutrali
c     5,8 : l+ l+ l, v v l+, vbar l+ v, l+ vbar v         - for chargino
c     R-parity violating decays via LQD operator
c     1,4  : e+ u dbar, e- ubar d, v d dbar, vbar dbar d  - for neutrali
c     5,8  : v u dbar, e+ dbar d, e+ ubar u, vbar dbar u  - for chargino
c     R-parity violating decays via UDD operator
c     1,4  :						  - for neutralinos
c     5,8  : u u d, u d u, dbar dbar dbar                 - for chargino
c igen =1,3
c     R-parity conserving decays : generation of produced particles
c     R-parity violating decays  : meaningless, i.e. only igen=1 used
************************************************************************
      Real*8   zr,was,esa
      Real*8   VOIJL,VOIJR,gfir,gfil
      COMMON/NEUMIX/ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
      real*8   OIJL,OIJR,V,U,FM,ETA
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      real*8   oijlp,oijrp
      COMMON/CHANEU/oijlp(4,2),oijrp(4,2)
      Integer       ILOOP
      COMMON/SFLOOP/ILOOP
      Real*8   PV
      Integer  IFLAV,NFLAV
CPM      COMMON /PARTC / PV(5,20),IFLAV(20,2),NFLAV
CPM      update to SUSYGEN V1.5
      COMMON /PARTC / pv(5,30)
      COMMON /PARTC1 / iflav(30,2),nflav


      real*8   gw,widfl,widfr,fmeltw,fmertw,fmeluw,fmeruw,gent,gentl
      integer  linda
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,7,6)
CPM     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
C 04/96 P.Morawitz & M.Williams  changed linda to allow for r-parity dec

      integer topo_charg,topo_neut
      common /topocom/ topo_charg,topo_neut

********************* end  of commons of SUSYGEN ***********************

        IF (COUPL_I(1).EQ.1) THEN
                A(1)= N_GH(INEUT,3)/(2*XMW*COSB) * XMELEC(COUPL_I(2))
                A(2)= 0.0
                A(3)= N_GH(INEUT,3)/(2*XMW*COSB) * XMELEC(COUPL_I(4))
                A(4)= 0.0
                A(5)= N_GH(INEUT,3)/(2*XMW*COSB) * XMELEC(COUPL_I(3))
                B(1)= -0.5*(N_GH(INEUT,2) + TANTHW* N_GH(INEUT,1))
                B(2)= 0.5*(N_GH(INEUT,2) - TANTHW* N_GH(INEUT,1))
                B(3)= -TANTHW * N_GH(INEUT,1)
                B(4)= B(2)
                B(5)= B(1)
           ELSE IF (COUPL_I(1).EQ.2) THEN
                A(1)= N_GH(INEUT,3)/(2*XMW*COSB) * XMELEC(COUPL_I(2))
                A(2)= N_GH(INEUT,4)/(2*XMW*SINB) * XMUP(COUPL_I(3))
                A(3)= N_GH(INEUT,3)/(2*XMW*COSB) * XMDOWN(COUPL_I(4))
                A(4)= 0.0
                A(5)= N_GH(INEUT,3)/(2*XMW*COSB) * XMDOWN(COUPL_I(3))
                B(1)= -0.5 * (N_GH(INEUT,2) + TANTHW* N_GH(INEUT,1))
                B(2)=
     +        0.5  * (N_GH(INEUT,2) + 1./3.*TANTHW* N_GH(INEUT,1))
                B(3)= -1./3.* TANTHW * N_GH(INEUT,1)
                B(4)= 0.5*(N_GH(INEUT,2) - TANTHW* N_GH(INEUT,1))
                B(5)=
     +       -0.5*(N_GH(INEUT,2) - 1./3.*TANTHW* N_GH(INEUT,1))
           ELSE IF (COUPL_I(1).EQ.3) THEN
                A(1)= N_GH(INEUT,4)/(2*XMW*SINB) * XMUP(COUPL_I(2))
                A(2)= N_GH(INEUT,3)/(2*XMW*COSB) * XMDOWN(COUPL_I(3))
                A(3)= N_GH(INEUT,3)/(2*XMW*COSB) * XMDOWN(COUPL_I(4))
                A(4)= A(1)
                A(5)= A(2)
                B(1)= 2./3.* TANTHW * N_GH(INEUT,1)
                B(2)= -1./3.* TANTHW * N_GH(INEUT,1)
                B(3)= -1./3.* TANTHW * N_GH(INEUT,1)
                B(4)= B(1)
                B(5)= B(2)
          ENDIF
                A(6)= A(3)
                B(6)= B(3)
C
        RETURN
        END

      SUBROUTINE CLSPCPL(Diagram)
C   Author: H.Dreiner
C
C*************************************************************
        IMPLICIT NONE
        INTEGER Diagram
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------

********************* start of commons of SUSYGEN **********************
      integer ievent
      common /eve/ ievent
      real*4  rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan(6)
      common /rkey/rgmaum,rgmaur,rgm0,rgtanb,rgatri,rgma,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan

      real*8  gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu
      common/steer/gmaum,gmaur,gm0,gtanb,gatri
     +       ,fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu

      Integer modes,MIX
      common/mds/modes,MIX
      logical zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,higgs
      common/sparc/ zino,wino,sele,smuo,stau,snu,squa,stopa,sbota,
     + higgs
      logical wrt,scan,lepi
      common/str/wrt,scan,lepi
      real*8  flum,ecm,s,roots,T,Q,Q2,EN
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
      real*8  QK
      COMMON/ISR/ QK(4)
      real erad,srad
      common/srada/erad(100),srad(100)
      integer  idbg,igener,irad
      COMMON /CONST/ idbg,igener,irad
      integer  index,index1,index2,nevt
      COMMON/INDEXX/index,index1,index2,nevt
      real*8   fmpr1,fmpr2,XCROST,APRO
      COMMON/FINDEX/fmpr1,fmpr2,XCROST,APRO
      real*8   cosphimix,facqcd,fgama,spartmas,ratq
      common/mixings/cosphimix,facqcd,fgama,spartmas,ratq
      real*8   FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +         FLC,FRC,gms,echar
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
      real*8      TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      real*8   fmal,fmar,ratqa,fgamc,fgamcr,cosmi
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)

      real*4 gmas,phimx
      common/stopmix/gmas(3),phimx(3)
      real*4 phimix1,stop1,phimix2,sbot1,phimix3,stau1
      equivalence (gmas(1),stop1)
      equivalence (gmas(2),sbot1)
      equivalence (gmas(3),stau1)
      equivalence (phimx(1),phimix1)
      equivalence (phimx(2),phimix2)
      equivalence (phimx(3),phimix3)
      real*4 gmas2
      common/stopmix2/gmas2(3)
      real*4 stop2,sbot2,stau2
      equivalence (gmas2(1),stop2)
      equivalence (gmas2(2),sbot2)
      equivalence (gmas2(3),stau2)
      real*4 rscale
      common/sscale/rscale
      logical imsg                      !Added by S.A. for use in the
      common/imessage/imsg              !NTONPH routine

      double precision sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      common/higgses/sfmh,sfma,sfmhp,sfmhpc,sina,cosa
      logical fix_higgs_masses
      common/ steerhiggs / fix_higgs_masses

      integer jdebu,idb1,idb2,lout
      common /debuc/ jdebu,idb1,idb2,lout

      real*8   xgaug,xeta
      COMMON/XCROS/xgaug(8),xeta(8)

      integer  ispa,kl,klap,idecs,klr
      common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
C 04/96 P.Morawitz & M.Williams introduce klr for Rpv gaugino decays
      common/reord2/klr(3,24)
c klr(1,n), klr(2,n) and klr(3,n) are the particles produced in
c R-parity violating decays of gauginos...
C n=1..4 , 5..8	 LLE neutralino,gaugino decays
C n=9..12,13..16 LQD neutralino,gaugino decays
C n=17.20,21..24 UDD neutralino,gaugino decays

      Integer  idecsel,ihigsel
      common/decsel/idecsel(23)
      common/higsel/ihigsel(5)
C 05/96 P.Morawitz
C ...   NOTE: the logical below is used in SUSYGEN V1.5 (April 96)
C       MSSM has its own implementation of R-parity violation.
C       The logical rpar is therefore always set to TRUE which avoids
C       the SUSYGEN R-parity code.
        logical rpar
        common/rpari/rpar
      real*8   brsum,brsuma
CPM      common/brsum/ brsum(5,6,6),brsuma(6)
C 04/96 P.Morawitz & M.Williams  changed brsum to allow for r-parity dec
      common/brsum/ brsum(13,7,6),brsuma(6)
************************************************************************
c EXPLANATION OF INDICES IN BRSUM(itype,igout,igin)
c
c igin  = 1,6 initial gaugino (neutralinos 1..4, charginos 1,2)
c igout = 1,7 outgoing gaugino
c ........where 7 => no outgoing gaugino ie. R-parity violating process
c itype = types of particles produced
c     1 - l+ l-    6 - l q qbar   10 - q q q'         12 - l+ l+ l-
c     2 - v vbar   7 - l q' qbar  11 - qbar qbar qbar 13 - l v v
c     3 - q qbar   8 - v q qbar
c     4 - l v      9 - v q' qbar
c     5 - q' qbar
************************************************************************
      real*8   fms,fmi,fmk,fml1,fml2,etai,etak,brspa
     +        ,brgaug,fmelt,fmert,fmelu,fmeru
      Integer  lind
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
CPM     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
     +lind(6,6,6),brgaug(6,7,11,3),fmelt,fmert,fmelu,fmeru
C 04/96 P.Morawitz & M.Williams  changed brgaug to allow for r-parity de

************************************************************************
c     EXPLANATIONS OF INDICES IN BRGAUG AND BRSPA
c
c BRSPA::
c kgaug =1,6 produced gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c kspar =1,24 initial sparticle
c     1,12  : left-handed sparticle  (u,d,v,e,c,s,v,mu,t,b,v,tau)
c     12,24 : right handed sparticle (u,d,v,e,c,s,v,mu,t,b,v,tau)
c
c BRGAUG::
c igin =1,6 parent gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c igout =1,7 daughter gaugino
c     1,4  : neutralinos
c     5,6  : charginos
c     7    : none (ie. R-parity violating process)
c ipart =1,6 for produced particles .....
c     R-parity conserving decays
c     1,4  : uu,dd,vv,ee                                  - 'like to lik
c     5,6  : ud,ev                                        - 'like to unl
C ipart =7,11 for the 5 diagrams which involve
C             gaugino -> gaugino' gamma
C	      gaugino -> Higgs X
C
C
C ipart =1,8 for Rp-violating!!!! decays (igout=7)
c     R-parity violating decays via LLE operator
c     1,4 :                                               - for neutrali
c     5,8 : l+ l+ l, v v l+, vbar l+ v, l+ vbar v         - for chargino
c     R-parity violating decays via LQD operator
c     1,4  : e+ u dbar, e- ubar d, v d dbar, vbar dbar d  - for neutrali
c     5,8  : v u dbar, e+ dbar d, e+ ubar u, vbar dbar u  - for chargino
c     R-parity violating decays via UDD operator
c     1,4  :						  - for neutralinos
c     5,8  : u u d, u d u, dbar dbar dbar                 - for chargino
c igen =1,3
c     R-parity conserving decays : generation of produced particles
c     R-parity violating decays  : meaningless, i.e. only igen=1 used
************************************************************************
      Real*8   zr,was,esa
      Real*8   VOIJL,VOIJR,gfir,gfil
      COMMON/NEUMIX/ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
      real*8   OIJL,OIJR,V,U,FM,ETA
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      real*8   oijlp,oijrp
      COMMON/CHANEU/oijlp(4,2),oijrp(4,2)
      Integer       ILOOP
      COMMON/SFLOOP/ILOOP
      Real*8   PV
      Integer  IFLAV,NFLAV
CPM      COMMON /PARTC / PV(5,20),IFLAV(20,2),NFLAV
CPM      update to SUSYGEN V1.5
      COMMON /PARTC / pv(5,30)
      COMMON /PARTC1 / iflav(30,2),nflav


      real*8   gw,widfl,widfr,fmeltw,fmertw,fmeluw,fmeruw,gent,gentl
      integer  linda
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,7,6)
CPM     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
C 04/96 P.Morawitz & M.Williams  changed linda to allow for r-parity dec

      integer topo_charg,topo_neut
      common /topocom/ topo_charg,topo_neut

********************* end  of commons of SUSYGEN ***********************

      INTEGER i

      DO i=1,6
         A(i)=-1d49
         B(i)=-1d49
      ENDDO

      IF (COUPL_I(1).EQ.1) THEN
         IF (Diagram.eq.1) then
            A(1)=0.
C            B(1)=XM(COUPL_I(3))*V(ICHAR,2)/
C     +           (SQRT(2.)*XMW*sinb)
            B(1)=0.

            A(2)=U(ICHAR,1)
            B(2)=A(2)

         ELSEIF (Diagram.eq.2) then
            A(1)=V(Ichar,1)
            B(1)=A(1)


            A(2)=XMELEC(COUPL_I(2))*U(ICHAR,2)/
     +           (SQRT(2.)*XMW*cosb)
            B(2)=XMELEC(COUPL_I(3))*U(ICHAR,2)/
     +           (SQRT(2.)*XMW*cosb)
         ELSE
            stop 'fatal bye'
         ENDIF
      ELSEIF (COUPL_I(1).EQ.2) THEN
         IF (Diagram.eq.1) then
            A(1)=U(ICHAR,1)
            B(1)=0.
            A(2)=U(ICHAR,1)
            B(2)=-XMUP(COUPL_I(3))*V(ICHAR,2)/
     +           (SQRT(2.)*XMW*sinb)
         ELSEIF (Diagram.eq.2) then
            A(1)=-V(Ichar,1)
            B(1)=XMELEC(COUPL_I(2))*U(ICHAR,2)/
     +           (SQRT(2.)*XMW*cosb)
            A(2)=-V(Ichar,1)
            B(2)=XMDOWN(COUPL_I(3))*U(Ichar,2)/
     +           (SQRT(2.)*XMW*cosb)
         ELSEIF ((Diagram.eq.3).or.(Diagram.eq.4)) then
            A(3)=0.
            B(3)=-XMDOWN(COUPL_I(4))*U(Ichar,2)/
     +           (SQRT(2.)*XMW*cosb)
         ELSE
            stop 'fatal bye'
         ENDIF
      ELSEIF (COUPL_I(1).EQ.3) THEN
         write (*,*)
     + ' CLSPCPL:Warning: Chargino UDD decays not yet implemented'
       return
      ELSE
         stop 'fatal bye'
      ENDIF
C
        RETURN
        END

      Double Precision Function Integral()
C   Author: P.Morawitz
C
C*************************************************************
        IMPLICIT NONE
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------

        Double Precision x1_min,x1_max,Integra2,ssdint,tint
        External Integra2,ssdint,tint

C...  work out the x_1 limit
      IF ((fntype.eq.122).or.(fntype.eq.112)) then
C ...      either the LQD nu type coupling, or the
C                     LLE nu type coupling - i.e. an exception

          x1_min=2.0*SQRT(XMU(4))
          x1_max=1.0 + XMU(4) - XMU(5) - XMU(6) - 2.*SQRT(xmu(5)*xmu(6))
      ELSE
C ... in all other cases
          x1_min=2.0*SQRT(XMU(1))
          x1_max=1.0 + XMU(1) - XMU(2) - XMU(3) - 2.*SQRT(xmu(2)*xmu(3))
        ENDIF

        IF ((x1_min.lt.0.).or.(x1_max.gt.2.)) then
          write (*,*) ' Warning: Wrong limits , x1min,max=',
     +            x1_min,x1_max
        x1_min=max(x1_min,0.d0)
        x1_max=min(x1_max,2.d0)
        ENDIF

C        Integral = SSDINT(x1_min,Integra2,x1_max)
        Integral = TINT(x1_min,Integra2,x1_max)
        return
        END

      Double Precision Function Integra2(x1)
C   Author: P.Morawitz
C
C*************************************************************
        IMPLICIT NONE
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------

        Double Precision fn,lspps,x1
        Double Precision x2_min,x2_max,c1,c2,c3,ssdint2,tint2
        External fn,ssdint2,lspps,tint2

C...  work out the x_2 limit
      IF ((fntype.eq.122).or.(fntype.eq.112)) then
C ...      either the LQD nu type coupling, or the
C                     LLE nu type coupling - i.e. an exception
           x(4)=x1
           C1= 1.-X(4)+XMU(4)
           C2= (2.-X(4)) * (1. + XMU(4) + XMU(5)-XMU(6)-X(4))
           C3= ((X(4)**2-4.*XMU(4)) * LSPPS( C1,XMU(5),XMU(6)))
      ELSE
C ...     in all other cases
           x(1)=x1
           C1= 1.-X(1)+XMU(1)
           C2= (2.-X(1)) * (1. + XMU(1) + XMU(2)-XMU(3)-X(1))
           C3= ((X(1)**2-4.*XMU(1)) * LSPPS( C1,XMU(2),XMU(3)))
      ENDIF

        IF (C3.LT.0.0) THEN
          IF (C3.GT.-10E-10) THEN
C            IT'S A ROUNDING ERROR
             write (*,*) ' Warning, rounding error in integra2'
             C3 = 0.0
          ELSE
             write (*,*) ' ooops, C3=',C3
             STOP ' Arithm. error in Integra2 C3='
          ENDIF
        ENDIF
        C3=SQRT(C3)
        x2_min=0.5/ C1* ( C2 - C3 )
        x2_max=0.5/ C1* ( C2 + C3 )


         IF ((x2_min.lt.0.).or.(x2_max.gt.2.)) then
           write (*,*) ' Warning: Wrong limits , x2min,max=',
     +            x2_min,x2_max
         x2_min=max(x2_min,0.d0)
         x2_max=min(x2_max,2.d0)
      ENDIF

C        Integra2 = SSDINT2(x2_min,fn,x2_max)
        Integra2 = TINT2(x2_min,fn,x2_max)
      return
        END

      DOUBLE PRECISION FUNCTION SSDINT2(XL,F,XR)
C-----------------------------------------------------------------------
C     Integrate double precision F over double precision (XL,XR)
C     Note quadrature constants R and W have been converted to explicit
C     double precision (.xxxxxDxx) form.
C
C     Bisset's XINTH
C-----------------------------------------------------------------------
      IMPLICIT NONE
      COMMON/SSLUN/LOUT
      INTEGER LOUT
      SAVE /SSLUN/
      EXTERNAL F
      INTEGER NMAX
      DOUBLE PRECISION TOLABS,TOLREL,XLIMS(100)
      DOUBLE PRECISION R(93),W(93)
      INTEGER PTR(4),NORD(4)
      INTEGER ICOUNT
      DOUBLE PRECISION XL,XR,F
      DOUBLE PRECISION AA,BB,TVAL,VAL,TOL
      INTEGER NLIMS,I,J,KKK
C
      DATA PTR,NORD/4,10,22,46,  6,12,24,48/
      DATA (R(KKK),KKK=1,48)/
     + .2386191860D0,.6612093865D0,.9324695142D0,.1252334085D0,
     + .3678314990D0,.5873179543D0,.7699026742D0,.9041172563D0,
     + .9815606342D0,.0640568929D0,.1911188675D0,.3150426797D0,
     + .4337935076D0,.5454214714D0,.6480936519D0,.7401241916D0,
     + .8200019860D0,.8864155270D0,.9382745520D0,.9747285560D0,
     + .9951872200D0,.0323801710D0,.0970046992D0,.1612223561D0,
     + .2247637903D0,.2873624873D0,.3487558863D0,.4086864820D0,
     + .4669029048D0,.5231609747D0,.5772247261D0,.6288673968D0,
     + .6778723796D0,.7240341309D0,.7671590325D0,.8070662040D0,
     + .8435882616D0,.8765720203D0,.9058791367D0,.9313866907D0,
     + .9529877032D0,.9705915925D0,.9841245837D0,.9935301723D0,
     + .9987710073D0,.0162767488D0,.0488129851D0,.0812974955D0/
      DATA (R(KKK),KKK=49,93)/
     + .1136958501D0,.1459737146D0,.1780968824D0,.2100313105D0,
     + .2417431561D0,.2731988126D0,.3043649444D0,.3352085229D0,
     + .3656968614D0,.3957976498D0,.4254789884D0,.4547094222D0,
     + .4834579739D0,.5116941772D0,.5393881083D0,.5665104186D0,
     + .5930323648D0,.6189258401D0,.6441634037D0,.6687183100D0,
     + .6925645366D0,.7156768123D0,.7380306437D0,.7596023411D0,
     + .7803690438D0,.8003087441D0,.8194003107D0,.8376235112D0,
     + .8549590334D0,.8713885059D0,.8868945174D0,.9014606353D0,
     + .9150714231D0,.9277124567D0,.9393703398D0,.9500327178D0,
     + .9596882914D0,.9683268285D0,.9759391746D0,.9825172636D0,
     + .9880541263D0,.9925439003D0,.9959818430D0,.9983643759D0,
     + .9996895039/
      DATA (W(KKK),KKK=1,48)/ .4679139346D0,.3607615730D0,
     +.1713244924D0,.2491470458D0, .2334925365D0,.2031674267D0,
     +.1600783285D0,.1069393260D0, .0471753364D0,.1279381953D0,
     +.1258374563D0,.1216704729D0, .1155056681D0,.1074442701D0,
     +.0976186521D0,.0861901615D0, .0733464814D0,.0592985849D0,
     +.0442774388D0,.0285313886D0, .0123412298D0,.0647376968D0,
     +.0644661644D0,.0639242386D0, .0631141923D0,.0620394232D0,
     +.0607044392D0,.0591148397D0, .0572772921D0,.0551995037D0,
     +.0528901894D0,.0503590356D0, .0476166585D0,.0446745609D0,
     +.0415450829D0,.0382413511D0, .0347772226D0,.0311672278D0,
     +.0274265097D0,.0235707608D0, .0196161605D0,.0155793157D0,
     +.0114772346D0,.0073275539D0, .0031533461D0,.0325506145D0,
     +.0325161187D0,.0324471637D0/
      DATA (W(KKK),KKK=49,93)/
     + .0323438226D0,.0322062048D0,.0320344562D0,.0318287589D0,
     + .0315893308D0,.0313164256D0,.0310103326D0,.0306713761D0,
     + .0302999154D0,.0298963441D0,.0294610900D0,.0289946142D0,
     + .0284974111D0,.0279700076D0,.0274129627D0,.0268268667D0,
     + .0262123407D0,.0255700360D0,.0249006332D0,.0242048418D0,
     + .0234833991D0,.0227370697D0,.0219666444D0,.0211729399D0,
     + .0203567972D0,.0195190811D0,.0186606796D0,.0177825023D0,
     + .0168854799D0,.0159705629D0,.0150387210D0,.0140909418D0,
     + .0131282296D0,.0121516047D0,.0111621020D0,.0101607705D0,
     + .0091486712D0,.0081268769D0,.0070964708D0,.0060585455D0,
     + .0050142027D0,.0039645543D0,.0029107318D0,.0018539608D0,
     + .0007967921/
C
      DATA TOLABS,TOLREL,NMAX/1.D-35,5.D-5,100/
C
      SSDINT2=0
      NLIMS=2
      XLIMS(1)=XL
      XLIMS(2)=XR
      ICOUNT=0
C
   10 AA=(XLIMS(NLIMS)-XLIMS(NLIMS-1))/2
      BB=(XLIMS(NLIMS)+XLIMS(NLIMS-1))/2
      TVAL=0
      DO 20 I=1,3
   20 TVAL=TVAL+W(I)*(F(BB+AA*R(I))+F(BB-AA*R(I)))
      TVAL=TVAL*AA
      DO 40 J=1,4
        VAL=0
        DO 30 I=PTR(J),PTR(J)-1+NORD(J)
          ICOUNT=ICOUNT+1
          IF(ICOUNT.GT.1E5) THEN
CYG             WRITE(1,*) 'ERROR IN SSDINT2: SET SSDINT2 TO ZERO'
            SSDINT2=0.
            RETURN
          ENDIF
   30   VAL=VAL+W(I)*(F(BB+AA*R(I))+F(BB-AA*R(I)))
        VAL=VAL*AA
        TOL=MAX(TOLABS,TOLREL*ABS(VAL))
        IF(ABS(TVAL-VAL).LT.TOL) THEN
          SSDINT2=SSDINT2+VAL
          NLIMS=NLIMS-2
          IF (NLIMS.NE.0) GO TO 10
          RETURN
        ENDIF
   40 TVAL=VAL
      IF(NMAX.EQ.2) THEN
        SSDINT2=VAL
        RETURN
      END IF
      IF(NLIMS.GT.(NMAX-2)) THEN
CYG         WRITE(1,10000) 'ERROR IN SSDINT2: SSDINT2,NMAX,BB-AA,BB+AA='
CYG      +  ,SSDINT2,NMAX,BB-AA,BB+AA
        RETURN
      ENDIF
      XLIMS(NLIMS+1)=BB
      XLIMS(NLIMS+2)=BB+AA
      XLIMS(NLIMS)=BB
      NLIMS=NLIMS+2
      GO TO 10
C
10000 FORMAT (' SSDINT2 FAILS, SSDINT2,NMAX,XL,XR=',G15.7,I5,2G15.7)
      END

      DOUBLE PRECISION FUNCTION FN(x2)
      IMPLICIT NONE
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------

      DOUBLE PRECISION CLQDFM1,CLQDFM2,CLQDFM3,CLQDFM4,
     +      LSPFM2,LSPFM5,LSPFM1,LSPFM4,LSPFM3,CLLEFM1,CLLEFM2
      EXTERNAL CLQDFM1,CLQDFM2,CLQDFM3,CLQDFM4,
     +      LSPFM2,LSPFM5,LSPFM1,LSPFM4,LSPFM3,CLLEFM1,CLLEFM2

      DOUBLE PRECISION x2
      x(2) = x2
      x(5) = x2

C .. LQD
      IF (fntype.eq.121) then
       fn=LSPFM2()
      ELSEIF (fntype.eq.122) then
       fn=LSPFM5()
      ELSEIF (fntype.eq.221) then
         fn=CLQDFM1()
      ELSEIF (fntype.eq.222) then
         fn=CLQDFM2()
      ELSEIF (fntype.eq.223) then
         fn=CLQDFM3()
      ELSEIF (fntype.eq.224) then
         fn=CLQDFM4()
      ELSEIF
C .. LLE
     +       (fntype.eq.111) then
         fn=LSPFM1()
      ELSEIF (fntype.eq.112) then
         fn=LSPFM4()
      ELSEIF (fntype.eq.211) then
         fn=CLLEFM1()
      ELSEIF (fntype.eq.212) then
         fn=CLLEFM2()
C .. UDD
      ELSEIF (fntype.eq.131) then
         fn=LSPFM3()
      ELSEIF (fntype.eq.132) then
         fn=0.
      ELSE
      stop ' bye in fn      '
      ENDIF
      END


      LOGICAL FUNCTION CPROP_OK()
C ... returns OK if the chargino propagator is virtual
C
      IMPLICIT NONE
      Double Precision k
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------


       CPROP_OK=.TRUE.
       IF (coupl_i(1).eq.1) then
C LLE case
          k=XMSCALELEC(COUPL_I(2))
          k=MIN(XMSCALELEC(COUPL_I(3)),k)
          k=MIN(XMSCALNEUT(COUPL_I(2)),k)
          k=MIN(XMSCALNEUT(COUPL_I(3)),k)
       ELSEIF (coupl_i(1).eq.2) then
C LQD case
          k=XMSCALELEC(COUPL_I(2))
          k=MIN(XMSCALDOWN(COUPL_I(3)),k)
          k=MIN(XMSCALNEUT(COUPL_I(2)),k)
          k=MIN(XMSCALUP(COUPL_I(3)),k)
          k=MIN(XMSCALDOWNR(COUPL_I(4)),k)
       ELSEIF (coupl_i(1).eq.3) then
          write(*,*)  ' stop in cprop_ok - UDD ???? '
       ENDIF

       IF (k.LT.XMCHAR(ICHAR)) THEN
          write (*,*)
     +   ' Warning, R-parity Chargino decay not allowed :'
          write (*,*) '    Operator=',COUPL_I(1)
          write (*,*) '    ijk=',COUPL_I(2),COUPL_I(3),
     +                           COUPL_I(4)
          write (*,*) '    Chargino=',ICHAR, ' MCHAR=',
     +                        XMCHAR(ICHAR)
          write(*,*)  '    M-exchanged-sparticle=',
     +                  k
          CPROP_OK=.FALSE.
       ENDIF

       END


      LOGICAL FUNCTION NPROP_OK()
C ... returns OK if the neutralino propagator is virtual
C
      IMPLICIT NONE
      Double Precision k
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------


       NPROP_OK=.TRUE.

       IF (coupl_i(1).eq.1) then
C LLE case
         k=XMSCALELEC(COUPL_I(2))
         k=MIN(XMSCALNEUT(COUPL_I(3)),k)
         k=MIN(XMSCALELECR(COUPL_I(4)),k)
         k=MIN(XMSCALNEUT(COUPL_I(2)),k)
         K=MIN(XMSCALELEC(COUPL_I(3)),k)
         k=MIN(XMSCALELECR(COUPL_I(4)),k)
       ELSEIF  (coupl_i(1).eq.2) THEN
C LQD case
         k=XMSCALELEC(COUPL_I(2))
         k=MIN(XMSCALUP(COUPL_I(3)),k)
         k=MIN(XMSCALDOWNR(COUPL_I(4)),k)
         k=MIN(XMSCALNEUT(COUPL_I(2)),k)
         k=MIN(XMSCALDOWN(COUPL_I(3)),k)
         k=MIN(XMSCALDOWNR(COUPL_I(4)),k)
       ELSEIF  (coupl_i(1).eq.3) THEN
C UDD case
         k=XMSCALUP(COUPL_I(2))
         k=MIN(XMSCALDOWN(COUPL_I(3)),k)
         k=MIN(XMSCALDOWNR(COUPL_I(3)),k)
       ELSE
          stop ' bye in nprop_ok '
       ENDIF

       IF (k.LT.XMNEU(INEUT)) THEN
          write (*,*)
     +   ' Warning, R-parity Neutralino decay not allowed :'
          write (*,*) '    Operator=',COUPL_I(1)
          write (*,*) '    ijk=',COUPL_I(2),COUPL_I(3),
     +                           COUPL_I(4)
          write (*,*) '    Neutralino=',INEUT, ' MNEU=',
     +                        XMNeu(INEUT)
          write(*,*)  '    M-exchanged-sparticle=',
     +                  k
          NPROP_OK=.FALSE.
       ENDIF

       END

       SUBROUTINE RPARHISTO
C ...  histogram the Rparity decay products
       IMPLICIT NONE
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------

       REAL fn2,fn11,fn12,fn13
       REAL x1,x2
       External fn2,fn11,fn12,fn13
       LOGICAL CPROP_OK
       EXTERNAL CPROP_OK
       integer i,j


       call hbook1(13001,' Rparity Chi-E11',100,0.,100.,0.)
       call hbook1(13002,' Rparity Chi-ct11',100,-1.,1.,0.)
       call hbook1(13003,' Rparity Chi-E12',100,0.,100.,0.)
       call hbook1(13004,' Rparity Chi-ct12',100,-1.,1.,0.)
       call hbook1(13005,' Rparity Chi-E13',100,0.,100.,0.)
       call hbook1(13006,' Rparity Chi-ct13',100,-1.,1.,0.)
*
       call hbook1(13011,' Rparity Chi-E21',100,0.,100.,0.)
       call hbook1(13012,' Rparity Chi-ct21',100,-1.,1.,0.)
       call hbook1(13013,' Rparity Chi-E22',100,0.,100.,0.)
       call hbook1(13014,' Rparity Chi-ct22',100,-1.,1.,0.)
       call hbook1(13015,' Rparity Chi-E23',100,0.,100.,0.)
       call hbook1(13016,' Rparity Chi-ct23',100,-1.,1.,0.)


       IF (COUPL_I(1).EQ.2) THEN
       ICHAR=1
         IF (CPROP_OK()) then

         fntype=221
         call hbfun2(22210,' Chi+ -> nu u dbar Rparity decays in x1/x2',
     +             100,0.,1.,100,0.,1.,fn2)
         fntype=222
         call hbfun2(22220,' Chi+ -> l dbar d Rparity decays in x1/x2',
     +             100,0.,1.,100,0.,1.,fn2)
         fntype=223
         call hbfun2(22230,' Chi+ -> l ubar u Rparity decays in x1/x2',
     +             100,0.,1.,100,0.,1.,fn2)
         fntype=224
         call hbfun2(22240,' Chi+ -> nu dbar u Rparity decays in x1/x2',
     +             100,0.,1.,100,0.,1.,fn2)

***********************************
         fntype=221
       call hbfun1(12211,' Chi+ -> nu u dbar E(nu) spectrum',100,0.,
     +                  SNGL(0.5*XMCHAR(ICHAR)),fn11)
       call hbfun1(12212,' Chi+ -> nu u dbar E(u) spectrum',100,0.,
     +                  SNGL(0.5*XMCHAR(ICHAR)),fn12)
         call hbook1(12213,' Chi+ -> nu u dbar E(dbar) spectrum',100,0.,
     +                  SNGL(0.5*XMCHAR(ICHAR)),0.)
       DO i=1,500
          DO j=1,500
            x1=real(i)/500.
            x2=real(j)/500.
            call hf1(12213,SNGL(0.5*(2.-x1-x2)*XMCHAR(ICHAR)),
     +                        (fn2(x1,x2)))
          ENDDO
       ENDDO

***********************************
         fntype=222
       call hbfun1(12221,' Chi+ -> l dbar d E(l) spectrum',100,0.,
     +                  SNGL(0.5*XMCHAR(ICHAR)),fn11)
       call hbfun1(12222,' Chi+ -> l dbar d E(dbar) spectrum',100,0.,
     +                  SNGL(0.5*XMCHAR(ICHAR)),fn12)
         call hbook1(12223,' Chi+ -> l dbar d E(d) spectrum',100,0.,
     +                  SNGL(0.5*XMCHAR(ICHAR)),0.)
       DO i=1,500
          DO j=1,500
            x1=real(i)/500.
            x2=real(j)/500.
            call hf1(12223,SNGL(0.5*(2.-x1-x2)*XMCHAR(ICHAR)),fn2(x1,x2)
     +           )
          ENDDO
       ENDDO
***********************************
         fntype=223
       call hbfun1(12231,' Chi+ -> l ubar u E(l) spectrum',100,0.,
     +                  SNGL(0.5*XMCHAR(ICHAR)),fn11)
       call hbfun1(12232,' Chi+ -> l ubar u E(ubar) spectrum',100,0.,
     +                  SNGL(0.5*XMCHAR(ICHAR)),fn12)
         call hbook1(12233,' Chi+ -> l ubar u E(u) spectrum',100,0.,
     +                  SNGL(0.5*XMCHAR(ICHAR)),0.)
       DO i=1,500
          DO j=1,500
            x1=real(i)/500.
            x2=real(j)/500.
            call hf1(12233,SNGL(0.5*(2.-x1-x2)*XMCHAR(ICHAR)),fn2(x1,x2)
     +           )
          ENDDO
       ENDDO
***********************************
         fntype=224
       call hbfun1(12241,' Chi+ -> nu dbar u E(nu) spectrum',100,0.,
     +                  SNGL(0.5*XMCHAR(ICHAR)),fn11)
       call hbfun1(12242,' Chi+ -> nu dbar u E(dbar) spectrum',100,0.,
     +                  SNGL(0.5*XMCHAR(ICHAR)),fn12)
         call hbook1(12243,' Chi+ -> nu dbar u E(u) spectrum',100,0.,
     +                  SNGL(0.5*XMCHAR(ICHAR)),0.)
       DO i=1,500
          DO j=1,500
              x1=real(i)/500.
            x2=real(j)/500.
         call hf1(12243,SNGL(0.5*(2.-x1-x2)*XMCHAR(ICHAR)),fn2(x1,x2))
          ENDDO
       ENDDO


       ENDIF ! CPROP_OK
       ELSE
        write (*,*)
     + 'RPARHISTO: Warning: UDD,LLE Chargino histos not yet implemented'
       ENDIF

       call hrput(0,'rparity.his','n')
       write (*,*) ' Rparity calc done ...'
       END


       REAL FUNCTION fn2(x1,x2)
       IMPLICIT NONE
       real x1,x2
        double precision CLQDFM1,CLQDFM2,CLQDFM3,CLQDFM4,LSPFM2,LSPFM5,
     +           CLLEFM1,CLLEFM2,LSPFM1,LSPFM4,LSPFM3
      EXTERNAL CLQDFM1,CLQDFM2,CLQDFM3,CLQDFM4,LSPFM2,LSPFM5,
     +           CLLEFM1,CLLEFM2,LSPFM1,LSPFM4,LSPFM3
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------

       real fml1,fml2,fml3,fmi

       x(1)=x1
       x(2)=x2
       x(4)=x1
       x(5)=x2

C ... LQD
       IF (fntype.eq.121) then
          CALL LSPCPL
          CALL PSPXMS
        fn2=SNGL(LSPFM2())
       ELSEIF (fntype.eq.122) then
          CALL LSPCPL
          CALL PSPXMS
        fn2=SNGL(LSPFM5())
       ELSEIF (fntype.eq.221) then
          CALL CLSPCPL(1)
          CALL CPSPXMS(1)
          fn2=SNGL(CLQDFM1())
       ELSEIF (fntype.eq.222) then
          CALL CLSPCPL(2)
          CALL CPSPXMS(2)
        fn2=SNGL(CLQDFM2())
       ELSEIF (fntype.eq.223) then
          CALL CLSPCPL(3)
          CALL CPSPXMS(3)
        fn2=SNGL(CLQDFM3())
       ELSEIF (fntype.eq.224) then
          CALL CLSPCPL(4)
          CALL CPSPXMS(4)
        fn2=SNGL(CLQDFM4())
C ... LLE
       ELSEIF (fntype.eq.111) then
          CALL LSPCPL
          CALL PSPXMS
        fn2=SNGL(LSPFM1())
       ELSEIF (fntype.eq.112) then
          CALL LSPCPL
          CALL PSPXMS
        fn2=SNGL(LSPFM4())
       ELSEIF (fntype.eq.211) then
          CALL CLSPCPL(1)
          CALL CPSPXMS(1)
          fn2=SNGL(CLLEFM1())
       ELSEIF (fntype.eq.212) then
          CALL CLSPCPL(2)
          CALL CPSPXMS(2)
          fn2=SNGL(CLLEFM2())
C ...  UDD
       ELSEIF (fntype.eq.131) then
          CALL LSPCPL
          CALL PSPXMS
          fn2=LSPFM3()
       ELSEIF (fntype.eq.132) then
          fn2=0.
       ELSE
       stop 'fatal in fn2'
       ENDIF

       if (fn2.lt.0.) fn2=0.

       END


       REAL FUNCTION fn11(x1)
       IMPLICIT NONE
       real x1
       double precision CLQDFM1,CLQDFM2,CLQDFM3,CLQDFM4,sum
       EXTERNAL CLQDFM1,CLQDFM2,CLQDFM3,CLQDFM4
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------


       INTEGER i

       x(1)=2.*x1/XMCHAR(ICHAR)
       sum=0.

       DO i=1,500
         x(2)=real(i)/500.

         IF (fntype.eq.221) then
            CALL CLSPCPL(1)
            CALL CPSPXMS(1)
            sum=sum+(CLQDFM1())
         ELSEIF (fntype.eq.222) then
            CALL CLSPCPL(2)
            CALL CPSPXMS(2)
            sum=sum+(CLQDFM2())
         ELSEIF (fntype.eq.223) then
            CALL CLSPCPL(3)
            CALL CPSPXMS(3)
            sum=sum+(CLQDFM3())
         ELSEIF (fntype.eq.224) then
            CALL CLSPCPL(4)
            CALL CPSPXMS(4)
            sum=sum+(CLQDFM4())
         ELSE
         stop ' bye in fn11'
         ENDIF
       ENDDO
       fn11=sngl(sum)
       END


       REAL FUNCTION fn12(x1)
       IMPLICIT NONE
       real x1
       double precision CLQDFM1,CLQDFM2,CLQDFM3,CLQDFM4,sum
       EXTERNAL CLQDFM1,CLQDFM2,CLQDFM3,CLQDFM4
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------


       INTEGER i

       x(2)=2.*x1/XMCHAR(ICHAR)
       sum=0.

       DO i=1,500
         x(1)=real(i)/500.

         IF (fntype.eq.221) then
            CALL CLSPCPL(1)
            CALL CPSPXMS(1)
            sum=sum+(CLQDFM1())
         ELSEIF (fntype.eq.222) then
            CALL CLSPCPL(2)
            CALL CPSPXMS(2)
            sum=sum+(CLQDFM2())
         ELSEIF (fntype.eq.223) then
            CALL CLSPCPL(3)
            CALL CPSPXMS(3)
            sum=sum+(CLQDFM3())
         ELSEIF (fntype.eq.224) then
            CALL CLSPCPL(4)
            CALL CPSPXMS(4)
            sum=sum+(CLQDFM4())
         ELSE
         stop ' bye in fn12'
         ENDIF
       ENDDO
       fn12=sngl(sum)
       END


      LOGICAL FUNCTION clims_ok()
      IMPLICIT NONE
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------


      DOUBLE PRECISION x1_min,x1_max,x2_min,x2_max,C1,C2,C3,lspps
      EXTERNAL LSPPS

C ..  first check that x is within limits
      clims_ok=.FALSE.
      IF ((fntype.eq.122).or.(fntype.eq.112)) then
         x1_min=2.0*SQRT(XMU(4))
         x1_max=1.0 + XMU(4) - XMU(5) - XMU(6) - 2.*SQRT(xmu(5)*xmu(6))
         IF ((x(4).lt.x1_min).or.(x(4).gt.x1_max)) RETURN
         C1= 1.-X(4)+XMU(4)
         C2= (2.-X(4)) * (1. + XMU(4) + XMU(5)-XMU(6)-X(4))
         C3= ((X(4)**2-4.*XMU(4)) * LSPPS( C1,XMU(5),XMU(6)))
      ELSE
         x1_min=2.0*SQRT(XMU(1))
         x1_max=1.0 + XMU(1) - XMU(2) - XMU(3) - 2.*SQRT(xmu(2)*xmu(3))
         IF ((x(1).lt.x1_min).or.(x(1).gt.x1_max)) RETURN
         C1= 1.-X(1)+XMU(1)
         C2= (2.-X(1)) * (1. + XMU(1) + XMU(2)-XMU(3)-X(1))
         C3= ((X(1)**2-4.*XMU(1)) * LSPPS( C1,XMU(2),XMU(3)))
      ENDIF

      IF (C3.LT.0.0) THEN
        IF (C3.GT.-10E-10) THEN
C          IT'S A ROUNDING ERROR
         write (*,*) ' Warning, rounding error in clim_ok'
           C3 = 0.0
        ELSE
           STOP ' Arithm. error in clim_ok C3='
        ENDIF
      ENDIF
      C3=SQRT(C3)
      x2_min=0.5/ C1* ( C2 - C3 )
      x2_max=0.5/ C1* ( C2 + C3 )
      IF ((fntype.eq.122).or.(fntype.eq.112)) then
         IF ((x(5).lt.x2_min).or.(x(5).gt.x2_max)) RETURN
       IF ((x(4)+x(5)).gt.2.) RETURN
      ELSE
         IF ((x(2).lt.x2_min).or.(x(2).gt.x2_max)) RETURN
       IF ((x(1)+x(2)).gt.2.) RETURN
      ENDIF
      clims_ok=.TRUE.
      END


        DOUBLE PRECISION FUNCTION TINT(XL, FCT, XU)
        IMPLICIT NONE

        DOUBLE PRECISION XL, XU, AI, BI, C, FCT, Y
        EXTERNAL FCT

        AI = 0.5D0*(XU+XL)
        BI = XU-XL
        IF(BI.LE.0.0)Y = 0
C
C Put a flag here for BI < 0.0
C
        TINT=0.
        IF(BI.LE.0.0)RETURN
        C = 0.49863193092474078D0 * BI
        Y  =    0.35093050047350483D-2 * (FCT(AI+C) +FCT(AI-C))
        C = 0.49280575577263417D0 * BI
        Y =  Y+ 0.81371973654528350D-2 * (FCT(AI+C) +FCT(AI-C))
        C = 0.48238112779375322D0 * BI
        Y  = Y +0.12696032654631030D-1 * (FCT(AI+C) +FCT(AI-C))
        C = 0.46745303796886984D0 * BI
        Y  = Y +0.17136931456510717D-1 * (FCT(AI+C) +FCT(AI-C))
        C = 0.44816057788302606D0 * BI
        Y  = Y +0.21417949011113340D-1 * (FCT(AI+C) +FCT(AI-C))
        C = 0.42468380686628499D0 * BI
        Y  = Y +0.25499029631188088D-1 * (FCT(AI+C) +FCT(AI-C))
        C = 0.39724189798397120D0 * BI
        Y  = Y +0.29342046739267774D-1 * (FCT(AI+C) +FCT(AI-C))
        C = 0.36609105937014484D0 * BI
        Y  = Y+ 0.32911111388180923D-1 * (FCT(AI+C) +FCT(AI-C))
        C = 0.33152213346510760D0 * BI
        Y  = Y +0.36172897054424253D-1 * (FCT(AI+C) +FCT(AI-C))
        C = 0.29385787862038116D0 * BI
        Y = Y + 0.39096947893535153D-1 * (FCT(AI+C) +FCT(AI-C))
        C = 0.25344995446611470D0 * BI
        Y  = Y +0.41655962113473378D-1 * (FCT(AI+C) +FCT(AI-C))
        C = 0.21067563806531767D0 * BI
        Y  = Y +0.43826046502201906D-1 * (FCT(AI+C) +FCT(AI-C))
        C = 0.16593430114106382D0 * BI
        Y  = Y +0.45586939347881942D-1 * (FCT(AI+C) +FCT(AI-C))
        C = 0.11964368112606854D0 * BI
        Y  = Y +0.46922199540402283D-1 * (FCT(AI+C) +FCT(AI-C))
        C = 0.7223598079139825D-1 * BI
        Y  =  Y+0.47819360039637430D-1 * (FCT(AI+C) +FCT(AI-C))
        C = 0.24153832843869158D-1 * BI
        Y =BI * ( Y + 0.48270044257363900D-1 * (FCT(AI+C)+FCT(AI-C)))
        TINT=Y

        RETURN
        END



        DOUBLE PRECISION FUNCTION TINT2(XL, FCT, XU)
        IMPLICIT NONE

        DOUBLE PRECISION XL, XU, AI, BI, C, FCT, Y
        EXTERNAL FCT

        AI = 0.5D0*(XU+XL)
        BI = XU-XL
        IF(BI.LE.0.0)Y = 0
C
C Put a flag here for BI < 0.0
C
        TINT2=0.
        IF(BI.LE.0.0)RETURN
        C = 0.49863193092474078D0 * BI
        Y  =    0.35093050047350483D-2 * (FCT(AI+C) +FCT(AI-C))
        C = 0.49280575577263417D0 * BI
        Y =  Y+ 0.81371973654528350D-2 * (FCT(AI+C) +FCT(AI-C))
        C = 0.48238112779375322D0 * BI
        Y  = Y +0.12696032654631030D-1 * (FCT(AI+C) +FCT(AI-C))
        C = 0.46745303796886984D0 * BI
        Y  = Y +0.17136931456510717D-1 * (FCT(AI+C) +FCT(AI-C))
        C = 0.44816057788302606D0 * BI
        Y  = Y +0.21417949011113340D-1 * (FCT(AI+C) +FCT(AI-C))
        C = 0.42468380686628499D0 * BI
        Y  = Y +0.25499029631188088D-1 * (FCT(AI+C) +FCT(AI-C))
        C = 0.39724189798397120D0 * BI
        Y  = Y +0.29342046739267774D-1 * (FCT(AI+C) +FCT(AI-C))
        C = 0.36609105937014484D0 * BI
        Y  = Y+ 0.32911111388180923D-1 * (FCT(AI+C) +FCT(AI-C))
        C = 0.33152213346510760D0 * BI
        Y  = Y +0.36172897054424253D-1 * (FCT(AI+C) +FCT(AI-C))
        C = 0.29385787862038116D0 * BI
        Y = Y + 0.39096947893535153D-1 * (FCT(AI+C) +FCT(AI-C))
        C = 0.25344995446611470D0 * BI
        Y  = Y +0.41655962113473378D-1 * (FCT(AI+C) +FCT(AI-C))
        C = 0.21067563806531767D0 * BI
        Y  = Y +0.43826046502201906D-1 * (FCT(AI+C) +FCT(AI-C))
        C = 0.16593430114106382D0 * BI
        Y  = Y +0.45586939347881942D-1 * (FCT(AI+C) +FCT(AI-C))
        C = 0.11964368112606854D0 * BI
        Y  = Y +0.46922199540402283D-1 * (FCT(AI+C) +FCT(AI-C))
        C = 0.7223598079139825D-1 * BI
        Y  =  Y+0.47819360039637430D-1 * (FCT(AI+C) +FCT(AI-C))
        C = 0.24153832843869158D-1 * BI
        Y =BI * ( Y + 0.48270044257363900D-1 * (FCT(AI+C)+FCT(AI-C)))
        TINT2=Y

        RETURN
        END



      Logical Function kine_ok(NEUCHA)
      IMplicit none
      integer neucha
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------


      kine_ok=.true.
      IF (neucha.eq.2) then
         IF (XMCHAR(ICHAR).lt.(XM(1)+XM(2)+XM(3))) then
            write (*,*) ' Warning, R-parity decay Mcharg ',
     +            ICHAR,' diagram ',fntype,' kinem. not allowed'
            write (*,*) ' Mcha=',XMCHAR(ICHAR),' < ',
     +         ' SumM(f.s.parts)=',
     +             (XM(1)+XM(2)+XM(3))
            kine_ok=.false.
         ENDIF
        ELSEIF (neucha.eq.1) then
         IF (XMNEU(INEUT).lt.(XM(1)+XM(2)+XM(3))) THEN
            write (*,*) ' Warning, R-parity decay Mneut ',
     +            INEUT,' diagram ',fntype,' kinem. not allowed'
            write (*,*) ' Mneut=',XMNEU(INEUT),' < ',
     +         ' SumM(f.s.parts)=',
     +             (XM(1)+XM(2)+XM(3))
            kine_ok=.false.
         ENDIF
      ELSE
        stop 'fatal in kine_ok      '
      ENDIF

      END


      SUBROUTINE mkrparh(HID,gaugino,diagram,
     +            nbin1,nbin2)
      IMPLICIT NONE
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------

      INTEGER HID,gaugino,diagram,nbin1,nbin2,proc
      REAL dummy,fn2,xlims(4)
      EXTERNAL fn2
      CHARACTER*80 htit

      IF (gaugino.le.4) then
            INEUT=gaugino
         fntype=Coupl_i(1)*10+100+(((diagram-1)/2) + 1)
           proc=100+Coupl_i(1)*10+diagram+10000*Ineut
      ELSE
            ICHAR=gaugino-4
         fntype=Coupl_i(1)*10+200+diagram
           proc=200+Coupl_i(1)*10+diagram+10000*ICHAR
      ENDIF

      xlims(1)=0.
      xlims(2)=2.
      xlims(3)=0.
      xlims(4)=2.

      write (htit,*) 'Rparity diagram =',fntype,' Process=',proc

        call hbfun2(HID,htit,nbin1,xlims(1),xlims(2) ,nbin2,
     +      xlims(3),xlims(4),fn2)

      end


C   the following routines only used for debugging the generator

      SUBROUTINE tmkrparh(HID,gaugino,diagram,
     +            nbin1,nbin2)
      IMPLICIT NONE
C ------------------------------------------------------------
C             Rparity violation common
C ------------------------------------------------------------
C  Rparity violating SUSY parameters
      REAL RBOD_G,rbod2_g,rbod4_m
      LOGICAL RBOD,rbod2,rbod3,rbod4
      common /rbod1/ RBOD , RBOD2
      common /rbod2/ RBOD_G(4),RBOD2_G(4)
      common /rbod3/ rbod3
      common /rbod4/ rbod4
      common /rbod4m/ rbod4_m(2)

        DOUBLE PRECISION XLAM
        DOUBLE PRECISION TANTHW,SIN2THW,XMU,
     +                   XMSCALDOWN

C ...   masses / SM + Left Scalar sector
        DOUBLE PRECISION XMDOWN,XMUP,XMELEC,XMW,
     +                   XMSCALUP
        DOUBLE PRECISION XMSCALELEC,XMSCALNEUT

C ...   masses / Right Scalar sector
        DOUBLE PRECISION XMSCALELECR
        DOUBLE PRECISION XMSCALUPR,XMSCALDOWNR


        DOUBLE PRECISION A,B,XMUTILDE
        DOUBLE PRECISION X

        DOUBLE PRECISION PPP

        DOUBLE PRECISION XM,XMTILDE
        DOUBLE PRECISION G
        DOUBLE PRECISION Dpi

        INtEGER INEUT,ICHAR
        DOUBLE PRECISION XMNEU,XMCHAR,ETACHAR

        DOUBLE PRECISION N_GH

      INTEGER fntype


        PARAMETER (Dpi = 3.14159)

        COMMON/SUSY/TANTHW,SIN2THW
        COMMON/MASS1/XMELEC(3),XMUP(3),XMDOWN(3)
        COMMON/MASS2/XMW
        COMMON/MASS3/XMU(6)
        COMMON/MASS4/XMSCALELEC(3),XMSCALNEUT(3),
     +               XMSCALDOWN(3),XMSCALUP(3),
     +               XMSCALELECR(3),
     +               XMSCALUPR(3),XMSCALDOWNR(3)

        COMMON/MASS5/XMUTILDE(6)
        COMMON/COUPLS/A(6),B(6)

        COMMON/INTVAR/X(6)
        COMMON/DOTPROD/PPP(0:6,0:6)
        COMMON/LAMDA/ XLAM
        COMMON/MASSEIGEN/ XM(6),XMTILDE(6)
        COMMON/FERMIG/ G

        COMMON/TMPCOM/ XMNEU(4),XMCHAR(2),ETACHAR(2),INEUT,ICHAR

        COMMON/GHCPL/ N_GH(4,4)

        COMMON/RpaMat/ fntype

        INTEGER COUPL_I
        COMMON/LSPCARDS/  Coupl_i(4)

      DOUBLE PRECISION cgamma, ngamma, cgamma_tot,
     +                   ngamma_tot
           COMMON/RpaGam/ cgamma(2,4), ngamma(4,4), cgamma_tot(2),
     +                   ngamma_tot(4)


C and the variables for the direct slepton 2body decays
      Double Precision brspa_rpv,rparsletondecaymatrix
        Common/sparrpv/ brspa_rpv(24),
     +                    rparsletondecaymatrix(24,2)
C-------------------------------------------------------------

      INTEGER HID,gaugino,diagram,nbin1,nbin2
      REAL dummy,fn2,xlims(4)
      EXTERNAL fn2
      CHARACTER*80 htit

      IF (gaugino.le.4) then
            INEUT=gaugino
         fntype=Coupl_i(1)*10+100+(((diagram-1)/2) + 1)
      ELSE
            ICHAR=gaugino-4
         fntype=Coupl_i(1)*10+200+diagram
      ENDIF

      xlims(1)=0.
      xlims(2)=2.
      xlims(3)=0.
      xlims(4)=2.

      write (htit,*) 'Rparity diagram =',fntype

*jvw        call fn2(1.046858 ,1.010813    )
      dummy=fn2(1.046858 ,1.010813    )
C     call hbfun2(HID,htit,nbin1,xlims(1),xlims(2) ,nbin2,
C     +      xlims(3),xlims(4),fn2)

      end


        subroutine prtlims(x1,x2,fmi,
     +          fml1,fml2,fml3)
C --- work out limits on x1,x2 given their masses,mchi+x1..x3
      implicit none
      real x1,x2,fmi,
     +          fml1,fml2,fml3

         real x3, xl1,xu1,xl2,xu2,t1,t2,t3,lspps1
         external lspps1
       real m1,m2,m3

         m1=(fml1/fmi)**2
         m2=(fml2/fmi)**2
         m3=(fml3/fmi)**2
       x3=2.-x1-x2

       xl1=2.*SQRT(m1)
         xu1=1.+m1-m2-m3-
     +       2.*SQRT(m2*m3)

       t1=sqrt(x1**2-4.*m1)*
     +      SQRT(lspps1((1.+m1-x1),
     +      m2,m3))
         xl2=0.5/(1.-x1+m1)*(
     +     (2.-x1)*(1.+m1+m2-m3-x1)-t1)
         xu2=0.5/(1.-x1+m1)*(
     +     (2.-x1)*(1.+m1+m2-m3-x1)+t1)

        write (*,*) ' xl/x/xu 1',xl1,x1,xu1
        write (*,*) ' xl/x/xu 2',xl2,x2,xu2

       end

      DOUBLE PRECISION FUNCTION LSPPS1(W1,W2,W3)
C   Author: H.Dreiner and P.Morawitz
        IMPLICIT NONE

      real W1,W2,W3

      LSPPS1= W1**2+ W2**2+ W3**2- 2*(W1*W2+ W1*W3+ W2*W3)

      RETURN
      END



C ------------------------------------------------------------
C             FSR interface
C ------------------------------------------------------------
C     --- Final state radiation interface -----------
C     --- Uses Photos package
C     --- The interface just makes Photos deal with SUSY particles

C     Authors: Dirk Zerwas April 96
C     Mods :   Peter Morawitz. Make Photos deal with event trees
C     .        properly.

      SUBROUTINE PHOCHK(JFIRST)
C ... Note - Routine absolutely necessary, otherwise PHOTOS does
C     not recognise SUSY particles, and won't produce FSR !!!!      
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
C.   allow also SUSY particles for SUSYGEN
C.                                    Dirk Zerwas              16/05/96
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
      INTEGER IDENT,K,ifi
      data ifi /0/
C these are OK .... if you do not like somebody else, add here.
C      F(IDABS)=
C     &     ( ((IDABS.GT.9).AND.(IDABS.LE.40)) .OR. (IDABS.GT.100) )
C     & .AND.(IDABS.NE.21)
C     $ .AND.(IDABS.NE.2101).AND.(IDABS.NE.3101).AND.(IDABS.NE.3201)
C     & .AND.(IDABS.NE.1103).AND.(IDABS.NE.2103).AND.(IDABS.NE.2203)
C     & .AND.(IDABS.NE.3103).AND.(IDABS.NE.3203).AND.(IDABS.NE.3303)
C
C... take SUSY into account
C
      F(IDABS)=
     &     ( ((IDABS.GT.9).AND.(IDABS.LE.78)) .OR. (IDABS.GT.100) )
     & .AND.(IDABS.NE.21)
     $ .AND.(IDABS.NE.2101).AND.(IDABS.NE.3101).AND.(IDABS.NE.3201)
     & .AND.(IDABS.NE.1103).AND.(IDABS.NE.2103).AND.(IDABS.NE.2203)
     & .AND.(IDABS.NE.3103).AND.(IDABS.NE.3203).AND.(IDABS.NE.3303)
C...
      if ( ifi.le.0) then
       write (6,*) '++++++ this is the modified version of phochk',
     $    ' to be used with mssm02 ++++++++'
       ifi = 1
      endif
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
C.  tabulate also charge of SUSY,SUSYGEN scheme
C.                        Dirk Zerwas                          16/05/96
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      REAL PHOCHA
      INTEGER IDHEP,IDABS,Q1,Q2,Q3
C--
C--   Array 'CHARGE' contains the charge  of the first 101 particles ac-
C--   cording  to  the PDG particle code... (0 is added for convenience)
      REAL CHARGE(0:100)
C     DATA CHARGE/ 0.,
C    &-0.3333333333,  0.6666666667, -0.3333333333, 0.6666666667,
C    &-0.3333333333,  0.6666666667, -0.3333333333, 0.6666666667,
C    & 2*0., -1., 0., -1., 0., -1., 0., -1., 6*0., 1., 12*0., 1., 63*0./
      INTEGER ifi
      data ifi /0/
      if ( ifi.le.0) then
       write (6,*) '+++++++ this is the modified version of phocha',
     $    ' to be used with mssm02 ++++++++'
       ifi = 1
      endif
C
C... TAKE SUSY INTO ACCOUNT 16/05/96
C
      DATA CHARGE/ 0.,
     &-0.3333333333,  0.6666666667, -0.3333333333, 0.6666666667,
     &-0.3333333333,  0.6666666667, -0.3333333333, 0.6666666667,
     & 2*0., -1., 0., -1., 0., -1., 0., -1., 6*0., 1., 12*0., 1.,
     & 3*0.,
     &-0.3333333333,  0.6666666667, -0.3333333333, 0.6666666667,
     &-0.3333333333,  0.6666666667, -0.3333333333,  0.6666666667,
     &-0.3333333333,  0.6666666667,
     &-1., 0.,-1., 0., -1., 0., -1., -1., -1., 0.,
     &-0.3333333333,  0.6666666667,-0.3333333333,  0.6666666667,
     &-1.,-0.3333333333,  0.6666666667, -1.,
     & 0., 0.,4*0.,2*1.,2*-1.,22*0./
C...
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
C.  tabulate also spin of SUSY for SUSYGEN
C.                        Dirk Zerwas                          16/05/96
C.----------------------------------------------------------------------
C--   IMPLICIT NONE
      REAL PHOSPI
      INTEGER IDHEP,IDABS,ifi
C--
C--   Array 'SPIN' contains the spin  of  the first 100 particles accor-
C--   ding to the PDG particle code...
      REAL SPIN(100)
C     DATA SPIN/ 8*.5, 1., 0., 8*.5, 2*0., 4*1., 76*0./
C
C... take SUSY into account 16/05/96
C
      DATA SPIN/ 8*.5, 1., 0., 8*.5, 2*0., 4*1., 16*0.,
     & 29*0.,9*.5,
     & 22*0./
      data ifi /0/
      if ( ifi.le.0) then
       write (6,*) '+++++++ this is the modified version of phospi',
     $    ' to be used with mssm02 ++++++++'
       ifi = 1
      endif
C...
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


      Subroutine Finrad_new(nbod,Pmoth,Idmoth,Nmoth,P1,IdP1,P2,IdP2,P3
     +     ,IdP3)
      implicit none
C     final state QED radiation for leptons
C     the resulting FSR photons are stored in the common
C     FPHOTONS with pointers to their mothers.

      integer frad
      common /fsr/ frad

      integer ifsrph
      real*8  pfsrphot
      integer imothfsr

      common /FPHOTONS/ pfsrphot(5,100),imothfsr(100),ifsrph

C...
C... HEPEVTCOMMON
C...
      INTEGER NMXHEP,NEVHEP,NHEP,ISTHEP,IDHEP,JMOHEP,JDAHEP
      REAL PHEP,VHEP
C
      PARAMETER (NMXHEP=2000)
      COMMON /HEPEVT/NEVHEP,NHEP,ISTHEP(NMXHEP),IDHEP(NMXHEP),
     &JMOHEP(2,NMXHEP),JDAHEP(2,NMXHEP),PHEP(5,NMXHEP),VHEP(4,NMXHEP)

      LOGICAL QEDRAD
      COMMON/PHOQED/QEDRAD(NMXHEP)

      integer nbod,Nmoth,Idmoth,idp1,idp2,idp3
      real*8 Pmoth(5),P1(5),P2(5),P3(5)

      Logical First
      data first /.true./
      save first

      integer i,k,imod

      real ZQVAR(5),tmp
      integer ilmoth

      integer ipart
      CHARACTER*16 PNAME

      REAL PHOCHA,PHOSPI,cha,spi
      EXTERNAL PHOCHA,PHOSPI

      integer ievent
      common /eve/ ievent
      
      if (first) then
        CALL PHOINI
        WRITE(6,*)'FINAL STATE RADIATION VIA PHOTOS'
        WRITE(6,*)'THE FOLLOWING PARAMETERS FOR SUSY ARE USED:'
        WRITE(6,*)' '
        WRITE(6,*)'LUND PARTICLE  CHARGE  SPIN'
        WRITE(6,*)'==========================='
        DO IPART=41,59,1
          CALL LUNAME(IPART,PNAME)
          cha = PHOCHA(IPART)
          spi = PHOSPI(IPART) 
          WRITE(6,100)IPART,PNAME,cha,spi 
        ENDDO
        DO IPART=61,68,1
          CALL LUNAME(IPART,PNAME)
          WRITE(6,100)IPART,PNAME,PHOCHA(IPART),PHOSPI(IPART)
        ENDDO
        DO IPART=70,78,1
          CALL LUNAME(IPART,PNAME)
          WRITE(6,100)IPART,PNAME,PHOCHA(IPART),PHOSPI(IPART)
        ENDDO
 100    FORMAT(1X,I2,3X,A10,F5.2,2X,F4.1)
        first=.false.
      ENDIF


C ... transfer the particles to the HEPEVT record
      NEVHEP=ievent

      NHEP=1
      ISTHEP(NHEP)=2
      IDHEP(NHEP)=idmoth
      JMOHEP(1,NHEP)=0
      JMOHEP(2,NHEP)=0
      JDAHEP(1,NHEP)=2
      JDAHEP(2,NHEP)=2+nbod-1
      Do i=1,5
         PHEP(i,NHEP)=Pmoth(i)
         VHEP(min(i,4),NHEP)=0.
      Enddo

      NHEP=2
      ISTHEP(NHEP)=1
      IDHEP(NHEP)=idp1
      JMOHEP(1,NHEP)=1
      JMOHEP(2,NHEP)=0
      JDAHEP(1,NHEP)=0
      JDAHEP(2,NHEP)=0
      Do i=1,5
         PHEP(i,NHEP)=P1(i)
         VHEP(min(i,4),NHEP)=0.
      Enddo

      NHEP=3
      ISTHEP(NHEP)=1
      IDHEP(NHEP)=idp2
      JMOHEP(1,NHEP)=1
      JMOHEP(2,NHEP)=0
      JDAHEP(1,NHEP)=0
      JDAHEP(2,NHEP)=0
      Do i=1,5
         PHEP(i,NHEP)=P2(i)
         VHEP(min(i,4),NHEP)=0.
      Enddo

      if (nbod.eq.3) then
      NHEP=4
      ISTHEP(NHEP)=1
      IDHEP(NHEP)=idp3
      JMOHEP(1,NHEP)=1
      JMOHEP(2,NHEP)=0
      JDAHEP(1,NHEP)=0
      JDAHEP(2,NHEP)=0
      Do i=1,5
         PHEP(i,NHEP)=P3(i)
         VHEP(min(i,4),NHEP)=0.
      Enddo
      Endif

C... NOTE: only emit QED radiation from leptons in the final state.
C...       the QED quark radiation is already dealt with by JETSET
      DO IPART=1,NHEP,1
         IF ((((ABS(IDHEP(IPART)).eq.11).or.(ABS(IDHEP(IPART)).eq.13))
     +        .or.(ABS(IDHEP(IPART)).eq.15)).and.JDAHEP(1,IPART).EQ.0)
     +        THEN
            QEDRAD(IPART)=.TRUE.
         ELSE
            QEDRAD(IPART)=.FALSE.
         ENDIF
      ENDDO

C ... and do FSR
      CALL PHOCAL(imod)

      if (imod.gt.0) then
C ...    we had some FSR photons. get them from the HEPEVT record and
C        store them in the common FPHOTONS
         do k=nbod+2,NHEP
            if ((ISTHEP(k).eq.1).and.(IDHEP(k).eq.22)) then
               ifsrph=ifsrph+1
               do i=1,5
                  pfsrphot(i,ifsrph)=PHEP(i,k)
               enddo
               imothfsr(ifsrph)=NMOTH

C     ...      and do some histogramming
               CALL VZERO(ZQVAR,5)
               ILMOTH = JMOHEP(1,k)
               ZQVAR(1) = PHEP(4,k)
               ZQVAR(2) = FLOAT(IDHEP(ILMOTH))
               ZQVAR(3) = PHOCHA(IDHEP(ILMOTH))
               TMP = PHEP(1,ILMOTH)**2+PHEP(2,ILMOTH)**2+PHEP(3,ILMOTH)
     +              **2
               TMP = PHEP(4,ILMOTH)**2 - TMP
               IF (TMP.GE.0.) THEN
                  TMP = SQRT(TMP)
               ELSE
                  TMP = SQRT(-TMP)
               ENDIF
               ZQVAR(4) = TMP
               ZQVAR(5) = FLOAT(ievent)
               CALL HFN(5010,ZQVAR)
            else
               write (*,*)
     +              ' Finrad found strange particle, not a gamma => ID='
     +              ,IDHEP(k),' ISTHEP=',ISTHEP(k)
               stop
            endif
         enddo

C     ... and modify the original daughter particles after FSR
         Do i=1,5
            P1(i)=PHEP(i,2)
            P2(i)=PHEP(i,3)
            if (nbod.eq.3) P3(i)=PHEP(i,4)
         Enddo

      endif

C ... that's it
      NHEP=0

      END

C*DK PHOCAL
      SUBROUTINE PHOCAL(IMOD)
C-----------------------------------------------------------
C...Purpose: call photos and check if any extra photon added
C     comdecks referenced : HEPEVT
C-----------------------------------------------------------
C*CA HEPEVT
      PARAMETER (NMXHEP=2000)
      COMMON/HEPEVT/NEVHEP,NHEP,ISTHEP(NMXHEP),IDHEP(NMXHEP),
     &JMOHEP(2,NMXHEP),JDAHEP(2,NMXHEP),PHEP(5,NMXHEP),VHEP(4,NMXHEP)
      SAVE /HEPEVT/
C*CC HEPEVT
      IMOD = 0
      NHEPI = NHEP
      CALL PHOTOS(1)
      NHEPF = NHEP
      IMOD=NHEPF-NHEPI
      RETURN
      END