C--------------------------------------------------
C    Aleph modifications - B.Bloch January 2001
C  1- common /bos/ changed to /boson/
C  2- create a function DIZETVER(dum) to return the version number
C  3- all include replaced by code
C--------------------------------------------------
*/////////////////////////////////////////////////////////////////////////////////////////
*//                                                                                     //
*//                     Pseudo-CLASS  DZface                                            //
*//   BornV.h  header is included in all routines                                       //
*//   (Some kind of 'inheritance' from class BornV class)                               //
*//   Initialization of BornV class is not necessary, however.                          //
*//                                                                                     //
*//   Purpose: Calculates Electroweak formfactor from Dizet                             //
*//            Writes the on the disk                                                   //
*//                                                                                     //
*//  General philosophy is that DZface is not linked with the MC like other classes     //
*//  but produces look-up tables on the disk which are read by BornV class.             //
*//  The tables can be produced using TabMain program which is run separately for       //
*//  each flavor, producing one table per flavour.                                      //
*//  In such a case there is no worry whether EW  library can be reinitialized          //
*//  properly (although Dizet apparently can reinitialize propoerly).                   //
*//  There is special testing program TabCheck in BornV/tabtest/ which tests            //
*//  whether interpolation is done correctly.                                           //
*//  Present version is for sub-permille precision.                                     //
*//  there is only one misteriuos discontinutity at W=40GeV of order 1%, to be checked. //
*//                                                                                     //
*// Notes:                                                                              //
*//  cyy(i+1,5 )=123.456 not used                                                       //
*//  ibox = 1 for all energies??? requires costheta in tables!                          //
*//  Is QCDcor smaller for b-quark then for other quarks??                              //
*//  remember to check signs of s,t,u of rokanc!!!                                      //
*//                                                                                     //
*/////////////////////////////////////////////////////////////////////////////////////////
      SUBROUTINE DZface_Initialize( KFfin, xpar)
*/////////////////////////////////////////////////////////////////////////////////////////
*//                                                                                     //
*//     Class initializator                                                             //
*//  Interface to DIZET of the Dubna-Zeuthen EWRC group                                 //
*//  Based on that in KORALZ 4.x                                                        //
*//  Notes:                                                                             //
*//    QED alfinv is separate from alfinv used bremsstrahlung part of KK2f.             //
*//    Note that fermion masses in Dizet are isolated from these in KK2f.               //
*//                                                                                     //
*/////////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
C      INCLUDE '../bornv/BornV.h'
*//////////////////////////////////////////////////////////////////////////////
*//                                                                          //
*//                     Pseudo-CLASS  BornV                                  //
*//                                                                          //
*//  Purpose:                                                                //
*//  Provide Born angular distribution and integrated x-section              //
*//  as a function of s.                                                     //
*//                                                                          //
*//  NOTES:                                                                  //
*//  How to eliminate nneut? This will come in a natural way                 //
*//  when neutrino type is generated.                                        //
*//  NB. Zbyszek says that weight dispersion might worsen!                   //
*//                                                                          //
*//////////////////////////////////////////////////////////////////////////////
*
*  Class members:
*
*//////////////////////////////////////////////////////////////////////////////
      DOUBLE PRECISION   m_pi
      PARAMETER         (m_pi =3.1415926535897932d0)
      DOUBLE PRECISION   m_fleps
****  PARAMETER (m_fleps = 1d-35)  ! original
****  PARAMETER (m_fleps = 1d-45)  ! enough???
      PARAMETER (m_fleps = 1d-100)  ! enough!!!
****      PARAMETER (m_fleps = 1d-200)  ! enough!!!
*//////////////////////////////////////////////////////////////////////////////
*//       Energy limits in the EW grid, w=sqrt(s) in GeV units.              //
*//////////////////////////////////////////////////////////////////////////////
*     340-point grid, only 80pt for NLC to be improved/tested in future
      INTEGER           m_poin1, m_poin2, m_poin3, m_poin4, m_poinG , m_poinQ !
      INTEGER           m_poTh1, m_poTh2, m_poTh3, m_poTh4
      PARAMETER(        m_poinG =   7 )                      ! No of EW formfactors
      PARAMETER(        m_poinQ =   4 )                      ! No of QCD corrections
*----------- Low energies and LEP1
      PARAMETER(        m_poin1 = 120 )                              ! LEP1 basic range sqrt(s)    spacing
cc      PARAMETER(        m_poin1 = 96 )                              ! LEP1 basic range sqrt(s)    spacing
      PARAMETER(        m_poTh1 =   0 )                              ! Cost(heta) spacing
      DOUBLE PRECISION  m_WminLEP1,          m_WmaxLEP1              ! LEP1 basic range (m_WminLEP1,m_WmaxLEP1)
      PARAMETER(        m_WminLEP1=0.010d0,  m_WmaxLEP1=100.001d0 )  ! LEP1 basic range (m_WminLEP1,m_WmaxLEP1)
***   PARAMETER(        m_WminLEP1=0.010d0,  m_WmaxLEP1=120.001d0 )  ! as in KORALZ, also enough
*----------- Z resonance
      PARAMETER(        m_poin2 =  20 )                              ! Z range sqrt(s)    spacing
      PARAMETER(        m_poTh2 =   0 )                              ! Cost(heta) spacing
***   PARAMETER(        m_poTh2 =  14 )                              ! =14 is overkill
      DOUBLE PRECISION  m_WminZ, m_WmaxZ, m_WdelZ                    ! Z range (amz + m_WdelZ)
      PARAMETER(        m_WdelZ = 5.000d0)                           ! Z range (amz + m_WdelZ)
***   PARAMETER(        m_WdelZ = 2d0 *2.495342704946d0)             ! Old range 2*Gamma
*----------- LEP2
      PARAMETER(        m_poTh3 =  30 )                              ! Overkill, bit lets kkep it
***   PARAMETER(        m_poTh3 =  14 )                              ! Cost(heta) spacing
      PARAMETER(        m_poin3 = 140 )                              ! LEP2 interval sqrt(s)    spacing
***   PARAMETER(        m_poin3 = 120 )                              ! as in KORALZ, also enough
      DOUBLE PRECISION  m_WmaxLEP2                                   ! LEP2 interval (m_WmaxLEP1,m_WmaxLEP2)
      PARAMETER(        m_WmaxLEP2  =240.001d0 )                     ! LEP2 interval (m_WmaxLEP1,m_WmaxLEP2)
*----------- Linear Colliders
      PARAMETER(        m_poin4 =  80 )                              ! NLC range sqrt(s)    spacing
      PARAMETER(        m_poTh4 =  14 )                              ! Cost(heta) spacing
      DOUBLE PRECISION  m_WmaxNLC                                    ! NLC range (m_WmaxLEP2,m_WmaxNLC)
      PARAMETER(        m_WmaxNLC  =1040.001d0 )                     ! NLC range (m_WmaxLEP2,m_WmaxNLC)
*//////////////////////////////////////////////////////////////////////////////
* EW formfactors, all flavours!!
      DOUBLE COMPLEX     m_cyy,     m_czz,     m_ctt,    m_clc   ! Electroweak FFactors
      DOUBLE PRECISION   m_syy,     m_szz,     m_stt,    m_slc   ! QCD corr.
      DOUBLE COMPLEX     m_GSW
      DOUBLE PRECISION   m_QCDcor   ! obsolete
      DOUBLE PRECISION   m_QCDcorR
*//////////////////////////////////////////////////////////////////////////////
* EW parameters
      DOUBLE PRECISION   m_Gmu
      DOUBLE PRECISION   m_MZ,      m_amh,     m_amtop
      DOUBLE PRECISION   m_swsq,    m_gammz,   m_amw,    m_gammw
*
      DOUBLE PRECISION   m_CMSene,  m_XXXene,  m_HadMin, m_vvmin,  m_vvmax !
      DOUBLE PRECISION   m_AvMult,  m_YFSkon,  m_YFS_IR, m_alfinv, m_alfpi, m_Xenph !
      DOUBLE PRECISION   m_vv,      m_x1,      m_x2
      DOUBLE PRECISION   m_Qf,      m_T3f,     m_helic,  m_amferm, m_auxpar !
      DOUBLE PRECISION   m_gnanob
      INTEGER            m_IsGenerated, m_KFferm,  m_NCf
      INTEGER            m_KFini,       m_KeyINT,  m_KeyQCD
      INTEGER            m_KeyElw,      m_KeyZet,  m_KeyWtm
      INTEGER            m_out

      COMMON /c_BornV/
* Tables of EW formfactors
     $  m_cyy(m_poin1+1,          m_poinG,16), ! formfactor, table
     $  m_czz(m_poin2+1,m_poTh2+1,m_poinG,16), ! formfactor, table
     $  m_ctt(m_poin3+1,m_poTh3+1,m_poinG,16), ! formfactor, table, costheta dependent
     $  m_clc(m_poin4+1,m_poTh4+1,m_poinG,16), ! formfactor, table, costheta dependent
     $  m_syy(m_poin1+1,          m_poinQ,16), ! QCD correction,
     $  m_szz(m_poin2+1,          m_poinQ,16), ! QCD correction,
     $  m_stt(m_poin3+1,          m_poinQ,16), ! QCD correction,
     $  m_slc(m_poin3+1,          m_poinQ,16), ! QCD correction,
     $  m_GSW(    m_poinG),                    ! form-factors,   at the actual energy/angle
     $  m_QCDcorR(m_poinQ),                    ! QCD correction, at the actual energy/angle
     $  m_QCDcor,                              ! obsolete!!!!
*
     $  m_CMSene,                       ! Initial value of CMS energy
     $  m_XXXene,                       ! CMS energy after beamsstrahlung or beam spread
* -------------------- EVENT --------------------------
     $  m_x1,                           ! 1-z1 = x1 for first  beam(strahlung)
     $  m_x2,                           ! 1-z2 = x2 for second beam(strahlung)
     $  m_vv,                           ! v = 1-sprim/s
     $  m_AvMult,                       ! Average photon multiplicity CRude at given v
     $  m_YFSkon,                       ! YFS formfactor finite part
     $  m_YFS_IR,                       ! YFS formfactor IR part
* -----------------------------------------------------
     $  m_vvmin,                        ! minimum v, infrared cut
     $  m_vvmax,                        ! maximum v
     $  m_HadMin,                       ! minimum hadronization mass [GeV]
* Basic QED and QCD
     $  m_alfinv,                       ! 1/alphaQED, Thomson limit (Q^2=0)
     $  m_alfpi,                        ! alphaQED/pi
     $  m_Xenph,                        ! Enhancement factor for Crude photon multiplicity
* EW parameters
     $  m_MZ,                           ! Z mass
     $  m_amh,                          ! Higgs mass
     $  m_amtop,                        ! Top mass
     $  m_swsq,                         ! sin(thetaW)**2
     $  m_gammz,                        ! Z width
     $  m_amw,                          ! W mass
     $  m_gammw,                        ! W width
     $  m_Gmu,                          ! Fermi constant (from muon decay)
* Table of fermion paramerets, quarks (1->6) and leptons (11->16)
     $  m_KFferm(20),                   ! fermion KFcode (1->6) and (11->16)
     $  m_NCf(20),                      ! number of colours
     $  m_Qf(20),                       ! electric charge
     $  m_T3f(20),                      ! isospin, L-hand component
     $  m_helic(20),                    ! helicity or polarization
     $  m_amferm(20),                   ! fermion mass
     $  m_auxpar(20),                   ! auxiliary parameter
     $  m_IsGenerated(20),              ! Generation flag, only for SAN !!! 
* Normalization
     $  m_gnanob,                       ! GeV^(-2) to nanobarns
* Initial/final fermion types
     $  m_KFini,                        ! KF code of beam
* Test switches
     $  m_KeyQCD,                       ! QCD FSR corr. switch
     $  m_KeyINT,                       ! ISR/FSR INTereference switch
     $  m_KeyElw,                       ! Type of Electrowak Library
     $  m_KeyZet,                       ! Z-boson on/off
     $  m_KeyWtm,                       ! Photon emission without mass terms
     $  m_out                           ! output unit for printouts
      SAVE /c_BornV/
*
* Formats for writing EW tables onto disk file.
      CHARACTER*80  m_fmt0, m_fmt1, m_fmt2
      PARAMETER (
     $  m_fmt0 ='(4g20.13)',                      ! Mz,Mt,Mh etc.
     $  m_fmt1 ='( a,  i4,  f10.5, i4,  f10.5 )', ! header
     $  m_fmt2 ='(6g13.7)'   )                    ! complex formfactors
*
*  Class procedures:
*
*//////////////////////////////////////////////////////////////////////////////
*//                                                                          //
*//                      End of CLASS  BornV                                 //
*//////////////////////////////////////////////////////////////////////////////

C      INCLUDE 'DZface.h'
*//////////////////////////////////////////////////////////////////////////////
*//                                                                          //
*//                     Pseudo-CLASS  DZface                                 //
*//   This  class is inheritance from class BornV                            //
*//   BornV.h  header is included in all routines                            //
*//                                                                          //
*//                                                                          //
*//   Purpose: Calculates Electroweak formfactor from Dizet                  //
*//            Writes the on the disk                                        //
*//////////////////////////////////////////////////////////////////////////////
*
*  Class members:
      DOUBLE PRECISION   m_alfinvMZ, m_alfQCDMZ
      INTEGER            m_KFfin
      INTEGER            m_IVini,   m_IVfin
      INTEGER            m_ibox
*//////////////////////////////////////////////////////////////////////////////
      COMMON /c_DZface/
     $  m_alfinvMZ,                     ! 1/alphaQED at (Q^2=MZ^2)     DIZET
     $  m_alfQCDMZ,                     ! alphaQCD   at (Q^2=MZ^2)     DIZET
*
     $  m_KFfin,                        ! KF code of final fermion     DIZET
     $  m_IVini,                        ! vertical id of initial ferm. DIZET
     $  m_IVfin,                        ! vertical id of   final ferm. DIZET
     $  m_ibox                          ! EW boxes on/off              DIZET
*
*  Class procedures:
*
*//////////////////////////////////////////////////////////////////////////////
*//                                                                          //
*//                      End of CLASS  DZface                                //
*//////////////////////////////////////////////////////////////////////////////
C      INCLUDE 'BXformat.h'
*
* BoX-FORMATs for nice and flexible outputs
      CHARACTER*80      bxope,bxclo,bxtxt,bxl1i,bxl1f,bxl2f,bxl1g,bxl2g,bxl1v
      PARAMETER (
     $  bxope ='(//1x,15(5h*****)    )',
     $  bxtxt ='(1x,1h*,                  a48,25x,    1h*)',
     $  bxl1i ='(1x,1h*,i17,                 16x, a20,a12,a7, 1x,1h*)',
     $  bxl1f ='(1x,1h*,f17.8,               16x, a20,a12,a7, 1x,1h*)',
     $  bxl2f ='(1x,1h*,f17.8, 4h  +-, f11.8, 1x, a20,a12,a7, 1x,1h*)',
     $  bxl1g ='(1x,1h*,g17.8,               16x, a20,a12,a7, 1x,1h*)',
     $  bxl2g ='(1x,1h*,g17.8, 4h  +-, f11.8, 1x, a20,a12,a7, 1x,1h*)',
     $  bxl1v ='(1x,1h*,      a20,  f10.2,   a23,        20x,    1h*)',
     $  bxclo ='(1x,15(5h*****)/   )'
     $ )
*///////////////////////////////////////////////////////////////////////////////

      DOUBLE PRECISION  xpar(*)
      INTEGER           KFfin
*
      DOUBLE PRECISION  partz(0:11),partw(3)
      DOUBLE PRECISION  zpard(30)
      INTEGER           Npar(30)
      INTEGER           ihvp,iamt4,Iqcd,imoms,iscre,ialem,imask
      INTEGER           iscal,ibarb,iftjr,ifacr,ifact,ihigs,iafmt
      INTEGER           imass,ii,i,kdumm,kolor
      INTEGER           iewlc,iczak,ihig2,iale2,igfer,iddzz
      DOUBLE PRECISION  amfin,wmass_start,qe,aizor,xolor,qf
      DOUBLE PRECISION  AlStrZ,AlQedZ,DAL5H,AlStrT
*/////////////////////////////////////////////////////////////////////////////
* Translation table KF-->IV
      INTEGER IV(-16:16)
      DATA IV / -1, -2, -1, -2, -1, -2, 4*0, -3, -4, -3, -4, -3, -4,  0,  
     $           4,  3,  4,  3,  4,  3, 4*0,  2,  1,  2,  1,  2,  1    /
*/////////////////////////////////////////////////////////////////////////////
      m_out   = 16
      m_KFfin = KFfin
      m_KFini = xpar(400) !!!
      m_IVini = IV(m_KFini)
      m_IVfin = IV(m_KFfin)
*
      m_MZ      = xpar(502) !!!
*
      m_ibox    = xpar(801) !!!
      m_amh     = xpar(805) !!!
      m_amtop   = xpar(806) !!!
*
      m_alfinvMZ  = xpar(808) !!! (128.86674175d0)
      m_alfQCDMZ  = xpar(809) !!! (0.125d0)

      m_amw   = 80d0      ! input, rededined by Dizet

      WRITE(m_out,bxope)
      WRITE(m_out,bxtxt) 'DZface_Initialize, Interface to Dizet 6.xx   '
      WRITE(m_out,bxl1f) m_MZ    ,   'Z mass             ','amz   ','a1'
      WRITE(m_out,bxl1f) m_amh   ,   'Higgs mass         ','amh   ','a2'
      WRITE(m_out,bxl1f) m_amtop ,   'Top mass           ','amtop ','a3'
      WRITE(m_out,bxl1i) m_KFini ,   'KF code of beam    ','KFini ','a5'
      WRITE(m_out,bxl1i) m_KFfin ,   'KF of final fermion','KFfin ','a6'
      WRITE(m_out,bxl1i) m_IVini ,   'IV code of beam    ','IVini ','a7'
      WRITE(m_out,bxl1i) m_IVfin ,   'IV of final fermion','IVfin ','a8'
      WRITE(m_out,bxl1i) m_ibox  ,   'EW box switch      ','ibox  ','a9'
      WRITE(m_out,bxl1f) m_alfinvMZ, 'QED alfa inv. at Z ','alfinv','a1'
      WRITE(m_out,bxl1f) m_alfQCDMZ, 'QCD alfa at Z mass ','alfQCD','a2'
      WRITE(m_out,bxclo)

      CALL DZface_GivIzo( m_IVini, 1,aizor,qe,kdumm)
      CALL DZface_GivIzo( m_IVfin, 1,aizor,qf,kolor)

*  Default values
*      Ihvp  =  1  ! =1,2,3  (Jegerlehner/Eidelman, Jegerlehner(1988), Burkhardt etal.)
*      Iamt4 =  4  ! =0,1,2,3,4 (=4 the best, Degrassi/Gambino)
*      Iqcd  =  3  ! =1,2,3  (approx/fast/lep1, exact/Slow!/Bardin/, exact/fast/Kniehl)
*      Imoms =  1  ! =0,1    (=1 W mass recalculated)
*      Imass =  0  ! =0,1    (=1 test only, effective quark masses)
*      Iscre =  0  ! =0,1,2  ( Remainder terms, 
*      Ialem =  3  ! =1,3 or 0,2, (for 1,3 DALH5 not input)
*      Imask =  0  ! =0,1 (=0: Quark masses everywhere; =1 Phys. threshold in the ph.sp.)
*      Iscal =  0  ! =0,1,2,3  ( Kniehl=1,2,3, Sirlin=4)
*      Ibarb =  2  ! =-1,0,1,2 ( Barbieri???)
*      Iftjr =  1  ! =0,1      ( FTJR corrections)
*      Ifacr =  0  ! =0,1,2,3  ( Expansion of delta_r; =0 none; =3 fully, unrecommed.)
*      Ifact =  0  ! =0,1,2,3,4,5 (Expansion of kappa; =0 none )
*      Ihigs =  0  ! =0,1      ( Leading Higgs contribution resummation)
*      Iafmt =  1  ! =0,1      (=0 for old ZF)
* new parameters of 6.x version
*      Iewlc =  1  ! =0,1   (???)
*      Iczak =  1  ! =0,1   (Czarnecki/Kuehn corrections)
*      Ihig2 =  1  ! =0,1   (Two-loop higgs  corrections off,on) 
*      Iale2 =  3  ! =1,2,3 (Two-loop constant corrections in delta_alpha)
*      Igfer =  2  ! =0,1,2 (QED corrections for fermi constant)
*      Iddzz =  1  ! =0,1   (??? DD-ZZ game, internal flag)
*
* Input flags in NPAR
      DO i=1,21
         Npar(i) = xpar(900+i)
      ENDDO
      WRITE(m_out,'(a/(a8,i2,a8,i2))')
     $ ' DIZET flags, see routine Dizet for explanation:',
     $ '  Ihvp =',Npar( 1),  ' Iamt4 =',Npar( 2),
     $ '  Iqcd =',Npar( 3),  ' Imoms =',Npar( 4),
     $ ' Imass =',Npar( 5),  ' Iscre =',Npar( 6),
     $ ' Ialem =',Npar( 7),  ' Imask =',Npar( 8),
     $ ' Iscal =',Npar( 9),  ' Ibarb =',Npar(10),
     $ ' IFtjr =',Npar(11),  ' Ifacr =',Npar(12),
     $ ' IFact =',Npar(13),  ' Ihigs =',Npar(14),
     $ ' Iafmt =',Npar(15),  ' Iewlc =',Npar(16),
     $ ' Iczak =',Npar(17),  ' Ihig2 =',Npar(18),
     $ ' Iale2 =',Npar(19),  ' Igfer =',Npar(20),
     $ ' Iddzz =',Npar(21)
*     =================================================================
* Input which is not in Npar
      AlStrZ      =  m_alfQCDMZ          ! input at MZ
      AlQedZ      =  1d0/m_alfinvMZ      ! will be redefibed by dizet6
*     =================================================================
******      !!!!! Dizet 5.x, obsolete !!!!!
******      CALL dizet( Npar, m_amw, m_MZ, m_amtop, m_amh,
******     $            AlQedZ, AlStrZ, 
******     $            zpard, partz, partw)
*     =================================================================
*  Dizet 6.x
      CALL DIZET( 
     $   Npar,   ! Inp. Integer switches
     $  m_amw,   ! I/O. W mass (Out. for Imoms=Npar(4)=1,3)
     $  m_MZ,    ! I/O. Z mass (Out. for Imoms=Npar(4)=2,4)
     $  m_amtop, ! Inp. t-quark mass 
     $  m_amh,   ! Inp. Higgs boson mass
     $  DAL5H,   ! I/O. \Delta_Alpha^5_{had}(MZ), (Inp. Ialem=0,2)(Out. Ialem=1,3)
     $  AlQedZ,  ! Out. Alpha_QED
     $  AlStrZ,  ! Inp. Alpha_strong(MZ)
     $  AlStrT,  ! Out. Alpha_strong(MT)
     $  zpard,   ! Out. zpar(1) = del_r, zpar(2) = del_r_rem, zpar(3) = sw2, ... etc
     $  partz,   ! Out. Z partial decay widths
     $  partw)   ! Out. W partial decay widths
*     =================================================================
*(((((((((( m_QCDcor is for debug only
      IF (    ABS(m_KFfin) .GT. 10)  THEN
         m_QCDcor = 0d0             ! leptons
      ELSEIF (ABS(m_KFfin) .EQ. 5)  THEN
         m_QCDcor = zpard(20)-1.0   ! b-quark
      ELSE
         m_QCDcor = zpard(25)-1.0   ! light-quarks
      ENDIF
c))))))))))))))))))))))))))))))))))))))
      WRITE(m_out,*) '   '
      WRITE(m_out,'(a,  f8.6)') ' Alpha-QED   (MZ)  =',AlQedZ
      WRITE(m_out,'(a,  f8.4)') ' Alfa strong (MZ)  =',AlStrZ
      WRITE(m_out,'(a,  f8.4)') ' Alfa strong (Mt)  =',AlStrT
      WRITE(m_out,'(a,f15.10)') 'zpard(20): QCD corr.fact. to Z-width (no b)  =',zpard(20)
      WRITE(m_out,'(a,f15.10)') 'zpard(25): QCD corr.fact. to Z-width (into b)=',zpard(25)
      WRITE(m_out,*) '   '
      WRITE(m_out,*) 'zpar-matrix: standard output of dizet:'
      WRITE(m_out,'(a,i2,a,f12.8)') ('    zpar(',ii,')=',zpard(ii),ii=1,30)

      WRITE(m_out,bxope)
      WRITE(m_out,bxtxt) 'DZface_Initializion ended  '
      WRITE(m_out,bxclo)
      END


      SUBROUTINE DZface_ReaDataX(DiskFile,iReset,imax,xpar)
*/////////////////////////////////////////////////////////////////////////////////////
*//                                                                                 //
*//   Clone of KK2f_ReaDataX                                                        //
*//                                                                                 //
*//   DiskFile  = input file to read                                                //
*//   imax   = maximum index in xpar                                                //
*//   iReset = 1, resets xpar to 0d0                                                //
*//   iTalk=1,     prints echo into standard input                                  //
*//                                                                                 //
*//   Single data card is:    (a1,i4,d15.0,a60)                                     //
*//   First data card: BeginX                                                       //
*//   Last  data card: EndX                                                         //
*//   First character * defines comment card!                                       //
*//                                                                                 //
*/////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
      CHARACTER*(*)     DiskFile
      DOUBLE PRECISION  xpar(*)
      CHARACTER*6       beg6
      CHARACTER*4       end4
      CHARACTER*1       mark1
      CHARACTER*60      comm60
      CHARACTER*80      comm80
      INTEGER           imax,iReset,iTalk
      INTEGER           ninp,i,line,index
      DOUBLE PRECISION  value
*////////////////////////////////////////
*//  Clear xpar and read default Umask //
*////////////////////////////////////////
      iTalk = 1
      IF(iReset .EQ. 1 ) THEN
         iTalk = 0
         DO i=1,imax
            xpar(i)=0d0
         ENDDO
      ENDIF
      ninp = 13
      OPEN(ninp,file=DiskFile)
      IF(iTalk .EQ. 1) THEN
         WRITE(  *,*) '****************************'
         WRITE(  *,*) '*  DZface_ReaDataX Starts  *'
         WRITE(  *,*) '****************************'
      ENDIF
* Search for 'BeginX'
      DO line =1,100000
         READ(ninp,'(a6,a)') beg6,comm60
         IF(beg6 .EQ. 'BeginX') THEN
            IF(iTalk .EQ. 1)   WRITE( *,'(a6,a)') beg6,comm60
            GOTO 200
         ENDIF
      ENDDO
 200  CONTINUE
* Read data, 'EndX' terminates data, '*' marks comment
      DO line =1,100000
         READ(ninp,'(a)') mark1
         IF(mark1 .EQ. ' ') THEN
            BACKSPACE(ninp)
            READ(ninp,'(a1,i4,d15.0,a60)') mark1,index,value,comm60
            IF(iTalk .EQ. 1) 
     $           WRITE( *,'(a1,i4,g15.6,a60)') mark1,index,value,comm60
            IF( (index .LE. 0) .OR. (index .GE. imax)) GOTO 990
            xpar(index) = value
         ELSEIF(mark1 .EQ. 'E') THEN
            BACKSPACE(ninp)
            READ(  ninp,'(a4,a)') end4,comm60
            IF(iTalk .EQ. 1)   WRITE( *,'(a4,a)') end4,comm60
            IF(end4 .EQ. 'EndX') GOTO 300
            GOTO 991
         ELSEIF(mark1 .EQ. '*') THEN
            BACKSPACE(ninp)
            READ(  ninp,'(a)') comm80
            IF(iTalk .EQ. 1)    WRITE( *,'(a)') comm80
         ENDIF
      ENDDO
 300  CONTINUE
      IF(iTalk .EQ. 1)  THEN
         WRITE(  *,*) '**************************'
         WRITE(  *,*) '*   DZface_ReaDataX Ends   *'
         WRITE(  *,*) '**************************'
      ENDIF
      CLOSE(ninp)
      RETURN
*-----------
 990  WRITE(    *,*) '+++ DZface_ReaDataX: wrong index= ',index
      STOP
      RETURN
 991  WRITE(    *,*) '+++ DZface_ReaDataX: wrong end of data '
      STOP
      END


      SUBROUTINE DZface_Tabluj
*/////////////////////////////////////////////////////////////////////////////////////////
*//                                                                                     //
*//  Routine for evaluation and pretabulation of electroweak formfactors                //
*//                                                                                     //
*/////////////////////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
C      INCLUDE '../bornv/BornV.h'
*//////////////////////////////////////////////////////////////////////////////
*//                                                                          //
*//                     Pseudo-CLASS  BornV                                  //
*//                                                                          //
*//  Purpose:                                                                //
*//  Provide Born angular distribution and integrated x-section              //
*//  as a function of s.                                                     //
*//                                                                          //
*//  NOTES:                                                                  //
*//  How to eliminate nneut? This will come in a natural way                 //
*//  when neutrino type is generated.                                        //
*//  NB. Zbyszek says that weight dispersion might worsen!                   //
*//                                                                          //
*//////////////////////////////////////////////////////////////////////////////
*
*  Class members:
*
*//////////////////////////////////////////////////////////////////////////////
      DOUBLE PRECISION   m_pi
      PARAMETER         (m_pi =3.1415926535897932d0)
      DOUBLE PRECISION   m_fleps
****  PARAMETER (m_fleps = 1d-35)  ! original
****  PARAMETER (m_fleps = 1d-45)  ! enough???
      PARAMETER (m_fleps = 1d-100)  ! enough!!!
****      PARAMETER (m_fleps = 1d-200)  ! enough!!!
*//////////////////////////////////////////////////////////////////////////////
*//       Energy limits in the EW grid, w=sqrt(s) in GeV units.              //
*//////////////////////////////////////////////////////////////////////////////
*     340-point grid, only 80pt for NLC to be improved/tested in future
      INTEGER           m_poin1, m_poin2, m_poin3, m_poin4, m_poinG , m_poinQ !
      INTEGER           m_poTh1, m_poTh2, m_poTh3, m_poTh4
      PARAMETER(        m_poinG =   7 )                      ! No of EW formfactors
      PARAMETER(        m_poinQ =   4 )                      ! No of QCD corrections
*----------- Low energies and LEP1
      PARAMETER(        m_poin1 = 120 )                              ! LEP1 basic range sqrt(s)    spacing
cc      PARAMETER(        m_poin1 = 96 )                              ! LEP1 basic range sqrt(s)    spacing
      PARAMETER(        m_poTh1 =   0 )                              ! Cost(heta) spacing
      DOUBLE PRECISION  m_WminLEP1,          m_WmaxLEP1              ! LEP1 basic range (m_WminLEP1,m_WmaxLEP1)
      PARAMETER(        m_WminLEP1=0.010d0,  m_WmaxLEP1=100.001d0 )  ! LEP1 basic range (m_WminLEP1,m_WmaxLEP1)
***   PARAMETER(        m_WminLEP1=0.010d0,  m_WmaxLEP1=120.001d0 )  ! as in KORALZ, also enough
*----------- Z resonance
      PARAMETER(        m_poin2 =  20 )                              ! Z range sqrt(s)    spacing
      PARAMETER(        m_poTh2 =   0 )                              ! Cost(heta) spacing
***   PARAMETER(        m_poTh2 =  14 )                              ! =14 is overkill
      DOUBLE PRECISION  m_WminZ, m_WmaxZ, m_WdelZ                    ! Z range (amz + m_WdelZ)
      PARAMETER(        m_WdelZ = 5.000d0)                           ! Z range (amz + m_WdelZ)
***   PARAMETER(        m_WdelZ = 2d0 *2.495342704946d0)             ! Old range 2*Gamma
*----------- LEP2
      PARAMETER(        m_poTh3 =  30 )                              ! Overkill, bit lets kkep it
***   PARAMETER(        m_poTh3 =  14 )                              ! Cost(heta) spacing
      PARAMETER(        m_poin3 = 140 )                              ! LEP2 interval sqrt(s)    spacing
***   PARAMETER(        m_poin3 = 120 )                              ! as in KORALZ, also enough
      DOUBLE PRECISION  m_WmaxLEP2                                   ! LEP2 interval (m_WmaxLEP1,m_WmaxLEP2)
      PARAMETER(        m_WmaxLEP2  =240.001d0 )                     ! LEP2 interval (m_WmaxLEP1,m_WmaxLEP2)
*----------- Linear Colliders
      PARAMETER(        m_poin4 =  80 )                              ! NLC range sqrt(s)    spacing
      PARAMETER(        m_poTh4 =  14 )                              ! Cost(heta) spacing
      DOUBLE PRECISION  m_WmaxNLC                                    ! NLC range (m_WmaxLEP2,m_WmaxNLC)
      PARAMETER(        m_WmaxNLC  =1040.001d0 )                     ! NLC range (m_WmaxLEP2,m_WmaxNLC)
*//////////////////////////////////////////////////////////////////////////////
* EW formfactors, all flavours!!
      DOUBLE COMPLEX     m_cyy,     m_czz,     m_ctt,    m_clc   ! Electroweak FFactors
      DOUBLE PRECISION   m_syy,     m_szz,     m_stt,    m_slc   ! QCD corr.
      DOUBLE COMPLEX     m_GSW
      DOUBLE PRECISION   m_QCDcor   ! obsolete
      DOUBLE PRECISION   m_QCDcorR
*//////////////////////////////////////////////////////////////////////////////
* EW parameters
      DOUBLE PRECISION   m_Gmu
      DOUBLE PRECISION   m_MZ,      m_amh,     m_amtop
      DOUBLE PRECISION   m_swsq,    m_gammz,   m_amw,    m_gammw
*
      DOUBLE PRECISION   m_CMSene,  m_XXXene,  m_HadMin, m_vvmin,  m_vvmax !
      DOUBLE PRECISION   m_AvMult,  m_YFSkon,  m_YFS_IR, m_alfinv, m_alfpi, m_Xenph !
      DOUBLE PRECISION   m_vv,      m_x1,      m_x2
      DOUBLE PRECISION   m_Qf,      m_T3f,     m_helic,  m_amferm, m_auxpar !
      DOUBLE PRECISION   m_gnanob
      INTEGER            m_IsGenerated, m_KFferm,  m_NCf
      INTEGER            m_KFini,       m_KeyINT,  m_KeyQCD
      INTEGER            m_KeyElw,      m_KeyZet,  m_KeyWtm
      INTEGER            m_out

      COMMON /c_BornV/
* Tables of EW formfactors
     $  m_cyy(m_poin1+1,          m_poinG,16), ! formfactor, table
     $  m_czz(m_poin2+1,m_poTh2+1,m_poinG,16), ! formfactor, table
     $  m_ctt(m_poin3+1,m_poTh3+1,m_poinG,16), ! formfactor, table, costheta dependent
     $  m_clc(m_poin4+1,m_poTh4+1,m_poinG,16), ! formfactor, table, costheta dependent
     $  m_syy(m_poin1+1,          m_poinQ,16), ! QCD correction,
     $  m_szz(m_poin2+1,          m_poinQ,16), ! QCD correction,
     $  m_stt(m_poin3+1,          m_poinQ,16), ! QCD correction,
     $  m_slc(m_poin3+1,          m_poinQ,16), ! QCD correction,
     $  m_GSW(    m_poinG),                    ! form-factors,   at the actual energy/angle
     $  m_QCDcorR(m_poinQ),                    ! QCD correction, at the actual energy/angle
     $  m_QCDcor,                              ! obsolete!!!!
*
     $  m_CMSene,                       ! Initial value of CMS energy
     $  m_XXXene,                       ! CMS energy after beamsstrahlung or beam spread
* -------------------- EVENT --------------------------
     $  m_x1,                           ! 1-z1 = x1 for first  beam(strahlung)
     $  m_x2,                           ! 1-z2 = x2 for second beam(strahlung)
     $  m_vv,                           ! v = 1-sprim/s
     $  m_AvMult,                       ! Average photon multiplicity CRude at given v
     $  m_YFSkon,                       ! YFS formfactor finite part
     $  m_YFS_IR,                       ! YFS formfactor IR part
* -----------------------------------------------------
     $  m_vvmin,                        ! minimum v, infrared cut
     $  m_vvmax,                        ! maximum v
     $  m_HadMin,                       ! minimum hadronization mass [GeV]
* Basic QED and QCD
     $  m_alfinv,                       ! 1/alphaQED, Thomson limit (Q^2=0)
     $  m_alfpi,                        ! alphaQED/pi
     $  m_Xenph,                        ! Enhancement factor for Crude photon multiplicity
* EW parameters
     $  m_MZ,                           ! Z mass
     $  m_amh,                          ! Higgs mass
     $  m_amtop,                        ! Top mass
     $  m_swsq,                         ! sin(thetaW)**2
     $  m_gammz,                        ! Z width
     $  m_amw,                          ! W mass
     $  m_gammw,                        ! W width
     $  m_Gmu,                          ! Fermi constant (from muon decay)
* Table of fermion paramerets, quarks (1->6) and leptons (11->16)
     $  m_KFferm(20),                   ! fermion KFcode (1->6) and (11->16)
     $  m_NCf(20),                      ! number of colours
     $  m_Qf(20),                       ! electric charge
     $  m_T3f(20),                      ! isospin, L-hand component
     $  m_helic(20),                    ! helicity or polarization
     $  m_amferm(20),                   ! fermion mass
     $  m_auxpar(20),                   ! auxiliary parameter
     $  m_IsGenerated(20),              ! Generation flag, only for SAN !!! 
* Normalization
     $  m_gnanob,                       ! GeV^(-2) to nanobarns
* Initial/final fermion types
     $  m_KFini,                        ! KF code of beam
* Test switches
     $  m_KeyQCD,                       ! QCD FSR corr. switch
     $  m_KeyINT,                       ! ISR/FSR INTereference switch
     $  m_KeyElw,                       ! Type of Electrowak Library
     $  m_KeyZet,                       ! Z-boson on/off
     $  m_KeyWtm,                       ! Photon emission without mass terms
     $  m_out                           ! output unit for printouts
      SAVE /c_BornV/
*
* Formats for writing EW tables onto disk file.
      CHARACTER*80  m_fmt0, m_fmt1, m_fmt2
      PARAMETER (
     $  m_fmt0 ='(4g20.13)',                      ! Mz,Mt,Mh etc.
     $  m_fmt1 ='( a,  i4,  f10.5, i4,  f10.5 )', ! header
     $  m_fmt2 ='(6g13.7)'   )                    ! complex formfactors
*
*  Class procedures:
*
*//////////////////////////////////////////////////////////////////////////////
*//                                                                          //
*//                      End of CLASS  BornV                                 //
*//////////////////////////////////////////////////////////////////////////////

C      INCLUDE 'DZface.h'
*//////////////////////////////////////////////////////////////////////////////
*//                                                                          //
*//                     Pseudo-CLASS  DZface                                 //
*//   This  class is inheritance from class BornV                            //
*//   BornV.h  header is included in all routines                            //
*//                                                                          //
*//                                                                          //
*//   Purpose: Calculates Electroweak formfactor from Dizet                  //
*//            Writes the on the disk                                        //
*//////////////////////////////////////////////////////////////////////////////
*
*  Class members:
      DOUBLE PRECISION   m_alfinvMZ, m_alfQCDMZ
      INTEGER            m_KFfin
      INTEGER            m_IVini,   m_IVfin
      INTEGER            m_ibox
*//////////////////////////////////////////////////////////////////////////////
      COMMON /c_DZface/
     $  m_alfinvMZ,                     ! 1/alphaQED at (Q^2=MZ^2)     DIZET
     $  m_alfQCDMZ,                     ! alphaQCD   at (Q^2=MZ^2)     DIZET
*
     $  m_KFfin,                        ! KF code of final fermion     DIZET
     $  m_IVini,                        ! vertical id of initial ferm. DIZET
     $  m_IVfin,                        ! vertical id of   final ferm. DIZET
     $  m_ibox                          ! EW boxes on/off              DIZET
*
*  Class procedures:
*
*//////////////////////////////////////////////////////////////////////////////
*//                                                                          //
*//                      End of CLASS  DZface                                //
*//////////////////////////////////////////////////////////////////////////////
      DOUBLE PRECISION  ww,x,cosi
      DOUBLE PRECISION  QCDcorR(20)
      DOUBLE PRECISION  amzD,gammz1,gammw1
      DOUBLE COMPLEX    GSW(100)
      INTEGER           i,j,k,kk,ndisk
*----------------------------------------------------------------------
*/////////////////////////////////////
*//    some initialisations         //
*/////////////////////////////////////
* Note that m_MZ m_amh, m_amtop are already defined.
* We get other params out of dizet using DZface_GetPrm.
      CALL DZface_GetPrm( amzD,m_gammz,gammz1,m_amw,m_gammw,gammw1,m_swsq) !
*/////////////////////////////////////////////////////////////////
*//   basic s range LEP1 and below        m_cyy(m_poin1+1, 7)   //
*/////////////////////////////////////////////////////////////////
      WRITE(m_out,*) 'DZface_Tabluj: pretabulation, basic LEP1 range'
      WRITE(6    ,*) 'DZface_Tabluj: pretabulation, basic LEP1 range'
      CALL DZface_MakeGSW(-1, ww, 0d0, GSW, QCDcorR) !initialize QCDcor calculation.
      DO i=0,m_poin1
         ww = m_WminLEP1 *(m_WmaxLEP1/m_WminLEP1)**(DFLOAT(i)/DFLOAT(m_poin1)) !
         IF(MOD(i,10)  .EQ.  0) WRITE(    6,*) 'a: i,ww= ',i,ww
         IF(MOD(i,10)  .EQ.  0) WRITE(m_out,*) 'a: i,ww= ',i,ww
         CALL DZface_MakeGSW( 0, ww, 0d0, GSW, QCDcorR) ! at theta=pi, ibox=0
*--------------------
         DO kk=1,m_poinG
            m_cyy(i+1,kk,m_KFfin) = GSW(kk)
         ENDDO
         DO kk=1,m_poinQ
            m_syy(i+1,kk,m_KFfin) = QCDcorR(kk)
         ENDDO
***      WRITE(6,*) 'KFf=',m_KFfin,'sqrt(s)=',ww,
***  $              'old=',m_QCDcor,'new=',QCDcorR
      ENDDO
*/////////////////////////////////////////////////////////////////
*/              near Z0 resonance    m_czz(m_poin2+1, 7)        //
*/////////////////////////////////////////////////////////////////
      WRITE(m_out,*) 'DZface_Tabluj: pretabulation, near Z0:'
      WRITE(    6,*) 'DZface_Tabluj: pretabulation, near Z0:'
      CALL DZface_MakeGSW( -1, ww, cosi, GSW, QCDcorR) !initialize QCDcor calculation.
      m_WminZ =m_MZ-m_WdelZ
      m_WmaxZ =m_MZ+m_WdelZ
      DO i=0,m_poin2
         ww = m_WminZ +(m_WmaxZ-m_WminZ)*(DFLOAT(i)/DFLOAT(m_poin2))
         IF(MOD(i,10)  .EQ.  0) WRITE(    6,*) 'b: i,ww= ',i,ww
         IF(MOD(i,10)  .EQ.  0) WRITE(m_out,*) 'b: i,ww= ',i,ww
         IF(m_poTh2.EQ.0) THEN
            cosi=0d0
            CALL DZface_MakeGSW( 0, ww, cosi, GSW, QCDcorR) ! at theta=pi, ibox=0
            DO kk=1,m_poinG
               m_czz(i+1,1,kk,m_KFfin)=GSW(kk)
            ENDDO
         ELSE
            DO  j=0,m_poTh2
              cosi = ( -1d0+2d0*DFLOAT(j)/DFLOAT(m_poTh2) )*(1d0-1d-8)
              IF(j.EQ.0      ) cosi=cosi+.3d0/max(1.d-5,DFLOAT(m_poTh2))
              IF(j.EQ.m_poTh2) cosi=cosi-.3d0/max(1.d-5,DFLOAT(m_poTh2))
              CALL DZface_MakeGSW( m_ibox, ww, cosi, GSW, QCDcorR) ! ibox from input
               DO kk=1,m_poinG
                  m_czz(i+1,j+1,kk,m_KFfin)=GSW(kk)
               ENDDO
            ENDDO
         ENDIF
         DO kk=1,m_poinQ
            m_szz(i+1,kk,m_KFfin) = QCDcorR(kk)
         ENDDO
      ENDDO
*/////////////////////////////////////////////////////////////////////
*//   the region of boxes, LEP2,   m_ctt(m_poin3+1, m_poTh3+1, 7)   //
*/////////////////////////////////////////////////////////////////////
      WRITE(m_out,*) 'DZface_Tabluj: LEP2 energy zone: pretabulation starts' !
      WRITE(    *,*) 'DZface_Tabluj: LEP2 energy zone: pretabulation starts: it will take a bit time' !
      CALL DZface_MakeGSW( -1, ww, cosi, GSW, QCDcorR)
      DO  i=0,m_poin3
         ww = m_WmaxLEP1 +(m_WmaxLEP2-m_WmaxLEP1)*(DFLOAT(i)/DFLOAT(m_poin3)) !
         IF(MOD(i,10)  .EQ.  0) WRITE(    6,*) 'c: i,ww= ',i,ww
         IF(MOD(i,10)  .EQ.  0) WRITE(m_out,*) 'c: i,ww= ',i,ww
         DO  j=0,m_poTh3
            cosi = ( -1d0+2d0*DFLOAT(j)/DFLOAT(m_poTh3) )*(1d0-1d-8)
            IF(j  .EQ.        0) cosi=cosi+.3d0/DFLOAT(m_poTh3)
            IF(j  .EQ.  m_poTh3) cosi=cosi-.3d0/DFLOAT(m_poTh3)
            CALL DZface_MakeGSW( m_ibox, ww, cosi, GSW, QCDcorR) ! ibox from input
            DO  kk=1,m_poinG
               m_ctt(i+1,j+1,kk,m_KFfin)=GSW(kk)
            ENDDO
         ENDDO
         DO kk=1,m_poinQ
            m_stt(i+1,kk,m_KFfin) = QCDcorR(kk)
         ENDDO
      ENDDO
*/////////////////////////////////////////////////////////////////////
*//   the region of boxes, NLC,    m_clc(m_poin4+1, m_poTh4+1, 7)   //
*/////////////////////////////////////////////////////////////////////
      WRITE(m_out,*) 'DZface_Tabluj: NLC energy range: pretabulation starts' !
      WRITE(    *,*) 'DZface_Tabluj: NLC energy range: pretabulation starts: it will take a bit time' !
      CALL DZface_MakeGSW(-1,ww,cosi,GSW,QCDcorR)
      DO  i=0,m_poin4
         ww  = m_WmaxLEP2+(m_WmaxNLC-m_WmaxLEP2)*(DFLOAT(i)/DFLOAT(m_poin4)) !
         IF(MOD(i,10)  .EQ.  0) WRITE(    6,*) 'd: i,ww= ',i,ww
         IF(MOD(i,10)  .EQ.  0) WRITE(m_out,*) 'd: i,ww= ',i,ww
         DO  j=0,m_poTh4
            cosi = ( -1d0+2d0*DFLOAT(j)/DFLOAT(m_poTh4) )*(1d0-1d-8)
            IF(j  .EQ.        0) cosi=cosi+.3d0/DFLOAT(m_poTh4)
            IF(j  .EQ.  m_poTh4) cosi=cosi-.3d0/DFLOAT(m_poTh4)
            CALL DZface_MakeGSW( m_ibox, ww, cosi, GSW, QCDcorR) ! ibox from input
*---------------
            DO  kk=1,m_poinG
               m_clc(i+1,j+1,kk,m_KFfin) = GSW(kk)
            ENDDO
         ENDDO
         DO kk=1,m_poinQ
            m_slc(i+1,kk,m_KFfin) = QCDcorR(kk)
         ENDDO
      ENDDO
      WRITE(m_out,*) 'DZface_Tabluj: pretabulatin finished  now !'
      WRITE(6    ,*) 'DZface_Tabluj: pretabulatin finished  now !'
      END                       ! DZface_Tabluj


      SUBROUTINE DZface_WriteFile(DiskFile)
*///////////////////////////////////////////////////////////////////
*//       Write tables into DiskFile                              //
*///////////////////////////////////////////////////////////////////
      IMPLICIT NONE
C      INCLUDE '../bornv/BornV.h'
*//////////////////////////////////////////////////////////////////////////////
*//                                                                          //
*//                     Pseudo-CLASS  BornV                                  //
*//                                                                          //
*//  Purpose:                                                                //
*//  Provide Born angular distribution and integrated x-section              //
*//  as a function of s.                                                     //
*//                                                                          //
*//  NOTES:                                                                  //
*//  How to eliminate nneut? This will come in a natural way                 //
*//  when neutrino type is generated.                                        //
*//  NB. Zbyszek says that weight dispersion might worsen!                   //
*//                                                                          //
*//////////////////////////////////////////////////////////////////////////////
*
*  Class members:
*
*//////////////////////////////////////////////////////////////////////////////
      DOUBLE PRECISION   m_pi
      PARAMETER         (m_pi =3.1415926535897932d0)
      DOUBLE PRECISION   m_fleps
****  PARAMETER (m_fleps = 1d-35)  ! original
****  PARAMETER (m_fleps = 1d-45)  ! enough???
      PARAMETER (m_fleps = 1d-100)  ! enough!!!
****      PARAMETER (m_fleps = 1d-200)  ! enough!!!
*//////////////////////////////////////////////////////////////////////////////
*//       Energy limits in the EW grid, w=sqrt(s) in GeV units.              //
*//////////////////////////////////////////////////////////////////////////////
*     340-point grid, only 80pt for NLC to be improved/tested in future
      INTEGER           m_poin1, m_poin2, m_poin3, m_poin4, m_poinG , m_poinQ !
      INTEGER           m_poTh1, m_poTh2, m_poTh3, m_poTh4
      PARAMETER(        m_poinG =   7 )                      ! No of EW formfactors
      PARAMETER(        m_poinQ =   4 )                      ! No of QCD corrections
*----------- Low energies and LEP1
      PARAMETER(        m_poin1 = 120 )                              ! LEP1 basic range sqrt(s)    spacing
cc      PARAMETER(        m_poin1 = 96 )                              ! LEP1 basic range sqrt(s)    spacing
      PARAMETER(        m_poTh1 =   0 )                              ! Cost(heta) spacing
      DOUBLE PRECISION  m_WminLEP1,          m_WmaxLEP1              ! LEP1 basic range (m_WminLEP1,m_WmaxLEP1)
      PARAMETER(        m_WminLEP1=0.010d0,  m_WmaxLEP1=100.001d0 )  ! LEP1 basic range (m_WminLEP1,m_WmaxLEP1)
***   PARAMETER(        m_WminLEP1=0.010d0,  m_WmaxLEP1=120.001d0 )  ! as in KORALZ, also enough
*----------- Z resonance
      PARAMETER(        m_poin2 =  20 )                              ! Z range sqrt(s)    spacing
      PARAMETER(        m_poTh2 =   0 )                              ! Cost(heta) spacing
***   PARAMETER(        m_poTh2 =  14 )                              ! =14 is overkill
      DOUBLE PRECISION  m_WminZ, m_WmaxZ, m_WdelZ                    ! Z range (amz + m_WdelZ)
      PARAMETER(        m_WdelZ = 5.000d0)                           ! Z range (amz + m_WdelZ)
***   PARAMETER(        m_WdelZ = 2d0 *2.495342704946d0)             ! Old range 2*Gamma
*----------- LEP2
      PARAMETER(        m_poTh3 =  30 )                              ! Overkill, bit lets kkep it
***   PARAMETER(        m_poTh3 =  14 )                              ! Cost(heta) spacing
      PARAMETER(        m_poin3 = 140 )                              ! LEP2 interval sqrt(s)    spacing
***   PARAMETER(        m_poin3 = 120 )                              ! as in KORALZ, also enough
      DOUBLE PRECISION  m_WmaxLEP2                                   ! LEP2 interval (m_WmaxLEP1,m_WmaxLEP2)
      PARAMETER(        m_WmaxLEP2  =240.001d0 )                     ! LEP2 interval (m_WmaxLEP1,m_WmaxLEP2)
*----------- Linear Colliders
      PARAMETER(        m_poin4 =  80 )                              ! NLC range sqrt(s)    spacing
      PARAMETER(        m_poTh4 =  14 )                              ! Cost(heta) spacing
      DOUBLE PRECISION  m_WmaxNLC                                    ! NLC range (m_WmaxLEP2,m_WmaxNLC)
      PARAMETER(        m_WmaxNLC  =1040.001d0 )                     ! NLC range (m_WmaxLEP2,m_WmaxNLC)
*//////////////////////////////////////////////////////////////////////////////
* EW formfactors, all flavours!!
      DOUBLE COMPLEX     m_cyy,     m_czz,     m_ctt,    m_clc   ! Electroweak FFactors
      DOUBLE PRECISION   m_syy,     m_szz,     m_stt,    m_slc   ! QCD corr.
      DOUBLE COMPLEX     m_GSW
      DOUBLE PRECISION   m_QCDcor   ! obsolete
      DOUBLE PRECISION   m_QCDcorR
*//////////////////////////////////////////////////////////////////////////////
* EW parameters
      DOUBLE PRECISION   m_Gmu
      DOUBLE PRECISION   m_MZ,      m_amh,     m_amtop
      DOUBLE PRECISION   m_swsq,    m_gammz,   m_amw,    m_gammw
*
      DOUBLE PRECISION   m_CMSene,  m_XXXene,  m_HadMin, m_vvmin,  m_vvmax !
      DOUBLE PRECISION   m_AvMult,  m_YFSkon,  m_YFS_IR, m_alfinv, m_alfpi, m_Xenph !
      DOUBLE PRECISION   m_vv,      m_x1,      m_x2
      DOUBLE PRECISION   m_Qf,      m_T3f,     m_helic,  m_amferm, m_auxpar !
      DOUBLE PRECISION   m_gnanob
      INTEGER            m_IsGenerated, m_KFferm,  m_NCf
      INTEGER            m_KFini,       m_KeyINT,  m_KeyQCD
      INTEGER            m_KeyElw,      m_KeyZet,  m_KeyWtm
      INTEGER            m_out

      COMMON /c_BornV/
* Tables of EW formfactors
     $  m_cyy(m_poin1+1,          m_poinG,16), ! formfactor, table
     $  m_czz(m_poin2+1,m_poTh2+1,m_poinG,16), ! formfactor, table
     $  m_ctt(m_poin3+1,m_poTh3+1,m_poinG,16), ! formfactor, table, costheta dependent
     $  m_clc(m_poin4+1,m_poTh4+1,m_poinG,16), ! formfactor, table, costheta dependent
     $  m_syy(m_poin1+1,          m_poinQ,16), ! QCD correction,
     $  m_szz(m_poin2+1,          m_poinQ,16), ! QCD correction,
     $  m_stt(m_poin3+1,          m_poinQ,16), ! QCD correction,
     $  m_slc(m_poin3+1,          m_poinQ,16), ! QCD correction,
     $  m_GSW(    m_poinG),                    ! form-factors,   at the actual energy/angle
     $  m_QCDcorR(m_poinQ),                    ! QCD correction, at the actual energy/angle
     $  m_QCDcor,                              ! obsolete!!!!
*
     $  m_CMSene,                       ! Initial value of CMS energy
     $  m_XXXene,                       ! CMS energy after beamsstrahlung or beam spread
* -------------------- EVENT --------------------------
     $  m_x1,                           ! 1-z1 = x1 for first  beam(strahlung)
     $  m_x2,                           ! 1-z2 = x2 for second beam(strahlung)
     $  m_vv,                           ! v = 1-sprim/s
     $  m_AvMult,                       ! Average photon multiplicity CRude at given v
     $  m_YFSkon,                       ! YFS formfactor finite part
     $  m_YFS_IR,                       ! YFS formfactor IR part
* -----------------------------------------------------
     $  m_vvmin,                        ! minimum v, infrared cut
     $  m_vvmax,                        ! maximum v
     $  m_HadMin,                       ! minimum hadronization mass [GeV]
* Basic QED and QCD
     $  m_alfinv,                       ! 1/alphaQED, Thomson limit (Q^2=0)
     $  m_alfpi,                        ! alphaQED/pi
     $  m_Xenph,                        ! Enhancement factor for Crude photon multiplicity
* EW parameters
     $  m_MZ,                           ! Z mass
     $  m_amh,                          ! Higgs mass
     $  m_amtop,                        ! Top mass
     $  m_swsq,                         ! sin(thetaW)**2
     $  m_gammz,                        ! Z width
     $  m_amw,                          ! W mass
     $  m_gammw,                        ! W width
     $  m_Gmu,                          ! Fermi constant (from muon decay)
* Table of fermion paramerets, quarks (1->6) and leptons (11->16)
     $  m_KFferm(20),                   ! fermion KFcode (1->6) and (11->16)
     $  m_NCf(20),                      ! number of colours
     $  m_Qf(20),                       ! electric charge
     $  m_T3f(20),                      ! isospin, L-hand component
     $  m_helic(20),                    ! helicity or polarization
     $  m_amferm(20),                   ! fermion mass
     $  m_auxpar(20),                   ! auxiliary parameter
     $  m_IsGenerated(20),              ! Generation flag, only for SAN !!! 
* Normalization
     $  m_gnanob,                       ! GeV^(-2) to nanobarns
* Initial/final fermion types
     $  m_KFini,                        ! KF code of beam
* Test switches
     $  m_KeyQCD,                       ! QCD FSR corr. switch
     $  m_KeyINT,                       ! ISR/FSR INTereference switch
     $  m_KeyElw,                       ! Type of Electrowak Library
     $  m_KeyZet,                       ! Z-boson on/off
     $  m_KeyWtm,                       ! Photon emission without mass terms
     $  m_out                           ! output unit for printouts
      SAVE /c_BornV/
*
* Formats for writing EW tables onto disk file.
      CHARACTER*80  m_fmt0, m_fmt1, m_fmt2
      PARAMETER (
     $  m_fmt0 ='(4g20.13)',                      ! Mz,Mt,Mh etc.
     $  m_fmt1 ='( a,  i4,  f10.5, i4,  f10.5 )', ! header
     $  m_fmt2 ='(6g13.7)'   )                    ! complex formfactors
*
*  Class procedures:
*
*//////////////////////////////////////////////////////////////////////////////
*//                                                                          //
*//                      End of CLASS  BornV                                 //
*//////////////////////////////////////////////////////////////////////////////

C      INCLUDE 'DZface.h'
*//////////////////////////////////////////////////////////////////////////////
*//                                                                          //
*//                     Pseudo-CLASS  DZface                                 //
*//   This  class is inheritance from class BornV                            //
*//   BornV.h  header is included in all routines                            //
*//                                                                          //
*//                                                                          //
*//   Purpose: Calculates Electroweak formfactor from Dizet                  //
*//            Writes the on the disk                                        //
*//////////////////////////////////////////////////////////////////////////////
*
*  Class members:
      DOUBLE PRECISION   m_alfinvMZ, m_alfQCDMZ
      INTEGER            m_KFfin
      INTEGER            m_IVini,   m_IVfin
      INTEGER            m_ibox
*//////////////////////////////////////////////////////////////////////////////
      COMMON /c_DZface/
     $  m_alfinvMZ,                     ! 1/alphaQED at (Q^2=MZ^2)     DIZET
     $  m_alfQCDMZ,                     ! alphaQCD   at (Q^2=MZ^2)     DIZET
*
     $  m_KFfin,                        ! KF code of final fermion     DIZET
     $  m_IVini,                        ! vertical id of initial ferm. DIZET
     $  m_IVfin,                        ! vertical id of   final ferm. DIZET
     $  m_ibox                          ! EW boxes on/off              DIZET
*
*  Class procedures:
*
*//////////////////////////////////////////////////////////////////////////////
*//                                                                          //
*//                      End of CLASS  DZface                                //
*//////////////////////////////////////////////////////////////////////////////
      CHARACTER*(*) DiskFile
      INTEGER KFfin
*--------------------------------------------------------------------
      DOUBLE PRECISION  ww,cosi,gammz1,gammw1,amzD
      INTEGER           KFf,i,j,k,ndisk
*--------------------------------------------------------------------
      KFf = ABS(m_KFfin)
      IF( KFf.LT.1 .OR. KFf.GT.16 ) THEN
         WRITE(m_out,*) '+++ DZface_WriteFile: wrong KFf= ', KFf
         WRITE(    6,*) '+++ DZface_WriteFile: wrong KFf= ', KFf
         STOP
      ENDIF
      WRITE(6 ,*) 'DZface_WriteFile: Tables are Written to DiskFile ',DiskFile !
* Note that m_MZ m_amh, m_amtop are already defined.
* We get other params out of dizet using DZface_GetPrm.
      CALL DZface_GetPrm( amzD,m_gammz,gammz1,m_amw,m_gammw,gammw1,m_swsq) !
      ndisk=21
      OPEN(ndisk,FILE=DiskFile)
      WRITE(ndisk,m_fmt0) m_MZ, m_amh, m_amtop, m_swsq, m_gammz, m_amw, m_gammw ! header
*/////////////////////////////////////////////////////////////////
*//   basic s range LEP1 and below        m_cyy(m_poin1+1, 7)   //
*/////////////////////////////////////////////////////////////////
      DO i=0, m_poin1
         ww = m_WminLEP1 *(m_WmaxLEP1/m_WminLEP1)**(DFLOAT(i)/DFLOAT(m_poin1)) !
         WRITE(ndisk,m_fmt1) 'a',i,ww
         WRITE(ndisk,m_fmt2) (m_cyy(i+1,k,KFf),k=1,m_poinG) ! EW
         WRITE(ndisk,m_fmt2) (m_syy(i+1,k,KFf),k=1,m_poinQ) ! QCD
      ENDDO
*/////////////////////////////////////////////////////////////////
*/              near Z0 resonance    m_czz(m_poin2+1, 7)        //
*/////////////////////////////////////////////////////////////////
      m_WminZ =m_MZ-m_WdelZ
      m_WmaxZ =m_MZ+m_WdelZ
      DO i=0,m_poin2
         ww = m_WminZ +(m_WmaxZ-m_WminZ)*(DFLOAT(i)/DFLOAT(m_poin2))
         DO  j=0,m_poTh2
            WRITE(ndisk,m_fmt1) 'b',i,ww,j
            WRITE(ndisk,m_fmt2) (m_czz(i+1,j+1,k,KFf),k=1,m_poinG) ! EW
         ENDDO
         WRITE(ndisk,m_fmt2) (m_szz(i+1,k,KFf),k=1,m_poinQ) ! QCD
      ENDDO
*/////////////////////////////////////////////////////////////////////
*//   the region of boxes, LEP2,   m_ctt(m_poin3+1, m_poTh3+1, 7)   //
*/////////////////////////////////////////////////////////////////////
      DO  i=0,m_poin3
         ww = m_WmaxLEP1 +(m_WmaxLEP2-m_WmaxLEP1)*(DFLOAT(i)/DFLOAT(m_poin3)) !
         DO  j=0,m_poTh3
            cosi = ( -1d0+2d0*DFLOAT(j)/DFLOAT(m_poTh3) )*(1d0-1d-8)
            IF(j  .EQ.        0) cosi=cosi+.3d0/DFLOAT(m_poTh3)
            IF(j  .EQ.  m_poTh3) cosi=cosi-.3d0/DFLOAT(m_poTh3)
            WRITE(ndisk,m_fmt1) 'c',i,ww,j,cosi
            WRITE(ndisk,m_fmt2) (m_ctt(i+1,j+1,k,KFf),k=1,m_poinG) ! EW
         ENDDO
         WRITE(   ndisk,m_fmt2) (m_stt(i+1,k,KFf),k=1,m_poinQ) ! QCD
      ENDDO
*/////////////////////////////////////////////////////////////////////
*//   the region of boxes, NLC,    m_clc(m_poin4+1, m_poTh4+1, 7)   //
*/////////////////////////////////////////////////////////////////////
      DO  i=0,m_poin4
         ww  = m_WmaxLEP2+(m_WmaxNLC-m_WmaxLEP2)*(DFLOAT(i)/DFLOAT(m_poin4)) !
         DO  j=0,m_poTh4
            cosi = ( -1d0+2d0*DFLOAT(j)/DFLOAT(m_poTh4) )*(1d0-1d-8)
            IF(j  .EQ.        0) cosi=cosi+.3d0/DFLOAT(m_poTh4)
            IF(j  .EQ.  m_poTh4) cosi=cosi-.3d0/DFLOAT(m_poTh4)
            WRITE(ndisk,m_fmt1) 'd',i,ww,j,cosi
            WRITE(ndisk,m_fmt2) (m_clc(i+1,j+1,k,KFf),k=1,m_poinG) ! EW
         ENDDO
         WRITE(   ndisk,m_fmt2) (m_slc(i+1,k,KFf),k=1,m_poinQ) ! QCD
      ENDDO
      CLOSE(ndisk)
      WRITE(m_out,*) 'DZface_WriteFile: finished  now !!!'
      WRITE(6    ,*) 'DZface_WriteFile: finished  now !!!'
      END                       ! DZface_WriteFile

      SUBROUTINE DZface_MakeGSW(iBox,ww,cosi,GSW,QCDcorR)
*/////////////////////////////////////////////////////////////////////////
*//   gets EWK FFactors and QCD corr. out of Dizet, at ww and theta     //
*//   Prior Dizet initialization is necesary!!!                         //
*//   Used in Tabluj and also in program testing tables                 //
*/////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
C      INCLUDE '../bornv/BornV.h'
*//////////////////////////////////////////////////////////////////////////////
*//                                                                          //
*//                     Pseudo-CLASS  BornV                                  //
*//                                                                          //
*//  Purpose:                                                                //
*//  Provide Born angular distribution and integrated x-section              //
*//  as a function of s.                                                     //
*//                                                                          //
*//  NOTES:                                                                  //
*//  How to eliminate nneut? This will come in a natural way                 //
*//  when neutrino type is generated.                                        //
*//  NB. Zbyszek says that weight dispersion might worsen!                   //
*//                                                                          //
*//////////////////////////////////////////////////////////////////////////////
*
*  Class members:
*
*//////////////////////////////////////////////////////////////////////////////
      DOUBLE PRECISION   m_pi
      PARAMETER         (m_pi =3.1415926535897932d0)
      DOUBLE PRECISION   m_fleps
****  PARAMETER (m_fleps = 1d-35)  ! original
****  PARAMETER (m_fleps = 1d-45)  ! enough???
      PARAMETER (m_fleps = 1d-100)  ! enough!!!
****      PARAMETER (m_fleps = 1d-200)  ! enough!!!
*//////////////////////////////////////////////////////////////////////////////
*//       Energy limits in the EW grid, w=sqrt(s) in GeV units.              //
*//////////////////////////////////////////////////////////////////////////////
*     340-point grid, only 80pt for NLC to be improved/tested in future
      INTEGER           m_poin1, m_poin2, m_poin3, m_poin4, m_poinG , m_poinQ !
      INTEGER           m_poTh1, m_poTh2, m_poTh3, m_poTh4
      PARAMETER(        m_poinG =   7 )                      ! No of EW formfactors
      PARAMETER(        m_poinQ =   4 )                      ! No of QCD corrections
*----------- Low energies and LEP1
      PARAMETER(        m_poin1 = 120 )                              ! LEP1 basic range sqrt(s)    spacing
cc      PARAMETER(        m_poin1 = 96 )                              ! LEP1 basic range sqrt(s)    spacing
      PARAMETER(        m_poTh1 =   0 )                              ! Cost(heta) spacing
      DOUBLE PRECISION  m_WminLEP1,          m_WmaxLEP1              ! LEP1 basic range (m_WminLEP1,m_WmaxLEP1)
      PARAMETER(        m_WminLEP1=0.010d0,  m_WmaxLEP1=100.001d0 )  ! LEP1 basic range (m_WminLEP1,m_WmaxLEP1)
***   PARAMETER(        m_WminLEP1=0.010d0,  m_WmaxLEP1=120.001d0 )  ! as in KORALZ, also enough
*----------- Z resonance
      PARAMETER(        m_poin2 =  20 )                              ! Z range sqrt(s)    spacing
      PARAMETER(        m_poTh2 =   0 )                              ! Cost(heta) spacing
***   PARAMETER(        m_poTh2 =  14 )                              ! =14 is overkill
      DOUBLE PRECISION  m_WminZ, m_WmaxZ, m_WdelZ                    ! Z range (amz + m_WdelZ)
      PARAMETER(        m_WdelZ = 5.000d0)                           ! Z range (amz + m_WdelZ)
***   PARAMETER(        m_WdelZ = 2d0 *2.495342704946d0)             ! Old range 2*Gamma
*----------- LEP2
      PARAMETER(        m_poTh3 =  30 )                              ! Overkill, bit lets kkep it
***   PARAMETER(        m_poTh3 =  14 )                              ! Cost(heta) spacing
      PARAMETER(        m_poin3 = 140 )                              ! LEP2 interval sqrt(s)    spacing
***   PARAMETER(        m_poin3 = 120 )                              ! as in KORALZ, also enough
      DOUBLE PRECISION  m_WmaxLEP2                                   ! LEP2 interval (m_WmaxLEP1,m_WmaxLEP2)
      PARAMETER(        m_WmaxLEP2  =240.001d0 )                     ! LEP2 interval (m_WmaxLEP1,m_WmaxLEP2)
*----------- Linear Colliders
      PARAMETER(        m_poin4 =  80 )                              ! NLC range sqrt(s)    spacing
      PARAMETER(        m_poTh4 =  14 )                              ! Cost(heta) spacing
      DOUBLE PRECISION  m_WmaxNLC                                    ! NLC range (m_WmaxLEP2,m_WmaxNLC)
      PARAMETER(        m_WmaxNLC  =1040.001d0 )                     ! NLC range (m_WmaxLEP2,m_WmaxNLC)
*//////////////////////////////////////////////////////////////////////////////
* EW formfactors, all flavours!!
      DOUBLE COMPLEX     m_cyy,     m_czz,     m_ctt,    m_clc   ! Electroweak FFactors
      DOUBLE PRECISION   m_syy,     m_szz,     m_stt,    m_slc   ! QCD corr.
      DOUBLE COMPLEX     m_GSW
      DOUBLE PRECISION   m_QCDcor   ! obsolete
      DOUBLE PRECISION   m_QCDcorR
*//////////////////////////////////////////////////////////////////////////////
* EW parameters
      DOUBLE PRECISION   m_Gmu
      DOUBLE PRECISION   m_MZ,      m_amh,     m_amtop
      DOUBLE PRECISION   m_swsq,    m_gammz,   m_amw,    m_gammw
*
      DOUBLE PRECISION   m_CMSene,  m_XXXene,  m_HadMin, m_vvmin,  m_vvmax !
      DOUBLE PRECISION   m_AvMult,  m_YFSkon,  m_YFS_IR, m_alfinv, m_alfpi, m_Xenph !
      DOUBLE PRECISION   m_vv,      m_x1,      m_x2
      DOUBLE PRECISION   m_Qf,      m_T3f,     m_helic,  m_amferm, m_auxpar !
      DOUBLE PRECISION   m_gnanob
      INTEGER            m_IsGenerated, m_KFferm,  m_NCf
      INTEGER            m_KFini,       m_KeyINT,  m_KeyQCD
      INTEGER            m_KeyElw,      m_KeyZet,  m_KeyWtm
      INTEGER            m_out

      COMMON /c_BornV/
* Tables of EW formfactors
     $  m_cyy(m_poin1+1,          m_poinG,16), ! formfactor, table
     $  m_czz(m_poin2+1,m_poTh2+1,m_poinG,16), ! formfactor, table
     $  m_ctt(m_poin3+1,m_poTh3+1,m_poinG,16), ! formfactor, table, costheta dependent
     $  m_clc(m_poin4+1,m_poTh4+1,m_poinG,16), ! formfactor, table, costheta dependent
     $  m_syy(m_poin1+1,          m_poinQ,16), ! QCD correction,
     $  m_szz(m_poin2+1,          m_poinQ,16), ! QCD correction,
     $  m_stt(m_poin3+1,          m_poinQ,16), ! QCD correction,
     $  m_slc(m_poin3+1,          m_poinQ,16), ! QCD correction,
     $  m_GSW(    m_poinG),                    ! form-factors,   at the actual energy/angle
     $  m_QCDcorR(m_poinQ),                    ! QCD correction, at the actual energy/angle
     $  m_QCDcor,                              ! obsolete!!!!
*
     $  m_CMSene,                       ! Initial value of CMS energy
     $  m_XXXene,                       ! CMS energy after beamsstrahlung or beam spread
* -------------------- EVENT --------------------------
     $  m_x1,                           ! 1-z1 = x1 for first  beam(strahlung)
     $  m_x2,                           ! 1-z2 = x2 for second beam(strahlung)
     $  m_vv,                           ! v = 1-sprim/s
     $  m_AvMult,                       ! Average photon multiplicity CRude at given v
     $  m_YFSkon,                       ! YFS formfactor finite part
     $  m_YFS_IR,                       ! YFS formfactor IR part
* -----------------------------------------------------
     $  m_vvmin,                        ! minimum v, infrared cut
     $  m_vvmax,                        ! maximum v
     $  m_HadMin,                       ! minimum hadronization mass [GeV]
* Basic QED and QCD
     $  m_alfinv,                       ! 1/alphaQED, Thomson limit (Q^2=0)
     $  m_alfpi,                        ! alphaQED/pi
     $  m_Xenph,                        ! Enhancement factor for Crude photon multiplicity
* EW parameters
     $  m_MZ,                           ! Z mass
     $  m_amh,                          ! Higgs mass
     $  m_amtop,                        ! Top mass
     $  m_swsq,                         ! sin(thetaW)**2
     $  m_gammz,                        ! Z width
     $  m_amw,                          ! W mass
     $  m_gammw,                        ! W width
     $  m_Gmu,                          ! Fermi constant (from muon decay)
* Table of fermion paramerets, quarks (1->6) and leptons (11->16)
     $  m_KFferm(20),                   ! fermion KFcode (1->6) and (11->16)
     $  m_NCf(20),                      ! number of colours
     $  m_Qf(20),                       ! electric charge
     $  m_T3f(20),                      ! isospin, L-hand component
     $  m_helic(20),                    ! helicity or polarization
     $  m_amferm(20),                   ! fermion mass
     $  m_auxpar(20),                   ! auxiliary parameter
     $  m_IsGenerated(20),              ! Generation flag, only for SAN !!! 
* Normalization
     $  m_gnanob,                       ! GeV^(-2) to nanobarns
* Initial/final fermion types
     $  m_KFini,                        ! KF code of beam
* Test switches
     $  m_KeyQCD,                       ! QCD FSR corr. switch
     $  m_KeyINT,                       ! ISR/FSR INTereference switch
     $  m_KeyElw,                       ! Type of Electrowak Library
     $  m_KeyZet,                       ! Z-boson on/off
     $  m_KeyWtm,                       ! Photon emission without mass terms
     $  m_out                           ! output unit for printouts
      SAVE /c_BornV/
*
* Formats for writing EW tables onto disk file.
      CHARACTER*80  m_fmt0, m_fmt1, m_fmt2
      PARAMETER (
     $  m_fmt0 ='(4g20.13)',                      ! Mz,Mt,Mh etc.
     $  m_fmt1 ='( a,  i4,  f10.5, i4,  f10.5 )', ! header
     $  m_fmt2 ='(6g13.7)'   )                    ! complex formfactors
*
*  Class procedures:
*
*//////////////////////////////////////////////////////////////////////////////
*//                                                                          //
*//                      End of CLASS  BornV                                 //
*//////////////////////////////////////////////////////////////////////////////

C      INCLUDE 'DZface.h'
*//////////////////////////////////////////////////////////////////////////////
*//                                                                          //
*//                     Pseudo-CLASS  DZface                                 //
*//   This  class is inheritance from class BornV                            //
*//   BornV.h  header is included in all routines                            //
*//                                                                          //
*//                                                                          //
*//   Purpose: Calculates Electroweak formfactor from Dizet                  //
*//            Writes the on the disk                                        //
*//////////////////////////////////////////////////////////////////////////////
*
*  Class members:
      DOUBLE PRECISION   m_alfinvMZ, m_alfQCDMZ
      INTEGER            m_KFfin
      INTEGER            m_IVini,   m_IVfin
      INTEGER            m_ibox
*//////////////////////////////////////////////////////////////////////////////
      COMMON /c_DZface/
     $  m_alfinvMZ,                     ! 1/alphaQED at (Q^2=MZ^2)     DIZET
     $  m_alfQCDMZ,                     ! alphaQCD   at (Q^2=MZ^2)     DIZET
*
     $  m_KFfin,                        ! KF code of final fermion     DIZET
     $  m_IVini,                        ! vertical id of initial ferm. DIZET
     $  m_IVfin,                        ! vertical id of   final ferm. DIZET
     $  m_ibox                          ! EW boxes on/off              DIZET
*
*  Class procedures:
*
*//////////////////////////////////////////////////////////////////////////////
*//                                                                          //
*//                      End of CLASS  DZface                                //
*//////////////////////////////////////////////////////////////////////////////
      INTEGER           iBox
      DOUBLE COMPLEX    GSW(*)
      DOUBLE PRECISION  ww,cosi,QCDcorR(*)
      DOUBLE PRECISION  QCDcorD(0:14)
      DOUBLE COMPLEX    xff(4),xfem,xfota
      INTEGER           i,j,kk,k,kdumm,kolor,ibfla,KFf
      DOUBLE PRECISION  ss,uu,tt,aizor,qe,qf,dum1,dum2
      SAVE
*     ---------------------------------------------------
      IF(    iBox.EQ.-1) THEN
         IF ( ABS(m_KFfin)  .EQ.  5) THEN
            ibfla=1
         ELSE
            ibfla=0
         ENDIF
         CALL DZface_GivIzo( m_IVini, 1,aizor,qe,kdumm)
         CALL DZface_GivIzo( m_IVfin, 1,aizor,qf,kolor)
         DO k=1,m_poinG
            m_GSW(k) =0d0
         ENDDO
      ELSEIF( iBox.EQ.0 .OR. iBox.EQ.1) THEN
         ss  = ww*ww
         tt  = ss*(1d0-cosi)/2d0
         uu  = ss*(1d0+cosi)/2d0
         CALL rokanc( iBox,ibfla,-uu,-ss,-tt,qe,qf,xff,xfem,xfota) ! check signs of s,u,t!!!
         CALL DZface_MakeQCDcor(ww,QCDcorD)
         DO  kk=1,4
            GSW(kk)=xff(kk)
         ENDDO
         GSW(5 )=123.456d0 ! UNUSED!!!!
         GSW(6 )=xfem
         GSW(7 )=xfota
         GSW(8 )=QCDcorD(1)-1d0     !  obsolete!!! test of pretabulation,may be replace with alpha_s???
* translate QCD R-factors and corrections
         QCDcorR(1) = 1d0
         QCDcorR(2) = 1d0
         QCDcorR(3) = 0d0
         QCDcorR(4) = 0d0
         KFf = ABS(m_KFfin)
         IF(     KFf .EQ. 1 ) THEN
            QCDcorR(1) = QCDcorD(3)  ! D quark, R Vector
            QCDcorR(2) = QCDcorD(4)  ! D quark, R Axial
            QCDcorR(3) = QCDcorD(13) ! singlet
            QCDcorR(4) = QCDcorD(14) ! f_1
         ELSEIF( KFf .EQ. 2 ) THEN
            QCDcorR(1) = QCDcorD(1)  ! U quark, R Vector
            QCDcorR(2) = QCDcorD(2)  ! U quark, R Axial
            QCDcorR(3) = QCDcorD(13) ! singlet
            QCDcorR(4) = QCDcorD(14) ! f_1
         ELSEIF( KFf .EQ. 3 ) THEN
            QCDcorR(1) = QCDcorD(7)  ! S quark, R Vector
            QCDcorR(2) = QCDcorD(8)  ! S quark, R Axial
            QCDcorR(3) = QCDcorD(13) ! singlet
            QCDcorR(4) = QCDcorD(14) ! f_1
         ELSEIF( KFf .EQ. 4 ) THEN
            QCDcorR(1) = QCDcorD(5)  ! C quark, R Vector
            QCDcorR(2) = QCDcorD(6)  ! C quark, R Axial
            QCDcorR(3) = QCDcorD(13) ! singlet
            QCDcorR(4) = QCDcorD(14) ! f_1
         ELSEIF( KFf .EQ. 5 ) THEN
            QCDcorR(1) = QCDcorD(11) ! B quark, R Vector
            QCDcorR(2) = QCDcorD(12) ! B quark, R Axial
            QCDcorR(3) = QCDcorD(13) ! singlet
            QCDcorR(4) = QCDcorD(14) ! f_1
         ENDIF
      ELSE
         WRITE(*,*) '++++ STOP in DZface_MakeGSW, wrong iBox =',iBox
         STOP
      ENDIF
      END

      SUBROUTINE DZface_GivIzo(idferm,ihelic,sizo3,charge,kolor)
* ----------------------------------------------------------------------
* Provides electric charge and weak izospin of a family fermion where
* idferm =           1,        2,        3,         4,
* denotes:    neutrino,   lepton,       up,      down   (quark)
* negative idferm=-1,-2,-3,-4, denotes corresponding antiparticle
* ihelic =     +1,  -1   denotes  right and left handednes ( chirality)
* sizo3 is third projection of weak izospin (plus minus half)
* and charge is electric charge in units of electron charge
* kolor is a qcd colour, 1 for lepton, 3 for quarks
* ----------------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION (a-h,o-z)
*
      IF(idferm.EQ.0  .OR.  iabs(idferm).GT.4 ) GOTO 901
      IF(iabs(ihelic).NE.1)                     GOTO 901
      ih  =ihelic
      idtype =iabs(idferm)
      ic  =idferm/idtype
      lepqua=int(idtype*0.4999999d0)
      iupdow=idtype-2*lepqua-1
      charge  =(-iupdow+2d0/3d0*lepqua)*ic
      sizo3   =0.25d0*(ic-ih)*(1-2*iupdow)
      kolor=1+2*lepqua
* Note that conventionaly Z0 coupling is
* xoupz=(sizo3-charge*swsq)/sqrt(swsq*(1-swsq))
      RETURN
 901  print *,' STOP in DZface_GivIzo: wrong params.'
      STOP
      END


      SUBROUTINE DZface_GetPrm( zmass,gamz0,gamzf,wmass,gamw0,gamwf,sin2w)
*/////////////////////////////////////////////////////////////////////////
*//     Gets out params from Dizet common blocks
*/////////////////////////////////////////////////////////////////////////
      IMPLICIT DOUBLE PRECISION  (a-h,o-z)
      COMMON /cdzzwg/camz,camh,gmu,a0,gamz,gamw,calsz,calst,calxi,calqed
      COMMON /cdzwsm/amw2,amz2,r,r1,r12,r2,amh2,rw,rw1,rw12,rw2,rz,rz1,
     $               rz12,rz2,alr,alrw,alrz,sw2m,cw2m,aksx,r1w,r1w2
*     -------------------------------------------------------------
      sin2w = r1
      wmass = SQRT(amw2)
      zmass = wmass/SQRT(1d0-sin2w)
      gamw0 = gamw
      gamz0 = gamz
      END

      SUBROUTINE DZface_MakeQCDcor(ww,QCDcor)
*/////////////////////////////////////////////////////////////////////////
      IMPLICIT NONE
C      INCLUDE '../bornv/BornV.h'
*//////////////////////////////////////////////////////////////////////////////
*//                                                                          //
*//                     Pseudo-CLASS  BornV                                  //
*//                                                                          //
*//  Purpose:                                                                //
*//  Provide Born angular distribution and integrated x-section              //
*//  as a function of s.                                                     //
*//                                                                          //
*//  NOTES:                                                                  //
*//  How to eliminate nneut? This will come in a natural way                 //
*//  when neutrino type is generated.                                        //
*//  NB. Zbyszek says that weight dispersion might worsen!                   //
*//                                                                          //
*//////////////////////////////////////////////////////////////////////////////
*
*  Class members:
*
*//////////////////////////////////////////////////////////////////////////////
      DOUBLE PRECISION   m_pi
      PARAMETER         (m_pi =3.1415926535897932d0)
      DOUBLE PRECISION   m_fleps
****  PARAMETER (m_fleps = 1d-35)  ! original
****  PARAMETER (m_fleps = 1d-45)  ! enough???
      PARAMETER (m_fleps = 1d-100)  ! enough!!!
****      PARAMETER (m_fleps = 1d-200)  ! enough!!!
*//////////////////////////////////////////////////////////////////////////////
*//       Energy limits in the EW grid, w=sqrt(s) in GeV units.              //
*//////////////////////////////////////////////////////////////////////////////
*     340-point grid, only 80pt for NLC to be improved/tested in future
      INTEGER           m_poin1, m_poin2, m_poin3, m_poin4, m_poinG , m_poinQ !
      INTEGER           m_poTh1, m_poTh2, m_poTh3, m_poTh4
      PARAMETER(        m_poinG =   7 )                      ! No of EW formfactors
      PARAMETER(        m_poinQ =   4 )                      ! No of QCD corrections
*----------- Low energies and LEP1
      PARAMETER(        m_poin1 = 120 )                              ! LEP1 basic range sqrt(s)    spacing
cc      PARAMETER(        m_poin1 = 96 )                              ! LEP1 basic range sqrt(s)    spacing
      PARAMETER(        m_poTh1 =   0 )                              ! Cost(heta) spacing
      DOUBLE PRECISION  m_WminLEP1,          m_WmaxLEP1              ! LEP1 basic range (m_WminLEP1,m_WmaxLEP1)
      PARAMETER(        m_WminLEP1=0.010d0,  m_WmaxLEP1=100.001d0 )  ! LEP1 basic range (m_WminLEP1,m_WmaxLEP1)
***   PARAMETER(        m_WminLEP1=0.010d0,  m_WmaxLEP1=120.001d0 )  ! as in KORALZ, also enough
*----------- Z resonance
      PARAMETER(        m_poin2 =  20 )                              ! Z range sqrt(s)    spacing
      PARAMETER(        m_poTh2 =   0 )                              ! Cost(heta) spacing
***   PARAMETER(        m_poTh2 =  14 )                              ! =14 is overkill
      DOUBLE PRECISION  m_WminZ, m_WmaxZ, m_WdelZ                    ! Z range (amz + m_WdelZ)
      PARAMETER(        m_WdelZ = 5.000d0)                           ! Z range (amz + m_WdelZ)
***   PARAMETER(        m_WdelZ = 2d0 *2.495342704946d0)             ! Old range 2*Gamma
*----------- LEP2
      PARAMETER(        m_poTh3 =  30 )                              ! Overkill, bit lets kkep it
***   PARAMETER(        m_poTh3 =  14 )                              ! Cost(heta) spacing
      PARAMETER(        m_poin3 = 140 )                              ! LEP2 interval sqrt(s)    spacing
***   PARAMETER(        m_poin3 = 120 )                              ! as in KORALZ, also enough
      DOUBLE PRECISION  m_WmaxLEP2                                   ! LEP2 interval (m_WmaxLEP1,m_WmaxLEP2)
      PARAMETER(        m_WmaxLEP2  =240.001d0 )                     ! LEP2 interval (m_WmaxLEP1,m_WmaxLEP2)
*----------- Linear Colliders
      PARAMETER(        m_poin4 =  80 )                              ! NLC range sqrt(s)    spacing
      PARAMETER(        m_poTh4 =  14 )                              ! Cost(heta) spacing
      DOUBLE PRECISION  m_WmaxNLC                                    ! NLC range (m_WmaxLEP2,m_WmaxNLC)
      PARAMETER(        m_WmaxNLC  =1040.001d0 )                     ! NLC range (m_WmaxLEP2,m_WmaxNLC)
*//////////////////////////////////////////////////////////////////////////////
* EW formfactors, all flavours!!
      DOUBLE COMPLEX     m_cyy,     m_czz,     m_ctt,    m_clc   ! Electroweak FFactors
      DOUBLE PRECISION   m_syy,     m_szz,     m_stt,    m_slc   ! QCD corr.
      DOUBLE COMPLEX     m_GSW
      DOUBLE PRECISION   m_QCDcor   ! obsolete
      DOUBLE PRECISION   m_QCDcorR
*//////////////////////////////////////////////////////////////////////////////
* EW parameters
      DOUBLE PRECISION   m_Gmu
      DOUBLE PRECISION   m_MZ,      m_amh,     m_amtop
      DOUBLE PRECISION   m_swsq,    m_gammz,   m_amw,    m_gammw
*
      DOUBLE PRECISION   m_CMSene,  m_XXXene,  m_HadMin, m_vvmin,  m_vvmax !
      DOUBLE PRECISION   m_AvMult,  m_YFSkon,  m_YFS_IR, m_alfinv, m_alfpi, m_Xenph !
      DOUBLE PRECISION   m_vv,      m_x1,      m_x2
      DOUBLE PRECISION   m_Qf,      m_T3f,     m_helic,  m_amferm, m_auxpar !
      DOUBLE PRECISION   m_gnanob
      INTEGER            m_IsGenerated, m_KFferm,  m_NCf
      INTEGER            m_KFini,       m_KeyINT,  m_KeyQCD
      INTEGER            m_KeyElw,      m_KeyZet,  m_KeyWtm
      INTEGER            m_out

      COMMON /c_BornV/
* Tables of EW formfactors
     $  m_cyy(m_poin1+1,          m_poinG,16), ! formfactor, table
     $  m_czz(m_poin2+1,m_poTh2+1,m_poinG,16), ! formfactor, table
     $  m_ctt(m_poin3+1,m_poTh3+1,m_poinG,16), ! formfactor, table, costheta dependent
     $  m_clc(m_poin4+1,m_poTh4+1,m_poinG,16), ! formfactor, table, costheta dependent
     $  m_syy(m_poin1+1,          m_poinQ,16), ! QCD correction,
     $  m_szz(m_poin2+1,          m_poinQ,16), ! QCD correction,
     $  m_stt(m_poin3+1,          m_poinQ,16), ! QCD correction,
     $  m_slc(m_poin3+1,          m_poinQ,16), ! QCD correction,
     $  m_GSW(    m_poinG),                    ! form-factors,   at the actual energy/angle
     $  m_QCDcorR(m_poinQ),                    ! QCD correction, at the actual energy/angle
     $  m_QCDcor,                              ! obsolete!!!!
*
     $  m_CMSene,                       ! Initial value of CMS energy
     $  m_XXXene,                       ! CMS energy after beamsstrahlung or beam spread
* -------------------- EVENT --------------------------
     $  m_x1,                           ! 1-z1 = x1 for first  beam(strahlung)
     $  m_x2,                           ! 1-z2 = x2 for second beam(strahlung)
     $  m_vv,                           ! v = 1-sprim/s
     $  m_AvMult,                       ! Average photon multiplicity CRude at given v
     $  m_YFSkon,                       ! YFS formfactor finite part
     $  m_YFS_IR,                       ! YFS formfactor IR part
* -----------------------------------------------------
     $  m_vvmin,                        ! minimum v, infrared cut
     $  m_vvmax,                        ! maximum v
     $  m_HadMin,                       ! minimum hadronization mass [GeV]
* Basic QED and QCD
     $  m_alfinv,                       ! 1/alphaQED, Thomson limit (Q^2=0)
     $  m_alfpi,                        ! alphaQED/pi
     $  m_Xenph,                        ! Enhancement factor for Crude photon multiplicity
* EW parameters
     $  m_MZ,                           ! Z mass
     $  m_amh,                          ! Higgs mass
     $  m_amtop,                        ! Top mass
     $  m_swsq,                         ! sin(thetaW)**2
     $  m_gammz,                        ! Z width
     $  m_amw,                          ! W mass
     $  m_gammw,                        ! W width
     $  m_Gmu,                          ! Fermi constant (from muon decay)
* Table of fermion paramerets, quarks (1->6) and leptons (11->16)
     $  m_KFferm(20),                   ! fermion KFcode (1->6) and (11->16)
     $  m_NCf(20),                      ! number of colours
     $  m_Qf(20),                       ! electric charge
     $  m_T3f(20),                      ! isospin, L-hand component
     $  m_helic(20),                    ! helicity or polarization
     $  m_amferm(20),                   ! fermion mass
     $  m_auxpar(20),                   ! auxiliary parameter
     $  m_IsGenerated(20),              ! Generation flag, only for SAN !!! 
* Normalization
     $  m_gnanob,                       ! GeV^(-2) to nanobarns
* Initial/final fermion types
     $  m_KFini,                        ! KF code of beam
* Test switches
     $  m_KeyQCD,                       ! QCD FSR corr. switch
     $  m_KeyINT,                       ! ISR/FSR INTereference switch
     $  m_KeyElw,                       ! Type of Electrowak Library
     $  m_KeyZet,                       ! Z-boson on/off
     $  m_KeyWtm,                       ! Photon emission without mass terms
     $  m_out                           ! output unit for printouts
      SAVE /c_BornV/
*
* Formats for writing EW tables onto disk file.
      CHARACTER*80  m_fmt0, m_fmt1, m_fmt2
      PARAMETER (
     $  m_fmt0 ='(4g20.13)',                      ! Mz,Mt,Mh etc.
     $  m_fmt1 ='( a,  i4,  f10.5, i4,  f10.5 )', ! header
     $  m_fmt2 ='(6g13.7)'   )                    ! complex formfactors
*
*  Class procedures:
*
*//////////////////////////////////////////////////////////////////////////////
*//                                                                          //
*//                      End of CLASS  BornV                                 //
*//////////////////////////////////////////////////////////////////////////////

C      INCLUDE 'DZface.h'
*//////////////////////////////////////////////////////////////////////////////
*//                                                                          //
*//                     Pseudo-CLASS  DZface                                 //
*//   This  class is inheritance from class BornV                            //
*//   BornV.h  header is included in all routines                            //
*//                                                                          //
*//                                                                          //
*//   Purpose: Calculates Electroweak formfactor from Dizet                  //
*//            Writes the on the disk                                        //
*//////////////////////////////////////////////////////////////////////////////
*
*  Class members:
      DOUBLE PRECISION   m_alfinvMZ, m_alfQCDMZ
      INTEGER            m_KFfin
      INTEGER            m_IVini,   m_IVfin
      INTEGER            m_ibox
*//////////////////////////////////////////////////////////////////////////////
      COMMON /c_DZface/
     $  m_alfinvMZ,                     ! 1/alphaQED at (Q^2=MZ^2)     DIZET
     $  m_alfQCDMZ,                     ! alphaQCD   at (Q^2=MZ^2)     DIZET
*
     $  m_KFfin,                        ! KF code of final fermion     DIZET
     $  m_IVini,                        ! vertical id of initial ferm. DIZET
     $  m_IVfin,                        ! vertical id of   final ferm. DIZET
     $  m_ibox                          ! EW boxes on/off              DIZET
*
*  Class procedures:
*
*//////////////////////////////////////////////////////////////////////////////
*//                                                                          //
*//                      End of CLASS  DZface                                //
*//////////////////////////////////////////////////////////////////////////////
      DOUBLE PRECISION ww, ene, AlfQED             ! Input
      DOUBLE PRECISION ALPHTT,ALPHXI, QCDcor(0:14) ! Output
      INTEGER  i,j,k
*     -------------------------------------------------------------
      ene     = MAX(ww,20d0)
      AlfQED  = 1d0/m_alfinvMZ
      CALL qcdcof(ene, m_amtop, m_swsq, AlfQED, m_alfQCDMZ, ALPHTT, ALPHXI, QCDcor) !
c[[[[[[[[[[[[[[
c      IF( ABS(ww-189d0).LT.0.1) 
c     $   WRITE(*,'(a,f15.6, 20f8.5)') '|||| ene,QCDcor= ',ene,(QCDcor(k),k=0,14) !
c]]]]]]]]]]]]]]
      END
*//////////////////////////////////////////////////////////////////////////////
*//                                                                          //
*//                      End of CLASS  DZface                                //
*//////////////////////////////////////////////////////////////////////////////
      SUBROUTINE BornV_StartEW(xpar_input)
*///////////////////////////////////////////////////////////////////
*//                                                               //
*//   Slow-start EW correction library                            //
*//   Here it is done by making forfactors from the scratch       //
*//                                                               //
*///////////////////////////////////////////////////////////////////
      IMPLICIT NONE
C      INCLUDE '../bornv/BornV.h'
*//////////////////////////////////////////////////////////////////////////////
*//                                                                          //
*//                     Pseudo-CLASS  BornV                                  //
*//                                                                          //
*//  Purpose:                                                                //
*//  Provide Born angular distribution and integrated x-section              //
*//  as a function of s.                                                     //
*//                                                                          //
*//  NOTES:                                                                  //
*//  How to eliminate nneut? This will come in a natural way                 //
*//  when neutrino type is generated.                                        //
*//  NB. Zbyszek says that weight dispersion might worsen!                   //
*//                                                                          //
*//////////////////////////////////////////////////////////////////////////////
*
*  Class members:
*
*//////////////////////////////////////////////////////////////////////////////
      DOUBLE PRECISION   m_pi
      PARAMETER         (m_pi =3.1415926535897932d0)
      DOUBLE PRECISION   m_fleps
****  PARAMETER (m_fleps = 1d-35)  ! original
****  PARAMETER (m_fleps = 1d-45)  ! enough???
      PARAMETER (m_fleps = 1d-100)  ! enough!!!
****      PARAMETER (m_fleps = 1d-200)  ! enough!!!
*//////////////////////////////////////////////////////////////////////////////
*//       Energy limits in the EW grid, w=sqrt(s) in GeV units.              //
*//////////////////////////////////////////////////////////////////////////////
*     340-point grid, only 80pt for NLC to be improved/tested in future
      INTEGER           m_poin1, m_poin2, m_poin3, m_poin4, m_poinG , m_poinQ !
      INTEGER           m_poTh1, m_poTh2, m_poTh3, m_poTh4
      PARAMETER(        m_poinG =   7 )                      ! No of EW formfactors
      PARAMETER(        m_poinQ =   4 )                      ! No of QCD corrections
*----------- Low energies and LEP1
      PARAMETER(        m_poin1 = 120 )                              ! LEP1 basic range sqrt(s)    spacing
cc      PARAMETER(        m_poin1 = 96 )                              ! LEP1 basic range sqrt(s)    spacing
      PARAMETER(        m_poTh1 =   0 )                              ! Cost(heta) spacing
      DOUBLE PRECISION  m_WminLEP1,          m_WmaxLEP1              ! LEP1 basic range (m_WminLEP1,m_WmaxLEP1)
      PARAMETER(        m_WminLEP1=0.010d0,  m_WmaxLEP1=100.001d0 )  ! LEP1 basic range (m_WminLEP1,m_WmaxLEP1)
***   PARAMETER(        m_WminLEP1=0.010d0,  m_WmaxLEP1=120.001d0 )  ! as in KORALZ, also enough
*----------- Z resonance
      PARAMETER(        m_poin2 =  20 )                              ! Z range sqrt(s)    spacing
      PARAMETER(        m_poTh2 =   0 )                              ! Cost(heta) spacing
***   PARAMETER(        m_poTh2 =  14 )                              ! =14 is overkill
      DOUBLE PRECISION  m_WminZ, m_WmaxZ, m_WdelZ                    ! Z range (amz + m_WdelZ)
      PARAMETER(        m_WdelZ = 5.000d0)                           ! Z range (amz + m_WdelZ)
***   PARAMETER(        m_WdelZ = 2d0 *2.495342704946d0)             ! Old range 2*Gamma
*----------- LEP2
      PARAMETER(        m_poTh3 =  30 )                              ! Overkill, bit lets kkep it
***   PARAMETER(        m_poTh3 =  14 )                              ! Cost(heta) spacing
      PARAMETER(        m_poin3 = 140 )                              ! LEP2 interval sqrt(s)    spacing
***   PARAMETER(        m_poin3 = 120 )                              ! as in KORALZ, also enough
      DOUBLE PRECISION  m_WmaxLEP2                                   ! LEP2 interval (m_WmaxLEP1,m_WmaxLEP2)
      PARAMETER(        m_WmaxLEP2  =240.001d0 )                     ! LEP2 interval (m_WmaxLEP1,m_WmaxLEP2)
*----------- Linear Colliders
      PARAMETER(        m_poin4 =  80 )                              ! NLC range sqrt(s)    spacing
      PARAMETER(        m_poTh4 =  14 )                              ! Cost(heta) spacing
      DOUBLE PRECISION  m_WmaxNLC                                    ! NLC range (m_WmaxLEP2,m_WmaxNLC)
      PARAMETER(        m_WmaxNLC  =1040.001d0 )                     ! NLC range (m_WmaxLEP2,m_WmaxNLC)
*//////////////////////////////////////////////////////////////////////////////
* EW formfactors, all flavours!!
      DOUBLE COMPLEX     m_cyy,     m_czz,     m_ctt,    m_clc   ! Electroweak FFactors
      DOUBLE PRECISION   m_syy,     m_szz,     m_stt,    m_slc   ! QCD corr.
      DOUBLE COMPLEX     m_GSW
      DOUBLE PRECISION   m_QCDcor   ! obsolete
      DOUBLE PRECISION   m_QCDcorR
*//////////////////////////////////////////////////////////////////////////////
* EW parameters
      DOUBLE PRECISION   m_Gmu
      DOUBLE PRECISION   m_MZ,      m_amh,     m_amtop
      DOUBLE PRECISION   m_swsq,    m_gammz,   m_amw,    m_gammw
*
      DOUBLE PRECISION   m_CMSene,  m_XXXene,  m_HadMin, m_vvmin,  m_vvmax !
      DOUBLE PRECISION   m_AvMult,  m_YFSkon,  m_YFS_IR, m_alfinv, m_alfpi, m_Xenph !
      DOUBLE PRECISION   m_vv,      m_x1,      m_x2
      DOUBLE PRECISION   m_Qf,      m_T3f,     m_helic,  m_amferm, m_auxpar !
      DOUBLE PRECISION   m_gnanob
      INTEGER            m_IsGenerated, m_KFferm,  m_NCf
      INTEGER            m_KFini,       m_KeyINT,  m_KeyQCD
      INTEGER            m_KeyElw,      m_KeyZet,  m_KeyWtm
      INTEGER            m_out

      COMMON /c_BornV/
* Tables of EW formfactors
     $  m_cyy(m_poin1+1,          m_poinG,16), ! formfactor, table
     $  m_czz(m_poin2+1,m_poTh2+1,m_poinG,16), ! formfactor, table
     $  m_ctt(m_poin3+1,m_poTh3+1,m_poinG,16), ! formfactor, table, costheta dependent
     $  m_clc(m_poin4+1,m_poTh4+1,m_poinG,16), ! formfactor, table, costheta dependent
     $  m_syy(m_poin1+1,          m_poinQ,16), ! QCD correction,
     $  m_szz(m_poin2+1,          m_poinQ,16), ! QCD correction,
     $  m_stt(m_poin3+1,          m_poinQ,16), ! QCD correction,
     $  m_slc(m_poin3+1,          m_poinQ,16), ! QCD correction,
     $  m_GSW(    m_poinG),                    ! form-factors,   at the actual energy/angle
     $  m_QCDcorR(m_poinQ),                    ! QCD correction, at the actual energy/angle
     $  m_QCDcor,                              ! obsolete!!!!
*
     $  m_CMSene,                       ! Initial value of CMS energy
     $  m_XXXene,                       ! CMS energy after beamsstrahlung or beam spread
* -------------------- EVENT --------------------------
     $  m_x1,                           ! 1-z1 = x1 for first  beam(strahlung)
     $  m_x2,                           ! 1-z2 = x2 for second beam(strahlung)
     $  m_vv,                           ! v = 1-sprim/s
     $  m_AvMult,                       ! Average photon multiplicity CRude at given v
     $  m_YFSkon,                       ! YFS formfactor finite part
     $  m_YFS_IR,                       ! YFS formfactor IR part
* -----------------------------------------------------
     $  m_vvmin,                        ! minimum v, infrared cut
     $  m_vvmax,                        ! maximum v
     $  m_HadMin,                       ! minimum hadronization mass [GeV]
* Basic QED and QCD
     $  m_alfinv,                       ! 1/alphaQED, Thomson limit (Q^2=0)
     $  m_alfpi,                        ! alphaQED/pi
     $  m_Xenph,                        ! Enhancement factor for Crude photon multiplicity
* EW parameters
     $  m_MZ,                           ! Z mass
     $  m_amh,                          ! Higgs mass
     $  m_amtop,                        ! Top mass
     $  m_swsq,                         ! sin(thetaW)**2
     $  m_gammz,                        ! Z width
     $  m_amw,                          ! W mass
     $  m_gammw,                        ! W width
     $  m_Gmu,                          ! Fermi constant (from muon decay)
* Table of fermion paramerets, quarks (1->6) and leptons (11->16)
     $  m_KFferm(20),                   ! fermion KFcode (1->6) and (11->16)
     $  m_NCf(20),                      ! number of colours
     $  m_Qf(20),                       ! electric charge
     $  m_T3f(20),                      ! isospin, L-hand component
     $  m_helic(20),                    ! helicity or polarization
     $  m_amferm(20),                   ! fermion mass
     $  m_auxpar(20),                   ! auxiliary parameter
     $  m_IsGenerated(20),              ! Generation flag, only for SAN !!! 
* Normalization
     $  m_gnanob,                       ! GeV^(-2) to nanobarns
* Initial/final fermion types
     $  m_KFini,                        ! KF code of beam
* Test switches
     $  m_KeyQCD,                       ! QCD FSR corr. switch
     $  m_KeyINT,                       ! ISR/FSR INTereference switch
     $  m_KeyElw,                       ! Type of Electrowak Library
     $  m_KeyZet,                       ! Z-boson on/off
     $  m_KeyWtm,                       ! Photon emission without mass terms
     $  m_out                           ! output unit for printouts
      SAVE /c_BornV/
*
* Formats for writing EW tables onto disk file.
      CHARACTER*80  m_fmt0, m_fmt1, m_fmt2
      PARAMETER (
     $  m_fmt0 ='(4g20.13)',                      ! Mz,Mt,Mh etc.
     $  m_fmt1 ='( a,  i4,  f10.5, i4,  f10.5 )', ! header
     $  m_fmt2 ='(6g13.7)'   )                    ! complex formfactors
*
*  Class procedures:
*
*//////////////////////////////////////////////////////////////////////////////
*//                                                                          //
*//                      End of CLASS  BornV                                 //
*//////////////////////////////////////////////////////////////////////////////

      DOUBLE PRECISION  xpar_input(*)
*------------------------------------------------------------------
      CALL BornV_StartDZ(xpar_input)
      END                       !BornV_StartEW

      SUBROUTINE BornV_StartDZ(xpar)
*///////////////////////////////////////////////////////////////////
*//                                                               //
*//   xpar goes as an input to DZface                             //
*//                                                               //
*///////////////////////////////////////////////////////////////////
C      INCLUDE '../bornv/BornV.h'
*//////////////////////////////////////////////////////////////////////////////
*//                                                                          //
*//                     Pseudo-CLASS  BornV                                  //
*//                                                                          //
*//  Purpose:                                                                //
*//  Provide Born angular distribution and integrated x-section              //
*//  as a function of s.                                                     //
*//                                                                          //
*//  NOTES:                                                                  //
*//  How to eliminate nneut? This will come in a natural way                 //
*//  when neutrino type is generated.                                        //
*//  NB. Zbyszek says that weight dispersion might worsen!                   //
*//                                                                          //
*//////////////////////////////////////////////////////////////////////////////
*
*  Class members:
*
*//////////////////////////////////////////////////////////////////////////////
      DOUBLE PRECISION   m_pi
      PARAMETER         (m_pi =3.1415926535897932d0)
      DOUBLE PRECISION   m_fleps
****  PARAMETER (m_fleps = 1d-35)  ! original
****  PARAMETER (m_fleps = 1d-45)  ! enough???
      PARAMETER (m_fleps = 1d-100)  ! enough!!!
****      PARAMETER (m_fleps = 1d-200)  ! enough!!!
*//////////////////////////////////////////////////////////////////////////////
*//       Energy limits in the EW grid, w=sqrt(s) in GeV units.              //
*//////////////////////////////////////////////////////////////////////////////
*     340-point grid, only 80pt for NLC to be improved/tested in future
      INTEGER           m_poin1, m_poin2, m_poin3, m_poin4, m_poinG , m_poinQ !
      INTEGER           m_poTh1, m_poTh2, m_poTh3, m_poTh4
      PARAMETER(        m_poinG =   7 )                      ! No of EW formfactors
      PARAMETER(        m_poinQ =   4 )                      ! No of QCD corrections
*----------- Low energies and LEP1
      PARAMETER(        m_poin1 = 120 )                              ! LEP1 basic range sqrt(s)    spacing
cc      PARAMETER(        m_poin1 = 96 )                              ! LEP1 basic range sqrt(s)    spacing
      PARAMETER(        m_poTh1 =   0 )                              ! Cost(heta) spacing
      DOUBLE PRECISION  m_WminLEP1,          m_WmaxLEP1              ! LEP1 basic range (m_WminLEP1,m_WmaxLEP1)
      PARAMETER(        m_WminLEP1=0.010d0,  m_WmaxLEP1=100.001d0 )  ! LEP1 basic range (m_WminLEP1,m_WmaxLEP1)
***   PARAMETER(        m_WminLEP1=0.010d0,  m_WmaxLEP1=120.001d0 )  ! as in KORALZ, also enough
*----------- Z resonance
      PARAMETER(        m_poin2 =  20 )                              ! Z range sqrt(s)    spacing
      PARAMETER(        m_poTh2 =   0 )                              ! Cost(heta) spacing
***   PARAMETER(        m_poTh2 =  14 )                              ! =14 is overkill
      DOUBLE PRECISION  m_WminZ, m_WmaxZ, m_WdelZ                    ! Z range (amz + m_WdelZ)
      PARAMETER(        m_WdelZ = 5.000d0)                           ! Z range (amz + m_WdelZ)
***   PARAMETER(        m_WdelZ = 2d0 *2.495342704946d0)             ! Old range 2*Gamma
*----------- LEP2
      PARAMETER(        m_poTh3 =  30 )                              ! Overkill, bit lets kkep it
***   PARAMETER(        m_poTh3 =  14 )                              ! Cost(heta) spacing
      PARAMETER(        m_poin3 = 140 )                              ! LEP2 interval sqrt(s)    spacing
***   PARAMETER(        m_poin3 = 120 )                              ! as in KORALZ, also enough
      DOUBLE PRECISION  m_WmaxLEP2                                   ! LEP2 interval (m_WmaxLEP1,m_WmaxLEP2)
      PARAMETER(        m_WmaxLEP2  =240.001d0 )                     ! LEP2 interval (m_WmaxLEP1,m_WmaxLEP2)
*----------- Linear Colliders
      PARAMETER(        m_poin4 =  80 )                              ! NLC range sqrt(s)    spacing
      PARAMETER(        m_poTh4 =  14 )                              ! Cost(heta) spacing
      DOUBLE PRECISION  m_WmaxNLC                                    ! NLC range (m_WmaxLEP2,m_WmaxNLC)
      PARAMETER(        m_WmaxNLC  =1040.001d0 )                     ! NLC range (m_WmaxLEP2,m_WmaxNLC)
*//////////////////////////////////////////////////////////////////////////////
* EW formfactors, all flavours!!
      DOUBLE COMPLEX     m_cyy,     m_czz,     m_ctt,    m_clc   ! Electroweak FFactors
      DOUBLE PRECISION   m_syy,     m_szz,     m_stt,    m_slc   ! QCD corr.
      DOUBLE COMPLEX     m_GSW
      DOUBLE PRECISION   m_QCDcor   ! obsolete
      DOUBLE PRECISION   m_QCDcorR
*//////////////////////////////////////////////////////////////////////////////
* EW parameters
      DOUBLE PRECISION   m_Gmu
      DOUBLE PRECISION   m_MZ,      m_amh,     m_amtop
      DOUBLE PRECISION   m_swsq,    m_gammz,   m_amw,    m_gammw
*
      DOUBLE PRECISION   m_CMSene,  m_XXXene,  m_HadMin, m_vvmin,  m_vvmax !
      DOUBLE PRECISION   m_AvMult,  m_YFSkon,  m_YFS_IR, m_alfinv, m_alfpi, m_Xenph !
      DOUBLE PRECISION   m_vv,      m_x1,      m_x2
      DOUBLE PRECISION   m_Qf,      m_T3f,     m_helic,  m_amferm, m_auxpar !
      DOUBLE PRECISION   m_gnanob
      INTEGER            m_IsGenerated, m_KFferm,  m_NCf
      INTEGER            m_KFini,       m_KeyINT,  m_KeyQCD
      INTEGER            m_KeyElw,      m_KeyZet,  m_KeyWtm
      INTEGER            m_out

      COMMON /c_BornV/
* Tables of EW formfactors
     $  m_cyy(m_poin1+1,          m_poinG,16), ! formfactor, table
     $  m_czz(m_poin2+1,m_poTh2+1,m_poinG,16), ! formfactor, table
     $  m_ctt(m_poin3+1,m_poTh3+1,m_poinG,16), ! formfactor, table, costheta dependent
     $  m_clc(m_poin4+1,m_poTh4+1,m_poinG,16), ! formfactor, table, costheta dependent
     $  m_syy(m_poin1+1,          m_poinQ,16), ! QCD correction,
     $  m_szz(m_poin2+1,          m_poinQ,16), ! QCD correction,
     $  m_stt(m_poin3+1,          m_poinQ,16), ! QCD correction,
     $  m_slc(m_poin3+1,          m_poinQ,16), ! QCD correction,
     $  m_GSW(    m_poinG),                    ! form-factors,   at the actual energy/angle
     $  m_QCDcorR(m_poinQ),                    ! QCD correction, at the actual energy/angle
     $  m_QCDcor,                              ! obsolete!!!!
*
     $  m_CMSene,                       ! Initial value of CMS energy
     $  m_XXXene,                       ! CMS energy after beamsstrahlung or beam spread
* -------------------- EVENT --------------------------
     $  m_x1,                           ! 1-z1 = x1 for first  beam(strahlung)
     $  m_x2,                           ! 1-z2 = x2 for second beam(strahlung)
     $  m_vv,                           ! v = 1-sprim/s
     $  m_AvMult,                       ! Average photon multiplicity CRude at given v
     $  m_YFSkon,                       ! YFS formfactor finite part
     $  m_YFS_IR,                       ! YFS formfactor IR part
* -----------------------------------------------------
     $  m_vvmin,                        ! minimum v, infrared cut
     $  m_vvmax,                        ! maximum v
     $  m_HadMin,                       ! minimum hadronization mass [GeV]
* Basic QED and QCD
     $  m_alfinv,                       ! 1/alphaQED, Thomson limit (Q^2=0)
     $  m_alfpi,                        ! alphaQED/pi
     $  m_Xenph,                        ! Enhancement factor for Crude photon multiplicity
* EW parameters
     $  m_MZ,                           ! Z mass
     $  m_amh,                          ! Higgs mass
     $  m_amtop,                        ! Top mass
     $  m_swsq,                         ! sin(thetaW)**2
     $  m_gammz,                        ! Z width
     $  m_amw,                          ! W mass
     $  m_gammw,                        ! W width
     $  m_Gmu,                          ! Fermi constant (from muon decay)
* Table of fermion paramerets, quarks (1->6) and leptons (11->16)
     $  m_KFferm(20),                   ! fermion KFcode (1->6) and (11->16)
     $  m_NCf(20),                      ! number of colours
     $  m_Qf(20),                       ! electric charge
     $  m_T3f(20),                      ! isospin, L-hand component
     $  m_helic(20),                    ! helicity or polarization
     $  m_amferm(20),                   ! fermion mass
     $  m_auxpar(20),                   ! auxiliary parameter
     $  m_IsGenerated(20),              ! Generation flag, only for SAN !!! 
* Normalization
     $  m_gnanob,                       ! GeV^(-2) to nanobarns
* Initial/final fermion types
     $  m_KFini,                        ! KF code of beam
* Test switches
     $  m_KeyQCD,                       ! QCD FSR corr. switch
     $  m_KeyINT,                       ! ISR/FSR INTereference switch
     $  m_KeyElw,                       ! Type of Electrowak Library
     $  m_KeyZet,                       ! Z-boson on/off
     $  m_KeyWtm,                       ! Photon emission without mass terms
     $  m_out                           ! output unit for printouts
      SAVE /c_BornV/
*
* Formats for writing EW tables onto disk file.
      CHARACTER*80  m_fmt0, m_fmt1, m_fmt2
      PARAMETER (
     $  m_fmt0 ='(4g20.13)',                      ! Mz,Mt,Mh etc.
     $  m_fmt1 ='( a,  i4,  f10.5, i4,  f10.5 )', ! header
     $  m_fmt2 ='(6g13.7)'   )                    ! complex formfactors
*
*  Class procedures:
*
*//////////////////////////////////////////////////////////////////////////////
*//                                                                          //
*//                      End of CLASS  BornV                                 //
*//////////////////////////////////////////////////////////////////////////////

      DOUBLE PRECISION  xpar(*)
*------------------------------------------------------------------
      INTEGER KFdown, KFup, KFstran, KFcharm, KFbotom, KFtop
      PARAMETER( 
     $     KFdown  = 1,   KFup    = 2,
     $     KFstran = 3,   KFcharm = 4,
     $     KFbotom = 5,   KFtop   = 6)
      INTEGER KFel,KFelnu,KFmu,KFmunu,KFtau,KFtaunu
      PARAMETER(
     $     KFel    = 11,  KFelnu  = 12,
     $     KFmu    = 13,  KFmunu  = 14,
     $     KFtau   = 15,  KFtaunu = 16)
*------------------------------------------------------------------
* Find active chanels
      DO i=401,416
         IF( xpar(i) .EQ. 1d0 ) THEN
            KFfin= i-400
            IF(    KFfin .EQ. KFdown  ) THEN
               WRITE(    *,*) '=========== BornV_StartDZ: DOWN quark ==========='
               WRITE(m_out,*) '=========== BornV_StartDZ: DOWN quark ==========='
               CALL DZface_Initialize( KFfin, xpar) ! Set EW params and run Dizet
               CALL DZface_Tabluj                   ! Calculate formfactor and store in tables
            ELSEIF(KFfin .EQ. KFup    )  THEN 
               WRITE(    *,*) '=========== BornV_StartDZ: UP quark ==========='
               WRITE(m_out,*) '=========== BornV_StartDZ: UP quark ==========='
               CALL DZface_Initialize( KFfin, xpar)
               CALL DZface_Tabluj
            ELSEIF(KFfin .EQ. KFstran )  THEN
               WRITE(    *,*) '=========== BornV_StartDZ: STRAN quark ==========='
               WRITE(m_out,*) '=========== BornV_StartDZ: STRAN quark ==========='
               CALL DZface_Initialize( KFfin, xpar)
               CALL DZface_Tabluj
            ELSEIF(KFfin .EQ. KFcharm )  THEN
               WRITE(    *,*) '=========== BornV_StartDZ: CHARM quark ==========='
               WRITE(m_out,*) '=========== BornV_StartDZ: CHARM quark ==========='
                CALL DZface_Initialize( KFfin, xpar)
               CALL DZface_Tabluj
            ELSEIF(KFfin .EQ. KFbotom )  THEN 
               WRITE(    *,*) '=========== BornV_StartDZ: BOTTOM quark ==========='
               WRITE(m_out,*) '=========== BornV_StartDZ: BOTTOM quark ==========='
               CALL DZface_Initialize( KFfin, xpar)
               CALL DZface_Tabluj
            ELSEIF(KFfin .EQ. KFmu)  THEN 
               WRITE(    *,*) '=========== BornV_StartDZ: MU lepton ==========='
               WRITE(m_out,*) '=========== BornV_StartDZ: MU lepton ==========='
               CALL DZface_Initialize( KFfin, xpar)
               CALL DZface_Tabluj
            ELSEIF(KFfin .EQ. KFtau)  THEN 
               WRITE(    *,*) '=========== BornV_StartDZ: TAU lepton ==========='
               WRITE(m_out,*) '=========== BornV_StartDZ: TAU lepton ==========='
               CALL DZface_Initialize( KFfin, xpar)
               CALL DZface_Tabluj
            ELSE
               WRITE(*,   *) '#### STOP in TabMain, wrong KFfin=',KFfin
               WRITE(m_out,*) '#### STOP in TabMain, wrong KFfin=',KFfin
               STOP
            ENDIF
         ENDIF
      ENDDO
      END                       ! BornV_StartDZ
      REAL FUNCTION DIZETVER(dum)
      DIZETVER = 605
      return
      END
      SUBROUTINE DIZET
     &  (NPAR,AMW,AMZ,AMT,AMH,DAL5H,ALQED,ALSTR,ALSTRT,ZPAR,PARTZ,PARTW)
*----------------------------------------------------------------------*
* DIZET is prepared to be called by ZFITTER.                           *
* For the program, description, updates etc. see:                      *
* http://www.ifh.de/theory/publist.html                                *
*----------------------------------------------------------------------*
* VERSION 6.05 (06 April 1999)                                         *
*----------------------------------------------------------------------*
* VERSION 5.20 (06 February 1999)                                      *
*----------------------------------------------------------------------*
* VERSION 5.10 (06 March 1998)                                         *
*----------------------------------------------------------------------*
* Recent versions:                                                     *
* version 5_0  - Reactivation of weak BOXES                            *
*       (\BETA)  March-September 1995                                  *
*                Used for "LEP2 Workshop"                              *
* version 4_9  - IMPLEMENTATION OR REACTIVATION OF `WORKING OPTIONS'   *
*                JULY-AUGUST 1994                                      *
*                USED FOR "Z-RESONANCE WORKSHOP"                       *
*----------------------------------------------------------------------*
* Insertions December 1996                                             *
*              - Implementation of more QCD corrections to R_V and R_A *
*                Carefully tested against TOPAZ0 at SQRT(s)=M_Z,15 GeV *
*              - Implementation of "running" Zbb vertex into ROKAPP    *
*                and ROKANC                                            *
* Insertions July 1997                                                 *    
*              - Implementation of Degrassi/Gambino/Sirlin/Vicini      *    
*                NLL corrections O(G^2_mu*m^2_t*M^2_Z)                 *    
*                for \Delta r and \sin^2\theta^{lept}_{eff}            *    
* Insertions February-March 1998                                       *
*              - Implementation of Degrassi/Gambino NLL corrections    *
*                for partial Z-widths and for all realistic observables*
*              - Reactivation of Kniehl's QCD library                  *
*              - Implementation of Czarnecki/Kuehn corrections         *
*======================================================================*
* THE PROGRAM DIZET IS A WEAK LIBRARY. IT CALCULATES ELECTROWEAK       *
* RADIATIVE CORRECTIONS IN THE STANDARD THEORY.                        *
* ---------------------------------------------------------------------*
* FOR THE CALCULATION OF                                               *
*       W-BOSON MASS AND WEAK MIXING ANGLE,                            *
*       Z-BOSON WIDTH,                                                 *
*       W-BOSON WIDTH,                                                 *
* --- CALL DIZET(...).                                                 *
* ---------------------------------------------------------------------*
* FOR THE CALCULATION OF                                               *
*       WEAK FORM FACTORS                                              *
*       FOR 2-FERMION INTO 2-FERMION NEUTRAL CURRENT PROCESSES         *
*       AND OF RUNNING ALPHA.QED,                                      *
* --- CALL ROKANC(...).                                                *
* FOR THE CALCULATION OF                                               *
*       WEAK FORM FACTORS                                              *
*       FOR 2-FERMION INTO 2-FERMION CHARGED CURRENT PROCESSES,        *
* --- CALL RHOCC(...).                                                 *
* IN BOTH CASES, AN EARLIER CALL OF DIZET(...) IS NECESSARY.           *
*======================================================================*
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
* NPAR(9) = ISCAL                                                      *
* NPAR(10)= IBARB                                                      *
* NPAR(11)= IFTJR                                                      *
* NPAR(12)= IFACR                                                      *
* NPAR(13)= IFACT                                                      *
* NPAR(14)= IHIGS                                                      *
* NPAR(15)= IAFMT                                                      *
* NPAR(16)= IEWLC                                                      *
* NPAR(17)= ICZAK                                                      *
* NPAR(18)= IHIG2                                                      *
* NPAR(19)= IALE2                                                      *
* NPAR(20)= IGFER                                                      *
* NPAR(21)= IDDZZ
*----------------------------------------------------------------------*
*         INPUT PARAMETERS TO BE SET BY THE USER                       *
*       ------------------------------------------                     *
* AMW  -  W-BOSON MASS (BUT IS BEING CALCULATED FOR NPAR(4)=1)         *
* AMZ  -  Z-BOSON MASS (BUT IS BEING CALCULATED FOR NPAR(4)=2)         *
*    NOTE: DUE TO A POSSIBLE RECALCULATION, THE AMZ, AMW CANNOT BE     *
*         ASSIGNED BY A PARAMETER STATEMENT (INPUT/OUTPUT VARIABLES)   *
* AMT  -  T-QUARK MASS                                                 *
* AMH  -  HIGGS BOSON MASS                                             *
* DAL5H - \Delta_ALPHA^5_{had}(MZ)                                     *
* ALSTR - ALPHA_ST(MZ)                                                 *
*----------------------------------------------------------------------*
*         OUTPUT OF THE DIZET PACKAGE                                  *
*       --------------------------------                               *
* ALSTRT  = ALPHA_ST(MT)                                               *
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
* IHVP :    IHVP=1: HADR. VACPOL. OF JEGERLEHNER - EIDELMAN REF. 11    *
*      I         2:       OF JEGERLEHNER(1988)                         *
*      I         3:       OF BURKHARDT ET AL., REF. 10                 *
*----------------------------------------------------------------------*
* HANDLING OF HIGHER ORDER (ALPHA*ALPHA.S) T-MASS TERMS:               *
* IQCD :    THE Z-WIDTH HAS FIXED QCD FACTOR (1+ALFAS/PI).             *
*      I    ADDITIONAL OPTIONS ARE FROM REF.8, WITH RUNNING ALPHA.S    *
*      I    IQCD=0: NO QCD CORRS. TO VECTOR BOSON SELF ENERGIES        *
*      I    IN DELTA-R, WIDTHS, CROSS SECTION                          *
*      I         1: APPROXIM. FAST QCD CORRS. (REALISED FOR  Z-WIDTH   *
*      I            AND LEP PROCESSES)                                 *
*      I            IMPORTANT NOTICE: THESE ARE RELIABLE ONLY FOR LEP-I*
*      I         2: EXACT FORMULAE (FROM BARDIN/CHIZHOV-LIBRARY)       *
*      I         3: EXACT FORMULAE (FROM B. KNIEHL-LIBRARY)            *
*----------------------------------------------------------------------*
* HANDLING OF ALPHA**2 T-MASS TERMS:                                   *
* IAMT4: IAMT4 = 0: NO  MT**4 CORRECTIONS,                             *
*      I       = 1: WITH MT**4 CORRECTIONS RESUMED, SEE REF. 7.        *
*                   IN ORDER TO HAVE COMPLETE BACKWARD COMPATIBILITY,  *
*                   NO COMMON RESUMMATION WITH IQCD.NE.0 TERMS IS DONE *
*      I       = 2: WITH RESUMMATION RECIPE DUE TO BARDIN/KNIEHL,      *
*                   SIMILAR TO THAT OF REF. 12                         *
*      I       = 3: WITH RESUMMATION RECIPE OF REFS. 13-15             *
*      I       = 4: WITH TWO LOOP SUBLEADING CORRECTIONS               *
*                   BY DEGRASSI, GAMBINO at al.                        *
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
*         =2: ------------------------------ RENORM (not recommended,  *
*                                                    = n.r.)           *
*----------------------------------------------------------------------*
* IF ISCAL=0: SCALET=1                                                 *
*         =1: SCALET=SCLAVR+SCTPLU     |                               *
*         =2: SCALET=SCLAVR            | Kniehl's                      *
*         =3: SCALET=SCLAVR-SCTMIN     |                               *
*         =4: SCALET=SIRLIN'S 0.204                                    *
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
* IALEM: IALEM = 0 OR 2: DALH5(AMZ) MUST BE SUPPLIED BY THE USER AS    *
*      I                            INPUT TO THE DIZET PACKAGE         *
*      I       = 1 OR 3: DALH5(AMZ) IS CALCULATED BY THE PROGRAM       *
*      I                            USING A PARAMETRIZATION (IHVP)     *
*----------------------------------------------------------------------*
* IFTJR  IFTJR = 0 WITHOUT FTJR CORRECTIONS                            * 
*        IFTJR > 1  WITH   FTJR CORRECTIONS                            * 
*----------------------------------------------------------------------*
* ICZAK: ICZAK = 0 WITHOUT CZARNECKI/KUEHN CORRECTIONS                 * 
*        ICZAK > 1  WITH   CZARNECKI/KUEHN CORRECTIONS                 * 
*----------------------------------------------------------------------*
* IHIG2: IHIG2 = 0 WITHOUT TWO-LOOP HIGGS  CORRECTIONS                 * 
*        IHIG2 = 1  WITH   --/--/--/--/--/--/--/--/--/                 * 
*----------------------------------------------------------------------*
* IALE2: IALE2 = 0 WITHOUT TWO-LOOP CONSTANT CORRECTIONS IN DELTA_ALPHA* 
*                  THIS IS FOR A BACK COMPATIBILITY ONLY               * 
*        IALE2 = 1 -- WITH   ONE-LOOP CORRECTIONS\                     * 
*        IALE2 = 2 -- WITH   TWO-LOOP CORRECTIONS | FOR LEPTONIC DALPHA* 
*        IALE2 = 3 -- WITH THREE-LOOP CORRECTIONS/                     * 
*----------------------------------------------------------------------*
* IGFER: IGFER = 0 FOR BACK COMPATIBILITY WITH 5.12                    *
*        IGFER = 1 ONE-LOOP QED CORRECTIONS FOR FERMI CONSTANT         *
*        IGFER = 2 TW0-LOOP QED CORRECTIONS FOR FERMI CONSTANT         *
*----------------------------------------------------------------------*
* CHOICE OF INPUT PARAMETERS BESIDES AMT, AMH, ALPHA.S:                *
* IMOMS: IMOMS = 1: (CONVENTIONAL)    ALPHA, GMU, AMZ (OUTPUT: AMW)    *
*      I       = 2: INPUT INSTEAD IS: ALPHA, GMU, AMW (OUTPUT: AMZ)    *
*      I       = 3:                   ALPHA, AMZ, AMW (OUTPUT: GMU)    *
* WHERE                                                                *
*      I GMU...... MUON DECAY CONSTANT                                 *
*      I AMT...... T-QUARK MASS                                        *
*      I AMH...... HIGGS BOSON MASS                                    *
*      I ALST..... STRONG COUPLING CONSTANT ALPHA.S (.11)              *
*======================================================================*
*                                                                      *
      IMPLICIT REAL*8(A-H,O-Z)
      COMPLEX*16 XFOTF3
*
      COMMON/CDZFLG/IHVP,IAMT4,IQCD,IMOMS,IMASS,IALEM,IMASK,IBARB,IFTJR
      COMMON/CDZSCT/ISCRE,ISCAL,IAFMT,IFACR,IFACT,IHIGS,IEWLC,ICZAK
     &             ,IHIG2,IALE2,IGFER      
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZZWG/CAMZ,CAMH,GMU,A0,GAMZ,GAMW,CALSZ,CALST,CALXI,CALQED
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
*
      COMMON /CDZRKZ/ARROFZ(0:10),ARKAFZ(0:10),ARVEFZ(0:10),ARSEFZ(0:10)
     &              ,AROTFZ(0:10),AIROFZ(0:10),AIKAFZ(0:10),AIVEFZ(0:10)
      COMMON/CDZ513/CDAL5H
*
* Internal COMMON to study \mt-additional terms
*
      COMMON/CDZ_LK/IMTADD
      COMMON/CDZDDZ/IDDZZ
*
      DIMENSION NPAR(21),PARTZ(0:11),PARTW(3),ZPAR(30),QCDCOR(0:14)
*
* Never change this flag
*
      IMTADD=0
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
      IEWLC=NPAR(16)
      ICZAK=MIN(1,NPAR(17))
      IHIG2=NPAR(18)
      IALE2=NPAR(19)
      IGFER=NPAR(20)
      IDDZZ=NPAR(21)
      ITQ=2-IHVP
*
      CALL CONST1(ITQ,AMT,AMH)
*
      ALFAS = ALSTR
      AMZ2  = AMZ**2
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
      IF(MOD(IALEM,2).EQ.0) THEN
        DAL5H=DAL5H
      ELSE
        DAL5H=DALH5(AMZ2,AMZ)     
      ENDIF
      CDAL5H=DAL5H
cbardin
        DALFA=AL4PI*DREAL(XFOTF3(IALEM,IALE2,IHVP,1,1,DAL5H,-AMZ**2))
        ALQED=1D0/ALFAI/(1D0-DALFA)
      CALQED=ALQED
*-----------------------------------------------------------------------
      SW2=.2325D0
      ALPHST=ALFAS
      CALL QCDCOF(AMZ,AMT,SW2,ALQED,ALPHST,ALPHTT,ALPHXI,QCDCOR)
      CALSZ=ALPHST
      CALST=ALPHTT
      ALSTRT=ALPHTT
      CALXI=ALPHXI
       ALSZ=ALPHST
       ALST=ALPHTT
       ALSX=ALPHXI
*
* ITERATIVE PROCEDURE FOR THE CALCULATION OF IVB- MASSES
*
      CALL SETCON(AMW,AMZ,AMT,AMH,DR,DRBIG,DRREM)
*
      AMW=DSQRT(AMW2)
      SW2=R1
*
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
          QCDCOR(13)=0D0
          QCDCOR(14)=0D0
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
 
      FUNCTION DZEWBX(RACOS)
*
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
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
      COMMON/CDZIBF/IBFLA
*
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
C AVOID THAT AI11,AI12 IS ZERO: MULTIPLY RACOS BY (1 - 2*ME**2/S)
      ACOSM=RACOS*(1.D0-0.0000005D0/S)
      IF (ABS(ACOSM) .EQ. 1D0) ACOSM = DSIGN(0.9999999999999D0,RACOS)
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
*
      XCHIGF=XCHIG*SF
      BOXWW=-COMPL*HOMPL*DREAL(
     & +(QF*XFZTG+XCHIGF*VEP1*VFP1)*
     &  (+(1D0+SE*SF)/2D0*(XBOX(IBFLA,AI11,AI12,AMW2)
     &   +4.D0*(AI11/S)**2*XJ3(S,AMW2))
     &   -(1D0-SE*SF)/2.D0*2.D0*(AI11/S)**2
     &   *(AI11/S*XJ4(S,AI11,AMW2)+2.D0*XJ3(S,AMW2)) ))
      BOXZZ=-DREAL(
     & +(QF*XFZTG*VZP1+XCHIGF*VZP2)
     & *(XBOX(0,AI11,AI12,AMZ2)-(2.D0*(AI11/S)**3)*XJ4(S,AI11,AMZ2))
     & -(QF*XFZTG*VZM1+XCHIGF*VZM2)
     & *(XBOX(0,AI12,AI11,AMZ2)-(2.D0*(AI12/S)**3)*XJ4(S,AI12,AMZ2)))
*
* BOX CROSS SECTION TAKES INTO ACCOUNT
* ARBITRARY BEAM POLARIZATIONS AND DEFINITE FINAL HELICITIES
* COLORF IS TAKEN INTO ACCOUNT IN ZFITTER VIA CORINT
*
      DZEWBX=CRFAC*(CBXWW*BOXWW+CBXZZ*BOXZZ)
*
      END
 
      FUNCTION DZEWBI(RACOS)
* 
* DZEWBI=DZEWBX (Linux problems)
*
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
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
      COMMON/CDZIBF/IBFLA
*
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
C AVOID THAT AI11,AI12 IS ZERO: MULTIPLY RACOS BY (1 - 2*ME**2/S)
      ACOSM=RACOS*(1.D0-0.0000005D0/S)
      IF (ABS(ACOSM) .EQ. 1D0) ACOSM = DSIGN(0.9999999999999D0,RACOS)
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
*
      XCHIGF=XCHIG*SF
      BOXWW=-COMPL*HOMPL*DREAL(
     & +(QF*XFZTG+XCHIGF*VEP1*VFP1)*
     &  (+(1D0+SE*SF)/2D0*(XBOX(IBFLA,AI11,AI12,AMW2)
     &   +4.D0*(AI11/S)**2*XJ3(S,AMW2))
     &   -(1D0-SE*SF)/2.D0*2.D0*(AI11/S)**2
     &   *(AI11/S*XJ4(S,AI11,AMW2)+2.D0*XJ3(S,AMW2)) ))
      BOXZZ=-DREAL(
     & +(QF*XFZTG*VZP1+XCHIGF*VZP2)
     & *(XBOX(0,AI11,AI12,AMZ2)-(2.D0*(AI11/S)**3)*XJ4(S,AI11,AMZ2))
     & -(QF*XFZTG*VZM1+XCHIGF*VZM2)
     & *(XBOX(0,AI12,AI11,AMZ2)-(2.D0*(AI12/S)**3)*XJ4(S,AI12,AMZ2)))
*
* BOX CROSS SECTION TAKES INTO ACCOUNT
* ARBITRARY BEAM POLARIZATIONS AND DEFINITE FINAL HELICITIES
* COLORF IS TAKEN INTO ACCOUNT IN ZFITTER VIA CORINT
*
      DZEWBI=CRFAC*(CBXWW*BOXWW+CBXZZ*BOXZZ)
*
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
 
      FUNCTION XBOX(IBFLA,AI11,AI12,AMV2)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZFLG/IHVP,IAMT4,IQCD,IMOMS,IMASS,IALEM,IMASK,IBARB,IFTJR
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
      COMMON/CDZ_LK/IMTADD
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
*
      IF(IBFLA.EQ.0) RETURN
*
* Genuine WW-box m_t corrections, p.12 of 1997 notes
*
      AMT2=(AMQ(5))**2
      AMW2=AMV2
      RTW =AMT2/AMW2
      ALRT=LOG(RTW)
      RWS =AMW2/S
*
      CALL J3WANA(AMT2,AMW2,AI12,XJ3WT)
      CALL J3WANA( 0D0,AMW2,AI12,XJ3W0)
      CALL S3WANA(AMT2,AMW2,-S,XJ0W,XS3WT,XS3W0)
      CALL S4WANA(AMT2,AMW2,-S,AI12,XS4WT)
      CALL S4WANA( 0D0,AMW2,-S,AI12,XS4W0)
*
      RJ2=AMT2/AI12
*
* WWbg_desc=1/M2W*rt*(RW*(2-1/2*RW-(1/2-RW)*rt-1/2*RW*rt**2)*s*Sw3
*           +1/4*([1/epsilon]-Lnw)
*           -1/2*(1/2-RW+RW*rt)*Jw
*           +1/2*RW*rt*[lnrt]+1/2*(3/2-RW+RW*rt)         
*                     );
*     WWbg =+RTW*(RWS*(2D0-.5D0*RWS-(.5D0-RWS)*RTW
*    &      -.5D0*RWS*RTW**2)*S*S3W     
*    &      -.5D0*(.5D0-RWS+RWS*RTW)*AJ0W
*    &      +.5D0*RWS*RTW*ALRT+.5D0*(1.5D0-RWS+RWS*RTW))
*
      XWWbg =+.5D0*RTW*RWS*(
     &        +(4D0-RWS-(1D0-2D0*RWS)*RTW-RWS*RTW**2)*S*XS3WT     
     &        +(1D0-RTW)*(XJ0W-1D0)+RTW*ALRT
     &                    )
*
      XBBX=AI11**2/S/AMW2*XWWbg
     &     +2D0/S*(
     &     +AI11*(LOG(1D0+RJ2)+RJ2*LOG(1D0+1D0/RJ2))
     &     +(2D0*S*AMW2-AI11**2-AI12**2)/2D0*(XS3WT-XS3W0)
     &     -S*AMT2/2D0*(XS3WT+XS3W0)
     &     +AI12*(AI12-AI11-2D0*AMW2)*(XJ3WT-XJ3W0)+AI12*AMT2*XJ3WT
     &     +(+AMW2*((2D0*S-AI11)*AMW2-2D0*AI12**2)       
     &       +AI12/2D0*(AI11**2+AI12**2))*(XS4WT-XS4W0)
     &     +(-AMW2*(2D0*S-AI11)+(AI11**2+AI12**2+S*AI12)/2D0
     &       +S*AMT2/2D0)*AMT2*XS4WT)
*
       IF(IMTADD.EQ.0) THEN
        XBOX=XBOX+XBBX 
       ELSE
        XBOX=XBOX
       ENDIF 
*
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
      CW2=R
      AMT2=AMQ(5)**2
*
* Mixed QCD-corrections
*
      XZERO=DCMPLX(0.D0,0.D0)
      XRQCD=XZERO
      XKQCD=XZERO
*
      IF    (IQCD.EQ.1) THEN
        XRQCD=AL4PI*XRQCDS(ALSZ,ALST,AMZ2,AMW2,AMT2,Q2M)
        XKQCD=AL4PI*XKQCDS(ALST,AMZ2,AMW2,AMT2,Q2M)
      ELSEIF(IQCD.EQ.2) THEN
        XRQCD=AL4PI*XROQCD(ALSZ,ALST,AMZ2,AMW2,AMT2,Q2M)
        XKQCD=AL4PI*XKAQCD(ALST,AMZ2,AMW2,AMT2,Q2M)
      ELSEIF(IQCD.EQ.3) THEN
* not yet tested (25/02/1998)
        XRQCD=AL1PI*ALST/PI*XRMQCD(AMZ2,AMW2,AMT2,Q2M)
     &       -AL1PI*ALSZ/PI/8D0/SW2/CW2*(VT2+VB2+2D0)
     &                   *Q2M/(AMZ2-Q2M)*LOG(Q2M/AMZ2)
* light quarks not added (25/02/1998), 
* there is a problem for low Q2M, see mixed_QCD.frm
* also IM part is not yet added
        XKQCD=AL1PI*ALST/PI*XKMQCD(AMZ2,AMW2,AMT2,Q2M)
      ENDIF
*
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
      IF(IBARB.EQ.0.OR.IBARB.EQ.-1) THEN
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
      ELSEIF(IAMT4 .GE. 3 ) THEN
       DWZ1AL=R/R1*DREAL(XWZ1R1+XDWZ1F)
       RENORM=SQRT(2D0)*GMU*AMZ2*R1*R/PI*ALFAI
       SCALE = AL4PI/R1*(41D0/6D0-11D0/3D0*R)*ALR
       CORKAP=(AL4PI*DWZ1AL+SCALE)+.75D0*AL4PI/SW2**2*AMT2/AMZ2
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
      V1B1W=4.D0*DREAL(XI3(AMW2,Q2,AML(IND)**2,AML(IND)**2))
      RNU=AL4PI/R1*V1B1W
      CHQ21=DREAL(XI3(AMW2,Q2,AML(2)**2,AML(2)**2)
     *     +XI3(AMW2,Q2,AML(4)**2,AML(4)**2)
     *     +XI3(AMW2,Q2,AML(6)**2,AML(6)**2))
      CHMQ1=CHQ21
      DO 201 I=1,6
      AMQ2=AMQ(I)**2
      CHMQ1=CHMQ1+3.D0*CQM(I)   *DREAL(XI3(AMW2,Q2,AMQ2,AMQ2))
      CHQ21=CHQ21+3.D0*CQM(I)**2*DREAL(XI3(AMW2,Q2,AMQ2,AMQ2))
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
 
      FUNCTION XV2B(Q2,AMV2)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      RMV=AMV2/Q2
      XV2B=5.D0/2.D0-8.D0/3.D0+2.D0*RMV
     *    +(5.D0/12.D0+3.D0/4.D0-RMV)/Q2*XL(Q2,AMV2,AMV2)
     *    +2.D0*(-2.D0*RMV+RMV**2)*XJ3(-Q2,AMV2)
*
      END
 
      FUNCTION XDZB(Q2)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
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
*
      END
 
      FUNCTION XDL(Q2,Q2SBT,AM12,AM22)
*
* XDL(Q2,AMQ2,AM12,AM22)=(L(Q2,AM12,AM22)-L(Q2SBT,AM12,AM22))/(Q2-Q2SBT)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
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
*
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
*
* XJ(Q2,M12,M22)=J(Q2,M12,M22)
*
      ALAM=(Q2+AM12+AM22)**2-4.D0*AM12*AM22
      REJ=FJJ(Q2,AM12,AM22)
      AIJ=0.D0
      TRES=(SQRT(AM12)+SQRT(AM22))**2
      IF(-Q2.LE.TRES) GO TO 1
      SLAM=SQRT(ALAM)
      AIJ=2.D0*PI/SLAM
1     XJ=DCMPLX(REJ,AIJ)
*
      END
 
      FUNCTION XL(Q2,AM12,AM22)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
*
* XL(Q2,M12,M22)=L(Q2,M12,M22)=ALAM(Q2,-M12,-M22)*J(Q2,M12,M22)
*
      ALAM=(Q2+AM12+AM22)**2-4.D0*AM12*AM22
      REL=ALAM*FJJ(Q2,AM12,AM22)
      AIL=0.D0
      TRES=(SQRT(AM12)+SQRT(AM22))**2
      IF(-Q2.LE.TRES.OR.ALAM.LT.0D0) GO TO 1
      SLAM=SQRT(ALAM)
      AIL=2.D0*PI*SLAM
1     XL=DCMPLX(REL,AIL)
*
      END
 
      FUNCTION FJJ(Q2,AM12,AM22)
*
      IMPLICIT REAL*8(A-H,O-Z)
*
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
*
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
*
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
      TRES=(SQRT(AM12)+SQRT(AM22))**2
      IF(-Q2.GT.TRES) AILQ=-PI
      XLQ=DCMPLX(RELQ,AILQ)
      XI0=AL1W-2.D0+(1.D0+AQ)*XLQ
*
      END
 
      FUNCTION XI1(AMW2,Q2,AM12,AM22)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
*
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
      TRES=(SQRT(AM12)+SQRT(AM22))**2
      IF(-Q2.GT.TRES) AILQ=-PI
      XLQ=DCMPLX(RELQ,AILQ)
      XI1=AL1W/2D0-1.D0-AQ/2.D0+(1.D0+AQ)**2/2.D0*XLQ
*
      END
 
      FUNCTION XI3(AMW2,Q2,AM12,AM22)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
*
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
      TRES=(SQRT(AM12)+SQRT(AM22))**2
      IF(-Q2.GT.TRES) AILQ=-PI
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
* equal for leptons
      INQ=2*NG
      DO 2 I=1,INQ
      AMQ2=AMQ(I)**2
      XCHMQ1=XCHMQ1+3.D0*CQM(I)*XI3(AMW2,Q2,AMQ2,AMQ2)
      XCHQ21=XCHQ21+3.D0*CQM(I)**2*XI3(AMW2,Q2,AMQ2,AMQ2)
2     CONTINUE
      XAMF=8.D0*R1*XCHQ21-2.D0*XCHMQ1
*
      END
 
      FUNCTION XAMFEF(Q2,SEFF2)
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
      XAMFEF=8.D0*SEFF2*XCHQ21-2.D0*XCHMQ1
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
 
      FUNCTION XFOTF1(IALEM,IHVP,IQCD,ITOP,Q2)
*
* NEG.Q2 IS S-CHANNEL, POS. T-CHANNEL
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZZWG/AMZ,AMH,GMU,A0,GAMZ,GAMW,CALSZ,CALST,CALXI,CALQED
      COMMON/CDZ513/DAL5H
*
      NG=3
      XCHQ21=DCMPLX(0D0,0D0)
C********* LEPTONIC PART OF VACUUM POLARISATION ********************
      DO 1 I=1,NG
      AML2=AML(2*I)**2
      XCHQLL=XI3(AML2,Q2,AML2,AML2)
      XCHQ21=XCHQ21+XCHQLL
 1    CONTINUE
*
* Leptonic one-loop contribution via DALPHL
*
      DALEP=DALPHL(1,ABS(Q2))
      XCHQ21=DCMPLX(DALEP/AL4PI/8,DIMAG(XCHQ21))
*      
      AMT2=AMQ(5)**2
      ALSZ=CALSZ
      ALST=CALXI
      SW2=R1
* AL4PI is removed from ALFQCD as Tord suggested
      IF(IQCD-1) 2,3,4
 2    ALFQCD=0D0
      GO TO 5
 3    ALFQCD=ALQCDS(ALST,AMZ2,AMW2,AMT2)
      GO TO 5
 4    ALFQCD=ALQCD (ALST,AMZ2,AMW2,AMT2)
 5    CONTINUE
C********* HADRONIC PART OF VACUUM POLARISATION ********************
      IF (IHVP - 2) 6,7,9
 6    CONTINUE
      XCHQ25=3D0*CQM(5)**2*XI3(AMT2,Q2,AMT2,AMT2)
      XCHQ21=XCHQ21+XCHQ25*ITOP
*
      AMQ2=ABS(Q2)
C***** JEGERLEHNER/EIDELMAN
      IF(MOD(IALEM,2).EQ.0) THEN
        UDCSB=DALH5(-Q2,AMZ)-DALH5(AMZ2,AMZ)+DAL5H
      ELSE
        UDCSB=DALH5(-Q2,AMZ)     
      ENDIF
C*****
      INQ=2*NG
      XCHQQQ=DCMPLX(0.D0,0.D0)
      DO 61 I=1,INQ
      IF(ITOP.EQ.0.AND.I.EQ.5) GOTO 61
      AMQ2=AMQ(I)**2
      XCHQQQ=XCHQQQ+3D0*CQM(I)**2*XI3(AMQ2,Q2,AMQ2,AMQ2)
 61   CONTINUE
      XFOTF1=8*XCHQ21+DCMPLX(UDCSB/AL4PI,8*DIMAG(XCHQQQ))+ALFQCD*ITOP
*
* this is a correction to Im part of \alpha_em, which improved
* the agreement with TOPAZ0
*     XFOTF1=8*XCHQ21
*    &     +DCMPLX(UDCSB/AL4PI,8*DIMAG(XCHQQQ*(1+CALSZ/PI)))+ALFQCD*ITOP
      RETURN
C****** THIS HADRONIC PART WAS USED IN THE 1989 Z PHYSICS WORKSHOP
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
C****** THIS IS BURKHARDT ET AL. HADRONIC VACUUM POLARIZATION
 9    CONTINUE
      XCHQ25=+3.D0*CQM(5)**2*XI3(AMT2,Q2,AMT2,AMT2)
      XCHQ21=XCHQ21+XCHQ25*ITOP
      XUDSCB = XADRQQ(-Q2)/AL4PI
      XFOTF1 = 8D0*XCHQ21 + XUDSCB +ALFQCD*ITOP
*
      END
 
      FUNCTION XFOTF3(IALEM,IALE2,IHVP,IQCD,ITOP,DAL5H,Q2)
*
* Contrary to XFOTF1, this function may return the leptonic part up to
* three-loop corrections, which is governed by the flag IALE2 as desribed. 
*
* NEG.Q2 IS S-CHANNEL, POS. T-CHANNEL
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZZWG/AMZ,AMH,GMU,A0,GAMZ,GAMW,CALSZ,CALST,CALXI,CALQED
* For print controll
*      DATA IPRC/0/
*      IPRC=IPRC+1
*
      NG=3
      XCHQ21=DCMPLX(0D0,0D0)
C********* LEPTONIC PART OF VACUUM POLARISATION ********************
      DO 1 I=1,NG
      AML2=AML(2*I)**2
      XCHQLL=XI3(AML2,Q2,AML2,AML2)
      XCHQ21=XCHQ21+XCHQLL
 1    CONTINUE
*
* Leptonic one-loop contribution via DALPHL
*
      DALEP=DALPHL(IALE2,ABS(Q2))
*
* Control print of DALEP
*     DALEP1=DALPHL(1,ABS(Q2))
*     DALEP2=DALPHL(2,ABS(Q2))-DALPHL(1,ABS(Q2))
*     DALEP3=DALPHL(3,ABS(Q2))-DALPHL(2,ABS(Q2))
*     DALEP =DALPHL(3,ABS(Q2))
*     print *,'MZ,SQ=',AMZ,SQRT(ABS(Q2)),DALEP1,DALEP2,DALEP3,DALEP
*     stop
      XCHQ21=DCMPLX(DALEP/AL4PI/8,DIMAG(XCHQ21))
*
      AMT2=AMQ(5)**2
      ALSZ=CALSZ
      ALST=CALXI
      SW2=R1
* AL4PI is removed from ALFQCD as Tord suggested
      IF(IQCD-1) 2,3,4
 2    ALFQCD=0D0
      GO TO 5
 3    ALFQCD=ALQCDS(ALST,AMZ2,AMW2,AMT2)
      GO TO 5
 4    CONTINUE
      IF(IQCD.EQ.2) ALFQCD=ALQCD (ALST,AMZ2,AMW2,AMT2)
      IF(IQCD.EQ.3) ALFQCD=AQCDBK(ALST,AMZ2,AMW2,AMT2)
 5    CONTINUE
*
* Control print of the QCDcontribution for the book
*      if(iprc.lt.10) print *,'ALST,QCD=',ALST,AL4PI*ALFQCD
C********* HADRONIC PART OF VACUUM POLARISATION ********************
      IF (IHVP - 2) 6,7,9
 6    CONTINUE
      XCHQ25=3D0*CQM(5)**2*XI3(AMT2,Q2,AMT2,AMT2)
      XCHQ21=XCHQ21+XCHQ25*ITOP
*
* Control print of the top contribution for the book
*      if(iprc.lt.10) print *,'top=',AL4PI*8*DREAL(XCHQ25)
*
      AMQ2=ABS(Q2)
C***** JEGERLEHNER/EIDELMAN
      IF(MOD(IALEM,2).EQ.0) THEN
        UDCSB=DALH5(-Q2,AMZ)-DALH5(AMZ2,AMZ)+DAL5H
      ELSE
        UDCSB=DALH5(-Q2,AMZ)
* Control print of UDCSB
*     print *,'UDCSB=',UDCSB
      ENDIF
C*****
      INQ=2*NG
      XCHQQQ=DCMPLX(0.D0,0.D0)
      DO 61 I=1,INQ
      IF(ITOP.EQ.0.AND.I.EQ.5) GOTO 61
      AMQ2=AMQ(I)**2
      XCHQQQ=XCHQQQ+3D0*CQM(I)**2*XI3(AMQ2,Q2,AMQ2,AMQ2)
 61   CONTINUE
      XFOTF3=8*XCHQ21+DCMPLX(UDCSB/AL4PI,8*DIMAG(XCHQQQ))+ALFQCD*ITOP
*
* this is a correction to Im part of \alpha_em, which improved
* the agreement with TOPAZ0
*     XFOTF3=8*XCHQ21
*    &     +DCMPLX(UDCSB/AL4PI,8*DIMAG(XCHQQQ*(1+CALSZ/PI)))+ALFQCD*ITOP
      RETURN
C****** THIS HADRONIC PART WAS USED IN THE 1989 Z PHYSICS WORKSHOP
 7    INQ=2*NG
      XCHQQQ=DCMPLX(0.D0,0.D0)
      DO 8 I=1,INQ
      IF(ITOP.EQ.0.AND.I.EQ.5) GOTO8
      AMQ2=AMQ(I)**2
      XCHQQQ=XCHQQQ+3D0*CQM(I)**2*XI3(AMQ2,Q2,AMQ2,AMQ2)
 8    CONTINUE
      XCHQ21=XCHQ21+XCHQQQ
      XFOTF3=8D0*XCHQ21+ALFQCD*ITOP
      RETURN
C****** THIS IS BURKHARDT ET AL. HADRONIC VACUUM POLARIZATION
 9    CONTINUE
      XCHQ25=+3.D0*CQM(5)**2*XI3(AMT2,Q2,AMT2,AMT2)
      XCHQ21=XCHQ21+XCHQ25*ITOP
      XUDSCB = XADRQQ(-Q2)/AL4PI
      XFOTF3 = 8D0*XCHQ21 + XUDSCB +ALFQCD*ITOP
*
      END
 
      SUBROUTINE SETCON(AMW,AMZ,AMT,AMH,DR,DRBIG,DRREM)
*
************************************************************************
*   THIS SUBROUTINE 
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
       IF(ABS(DRF-DRP).LE.1D-11) GO TO 11
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
       IF(ABS(DRF-DRP).LE.1D-11) GO TO 21
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
*
      COMMON/CDZSCT/ISCRE,ISCAL,IAFMT,IFACR,IFACT,IHIGS,IEWLC,ICZAK
     &             ,IHIG2,IALE2,IGFER      
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZZWG/AMZ,AMH,GMU,A0,GAMZ,GAMW,CALSZ,CALST,CALXI,CALQED
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
      COMMON/CDZTHR/AMTH(6)
      DIMENSION AMHF(4),CLMI(8),AMLI(8),AMTI(6)
      DATA CLMI/0.D0,1.D0,0.D0,1.D0,0.D0,1.D0,0.D0,1.D0/
      DATA AMLI/0D0,.51099907D-3,0D0,.105658389D0,0D0,1.77705D0,2*0D0/
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
      IF(IGFER.LE.1) THEN
        GMU=1.16639D-5
      ELSE
        GMU=1.16637D-5
      ENDIF
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
102   AMQ(1)=.04145D0
      AMQ(2)=.04146D0
      AMQ(3)=1.50D0
      AMQ(4)=0.15D0
      AMQ(5)=FPMT
      AMQ(6)=4.70D0
      AMQ(7)=AMHF(3)
      AMQ(8)=AMHF(4)
103   CONTINUE
*
      END
 
      SUBROUTINE CONST2 (NG,FPMW2,FPMZ2)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      COMMON/CDZFLG/IHVP,IAMT4,IQCD,IMOMS,IMASS,IALEM,IMASK,IBARB,IFTJR
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
      XZM1F=(0D0,0D0)
*     T'HOOFT SCALE NOW APPLIED ONLY FOR FERMIONS, CANCELS IN DELTA_R
cbardin  Why 'ONLY FOR FERMIONS' but not for BOSONS??? This I forgot.
      AMW2MU=AMW2
*
      DO 1 I=1,NG
*     NEUTRINO PART
      ALRNOR=LOG(AMW2MU/AMZ2)
      XALR=DCMPLX(ALRNOR,PI)
      XZM1F=XZM1F+1D0/R/6D0*(XALR+5D0/3D0)

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
*     DERIVATIVES, USED ONLY IN FORMFACTORS AND PARTIAL WIDTHS
*
      XWFM1F=XDWF(-AMW2)
      XZFM1F=XDZF(-AMZ2)
      XAMM1F=XAMF(-AMZ2)
*
* Gambino's modification of XZM1F, include mixing ZA squared in the mass 
*                                  counterterm (Dyson resummation)
      IF(IAMT4.EQ.4) XZM1F=XZM1F-AL4PI*XAMM1F**2
*
      DWZ0F =( W0F - Z0F )/R1
      XDWZ1F=(XWM1F-XZM1F)/R1
*
*     FILL BOSONIC PARTS
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
     &                  DRBIG,DRREM)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMMON/CDZSCT/ISCRE,ISCAL,IAFMT,IFACR,IFACT,IHIGS,IEWLC,ICZAK
     &             ,IHIG2,IALE2,IGFER      
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZZWG/AMZ,AMH,GMU,A0,GAMZ,GAMW,CALSZ,CALST,CALXI,CALQED
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
      COMMON/CDZWSC/SL2,SQ2,W0,W0F,Z0,Z0F,DWZ0R1,DWZ0F,XWM1,XWM1F,XZM1,
     &      XZM1F,XWZ1R1,XDWZ1F,XZFM1,XZFM1F,XAMM1,XAMM1F,XWFM1,XWFM1F
      COMMON/CDZDEG/DROBAR,DROBLO,DRREMD
      COMMON/CDZ513/DAL5H
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
*
      CLQQCD=0D0
      XTBQCD=DCMPLX(0D0,0D0)
      ALFQCD=0D0
      AMT2=AMQ(5)**2
      SW2=R1
*
* Mixed QCD-corrections to \dr
*
      IF(IQCD.EQ.0) GO TO 4
      ALSZ=CALSZ
      ALST=CALST
*
* Mixed QCD-corrections from two light doublets
*
      CLQQCD=-AL4PI*(R/R1-1D0)/R1*ALR*ALSZ/PI*(1D0+1.409*ALSZ/PI
     &       -12.805*(ALSZ/PI)**2)
*
* Mixed QCD-corrections from t-b doublet
*
      IF    (IQCD.EQ.0) THEN
        XTBQCD=DCMPLX(0D0,0D0)
        ALFQCD=0D0
      ELSEIF(IQCD.EQ.1) THEN
        XTBQCD=AL4PI*DCMPLX(RXQCDS(ALST,AMZ2,AMW2,AMT2),0D0)
        XTBQCD=AL4PI*DCMPLX(RXQCDS(ALST,AMZ2,AMW2,AMT2),0D0)
        ALFQCD=AL4PI*ALQCDS(ALST,AMZ2,AMW2,AMT2)
      ELSEIF(IQCD.EQ.2) THEN
        XTBQCD=AL4PI*DCMPLX( RXQCD(ALST,AMZ2,AMW2,AMT2),0D0)
        ALFQCD=AL4PI*ALQCD (ALST,AMZ2,AMW2,AMT2)
      ELSEIF(IQCD.EQ.3) THEN
        XTBQCD=AL1PI*ALST/PI*DRMQCD(AMZ2,AMW2,AMT2)
        ALFQCD=0D0
* for IQCD=3, ALFQCD is a part of \delta_r - reminder  
      ENDIF
*
* Hadronic vacuum polarization
*
 4    IF(IHVP-2)5,7,8
*
 5    CONTINUE
      XQQ15=(0D0,0D0)
      DO 6 IQ=1,6
      AMQ2 = AMQ(IQ)*AMQ(IQ)
      IF(IQ.EQ.5) GO TO 6 
      XQQ15=XQQ15 + 6D0*XI3(AMQ2,-AMZ2,AMQ2,AMQ2) * 3D0 *CQM(IQ)**2
 6    CONTINUE
C***** JEGERLEHNER/EIDELMAN
      IF(MOD(IALEM,2).EQ.0) THEN
        UDCSB=DAL5H
      ELSE
        UDCSB=DALH5(AMZ2,AMZ)     
      ENDIF
C*****
      IF(IMASS.EQ.0) THEN
       DR1FER=AL4PI*RXXFER-AL4PI*4D0/3D0*DREAL(XQQ15)+UDCSB 
       DR1BOS=AL4PI*RXXBOS
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
       DR1FER=DREAL(AL4PI*RXXFER - AL4PI*4D0/3D0*XQQ15 + XUDSCB)
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
      IF(IBARB.EQ.0.OR.IBARB.EQ.-1) THEN
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
*
* XFOTF3-CALL to compute DALPH's
*
      DALFA1=DREAL(XFOTF3(IALEM,    1,IHVP,IQCD,0,DAL5H,-AMZ2))*AL4PI
      DALFA =DREAL(XFOTF3(IALEM,IALE2,IHVP,IQCD,0,DAL5H,-AMZ2))*AL4PI
*
*-----------------------------------------------------------------------
      IF (IAMT4 .EQ. 1) THEN
*-----------------------------------------------------------------------
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
*
*-----------------------------------------------------------------------
      ELSEIF(IAMT4 .EQ. 2) THEN
*-----------------------------------------------------------------------
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
*
*-----------------------------------------------------------------------
      ELSEIF(IAMT4 .EQ. 3) THEN
*-----------------------------------------------------------------------
       DRHO1 = .75D0*AL4PI/SW2/R*AMT2/AMZ2
       AXF   = AMT2*GMU/(8D0*PI2*SQRT(2D0))
       DRIRR = 3D0*AXF*(1D0+AMT4C*AXF+TBQCD0)
       SCALE = AL4PI/R1*(41D0/6D0-11D0/3D0*R)*ALR
* the leading HIGGS-contribution  (FOR IAMT4=3 11/12 --> 1/12)
       DRHIG1= 0d0
       DRHIGS= 0d0
       fachig= log(amh2/amw2)-5d0/6
       if(ihigs.eq.1.and.fachig.gt.0d0) then
        DRHIG1= al4pi/4/sw2                * 1d0/3*fachig
        DRHIGS= sqrt(2d0)*gmu*amw2/16/pi**2* 1d0/3*fachig
       endif
       DRREM = DR1FER+DR1BOS-DALFA1-TBQCDL-(DWZ1AL*AL4PI+SCALE)-DRHIG1
       DRHHS = -.005832D0*(AL1PI)**2/SW2**2*AMH2/AMW2
       DRREM = DRREM+DRHHS
       RENORM=SQRT(2D0)*GMU*AMZ2*R1*R*(1D0-DALFA)/PI*ALFAI
       DRBIG=1D0-(1D0+R/SW2*DRIRR-DRHIGS)*(1D0-DALFA)
     &   +((AL4PI*DWZ1AL+SCALE)+R/SW2*DRHO1)*RENORM
* end of HIGGS-modification
       DR=DRBIG+SCALER*DRREM
       RENORD=SQRT(2D0)*GMU*AMZ2*R1*R*(1D0-DRBIG)/PI*ALFAI
       IF(ISCRE.EQ.0) SCALER=1.00D0
       IF(ISCRE.EQ.1) SCALER=RENORD
       IF(ISCRE.EQ.2) SCALER=RENORM
       DR=DRBIG+SCALER*DRREM
*
*-----------------------------------------------------------------------
      ELSEIF(IAMT4 .EQ. 4) THEN
*-----------------------------------------------------------------------
       DRHO1 = .75D0*AL4PI/SW2/R*AMT2/AMZ2
       AXF   = AMT2*GMU/(8D0*PI2*SQRT(2D0))
       SCALEB = AL4PI/R1*(1D0/6D0+7D0*R)*ALR
       ANUMF  = 24D0
       TRQ2F  =  8D0
       SCALEF = -AL4PI/R1*(ANUMF/6-4D0/3*R1*TRQ2F)*ALR
       SCALE=SCALEB+SCALEF
* the leading HIGGS-contribution  (FOR IAMT4=3 11/12 --> 1/12)
       DRHIG1= 0d0
       DRHIGS= 0d0
       fachig= log(amh2/amw2)-5d0/6
       if(ihigs.eq.1.and.fachig.gt.0d0) then
        DRHIG1= al4pi/4/sw2                *1d0/3*fachig
        DRHIGS= sqrt(2d0)*gmu*amw2/16/pi**2*1d0/3*fachig
       endif
*
       IF(IHIG2.EQ.1) THEN
         DRHHS=-.005832*(AL1PI)**2/SW2**2*AMH2/AMW2
       ELSE
         DRHHS = 0D0
       ENDIF
*
* "Old" reminder DRREM, commented
*
*      DRREM=DR1FER+DR1BOS-DALFA1-TBQCDL-(DWZ1AL*AL4PI+SCALE)
*    &      -DRHIG1+DRHHS
*       print *,'DALFA1=',DALFA1
*       print *,'DALFA =',DALFA 
*       print *,'DRREM =',DRREM
*       print *,'DRLEA =',(DWZ1AL*AL4PI+SCALE)
*
* "New" reminder DRREM from NEWDR \equiv "Old" reminder DRREM
*
       CALL NEWDR(DALFAN,DRLEAN,DRREMN,DRREMK)
       DRREMD=DRREMK
       DRREM =DRREMN+TBQCD+2D0*CLQQCD+ALFQCD-TBQCDL+DRHHS
*
*       print *,'DALFAN=',DALFAN
*       print *,'DRREMN=',DRREM
*       print *,'DRLEAN=',DRLEAN
*       print *,'DRREM =',DRREM
*
       AMT=AMQ(5)
       PI3QF=1D0
*
* PI3QF=|QF|, new parameter of GDEGNL
*
       CALL GDEGNL
     & (GMU,AMZ,AMT,AMH,AMW,PI3QF,AMZ2,DRDREM,DRHOD,DKDREM,DROREM)
*
       DROBAR=3D0*AXF*TBQCD0-(AL4PI*DWZ1AL+SCALE)
     &       *SQRT(2D0)*GMU*AMZ2*R1**2/PI*ALFAI+DRHOD
       DROBLO=              -(AL4PI*DWZ1AL+SCALE)
     &       *SQRT(2D0)*GMU*AMZ2*R1**2/PI*ALFAI
*      
* Activation of old options (SCRE, EXPR) for DR:
*
* New game with SCALER, April 99
*
       RENORM=SQRT(2D0)*GMU*AMZ2*R1*R/PI*ALFAI
       IF(ISCRE.EQ.0) SCALER2=1.00D0
       IF(ISCRE.EQ.1) SCALER2=1D0/RENORM**2
       IF(ISCRE.EQ.2) SCALER2=1D0*RENORM**2
       IF(IFACR.EQ.0) THEN
* DRHHS added to main option IFACR=0
        DR=1D0-(1D0+R/SW2*DROBAR-DRHIGS)*(1D0-DALFA-DRREM 
     &        -(DRHHS+DRDREM)*SCALER2) 
        AAFAC=A0/SQRT(1D0-DR)
       ELSEIF(IFACR.EQ.1) THEN
        DR=1D0-(1D0+R/SW2*DROBAR-DRHIGS)*(1D0-DALFA-DRREM)
     &        +(DRHHS+DRDREM)*SCALER2
        AAFAC=A0/SQRT(1D0-DR)
       ELSEIF(IFACR.EQ.2) THEN
        DR=1D0-(1D0+R/SW2*DROBAR-DRHIGS)*(1D0-DALFA)
     &        +(1D0+R/SW2*DROBLO)*DRREM 
     &        +(DRHHS+DRDREM)*SCALER2
        AAFAC=A0/SQRT(1D0-DR)
       ENDIF
      DRBIG=DR
      ENDIF
*
* DR-options of YR(1994)
*
      IF(IAMT4.LE.3) THEN
       IF(IFACR.EQ.0) THEN
        AAFAC=A0/SQRT(1D0-DR)
       ELSEIF(IFACR.EQ.1) THEN
        AAFAC=A0*SQRT(1/(1-DRBIG)*(1+SCALER*DRREM/(1-DRBIG)))
       ELSEIF(IFACR.EQ.2) THEN
        AAFAC=A0*SQRT((1+SCALER*DRREM)/(1D0-DRBIG))
       ELSEIF(IFACR.EQ.3) THEN
        AAFAC=A0*SQRT(1/(1D0-DRBIG)+SCALER*DRREM)
       ELSE
        STOP
       ENDIF
      ENDIF
*
      END

      SUBROUTINE NEWDR(DALFA,DRLEA,DRREM,DRREMK)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      COMMON/CDZFLG/IHVP,IAMT4,IQCD,IMOMS,IMASS,IALEM,IMASK,IBARB,IFTJR
      COMMON/CDZSCT/ISCRE,ISCAL,IAFMT,IFACR,IFACT,IHIGS,IEWLC,ICZAK
     &             ,IHIG2,IALE2,IGFER      
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZZWG/AMZ,AMH,GMU,A0,GAMZ,GAMW,CALSZ,CALST,CALXI,CALQED
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
      COMMON/CDZWSC/SL2,SQ2,W0,W0F,Z0,Z0F,DWZ0R1,DWZ0F,XWM1,XWM1F,XZM1,
     &      XZM1F,XWZ1R1,XDWZ1F,XZFM1,XZFM1F,XAMM1,XAMM1F,XWFM1,XWFM1F
      COMMON/CDZ513/DAL5H
*
* This is done for a cross-check using the results from DB/GP
* It calculates leading, DRLEA, and reminder, DRREM, contributions to \dr
* using exactly final equation (7.405) from DB/GP
*
      ANUMF = 24D0
      TRQ2F =  8D0
*
      XLLA=(0D0,0D0)
      XLL =(0D0,0D0)
      DO 1 IL=1,3
      AML2=AML(2*IL)*AML(2*IL)
      XLLA=XLLA+6D0*XI3(AML2,-AMZ2,AML2,AML2)
      XLL =XLL +6D0*XI3(AMZ2,-AMZ2,AML2,AML2)
 1    CONTINUE
*
      XQQ5=(0D0,0D0)
      DO 2 IQ=1,6
      AMQ2=AMQ(IQ)*AMQ(IQ)
      IF(IQ.EQ.5) GO TO 2
      XQQ5=XQQ5+6D0*XI3(AMZ2,-AMZ2,AMQ2,AMQ2)*3D0*CQM(IQ)**2
 2    CONTINUE
C***** JEGERLEHNER/EIDELMAN
      IF(MOD(IALEM,2).EQ.0) THEN
        UDCSB=DAL5H
      ELSE
        UDCSB=DALH5(AMZ2,AMZ)     
      ENDIF
C*****
*
* NEWDR is unused again, DALFA1 is not modified
*
      DALFA1=UDCSB+AL4PI*4D0/3*DREAL(XLLA)
      DALFA =DALFA1
      DR1FER=DALFA1
     &      +AL1PI/3*(-4D0/3*LOG(AMQ(5)**2/AMZ2)-DREAL(XQQ5+XLL))
     &      +AL4PI/R1*(W0F-DREAL(XWM1F))
     &      +AL1PI/R1*ANUMF/24*LOG(R)
      DR1BOS=AL4PI*(-2D0/3D0
     &      +1D0/R1*(W0-DREAL(XWM1)
     &      -5D0/8D0*R*(1D0+R)+11D0/2D0+9D0/4D0*R/R1*ALR))
     &      -AL4PI/R1*(1D0/6+7D0*R)*LOG(R)
*
      DRREM=DR1FER+DR1BOS-DALFA1
      DRLEA=
     &      +AL4PI*R/R1*DREAL(XDWZ1F)
     &      +AL4PI/R1*(ANUMF/6-4D0/3*R1*TRQ2F)*(-LOG(R))
     &      +AL4PI*R/R1*DREAL(XWZ1R1)
     &      +AL4PI/R1*(1D0/6+7D0*R)*LOG(R)
*
      DRREMK=DR1BOS
* excluded following Guiseppe Degrassi
*     &      +AL1PI/3*(-4D0/3*LOG(AMQ(5)**2/AMZ2))
     &      +AL4PI/R1*(W0F-DREAL(XWM1F))
     &      +AL1PI/R1*ANUMF/24*LOG(R)
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
        ALFA=1.D0/ALFAIN
        ALFAPI=1.D0/PI/ALFAIN
      ENDIF
      T=ABS(S)
      IF(T.LT.0.3D0**2) THEN
        REPIAA=A1+B1*LOG(1.D0+C1*T)
      ELSEIF(T.LT.3.D0**2) THEN
        REPIAA=A2+B2*LOG(1.D0+C2*T)
      ELSEIF(T.LT.100.D0**2) THEN
        REPIAA=A3+B3*LOG(1.D0+C3*T)
      ELSE
        REPIAA=A4+B4*LOG(1.D0+C4*T)
      ENDIF
C     AS IMAGINARY PART TAKE -I ALFA/3 REXP
      XADRQQ=REPIAA-(0.D0,1.D0)*ALFA/3.*REXP(S)
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
        W=SQRT(S)
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
*
************************************************************************
*  ZWRATE - Z- AND W- BOSONS DECAY RATES, CALCULATES PARTIAL AND TOTAL *
*  WIDTHS OF Z- AND W- BOSONS WITH ACCOUNT OF ALL 1-LOOP ELECTROWEAK   *
*  AND QED CORRECTIONS (QCD CORRECTIONS ARE ALSO INCLUDED).            *
************************************************************************
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZFLG/IHVP,IAMT4,IQCD,IMOMS,IMASS,IALEM,IMASK,IBARB,IFTJR
      COMMON/CDZSCT/ISCRE,ISCAL,IAFMT,IFACR,IFACT,IHIGS,IEWLC,ICZAK
     &             ,IHIG2,IALE2,IGFER      
      COMMON/CDZZWG/AMZ,AMH,GMU,A0,GAMZ,GAMW,CALSZ,CALST,CALXI,CALQED
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     &      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
      COMMON/CDZTHR/AMTH(6)
*
      COMMON /CDZRKZ/ARROFZ(0:10),ARKAFZ(0:10),ARVEFZ(0:10),ARSEFZ(0:10)
     &              ,AROTFZ(0:10),AIROFZ(0:10),AIKAFZ(0:10),AIVEFZ(0:10)
      COMMON /CDZAUX/PARTZA(0:10),PARTZI(0:10),RENFAC(0:10),SRENFC(0:10)
*
      COMMON/CDZAQF/AQFI(10)
*
      COMMON/CDZDDZ/IDDZZ
*
      DIMENSION MCOLFZ(10),PARTZ(0:11),PARTW(3),QCDCOR(0:14)
      DIMENSION INDF(10),INDL(10),INDQ(10)
      DIMENSION MWFAC(2),AQFW(2)
      DIMENSION ARCZAK(0:6)
*
      DATA MWFAC/3,6/
      DATA INDF /2,1,1,1,4,3,4,3,4,5/
      DATA INDL /1,2,4,6,0,0,0,0,0,0/
      DATA INDQ /0,0,0,0,1,2,3,4,5,6/
      DATA MCOLFZ/1,1,1,1,3,3,3,3,3,3/
*
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
*
* AQFI - ARRAY OF FINAL PARTICLE CHARGES FOR PARTIAL Z- WIDTHS%
* T,TBAR DECAY CHANNEL IS ASSUMED TO BE ABOVE Z- THRESHOLD AND IS
* NOT ADDED TO THE TOTAL Z- WIDTH
*
      AQFW(1)=1.D0
      AQFW(2)=2.D0/3.D0
*
* Numerical implementation of Czarnecki-Kuehn's corrections
*
      IF(CALSZ.LE.1D-4) THEN
        DO ICZ=0,6
           ARCZAK(ICZ)=0D0
        ENDDO
      ELSE
        ARCZAK(0)= 0.D0
        ARCZAK(1)=-0.113D-3/3
        ARCZAK(2)=-0.160D-3/3
        ARCZAK(3)=-0.113D-3/3
        ARCZAK(4)=-0.160D-3/3
        ARCZAK(5)= 0.D0
        ARCZAK(6)=-0.040D-3/3
      ENDIF
*
* THE SAME FOR PARTIAL W- WIDTHS, HERE ONLY TWO CHANNELS EXIST IF ONE
* NEGLECTS FERMION MASSES. AGAIN T,BBBAR DECAY CHANNEL IS ASSUMED TO BE
*
      GAM0T=0.D0
      GAM0H=0.D0
      GAMWT=0.D0
      GAM1H=0.D0
      GAM1HA=0.D0
      GAM1HI=0.D0
      GAM1T =0.D0
      CONSTZ=GMU*AMZ**3/12.D0/PI/SQRT(2.D0)
*
* LOOP ON FERMIONS IN Z DECAY
*
      DO 3 INF=1,10
*
      CALL VERTZW(1,INDF(INF))
*
* THIS IS SOME INITIALIZATION SUBROUTINE FOR SUBSEQUENT CALCULATION
* OF THE ELECTROWEAK FORMFACTORS (SEE BELOW)
*
      IBFLA=0
      IF(INF.EQ.10) IBFLA=1
       CALL ROKAPP(AQFI(INF),IBFLA,DR,DRBIG,DRREM,ROFACI,ROFACL,ROFACR,
     &                                    SCALER,AKFACI,AKFACL,AKFACR)
       AK1IM=0D0
       AR1IM=0D0
      IF(IAMT4.EQ.4.AND.INF.NE.10) THEN
       CALL 
     & FOKAPP(AQFI(INF),DR,DRBIG,DRREM,SCALER,ROFACI,AKFACI,AR1IM,AK1IM)
      ENDIF  
*
* SUBROUTINE RETURNS EW-FORMFACTORS RO AND KAPPA 
*
      RAT=0D0
      SQR=1D0
      IF(INF.LE.4) THEN
       RAT=AML(INDL(INF))**2/AMZ2
      ELSEIF(INF.NE.9.AND.
     &  INF.GT.4.AND.ABS(QCDCOR((MAX(0,2*INDQ(INF)-1)))-1).LT.1D-8) THEN
       RAT=AMQ(INDQ(INF))**2/AMZ2
      ENDIF
      SQR=SQRT(1-4*RAT)
      IF(INF.EQ.9) THEN
        SQR=0D0
        ROFACI=0D0
        AKFACI=0D0
      ENDIF
*
      SINEFF=AKFACI*SW2M
*
      IF(INF.LE.4.OR.ABS(QCDCOR((MAX(0,2*INDQ(INF)-1)))-1).LT.1D-8) THEN
        RQCDV=1D0+0.75D0*CALQED/PI*AQFI(INF)**2
        RQCDA=RQCDV
      ELSE
        RQCDV=QCDCOR(MAX(0,2*INDQ(INF)-1))
        RQCDA=QCDCOR(MAX(0,2*INDQ(INF)  ))
      ENDIF
*
* DD-ZZ game, internal flag, not for 
*
*      print *,'IDDZZ=',IDDZZ
      IF(IDDZZ.EQ.0) THEN
        RQCDV=1D0
        RQCDA=1D0
      ENDIF
*
* GAM0I - PARTIAL WIDTH FOR I-TH CHANNEL IN THE BORN APPROXIMATION
*
       VF0L=1-4*SW2M*AQFI(INF)
       GAM0I=CONSTZ*SQR*((1+2*RAT)*(VF0L**2*RQCDV+RQCDA)/2-3*RAT*RQCDA)
*
* GAMWI - THE SAME BUT INCLUDING NON QED ELECTROWEAK 1-LOOP CORRECTIONS
* GAM1I - THE SAME BUT INCLUDING QED AND QCD CORRECTIONS TOO
*
      IF(IFACT.LE.3) THEN
       VF1L=1-4*SW2M*AQFI(INF)*AKFACI
       GAMWI=CONSTZ*ROFACI*SQR*((1+2*RAT)*(VF1L**2+1)/2-3*RAT)
       GAM1I=CONSTZ*ROFACI*SQR*((1+2*RAT)
     &     *((VF1L**2+16*SW2M**2*(AQFI(INF))**2*AK1IM**2)*RQCDV+RQCDA)/2
     &                            -3*RAT*RQCDA)
     &      +ICZAK*ARCZAK(INDQ(INF))
       GAM1IA=CONSTZ*ROFACI*SQR*((1+2*RAT)
     &      *(VF1L**2*RQCDV+RQCDA)/2-3*RAT*RQCDA)
     &      +ICZAK*ARCZAK(INDQ(INF))
       GAM1II=CONSTZ*ROFACI*SQR*(1+2*RAT)
     &      *(16*SW2M**2*(AQFI(INF))**2*AK1IM**2*RQCDV)/2
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
       GAM1I=CONSTZ*SQR*(ROFACL*((1+2*RAT)
     & *(((VF1LL**2+2*VF1LL*VF1LR)+16*SW2M**2*(AQFI(INF))**2*AK1IM**2)/2
     &                                    *RQCDV+RQCDA/2)-3*RAT*RQCDA)
     &                  +ROFACR*((1+2*RAT)*( VF1LL**2/2
     &                                    *RQCDV+RQCDA/2)-3*RAT*RQCDA) )
     &      +ICZAK*ARCZAK(INDQ(INF))
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
       GAM1I=CONSTZ*SQR*(ROFACL*((1+2*RAT)
     &      *((VF1LL**2+16*SW2M**2*(AQFI(INF))**2*AK1IM**2)/2
     &                                      *RQCDV+RQCDA/2)-3*RAT*RQCDA)
     &                  +ROFACL*((1+2*RAT)*VF1LL*VF1LR)
     &                  +ROFACR*((1+2*RAT)*( VF1LL**2+1)/2 -3*RAT)     )
     &      +ICZAK*ARCZAK(INDQ(INF))
      ENDIF
*
      NCF=1
      IF(INF.EQ.1) NCF=3
      GAM0T=GAM0T+GAM0I*MCOLFZ(INF)*NCF
      GAMWT=GAMWT+GAMWI*MCOLFZ(INF)*NCF
      IF(INF.GT.4) GAM0H =GAM0H +GAM0I *MCOLFZ(INF)*NCF
      IF(INF.GT.4) GAM1H =GAM1H +GAM1I *MCOLFZ(INF)*NCF
      IF(INF.GT.4) GAM1HA=GAM1HA+GAM1IA*MCOLFZ(INF)*NCF
      IF(INF.GT.4) GAM1HI=GAM1HI+GAM1II*MCOLFZ(INF)*NCF
      GAM1T=GAM1T+GAM1I*MCOLFZ(INF)*NCF
*
      PARTZ (INF-1)=GAM1I *1D3*MCOLFZ(INF)
      PARTZA(INF-1)=GAM1I *1D3*MCOLFZ(INF)
cbard    PARTZI(INF-1)=GAM1II*1D3*MCOLFZ(INF)
      PARTZI(INF-1)=0D0
*
      IF(INF.NE.9) THEN
        RENFAC(INF-1)=GAM1I/GAM1IA
      ELSE
        RENFAC(9)=1D0
      ENDIF
      SRENFC(INF-1)=SQRT(RENFAC(INF-1))
      ARROFZ(INF-1)=ROFACI*RENFAC(INF-1)
      AROTFZ(INF-1)=ROFACI
      ARKAFZ(INF-1)=AKFACI
      ARVEFZ(INF-1)=1D0-4D0*SW2M*AKFACI*AQFI(INF)
      ARSEFZ(INF-1)=SINEFF
      AIROFZ(INF-1)=AR1IM
      AIKAFZ(INF-1)=AK1IM
      AIVEFZ(INF-1)=-4D0*SW2M*AK1IM*AQFI(INF)
*
* GAM.T - CORRESPONDING TOTAL Z- WIDTHS WITHIN DIFFERENT APPROXIMATIONS
*
3     CONTINUE
*
* END LOOP ON FERMION FLAVORS IN Z DECAY
*
      GAMZ = GAM1T
      GAM1TZ=GAM1T
cbard      CORVEC=CONSTZ*3D0/2*(QCDCOR(13)-1)*1D3
      PARTZ (10)=GAM1H *1D3
      PARTZA(10)=GAM1H *1D3
cbard      PARTZI(10)=GAM1HI*1D3
      PARTZI(10)=0D0
      PARTZ (11)=GAM1T *1D3
*
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
* EXISTING IN THE W- DECAY CASE.
* THE OTHER IMPORTANT DIFFERENCE FROM Z- CASE IS THAT IT IS IMPOSSIBLE T
* DEFINE HERE QED- GAUGE INVARIANT SUBSET OF DIAGRAMS, FOR THIS REASON
* ONLY TOTAL 1-LOOP GAMMAS AND WIDTHS ARE CALCULATED FOR W- DECAY
* 
      GAM0I=CONSTW
      GAM1I=CONSTW*ROW
      DELT1I=(GAM1I/GAM0I-1.D0)*100.D0
      GAM0T=GAM0T+GAM0I*MWFAC(IND)
      GAM1T=GAM1T+GAM1I*MWFAC(IND)*QCDCOR(IND-1)
      PARTW(IND)=GAM1I*(2*IND-1)*1D3
7     CONTINUE
      DELT1T=(GAM1T/GAM0T-1.D0)*100.D0
      GAMW = GAM1T
      PARTW(3)=GAMW*1D3
*
      END
 
      SUBROUTINE ROKAPP(CH ,IBFLA,DR,DRBIG,DRREM,ROFACI,ROFACL,ROFACR,
     &                                    SCALER,AKFACI,AKFACL,AKFACR)
*
* Calculates RHO's and KAPPA's for partial Z-widths
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZFLG/IHVP,IAMT4,IQCD,IMOMS,IMASS,IALEM,IMASK,IBARB,IFTJR
      COMMON/CDZSCT/ISCRE,ISCAL,IAFMT,IFACR,IFACT,IHIGS,IEWLC,ICZAK
     &             ,IHIG2,IALE2,IGFER      
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
      COMMON/CDZZWG/AMZ,AMH,GMU,A0,GAMZ,GAMW,CALSZ,CALST,CALXI,CALQED
      COMMON/CDZWSC/SL2,SQ2,W0,W0F,Z0,Z0F,DWZ0R1,DWZ0F,XWM1,XWM1F,XZM1,
     &      XZM1F,XWZ1R1,XDWZ1F,XZFM1,XZFM1F,XAMM1,XAMM1F,XWFM1,XWFM1F
      COMMON/CDZVZW/V1ZZ,V1ZW,V2ZWW,V1WZ,V2WWZ,VTB
      COMMON/CDZ513/DAL5H
*
* Basic EW RHO and KAPPA
*
      CH2=CH*CH
      W0A  =W0+W0F
      ZM1A =DREAL(XZM1 +XZM1F )
      ZFM1A=DREAL(XZFM1+XZFM1F)
      WM1A =DREAL(XWM1 +XWM1F )
      AMM1A=DREAL(XAMM1+XAMM1F)
*
      UFF=(0.5D0/R-3.D0/R*CH*R1+6.D0*R12/R*CH2)*V1ZZ
     &   +(1.D0-2.D0*R-2.D0*CH*R1)*V1ZW
     &   +2.D0*R*V2ZWW+2.D0*VTB
*
      RO1=AL4PI/R1*(ZM1A+ZFM1A-W0A+5.D0/8.D0*R2+5.D0/8.D0*R
     &   -11.D0/2.D0-9.D0/4.D0*R/R1*ALR+UFF)
*
      AK1=AL4PI/R1*(R/R1*(ZM1A-WM1A)+AMM1A+R12/R*CH2*V1ZZ-.5D0*UFF)
*
* MIXED QCD-CORRECTIONS TO Z-WIDTH
*
      ALSZ=CALSZ
      ALST=CALST
      SW2=R1
      CW2=R
      SSZ=AMZ2
      ROQCD = 0D0
      AKQCD = 0D0
      AMT2=AMQ(5)**2
*
* Mixed QCD-corrections
*
      ROQCD=0D0
      AKQCD=0D0
*
      IF    (IQCD.EQ.1) THEN
        ROQCD=AL4PI*DREAL(XRQCDS(ALSZ,ALST,AMZ2,AMW2,AMT2,SSZ))
        AKQCD=AL4PI*DREAL(XKQCDS(ALST,AMZ2,AMW2,AMT2,SSZ))
      ELSEIF(IQCD.EQ.2) THEN
        ROQCD=AL4PI*DREAL(XROQCD(ALSZ,ALST,AMZ2,AMW2,AMT2,SSZ))
        AKQCD=AL4PI*DREAL(XKAQCD(ALST,AMZ2,AMW2,AMT2,SSZ))
      ELSEIF(IQCD.EQ.3) THEN
        ROQCD=AL1PI*ALST/PI*DREAL(XRMQCD(AMZ2,AMW2,AMT2,SSZ))
     &       +AL1PI*ALSZ/PI/8D0/SW2/CW2*(VT2+VB2+2D0)
* light quarks are added (25/02/1998), TWO doublets --> 2
        AKQCD=AL1PI*ALST/PI*DREAL(XKMQCD(AMZ2,AMW2,AMT2,SSZ))
     &       +AL1PI*ALSZ/PI*CW2/2D0/SW2**2*LOG(CW2)
      ENDIF
*
C-----------------------------------------------------------------------
C 13/10/1992 - Barbieri's m_t^4 are implemented
      IF(IBARB.EQ.-1) THEN
       AMT4C=0D0
       AMT4B=0D0
        ELSEIF(IBARB.EQ.0) THEN
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
      IF(IFTJR.EQ.0) THEN
        TAUBB1=-2*TOPX2
      ELSE
        TAUBB1=-2*TOPX2*(1-PI/3*CALST)
      ENDIF
      TAUBB2=-2*TOPX2*( +TOPX2*AMT4B)
      CORBB =+AL1PI/8/SW2*AMT2/AMW2
*
      ROFACI=1D0+RO1+ROQCD
      AKFACI=1D0+AK1+AKQCD
      ROFACM=ROFACI
      AKFACM=AKFACI
*
      DALFA=AL4PI*DREAL(XFOTF3(IALEM,IALE2,IHVP,IQCD,0,DAL5H,-AMZ2))
*
      RENORD=SQRT(2D0)*GMU*AMZ2*R1*R/PI*ALFAI
      RENORM=SQRT(2D0)*GMU*AMZ2*R1*R/PI*ALFAI
      IF(ISCRE.EQ.0) SCALER=1.00D0
      IF(ISCRE.EQ.1) SCALER=RENORD
      IF(ISCRE.EQ.2) SCALER=RENORM
*
*---- without Zbb-vertex -----------------------------------------------
*
      ROFACI=1D0+RO1+ROQCD+2*CORBB*IBFLA
      AKFACI=1D0+AK1+AKQCD-  CORBB*IBFLA
*
* IF(AMT4)
*
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
*
      ELSEIF(IAMT4 .EQ. 2) THEN
*
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
*
      ELSEIF(IAMT4 .GE. 3) THEN
*
       DWZ1AL=R/R1*DREAL(XWZ1R1+XDWZ1F)
       RENORM=SQRT(2D0)*GMU*AMZ2*R1*R/PI*ALFAI
       SCALE = AL4PI/R1*(41D0/6D0-11D0/3D0*R)*ALR
       CORKAP=(AL4PI*DWZ1AL+SCALE)+.75D0*AL4PI/SW2**2*AMT2/AMZ2
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
      IF(IAMT4.LE.3.OR.IBFLA.EQ.1) THEN
      IF(IEWLC.EQ.1) THEN
       IF(IFACT.EQ.0)THEN
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
      ELSEIF(IEWLC.EQ.0) THEN
       ROFACI=ROFACL
       AKFACI=AKFACL
      ELSE
       STOP
      ENDIF
      ENDIF
*
      END
 
      SUBROUTINE FOKAPP(CH,DR,DRBIG,DRREM,SCALER,ROFACI,AKFACI,AR1IM,
     &                  AK1IM)
*
* Calculates KAPPA's for Degrassi's sin^2\theta^{lept}_{eff}
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZFLG/IHVP,IAMT4,IQCD,IMOMS,IMASS,IALEM,IMASK,IBARB,IFTJR
      COMMON/CDZSCT/ISCRE,ISCAL,IAFMT,IFACR,IFACT,IHIGS,IEWLC,ICZAK
     &             ,IHIG2,IALE2,IGFER      
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
      COMMON/CDZZWG/AMZ,AMH,GMU,A0,GAMZ,GAMW,CALSZ,CALST,CALXI,CALQED
      COMMON/CDZWSC/SL2,SQ2,W0,W0F,Z0,Z0F,DWZ0R1,DWZ0F,XWM1,XWM1F,XZM1,
     &      XZM1F,XWZ1R1,XDWZ1F,XZFM1,XZFM1F,XAMM1,XAMM1F,XWFM1,XWFM1F
      COMMON/CDZVZW/V1ZZ,V1ZW,V2ZWW,V1WZ,V2WWZ,VTB
      COMMON/CDZDEG/DROBAR,DROBLO,DRREMD
      COMMON/CDZ513/DAL5H
*
* Basic EW RHO and KAPPA
*
      CH2=CH*CH
      W0A  =W0+W0F
      XZM1A =XZM1 +XZM1F 
      XZFM1A=XZFM1+XZFM1F
      XWM1A =XWM1 +XWM1F 
      XAMM1A=XAMM1+XAMM1F
*
      V1ZIM=DIMAG(XV1B(-AMZ2,AMZ2))
      V1WIM=DIMAG(XV1B(-AMZ2,AMW2))
      XV1ZZ=DCMPLX(V1ZZ,V1ZIM)
      XV1ZW=DCMPLX(V1ZW,V1WIM)
*
      XUFF=0.25D0/R*(1D0-6D0*CH*R1+12D0*R12*CH2)*XV1ZZ
     &    +(0.5D0-R-CH*R1)*XV1ZW+R*V2ZWW+VTB
*
      XRO1=AL4PI/R1*(DREAL(XZM1A+XZFM1A)-W0A+5.D0/8.D0*R*(1D0+R)
     &   -11.D0/2.D0-9.D0/4.D0*R/R1*ALR+2D0*XUFF)
*
      XAK1=AL4PI/R1*(R/R1*DREAL(XZM1A-XWM1A)
     &    +XAMM1A+R12/R*CH2*XV1ZZ-XUFF)
*
      RO1=SQRT((1D0+DREAL(XRO1))**2+(DIMAG(XRO1))**2)
      AK1=1D0+DREAL(XAK1)
*
* Mixed QCD-corrections to Z-widths
*
      ALSZ=CALSZ
      ALST=CALST
      SW2=R1
      CW2=R
      SSZ=AMZ2
      ROQCD = 0D0
      AKQCD = 0D0
      AMT2=AMQ(5)**2
*
      AKMIX=AL1PI*ALSZ/8D0/3D0/SW2**2*(2D0*SW2-1D0)
      AR1IM=DIMAG(XRO1)
      AK1IM=DIMAG(XAK1)+AKMIX        
*
      ROQCD=0D0
      AKQCD=0D0
*
      IF    (IQCD.EQ.1) THEN
        ROQCD=AL4PI*DREAL(XRQCDS(ALSZ,ALST,AMZ2,AMW2,AMT2,SSZ))
        AKQCD=AL4PI*DREAL(XKQCDS(ALST,AMZ2,AMW2,AMT2,SSZ))
      ELSEIF(IQCD.EQ.2) THEN
        ROQCD=AL4PI*DREAL(XROQCD(ALSZ,ALST,AMZ2,AMW2,AMT2,SSZ))
        AKQCD=AL4PI*DREAL(XKAQCD(ALST,AMZ2,AMW2,AMT2,SSZ))
      ELSEIF(IQCD.EQ.3) THEN
        ROQCD=AL1PI*ALST/PI*DREAL(XRMQCD(AMZ2,AMW2,AMT2,SSZ))
     &       +AL1PI*ALSZ/PI/8D0/SW2/CW2*(VT2+VB2+2D0)
* light quarks are added (25/02/1998), TWO doublets --> 2
        AKQCD=AL1PI*ALST/PI*DREAL(XKMQCD(AMZ2,AMW2,AMT2,SSZ))
     &       +AL1PI*ALSZ/PI*CW2/2D0/SW2**2*LOG(CW2)
      ENDIF
*
*-----------------------------------------------------------------------
*
      ROFACI=RO1+ROQCD
      AKFACI=AK1+AKQCD
      ROFACM=ROFACI
      AKFACM=AKFACI
*
      DALFA=DREAL(XFOTF3(IALEM,IALE2,IHVP,IQCD,0,DAL5H,-AMZ2))*AL4PI
*
* DALFA is used only in the scale of ADDIM, elsewhere one uses RENORM
*
*---- without Zbb-vertex -----------------------------------------------
*
       RENORM=SQRT(2D0)*GMU*AMZ2*R1*R/PI*ALFAI
* the same scale as in SEARCH
       SCALEB = AL4PI/R1*(1D0/6D0+7D0*R)*ALR
       ANUMF  = 24D0
       TRQ2F  =  8D0
       SCALEF = -AL4PI/R1*(ANUMF/6-4D0/3*R1*TRQ2F)*ALR
       SCALE=SCALEB+SCALEF
*
* to CORrect reminders:
*
       CORKAP=AL4PI*R/R1*(XDWZ1F+XWZ1R1)+SCALE
       CORRHO=R1/R*CORKAP
       DRHOT =.75D0*AL4PI/SW2/R*AMT2/AMZ2
       TOPX2 =GMU*AMT2/DSQRT(2.D0)/8.D0/PI2
*
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
*
       ROFACR=ROFACI      -TBQCDL+CORRHO-1
       AKFACR=AKFACI-R/SW2*TBQCDL+CORKAP-1
*
       AMW=SQRT(AMW2)
       AMT=AMQ(5)
       PI3QF=ABS(CH)
*    
       CALL GDEGNL
     & (GMU,AMZ,AMT,AMH,AMW,PI3QF,AMZ2,DRDREM,DRHOD,DKDREM,DROREM)
*
       DF1BAR=RENORM*DRREMD
*
* New game with SCALER, April 99  
*
      IF(ISCRE.EQ.0) SCALER2=1D0
      IF(ISCRE.EQ.1) SCALER2=1D0/RENORM**2
      IF(ISCRE.EQ.2) SCALER2=1D0*RENORM**2
*
      IF(IFACT.EQ.0)     THEN
       ROFAC=(1D0+RENORM*ROFACR+DROREM*SCALER2)
     &                          /(1D0-DROBAR*(1D0-DF1BAR))       
      ELSEIF(IFACT.EQ.1) THEN
       ROFAC=(1D0+RENORM*ROFACR)/(1D0-DROBAR*(1D0-DF1BAR))
     &                         +DROREM*SCALER2       
      ELSEIF(IFACT.EQ.2) THEN
       ROFAC=1D0+DROBAR-DROBLO*DF1BAR+DROBLO**2
     &           +RENORM*ROFACR*(1D0+DROBLO)
     &                         +DROREM*SCALER2       
      ENDIF
      ROFACI=ROFAC
      IF(IFACT.EQ.0) THEN
       AKFAC=(1D0+RENORM*AKFACR+DKDREM*SCALER2)
     &                          *(1D0+R/SW2*DROBAR*(1D0-DF1BAR))
      ELSEIF(IFACT.EQ.1) THEN
       AKFAC=(1D0+RENORM*AKFACR)*(1D0+R/SW2*DROBAR*(1D0-DF1BAR))
     &                         +DKDREM*SCALER2
      ELSEIF(IFACT.EQ.2) THEN
       AKFAC=1D0+R/SW2*DROBAR-R/SW2*DROBLO*DF1BAR
     &           +RENORM*AKFACR *(1D0+R/SW2*DROBLO)
     &                         +DKDREM*SCALER2
      ENDIF
*
      ADDIM=1D0/ALFAI**2/(1D0-DALFA)**2*35D0/18*(1D0-8D0/3*AKFAC*SW2)
      AKFACI=AKFAC+ADDIM/SW2 
      SINEFF=AKFACI*SW2
*cbardprint *,'CH,ADDIM,SINEFF=',CH,ADDIM,SINEFF 
*
* iterations are abandoned
*
      NOITER=0
      IF(NOITER.EQ.0) RETURN
      ADDIM=1D0/ALFAI**2/(1D0-DALFA)**2*35D0/18*(1D0-8D0/3*SINEFF)
      AKK=AL4PI*(DREAL(XAMFEF(-AMZ2,SINEFF))-DREAL(XAMM1F))+ADDIM
      AKFACI=AKFAC+AKK/SW2
      SINEFF=AKFACI*SW2
*
      ADDIM=1D0/ALFAI**2/(1D0-DALFA)**2*35D0/18*(1D0-8D0/3*SINEFF)
      AKK=AL4PI*(DREAL(XAMFEF(-AMZ2,SINEFF))-DREAL(XAMM1F))+ADDIM
      AKFACI=AKFAC+AKK/SW2
      SINEFF=AKFACI*SW2
*
      END
 
      SUBROUTINE VERTZW(MZ,INDF)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZVZW/V1ZZ,V1ZW,V2ZWW,V1WZ,V2WWZ,VTB
*
      IF(MZ) 5,8,5
*
* Z-BOSON CHAIN *********************
* FILLS CDZVZW (Z PART)
*
5     SR=SQRT(4.D0*R-1.D0)
      AT=ATAN(SR/(2.D0*R-1.D0))
      V1ZZ=-5.5D0-8.D0*(F1-SPENCE(2.D0))
      SPERR=SPENCE(1.D0+1.D0/R)
      V1ZW=-3.5D0-2.D0*R-(3.D0+2.D0*R)*ALR-2.D0*(1.D0+R)**2*(F1-SPERR)
      V2ZWW=2.D0/9.D0/R2+43.D0/18.D0/R-1.D0/6.D0-2.D0*R
     *     +(-1.D0/12.D0/R2-1.5D0/R+7.D0/3.D0+2.D0*R)*SR*AT
     *     -2.D0*R*(2.D0+R)*AT**2
*
      IF(INDF.EQ.5) THEN
*
       CALL VTBANA(1,AMZ2,WWv2,WWv11,WWv12)
       QBM=1D0/3D0
       VTB=R*WWv2-.5D0*(1D0-2D0*R1*(1D0-QBM))*WWv11-.5D0*WWv12
*
      ELSE
       VTB=0.D0
      ENDIF
      GO TO 9
*
* W-BOSON CHAIN *********************
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
*
      END

      SUBROUTINE VTBANA(NUNI,S,WWv2,WWv11,WWv12)   
*
* Supplies all ingredients for off-resonance EW finite m_t corrections
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
*
      RWS =AMW2/S
      AMT2=AMQ(5)**2
      RTW =AMT2/AMW2
      RTW1=RTW-1D0
      ALRT=LOG(RTW)
*
      CALL S3WANA(AMT2,AMW2,-S,XJ0W,XS3W,XS3W0)
      CALL S3WANA(AMW2,AMT2,-S,XJ0T,XS3T,XS3T0)
*
      AJ0W=DREAL(XJ0W)
      AJ0T=DREAL(XJ0T)
      S3W =DREAL(XS3W)
      S3W0=DREAL(XS3W0)
      S3T =DREAL(XS3T)
      S3T0=DREAL(XS3T0)
*
      WWv2 =-2D0*RWS*(2D0+RWS)*S*(S3w-S3w0)
     &      +RTW*((3D0*RWS**2+2.5D0*RWS-2D0-(2D0*RWS-.5D0)*RTW
     &           +RWS*(.5D0-RWS)*RTW**2)*S*S3w
     &           -(RWS+1D0-(.5D0-RWS)*RTW)*(AJ0w-2D0)
     &           +(2D0*RWS+3D0/2/RTW1**2-2D0/RTW1+1D0/2
     &           -(.5D0-RWS)*RTW)*ALRT
     &           -(RWS+3D0/2/RTW1+3D0/4-(.5D0-RWS)*RTW)
     &           +.25D0/RWS*(AJ0w-3D0)*NUNI
     &           )
      WWv11=+2D0*(1D0+RWS)**2*S*(S3t-S3t0)
     &      +(2D0*RWS+3D0)*(AJ0t+ALRT+LOG(RWS))
     &      -RTW*(RWS*(3D0*RWS+2D0-RTW-RWS*RTW**2)*S*S3t
     &           +(RWS+.5D0+RWS*RTW)*(AJ0t+ALRT-2D0)
     &           -(2D0*RWS+3D0/2/RTW1**2-2D0/RTW1+1D0/2+RWS*RTW)*ALRT
     &           +RWS+3D0/2/RTW1+5D0/4+RWS*RTW
     &           ) 
      WWv12=-RTW*(RWS*(2D0+RWS-2D0*RWS*RTW+RWS*RTW**2)*S*S3t
     &           -(.5D0-RWS+RWS*RTW)*(AJ0t+ALRT-1D0)+RWS*RTW*ALRT
     &           )
*
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
      COMMON/CDZVZW/V1ZZ,V1ZW,V2ZWW,V1WZ,V2WWZ,VTB
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
*
      END

      SUBROUTINE ROKANC(IBOXF,IBFLA,S,Q2,U,QI,QJ,XROK,XFOT,XFOT5)
*
* BEFORE USE OF ROKANC, AT LEAST ONE CALL OF DIZET MUST BE DONE.
* SEE ALSO THE COMMENTS THERE.
*---------------------------------------------------------------------
* THIS ROUTINE CALCULATES THE WEAK NEUTRAL CURRENT FORM FACTORS FOR
* THE 4-FERMION SCATTERING CROSS SECTION. ALSO: THE RUNNING ALPHA.QED.
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
      COMMON/CDZSCT/ISCRE,ISCAL,IAFMT,IFACR,IFACT,IHIGS,IEWLC,ICZAK
     &             ,IHIG2,IALE2,IGFER      
      COMMON/CDZWSM/AMW2,AMZ2,R,R1,R12,R2,AMH2,RW,RW1,RW12,RW2,RZ,RZ1,
     *      RZ12,RZ2,ALR,ALRW,ALRZ,SW2M,CW2M,AKSX,R1W,R1W2
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
      COMMON/CDZZWG/AMZ,AMH,GMU,A0,GAMZ,GAMW,CALSZ,CALST,CALXI,CALQED
      COMMON/CDZWSC/SL2,SQ2,W0,W0F,Z0,Z0F,DWZ0R1,DWZ0F,XWM1,XWM1F,XZM1,
     &      XZM1F,XWZ1R1,XDWZ1F,XZFM1,XZFM1F,XAMM1,XAMM1F,XWFM1,XWFM1F
      COMMON/CDZVZW/V1ZZ,V1ZW,V2ZWW,V1WZ,V2WWZ,VTB
      COMMON/CDZXKF/XROKF
      COMMON/CDZRLR/ROKL(4),ROKR(4),AROK(4)
      COMMON/CDZDEG/DROBAR,DROBLO,DRREMD
      COMMON/CDZ513/DAL5H
      COMMON/CDZ_LK/IMTADD
*
      DIMENSION XROK(4),XROKIN(4)
*
      AMT2=AMQ(5)**2
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
      XRFL3=XL(Q2,AMW2,AMW2)/Q2
      XROBZ=17D0/6D0-5D0/6D0*XRFL3
      IF(IBFLA.EQ.1) THEN
        XROBT=AMT2/AMW2/4*(3D0-1D0/2*XRFL3)
      ELSE
        XROBT=(0D0,0D0)
      ENDIF
      Q2M=ABS(Q2)
      ALSZ=CALSZ
      ALST=CALST
      SW2=R1
      CW2=R
*
* Mixed QCD-corrections
*
      XZERO=DCMPLX(0.D0,0.D0)
      XRQCD=XZERO
      XKQCD=XZERO
*
      IF    (IQCD.EQ.1) THEN
        XRQCD=AL4PI*XRQCDS(ALSZ,ALST,AMZ2,AMW2,AMT2,Q2M)
        XKQCD=AL4PI*XKQCDS(ALST,AMZ2,AMW2,AMT2,Q2M)
      ELSEIF(IQCD.EQ.2) THEN
        XRQCD=AL4PI*XROQCD(ALSZ,ALST,AMZ2,AMW2,AMT2,Q2M)
        XKQCD=AL4PI*XKAQCD(ALST,AMZ2,AMW2,AMT2,Q2M)
      ELSEIF(IQCD.EQ.3) THEN
* are added (25/02/1998) and tested (05/12/1998)
       IF(ABS(1D0-Q2M/AMZ2).LT.1D-3) THEN
        XRQCD=AL1PI*ALST/PI*XRMQCD(AMZ2,AMW2,AMT2,Q2M)
     &       +AL1PI*ALSZ/PI/8D0/SW2/CW2*(VT2+VB2+2D0)
       ELSE
        XRQCD=AL1PI*ALST/PI*XRMQCD(AMZ2,AMW2,AMT2,Q2M)
     &       -AL1PI*ALSZ/PI/8D0/SW2/CW2*(VT2+VB2+2D0)
     &                   *Q2M/(AMZ2-Q2M)*LOG(Q2M/AMZ2)
       ENDIF
* light quarks are added (25/02/1998) and tested (05/12/1998)  
* Qum^2+Qdm^2=5/9 and two doublets
        XKQCD=AL1PI*ALST/PI*XKMQCD(AMZ2,AMW2,AMT2,Q2M)
     &       +DCMPLX(AL1PI*ALSZ/PI/2D0/SW2**2*(CW2*LOG(CW2)
     &                -SW2*(1D0-20D0/9D0*SW2)*LOG(Q2M/AMZ2))
     &              ,AL1PI*ALSZ/8D0/3D0/SW2**2*(2D0*SW2-1D0))      
      ENDIF
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
      XWWP= (1D0+SI*SJ)/2D0*(XBOX(IBFLA,AI11,AI12,AMW2)
     &     +4.D0*(AI11/SB)**2*XJ3(SB,AMW2) )
* This is with March'95 corrections
* Still could be wrong! Attention of sign!!!
      XWWM=-(1D0-SI*SJ)/2D0*2.D0*(AI11/SB)**2
     &     *(AI11/SB*XJ4(SB,AI11,AMW2)+2.D0*XJ3(SB,AMW2))
      XZZP=  XBOX(0,AI11,AI12,AMZ2)
     &     -2.D0*(AI11/SB)**3*XJ4(SB,AI11,AMZ2)
      XZZM=-(XBOX(0,AI12,AI11,AMZ2)
     &     -2.D0*(AI12/SB)**3*XJ4(SB,AI12,AMZ2))
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
      XROK(1)=1.D0+AL4PI/R1*(CONST+XDBAL+2.D0*R*XV2BW+XROBZ-XROBT
     *       +(-2.D0*R+0.5D0+(VI+VJ)/4.D0)*XV1BW
     *       +(1.D0+3.D0/2.D0*(VI**2+VJ**2))/8.D0/R*XV1BZ)
     *       +XRQCD
      XROK(1)=XROK(1) + IBOXF*AL4PI/R1*(XZZRO+XWWRO)
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
     *       -XROBZ+XROBT
     *       +(2.D0*R-QIM-(VI+VJ)/4.D0+(1.D0-QIM)*AMW2/Q2)*XV1BW
     *       +(-VJ*(1.D0+VJ)/8.D0/R-QIM*VI/2.D0*(1.D0+AMZ2/Q2))*XV1BZ)
     *       +XKQCD
      XROK(3)=XROK(3) + IBOXF*AL4PI/R1*(XZZJ-XWWRO)
*
*  XROK(4)=KAPPA WITH INDEXES I AND J
      XROK(4)=1.D0+AL4PI/R1*(-2.D0*WZ1AL+2.D0*XFMF+(-R+AMW2/Q2)*XA1BW
     *       -4.D0/3.D0*R+35.D0/18.D0-2.D0/3.D0*XRFL3-2.D0*R*XV2BW
     *       -XROBZ+XROBT+(2.D0*R-0.5D0-(VI+VJ)/4.D0)*XV1BW
     *       +(-1.D0/8.D0/R-3.D0*(VI**2+VJ**2)/16.D0/R
     *       +(QI**2+QJ**2)*R1/R*(1.D0+AMW2/Q2))*XV1BZ)
     *       +2.D0*XKQCD
      XROK(4)=XROK(4) + IBOXF*AL4PI/R1*(XZZIJ-XWWRO)
*
C-----------------------------------------------------------------------
      IF(IBARB.EQ.0.OR.IBARB.EQ.-1) THEN
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
*
* AMT4=3 option should work for bb-channel at AMT4=4, since 
*        Degrassi's corrections are not known for bb-channel       
*
      ELSEIF(IAMT4.EQ.3.OR.(IAMT4.EQ.4.AND.IBFLA.EQ.1)) THEN
*
       DWZ1AL=R/R1*DREAL(XWZ1R1+XDWZ1F)
       RENORM=SQRT(2D0)*GMU*AMZ2*R1*R/PI*ALFAI
       SCALE = AL4PI/R1*(41D0/6D0-11D0/3D0*R)*ALR
       CORKAP=(AL4PI*DWZ1AL+SCALE)+.75D0*AL4PI/SW2**2*AMT2/AMZ2
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
*-----------------------------------------------------------------------
*
* bb-channel modification
*
      IF(IBFLA.EQ.1) THEN
************************************************************************
* Obsolete comment:
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
      IF(IBARB.EQ.0.OR.IBARB.EQ.-1) THEN
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
      TOPX2 = GMU*AMT2/DSQRT(2.D0)/8.D0/PI2
      IF(IFTJR.EQ.1) THEN
        TAUBB1=-2*TOPX2*(1-PI/3*CALST)
      ELSE
        TAUBB1=-2*TOPX2
      ENDIF
      TAUBB2=-2*TOPX2*( +TOPX2*AMT4B)
*                       
* New, s-dependent bb-corrections
*
      IF(IMTADD.EQ.1) THEN
        CALL VTBANA(0,AMZ2,WWv2,WWv11,WWv12)
      ELSE
        CALL VTBANA(0,SB,WWv2,WWv11,WWv12)
      ENDIF
*
* WW-box via XBOX
*
      QBM=1D0/3D0
      VTBX1=R*WWv2-.5D0*(1D0-2D0*R1*(1-QBM))*WWv11-.5D0*WWv12
      VTBX2=R*(AMZ2/SB-1D0)*(-(1D0-QBM)*WWv11+WWv2)
*
* VTBX1 is asymptotically -AMT2/AMW2/2
*
      DVTBB1=AL4PI*VTBX1/R1-AL1PI/4/SW2*(-AMT2/AMW2/2)
      DVTBB2=AL4PI*VTBX2/R1
*
      ROKR(1)=ROKR(1)+DVTBB1
      ROKR(2)=ROKR(2)+DVTBB2
      ROKR(3)=ROKR(3)-DVTBB1
      ROKR(4)=ROKR(4)-DVTBB1
*
      ROKL(1)=ROKL(1)*(1+(TAUBB1+TAUBB2)*IBFLA)
* 25/11/1998, confirm correctness of commenting, db
*     ROKL(2)=ROKL(2)/(1+(TAUBB1+TAUBB2)*IBFLA)
      ROKL(3)=ROKL(3)/(1+(TAUBB1+TAUBB2)*IBFLA)
      ROKL(4)=ROKL(4)/(1+(TAUBB1+TAUBB2)*IBFLA)
*
* End of bb-channel modification
*
      ENDIF
*
* Game with options for AMT4 < 4 only
*
      IF(IAMT4.LT.4.OR.IBFLA.EQ.1) THEN
      IF(IFACT.EQ.0) THEN
       XROKIN(1)=DCMPLX(1/(1/ROKL(1)-SCALER*ROKR(1)),AROK(1))
       XROKIN(2)=DCMPLX(ROKL(2)*(1+SCALER*ROKR(2)),AROK(2))
       XROKIN(3)=DCMPLX(ROKL(3)*(1+SCALER*ROKR(3)),AROK(3))
       XROKIN(4)=DCMPLX(ROKL(4)*(1+SCALER*ROKR(4)),AROK(4))
      ELSEIF(IFACT.EQ.1) THEN
       XROKIN(1)=DCMPLX(ROKL(1)*(1+SCALER*ROKR(1)*ROKL(1)),AROK(1))
       XROKIN(2)=DCMPLX(ROKL(2)+SCALER*ROKR(2),AROK(2))
       XROKIN(3)=DCMPLX(ROKL(3)+SCALER*ROKR(3),AROK(3))
       XROKIN(4)=DCMPLX(ROKL(4)+SCALER*ROKR(4),AROK(4))
      ELSEIF(IFACT.EQ.2) THEN
       XROKIN(1)=DCMPLX(ROKL(1)*(1+SCALER*ROKR(1)),AROK(1))
       XROKIN(2)=DCMPLX(ROKL(2)+SCALER*ROKR(2),AROK(2))
       XROKIN(3)=DCMPLX(ROKL(3)+SCALER*ROKR(3),AROK(3))
       XROKIN(4)=DCMPLX(ROKL(4)+SCALER*ROKR(4),AROK(4))
      ELSEIF(IFACT.EQ.3) THEN
       XROKIN(1)=DCMPLX(ROKL(1)+SCALER*ROKR(1),AROK(1))
       XROKIN(2)=DCMPLX(ROKL(2)+SCALER*ROKR(2),AROK(2))
       XROKIN(3)=DCMPLX(ROKL(3)+SCALER*ROKR(3),AROK(3))
       XROKIN(4)=DCMPLX(ROKL(4)+SCALER*ROKR(4),AROK(4))
      ELSE
       XROKIN(1)=DCMPLX(ROKL(1),AROK(1))
       XROKIN(2)=DCMPLX(ROKL(2),AROK(2))
       XROKIN(3)=DCMPLX(ROKL(3),AROK(3))
       XROKIN(4)=DCMPLX(ROKL(4),AROK(4))
         ROKR(1)=SCALER*ROKR(1)
         ROKR(2)=SCALER*ROKR(2)
         ROKR(3)=SCALER*ROKR(3)
         ROKR(4)=SCALER*ROKR(4)
      ENDIF
      ENDIF
*
* End of options
*
*-----------------------------------------------------------------------
*
* New option AMT4=4
*
      IF(IAMT4.EQ.4.AND.IBFLA.EQ.0) THEN
*
       RENORM=SQRT(2D0)*GMU*AMZ2*R1*R/PI*ALFAI
* the same scale as in SEARCH
       SCALEB = AL4PI/R1*(1D0/6D0+7D0*R)*ALR
       ANUMF  = 24D0
       TRQ2F  =  8D0
       SCALEF = -AL4PI/R1*(ANUMF/6-4D0/3*R1*TRQ2F)*ALR
       SCALE=SCALEB+SCALEF       
       CORKAP=AL4PI*R/R1*(XDWZ1F+XWZ1R1)+SCALE
       CORRHO=R1/R*CORKAP
       DRHOT = .75D0*AL4PI/SW2/R*AMT2/AMZ2
       TOPX2 = GMU*AMT2/DSQRT(2.D0)/8.D0/PI2
*
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
*
       AMW=SQRT(AMW2)
       AMT=AMQ(5)
       PI3QE=ABS(QI)
       PI3QF=ABS(QJ)
*    
       CALL GDEGNL
     & (GMU,AMZ,AMT,AMH,AMW,PI3QE,Q2M,DRDREM,DRHOD,DKDREE,DROREE)
       CALL GDEGNL
     & (GMU,AMZ,AMT,AMH,AMW,PI3QF,Q2M,DRDREM,DRHOD,DKDREF,DROREF)
*    
       DF1BAR=RENORM*DRREMD
       DROREM=.5D0*(DROREE+DROREF)
*
cb     ROFACR=ROFACI      -TBQCDL+CORRHO-1
cb     AKFACR=AKFACI-R/SW2*TBQCDL+CORKAP-1
cb     ROFAC=(1D0+RENORM*ROFACR+DROREM)/(1D0      -DROBAR*(1D0-DF1BAR))
cb     AKFAC=(1D0+RENORM*AKFACR+DKDREM)*(1D0+R/SW2*DROBAR*(1D0-DF1BAR))
*
       ROKL(1)=1D0/(1D0-DROBAR*(1D0-DF1BAR))
       ROKR(1)=1D0+DREAL(RENORM*(XROK(1)-TBQCDL+CORRHO-1D0)+DROREM)
       XROKIN(1)=DCMPLX(ROKL(1)*ROKR(1),DIMAG(XROK(1)))
*
       ROKL(2)=1D0+R/SW2*DROBAR*(1D0-DF1BAR)
       ROKR(2)=1D0
     &        +DREAL(RENORM*(XROK(2)-R/SW2*TBQCDL+CORKAP-1D0)+DKDREE)
       XROKIN(2)=DCMPLX(ROKL(2)*ROKR(2),DIMAG(XROK(2)))
*
       ROKL(3)=1D0+R/SW2*DROBAR*(1D0-DF1BAR)
       ROKR(3)=1D0
     &        +DREAL(RENORM*(XROK(3)-R/SW2*TBQCDL+CORKAP-1D0)+DKDREF)
       XROKIN(3)=DCMPLX(ROKL(3)*ROKR(3),DIMAG(XROK(3)))
*
       ROKL(4)=(1D0+R/SW2*DROBAR*(1D0-DF1BAR))**2
       ROKR(4)=1D0
     &        +DREAL(RENORM*(XROK(4)-2D0*R/SW2*TBQCDL+2D0*CORKAP-1D0)
     &        +DKDREE+DKDREF)
       XROKIN(4)=DCMPLX(ROKL(4)*ROKR(4),DIMAG(XROK(4)))
*
      ENDIF
*
      DO IRK=1,4
        XROK(IRK)=XROKIN(IRK)
      ENDDO
*
*-----------------------------------------------------------------------
* 
* PHOTON FORMFACTOR
*
      IF(IALE2.EQ.0) THEN
        XFOT =1D0+AL4PI*XFOTF3(IALEM,    1,IHVP,IQCD,1,DAL5H,Q2)
        XFOT5=1D0+AL4PI*XFOTF3(IALEM,    1,IHVP,   0,0,DAL5H,Q2)
      ELSE
        XFOT =1D0+AL4PI*XFOTF3(IALEM,IALE2,IHVP,IQCD,1,DAL5H,Q2)
        XFOT5=1D0+AL4PI*XFOTF3(IALEM,IALE2,IHVP,   0,0,DAL5H,Q2)
      ENDIF
*
* Release for running quantities inside XFOTF3
*
      END

      SUBROUTINE J3WANA(MT2,MW2,AMI2,J3W)
*
      IMPLICIT NONE
      REAL*8 MT2,MW2,AMI2
      COMPLEX*16 AMT2,AMW2,J3W,DCMPLX,XSPENZ
*
      AMT2=DCMPLX(MT2,-1D-10)
      AMW2=DCMPLX(MW2,-1D-10)
*
      J3W=1D0/AMI2*(XSPENZ(1D0-AMT2/AMW2)
     &             -XSPENZ(1D0-AMT2/AMW2-AMI2/AMW2))
*
      RETURN
      END

      SUBROUTINE S3WANA(MT2,MW2,AMQ2,J0,S3,S30)
*
* Supplies real parts of J0,S3,S30 (w,t) in analytic presentation
* CALL S3ANA(MT2,MW2,-S,...) supplies `w' indices
* CALL S3ANA(MW2,MT2,-S,...) supplies `t' indices
*
      IMPLICIT NONE
      REAL*8 MT2,MW2,AMQ2
      REAL*8 PI,PI2,D2,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMPLEX*16 AMT2,AMW2
      COMPLEX*16 SQR,LQR,X0,X1,X2,X3
      COMPLEX*16 Y1,Y2,Y3,Y4,Y5,Y6,J0,S3,S30
      COMPLEX*16 XSPENZ,LOG,SQRT
c      COMPLEX*16 A1,A2,A3,A4,A5,A6
*
      COMMON/CDZCON/PI,PI2,D2,D3,ALFAI,AL4PI,AL2PI,AL1PI
*
      AMT2=DCMPLX(MT2,-1D-10)
      AMW2=DCMPLX(MW2,-1D-10)
*
      SQR=SQRT(1D0+4D0*AMW2/AMQ2)
*
      LQR=LOG((SQR+1D0)/(SQR-1D0))
      J0 =SQR*LQR
      IF(MT2.GT.MW2) THEN
        S30=1D0/AMQ2*LQR**2
      ELSE
        S30=1D0/AMQ2*(D2-XSPENZ(1D0-AMQ2/AMT2))
      ENDIF
*
      X1=(1D0-SQR)/2D0
      X2=(1D0+SQR)/2D0
      X0=(AMT2-AMW2)/AMQ2
      X3=AMT2/(AMT2-AMW2)
*
      Y1=X1/X0
      Y2=(1D0-X1)/(1D0-X0)
      Y3=X2/X0
      Y4=(1D0-X2)/(1D0-X0)
      Y5=X3/X0
      Y6=(1D0-X3)/(1D0-X0)
*
c      A1=1D0/(1D0-Y1)
c      A2=1D0/(1D0-Y2)
c      A3=1D0/(1D0-Y3)
c      A4=1D0/(1D0-Y4)
c      A5=1D0/(1D0-Y5)
c      A6=1D0/(1D0-Y6)
*
      S3=1D0/AMQ2*(XSPENZ(1D0/(1D0-Y1))-XSPENZ(1D0/(1D0-Y2))
     &            +XSPENZ(1D0/(1D0-Y3))-XSPENZ(1D0/(1D0-Y4))
     &            -XSPENZ(1D0/(1D0-Y5))+XSPENZ(1D0/(1D0-Y6)))
c      S3=1D0/AMQ2*(XSPENZ(A1)-XSPENZ(A2)
c     &            +XSPENZ(A3)-XSPENZ(A4)
c     &            -XSPENZ(A5)+XSPENZ(A6))
*
      RETURN
      END
 
      SUBROUTINE S4WANA(MT2,MW2,AMQ2,AMI2,S4W)
*
      IMPLICIT NONE
      REAL*8 MT2,MW2,AMQ2,AMI2
      COMPLEX*16 AMT2,AMW2,S4W
      COMPLEX*16 SQW,SQB,X1,X2,X3,X4,X1B,X2B
      COMPLEX*16 Y1,Y2,Y3,Y4,Y5,Y6,Y7,Y8,Y9,Y10,Y11,Y12,Y13,Y14,Y15,Y16
      COMPLEX*16 DCMPLX,SQRT,XSPENZ
*
      AMT2=DCMPLX(MT2,-1D-10)
      AMW2=DCMPLX(MW2,-1D-10)
*
      SQW=SQRT(1D0+4D0*AMW2/AMQ2)
      SQB=SQRT(1D0+4D0*AMW2/AMQ2*AMI2*(AMT2+AMI2-AMW2)/(AMT2+AMI2)**2)
      X1 =1D0/2D0*(1D0-SQW)
      X2 =1D0/2D0*(1D0+SQW)
      X3 =1D0/(1D0-AMW2/AMT2)
      X4 =1D0/(1D0-AMW2/(AMT2+AMI2))
      X1B=X4/2D0*(1D0-SQB)
      X2B=X4/2D0*(1D0+SQB)
*
      Y1 =X1/X1B
      Y3 =X2/X1B
      Y5 =X4/X1B
      Y7 =X3/X1B
      Y9 =X1/X2B
      Y11=X2/X2B
      Y13=X4/X2B
      Y15=X3/X2B
*
      Y2 =(X1-1D0)/(X1B-1D0)
      Y4 =(X2-1D0)/(X1B-1D0)
      Y6 =(X4-1D0)/(X1B-1D0)
      Y8 =(X3-1D0)/(X1B-1D0)
      Y10=(X1-1D0)/(X2B-1D0)
      Y12=(X2-1D0)/(X2B-1D0)
      Y14=(X4-1D0)/(X2B-1D0)
      Y16=(X3-1D0)/(X2B-1D0)
*
      S4W=1D0/(AMQ2*(AMT2+AMI2)*SQB)*(
     &     +XSPENZ(1D0/(1D0-Y1 ))-XSPENZ(1D0/(1D0-Y2 ))
     &     +XSPENZ(1D0/(1D0-Y3 ))-XSPENZ(1D0/(1D0-Y4 ))
     &     +XSPENZ(1D0/(1D0-Y5 ))-XSPENZ(1D0/(1D0-Y6 ))
     &     -XSPENZ(1D0/(1D0-Y7 ))+XSPENZ(1D0/(1D0-Y8 ))
     &     -XSPENZ(1D0/(1D0-Y9 ))+XSPENZ(1D0/(1D0-Y10))
     &     -XSPENZ(1D0/(1D0-Y11))+XSPENZ(1D0/(1D0-Y12))
     &     -XSPENZ(1D0/(1D0-Y13))+XSPENZ(1D0/(1D0-Y14))
     &     +XSPENZ(1D0/(1D0-Y15))-XSPENZ(1D0/(1D0-Y16))
     &     )
*
      RETURN
      END
 
      SUBROUTINE RHOCC(S,Q2,U,QI,QJ,QK,QL,ROW)
* ------ FORMER NAME OF THE ROUTINE: ROWAL
* BEFORE USE OF RHOCC AT LEAST ONE CALL OF DIZET MUST BE DONE.
* SEE ALSO THE COMMENTS THERE.
*---------------------------------------------------------------------
* THIS ROUTINE CALCULATES THE WEAK CHARGED CURRENT FORM FACTOR FOR
* THE 4-FERMION SCATTERING CROSS SECTION. 
*----------------------------------------------------------------------
* EXAMPLES OF THE USE OF THIS ROUTINE MAY BE FOUND IN THE PACKAGE
* HECTOR, Comp. Phys. Commun. 94 (1996) 128 [hep-ph/9511434] 
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
* DERIVATIVE OF XPDF  IS STILL MISSING 
*
      XDPWF=(0D0,0D0)
*
      END
 
      FUNCTION XDPWFI(ALTW)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
* DERIVATIVE OF XPDFI IS STILL MISSING
*
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
*
      IMPLICIT REAL*8(A-H,J-Z)
*
      COMMON/CDZSCT/ISCRE,ISCAL,IAFMT,IFACR,IFACT,IHIGS,IEWLC,ICZAK
     &             ,IHIG2,IALE2,IGFER      
      COMMON/CDZZWG/CAMZ,CAMH,GMU,A0,GAMZ,GAMW,CALSZ,CALST,CALXI,CALQED
      COMMON /CDZZER/ PI,ALPHAQ,ANF,AKC,AKB
      COMMON /CDZPHM/ CMASS,BMASS,TMASS,SMRUN1
      COMMON /CDZINP/ BMASSI
      COMMON /CDZRUN/ CMQRUN(8)
      COMMON /CDZBGC/ BETA03,BETA13,BETA23,GAMA03,GAMA13,GAMA23,
     &                BETA04,BETA14,BETA24,GAMA04,GAMA14,GAMA24,
     &                BETA05,BETA15,BETA25,GAMA05,GAMA15,GAMA25,
     &                COEF13,COEF23,COEF14,COEF24,COEF15,COEF25,
     &                ALMSB3,ALMSB4,ALMSB5,ALMSB6,ALF1PI,ALFCPI,ALFBPI,
     &                AMSAMC,AMSAMB,AMCAMC,AMCAMB,AMBAMB
      COMMON /CDZBG3/ BETA33,BETA34,BETA35,GAMA33,GAMA34,GAMA35
*
      DIMENSION QCDCOR(0:14),QCDCON(0:14)
      DIMENSION AMQRUN(6),CHARQU(6)
      DIMENSION QCDC2V(6),QCDC2A(6),QCDC4V(6),QCDC4A(6)
      DIMENSION SCTAVR(6),SCTPLU(6),SCTMIN(6)
*
      EXTERNAL ZALPHA,ZALSFL,ZRMCIN,ZRMCMC,ZRMBMB
*
      DATA AMQRUN/0D0,0D0,.750D0,0D0,0D0,2.40D0/
      DATA SCTAVR/.20D0,.19D0,.18D0,.17D0,.15D0,.13D0/
      DATA SCTPLU/.09D0,.10D0,.10D0,.10D0,.09D0,.08D0/
      DATA SCTMIN/.05D0,.04D0,.04D0,.04D0,.04D0,.04D0/
      DATA icont/0/  !stj
*
* ISCAL=1,2,3 ARE NOT UP TO DATE, SEE KNIEHL's CONTRIBUTION:
* GAMES WITH THE SCALE FOR THE ALFA*ALFAS(SCALET*AMT) CORRECTIONS
*
      AMZ =CAMZ
      AMZ2=AMZ**2
cbardin    SQS=AMZ
cbardin    SQS=15D0
*
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
* HEAVY QUARK POLE MASSES (DB/GP-CONVENTION)
*
      SMASS=0.3D0
      CMASS=1.5D0
      BMASS=4.7D0
      TMASS=AMT
*
* S-QUARK RUNNING MASS AT 1 GEV
*
      SMRUN1=.189D0
*
      ALFAT=0D0
      ALFAXI=0D0
*
      DO IQ=0,14
       QCDCOR(IQ)=1D0
      ENDDO
*
      DO IQ=1,3
       CHARQU(2*IQ-1)=2D0/3
       CHARQU(2*IQ  )=1D0/3
      ENDDO
*
      DO IMQ=1,6
       CMQRUN(IMQ)=AMQRUN(IMQ)
      ENDDO
      CMQRUN(3)=CMASS
      CMQRUN(6)=BMASS
*
      IF(ALFAS.LT.1D-10) RETURN
*
* NUMERICAL CONSTANTS
*
      PI=4D0*ATAN(1D0)
      PI2=PI**2
      D2=PI2/6D0
      D3=1.2020569031596D0
      D4=PI2**2/90
      D5=1.0369277551434D0
*
* Check of SQRT(S), its redefinition or STOP
*
      IF(SQS.LT.13D0) THEN
        PRINT *,'Warning: you have requested SQRT(S).LT.13 GeV.'
        PRINT *,'Program resets SQRT(S) to 13 GeV and continues.'
        SQS=13D0
      ENDIF
*
cc      IF(SQS.GE.350D0) THEN                               !stj
      IF(SQS.GE.350D0 .AND. icont.LE.10 ) THEN              !stj
        PRINT *,'You have requested SQRT(S).GE.350 GeV.'
          icont=icont+1  ! stj
cc        PRINT *,'Program STORs, since it is not foreseen' !stj
cc        PRINT *,'to run above the t-tbar threshold.'      !stj
      ENDIF
*
* COEFFICIENTS OF BETA AND GAMA FUNCTIONS
*
      IF (SQS.LE.CMASS) THEN
       ANF=3D0
      ELSEIF(SQS.LE.BMASS) THEN
       ANF=4D0
      ELSEIF(SQS.LE.TMASS) THEN
       ANF=5D0
      ELSE
       ANF=6D0
      END IF
      ANF3=3D0
      ANF4=4D0
      ANF5=5D0
*
* First MG's insertion
*
      AMIN=LOG(AMZ2/1D-3)
      AMAX=LOG(AMZ2/1D+2)
      ALPHAQ=ALFAS            
      DO I=1,10
      FMIN=ZALPHA(AMIN)
      FMAX=ZALPHA(AMAX)
C     PRINT*,1,I,AMIN,AMAX,FMIN,FMAX
      IF ((FMIN.LE.0D0.AND.FMAX.LE.0D0).OR.
     &    (FMIN.GE.0D0.AND.FMAX.GE.0D0)) THEN
        AMIN=AMIN+2D0
        AMAX=AMAX-2D0
      ELSE
        GOTO 97
      ENDIF
      ENDDO
 97   CONTINUE
      CALL DZERO(AMIN,AMAX,ROOT,DUM,1D-8,100,ZALPHA)
C     PRINT*,1,I,AMIN,AMAX,FMIN,FMAX
*     CALL DZERO(AMIN,AMAX,ROOT,DUM,1D-8,100,ZALSFL)
      ALMSB5=AMZ*EXP(-ROOT/2)
*
*      ALMSB4=ALMSB5*(BMASS/ALMSB5)**(2D0/25)
*     &         *(LOG(BMASS**2/ALMSB5**2))**(963D0/14375)
cbardin
*      ALMSB4=.32D0
*      ALMSB3=ALMSB4*(CMASS/ALMSB4)**(2D0/27)
*     &         *(LOG(CMASS**2/ALMSB4**2))**(107D0/2025)
*      ALMSB6=ALMSB5*(ALMSB5/TMASS)**(2D0/21)
*     &         *(LOG(TMASS**2/ALMSB5**2))**(-107D0/1127)
*
* BETA/GAMA - COEFFICIENTS FOR ARBITRARY ANF
*
      B0=11D0-2D0/3D0*ANF
      B1=102D0-38D0/3D0*ANF
      B2=.5D0*(2857D0-5033D0/9D0*ANF+325D0/27D0*ANF**2)
      BETA0=B0/4
      BETA1=B1/16
      BETA2=B2/64
      GAMA0=1D0
      GAMA1=(202D0/3-20D0/9*ANF)/16
      GAMA2=(1249-(2216D0/27+160D0/3*D3)*ANF-140D0/81*ANF**2)/64
*
* BETA/GAMMA - COEFFICIENTS FOR ANF=3
*
      BETA03=(11D0-2D0/3D0*ANF3)/4
      BETA13=(102D0-38D0/3D0*ANF3)/16
      BETA23=(.5D0*(2857D0-5033D0/9D0*ANF3+325D0/27D0*ANF3**2))/64
      GAMA03=1D0
      GAMA13=(202D0/3-20D0/9*ANF3)/16
      GAMA23=(1249-(2216D0/27+160D0/3*D3)*ANF3-140D0/81*ANF3**2)/64
      COEF13=GAMA13/BETA03-BETA13*GAMA03/BETA03**2
      COEF23=GAMA23/BETA03-BETA13*GAMA13/BETA03**2
     &      -BETA23*GAMA03/BETA03**2+BETA13**2*GAMA03/BETA03**3
*
* BETA/GAMA - COEFFICIENTS FOR ANF=4
*
      BETA04=(11D0-2D0/3D0*ANF4)/4
      BETA14=(102D0-38D0/3D0*ANF4)/16
      BETA24=(.5D0*(2857D0-5033D0/9D0*ANF4+325D0/27D0*ANF4**2))/64
      GAMA04=1D0
      GAMA14=(202D0/3-20D0/9*ANF4)/16
      GAMA24=(1249-(2216D0/27+160D0/3*D3)*ANF4-140D0/81*ANF4**2)/64
      COEF14=GAMA14/BETA04-BETA14*GAMA04/BETA04**2
      COEF24=GAMA24/BETA04-BETA14*GAMA14/BETA04**2
     &      -BETA24*GAMA04/BETA04**2+BETA14**2*GAMA04/BETA04**3
*
* BETA/GAMA - COEFFICIENTS FOR ANF=5
*
      BETA05=(11D0-2D0/3D0*ANF5)/4
      BETA15=(102D0-38D0/3D0*ANF5)/16
      BETA25=(.5D0*(2857D0-5033D0/9D0*ANF5+325D0/27D0*ANF5**2))/64
      GAMA05=1D0
      GAMA15=(202D0/3-20D0/9*ANF5)/16
      GAMA25=(1249-(2216D0/27+160D0/3*D3)*ANF5-140D0/81*ANF5**2)/64
      COEF15=GAMA15/BETA05-BETA15*GAMA05/BETA05**2
      COEF25=GAMA25/BETA05-BETA15*GAMA15/BETA05**2
     &      -BETA25*GAMA05/BETA05**2+BETA15**2*GAMA05/BETA05**3
*
* FOUR LOOP BETA/GAMA
*
      BETA33=1D0/256D0*(149753D0/6D0+3564D0*D3
     &      -(1078361D0/162D0+6508D0/27D0*D3)*ANF3
     &  +(50065D0/162D0+6472D0/81D0*D3)*ANF3**2+1093D0/729D0*ANF3**3)
* test
*      print *,'0=',+1D0/256D0*(149753D0/6D0+3564D0*D3)
*      print *,'1=',+1D0/256D0*(-(1078361D0/162D0+6508D0/27D0*D3))
*      print *,'2=',+1D0/256D0*(+(50065D0/162D0+6472D0/81D0*D3))
*      print *,'3=',+1D0/256D0*(+1093D0/729D0)
*      stop
      BETA34=1D0/256D0*(149753D0/6D0+3564D0*D3
     &      -(1078361D0/162D0+6508D0/27D0*D3)*ANF4
     &  +(50065D0/162D0+6472D0/81D0*D3)*ANF4**2+1093D0/729D0*ANF4**3)
      BETA35=1D0/256D0*(149753D0/6D0+3564D0*D3
     &      -(1078361D0/162D0+6508D0/27D0*D3)*ANF5
     &  +(50065D0/162D0+6472D0/81D0*D3)*ANF5**2+1093D0/729D0*ANF5**3)
*
      GAMA33=1D0/256D0*(4603055D0/162D0+135680D0/27D0*D3-8800D0*D5
     &  +(-91723D0/27D0-34192D0/9D0*D3+880D0*D4+18400D0/9D0*D5)*ANF3
     &      +(5242D0/243D0+800D0/9D0*D3-160D0/3D0*D4)*ANF3**2
     &      +(-332D0/243D0+64D0/27D0*D3)*ANF3**3)
      GAMA34=1D0/256D0*(4603055D0/162D0+135680D0/27D0*D3-8800D0*D5
     &  +(-91723D0/27D0-34192D0/9D0*D3+880D0*D4+18400D0/9D0*D5)*ANF4
     &      +(5242D0/243D0+800D0/9D0*D3-160D0/3D0*D4)*ANF4**2
     &      +(-332D0/243D0+64D0/27D0*D3)*ANF4**3)
      GAMA35=1D0/256D0*(4603055D0/162D0+135680D0/27D0*D3-8800D0*D5
     &  +(-91723D0/27D0-34192D0/9D0*D3+880D0*D4+18400D0/9D0*D5)*ANF5
     &      +(5242D0/243D0+800D0/9D0*D3-160D0/3D0*D4)*ANF5**2
     &      +(-332D0/243D0+64D0/27D0*D3)*ANF5**3)
*
* Calculation of other \Lambda's
*
      ALMSB4=ALNFM1(BMASS,ALMSB5,5)
      ALMSBN=ANFM1N(BMASS,ALMSB5,5)
      ALMSB3=ALNFM1(CMASS,ALMSB4,4)
*
* Test of matching
*
*      print *,'ALMSB4=',ALMSB4
*      print *,'ALMSBN=',ALMSBN
*      ANF=5D0
*      ALMS=LOG(BMASS**2/ALMSB5**2)
*      ALP5=ALPHAS(ALMS)
*      print *,'ALP5=',ALP5
*      ANF=4D0
*      ALMS=LOG(BMASS**2/ALMSB4**2)
*      ALP4=ALPHAS(ALMS)
*      print *,'ALP4=',ALP4
*      ALMS=LOG(BMASS**2/ALMSBN**2)
*      ALP4=ALPHAS(ALMS)
*      print *,'ALP4=',ALP4
*      stop
*
* ALPHAS at 1 GeV, Mc-pole and Mb-pole
*
      ANF=3D0
      ALMS1=LOG((1D0)**2/ALMSB3**2)
      ALF1PI=ALPHAS(ALMS1)/PI
*
      ANF=4D0
      ALMC21=LOG(CMASS**2/ALMSB4**2)
      ALFCPI=ALPHAS(ALMC21)/PI
      ALMC22=LOG(4D0*CMASS**2/ALMSB4**2)
      CLFCPI=ALPHAS(ALMC22)/PI
      ANF=3D0
      ALMC21=LOG(CMASS**2/ALMSB3**2)
      BLFCPI=ALPHAS(ALMC21)/PI
      ALMC22=LOG(4D0*CMASS**2/ALMSB3**2)
      DLFCPI=ALPHAS(ALMC22)/PI
*
      ANF=5D0
      ALMB21=LOG(BMASS**2/ALMSB5**2)
      ALFBPI=ALPHAS(ALMB21)/PI
      ALMB22=LOG(4D0*BMASS**2/ALMSB5**2)
      CLFBPI=ALPHAS(ALMB22)/PI
      ANF=4D0
      ALMB21=LOG(BMASS**2/ALMSB4**2)
      BLFBPI=ALPHAS(ALMB21)/PI
      ALMB22=LOG(4D0*BMASS**2/ALMSB4**2)
      DLFBPI=ALPHAS(ALMB22)/PI
*
      ANF=5D0
      ALMS2=LOG( SQS**2          /ALMSB5**2)
      ALMT2=LOG((       TMASS)**2/ALMSB5**2)
      ALMX2=LOG((SCALET*TMASS)**2/ALMSB5**2)
      ALFSPI=ALPHAS(ALMS2)/PI
      ALFTPI=ALPHAS(ALMT2)/PI
      ALFXPI=ALPHAS(ALMX2)/PI
      ALFAT =ALFTPI*PI
      ALFAXI=ALFXPI*PI
*
      AMSAMC=SMRUN1*(ALFCPI/ALF1PI)**(GAMA03/BETA03)
     &      *(1+COEF13*(ALFCPI-ALF1PI)+.5D0*COEF13**2*(ALFCPI-ALF1PI)**2
     &         +.5D0*COEF23*(ALFCPI**2-ALF1PI**2))
*
*      BMSAMC=SMRUN1*(BLFCPI/ALF1PI)**(GAMA03/BETA03)
*     &      *(1+COEF13*(BLFCPI-ALF1PI)+.5D0*COEF13**2*(BLFCPI-ALF1PI)**2
*     &         +.5D0*COEF23*(BLFCPI**2-ALF1PI**2))
*
      AMSAMB=AMSAMC*(ALFBPI/ALFCPI)**(GAMA04/BETA04)
     &      *(1+COEF14*(ALFBPI-ALFCPI)+.5D0*COEF14**2*(ALFBPI-ALFCPI)**2
     &         +.5D0*COEF24*(ALFBPI**2-ALFCPI**2))
*
* RUNNING C-MASS, NF=4 EFFECTIVE THEORY
*
* Calculation of K_c
*
      AKC=2905D0/288+(7D0/3+2D0/3*LOG(2D0))*D2-1D0/6*D3
     &   -1D0/3*(71D0/48+D2)*ANF4
*
* Three ways of running m_c calculation:
*
* 1) Running m_c(m_c)
*
*      CALL DZERO(.70D0,1.30D0,ROOT,DUM,1D-8,100,ZRMCIN)
*      AMCSIN=ROOT
*      print *,'AMCSIN=',AMCSIN
*
* RGE-running from m_c to M_c
*
*      ANF=4D0
*      ALMSIN=LOG(AMCSIN**2/ALMSB4**2)
*      ALFSIN=ALPHAS(ALMSIN)/PI
*      AMCAMC=AMCSIN*(ALFCPI/ALFSIN)**(GAMA03/BETA03)
*     &      *(1+COEF13*(ALFCPI-ALFSIN)+.5D0*COEF13**2*(ALFCPI-ALFSIN)**2
*     &         +.5D0*COEF23*(ALFCPI**2-ALFSIN**2))
*      print *,'AMCAMC_1(3)=',AMCAMC
*      AMCAMC=AMCSIN*(ALFCPI/ALFSIN)**(GAMA04/BETA04)
*     &      *(1+COEF14*(ALFCPI-ALFSIN)+.5D0*COEF14**2*(ALFCPI-ALFSIN)**2
*     &         +.5D0*COEF24*(ALFCPI**2-ALFSIN**2))
*      print *,'AMCAMC_1(4)=',AMCAMC
*
* 2) Running m_c(M_c)
*
* Second MG's insertion
*
      AMIN=.70D0
      AMAX=1.30D0
      DO I=1,10
      FMIN=ZRMCMC(AMIN)
      FMAX=ZRMCMC(AMAX)
C     PRINT*,2,I,AMIN,AMAX,FMIN,FMAX
      IF ((FMIN.LE.0D0.AND.FMAX.LE.0D0).OR.
     &    (FMIN.GE.0D0.AND.FMAX.GE.0D0)) THEN
        AMIN=AMIN/2D0
        AMAX=AMAX*2D0
      ELSE
        GOTO 98
      ENDIF
      ENDDO
 98   CONTINUE
      CALL DZERO(AMIN,AMAX,ROOT,DUM,1D-8,100,ZRMCMC)
C     PRINT*,2,I,AMIN,AMAX,FMIN,FMAX
      AMCAMC=ROOT
*      print *,'AMCAMC_2=',AMCAM2
*
*      AMCAMC=CMASS/(1+4D0/3*ALFCPI+13.3D0*ALFCPI**2)
*      print *,'AMCAMC_O=',AMCAMC
*
      AMCAMB=AMCAMC*(ALFBPI/ALFCPI)**(GAMA04/BETA04)
     &      *(1+COEF14*(ALFBPI-ALFCPI)+.5D0*COEF14**2*(ALFBPI-ALFCPI)**2
     &         +.5D0*COEF24*(ALFBPI**2-ALFCPI**2))
*      print *,'AMCAMB_2(4)=',AMCAMB
*      AMCAMB=AMCAMC*(ALFBPI/ALFCPI)**(GAMA05/BETA05)
*     &      *(1+COEF15*(ALFBPI-ALFCPI)+.5D0*COEF15**2*(ALFBPI-ALFCPI)**2
*     &         +.5D0*COEF25*(ALFBPI**2-ALFCPI**2))
*      print *,'AMCAMB_2(5)=',AMCAMB
*
      AMCRUN=AMCAMB*(ALFSPI/ALFBPI)**(GAMA05/BETA05)
     &      *(1+COEF15*(ALFSPI-ALFBPI)+.5D0*COEF15**2*(ALFSPI-ALFBPI)**2
     &         +.5D0*COEF25*(ALFSPI**2-ALFBPI**2))
      AMQRUN(3)=AMCRUN
*
* RUNNING B-MASS, NF=5 EFFECTIVE THEORY
*
* Calculation of K_b
*
      AKB=3817D0/288+2D0/3*(2D0+LOG(2D0))*D2-1D0/6*D3-8D0/3
     &   +D2-1D0/2-1D0/3*(71D0/48+D2)*ANF5
*
* Third MG's insertion
*
      AMIN=3.5D0
      AMAX=4.5D0
      DO I=1,10
      FMIN=ZRMBMB(AMIN)
      FMAX=ZRMBMB(AMAX)
C     PRINT*,3,I,AMIN,AMAX,FMIN,FMAX
      IF ((FMIN.LE.0D0.AND.FMAX.LE.0D0).OR.
     &    (FMIN.GE.0D0.AND.FMAX.GE.0D0)) THEN
        AMIN=AMIN/2D0
        AMAX=AMAX*2D0
      ELSE
        GOTO 99
      ENDIF
      ENDDO
 99   CONTINUE
      CALL DZERO(AMIN,AMAX,ROOT,DUM,1D-8,100,ZRMBMB)
C     PRINT*,3,I,AMIN,AMAX,FMIN,FMAX
      AMBAMB=ROOT
*
*      AMBAMB=BMASS*(1-4D0/3*ALFBPI-(12.4D0-16D0/9)*ALFBPI**2)
*
      AMBRUN=AMBAMB*(ALFSPI/ALFBPI)**(GAMA05/BETA05)
     &      *(1+COEF15*(ALFSPI-ALFBPI)+.5D0*COEF15**2*(ALFSPI-ALFBPI)**2
     &         +.5D0*COEF25*(ALFSPI**2-ALFBPI**2))
      AMQRUN(6)=AMBRUN
*
      DO IMQ=1,6
       CMQRUN(IMQ)=AMQRUN(IMQ)
      ENDDO
*
      RATU=-(1D0+4D0/3*SW2)/(1-8D0/3*SW2)
      RATD=+(1D0+4D0/3*SW2)/(1-4D0/3*SW2)
      RATV=+(1D0+4D0/3*SW2)**2
*
* Re-implementation of QCD-corrections
* References: CKK, CERN 95-03
*              CK, MPI/PhT/96-84, hep-ph/9609202
*                  
cbardin
cb        print *,'SQRTs =',SQS
cb        print *,'SMASS =',SMASS
cb        print *,'CMASS =',CMASS
cb        print *,'BMASS =',BMASS
cb        print *,'TMASS =',AMT
cb        print *,'ALMSB3=',ALMSB3
cb        print *,'ALMSB4=',ALMSB4
cb        print *,'ALMSB5=',ALMSB5
cb        print *,'ALFAS =',ALFAS
cb        print *,'ALFAS1=',ALF1PI*PI
cb        print *,'ALFAMC=',ALFCPI*PI
cb        print *,'BLFAMC=',BLFCPI*PI
cb        print *,'CLFAMC=',CLFCPI*PI
cb        print *,'DLFAMC=',DLFCPI*PI
cb        print *,'ALFAMB=',ALFBPI*PI
cb        print *,'BLFAMB=',BLFBPI*PI
cb        print *,'CLFAMB=',CLFBPI*PI
cb        print *,'DLFAMB=',DLFBPI*PI
cb        print *,'ALFASS=',ALFSPI*PI
cb        print *,'AMSAMC=',AMSAMC
cb        print *,'AMSAMB=',AMSAMB
cb        print *,'AMCAMC=',AMCAMC
cb        print *,'AMCAMB=',AMCAMB
cb        print *,'AMCRUN=',AMCRUN
cb        print *,'AMBAMB=',AMBAMB
cb        print *,'AMBRUN=',AMBRUN
*
* Massless corrections
*
      ANF=5D0
      COEF01=1D0
      COEF02=365D0/24-11D0*D3+(-11D0/12+2D0/3*D3)*ANF
      COEF03=87029D0/288 -121D0/8*D2-1103D0/4*D3+275D0/6*D5
     &      +(-7847D0/216+ 11D0/6*D2+ 262D0/9*D3- 25D0/9*D5)*ANF
     &      +(151D0/162  - 1D0/18*D2- 19D0/27*D3           )*ANF**2
*
* Quadratic Corrections
*
* We consider the case when only AMCRUN and AMBRUN are retained, 
* i.e these corrections should be applied only for sqrt(S).GE.13-15 GeV
*
* Light quarks
*
      COEFL1=0D0
      COEFL2=0D0
      COEFL3=-80D0+60D0*D3+(32D0/9-8D0/3*D3)*ANF
*
* Heavy quarks
*
      COEFV1=12D0
      COEFV2=253D0/2-13D0/3*ANF
      COEFV3=  2522D0   - 855D0/2*D2+ 310D0/3*D3- 5225D0/6*D5
     &      +(-4942D0/27+    34D0*D2-394D0/27*D3+1045D0/27*D5)*ANF
     &      +(125D0/54  -   2D0/3*D2                      )*ANF**2
*
      COEFA0=-6D0
      COEFA1=-22D0
      COEFA2=-8221D0/24+57D0*D2+117D0*D3
     &      +(151D0/12 - 2D0*D2-  4D0*D3)*ANF   
      COEFA3=-4544045D0/864+   1340*D2+118915D0/36*D3  -1270D0*D5
     &      +(71621D0/162  -209D0/2*D2   -216D0*D3+5D0*D4+55D0*D5)*ANF
     &      +(-13171D0/1944+ 16D0/9*D2  +26D0/9*D3            )*ANF**2
*
*     PRINT *,'COEF01,2,3=',COEF01,COEF02,COEF03
*     PRINT *,'COEFL1,2,3=',COEFL1,COEFL2,COEFL3
*     PRINT *,'COEFV1,2,3=',COEFV1,COEFV2,COEFV3       
*     PRINT *,'COEFA1,2,3=',COEFA1,COEFA2,COEFA3
*     PRINT *,'(COEFV3+COEFL3)=',(COEFV3+COEFL3)/12 
*
      RLMC=AMCRUN**2/SQS**2
      RLMB=AMBRUN**2/SQS**2
      R2LU=(RLMC+RLMB)*COEFL3*ALFSPI**3
      RV20=COEFV1*ALFSPI+COEFV2*ALFSPI**2+COEFV3*ALFSPI**3
      RA20=COEFA0+COEFA1*ALFSPI+COEFA2*ALFSPI**2+COEFA3*ALFSPI**3
*
      QCDC2V(1)=R2LU
      QCDC2V(2)=R2LU
      QCDC2V(3)=R2LU+RLMC*RV20
      QCDC2V(4)=R2LU
      QCDC2V(5)=0D0
      QCDC2V(6)=R2LU+RLMB*RV20
*
      QCDC2A(1)=R2LU
      QCDC2A(2)=R2LU
      QCDC2A(3)=R2LU+RLMC*RA20
      QCDC2A(4)=R2LU
      QCDC2A(5)=0D0
      QCDC2A(6)=R2LU+RLMB*RA20
*
* Quartic Corrections. They contain ln(M^2/S) and can't be coded 
*                      as above as consts
*
* For bb-channel, the vector m^6_b correction is added
*                                                                   
* Light quarks                                             
*
      ALMC=LOG(RLMC)
      R4LC=RLMC**2*(13D0/3-ALMC-4D0*D3)*ALFSPI**2
      ALMB=LOG(RLMB)
      R4LB=RLMB**2*(13D0/3-ALMB-4D0*D3)*ALFSPI**2
*
* Heavy quarks (actually b-quark)                 
*                                
      RV40=-6D0-22D0*ALFSPI+(+12D0-3173D0/12+27D0*PI2+112D0*D3
     &     +(143D0/18-2D0/3*PI2- 8D0/3*D3)*ANF)*ALFSPI**2                      
*                                
*     PRINT *,'RV40=',12D0-3173D0/12+27D0*PI2+112D0*D3
*    &     +(143D0/18-2D0/3*PI2- 8D0/3*D3)*ANF                      
*
      RA40=+6D0+10D0*ALFSPI+(-12D0+3533D0/12-27D0*PI2-220D0*D3
     &     +(-41D0/6 +2D0/3*PI2+16D0/3*D3)*ANF)*ALFSPI**2
      RV4L=(-11D0/2+1D0/3*ANF)*ALFSPI**2
      RA4L=(+77D0/2-7D0/3*ANF)*ALFSPI**2
*
      QCDC4V(1)=R4LC+R4LB
      QCDC4V(2)=R4LC+R4LB
      QCDC4V(3)=R4LC+R4LB+RLMC**2*(RV40+RV4L*ALMC)+12*RLMB**2*ALFSPI**2
      QCDC4V(4)=R4LC+R4LB
      QCDC4V(5)=0D0
      QCDC4V(6)=R4LC+R4LB+RLMB**2*(RV40+RV4L*ALMB)+12*RLMC**2*ALFSPI**2
     &                   -RLMB**3*(8D0+16D0/27*(155D0+6D0*ALMB)*ALFSPI)
*
      QCDC4A(1)=R4LC+R4LB
      QCDC4A(2)=R4LC+R4LB
      QCDC4A(3)=R4LC+R4LB+RLMC**2*(RA40+RA4L*ALMC)-12*RLMB**2*ALFSPI**2
      QCDC4A(4)=R4LC+R4LB
      QCDC4A(5)=0D0
      QCDC4A(6)=R4LC+R4LB+RLMB**2*(RA40+RA4L*ALMB)-12*RLMC**2*ALFSPI**2
*
      RLMT=SQS**2/AMT**2
      ALMT=LOG(RLMT)
      CAI2=-37D0/12+ALMT+7D0/81*RLMT+.0132D0*RLMT**2
      CAI3=-5651D0/216+8D0/3+23D0/6*D2+D3+67D0/18*ALMT+23D0/12*ALMT**2
*                                                                         
      DO 10 IQ=1,6
      SINS=(-1)**IQ
*           
* R_V
*
      QCDCON(2*IQ-1)=1+ALFSPI+1D0/4*ALQED/PI*CHARQU(IQ)**2*(3-ALFSPI)
     &          +(1.40923D0+(44D0/675-2D0/135*ALMT)*RLMT)*ALFSPI**2
     &          +(-12.76706D0)*ALFSPI**3
     &+12*AMQRUN(IQ)**2/SQS**2*ALFSPI*(1+8.7D0*ALFSPI+45.15D0*ALFSPI**2)
*
      QCDCOR(2*IQ-1)=1+ALFSPI+1D0/4*ALQED/PI*CHARQU(IQ)**2*(3-ALFSPI)
     &              +(COEF02+(44D0/675-2D0/135*ALMT)*RLMT)*ALFSPI**2
     &              + COEF03*ALFSPI**3
     &              +QCDC2V(IQ)+QCDC4V(IQ)
*
* R_A
*
      QCDCON(2*IQ  )=1+ALFSPI+1D0/4*ALQED/PI*CHARQU(IQ)**2*(3-ALFSPI)
     &   +(1.40923D0+(44D0/675-2D0/135*ALMT)*RLMT+SINS*CAI2)*ALFSPI**2
     &   +(-12.76706D0+SINS*CAI3)*ALFSPI**3
     &   -6*AMQRUN(IQ)**2/SQS**2*
     &                      (1+11D0/3*ALFSPI+(11.286D0+ALMT)*ALFSPI**2)
     &         -10*AMQRUN(IQ)**2/AMT**2*(8D0/81-1D0/54*ALMT)*ALFSPI**2
*
* Axial singlet contributions
*
      IF    (IQ.EQ.3) THEN
       RASING=-6D0*AMCRUN**2/SQS**2*(-3D0+ALMT)*ALFSPI**2
     &       -10D0*AMCRUN**2/AMT**2*(8D0/81-1D0/54*ALMT)*ALFSPI**2
      ELSEIF(IQ.EQ.6) THEN
       RASING=-6D0*AMBRUN**2/SQS**2*(-3D0+ALMT)*ALFSPI**2
     &       -10D0*AMBRUN**2/AMT**2*(8D0/81-1D0/54*ALMT)*ALFSPI**2
      ELSE
       RASING=0D0
      ENDIF
*
      QCDCOR(2*IQ  )=1+ALFSPI+1D0/4*ALQED/PI*CHARQU(IQ)**2*(3-ALFSPI)
     &        +(COEF02+(44D0/675-2D0/135*ALMT)*RLMT+SINS*CAI2)*ALFSPI**2
     &        +(COEF03+SINS*CAI3)*ALFSPI**3                            
     &        +QCDC2A(IQ)+QCDC4A(IQ)                                   
     &        +RASING
  10  CONTINUE   
*
* Vector singlet contribution
*
*     RVSING=1D0/192*(176D0/3-128D0*D3)
      RVSING=-.41317D0
*
      QCDCOR(13)=RVSING*ALFSPI**3
* QCDCOR(14) - Arbuzov, Bardin, Leike correction
      QCDCOR(14)=16D0/3*ALFSPI
*
      END
 
      FUNCTION ZRMCIN(RMASS)
      IMPLICIT REAL*8(A-H,O-Z)
*
      COMMON /CDZZER/ PI,ALPHAQ,ANF,AKC,AKB
      COMMON /CDZPHM/ CMASS,BMASS,TMASS,SMRUN1
      COMMON /CDZBGC/ BETA03,BETA13,BETA23,GAMA03,GAMA13,GAMA23,
     &                BETA04,BETA14,BETA24,GAMA04,GAMA14,GAMA24,
     &                BETA05,BETA15,BETA25,GAMA05,GAMA15,GAMA25,
     &                COEF13,COEF23,COEF14,COEF24,COEF15,COEF25,
     &                ALMSB3,ALMSB4,ALMSB5,ALMSB6,ALF1PI,ALFCPI,ALFBPI,
     &                AMSAMC,AMSAMB,AMCAMC,AMCAMB,AMBAMB
*
      IF(RMASS.LE.1D0.OR.RMASS.LE.ALMSB3) THEN
       AMSRMC=SMRUN1
      ELSE
       ANF=3D0
       ALMC2=LOG(RMASS**2/ALMSB3**2)
       ALFRPI=ALPHAS(ALMC2)/PI
       AMSRMC=SMRUN1*(ALFRPI/ALF1PI)**(GAMA03/BETA03)
     &      *(1+COEF13*(ALFRPI-ALF1PI)+.5D0*COEF13**2*(ALFRPI-ALF1PI)**2
     &         +.5D0*COEF23*(ALFRPI**2-ALF1PI**2))
      ENDIF
*
      ANF=4D0
      ALMC2 =LOG(RMASS**2/ALMSB4**2)
      ALFRPI=ALPHAS(ALMC2)/PI
      RAT=AMSRMC/RMASS
      DEL=(PI**2/8-.597D0*RAT+.23D0*RAT**2)*RAT
*
      ZRMCIN=CMASS-RMASS*(1D0+4D0/3*ALFRPI+(AKC+4D0/3*DEL)*ALFRPI**2)
*
      END
 
      FUNCTION ZRMCMC(RMASS)
      IMPLICIT REAL*8(A-H,O-Z)
*
      COMMON /CDZZER/ PI,ALPHAQ,ANF,AKC,AKB
      COMMON /CDZPHM/ CMASS,BMASS,TMASS,SMRUN1
      COMMON /CDZBGC/ BETA03,BETA13,BETA23,GAMA03,GAMA13,GAMA23,
     &                BETA04,BETA14,BETA24,GAMA04,GAMA14,GAMA24,
     &                BETA05,BETA15,BETA25,GAMA05,GAMA15,GAMA25,
     &                COEF13,COEF23,COEF14,COEF24,COEF15,COEF25,
     &                ALMSB3,ALMSB4,ALMSB5,ALMSB6,ALF1PI,ALFCPI,ALFBPI,
     &                AMSAMC,AMSAMB,AMCAMC,AMCAMB,AMBAMB
*
      ANFE=4D0
      RAT=AMSAMC/RMASS
      DEL=(PI**2/8-.597D0*RAT+.23D0*RAT**2)*RAT
      ALRMC=LOG(CMASS**2/RMASS**2)
*
      ZRMCMC=CMASS-RMASS*(1D0+(4D0/3+ALRMC)*ALFCPI
     &+(AKC+4D0/3*DEL+(173D0/24-13D0/36*ANFE)*ALRMC
     &+(15D0/8-1D0/12*ANFE)*ALRMC**2)*ALFCPI**2)
cbardin
cb      print *,'First =',(4D0/3+ALRMC)*ALFCPI
cb      print *,'Second=',
cb     &+(AKC+4D0/3*DEL+(173D0/24-13D0/36*ANFE)*ALRMC
cb     &+(15D0/8-1D0/12*ANFE)*ALRMC**2)*ALFCPI**2
*
      END
 
      FUNCTION ZRMBMB(RMASS)
      IMPLICIT REAL*8(A-H,O-Z)
*
      COMMON /CDZZER/ PI,ALPHAQ,ANF,AKC,AKB
      COMMON /CDZPHM/ CMASS,BMASS,TMASS,SMRUN1
      COMMON /CDZBGC/ BETA03,BETA13,BETA23,GAMA03,GAMA13,GAMA23,
     &                BETA04,BETA14,BETA24,GAMA04,GAMA14,GAMA24,
     &                BETA05,BETA15,BETA25,GAMA05,GAMA15,GAMA25,
     &                COEF13,COEF23,COEF14,COEF24,COEF15,COEF25,
     &                ALMSB3,ALMSB4,ALMSB5,ALMSB6,ALF1PI,ALFCPI,ALFBPI,
     &                AMSAMC,AMSAMB,AMCAMC,AMCAMB,AMBAMB
*
      ANFE=5D0
      RATS=AMSAMB/RMASS
      RATC=AMCAMB/RMASS
      DELS=(PI**2/8-.597D0*RATS+.23D0*RATS**2)*RATS
      DELC=(PI**2/8-.597D0*RATC+.23D0*RATC**2)*RATC
      DEL =DELS+DELC
      ALRMB=LOG(BMASS**2/RMASS**2)
*
      ZRMBMB=BMASS-RMASS*(1D0+(4D0/3+ALRMB)*ALFBPI
     &+(AKB+4D0/3*DEL+(173D0/24-13D0/36*ANFE)*ALRMB
     &+(15D0/8-1D0/12*ANFE)*ALRMB**2)*ALFBPI**2)
cbardin
cb      print *,'First =',(4D0/3+ALRMB)*ALFBPI
cb      print *,'Second=',
cb     &+(AKB+4D0/3*DEL+(173D0/24-13D0/36*ANFE)*ALRMB
cb     &+(15D0/8-1D0/12*ANFE)*ALRMB**2)*ALFBPI**2
*
      END
 
      FUNCTION ZALPHA(A)
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON /CDZZER/ PI,ALPHAQ,ANF,AKC,AKB
      B=LOG(A)
      B0=11D0-2D0/3D0*ANF
      B1=102D0-38D0/3D0*ANF
      B2=.5D0*(2857D0-5033D0/9D0*ANF+325D0/27D0*ANF**2)
      C=B1/(B0**2*A)
      ZALPHA=ALPHAQ-
     &     4D0*PI/(B0*A)*(1D0-C*B+C**2*((B-.5D0)**2+B2*B0/B1**2-1.25D0))
      END
 
      FUNCTION ZALSFL(A)
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON /CDZZER/UPI,ALPHAQ,ANF,AKC,AKB
      COMMON /CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
      B=LOG(A)
      B0=1D0/4D0 *(11D0-2D0/3D0*ANF)
      B1=1D0/16D0*(102D0-38D0/3D0*ANF)/B0
      B2=1D0/64D0*(2857D0/2D0-5033D0/18D0*ANF+325D0/54D0*ANF**2)/B0
      B3=1D0/256D0*(149753D0/6D0+3564D0*D3
     &  -(1078361D0/162D0+6508D0/27D0*D3)*ANF
     &  +(50065D0/162D0+6472D0/81D0*D3)*ANF**2+1093D0/729D0*ANF**3)/B0
*
      ZALSFL=ALPHAQ-PI*(1D0/(B0*A)
     &                 -1D0/(B0*A)**2* B1*B
     &                 +1D0/(B0*A)**3*(B1**2*(B**2-B-1D0)+B2))
     &      -1D0/(B0*A)**4*(B1**3*(B**3-2.5D0*B**2-2D0*B+.5D0)
     &                      +3D0*B1*B2*B-.5D0*B3)    
*
      END
 
      FUNCTION ALPHAS(A)
      IMPLICIT REAL*8(A-H,O-Z)
      COMMON /CDZZER/ PI,ALPHAQ,ANF,AKC,AKB
      B=LOG(A)
      B0=11D0-2D0/3D0*ANF
      B1=102D0-38D0/3D0*ANF
      B2=.5D0*(2857D0-5033D0/9D0*ANF+325D0/27D0*ANF**2)
      C=B1/(B0**2*A)
      ALPHAS=
     &     4D0*PI/(B0*A)*(1D0-C*B+C**2*((B-.5D0)**2+B2*B0/B1**2-1.25D0))
      END

      FUNCTION ALNFM1(AMQ,ALNFN,NF)
      IMPLICIT REAL*8(A-H,O-Z)
*
      COMMON /CDZBGC/ BETA03,BETA13,BETA23,GAMA03,GAMA13,GAMA23,
     &                BETA04,BETA14,BETA24,GAMA04,GAMA14,GAMA24,
     &                BETA05,BETA15,BETA25,GAMA05,GAMA15,GAMA25,
     &                COEF13,COEF23,COEF14,COEF24,COEF15,COEF25,
     &                ALMSB3,ALMSB4,ALMSB5,ALMSB6,ALF1PI,ALFCPI,ALFBPI,
     &                AMSAMC,AMSAMB,AMCAMC,AMCAMB,AMBAMB
*
      IF(NF.EQ.5) THEN
        BETA0N=BETA05
        BETA1N=BETA15 
        BETA2N=BETA25
        BETA0M=BETA04
        BETA1M=BETA14
        BETA2M=BETA24 
      ELSEIF(NF.EQ.4) THEN
        BETA0N=BETA04
        BETA1N=BETA14
        BETA2N=BETA24
        BETA0M=BETA03
        BETA1M=BETA13
        BETA2M=BETA23
      ELSE
        PRINT *,'ERROR IN ALNFM1 CALL'
        STOP
      ENDIF
*
      ALG=2D0*LOG(AMQ/ALNFN)
      ALGALG=LOG(ALG)
*
      CO1=BETA0N-BETA0M
      CO2=BETA1N/BETA0N-BETA1M/BETA0M
      CO3=-BETA1M/BETA0M
      CO4=BETA1N/BETA0N**2*(BETA1N/BETA0N-BETA1M/BETA0M)
      CO5=1D0/BETA0N*((BETA1N/BETA0N)**2-(BETA1M/BETA0M)**2
     &                -BETA2N/BETA0N+BETA2M/BETA0M+7D0/24D0)
*     &                -BETA2N/BETA0N+BETA2M/BETA0M-7D0/72D0)
*
      RHS=(CO1*ALG+CO2*ALGALG+CO3*LOG(BETA0N/BETA0M)
     &    +CO4*ALGALG/ALG+CO5/ALG)/BETA0M
      ALNFM1=ALNFN/(EXP(RHS/2D0))
*
      END

      FUNCTION ANFM1N(AMQ,ALNFN,NF)
      IMPLICIT REAL*8(A-H,O-Z)
*
* This is 1997 version of ALNFM1 with possible inclusion of four loops
*
      COMMON/CDZCON/PI,PI2,D2,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON /CDZBGC/ BETA03,BETA13,BETA23,GAMA03,GAMA13,GAMA23,
     &                BETA04,BETA14,BETA24,GAMA04,GAMA14,GAMA24,
     &                BETA05,BETA15,BETA25,GAMA05,GAMA15,GAMA25,
     &                COEF13,COEF23,COEF14,COEF24,COEF15,COEF25,
     &                ALMSB3,ALMSB4,ALMSB5,ALMSB6,ALF1PI,ALFCPI,ALFBPI,
     &                AMSAMC,AMSAMB,AMCAMC,AMCAMB,AMBAMB
      COMMON /CDZBG3/ BETA33,BETA34,BETA35,GAMA33,GAMA34,GAMA35
*
* Returns \Lambda(n_f-1)=ANFM1N, given \Lambda(n_f)=ALNFN
*
      IF(NF.EQ.5) THEN
        BETA0N=BETA05
        BETA1N=BETA15 
        BETA2N=BETA25
        BETA3N=BETA35
        BETA0M=BETA04
        BETA1M=BETA14
        BETA2M=BETA24 
        BETA3M=BETA34 
      ELSEIF(NF.EQ.4) THEN
        BETA0N=BETA04
        BETA1N=BETA14
        BETA2N=BETA24
        BETA3N=BETA34
        BETA0M=BETA03
        BETA1M=BETA13
        BETA2M=BETA23
        BETA3M=BETA33
      ELSE
        PRINT *,'ERROR IN ALNFM1 CALL'
        STOP
      ENDIF
*
* calculation of b_i and b'_i
*
      b1 =BETA1N/BETA0N    
      b2 =BETA2N/BETA0N    
      b3 =BETA3N/BETA0N    
      b1p=BETA1M/BETA0M    
      b2p=BETA2M/BETA0M    
      b3p=BETA3M/BETA0M    
*
      ALG=2D0*LOG(AMQ/ALNFN)
      ALGALG=LOG(ALG)
*
      Bc2=-7D0/24D0
      Bc3=-80507D0/27648D0*D3-2D0/3D0*(1D0/3D0*LOG(2D0)+1D0)*D2
     &   -58933D0/124416D0+1D0/9D0*(D2+2479D0/3456D0)*4D0
*
      CO1=BETA0N-BETA0M
      CO2=b1-b1p
      CO3=-b1p
      CO4=b1*(b1-b1p)
      CO5=b1**2-b1p**2-b2+b2p-Bc2
      CO6=b1**2/2D0*(b1-b1p)
      CO7=b1*(b1p*(b1-b1p)-b2+b2p-Bc2)
      CO8=.5D0*(-b1**3-b1p**3+b3-b3p)
     &   +b1p*(b1**2+b2p-b2-Bc2)+Bc3
*
      RHS=(CO1*ALG+CO2*ALGALG+CO3*LOG(BETA0N/BETA0M)
     &    +1D0/(BETA0N*ALG)*(CO4*ALGALG+CO5)
*     &    -1D0/(BETA0N*ALG)**2*(CO6*ALGALG**2+CO7*ALGALG+CO8)
     &    )/BETA0M
      ANFM1N=ALNFN/(EXP(RHS/2D0))
*
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
 
      FUNCTION DALPHL(IALE2,S)
*
* LEPTONIC \Delta\alpha up to three loops
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      COMMON/CDZCON/PI,PI2,D2,D3,ALFAI,AL4PI,AL2PI,AL1PI
      COMMON/CDZFER/CLM(8),AML(8),CQM(8),AMQ(8),VB,VT,VB2,VB2T,VT2,VT2T
      DIMENSION PI0(3),PI1(3),PI2A(3),PI2L(3,3),PI2F(3),PI2H(3)
     &                       ,PI1L(3),PI2B(3,3),PI2S(3),PISU(3)
*
      D5=1.0369277551434D0
      ALPHA0=ALFAI
      CEILER=.577216D0
      CONST=0D0
*
      DO I=1,3
      AML2=(AML(2*I))**2
      RML2=AML2/S
      ALG1=LOG(S/AML2)
      PI0(I)=1D0/ALFAI/PI*(1D0/9+1D0/3*(1D0+2D0*RML2)
     &      *DREAL(XI0(AML2,-S,AML2,AML2)))
      PI1(I) =(1D0/ALFAI/PI)**2*((1D0+12D0*RML2)/4*ALG1+D3-5D0/24)
      PI1L(I)=(1D0/ALFAI/PI)**2*( 1D0/4*ALG1)
      PI2A(I)=(1D0/ALFAI/PI)**3*(-1D0/4*(-121D0/48
     &       +(-5D0+8D0*LOG(2D0))*D2-99D0/16*D3+10D0*D5+1D0/8*ALG1))
      ENDDO
*
      DO I=1,3
      SUM=0D0
      DO J=1,3
      ALG1=LOG(S/(AML(2*I))**2)
      ALG2=LOG(S/(AML(2*J))**2)
      PI2F(I)=(1D0/ALFAI/PI)**3*(-1D0/4*(-307D0/216-8D0/3*D2
     &       +545D0/144*D3+(11D0/6-4D0/3*D3)*ALG1-1D0/6*ALG1**2+CONST))
      PI2L(I,J)=(1D0/ALFAI/PI)**3*(-1D0/4*(-116D0/27+4D0/3*D2
     &         +38D0/9*D3+14D0/9*ALG1+(5D0/18-4D0/3*D3)*ALG2
     &         +1D0/6*ALG1**2-1D0/3*ALG1*ALG2+CONST))
      PI2H(J)=(1D0/ALFAI/PI)**3*(-1D0/4*(-37D0/6+38D0/9*D3
     &       +(11D0/6-4D0/3*D3)*ALG2-1D0/6*ALG2**2+CONST))
      IF(I.LT.J) THEN
        PI2B(I,J)=PI2H(J)  
      ELSEIF(I.EQ.J) THEN 
        PI2B(I,J)=PI2F(I)  
      ELSEIF(I.GT.J) THEN
        PI2B(I,J)=PI2L(I,J)
      ENDIF
      SUM=SUM+PI2B(I,J)
      ENDDO
      PI2S(I)=PI2A(I)+SUM
*
      IF(IALE2.EQ.0) THEN
        PISU(I)=PI0(I)+PI1L(I)
      ELSEIF(IALE2.EQ.1) THEN
        PISU(I)=PI0(I)
      ELSEIF(IALE2.EQ.2) THEN
        PISU(I)=PI0(I)+PI1(I)
      ELSEIF(IALE2.EQ.3) THEN
        PISU(I)=PI0(I)+PI1(I)+PI2A(I)+PI2S(I)
      ENDIF
*
      ENDDO
*
      DALPHL=PISU(1)+PISU(2)+PISU(3)
*
      END

      double precision function dalh5(s,argmz)
*
      IMPLICIT REAL*8(A-H,O-Z)
*
      COMMON/CDZFLG/IHVP,IAMT4,IQCD,IMOMS,IMASS,IALEM,IMASK,IBARB,IFTJR
      COMMON/CDZSCT/ISCRE,ISCAL,IAFMT,IFACR,IFACT,IHIGS,IEWLC,ICZAK
     &             ,IHIG2,IALE2,IGFER      
*
* for back-compatibility only
*
       IF(IALE2.EQ.0) THEN
        e=-sngl(s/abs(s)*sqrt(abs(s)))
       ELSE
        e=+sngl(s/abs(s)*sqrt(abs(s)))
       ENDIF
* st2=0.2322 is the reference value
       st2= 0.2322d0
       call hadr5(e,argmz,st2,der,errder,deg,errdeg)
       dalh5=der
*
      end
 
      subroutine hadr5(e,amz,st2,der,errder,deg,errdeg)
c ******************************************************************
c *                                                                *
c *      subroutine for the evaluation of the light hadron         *
c *           contributions to Delta_r  and  Delta_g               *
c *                    using fits to the                           *
c *          QED vacuum polarization from e^+ e^- data             *
c *                                                                *
c *    F. Jegerlehner, Paul Scherrer Institute, CH-5232 Villigen   *
c *                                                                *
c *    E-mail:jegerlehner@cvax.psi.ch                              *
c *    Phone :   +41-56-993662                                     *
c *                                                                *
c *    Reference: F. Jegerlehner, Z. Phys. C32 (1986) 195          *
c *               H. Burkhardt et al., Z. Phys. C42 (1989) 497     *
c *               S. Eidelman, F. Jegerlehner, Z. Phys. C (1995)   *
c *                                                                *
c ******************************************************************
c       VERSION: 24/02/1995
c
C  Notation: E energy ( momentum transfer ): E>0 timelike , E<0 spacelik
C            st2 is sin^2(Theta); st2=0.2322 is the reference value
C  the routine returns the hadronic contribution of 5 flavors (u,d,s,c,b
C                 to   DER=Delta_r with hadronic error ERRDER
C                and   DEG=Delta_g with hadronic error ERRDEG
C  The effective value of the fine structure constant alphaQED at energy
C  E is alphaQED(E)=alphaQED(0)/(1-Delta_r) ,similarly for the SU(2)
C  coupling alphaSU2(E)=alphaSU2(0)/(1-Delta_g), where Delta_r(g) is the
C  sum of leptonic, hadronic contributions (top to be added).
C
C  This program does not yet know how to compute Delta r and Delta g for
C  energies in the ranges  |E|>1TeV and 2m_pi < E < 40(13) GeV !!!!!!!!!
C
       implicit none
       integer*4 nf,ns,i,j
       parameter(nf=9,ns=4)
       real*8 e,st2,st20,der,deg,errder,errdeg,s,s0,x1,xi,x2,xlog,xlar
       real*8 m1(nf),c1(nf,ns),c2(nf,ns),c3(nf,ns),c4(nf,ns),ae(nf,ns)
       real*8 eu(nf),eo(nf),res(ns),l1(nf,ns),fx,gx,hx,xx,u,Se,amz
       do i=1,nf
         do j=1,ns
           ae(i,j)=0.0
         enddo
       enddo
c #1# Delta_r
c Fit parameters spacelike  -1000 to  -200 GeV
      eu(1)  =-1000.
      eo(1)  = -200.
      m1(1)=  -1000.000
      c1(1,1)=  4.2069394e-02
      c2(1,1)=  2.9253566e-03
      c3(1,1)= -6.7782454e-04
      c4(1,1)=  9.3214130e-06
c   chi2=  2.5763808e-05
c Fit parameters spacelike  -200 to  -20 GeV
      eu(2)  = -200.
      eo(2)  =  -20.
      m1(2)  =  -100.0000
      c1(2,1)=  2.8526291e-02
      c2(2,1)=  2.9520725e-03
      c3(2,1)= -2.7906310e-03
      c4(2,1)=  6.4174528e-05
c   chi2=  6.6264300e-04
c Fit parameters spacelike   -20 to   -2 GeV
      eu(3)  =  -20.
      eo(3)  =   -2.
      m1(3)  =   -20.0000
      l1(3,1)=  9.3055e-3
      c1(3,1)=  2.8668314e-03
      c2(3,1)=  0.3514608
      c3(3,1)=  0.5496359
      c4(3,1)=  1.9892334e-04
c   chi2=  4.2017717e-03
      ae(3,1)=  3.0
c Fit parameters spacelike    -2 to    0.25 GeV
      eu(4)  =   -2.
      eo(4)  =    0.25
      m1(4)  =    -2.0000
      l1(4,1)=  9.3055e-3
      c1(4,1)=  2.2694240e-03
      c2(4,1)=   8.073429
      c3(4,1)=  0.1636393
      c4(4,1)= -3.3545541e-05
c   chi2=  0.1239052
      ae(4,1)=  2.0
c Fit parameters timelike   0.25 to    2 GeV
      eu(5)  =    0.25
      eo(5)  =    2.
c Fit parameters timelike   2    to   40 GeV
      eu(6)  =    2.
      eo(6)  =   40.
c Fit parameters timelike     40 to   80 GeV
      eu(7)  =   40.
      eo(7)  =   80.
      m1(7)  =   80.00000
      c1(7,1)=  2.7266588e-02
      c2(7,1)=  2.9285045e-03
      c3(7,1)= -4.7720564e-03
      c4(7,1)=  7.7295507e-04
c   chi2=  7.7148885e-05
c Fit parameters timelike     80 to  250 GeV
      eu(8)  =   80.
      eo(8)  =  250.
      m1(8)  =  amz
      c1(8,1)=  2.8039809e-02
      c2(8,1)=  2.9373798e-03
      c3(8,1)= -2.8432352e-03
      c4(8,1)= -5.2537734e-04
c   chi2=  4.2241514e-05
c Fit parameters timelike    250 to 1000 GeV
      eu(9)  =  250.
      eo(9)  = 1000.
      m1(9)  = 1000.00000
      c1(9,1)=  4.2092260e-02
      c2(9,1)=  2.9233438e-03
      c3(9,1)= -3.2966913e-04
      c4(9,1)=  3.4324117e-07
c   chi2=  6.0426464e-05
c #2# Delta_g
c Fit parameters spacelike  -1000 to  -200 GeV
c     eu(1)  =-1000.
c     eo(1)  = -200.
c     m1(1)=  -1000.000
      c1(1,2)=  8.6415343e-02
      c2(1,2)=  6.0127582e-03
      c3(1,2)= -6.7379221e-04
      c4(1,2)=  9.0877611e-06
c   chi2=  9.6284139e-06
c Fit parameters spacelike  -200 to  -20 GeV
c     eu(2)  = -200.
c     eo(2)  =  -20.
c     m1(2)  =  -100.0000
      c1(2,2)=  5.8580618e-02
      c2(2,2)=  6.0678599e-03
      c3(2,2)= -2.4153464e-03
      c4(2,2)=  6.1934326e-05
c   chi2=  6.3297758e-04
c Fit parameters spacelike   -20 to   -2 GeV
c     eu(3)  =  -20.
c     eo(3)  =   -2.
c     m1(3)  =   -20.0000
      l1(3,2)=  1.9954e-2
      c1(3,2)=  5.7231588e-03
      c2(3,2)=  0.3588257
      c3(3,2)=  0.5532265
      c4(3,2)=  6.0730567e-04
c   chi2=  7.9884287e-03
      ae(3,2)=  3.0
c   chi2=  4.2017717e-03
c Fit parameters spacelike    -2 to    0.25 GeV
c     eu(4)  =   -2.
c     eo(4)  =    0.25
c     m1(4)  =    -2.0000
      l1(4,2)=  1.9954e-2
      c1(4,2)=  4.8065037e-03
      c2(4,2)=   8.255167
      c3(4,2)=  0.1599882
      c4(4,2)= -1.8624817e-04
c   chi2=  0.1900761
      ae(3,2)=  2.0
c Fit parameters timelike     40 to   80 GeV
c     eu(7)  =   40.
c     eo(7)  =   80.
c     m1(7)  =   80.00000
      c1(7,2)=  5.5985276e-02
      c2(7,2)=  6.0203830e-03
      c3(7,2)= -5.0066952e-03
      c4(7,2)=  7.1363564e-04
c   chi2=  7.6000040e-05
c Fit parameters timelike     80 to  250 GeV
c     eu(8)  =   80.
c     eo(8)  =  250.
c     m1(8)  =   91.18880
      c1(8,2)=  5.7575710e-02
      c2(8,2)=  6.0372148e-03
      c3(8,2)= -3.4556778e-03
      c4(8,2)= -4.9574347e-04
c   chi2=  3.3244669e-05
c Fit parameters timelike    250 to 1000 GeV
c     eu(9)  =  250.
c     eo(9)  = 1000.
c     m1(9)  = 1000.00000
      c1(9,2)=  8.6462371e-02
      c2(9,2)=  6.0088057e-03
      c3(9,2)= -3.3235471e-04
      c4(9,2)=  5.9021050e-07
c   chi2=  2.9821187e-05
c #3# error Delta_r
c Fit parameters spacelike  -1000 to  -200 GeV
c     eu(1)  =-1000.
c     eo(1)  = -200.
c     m1(1)=  -1000.000
      c1(1,3)=  6.3289929e-04
      c2(1,3)=  3.3592437e-06
      c3(1,3)=  0.0
      c4(1,3)=  0.0
c   chi2=  2.3007713E-05
c Fit parameters spacelike  -200 to  -20 GeV
c     eu(2)  = -200.
c     eo(2)  =  -20.
c     m1(2)  =  -100.0000
      c1(2,3)=  6.2759849e-04
      c2(2,3)= -1.0816625e-06
      c3(2,3)=   5.050189
      c4(2,3)= -9.6505374e-02
c   chi2=  3.4677869e-04
      ae(2,3)=  1.0
c Fit parameters spacelike   -20 to   -2 GeV
c     eu(3)  =  -20.
c     eo(3)  =   -2.
c     m1(3)  =   -20.0000
      l1(3,3)=  2.0243e-4
      c1(3,3)=  1.0147886e-04
      c2(3,3)=   1.819327
      c3(3,3)= -0.1174904
      c4(3,3)= -1.2404939e-04
c   chi2=  7.1917898e-03
      ae(3,3)=  3.0
c Fit parameters spacelike    -2 to    0.25 GeV
c     eu(4)  =   -2.
c     eo(4)  =    0.25
c     m1(4)  =    -2.0000
      l1(4,3)=  2.0243e-4
      c1(4,3)= -7.1368617e-05
      c2(4,3)=  9.980347e-04
      c3(4,3)=   1.669151
      c4(4,3)=  3.5645600e-05
c   chi2=  0.1939734
      ae(4,3)=  2.0
c Fit parameters timelike     40 to   80 GeV
c     eu(7)  =   40.
c     eo(7)  =   80.
c     m1(7)  =   80.00000
      c1(7,3)=  6.4947648e-04
      c2(7,3)=  4.9386853e-07
      c3(7,3)=  -55.22332
      c4(7,3)=   26.13011
c   chi2=  7.2068366e-04
c Fit parameters timelike     80 to  250 GeV
c     eu(8)  =   80.
c     eo(8)  =  250.
c     m1(8)  =   91.18880
      c1(8,3)=  6.4265809e-04
      c2(8,3)= -2.8453374e-07
      c3(8,3)=  -23.38172
      c4(8,3)=  -6.251794
c   chi2=  1.1478480e-07
c Fit parameters timelike    250 to 1000 GeV
c     eu(9)  =  250.
c     eo(9)  = 1000.
c     m1(9)  = 1000.00000
      c1(9,3)=  6.3369947e-04
      c2(9,3)= -2.0898329e-07
      c3(9,3)=  0.0
      c4(9,3)=  0.0
c   chi2=  2.9124376E-06
c #4# error Delta_g
c Fit parameters spacelike  -1000 to  -200 GeV
c     eu(1)  =-1000.
c     eo(1)  = -200.
c     m1(1)=  -1000.000
      c1(1,4)=  1.2999176e-03
      c2(1,4)=  7.4505529e-06
      c3(1,4)=  0.0
      c4(1,4)=  0.0
c   chi2=  2.5312527E-05
c Fit parameters spacelike  -200 to  -20 GeV
c     eu(2)  = -200.
c     eo(2)  =  -20.
c     m1(2)  =  -100.0000
      c1(2,4)=  1.2883141e-03
      c2(2,4)= -1.3790827e-06
      c3(2,4)=   8.056159
      c4(2,4)= -0.1536313
c   chi2=  2.9774895e-04
      ae(2,4)=  1.0
c Fit parameters spacelike   -20 to   -2 GeV
c     eu(3)  =  -20.
c     eo(3)  =   -2.
c     m1(3)  =   -20.0000
      l1(3,4)=  4.3408e-4
      c1(3,4)=  2.0489733e-04
      c2(3,4)=   2.065011
      c3(3,4)= -0.6172962
      c4(3,4)= -2.5603661e-04
c   chi2=  7.5258738e-03
      ae(3,4)=  3.0
c Fit parameters spacelike    -2 to    0.25 GeV
c     eu(4)  =   -2.
c     eo(4)  =    0.25
c     m1(4)  =    -2.0000
      l1(4,4)=  4.3408e-4
      c1(4,4)= -1.5095409e-04
      c2(4,4)=  9.9847501e-04
      c3(4,4)=   1.636659
      c4(4,4)=  7.5892596e-05
c   chi2=  0.1959371
      ae(4,4)=  2.0
c Fit parameters timelike     40 to   80 GeV
c     eu(7)  =   40.
c     eo(7)  =   80.
c     m1(7)  =   80.00000
      c1(7,4)=  1.3335156e-03
      c2(7,4)=  2.2939612e-07
      c3(7,4)=  -246.4966
      c4(7,4)=   114.9956
c   chi2=  7.2293193e-04
c Fit parameters timelike     80 to  250 GeV
c     eu(8)  =   80.
c     eo(8)  =  250.
c     m1(8)  =   91.18880
      c1(8,4)=  1.3196438e-03
      c2(8,4)=  2.8937683e-09
      c3(8,4)=   5449.778
      c4(8,4)=   930.3875
c   chi2=  4.2109136e-08
c Fit parameters timelike    250 to 1000 GeV
c     eu(9)  =  250.
c     eo(9)  = 1000.
c     m1(9)  = 1000.00000
      c1(9,4)=  1.3016918e-03
      c2(9,4)= -3.6027674e-07
      c3(9,4)=  0.0
      c4(9,4)=  0.0
c   chi2=  2.8220852E-06
C ######################################################################
       Se=654./643.      ! rescaling error to published version 1995
       st20=0.2322
       s=e**2
       der=0.0
       deg=0.0
       errder=0.0
       errdeg=0.0
       if ((e.gt.1.e3).or.(e.lt.-1.e3)) goto 100
       if ((e.lt.4.e1).and.(e.gt.0.25)) goto 100
       i=1
       do while (e.ge.eo(i))
         i=i+1
       enddo
       if (e.eq.1.e3) i=9
       if (e.eq.0.0 ) goto 100
       s0=sign(1d0,m1(i))*m1(i)**2
       s =sign(1d0,e)*e**2
       x1=s0/s
       xi=1.0/x1
       x2=x1**2
       if (ae(i,1).le.0.0) then
         do j=1,4
           xlar=xi+ae(i,j)*exp(-xi)
           xlog=log(xlar)
           res(j)=c1(i,j)
     .           +c2(i,j)*(xlog+c3(i,j)*(x1-1.0)+c4(i,j)*(x2-1.0))
         enddo
       else if (ae(i,1).eq.2.0) then
         hx     =xi**2
         do j=1,2
           fx     =1.0-c2(i,j)*s
           gx     = c3(i,j)*s/(c3(i,j)-s)
           xx     =log(abs(fx))+c2(i,j)*gx
           res(j)=c1(i,j)*xx-l1(i,j)*gx+c4(i,j)*hx
         enddo
         do j=3,4
           u      =abs(s)
           gx     =-c3(i,j)*u/(c3(i,j)+u)
           xx     =xi**3/(sqrt(abs(xi))**5+c2(i,j))
           res(j)=c1(i,j)*xx-l1(i,j)*gx+c4(i,j)*hx
         enddo
       else if (ae(i,1).eq.3.0) then
         hx     =xi
         do j=1,4
           fx     =1.0-c2(i,j)*s
           gx     = c3(i,j)*s/(c3(i,j)-s)
           xx     =log(abs(fx))+c2(i,j)*gx
           res(j)=c1(i,j)*xx-l1(i,j)*gx+c4(i,j)*hx
         enddo
       endif
       der=res(1)
       deg=res(2)*st20/st2
       errder=res(3)*Se
       errdeg=res(4)*Se
       goto 100
* 99    write(*,*) ' out of range! '
100    return
       end
*
* Below are auxiliary functions for ZFITTER package
*
      SUBROUTINE FDSIMP (AA1,BB1,HH1,REPS1,AEPS1,FUNCT,DFUN,DFUNIN,
     +                                               DUMMY,AI,AIH,AIABS)
*     ==================================================================
C        B1
C AI=INT {FUNCT(X)*D
C        A1
C A1,B1 -THE LIMITS OF INTEGRATION
C H1    -AN INITIAL STEP OF INTEGRATION
C REPS1,AEPS1 - RELATIVE AND ABSOLUTE PRECISION OF INTEGRATION
C FUNCT -A NAME OF FUNCTION SUBPROGRAM FOR CALCULATION OF INTEGRAND +
C X - AN ARGUMENT OF THE INTEGRAND
C DFUNIN - INVERSE ( DFUN ). SHOULD BE DFUNIN
C AI - THE VALUE OF INTEGRAL
C AIH- THE VALUE OF INTEGRAL WITH THE STEP OF INTEGRATION
C AIABS- THE VALUE OF INTEGRAL FOR MODULE OF THE INTEGRAND
C THIS SUBROGRAM CALCULATES THE DEFINITE INTEGRAL WITH THE RELATIVE OR
C ABSOLUTE PRECISION BY SIMPSON+S METHOD WITH THE AUTOMATICAL CHOICE
C OF THE STEP OF INTEGRATION
C IF AEPS1    IS VERY SMALL(LIKE 1.E-17),THEN CALCULATION OF INTEGRAL
C WITH REPS1,AND IF REPS1 IS VERY SMALL (LIKE 1.E-10),THEN CALCULATION
C OF INTEGRAL WITH AEPS1
C WHEN  AEPS1=REPS1=0. THEN CALCULATION WITH THE CONSTANT STEP H1
C
      IMPLICIT REAL*8(A-H,O-Z)
      DIMENSION F(7),P(5)
      EXTERNAL FUNCT,DFUN,DFUNIN
*
      DUM=DUMMY
      H1=(DFUN(BB1)-DFUN(AA1))/(BB1-AA1+1.654876596E-20)*HH1
      A1=DFUN(AA1)
      B1=DFUN(BB1)
      H=DSIGN(H1,B1-A1+1.654876596E-20)
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
      F(1)=FUNCT(DFUNIN(X))/3.
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
   11 F(K)=FUNCT(DFUNIN(X))/3.
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
 
      DOUBLE PRECISION FUNCTION DDILOG(X)
*     ====== ========= ======== =========
C
      DOUBLE PRECISION X,Y,T,S,A,PI3,PI6,ZERO,ONE,HALF,MALF,MONE,MTWO
      DOUBLE PRECISION C(0:18),H,ALFA,B0,B1,B2
C
      DATA ZERO /0.0D0/, ONE /1.0D0/
      DATA HALF /0.5D0/, MALF /-0.5D0/, MONE /-1.0D0/, MTWO /-2.0D0/
      DATA PI3 /3.28986 81336 96453D0/, PI6 /1.64493 40668 48226D0/
C
      DATA C( 0) / 0.42996 69356 08137 0D0/
      DATA C( 1) / 0.40975 98753 30771 1D0/
      DATA C( 2) /-0.01858 84366 50146 0D0/
      DATA C( 3) / 0.00145 75108 40622 7D0/
      DATA C( 4) /-0.00014 30418 44423 4D0/
      DATA C( 5) / 0.00001 58841 55418 8D0/
      DATA C( 6) /-0.00000 19078 49593 9D0/
      DATA C( 7) / 0.00000 02419 51808 5D0/
      DATA C( 8) /-0.00000 00319 33412 7D0/
      DATA C( 9) / 0.00000 00043 45450 6D0/
      DATA C(10) /-0.00000 00006 05784 8D0/
      DATA C(11) / 0.00000 00000 86121 0D0/
      DATA C(12) /-0.00000 00000 12443 3D0/
      DATA C(13) / 0.00000 00000 01822 6D0/
      DATA C(14) /-0.00000 00000 00270 1D0/
      DATA C(15) / 0.00000 00000 00040 4D0/
      DATA C(16) /-0.00000 00000 00006 1D0/
      DATA C(17) / 0.00000 00000 00000 9D0/
      DATA C(18) /-0.00000 00000 00000 1D0/
 
      IF(X .EQ. ONE) THEN
       DDILOG=PI6
       RETURN
      ELSE IF(X .EQ. MONE) THEN
       DDILOG=MALF*PI6
       RETURN
      END IF
      T=-X
      IF(T .LE. MTWO) THEN
       Y=MONE/(ONE+T)
       S=ONE
       A=-PI3+HALF*(LOG(-T)**2-LOG(ONE+ONE/T)**2)
      ELSE IF(T .LT. MONE) THEN
       Y=MONE-T
       S=MONE
       A=LOG(-T)
       A=-PI6+A*(A+LOG(ONE+ONE/T))
      ELSE IF(T .LE. MALF) THEN
       Y=(MONE-T)/T
       S=ONE
       A=LOG(-T)
       A=-PI6+A*(MALF*A+LOG(ONE+T))
      ELSE IF(T .LT. ZERO) THEN
       Y=-T/(ONE+T)
       S=MONE
       A=HALF*LOG(ONE+T)**2
      ELSE IF(T .LE. ONE) THEN
       Y=T
       S=ONE
       A=ZERO
      ELSE
       Y=ONE/T
       S=MONE
       A=PI6+HALF*LOG(T)**2
      END IF
 
      H=Y+Y-ONE
      ALFA=H+H
      B1=ZERO
      B2=ZERO
      DO 1 I = 18,0,-1
      B0=C(I)+ALFA*B1-B2
      B2=B1
    1 B1=B0
      DDILOG=-(S*(B0-H*B2)+A)
      RETURN
      END
 
      DOUBLE PRECISION FUNCTION TRILOG(X)
*     ====== ========= ======== =========
C Tsuyoshi Matsuura 1987
C
C     TRILOG: Li3   between 0 and 1  !!!
C
      DOUBLE PRECISION X,S(0:10),L(0:20),U,Z,HELP,Z3
      DOUBLE PRECISION DDILOG
C
C     S: COEFFICIENTS OF S1,2
C     L: COEFFICIENTS OF Li3
C
      DATA S/0.5000000000000000D+00,2.0833333333333333D-02,
     1      -2.3148148148148148D-04,4.1335978835978837D-06,
     2      -8.2671957671957673D-08,1.7397297489890083D-09,
     3      -3.7744215276339238D-11,8.3640853316779243D-13,
     4      -1.8831557201792127D-14,4.2930310281389223D-16,
     5      -9.8857668116275541D-18/
      DATA L/1.0000000000000000D+00,-0.3750000000000000D+00,
     1       7.8703703703703705E-02,-8.6805555555555557E-03,
     2       1.2962962962962963E-04, 8.1018518518518520E-05,
     3      -3.4193571608537598E-06,-1.3286564625850340E-06,
     4       8.6608717561098512E-08, 2.5260875955320400E-08,
     5      -2.1446944683640648E-09,-5.1401106220129790E-10,
     6       5.2495821146008296E-11, 1.0887754406636318E-11,
     7      -1.2779396094493696E-12,-2.3698241773087452E-13,
     8       3.1043578879654624E-14, 5.2617586299125060E-15,
     9      -7.5384795499492655E-16,-1.1862322577752285E-16,
     1       1.8316979965491384E-17/
      DATA Z3/1.2020569031595943D+00/
C
      IF(X .LT. 0D0  .OR.  X .GT. 1D0) THEN
         WRITE(*,*)' **************************************'
         WRITE(*,*)' Li3 called with X = ',X
         WRITE(*,*)' This should lie between 0 and 1 !!!'
         STOP' The program stops right here !!!'
      ENDIF
      IF (X.LT.0.5D0) THEN
         IF (X.GT.0.0D0) THEN
            U=-DLOG(1.0D0-X)
            HELP=U*L(20)+L(19)
            DO 10 I=18,0,-1
               HELP=U*HELP+L(I)
   10       CONTINUE
            TRILOG=U*HELP
         ELSE
            TRILOG=0.0D0
         ENDIF
      ELSE
         IF (X.LT.1.0D0) THEN
            U=-DLOG(X)
            Z=U*U
            HELP=Z*S(10)+S(9)
            DO 20 I=8,0,-1
               HELP=Z*HELP+S(I)
   20       CONTINUE
            HELP=1.0D0/2.0D0*(Z*HELP-Z*U/6.0D0)
C           LI3=-HELP+DLOG(X)*DILOG(X)+0.5D0*DLOG(1D0-X)*DLOG(X)**2+Z3
        TRILOG=-HELP+DLOG(X)*DDILOG(X)+0.5D0*DLOG(1D0-X)*DLOG(X)**2+Z3
         ELSE
          TRILOG=Z3
         ENDIF
      ENDIF
      END
 
      DOUBLE PRECISION FUNCTION S12(X)
*     ====== ========= ======== ======
C Tsuyoshi Matsuura 1987
C
C     S1,2   between 0 and 1  !!!
C
      REAL*8 X,S(0:10),L(0:20),U,Z,HELP,Z3
      REAL*8 DDILOG
C
C     S: COEFFICIENTS OF S1,2
C     L: COEFFICIENTS OF Li3
C
      DATA S/0.5000000000000000D+00,2.0833333333333333D-02,
     1      -2.3148148148148148D-04,4.1335978835978837D-06,
     2      -8.2671957671957673D-08,1.7397297489890083D-09,
     3      -3.7744215276339238D-11,8.3640853316779243D-13,
     4      -1.8831557201792127D-14,4.2930310281389223D-16,
     5      -9.8857668116275541D-18/
      DATA L/1.0000000000000000D+00,-0.3750000000000000D+00,
     1       7.8703703703703705E-02,-8.6805555555555557E-03,
     2       1.2962962962962963E-04, 8.1018518518518520E-05,
     3      -3.4193571608537598E-06,-1.3286564625850340E-06,
     4       8.6608717561098512E-08, 2.5260875955320400E-08,
     5      -2.1446944683640648E-09,-5.1401106220129790E-10,
     6       5.2495821146008296E-11, 1.0887754406636318E-11,
     7      -1.2779396094493696E-12,-2.3698241773087452E-13,
     8       3.1043578879654624E-14, 5.2617586299125060E-15,
     9      -7.5384795499492655E-16,-1.1862322577752285E-16,
     1       1.8316979965491384E-17/
      DATA Z3/1.2020569031595943D+00/
C
      IF(X .LT. 0D0  .OR.  X .GT. 1D0) THEN
         WRITE(*,*)' **************************************'
         WRITE(*,*)' S12 called with X = ',X
         WRITE(*,*)' This should lie between 0 and 1 !!!'
         STOP' The program stops right here !!!'
      ENDIF
      IF (X.LT.0.5D0) THEN
         IF (X.GT.0.0D0) THEN
            U=-DLOG(1.0D0-X)
            Z=U*U
            HELP=Z*S(10)+S(9)
            DO 10 I=8,0,-1
               HELP=HELP*Z+S(I)
   10       CONTINUE
            S12=1.0D0/2.0D0*(Z*HELP-Z*U/6.0D0)
         ELSE
            S12=0.0D0
         ENDIF
      ELSE
         IF (X.LT.1.0D0) THEN
            U=-DLOG(X)
            HELP=U*L(20)+L(19)
            DO 20 I=18,0,-1
               HELP=HELP*U+L(I)
   20       CONTINUE
            HELP=U*HELP
            S12=-HELP+DLOG(1.0D0-X)*DDILOG(1.0D0-X)+
     +           0.5D0*DLOG(X)*DLOG(1.0D0-X)**2+Z3
         ELSE
            S12=Z3
         ENDIF
      ENDIF
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
      EXTERNAL FUNCT
*
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
      EXTERNAl FUNCT
*
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
C SIMPU
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
      EXTERNAl FUNCT
*
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

      SUBROUTINE SIMPV(A1,B1,H1,REPS1,AEPS1,FUNCT,X,AI,AIH,AIABS)
C SIMPV
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
      EXTERNAl FUNCT
*
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
 
      FUNCTION XSPENZ(Z)
C================================================================
C
      IMPLICIT COMPLEX*16(X,Y)
      IMPLICIT REAL*8(A-H,O-W,Z)
      COMPLEX*16 Z,XCDIL,CSPENZ,LOG
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
      COMPLEX*16 Z,Z1,CLZ,CLZP,CADD,LOG
      COMMON/CDZPIF/PI,F1
      DIMENSION ZETA(15)
      EXTERNAL FZETA
      DATA N/0/,TCH/1.D-16/
      SAVE ZETA
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
**********************************************************************
* SERVICE & BURKHARD ET AL ROUTINES
* (SHOULD NOT BE REPEATED WHEN IN ZFITTER)
**********************************************************************
      SUBROUTINE PIGINI
*-INITIALIZATION ROUTINE FOR BURKHARD ET AL. VACUUM POLARIZATION
      IMPLICIT REAL*8(A-Z)
      COMMON /BHANUM/ PI,F1,AL2,ZET3
      COMMON /BHAPHY/ ALFAI,AL1PI,ALQE2,GFERMI,CSIGNB
      COMMON /BHAPAR /AMZ,GAMZ,GAMEE,SW2,GV,GA
      COMMON /BHAELE/ AME,AME2,QE,QEM,QE2,COMB1,COMB2,COMB3
      COMMON /LEPT/ME,MMU,MTAU/HAD/MU,MD,MS,MC,MB,MT
      COMMON /ALF/AL,ALPHA,ALFA
      COMMON /BOSON/MZ,MW,MH
C NUMERICAL CONSTANTS
      ALFA=1D0/ALFAI
      AL=AL1PI
      ALPHA=AL/4.
 
C MASS OF THE Z0
      MZ=AMZ
C
C SIN**2 OF THE ELECTROWEAK MIXING ANGLE
      SW=SW2
      SW=0.227018D0
C
C MASS OF THE W BOSON
      CW=1.-SW
      MW=MZ*DSQRT(CW)
      MW=80.1561D0
C
C MASS OF THE HIGGS BOSON
      MH=100D0
C
C MASSES OF THE FERMIONS: LEPTONS...
      ME=AME
      MMU=.106D0
      MTAU=1.785D0
C
C ...AND QUARKS (THE TOP QUARK MASS IS STILL A FREE PARAMETER)
      MU=.032D0
      MD=.0321D0
      MS=.15D0
      MC=1.5D0
      MB=4.5D0
      MT=130D0
C
      END
 
      FUNCTION XPIG(S)
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
      COMPLEX*16 P,XPIG,PIL,PIH,HADRQQ,FC
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
      XPIG=PIL+PIH+PIW
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
C     as imaginary part take -i alfa/3 Rexpbh
      HADRQQ=REPIAA-(0.,1.)*ALFA/3.*REXPBH(S)
CEXPO HADRQQ=HADRQQ/(4.D0*PI*ALFA)  ! EXPOstar divides by 4 pi alfa
      END
C--------+---------+---------+---------+---------+---------+---------+--
      FUNCTION REXPBH(S)
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
      REXPBH=0.D0
      IF(S.GT.0.D0) THEN
        W=SQRT(S)
        IF(W.GT.WW(1)) THEN
          DO 2 I=1,NDIM
C           find out between which points of the RR array W is
            K=I
            IF(I.LT.NDIM) THEN
              IF(W.LT.WW(I+1)) GOTO 3
            ENDIF
    2     CONTINUE
    3     CONTINUE
          REXPBH=AA(K)+BB(K)*W
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
 
*      DOUBLE PRECISION FUNCTION F(Y,A,B)
*      IMPLICIT REAL*8(A-Z)
*      IF(A.LT.1.0D-05) GO TO 50
*      F1=2.D0
*      IF(A.EQ.B) GO TO 10
*      F1=1.D0+((A*A-B*B)/Y-(A*A+B*B)/(A*A-B*B))*DLOG(B/A)
*   10 CONTINUE
*      Q=(A+B)*(A+B)
*      P=(A-B)*(A-B)
*      IF(Y.LT.P) GO TO 20
*      IF(Y.GE.Q) GO TO 30
*      F2=DSQRT((Q-Y)*(Y-P))*(-2.D0)*DATAN(DSQRT((Y-P)/(Q-Y)))
*      GO TO 40
*   20 CONTINUE
*      F2=DSQRT((Q-Y)*(P-Y))*DLOG((DSQRT(Q-Y)+DSQRT(P-Y))**2/
*     &                                               (4.D0*A*B))
*      GO TO 40
*   30 CONTINUE
*      F2=DSQRT((Y-Q)*(Y-P))*(-1.D0)*DLOG((DSQRT(Y-P)+DSQRT(Y-Q))**2/
*     &(4.D0*A*B))
*   40 CONTINUE
*      F=F1+F2/Y
*      GO TO 70
*   50 CONTINUE
*      IF(Y.EQ.(B*B)) GO TO 65
*      IF(Y.LT.(B*B)) GO TO 60
*      F=1.D0+(1.D0-B*B/Y)*DLOG(B*B/(Y-B*B))
*      GO TO 70
*   60 CONTINUE
*      F=1.D0+(1.D0-B*B/Y)*DLOG(B*B/(B*B-Y))
*      GO TO 70
*   65 CONTINUE
*      F=1.D0
*   70 CONTINUE
*      RETURN
*      END
 
       SUBROUTINE INTERB(NPOINT,XMIN,XMAX,Y,XI,YI)
*=======================================================================
*     ROUTINE MAKES QUADRATIC INTERPOLATION FOR ARRAY "Y" OF "NPOINT"
*     EQUIDISTANT POINTS IN THE INTERVAL (XMIN,XMAX)
*-----------------------------------------------------------------------
       IMPLICIT REAL*8(A-H,O-Z)
*
       PARAMETER (NR=20)
       DIMENSION Y(NR)
*
       IF(NR.LT.NPOINT) STOP 'WRONG NUMBER OF POINTS'
       XSTEP=(XMAX-XMIN)/(NPOINT-1)
       N=INT((XI-XMIN)/XSTEP+0.5)+1
       IF(N.LT.2) THEN
         N=2
       ELSE IF(N.GT.NPOINT-1) THEN
         N=NPOINT-1
       END IF
*
       XCLOSE=XMIN+XSTEP*(N-1)
       W1=(XI-XCLOSE+XSTEP)
       W2=(XI-XCLOSE)
       W3=(XI-XCLOSE-XSTEP)
*
       YI=(0.5D0*W2*W3*Y(N-1)-W3*W1*Y(N)+0.5D0*W1*W2*Y(N+1))/XSTEP**2
       END
 
      SUBROUTINE FESIMP (AA1,BB1,HH1,REPS1,AEPS1,FUNCT,DFUN,DFUNIN,
     + DUMMY,AI,AIH,AIABS)
*=======================================================================
C        B1
C AI=INT {FUNCT(X)*D[DFUN(X)]}
C        A1
C A1,B1 -THE LIMITS OF INTEGRATION
C H1    -AN INITIAL STEP OF INTEGRATION
C REPS1,AEPS1 - RELATIVE AND ABSOLUTE PRECISION OF INTEGRATION
C FUNCT -A NAME OF FUNCTION SUBPROGRAM FOR CALCULATION OF INTEGRAND +
C X - AN ARGUMENT OF THE INTEGRAND
C DFUNIN - INVERSE ( DFUN ). SHOULD BE DFUNIN[DFUN(X)]=X.
C AI - THE VALUE OF INTEGRAL
C AIH- THE VALUE OF INTEGRAL WITH THE STEP OF INTEGRATION
C AIABS- THE VALUE OF INTEGRAL FOR MODULE OF THE INTEGRAND
C THIS SUBROGRAM CALCULATES THE DEFINITE INTEGRAL WITH THE RELATIVE OR
C ABSOLUTE PRECISION BY SIMPSON+S METHOD WITH THE AUTOMATICAL CHOICE
C OF THE STEP OF INTEGRATION
C IF AEPS1    IS VERY SMALL(LIKE 1.E-17),THEN CALCULATION OF INTEGRAL
C WITH REPS1,AND IF REPS1 IS VERY SMALL (LIKE 1.E-10),THEN CALCULATION
C OF INTEGRAL WITH AEPS1
C WHEN  AEPS1=REPS1=0. THEN CALCULATION WITH THE CONSTANT STEP H1
C
       IMPLICIT REAL*8(A-H,O-Z)
       DIMENSION F(7),P(5)
       EXTERNAL FUNCT,DFUN,DFUNIN
*
       DUM=DUMMY
       H1=(DFUN(BB1)-DFUN(AA1))/(BB1-AA1+1.654876596E-20)*HH1
       A1=DFUN(AA1)
       B1=DFUN(BB1)
       H=DSIGN(H1,B1-A1+1.654876596E-20)
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
    1  REPS=DABS(REPS1)
       AEPS=DABS(AEPS1)
       DO 3 K=1,7
    3  F(K)=10.D16
       X=A
       C=0.D0
       F(1)=FUNCT(DFUNIN(X))/3.
    4  X0=X
       IF((X0+4.*H-B)*S) 5,5,6
    6  H=(B-X0)/4.
       IF(H) 7,2,7
    7  DO 8 K=2,7
    8  F(K)=10.D16
       C=1.D0
    5  DI2=F(1)
       DI3=DABS(F(1))
       DO 9 K=2,5
         X=X+H
         IF((X-B)*S) 23,24,24
   24    X=B
   23    IF(F(K)-10.D16) 10,11,10
   11    F(K)=FUNCT(DFUNIN(X))/3.
   10    DI2=DI2+P(K)*F(K)
    9  DI3=DI3+P(K)*ABS(F(K))
       DI1=(F(1)+4.*F(3)+F(5))*2.*H
       DI2=DI2*H
       DI3=DI3*H
       IF(REPS) 12,13,12
   13  IF(AEPS) 12,14,12
   12  EPS=DABS((AIABS+DI3)*REPS)
       IF(EPS-AEPS) 15,16,16
   15  EPS=AEPS
   16  DELTA=DABS(DI2-DI1)
       IF(DELTA-EPS) 20,21,21
   20  IF(DELTA-EPS/8.) 17,14,14
   17  H=2.*H
       F(1)=F(5)
       F(2)=F(6)
       F(3)=F(7)
       DO 19 K=4,7
   19  F(K)=10.D16
       GO TO 18
   14  F(1)=F(5)
       F(3)=F(6)
       F(5)=F(7)
       F(2)=10.D16
       F(4)=10.D16
       F(6)=10.D16
       F(7)=10.D16
   18  DI1=DI2+(DI2-DI1)/15.
       AI=AI+DI1
       AIH=AIH+DI2
       AIABS=AIABS+DI3
       GO TO 22
   21  H=H/2.
       F(7)=F(5)
       F(6)=F(4)
       F(5)=F(3)
       F(3)=F(2)
       F(2)=10.D16
       F(4)=10.D16
       X=X0
       C=0.D0
       GO TO 5
   22  IF(C) 2,4,2
    2  RETURN
       END
 
      SUBROUTINE DZERO(A,B,X0,R,EPS,MXF,F)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C     LOGICAL MFLAG,RFLAG
      EXTERNAL F
 
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
C+
C    5 CALL KERMTR('C205.1',LGFILE,MFLAG,RFLAG)
C      IF(MFLAG) THEN
C       IF(LGFILE .EQ. 0) WRITE(*,100)
C       IF(LGFILE .NE. 0) WRITE(LGFILE,100)
C      END IF
C      IF(.NOT.RFLAG) CALL ABEND
    5 PRINT *,'***** DZERO ... F(A) AND F(B) HAVE THE SAME SIGN'
C-
      R=-2*(XB-XA)
      X0=0
      RETURN
C+
C    6 CALL KERMTR('C205.2',LGFILE,MFLAG,RFLAG)
C      IF(MFLAG) THEN
C       IF(LGFILE .EQ. 0) WRITE(*,101)
C       IF(LGFILE .NE. 0) WRITE(LGFILE,101)
C      END IF
C      IF(.NOT.RFLAG) CALL ABEND
    6 PRINT *,'***** DZERO ... TOO MANY FUNCTION CALLS'
C-
      R=-HALF*ABS(XB-XA)
      X0=0
      RETURN
  100 FORMAT(1X,'***** CERN C205 DZERO ... F(A) AND F(B)',
     1          ' HAVE THE SAME SIGN')
  101 FORMAT(1X,'***** CERN C205 DZERO ... TOO MANY FUNCTION CALLS')
      END

      DOUBLE PRECISION FUNCTION DGAMMA(X)
C
C		Tue Feb 21 14:15:50 MET 1995
c from cernpams at cernvm, file: kernnum car
c changes by t.riemann for a HP workstation.
c another computer may be more precise and then use of the higher
c accuracy may be recommended. 8 oct 1992
      LOGICAL MFLAG,RFLAG
      REAL SX
      DOUBLE PRECISION X,U,F,ZERO,ONE,THREE,FOUR,PI
      DOUBLE PRECISION C(0:24),H,ALFA,B0,B1,B2
      DATA ZERO /0.0D0/, ONE /1.0D0/, THREE /3.0D0/, FOUR /4.0D0/
cHP  +SELF,IF=NUMHIPRE.
c     DATA NC /24/
c     DATA PI    /3.14159 26535 89793 23846 26433 83D0/
c     DATA C( 0) /3.65738 77250 83382 43849 88068 39D0/
c     DATA C( 1) /1.95754 34566 61268 26928 33742 26D0/
c     DATA C( 2) / .33829 71138 26160 38915 58510 73D0/
c     DATA C( 3) / .04208 95127 65575 49198 51083 97D0/
c     DATA C( 4) / .00428 76504 82129 08770 04289 08D0/
c     DATA C( 5) / .00036 52121 69294 61767 02198 22D0/
c     DATA C( 6) / .00002 74006 42226 42200 27170 66D0/
c     DATA C( 7) / .00000 18124 02333 65124 44603 05D0/
c     DATA C( 8) / .00000 01096 57758 65997 06993 06D0/
c     DATA C( 9) / .00000 00059 87184 04552 00046 95D0/
c     DATA C(10) / .00000 00003 07690 80535 24777 71D0/
c     DATA C(11) / .00000 00000 14317 93029 61915 76D0/
c     DATA C(12) / .00000 00000 00651 08773 34803 70D0/
c     DATA C(13) / .00000 00000 00025 95849 89822 28D0/
c     DATA C(14) / .00000 00000 00001 10789 38922 59D0/
c     DATA C(15) / .00000 00000 00000 03547 43620 17D0/
c     DATA C(16) / .00000 00000 00000 00168 86075 04D0/
c     DATA C(17) / .00000 00000 00000 00002 73543 58D0/
c     DATA C(18) / .00000 00000 00000 00000 30297 74D0/
c     DATA C(19) /-.00000 00000 00000 00000 00571 22D0/
c     DATA C(20) / .00000 00000 00000 00000 00090 77D0/
c     DATA C(21) /-.00000 00000 00000 00000 00005 05D0/
c     DATA C(22) / .00000 00000 00000 00000 00000 41D0/
c     DATA C(23) /-.00000 00000 00000 00000 00000 03D0/
c     DATA C(24) / .00000 00000 00000 00000 00000 01D0/
cHP +SELF,IF=NUMLOPRE.
      DATA NC /15/
      DATA PI    /3.14159 26535 89793 24D0/
      DATA C( 0) /3.65738 77250 83382 44D0/
      DATA C( 1) /1.95754 34566 61268 27D0/
      DATA C( 2) / .33829 71138 26160 39D0/
      DATA C( 3) / .04208 95127 65575 49D0/
      DATA C( 4) / .00428 76504 82129 09D0/
      DATA C( 5) / .00036 52121 69294 62D0/
      DATA C( 6) / .00002 74006 42226 42D0/
      DATA C( 7) / .00000 18124 02333 65D0/
      DATA C( 8) / .00000 01096 57758 66D0/
      DATA C( 9) / .00000 00059 87184 05D0/
      DATA C(10) / .00000 00003 07690 81D0/
      DATA C(11) / .00000 00000 14317 93D0/
      DATA C(12) / .00000 00000 00651 09D0/
      DATA C(13) / .00000 00000 00025 96D0/
      DATA C(14) / .00000 00000 00001 11D0/
      DATA C(15) / .00000 00000 00000 04D0/
cHP  +SELF.
      U=X
      IF(X .LE. ZERO) THEN
       IF(X .EQ. INT(X)) THEN
        CALL KERMTR('C305.1',LGFILE,MFLAG,RFLAG)
        IF(MFLAG) THEN
         SX=X
         IF(LGFILE .EQ. 0) THEN
          WRITE(*,100) SX
         ELSE
          WRITE(LGFILE,100) SX
         END IF
        END IF
        IF(.NOT.RFLAG) CALL ABEND
        DGAMMA=ZERO
        RETURN
       ELSE
        U=ONE-U
       END IF
      END IF
      F=ONE
      IF(U .LT. THREE) THEN
       DO 1 I = 1,INT(FOUR-U)
       F=F/U
    1  U=U+ONE
      ELSE
       DO 2 I = 1,INT(U-THREE)
       U=U-ONE
    2  F=F*U
      END IF
      U=U-THREE
      H=U+U-ONE
      ALFA=H+H
      B1=ZERO
      B2=ZERO
      DO 3 I = NC,0,-1
      B0=C(I)+ALFA*B1-B2
      B2=B1
    3 B1=B0
      U=F*(B0-H*B2)
      IF(X .LT. ZERO) U=PI/(SIN(PI*X)*U)
      DGAMMA=U
      RETURN
  100 FORMAT(1X,'DGAMMA ... ARGUMENT IS NON-POSITIVE INTEGER = ',E15.1)
      END
C
       subroutine abend
       stop
       end

          SUBROUTINE KERSET(ERCODE,LGFILE,LIMITM,LIMITR)
C
C	Tue Feb 21 14:15:50 MET 1995
                    PARAMETER(KOUNTE  =  27)
          CHARACTER*6         ERCODE,   CODE(KOUNTE)
          LOGICAL             MFLAG,    RFLAG
          INTEGER             KNTM(KOUNTE),       KNTR(KOUNTE)
          DATA      LOGF      /  0  /
          DATA      CODE(1), KNTM(1), KNTR(1)  / 'C204.1', 255, 255 /
          DATA      CODE(2), KNTM(2), KNTR(2)  / 'C204.2', 255, 255 /
          DATA      CODE(3), KNTM(3), KNTR(3)  / 'C204.3', 255, 255 /
          DATA      CODE(4), KNTM(4), KNTR(4)  / 'C205.1', 255, 255 /
          DATA      CODE(5), KNTM(5), KNTR(5)  / 'C205.2', 255, 255 /
          DATA      CODE(6), KNTM(6), KNTR(6)  / 'C305.1', 255, 255 /
          DATA      CODE(7), KNTM(7), KNTR(7)  / 'C308.1', 255, 255 /
          DATA      CODE(8), KNTM(8), KNTR(8)  / 'C312.1', 255, 255 /
          DATA      CODE(9), KNTM(9), KNTR(9)  / 'C313.1', 255, 255 /
          DATA      CODE(10),KNTM(10),KNTR(10) / 'C336.1', 255, 255 /
          DATA      CODE(11),KNTM(11),KNTR(11) / 'C337.1', 255, 255 /
          DATA      CODE(12),KNTM(12),KNTR(12) / 'C341.1', 255, 255 /
          DATA      CODE(13),KNTM(13),KNTR(13) / 'D103.1', 255, 255 /
          DATA      CODE(14),KNTM(14),KNTR(14) / 'D106.1', 255, 255 /
          DATA      CODE(15),KNTM(15),KNTR(15) / 'D209.1', 255, 255 /
          DATA      CODE(16),KNTM(16),KNTR(16) / 'D509.1', 255, 255 /
          DATA      CODE(17),KNTM(17),KNTR(17) / 'E100.1', 255, 255 /
          DATA      CODE(18),KNTM(18),KNTR(18) / 'E104.1', 255, 255 /
          DATA      CODE(19),KNTM(19),KNTR(19) / 'E105.1', 255, 255 /
          DATA      CODE(20),KNTM(20),KNTR(20) / 'E208.1', 255, 255 /
          DATA      CODE(21),KNTM(21),KNTR(21) / 'E208.2', 255, 255 /
          DATA      CODE(22),KNTM(22),KNTR(22) / 'F010.1', 255,   0 /
          DATA      CODE(23),KNTM(23),KNTR(23) / 'F011.1', 255,   0 /
          DATA      CODE(24),KNTM(24),KNTR(24) / 'F012.1', 255,   0 /
          DATA      CODE(25),KNTM(25),KNTR(25) / 'F406.1', 255,   0 /
          DATA      CODE(26),KNTM(26),KNTR(26) / 'G100.1', 255, 255 /
          DATA      CODE(27),KNTM(27),KNTR(27) / 'G100.2', 255, 255 /
          LOGF  =  LGFILE
             L  =  0
          IF(ERCODE .NE. ' ')  THEN
             DO 10  L = 1, 6
                IF(ERCODE(1:L) .EQ. ERCODE)  GOTO 12
  10            CONTINUE
  12         CONTINUE
          ENDIF
          DO 14     I  =  1, KOUNTE
             IF(L .EQ. 0)  GOTO 13
             IF(CODE(I)(1:L) .NE. ERCODE(1:L))  GOTO 14
  13         IF(LIMITM.GE.0) KNTM(I)  =  LIMITM
             IF(LIMITR.GE.0) KNTR(I)  =  LIMITR
  14         CONTINUE
          RETURN
          ENTRY KERMTR(ERCODE,LOG,MFLAG,RFLAG)
          LOG  =  LOGF
          DO 20     I  =  1, KOUNTE
             IF(ERCODE .EQ. CODE(I))  GOTO 21
  20         CONTINUE
          WRITE(*,1000)  ERCODE
          CALL ABEND
          RETURN
  21      RFLAG  =  KNTR(I) .GE. 1
          IF(RFLAG  .AND.  (KNTR(I) .LT. 255))  KNTR(I)  =  KNTR(I) - 1
          MFLAG  =  KNTM(I) .GE. 1
          IF(MFLAG  .AND.  (KNTM(I) .LT. 255))  KNTM(I)  =  KNTM(I) - 1
          IF(.NOT. RFLAG)  THEN
             IF(LOGF .LT. 1)  THEN
                WRITE(*,1001)  CODE(I)
             ELSE
                WRITE(LOGF,1001)  CODE(I)
             ENDIF
          ENDIF
          IF(MFLAG .AND. RFLAG)  THEN
             IF(LOGF .LT. 1)  THEN
                WRITE(*,1002)  CODE(I)
             ELSE
                WRITE(LOGF,1002)  CODE(I)
             ENDIF
          ENDIF
          RETURN
1000      FORMAT(' KERNLIB LIBRARY ERROR. ' /
     +           ' ERROR CODE ',A6,' NOT RECOGNIZED BY KERMTR',
     +           ' ERROR MONITOR. RUN ABORTED.')
1001      FORMAT(/' ***** RUN TERMINATED BY CERN LIBRARY ERROR ',
     +           'CONDITION ',A6)
1002      FORMAT(/' ***** CERN LIBRARY ERROR CONDITION ',A6)
          END
*
* Bardin-Chizov QCD-library
* 
      FUNCTION RXQCDS(ALST,AMZ2,AMW2,AMT2)
* 
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      DATA PI/3.1415926535898D0/
      DATA D2/1.6449340668482D0/
*
* WITHOUT FACTOR ALPI/4/PI
*
      QTM =2D0/3D0
      CW2 =AMW2/AMZ2
      SW2 =1D0-CW2
      VT2 =(1D0-4*QTM*SW2)**2
      ALTW=-AMT2/AMW2
      ALTZ=-AMT2/AMZ2
      PVFBW=ALTW*DREAL(XPVF0(ALTW))
      PVFBZ=ALTZ*DREAL(XPVF0(ALTZ))
      PVFTW=ALTW*DREAL(XPVFI(ALTW))
      PVFTZ=ALTZ*DREAL(XPVFI(ALTZ))
      PAFTZ=ALTZ*DREAL(XPAFI(ALTZ))
      PWFTW=ALTW*DREAL(XPWFI(ALTW))
      PWF0  =-3D0*D2-105D0/8D0
*
      RXQCDT=ALST/3D0/PI/SW2*(4D0*SW2*QTM**2*(PVFTZ-PVFBZ)
     &      -1D0/4D0/SW2*(VT2*(PVFTZ-PVFBZ)+PAFTZ-PVFBZ)
     &      +(CW2-SW2)/SW2*(PWFTW-PVFBW)-AMT2/AMW2*PWF0)
      RXQCDB=ALST/PI/SW2**2*(CW2-SW2)*LOG(AMZ2/AMW2)
      RXQCDS=RXQCDT+RXQCDB
*
      END
 
      FUNCTION RXQCD(ALST,AMZ2,AMW2,AMT2)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      DATA PI/3.1415926535898D0/
      DATA D2/1.6449340668482D0/
      DATA EPS/1D-4/
*
* WITHOUT FACTOR ALPI/4/PI
*
      QTM =2D0/3D0
      CW2 =AMW2/AMZ2
      SW2 =1D0-CW2
      VT2 =(1D0-4*QTM*SW2)**2
      ALTW=-AMT2/AMW2
      ALTZ=-AMT2/AMZ2
      PVFBW=ALTW*DREAL(XPVF0(ALTW))
      PVFBZ=ALTZ*DREAL(XPVF0(ALTZ))
      PVFTW=ALTW*DREAL(XPVF (ALTW))
      PVFTZ=ALTZ*DREAL(XPVF (ALTZ))
      PAFTZ=ALTZ*DREAL(XPAF (ALTZ))
      PWFTW=ALTW*DREAL(XPWF (ALTW))
      PWF0  =-3D0*D2-105D0/8D0
*
      RXQCDT=ALST/3D0/PI/SW2*(4D0*SW2*QTM**2*(PVFTZ-PVFBZ)
     &      -1D0/4D0/SW2*(VT2*(PVFTZ-PVFBZ)+PAFTZ-PVFBZ)
     &      +(CW2-SW2)/SW2*(PWFTW-PVFBW)-AMT2/AMW2*PWF0)
      RXQCDB=ALST/PI/SW2**2*(CW2-SW2)*LOG(AMZ2/AMW2)
      RXQCD =RXQCDT+RXQCDB
*
      END
 
      FUNCTION ALQCDS(ALST,AMZ2,AMW2,AMT2)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      DATA PI/3.1415926535898D0/
*
* WITHOUT FACTOR ALPI/4/PI
*
      QTM =2D0/3D0
      CW2 =AMW2/AMZ2
      SW2 =1D0-CW2
      ALTZ=-AMT2/AMZ2
      PVFTZ=ALTZ*DREAL(XPVFI(ALTZ))
      ALQCDS=-ALST/3D0/PI/SW2*(4D0*SW2*QTM**2*(PVFTZ-45D0/4D0))
*
      END
 
      FUNCTION ALQCD(ALST,AMZ2,AMW2,AMT2)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      DATA PI/3.1415926535898D0/
*
* WITHOUT FACTOR ALPI/4/PI
*
      QTM =2D0/3D0
      CW2 =AMW2/AMZ2
      SW2 =1D0-CW2
      ALTZ=-AMT2/AMZ2
      PVFTZ=ALTZ*DREAL(XPVF(ALTZ))
      ALQCD=-ALST/3D0/PI/SW2*(4D0*SW2*QTM**2*(PVFTZ-45D0/4D0))
*
      END
 
      FUNCTION XKQCDS(ALST,AMZ2,AMW2,AMT2,S)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      DATA PI/3.1415926535898D0/
*
* CALPI/4 IS OMITTED
*
      QTM=2D0/3D0
      QBM=1D0/3D0
      CW2=AMW2/AMZ2
      SW2=1D0-CW2
      VT =1D0-4D0*QTM*SW2
      VB =1D0-4D0*QBM*SW2
*
      ALTW=-AMT2/AMW2
      ALTZ=-AMT2/AMZ2
      ALTS=-AMT2/S
      XPVFBS=ALTS*XPVF0(ALTS)
      XPVFTS=ALTS*XPVFI(ALTS)
      XPVFBZ=ALTZ*XPVF0(ALTZ)
      XPVFTZ=ALTZ*XPVFI(ALTZ)
      XPAFTZ=ALTZ*XPAFI(ALTZ)
      XPWFW =ALTW*XPWF (ALTW)
*
      XKQCDS=ALST/(3D0*PI*SW2)*(1D0/4D0/SW2*((VB**2+1D0)*XPVFBZ
     *      +VT**2*XPVFTZ+XPAFTZ)-CW2/SW2*XPWFW+VB*QBM*XPVFBS
     *      +VT*QTM*XPVFTS)
*
      END
 
      FUNCTION XKAQCD(ALST,AMZ2,AMW2,AMT2,S)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      DATA PI/3.1415926535898D0/
*
* CALPI/4 IS OMITTED
*
      QTM=2D0/3D0
      QBM=1D0/3D0
      CW2=AMW2/AMZ2
      SW2=1D0-CW2
      VT =1D0-4D0*QTM*SW2
      VB =1D0-4D0*QBM*SW2
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
*
      XKAQCD=ALST/(3D0*PI*SW2)*(1D0/4D0/SW2*((VB**2+1D0)*XPVFBZ
     *      +VT**2*XPVFTZ+XPAFTZ)-CW2/SW2*XPWFW+VB*QBM*XPVFBS
     *      +VT*QTM*XPVFTS)
*
      END
*
      FUNCTION XRQCDS(ALSZ,ALST,AMZ2,AMW2,AMT2,S)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      DATA PI/3.1415926535898D0/
      DATA D2/1.6449340668482D0/
      DATA EPS/1D-3/
*
* CALPI/4 IS OMITTED
*
      QTM=2D0/3D0
      QBM=1D0/3D0
      CW2=AMW2/AMZ2
      SW2=1D0-CW2
      VT =1D0-4D0*QTM*SW2
      VB =1D0-4D0*QBM*SW2
      VT2=VT**2
      VB2=VB**2
*
      ALTZ=-AMT2/AMZ2
      ALTS=-AMT2/S
      SMZ2=S/AMZ2
      DMZ2=1.D0-SMZ2
      XPVFTS=XPVFI(ALTS)
      XPVFTZ=XPVFI(ALTZ)
      XPAFTS=XPAFI(ALTS)
      XPAFTZ=XPAFI(ALTZ)
*
      IF(ABS(DMZ2).LT.EPS) THEN
        XDVFTZ=XDPVFI(ALTZ)
        XDAFTZ=XDPAFI(ALTZ)                                                   
        XRQCDS=ALSZ/(3D0*PI*SW2)*(3D0/2D0/CW2*(2D0+VT2+VB2))
     *                   +ALST/(3D0*PI*SW2)*(3D0/4D0/CW2*(1D0+VB2)
     *                   +AMT2/4D0/AMW2*(VT2*(XDVFTZ/ALTZ-XPVFTZ)
     *                   +XDAFTZ/ALTZ-XPAFTZ)
     *                   -AMT2/AMW2*(3D0*D2+105D0/8D0))
      ELSE
        XRQCDS=
     *    +ALSZ/(3D0*PI*SW2)*(-S*3D0/2D0/AMW2*(VT2+VB2+2D0)*RFL(SMZ2))      
     *    +ALST/(3D0*PI*SW2)*(-S*3D0/4D0/AMW2*(VB2+1D0)*RFL(SMZ2)
     *                   +AMT2/4D0/AMW2*(1D0/DMZ2*(VT2*(XPVFTZ-XPVFTS)
     *                   +XPAFTZ-XPAFTS)-(VT2*XPVFTZ+XPAFTZ))
     *                   -AMT2/AMW2*(3D0*D2+105D0/8D0))
      ENDIF
*
      END
 
      FUNCTION XROQCD(ALSZ,ALST,AMZ2,AMW2,AMT2,S)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      DATA PI/3.1415926535898D0/
      DATA D2/1.6449340668482D0/
      DATA EPS/1D-3/
*
* CALPI/4 IS OMITTED
*
      QTM=2D0/3D0
      QBM=1D0/3D0
      CW2=AMW2/AMZ2
      SW2=1D0-CW2
      VT =1D0-4D0*QTM*SW2
      VB =1D0-4D0*QBM*SW2
      VT2=VT**2
      VB2=VB**2
*
      ALTZ=-AMT2/AMZ2
      ALTS=-AMT2/S
      SMZ2=S/AMZ2
      DMZ2=1.D0-SMZ2
      XPVFTS=XPVF(ALTS)
      XPVFTZ=XPVF(ALTZ)
      XPAFTS=XPAF(ALTS)
      XPAFTZ=XPAF(ALTZ)
*
      IF(ABS(DMZ2).LT.EPS) THEN
        XDVFTZ=XDPVF(ALTZ)
        XDAFTZ=XDPAF(ALTZ)
        XROQCD=ALSZ/(3D0*PI*SW2)*(3D0/2D0/CW2*(VT2+VB2+2D0))
     *        +ALST/(3D0*PI*SW2)*(3D0/4D0/CW2*(VB2+1D0)
     *                   +AMT2/4D0/AMW2*(VT2*(XDVFTZ/ALTZ-XPVFTZ)
     *                   +XDAFTZ/ALTZ-XPAFTZ)
     *                   -AMT2/AMW2*(3D0*D2+105D0/8D0))
      ELSE
        XROQCD=
     *    +ALSZ/(3D0*PI*SW2)*(-S*3D0/2D0/AMW2*(VT2+VB2+2D0)*RFL(SMZ2))
     *    +ALST/(3D0*PI*SW2)*(-S*3D0/4D0/AMW2*(VB2+1D0)*RFL(SMZ2)
     *                   +AMT2/4D0/AMW2*(1D0/DMZ2*(VT2*(XPVFTZ-XPVFTS)
     *                   +XPAFTZ-XPAFTS)-(VT2*XPVFTZ+XPAFTZ))
     *                   -AMT2/AMW2*(3D0*D2+105D0/8D0))
      ENDIF
*
      END
*
* Library of polarization operators and their auxiliary functions 
*
      FUNCTION XPVF0(AL)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      DATA D3/1.2020569031596D0/
*
      XPVF0=(55.D0/4.D0-12.D0*D3+3.D0*DCMPLX(LOG(ABS(AL)),0.D0))/AL
*
      END
 
      FUNCTION PVF0G(AL)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      DATA D3/1.2020569031596D0/
*
      PVF0G=(55D0/4D0-12D0*D3)/AL
*
      END
 
      FUNCTION XPVFI(AL)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      RPVFI=45.D0/4.D0/AL-82.D0/27.D0/AL**2+449.D0/900.D0/AL**3
     *     -62479.D0/661500.D0/AL**4
      XPVFI=DCMPLX(RPVFI,.0D0)
*
      END
 
      FUNCTION XPVF(AL)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*  
      DATA EPS/2.D-3/
      DATA D3/1.2020569031596D0/
*
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
*   
      END
 
      FUNCTION XDPVFI(AL)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      RDPVFI=45.D0/4.D0-164.D0/27.D0/AL+449.D0/300.D0/AL**2
     *      -62479.D0/165375.D0/AL**3+9.55063D-2/AL**4
      XDPVFI=DCMPLX(RDPVFI,.0D0)
*
      END
 
      FUNCTION XDPVF(AL)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      DATA D3/1.2020569031596D0/
      DATA EPS/2.D-3/
*
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
*  
      END
 
      FUNCTION XPAFI(AL)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      RPAFI=-93.D0/2.D0+67.D0/12.D0/AL-689.D0/540.D0/AL**2
     *     +1691.D0/12600.D0/AL**3-1.8599D-2/AL**4
      XPAFI=DCMPLX(RPAFI,.0D0)
*
      END
 
      FUNCTION XPAF(AL)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      DATA D3/1.2020569031596D0/
      DATA EPS/2.D-3/
*
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
*
      END
 
      FUNCTION XDPAFI(AL)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      RDPAFI=67.D0/12.D0-689.D0/270.D0/AL+1691.D0/4200.D0/AL**2
     *      -7.43961D-2/AL**3+275205680132.D0/18606865047887.D0/AL**4
      XDPAFI=DCMPLX(RDPAFI,.0D0)
*
      END
 
      FUNCTION XDPAF(AL)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      DATA D3/1.2020569031596D0/
      DATA EPS/2.D-3/
*
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
*
      END
 
      FUNCTION XPWFI(AL)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      DATA D2/1.6449340668482D0/
      DATA D3/1.2020569031596D0/
*
      F1=6.D0*D3
      G1=2.D0*D2
      RPWFI=-105.D0/8.D0-3.D0/2.D0*G1+(115.D0/12.D0-2.D0/3.D0*G1)/AL
     *     +(-25.D0/16.D0-3.D0/4.D0)/AL**2
      XPWFI=DCMPLX(RPWFI,.0D0)
*
      END
 
      FUNCTION XPWF(AL)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      DATA D2/1.6449340668482D0/
      DATA D3/1.2020569031596D0/
      DATA EPS/2.D-3/
*
      F1=6.D0*D3
      G1=2.D0*D2
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
10    XPWF=DCMPLX(-161.D0/8.D0-4.D0*G1,.0D0)
 99   CONTINUE
*
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
*
      END
 
      FUNCTION RFL(X)
*
      IMPLICIT REAL*8(A-H,O-X)
*
      DATA EPS/1.D-3/
*
      X1=1.D0-X
      AB=ABS(X1)
      IF(AB.LT.EPS) GO TO 1
      RFL=LOG(X)/X1
      RETURN
1     RFL=-(1.D0+X1/2.D0+X1**2/3.D0+X1**3/4.D0+X1**4/5.D0)
*
      END
 
      FUNCTION XGS1(X)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      DATA D2/1.6449340668482D0/
*
      X1=X-1.D0
      G1=2.D0*D2
      XGS1=G1+X1-1.D0/2.D0*X1**2+11.D0/36.D0*X1**3
     *    -5.D0/24.D0*X1**4+137.D0/900.D0*X1**5-7.D0/60.D0*X1**6
*
      END
 
      FUNCTION XGIN(X)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      EXTERNAL RGIN,AGIN
*
      COMMON/CDZTMP/CDZT(5),ICDZ
      EQUIVALENCE (CDZT(1),XC)
*
      DATA EPS/1D-4/
      DATA EPSL/1D-14/
*
      XC=X
      CALL SIMPU(EPSL,1D0,.25D0,EPS,1D-30,RGIN,AR,RG,R2,R3)
      CALL SIMPU(EPSL,1D0,.25D0,EPS,1D-30,AGIN,AR,AG,R2,R3)
      XGIN=X*DCMPLX(RG,AG)
*
      END
 
      FUNCTION RGIN(T)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      COMMON/CDZTMP/CDZT(5),ICDZ
      EQUIVALENCE (CDZT(1),XC)
*
      DATA EPS/1.D-3/
*
      X=XC
      X1=1.D0-T*X
      AB=CDABS(X1)
      IF(AB.LT.EPS) GO TO 1
      RGIN=DREAL((LOG(T*X)/X1)**2)
      RETURN
1     RGIN=DREAL((1.D0+X1/2.D0+X1**2/3.D0+X1**3/4.D0+X1**4/5.D0)**2)
*
      END
 
      FUNCTION AGIN(T)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      COMMON/CDZTMP/CDZT(5),ICDZ
      EQUIVALENCE (CDZT(1),XC)
*
      DATA EPS/1.D-3/
*
      X=XC
      X1=1.D0-T*X
      AB=CDABS(X1)
      IF(AB.LT.EPS) GO TO 1
      AGIN=DIMAG((LOG(T*X)/X1)**2)
      RETURN
1     AGIN=DIMAG((1.D0+X1/2.D0+X1**2/3.D0+X1**3/4.D0+X1**4/5.D0)**2)
*
      END
 
      FUNCTION XFS1(X)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      DATA D2/1.6449340668482D0/
      DATA D3/1.2020569031596D0/
*
      F1=6.D0*D3
      G1=2.D0*D2
      X1=X-1.D0
      XFS1=F1+G1*X1+(1.D0-G1)/2.D0*X1**2+(2.D0*G1-3.D0)/6.D0*X1**3
     *    +(65.D0-36.D0*G1)/144.D0*X1**4+(G1/5.D0-29.D0/72.D0)*X1**5
     *    +(3899.D0/1800.D0/6.D0-G1/6.D0)*X1**6
*
      END
 
      FUNCTION XFIN(X)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      EXTERNAL RFIN,AFIN
*
      COMMON/CDZTMP/CDZT(5),ICDZ
      EQUIVALENCE (CDZT(1),XC)
*
      DATA EPS/1D-4/
      DATA EPSL/1D-14/
*
      XC=X
      CALL SIMPU(EPSL,1D0,.25D0,EPS,1D-30,RFIN,AR,RF,R2,R3)
      CALL SIMPU(EPSL,1D0,.25D0,EPS,1D-30,AFIN,AR,AF,R2,R3)
      XFIN=X*DCMPLX(RF,AF)
*
      END
 
      FUNCTION RFIN(T)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      COMMON/CDZTMP/CDZT(5),ICDZ
      EQUIVALENCE (CDZT(1),XC)
*
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
*
      END
 
      FUNCTION AFIN(T)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
*
      COMMON/CDZTMP/CDZT(5),ICDZ
      EQUIVALENCE (CDZT(1),XC)
*
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
*
      END
*
* New mixed QCD-corrections based on B.Kniehl QCD-library
*
 
      FUNCTION AQCDBK(ALST,AMZ2,AMW2,AMT2)
*
      IMPLICIT REAL*8(A-H,O-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMPLEX*16 CV1
*
      DATA PI/3.1415926535898D0/
      DATA D3/1.2020569031596D0/
*
* WITHOUT FACTOR ALPI/4/PI
*
      QTM =2D0/3D0
*
      XCR   =DCMPLX(AMZ2/(4D0*AMT2))
      AQCDBK=-ALST/PI*4D0*QTM**2
     &      *(DREAL(CV1(XCR)/XCR)-(4D0*D3-5D0/6D0))
*
      END

      FUNCTION DRMQCD(AMZ2,AMW2,AMT2)
*
      IMPLICIT REAL*8(A-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMPLEX*16 CV1,CA1,CF1
*
      DATA D2/1.6449340668482D0/
      DATA D3/1.2020569031596D0/
*
      CW2 =AMW2/AMZ2
      SW2 =1D0-CW2
      QTM=2D0/3D0
      QBM=1D0/3D0
      XCR  =DCMPLX(AMZ2/(4D0*AMT2))
      XCX  =DCMPLX(AMW2/AMT2)
      XZERO=DCMPLX(0D0)
*
      V1P=4D0*D3-5D0/6D0
*
      DRMQCD=QTM**2*V1P 
     &      +CW2/SW2**2*AMT2/AMw2/4*(D2+1D0/2D0)
     &-1D0/4/SW2**2*AMT2/AMZ2*((1D0-4D0*QTM*SW2)**2*DREAL(CV1(XCR))
     &                            +DREAL(CA1(XCR))-DREAL(CA1(XZERO)))
     &+(CW2-SW2)/SW2**2*AMT2/AMW2*(DREAL(CF1(XCX))-DREAL(CF1(XZERO)))
     &      -1D0/8*(1D0-4D0*QBM*SW2)/SW2**2*LOG(AMT2/AMZ2)
*
      END
*
      FUNCTION XKMQCD(AMZ2,AMW2,AMT2,S)
*
      IMPLICIT REAL*8(A-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMPLEX*16 CV1,CA1,CF1
*
      CW2 =AMW2/AMZ2
      SW2 =1D0-CW2
*
      QTM=2D0/3D0
      QBM=1D0/3D0
      XCR=DCMPLX(AMZ2/(4D0*AMT2))
      XCS=DCMPLX( S  /(4D0*AMT2))
      XCX=DCMPLX(AMW2/AMT2)
*
      XKMQCD=CW2/SW2**2/4D0*AMT2/AMW2
     &      *((1D0-4D0*QTM*SW2)**2*CV1(XCR)+CA1(XCR))
     &      -CW2/SW2**2*AMT2/AMW2*CF1(XCX)
     &      +1D0/SW2*(1D0-4D0*QTM*SW2)*QTM*AMT2/S*CV1(XCS)
     &      -1D0/16D0/SW2**2*(2D0*(1D0-2D0*QBM*SW2)*LOG(AMZ2/AMT2)
     &      +4D0*(1D0-4D0*QBM*SW2)*QBM*SW2*LOG(S/AMZ2))
*
      END

      FUNCTION XRMQCD(AMZ2,AMW2,AMT2,S)
*
      IMPLICIT REAL*8(A-W,Y-Z)
      IMPLICIT COMPLEX*16(X)
      COMPLEX*16 CV1,CA1
*
      DATA D2/1.6449340668482D0/
      DATA D3/1.2020569031596D0/
      DATA EPS/1D-3/
*
      CW2 =AMW2/AMZ2
      SW2 =1D0-CW2
*
      QTM=2D0/3D0
      QBM=1D0/3D0
      XCR=DCMPLX(AMZ2/(4D0*AMT2))
      XCS=DCMPLX( S  /(4D0*AMT2))
*
      XV1r =CV1(XCR)
      XA1r =CA1(XCR)
      XV1rs=CV1(XCS)
      XA1rs=CA1(XCS)
*
      SMZ2=S/AMZ2
      DMZ2=1.D0-SMZ2
*
      IF(ABS(DMZ2).LT.EPS) THEN
        VT =1D0-4D0*QTM*SW2
        VB =1D0-4D0*QBM*SW2
        VT2=VT**2
        VB2=VB**2
*
        ALTZ=-AMT2/AMZ2
        ALTS=-AMT2/S
        XPVFTS=XPVFI(ALTS)
        XPVFTZ=XPVFI(ALTZ)
        XPAFTS=XPAFI(ALTS)
        XPAFTZ=XPAFI(ALTZ)
*
        XDVFTZ=XDPVFI(ALTZ)
        XDAFTZ=XDPAFI(ALTZ)                                                   
        XRMQCD=1D0/(12D0*SW2)
     &        *(3D0/4D0/CW2*(1D0+VB2)
     &        +AMT2/4D0/AMW2*(VT2*(XDVFTZ/ALTZ-XPVFTZ)
     &        +XDAFTZ/ALTZ-XPAFTZ)
     &        -AMT2/AMW2*(3D0*D2+105D0/8D0))
      ELSE
        XRMQCD=1D0/4D0/SW2/CW2
     &        *(AMT2/AMZ2*((1D0-4D0*QTM*SW2)**2*XV1r+XA1r)
     &        +AMT2/(AMZ2-S)*((1-4*QTM*SW2)**2*(XV1rs-XV1r)+XA1rs-XA1r)
     &        +2D0*AMT2/AMZ2*(-23D0/8D0+D2+3D0*D3)
     &    -1D0/4D0*(1D0+(1D0-4D0*QBM*SW2)**2)*S/(AMZ2-S)*LOG(S/AMZ2))      
      ENDIF
*
      END
*
* B.Kniehl QCD-library
*
      FUNCTION CV1(CR)
C     ****************
C V_1(r) defined by Eq. (10) in
C B.A. Kniehl, Nucl. Phys. B347 (1990) 86.
C r = (s + i*epsilon)/(4*m^2), where s may be complex.
C
      IMPLICIT LOGICAL (A-Z)
      COMPLEX*16 CR,CV1
      REAL*8 PI
      COMPLEX*16 C1,C2,CD,CF,CFS,CG,CH,CLI2,CLI3,CM,CMQ,CMS,CONE,CP,CRT,
     .           CS,CZERO,CZETA2,CZETA3
      DATA CZERO,CONE/(0.D0,0.D0),(1.D0,0.D0)/
      PI=4.D0*DATAN(1.D0)
      CZETA2=DCMPLX(PI**2/6.D0)
      CZETA3=CLI3(CONE,CONE)
      IF (CR.EQ.CZERO) THEN
          CV1=CZERO
      ELSE IF (CR.EQ.CONE) THEN
          CV1=DCMPLX(0.D0,PI**3)
          WRITE (6,*)
     .        'Warning: Coulomb singularity of V_1(r) at r = 1 !'
      ELSE
          C1=CRT(CONE-CR,-CONE)
          C2=CRT(-CR,-CONE)
          CS=C1/C2
          CP=C1+C2
          CM=C1-C2
          CMS=CM**2
          CMQ=CMS**2
          CF=CDLOG(CP)
          CFS=CF**2
          CG=CDLOG(CP-CM)
          CH=CDLOG(CP+CM)
          CD=CLI2(CMS,CONE)-CLI2(CMQ,CONE)
          CV1=4.D0*(CR-1.D0/(4.D0*CR))*(2.D0*CLI3(CMS,CONE)
     .        -CLI3(CMQ,CONE)+8.D0/3.D0*CF*CD
     .        +4.D0*CFS*(-CF+CG/3.D0+2.D0/3.D0*CH))
     .        +CS*(8.D0/3.D0*(CR+1.D0/2.D0)*(CD
     .        +CF*(-3.D0*CF+2.D0*CG+4.D0*CH))-2.D0*(CR+3.D0/2.D0)*CF)
     .        -8.D0*(CR-1.D0/6.D0-7.D0/(48.D0*CR))*CFS+13.D0/6.D0
     .        +CZETA3/CR
          END IF
      RETURN
C***********************************************************************
      END

      FUNCTION CA1(CR)
C     ****************
C A_1(r) defined by Eq. (11) in
C B.A. Kniehl, Nucl. Phys. B347 (1990) 86.
C r = (s + i*epsilon)/(4*m^2), where s may be complex.
C
      IMPLICIT LOGICAL (A-Z)
      COMPLEX*16 CR,CA1
      REAL*8 PI
      COMPLEX*16 C1,C2,CD,CF,CFS,CG,CH,CLI2,CLI3,CM,CMQ,CMS,CONE,CP,CRT,
     .           CS,CZERO,CZETA2,CZETA3
      DATA CZERO,CONE/(0.D0,0.D0),(1.D0,0.D0)/
      PI=4.D0*DATAN(1.D0)
      CZETA2=DCMPLX(PI**2/6.D0)
      CZETA3=CLI3(CONE,CONE)
      IF (CR.EQ.CZERO) THEN
          CA1=3.D0*(-2.D0*CZETA3-CZETA2+7.D0/4.D0)
      ELSE IF (CR.EQ.CONE) THEN
          CA1=-2.D0*CZETA3-3.D0/8.D0*CZETA2+29.D0/12.D0
      ELSE
          C1=CRT(CONE-CR,-CONE)
          C2=CRT(-CR,-CONE)
          CS=C1/C2
          CP=C1+C2
          CM=C1-C2
          CMS=CM**2
          CMQ=CMS**2
          CF=CDLOG(CP)
          CFS=CF**2
          CG=CDLOG(CP-CM)
          CH=CDLOG(CP+CM)
          CD=CLI2(CMS,CONE)-CLI2(CMQ,CONE)
          CA1=4.D0*(CR-3.D0/2.D0+1.D0/(2.D0*CR))*(2.D0*CLI3(CMS,CONE)
     .        -CLI3(CMQ,CONE)+8.D0/3.D0*CF*CD
     .        +4.D0*CFS*(-CF+CG/3.D0+2.D0/3.D0*CH))
     .        +CS*(8.D0/3.D0*(CR-1.D0)*(CD
     .        +CF*(-3.D0*CF+2.D0*CG+4.D0*CH))
     .        -2.D0*(CR-3.D0+1.D0/(4.D0*CR))*CF)
     .        -8.D0*(CR-11.D0/12.D0+5.D0/(48.D0*CR)
     .        +1.D0/(32.D0*CR**2))*CFS
     .        -3.D0*CZETA2+13.D0/6.D0+(-2.D0*CZETA3+1.D0/4.D0)/CR
          END IF
      RETURN
C***********************************************************************
      END

      FUNCTION CF1(CX)
C     ****************
C F_1(x) defined by Eq. (12) in
C B.A. Kniehl, Nucl. Phys. B347 (1990) 86.
C x = (s + i*epsilon)/m^2, where s may be complex.
C
      IMPLICIT LOGICAL (A-Z)
      COMPLEX*16 CX,CF1
      REAL*8 PI
      COMPLEX*16 CA,CB,CBS,CD,CLI2,CLI3,CLN,CXS,CONE,CZERO,CZETA2,CZETA3
      DATA CZERO,CONE/(0.D0,0.D0),(1.D0,0.D0)/
      PI=4.D0*DATAN(1.D0)
      CZETA2=DCMPLX(PI**2/6.D0)
      CZETA3=CLI3(CONE,CONE)
      IF (CX.EQ.CZERO) THEN
          CF1=-3.D0/2.D0*CZETA3-CZETA2/2.D0+23.D0/16.D0
      ELSE IF (CX.EQ.CONE) THEN
          CF1=-CZETA3/2.D0-CZETA2/12.D0+7.D0/8.D0
      ELSE
          CXS=CX**2
          CA=CLN(-CX,-CONE)
          CB=CLN(CONE-CX,-CONE)
          CBS=CB**2
          CD=CLI2(CONE/(CONE-CX),CONE)
          CF1=(CX-3.D0/2.D0+1.D0/(2.D0*CXS))*(CLI3(CONE/(CONE-CX),CONE)
     .        +2.D0/3.D0*CB*CD-CBS/6.D0*(CA-CB))
     .        +(CX+1.D0/2.D0-1.D0/(2.D0*CX))/3.D0*(CD-CA*CB)
     .        +(CX-1.D0/8.D0-1.D0/CX+5.D0/(8.D0*CXS))/3.D0*CBS
     .        -(CX-5.D0/2.D0+2.D0/(3.D0*CX)+5.D0/(6.D0*CXS))/4.D0*CB
     .        -3.D0/4.D0*CZETA2+13.D0/12.D0-5.D0/(24.D0*CX)
     .        -CZETA3/(2.D0*CXS)
          END IF
      RETURN
C***********************************************************************
      END

      FUNCTION CLI2(CY,CE)
C     ********************
C Li_2(y + i*epsilon*sign(Re(e)))
C
      IMPLICIT LOGICAL (A-Z)
      COMPLEX*16 CY,CE,CLI2
      INTEGER I,IFLAG1,IFLAG2,N
      REAL*8 B(0:60),EPS,PI
      COMPLEX*16 CH,CLN,COLD,CONE,CX,CZ,CZERO,CZETA2
      DATA CZERO,CONE/(0.D0,0.D0),(1.D0,0.D0)/
C N = # of terms to be evaluated in the expansion, N <= 61.
      N=30
C Relative precision.
      EPS=1.D-20
      PI=4.D0*DATAN(1.D0)
      CZETA2=DCMPLX(PI**2/6.D0)
      DO 1 I=3,59,2
1         B(I)=0.D0
      B(0)=1.D0
      B(1)=-.5D0
      B(2)=1.D0/6.D0
      B(4)=-1.D0/30.D0
      B(6)=1.D0/42.D0
      B(8)=B(4)
      B(10)=5.D0/66.D0
      B(12)=-691.D0/2730.D0
      B(14)=7.D0/6.D0
      B(16)=-3617.D0/510.D0
      B(18)=43867.D0/798.D0
      B(20)=-174611.D0/330.D0
      B(22)=854513.D0/138.D0
      B(24)=-236364091.D0/2730.D0
      B(26)=8553103.D0/6.D0
      B(28)=-23749461029.D0/870.D0
      B(30)=8615841276005.D0/14322.D0
      B(32)=-7709321041217.D0/510.D0
      B(34)=2577687858367.D0/6.D0
      B(36)=-26315271553053477373.D0/1919190.D0
      B(38)=2929993913841559.D0/6.D0
      B(40)=-261082718496449122051.D0/13530.D0
      B(42)=1520097643918070802691.D0/1806.D0
      B(44)=-27833269579301024235023.D0/690.D0
      B(46)=596451111593912163277961.D0/282.D0
      B(48)=-5609403368997817686249127547.D0/46410.D0
      B(50)=495057205241079648212477525.D0/66.D0
      B(52)=-801165718135489957347924991853.D0/1590.D0
      B(54)=29149963634884862421418123812691.D0/798.D0
      B(56)=-2479392929313226753685415739663229.D0/870.D0
      B(58)=84483613348880041862046775994036021.D0/354.D0
C      B(60)=-1215233140483755572040304994079820246041491.D0/56786730.D0
      CX=CY
      IF (CX.EQ.CZERO) THEN
          CLI2=CZERO
      ELSE IF (CX.EQ.CONE) THEN
          CLI2=CZETA2
      ELSE
          IFLAG1=0
          IFLAG2=0
          IF (CDABS(CX).GT.1.D0) THEN
              CX=CONE/CX
              IFLAG1=1
              END IF
          IF (DREAL(CX).GT..5D0) THEN
              CX=CONE-CX
              IFLAG2=1
              END IF
          CZ=-CDLOG(CONE-CX)
          CH=CONE
          CLI2=CZERO
          DO 2 I=1,N
              COLD=CLI2
              CH=CH*CZ/DCMPLX(DFLOAT(I))
              CLI2=CLI2+DCMPLX(B(I-1))*CH
2             IF (B(I-1).NE.0.D0.AND.CDABS(COLD/CLI2-CONE).LT.EPS)
     .            GOTO 3
3         IF (IFLAG2.EQ.1) THEN
              CLI2=-CLI2+CZETA2-CDLOG(CX)*CDLOG(CONE-CX)
              END IF
          IF (IFLAG1.EQ.1) THEN
              CLI2=-CLI2-CZETA2-DCMPLX(.5D0)*CLN(-CY,-CE)**2
              END IF
          END IF
      RETURN
C***********************************************************************
      END

      FUNCTION CLI3(CY,CE)
C     ********************
C Li_3(y + i*epsilon*sign(Re(e)))
C
      IMPLICIT LOGICAL (A-Z)
      COMPLEX*16 CY,CE,CLI3
      INTEGER IFLAG
      REAL*8 PI
      COMPLEX*16 CH,CLI3H,CLN,CONE,CX,CZERO,CZETA2,CZETA3
      DATA CZERO,CONE/(0.D0,0.D0),(1.D0,0.D0)/
      PI=4.D0*DATAN(1.D0)
      CZETA2=DCMPLX(PI**2/6.D0)
      CZETA3=DCMPLX(1.20205690315959D0)
      CX=CY
      IF (CX.EQ.CZERO) THEN
          CLI3=CZERO
      ELSE IF (CX.EQ.CONE) THEN
          CLI3=CZETA3
      ELSE
          IFLAG=0
          IF (CDABS(CX).GT.1.D0) THEN
              CX=CONE/CX
              IFLAG=1
              END IF
          IF (DREAL(CX).GT..5D0) THEN
              CH=CDLOG(CX)
              CLI3=-CLI3H(CONE-CONE/CX)-CLI3H(CONE-CX)+CZETA3+CZETA2*CH
     .             +CH**3/DCMPLX(6.D0)-DCMPLX(.5D0)*CH**2*CDLOG(CONE-CX)
          ELSE
              CLI3=CLI3H(CX)
              END IF
          IF (IFLAG.EQ.1) THEN
              CH=CLN(-CY,-CE)
              CLI3=CLI3-CZETA2*CH-CH**3/DCMPLX(6.D0)
              END IF
          END IF
      RETURN
C***********************************************************************
      END

      FUNCTION CLI3H(CX)
C     ******************
C Li_3(x) for 0 < |x| <= 1, Re(x) <= 1/2.
C
      IMPLICIT LOGICAL (A-Z)
      COMPLEX*16 CX,CLI3H
      INTEGER I,J,N
C N = # of terms to be evaluated in the expansion, N <= 61.
      PARAMETER (N=30)
      REAL*8 B(0:60),EPS,F(0:N)
      COMPLEX*16 CC,COLD,CONE,CP,CZ,CZERO
      DATA CZERO,CONE/(0.D0,0.D0),(1.D0,0.D0)/
C Relative precision.
      EPS=1.D-20
      DO 1 I=3,59,2
1         B(I)=0.D0
      B(0)=1.D0
      B(1)=-.5D0
      B(2)=1.D0/6.D0
      B(4)=-1.D0/30.D0
      B(6)=1.D0/42.D0
      B(8)=B(4)
      B(10)=5.D0/66.D0
      B(12)=-691.D0/2730.D0
      B(14)=7.D0/6.D0
      B(16)=-3617.D0/510.D0
      B(18)=43867.D0/798.D0
      B(20)=-174611.D0/330.D0
      B(22)=854513.D0/138.D0
      B(24)=-236364091.D0/2730.D0
      B(26)=8553103.D0/6.D0
      B(28)=-23749461029.D0/870.D0
      B(30)=8615841276005.D0/14322.D0
      B(32)=-7709321041217.D0/510.D0
      B(34)=2577687858367.D0/6.D0
      B(36)=-26315271553053477373.D0/1919190.D0
      B(38)=2929993913841559.D0/6.D0
      B(40)=-261082718496449122051.D0/13530.D0
      B(42)=1520097643918070802691.D0/1806.D0
      B(44)=-27833269579301024235023.D0/690.D0
      B(46)=596451111593912163277961.D0/282.D0
      B(48)=-5609403368997817686249127547.D0/46410.D0
      B(50)=495057205241079648212477525.D0/66.D0
      B(52)=-801165718135489957347924991853.D0/1590.D0
      B(54)=29149963634884862421418123812691.D0/798.D0
      B(56)=-2479392929313226753685415739663229.D0/870.D0
      B(58)=84483613348880041862046775994036021.D0/354.D0
C      B(60)=-1215233140483755572040304994079820246041491.D0/56786730.D0
      F(0)=1.D0
      DO 2 I=1,N
2         F(I)=F(I-1)*DFLOAT(I)
      CZ=-CDLOG(CONE-CX)
      CP=CONE
      CLI3H=CZERO
      DO 3 I=1,N
          COLD=CLI3H
          CP=CP*CZ
          CC=CZERO
          DO 4 J=1,I
4             CC=CC+DCMPLX(B(J-1)*B(I-J)/(F(J)*F(I-J)))
          CLI3H=CLI3H+CP*CC/DCMPLX(DFLOAT(I))
3     IF (CDABS(COLD/CLI3H-CONE).LT.EPS) GOTO 5
5     RETURN
C***********************************************************************
      END
      FUNCTION CRT(CX,CE)
C     *******************
C sqrt(x + i*epsilon*sign(Re(e)))
C
      IMPLICIT LOGICAL (A-Z)
      COMPLEX*16 CX,CE,CRT
      IF (DREAL(CX).LT.0.D0.AND.DIMAG(CX).EQ.0.D0) THEN
          CRT=DSIGN(1.D0,DREAL(CE))*(0.D0,1.D0)*CDSQRT(-CX)
      ELSE
          CRT=CDSQRT(CX)
          END IF
      RETURN
C***********************************************************************
      END

      FUNCTION CLN(CX,CE)
C     *******************
C ln(x + i*epsilon*sign(Re(e)))
C
      IMPLICIT LOGICAL (A-Z)
      COMPLEX*16 CX,CE,CLN
      REAL*8 PI
      PI=4.D0*DATAN(1.D0)
      IF (DREAL(CX).LT.0.D0.AND.DIMAG(CX).EQ.0.D0) THEN
          CLN=CDLOG(-CX)+DSIGN(1.D0,DREAL(CE))*(0.D0,1.D0)*PI
      ELSE
          CLN=CDLOG(CX)
          END IF
      RETURN
C***********************************************************************
      END
      SUBROUTINE GDEGNL
     & (GMU,MZ,MT,AMH,MW,PI3QF,SMAN,DRDREM,DRHOD,DKDREM,DROREM)      
c
c       This file contains the 2 loop O(g^4 mt^2/mw^2) corrections 
c       to various ew parameters.
c       As a general rule the routines with names "something" contain
c       the various corrections in the MSbar framework. The routines
c       with names "somethingOS" contain the additional corrections 
c       coming from the expansion of the  OS sine in the one-loop result.
c       To get an OS result one should put together the routines
c       something + somethingOS with coupling constants in both routines
c       expressed in terms of OS quantities.
c       In OS framework in units
c       Nc*(alfa/(4.d0*pi*s2))**2.d0*(mt^2/(4.d0 mw^2))**2.d0
c       one has :
c
c       Delta r ^(2l) = 16.d0*drs2lew + 4.d0*zt*c2*drs2lewOS
c                      - 16.d0*deleoe2lew
c                      - c2/s2*(tobf2lew + 4.d0*zt*c2*tobf2lewOS)
c
c       sineff = ( 1+ delta ) s2
c       delta^(2l)    = k2lew -4.d0*c2*c2*zt*k2lewOS
c                       + c2/s2*(tobf2lew + 4.d0*zt*c2*tobf2lewOS)
c        mz = Z mass
c        mu = 't Hooft mass
c        mt = top mass
c        mh = Higgs mass
c        zt = (mz/mt)**2
c        ht = (mh/mt)**2
c        s2 = sin^2 theta_w
c        c2 = cos^2 theta_w
c        sman = s (Mandelstein variable)
c        ddilog = double precision dilogarithmic function
c        Cl2 = Clausen integral of second order
c
      IMPLICIT REAL*8(A-Z)
      COMMON/CDZCON/PI,PI2,F1,D3,ALFAI,AL4PI,AL2PI,AL1PI
c
c     common/datcom/ needed for Degrassi package
        double precision gmud,repiggh0,mz0,alfa0,alfastr,delQCD,
     1                pide,mel,mmu,mtau,mb,gamz,Nc,zeta3
c
        common/datcom/gmud,repiggh0,mz0,alfa0,alfastr,delQCD,
     1                pide,mel,mmu,mtau,mb,gamz,Nc,zeta3
c
      pide=pi
      zeta3=D3
c
c     color factor
      Nc = 3.d0
      alfa0=1d0/ALFAI
*
* protection by shifting of Higgs mass if it is = 2*mt or 2*mz
*
      MH=AMH
      if(ABS(AMH-2d0*MT).LT.5d-5) MH=2d0*MT-1d-4
      if(ABS(AMH-2d0*MZ).LT.5d-5) MH=2d0*MZ-1d-4
*
      c2=MW**2/mz**2
      s2=1d0-c2
      mu=mz
c      sman=mz**2
      zt = (mz/mt)**2
      ht = (mh/mt)**2
      xt = gmu/sqrt(2d0)*mt**2/8d0/pi**2
c
      call ew2ltwodel(zt,ht,deleoe2lew,s2,mz,mu)
c
      call ew2ldeltarw(zt,ht,drs2lew,s2,mz,mu)
      call ew2ldeltarwOS(zt,drs2lewOS,s2,mz,mu)
c
      call ew2ltobf(zt,ht,tobf2lew,s2,mz,mu)
      call ew2ltobfOS(zt,tobf2lewOS,s2,mz,mu)
c
      call kappacur2l(zt,ht,k2lew,c2,mz,mu)
      call kappacur2lOS(zt,k2lewOS,c2,mz,mu,sman,pi3qf)
c
      call ew2leta(zt,ht,eta2lew,c2,mz,mu)
      call ew2letaOS(zt,ht,eta2lewOS,s2,mz,mu,sman,pi3qf)
c
      DRHOD =Nc*xt**2*(tobf2lew+4.d0*zt*c2*tobf2lewOS)
      DKHOD =Nc*xt**2*(tobf2lew+4.d0*zt*c2*tobf2lewOS)
      DRDREM=
     &+Nc*(alfa0/(4.d0*pi*s2))**2*(mt**2/(4.d0*mw**2))**2
     &*(16.d0*drs2lew+4.d0*zt*c2*drs2lewOS-16.d0*deleoe2lew)
      DKDREM=Nc*xt**2*(k2lew-4.d0*c2*c2*zt*k2lewOS)
c
c Dear Dima, here are the routines that contain the O(g^4 mt^2/mw^2) 
c corrections to the factor eta relevant for the widths, but the b. 
c The notation is identical to that of the previuos routines. Notice that
c the you have already the routines containing the O(g^4 mt^2/mw^2)
c corrections to the overall prefactor. In particular the corrections to
c f^prime bar are contained in the subroutines ew2ldeltarw and
c ew2ldeltarwOS. All best Giuseppe
c 
      eta2l = 4.d0*eta2lew +eta2lewOS - 8.d0*c2*log(c2)
c   
*      DETAF =Nc*(alfa0/(4.d0*pi*s2))**2*(mt**2/(4.d0*mw**2))*eta2l
      DROREM=Nc*xt**2
     &      *(4.d0*zt*c2*eta2l-(16.d0*drs2lew+4.d0*zt*c2*drs2lewOS))
c       
      return
      end
c
c*********************** FUNCTIONS ****************************
c
c       function J1 in Bertolini-Sirlin

        double precision function j1(x,y)
        double precision x,y,d,ln,j
        d=4.d0*x*y-1.d0
        j=dlog(x)+1.d0/3.d0
        j=j+(3.d0+d)*(ln(d)-1.d0)
        j1=j/6.d0
        return
        end
c
c       function lambda present in J1 and J2
        double precision function ln(d)
        double precision d,d1
        if (d.lt.0.d0) go to 10
        ln=dsqrt(d)*datan(1.d0/dsqrt(d))
        go to 20
10      continue
        d1=dabs(d)
        d1=dsqrt(d1)
        ln=0.5d0*d1*dlog(dabs((1.d0+d1)/(1.d0-d1)))
20      continue
        return
        end
c
c-----------------------------------------------------------------
c	The below functions U and V are related to the functions
c	f(y) and g(y) in the Degrassi-Sirlin paper as follows:
c	V(x)=f(y)
c	U(x)+0.25 = -2*g(y)
c	where y=1/x
c----------------------------------------------------------------
c
c       function V present in the vertices (real part)
        double precision function revf(x)
        double precision  a1,a2,x,ddilog
c
        double precision gmu,repiggh0,mz0,alfa0,alfastr,delQCD,
     1                pi,mel,mmu,mtau,mb,gamz,Nc,zeta3
c
        common/datcom/gmu,repiggh0,mz0,alfa0,alfastr,delQCD,
     1                pi,mel,mmu,mtau,mb,gamz,Nc,zeta3
c
        a1=2.d0*(2.d0+x)-0.5d0+(3.d0+2.d0*x)*dlog(x)
        a2=dlog(1.d0+1.d0/x)*dlog(1.d0+1.d0/x)
     1  -(pi*pi)/3.d0
        a2=a2+2.d0*ddilog(x/(x+1.d0))
        a2=(1.d0+x)*(1.d0+x)*a2
        revf=a1+a2
        return
        end
c
c       Function U present in the vertices 
        double precision function ug(x)
        double precision a1,x,dat
*
* here the code fails for x < 1/4 or above 'a' threshold
* correction is proposed
* old:  
c       a1=dsqrt(4.d0*x-1.d0)
c       a2=(1.d0+2.d0*x)*a1*datan(1.d0/a1)
c       a2=-1.5d0+x-a2
c       a2=4.d0*x*(2.d0+x)*datan(1.d0/a1)*datan(1.d0/a1)+a2
c       ug=a2
* new:
        a1=4.d0*x-1.d0
        if(a1.le.0.d0) then
         dat=.5d0*dlog(dabs((1+dsqrt(dabs(a1)))
     1                     /(1-dsqrt(dabs(a1)))))
        elseif(a1.gt.0.d0) then
         dat=datan(1.d0/dsqrt(a1))
        endif
        ug=4.d0*x*(2.d0+x)*dat*dat-1.5d0+x
     1    -(1.d0+2.d0*x)*dsqrt(dabs(a1))*dat
        return
        end
c
c       function phi
        real*8 function phi(x)
        real*8 x,Cl2,ddilog
c
        double precision gmu,repiggh0,mz0,alfa0,alfastr,delQCD,
     1                pi,mel,mmu,mtau,mb,gamz,Nc,zeta3
c
        common/datcom/gmu,repiggh0,mz0,alfa0,alfastr,delQCD,
     1                pi,mel,mmu,mtau,mb,gamz,Nc,zeta3
c
        if(x.lt.1.d0) then
          phi =  4.d0*dsqrt(x/(1.d0-x))*Cl2(2.d0*dasin(dsqrt(x)))
        else
          phi= dsqrt(x/(x-1.d0))*
     1        (-4.d0*ddilog((1.d0-dsqrt(1.d0-1.d0/x))/2.d0) +
     2        2.d0*dlog((1.d0-dsqrt(1.d0-1.d0/x))/2.d0)**2.d0 -
     3        dlog(4.d0*x)**2.d0+pi*pi/3.d0)
        endif
        return
        end
c
c       function g(x) --> gdeg(x)
        real*8 function gdeg(x)
        real*8 x
c
        double precision gmu,repiggh0,mz0,alfa0,alfastr,delQCD,
     1                pi,mel,mmu,mtau,mb,gamz,Nc,zeta3
c
        common/datcom/gmu,repiggh0,mz0,alfa0,alfastr,delQCD,
     1                pi,mel,mmu,mtau,mb,gamz,Nc,zeta3
        if(x.gt.4.d0) then
        gdeg=2.d0*dsqrt(x/4.d0 -1.d0)*dlog((1.d0-dsqrt(1.d0-4.d0/x))/
     1        (1.d0 + dsqrt(1.d0 -4.d0/x)))
        else
        gdeg=dsqrt(4.d0-x)*(pi - 2.d0*dasin(dsqrt(x/4.d0))) 
        endif
        return
        end
c
c       function B0(q,m1,m2,mu2)); it is the - I_3 of DS once the pole
c       1/eps has been extracted. q is the momentum squared, m1 and m2
c       the mass squared and mu2 the squared of the `t Hooft mass
        real*8 function B0(q,m1,m2,mu2)
        real*8 q,m1,m2,Omega,mu2
        B0 = -( dlog(q/mu2)-2.d0 + 
     1         1.d0/2.d0*( 1.d0 + (m1/q-m2/q))*dlog(m1/q) +
     2         1.d0/2.d0*( 1.d0 - (m1/q-m2/q))*dlog(m2/q) +
     3         2.d0*Omega(m1/q,m2/q))
        return
        end

c       function Omega(a,b) contained in B0
        real*8 function Omega(a,b)
        real*8 a,b,cbig
        Cbig = (a+b)/2.d0 - (a-b)**2.d0/4.d0 -1.d0/4.d0
        if(Cbig.gt.0.d0) then
            Omega = dsqrt(Cbig)*
     1          (datan((1.d0 + a - b)/(2.d0*dsqrt(Cbig))) +
     2           datan((1.d0 - a + b)/(2.d0*dsqrt(Cbig))) )
        else
            Cbig = - Cbig
            Omega = 1.d0/2.d0*dsqrt(Cbig)*
     1              dlog((a/2.d0 +b/2.d0 -1.d0/2.d0 -dsqrt(Cbig))/
     2              (a/2.d0 + b/2.d0 -1.d0/2.d0 + dsqrt(Cbig)))
                  
        endif
        return
        end
c
      DOUBLE PRECISION FUNCTION CL2(THETA)
C     ************************************
C CALCULATES CLAUSEN'S INTEGRAL OF SECOND ORDER FOR REAL ARGUMENTS
C THETA.
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      PARAMETER (N=30,K=20,DM=1.D-15,PM=1.D-35,VM=1.D35)
      DIMENSION B(N)
      B(1)=.1D1/.6D1
      B(2)=.1D1/.30D2
      B(3)=.1D1/.42D2
      B(4)=.1D1/.30D2
      B(5)=.5D1/.66D2
      B(6)=.691D3/.2730D4
      B(7)=.7D1/.6D1
      B(8)=.3617D4/.510D3
      B(9)=.43867D5/.798D3
      B(10)=.174611D6/.330D3
      B(11)=.854513D6/.138D3
      B(12)=.236364091D9/.2730D4
      B(13)=.8553103D7/.6D1
      B(14)=.23749461029D11/.870D3
      B(15)=.8615841276005D13/.14322D5
      B(16)=.7709321041217D13/.510D3
      B(17)=.2577687858367D13/.6D1
      B(18)=.26315271553053477373D20/.1919190D7
      B(19)=.2929993913841559D16/.6D1
      B(20)=.261082718496449122051D21/.13530D5
      B(21)=.1520097643918070802691D22/.1806D4
      B(22)=.27833269579301024235023D23/.690D3
      B(23)=.596451111593912163277961D24/.282D3
      B(24)=.5609403368997817686249127547D28/.46410D5
      B(25)=.495057205241079648212477525D27/.66D2
      B(26)=.801165718135489957347924991853D30/.1590D4
      B(27)=.29149963634884862421418123812691D32/.798D3
      B(28)=.2479392929313226753685415739663229D34/.870D3
      B(29)=.84483613348880041862046775994036021D35/.354D3
      B(30)=.1215233140483755572040304994079820246041491D35/.56786730D0
      PI=.4D1*DATAN(.1D1)
      X=DMOD(THETA,.2D1*PI)
      IF (X.GT.PI) X=X-.2D1*PI
      IF (X.LE.-PI) X=X+.2D1*PI
      IF (X.EQ.0.D0) THEN
      CL2=0.D0
      ELSE
      H=.1D1-DLOG(DABS(X))
      XS=X**2
      P=XS
      V=.2D1
      DO 1 I=1,K
      D=B(I)/(DFLOAT(2*I*(2*I+1))*V)*P
      H=H+D
      IF (D.LT.DM.OR.P.LT.PM.OR.V.GT.VM) GOTO 2
      P=P*XS
1     V=V*DFLOAT((2*I+1)*(2*I+2))
2     CL2=X*H
      END IF
      RETURN
C***********************************************************************
      END
c
c***************   ROUTINES ********************************************
c
c       This subroutine contains the 2 loop expressions of
c       [Aww (mw^2) - Aww(0)]/mw^2 and the vertex contribution
c       in units
c       Nc*(alfa0/(4.d0*pi*s2))**2.d0/(zt*c2)**2.d0
c       OUTPUT = drs2lew
c     
        subroutine ew2ldeltarw(zt,ht,drs2lew,s2,mz,mu)
        real*8 zt,ht,drs2lew,s2,c2,mz,ln,vertex,aww,mz2,B0,gdeg,phi,
     1         ddilog,mu,mu2
c
        double precision gmu,repiggh0,mz0,alfa0,alfastr,delQCD,
     1                pi,mel,mmu,mtau,mb,gamz,Nc,zeta3
c
        common/datcom/gmu,repiggh0,mz0,alfa0,alfastr,delQCD,
     1                pi,mel,mmu,mtau,mb,gamz,Nc,zeta3
        c2 = 1.d0 - s2  
        mz2 = mz*mz
        mu2 = mu*mu
        if(dsqrt(ht).lt.0.3d0) then
c       LIGHT HIGGS CASE
c
c       [Aww (mw^2) - Aww(0)]/mw^2
c
        aww = 
     1  35.d0*ht/288.d0-5.d0*ht*ht/(144.d0*c2*zt)- 41.d0*zt/96.d0   -
     2  zt/(48.d0*c2) +325.d0*c2*zt/144.d0 - c2*dsqrt(ht)*pi*zt/3.d0- 
     3  c2*pi*pi*zt/36.d0+B0(c2*mz2, ht*mz2/zt,c2*mz2,mu2)*
     4  (-5.d0*ht/36.d0+5.d0*ht*ht/(144.d0*c2*zt)+5.d0*c2*zt/12.d0) +
     5  B0(c2*mz2, c2*mz2, mz2,mu2)*
     6  (5.d0*zt/12.d0 + zt/(48.d0*c2) - c2*zt/2.d0)  +
     9  (5.d0*(-1.d0)*ht/144.d0-19.d0*zt/12.d0-(425.d0*c2*zt/144.d0)+
     $  25.d0*zt/(16.d0*s2)-5.d0*c2*c2*zt*zt/(16.d0*(ht-c2*zt)))*
     1  dlog(c2) + zt*dlog(c2)**2.d0/2.d0 + c2*zt*dlog(c2)**2.d0/2.d0 + 
     2  zt*dlog(c2)**2.d0/(2.d0*(-s2)) -5.d0*ht*dlog(ht)/48.d0 + 
     3  5.d0*ht*ht*dlog(ht)/(144.d0*c2*zt) +5.d0*c2*zt*dlog(ht)/16.d0 +
     4  5.d0*c2*c2*zt**2.d0*dlog(ht)/(16.d0*(ht - c2*zt)) +
     5  (-5.d0*ht/36.d0 + 5.d0*ht*ht/(144.d0*c2*zt) + 5.d0*zt/12.d0 +
     6  zt/(48.d0*c2) -7.d0*c2*zt/3.d0 + 2.d0*zt*dlog(c2) + 
     7  2.d0*c2*zt*dlog(c2) - 2.d0*zt*dlog(c2)/s2)*(dlog(1.d0/zt) +
     $                     dlog(mz2/mu2) ) + 
     8  (-5.d0*ht/144.d0 +5.d0*zt/12.d0 + zt/(48.d0*c2) - 
     9  209.d0*c2*zt/144.d0 -5.d0*c2*c2*zt*zt/(16.d0*(ht - c2*zt)) +
     $  zt*dlog(c2) + c2*zt*dlog(c2) +zt*dlog(c2)/(-s2))*dlog(zt)
c
        else
c
c       HEAVY HIGGS CASE
c
        aww =
     1  c2*(4.d0 - ht)*zt*ln(-1.d0 + 4.d0/ht)/(12.d0*ht) +
     2  c2*(19.d0+21.d0*ht-12.d0*ht*ht-31.d0*ht**3.d0+9.d0*ht**4.d0)*zt*
     3  ddilog(1.d0 - ht)/(72.d0*ht*ht) +
     4  ((1.d0 + 69.d0*c2 - 145.d0*c2*c2)*zt*dlog(c2))/(48.d0*(-s2)) +
     5  (zt*(-228.d0*c2*c2*ht + 228.d0*c2**3.d0*ht + 18.d0*ht*ht + 
     6  351.d0*c2*ht*ht- 2226.d0*c2*c2*ht*ht +1857.d0*c2**3.d0*ht*ht-
     7  36.d0*c2*c2*ht**3.d0+36.d0*c2**3.d0*ht**3.d0+38.d0*c2*c2*pi*pi -
     8  38.d0*c2**3.d0*pi*pi+42.d0*c2*c2*ht*pi*pi-42.d0*c2**3.d0*ht*pi*
     9  pi + B0(c2*mz2, c2*mz2, mz2,mu2)*(-18.d0*ht*ht-342.d0*c2*ht*ht +
     $  792.d0*c2*c2*ht*ht - 432.d0*c2**3.d0*ht*ht) +
     3  gdeg(ht)
     3  *(144.d0*c2*c2*s2*ht**(2.5d0)-36.d0*c2*c2*s2*ht**(3.5d0))+     
     4  432.d0*c2**3.d0*ht*ht*dlog(c2)**2.d0))/(864.d0*c2*(-s2)*ht*ht)+
     5  (c2*(-31.d0+2.d0*ht-9.d0*ht*ht+3.d0*ht**3.d0)*zt*dlog(ht))/
     6  (72.d0*ht) +((1.d0 + 20.d0*c2 - 132.d0*c2*c2)*zt/(48.d0*c2) + 
     7  (2.d0*c2*c2*zt*dlog(c2))/(-s2))*(dlog(1.d0/zt) +dlog(mz2/mu2))+ 
     8  (zt*(-1.d0-19.d0*c2+93.d0*c2*c2-73.d0*c2**3.d0+48.d0*c2**3.d0*
     9  dlog(c2))*dlog(zt))/(48.d0*c2*(-s2)) + (c2*(-24.d0 + 74.d0*ht + 
     $  35.d0*ht*ht-49.d0*ht**3.d0+9.d0*ht**4.d0)*zt*phi(ht/4.d0))/
     1  (144.d0*ht*ht)
        endif
c
c       vertex contribution
c
        vertex =
     1  zt*( (-2.d0*c2 + 5.d0*c2*c2)*dlog(c2)/(2.d0*(-s2)) +
     2  (3.d0*c2-3.d0*c2*c2-c2*c2*dlog(c2)**2.d0)/(2.d0*(-s2))+
     3  (-c2 + c2*c2 - c2*c2*dlog(c2))/(-s2)*(dlog(1.d0/zt) +
     4      2.d0*dlog(mz2/mu2)) )

        drs2lew = aww + vertex
        return
        end
c
c       This subroutine contains the two loop contribution to
c       the electric charge in units
c       Nc*(alfa0/(4.d0*pi*s2))**2.d0/(zt*c2)**2.d0
c       OUTPUT = deleoe2lew       
c
        subroutine ew2ltwodel(zt,ht,deleoe2lew,s2,mz,mu)
        real*8 zt,ht,deleoe2lew,s2,c2,mz,phi,gdeg,mu,mz2,mu2
c     
        double precision gmu,repiggh0,mz0,alfa0,alfastr,delQCD,
     1                pi,mel,mmu,mtau,mb,gamz,Nc,zeta3
c
        common/datcom/gmu,repiggh0,mz0,alfa0,alfastr,delQCD,
     1                pi,mel,mmu,mtau,mb,gamz,Nc,zeta3
        c2 = 1.d0 - s2  
        mz2 = mz*mz
        mu2= mu*mu
        if(dsqrt(ht).lt.0.3d0) then
c       LIGHT HIGGS CASE
         deleoe2lew =
     1   -s2*c2*zt*( (2.d0-dlog(ht))/9.d0+(100.d0+256.d0*(-4.d0 + 2.d0*
     2   dsqrt(ht)*pi)+96.d0*dlog(ht))/864.d0 +
     3    13.d0/18.d0*(dlog(1.d0/zt)+ dlog(mz2/mu2)) )
c
c
        else
c
c       HEAVY HIGGS CASE
c
        deleoe2lew =
     $  -s2*c2*zt*((100.d0-25.d0*ht+96.d0*dlog(ht)+48.d0*ht*dlog(ht) +
     1  256.d0*(-4.d0+ht/2.d0-(-4.d0 + ht)*dsqrt(ht)*gdeg(ht)/4.d0 +
     2  (6.d0 - ht)*ht*dlog(ht)/4.d0)-64.d0*ht*(-4.d0 + ht/2.d0 - 
     3  (-4.d0+ht)*dsqrt(ht)*gdeg(ht)/4.d0+(6.d0-ht)*ht*dlog(ht)/4.d0))/
     4  (216.d0*(4.d0-ht))+13.d0/18.d0*(dlog(1.d0/zt)+dlog(mz2/mu2))+
     5  4.d0*(-1.d0 + ht)*phi(ht/4.d0)/(9.d0*(-4.d0 + ht)*ht))
c 
        endif
c
        return
        end

c       This subroutine computes  the 2 loop expressions of
c       [Aww (mw^2)/mw^2 - Azz(mz^2)/mw^2] 
c       in units 
c       Nc*(alfa0/(4.d0*pi*s2))**2/(4.d0*zt*c2)**2.d0
c       OUTPUT = tobf2lew
c
        subroutine ew2ltobf(zt,ht,tobf2lew,s2,mz,mu)
        real*8 zt,ht,tobf2lew,s2,c2,mz,mz2,gdeg,ddilog,b0,ln,mu,mu2,phi,
     1         sht,mt
c
        double precision gmu,repiggh0,mz0,alfa0,alfastr,delQCD,
     1                pi,mel,mmu,mtau,mb,gamz,Nc,zeta3
c
        common/datcom/gmu,repiggh0,mz0,alfa0,alfastr,delQCD,
     1                pi,mel,mmu,mtau,mb,gamz,Nc,zeta3
c
        c2 = 1.d0 - s2  
        mz2 = mz*mz
        mu2 = mu*mu
        mt = mz/Dsqrt(zt)
        sht = Dsqrt(ht)
c
        lew=0
        if(lew.eq.1) then
c       BARBIERI result
c
        tobf2lew =
     $  25.d0 - 4.d0*ht + pi*pi*(0.5d0 -1.d0/ht) +
     3  (-4.d0 + ht)*dsqrt(ht)*gdeg(ht)/2.d0 +
     $  (-6.d0 - 6.d0*ht + ht*ht/2.d0)*dlog(ht) +
     4  (54.d0/ht-135.d0+108.d0*ht-27.d0*ht*ht)*ddilog(1.d0-ht)/(9.d0) 
     5  + 1.5d0*(-10.d0 + 6.d0*ht -ht*ht)*phi(ht/4.d0)
        return
        endif
c
c       Our result
        if(ht.lt.0.25d0) then
c       LIGHT HIGGS CASE
c
        tobf2lew =
     1  19.d0 - (53.d0*ht)/3.d0 - 4.d0*dsqrt(ht)*pi - 2.d0*pi*pi    + 
     2  2.d0*ht*pi*pi + 8.d0*ht*ht/(9.d0*zt) -5.d0*ht*ht/(9.d0*c2*zt)+
     3  3.d0/2.d0*ht**(3.d0/2.d0)*pi + B0(mz2, ht*mz2/zt, mz2,mu2)*
     4  (32.d0*ht/9.d0 - 8.d0*ht*ht/(9.d0*zt)) + 
     5  B0(c2*mz2, ht*mz2/zt, c2*mz2,mu2)*(-20.d0*ht/9.d0+
     6  5.d0*ht*ht/(9.d0*c2*zt))-5.d0*ht*dlog(c2)/9.d0 -
     7  2.d0*ht*dlog(ht) - 8.d0*ht*ht*dlog(ht)/(9.d0*zt) + 
     8  5.d0*ht*ht*dlog(ht)/(9.d0*c2*zt)+ 
     9  ht*(5.d0*ht-8.d0*c2*ht+12.d0*c2*zt)*(dlog(1.d0/zt) +
     $      Dlog(mz2/mu2))/(9.d0*c2*zt)+ 
     $  ht*dlog(zt)/3.d0 +  zt*((-9.d0 + 845.d0*c2 + 427.d0*c2*c2 - 
     1  366.d0*c2**3.d0+136.d0*c2*dsqrt(ht)*pi- 
     2  464.d0*c2*c2*dsqrt(ht)*pi+ 256.d0*c2**3.d0*dsqrt(ht)*pi - 
     3  119.d0*c2*pi*pi + 44.d0*c2*c2*pi*pi - 
     4  396.d0*c2*B0(mz2, ht*mz2/zt, mz2, mu2) +
     5  B0(mz2, c2*mz2, c2*mz2, mu2)*(-18.d0*c2 -324.d0*c2*c2 +
     6  288.d0*c2**3.d0)+180.d0*c2*c2*B0(c2*mz2,ht*mz2/zt,c2*mz2,mu2) +
     7  B0(c2*mz2, c2*mz2, mz2, mu2)*(9.d0+180.d0*c2 -
     8  216.d0*c2*c2))/(27.d0*c2) + (-3.d0-32.d0*c2-48.d0*c2*c2)*
     9  dlog(c2)/9.d0 + (3.d0-10.d0*c2-328.d0*c2*c2 + 56.d0*c2**3.d0)*
     $  (dlog(1.d0/zt)+dlog(mz2/mu2))/(9.d0*c2)+(3.d0-11.d0*c2 -
     $  16.d0*c2*c2 - 48.d0*c2**3.d0)*dlog(zt)/(9.d0*c2)) +
     2  4.d0*zt*B0(mz2, ht*mz2/zt, mz2,mu2)
c
        else
c
        if(ht.lt.4.d0) then
c
c
c       INTERPOLATION
c
        tobf2lew =
     1  -15.642064d0 + 0.036381841d0*mt + dsqrt(sht)*(2.30111d0- 
     1   0.013429d0*mt) + sht*(0.0180877d0*mt -9.95272d0) + 
     2   ht*(5.68703d0 - 0.0156807d0*mt) +
     3  ht*sht*(0.00536879d0*mt - 1.64687d0) +ht*ht*(0.185188d0 -
     4  0.000646014*mt) +
     5  8.d0/9.d0*zt*(4.d0 - 26.d0*c2-5.d0*c2*c2)*dlog(mz2/mu2)

        else

c       HEAVY HIGGS CASE
c
        tobf2lew =
     $  (10800.d0*c2*ht**3.d0-4428.d0*c2*ht**4.d0+432.d0*c2*ht**5.d0 -
     1  432.d0*c2*ht**2.d0*pi**2.d0 + 324.d0*c2*ht**3.d0*pi*pi - 
     2  54.d0*c2*ht**4.d0*pi*pi)/(108.d0*c2*(4.d0 - ht)*ht**3.d0) +
     3  ((-4.d0 + ht)*dsqrt(ht)*gdeg(ht))/2.d0 +
     4  ((54.d0*ht*ht-135.d0*ht**3.d0+108.d0*ht**4.d0-27.d0*ht**5.d0)*
     5  ddilog(1.d0 - ht))/(9.d0*ht**3.d0) + ((-5184.d0*ht**3.d0 - 
     6  2592.d0*ht**4.d0+2700*ht**5.d0-540*ht**6.d0 + 27.d0*ht**7.d0)*
     7  dlog(ht))/(54.d0*(-4.d0 + ht)**2.d0*ht**3.d0) + 
     8  (-12960*ht**2.d0 + 14256.d0*ht**3.d0 - 5994.d0*ht**4.d0 +
     9  1134.d0*ht**5.d0-81.d0*ht**6.d0)*phi(ht/4.d0)/
     $  (54.d0*(-4.d0 + ht)**2.d0*ht*ht) +
     1  zt*((3552.d0*c2*c2*ht*ht-144.d0*ht**3.d0+10772.d0*c2*ht**3.d0+
     2  6112.d0*c2*c2*ht**3.d0-7392.d0*c2**3.d0*ht**3.d0+36.d0*ht**4.d0-
     3  2134.d0*c2*ht**4.d0 - 2742.d0*c2*c2*ht**4.d0-136.d0*c2*ht**5.d0+
     4  2872.d0*c2**3.d0*ht**4.d0+248.d0*c2*c2*ht**5.d0 - 
     5  256.d0*c2**3.d0*ht**5.d0 - 592.d0*c2*c2*ht*pi*pi +
     6  244.d0*c2*c2*ht**2.d0*pi*pi - 1904.d0*c2*ht**3.d0*pi*pi +
     7  872.d0*c2*c2*ht**3.d0*pi*pi + 476.d0*c2*ht**4.d0*pi*pi - 
     8  224.d0*c2*c2*ht**4.d0*pi*pi)/(108.d0*c2*(4.d0 - ht)*ht**3.d0) -
     9  2.d0*(1.d0+18.d0*c2-16.d0*c2*c2)*B0(mz2,c2*mz2,c2*mz2,mu2)/3.d0+
     $  (1.d0+20.d0*c2-24.d0*c2*c2)*B0(c2*mz2,c2*mz2,mz2,mu2)/(3.d0*c2)+
     1  (-34.d0+116.d0*c2-64.d0*c2*c2)*(-4.d0+ht)*dsqrt(ht)*gdeg(ht)/54+
     2  40*(-s2)*(4.d0 - ht)*Ln(-1.d0 + 4.d0/ht)/(3.d0*ht) +
     3  (74.d0*c2*ht-12.d0*c2*ht*ht-24.d0*c2*ht**3.d0-44.d0*c2*ht**4.d0+
     4  18.d0*c2*ht**5.d0)*ddilog(1.d0 - ht)/(9.d0*ht**3.d0) +
     5  (-3.d0-42.d0*c2-48.d0*c2*c2)*dlog(c2)/(9.d0) +
     6  (23040.d0*ht*ht-30144.d0*c2*ht*ht +
     7  ht**3.d0*(-10884.d0 + 17856.d0*c2 +  1536.d0*c2*c2) + 
     8  ht**4.d0*(5094.d0 - 14124.d0*c2 + 6528.d0*c2*c2)  +
     9  ht**5.d0*(-2302.d0 + 7094.d0*c2 - 4288.d0*c2*c2) + 
     $  ht**6.d0*(476.d0 - 1516.d0*c2 + 896.d0*c2*c2)+
     1  ht**7.d0*(-34.d0 + 116.d0*c2 - 64.d0*c2*c2))*dlog(ht)/
     2  (54.d0*(-4.d0 + ht)**2.d0*ht**3.d0) -
     3  (3.d0+122.d0*c2-388.d0*c2*c2+56.d0*c2**3.d0)*
     $   (dlog(zt)- dlog(mz2/mu2))/(9.d0*c2) +
     4  (3.d0+5.d0*c2-26.d0*c2*c2-48.d0*c2**3.d0)*dlog(zt)/(9.d0*c2) +
     5  (23040.d0-23040.d0*c2-25860.d0*ht+25344.d0*c2*ht + 
     6  1536.d0*c2*c2*ht+ht*ht*(10236.d0-7872.d0*c2 -1920*c2*c2) +
     7  ht**3.d0*(-1890.d0 -  2856.d0*c2 + 384.d0*c2*c2) + 
     8  ht**4.d0*(144.d0+2724.d0*c2)-672.d0*c2*ht**5.d0 + 
     9  54.d0*c2*ht**6.d0)*phi(ht/4.d0)/(54.d0*(-4.d0+ht)**2.d0*ht*ht))+
     $  4.d0*zt*(1.d0 - dlog(ht)+ dlog(zt)-dlog(mz2/mu2))
c
        endif
        endif
c
        return
        end
c
c       This subroutine computes  the additional term to be added
c       to the Msbar 2 loop expression of
c       [Aww (mw^2)/mw^2 - Azz(mz^2)/mw^2] 
c       in units 
c       Nc*(alfa0/(4.d0*pi*s2))**2/(4.d0*zt*c2)
c       OUTPUT = tobf2lewOS
c   
        subroutine ew2ltobfOS(zt,tobf2lewOS,s2,mz,mu)
        real*8 zt,tobf2lewOS,s2,c2,mz,mu
        c2 = 1.d0 - s2  
        tobf2lewOS  = -(
     1   2.d0*(18.d0 - 181.d0*c2 + 166.d0*c2*c2 - 
     2   216.d0*c2**3.d0)/(27.d0*c2) + 
     3   DSqrt(-1.d0 + 4.d0*c2)*(2.d0*(1.d0 +26.d0*c2+24.d0*c2*c2)*
     4   DATan(1/Sqrt(-1.d0 + 4.d0*c2))/3.d0 - 
     5   (1.d0 + 11.d0*c2 + 12.d0*c2*c2)*
     6   DATan(Sqrt(-1.d0 + 4.d0*c2))/(3.d0*c2*c2)) + 
     7   DLog(c2)/(6.d0*c2*c2)*
     8   (1.d0 + 9.d0*c2 - 4.d0*c2*c2 + 60.d0*c2**3.d0) + 
     9   (-20.d0 + 32.d0*c2)*dLog(zt)/9.d0 +
     $   Dlog(mz*mz/mu/mu)*(4.d0/3.d0 + 34.d0/3.d0*s2 -1.d0/c2))
         
        return
         end
c
c       This subroutine computes  the additional term to be added
c       to the Msbar 2 loop expression of Deltar^w
c       in units 
c       Nc*(alfa0/(4.d0*pi*s2))**2/(4.d0*zt*c2)
c       OUTPUT = drs2lewOS
c
        subroutine ew2ldeltarwOS(zt,drs2lewOS,s2,mz,mu)
        real*8 zt,drs2lewOS,s2,c2,mz,mu
        c2 = 1.d0 - s2  
        drs2lewOS = - (
     1   1.d0/(3.d0*c2) + 4.d0 - 
     2   (1.d0 + 11.d0*c2 + 12.d0*c2*c2)/(3.d0*c2*c2)*
     3   DSqrt(-1.d0 + 4.d0*c2)*DATan(Sqrt(-1.d0 + 4.d0*c2)) -
     4   DLog(c2)*(0.5d0/s2 +3.d0 - 1.5d0/c2 - 1.d0/(6.d0*c2*c2)))
         return
         end
c
c       This subroutine contains the 2 loop expressions of
c       -c/s A_{gamma Z}(mz^2/mz^2) and the vertex contribution
c       in units
c       Nc*(alfa0/(4.d0*pi*s2))**2.d0/(4*zt*c2)**2.d0
c       OUTPUT = k2lew
c 
        subroutine kappacur2l(zt,ht,k2lew,c2,mz,mu)
        real*8 zt,k2lew,phi,c2,mz,mz2,B0,gdeg,mu,mu2,ht,hht
        mz2 = mz*mz
        mu2=mu*mu
        hht = ht/4.d0
        k2lew = zt*(
     1  -8.d0*c2*c2*DLog(c2)/3.d0 + 4.d0*(30.d0*c2-48.d0*c2*c2+ 
     2  135.d0*c2*ht - 216.d0*c2*c2*ht - 50.d0*c2*ht*ht + 
     3  80.d0*c2*c2*ht*ht+5.d0*c2*ht**3.d0-8.d0*c2*c2*ht**3.d0)*
     4  DLog(ht)/(27.d0*(-4.d0 + ht)) + 
     5  (251.d0*c2 - 462.d0*c2*c2-40.d0*c2*ht+64.d0*c2*c2*ht + 
     6  (18.d0*c2 + 144.d0*c2*c2)*B0(mz2,mz2*c2,mz2*c2,mu2) 
     8  +(20.d0*c2 - 32.d0*c2*c2)*(ht-4.d0)*DSQRT(ht)*gdeg(ht) 
     9  -(186.d0*c2-240.d0*c2*c2)*(-DLog(zt)+Dlog(mz2/mu2)))/27.d0+ 
     1  8.d0*(c2 - 3.d0*c2*c2)*DLog(zt)/9.d0  
     1  +8.d0*phi(hht)*(5.d0*c2-8.d0*c2*c2)/(9.d0*(-4.d0 +ht)*ht)-
     1  8.d0*phi(hht)*(5.d0*c2- 8.d0*c2*c2)/(9.d0*(-4.d0 + ht)) 
     1    )
        return
        end
c
c       This subroutine should replace the one with the same name
c       Notice that in the subroutine statement there is one new
c       entry, i.e. i3qf.
c       i3qf is the product of the isospin of the fermion (i3)
c       times the electric charge (qf). The isospin is defined such that for
c       electron i3 = -1, therefore for electron i3qf = 1
c       for down quark i3qf = 1/3, for up quark i3qf = 2/3
c
c       This subroutine contains the additional piece to be
c       added to the MSbar two-loop contribution to
c       c/s A_{gamma Z}(mz^2/mz^2 and the vertex part
c       in units
c       Nc*(alfa0/(4.d0*pi*s2))**2.d0/(4*zt)
c     
        subroutine kappacur2lOS(zt,k2lewOS,c2w,mz,mu,sman,i3qf)
        real*8 zt,k2lewOS,s2w,c2w,mz,mz2,B0,mu,mu2,j1,sman,
     1         ug,revf,i3qf
        s2w = 1.d0-c2w
        mz2 = mz*mz
        mu2=mu*mu
c       c/s A_gz
c       top
        k2lewOS = -32.d0/3.d0*(j1(1.d0/zt,sman/mz2)+dlog(sman/mu2)/6.d0)
c       light quarks
        k2lewOS = k2lewOS + 44.d0/9.d0*(-dlog(sman/mu2)+5.d0/3.d0)
c       leptons
        k2lewOS = k2lewOS + 4.d0*(-dlog(sman/mu2)+5.d0/3.d0)
c       bosons
        k2lewOS = k2lewOS -( 4.d0*c2w*mz2/sman*dlog(c2w)+ 
     $                      4.d0*c2w*mz2/sman*dlog(mz2/mu2) +
     1           (3.d0*sman/mz2 + 4.d0*c2w*mz2/sman)*
     2           B0(sman,mz2*c2w,mz2*c2w,mu2))
c       vertex contribution
        k2lewOS = k2lewOS +2.d0*(ug(c2w*mz2/sman)+0.25d0) +
     $   (i3qf - 1.d0)*(revf(mz2*c2w/sman) + 
     $                   3.d0/2.d0/c2w/c2w*revf(mz2/sman)) -
     $    4.d0*s2w/c2w*(i3qf*i3qf-1.d0)*revf(mz2/sman) +
     1   (5.d0 - 16.d0*s2w + 8.d0*s2w*s2w)/4.d0/c2w/c2w*revf(mz2/sman)
     2       +2.d0*dlog(c2w) +2.d0*dlog(mz2/mu2)
        return
        end
c
c       In OS framework in units
c       Nc*(alfa/(4.d0*pi*s2))**2.d0*(mt^2/(4.d0 mw^2))
c       one has:
c 
c       eta^(2l) = 4.d0*eta2lew +eta2lewOS
c
c       This subroutine contains the 2 loop expressions of
c       Re [Azz (q^2) - Azz(mz^2)]/(q^2 - mz^2) |_mz^2
c       in units
c       Nc*(alfa0/(4.d0*pi*s2))**2.d0/(zt*c2)
c       OUTPUT = eta2lew
c
        subroutine ew2leta(zt,ht,eta2lew,c2,mz,mu)
        real*8 zt,ht,eta2lew,c2,mz,ln,mz2,B0,gdeg,phi,mu,mu2
        double precision gmu,repiggh0,mz0,alfa0,alfastr,delQCD,
     1                pi,mel,mmu,mtau,mb,gamz,Nc,zeta3
c
        common/datcom/gmu,repiggh0,mz0,alfa0,alfastr,delQCD,
     1                pi,mel,mmu,mtau,mb,gamz,Nc,zeta3
        mz2 = mz*mz
        mu2 = mu*mu
  
        if(dsqrt(ht).lt.0.57d0) then
c       LIGHT HIGGS CASE
        
        eta2lew = 
     -   ((-17.d0 + 40.d0*c2 - 32.d0*(c2*c2))*
     -   (-4.d0 + 2.d0*Sqrt(ht)*Pi))/(108.d0*c2) + 
     -  ((-24.d0 + 96.d0*c2)*ht*ht*ht + (144.d0 - 576.d0*c2)*ht*ht*zt + 
     -  ( -313.d0 +1345.d0*c2 + 349.d0*c2*c2 - 292.d0*c2**3)*ht*zt*zt + 
     -  (196.d0 - 1156.d0*c2 - 1396.d0*c2*c2 + 1168.d0*c2**3)*zt*zt*zt)/
     -  (216.d0*c2*(-1.d0 + 4.d0*c2)*(ht - 4.d0*zt)*zt*zt) + 
     -  ((-2.d0*ht*ht*ht + 13.d0*ht*ht*zt - 32.d0*ht*zt*zt + 
     -  36.d0*zt*zt*zt)*B0(mz2, ht*mz2/zt, mz2, mu2))/
     -  (18.d0*c2*(ht - 4.d0*zt)*zt*zt) + 
     -  ((-1.d0 + 4.d0*c2 - 44.d0*c2*c2 + 32.d0*c2**3)*
     -  B0(mz2, c2*mz2, c2*mz2,mu2))/(-24.d0*c2 + 96.d0*(c2*c2)) + 
     -  ((-1.d0-18.d0*c2+16.d0*c2*c2)*DLog(c2))/(2.d0*(-6.d0+24.d0*c2))+ 
     -  ((-2.d0*ht*ht*ht + 11.d0*ht*ht*zt - 24.d0*ht*zt*zt + 
     -  24.d0*zt*zt*zt)*DLog(ht))/(18.d0*c2*(ht - 4.d0*zt)*zt*zt) + 
     -  (((8.d0-32.d0*c2)*ht*ht*ht -52.d0*ht*ht*zt +208.d0*c2*ht*ht*zt + 
     -  159.d0*ht*zt*zt - 704.d0*c2*ht*zt*zt + 192.d0*c2*c2*ht*zt*zt - 
     -  112.d0*c2**3*ht*zt*zt + ( -268.d0 + 1344.d0*c2 - 
     -  768.d0*(c2*c2) + 448.d0*c2**3)*zt*zt*zt)*
     -  (Dlog(1.d0/zt) +DLog(mz2/mu2)))/
     -  (72.d0*c2*(-1.d0 + 4.d0*c2)*(ht - 4.d0*zt)*zt*zt) + 
     -  ((-4.d0*ht*ht + 16.d0*c2*ht*ht + 20.d0*ht*zt - 79.d0*c2*ht*zt - 
     -  70.d0*c2*c2*ht*zt+48.d0*c2**3*ht*zt-40.d0*zt*zt+156.d0*c2*zt*zt+ 
     -  280.d0*c2*c2*zt*zt - 192.d0*c2**3*zt*zt)*DLog(zt))/
     -  (36.d0*c2*(-1.d0 + 4.d0*c2)*(ht - 4.d0*zt)*zt)
c
        else
c
c       HEAVY HIGGS CASE
c
        eta2lew =
     -  (-1152.d0 + 4608.d0*c2 +50.d0*ht+2248.d0*c2*ht+976.d0*c2*c2*ht - 
     -  1600.d0*c2**3*ht+67.d0*ht*ht-880.d0*c2*ht*ht-244.d0*c2*c2*ht*ht+ 
     -  400.d0*c2**3*ht*ht)/(864.d0*c2*(1.d0 -4.d0*c2)*(-4.d0 + ht)*ht)+ 
     -  ((-1.d0 + 4.d0*c2 - 44.d0*c2*c2 + 32.d0*c2**3)*
     -  B0(mz2,c2*mz2,c2*mz2,mu2))/(-24.d0*c2 + 96.d0*(c2*c2)) + 
     -  (4.d0/3.d0 - 4.d0/ht - 
     -  (1.d0 -4.d0/ht)*Ln(-1.d0 + 4.d0/ht))/(12.d0*c2) + 
     -  ((-1.d0-18.d0*c2+16.d0*c2*c2)*DLog(c2))/(2.d0*(-6.d0+24.d0*c2))+ 
     -  ((-384.d0 - 202.d0*ht + 320.d0*c2*ht - 256.d0*c2*c2*ht + 
     -  55.d0*ht*ht + 80.d0*c2*ht*ht - 64.d0*c2*c2*ht*ht +3.d0*ht*ht*ht-
     -  40.d0*c2*ht*ht*ht + 32.d0*(c2*c2)*ht*ht*ht)*DLog(ht))/
     -  (144.d0*c2*(-4.d0 + ht)**2*ht) +
     -  ((-17.d0 + 40.d0*c2 - 32.d0*(c2*c2))*(-4.d0 + ht/2.d0 + 
     -  (1.d0 - ht/4.d0)*Sqrt(ht)*gdeg(ht) + 
     -  ((6.d0 - ht)*ht*Log(ht))/4.d0))/(108.d0*c2) + 
     -  ((-31.d0 + 192.d0*c2 - 192.d0*(c2*c2) + 112.d0*c2**3)*
     -  (Dlog(1.d0/zt) + DLog(mz2/mu2)))/(72.d0*c2 - 288.d0*(c2*c2)) + 
     -  ((2.d0 - 7.d0*c2 - 70.d0*c2*c2 + 48.d0*c2**3)*DLog(zt))/
     -  (-36.d0*c2 + 144.d0*(c2*c2))+ 
     -  ((-384.d0 - 10.d0*ht + 320.d0*c2*ht - 256.d0*(c2*c2)*ht + 
     -  238.d0*ht*ht - 400.d0*c2*ht*ht + 320.d0*c2*c2*ht*ht - 
     -  63.d0*ht*ht*ht + 80.d0*c2*ht*ht*ht - 
     -  64.d0*(c2*c2)*ht*ht*ht + 3.d0*ht**4)*phi(ht/4.d0))/
     -  (144.d0*c2*(-4.d0 + ht)**2*ht*ht)
        endif
c
        return
        end
c
c       This subroutine contains the additional piece to be
c       added to the MSbar two-loop contribution to
c       Re [Azz (q^2) - Azz(mz^2)]/(q^2 - mz^2) |_mz^2
c       in units
c       Nc*(alfa0/(4.d0*pi*s2))**2.d0/(4.d0*zt*c2)
c       OUTPUT = eta2lewOS
c      
        subroutine ew2letaOS(zt,ht,eta2lewOS,s2,mz,mu,sman,i3qf)
        real*8 zt,eta2lewOS,c2,mz,mz2,B0,mu,mu2,sman,ug,revf,i3qf,
     1         zs2,di,ln,hbar,j1,a1,a2,ht,s2,vertex
c
        mz2 = mz*mz 
        mu2=mu*mu
        zs2 =1.d0/zt        
        c2 = 1.d0 - s2
c       Azz
         eta2lewOS =  
     -   (197.d0 - 1378.d0*c2 + 1064.d0*c2*c2)/(27.d0*(-1.d0 +4.d0*c2))+ 
     -   (1.d0 + 16.d0*c2 - 20.d0*(c2*c2) + 48.d0*c2**3)*
     -   B0(mz2, c2*mz2, c2*mz2, mu2)/(-3.d0 + 12.d0*c2) + 
     -   (2.d0*c2*(1.d0 + 26.d0*c2 + 24.d0*(c2*c2))*DLog(c2))/
     -   (-3.d0 + 12.d0*c2) + 
     -   (2.d0*(-20.d0 + 113.d0*c2 - 102.d0*(c2*c2) + 24.d0*c2**3)*
     -   (Dlog(zs2) + DLog(mz2/mu2)))/(-3.d0 + 12.d0*c2) + 
     -   (2.d0*(-50.d0 + 283.d0*c2 - 242.d0*c2*c2 + 72.d0*c2**3)*
     -   DLog(zt))/(-9.d0 + 36.d0*c2)  

c       Vertex contribution 
        vertex = 
     -   4.d0*c2*(DLog(c2) + DLog(mz2/mu2)) +4.d0*c2*(ug(mz2*c2/sman)+
     -    0.25d0) - 2.d0*c2*(1.d0 - i3qf)*revf(mz2*c2/sman) -
     -    (1.d0 - 6.d0*I3qf + 12.d0*(1.d0-c2*c2)*i3qf*i3qf)/(2.d0*c2)*
     -    revf(mz2/sman) 
  
c       Contribution of eta due to overall shift
c 
c       hadronic contribution
        di=4.d0*zs2-1.d0
         a1=(6.d0*(zs2-4.d0*zs2*zs2/di*ln(di)+1.d0/6.d0+j1(zs2,1.d0))*
     1       (16.d0*s2*s2/9.d0-4.d0*s2/3.d0+0.5d0)-1.5d0*zs2 +
     1        6.d0*zs2*zs2/di*ln(di) -
     2        2.d0/3.d0*(2.5d0-14.d0/3.d0*s2+44.d0*s2*s2/9.d0)  +
     3       3.d0*(20.d0/9.d0*s2*s2 - 2.d0*s2 + 1.d0)*Dlog(mz2/mu2))/c2
c          leptonic contribution
        a1= a1 +(1.d0-2.d0*s2+4.d0*s2*s2)/c2*(Dlog(mz2/mu2)-2.d0/3.d0)
c          bosonic contribution
        a2=dsqrt(4.d0*c2-1.d0)
        a2=a2*datan(1.d0/a2)
        a2=a2*(1.d0/6.d0/c2-2.d0/3.d0+c2/c2/3.d0-4.d0/3.d0*c2
     1        +6.d0*c2*c2-6.d0*c2+c2/c2*(18.d0*c2**2-8.d0*c2*s2**2)
     2        /(4.d0*c2-1.d0))
c
        a2=a2+hbar(ht/zt)/2.d0/c2
        a2=a2+dlog(c2)*(1.d0/12.d0/c2-1.d0/3.d0-3.d0*c2)-4.d0*c2*c2
     1     +108.d0/36.d0*c2-8.d0*c2/3.d0+5.d0/9.d0-5.d0/36.d0/c2
     2     +5.d0/3.d0 -1.d0/6.d0*(19.d0*c2 - s2*s2/c2)*dlog(mz2/mu2)
        eta2lewOS = eta2lewOS + vertex + a1 + a2
c
        return
        end

c       function Hbar in d AZZ(q**2)/d q**2 (Degrassi-Sirlin)
        double precision function hbar(x)
        double precision x,a,h
        h=31.d0/18.d0-x+x*x/3.d0
        h=(1.d0-1.5d0*x+0.75d0*x*x-x*x*x/6.d0)*dlog(x)+h
        if(x.gt.4.d0) go to 330
        a=dsqrt(4.d0/x-1.d0)
        a=datan(a)
        a=a*dsqrt(4.d0*x-x*x)
        hbar=h+(-2.d0+2.d0/(4.d0-x)+5.d0*x/6.d0-x*x/3.d0)*a
        go to 340
330     continue
        a=dsqrt(1.d0-4.d0/x)
        a=dlog((1.d0-a)/(1.d0+a))
        a=dsqrt(x*x/4.d0-x)*a
        hbar=h+(-2.d0+2.d0/(4.d0-x)+5.d0/6.d0*x-x*x/3.d0)*a
340     continue
        return
        end