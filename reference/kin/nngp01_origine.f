*
*  mods for Linux compiler
*  -common /VETO/ renamed to /cVETO/
*  -call fillmom with argument NOUTGOINGB as NOUTGOING is in /integra/
*  -common/kinevt/cevent(24),iacc  replacing DIMENSION CEVENT(24) in each
*   generation routine
*  -mofify declaration of 
*   REAL*8 MASSOUTGOING(NMAX_ALPHA)
*   INTEGER INDEXOUTGOING(NMAX_ALPHA),INDEXINGOING(NMAX_ALPHA) 
*   to
*   REAL*8 MASSOUTGOING
*   INTEGER INDEXOUTGOING,INDEXINGOING  
* and
*   COMMON/INTEGRA/MASSOUTGOING(NMAX_ALPHA),
*  # NOUTGOING,INDEXOUTGOING(NMAX_ALPHA),INDEXINGOING(NMAX_ALPHA) 
*  - in generation subroutines, introduce loop from ilgenmin to ilgenmax
*    to handle Integration step with only pass 1 and Generation step with
*    only pass 2 ( keeping track of FUNVALMAX computed in step I)
*  - move CALL RLUXGO(LUX,INT,K1,K2) to interface : called once before init
*    then after init as init of pass G ( one event at a time)
*  - introduce flag iacc=1 for events accepted  (REFN.LT.FUNVAL)
*  - do not reset funval and funvalmax at begin of G step 
*******************************************************
*                                                     *
*          A MONTE CARLO EVENT GENERATOR FOR          *
*           SINGLE- AND MULTI-PHOTON EVENTS           *
*              PLUS MISSING ENERGY AT LEP             *  
*                                                     *
* AUTHORS:                                            *
*            G. MONTAGNA  (1)                         *
*            M. MORETTI   (2)                         *
*            O. NICROSINI (3)                         *
*            M. OSMO      (3)                         *
*            F. PICCININI (3)                         *
*                                                     *
*   (1) DFNT AND INFN, PAVIA                          *
*   (2) CERN, TH DIVISION, GENEVA,                    *
*       DIP. DI FISICA AND INFN, FERRARA              *
*   (3) INFN AND DFNT, PAVIA                          *
*                                                     *
*PREVIOUS VERSIONS OF NUNUGPV:                        *
*COMPUT. PHYS. COMMUN. 98 (1996) 206, BY              *
*G. MONTAGNA, O. NICROSINI AND F. PICCININI           * 
*                                                     *
*NUCL. PHYS. B541 (1999) 31, BY                       *
*G. MONTAGNA, O. NICROSINI M. MORETTI AND F. PICCININI* 
*                                                     *
*                                                     *
*******************************************************
*
* EXAMPLE OF JOB CONTROL FILE
*
*$ RUN NUNUGPV
*1,2,3,-1,-4 [NUMBER OF DETECTED GAMMA NPHOT; -1 = AT LEAST ONE; -4 = MASSIVE]
*F,M,T,E     [NEUTRINO FLAVOUR; F= SUM OVER THREE FLAVOURS]
*I,G         [INTEGRATION OR GENERATION MODE]
*314159265   [RANDOM NUMBER SEED, INTEGER NUMBER]
*190.D0      [C.M. ENERGY]
*1000        [NUMBER OF EVENTS]
*1,0         [1= YES IS QED, 0= TREE LEVEL; 1 AUTOMATICALLY FOR NPHOT= -1]
*1,0         [1= ISR WITH P_T; 0= COLLINEAR ISR; 1 AUTOMATICALLY FOR NPHOT= -1]
*45.D0       [MINIMUM PHOTON SCATTERING ANGLE]
*10.D0       [MINIMUM PHOTON ENERGY]
*95.D0       [MAXIMUM PHOTON ENERGY]
*N           [OPTION FOR ANOMALOUS COUPLINGS (Y,N)]
*             IF Y, XG AND YG MUST BE PROVIDED
*N           [OPTION OFAST (Y,N); ACTIVE ONLY FOR NPHOT= -1]
*10.d0       [fourth generation neutrino mass]
*128.87D0    [1/ALPHA(M_Z)]
*N           [OPTION FOR QUARTIC ANOMALOUS GAUGE COUPLINGS (Y,N)]
*             IF Y, THE SCALE LAMBDA (GEV), A0W, ACW, A0Z, AND ACZ 
*             MUST BE PROVIDED ACCORDING TO THE PARAMETRIZATION 
*             OF HEP-PH/9907235. THE PARAMETERS A0W AND ACW REFER TO 
*             THE COUPLING WWGG, WHILE A0Z AND ACZ REFER TO 
*             THE COUPLING ZZGG
*$ EXIT
*
*     WARNING: WHEN RUNNING ON HP SYSTEM -K OPTION FOR COMPILATION IS REQUIRED
*
*     THE PROGRAM HAS TO BE LINKED TO THE NAG LIBRARY
*
*     DURING THE RUN THE PROGRAM GENERATES THE FOLLOWING AUXILIARY FILES:
*     colbin.dat
*     spinbin.dat
*     spinbin_old.dat
*     spinconf.dat
*     spinconf_old.dat
*     PARAM.DAT
*     SPB2NPT.DAT
*     SPB2YPT.DAT
*     SPB3NPT.DAT
*     SPC2NPT.DAT
*     SPC2YPT.DAT
*     SPC3NPT.DAT
*
*     The content of the previous files is irrelevant for the user
*
*     WARNING:
*     THESE FILES MUST NOT BE OVERWRITTEN AND BECAUSE OF THIS REASON
*     NO MORE THAN ONE JOB CAN BE RUN SIMULTANEOUSLY IN A SINGLE DIRECTORY
*
************************************************************************
*
*     CONTENT OF THE NTUPLE STORED IN EXAMPLE.DAT WITH LABEL 313:
*
*     X_1= ENERGY FRACTION OF THE INCOMING E-
*     X_2= ENERGY FRACTION OF THE INCOMING E+
*     EB= NOMINAL BEAM ENERGY
*     Q1X,Q1Y,Q1Z= X,Y,Z COMPONENTS OF NEUTRINO MOMENTUM
*     Q2X,Q2Y,Q2Z= X,Y,Z COMPONENTS OF ANTINEUTRINO MOMENTUM
*     Q3X,Q3Y,Q3Z= X,Y,Z COMPONENTS OF DETECTED PHOTON
*     Q4X,Q4Y,Q4Z= X,Y,Z COMPONENTS OF DETECTED PHOTON
*     Q5X,Q5Y,Q5Z= X,Y,Z COMPONENTS OF DETECTED PHOTON
*     FOR EVENTS WITH ONLY ONE DETECTED PHOTON Q4 QND Q5 = 0
*     FOR EVENTS WITH ONLY TWO DETECTED PHOTONS Q5 = 0    
*
*     EGE= ENERGY OF THE PREEMISSION PHOTON FROM E-
*     EGP= ENERGY OF THE PHOTON EMITTED BY E+
*     CGE= COS OF THE POLAR ANGLE OF THE PHOTON EMITTE BY E-
*     CGP= COS OF THE POLAR ANGLE OF THE PHOTON EMITTE BY E+
*     ANGE= AZIMUTHAL ANGLE OF THE PHOTON EMITTED BY E- (RAD)
*     ANGP= AZIMUTHAL ANGLE OF THE PHOTON EMITTED BY E+ (RAD)     
*       
*     WARNING: 
*          1) ALL THE "OBSERVABLE" PHOTONS ARE GENERATED WITHIN THE 
*             ACCEPTANCE DEFINED IN THE INPUT DATA             
*          2) PREEMISSION PHOTONS ARE ALWAYS GENERATED IN THE REGION
*             COMPLEMENTARY TO THE ONE OF THE OBSERVABLE PHOTONS; 
*             TO BE USED ONLY FOR VETO PURPOSES
*          3) WHEN THE SUM OVER NEUTRINO FLAVOURS IS REQUIRED
*             THE FLAVOUR OF THE NEUTRINO'S IS NOT RECORDED
*          4) AT PRESENT, THE PREEMISSION PHOTONS CARRY LONGITUDINAL 
*             AND TRANSVERSE MOMENTUM, BUT THE EFFECT OF THE LATTER 
*             IS NOT PROPAGATED IN THE KERNEL CROSS SECTION 
*
********************************************************************************
********************************************************************************
********************************************************************************
*
*     SUBROUTINES VETO AND CUTUSER TO BE MODIFIED BY THE USER
*
********************************************************************************
********************************************************************************
********************************************************************************
*
*-----SUBROUTINE VETO: TO IMPOSE THE VETO CONDITIONS ON PREEMISSION PHOTONS
*                      THE POLAR AXIS IS ASSUMED TO BE ALONG THE INCOMING E-
*                      AKE0:  ENERGY OF THE PHOTON EMITTED BY E-
*                      AKP0:  ENERGY OF THE PHOTON EMITTED BY E+
*                      CTHG1: COS OF THE POLAR ANGLE OF THE PHOTON EMITTE BY E-
*                      CTHG2: COS OF THE POLAR ANGLE OF THE PHOTON EMITTE BY E+
*                      ANGE: AZIMUTHAL ANGLE OF THE PHOTON EMITTED BY E- (RAD)
*                      ANGP: AZIMUTHAL ANGLE OF THE PHOTON EMITTED BY E+ (RAD)
*
*                      IFLAGV: 1 MEANS REJECTED EVENTS
*                      IFLAGV: 0 MEANS ACCEPTED EVENTS
*
      SUBROUTINE VETO(AKE0,CTHG1,ANGE,AKP0,CTHG2,ANGP,IFLAGV)
      IMPLICIT REAL*8 (A-H,O-Z)
      COMMON/PAR/WM,WG,CFACT,GF,G,ZM,ZW,PI,ALPHA,EM2       
*
      IFLAGV = 0
*
      RETURN
      END
*
*-----SUBROUTINE CUTUSER: USED TO IMPLEMENT ANY KIND OF
*     EXPERIMENTAL CUT IN THE LABORATORY FRAME
*
*-----THE FOLLOWING QUANTITIES ARE USED:
*
*     NPHOT= SELECTED NUMBER OF DETECTED PHOTONS
*
*     Q1X,Q1Y,Q1Z= X,Y,Z COMPONENTS OF NEUTRINO MOMENTUM
*     Q2X,Q2Y,Q2Z= X,Y,Z COMPONENTS OF ANTINEUTRINO MOMENTUM
*     Q3X,Q3Y,Q3Z= X,Y,Z COMPONENTS OF DETECTED PHOTON
*     Q4X,Q4Y,Q4Z= X,Y,Z COMPONENTS OF DETECTED PHOTON
*     Q5X,Q5Y,Q5Z= X,Y,Z COMPONENTS OF DETECTED PHOTON
*     FOR EVENTS WITH ONLY ONE DETECTED PHOTON Q4 QND Q5 = 0
*     FOR EVENTS WITH ONLY TWO DETECTED PHOTONS Q5 = 0    
*
*     CUTFLAG= RETURNED IN OUTPUT 1) ACCEPTED EVENT
*                                 0) REJECTED EVENT
*
*     AS EXAMPLE THE MISSING MASS CUT IS PROVIDED
*
      SUBROUTINE CUTUSER(EVENT,CUTFLAG)
      IMPLICIT REAL*8 (A-H,O-Z)
      DIMENSION EVENT(24)
C      DIMENSION CEVENT(24)     
      common/kinevt/cevent(24),iacc
      COMMON/NG/NPHOT
*
      DO J = 1,18
         CEVENT(J) = EVENT(J)
      ENDDO
*
      EB = CEVENT(3)
*
      Q1X= CEVENT(4)
      Q1Y= CEVENT(5)
      Q1Z= CEVENT(6)
      Q2X= CEVENT(7)
      Q2Y= CEVENT(8)
      Q2Z= CEVENT(9)
      Q3X= CEVENT(10)
      Q3Y= CEVENT(11)
      Q3Z= CEVENT(12)
      Q4X= CEVENT(13)
      Q4Y= CEVENT(14)
      Q4Z= CEVENT(15)
      Q5X= CEVENT(16)
      Q5Y= CEVENT(17)
      Q5Z= CEVENT(18)
*
      CUTFLAG= 1.D0
*
      IF(NPHOT.EQ.1) THEN
*
*-----MISSING MASS CUT
*
C         E3= SQRT(Q3X*Q3X+Q3Y*Q3Y+Q3Z*Q3Z)
C         TWOPMQ3= 2.D0*EB*(E3-Q3Z)
C         TWOPPQ3= 2.D0*EB*(E3+Q3Z)
C         AMISS2= 4.D0*EB*EB-TWOPMQ3-TWOPPQ3
C         AMISS= SQRT(AMISS2)
C         IF(AMISS.LT.100.D0) THEN
C            CUTFLAG= 0.D0
C            RETURN
C         ENDIF 
      ELSE IF(NPHOT.EQ.2) THEN
C*
C*-----MISSING MASS CUT
C*
C         TWOPMQ3= 2.D0*EB*(E3-Q3Z)
C         TWOPPQ3= 2.D0*EB*(E3+Q3Z)
C         TWOPMQ4= 2.D0*EB*(E4-Q4Z)
C         TWOPPQ4= 2.D0*EB*(E4+Q4Z)
C         TWOQ3Q4= 2.D0*(E3*E4-Q3X*Q4X-Q3Y*Q4Y-Q3Z*Q4Z)
C         AMISS2= 4.D0*EB*EB-TWOPMQ3-TWOPPQ3-TWOPMQ4-TWOPPQ4+TWOQ3Q4
C         AMISS= SQRT(AMISS2)
C         IF(AMISS.LT.100.D0) THEN
C            CUTFLAG= 0.D0
C            RETURN
C         ENDIF 
*
      ELSE IF(NPHOT.EQ.3) THEN
C*
C*-----MISSING MASS CUT
C*
C         TWOPMQ3= 2.D0*EB*(E3-Q3Z)
C         TWOPPQ3= 2.D0*EB*(E3+Q3Z)
C         TWOPMQ4= 2.D0*EB*(E4-Q4Z)
C         TWOPPQ4= 2.D0*EB*(E4+Q4Z)
C         TWOPMQ5= 2.D0*EB*(E5-Q5Z)
C         TWOPPQ5= 2.D0*EB*(E5+Q5Z)
C         TWOQ3Q4= 2.D0*(E3*E4-Q3X*Q4X-Q3Y*Q4Y-Q3Z*Q4Z)  
C         TWOQ3Q5= 2.D0*(E3*E5-Q3X*Q5X-Q3Y*Q5Y-Q3Z*Q5Z)  
C         TWOQ4Q5= 2.D0*(E4*E5-Q4X*Q5X-Q4Y*Q5Y-Q4Z*Q5Z)  
C         AMISS2= 4.D0*EB*EB-TWOPMQ3-TWOPPQ3
C     #                     -TWOPMQ4-TWOPPQ4
C     #                     -TWOPMQ5-TWOPPQ5
C     #                     +TWOQ3Q4+TWOQ3Q5+TWOQ4Q5
C         AMISS= SQRT(AMISS2)
C         IF(AMISS.LT.100.D0) THEN
C            CUTFLAG= 0.D0
C            RETURN
C         ENDIF 
*
      ENDIF
*
      RETURN
      END
*
********************************************************************************
********************************************************************************

      SUBROUTINE MAINNNGPV
********************************************************************************
*
*     MAIN PROGRAM
*
********************************************************************************
********************************************************************************
********************************************************************************
*

*
      IMPLICIT REAL*8 (A-H,O-Z)
*
      PARAMETER (NWPAWC=1000000)
      PARAMETER (LUX=4,K1=0,K2=0,LEN=25)
*
* BEGIN ALPHA
*
      PARAMETER (NMAX_ALPHA=8)
*
* END ALPHA
*
      CHARACTER*1 OGEN, NFLV, OANOM, OFAST
      REAL*8 MNU,MNU2
*
* BEGIN ALPHA 
*
      REAL*8 MASSOUTGOING
      INTEGER INDEXOUTGOING,INDEXINGOING    !new
      INTEGER COULORSOUR(NMAX_ALPHA)
*
* END ALPHA
*
      COMMON/CMENERGY/RS,S  
      COMMON/PAR/WM,WG,CFACT,GF,G,ZM,ZW,PI,ALPHA,EM2       
      COMMON/PARD/ZM2,ZW2,WM2,WG2,GF2,G2,G4,G8
      COMMON/RPAR/RWM2,RWG2,RZM2,RZW2,RW,RZW,RW2
      COMMON/THETAW/STH2
      COMMON/EM/RL,ETA,BETA,SDELTA,BETAM
      COMMON/PAWC/PAW(NWPAWC)
      COMMON/OG/OGEN
      COMMON/S2CH/NSCH
      COMMON/AIN/ALPHAI
      COMMON/EMC/IQED
      COMMON/RELACC/EPS
      COMMON/QCM/QMF1,QMF2,QMF3,QMF4,QMF5,QMF6
      COMMON/CHANN/ICHANNEL
      COMMON/CUTS/EGMINL,EGMAXL,CMINL,CMAXL
      COMMON/CVETO/CMINV,CMAXV    
      COMMON/NG/NPHOT   
      COMMON/CALLS/NHITWMAX,NHITMAX,NCALLS
      COMMON/MAXVALUE/FMAX
      COMMON/ANOM/OANOM
      COMMON/ANOMV/XG,YG
      COMMON/NUMASS/MNU,MNU2
      COMMON/PT/IPT
*
* BEGIN ALPHA
*
      COMMON/INTEGRA/MASSOUTGOING(NMAX_ALPHA),
     # NOUTGOING,INDEXOUTGOING(NMAX_ALPHA),INDEXINGOING(NMAX_ALPHA)       !new
      COMMON/COLOR/COULORSOUR
*
* END ALPHA
*
      CHARACTER*4 CHTAGS(24)
      DATA CHTAGS/'X_1','X_2','EB','Q1X','Q1Y','Q1Z',
     #            'Q2X','Q2Y','Q2Z','Q3X',
     #            'Q3Y','Q3Z','Q4X','Q4Y','Q4Z',
     #            'Q5X','Q5Y','Q5Z',
     #            'EGE','CGE','ANGE','EGP','CGP','ANGP'/
*
      PRINT*,'ENTER NUMBER OF VISIBLE PHOTONS [1/2/3/-1/-4]'
      PRINT*,'-1 MEANS AT LEAST ONE PHOTON'
      PRINT*,'-4 MEANS MASSIVE NEUTRINOS INCLUDED'
      READ*,NPHOT
*
      PRINT*,'ENTER NEUTRINO FLAVOUR [E,M,T,F=SUM OVER THREE FLAVOURS]'
      READ '(A)',NFLV
*
      PRINT*,'ENTER OPTION FOR MC INTEGR. OR EVENT GEN. [I,G]'
      READ '(A)',OGEN
*
      PRINT*,'ENTER SEED FOR RANDOM NUMBER GENERATION'
      READ*,INPT
*
*----ENTER C.M. ENERGY
*
      PRINT*,'ENTER C.M. ENERGY (GEV)'
      READ*,RS
*
      RRS= RS
*
      S= RS*RS
*
*-----ENTER NUMBER OF CALLS: THE PROGRAM RUNS TILL THE REQUIRED
*                            NUMBER OF CALLS HAS BEEN REACHED. 
*                            IN ANY CASE, AFTER NCALLS = 10**9
*                            CALLS TO THE RANDOM NUMBER GEN. THE
*                            PROGRAM STOPS.
*
      IF(OGEN.EQ.'I') THEN
         PRINT*,' '
         PRINT*,'ENTER MAXIMUM NUMBER OF CALLS [I-BRANCH]'
         READ*,NHITWMAX
         NCALLS = 10**9
         NHITMAX = 0
      ELSE IF(OGEN.EQ.'G') THEN
         PRINT*,'ENTER REQUIRED NUMBER OF HITS [G-BRANCH]'
         READ*,NHITMAX
         PRINT*,'N. HITS = ',NHITMAX
         NCALLS = 10**9
         NHITWMAX = 0
      ENDIF
*
*----ENTER CHOICE FOR BORN (0) OR QED CORR. X-SECTION (1)
*
      PRINT*,'ENTER 0 FOR BORN OR 1 FOR QED CORR. CROSS SECTION'
      READ*,IQED
      IF(IQED.EQ.0) THEN
         PRINT*,'BORN CROSS SECTION IS COMPUTED'
      ELSE IF(IQED.EQ.1) THEN
         PRINT*,'QED CORR. CROSS SECTION IS COMPUTED'
      ELSE
         PRINT*,'IQED MUST BE 0 OR 1'
         STOP
      ENDIF
*
*-----ENTER CHOICE FOR TREATMENT OF ISR [0=COLLINEAR,1=P_T SF]
*
      PRINT*,'ENTER 0 FOR COLLINEAR OR 1 FOR P_T SF'
      PRINT*,'IN CASE OF TREE LEVEL IT IS IGNORED'
      READ*,IPT
      PRINT*,'ENTER THMINL (DEG)'
      READ*,THMINL
      PRINT*,'ENTER EGMINL (GEV)'
      READ*,EGMINL
      PRINT*,'ENTER EGMAXL (GEV)'
      READ*,EGMAXL
*
      THMINL = THMINL*PI/180.D0
      THMAXL = PI - THMINL
      CMINL = COS(THMAXL)
      CMAXL = COS(THMINL)
*
      IF(EGMAXL.GT.(RS/2.D0)) EGMAXL = RS/2.D0
*
      PRINT*,'ENTER OPTION FOR ANOMALOUS COUPLINGS'
      READ '(A)',OANOM
      IF(OANOM.EQ.'Y') THEN
         PRINT*,' '
         PRINT*,'ENTER XG'
         READ*,XG
         PRINT*,'ENTER YG'
         READ*,YG
      ELSE
         XG= 0.D0
         YG= 0.D0
      ENDIF
*
      PRINT*,'ENTER OPTION OFAST [N/Y]'
      PRINT*,'ACTIVE ONLY FOR NPHOT= -1'
      PRINT*,'IF OFAST= Y 3 PHOTON EVENTS ARE NOT COMPUTED'
      READ '(A)',OFAST
      PRINT*,'ENTER VALUE FOR IV GENERATION NEUTRINO MASS'
      READ*,MNU
      MNU2 = MNU*MNU
*
      CALL PARAMETERS()
*
*-----DERIVED PARAMETERS
*
      RWM2= WM2/S
      RWG2= WG2/S
      RZM2= ZM2/S
      RZW2= ZW2/S
*
      RW = WG*WM/S
      RZW = ZW*ZM/S
      RW2 = RW*RW
*
      ZRM= 1.D-35
*
      CALL INITIAL0()
*
      NPHOT0= NPHOT
*
      IF(OGEN.EQ.'G') THEN
         CALL HLIMIT(NWPAWC)
         CALL HROPEN(27,'EXAMPLE','EXAMPLE.DAT',
     #'N',1024,ISTAT)
         CALL HBOOKN(313,'NTUPLE',24,'EXAMPLE',2000,CHTAGS)
      ENDIF
*
      IF((IQED.EQ.0.AND.NPHOT.GT.0).OR.
     #   (IQED.EQ.1.AND.IPT.EQ.0.AND.NPHOT.GT.0)) THEN
         IF(NPHOT.EQ.1) THEN 
            CALL PHOT1(INPT,NFLV,XSECT,DXSECT,NHITO,FMAXO,EFFO,ANBIASO)
         ELSE IF(NPHOT.EQ.2) THEN
            CALL PHOT2(INPT,NFLV,XSECT,DXSECT,NHITO,FMAXO,EFFO,ANBIASO)
         ELSE IF(NPHOT.EQ.3) THEN
            CALL PHOT3(INPT,NFLV,XSECT,DXSECT,NHITO,FMAXO,EFFO,ANBIASO)
         ELSE 
            WRITE(6,*)NPHOT
            WRITE(6,*)'OPTION INCONSISTENT WITH BORN'
         ENDIF
      ELSE IF(IQED.EQ.1.AND.IPT.EQ.1.AND.NPHOT.GT.0) THEN
         IF(NPHOT.EQ.1) THEN 
            CALL PHOT1PT(INPT,NFLV,XSECT,DXSECT,
     >                   NHITO,FMAXO,EFFO,ANBIASO)
         ELSE IF(NPHOT.EQ.2) THEN
            CALL PHOT2PT(INPT,NFLV,XSECT,DXSECT,
     >                  NHITO,FMAXO,EFFO,ANBIASO)
         ENDIF
      ELSE IF(NPHOT.EQ.-1) THEN
         IF(OFAST.EQ.'N') THEN
            CALL ATLEASTONE(INPT,NFLV)
         ELSE IF(OFAST.EQ.'Y') THEN
            CALL ATLEASTONEF(INPT,NFLV)
         ENDIF
      ELSE IF(NPHOT.EQ.-4) THEN
         CALL MASSIVENU(INPT,NFLV)
      ENDIF
*
      IF(OGEN.EQ.'G') THEN
         CALL HROUT(0,ICYCLE,' ')
         CALL HREND('EXAMPLE')
      ENDIF
*
      NPHOT= NPHOT0
*
      IF(NPHOT.GT.0) THEN
         IF(OGEN.EQ.'G') THEN
            PRINT*, ' '
            PRINT*, 'RS = ',RS
            PRINT*, ' '
            PRINT*, 'NHIT = ',NHITO
            PRINT*, ' '
            PRINT*, 'XSECT FOR UNWEIGHTED EVENTS'
            PRINT*, ' '
            PRINT*, 'EFF = ', EFFO
            PRINT*, 'XSECT = ', XSECT, ' +- ', DXSECT, ' (PB)'
            PRINT*, 'NBIAS/NMAX = ', ANBIASO
            PRINT*, 'FMAX= ',FMAXO
         ELSE IF(OGEN.EQ.'I') THEN
            PRINT*, ' '
            PRINT*, 'RS = ',RS
            PRINT*, ' '
            PRINT*, 'NCALLS = ', NHITO
            PRINT*, ' '
            PRINT*, 'XSECT FOR WEIGHTED EVENTS'
            PRINT*, ' '
            PRINT*, 'EFF = ',EFFO
            PRINT*, 'FMAX= ',FMAXO
            PRINT*, 'XSECT = ', XSECT, ' +- ', DXSECT, ' (PB)'
         ENDIF                 
      ENDIF

      STOP
      END
*
      SUBROUTINE PHOT1(INT,NFLV,XSECT,DXSECT,NHITO,FMAXO,EFFO,ANBIASO)
      IMPLICIT REAL*8 (A-H,O-Z)
*
      PARAMETER (LUX=4,K1=0,K2=0,LEN=25)
*
      REAL*4 EVENT(24),RVEC(LEN)
      REAL*8 HP,HM,KP,KM

      CHARACTER*1 OGEN, OGEN0, NFLV
*
      DIMENSION VEC(LEN)
*
C      DIMENSION CEVENT(24)
      common/kinevt/cevent(24),iacc
*
      DIMENSION Q12(0:3),
     #          Q1S(0:3),Q2S(0:3),
     #          PP(0:3),PM(0:3),Q1(0:3),Q2(0:3),Q3(0:3),Q4(0:3),Q5(0:3),
     #          Q1L(0:3),Q2L(0:3),Q3L(0:3),Q4L(0:3),Q5L(0:3),PTOTL(0:3)
*
      DIMENSION RPRINT(LEN)
*
      COMMON/CMENERGY/RS,S
      COMMON/PAR/WM,WG,CFACT,GF,G,ZM,ZW,PI,ALPHA,EM2
      COMMON/PARD/ZM2,ZW2,WM2,WG2,GF2,G2,G4,G8
      COMMON/RPAR/RWM2,RWG2,RZM2,RZW2,RW,RZW,RW2
      COMMON/THETAW/STH2
      COMMON/EM/RL,ETA,BETA,SDELTA,BETAM
      COMMON/OG/OGEN
      COMMON/S2CH/NSCH
      COMMON/AIN/ALPHAI
      COMMON/EMC/IQED
      COMMON/RELACC/EPS
      COMMON/QCM/QMF1,QMF2,QMF3,QMF4,QMF5,QMF6
      COMMON/CHANN/ICHANNEL
      COMMON/CUTS/EGMINL,EGMAXL,CMINL,CMAXL
      COMMON/NG/NPHOT
      COMMON/CALLS/NHITWMAX,NHITMAX,NCALLS
      COMMON/MAXVALUE/FMAX
*
      IF(OGEN.EQ.'G') NHITWMAX = 100000
      NHITWMAX0 = NHITWMAX
      OGEN0 = OGEN
      OGEN = 'I'
*
      IF(OGEN0.EQ.'I') THEN
         ILGENMAX = 1
         ILGENMIN = 1
      ELSE
         ILGENMAX = 2
         ILGENMIN = 2
      ENDIF
*
      DO ILGEN = ILGENMIN,ILGENMAX
      IF(ILGEN.EQ.2) THEN
         OGEN = OGEN0
         FMAX = FUNVALMAX
      ENDIF 
*
*-----INITIALIZE RANDOM GENERATION
*
      NMAX = NCALLS
      if (OGEN.eq.'I') then
      ICNT = 0
      NHIT = 0
*
      FUNVAL = 0.D0
      FUNVALMAX= 0.D0
      NBIAS = 0
*
      FAV= 0.D0
      F2AV= 0.D0
*
*-----RANDOM NUMBER GENERATOR INITIALIZATION
*
C      CALL RLUXGO(LUX,INT,K1,K2)
      endif
*
*-----BEGINNING OF LOOP OVER EVENTS
*
      DO I = 1,NMAX
*
         FUNVAL = 0.D0
         ICNT = ICNT + 1
*
*-----RANDOM NUMBER GENERATION
*
         CALL RANLUX(RVEC,LEN)
C         call ranmar(rvec,len)
*
         DO J = 1,LEN
            VEC(J) = RVEC(J)
         ENDDO
*
         X1BS = 1.D0
         X2BS = 1.D0
*
         IF(IQED.EQ.1) THEN
*
*-----MIN AND MAX FOR X1
*
            X1MIN = 0.D0
            X1MAX = 1.D0
*
            OMX1 = ((1.D0 - X1MIN)**(BETAM)*(1.D0 - VEC(1))
     #        +(1.D0 - X1MAX)**(BETAM)*VEC(1))**(1.D0/BETAM)
            X1 = 1.D0 - OMX1
*
*-----MIN AND MAX FOR X2
*
            X2MIN = 0.D0
            X2MAX = 1.D0
*
            OMX2 = ((1.D0 - X2MIN)**(BETAM)*(1.D0 - VEC(2))
     #        +(1.D0 - X2MAX)**(BETAM)*VEC(2))**(1.D0/BETAM)
            X2 = 1.D0 - OMX2
*
         ELSE IF(IQED.EQ.0) THEN
            X1 = 1.D0
            X2 = 1.D0
         ENDIF
*
         X1D = X1
         X2D = X2
         X1 = X1BS*X1D
         X2 = X2BS*X2D
*                                                                      
         RZM2HAT = RZM2/X1/X2
         RZWHAT = RZW/X1/X2
         SHAT = X1*X2*S
*
         IF(IQED.EQ.1) THEN
            XM = X1 - X2
            XP = X1 + X2
*
            BLOR = XM/XP
            GLOR = XP/2.D0/SQRT(X1*X2)
*
*.....MIN AND MAX FOR THE PHOTON ANGLE IN C.M. FRAME
*
            CMAX = (CMAXL - BLOR)/(1.D0-BLOR*CMAXL)
            CMIN = (CMINL - BLOR)/(1.D0-BLOR*CMINL)
*
*-----angular sampling 1/(1-b^2 cthg^2) with b = 1
*
            arglog = ((1.d0+cmax)/(1.d0-cmax))*((1.d0-cmin)/(1.d0+cmin))
            ancthg = 0.5d0*log(arglog)
            rcmax = (1.d0+cmax)/(1.d0-cmax)
            rcmin = (1.d0-cmin)/(1.d0+cmin)
            cum = vec(3)
            cumm1 = vec(3) - 1.d0
            cthg = (rcmax**cum*rcmin**cumm1-1.d0)
     #            /(rcmax**cum*rcmin**cumm1+1.d0)
            pm1cthg = ancthg*(1.d0-cthg)*(1.d0+cthg) 
*
*.....MIN AND MAX FOR THE PHOTON ENERGY IN C.M. FRAME
*
            OPBC = 1.D0 + BLOR*CTHG
            SHAT = X1*X2*S
            EGMAX0 = SQRT(SHAT)/2.D0
            EGMIN = EGMINL/GLOR/OPBC
            EGMAX = DMIN1(EGMAXL/GLOR/OPBC,EGMAX0)
            EBSTAR = SQRT(SHAT)/2.D0 
         ELSE
            CMIN = CMINL
            CMAX = CMAXL
*
*-----angular sampling 1/(1-b^2 cthg^2) with b = 1
*
            arglog = ((1.d0+cmax)/(1.d0-cmax))*((1.d0-cmin)/(1.d0+cmin))
            ancthg = 0.5d0*log(arglog)
            rcmax = (1.d0+cmax)/(1.d0-cmax)
            rcmin = (1.d0-cmin)/(1.d0+cmin)
            cum = vec(3)
            cumm1 = vec(3) - 1.d0
            cthg = (rcmax**cum*rcmin**cumm1-1.d0)
     #            /(rcmax**cum*rcmin**cumm1+1.d0)
            pm1cthg = ancthg*(1.d0-cthg)*(1.d0+cthg)
*
            EGMIN = EGMINL
            EGMAX = EGMAXL
         ENDIF
*
         SHAT = X1*X2*S
         RSHAT = SQRT(SHAT)
*
         ancth = 2.d0
         cth = ancth*VEC(4) -1.d0
*
         anphig = 2.d0*pi
         phig = 2.d0*pi*VEC(5)
*
         anphi = 2.d0*pi
         phi = 2.d0*pi*VEC(6)
*
*-----S' GENERATION
*
         CM12 = VEC(7)
         X12MIN = 1.D0-2.D0*EGMAX/RSHAT
         X12MAX = 1.D0-2.D0*EGMIN/RSHAT
         IF(X12MAX.LT.X12MIN) GO TO 1100
         ISBW= 1
         ISIR= 1
         CALL INVMBWIR(SHAT,CM12,X12MIN,X12MAX,RZM2HAT,RZWHAT,
     #                 Q122,ANRM12,PRQ12,ISBW,ISIR)
*
         IKINEI= 0
         CALL DPHI2(SHAT,0.D0,Q122,CTHG,PHIG,Q3,Q12,F123,IKINEI)
         CALL DPHI2(Q122,0.D0,0.D0,CTH,PHI,Q1S,Q2S,F12,IKINEI)
*
         IF(IKINEI.GT.0) GO TO 1100
         CALL BOOST(Q1S,Q12,Q1)
         CALL BOOST(Q2S,Q12,Q2)
*
         EBEAM= RS/2.D0
*
         REFN = VEC(25)*FMAX
*
*-----EVENT DEFINITION
*
         RSHAT = SQRT(SHAT)
*
         PP(0) = RSHAT/2.D0
         PP(1) = 0.D0
         PP(2) = 0.D0
         PP(3) = -RSHAT/2.D0
         PM(0) = RSHAT/2.D0
         PM(1) = 0.D0
         PM(2) = 0.D0
         PM(3) = RSHAT/2.D0
*
         Q4(0) = 0.D0
         Q4(1) = 0.D0
         Q4(2) = 0.D0
         Q4(3) = 0.D0
         Q5(0) = 0.D0
         Q5(1) = 0.D0
         Q5(2) = 0.D0
         Q5(3) = 0.D0
*
         ENSUM= ABS(RSHAT - (Q1(0)+Q2(0)+Q3(0)))
         PXSUM= ABS(Q1(1)+Q2(1)+Q3(1))
         PYSUM= ABS(Q1(2)+Q2(2)+Q3(2))
         PZSUM= ABS(Q1(3)+Q2(3)+Q3(3))
         IF(ENSUM.GT.1.D-8.OR.
     #      PXSUM.GT.1.D-8.OR.
     #      PYSUM.GT.1.D-8.OR.
     #      PZSUM.GT.1.D-8) THEN
*
            PRINT*,'ENSUM= ',ENSUM
            PRINT*,'PXSUM= ',PXSUM
            PRINT*,'PYSUM= ',PYSUM
            PRINT*,'PZSUM= ',PZSUM
            GO TO 1100
         ENDIF
*
         X_1 = X1
         X_2 = X2
         EB = RS/2.D0
*
         IF(IQED.EQ.1) THEN
            PTOTL(0) = (X1+X2)*EB
            PTOTL(1) = 0.D0
            PTOTL(2) = 0.D0
            PTOTL(3) = (X1-X2)*EB
*
            CALL BOOST(Q1,PTOTL,Q1L)
            CALL BOOST(Q2,PTOTL,Q2L)
            CALL BOOST(Q3,PTOTL,Q3L)
            CALL BOOST(Q4,PTOTL,Q4L)
            CALL BOOST(Q5,PTOTL,Q5L)
         ELSE IF(IQED.EQ.0) THEN
            DO III = 0,3
               Q1L(III) = Q1(III)
               Q2L(III) = Q2(III)
               Q3L(III) = Q3(III)
               Q4L(III) = Q4(III)
               Q5L(III) = Q5(III)
            ENDDO
         ENDIF
*
         EGE = OMX1*EB
         CGE = 1.D0
         ANGE = 0.D0
         EGP = OMX2*EB
         CGP = -1.D0
         ANGP = 0.D0
*
         CEVENT(1) = X_1
         CEVENT(2) = X_2
         CEVENT(3) = EB
         CEVENT(4) = Q1L(1)
         CEVENT(5) = Q1L(2)
         CEVENT(6) = Q1L(3)
         CEVENT(7) = Q2L(1)
         CEVENT(8) = Q2L(2)
         CEVENT(9) = Q2L(3)
         CEVENT(10) = Q3L(1)
         CEVENT(11) = Q3L(2)
         CEVENT(12) = Q3L(3)
         CEVENT(13) = Q4L(1)
         CEVENT(14) = Q4L(2)
         CEVENT(15) = Q4L(3)
         CEVENT(16) = Q5L(1)
         CEVENT(17) = Q5L(2)
         CEVENT(18) = Q5L(3)
         CEVENT(19) = EGE
         CEVENT(20) = CGE
         CEVENT(21) = ANGE
         CEVENT(22) = EGP
         CEVENT(23) = CGP
         CEVENT(24) = ANGP   
*
*-----SUBROUTINE CUTUSER IS CALLED (I-BRANCH)
*
         CUTFLAG= 1.D0
         CALL ACCEPTANCE(CEVENT,CUTFLAG)
         IF(CUTFLAG.GT.0.D0) CALL CUTUSER(CEVENT,CUTFLAG)
         IF(CUTFLAG.GT.0.D0) THEN
            NHITW = NHITW+1
*
            SP = -2.D0*SCALPROD(Q1,Q2)
            TP = 2.D0*SCALPROD(PM,Q2)
            T = 2.D0*SCALPROD(PP,Q1)
            UP = 2.D0*SCALPROD(PM,Q1)
            U = 2.D0*SCALPROD(PP,Q2)
            HP = -2.D0*SCALPROD(PP,Q3)
            HM = -2.D0*SCALPROD(PM,Q3)
            KP = -2.D0*SCALPROD(Q1,Q3)
            KM = -2.D0*SCALPROD(Q2,Q3)
*
            call dnunug(nflv,Q1,Q2,Q3,
     #                  SHAT,HP,HM,KP,KM,SP,TP,T,UP,U,emtrx)
            emtrx= emtrx*cfact

            IF(IQED.EQ.1) THEN
*
*
*-----STRUCTURE FUNCTION NORM
*
               AND1 = (1.D0-X1MIN)**BETAM-(1.D0-X1MAX)**BETAM
               AND2 = (1.D0-X2MIN)**BETAM-(1.D0-X2MAX)**BETAM
*
                  FUNVAL = (2.D0*PI)**4/16.D0/(2.D0*PI)**9/2.D0
     #                     *EMTRX*F123*F12
     #                     *PM1CTHG*ANPHIG*ANCTH*ANPHI
     #                     *ANRM12*PRQ12*DOP(X1D)*DOP(X2D)*AND1*AND2
            ELSE IF(IQED.EQ.0) THEN
*
                  FUNVAL = (2.D0*PI)**4/16.D0/(2.D0*PI)**9/2.D0
     #                     *EMTRX*F123*F12
     #                     *PM1CTHG*ANPHIG*ANCTH*ANPHI 
     #                     *ANRM12*PRQ12
*
            ENDIF
*
         ELSE 
            FUNVAL= 0.D0
         ENDIF
*
         IF(FUNVAL.GT.FUNVALMAX) THEN 
            FUNVALMAX= FUNVAL
            X1PRINT= X1
            X2PRINT= X2
            RSHATPRINT= SQRT(SHAT)
            Q10PRINT= SQRT(Q1L(1)*Q1L(1)+Q1L(2)*Q1L(2)+Q1L(3)*Q1L(3))
            Q1XPRINT= Q1L(1)
            Q1YPRINT= Q1L(2)
            Q1ZPRINT= Q1L(3)
            Q20PRINT= SQRT(Q2L(1)*Q2L(1)+Q2L(2)*Q2L(2)+Q2L(3)*Q2L(3))
            Q2XPRINT= Q2L(1)
            Q2YPRINT= Q2L(2)
            Q2ZPRINT= Q2L(3)
            Q30PRINT= SQRT(Q3L(1)*Q3L(1)+Q3L(2)*Q3L(2)+Q3L(3)*Q3L(3))
            Q3XPRINT= Q3L(1)
            Q3YPRINT= Q3L(2)
            Q3ZPRINT= Q3L(3)
            EMTRXPRINT= EMTRX
            F123PRINT= F123
            F12PRINT= F12
            ANCTHGPRINT= ANCTHG
            ANPHIGPRINT= ANPHIG
            ANPHIPRINT= ANPHI
            ANCTHPRINT= ANCTH
            ANRM12PRINT= ANRM12
            PRQ12PRINT= PRQ12
            DOPX1PRINT= DOP(X1D)
            DOPX2PRINT= DOP(X2D)
            AND1PRINT= AND1
            AND2PRINT= AND2
            DO JJ=1,LEN
               RPRINT(JJ)= VEC(JJ)
            ENDDO
            SPPRINT= SP
            TPPRINT= TP
            TPRINT= T
            UPPRINT= UP
            UPRINT= U
            HPPRINT= HP
            HMPRINT= HM
            AKPPRINT= KP
            AKMPRINT= KM
         ENDIF
*
*-----AVERAGE AND SQUARED AVERAGE ARE CUMULATED (I-BRANCH)
*
         IF(OGEN.EQ.'I') THEN
*
            FAV = FAV + FUNVAL
            F2AV = F2AV + FUNVAL**2
*
            IF(NHITW.GE.NHITWMAX) GO TO 2100
*
         ELSE IF(OGEN.EQ.'G') THEN
*
*-----CHECK POSSIBLE BIAS (GENERATION BRANCH)
*
            IF(FUNVAL.GT.FMAX) THEN
               NBIAS = NBIAS + 1
               ANBIAS = NBIAS*1.D0
            ENDIF
*
            IF(REFN.LT.FUNVAL) THEN
               NHIT = NHIT + 1
               DO I1 = 1,24
                  EVENT(I1) = CEVENT(I1)
               ENDDO
               iacc = 1
*
C               print *,' accepted event',(event(i1),i1=4,18)
               CALL HFN(313,EVENT)
* 
            ENDIF
*
            IF(NHIT.GE.NHITMAX) GO TO 2100
         ENDIF
*
 1100 END DO
*
 2100 AN = ICNT*1.D0
      FAV = FAV/AN
      F2AV = F2AV/AN
      DFAV = SQRT(F2AV - FAV**2)/SQRT(AN-1.D0)
      EFF = NHIT*1.D0/AN
      EFFW = NHITW*1.D0/AN
      REFV = FMAX
*
      IF(OGEN.EQ.'G') THEN
         XSECT = EFF*REFV
         DXSECT = REFV/SQRT(AN)*SQRT(EFF*(1.D0-EFF))
         NHITO = NHIT
         FMAXO = FUNVALMAX
         EFFO = EFF
         ANBIASO = ANBIAS/AN
      ELSE IF(OGEN.EQ.'I') THEN
         EFF = EFFW
         XSECT = FAV
         DXSECT = DFAV
         NHITO = NHITW
         FMAXO = FUNVALMAX
         EFFO = EFF
         ANBIASO = 0.D0
*
      ENDIF
      ENDDO
*
      if (OGEN.eq.'I') then
      ICNT = 0
      NHIT = 0
*
C      FUNVAL = 0.D0
C      FUNVALMAX= 0.D0
      NBIAS = 0
*
      FAV= 0.D0
      F2AV= 0.D0
      endif
      RETURN
      END
*
      SUBROUTINE PHOT1M(INT,NFLV,XSECT,DXSECT,NHITO,FMAXO,EFFO,ANBIASO)
      IMPLICIT REAL*8 (A-H,O-Z)
*
      PARAMETER (LUX=4,K1=0,K2=0,LEN=25)
*
* BEGIN ALPHA
*
      PARAMETER (NMAX_ALPHA=8)
*
* END ALPHA
*
      REAL*4 EVENT(24),RVEC(LEN)
      REAL*8 HP,HM,KP,KM
      REAL*8 MNU,MNU2

      CHARACTER*1 OGEN, OGEN0, NFLV
*
* BEGIN ALPHA
*
      INTEGER COULORSOUR(NMAX_ALPHA)
*
* END ALPHA
*
      DIMENSION VEC(LEN)
*
C      DIMENSION CEVENT(24)
      common/kinevt/cevent(24),iacc
*
      DIMENSION Q12(0:3),
     #          Q1S(0:3),Q2S(0:3),
     #          PP(0:3),PM(0:3),Q1(0:3),Q2(0:3),Q3(0:3),Q4(0:3),Q5(0:3),
     #          Q1L(0:3),Q2L(0:3),Q3L(0:3),Q4L(0:3),Q5L(0:3),PTOTL(0:3)
*
      DIMENSION RPRINT(LEN)
*
      COMMON/CMENERGY/RS,S
      COMMON/PAR/WM,WG,CFACT,GF,G,ZM,ZW,PI,ALPHA,EM2
      COMMON/PARD/ZM2,ZW2,WM2,WG2,GF2,G2,G4,G8
      COMMON/RPAR/RWM2,RWG2,RZM2,RZW2,RW,RZW,RW2
      COMMON/THETAW/STH2
      COMMON/EM/RL,ETA,BETA,SDELTA,BETAM
      COMMON/OG/OGEN
      COMMON/S2CH/NSCH
      COMMON/AIN/ALPHAI
      COMMON/EMC/IQED
      COMMON/RELACC/EPS
      COMMON/QCM/QMF1,QMF2,QMF3,QMF4,QMF5,QMF6
      COMMON/CHANN/ICHANNEL
      COMMON/CUTS/EGMINL,EGMAXL,CMINL,CMAXL
      COMMON/NG/NPHOT
      COMMON/CALLS/NHITWMAX,NHITMAX,NCALLS
      COMMON/MAXVALUE/FMAX
      COMMON/NUMASS/MNU,MNU2
*
      IF(OGEN.EQ.'G') NHITWMAX = 100000
      NHITWMAX0 = NHITWMAX
      OGEN0 = OGEN
      OGEN = 'I'
*
      IF(OGEN0.EQ.'I') THEN
         ILGENMAX = 1
         ILGENMIN = 1
      ELSE
         ILGENMAX = 2
         ILGENMIN = 2
      ENDIF
*
      DO ILGEN = ILGENMIN,ILGENMAX
      IF(ILGEN.EQ.2) THEN
         OGEN = OGEN0
         FMAX = FUNVALMAX
      ENDIF 
*
*-----INITIALIZE RANDOM GENERATION
*
      NMAX = NCALLS
      if (OGEN.eq.'I') then
      ICNT = 0
      NHIT = 0
*
      FUNVAL = 0.D0
      FUNVALMAX= 0.D0
      NBIAS = 0
*
      FAV= 0.D0
      F2AV= 0.D0
*
*-----BEGIN ALPHA
*
      DO J=1,8
         COULORSOUR(J)=1
      ENDDO
*
*-----RANDOM NUMBER GENERATOR INITIALIZATION
*
C      CALL RLUXGO(LUX,INT,K1,K2)    ! move to askusi
      endif
*
*-----BEGINNING OF LOOP OVER EVENTS
*
      DO I = 1,NMAX
*
         FUNVAL = 0.D0
         ICNT = ICNT + 1
*
*-----RANDOM NUMBER GENERATION
*
         CALL RANLUX(RVEC,LEN)
*
         DO J = 1,LEN
            VEC(J) = RVEC(J)
         ENDDO
*
         X1BS = 1.D0
         X2BS = 1.D0
*
         IF(IQED.EQ.1) THEN
*
*-----MIN AND MAX FOR X1
*
            X1MIN = 0.D0
            X1MAX = 1.D0
*
            OMX1 = ((1.D0 - X1MIN)**(BETAM)*(1.D0 - VEC(1))
     #        +(1.D0 - X1MAX)**(BETAM)*VEC(1))**(1.D0/BETAM)
            X1 = 1.D0 - OMX1
*
*-----MIN AND MAX FOR X2
*
            X2MIN = 0.D0
            X2MAX = 1.D0
*
            OMX2 = ((1.D0 - X2MIN)**(BETAM)*(1.D0 - VEC(2))
     #        +(1.D0 - X2MAX)**(BETAM)*VEC(2))**(1.D0/BETAM)
            X2 = 1.D0 - OMX2
*
         ELSE IF(IQED.EQ.0) THEN
            X1 = 1.D0
            X2 = 1.D0
         ENDIF
*
         X1D = X1
         X2D = X2
         X1 = X1BS*X1D
         X2 = X2BS*X2D
*                                                                      
         RZM2HAT = RZM2/X1/X2
         RZWHAT = RZW/X1/X2
         SHAT = X1*X2*S
*
         IF(IQED.EQ.1) THEN
            XM = X1 - X2
            XP = X1 + X2
*
            BLOR = XM/XP
            GLOR = XP/2.D0/SQRT(X1*X2)
*
*.....MIN AND MAX FOR THE PHOTON ANGLE IN C.M. FRAME
*
            CMAX = (CMAXL - BLOR)/(1.D0-BLOR*CMAXL)
            CMIN = (CMINL - BLOR)/(1.D0-BLOR*CMINL)
*
*-----angular sampling 1/(1-b^2 cthg^2) with b = 1
*
            arglog = ((1.d0+cmax)/(1.d0-cmax))*((1.d0-cmin)/(1.d0+cmin))
            ancthg = 0.5d0*log(arglog)
            rcmax = (1.d0+cmax)/(1.d0-cmax)
            rcmin = (1.d0-cmin)/(1.d0+cmin)
            cum = vec(3)
            cumm1 = vec(3) - 1.d0
            cthg = (rcmax**cum*rcmin**cumm1-1.d0)
     #            /(rcmax**cum*rcmin**cumm1+1.d0)
            pm1cthg = ancthg*(1.d0-cthg)*(1.d0+cthg) 
*
*.....MIN AND MAX FOR THE PHOTON ENERGY IN C.M. FRAME
*
            OPBC = 1.D0 + BLOR*CTHG
            SHAT = X1*X2*S
            EGMAX0 = SQRT(SHAT)/2.D0
            EGMIN = EGMINL/GLOR/OPBC
            EGMAX = DMIN1(EGMAXL/GLOR/OPBC,EGMAX0)
            EBSTAR = SQRT(SHAT)/2.D0 
*
            EGMNXNEU = (EBSTAR*EBSTAR-MNU2)/EBSTAR
            EGMAX = DMIN1(EGMAX,EGMNXNEU)
*
         ELSE
            CMIN = CMINL
            CMAX = CMAXL
*
*-----angular sampling 1/(1-b^2 cthg^2) with b = 1
*
            arglog = ((1.d0+cmax)/(1.d0-cmax))*((1.d0-cmin)/(1.d0+cmin))
            ancthg = 0.5d0*log(arglog)
            rcmax = (1.d0+cmax)/(1.d0-cmax)
            rcmin = (1.d0-cmin)/(1.d0+cmin)
            cum = vec(3)
            cumm1 = vec(3) - 1.d0
            cthg = (rcmax**cum*rcmin**cumm1-1.d0)
     #            /(rcmax**cum*rcmin**cumm1+1.d0)
            pm1cthg = ancthg*(1.d0-cthg)*(1.d0+cthg)
*
            EGMIN = EGMINL
            EGMAX = EGMAXL
*
            EGMNXNEU = (S/4.D0-MNU2)/RS*2.D0
            EGMAX = DMIN1(EGMAX,EGMNXNEU)
*            
         ENDIF
*
         SHAT = X1*X2*S
         RSHAT = SQRT(SHAT)
*
         ancth = 2.d0
         cth = ancth*VEC(4) -1.d0
*
         anphig = 2.d0*pi
         phig = 2.d0*pi*VEC(5)
*
         anphi = 2.d0*pi
         phi = 2.d0*pi*VEC(6)
*
*-----S' GENERATION
*
         CM12 = VEC(7)
         X12MIN = 1.D0-2.D0*EGMAX/RSHAT
         X12MAX = 1.D0-2.D0*EGMIN/RSHAT
         IF(X12MAX.LT.X12MIN) GO TO 1180
         ISBW= 1
         ISIR= 1
         CALL INVMBWIR(SHAT,CM12,X12MIN,X12MAX,RZM2HAT,RZWHAT,
     #                 Q122,ANRM12,PRQ12,ISBW,ISIR)
*
         IKINEI= 0
         CALL DPHI2(SHAT,0.D0,Q122,CTHG,PHIG,Q3,Q12,F123,IKINEI)
         CALL DPHI2(Q122,MNU2,MNU2,CTH,PHI,Q1S,Q2S,F12,IKINEI)
*
         IF(IKINEI.GT.0) GO TO 1180
         CALL BOOST(Q1S,Q12,Q1)
         CALL BOOST(Q2S,Q12,Q2)
*
         EBEAM= RS/2.D0
*
         REFN = VEC(25)*FMAX
*
*-----EVENT DEFINITION
*
         RSHAT = SQRT(SHAT)
*
         PP(0) = RSHAT/2.D0
         PP(1) = 0.D0
         PP(2) = 0.D0
         PP(3) = -RSHAT/2.D0
         PM(0) = RSHAT/2.D0
         PM(1) = 0.D0
         PM(2) = 0.D0
         PM(3) = RSHAT/2.D0
*
         Q4(0) = 0.D0
         Q4(1) = 0.D0
         Q4(2) = 0.D0
         Q4(3) = 0.D0
         Q5(0) = 0.D0
         Q5(1) = 0.D0
         Q5(2) = 0.D0
         Q5(3) = 0.D0
*
         ENSUM= ABS(RSHAT - (Q1(0)+Q2(0)+Q3(0)))
         PXSUM= ABS(Q1(1)+Q2(1)+Q3(1))
         PYSUM= ABS(Q1(2)+Q2(2)+Q3(2))
         PZSUM= ABS(Q1(3)+Q2(3)+Q3(3))
         IF(ENSUM.GT.1.D-8.OR.
     #      PXSUM.GT.1.D-8.OR.
     #      PYSUM.GT.1.D-8.OR.
     #      PZSUM.GT.1.D-8) THEN
*
            PRINT*,'ENSUM= ',ENSUM
            PRINT*,'PXSUM= ',PXSUM
            PRINT*,'PYSUM= ',PYSUM
            PRINT*,'PZSUM= ',PZSUM
            GO TO 1180
         ENDIF
*
         X_1 = X1
         X_2 = X2
         EB = RS/2.D0
*
         IF(IQED.EQ.1) THEN
            PTOTL(0) = (X1+X2)*EB
            PTOTL(1) = 0.D0
            PTOTL(2) = 0.D0
            PTOTL(3) = (X1-X2)*EB
*
            CALL BOOST(Q1,PTOTL,Q1L)
            CALL BOOST(Q2,PTOTL,Q2L)
            CALL BOOST(Q3,PTOTL,Q3L)
            CALL BOOST(Q4,PTOTL,Q4L)
            CALL BOOST(Q5,PTOTL,Q5L)
         ELSE IF(IQED.EQ.0) THEN
            DO III = 0,3
               Q1L(III) = Q1(III)
               Q2L(III) = Q2(III)
               Q3L(III) = Q3(III)
               Q4L(III) = Q4(III)
               Q5L(III) = Q5(III)
            ENDDO
         ENDIF
*
         EGE = OMX1*EB
         CGE = 1.D0
         ANGE = 0.D0
         EGP = OMX2*EB
         CGP = -1.D0
         ANGP = 0.D0
*
         CEVENT(1) = X_1
         CEVENT(2) = X_2
         CEVENT(3) = EB
         CEVENT(4) = Q1L(1)
         CEVENT(5) = Q1L(2)
         CEVENT(6) = Q1L(3)
         CEVENT(7) = Q2L(1)
         CEVENT(8) = Q2L(2)
         CEVENT(9) = Q2L(3)
         CEVENT(10) = Q3L(1)
         CEVENT(11) = Q3L(2)
         CEVENT(12) = Q3L(3)
         CEVENT(13) = Q4L(1)
         CEVENT(14) = Q4L(2)
         CEVENT(15) = Q4L(3)
         CEVENT(16) = Q5L(1)
         CEVENT(17) = Q5L(2)
         CEVENT(18) = Q5L(3)
         CEVENT(19) = EGE
         CEVENT(20) = CGE
         CEVENT(21) = ANGE
         CEVENT(22) = EGP
         CEVENT(23) = CGP
         CEVENT(24) = ANGP   
*
*-----SUBROUTINE CUTUSER IS CALLED (I-BRANCH)
*
         CUTFLAG= 1.D0
         CALL ACCEPTANCE(CEVENT,CUTFLAG)
         IF(CUTFLAG.GT.0.D0) CALL CUTUSER(CEVENT,CUTFLAG)
         IF(CUTFLAG.GT.0.D0) THEN
            NHITW = NHITW+1
*
            SP = -2.D0*SCALPROD(Q1,Q2) + 2.D0*MNU2
            TP = 2.D0*SCALPROD(PM,Q2) + MNU2
            T = 2.D0*SCALPROD(PP,Q1) + MNU2
            UP = 2.D0*SCALPROD(PM,Q1) + MNU2
            U = 2.D0*SCALPROD(PP,Q2) + MNU2
            HP = -2.D0*SCALPROD(PP,Q3)
            HM = -2.D0*SCALPROD(PM,Q3)
            KP = -2.D0*SCALPROD(Q1,Q3) + MNU2
            KM = -2.D0*SCALPROD(Q2,Q3) + MNU2
*
            call dnunugm(nflv,Q1,Q2,Q3,
     #                   SHAT,HP,HM,KP,KM,SP,TP,T,UP,U,emtrx)
            emtrx= emtrx*cfact
            IF(IQED.EQ.1) THEN
*
*
*-----STRUCTURE FUNCTION NORM
*
               AND1 = (1.D0-X1MIN)**BETAM-(1.D0-X1MAX)**BETAM
               AND2 = (1.D0-X2MIN)**BETAM-(1.D0-X2MAX)**BETAM
*
                  FUNVAL = (2.D0*PI)**4/16.D0/(2.D0*PI)**9/2.D0
     #                     *EMTRX*F123*F12
     #                     *PM1CTHG*ANPHIG*ANCTH*ANPHI
     #                     *ANRM12*PRQ12*DOP(X1D)*DOP(X2D)*AND1*AND2
            ELSE IF(IQED.EQ.0) THEN
*
                  FUNVAL = (2.D0*PI)**4/16.D0/(2.D0*PI)**9/2.D0
     #                     *EMTRX*F123*F12
     #                     *PM1CTHG*ANPHIG*ANCTH*ANPHI 
     #                     *ANRM12*PRQ12
*
            ENDIF
*
         ELSE 
            FUNVAL= 0.D0
         ENDIF
*
         IF(FUNVAL.GT.FUNVALMAX) THEN 
            FUNVALMAX= FUNVAL
            X1PRINT= X1
            X2PRINT= X2
            RSHATPRINT= SQRT(SHAT)
            Q10PRINT= SQRT(Q1L(1)*Q1L(1)+Q1L(2)*Q1L(2)+Q1L(3)*Q1L(3))
            Q1XPRINT= Q1L(1)
            Q1YPRINT= Q1L(2)
            Q1ZPRINT= Q1L(3)
            Q20PRINT= SQRT(Q2L(1)*Q2L(1)+Q2L(2)*Q2L(2)+Q2L(3)*Q2L(3))
            Q2XPRINT= Q2L(1)
            Q2YPRINT= Q2L(2)
            Q2ZPRINT= Q2L(3)
            Q30PRINT= SQRT(Q3L(1)*Q3L(1)+Q3L(2)*Q3L(2)+Q3L(3)*Q3L(3))
            Q3XPRINT= Q3L(1)
            Q3YPRINT= Q3L(2)
            Q3ZPRINT= Q3L(3)
            EMTRXPRINT= EMTRX
            F123PRINT= F123
            F12PRINT= F12
            ANCTHGPRINT= ANCTHG
            ANPHIGPRINT= ANPHIG
            ANPHIPRINT= ANPHI
            ANCTHPRINT= ANCTH
            ANRM12PRINT= ANRM12
            PRQ12PRINT= PRQ12
            DOPX1PRINT= DOP(X1D)
            DOPX2PRINT= DOP(X2D)
            AND1PRINT= AND1
            AND2PRINT= AND2
            DO JJ=1,LEN
               RPRINT(JJ)= VEC(JJ)
            ENDDO
            SPPRINT= SP
            TPPRINT= TP
            TPRINT= T
            UPPRINT= UP
            UPRINT= U
            HPPRINT= HP
            HMPRINT= HM
            AKPPRINT= KP
            AKMPRINT= KM
         ENDIF
*
*-----AVERAGE AND SQUARED AVERAGE ARE CUMULATED (I-BRANCH)
*
         IF(OGEN.EQ.'I') THEN
*
            FAV = FAV + FUNVAL
            F2AV = F2AV + FUNVAL**2
*
            IF(NHITW.GE.NHITWMAX) GO TO 2180
*
         ELSE IF(OGEN.EQ.'G') THEN
*
*-----CHECK POSSIBLE BIAS (GENERATION BRANCH)
*
            IF(FUNVAL.GT.FMAX) THEN
               NBIAS = NBIAS + 1
               ANBIAS = NBIAS*1.D0
            ENDIF
*
            IF(REFN.LT.FUNVAL) THEN
               NHIT = NHIT + 1
               DO I1 = 1,24
                  EVENT(I1) = CEVENT(I1)
               ENDDO
*
              iacc = 1
                print *,' accepted event',(event(i1),i1=4,18)
              CALL HFN(313,EVENT)
* 
            ENDIF
*
            IF(NHIT.GE.NHITMAX) GO TO 2180
         ENDIF
*
 1180 END DO
*
 2180 AN = ICNT*1.D0
      FAV = FAV/AN
      F2AV = F2AV/AN
      DFAV = SQRT(F2AV - FAV**2)/SQRT(AN-1.D0)
      EFF = NHIT*1.D0/AN
      EFFW = NHITW*1.D0/AN
      REFV = FMAX
*
      IF(OGEN.EQ.'G') THEN
         XSECT = EFF*REFV
         DXSECT = REFV/SQRT(AN)*SQRT(EFF*(1.D0-EFF))
         NHITO = NHIT
         FMAXO = FUNVALMAX
         EFFO = EFF
         ANBIASO = ANBIAS/AN
      ELSE IF(OGEN.EQ.'I') THEN
         EFF = EFFW
         XSECT = FAV
         DXSECT = DFAV
         NHITO = NHITW
         FMAXO = FUNVALMAX
         EFFO = EFF
         ANBIASO = 0.D0
*
      ENDIF
      ENDDO
*
      if (OGEN.eq.'I') then
      ICNT = 0
      NHIT = 0
*
C      FUNVAL = 0.D0
C      FUNVALMAX= 0.D0
      NBIAS = 0
*
      FAV= 0.D0
      F2AV= 0.D0
*
*-----BEGIN ALPHA
*
      DO J=1,8
         COULORSOUR(J)=1
      ENDDO
      endif
      RETURN
      END
*
      SUBROUTINE PHOT2(INT,NFLV,XSECT,DXSECT,NHITO,FMAXO,EFFO,ANBIASO)
      IMPLICIT REAL*8 (A-H,O-Z)
*
      PARAMETER (LUX=4,K1=0,K2=0,LEN=25)
      integer irndm
      common/random/irndm(3)
*
* BEGIN ALPHA
*
      PARAMETER (NMAX_ALPHA=8)
*
* END ALPHA
*
      REAL*4 EVENT(24),RVEC(LEN)
      CHARACTER*1 OGEN, OGEN0, NFLV
*
* BEGIN ALPHA
*
      REAL*8 MOMEN(4,NMAX_ALPHA),MOMEN_IN(4,NMAX_ALPHA)      !new
      REAL*8 MASSOUTGOING(NMAX_ALPHA)
      INTEGER INDEXOUTGOING(NMAX_ALPHA),INDEXINGOING(NMAX_ALPHA)    !new
      COMPLEX*16 ELMAT
      INTEGER COULORSOUR(NMAX_ALPHA)
      INTEGER NINGOING
*
* END ALPHA
*
      DIMENSION VEC(LEN)
*
C      DIMENSION CEVENT(24)
      common/kinevt/cevent(24),iacc
      DIMENSION PP(0:3),PM(0:3),Q1(0:3),Q2(0:3),Q3(0:3),Q4(0:3),Q5(0:3),
     #          Q1L(0:3),Q2L(0:3),Q3L(0:3),Q4L(0:3),Q5L(0:3)
      DIMENSION PARTIAL(64),conf(8,64)
*
      COMMON/CMENERGY/RS,S
      COMMON/PAR/WM,WG,CFACT,GF,G,ZM,ZW,PI,ALPHA,EM2
      COMMON/PARD/ZM2,ZW2,WM2,WG2,GF2,G2,G4,G8
      COMMON/RPAR/RWM2,RWG2,RZM2,RZW2,RW,RZW,RW2
      COMMON/THETAW/STH2
      COMMON/EM/RL,ETA,BETA,SDELTA,BETAM
      COMMON/OG/OGEN
      COMMON/S2CH/NSCH
      COMMON/AIN/ALPHAI
      COMMON/EMC/IQED
      COMMON/RELACC/EPS
      COMMON/QCM/QMF1,QMF2,QMF3,QMF4,QMF5,QMF6
      COMMON/CHANN/ICHANNEL
      COMMON/CUTS/EGMINL,EGMAXL,CMINL,CMAXL
      COMMON/NG/NPHOT
      COMMON/CALLS/NHITWMAX,NHITMAX,NCALLS
      COMMON/MAXVALUE/FMAX
*
* BEGIN ALPHA
*
      COMMON/INTEGRA/MASSOUTGOING,NOUTGOING,INDEXOUTGOING,INDEXINGOING
C     #               NOUTGOING,INDEXOUTGOING,INDEXINGOING                 !new
      COMMON/COLOR/COULORSOUR
*
* END ALPHA
*
      NHITWMAX0 = NHITWMAX
      OGEN0 = OGEN
      OGEN = 'I'
*
      IF(NFLV.EQ.'E') THEN
         NFLMIN = 1
         NFLMAX = 1
      ELSE IF(NFLV.EQ.'M'.OR.NFLV.EQ.'T') THEN
         NFLMIN = 2
         NFLMAX = 2
      ELSE IF(NFLV.EQ.'F') THEN
         NFLMIN = 1
         NFLMAX = 2
      ENDIF  
*
*-----REQUIRED BY THE GENERATING BRANCH
*
      ismin = 1
      ismax = 4
      
      if (OGEN0.eq.'G') ismin = 4 
      if (OGEN0.eq.'I') ismax = 3 
      if ( OGEN0.eq.'I') then
         print *, ' calling phot2 with OGEN ',Ogen0
         print *,' looping ',ismin,ismax
         print *,' NHITWMAX begin ',NHITWMAX0
         print *,' FMAX begin ', FMAX
      elseif (OGEN0.eq.'G'.and. ifir.lt.5) then
         print *, ' calling phot2 with OGEN ',Ogen0,ifir
         print *,' looping ',ismin,ismax
         print *,' NHITMAX begin ',NHITMAX
         print *,' FMAXO begin ', FMAXO
         print *,' FMAX begin ', FMAX
         print *,' ICNT begin ', ICNT
      endif
      ifir = ifir+1
      DO IS = ismin,ismax
         IF(IS.EQ.1) THEN 
            IFLAG_SPIN = 0
            NHITWMAX = 10000
            print *,' nhitw max  is ', NHITWMAX
         ELSE IF(IS.EQ.2) THEN
            IFLAG_SPIN = 1
            NHITWMAX = 100000
            NHITWMAX = 70000
            print *,' nhitw max  is ', NHITWMAX
         ELSE IF(IS.EQ.3) THEN
            IFLAG_SPIN = 1
            NHITWMAX = 100000
            NHITWMAX = 70000
            print *,' nhitw max  is ', NHITWMAX
         ELSE IF(IS.EQ.4) THEN
            IFLAG_SPIN = 1
            FMAX = FMAXO
            NHITWMAX = NHITWMAX0
            IF(OGEN0.EQ.'G') THEN
               OGEN = OGEN0
            ENDIF
         ENDIF
*         
         if (ifir.le.5) print *,' step ',is,IFLAG_SPIN,FMAXO,ncalls
         INIT_SPIN=0               !IT MUST BE 0 BEFORE ANY INTEGRATION LOOP
         INIT_FLAG=0               !IT MUST BE 0 BEFORE ANY INTEGRATION LOOP
         INIT_REG=0               !IT MUST BE 0 BEFORE ANY INTEGRATION LOOP
         NCONF=64                  !NUMBER OF SPIN CONFIGURATIONS
*
*-----INITIALIZE RANDOM GENERATION
*
         NMAX = NCALLS
       if (OGEN0.eq.'I') then
         ICNT = 0
         NHIT = 0
         NHITW = 0
*
         FUNVAL = 0.D0
         FUNVALMAX= 0.D0
         NBIAS = 0
*
         FAV= 0.D0
         F2AV= 0.D0
*
*-----BEGIN ALPHA
*
         DO J=1,8
            COULORSOUR(J)=1
         ENDDO
*
*-----END ALPHA
*
*-----RANDOM NUMBER GENERATOR INITIALIZATION
*
         print *,' before init gene lux,int,k1,k2',LUX,INT,K1,K2
         CALL RLUXGO(LUX,INT,K1,K2)
         print *,' reinit with ',irndm
         call rmarin(irndm(1),irndm(2),irndm(3))
C         print *,' rluxgo has been recalled'
       endif
*
*-----BEGINNING OF LOOP OVER EVENTS
*
C         if (ifir.le.5) print *,' step ',is,IFLAG_SPIN,FMAXO,ncalls
         DO I = 1,NMAX
*
 1001      continue
            ICNT = ICNT + 1
*
*
*-----RANDOM NUMBER GENERATION
*
            CALL RANLUX(RVEC,LEN)
*
            DO J = 1,LEN
               VEC(J) = RVEC(J)
            ENDDO
*
C            print *,'vec',vec
            X1BS = 1.D0
            X2BS = 1.D0
*
            IF(IQED.EQ.1) THEN
*
*-----MIN AND MAX FOR X1
*
               X1MIN = 0.D0
               X1MAX = 1.D0
*
               OMX1 = ((1.D0 - X1MIN)**(BETAM)*(1.D0 - VEC(1))
     #           +(1.D0 - X1MAX)**(BETAM)*VEC(1))**(1.D0/BETAM)
               X1 = 1.D0 - OMX1
*
*-----MIN AND MAX FOR X2
*
               X2MIN = 0.D0
               X2MAX = 1.D0
*
               OMX2 = ((1.D0 - X2MIN)**(BETAM)*(1.D0 - VEC(2))
     #           +(1.D0 - X2MAX)**(BETAM)*VEC(2))**(1.D0/BETAM)
               X2 = 1.D0 - OMX2
*
            ELSE IF(IQED.EQ.0) THEN
               X1 = 1.D0
               X2 = 1.D0
            ENDIF
*
            X1D = X1
            X2D = X2
            X1 = X1BS*X1D
            X2 = X2BS*X2D
*                                                                      
            RZM2HAT = RZM2/X1/X2
            RZWHAT = RZW/X1/X2
            SHAT = X1*X2*S
            RSHAT = SQRT(SHAT)
*
            CMCTHG3 = VEC(3)
            CM12 = VEC(4)
            CMG3 = VEC(5)
            CMG4 = VEC(6)
            CMPHIG34 = VEC(7)
            CMCTHS = VEC(8)
            CMPHIS = VEC(9)
            CMPHIG3 = VEC(10)
            IKINE = 0
            CALL KINE2(X1,X2,SHAT,CMCTHG3,CM12,CMG3,CMG4,CMPHIG34,
     #                 CMCTHS,CMPHIS,CMPHIG3,ancthg3,pm1cthg3,
     #                 ANRM12,PRQ12,
     #                 RZM2HAT,RZWHAT,F12,ANEG3,XG3,ANEG4,XG4,
     #                 anphig34,ancths,anphis,anphig3,
     #                 PP,PM,Q1,Q2,Q3,Q4,Q5,
     #                 Q1L,Q2L,Q3L,Q4L,Q5L,IKINE)
            IF(IKINE.GT.0) GO TO 1000
*
            REFN = VEC(25)*FMAX
*
            X_1 = X1
            X_2 = X2
            EB= RS/2.D0
*
            EGE = OMX1*EB
            CGE = 1.D0
            ANGE = 0.D0
            EGP = OMX2*EB
            CGP = -1.D0
            ANGP = 0.D0
*
            CEVENT(1) = X_1
            CEVENT(2) = X_2
            CEVENT(3) = EB
            CEVENT(4) = Q1L(1)
            CEVENT(5) = Q1L(2)
            CEVENT(6) = Q1L(3)
            CEVENT(7) = Q2L(1)
            CEVENT(8) = Q2L(2)
            CEVENT(9) = Q2L(3)
            CEVENT(10) = Q3L(1)
            CEVENT(11) = Q3L(2)
            CEVENT(12) = Q3L(3)
            CEVENT(13) = Q4L(1)
            CEVENT(14) = Q4L(2)
            CEVENT(15) = Q4L(3)
            CEVENT(16) = Q5L(1)
            CEVENT(17) = Q5L(2)
            CEVENT(18) = Q5L(3)
            CEVENT(19) = EGE
            CEVENT(20) = CGE
            CEVENT(21) = ANGE
            CEVENT(22) = EGP
            CEVENT(23) = CGP
            CEVENT(24) = ANGP   
*
*-----SUBROUTINE CUTUSER IS CALLED (I-BRANCH)
*
            CUTFLAG= 1.D0
            CALL ACCEPTANCE(CEVENT,CUTFLAG)
            IF(CUTFLAG.GT.0.D0) CALL CUTUSER(CEVENT,CUTFLAG)
            IF(CUTFLAG.GT.0.D0) THEN
               NHITW = NHITW+1
*
* BEGIN ALPHA
*
               DO III=1,4
                  MOMEN(III,1)= Q1(III-1)
                  MOMEN(III,2)= Q2(III-1)
                  MOMEN(III,3)= Q3(III-1)
                  MOMEN(III,4)= Q4(III-1)
               ENDDO
*
* spin sampling
*
* SPINSAMPLING_NEW(RND,REDEFINED,SPINWEIGHT,nconf,flag)               
               IF (IFLAG_SPIN.EQ.1) THEN
                  CALL SPINSAMPLING_NEW(vec(18),REDEFINED,SPINWEIGHT,
     >                                  nconf,INIT_flag)
               ELSE
                  REDEFINED=VEC(18)
                  SPINWEIGHT=1.
               ENDIF
*

               momen_in(1,1)=RSHAT/2.D0                  !new
               momen_in(2,1)=0.                  !new
               momen_in(3,1)=0.                  !new
               momen_in(4,1)=RSHAT/2.D0                  !new
*
               momen_in(1,2)=RSHAT/2.D0                  !new
               momen_in(2,2)=0.                  !new
               momen_in(3,2)=0.                  !new
               momen_in(4,2)=-RSHAT/2.D0                  !new
*
               ningoing=2                !new  number of ingoing particles
*
               ELMATSQ = 0.D0
               DO IFL = NFLMIN,NFLMAX
                  CALL PROCESSO_H(IFL)                 !new style
*
                  CALL FILLMOM(MOMEN,NOUTGOINGb,momen_in,ningoing)     !new
                  CALL SPINCOULOR_H(REDEFINED,NSPINCONF,LABEL,INIT_SPIN,
     >                      IFLAG_SPIN)
*
                  CALL ITERA(ELMAT)
                  IF(IFL.EQ.1) ELMATSQE = (ABS(ELMAT))**2
                  IF(IFL.EQ.2) ELMATSQM = (ABS(ELMAT))**2
               ENDDO
*
               IF(NFLV.EQ.'E') THEN
                  ELMATSQ = ELMATSQE
               ELSE IF(NFLV.EQ.'M'.OR.NFLV.EQ.'T') THEN
                  ELMATSQ = ELMATSQM
               ELSE IF(NFLV.EQ.'F') THEN
                  ELMATSQ = 2.D0*ELMATSQM + ELMATSQE
               ENDIF 
*
               EMTRX = ELMATSQ
               EMTRX = EMTRX * 16. * CFACT      
               EMTRX = EMTRX * SPINWEIGHT   ! SPIN RESCALING
               EMTRX = EMTRX*(4.D0*PI*ALPHA/G2/STH2)**2     
*
* END ALPHA    
*
               IF(IQED.EQ.1) THEN
*
*
*-----STRUCTURE FUNCTION NORM
*
                  AND1 = (1.D0-X1MIN)**BETAM-(1.D0-X1MAX)**BETAM
                  AND2 = (1.D0-X2MIN)**BETAM-(1.D0-X2MAX)**BETAM
*
                  FUNVAL = (2.D0*PI)**4/(2.D0*PI)**12/2.D0**5/2.D0
     #                     *EMTRX*ANRM12*PRQ12*F12
     #                     *pm1cthg3*ANEG3*ANEG4*ANPHIG34
     #                     *ANCTHS*ANPHIS*ANPHIG3
     #                     *XG3*XG4
     #                     *DOP(X1D)*DOP(X2D)*AND1*AND2
*
               ELSE IF(IQED.EQ.0) THEN
*
                  FUNVAL = (2.D0*PI)**4/(2.D0*PI)**12/2.D0**5/2.D0
     #                     *EMTRX*ANRM12*PRQ12*F12
     #                     *pm1cthg3*ANEG3*ANEG4*ANPHIG34
     #                     *ANCTHS*ANPHIS*ANPHIG3
     #                     *XG3*XG4
*
               ENDIF
*
            ELSE
               FUNVAL = 0.D0
            ENDIF
*
*-----STATISTICAL FACTOR FOR TWO INDISTINGUISHABLE PHOTONS
*
            FUNVAL = FUNVAL/2.D0
*
            IF(FUNVAL.GT.FUNVALMAX) FUNVALMAX= FUNVAL
*
*-----AVERAGE AND SQUARED AVERAGE ARE CUMULATED (I-BRANCH)
*
            IF(OGEN0.EQ.'I') THEN
*
               FAV = FAV + FUNVAL
               F2AV = F2AV + FUNVAL**2
*
               IF(NHITW.GE.NHITWMAX) GO TO 2000
*
            ELSE IF(OGEN0.EQ.'G') THEN
*
*-----CHECK POSSIBLE BIAS (GENERATION BRANCH)
*
C               print *,'FMAX,FUNVAL,REFN ', FMAX,FUNVAL,REFN
               IF(FUNVAL.GT.FMAX) THEN
                  NBIAS = NBIAS + 1
                  ANBIAS = NBIAS*1.D0
               ENDIF
*
               IF (REFN.LT.FUNVAL) THEN
                  NHIT = NHIT + 1
                  DO I1 = 1,24
                     EVENT(I1) = CEVENT(I1)
                  ENDDO
*
                  iacc = 1
C               print *,' accepted event',(event(i1),i1=4,18)
                  CALL HFN(313,EVENT)
* 
               ENDIF
*
               IF(NHIT.GE.NHITMAX) GO TO 2000
            ENDIF
*
* BEGIN ALPHA
*
            WEIGHT = 1.D0
            if(funval.gt.0) 
     #         CALL REGSPIN_NEW
     #              (nspinconf,label,1,1,FUNVAL,weight,INIT_REG)
*
* END ALPHA
*
*-----END OF LOOP OVER EVENTS
*
             go to 1001
 1000    END DO
*
* BEGIN ALPHA
*
 2000    CALL WRITESPIN
*
* END ALPHA
*
         AN = ICNT*1.D0
         FAV = FAV/AN
         F2AV = F2AV/AN
         DFAV = SQRT(F2AV - FAV**2)/SQRT(AN-1.D0)
         EFF = NHIT*1.D0/AN
         EFFW = NHITW*1.D0/AN
         REFV = FMAX
*
         IF(OGEN0.EQ.'G') THEN
            XSECT = EFF*REFV
            DXSECT = REFV/SQRT(AN)*SQRT(EFF*(1.D0-EFF))
            NHITO = NHIT
            FMAXO = FUNVALMAX
            EFFO = EFF
            ANBIASO = ANBIAS/AN
         ELSE IF(OGEN0.EQ.'I') THEN
            EFF = EFFW
            XSECT = FAV
            DXSECT = DFAV
            NHITO = NHITW
            FMAXO = FUNVALMAX
            EFFO = EFF
            ANBIASO = 0.D0
          ENDIF
*
      ENDDO
*
         if (OGEN0.eq.'I') then
         ICNT = 0
         NHIT = 0
         NHITW = 0
*
C         FUNVAL = 0.D0
C         FUNVALMAX= 0.D0
         NBIAS = 0
*
         FAV= 0.D0
         F2AV= 0.D0
*
*-----BEGIN ALPHA
*
         DO J=1,8
            COULORSOUR(J)=1
         ENDDO
         print *, ' end of init funvalmax,fmax0',funvalmax,fmax0
         endif
*
*-----END ALPHA
            OPEN (1,FILE='spinbin.dat',STATUS='OLD')
            DO J1=1,64
               READ(1,*)PARTIAL(J1)
            ENDDO
            CLOSE(1)
            OPEN (1,FILE='SPB2NPT.DAT',STATUS='UNKNOWN')
            DO J1=1,64
               WRITE(1,*)PARTIAL(J1)
            ENDDO
            CLOSE(1)
            OPEN (1,FILE='spinconf.dat',STATUS='OLD')
            READ(1,*)NSPC
            DO J1=1,64
               READ(1,*)(CONF(J2,J1),J2=1,8)
            ENDDO
            CLOSE(1)
            OPEN (1,FILE='SPC2NPT.DAT',STATUS='UNKNOWN')
            WRITE(1,*)NSPC
            DO J1=1,64
               WRITE(1,*)(CONF(J2,J1),J2=1,8)
            ENDDO
            CLOSE(1)
         
      RETURN
      END
*
      SUBROUTINE PHOT3(INT,NFLV,XSECT,DXSECT,NHITO,FMAXO,EFFO,ANBIASO)
      IMPLICIT REAL*8 (A-H,O-Z)
*
      PARAMETER (LUX=4,K1=0,K2=0,LEN=25)
*
* BEGIN ALPHA
*
      PARAMETER (NMAX_ALPHA=8)
*
* END ALPHA
*
      REAL*4 EVENT(24),RVEC(LEN)
      CHARACTER*1 OGEN, OGEN0, NFLV
*
* BEGIN ALPHA
*
      REAL*8 MOMEN(4,NMAX_ALPHA),MOMEN_IN(4,NMAX_ALPHA)      !new
      REAL*8 MASSOUTGOING(NMAX_ALPHA)
      INTEGER INDEXOUTGOING(NMAX_ALPHA),INDEXINGOING(NMAX_ALPHA)    !new
      COMPLEX*16 ELMAT
      INTEGER COULORSOUR(NMAX_ALPHA)
      INTEGER NINGOING
*
* END ALPHA
*
      DIMENSION VEC(LEN)
*
C      DIMENSION CEVENT(24)
      common/kinevt/cevent(24),iacc
*
      DIMENSION PP(0:3),PM(0:3),Q1(0:3),Q2(0:3),Q3(0:3),Q4(0:3),Q5(0:3),
     #          Q1L(0:3),Q2L(0:3),Q3L(0:3),Q4L(0:3),Q5L(0:3)
      DIMENSION PARTIAL(128),conf(8,128)
*
      DIMENSION Q1MAX(0:3),Q2MAX(0:3),Q3MAX(0:3),Q4MAX(0:3),Q5MAX(0:3)
      DIMENSION Q1MAXL(0:3),Q2MAXL(0:3),Q3MAXL(0:3),Q4MAXL(0:3),
     #          Q5MAXL(0:3)
*
      COMMON/CMENERGY/RS,S
      COMMON/PAR/WM,WG,CFACT,GF,G,ZM,ZW,PI,ALPHA,EM2
      COMMON/PARD/ZM2,ZW2,WM2,WG2,GF2,G2,G4,G8
      COMMON/RPAR/RWM2,RWG2,RZM2,RZW2,RW,RZW,RW2
      COMMON/THETAW/STH2
      COMMON/EM/RL,ETA,BETA,SDELTA,BETAM
      COMMON/OG/OGEN
      COMMON/S2CH/NSCH
      COMMON/AIN/ALPHAI
      COMMON/EMC/IQED
      COMMON/RELACC/EPS
      COMMON/QCM/QMF1,QMF2,QMF3,QMF4,QMF5,QMF6
      COMMON/CHANN/ICHANNEL
      COMMON/CUTS/EGMINL,EGMAXL,CMINL,CMAXL
      COMMON/NG/NPHOT
      COMMON/CALLS/NHITWMAX,NHITMAX,NCALLS
      COMMON/MAXVALUE/FMAX
*
* BEGIN ALPHA
*
      COMMON/INTEGRA/MASSOUTGOING,
     #               NOUTGOING,INDEXOUTGOING,INDEXINGOING                 !new
      COMMON/COLOR/COULORSOUR
*
* END ALPHA
*
      NHITWMAX0 = NHITWMAX
      OGEN0 = OGEN
      OGEN = 'I'
*
      IF(NFLV.EQ.'E') THEN
         NFLMIN = 6
         NFLMAX = 6
      ELSE IF(NFLV.EQ.'M'.OR.NFLV.EQ.'T') THEN
         NFLMIN = 7
         NFLMAX = 7
      ELSE IF(NFLV.EQ.'F') THEN
         NFLMIN = 6
         NFLMAX = 7
      ENDIF
*
*-----REQUIRED BY THE GENERATING BRANCH
*
      DO IS = 1,4
         IF(IS.EQ.1) THEN 
            IFLAG_SPIN = 0
            NHITWMAX = 100000
         ELSE IF(IS.EQ.2) THEN
            IFLAG_SPIN = 1
            NHITWMAX = 100000
         ELSE IF(IS.EQ.3) THEN
            IFLAG_SPIN = 1
            NHITWMAX = 100000
         ELSE IF(IS.EQ.4) THEN
            IFLAG_SPIN = 1
            FMAX = FMAXO
            NHITWMAX = NHITWMAX0
            IF(OGEN0.EQ.'G') THEN
               OGEN = OGEN0
            ENDIF
         ENDIF
*         
         INIT_SPIN=0               !IT MUST BE 0 BEFORE ANY INTEGRATION LOOP
         INIT_FLAG=0               !IT MUST BE 0 BEFORE ANY INTEGRATION LOOP
         INIT_REG=0                !IT MUST BE 0 BEFORE ANY INTEGRATION LOOP
         NCONF=128                 !NUMBER OF SPIN CONFIGURATIONS
*
*-----INITIALIZE RANDOM GENERATION
*
         iin= 0
         iout = 0

         NMAX = NCALLS
         if (OGEN.eq.'I') then
         ICNT = 0
         NHIT = 0
         NHITW = 0
*
         FUNVAL = 0.D0
         FUNVALMAX= 0.D0
         ANBIAS = 0.D0
         NBIAS = 0
*
         FAV= 0.D0
         F2AV= 0.D0
*
*-----BEGIN ALPHA
*
         DO J=1,8
            COULORSOUR(J)=1
         ENDDO
*
*-----END ALPHA
*
*-----RANDOM NUMBER GENERATOR INITIALIZATION
*
C         CALL RLUXGO(LUX,INT,K1,K2)
         endif
*
*-----BEGINNING OF LOOP OVER EVENTS
*
         DO I = 1,NMAX
*
            ICNT = ICNT + 1
*
*-----RANDOM NUMBER GENERATION
*
            CALL RANLUX(RVEC,LEN)
*
            DO J = 1,LEN
               VEC(J) = RVEC(J)
            ENDDO
*
            X1BS = 1.D0
            X2BS = 1.D0
*
            IF(IQED.EQ.1) THEN
*
*-----MIN AND MAX FOR X1
*
               X1MIN = 0.D0
               X1MAX = 1.D0
*
               OMX1 = ((1.D0 - X1MIN)**(BETAM)*(1.D0 - VEC(1))
     #           +(1.D0 - X1MAX)**(BETAM)*VEC(1))**(1.D0/BETAM)
               X1 = 1.D0 - OMX1
*
*-----MIN AND MAX FOR X2
*
               X2MIN = 0.D0
               X2MAX = 1.D0
*
               OMX2 = ((1.D0 - X2MIN)**(BETAM)*(1.D0 - VEC(2))
     #           +(1.D0 - X2MAX)**(BETAM)*VEC(2))**(1.D0/BETAM)
               X2 = 1.D0 - OMX2       
*
            ELSE IF(IQED.EQ.0) THEN
               X1 = 1.D0
               X2 = 1.D0
            ENDIF
*
            X1D = X1
            X2D = X2
            X1 = X1BS*X1D
            X2 = X2BS*X2D
*                                                                      
            RZM2HAT = RZM2/X1/X2
            RZWHAT = RZW/X1/X2
            SHAT = X1*X2*S
            RSHAT = SQRT(SHAT)
*
            CMCTHG3 = VEC(3)
            CM125 = VEC(4)
            CM12 = VEC(5)
            CMG3 = VEC(6)
            CMG4 = VEC(7)
            CMPHIG34 = VEC(8)
            CMCTH5S = VEC(9)
            CMPHI5S = VEC(10)
            CMCTHS = VEC(11)
            CMPHIS = VEC(12)
            CMPHIG3 = VEC(13)
*
            IKINE = 0
*            
            CALL KINE3(iin,X1,X2,SHAT,CMCTHG3,CM125,CM12,CMG3,CMG4,
     #                 CMPHIG34,CMCTH5S,CMPHI5S,CMCTHS,CMPHIS,CMPHIG3,
     #                 ancthg3,pm1cthg3,ANRM125,PRQ125,ANRM12,PRQ12,
     #                 RZM2HAT,RZWHAT,F125,F12,ANEG3,XG3,ANEG4,XG4,
     #                 anphig34,ancth5s,anphi5s,
     #                 ancths,anphis,anphig3,
     #                 PP,PM,Q1,Q2,Q3,Q4,Q5,
     #                 Q1L,Q2L,Q3L,Q4L,Q5L,IKINE)
            IF(IKINE.GT.0) GO TO 1200
*
            REFN = VEC(25)*FMAX
*
            X_1 = X1
            X_2 = X2
            EB= RS/2.D0
*
            EGE = OMX1*EB
            CGE = 1.D0
            ANGE = 0.D0
            EGP = OMX2*EB
            CGP = -1.D0
            ANGP = 0.D0
*
            CEVENT(1) = X_1
            CEVENT(2) = X_2
            CEVENT(3) = EB
            CEVENT(4) = Q1L(1)
            CEVENT(5) = Q1L(2)
            CEVENT(6) = Q1L(3)
            CEVENT(7) = Q2L(1)
            CEVENT(8) = Q2L(2)
            CEVENT(9) = Q2L(3)
            CEVENT(10) = Q3L(1)
            CEVENT(11) = Q3L(2)
            CEVENT(12) = Q3L(3)
            CEVENT(13) = Q4L(1)
            CEVENT(14) = Q4L(2)
            CEVENT(15) = Q4L(3)
            CEVENT(16) = Q5L(1)
            CEVENT(17) = Q5L(2)
            CEVENT(18) = Q5L(3)
            CEVENT(19) = EGE
            CEVENT(20) = CGE
            CEVENT(21) = ANGE
            CEVENT(22) = EGP
            CEVENT(23) = CGP
            CEVENT(24) = ANGP   
*
*-----SUBROUTINE CUTUSER IS CALLED (I-BRANCH)
*
            CUTFLAG= 1.D0
            CALL ACCEPTANCE(CEVENT,CUTFLAG)
            IF(CUTFLAG.GT.0.D0) CALL CUTUSER(CEVENT,CUTFLAG)
            IF(CUTFLAG.GT.0.D0) THEN
               NHITW = NHITW+1
*
* BEGIN ALPHA
*
               DO III=1,4
                  MOMEN(III,1)= Q1(III-1)
                  MOMEN(III,2)= Q2(III-1)
                  MOMEN(III,3)= Q3(III-1)
                  MOMEN(III,4)= Q4(III-1)
                  MOMEN(III,5)= Q5(III-1)
               ENDDO
*
* spin sampling
*
               IF (IFLAG_SPIN.EQ.1) THEN

                  CALL SPINSAMPLING_NEW(vec(18),REDEFINED,SPINWEIGHT,
     >                                  nconf,INIT_flag)
               ELSE
                  REDEFINED=VEC(18)
                  SPINWEIGHT=1.
               ENDIF
*
               momen_in(1,1)=RSHAT/2.D0                  !new
               momen_in(2,1)=0.                  !new
               momen_in(3,1)=0.                  !new
               momen_in(4,1)=RSHAT/2.D0                  !new
*
               momen_in(1,2)=RSHAT/2.D0                  !new
               momen_in(2,2)=0.                  !new
               momen_in(3,2)=0.                  !new
               momen_in(4,2)=-RSHAT/2.D0                  !new
*
               ningoing=2                !new  number of ingoing particles
*
               ELMATSQ = 0.D0
               DO IFL = NFLMIN,NFLMAX

                  CALL PROCESSO_H(IFL)                 !new style
*
                  CALL FILLMOM(MOMEN,NOUTGOINGb,momen_in,ningoing)     !new
                  CALL SPINCOULOR_H(REDEFINED,NSPINCONF,LABEL,INIT_SPIN,
     >                   IFLAG_SPIN)
                  CALL ITERA(ELMAT)
*
                  IF(IFL.EQ.6) ELMATSQE = (ABS(ELMAT))**2
                  IF(IFL.EQ.7) ELMATSQM = (ABS(ELMAT))**2
               ENDDO
*
               IF(NFLV.EQ.'E') THEN
                  ELMATSQ = ELMATSQE
               ELSE IF(NFLV.EQ.'M'.OR.NFLV.EQ.'T') THEN
                  ELMATSQ = ELMATSQM
               ELSE IF(NFLV.EQ.'F') THEN
                  ELMATSQ = 2.D0*ELMATSQM + ELMATSQE
               ENDIF 
*
               EMTRX = ELMATSQ
               EMTRX = EMTRX * 32. * CFACT      
               EMTRX = EMTRX * SPINWEIGHT   ! SPIN RESCALING
*
               EMTRX = EMTRX*(4.D0*PI*ALPHA/G2/STH2)**3
*
* END ALPHA
*
               IF(IQED.EQ.1) THEN
*
*-----STRUCTURE FUNCTION NORM
*
                  AND1 = (1.D0-X1MIN)**BETAM-(1.D0-X1MAX)**BETAM
                  AND2 = (1.D0-X2MIN)**BETAM-(1.D0-X2MAX)**BETAM
*
                  FUNVAL = (2.D0*PI)**4/(2.D0*PI)**15/2.D0**7/2.D0*SHAT
     #                     *EMTRX*ANRM125*PRQ125*F125
     #                     *ANRM12*PRQ12*F12
     #                     *pm1cthg3*ANEG3*ANEG4*ANPHIG34
     #                     *ANCTH5S*ANPHI5S
     #                     *ANCTHS*ANPHIS*ANPHIG3
     #                     *XG3*XG4
     #                     *DOP(X1D)*DOP(X2D)*AND1*AND2       
C*
C*-----TEST: STRATIFIED SAMPLING OVER D(X)
C*
C                  IF(X1D.GT.XMED.AND.X2D.GT.XMED) THEN
C                     FUNVAL = (2.D0*PI)**4/(2.D0*PI)**15/2.D0**7
C     #                      /2.D0*SHAT
C     #                      *EMTRX*ANRM125*PRQ125*F125
C     #                      *ANRM12*PRQ12*F12
Cc     #                      *ANCTHG3*ANEG3*ANEG4*ANPHIG34
C     #                      *pm1cthg3*ANEG3*ANEG4*ANPHIG34
C     #                      *ANCTH5S*ANPHI5S
C     #                      *ANCTHS*ANPHIS*ANPHIG3
C     #                      *XG3*XG4
C     #                      *DOP(X1D)*DOP(X2D)*AND1*AND2       
C                   ELSE IF(X1D.LT.XMED.AND.X2D.GT.XMED) THEN
C                     FUNVAL = (2.D0*PI)**4/(2.D0*PI)**15/2.D0**7
C     #                      /2.D0*SHAT
C     #                      *EMTRX*ANRM125*PRQ125*F125
C     #                      *ANRM12*PRQ12*F12
Cc     #                      *ANCTHG3*ANEG3*ANEG4*ANPHIG34
C     #                      *pm1cthg3*ANEG3*ANEG4*ANPHIG34
C     #                      *ANCTH5S*ANPHI5S
C     #                      *ANCTHS*ANPHIS*ANPHIG3
C     #                      *XG3*XG4
C     #                      *D(X1D)*DOP(X2D)*AND1*AND2     
C                   ELSE IF(X1D.GT.XMED.AND.X2D.LT.XMED) THEN
C                     FUNVAL = (2.D0*PI)**4/(2.D0*PI)**15/2.D0**7
C     #                      /2.D0*SHAT
C     #                      *EMTRX*ANRM125*PRQ125*F125
C     #                      *ANRM12*PRQ12*F12
Cc     #                      *ANCTHG3*ANEG3*ANEG4*ANPHIG34
C     #                      *pm1cthg3*ANEG3*ANEG4*ANPHIG34
C     #                      *ANCTH5S*ANPHI5S
C     #                      *ANCTHS*ANPHIS*ANPHIG3
C     #                      *XG3*XG4
C     #                      *DOP(X1D)*D(X2D)*AND1*AND2     
C                   ELSE
C                     FUNVAL = (2.D0*PI)**4/(2.D0*PI)**15/2.D0**7
C     #                      /2.D0*SHAT
C     #                      *EMTRX*ANRM125*PRQ125*F125
C     #                      *ANRM12*PRQ12*F12
Cc     #                      *ANCTHG3*ANEG3*ANEG4*ANPHIG34
C     #                      *pm1cthg3*ANEG3*ANEG4*ANPHIG34
C     #                      *ANCTH5S*ANPHI5S
C     #                      *ANCTHS*ANPHIS*ANPHIG3
C     #                      *XG3*XG4
C     #                      *D(X1D)*D(X2D)*AND1*AND2     
C                   ENDIF
*
               ELSE IF(IQED.EQ.0) THEN
*
                  FUNVAL = (2.D0*PI)**4/(2.D0*PI)**15/2.D0**7/2.D0*SHAT
     #                     *EMTRX*ANRM125*PRQ125*F125
     #                     *ANRM12*PRQ12*F12
     #                     *pm1cthg3*ANEG3*ANEG4*ANPHIG34
     #                     *ANCTH5S*ANPHI5S
     #                     *ANCTHS*ANPHIS*ANPHIG3
     #                     *XG3*XG4
*
               ENDIF
*
            ELSE
               FUNVAL = 0.D0
            ENDIF
*
*-----STATISTICAL FACTOR FOR THREE INDISTINGUISHABLE PHOTONS
*
            FUNVAL = FUNVAL/6.D0
*
            X1DMAX= X1D
            X2DMAX= X2D
            RSHATMAX= SQRT(SHAT)
            q0tot= q1l(0)+q2l(0)+q3l(0)+q4l(0)+q5l(0)
            qxtot= q1l(1)+q2l(1)+q3l(1)+q4l(1)+q5l(1)
            qytot= q1l(2)+q2l(2)+q3l(2)+q4l(2)+q5l(2)
            qztot= q1l(3)+q2l(3)+q3l(3)+q4l(3)+q5l(3)
            qtotmax= sqrt(q0tot**2-qxtot**2-qytot**2-qztot**2)
            qztotmax= qztot+(X2DMAX-X1DMAX)*rs/2.d0
            absrshat= abs(rshat-qtotmax)
            if(absrshat.gt.1.d-4) then
               iout= iout+1
            endif                 
*
            IF(FUNVAL.GT.FUNVALMAX) THEN
               FUNVALMAX= FUNVAL
               DO JJ= 0,3
                  Q1MAX(JJ)= Q1(JJ)
                  Q2MAX(JJ)= Q2(JJ)
                  Q3MAX(JJ)= Q3(JJ)
                  Q4MAX(JJ)= Q4(JJ)
                  Q5MAX(JJ)= Q5(JJ)   
                  Q1MAXL(JJ)= Q1L(JJ)
                  Q2MAXL(JJ)= Q2L(JJ)
                  Q3MAXL(JJ)= Q3L(JJ)
                  Q4MAXL(JJ)= Q4L(JJ)
                  Q5MAXL(JJ)= Q5L(JJ)
               ENDDO
               X1DMAX= X1D
               X2DMAX= X2D
               RSHATMAX= SQRT(SHAT)
               q0tot= q1l(0)+q2l(0)+q3l(0)+q4l(0)+q5l(0)
               qxtot= q1l(1)+q2l(1)+q3l(1)+q4l(1)+q5l(1)
               qytot= q1l(2)+q2l(2)+q3l(2)+q4l(2)+q5l(2)
               qztot= q1l(3)+q2l(3)+q3l(3)+q4l(3)+q5l(3)
               qtotmax= sqrt(q0tot**2-qxtot**2-qytot**2-qztot**2)
               qztotmax= qztot+(X2DMAX-X1DMAX)*rs/2.d0 
            ENDIF
*
*-----AVERAGE AND SQUARED AVERAGE ARE CUMULATED (I-BRANCH)
*
            IF(OGEN.EQ.'I') THEN
*
               FAV = FAV + FUNVAL
               F2AV = F2AV + FUNVAL**2
*
               IF(NHITW.GE.NHITWMAX) GO TO 2200
*
            ELSE IF(OGEN.EQ.'G') THEN
*
*-----CHECK POSSIBLE BIAS (GENERATION BRANCH)
*
               IF(FUNVAL.GT.FMAX) THEN
                  NBIAS = NBIAS + 1
                  ANBIAS = NBIAS*1.D0
               ENDIF
*
               IF (REFN.LT.FUNVAL) THEN
                  NHIT = NHIT + 1
                  DO I1 = 1,24
                     EVENT(I1) = CEVENT(I1)
                  ENDDO
*
                  iacc = 1
               print *,' accepted event',(event(i1),i1=4,18)
                  CALL HFN(313,EVENT)
* 
               ENDIF
*
               IF(NHIT.GE.NHITMAX) GO TO 2200
            ENDIF
*
* BEGIN ALPHA
*
            WEIGHT = 1.D0
            if(funval.gt.0) 
     #         CALL REGSPIN_NEW
     #              (nspinconf,label,1,1,FUNVAL,weight,INIT_REG)
*
* END ALPHA
*
*-----END OF LOOP OVER EVENTS
*
 1200    END DO
*
*
* BEGIN ALPHA
*
 2200    CALL WRITESPIN
*
* END ALPHA
*
         AN = ICNT*1.D0
         FAV = FAV/AN
         F2AV = F2AV/AN
         DFAV = SQRT(F2AV - FAV**2)/SQRT(AN-1.D0)
         EFF = NHIT*1.D0/AN
         EFFW = NHITW*1.D0/AN
         REFV = FMAX
*
         IF(OGEN.EQ.'G') THEN
            XSECT = EFF*REFV
            DXSECT = REFV/SQRT(AN)*SQRT(EFF*(1.D0-EFF))
C            PRINT*, ' '
C            PRINT*, 'RS = ',RS
C            PRINT*, ' '
C            PRINT*, 'NHIT = ',NHIT
C            PRINT*, ' '
C            PRINT*, 'XSECT FOR UNWEIGHTED EVENTS'
C            PRINT*, ' '
C            PRINT*, 'EFF = ', EFF
C            PRINT*, 'XSECT = ', XSECT, ' +- ', DXSECT, ' (PB)'
C            PRINT*, 'NBIAS/NMAX = ', ANBIAS/AN
C            PRINT*, 'FMAX= ',FUNVALMAX
            NHITO = NHIT
            FMAXO = FUNVALMAX
            EFFO = EFF
            ANBIASO = ANBIAS/AN
         ELSE IF(OGEN.EQ.'I') THEN
            EFF = EFFW
            XSECT = FAV
            DXSECT = DFAV
C            PRINT*, ' '
C            PRINT*, 'RS = ',RS
C            PRINT*, ' '
C            PRINT*, 'NCALLS = ', NHITW
C            PRINT*, ' '
C            PRINT*, 'XSECT FOR WEIGHTED EVENTS'
C            PRINT*, ' '
C            PRINT*, 'EFF = ',EFFW
C            PRINT*, 'IIN = ',IIN
C            PRINT*, 'IOUT = ',IOUT
C            PRINT*, 'FMAX= ',FUNVALMAX
C            PRINT*, 'X1MAX= ',X1DMAX
C            PRINT*, 'X2MAX= ',X2DMAX
C            PRINT*, 'RSHATMAX= ',RSHATMAX
C            PRINT*,' QTOTMAX= ',QTOTMAX
C            PRINT*,' QZTOTMAX= ',QZTOTMAX    
C            PRINT*,' '
C            PRINT*, 'XSECT = ', FAV, ' +- ', DFAV, ' (PB)'
            NHITO = NHITW
            FMAXO = FUNVALMAX
            EFFO = EFF
            ANBIASO = 0.D0
          ENDIF
*
      ENDDO
*
         if (OGEN.eq.'I') then
         ICNT = 0
         NHIT = 0
         NHITW = 0
*
C         FUNVAL = 0.D0
C         FUNVALMAX= 0.D0
         ANBIAS = 0.D0
         NBIAS = 0
*
         FAV= 0.D0
         F2AV= 0.D0
*
*-----BEGIN ALPHA
*
         DO J=1,8
            COULORSOUR(J)=1
         ENDDO
*
*-----END ALPHA
*
*-----RANDOM NUMBER GENERATOR INITIALIZATION
*
C         CALL RLUXGO(LUX,INT,K1,K2)
      OPEN (1,FILE='spinbin.dat',STATUS='OLD')
      DO J1=1,128
         READ(1,*)PARTIAL(J1)
      ENDDO
      CLOSE(1)
      OPEN (1,FILE='SPB3NPT.DAT',STATUS='UNKNOWN')
      DO J1=1,128
         WRITE(1,*)PARTIAL(J1)
      ENDDO
      CLOSE(1)
      OPEN (1,FILE='spinconf.dat',STATUS='OLD')
      READ(1,*)NSPC
      DO J1=1,128
         READ(1,*)(CONF(J2,J1),J2=1,8)
      ENDDO
      CLOSE(1)
      OPEN (1,FILE='SPC3NPT.DAT',STATUS='UNKNOWN')
      WRITE(1,*)NSPC
      DO J1=1,128
         WRITE(1,*)(CONF(J2,J1),J2=1,8)
      ENDDO
      CLOSE(1)
*
      endif
      RETURN
      END
*
      SUBROUTINE PHOT1PT(INT,NFLV,XSECT,DXSECT,NHITO,FMAXO,EFFO,ANBIASO)
      IMPLICIT REAL*8 (A-H,O-Z)
*
      PARAMETER (LUX=4,K1=0,K2=0,LEN=25)
*
* BEGIN ALPHA
*
      PARAMETER (NMAX_ALPHA=8)
*
* END ALPHA
*
      REAL*4 EVENT(24),RVEC(LEN),sum(3)
      REAL*8 HP,HM,KP,KM

      CHARACTER*1 OGEN, OGEN0, NFLV
*
* BEGIN ALPHA
*
      INTEGER COULORSOUR(NMAX_ALPHA)
*
* END ALPHA
*
      DIMENSION VEC(LEN)
*
C      DIMENSION CEVENT(24)
      common/kinevt/cevent(24),iacc
      DIMENSION Q12(0:3),
     #          Q1S(0:3),Q2S(0:3),
     #          PP(0:3),PM(0:3),Q1(0:3),Q2(0:3),Q3(0:3),Q4(0:3),Q5(0:3),
     #          Q1L(0:3),Q2L(0:3),Q3L(0:3),Q4L(0:3),Q5L(0:3),PTOTL(0:3)
*
      DIMENSION RPRINT(LEN)
*
      COMMON/CMENERGY/RS,S
      COMMON/PAR/WM,WG,CFACT,GF,G,ZM,ZW,PI,ALPHA,EM2
      COMMON/PARD/ZM2,ZW2,WM2,WG2,GF2,G2,G4,G8
      COMMON/RPAR/RWM2,RWG2,RZM2,RZW2,RW,RZW,RW2
      COMMON/THETAW/STH2
      COMMON/EM/RL,ETA,BETA,SDELTA,BETAM
      COMMON/OG/OGEN
      COMMON/S2CH/NSCH
      COMMON/AIN/ALPHAI
      COMMON/EMC/IQED
      COMMON/RELACC/EPS
      COMMON/QCM/QMF1,QMF2,QMF3,QMF4,QMF5,QMF6
      COMMON/CHANN/ICHANNEL
      COMMON/CUTS/EGMINL,EGMAXL,CMINL,CMAXL
      COMMON/CVETO/CMINV,CMAXV
      COMMON/NG/NPHOT
      COMMON/CALLS/NHITWMAX,NHITMAX,NCALLS
      COMMON/MAXVALUE/FMAX
*
      IF(OGEN.EQ.'G') NHITWMAX = 100000
      NHITWMAX0 = NHITWMAX
      OGEN0 = OGEN
      OGEN = 'I'
*
      IF(OGEN0.EQ.'I') THEN
         ILGENMAX = 1
         ILGENMIN = 1
      ELSE
         ILGENMAX = 2
         ILGENMIN = 2
      ENDIF
*
      DO ILGEN = ILGENMIN,ILGENMAX
      IF(ILGEN.EQ.2) THEN
         OGEN = OGEN0
         FMAX = FUNVALMAX
      ENDIF
*
      EM = SQRT(EM2)
*
*-----REQUIRED BY THE GENERATING BRANCH  ! only once !
*
*-----INITIALIZE RANDOM GENERATION
*
      NMAX = NCALLS
      if (OGEN.eq.'I') then
      ICNT = 0
      NHIT = 0
*
      FUNVAL = 0.D0
      FUNVALMAX= 0.D0
      ANBIAS = 0.D0
      NBIAS = 0
*
      FAV= 0.D0
      F2AV= 0.D0
*
*-----BEGIN ALPHA
*
      DO J=1,8
         COULORSOUR(J)=1
      ENDDO
*
*-----RANDOM NUMBER GENERATOR INITIALIZATION
*
C      CALL RLUXGO(LUX,INT,K1,K2)
      endif
*
*-----BEGINNING OF LOOP OVER EVENTS
*
      DO I = 1,NMAX
*
         ICNT = ICNT + 1
*
*-----RANDOM NUMBER GENERATION
*
         CALL RANLUX(RVEC,LEN)
*
         DO J = 1,LEN
            VEC(J) = RVEC(J)
         ENDDO
*
         X1BS = 1.D0
         X2BS = 1.D0
*
*-----MIN AND MAX FOR X1
*
         X1MIN = 0.D0
         X1MAX = 1.D0
*
         OMX1 = ((1.D0 - X1MIN)**(BETAM)*(1.D0 - VEC(1))
     #        +(1.D0 - X1MAX)**(BETAM)*VEC(1))**(1.D0/BETAM)
         X1 = 1.D0 - OMX1
*
*-----MIN AND MAX FOR X2
*
         X2MIN = 0.D0
         X2MAX = 1.D0
*
         OMX2 = ((1.D0 - X2MIN)**(BETAM)*(1.D0 - VEC(2))
     #        +(1.D0 - X2MAX)**(BETAM)*VEC(2))**(1.D0/BETAM)
         X2 = 1.D0 - OMX2
*
         IF((X1.EQ.0.D0.AND.X2.EQ.1.D0).OR.
     #      (X2.EQ.0.D0.AND.X1.EQ.1.D0)) GO TO 1150
*
         X1D = X1
         X2D = X2
         OMX1D = OMX1
         OMX2D = OMX2
         X1 = X1BS*X1D
         X2 = X2BS*X2D
         OMX1 = 1.D0-X1
         OMX2 = 1.D0-X2
*                                                                      
*....P_T ON INITIAL STATE PHOTONS IS GENERATED
*
         EBEAM= RS/2.D0
*
         VOC = (1.D0 - EM/EBEAM)*(1.D0 + EM/EBEAM)
         VOC = SQRT(VOC)
         ANTHG = -LOG((1.D0-VOC)/(1.D0+VOC))/VOC
*
         CTHG1 = (1.D0-(1.D0+VOC)*EXP(-VOC*VEC(14)*ANTHG))/VOC
         CTHG2 = -(1.D0-(1.D0-VOC)*EXP(VOC*VEC(15)*ANTHG))/VOC
* 
         IF(CTHG1.GT.1.D0.OR.CTHG2.GT.1.D0) GO TO 1150
         if((1.D0-CTHG1*CTHG1).lt.0.d0) go to 1150
         if((1.D0-CTHG2*CTHG2).lt.0.d0) go to 1150
         STHG1 = SQRT(1.D0-CTHG1*CTHG1)
         STHG2 = SQRT(1.D0-CTHG2*CTHG2)
         ANGP = 2.D0*PI*VEC(16)
         CPHIGP = COS(ANGP)
         SPHIGP = SIN(ANGP)
         ANGE = 2.D0*PI*VEC(17)
         CPHIGE = COS(ANGE)
         SPHIGE = SIN(ANGE)
*
*.....I.S. RADIATED PHOTONS COMPONENTS AND I.S. LEPTONS MOMENTA (AFTER
*.....RADIATION)
*
         AKE0 = OMX1*EBEAM
         AKEXR = AKE0*STHG1*CPHIGE
         AKEYR = AKE0*STHG1*SPHIGE
         AKEZ = AKE0*CTHG1 
*
         AKP0 = OMX2*EBEAM
         AKPXR = AKP0*STHG2*CPHIGP
         AKPYR = AKP0*STHG2*SPHIGP
         AKPZ = AKP0*CTHG2
*
         PXE = -AKEXR
         PYE = -AKEYR
         PZE = EBEAM-AKEZ
         PXP = -AKPXR
         PYP = -AKPYR
         PZP = -EBEAM-AKPZ
         P0P = X2*EBEAM
         P0E = X1*EBEAM
*
         IF(AKE0.GT.EGMINL) THEN
            IF(CTHG1.LT.CMAXL.AND.CTHG1.GT.CMINL) GO TO 1150
         ENDIF
         IF(AKP0.GT.EGMINL) THEN
            IF(CTHG2.LT.CMAXL.AND.CTHG2.GT.CMINL) GO TO 1150
         ENDIF
         CALL VETO(AKE0,CTHG1,ANGE,AKP0,CTHG2,ANGP,IFLAGV)
         IF(IFLAGV.GT.0) GO TO 1150
*  
         SHAT = (RS-AKE0-AKP0)**2-(AKEXR+AKPXR)**2
     #        -(AKEYR+AKPYR)**2-(AKEZ+AKPZ)**2
*
         RZM2HAT = ZM2/SHAT
         RZWHAT = ZW*ZM/SHAT
*
         IF(SHAT.LT.0.D0) GO TO 1150    
*
         XM = X1 - X2
         XP = X1 + X2
         RSHAT = SQRT(SHAT)
*
*-----BOOST
*
         BLOR = XM/XP
         GLOR = XP/2.D0/SQRT(X1*X2)
*
*.....MIN AND MAX FOR THE PHOTON ANGLE IN C.M. FRAME
*
         CMAX = (CMAXL - BLOR)/(1.D0-BLOR*CMAXL)
         CMIN = (CMINL - BLOR)/(1.D0-BLOR*CMINL)
*
*-----angular sampling according to 1/(1-b^2 cthg^2) with b = 1
*
         arglog = ((1.d0+cmax)/(1.d0-cmax))*((1.d0-cmin)/(1.d0+cmin))
         ancthg = 0.5d0*log(arglog)
         rcmax = (1.d0+cmax)/(1.d0-cmax)
         rcmin = (1.d0-cmin)/(1.d0+cmin)
         cum = vec(3)
         cumm1 = vec(3) - 1.d0
         cthg = (rcmax**cum*rcmin**cumm1-1.d0)
     #         /(rcmax**cum*rcmin**cumm1+1.d0)
         pm1cthg = ancthg*(1.d0-cthg)*(1.d0+cthg)
*
*.....MIN AND MAX FOR THE PHOTON ENERGY IN C.M. FRAME
*
         OPBC = 1.D0 + BLOR*CTHG
         EGMAX0 = SQRT(SHAT)/2.D0
         EGMIN = EGMINL/GLOR/OPBC
         EGMAX = DMIN1(EGMAXL/GLOR/OPBC,EGMAX0)
         EBSTAR = SQRT(SHAT)/2.D0 
*
         ancth = 2.d0
         cth = ancth*VEC(4) -1.d0
*
         anphig = 2.d0*pi
         phig = 2.d0*pi*VEC(5)
*
         anphi = 2.d0*pi
         phi = 2.d0*pi*VEC(6)
*
*-----S' GENERATION
*
         CM12 = VEC(7)
         X12MIN = 1.D0-2.D0*EGMAX/RSHAT
         X12MAX = 1.D0-2.D0*EGMIN/RSHAT
         IF(X12MAX.LT.X12MIN) GO TO 1150
         ISBW= 1
         ISIR= 1
         CALL INVMBWIR(SHAT,CM12,X12MIN,X12MAX,RZM2HAT,RZWHAT,
     #                 Q122,ANRM12,PRQ12,ISBW,ISIR)
*
         IKINEI= 0
         CALL DPHI2(SHAT,0.D0,Q122,CTHG,PHIG,Q3,Q12,F123,IKINEI)
         CALL DPHI2(Q122,0.D0,0.D0,CTH,PHI,Q1S,Q2S,F12,IKINEI)
*
         IF(IKINEI.GT.0) GO TO 1150
         CALL BOOST(Q1S,Q12,Q1)
         CALL BOOST(Q2S,Q12,Q2)
*
         Q4(0) = 0.D0
         Q4(1) = 0.D0
         Q4(2) = 0.D0
         Q4(3) = 0.D0
         Q5(0) = 0.D0
         Q5(1) = 0.D0
         Q5(2) = 0.D0
         Q5(3) = 0.D0
*
         EBEAM= RS/2.D0
*
         EKECHECK= SQRT(AKEXR*AKEXR+AKEYR*AKEYR+AKEZ*AKEZ)
         EKPCHECK= SQRT(AKPXR*AKPXR+AKPYR*AKPYR+AKPZ*AKPZ)
         IF(EKECHECK.GT.EBEAM.OR.
     #      EKPCHECK.GT.EBEAM) GO TO 1150
*
         REFN = VEC(25)*FMAX
*
*-----EVENT DEFINITION
*
         RSHAT = SQRT(SHAT)
*
         PP(0) = RSHAT/2.D0
         PP(1) = 0.D0
         PP(2) = 0.D0
         PP(3) = -RSHAT/2.D0
         PM(0) = RSHAT/2.D0
         PM(1) = 0.D0
         PM(2) = 0.D0
         PM(3) = RSHAT/2.D0
*
         ENSUM= ABS(RSHAT - (Q1(0)+Q2(0)+Q3(0)))
         PXSUM= ABS(Q1(1)+Q2(1)+Q3(1))
         PYSUM= ABS(Q1(2)+Q2(2)+Q3(2))
         PZSUM= ABS(Q1(3)+Q2(3)+Q3(3))
         IF(ENSUM.GT.1.D-8.OR.
     #      PXSUM.GT.1.D-8.OR.
     #      PYSUM.GT.1.D-8.OR.
     #      PZSUM.GT.1.D-8) THEN
*
            PRINT*,'NEL C.M.'
            PRINT*,'ENSUM cm= ',ENSUM
            PRINT*,'PXSUM cm= ',PXSUM
            PRINT*,'PYSUM cm= ',PYSUM
            PRINT*,'PZSUM cm= ',PZSUM
            GO TO 1150
         ENDIF
*
         X_1 = X1
         X_2 = X2
         EB = RS/2.D0
*
*-----BOOST
*
         PTOTL(0) = (X1+X2)*EB
         PTOTL(1) = 0.D0
         PTOTL(2) = 0.D0
         PTOTL(3) = (X1-X2)*EB
*
         CALL BOOST(Q1,PTOTL,Q1L)
         CALL BOOST(Q2,PTOTL,Q2L)
         CALL BOOST(Q3,PTOTL,Q3L)
         CALL BOOST(Q4,PTOTL,Q4L)
         CALL BOOST(Q5,PTOTL,Q5L)
*
         AKEX = AKEXR
         AKEY = AKEYR
         AKPX = AKPXR
         AKPY = AKPYR
         EGE = SQRT(AKEX*AKEX+AKEY*AKEY+AKEZ*AKEZ)
         CGE = CTHG1
         EGP = SQRT(AKPX*AKPX+AKPY*AKPY+AKPZ*AKPZ)
         CGP = CTHG2 
*
         ENSUM= ABS(RS - (Q1L(0)+Q2L(0)+Q3L(0)) - EKECHECK - EKPCHECK)
         PXSUM= ABS(Q1L(1)+Q2L(1)+Q3L(1)+AKEX+AKPX)
         PYSUM= ABS(Q1L(2)+Q2L(2)+Q3L(2)+AKEY+AKPY)
         PZSUM= ABS(Q1L(3)+Q2L(3)+Q3L(3)+AKEZ+AKPZ)
         IF(ENSUM.GT.1.D-5.OR.
     #      PXSUM.GT.1.D-5.OR.
     #      PYSUM.GT.1.D-5.OR.
     #      PZSUM.GT.1.D-5) THEN
* 
C          print *,' non e-p conservation',pxsum,pysum,pzsum,ensum
         ENDIF
* 
         CEVENT(1) = X_1
         CEVENT(2) = X_2
         CEVENT(3) = EB
         CEVENT(4) = Q1L(1)
         CEVENT(5) = Q1L(2)
         CEVENT(6) = Q1L(3)
         CEVENT(7) = Q2L(1)
         CEVENT(8) = Q2L(2)
         CEVENT(9) = Q2L(3)
         CEVENT(10) = Q3L(1)
         CEVENT(11) = Q3L(2)
         CEVENT(12) = Q3L(3)
         CEVENT(13) = Q4L(1)
         CEVENT(14) = Q4L(2)
         CEVENT(15) = Q4L(3)
         CEVENT(16) = Q5L(1)
         CEVENT(17) = Q5L(2)
         CEVENT(18) = Q5L(3)
         CEVENT(19) = EGE
         CEVENT(20) = CGE
         CEVENT(21) = ANGE
         CEVENT(22) = EGP
         CEVENT(23) = CGP
         CEVENT(24) = ANGP   
*
*-----SUBROUTINE CUTUSER IS CALLED (I-BRANCH)
*
         CUTFLAG= 1.D0
         CALL ACCEPTANCE(CEVENT,CUTFLAG)
         IF(CUTFLAG.GT.0.D0) CALL CUTUSER(CEVENT,CUTFLAG)
         IF(CUTFLAG.GT.0.D0) THEN
            NHITW = NHITW+1
*
            SP = -2.D0*SCALPROD(Q1,Q2)
            TP = 2.D0*SCALPROD(PM,Q2)
            T = 2.D0*SCALPROD(PP,Q1)
            UP = 2.D0*SCALPROD(PM,Q1)
            U = 2.D0*SCALPROD(PP,Q2)
            HP = -2.D0*SCALPROD(PP,Q3)
            HM = -2.D0*SCALPROD(PM,Q3)
            KP = -2.D0*SCALPROD(Q1,Q3)
            KM = -2.D0*SCALPROD(Q2,Q3)
*
            call dnunug(nflv,Q1,Q2,Q3,
     #                  SHAT,HP,HM,KP,KM,SP,TP,T,UP,U,emtrx)
            emtrx= emtrx*cfact
*
*-----STRUCTURE FUNCTION NORM
*
            AND1 = (1.D0-X1MIN)**BETAM-(1.D0-X1MAX)**BETAM
            AND2 = (1.D0-X2MIN)**BETAM-(1.D0-X2MAX)**BETAM
*
            FUNVAL = (2.D0*PI)**4/16.D0/(2.D0*PI)**9/2.D0
     #               *EMTRX*F123*F12
     #               *PM1CTHG*ANPHIG*ANCTH*ANPHI
     #               *ANRM12*PRQ12*DOP(X1D)*DOP(X2D)*AND1*AND2
     #               *ANTHG*ANTHG
     #               *(1.D0-VOC*CTHG1)*(1.D0+VOC*CTHG2)
     #               *CGLEAD(CTHG1)*CGLEAD(-CTHG2)
*
         ELSE
            FUNVAL = 0.D0
         ENDIF
*
         IF(FUNVAL.GT.FUNVALMAX) THEN 
            FUNVALMAX= FUNVAL
            X1PRINT= X1
            X2PRINT= X2
            RSHATPRINT= SQRT(SHAT)
            Q10PRINT= SQRT(Q1L(1)*Q1L(1)+Q1L(2)*Q1L(2)+Q1L(3)*Q1L(3))
            Q1XPRINT= Q1L(1)
            Q1YPRINT= Q1L(2)
            Q1ZPRINT= Q1L(3)
            Q20PRINT= SQRT(Q2L(1)*Q2L(1)+Q2L(2)*Q2L(2)+Q2L(3)*Q2L(3))
            Q2XPRINT= Q2L(1)
            Q2YPRINT= Q2L(2)
            Q2ZPRINT= Q2L(3)
            Q30PRINT= SQRT(Q3L(1)*Q3L(1)+Q3L(2)*Q3L(2)+Q3L(3)*Q3L(3))
            Q3XPRINT= Q3L(1)
            Q3YPRINT= Q3L(2)
            Q3ZPRINT= Q3L(3)
            EMTRXPRINT= EMTRX
            F123PRINT= F123
            F12PRINT= F12
            ANCTHGPRINT= ANCTHG
            ANPHIGPRINT= ANPHIG
            ANPHIPRINT= ANPHI
            ANCTHPRINT= ANCTH
            ANRM12PRINT= ANRM12
            PRQ12PRINT= PRQ12
            DOPX1PRINT= DOP(X1D)
            DOPX2PRINT= DOP(X2D)
            AND1PRINT= AND1
            AND2PRINT= AND2
            DO JJ=1,LEN
               RPRINT(JJ)= VEC(JJ)
            ENDDO
            SPPRINT= SP
            TPPRINT= TP
            TPRINT= T
            UPPRINT= UP
            UPRINT= U
            HPPRINT= HP
            HMPRINT= HM
            AKPPRINT= KP
            AKMPRINT= KM
         ENDIF
*
*-----AVERAGE AND SQUARED AVERAGE ARE CUMULATED (I-BRANCH)
*
         IF(OGEN.EQ.'I') THEN
*
            FAV = FAV + FUNVAL
            F2AV = F2AV + FUNVAL**2
*
            IF(NHITW.GE.NHITWMAX) GO TO 2150
*
         ELSE IF(OGEN.EQ.'G') THEN
*
*-----CHECK POSSIBLE BIAS (GENERATION BRANCH)
*
            IF(FUNVAL.GT.FMAX) THEN
               NBIAS = NBIAS + 1
               ANBIAS = NBIAS*1.D0
            ENDIF
*
            IF(REFN.LT.FUNVAL) THEN
               NHIT = NHIT + 1
               DO I1 = 1,24
                  EVENT(I1) = CEVENT(I1)
               ENDDO
*
               iacc = 1
C               print *,' accepted event',icnt,(event(i1),i1=4,18)
               do i1 = 1,3
                 sum(i1) = 0.
                 do i2 = 1,5
                 sum(i1) = sum(i1) + event(3+3*(i2-1)+i1)
                 enddo
                 if (i1.eq.1) then
                 sum(i1) = sum(i1) + ege*cos(ange)*sqrt(1.d0-cge*cge)
     &                     + egp*cos(angp)*sqrt(1-cgp*cgp)
                 else if (i1.eq.2) then
                 sum(i1) = sum(i1) + ege*sin(ange)*sqrt(1.d0-cge*cge)
     &                     + egp*sin(angp)*sqrt(1-cgp*cgp)
                 else if (i1.eq.3) then
                 sum(i1) = sum(i1) + ege*cge + egp*cgp
                 endif
            if (abs(sum(i1)).gt.2.) print *,'p nonconserved',i1,sum(i1)
               enddo
               CALL HFN(313,EVENT)
* 
            ENDIF
*
            IF(NHIT.GE.NHITMAX) GO TO 2150
         ENDIF
*
 1150 END DO
*
 2150 AN = ICNT*1.D0
      FAV = FAV/AN
      F2AV = F2AV/AN
      DFAV = SQRT(F2AV - FAV**2)/SQRT(AN-1.D0)
      EFF = NHIT*1.D0/AN
      EFFW = NHITW*1.D0/AN
      REFV = FMAX
*
      IF(OGEN.EQ.'G') THEN
         XSECT = EFF*REFV
         DXSECT = REFV/SQRT(AN)*SQRT(EFF*(1.D0-EFF))
         NHITO = NHIT
         FMAXO = FUNVALMAX
         EFFO = EFF
         ANBIASO = ANBIAS/AN
      ELSE IF(OGEN.EQ.'I') THEN
         EFF = EFFW
         XSECT = FAV
         DXSECT = DFAV
         NHITO = NHITW
         FMAXO = FUNVALMAX
         EFFO = EFF
         ANBIASO = 0.D0

*
      ENDIF
      ENDDO
*  reset everything for the generation step later
      if (OGEN.eq.'I') then
      ICNT = 0
      NHIT = 0
*
C      FUNVAL = 0.D0
C      FUNVALMAX= 0.D0
      ANBIAS = 0.D0
      NBIAS = 0
*
      FAV= 0.D0
      F2AV= 0.D0
*
*-----BEGIN ALPHA
*
      DO J=1,8
         COULORSOUR(J)=1
      ENDDO

      endif
      RETURN
      END
*
      SUBROUTINE PHOT1PTM(INT,NFLV,XSECT,DXSECT,NHITO,FMAXO,
     #                    EFFO,ANBIASO)
      IMPLICIT REAL*8 (A-H,O-Z)
      REAL*8 MNU,MNU2
*
      PARAMETER (LUX=4,K1=0,K2=0,LEN=25)
*
* BEGIN ALPHA
*
      PARAMETER (NMAX_ALPHA=8)
*
* END ALPHA
*
      REAL*4 EVENT(24),RVEC(LEN)
      REAL*8 HP,HM,KP,KM

      CHARACTER*1 OGEN, OGEN0, NFLV
*
* BEGIN ALPHA
*
      INTEGER COULORSOUR(NMAX_ALPHA)
*
* END ALPHA
*
      DIMENSION VEC(LEN)
*
C      DIMENSION CEVENT(24)
      common/kinevt/cevent(24),iacc
*
      DIMENSION Q12(0:3),
     #          Q1S(0:3),Q2S(0:3),
     #          PP(0:3),PM(0:3),Q1(0:3),Q2(0:3),Q3(0:3),Q4(0:3),Q5(0:3),
     #          Q1L(0:3),Q2L(0:3),Q3L(0:3),Q4L(0:3),Q5L(0:3),PTOTL(0:3)
*
      DIMENSION RPRINT(LEN)
*
      COMMON/CMENERGY/RS,S
      COMMON/PAR/WM,WG,CFACT,GF,G,ZM,ZW,PI,ALPHA,EM2
      COMMON/PARD/ZM2,ZW2,WM2,WG2,GF2,G2,G4,G8
      COMMON/RPAR/RWM2,RWG2,RZM2,RZW2,RW,RZW,RW2
      COMMON/THETAW/STH2
      COMMON/EM/RL,ETA,BETA,SDELTA,BETAM
      COMMON/OG/OGEN
      COMMON/S2CH/NSCH
      COMMON/AIN/ALPHAI
      COMMON/EMC/IQED
      COMMON/RELACC/EPS
      COMMON/QCM/QMF1,QMF2,QMF3,QMF4,QMF5,QMF6
      COMMON/CHANN/ICHANNEL
      COMMON/CUTS/EGMINL,EGMAXL,CMINL,CMAXL
      COMMON/CVETO/CMINV,CMAXV
      COMMON/NG/NPHOT
      COMMON/CALLS/NHITWMAX,NHITMAX,NCALLS
      COMMON/MAXVALUE/FMAX
      COMMON/NUMASS/MNU,MNU2

*
      IF(OGEN.EQ.'G') NHITWMAX = 100000
      NHITWMAX0 = NHITWMAX
      OGEN0 = OGEN
      OGEN = 'I'
*
      IF(OGEN0.EQ.'I') THEN
         ILGENMAX = 1
         ILGENMIN = 1
      ELSE
         ILGENMAX = 2
         ILGENMIN = 2
      ENDIF
*
      DO ILGEN = ILGENMIN,ILGENMAX
      IF(ILGEN.EQ.2) THEN
         OGEN = OGEN0
         FMAX = FUNVALMAX
      ENDIF
*
      EM = SQRT(EM2)
*
*-----REQUIRED BY THE GENERATING BRANCH
*
*-----INITIALIZE RANDOM GENERATION
*
      NMAX = NCALLS
      if (OGEN.eq.'I') then
      ICNT = 0
      NHIT = 0
*
      FUNVAL = 0.D0
      FUNVALMAX= 0.D0
      ANBIAS = 0.D0
      NBIAS = 0
*
      FAV= 0.D0
      F2AV= 0.D0
*
*-----BEGIN ALPHA
*
      DO J=1,8
         COULORSOUR(J)=1
      ENDDO
*
*-----RANDOM NUMBER GENERATOR INITIALIZATION
*
C      CALL RLUXGO(LUX,INT,K1,K2)
      endif
*
*-----BEGINNING OF LOOP OVER EVENTS
*
      DO I = 1,NMAX
*
         ICNT = ICNT + 1
*
*-----RANDOM NUMBER GENERATION
*
         CALL RANLUX(RVEC,LEN)
*
         DO J = 1,LEN
            VEC(J) = RVEC(J)
         ENDDO
*
         X1BS = 1.D0
         X2BS = 1.D0
*
*-----MIN AND MAX FOR X1
*
         X1MIN = 0.D0
         X1MAX = 1.D0
*
         OMX1 = ((1.D0 - X1MIN)**(BETAM)*(1.D0 - VEC(1))
     #        +(1.D0 - X1MAX)**(BETAM)*VEC(1))**(1.D0/BETAM)
         X1 = 1.D0 - OMX1
*
*-----MIN AND MAX FOR X2
*
         X2MIN = 0.D0
         X2MAX = 1.D0
*
         OMX2 = ((1.D0 - X2MIN)**(BETAM)*(1.D0 - VEC(2))
     #        +(1.D0 - X2MAX)**(BETAM)*VEC(2))**(1.D0/BETAM)
         X2 = 1.D0 - OMX2
*
         IF((X1.EQ.0.D0.AND.X2.EQ.1.D0).OR.
     #      (X2.EQ.0.D0.AND.X1.EQ.1.D0)) GO TO 1158
*
         X1D = X1
         X2D = X2
         OMX1D = OMX1
         OMX2D = OMX2
         X1 = X1BS*X1D
         X2 = X2BS*X2D
         OMX1 = 1.D0-X1
         OMX2 = 1.D0-X2
*                                                                      
*....P_T ON INITIAL STATE PHOTONS IS GENERATED
*
         EBEAM= RS/2.D0
*
         VOC = (1.D0 - EM/EBEAM)*(1.D0 + EM/EBEAM)
         VOC = SQRT(VOC)
         ANTHG = -LOG((1.D0-VOC)/(1.D0+VOC))/VOC
*
         CTHG1 = (1.D0-(1.D0+VOC)*EXP(-VOC*VEC(14)*ANTHG))/VOC
         CTHG2 = -(1.D0-(1.D0-VOC)*EXP(VOC*VEC(15)*ANTHG))/VOC
* 
         IF(CTHG1.GT.1.D0.OR.CTHG2.GT.1.D0) GO TO 1158
         if((1.D0-CTHG1*CTHG1).lt.0.d0) go to 1158
         if((1.D0-CTHG2*CTHG2).lt.0.d0) go to 1158
         STHG1 = SQRT(1.D0-CTHG1*CTHG1)
         STHG2 = SQRT(1.D0-CTHG2*CTHG2)
         ANGP = 2.D0*PI*VEC(16)
         CPHIGP = COS(ANGP)
         SPHIGP = SIN(ANGP)
         ANGE = 2.D0*PI*VEC(17)
         CPHIGE = COS(ANGE)
         SPHIGE = SIN(ANGE)
*
*.....I.S. RADIATED PHOTONS COMPONENTS AND I.S. LEPTONS MOMENTA (AFTER
*.....RADIATION)
*
         AKE0 = OMX1*EBEAM
         AKEXR = AKE0*STHG1*CPHIGE
         AKEYR = AKE0*STHG1*SPHIGE
         AKEZ = AKE0*CTHG1 
*
         AKP0 = OMX2*EBEAM
         AKPXR = AKP0*STHG2*CPHIGP
         AKPYR = AKP0*STHG2*SPHIGP
         AKPZ = AKP0*CTHG2
*
         PXE = -AKEXR
         PYE = -AKEYR
         PZE = EBEAM-AKEZ
         PXP = -AKPXR
         PYP = -AKPYR
         PZP = -EBEAM-AKPZ
         P0P = X2*EBEAM
         P0E = X1*EBEAM
*
         IF(AKE0.GT.EGMINL) THEN
            IF(CTHG1.LT.CMAXL.AND.CTHG1.GT.CMINL) GO TO 1158
         ENDIF
         IF(AKP0.GT.EGMINL) THEN
            IF(CTHG2.LT.CMAXL.AND.CTHG2.GT.CMINL) GO TO 1158
         ENDIF
         CALL VETO(AKE0,CTHG1,ANGE,AKP0,CTHG2,ANGP,IFLAGV)
         IF(IFLAGV.GT.0) GO TO 1158
*  
         SHAT = (RS-AKE0-AKP0)**2-(AKEXR+AKPXR)**2
     #        -(AKEYR+AKPYR)**2-(AKEZ+AKPZ)**2
*
         RZM2HAT = ZM2/SHAT
         RZWHAT = ZW*ZM/SHAT
*
         IF(SHAT.LT.0.D0) GO TO 1158    
*
         XM = X1 - X2
         XP = X1 + X2
         RSHAT = SQRT(SHAT)
*
*-----BOOST
*
         BLOR = XM/XP
         GLOR = XP/2.D0/SQRT(X1*X2)
*
*.....MIN AND MAX FOR THE PHOTON ANGLE IN C.M. FRAME
*
         CMAX = (CMAXL - BLOR)/(1.D0-BLOR*CMAXL)
         CMIN = (CMINL - BLOR)/(1.D0-BLOR*CMINL)
*
*-----angular sampling according to 1/(1-b^2 cthg^2) with b = 1
*
         arglog = ((1.d0+cmax)/(1.d0-cmax))*((1.d0-cmin)/(1.d0+cmin))
         ancthg = 0.5d0*log(arglog)
         rcmax = (1.d0+cmax)/(1.d0-cmax)
         rcmin = (1.d0-cmin)/(1.d0+cmin)
         cum = vec(3)
         cumm1 = vec(3) - 1.d0
         cthg = (rcmax**cum*rcmin**cumm1-1.d0)
     #         /(rcmax**cum*rcmin**cumm1+1.d0)
         pm1cthg = ancthg*(1.d0-cthg)*(1.d0+cthg)
*
*.....MIN AND MAX FOR THE PHOTON ENERGY IN C.M. FRAME
*
         OPBC = 1.D0 + BLOR*CTHG
         EGMAX0 = SQRT(SHAT)/2.D0
         EGMIN = EGMINL/GLOR/OPBC
         EGMAX = DMIN1(EGMAXL/GLOR/OPBC,EGMAX0)
         EBSTAR = SQRT(SHAT)/2.D0
*
         EGMNXNEU = (EBSTAR*EBSTAR-MNU2)/EBSTAR
         EGMAX = DMIN1(EGMAX,EGMNXNEU) 
*
         ancth = 2.d0
         cth = ancth*VEC(4) -1.d0
*
         anphig = 2.d0*pi
         phig = 2.d0*pi*VEC(5)
*
         anphi = 2.d0*pi
         phi = 2.d0*pi*VEC(6)
*
*-----S' GENERATION
*
         CM12 = VEC(7)
         X12MIN = 1.D0-2.D0*EGMAX/RSHAT
         X12MAX = 1.D0-2.D0*EGMIN/RSHAT
         IF(X12MAX.LT.X12MIN) GO TO 1158
         ISBW= 1
         ISIR= 1
         CALL INVMBWIR(SHAT,CM12,X12MIN,X12MAX,RZM2HAT,RZWHAT,
     #                 Q122,ANRM12,PRQ12,ISBW,ISIR)
*
         IKINEI= 0
         CALL DPHI2(SHAT,0.D0,Q122,CTHG,PHIG,Q3,Q12,F123,IKINEI)
         CALL DPHI2(Q122,MNU2,MNU2,CTH,PHI,Q1S,Q2S,F12,IKINEI)
*
         IF(IKINEI.GT.0) GO TO 1158
         CALL BOOST(Q1S,Q12,Q1)
         CALL BOOST(Q2S,Q12,Q2)
*
         Q4(0) = 0.D0
         Q4(1) = 0.D0
         Q4(2) = 0.D0
         Q4(3) = 0.D0
         Q5(0) = 0.D0
         Q5(1) = 0.D0
         Q5(2) = 0.D0
         Q5(3) = 0.D0
*
         EBEAM= RS/2.D0
*
         EKECHECK= SQRT(AKEXR*AKEXR+AKEYR*AKEYR+AKEZ*AKEZ)
         EKPCHECK= SQRT(AKPXR*AKPXR+AKPYR*AKPYR+AKPZ*AKPZ)
         IF(EKECHECK.GT.EBEAM.OR.
     #      EKPCHECK.GT.EBEAM) GO TO 1158
*
         REFN = VEC(25)*FMAX
*
*-----EVENT DEFINITION
*
         RSHAT = SQRT(SHAT)
*
         PP(0) = RSHAT/2.D0
         PP(1) = 0.D0
         PP(2) = 0.D0
         PP(3) = -RSHAT/2.D0
         PM(0) = RSHAT/2.D0
         PM(1) = 0.D0
         PM(2) = 0.D0
         PM(3) = RSHAT/2.D0
*
         ENSUM= ABS(RSHAT - (Q1(0)+Q2(0)+Q3(0)))
         PXSUM= ABS(Q1(1)+Q2(1)+Q3(1))
         PYSUM= ABS(Q1(2)+Q2(2)+Q3(2))
         PZSUM= ABS(Q1(3)+Q2(3)+Q3(3))
         IF(ENSUM.GT.1.D-8.OR.
     #      PXSUM.GT.1.D-8.OR.
     #      PYSUM.GT.1.D-8.OR.
     #      PZSUM.GT.1.D-8) THEN
*
            PRINT*,'NEL C.M.'
            PRINT*,'ENSUM cm= ',ENSUM
            PRINT*,'PXSUM cm= ',PXSUM
            PRINT*,'PYSUM cm= ',PYSUM
            PRINT*,'PZSUM cm= ',PZSUM
            GO TO 1158
         ENDIF
*
         X_1 = X1
         X_2 = X2
         EB = RS/2.D0
*
*-----BOOST
*
         PTOTL(0) = (X1+X2)*EB
         PTOTL(1) = 0.D0
         PTOTL(2) = 0.D0
         PTOTL(3) = (X1-X2)*EB
*
         CALL BOOST(Q1,PTOTL,Q1L)
         CALL BOOST(Q2,PTOTL,Q2L)
         CALL BOOST(Q3,PTOTL,Q3L)
         CALL BOOST(Q4,PTOTL,Q4L)
         CALL BOOST(Q5,PTOTL,Q5L)
*
         AKEX = AKEXR
         AKEY = AKEYR
         AKPX = AKPXR
         AKPY = AKPYR
         EGE = SQRT(AKEX*AKEX+AKEY*AKEY+AKEZ*AKEZ)
         CGE = CTHG1
         EGP = SQRT(AKPX*AKPX+AKPY*AKPY+AKPZ*AKPZ)
         CGP = CTHG2 
*
         ENSUM= ABS(RS - (Q1L(0)+Q2L(0)+Q3L(0)) - EKECHECK - EKPCHECK)
         PXSUM= ABS(Q1L(1)+Q2L(1)+Q3L(1)+AKEX+AKPX)
         PYSUM= ABS(Q1L(2)+Q2L(2)+Q3L(2)+AKEY+AKPY)
         PZSUM= ABS(Q1L(3)+Q2L(3)+Q3L(3)+AKEZ+AKPZ)
         IF(ENSUM.GT.1.D-6.OR.
     #      PXSUM.GT.1.D-6.OR.
     #      PYSUM.GT.1.D-6.OR.
     #      PZSUM.GT.1.D-6) THEN
* 
         ENDIF
* 
         CEVENT(1) = X_1
         CEVENT(2) = X_2
         CEVENT(3) = EB
         CEVENT(4) = Q1L(1)
         CEVENT(5) = Q1L(2)
         CEVENT(6) = Q1L(3)
         CEVENT(7) = Q2L(1)
         CEVENT(8) = Q2L(2)
         CEVENT(9) = Q2L(3)
         CEVENT(10) = Q3L(1)
         CEVENT(11) = Q3L(2)
         CEVENT(12) = Q3L(3)
         CEVENT(13) = Q4L(1)
         CEVENT(14) = Q4L(2)
         CEVENT(15) = Q4L(3)
         CEVENT(16) = Q5L(1)
         CEVENT(17) = Q5L(2)
         CEVENT(18) = Q5L(3)
         CEVENT(19) = EGE
         CEVENT(20) = CGE
         CEVENT(21) = ANGE
         CEVENT(22) = EGP
         CEVENT(23) = CGP
         CEVENT(24) = ANGP   
*
*-----SUBROUTINE CUTUSER IS CALLED (I-BRANCH)
*
         CUTFLAG= 1.D0
         CALL ACCEPTANCE(CEVENT,CUTFLAG)
         IF(CUTFLAG.GT.0.D0) CALL CUTUSER(CEVENT,CUTFLAG)
         IF(CUTFLAG.GT.0.D0) THEN
            NHITW = NHITW+1
*
            SP = -2.D0*SCALPROD(Q1,Q2) + 2.D0*MNU2
            TP = 2.D0*SCALPROD(PM,Q2) + MNU2
            T = 2.D0*SCALPROD(PP,Q1) + MNU2
            UP = 2.D0*SCALPROD(PM,Q1) + MNU2
            U = 2.D0*SCALPROD(PP,Q2) + MNU2
            HP = -2.D0*SCALPROD(PP,Q3)
            HM = -2.D0*SCALPROD(PM,Q3)
            KP = -2.D0*SCALPROD(Q1,Q3) + MNU2
            KM = -2.D0*SCALPROD(Q2,Q3) + MNU2
*
            call dnunugm(nflv,Q1,Q2,Q3,
     #                   SHAT,HP,HM,KP,KM,SP,TP,T,UP,U,emtrx)
            emtrx= emtrx*cfact
*
*-----STRUCTURE FUNCTION NORM
*
            AND1 = (1.D0-X1MIN)**BETAM-(1.D0-X1MAX)**BETAM
            AND2 = (1.D0-X2MIN)**BETAM-(1.D0-X2MAX)**BETAM
*
            FUNVAL = (2.D0*PI)**4/16.D0/(2.D0*PI)**9/2.D0
     #               *EMTRX*F123*F12
     #               *PM1CTHG*ANPHIG*ANCTH*ANPHI
     #               *ANRM12*PRQ12*DOP(X1D)*DOP(X2D)*AND1*AND2
     #               *ANTHG*ANTHG
     #               *(1.D0-VOC*CTHG1)*(1.D0+VOC*CTHG2)
     #               *CGLEAD(CTHG1)*CGLEAD(-CTHG2)
*
         ELSE
            FUNVAL = 0.D0
         ENDIF
*
         IF(FUNVAL.GT.FUNVALMAX) THEN 
            FUNVALMAX= FUNVAL
            X1PRINT= X1
            X2PRINT= X2
            RSHATPRINT= SQRT(SHAT)
            Q10PRINT= SQRT(Q1L(1)*Q1L(1)+Q1L(2)*Q1L(2)+Q1L(3)*Q1L(3))
            Q1XPRINT= Q1L(1)
            Q1YPRINT= Q1L(2)
            Q1ZPRINT= Q1L(3)
            Q20PRINT= SQRT(Q2L(1)*Q2L(1)+Q2L(2)*Q2L(2)+Q2L(3)*Q2L(3))
            Q2XPRINT= Q2L(1)
            Q2YPRINT= Q2L(2)
            Q2ZPRINT= Q2L(3)
            Q30PRINT= SQRT(Q3L(1)*Q3L(1)+Q3L(2)*Q3L(2)+Q3L(3)*Q3L(3))
            Q3XPRINT= Q3L(1)
            Q3YPRINT= Q3L(2)
            Q3ZPRINT= Q3L(3)
            EMTRXPRINT= EMTRX
            F123PRINT= F123
            F12PRINT= F12
            ANCTHGPRINT= ANCTHG
            ANPHIGPRINT= ANPHIG
            ANPHIPRINT= ANPHI
            ANCTHPRINT= ANCTH
            ANRM12PRINT= ANRM12
            PRQ12PRINT= PRQ12
            DOPX1PRINT= DOP(X1D)
            DOPX2PRINT= DOP(X2D)
            AND1PRINT= AND1
            AND2PRINT= AND2
            DO JJ=1,LEN
               RPRINT(JJ)= VEC(JJ)
            ENDDO
            SPPRINT= SP
            TPPRINT= TP
            TPRINT= T
            UPPRINT= UP
            UPRINT= U
            HPPRINT= HP
            HMPRINT= HM
            AKPPRINT= KP
            AKMPRINT= KM
         ENDIF
*
*-----AVERAGE AND SQUARED AVERAGE ARE CUMULATED (I-BRANCH)
*
         IF(OGEN.EQ.'I') THEN
*
            FAV = FAV + FUNVAL
            F2AV = F2AV + FUNVAL**2
*
            IF(NHITW.GE.NHITWMAX) GO TO 2158
*
         ELSE IF(OGEN.EQ.'G') THEN
*
*-----CHECK POSSIBLE BIAS (GENERATION BRANCH)
*
            IF(FUNVAL.GT.FMAX) THEN
               NBIAS = NBIAS + 1
               ANBIAS = NBIAS*1.D0
            ENDIF
*
            IF(REFN.LT.FUNVAL) THEN
               NHIT = NHIT + 1
               DO I1 = 1,24
                  EVENT(I1) = CEVENT(I1)
               ENDDO
*
               iacc = 1
               print *,' accepted event',(event(i1),i1=4,18)
               CALL HFN(313,EVENT)
* 
            ENDIF
*
            IF(NHIT.GE.NHITMAX) GO TO 2158
         ENDIF
*
 1158 END DO
*
 2158 AN = ICNT*1.D0
      FAV = FAV/AN
      F2AV = F2AV/AN
      DFAV = SQRT(F2AV - FAV**2)/SQRT(AN-1.D0)
      EFF = NHIT*1.D0/AN
      EFFW = NHITW*1.D0/AN
      REFV = FMAX
*
      IF(OGEN.EQ.'G') THEN
         XSECT = EFF*REFV
         DXSECT = REFV/SQRT(AN)*SQRT(EFF*(1.D0-EFF))
         NHITO = NHIT
         FMAXO = FUNVALMAX
         EFFO = EFF
         ANBIASO = ANBIAS/AN
      ELSE IF(OGEN.EQ.'I') THEN
         EFF = EFFW
         XSECT = FAV
         DXSECT = DFAV
         NHITO = NHITW
         FMAXO = FUNVALMAX
         EFFO = EFF
         ANBIASO = 0.D0
*
      ENDIF
      ENDDO
*
      if (OGEN.eq.'I') then
      ICNT = 0
      NHIT = 0
*
C      FUNVAL = 0.D0
C      FUNVALMAX= 0.D0
      ANBIAS = 0.D0
      NBIAS = 0
*
      FAV= 0.D0
      F2AV= 0.D0
*
*-----BEGIN ALPHA
*
      DO J=1,8
         COULORSOUR(J)=1
      ENDDO
*
*-----RANDOM NUMBER GENERATOR INITIALIZATION
*
C      CALL RLUXGO(LUX,INT,K1,K2)
      endif
      RETURN
      END
*
      SUBROUTINE PHOT1G(VEC,NFLV,FMAXO,NHITO,ANBIASO)
      IMPLICIT REAL*8 (A-H,O-Z)
*
      PARAMETER (LEN=25)
*
* BEGIN ALPHA
*
      PARAMETER (NMAX_ALPHA=8)
*
* END ALPHA
*
      REAL*4 EVENT(24)
      REAL*8 HP,HM,KP,KM

      CHARACTER*1 OGEN, NFLV
*
      DIMENSION VEC(LEN)
*
C      DIMENSION CEVENT(24)
      common/kinevt/cevent(24),iacc
*
      DIMENSION Q12(0:3),
     #          Q1S(0:3),Q2S(0:3),
     #          PP(0:3),PM(0:3),Q1(0:3),Q2(0:3),Q3(0:3),Q4(0:3),Q5(0:3),
     #          Q1L(0:3),Q2L(0:3),Q3L(0:3),Q4L(0:3),Q5L(0:3),PTOTL(0:3)
*
      COMMON/CMENERGY/RS,S
      COMMON/PAR/WM,WG,CFACT,GF,G,ZM,ZW,PI,ALPHA,EM2
      COMMON/PARD/ZM2,ZW2,WM2,WG2,GF2,G2,G4,G8
      COMMON/RPAR/RWM2,RWG2,RZM2,RZW2,RW,RZW,RW2
      COMMON/THETAW/STH2
      COMMON/EM/RL,ETA,BETA,SDELTA,BETAM
      COMMON/OG/OGEN
      COMMON/S2CH/NSCH
      COMMON/AIN/ALPHAI
      COMMON/EMC/IQED
      COMMON/RELACC/EPS
      COMMON/QCM/QMF1,QMF2,QMF3,QMF4,QMF5,QMF6
      COMMON/CHANN/ICHANNEL
      COMMON/CUTS/EGMINL,EGMAXL,CMINL,CMAXL
      COMMON/NG/NPHOT
      COMMON/CALLS/NHITWMAX,NHITMAX,NCALLS
      COMMON/MAXVALUE/FMAX
*
      FMAX = FMAXO
*
      EM = SQRT(EM2)
*
*-----INITIALIZE RANDOM GENERATION
*
      NMAX = NCALLS
      if (OGEN.eq.'I') then
      ICNT = 0
      NHIT = 0
*
      FUNVAL = 0.D0
      FUNVALMAX= 0.D0
      ANBIAS = 0.D0
      NBIAS = 0
*
      X1BS = 1.D0
      X2BS = 1.D0
      endif
*
*-----MIN AND MAX FOR X1
*
         X1MIN = 0.D0
         X1MAX = 1.D0
*
         OMX1 = ((1.D0 - X1MIN)**(BETAM)*(1.D0 - VEC(1))
     #        +(1.D0 - X1MAX)**(BETAM)*VEC(1))**(1.D0/BETAM)
         X1 = 1.D0 - OMX1
*
*-----MIN AND MAX FOR X2
*
         X2MIN = 0.D0
         X2MAX = 1.D0
*
         OMX2 = ((1.D0 - X2MIN)**(BETAM)*(1.D0 - VEC(2))
     #        +(1.D0 - X2MAX)**(BETAM)*VEC(2))**(1.D0/BETAM)
         X2 = 1.D0 - OMX2
*
         IF((X1.EQ.0.D0.AND.X2.EQ.1.D0).OR.
     #      (X2.EQ.0.D0.AND.X1.EQ.1.D0)) GOTO 1151
*
         X1D = X1
         X2D = X2
         OMX1D = OMX1
         OMX2D = OMX2
         X1 = X1BS*X1D
         X2 = X2BS*X2D
         OMX1 = 1.D0-X1
         OMX2 = 1.D0-X2
*                                    
*....P_T ON INITIAL STATE PHOTONS IS GENERATED
*
         EBEAM= RS/2.D0
*
         VOC = (1.D0 - EM/EBEAM)*(1.D0 + EM/EBEAM)
         VOC = SQRT(VOC)
         ANTHG = -LOG((1.D0-VOC)/(1.D0+VOC))/VOC
*
         CTHG1 = (1.D0-(1.D0+VOC)*EXP(-VOC*VEC(14)*ANTHG))/VOC
         CTHG2 = -(1.D0-(1.D0-VOC)*EXP(VOC*VEC(15)*ANTHG))/VOC
* 
         IF(CTHG1.GT.1.D0.OR.CTHG2.GT.1.D0) GO TO 1151
         if((1.D0-CTHG1*CTHG1).lt.0.d0) go to 1151
         if((1.D0-CTHG2*CTHG2).lt.0.d0) go to 1151
         STHG1 = SQRT(1.D0-CTHG1*CTHG1)
         STHG2 = SQRT(1.D0-CTHG2*CTHG2)
         ANGP = 2.D0*PI*VEC(16)
         CPHIGP = COS(ANGP)
         SPHIGP = SIN(ANGP)
         ANGE = 2.D0*PI*VEC(17)
         CPHIGE = COS(ANGE)
         SPHIGE = SIN(ANGE)
*
*.....I.S. RADIATED PHOTONS COMPONENTS AND I.S. LEPTONS MOMENTA (AFTER
*.....RADIATION)
*
         AKE0 = OMX1*EBEAM
         AKEXR = AKE0*STHG1*CPHIGE
         AKEYR = AKE0*STHG1*SPHIGE
         AKEZ = AKE0*CTHG1 
*
         AKP0 = OMX2*EBEAM
         AKPXR = AKP0*STHG2*CPHIGP
         AKPYR = AKP0*STHG2*SPHIGP
         AKPZ = AKP0*CTHG2
*
         PXE = -AKEXR
         PYE = -AKEYR
         PZE = EBEAM-AKEZ
         PXP = -AKPXR
         PYP = -AKPYR
         PZP = -EBEAM-AKPZ
         P0P = X2*EBEAM
         P0E = X1*EBEAM
*
         SHAT = (RS-AKE0-AKP0)**2-(AKEXR+AKPXR)**2
     #        -(AKEYR+AKPYR)**2-(AKEZ+AKPZ)**2
*
         IF(AKE0.GT.EGMINL) THEN
            IF(CTHG1.LT.CMAXL.AND.CTHG1.GT.CMINL) GO TO 1151
         ENDIF
         IF(AKP0.GT.EGMINL) THEN
            IF(CTHG2.LT.CMAXL.AND.CTHG2.GT.CMINL) GO TO 1151
         ENDIF  
         CALL VETO(AKE0,CTHG1,ANGE,AKP0,CTHG2,ANGP,IFLAGV)
         IF(IFLAGV.GT.0) GO TO 1151
*
         RZM2HAT = ZM2/SHAT
         RZWHAT = ZW*ZM/SHAT
*
         IF(SHAT.LT.0.D0) GO TO 1151    
*
         XM = X1 - X2
         XP = X1 + X2
*
         RSHAT = SQRT(SHAT)
*
         BLOR = XM/XP
         GLOR = XP/2.D0/SQRT(X1*X2)
*
*.....MIN AND MAX FOR THE PHOTON ANGLE IN C.M. FRAME
*
         CMAX = (CMAXL - BLOR)/(1.D0-BLOR*CMAXL)
         CMIN = (CMINL - BLOR)/(1.D0-BLOR*CMINL)
*
         arglog = ((1.d0+cmax)/(1.d0-cmax))*((1.d0-cmin)/(1.d0+cmin))
         ancthg = 0.5d0*log(arglog)
         rcmax = (1.d0+cmax)/(1.d0-cmax)
         rcmin = (1.d0-cmin)/(1.d0+cmin)
         cum = vec(3)
         cumm1 = vec(3) - 1.d0
         cthg = (rcmax**cum*rcmin**cumm1-1.d0)
     #         /(rcmax**cum*rcmin**cumm1+1.d0)
         pm1cthg = ancthg*(1.d0-cthg)*(1.d0+cthg) 
*
*.....MIN AND MAX FOR THE PHOTON ENERGY IN C.M. FRAME
*
         OPBC = 1.D0 + BLOR*CTHG
         EGMAX0 = SQRT(SHAT)/2.D0
         EGMIN = EGMINL/GLOR/OPBC
         EGMAX = DMIN1(EGMAXL/GLOR/OPBC,EGMAX0)
         EBSTAR = SQRT(SHAT)/2.D0 
*
         ancth = 2.d0
         cth = ancth*VEC(4) -1.d0
*
         anphig = 2.d0*pi
         phig = 2.d0*pi*VEC(5)
*
         anphi = 2.d0*pi
         phi = 2.d0*pi*VEC(6)
*
*-----S' GENERATION
*
         CM12 = VEC(7)
         X12MIN = 1.D0-2.D0*EGMAX/RSHAT
         X12MAX = 1.D0-2.D0*EGMIN/RSHAT
         IF(X12MAX.LT.X12MIN) GO TO 1151
         ISBW= 1
         ISIR= 1
         CALL INVMBWIR(SHAT,CM12,X12MIN,X12MAX,RZM2HAT,RZWHAT,
     #                 Q122,ANRM12,PRQ12,ISBW,ISIR)
*
         IKINEI= 0
         CALL DPHI2(SHAT,0.D0,Q122,CTHG,PHIG,Q3,Q12,F123,IKINEI)
         CALL DPHI2(Q122,0.D0,0.D0,CTH,PHI,Q1S,Q2S,F12,IKINEI)
*
         IF(IKINEI.GT.0) GO TO 1151
         CALL BOOST(Q1S,Q12,Q1)
         CALL BOOST(Q2S,Q12,Q2)
*
         Q4(0) = 0.D0
         Q4(1) = 0.D0
         Q4(2) = 0.D0
         Q4(3) = 0.D0
         Q5(0) = 0.D0
         Q5(1) = 0.D0
         Q5(2) = 0.D0
         Q5(3) = 0.D0
*
         EBEAM= RS/2.D0
*
         EKECHECK= SQRT(AKEXR*AKEXR+AKEYR*AKEYR+AKEZ*AKEZ)
         EKPCHECK= SQRT(AKPXR*AKPXR+AKPYR*AKPYR+AKPZ*AKPZ)
         IF(EKECHECK.GT.EBEAM.OR.
     #      EKPCHECK.GT.EBEAM) GO TO 1151
*
         REFN = VEC(25)*FMAX
*
*-----EVENT DEFINITION
*
         RSHAT = SQRT(SHAT)
*
         PP(0) = RSHAT/2.D0
         PP(1) = 0.D0
         PP(2) = 0.D0
         PP(3) = -RSHAT/2.D0
         PM(0) = RSHAT/2.D0
         PM(1) = 0.D0
         PM(2) = 0.D0
         PM(3) = RSHAT/2.D0
*
         ENSUM= ABS(RSHAT - (Q1(0)+Q2(0)+Q3(0)))
         PXSUM= ABS(Q1(1)+Q2(1)+Q3(1))
         PYSUM= ABS(Q1(2)+Q2(2)+Q3(2))
         PZSUM= ABS(Q1(3)+Q2(3)+Q3(3))
         IF(ENSUM.GT.1.D-8.OR.
     #      PXSUM.GT.1.D-8.OR.
     #      PYSUM.GT.1.D-8.OR.
     #      PZSUM.GT.1.D-8) THEN
*
            PRINT*,'IN C.M.'
            PRINT*,'ENSUM cm= ',ENSUM
            PRINT*,'PXSUM cm= ',PXSUM
            PRINT*,'PYSUM cm= ',PYSUM
            PRINT*,'PZSUM cm= ',PZSUM
            GO TO 1151
         ENDIF
*
         X_1 = X1
         X_2 = X2
         EB = RS/2.D0
*
*-----BOOST
*
         PTOTL(0) = (X1+X2)*EB
         PTOTL(1) = 0.D0
         PTOTL(2) = 0.D0
         PTOTL(3) = (X1-X2)*EB
*
         CALL BOOST(Q1,PTOTL,Q1L)
         CALL BOOST(Q2,PTOTL,Q2L)
         CALL BOOST(Q3,PTOTL,Q3L)
         CALL BOOST(Q4,PTOTL,Q4L)
         CALL BOOST(Q5,PTOTL,Q5L)
*
         AKEX = AKEXR
         AKEY = AKEYR
         AKPX = AKPXR
         AKPY = AKPYR
         EGE = SQRT(AKEX*AKEX+AKEY*AKEY+AKEZ*AKEZ)
         CGE = CTHG1
         EGP = SQRT(AKPX*AKPX+AKPY*AKPY+AKPZ*AKPZ)
         CGP = CTHG2 
*
         ENSUM= ABS(RS - (Q1L(0)+Q2L(0)+Q3L(0)) - EKECHECK - EKPCHECK)
         PXSUM= ABS(Q1L(1)+Q2L(1)+Q3L(1)+AKEX+AKPX)
         PYSUM= ABS(Q1L(2)+Q2L(2)+Q3L(2)+AKEY+AKPY)
         PZSUM= ABS(Q1L(3)+Q2L(3)+Q3L(3)+AKEZ+AKPZ)
         IF(ENSUM.GT.1.D-6.OR.
     #      PXSUM.GT.1.D-6.OR.
     #      PYSUM.GT.1.D-6.OR.
     #      PZSUM.GT.1.D-6) THEN
* 
         ENDIF
* 
         CEVENT(1) = X_1
         CEVENT(2) = X_2
         CEVENT(3) = EB
         CEVENT(4) = Q1L(1)
         CEVENT(5) = Q1L(2)
         CEVENT(6) = Q1L(3)
         CEVENT(7) = Q2L(1)
         CEVENT(8) = Q2L(2)
         CEVENT(9) = Q2L(3)
         CEVENT(10) = Q3L(1)
         CEVENT(11) = Q3L(2)
         CEVENT(12) = Q3L(3)
         CEVENT(13) = Q4L(1)
         CEVENT(14) = Q4L(2)
         CEVENT(15) = Q4L(3)
         CEVENT(16) = Q5L(1)
         CEVENT(17) = Q5L(2)
         CEVENT(18) = Q5L(3)
         CEVENT(19) = EGE
         CEVENT(20) = CGE
         CEVENT(21) = ANGE
         CEVENT(22) = EGP
         CEVENT(23) = CGP
         CEVENT(24) = ANGP
*
*-----SUBROUTINE CUTUSER IS CALLED (I-BRANCH)
*
         CUTFLAG= 1.D0
         CALL ACCEPTANCE(CEVENT,CUTFLAG)
         IF(CUTFLAG.GT.0.D0) CALL CUTUSER(CEVENT,CUTFLAG)
         IF(CUTFLAG.GT.0.D0) THEN
            NHITW = NHITW+1
*
*-----con elicita`
*
            SP = -2.D0*SCALPROD(Q1,Q2)
            TP = 2.D0*SCALPROD(PM,Q2)
            T = 2.D0*SCALPROD(PP,Q1)
            UP = 2.D0*SCALPROD(PM,Q1)
            U = 2.D0*SCALPROD(PP,Q2)
            HP = -2.D0*SCALPROD(PP,Q3)
            HM = -2.D0*SCALPROD(PM,Q3)
            KP = -2.D0*SCALPROD(Q1,Q3)
            KM = -2.D0*SCALPROD(Q2,Q3)
*
            call dnunug(nflv,Q1,Q2,Q3,
     #                  SHAT,HP,HM,KP,KM,SP,TP,T,UP,U,emtrx)
            emtrx= emtrx*cfact
*
*-----STRUCTURE FUNCTION NORM
*
            AND1 = (1.D0-X1MIN)**BETAM-(1.D0-X1MAX)**BETAM
            AND2 = (1.D0-X2MIN)**BETAM-(1.D0-X2MAX)**BETAM
*
            FUNVAL = (2.D0*PI)**4/16.D0/(2.D0*PI)**9/2.D0
     #               *EMTRX*F123*F12
     #               *pm1cthg*ANPHIG*ANCTH*ANPHI
     #               *ANRM12*PRQ12*DOP(X1D)*DOP(X2D)*AND1*AND2
     #               *ANTHG*ANTHG
     #               *(1.D0-VOC*CTHG1)*(1.D0+VOC*CTHG2)
     #               *CGLEAD(CTHG1)*CGLEAD(-CTHG2)
*
         ELSE
            FUNVAL = 0.D0
         ENDIF
*
            IF(FUNVAL.GT.FMAX) THEN
               NBIAS = NBIAS + 1
               ANBIAS = NBIAS*1.D0
            ENDIF
*
            IF(REFN.LT.FUNVAL) THEN
               NHIT = NHIT + 1
               DO I1 = 1,24
                  EVENT(I1) = CEVENT(I1)
               ENDDO
*
               iacc=1
               print *,' accepted event',(event(i1),i1=4,18)
               CALL HFN(313,EVENT)
* 
            ENDIF
*
      NHITO = NHIT
      ANBIASO = ANBIAS
 1151 RETURN
*
      END
*
      SUBROUTINE PHOT1GM(VEC,NFLV,FMAXO,NHITO,ANBIASO)
      IMPLICIT REAL*8 (A-H,O-Z)
      REAL*8 MNU,MNU2
*
      PARAMETER (LEN=25)
*
* BEGIN ALPHA
*
      PARAMETER (NMAX_ALPHA=8)
*
* END ALPHA
*
      REAL*4 EVENT(24)
      REAL*8 HP,HM,KP,KM

      CHARACTER*1 OGEN, NFLV
*
      DIMENSION VEC(LEN)
*
C      DIMENSION CEVENT(24)
      common/kinevt/cevent(24),iacc
*
      DIMENSION Q12(0:3),
     #          Q1S(0:3),Q2S(0:3),
     #          PP(0:3),PM(0:3),Q1(0:3),Q2(0:3),Q3(0:3),Q4(0:3),Q5(0:3),
     #          Q1L(0:3),Q2L(0:3),Q3L(0:3),Q4L(0:3),Q5L(0:3),PTOTL(0:3)
*
      COMMON/CMENERGY/RS,S
      COMMON/PAR/WM,WG,CFACT,GF,G,ZM,ZW,PI,ALPHA,EM2
      COMMON/PARD/ZM2,ZW2,WM2,WG2,GF2,G2,G4,G8
      COMMON/RPAR/RWM2,RWG2,RZM2,RZW2,RW,RZW,RW2
      COMMON/THETAW/STH2
      COMMON/EM/RL,ETA,BETA,SDELTA,BETAM
      COMMON/OG/OGEN
      COMMON/S2CH/NSCH
      COMMON/AIN/ALPHAI
      COMMON/EMC/IQED
      COMMON/RELACC/EPS
      COMMON/QCM/QMF1,QMF2,QMF3,QMF4,QMF5,QMF6
      COMMON/CHANN/ICHANNEL
      COMMON/CUTS/EGMINL,EGMAXL,CMINL,CMAXL
      COMMON/NG/NPHOT
      COMMON/CALLS/NHITWMAX,NHITMAX,NCALLS
      COMMON/MAXVALUE/FMAX
      COMMON/NUMASS/MNU,MNU2
*
      FMAX = FMAXO
*
      EM = SQRT(EM2)
*
*-----INITIALIZE RANDOM GENERATION
*
      NMAX = NCALLS
      if (OGEN.eq.'I') then
      ICNT = 0
      NHIT = 0
*
      FUNVAL = 0.D0
      FUNVALMAX= 0.D0
      ANBIAS = 0.D0
      NBIAS = 0
*
      X1BS = 1.D0
      X2BS = 1.D0
      endif
*
*-----MIN AND MAX FOR X1
*
         X1MIN = 0.D0
         X1MAX = 1.D0
*
         OMX1 = ((1.D0 - X1MIN)**(BETAM)*(1.D0 - VEC(1))
     #        +(1.D0 - X1MAX)**(BETAM)*VEC(1))**(1.D0/BETAM)
         X1 = 1.D0 - OMX1
*
*-----MIN AND MAX FOR X2
*
         X2MIN = 0.D0
         X2MAX = 1.D0
*
         OMX2 = ((1.D0 - X2MIN)**(BETAM)*(1.D0 - VEC(2))
     #        +(1.D0 - X2MAX)**(BETAM)*VEC(2))**(1.D0/BETAM)
         X2 = 1.D0 - OMX2
*
         IF((X1.EQ.0.D0.AND.X2.EQ.1.D0).OR.
     #      (X2.EQ.0.D0.AND.X1.EQ.1.D0)) GOTO 1159
*
         X1D = X1
         X2D = X2
         OMX1D = OMX1
         OMX2D = OMX2
         X1 = X1BS*X1D
         X2 = X2BS*X2D
         OMX1 = 1.D0-X1
         OMX2 = 1.D0-X2
*                                    
*....P_T ON INITIAL STATE PHOTONS IS GENERATED
*
         EBEAM= RS/2.D0
*
         VOC = (1.D0 - EM/EBEAM)*(1.D0 + EM/EBEAM)
         VOC = SQRT(VOC)
         ANTHG = -LOG((1.D0-VOC)/(1.D0+VOC))/VOC
*
         CTHG1 = (1.D0-(1.D0+VOC)*EXP(-VOC*VEC(14)*ANTHG))/VOC
         CTHG2 = -(1.D0-(1.D0-VOC)*EXP(VOC*VEC(15)*ANTHG))/VOC
* 
         IF(CTHG1.GT.1.D0.OR.CTHG2.GT.1.D0) GO TO 1159
         if((1.D0-CTHG1*CTHG1).lt.0.d0) go to 1159
         if((1.D0-CTHG2*CTHG2).lt.0.d0) go to 1159
         STHG1 = SQRT(1.D0-CTHG1*CTHG1)
         STHG2 = SQRT(1.D0-CTHG2*CTHG2)
         ANGP = 2.D0*PI*VEC(16)
         CPHIGP = COS(ANGP)
         SPHIGP = SIN(ANGP)
         ANGE = 2.D0*PI*VEC(17)
         CPHIGE = COS(ANGE)
         SPHIGE = SIN(ANGE)
*
*.....I.S. RADIATED PHOTONS COMPONENTS AND I.S. LEPTONS MOMENTA (AFTER
*.....RADIATION)
*
         AKE0 = OMX1*EBEAM
         AKEXR = AKE0*STHG1*CPHIGE
         AKEYR = AKE0*STHG1*SPHIGE
         AKEZ = AKE0*CTHG1 
*
         AKP0 = OMX2*EBEAM
         AKPXR = AKP0*STHG2*CPHIGP
         AKPYR = AKP0*STHG2*SPHIGP
         AKPZ = AKP0*CTHG2
*
         PXE = -AKEXR
         PYE = -AKEYR
         PZE = EBEAM-AKEZ
         PXP = -AKPXR
         PYP = -AKPYR
         PZP = -EBEAM-AKPZ
         P0P = X2*EBEAM
         P0E = X1*EBEAM
*
         SHAT = (RS-AKE0-AKP0)**2-(AKEXR+AKPXR)**2
     #        -(AKEYR+AKPYR)**2-(AKEZ+AKPZ)**2
*
         IF(AKE0.GT.EGMINL) THEN
            IF(CTHG1.LT.CMAXL.AND.CTHG1.GT.CMINL) GO TO 1159
         ENDIF
         IF(AKP0.GT.EGMINL) THEN
            IF(CTHG2.LT.CMAXL.AND.CTHG2.GT.CMINL) GO TO 1159
         ENDIF  
         CALL VETO(AKE0,CTHG1,ANGE,AKP0,CTHG2,ANGP,IFLAGV)
         IF(IFLAGV.GT.0) GO TO 1159
*
         RZM2HAT = ZM2/SHAT
         RZWHAT = ZW*ZM/SHAT
*
         IF(SHAT.LT.0.D0) GO TO 1159    
*
         XM = X1 - X2
         XP = X1 + X2
*
         RSHAT = SQRT(SHAT)
*
         BLOR = XM/XP
         GLOR = XP/2.D0/SQRT(X1*X2)
*
*.....MIN AND MAX FOR THE PHOTON ANGLE IN C.M. FRAME
*
         CMAX = (CMAXL - BLOR)/(1.D0-BLOR*CMAXL)
         CMIN = (CMINL - BLOR)/(1.D0-BLOR*CMINL)
*
         arglog = ((1.d0+cmax)/(1.d0-cmax))*((1.d0-cmin)/(1.d0+cmin))
         ancthg = 0.5d0*log(arglog)
         rcmax = (1.d0+cmax)/(1.d0-cmax)
         rcmin = (1.d0-cmin)/(1.d0+cmin)
         cum = vec(3)
         cumm1 = vec(3) - 1.d0
         cthg = (rcmax**cum*rcmin**cumm1-1.d0)
     #         /(rcmax**cum*rcmin**cumm1+1.d0)
         pm1cthg = ancthg*(1.d0-cthg)*(1.d0+cthg) 
*
*.....MIN AND MAX FOR THE PHOTON ENERGY IN C.M. FRAME
*
         OPBC = 1.D0 + BLOR*CTHG
         EGMAX0 = SQRT(SHAT)/2.D0
         EGMIN = EGMINL/GLOR/OPBC
         EGMAX = DMIN1(EGMAXL/GLOR/OPBC,EGMAX0)
         EBSTAR = SQRT(SHAT)/2.D0 
*
         EGMNXNEU = (EBSTAR*EBSTAR-MNU2)/EBSTAR
         EGMAX = DMIN1(EGMAX,EGMNXNEU)
*
         ancth = 2.d0
         cth = ancth*VEC(4) -1.d0
*
         anphig = 2.d0*pi
         phig = 2.d0*pi*VEC(5)
*
         anphi = 2.d0*pi
         phi = 2.d0*pi*VEC(6)
*
*-----S' GENERATION
*
         CM12 = VEC(7)
         X12MIN = 1.D0-2.D0*EGMAX/RSHAT
         X12MAX = 1.D0-2.D0*EGMIN/RSHAT
         IF(X12MAX.LT.X12MIN) GO TO 1159
         ISBW= 1
         ISIR= 1
         CALL INVMBWIR(SHAT,CM12,X12MIN,X12MAX,RZM2HAT,RZWHAT,
     #                 Q122,ANRM12,PRQ12,ISBW,ISIR)
*
         IKINEI= 0
         CALL DPHI2(SHAT,0.D0,Q122,CTHG,PHIG,Q3,Q12,F123,IKINEI)
         CALL DPHI2(Q122,MNU2,MNU2,CTH,PHI,Q1S,Q2S,F12,IKINEI)
*
         IF(IKINEI.GT.0) GO TO 1159
         CALL BOOST(Q1S,Q12,Q1)
         CALL BOOST(Q2S,Q12,Q2)
*
         Q4(0) = 0.D0
         Q4(1) = 0.D0
         Q4(2) = 0.D0
         Q4(3) = 0.D0
         Q5(0) = 0.D0
         Q5(1) = 0.D0
         Q5(2) = 0.D0
         Q5(3) = 0.D0
*
         EBEAM= RS/2.D0
*
         EKECHECK= SQRT(AKEXR*AKEXR+AKEYR*AKEYR+AKEZ*AKEZ)
         EKPCHECK= SQRT(AKPXR*AKPXR+AKPYR*AKPYR+AKPZ*AKPZ)
         IF(EKECHECK.GT.EBEAM.OR.
     #      EKPCHECK.GT.EBEAM) GO TO 1159
*
         REFN = VEC(25)*FMAX
*
*-----EVENT DEFINITION
*
         RSHAT = SQRT(SHAT)
*
         PP(0) = RSHAT/2.D0
         PP(1) = 0.D0
         PP(2) = 0.D0
         PP(3) = -RSHAT/2.D0
         PM(0) = RSHAT/2.D0
         PM(1) = 0.D0
         PM(2) = 0.D0
         PM(3) = RSHAT/2.D0
*
         ENSUM= ABS(RSHAT - (Q1(0)+Q2(0)+Q3(0)))
         PXSUM= ABS(Q1(1)+Q2(1)+Q3(1))
         PYSUM= ABS(Q1(2)+Q2(2)+Q3(2))
         PZSUM= ABS(Q1(3)+Q2(3)+Q3(3))
         IF(ENSUM.GT.1.D-8.OR.
     #      PXSUM.GT.1.D-8.OR.
     #      PYSUM.GT.1.D-8.OR.
     #      PZSUM.GT.1.D-8) THEN
*
            PRINT*,'IN C.M.'
            PRINT*,'ENSUM cm= ',ENSUM
            PRINT*,'PXSUM cm= ',PXSUM
            PRINT*,'PYSUM cm= ',PYSUM
            PRINT*,'PZSUM cm= ',PZSUM
            GO TO 1159
         ENDIF
*
         X_1 = X1
         X_2 = X2
         EB = RS/2.D0
*
*-----BOOST
*
         PTOTL(0) = (X1+X2)*EB
         PTOTL(1) = 0.D0
         PTOTL(2) = 0.D0
         PTOTL(3) = (X1-X2)*EB
*
         CALL BOOST(Q1,PTOTL,Q1L)
         CALL BOOST(Q2,PTOTL,Q2L)
         CALL BOOST(Q3,PTOTL,Q3L)
         CALL BOOST(Q4,PTOTL,Q4L)
         CALL BOOST(Q5,PTOTL,Q5L)
*
         AKEX = AKEXR
         AKEY = AKEYR
         AKPX = AKPXR
         AKPY = AKPYR
         EGE = SQRT(AKEX*AKEX+AKEY*AKEY+AKEZ*AKEZ)
         CGE = CTHG1
         EGP = SQRT(AKPX*AKPX+AKPY*AKPY+AKPZ*AKPZ)
         CGP = CTHG2 
*
         ENSUM= ABS(RS - (Q1L(0)+Q2L(0)+Q3L(0)) - EKECHECK - EKPCHECK)
         PXSUM= ABS(Q1L(1)+Q2L(1)+Q3L(1)+AKEX+AKPX)
         PYSUM= ABS(Q1L(2)+Q2L(2)+Q3L(2)+AKEY+AKPY)
         PZSUM= ABS(Q1L(3)+Q2L(3)+Q3L(3)+AKEZ+AKPZ)
         IF(ENSUM.GT.1.D-6.OR.
     #      PXSUM.GT.1.D-6.OR.
     #      PYSUM.GT.1.D-6.OR.
     #      PZSUM.GT.1.D-6) THEN
* 
         ENDIF
* 
         CEVENT(1) = X_1
         CEVENT(2) = X_2
         CEVENT(3) = EB
         CEVENT(4) = Q1L(1)
         CEVENT(5) = Q1L(2)
         CEVENT(6) = Q1L(3)
         CEVENT(7) = Q2L(1)
         CEVENT(8) = Q2L(2)
         CEVENT(9) = Q2L(3)
         CEVENT(10) = Q3L(1)
         CEVENT(11) = Q3L(2)
         CEVENT(12) = Q3L(3)
         CEVENT(13) = Q4L(1)
         CEVENT(14) = Q4L(2)
         CEVENT(15) = Q4L(3)
         CEVENT(16) = Q5L(1)
         CEVENT(17) = Q5L(2)
         CEVENT(18) = Q5L(3)
         CEVENT(19) = EGE
         CEVENT(20) = CGE
         CEVENT(21) = ANGE
         CEVENT(22) = EGP
         CEVENT(23) = CGP
         CEVENT(24) = ANGP
*
*-----SUBROUTINE CUTUSER IS CALLED (I-BRANCH)
*
         CUTFLAG= 1.D0
         CALL ACCEPTANCE(CEVENT,CUTFLAG)
         IF(CUTFLAG.GT.0.D0) CALL CUTUSER(CEVENT,CUTFLAG)
         IF(CUTFLAG.GT.0.D0) THEN
            NHITW = NHITW+1
*
*-----con elicita`
*
            SP = -2.D0*SCALPROD(Q1,Q2) + 2.D0*MNU2
            TP = 2.D0*SCALPROD(PM,Q2) + MNU2
            T = 2.D0*SCALPROD(PP,Q1) + MNU2
            UP = 2.D0*SCALPROD(PM,Q1) + MNU2
            U = 2.D0*SCALPROD(PP,Q2) + MNU2
            HP = -2.D0*SCALPROD(PP,Q3)
            HM = -2.D0*SCALPROD(PM,Q3)
            KP = -2.D0*SCALPROD(Q1,Q3) + MNU2
            KM = -2.D0*SCALPROD(Q2,Q3) + MNU2
*
            call dnunugm(nflv,Q1,Q2,Q3,
     #                   SHAT,HP,HM,KP,KM,SP,TP,T,UP,U,emtrx)
            emtrx= emtrx*cfact
*
*-----STRUCTURE FUNCTION NORM
*
            AND1 = (1.D0-X1MIN)**BETAM-(1.D0-X1MAX)**BETAM
            AND2 = (1.D0-X2MIN)**BETAM-(1.D0-X2MAX)**BETAM
*
            FUNVAL = (2.D0*PI)**4/16.D0/(2.D0*PI)**9/2.D0
     #               *EMTRX*F123*F12
     #               *pm1cthg*ANPHIG*ANCTH*ANPHI
     #               *ANRM12*PRQ12*DOP(X1D)*DOP(X2D)*AND1*AND2
     #               *ANTHG*ANTHG
     #               *(1.D0-VOC*CTHG1)*(1.D0+VOC*CTHG2)
     #               *CGLEAD(CTHG1)*CGLEAD(-CTHG2)
*
         ELSE
            FUNVAL = 0.D0
         ENDIF
*
            IF(FUNVAL.GT.FMAX) THEN
               NBIAS = NBIAS + 1
               ANBIAS = NBIAS*1.D0
            ENDIF
*
            IF(REFN.LT.FUNVAL) THEN
               NHIT = NHIT + 1
               DO I1 = 1,24
                  EVENT(I1) = CEVENT(I1)
               ENDDO
*
               iacc = 1
               print *,' accepted event',(event(i1),i1=4,18)
               CALL HFN(313,EVENT)
* 
            ENDIF
*
      NHITO = NHIT
      ANBIASO = ANBIAS
 1159 RETURN
*
      END
*
      SUBROUTINE PHOT2PT(INT,NFLV,XSECT,DXSECT,NHITO,FMAXO,EFFO,ANBIASO)
      IMPLICIT REAL*8 (A-H,O-Z)
*
      PARAMETER (LUX=4,K1=0,K2=0,LEN=25)
*
* BEGIN ALPHA
*
      PARAMETER (NMAX_ALPHA=8)
*
* END ALPHA
*
      REAL*4 EVENT(24),RVEC(LEN)
      CHARACTER*1 OGEN, OGEN0, NFLV
*
* BEGIN ALPHA
*
      REAL*8 MOMEN(4,NMAX_ALPHA),MOMEN_IN(4,NMAX_ALPHA)      !new
      REAL*8 MASSOUTGOING(NMAX_ALPHA)
      INTEGER INDEXOUTGOING(NMAX_ALPHA),INDEXINGOING(NMAX_ALPHA)    !new
      COMPLEX*16 ELMAT
      INTEGER COULORSOUR(NMAX_ALPHA)
      INTEGER NINGOING
*
* END ALPHA
*
      DIMENSION VEC(LEN)
*
C      DIMENSION CEVENT(24)
      common/kinevt/cevent(24),iacc
*
      DIMENSION PP(0:3),PM(0:3),Q1(0:3),Q2(0:3),Q3(0:3),Q4(0:3),Q5(0:3),
     #          Q1L(0:3),Q2L(0:3),Q3L(0:3),Q4L(0:3),Q5L(0:3)
      DIMENSION PARTIAL(64),conf(8,64)
*
      COMMON/CMENERGY/RS,S
      COMMON/PAR/WM,WG,CFACT,GF,G,ZM,ZW,PI,ALPHA,EM2
      COMMON/PARD/ZM2,ZW2,WM2,WG2,GF2,G2,G4,G8
      COMMON/RPAR/RWM2,RWG2,RZM2,RZW2,RW,RZW,RW2
      COMMON/THETAW/STH2
      COMMON/EM/RL,ETA,BETA,SDELTA,BETAM
      COMMON/OG/OGEN
      COMMON/S2CH/NSCH
      COMMON/AIN/ALPHAI
      COMMON/EMC/IQED
      COMMON/RELACC/EPS
      COMMON/QCM/QMF1,QMF2,QMF3,QMF4,QMF5,QMF6
      COMMON/CHANN/ICHANNEL
      COMMON/CUTS/EGMINL,EGMAXL,CMINL,CMAXL
      COMMON/CVETO/CMINV,CMAXV
      COMMON/NG/NPHOT
      COMMON/CALLS/NHITWMAX,NHITMAX,NCALLS
      COMMON/MAXVALUE/FMAX
*
* BEGIN ALPHA
*
      COMMON/INTEGRA/MASSOUTGOING,
     #               NOUTGOING,INDEXOUTGOING,INDEXINGOING          !new
      COMMON/COLOR/COULORSOUR
*
* END ALPHA
*
      NHITWMAX0 = NHITWMAX
      OGEN0 = OGEN
      OGEN = 'I'
*
      IF(NFLV.EQ.'E') THEN
         NFLMIN = 1
         NFLMAX = 1
      ELSE IF(NFLV.EQ.'M'.OR.NFLV.EQ.'T') THEN
         NFLMIN = 2
         NFLMAX = 2
      ELSE IF(NFLV.EQ.'F') THEN
         NFLMIN = 1
         NFLMAX = 2
      ENDIF
*
      print *,' starting with option, nflmin,nflmax ',ogen,nflmin,nflmax
      DO IS = 1,4
         IF(IS.EQ.1) THEN 
            IFLAG_SPIN = 0
            NHITWMAX = 10000
         ELSE IF(IS.EQ.2) THEN
            IFLAG_SPIN = 1
            NHITWMAX = 100000
         ELSE IF(IS.EQ.3) THEN
            IFLAG_SPIN = 1
            NHITWMAX = 100000
         ELSE IF(IS.EQ.4) THEN
            IFLAG_SPIN = 1
            NHITWMAX = NHITWMAX0
            FMAX = FMAXO
            IF(OGEN0.EQ.'G') THEN
               OGEN = OGEN0
            ENDIF
         ENDIF
*         
         print *,'  pass ',is
         INIT_SPIN=0               !IT MUST BE 0 BEFORE ANY INTEGRATION LOOP
         INIT_FLAG=0               !IT MUST BE 0 BEFORE ANY INTEGRATION LOOP
         INIT_REG=0               !IT MUST BE 0 BEFORE ANY INTEGRATION LOOP
         NCONF=64                  !NUMBER OF SPIN CONFIGURATIONS
*
*-----INITIALIZE RANDOM GENERATION
*
         NMAX = NCALLS
         if (OGEN.eq.'I') then
         ICNT = 0
         NHIT = 0
         NHITW = 0
*
         FUNVAL = 0.D0
         FUNVALMAX= 0.D0
         ANBIAS = 0.D0
         NBIAS = 0
*
         FAV= 0.D0
         F2AV= 0.D0
*
*-----BEGIN ALPHA
*
         DO J=1,8
            COULORSOUR(J)=1
         ENDDO
*
*-----END ALPHA
*
*-----RANDOM NUMBER GENERATOR INITIALIZATION
*
         print *,' init rlux',LUX,INT,K1,K2
C         CALL RLUXGO(LUX,INT,K1,K2)
         endif
*
*-----BEGINNING OF LOOP OVER EVENTS
*
         print *,' loop over ',nmax,' events'
         DO I = 1,NMAX
*
            ICNT = ICNT + 1
*
*
*-----RANDOM NUMBER GENERATION
*
            CALL RANLUX(RVEC,LEN)
*
            DO J = 1,LEN
               VEC(J) = RVEC(J)
            ENDDO
*
C            print *,' randoms ',vec
            X1BS = 1.D0
            X2BS = 1.D0
*
*-----MIN AND MAX FOR X1
*
            X1MIN = 0.D0
            X1MAX = 1.D0
*
            OMX1 = ((1.D0 - X1MIN)**(BETAM)*(1.D0 - VEC(1))
     #        +(1.D0 - X1MAX)**(BETAM)*VEC(1))**(1.D0/BETAM)
            X1 = 1.D0 - OMX1
*
*-----MIN AND MAX FOR X2
*
            X2MIN = 0.D0
            X2MAX = 1.D0
*
            OMX2 = ((1.D0 - X2MIN)**(BETAM)*(1.D0 - VEC(2))
     #        +(1.D0 - X2MAX)**(BETAM)*VEC(2))**(1.D0/BETAM)
            X2 = 1.D0 - OMX2
*
            X1D = X1
            X2D = X2
            X1 = X1BS*X1D
            X2 = X2BS*X2D
            OMX1 = 1.D0-X1
            OMX2 = 1.D0-X2
C            print *,' generated x1,x2',x1,x2
*                                                                      
*....P_T ON INITIAL STATE PHOTONS IS GENERATED
*
            EBEAM= RS/2.D0
*
            EM = SQRT(EM2)
*
            VOC = (1.D0 - EM/EBEAM)*(1.D0 + EM/EBEAM)
            VOC = SQRT(VOC)
            ANTHG = -LOG((1.D0-VOC)/(1.D0+VOC))/VOC
*
            CTHG1 = (1.D0-(1.D0+VOC)*EXP(-VOC*VEC(14)*ANTHG))/VOC
            CTHG2 = -(1.D0-(1.D0-VOC)*EXP(VOC*VEC(15)*ANTHG))/VOC
*
            IF(CTHG1.GT.1.D0.OR.CTHG2.GT.1.D0) GO TO 1050
            if((1.D0-CTHG1*CTHG1).lt.0.d0) go to 1050
            if((1.D0-CTHG2*CTHG2).lt.0.d0) go to 1050
            STHG1 = SQRT(1.D0-CTHG1*CTHG1)
            STHG2 = SQRT(1.D0-CTHG2*CTHG2)
            ANGP = 2.D0*PI*VEC(16)
            CPHIGP = COS(ANGP)
            SPHIGP = SIN(ANGP)
            ANGE = 2.D0*PI*VEC(17)
            CPHIGE = COS(ANGE)
            SPHIGE = SIN(ANGE)
*
*.....I.S. RADIATED PHOTONS COMPONENTS AND I.S. LEPTONS MOMENTA (AFTER
*.....RADIATION)
*
            AKE0 = OMX1*EBEAM
            AKEXR = AKE0*STHG1*CPHIGE
            AKEYR = AKE0*STHG1*SPHIGE
            AKEZ = AKE0*CTHG1 
*
            AKP0 = OMX2*EBEAM
            AKPXR = AKP0*STHG2*CPHIGP
            AKPYR = AKP0*STHG2*SPHIGP
            AKPZ = AKP0*CTHG2

            IF(AKE0.GT.EGMINL) THEN
               IF(CTHG1.LT.CMAXL.AND.CTHG1.GT.CMINL) GO TO 1050
            ENDIF
            IF(AKP0.GT.EGMINL) THEN
               IF(CTHG2.LT.CMAXL.AND.CTHG2.GT.CMINL) GO TO 1050
            ENDIF  
            CALL VETO(AKE0,CTHG1,ANGE,AKP0,CTHG2,ANGP,IFLAGV)
            IF(IFLAGV.GT.0) GO TO 1050
*
            PXE = -AKEXR
            PYE = -AKEYR
            PZE = EBEAM-AKEZ
            PXP = -AKPXR
            PYP = -AKPYR
            PZP = -EBEAM-AKPZ
            P0P = X2*EBEAM
            P0E = X1*EBEAM
*
            SHAT = (RS-AKE0-AKP0)**2-(AKEXR+AKPXR)**2
     #           -(AKEYR+AKPYR)**2-(AKEZ+AKPZ)**2
*
            RZM2HAT = ZM2/SHAT
            RZWHAT = ZW*ZM/SHAT
*
            IF(SHAT.LT.0.D0) GO TO 1050    
*
            XM = X1 - X2
            XP = X1 + X2
*
            RSHAT = SQRT(SHAT)
*
            CMCTHG3 = VEC(3)
            CM12 = VEC(4)
            CMG3 = VEC(5)
            CMG4 = VEC(6)
            CMPHIG34 = VEC(7)
            CMCTHS = VEC(8)
            CMPHIS = VEC(9)
            CMPHIG3 = VEC(10)
            IKINE = 0
            CALL KINE2(X1,X2,SHAT,CMCTHG3,CM12,CMG3,CMG4,CMPHIG34,
     #                 CMCTHS,CMPHIS,CMPHIG3,ancthg3,pm1cthg3,
     #                 ANRM12,PRQ12,
     #                 RZM2HAT,RZWHAT,F12,ANEG3,XG3,ANEG4,XG4,
     #                 anphig34,ancths,anphis,anphig3,
     #                 PP,PM,Q1,Q2,Q3,Q4,Q5,
     #                 Q1L,Q2L,Q3L,Q4L,Q5L,IKINE)
            IF(IKINE.GT.0) GO TO 1050
*
            EKECHECK= SQRT(AKEXR*AKEXR+AKEYR*AKEYR+AKEZ*AKEZ)
            EKPCHECK= SQRT(AKPXR*AKPXR+AKPYR*AKPYR+AKPZ*AKPZ)
            IF(EKECHECK.GT.EBEAM.OR.
     #         EKPCHECK.GT.EBEAM) GO TO 1050
*
            AKEX = AKEXR
            AKEY = AKEYR
            AKPX = AKPXR
            AKPY = AKPYR
            EGE = SQRT(AKEX*AKEX+AKEY*AKEY+AKEZ*AKEZ)
            CGE = CTHG1
            EGP = SQRT(AKPX*AKPX+AKPY*AKPY+AKPZ*AKPZ)
            CGP = CTHG2 
*
            ENSUM= ABS(RS-(Q1L(0)+Q2L(0)+Q3L(0)+Q4L(0))
     #                   -EKECHECK-EKPCHECK)
            PXSUM= ABS(Q1L(1)+Q2L(1)+Q3L(1)+Q4L(1)+AKEX+AKPX)
            PYSUM= ABS(Q1L(2)+Q2L(2)+Q3L(2)+Q4L(2)+AKEY+AKPY)
            PZSUM= ABS(Q1L(3)+Q2L(3)+Q3L(3)+Q4L(3)+AKEZ+AKPZ)
* 
            REFN = VEC(25)*FMAX
*
            X_1 = X1
            X_2 = X2
            EB= RS/2.D0
*
            CEVENT(1) = X_1
            CEVENT(2) = X_2
            CEVENT(3) = EB
            CEVENT(4) = Q1L(1)
            CEVENT(5) = Q1L(2)
            CEVENT(6) = Q1L(3)
            CEVENT(7) = Q2L(1)
            CEVENT(8) = Q2L(2)
            CEVENT(9) = Q2L(3)
            CEVENT(10) = Q3L(1)
            CEVENT(11) = Q3L(2)
            CEVENT(12) = Q3L(3)
            CEVENT(13) = Q4L(1)
            CEVENT(14) = Q4L(2)
            CEVENT(15) = Q4L(3)
            CEVENT(16) = Q5L(1)
            CEVENT(17) = Q5L(2)
            CEVENT(18) = Q5L(3)
            CEVENT(19) = EGE
            CEVENT(20) = CGE
            CEVENT(21) = ANGE
            CEVENT(22) = EGP
            CEVENT(23) = CGP
            CEVENT(24) = ANGP
*
*-----SUBROUTINE CUTUSER IS CALLED (I-BRANCH)
*
            CUTFLAG= 1.D0
            CALL ACCEPTANCE(CEVENT,CUTFLAG)
C            if(cutflag.le.0d0) print *,' event not accepted ',icnt
            IF(CUTFLAG.GT.0.D0) CALL CUTUSER(CEVENT,CUTFLAG)
C            if(cutflag.le.0d0) print *,' event not user accepted ',icnt
            IF(CUTFLAG.GT.0.D0) THEN
               NHITW = NHITW+1
*
* BEGIN ALPHA
*
               DO III=1,4
*
                  MOMEN(III,1)= Q1(III-1)
                  MOMEN(III,2)= Q2(III-1)
                  MOMEN(III,3)= Q3(III-1)
                  MOMEN(III,4)= Q4(III-1)
               ENDDO
*
* spin sampling
*
* SPINSAMPLING_NEW(RND,REDEFINED,SPINWEIGHT,nconf,flag)               
               IF (IFLAG_SPIN.EQ.1) THEN
                  CALL SPINSAMPLING_NEW(vec(18),REDEFINED,SPINWEIGHT,
     >                                  nconf,INIT_flag) 
               ELSE
                  REDEFINED=VEC(18)
                  SPINWEIGHT=1.
               ENDIF
*
               momen_in(1,1)=RSHAT/2.D0                  !new
               momen_in(2,1)=0.                  !new
               momen_in(3,1)=0.                  !new
               momen_in(4,1)=RSHAT/2.D0                  !new
*
               momen_in(1,2)=RSHAT/2.D0                  !new
               momen_in(2,2)=0.                  !new
               momen_in(3,2)=0.                  !new
               momen_in(4,2)=-RSHAT/2.D0                  !new

               ningoing=2                !new  number of ingoing particles
*
               ELMATSQ = 0.D0
               DO IFL = NFLMIN,NFLMAX
                  CALL PROCESSO_H(IFL)                 !new style
*
                  CALL FILLMOM(MOMEN,NOUTGOINGb,momen_in,ningoing)     !new
                  CALL SPINCOULOR_H(REDEFINED,NSPINCONF,LABEL,INIT_SPIN,
     >                      IFLAG_SPIN)
*
                  CALL ITERA(ELMAT)
                  IF(IFL.EQ.1) ELMATSQE = (ABS(ELMAT))**2
                  IF(IFL.EQ.2) ELMATSQM = (ABS(ELMAT))**2
               ENDDO
*
               IF(NFLV.EQ.'E') THEN
                  ELMATSQ = ELMATSQE
               ELSE IF(NFLV.EQ.'M'.OR.NFLV.EQ.'T') THEN
                  ELMATSQ = ELMATSQM
               ELSE IF(NFLV.EQ.'F') THEN
                  ELMATSQ = 2.D0*ELMATSQM + ELMATSQE
               ENDIF 
*
               EMTRX = ELMATSQ
               EMTRX = EMTRX * 16. * CFACT      
               EMTRX = EMTRX * SPINWEIGHT   ! SPIN RESCALING
*
               EMTRX = EMTRX*(4.D0*PI*ALPHA/G2/STH2)**2
*
* END ALPHA
*
*-----STRUCTURE FUNCTION NORM
*
               AND1 = (1.D0-X1MIN)**BETAM-(1.D0-X1MAX)**BETAM
               AND2 = (1.D0-X2MIN)**BETAM-(1.D0-X2MAX)**BETAM
*
               FUNVAL = (2.D0*PI)**4/(2.D0*PI)**12/2.D0**5/2.D0
     #                  *EMTRX*ANRM12*PRQ12*F12
     #                  *pm1cthg3*ANEG3*ANEG4*ANPHIG34
     #                  *ANCTHS*ANPHIS*ANPHIG3
     #                  *XG3*XG4
     #                  *DOP(X1D)*DOP(X2D)*AND1*AND2
     #                  *ANTHG*ANTHG
     #                  *(1.D0-VOC*CTHG1)*(1.D0+VOC*CTHG2)
     #                  *CGLEAD(CTHG1)*CGLEAD(-CTHG2)
*
            ELSE
               FUNVAL = 0.D0
            ENDIF
*
*-----STATISTICAL FACTOR FOR TWO INDISTINGUISHABLE PHOTONS
*
            FUNVAL = FUNVAL/2.D0
*
            IF(FUNVAL.GT.FUNVALMAX) FUNVALMAX= FUNVAL
*
*-----AVERAGE AND SQUARED AVERAGE ARE CUMULATED (I-BRANCH)
*
            IF(OGEN.EQ.'I') THEN
*
               FAV = FAV + FUNVAL
               F2AV = F2AV + FUNVAL**2
*
               IF(NHITW.GE.NHITWMAX) GO TO 2050
*
            ELSE IF(OGEN.EQ.'G') THEN
*
*-----CHECK POSSIBLE BIAS (GENERATION BRANCH)
*
               IF(FUNVAL.GT.FMAX) THEN
                  NBIAS = NBIAS + 1
                  ANBIAS = NBIAS*1.D0
               ENDIF
*
               IF (REFN.LT.FUNVAL) THEN
                  NHIT = NHIT + 1
                  DO I1 = 1,24
                     EVENT(I1) = CEVENT(I1)
                  ENDDO
*
                 iacc =1
                print *,' accepted event',(event(i1),i1=4,18)
                 CALL HFN(313,EVENT)
* 
               ENDIF
*
               IF(NHIT.GE.NHITMAX) GO TO 2050
            ENDIF
*
* BEGIN ALPHA
*
            WEIGHT = 1.D0
            if(funval.gt.0) 
     #         CALL REGSPIN_NEW
     #              (nspinconf,label,1,1,FUNVAL,weight,INIT_REG)
*
* END ALPHA
*
*-----END OF LOOP OVER EVENTS
*
 1050    END DO
         print *,' funvalmax ',funvalmax
         if (OGEN.eq.'I') then
         ICNT = 0
         NHIT = 0
         NHITW = 0
*
         FUNVAL = 0.D0
         FUNVALMAX= 0.D0
         ANBIAS = 0.D0
         NBIAS = 0
*
         FAV= 0.D0
         F2AV= 0.D0
*
*-----BEGIN ALPHA
*
         DO J=1,8
            COULORSOUR(J)=1
         ENDDO
*
*-----END ALPHA
         endif
*
* BEGIN ALPHA
*
 2050    CALL WRITESPIN
*
* END ALPHA
*
         AN = ICNT*1.D0
         FAV = FAV/AN
         F2AV = F2AV/AN
         DFAV = SQRT(F2AV - FAV**2)/SQRT(AN-1.D0)
         EFF = NHIT*1.D0/AN
         EFFW = NHITW*1.D0/AN
         REFV = FMAX
*
*
         IF(OGEN.EQ.'G') THEN
            XSECT = EFF*REFV
            DXSECT = REFV/SQRT(AN)*SQRT(EFF*(1.D0-EFF))
            NHITO = NHIT
            FMAXO = FUNVALMAX
            EFFO = EFF
            ANBIASO = ANBIAS/AN
         ELSE IF(OGEN.EQ.'I') THEN
            EFF = EFFW
            XSECT = FAV
            DXSECT = DFAV
            NHITO = NHITW
            FMAXO = FUNVALMAX
            EFFO = EFF
            ANBIASO = 0.D0
          ENDIF
*
      ENDDO
*
      OPEN (1,FILE='spinbin.dat',STATUS='OLD')
      DO J1=1,64
         READ(1,*)PARTIAL(J1)
      ENDDO
      CLOSE(1)
      OPEN (1,FILE='SPB2YPT.DAT',STATUS='UNKNOWN')
      DO J1=1,64
         WRITE(1,*)PARTIAL(J1)
      ENDDO
      CLOSE(1)
      OPEN (1,FILE='spinconf.dat',STATUS='OLD')
      READ(1,*)NSPC
      DO J1=1,64
         READ(1,*)(CONF(J2,J1),J2=1,8)
      ENDDO
      CLOSE(1)
      OPEN (1,FILE='SPC2YPT.DAT',STATUS='UNKNOWN')
      WRITE(1,*)NSPC
      DO J1=1,64
         WRITE(1,*)(CONF(J2,J1),J2=1,8)
      ENDDO
      CLOSE(1)
*
      RETURN
      END
*
      SUBROUTINE PHOT2G(VEC,NFLV,FMAXO,NHITO,ANBIASO,ICALL)
      IMPLICIT REAL*8 (A-H,O-Z)
*
      PARAMETER (LEN=25)
*
* BEGIN ALPHA
*
      PARAMETER (NMAX_ALPHA=8)
*
* END ALPHA
*
      REAL*4 EVENT(24)
      CHARACTER*1 OGEN, NFLV
*
* BEGIN ALPHA
*
      REAL*8 MOMEN(4,NMAX_ALPHA),MOMEN_IN(4,NMAX_ALPHA)      !new
      REAL*8 MASSOUTGOING(NMAX_ALPHA)
      INTEGER INDEXOUTGOING(NMAX_ALPHA),INDEXINGOING(NMAX_ALPHA)    !new
      COMPLEX*16 ELMAT
      INTEGER COULORSOUR(NMAX_ALPHA)
      INTEGER NINGOING
*
* END ALPHA
*
      DIMENSION VEC(LEN)
*
C      DIMENSION CEVENT(24)
      common/kinevt/cevent(24),iacc
*
      DIMENSION PP(0:3),PM(0:3),Q1(0:3),Q2(0:3),Q3(0:3),Q4(0:3),Q5(0:3),
     #          Q1L(0:3),Q2L(0:3),Q3L(0:3),Q4L(0:3),Q5L(0:3)
      DIMENSION PARTIAL(64),conf(8,64)
*
      COMMON/CMENERGY/RS,S
      COMMON/PAR/WM,WG,CFACT,GF,G,ZM,ZW,PI,ALPHA,EM2
      COMMON/PARD/ZM2,ZW2,WM2,WG2,GF2,G2,G4,G8
      COMMON/RPAR/RWM2,RWG2,RZM2,RZW2,RW,RZW,RW2
      COMMON/THETAW/STH2
      COMMON/EM/RL,ETA,BETA,SDELTA,BETAM
      COMMON/OG/OGEN
      COMMON/S2CH/NSCH
      COMMON/AIN/ALPHAI
      COMMON/EMC/IQED
      COMMON/RELACC/EPS
      COMMON/QCM/QMF1,QMF2,QMF3,QMF4,QMF5,QMF6
      COMMON/CHANN/ICHANNEL
      COMMON/CUTS/EGMINL,EGMAXL,CMINL,CMAXL
      COMMON/NG/NPHOT
      COMMON/CALLS/NHITWMAX,NHITMAX,NCALLS
      COMMON/MAXVALUE/FMAX
*
* BEGIN ALPHA
*
      COMMON/INTEGRA/MASSOUTGOING,
     #               NOUTGOING,INDEXOUTGOING,INDEXINGOING                 !new
      COMMON/COLOR/COULORSOUR
*
* END ALPHA
*
       IF(ICALL.NE.2) THEN
            OPEN (1,FILE='SPB2YPT.DAT',STATUS='OLD')
            DO J1=1,64
               read(1,*)PARTIAL(J1)
            ENDDO
            CLOSE(1)
            OPEN (1,FILE='spinbin.dat',STATUS='UNKNOWN')
            DO J1=1,64
               write(1,*)PARTIAL(J1)
            ENDDO
            CLOSE(1)
            OPEN (1,FILE='SPC2YPT.DAT',STATUS='OLD')
            READ(1,*)NSPC
            DO J1=1,64
               read(1,*)(CONF(J2,J1),J2=1,8)
            ENDDO
            CLOSE(1)
            OPEN (1,FILE='spinconf.dat',STATUS='UNKNOWN')
            WRITE(1,*)NSPC
            DO J1=1,64
               write(1,*)(CONF(J2,J1),J2=1,8)
            ENDDO
            CLOSE(1)
            INIT_SPIN=0               !IT MUST BE 0 BEFORE ANY INTEGRATION LOOP
            INIT_FLAG=0               !IT MUST BE 0 BEFORE ANY INTEGRATION LOOP
      ENDIF 
C
      IF(NFLV.EQ.'E') THEN
         NFLMIN = 1
         NFLMAX = 1
      ELSE IF(NFLV.EQ.'M'.OR.NFLV.EQ.'T') THEN
         NFLMIN = 2
         NFLMAX = 2
      ELSE IF(NFLV.EQ.'F') THEN
         NFLMIN = 1
         NFLMAX = 2
      ENDIF
*
      IS = 4
         IF(IS.EQ.1) THEN 
            IFLAG_SPIN = 0
            NHITWMAX = 10000
         ELSE IF(IS.EQ.2) THEN
            IFLAG_SPIN = 1
            NHITWMAX = 100000
         ELSE IF(IS.EQ.3) THEN
            IFLAG_SPIN = 1
            NHITWMAX = 100000
         ELSE IF(IS.EQ.4) THEN
            IFLAG_SPIN = 1
            FMAX = FMAXO
         ENDIF
*
         NCONF=64                  !NUMBER OF SPIN CONFIGURATIONS
*
*-----INITIALIZE RANDOM GENERATION
*
         NMAX = NCALLS
         if (OGEN.eq.'I') then
         ICNT = 0
         NHIT = 0
         NHITW = 0
*
         FUNVAL = 0.D0
         NBIAS = 0
         ANBIAS = 0.D0
*
*-----BEGIN ALPHA
*
         DO J=1,8
            COULORSOUR(J)=1
         ENDDO
*
*-----END ALPHA
*
*-----RANDOM NUMBER GENERATOR INITIALIZATION
*
            X1BS = 1.D0
            X2BS = 1.D0
*
*-----MIN AND MAX FOR X1
*
            X1MIN = 0.D0
            X1MAX = 1.D0
         endif
*
            OMX1 = ((1.D0 - X1MIN)**(BETAM)*(1.D0 - VEC(1))
     #        +(1.D0 - X1MAX)**(BETAM)*VEC(1))**(1.D0/BETAM)
            X1 = 1.D0 - OMX1
*
*-----MIN AND MAX FOR X2
*
            X2MIN = 0.D0
            X2MAX = 1.D0
*
            OMX2 = ((1.D0 - X2MIN)**(BETAM)*(1.D0 - VEC(2))
     #        +(1.D0 - X2MAX)**(BETAM)*VEC(2))**(1.D0/BETAM)
            X2 = 1.D0 - OMX2
*
            X1D = X1
            X2D = X2
            X1 = X1BS*X1D
            X2 = X2BS*X2D
            OMX1 = 1.D0-X1
            OMX2 = 1.D0-X2
*                                                                      
*....P_T ON INITIAL STATE PHOTONS IS GENERATED
*
            EBEAM= RS/2.D0
*
            EM = SQRT(EM2)
*
            VOC = (1.D0 - EM/EBEAM)*(1.D0 + EM/EBEAM)
            VOC = SQRT(VOC)
            ANTHG = -LOG((1.D0-VOC)/(1.D0+VOC))/VOC
*
            CTHG1 = (1.D0-(1.D0+VOC)*EXP(-VOC*VEC(14)*ANTHG))/VOC
            CTHG2 = -(1.D0-(1.D0-VOC)*EXP(VOC*VEC(15)*ANTHG))/VOC
* 
            IF(CTHG1.GT.1.D0.OR.CTHG2.GT.1.D0) GO TO 1051
            if((1.D0-CTHG1*CTHG1).lt.0.d0) go to 1051
            if((1.D0-CTHG2*CTHG2).lt.0.d0) go to 1051
            STHG1 = SQRT(1.D0-CTHG1*CTHG1)
            STHG2 = SQRT(1.D0-CTHG2*CTHG2)
            ANGP = 2.D0*PI*VEC(16)
            CPHIGP = COS(ANGP)
            SPHIGP = SIN(ANGP)
            ANGE = 2.D0*PI*VEC(17)
            CPHIGE = COS(ANGE)
            SPHIGE = SIN(ANGE)
*
*.....I.S. RADIATED PHOTONS COMPONENTS AND I.S. LEPTONS MOMENTA (AFTER
*.....RADIATION)
*
            AKE0 = OMX1*EBEAM
            AKEXR = AKE0*STHG1*CPHIGE
            AKEYR = AKE0*STHG1*SPHIGE
            AKEZ = AKE0*CTHG1 
*
            AKP0 = OMX2*EBEAM
            AKPXR = AKP0*STHG2*CPHIGP
            AKPYR = AKP0*STHG2*SPHIGP
            AKPZ = AKP0*CTHG2
*
            PXE = -AKEXR
            PYE = -AKEYR
            PZE = EBEAM-AKEZ
            PXP = -AKPXR
            PYP = -AKPYR
            PZP = -EBEAM-AKPZ
            P0P = X2*EBEAM
            P0E = X1*EBEAM
*
            IF(AKE0.GT.EGMINL) THEN
               IF(CTHG1.LT.CMAXL.AND.CTHG1.GT.CMINL) GO TO 1051
            ENDIF
            IF(AKP0.GT.EGMINL) THEN
               IF(CTHG2.LT.CMAXL.AND.CTHG2.GT.CMINL) GO TO 1051
            ENDIF  
            CALL VETO(AKE0,CTHG1,ANGE,AKP0,CTHG2,ANGP,IFLAGV)
            IF(IFLAGV.GT.0) GO TO 1051
*
            SHAT = (RS-AKE0-AKP0)**2-(AKEXR+AKPXR)**2
     #           -(AKEYR+AKPYR)**2-(AKEZ+AKPZ)**2
*
            RZM2HAT = ZM2/SHAT
            RZWHAT = ZW*ZM/SHAT
*
            IF(SHAT.LT.0.D0) GO TO 1051    
*
            XM = X1 - X2
            XP = X1 + X2
*
            RSHAT = SQRT(SHAT)
*
            CMCTHG3 = VEC(3)
            CM12 = VEC(4)
            CMG3 = VEC(5)
            CMG4 = VEC(6)
            CMPHIG34 = VEC(7)
            CMCTHS = VEC(8)
            CMPHIS = VEC(9)
            CMPHIG3 = VEC(10)
            IKINE = 0
            CALL KINE2(X1,X2,SHAT,CMCTHG3,CM12,CMG3,CMG4,CMPHIG34,
     #                 CMCTHS,CMPHIS,CMPHIG3,ancthg3,pm1cthg3,
     #                 ANRM12,PRQ12,
     #                 RZM2HAT,RZWHAT,F12,ANEG3,XG3,ANEG4,XG4,
     #                 anphig34,ancths,anphis,anphig3,
     #                 PP,PM,Q1,Q2,Q3,Q4,Q5,
     #                 Q1L,Q2L,Q3L,Q4L,Q5L,IKINE)
            IF(IKINE.GT.0) GO TO 1051
*
            EKECHECK= SQRT(AKEXR*AKEXR+AKEYR*AKEYR+AKEZ*AKEZ)
            EKPCHECK= SQRT(AKPXR*AKPXR+AKPYR*AKPYR+AKPZ*AKPZ)
            IF(EKECHECK.GT.EBEAM.OR.
     #         EKPCHECK.GT.EBEAM) GO TO 1051
*
            AKEX = AKEXR
            AKEY = AKEYR
            AKPX = AKPXR
            AKPY = AKPYR
            EGE = SQRT(AKEX*AKEX+AKEY*AKEY+AKEZ*AKEZ)
            CGE = CTHG1
            EGP = SQRT(AKPX*AKPX+AKPY*AKPY+AKPZ*AKPZ)
            CGP = CTHG2 
*
            ENSUM= ABS(RS-(Q1L(0)+Q2L(0)+Q3L(0)+Q4L(0))
     #                   -EKECHECK-EKPCHECK)
            PXSUM= ABS(Q1L(1)+Q2L(1)+Q3L(1)+Q4L(1)+AKEX+AKPX)
            PYSUM= ABS(Q1L(2)+Q2L(2)+Q3L(2)+Q4L(2)+AKEY+AKPY)
            PZSUM= ABS(Q1L(3)+Q2L(3)+Q3L(3)+Q4L(3)+AKEZ+AKPZ)
* 
            REFN = VEC(25)*FMAX
*
            X_1 = X1
            X_2 = X2
            EB= RS/2.D0
*
            CEVENT(1) = X_1
            CEVENT(2) = X_2
            CEVENT(3) = EB
            CEVENT(4) = Q1L(1)
            CEVENT(5) = Q1L(2)
            CEVENT(6) = Q1L(3)
            CEVENT(7) = Q2L(1)
            CEVENT(8) = Q2L(2)
            CEVENT(9) = Q2L(3)
            CEVENT(10) = Q3L(1)
            CEVENT(11) = Q3L(2)
            CEVENT(12) = Q3L(3)
            CEVENT(13) = Q4L(1)
            CEVENT(14) = Q4L(2)
            CEVENT(15) = Q4L(3)
            CEVENT(16) = Q5L(1)
            CEVENT(17) = Q5L(2)
            CEVENT(18) = Q5L(3)
            CEVENT(19) = EGE
            CEVENT(20) = CGE
            CEVENT(21) = ANGE
            CEVENT(22) = EGP
            CEVENT(23) = CGP
            CEVENT(24) = ANGP
*
*-----SUBROUTINE CUTUSER IS CALLED (I-BRANCH)
*
            CUTFLAG= 1.D0
            CALL ACCEPTANCE(CEVENT,CUTFLAG)
            IF(CUTFLAG.GT.0.D0) CALL CUTUSER(CEVENT,CUTFLAG)
            IF(CUTFLAG.GT.0.D0) THEN
               NHITW = NHITW+1
*
* BEGIN ALPHA
*
               DO III=1,4
                  MOMEN(III,1)= Q1(III-1)
                  MOMEN(III,2)= Q2(III-1)
                  MOMEN(III,3)= Q3(III-1)
                  MOMEN(III,4)= Q4(III-1)
               ENDDO
*
* spin sampling
*
* SPINSAMPLING_NEW(RND,REDEFINED,SPINWEIGHT,nconf,flag)               
               IF (IFLAG_SPIN.EQ.1) THEN
                  CALL SPINSAMPLING_NEW(vec(18),REDEFINED,SPINWEIGHT,
     >                                  nconf,INIT_flag) 
               ELSE
                  REDEFINED=VEC(18)
                  SPINWEIGHT=1.
               ENDIF
*
               momen_in(1,1)=RSHAT/2.D0                  !new
               momen_in(2,1)=0.                  !new
               momen_in(3,1)=0.                  !new
               momen_in(4,1)=RSHAT/2.D0                  !new
*
               momen_in(1,2)=RSHAT/2.D0                  !new
               momen_in(2,2)=0.                  !new
               momen_in(3,2)=0.                  !new
               momen_in(4,2)=-RSHAT/2.D0                  !new

               ningoing=2                !new  number of ingoing particles
*
               ELMATSQ = 0.D0
               DO IFL = NFLMIN,NFLMAX
                  CALL PROCESSO_H(IFL)                 !new style
*
                  CALL FILLMOM(MOMEN,NOUTGOINGb,momen_in,ningoing)     !new
                  CALL SPINCOULOR_H(REDEFINED,NSPINCONF,LABEL,INIT_SPIN,
     >                      IFLAG_SPIN)
*
                  CALL ITERA(ELMAT)
                  IF(IFL.EQ.1) ELMATSQE = (ABS(ELMAT))**2
                  IF(IFL.EQ.2) ELMATSQM = (ABS(ELMAT))**2
               ENDDO
*
               IF(NFLV.EQ.'E') THEN
                  ELMATSQ = ELMATSQE
               ELSE IF(NFLV.EQ.'M'.OR.NFLV.EQ.'T') THEN
                  ELMATSQ = ELMATSQM
               ELSE IF(NFLV.EQ.'F') THEN
                  ELMATSQ = 2.D0*ELMATSQM + ELMATSQE
               ENDIF 
*
               EMTRX = ELMATSQ
               EMTRX = EMTRX * 16. * CFACT      
               EMTRX = EMTRX * SPINWEIGHT   ! SPIN RESCALING
*
               EMTRX = EMTRX*(4.D0*PI*ALPHA/G2/STH2)**2
*
* END ALPHA
*
*-----STRUCTURE FUNCTION NORM
*
               AND1 = (1.D0-X1MIN)**BETAM-(1.D0-X1MAX)**BETAM
               AND2 = (1.D0-X2MIN)**BETAM-(1.D0-X2MAX)**BETAM
*
               FUNVAL = (2.D0*PI)**4/(2.D0*PI)**12/2.D0**5/2.D0
     #                  *EMTRX*ANRM12*PRQ12*F12
     #                  *pm1cthg3*ANEG3*ANEG4*ANPHIG34
     #                  *ANCTHS*ANPHIS*ANPHIG3
     #                  *XG3*XG4
     #                  *DOP(X1D)*DOP(X2D)*AND1*AND2
     #                  *ANTHG*ANTHG
     #                  *(1.D0-VOC*CTHG1)*(1.D0+VOC*CTHG2)
     #                  *CGLEAD(CTHG1)*CGLEAD(-CTHG2)
*
            ELSE
               FUNVAL = 0.D0
            ENDIF
*
*-----STATISTICAL FACTOR FOR TWO INDISTINGUISHABLE PHOTONS
*
            FUNVAL = FUNVAL/2.D0
*
               IF(FUNVAL.GT.FMAX) THEN
                  NBIAS = NBIAS + 1
                  ANBIAS = NBIAS*1.D0
               ENDIF
*
               IF (REFN.LT.FUNVAL) THEN
                  NHIT = NHIT + 1
                  DO I1 = 1,24
                     EVENT(I1) = CEVENT(I1)
                  ENDDO
*
                  iacc = 1
               print *,' accepted event',(event(i1),i1=4,18)
                  CALL HFN(313,EVENT)
* 
               ENDIF
*
         NHITO= NHIT
         ANBIASO= ANBIAS
 1051    RETURN
*
      END
*
      SUBROUTINE PHOT3G(VEC,NFLV,FMAXO,NHITO,ANBIASO,ICALL)
      IMPLICIT REAL*8 (A-H,O-Z)
*
      PARAMETER (LEN=25)
*
* BEGIN ALPHA
*
      PARAMETER (NMAX_ALPHA=8)
*
* END ALPHA
*
      REAL*4 EVENT(24)
      CHARACTER*1 OGEN, NFLV
*
* BEGIN ALPHA
*
      REAL*8 MOMEN(4,NMAX_ALPHA),MOMEN_IN(4,NMAX_ALPHA)      !new
      REAL*8 MASSOUTGOING(NMAX_ALPHA)
      INTEGER INDEXOUTGOING(NMAX_ALPHA),INDEXINGOING(NMAX_ALPHA)    !new
      COMPLEX*16 ELMAT
      INTEGER COULORSOUR(NMAX_ALPHA)
      INTEGER NINGOING
*
* END ALPHA
*
      DIMENSION VEC(LEN)
*
C      DIMENSION CEVENT(24)
      common/kinevt/cevent(24),iacc
*
      DIMENSION PP(0:3),PM(0:3),Q1(0:3),Q2(0:3),Q3(0:3),Q4(0:3),Q5(0:3),
     #          Q1L(0:3),Q2L(0:3),Q3L(0:3),Q4L(0:3),Q5L(0:3)
      DIMENSION PARTIAL(128),conf(8,128)
*
      COMMON/CMENERGY/RS,S
      COMMON/PAR/WM,WG,CFACT,GF,G,ZM,ZW,PI,ALPHA,EM2
      COMMON/PARD/ZM2,ZW2,WM2,WG2,GF2,G2,G4,G8
      COMMON/RPAR/RWM2,RWG2,RZM2,RZW2,RW,RZW,RW2
      COMMON/THETAW/STH2
      COMMON/EM/RL,ETA,BETA,SDELTA,BETAM
      COMMON/OG/OGEN
      COMMON/S2CH/NSCH
      COMMON/AIN/ALPHAI
      COMMON/EMC/IQED
      COMMON/RELACC/EPS
      COMMON/QCM/QMF1,QMF2,QMF3,QMF4,QMF5,QMF6
      COMMON/CHANN/ICHANNEL
      COMMON/CUTS/EGMINL,EGMAXL,CMINL,CMAXL
      COMMON/NG/NPHOT
      COMMON/CALLS/NHITWMAX,NHITMAX,NCALLS
      COMMON/MAXVALUE/FMAX
*
* BEGIN ALPHA
*
      COMMON/INTEGRA/MASSOUTGOING,
     #               NOUTGOING,INDEXOUTGOING,INDEXINGOING                 !new
      COMMON/COLOR/COULORSOUR
*
* END ALPHA
*
      IF(ICALL.NE.3) THEN
            OPEN (1,FILE='SPB3NPT.DAT',STATUS='OLD')
            DO J1=1,128
               read(1,*)PARTIAL(J1)
            ENDDO
            CLOSE(1)
            OPEN (1,FILE='spinbin.dat',STATUS='UNKNOWN')
            DO J1=1,128
               write(1,*)PARTIAL(J1)
            ENDDO
            CLOSE(1)
            OPEN (1,FILE='SPC3NPT.DAT',STATUS='OLD')
            READ(1,*)NSPC
            DO J1=1,128
               read(1,*)(CONF(J2,J1),J2=1,8)
            ENDDO
            CLOSE(1)
            OPEN (1,FILE='spinconf.dat',STATUS='UNKNOWN')
            WRITE(1,*)NSPC
            DO J1=1,128
               write(1,*)(CONF(J2,J1),J2=1,8)
            ENDDO
            CLOSE(1)
            INIT_SPIN=0               !IT MUST BE 0 BEFORE ANY INTEGRATION LOOP
            INIT_FLAG=0               !IT MUST BE 0 BEFORE ANY INTEGRATION LOOP
      ENDIF

      IF(NFLV.EQ.'E') THEN
         NFLMIN = 6
         NFLMAX = 6
      ELSE IF(NFLV.EQ.'M'.OR.NFLV.EQ.'T') THEN
         NFLMIN = 7
         NFLMAX = 7
      ELSE IF(NFLV.EQ.'F') THEN
         NFLMIN = 6
         NFLMAX = 7
      ENDIF
*
      IS = 4
         IF(IS.EQ.1) THEN 
            IFLAG_SPIN = 0
            NHITWMAX = 10000

         ELSE IF(IS.EQ.2) THEN
            IFLAG_SPIN = 1
            NHITWMAX = 10000
         ELSE IF(IS.EQ.3) THEN
            IFLAG_SPIN = 1
            NHITWMAX = 10000
         ELSE IF(IS.EQ.4) THEN
            IFLAG_SPIN = 1
            FMAX = FMAXO
         ENDIF
*         
         NCONF=128                 !NUMBER OF SPIN CONFIGURATIONS
*
*-----INITIALIZE RANDOM GENERATION
*
         NMAX = NCALLS
         if (OGEN.eq.'I') then
         ICNT = 0
         NHIT = 0
         NHITW = 0
*
         FUNVAL = 0.D0
         FUNVALMAX= 0.D0
         ANBIAS= 0.D0
         NBIAS = 0
*
*-----BEGIN ALPHA
*
         DO J=1,8
            COULORSOUR(J)=1
         ENDDO
         endif
*
*-----END ALPHA
*
            X1BS = 1.D0
            X2BS = 1.D0
*
            IF(IQED.EQ.1) THEN
*
*-----MIN AND MAX FOR X1
*
               X1MIN = 0.D0
               X1MAX = 1.D0
*
               OMX1 = ((1.D0 - X1MIN)**(BETAM)*(1.D0 - VEC(1))
     #           +(1.D0 - X1MAX)**(BETAM)*VEC(1))**(1.D0/BETAM)
               X1 = 1.D0 - OMX1
*
*-----MIN AND MAX FOR X2
*
               X2MIN = 0.D0
               X2MAX = 1.D0
*
               OMX2 = ((1.D0 - X2MIN)**(BETAM)*(1.D0 - VEC(2))
     #           +(1.D0 - X2MAX)**(BETAM)*VEC(2))**(1.D0/BETAM)
               X2 = 1.D0 - OMX2
*
            ELSE IF(IQED.EQ.0) THEN
               X1 = 1.D0
               X2 = 1.D0
            ENDIF
*
            X1D = X1
            X2D = X2
            X1 = X1BS*X1D
            X2 = X2BS*X2D
*                                                                      
            RZM2HAT = RZM2/X1/X2
            RZWHAT = RZW/X1/X2
            SHAT = X1*X2*S
            RSHAT = SQRT(SHAT)
*
            CMCTHG3 = VEC(3)
            CM125 = VEC(4)
            CM12 = VEC(5)
            CMG3 = VEC(6)
            CMG4 = VEC(7)
            CMPHIG34 = VEC(8)
            CMCTH5S = VEC(9)
            CMPHI5S = VEC(10)
            CMCTHS = VEC(11)
            CMPHIS = VEC(12)
            CMPHIG3 = VEC(13)
*
            IKINE = 0
*            
            CALL KINE3(iin,X1,X2,SHAT,CMCTHG3,CM125,CM12,CMG3,CMG4,
     #                 CMPHIG34,CMCTH5S,CMPHI5S,CMCTHS,CMPHIS,CMPHIG3,
     #                 ancthg3,pm1cthg3,ANRM125,PRQ125,ANRM12,PRQ12,
     #                 RZM2HAT,RZWHAT,F125,F12,ANEG3,XG3,ANEG4,XG4,
     #                 anphig34,ancth5s,anphi5s,
     #                 ancths,anphis,anphig3,
     #                 PP,PM,Q1,Q2,Q3,Q4,Q5,
     #                 Q1L,Q2L,Q3L,Q4L,Q5L,IKINE)
            IF(IKINE.GT.0) GO TO 1201
*
            REFN = VEC(25)*FMAX
*
            X_1 = X1
            X_2 = X2
            EB= RS/2.D0
*
            EGE = OMX1*EB
            CGE = 1.D0
            ANGE = 0.D0
            EGP = OMX2*EB
            CGP = -1.D0
            ANGP = 0.D0
*
            CEVENT(1) = X_1
            CEVENT(2) = X_2
            CEVENT(3) = EB
            CEVENT(4) = Q1L(1)
            CEVENT(5) = Q1L(2)
            CEVENT(6) = Q1L(3)
            CEVENT(7) = Q2L(1)
            CEVENT(8) = Q2L(2)
            CEVENT(9) = Q2L(3)
            CEVENT(10) = Q3L(1)
            CEVENT(11) = Q3L(2)
            CEVENT(12) = Q3L(3)
            CEVENT(13) = Q4L(1)
            CEVENT(14) = Q4L(2)
            CEVENT(15) = Q4L(3)
            CEVENT(16) = Q5L(1)
            CEVENT(17) = Q5L(2)
            CEVENT(18) = Q5L(3)
            CEVENT(19) = EGE
            CEVENT(20) = CGE
            CEVENT(21) = ANGE
            CEVENT(22) = EGP
            CEVENT(23) = CGP
            CEVENT(24) = ANGP   
*
*-----SUBROUTINE CUTUSER IS CALLED (I-BRANCH)
*
            CUTFLAG= 1.D0
            CALL ACCEPTANCE(CEVENT,CUTFLAG)
            IF(CUTFLAG.GT.0.D0) CALL CUTUSER(CEVENT,CUTFLAG)
            IF(CUTFLAG.GT.0.D0) THEN
               NHITW = NHITW+1
*
* BEGIN ALPHA
*
               DO III=1,4
                  MOMEN(III,1)= Q1(III-1)
                  MOMEN(III,2)= Q2(III-1)
                  MOMEN(III,3)= Q3(III-1)
                  MOMEN(III,4)= Q4(III-1)
                  MOMEN(III,5)= Q5(III-1)
               ENDDO
*
* spin sampling
*
               IF (IFLAG_SPIN.EQ.1) THEN

                  CALL SPINSAMPLING_NEW(vec(18),REDEFINED,SPINWEIGHT,
     >                                  nconf,INIT_flag)
               ELSE
                  REDEFINED=VEC(18)
                  SPINWEIGHT=1.
               ENDIF
*
               momen_in(1,1)=RSHAT/2.D0                  !new
               momen_in(2,1)=0.                  !new
               momen_in(3,1)=0.                  !new
               momen_in(4,1)=RSHAT/2.D0                  !new

               momen_in(1,2)=RSHAT/2.D0                  !new
               momen_in(2,2)=0.                  !new
               momen_in(3,2)=0.                  !new
               momen_in(4,2)=-RSHAT/2.D0                  !new

               ningoing=2                !new  number of ingoing particles
*
               ELMATSQ = 0.D0
               DO IFL = NFLMIN,NFLMAX

                  CALL PROCESSO_H(IFL)                 !new style
*
                  CALL FILLMOM(MOMEN,NOUTGOINGb,momen_in,ningoing)     !new
                  CALL SPINCOULOR_H(REDEFINED,NSPINCONF,LABEL,INIT_SPIN,
     >                   IFLAG_SPIN)
*
                  CALL ITERA(ELMAT)
*
                  IF(IFL.EQ.6) ELMATSQE = (ABS(ELMAT))**2
                  IF(IFL.EQ.7) ELMATSQM = (ABS(ELMAT))**2
               ENDDO
*
               IF(NFLV.EQ.'E') THEN
                  ELMATSQ = ELMATSQE
               ELSE IF(NFLV.EQ.'M'.OR.NFLV.EQ.'T') THEN
                  ELMATSQ = ELMATSQM
               ELSE IF(NFLV.EQ.'F') THEN
                  ELMATSQ = 2.D0*ELMATSQM + ELMATSQE
               ENDIF 
*
               EMTRX = ELMATSQ
               EMTRX = EMTRX * 32. * CFACT      
               EMTRX = EMTRX * SPINWEIGHT   ! SPIN RESCALING
*
               EMTRX = EMTRX*(4.D0*PI*ALPHA/G2/STH2)**3
*
* END ALPHA
*
               IF(IQED.EQ.1) THEN
*
*
*-----STRUCTURE FUNCTION NORM
*
                  AND1 = (1.D0-X1MIN)**BETAM-(1.D0-X1MAX)**BETAM
                  AND2 = (1.D0-X2MIN)**BETAM-(1.D0-X2MAX)**BETAM
*
                  FUNVAL = (2.D0*PI)**4/(2.D0*PI)**15/2.D0**7/2.D0*SHAT
     #                     *EMTRX*ANRM125*PRQ125*F125
     #                     *ANRM12*PRQ12*F12
     #                     *pm1cthg3*ANEG3*ANEG4*ANPHIG34
     #                     *ANCTH5S*ANPHI5S
     #                     *ANCTHS*ANPHIS*ANPHIG3
     #                     *XG3*XG4
     #                     *DOP(X1D)*DOP(X2D)*AND1*AND2

               ELSE IF(IQED.EQ.0) THEN
*
                  FUNVAL = (2.D0*PI)**4/(2.D0*PI)**15/2.D0**7/2.D0*SHAT
     #                     *EMTRX*ANRM125*PRQ125*F125
     #                     *ANRM12*PRQ12*F12
     #                     *pm1cthg3*ANEG3*ANEG4*ANPHIG34
     #                     *ANCTH5S*ANPHI5S
     #                     *ANCTHS*ANPHIS*ANPHIG3
     #                     *XG3*XG4
*
               ENDIF
*
            ELSE
               FUNVAL = 0.D0
            ENDIF
*
*-----STATISTICAL FACTOR FOR THREE INDISTINGUISHABLE PHOTONS
*
            FUNVAL = FUNVAL/6.D0
*
*
*-----CHECK POSSIBLE BIAS (GENERATION BRANCH)
*
               IF(FUNVAL.GT.FMAX) THEN
                  NBIAS = NBIAS + 1
                  ANBIAS = NBIAS*1.D0
               ENDIF
*
               IF (REFN.LT.FUNVAL) THEN
                  NHIT = NHIT + 1
                  DO I1 = 1,24
                     EVENT(I1) = CEVENT(I1)
                  ENDDO
                  print *,' accepted event',(event(i1),i1=4,18)
*
                  iacc = 1
               print *,' accepted event',(event(i1),i1=4,18)
                  CALL HFN(313,EVENT)
* 
               ENDIF
*
         ANBIASO = ANBIAS
         NHITO = NHIT
 1201    RETURN
*
      END
*
      SUBROUTINE ATLEASTONE(INPT,NFLV)
      IMPLICIT REAL*8 (A-H,O-Z)
*
      PARAMETER (LUX=4,K1=0,K2=0,LEN=25)
      REAL*4 RVEC(LEN)

      CHARACTER*1 NFLV,OGEN,OGEN0
*
      DIMENSION VEC(LEN)
*
      COMMON/CALLS/NHITWMAX,NHITMAX,NCALLS
      COMMON/NG/NPHOT   
      COMMON/OG/OGEN
      COMMON/CMENERGY/RS,S  
*
      OGEN0= OGEN
*
      IQED= 1
      IPT= 1
      OGEN= 'I'
      IF(OGEN0.EQ.'G') NHITWMAX= 100000
      INPT0= INPT
      nphot= 1
      CALL PHOT1PT(INPT,NFLV,XSECT1,DXSECT1,NHIT1,FMAXO1,EFF1,ANBIAS1)
      INPT=INPT0
      nphot= 2
      IF(OGEN0.EQ.'I') NHITWMAX= MAX(10000,NHITWMAX/10)      
      CALL PHOT2PT(INPT,NFLV,XSECT2,DXSECT2,NHIT2,FMAXO2,EFF2,ANBIAS2)
      nphot= 3
      INPT=INPT0
      IF(OGEN0.EQ.'I') NHITWMAX= MAX(10000,NHITWMAX/10)      
      CALL PHOT3(INPT,NFLV,XSECT3,DXSECT3,NHITO3,FMAXO3,EFF3,ANBIAS3)
*
      IF(OGEN0.EQ.'I') THEN
         XSECT= XSECT1+XSECT2+XSECT3
         DXSECT= DXSECT1+DXSECT2+DXSECT3
         PRINT*, ' '
         PRINT*, 'RS = ',RS
         PRINT*, ' '
         PRINT*, 'XSECT FOR 1 GAMMA= ', XSECT1, ' +- ', DXSECT1, ' (PB)'
         PRINT*, 'XSECT FOR 2 GAMMA= ', XSECT2, ' +- ', DXSECT2, ' (PB)'
         PRINT*, 'XSECT FOR 3 GAMMA= ', XSECT3, ' +- ', DXSECT3, ' (PB)'
         PRINT*, 'XSECT FOR WEIGHTED EVENTS'
         PRINT*, ' '
         PRINT*, 'XSECT = ', XSECT, ' +- ', DXSECT, ' (PB)'
         RETURN                 
      ENDIF
*
      WEIGHT=XSECT1+XSECT2+XSECT3
      W1=XSECT1/WEIGHT        
      W2=XSECT2/WEIGHT
      W3=XSECT3/WEIGHT
      W2=W2+W1
      W3=1.
      NPH1=0.
      NPH2=0.
      NPH3=0.
      BIAS1=0.
      BIAS2=0.
      BIAS3=0.
      OGEN='G'
*
      print*,'w1 = ',w1
      print*,'w2 = ',w2
      print*,'w3 = ',w3
      PRINT*,'FMAXO1 = ',FMAXO1
      PRINT*,'FMAXO2 = ',FMAXO2
      PRINT*,'FMAXO3 = ',FMAXO3
*
*-----INITIALIZE RANDOM GENERATION
*
      NMAX = NCALLS
      if (OGEN.eq.'I') then
      ICNT1 = 0
      ICNT2 = 0
      ICNT3 = 0
      NHIT = 0
      ICALL= 0
      NCHOICE= 1 
*
*-----RANDOM NUMBER GENERATOR INITIALIZATION
*
C      CALL RLUXGO(LUX,INPT,K1,K2)
      endif
*
*-----BEGINNING OF LOOP OVER EVENTS
*
      DO I = 1,NMAX
*
*-----RANDOM NUMBER GENERATION
*
         CALL RANLUX(RVEC,LEN)
*
         DO J = 1,LEN
            VEC(J) = RVEC(J)
         ENDDO
*
         IF(NCHOICE.EQ.1) THEN
            NCHOICE=0
            CHOICE=VEC(19)
         ENDIF
*
         IF(CHOICE.LT.W1) THEN
            NPHOT = 1
            ICNT1 = ICNT1 + 1
            ANBIAS1 = 0.D0
            CALL PHOT1G(VEC,NFLV,FMAXO1,NCHOICE,ANBIAS1)
            BIAS1=BIAS1+ANBIAS1
            NPH1=NPH1+NCHOICE
         ELSEIF(CHOICE.LT.W2) THEN
            NPHOT = 2
            ICNT2 = ICNT2 + 1
            ANBIAS2 = 0.D0
            CALL PHOT2G(VEC,NFLV,FMAXO2,NCHOICE,ANBIAS2,ICALL)
            ICALL= 2
            BIAS2=BIAS2+ANBIAS2
            NPH2=NPH2+NCHOICE
         ELSE
            NPHOT = 3
            ICNT3 = ICNT3 + 1
            ANBIAS3 = 0.D0
            CALL PHOT3G(VEC,NFLV,FMAXO3,NCHOICE,ANBIAS3,ICALL)
            ICALL= 3
            BIAS3=BIAS3+ANBIAS3
            NPH3=NPH3+NCHOICE
         ENDIF
         NHIT = NHIT+NCHOICE
         IF(NHIT.GE.NHITMAX) GO TO 2400
 1400 ENDDO
*
 2400 WRITE(6,*)'NUMBER OF ONE PHOTON EVENTS',NPH1
      IF(NPH1.GT.0) THEN
         WRITE(6,*)'BIAS FOR ONE PHOTON EVENTS',BIAS1/FLOAT(ICNT1)
      ENDIF
      WRITE(6,*)'NUMBER OF TWO PHOTON EVENTS',NPH2
      IF(NPH2.GT.0) THEN
         WRITE(6,*)'BIAS FOR TWO PHOTON EVENTS',BIAS2/FLOAT(ICNT2)
      ENDIF
      WRITE(6,*)'NUMBER OF THREE PHOTON EVENTS',NPH3
      IF(NPH3.GT.0) THEN
         WRITE(6,*)'BIAS FOR THREE PHOTON EVENTS',BIAS3/FLOAT(ICNT3)
      ENDIF
*
      RETURN
      END
*
      SUBROUTINE ATLEASTONEF(INPT,NFLV)
      IMPLICIT REAL*8 (A-H,O-Z)
*
      PARAMETER (LUX=4,K1=0,K2=0,LEN=25)
      REAL*4 RVEC(LEN)

      CHARACTER*1 NFLV,OGEN,OGEN0
*
      DIMENSION VEC(LEN)
*
      COMMON/CALLS/NHITWMAX,NHITMAX,NCALLS
      COMMON/NG/NPHOT   
      COMMON/OG/OGEN
      COMMON/CMENERGY/RS,S  
*
      OGEN0= OGEN
*
      IQED= 1
      IPT= 1
      OGEN= 'I'
      IF(OGEN0.EQ.'G') NHITWMAX= 100000
      INPT0= INPT
      nphot= 1
      CALL PHOT1PT(INPT,NFLV,XSECT1,DXSECT1,NHIT1,FMAXO1,EFF1,ANBIAS1)
      INPT=INPT0
      nphot= 2
      IF(OGEN0.EQ.'I') NHITWMAX= MAX(10000,NHITWMAX/10)      
      CALL PHOT2PT(INPT,NFLV,XSECT2,DXSECT2,NHIT2,FMAXO2,EFF2,ANBIAS2)
*
      IF(OGEN0.EQ.'I') THEN
         XSECT= XSECT1+XSECT2
         DXSECT= DXSECT1+DXSECT2
         PRINT*, ' '
         PRINT*, 'RS = ',RS
         PRINT*, ' '
         PRINT*, 'XSECT FOR 1 GAMMA= ', XSECT1, ' +- ', DXSECT1, ' (PB)'
         PRINT*, 'XSECT FOR 2 GAMMA= ', XSECT2, ' +- ', DXSECT2, ' (PB)'
         PRINT*, 'XSECT FOR WEIGHTED EVENTS'
         PRINT*, ' '
         PRINT*, 'XSECT = ', XSECT, ' +- ', DXSECT, ' (PB)'
         RETURN                 
      ENDIF
*
      WEIGHT=XSECT1+XSECT2
      W1=XSECT1/WEIGHT        
      W2=1.
      NPH1=0.
      NPH2=0.
      BIAS1=0.
      BIAS2=0.
      OGEN='G'
*
      print*,'w1 = ',w1
      print*,'w2 = ',w2
      PRINT*,'FMAXO1 = ',FMAXO1
      PRINT*,'FMAXO2 = ',FMAXO2
*
*-----INITIALIZE RANDOM GENERATION
*
      NMAX = NCALLS
      if (OGEN.eq.'I') then
      ICNT1 = 0
      ICNT2 = 0
      ICNT3 = 0
      NHIT = 0
      ICALL= 0
      NCHOICE= 1 
*
*-----RANDOM NUMBER GENERATOR INITIALIZATION
*
C      CALL RLUXGO(LUX,INPT,K1,K2)
      endif
*
*-----BEGINNING OF LOOP OVER EVENTS
*
      DO I = 1,NMAX
*
*-----RANDOM NUMBER GENERATION
*
         CALL RANLUX(RVEC,LEN)
*
         DO J = 1,LEN
            VEC(J) = RVEC(J)
         ENDDO
*
         IF(NCHOICE.EQ.1) THEN
            NCHOICE=0
            CHOICE=VEC(19)
         ENDIF
*
         IF(CHOICE.LT.W1) THEN
            NPHOT = 1
            ICNT1 = ICNT1 + 1
            ANBIAS1 = 0.D0
            CALL PHOT1G(VEC,NFLV,FMAXO1,NCHOICE,ANBIAS1)
            BIAS1=BIAS1+ANBIAS1
            NPH1=NPH1+NCHOICE
         ELSEIF(CHOICE.LT.W2) THEN
            NPHOT = 2
            ICNT2 = ICNT2 + 1
            ANBIAS2 = 0.D0
            CALL PHOT2G(VEC,NFLV,FMAXO2,NCHOICE,ANBIAS2,ICALL)
            ICALL= 2
            BIAS2=BIAS2+ANBIAS2
            NPH2=NPH2+NCHOICE
         ENDIF
         NHIT = NHIT+NCHOICE
         IF(NHIT.GE.NHITMAX) GO TO 2401
 1401 ENDDO
*
 2401 WRITE(6,*)'NUMBER OF ONE PHOTON EVENTS',NPH1
      IF(NPH1.GT.0) THEN
         WRITE(6,*)'BIAS FOR ONE PHOTON EVENTS',BIAS1/FLOAT(ICNT1)
      ENDIF
      WRITE(6,*)'NUMBER OF TWO PHOTON EVENTS',NPH2
      IF(NPH2.GT.0) THEN
         WRITE(6,*)'BIAS FOR TWO PHOTON EVENTS',BIAS2/FLOAT(ICNT2)
      ENDIF
*
      RETURN
      END
*
      SUBROUTINE MASSIVENU(INPT,NFLV)
      IMPLICIT REAL*8 (A-H,O-Z)
      REAL*8 MNU,MNU2
*
      PARAMETER (LUX=4,K1=0,K2=0,LEN=25)
      REAL*4 RVEC(LEN)

      CHARACTER*1 NFLV,OGEN,OGEN0
*
      DIMENSION VEC(LEN)
*
      COMMON/CALLS/NHITWMAX,NHITMAX,NCALLS
      COMMON/NG/NPHOT   
      COMMON/OG/OGEN
*
      COMMON/CMENERGY/RS,S 
      COMMON/EMC/IQED
      COMMON/NUMASS/MNU,MNU2
      COMMON/PT/IPT
*
      OGEN0= OGEN
*
      OGEN= 'I'
      IF(OGEN0.EQ.'G') NHITWMAX= 1000000
      INPT0= INPT
      nphot= 1
      IF(IPT.EQ.1) THEN
         CALL PHOT1PT(INPT,NFLV,XSECT1,DXSECT1,NHIT1,FMAXO1,
     #                EFF1,ANBIAS1)
         INPT=INPT0
         nphot= 1
         CALL PHOT1PTM(INPT,NFLV,XSECTM,DXSECTM,NHITM,FMAXOM,
     #                 EFFM,ANBIASM)
      ELSE
         CALL PHOT1(INPT,NFLV,XSECT1,DXSECT1,NHIT1,FMAXO1,
     #              EFF1,ANBIAS1)
         INPT=INPT0
         nphot= 1
         CALL PHOT1M(INPT,NFLV,XSECTM,DXSECTM,NHITM,FMAXOM,
     #               EFFM,ANBIASM)
      ENDIF
*
      IF(OGEN0.EQ.'I') THEN
         XSECT= XSECT1+XSECTM
         DXSECT= DXSECT1+DXSECTM
         PRINT*, ' '
         PRINT*, 'RS = ',RS
         PRINT*, 'NEUTRINO MASS = ',MNU,' (GEV)'
         PRINT*, ' '
         PRINT*, 'XSECT FOR 1 GAMMA=    ',XSECT1,' +- ',DXSECT1,' (PB)'
         PRINT*, 'XSECT FOR 1 GAMMA M = ',XSECTM,' +- ',DXSECTM,' (PB)'
         PRINT*, 'XSECT FOR WEIGHTED EVENTS'
         PRINT*, ' '
         PRINT*, 'XSECT = ', XSECT, ' +- ', DXSECT, ' (PB)'
         RETURN                 
      ENDIF
*
      WEIGHT=XSECT1+XSECTM
      W1=XSECT1/WEIGHT        
      W2=1.
      NPH1=0.
      NPHM=0.
      BIAS1=0.
      BIASM=0.
      OGEN='G'
*
      print*,'w1 = ',w1
      print*,'w2 = ',w2
      PRINT*,'FMAXO1 = ',FMAXO1
      PRINT*,'FMAXOM = ',FMAXOM
*
*-----INITIALIZE RANDOM GENERATION
*
      NMAX = NCALLS
      if (OGEN.eq.'I') then
      ICNT1 = 0
      ICNTM = 0
      NHIT = 0
      NCHOICE= 1 
*
*-----RANDOM NUMBER GENERATOR INITIALIZATION
*
C      CALL RLUXGO(LUX,INPT,K1,K2)
      endif
*
*-----BEGINNING OF LOOP OVER EVENTS
*
      DO I = 1,NMAX
*
*-----RANDOM NUMBER GENERATION
*
         CALL RANLUX(RVEC,LEN)
*
         DO J = 1,LEN
            VEC(J) = RVEC(J)
         ENDDO
*
         IF(NCHOICE.EQ.1) THEN
            NCHOICE=0
            CHOICE=VEC(19)
         ENDIF
*
         IF(CHOICE.LT.W1) THEN
            NPHOT = 1
            ICNT1 = ICNT1 + 1
            ANBIAS1 = 0.D0
            CALL PHOT1G(VEC,NFLV,FMAXO1,NCHOICE,ANBIAS1)
            BIAS1=BIAS1+ANBIAS1
            NPH1=NPH1+NCHOICE
         ELSEIF(CHOICE.LT.W2) THEN
            NPHOT = 1
            ICNTM = ICNTM + 1
            ANBIASM = 0.D0
            CALL PHOT1GM(VEC,NFLV,FMAXOM,NCHOICE,ANBIASM)
            BIASM=BIASM+ANBIASM
            NPHM=NPHM+NCHOICE
         ENDIF
         NHIT = NHIT+NCHOICE
         IF(NHIT.GE.NHITMAX) GO TO 2401
 1401 ENDDO
*
 2401 WRITE(6,*)'NUMBER OF ONE PHOTON EVENTS',NPH1
      IF(NPH1.GT.0) THEN
         WRITE(6,*)'BIAS FOR ONE PHOTON EVENTS',BIAS1/FLOAT(ICNT1)
      ENDIF
      WRITE(6,*)'NUMBER OF M PHOTON EVENTS',NPHM
      IF(NPHM.GT.0) THEN
         WRITE(6,*)'BIAS FOR M PHOTON EVENTS',BIASM/FLOAT(ICNTM)
      ENDIF
*
      if (OGEN.eq.'I') then
      ICNT1 = 0
      ICNTM = 0
      NHIT = 0
      NCHOICE= 1 
      endif
      RETURN
      END
      SUBROUTINE RANLUX(RVEC,LENV)
      parameter(lenr=25)
      DIMENSION RVEC(LENr)
      call ranmar(rvec,lenr)
      return
      ENTRY RLUXGO(LUX,INS,K1,K2)
      call RDMIN(k1)
      print *, ' RLUXGO has been called for init'
      return
      end
*-----SUBROUTINE RANLUX: RANDOM NUMBER GENERATOR
*
      SUBROUTINE ORANLUX(RVEC,LENV)
C         SUBTRACT-AND-BORROW RANDOM NUMBER GENERATOR PROPOSED BY
C         MARSAGLIA AND ZAMAN, IMPLEMENTED BY F. JAMES WITH THE NAME
C         RCARRY IN 1991, AND LATER IMPROVED BY MARTIN LUESCHER
C         IN 1993 TO PRODUCE "LUXURY PSEUDORANDOM NUMBERS".
C     FORTRAN 77 CODED BY F. JAMES, 1993
C
C   LUXURY LEVELS.
C   ------ ------      THE AVAILABLE LUXURY LEVELS ARE:
C
C  LEVEL 0  (P=24): EQUIVALENT TO THE ORIGINAL RCARRY OF MARSAGLIA
C           AND ZAMAN, VERY LONG PERIOD, BUT FAILS MANY TESTS.
C  LEVEL 1  (P=48): CONSIDERABLE IMPROVEMENT IN QUALITY OVER LEVEL 0,
C           NOW PASSES THE GAP TEST, BUT STILL FAILS SPECTRAL TEST.
C  LEVEL 2  (P=97): PASSES ALL KNOWN TESTS, BUT THEORETICALLY STILL
C           DEFECTIVE.
C  LEVEL 3  (P=223): DEFAULT VALUE.  ANY THEORETICALLY POSSIBLE
C           CORRELATIONS HAVE VERY SMALL CHANCE OF BEING OBSERVED.
C  LEVEL 4  (P=389): HIGHEST POSSIBLE LUXURY, ALL 24 BITS CHAOTIC.
C
C!!! ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C!!!  CALLING SEQUENCES FOR RANLUX:                                  ++
C!!!      CALL RANLUX (RVEC, LEN)   RETURNS A VECTOR RVEC OF LEN     ++
C!!!                   32-BIT RANDOM FLOATING POINT NUMBERS BETWEEN  ++
C!!!                   ZERO (NOT INCLUDED) AND ONE (ALSO NOT INCL.). ++
C!!!      CALL RLUXGO(LUX,INT,K1,K2) INITIALIZES THE GENERATOR FROM  ++
C!!!               ONE 32-BIT INTEGER INT AND SETS LUXURY LEVEL LUX  ++
C!!!               WHICH IS INTEGER BETWEEN ZERO AND MAXLEV, OR IF   ++
C!!!               LUX .GT. 24, IT SETS P=LUX DIRECTLY.  K1 AND K2   ++
C!!!               SHOULD BE SET TO ZERO UNLESS RESTARTING AT A BREAK++
C!!!               POINT GIVEN BY OUTPUT OF RLUXAT (SEE RLUXAT).     ++
C!!!      CALL RLUXAT(LUX,INT,K1,K2) GETS THE VALUES OF FOUR INTEGERS++
C!!!               WHICH CAN BE USED TO RESTART THE RANLUX GENERATOR ++
C!!!               AT THE CURRENT POINT BY CALLING RLUXGO.  K1 AND K2++
C!!!               SPECIFY HOW MANY NUMBERS WERE GENERATED SINCE THE ++
C!!!               INITIALIZATION WITH LUX AND INT.  THE RESTARTING  ++
C!!!               SKIPS OVER  K1+K2*E9   NUMBERS, SO IT CAN BE LONG.++
C!!!   A MORE EFFICIENT BUT LESS CONVENIENT WAY OF RESTARTING IS BY: ++
C!!!      CALL RLUXIN(ISVEC)    RESTARTS THE GENERATOR FROM VECTOR   ++
C!!!                   ISVEC OF 25 32-BIT INTEGERS (SEE RLUXUT)      ++
C!!!      CALL RLUXUT(ISVEC)    OUTPUTS THE CURRENT VALUES OF THE 25 ++
C!!!                 32-BIT INTEGER SEEDS, TO BE USED FOR RESTARTING ++
C!!!      ISVEC MUST BE DIMENSIONED 25 IN THE CALLING PROGRAM        ++
C!!! ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      DIMENSION RVEC(LENV)
      DIMENSION SEEDS(24), ISEEDS(24), ISDEXT(25)
      PARAMETER (MAXLEV=4, LXDFLT=3)
      DIMENSION NDSKIP(0:MAXLEV)
      DIMENSION NEXT(24)
      PARAMETER (TWOP12=4096., IGIGA=1000000000,JSDFLT=314159265)
      PARAMETER (ITWO24=2**24, ICONS=2147483563)
      SAVE NOTYET, I24, J24, CARRY, SEEDS, TWOM24, TWOM12, LUXLEV
      SAVE NSKIP, NDSKIP, IN24, NEXT, KOUNT, MKOUNT, INSEED
      INTEGER LUXLEV
      LOGICAL NOTYET
      DATA NOTYET, LUXLEV, IN24, KOUNT, MKOUNT /.TRUE., LXDFLT, 0,0,0/
      DATA I24,J24,CARRY/24,10,0./
C                               DEFAULT
C  LUXURY LEVEL   0     1     2   *3*    4
      DATA NDSKIP/0,   24,   73,  199,  365 /
CORRESPONDS TO P=24    48    97   223   389
C     TIME FACTOR 1     2     3     6    10   ON SLOW WORKSTATION
C                 1    1.5    2     3     5   ON FAST MAINFRAME
C
C  NOTYET IS .TRUE. IF NO INITIALIZATION HAS BEEN PERFORMED YET.
C              DEFAULT INITIALIZATION BY MULTIPLICATIVE CONGRUENTIAL
      IF (NOTYET) THEN
         NOTYET = .FALSE.
         JSEED = JSDFLT
         INSEED = JSEED
         WRITE(6,'(A,I12)') ' RANLUX DEFAULT INITIALIZATION: ',JSEED
         LUXLEV = LXDFLT
         NSKIP = NDSKIP(LUXLEV)
         LP = NSKIP + 24
         IN24 = 0
         KOUNT = 0
         MKOUNT = 0
         WRITE(6,'(A,I2,A,I4)')  ' RANLUX DEFAULT LUXURY LEVEL =  ',
     +        LUXLEV,'      P =',LP
            TWOM24 = 1.
         DO 25 I= 1, 24
            TWOM24 = TWOM24 * 0.5
         K = JSEED/53668
         JSEED = 40014*(JSEED-K*53668) -K*12211
         IF (JSEED .LT. 0)  JSEED = JSEED+ICONS
         ISEEDS(I) = MOD(JSEED,ITWO24)
   25    CONTINUE
         TWOM12 = TWOM24 * 4096.
         DO 50 I= 1,24
         SEEDS(I) = REAL(ISEEDS(I))*TWOM24
         NEXT(I) = I-1
   50    CONTINUE
         NEXT(1) = 24
         I24 = 24
         J24 = 10
         CARRY = 0.
         IF (SEEDS(24) .EQ. 0.) CARRY = TWOM24
      ENDIF
C
C          THE GENERATOR PROPER: "SUBTRACT-WITH-BORROW",
C          AS PROPOSED BY MARSAGLIA AND ZAMAN,
C          FLORIDA STATE UNIVERSITY, MARCH, 1989
C
      DO 100 IVEC= 1, LENV
      UNI = SEEDS(J24) - SEEDS(I24) - CARRY
      IF (UNI .LT. 0.)  THEN
         UNI = UNI + 1.0
         CARRY = TWOM24
      ELSE
         CARRY = 0.
      ENDIF
      SEEDS(I24) = UNI
      I24 = NEXT(I24)
      J24 = NEXT(J24)
      RVEC(IVEC) = UNI
C  SMALL NUMBERS (WITH LESS THAN 12 "SIGNIFICANT" BITS) ARE "PADDED".
      IF (UNI .LT. TWOM12)  THEN
         RVEC(IVEC) = RVEC(IVEC) + TWOM24*SEEDS(J24)
C        AND ZERO IS FORBIDDEN IN CASE SOMEONE TAKES A LOGARITHM
         IF (RVEC(IVEC) .EQ. 0.)  RVEC(IVEC) = TWOM24*TWOM24
      ENDIF
C        SKIPPING TO LUXURY.  AS PROPOSED BY MARTIN LUSCHER.
      IN24 = IN24 + 1
      IF (IN24 .EQ. 24)  THEN
         IN24 = 0
         KOUNT = KOUNT + NSKIP
         DO 90 ISK= 1, NSKIP
         UNI = SEEDS(J24) - SEEDS(I24) - CARRY
         IF (UNI .LT. 0.)  THEN
            UNI = UNI + 1.0
            CARRY = TWOM24
         ELSE
            CARRY = 0.
         ENDIF
         SEEDS(I24) = UNI
         I24 = NEXT(I24)
         J24 = NEXT(J24)
   90    CONTINUE
      ENDIF
  100 CONTINUE
      KOUNT = KOUNT + LENV
      IF (KOUNT .GE. IGIGA)  THEN
         MKOUNT = MKOUNT + 1
         KOUNT = KOUNT - IGIGA
      ENDIF
      RETURN
C
C           ENTRY TO INPUT AND FLOAT INTEGER SEEDS FROM PREVIOUS RUN
      ENTRY RLUXIN(ISDEXT)
         TWOM24 = 1.
         DO 195 I= 1, 24
         NEXT(I) = I-1
  195    TWOM24 = TWOM24 * 0.5
         NEXT(1) = 24
         TWOM12 = TWOM24 * 4096.
      WRITE(6,'(A)') ' FULL INITIALIZATION OF RANLUX WITH 25 INTEGERS:'
      WRITE(6,'(5X,5I12)') ISDEXT
      DO 200 I= 1, 24
      SEEDS(I) = REAL(ISDEXT(I))*TWOM24
  200 CONTINUE
      CARRY = 0.
      IF (ISDEXT(25) .LT. 0)  CARRY = TWOM24
      ISD = IABS(ISDEXT(25))
      I24 = MOD(ISD,100)
      ISD = ISD/100
      J24 = MOD(ISD,100)
      ISD = ISD/100
      IN24 = MOD(ISD,100)
      ISD = ISD/100
      LUXLEV = ISD
        IF (LUXLEV .LE. MAXLEV) THEN
          NSKIP = NDSKIP(LUXLEV)
          WRITE (6,'(A,I2)') ' RANLUX LUXURY LEVEL SET BY RLUXIN TO: ',
     +                         LUXLEV
        ELSE  IF (LUXLEV .GE. 24) THEN
          NSKIP = LUXLEV - 24
          WRITE (6,'(A,I5)') ' RANLUX P-VALUE SET BY RLUXIN TO:',LUXLEV
        ELSE
          NSKIP = NDSKIP(MAXLEV)
          WRITE (6,'(A,I5)') ' RANLUX ILLEGAL LUXURY RLUXIN: ',LUXLEV
          LUXLEV = MAXLEV
        ENDIF
      INSEED = -1
      RETURN
C
C                    ENTRY TO OUPUT SEEDS AS INTEGERS
      ENTRY RLUXUT(ISDEXT)
      DO 300 I= 1, 24
         ISDEXT(I) = INT(SEEDS(I)*TWOP12*TWOP12)
  300 CONTINUE
      ISDEXT(25) = I24 + 100*J24 + 10000*IN24 + 1000000*LUXLEV
      IF (CARRY .GT. 0.)  ISDEXT(25) = -ISDEXT(25)
      RETURN
C
C                    ENTRY TO OUTPUT THE "CONVENIENT" RESTART POINT
      ENTRY RLUXAT(LOUT,INOUT,K1,K2)
      LOUT = LUXLEV
      INOUT = INSEED
      K1 = KOUNT
      K2 = MKOUNT
      RETURN
C
C                    ENTRY TO INITIALIZE FROM ONE OR THREE INTEGERS
      ENTRY ORLUXGO(LUX,INS,K1,K2)
         IF (LUX .LT. 0) THEN
            LUXLEV = LXDFLT
         ELSE IF (LUX .LE. MAXLEV) THEN
            LUXLEV = LUX
         ELSE IF (LUX .LT. 24 .OR. LUX .GT. 2000) THEN
            LUXLEV = MAXLEV
            WRITE (6,'(A,I7)') ' RANLUX ILLEGAL LUXURY RLUXGO: ',LUX
         ELSE
            LUXLEV = LUX
            DO 310 ILX= 0, MAXLEV
              IF (LUX .EQ. NDSKIP(ILX)+24)  LUXLEV = ILX
  310       CONTINUE
         ENDIF
      IF (LUXLEV .LE. MAXLEV)  THEN
         NSKIP = NDSKIP(LUXLEV)
C         WRITE(6,'(A,I2,A,I4)') ' RANLUX LUXURY LEVEL SET BY RLUXGO :',
C     +        LUXLEV,'     P=', NSKIP+24
      ELSE
          NSKIP = LUXLEV - 24
          WRITE (6,'(A,I5)') ' RANLUX P-VALUE SET BY RLUXGO TO:',LUXLEV
      ENDIF
      IN24 = 0
      IF (INS .LT. 0)  WRITE (6,'(A)')
     +   ' ILLEGAL INITIALIZATION BY RLUXGO, NEGATIVE INPUT SEED'
      IF (INS .GT. 0)  THEN
       JSEED = INS
C        WRITE(6,'(A,3I12)') ' RANLUX INITIALIZED BY RLUXGO FROM SEEDS',
C     +      JSEED, K1,K2
      ELSE
        JSEED = JSDFLT
C        WRITE(6,'(A)')' RANLUX INITIALIZED BY RLUXGO FROM DEFAULT SEED'
      ENDIF
      INSEED = JSEED
      NOTYET = .FALSE.
      TWOM24 = 1.
         DO 325 I= 1, 24
           TWOM24 = TWOM24 * 0.5
         K = JSEED/53668
         JSEED = 40014*(JSEED-K*53668) -K*12211
         IF (JSEED .LT. 0)  JSEED = JSEED+ICONS
         ISEEDS(I) = MOD(JSEED,ITWO24)
  325    CONTINUE
      TWOM12 = TWOM24 * 4096.
         DO 350 I= 1,24
         SEEDS(I) = REAL(ISEEDS(I))*TWOM24
         NEXT(I) = I-1
  350    CONTINUE
      NEXT(1) = 24
      I24 = 24
      J24 = 10
      CARRY = 0.
      IF (SEEDS(24) .EQ. 0.) CARRY = TWOM24
C        IF RESTARTING AT A BREAK POINT, SKIP K1 + IGIGA*K2
C        NOTE THAT THIS IS THE NUMBER OF NUMBERS DELIVERED TO
C        THE USER PLUS THE NUMBER SKIPPED (IF LUXURY .GT. 0).
      KOUNT = K1
      MKOUNT = K2
      IF (K1+K2 .NE. 0)  THEN
        DO 500 IOUTER= 1, K2+1
          INNER = IGIGA
          IF (IOUTER .EQ. K2+1)  INNER = K1
          DO 450 ISK= 1, INNER
            UNI = SEEDS(J24) - SEEDS(I24) - CARRY
            IF (UNI .LT. 0.)  THEN
               UNI = UNI + 1.0
               CARRY = TWOM24
            ELSE
               CARRY = 0.
            ENDIF
            SEEDS(I24) = UNI
            I24 = NEXT(I24)
            J24 = NEXT(J24)
  450     CONTINUE
  500   CONTINUE
C         GET THE RIGHT VALUE OF IN24 BY DIRECT CALCULATION
        IN24 = MOD(KOUNT, NSKIP+24)
        IF (MKOUNT .GT. 0)  THEN
           IZIP = MOD(IGIGA, NSKIP+24)
           IZIP2 = MKOUNT*IZIP + IN24
           IN24 = MOD(IZIP2, NSKIP+24)
        ENDIF
C       NOW IN24 HAD BETTER BE BETWEEN ZERO AND 23 INCLUSIVE
        IF (IN24 .GT. 23) THEN
           WRITE (6,'(A/A,3I11,A,I5)')
     +    '  ERROR IN RESTARTING WITH RLUXGO:','  THE VALUES', INS,
     +     K1, K2, ' CANNOT OCCUR AT LUXURY LEVEL', LUXLEV
           IN24 = 0
        ENDIF
      ENDIF
      RETURN
      END
C +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C **********************************************************************
C
C **********************************************************************

*
      SUBROUTINE DPHI2(QI2,QJ2,QK2,CTHJ,PHIJ,QJ,QK,FLUX,IKINEI)
*
      IMPLICIT REAL*8 (A-H,O-Z)
      DIMENSION QJ(0:3),QK(0:3)
*
      STHJ= SQRT(1.D0-CTHJ*CTHJ)
      CPHIJ= COS(PHIJ)
      SPHIJ= SIN(PHIJ)
*
      QJM2= (QI2+QK2-QJ2)*(QI2+QK2-QJ2)/4.D0/QI2 - QK2
      IF(QJM2.LT.0.D0) THEN
         IKINEI= IKINEI+1
         QJM2 = 1.D-13
      ENDIF
      QJM= SQRT(QJM2)
*
* MOMENTA ARE CALCULATED
*
      QJ(0)= SQRT(QJ2+QJM2)
      QJ(1)= QJM*STHJ*CPHIJ
      QJ(2)= QJM*STHJ*SPHIJ
      QJ(3)= QJM*CTHJ
*
      QK(0)= SQRT(QK2+QJ(1)*QJ(1)+QJ(2)*QJ(2)+QJ(3)*QJ(3))
      QK(1)= -QJ(1)
      QK(2)= -QJ(2)
      QK(3)= -QJ(3)
*
* FLUX IS CALCULATED
*
      FLUX= QJM/(QJ(0)+QK(0))
*
      RETURN
      END
*
* INPUT:  QJS_0 ,QJS_X, QJS_Y, QJS_Z, QI_0, QI_1, QI_2, QI_3
* OUTPUT: QJ_0, QJ_X, QJ_Y, QJ_Z, DJ2
*
      SUBROUTINE BOOST(QJS,QI,QJ)
*
      IMPLICIT REAL*8 (A-H,O-Z)
      DIMENSION QJS(0:3),QI(0:3),QJ(0:3)
      DIMENSION QJT(3),AN(3),QJSL(3)
*
      QIL= SQRT(QI(1)*QI(1)+QI(2)*QI(2)+QI(3)*QI(3))
*
      ZERO = 1.D-13
*
      IF(QI(0).GT.ZERO.AND.QIL.GT.ZERO) THEN
         BI= QIL/QI(0)
         IF(BI.GE.1.D0) THEN
            GML = 1.D13
         ELSE
            GML= 1.D0/SQRT(1.D0-BI*BI)
         ENDIF
      ELSE
         BI = 0.D0
         GML = 1.D0
      ENDIF
*
      IF(ABS(QIL).LT.ZERO) THEN
         AN(1)= 0.D0
         AN(2)= 0.D0
         AN(3)= 0.D0
      ELSE
         AN(1)= -QI(1)/QIL
         AN(2)= -QI(2)/QIL
         AN(3)= -QI(3)/QIL
      ENDIF
*
      QJSLM= QJS(1)*AN(1)+QJS(2)*AN(2)+QJS(3)*AN(3)
      QJSL(1)= QJSLM*AN(1)
      QJSL(2)= QJSLM*AN(2)
      QJSL(3)= QJSLM*AN(3)
      QJT(1)= QJS(1)-QJSL(1)
      QJT(2)= QJS(2)-QJSL(2)
      QJT(3)= QJS(3)-QJSL(3)
*
      QJ(0)= GML*(QJS(0)-BI*QJSLM)
      QJLM= GML*(-BI*QJS(0)+QJSLM)
*
      QJ(1)= QJLM*AN(1)+QJT(1)
      QJ(2)= QJLM*AN(2)+QJT(2)
      QJ(3)= QJLM*AN(3)+QJT(3)
*
      RETURN
      END
*
      SUBROUTINE BOOSTPT(QJS,BLAB,GLOR,ANX,ANY,ANZ,QJ)
*
      IMPLICIT REAL*8 (A-H,O-Z)
      DIMENSION QJS(0:3),QJ(0:3)
*
      QJL = QJS(1)*ANX+QJS(2)*ANY+QJS(3)*ANZ
      QJLLAB = GLOR*(QJL-BLAB*QJS(0))
      QJ0LAB = GLOR*(QJS(0)-BLAB*QJL)
*
      QJXT = QJS(1) - QJL*ANX
      QJYT = QJS(2) - QJL*ANY
      QJZT = QJS(3) - QJL*ANZ
*
      QJ(1) = QJLLAB*ANX+QJXT
      QJ(2) = QJLLAB*ANY+QJYT
      QJ(3) = QJLLAB*ANZ+QJZT
      QJ(0) = QJ0LAB
*
      RETURN
      END
*
      FUNCTION SCALPROD(QI,QJ)
      IMPLICIT REAL*8 (A-H,O-Z)
      DIMENSION QI(0:3),QJ(0:3)
      SCALPROD= QI(1)*QJ(1)+QI(2)*QJ(2)+QI(3)*QJ(3)-QI(0)*QJ(0)
      RETURN
      END
*
      SUBROUTINE INITIAL0()
      IMPLICIT REAL*8 (A-H,O-Z)
*
      EXTERNAL X01ABF,S14AAF
*
      COMMON/CMENERGY/RS,S
      COMMON/CHANN/ICHANNEL
      COMMON/COUPL/FI3E,QFE,FI31,QF1,FI32,QF2,FI33,QF3,FI34,QF4,
     #            FI35,QF5,FI36,QF6
      COMMON/PAR/WM,WG,CFACT,GF,G,ZM,ZW,PI,ALPHA,EM2
      COMMON/FM/EM,AMU,TLM,UQM,DQM,CQM,SQM,BQM,TQM
      COMMON/EM/RL,ETA,BETA,SDELTA,BETAM
      COMMON/QCM/QMF1,QMF2,QMF3,QMF4,QMF5,QMF6
*
      FI3E= -0.5D0
      QFE= -1.D0
      FI31= -0.5D0
      QF1= -1.D0/3.D0
      FI32= +0.5D0
      QF2= +2.D0/3.D0
      FI33= +0.5D0
      QF3= +0.D0
      FI34= -0.5D0
      QF4= -1.D0
*
*-----ISR E.M. QUANTITIES ARE INITIALIZED
*
      API= ALPHA/PI
      EM2= EM*EM
*
      RL= LOG(S/EM2)
      RL2= RL*RL
      ETA= 2.D0*API*RL
      BETA= 2.D0*API*(RL-1.D0)
C      print *,'initial0 : s,em,em2 ',s,em,em2
C      print *,'initial0 : api ', api
C      print *,'initial0 : rl ', rl
C      print *,'initial0 : beta ', beta
*
      BETAM= BETA/2.D0
      OPBM= 1.D0+BETAM
*
*-----GRIBOV-LIPATOV FORM FACTOR
*
C      print *,'initial0 : betam ', betam
C      print *,'initial0 : OPBM  ', OPBM
      GE = 0.5772156649015329D0
      SDELTA= EXP(BETAM*(3.D0/4.D0-GE))/DGAMMA(OPBM)
*
      RETURN
      END
*
      SUBROUTINE INVMBW(SS,C,X2MN,X2M,RM2,RW,QIJ2,ANRMIJ,PRQIJ,IS)
      IMPLICIT REAL*8 (A-H,O-Z)
*
      X2MIN = X2MN
      X2MAX = X2M
*
      XM2X = ATAN((X2MAX-RM2)/RW)
      XM2N = ATAN((X2MIN-RM2)/RW)
*
      IF(IS.EQ.0) THEN
         ANRMIJ = X2MAX-X2MIN
         XIJ = (X2MAX-X2MIN)*C + X2MIN
         PRQIJ = 1.D0
      ELSE 
         ANRMIJ = (XM2X-XM2N)/RW
         XIJ = RM2 + RW*TAN(XM2X*C+XM2N*(1.D0-C))
         PRQIJ = (XIJ-RM2)*(XIJ-RM2) + RW*RW
      ENDIF
*
      QIJ2 = XIJ*SS
*
      RETURN
      END
*
      SUBROUTINE INVMPHBWF(SS,C,X2MN,X2M,RM2,RW,QIJ2,ANRMIJ,PRQIJ,IS)
      IMPLICIT REAL*8 (A-H,O-Z)
*
      REAL*8 C_EX(0:3)/0.,0.,0.,1./,X_EX(0:3)
      REAL*8 C_EXOUT(0:3)
      DATA IREAD/0/
*
      IF(IS.EQ.0) THEN
         ANRMIJ = X2M-X2MN
         XIJ = (X2M-X2MN)*C + X2MN
         PRQIJ = 1.D0
         RETURN
      ENDIF
*
      X_EX(0)=X2MN
      X_EX(3)=X2M
*
      IF(IREAD.EQ.0) THEN
         IREAD = 1
         DO I = 1,2
            READ*,C_EX(I)
            PRINT*,'C= ',C_EX(I)
            C_EXOUT(I)= C_EX(I)
         ENDDO
      ENDIF
*
      RM= SQRT(RM2)
      RG= RW/RM
      EXTBWMN= (RM-4.D0*RG)**2
      EXTBWMX= (RM+4.D0*RG)**2
      DX= (X2M-X2MN)/10.D0
*
      IF(RM2.GT.X2MN.AND.RM2.LT.X2M) THEN
*
         X_EX(1)= EXTBWMN
         X_EX(2)= EXTBWMX
*
         IF(EXTBWMN.GT.X2MN.AND.EXTBWMX.LT.X2M) THEN
          I= 1
          DO WHILE(C.GT.C_EX(I))
           I= I+1
          ENDDO
          CB= (C-C_EX(I-1))/(C_EX(I)-C_EX(I-1))
          IF(I.EQ.1) THEN
           CALL PHOT(SS,CB,X_EX(I-1),X_EX(I),QIJ2,ANRMIJ,PRQIJ)
          ELSE IF(I.EQ.2) THEN
           CALL ATG(SS,CB,X_EX(I-1),X_EX(I),RM2,RW,QIJ2,ANRMIJ,PRQIJ)
          ELSE
           CALL FLAT(SS,CB,X_EX(I-1),X_EX(I),QIJ2,ANRMIJ,PRQIJ)
          ENDIF
          ANRMIJ= ANRMIJ/(C_EX(I)-C_EX(I-1))
         ELSE IF(EXTBWMN.LT.X2MN.AND.EXTBWMX.GT.X2M) THEN
           CALL ATG(SS,C,X2MN,X2M,RM2,RW,QIJ2,ANRMIJ,PRQIJ)
         ELSE IF(EXTBWMN.LT.X2MN.AND.EXTBWMX.LT.X2M) THEN
          C_EX(1)= 0.D0
          I= 2
          DO WHILE(C.GT.C_EX(I))
             I= I+1
          ENDDO
          CB= (C-C_EX(I-1))/(C_EX(I)-C_EX(I-1))
          IF(I.EQ.2) THEN
             CALL ATG(SS,CB,X_EX(I-1),X_EX(I),RM2,RW,QIJ2,ANRMIJ,PRQIJ)
          ELSE IF(I.EQ.3) THEN
             CALL FLAT(SS,CB,X_EX(I-1),X_EX(I),QIJ2,ANRMIJ,PRQIJ)
          ELSE 
             PRINT*,'SUCCESSO QUALCOSA DI STRANO NEGLI ESTREMI'
          ENDIF
          ANRMIJ= ANRMIJ/(C_EX(I)-C_EX(I-1))
         ELSE IF(EXTBWMN.GT.X2MN.AND.EXTBWMX.GT.X2M) THEN
          I= 1
          C_EX(2)= 1.D0
          DO WHILE(C.GT.C_EX(I))
             I= I+1
          ENDDO
          CB= (C-C_EX(I-1))/(C_EX(I)-C_EX(I-1))
          IF(I.EQ.1) THEN
             CALL PHOT(SS,CB,X_EX(I-1),X_EX(I),QIJ2,ANRMIJ,PRQIJ)
          ELSE IF(I.EQ.2) THEN
             CALL ATG(SS,CB,X_EX(I-1),X_EX(I),RM2,RW,QIJ2,ANRMIJ,PRQIJ)
          ELSE
             PRINT*,'SUCCESSO QUALCOSA DI STRANO NEGLI ESTREMI'
          ENDIF
          ANRMIJ= ANRMIJ/(C_EX(I)-C_EX(I-1))
         ELSE
          PRINT*,'SUCCESSO QUALCOSA DI STRANO NEGLI ESTREMI'
         ENDIF
      ELSE IF(RM2.LE.X2MN) THEN
         C_EX(1)= 0.D0
         X_EX(1)= X_EX(0)
         XPDX= X2MN + DX
         IF(EXTBWMX.LT.X2M) THEN
            X_EX(2)= MAX(EXTBWMX,XPDX)
         ELSE
            X_EX(2)= XPDX
         ENDIF
         I= 2
         DO WHILE(C.GT.C_EX(I))
            I= I+1
         ENDDO
         CB= (C-C_EX(I-1))/(C_EX(I)-C_EX(I-1))
         IF(I.EQ.2) THEN
            CALL ATG(SS,CB,X_EX(I-1),X_EX(I),RM2,RW,QIJ2,ANRMIJ,PRQIJ)
         ELSE IF(I.EQ.3) THEN
            CALL FLAT(SS,CB,X_EX(I-1),X_EX(I),QIJ2,ANRMIJ,PRQIJ)
         ELSE 
            PRINT*,'SUCCESSO QUALCOSA DI STRANO NEGLI ESTREMI'
         ENDIF
         ANRMIJ= ANRMIJ/(C_EX(I)-C_EX(I-1))
      ELSE IF(RM2.GE.X2M) THEN
         X_EX(2)= X_EX(3)
         XMDX= X2M - DX
         IF(EXTBWMN.GT.X2MN) THEN
            X_EX(1)= MIN(EXTBWMN,XMDX)
         ELSE
            X_EX(1)= XMDX
         ENDIF
         I= 1
         C_EX(2)= 1.D0
         DO WHILE(C.GT.C_EX(I))
            I= I+1
         ENDDO
         CB= (C-C_EX(I-1))/(C_EX(I)-C_EX(I-1))
         IF(I.EQ.1) THEN
            CALL PHOT(SS,CB,X_EX(I-1),X_EX(I),QIJ2,ANRMIJ,PRQIJ)
         ELSE IF(I.EQ.2) THEN
            CALL ATG(SS,CB,X_EX(I-1),X_EX(I),RM2,RW,QIJ2,ANRMIJ,PRQIJ)
         ELSE
            PRINT*,'SUCCESSO QUALCOSA DI STRANO NEGLI ESTREMI'
         ENDIF
         ANRMIJ= ANRMIJ/(C_EX(I)-C_EX(I-1))

      ENDIF
*
      DO I = 1,2
         C_EX(I)= C_EXOUT(I)
      ENDDO
*
      RETURN
      END
*
      SUBROUTINE INVMFBWF(SS,C,X2MN,X2M,RM2,RW,QIJ2,ANRMIJ,PRQIJ,IS)
      IMPLICIT REAL*8 (A-H,O-Z)
*
      REAL*8 C_EX(0:3)/0.,0.,0.,1./,X_EX(0:3)
      REAL*8 C_EXOUT(0:3)
      DATA IREAD/0/
*
      IF(IS.EQ.0) THEN
         ANRMIJ = X2M-X2MN
         XIJ = (X2M-X2MN)*C + X2MN
         PRQIJ = 1.D0
         QIJ2 = XIJ*SS
         RETURN
      ENDIF
*
      X_EX(0)=X2MN
      X_EX(3)=X2M
*
      IF(IREAD.EQ.0) THEN
         IREAD = 1
         C_EX(1)= 0.3D0
         C_EX(2)= 0.7D0
         DO I = 1,2
            C_EXOUT(I)= C_EX(I)
         ENDDO
      ENDIF
*
      RM= SQRT(RM2)
      RG= RW/RM
      EXTBWMN= (RM-4.D0*RG)**2
      EXTBWMX= (RM+4.D0*RG)**2
      DX= (X2M-X2MN)/10.D0
*
      IF(RM2.GT.X2MN.AND.RM2.LT.X2M) THEN
*
         X_EX(1)= EXTBWMN
         X_EX(2)= EXTBWMX
*
         IF(EXTBWMN.GT.X2MN.AND.EXTBWMX.LT.X2M) THEN
          I= 1
          DO WHILE(C.GT.C_EX(I))
           I= I+1
          ENDDO
          CB= (C-C_EX(I-1))/(C_EX(I)-C_EX(I-1))
          IF(I.EQ.1) THEN
           CALL FLAT(SS,CB,X_EX(I-1),X_EX(I),QIJ2,ANRMIJ,PRQIJ)
          ELSE IF(I.EQ.2) THEN
           CALL ATG(SS,CB,X_EX(I-1),X_EX(I),RM2,RW,QIJ2,ANRMIJ,PRQIJ)
          ELSE
           CALL FLAT(SS,CB,X_EX(I-1),X_EX(I),QIJ2,ANRMIJ,PRQIJ)
          ENDIF
          ANRMIJ= ANRMIJ/(C_EX(I)-C_EX(I-1))
         ELSE IF(EXTBWMN.LT.X2MN.AND.EXTBWMX.GT.X2M) THEN
           CALL ATG(SS,C,X2MN,X2M,RM2,RW,QIJ2,ANRMIJ,PRQIJ)
         ELSE IF(EXTBWMN.LT.X2MN.AND.EXTBWMX.LT.X2M) THEN
          C_EX(1)= 0.D0
          I= 2
          DO WHILE(C.GT.C_EX(I))
             I= I+1
          ENDDO
          CB= (C-C_EX(I-1))/(C_EX(I)-C_EX(I-1))
          IF(I.EQ.2) THEN
             CALL ATG(SS,CB,X2MN,X_EX(I),RM2,RW,QIJ2,ANRMIJ,PRQIJ)
          ELSE IF(I.EQ.3) THEN
             CALL FLAT(SS,CB,X_EX(I-1),X2M,QIJ2,ANRMIJ,PRQIJ)
          ELSE 
             PRINT*,'SUCCESSO QUALCOSA DI STRANO NEGLI ESTREMI'
          ENDIF
          ANRMIJ= ANRMIJ/(C_EX(I)-C_EX(I-1))
         ELSE IF(EXTBWMN.GT.X2MN.AND.EXTBWMX.GT.X2M) THEN
          I= 1
          C_EX(2)= 1.D0
          DO WHILE(C.GT.C_EX(I))
             I= I+1
          ENDDO
          CB= (C-C_EX(I-1))/(C_EX(I)-C_EX(I-1))
          IF(I.EQ.1) THEN
             CALL FLAT(SS,CB,X_EX(I-1),X_EX(I),QIJ2,ANRMIJ,PRQIJ)
          ELSE IF(I.EQ.2) THEN
             CALL ATG(SS,CB,X_EX(I-1),X2M,RM2,RW,QIJ2,ANRMIJ,PRQIJ)
          ELSE
             PRINT*,'SUCCESSO QUALCOSA DI STRANO NEGLI ESTREMI'
          ENDIF
          ANRMIJ= ANRMIJ/(C_EX(I)-C_EX(I-1))
         ELSE
          PRINT*,'SUCCESSO QUALCOSA DI STRANO NEGLI ESTREMI'
         ENDIF
      ELSE IF(RM2.LE.X2MN) THEN
         C_EX(1)= 0.D0
         X_EX(1)= X_EX(0)
         XPDX= X2MN + DX
         IF(EXTBWMX.LT.X2M) THEN
            X_EX(2)= MAX(EXTBWMX,XPDX)
         ELSE
            X_EX(2)= XPDX
         ENDIF
         I= 2
         DO WHILE(C.GT.C_EX(I))
            I= I+1
         ENDDO
         CB= (C-C_EX(I-1))/(C_EX(I)-C_EX(I-1))
         IF(I.EQ.2) THEN
            CALL ATG(SS,CB,X_EX(I-1),X_EX(I),RM2,RW,QIJ2,ANRMIJ,PRQIJ)
         ELSE IF(I.EQ.3) THEN
            CALL FLAT(SS,CB,X_EX(I-1),X_EX(I),QIJ2,ANRMIJ,PRQIJ)
         ELSE 
            PRINT*,'SUCCESSO QUALCOSA DI STRANO NEGLI ESTREMI'
         ENDIF
         ANRMIJ= ANRMIJ/(C_EX(I)-C_EX(I-1))
      ELSE IF(RM2.GE.X2M) THEN
         X_EX(2)= X_EX(3)
         XMDX= X2M - DX
         IF(EXTBWMN.GT.X2MN) THEN
            X_EX(1)= MIN(EXTBWMN,XMDX)
         ELSE
            X_EX(1)= XMDX
         ENDIF
         I= 1
         C_EX(2)= 1.D0
         DO WHILE(C.GT.C_EX(I))
            I= I+1
         ENDDO
         CB= (C-C_EX(I-1))/(C_EX(I)-C_EX(I-1))
         IF(I.EQ.1) THEN
            CALL FLAT(SS,CB,X_EX(I-1),X_EX(I),QIJ2,ANRMIJ,PRQIJ)
         ELSE IF(I.EQ.2) THEN
            CALL ATG(SS,CB,X_EX(I-1),X_EX(I),RM2,RW,QIJ2,ANRMIJ,PRQIJ)
         ELSE
            PRINT*,'SUCCESSO QUALCOSA DI STRANO NEGLI ESTREMI'
         ENDIF
         ANRMIJ= ANRMIJ/(C_EX(I)-C_EX(I-1))

      ENDIF
*
      DO I = 1,2
         C_EX(I)= C_EXOUT(I)
      ENDDO
*
      RETURN
      END
*
      SUBROUTINE FLAT(SS,C,X2MN,X2M,QIJ2,ANRMIJ,PRQIJ)
      IMPLICIT REAL*8 (A-H,O-Z)
*
      X2MIN = X2MN
      X2MAX = X2M
*
      ANRMIJ = X2MAX-X2MIN
      XIJ = (X2MAX-X2MIN)*C + X2MIN
      PRQIJ = 1.D0
*
      QIJ2 = XIJ*SS
*
      RETURN
      END
*
      SUBROUTINE PHOT(SS,C,X2MN,X2M,QIJ2,ANRMIJ,PRQIJ)
      IMPLICIT REAL*8 (A-H,O-Z)
*
      X2MIN = X2MN
      X2MAX = X2M
*
      ANRMIJ = LOG(X2MAX/X2MIN)
      XIJ = X2MIN*EXP(C*ANRMIJ)
      PRQIJ = XIJ
*
      QIJ2 = XIJ*SS
*
      RETURN
      END
*
      SUBROUTINE ATG(SS,C,X2MN,X2M,RM2,RW,QIJ2,ANRMIJ,PRQIJ)
      IMPLICIT REAL*8 (A-H,O-Z)
*
      X2MIN = X2MN
      X2MAX = X2M
*
      XM2X = ATAN((X2MAX-RM2)/RW)
      XM2N = ATAN((X2MIN-RM2)/RW)
*
      ANRMIJ = (XM2X-XM2N)/RW
      XIJ = RM2 + RW*TAN(XM2X*C+XM2N*(1.D0-C))
      PRQIJ = (XIJ-RM2)*(XIJ-RM2) + RW*RW
*
      QIJ2 = XIJ*SS
*
      RETURN
      END
*
*-----FUNCTION DOP: D(X)/P(X)/ANORMD(XMIN,XMAX) WHERE D(X) IS
*     THE ELECTRON STRUCTURE FUNCTION
*
      FUNCTION DOP(X)
      IMPLICIT REAL*8 (A-H,O-Z)
      COMMON/EM/RL,ETA,BETA,SDELTA,BETAM
*
      BETAM = BETA/2.D0
*
      OMX = 1.D0 - X
      OPX = 1.D0 + X
*
      ALX = LOG(X)
*
      IF (OMX.LT.1D-28) THEN
         ALOMX = 0.D0
         ALOX = -1.D0
      ELSE
         ALOMX = LOG(OMX)
         ALOX = ALX/OMX
      ENDIF
*
      PM1 = 1.D0/BETAM*(1.D0 - X)**(1.D0 - BETAM)
      DFUNS = SDELTA
*
      ETA= BETA
*
      DFUNH = - ETA/4.D0*OPX
     #        + ETA**2/32.D0*(
     #        - 4.D0*OPX*ALOMX + 3.D0*OPX*ALX - 4.D0*ALOX
     #        - 5.D0 - X)
      DOP = DFUNS + DFUNH*PM1
*
      RETURN
      END     
*
*-----FUNCTION D: D(X) IS THE ELECTRON STRUCTURE FUNCTION
*
      FUNCTION D(X)
      IMPLICIT REAL*8 (A-H,O-Z)
      COMMON/EM/RL,ETA,BETA,SDELTA,BETAM
*
      BETAM = BETA/2.D0
*
      OMX = 1.D0 - X
      OPX = 1.D0 + X
*
      ALX = LOG(X)
*
      IF (OMX.LT.1D-28) THEN
         ALOMX = 0.D0
         ALOX = -1.D0
      ELSE
         ALOMX = LOG(OMX)
         ALOX = ALX/OMX
      ENDIF
*
c      PM1 = 1.D0/BETAM*(1.D0 - X)**(1.D0 - BETAM)
      DFUNS = SDELTA*BETAM*(1.D0 - X)**(-1.D0 + BETAM)
*
      ETA= BETA
*
      DFUNH = - ETA/4.D0*OPX
     #        + ETA**2/32.D0*(
     #        - 4.D0*OPX*ALOMX + 3.D0*OPX*ALX - 4.D0*ALOX
     #        - 5.D0 - X)
      D = DFUNS + DFUNH
*
      RETURN
      END     
*
      SUBROUTINE ENPHOT(SS,C,EMIN,EMAX,EG,ANEG,XG,ISF)
      IMPLICIT REAL*8 (A-H,O-Z)
      IF(ISF.EQ.1) THEN
         ALEMAOEMI= LOG(EMAX/EMIN)
         RSS= SQRT(SS)
         ANEG= RSS/2.D0*ALEMAOEMI
         EG= EMIN*EXP(ALEMAOEMI*C)
         XG= 2.D0*EG/RSS
      ELSE
         ANEG= EMAX-EMIN
         EG= ANEG*C+EMIN
         XG= 1.D0
      ENDIF
*
      RETURN
      END

      subroutine dnunug(nflv,q1,q2,q3,
     #                  SS,HP,HM,KP,KM,SP,TP,T,UP,U,ds4el)
      implicit real*8 (a-h,o-z)
      real*8 km, KM2, kp, KP2
*
      CHARACTER*1 NFLV,OANOM
      DIMENSION Q1(0:3), Q2(0:3), Q3(0:3)
      COMMON/CUTS/EGMINL,EGMAXL,CMINL,CMAXL
      COMMON/PAR/WM,WG,CFACT,GF,G,ZM,ZW,PI,ALPHA,EM2
      COMMON/PARD/ZM2,ZW2,WM2,WG2,GF2,G2,G4,G8
      COMMON/THETAW/STH2
      COMMON/AIN/ALPHAI
      COMMON/FM/EM,AMU,TLM,UQM,DQM,CQM,SQM,BQM,TQM
      COMMON/WEAKRHO/RHO
      COMMON/ANOM/OANOM
      COMMON/ANOMV/XG,YG
*
      st2 = sth2
      ame = sqrt(em2)
*
      zm2 = zm*zm
      zw2 = zw*zw
      ve = -0.5d0+2.d0*st2
      ae = -0.5d0

      gf = 8.2476227851D-6
*
      st = sqrt(st2)
      g4 = g2**2
      st4 = st2*st2
      st6 = st4*st2 
      ct2 = 1.d0-st2
      ct = sqrt(ct2)
      ctm1 = 1.d0/ct
      ct4 = ct2*ct2
      ctm2 = 1.d0/ct2
      ctm4 = 1.d0/ct4
      ve2 = ve*ve
      ae2 = ae*ae
      s= ss
      s2 = s*s
      s3 = s2*s
      ZW2R = ZW2
      ZWR = ZW
*
      spm2 = 1.d0/sp/sp

      hp2 = hp**2
      hm2 = hm**2
      hpm1 = 1.d0/hp
      hpm2 = hpm1/hp
      hmm1 = 1.d0/hm
      hmm2 = hmm1/hm
      KM2 = KM**2
      KP2 = KP**2

      s2 = s*s
      tp2 = tp*tp
      t2 = t*t
      up2 = up*up
      u2 = u*u
      wm2 = wm*wm

      rho = 1.

      dpropz = (sp-zm2)**2+zm2*zw2R
      rpropz = (sp-zm2)/dpropz
      rpropz = -rpropz
      rpropz = rpropz*rho
      aipropz = - zm*zwR/dpropz
      aipropz = - aipropz
      aipropz = aipropz*rho
      propz2 = rpropz*rpropz+aipropz*aipropz
      propw = 1.d0/(t-wm2)
      propw = -propw
      rpropw = propw
      aipropw = 0.d0
      propwp = 1.d0/(tp-wm2)
      propwp = -propwp
      rpropwp = propwp
      aipropwp = 0.d0
      propw2 = propw**2
      propwp2 = propwp**2
*
      epppmqmk = -ss/2.d0*(-q1(1)*q3(2)+q1(2)*q3(1))

      epppmqpk = -epppmqmk
      epppmqpqm = epppmqmk
      epmqpqmk = -epppmqmk
      eppqpqmk = epppmqmk
*
      if(ct2.eq.0.d0.or.hm.eq.0.d0.or.hp.eq.0.d0) then
         print*,'ct2 = ',ct2
         print*,'hm = ',hm
         print*,'hp = ',hp
      endif

      red1 = g*g2/8.d0*st/ct2/hm*rpropz      
      aid1 = g*g2/8.d0*st/ct2/hm*aipropz
*
      denppp = sqrt(-((-Hp)*(-Hm)*(-s)*(u)*(up))/2.d0)/4.d0
      denppm = 0.d0
      denpmp = sqrt(-((-Hp)*(-Hm)*(-s)*(t)*(tp))/2.d0)/4.d0
      denpmm = 0.d0
      denmmm = 0.d0
      denmmp = denpmp
      denmpm = 0.d0
      denmpp = denppp
*
      if(denppp.eq.0.d0) then
         print*,'denppp = ',denppp
      endif
      ro1ppp = -(ve+ae)/4.d0/denppp*( - 2.d0*s*u*up*Hm)
      ai1ppp = 0.d0
      if(denpmp.eq.0.d0) then
         print*,'denpmp = ',denpmp
      endif
      ro1pmp = -(ve-ae)/2.d0/denpmp*(- s*t*tp*Hm + 2.d0*s*t*tp*Hm
     #                              + s*t*Hm*km + t*u*Hm*Hm
     #                              - t*tp*Hm*Hp)
      ai1pmp = -(ve-ae)/2.d0/denpmp*( + 4.d0*epppmqmk*t*Hm)
      if(denmmp.eq.0.d0) then
         print*,'denmmp = ',denmmp
      endif
      ro1mmp = (ve-ae)*(-s/2.d0)/2.d0/denmmp*( 2.d0*t*tp*Hm)
      ai1mmp = 0.d0
      if(denppp.eq.0.d0) then
         print*,'denmpp = ',denmpp
      endif
      ro1mpp = -(ve+ae)/4.d0/(-s/2.d0)/denmpp*
     #  (- s2*u*up*Hm + s*t*u*Hm2 - s*u*up*Hm*Hp + 2.d0*s2*u*up*Hm
     #   + s2*u*Hm*Kp)
      ai1mpp = -(ve+ae)/4.d0/(-s/2.d0)/denmpp*( - 4.d0*epppmqpk*s*u*Hm)
*
      redia1ppp = red1*ro1ppp - aid1*ai1ppp
      aidia1ppp = red1*ai1ppp + aid1*ro1ppp
      redia1pmp = red1*ro1pmp - aid1*ai1pmp
      aidia1pmp = red1*ai1pmp + aid1*ro1pmp
      redia1mmp = red1*ro1mmp - aid1*ai1mmp
      aidia1mmp = red1*ai1mmp + aid1*ro1mmp
      redia1mpp = red1*ro1mpp - aid1*ai1mpp
      aidia1mpp = red1*ai1mpp + aid1*ro1mpp
*
      red2 = -g*g2/8.d0*st/ct2/hp*rpropz
      aid2 = -g*g2/8.d0*st/ct2/hp*aipropz
*
      ro2ppp = (ve+ae)/4.d0/denppp/(-s/2.d0)
     #        *(- s2*u*up*Hp - s*u*up*Hm*Hp + s*tp*up*Hp2
     #          + 2.d0*s2*u*up*Hp + s2*up*Hp*Km)
      ai2ppp = (ve+ae)/4.d0/denppp/(-s/2.d0)
     #        *(- 4.d0*epppmqmk*s*up*Hp)
      ro2pmp = -(ve-ae)/2.d0/denpmp*(-s*t*tp*Hp)
      ai2pmp = 0.d0
      ro2mmp = (ve-ae)/2.d0/denmmp
     #         *( - s*t*tp*Hp + 2.d0*s*t*tp*Hp + s*tp*Hp*Kp
     #            - t*tp*Hm*Hp + tp*up*Hp2)
      ai2mmp = (ve-ae)/2.d0/denmmp
     #         *( + 4.d0*epppmqpk*tp*Hp)
      ro2mpp = -(ve+ae)/4.d0/(-s/2.d0)/denmpp*(-s2*u*up*Hp)
      ai2mpp = 0.d0
*
      redia2ppp = red2*ro2ppp - aid2*ai2ppp
      aidia2ppp = red2*ai2ppp + aid2*ro2ppp
      redia2pmp = red2*ro2pmp - aid2*ai2pmp
      aidia2pmp = red2*ai2pmp + aid2*ro2pmp
      redia2mmp = red2*ro2mmp - aid2*ai2mmp
      aidia2mmp = red2*ai2mmp + aid2*ro2mmp
      redia2mpp = red2*ro2mpp - aid2*ai2mpp
      aidia2mpp = red2*ai2mpp + aid2*ro2mpp
*
      red3 = -g*g2/8.d0*st/hm*rpropw
      aid3 = -g*g2/8.d0*st/hm*aipropw
*
      ro3ppp = hm/2.d0/denppp*(- 2.d0*s*u*up)
      ai3ppp = 0.d0
      ro3pmp = 0.d0
      ai3pmp = 0.d0
      ro3mmp = 0.d0
      ai3mmp = 0.d0
      ro3mpp = 1.d0/denmpp*Hm*(-t*u*Hm+u*up*Hp-s*u*up-s*u*Kp)
      ai3mpp =  2.d0/denmpp*Hm*(-epppmqpqm*Hp+epppmqpk*u
     #                          +epppmqmk*t+eppqpqmk*s)
*
      redia3ppp = red3*ro3ppp - aid3*ai3ppp
      aidia3ppp = red3*ai3ppp + aid3*ro3ppp
      redia3pmp = red3*ro3pmp - aid3*ai3pmp
      aidia3pmp = red3*ai3pmp + aid3*ro3pmp
      redia3mmp = red3*ro3mmp - aid3*ai3mmp
      aidia3mmp = red3*ai3mmp + aid3*ro3mmp
      redia3mpp = red3*ro3mpp - aid3*ai3mpp
      aidia3mpp = red3*ai3mpp + aid3*ro3mpp
*
      red4 = g*g2/8.d0*st/hp*rpropwp
      aid4 = g*g2/8.d0*st/hp*aipropwp
*
      ro4ppp = -1.d0/denppp*Hp*(u*up*Hm-tp*up*Hp-s*u*up-s*up*Km)
      ai4ppp = -2.d0/denppp*Hp*(+epppmqpqm*Hm+epppmqpk*tp
     #                          +epppmqmk*up+epmqpqmk*s)
      ro4pmp = 0.d0
      ai4pmp = 0.d0
      ro4mmp = 0.d0
      ai4mmp = 0.d0
      ro4mpp = 1.d0/denmpp*(s*u*up*Hp)
      ai4mpp = 0.d0
*
      redia4ppp = red4*ro4ppp - aid4*ai4ppp
      aidia4ppp = red4*ai4ppp + aid4*ro4ppp
      redia4pmp = red4*ro4pmp - aid4*ai4pmp
      aidia4pmp = red4*ai4pmp + aid4*ro4pmp
      redia4mmp = red4*ro4mmp - aid4*ai4mmp
      aidia4mmp = red4*ai4mmp + aid4*ro4mmp
      redia4mpp = red4*ro4mpp - aid4*ai4mpp
      aidia4mpp = red4*ai4mpp + aid4*ro4mpp
*
      red5 = g*g2/8.d0*st*(rpropw*rpropwp-aipropw*aipropwp)
      aid5 = g*g2/8.d0*st*(rpropw*aipropwp+aipropw*rpropwp)
*
      ro5ppp = -1.d0/denppp
     #       *( 0.5D0*t*u*up*Hm - 0.5d0*t*tp*up*Hp + 0.5d0*u*tp*up*Hp
     #        + 0.5d0*u*up*Hm*Hp - 0.5d0*u2*up*Hm - 0.5d0*tp*up*Hp2
     #        + 0.25d0*s*t*u*Hm - 0.25d0*s*t*up*Km + 0.25d0*s*u*sp*Hm
     #        + 0.25d0*s*u*tp*Kp - 0.25d0*s*u*up*Hm + 0.25d0*s*u*up*Hp
     #        - 0.25d0*s*u*up*Km + 0.25d0*s*u*up*Kp + 0.25d0*s*sp*up*Hp
     #        - 0.25d0*s*tp*up*Hp - 0.5d0*s*up*Hp*Km
     #        + 0.25d0*s2*u*Kp - 0.25d0*s2*up*Km )
      ai5ppp = -1.d0/denppp
     #       *( 0.5d0*epppmqpqm*t*Hm - 0.5d0*epppmqpqm*u*Hm
     #        + 0.5d0*epppmqpqm*tp*Hp + 1.5d0*epppmqpqm*up*Hp
     #        + 0.5d0*epppmqpqm*s*Km + 0.5d0*epppmqpqm*s*Kp
     #        + 0.5d0*epppmqpk*t*tp + 1.5d0*epppmqpk*u*up
     #        - epppmqpk*s*u - 0.5d0*epppmqpk*s*sp
     #        - 0.5d0*epppmqmk*t*tp - 1.5d0*epppmqmk*u*up
     #        + 2.d0*epppmqmk*up*Hp + 0.5d0*epppmqmk*s*sp
     #        + epppmqmk*s*up )
      ro5pmp = 0.d0
      ai5pmp = 0.d0
      ro5mmp = 0.d0
      ai5mmp = 0.d0
      ro5mpp = -1.d0/denmpp
     #       *(- 0.5d0*t*u*tp*Hm + 0.5d0*t*u*up*Hm - 0.5d0*t*u*Hm2
     #         + 0.5d0*u*tp*up*Hp + 0.5d0*u*up*Hm*Hp - 0.5d0*u*up2*Hp
     #         - 0.25d0*s*t*u*Hm + 0.25d0*s*t*up*Km + 0.25d0*s*u*sp*Hm
     #         - 0.25d0*s*u*tp*Kp + 0.25d0*s*u*up*Hm - 0.25d0*s*u*up*Hp
     #         + 0.25d0*s*u*up*Km - 0.25d0*s*u*up*Kp - 0.5d0*s*u*Hm*Kp
     #         + 0.25d0*s*sp*up*Hp + 0.25d0*s*tp*up*Hp
     #         - 0.25d0*s2*u*Kp + 0.25d0*s2*up*Km )
      ai5mpp = -1.d0/denmpp
     #       *(- 0.5d0*epppmqpqm*t*Hm - 1.5d0*epppmqpqm*u*Hm
     #         - 0.5d0*epppmqpqm*tp*Hp + 0.5d0*epppmqpqm*up*Hp
     #         - 0.5d0*epppmqpqm*s*Km - 0.5d0*epppmqpqm*s*Kp
     #         - 0.5d0*epppmqpk*t*tp - 1.5d0*epppmqpk*u*up
     #         + 2.d0*epppmqpk*u*Hm + epppmqpk*s*u
     #         + 0.5d0*epppmqpk*s*sp + 0.5d0*epppmqmk*t*tp
     #         + 1.5d0*epppmqmk*u*up - 0.5d0*epppmqmk*s*sp
     #         - epppmqmk*s*up)
*
      IF(OANOM.EQ.'Y') THEN
         xg0 = -xg
         yg0 = -yg
         red6 = xg0*g*g2/8.d0*st*(rpropw*rpropwp-aipropw*aipropwp)
         aid6 = xg0*g*g2/8.d0*st*(rpropw*aipropwp+aipropw*rpropwp)
*
         ro6ppp = -1.d0/denppp
     #       *( - 0.5d0*u*up*Hm*Hp + 0.5d0*tp*up*Hp2
     #          + 0.5d0*s*up*Hp*Km )
         ai6ppp = -1.d0/denppp *( - 2.d0*epppmqmk*up*Hp )
         ro6pmp = 0.d0
         ai6pmp = 0.d0
         ro6mmp = 0.d0
         ai6mmp = 0.d0
         ro6mpp = -1.d0/denmpp
     #       *( 0.5d0*t*u*Hm2 - 0.5d0*u*up*Hm*Hp
     #        + 0.5d0*s*u*Hm*Kp)
         ai6mpp = -1.d0/denmpp*(-2.d0*epppmqpk*u*Hm )
*
         red7 = yg0/wm2*g2/8.d0*g*st*(rpropw*rpropwp-aipropw*aipropwp)
         aid7 = yg0/wm2*g2/8.d0*g*st*(rpropw*aipropwp+aipropw*rpropwp)
*
         ro7ppp = -1.d0/denppp
     #       *( - 0.5d0*u*tp*up*Hp2 + 0.5d0*u2*up*Hm*Hp
     #         - 0.5d0*s*u*sp*Hm*Hp - 0.5d0*s*u*tp*Hp*Kp)
         ai7ppp = -1.d0/denppp 
     #       *( + 0.5d0*epppmqpqm*t*Hm*Km 
     #          + 0.5d0*epppmqpqm*u*Hm*Hp
     #          - 0.5d0*epppmqpqm*tp*Hp2
     #          - epppmqpqm*up*Hm*Hp
     #          + 0.5d0*epppmqpqm*up*Hp*Km
     #          - 0.5d0*epppmqpqm*s*Hp*Km
     #          + 0.5d0*epppmqpqm*s*Km*Kp
     #          + 0.5d0*epppmqpk*t*tp*Km
     #          + 0.5d0*epppmqpk*u*tp*Hp
     #          - 0.5d0*epppmqpk*u*up*Hm
     #          + 0.5d0*epppmqpk*u*up*Km
     #          - 0.5d0*epppmqpk*u2*Hm 
     #          - 0.5d0*epppmqpk*tp*up*Hp
     #          - 0.5d0*epppmqpk*s*u*Km
     #          - 0.5d0*epppmqpk*s*sp*Km
     #          - 0.5d0*epppmqpk*s*up*Km
     #          + 0.5d0*epppmqmk*t*u*Hm
     #          + 0.5d0*epppmqmk*t*tp*Hp
     #          + 0.5d0*epppmqmk*t*up*Hm
     #          - epppmqmk*t*up*Km
     #          + epppmqmk*u*up*Hp
     #          + 0.5d0*epppmqmk*up2*Hp
     #          + 0.5d0*epppmqmk*s*u*Kp
     #          - 0.5d0*epppmqmk*s*sp*Hp
     #          + 0.5d0*epppmqmk*s*up*Kp)
         ro7pmp = 0.d0
         ai7pmp = 0.d0
         ro7mmp = 0.d0
         ai7mmp = 0.d0
         ro7mpp = -1.d0/denmpp
     #       *( - 0.5d0*t*u*up*Hm2 + 0.5d0*u*up2*Hm*Hp
     #          - 0.5d0*s*t*up*Hm*Km - 0.5d0*s*sp*up*Hm*Hp)
         ai7mpp = -1.d0/denmpp*(
     #  + 0.5d0*epppmqpqm*t*Hm2 + epppmqpqm*u*Hm*Hp
     #  - 0.5d0*epppmqpqm*u*Hm*Kp
     #  - 0.5d0*epppmqpqm*tp*Hp*Kp
     #  - 0.5d0*epppmqpqm*up*Hm*Hp
     #  + 0.5d0*epppmqpqm*s*Hm*Kp
     #  - 0.5d0*epppmqpqm*s*Km*Kp
     #  + 0.5d0*epppmqpk*t*tp*Hm
     #  - 0.5d0*epppmqpk*t*tp*Km
     #  + 0.5d0*epppmqpk*u*sp*Hm
     #  + 0.5d0*epppmqpk*u*tp*Hp
     #  + epppmqpk*u*up*Hm
     #  - 0.5d0*epppmqpk*u*up*Km
     #  + 0.5d0*epppmqpk*u2*Hm
     #  + 0.5d0*epppmqpk*sp*tp*Hp 
     #  + 0.5d0*epppmqpk*tp*up*Hp 
     #  + 0.5d0*epppmqpk*s*u*Km
     #  - 0.5d0*epppmqpk*s*sp*Hm 
     #  + 0.5d0*epppmqpk*s*sp*Km
     #  + 0.5d0*epppmqpk*s*up*Km 
     #  + 0.5d0*epppmqpk*t*u*tp*Hm/s
     #  - 0.5d0*epppmqpk*t/s*tp2*Hp
     #  + 0.5d0*epppmqpk*u/s*tp*up*Hp
     #  - 0.5d0*epppmqpk*u2/s*up*Hm 
     #  - 0.5d0*epppmqmk*t*u*Hm 
     #  + 0.5d0*epppmqmk*t*sp*Hm 
     #  + 0.5d0*epppmqmk*t*up*Hm 
     #  + epppmqmk*t*up*Km 
     #  - 0.5d0*epppmqmk*u*up*Hp 
     #  + 0.5d0*epppmqmk*sp*up*Hp 
     #  - 0.5d0*epppmqmk*up2*Hp 
     #  - 0.5d0*epppmqmk*s*u*Kp 
     #  - 0.5d0*epppmqmk*s*up*Kp 
     #  + 0.5d0*epppmqmk*t/s*u*up*Hm 
     #  + 0.5d0*epppmqmk*t/s*tp*up*Hp 
     #  - 0.5d0*epppmqmk*t2/s*tp*Hm 
     #  - 0.5d0*epppmqmk*u/s*up2*Hp)
*
      ELSE
         red6 = 0.d0
         aid6 = 0.d0
         red7 = 0.d0
         aid7 = 0.d0 
         ro6ppp = 0.d0
         ai6ppp = 0.d0
         ro6pmp = 0.d0
         ai6pmp = 0.d0
         ro6mmp = 0.d0
         ai6mmp = 0.d0
         ro6mpp = 0.d0
         ai6mpp = 0.d0
         ro7ppp = 0.d0
         ai7ppp = 0.d0
         ro7pmp = 0.d0
         ai7pmp = 0.d0
         ro7mmp = 0.d0
         ai7mmp = 0.d0
         ro7mpp = 0.d0
         ai7mpp = 0.d0
      ENDIF
*
      redia5ppp = red5*ro5ppp - aid5*ai5ppp
      aidia5ppp = red5*ai5ppp + aid5*ro5ppp
      redia5pmp = red5*ro5pmp - aid5*ai5pmp
      aidia5pmp = red5*ai5pmp + aid5*ro5pmp
      redia5mmp = red5*ro5mmp - aid5*ai5mmp
      aidia5mmp = red5*ai5mmp + aid5*ro5mmp
      redia5mpp = red5*ro5mpp - aid5*ai5mpp
      aidia5mpp = red5*ai5mpp + aid5*ro5mpp    
*
      redia6ppp = red6*ro6ppp - aid6*ai6ppp
      aidia6ppp = red6*ai6ppp + aid6*ro6ppp
      redia6pmp = red6*ro6pmp - aid6*ai6pmp
      aidia6pmp = red6*ai6pmp + aid6*ro6pmp
      redia6mmp = red6*ro6mmp - aid6*ai6mmp
      aidia6mmp = red6*ai6mmp + aid6*ro6mmp
      redia6mpp = red6*ro6mpp - aid6*ai6mpp
      aidia6mpp = red6*ai6mpp + aid6*ro6mpp    
*
      redia7ppp = red7*ro7ppp - aid7*ai7ppp
      aidia7ppp = red7*ai7ppp + aid7*ro7ppp
      redia7pmp = red7*ro7pmp - aid7*ai7pmp
      aidia7pmp = red7*ai7pmp + aid7*ro7pmp
      redia7mmp = red7*ro7mmp - aid7*ai7mmp
      aidia7mmp = red7*ai7mmp + aid7*ro7mmp
      redia7mpp = red7*ro7mpp - aid7*ai7mpp
      aidia7mpp = red7*ai7mpp + aid7*ro7mpp
*
      redia5ppp = redia5ppp + redia6ppp + redia7ppp 
      aidia5ppp = aidia5ppp + aidia6ppp + aidia7ppp 
      redia5pmp = redia5pmp + redia6pmp + redia7pmp 
      aidia5pmp = aidia5pmp + aidia6pmp + aidia7pmp
      redia5mmp = redia5mmp + redia6mmp + redia7mmp
      aidia5mmp = aidia5mmp + aidia6mmp + aidia7mmp
      redia5mpp = redia5mpp + redia6mpp + redia7mpp
      aidia5mpp = aidia5mpp + aidia6mpp + aidia7mpp  
*
*-----s+t
*
      rediappp = redia1ppp+redia2ppp+redia3ppp+redia4ppp+redia5ppp
      aidiappp = aidia1ppp+aidia2ppp+aidia3ppp+aidia4ppp+aidia5ppp
      rediapmp = redia1pmp+redia2pmp+redia3pmp+redia4pmp+redia5pmp
      aidiapmp = aidia1pmp+aidia2pmp+aidia3pmp+aidia4pmp+aidia5pmp
      rediammp = redia1mmp+redia2mmp+redia3mmp+redia4mmp+redia5mmp
      aidiammp = aidia1mmp+aidia2mmp+aidia3mmp+aidia4mmp+aidia5mmp
      rediampp = redia1mpp+redia2mpp+redia3mpp+redia4mpp+redia5mpp
      aidiampp = aidia1mpp+aidia2mpp+aidia3mpp+aidia4mpp+aidia5mpp 
*
*-----s
*
      rediasppp = redia1ppp+redia2ppp
      aidiasppp = aidia1ppp+aidia2ppp
      rediaspmp = redia1pmp+redia2pmp
      aidiaspmp = aidia1pmp+aidia2pmp
      rediasmmp = redia1mmp+redia2mmp
      aidiasmmp = aidia1mmp+aidia2mmp
      rediasmpp = redia1mpp+redia2mpp
      aidiasmpp = aidia1mpp+aidia2mpp  
*
      redias2 = rediasppp*rediasppp+
     #          rediaspmp*rediaspmp+
     #          rediasmmp*rediasmmp+
     #          rediasmpp*rediasmpp
      aidias2 = aidiasppp*aidiasppp+
     #          aidiaspmp*aidiaspmp+
     #          aidiasmmp*aidiasmmp+
     #          aidiasmpp*aidiasmpp
*
*-----s+t
*
      redia2 = rediappp*rediappp+
     #         rediapmp*rediapmp+
     #         rediammp*rediammp+
     #         rediampp*rediampp
      aidia2 = aidiappp*aidiappp+
     #         aidiapmp*aidiapmp+
     #         aidiammp*aidiammp+
     #         aidiampp*aidiampp
*
*----- squared matrix element
*----- /4.d0 means average over initial state spins
*
*-----soft+virtual O(alpha) constants for Z contribution
*
      api= alpha/pi
      spvoa= 1.d0
c +api*(pi*pi/3.d0-0.5d0)
*
      if(NFLV.EQ.'M'.OR.NFLV.EQ.'T') THEN
         anunug = (redias2+aidias2)*spvoa/4.d0
      else if(NFLV.EQ.'E') THEN
         anunug = (redia2+aidia2)/4.d0
      else if(NFLV.EQ.'F') THEN
         anunug = (2.d0*(redias2+aidias2)*spvoa+redia2+aidia2)/4.d0
      endif
*
      scfact = 4.d0*pi*alpha/g/g/st/st
*
      ds4el = anunug*scfact

      return
      end
*
      subroutine dnunugm(nflv,q1,q2,q3,
     #                   SS,HP,HM,KP,KM,SP,TP,T,UP,U,ds4el)
      implicit real*8 (a-h,o-z)
      real*8 km, KM2, kp, KP2
      real*8 mnu,mnu2,mnu4
      CHARACTER*1 NFLV,OANOM
      DIMENSION Q1(0:3), Q2(0:3), Q3(0:3)
      COMMON/CUTS/EGMINL,EGMAXL,CMINL,CMAXL
      COMMON/PAR/WM,WG,CFACT,GF,G,ZM,ZW,PI,ALPHA,EM2
      COMMON/PARD/ZM2,ZW2,WM2,WG2,GF2,G2,G4,G8
      COMMON/THETAW/STH2
      COMMON/AIN/ALPHAI
      COMMON/FM/EM,AMU,TLM,UQM,DQM,CQM,SQM,BQM,TQM
      COMMON/WEAKRHO/RHO
      COMMON/ANOM/OANOM
      COMMON/ANOMV/XG,YG
      COMMON/NUMASS/MNU,MNU2
*
      st2 = sth2
      ame = sqrt(em2)
*
      zm2 = zm*zm
      zw2 = zw*zw
      ve = -0.5d0+2.d0*st2
      ae = -0.5d0

      gf = 8.2476227851D-6
*
      st = sqrt(st2)
      g4 = g2**2
      st4 = st2*st2
      st6 = st4*st2 
      ct2 = 1.d0-st2
      ct = sqrt(ct2)
      ctm1 = 1.d0/ct
      ct4 = ct2*ct2
      ctm2 = 1.d0/ct2
      ctm4 = 1.d0/ct4
      ve2 = ve*ve
      ae2 = ae*ae
      s= ss
      s2 = s*s
      s3 = s2*s
      ZW2R = ZW2
      ZWR = ZW
*
      spm2 = 1.d0/sp/sp

      hp2 = hp**2
      hm2 = hm**2
      hpm1 = 1.d0/hp
      hpm2 = hpm1/hp
      hmm1 = 1.d0/hm
      hmm2 = hmm1/hm
      KM2 = KM**2
      KP2 = KP**2

      s2 = s*s
      tp2 = tp*tp
      t2 = t*t
      up2 = up*up
      u2 = u*u
      wm2 = wm*wm

      dpropz = (sp-zm2)**2+zm2*zw2R
      rpropz = (sp-zm2)/dpropz
      rpropz = -rpropz
      rpropz = rpropz*rho
      aipropz = - zm*zwR/dpropz
      aipropz = - aipropz
      aipropz = aipropz*rho
      propz2 = rpropz*rpropz+aipropz*aipropz
      propw = 1.d0/(t-wm2)
      propw = -propw
      rpropw = propw
      aipropw = 0.d0
      propwp = 1.d0/(tp-wm2)
      propwp = -propwp
      rpropwp = propwp
      aipropwp = 0.d0
      propw2 = propw**2
      propwp2 = propwp**2
*
*----- squared matrix element
*----- /4.d0 means average over initial state spins
*
*-----soft+virtual O(alpha) constants for Z contribution
*
      api= alpha/pi
      spvoa= 1.d0+api*(pi*pi/3.d0-0.5d0)
*
      scfact = 4.d0*pi*alpha/g/g/st/st
*
      mnu4= mnu2*mnu2
*      
      comfact= g4*g2/64.d0*st2*ctm4/4.d0*propz2
*
*-----electron radiation
*
      anunug1 = (ve+ae)**2*(-u*kp + mnu2*(kp+u)-mnu4)
     #            + (ve-ae)**2*(-t*km + mnu2*(km+t)-mnu4)
      anunug1 = 32.d0*anunug1/hm
*
*-----positron radiation
*
      anunug2 = (ve+ae)**2*(-up*km + mnu2*(km+up)-mnu4)
     #            + (ve-ae)**2*(-tp*kp + mnu2*(kp+tp)-mnu4)
      anunug2 = 32.d0*anunug2/hp
*
*-----interference
*
      vemae2 = (ve - ae)**2
      vepae2 = (ve + ae)**2
      aint = 32.d0*vemae2*(2.d0*s*t*tp+s*t*km+s*tp*kp
     #                     -t*tp*hm-t*tp*hp)
     #      +32.d0*vepae2*(2.d0*s*u*up+s*u*kp+s*up*km
     #                     -u*up*hm-u*up*hp)
     #      +64.d0*(ve2+ae2)*(t*u*hm+tp*up*hp)
     #      +mnu2*(32.d0*vemae2*(-3.d0*s*t-3.d0*s*tp+t*hp
     #                           -u*hm+tp*hm-up*hp)
     #             +32.d0*vepae2*(-3.d0*s*u-3.d0*s*up-t*hm
     #                            +u*hp-tp*hp+up*hm)
     #             -64.d0*(ve2+ae2)*(s*km+s*kp))
     #             +256.d0*(ve2+ae2)*mnu4*s
*     
      aint = aint/hp/hm
      anunug = (anunug1+anunug2+aint)*spvoa*comfact
*
      ds4el = anunug*scfact
*
      return
      end
*
*-----KINEH
*
      SUBROUTINE KINEH(SS,CTH,EG,CTHG,PHIG,PPDQM,PMDQM,QMDK,PPDPM,
     #                 PPDK,PMDK,QPDK,S,T,U,SP,TP,UP,
     #                 EM,TBIG)
      IMPLICIT REAL*8 (A-H,O-Z)
*
      COMMON/PAR/WM,WG,CFACT,GF,G,ZM,ZW,PI,ALPHA,EM2
      COMMON/THETAW/STH2
*
      st2 = sth2
      ame= sqrt(em2)
*
      EB = SQRT(SS)/2.D0
      EB2 = EB**2
      CPHIG = COS(PHIG)
      STH = SQRT(1.D0-CTH*CTH)
      STHG = SQRT(1.D0-CTHG*CTHG)
      SPHIG = SIN(PHIG)
*
      TBIG = STH*STHG*CPHIG + CTH*CTHG
      BE = 1.D0
      BEM = 1.D0
*
*-----PHOTON AND POSITRON ENERGY
*
      Em = 2.D0*EB*(EB - Eg)
      Em = Em/(2.D0*EB - Eg*(1.D0 - TBIG))
*
*-----DOT PRODUCTS NEEDED FOR INVARIANTS
*
      PPDQM = -EB*EM*(1.D0+BE*BEM*CTH)
      PMDQM = -EB*EM*(1.D0-BE*BEM*CTH)
      QMDK = -EG*EM*(1.D0-BEM*TBIG)
      PPDPM = -2.D0*EB2
      PPDK = -EG*EB*(1.D0+BE*CTHG)
      PMDK = -EG*EB*(1.D0-BE*CTHG)
      QPDK = PPDK + PMDK - QMDK
*
*-----INVARIANTS
*
      S = - 2.D0*PPDPM
      SP = -2.D0*(PPDQM+PMDQM-QMDK)
      T = -2.D0*(-PPDPM+PPDQM+PPDK)
      TP = 2.D0*PMDQM
      U = 2.D0*PPDQM
      UP = -2.D0*(-PPDPM+PMDQM+PMDK)
*
      return
      END
*
      SUBROUTINE KINE3(iin,X1,X2,SHAT,CMCTHG3,CM125,CM12,CMG3,CMG4,
     #                 CMPHIG34,CMCTH5S,CMPHI5S,CMCTHS,CMPHIS,CMPHIG3,
     #                 ancthg3,pm1cthg3,ANRM125,PRQ125,ANRM12,PRQ12,
     #                 RZM2HAT,RZWHAT,F125,F12,ANEG3,XG3,ANEG4,XG4,
     #                 anphig34,ancth5s,anphi5s,
     #                 ancths,anphis,anphig3,
     #                 PP,PM,Q1,Q2,Q3,Q4,Q5,
     #                 Q1L,Q2L,Q3L,Q4L,Q5L,IKINEI)
      IMPLICIT REAL*8 (A-H,O-Z)
*
      DIMENSION Q125(0:3),Q12(0:3),Q12S(0:3),
     #          Q1S(0:3),Q2S(0:3),Q4S(0:3),Q5S(0:3),
     #          Q1F(0:3),Q2F(0:3),Q3F(0:3),Q4F(0:3),Q5F(0:3),
     #          PP(0:3),PM(0:3),Q1(0:3),Q2(0:3),Q3(0:3),Q4(0:3),Q5(0:3),
     #          Q1L(0:3),Q2L(0:3),Q3L(0:3),Q4L(0:3),Q5L(0:3),PTOTL(0:3)
      COMMON/CMENERGY/RS,S
      COMMON/EMC/IQED
      COMMON/CUTS/EGMINL,EGMAXL,CMINL,CMAXL
      COMMON/PAR/WM,WG,CFACT,GF,G,ZM,ZW,PI,ALPHA,EM2
      COMMON/RPAR/RWM2,RWG2,RZM2,RZW2,RW,RZW,RW2
*
    
      IKINEI = 0
      IF(IQED.EQ.1) THEN
         XM = X1 - X2
         XP = X1 + X2
*
         BLOR = XM/XP
         GLOR = XP/2.D0/SQRT(X1*X2)
*
*.....MIN AND MAX FOR THE PHOTON ANGLE IN C.M. FRAME
*
         CMAX = (CMAXL - BLOR)/(1.D0-BLOR*CMAXL)
         CMIN = (CMINL - BLOR)/(1.D0-BLOR*CMINL)
*
*-----CTHG3 GENERATION
*
*-----sampling according to 1/(1-b^2 cthg^2) con b = 1
*
         arglog = ((1.d0+cmax)/(1.d0-cmax))*((1.d0-cmin)/(1.d0+cmin))
         ancthg3 = 0.5d0*log(arglog)
         rcmax = (1.d0+cmax)/(1.d0-cmax)
         rcmin = (1.d0-cmin)/(1.d0+cmin)
         cum = CMCTHG3
         cumm1 = cum - 1.d0
         cthg3 = (rcmax**cum*rcmin**cumm1-1.d0)
     #         /(rcmax**cum*rcmin**cumm1+1.d0)
         pm1cthg3 = ancthg3*(1.d0-cthg3)*(1.d0+cthg3) 
*
         sthg3 = sqrt(1.d0-cthg3*cthg3)
*
*.....MIN AND MAX FOR THE PHOTON ENERGY IN C.M. FRAME
*
         OPBC = 1.D0 + BLOR*CTHG3
         EGMAX0 = SQRT(SHAT)/2.D0
         EGMIN = EGMINL/GLOR/OPBC
         EGMAX = DMIN1(EGMAXL/GLOR/OPBC,EGMAX0)
         EBSTAR = SQRT(SHAT)/2.D0
      ELSE
         CMIN = CMINL
         CMAX = CMAXL
*
*-----CTHG3 GENERATION
*
*-----sampling according to 1/(1-b^2 cthg^2) con b = 1
*
         arglog = ((1.d0+cmax)/(1.d0-cmax))*((1.d0-cmin)/(1.d0+cmin))
         ancthg3 = 0.5d0*log(arglog)
         rcmax = (1.d0+cmax)/(1.d0-cmax)
         rcmin = (1.d0-cmin)/(1.d0+cmin)
         cum = CMCTHG3
         cumm1 = cum - 1.d0
         cthg3 = (rcmax**cum*rcmin**cumm1-1.d0)
     #         /(rcmax**cum*rcmin**cumm1+1.d0)
         pm1cthg3 = ancthg3*(1.d0-cthg3)*(1.d0+cthg3) 
*
         sthg3 = sqrt(1.d0-cthg3*cthg3)
         EGMIN = EGMINL
         EGMAX = EGMAXL
      ENDIF
*
      RSHAT = SQRT(SHAT)
*
*-----INVARIANT MASS GENERATION FOR THE Z+GAMMA SYSTEM
*
      X125MIN= 0.D0 
      X125MAX= 1.D0
      IF(X125MAX.LT.X125MIN) THEN
         IKINEI = IKINEI + 1
         RETURN
      ENDIF 
      ISI= 0
      CALL INVMBW(SHAT,CM125,X125MIN,X125MAX,RZM2HAT,RZWHAT,
     #            Q1252,ANRM125,PRQ125,ISI) 
*
*-----INVARIANT MASS GENERATION FOR THE Z
*
      Q122MIN= 0.D0
      Q122MAX= Q1252
      X12MIN= Q122MIN/SHAT
      X12MAX= Q122MAX/SHAT
      IF(X12MAX.LT.X12MIN) THEN
         IKINEI = IKINEI + 1
         RETURN
      ENDIF 
      ISI= 1
*
      CALL INVMFBWF(SHAT,CM12,X12MIN,X12MAX,RZM2HAT,RZWHAT,
     #              Q122,ANRM12,PRQ12,ISI)   
*
*-----EG3 GENERATION
*
      EG3MIN1= EGMIN
      EG3MIN2= EGMIN
      EG3MIN= DMAX1(EG3MIN1,EG3MIN2)
      EG3MAX1= (SHAT-Q1252)/2.D0/RSHAT
      EG3MAX2= RSHAT
      EG3MAX3= EGMAX
      EG3MAX4= RSHAT
      EG3MIN= DMAX1(EG3MIN1,EG3MIN2)
      EG3MAX= DMIN1(EG3MAX1,EG3MAX2,EG3MAX3,EG3MAX4)
      IF(EG3MAX.LT.EG3MIN) THEN
         IKINEI = IKINEI + 1
         RETURN
      ENDIF
      ISF3= 1
      CALL ENPHOT(SHAT,CMG3,EG3MIN,EG3MAX,EG3,ANEG3,XG3,ISF3)
*
*-----EG4 GENERATION
*
      IF(IQED.EQ.0) THEN
         EG4MIN= (SHAT-Q1252-2.D0*RSHAT*EG3)/2.D0/RSHAT
         EG4MIN= DMAX1(EGMIN,EG4MIN)
         EG4MAX1= RSHAT-EG3
         EG4MAX2= (SHAT-Q1252-2.D0*RSHAT*EG3)/2.D0/(RSHAT-2.D0*EG3)
         EG4MAX= DMIN1(EGMAX,EG4MAX1,EG4MAX2)
*
         IF(EG4MAX.LT.EG4MIN) THEN
            IKINEI = IKINEI + 1
            RETURN
         ENDIF
         ISF4= 1
         CALL ENPHOT(SHAT,CMG4,EG4MIN,EG4MAX,EG4,ANEG4,XG4,ISF4)  
      ELSE 
         OPBCS = 1.D0 + ABS(BLOR)
         EGMINS = EGMINL/GLOR/OPBCS
         EBSTAR = SQRT(SHAT)/2.D0 
         EGMAXS = EBSTAR
         EG4MIN= (SHAT-Q1252-2.D0*RSHAT*EG3)/2.D0/RSHAT
         EG4MIN= DMAX1(EGMINS,EG4MIN)
         EG4MAX1= RSHAT-EG3
         EG4MAX2= (SHAT-Q1252-2.D0*RSHAT*EG3)/2.D0/(RSHAT-2.D0*EG3)
         EG4MAX= DMIN1(EGMAXS,EG4MAX1,EG4MAX2)
*
         IF(EG4MAX.LT.EG4MIN) THEN
            IKINEI = IKINEI + 1
            RETURN
         ENDIF
         ISF4= 1
         CALL ENPHOT(SHAT,CMG4,EG4MIN,EG4MAX,EG4,ANEG4,XG4,ISF4)  
      ENDIF
*
      CTHG34= SHAT-2.D0*RSHAT*(EG3+EG4)+2.D0*EG3*EG4-Q1252
*
      CTHG34= CTHG34/2.D0/EG3/EG4
      IF(CTHG34.LT.-1.D0.OR.CTHG34.GT.1.D0) THEN
         IKINEI = IKINEI + 1
         RETURN
      ENDIF
      STHG34= SQRT(1.D0-CTHG34*CTHG34)
*
*-----PHI34 GENERATION
*
      anphig34 = 2.d0*pi
      phig34 = anphig34*CMPHIG34
      cphig34 = cos(phig34)
      sphig34 = sin(phig34)
*
*-----Q3 COMPONENTS (PHOTON 1) IN C.M. SYSTEM 
*     Q3 CHOSEN IN THE X-Z PLANE
*
      Q3(0) = EG3
      Q3(1) = EG3*STHG3
      Q3(2) = 0.D0
      Q3(3) = EG3*CTHG3
*
*-----Q4S COMPONENTS (PHOTON 2) IN C.M. THE SYSTEM WITH Z AXIS ALONG Q3Z
*
      Q4S(0) = EG4
      Q4S(1) = EG4*STHG34*CPHIG34
      Q4S(2) = EG4*STHG34*SPHIG34
      Q4S(3) = EG4*CTHG34
*
*-----Q4 COMPONENTS (PHOTON 2) OBTAINED FROM Q4S WITH A ROTATION AROUND
*     THE Y AXIS OF -THG3
*
      Q4(0) = Q4S(0)
      Q4(1) = Q4S(1)*CTHG3+Q4S(3)*STHG3
      Q4(2) = Q4S(2)
      Q4(3) = -Q4S(1)*STHG3+Q4S(3)*CTHG3

      Q125(0) = RSHAT-Q3(0)-Q4(0)
      Q125(1) = -Q3(1)-Q4(1)
      Q125(2) = -Q3(2)-Q4(2)
      Q125(3) = -Q3(3)-Q4(3)
*
*-----COS(THETA_Q5) GENERATION IN THE Q1 Q2 Q5(Z+GAMMA) REST FRAME
*
      ancth5s = 2.d0
      cth5s = ancth5s*CMCTH5S -1.d0
      sth5s = sqrt(1.d0-cth5s*cth5s)
*
*-----PHI_NU GENERATION
*
      anphi5s = 2.d0*pi
      phi5s = anphi5s*CMPHI5S
      cphi5s = cos(phi5s)
      sphi5s = sin(phi5s)
*
*-----Q1S AND Q2S ARE CALCULATED (NEUTRINOS IN THE Q1 Q2 (Z) REST FRAME)
*
      IKINEI2= 0
      CALL DPHI2(Q1252,0.D0,Q122,CTH5S,PHI5S,Q5S,Q12S,F125,IKINEI2)
      IF(IKINEI2.GT.0) THEN
         IKINEI = IKINEI + 1
         RETURN
      ENDIF
*
*-----Q1 AND Q2 ARE CALCULATED (NEUTRINOS IN THE C.M. FRAME)
*
      CALL BOOST(Q5S,Q125,Q5)
      CALL BOOST(Q12S,Q125,Q12)
*
*-----COS(THETA_NU) GENERATION IN THE Q1 Q2 (Z) REST FRAME
*
      ancths = 2.d0
      cths = ancths*CMCTHS -1.d0
      sths = sqrt(1.d0-cths*cths)
*
*-----PHI_NU GENERATION
*
      anphis = 2.d0*pi
      phis = anphis*CMPHIS
      cphis = cos(phis)
      sphis = sin(phis)
*
*-----Q1S AND Q2S ARE CALCULATED (NEUTRINOS IN THE Q1 Q2 (Z) REST FRAME)
*
      IKINEI2= 0
      CALL DPHI2(Q122,0.D0,0.D0,CTHS,PHIS,Q1S,Q2S,F12,IKINEI2)
      IF(IKINEI2.GT.0) THEN
         IKINEI = IKINEI + 1
         RETURN
      ENDIF
*
*-----Q1 AND Q2 ARE CALCULATED (NEUTRINOS IN THE C.M. FRAME)
*
      CALL BOOST(Q1S,Q12,Q1)
      CALL BOOST(Q2S,Q12,Q2)
*
*-----PHI3 GENERATION
*
      anphig3 = 2.d0*pi
      phig3 = anphig3*CMPHIG3
      cphig3 = cos(phig3)
      sphig3 = sin(phig3)
*
*-----ROTATION AROUND THE BEAM AXIS
*
      DO II= 0,3
         Q1F(II)= Q1(II)
         Q2F(II)= Q2(II)
         Q3F(II)= Q3(II)
         Q4F(II)= Q4(II)
         Q5F(II)= Q5(II)
      ENDDO
*
      Q1(1) =  Q1F(1)*CPHIG3+Q1F(2)*SPHIG3
      Q1(2) = -Q1F(1)*SPHIG3+Q1F(2)*CPHIG3
*
      Q2(1) =  Q2F(1)*CPHIG3+Q2F(2)*SPHIG3
      Q2(2) = -Q2F(1)*SPHIG3+Q2F(2)*CPHIG3
*
      Q3(1) =  Q3F(1)*CPHIG3+Q3F(2)*SPHIG3
      Q3(2) = -Q3F(1)*SPHIG3+Q3F(2)*CPHIG3
*
      Q4(1) =  Q4F(1)*CPHIG3+Q4F(2)*SPHIG3
      Q4(2) = -Q4F(1)*SPHIG3+Q4F(2)*CPHIG3
*
      Q5(1) =  Q5F(1)*CPHIG3+Q5F(2)*SPHIG3
      Q5(2) = -Q5F(1)*SPHIG3+Q5F(2)*CPHIG3
*
      RSHAT = SQRT(SHAT)
*
      PP(0) = RSHAT/2.D0
      PP(1) = 0.D0
      PP(2) = 0.D0
      PP(3) = -RSHAT/2.D0
      PM(0) = RSHAT/2.D0
      PM(1) = 0.D0
      PM(2) = 0.D0
      PM(3) = RSHAT/2.D0
*
      ENSUM= ABS(Q1(0)+Q2(0)+Q3(0)+Q4(0)+Q5(0)-RSHAT)
      PXSUM= ABS(Q1(1)+Q2(1)+Q3(1)+Q4(1)+Q5(1))
      PYSUM= ABS(Q1(2)+Q2(2)+Q3(2)+Q4(2)+Q5(2))
      PZSUM= ABS(Q1(3)+Q2(3)+Q3(3)+Q4(3)+Q5(3))
*
      IF(ENSUM.GT.1.D-6.OR.PXSUM.GT.1.D-6.OR.
     #   PYSUM.GT.1.D-6.OR.PZSUM.GT.1.D-6) THEN
*                                                 
         PRINT*,'ENSUM= ',ENSUM
         PRINT*,'PXSUM= ',PXSUM
         PRINT*,'PYSUM= ',PYSUM
         PRINT*,'PZSUM= ',PZSUM
      ENDIF
*
      EB = RS/2.D0
*
      IF(IQED.EQ.1) THEN
         PTOTL(0) = (X1+X2)*EB
         PTOTL(1) = 0.D0
         PTOTL(2) = 0.D0
         PTOTL(3) = (X1-X2)*EB
*
         CALL BOOST(Q1,PTOTL,Q1L)
         CALL BOOST(Q2,PTOTL,Q2L)
         CALL BOOST(Q3,PTOTL,Q3L)
         CALL BOOST(Q4,PTOTL,Q4L)
         CALL BOOST(Q5,PTOTL,Q5L)
         ENSUML= ABS(Q1L(0)+Q2L(0)+Q3L(0)+Q4L(0)+Q5L(0)
     #           +(2.D0-X1-X2)*RS/2.D0-RS)
         PXSUML= ABS(Q1L(1)+Q2L(1)+Q3L(1)+Q4L(1)+Q5L(1))
         PYSUML= ABS(Q1L(2)+Q2L(2)+Q3L(2)+Q4L(2)+Q5L(2))
         PZSUML= ABS(Q1L(3)+Q2L(3)+Q3L(3)+Q4L(3)+Q5L(3)
     #          +(X2-X1)*RS/2.D0) 
*                                                 

      ELSE IF(IQED.EQ.0) THEN
         DO III = 0,3
            Q1L(III) = Q1(III)
            Q2L(III) = Q2(III)
            Q3L(III) = Q3(III)
            Q4L(III) = Q4(III)
            Q5L(III) = Q5(III)
         ENDDO
      ENDIF
*
      q0tot= q1l(0)+q2l(0)+q3l(0)+q4l(0)+q5l(0)
      qxtot= q1l(1)+q2l(1)+q3l(1)+q4l(1)+q5l(1)
      qytot= q1l(2)+q2l(2)+q3l(2)+q4l(2)+q5l(2)
      qztot= q1l(3)+q2l(3)+q3l(3)+q4l(3)+q5l(3)
      qtotmax= sqrt(q0tot**2-qxtot**2-qytot**2-qztot**2)
      qztotmax= qztot+(X2-X1)*rs/2.d0
      absrshat= abs(rshat-qtotmax)
      if(absrshat.gt.1.d-6) then
         iin= iin+1
      endif                 
*
      RETURN
      END
*
      SUBROUTINE KINE2(X1,X2,SHAT,CMCTHG3,CM12,CMG3,CMG4,CMPHIG34,
     #                 CMCTHS,CMPHIS,CMPHIG3,ancthg3,pm1cthg3,
     #                 ANRM12,PRQ12,
     #                 RZM2HAT,RZWHAT,F12,ANEG3,XG3,ANEG4,XG4,
     #                 anphig34,ancths,anphis,anphig3,
     #                 PP,PM,Q1,Q2,Q3,Q4,Q5,
     #                 Q1L,Q2L,Q3L,Q4L,Q5L,IKINEI)
      IMPLICIT REAL*8 (A-H,O-Z)
*
      DIMENSION Q12(0:3),Q1S(0:3),Q2S(0:3),Q4S(0:3),
     #          Q1F(0:3),Q2F(0:3),Q3F(0:3),Q4F(0:3),
     #          PP(0:3),PM(0:3),Q1(0:3),Q2(0:3),Q3(0:3),Q4(0:3),Q5(0:3),
     #          Q1L(0:3),Q2L(0:3),Q3L(0:3),Q4L(0:3),Q5L(0:3),PTOTL(0:3)
      COMMON/CMENERGY/RS,S
      COMMON/EMC/IQED
      COMMON/CUTS/EGMINL,EGMAXL,CMINL,CMAXL
      COMMON/PAR/WM,WG,CFACT,GF,G,ZM,ZW,PI,ALPHA,EM2
      COMMON/RPAR/RWM2,RWG2,RZM2,RZW2,RW,RZW,RW2
*            
      IKINEI = 0
      IF(IQED.EQ.1) THEN
         XM = X1 - X2
         XP = X1 + X2
*
         BLOR = XM/XP
         GLOR = XP/2.D0/SQRT(X1*X2)
*
*.....MIN AND MAX FOR THE PHOTON ANGLE IN C.M. FRAME
*
         CMAX = (CMAXL - BLOR)/(1.D0-BLOR*CMAXL)
         CMIN = (CMINL - BLOR)/(1.D0-BLOR*CMINL)
*
*-----CTHG3 GENERATION
*
*-----sampling according to 1/(1-b^2 cthg^2) con b = 1
*
         arglog = ((1.d0+cmax)/(1.d0-cmax))*((1.d0-cmin)/(1.d0+cmin))
         ancthg3 = 0.5d0*log(arglog)
         rcmax = (1.d0+cmax)/(1.d0-cmax)
         rcmin = (1.d0-cmin)/(1.d0+cmin)
         cum = CMCTHG3
         cumm1 = cum - 1.d0
         cthg3 = (rcmax**cum*rcmin**cumm1-1.d0)
     #         /(rcmax**cum*rcmin**cumm1+1.d0)
         pm1cthg3 = ancthg3*(1.d0-cthg3)*(1.d0+cthg3) 
*
         sthg3 = sqrt(1.d0-cthg3*cthg3)
*
*.....MIN AND MAX FOR THE PHOTON ENERGY IN C.M. FRAME
*
         OPBC = 1.D0 + BLOR*CTHG3
         EGMAX0 = SQRT(SHAT)/2.D0
         EGMIN = EGMINL/GLOR/OPBC
         EGMAX = DMIN1(EGMAXL/GLOR/OPBC,EGMAX0)
         EBSTAR = SQRT(SHAT)/2.D0
      ELSE
         CMIN = CMINL
         CMAX = CMAXL
*
*-----CTHG3 GENERATION
*
*-----sampling according to 1/(1-b^2 cthg^2) con b = 1
*
         arglog = ((1.d0+cmax)/(1.d0-cmax))*((1.d0-cmin)/(1.d0+cmin))
         ancthg3 = 0.5d0*log(arglog)
         rcmax = (1.d0+cmax)/(1.d0-cmax)
         rcmin = (1.d0-cmin)/(1.d0+cmin)
         cum = CMCTHG3
         cumm1 = cum - 1.d0
         cthg3 = (rcmax**cum*rcmin**cumm1-1.d0)
     #         /(rcmax**cum*rcmin**cumm1+1.d0)
         pm1cthg3 = ancthg3*(1.d0-cthg3)*(1.d0+cthg3) 
*
         sthg3 = sqrt(1.d0-cthg3*cthg3)
         EGMIN = EGMINL
         EGMAX = EGMAXL
      ENDIF
*
      RSHAT = SQRT(SHAT)
*
      X12MIN= 0.D0
      X12MAX= 1.D0
      ISI= 1    
      CALL INVMBW(SHAT,CM12,X12MIN,X12MAX,RZM2HAT,RZWHAT,
     #            Q122,ANRM12,PRQ12,ISI)
*
*-----EG3 GENERATION
*
      EG3MIN1= EGMIN
      eg3min2= egmin

      EG3MAX1= (SHAT-Q122)/2.D0/RSHAT
      eg3max2= egmax
      EG3MAX3= EGMAX
      EG3MAX4= EGMAX


      EG3MIN= DMAX1(EG3MIN1,EG3MIN2)
      EG3MAX= DMIN1(EG3MAX1,EG3MAX2,EG3MAX3,EG3MAX4)
      IF(EG3MAX.LT.EG3MIN) THEN
         IKINEI = IKINEI + 1
         RETURN
      ENDIF
      ISF3= 1
      CALL ENPHOT(SHAT,CMG3,EG3MIN,EG3MAX,EG3,ANEG3,XG3,ISF3)
*
*-----EG4 GENERATION
*
*
*.....MIN AND MAX FOR THE PHOTON ENERGY IN C.M. FRAME
*
      IF(IQED.EQ.1) THEN
         OPBC = 1.D0 + ABS(BLOR)
         EGMINS = EGMINL/GLOR/OPBC
         EBSTAR = SQRT(SHAT)/2.D0 
         EGMAXS = EBSTAR
      ELSE
         EGMINS = EGMINL
         EGMAXS = EGMAXL
      ENDIF
*
      EG4MIN= (SHAT-Q122-2.D0*RSHAT*EG3)/2.D0/RSHAT
      EG4MIN= DMAX1(EGMINS,EG4MIN)
      EG4MAX1= RSHAT-EG3
      EG4MAX2= (SHAT-Q122-2.D0*RSHAT*EG3)/2.D0/(RSHAT-2.D0*EG3)
      EG4MAX= DMIN1(EGMAXS,EG4MAX1,EG4MAX2)
*
      IF(EG4MAX.LT.EG4MIN) THEN
         IKINEI = IKINEI + 1
         RETURN
      ENDIF
      ISF4= 1
      CALL ENPHOT(SHAT,CMG4,EG4MIN,EG4MAX,EG4,ANEG4,XG4,ISF4)
*
      CTHG34= SHAT-2.D0*RSHAT*(EG3+EG4)+2.D0*EG3*EG4-Q122
      CTHG34= CTHG34/2.D0/EG3/EG4
      IF(CTHG34.LT.-1.D0.OR.CTHG34.GT.1.D0) THEN
         PRINT*,'CTHG34= ',CTHG34
         IKINEI = IKINEI + 1
         RETURN
      ENDIF
      STHG34= SQRT(1.D0-CTHG34*CTHG34)
*
*-----PHI34 GENERATION
*
      anphig34 = 2.d0*pi
      phig34 = anphig34*CMPHIG34
      cphig34 = cos(phig34)
      sphig34 = sin(phig34)
*
*-----Q3 COMPONENTS (PHOTON 1) IN C.M. SYSTEM 
*     Q3 CHOSEN IN THE X-Z PLANE
*
      Q3(0) = EG3
      Q3(1) = EG3*STHG3
      Q3(2) = 0.D0
      Q3(3) = EG3*CTHG3
*
*-----Q4S COMPONENTS (PHOTON 2) IN C.M. THE SYSTEM WITH Z AXIS ALONG Q3Z
*
      Q4S(0) = EG4
      Q4S(1) = EG4*STHG34*CPHIG34
      Q4S(2) = EG4*STHG34*SPHIG34
      Q4S(3) = EG4*CTHG34
*
*-----Q4 COMPONENTS (PHOTON 2) OBTAINED FROM Q4S WITH A ROTATION AROUND
*     THE Y AXIS OF -THG3
*
      Q4(0) = Q4S(0)
      Q4(1) = Q4S(1)*CTHG3+Q4S(3)*STHG3
      Q4(2) = Q4S(2)
      Q4(3) = -Q4S(1)*STHG3+Q4S(3)*CTHG3
*
*-----Q1+Q2 (Z) VECTOR IS CALCULATED
*
      Q12(0) = RSHAT-Q3(0)-Q4(0)
      Q12(1) = -Q3(1)-Q4(1)
      Q12(2) = -Q3(2)-Q4(2)
      Q12(3) = -Q3(3)-Q4(3)
*
*-----COS(THETA_NU) GENERATION IN THE Q1 Q2 (Z) REST FRAME
*
      ancths = 2.d0
      cths = ancths*CMCTHS -1.d0
      sths = sqrt(1.d0-cths*cths)
*
*-----PHI_NU GENERATION
*
      anphis = 2.d0*pi
      phis = anphis*CMPHIS
      cphis = cos(phis)
      sphis = sin(phis)
*
*-----Q1S AND Q2S ARE CALCULATED (NEUTRINOS IN THE Q1 Q2 (Z) REST FRAME)
*
      IKINEI2= 0
      CALL DPHI2(Q122,0.D0,0.D0,CTHS,PHIS,Q1S,Q2S,F12,IKINEI2)
      IF(IKINEI2.GT.0) THEN
         IKINEI = IKINEI + 1
         RETURN
      ENDIF
*
*-----Q1 AND Q2 ARE CALCULATED (NEUTRINOS IN THE C.M. FRAME)
*
      CALL BOOST(Q1S,Q12,Q1)
      CALL BOOST(Q2S,Q12,Q2)
*
*-----PHI3 GENERATION
*
      anphig3 = 2.d0*pi
      phig3 = anphig3*CMPHIG3
      cphig3 = cos(phig3)
      sphig3 = sin(phig3)
*
*-----ROTATION AROUND THE BEAM AXIS
*
      DO II= 0,3
         Q1F(II)= Q1(II)
         Q2F(II)= Q2(II)
         Q3F(II)= Q3(II)
         Q4F(II)= Q4(II)
      ENDDO
      Q1(1) =  Q1F(1)*CPHIG3+Q1F(2)*SPHIG3
      Q1(2) = -Q1F(1)*SPHIG3+Q1F(2)*CPHIG3

      Q2(1) =  Q2F(1)*CPHIG3+Q2F(2)*SPHIG3
      Q2(2) = -Q2F(1)*SPHIG3+Q2F(2)*CPHIG3

      Q3(1) =  Q3F(1)*CPHIG3+Q3F(2)*SPHIG3
      Q3(2) = -Q3F(1)*SPHIG3+Q3F(2)*CPHIG3

      Q4(1) =  Q4F(1)*CPHIG3+Q4F(2)*SPHIG3
      Q4(2) = -Q4F(1)*SPHIG3+Q4F(2)*CPHIG3
*
      RSHAT = SQRT(SHAT)
*
      PP(0) = RSHAT/2.D0
      PP(1) = 0.D0
      PP(2) = 0.D0
      PP(3) = -RSHAT/2.D0
      PM(0) = RSHAT/2.D0
      PM(1) = 0.D0
      PM(2) = 0.D0
      PM(3) = RSHAT/2.D0
*
      ENSUM= ABS(Q1(0)+Q2(0)+Q3(0)+Q4(0)-RSHAT)
      PXSUM= ABS(Q1(1)+Q2(1)+Q3(1)+Q4(1))
      PYSUM= ABS(Q1(2)+Q2(2)+Q3(2)+Q4(2))
      PZSUM= ABS(Q1(3)+Q2(3)+Q3(3)+Q4(3))
*
      IF(ENSUM.GT.1.D-6.OR.PXSUM.GT.1.D-6.OR.
     #   PYSUM.GT.1.D-6.OR.PZSUM.GT.1.D-6) THEN
*
         PRINT*,'ENSUM= ',ENSUM
         PRINT*,'PXSUM= ',PXSUM
         PRINT*,'PYSUM= ',PYSUM
         PRINT*,'PZSUM= ',PZSUM
      ENDIF
*
      EB = RS/2.D0
*
      Q5(0) = 0.D0
      Q5(1) = 0.D0
      Q5(2) = 0.D0
      Q5(3) = 0.D0
*
      IF(IQED.EQ.1) THEN
         PTOTL(0) = (X1+X2)*EB
         PTOTL(1) = 0.D0
         PTOTL(2) = 0.D0
         PTOTL(3) = (X1-X2)*EB
*
         CALL BOOST(Q1,PTOTL,Q1L)
         CALL BOOST(Q2,PTOTL,Q2L)
         CALL BOOST(Q3,PTOTL,Q3L)
         CALL BOOST(Q4,PTOTL,Q4L)
         CALL BOOST(Q5,PTOTL,Q5L)
*
      ELSE IF(IQED.EQ.0) THEN
         DO III = 0,3
            Q1L(III) = Q1(III)
            Q2L(III) = Q2(III)
            Q3L(III) = Q3(III)
            Q4L(III) = Q4(III)
            Q5L(III) = Q5(III)
         ENDDO
      ENDIF
*
      RETURN
      END
C*********************************************************************
      SUBROUTINE SPINSAMPLING_NEW(RND,REDEFINED,SPINWEIGHT,nconf,flag)
C*********************************************************************
C
      IMPLICIT NONE
C      
      integer nconf     !number of spin configurations
      INTEGER FLAG      !Flag to decide wether the cumulative is already
                        !present or must be computed
                        !:  0 = read SPINBIN.DAT and compute CUMULATIVE
      REAL*8 RND        !RANDOM NUMBER
      REAL*8 REDEFINED  !PROPERLY RESCALED SPIN VARIABLE
      REAL*8 SPINWEIGHT !WEIGHT DUE TO RESCALING
      INTEGER J1,J2
      integer nconfmax
      integer nmax
      parameter (nmax=8)        !maximum number of external particles, change here
      parameter (nconfmax=3**nmax) 
      REAL*8 PARTIAL(nconfmax),TOT,AUXILIAR,CUMULATIVE(nconfmax)
      common/sampl_gen/cumulative
C
      IF (FLAG.EQ.0) THEN
       FLAG=1       
       OPEN (1,FILE='spinbin.dat',STATUS='OLD')
        TOT=0.
        DO J1=1,nconf
         READ(1,*)PARTIAL(J1)
         TOT=TOT+PARTIAL(J1)
        ENDDO
       CLOSE(1)
C
       DO J1=1,nconf
        PARTIAL(J1)=PARTIAL(J1)/TOT
       ENDDO
C
       TOT=0.
       DO J1=1,nconf
        IF(PARTIAL(J1).LT.4.D-4)PARTIAL(J1)=4.D-4
        TOT=TOT+PARTIAL(J1)
       ENDDO
C
       DO J1=1,nconf
        PARTIAL(J1)=PARTIAL(J1)/TOT
       ENDDO
C
       DO J1=1,nconf
        DO J2=J1,nconf
         IF(PARTIAL(J2).GT.PARTIAL(J1)) THEN
          AUXILIAR=PARTIAL(J1)
          PARTIAL(J1)=PARTIAL(J2)
          PARTIAL(J2)=AUXILIAR
         ENDIF
        ENDDO
       ENDDO
C
       CUMULATIVE(1)=PARTIAL(1)
       DO J1=2,nconf
        CUMULATIVE(J1)=CUMULATIVE(J1-1)+PARTIAL(J1)
       ENDDO
C
      ENDIF
C
*
*     WARNING THE FOLLOWING LOOP DOES NOT WORK IF PARTIAL(J1) HAS ZEROS
*
      J1=1
      DO WHILE(RND.GT.CUMULATIVE(J1))
       J1=J1+1
      ENDDO
C
      REDEFINED= (FLOAT(J1)-0.5)/float(nconf)
      SPINWEIGHT = 1./float(nconf)/PARTIAL(J1)
C
      RETURN
      END
C*********************************************************************
      SUBROUTINE SPINSAMPLING_NEW_B(RND,REDEFINED,SPINWEIGHT,
     #                              nconf,flag,flnm)
C*********************************************************************
C
      IMPLICIT NONE
C      
      integer nconf     !number of spin configurations
      INTEGER FLAG      !Flag to decide wether the cumulative is already
                        !present or must be computed
                        !:  0 = read SPINBIN.DAT and compute CUMULATIVE
      REAL*8 RND        !RANDOM NUMBER
      REAL*8 REDEFINED  !PROPERLY RESCALED SPIN VARIABLE
      REAL*8 SPINWEIGHT !WEIGHT DUE TO RESCALING
      INTEGER J1,J2
      integer nconfmax
      integer nmax
      parameter (nmax=8)        !maximum number of external particles, change here
      parameter (nconfmax=3**nmax) 
      REAL*8 PARTIAL(nconfmax),TOT,AUXILIAR,CUMULATIVE(nconfmax)
      CHARACTER*11 FLNM
      common/sampl_gen/cumulative
C
      IF (FLAG.EQ.0) THEN
       FLAG=1       
       OPEN (1,FILE='FLNM',STATUS='OLD')
        TOT=0.
        DO J1=1,nconf
         READ(1,*)PARTIAL(J1)
         TOT=TOT+PARTIAL(J1)
        ENDDO
       CLOSE(1)
C
       DO J1=1,nconf
        PARTIAL(J1)=PARTIAL(J1)/TOT
       ENDDO
C
       TOT=0.
       DO J1=1,nconf
        IF(PARTIAL(J1).LT.4.D-4)PARTIAL(J1)=4.D-4
        TOT=TOT+PARTIAL(J1)
       ENDDO
C
       DO J1=1,nconf
        PARTIAL(J1)=PARTIAL(J1)/TOT
       ENDDO
C
       DO J1=1,nconf
        DO J2=J1,nconf
         IF(PARTIAL(J2).GT.PARTIAL(J1)) THEN
          AUXILIAR=PARTIAL(J1)
          PARTIAL(J1)=PARTIAL(J2)
          PARTIAL(J2)=AUXILIAR
         ENDIF
        ENDDO
       ENDDO
C
       CUMULATIVE(1)=PARTIAL(1)
       DO J1=2,nconf
        CUMULATIVE(J1)=CUMULATIVE(J1-1)+PARTIAL(J1)
       ENDDO
C
      ENDIF
C
*
*     WARNING THE FOLLOWING LOOP DOES NOT WORK IF PARTIAL(J1) HAS ZEROS
*
      J1=1
      DO WHILE(RND.GT.CUMULATIVE(J1))
       J1=J1+1
      ENDDO
C
      REDEFINED= (FLOAT(J1)-0.5)/float(nconf)
      SPINWEIGHT = 1./float(nconf)/PARTIAL(J1)
C
      RETURN
      END

*
      SUBROUTINE INVMBWIR(SS,C,X2MN,X2M,RM2,RW,
     #                    QIJ2,ANRMIJ,PRQIJ,ISBW,ISIR)
      IMPLICIT REAL*8 (A-H,O-Z)
*
      XMED = (X2MN+X2M)/2.D0
*
      IF(C.LT.0.5D0) THEN
         CB= C/0.5D0
         CALL INVMBW(SS,CB,X2MN,XMED,RM2,RW,QIJ2,ANRMIJ,PRQIJ,ISBW)
         ANRMIJ= ANRMIJ/0.5D0
      ELSE IF(C.GE.0.5D0) THEN
         CB= (C-0.5D0)/0.5D0
         CALL INVMIR(SS,CB,XMED,X2M,QIJ2,ANRMIJ,PRQIJ,ISIR)
         ANRMIJ= ANRMIJ/0.5D0
      ENDIF
*
      RETURN
      END
*
      SUBROUTINE INVMIR(SS,C,X2MN,X2M,QIJ2,ANRMIJ,PRQIJ,IS)
      IMPLICIT REAL*8 (A-H,O-Z)
*
      X2MIN = X2MN
      X2MAX = X2M
*
      IF(IS.EQ.0) THEN
         ANRMIJ = X2MAX-X2MIN
         XIJ = (X2MAX-X2MIN)*C + X2MIN
         PRQIJ = 1.D0
      ELSE
         ANRMIJ = LOG((1.D0-X2MIN)/(1.D0-X2MAX))
         OMXIJ = EXP((1.D0-C)*LOG(1.D0-X2MIN))*EXP(C*LOG(1.D0-X2MAX))
         XIJ = 1.D0 - OMXIJ
         PRQIJ = 1.D0-XIJ
      ENDIF
*
      QIJ2 = XIJ*SS
*
      RETURN
      END
*
      FUNCTION CGLEAD(X)
      IMPLICIT REAL*8 (A-H,O-Z)
*
      COMMON/CMENERGY/RS,S
      COMMON/PAR/WM,WG,CFACT,GF,G,ZM,ZW,PI,ALPHA,EM2
*
      EM = SQRT(EM2)
      EBEAM = RS/2.D0
      VOC = (1.D0 - EM/EBEAM)*(1.D0 + EM/EBEAM)
      VOC = SQRT(VOC)
      ANBM = -1.D0/VOC*LOG((1.D0-VOC)/(1.D0+VOC))

      CGLEAD = 1.D0/(1.D0-VOC*X)
      CGLEAD = CGLEAD/ANBM
*
      RETURN
      END
*
*-----SUBROUTINE PARAMETERS()
*
      SUBROUTINE PARAMETERS()
      IMPLICIT REAL*8 (A-H,O-Z)
      COMPLEX*16 GZCLEPV,GZCLEPA,GZNLEPV,GZNLEPA,GZCUPV,GZCUPA,GZCDNV,
     #           GZCDNA,GWLEPV,GWLEPA,E_ELM,HWW,HZZ,ZWW,AWW,ZW13,ZW14,
     #           zz15,ww16,gg17,gz17,zwp18,wmg19,gwm19,zwm18,wpg19,gwp19
     #          ,zz20,gg21,zazb22,gagb23 
      COMPLEX*16 WW4,ZZ5,ZG5,GG5,WW5,GW5,GW6,ZW7,GW7,WW8,WW9 

*
      COMMON/CMENERGY/RS,S
      COMMON/FM/EM,AMU,TLM,UQM,DQM,CQM,SQM,BQM,TQM
      COMMON/PAR/WM,WG,CFACT,GF,G,ZM,ZW,PI,ALPHA,EM2
      COMMON/PARD/ZM2,ZW2,WM2,WG2,GF2,G2,G4,G8
      COMMON/Higgs/HM,HW1
      COMMON/THETAW/STH2
      COMMON/EM/RL,ETA,BETA,SDELTA,BETAM
      COMMON/AIN/ALPHAI
      COMMON/EMC/IQED
      COMMON/WEAKRHO/RHO
      CHARACTER*1 OQGC
      real*8 XLAMBDA, A0W,ACW,A0Z,ACZ
      COMMON/QGC/XLAMBDA, A0W,ACW,A0Z,ACZ,OQGC
      real*8 gv,kv,lv,gv5,kp,lp,awwgg,awgwg !anomalous couplings
      real*8 awwgz,awzwg,awpzfwfg,awmzfwfg,awmfwpgfz
      real*8 agfwpwmfz,awpfwmgfz,agfwmwpfz,azgzg,azzgg

      common/anz/gv,kv,lv,gv5
      common/ang/kp,lp
      common/anm4/apmpm,appmm,apzmz,azzpm,azzzz
      common/an4g/awwgg,awgwg,azzgg
      common/an4gz/awwgz,awzwg,awpzfwfg,awmzfwfg
      COMMON/ANOMV/XG,YG      
*
*     PARAMETERS ARE INITIALIZED
*
*-----INPUT PARAMETERS ARE INITIALIZED: W MASS, Z MASS + OTHERS
*-----PARAMETER VALUES
*
      DATA WM/80.22D0/,CFACT/0.38937966D9/,
     #     GF/8.2476227851D-6/,ZM/91.1887D0/,
     #     ZW/2.497D0/
*
*-----FERMION MASSES
*
      DATA EM/0.51099906D-3/,AMU/0.10565839D0/,
     #     TLM/1.7771D0/,UQM/0.047D0/,DQM/0.047D0/,
     #     CQM/1.55D0/,SQM/0.15D0/,
     #     BQM/4.7D0/,TQM/175.D0/ 
*
      DATA PI/3.141592653589793238462643D0/,
     #     ALPHA/7.297353079644819D-3/
*
      data gv/1./,kv/1./,kp/1./,lv/0./,gv5/0./,lp/0./ ! ,awwgg/2.0/
*
      data awwgg/0./,awgwg/0./,awwgz/0./,awzwg/0./,awpzfwfg/0./
      data awmzfwfg/0./,awmfwpgfz/0./,agfwpwmfz/0./,awpfwmgfz/0./
      data agfwmwpfz/0./,azgzg/0./,azzgg/0./
*
*-----DERIVED PARAMETERS
*
      zm0=zm       
      zw0=zw         
      ZM2= ZM*ZM
      WM2= WM*WM
*
*-----TGC FOR ALPHA
*
      kp= 1+xg
      lp= -yg       
      lp=lp/wm2
*
      DELA= 1.D0 - ALPHA/ALPHAI
      OMDA= 1.D0-DELA
*      
      AMUP= SQRT(PI*ALPHA/2.D0/GF)
      DELR= 3.D0*GF*TQM**2/8.D0/PI/PI
      RHO= 1.D0/(1.D0-DELR)

      STH2= 0.5D0*(1.D0-SQRT(1.D0-4.D0*AMUP**2/RHO/ZM/ZM/OMDA))
*
      G2 = 8.D0*GF*WM2
      G= SQRT(G2)
      STH= SQRT(STH2)
      CTH2= 1.D0-STH2
      CTH= SQRT(CTH2)
*
      PREFACT=-(G*STH/XLAMBDA)**2/16.D0      
      awwgg=prefact*2.d0*a0w
      awgwg=prefact*acw
      azzgg=prefact/cth2*a0z
      azgzg=prefact/cth2*acz   
*
      WGSM= 0.D0
*
      WG= WGSM
      WG2= WG*WG

      awzwg      = awzwg/2.d0  !rescaling
      awpzfwfg   = -awpzfwfg   !signe changes 

      awmzfwfg   = -awpzfwfg   !WZ1 
      agfwmwpfz  =  agfwpwmfz  !WZ2   
      awpfwmgfz  =  awmfwpgfz  !WZ3        
      awgwg = awgwg/2.d0
      azgzg = azgzg/4.d0

*
      OPEN(1,FILE='PARAM.DAT',STATUS='UNKNOWN')
      
*
*-----BOSON MASSES AND WIDTHS
*
      WRITE(1,*) HM     ! HIGGS MASS
      WRITE(1,*) WM     ! W MASS
      WRITE(1,*) ZM     ! Z MASS
      WRITE(1,*) HW1    ! HIGGS WIDTH
      WRITE(1,*) WG    ! W WIDTH
      WRITE(1,*) ZW     ! Z WIDTH
*
*-----FERMION MASSES
*
      WRITE(1,*) 0. ! EM      ! ELECTRON MASS
      WRITE(1,*) 0. ! AMU     ! MUON MASS
      WRITE(1,*) 0. ! TLM     ! TAU  MASS
      WRITE(1,*) 0. ! UQM     ! U QUARK MASS
      WRITE(1,*) 0. ! DQM     ! D QUARK MASS
      WRITE(1,*) 0. ! CQM     ! C QUARK MASS
      WRITE(1,*) 0. ! SQM     ! S QUARK MASS
*
      GZCLEPV= G*(4.D0*STH2 - 1.D0)/4.D0/CTH
      GZCLEPV= - GZCLEPV                               !alpha convention
      GZCLEPA= -G/4.D0/CTH
      GZNLEPV= G/4.D0/CTH
      GZNLEPV= -GZNLEPV                               !alpha convention
      GZNLEPA= G/4.D0/CTH
      GWLEPV= G/2.D0/SQRT(2.D0)
      GWLEPV= - GWLEPV                               !alpha convention
      GWLEPA= G/2.D0/SQRT(2.D0)
      GZCUPV= G*(-2./3.*4.D0*STH2 + 1.D0)/4.D0/CTH
      GZCUPV= - GZCUPV                               !alpha convention
      GZCDNV= G*(1./3.*4.D0*STH2 - 1.D0)/4.D0/CTH
      GZCDNV= - GZCDNV                               !alpha convention
      GZCUPA= G/4.D0/CTH
      GZCDNA= -G/4.D0/CTH
      E_ELM= G*STH
*
*  notice ALPHA uses (1-g_5) for left-handed projector
*
      WRITE(1,*) GZCLEPV  ! COUPLING Z L+ L- VECTOR
      WRITE(1,*) GZCLEPA  ! COUPLING Z L+ L- ASSIAL
      WRITE(1,*) GZNLEPV  ! COUPLING Z N N  VECTOR
      WRITE(1,*) GZNLEPA  ! COUPLING Z N N  ASSIAL
      WRITE(1,*) GZCUPV   ! COUPLING Z U U  VECTOR
      WRITE(1,*) GZCUPA   ! COUPLING Z U U  ASSIAL
      WRITE(1,*) GZCDNV   ! COUPLING Z D D  VECTOR
      WRITE(1,*) GZCDNA   ! COUPLING Z D D  ASSIAL
      WRITE(1,*) GWLEPV   ! COUPLING Z F F' VECTOR
      WRITE(1,*) GWLEPA   ! COUPLING Z F F' ASSIAL
      WRITE(1,*) -E_ELM*2./3. !GAMMA U U 
      WRITE(1,*) E_ELM*1./3. !GAMMA D D 
      WRITE(1,*) E_ELM       !GAMMA L L  
*
*-----SELF COUPLING HIGGS-GAUGE BOSONS
*
      HWW= -G*WM
      HZZ= -G*WM/CTH/CTH/2.
      WRITE(1,*) HWW  ! COUPLING H W+ W- 
      WRITE(1,*) HZZ  ! COUPLING H Z Z
*
*-----TRILINEAR GAUGE SELF COUPLINGS
*
      ZWW= G*CTH
      AWW= G*STH
      WRITE(1,*) ZWW  ! COUPLING Z W+ W- 
      WRITE(1,*) AWW  ! COUPLING A W+ W-
*
*-----QUADRILINEAR GAUGE SELF COUPLINGS   (couplings for auxiliary fields)
*
      azzpm= 0.
      apmpm= 0.
      appmm= 0.
      apzmz= 0.
      azzzz= 0.

      WW4= G                  !COUPLINGS (4) W W
      ZZ5= G*CTH2-azzpm/g            !COUPLINGS (5) Z Z
      ZG5= 2.*G*CTH*STH       !COUPLINGS (5) Z GAMMA
      GG5= G*STH2             !COUPLINGS (5) GAMMA GAMMA
      WW5= G/2.-apmpm/g       !COUPLINGS (5) W W
      GW5= G*CTH              !COUPLINGS (6) Z W
      GW6= G*STH              !COUPLINGS (6) GAMMA W
      ZW7= -G*CTH             !COUPLINGS (7) Z W
      GW7= -G*STH             !COUPLINGS (7) GAMMA W
      WW8= G                  !COUPLINGS (8) W W
      WW9= -G/2.-appmm/g      !COUPLINGS (9) W W
      ZW13=1.                 !COUPLINGS (13) Z W^- 
      ZW14=-apzmz              !COUPLINGS (14) Z W^+  (for anomalous quartic) 
      zz15=sqrt(azzzz)        !COUPLINGS (15) Z Z  (for anomalous quartic)
      ww16=1.
      gg17=  awgwg
      gz17 = awzwg
      zwp18 = 1.d0 
      wmg19 = awmfwpgfz
      gwm19 = agfwpwmfz
      zwm18 = 1.d0 
      wpg19 = awpfwmgfz
      gwp19 = agfwmwpfz
      zz20 = 1.d0
      gg21 = 1.d0         !azzgg
      zazb22 = 1.d0      
      gagb23 = azgzg
      

      WRITE(1,*) WW4           !COUPLINGS (4) W W
      WRITE(1,*) ZZ5           !COUPLINGS (5) Z Z
      WRITE(1,*) ZG5           !COUPLINGS (5) Z GAMMA
      WRITE(1,*) GG5           !COUPLINGS (5) GAMMA GAMMA
      WRITE(1,*) WW5           !COUPLINGS (5) W W
      WRITE(1,*) GW5           !COUPLINGS (6) Z W
      WRITE(1,*) GW6           !COUPLINGS (6) GAMMA W
      WRITE(1,*) ZW7           !COUPLINGS (7) Z W
      WRITE(1,*) GW7           !COUPLINGS (7) GAMMA W
      WRITE(1,*) WW8           !COUPLINGS (8) W W
      WRITE(1,*) WW9           !COUPLINGS (9) W W         
      WRITE(1,*) ZW13          !COUPLINGS (13) Z W^- 
      WRITE(1,*) ZW14          !COUPLINGS (14) Z W^+  (for anomalous quartic) 
      WRITE(1,*) ZZ15          !COUPLINGS (15) Z Z    (for anomalous quartic)
      WRITE(1,*) WW16          !COUPLINGS (16) W W
      WRITE(1,*) GG17          !COUPLINGS (17) GAMMA GAMMA
      WRITE(1,*) GZ17          !COUPLINGS (17) GAMMA ZETA
      write(1,*) zwp18 
      write(1,*) wmg19
      write(1,*) gwm19
      write(1,*) zwm18
      write(1,*) wpg19
      write(1,*) gwp19
      write(1,*) zz20
      write(1,*) gg21
      write(1,*) zazb22
      write(1,*) gagb23
      CLOSE(1)
    
      RETURN
      END
*
*-----SUBROUTINE ACCEPTANCE: USED TO GENERATE PHOTONS
*     WITHIN THE INPUT ACCEPTANCE
*
      SUBROUTINE ACCEPTANCE(EVENT,CUTFLAG)
      IMPLICIT REAL*8 (A-H,O-Z)
      DIMENSION EVENT(24)
      DIMENSION CEVENT(24)     
      COMMON/PAR/WM,WG,CFACT,GF,G,ZM,ZW,PI,ALPHA,EM2
      COMMON/COUPL/FI3E,QFE,FI31,QF1,FI32,QF2,FI33,QF3,FI34,QF4,
     #            FI35,QF5,FI36,QF6
      COMMON/CUTS/EGMINL,EGMAXL,CMINL,CMAXL
      COMMON/NG/NPHOT
*
      DO J = 1,18
         CEVENT(J) = EVENT(J)
      ENDDO
*
      EB = CEVENT(3)
*
      Q1X= CEVENT(4)
      Q1Y= CEVENT(5)
      Q1Z= CEVENT(6)
      Q2X= CEVENT(7)
      Q2Y= CEVENT(8)
      Q2Z= CEVENT(9)
      Q3X= CEVENT(10)
      Q3Y= CEVENT(11)
      Q3Z= CEVENT(12)
      Q4X= CEVENT(13)
      Q4Y= CEVENT(14)
      Q4Z= CEVENT(15)
      Q5X= CEVENT(16)
      Q5Y= CEVENT(17)
      Q5Z= CEVENT(18)
*
      CUTFLAG= 1.D0
      if(ifir.eq.0)then
         print *,'EGMINL,EGMAXL,CMINL,CMAXL',EGMINL,EGMAXL,CMINL,CMAXL
         ifir = 1
      endif 
*
      IF(NPHOT.EQ.1) THEN
         E3= SQRT(Q3X*Q3X+Q3Y*Q3Y+Q3Z*Q3Z)
         CTH3= Q3Z/E3
         IF(E3.LT.EGMINL.OR.E3.GT.EGMAXL.OR.
     #      CTH3.LT.CMINL.OR.CTH3.GT.CMAXL) THEN
            CUTFLAG= 0.D0
            RETURN
         ENDIF          
*
      ELSE IF(NPHOT.EQ.2) THEN
         E3= SQRT(Q3X*Q3X+Q3Y*Q3Y+Q3Z*Q3Z)
         E4= SQRT(Q4X*Q4X+Q4Y*Q4Y+Q4Z*Q4Z)
         IF(E3.LT.EGMINL.OR.E3.GT.EGMAXL) THEN
            CUTFLAG= 0.D0
            RETURN
         ENDIF
         IF(E4.LT.EGMINL.OR.E4.GT.EGMAXL) THEN
            CUTFLAG= 0.D0
            RETURN
         ENDIF
         CTH3= Q3Z/E3
         CTH4= Q4Z/E4     
         IF(CTH3.LT.CMINL.OR.CTH3.GT.CMAXL) THEN
            CUTFLAG= 0.D0
            RETURN
         ENDIF

         IF(CTH4.LT.CMINL.OR.CTH4.GT.CMAXL) THEN
            CUTFLAG= 0.D0
            RETURN
         ENDIF
*
      ELSE IF(NPHOT.EQ.3) THEN
         E3= SQRT(Q3X*Q3X+Q3Y*Q3Y+Q3Z*Q3Z)
         E4= SQRT(Q4X*Q4X+Q4Y*Q4Y+Q4Z*Q4Z)
         E5= SQRT(Q5X*Q5X+Q5Y*Q5Y+Q5Z*Q5Z)
         IF(E3.LT.EGMINL.OR.E3.GT.EGMAXL) THEN
            CUTFLAG= 0.D0
            RETURN
         ENDIF

         IF(E4.LT.EGMINL.OR.E4.GT.EGMAXL) THEN
            CUTFLAG= 0.D0
            RETURN
         ENDIF

         IF(E5.LT.EGMINL.OR.E5.GT.EGMAXL) THEN
            CUTFLAG= 0.D0
            RETURN
         ENDIF
         CTH3= Q3Z/E3
         CTH4= Q4Z/E4
         CTH5= Q5Z/E5
         IF(CTH3.LT.CMINL.OR.CTH3.GT.CMAXL) THEN
            CUTFLAG= 0.D0
            RETURN
         ENDIF

         IF(CTH4.LT.CMINL.OR.CTH4.GT.CMAXL) THEN
            CUTFLAG= 0.D0
            RETURN
         ENDIF

         IF(CTH5.LT.CMINL.OR.CTH5.GT.CMAXL) THEN
            CUTFLAG= 0.D0
            RETURN
         ENDIF
*
      ENDIF
*
      RETURN
      END
*
C***********************************************************************
          subroutine itera(elmat)
C***********************************************************************
C
C This subroutine perform the perturbative iteration.
C 
          implicit none
C
          integer countsour   !to count the number of already initilaized
C                               sources
          integer flagread/0/
          integer jloop,j1,j2,j3,j4,j5 !loop variables
          integer labvma (100,5), labyuk (10,4), labselfgau (50,3),
     >            labgauhg (50,3)   !labelling non zero interactions
          integer nvma ,nyuk, nselfgau, ngauhg
          integer next       !number of external particles
          integer nfermion   !number of external fermions
          integer nmax       !maximum number of external particles
          parameter (nmax=8) !maximal number of external particle. Change here
          integer dimnum       !dimension of the array NUMBfield
          integer dimmom       !dimension of the array MOMfield
          integer dimcons      !dimension of the array CONSTfield
          integer dimop        !dimension of the array OPERATOR
C
          parameter (dimmom=(2**nmax-2)/2) !number of allowed momentum 
C                     configuration 
          parameter (dimnum=nmax/2)      !storing the number of configuration
C                                    with 1,...,4 momenta contributing
          parameter (dimop=1)
          parameter (dimcons=5)      !number of needed particle caracteristics.
C                       wishing to change it one needs to change this statement
          integer iteration   !storing the present iteration stage
          integer niteration !number of iteration steps
          integer operator(dimop)  !a flag to identify the type of operator, 
          integer write/0/       !flag to control output
C
          real*8 coupmin/1.d-10/
C
          complex*16 a,b,c,count1,count2
          complex*16 elmat      !to store matrix element
C
          common/iter/niteration
          common/external/next,nfermion !containing the number of external
C                                        particles from the subroutine ??????
          common/vecass/a,b,count1,count2
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C  declaring the variables for higgs, gauge-bosons, fermions and fermionbars 
C  fields
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C setting the variables defininig the higgs field
C
          integer nhigbos
          parameter (nhigbos=3) !higgs field 1) higgs 2) Y_h 3) X_h
          real*8 consthiggs(dimcons,nhigbos) !containing the characteristic of
C          the higgs fields:
C                              1) mass
C                              2) Lorentz nature 
C                              3) coulor
C                              4) particle "name" see ??? for the conventions
C                              5) particle width
          integer dimhiggs     !dimension of the array field for higgs field
          parameter (dimhiggs=dimmom)  !dimension of a scalar, coulor singlet
C                  higgs field.
          complex*16 higgs(dimhiggs,nhigbos) !array containing the higgs field
C                                             configurations 
          integer momhiggs(dimmom,nhigbos)  !array containing a label for each 
C            indipendent momentum configuration. This is for the higgs field
          integer numbhiggs(dimnum,nhigbos) !NUMBHIGGS(j,k) contains the number
C                                        of higgs configurations with j momenta
          integer starthiggs(nhigbos) !to help disentangling the structure of 
C                                                                  the variable
          data starthiggs/0,1,2/             
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C setting the variables defininig the gauge-bosons field
C
          integer ngaubos
          parameter (ngaubos=23)  ! Gauge bosons fields 1)Z 2)W^+ 3)W^- 
C                   4)X_{+-} 5)Y_{+-} 6)X_{3+} 7)Y_{3+} 8)X_{++} 9)Y_{++} 10) A
C                   11)gluons  12) G_mn (for the definition of X, Y 
C                                              G and G_mn see notes)
C
          real*8 constgaubosons(dimcons,ngaubos)!containing the characteristic
C                                                   of the gauge-bosons fields 
          integer dimgaubosons               !dimension of the array field for
C                                              gauge-bosons field
          parameter (dimgaubosons=133*dimmom) ! 133  =  4 ( 4 lorentz 
C                 degrees of freedom) * 4 (Z,W,W,A) + 6 (number of X,Y fields) 
C                 + 4 (Lor dof) gluon    + 6 (Lor dof) G_mn   
C                 + 3 (number of X,Y fields) +16 (Lor dof) * 4 (X_munu fields)
C                 + 2 (number of X,Y fields) +16 (Lor dof) * 2 (X_munu fields
          integer momgaubosons(dimmom,ngaubos)   !array containing a label for 
C      each indipendent momentum configuration. This is for the gaubosons field
          integer numbgaubosons(dimnum,ngaubos) !NUMBGAUBOSONS(j) contains the
C                           number of gaubosons configurations with j momenta
          complex*16 gaubosons(dimgaubosons)     !gaubosons field
          integer startgaubosons(ngaubos)!to help disentangling the structure
C                                                             of the variable
          data startgaubosons/0,4,8,12,13,14,15,16,17,18,22,26,32,33,
     >                        34,35,51,67,83,99,100,101,117/
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C setting the variables defininig the fermions field
C
          integer nfer1
          integer nfer2
          parameter (nfer1=3) ! 3 fermion families
          parameter (nfer2=4) ! 4 fermions per family          
          real*8 constfermion(dimcons,nfer2,nfer1)  !containing the 
C                                        characteristic of the fermion fields. 
          integer dimfermion    !dimension of the array field for fermion field
          parameter (dimfermion=dimmom*16)  !dimension of a fermion family. 
C         4 (2 quarks  and 2 leptons) * 4 (lorentz dof)
          complex*16 fermion(dimfermion,nfer1)      !fermion fields. The first
C index run over the family memebrs as well as over the momentum configurations
          integer momfermion(dimmom,nfer2,nfer1) !array containing a label for
C       each indipendent momentum configuration. This is for the fermion fields
          integer numbfermion(dimnum,nfer2,nfer1)  !NUMBFERMION(i,j,k) contains
C                         the number fermion(i,j) configurations with k momenta
          integer stfermion(nfer2)                 !to help disentangling the 
C                                                   structure of the variable
          data stfermion/0,4,8,12/    
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C setting the variables defininig the fermionsbar field
C
          real*8 constfermionbar(dimcons,nfer2,nfer1) !containing the 
C  characteristic of the fermionbar fields. 
          complex*16 fermionbar(dimfermion,nfer1) !fermionbar fields. The first 
C index runs over the family members as well as over the momenta configurations
          integer momfermionbar(dimmom,nfer2,nfer1) !array containing a label 
C for each indipendent momentum configuration. This is for fermionbar fields
          integer numbfermionbar(dimnum,nfer2,nfer1)  !NUMBFERMIONBAR(i,j,k) 
C                      the number fermionbar(i,j) configurations with k momenta
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C Containing the common for coupling constants. Shared by the subroutines       
C ITERA and COUPLINGS.
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
          complex*16 selfhiggs(3), yukawa(3,4,3,4), 
     >               vectorial(ngaubos,3,4,3,4), assial(ngaubos,3,4,3,4)
     >               ,selfgauge(ngaubos,ngaubos,ngaubos),
     >               higgsgauge(3,ngaubos,ngaubos)  
C
          common/coupconst/selfhiggs,yukawa,vectorial,selfgauge,
     >                    higgsgauge,assial   !add here new couplings
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C                                                                             C
C Containing the common for particles masses. Shared by the subroutines       C
C ITERA and COUPLINGS                                                         C
C                                                                             C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
          real*8 masshiggs(3), massgaubosons(ngaubos), massfermion(3,4)
     >           , widthhiggs(3), widthgaubosons(ngaubos),
     >           widthfermion(3,4)  
C
          common/masses/masshiggs,massgaubosons,massfermion ,
     >                  widthhiggs,widthgaubosons,widthfermion !add here new particles
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C                                                                             C
C Containing the common for number,coulor and spin of external particles. Shared by the       C
C subroutines ITERA, PROCESSO and SPINVARIABLE; ITERA and COLORCONF;
C ITERA, PROCESSO, FILLCONFSPIN AND SPINCOULOR respectively
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
         integer nsourfermion    !to store the number of external fermions
         integer nsourfermionbar !to store the number of external fermions
         integer nsourhiggs      !the number of external higgs particles
         integer nsourgaubosons  !the number of external "topbar" particles
         real*8  spinsour        !array containing the spin of the source
         real*8  spinsouraux     !array containing the spin of the source
         common/source/nsourhiggs(3),nsourgaubosons(ngaubos),
     >                 nsourfermion(3,4),nsourfermionbar(3,4)
         common/spin/spinsour(nmax),spinsouraux(nmax)
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
         real*8 cf3(nfer2)/2.,2.,1.,1./  !auxiliary variable to initialize the 
C                             array CONSTFERMION: 2=triplet 1=singlet the full 
C                             set of conventions is in subroutine COULOR 
         real*8 ch2(3)/2.,1.,1./ !same as above for CONSTHIGGS:
C                                2=scalar, 1=auxiliary see subroutine LORENTZ
         real*8 cg2(ngaubos)/3*5.,6*1.,2*6.,7.,3*1.,4*8.,2*1.,2*8./ !same as above for CONSTGAUBOSONS:
C  3=massive g.b., 5. auxiliary g.b., 6=massles g.b., 7 aux gluons,
C   8 X_munu aux gau bos, see subroutine LORENTZ
         real*8 cg3(ngaubos)/10*1.,2*3.,11*1./  !same as above for CONSTGAUBOSONS:
C                    1=singlet, 3=adjoint see subroutine COULOR
         integer nnaux
         parameter (nnaux=ngaubos**3)
         integer osg1(ngaubos,ngaubos,ngaubos)/nnaux*0./ !same as above for g.b. self
C         interaction see subroutines  LOROPER
         integer optmulti
         common/options/optmulti
C
C We read, from the file 'LABELINTERACTION.DAT' the labels of the
C interactions relevant to the given process. This speed up the the computation
C
C
C Saving variables
C
         save flagread,labvma,labyuk,labselfgau,labgauhg,nvma,nyuk
         save ngauhg,starthiggs,startgaubosons,nselfgau
         save stfermion
         save constfermionbar, constgaubosons,constfermion, consthiggs
         save cf3,ch2,cg2,osg1,cg3
C
            optmulti=1                         !warning, 0 for test pourpose
c           open (1,file='labelinteraction',status='old')
            if (optmulti.eq.1) then
             call readarrtwobytwo_h(labvma,100,5,nvma,1)
             call readarrtwobytwo_h(labyuk,10,4,nyuk,1)
             call readarrtwobytwo_h(labselfgau,50,3,nselfgau,1)
             call readarrtwobytwo_h(labgauhg,50,3,ngauhg,1)
            endif
c           close (1)
C
C  initializing some auxiliary array
C
          if (flagread.eq.0) then
           if(optmulti.eq.0) then
            open (1,file='labelinteraction',status='old')
             call readarrtwobytwo(labvma,100,5,nvma,1)
             call readarrtwobytwo(labyuk,10,4,nyuk,1)
             call readarrtwobytwo(labselfgau,50,3,nselfgau,1)
             call readarrtwobytwo(labgauhg,50,3,ngauhg,1)
            close (1)
           endif
           flagread=1
           osg1(1,2,3)=5
           osg1(10,2,3)=7
           osg1(4,2,3)=6
           osg1(5,1,1)=6
           osg1(5,1,10)=11
           osg1(5,10,10)=8
           osg1(5,2,3)=6
           osg1(6,1,2)=6
           osg1(6,10,2)=12
           osg1(7,1,3)=6
           osg1(7,10,3)=13
           osg1(8,2,2)=6
           osg1(9,3,3)=6
           osg1(11,11,11)=5
           osg1(12,11,11)=7
           osg1(13,1,3)=6
           osg1(14,1,2)=6
           osg1(15,1,1)=6
           osg1(16,2,3)=9
           osg1(17,10,10)=10
           osg1(17,1,10)=10
           osg1(18,1,2)=14
           osg1(19,3,10)=15
           osg1(19,10,3)=15
           osg1(18,1,3)=14
           osg1(19,2,10)=15
           osg1(19,10,2)=15
           osg1(20,1,1)=6
           osg1(21,10,10)=16
           osg1(22,1,1)=9
           osg1(23,10,10)=10
C
          endif
C
C  We first set to zero all the relevant arrays. Adding new fields the same has
C  to be done with the new arrays. Each newfield require an array NUMBnewfield
C
          jloop=nfer1*nfer2*dimnum
          call zeroarrayint(numbfermion,jloop)
          call zeroarrayint(numbfermionbar,jloop)
          jloop=nhigbos*dimnum
          call zeroarrayint(numbhiggs,jloop)
          jloop=ngaubos*dimnum
          call zeroarrayint(numbgaubosons,jloop)
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C Initializing the SM particles variables
C 
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C We than initialize the fields. The order is immaterial; the only 
C important point is that Fermions have to be initialized before Bosons
C
         countsour=1
C
CCCCCC   Initializing fermion fields  CCCCCCC
C
           do j2=1,nfer1                 !loop over family index
            do j1=1,nfer2                 !loop over family members
             constfermion(1,j1,j2)=massfermion(j2,j1)                 
             constfermion(5,j1,j2)=widthfermion(j2,j1)
             constfermion(2,j1,j2)=3. 
             constfermion(3,j1,j2)=cf3(j1)  
             constfermion(4,j1,j2)=100.+dfloat(4*(j2-1)+j1)   !particle label,
C                                                              fermions
C                                                will be labelled 101,...112
             if (nsourfermion(j2,j1).ne.0) then   
              do j3=countsour,countsour+nsourfermion(j2,j1)-1
               call initial(fermion(stfermion(j1)*dimmom+1,j2),
     >              momfermion(1,j1,j2),constfermion(1,j1,j2),
     >              numbfermion(1,j1,j2),j3,
     >            countsour,spinsour(j3))
              enddo
              countsour=countsour+nsourfermion(j2,j1)
C
             endif
C
            enddo
           enddo
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
CCCCCC   Initializing fermionbar fields  CCCCCCC
C
           do j1=1,nfer1                  !loop over family index
            do j2=1,nfer2                 !loop over family memebers
             constfermionbar(1,j2,j1)=massfermion(j1,j2)                 
             constfermionbar(5,j2,j1)=widthfermion(j1,j2)
             constfermionbar(2,j2,j1)=4. 
             constfermionbar(3,j2,j1)=cf3(j2) 
             constfermionbar(4,j2,j1)=200.+dfloat(4*(j1-1)+j2)   !particle 
C                               label,  fermionbars will be labelled 201,...212
             if (nsourfermionbar(j1,j2).ne.0) then   
              do j3=countsour,countsour+nsourfermionbar(j1,j2)-1
               call initial(fermionbar(stfermion(j2)*dimmom+1,j1)
     >           ,momfermionbar(1,j2,j1),constfermionbar(1,j2,j1)
     >           ,numbfermionbar(1,j2,j1),j3,
     >            countsour,spinsour(j3))
              enddo
              countsour=countsour+nsourfermionbar(j1,j2)
C
             endif
C
            enddo
           enddo 
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
CCCCCC   Initializing boson fields  CCCCCCC
C
C Initializing Higgs field. 
C
           do j1=1,nhigbos             !higgs and its auxiliary field
            consthiggs(1,j1)=masshiggs(j1)                !higgs mass 
            consthiggs(5,j1)=widthhiggs(j1)
            consthiggs(2,j1)=ch2(j1)
            consthiggs(3,j1)=1.                !coulor singlet (see subroutine 
C                                      COULOR for the full set of conventions
            consthiggs(4,j1)=300+j1                !particle label:
C                             301,302)=higgs,auxiliary-higgs
C                             101,...,112)=fermions
C                             201,...,212)=fermionsbar
C                             401,...,403)=Z,W^+,W^-,...,A
C### wishing to add a new particle the corresponding CONSTnew has to be
C### declared dimensioned and filled as above. The corresponding mass as well
            if (nsourhiggs(j1).ne.0) then       !NSOURHIGG contain the number
C                                      of external higgs field
C### wishing to add a new particle the corresponding NSOURnew has
C### to be declared (and "computed" in the subroutine ??????)
             do j2=countsour,countsour+nsourhiggs(j1)-1
              call initial(higgs(1,j1),momhiggs(1,j1),consthiggs(1,j1),
     >        numbhiggs(1,j1),j2,countsour,spinsour(j2))      
             enddo
C                    momenta configuration in the array MOM1. The array
C              NUMB1(j) contain the number of higgs field configurations
C              with J momenta contributing .The Arrays SPINSOUR and COLOURSOUR 
C                    contain the spin and the coulor of the external source 
C                    and are setted in the subroutine ???????
C### wishing to add a new particle the arrays:
C###  newfield, NUMBnewfield and MOMnewfield
C### have to be declared and dimensioned. MOMnewfield MUST BE setted to 0 at
C### the BEGINNING of this subroutine.
C### WARNING the dimension of each field are setted through a PARAMETER
C### statement. Each newfield array needs a variable DIMnewarray which
C###  has to be declared and initialized through a proper PARAMETER statement
C
             countsour=countsour+nsourhiggs(j1)
C 
            endif
C
           enddo
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
CCCCCC   Initializing gauge-boson fields  CCCCCCC
C
           do j1=1,ngaubos
            constgaubosons(1,j1)=massgaubosons(j1)                 
            constgaubosons(5,j1)=widthgaubosons(j1)
            constgaubosons(2,j1)=cg2(j1)                
            constgaubosons(3,j1)=cg3(j1)             
            constgaubosons(4,j1)=400. + dfloat(j1)                
            if (nsourgaubosons(j1).ne.0) then   
             do j2=countsour,countsour+nsourgaubosons(j1)-1
              call initial(gaubosons(startgaubosons(j1)*dimmom+1),
     >               momgaubosons(1,j1) ,constgaubosons(1,j1),  
     >               numbgaubosons(1,j1),j2,countsour,
     >               spinsour(j2))
             enddo
             countsour=countsour+nsourgaubosons(j1)
C
            endif
C
           enddo
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C Obtaining the fields configuration iterating the equation of motion
C and the matrix element from G
C
           elmat=0.   !It will contain the matrix element
C
           niteration=next/2           !number of iteration steps needed
C Notice that a priori  more are needed, however the last terms
C enters only linearly and therefore their contribution vanishes.
C
           do iteration=2,niteration+1   !loop to generate the iterations.
C the last run is needed to compute the matrix element
C###                        WARNING each new interaction term MUST
C###                        be INSIDE this loop
C
C Using the interaction terms to iterate the equation of motion
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C Higgs self-interaction: 
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
            operator(1)=1         !lorentz cubic scalar interaction without
C                    derivatives for the full set of convention see the
C                    subroutine LOROPER
            do j1=1,nhigbos
C
             if (abs(selfhiggs(j1)).gt.coupmin) then
C
              call compute(higgs(1,j1),   !The first 3 entries are the 3 fields
     >         higgs(1,1),                 !entering in the interaction. The 
     >         higgs(1,1), !ordering is fixed in subroutine LOROPER and COLOPER
     >         momhiggs(1,j1),  !The 4,5,6 entryes contains the corresponding
     >         momhiggs(1,1),   !configurations label. The orde MUST be
     >         momhiggs(1,1),   !the same chose for 1,2,3
     >         numbhiggs(1,j1),      !The 7,8,9 entries are arrays containing
     >         numbhiggs(1,1),      !additional information about the field
     >         numbhiggs(1,1),      !configuration. The order again as 1,2,3
     >         consthiggs(1,j1),    !Containing the mass the lorentz and coulor
     >         consthiggs(1,1),     !nature of the field. Again the order as
     >         consthiggs(1,1),           ! 1,2,3
     >         operator,                 !To identify the type of operator
     >         iteration,                !Iteration step
     >         selfhiggs(j1),            !Interaction coupling constant
     >         elmat,                    !matrix element
     >         niteration)              !number of perturbative iteration steps

             endif
C
            enddo
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C Yukawa interactions
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
            operator(1)=2     
C
           if (nyuk.gt.0) then
            do jloop=1,nyuk
             j1=labyuk(jloop,1)
             j2=labyuk(jloop,2)
             j3=labyuk(jloop,3)
             j4=labyuk(jloop,4)
C
                 call compute(higgs(1,1),
     >            fermionbar(stfermion(j2)*dimmom+1,j1)        
     >            ,fermion(stfermion(j4)*dimmom+1,j3),momhiggs(1,1),
     >            momfermionbar(1,j2,j1),momfermion(1,j4,j3),
     >            numbhiggs(1,1),numbfermionbar(1,j2,j1),
     >            numbfermion(1,j4,j3),consthiggs(1,1),
     >            constfermionbar(1,j2,j1),constfermion(1,j4,j3),
     >            operator,iteration,yukawa(j1,j2,j3,j4),elmat,
     >                                                    niteration)  
C
            enddo
           endif
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C V-A interactions with electroweak gauge bosons
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
           operator(1)=3     
           if(nvma.gt.0) then      
            do jloop=1,nvma
              j5=labvma(jloop,1)
              j1=labvma(jloop,2)
              j2=labvma(jloop,3)
              j3=labvma(jloop,4)
              j4=labvma(jloop,5)
              a=vectorial(j5,j1,j2,j3,j4)
              b=assial(j5,j1,j2,j3,j4)
              count1=j5
              count2=j2
              c=(1.,0.)
              call compute(gaubosons(startgaubosons(j5)*dimmom+1)
     >              ,fermionbar(stfermion(j2)*dimmom+1,j1),
     >              fermion(stfermion(j4)*dimmom+1,j3),
     >                momgaubosons(1,j5)      
     >              ,momfermionbar(1,j2,j1),momfermion(1,j4,j3),
     >              numbgaubosons(1,j5),numbfermionbar(1,j2,j1),
     >              numbfermion(1,j4,j3),constgaubosons(1,j5),
     >              constfermionbar(1,j2,j1),constfermion(1,j4,j3),
     >                         operator,iteration,c,elmat,niteration)
C
            enddo
           endif
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C gauge bosons self-interactions with electroweak gauge bosons
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
           if (nselfgau.gt.0) then
            do jloop=1,nselfgau              !loop over gauge bosons
C
             j5=labselfgau(jloop,1)
             j1=labselfgau(jloop,2)
             j3=labselfgau(jloop,3)
C
             operator(1)=osg1(j5,j1,j3)
              call compute(gaubosons(startgaubosons(j5)*dimmom+1),
     >             gaubosons(startgaubosons(j1)*dimmom+1), 
     >             gaubosons(startgaubosons(j3)*dimmom+1),
     .             momgaubosons(1,j5)
     >             ,momgaubosons(1,j1),momgaubosons(1,j3),
     >             numbgaubosons(1,j5),numbgaubosons(1,j1)
     >             ,numbgaubosons(1,j3),constgaubosons(1,j5),
     >             constgaubosons(1,j1),constgaubosons(1,j3),
     >             operator,iteration,selfgauge(j5,j1,j3),
     >             elmat,niteration)
C
            enddo
C
           endif
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C gauge bosons -higgs  interactions with electroweak gauge bosons
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
           if (ngauhg.gt.0) then
            do jloop=1,ngauhg              !loop over higgs bosons
             j5=labgauhg(jloop,1)
             j1=labgauhg(jloop,2)
             j3=labgauhg(jloop,3)
C
             operator(1)=6
             call compute(higgs(1,j5),
     >              gaubosons(startgaubosons(j1)*dimmom+1)      
     >             ,gaubosons(startgaubosons(j3)*dimmom+1),
     >              momhiggs(1,j5),     
     >             momgaubosons(1,j1),momgaubosons(1,j3),
     >             numbhiggs(1,j5),numbgaubosons(1,j1),
     >             numbgaubosons(1,j3),consthiggs(1,j5),
     >             constgaubosons(1,j1),constgaubosons(1,j3),
     >             operator,iteration,higgsgauge(j5,j1,j3),
     >             elmat,niteration)
C
            enddo
C
           endif
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C### wishing to add new interaction terms:
C### repeat the above statements
C
C Now we need to interchange, because of the way the SUBROUTINE INTERACTION
C works, all the informations (FIELD, MOM, NUMB), obtained at the step
C ITERATION, among each field and its conjugate.
C ### This has to be done for each new complex field. Add it here
C ### WARNING, it has to be placed HERE, AFTER all the interaction terms
C ### and INSIDE the loop
C
          if(iteration.le.niteration) then
C
CCCCCC Exchanging fermion and fermionbar fields  CCCCCCC
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
           do j1=1,nfer1                  !loop over family index
            do j2=1,nfer2                 !loop over family memebers
C
             call exchange(fermionbar(stfermion(j2)*dimmom+1,j1),
     >         fermion(stfermion(j2)*dimmom+1,j1)
     >         ,momfermionbar(1,j2,j1)
     >         ,momfermion(1,j2,j1),numbfermionbar(1,j2,j1),
     >         numbfermion(1,j2,j1),constfermion(1,j2,j1),iteration)
C
            enddo
           enddo 

C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
CCCCCC Exchanging W^+ and W^-, X and Y  fields  CCCCCCC
C
            do j1=1,4
C
             call exchange(gaubosons(startgaubosons(2*j1)*dimmom+1),
     >         gaubosons(startgaubosons(2*j1+1)*dimmom+1),
     >          momgaubosons(1,2*j1)
     >         ,momgaubosons(1,2*j1+1),numbgaubosons(1,2*j1),
     >         numbgaubosons(1,2*j1+1),constgaubosons(1,2*j1)
     >                                                      ,iteration)
C
            enddo
            do j1=7,7
C
             call exchange(gaubosons(startgaubosons(2*j1)*dimmom+1),
     >         gaubosons(startgaubosons(2*j1-1)*dimmom+1),
     >          momgaubosons(1,2*j1)
     >         ,momgaubosons(1,2*j1-1),numbgaubosons(1,2*j1),
     >         numbgaubosons(1,2*j1-1),constgaubosons(1,2*j1)
     >                                                      ,iteration)
C
            enddo
            do j1=8,11
C
             call exchange(gaubosons(startgaubosons(2*j1)*dimmom+1),
     >         gaubosons(startgaubosons(2*j1+1)*dimmom+1),
     >          momgaubosons(1,2*j1)
     >         ,momgaubosons(1,2*j1+1),numbgaubosons(1,2*j1),
     >         numbgaubosons(1,2*j1+1),constgaubosons(1,2*j1)
     >                                                      ,iteration)
C
            enddo
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
CCCCCC Exchanging X_h and Y_h fields  CCCCCCC
C
            do j1=1,1
C
             call exchange(higgs(1,2*j1),higgs(1,2*j1+1),
     >         momhiggs(1,2*j1),momhiggs(1,2*j1+1),numbhiggs(1,2*j1)
     >         ,numbhiggs(1,2*j1+1),consthiggs(1,2*j1),iteration)
C
            enddo
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
            endif
           enddo   !loop to generate the iterations.
C###                        WARNING each new interaction term MUST
C###                        be INSIDE this loop
C
           if (write.eq.0) then
            write(16,*)'numbhiggs,'
            write(16,1)numbhiggs
            write(16,*)'numbgaubosons,'
            write(16,1)numbgaubosons
            write(16,*)'numbfermion,'
            write(16,1)numbfermion
            write(16,*)'numbfermionbar,'
            write(16,1)numbfermionbar
 1          format(4(2x,i3))
            write=1
           endif
C
           return
           end
C***********************************************************************
          subroutine initial(field1,mom1,const1,numb1,npart,
     >            countsour,spinsour)
C***********************************************************************
C
C This subroutine perform the perturbative iteration.
C 
          implicit none
C
          integer dimfiel    !dimension of the array FIELD1
          integer dimmom     !dimension of the array MOM1
          integer dimnum     !dimension of the array NUMB1
          integer dimcons    !dimension of the array CONST1
          integer nlormax
          integer nmax       !maximum number of external particles
          parameter (nlormax=16) !maximum number of lorentz degrees of freedom
C                                of the field of the theory. change here
          parameter (nmax=8)   !N=8=maximum number of external particles. change here
          parameter (dimmom=(2**nmax-2)/2)     
          parameter (dimfiel=nlormax*dimmom)  
          parameter (dimcons=5)      
          parameter (dimnum=nmax/2)      
          integer countsour  !to count the number of already initilaized
C                               sources
          integer j1          !loop index
          integer label       !label for setting the array index
          integer menu        !to find out the lorentz character of the particle
          integer mom1(dimmom)        !array containing a label for each indipendent
C                        momentum configuration.
          integer nlor1       !to store the "lorentz" index  of the particle
          integer npart      !the number of initialized external particles
C                             of the current type
          integer numb1(dimnum)  !NUMB1(j) contains the number of particle
C
          real*8 const1(dimcons)    !containing the characteristic of the higgs field:
C                              1) mass
C                              2) Lorentz nature 
C                              3) coulor
C                              4) particle "name" see ??? for the conventions
          real*8  internal    !array of flags to decide wether the particle is
C                              internal or external
          real*8 mass         !containing the mass of the initializing
C                              external particle 
          real*8 mom(4)       !array containing the momenta of the initializing
C                              external particle 
          real*8 momenta !array containing the momenta of the external particles 
          real*8 spinsour   !containing the spin of the source
C                              configurations with j momenta
C
          complex*16 field1(dimfiel)   !array containing the field configurations
          complex*16 fieldaux(4) !array containing the individual field 
C                                                                configuration
C
          common/momenta/momenta(nmax,4),internal(nmax)
C
          integer nspn
C
C initializing mom1
C
           mom1(npart-countsour+1)=npart
C
C initializing numb1
C
           numb1(1)=numb1(1)+1
C
C initializing field1
C
           menu=nint(const1(2))
           do j1=1,4
            mom(j1)=momenta(npart,j1)*internal(npart)
           enddo
C                                          degrees of freedom
           goto(1,2,3,4,5,6),menu
C
           write(6,*)'I have failed to find the proper label for the'
           write(6,*)'source labelled with lorentz label',menu
           stop
C
 1         write(6,*) 'I have been asked to initialize an auxiliary'
           write(6,*) 'field. I cannot do it since no source exists.'  !this should not happen
           stop
C
 2         fieldaux(1)=-1.
           goto 999
C
 3         mass=const1(1)
           nspn=nint(spinsour*100.)
           call  fermionsources(nspn,fieldaux,mom,mass)
           goto 999
C
 4         mass=const1(1)
           nspn=nint(spinsour*100.)
           call  fermionbarsources(nspn,fieldaux,mom,mass)
           goto 999
C
 5         mass=const1(1)
           call  sourcemassboson(spinsour,fieldaux,mom,mass)
           goto 999
C
 6         mass=const1(1)
           call  sourcemassboson(spinsour,fieldaux,mom,mass)
           goto 999
C
C### add  new particles here
C
 999       call lorentz(const1(2),nlor1)
           label=nlor1*(numb1(1)-1)
           do j1=1,nlor1
            field1(j1+label)=fieldaux(j1)
           enddo
           return
C
           end
C***********************************************************************
          subroutine interaction(field1,field2,field3,mom1,mom2,mom3,
     >     numb1,numb2,numb3,                   
     >     const1,const2,const3,operator,iteration,couplingconst)
C***********************************************************************
C
C This subroutine given three field configuration FIELD1, FIELD2, FIELD3,
C whose corresponding parents momenta are recorded in MOM1, MOM2, MOM3,
C return the new field configurations produced at the relevant ITERATION
C step.
C
          implicit none
C
          integer dimfiel      !dimension of the array field1,2,3
          integer dimnum       !dimension of the array numb1,2,3
          integer dimmom       !dimension of the array mom1,2,3
          integer dimcons      !dimension of the array cons1,2,3
          integer dimop        !dimension of the array operator
          integer nlormax    !maximum number of lorentz degrees of freedom, change here
          integer ncolmax    !maximum number of coulor degrees of freedom,change hrere
          integer nmax
C                             of the fields of the theory. change here
          parameter (ncolmax=8)
          parameter (nlormax=16)
          parameter (nmax=8)   !maximum number of external particles. change here
          parameter (dimcons=5)      !number of needed particle caracteristics.
          parameter (dimmom=(2**nmax-2)/2) !number of allowed momentum 
          parameter (dimfiel=ncolmax*nlormax*dimmom)  !this will set the dimensions for the 
C                     array for the different fields. 
          parameter (dimnum=nmax/2)      !storing the number of configuration
          parameter (dimop=1)
C
          integer e12, e13, e23, e123           !flags to check fields equality
          integer extr1         !loop extremum
          integer iteration   !storing the present iteration stage
          integer mom1(dimmom), mom2(dimmom), mom3(dimmom)  !arrays containing 
C                    a label for each indipendent momentum configuration. This 
C                    number will allow to determine the complete configuration
          integer multiplicity !flag to obtain the right combinatorial factors
          integer niteration !number of iteration steps
          integer nlor1      !storing the number of lorentz degrees of freedom
          integer numb1(dimnum), numb2(dimnum), numb3(dimnum) !storing 
C                        the number of configuration according to the number 
C                       of momenta contributing to the configuration under exam
          integer operator(dimop)    !a flag to identify the type of operator
          integer orderfield(3) !containing the ordering of FIELD1, FIELD2 
C           and FIELD3 to pick up the correct colour and lorentz matrix element
C
          real*8 const1(dimcons), const2(dimcons), const3(dimcons) !containing 
C                                              the characteristic of the field:
          real*8 weight      !to help in computing the square of equal fields
C
          complex*16 couplingconst
          complex*16 field1(dimfiel), field2(dimfiel), field3(dimfiel)
C arrays containing the field configuration of of the three field to multiply
C
           common/combinr/weight
           common/combini/multiplicity
           common/iter/niteration
C
           e12=1
           e13=1
           e23=1
           e123=1
           if (nint(const1(4)).ne.nint(const2(4))) e12=0
           if (nint(const1(4)).ne.nint(const3(4))) e13=0
           if (nint(const2(4)).ne.nint(const3(4))) e23=0
           e123=e12*e13            
C
C Computing the contribution to field1 equation of motion
C
           multiplicity=1+e23
           weight=1.
           if(e13.eq.1.or.e12.eq.1)weight=2.
           if(e123.eq.1)weight=3.
C
           orderfield(1)=1     !setting the coulor order of the fields
           orderfield(2)=2
           orderfield(3)=3
C
           call prodinteraction(field1,field2,field3, mom1,mom2,mom3,
     >     numb1,numb2,numb3,const1,const2,const3,operator,                  
     >     iteration,couplingconst,orderfield)
C
C Computing the contribution to field2 equation of motion
C
           if (e12.eq.0) then        !only in this case we need to compute
C                                    the iteration
            multiplicity=1+e13
            weight=1.
            if(e23.eq.1)weight=2.
C
            orderfield(1)=2     !setting the coulor order of the fields
            orderfield(2)=1
            orderfield(3)=3
C
            call prodinteraction(field2,field1,field3,mom2,mom1,
     >      mom3,numb2,numb1,numb3,const2,const1,const3,operator,         
     >      iteration,couplingconst,orderfield)
           else
            if (numb1(iteration).ne.0) then
             call lorentz(const1(2),nlor1)    ! the number of lorentz degrees of freedom NLOR1
             call sumintegarr(numb1,iteration-1,extr1)
C
             call equalintarrays(numb1,numb2,dimnum)
             call equalintarrays(mom1(extr1+1),mom2(extr1+1),
     >                           numb1(iteration))
             extr1=extr1*nlor1
             call equalcomparrays(field1(extr1+1),field2(extr1+1),
     >                           numb1(iteration)*nlor1)
            endif
           endif
C
C Computing the contribution to field3 equation of motion
C
           if (e13.eq.0) then        !only in this case we need to compute
C                                    the iteration
            if (e23.eq.0) then        !only in this case we need to compute
C                                    the iteration
             multiplicity=1+e12
             weight=1.
C
             orderfield(1)=3     !setting the coulor order of the fields
             orderfield(2)=1
             orderfield(3)=2
C
             call prodinteraction(field3,field1,field2,mom3,mom1,
     >       mom2,numb3,numb1,numb2,const3,const1,const2,operator,      
     >       iteration,couplingconst,orderfield)
            else
             call lorentz(const2(2),nlor1)    
             call sumintegarr(numb2,iteration-1,extr1)
C
             call equalintarrays(numb2,numb3,dimnum)
             call equalintarrays(mom2(extr1+1),mom3(extr1+1),
     >                           numb2(iteration))
             extr1=extr1*nlor1
             call equalcomparrays(field2(extr1+1),field3(extr1+1),
     >                           numb2(iteration)*nlor1)
C
            endif
C
           else
C
            call lorentz(const1(2),nlor1)    
            call sumintegarr(numb1,iteration-1,extr1)
C
            call equalintarrays(numb1,numb2,dimnum)
            call equalintarrays(mom1(extr1+1),mom2(extr1+1),
     >                           numb1(iteration))
            extr1=extr1*nlor1
            call equalcomparrays(field1(extr1+1),field2(extr1+1),
     >                           numb1(iteration)*nlor1)
           endif
C
           return
           end
C***********************************************************************
          subroutine prodinteraction(field1,field2,field3,mom1,mom2,
     >     mom3,numb1,numb2,numb3,const1,const2,const3,operator,       
     >     iteration,couplingconst,orderfield)
C***********************************************************************
C
C This subroutine given three field configurations FIELD1, FIELD2, FIELD3,
C whose corresponding parents momenta are recorded in MOM1, MOM2, MOM3,
C return the new field configurations produced at the relevant ITERATION
C step.
C
          implicit none
C
          integer nlormax    !maximum number of lorentz degrees of freedom
C                             of the fields of the theory. change here
          integer nmax
          integer dimamp       !dimension of the array newamplitude
          integer dimfiel      !dimension of the array field1,2,3
          integer dimcons      !dimension of the array cons1,2,3
          integer dimmom       !dimension of the array mom1,2,3
          integer dimnum       !dimension of the array numb1,2,3
          integer dimop        !dimension of the array operator
          parameter (nmax=8) !maximum number of external particles. change here
          parameter (nlormax=16)
          parameter (dimamp=nlormax) 
          parameter (dimcons=5)     !number of needed particle caracteristics.
          parameter (dimmom=(2**nmax-2)/2)     
          parameter (dimfiel=nlormax*dimmom) 
          parameter (dimnum=nmax/2)      
          parameter (dimop=1)     
          integer addition    !flag to check wether a new configuration
C                       or a new contribution to an old one has been computed
          integer extrem1,extrem2          !loop lower and upper extrema
          integer ex1,ex2,ex3   !to store the number of excitation of field1,2,3
          integer iteration   !storing the present iteration stage
          integer j1, j2, j3, j4, j5, j6, j8          !loop index
          integer label,label1  !label for the arrays ALFA and BETA
          integer labelstart2  !to set label index properly
          integer mom1(dimmom),mom2(dimmom),mom3(dimmom) !array containing a number for each indipendent
C                              momentum configuration. This numbers will allow
C                              to determine the complete configuration   
          integer momaux(6)       !containing the label of the momenta currently
C                               used
          integer multiplicity !flag to obtain the right combinatorial factors
          integer nadd        !array label
          integer newc       !to store a new label number
          integer nlor1,nlor2,nlor3       !storing the number of lorentz degrees of freedom
C                             of field1
          integer niteration !number of iteration steps
          integer nstart2,nstart3    !storing the label of the relevant amplitude
C                             for te array field1
          integer numb1(dimnum),numb2(dimnum),numb3(dimnum) !storing the number of configuration according
C                                           to the number of momenta contributing
          integer operator(dimop) !a flag to identify the type of operator, up to
C                              now only one different operators are know:
C                              1)  A h h   (h=higgs, A auxiliar higgs)
          integer orderfield(3) !containing the ordering of FIELD1,
C                              FIELD2 and FIELD3 to pick up the correct
C                              colour and lorentz matrix element
          integer pos        !flag to determine the loop extrema
          integer positio        !flag to determine the loop extrema
          integer st(3)/0,2,4/
          integer prodconfprod(2,(2**nmax-2)/2,(2**nmax-2)/2) !array computed in INITCOMPCONF
          integer n1,n2,start(nmax/2)   !to compute the labels for PRODCONFPROD
          common/prodprod/prodconfprod
          common/strt/start
C
          real*8 const1(dimcons), const2(dimcons), const3(dimcons) 
          real*8 perm        !sign of the fermion permutation
          real*8 sign      !correct sign for the momenta
C
          real*8 weig        !containing the combinatorial factor
          real*8 weight      !to help in computing the square of equal fields
          real*8 ww          !to store the result of intermediate products
C
          complex*16 alfaprime(nlormax**3)  !storing the lorentz interaction matrix for
C                              subroutine LOROPER
          complex*16 aux(nlormax**2)    !auxiliar variable, NLORMAX lorentz degrees of 
C                                freedom at most.
          complex*16 couplingconst  !coupling constant
          complex*16 field1(dimfiel),field2(dimfiel), field3(dimfiel) !arrays containing the field configuration of one  
C                                               of the three field to multiply
          complex*16 newamplitude(dimamp)  !storing the result of the multiplication
          complex*16 newamplitudeprime(dimamp)  !storing the result of the multiplication
          complex*16 propaux(nlormax**2)     !propagator returned by the subroutine PROPAGATOR
          complex*16 zero/(0.,0.)/
C
          common/combinr/weight
          common/combini/multiplicity
          common/iter/niteration
          common/sign/sign(3)            !correct sign for the four momenta
C
C Static variables
C
          save zero
C
C
C Computing the number of configuration of the field 2,3 contributing
C at the present perturbative stage.
C
            call sumintegarr(numb1,iteration-1,ex1)
            call sumintegarr(numb2,iteration-1,ex2)
            call sumintegarr(numb3,iteration-1,ex3)
C
C  We now iterate field1
C
           if (ex2.ne.0.and.ex3.ne.0) then !do it only if neither field2 nor 
C                                          field3 are empty
C           
C
C Pickig up the particle characteristics. Outside the loop is less expensive
C
            call lorentz(const1(2),nlor1)    !returning the number of lorentz
C                                         degrees of freedom of FIELD1
            call lorentz(const2(2),nlor2)
            call lorentz(const3(2),nlor3)
C
            pos=1                           
            positio=numb2(pos)
            do j1=1,ex2                !loop over the field2 configuration
C
C Calculating the configurations of field3 contributing to the sum
C
C The pourpose of the following lines is to store in POS the number
C of momenta contributing to the field2 configuration. This in turn
C allow to select only the configuration in field3 with a number of
C momenta ITERATION-POS. The variable positio stores the total
C number of configuration with less than POS momenta allowing for the check
C
             do while (j1.gt.positio) 
              pos=pos+1
              positio=positio+numb2(pos)
             enddo
C
             extrem1=0
             if(iteration.gt.pos-1)
     >          call sumintegarr(numb3,iteration-pos-1,extrem1)
             extrem1=1+extrem1
             extrem2=numb3(iteration-pos)-1 +extrem1
C
             weig=1
             if (multiplicity.ne.1) then    !two equal fields
              weig=2.
              extrem1=max(extrem1,j1+1)     !avoiding doublecounting
             endif
C
             if (extrem2.ge.extrem1) then
C
              do j2=extrem1,extrem2
C
              n1=start(pos)+mom2(j1)
              n2=start(iteration-pos)+mom3(j2)
              newc=prodconfprod(1,n1,n2)
              perm=prodconfprod(2,n1,n2) !to compose the two momenta configuration. If NEWC is 0
C                               it means that the no configuration is possible
C                               as a product of the two. Otherwise NEWC carries
C                               the label of the new configuration. PERM will
C                               return the sign of the fermion permutation
C                               PRODCONFPROD is computed in INITCOMPCONF
C
               if (newc.ne.0) then  !an acceptable configuration has been  
C                                     created
C
C Extracting the amplitude of the present configuration
C
                momaux(st(orderfield(1))+1)=iteration
                momaux(st(orderfield(1))+2)=newc
                momaux(st(orderfield(2))+1)=pos
                momaux(st(orderfield(2))+2)=mom2(j1)
                momaux(st(orderfield(3))+1)=iteration-pos
                momaux(st(orderfield(3))+2)=mom3(j2)
                sign(orderfield(1))=-1.      !the sign of the momenta of this 
C                                            configuration must be reversed
                sign(orderfield(2))=1.
                sign(orderfield(3))=1.
                call loroper(operator(1),alfaprime,momaux)  !lorentz interaction
C                                                           matrix
                call reorder(orderfield(1),alfaprime,nlor1,nlor2,nlor3)
C
                    nstart2=(j1-1)*nlor2
                    nstart3=nlor3*(j2-1)
C
                    label=0
                    label1=0
                    do j4=1,nlor1  !looping over the lorentz index of particle 1
                     newamplitude(j4)=0.                     
                     do j6=nstart2+1,nstart2+nlor2
                      if(field2(j6).ne.zero) then
                       label1=label1+1
                       aux(label1)=zero
                       do j8=nstart3+1,nstart3+nlor3
C
C Performing the product
C
C
C Looking for the lorentz coefficient alfa
C
                        label=label+1
                        aux(label1)=alfaprime(label)*
     >                               field3(j8)+aux(label1)
                       enddo  
                       newamplitude(j4)=newamplitude(j4)       
     >                                + aux(label1)*field2(j6)
                      else
                       label=label+nlor2
                      endif
                     enddo
                     newamplitude(j4)=newamplitude(j4)
                    enddo
C
C  Multiplying for the inverse propagator                            
C
                call propagator (const1(2),const1(1),const1(5),
     >                  propaux,newc,iteration)!PROP will return the propagator
C
                label=0
                ww=weight*weig*perm   !outside the loop is cheaper
                 do j4=1,nlor1
                  newamplitudeprime(j4)=0.
                  do j5=1,nlor1
                   label=label+1
                   newamplitudeprime(j4)=ww*
     >                   propaux(label)*newamplitude(j5)
     >                   +newamplitudeprime(j4)
                  enddo
                 enddo
C
                addition=0            !checking if a new configuration has
C                         been obtained or a new contribution to an old one
                if(numb1(iteration).ne.0) then
                 do j3=ex1+1,numb1(iteration)+ex1
                  if (newc.eq.mom1(j3)) addition = j3
                 enddo
                endif
                if (addition.eq.0) then      ! a new configuration
                 numb1(iteration)=numb1(iteration)+1
                 labelstart2=(ex1+numb1(iteration)-1)*nlor1
                 do j3=1,nlor1
                  field1(labelstart2+j3)=newamplitudeprime(j3)
     >                                  *couplingconst
                 enddo
                 mom1(ex1+numb1(iteration))=newc
                else                        ! a new contribution to an old
C                                           configuration
                 nadd=(addition-1)*nlor1
                 do j3=1,nlor1
                  field1(nadd+j3)=newamplitudeprime(j3)
     >                     *couplingconst +field1(nadd+j3)
                 enddo
                endif
C
               endif
C
              enddo
C
             endif
C
            enddo          
C
           endif
C
           return
           end
C***********************************************************************
          subroutine lagint(field1,field2,field3,mom1,mom2,mom3,
     >     numb1,numb2,numb3,const1,const2,const3,operator,
     >     couplingconst,elmataux)
C***********************************************************************
C
C This subroutine given three field configuration FIELD1, FIELD2, FIELD3,
C whose corresponding parents momenta are recorded in MOM1, MOM2, MOM3,
C return the new contribution to the amplitude in ELAMATAUX
C
          implicit none
C
          integer dimfiel      !dimension of the array field1,2,3
          integer dimcons      !dimension of the array cons1,2,3
          integer dimmom       !dimension of the array mom1,2,3
          integer dimnum       !dimension of the array numb1,2,3
          integer dimop        !dimension of the array operator
          integer nlormax    !maximum number of lorentz degrees of freedom
C                             of the fields of the theory. change here
          integer nmax
          parameter (nlormax=16)
          parameter (nmax=8)       !maximum number of external particles, change here 
          parameter (dimcons=5)      
          parameter (dimmom=(2**nmax-2)/2)     
          parameter (dimfiel=nlormax*dimmom)  
          parameter (dimnum=nmax/2)      
          parameter (dimop=1)     
C
          integer e12         !flag to chek field1,2 equality
          integer e23         !flag to chek field2,3 equality
          integer e123        !flag to chek field1,2,3 equality
          integer extrem1     !loop lower extremum
          integer extrem2     !loop upper extremum
          integer ex1         !to store the number of excitation of field1
          integer ex2         
          integer ex3
          integer find1       !flag to find the field3 configuration
          integer indaux
          integer j1,j2,j3,j4,j6,j8          !loop index
          integer label      !label for the arrays ALFA abd BETA
          integer label3     !to store the label of field3
          integer mom1(dimmom),mom2(dimmom),mom3(dimmom)       !array containing a number for each indipendent
C                              momentum configuration. This numbers will allow
C                              to determine the complete configuration   
          integer momaux(6)  !storing the labels of the three momenta currently
C                            under use
          integer newc       !to store a new label number
          integer next       !number of external particle
          integer nfermion
          integer nlor1,nlor2,nlor3      !storing the number of lorentz degrees of freedom
C                             of field1
          integer nstart1,nstart2,nstart3    !storing the label of the relevant amplitude
C                             for the array field1
          integer numb1(dimnum),numb2(dimnum),numb3(dimnum)      !storing the number of configuration according
          integer operator(dimop)    !a flag to identify the type of operator, up to
          integer pos1,pos2,pos3        !flag to determine the loop extrema
          integer positio1,positio2        !flag to determine the loop extrema
          integer prodconflag(2,(2**nmax-2)/2,(2**nmax-2)/2)
          integer n1,n2,start(nmax/2)         !to compute PRODCONFLAG labels
C
          real*8 const1(dimcons),const2(dimcons),const3(dimcons)
          real*8 perm         !the sign of the fermion permutation
C                              now only one different operators are know:
          real*8 sign         !to be poassed to the subroutine LOROPER
C                              1)  A h h   (h=higgs, A auxiliar higgs)
          real*8 weight      !to help in computing the square of equal fields
C
          complex*16 alfaprime (nlormax**3)   !storing the lorentz interaction matrix for
C                              subroutine LOROPER
          complex*16 aux1,aux2,aux3 !auxiliar variables. 
C
          complex*16 couplingconst !coupling constant
          complex*16  elmataux     !containing the contribution to the amplitude
          complex*16 field1(dimfiel),field2(dimfiel),field3(dimfiel)   !array containing the field configuration of one  
C                              of the three fields to multiply
          common/prodlag/prodconflag
          common/strt/start
          complex*16 zero/(0.,0.)/
          common/external/next,nfermion  !containing the number of external
C                                       particles from the subroutine ?????????
          common/sign/sign(3)            !correct sign for the four momenta
C
C Static variables
C
          save zero
C
C
           elmataux=0
C
C Setting flags to manage products of equal fields
C
           e12=1
           if (const1(4).ne.const2(4)) e12=0
           e23=1
           if (const3(4).ne.const2(4)) e23=0
           e123=e12*e23
           weight=1
           if(e12.eq.1.or.e23.eq.1) weight = 2.
           if(e123.eq.1) weight = 6.
C
C Computing the number of configuration of the field 2,3 contributing
C
           call sumintegarr(numb1,dimnum,ex1)
           call sumintegarr(numb2,dimnum,ex2)
           call sumintegarr(numb3,dimnum,ex3)
C
C  We now iterate field1
C
           if (ex1.ne.0.and.ex2.ne.0.and.ex3.ne.0) then !do it only if neither field2 nor 
C                                          field3 are empty           
C
C Pickig up the particle characteristics. Outside the loop is less expensive
C
            call lorentz(const1(2),nlor1)    !returning the number of lorentz
C                                         degrees of freedom of FIELD1
            call lorentz(const2(2),nlor2)
            call lorentz(const3(2),nlor3)
C
            pos1=1                           
            positio1=numb1(pos1)
            do j1=1,ex1                !loop over the field1 configuration
C
C Calculating the configurations of field3 contributing to the sum
C
C The pourpose of the following lines is to store in POS1 the number
C of momenta contributing to the field2 configuration. 
C
             do while (j1.gt.positio1) 
              pos1=pos1+1
              positio1=positio1+numb1(pos1)
             enddo
C
             pos2=1                           
             positio2=numb2(pos2)
             extrem1=1
             if (e12.eq.1) then    !field1 and 2 equal
              extrem1=j1+1         !avoiding to repeat the same computation
              if(extrem1.le.ex2) then
               do while(extrem1.gt.positio2)
                pos2=pos2+1
                positio2=numb2(pos2)+positio2
               enddo
              endif
             endif
             do while (next-pos1-pos2.gt.dimnum) 
              pos2=pos2+1
              positio2=positio2+numb2(pos2)
             enddo
             j2=max(extrem1,positio2-numb2(pos2)+1)
             do while(pos1+pos2.lt.next.and.j2.le.ex2) !loop over field1
              do while (j2-positio2.gt.0) 
               pos2=pos2+1
               positio2=positio2+numb2(pos2)
              enddo
              pos3=next-pos1-pos2  !number of momenta of the third fields
              if(pos3.gt.0) then
               if(numb3(pos3).gt.0) then !only in this case a non zero value is
C                                       possible
                n1=start(pos1)+mom1(j1)
                n2=start(pos2)+mom2(j2)
                newc=prodconflag(1,n1,n2)
                perm=prodconflag(2,n1,n2)    !to  compose the two momenta configuration. If NEWC is 0
C                               it means that the no configuration is possible
C                               as a product of the two. Otherwise NEWC carries
C                               the label of the new configuration. PERM is
C                               the sign of the fermion permutation. 
C
                if (e23.eq.1) then
                 if (pos3.lt.pos2) newc=0
                 if (pos3.eq.pos2.and.newc.lt.mom2(j2)) newc=0
                endif
                if (newc.ne.0) then  !an acceptable configuration has been  
C                                     created
C
C Now NEWC contain the label of the configuration conf1
C
                 extrem2=0
                 if (pos3.gt.1) 
     >               call sumintegarr(numb3,pos3-1,extrem2)
                 extrem2=0+extrem2
C
                 j3=extrem2                 !finding the amplitude of the
                 find1=0                      !third configuration
                 do while(find1.eq.0.and.j3.lt.extrem2+numb3(pos3)) 
                  j3=j3+1
                  if(mom3(j3).eq.newc) find1=1
                 enddo
                 if (find1.eq.1) then
                  label3=j3
C
C Extracting the amplitude of the present configuration
C
                  momaux(1)=pos1     !containing the label of the present
                  momaux(2)=mom1(j1) !momenta configuration for the subroutine
                  momaux(3)=pos2     !LOROPER
                  momaux(4)=mom2(j2)
                  momaux(5)=pos3
                  momaux(6)=newc
C
                  sign(1)=1.      !all the momenta configuration we pass to 
                  sign(2)=1.      !the subroutine LOROPER shoul keep the
                  sign(3)=1.      !same sign for the momenta
                  call loroper(operator(1),alfaprime,momaux)!lorentz 
C                                                           interaction matrix
C
                  aux3=0.
                  nstart1=(j1-1)*nlor1
                  nstart2=nlor2*(j2-1)
                  nstart3=(label3-1)*nlor3
                      label=0
                      indaux=nlor2*nlor3
                      do j4=nstart1+1,nstart1+nlor1      !looping over the lorentz index of particle 1
                       if (field1(j4).ne.zero) then
                        aux2=zero
                        do j6=nstart2+1,nstart2+nlor2
                         if (field2(j6).ne.zero) then
                          aux1=zero
                          do j8=nstart3+1,nstart3+nlor3
                           label=label+1
                           aux1=aux1+
     >                          alfaprime(label)*field3(j8)
                          enddo  
                          aux2=aux2+
     >                            aux1*field2(j6)
                         else
                          label=label+nlor3
                         endif
                        enddo
                        aux3=aux3+aux2*field1(j4)
                       else
                        label=label+indaux
                       endif
                      enddo
C
                  elmataux=elmataux+aux3*weight*perm
C
                 endif
C
                endif
C
               endif
C
              endif
C
              j2=j2+1
             enddo
C
            enddo          
C
           endif
C
           elmataux=elmataux*couplingconst
C       
           return
           end
C***********************************************************************
          subroutine propagator (c1,mm1,gam1,prop,newc,iteration)   
C***********************************************************************
C
C Returns the inverse propagator of lorentz index LOR1 LOR2 in the
C variable PROP for the particle C1 with momentum defined by NEWC
C
          implicit none
C
          integer iteration     !iteration number
          integer j1          !loop index
          integer newc       !to store a new label number
          integer nlormax    !maximum number of lorentz degrees of freedom
C                             of the fields of the theory. change here
          parameter (nlormax=16)
C
          real*8 bar      !flag distinguishing among charged and anticharged particles
          real*8 c1       !containing the characteristic of the field:
C                              2) Lorentz nature 
          real*8 mm1           !particle mass
          real*8 gam1         !particle width
          real*8 pq         !four momentum squared
C
          complex*16 re
          parameter (re=(1.,0.))
          complex*16 im
          parameter (im=(0,1))
          complex*16 m1           !particle  complex mass  (M + i \Gamma)
          complex*16  prop(nlormax**2)        !propagator
          complex*16  zz
C
           m1=mm1
           goto(1,2,3,4,5,6,7,8),nint(c1)
           write(6,*)'I have been asked to compute the propagator of'
           write(6,*)'the particle with Lorentz Index',c1,'which is not'
           write(6,*)'in my table of propagators'  !this should not happen
           stop
C
 1         prop(1)=1.*re     !auxiliary field  propagator
           return
C
 2         call momsq(newc,iteration,pq) !scalar field propagator
           zz=pq-mm1*mm1+mm1*gam1*im
           prop(1)=1./zz
           return        
C
 3         bar=-1.
           call pslashplusmtr(newc,iteration,prop,mm1,gam1,bar)
           return        
C
 4         bar=1.
           call pslashplusm(newc,iteration,prop,mm1,gam1,bar)
           return        
C
 5         call gmnminkmkn(newc,iteration,prop,mm1,gam1)
           return        
C
 6         call momsq(newc,iteration,pq)  !massless gauge boson propagator
           pq=1/pq
           do j1=1,16
            prop(j1)=0.
           enddo
           prop(1)=-pq
           prop(6)=pq
           prop(11)=pq
           prop(16)=pq
           return        
C
 7         stop
C
 8         call auxpr(prop)
C
           end
C***********************************************************************
        subroutine auxpr(alpha)   
C***********************************************************************
C
C Returns the inverse propagator in the array PROP for a fermionbar particle 
C with momentum defined by NEWC and ITERATION
C
        implicit none
C
        complex*16 alpha(256)   !storing the relevant component of pslash+m
C
        alpha(1) = 1
        alpha(2) = 0
        alpha(3) = 0
        alpha(4) = 0
        alpha(5) = 0
        alpha(6) = 0
        alpha(7) = 0
        alpha(8) = 0
        alpha(9) = 0
        alpha(10) = 0
        alpha(11) = 0
        alpha(12) = 0
        alpha(13) = 0
        alpha(14) = 0
        alpha(15) = 0
        alpha(16) = 0
        alpha(17) = 0
        alpha(18) = -1
        alpha(19) = 0
        alpha(20) = 0
        alpha(21) = 0
        alpha(22) = 0
        alpha(23) = 0
        alpha(24) = 0
        alpha(25) = 0
        alpha(26) = 0
        alpha(27) = 0
        alpha(28) = 0
        alpha(29) = 0
        alpha(30) = 0
        alpha(31) = 0
        alpha(32) = 0
        alpha(33) = 0
        alpha(34) = 0
        alpha(35) = -1
        alpha(36) = 0
        alpha(37) = 0
        alpha(38) = 0
        alpha(39) = 0
        alpha(40) = 0
        alpha(41) = 0
        alpha(42) = 0
        alpha(43) = 0
        alpha(44) = 0
        alpha(45) = 0
        alpha(46) = 0
        alpha(47) = 0
        alpha(48) = 0
        alpha(49) = 0
        alpha(50) = 0
        alpha(51) = 0
        alpha(52) = -1
        alpha(53) = 0
        alpha(54) = 0
        alpha(55) = 0
        alpha(56) = 0
        alpha(57) = 0
        alpha(58) = 0
        alpha(59) = 0
        alpha(60) = 0
        alpha(61) = 0
        alpha(62) = 0
        alpha(63) = 0
        alpha(64) = 0
        alpha(65) = 0
        alpha(66) = 0
        alpha(67) = 0
        alpha(68) = 0
        alpha(69) = -1
        alpha(70) = 0
        alpha(71) = 0
        alpha(72) = 0
        alpha(73) = 0
        alpha(74) = 0
        alpha(75) = 0
        alpha(76) = 0
        alpha(77) = 0
        alpha(78) = 0
        alpha(79) = 0
        alpha(80) = 0
        alpha(81) = 0
        alpha(82) = 0
        alpha(83) = 0
        alpha(84) = 0
        alpha(85) = 0
        alpha(86) = 1
        alpha(87) = 0
        alpha(88) = 0
        alpha(89) = 0
        alpha(90) = 0
        alpha(91) = 0
        alpha(92) = 0
        alpha(93) = 0
        alpha(94) = 0
        alpha(95) = 0
        alpha(96) = 0
        alpha(97) = 0
        alpha(98) = 0
        alpha(99) = 0
        alpha(100) = 0
        alpha(101) = 0
        alpha(102) = 0
        alpha(103) = 1
        alpha(104) = 0
        alpha(105) = 0
        alpha(106) = 0
        alpha(107) = 0
        alpha(108) = 0
        alpha(109) = 0
        alpha(110) = 0
        alpha(111) = 0
        alpha(112) = 0
        alpha(113) = 0
        alpha(114) = 0
        alpha(115) = 0
        alpha(116) = 0
        alpha(117) = 0
        alpha(118) = 0
        alpha(119) = 0
        alpha(120) = 1
        alpha(121) = 0
        alpha(122) = 0
        alpha(123) = 0
        alpha(124) = 0
        alpha(125) = 0
        alpha(126) = 0
        alpha(127) = 0
        alpha(128) = 0
        alpha(129) = 0
        alpha(130) = 0
        alpha(131) = 0
        alpha(132) = 0
        alpha(133) = 0
        alpha(134) = 0
        alpha(135) = 0
        alpha(136) = 0
        alpha(137) = -1
        alpha(138) = 0
        alpha(139) = 0
        alpha(140) = 0
        alpha(141) = 0
        alpha(142) = 0
        alpha(143) = 0
        alpha(144) = 0
        alpha(145) = 0
        alpha(146) = 0
        alpha(147) = 0
        alpha(148) = 0
        alpha(149) = 0
        alpha(150) = 0
        alpha(151) = 0
        alpha(152) = 0
        alpha(153) = 0
        alpha(154) = 1
        alpha(155) = 0
        alpha(156) = 0
        alpha(157) = 0
        alpha(158) = 0
        alpha(159) = 0
        alpha(160) = 0
        alpha(161) = 0
        alpha(162) = 0
        alpha(163) = 0
        alpha(164) = 0
        alpha(165) = 0
        alpha(166) = 0
        alpha(167) = 0
        alpha(168) = 0
        alpha(169) = 0
        alpha(170) = 0
        alpha(171) = 1
        alpha(172) = 0
        alpha(173) = 0
        alpha(174) = 0
        alpha(175) = 0
        alpha(176) = 0
        alpha(177) = 0
        alpha(178) = 0
        alpha(179) = 0
        alpha(180) = 0
        alpha(181) = 0
        alpha(182) = 0
        alpha(183) = 0
        alpha(184) = 0
        alpha(185) = 0
        alpha(186) = 0
        alpha(187) = 0
        alpha(188) = 1
        alpha(189) = 0
        alpha(190) = 0
        alpha(191) = 0
        alpha(192) = 0
        alpha(193) = 0
        alpha(194) = 0
        alpha(195) = 0
        alpha(196) = 0
        alpha(197) = 0
        alpha(198) = 0
        alpha(199) = 0
        alpha(200) = 0
        alpha(201) = 0
        alpha(202) = 0
        alpha(203) = 0
        alpha(204) = 0
        alpha(205) = -1
        alpha(206) = 0
        alpha(207) = 0
        alpha(208) = 0
        alpha(209) = 0
        alpha(210) = 0
        alpha(211) = 0
        alpha(212) = 0
        alpha(213) = 0
        alpha(214) = 0
        alpha(215) = 0
        alpha(216) = 0
        alpha(217) = 0
        alpha(218) = 0
        alpha(219) = 0
        alpha(220) = 0
        alpha(221) = 0
        alpha(222) = 1
        alpha(223) = 0
        alpha(224) = 0
        alpha(225) = 0
        alpha(226) = 0
        alpha(227) = 0
        alpha(228) = 0
        alpha(229) = 0
        alpha(230) = 0
        alpha(231) = 0
        alpha(232) = 0
        alpha(233) = 0
        alpha(234) = 0
        alpha(235) = 0
        alpha(236) = 0
        alpha(237) = 0
        alpha(238) = 0
        alpha(239) = 1
        alpha(240) = 0
        alpha(241) = 0
        alpha(242) = 0
        alpha(243) = 0
        alpha(244) = 0
        alpha(245) = 0
        alpha(246) = 0
        alpha(247) = 0
        alpha(248) = 0
        alpha(249) = 0
        alpha(250) = 0
        alpha(251) = 0
        alpha(252) = 0
        alpha(253) = 0
        alpha(254) = 0
        alpha(255) = 0
        alpha(256) = 1
C
          return
          end
C***********************************************************************
          subroutine momsq(newc,nmom,pq)
C***********************************************************************
C
C returning the four momenta squared in PQ for a configuration with
C NMOM momenta and label NEWC
C
          implicit none
C
          integer nmax       !maximal number of external particles
          parameter (nmax=8)  !maximal number of external particles, change here.
          integer newc       !configuration label
          integer next       !number of external particles
          integer nfermion
          integer nmom       !number of momenta
C
          real*8  internal    !array of flags to decide wether the particle is
C                              internal or external
          real*8 momenta     !array containing the external momenta
          real*8 p(4)           !storing the j-th component of the momentum
          real*8 pq          !squared momentum
C
          common/momenta/momenta(nmax,4),internal(nmax)
          common/external/next,nfermion  !containing the number of external
C                                       particles from the subroutine ?????????
C
          call findmom(nmom,newc,p)
C
          pq=p(1)*p(1)-p(2)*p(2)-p(3)*p(3)-p(4)*p(4)
C
          return
          end
C***********************************************************************
          subroutine loroper(oper,alfaprime,momaux)
C***********************************************************************
C
C This subroutine returns in ALFA the lorentz interaction matrix. The flag
C OPER allows to chose the correct lorentz operator. Wishing to add new Lorentz 
C operator one has to modify the GOTO instruction adding a new label 
C (goto(1,2,3,...,q) --> goto(1,2,3,...,q,q+11);  next a labelled (q+1) 
C instruction has to be added with a call to a new subroutine containing the new
C Lorenz operator. Finally this new subroutine has to be added
C
          implicit none
C
          integer nmax     !maximum number of external particles
          parameter (nmax=8)  !maximum number of external particles, change here
          integer nlormax    !maximum number of lorentz degrees of freedom
C                             of the fields of the theory. change here
          parameter (nlormax=16)
          integer j1       !loop index
          integer momaux(6)   !containing the labels of the momenta currently used
          real*8  momenta  !storing the external momenta
          real*8  mom1(4),mom2(4),mom3(4)     !momentum of configuration 1
          integer next     !number of external particles
          integer nfermion !number of external fermions
          integer oper     !operator flag to choose the right subroutine
C
          real*8 internal !labels to discriminate among incoming and outcoming
C                           particles
          real*8 sign      !correct sign for the momenta
C
          complex*16 alfaprime(nlormax**3)        !storing the result of the "lorentz product"
C
          common/external/next,nfermion  !containing the number of external
C                                       particles from the subroutine ?????????
          common/momenta/momenta(nmax,4),internal(nmax)
          common/sign/sign(3)            !correct sign for the four momenta
C
          real*8 awwgz,awzwg,awwgg,awgwg,awpzfwfg,awmzfwfg,azzgg
          common/an4gz/awwgz,awzwg,awpzfwfg,awmzfwfg
          common/an4g/awwgg,awgwg,azzgg
C
          if(oper.eq.5.or.oper.eq.7.or.oper.eq.8.or.oper.eq.10
     >       .or.oper.eq.11.or.oper.eq.12.or.oper.eq.13
     >       .or.oper.eq.15.or.oper.eq.16) then
           call findmom(momaux(1),momaux(2),mom1)
           call findmom(momaux(3),momaux(4),mom2)
           call findmom(momaux(5),momaux(6),mom3)
           if (sign(1).lt.0) then
            do j1=1,4                                
             mom1(j1)=-mom1(j1)                              
            enddo
           elseif (sign(2).lt.0) then
            do j1=1,4                                
             mom2(j1)=-mom2(j1)                              
            enddo
           elseif (sign(3).lt.0) then
            do j1=1,4                                
             mom3(j1)=-mom3(j1)                              
            enddo
           endif
C
          endif
C
           goto(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16), oper
C
           write(6,*)'I have been given the label',oper,'to search for '
           write(6,*)'in subroutine LOROPER. It is not in my table'
C
 1         call scalscalscal(alfaprime)            !cubic scalar interaction
           return
C
 2         call psibarpsiphi(alfaprime)            !yukawa interaction
           return
C
 3         call gammamat(alfaprime)                !gammamu(a+b*gamma5)
           return
C
 4         write(6,*) 'nonexixsting label', oper,'in LOROPER'  !for historical reasons
           return
C
 5         call wpwmz(mom1,mom2,mom3,alfaprime)    !three bosons vertex
           return
C
 6         call gmunumat(alfaprime)      !auxiliary-gaubosons(W,Z)
           return
C
 7         call wpwmg(mom1,mom2,mom3,alfaprime)    !three bosons vertex 
           return
C
 8         call an6(mom1,mom2,mom3,alfaprime,awwgg) !w w A A  vertex 
           return
C
 9         call xabwpwm(alfaprime)              !Xab W W vertex (W A W A)
           return
C
 10        call yabgg(mom1,mom2,mom3,alfaprime)  !Yab Z/g Z/g vertex (W A W A) 
           return
C
 11        call an6(mom1,mom2,mom3,alfaprime,awwgz) !w w Z A  vertex 
           return
C
 12        call an6(mom1,mom2,mom3,alfaprime,awpzfwfg) !w w Z A  vertex 
           return
C
 13        call an6(mom1,mom2,mom3,alfaprime,awmzfwfg) !w w Z A  vertex 
           return
C
 14        call xabwpwmnsim(alfaprime)                 !Xab W W vertex (W A W A)
           return
C
 15        call yabggnsim(mom1,mom2,mom3,alfaprime)  !Yab Z/g Z/g vertex (W A W A) 
           return
C
 16        call an7(mom1,mom2,mom3,alfaprime,azzgg) !w w Z A  vertex 
           return
C
           end    !tolto il commento
C***********************************************************************
        subroutine yabggnsim(k1,k2,k3,alpha)
C***********************************************************************
C
        implicit none
C
        real*8 k1(4),k2(4),k3(4)
        complex*16 alpha(256)
C
        k3(1)=-k3(1)
        k2(1)=-k2(1)
        k1(1)=-k1(1)
C
        alpha(1) = -(k2(2)*k3(2)) - k2(3)*k3(3) - k2(4)*k3(4)
        alpha(2) = -(k2(2)*k3(1))
        alpha(3) = -(k2(3)*k3(1))
        alpha(4) = -(k2(4)*k3(1))
        alpha(5) = -(k2(1)*k3(2))
        alpha(6) = -(k2(1)*k3(1))
        alpha(7) = 0
        alpha(8) = 0
        alpha(9) = -(k2(1)*k3(3))
        alpha(10) = 0
        alpha(11) = -(k2(1)*k3(1))
        alpha(12) = 0
        alpha(13) = -(k2(1)*k3(4))
        alpha(14) = 0
        alpha(15) = 0
        alpha(16) = -(k2(1)*k3(1))
        alpha(17) = 0
        alpha(18) = k2(3)*k3(3) + k2(4)*k3(4)
        alpha(19) = -(k2(3)*k3(2))
        alpha(20) = -(k2(4)*k3(2))
        alpha(21) = 0
        alpha(22) = 0
        alpha(23) = 0
        alpha(24) = 0
        alpha(25) = 0
        alpha(26) = k2(1)*k3(3)
        alpha(27) = -(k2(1)*k3(2))
        alpha(28) = 0
        alpha(29) = 0
        alpha(30) = k2(1)*k3(4)
        alpha(31) = 0
        alpha(32) = -(k2(1)*k3(2))
        alpha(33) = 0
        alpha(34) = -(k2(2)*k3(3))
        alpha(35) = k2(2)*k3(2) + k2(4)*k3(4)
        alpha(36) = -(k2(4)*k3(3))
        alpha(37) = 0
        alpha(38) = -(k2(1)*k3(3))
        alpha(39) = k2(1)*k3(2)
        alpha(40) = 0
        alpha(41) = 0
        alpha(42) = 0
        alpha(43) = 0
        alpha(44) = 0
        alpha(45) = 0
        alpha(46) = 0
        alpha(47) = k2(1)*k3(4)
        alpha(48) = -(k2(1)*k3(3))
        alpha(49) = 0
        alpha(50) = -(k2(2)*k3(4))
        alpha(51) = -(k2(3)*k3(4))
        alpha(52) = k2(2)*k3(2) + k2(3)*k3(3)
        alpha(53) = 0
        alpha(54) = -(k2(1)*k3(4))
        alpha(55) = 0
        alpha(56) = k2(1)*k3(2)
        alpha(57) = 0
        alpha(58) = 0
        alpha(59) = -(k2(1)*k3(4))
        alpha(60) = k2(1)*k3(3)
        alpha(61) = 0
        alpha(62) = 0
        alpha(63) = 0
        alpha(64) = 0
        alpha(65) = 0
        alpha(66) = 0
        alpha(67) = 0
        alpha(68) = 0
        alpha(69) = k2(3)*k3(3) + k2(4)*k3(4)
        alpha(70) = 0
        alpha(71) = k2(3)*k3(1)
        alpha(72) = k2(4)*k3(1)
        alpha(73) = -(k2(2)*k3(3))
        alpha(74) = 0
        alpha(75) = -(k2(2)*k3(1))
        alpha(76) = 0
        alpha(77) = -(k2(2)*k3(4))
        alpha(78) = 0
        alpha(79) = 0
        alpha(80) = -(k2(2)*k3(1))
        alpha(81) = k2(2)*k3(2)
        alpha(82) = k2(2)*k3(1)
        alpha(83) = 0
        alpha(84) = 0
        alpha(85) = k2(1)*k3(2)
        alpha(86) = k2(1)*k3(1) - k2(3)*k3(3) - k2(4)*k3(4)
        alpha(87) = k2(3)*k3(2)
        alpha(88) = k2(4)*k3(2)
        alpha(89) = 0
        alpha(90) = k2(2)*k3(3)
        alpha(91) = -(k2(2)*k3(2))
        alpha(92) = 0
        alpha(93) = 0
        alpha(94) = k2(2)*k3(4)
        alpha(95) = 0
        alpha(96) = -(k2(2)*k3(2))
        alpha(97) = k2(2)*k3(3)
        alpha(98) = 0
        alpha(99) = k2(2)*k3(1)
        alpha(100) = 0
        alpha(101) = k2(1)*k3(3)
        alpha(102) = 0
        alpha(103) = k2(1)*k3(1) - k2(4)*k3(4)
        alpha(104) = k2(4)*k3(3)
        alpha(105) = 0
        alpha(106) = 0
        alpha(107) = 0
        alpha(108) = 0
        alpha(109) = 0
        alpha(110) = 0
        alpha(111) = k2(2)*k3(4)
        alpha(112) = -(k2(2)*k3(3))
        alpha(113) = k2(2)*k3(4)
        alpha(114) = 0
        alpha(115) = 0
        alpha(116) = k2(2)*k3(1)
        alpha(117) = k2(1)*k3(4)
        alpha(118) = 0
        alpha(119) = k2(3)*k3(4)
        alpha(120) = k2(1)*k3(1) - k2(3)*k3(3)
        alpha(121) = 0
        alpha(122) = 0
        alpha(123) = -(k2(2)*k3(4))
        alpha(124) = k2(2)*k3(3)
        alpha(125) = 0
        alpha(126) = 0
        alpha(127) = 0
        alpha(128) = 0
        alpha(129) = 0
        alpha(130) = 0
        alpha(131) = 0
        alpha(132) = 0
        alpha(133) = -(k2(3)*k3(2))
        alpha(134) = -(k2(3)*k3(1))
        alpha(135) = 0
        alpha(136) = 0
        alpha(137) = k2(2)*k3(2) + k2(4)*k3(4)
        alpha(138) = k2(2)*k3(1)
        alpha(139) = 0
        alpha(140) = k2(4)*k3(1)
        alpha(141) = -(k2(3)*k3(4))
        alpha(142) = 0
        alpha(143) = 0
        alpha(144) = -(k2(3)*k3(1))
        alpha(145) = k2(3)*k3(2)
        alpha(146) = k2(3)*k3(1)
        alpha(147) = 0
        alpha(148) = 0
        alpha(149) = 0
        alpha(150) = 0
        alpha(151) = 0
        alpha(152) = 0
        alpha(153) = k2(1)*k3(2)
        alpha(154) = k2(1)*k3(1) - k2(4)*k3(4)
        alpha(155) = 0
        alpha(156) = k2(4)*k3(2)
        alpha(157) = 0
        alpha(158) = k2(3)*k3(4)
        alpha(159) = 0
        alpha(160) = -(k2(3)*k3(2))
        alpha(161) = k2(3)*k3(3)
        alpha(162) = 0
        alpha(163) = k2(3)*k3(1)
        alpha(164) = 0
        alpha(165) = 0
        alpha(166) = -(k2(3)*k3(3))
        alpha(167) = k2(3)*k3(2)
        alpha(168) = 0
        alpha(169) = k2(1)*k3(3)
        alpha(170) = k2(2)*k3(3)
        alpha(171) = k2(1)*k3(1) - k2(2)*k3(2) - k2(4)*k3(4)
        alpha(172) = k2(4)*k3(3)
        alpha(173) = 0
        alpha(174) = 0
        alpha(175) = k2(3)*k3(4)
        alpha(176) = -(k2(3)*k3(3))
        alpha(177) = k2(3)*k3(4)
        alpha(178) = 0
        alpha(179) = 0
        alpha(180) = k2(3)*k3(1)
        alpha(181) = 0
        alpha(182) = -(k2(3)*k3(4))
        alpha(183) = 0
        alpha(184) = k2(3)*k3(2)
        alpha(185) = k2(1)*k3(4)
        alpha(186) = k2(2)*k3(4)
        alpha(187) = 0
        alpha(188) = k2(1)*k3(1) - k2(2)*k3(2)
        alpha(189) = 0
        alpha(190) = 0
        alpha(191) = 0
        alpha(192) = 0
        alpha(193) = 0
        alpha(194) = 0
        alpha(195) = 0
        alpha(196) = 0
        alpha(197) = -(k2(4)*k3(2))
        alpha(198) = -(k2(4)*k3(1))
        alpha(199) = 0
        alpha(200) = 0
        alpha(201) = -(k2(4)*k3(3))
        alpha(202) = 0
        alpha(203) = -(k2(4)*k3(1))
        alpha(204) = 0
        alpha(205) = k2(2)*k3(2) + k2(3)*k3(3)
        alpha(206) = k2(2)*k3(1)
        alpha(207) = k2(3)*k3(1)
        alpha(208) = 0
        alpha(209) = k2(4)*k3(2)
        alpha(210) = k2(4)*k3(1)
        alpha(211) = 0
        alpha(212) = 0
        alpha(213) = 0
        alpha(214) = 0
        alpha(215) = 0
        alpha(216) = 0
        alpha(217) = 0
        alpha(218) = k2(4)*k3(3)
        alpha(219) = -(k2(4)*k3(2))
        alpha(220) = 0
        alpha(221) = k2(1)*k3(2)
        alpha(222) = k2(1)*k3(1) - k2(3)*k3(3)
        alpha(223) = k2(3)*k3(2)
        alpha(224) = 0
        alpha(225) = k2(4)*k3(3)
        alpha(226) = 0
        alpha(227) = k2(4)*k3(1)
        alpha(228) = 0
        alpha(229) = 0
        alpha(230) = -(k2(4)*k3(3))
        alpha(231) = k2(4)*k3(2)
        alpha(232) = 0
        alpha(233) = 0
        alpha(234) = 0
        alpha(235) = 0
        alpha(236) = 0
        alpha(237) = k2(1)*k3(3)
        alpha(238) = k2(2)*k3(3)
        alpha(239) = k2(1)*k3(1) - k2(2)*k3(2)
        alpha(240) = 0
        alpha(241) = k2(4)*k3(4)
        alpha(242) = 0
        alpha(243) = 0
        alpha(244) = k2(4)*k3(1)
        alpha(245) = 0
        alpha(246) = -(k2(4)*k3(4))
        alpha(247) = 0
        alpha(248) = k2(4)*k3(2)
        alpha(249) = 0
        alpha(250) = 0
        alpha(251) = -(k2(4)*k3(4))
        alpha(252) = k2(4)*k3(3)
        alpha(253) = k2(1)*k3(4)
        alpha(254) = k2(2)*k3(4)
        alpha(255) = k2(3)*k3(4)
        alpha(256) = k2(1)*k3(1) - k2(2)*k3(2) - k2(3)*k3(3)
C
        return
        end
C***********************************************************************
        subroutine yabgg(k1,k2,k3,alpha)
C***********************************************************************
C
        implicit none
C
        real*8 k1(4),k2(4),k3(4)
        complex*16 alpha(256)
C
        k3(1)=-k3(1)
        k2(1)=-k2(1)
        k1(1)=-k1(1)
C
        alpha(1) = -2*k2(2)*k3(2) - 2*k2(3)*k3(3) - 2*k2(4)*k3(4)
        alpha(2) = -2*k2(2)*k3(1)
        alpha(3) = -2*k2(3)*k3(1)
        alpha(4) = -2*k2(4)*k3(1)
        alpha(5) = -2*k2(1)*k3(2)
        alpha(6) = -2*k2(1)*k3(1)
        alpha(7) = 0
        alpha(8) = 0
        alpha(9) = -2*k2(1)*k3(3)
        alpha(10) = 0
        alpha(11) = -2*k2(1)*k3(1)
        alpha(12) = 0
        alpha(13) = -2*k2(1)*k3(4)
        alpha(14) = 0
        alpha(15) = 0
        alpha(16) = -2*k2(1)*k3(1)
        alpha(17) = 0
        alpha(18) = k2(3)*k3(3) + k2(4)*k3(4)
        alpha(19) = -(k2(3)*k3(2))
        alpha(20) = -(k2(4)*k3(2))
        alpha(21) = k2(3)*k3(3) + k2(4)*k3(4)
        alpha(22) = 0
        alpha(23) = k2(3)*k3(1)
        alpha(24) = k2(4)*k3(1)
        alpha(25) = -(k2(2)*k3(3))
        alpha(26) = k2(1)*k3(3)
        alpha(27) = -(k2(2)*k3(1)) - k2(1)*k3(2)
        alpha(28) = 0
        alpha(29) = -(k2(2)*k3(4))
        alpha(30) = k2(1)*k3(4)
        alpha(31) = 0
        alpha(32) = -(k2(2)*k3(1)) - k2(1)*k3(2)
        alpha(33) = 0
        alpha(34) = -(k2(2)*k3(3))
        alpha(35) = k2(2)*k3(2) + k2(4)*k3(4)
        alpha(36) = -(k2(4)*k3(3))
        alpha(37) = -(k2(3)*k3(2))
        alpha(38) = -(k2(3)*k3(1)) - k2(1)*k3(3)
        alpha(39) = k2(1)*k3(2)
        alpha(40) = 0
        alpha(41) = k2(2)*k3(2) + k2(4)*k3(4)
        alpha(42) = k2(2)*k3(1)
        alpha(43) = 0
        alpha(44) = k2(4)*k3(1)
        alpha(45) = -(k2(3)*k3(4))
        alpha(46) = 0
        alpha(47) = k2(1)*k3(4)
        alpha(48) = -(k2(3)*k3(1)) - k2(1)*k3(3)
        alpha(49) = 0
        alpha(50) = -(k2(2)*k3(4))
        alpha(51) = -(k2(3)*k3(4))
        alpha(52) = k2(2)*k3(2) + k2(3)*k3(3)
        alpha(53) = -(k2(4)*k3(2))
        alpha(54) = -(k2(4)*k3(1)) - k2(1)*k3(4)
        alpha(55) = 0
        alpha(56) = k2(1)*k3(2)
        alpha(57) = -(k2(4)*k3(3))
        alpha(58) = 0
        alpha(59) = -(k2(4)*k3(1)) - k2(1)*k3(4)
        alpha(60) = k2(1)*k3(3)
        alpha(61) = k2(2)*k3(2) + k2(3)*k3(3)
        alpha(62) = k2(2)*k3(1)
        alpha(63) = k2(3)*k3(1)
        alpha(64) = 0
        alpha(65) = 0
        alpha(66) = k2(3)*k3(3) + k2(4)*k3(4)
        alpha(67) = -(k2(3)*k3(2))
        alpha(68) = -(k2(4)*k3(2))
        alpha(69) = k2(3)*k3(3) + k2(4)*k3(4)
        alpha(70) = 0
        alpha(71) = k2(3)*k3(1)
        alpha(72) = k2(4)*k3(1)
        alpha(73) = -(k2(2)*k3(3))
        alpha(74) = k2(1)*k3(3)
        alpha(75) = -(k2(2)*k3(1)) - k2(1)*k3(2)
        alpha(76) = 0
        alpha(77) = -(k2(2)*k3(4))
        alpha(78) = k2(1)*k3(4)
        alpha(79) = 0
        alpha(80) = -(k2(2)*k3(1)) - k2(1)*k3(2)
        alpha(81) = 2*k2(2)*k3(2)
        alpha(82) = 2*k2(2)*k3(1)
        alpha(83) = 0
        alpha(84) = 0
        alpha(85) = 2*k2(1)*k3(2)
        alpha(86) = 2*k2(1)*k3(1) - 2*k2(3)*k3(3) - 2*k2(4)*k3(4)
        alpha(87) = 2*k2(3)*k3(2)
        alpha(88) = 2*k2(4)*k3(2)
        alpha(89) = 0
        alpha(90) = 2*k2(2)*k3(3)
        alpha(91) = -2*k2(2)*k3(2)
        alpha(92) = 0
        alpha(93) = 0
        alpha(94) = 2*k2(2)*k3(4)
        alpha(95) = 0
        alpha(96) = -2*k2(2)*k3(2)
        alpha(97) = k2(3)*k3(2) + k2(2)*k3(3)
        alpha(98) = k2(3)*k3(1)
        alpha(99) = k2(2)*k3(1)
        alpha(100) = 0
        alpha(101) = k2(1)*k3(3)
        alpha(102) = 0
        alpha(103) = k2(1)*k3(1) - k2(4)*k3(4)
        alpha(104) = k2(4)*k3(3)
        alpha(105) = k2(1)*k3(2)
        alpha(106) = k2(1)*k3(1) - k2(4)*k3(4)
        alpha(107) = 0
        alpha(108) = k2(4)*k3(2)
        alpha(109) = 0
        alpha(110) = k2(3)*k3(4)
        alpha(111) = k2(2)*k3(4)
        alpha(112) = -(k2(3)*k3(2)) - k2(2)*k3(3)
        alpha(113) = k2(4)*k3(2) + k2(2)*k3(4)
        alpha(114) = k2(4)*k3(1)
        alpha(115) = 0
        alpha(116) = k2(2)*k3(1)
        alpha(117) = k2(1)*k3(4)
        alpha(118) = 0
        alpha(119) = k2(3)*k3(4)
        alpha(120) = k2(1)*k3(1) - k2(3)*k3(3)
        alpha(121) = 0
        alpha(122) = k2(4)*k3(3)
        alpha(123) = -(k2(4)*k3(2)) - k2(2)*k3(4)
        alpha(124) = k2(2)*k3(3)
        alpha(125) = k2(1)*k3(2)
        alpha(126) = k2(1)*k3(1) - k2(3)*k3(3)
        alpha(127) = k2(3)*k3(2)
        alpha(128) = 0
        alpha(129) = 0
        alpha(130) = -(k2(2)*k3(3))
        alpha(131) = k2(2)*k3(2) + k2(4)*k3(4)
        alpha(132) = -(k2(4)*k3(3))
        alpha(133) = -(k2(3)*k3(2))
        alpha(134) = -(k2(3)*k3(1)) - k2(1)*k3(3)
        alpha(135) = k2(1)*k3(2)
        alpha(136) = 0
        alpha(137) = k2(2)*k3(2) + k2(4)*k3(4)
        alpha(138) = k2(2)*k3(1)
        alpha(139) = 0
        alpha(140) = k2(4)*k3(1)
        alpha(141) = -(k2(3)*k3(4))
        alpha(142) = 0
        alpha(143) = k2(1)*k3(4)
        alpha(144) = -(k2(3)*k3(1)) - k2(1)*k3(3)
        alpha(145) = k2(3)*k3(2) + k2(2)*k3(3)
        alpha(146) = k2(3)*k3(1)
        alpha(147) = k2(2)*k3(1)
        alpha(148) = 0
        alpha(149) = k2(1)*k3(3)
        alpha(150) = 0
        alpha(151) = k2(1)*k3(1) - k2(4)*k3(4)
        alpha(152) = k2(4)*k3(3)
        alpha(153) = k2(1)*k3(2)
        alpha(154) = k2(1)*k3(1) - k2(4)*k3(4)
        alpha(155) = 0
        alpha(156) = k2(4)*k3(2)
        alpha(157) = 0
        alpha(158) = k2(3)*k3(4)
        alpha(159) = k2(2)*k3(4)
        alpha(160) = -(k2(3)*k3(2)) - k2(2)*k3(3)
        alpha(161) = 2*k2(3)*k3(3)
        alpha(162) = 0
        alpha(163) = 2*k2(3)*k3(1)
        alpha(164) = 0
        alpha(165) = 0
        alpha(166) = -2*k2(3)*k3(3)
        alpha(167) = 2*k2(3)*k3(2)
        alpha(168) = 0
        alpha(169) = 2*k2(1)*k3(3)
        alpha(170) = 2*k2(2)*k3(3)
        alpha(171) = 2*k2(1)*k3(1) - 2*k2(2)*k3(2) - 2*k2(4)*k3(4)
        alpha(172) = 2*k2(4)*k3(3)
        alpha(173) = 0
        alpha(174) = 0
        alpha(175) = 2*k2(3)*k3(4)
        alpha(176) = -2*k2(3)*k3(3)
        alpha(177) = k2(4)*k3(3) + k2(3)*k3(4)
        alpha(178) = 0
        alpha(179) = k2(4)*k3(1)
        alpha(180) = k2(3)*k3(1)
        alpha(181) = 0
        alpha(182) = -(k2(4)*k3(3)) - k2(3)*k3(4)
        alpha(183) = k2(4)*k3(2)
        alpha(184) = k2(3)*k3(2)
        alpha(185) = k2(1)*k3(4)
        alpha(186) = k2(2)*k3(4)
        alpha(187) = 0
        alpha(188) = k2(1)*k3(1) - k2(2)*k3(2)
        alpha(189) = k2(1)*k3(3)
        alpha(190) = k2(2)*k3(3)
        alpha(191) = k2(1)*k3(1) - k2(2)*k3(2)
        alpha(192) = 0
        alpha(193) = 0
        alpha(194) = -(k2(2)*k3(4))
        alpha(195) = -(k2(3)*k3(4))
        alpha(196) = k2(2)*k3(2) + k2(3)*k3(3)
        alpha(197) = -(k2(4)*k3(2))
        alpha(198) = -(k2(4)*k3(1)) - k2(1)*k3(4)
        alpha(199) = 0
        alpha(200) = k2(1)*k3(2)
        alpha(201) = -(k2(4)*k3(3))
        alpha(202) = 0
        alpha(203) = -(k2(4)*k3(1)) - k2(1)*k3(4)
        alpha(204) = k2(1)*k3(3)
        alpha(205) = k2(2)*k3(2) + k2(3)*k3(3)
        alpha(206) = k2(2)*k3(1)
        alpha(207) = k2(3)*k3(1)
        alpha(208) = 0
        alpha(209) = k2(4)*k3(2) + k2(2)*k3(4)
        alpha(210) = k2(4)*k3(1)
        alpha(211) = 0
        alpha(212) = k2(2)*k3(1)
        alpha(213) = k2(1)*k3(4)
        alpha(214) = 0
        alpha(215) = k2(3)*k3(4)
        alpha(216) = k2(1)*k3(1) - k2(3)*k3(3)
        alpha(217) = 0
        alpha(218) = k2(4)*k3(3)
        alpha(219) = -(k2(4)*k3(2)) - k2(2)*k3(4)
        alpha(220) = k2(2)*k3(3)
        alpha(221) = k2(1)*k3(2)
        alpha(222) = k2(1)*k3(1) - k2(3)*k3(3)
        alpha(223) = k2(3)*k3(2)
        alpha(224) = 0
        alpha(225) = k2(4)*k3(3) + k2(3)*k3(4)
        alpha(226) = 0
        alpha(227) = k2(4)*k3(1)
        alpha(228) = k2(3)*k3(1)
        alpha(229) = 0
        alpha(230) = -(k2(4)*k3(3)) - k2(3)*k3(4)
        alpha(231) = k2(4)*k3(2)
        alpha(232) = k2(3)*k3(2)
        alpha(233) = k2(1)*k3(4)
        alpha(234) = k2(2)*k3(4)
        alpha(235) = 0
        alpha(236) = k2(1)*k3(1) - k2(2)*k3(2)
        alpha(237) = k2(1)*k3(3)
        alpha(238) = k2(2)*k3(3)
        alpha(239) = k2(1)*k3(1) - k2(2)*k3(2)
        alpha(240) = 0
        alpha(241) = 2*k2(4)*k3(4)
        alpha(242) = 0
        alpha(243) = 0
        alpha(244) = 2*k2(4)*k3(1)
        alpha(245) = 0
        alpha(246) = -2*k2(4)*k3(4)
        alpha(247) = 0
        alpha(248) = 2*k2(4)*k3(2)
        alpha(249) = 0
        alpha(250) = 0
        alpha(251) = -2*k2(4)*k3(4)
        alpha(252) = 2*k2(4)*k3(3)
        alpha(253) = 2*k2(1)*k3(4)
        alpha(254) = 2*k2(2)*k3(4)
        alpha(255) = 2*k2(3)*k3(4)
        alpha(256) = 2*k2(1)*k3(1) - 2*k2(2)*k3(2) - 2*k2(3)*k3(3)
C
        return
C
        alpha(1) = -(k2(2)*k3(2)) - k2(3)*k3(3) - k2(4)*k3(4)
        alpha(2) = -(k2(2)*k3(1))
        alpha(3) = -(k2(3)*k3(1))
        alpha(4) = -(k2(4)*k3(1))
        alpha(5) = -(k2(1)*k3(2))
        alpha(6) = -(k2(1)*k3(1))
        alpha(7) = 0
        alpha(8) = 0
        alpha(9) = -(k2(1)*k3(3))
        alpha(10) = 0
        alpha(11) = -(k2(1)*k3(1))
        alpha(12) = 0
        alpha(13) = -(k2(1)*k3(4))
        alpha(14) = 0
        alpha(15) = 0
        alpha(16) = -(k2(1)*k3(1))
        alpha(17) = 0
        alpha(18) = -(k2(3)*k3(3)) - k2(4)*k3(4)
        alpha(19) = k2(3)*k3(2)
        alpha(20) = k2(4)*k3(2)
        alpha(21) = 0
        alpha(22) = 0
        alpha(23) = 0
        alpha(24) = 0
        alpha(25) = 0
        alpha(26) = -(k2(1)*k3(3))
        alpha(27) = k2(1)*k3(2)
        alpha(28) = 0
        alpha(29) = 0
        alpha(30) = -(k2(1)*k3(4))
        alpha(31) = 0
        alpha(32) = k2(1)*k3(2)
        alpha(33) = 0
        alpha(34) = k2(2)*k3(3)
        alpha(35) = -(k2(2)*k3(2)) - k2(4)*k3(4)
        alpha(36) = k2(4)*k3(3)
        alpha(37) = 0
        alpha(38) = k2(1)*k3(3)
        alpha(39) = -(k2(1)*k3(2))
        alpha(40) = 0
        alpha(41) = 0
        alpha(42) = 0
        alpha(43) = 0
        alpha(44) = 0
        alpha(45) = 0
        alpha(46) = 0
        alpha(47) = -(k2(1)*k3(4))
        alpha(48) = k2(1)*k3(3)
        alpha(49) = 0
        alpha(50) = k2(2)*k3(4)
        alpha(51) = k2(3)*k3(4)
        alpha(52) = -(k2(2)*k3(2)) - k2(3)*k3(3)
        alpha(53) = 0
        alpha(54) = k2(1)*k3(4)
        alpha(55) = 0
        alpha(56) = -(k2(1)*k3(2))
        alpha(57) = 0
        alpha(58) = 0
        alpha(59) = k2(1)*k3(4)
        alpha(60) = -(k2(1)*k3(3))
        alpha(61) = 0
        alpha(62) = 0
        alpha(63) = 0
        alpha(64) = 0
        alpha(65) = 0
        alpha(66) = 0
        alpha(67) = 0
        alpha(68) = 0
        alpha(69) = -(k2(3)*k3(3)) - k2(4)*k3(4)
        alpha(70) = 0
        alpha(71) = -(k2(3)*k3(1))
        alpha(72) = -(k2(4)*k3(1))
        alpha(73) = k2(2)*k3(3)
        alpha(74) = 0
        alpha(75) = k2(2)*k3(1)
        alpha(76) = 0
        alpha(77) = k2(2)*k3(4)
        alpha(78) = 0
        alpha(79) = 0
        alpha(80) = k2(2)*k3(1)
        alpha(81) = k2(2)*k3(2)
        alpha(82) = k2(2)*k3(1)
        alpha(83) = 0
        alpha(84) = 0
        alpha(85) = k2(1)*k3(2)
        alpha(86) = k2(1)*k3(1) - k2(3)*k3(3) - k2(4)*k3(4)
        alpha(87) = k2(3)*k3(2)
        alpha(88) = k2(4)*k3(2)
        alpha(89) = 0
        alpha(90) = k2(2)*k3(3)
        alpha(91) = -(k2(2)*k3(2))
        alpha(92) = 0
        alpha(93) = 0
        alpha(94) = k2(2)*k3(4)
        alpha(95) = 0
        alpha(96) = -(k2(2)*k3(2))
        alpha(97) = k2(2)*k3(3)
        alpha(98) = 0
        alpha(99) = k2(2)*k3(1)
        alpha(100) = 0
        alpha(101) = k2(1)*k3(3)
        alpha(102) = 0
        alpha(103) = k2(1)*k3(1) - k2(4)*k3(4)
        alpha(104) = k2(4)*k3(3)
        alpha(105) = 0
        alpha(106) = 0
        alpha(107) = 0
        alpha(108) = 0
        alpha(109) = 0
        alpha(110) = 0
        alpha(111) = k2(2)*k3(4)
        alpha(112) = -(k2(2)*k3(3))
        alpha(113) = k2(2)*k3(4)
        alpha(114) = 0
        alpha(115) = 0
        alpha(116) = k2(2)*k3(1)
        alpha(117) = k2(1)*k3(4)
        alpha(118) = 0
        alpha(119) = k2(3)*k3(4)
        alpha(120) = k2(1)*k3(1) - k2(3)*k3(3)
        alpha(121) = 0
        alpha(122) = 0
        alpha(123) = -(k2(2)*k3(4))
        alpha(124) = k2(2)*k3(3)
        alpha(125) = 0
        alpha(126) = 0
        alpha(127) = 0
        alpha(128) = 0
        alpha(129) = 0
        alpha(130) = 0
        alpha(131) = 0
        alpha(132) = 0
        alpha(133) = k2(3)*k3(2)
        alpha(134) = k2(3)*k3(1)
        alpha(135) = 0
        alpha(136) = 0
        alpha(137) = -(k2(2)*k3(2)) - k2(4)*k3(4)
        alpha(138) = -(k2(2)*k3(1))
        alpha(139) = 0
        alpha(140) = -(k2(4)*k3(1))
        alpha(141) = k2(3)*k3(4)
        alpha(142) = 0
        alpha(143) = 0
        alpha(144) = k2(3)*k3(1)
        alpha(145) = k2(3)*k3(2)
        alpha(146) = k2(3)*k3(1)
        alpha(147) = 0
        alpha(148) = 0
        alpha(149) = 0
        alpha(150) = 0
        alpha(151) = 0
        alpha(152) = 0
        alpha(153) = k2(1)*k3(2)
        alpha(154) = k2(1)*k3(1) - k2(4)*k3(4)
        alpha(155) = 0
        alpha(156) = k2(4)*k3(2)
        alpha(157) = 0
        alpha(158) = k2(3)*k3(4)
        alpha(159) = 0
        alpha(160) = -(k2(3)*k3(2))
        alpha(161) = k2(3)*k3(3)
        alpha(162) = 0
        alpha(163) = k2(3)*k3(1)
        alpha(164) = 0
        alpha(165) = 0
        alpha(166) = -(k2(3)*k3(3))
        alpha(167) = k2(3)*k3(2)
        alpha(168) = 0
        alpha(169) = k2(1)*k3(3)
        alpha(170) = k2(2)*k3(3)
        alpha(171) = k2(1)*k3(1) - k2(2)*k3(2) - k2(4)*k3(4)
        alpha(172) = k2(4)*k3(3)
        alpha(173) = 0
        alpha(174) = 0
        alpha(175) = k2(3)*k3(4)
        alpha(176) = -(k2(3)*k3(3))
        alpha(177) = k2(3)*k3(4)
        alpha(178) = 0
        alpha(179) = 0
        alpha(180) = k2(3)*k3(1)
        alpha(181) = 0
        alpha(182) = -(k2(3)*k3(4))
        alpha(183) = 0
        alpha(184) = k2(3)*k3(2)
        alpha(185) = k2(1)*k3(4)
        alpha(186) = k2(2)*k3(4)
        alpha(187) = 0
        alpha(188) = k2(1)*k3(1) - k2(2)*k3(2)
        alpha(189) = 0
        alpha(190) = 0
        alpha(191) = 0
        alpha(192) = 0
        alpha(193) = 0
        alpha(194) = 0
        alpha(195) = 0
        alpha(196) = 0
        alpha(197) = k2(4)*k3(2)
        alpha(198) = k2(4)*k3(1)
        alpha(199) = 0
        alpha(200) = 0
        alpha(201) = k2(4)*k3(3)
        alpha(202) = 0
        alpha(203) = k2(4)*k3(1)
        alpha(204) = 0
        alpha(205) = -(k2(2)*k3(2)) - k2(3)*k3(3)
        alpha(206) = -(k2(2)*k3(1))
        alpha(207) = -(k2(3)*k3(1))
        alpha(208) = 0
        alpha(209) = k2(4)*k3(2)
        alpha(210) = k2(4)*k3(1)
        alpha(211) = 0
        alpha(212) = 0
        alpha(213) = 0
        alpha(214) = 0
        alpha(215) = 0
        alpha(216) = 0
        alpha(217) = 0
        alpha(218) = k2(4)*k3(3)
        alpha(219) = -(k2(4)*k3(2))
        alpha(220) = 0
        alpha(221) = k2(1)*k3(2)
        alpha(222) = k2(1)*k3(1) - k2(3)*k3(3)
        alpha(223) = k2(3)*k3(2)
        alpha(224) = 0
        alpha(225) = k2(4)*k3(3)
        alpha(226) = 0
        alpha(227) = k2(4)*k3(1)
        alpha(228) = 0
        alpha(229) = 0
        alpha(230) = -(k2(4)*k3(3))
        alpha(231) = k2(4)*k3(2)
        alpha(232) = 0
        alpha(233) = 0
        alpha(234) = 0
        alpha(235) = 0
        alpha(236) = 0
        alpha(237) = k2(1)*k3(3)
        alpha(238) = k2(2)*k3(3)
        alpha(239) = k2(1)*k3(1) - k2(2)*k3(2)
        alpha(240) = 0
        alpha(241) = k2(4)*k3(4)
        alpha(242) = 0
        alpha(243) = 0
        alpha(244) = k2(4)*k3(1)
        alpha(245) = 0
        alpha(246) = -(k2(4)*k3(4))
        alpha(247) = 0
        alpha(248) = k2(4)*k3(2)
        alpha(249) = 0
        alpha(250) = 0
        alpha(251) = -(k2(4)*k3(4))
        alpha(252) = k2(4)*k3(3)
        alpha(253) = k2(1)*k3(4)
        alpha(254) = k2(2)*k3(4)
        alpha(255) = k2(3)*k3(4)
        alpha(256) = k2(1)*k3(1) - k2(2)*k3(2) - k2(3)*k3(3)
C
        return
        end
C***********************************************************************
           subroutine xabwpwmnsim(alpha)
C***********************************************************************
C
           implicit none
C
           complex*16 alpha(256)
C
        alpha(1) = 1
        alpha(2) = 0
        alpha(3) = 0
        alpha(4) = 0
        alpha(5) = 0
        alpha(6) = 0
        alpha(7) = 0
        alpha(8) = 0
        alpha(9) = 0
        alpha(10) = 0
        alpha(11) = 0
        alpha(12) = 0
        alpha(13) = 0
        alpha(14) = 0
        alpha(15) = 0
        alpha(16) = 0
        alpha(17) = 0
        alpha(18) = -1
        alpha(19) = 0
        alpha(20) = 0
        alpha(21) = 0
        alpha(22) = 0
        alpha(23) = 0
        alpha(24) = 0
        alpha(25) = 0
        alpha(26) = 0
        alpha(27) = 0
        alpha(28) = 0
        alpha(29) = 0
        alpha(30) = 0
        alpha(31) = 0
        alpha(32) = 0
        alpha(33) = 0
        alpha(34) = 0
        alpha(35) = -1
        alpha(36) = 0
        alpha(37) = 0
        alpha(38) = 0
        alpha(39) = 0
        alpha(40) = 0
        alpha(41) = 0
        alpha(42) = 0
        alpha(43) = 0
        alpha(44) = 0
        alpha(45) = 0
        alpha(46) = 0
        alpha(47) = 0
        alpha(48) = 0
        alpha(49) = 0
        alpha(50) = 0
        alpha(51) = 0
        alpha(52) = -1
        alpha(53) = 0
        alpha(54) = 0
        alpha(55) = 0
        alpha(56) = 0
        alpha(57) = 0
        alpha(58) = 0
        alpha(59) = 0
        alpha(60) = 0
        alpha(61) = 0
        alpha(62) = 0
        alpha(63) = 0
        alpha(64) = 0
        alpha(65) = 0
        alpha(66) = 0
        alpha(67) = 0
        alpha(68) = 0
        alpha(69) = -1
        alpha(70) = 0
        alpha(71) = 0
        alpha(72) = 0
        alpha(73) = 0
        alpha(74) = 0
        alpha(75) = 0
        alpha(76) = 0
        alpha(77) = 0
        alpha(78) = 0
        alpha(79) = 0
        alpha(80) = 0
        alpha(81) = 0
        alpha(82) = 0
        alpha(83) = 0
        alpha(84) = 0
        alpha(85) = 0
        alpha(86) = 1
        alpha(87) = 0
        alpha(88) = 0
        alpha(89) = 0
        alpha(90) = 0
        alpha(91) = 0
        alpha(92) = 0
        alpha(93) = 0
        alpha(94) = 0
        alpha(95) = 0
        alpha(96) = 0
        alpha(97) = 0
        alpha(98) = 0
        alpha(99) = 0
        alpha(100) = 0
        alpha(101) = 0
        alpha(102) = 0
        alpha(103) = 1
        alpha(104) = 0
        alpha(105) = 0
        alpha(106) = 0
        alpha(107) = 0
        alpha(108) = 0
        alpha(109) = 0
        alpha(110) = 0
        alpha(111) = 0
        alpha(112) = 0
        alpha(113) = 0
        alpha(114) = 0
        alpha(115) = 0
        alpha(116) = 0
        alpha(117) = 0
        alpha(118) = 0
        alpha(119) = 0
        alpha(120) = 1
        alpha(121) = 0
        alpha(122) = 0
        alpha(123) = 0
        alpha(124) = 0
        alpha(125) = 0
        alpha(126) = 0
        alpha(127) = 0
        alpha(128) = 0
        alpha(129) = 0
        alpha(130) = 0
        alpha(131) = 0
        alpha(132) = 0
        alpha(133) = 0
        alpha(134) = 0
        alpha(135) = 0
        alpha(136) = 0
        alpha(137) = -1
        alpha(138) = 0
        alpha(139) = 0
        alpha(140) = 0
        alpha(141) = 0
        alpha(142) = 0
        alpha(143) = 0
        alpha(144) = 0
        alpha(145) = 0
        alpha(146) = 0
        alpha(147) = 0
        alpha(148) = 0
        alpha(149) = 0
        alpha(150) = 0
        alpha(151) = 0
        alpha(152) = 0
        alpha(153) = 0
        alpha(154) = 1
        alpha(155) = 0
        alpha(156) = 0
        alpha(157) = 0
        alpha(158) = 0
        alpha(159) = 0
        alpha(160) = 0
        alpha(161) = 0
        alpha(162) = 0
        alpha(163) = 0
        alpha(164) = 0
        alpha(165) = 0
        alpha(166) = 0
        alpha(167) = 0
        alpha(168) = 0
        alpha(169) = 0
        alpha(170) = 0
        alpha(171) = 1
        alpha(172) = 0
        alpha(173) = 0
        alpha(174) = 0
        alpha(175) = 0
        alpha(176) = 0
        alpha(177) = 0
        alpha(178) = 0
        alpha(179) = 0
        alpha(180) = 0
        alpha(181) = 0
        alpha(182) = 0
        alpha(183) = 0
        alpha(184) = 0
        alpha(185) = 0
        alpha(186) = 0
        alpha(187) = 0
        alpha(188) = 1
        alpha(189) = 0
        alpha(190) = 0
        alpha(191) = 0
        alpha(192) = 0
        alpha(193) = 0
        alpha(194) = 0
        alpha(195) = 0
        alpha(196) = 0
        alpha(197) = 0
        alpha(198) = 0
        alpha(199) = 0
        alpha(200) = 0
        alpha(201) = 0
        alpha(202) = 0
        alpha(203) = 0
        alpha(204) = 0
        alpha(205) = -1
        alpha(206) = 0
        alpha(207) = 0
        alpha(208) = 0
        alpha(209) = 0
        alpha(210) = 0
        alpha(211) = 0
        alpha(212) = 0
        alpha(213) = 0
        alpha(214) = 0
        alpha(215) = 0
        alpha(216) = 0
        alpha(217) = 0
        alpha(218) = 0
        alpha(219) = 0
        alpha(220) = 0
        alpha(221) = 0
        alpha(222) = 1
        alpha(223) = 0
        alpha(224) = 0
        alpha(225) = 0
        alpha(226) = 0
        alpha(227) = 0
        alpha(228) = 0
        alpha(229) = 0
        alpha(230) = 0
        alpha(231) = 0
        alpha(232) = 0
        alpha(233) = 0
        alpha(234) = 0
        alpha(235) = 0
        alpha(236) = 0
        alpha(237) = 0
        alpha(238) = 0
        alpha(239) = 1
        alpha(240) = 0
        alpha(241) = 0
        alpha(242) = 0
        alpha(243) = 0
        alpha(244) = 0
        alpha(245) = 0
        alpha(246) = 0
        alpha(247) = 0
        alpha(248) = 0
        alpha(249) = 0
        alpha(250) = 0
        alpha(251) = 0
        alpha(252) = 0
        alpha(253) = 0
        alpha(254) = 0
        alpha(255) = 0
        alpha(256) = 1
C
        return
        end
C***********************************************************************
           subroutine xabwpwm(alpha)
C***********************************************************************
C
           implicit none
C
           complex*16 alpha(256)
C
           alpha(1) = 2
           alpha(2) = 0
           alpha(3) = 0
           alpha(4) = 0
           alpha(5) = 0
           alpha(6) = 0
           alpha(7) = 0
           alpha(8) = 0
           alpha(9) = 0
           alpha(10) = 0
           alpha(11) = 0
           alpha(12) = 0
           alpha(13) = 0
           alpha(14) = 0
           alpha(15) = 0
           alpha(16) = 0
           alpha(17) = 0
           alpha(18) = -1
           alpha(19) = 0
           alpha(20) = 0
           alpha(21) = -1
           alpha(22) = 0
           alpha(23) = 0
           alpha(24) = 0
           alpha(25) = 0
           alpha(26) = 0
           alpha(27) = 0
           alpha(28) = 0
           alpha(29) = 0
           alpha(30) = 0
           alpha(31) = 0
           alpha(32) = 0
           alpha(33) = 0
           alpha(34) = 0
           alpha(35) = -1
           alpha(36) = 0
           alpha(37) = 0
           alpha(38) = 0
           alpha(39) = 0
           alpha(40) = 0
           alpha(41) = -1
           alpha(42) = 0
           alpha(43) = 0
           alpha(44) = 0
           alpha(45) = 0
           alpha(46) = 0
           alpha(47) = 0
           alpha(48) = 0
           alpha(49) = 0
           alpha(50) = 0
           alpha(51) = 0
           alpha(52) = -1
           alpha(53) = 0
           alpha(54) = 0
           alpha(55) = 0
           alpha(56) = 0
           alpha(57) = 0
           alpha(58) = 0
           alpha(59) = 0
           alpha(60) = 0
           alpha(61) = -1
           alpha(62) = 0
           alpha(63) = 0
           alpha(64) = 0
           alpha(65) = 0
           alpha(66) = -1
           alpha(67) = 0
           alpha(68) = 0
           alpha(69) = -1
           alpha(70) = 0
           alpha(71) = 0
           alpha(72) = 0
           alpha(73) = 0
           alpha(74) = 0
           alpha(75) = 0
           alpha(76) = 0
           alpha(77) = 0
           alpha(78) = 0
           alpha(79) = 0
           alpha(80) = 0
           alpha(81) = 0
           alpha(82) = 0
           alpha(83) = 0
           alpha(84) = 0
           alpha(85) = 0
           alpha(86) = 2
           alpha(87) = 0
           alpha(88) = 0
           alpha(89) = 0
           alpha(90) = 0
           alpha(91) = 0
           alpha(92) = 0
           alpha(93) = 0
           alpha(94) = 0
           alpha(95) = 0
           alpha(96) = 0
           alpha(97) = 0
           alpha(98) = 0
           alpha(99) = 0
           alpha(100) = 0
           alpha(101) = 0
           alpha(102) = 0
           alpha(103) = 1
           alpha(104) = 0
           alpha(105) = 0
           alpha(106) = 1
           alpha(107) = 0
           alpha(108) = 0
           alpha(109) = 0
           alpha(110) = 0
           alpha(111) = 0
           alpha(112) = 0
           alpha(113) = 0
           alpha(114) = 0
           alpha(115) = 0
           alpha(116) = 0
           alpha(117) = 0
           alpha(118) = 0
           alpha(119) = 0
           alpha(120) = 1
           alpha(121) = 0
           alpha(122) = 0
           alpha(123) = 0
           alpha(124) = 0
           alpha(125) = 0
           alpha(126) = 1
           alpha(127) = 0
           alpha(128) = 0
           alpha(129) = 0
           alpha(130) = 0
           alpha(131) = -1
           alpha(132) = 0
           alpha(133) = 0
           alpha(134) = 0
           alpha(135) = 0
           alpha(136) = 0
           alpha(137) = -1
           alpha(138) = 0
           alpha(139) = 0
           alpha(140) = 0
           alpha(141) = 0
           alpha(142) = 0
           alpha(143) = 0
           alpha(144) = 0
           alpha(145) = 0
           alpha(146) = 0
           alpha(147) = 0
           alpha(148) = 0
           alpha(149) = 0
           alpha(150) = 0
           alpha(151) = 1
           alpha(152) = 0
           alpha(153) = 0
           alpha(154) = 1
           alpha(155) = 0
           alpha(156) = 0
           alpha(157) = 0
           alpha(158) = 0
           alpha(159) = 0
           alpha(160) = 0
           alpha(161) = 0
           alpha(162) = 0
           alpha(163) = 0
           alpha(164) = 0
           alpha(165) = 0
           alpha(166) = 0
           alpha(167) = 0
           alpha(168) = 0
           alpha(169) = 0
           alpha(170) = 0
           alpha(171) = 2
           alpha(172) = 0
           alpha(173) = 0
           alpha(174) = 0
           alpha(175) = 0
           alpha(176) = 0
           alpha(177) = 0
           alpha(178) = 0
           alpha(179) = 0
           alpha(180) = 0
           alpha(181) = 0
           alpha(182) = 0
           alpha(183) = 0
           alpha(184) = 0
           alpha(185) = 0
           alpha(186) = 0
           alpha(187) = 0
           alpha(188) = 1
           alpha(189) = 0
           alpha(190) = 0
           alpha(191) = 1
           alpha(192) = 0
           alpha(193) = 0
           alpha(194) = 0
           alpha(195) = 0
           alpha(196) = -1
           alpha(197) = 0
           alpha(198) = 0
           alpha(199) = 0
           alpha(200) = 0
           alpha(201) = 0
           alpha(202) = 0
           alpha(203) = 0
           alpha(204) = 0
           alpha(205) = -1
           alpha(206) = 0
           alpha(207) = 0
           alpha(208) = 0
           alpha(209) = 0
           alpha(210) = 0
           alpha(211) = 0
           alpha(212) = 0
           alpha(213) = 0
           alpha(214) = 0
           alpha(215) = 0
           alpha(216) = 1
           alpha(217) = 0
           alpha(218) = 0
           alpha(219) = 0
           alpha(220) = 0
           alpha(221) = 0
           alpha(222) = 1
           alpha(223) = 0
           alpha(224) = 0
           alpha(225) = 0
           alpha(226) = 0
           alpha(227) = 0
           alpha(228) = 0
           alpha(229) = 0
           alpha(230) = 0
           alpha(231) = 0
           alpha(232) = 0
           alpha(233) = 0
           alpha(234) = 0
           alpha(235) = 0
           alpha(236) = 1
           alpha(237) = 0
           alpha(238) = 0
           alpha(239) = 1
           alpha(240) = 0
           alpha(241) = 0
           alpha(242) = 0
           alpha(243) = 0
           alpha(244) = 0
           alpha(245) = 0
           alpha(246) = 0
           alpha(247) = 0
           alpha(248) = 0
           alpha(249) = 0
           alpha(250) = 0
           alpha(251) = 0
           alpha(252) = 0
           alpha(253) = 0
           alpha(254) = 0
           alpha(255) = 0
           alpha(256) = 2
C
           return
           end
C***********************************************************************
           subroutine xabwpwmold(alpha)
C***********************************************************************
C
           implicit none
C
           complex*16 alpha(256)
C
           alpha(1) = 1
           alpha(2) = 0
           alpha(3) = 0
           alpha(4) = 0
           alpha(5) = 0
           alpha(6) = 0
           alpha(7) = 0
           alpha(8) = 0
           alpha(9) = 0
           alpha(10) = 0
           alpha(11) = 0
           alpha(12) = 0
           alpha(13) = 0
           alpha(14) = 0
           alpha(15) = 0
           alpha(16) = 0
           alpha(17) = 0
           alpha(18) = -1
           alpha(19) = 0
           alpha(20) = 0
           alpha(21) = 0
           alpha(22) = 0
           alpha(23) = 0
           alpha(24) = 0
           alpha(25) = 0
           alpha(26) = 0
           alpha(27) = 0
           alpha(28) = 0
           alpha(29) = 0
           alpha(30) = 0
           alpha(31) = 0
           alpha(32) = 0
           alpha(33) = 0
           alpha(34) = 0
           alpha(35) = -1
           alpha(36) = 0
           alpha(37) = 0
           alpha(38) = 0
           alpha(39) = 0
           alpha(40) = 0
           alpha(41) = 0
           alpha(42) = 0
           alpha(43) = 0
           alpha(44) = 0
           alpha(45) = 0
           alpha(46) = 0
           alpha(47) = 0
           alpha(48) = 0
           alpha(49) = 0
           alpha(50) = 0
           alpha(51) = 0
           alpha(52) = -1
           alpha(53) = 0
           alpha(54) = 0
           alpha(55) = 0
           alpha(56) = 0
           alpha(57) = 0
           alpha(58) = 0
           alpha(59) = 0
           alpha(60) = 0
           alpha(61) = 0
           alpha(62) = 0
           alpha(63) = 0
           alpha(64) = 0
           alpha(65) = 0
           alpha(66) = 0
           alpha(67) = 0
           alpha(68) = 0
           alpha(69) = -1
           alpha(70) = 0
           alpha(71) = 0
           alpha(72) = 0
           alpha(73) = 0
           alpha(74) = 0
           alpha(75) = 0
           alpha(76) = 0
           alpha(77) = 0
           alpha(78) = 0
           alpha(79) = 0
           alpha(80) = 0
           alpha(81) = 0
           alpha(82) = 0
           alpha(83) = 0
           alpha(84) = 0
           alpha(85) = 0
           alpha(86) = 1
           alpha(87) = 0
           alpha(88) = 0
           alpha(89) = 0
           alpha(90) = 0
           alpha(91) = 0
           alpha(92) = 0
           alpha(93) = 0
           alpha(94) = 0
           alpha(95) = 0
           alpha(96) = 0
           alpha(97) = 0
           alpha(98) = 0
           alpha(99) = 0
           alpha(100) = 0
           alpha(101) = 0
           alpha(102) = 0
           alpha(103) = 1
           alpha(104) = 0
           alpha(105) = 0
           alpha(106) = 0
           alpha(107) = 0
           alpha(108) = 0
           alpha(109) = 0
           alpha(110) = 0
           alpha(111) = 0
           alpha(112) = 0
           alpha(113) = 0
           alpha(114) = 0
           alpha(115) = 0
           alpha(116) = 0
           alpha(117) = 0
           alpha(118) = 0
           alpha(119) = 0
           alpha(120) = 1
           alpha(121) = 0
           alpha(122) = 0
           alpha(123) = 0
           alpha(124) = 0
           alpha(125) = 0
           alpha(126) = 0
           alpha(127) = 0
           alpha(128) = 0
           alpha(129) = 0
           alpha(130) = 0
           alpha(131) = 0
           alpha(132) = 0
           alpha(133) = 0
           alpha(134) = 0
           alpha(135) = 0
           alpha(136) = 0
           alpha(137) = -1
           alpha(138) = 0
           alpha(139) = 0
           alpha(140) = 0
           alpha(141) = 0
           alpha(142) = 0
           alpha(143) = 0
           alpha(144) = 0
           alpha(145) = 0
           alpha(146) = 0
           alpha(147) = 0
           alpha(148) = 0
           alpha(149) = 0
           alpha(150) = 0
           alpha(151) = 0
           alpha(152) = 0
           alpha(153) = 0
           alpha(154) = 1
           alpha(155) = 0
           alpha(156) = 0
           alpha(157) = 0
           alpha(158) = 0
           alpha(159) = 0
           alpha(160) = 0
           alpha(161) = 0
           alpha(162) = 0
           alpha(163) = 0
           alpha(164) = 0
           alpha(165) = 0
           alpha(166) = 0
           alpha(167) = 0
           alpha(168) = 0
           alpha(169) = 0
           alpha(170) = 0
           alpha(171) = 1
           alpha(172) = 0
           alpha(173) = 0
           alpha(174) = 0
           alpha(175) = 0
           alpha(176) = 0
           alpha(177) = 0
           alpha(178) = 0
           alpha(179) = 0
           alpha(180) = 0
           alpha(181) = 0
           alpha(182) = 0
           alpha(183) = 0
           alpha(184) = 0
           alpha(185) = 0
           alpha(186) = 0
           alpha(187) = 0
           alpha(188) = 1
           alpha(189) = 0
           alpha(190) = 0
           alpha(191) = 0
           alpha(192) = 0
           alpha(193) = 0
           alpha(194) = 0
           alpha(195) = 0
           alpha(196) = 0
           alpha(197) = 0
           alpha(198) = 0
           alpha(199) = 0
           alpha(200) = 0
           alpha(201) = 0
           alpha(202) = 0
           alpha(203) = 0
           alpha(204) = 0
           alpha(205) = -1
           alpha(206) = 0
           alpha(207) = 0
           alpha(208) = 0
           alpha(209) = 0
           alpha(210) = 0
           alpha(211) = 0
           alpha(212) = 0
           alpha(213) = 0
           alpha(214) = 0
           alpha(215) = 0
           alpha(216) = 0
           alpha(217) = 0
           alpha(218) = 0
           alpha(219) = 0
           alpha(220) = 0
           alpha(221) = 0
           alpha(222) = 1
           alpha(223) = 0
           alpha(224) = 0
           alpha(225) = 0
           alpha(226) = 0
           alpha(227) = 0
           alpha(228) = 0
           alpha(229) = 0
           alpha(230) = 0
           alpha(231) = 0
           alpha(232) = 0
           alpha(233) = 0
           alpha(234) = 0
           alpha(235) = 0
           alpha(236) = 0
           alpha(237) = 0
           alpha(238) = 0
           alpha(239) = 1
           alpha(240) = 0
           alpha(241) = 0
           alpha(242) = 0
           alpha(243) = 0
           alpha(244) = 0
           alpha(245) = 0
           alpha(246) = 0
           alpha(247) = 0
           alpha(248) = 0
           alpha(249) = 0
           alpha(250) = 0
           alpha(251) = 0
           alpha(252) = 0
           alpha(253) = 0
           alpha(254) = 0
           alpha(255) = 0
           alpha(256) = 1           
C
           return
           end
C***********************************************************************
          subroutine scalscalscal(alfaprime)            
C***********************************************************************
C
C This subroutine return the lorentz interaction matrix for a cubic
C scalar interaction
C
          implicit none
C
          complex*16 alfaprime        !storing the result of the "lorentz product"
C
          dimension alfaprime(1)
C
          alfaprime(1) = (1.,0.)
C 
          return
          end
C***********************************************************************
          subroutine psibarpsiphi(alfaprime)     
C***********************************************************************
C
C This subroutine return the lorentz interaction matrix for a yukawa interaction
C scalar interaction
C
          implicit none
C
          integer j1          !loop index
          complex*16 alfaprime        !storing the result of the "lorentz product"
C
          dimension alfaprime(16)
C
          do j1=1,16
           alfaprime(j1)=0.
          enddo
          alfaprime(1)=(1.,0.)
          alfaprime(6)=(1.,0.)
          alfaprime(11)=(1.,0.)
          alfaprime(6)=(1.,0.)
C 
          return
          end
C***********************************************************************
          subroutine lorentz(const1,nlor1)
C***********************************************************************
C
C This subroutine returns the number of lorentz degrees of freedom of
C the field corresponding to const1
C
          implicit none
C
          integer nlor1       !storing the numer of coulor degrees of freedom of
C                              the particles in field1
          real*8 const1       !containing the characteristic of the field:
C                              2) Lorentz nature 
C
          if (nint(const1).eq.1) then
           nlor1=1  !auxiliar scalar field 
          elseif (nint(const1).eq.2) then 
           nlor1=1  !scalar field
          elseif (nint(const1).eq.3) then
           nlor1=4    !fermion
          elseif (nint(const1).eq.4) then
           nlor1=4    !fermionbar
          elseif (nint(const1).eq.5) then
           nlor1=4    !massive gauge boson
          elseif (nint(const1).eq.6) then
           nlor1=4    !massless gauge boson
          elseif (nint(const1).eq.7) then
           nlor1=10    !auxiliar tensor field G_mn  (symmetric) for gluons
          elseif (nint(const1).eq.8) then
           nlor1=16    !auxiliar tensor field G_mn  (symmetric) for gluons
          else
           write(6,*)'wrong lorentz index',const1,'in LORENTZ'
           stop
          endif
C
          return
          end
C***********************************************************************
          subroutine compconf(nmom1,nmom2,num1,num2,newc,perm) 
C***********************************************************************
C
C This subroutine given the label of two field configuration NC1 and NC2
C return the new field configuration NEWC produced as the product of the
C former one. If no allowed product arise NEWC is set to 0.
C
          implicit none
C
          integer nmax     !dimension of the arrays CONF, CONF1 and CONF2
          parameter (nmax=8)  !maximum number of external particle, change here
          integer acceptable  !flag to check wether the building up 
C                              configuration is allowed
          integer conf(nmax)        !to store the new field configuration
          integer conf1(nmax),conf2(nmax)       !to store the old field configuration
          integer confperm(nmax)    !array to compute the sign of the permutation
          integer j1          !loop label
          integer label       !array label
          integer nmom1,nmom2         !to store the number of momenta 
          integer next        !number of external particles
          integer nfermion
          integer num1,num2        !to store the label of the configuration
          integer newc       !to store a new label number
C
          real*8 perm
C                                change this number this has to be modified
C
          common/external/next,nfermion  !containing the number of external
C                                     particles from the subroutine ??????
C
          call seleconf(nmom1,num1,conf1)  !reconstructing the field 
C                                           configuration
          call seleconf(nmom2,num2,conf2)
C
          j1=1
          acceptable=1
          do while (acceptable.eq.1.and.j1.le.next)
           conf(j1)=conf1(j1)+conf2(j1)            !making the "product of the
C                                                     two configurations
           if(conf(j1).ne.0.and.conf(j1).ne.j1) acceptable=0 !each external 
C                        momenta should not contribute to a new configuration
C                        more than one
           j1=j1+1
          enddo
C
          if (acceptable.eq.1) then
           call findlabel(conf,newc,nmom1+nmom2)  !searching for the labels 
C
           if (nfermion.ne.0) then                 !computing the sign of the
            label=0                                !fermion permutation.
            do j1=1,nfermion                       !the array confperm store
             if (conf1(j1).ne.0) then              !FIRST the momenta of CONF1
              label=label+1                        !THEN  the momenta of CONF2
              confperm(label)=conf1(j1)            !permuting these elemnts to
             endif                               !reobtain the standard ordering
            enddo                                  !will allow to compute the
            do j1=1,nfermion                    !sign of the fermion permutation
             if (conf2(j1).ne.0) then
              label=label+1
              confperm(label)=conf2(j1)
             endif
            enddo
           endif
           perm=1.
           if (label.ge.2) call permutation(confperm,perm,label) !it will  
C                                    return the sign of the permutation in PERM
C
          else
           newc=0                       !this configuration is not allowed
          endif
C
          return
          end
C***********************************************************************
          subroutine compconflag(nmom1,nmom2,num1,num2,newc,perm) 
C***********************************************************************
C
C This subroutine given the label of two field configuration NC1 and NC2
C return the new field configuration NEWC produced as the product of the
C former one. If no allowed product arise NEWC is set to 0.
C
          implicit none
C
          integer nmax  !dimension of the arrays CONF, CONF1, CONF2 and CONFPERM
          parameter (nmax=8)  !maximum number of external particle, change here
          integer acceptable  !flag to check wether the building up 
C                              configuration is allowed
          integer conf(nmax)        !to store the new field configuration
          integer conf1(nmax),conf2(nmax)       !to store the old field configuration
          integer confperm(nmax)    !array to be used to compute the sign of the
C                              fermion permutation       
          integer j1          !loop label
          integer label       !array label
          integer next        !number of external particles
          integer nfermion
          integer nmom1,nmom2         !to store the number of momenta 
          integer num1,num2        !to sotre the label of the configuration
          integer newc       !to store a new label number
C
          real*8 perm        !sign of the fermion permutation
C
          common/external/next,nfermion  !containing the number of external
C                                     particles from the subroutine ??????
C
          call seleconf(nmom1,num1,conf1)  !reconstructing the field 
C                                           configuration
          call seleconf(nmom2,num2,conf2)
C
          j1=1
          acceptable=1
          do while (acceptable.eq.1.and.j1.le.next)
           conf(j1)=conf1(j1)+conf2(j1)            !making the "product of the
C                                                     two configurations
           if(conf(j1).ne.0.and.conf(j1).ne.j1) acceptable=0 !each external 
C                        momenta should not contribute to a new configuration
C                        more than one
           j1=j1+1
          enddo
C
          if (acceptable.eq.1) then
           do j1=1,next
            if (conf(j1).eq.0) then     !finding the complementary configuration
             conf(j1)=j1
            else
             conf(j1)=0
            endif
           enddo
           call findlabel(conf,newc,next-nmom1-nmom2)  !searching for the labels
C                                                   of the new configuration
C
           if (nfermion.ne.0) then                 !computing the sign of the
            label=0                                !fermion permutation.
            do j1=1,nfermion                       !the array confperm store
             if (conf1(j1).ne.0) then              !FIRST the momenta of CONF1
              label=label+1                        !THEN  the momenta of CONF2
              confperm(label)=conf1(j1)               !permuting these elemnts to
             endif                               !reobtain the standard ordering
            enddo                                  !will allow to compute the
            do j1=1,nfermion                    !sign of the fermion permutation
             if (conf2(j1).ne.0) then
              label=label+1
              confperm(label)=conf2(j1)
             endif
            enddo
            do j1=1,nfermion                    
             if (conf(j1).ne.0) then
              label=label+1
              confperm(label)=conf(j1)
             endif
            enddo
           endif
           perm=1.
           if (label.ge.2) call permutation(confperm,perm,label) !it will  
C                                    return the sign of the permutation in PERM
          else
           newc=0                       !this configuration is not allowed
          endif
C
          return
          end
C***********************************************************************
          subroutine seleconf(nmom1,num1,conf1)
C***********************************************************************
C
C This subroutine given the label of a field configuration NUM1 and
C the number of the momenta NMOM1 which contribute to it 
C return the field configuration CONF1 which is an array of N=8=maximal
C number of external particle element. The n-th element of the array is
C n if the n-th external momentum contribute to this configuration,
C 0 otherwise
C
          implicit none
C
          integer dim1,dim2,dim3,dim4  !dimension of the array CONFIGURATION1,2,3,4
          integer nmax     !dimension of the array CONF
          parameter (dim1=8,dim2=28,dim3=56,dim4=70) !these numbers are calculated as:
C                    DIMj=N!/j!/(N-j)!    where again N=NMAX number of external
C                     particle. Wishing to change NMAX these numbers have to be   changed
          parameter (nmax=8)  !maximum number of external particle, change  here
          integer conf1(nmax)   !to store the new field configuration
          integer configuration1,configuration2,
     >             configuration3,configuration4  !it stores all the configuration with 1,2,3,4
C                                   momenta contributing
          integer j1          !loop indices
          integer nmom1       !label of the configuration
          integer num1      !number of mometa contributing to the configuration
          integer next        !containing the number of external particles
          integer nfermion
C
          common/external/next,nfermion  !containing the number of external
C                                     particles from the subroutine ??????
          common/momconfig/configuration1(dim1,nmax),
     >             configuration2(dim2,nmax),configuration3(dim3,nmax),
     >                 configuration4(dim4,nmax)   !All this configuration are
C                            obtained in the subroutine CONFIGURATION. 
C
          goto (1,2,3,4),nmom1 !the pourpose of the labels is only
C                                           to create a menu
C
          write(6,*)'In subroutine SELECONF I have been given the'
          write(6,*)'label',nmom1,' to search for. This label is not'
          write(6,*)'in my labels table.'
C
          stop
C
  1       do j1=1,nmax 
           conf1(j1)=configuration1(num1,j1)
          enddo
          return
C
  2       do j1=1,nmax
           conf1(j1)=configuration2(num1,j1)
          enddo
          return
C
  3       do j1=1,nmax
           conf1(j1)=configuration3(num1,j1)
          enddo
          return
C
  4       do j1=1,nmax
           conf1(j1)=configuration4(num1,j1)
          enddo
          return
C
          end
C***********************************************************************
          subroutine findlabel(conf1,newc,nmom)
C***********************************************************************
C
C This subroutine given  a field configuration CONF made up of NMOM momenta
C return its corresponding label NEWC. 
C
          implicit none
C
          integer dim1,dim2,dim3,dim4  !dimension of the array CONFIGURATION1,2,3,4
          integer nmax     !dimension of the array CONF
          parameter (dim1=8,dim2=28,dim3=56,dim4=70) !these numbers are calculated as:
C                    DIMj=N!/j!/(N-j)!    where again N=NMAX number of external
C                     particle. Wishing to change NMAX these numbers have to be   changed
          parameter (nmax=8)  !maximum number of external particle, change  here
          integer conf1(nmax)   !to store the new field configuration
          integer configuration1,configuration2,
     >             configuration3,configuration4  !it stores all the configuration with 1,2,3,4
C                                   momenta contributing
          integer ddim1,ddim2,ddim3,ddim4        !number of elemEnts in CONFIGURATION1 among
C                               which the configuration has to be looked for
          integer find1,find2       !flag to check wether the correct configuration
C                              has been found
          integer j1,j2          !loop index
          integer next        !number of external particles
          integer newc        !to store the label of the new configuration
          integer nmom        !containing the number ofo contributing momenta
C                              on which searching for the configuration
          integer nfermion
C
          common/dimens/ddim1,ddim2,ddim3,ddim4 !number of excitations for
C                 CONFIGURATION1,2,3,4 computed in subroutine CONFIGURATION
          common/external/next,nfermion  !containing the number of external
C                                     particles from the subroutine ??????
          common/momconfig/configuration1(dim1,nmax),
     >           configuration2(dim2,nmax),configuration3(dim3,nmax),
     >                 configuration4(dim4,nmax)   !All this configuration are
C                             obtained in the subroutine CONFIGURATION.
C
C we now have to implement the fact that if NEXT is odd only half
C of the dim-NEXT/2 elements contribute
C
          newc=0
          goto (1,2,3,4), nmom      !the pourpose of the labels is only
C                                           to create a menu
          write (6,*)'In subroutine FINDLABEL I have been given the '
          write (6,*)'label',nmom,' to search for. This label is not'
          write (6,*)'in my labels table.'
C
          stop
C
C All the following instruction separated be a string of CCCCCC are exactly equal. 
C It changes only the array which is used to search for the configuration.
C
 1        j1=1
          find1=0
          do while (find1.eq.0.and.j1.le.ddim1)    !loop to search for the right
C                             configuration. It has to stop when this is found
           j2=1
           find2=1
           do while (find2.eq.1.and.j2.le.next)
            if (configuration1(j1,j2).ne.conf1(j2)) find2=0 !the two 
C                   configurations are different, stop the j2 loop.           
            j2=j2+1
           enddo
C
           if (find2.eq.1) then     !we have found the right configuration
            find1=1                 !stop the j1 loop
            newc=j1                 !store the label of the new configuration
           endif
C
           j1=j1+1
C
          enddo
          if (find1.ne.1.and.dim1.eq.ddim1) 
     >       write(6,*)'mistake in FINDLABEL'
          return
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
 2        j1=1
          find1=0
          do while (find1.eq.0.and.j1.le.ddim2)    !loop to search for the right
C                             configuration. It has to stop when this is found
           j2=1
           find2=1
           do while (find2.eq.1.and.j2.le.next)
            if (configuration2(j1,j2).ne.conf1(j2)) find2=0 !the two 
C                   configurations are different, stop the j2 loop.           
            j2=j2+1
           enddo
C
           if (find2.eq.1) then     !we have found the right configuration
            find1=1                 !stop the j1 loop
            newc=j1                 !store the label of the new configuration
           endif
C
           j1=j1+1
C
          enddo
          if (find1.ne.1.and.dim2.eq.ddim2) 
     >       write(6,*)'mistake in FINDLABEL'
          return
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
 3        j1=1
          find1=0
          do while (find1.eq.0.and.j1.le.ddim3)    !loop to search for the right
C                             configuration. It has to stop when this is found
           j2=1
           find2=1
           do while (find2.eq.1.and.j2.le.next)
            if (configuration3(j1,j2).ne.conf1(j2)) find2=0 !the two 
C                   configurations are different, stop the j2 loop.           
            j2=j2+1
           enddo
C
           if (find2.eq.1) then     !we have found the right configuration
            find1=1                 !stop the j1 loop
            newc=j1                 !store the label of the new configuration
           endif
C
           j1=j1+1
C
          enddo
          if (find1.ne.1.and.dim3.eq.ddim3) 
     >       write(6,*)'mistake in FINDLABEL'
          return
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
 4        j1=1
          find1=0
          do while (find1.eq.0.and.j1.le.ddim4)    !loop to search for the right
C                             configuration. It has to stop when this is found
           j2=1
           find2=1
           do while (find2.eq.1.and.j2.le.next)
            if (configuration4(j1,j2).ne.conf1(j2)) find2=0 !the two 
C                   configurations are different, stop the j2 loop.           
            j2=j2+1
           enddo
C
           if (find2.eq.1) then     !we have found the right configuration
            find1=1                 !stop the j1 loop
            newc=j1                 !store the label of the new configuration
           endif
C
           j1=j1+1
C
          enddo
          if (find1.ne.1.and.dim4.eq.ddim4) 
     >       write(6,*)'mistake in FINDLABEL'
          return
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
          end
C***********************************************************************
          subroutine configuration
C***********************************************************************
C
C This subroutine stores the momenta configurations with 1,...,4
C momenta in the array CONFIGURATION1,2,3,4
C
          implicit none
C
          integer dim1,dim2,dim3,dim4    !dimension of the array CONFIGURATION1,2,3,4
          integer nmax        !maximal number of external particles
          parameter (dim1=8,dim2=28,dim3=56,dim4=70)  !these numbers are calculated as:
          parameter (nmax=8)   !maximal number of external particles change here
C                               of esternal particles change here
C               particle. Wishing to change this number these numbers have to be changed
          integer configuration1,configuration2,
     >            configuration3,configuration4  !it stores all the 
C             configuration with 1,2,3,4 momenta contributing again this 
C             assumes N=NMAX number of external particles. Wishing to change 
C             NMAX the number and the dimensions of these arrays has to be modified
          integer ddim1,ddim2,ddim3,ddim4       !number of excitation with 1 momenta
          integer j1,j2,j3,j4,j5          !loop index
          integer next        !number of external particles
          integer nfermion
          common/dimens/ddim1,ddim2,ddim3,ddim4 !number of excitations for
C                 CONFIGURATION1,2,3,4 computed in subroutine CONFIGURATION
          common/external/next,nfermion  !containing the number of external
C                                     particles from the subroutine ??????
          common/momconfig/configuration1(dim1,nmax),
     >          configuration2(dim2,nmax),configuration3(dim3,nmax),
     >                 configuration4(dim4,nmax)   
C
           call zeroarrayint(configuration1,nmax*dim1)
           call zeroarrayint(configuration2,nmax*dim2)
           call zeroarrayint(configuration3,nmax*dim3)
           call zeroarrayint(configuration4,nmax*dim4)
C
C  filling CONFIGURATION1
C
           j1=1
           do j2=1,next
            configuration1(j1,j2)=j2
            j1=j1+1
           enddo
           ddim1=j1-1
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C  filling CONFIGURATION2
C
           j1=1
           do j2=1,next
            if (j2+1.le.next) then
             do j3=j2+1,next
              configuration2(j1,j2)=j2
              configuration2(j1,j3)=j3
              j1=j1+1
             enddo
            endif
           enddo
           ddim2=j1-1
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C  filling CONFIGURATION3
C
           j1=1
           do j2=1,next
            if (j2+1.le.next) then
             do j3=j2+1,next
              if (j3+1.le.next) then
               do j4=j3+1,next
                configuration3(j1,j2)=j2
                configuration3(j1,j3)=j3
                configuration3(j1,j4)=j4
                j1=j1+1
               enddo
              endif
             enddo
            endif
           enddo
           ddim3=j1-1
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C  filling CONFIGURATION4
C
           j1=1
           do j2=1,next
            if (j2+1.le.next) then
             do j3=j2+1,next
              if (j3+1.le.next) then
               do j4=j3+1,next
                if (j4+1.le.next) then
                 do j5=j4+1,next
                  configuration4(j1,j2)=j2
                  configuration4(j1,j3)=j3
                  configuration4(j1,j4)=j4
                  configuration4(j1,j5)=j5
                  j1=j1+1
                 enddo
                endif
               enddo
              endif
             enddo
            endif
           enddo
           ddim4=j1-1
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C Again everything is tuned to N=8=maximal number of external particles 
C everything has to be changed accordingly if one wishes to change N
C
          if(next.eq.4)ddim2=ddim2/2      !to keep only the relevant configurations
          if(next.eq.6)ddim3=ddim3/2
          if(next.eq.8)ddim4=ddim4/2
C
          return
          end
C***********************************************************************
          subroutine fermionsources(spinsour,fieldaux ,mom,mass)
C***********************************************************************
C
C This subroutine return the initialized fermion field.
C Elicity heigenstates
C 
          implicit none
C
          real*8  mass         !containing the mass of the external particle
          real*8  mom(4)          !array containing the momenta of the external particle
          integer  spinsour    !array containing the spin of the source
          real*8 p,p3p,p3m,mp,coeffp,coeffm
C                               
          complex*16 fieldaux(4)  !array returning the fermion field configuration
          complex*16 im/(0.,1.)/  !immaginary unity in complex representation
          complex*16 p1p
C
C
C Static variables
C
          save im
C
          p=sqrt(mom(2)**2+mom(3)**2+mom(4)**2)
          p3p=p+mom(4)
          p3m=p-mom(4)
          mp=mass+mom(1)
          p1p=mom(2)+mom(3)*im
C
          if(abs(p3m).lt.1.d-10.or.abs(p3p).lt.1.d-10)then
           call fs(spinsour,fieldaux ,mom,mass)
           return
          endif
C
          coeffp=1./Sqrt(2.*p*mp*p3p)
          coeffm=1./Sqrt(2.*p*mp*p3m)
C
C "spin up" ingoing fermion
C
           if (spinsour.eq.49) then
            fieldaux(1)=coeffp*p3p*mp
            fieldaux(2)=coeffp*p1p*mp
            fieldaux(3)=coeffp*p3p*p
            fieldaux(4)=coeffp*p1p*p
C
C "spin down" ingoing fermion
C
           elseif (spinsour.eq.-49) then
            fieldaux(1)=coeffm*p3m*mp
            fieldaux(2)=-coeffm*p1p*mp
            fieldaux(3)=-coeffm*p3m*p
            fieldaux(4)=coeffm*p1p*p
C
C "spin up" outgoing antifermion
C
           elseif (spinsour.eq.51) then
            fieldaux(1)=-coeffm*p3m*p
            fieldaux(2)=coeffm*p1p*p
            fieldaux(3)=coeffm*p3m*mp
            fieldaux(4)=-coeffm*p1p*mp
C
C "spin down" outgoing antifermion
C
           elseif (spinsour.eq.-51) then
            fieldaux(1)=coeffp*p3p*p 
            fieldaux(2)=coeffp*p1p*p
            fieldaux(3)=coeffp*p3p*mp
            fieldaux(4)=coeffp*p1p*mp
           else
            write(6,*)'wrong SPINSOUR for fermions'
           endif
C
           return
           end

C***********************************************************************
          subroutine fermionbarsources(spinsour,fieldaux ,mom,mass)
C***********************************************************************
C
C This subroutine return the initialized fermionbar field.
C Elicity heigenstates
C 
          implicit none
C
          real*8  mass         !containing the mass of the external particle
          real*8  mom(4)          !array containing the momenta of the external particle
          integer spinsour    !array containing the spin of the source
          real*8 p,p3p,p3m,mp,coeffp,coeffm
C                               
          complex*16 fieldaux(4)     !array returning the fermion field configuration
          complex*16 im/(0.,1.)/  !immaginary unity in complex representation
          complex*16 p1p
C
C Static variables
C
          save im
C
C
          p=sqrt(mom(2)**2+mom(3)**2+mom(4)**2)
          p3p=p+mom(4)
          p3m=p-mom(4)
          mp=mass+mom(1)
          p1p=mom(2)-mom(3)*im
C
          if(abs(p3m).lt.1.d-10.or.abs(p3p).lt.1.d-10)then
           call fbs(spinsour,fieldaux ,mom,mass)
           return
          endif
C
          coeffp=1./Sqrt(2.*p*mp*p3p)
          coeffm=1./Sqrt(2.*p*mp*p3m)
C
C "spin up" ingoing fermion
C
           if (spinsour.eq.49) then
            fieldaux(1)=coeffp*p3p*mp
            fieldaux(2)=coeffp*p1p*mp
            fieldaux(3)=-coeffp*p3p*p
            fieldaux(4)=-coeffp*p1p*p
C
C "spin down" ingoing fermion
C
           elseif (spinsour.eq.-49) then
            fieldaux(1)=coeffm*p3m*mp
            fieldaux(2)=-coeffm*p1p*mp
            fieldaux(3)=coeffm*p3m*p
            fieldaux(4)=-coeffm*p1p*p
C
C "spin up" outgoing antifermion
C
           elseif (spinsour.eq.51) then
            fieldaux(1)=-coeffm*p3m*p
            fieldaux(2)=coeffm*p1p*p
            fieldaux(3)=-coeffm*p3m*mp
            fieldaux(4)=coeffm*p1p*mp
C
C "spin down" outgoing antifermion
C
           elseif (spinsour.eq.-51) then
            fieldaux(1)=coeffp*p3p*p 
            fieldaux(2)=coeffp*p1p*p
            fieldaux(3)=-coeffp*p3p*mp
            fieldaux(4)=-coeffp*p1p*mp
           else
            write(6,*)'wrong SPINSOUR for fermions'
           endif
C
           return
           end

C***********************************************************************
          subroutine fs(spinsour,fieldaux ,mom,mass)
C***********************************************************************
C
C This subroutine return the initialized fermion field.
C 
          implicit none
C
          real*8  mass         !containing the mass of the external particle
          real*8  mom(4)       !array containing the momenta of the external particle
          integer spinsour    !array containing the spin of the source
C                               
          complex*16 fieldaux(4)     !array returning the fermion field configuration
          complex*16 im/(0.,1.)/  !immaginary unity in complex representation
C
C Static variables
C
          save im
C
C
C "spin up" ingoing fermion
C
           if (spinsour.eq.49) then
            fieldaux(1)=sqrt((mom(1)+mass))
            fieldaux(2)=0. 
            fieldaux(3)=mom(4)/sqrt((mass+mom(1)))         
            fieldaux(4)=mom(2)/sqrt((mass+mom(1)))
     >                         + mom(3)/sqrt((mass+mom(1)))*im          
C
C "spin down" ingoing fermion
C
           elseif (spinsour.eq.-49) then
            fieldaux(1)=0.
            fieldaux(2)=sqrt((mom(1)+mass)) 
            fieldaux(3)= mom(2)/sqrt((mass+mom(1)))
     >                         - mom(3)/sqrt((mass+mom(1)))*im         
            fieldaux(4)=-mom(4)/sqrt((mass+mom(1)))
C
C "spin up" outgoing antifermion
C
           elseif (spinsour.eq.51) then
            fieldaux(1)=mom(4)/sqrt((mass+mom(1)))         
            fieldaux(2)=mom(2)/sqrt((mass+mom(1)))
     >                         + mom(3)/sqrt((mass+mom(1)))*im          
            fieldaux(3)=sqrt((mom(1)+mass))
            fieldaux(4)=0. 
C
C "spin down" outgoing antifermion
C
           elseif (spinsour.eq.-51) then
            fieldaux(1)= mom(2)/sqrt((mass+mom(1)))
     >                         - mom(3)/sqrt((mass+mom(1)))*im         
            fieldaux(2)=-mom(4)/sqrt((mass+mom(1)))
            fieldaux(3)=0.
            fieldaux(4)=sqrt((mom(1)+mass))          
           else
            write(6,*)'wrong SPINSOUR for fermions'
           endif
C
           return
           end
C***********************************************************************
          subroutine fbs(spinsour,fieldaux,mom,mass)
C***********************************************************************
C
C This subroutine return the initialized fermion field.
C 
          implicit none
C
          real*8  mass        !containing the mass of the external particle
          real*8  mom(4)      !array containing the momenta of the external particle
          integer spinsour    !array containing the spin of the source
C                               
          complex*16 fieldaux(4)   !array returning the fermionbar field configuration
          complex*16 im/(0.,1.)/           !immaginary unity in complex representation
C
C Static variables
C
          save im
C
C
C "spin up" outgoing fermion
C
           if (spinsour.eq.49) then
            fieldaux(1)=sqrt((mom(1)+mass))
            fieldaux(2)=0. 
            fieldaux(3)=-mom(4)/sqrt((mass+mom(1)))         
            fieldaux(4)=-mom(2)/sqrt((mass+mom(1)))
     >                         +mom(3)/sqrt((mass+mom(1)))*im          
C
C "spin down" outgoing fermion
C
           elseif (spinsour.eq.-49) then
            fieldaux(1)=0.
            fieldaux(2)=sqrt((mom(1)+mass)) 
            fieldaux(3)= -mom(2)/sqrt((mass+mom(1)))
     >                         - mom(3)/sqrt((mass+mom(1)))*im         
            fieldaux(4)=mom(4)/sqrt((mass+mom(1)))
C
C "spin up" ingoing antifermion
C
           elseif (spinsour.eq.51) then
            fieldaux(1)=-mom(4)/sqrt((mass+mom(1)))         
            fieldaux(2)=-mom(2)/sqrt((mass+mom(1)))
     >                          +mom(3)/sqrt((mass+mom(1)))*im          
            fieldaux(3)=sqrt((mom(1)+mass))
            fieldaux(4)=0. 
C
C "spin down" ingoing antifermion
C
           elseif (spinsour.eq.-51) then
            fieldaux(1)= -mom(2)/sqrt((mass+mom(1)))
     >                         - mom(3)/sqrt((mass+mom(1)))*im         
            fieldaux(2)=mom(4)/sqrt((mass+mom(1)))
            fieldaux(3)=0.
            fieldaux(4)=sqrt((mom(1)+mass))          
           else
            write(6,*)'wrong SPINSOUR for fermions'
           endif
C
           return
           end
C***********************************************************************
          subroutine pslashplusmtr(newc,iteration,pslplm,m1,w1,bar)   
C***********************************************************************
C
C Returns the inverse propagator in the array PSLPLM for a fermionbar particle 
C with momentum defined by NEWC and ITERATION
C
          implicit none
C
          integer nmax       !maximal number of external particles, change here
          parameter (nmax=8)  
          integer iteration     !iteration number
          integer j1         !loop index
C
          real*8  bar         !flag distinguishing among fermion and fermionbar
          real*8  internal    !array of flags to decide wether the particle is
C                              internal or external
          integer newc       !to store a new label number
          integer next       !number of external particles
          integer nfermion
C
          real*8 m1          !particle mass
          real*8 mom(4)      !momentum fo teh present configuration
          real*8 momenta     !array containing the external momenta
          real*8  w1          !width
C
          complex*16 den
          complex*16 im/(0.,1.)/  !immaginary unit
          complex*16 pslplm(16)   !storing the relevant component of pslash+m
C
          common/external/next,nfermion  !containing the number of external
C                                     particles from the subroutine ??????
          common/momenta/momenta(nmax,4),internal(nmax)
C
C
C Static variables
C
          save im
C
          call findmom(iteration,newc,mom)
          do j1=1,4
           mom(j1)=-mom(j1)
          enddo
C
          pslplm(1)= mom(1)+m1
          pslplm(2)= 0.
          pslplm(3)= mom(4)
          pslplm(4)= mom(2)+mom(3)*im
          pslplm(5)= 0.
          pslplm(6)=  mom(1)+m1
          pslplm(7)= mom(2)-mom(3)*im
          pslplm(8)= -mom(4)
          pslplm(9)= -mom(4)
          pslplm(10)= -mom(2)-mom(3)*im
          pslplm(11)= -mom(1)+m1
          pslplm(12)= 0.
          pslplm(13)= -mom(2)+mom(3)*im
          pslplm(14)= mom(4)
          pslplm(15)= 0.
          pslplm(16)= -mom(1)+m1
C
          den=mom(1)*mom(1)-mom(2)*mom(2)-mom(3)*mom(3)-mom(4)*mom(4)
          den=den-m1*m1
          den=1./den
          do j1=1,16
           pslplm(j1)=pslplm(j1)*den
          enddo
C
          return
          end
C***********************************************************************
          subroutine pslashplusm(newc,iteration,pslplm,m1,w1,bar)   
C***********************************************************************
C
C Returns the inverse propagator in the array PSLPLM for a fermion particle with
C momentum defined by NEWC and ITERATION
C
          implicit none
C
          integer nmax       !maximal number of external particles, change here
          parameter (nmax=8)  
          integer iteration   !iteration number
          integer j1          !loop index
          integer newc       !to store a new label number
          integer next       !number of external particles
          integer nfermion
C
          real*8  bar         !flag distinguishing among fermion and fermionbar
          real*8  internal    !array of flags to decide wether the particle is
          real*8 m1           !particle mass
          real*8 mom(4)       !momentum fo teh present configuration
          real*8 momenta     !array containing the external momenta
C                              internal or external
          real*8  w1          !width
C
          complex*16 im/(0.,1.)/     !immaginary unit
          complex*16 pslplm(16)     !storing the relevant component of pslash+m
          complex*16 den
C
          common/external/next,nfermion  !containing the number of external
C                                     particles from the subroutine ??????
          common/momenta/momenta(nmax,4),internal(nmax)
C
C
C Static variables
C
          save im
C
          call findmom(iteration,newc,mom)
C
          pslplm(1)= mom(1)+m1
          pslplm(2)= 0.
          pslplm(3)= -mom(4)
          pslplm(4)= -mom(2)+mom(3)*im
          pslplm(5)= 0.
          pslplm(6)=  mom(1)+m1
          pslplm(7)= -mom(2)-mom(3)*im
          pslplm(8)= mom(4)
          pslplm(9)= mom(4)
          pslplm(10)= mom(2)-mom(3)*im
          pslplm(11)= -mom(1)+m1
          pslplm(12)= 0.
          pslplm(13)= mom(2)+mom(3)*im
          pslplm(14)= -mom(4)
          pslplm(15)= 0.
          pslplm(16)= -mom(1)+m1
C
          den=mom(1)*mom(1)-mom(2)*mom(2)-mom(3)*mom(3)-mom(4)*mom(4)
          den=den-m1*m1
          den=1./den
          do j1=1,16
           pslplm(j1)=pslplm(j1)*den
          enddo
C
          return
          end
C***********************************************************************
          subroutine permutation(confperm,perm,nfermion) 
C***********************************************************************
C
C This Subroutine returns the sign of the fermion permutation in the variable
C PERM
C
          implicit none
C
          integer nmax        !maximal number of external particles, change here
          parameter (nmax=8)  
          integer confperm(nmax) !array to compute the sign of the permutation
          integer nfermion    !number of external fermions
          integer j1,j2          !loop label
          integer parking1    !to store momentarily elemnts of 
C
          real*8 perm
C
          perm=1.
          if (nfermion.gt.1) then       !compute the sign of the permutation
           do j1=nfermion-1,1,-1
            do j2=1,j1
             if(confperm(j2).gt.confperm(j2+1)) then
              parking1=confperm(j2)
              confperm(j2)=confperm(j2+1)
              confperm(j2+1)=parking1
              perm=-perm
             endif
            enddo
           enddo
          endif
C
          return
          end
C***********************************************************************
          subroutine order (label,ordering)
C***********************************************************************
C
C It will return in LABEL the correct label order for the relevant operator
C according ot the ordering setted in order
C
          implicit none
C
          integer j1       !loop index
          integer label(3)    !it will contain the correct indices for the relevant
C                           operator
          integer ordering(3)    !it contains the order of the indices for the 
C                           relevant operator
          integer parking(3)  !for temporary storing
C
          do j1=1,3
           parking(j1)=label(j1)
          enddo
          do j1=1,3
           label(ordering(j1))=parking(j1)
          enddo
C 
          return
          end
C***********************************************************************
          subroutine exchange(field1,field2,mom1,mom2,numb1,numb2,
     >     const1,iteration)
C***********************************************************************
C
C This subroutine given two  field configuration FIELD1 and  FIELD2
C whose corresponding parents momenta are recorded in MOM1, and MOM2
C exchange all the information (FIELD, MOM and NUMB) obtained at the ITERATION
C step. This is required because the derivative of a complex fied contribute
C to build up not the field itself but rather its complex conjugate.
C
          implicit none
C
          integer dimfiel      !dimension of the array field1,2,3
          integer dimnum       !dimension of the array numb1,2,3
          integer dimmom       !dimension of the array mom1,2,3
          integer dimcons      !dimension of the array cons1,2,3
          integer nmax         !maximal numer of external particles, change here
          integer nlormax !maximal number of lorentz and color 
C                                   degrees of freedom change here
          parameter (nmax=8)
          parameter (nlormax=16)
          parameter (dimcons=5)      
          parameter (dimmom=(2**nmax-2)/2)     
          parameter (dimfiel=nlormax*dimmom)  
          parameter (dimnum=nmax/2)      !storing the number of configuration
C                                    with 1,...,7 momenta contributing
          integer iteration   !storing the present iteration stage
          integer interval1,interval2   !setting the interval for the loops for particle 1
          integer j1          !loop variable
          integer mom1(dimmom),mom2(dimmom)        !array containing a label for each indipendent
C                              momentum configuration. 
          integer mompark(dimmom)    !for temporay storing of MOM1
          integer nlor1      !storing the number of lorentz degrees of freedom
          integer numb1(dimnum),numb2(dimnum)      !to the number of momenta contributing
C                             to the configuration under exam
          integer numbpark(dimnum)   !for temporay storing of NUM1
          integer start1,start2 !setting the starting point for the loops for particle 1
C
          real*8 const1(dimcons)
C
          complex*16 field1(dimfiel),field2(dimfiel)      !array containing the 
C                        field configuration of the two field to exchange
          complex*16 fieldpark(dimfiel)   !for temporay storing of FIELD1
C
           start1=0                        !all this configurations are ok
           start2=0                        !all this configurations are ok
           do j1=1,iteration-1
            start1=start1+numb1(j1)
            start2=start2+numb2(j1)
           enddo
C
           call lorentz(const1(2),nlor1)    !returning the number of lorentz
C                                         degrees of freedom of FIELD1,2
C
           interval1=numb1(iteration)     !all this configurations should be 
C                                          exchanged   
           interval2=numb2(iteration)     !all this configurations should be 
C                                          exchanged   
C
C  exchanging NUMB1(ITERATION) abd NUMB2(ITERATION)
C
          numbpark(iteration)=numb1(iteration)
          numb1(iteration)=numb2(iteration)
          numb2(iteration)=numbpark(iteration)
C
C  exchanging MOM1 abd MOM2 generated at the iteration step
C
          if (interval1.ne.0) then
           do j1=1,interval1
            mompark(j1)=mom1(j1+start1)
           enddo
          endif
          if (interval2.ne.0) then
           do j1=1,interval2
            mom1(j1+start1)=mom2(j1+start2)
           enddo
          endif
          if (interval1.ne.0) then
           do j1=1,interval1
            mom2(j1+start2)=mompark(j1)
           enddo
          endif
C
C  exchanging FIELD1 abd FIELD2 generated at the iteration step
C
          start1=start1*nlor1
          start2=start2*nlor1
          interval1=interval1*nlor1
          interval2=interval2*nlor1
          if (interval1.ne.0) then
           do j1=1,interval1
            fieldpark(j1)=field1(j1+start1)
           enddo
          endif
          if (interval2.ne.0) then
           do j1=1,interval2
            field1(j1+start1)=field2(j1+start2)
           enddo
          endif
          if (interval1.ne.0) then
           do j1=1,interval1
            field2(j1+start2)=fieldpark(j1)
           enddo
          endif
C
           return
           end
C***************************************************************************
          subroutine sourcemassboson(spinsour,fieldaux,mom,mass)
C***************************************************************************
C
C This subroutine given the four momentum of a massive boson MOM the required
C source polarization SPINSOUR and the boson mass MASS returns in
C FIELDAUX the source term
C
          implicit none
C
          integer n               !loop index
C
          real*8 knorm2           !squared modulus of the three momentum
          real*8 mass             !massive boson mass
          real*8 massa2           !squared mass
          real*8 mom(4)           !four momentum
          real*8 nz(4)/0.,0.,0.,1./,nx(4)/0.,1.,0.,0./
          real*8 sour1(4)/4*0./,sour2(4)/4*0./,sour3(4)/4*0./   !longitudinal (1)
C                                and transverse (2,3) polarizations
          real*8 spinsour   !required polarization
          real*8 scalar3
          real*8 xnorm      !to normalize the sources
C
          complex*16 fieldaux(4)   !to return the relevan polarization
C
C
          save nx,nz
C
          knorm2=mom(2)**2+mom(3)**2+mom(4)**2  
C
          if (knorm2.eq.0) then
           sour1(2)=1.
           sour2(3)=1.
           sour3(4)=1.
           return
          endif
          massa2=mass**2       
C
C    pol. longitudinal
C
          do n=2,4
           sour1(n)=mom(n)
          enddo
	  sour1(1)=knorm2/mom(1)
          xnorm=sqrt(scalar3(sour1,sour1))
          if(xnorm.ne.0.) then
           do n=1,4
            sour1(n)=sour1(n)/xnorm
           enddo
          endif
C
C    pol. transverse +
C
          if (mom(4)**2.gt.mom(2)**2) then 
           call vector3prod(mom,nx,sour2)
          else 
           call vector3prod(mom,nz,sour2)  
          endif
          xnorm=Sqrt(scalar3(sour2,sour2))
          do n=1,4
           sour2(n)=sour2(n)/xnorm
          enddo
C
C    pol. transverse -
C
          call vector3prod(mom,sour2,sour3)
          xnorm=sqrt(scalar3(sour3,sour3))
          do n=1,4
           sour3(n)=sour3(n)/xnorm
          enddo
C
          do n=1,4
           fieldaux(n)=0.
           if(nint(spinsour).eq.0)fieldaux(n)=sour1(n)
           if(nint(spinsour).eq.1)fieldaux(n)=sour2(n)
           if(nint(spinsour).eq.-1)fieldaux(n)=sour3(n)
          enddo
C
          return
          end
C*********************************************************************
	  subroutine vector3prod(v1,v2,vfin)
C*********************************************************************
C
          implicit none
C
           real*8 v1(4)
           real*8 v2(4)
           real*8 vfin(4)
C
           vfin(2)=v1(3)*v2(4)-v1(4)*v2(3)   
           vfin(3)=v1(4)*v2(2)-v1(2)*v2(4)   
           vfin(4)=v1(2)*v2(3)-v1(3)*v2(2)   
           vfin(1)=0 
C                                               
           return 
           end 
C*********************************************************************** 
           function scalar3(v1,v2)
C***********************************************************************
C
           implicit none
C
           real*8 scalar3
	   real*8 v1(4)
           real*8 v2(4)
C
           scalar3=abs(v1(1)*v2(1)-v1(2)*v2(2)-v1(3)*v2(3)-v1(4)*v2(4)) 
C
            return
            end                                                  
C***********************************************************************
	subroutine gammamat(gamtemp)
C***********************************************************************
C
C Returns a*V + b*A interactions, needs to be modified for multiple processes
C
	implicit none
C
	integer n1,n2,n3,m1,sign,label,flag(100)/100*0/
C
        complex*16 a,b,c1,c2
        complex*16  gamtemp(64),gamtemp1(4,4,4),gam(4,4,5),
     >              iden(4,4),gammastore(64,100)
C
        common/vecass/a,b,c1,c2
C
     	data gam/(1.,0.),(0.,0),(0.,0.),(0.,0.),(0.,0.)
     >     ,(1.,0.),(0.,0.),(0.,0.),(0.,0.),(0.,0.),
     >  (-1.,0.),(0.,0.),(0.,0.),(0.,0.), (0.,0.),(-1.,0.),          !gamma0
     >  (0.,0.),(0.,0.),(0.,0.),(1.,0.),(0.,0.),
     >  (0.,0.),(1.,0.),(0.,0.),(0.,0.),(-1.,0.),
     >  (0.,0.),(0.,0.),(-1.,0.),(0.,0.),(0.,0.),(0.,0.),             !gamma1
     >  (0.,0.),(0.,0.),(0.,0.),(0.,-1.),(0.,0.), 
     >  (0.,0.),(0.,1.),(0.,0.),(0.,0.),(0.,1.), 
     >  (0.,0.),(0.,0.),(0.,-1.),(0.,0.),(0.,0.), (0.,0.),           !gamma2
     >  (0.,0.),(0.,0.),(1.,0.),(0.,0.),(0.,0.),
     >  (0.,0.),(0.,0.),(-1.,0.),(-1.,0.),(0.,0.),
     >  (0.,0.),(0.,0.),(0.,0.),(1.,0.),(0.,0.),(0.,0.),              !gamma3
     >  (0.,0.),(0.,0.),(1.,0.),(0.,0.),(0.,0.), 
     >  (0.,0.),(0.,0.),(1.,0.),(1.,0.),(0.,0.),
     >   (0.,0.),(0.,0.),(0.,0.),(1.,0.),(0.,0.),(0.,0.)/           !gamma5
        data iden/(1.,0.), (0.,0.), (0.,0.), (0.,0.),
     *   (0.,0.), (1.,0.),(0.,0.), (0.,0.), (0.,0.), (0.,0.),
     *   (1.,0.), (0.,0.),(0.,0.), (0.,0.), (0.,0.), (1.,0.)/
C
C
C Static variables
C
          save gam,iden,gammastore
C
        label=nint(abs(4*(c1-1)+c2))
        if (label.gt.100) then
         write(6,*)'label overflow in GAMMAMAT'
         stop
        endif
        if (flag(label).eq.0) then
         flag(label)=1
         do n1=1,4
       	  do n2=1,4
           do n3=1,4
            gamtemp1(n1,n2,n3)=0
            do m1=1,4	 
             gamtemp1(n1,n2,n3)=gam(m1,n1,n3)*
     *         (a*iden(m1,n2)+b*gam(n2,m1,5))+gamtemp1(n1,n2,n3)
            enddo 
           enddo
          enddo
         enddo         
C
         do n1=0,3
          do n2=0,3
           do n3=0,3
            if (16*n3+4*n2+n1+1.gt.16) then
             sign=-1
            else
             sign=1
            endif
            gamtemp(16*n3+4*n2+n1+1)=gamtemp1(n2+1,n1+1,n3+1)*sign
           enddo
          enddo
         enddo
C
         do n1=1,64
          gammastore(n1,label)=gamtemp(n1)
         enddo
         else
         call equalcomparrays(gammastore(1,label),gamtemp,64)
        endif
C
        return
	end
C***********************************************************************
          subroutine gmnminkmkn(newc,iteration,pslplm,m1,w1)
C***********************************************************************
C
C Returns the inverse propagator in the array PSLPLM for a massive boson
C  particle with momentum defined by NEWC and ITERATION
C
          implicit none
C
          integer nmax          !maximal number of external particles, change here
          parameter (nmax=8)  
c          integer conf1(nmax)      !array containing the configuration
          integer iteration        !iteration number
          integer j1               !loop index
          integer newc          !to store a new label number
          integer next          !number of external particles
          integer nfermion
C
          real*8 internal
          real*8 m1,w1                !particle mass and width
          real*8 mom(4)            !momentum for the present configuration
          real*8 momenta        !array containing the external momenta
          real*8 pq
          complex*16 pole
C
          complex*16 pqm            !momentum squared - particle mass squared
          complex*16 pslplm(16)  !storing the relevant component of pslash+m
C
          common/external/next,nfermion  !containing the number of external
C                                     particles from the subroutine ??????
          common/cmomentum/momenta(nmax,4),internal(nmax)
C
          call findmom(iteration,newc,mom)
C
          pqm=m1**2 -(0,1)*m1*w1
C
          pslplm(1)= pqm-mom(1)*mom(1)
          pslplm(2)= -mom(1)*mom(2)
          pslplm(3)= -mom(1)*mom(3)
          pslplm(4)= -mom(1)*mom(4)
          pslplm(5)= pslplm(2)
          pslplm(6)=-pqm-mom(2)*mom(2)
          pslplm(7)= -mom(2)*mom(3)
          pslplm(8)= -mom(2)*mom(4)
          pslplm(9)= pslplm(3)
          pslplm(10)= pslplm(7)
          pslplm(11)= -pqm-mom(3)*mom(3)
          pslplm(12)= -mom(3)*mom(4)
          pslplm(13)= pslplm(4)
          pslplm(14)= pslplm(8)
          pslplm(15)= pslplm(12)
          pslplm(16)= -pqm-mom(4)*mom(4)
C
          pq=mom(1)**2-mom(2)**2-mom(3)**2 -mom(4)**2
c          theta=0.
c          if (pq.gt.0)theta=1
C
c          pole=-1./(pq-m1*m1+theta*pq*w1*(0.,1.)/m1)
          pole=-1./(pq-m1*m1+w1*(0.,1.)*m1)
C
          do j1=1,16
           pslplm(j1)=pslplm(j1)*pole/pqm
          enddo
C
          return
          end
C***********************************************************************
          subroutine gmnminkmkny(newc,iteration,pslplm,m1,w1)
C***********************************************************************
C
C Returns the inverse propagator in the array PSLPLM for a massive boson
C  particle with momentum defined by NEWC and ITERATION
C
          implicit none
C
          integer nmax          !maximal number of external particles, change here
          parameter (nmax=8)  
          integer iteration        !iteration number
          integer j1               !loop index
          integer newc          !to store a new label number
          integer next          !number of external particles
          integer nfermion
C
          real*8 internal
          real*8 m1,w1                !particle mass and width
          real*8 mom(4)            !momentum for the present configuration
          real*8 momenta        !array containing the external momenta
          real*8 pq
C
          complex*16 pqm            !momentum squared - particle mass squared
          complex*16 pslplm(16)  !storing the relevant component of pslash+m
C
          common/external/next,nfermion  !containing the number of external
C                                     particles from the subroutine ??????
          common/momenta/momenta(nmax,4),internal(nmax)
C
          call findmom(iteration,newc,mom)
C
          pqm=m1**2
C
          pslplm(1)= pqm-mom(1)*mom(1)
          pslplm(2)= -mom(1)*mom(2)
          pslplm(3)= -mom(1)*mom(3)
          pslplm(4)= -mom(1)*mom(4)
          pslplm(5)= pslplm(2)
          pslplm(6)=-pqm-mom(2)*mom(2)
          pslplm(7)= -mom(2)*mom(3)
          pslplm(8)= -mom(2)*mom(4)
          pslplm(9)= pslplm(3)
          pslplm(10)= pslplm(7)
          pslplm(11)= -pqm-mom(3)*mom(3)
          pslplm(12)= -mom(3)*mom(4)
          pslplm(13)= pslplm(4)
          pslplm(14)= pslplm(8)
          pslplm(15)= pslplm(12)
          pslplm(16)= -pqm-mom(4)*mom(4)
C
          pq=mom(1)**2-mom(2)**2-mom(3)**2 -mom(4)**2
c          theta=0.
c          if (pq.gt.0)theta=1
C
c          pqm=-1./(pq-pqm+theta*pq*w1*(0.,1.)/m1)/pqm
          pqm=-1./(pq-pqm+w1*(0.,1.)*m1)/pqm
C
          do j1=1,16
           pslplm(j1)=pslplm(j1)*pqm
          enddo
C
          return
          end
C***********************************************************************
        subroutine wpwmz(k1,k2,k3,alpha)
C***********************************************************************
C
C Returns the trilinear boson self interaction (su(2) group W^+ W^- Z)
C Optimize here!
        implicit none
C
        real*8 k1(4),k2(4),k3(4),gv,kv,lv,gv5
        common/anz/gv,kv,lv,gv5
C
        complex*16 alpha(64)
C
        k3(1)=-k3(1)
        k2(1)=-k2(1)
        k1(1)=-k1(1)
C
        alpha(1)=0
        alpha(2)=
     >  -(kv*k1(2))+gv*k2(2)-
     >   lv*(-(k1(3)*k2(2)*k3(3))+k1(2)*k2(3)*k3(3)-k1(4)*k2(2)*k3(4)+
     >      k1(2)*k2(4)*k3(4))
        alpha(3)=
     >  -(kv*k1(3))+gv*k2(3)-
     >   lv*(k1(3)*k2(2)*k3(2)-k1(2)*k2(3)*k3(2)-k1(4)*k2(3)*k3(4)+
     >      k1(3)*k2(4)*k3(4))
        alpha(4)=
     >  -(kv*k1(4))+gv*k2(4)-
     >   lv*(k1(4)*k2(2)*k3(2)-k1(2)*k2(4)*k3(2)+k1(4)*k2(3)*k3(3)-
     >      k1(3)*k2(4)*k3(3))
        alpha(5)=
     >  kv*k1(2)-gv*k3(2)-lv*
     >    (k1(3)*k2(3)*k3(2)+k1(4)*k2(4)*k3(2)-k1(2)*k2(3)*k3(3)-
     >      k1(2)*k2(4)*k3(4))
        alpha(6)=
     >  gv*k2(1)-gv*k3(1)-lv*
     >    (k1(3)*k2(3)*k3(1)+k1(4)*k2(4)*k3(1)-k1(3)*k2(1)*k3(3)-
     >      k1(4)*k2(1)*k3(4))
        alpha(7)=
     >  -(lv*(-(k1(2)*k2(3)*k3(1))+k1(3)*k2(1)*k3(2)))+
     >   (0,1)*gv5*(k2(4)-k3(4))
        alpha(8)=
     >  -(lv*(-(k1(2)*k2(4)*k3(1))+k1(4)*k2(1)*k3(2)))+
     >   (0,1)*gv5*(-k2(3)+k3(3))
        alpha(9)=
     >  kv*k1(3)-gv*k3(3)-lv*
     >    (-(k1(3)*k2(2)*k3(2))+k1(2)*k2(2)*k3(3)+k1(4)*k2(4)*k3(3)-
     >      k1(3)*k2(4)*k3(4))
        alpha(10)=
     >  -(lv*(-(k1(3)*k2(2)*k3(1))+k1(2)*k2(1)*k3(3)))+
     >   (0,1)*gv5*(-k2(4)+k3(4))
        alpha(11)=
     >  gv*k2(1)-gv*k3(1)-lv*
     >    (k1(2)*k2(2)*k3(1)+k1(4)*k2(4)*k3(1)-k1(2)*k2(1)*k3(2)-
     >      k1(4)*k2(1)*k3(4))
        alpha(12)=
     >  (0,1)*gv5*(k2(2)-k3(2))-
     >   lv*(-(k1(3)*k2(4)*k3(1))+k1(4)*k2(1)*k3(3))
        alpha(13)=
     >  kv*k1(4)-gv*k3(4)-lv*
     >    (-(k1(4)*k2(2)*k3(2))-k1(4)*k2(3)*k3(3)+k1(2)*k2(2)*k3(4)+
     >      k1(3)*k2(3)*k3(4))
        alpha(14)=
     >  (0,1)*gv5*(k2(3)-k3(3))-
     >   lv*(-(k1(4)*k2(2)*k3(1))+k1(2)*k2(1)*k3(4))
        alpha(15)=
     >  (0,1)*gv5*(-k2(2)+k3(2))-
     >   lv*(-(k1(4)*k2(3)*k3(1))+k1(3)*k2(1)*k3(4))
        alpha(16)=
     >  gv*k2(1)-gv*k3(1)-lv*
     >    (k1(2)*k2(2)*k3(1)+k1(3)*k2(3)*k3(1)-k1(2)*k2(1)*k3(2)-
     >      k1(3)*k2(1)*k3(3))
        alpha(17)=
     >  -(gv*k2(2))+gv*k3(2)-
     >   lv*(-(k1(3)*k2(3)*k3(2))-k1(4)*k2(4)*k3(2)+k1(3)*k2(2)*k3(3)+
     >      k1(4)*k2(2)*k3(4))
        alpha(18)=
     >  -(kv*k1(1))+gv*k3(1)-
     >   lv*(-(k1(3)*k2(3)*k3(1))-k1(4)*k2(4)*k3(1)+k1(1)*k2(3)*k3(3)+
     >      k1(1)*k2(4)*k3(4))
        alpha(19)=
     >  -(lv*(k1(3)*k2(2)*k3(1)-k1(1)*k2(3)*k3(2)))+
     >   (0,1)*gv5*(-k2(4)+k3(4))
        alpha(20)=
     >  -(lv*(k1(4)*k2(2)*k3(1)-k1(1)*k2(4)*k3(2)))+
     >   (0,1)*gv5*(k2(3)-k3(3))
        alpha(21)=
     >  kv*k1(1)-gv*k2(1)-lv*
     >    (k1(3)*k2(1)*k3(3)-k1(1)*k2(3)*k3(3)+k1(4)*k2(1)*k3(4)-
     >      k1(1)*k2(4)*k3(4))
        alpha(22)=0
        alpha(23)=
     >  kv*k1(3)-gv*k2(3)-lv*
     >    (k1(3)*k2(1)*k3(1)-k1(1)*k2(3)*k3(1)+k1(4)*k2(3)*k3(4)-
     >      k1(3)*k2(4)*k3(4))
        alpha(24)=
     >  kv*k1(4)-gv*k2(4)-lv*
     >    (k1(4)*k2(1)*k3(1)-k1(1)*k2(4)*k3(1)-k1(4)*k2(3)*k3(3)+
     >      k1(3)*k2(4)*k3(3))
        alpha(25)=
     >  -(lv*(-(k1(3)*k2(1)*k3(2))+k1(1)*k2(2)*k3(3)))+
     >   (0,1)*gv5*(k2(4)-k3(4))
        alpha(26)=
     >  -(kv*k1(3))+gv*k3(3)-
     >   lv*(-(k1(3)*k2(1)*k3(1))+k1(1)*k2(1)*k3(3)-k1(4)*k2(4)*k3(3)+
     >      k1(3)*k2(4)*k3(4))
        alpha(27)=
     >  gv*k2(2)-gv*k3(2)-lv*
     >    (k1(1)*k2(2)*k3(1)-k1(1)*k2(1)*k3(2)+k1(4)*k2(4)*k3(2)-
     >      k1(4)*k2(2)*k3(4))
        alpha(28)=
     >  (0,1)*gv5*(-k2(1)+k3(1))-
     >   lv*(-(k1(3)*k2(4)*k3(2))+k1(4)*k2(2)*k3(3))
        alpha(29)=
     >  (0,1)*gv5*(-k2(3)+k3(3))-
     >   lv*(-(k1(4)*k2(1)*k3(2))+k1(1)*k2(2)*k3(4))
        alpha(30)=
     >  -(kv*k1(4))+gv*k3(4)-
     >   lv*(-(k1(4)*k2(1)*k3(1))+k1(4)*k2(3)*k3(3)+k1(1)*k2(1)*k3(4)-
     >      k1(3)*k2(3)*k3(4))
        alpha(31)=
     >  (0,1)*gv5*(k2(1)-k3(1))-
     >   lv*(-(k1(4)*k2(3)*k3(2))+k1(3)*k2(2)*k3(4))
        alpha(32)=
     >  gv*k2(2)-gv*k3(2)-lv*
     >    (k1(1)*k2(2)*k3(1)-k1(1)*k2(1)*k3(2)+k1(3)*k2(3)*k3(2)-
     >      k1(3)*k2(2)*k3(3))
        alpha(33)=
     >  -(gv*k2(3))+gv*k3(3)-
     >   lv*(k1(2)*k2(3)*k3(2)-k1(2)*k2(2)*k3(3)-k1(4)*k2(4)*k3(3)+
     >      k1(4)*k2(3)*k3(4))
        alpha(34)=
     >  -(lv*(k1(2)*k2(3)*k3(1)-k1(1)*k2(2)*k3(3)))+
     >   (0,1)*gv5*(k2(4)-k3(4))
        alpha(35)=
     >  -(kv*k1(1))+gv*k3(1)-
     >   lv*(-(k1(2)*k2(2)*k3(1))-k1(4)*k2(4)*k3(1)+k1(1)*k2(2)*k3(2)+
     >      k1(1)*k2(4)*k3(4))
        alpha(36)=
     >  (0,1)*gv5*(-k2(2)+k3(2))-
     >   lv*(k1(4)*k2(3)*k3(1)-k1(1)*k2(4)*k3(3))
        alpha(37)=
     >  -(lv*(k1(1)*k2(3)*k3(2)-k1(2)*k2(1)*k3(3)))+
     >   (0,1)*gv5*(-k2(4)+k3(4))
        alpha(38)=
     >  gv*k2(3)-gv*k3(3)-lv*
     >    (k1(1)*k2(3)*k3(1)-k1(1)*k2(1)*k3(3)+k1(4)*k2(4)*k3(3)-
     >      k1(4)*k2(3)*k3(4))
        alpha(39)=
     >  -(kv*k1(2))+gv*k3(2)-
     >   lv*(-(k1(2)*k2(1)*k3(1))+k1(1)*k2(1)*k3(2)-k1(4)*k2(4)*k3(2)+
     >      k1(2)*k2(4)*k3(4))
        alpha(40)=
     >  (0,1)*gv5*(k2(1)-k3(1))-lv*(k1(4)*k2(3)*k3(2)-k1(2)*k2(4)*k3(3))
        alpha(41)=
     >  kv*k1(1)-gv*k2(1)-lv*
     >    (k1(2)*k2(1)*k3(2)-k1(1)*k2(2)*k3(2)+k1(4)*k2(1)*k3(4)-
     >      k1(1)*k2(4)*k3(4))
        alpha(42)=
     >  kv*k1(2)-gv*k2(2)-lv*
     >    (k1(2)*k2(1)*k3(1)-k1(1)*k2(2)*k3(1)+k1(4)*k2(2)*k3(4)-
     >      k1(2)*k2(4)*k3(4))
        alpha(43)=0
        alpha(44)=
     >  kv*k1(4)-gv*k2(4)-lv*
     >    (k1(4)*k2(1)*k3(1)-k1(1)*k2(4)*k3(1)-k1(4)*k2(2)*k3(2)+
     >      k1(2)*k2(4)*k3(2))
        alpha(45)=
     >  (0,1)*gv5*(k2(2)-k3(2))-
     >   lv*(-(k1(4)*k2(1)*k3(3))+k1(1)*k2(3)*k3(4))
        alpha(46)=
     >  (0,1)*gv5*(-k2(1)+k3(1))-
     >   lv*(-(k1(4)*k2(2)*k3(3))+k1(2)*k2(3)*k3(4))
        alpha(47)=
     >  -(kv*k1(4))+gv*k3(4)-
     >   lv*(-(k1(4)*k2(1)*k3(1))+k1(4)*k2(2)*k3(2)+k1(1)*k2(1)*k3(4)-
     >      k1(2)*k2(2)*k3(4))
        alpha(48)=
     >  gv*k2(3)-gv*k3(3)-lv*
     >    (k1(1)*k2(3)*k3(1)-k1(2)*k2(3)*k3(2)-k1(1)*k2(1)*k3(3)+
     >      k1(2)*k2(2)*k3(3))
        alpha(49)=
     >  -(gv*k2(4))+gv*k3(4)-
     >   lv*(k1(2)*k2(4)*k3(2)+k1(3)*k2(4)*k3(3)-k1(2)*k2(2)*k3(4)-
     >      k1(3)*k2(3)*k3(4))
        alpha(50)=
     >  (0,1)*gv5*(-k2(3)+k3(3))-
     >   lv*(k1(2)*k2(4)*k3(1)-k1(1)*k2(2)*k3(4))
        alpha(51)=
     >  (0,1)*gv5*(k2(2)-k3(2))-lv*(k1(3)*k2(4)*k3(1)-k1(1)*k2(3)*k3(4))
        alpha(52)=
     >  -(kv*k1(1))+gv*k3(1)-
     >   lv*(-(k1(2)*k2(2)*k3(1))-k1(3)*k2(3)*k3(1)+k1(1)*k2(2)*k3(2)+
     >      k1(1)*k2(3)*k3(3))
        alpha(53)=
     >  (0,1)*gv5*(k2(3)-k3(3))-lv*(k1(1)*k2(4)*k3(2)-k1(2)*k2(1)*k3(4))
        alpha(54)=
     >  gv*k2(4)-gv*k3(4)-lv*
     >    (k1(1)*k2(4)*k3(1)-k1(3)*k2(4)*k3(3)-k1(1)*k2(1)*k3(4)+
     >      k1(3)*k2(3)*k3(4))
        alpha(55)=
     >  (0,1)*gv5*(-k2(1)+k3(1))-
     >   lv*(k1(3)*k2(4)*k3(2)-k1(2)*k2(3)*k3(4))
        alpha(56)=
     >  -(kv*k1(2))+gv*k3(2)-
     >   lv*(-(k1(2)*k2(1)*k3(1))+k1(1)*k2(1)*k3(2)-k1(3)*k2(3)*k3(2)+
     >      k1(2)*k2(3)*k3(3))
        alpha(57)=
     >  (0,1)*gv5*(-k2(2)+k3(2))-
     >   lv*(k1(1)*k2(4)*k3(3)-k1(3)*k2(1)*k3(4))
        alpha(58)=
     >  (0,1)*gv5*(k2(1)-k3(1))-lv*(k1(2)*k2(4)*k3(3)-k1(3)*k2(2)*k3(4))
        alpha(59)=
     >  gv*k2(4)-gv*k3(4)-lv*
     >    (k1(1)*k2(4)*k3(1)-k1(2)*k2(4)*k3(2)-k1(1)*k2(1)*k3(4)+
     >      k1(2)*k2(2)*k3(4))
        alpha(60)=
     >  -(kv*k1(3))+gv*k3(3)-
     >   lv*(-(k1(3)*k2(1)*k3(1))+k1(3)*k2(2)*k3(2)+k1(1)*k2(1)*k3(3)-
     >      k1(2)*k2(2)*k3(3))
        alpha(61)=
     >  kv*k1(1)-gv*k2(1)-lv*
     >    (k1(2)*k2(1)*k3(2)-k1(1)*k2(2)*k3(2)+k1(3)*k2(1)*k3(3)-
     >      k1(1)*k2(3)*k3(3))
        alpha(62)=
     >  kv*k1(2)-gv*k2(2)-lv*
     >    (k1(2)*k2(1)*k3(1)-k1(1)*k2(2)*k3(1)+k1(3)*k2(2)*k3(3)-
     >      k1(2)*k2(3)*k3(3))
        alpha(63)=
     >  kv*k1(3)-gv*k2(3)-lv*
     >    (k1(3)*k2(1)*k3(1)-k1(1)*k2(3)*k3(1)-k1(3)*k2(2)*k3(2)+
     >      k1(2)*k2(3)*k3(2))
        alpha(64)=0
C
        return
        end
C***********************************************************************
        subroutine wpwmg(k1,k2,k3,alpha)
C***********************************************************************
C
C Returns the trilinear boson self interaction (su(2) group W^+ W^- Z)
C Optimize here!
        implicit none
C
        real*8 k1(4),k2(4),k3(4),kp,lp
        common/ang/kp,lp
C
        complex*16 alpha(64)
C
        k3(1)=-k3(1)
        k2(1)=-k2(1)
        k1(1)=-k1(1)
C
        alpha(1)=0
        alpha(2)=
     >  -(kp*k1(2))+k2(2)+lp*
     >    (-(k1(3)*k2(2)*k3(3))+k1(2)*k2(3)*k3(3)-k1(4)*k2(2)*k3(4)+
     >      k1(2)*k2(4)*k3(4))
        alpha(3)=
     >  -(kp*k1(3))+k2(3)+lp*
     >    (k1(3)*k2(2)*k3(2)-k1(2)*k2(3)*k3(2)-k1(4)*k2(3)*k3(4)+
     >      k1(3)*k2(4)*k3(4))
        alpha(4)=
     >  -(kp*k1(4))+k2(4)+lp*
     >    (k1(4)*k2(2)*k3(2)-k1(2)*k2(4)*k3(2)+k1(4)*k2(3)*k3(3)-
     >      k1(3)*k2(4)*k3(3))
        alpha(5)=
     >  kp*k1(2)-k3(2)+lp*(k1(3)*k2(3)*k3(2)+k1(4)*k2(4)*k3(2)-
     >      k1(2)*k2(3)*k3(3)-k1(2)*k2(4)*k3(4))
        alpha(6)=
     >  k2(1)-k3(1)+lp*(k1(3)*k2(3)*k3(1)+k1(4)*k2(4)*k3(1)-
     >      k1(3)*k2(1)*k3(3)-k1(4)*k2(1)*k3(4))
        alpha(7)=lp*(-(k1(2)*k2(3)*k3(1))+k1(3)*k2(1)*k3(2))
        alpha(8)=lp*(-(k1(2)*k2(4)*k3(1))+k1(4)*k2(1)*k3(2))
        alpha(9)=
     >  kp*k1(3)-k3(3)+lp*(-(k1(3)*k2(2)*k3(2))+k1(2)*k2(2)*k3(3)+
     >      k1(4)*k2(4)*k3(3)-k1(3)*k2(4)*k3(4))
        alpha(10)=lp*(-(k1(3)*k2(2)*k3(1))+k1(2)*k2(1)*k3(3))
        alpha(11)=
     >  k2(1)-k3(1)+lp*(k1(2)*k2(2)*k3(1)+k1(4)*k2(4)*k3(1)-
     >      k1(2)*k2(1)*k3(2)-k1(4)*k2(1)*k3(4))
        alpha(12)=lp*(-(k1(3)*k2(4)*k3(1))+k1(4)*k2(1)*k3(3))
        alpha(13)=
     >  kp*k1(4)-k3(4)+lp*(-(k1(4)*k2(2)*k3(2))-k1(4)*k2(3)*k3(3)+
     >      k1(2)*k2(2)*k3(4)+k1(3)*k2(3)*k3(4))
        alpha(14)=lp*(-(k1(4)*k2(2)*k3(1))+k1(2)*k2(1)*k3(4))
        alpha(15)=lp*(-(k1(4)*k2(3)*k3(1))+k1(3)*k2(1)*k3(4))
        alpha(16)=
     >  k2(1)-k3(1)+lp*(k1(2)*k2(2)*k3(1)+k1(3)*k2(3)*k3(1)-
     >      k1(2)*k2(1)*k3(2)-k1(3)*k2(1)*k3(3))
        alpha(17)=
     >  -k2(2)+k3(2)+lp*(-(k1(3)*k2(3)*k3(2))-k1(4)*k2(4)*k3(2)+
     >      k1(3)*k2(2)*k3(3)+k1(4)*k2(2)*k3(4))
        alpha(18)=
     >  -(kp*k1(1))+k3(1)+lp*
     >    (-(k1(3)*k2(3)*k3(1))-k1(4)*k2(4)*k3(1)+k1(1)*k2(3)*k3(3)+
     >      k1(1)*k2(4)*k3(4))
        alpha(19)=lp*(k1(3)*k2(2)*k3(1)-k1(1)*k2(3)*k3(2))
        alpha(20)=lp*(k1(4)*k2(2)*k3(1)-k1(1)*k2(4)*k3(2))
        alpha(21)=
     >  kp*k1(1)-k2(1)+lp*(k1(3)*k2(1)*k3(3)-k1(1)*k2(3)*k3(3)+
     >      k1(4)*k2(1)*k3(4)-k1(1)*k2(4)*k3(4))
        alpha(22)=0
        alpha(23)=
     >  kp*k1(3)-k2(3)+lp*(k1(3)*k2(1)*k3(1)-k1(1)*k2(3)*k3(1)+
     >      k1(4)*k2(3)*k3(4)-k1(3)*k2(4)*k3(4))
        alpha(24)=
     >  kp*k1(4)-k2(4)+lp*(k1(4)*k2(1)*k3(1)-k1(1)*k2(4)*k3(1)-
     >      k1(4)*k2(3)*k3(3)+k1(3)*k2(4)*k3(3))
        alpha(25)=lp*(-(k1(3)*k2(1)*k3(2))+k1(1)*k2(2)*k3(3))
        alpha(26)=
     >  -(kp*k1(3))+k3(3)+lp*
     >    (-(k1(3)*k2(1)*k3(1))+k1(1)*k2(1)*k3(3)-k1(4)*k2(4)*k3(3)+
     >      k1(3)*k2(4)*k3(4))
        alpha(27)=
     >  k2(2)-k3(2)+lp*(k1(1)*k2(2)*k3(1)-k1(1)*k2(1)*k3(2)+
     >      k1(4)*k2(4)*k3(2)-k1(4)*k2(2)*k3(4))
        alpha(28)=lp*(-(k1(3)*k2(4)*k3(2))+k1(4)*k2(2)*k3(3))
        alpha(29)=lp*(-(k1(4)*k2(1)*k3(2))+k1(1)*k2(2)*k3(4))
        alpha(30)=
     >  -(kp*k1(4))+k3(4)+lp*
     >    (-(k1(4)*k2(1)*k3(1))+k1(4)*k2(3)*k3(3)+k1(1)*k2(1)*k3(4)-
     >      k1(3)*k2(3)*k3(4))
        alpha(31)=lp*(-(k1(4)*k2(3)*k3(2))+k1(3)*k2(2)*k3(4))
        alpha(32)=
     >  k2(2)-k3(2)+lp*(k1(1)*k2(2)*k3(1)-k1(1)*k2(1)*k3(2)+
     >      k1(3)*k2(3)*k3(2)-k1(3)*k2(2)*k3(3))
        alpha(33)=
     >  -k2(3)+k3(3)+lp*(k1(2)*k2(3)*k3(2)-k1(2)*k2(2)*k3(3)-
     >      k1(4)*k2(4)*k3(3)+k1(4)*k2(3)*k3(4))
        alpha(34)=lp*(k1(2)*k2(3)*k3(1)-k1(1)*k2(2)*k3(3))
        alpha(35)=
     >  -(kp*k1(1))+k3(1)+lp*
     >    (-(k1(2)*k2(2)*k3(1))-k1(4)*k2(4)*k3(1)+k1(1)*k2(2)*k3(2)+
     >      k1(1)*k2(4)*k3(4))
        alpha(36)=lp*(k1(4)*k2(3)*k3(1)-k1(1)*k2(4)*k3(3))
        alpha(37)=lp*(k1(1)*k2(3)*k3(2)-k1(2)*k2(1)*k3(3))
        alpha(38)=
     >  k2(3)-k3(3)+lp*(k1(1)*k2(3)*k3(1)-k1(1)*k2(1)*k3(3)+
     >      k1(4)*k2(4)*k3(3)-k1(4)*k2(3)*k3(4))
        alpha(39)=
     >  -(kp*k1(2))+k3(2)+lp*
     >    (-(k1(2)*k2(1)*k3(1))+k1(1)*k2(1)*k3(2)-k1(4)*k2(4)*k3(2)+
     >      k1(2)*k2(4)*k3(4))
        alpha(40)=lp*(k1(4)*k2(3)*k3(2)-k1(2)*k2(4)*k3(3))
        alpha(41)=
     >  kp*k1(1)-k2(1)+lp*(k1(2)*k2(1)*k3(2)-k1(1)*k2(2)*k3(2)+
     >      k1(4)*k2(1)*k3(4)-k1(1)*k2(4)*k3(4))
        alpha(42)=
     >  kp*k1(2)-k2(2)+lp*(k1(2)*k2(1)*k3(1)-k1(1)*k2(2)*k3(1)+
     >      k1(4)*k2(2)*k3(4)-k1(2)*k2(4)*k3(4))
        alpha(43)=0
        alpha(44)=
     >  kp*k1(4)-k2(4)+lp*(k1(4)*k2(1)*k3(1)-k1(1)*k2(4)*k3(1)-
     >      k1(4)*k2(2)*k3(2)+k1(2)*k2(4)*k3(2))
        alpha(45)=lp*(-(k1(4)*k2(1)*k3(3))+k1(1)*k2(3)*k3(4))
        alpha(46)=lp*(-(k1(4)*k2(2)*k3(3))+k1(2)*k2(3)*k3(4))
        alpha(47)=
     >  -(kp*k1(4))+k3(4)+lp*
     >    (-(k1(4)*k2(1)*k3(1))+k1(4)*k2(2)*k3(2)+k1(1)*k2(1)*k3(4)-
     >      k1(2)*k2(2)*k3(4))
        alpha(48)=
     >  k2(3)-k3(3)+lp*(k1(1)*k2(3)*k3(1)-k1(2)*k2(3)*k3(2)-
     >      k1(1)*k2(1)*k3(3)+k1(2)*k2(2)*k3(3))
        alpha(49)=
     >  -k2(4)+k3(4)+lp*(k1(2)*k2(4)*k3(2)+k1(3)*k2(4)*k3(3)-
     >      k1(2)*k2(2)*k3(4)-k1(3)*k2(3)*k3(4))
        alpha(50)=lp*(k1(2)*k2(4)*k3(1)-k1(1)*k2(2)*k3(4))
        alpha(51)=lp*(k1(3)*k2(4)*k3(1)-k1(1)*k2(3)*k3(4))
        alpha(52)=
     >  -(kp*k1(1))+k3(1)+lp*
     >    (-(k1(2)*k2(2)*k3(1))-k1(3)*k2(3)*k3(1)+k1(1)*k2(2)*k3(2)+
     >      k1(1)*k2(3)*k3(3))
        alpha(53)=lp*(k1(1)*k2(4)*k3(2)-k1(2)*k2(1)*k3(4))
        alpha(54)=
     >  k2(4)-k3(4)+lp*(k1(1)*k2(4)*k3(1)-k1(3)*k2(4)*k3(3)-
     >      k1(1)*k2(1)*k3(4)+k1(3)*k2(3)*k3(4))
        alpha(55)=lp*(k1(3)*k2(4)*k3(2)-k1(2)*k2(3)*k3(4))
        alpha(56)=
     >  -(kp*k1(2))+k3(2)+lp*
     >    (-(k1(2)*k2(1)*k3(1))+k1(1)*k2(1)*k3(2)-k1(3)*k2(3)*k3(2)+
     >      k1(2)*k2(3)*k3(3))
        alpha(57)=lp*(k1(1)*k2(4)*k3(3)-k1(3)*k2(1)*k3(4))
        alpha(58)=lp*(k1(2)*k2(4)*k3(3)-k1(3)*k2(2)*k3(4))
        alpha(59)=
     >  k2(4)-k3(4)+lp*(k1(1)*k2(4)*k3(1)-k1(2)*k2(4)*k3(2)-
     >      k1(1)*k2(1)*k3(4)+k1(2)*k2(2)*k3(4))
        alpha(60)=
     >  -(kp*k1(3))+k3(3)+lp*
     >    (-(k1(3)*k2(1)*k3(1))+k1(3)*k2(2)*k3(2)+k1(1)*k2(1)*k3(3)-
     >      k1(2)*k2(2)*k3(3))
        alpha(61)=
     >  kp*k1(1)-k2(1)+lp*(k1(2)*k2(1)*k3(2)-k1(1)*k2(2)*k3(2)+
     >      k1(3)*k2(1)*k3(3)-k1(1)*k2(3)*k3(3))
        alpha(62)=
     >  kp*k1(2)-k2(2)+lp*(k1(2)*k2(1)*k3(1)-k1(1)*k2(2)*k3(1)+
     >      k1(3)*k2(2)*k3(3)-k1(2)*k2(3)*k3(3))
        alpha(63)=
     >  kp*k1(3)-k2(3)+lp*(k1(3)*k2(1)*k3(1)-k1(1)*k2(3)*k3(1)-  
     >      k1(3)*k2(2)*k3(2)+k1(2)*k2(3)*k3(2))
        alpha(64)=0
C
        return
        end
C***********************************************************************
        subroutine wpwmgg(k1,k2,k3,alpha)
C***********************************************************************
C
C Returns the trilinear boson self interaction (su(2) group W^+ W^- Z)
C Optimize here!
        implicit none
C
        real*8 k1(4),k2(4),k3(4),awwgg,awgwg,azzgg
        common/an4g/awwgg,awgwg,azzgg
C
        complex*16 alpha(64)
        integer j1
C
        k3(1)=-k3(1)
        k2(1)=-k2(1)
        k1(1)=-k1(1)
C
        alpha(1) = -2*k2(2)*k3(2) - 2*k2(3)*k3(3) - 2*k2(4)*k3(4)
        alpha(2) = -2*k2(2)*k3(1)
        alpha(3) = -2*k2(3)*k3(1)
        alpha(4) = -2*k2(4)*k3(1)
        alpha(5) = -2*k2(1)*k3(2)
        alpha(6) = -2*k2(1)*k3(1) + 2*k2(3)*k3(3) + 2*k2(4)*k3(4)
        alpha(7) = -2*k2(3)*k3(2)
        alpha(8) = -2*k2(4)*k3(2)
        alpha(9) = -2*k2(1)*k3(3)
        alpha(10) = -2*k2(2)*k3(3)
        alpha(11) = -2*k2(1)*k3(1) + 2*k2(2)*k3(2) + 2*k2(4)*k3(4)
        alpha(12) = -2*k2(4)*k3(3)
        alpha(13) = -2*k2(1)*k3(4)
        alpha(14) = -2*k2(2)*k3(4)
        alpha(15) = -2*k2(3)*k3(4)
        alpha(16) = -2*k2(1)*k3(1) + 2*k2(2)*k3(2) + 2*k2(3)*k3(3)

C
        do j1=1,16
         alpha(j1)=alpha(j1)*awwgg
        enddo
        alpha(1)=1.+alpha(1)
        alpha(6)=-1.+alpha(6)
        alpha(11)=-1.+alpha(11)
        alpha(16)=-1.+alpha(16)
C
        return
        end
C***********************************************************************
        subroutine wpwmzg(k1,k2,k3,alpha)
C***********************************************************************
C
C Returns the trilinear boson self interaction (su(2) group W^+ W^- Z)
C Optimize here!
        implicit none
C
        real*8 k1(4),k2(4),k3(4),awwgz,awzwg,awpzfwfg,awmzfwfg
        common/an4gz/awwgz,awzwg,awpzfwfg,awmzfwfg
C
        complex*16 alpha(64)
        integer j1
C
        k3(1)=-k3(1)
        k2(1)=-k2(1)
        k1(1)=-k1(1)
C
        alpha(1) = -2*k2(2)*k3(2) - 2*k2(3)*k3(3) - 2*k2(4)*k3(4)
        alpha(2) = -2*k2(2)*k3(1)
        alpha(3) = -2*k2(3)*k3(1)
        alpha(4) = -2*k2(4)*k3(1)
        alpha(5) = -2*k2(1)*k3(2)
        alpha(6) = -2*k2(1)*k3(1) + 2*k2(3)*k3(3) + 2*k2(4)*k3(4)
        alpha(7) = -2*k2(3)*k3(2)
        alpha(8) = -2*k2(4)*k3(2)
        alpha(9) = -2*k2(1)*k3(3)
        alpha(10) = -2*k2(2)*k3(3)
        alpha(11) = -2*k2(1)*k3(1) + 2*k2(2)*k3(2) + 2*k2(4)*k3(4)
        alpha(12) = -2*k2(4)*k3(3)
        alpha(13) = -2*k2(1)*k3(4)
        alpha(14) = -2*k2(2)*k3(4)
        alpha(15) = -2*k2(3)*k3(4)
        alpha(16) = -2*k2(1)*k3(1) + 2*k2(2)*k3(2) + 2*k2(3)*k3(3)

C
        do j1=1,16
         alpha(j1)=alpha(j1)*awwgz   !c'era scritto awwzg
        enddo
        alpha(1)=1.+alpha(1)
        alpha(6)=-1.+alpha(6)
        alpha(11)=-1.+alpha(11)
        alpha(16)=-1.+alpha(16)
C
        return
        end
C***********************************************************************
        subroutine an6(k1,k2,k3,alpha,anom)
C***********************************************************************
C
C Returns the trilinear boson self interaction (su(2) group W^+ W^- Z)
C Optimize here!
        implicit none
C
        real*8 k1(4),k2(4),k3(4),anom
C
        complex*16 alpha(64)
        integer j1
C
        k3(1)=-k3(1)
        k2(1)=-k2(1)
        k1(1)=-k1(1)
C
        alpha(1) = -2*k2(2)*k3(2) - 2*k2(3)*k3(3) - 2*k2(4)*k3(4)
        alpha(2) = -2*k2(2)*k3(1)
        alpha(3) = -2*k2(3)*k3(1)
        alpha(4) = -2*k2(4)*k3(1)
        alpha(5) = -2*k2(1)*k3(2)
        alpha(6) = -2*k2(1)*k3(1) + 2*k2(3)*k3(3) + 2*k2(4)*k3(4)
        alpha(7) = -2*k2(3)*k3(2)
        alpha(8) = -2*k2(4)*k3(2)
        alpha(9) = -2*k2(1)*k3(3)
        alpha(10) = -2*k2(2)*k3(3)
        alpha(11) = -2*k2(1)*k3(1) + 2*k2(2)*k3(2) + 2*k2(4)*k3(4)
        alpha(12) = -2*k2(4)*k3(3)
        alpha(13) = -2*k2(1)*k3(4)
        alpha(14) = -2*k2(2)*k3(4)
        alpha(15) = -2*k2(3)*k3(4)
        alpha(16) = -2*k2(1)*k3(1) + 2*k2(2)*k3(2) + 2*k2(3)*k3(3)

C
        do j1=1,16
         alpha(j1)=alpha(j1)*anom
        enddo
        alpha(1)=1.+alpha(1)
        alpha(6)=-1.+alpha(6)
        alpha(11)=-1.+alpha(11)
        alpha(16)=-1.+alpha(16)
C
        return
        end
C***********************************************************************
        subroutine an7(k1,k2,k3,alpha,anom)
C***********************************************************************
C
C Returns the trilinear boson self interaction (su(2) group W^+ W^- Z)
C Optimize here!
        implicit none
C
        real*8 k1(4),k2(4),k3(4),anom
C
        complex*16 alpha(64)
        integer j1
C
        k3(1)=-k3(1)
        k2(1)=-k2(1)
        k1(1)=-k1(1)
C
        alpha(1) = -2*k2(2)*k3(2) - 2*k2(3)*k3(3) - 2*k2(4)*k3(4)
        alpha(2) = -2*k2(2)*k3(1)
        alpha(3) = -2*k2(3)*k3(1)
        alpha(4) = -2*k2(4)*k3(1)
        alpha(5) = -2*k2(1)*k3(2)
        alpha(6) = -2*k2(1)*k3(1) + 2*k2(3)*k3(3) + 2*k2(4)*k3(4)
        alpha(7) = -2*k2(3)*k3(2)
        alpha(8) = -2*k2(4)*k3(2)
        alpha(9) = -2*k2(1)*k3(3)
        alpha(10) = -2*k2(2)*k3(3)
        alpha(11) = -2*k2(1)*k3(1) + 2*k2(2)*k3(2) + 2*k2(4)*k3(4)
        alpha(12) = -2*k2(4)*k3(3)
        alpha(13) = -2*k2(1)*k3(4)
        alpha(14) = -2*k2(2)*k3(4)
        alpha(15) = -2*k2(3)*k3(4)
        alpha(16) = -2*k2(1)*k3(1) + 2*k2(2)*k3(2) + 2*k2(3)*k3(3)

C
        do j1=1,16
         alpha(j1)=alpha(j1)*anom
        enddo
C
        return
        end
C***********************************************************************
         subroutine compute(field1,field2,field3,mom1,mom2,mom3,
     >                   numb1,numb2,numb3,const1,const2,const3,
     >             operator,iteration,couplingconst,elmat,niteration)
C***********************************************************************
C
C It calls the SUBROUTINE INTERACTION to compute the perturbative solution
C
          implicit none
C
          complex*16 couplingconst
          complex*16 elmat      !matrix element
          complex*16 elmataux   !for intermediate storage of ELMAT
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C  setting the variables for the dummy fields FIELD1,FIELD2,FIELD3,.....
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C  FIELD.COMMM            shared by ITERA, SELECTFIELD and REPLACEFIELD
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
          integer dimfiel      !dimension of the array field1,2,3
          integer dimnum       !dimension of the array numb1,2,3
          integer dimmom       !dimension of the array mom1,2,3
          integer dimcons      !dimension of the array cons1,2,3
          integer dimop        !dimension of the array operator
          integer nmax         !maximum number of external particles, change here
          integer nlormax      !maximum number of lorentz d.o.f., change here
          parameter (nmax=8)
          parameter (nlormax=16)
          parameter (dimmom=(2**nmax-2)/2)     
          parameter (dimnum=nmax/2)      
          parameter (dimop=1)
          parameter (dimcons=5)      
          parameter (dimfiel=nlormax*dimmom)  
          integer iteration   !storing the present iteration stage
          integer mom1(dimmom),mom2(dimmom),mom3(dimmom)  !array containing a label for each indipendent
C                              momentum configuration. This number will allow
C                              to determine the complete configuration   
          integer niteration !number of iteration steps
          integer numb1(dimnum),numb2(dimnum),numb3(dimnum) 
          integer operator(dimop)  !a flag to identify the type of operator, 
C
          real*8 const1(dimcons) , const2(dimcons), const3(dimcons) !containing the characteristic of the field:
C
          complex*16 field1(dimfiel),field2(dimfiel),field3(dimfiel)  !array containing the field configuration
C                                        of one of the three field to multiply
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
           if (iteration.le.niteration) then
            call interaction(field1,field2,field3,mom1,mom2,mom3,
     >                        numb1,numb2,numb3,const1,const2,const3        
     >                            ,operator,iteration,couplingconst)
           else
            call lagint(field1,field2,field3,mom1,mom2,mom3,
     >                  numb1,numb2,numb3,const1,const2,const3
     >                  ,operator,couplingconst,elmataux)
            elmat=elmat+elmataux
           endif
C
           return
           end
C***********************************************************************
        subroutine gmunumat(metric)
C***********************************************************************
	implicit none
C
        complex*16 metric(16)
        integer j1
C
        do j1=1,16
         metric(j1)=0.
        enddo
C
        metric(1)=(1.,0.)
        metric(6)=(-1.,0.)
        metric(11)=(-1.,0.)
        metric(16)=(-1.,0.)
C
        return
        end    
C***********************************************************************
          subroutine processo_h(nproc)
C***********************************************************************
          implicit none
C
          integer ngaubos
          parameter (ngaubos=23)
          integer nmax        !maximum number of external particles, change here
          parameter (nmax=8)          
          integer flag/0/
          integer indexoutgoing
C(nmax)/nmax*0/ !reporting the order of storage of  
C                                      outgoing momenta
          integer indexingoing
C/nmax*0/ !reporting the order of storage of  
C                                      ingoing momenta
          integer j3,j4          !loop variable
          integer next        !number of external particles
          integer nfermion    !counting the number of anticommuting particles
          integer nproc       !to choose among different processes
          integer noutgoing    !number of outgoing particles
          integer nsourfermion, nsourfermionbar, nsourhiggs,
     >           nsourgaubosons
C
          real*8  internal
C(nmax)/nmax*1/    !array of flags to decide wether the particle is
C                              internal or external
          real*8 momenta      !particles momenta
          real*8  massoutgoing !containing the masses of outcoming 
C                                     particles
          real*8 masshiggs(3)    !higgs mass
          real*8 massgaubosons(ngaubos)   !zboson mass
          real*8 massfermion(3,4)  !fermion masses
          real*8 widthhiggs(3)    !higgs width
          real*8 widthgaubosons(ngaubos)   !zboson width
          real*8 widthfermion(3,4)  !fermion widthes
          real*8  spinsour, spinsouraux  
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C                                                                             C
C Containing the common for number and spin of external particles. Shared by the       C
C subroutines ITERA, PROCESSO and SPINVARIABLE; 
C ITERA, PROCESSO, FILLCONFSPIN AND SPINCOULOR respectively
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
         common/source/nsourhiggs(3),nsourgaubosons(ngaubos),
     >                 nsourfermion(3,4),nsourfermionbar(3,4)
         common/spin/spinsour(nmax),spinsouraux(nmax)
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C                                                                             C
C MASSES.COMM                                                                 C
C                                                                             C
C Containing the common for particles masses. Shared by the subroutines       C
C ITERA and COUPLINGS                                                         C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
          common/masses/masshiggs,massgaubosons,massfermion ,
     >                  widthhiggs,widthgaubosons,widthfermion !in this
C                      common all the  masses of the particles are transferred.
C                                    Wishing to add a new particle change here
CCCCCCCCC
          common/external/next,nfermion  !containing the number of external
C                                     particles from the subroutine ??????
          common/momenta/momenta(nmax,4),internal(nmax)
          common/integra/massoutgoing(nmax),
     >           noutgoing,indexoutgoing(nmax),indexingoing(nmax)
C
          integer inputinteraction(1000),count3   !to initialize relevant interaction terms
          common/interactions/inputinteraction,count3 ! shared with subroutine
C                                                       READARRAYTWOBYTWO_H
C
         integer next_old                !old number of esternal particles
         data internal/nmax*1/,
     &        indexoutgoing/nmax*0/,indexingoing/nmax*0/
C
         if (flag.eq.0) call couplings
C
         do j3=1,3
          do j4=1,4
           nsourfermion(j3,j4)=0
           nsourfermionbar(j3,j4)=0
          enddo
         enddo
C
         do j3=1,3
          nsourhiggs(j3)=0
         enddo
C
         do j3=1,ngaubos
          nsourgaubosons(j3)=0
         enddo
C
         do j3=1,nmax
          spinsouraux(j3)=0
          massoutgoing(j3)=0.
         enddo
C
C
C processo ee-->nu_e nu_e gamma gamma
C
        if(nproc.eq.1) then
C
         nsourfermion(1,3)=1       ! outgoin \nu_e-bar
         nsourfermion(1,4)=1       ! ingoin  e^-
         nsourfermionbar(1,3)=1       ! outgoin nu_e
         nsourfermionbar(1,4)=1       ! ingoin e^+
         nsourgaubosons(10)=2       ! outgoin gammas
         massoutgoing(1)=massfermion(1,3)
         massoutgoing(2)=massfermion(1,4)
         massoutgoing(3)=massfermion(1,3)
         massoutgoing(4)=massfermion(1,4)
         massoutgoing(5)=massgaubosons(10)
         massoutgoing(6)=massgaubosons(10)
C
         do j3=1,nmax
          indexingoing(j3)=0
          indexoutgoing(j3)=j3
          internal(j3)=1
         enddo        
         indexoutgoing(1)=1
         indexoutgoing(2)=3
         indexoutgoing(3)=5
         indexoutgoing(4)=6
         indexingoing(1)=2
         indexingoing(2)=4
         spinsouraux(1)=0.51
         spinsouraux(2)=0.49
         spinsouraux(3)=0.49
         spinsouraux(4)=0.51
         spinsouraux(5)=1.1
         spinsouraux(6)=1.1
         internal(1)=-1
         internal(3)=-1
         nfermion=4
         next=6
         noutgoing=4
C
C
C  Initializing relevant interaction terms
C
         count3=0
         inputinteraction(1)=5   !                      Number of V-A interaction
         inputinteraction(2)=1
         inputinteraction(3)=1
         inputinteraction(4)=3
         inputinteraction(5)=1
         inputinteraction(6)=3    !                    z nu_e nu_e
         inputinteraction(7)=1
         inputinteraction(8)=1
         inputinteraction(9)=4
         inputinteraction(10)=1
         inputinteraction(11)=4   !                     z e e
         inputinteraction(12)=3
         inputinteraction(13)=1
         inputinteraction(14)=4
         inputinteraction(15)=1
         inputinteraction(16)=3   !                     w e nu  
         inputinteraction(17)=2
         inputinteraction(18)=1
         inputinteraction(19)=3
         inputinteraction(20)=1
         inputinteraction(21)=4   !                     w  nu e
         inputinteraction(22)=10
         inputinteraction(23)=1
         inputinteraction(24)=4
         inputinteraction(25)=1
         inputinteraction(26)=4   !                     gamma e e  
         inputinteraction(27)=0  !                      number of Yukawa interaction
         inputinteraction(28)=19 !                       number of selfgauge
         inputinteraction(29)=1
         inputinteraction(30)=2
         inputinteraction(31)=3  !                      z w w
         inputinteraction(32)=10
         inputinteraction(33)=2
         inputinteraction(34)=3  !                      gamma w w 
         inputinteraction(35)=4
         inputinteraction(36)=2
         inputinteraction(37)=3
         inputinteraction(38)=5
         inputinteraction(39)=1
         inputinteraction(40)=1
         inputinteraction(41)=5
         inputinteraction(42)=1
         inputinteraction(43)=10
         inputinteraction(44)=5
         inputinteraction(45)=10
         inputinteraction(46)=10
         inputinteraction(47)=5
         inputinteraction(48)=2
         inputinteraction(49)=3
         inputinteraction(50)=6
         inputinteraction(51)=1
         inputinteraction(52)=2
         inputinteraction(53)=6
         inputinteraction(54)=10
         inputinteraction(55)=2
         inputinteraction(56)=7
         inputinteraction(57)=1
         inputinteraction(58)=3
         inputinteraction(59)=7
         inputinteraction(60)=10
         inputinteraction(61)=3
         inputinteraction(62)=8
         inputinteraction(63)=2
         inputinteraction(64)=2
         inputinteraction(65)=9
         inputinteraction(66)=3
         inputinteraction(67)=3
         inputinteraction(68)=16
         inputinteraction(69)=2
         inputinteraction(70)=3
         inputinteraction(71)=17
         inputinteraction(72)=10
         inputinteraction(73)=10
         inputinteraction(74)= 20
         inputinteraction(75)= 1
         inputinteraction(76)= 1
         inputinteraction(77)= 21
         inputinteraction(78)= 10
         inputinteraction(79)= 10
         inputinteraction(80)= 22
         inputinteraction(81)= 1
         inputinteraction(82)= 1
         inputinteraction(83)= 23
         inputinteraction(84)= 10
         inputinteraction(85)= 10
         inputinteraction(86)=0 !                        number of Gauge-higgs couplings
        endif
C
C processo ee-->nu_mu nu_mu gamma gamma  (per ragioni di convenienza si usa
C                                         un trucco ovvero nu_e senza accoppiamento 
C                                         col W)
C
        if(nproc.eq.2) then
C
         nsourfermion(1,3)=1       ! outgoin \nu_e-bar
         nsourfermion(1,4)=1       ! ingoin  e^-
         nsourfermionbar(1,3)=1       ! outgoin nu_e
         nsourfermionbar(1,4)=1       ! ingoin e^+
         nsourgaubosons(10)=2       ! outgoin gammas
         massoutgoing(1)=massfermion(1,3)
         massoutgoing(2)=massfermion(1,4)
         massoutgoing(3)=massfermion(1,3)
         massoutgoing(4)=massfermion(1,4)
         massoutgoing(5)=massgaubosons(10)
         massoutgoing(6)=massgaubosons(10)
C
         do j3=1,8
          indexingoing(j3)=0
          indexoutgoing(j3)=j3
          internal(j3)=1
         enddo        
         indexoutgoing(1)=1
         indexoutgoing(2)=3
         indexoutgoing(3)=5
         indexoutgoing(4)=6
         indexingoing(1)=2
         indexingoing(2)=4
         spinsouraux(1)=0.51
         spinsouraux(2)=0.49
         spinsouraux(3)=0.49
         spinsouraux(4)=0.51
         spinsouraux(5)=1.1
         spinsouraux(6)=1.1
         internal(1)=-1
         internal(3)=-1
         nfermion=4
         next=6
         noutgoing=4
C
C
C  Initializing relevant interaction terms
C
         count3=0
         inputinteraction(1)=3   !                      Number of V-A interaction
         inputinteraction(2)=1
         inputinteraction(3)=1
         inputinteraction(4)=3
         inputinteraction(5)=1
         inputinteraction(6)=3    !                    z nu_e nu_e
         inputinteraction(7)=1
         inputinteraction(8)=1
         inputinteraction(9)=4
         inputinteraction(10)=1
         inputinteraction(11)=4   !                     z e e
         inputinteraction(12)=10
         inputinteraction(13)=1
         inputinteraction(14)=4
         inputinteraction(15)=1
         inputinteraction(16)=4   !                     gamma e e  
         inputinteraction(17)=0  !                      number of Yukawa interaction
         inputinteraction(18)=6  !                       number of selfgauge
         inputinteraction(19)=16
         inputinteraction(20)=2
         inputinteraction(21)=3
         inputinteraction(22)=17
         inputinteraction(23)=10
         inputinteraction(24)=10
         inputinteraction(25)= 20
         inputinteraction(26)= 1
         inputinteraction(27)= 1
         inputinteraction(28)= 21
         inputinteraction(29)= 10
         inputinteraction(30)= 10
         inputinteraction(31)= 22
         inputinteraction(32)= 1
         inputinteraction(33)= 1
         inputinteraction(34)= 23
         inputinteraction(35)= 10
         inputinteraction(36)= 10
         inputinteraction(37)=0 !                        number of Gauge-higgs couplings
        endif
C
C processo ee-->nu_e nu_e gamma 
C
        if(nproc.eq.3) then
C
         nsourfermion(1,3)=1       ! outgoin \nu_e-bar
         nsourfermion(1,4)=1       ! ingoin  e^-
         nsourfermionbar(1,3)=1       ! outgoin nu_e
         nsourfermionbar(1,4)=1       ! ingoin e^+
         nsourgaubosons(10)=1       ! outgoin gammas
         massoutgoing(1)=massfermion(1,3)
         massoutgoing(2)=massfermion(1,4)
         massoutgoing(3)=massfermion(1,3)
         massoutgoing(4)=massfermion(1,4)
         massoutgoing(5)=massgaubosons(10)
C
         do j3=1,8
          indexingoing(j3)=0
          indexoutgoing(j3)=j3
          internal(j3)=1
         enddo        
         indexoutgoing(1)=1
         indexoutgoing(2)=3
         indexoutgoing(3)=5
         indexingoing(1)=2
         indexingoing(2)=4
         spinsouraux(1)=0.51
         spinsouraux(2)=0.49
         spinsouraux(3)=0.49
         spinsouraux(4)=0.51
         spinsouraux(5)=1.1
         internal(1)=-1
         internal(3)=-1
         nfermion=4
         next=5
         noutgoing=3
C
C
C  Initializing relevant interaction terms
C
         count3=0
         inputinteraction(1)=5   !                      Number of V-A interaction
         inputinteraction(2)=1
         inputinteraction(3)=1
         inputinteraction(4)=3
         inputinteraction(5)=1
         inputinteraction(6)=3    !                    z nu_e nu_e
         inputinteraction(7)=1
         inputinteraction(8)=1
         inputinteraction(9)=4
         inputinteraction(10)=1
         inputinteraction(11)=4   !                     z e e
         inputinteraction(12)=3
         inputinteraction(13)=1
         inputinteraction(14)=4
         inputinteraction(15)=1
         inputinteraction(16)=3   !                     w e nu  
         inputinteraction(17)=2
         inputinteraction(18)=1
         inputinteraction(19)=3
         inputinteraction(20)=1
         inputinteraction(21)=4   !                     w  nu e
         inputinteraction(22)=10
         inputinteraction(23)=1
         inputinteraction(24)=4
         inputinteraction(25)=1
         inputinteraction(26)=4   !                     gamma e e  
         inputinteraction(27)=0  !                      number of Yukawa interaction
         inputinteraction(28)=1 !                       number of selfgauge
         inputinteraction(29)=10
         inputinteraction(30)=2
         inputinteraction(31)=3  !                      gamma w w 
         inputinteraction(32)=0 !                        number of Gauge-higgs couplings
        endif
C
C processo ee-->nu_mu nu_mu gamma (trucco no e nu_e W couplings, per convenienza)
C
        if(nproc.eq.4) then
C
         nsourfermion(1,3)=1       ! outgoin \nu_e-bar
         nsourfermion(1,4)=1       ! ingoin  e^-
         nsourfermionbar(1,3)=1       ! outgoin nu_e
         nsourfermionbar(1,4)=1       ! ingoin e^+
         nsourgaubosons(10)=1       ! outgoin gammas
         massoutgoing(1)=massfermion(1,3)
         massoutgoing(2)=massfermion(1,4)
         massoutgoing(3)=massfermion(1,3)
         massoutgoing(4)=massfermion(1,4)
         massoutgoing(5)=massgaubosons(10)
C
         do j3=1,8
          indexingoing(j3)=0
          indexoutgoing(j3)=j3
          internal(j3)=1
         enddo        
         indexoutgoing(1)=1
         indexoutgoing(2)=3
         indexoutgoing(3)=5
         indexingoing(1)=2
         indexingoing(2)=4
         spinsouraux(1)=0.51
         spinsouraux(2)=0.49
         spinsouraux(3)=0.49
         spinsouraux(4)=0.51
         spinsouraux(5)=1.1
         internal(1)=-1
         internal(3)=-1
         nfermion=4
         next=5
         noutgoing=3
C
C
C  Initializing relevant interaction terms
C
         count3=0
         inputinteraction(1)=3   !                      Number of V-A interaction
         inputinteraction(2)=1
         inputinteraction(3)=1
         inputinteraction(4)=3
         inputinteraction(5)=1
         inputinteraction(6)=3    !                    z nu_e nu_e
         inputinteraction(7)=1
         inputinteraction(8)=1
         inputinteraction(9)=4
         inputinteraction(10)=1
         inputinteraction(11)=4   !                     z e e
         inputinteraction(12)=10
         inputinteraction(13)=1
         inputinteraction(14)=4
         inputinteraction(15)=1
         inputinteraction(16)=4   !                     gamma e e  
         inputinteraction(17)=0  !                      number of Yukawa interaction
         inputinteraction(18)=0 !                       number of selfgauge
         inputinteraction(19)=0 !                        number of Gauge-higgs couplings
        endif
C
C processo ee-->nu_mu nu_mu gamma (trucco no e nu_e W couplings, per convenienza)
C
        if(nproc.eq.5) then
C
         nsourfermion(1,4)=2       ! ingoin  e^- ,outgoing e^+
         nsourfermionbar(1,4)=2       ! ingoin e^+, outgoing e^-
         nsourgaubosons(10)=2       ! outgoin gammas
         massoutgoing(1)=massfermion(1,4)
         massoutgoing(2)=massfermion(1,4)
         massoutgoing(3)=massfermion(1,4)
         massoutgoing(4)=massfermion(1,4)
         massoutgoing(5)=massgaubosons(10)
         massoutgoing(6)=massgaubosons(10)
C
         do j3=1,8
          indexingoing(j3)=0
          indexoutgoing(j3)=j3
          internal(j3)=1
         enddo        
         indexoutgoing(1)=2
         indexoutgoing(2)=4
         indexoutgoing(3)=5
         indexoutgoing(4)=6
         indexingoing(1)=1
         indexingoing(2)=3
         spinsouraux(1)=0.49
         spinsouraux(2)=0.51
         spinsouraux(3)=0.51
         spinsouraux(4)=0.49
         spinsouraux(5)=1.1
         spinsouraux(6)=1.1
         internal(2)=-1
         internal(4)=-1
         nfermion=4
         next=6
         noutgoing=4
C
C
C  Initializing relevant interaction terms
C
         count3=0
         inputinteraction(1)=2   !                      Number of V-A interaction
         inputinteraction(2)=1
         inputinteraction(3)=1
         inputinteraction(4)=4
         inputinteraction(5)=1
         inputinteraction(6)=4   !                     z e e
         inputinteraction(7)=10
         inputinteraction(8)=1
         inputinteraction(9)=4
         inputinteraction(10)=1
         inputinteraction(11)=4   !                     gamma e e  
         inputinteraction(12)=0  !                      number of Yukawa interaction
         inputinteraction(13)=0 !                       number of selfgauge
         inputinteraction(14)=0 !                        number of Gauge-higgs couplings
        endif
C
C processo ee-->nu_e nu_e gamma gamma gamma
C
        if(nproc.eq.6) then
C
         nsourfermion(1,3)=1       ! outgoin \nu_e-bar
         nsourfermion(1,4)=1       ! ingoin  e^-
         nsourfermionbar(1,3)=1       ! outgoin nu_e
         nsourfermionbar(1,4)=1       ! ingoin e^+
         nsourgaubosons(10)=3       ! outgoin gammas
         massoutgoing(1)=massfermion(1,3)
         massoutgoing(2)=massfermion(1,4)
         massoutgoing(3)=massfermion(1,3)
         massoutgoing(4)=massfermion(1,4)
         massoutgoing(5)=massgaubosons(10)
         massoutgoing(6)=massgaubosons(10)
         massoutgoing(7)=massgaubosons(10)
C
         do j3=1,8
          indexingoing(j3)=0
          indexoutgoing(j3)=j3
          internal(j3)=1
         enddo        
         indexoutgoing(1)=1
         indexoutgoing(2)=3
         indexoutgoing(3)=5
         indexoutgoing(4)=6
         indexoutgoing(5)=7
         indexingoing(1)=2
         indexingoing(2)=4
         spinsouraux(1)=0.51
         spinsouraux(2)=0.49
         spinsouraux(3)=0.49
         spinsouraux(4)=0.51
         spinsouraux(5)=1.1
         spinsouraux(6)=1.1
         spinsouraux(7)=1.1
         internal(1)=-1
         internal(3)=-1
         nfermion=4
         next=7
         noutgoing=5
C
C
C  Initializing relevant interaction terms
C
         count3=0
         inputinteraction(1)=5   !                      Number of V-A interaction
         inputinteraction(2)=1
         inputinteraction(3)=1
         inputinteraction(4)=3
         inputinteraction(5)=1
         inputinteraction(6)=3    !                    z nu_e nu_e
         inputinteraction(7)=1
         inputinteraction(8)=1
         inputinteraction(9)=4
         inputinteraction(10)=1
         inputinteraction(11)=4   !                     z e e
         inputinteraction(12)=3
         inputinteraction(13)=1
         inputinteraction(14)=4
         inputinteraction(15)=1
         inputinteraction(16)=3   !                     w e nu  
         inputinteraction(17)=2
         inputinteraction(18)=1
         inputinteraction(19)=3
         inputinteraction(20)=1
         inputinteraction(21)=4   !                     w  nu e
         inputinteraction(22)=10
         inputinteraction(23)=1
         inputinteraction(24)=4
         inputinteraction(25)=1
         inputinteraction(26)=4   !                     gamma e e  
         inputinteraction(27)=0  !                      number of Yukawa interaction
         inputinteraction(28)=19 !                       number of selfgauge
         inputinteraction(29)=1
         inputinteraction(30)=2
         inputinteraction(31)=3  !                      z w w
         inputinteraction(32)=10
         inputinteraction(33)=2
         inputinteraction(34)=3  !                      gamma w w 
         inputinteraction(35)=4
         inputinteraction(36)=2
         inputinteraction(37)=3
         inputinteraction(38)=5
         inputinteraction(39)=1
         inputinteraction(40)=1
         inputinteraction(41)=5
         inputinteraction(42)=1
         inputinteraction(43)=10
         inputinteraction(44)=5
         inputinteraction(45)=10
         inputinteraction(46)=10
         inputinteraction(47)=5
         inputinteraction(48)=2
         inputinteraction(49)=3
         inputinteraction(50)=6
         inputinteraction(51)=1
         inputinteraction(52)=2
         inputinteraction(53)=6
         inputinteraction(54)=10
         inputinteraction(55)=2
         inputinteraction(56)=7
         inputinteraction(57)=1
         inputinteraction(58)=3
         inputinteraction(59)=7
         inputinteraction(60)=10
         inputinteraction(61)=3
         inputinteraction(62)=8
         inputinteraction(63)=2
         inputinteraction(64)=2
         inputinteraction(65)=9
         inputinteraction(66)=3
         inputinteraction(67)=3
         inputinteraction(68)=16
         inputinteraction(69)=2
         inputinteraction(70)=3
         inputinteraction(71)=17
         inputinteraction(72)=10
         inputinteraction(73)=10
         inputinteraction(74)= 20
         inputinteraction(75)= 1
         inputinteraction(76)= 1
         inputinteraction(77)= 21
         inputinteraction(78)= 10
         inputinteraction(79)= 10
         inputinteraction(80)= 22
         inputinteraction(81)= 1
         inputinteraction(82)= 1
         inputinteraction(83)= 23
         inputinteraction(84)= 10
         inputinteraction(85)= 10
         inputinteraction(86)=0 !                        number of Gauge-higgs couplings
        endif
C
C processo ee-->nu_mu nu_mu gamma gamma gamma (per ragioni di convenienza si usa
C                                         un trucco ovvero nu_e senza accoppiamento 
C                                         col W)
C
        if(nproc.eq.7) then
C
         nsourfermion(1,3)=1       ! outgoin \nu_e-bar
         nsourfermion(1,4)=1       ! ingoin  e^-
         nsourfermionbar(1,3)=1       ! outgoin nu_e
         nsourfermionbar(1,4)=1       ! ingoin e^+
         nsourgaubosons(10)=3       ! outgoin gammas
         massoutgoing(1)=massfermion(1,3)
         massoutgoing(2)=massfermion(1,4)
         massoutgoing(3)=massfermion(1,3)
         massoutgoing(4)=massfermion(1,4)
         massoutgoing(5)=massgaubosons(10)
         massoutgoing(6)=massgaubosons(10)
         massoutgoing(7)=massgaubosons(10)
C
         do j3=1,8
          indexingoing(j3)=0
          indexoutgoing(j3)=j3
          internal(j3)=1
         enddo        
         indexoutgoing(1)=1
         indexoutgoing(2)=3
         indexoutgoing(3)=5
         indexoutgoing(4)=6
         indexoutgoing(5)=7
         indexingoing(1)=2
         indexingoing(2)=4
         spinsouraux(1)=0.51
         spinsouraux(2)=0.49
         spinsouraux(3)=0.49
         spinsouraux(4)=0.51
         spinsouraux(5)=1.1
         spinsouraux(6)=1.1
         spinsouraux(7)=1.1
         internal(1)=-1
         internal(3)=-1
         nfermion=4
         next=7
         noutgoing=5
C
C  Initializing relevant interaction terms
C
         count3=0
         inputinteraction(1)=3   !                      Number of V-A interaction
         inputinteraction(2)=1
         inputinteraction(3)=1
         inputinteraction(4)=3
         inputinteraction(5)=1
         inputinteraction(6)=3    !                    z nu_e nu_e
         inputinteraction(7)=1
         inputinteraction(8)=1
         inputinteraction(9)=4
         inputinteraction(10)=1
         inputinteraction(11)=4   !                     z e e
         inputinteraction(12)=10
         inputinteraction(13)=1
         inputinteraction(14)=4
         inputinteraction(15)=1
         inputinteraction(16)=4   !                     gamma e e  
         inputinteraction(17)=0  !                      number of Yukawa interaction
         inputinteraction(18)=6  !                       number of selfgauge
         inputinteraction(19)=16
         inputinteraction(20)=2
         inputinteraction(21)=3
         inputinteraction(22)=17
         inputinteraction(23)=10
         inputinteraction(24)=10
         inputinteraction(25)= 20
         inputinteraction(26)= 1
         inputinteraction(27)= 1
         inputinteraction(28)= 21
         inputinteraction(29)= 10
         inputinteraction(30)= 10
         inputinteraction(31)= 22
         inputinteraction(32)= 1
         inputinteraction(33)= 1
         inputinteraction(34)= 23
         inputinteraction(35)= 10
         inputinteraction(36)= 10
         inputinteraction(37)=0 !                        number of Gauge-higgs couplings
        endif
C
C common environment
C
         do j3=1,next
          spinsour(j3)=spinsouraux(j3)
         enddo
C
         if(next.ne.next_old) flag=0
         next_old=next
C
         if(flag.eq.0) then    !initialization step for coupling constants
          flag=1               !and to define product among momentum configurations
          call configuration
          call initcompconf
         endif

C
C processo ee-->mu mu tau nu_tau u d
C
c         nsourfermion(1,2)=1       ! outgoin d-bar
c         nsourfermion(1,4)=1       ! ingoin  e^-
c         nsourfermion(2,4)=1       ! outgoin mu^+
c         nsourfermion(3,3)=1       ! outgoin \bar nu_tau
c         nsourfermionbar(1,1)=1       ! outgoin u
c         nsourfermionbar(1,4)=1       ! ingoin  e^+
c         nsourfermionbar(2,4)=1       ! outgoin mu^-
c         nsourfermionbar(3,4)=1       ! outgoin tau^-
c         massoutgoing(1)=massfermion(1,2)
c         massoutgoing(2)=massfermion(1,4)
c         massoutgoing(3)=massfermion(2,4)
c         massoutgoing(4)=massfermion(1,1)
c         massoutgoing(5)=massfermion(2,4)
c         massoutgoing(6)=massfermion(3,4)
cC
c         do j3=1,8
c          indexingoing(j3)=0
c          indexoutgoing(j3)=j3
c          internal(j3)=1
c         enddo        
c         indexoutgoing(1)=1
c         indexoutgoing(2)=3
c         indexoutgoing(3)=4
c         indexoutgoing(4)=5
c         indexoutgoing(5)=7
c         indexoutgoing(6)=8
c         indexingoing(1)=2
c         indexingoing(2)=6
c         spinsouraux(1)=0.51
c         spinsouraux(2)=0.49
c         spinsouraux(3)=0.51
c         spinsouraux(4)=0.51
c         spinsouraux(5)=0.49
c         spinsouraux(6)=0.51
c         spinsouraux(7)=0.49
c         spinsouraux(8)=0.49
c         internal(1)=-1
c         internal(3)=-1
c         internal(4)=-1
c         internal(5)=-1
c         internal(7)=-1
c         internal(8)=-1
c         nfermion=8
c         next=8
c         noutgoing=6
C
C
C  Initializing relevant interaction terms
C
c         count3=0
c         inputinteraction(1)=21   !                      Number of V-A interaction
c         inputinteraction(2)=1
c         inputinteraction(3)=1
c         inputinteraction(4)=3
c         inputinteraction(5)=1
c         inputinteraction(6)=3    !                    z nu_e nu_e
c         inputinteraction(7)=1
c         inputinteraction(8)=1
c         inputinteraction(9)=4
c         inputinteraction(10)=1
c         inputinteraction(11)=4   !                     z e e
c         inputinteraction(12)=1
c         inputinteraction(13)=1
c         inputinteraction(14)=1
c         inputinteraction(15)=1
c         inputinteraction(16)=1   !                     z u u
c         inputinteraction(17)=1
c         inputinteraction(18)=1
c         inputinteraction(19)=2
c         inputinteraction(20)=1
c         inputinteraction(21)=2   !                     z d d
c         inputinteraction(22)=1
c         inputinteraction(23)=2
c         inputinteraction(24)=3
c         inputinteraction(25)=2
c         inputinteraction(26)=3   !                     z nu_mu nu_mu
c         inputinteraction(27)=1
c         inputinteraction(28)=2
c         inputinteraction(29)=4
c         inputinteraction(30)=2
c         inputinteraction(31)=4   !                     z mu mu
c         inputinteraction(32)=1
c         inputinteraction(33)=3
c         inputinteraction(34)=3
c         inputinteraction(35)=3
c         inputinteraction(36)=3   !                      z nu_tau nu_tau
c         inputinteraction(37)=1
c         inputinteraction(38)=3
c         inputinteraction(39)=4
c         inputinteraction(40)=3
c         inputinteraction(41)=4   !                      z tau tau
c         inputinteraction(42)=2
c         inputinteraction(43)=1
c         inputinteraction(44)=1
c         inputinteraction(45)=1
c         inputinteraction(46)=2   !                     w u d
c         inputinteraction(47)=3
c         inputinteraction(48)=1
c         inputinteraction(49)=2
c         inputinteraction(50)=1
c         inputinteraction(51)=1   !                     w d u
c         inputinteraction(52)=3
c         inputinteraction(53)=1
c         inputinteraction(54)=4
c         inputinteraction(55)=1
c         inputinteraction(56)=3   !                     w e nu  
c         inputinteraction(57)=2
c         inputinteraction(58)=1
c         inputinteraction(59)=3
c         inputinteraction(60)=1
c         inputinteraction(61)=4   !                     w  nu e
c         inputinteraction(62)=2
c         inputinteraction(63)=2
c         inputinteraction(64)=3
c         inputinteraction(65)=2
c         inputinteraction(66)=4   !                     w nu mu
c         inputinteraction(67)=3
c         inputinteraction(68)=2
c         inputinteraction(69)=4
c         inputinteraction(70)=2
c         inputinteraction(71)=3   !                     w mu nu 
c         inputinteraction(72)=2
c         inputinteraction(73)=3
c         inputinteraction(74)=3
c         inputinteraction(75)=3
c         inputinteraction(76)=4   !                     w nu tau
c         inputinteraction(77)=3
c         inputinteraction(78)=3
c         inputinteraction(79)=4
c         inputinteraction(80)=3
c         inputinteraction(81)=3   !                     w tau    nu 
c         inputinteraction(82)=10
c         inputinteraction(83)=1
c         inputinteraction(84)=1
c         inputinteraction(85)=1
c         inputinteraction(86)=1   !                     gamma u u 
c         inputinteraction(87)=10
c         inputinteraction(88)=1
c         inputinteraction(89)=2
c         inputinteraction(90)=1
c         inputinteraction(91)=2   !                     gamma d d  
c         inputinteraction(92)=10
c         inputinteraction(93)=1
c         inputinteraction(94)=4
c         inputinteraction(95)=1
c         inputinteraction(96)=4   !                     gamma e e  
c         inputinteraction(97)=10
c         inputinteraction(98)=2
c         inputinteraction(99)=4
c         inputinteraction(100)=2
c         inputinteraction(101)=4  !                      gamma mu mu 
c         inputinteraction(102)=10
c         inputinteraction(103)=3
c         inputinteraction(104)=4
c         inputinteraction(105)=3
c         inputinteraction(106)=4  !                      gamma tau tau 
c         inputinteraction(107)=0  !                      number of Yukawa interaction
c         inputinteraction(108)=13 !                       number of selfgauge
c         inputinteraction(109)=1
c         inputinteraction(110)=2
c         inputinteraction(111)=3  !                      z w w
c         inputinteraction(112)=10
c         inputinteraction(113)=2
c         inputinteraction(114)=3  !                      gamma w w 
c         inputinteraction(115)=4
c         inputinteraction(116)=2
c         inputinteraction(117)=3
c         inputinteraction(118)=5
c         inputinteraction(119)=1
c         inputinteraction(120)=1
c         inputinteraction(121)=5
c         inputinteraction(122)=1
c         inputinteraction(123)=10
c         inputinteraction(124)=5
c         inputinteraction(125)=10
c         inputinteraction(126)=10
c         inputinteraction(127)=5
c         inputinteraction(128)=2
c         inputinteraction(129)=3
c         inputinteraction(130)=6
c         inputinteraction(131)=1
c         inputinteraction(132)=2
c         inputinteraction(133)=6
c         inputinteraction(134)=10
c         inputinteraction(135)=2
c         inputinteraction(136)=7
c         inputinteraction(137)=1
c         inputinteraction(138)=3
c         inputinteraction(139)=7
c         inputinteraction(140)=10
c         inputinteraction(141)=3
c         inputinteraction(142)=8
c         inputinteraction(143)=2
c         inputinteraction(144)=2
c         inputinteraction(145)=9
c         inputinteraction(146)=3
c         inputinteraction(147)=3
c         inputinteraction(148)=2 !                        number of Gauge-higgs couplings
c         inputinteraction(149)=1
c         inputinteraction(150)=1
c         inputinteraction(151)=1 !                       h z z
c         inputinteraction(152)=1
c         inputinteraction(153)=2
c         inputinteraction(154)=3 !                       h w w
C
C
C
C
c         open (10,file='processo.dat',status='old')
C
c         do j3=1,3
c          do j4=1,4
C
c           read(10,*)nsourfermion(j3,j4)
C
c           if(nsourfermion(j3,j4).ne.0) then
c            do j1=next+1,next+nsourfermion(j3,j4)
c             indexingoing(j1)=j1
c             spinsour(j1)=0.49
c            enddo
c            next=nsourfermion(j3,j4)+next
c           endif
C
c           read(10,*)naux
c           nsourfermion(j3,j4)=naux+nsourfermion(j3,j4)
C
c           if(naux.ne.0) then
c            do j1=next+1,next+naux
c             internal(j1)=-1.
c             spinsour(j1)=0.51
c             indexoutgoing(j1)=j1
c             massoutgoing(j1)=massfermion(j3,j4)
c            enddo
c            next=naux+next
c           endif
c          enddo
c         enddo
C
c         do j3=1,3
c          do j4=1,4
C
c           read(10,*)nsourfermionbar(j3,j4)
C
c           if(nsourfermionbar(j3,j4).ne.0) then
c            do j1=next+1,next+nsourfermionbar(j3,j4)
c             internal(j1)=-1.
c             spinsour(j1)=0.49
c             indexoutgoing(j1)=j1
c             massoutgoing(j1)=massfermion(j3,j4)
c            enddo
c           next=nsourfermionbar(j3,j4)+next
c           endif
C
c           read(10,*)naux
c           nsourfermionbar(j3,j4)=naux+nsourfermionbar(j3,j4)
C
c           if(naux.ne.0) then
c            do j1=next+1,next+naux
c             indexingoing(j1)=j1
c             spinsour(j1)=0.51
c            enddo
c            next=naux+next
c           endif
C
c          enddo
c         enddo
C
c           read(10,*)nsourhiggs(1)
c           nsourhiggs(2)=0
c           nsourhiggs(3)=0
C
c           if(nsourhiggs(1).ne.0) then
c            do j1=next+1,next+nsourhiggs(1)
c             indexingoing(j1)=j1
c             spinsour(j1)=0.
c            enddo
c            next=nsourhiggs(1)+next
c           endif
C
c           read(10,*)naux
C
c           if(naux.ne.0) then
c            do j1=next+1,next+naux
c             spinsour(j1)=0.
c             indexoutgoing(j1)=j1
c             massoutgoing(j1)=masshiggs(1)
c             internal(j1)=-1
c            enddo
c            next=naux+next
c           endif
c           nsourhiggs(1)=nsourhiggs(1)+naux
C
c         do j3=1,ngaubos
c          if(j3.gt.3.and.j3.lt.10.or.j3.gt.11) then
c           nsourgaubosons(j3)=0
c          else
c            read(10,*)nsourgaubosons(j3)
C
c            if(nsourgaubosons(j3).ne.0) then
c             do j1=next+1,next+nsourgaubosons(j3)
c             indexingoing(j1)=j1
c              spinsour(j1)=1.+dfloat(j3)*1.d-2
c             enddo
c             next=nsourgaubosons(j3)+next
c            endif
C
c            read(10,*)naux
C
c            if(naux.ne.0) then
c             do j1=next+1,next+naux
c              spinsour(j1)=1.+dfloat(j3)*1.d-2
c              indexoutgoing(j1)=j1
c              massoutgoing(j1)=massgaubosons(j3)
c             enddo
c             next=naux+next
c            endif
c             nsourgaubosons(j3)=nsourgaubosons(j3)+naux
c           endif
c          enddo
C
c           nfermion=0
c           do j1=1,3
c            do j2=1,4
c             nfermion=nsourfermion(j1,j2)+
c     >                nsourfermionbar(j1,j2)+nfermion
c            enddo
c           enddo
C
c           noutgoing=next
c           do j1=1,next
c            if (indexoutgoing(j1).eq.0) then
c             noutgoing=noutgoing-1
c            endif           
c           enddo
C
c          do j3=1,next-noutgoing
c           do j1=1,next-1
c            if (indexoutgoing(j1).eq.0) then
c             do j2=j1,next-1
c              indexoutgoing(j2)=indexoutgoing(j2+1)
c              massoutgoing(j2)=massoutgoing(j2+1)
c             enddo
c            endif
c           enddo
c          enddo
C
c          do j3=1,noutgoing
c           do j1=1,next-1
c            if (indexingoing(j1).eq.0) then
c             do j2=j1,next-1
c              indexingoing(j2)=indexingoing(j2+1)
c             enddo
c            endif
c           enddo
c          enddo
C
c           do j1=1,next
c            spinsouraux(j1)=spinsour(j1)
c           enddo
C
c           close (10)
C
           return
           end
C***********************************************************************
          subroutine processo
C***********************************************************************
          implicit none
C
          integer ngaubos
          parameter (ngaubos=23)
          integer nmax        !maximum number of external particles, change here
          parameter (nmax=8)          
          integer flag/0/
          integer indexoutgoing(nmax)
C         /nmax*0/ !reporting the order of storage of  
C                                      outgoing momenta
          integer indexingoing(nmax)
C         /nmax*0/ !reporting the order of storage of  
C                                      ingoing momenta
          integer j1,j2,j3,j4          !loop variable
          integer naux        !auxiliar counter
          integer next        !number of external particles
          integer nfermion    !counting the number of anticommuting particles
          integer noutgoing    !number of outgoing particles
          integer nsourfermion, nsourfermionbar, nsourhiggs,
     >           nsourgaubosons
C
          real*8  internal    !array of flags to decide wether the particle is
C                              internal or external
          real*8 momenta      !particles momenta
          real*8  initialmomentum(4) !arrays containing the total initial 
C                                     fourmomentum
          real*8  massoutgoing(nmax) !containing the masses of outcoming 
C                                     particles
          real*8 masshiggs(3)    !higgs mass
          real*8 massgaubosons(ngaubos)   !zboson mass
          real*8 massfermion(3,4)  !fermion masses
          real*8 widthhiggs(3)    !higgs width
          real*8 widthgaubosons(ngaubos)   !zboson width
          real*8 widthfermion(3,4)  !fermion widthes
          real*8  spinsour, spinsouraux  
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C                                                                             C
C Containing the common for number and spin of external particles. Shared by the       C
C subroutines ITERA, PROCESSO and SPINVARIABLE; 
C ITERA, PROCESSO, FILLCONFSPIN AND SPINCOULOR respectively
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
         common/source/nsourhiggs(3),nsourgaubosons(ngaubos),
     >                 nsourfermion(3,4),nsourfermionbar(3,4)
         common/spin/spinsour(nmax),spinsouraux(nmax)
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C                                                                             C
C MASSES.COMM                                                                 C
C                                                                             C
C Containing the common for particles masses. Shared by the subroutines       C
C ITERA and COUPLINGS                                                         C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
          common/masses/masshiggs,massgaubosons,massfermion ,
     >                  widthhiggs,widthgaubosons,widthfermion !in this
C                      common all the  masses of the particles are transferred.
C                                    Wishing to add a new particle change here
CCCCCCCCC
          common/external/next,nfermion  !containing the number of external
C                                     particles from the subroutine ??????
          common/momenta/momenta(nmax,4),internal(nmax)
          common/integra/massoutgoing,
     >                       noutgoing,indexoutgoing,indexingoing
C
         if (flag.eq.0) call couplings
         next=0
         do j1=1,nmax
          internal(j1)=1.
         enddo
C
         open (10,file='processo.dat',status='old')
C
         do j3=1,3
          do j4=1,4
C
           read(10,*)nsourfermion(j3,j4)
C
           if(nsourfermion(j3,j4).ne.0) then
            do j1=next+1,next+nsourfermion(j3,j4)
             indexingoing(j1)=j1
c             do j2=1,4
c              read(10,*) momenta(j1,j2)             
c             enddo
             spinsour(j1)=0.49
            enddo
            next=nsourfermion(j3,j4)+next
           endif
C
           read(10,*)naux
           nsourfermion(j3,j4)=naux+nsourfermion(j3,j4)
C
           if(naux.ne.0) then
            do j1=next+1,next+naux
             internal(j1)=-1.
             spinsour(j1)=0.51
             indexoutgoing(j1)=j1
             massoutgoing(j1)=massfermion(j3,j4)
            enddo
            next=naux+next
           endif
          enddo
         enddo
C
         do j3=1,3
          do j4=1,4
C
           read(10,*)nsourfermionbar(j3,j4)
C
           if(nsourfermionbar(j3,j4).ne.0) then
            do j1=next+1,next+nsourfermionbar(j3,j4)
             internal(j1)=-1.
             spinsour(j1)=0.49
             indexoutgoing(j1)=j1
             massoutgoing(j1)=massfermion(j3,j4)
            enddo
           next=nsourfermionbar(j3,j4)+next
           endif
C
           read(10,*)naux
           nsourfermionbar(j3,j4)=naux+nsourfermionbar(j3,j4)
C
           if(naux.ne.0) then
            do j1=next+1,next+naux
             indexingoing(j1)=j1
c             do j2=1,4
c              read(10,*)momenta(j1,j2)
c             enddo
             spinsour(j1)=0.51
            enddo
            next=naux+next
           endif
C
          enddo
         enddo
C
           read(10,*)nsourhiggs(1)
           nsourhiggs(2)=0
           nsourhiggs(3)=0
C
           if(nsourhiggs(1).ne.0) then
            do j1=next+1,next+nsourhiggs(1)
             indexingoing(j1)=j1
c             do j2=1,4
c              read(10,*)momenta(j1,j2)
c             enddo
             spinsour(j1)=0.
            enddo
            next=nsourhiggs(1)+next
           endif
C
           read(10,*)naux
C
           if(naux.ne.0) then
            do j1=next+1,next+naux
             spinsour(j1)=0.
             indexoutgoing(j1)=j1
             massoutgoing(j1)=masshiggs(1)
            enddo
            next=naux+next
           endif
           nsourhiggs(1)=nsourhiggs(1)+naux
C
         do j3=1,ngaubos
          if(j3.gt.3.and.j3.lt.10.or.j3.gt.11) then
           nsourgaubosons(j3)=0
          else
            read(10,*)nsourgaubosons(j3)
C
            if(nsourgaubosons(j3).ne.0) then
             do j1=next+1,next+nsourgaubosons(j3)
             indexingoing(j1)=j1
c              do j2=1,4
c               read(10,*)momenta(j1,j2)
c              enddo
              spinsour(j1)=1.+dfloat(j3)*1.d-2
             enddo
             next=nsourgaubosons(j3)+next
            endif
C
            read(10,*)naux
C
            if(naux.ne.0) then
             do j1=next+1,next+naux
              spinsour(j1)=1.+dfloat(j3)*1.d-2
              indexoutgoing(j1)=j1
              massoutgoing(j1)=massgaubosons(j3)
             enddo
             next=naux+next
            endif
             nsourgaubosons(j3)=nsourgaubosons(j3)+naux
           endif
          enddo
C
           nfermion=0
           do j1=1,3
            do j2=1,4
             nfermion=nsourfermion(j1,j2)+
     >                nsourfermionbar(j1,j2)+nfermion
            enddo
           enddo
C
c           do j1=1,4
c            initialmomentum(j1)=0.
c           enddo
C
           if(flag.eq.0) then    !initialization step for coupling constants
            flag=1               !and to define product among momentum configurations
            call configuration
            call initcompconf
           endif
C
           noutgoing=next
           do j1=1,next
            if (indexoutgoing(j1).eq.0) then
c             do j2=1,4
c              initialmomentum(j2)=initialmomentum(j2)+momenta(j1,j2)
c             enddo 
             noutgoing=noutgoing-1
            endif           
           enddo
C
          do j3=1,next-noutgoing
           do j1=1,next-1
            if (indexoutgoing(j1).eq.0) then
             do j2=j1,next-1
              indexoutgoing(j2)=indexoutgoing(j2+1)
              massoutgoing(j2)=massoutgoing(j2+1)
             enddo
            endif
           enddo
          enddo
C
          do j3=1,noutgoing
           do j1=1,next-1
            if (indexingoing(j1).eq.0) then
             do j2=j1,next-1
              indexingoing(j2)=indexingoing(j2+1)
             enddo
            endif
           enddo
          enddo
C
           do j1=1,next
            spinsouraux(j1)=spinsour(j1)
           enddo
C
           close (10)
C
           return
           end
C****************************************************************************
         subroutine spinvariable(spinconf,nconfspin)
C****************************************************************************
C
C After the execution of this subroutine the array SPINSOUR will contain
C the spin of the particles chosen randomly according to the values
C of 0 <= RANDNUMB(J) <= 1 .
C
         implicit none
C
         integer ngaubos
         integer nmax        !maximum number of external particles, change here
         integer nspinmax    !maximum number of spinconfiguration, change here
         parameter (ngaubos=23)
         parameter (nmax=8)          
         parameter (nspinmax=3**nmax)          
         integer l1,l2,l3
         integer nconfspin
         integer nsourfermion, nsourfermionbar, nsourhiggs,
     >           nsourgaubosons 
C
         real*8 dummy,max,dummyspin(nmax)
         real*8 inte
         real*8 lattice(nspinmax)
         real*8 partinteg(nspinmax)
         real*8 spinconf(nspinmax,nmax)
         real*8 wei(nspinmax)
C
         common/rescal/wei,lattice
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C                                                                             C
C Containing the common for number external particles. Shared by the       C
C subroutines ITERA, PROCESSO and SPINVARIABLE; 
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
         common/source/nsourhiggs(3),nsourgaubosons(ngaubos),
     >                 nsourfermion(3,4),nsourfermionbar(3,4)
C
         open(41,file='spinconf.dat',status='old')
         read (41,*)nconfspin
         do l1=1,nconfspin
          read(41,*)(spinconf(l1,l2),l2=1,nmax)
         enddo
         close(41)
C
         open(41,file='spinconf_old.dat',status='unknown')
         write (41,*)nconfspin
         do l1=1,nconfspin
          write(41,*)(spinconf(l1,l2),l2=1,nmax)
         enddo
         close(41)
C
         inte=0.
         open(31,file='spinbin.dat',status='old')
         do l1=1,nconfspin
          read(31,*)partinteg(l1)
          inte=inte+partinteg(l1)
         enddo
         close(31)
C
         open(31,file='spinbin_old.dat',status='unknown')
         do l1=1,nconfspin
          write(31,*)partinteg(l1)
          inte=inte+partinteg(l1)
         enddo
         close(31)
C
         do l1=1,nconfspin-1
          max=partinteg(l1)
          do l2=l1+1,nconfspin
           if (partinteg(l2).gt.max)then
            max=partinteg(l2)
            dummy=partinteg(l1)
            partinteg(l1)=partinteg(l2)
            partinteg(l2)=dummy
            do l3=1,nmax
             dummyspin(l3)=spinconf(l1,l3)
             spinconf(l1,l3)=spinconf(l2,l3)
             spinconf(l2,l3)=dummyspin(l3)
            enddo
           endif
          enddo
         enddo
C
         open(41,file='spinconf.dat',status='old')
         write(41,*)nconfspin
         do l1=1,nconfspin
          write(41,*)(spinconf(l1,l2),l2=1,nmax)
         enddo
         close(41)
C
         return
         end
C****************************************************************************
         subroutine fillconfspin(label,spinconf)
C****************************************************************************
C
C After the execution of this subroutine the array SPINSOUR will contain
C the spin of the particles chosen randomly according to the values
C of 0 <= RANDNUMB(J) <= 1 .
C
         implicit none
C
         integer nmax        !maximum number of external particles,change here
         integer nspinmax     !maximum number of spin configuration, change here
         parameter (nmax=8)          
         parameter (nspinmax=3**nmax)          
         integer j1,l1,l2,l3,l4,l5,l6,l7,l8
         integer j(nmax)
         integer label
         integer loop(nmax)
C
         real*8 vecspin(nmax,3)
         real*8 spinconf(nspinmax,nmax)
         real*8 spinsour,spinsouraux
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C                                                                             C
C Containing the common for spin of external particles. Shared by the       C
C subroutines ITERA, PROCESSO, FILLCONFSPIN AND SPINCOULOR 
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
         common/spin/spinsour(nmax),spinsouraux(nmax)
         do j1=1,nmax
C                                 if more than one coulor tensor contribute
          if (nint(spinsouraux(j1)).eq.0) then
           loop(j1)=1
           vecspin(j1,1)=0.
          endif
          if (spinsouraux(j1).gt.0.4) then                !fermion
           loop(j1)=2
           vecspin(j1,1)=0.49
           vecspin(j1,2)=-0.49
          endif
          if (spinsouraux(j1).gt.0.5) then
           loop(j1)=2
           vecspin(j1,1)=0.51
           vecspin(j1,2)=-0.51
          endif
          if (spinsouraux(j1).gt.1.) then               !massive vector boson
           loop(j1)=3
           vecspin(j1,1)=1.
           vecspin(j1,2)=0.
           vecspin(j1,3)=-1.
          endif
          if (spinsouraux(j1).gt.1.05) then              !massless vector boson
           loop(j1)=2
           vecspin(j1,1)=1.
           vecspin(j1,2)=-1.
          endif
C
         enddo
C
         label=0
         do l1=1,loop(1)
          do l2=1,loop(2)
           do l3=1,loop(3)
            do l4=1,loop(4)
             do l5=1,loop(5)
              do l6=1,loop(6)
               do l7=1,loop(7)
                do l8=1,loop(8)
                 label=label+1
                 j(1)=l1
                 j(2)=l2
                 j(3)=l3
                 j(4)=l4
                 j(5)=l5
                 j(6)=l6
                 j(7)=l7
                 j(8)=l8
                 do j1=1,nmax
                  spinconf(label,j1)=vecspin(j1,j(j1))
                 enddo
                enddo
               enddo
              enddo
             enddo
            enddo
           enddo
          enddo
         enddo
C
         open(41,file='spinconf.dat',status='unknown')
         write (41,*)label
         do j1=1,label
          write (41,*)(spinconf(j1,l1),l1=1,nmax)
         enddo
         close(41)
C
         return
         end
C****************************************************************************
         subroutine spincoulor_h (randnumb,nspinconf,label,spinflag,
     >                          spinflag1)
C****************************************************************************
C
C After the execution of this subroutine the array SPINSOUR will contain
C the spin of the particles chosen randomly according to the values
C of 0 <= RANDNUMB(J) <= 1 .
C
         implicit none
C
         integer nmax        !maximum number of external particles,change here
         integer nspinmax    !maximum number of spin configuration, change here
         parameter (nmax=8)          
         parameter (nspinmax=3**nmax)          
         integer j1,j2
         integer label
         integer nspinconf
         integer spinflag
         integer spinflag1
C
         real*8 randnumb
         real*8  spinconf(nspinmax,nmax),spinconfaux(nspinmax,nmax)
         real*8  spinsour, spinsouraux  
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C                                                                             C
C Containing the common for spin of external particles. Shared by the       C
C subroutines ITERA, PROCESSO, FILLCONFSPIN AND SPINCOULOR 
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
         common/spin_gen/spinconfaux
         common/spin/spinsour(nmax),spinsouraux(nmax)
C
         save spinconf
C
         if (spinflag.eq.0)then
          spinflag=1
c          write(6,*)'do you want me to try to define a "clever" spin'
c          write(6,*)'function? (0=no, 1=yes)'
c          read (5,*)spinflag1
          if (spinflag1.eq.0)then
           call fillconfspin(nspinconf,spinconf)
          else
           call spinvariable(spinconf,nspinconf)
          endif
C
          do j1=1,nspinmax
           do j2=1,nmax
            spinconfaux(j1,j2)=spinconf(j1,j2)
           enddo
          enddo
C
         endif
C
         label=int(randnumb*float(nspinconf))+1
         if (label.gt.nspinconf)label=nspinconf
C
         do j1=1,nmax
          spinsour(j1)=spinconfaux(label,j1)
         enddo
C
         return
         end
C****************************************************************************
         subroutine spincoulor (spinflag1,randnumb,nspinconf,label)
C****************************************************************************
C
C After the execution of this subroutine the array SPINSOUR will contain
C the spin of the particles chosen randomly according to the values
C of 0 <= RANDNUMB(J) <= 1 .
C
         implicit none
C
         integer nmax        !maximum number of external particles,change here
         integer nspinmax    !maximum number of spin configuration, change here
         parameter (nmax=8)          
         parameter (nspinmax=3**nmax)          
         integer j1
         integer label
         integer nspinconf
         integer spinflag
         integer spinflag1
C
         real*8 randnumb
         real*8  spinconf(nspinmax,nmax)
         real*8  spinsour, spinsouraux  
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C                                                                             C
C Containing the common for spin of external particles. Shared by the       C
C subroutines ITERA, PROCESSO, FILLCONFSPIN AND SPINCOULOR 
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
         common/spin/spinsour(nmax),spinsouraux(nmax)
C
C
C Static variables
C
         save spinflag,spinconf  
C
         if (spinflag.eq.0)then
          spinflag=1
c          write(6,*)'do you want me to try to define a "clever" spin'
c          write(6,*)'function? (0=no, 1=yes)'
c          read (5,*)spinflag1
          if (spinflag1.eq.0)then
           call fillconfspin(nspinconf,spinconf)
          else
           call spinvariable(spinconf,nspinconf)
          endif
         endif
C
         label=int(randnumb*float(nspinconf))+1
         if (label.gt.nspinconf)label=nspinconf
C
         do j1=1,nmax
          spinsour(j1)=spinconf(label,j1)
         enddo
C
         return
         end
C****************************************************************************
         subroutine spincoulorx (randnumb,nspinconf,label)
C****************************************************************************
C
C After the execution of this subroutine the array SPINSOUR will contain
C the spin of the particles chosen randomly according to the values
C of 0 <= RANDNUMB(J) <= 1 .
C
         implicit none
C
         integer nmax        !maximum number of external particles,change here
         integer nspinmax    !maximum number of spin configuration, change here
         parameter (nmax=8)          
         parameter (nspinmax=3**nmax)          
         integer j1
         integer label
         integer nspinconf
         integer spinflag
         integer spinflag1
C
         real*8 randnumb
         real*8  spinconf(nspinmax,nmax)
         real*8  spinsour, spinsouraux  
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C                                                                             C
C Containing the common for spin of external particles. Shared by the       C
C subroutines ITERA, PROCESSO, FILLCONFSPIN AND SPINCOULOR 
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
         common/spin/spinsour(nmax),spinsouraux(nmax)
C
C
C Static variables
C
         save spinflag,spinconf  
C
C 
         if (spinflag.eq.0)then
          spinflag=1
          write(6,*)'do you want me to try to define a "clever" spin'
          write(6,*)'function? (0=no, 1=yes)'
          read (5,*)spinflag1
          if (spinflag1.eq.0)then
           call fillconfspin(nspinconf,spinconf)
          else
           call spinvariable(spinconf,nspinconf)
          endif
         endif
C
         label=int(randnumb*float(nspinconf))+1
         if (label.gt.nspinconf)label=nspinconf
C
         do j1=1,nmax
          spinsour(j1)=spinconf(label,j1)
         enddo
C
         return
         end
C*****************************************************************************
          subroutine fillmom(momen,noutgoingbis,momen_in,ningoing)
C*****************************************************************************
C
C Returns MOMENTA filled according to what needed by the subroutine ITERA
C
          implicit none
C
          integer nmax        !maximum number of external particles, change here
          parameter (nmax=8)  
          integer indexingoing  !reporting the order of storage of  
C                                       ingoing momenta
          integer indexoutgoing  !reporting the order of storage of  
C                                       outgoing momenta
          integer j1,j2,j3          !loop variable
          integer ningoing            !number of inggoing particles
          integer noutgoingbis   !number of outgoing particles
          integer noutgoing            !number of outgoing particles
C
          real*8  internal    !array of flags to decide wether the particle is
C                              internal or external
          real*8 momenta      !particles momenta
          real*8 momen(4,noutgoingbis)  !outgoing particles momenta
          real*8 momen_in(4,ningoing)  !outgoing particles momenta
          real*8 massoutgoing   !containing the masses of outcoming 
C                                       particles
C
          real*8 momentaprime,flag
          common/momenta/momenta(nmax,4),internal(nmax)
          common/momprime/momentaprime(nmax*4),flag
          common/integra/massoutgoing(nmax),
     >             noutgoing,indexoutgoing(nmax),indexingoing(nmax)
C
          flag=-1.
          do j1=1,noutgoing
           do j2=1,4
            momenta(indexoutgoing(j1),j2)=-momen(j2,j1)
           enddo
          enddo
C
          do j1=1,ningoing
           do j2=1,4
            momenta(indexingoing(j1),j2)=momen_in(j2,j1)
           enddo
          enddo
C
          j3=0
          do j1=1,nmax
           do j2=1,4
            j3=j3+1
            momentaprime(j3)=momenta(j1,j2)
           enddo
          enddo
C
          return
          end
C**************************************************************************
         subroutine writespin
C**************************************************************************
C
         implicit none
C
         integer nmax           !maximum number of external particles, change here
         integer nspinmax       !maximum number of spin configuration, change here
         parameter (nmax=8)
         parameter (nspinmax=3**nmax)
         integer j1
         integer nspinconf1,ncolconf1
         integer spinflag/0/
C
         real*8  partinteg(nspinmax),partinteg1(nspinmax)
C
         common/partspin/partinteg,partinteg1
         common/partspin1/nspinconf1,ncolconf1
C
C Static variables
C
         save spinflag    
C
C 
C
         if (spinflag.eq.0) then
          open(31,file='spinbin.dat',status='unknown')
          open(32,file='colbin.dat',status='unknown')
          spinflag=1
         else
          open(31,file='spinbin.dat',status='old')
          open(32,file='colbin.dat',status='old')
         endif
C
         do j1=1,nspinconf1
          write(31,*)partinteg(j1)
         enddo
         close(31)
C
         do j1=1,ncolconf1
          write(32,*)partinteg1(j1)
         enddo
         close(32)
C
         return
         end
C**************************************************************************
         subroutine regspin(nspinconf,label,ncolconf,label1,
     >                                     result,weight)
C**************************************************************************
C
         implicit none
C
         integer nmax           !maximum number of external particles, change here
         integer nspinmax       !maximum number of spin configuration, change here
         parameter (nmax=8)
         parameter (nspinmax=3**nmax)
         integer j1
         integer flag/0/
         integer nspinconf,nspinconf1
         integer ncolconf,ncolconf1
         integer label,label1
C
         real*8  partinteg(nspinmax),partinteg1(nspinmax)
         real*8  weight
         real*8  result
C
         common/partspin/partinteg,partinteg1
         common/partspin1/nspinconf1,ncolconf1
C
C Static variables
C
         save flag  
C
C 
C
         if (flag.eq.0)then
          do j1=1,nspinmax
           partinteg(j1)=0
           partinteg1(j1)=0
          enddo
          nspinconf1=nspinconf
          ncolconf1=ncolconf
          flag=1
         endif
C
         partinteg(label)=partinteg(label) +result*weight
         if (label1.gt.nspinmax) then
          write(6,*)'number of coulor configurations too big'
          stop
         endif
         partinteg1(label1)=partinteg1(label1) +result*weight
C
         return
         end
C**************************************************************************
         subroutine regspin_new(nspinconf,label,ncolconf,label1,
     >                                     result,weight,flag)
C**************************************************************************
C
         implicit none
C
         integer nmax           !maximum number of external particles, change here
         integer nspinmax       !maximum number of spin configuration, change here
         parameter (nmax=8)
         parameter (nspinmax=3**nmax)
         integer flag
         integer j1
         integer nspinconf,nspinconf1
         integer ncolconf,ncolconf1
         integer label,label1
C
         real*8  partinteg(nspinmax),partinteg1(nspinmax)
         real*8  weight
         real*8  result
C
         common/partspin/partinteg,partinteg1
         common/partspin1/nspinconf1,ncolconf1
C
         if (flag.eq.0)then
          do j1=1,nspinmax
           partinteg(j1)=0
           partinteg1(j1)=0
          enddo
          nspinconf1=nspinconf
          ncolconf1=ncolconf
          flag=1
         endif
C
         partinteg(label)=partinteg(label) +result*weight
         if (label1.gt.nspinmax) then
          write(6,*)'number of coulor configurations too big'
          stop
         endif
         partinteg1(label1)=partinteg1(label1) +result*weight
C
         return
         end
C***********************************************************************
          subroutine readarrtwobytwo_h(arr,ndm1,ndm2,ninteraction,nunit)
C***********************************************************************
C
C It reads NINTERACTION entries (for the first index) of an integer
C array ARR, NDM1 * NDM2 dimensioned, from the logical unit NUNIT
C
          implicit none
C
          integer ndm1,ndm2,ninteraction,nunit,j1,j2,arr(ndm1,ndm2)
          integer inputinteraction(1000),count3   !to initialize relevant interaction terms
          common/interactions/inputinteraction,count3
C
          count3=count3+1
          ninteraction=inputinteraction(count3)
          if(ninteraction.gt.0) then
           do j1=1,ninteraction
            do j2=1,ndm2
             count3=count3+1
             arr(j1,j2)=inputinteraction(count3)
            enddo
           enddo
          endif
C
          return
          end
C**************************************************************************
          subroutine zeroarrayint(arr,nel)
C**************************************************************************
C
C Setting to zero the NEL elements of an integer array ARR
C
          implicit none
          integer nel,arr(nel),j1
C
          do j1=1,nel
           arr(j1)=0
          enddo
C
          return
          end
C**********************************************************************
            subroutine sumintegarr(intarr,npt,sum)
C**********************************************************************
C
C Perform the sum SUM of the first NPT entries of an integer array INTARR(DIM)
C DIM > 0  it is very important!!!!!!
C
            implicit none
C
            integer npt,intarr(npt),sum,j1            
C
            sum=0
            do j1=1,npt
             sum=sum+intarr(j1)
            enddo
C
            return
            end

C*************************************************************************
           subroutine equalintarrays(intarr1,intarr2,npt)
C*************************************************************************
C
C It sets the integer array INTARR2(NPT) equal to INTARR1(NPT)
C
             implicit none
C
             integer npt,intarr1(npt),intarr2(npt),j1
C
             do j1=1,npt
              intarr2(j1)=intarr1(j1)
             enddo
C
             return
             end
C*************************************************************************
           subroutine equalcomparrays(intarr1,intarr2,npt)
C*************************************************************************
C
C It sets the complex array INTARR2(NPT) equal to INTARR1(NPT)
C
             implicit none
C
             integer npt,j1
             complex*16 intarr1(npt),intarr2(npt)
C
             do j1=1,npt
              intarr2(j1)=intarr1(j1)
             enddo
C
             return
             end
C*********************************************************************
          subroutine findmom(nmom,labmom,mom)
C*********************************************************************
C
C Given the number of momenta NMOM contributing to a given configuration
C with label LABMOM returns in MOM the four momenta
C
          implicit none
C
          integer nmax        !maximum number of external particles, change here
          parameter (nmax=8)
          integer nmom,labmom,aux,conf(nmax),start(nmax/2),aux1,j1,j2
          real*8 mom(4),momentaprime(nmax*4),flag,
     >                 momstore(5*(2**nmax-2)/2)
          common/momprime/momentaprime,flag
          common/strt/start
C
C
C Static variables
C
          save momstore
C
C 
          if (flag.lt.0) then
           flag=1.
           aux=0
           do j1=1,(2**nmax-2)/2
            momstore(1+aux)=-1.
            aux=aux+5
           enddo
          endif
C
         aux1=start(nmom)+labmom-1
         aux1=aux1*5+1
         if(momstore(aux1).lt.0) then
          call seleconf(nmom,labmom,conf)
          aux=0
          do j1=1,4
           mom(j1)=0.
          enddo
          do j1=1,8
           if (conf(j1).ne.0) then
            do j2=1,4
             mom(j2)=mom(j2)+momentaprime(j2+aux)
            enddo
           endif
           aux=aux+4
          enddo
C
          momstore(aux1)=1.
          do j1=1,4
           momstore(aux1+j1)=mom(j1)
          enddo
C
         else
          do j1=1,4
           mom(j1)=momstore(aux1+j1)
          enddo
         endif
C
          return
          end
C**********************************************************************72
          subroutine initcompconf
C**********************************************************************72
C
C  It computes all possible products among momenta configuration:
C  Those used in PRODINTERACTION are storedi in the array PRODCONFPROD,
C  those used in LAGINT in the array PRODCONFLAG
C
          implicit none
C
          integer nmax        !maximum number of external particles, change here
          integer dmax
          parameter (nmax=8)
          parameter (dmax=(2**nmax-2)/2)
          integer ddim1,ddim2,ddim3,ddim4
          integer j1,j2,j3,n1,n2,nn1,nn2,newc
          integer next,nfermion,endloop
          common/external/next,nfermion  !containing the number of external
C                                     particles from the subroutine ??????
          integer prodconfprod(2,dmax,dmax),
     >            prodconflag(2,dmax,dmax)
          integer start(nmax/2)
C
          real*8 perm
C
          common/dimens/ddim1,ddim2,ddim3,ddim4 !number of excitations for
C                 CONFIGURATION1,2,3,4 computed in subroutine CONFIGURATION
          common/prodprod/prodconfprod
          common/prodlag/prodconflag
          common/strt/start
C
          do j1=1,2
           do j2=1,dmax
            do j3=1,dmax
             prodconflag(j1,j2,j3)=0
             prodconfprod(j1,j2,j3)=0
            enddo
           enddo
          enddo
C
          start(1)=0
          start(2)=ddim1
          start(3)=ddim1+ddim2
          start(4)=ddim1+ddim2+ddim3
C
          if(next/2.lt.nmax/2) then
           endloop=start(next/2+1)
          else
           endloop=start(nmax/2)+ddim4
          endif
C
          do j1=1,endloop
           do j2=1,endloop
            do j3=1,next/2
             if(start(j3).lt.j1) n1=j3
            enddo
            nn1=j1-start(n1)
            do j3=1,next/2
             if(start(j3).lt.j2) n2=j3
            enddo
            nn2=j2-start(n2)
C
            if(n1+n2.ge.next/2) then
             call compconflag(n1,n2,nn1,nn2,newc,perm) 
             prodconflag(1,j1,j2)=newc
             prodconflag(2,j1,j2)=perm
            else
             prodconflag(1,j1,j2)=0
             prodconflag(2,j1,j2)=0
            endif
            if(n1+n2.le.next/2) then
             call compconf(n1,n2,nn1,nn2,newc,perm) 
             prodconfprod(1,j1,j2)=newc
             prodconfprod(2,j1,j2)=perm
            else
             prodconfprod(1,j1,j2)=0
             prodconfprod(2,j1,j2)=0
            endif
C
           enddo
          enddo
C
          return
          end
C***************************************************************************
             subroutine reorder(first,tens,nl1,nl2,nl3) 
C***************************************************************************
C
C to use in PRODINTERACTION. given the particle FIRST whose equation is
C being computed it returns the interaction vector TENS in the proper order
C NL1, NL2, NL3 are the number of lorentz dof of the particle
C
             implicit none
C
             integer first,nl1,nl2,nl3,j1,j2,j3,lbp1,lbp2,lb,aux,nlormax
             parameter (nlormax=16)
             complex*16 tens(nlormax**3),tensprime(nlormax**3)
C
             if (first.eq.1) then        !T^{1,2,3} --> T^{1,2,3} do nothing
             elseif (first.eq.2) then    !T^{1,2,3} --> T^{2,1,3} 
              lb=0
              aux=nl3*nl2
              lbp1=0
              do j1=1,nl2
               lbp2=0
               do j2=1,nl1
                do j3=1,nl3
                 lb=lb+1
                 tensprime(lb)=tens(j3+lbp1+lbp2)
                enddo
               lbp2=lbp2+aux
               enddo
               lbp1=lbp1+nl3
              enddo
C
              aux=nl1*nl2*nl3
              do j1=1,aux
               tens(j1)=tensprime(j1)
              enddo
C
             elseif (first.eq.3) then    !T^{1,2,3} --> T^{3,1,2} 
              lb=0
              aux=nl3*nl2
              do j3=1,nl3
               lbp1=0
               do j1=1,nl1
                lbp2=0
                do j2=1,nl2
                 lb=lb+1
                 tensprime(lb)=tens(j3+lbp1+lbp2)
                 lbp2=lbp2+nl3
                enddo
                lbp1=lbp1+aux
               enddo
              enddo
C
              aux=nl1*nl2*nl3
              do j1=1,aux
               tens(j1)=tensprime(j1)
              enddo
C
             else
              write(6,*)'FIRST=',first,'in subroutine REORDER !!!!!'
             endif
C
             return
             end

C**********************************************************************
          subroutine readarrtwobytwo(arr,ndm1,ndm2,ninteraction,nunit)
C**********************************************************************
C
C It reads NINTERACTION entries (for the first index) of an integer
C array ARR, NDM1 * NDM2 dimensioned, from the logical unit NUNIT
C
          implicit none
C
          integer ndm1,ndm2,ninteraction,nunit,j1,j2,arr(ndm1,ndm2)
C
          read (nunit,*) ninteraction
          if(ninteraction.gt.0) then
           do j1=1,ninteraction
            do j2=1,ndm2
             read(nunit,*) arr(j1,j2)
            enddo
           enddo
          endif
C
          return
          end


C***********************************************************************
          subroutine couplings           
C***********************************************************************
C
C This subroutine returns the couplings of the model
C 
          implicit none
C
          complex*16 re
          parameter(re=(1.,0.))
C
          real*8 conver       !to convert to the chosen mass units
          parameter (conver=1.)   !25 GeV units
          integer ngaubos
          parameter (ngaubos=23)     !number of gauge bosons fields,
C                                       including auxiliary fields
          real*8 minfer       !conventionally no mass fermion is less
C                              than minfer
          parameter (minfer=0.2*conver) !200 MeV limit
C
          real*8 higgsvev     !higgs vacuum expectation value
          real*8 gsu2l        !SU(2)_L gauge coupling
          real*8 gu1y         !U(1)_Y gauge coupling
          real*8 gbar
          real*8 ctetaw
          real*8 stetaw       !Weinberg angle
          complex*16 vud       !V_{ud}  Cabibbo-Kobayashi-Maskawa entry
          complex*16 vus
          complex*16 vub
          complex*16 vcd
          complex*16 vcs
          complex*16 vcb
          complex*16 vtd
          complex*16 vts
          complex*16 vtb
          complex*16 vdu
          complex*16 vdc
          complex*16 vdt
          complex*16 vsu
          complex*16 vsc
          complex*16 vst
          complex*16 vbu
          complex*16 vbc
          complex*16 vbt
C
C          include 'couplings_e.comm'
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C COUPLINGS.COMM
C
C Containing the common for coupling constan. Shared by the subroutines       C
C ITERA and COUPLINGS                                                         C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
          complex*16 selfhiggs(3)  !higgs  and auxiliary-higgs selfcoupling 
C                                                            constant
          complex*16 yukawa(3,4,3,4)    !yukawa couplings
          complex*16 vectorial(ngaubos,3,4,3,4)   !V fermions-gauge-bosons interactions
          complex*16 assial(ngaubos,3,4,3,4)   !V fermions-gauge-bosons interactions
          complex*16 selfgauge(ngaubos,ngaubos,ngaubos)   !gauge-bosons self-interactions
          complex*16 higgsgauge(3,ngaubos,ngaubos)  !higgs-gauge bosons couplings
C
          common/coupconst/selfhiggs,yukawa,vectorial,selfgauge,
     >                    higgsgauge,assial                     !in this common 
C                             all the couplings of the theory are transferred.
C                               Wishing to add a new coupling change here




C          include 'masses_e.comm'
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C                                                                             C
C MASSES.COMM                                                                 C
C                                                                             C
C Containing the common for particles masses. Shared by the subroutines       C
C ITERA and COUPLINGS                                                         C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
          real*8 masshiggs(3)    !higgs mass
          real*8 massgaubosons(ngaubos)   !zboson mass
          real*8 massfermion(3,4)  !fermion masses
          real*8 widthhiggs(3)    !higgs width
          real*8 widthgaubosons(ngaubos)   !zboson width
          real*8 widthfermion(3,4)  !fermion widthes
C
          common/masses/masshiggs,massgaubosons,massfermion ,
     >                  widthhiggs,widthgaubosons,widthfermion !in this
C                      common all the  masses of the particles are transferred.
C                                    Wishing to add a new particle change here





C
          data masshiggs/3*0./
          data massgaubosons/ngaubos*0./
          data massfermion/12*0./
          data widthhiggs/3*0./
          data widthgaubosons/ngaubos*0./
          data widthfermion/12*0./
C
          data selfhiggs/3*0./
          data yukawa/144*0./
          integer nvec
          parameter (nvec=144*ngaubos)
          data vectorial/nvec*0./
          data assial/nvec*0./
          integer ngau
          parameter (ngau=ngaubos**3)
          data selfgauge/ngau*0./
          integer ngh
          parameter (ngh=ngaubos**2*3)
          data higgsgauge/ngh*0./
          real*8 awwgg,awgwg,awwgz,awzwg,awpzfwfg,awmzfwfg
          real*8 azzgg
          common/an4g/awwgg,awgwg,azzgg         
          common/an4gz/awwgz,awzwg,awpzfwfg,awmzfwfg
C
c          call warning
C
          gsu2l=0.6516162
          gu1y =0.341995975392041
          gbar =sqrt(gsu2l**2+gu1y**2)
          ctetaw=gsu2l/gbar
          stetaw=gu1y/gbar
          higgsvev=246.221*conver
C
C          include 'masses.matrix'
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C  MASSES.MATRIX, used in COUPLINGS
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C Masses, units 25 GeV. The constant CONVER is used to allow the possibility
C to choose different units
C
          masshiggs(1)=170.*conver        !at some point we need to fix values
C                                                             and normalization
C
          massfermion(3,1)=175.*conver           !top mass
          massfermion(3,2)=0.! minfer !4.8*conver            !bottom mass
          massfermion(3,3)=minfer            !\nu_\tau mass conventionally
C                                                 no mass is less than minfer
          massfermion(3,4)=1.7771*conver         !\tau mass      
          massfermion(2,1)=0. !minfer ! 1.3*conver            !charm mass
          massfermion(2,2)=0.  !minfer             !strange mass
          massfermion(2,3)=minfer             !\nu_\mu mass
          massfermion(2,4)=0.  !0.105658389*conver             !\mu mass
          massfermion(1,1)=0.   !0.005*conver                     !up mass
          massfermion(1,2)=0.    !0.010*conver              !down mass
          massfermion(1,3)=minfer                    !\nu_e mass
          massfermion(1,4)=0. !minfer !0.0005*conver             !e^- mass
C
C          massgaubosons(1)=gbar*higgsvev/2.        !Z mass
          massgaubosons(1)=91.1887*conver           !Z mass LEPII agreed
C          massgaubosons(2)=gsu2l*higgsvev/2.       !W^+ mass
          massgaubosons(2)=80.23*conver           !W^+ mass LEPII agreed
          massgaubosons(3)=massgaubosons(2)         !W^- mass 
C          include 'widths.matrix'
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C  WIDTHS.MATRIX, used in COUPLINGS
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C widthes, units 25 GeV. The constant CONVER is used to allow the possibility
C to choose different units
C
          widthhiggs(1)= 0.2 !3.238874011324727E-003*conver  !1.*conver     !at some point we need to fix values
C                                                             and normalization
C
c          widthfermion(3,1)=5.*conver            !top width
c          widthfermion(3,2)=0.5*conver             !bottom width
c          widthfermion(3,3)=0.5*conver          !\nu_\tau width  Conventionally
C                                                 no width is less than 50 MeV
c          widthfermion(3,4)=0.05*conver          !\tau width      
c          widthfermion(2,1)=0.05*conver             !charm width
c          widthfermion(2,2)=0.05*conver             !strange width
c          widthfermion(2,3)=0.05*conver             !\nu_\mu width
c          widthfermion(2,4)=0.0005*conver             !\mu width
c          widthfermion(1,1)=0.05*conver             !up width
c          widthfermion(1,2)=0.05*conver             !down width
c          widthfermion(1,3)=0.05*conver             !\nu_e width
c          widthfermion(1,4)=0.05*conver             !e^- width
C
          widthgaubosons(1)=2.4974*conver         !Z width
          widthgaubosons(2)=2.03367*conver         !W^+ width
          widthgaubosons(3)=widthgaubosons(2)      !W^- width
C
C Coupling constants
C
c          selfhiggs(1)=masshiggs(1)**2./higgsvev/2.*re     !higgs trilinear self 
C                                                                     coupling
c          selfhiggs(2)= re                               !Y_h h h coupling
c          selfhiggs(3)=masshiggs(1)**2./higgsvev**2/8.*re  !X_h h h coupling
C
C          include 'yukawa.matrix'
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C YUKAWA.MATRIX used in COUPLINGS
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
c          yukawa(3,1,3,1)=175./higgsvev*re*conver                !top yukawa
C          yukawa(3,2,3,2)=4.3/higgsvev*re*conver                 !bottom yukawa
           yukawa(3,2,3,2)=4.7/2./MASSGAUBOSONS(2)*re*conver 
     >          *gsu2l            !bottom yukawa
c          yukawa(3,3,3,3)=0.5/higgsvev*re*conver              !\nu_\tau yukawa
c          yukawa(3,4,3,4)=1.7771/higgsvev*re*conver              !\tau yukawa
c          yukawa(2,1,2,1)=1.3/higgsvev*re*conver                 !charm yukawa
c          yukawa(2,2,2,2)=0.5/higgsvev*re*conver                !strange yukawa
c          yukawa(2,3,2,4)=0.5/higgsvev*re*conver                !\nu_\mu yukawa
c          yukawa(2,4,2,4)=0.5/higgsvev*re*conver                 !muon yukawa
c          yukawa(1,1,1,1)=0.5/higgsvev*re*conver                 !up yukawa
c          yukawa(1,2,1,2)=0.5/higgsvev*re*conver                 !down yukawa
c          yukawa(1,3,1,3)=0.5/higgsvev*re*conver                !\nu_e yukawa
c          yukawa(1,4,1,4)=0.5/higgsvev*re*conver              !electron yukawa

C
          vud=1.*re
          vus=0.*re
          vub=0.*re
          vcd=0.*re
          vcs=1.*re
          vcb=0.*re
          vtd=0.*re
          vts=0.*re
          vtb=1.*re
          vdu=1.*re
          vsu=0.*re
          vbu=0.*re
          vdc=0.*re
          vsc=1.*re
          vbc=0.*re
          vdt=0.*re
          vst=0.*re
          vbt=1.*re
C
C          include 'vectorial.matrix'
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C VECTORIAL.MATRIX used in COUPLINGS
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
          vectorial(1,3,1,3,1)=-gbar*(1.-stetaw**2*8/3.)/4.*re  !Z \bar t t     V coupling
          vectorial(1,2,1,2,1)=-gbar*(1.-stetaw**2*8/3.)/4.*re  !Z \bar c c     V coupling
          vectorial(1,1,1,1,1)=-gbar*(1.-stetaw**2*8/3.)/4.*re  !Z \bar u u     V coupling
          vectorial(1,3,2,3,2)=-gbar*(-1.+stetaw**2*4/3.)/4.*re  !Z \bar b b     V coupling
          vectorial(1,2,2,2,2)=-gbar*(-1.+stetaw**2*4/3.)/4.*re  !Z \bar s s     V coupling
          vectorial(1,1,2,1,2)=-gbar*(-1.+stetaw**2*4/3.)/4.*re  !Z \bar d d     V coupling
          vectorial(1,3,3,3,3)=-gbar*(1.)/4.*re  !Z \bar \nu_\tau \nu_\tau     V coupling
          vectorial(1,2,3,2,3)=-gbar*(1.)/4.*re  !Z \bar \nu_\mu \nu_\mu     V coupling
          vectorial(1,1,3,1,3)=-gbar*(1.)/4.*re  !Z \bar \nu_e \nu_e     V coupling
          vectorial(1,3,4,3,4)=-gbar*(-1.+stetaw**2*4.)/4.*re  !Z \bar \tau \tau    V 
          vectorial(1,2,4,2,4)=-gbar*(-1.+stetaw**2*4.)/4.*re  !Z \bar \mu \mu     V 
          vectorial(1,1,4,1,4)=-gbar*(-1.+stetaw**2*4.)/4.*re  !Z \bar  e e  V 
          vectorial(10,3,1,3,1)=-gbar*ctetaw*stetaw*2./3.*re  !A \bar t t     V coupling
          vectorial(10,2,1,2,1)=-gbar*ctetaw*stetaw*2./3.*re  !A \bar c c     V coupling
          vectorial(10,1,1,1,1)=-gbar*ctetaw*stetaw*2./3.*re  !A \bar u u     V coupling
          vectorial(10,3,2,3,2)=gbar*ctetaw*stetaw/3.*re  !A \bar b b     V coupling
          vectorial(10,2,2,2,2)=gbar*ctetaw*stetaw/3.*re  !A \bar s s     V coupling
          vectorial(10,1,2,1,2)=gbar*ctetaw*stetaw/3.*re  !A \bar d d     V coupling
          vectorial(10,3,4,3,4)=gbar*ctetaw*stetaw*re  !A \bar \tau \tau     V coupling
          vectorial(10,2,4,2,4)=gbar*ctetaw*stetaw*re  !A \bar \mu \mu       V coupling
          vectorial(10,1,4,1,4)=gbar*ctetaw*stetaw*re  !A \bar e e           V coupling
C
          vectorial(2,3,1,3,2)=-gsu2l/sqrt(2.)/2.*vtb  !W^+ \bar t b     V coupling
          vectorial(3,3,2,3,1)=-gsu2l/sqrt(2.)/2.*vbt  !W^- \bar b t     V coupling
          vectorial(2,3,1,2,2)=-gsu2l/sqrt(2.)/2.*vts  !W^+ \bar t s     V coupling
          vectorial(3,2,2,3,1)=-gsu2l/sqrt(2.)/2.*vst  !W^- \bar s t     V coupling
          vectorial(2,3,1,1,2)=-gsu2l/sqrt(2.)/2.*vtd  !W^+ \bar t d     V coupling
          vectorial(3,1,2,3,1)=-gsu2l/sqrt(2.)/2.*vdt  !W^- \bar d t     V coupling
C
          vectorial(2,2,1,3,2)=-gsu2l/sqrt(2.)/2.*vcb  !W^+ \bar c b     V coupling
          vectorial(3,3,2,2,1)=-gsu2l/sqrt(2.)/2.*vbc  !W^- \bar b c     V coupling
          vectorial(2,2,1,2,2)=-gsu2l/sqrt(2.)/2.*vcs  !W^+ \bar c s     V coupling
          vectorial(3,2,2,2,1)=-gsu2l/sqrt(2.)/2.*vsc  !W^- \bar s c     V coupling
          vectorial(2,2,1,1,2)=-gsu2l/sqrt(2.)/2.*vcd  !W^+ \bar c d     V coupling
          vectorial(3,1,2,2,1)=-gsu2l/sqrt(2.)/2.*vdc  !W^- \bar d c     V coupling
C
          vectorial(2,1,1,3,2)=-gsu2l/sqrt(2.)/2.*vub  !W^+ \bar u b     V coupling
          vectorial(3,3,2,1,1)=-gsu2l/sqrt(2.)/2.*vbu  !W^- \bar b u     V coupling
          vectorial(2,1,1,2,2)=-gsu2l/sqrt(2.)/2.*vus  !W^+ \bar u b     V coupling
          vectorial(3,2,2,1,1)=-gsu2l/sqrt(2.)/2.*vsu  !W^- \bar b u     V coupling
          vectorial(2,1,1,1,2)=-gsu2l/sqrt(2.)/2.*vud  !W^+ \bar u b     V coupling
          vectorial(3,1,2,1,1)=-gsu2l/sqrt(2.)/2.*vdu  !W^- \bar b u     V coupling
C
          vectorial(2,3,3,3,4)=-gsu2l/sqrt(2.)/2.*re  !W^+ \bar \nu_\tau \tau    V coupling
          vectorial(3,3,4,3,3)=-gsu2l/sqrt(2.)/2.*re !W^+ \bar \tau \nu_\tau     V coupling
C
          vectorial(2,2,3,2,4)=-gsu2l/sqrt(2.)/2.*re  !W^+ \bar \nu_\mu \mu    V coupling
          vectorial(3,2,4,2,3)=-gsu2l/sqrt(2.)/2.*re  !W^+ \bar \mu \nu_\mu     V coupling
C
          vectorial(2,1,3,1,4)=-gsu2l/sqrt(2.)/2.*re  !W^+ \bar \nu_e e  V coupling
          vectorial(3,1,4,1,3)=-gsu2l/sqrt(2.)/2.*re  !W^+ \bar e \nu_e  V coupling
C
 

C          include 'assial.matrix'
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C ASSIAL.MATRIX used in COUPLINGS
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
          assial(1,3,1,3,1)=gbar/4.*re  !Z \bar t t     A coupling
          assial(1,2,1,2,1)=gbar/4.*re  !Z \bar c c     A coupling
          assial(1,1,1,1,1)=gbar/4.*re  !Z \bar u u     A coupling
          assial(1,3,2,3,2)=-gbar/4.*re !Z \bar b b     A coupling
          assial(1,2,2,2,2)=-gbar/4.*re !Z \bar s s     A coupling
          assial(1,1,2,1,2)=-gbar/4.*re !Z \bar d d     A coupling
          assial(1,3,3,3,3)=gbar/4.*re  !Z \bar \nu_\tau \nu_\tau     A coupling
          assial(1,2,3,2,3)=gbar/4.*re  !Z \bar \nu_\mu \nu_\mu       A coupling
          assial(1,1,3,1,3)=gbar/4.*re  !Z \bar \nu_e \nu_e           A coupling
          assial(1,3,4,3,4)=-gbar/4.*re  !Z \bar \tau \tau            A coupling
          assial(1,2,4,2,4)=-gbar/4.*re  !Z \bar \mu \mu              A coupling
          assial(1,1,4,1,4)=-gbar/4.*re  !Z \bar e e                  A coupling
C
          assial(2,3,1,3,2)=gsu2l/sqrt(2.)/2.*vtb  !W^+ \bar t b     A coupling
          assial(3,3,2,3,1)=gsu2l/sqrt(2.)/2.*vbt  !W^- \bar b t     A coupling
          assial(2,3,1,2,2)=gsu2l/sqrt(2.)/2.*vts  !W^+ \bar t s     A coupling
          assial(3,2,2,3,1)=gsu2l/sqrt(2.)/2.*vst  !W^- \bar s t     A coupling
          assial(2,3,1,1,2)=gsu2l/sqrt(2.)/2.*vtd  !W^+ \bar t d     A coupling
          assial(3,1,2,3,1)=gsu2l/sqrt(2.)/2.*vdt  !W^- \bar d t     A coupling
C
          assial(2,2,1,3,2)=gsu2l/sqrt(2.)/2.*vcb  !W^+ \bar c b     A coupling
          assial(3,3,2,2,1)=gsu2l/sqrt(2.)/2.*vbc  !W^- \bar b c     A coupling
          assial(2,2,1,2,2)=gsu2l/sqrt(2.)/2.*vcs  !W^+ \bar c s     A coupling
          assial(3,2,2,2,1)=gsu2l/sqrt(2.)/2.*vsc  !W^- \bar s c     A coupling
          assial(2,2,1,1,2)=gsu2l/sqrt(2.)/2.*vcd  !W^+ \bar c d     A coupling
          assial(3,1,2,2,1)=gsu2l/sqrt(2.)/2.*vdc  !W^- \bar d c     A coupling
C
          assial(2,1,1,3,2)=gsu2l/sqrt(2.)/2.*vub  !W^+ \bar u b     A coupling
          assial(3,3,2,1,1)=gsu2l/sqrt(2.)/2.*vbu  !W^- \bar b u     A coupling
          assial(2,1,1,2,2)=gsu2l/sqrt(2.)/2.*vus  !W^+ \bar u b     A coupling
          assial(3,2,2,1,1)=gsu2l/sqrt(2.)/2.*vsu  !W^- \bar b u     A coupling
          assial(2,1,1,1,2)=gsu2l/sqrt(2.)/2.*vud  !W^+ \bar u b     A coupling
          assial(3,1,2,1,1)=gsu2l/sqrt(2.)/2.*vdu  !W^- \bar b u     A coupling
C
          assial(2,3,3,3,4)=gsu2l/sqrt(2.)/2.*re  !W^+ \bar \nu_\tau \tau  A coupling
          assial(3,3,4,3,3)=gsu2l/sqrt(2.)/2.*re  !W^- \bar \tau \nu_\tau  A coupling
C
          assial(2,2,3,2,4)=gsu2l/sqrt(2.)/2.*re !W^+ \bar \nu_\mu \mu    A coupling
          assial(3,2,4,2,3)=gsu2l/sqrt(2.)/2. *re !W^- \bar \mu \nu_\mu    A coupling
C
          assial(2,1,3,1,4)=gsu2l/sqrt(2.)/2.*re  !W^+ \bar \nu_e e        A coupling
          assial(3,1,4,1,3)=gsu2l/sqrt(2.)/2.*re  !W^- \bar e \nu_e        A coupling
C


C
C          include 'selfgauge.matrix'        !W^+ W^- Z      couplings
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C SELFGAUGE.MATRIX, used in COUPLINGS
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
          selfgauge(1,2,3)   = gsu2l*ctetaw*re
          selfgauge(10,2,3)  = gsu2l*stetaw*re
          selfgauge(4,2,3)   = gsu2l*re          
          selfgauge(5,1,1)   = gsu2l*ctetaw**2*re          
          selfgauge(5,1,10)  = 2.*gsu2l*ctetaw*stetaw*re          
          selfgauge(5,10,10) = gsu2l*stetaw**2*re          
          selfgauge(5,2,3)   = gsu2l/2.*re  
          selfgauge(6,1,2)   = gsu2l*ctetaw*re          
          selfgauge(6,10,2)  = gsu2l*stetaw*re  
          selfgauge(7,1,3)   = - gsu2l*ctetaw*re          
          selfgauge(7,10,3)  = - gsu2l*stetaw*re          
          selfgauge(8,2,2)   = gsu2l*re          
          selfgauge(9,3,3)   = -gsu2l/2.*re          

C
C          include 'higgsgauge.matrix'
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C HIGGSGAUGE.MATRIX used in subroutine COUPLINGS
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
         higgsgauge(1,1,1)=-gbar*massgaubosons(1)/2.*re
         higgsgauge(1,2,3)=-gsu2l*massgaubosons(2)*re
c         higgsgauge(3,1,1)=-gbar**2/8.*re
c         higgsgauge(3,2,3)=-gsu2l**2/4.*re

C
          include 'initial_agc.par'
C
          return
          end


*******************************************************
*
* SUBROUTINE NUNUGPV_R IS INTENDED TO BE USED FOR REWEIGHTING 
* PROCEDURE OF A GIVEN EVENT SAMPLE BY VARIATION OF THE 
* QUARTIC ANOMALOUS GAUGE COUPLINGS A0W, A0Z, ACW, ACZ 
* IN THE PROCESS E+ E- --> NU BAR NU GAMMA GAMMA
*
****************************************************************************
* INPUT: NFLV (E,M,T,F) IS THE NEUTRINO FLAVOUR (F= SUM OVER ALL FLAVOURS)
*        MOMEN_IN(4,8) IS THE MOMENTUM MATRIX OF THE INCOMING LEPTONS
*                      MOMEN_IN(I,1) I-TH COMPONENT OF THE ELECTRON MOMENTUM
*                      MOMEN_IN(I,2) I-TH COMPONENT OF THE POSITRON MOMENTUM
*                                    I=1  ENERGY, I=2,3,4  X,Y,Z COMPONENTS
*        MOMEN(4,8) IS THE FINAL STATE MOMENTUM MATRIX
*                   MOMEN(I,1) I-TH COMPONENT OF THE NU MOMENTUM
*                   MOMEN(I,2) I-TH COMPONENT OF THE BAR NU MOMENTUM
*                   MOMEN(I,3) I-TH COMPONENT OF THE PHOTON 1 MOMENTUM
*                   MOMEN(I,4) I-TH COMPONENT OF THE PHOTON 2 MOMENTUM
*                              I=1 ENERGY, I=2,3,4 X,Y,Z COMPONENTS
*        XLAMBDA    IS THE SCALE OF NEW PHYSICS
*        A0W        IS THE A0 CONTRIBUTION DUE TO WWGG VERTEX
*        A0Z        IS THE A0 CONTRIBUTION DUE TO ZZGG VERTEX
*        ACW        IS THE AC CONTRIBUTION DUE TO WWGG VERTEX
*        ACZ        IS THE AC CONTRIBUTION DUE TO ZZGG VERTEX
*
*     NOTE: EVEN IF THE CHARGED AND NEUTRAL CONTRIBUTIONS ARE SEPARATED,
*           IN ORDER TO ENSURE SU(2) CUSTODIAL SYMMETRY, 
*           A0W=A0Z AND ACW=ACZ SHOULD BE ENTERED
*
* OUTPUT: SQME      IS THE SQUARED MATRIX ELEMENT 
*                           (APART FROM CONSTANTS WHICH CANCEL IN THE 
*                            RATIO ME_QAGC/ME_SM)
****************************************************************************
      SUBROUTINE NUNUGPV_R(NFLV,MOMEN_IN,MOMEN,
     #                     XLAMBDA,A0W,A0Z,ACW,ACZ,SQME)
      IMPLICIT REAL*8 (A-H,O-Z)
*
      PARAMETER (NMAX_ALPHA=8)
      CHARACTER*1 NFLV
      REAL*8 MOMEN(4,NMAX_ALPHA),MOMEN_IN(4,NMAX_ALPHA)
      REAL*8 MASSOUTGOING(NMAX_ALPHA)
      INTEGER INDEXOUTGOING(NMAX_ALPHA),INDEXINGOING(NMAX_ALPHA)
      COMPLEX*16 ELMAT
      INTEGER COULORSOUR(NMAX_ALPHA)
      INTEGER NINGOING
      DATA IFLAGP/0/
      COMMON/PAR/WM,WG,CFACT,GF,G,ZM,ZW,PI,ALPHA,EM2
      COMMON/PARD/ZM2,ZW2,WM2,WG2,GF2,G2,G4,G8
      COMMON/THETAW/STH2
      COMMON/INTEGRA/MASSOUTGOING,
     #               NOUTGOING,INDEXOUTGOING,INDEXINGOING
      COMMON/COLOR/COULORSOUR
*
      SAVE IFLAGP
*
      IF(IFLAGP.EQ.0) THEN
         IFLAGP= 1
         CALL PARAMETERS()
      ENDIF
*
      IF(NFLV.EQ.'E') THEN
         NFLMIN = 1
         NFLMAX = 1
      ELSE IF(NFLV.EQ.'M'.OR.NFLV.EQ.'T') THEN
         NFLMIN = 2
         NFLMAX = 2
      ELSE IF(NFLV.EQ.'F') THEN
         NFLMIN = 1
         NFLMAX = 2
      ENDIF  
      IFLAG_SPIN = 0
      INIT_SPIN=0  
      INIT_FLAG=0  
      INIT_REG=0   
      NCONF=64     
      DO J=1,8
         COULORSOUR(J)=1
      ENDDO
*
      ningoing=2                ! number of ingoing particles
*
      SQME= 0.D0
      DO ISPIN=1,64
         redefined=(float(ispin)-0.5)/64.
         DO IFL = NFLMIN,NFLMAX
            CALL PROCESSO_H(IFL) 
*
            call parametersbis(xlambda,a0w,a0z,acw,acz)

            CALL FILLMOM(MOMEN,NOUTGOING,momen_in,ningoing)
            CALL SPINCOULOR_H(REDEFINED,NSPINCONF,LABEL,INIT_SPIN,
     >                        IFLAG_SPIN)

            CALL ITERA(ELMAT)
            IF(IFL.EQ.1) ELMATSQE = (ABS(ELMAT))**2
            IF(IFL.EQ.2) ELMATSQM = (ABS(ELMAT))**2
         ENDDO
*
         IF(NFLV.EQ.'E') THEN
            ELMATSQ = ELMATSQE
         ELSE IF(NFLV.EQ.'M'.OR.NFLV.EQ.'T') THEN
            ELMATSQ = ELMATSQM
         ELSE IF(NFLV.EQ.'F') THEN
            ELMATSQ = 2.D0*ELMATSQM + ELMATSQE
         ENDIF 
*
         EMTRX = ELMATSQ
         EMTRX = EMTRX * CFACT      
         EMTRX = EMTRX / 4.D0  ! I. S. SPIN AVERAGE
         EMTRX = EMTRX*(4.D0*PI*ALPHA/G2/STH2)**2
         SQME = SQME + EMTRX 
      ENDDO    
*
      RETURN
      END
*
*-----SUBROUTINE PARAMETERSbis()
*
      SUBROUTINE PARAMETERSbis(xlambda,a0w,a0z,acw,acz)
      IMPLICIT none
      integer ngaubos
      parameter (ngaubos=23)     !number of gauge bosons fields,
C                                       including auxiliary fields
      COMPLEX*16 GZCLEPV,GZCLEPA,GZNLEPV,GZNLEPA,GZCUPV,GZCUPA,GZCDNV,
     #           GZCDNA,GWLEPV,GWLEPA,E_ELM,HWW,HZZ,ZWW,AWW,ZW13,ZW14,
     #           zz15,ww16,gg17,gz17,zwp18,wmg19,gwm19,zwm18,wpg19,gwp19
     #          ,zz20,gg21,zazb22,gagb23 
      COMPLEX*16 WW4,ZZ5,ZG5,GG5,WW5,GW5,GW6,ZW7,GW7,WW8,WW9 
      real*8 a0w,a0z,acw,acz,xlambda
C
      complex*16 selfhiggs(3)  !higgs  and auxiliary-higgs selfcoupling 
C                                                            constant
      complex*16 yukawa(3,4,3,4)    !yukawa couplings
      complex*16 vectorial(ngaubos,3,4,3,4)   !V fermions-gauge-bosons interactions
      complex*16 assial(ngaubos,3,4,3,4)   !V fermions-gauge-bosons interactions
      complex*16 selfgauge(ngaubos,ngaubos,ngaubos)   !gauge-bosons self-interactions
      complex*16 higgsgauge(3,ngaubos,ngaubos)  !higgs-gauge bosons couplings
C
      common/coupconst/selfhiggs,yukawa,vectorial,selfgauge,
     >                 higgsgauge,assial                     !in this common 
C                             all the couplings of the theory are transferred.
C                               Wishing to add a new coupling change here
C
      real*8 alphai,omda,dela,rho,delr,wm2,amup,sth2,g2,sth
      real*8 cth,cth2,prefact,azzpm,apmpm,appmm,apzmz,azzzz
      real*8 EM,AMU,TLM,UQM,DQM,CQM,SQM,BQM,TQM
      real*8 WM,WG,CFACT,GF,G,ZM,ZW,PI,ALPHA,EM2


      COMMON/FM/EM,AMU,TLM,UQM,DQM,CQM,SQM,BQM,TQM        
      COMMON/PAR/WM,WG,CFACT,GF,G,ZM,ZW,PI,ALPHA,EM2      
      COMMON/AIN/ALPHAI                                   

      real*8 gv,kv,lv,gv5,kp,lp,awwgg,awgwg !anomalous couplings
      real*8 awwgz,awzwg,awpzfwfg,awmzfwfg,awmfwpgfz
      real*8 agfwpwmfz,awpfwmgfz,agfwmwpfz,azgzg,azzgg

      common/anz/gv,kv,lv,gv5
      common/ang/kp,lp
      common/anm4/apmpm,appmm,apzmz,azzpm,azzzz
      common/an4g/awwgg,awgwg,azzgg
      common/an4gz/awwgz,awzwg,awpzfwfg,awmzfwfg
*
*     PARAMETERS ARE INITIALIZED
*
*
*-----DERIVED PARAMETERS
*
      WM2= WM*WM
*
      DELA= 1.D0 - ALPHA/ALPHAI          
      OMDA= 1.D0-DELA
*      
      AMUP= SQRT(PI*ALPHA/2.D0/GF)
      DELR= 3.D0*GF*TQM**2/8.D0/PI/PI
      RHO= 1.D0/(1.D0-DELR)

      STH2= 0.5D0*(1.D0-SQRT(1.D0-4.D0*AMUP**2/RHO/ZM/ZM/OMDA))
*
      G2 = 8.D0*GF*WM2
      G= SQRT(G2)
      STH= SQRT(STH2)
      CTH2= 1.D0-STH2
      CTH= SQRT(CTH2)
*
      PREFACT=-(G*STH/XLAMBDA)**2/16.D0      
      awwgg=prefact*2.d0*a0w
      awgwg=prefact*acw
      azzgg=prefact/cth2*a0z
      azgzg=prefact/cth2*acz
*
      awzwg      = awzwg/2.d0  !rescaling
      awpzfwfg   = -awpzfwfg   !signe changes 
      awmzfwfg   = -awpzfwfg   !WZ1 
*
      awmfwpgfz  = 0.d0
      agfwpwmfz  = 0.d0
      awpfwmgfz  = 0.d0
      agfwmwpfz  = 0.d0
*
c      agfwmwpfz  =  agfwpwmfz  !WZ2   
c      awpfwmgfz  =  awmfwpgfz  !WZ3        
      awgwg = awgwg/2.d0
      azgzg = azgzg/4.d0
*
*-----QUADRILINEAR GAUGE SELF COUPLINGS   (couplings for auxiliary fields)
*
      azzpm= 0.
      apmpm= 0.
      appmm= 0.
      apzmz= 0.
      azzzz= 0.
      selfgauge(17,10,10) =  awgwg
      selfgauge(17,1,10) = awzwg
      selfgauge(19,3,10) = awmfwpgfz
      selfgauge(19,10,3) = agfwpwmfz
      selfgauge(19,2,10) = awpfwmgfz
      selfgauge(19,10,2) = agfwmwpfz
      selfgauge(23,10,10) = azgzg
      awwgg=awwgg/selfgauge(10,2,3)**2 
      awwgz=awwgz/selfgauge(10,2,3)/selfgauge(1,2,3)/2.d0
      awpzfwfg=awpzfwfg/selfgauge(10,2,3)/selfgauge(1,2,3)
      awmzfwfg=-awmzfwfg/selfgauge(10,2,3)/selfgauge(1,2,3)
*
      RETURN
      END



