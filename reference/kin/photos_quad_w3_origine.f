*///////////////////////////////////////////////////////////////////////
*//                                                                     
*//  !!!!!!! WARNING!!!!!   This source may be  agressive !!!!          
*//                                                                     
*//  Due to short common block names it may owerwrite variables in other
*//  parts of the code.                                                 
*//                                                                     
*//  One should add suffix c_Photos_ to names of all commons as soon as 
*//  possible!!  
*///////////////////////////////////////////////////////////////////////

C.----------------------------------------------------------------------
C.
C.    PHOTOS:   PHOtos CDE-s
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
C.                                      PHOTOS_GET
C.                                      PHOTOS_SET
C.                                      PHOTOS_MAKE
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
C.                                      PHCORK
C.                                      IPHQRK
C.                                      IPHEKL
C.   COMMONS:
C.   NAME     USED IN SECT. # OF OCC.     Comment
C.   PHOQED   1) 2)            3      Flags whether emisson to be gen. 
C.   PHOLUN   1) 4)            6      Output device number
C.   PHOCOP   1) 3)            4      photon coupling & min energy
C.   PHPICO   1) 3) 4)         5      PI & 2*PI
C.   PHSEED   1) 4)            3      RN seed 
C.   PHOSTA   1) 4)            3      Status information
C.   PHOKEY   1) 2) 3)         7      Keys for nonstandard application
C.   PHOVER   1)               1      Version info for outside
C.   HEPEVT   2)               2      PDG common
C.   PH_HEPEVT2)               8      PDG common internal
C.   PHOEVT   2) 3)           10      PDG branch
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
      IMPLICIT NONE
      INTEGER INIT,IDUM,IPHQRK,IPHEKL
**M.S.     SAVE INIT
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
C--   all the following parameter setters can be called after PHOINI.   
C--   Initialization of kinematic correction against rounding errors.
C--   The set values will be used later if called wit zero.
C--   Default parameter is 1 (no correction) optionally 2, 3, 4
      CALL PHCORK(1)
C--   blocks emission from quarks if parameter is 1 (enables if 2), 
C--   physical treatment
C--   will be 3, option 2 is not realistic and for tests only, 
      IDUM= IPHQRK(1)   ! default is 1
C--   blocks emission in  pi0 to gamma e+ e- if parameter is 1 
C--   (enables if 2)
      IDUM= IPHEKL(1)   ! default is 1 

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
      IMPLICIT NONE
      INTEGER d_h_NMXHEP

      PARAMETER (d_h_NMXHEP=2000)

      LOGICAL QEDRAD
      COMMON/PHOQED/QEDRAD(d_h_NMXHEP)
      INTEGER PHLUN
      COMMON/PHOLUN/PHLUN
      REAL(16) ALPHA,XPHCUT
      COMMON/PHOCOP/ALPHA,XPHCUT
      REAL(16) PI,TWOPI
      COMMON/PHPICO/PI,TWOPI
      INTEGER ISEED,I97,J97
      REAL(16) URAN,CRAN,CDRAN,CMRAN
      COMMON/PHSEED/ISEED(2),I97,J97,URAN(97),CRAN,CDRAN,CMRAN
      INTEGER PHOMES
      PARAMETER (PHOMES=10)
      INTEGER STATUS
      COMMON/PHOSTA/STATUS(PHOMES)
      LOGICAL INTERF,ISEC,IFTOP
      REAL(16) FINT,FSEC
      COMMON /PHOKEY/ FSEC,FINT,INTERF,ISEC,IFTOP
      INTEGER INIT,I
**M.S.     SAVE INIT
      DATA INIT/ 0/
C--
C--   Return if already initialized...
      IF (INIT.NE.0) RETURN
      INIT=1
C--
C--   Preset switch  for  photon emission to 'TRUE' for each particle in
C--   /PH_HEPEVT/, this interface is needed for KORALB and KORALZ...
      DO 10 I=1,d_h_NMXHEP
   10 QEDRAD(I)=.TRUE.
C--
C--   Logical output unit for printing of PHOTOS error messages
      PHLUN=6
C--
C--   Set cut parameter for photon radiation
      XPHCUT=0.01q0
C--
C--   Define some constants
      ALPHA=0.00729735039q0
      PI=3.14159265358979324q0
      TWOPI=6.28318530717958648q0
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
C--   best choice is if FINT=2**N where N+1 is maximal number 
C--   of charged daughters
C--   see report on overweihted events
        FINT=2.0q0
      ELSE
        FINT=1.0q0
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
      IMPLICIT NONE
      INTEGER IV1,IV2,IV3
      INTEGER PHOVN1,PHOVN2
      COMMON/PHOVER/PHOVN1,PHOVN2
      INTEGER PHLUN
      COMMON/PHOLUN/PHLUN
      LOGICAL INTERF,ISEC,IFTOP
      REAL(16) FINT,FSEC
      COMMON /PHOKEY/ FSEC,FINT,INTERF,ISEC,IFTOP
      REAL(16) ALPHA,XPHCUT
      COMMON/PHOCOP/ALPHA,XPHCUT
C--
C--   PHOTOS version number and release date
      PHOVN1=203
      PHOVN2=111200
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
      WRITE(PHLUN,9080)
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
 9070 FORMAT(1H ,'*',9X,
     &'Monte Carlo Program - by E. Barberio, B. van Eijk and Z. Was',
     & T81,'*',/,
     &     1H ,'*',9X,'From version 2.0q on - by E.B. and Z.W.',T81,'*')
 9080 FORMAT( 1H ,'*',9X,' ',T81,'*',/,
     &  1H ,'*',9X,
     & ' WARNING (1): /HEPEVT/ is not anymore the standard common block'
     & ,T81,'*',/,
     &  1H ,'*',9X,' ',T81,'*',/,
     &  1H ,'*',9X,
     &'PHOTOS expects /HEPEVT/ to have REAL(16) variables. To change to'
     &,T81,'*',/,  1H ,'*',9X,
     & 'REAL(16) modify its declaration in subr. PHOTOS_GET PHOTOS_SET:'
     & ,T81,'*',/,  1H ,'*',9X,
     & '      REAL(16)  d_h_phep,  d_h_vhep'
     & ,T81,'*',/,  1H ,'*',9X,
     & ' WARNING (2): check dims. of /hepevt/ /phoqed/ /ph_hepevt/.'
     & ,T81,'*',/,  1H ,'*',9X,
     & ' HERE:                     d_h_nmxhep=2000  and  NMXHEP=10000'
     & ,T81,'*')
      END
      SUBROUTINE PHOTOS(ID)
      IMPLICIT NONE 
      INTEGER ID
C.----------------------------------------------------------------------
C.
C.    PHOTOS:  General search routine + _GET + _SET
C.
C.    Purpose:  /HEPEVT/ is not anymore a standard at least 
C.              REAL(16) REAL(16) are in use. PHOTOS_GET and PHOTOS_SET
C.              were to be introduced.
C.              
C.
C.    Input Parameters:   ID see routine PPHOTOS_MAKE
C.
C.    Output Parameters:  None
C.
C.    Author(s):  Z. Was                          Created at:  21/07/98
C.                                                Last Update: 21/07/98
C.
C.----------------------------------------------------------------------
      CALL PHOTOS_GET
      CALL PHOTOS_MAKE(ID)
      CALL PHOTOS_SET
      END

      SUBROUTINE  PHOTOS_GET
C.----------------------------------------------------------------------
C.
C.    Getter for PHOTOS:   
C.
C.    Purpose:  Copies /HEPEVT/ into /PH_HEPEVT/
C.              
C.
C.    Input Parameters:   None
C.
C.    Output Parameters:  None
C.
C.    Author(s):  Z. Was                          Created at:  21/07/98
C.                                                Last Update: 21/07/98
C.
C.----------------------------------------------------------------------

      IMPLICIT NONE
      INTEGER  d_h_nmxhep         ! maximum number of particles

      PARAMETER (d_h_NMXHEP=2000)
      REAL  d_h_phep,  d_h_vhep ! to be real*4/ *8  depending on host
      INTEGER d_h_nevhep,d_h_nhep,d_h_isthep,d_h_idhep,d_h_jmohep,
     $        d_h_jdahep
      COMMON /hepevt/

     $      d_h_nevhep,               ! serial number
     $      d_h_nhep,                 ! number of particles
     $      d_h_isthep(d_h_nmxhep),   ! status code
     $      d_h_idhep(d_h_nmxhep),    ! particle ident KF
     $      d_h_jmohep(2,d_h_nmxhep), ! parent particles
     $      d_h_jdahep(2,d_h_nmxhep), ! childreen particles
     $      d_h_phep(5,d_h_nmxhep),   ! four-momentum, mass [GeV]
     $      d_h_vhep(4,d_h_nmxhep)    ! vertex [mm]
* ----------------------------------------------------------------------
      LOGICAL d_h_qedrad
      COMMON /phoqed/ 
     $     d_h_qedrad(d_h_nmxhep)    ! Photos flag
      INTEGER NMXHEP
      PARAMETER (NMXHEP=10000)
      INTEGER IDHEP,ISTHEP,JDAHEP,JMOHEP,NEVHEP,NHEP
      REAL(16) PHEP,VHEP
      COMMON/PH_HEPEVT/PHEP(5,NMXHEP),VHEP(4,NMXHEP),NEVHEP,NHEP,
     & ISTHEP(NMXHEP),IDHEP(NMXHEP),JMOHEP(2,NMXHEP),JDAHEP(2,NMXHEP)
      LOGICAL QEDRAD
      COMMON/PH_PHOQED/QEDRAD(NMXHEP)
      integer k,l
         nevhep=  d_h_nevhep             ! serial number
         nhep  =  d_h_nhep               ! number of particles
         DO K=1,nhep
           isthep(k)    =d_h_isthep(k)   ! status code
           idhep(k)     =d_h_idhep(k)    ! particle ident KF
           jmohep(1,k)  =d_h_jmohep(1,k) ! parent particles
           jdahep(1,k)  =d_h_jdahep(1,k) ! childreen particles
           jmohep(2,k)  =d_h_jmohep(2,k) ! parent particles
           jdahep(2,k)  =d_h_jdahep(2,k) ! childreen particles
           DO l=1,4
           phep(l,k)    =d_h_phep(l,k)   ! four-momentum, mass [GeV]
           vhep(l,k)    =d_h_vhep(l,k)   ! vertex [mm]
           ENDDO
           phep(5,k)    =d_h_phep(5,k)   ! four-momentum, mass [GeV]
           qedrad(k)    =d_h_qedrad(k)   ! Photos special flag
         ENDDO
      END


      SUBROUTINE PHOTOS_SET
C.----------------------------------------------------------------------
C.
C.    Setter for PHOTOS:   
C.
C.    Purpose:  Copies /PH_HEPEVT/ into /HEPEVT/
C.              
C.
C.    Input Parameters:   None
C.
C.    Output Parameters:  None
C.
C.    Author(s):  Z. Was                          Created at:  21/07/98
C.                                                Last Update: 21/07/98
C.
C.----------------------------------------------------------------------
      IMPLICIT NONE
      INTEGER  d_h_nmxhep         ! maximum number of particles

      PARAMETER (d_h_NMXHEP=2000)
      REAL  d_h_phep,  d_h_vhep ! to be real*4/ *8  depending on host
      INTEGER d_h_nevhep,d_h_nhep,d_h_isthep,d_h_idhep,d_h_jmohep,
     $        d_h_jdahep
      COMMON /hepevt/

     $      d_h_nevhep,               ! serial number
     $      d_h_nhep,                 ! number of particles
     $      d_h_isthep(d_h_nmxhep),   ! status code
     $      d_h_idhep(d_h_nmxhep),    ! particle ident KF
     $      d_h_jmohep(2,d_h_nmxhep), ! parent particles
     $      d_h_jdahep(2,d_h_nmxhep), ! childreen particles
     $      d_h_phep(5,d_h_nmxhep),   ! four-momentum, mass [GeV]
     $      d_h_vhep(4,d_h_nmxhep)    ! vertex [mm]
* ----------------------------------------------------------------------
      LOGICAL d_h_qedrad
      COMMON /phoqed/ 
     $     d_h_qedrad(d_h_nmxhep)    ! Photos flag
      INTEGER NMXHEP
      PARAMETER (NMXHEP=10000)
      INTEGER IDHEP,ISTHEP,JDAHEP,JMOHEP,NEVHEP,NHEP
      REAL(16) PHEP,VHEP
      COMMON/PH_HEPEVT/PHEP(5,NMXHEP),VHEP(4,NMXHEP),NEVHEP,NHEP,
     & ISTHEP(NMXHEP),IDHEP(NMXHEP),JMOHEP(2,NMXHEP),JDAHEP(2,NMXHEP)
      LOGICAL QEDRAD
      COMMON/PH_PHOQED/QEDRAD(NMXHEP)
      INTEGER K,L

         d_h_nevhep=  nevhep             ! serial number
         d_h_nhep  =  nhep               ! number of particles
         DO K=1,nhep
           d_h_isthep(k)    =isthep(k)   ! status code
           d_h_idhep(k)     =idhep(k)    ! particle ident KF
           d_h_jmohep(1,k)  =jmohep(1,k) ! parent particles
           d_h_jdahep(1,k)  =jdahep(1,k) ! childreen particles
           d_h_jmohep(2,k)  =jmohep(2,k) ! parent particles
           d_h_jdahep(2,k)  =jdahep(2,k) ! childreen particles
           DO l=1,4
           d_h_phep(l,k)    =phep(l,k)   ! four-momentum, mass [GeV]
           d_h_vhep(l,k)    =vhep(l,k)   ! vertex [mm]
           ENDDO
           d_h_phep(5,k)    =phep(5,k)   ! four-momentum, mass [GeV]
           d_h_qedrad(k)    =qedrad(k)   ! Photos special flag
         ENDDO
      END
      SUBROUTINE PHOTOS_MAKE(IPARR)
C.----------------------------------------------------------------------
C.
C.    PHOTOS_MAKE:   General search routine
C.
C.    Purpose:  Search through the /PH_HEPEVT/ standard HEP common, sta-
C.              rting from  the IPPAR-th  particle.  Whenevr  branching 
C.              point is found routine PHTYPE(IP) is called.
C.              Finally if calls on PHTYPE(IP) modified entries, common
C               /PH_HEPEVT/ is ordered.
C.
C.    Input Parameter:    IPPAR:  Pointer   to   decaying  particle  in
C.                                /PH_HEPEVT/ and the common itself,
C.
C.    Output Parameters:  Common  /PH_HEPEVT/, either with or without 
C.                                new particles added.
C.
C.    Author(s):  Z. Was, B. van Eijk             Created at:  26/11/89
C.                                                Last Update: 30/08/93
C.
C.----------------------------------------------------------------------
      IMPLICIT NONE
      REAL(16) PHOTON(5)
      INTEGER IP,IPARR,IPPAR,I,J,K,L,NLAST
      REAL(16) DATA
      INTEGER MOTHER,POSPHO
      LOGICAL CASCAD
      INTEGER NMXHEP
      PARAMETER (NMXHEP=10000)
      INTEGER IDHEP,ISTHEP,JDAHEP,JMOHEP,NEVHEP,NHEP
      REAL(16) PHEP,VHEP
      COMMON/PH_HEPEVT/PHEP(5,NMXHEP),VHEP(4,NMXHEP),NEVHEP,NHEP,
     & ISTHEP(NMXHEP),IDHEP(NMXHEP),JMOHEP(2,NMXHEP),JDAHEP(2,NMXHEP)      
      LOGICAL QEDRAD
      COMMON/PH_PHOQED/QEDRAD(NMXHEP)
      INTEGER NMXPHO
      PARAMETER (NMXPHO=10000)
      INTEGER ISTACK(0:NMXPHO),NUMIT,NTRY,KK,LL,II,NA,FIRST,LAST
      INTEGER FIRSTA,LASTA,IPP,IDA1,IDA2,MOTHER2,IDPHO,ISPHO
      REAL(16) PORIG(5,NMXPHO)
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
C-- let-s search if IPARR does not prevent searching. 
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
C-- let-s do generation
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
C--   rearrange  /PH_HEPEVT/  to get correct order..
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
C--   Order /PH_HEPEVT/
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
C--   Correct pointers assuming most dirty /PH_HEPEVT/...
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
C.                                 ted (/PH_HEPEVT/),
C.                        LAST:    Pointer to last  particle to be boos-
C.                                 ted (/PH_HEPEVT/).
C.
C.    Output Parameters:  Common /PH_HEPEVT/.
C.
C.    Author(s):  B. van Eijk                     Created at:  13/02/90
C.                Z. Was                          Last Update: 16/11/93
C.
C.----------------------------------------------------------------------
      IMPLICIT NONE
      REAL(16) BET1(3),BET2(3),GAM1,GAM2,PB,DATA
      INTEGER I,J,FIRST,LAST,MAXSTA,NSTACK,IP
      PARAMETER (MAXSTA=10000)
      INTEGER STACK(MAXSTA)
      REAL(16) PBOOS1(5),PBOOS2(5)
      INTEGER NMXHEP
      PARAMETER (NMXHEP=10000)
      INTEGER IDHEP,ISTHEP,JDAHEP,JMOHEP,NEVHEP,NHEP
      REAL(16) PHEP,VHEP
      COMMON/PH_HEPEVT/PHEP(5,NMXHEP),VHEP(4,NMXHEP),NEVHEP,NHEP,
     & ISTHEP(NMXHEP),IDHEP(NMXHEP),JMOHEP(2,NMXHEP),JDAHEP(2,NMXHEP)      
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
   30    PHEP(J,I)=PHEP(J,I)+BET1(J)*(PHEP(4,I)+PB/(GAM1+1.q0))
         PHEP(4,I)=GAM1*PHEP(4,I)+PB
C--
C--    ...and boost back to modified parent frame.
         PB=BET2(1)*PHEP(1,I)+BET2(2)*PHEP(2,I)+BET2(3)*PHEP(3,I)
         DO 40 J=1,3
   40    PHEP(J,I)=PHEP(J,I)+BET2(J)*(PHEP(4,I)+PB/(GAM2+1.q0))
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
C.    Purpose:  copies IP branch of the common /PH_HEPEVT/ into /PHOEVT/
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
      IMPLICIT NONE
      INTEGER NMXHEP
      PARAMETER (NMXHEP=10000)
      INTEGER IDHEP,ISTHEP,JDAHEP,JMOHEP,NEVHEP,NHEP
      REAL(16) PHEP,VHEP
      COMMON/PH_HEPEVT/PHEP(5,NMXHEP),VHEP(4,NMXHEP),NEVHEP,NHEP,
     & ISTHEP(NMXHEP),IDHEP(NMXHEP),JMOHEP(2,NMXHEP),JDAHEP(2,NMXHEP)      
      INTEGER NMXPHO
      PARAMETER (NMXPHO=10000)
      INTEGER IDPHO,ISTPHO,JDAPHO,JMOPHO,NEVPHO,NPHO
      REAL(16) PPHO,VPHO
      COMMON/PHOEVT/PPHO(5,NMXPHO),VPHO(4,NMXPHO),NEVPHO,NPHO,
     & ISTPHO(NMXPHO),IDPHO(NMXPHO),JMOPHO(2,NMXPHO),JDAPHO(2,NMXPHO)
      INTEGER IP,IP2,I,FIRST,LAST,LL,NA
      LOGICAL BOOST
      INTEGER J,NHEP0
      REAL(16) BET(3),GAM,PB
      COMMON /PHOCMS/ BET,GAM
      LOGICAL INTERF,ISEC,IFTOP
      REAL(16) FINT,FSEC
      COMMON /PHOKEY/ FSEC,FINT,INTERF,ISEC,IFTOP
C--
C let-s calculate size of the little common entry
        FIRST=JDAHEP(1,IP)
        LAST =JDAHEP(2,IP)
        NPHO=3+LAST-FIRST+NHEP-NHEP0
        NEVPHO=NPHO
C let-s take in decaying particle
           IDPHO(1)=IDHEP(IP)
           JDAPHO(1,1)=3
           JDAPHO(2,1)=3+LAST-FIRST
           DO I=1,5
             PPHO(I,1)=PHEP(I,IP)
           ENDDO
C let-s take in eventual second mother
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
             PPHO(I,2)=0.0q0
           ENDDO
         ENDIF
C let-s take in daughters
        DO LL=0,LAST-FIRST
           IDPHO(3+LL)=IDHEP(FIRST+LL)
           JMOPHO(1,3+LL)=JMOHEP(1,FIRST+LL)
           IF (JMOHEP(1,FIRST+LL).EQ.IP) JMOPHO(1,3+LL)=1
           DO I=1,5
             PPHO(I,3+LL)=PHEP(I,FIRST+LL)
           ENDDO
        ENDDO
        IF (NHEP.GT.NHEP0) THEN
C let-s take in illegitimate daughters
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
        CALL PHCORK(0)
C special case of t tbar production process
        IF(IFTOP) CALL PHOTWO(0)
        BOOST=.FALSE.
C--   Check whether parent is in its rest frame...
      IF (     (ABS(PPHO(4,1)-PPHO(5,1)).GT.PPHO(5,1)*1.q-8)
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
   20     PPHO(J,I)=PPHO(J,I)+BET(J)*(PPHO(4,I)+PB/(GAM+1.q0))
   30   PPHO(4,I)=GAM*PPHO(4,I)+PB
C--    Finally boost mother as well
          I=1   
          PB=BET(1)*PPHO(1,I)+BET(2)*PPHO(2,I)+BET(3)*PPHO(3,I)
          DO J=1,3
            PPHO(J,I)=PPHO(J,I)+BET(J)*(PPHO(4,I)+PB/(GAM+1.q0))
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
      IMPLICIT NONE
      INTEGER NMXPHO
      PARAMETER (NMXPHO=10000)
      INTEGER IDPHO,ISTPHO,JDAPHO,JMOPHO,NEVPHO,NPHO
      REAL(16) PPHO,VPHO
      COMMON/PHOEVT/PPHO(5,NMXPHO),VPHO(4,NMXPHO),NEVPHO,NPHO,
     & ISTPHO(NMXPHO),IDPHO(NMXPHO),JMOPHO(2,NMXPHO),JDAPHO(2,NMXPHO)
      REAL(16) BET(3),GAM
      COMMON /PHOCMS/ BET,GAM
      INTEGER I,MODE
      REAL(16) MPASQR
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
       IFRAD=IFRAD.AND.(MPASQR.GT.0.0q0)
       IF(IFRAD) THEN
c.....combining first and second mother
            DO I=1,4
            PPHO(I,1)=PPHO(I,1)+PPHO(I,2)
            ENDDO
            PPHO(5,1)=SQRT(MPASQR)
c.....removing second mother, 
            DO I=1,5
              PPHO(I,2)=0.0q0
            ENDDO
       ENDIF
      ELSE
C boosting of the mothers to the reaction frame not implemented yet.
C to do it in mode 0 original mothers have to be stored in new comon (?)
C and in mode 1 boosted to cms. 
      ENDIF
      END 
      SUBROUTINE PHOOUT(IP,BOOST,NHEP0)
C.----------------------------------------------------------------------
C.
C.    PHOOUT:   PHOtos OUTput
C.
C.    Purpose:  copies back IP branch of the common /PH_HEPEVT/ from 
C.              /PHOEVT/ moves branch back from its CMS system.
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
      IMPLICIT NONE
      INTEGER NMXHEP
      PARAMETER (NMXHEP=10000)
      INTEGER IDHEP,ISTHEP,JDAHEP,JMOHEP,NEVHEP,NHEP
      REAL(16) PHEP,VHEP
      COMMON/PH_HEPEVT/PHEP(5,NMXHEP),VHEP(4,NMXHEP),NEVHEP,NHEP,
     & ISTHEP(NMXHEP),IDHEP(NMXHEP),JMOHEP(2,NMXHEP),JDAHEP(2,NMXHEP)      
      INTEGER NMXPHO
      PARAMETER (NMXPHO=10000)
      INTEGER IDPHO,ISTPHO,JDAPHO,JMOPHO,NEVPHO,NPHO
      REAL(16) PPHO,VPHO
      COMMON/PHOEVT/PPHO(5,NMXPHO),VPHO(4,NMXPHO),NEVPHO,NPHO,
     & ISTPHO(NMXPHO),IDPHO(NMXPHO),JMOPHO(2,NMXPHO),JDAPHO(2,NMXPHO)
      INTEGER IP,LL,FIRST,LAST,I
      LOGICAL BOOST
      INTEGER NN,J,K,NHEP0,NA
      REAL(16) BET(3),GAM,PB
      COMMON /PHOCMS/ BET,GAM
      IF(NPHO.EQ.NEVPHO) RETURN
C--   When parent was not in its rest-frame, boost back...
      CALL PHLUPA(10)
      IF (BOOST) THEN
        DO 110 J=JDAPHO(1,1),JDAPHO(2,1)
          PB=-BET(1)*PPHO(1,J)-BET(2)*PPHO(2,J)-BET(3)*PPHO(3,J)
          DO 100 K=1,3
  100     PPHO(K,J)=PPHO(K,J)-BET(K)*(PPHO(4,J)+PB/(GAM+1.q0))
  110   PPHO(4,J)=GAM*PPHO(4,J)+PB
C--   ...boost photon, or whatever else has shown up
        DO NN=NEVPHO+1,NPHO
          PB=-BET(1)*PPHO(1,NN)-BET(2)*PPHO(2,NN)-BET(3)*PPHO(3,NN)
          DO 120 K=1,3
  120     PPHO(K,NN)=PPHO(K,NN)-BET(K)*(PPHO(4,NN)+PB/(GAM+1.q0))
          PPHO(4,NN)=GAM*PPHO(4,NN)+PB
        ENDDO
      ENDIF
        FIRST=JDAHEP(1,IP)
        LAST =JDAHEP(2,IP)
C let-s take in original daughters
        DO LL=0,LAST-FIRST
         IDHEP(FIRST+LL) = IDPHO(3+LL)
           DO I=1,5
             PHEP(I,FIRST+LL) = PPHO(I,3+LL)
           ENDDO
        ENDDO
C let-s take newcomers to the end of HEPEVT.
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
C.              JFIRST is the position in /PH_HEPEVT/ (!) of the first 
C.              daughter of sub-branch under action.
C.
C.
C.    Author(s):  Z. Was                           Created at: 22/10/92
C.                                                Last Update: 11/12/00
C.
C.----------------------------------------------------------------------
C     ********************
      IMPLICIT NONE
      INTEGER NMXPHO
      PARAMETER (NMXPHO=10000)
      INTEGER IDPHO,ISTPHO,JDAPHO,JMOPHO,NEVPHO,NPHO
      REAL(16) PPHO,VPHO
      COMMON/PHOEVT/PPHO(5,NMXPHO),VPHO(4,NMXPHO),NEVPHO,NPHO,
     & ISTPHO(NMXPHO),IDPHO(NMXPHO),JMOPHO(2,NMXPHO),JDAPHO(2,NMXPHO)
      LOGICAL CHKIF
      COMMON/PHOIF/CHKIF(NMXPHO)
      INTEGER NMXHEP
      PARAMETER (NMXHEP=10000)
      LOGICAL QEDRAD
      COMMON/PH_PHOQED/QEDRAD(NMXHEP)
      INTEGER JFIRST
      LOGICAL F
      INTEGER IDABS,NLAST,I,IPPAR
      LOGICAL INTERF,ISEC,IFTOP,IFNPI0,IFKL
      REAL(16) FINT,FSEC
      COMMON /PHOKEY/ FSEC,FINT,INTERF,ISEC,IFTOP
      LOGICAL IFRAD
      INTEGER IDENT,K,IQRK,IPHQRK,IEKL,IPHEKL
C these are OK .... if you do not like somebody else, add here.
      F(IDABS)=
     &     ( ((IDABS.GT.9.OR.IQRK.NE.1).AND.(IDABS.LE.40)) 
     & .OR.(IDABS.GT.100) )
     & .AND.(IDABS.NE.21)
     $ .AND.(IDABS.NE.2101).AND.(IDABS.NE.3101).AND.(IDABS.NE.3201)
     & .AND.(IDABS.NE.1103).AND.(IDABS.NE.2103).AND.(IDABS.NE.2203)
     & .AND.(IDABS.NE.3103).AND.(IDABS.NE.3203).AND.(IDABS.NE.3303)
C
      IQRK=IPHQRK(0) ! switch for emission from quark
      IEKL=IPHEKL(0)
      NLAST = NPHO
C
      IPPAR=1
C checking for good particles
      IFNPI0=.TRUE.
      IF (IEKL.GT.1) THEN ! exclude radiative corr in decay of pi0 
C                         ! and Kl --> ee gamma
        IFNPI0= (IDPHO(1).NE.111) ! pi0
        IFKL  = ((IDPHO(1).EQ.130).AND.  ! Kl --> ee gamma
     $          ((IDPHO(3).EQ.22).OR.(IDPHO(4).EQ.22).OR.
     $           (IDPHO(5).EQ.22)).AND.
     $          ((IDPHO(3).EQ.11).OR.(IDPHO(4).EQ.11).OR.
     $           (IDPHO(5).EQ.11))     )

        IFNPI0=(IFNPI0.AND.(.NOT.IFKL))
      ENDIF
      DO 10 I=IPPAR,NLAST
      IDABS    = ABS(IDPHO(I))
C possibly call on PHZODE is a dead (to be omitted) code. 
      CHKIF(I)= F(IDABS)       .AND.F(ABS(IDPHO(1)))
     &  .AND.   (IDPHO(2).EQ.0)
      IF(I.GT.2) CHKIF(I)=CHKIF(I).AND.QEDRAD(JFIRST+I-IPPAR-2)
     &                            .AND.IFNPI0
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
C.                                 in /PH_HEPEVT/ to be treated.
C.
C.    Output Parameters:  Common /PH_HEPEVT/.
C.
C.    Author(s):  Z. Was                          Created at:  24/05/93
C.                                                Last Update: 01/10/93
C.
C.----------------------------------------------------------------------
      IMPLICIT NONE
      INTEGER NMXHEP
      PARAMETER (NMXHEP=10000)
      INTEGER IDHEP,ISTHEP,JDAHEP,JMOHEP,NEVHEP,NHEP
      REAL(16) PHEP,VHEP
      COMMON/PH_HEPEVT/PHEP(5,NMXHEP),VHEP(4,NMXHEP),NEVHEP,NHEP,
     & ISTHEP(NMXHEP),IDHEP(NMXHEP),JMOHEP(2,NMXHEP),JDAHEP(2,NMXHEP)      
      LOGICAL INTERF,ISEC,IFTOP
      REAL(16) FINT,FSEC
      COMMON /PHOKEY/ FSEC,FINT,INTERF,ISEC,IFTOP
      INTEGER ID,NHEP0
      LOGICAL IPAIR
      REAL(16) RN,PHORAN
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
        FSEC=1.0q0
        RN=PHORAN(WTDUM)
        IF (RN.GE.0.5q0) THEN
          CALL PHOMAK(ID,NHEP0)
          CALL PHOMAK(ID,NHEP0)
        ENDIF
      ELSE
C-- single photon emission
        FSEC=1.0q0
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
C.              the  HEP common /PH_HEPEVT/. Example of the use of 
C.              general tools.
C.
C.    Input Parameter:    IPPAR:  Pointer   to   decaying  particle  in
C.                                /PH_HEPEVT/ and the common itself
C.
C.    Output Parameters:  Common  /PH_HEPEVT/, either  with  or  without
C.                                particles added.
C.
C.    Author(s):  Z. Was,                         Created at:  26/05/93
C.                                                Last Update: 
C.
C.----------------------------------------------------------------------
      IMPLICIT NONE
      REAL(16) DATA
      REAL(16) PHORAN
      INTEGER IP,IPPAR,NCHARG
      INTEGER WTDUM,IDUM,NHEP0
      INTEGER NCHARB,NEUDAU
      REAL(16) RN,WT,PHINT
      LOGICAL BOOST
      INTEGER NMXHEP
      PARAMETER (NMXHEP=10000)
      INTEGER IDHEP,ISTHEP,JDAHEP,JMOHEP,NEVHEP,NHEP
      REAL(16) PHEP,VHEP
      COMMON/PH_HEPEVT/PHEP(5,NMXHEP),VHEP(4,NMXHEP),NEVHEP,NHEP,
     & ISTHEP(NMXHEP),IDHEP(NMXHEP),JMOHEP(2,NMXHEP),JDAHEP(2,NMXHEP)      
      LOGICAL INTERF,ISEC,IFTOP
      REAL(16) FINT,FSEC
      COMMON /PHOKEY/ FSEC,FINT,INTERF,ISEC,IFTOP
C--
      IP=IPPAR
      IDUM=1
      NCHARG=0
C--
        CALL PHOIN(IP,BOOST,NHEP0)
        CALL PHOCHK(JDAHEP(1,IP))
        WT=0.0q0
        CALL PHOPRE(1,WT,NEUDAU,NCHARB)
        IF (WT.EQ.0.0q0) RETURN
        RN=PHORAN(WTDUM)
C PHODO is caling PHORAN, thus change of series if it is moved before if
        CALL PHODO(1,NCHARB,NEUDAU)
        IF (INTERF) WT=WT*PHINT(IDUM)/FINT
        DATA=WT 
        IF (WT.GT.1.0q0) CALL PHOERR(3,'WT_INT',DATA)
      IF (RN.LE.WT) THEN 
        CALL PHOOUT(IP,BOOST,NHEP0)
      ENDIF
      RETURN
      END
      FUNCTION PHINT1(IDUM)
C.----------------------------------------------------------------------
C.
C.    PHINT:   PHotos INTerference (Old version kept for tests only.
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
C.                                                Last Update: 15/03/99
C.
C.----------------------------------------------------------------------

      IMPLICIT NONE
      REAL(16) PHINT,phint1
      REAL(16) PHOCHA
      INTEGER IDUM
      INTEGER NMXPHO
      PARAMETER (NMXPHO=10000)
      INTEGER IDPHO,ISTPHO,JDAPHO,JMOPHO,NEVPHO,NPHO
      REAL(16) PPHO,VPHO
      COMMON/PHOEVT/PPHO(5,NMXPHO),VPHO(4,NMXPHO),NEVPHO,NPHO,
     & ISTPHO(NMXPHO),IDPHO(NMXPHO),JMOPHO(2,NMXPHO),JDAPHO(2,NMXPHO)
      REAL(16) MCHSQR,MNESQR
      REAL(16) PNEUTR
      COMMON/PHOMOM/MCHSQR,MNESQR,PNEUTR(5)
      REAL(16) COSTHG,SINTHG
      REAL(16) XPHMAX,XPHOTO
      COMMON/PHOPHS/XPHMAX,XPHOTO,COSTHG,SINTHG
      REAL(16) MPASQR,XX,BETA
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
      IFINT= IFINT.AND.PHOCHA(IDPHO(IDENT)).NE.0
C calculates interference weight contribution
      IF(IFINT) THEN
        MPASQR = PPHO(5,1)**2
        XX=4.q0*MCHSQR/MPASQR*(1.q0-XPHOTO)/(1.q0-XPHOTO+(MCHSQR-MNESQR)
     &     /MPASQR)**2
         BETA=SQRT(1.q0-XX)
         PHINT  = 2q0/(1q0+COSTHG**2*BETA**2)
      ELSE
         PHINT  = 1q0
      ENDIF
       phint1=1
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

      IMPLICIT NONE
      REAL(16) PHINT,phint1
      REAL(16) PHOCHA
      INTEGER IDUM
      INTEGER NMXPHO
      PARAMETER (NMXPHO=10000)
      INTEGER IDPHO,ISTPHO,JDAPHO,JMOPHO,NEVPHO,NPHO
      REAL(16) PPHO,VPHO
      COMMON/PHOEVT/PPHO(5,NMXPHO),VPHO(4,NMXPHO),NEVPHO,NPHO,
     & ISTPHO(NMXPHO),IDPHO(NMXPHO),JMOPHO(2,NMXPHO),JDAPHO(2,NMXPHO)
      REAL(16) MCHSQR,MNESQR
      REAL(16) PNEUTR
      COMMON/PHOMOM/MCHSQR,MNESQR,PNEUTR(5)
      REAL(16) COSTHG,SINTHG
      REAL(16) XPHMAX,XPHOTO
      COMMON/PHOPHS/XPHMAX,XPHOTO,COSTHG,SINTHG
      REAL(16) MPASQR,XX,BETA,PQ1(4),PQ2(4),PPHOT(4)
      REAL(16) SS,PP2,PP,E1,E2,Q1,Q2,COSTHE
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
C check if two body was particle antiparticle (we improve on it !
C      IFINT= IFINT.AND.IDPHO(JDAPHO(1,1)).EQ.-IDPHO(IDENT)
C check if particles were charged
      IFINT= IFINT.AND.abs(PHOCHA(IDPHO(IDENT))).GT.0.01q0
C check if they have both charge
      IFINT= IFINT.AND.
     $       abs(PHOCHA(IDPHO(JDAPHO(1,1)))).gt.0.01q0
C calculates interference weight contribution
      IF(IFINT) THEN
        MPASQR = PPHO(5,1)**2
        XX=4.q0*MCHSQR/MPASQR*(1.q0-XPHOTO)/(1.q0-XPHOTO+(MCHSQR-MNESQR)
     &     /MPASQR)**2
         BETA=SQRT(1.q0-XX)
         PHINT  = 2q0/(1q0+COSTHG**2*BETA**2)
         SS =MPASQR*(1.q0-XPHOTO)
         PP2=((SS-MCHSQR-MNESQR)**2-4*MCHSQR*MNESQR)/SS/4
         PP =SQRT(PP2)
         E1 =SQRT(PP2+MCHSQR)
         E2 =SQRT(PP2+MNESQR)
         PHINT= (E1+E2)**2/((E2+COSTHG*PP)**2+(E1-COSTHG*PP)**2)
C
      q1=PHOCHA(IDPHO(JDAPHO(1,1)))
      q2=PHOCHA(IDPHO(IDENT))
      do k=1,4
       pq1(k)=ppho(k,JDAPHO(1,1))
       pq2(k)=ppho(k,JDAPHO(1,1)+1)
       pphot(k)=ppho(k,npho)
      enddo
       costhe=(pphot(1)*pq1(1)+pphot(2)*pq1(2)+pphot(3)*pq1(3))
       costhe=costhe/sqrt(pq1(1)**2+pq1(2)**2+pq1(3)**2)
       costhe=costhe/sqrt(pphot(1)**2+pphot(2)**2+pphot(3)**2)
C
! --- this IF checks whether JDAPHO(1,1) was MCH or MNE. 
! --- COSTHG angle (and in-generation variables) may be better choice 
! --- than costhe. note that in the formulae below amplitudes were 
! --- multiplied by (E2+COSTHG*PP)*(E1-COSTHG*PP). 
        IF (costhg*costhe.GT.0) then

         PHINT= (q1*(E2+COSTHG*PP)-q2*(E1-COSTHG*PP))**2
     &         /(q1**2*(E2+COSTHG*PP)**2+q2**2*(E1-COSTHG*PP)**2)
        ELSE

         PHINT= (q1*(E1-COSTHG*PP)-q2*(E2+COSTHG*PP))**2
     &         /(q1**2*(E1-COSTHG*PP)**2+q2**2*(E2+COSTHG*PP)**2)
        ENDIF
      ELSE
         PHINT  = 1q0
      ENDIF
         phint1=1
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
      IMPLICIT NONE
      REAL(16) MINMAS,MPASQR,MCHREN
      REAL(16) BETA,EPS,DEL1,DEL2,DATA
      REAL(16) PHOCHA,PHOSPI,PHORAN,PHOCOR,MASSUM
      INTEGER IP,IPARR,IPPAR,I,J,ME,NCHARG,NEUPOI,NLAST,THEDUM
      INTEGER IDABS,IDUM
      INTEGER NCHARB,NEUDAU
      REAL(16) WT
      INTEGER NMXPHO
      PARAMETER (NMXPHO=10000)
      INTEGER IDPHO,ISTPHO,JDAPHO,JMOPHO,NEVPHO,NPHO
      REAL(16) PPHO,VPHO
      COMMON/PHOEVT/PPHO(5,NMXPHO),VPHO(4,NMXPHO),NEVPHO,NPHO,
     & ISTPHO(NMXPHO),IDPHO(NMXPHO),JMOPHO(2,NMXPHO),JDAPHO(2,NMXPHO)
      LOGICAL CHKIF
      COMMON/PHOIF/CHKIF(NMXPHO)
      INTEGER CHAPOI(NMXPHO)
      REAL(16) MCHSQR,MNESQR
      REAL(16) PNEUTR
      COMMON/PHOMOM/MCHSQR,MNESQR,PNEUTR(5)
      REAL(16) COSTHG,SINTHG
      REAL(16) XPHMAX,XPHOTO
      COMMON/PHOPHS/XPHMAX,XPHOTO,COSTHG,SINTHG
      REAL(16) ALPHA,XPHCUT
      COMMON/PHOCOP/ALPHA,XPHCUT
      INTEGER IREP
      REAL(16) PROBH,CORWT,XF
      COMMON/PHOPRO/PROBH,CORWT,XF,IREP
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
      MINMAS=0.q0
      MASSUM=0.q0
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
        IF ((PPHO(5,IP)-MASSUM)/PPHO(5,IP).GT.2.q0*XPHCUT) THEN
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
            EPS=MCHREN/(1.q0+BETA)
C--
C--   Calculate sin(theta) and cos(theta) from interval variables
            DEL1=(2.q0-EPS)*(EPS/(2.q0-EPS))**PHORAN(THEDUM)
            DEL2=2.q0-DEL1
            COSTHG=(1.q0-DEL1)/BETA
            SINTHG=SQRT(DEL1*DEL2-MCHREN)/BETA
C--
C--   Determine spin of  particle and construct code  for matrix element
            ME=2.q0*PHOSPI(IDPHO(CHAPOI(NCHARG)))+1.q0
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
      IMPLICIT NONE
      INTEGER NMXPHO
      PARAMETER (NMXPHO=10000)
      INTEGER IDPHO,ISTPHO,JDAPHO,JMOPHO,NEVPHO,NPHO
      REAL(16) PPHO,VPHO
      COMMON/PHOEVT/PPHO(5,NMXPHO),VPHO(4,NMXPHO),NEVPHO,NPHO,
     & ISTPHO(NMXPHO),IDPHO(NMXPHO),JMOPHO(2,NMXPHO),JDAPHO(2,NMXPHO)
      INTEGER IFIRST,ILAST,I,J,BUFPOI,POINTR(NMXPHO)
      REAL(16) BUFMAS,MASS(NMXPHO)
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
      IMPLICIT NONE
      REAL(16) MPASQR,MCHREN,BIGLOG,BETA,DATA
      INTEGER IWT1,IRN,IWT2
      REAL(16) PRSOFT,PRHARD,PHORAN,PHOFAC
      REAL(16) MCHSQR,MNESQR
      REAL(16) PNEUTR
      INTEGER IDENT
      REAL(16) PHOCHA
      COMMON/PHOMOM/MCHSQR,MNESQR,PNEUTR(5)
      REAL(16) COSTHG,SINTHG
      REAL(16) XPHMAX,XPHOTO
      COMMON/PHOPHS/XPHMAX,XPHOTO,COSTHG,SINTHG
      REAL(16) ALPHA,XPHCUT
      COMMON/PHOCOP/ALPHA,XPHCUT
      REAL(16) PI,TWOPI
      COMMON/PHPICO/PI,TWOPI
      INTEGER IREP
      REAL(16) PROBH,CORWT,XF
      COMMON/PHOPRO/PROBH,CORWT,XF,IREP
      LOGICAL INTERF,ISEC,IFTOP
      REAL(16) FINT,FSEC
      COMMON /PHOKEY/ FSEC,FINT,INTERF,ISEC,IFTOP
C--
      IF (XPHMAX.LE.XPHCUT) THEN
* jvw 20190913 this one line bug fix comes from version 2.09 and should
* solve the "Too much Bremsstrahlung required" stopping problem.
        BETA=PHOFAC(-1)  ! to zero counter, here beta is dummy
*
        XPHOTO=0.0q0
        RETURN
      ENDIF
C--   Probabilities for hard and soft bremstrahlung...
      MCHREN=4.q0*MCHSQR/MPASQR/(1.q0+MCHSQR/MPASQR)**2
      BETA=SQRT(1.q0-MCHREN)
      BIGLOG=LOG(MPASQR/MCHSQR*(1.q0+BETA)**2/4.q0*
     &     (1.q0+MCHSQR/MPASQR)**2)
      PRHARD=ALPHA/PI/BETA*BIGLOG*(LOG(XPHMAX/XPHCUT)-.75q0+XPHCUT/
     &XPHMAX-.25q0*XPHCUT**2/XPHMAX**2)
      PRHARD=PRHARD*PHOCHA(IDENT)**2*FINT*FSEC
      IF (IREP.EQ.0) PROBH=0.q0
      PRHARD=PRHARD*PHOFAC(0)
      PROBH=PRHARD
      PRSOFT=1.q0-PRHARD
C--   
C--   Check on kinematical bounds
      IF (PRSOFT.LT.0.1q0) THEN
        DATA=PRSOFT
        CALL PHOERR(2,'PHOENE',DATA)
      ENDIF
      IF (PHORAN(IWT1).LT.PRSOFT) THEN
C--
C--   No photon... (ie. photon too soft)
        XPHOTO=0.q0
      ELSE
C--
C--   Hard  photon... (ie.  photon  hard enough).
C--   Calculate  Altarelli-Parisi Kernel
   10   XPHOTO=EXP(PHORAN(IRN)*LOG(XPHCUT/XPHMAX))
        XPHOTO=XPHOTO*XPHMAX
        IF (PHORAN(IWT2).GT.((1.q0+(1.q0-XPHOTO/XPHMAX)**2)/2.q0)) 
     &                            GOTO 10
      ENDIF
C--
C--   Calculate parameter for PHOFAC function
      XF=4.q0*MCHSQR*MPASQR/(MPASQR+MCHSQR-MNESQR)**2
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
      IMPLICIT NONE
      REAL(16) MPASQR,MCHREN,BETA,XX,YY,DATA
      INTEGER ME
      REAL(16) PHOCOR,PHOFAC,WT1,WT2,WT3
      REAL(16) MCHSQR,MNESQR
      REAL(16) PNEUTR
      COMMON/PHOMOM/MCHSQR,MNESQR,PNEUTR(5)
      REAL(16) COSTHG,SINTHG
      REAL(16) XPHMAX,XPHOTO
      COMMON/PHOPHS/XPHMAX,XPHOTO,COSTHG,SINTHG
      INTEGER IREP
      REAL(16) PROBH,CORWT,XF
      COMMON/PHOPRO/PROBH,CORWT,XF,IREP
C--
C--   Shaping (modified by ZW)...
      XX=4.q0*MCHSQR/MPASQR*(1.q0-XPHOTO)/(1.q0-XPHOTO+(MCHSQR-MNESQR)/
     &MPASQR)**2
      IF (ME.EQ.1) THEN
        YY=1.q0
        WT3=(1.q0-XPHOTO/XPHMAX)/((1.q0+(1.q0-XPHOTO/XPHMAX)**2)/2.q0)
      ELSEIF (ME.EQ.2) THEN
        YY=0.5q0*(1.q0-XPHOTO/XPHMAX+1.q0/(1.q0-XPHOTO/XPHMAX))
        WT3=1.q0
      ELSEIF ((ME.EQ.3).OR.(ME.EQ.4).OR.(ME.EQ.5)) THEN
        YY=1.q0
        WT3=(1.q0+(1.q0-XPHOTO/XPHMAX)**2-(XPHOTO/XPHMAX)**3)/
     &  (1.q0+(1.q0-XPHOTO/XPHMAX)** 2)
      ELSE
        DATA=(ME-1.q0)/2.q0
        CALL PHOERR(6,'PHOCOR',DATA)
        YY=1.q0
        WT3=1.q0
      ENDIF
      BETA=SQRT(1.q0-XX)
      WT1=(1.q0-COSTHG*SQRT(1.q0-MCHREN))/(1.q0-COSTHG*BETA)
      WT2=(1.q0-XX/YY/(1.q0-BETA**2*COSTHG**2))*(1.q0+COSTHG*BETA)/2.q0
      WT2=WT2*PHOFAC(1)
      PHOCOR=WT1*WT2*WT3
      CORWT=PHOCOR
      IF (PHOCOR.GT.1.q0) THEN
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
      IMPLICIT NONE
      REAL(16) PHOFAC,FF,PRX
      INTEGER MODE
      INTEGER IREP
      REAL(16) PROBH,CORWT,XF
      COMMON/PHOPRO/PROBH,CORWT,XF,IREP
**M.S.     SAVE PRX,FF
      DATA PRX,FF/ 0.q0, 0.q0/
* jvw bug fix from version 2.09 (enable MODE=-1 option)
      IF   (MODE.EQ.-1) THEN
        PRX=1.q0
        FF=1.q0
        PROBH=0.0q0
*
      ELSEIF (MODE.EQ.0) THEN
        IF (IREP.EQ.0) PRX=1.q0
        PRX=PRX/(1.q0-PROBH)
        FF=1.q0
C--
C--   Following options are not considered for the time being...
C--   (1) Good choice, but does not save very much time:
C--       FF=(1.0D0-SQRT(XF)/2.0D0)/(1.0+SQRT(XF)/2.0D0)
C--   (2) Taken from the blue, but works without weight overflows...
C--       FF=(1.D0-XF/(1-(1-SQRT(XF))**2))*(1+(1-SQRT(XF))/SQRT(1-XF))/2
        PHOFAC=FF*PRX
      ELSE
        PHOFAC=1.q0/FF
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
      IMPLICIT NONE
      REAL(16) PHOAN1,PHOAN2,ANGLE,FI1,FI3,FI4,FI5,TH1,TH3,TH4
      REAL(16) PARNE,QNEW,QOLD,DATA
      INTEGER IP,FI3DUM,I,J,NEUDAU,FIRST,LAST
      INTEGER NCHARB
      REAL(16) EPHOTO,PMAVIR,PHOTRI
      REAL(16) GNEUT,PHORAN,CCOSTH,SSINTH,PVEC(4)
      INTEGER NMXPHO
      PARAMETER (NMXPHO=10000)
      INTEGER IDPHO,ISTPHO,JDAPHO,JMOPHO,NEVPHO,NPHO
      REAL(16) PPHO,VPHO
      COMMON/PHOEVT/PPHO(5,NMXPHO),VPHO(4,NMXPHO),NEVPHO,NPHO,
     & ISTPHO(NMXPHO),IDPHO(NMXPHO),JMOPHO(2,NMXPHO),JDAPHO(2,NMXPHO)
      REAL(16) MCHSQR,MNESQR
      REAL(16) PNEUTR
      COMMON/PHOMOM/MCHSQR,MNESQR,PNEUTR(5)
      REAL(16) COSTHG,SINTHG
      REAL(16) XPHMAX,XPHOTO
      COMMON/PHOPHS/XPHMAX,XPHOTO,COSTHG,SINTHG
      REAL(16) PI,TWOPI
      COMMON/PHPICO/PI,TWOPI
C--
      EPHOTO=XPHOTO*PPHO(5,IP)/2.q0
      PMAVIR=SQRT(PPHO(5,IP)*(PPHO(5,IP)-2.q0*EPHOTO))
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
      IF (GNEUT.LT.1.q0) THEN
        DATA=0.q0
        CALL PHOERR(4,'PHOKIN',DATA)
      ENDIF
      PARNE=GNEUT-SQRT(MAX(GNEUT**2-1.0q0,0.q0))
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
      PPHO(5,NPHO)=0.q0
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
   60   PVEC(I)=0.q0
        PVEC(1)=1.q0
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
      IMPLICIT NONE
      REAL(16) DA,DB,DC,DAPB,DAMB,DTRIAN
      REAL(16) A,B,C,PHOTRI
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
      IMPLICIT NONE
      REAL(16) PHOAN1
      REAL(16) X,Y
      REAL(16) PI,TWOPI
      COMMON/PHPICO/PI,TWOPI
      IF (ABS(Y).LT.ABS(X)) THEN
        PHOAN1=ATAN(ABS(Y/X))
        IF (X.LE.0.q0) PHOAN1=PI-PHOAN1
      ELSE
        PHOAN1=ACOS(X/SQRT(X**2+Y**2))
      ENDIF
      IF (Y.LT.0.q0) PHOAN1=TWOPI-PHOAN1
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
      IMPLICIT NONE
      REAL(16) PHOAN2
      REAL(16) X,Y
      REAL(16) PI,TWOPI
      COMMON/PHPICO/PI,TWOPI
      IF (ABS(Y).LT.ABS(X)) THEN
        PHOAN2=ATAN(ABS(Y/X))
        IF (X.LE.0.q0) PHOAN2=PI-PHOAN2
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
      IMPLICIT NONE
      REAL(16) QPL,QMI,ANGLE
      REAL(16) PVEC(4)
      QPL=(PVEC(4)+PVEC(3))*ANGLE
      QMI=(PVEC(4)-PVEC(3))/ANGLE
      PVEC(3)=(QPL-QMI)/2.q0
      PVEC(4)=(QPL+QMI)/2.q0
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
      IMPLICIT NONE
      REAL(16) CS,SN,ANGLE
      REAL(16) PVEC(4)
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
      IMPLICIT NONE
      REAL(16) CS,SN,ANGLE
      REAL(16) PVEC(4)
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
      IMPLICIT NONE
      REAL(16) DATA
      REAL(16) S,T
      INTEGER I,IS1,IS2,IS3,IS4,IS5,J
      INTEGER ISEED,I97,J97
      REAL(16) URAN,CRAN,CDRAN,CMRAN
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
        S=0.q0
        T=0.5q0
        DO 10 J=1,24
          IS5=MOD (MOD(IS1*IS2,179)*IS3,179)
          IS1=IS2
          IS2=IS3
          IS3=IS5
          IS4=MOD(53*IS4+1,169)
          IF (MOD(IS4*IS5,64).GE.32) S=S+T
   10   T=0.5q0*T
   20 URAN(I)=S
      CRAN=362436.q0/16777216.q0
      CDRAN=7654321.q0/16777216.q0
      CMRAN=16777213.q0/16777216.q0
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
      IMPLICIT NONE
      REAL(16) PHORAN
      INTEGER IDUM
      INTEGER ISEED,I97,J97
      REAL(16) URAN,CRAN,CDRAN,CMRAN
      COMMON/PHSEED/ISEED(2),I97,J97,URAN(97),CRAN,CDRAN,CMRAN
   10 PHORAN=URAN(I97)-URAN(J97)
      IF (PHORAN.LT.0.q0) PHORAN=PHORAN+1.q0
      URAN(I97)=PHORAN
      I97=I97-1
      IF (I97.EQ.0) I97=97
      J97=J97-1
      IF (J97.EQ.0) J97=97
      CRAN=CRAN-CDRAN
      IF (CRAN.LT.0.q0) CRAN=CRAN+CMRAN
      PHORAN=PHORAN-CRAN
      IF (PHORAN.LT.0.q0) PHORAN=PHORAN+1.q0
      IF (PHORAN.LE.0.q0) GOTO 10
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
      IMPLICIT NONE
      REAL(16) PHOCHA
      INTEGER IDHEP,IDABS,Q1,Q2,Q3
C--
C--   Array 'CHARGE' contains the charge  of the first 101 particles ac-
C--   cording  to  the PDG particle code... (0 is added for convenience)
      REAL(16) CHARGE(0:100)
      DATA CHARGE/ 0.q0,
     &-0.3333333333q0,  0.6666666667q0, -0.3333333333q0, 0.6666666667q0,
     &-0.3333333333q0,  0.6666666667q0, -0.3333333333q0, 0.6666666667q0,
     & 2*0.q0, -1.q0, 0.q0, -1.q0, 0.q0, -1.q0, 0.q0, -1.q0, 6*0.q0, 
     & 1.q0, 12*0.q0, 1.q0, 63*0.q0/
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
      IF (IDHEP.LT.0.q0) PHOCHA=-PHOCHA
      IF (PHOCHA**2.lt.1q-6) PHOCHA=0.q0
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
      IMPLICIT NONE
      REAL(16) PHOSPI
      INTEGER IDHEP,IDABS
C--
C--   Array 'SPIN' contains the spin  of  the first 100 particles accor-
C--   ding to the PDG particle code...
      REAL(16) SPIN(100)
      DATA SPIN/ 8*.5q0, 1.q0, 0.q0, 8*.5q0, 2*0.q0, 4*1.q0, 76*0.q0/
      IDABS=ABS(IDHEP)
C--
C--   Spin of quark, lepton, boson etc....
      IF (IDABS.LE.100) THEN
        PHOSPI=SPIN(IDABS)
      ELSE
C--
C--   ...other particles, however...
        PHOSPI=(MOD(IDABS,10)-1.q0)/2.q0
C--
C--   ...K_short and K_long are special !!
        PHOSPI=MAX(PHOSPI,0.q0)
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
      IMPLICIT NONE
      REAL(16) DATA
      INTEGER IMES,IERROR
      REAL(16) SDATA
      INTEGER PHLUN
      COMMON/PHOLUN/PHLUN
      INTEGER PHOMES
      PARAMETER (PHOMES=10)
      INTEGER STATUS
      COMMON/PHOSTA/STATUS(PHOMES)
      CHARACTER TEXT*(*)
**M.S.     SAVE IERROR
C--   security STOP switch  
      LOGICAL ISEC
**M.S.     SAVE ISEC
      DATA ISEC /.TRUE./
      DATA IERROR/ 0/
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
 9030 FORMAT(1H ,'* ',A,': Combined Weight is exceeding 1q0, Weight = ',
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
      IMPLICIT NONE
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
      IMPLICIT NONE 
      REAL(16) SUM
      INTEGER IPOINT,I,IEV,IOUT,J
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
      PARAMETER (NMXPHO=10000)
      INTEGER IDPHO,ISTPHO,JDAPHO,JMOPHO,NEVPHO,NPHO
      REAL(16) PPHO,VPHO
      COMMON/PHOEVT/PPHO(5,NMXPHO),VPHO(4,NMXPHO),NEVPHO,NPHO,
     & ISTPHO(NMXPHO),IDPHO(NMXPHO),JMOPHO(2,NMXPHO),JDAPHO(2,NMXPHO)      
      COMMON /PHNUM/ IEV
      INTEGER PHLUN
      COMMON/PHOLUN/PHLUN
      DIMENSION SUM(5)
      IF (IPOINT.LT.3000) RETURN
      IOUT=56
      IF (IEV.LT.1000) THEN
      DO I=1,5
        SUM(I)=0.0q0
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



      FUNCTION IPHQRK(MODCOR)
      implicit none
C.----------------------------------------------------------------------
C.
C.    IPHQRK: enables blocks emision from quarks
C.            
C
C.    Input Parameters:   MODCOR
C.                        MODCOR >0 type of action
C.                               =1 blocks
C.                               =2 enables
C.                               =0 execution mode (retrns stored value)
C.
C.
C.    Author(s):  Z. Was                          Created at:  11/12/00
C.						  Modified  :  
C.----------------------------------------------------------------------
      INTEGER IPHQRK,MODCOR,MODOP
      INTEGER PHLUN
      COMMON/PHOLUN/PHLUN

**M.S.     SAVE MODOP
      DATA MODOP  /0/
      IF (MODCOR.NE.0) THEN 
C       INITIALIZATION
        MODOP=MODCOR

        WRITE(PHLUN,*) 
     $  'Message from PHOTOS: IPHQRK(MODCOR):: (re)initialization'
        IF     (MODOP.EQ.1) THEN
          WRITE(PHLUN,*) 
     $    'MODOP=1 -- blocks emission from light quarks: DEFAULT' 
        ELSEIF (MODOP.EQ.2) THEN
          WRITE(PHLUN,*) 
     $    'MODOP=2 -- enables emission from light quarks: TEST '
        ELSE
          WRITE(PHLUN,*) 'IPHQRK wrong MODCOR=',MODCOR
          STOP
        ENDIF
        RETURN
      ENDIF

      IF (MODOP.EQ.0.AND.MODCOR.EQ.0) THEN
        WRITE(PHLUN,*) 'IPHQRK lack of initialization'
        STOP
      ENDIF
      IPHQRK=MODOP
      END


      FUNCTION IPHEKL(MODCOR)
      implicit none
C.----------------------------------------------------------------------
C.
C.    IPHEKL: enables/blocks emision in: pi0 to gamma e+ e-
C.            
C
C.    Input Parameters:   MODCOR
C.                        MODCOR >0 type of action
C.                               =1 blocks
C.                               =2 enables
C.                               =0 execution mode (retrns stored value)
C.
C.
C.    Author(s):  Z. Was                          Created at:  11/12/00
C.						  Modified  :  
C.----------------------------------------------------------------------
      INTEGER IPHEKL,MODCOR,MODOP
      INTEGER PHLUN
      COMMON/PHOLUN/PHLUN

**M.S.     SAVE MODOP
      DATA MODOP  /0/

      IF (MODCOR.NE.0) THEN 
C       INITIALIZATION
        MODOP=MODCOR

        WRITE(PHLUN,*) 
     $  'Message from PHOTOS: IPHEKL(MODCOR):: (re)initialization'
        IF     (MODOP.EQ.1) THEN
          WRITE(PHLUN,*) 
     $    'MODOP=1 -- blocks emission in pi0 to gamma e+e-: DEFAULT' 
          WRITE(PHLUN,*) 
     $    'MODOP=1 -- blocks emission in Kl  to gamma e+e-: DEFAULT' 
        ELSEIF (MODOP.EQ.2) THEN
          WRITE(PHLUN,*) 
     $    'MODOP=2 -- enables emission in pi0 to gamma e+e- : TEST '
          WRITE(PHLUN,*) 
     $    'MODOP=2 -- enables emission in Kl  to gamma e+e- : TEST '
        ELSE
          WRITE(PHLUN,*) 'IPHEKL wrong MODCOR=',MODCOR
          STOP
        ENDIF
        RETURN
      ENDIF

      IF (MODOP.EQ.0.AND.MODCOR.EQ.0) THEN
        WRITE(PHLUN,*) 'IPHELK lack of initialization'
        STOP
      ENDIF
      IPHEKL=MODOP
      END

      SUBROUTINE PHCORK(MODCOR)
      implicit none
C.----------------------------------------------------------------------
C.
C.    PHCORK: corrects kinmatics of subbranch needed if host program
C.            produces events with the shaky momentum conservation
C
C.    Input Parameters:   Common /PHOEVT/, MODCOR
C.                        MODCOR >0 type of action
C.                               =1 no action
C.                               =2 corrects energy from mass
C.                               =3 corrects mass from energy
C.                               =4 corrects energy from mass for 
C.                                  particles up to .4 GeV mass, 
C.                                  for heavier ones corrects mass,
C.                               =0 execution mode 
C.
C.    Output Parameters:  corrected /PHOEVT/
C.
C.    Author(s):  P.Golonka, Z. Was               Created at:  01/02/99
C.						  Modified  :  08/02/99
C.----------------------------------------------------------------------
      INTEGER NMXPHO
      PARAMETER (NMXPHO=10000)
      
      REAL(16) M,P2,PX,PY,PZ,E,EN,MCUT
      INTEGER MODCOR,MODOP,I,IEV,IPRINT
      INTEGER IDPHO,ISTPHO,JDAPHO,JMOPHO,NEVPHO,NPHO
      REAL(16) PPHO,VPHO
      COMMON/PHOEVT/PPHO(5,NMXPHO),VPHO(4,NMXPHO),NEVPHO,NPHO,
     & ISTPHO(NMXPHO),IDPHO(NMXPHO),JMOPHO(2,NMXPHO),JDAPHO(2,NMXPHO)      

      INTEGER PHLUN
      COMMON/PHOLUN/PHLUN

      COMMON /PHNUM/ IEV
**M.S.     SAVE MODOP
      DATA MODOP  /0/
**M.S.     SAVE IPRINT
      DATA IPRINT /0/
**M.S.     SAVE MCUT
      IF (MODCOR.NE.0) THEN 
C       INITIALIZATION
        MODOP=MODCOR

        WRITE(PHLUN,*) 'Message from PHCORK(MODCOR):: initialization'
        IF     (MODOP.EQ.1) THEN
          WRITE(PHLUN,*) 'MODOP=1 -- no corrections on event: DEFAULT' 
        ELSEIF (MODOP.EQ.2) THEN
          WRITE(PHLUN,*) 'MODOP=2 -- corrects Energy from mass'
        ELSEIF (MODOP.EQ.3) THEN
          WRITE(PHLUN,*) 'MODOP=3 -- corrects mass from Energy'
        ELSEIF (MODOP.EQ.4) THEN
          WRITE(PHLUN,*) 'MODOP=4 -- corrects Energy from mass to Mcut'
          WRITE(PHLUN,*) '           and mass from  energy above  Mcut '
          MCUT=0.4q0
          WRITE(PHLUN,*) 'Mcut=',MCUT,'GeV'
        ELSE
          WRITE(PHLUN,*) 'PHCORK wrong MODCOR=',MODCOR
          STOP
        ENDIF
        RETURN
      ENDIF

      IF (MODOP.EQ.0.AND.MODCOR.EQ.0) THEN
        WRITE(PHLUN,*) 'PHCORK lack of initialization'
        STOP
      ENDIF

C execution mode
C ==============
C ============== 

     
        PX=0
        PY=0
        PZ=0
        E =0

      IF    (MODOP.EQ.1) THEN
C     -----------------------
C       In this case we do nothing
        RETURN
      ELSEIF(MODOP.EQ.2) THEN
C     -----------------------
CC      lets loop thru all daughters and correct their energies 
CC      according to E^2=p^2+m^2

       DO I=3,NPHO
         
         PX=PX+PPHO(1,I)
         PY=PY+PPHO(2,I)
         PZ=PZ+PPHO(3,I)

         P2=PPHO(1,I)**2+PPHO(2,I)**2+PPHO(3,I)**2

         EN=SQRT( PPHO(5,I)**2 + P2)
         
         IF (IPRINT.EQ.1)
     &   WRITE(PHLUN,*) "CORRECTING ENERGY OF ",I,":",
     &        PPHO(4,I),"=>",EN

         PPHO(4,I)=EN
         E = E+PPHO(4,I)

       ENDDO
      
      ELSEIF(MODOP.EQ.3) THEN
C     -----------------------

CC      lets loop thru all daughters and correct their masses 
CC      according to E^2=p^2+m^2

       DO I=3,NPHO
         
         PX=PX+PPHO(1,I)
         PY=PY+PPHO(2,I)
         PZ=PZ+PPHO(3,I)
         E = E+PPHO(4,I)

         P2=PPHO(1,I)**2+PPHO(2,I)**2+PPHO(3,I)**2

         M=SQRT(ABS( PPHO(4,I)**2 - P2))

         IF (IPRINT.EQ.1)
     &   WRITE(PHLUN,*) "CORRECTING MASS OF ",I,":",
     &        PPHO(5,I),"=>",M

         PPHO(5,I)=M

       ENDDO
      

      ELSEIF(MODOP.EQ.4) THEN
C     -----------------------
            
CC      lets loop thru all daughters and correct their masses 
CC      or energies according to E^2=p^2+m^2

       DO I=3,NPHO
         
         PX=PX+PPHO(1,I)
         PY=PY+PPHO(2,I)
         PZ=PZ+PPHO(3,I)

         P2=PPHO(1,I)**2+PPHO(2,I)**2+PPHO(3,I)**2

         M=SQRT(ABS( PPHO(4,I)**2 - P2))

         IF (M.GT.MCUT) THEN
          IF (IPRINT.EQ.1)
     &    WRITE(PHLUN,*) "CORRECTING MASS OF ",I,":",
     &         PPHO(5,I),"=>",M
          PPHO(5,I)=M
          E = E+PPHO(4,I)
         ELSE

          EN=SQRT( PPHO(5,I)**2 + P2)

         IF (IPRINT.EQ.1)
     &    WRITE(PHLUN,*) "CORRECTING ENERGY OF ",I,":",
     &        PPHO(4,I),"=>",EN

          PPHO(4,I)=EN
          E = E+PPHO(4,I)
         ENDIF

       ENDDO
      ENDIF
C     -----

       IF (IPRINT.EQ.1) THEN
        WRITE(PHLUN,*) "CORRECTING MOTHER"
        WRITE(PHLUN,*) "PX:",PPHO(1,1),"=>",PX-PPHO(1,2)
        WRITE(PHLUN,*) "PY:",PPHO(2,1),"=>",PY-PPHO(2,2)
        WRITE(PHLUN,*) "PZ:",PPHO(3,1),"=>",PZ-PPHO(3,2)
        WRITE(PHLUN,*) " E:",PPHO(4,1),"=>",E-PPHO(4,2)
       ENDIF

       PPHO(1,1)=PX-PPHO(1,2)
       PPHO(2,1)=PY-PPHO(2,2)
       PPHO(3,1)=PZ-PPHO(3,2)
       PPHO(4,1)=E -PPHO(4,2)

       P2=PPHO(1,1)**2+PPHO(2,1)**2+PPHO(3,1)**2

       IF (PPHO(4,1)**2.GT.P2) THEN
          M=SQRT( PPHO(4,1)**2 - P2 )
          IF (IPRINT.EQ.1)
     &    WRITE(PHLUN,*) " M:",PPHO(5,1),"=>",M
          PPHO(5,1)=M
       ENDIF

      CALL PHLUPA(25)

      END





