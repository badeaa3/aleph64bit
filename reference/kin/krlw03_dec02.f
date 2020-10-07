      SUBROUTINE ASKUSI(IGCOD)
      IMPLICIT none
      INTEGER igcod
C-----------------------------------------------------------------------
C Initialization
C Adapted from KRLW01 and KRLW02 interfaces
C - KRLW01                      P.Perez, B.Bloch                   1995
C - KRLW02                      A.Valassi                          1996
C - add vertex offset           B.Bloch                        Sep 1998
C - add W+- mass difference     A.Valassi                      Nov 2000
C - KRLW03 (KORALW 1.42)        S.Jezequel                         1997
C - KRLW03 (KORALW 1.52)        B.Bloch, A.Valassi            1999-2001
C - IMPLICIT NONE + CLEANUP     A.Valassi                     June 2001
C - KandY (KW and YFSWW 3.1.16) A.Valassi                     June 2001
C - Various additions           A.Valassi                     June 2001
C-----------------------------------------------------------------------
C Generator code (see KINLIB DOC)
      INTEGER igco, iver
      PARAMETER ( IGCO = 5038 )
      PARAMETER ( IVER = 1532 )
C Input/output units
      INTEGER          inut, iout
      COMMON / INOUT / INUT, IOUT
C KORALW generator input parameters
      INTEGER npar
      PARAMETER (npar=10000)
      DOUBLE PRECISION xpar(npar) ! array for input parameters
C BOS stuff
      INTEGER    LBCS
      PARAMETER (LBCS=1000)
      COMMON /BCS/ IW(LBCS)
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C Vertex information
      INTEGER namind
      INTEGER nasvrt, jsvrt
      INTEGER naxvrt, jxvrt
C KINGAL Common block KGCOMM
      REAL*4  VRTEX, SDVRT, XVRT, SXVRT, ECMI
      INTEGER NEVENT, IFVRT
      COMMON / KGCOMM / 
     &     VRTEX(4), SDVRT(3), XVRT(3), SXVRT(3), ECMI, 
     &     NEVENT(9), IFVRT
      integer iflowm
      real xlow
      common/toolowm/xlow,iflowm
C KINGAL KPAR bank
      INTEGER nrow, ncol
      PARAMETER (ncol=534)
      REAL userpar(132)
      REAL tabl(ncol)
      INTEGER it, jkpar
      INTEGER altabl
C KINGAL RLEP bank
      INTEGER IEBEAM, JRLEP
      INTEGER NINT, ALRLEP
C KANDY common
      INTEGER ikandy            ! 0=off 1=weightedKandy 2=unweightedKandy
      CHARACTER*200 chywexe     ! full path to YFSWW executable
      CHARACTER*200 chywout     ! full path to output file for YFSWW
      CHARACTER*200 ch4vect     ! full path to FIFO file to exchange 4vectors
      CHARACTER*200 chwtext     ! full path to FIFO file to exchange weights
      COMMON / K3ANDY / ikandy, chywexe, chywout, ch4vect, chwtext
C Welcome
      CHARACTER*200 chhost
      CHARACTER*200 chos
      INTEGER lnblnk
      INTEGER idate, itime
C
C Return generator code
C
      IGCOD = IGCO
      INUT  = IW(5)
      IOUT  = IW(6)
      WRITE(IOUT,101) IGCOD, IVER
  101 FORMAT(/,10X,'KRLW03 - CODE NUMBER =',I4,
     &       /,10X,'**************************',
     &       /,10X,' SUBVERSION  :',I10 ,
     &       /,10X,' Last mod = 8 December 2002  ')
C
C Welcome
C
      WRITE (iout,*)
     &     '_ASKUSI Welcome to KRLW03!'
      CALL getenv('HOST',chhost)
      CALL getenv('OS',chos)
      CALL datime(idate,itime)
      WRITE (iout,'(1x,a,1x,i6,1x,i4)') 
     &     'Execution on '//chhost(1:lnblnk(chhost))
     &     //' under '//chos(1:lnblnk(chos))//' starting on '
     &     //'[yymmdd] [hhmm]', idate, itime
C
C Input parameters for the KORALW generator (see subroutine KW for comment)
C Defaults can be changed by cards GKEY, GENE, GKAC, GDEK, MSKW, MSKZ, XPAR
C
      CALL KORALWINI_DEFAULTS(XPAR) ! defaults for xpar are set
      CALL KORALWINI_USER(XPAR)     ! change xpar according to the cards
      CALL KORALWINI_CHECK(XPAR)    ! check xpar, change if needed
C
C Input parameters for the KRLW03 interface (user cuts, mass difference)
C Defaults can be changed by cards GDMW,GCWW,GCZZ,GCE1,GCE2,GCUU,GCEE
C
      CALL KRLW03INI_USER(userpar)
C
C KINGAL KGCOMM bank
C
* initialize event counters
      NEVENT(1) = 0             ! #gen evts (#Askuse calls)
      NEVENT(2) = 0             ! #acc evts (#Askuse calls with ist=0)
      NEVENT(3) = 0             ! #rej evts (#Askuse calls with ist#0)
      NEVENT(4) = 0             ! #rej evts (ist#0 because weight=0)
      NEVENT(5) = 0             ! #rej evts (ist#0 in KWGT bank)
      NEVENT(6) = 0             ! #rej evts (ist#0 in KW4F bank)
      NEVENT(7) = 0             ! #rej evts (ist#0 elsewhere)
      NEVENT(8) = 0             ! #acc evts with W bosons
      NEVENT(9) = 0             ! #acc evts with Z bosons
* cms energy
      ecmi = xpar(1)
* main vertex initialization
      SDVRT(1) = 0.0113
      SDVRT(2) = 0.0005
      SDVRT(3) = 0.790
      NASVRT = NAMIND('SVRT')
      JSVRT  = IW(NASVRT)
      IF(JSVRT.NE.0) THEN
        SDVRT(1) = RW(JSVRT+1)
        SDVRT(2) = RW(JSVRT+2)
        SDVRT(3) = RW(JSVRT+3)
      ENDIF
* KINGAL offset for position of interaction point
* If needed get a smearing on this position
* XVRT    x      y      z    ( sz    sy    sz)
      CALL vzero (XVRT,  3)
      CALL vzero (SXVRT, 3)
      IFVRT = 0
      NAXVRT = NAMIND('XVRT')
      JXVRT  = IW(NAXVRT)
      IF (JXVRT.NE.0) THEN
        IFVRT = 1
        XVRT(1)=RW(JXVRT+1)
        XVRT(2)=RW(JXVRT+2)
        XVRT(3)=RW(JXVRT+3)
        IF (IW(JXVRT).gt.3) then
          IFVRT = 2
          SXVRT(1)=RW(JXVRT+4)
          SXVRT(2)=RW(JXVRT+5)
          SXVRT(3)=RW(JXVRT+6)
        ENDIF
      ENDIF
C
C Fill and print the RLEP bank
C
      IEBEAM = NINT(ecmi * 500.)
      JRLEP  = ALRLEP(IEBEAM,'    ',0,0,0)
      CALL PRTABL('RLEP',0)
C
C Initialise Jetset stuff (this can modify XPAR!)
C
      CALL KRLW03INI_JETSET(xpar)
C
C Initialise Kandy stuff (this can modify XPAR!)
C Defaults can be changed by cards YFSW, YOUT, YUNW
C 
      CALL KRLW03INI_KANDY(xpar)
C
C Store FINAL generator parameters in the TABL array
C Fill and print the KPAR bank with the contents of the TABL array
C
      DO it = 1, ncol
        TABL(it) = 0
      END DO
* TABL(1-80)=xpar(1-80): basic parameters, internal cuts, TGC values
      DO it = 1, 80
        TABL(it)     = xpar(it)
      END DO
* TABL(81-90)=xpar(111-120): CKM matrix elements
      DO it = 1, 10
        TABL(it+80)  = xpar(110+it)
      END DO
* TABL(91-100)=xpar(131-140): W decay BR's
      DO it = 1, 10
        TABL(it+90)  = xpar(130+it)
      END DO
* TABL(101-180)=xpar(1011-1090): KORALW technical switches
      DO it = 1, 80
        TABL(it+100) = xpar(1010+it)
      END DO
* TABL(181-382)=xpar(1101-1302): KORALW WW and ZZ masks
      DO it = 1, 202
        TABL(it+180) = xpar(1100+it)
      END DO
* TABL(383-391)=xpar(2001-2009): YFSWW technical switches
      DO it = 1, 9
        TABL(it+382) = xpar(2000+it)
      END DO
* TABL(392): user parameter ikandy for YFSWW
      TABL(392) = ikandy
* TABL(393-402): vertex position and smearing
      DO it = 1, 3
        TABL(it+392) = SDVRT(it)
        TABL(it+395) = XVRT(it)
        TABL(it+398) = SXVRT(it)
      END DO      
      TABL(402) = ifvrt
* TABL(403-534): user parameters for cuts and mass difference
      DO it = 1, 132
        TABL(402+it) = userpar(it)
      END DO
* fill the bank
      NROW  = 1
      JKPAR = ALTABL('KPAR',NCOL,NROW,TABL,'2I,(F)','C')
* print the bank
      CALL PRTABL('KPAR',0)
C
C Generator initialization with the final xpar array
C
      WRITE(iout,*) '_ASKUSI Now call KW_initialize'
      WRITE(iout,*) '_ASKUSI ecmi, xpar(1)', ecmi, xpar(1)
      CALL KW_Initialize(XPAR)
      WRITE(iout,*) '_ASKUSI Exited KW_initialize'
C
C Initialise Tauola stuff and fill the KORL bank
C Print the KORL bank
C
      CALL KRLW03INI_TAUOLA
      CALL PRTABL('KORL',0)
C
C Monitor the xsections for accepted Kingal events only
C
      CALL xsecmon(-1)
C   minimu mass of hadronic system for Jetset
      xlow = 0.200
C
C Book some control histograms
C
*     CALL krlw03_bookhis
      call hbook1(101,'minv ffbar',50,0.,200.,0.)
      call hbook1(102,'electron cost',50,-1.,1.,0.)
      call hbook1(103,'positron cost',50,-1.,1.,0.)
      call hbook1(104,'electron energy',50,0.,100.,0.)
      call hbook1(105,'positron energy',50,0.,100.,0.)
      call hbook1(116,'sum pt_ch^2',60,5.,605.,0.)
      call hbook1(106,'accepted sum pt_ch^2',60,5.,605.,0.)
      call hbook1(107,' masse 12 & 34 for ee',50,0.,25.,0.)
      call hbook1(108,' accepted masse 12 & 34 for ee',50,0.,10.,0.)
C
C Return
C
      RETURN
      END

************************************************************************

      SUBROUTINE ASKUSE (IDP,IST,NTRK,NVRT,ECM,WEI)
      IMPLICIT none
      INTEGER idp, ist, ntrk, nvrt
      REAL ecm, wei
C-----------------------------------------------------------------------
C Event generation
C Adapted from KRLW01 and KRLW02 interfaces
C - KRLW01                      P.Perez, B.Bloch                   1995
C - KRLW02                      A.Valassi                          1996
C - KRLW03 (KORALW 1.52)        B.Bloch, A.Valassi            1998-2001
C - IMPLICIT NONE + CLEANUP     A.Valassi                     June 2001
C - KandY (KW and YFSWW 3.1.16) A.Valassi                     June 2001
C - Various additions           A.Valassi                     June 2001
C-----------------------------------------------------------------------
C Input:  none
C Output: 6 arguments
C          IDP    : process identification
C          IST    : status flag (0 means ok)
C          NTRK   : number of tracks generated and kept
C          NVRT   : number of vertices generated
C          ECM    : center of mass energy for the event
C          WEI    : event weight always equal to 1
C--------------------------------------------------------------------
C Jetset commons
      INTEGER LJNPAR
      INTEGER L1MST, L1PAR
      INTEGER L2PAR, L2PARF
      PARAMETER (LJNPAR=4000)
      PARAMETER (L1MST=200, L1PAR=200)
      PARAMETER (L2PAR=500, L2PARF=2000 )
      INTEGER N7LU, K7LU
      REAL    P7LU, V7LU
      INTEGER MSTU, MSTJ
      REAL    PARU, PARJ
      INTEGER KCHG
      REAL    PMAS, PARF, VCKM
      COMMON /LUJETS/ N7LU,K7LU(LJNPAR,5),P7LU(LJNPAR,5),V7LU(LJNPAR,5)
      COMMON /LUDAT1/ MSTU(L1MST),PARU(L1PAR),MSTJ(L1MST),PARJ(L1PAR)
      COMMON /LUDAT2/ KCHG(L2PAR,3),PMAS(L2PAR,4),PARF(L2PARF),VCKM(4,4)
      INTEGER ipart
C KORALW event properties
      INTEGER iflav(4)
      DOUBLE PRECISION amdec(4)
      COMMON / DECAYS / IFLAV, AMDEC
C Generate vertex
      REAL rn1, rn2, rn3, dum
      REAL rxx, ryy, rzz
      REAL*4  VRTEX, SDVRT, XVRT, SXVRT, ECMI
      INTEGER NEVENT, IFVRT,iok
      COMMON / KGCOMM / 
     &     VRTEX(4), SDVRT(3), XVRT(3), SXVRT(3), ECMI, 
     &     NEVENT(9), IFVRT
      integer iflowm
      real xlow
      common/toolowm/xlow,iflowm
C Event weight
      DOUBLE PRECISION wtmain, wtcrud, wtset(100)
C Status code
      INTEGER istatus
C Input/output units
      INTEGER          inut, iout
      COMMON / INOUT / INUT, IOUT
C KORALW switches
      INCLUDE 'KW.h'
C Overweighted and negative weight events
      INTEGER           nevovrwgt, nevnegwgt
      COMMON / OVRWGT / nevovrwgt, nevnegwgt                           !cav
C KANDY common
      INTEGER ikandy            ! 0=off 1=weightedKandy 2=unweightedKandy
      CHARACTER*200 chywexe     ! full path to YFSWW executable
      CHARACTER*200 chywout     ! full path to output file for YFSWW
      CHARACTER*200 ch4vect     ! full path to FIFO file to exchange 4vectors
      CHARACTER*200 chwtext     ! full path to FIFO file to exchange weights
      COMMON / K3ANDY / ikandy, chywexe, chywout, ch4vect, chwtext
C
      IF ( mod( nevent(2)+1, 10**INT(log(1.*nevent(2)+1)/log(10.)) 
     &     ).EQ.0 ) THEN
        WRITE(iout,
     &       '(1x,''_ASKUSE Entering event: #accepted = '', i9,
     &       '' #generated = '',i9)'), nevent(2)+1, nevent(1)+1
      ENDIF      
C
      IDP  = 0
      IST  = 0
      NTRK = 0
      NVRT = 0
      ECM  = 0.
      WEI  = 0.
C
C Reset fragmentation storage in common
C
      MSTU(90)=0
C
C  Generate primary vertex
C
      CALL RANNOR (RN1,RN2)
      CALL RANNOR (RN3,DUM)
      VRTEX(1) = RN1*SDVRT(1)
      VRTEX(2) = RN2*SDVRT(2)
      VRTEX(3) = RN3*SDVRT(3)
      VRTEX(4) = 0
      IF ( IFVRT.ge.1 ) THEN
         VRTEX(1) = VRTEX(1) + XVRT(1)
         VRTEX(2) = VRTEX(2) + XVRT(2)
         VRTEX(3) = VRTEX(3) + XVRT(3)
      ENDIF
      IF ( IFVRT.ge.2 ) THEN
         CALL RANNOR(RXX,RYY)
         CALL RANNOR(RZZ,DUM)
         VRTEX(1) = VRTEX(1) + RXX*SXVRT(1)
         VRTEX(2) = VRTEX(2) + RYY*SXVRT(2)
         VRTEX(3) = VRTEX(3) + RZZ*SXVRT(3)
      ENDIF
C
C  Event generation in KORALW
C
 10   continue

      CALL KW_MAKE

C
C  Event counter
C
      NEVENT(1) = NEVENT(1)+1

      if (iflowm.gt.0) go to 10   ! this event could not hadronize
C   apply a possible selection on final particles
      iok = 0
      call seluser(iok)
C      print *,iok,' iok for event ',nevent(1)
      if ( iok.ne.0) go to 10
      if (NEVENT(1).le.5) call lulist(1)
C
C Event properties
C
      IDP  =         abs(IFLAV(1)) 
     &     +     100*abs(IFLAV(2)) 
     &     +   10000*abs(IFLAV(3))
     &     + 1000000*abs(IFLAV(4))
      ECM  = ECMI
C
C Get event weight
C
      CALL KW_getwtall(wtmain, wtcrud, wtset)
      IF (wtmain.LT.0d0) THEN
        nevnegwgt = nevnegwgt+1
        WRITE(iout,*) 
        WRITE(iout,
     &       '(1x,''_ASKUSE Wgt<0 event!! #acc='', i9,
     &       '' #gen='',i9,'' wgt='',e8.3)'), 
     &       nevent(2)+1, nevent(1)+1, wtmain
      ELSEIF (m_keywgt.EQ.0 .AND. wtmain.GT.1d0) THEN
        nevovrwgt = nevovrwgt+1
        WRITE(iout,*) 
        WRITE(iout,
     &       '(1x,''_ASKUSE Ovrwgt event! #acc='', i9,
     &       '' #gen='',i9,'' wgt='',e8.3)'), 
     &       nevent(2)+1, nevent(1)+1, wtmain
      ENDIF
      wei = wtmain              ! wgtd/unwgtd depending on Keywgt switch!
      IF (wei.LE.0) THEN
        ist = -4
        NEVENT(4) = NEVENT(4)+1
        GO TO 20
      ENDIF
C
C Post-generation YFSWW O(alpha) weights for accepted events (card YUNW)
C
      IF (ikandy.EQ.1) CALL kandypost(0) 
C
C Store interesting weights in KWGT
C NB This fails, amongst other things, if wtset(1)<0
C
      CALL KKWGT(istatus)
      IF (istatus.eq.0) THEN
        WRITE(iout,*) 
     &       '_ASKUSE Error booking KWGT: GenEvt #', NEVENT(1),
     &       ', AccEvt # ', NEVENT(2)
        ist = -5
        NEVENT(5) = NEVENT(5)+1
        GO TO 20
      ENDIF
C
C Monitor the xsections for accepted Kingal events only
C
      CALL xsecmon(0)
C
C Create KW4f bank with double precision information on photons
C This is necessary for a-posteriori reweighting with YFSWW O(alpha) radcor
C
      CALL KW4FBK(istatus)
      IF (istatus.ne.0) THEN
        IST = -6
        NEVENT(6) = NEVENT(6)+1
        GO TO 20
      ELSE
        IF(NEVENT(1).le.5) call prtabl('KW4F',0)
      ENDIF
C
C Decay remaining pi0's
C Book all banks
C
      CALL KXL7AL(VRTEX,istatus,NVRT,NTRK)
      IF (istatus.ne.0) THEN
        IST  = -7
      ENDIF
C
C Book & fill the bank KZFR with info on fragmentation
C
      CALL kzfrbk(istatus)
      IF (istatus.NE.0) THEN 
        IST  = -8
      ENDIF
C
C WHAT IS THIS? (comes from hzha)
C
      IF (MSTU(24).GT.0) THEN
        IST  = -9
        CALL LULIST(1)
      ENDIF
C
C Was event OK?
C      
      IF(IST.NE.0) THEN
        NEVENT(7) = NEVENT(7)+1
        GO TO 20
      ENDIF
C
C  Event counters (with and without photons)
C
      IF (IST.EQ.0) THEN
        NEVENT(2) = NEVENT(2) + 1
        DO ipart = 1, N7LU
          IF(ABS(K7LU(ipart,2)).EQ.24) THEN
            NEVENT(8) = NEVENT(8)+1
            GO TO 20
          ENDIF
        END DO
        DO ipart = 1, N7LU
          IF(ABS(K7LU(ipart,2)).EQ.23) THEN
            NEVENT(9) = NEVENT(9)+1
            GO TO 20
          ENDIF
        END DO
      ENDIF
C
C Exit point
C
   20 CONTINUE
      IF(IST.NE.0) NEVENT(3)=NEVENT(3)+1
C
C Fill histograms
C
      IF (IST.EQ.0) CALL krlw03_fillhis
C
C Return
C
      RETURN
      END

************************************************************************

      SUBROUTINE USCJOB
      IMPLICIT none
C-----------------------------------------------------------------------
C End of generation
C Adapted from KRLW01 and KRLW02 interfaces
C - KRLW01                      P.Perez, B.Bloch                   1995
C - KRLW02                      A.Valassi                          1996
C - KRLW03 (KORALW 1.51)        B.Bloch, A.Valassi            1998-2001
C - IMPLICIT NONE + CLEANUP     A.Valassi                     June 2001
C - KandY (KW and YFSWW 3.1.16) A.Valassi                     June 2001
C - Various additions           A.Valassi                     June 2001
C-----------------------------------------------------------------------
C Input/output units
      INTEGER          inut, iout
      COMMON / INOUT / INUT, IOUT
C KINGAL common block
      REAL*4  VRTEX, SDVRT, XVRT, SXVRT, ECMI
      INTEGER NEVENT, IFVRT
      COMMON / KGCOMM / 
     &     VRTEX(4), SDVRT(3), XVRT(3), SXVRT(3), ECMI, 
     &     NEVENT(9), IFVRT
C KORWAN cross sections
      INTEGER keymod, keypre
      DOUBLE PRECISION svar
      DOUBLE PRECISION xsecsa0, xerrsa0
      DOUBLE PRECISION xsecsa3, xerrsa3
C KORALW cross sections
      INTEGER nvtru
      DOUBLE PRECISION xsecnr, xerrnr
      DOUBLE PRECISION xsecmc, xerrmc
C KORALW switches
      INCLUDE 'KW.h'
C KRLW03 event statistics
      INTEGER           nevovrwgt, nevnegwgt
      COMMON / OVRWGT / nevovrwgt, nevnegwgt                           !cav
      INTEGER           nkwctot,    nkwctww, nkwctzz, 
     &                  nkwcte1,    nkwcte2, nkwctuu, nkwctee,nkwctpt
      COMMON / USLCTO / nkwctot(3), nkwctww, nkwctzz,                  !cav
     &                  nkwcte1,    nkwcte2, nkwctuu, nkwctee,nkwctpt  !cav
      INTEGER           nphspace
      COMMON / KOPHSP / nphspace(5)                                    !cav
      INTEGER           nselecto
      COMMON / KOSELE / nselecto(4)                                    !cav
C KANDY common
      INTEGER ikandy            ! 0=off 1=weightedKandy 2=unweightedKandy
      CHARACTER*200 chywexe     ! full path to YFSWW executable
      CHARACTER*200 chywout     ! full path to output file for YFSWW
      CHARACTER*200 ch4vect     ! full path to FIFO file to exchange 4vectors
      CHARACTER*200 chwtext     ! full path to FIFO file to exchange weights
      COMMON / K3ANDY / ikandy, chywexe, chywout, ch4vect, chwtext
C Byebye
      CHARACTER*200 chhost
      CHARACTER*200 chos
      INTEGER idate, itime
C More KANDY stuff
      INTEGER lnblnk
C
C End of generation
C
      IF (ikandy.EQ.1) CALL kandypost(1)
      CALL KW_Finalize
C
C Cleanup KANDY environment
C
      if (ikandy.GT.0) then
        write (iout,*) '_USCJOB: Cleanup KANDY environment'
        CALL system( '\rm -f '//ch4vect(1:lnblnk(ch4vect)) )
        CALL system( '\rm -f '//chwtext(1:lnblnk(chwtext)) )
        write (iout,*) '_USCJOB: KANDY environment cleaned up'
      endif
C
C Print event counters
C
      WRITE(IOUT,101)
 101  FORMAT(/
     &     /20X,'EVENTS STATISTICS',
     &     /20X,'*****************')
      WRITE(IOUT,102) 
     &     NEVENT(1),NEVENT(2),NEVENT(3),NEVENT(8),NEVENT(9)
 102  FORMAT(
     &     /5X,'# OF GENERATED EVENTS                      = ',I10,
     &     /5X,'# OF ACCEPTED  EVENTS                      = ',I10,
     &     /5X,'# OF REJECTED  EVENTS (IST#0 in ASKUSE)    = ',I10,
     &     /5X,'# OF ACCEPTED  EVENTS WITH W BOSONS        = ',I10,
     &     /5X,'# OF ACCEPTED  EVENTS WITH Z BOSONS        = ',I10)
      WRITE(IOUT,103)
 103  FORMAT(/
     &     /20X,'ERRORS STATISTICS',
     &     /20X,'*****************')
      WRITE(IOUT,104) NEVENT(4),NEVENT(5),NEVENT(6),NEVENT(7)
 104  FORMAT(
     &     /10X,'IST#0 EVENT WITH WEIGHT=0   # OF REJECT = ',I10,
     &     /10X,'IST#0 IN BOOKING KWGT       # OF REJECT = ',I10,
     &     /10X,'IST#0 IN BOOKING KW4F       # OF REJECT = ',I10,
     &     /10X,'IST#0 IN KXL7AL AND LATER   # OF REJECT = ',I10)
C
C Print cross-section (MC and Semi-analytical calculations)
C
      WRITE(iout,*)
      WRITE(iout,'(A60)') '============ KRLW03: X-sections ============'
      WRITE(iout,*)
* Korwan
      IF (m_key4f.eq.0) THEN
        svar=ecmi**2
        keymod=0
        keypre=1
        call korwan(svar,0d0,1d0,keymod,keypre,xsecsa0,xerrsa0)
        keymod=303
        keypre=1
        call korwan(svar,0d0,1d0,keymod,keypre,xsecsa3,xerrsa3)
        WRITE(iout,'(1X,F17.8, 4H  +-, F17.8, 1X, A30)')
     $       xsecsa0,xerrsa0,'SemiAnal Born, KORWAN'
        WRITE(iout,*)
        WRITE(iout,'(1X,F17.8, 4H  +-, F17.8, 1X, A30)')
     $       xsecsa3,xerrsa3,'SemiAnal O(alf3)exp.LL, KORWAN'
        WRITE(iout,*)
      ENDIF
* Koralw
      call KW_GetNevMC (nvtru)
      WRITE(iout,'(1X,A40,I20)')
     $     'Total generated events                   ', NVTRU
      WRITE(iout,'(1X,A40,I20)')
     $     '- amongst which, overweighted            ', NEVOVRWGT
      WRITE(iout,'(1X,A40,I20)')
     $     '- amongst which, with negative weight    ', NEVNEGWGT
      WRITE(iout,*)
      WRITE(iout,'(1X,A40,I20)')
     $     'Tot #evts generated by Koralw            ', nphspace(1)
      WRITE(iout,'(1X,A40,I20)')
     $     'Tot #evts gen. with non-zero ISR weight  ', nphspace(2)
      WRITE(iout,'(1X,A40,I20)')
     $     'Tot #evts gen. within phys. phase space  ', nphspace(3)
      WRITE(iout,*)
      WRITE(iout,'(1X,A40,I20)')
     $     'Tot #evts input to KW selection          ', nselecto(1)
      WRITE(iout,'(1X,A40,I20)')
     $     'Tot #evts input to KW selection, wgt>0   ', nselecto(2)
      WRITE(iout,'(1X,A40,I20)')
     $     'Tot #evts accepted by KW sel (LAB)       ', nselecto(3)
      WRITE(iout,'(1X,A40,I20)')
     $     'Tot #evts accepted by KW sel (LAB&CMS)   ', nselecto(4)
      WRITE(iout,*)
      WRITE(iout,'(1X,A40,I20)')
     $     'Tot #evts input to user selection        ', nkwctot(1)
      WRITE(iout,'(1X,A40,I20)')
     $     'Tot #evts input to user selection, wgt>0 ', nkwctot(2)
      WRITE(iout,'(1X,A40,I20)')
     $     '- rejected by GCWW cuts                  ', nkwctww
      WRITE(iout,'(1X,A40,I20)')
     $     '- rejected by GCZZ cuts                  ', nkwctzz
      WRITE(iout,'(1X,A40,I20)')
     $     '- rejected by GCE1 cuts                  ', nkwcte1
      WRITE(iout,'(1X,A40,I20)')
     $     '- rejected by GCE2 cuts                  ', nkwcte2
      WRITE(iout,'(1X,A40,I20)')
     $     '- rejected by GCUU cuts                  ', nkwctuu
      WRITE(iout,'(1X,A40,I20)')
     $     '- rejected by GCEE cuts                  ', nkwctee
      WRITE(iout,'(1X,A40,I20)')
     $     '- rejected by GPT2 cuts                  ', nkwctpt
      WRITE(iout,'(1X,A40,I20)')
     $     'Tot #evts accepted by user selection     ', nkwctot(3)
      WRITE(iout,*)
      WRITE(iout,'(1X,A40,I20)')
     $     'Tot #evts accepted by both KW and user   ', nphspace(4)
      WRITE(iout,'(1X,A40,I20)')
     $     'Tot #evts acc. within phys. phase space  ', nphspace(5)
      WRITE(iout,*)
      call KW_GetXsecNR(xsecnr,xerrnr)
      call KW_GetXsecMC(xsecmc,xerrmc)
      WRITE(iout,*) ' because of too low hadronic masses,',
     $ ' 4f x-sections to be multiplied by ',
     $   float(nevent(2))/float(nevent(1))
      WRITE(iout,'(1X,f17.8, 4H  +-, f17.8, 1X, A30, 4H <<<)')
     $     xsecnr, xerrnr, 'MC Normalization KORALW'
      WRITE(iout,*) xsecnr*float(nevent(2))/float(nevent(1)),' MC corr'
      WRITE(iout,'(1X,f17.8, 4H  +-, f17.8, 1X, A30, 4H <<<)')
     $     xsecmc, xerrmc, 'MC Best KORALW'
      WRITE(iout,*) xsecmc*float(nevent(2))/float(nevent(1)),' MC corr'
      WRITE(iout,*)
      WRITE(iout,'(A60)') '========== KRLW03: End X-sections =========='
      WRITE(iout,*)
C
C Create cross section banks
C
      CALL ugtsec
C
C Monitor the xsections for accepted Kingal events only
C
      CALL xsecmon(1)
C
C Byebye
C
      CALL getenv('HOST',chhost)
      CALL getenv('OS',chos)
      CALL datime(idate,itime)
      WRITE (iout,'(1x,a,1x,i6,1x,i4)') 
     &     'Execution on '//chhost(1:lnblnk(chhost))
     &     //' under '//chos(1:lnblnk(chos))//' ending on '
     &     //'[yymmdd] [hhmm]', idate, itime
      WRITE (iout,*)
     &     '_USCJOB Bye-bye by KRLW03!'
      RETURN
      END

************************************************************************

      SUBROUTINE ugtsec
      IMPLICIT none
C --------------------------------------------------------------------
C B.Bloch   Nov.  2000   Create x-section bank KSEC for KRLW02
C B.Bloch   March 2001   Add CC03 x-section when in 4f mode
C A.Valassi June  2001   Adapt to KRLW03
C This routine is called before KW_finalize: cannot use KW_GetXsec
C -> use gmonit routines instead
C This routine is called more than once: be sure not to modify counters!
C For each row the IVER value contains the type of cross section :
C Row 1 contains always BEST, with program version as IVERS
C               Koralw best IVERS = 1532
C Next rows contains possibly: 
C               Koralw CC03 IVERS = 50
C               Grace  4f   IVERS = 51
C               Grace  CC03 IVERS = 150
C               Grace  NC02 IVERS = 152
C --------------------------------------------------------------------
c Generator info
      INTEGER igco, iver
      PARAMETER ( IGCO = 5038 )
      PARAMETER ( IVER = 1532 )
C Input/output units
      INTEGER          inut, iout
      COMMON / INOUT / INUT, IOUT
c KORALW switches
      INCLUDE 'KW.h'
c Kingal common block
      REAL*4  VRTEX, SDVRT, XVRT, SXVRT, ECMI
      INTEGER NEVENT, IFVRT
      COMMON / KGCOMM / 
     &     VRTEX(4), SDVRT(3), XVRT(3), SXVRT(3), ECMI, 
     &     NEVENT(9), IFVRT
c Crude xsection from KORALW
      DOUBLE PRECISION xcrude, xcvesk, dumm1 
c Weight histograms from KORALW and GLIB
      DOUBLE PRECISION averwt, errela, evtot
      DOUBLE PRECISION xsecbst, xerrbst   ! Best
      DOUBLE PRECISION xsec4f,  xerr4f    ! 4f
      DOUBLE PRECISION xsecWW,  xerrWW    ! CC3 (internal matrix el.)
      DOUBLE PRECISION xsecCC3, xerrCC3   ! CC3 (Grace matrix el.)
      DOUBLE PRECISION xsecNC2, xerrNC2   ! NC2
c Store into the KPAR bank
      INTEGER ivers
      INTEGER ksecbk, isec
      INTEGER ntot, nacc
      REAL    xtot, xacc
      REAL    rtot, racc      
C
C Get the crude xsection first, needed for all normalisations
C
      CALL karlud(1,xcrude,xcvesk,dumm1)
C
C Now get the average weights and compute the cross sections
C
      CALL gmonit(1,idyfs+80,averwt,errela,evtot)
      xsecbst = xcrude*averwt
      xerrbst = xsecbst*errela
      IF ( m_key4f .NE. 0 ) THEN
        CALL gmonit(1,idyfs+92,averwt,errela,evtot) ! best 4f
        xsec4f  = xcrude*averwt
        xerr4f  = xsec4f*errela
        CALL gmonit(1,idyfs+93,averwt,errela,evtot) ! internal CC3
        xsecww  = xcrude*averwt
        xerrww  = xsecww*errela
        CALL gmonit(1,idyfs+95,averwt,errela,evtot) ! Grace CC3
        xseccc3 = xcrude*averwt
        xerrcc3 = xseccc3*errela
        CALL gmonit(1,idyfs+94,averwt,errela,evtot) ! Grace NC2
        xsecnc2 = xcrude*averwt
        xerrnc2 = xsecnc2*errela
      ENDIF
C
C Get the number of Kingal events generated so far
C Unweighted and weighted KORALW events:
C -  ntot is the number of events within the acceptance
C -  nacc is the number of these written to file
C -  ntot-nacc are the events with problems or weight=0
C => USE NTOT TO NORMALISE THE ANALYSIS!!!
C (This is because crude xsec is normalised before Kingal rejection)
C In both unweighted and weighted events, KORALW may generate more events 
C than ntot, but these have weight=0 if they are outside the acceptance.
C In unweighted events, KORALW generates many more events that are within
C the acceptance but are randomly rejected to produce weight=1 events.
C
      ntot = NEVENT(1)          ! #evts within the acceptance
      nacc = NEVENT(2)          ! #evts on file (no problems and wt>0)
C
C Fill the KSEC bank
C
* Row 1 = best xsection
      XTOT  = xsecbst/1000.     ! must be in nb
      RTOT  = xerrbst/1000.     ! must be in nb
      XACC  = XTOT*float(nacc)/float(ntot)
      RACC  = RTOT*float(nacc)/float(ntot)
      ISEC  = KSECBK(1,IGCO,IVER,NTOT,NACC,XTOT,RTOT,XACC,RACC)
      IF ( m_key4f .NE. 0 ) THEN
* Row 2 = CC3 xsection
        XTOT  = xsecww/1000.    ! must be in nb
        RTOT  = xerrww/1000.    ! must be in nb
        XACC  = XTOT
        RACC  = RTOT
        IVERS = 50
        ISEC  = KSECBK(2,IGCO,IVERS,NTOT,NACC,XTOT,RTOT,XACC,RACC)
* Row 3 = 4f xsection
        XTOT  = xsecbst/1000.   ! must be in nb
        RTOT  = xerrbst/1000.   ! must be in nb
        XACC  = XTOT*float(nacc)/float(ntot)
        RACC  = RTOT*float(nacc)/float(ntot)
        IVERS = 51
        ISEC  = KSECBK(3,IGCO,IVERS,NTOT,NACC,XTOT,RTOT,XACC,RACC)
* Row 4 = CC3 xsection (Grace matrix element)
        XTOT  = xseccc3/1000.   ! must be in nb
        RTOT  = xerrcc3/1000.   ! must be in nb
        XACC  = XTOT
        RACC  = RTOT
        IVERS = 150
        ISEC  = KSECBK(4,IGCO,IVERS,NTOT,NACC,XTOT,RTOT,XACC,RACC)
* Row 5 = NC2 xsection (Grace matrix element)
        XTOT  = xsecnc2/1000.   ! must be in nb
        RTOT  = xerrnc2/1000.   ! must be in nb
        XACC  = XTOT
        RACC  = RTOT
        IVERS = 152
        ISEC  = KSECBK(5,IGCO,IVERS,NTOT,NACC,XTOT,RTOT,XACC,RACC)
      ENDIF
C
C Dump cross sections
C
      WRITE(iout,*)
     &     '=====================================',
     &     '====================================='
      WRITE(iout,*)
     &     ' Various x-sections within cuts      '
      WRITE(iout,*)
     &     '=====================================',
     &     '====================================='
 123  FORMAT(a38, f14.7, a4, f14.7, a3)
      WRITE (iout,123)
     &     ' BEST total x-section:               ',
     &     xsecbst,  ' +- ', xerrbst, ' pb'
      WRITE(iout,*)
     &     '=====================================',
     &     '====================================='
      IF ( m_key4f .NE. 0 ) THEN
        WRITE (iout,123)
     &       ' Total  4f x-section (Grace 4f):     ',
     &       xsec4f, ' +- ', xerr4f,   ' pb'
        WRITE (iout,123)
     &       ' Total CC3 x-section (internal CC3): ',
     &       xsecWW, ' +- ', xerrWW,   ' pb'
        WRITE(iout,*)
     &       '=====================================',
     &       '====================================='
        WRITE (iout,123)
     &       ' Total CC3 x-section (Grace CC3):    ',
     &       xsecCC3, ' +- ', xerrCC3, ' pb'
        WRITE (iout,123)
     &       ' Total NC2 x-section (Grace NC2):    ',
     &       xsecNC2, ' +- ', xerrNC2, ' pb'
        WRITE(iout,*)
     &       '=====================================',
     &       '====================================='
      ENDIF
C
C Print the KSEC bank
C
      CALL PRTABL('KSEC',0)
C Return
      RETURN
      END
      SUBROUTINE seluser(iok)
C---------------------------------------------------
C   possible selection from user , iok=0 keep event
C---------------------------------------------------
      LOGICAL           xgcww, xgczz, xgce1, xgce2, xgcuu, xgcee,xgcpt
     &                 ,xgcel
      COMMON / KWCUTS / xgcww, xgczz, xgce1, xgce2, xgcuu, xgcee,xgcpt !cav
     &                 ,xgcel
      REAL *4           ctmax,elmax
      COMMON / KWCTEL / ctmax,elmax

      INTEGER LJNPAR
      INTEGER L1MST, L1PAR
      INTEGER L2PAR, L2PARF
      PARAMETER (LJNPAR=4000)
      PARAMETER (L1MST=200, L1PAR=200)
      PARAMETER (L2PAR=500, L2PARF=2000 )
      INTEGER N7LU, K7LU
      REAL    P7LU, V7LU
      INTEGER MSTU, MSTJ
      REAL    PARU, PARJ
      INTEGER KCHG
      REAL    PMAS, PARF, VCKM
      COMMON /LUJETS/ N7LU,K7LU(LJNPAR,5),P7LU(LJNPAR,5),V7LU(LJNPAR,5)
      COMMON /LUDAT1/ MSTU(L1MST),PARU(L1PAR),MSTJ(L1MST),PARJ(L1PAR)
      COMMON /LUDAT2/ KCHG(L2PAR,3),PMAS(L2PAR,4),PARF(L2PARF),VCKM(4,4)
C      parameter ( costm=0.9781476)   !   cos(12 degrees)
C      parameter ( costm=0.984808)   !   cos(10 degrees)
C      parameter ( emin=3.0)          !   minimum 3 gev
      if (.not.xgcel) return
      iok = 1
      do it = 1,n7lu
C  ask for at least one electron(positron) within [12,168] degrees and 3 GeV
         ityp = K7LU(it,2)
         ista = K7LU(it,1)
         if ( ista.eq.1 .and. abs(ityp).eq.11 ) then
C             print *,' found lepton position ',it
             if (abs(P7LU(it,3))/PLU(it,8).le. ctmax) then
C             if (PLU(it,14).ge.12. .and. PLU(it,14).le.168.) then
C             print *,' found lepton right angle',it
                 if( P7LU(it,4).gt.elmax) iok = 0
                 if ( iok.eq.0)go to 10
             endif
         endif
      enddo
 10   continue
C         if ( iok.eq.0) print *,' found lepton right energy',it
C         call lulist(1)
      return
      end
************************************************************************

      SUBROUTINE user_selecto(p1,p2,p3,p4,qeff1,qeff2,wt)
* #################################################
* #        mask on phase space regions            #
* #         to be modified by the user            #
* #################################################
      IMPLICIT none
      DOUBLE PRECISION p1(4),p2(4),p3(4),p4(4),qeff1(4),qeff2(4),wt
c
c A.Valassi  June 2001        New version for KRLW03
c - Koralw1.52 has better presamplers than Koralw1.21, with built-in cuts
c   ==> RECOMMENDED FOR PRODUCTION: NO USER CUTS!!!
c - Default cuts by authors are in "selecto" (not to be modified!)
c - User routine is now called "user_selecto"
c - Split WW and ZZ cuts to avoid confusion in fermion indices
c   (this was not necessary in KRLW02 which had only WW-like final states)
c A.Valassi  June-July 1996   Previous version for KRLW02
c - Only one routine ("selecto") implements user cuts (no default cuts)
c B.Bloch may 2002 : add an extra cut for cost range of the second electron
c   in GCE1 card to allow to select e v e v events with one lepton at low
c   angle ( Wev like) and the other within some detector acceptance
C   new card GPT2 to generate events with Sumpt^2 between
C   min and max , and associated common 
c Input:
c   p1, p2, p3, p4 -> 4-momenta of 4 final state fermions
c   qeff1, qeff2   -> effective 4-mom. of initial state e+/e- after ISR
c   wt             -> Current weight (not equal to 0)
c   /DECAYS/       -> Final state flavours and masses via common
c Output:
c   wt             -> Weight = 0 if event outside allowed phase space
c Cut-specific input:
c   /KWCUTS/       -> Cuts via common
c   /KWCTWW/       -> Cuts via common
c   /KWCTZZ/       -> Cuts via common
c   /KWCTE1/       -> Cuts via common
c   /KWCTE2/       -> Cuts via common
c   /KWCTUU/       -> Cuts via common
c   /KWCTEE/       -> Cuts via common
c   /KWCTPT/       -> Cuts via common
c Statistics input/output:
c   /USLCTO/       -> Cuts rejection statistics
c Remark: cuts are in single precision. Protection added on cos(theta).
c
c Cut description:
c 1. (COMMON/KWCTWW/) -> "WW-like events"
c    => Cuts adapted from /KWCTE0/ cuts in previous KRLW02 interface
c       Applied to WW-like (including ZZ overlap), regardless of flavour.
c 2. (COMMON/KWCTZZ/) -> "ZZ-like events"
c    => Same cuts as /KWCTWW/, with different fermion indices
c       Applied to ZZ-like (including WW overlap), regardless of flavour.
c 3. (COMMON/KWCTE1/) -> "WW-like with 1 or more electrons"
c    => Cuts on final state electron/positron theta in e-nu-x-x events.
c       Useful to remove high-weight singleW-like e-nu-x-x events with
c       e+- lost along the beam pipe (mainly t-channel photon exchange).
c       Also applied to e+nue~e-nue events.
c 4. (COMMON/KWCTE2/) -> "WW-like with 2 electrons"
c    => Cuts on final state electron and positron in e+nue~e-nue events.
c       Useful to remove high-weight 4f singularities in e+nue~e-nue events
c       with low-energy, low-mass, low-Pt e+- pairs from photon bremsstr.
c 5. (COMMON/KWCTUU/) -> "WW-like with two u quarks"
c    => Cuts on uudd final states.
c       Useful to remove high-weight 4f singularities in udud events with
c       low-mass uu or dd pairs from photon brehmsstrahlung.
c 6. (COMMON/KWCTEE/) -> "non-WW-like with 2 electrons"
c    => Cuts on e+e-x+x- events (excluding e+nue~e-nue!).
c       Useful to remove high-weight 4f singularities in e+e-x+x- events
c       with low-energy, low-mass, low-Pt e+- pairs from photon bremsstr.
c       modified BBL June 2002 to apply signal definition on Zee
c 7. (COMMON/KWCTPT/) -> "any events"
c    => Cuts on sum of pt^2 of charged fermions. Used to generate events
c       in a [pt2min,pt2max] range
C       also complement with respect to mee^2 cut in [mee2min,mee2max]range 
c
      INTEGER iflav(4)
      DOUBLE PRECISION amdec(4)
      COMMON / DECAYS / IFLAV, AMDEC
      DOUBLE PRECISION  qadra, angle, qnorm 
      LOGICAL           xgcww, xgczz, xgce1, xgce2, xgcuu, xgcee,xgcpt
      LOGICAL           xgcel
      COMMON / KWCUTS / xgcww, xgczz, xgce1, xgce2, xgcuu, xgcee,xgcpt !cav
     &                 ,xgcel
      REAL*4            spminww,  spmaxww,
     &                  e1minww,  e2minww,  e3minww,  e4minww,
     &                  e1maxww,  e2maxww,  e3maxww,  e4maxww,
     &                  s12minww, s13minww, s14minww, 
     &                  s23minww, s24minww, s34minww,
     &                  s12maxww, s13maxww, s14maxww, 
     &                  s23maxww, s24maxww, s34maxww,
     &                  c1minww,  c2minww,  c3minww,  c4minww,
     &                  c1maxww,  c2maxww,  c3maxww,  c4maxww,
     &                  c12minww, c13minww, c14minww, 
     &                  c23minww, c24minww, c34minww,
     &                  c12maxww, c13maxww, c14maxww, 
     &                  c23maxww, c24maxww, c34maxww
      COMMON / KWCTWW / spminww,  spmaxww,                             !cav
     &                  e1minww,  e2minww,  e3minww,  e4minww,
     &                  e1maxww,  e2maxww,  e3maxww,  e4maxww,
     &                  s12minww, s13minww, s14minww, 
     &                  s23minww, s24minww, s34minww,
     &                  s12maxww, s13maxww, s14maxww, 
     &                  s23maxww, s24maxww, s34maxww,
     &                  c1minww,  c2minww,  c3minww,  c4minww,
     &                  c1maxww,  c2maxww,  c3maxww,  c4maxww,
     &                  c12minww, c13minww, c14minww, 
     &                  c23minww, c24minww, c34minww,
     &                  c12maxww, c13maxww, c14maxww, 
     &                  c23maxww, c24maxww, c34maxww
      REAL*4            spminzz,  spmaxzz,
     &                  e1minzz,  e2minzz,  e3minzz,  e4minzz,
     &                  e1maxzz,  e2maxzz,  e3maxzz,  e4maxzz,
     &                  s12minzz, s13minzz, s14minzz, 
     &                  s23minzz, s24minzz, s34minzz,
     &                  s12maxzz, s13maxzz, s14maxzz, 
     &                  s23maxzz, s24maxzz, s34maxzz,
     &                  c1minzz,  c2minzz,  c3minzz,  c4minzz,
     &                  c1maxzz,  c2maxzz,  c3maxzz,  c4maxzz,
     &                  c12minzz, c13minzz, c14minzz, 
     &                  c23minzz, c24minzz, c34minzz,
     &                  c12maxzz, c13maxzz, c14maxzz, 
     &                  c23maxzz, c24maxzz, c34maxzz
      COMMON / KWCTZZ / spminzz,  spmaxzz,                             !cav
     &                  e1minzz,  e2minzz,  e3minzz,  e4minzz,
     &                  e1maxzz,  e2maxzz,  e3maxzz,  e4maxzz,
     &                  s12minzz, s13minzz, s14minzz, 
     &                  s23minzz, s24minzz, s34minzz,
     &                  s12maxzz, s13maxzz, s14maxzz, 
     &                  s23maxzz, s24maxzz, s34maxzz,
     &                  c1minzz,  c2minzz,  c3minzz,  c4minzz,
     &                  c1maxzz,  c2maxzz,  c3maxzz,  c4maxzz,
     &                  c12minzz, c13minzz, c14minzz, 
     &                  c23minzz, c24minzz, c34minzz,
     &                  c12maxzz, c13maxzz, c14maxzz, 
     &                  c23maxzz, c24maxzz, c34maxzz
CBB      REAL*4            cmaxem, cminem, cmaxep, cminep
CBB      COMMON / KWCTE1 / cmaxem, cminem, cmaxep, cminep                 !cav
      REAL*4            cmaxem, cminem, cmaxep, cminep,cmine,cmaxe 
      COMMON / KWCTE1 / cmaxem, cminem, cmaxep, cminep,cmine,cmaxe     ! bb
      REAL*4            eneme2, enepe2, scute2, ptsme2
      COMMON / KWCTE2 / eneme2, enepe2, scute2, ptsme2                 !cav
      REAL*4            spctuu, scutuu
      COMMON / KWCTUU / spctuu, scutuu                                 !cav
      REAL*4            eemminee, eepminee, efmminee, efpminee,
     &                  eemmaxee, eepmaxee, efmmaxee, efpmaxee,
     &                  seeminee, sffminee,
     &                  seemaxee, sffmaxee,
     &                  cemminee, cepminee, cfmminee, cfpminee,
     &                  cemmaxee, cepmaxee, cfmmaxee, cfpmaxee,
     &                  ceeminee, cffminee,
     &                  ceemaxee, cffmaxee,
     &                  eexminee, eexmaxee,
     &                  cexminee, cexmaxee
      COMMON / KWCTEE / eemminee, eepminee, efmminee, efpminee,         !cav
     &                  eemmaxee, eepmaxee, efmmaxee, efpmaxee,
     &                  seeminee, sffminee,
     &                  seemaxee, sffmaxee,
     &                  cemminee, cepminee, cfmminee, cfpminee,
     &                  cemmaxee, cepmaxee, cfmmaxee, cfpmaxee,
     &                  ceeminee, cffminee,
     &                  ceemaxee, cffmaxee,
     &                  eexminee, eexmaxee,
     &                  cexminee, cexmaxee
      INTEGER           nkwctot,    nkwctww, nkwctzz, 
     &                  nkwcte1,    nkwcte2, nkwctuu, nkwctee,nkwctpt
      COMMON / USLCTO / nkwctot(3), nkwctww, nkwctzz,                  !cav
     &                  nkwcte1,    nkwcte2, nkwctuu, nkwctee,nkwctpt  !cav
      REAL *4           pt2min,pt2max,ee2min,ee2max
      COMMON / KWCTPT / pt2min,pt2max,ee2min,ee2max
      REAL *4           ctmax,elmax
      COMMON / KWCTEL / ctmax,elmax
      INTEGER imu
      DOUBLE PRECISION p4mu(4,4)
      INTEGER isww, iszz, i4ww(4), i4zz(4)
      DOUBLE PRECISION p1ww(4),p2ww(4),p3ww(4),p4ww(4)
      DOUBLE PRECISION p1zz(4),p2zz(4),p3zz(4),p4zz(4)
      LOGICAL xeeee
      DOUBLE PRECISION p1ee(4),p2ee(4),p3ee(4),p4ee(4)
C KINGAL Common block KGCOMM
      REAL*4  VRTEX, SDVRT, XVRT, SXVRT, ECMI
      INTEGER NEVENT, IFVRT
      COMMON / KGCOMM / 
     &     VRTEX(4), SDVRT(3), XVRT(3), SXVRT(3), ECMI, 
     &     NEVENT(9), IFVRT
      REAL*8 arbitr,themin,angarb,pt2,em12,em34,em14,em23
C Debug 
      INTEGER iacc,iel,iee
      DOUBLE PRECISION wt1,wt2,wt3,wt4,wtee,wtpt
      real*4 ct1,dum,XMINV,ct2
      DATA iacc/0/
      SAVE iacc
c
      nkwctot(1) = nkwctot(1)+1
      if (wt.eq.0d0) return
      nkwctot(2) = nkwctot(2)+1
c
c A.Valassi June 2001
c When generating inclusive final states (all W, all Z), the ordering 
c of fermion indices is determined by umaskww and umaskzz: the default 
c masks hardcoded in this program uses WW indexing for all events that 
c can be both WW-like and ZZ-like (except double CKM non-diagonal, usus, 
c ubub, cdcd, cbcb, treated as ZZ only - CKM is diagonal in Grace!)
c However, when generating exclusive ZZ final states (that can be WW
c overlaps) the order is fixed to ZZ-like: WW cuts would not be applied
c correctly in that case, if WW ordering is assumed.
c => To avoid any confusion, explicitly check the WW/ZZ/overlap hypotheses!!!
c
      DO imu = 1, 4
        p4mu(1,imu) = p1(imu)
        p4mu(2,imu) = p2(imu)
        p4mu(3,imu) = p3(imu)
        p4mu(4,imu) = p4(imu)
      END DO
      CALL WWORZZ(iflav, isww, iszz, i4ww, i4zz)
      IF ( mod( nevent(2)+1, 10**INT(log(1.*nevent(2)+1)/log(10.)) 
     &     ).EQ.0 ) THEN
        IF (iacc.NE.nevent(1)) THEN
          PRINT *, '_USER_SELECTO iflav(4), isww, iszz:', 
     &         iflav, isww, iszz
          PRINT *, '_USER_SELECTO i4ww, i4zz:', i4ww, i4zz
          iacc = nevent(1)
        ENDIF
      ENDIF      
c
c 1. /KWCTWW/ cuts
c ----------------
c Cuts only apply to WW-like events (including the ZZ overlap)
c
      if (xgcww) then
c
        if ( isww.GT.0 ) then   ! this is compatible to a WW final state
          do imu = 1, 4
            p1ww(imu) = p4mu(i4ww(1),imu) !     ferm from W-/Z1 (    quark d)
            p2ww(imu) = p4mu(i4ww(2),imu) ! antiferm from W-/Z2 (antiquark u)
            p3ww(imu) = p4mu(i4ww(3),imu) !     ferm from W+/Z2 (    quark u)
            p4ww(imu) = p4mu(i4ww(4),imu) ! antiferm from W+/Z1 (antiquark d)
          end do          
        else
          goto 10
        endif
c
c Cut on min/max sqrt(s') - invariant mass of beam e+e- after ISR
c
        if (qadra(qeff1,qeff2).lt.spminww**2) wt=0d0
        if (qadra(qeff1,qeff2).gt.spmaxww**2 .and. spmaxww.gt.0
     &       ) wt=0d0
c
c Cuts on min/max fermion energies
c
        if (p1ww(4).lt.e1minww) wt=0d0
        if (p2ww(4).lt.e2minww) wt=0d0
        if (p3ww(4).lt.e3minww) wt=0d0
        if (p4ww(4).lt.e4minww) wt=0d0
c
        if (p1ww(4).gt.e1maxww .and. e1maxww.gt.0) wt=0d0
        if (p2ww(4).gt.e2maxww .and. e2maxww.gt.0) wt=0d0
        if (p3ww(4).gt.e3maxww .and. e3maxww.gt.0) wt=0d0
        if (p4ww(4).gt.e4maxww .and. e4maxww.gt.0) wt=0d0
c
c Cuts on min/max invariant masses of fermion pairs
c
        if (qadra(p1ww,p2ww).lt.s12minww**2) wt=0d0
        if (qadra(p1ww,p3ww).lt.s13minww**2) wt=0d0
        if (qadra(p1ww,p4ww).lt.s14minww**2) wt=0d0
        if (qadra(p2ww,p3ww).lt.s23minww**2) wt=0d0
        if (qadra(p2ww,p4ww).lt.s24minww**2) wt=0d0
        if (qadra(p3ww,p4ww).lt.s34minww**2) wt=0d0
c
        if (qadra(p1ww,p2ww).gt.s12maxww**2 .and. s12maxww.gt.0 
     &       ) wt=0d0
        if (qadra(p1ww,p3ww).gt.s13maxww**2 .and. s13maxww.gt.0 
     &       ) wt=0d0
        if (qadra(p1ww,p4ww).gt.s14maxww**2 .and. s14maxww.gt.0 
     &       ) wt=0d0
        if (qadra(p2ww,p3ww).gt.s23maxww**2 .and. s23maxww.gt.0 
     &       ) wt=0d0
        if (qadra(p2ww,p4ww).gt.s24maxww**2 .and. s24maxww.gt.0 
     &       ) wt=0d0
        if (qadra(p3ww,p4ww).gt.s34maxww**2 .and. s34maxww.gt.0 
     &       ) wt=0d0
c
c Cuts on min/max cos-theta of outgoing fermions (w.r.t. beam axis)
c
        if (c1minww.gt.-1 .and. p1ww(3).lt.qnorm(p1ww)*c1minww ) 
     &       wt=0d0
        if (c2minww.gt.-1 .and. p2ww(3).lt.qnorm(p2ww)*c2minww ) 
     &       wt=0d0
        if (c3minww.gt.-1 .and. p3ww(3).lt.qnorm(p3ww)*c3minww ) 
     &       wt=0d0
        if (c4minww.gt.-1 .and. p4ww(3).lt.qnorm(p4ww)*c4minww ) 
     &       wt=0d0
c
        if (c1maxww.lt.+1 .and. p1ww(3).gt.qnorm(p1ww)*c1maxww ) 
     &       wt=0d0
        if (c2maxww.lt.+1 .and. p2ww(3).gt.qnorm(p2ww)*c2maxww ) 
     &       wt=0d0
        if (c3maxww.lt.+1 .and. p3ww(3).gt.qnorm(p3ww)*c3maxww ) 
     &       wt=0d0
        if (c4maxww.lt.+1 .and. p4ww(3).gt.qnorm(p4ww)*c4maxww ) 
     &       wt=0d0
c
c Cuts on min/max cos-theta between outgoing fermions
c
        if (c12minww.gt.-1.and.cos(angle(p1ww,p2ww)).lt.c12minww) 
     &       wt=0d0
        if (c13minww.gt.-1.and.cos(angle(p1ww,p3ww)).lt.c13minww) 
     &       wt=0d0
        if (c14minww.gt.-1.and.cos(angle(p1ww,p4ww)).lt.c14minww) 
     &       wt=0d0
        if (c23minww.gt.-1.and.cos(angle(p2ww,p3ww)).lt.c23minww) 
     &       wt=0d0
        if (c24minww.gt.-1.and.cos(angle(p2ww,p4ww)).lt.c24minww) 
     &       wt=0d0
        if (c34minww.gt.-1.and.cos(angle(p3ww,p4ww)).lt.c34minww) 
     &       wt=0d0
c
        if (c12maxww.lt.+1.and.cos(angle(p1ww,p2ww)).gt.c12maxww) 
     &       wt=0d0
        if (c13maxww.lt.+1.and.cos(angle(p1ww,p3ww)).gt.c13maxww) 
     &       wt=0d0
        if (c14maxww.lt.+1.and.cos(angle(p1ww,p4ww)).gt.c14maxww) 
     &       wt=0d0
        if (c23maxww.lt.+1.and.cos(angle(p2ww,p3ww)).gt.c23maxww) 
     &       wt=0d0
        if (c24maxww.lt.+1.and.cos(angle(p2ww,p4ww)).gt.c24maxww) 
     &       wt=0d0
        if (c34maxww.lt.+1.and.cos(angle(p3ww,p4ww)).gt.c34maxww) 
     &       wt=0d0
c
        if (wt.eq.0d0) then
          nkwctww=nkwctww+1
*         print *, '_USER_SELECTO Event rejected by GCWW'
          return
        endif
      endif
 10   CONTINUE
c
c 2. /KWCTZZ/ cuts
c ----------------
c Cuts only apply to ZZ-like events (including the WW overlap)
c
      if (xgczz) then
c
        if ( iszz.GT.0 ) then   ! this is compatible to a ZZ final state
          do imu = 1, 4
            p1zz(imu) = p4mu(i4zz(1),imu) !     ferm from Z1/W1 (    quark d)
            p2zz(imu) = p4mu(i4zz(2),imu) ! antiferm from Z1/W2 (antiquark d)
            p3zz(imu) = p4mu(i4zz(3),imu) !     ferm from Z2/W2 (    quark u)
            p4zz(imu) = p4mu(i4zz(4),imu) ! antiferm from Z2/W1 (antiquark u)
          end do          
        else
          goto 20
        endif
c
c Cut on min/max sqrt(s') - invariant mass of beam e+e- after ISR
c
*       PRINT *, '00 wt =', wt
        if (qadra(qeff1,qeff2).lt.spminzz**2) wt=0d0
        if (qadra(qeff1,qeff2).gt.spmaxzz**2 .and. spmaxzz.gt.0
     &       ) wt=0d0
c
c Cuts on min/max fermion energies
c
*       PRINT *, '10 wt =', wt
        if (p1zz(4).lt.e1minzz) wt=0d0
        if (p2zz(4).lt.e2minzz) wt=0d0
        if (p3zz(4).lt.e3minzz) wt=0d0
        if (p4zz(4).lt.e4minzz) wt=0d0
c
        if (p1zz(4).gt.e1maxzz .and. e1maxzz.gt.0) wt=0d0
        if (p2zz(4).gt.e2maxzz .and. e2maxzz.gt.0) wt=0d0
        if (p3zz(4).gt.e3maxzz .and. e3maxzz.gt.0) wt=0d0
        if (p4zz(4).gt.e4maxzz .and. e4maxzz.gt.0) wt=0d0
c
c Cuts on min/max invariant masses of fermion pairs
c
*       PRINT *, '20 wt =', wt
        if (qadra(p1zz,p2zz).lt.s12minzz**2) wt=0d0
        if (qadra(p1zz,p3zz).lt.s13minzz**2) wt=0d0
        if (qadra(p1zz,p4zz).lt.s14minzz**2) wt=0d0
        if (qadra(p2zz,p3zz).lt.s23minzz**2) wt=0d0
        if (qadra(p2zz,p4zz).lt.s24minzz**2) wt=0d0
        if (qadra(p3zz,p4zz).lt.s34minzz**2) wt=0d0
c
        if (qadra(p1zz,p2zz).gt.s12maxzz**2 .and. s12maxzz.gt.0 
     &       ) wt=0d0
        if (qadra(p1zz,p3zz).gt.s13maxzz**2 .and. s13maxzz.gt.0 
     &       ) wt=0d0
        if (qadra(p1zz,p4zz).gt.s14maxzz**2 .and. s14maxzz.gt.0 
     &       ) wt=0d0
        if (qadra(p2zz,p3zz).gt.s23maxzz**2 .and. s23maxzz.gt.0 
     &       ) wt=0d0
        if (qadra(p2zz,p4zz).gt.s24maxzz**2 .and. s24maxzz.gt.0 
     &       ) wt=0d0
        if (qadra(p3zz,p4zz).gt.s34maxzz**2 .and. s34maxzz.gt.0 
     &       ) wt=0d0
c
c Cuts on min/max cos-theta of outgoing fermions (w.r.t. beam axis)
c
*       PRINT *, '30 wt =', wt
        if (c1minzz.gt.-1 .and. p1zz(3).lt.qnorm(p1zz)*c1minzz ) 
     &       wt=0d0
        if (c2minzz.gt.-1 .and. p2zz(3).lt.qnorm(p2zz)*c2minzz ) 
     &       wt=0d0
        if (c3minzz.gt.-1 .and. p3zz(3).lt.qnorm(p3zz)*c3minzz ) 
     &       wt=0d0
        if (c4minzz.gt.-1 .and. p4zz(3).lt.qnorm(p4zz)*c4minzz ) 
     &       wt=0d0
c
        if (c1maxzz.lt.+1 .and. p1zz(3).gt.qnorm(p1zz)*c1maxzz ) 
     &       wt=0d0
        if (c2maxzz.lt.+1 .and. p2zz(3).gt.qnorm(p2zz)*c2maxzz ) 
     &       wt=0d0
        if (c3maxzz.lt.+1 .and. p3zz(3).gt.qnorm(p3zz)*c3maxzz ) 
     &       wt=0d0
        if (c4maxzz.lt.+1 .and. p4zz(3).gt.qnorm(p4zz)*c4maxzz ) 
     &       wt=0d0
c
c Cuts on min/max cos-theta between outgoing fermions
c
*       PRINT *, '40 wt =', wt
        if (c12minzz.gt.-1.and.cos(angle(p1zz,p2zz)).lt.c12minzz) 
     &       wt=0d0
        if (c13minzz.gt.-1.and.cos(angle(p1zz,p3zz)).lt.c13minzz) 
     &       wt=0d0
        if (c14minzz.gt.-1.and.cos(angle(p1zz,p4zz)).lt.c14minzz) 
     &       wt=0d0
        if (c23minzz.gt.-1.and.cos(angle(p2zz,p3zz)).lt.c23minzz) 
     &       wt=0d0
        if (c24minzz.gt.-1.and.cos(angle(p2zz,p4zz)).lt.c24minzz) 
     &       wt=0d0
        if (c34minzz.gt.-1.and.cos(angle(p3zz,p4zz)).lt.c34minzz) 
     &       wt=0d0
c
        if (c12maxzz.lt.+1.and.cos(angle(p1zz,p2zz)).gt.c12maxzz) 
     &       wt=0d0
        if (c13maxzz.lt.+1.and.cos(angle(p1zz,p3zz)).gt.c13maxzz) 
     &       wt=0d0
        if (c14maxzz.lt.+1.and.cos(angle(p1zz,p4zz)).gt.c14maxzz) 
     &       wt=0d0
        if (c23maxzz.lt.+1.and.cos(angle(p2zz,p3zz)).gt.c23maxzz) 
     &       wt=0d0
        if (c24maxzz.lt.+1.and.cos(angle(p2zz,p4zz)).gt.c24maxzz) 
     &       wt=0d0
        if (c34maxzz.lt.+1.and.cos(angle(p3zz,p4zz)).gt.c34maxzz) 
     &       wt=0d0
c
*       PRINT *, '50 wt =', wt
        if (wt.eq.0d0) then
          nkwctzz=nkwctzz+1
*         print *, '_USER_SELECTO Event rejected by GCZZ'
          return
        endif
      endif
 20   CONTINUE
c
c 3. /KWCTE1/ cuts
c ----------------
c Cuts only apply to (xx)(e-nue) and (e+nue~)(xx) events
C These are events compatible with single-W production
c
      if (xgce1) then
        wt1 = 0d0
        wt2 = 0d0
        wt3 = 0d0
        wt4 = 0d0
        iel = 0
c
c Cuts on max and min cos-theta of outgoing electrons (w.r.t. beam axis)
c
        if (iflav(1).eq.11 .and. iflav(2).eq.-12) then
          wt1 = 1d0
          wt3 = 1d0
          iel = iel + 1
          if (cmaxem.lt.1e0 .and.
     $         p1(3) .gt. dsqrt(p1(1)**2+p1(2)**2+p1(3)**2) * cmaxem)
CBB     $         wt=0d0
     $         wt1=0d0
          if (cmaxe.lt.1e0 .and.
     $         p1(3) .gt. dsqrt(p1(1)**2+p1(2)**2+p1(3)**2) * cmaxe)
     $         wt3=0d0
          if (cminem.gt.-1e0 .and.
     $         p1(3) .lt. dsqrt(p1(1)**2+p1(2)**2+p1(3)**2) * cminem)
CBB     $         wt=0d0
     $         wt1=0d0
          if (cmine.gt.-1e0 .and.
     $         p1(3) .lt. dsqrt(p1(1)**2+p1(2)**2+p1(3)**2) * cmine)
     $         wt3=0d0
        endif
c
c Cuts on max and min cos-theta of outgoing positrons (w.r.t. beam axis)
c
        if (iflav(3).eq.12 .and. iflav(4).eq.-11) then
          wt2 = 1d0
          wt4 = 1d0
          iel = iel + 1
          if (cmaxep.lt.1e0 .and.
     $         p4(3) .gt. dsqrt(p4(1)**2+p4(2)**2+p4(3)**2) * cmaxep)
CBB     $         wt=0d0
     $         wt2=0d0
          if (cmaxe.lt.1e0 .and.
     $         p4(3) .gt. dsqrt(p4(1)**2+p4(2)**2+p4(3)**2) * cmaxe)
     $         wt4=0d0
          if (cminep.gt.-1e0 .and.
     $         p4(3) .lt. dsqrt(p4(1)**2+p4(2)**2+p4(3)**2) * cminep)
CBB     $         wt=0d0
     $         wt2=0d0
          if (cmine.gt.-1e0 .and.
     $         p4(3) .lt. dsqrt(p4(1)**2+p4(2)**2+p4(3)**2) * cmine)
     $         wt4=0d0
        endif
c
        if ( iel.eq.0) then
           wt = 0d0
        else if ( iel.eq.1) then
           if ( wt1.lt.1d0 .and.  wt2.lt.1d0) wt = 0d0
CBB           if (wt1.gt.0d0 .and. wt.gt.0d0) then
CBB              ct1 = p1(3)/sqrt(p1(1)**2+p1(2)**2+p1(3)**2)
CBB              call hfill(111,ct1,dum,1.)
CBB           endif
CBB           if (wt2.gt.0d0 .and. wt.gt.0d0) then
CBB              ct1 = p4(3)/sqrt(p4(1)**2+p4(2)**2+p4(3)**2)
CBB              call hfill(112,ct1,dum,1.)
CBB           endif
        else if ( iel.eq.2) then
           if ( wt1*wt4.lt.1d0 .and. wt2*wt3.lt.1d0) wt = 0d0
CBB           if (wt1.gt.0d0 .and. wt.gt.0d0) then
CBB              ct1 = p1(3)/sqrt(p1(1)**2+p1(2)**2+p1(3)**2)
CBB              call hfill(111,ct1,dum,1.)
CBB              ct1 = p4(3)/sqrt(p4(1)**2+p4(2)**2+p4(3)**2)
CBB              call hfill(211,ct1,dum,1.)
CBB           endif  
CBB           if (wt2.gt.0d0 .and. wt.gt.0d0) then
CBB              ct1 = p4(3)/sqrt(p4(1)**2+p4(2)**2+p4(3)**2)
CBB              call hfill(112,ct1,dum,1.)
CBB              ct1 = p1(3)/sqrt(p1(1)**2+p1(2)**2+p1(3)**2)
CBB              call hfill(212,ct1,dum,1.)
CBB           endif
        endif
c  
        if (wt.eq.0d0) then
          nkwcte1=nkwcte1+1
*         print *, '_USER_SELECTO Event rejected by GCE1'
          return
        endif
      endif
c
c 4. /KWCTE2/ cuts
c ----------------
c Cuts only apply to e+nue~e-nue events
c
      if (xgce2) then
        if ( iflav(1).eq.11 .and. iflav(2).eq.-12 .and.
     &       iflav(3).eq.12 .and. iflav(4).eq.-11) then
c
c Cuts on energies of e- and e+
c
          if (p1(4).lt.eneme2) wt=0d0
          if (p4(4).lt.enepe2) wt=0d0
c
c Cut on invariant mass of e-/e+ system
c
          if (qadra(p1,p4).lt.scute2**2) wt=0d0
c
c Cut on sum of |pT(e+)| and |pT(e-)|
c
          if ( dsqrt(p1(1)**2+p1(2)**2)+
     &         dsqrt(p4(1)**2+p4(2)**2).lt.ptsme2) wt=0d0
c
        endif
        if (wt.eq.0d0) then
          nkwcte2=nkwcte2+1
*         print *, '_USER_SELECTO Event rejected by GCE2'
          return
        endif
      endif
c
c 5. /KWCTUU/ cuts
c ----------------
c Cuts only apply to uudd final states
c
      if (xgcuu) then
        if ( iflav(1).eq.1 .and. iflav(2).eq.-2 .and.
     &       iflav(3).eq.2 .and. iflav(4).eq.-1       ) then
c
c Cut on invariant mass of uudd system after ISR (s') in udud events
c
          if (qadra(qeff1,qeff2).lt.spctuu**2) wt=0d0
c
c Cuts on invariant masses of uu and dd systems
c
          if (qadra(p1,p4).lt.scutuu**2) wt=0d0
          if (qadra(p2,p3).lt.scutuu**2) wt=0d0
c
        endif
        if (wt.eq.0d0) then
          nkwctuu=nkwctuu+1
*         print *, '_USER_SELECTO Event rejected by GCUU'
          return
        endif
      endif
c
c 6. /KWCTEE/ cuts
c ----------------
c Cuts only apply to e+e-xx (excluding e-nue~e+nue) events
c => NB For eeee events, apply ep/em (rather than fp/fm) cuts to both pairs
c => (and also take into account combinatorics!)
c
C  modified by B.Bloch to be able to apply Zee signal cuts definition :
C    minimum mass for the ffbar invariant mass M(mumu) or M(qqbar) > 60 Gev
C    theta(e-)<12 degrees and 12 degrees <theta(e+)< 120 degrees
C    and E(e+)>3 GeV for the e- lost in the beam-pipe
C or theta(e+)>168 deg. and 60 deg. < theta(e-) <168 deg.
C    and E(e-)>3 GeV for the e+ lost in the beam-pipe
C
      if (xgcee) then
        if (    iflav(1).eq.11 .and. iflav(2).eq.-11 ) then
          do imu = 1, 4
            p1ee(imu) = p1(imu)   ! e-
            p2ee(imu) = p2(imu)   ! e+
            p3ee(imu) = p3(imu)   ! fermion x
            p4ee(imu) = p4(imu)   ! antifermion x
          end do          
        elseif( iflav(3).eq.11 .and. iflav(4).eq.-11 ) then
          do imu = 1, 4
            p1ee(imu) = p3(imu)   ! e-
            p2ee(imu) = p4(imu)   ! e+
            p3ee(imu) = p1(imu)   ! fermion x
            p4ee(imu) = p2(imu)   ! antifermion x
          end do          
        else
          goto 60
        endif
        if ( (iflav(1).eq.11 .and. iflav(2).eq.-11) .and.
     &       (iflav(3).eq.11 .and. iflav(4).eq.-11) ) then
          xeeee = .true.
        else
          xeeee = .false.
        endif
        XMINV = SQRT(qadra(p3ee,p4ee))
        ct1 = real(p1ee(3)/qnorm(p1ee))         
        ct2 = real(p2ee(3)/qnorm(p2ee))
c
c Cuts on min/max energies
c
*       PRINT *, '10 wt =', wt
CBB         if (p1ee(4).lt.eemminee) wt=0d0
CBB         if (p2ee(4).lt.eepminee) wt=0d0
CBB         if (.not. xeeee) then
CBB           if (p3ee(4).lt.efmminee) wt=0d0
CBB           if (p4ee(4).lt.efpminee) wt=0d0
CBB         else
CBB           if (p3ee(4).lt.eemminee) wt=0d0
CBB           if (p4ee(4).lt.eepminee) wt=0d0
CBB         endif
c
*       PRINT *, '15 wt =', wt
CBB         if (p1ee(4).gt.eemmaxee .and. eemmaxee.gt.0) wt=0d0
CBB         if (p2ee(4).gt.eepmaxee .and. eepmaxee.gt.0) wt=0d0
CBB         if (.not. xeeee) then
CBB           if (p3ee(4).gt.efmmaxee .and. efmmaxee.gt.0) wt=0d0
CBB           if (p4ee(4).gt.efpmaxee .and. efpmaxee.gt.0) wt=0d0
CBB         else
CBB           if (p3ee(4).gt.eemmaxee .and. eemmaxee.gt.0) wt=0d0
CBB           if (p4ee(4).gt.eepmaxee .and. eepmaxee.gt.0) wt=0d0
CBB         endif
c
c Cuts on min/max invariant masses of fermion pairs
c
*       PRINT *, '20 wt =', wt
        if (qadra(p1ee,p2ee).lt.seeminee**2) wt=0d0
        if (.not. xeeee) then
          if (qadra(p3ee,p4ee).lt.sffminee**2) wt=0d0
        else
          if (qadra(p3ee,p4ee).lt.seeminee**2) wt=0d0
          if (qadra(p1ee,p4ee).lt.seeminee**2) wt=0d0
          if (qadra(p3ee,p2ee).lt.seeminee**2) wt=0d0
        endif
c
*       PRINT *, '25 wt =', wt
        if (qadra(p1ee,p2ee).gt.seemaxee**2 .and. seemaxee.gt.0 
     &       ) wt=0d0
        if (.not. xeeee) then
          if (qadra(p3ee,p4ee).gt.sffmaxee**2 .and. sffmaxee.gt.0 
     &         ) wt=0d0
        else
          if (qadra(p3ee,p4ee).gt.seemaxee**2 .and. seemaxee.gt.0 
     &         ) wt=0d0
          if (qadra(p1ee,p4ee).gt.seemaxee**2 .and. seemaxee.gt.0 
     &         ) wt=0d0
          if (qadra(p3ee,p2ee).gt.seemaxee**2 .and. seemaxee.gt.0 
     &         ) wt=0d0
        endif
c
c Cuts on max and min cos-theta of outgoing fermions (w.r.t. beam axis)
c
*       PRINT *, '30 wt =', wt
CBB         if (cemminee.gt.-1 .and. p1ee(3).lt.qnorm(p1ee)*cemminee ) 
CBB      &       wt=0d0
CBB         if (cepminee.gt.-1 .and. p2ee(3).lt.qnorm(p2ee)*cepminee ) 
CBB      &       wt=0d0
CBB         if (cfmminee.gt.-1 .and. p3ee(3).lt.qnorm(p3ee)*cfmminee ) 
CBB      &       wt=0d0
CBB         if (cfpminee.gt.-1 .and. p4ee(3).lt.qnorm(p4ee)*cfpminee ) 
CBB      &       wt=0d0
c
*       PRINT *, '35 wt =', wt
CBB         if (cemmaxee.lt.+1 .and. p1ee(3).gt.qnorm(p1ee)*cemmaxee ) 
CBB      &       wt=0d0
CBB         if (cepmaxee.lt.+1 .and. p2ee(3).gt.qnorm(p2ee)*cepmaxee ) 
CBB      &       wt=0d0
CBB         if (cfmmaxee.lt.+1 .and. p3ee(3).gt.qnorm(p3ee)*cfmmaxee ) 
CBB      &       wt=0d0
CBB         if (cfpmaxee.lt.+1 .and. p4ee(3).gt.qnorm(p4ee)*cfpmaxee ) 
CBB      &       wt=0d0
        wt1=0d0
        wt2=0d0
        if ((p1ee(3).ge.qnorm(p1ee)*cemminee )
     &  .and.(p1ee(4).ge.eemminee)
     &  .and.(p2ee(3).ge.qnorm(p2ee)*cepminee )
     &  .and.(p2ee(3).le.qnorm(p2ee)*cepmaxee )) 
     &       wt1=1d0
        if ((p2ee(3).le.-qnorm(p2ee)*cemminee )
     &  .and.(p2ee(4).ge.eepminee)
     &  .and.(p1ee(3).ge.-qnorm(p1ee)*cepmaxee )
     &  .and.(p1ee(3).le.-qnorm(p1ee)*cepminee )) 
     &       wt2=1d0  
        if (wt1+wt2.ne.1d0) wt=0d0  
        if(wt.eq.0d0) go to 1234
        call hfill(102,ct1,dum,1.)
        call hfill(103,ct2,dum,1.)
        call hfill(101,XMINV,DUM,1.)
        call hfill(104,real(p1ee(4)),dum,1.)
        call hfill(105,real(p2ee(4)),dum,1.)
c
c Cuts on min/max cos theta between fermion pairs
c
*       PRINT *, '40 wt =', wt
        if (ceeminee.gt.-1.and.cos(angle(p1ee,p2ee)).lt.ceeminee) 
     &       wt=0d0
        if (.not. xeeee) then
          if (cffminee.gt.-1.and.cos(angle(p3ee,p4ee)).lt.cffminee) 
     &         wt=0d0
        else
          if (ceeminee.gt.-1.and.cos(angle(p3ee,p4ee)).lt.ceeminee) 
     &         wt=0d0
          if (ceeminee.gt.-1.and.cos(angle(p1ee,p4ee)).lt.ceeminee) 
     &         wt=0d0
          if (ceeminee.gt.-1.and.cos(angle(p3ee,p2ee)).lt.ceeminee) 
     &         wt=0d0
        endif
c
*       PRINT *, '45 wt =', wt
        if (ceemaxee.lt.+1.and.cos(angle(p1ee,p2ee)).gt.ceemaxee) 
     &       wt=0d0
        if (.not. xeeee) then
          if (cffmaxee.lt.+1.and.cos(angle(p3ee,p4ee)).gt.cffmaxee) 
     &         wt=0d0
        else
          if (ceemaxee.lt.+1.and.cos(angle(p3ee,p4ee)).gt.ceemaxee) 
     &         wt=0d0
          if (ceemaxee.lt.+1.and.cos(angle(p1ee,p4ee)).gt.ceemaxee) 
     &         wt=0d0
          if (ceemaxee.lt.+1.and.cos(angle(p3ee,p2ee)).gt.ceemaxee) 
     &         wt=0d0
        endif
c
c Cuts on at least 1 electron out of 2 (at least 3 out of 4!)
c
*       PRINT *, '50 wt =', wt
        if (.not. xeeee) then
          if ( p1ee(4).lt.eexminee .and.
     &         p2ee(4).lt.eexminee ) 
     &         wt=0d0
        else
          if ( p1ee(4).lt.eexminee .and.
     &         p2ee(4).lt.eexminee .and.
     &         p3ee(4).lt.eexminee .and.
     &         p4ee(4).lt.eexminee ) 
     &         wt=0d0
        endif
c
        if (eexmaxee.gt.0) then
          if (.not. xeeee) then
            if ( p1ee(4).gt.eexmaxee .and.
     &           p2ee(4).gt.eexmaxee ) 
     &           wt=0d0
          else
            if ( p1ee(4).gt.eexmaxee .and.
     &           p2ee(4).gt.eexmaxee .and.
     &           p3ee(4).gt.eexmaxee .and.
     &           p4ee(4).gt.eexmaxee ) 
     &           wt=0d0
          endif
        endif
c
*       PRINT *, '55 wt =', wt
        if (cexminee.gt.-1) then
          if (.not. xeeee) then
            if ( p1ee(3).lt.qnorm(p1ee)*cexminee .and.
     &           p2ee(3).lt.qnorm(p2ee)*cexminee ) 
     &           wt=0d0
          else
            if ( p1ee(3).lt.qnorm(p1ee)*cexminee .and.
     &           p2ee(3).lt.qnorm(p2ee)*cexminee .and.
     &           p3ee(3).lt.qnorm(p3ee)*cexminee .and.
     &           p4ee(3).lt.qnorm(p4ee)*cexminee ) 
     &           wt=0d0
          endif
        endif
c
        if (cexmaxee.lt.-1) then
          if (.not. xeeee) then
            if ( p1ee(3).gt.qnorm(p1ee)*cexmaxee .and.
     &           p2ee(3).gt.qnorm(p2ee)*cexmaxee ) 
     &           wt=0d0
          else
            if ( p1ee(3).gt.qnorm(p1ee)*cexmaxee .and.
     &           p2ee(3).gt.qnorm(p2ee)*cexmaxee .and.
     &           p3ee(3).gt.qnorm(p3ee)*cexmaxee .and.
     &           p4ee(3).gt.qnorm(p4ee)*cexmaxee ) 
     &           wt=0d0
          endif
        endif        
c
 1234   continue
*       PRINT *, '60 wt =', wt
        if (wt.eq.0d0) then
          nkwctee=nkwctee+1
*         print *, 'Event rejected by GCEE'
          return
        endif
      endif
c
c 7. /KWCTPT/ cuts
c ----------------
c Cuts to be apllied to sum of pt^2 from charged fermions 

!!!!!!!!!!!!! sumup pt2 for charged final fermions
          themin = 1.d-6
          angarb = SIN(themin)**2
          pt2=0d0
          IF(abs(iflav(1)) .NE. 12  .AND.  abs(iflav(1)) .NE. 14
     $  .AND.  abs(iflav(1)) .NE. 16  .AND.
     $ (p1(1)**2+p1(2)**2)/(p1(1)**2+p1(2)**2+p1(3)**2) .GT. angarb )
     $  pt2=pt2+p1(1)**2+p1(2)**2

          IF(abs(iflav(2)) .NE. 12  .AND.  abs(iflav(2)) .NE. 14
     $  .AND.  abs(iflav(2)) .NE. 16  .AND.
     $ (p2(1)**2+p2(2)**2)/(p2(1)**2+p2(2)**2+p2(3)**2) .GT. angarb )
     $  pt2=pt2+p2(1)**2+p2(2)**2

          IF(abs(iflav(3)) .NE. 12  .AND.  abs(iflav(3)) .NE. 14
     $  .AND.  abs(iflav(3)) .NE. 16  .AND.
     $ (p3(1)**2+p3(2)**2)/(p3(1)**2+p3(2)**2+p3(3)**2) .GT. angarb )
     $  pt2=pt2+p3(1)**2+p3(2)**2

          IF(abs(iflav(4)) .NE. 12  .AND.  abs(iflav(4)) .NE. 14
     $  .AND.  abs(iflav(4)) .NE. 16  .AND.
     $ (p4(1)**2+p4(2)**2)/(p4(1)**2+p4(2)**2+p4(3)**2) .GT. angarb )
     $  pt2=pt2+p4(1)**2+p4(2)**2
C      call hfill(106,real(pt2),dum,1.)

C  check now on ee invariant mass to be in complementary range
      em12 = 1.d20
      em34 = 1.d20
      em14 = 1.d20
      em23 = 1.d20
      wtee = 1.d0
      iee = 0
      IF (iflav(2) .EQ. -11) then
         em12 = qadra(p1,p2)
         wtee = 0.d0
         iee = 1
         if (em12.gt.ee2min .and. em12.lt.ee2max) wtee = 1.d0
      ENDIF
      IF (iflav(3) .EQ. 11) THEN
         em34 = qadra(p3,p4)
         wtee = 0.d0
         iee = 1   
         if (em34.gt.ee2min .and. em34.lt.ee2max) wtee = 1.d0
      ENDIF
      call hfill(116,real(pt2),dum,1.)
      wtpt = 1.d0
      if (xgcpt) then
          IF(pt2 .ge. pt2max) wtpt=0d0
          IF(pt2 .lt. pt2min) wtpt=0d0
          if( (iee.eq.0 .and.wtpt.eq.0d0).or.
     *        (iee.eq.1).and.(wtpt.eq.0d0).and.(wtee.eq.0d0)) then
             nkwctpt=nkwctpt+1
             wt = 0.d0 
C             print *, '_USER_SELECTO Event rejected by GCWW'
             return
          else
C          print *,' pt2 ,min,max ',pt2,pt2min,pt2max
C          print *,' em12,34 min,max ',em12,em34,ee2min,ee2max
C          print *,' wtpt,wtee ',wtpt,wtee
          if (iee.eq.1) then
             call hfill(107,real(em12),dum,1.)
             call hfill(107,real(em34),dum,1.)
C             call hfill(107,real(em14),dum,1.)
C             call hfill(107,real(em23),dum,1.)
           endif

          endif

      endif
 60   CONTINUE
c
      nkwctot(3) = nkwctot(3)+1
      return
      end

************************************************************************

      SUBROUTINE KORALWINI_DEFAULTS (XPAR)
C--------------------------------------------------------------------
C Give default values to input parameters in XPAR array
C A.Valassi 2001 adapted from version by B.Bloch 1999
C The values are exactly those in the KW1.51.3 data_defaults file
C Input:  none
C Output: XPAR array
C--------------------------------------------------------------------
C A.Valassi 26/06/2001
C Cross-check authors' recommendation with Maciek and Wiesiek for:
C - KeyBra=2 
C   Branching ratios are recalculated from CKM
C - KeyZet=KeyWu=1 
C   Use fixed width everywhere (even if Grace is now able to use
C   running widths, which was not the case for KRLW02).
C   This is mandatory to avoid gauge violations for single W events.
C   The 27 MeV shift needs to be applied for the mass.
C - KeyMix=1
C   Use the Gmu scheme. This is mandatory for YFSWW reweighting.
C - KeyCor=6
C   The fast YFSWW option uses pretabulated values and produces 
C   equivalent physics (at 0.1%) to the exact slower option (=5).
C   Both require ~20sec bootstrap time on the first event.
C - KeyLpa=0
C   Use LPA_a in YFSWW.
C--------------------------------------------------------------------
C A.Valassi 14 August 2001 Upgrade to version 1.53.1
C - xpar(20) controls singleW
C - xpar(1034-1035) control Korwan
C--------------------------------------------------------------------
      IMPLICIT NONE
C KORALW generator input parameters
      INTEGER npar
      PARAMETER (npar=10000)
      DOUBLE PRECISION xpar(npar) ! array for input parameters
      INTEGER i
******************************************************************************
* This is default Umask for completely INCLUSIVE final states
* Umask is used in program only for completely inclusive request
* (KeyDWM=0, KeyDWP=0, KeyWon=1, KeyZon=1), otherwise it is ignored!
******************************************************************************
      REAL*8 umaskww (81)
      DATA   umaskww /
C Wm =     1:ud 2:cd 3:us 4:cs 5:ub 6:cb 7:el 8:mu 9:ta / Wp=
     &     1,  1,    1,    1,    1,  1,    1,   1,    1, !  1:ud
     &     1,  0,    1,    1,    1,  1,    1,   1,    1, !  2:cd
     &     1,  1,    0,    1,    1,  1,    1,   1,    1, !  3:us
     &     1,  1,    1,    1,    1,  1,    1,   1,    1, !  4:cs
     &     1,  1,    1,    1,    0,  1,    1,   1,    1, !  5:ub
     &     1,  1,    1,    1,    1,  0,    1,   1,    1, !  6:cb
     &     1,  1,    1,    1,    1,  1,    1,   1,    1, !  7:el
     &     1,  1,    1,    1,    1,  1,    1,   1,    1, !  8:mu
     &     1,  1,    1,    1,    1,  1,    1,   1,    1/ !  9:ta
      REAL*8 umaskzz (121)
      DATA   umaskzz /
C Z1 =     1:d  2:u  3:s  4:c  5:b  6:el 7:mu 8:ta 9:ve 10:vm 11:vt / Z2=
     &     1,    0,   0,   0,   0,   0,   0,   0,   0,    0,    0, !  1:d
     &     0,    1,   0,   0,   0,   0,   0,   0,   0,    0,    0, !  2:u
     &     1,    1,   1,   0,   0,   0,   0,   0,   0,    0,    0, !  3:s
     &     1,    1,   0,   1,   0,   0,   0,   0,   0,    0,    0, !  4:c
     &     1,    1,   1,   1,   1,   0,   0,   0,   0,    0,    0, !  5:b
     &     1,    1,   1,   1,   1,   1,   0,   0,   0,    0,    0, !  6:el
     &     1,    1,   1,   1,   1,   1,   1,   0,   0,    0,    0, !  7:mu
     &     1,    1,   1,   1,   1,   1,   1,   1,   0,    0,    0, !  8:ta
     &     1,    1,   1,   1,   1,   0,   1,   1,   1,    0,    0, !  9:ve
     &     1,    1,   1,   1,   1,   1,   0,   1,   1,    1,    0, !  10vm
     &     1,    1,   1,   1,   1,   1,   1,   0,   1,    1,    1/ !  11vt
******************************************************************************
* RESET XPAR TO 0
******************************************************************************
      DO i = 1, 10000
        xpar(i) = 0d0
      END DO
******************************************************************************
* Parameters 1-13 are also used in YFSWW3
******************************************************************************
      XPAR ( 1) = 200d0         ! CmsEne = CMS total energy [GeV]
      XPAR ( 2) = 1.16639d-5    ! GFermi = Fermi Constant 
      XPAR ( 3) = 128.07d0      ! AlfWin = Inverse alpha QED at WW treshold
      XPAR ( 4) = 91.1882d0     ! amaZ   = Z mass   
      XPAR ( 5) = 2.4952d0      ! gammZ  = Z width      
      XPAR ( 6) = 80.419d0      ! amaW   = W mass 
      XPAR ( 7) = -2.120d0      ! gammW  = W width (<0 => RECALCULATED in code)
      XPAR ( 8) = 1d-6          ! vvmin  = Photon spectrum parameter
      XPAR ( 9) = 0.99d0        ! vvmax  = Photon spectrum parameter
      XPAR (10) = 2d0           ! wtmax  = Max weight for rejection 
      XPAR (11) = 115D0         ! amh    = Higgs mass
      XPAR (12) = 1.0D0         ! agh    = Higgs width
      XPAR (13) = 0.1185d0      ! alpha_s= QCD coupling const.
******************************************************************************
* Parameters 14-19 are not used in YFSWW3
******************************************************************************
      XPAR (14) = 600d0         ! arbitr = Min. vis p_t**2 (GeV**2)
      XPAR (15) = 8d0           ! arbitr1= Inv_mass**2 cut for e+e-xx (GeV**2)
      XPAR (16) = 1d-6          ! themin = Min theta (rad) with beam (0=no cut)
      XPAR (17) = 300d0         ! arbitr2= Max p_t**2 photons in eexx (GeV**2)
      XPAR (18) = -1d0          ! WTMAX_cc03= Max wt for cc03 rej. (<0=default)
      XPAR (19) = 0d0           ! PReco  = Colour Reconnection Probability
******************************************************************************
* Parameter 20 controls the singleW correction (default is to be tuned!)
* SingleW t-channel ISR and alpha(t) are emulated below tAngMax
* tAngMax =   0 means no singleW correction
* tAngMax = 180 means singleW correction at all angles
******************************************************************************
      XPAR (20) = 0d0           ! tAngMax =maximum  theta (deg) of e+/- 
******************************************************************************
* Parameters 21-73 are reserved for anomalous couplings
* Example of wild random anomalous coupling constants (benchmark)
* Must set KeyACC>0 in order to activate them.
******************************************************************************
* KeyAcc=1: Set 1, the most general TGC's 
* Cf. Hagiwara et al., Nucl. Phys. B282 (1987) 253.
*                g_1^V                g1(2)
*                kappa_V              kap(2)
*                lambda_V             lam(2)
*                g_4^V                g4(2)
*                g_5^V                g5(2)
*                kappa-tilde_V        kapt(2)
*                lambda-tilde_V       lamt(2)
* Standard Model looks as follows: 
* xpar(21)=1d0, xpar(22)=1d0, xpar(41)=1d0, xpar(42)=1d0 and all others=0d0
      XPAR (21) =      .1191D+01 ! Re[g1(1)]
      XPAR (22) =     -.3060D+00 ! Re[kap(1)]
      XPAR (23) =      .1283D+01 ! Re[lam(1)]
      XPAR (24) =     -.3160D+01 ! Re[g4(1)]
      XPAR (25) =     -.7430D+00 ! Re[g5(1)]
      XPAR (26) =     -.6050D+00 ! Re[kapt(1)]
      XPAR (27) =      .1530D+01 ! Re[lampt(1)]
      XPAR (31) =     -.8010D+00 ! Im[g1(1)]
      XPAR (32) =      .7237D+00 ! Im[kap(1)]
      XPAR (33) =     -.4960D+00 ! Im[lam(1)]
      XPAR (34) =      .8320D+00 ! Im[g4(1)]
      XPAR (35) =     -.1490D+01 ! Im[g5(1)]
      XPAR (36) =      .8380D+00 ! Im[kapt(1)]
      XPAR (37) =      .9920D-01 ! Im[lampt(1)]
      XPAR (41) =     -.1960D+01 ! Re[g1(2)]
      XPAR (42) =     -.4970D+00 ! Re[kap(2)]
      XPAR (43) =      .6380D+00 ! Re[lam(2)]
      XPAR (44) =     -.9980D+00 ! Re[g4(2)]
      XPAR (45) =      .6410D+00 ! Re[g5(2)]
      XPAR (46) =      .1638D+00 ! Re[kapt(2)]
      XPAR (47) =     -.5950D+00 ! Re[lampt(2)]
      XPAR (51) =      .5169D+00 ! Im[g1(2)]
      XPAR (52) =      .6489D+00 ! Im[kap(2)]
      XPAR (53) =      .1426D+01 ! Im[lam(2)]
      XPAR (54) =     -.2760D+00 ! Im[g4(2)]
      XPAR (55) =      .2986D+01 ! Im[g5(2)]
      XPAR (56) =      .4021D+00 ! Im[kapt(2)]
      XPAR (57) =      .7230D+00 ! Im[lampt(2)]
* KeyAcc=2: Set 2, cf. YR CERN 96-01 "Physics at LEP2", Vol 1, p. 525
      XPAR (61) =        0.2D+00 ! delta_Z
      XPAR (62) =        0.1D+00 ! x_gamma
      XPAR (63) =        0.1D+00 ! x_Z
      XPAR (64) =        0.1D+00 ! y_gamma
      XPAR (65) =        0.1D+00 ! y_Z
* KeyAcc=3: Set 3, cf. YR CERN 96-01 "Physics at LEP2", Vol 1, p. 525
      XPAR (71) =        0.1D+00 ! alpha_Wphi 
      XPAR (72) =        0.1D+00 ! alpha_Bphi
      XPAR (73) =       -0.1D+00 ! alpha_W
******************************************************************************
* Parameters 100-102 set masses and coupling constants
******************************************************************************
      XPAR (100) = 0.510998902D-3 ! amel   = electron mass
      XPAR (101) = 137.03599976D0 ! AlfInv = 1/alpha_QED, Thomson limit
      XPAR (102) =   389.379292D6 ! gpicob = GeV-->picobarn translation
******************************************************************************
* Parameters 111-119 set CKM matrix elements
* Parameters 121-129 are reserved for imaginary parts
* Values of the CKM matrix elements from 2000 PDG Review
* Eq.(11.3) for mean values of given ranges for s_12, s_23, s_13
* Only real parts of the matrix elements are taken
* (For KeyBra=2, recalculate branching ratios from CKM matrix and alpha_s 
* (according to formula of A. Denner, Fortschr. Phys. 41 (1993) 307
******************************************************************************
      XPAR (111) =      0.97493d0 ! V_ud  real part
      XPAR (112) =      0.22250d0 ! V_us  real part
      XPAR (113) =      0.00350d0 ! V_ub  real part
      XPAR (114) =     -0.22246d0 ! V_cd  real part
      XPAR (115) =      0.97412d0 ! V_cs  real part
      XPAR (116) =      0.04000d0 ! V_cb  real part
      XPAR (117) =      0.00549d0 ! V_td  real part
      XPAR (118) =     -0.03978d0 ! V_ts  real part
      XPAR (119) =      0.99920d0 ! V_tb  real part
******************************************************************************
* Parameters 131-139 set W decay BR
* These are the default values used for KeyBra=1
* (For KeyBra=2 recalculate branching ratios from CKM matrix and alpha_s)
******************************************************************************
      XPAR (131) =      0.32110D0 ! 1-ud
      XPAR (132) =      0.01630D0 ! 2-cd
      XPAR (133) =      0.01635D0 ! 3-us
      XPAR (134) =      0.32043D0 ! 4-cs
      XPAR (135) =      0.00002D0 ! 5-ub
      XPAR (136) =      0.00070D0 ! 6-cb
      XPAR (137) =      0.10840D0 ! 7-e
      XPAR (138) =      0.10840D0 ! 8-mu
      XPAR (139) =      0.10830D0 ! 9-tau
******************************************************************************
* Parameters 151-157 Energy dependent wtmax_cc03
******************************************************************************
      XPAR (151) =          7.0D0 !     0 < CMSene < 162
      XPAR (152) =          5.0D0 !   162 < CMSene < 175
      XPAR (153) =          4.0D0 !   175 < CMSene < 200
      XPAR (154) =          4.4D0 !   200 < CMSene < 250
      XPAR (155) =          4.8D0 !   250 < CMSene < 350
      XPAR (156) =          7.0D0 !   350 < CMSene < 700
      XPAR (157) =          9.0D0 !   700 < CMSene
******************************************************************************
* Parameters 511-1000 properties of quarks and leptons
* i-th position in xpar(i) according to i = 500+10*KFlavour +j
******************************************************************************
****** d-quark
      XPAR (511) =              1 ! KFlavour
      XPAR (512) =              3 ! NColor
      XPAR (513) =             -1 ! 3*Q   =3*charge
      XPAR (514) =             -1 ! 2*T3L =2*Isospin for Left component
      XPAR (515) =              0 ! 2*helicity, 0 for unpolarized
      XPAR (516) =        0.006d0 ! mass [GeV] (3-9 MeV in PDG)
      XPAR (517) =          3.5d0 ! WtMax Maximum weight for rejection d-quark
****** u-quark
      XPAR (521) =              2 ! KFlavour
      XPAR (522) =              3 ! NColor
      XPAR (523) =              2 ! 3*Q   =3*charge
      XPAR (524) =              1 ! 2*T3L =2*Isospin for Left component
      XPAR (525) =              0 ! 2*helicity, 0 for unpolarized
      XPAR (526) =        0.003d0 ! mass [GeV] (1-5 MeV in PDG)
      XPAR (527) =          3.5d0 ! WtMax Maximum weight for rejection u-quark
****** s-quark
      XPAR (531) =              3 ! KFlavour
      XPAR (532) =              3 ! NColor
      XPAR (533) =             -1 ! 3*Q   =3*charge
      XPAR (534) =             -1 ! 2*T3L =2*Isospin for Left component
      XPAR (535) =              0 ! 2*helicity, 0 for unpolarized
      XPAR (536) =       0.1225d0 ! mass [GeV] (75-170 MeV in PDG)
      XPAR (537) =          3.5d0 ! WtMax Maximum weight for rejection s-quark
****** c-quark
      XPAR (541) =              4 ! KFlavour
      XPAR (542) =              3 ! NColor
      XPAR (543) =              2 ! 3*Q   =3*charge
      XPAR (544) =              1 ! 2*T3L =2*Isospin for Left component
      XPAR (545) =              0 ! 2*helicity, 0 for unpolarized
      XPAR (546) =         1.25d0 ! mass [GeV] (1.15-1.35 GeV in PDG)
      XPAR (547) =          3.5d0 ! WtMax Maximum weight for rejection c-quark
****** b-quark
      XPAR (551) =              5 ! KFlavour
      XPAR (552) =              3 ! NColor
      XPAR (553) =             -1 ! 3*Q   =3*charge
      XPAR (554) =             -1 ! 2*T3L =2*Isospin for Left component
      XPAR (555) =              0 ! 2*helicity, 0 for unpolarized
      XPAR (556) =          4.2d0 ! mass [GeV] (4.0-4.4 GeV in PDG)
      XPAR (557) =          3.5d0 ! WtMax Maximum weight for rejection b-quark
****** t-quark
      XPAR (561) =              6 ! KFlavour
      XPAR (562) =              3 ! NColor
      XPAR (563) =              2 ! 3*Q   =3*charge
      XPAR (564) =              1 ! 2*T3L =2*Isospin for Left component
      XPAR (565) =              0 ! 2*helicity, 0 for unpolarized
      XPAR (566) =        174.3d0 ! mass [GeV] (174.3 GeV in PDG)
      XPAR (567) =          3.5d0 ! WtMax Maximum weight for rejection t-quark
****** electron
      XPAR (611) =             11 ! KFlavour
      XPAR (612) =              1 ! NColor
      XPAR (613) =             -3 ! 3*Q   =3*charge
      XPAR (614) =             -1 ! 2*T3L =2*Isospin for Left component
      XPAR (615) =              0 ! 2*helicity
      XPAR (616) = 0.510998902d-3 ! mass [GeV]   (0.51099907 MeV)
      XPAR (617) =          3.5d0 ! WtMax Maximum weight for rejection electron
****** neutrino electron
      XPAR (621) =             12 ! KFlavour
      XPAR (622) =              1 ! NColor
      XPAR (623) =              0 ! 3*Q   =3*charge
      XPAR (624) =              1 ! 2*T3L =2*Isospin for Left component
      XPAR (625) =              0 ! 2*helicity
      XPAR (626) =           1d-3 ! mass [GeV]
      XPAR (627) =          3.5d0 ! WtMax Maximum weight for rejection nu elec
****** muon
      XPAR (631) =             13 ! KFlavour
      XPAR (632) =              1 ! NColor
      XPAR (633) =             -3 ! 3*Q   =3*charge
      XPAR (634) =             -1 ! 2*T3L =2*Isospin for Left component
      XPAR (635) =              0 ! 2*helicity
      XPAR (636) =  0.105658357d0 ! mass [GeV]   (0.105658389 GeV)
      XPAR (637) =          3.5d0 ! WtMax Maximum weight for rejection muon
****** neutrino muon
      XPAR (641) =             14 ! KFlavour
      XPAR (642) =              1 ! NColor
      XPAR (643) =              0 ! 3*Q   =3*charge
      XPAR (644) =              1 ! 2*T3L =2*Isospin for Left component
      XPAR (645) =              0 ! 2*helicity
      XPAR (646) =           1d-3 ! mass [GeV]
      XPAR (647) =          3.5d0 ! WtMax Maximum weight for rejection nu muon
****** tau
      XPAR (651) =             15 ! KFlavour
      XPAR (652) =              1 ! NColor
      XPAR (653) =             -3 ! 3*Q   =3*charge
      XPAR (654) =             -1 ! 2*T3L =2*Isospin for Left component
      XPAR (655) =              0 ! 2*helicity
      XPAR (656) =      1.77703d0 ! mass [GeV]   (1.77705 GeV)
      XPAR (657) =          3.5d0 ! WtMax Maximum weight for rejection tau
****** neutrino tau
      XPAR (661) =             16 ! KFlavour
      XPAR (662) =              1 ! NColor
      XPAR (663) =              0 ! 3*Q   =3*charge
      XPAR (664) =              1 ! 2*T3L =2*Isospin for Left component
      XPAR (665) =              0 ! 2*helicity
      XPAR (666) =           1d-3 ! mass [GeV]
      XPAR (667) =          3.5d0 ! WtMax Maximum weight for rejection nu tau
******************************************************************************
* Parameters 1000-1100 set the internal switches
******************************************************************************
      XPAR (1011) =            2d0 ! KeyISR =xpar(1011)
*                    =0,1  initial state radiation off/on
      XPAR (1012) =            0d0 ! KeyFSR =xpar(1012) 
*                    KeyFSR =final state radiation switch, INACTIVE
      XPAR (1013) =            1d0 ! KeyNLL =xpar(1013)
*                    =0 sets next-to leading alpha/pi terms to zero
*                    =1 alpha/pi in yfs formfactor is kept
      XPAR (1014) =            2d0 ! KeyCul =xpar(1014)
*                    =0 No Coulomb correction 
*                    =1 "Normal" Coulomb correction 
*                    =2 "Screened-Coulomb" Ansatz for Non-Factorizable Corr. 
      XPAR (1021) =            2d0 ! KeyBra =xpar(1021)
*                      NOTE, in KW key changed its meaning since v. 1.42 !!
*                    = 0 born branching ratios, no mixing
*                    = 1 branching ratios with mixing and naive QCD
*                        taken from input
*                    = 2 branching ratios with mixing and naive QCD 
*                        calculated in IBA from the CKM matrix (PDG 2000); 
*                    = 3 fixed branching ratios with mixing and naive QCD
*                        (this is KeyBra=1 setting of v. 1.42.3)
*                        see file KW.f for setup 
      XPAR (1022) =            1d0 ! KeyMas =xpar(1022)
*                    = 0,1 masless/massive kinematics for w decay products
      XPAR (1023) =            1d0 ! KeyZet =xpar(1023)
*                    = 0, Z width in z propagator: s/m_z *gamm_z
*                    = 1, Z width in z propagator:   m_z *gamm_z
*                    = 2, Z zero width in z propagator.
      XPAR (1024) =            1d0 ! KeySpn =xpar(1024)
*                    = 0,1 spin effects off/on in W decays
      XPAR (1025) =            0d0 ! KeyRed =xpar(1025)
*                    = reduction of massive fs to massles matr.el.
*                    = 0 fine (recommended)
*                    = 1 crude, 4-mom. non conserving
*                    = 2 no reduction at all
      XPAR (1026) =            1d0 ! KeyWu  =xpar(1026)
*                    = 0 w width in w propagator: s/m_w *gamm_w
*                    = 1 w width in w propagator:   m_w *gamm_w
*                    = 2 no (0) w width in w propagator.
      XPAR (1031) =            0d0 ! KeyWgt =xpar(1031)
*                    =0, unweighted events (wt=1), for apparatus Monte Carlo
*                    =1, weighted events, option faster and safer
*                    =2, unweighted for internal matrix element and weighted
*                        for external matrix el. (for some special purposes)
      XPAR (1032) =            1d0 ! KeyRnd =xpar(1032)
*                    =1 for RANMAR random number generator (default)
*                    =2 for ECURAN random number generator
*                    =3 for CARRAN random number generator
      XPAR (1033) =            2d0 ! KeySmp =xpar(1033)
*                    =0 presampler set as in KORALW v. 1.02-1.2
*                    =1 first presampler for all 4fermion final states
*                    =2 second presampler for all 4fermion final states
*                    =3 50/50 mixed (1+2) presampler 
*                              for all 4fermion final states
*                      MUST BE =0 in YFSWW3 (no background processes!)
      XPAR (1034) =            0d0 ! KeySAN =xpar(1034)
*                    =0 KorWan: semianalytical formula of Muta et al 
*                    =1 KorWan: spin amplitudes of KoralW (with A.C.C.)
      XPAR (1035) =            0d0 ! KeyCOS =xpar(1035)
*                    =0 KorWan:  normal dsigma/dxxx
*                    =1 KorWan:  dsigma/(dcosthe dxxx) (only for KeySAN=1)
      XPAR (1041) =            1d0 ! KeyMix =xpar(1041)
*                    KeyMix EW "Input Parameter Scheme" choices. 
*                      NOTE, this key changed its meaning since v. 1.33 !!
*                    =0 'LEP2 Workshop 1995' scheme
*                        (in YFSWW for Born and ISR only!)
*                    =1 G_mu scheme (RECOMMENDED)
      XPAR (1042) =            1d0 ! Key4f  =xpar(1042)
*                    = 0, INTERNAL matrix element
*                    = 1, EXTERNAL matrix element
*                      MUST BE =0 in YFSWW3 (no background processes!)
      XPAR (1043) =            0d0 ! KeyAcc =xpar(1043)
*                    = 0, anomalous WWV couplings in internal matr. el. OFF
*                    > 0, anomalous WWV couplings in internal matr. el. ON
*                    = 1, set 1: the most general (complex number) TGC's 
*                           in the notation of Ref. 
*                           K. Hagiwara et al., Nucl. Phys. B282 (1987) 253, 
*                           see also: YR CERN 96-01 "Physics at LEP2;
*                    > 1, some specific parametrizations discussed in: 
*                          YR CERN 96-01 "Physics at LEP2", Vol. 1, p. 525;
*                          = 2, set 2: delta_Z, x_gamma, x_Z, y_gamma, y_Z   
*                          = 3, set 3: alpha_Wphi, alpha_Bphi, alpha_W
      XPAR (1044) =            1d0 ! KeyZon =xpar(1044)
*                    = 1/0, ZZ type final states ON/OFF
*                       MUST BE =0 in YFSWW3 (no background processes!)
      XPAR (1045) =            1d0 ! KeyWon =xpar(1045)
*                    = 1/0, WW type final states ON/OFF
*                       MUST BE =1 in YFSWW3 (only WW-type processes!)
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* W decays: 1=ud, 2=cd, 3=us, 4=cs, 5=ub, 6=cb, 7=e, 8=mu, 9=tau, 0=all chan.
      XPAR (1055) =            0d0 ! KeyDWM =xpar(1055)   W- decay   
      XPAR (1056) =            0d0 ! KeyDWP =xpar(1056)   W+ decay  
* Output unit#
      XPAR (1057) =            6d0 ! Nout   =xpar(1057)   Output unit (16 if<0)
* Tauola, Photos, Jetset
      XPAR (1071) =            0d0 ! JAK1   =xpar(1071)   Decay mode tau+
      XPAR (1072) =            0d0 ! JAK2   =xpar(1072)   Decay mode tau-
      XPAR (1073) =            1d0 ! ITDKRC =xpar(1073)   Brems in Tauola 
      XPAR (1074) =            1d0 ! IFPHOT =xpar(1074)   PHOTOS switch
      XPAR (1075) =            1d0 ! IFHADM =xpar(1075)   Hadronization W-
      XPAR (1076) =            1d0 ! IFHADP =xpar(1076)   Hadronization W+
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
C technical switches added 10/10/00 1079  -1088
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      XPAR (1079) = 0d0 ! i_pres  =xpar(1079)  presampler probabilities monitor
*                    = 1/0 ON/OFF 
      XPAR (1080) = 0d0 ! i_yfs  =xpar(1080)   yfs internal tests
*                    = 1/0 ON/OFF 
      XPAR (1081) = 1d0 ! i_file =xpar(1081)   photonic presampling
*                    = 1 xsect(s) pretabulated (default)
*                    = 0 xsect(s) from analytic function
      XPAR (1082) = 0d0 ! i_disk =xpar(1082)   
*                    = 0 normal M.C. generation (default)
*                    = 1 4f phase space debugg mode (reads 4vects from disk)
*                    = 2 reads 4vects from disk, short format
*                    = 3 reads 4vects from disk, short fmt + end of run marker
*                    = 4 reads 4vects from disk, long format
      XPAR (1083) = 1d0 ! i_prnt =xpar(1083)   printout on wt over wtmax
*                    = 1/0 ON/OFF
      XPAR (1084) = 1d0 ! i_sw4f =xpar(1084)   approximations in 4f matr. el.
*                    = -1 all apprs. set in /isw4f/ in amp4f.f
*                    =  0 CC03
*                    =  1 complete 4f (default)
*                    =  2 - 9 specific apprs, see amp4f.f
      XPAR (1085) = 4d0 ! i_prwt =xpar(1085)   order of ISR matr el.
*                    = 2 first  order ISR
*                    = 3 second order ISR
*                    = 4 third  order ISR (default)
      XPAR (1086) = 0d0 ! i_writ_wt =xpar(1086) writing weights on disk
*                    = 0 OFF (default)
*                    = 1 wtext only
*                    = 3 wtset(1-9) only
      XPAR (1087) = 0d0 ! i_writ_4v =xpar(1087) writing 4vectors to disk
*                    = 0 OFF (default)
*                    = 2 short (readable by i_disk=2)
*                    = 3 short format + end of run marker
*                    = 4 long format
      XPAR (1088) = 0d0 ! i_read_wt =xpar(1088) reading wgts from disk, tests
*                    = 0 OFF (default)
*                    = 1 wtext additive
*                    = 2 wtext multiplicative
*                    = 3 wtset(1-9), overwrites 
*                    = 4 wtset(1-9), put into wtset(91-99)
*                      negative values = tests:
*                    =-3 wtset, tests of wtset
*                    =-2 wtext, tests of 4f born 
*                    =-1 wtext, tests of cc03 born
******************************************************************************
* Entries from 1101 to 1302 are reserved for Umask matrix
* User may owerwrite Umask with explicit CALL KW_ReadMask( DiskFile, 1, xpar)
* This is default Umask for completely INCLUSIVE final states
* Umask is used in program only for completely inclusive request
* (KeyDWM=0, KeyDWP=0, KeyWon=1, KeyZon=1), otherwise it is ignored!
******************************************************************************
      DO i = 1, 81
        XPAR (1100+i) = umaskww(i)
      END DO
      DO i = 1, 121
        XPAR (1181+i) = umaskzz(i)
      END DO
******************************************************************************
* Entries from 2000 to 2999 are YFSWW-specific
******************************************************************************
      XPAR (2001) = 6d0         ! KeyCor =xpar(2001) Rad Corr switch
*                    KeyCor   =0: Born
*                             =1: Above + ISR
*                             =2: Above + Coulomb Correction
*                             =3: Above + YFS Full Form-Factor Correction
*                             =4: Above + Radiation from WW
*                             =5: Above + Exact O(alpha) EWRC (BEST!)
*                             =6: As Above but Approximate EWRC (faster) 
      XPAR (2002) = 0d0         ! KeyLPA =xpar(1034)   LPA mode switch
*                           = 0,1: LPA_a/LPA_b mode (=0 RECOMMENDED)
******************************************************************************
* Entries from 4000 to 4999 are reserved for private exercises, for example:
******************************************************************************
* BE parameters
      XPAR (4061) =          0.2d0 ! range  =xpar(61) Q^2 range  , Epifany97!!!
      XPAR (4062) =            1d0 ! ifun   =xpar(62) Gausian UA1, Epifany97!!!
      XPAR (4063) =         0.20d0 ! pp     =xpar(63) Gausian UA1, Epifany97!!!
      XPAR (4064) =         1.00d0 ! radius =xpar(64) Gausian UA1, Epifany97!!!
* renormalizations
      XPAR (4065) =       1.0675d0 ! lam=xpar(65) 172GeV 2W Range=0.20,ifun=2
      XPAR (4066) =       0.1751d0 ! avewt=xpar(66) 172GeV 2W Range=0.20,ifun=2
      XPAR (4067) =       1.0510d0 ! lam2=xpar(67) 172GeV 1W Range=0.20,ifun=2
      XPAR (4068) =       0.4387d0 ! avwt2=xpar(68) 172GeV 1W Range=0.20,ifun=2
* rejection parameters
      XPAR (4069) =            0d0 ! KeyRej =xpar(69) Rejection ON for KeyRej=0
      XPAR (4070) =            3d0 ! WtMax  =xpar(70) maximum wgt for rejection
  999 RETURN
      END

************************************************************************

      SUBROUTINE KORALWINI_USER (XPAR)
C--------------------------------------------------------------------
C Change values of input parameters in XPAR array
C A.Valassi 2001
C Input: 
C - XPAR array
C - /INOUT/ common
C - data cards GKEY, GENE, GKAC, GDEK, MSKW, MSKZ, XPAR
C Output:
C - XPAR array
C--------------------------------------------------------------------
      IMPLICIT NONE
      INTEGER npar
      PARAMETER (npar=10000)
      DOUBLE PRECISION xpar(npar) ! array for input parameters
      INTEGER          inut, iout
      COMMON / INOUT / INUT, IOUT
      INTEGER    LBCS
      PARAMETER (LBCS=1000)
      INTEGER IW(LBCS)
      REAL    RW(LBCS)
      COMMON /BCS/ IW
      EQUIVALENCE (RW(1),IW(1))
      INTEGER NAMIND
      INTEGER NAGKEY, JGKEY
      INTEGER NAGENE, JGENE
      INTEGER NAGKAC, JGKAC
      INTEGER NAGDEK, JGDEK
      INTEGER NAMSKW, JMSKW
      INTEGER NAMSKZ, JMSKZ
      INTEGER NAMI, KIND, LUPAR
      INTEGER imask
c
c Output unit#
c
      XPAR(1057) = IOUT
c
c Data card GKEY
c
      NAGKEY = NAMIND('GKEY')
      JGKEY = IW(NAGKEY)
      IF(JGKEY.NE.0) THEN
        XPAR(1011) = IW(JGKEY+ 1) ! KEYISR
        XPAR(1012) = IW(JGKEY+ 2) ! KEYFSR
        XPAR(1013) = IW(JGKEY+ 3) ! KEYNLL
        XPAR(1014) = IW(JGKEY+ 4) ! KEYCUL
        XPAR(1021) = IW(JGKEY+ 5) ! KEYBRA
        XPAR(1022) = IW(JGKEY+ 6) ! KEYMAS
        XPAR(1023) = IW(JGKEY+ 7) ! KEYZET
        XPAR(1024) = IW(JGKEY+ 8) ! KEYSPN
        XPAR(1025) = IW(JGKEY+ 9) ! KEYRED
        XPAR(1026) = IW(JGKEY+10) ! KEYWU
        XPAR(1033) = IW(JGKEY+11) ! KEYSMP
        XPAR(1041) = IW(JGKEY+12) ! KEYMIX
        XPAR(1042) = IW(JGKEY+13) ! KEY4F
        XPAR(1043) = IW(JGKEY+14) ! KEYACC
        XPAR(1044) = IW(JGKEY+15) ! KEYZON
        XPAR(1045) = IW(JGKEY+16) ! KEYWON
        XPAR(1055) = IW(JGKEY+17) ! KEYDWM
        XPAR(1056) = IW(JGKEY+18) ! KEYDWP
      ENDIF
c
c Data card GENE
c
      NAGENE = NAMIND('GENE')
      JGENE = IW(NAGENE)
      IF(JGENE.NE.0) THEN
        XPAR(1)  = RW(JGENE+ 1) ! CMSENE
        XPAR(4)  = RW(JGENE+ 2) ! AMAZ
        XPAR(5)  = RW(JGENE+ 3) ! GAMMZ
        XPAR(6)  = RW(JGENE+ 4) ! AMAW
        XPAR(7)  = RW(JGENE+ 5) ! GAMMW
        XPAR(11) = RW(JGENE+ 6) ! AMH
        XPAR(12) = RW(JGENE+ 7) ! AGH
        XPAR(8)  = RW(JGENE+ 8) ! VVMIN
        XPAR(9)  = RW(JGENE+ 9) ! VVMAX
        XPAR(10) = RW(JGENE+10) ! WTMAX
        XPAR(18) = RW(JGENE+11) ! WTMAX_cc03
        XPAR(19) = RW(JGENE+12) ! PRECO
      ENDIF
c
c Data card GKAC
c
      NAGKAC = NAMIND('GKAC')
      JGKAC = IW(NAGKAC)
      IF(JGKAC.NE.0) THEN
* WWgamma vertex Real part 
        XPAR(21) = RW(JGKAC+1)  ! Re[g1(1)]
        XPAR(22) = RW(JGKAC+2)  ! Re[kap(1)]
        XPAR(23) = RW(JGKAC+3)  ! Re[lam(1)]
        XPAR(24) = RW(JGKAC+4)  ! Re[g4(1)]
        XPAR(25) = RW(JGKAC+5)  ! Re[g5(1)]
        XPAR(26) = RW(JGKAC+6)  ! Re[kapt(1)]
        XPAR(27) = RW(JGKAC+7)  ! Re[lampt(1)]
* WWgamma vertex Imaginary part 
        XPAR(31) = RW(JGKAC+8)  ! Im[g1(1)]
        XPAR(32) = RW(JGKAC+9)  ! Im[kap(1)]
        XPAR(33) = RW(JGKAC+10) ! Im[lam(1)]
        XPAR(34) = RW(JGKAC+11) ! Im[g4(1)]
        XPAR(35) = RW(JGKAC+12) ! Im[g5(1)]
        XPAR(36) = RW(JGKAC+13) ! Im[kapt(1)]
        XPAR(37) = RW(JGKAC+14) ! Im[lampt(1)]
* WWZ vertex Real part 
        XPAR(41) = RW(JGKAC+15) ! Re[g1(2)]
        XPAR(42) = RW(JGKAC+16) ! Re[kap(2)]
        XPAR(43) = RW(JGKAC+17) ! Re[lam(2)]
        XPAR(44) = RW(JGKAC+18) ! Re[g4(2)]
        XPAR(45) = RW(JGKAC+19) ! Re[g5(2)]
        XPAR(46) = RW(JGKAC+20) ! Re[kapt(2)]
        XPAR(47) = RW(JGKAC+21) ! Re[lampt(2)]
* WWZ vertex Imaginary part 
        XPAR(51) = RW(JGKAC+22) ! Im[g1(2)]
        XPAR(52) = RW(JGKAC+23) ! Im[kap(2)]
        XPAR(53) = RW(JGKAC+24) ! Im[lam(2)]
        XPAR(54) = RW(JGKAC+25) ! Im[g4(2)]
        XPAR(55) = RW(JGKAC+26) ! Im[g5(2)]
        XPAR(56) = RW(JGKAC+27) ! Im[kapt(2)]
        XPAR(57) = RW(JGKAC+28) ! Im[lampt(2)]
      ENDIF
c
c Data card GDEK
c
      NAGDEK = NAMIND('GDEK')
      JGDEK = IW(NAGDEK)
      IF(JGDEK.NE.0) THEN
        XPAR(1071) = IW(JGDEK+1) ! jak1
        XPAR(1072) = IW(JGDEK+2) ! jak2
        XPAR(1073) = IW(JGDEK+3) ! itdkrc
        XPAR(1074) = IW(JGDEK+4) ! ifphot
        XPAR(1075) = IW(JGDEK+5) ! ifhadm
        XPAR(1076) = IW(JGDEK+6) ! ifhadp
      ENDIF
C
C Data card MSKW
C
      NAMSKW = NAMIND('MSKW')
      JMSKW = IW(NAMSKW)
      IF(JMSKW.NE.0) THEN
        DO imask = 1, 81
          XPAR (1100+imask) = IW(JMSKW+imask)
        END DO
      ENDIF
C
C Data card MSKZ
C
      NAMSKZ = NAMIND('MSKZ')
      JMSKZ = IW(NAMSKZ)
      IF(JMSKZ.NE.0) THEN
        DO imask = 1, 121
          XPAR (1181+imask) = IW(JMSKZ+imask)
        END DO
      ENDIF
C
C Data card XPAR (any input parameter in case it's not foreseen in a card)
C
      NAMI=NAMIND('XPAR')
      IF (IW(NAMI).EQ.0) GOTO 50
      KIND=NAMI+1
 15   KIND=IW(KIND-1)
      IF (KIND.EQ.0) GOTO 49
      LUPAR = LUPAR+1
      XPAR(IW(KIND-2)) = DBLE(RW(KIND+1))
      GOTO 15
 49   CONTINUE
      CALL BKFMT ('XPAR','F')
      CALL BLIST (IW,'C+','XPAR')
 50   CONTINUE
c Return
      RETURN
      END

************************************************************************

      SUBROUTINE KORALWINI_CHECK (XPAR)
C--------------------------------------------------------------------
C Check internal consistency of values of XPAR (change them if needed) 
C A.Valassi 2001
C Input: 
C - XPAR array
C - /INOUT/ common
C Output:
C - XPAR array
C--------------------------------------------------------------------
      IMPLICIT NONE
      INTEGER npar
      PARAMETER (npar=10000)
      DOUBLE PRECISION xpar(npar) ! array for input parameters
      INTEGER          inut, iout
      COMMON / INOUT / INUT, IOUT
      INTEGER keywgt, keymas, keywu, keyzet
      REAL amaw,     gammw
      REAL amaw_run, gammw_run
      REAL amaz,     gammz
      REAL amaz_run, gammz_run
C
C  Consistency checks between switches
C
      KeyWgt = xpar(1031)
      KeyMas = xpar(1022)
      IF ((KeyWgt.NE.0).or.(KeyMas.NE.1)) THEN
        xpar(1071) = -1    ! JAK1   = -1
        xpar(1072) = -1    ! JAK2   = -1
        xpar(1073) =  0    ! ITDKRC = 0
        xpar(1074) =  0    ! IFPHOT = 0
        xpar(1075) =  0    ! IFHADM = 0
        xpar(1076) =  0    ! IFHADP = 0
        WRITE (IOUT,*)
        if (KeyWgt.NE.0) WRITE (IOUT,*)
     +  '+++ASKUSI+++ Weighted events required -> no fragmentation'
        WRITE (IOUT,*)
        if (KeyMas.NE.1) WRITE (IOUT,*)
     +  '+++ASKUSI+++ Massless kinematics required -> no fragmentation'
        WRITE (IOUT,*)
     +  '             (GDEK card values superseeded)'
        WRITE (IOUT,*)
      ENDIF
C
C  Warn the user that the W width may be not compatible to other inputs
C
      gammw  =  XPAR(7)
      IF (GAMMW.GT.0E0) THEN
        WRITE (IOUT,*)
        WRITE (IOUT,
     +       '(A45,f10.7)')
     +       '+++ASKUSI+++ W width (user input) will be ', gammw
        WRITE (IOUT,*)
     +       '             Why not let KORALW compute it instead?!' 
        WRITE (IOUT,*)
      ENDIF
C
C Warn user if fixed width is used in the calculation for either W or Z.
C
      amaz   = XPAR(4)
      gammz  = XPAR(5)
      KeyZet = XPAR(1023)
      IF (KeyZet.EQ.1) THEN
        amaz_run  = amaz  * (1. + gammz**2/amaz**2/2.)
        gammz_run = gammz * (1. + gammz**2/amaz**2/2.)
        WRITE (IOUT,*)
        WRITE (IOUT,*)
     +  '+++ASKUSI+++ Fixed Z width required'
        WRITE (IOUT,*)
     +  ' !!!!!! Be aware of resulting MASS SHIFT !!!!!!'
        WRITE (IOUT,*)
     +  ' Ref. Phys.Lett.B206(1988)539; CERN96-01,vol.1,page153'
        WRITE (IOUT,111) gammz
 111    FORMAT
     +('  Z width (fixed width) is ',f8.5,' GeV')
        WRITE (IOUT,112) gammz_run
 112    FORMAT
     +('  ===> corresponds to Z width (running width) of ',f8.5,' GeV')
        WRITE (IOUT,113) amaz
 113    FORMAT
     +('  Z mass  (fixed width) is ',f8.5,' GeV')
        WRITE (IOUT,114) amaz_run
 114    FORMAT
     +('  ===> corresponds to Z mass  (running width) of ',f8.5,' GeV')
        WRITE (IOUT,*)
      ENDIF
C
      amaw   = XPAR(6)
      gammw  = XPAR(7)
      KeyWu = XPAR(1026)
      IF (KeyWu.EQ.1) THEN
        amaw_run  = amaw  * (1. + gammw**2/amaw**2/2.)
        gammw_run = gammw * (1. + gammw**2/amaw**2/2.)
        WRITE (IOUT,*)
        WRITE (IOUT,*)
     +  '+++ASKUSI+++ Fixed W width required'
        WRITE (IOUT,*)
     +  ' !!!!!! Be aware of resulting MASS SHIFT !!!!!!'
        WRITE (IOUT,*)
     +  ' Ref. Phys.Lett.B206(1988)539; CERN96-01,vol.1,page153'
        WRITE (IOUT,211) gammw
 211    FORMAT
     +('  W width (fixed width) is ',f8.5,' GeV')
        WRITE (IOUT,212) gammw_run
 212    FORMAT
     +('  ===> corresponds to W width (running width) of ',f8.5,' GeV')
        WRITE (IOUT,213) amaw
 213    FORMAT
     +('  W mass  (fixed width) is ',f8.5,' GeV')
        WRITE (IOUT,214) amaw_run
 214    FORMAT
     +('  ===> corresponds to W mass  (running width) of ',f8.5,' GeV')
        WRITE (IOUT,*)
      ENDIF
c Return
      RETURN
      END

************************************************************************

      SUBROUTINE KRLW03INI_USER(userpar)
C-----------------------------------------------------------------------
C Read data cards for KRLW03-specific parameters
C Initialize event statistics
C A.Valassi 2001
C B.Bloch May 2002 add data card GPT2
C Input:
C - common block INOUT  
C - data cards   GDMW, GCWW,   GCZZ,   GCE1,   GCE2,   GCUU,   GCEE,GPT2
C Output: 
C - common blocks KWGDMW, KWCTWW, KWCTZZ, KWCTE1, KWCTE2, KWCTUU, KWCTEE
C                 KWCTPT
C - common block  USLCTO
C-----------------------------------------------------------------------
      IMPLICIT NONE
      REAL userpar(132)
      INTEGER           inut, iout
      COMMON / INOUT /  INUT, IOUT
      INTEGER    LBCS
      PARAMETER (LBCS=1000)
      INTEGER IW(LBCS)
      REAL    RW(LBCS)
      COMMON /BCS/ IW
      EQUIVALENCE (RW(1),IW(1))
      INTEGER NAMIND
      INTEGER NAGDMW, JGDMW
      INTEGER NAGCWW, JGCWW
      INTEGER NAGCZZ, JGCZZ
      INTEGER NAGCE1, JGCE1
      INTEGER NAGCPT, JGCPT, NAGCEL, JGCEL
      INTEGER NAGCE2, JGCE2
      INTEGER NAGCUU, JGCUU
      INTEGER NAGCEE, JGCEE
      REAL*4            dmwmmp
      COMMON / KWDMW  / dmwmmp                                         !cav
      LOGICAL           xgcww, xgczz, xgce1, xgce2, xgcuu, xgcee,xgcpt
     &                 ,xgcel
      COMMON / KWCUTS / xgcww, xgczz, xgce1, xgce2, xgcuu, xgcee,xgcpt !cav
     &                 ,xgcel
      REAL*4            spminww,  spmaxww,
     &                  e1minww,  e2minww,  e3minww,  e4minww,
     &                  e1maxww,  e2maxww,  e3maxww,  e4maxww,
     &                  s12minww, s13minww, s14minww, 
     &                  s23minww, s24minww, s34minww,
     &                  s12maxww, s13maxww, s14maxww, 
     &                  s23maxww, s24maxww, s34maxww,
     &                  c1minww,  c2minww,  c3minww,  c4minww,
     &                  c1maxww,  c2maxww,  c3maxww,  c4maxww,
     &                  c12minww, c13minww, c14minww, 
     &                  c23minww, c24minww, c34minww,
     &                  c12maxww, c13maxww, c14maxww, 
     &                  c23maxww, c24maxww, c34maxww
      COMMON / KWCTWW / spminww,  spmaxww,                             !cav
     &                  e1minww,  e2minww,  e3minww,  e4minww,
     &                  e1maxww,  e2maxww,  e3maxww,  e4maxww,
     &                  s12minww, s13minww, s14minww, 
     &                  s23minww, s24minww, s34minww,
     &                  s12maxww, s13maxww, s14maxww, 
     &                  s23maxww, s24maxww, s34maxww,
     &                  c1minww,  c2minww,  c3minww,  c4minww,
     &                  c1maxww,  c2maxww,  c3maxww,  c4maxww,
     &                  c12minww, c13minww, c14minww, 
     &                  c23minww, c24minww, c34minww,
     &                  c12maxww, c13maxww, c14maxww, 
     &                  c23maxww, c24maxww, c34maxww
      REAL*4            spminzz,  spmaxzz,
     &                  e1minzz,  e2minzz,  e3minzz,  e4minzz,
     &                  e1maxzz,  e2maxzz,  e3maxzz,  e4maxzz,
     &                  s12minzz, s13minzz, s14minzz, 
     &                  s23minzz, s24minzz, s34minzz,
     &                  s12maxzz, s13maxzz, s14maxzz, 
     &                  s23maxzz, s24maxzz, s34maxzz,
     &                  c1minzz,  c2minzz,  c3minzz,  c4minzz,
     &                  c1maxzz,  c2maxzz,  c3maxzz,  c4maxzz,
     &                  c12minzz, c13minzz, c14minzz, 
     &                  c23minzz, c24minzz, c34minzz,
     &                  c12maxzz, c13maxzz, c14maxzz, 
     &                  c23maxzz, c24maxzz, c34maxzz
      COMMON / KWCTZZ / spminzz,  spmaxzz,                             !cav
     &                  e1minzz,  e2minzz,  e3minzz,  e4minzz,
     &                  e1maxzz,  e2maxzz,  e3maxzz,  e4maxzz,
     &                  s12minzz, s13minzz, s14minzz, 
     &                  s23minzz, s24minzz, s34minzz,
     &                  s12maxzz, s13maxzz, s14maxzz, 
     &                  s23maxzz, s24maxzz, s34maxzz,
     &                  c1minzz,  c2minzz,  c3minzz,  c4minzz,
     &                  c1maxzz,  c2maxzz,  c3maxzz,  c4maxzz,
     &                  c12minzz, c13minzz, c14minzz, 
     &                  c23minzz, c24minzz, c34minzz,
     &                  c12maxzz, c13maxzz, c14maxzz, 
     &                  c23maxzz, c24maxzz, c34maxzz
CBB      REAL*4            cmaxem, cminem, cmaxep, cminep
CBB      COMMON / KWCTE1 / cmaxem, cminem, cmaxep, cminep              !cav
      REAL*4            cmaxem, cminem, cmaxep, cminep,cmine,cmaxe     ! bb
      COMMON / KWCTE1 / cmaxem, cminem, cmaxep, cminep,cmine,cmaxe 
      REAL*4            eneme2, enepe2, scute2, ptsme2
      COMMON / KWCTE2 / eneme2, enepe2, scute2, ptsme2                 !cav
      REAL*4            pt2min,pt2max,ee2min,ee2max 
      COMMON / KWCTPT / pt2min,pt2max,ee2min,ee2max                    ! bb
      COMMON / KWCTEL / ctmax,elmax
      REAL*4            ctmax,elmax
      REAL*4            spctuu, scutuu
      COMMON / KWCTUU / spctuu, scutuu                                 !cav
      REAL*4            eemminee, eepminee, efmminee, efpminee,
     &                  eemmaxee, eepmaxee, efmmaxee, efpmaxee,
     &                  seeminee, sffminee,
     &                  seemaxee, sffmaxee,
     &                  cemminee, cepminee, cfmminee, cfpminee,
     &                  cemmaxee, cepmaxee, cfmmaxee, cfpmaxee,
     &                  ceeminee, cffminee,
     &                  ceemaxee, cffmaxee,
     &                  eexminee, eexmaxee,
     &                  cexminee, cexmaxee
      COMMON / KWCTEE / eemminee, eepminee, efmminee, efpminee,         !cav
     &                  eemmaxee, eepmaxee, efmmaxee, efpmaxee,
     &                  seeminee, sffminee,
     &                  seemaxee, sffmaxee,
     &                  cemminee, cepminee, cfmminee, cfpminee,
     &                  cemmaxee, cepmaxee, cfmmaxee, cfpmaxee,
     &                  ceeminee, cffminee,
     &                  ceemaxee, cffmaxee,
     &                  eexminee, eexmaxee,
     &                  cexminee, cexmaxee
      REAL*4            vkwctww(42)
      EQUIVALENCE       (spminww, vkwctww(1))
      REAL*4            vkwctzz(42)
      EQUIVALENCE       (spminzz, vkwctzz(1))
      REAL*4            vkwcte1(6)
      EQUIVALENCE       (cmaxem,  vkwcte1(1))
      REAL*4            vkwctpt(2)
      EQUIVALENCE       (pt2min,  vkwctpt(1))
      REAL*4            vkwcte2(4)
      EQUIVALENCE       (eneme2,  vkwcte2(1))
      REAL*4            vkwctuu(2)
      EQUIVALENCE       (spctuu,  vkwctuu(1))
      REAL*4            vkwctee(28)
      EQUIVALENCE       (eemminee,vkwctee(1))
      INTEGER ipar
      CHARACTER*80 BXOPE, BXTXT, BXL1F, BXCLO
      INTEGER           nphspace
      COMMON / KOPHSP / nphspace(5)                                    !cav
      INTEGER           nselecto
      COMMON / KOSELE / nselecto(4)                                    !cav
      INTEGER           nkwctot,    nkwctww, nkwctzz, 
     &                  nkwcte1,    nkwcte2, nkwctuu, nkwctee,nkwctpt
      COMMON / USLCTO / nkwctot(3), nkwctww, nkwctzz,                  !cav
     &                  nkwcte1,    nkwcte2, nkwctuu, nkwctee ,nkwctpt !cav
      INTEGER           nevovrwgt, nevnegwgt
      COMMON / OVRWGT / nevovrwgt, nevnegwgt                           !cav
C
C GDMW data card
C
      DMWMMP = 0E0              ! Mass difference between W- and W+ [GeV]
      NAGDMW = NAMIND('GDMW')
      JGDMW  = IW(NAGDMW)
      IF(JGDMW.NE.0) THEN
        DMWMMP = RW(JGDMW+1)
      ENDIF
C
C GCWW data card (WW-like events: common block /KWCTWW/)
C
      XGCWW  = .false.
      CALL vzero(vkwctww,42)
      NAGCWW = NAMIND('GCWW')
      JGCWW  = IW(NAGCWW)
      IF(JGCWW.NE.0) THEN
        XGCWW  = .true.
        SPMINWW  = RW(JGCWW+1)
        SPMINWW  = RW(JGCWW+2)
        E1MINWW  = RW(JGCWW+3)
        E2MINWW  = RW(JGCWW+4)
        E3MINWW  = RW(JGCWW+5)
        E4MINWW  = RW(JGCWW+6)
        E1MAXWW  = RW(JGCWW+7)
        E2MAXWW  = RW(JGCWW+8)
        E3MAXWW  = RW(JGCWW+9)
        E4MAXWW  = RW(JGCWW+10)
        S12MINWW = RW(JGCWW+11)
        S13MINWW = RW(JGCWW+12)
        S14MINWW = RW(JGCWW+13)
        S23MINWW = RW(JGCWW+14)
        S24MINWW = RW(JGCWW+15)
        S34MINWW = RW(JGCWW+16)
        S12MAXWW = RW(JGCWW+17)
        S13MAXWW = RW(JGCWW+18)
        S14MAXWW = RW(JGCWW+19)
        S23MAXWW = RW(JGCWW+20)
        S24MAXWW = RW(JGCWW+21)
        S34MAXWW = RW(JGCWW+22)
        C1MINWW  = RW(JGCWW+23)
        C2MINWW  = RW(JGCWW+24)
        C3MINWW  = RW(JGCWW+25)
        C4MINWW  = RW(JGCWW+26)
        C1MAXWW  = RW(JGCWW+27)
        C2MAXWW  = RW(JGCWW+28)
        C3MAXWW  = RW(JGCWW+29)
        C4MAXWW  = RW(JGCWW+30)
        C12MINWW = RW(JGCWW+31)
        C13MINWW = RW(JGCWW+32)
        C14MINWW = RW(JGCWW+33)
        C23MINWW = RW(JGCWW+34)
        C24MINWW = RW(JGCWW+35)
        C34MINWW = RW(JGCWW+36)
        C12MAXWW = RW(JGCWW+37)
        C13MAXWW = RW(JGCWW+38)
        C14MAXWW = RW(JGCWW+39)
        C23MAXWW = RW(JGCWW+40)
        C24MAXWW = RW(JGCWW+41)
        C34MAXWW = RW(JGCWW+42)
      ENDIF
C
C GCZZ data card (ZZ-like events: common block /KWCTZZ/)
C
      XGCZZ  = .false.
      CALL vzero(vkwctzz,42)
      NAGCZZ = NAMIND('GCZZ')
      JGCZZ  = IW(NAGCZZ)
      IF(JGCZZ.NE.0) THEN
        XGCZZ  = .true.
        SPMINZZ  = RW(JGCZZ+1)
        SPMINZZ  = RW(JGCZZ+2)
        E1MINZZ  = RW(JGCZZ+3)
        E2MINZZ  = RW(JGCZZ+4)
        E3MINZZ  = RW(JGCZZ+5)
        E4MINZZ  = RW(JGCZZ+6)
        E1MAXZZ  = RW(JGCZZ+7)
        E2MAXZZ  = RW(JGCZZ+8)
        E3MAXZZ  = RW(JGCZZ+9)
        E4MAXZZ  = RW(JGCZZ+10)
        S12MINZZ = RW(JGCZZ+11)
        S13MINZZ = RW(JGCZZ+12)
        S14MINZZ = RW(JGCZZ+13)
        S23MINZZ = RW(JGCZZ+14)
        S24MINZZ = RW(JGCZZ+15)
        S34MINZZ = RW(JGCZZ+16)
        S12MAXZZ = RW(JGCZZ+17)
        S13MAXZZ = RW(JGCZZ+18)
        S14MAXZZ = RW(JGCZZ+19)
        S23MAXZZ = RW(JGCZZ+20)
        S24MAXZZ = RW(JGCZZ+21)
        S34MAXZZ = RW(JGCZZ+22)
        C1MINZZ  = RW(JGCZZ+23)
        C2MINZZ  = RW(JGCZZ+24)
        C3MINZZ  = RW(JGCZZ+25)
        C4MINZZ  = RW(JGCZZ+26)
        C1MAXZZ  = RW(JGCZZ+27)
        C2MAXZZ  = RW(JGCZZ+28)
        C3MAXZZ  = RW(JGCZZ+29)
        C4MAXZZ  = RW(JGCZZ+30)
        C12MINZZ = RW(JGCZZ+31)
        C13MINZZ = RW(JGCZZ+32)
        C14MINZZ = RW(JGCZZ+33)
        C23MINZZ = RW(JGCZZ+34)
        C24MINZZ = RW(JGCZZ+35)
        C34MINZZ = RW(JGCZZ+36)
        C12MAXZZ = RW(JGCZZ+37)
        C13MAXZZ = RW(JGCZZ+38)
        C14MAXZZ = RW(JGCZZ+39)
        C23MAXZZ = RW(JGCZZ+40)
        C24MAXZZ = RW(JGCZZ+41)
        C34MAXZZ = RW(JGCZZ+42)
      ENDIF
C
C GCE1 data card (>=1 e+/e-: common block /KWCTE1/)
C
      XGCE1  = .false.
      CALL vzero(vkwcte1,6)
      NAGCE1 = NAMIND('GCE1')
      JGCE1  = IW(NAGCE1)
      IF(JGCE1.NE.0) THEN
        XGCE1  = .true.
        CMAXEM = RW(JGCE1+1)
        CMINEM = RW(JGCE1+2)
        CMAXEP = RW(JGCE1+3)
        CMINEP = RW(JGCE1+4)
        CMINE  = RW(JGCE1+5)
        CMAXE  = RW(JGCE1+6)
CBB     call hbook1(111,'cost e-',50,.998,1.,0.)
CBB     call hbook1(112,'cost e+',50,-1.,-0.998,0.)
CBB     call hbook1(211,'cost e+',50,-0.98,0.98,0.)
CBB     call hbook1(212,'cost e-',50,-0.98,0.98,0.)
      ENDIF
C
C GPT2 data card (any event: common block /KWCTPT/)
C
      XGCPT  = .false.
      CALL vzero(vkwctpt,2)
      NAGCPT = NAMIND('GPT2')
      JGCPT  = IW(NAGCPT)
      IF(JGCPT.NE.0) THEN
        XGCPT  = .true.
        ee2min = 8.d0  ! default xpar(15)
        ee2max = 1.d20
        PT2MIN = RW(JGCPT+1)
        PT2MAX = RW(JGCPT+2)
        if (iw(JGCPT).gt.2) then
            ee2min = RW(JGCPT+3)
            ee2max = RW(JGCPT+4)
        endif
      ENDIF
C
C GELE card to require at least one elctron(positon)
C      in an angular range ans some minimum energy
      XGCEL  = .false.
      NAGCEL = NAMIND('GCEL')
      JGCEL  = IW(NAGCEL)
      IF(JGCEL.NE.0) THEN
         XGCEL  = .true.
         CTMAX = RW(JGCEL+1)
         ELMAX = RW(JGCEL+2)
      ENDIF      
C
C GCE2 data card (e+e-nue~nue: common block /KWCTE2/)
C
      XGCE2  = .false.
      CALL vzero(vkwcte2,4)
      NAGCE2 = NAMIND('GCE2')
      JGCE2  = IW(NAGCE2)
      IF(JGCE2.NE.0) THEN
        XGCE2  = .true.
        ENEME2 = RW(JGCE2+1)
        ENEPE2 = RW(JGCE2+2)
        SCUTE2 = RW(JGCE2+3)
        PTSME2 = RW(JGCE2+4)
      ENDIF
C
C GCUU data card (udud events: common block /KWCTUU/)
C
      XGCUU  = .false.
      CALL vzero(vkwctuu,2)
      NAGCUU = NAMIND('GCUU')
      JGCUU  = IW(NAGCUU)
      IF(JGCUU.NE.0) THEN
        XGCUU  = .true.
        SPCTUU = RW(JGCUU+1)
        SCUTUU = RW(JGCUU+2)
      ENDIF
C
C GCEE data card (e+e-x+x-: common block /KWCTEE/)
C
      XGCEE  = .false.
      CALL vzero(vkwctee,28)
      NAGCEE = NAMIND('GCEE')
      JGCEE  = IW(NAGCEE)
      IF(JGCEE.NE.0) THEN
        XGCEE    = .true.
        EEMMINEE = RW(JGCEE+1)
        EEPMINEE = RW(JGCEE+2)
        EFMMINEE = RW(JGCEE+3)
        EFPMINEE = RW(JGCEE+4)
        EEMMAXEE = RW(JGCEE+5)
        EEPMAXEE = RW(JGCEE+6)
        EFMMAXEE = RW(JGCEE+7)
        EFPMAXEE = RW(JGCEE+8)
        SEEMINEE = RW(JGCEE+9)
        SFFMINEE = RW(JGCEE+10)
        SEEMAXEE = RW(JGCEE+11)
        SFFMAXEE = RW(JGCEE+12)
        CEMMINEE = RW(JGCEE+13)
        CEPMINEE = RW(JGCEE+14)
        CFMMINEE = RW(JGCEE+15)
        CFPMINEE = RW(JGCEE+16)
        CEMMAXEE = RW(JGCEE+17)
        CEPMAXEE = RW(JGCEE+18)
        CFMMAXEE = RW(JGCEE+19)
        CFPMAXEE = RW(JGCEE+20)
        CEEMINEE = RW(JGCEE+21)
        CFFMINEE = RW(JGCEE+22)
        CEEMAXEE = RW(JGCEE+23)
        CFFMAXEE = RW(JGCEE+24)
        EEXMINEE = RW(JGCEE+25)
        EEXMAXEE = RW(JGCEE+26)
        CEXMINEE = RW(JGCEE+27)
        CEXMAXEE = RW(JGCEE+28)
      ENDIF
C
C Fill userpar array
C
      DO ipar = 1, 129
        userpar(ipar) = 0
      END DO
*userpar(1)
      userpar(1) = dmwmmp
*userpar(2)
      IF (xgcww) 
     &     userpar(2) = 1
*userpar(3-44)
      DO ipar = 1, 42
        userpar(2+ipar) = vkwctww(ipar)
      END DO
*userpar(45)
      IF (xgcww) 
     &     userpar(45) = 1
*userpar(46-87)
      DO ipar = 1, 42
        userpar(45+ipar) = vkwctzz(ipar)
      END DO
*userpar(88)
      IF (xgce1) 
     &     userpar(88) = 1
*userpar(89-92)
      DO ipar = 1, 4
        userpar(88+ipar) = vkwcte1(ipar)
      END DO
*userpar(93)
      IF (xgce2) 
     &     userpar(93) = 1
*userpar(94-97)
      DO ipar = 1, 4
        userpar(93+ipar) = vkwcte2(ipar)
      END DO
*userpar(98)
      IF (xgcuu) 
     &     userpar(98) = 1
*userpar(99-100)
      DO ipar = 1, 2
        userpar(98+ipar) = vkwctuu(ipar)
      END DO
*userpar(101)
      IF (xgcee) 
     &     userpar(101) = 1
*userpar(102-129)
      DO ipar = 1, 28
        userpar(101+ipar) = vkwctee(ipar)
      END DO
*userpar(130)
      IF (xgcpt) 
     &     userpar(130) = 1
*userpar(131-132)
      DO ipar = 1, 2
        userpar(130+ipar) = vkwctpt(ipar)
      END DO
C
C  Print out cuts used in generation
C
      BXOPE =  '(//1X,15(5H*****)    )'
      BXTXT =  '(1X,1H*,                  A48,25X,    1H*)'
      BXL1F =  '(1X,1H*,F17.8,               12X, A30,7X,A6, 1X,1H*)'
      BXCLO =  '(1X,15(5H*****)/   )'
      WRITE(IOUT,BXOPE)
      WRITE(IOUT,BXTXT) '  +++ASKUSI+++ Following cuts will be   '
      WRITE(IOUT,BXTXT) '    applied on final state fermions     '
      WRITE(IOUT,BXTXT) '                                        '
      WRITE(IOUT,BXTXT) '[GCWW] WW-like (including ZZ overlap):  '
      IF (xgcww) THEN
      WRITE(IOUT,BXL1F)  spminww,'Min sqrt(sp) after ISR      ',' spmiw'
      WRITE(IOUT,BXL1F)  spmaxww,'Max sqrt(sp) after ISR      ',' spmaw'
      WRITE(IOUT,BXL1F)  e1minww,'Min energy fermion 1        ',' e1miw'
      WRITE(IOUT,BXL1F)  e2minww,'Min energy fermion 2        ',' e2miw'
      WRITE(IOUT,BXL1F)  e3minww,'Min energy fermion 3        ',' e3miw'
      WRITE(IOUT,BXL1F)  e4minww,'Min energy fermion 4        ',' e4miw'
      WRITE(IOUT,BXL1F)  e1maxww,'Max energy fermion 1        ',' e1maw'
      WRITE(IOUT,BXL1F)  e2maxww,'Max energy fermion 2        ',' e2maw'
      WRITE(IOUT,BXL1F)  e3maxww,'Max energy fermion 3        ',' e3maw'
      WRITE(IOUT,BXL1F)  e4maxww,'Max energy fermion 4        ',' e4maw'
      WRITE(IOUT,BXL1F) s12minww,'Min inv. mass fermions 1-2  ','s12miw'
      WRITE(IOUT,BXL1F) s13minww,'Min inv. mass fermions 1-3  ','s13miw'
      WRITE(IOUT,BXL1F) s14minww,'Min inv. mass fermions 1-4  ','s14miw'
      WRITE(IOUT,BXL1F) s23minww,'Min inv. mass fermions 2-3  ','s23miw'
      WRITE(IOUT,BXL1F) s24minww,'Min inv. mass fermions 2-4  ','s24miw'
      WRITE(IOUT,BXL1F) s34minww,'Min inv. mass fermions 3-4  ','s34miw'
      WRITE(IOUT,BXL1F) s12maxww,'Max inv. mass fermions 1-2  ','s12maw'
      WRITE(IOUT,BXL1F) s13maxww,'Max inv. mass fermions 1-3  ','s13maw'
      WRITE(IOUT,BXL1F) s14maxww,'Max inv. mass fermions 1-4  ','s14maw'
      WRITE(IOUT,BXL1F) s23maxww,'Max inv. mass fermions 2-3  ','s23maw'
      WRITE(IOUT,BXL1F) s24maxww,'Max inv. mass fermions 2-4  ','s24maw'
      WRITE(IOUT,BXL1F) s34maxww,'Max inv. mass fermions 3-4  ','s34maw'
      WRITE(IOUT,BXL1F)  c1minww,'Min cos theta fermion 1     ',' c1miw'
      WRITE(IOUT,BXL1F)  c2minww,'Min cos theta fermion 2     ',' c2miw'
      WRITE(IOUT,BXL1F)  c3minww,'Min cos theta fermion 3     ',' c3miw'
      WRITE(IOUT,BXL1F)  c4minww,'Min cos theta fermion 4     ',' c4miw'
      WRITE(IOUT,BXL1F)  c1maxww,'Max cos theta fermion 1     ',' c1maw'
      WRITE(IOUT,BXL1F)  c2maxww,'Max cos theta fermion 2     ',' c2maw'
      WRITE(IOUT,BXL1F)  c3maxww,'Max cos theta fermion 3     ',' c3maw'
      WRITE(IOUT,BXL1F)  c4maxww,'Max cos theta fermion 4     ',' c4maw'
      WRITE(IOUT,BXL1F) c12minww,'Min cos theta fermions 1-2  ','c12miw'
      WRITE(IOUT,BXL1F) c13minww,'Min cos theta fermions 1-3  ','c13miw'
      WRITE(IOUT,BXL1F) c14minww,'Min cos theta fermions 1-4  ','c14miw'
      WRITE(IOUT,BXL1F) c23minww,'Min cos theta fermions 2-3  ','c23miw'
      WRITE(IOUT,BXL1F) c24minww,'Min cos theta fermions 2-4  ','c24miw'
      WRITE(IOUT,BXL1F) c34minww,'Min cos theta fermions 3-4  ','c34miw'
      WRITE(IOUT,BXL1F) c12maxww,'Max cos theta fermions 1-2  ','c12maw'
      WRITE(IOUT,BXL1F) c13maxww,'Max cos theta fermions 1-3  ','c13maw'
      WRITE(IOUT,BXL1F) c14maxww,'Max cos theta fermions 1-4  ','c14maw'
      WRITE(IOUT,BXL1F) c23maxww,'Max cos theta fermions 2-3  ','c23maw'
      WRITE(IOUT,BXL1F) c24maxww,'Max cos theta fermions 2-4  ','c24maw'
      WRITE(IOUT,BXL1F) c34maxww,'Max cos theta fermions 3-4  ','c34maw'
      ELSE
      WRITE(IOUT,BXTXT) '-----> INACTIVE:                        '
      ENDIF
      WRITE(IOUT,BXTXT) '                                        '
      WRITE(IOUT,BXTXT) '[GCZZ] ZZ-like (including WW overlap):  '
      IF (xgczz) THEN
      WRITE(IOUT,BXL1F)  spminzz,'Min sqrt(sp) after ISR      ',' spmiz'
      WRITE(IOUT,BXL1F)  spmaxzz,'Max sqrt(sp) after ISR      ',' spmaz'
      WRITE(IOUT,BXL1F)  e1minzz,'Min energy fermion 1        ',' e1miz'
      WRITE(IOUT,BXL1F)  e2minzz,'Min energy fermion 2        ',' e2miz'
      WRITE(IOUT,BXL1F)  e3minzz,'Min energy fermion 3        ',' e3miz'
      WRITE(IOUT,BXL1F)  e4minzz,'Min energy fermion 4        ',' e4miz'
      WRITE(IOUT,BXL1F)  e1maxzz,'Max energy fermion 1        ',' e1maz'
      WRITE(IOUT,BXL1F)  e2maxzz,'Max energy fermion 2        ',' e2maz'
      WRITE(IOUT,BXL1F)  e3maxzz,'Max energy fermion 3        ',' e3maz'
      WRITE(IOUT,BXL1F)  e4maxzz,'Max energy fermion 4        ',' e4maz'
      WRITE(IOUT,BXL1F) s12minzz,'Min inv. mass fermions 1-2  ','s12miz'
      WRITE(IOUT,BXL1F) s13minzz,'Min inv. mass fermions 1-3  ','s13miz'
      WRITE(IOUT,BXL1F) s14minzz,'Min inv. mass fermions 1-4  ','s14miz'
      WRITE(IOUT,BXL1F) s23minzz,'Min inv. mass fermions 2-3  ','s23miz'
      WRITE(IOUT,BXL1F) s24minzz,'Min inv. mass fermions 2-4  ','s24miz'
      WRITE(IOUT,BXL1F) s34minzz,'Min inv. mass fermions 3-4  ','s34miz'
      WRITE(IOUT,BXL1F) s12maxzz,'Max inv. mass fermions 1-2  ','s12maz'
      WRITE(IOUT,BXL1F) s13maxzz,'Max inv. mass fermions 1-3  ','s13maz'
      WRITE(IOUT,BXL1F) s14maxzz,'Max inv. mass fermions 1-4  ','s14maz'
      WRITE(IOUT,BXL1F) s23maxzz,'Max inv. mass fermions 2-3  ','s23maz'
      WRITE(IOUT,BXL1F) s24maxzz,'Max inv. mass fermions 2-4  ','s24maz'
      WRITE(IOUT,BXL1F) s34maxzz,'Max inv. mass fermions 3-4  ','s34maz'
      WRITE(IOUT,BXL1F)  c1minzz,'Min cos theta fermion 1     ',' c1miz'
      WRITE(IOUT,BXL1F)  c2minzz,'Min cos theta fermion 2     ',' c2miz'
      WRITE(IOUT,BXL1F)  c3minzz,'Min cos theta fermion 3     ',' c3miz'
      WRITE(IOUT,BXL1F)  c4minzz,'Min cos theta fermion 4     ',' c4miz'
      WRITE(IOUT,BXL1F)  c1maxzz,'Max cos theta fermion 1     ',' c1maz'
      WRITE(IOUT,BXL1F)  c2maxzz,'Max cos theta fermion 2     ',' c2maz'
      WRITE(IOUT,BXL1F)  c3maxzz,'Max cos theta fermion 3     ',' c3maz'
      WRITE(IOUT,BXL1F)  c4maxzz,'Max cos theta fermion 4     ',' c4maz'
      WRITE(IOUT,BXL1F) c12minzz,'Min cos theta fermions 1-2  ','c12miz'
      WRITE(IOUT,BXL1F) c13minzz,'Min cos theta fermions 1-3  ','c13miz'
      WRITE(IOUT,BXL1F) c14minzz,'Min cos theta fermions 1-4  ','c14miz'
      WRITE(IOUT,BXL1F) c23minzz,'Min cos theta fermions 2-3  ','c23miz'
      WRITE(IOUT,BXL1F) c24minzz,'Min cos theta fermions 2-4  ','c24miz'
      WRITE(IOUT,BXL1F) c34minzz,'Min cos theta fermions 3-4  ','c34miz'
      WRITE(IOUT,BXL1F) c12maxzz,'Max cos theta fermions 1-2  ','c12maz'
      WRITE(IOUT,BXL1F) c13maxzz,'Max cos theta fermions 1-3  ','c13maz'
      WRITE(IOUT,BXL1F) c14maxzz,'Max cos theta fermions 1-4  ','c14maz'
      WRITE(IOUT,BXL1F) c23maxzz,'Max cos theta fermions 2-3  ','c23maz'
      WRITE(IOUT,BXL1F) c24maxzz,'Max cos theta fermions 2-4  ','c24maz'
      WRITE(IOUT,BXL1F) c34maxzz,'Max cos theta fermions 3-4  ','c34maz'
      ELSE
      WRITE(IOUT,BXTXT) '-----> INACTIVE:                        '
      ENDIF
      WRITE(IOUT,BXTXT) '                                        '
      WRITE(IOUT,BXTXT) '[GCE1] For e-nu-x-x (incl. e-nu-e-nu):  '
      IF (xgce1) THEN
      WRITE(IOUT,BXL1F) cmaxem,' Max cos theta electron      ','cmaxem'
      WRITE(IOUT,BXL1F) cminem,' Min cos theta electron      ','cminem'
      WRITE(IOUT,BXL1F) cmaxep,' Max cos theta positron      ','cmaxep'
      WRITE(IOUT,BXL1F) cminep,' Min cos theta positron      ','cminep'
      WRITE(IOUT,BXL1F) cmine ,' Min cos theta other lepton  ','cmine'
      WRITE(IOUT,BXL1F) cmaxe ,' Max cos theta other lepton  ','cmaxe'
      ELSE
      WRITE(IOUT,BXTXT) '-----> INACTIVE:                        '
      ENDIF
      WRITE(IOUT,BXTXT) '                                        '
      WRITE(IOUT,BXTXT) '[GPT2] For any WW -4f :                 '
      IF (xgcpt) THEN
      WRITE(IOUT,BXL1F) pt2min,' Min sum pt^2                ','pt2min'
      WRITE(IOUT,BXL1F) pt2max,' Max sum pt^2                ','pt2max'
      write(iout,bxl1f) ee2min,' Min mee^2                   ','ee2min'
      write(iout,bxl1f) ee2max,' Max mee^2                   ','ee2max'
      ELSE
      WRITE(IOUT,BXTXT) '-----> INACTIVE:                        '
      ENDIF
      WRITE(IOUT,BXTXT) '                                        '
      WRITE(IOUT,BXTXT) '[GCEL] For any ZZ -4f :                 '
      IF (xgcel) THEN
      WRITE(IOUT,BXL1F) ctmax,' Max cost lepton              ','ctmax'
      write(iout,bxl1f) elmax,' Min energy lepton            ','elmax'
      ELSE
      WRITE(IOUT,BXTXT) '-----> INACTIVE:                        '
      ENDIF
      WRITE(IOUT,BXTXT) '                                        '
      WRITE(IOUT,BXTXT) '[GCE2] For e-nu-e-nu:                   '
      IF (xgce2) THEN
      WRITE(IOUT,BXL1F) eneme2,' Min energy electron         ','eneme2'
      WRITE(IOUT,BXL1F) enepe2,' Min energy positron         ','enepe2'
      WRITE(IOUT,BXL1F) scute2,' Min invariant mass e+/e-    ','scute2'
      WRITE(IOUT,BXL1F) ptsme2,' Min sum of |pT| e+/e-       ','ptsme2'
      ELSE
      WRITE(IOUT,BXTXT) '-----> INACTIVE:                        '
      ENDIF
      WRITE(IOUT,BXTXT) '                                        '
      WRITE(IOUT,BXTXT) '[GCUU] For u-d-u-d:                     '
      IF (xgcuu) THEN
      WRITE(IOUT,BXL1F) spctuu,' Min sqrt(s_prime) after ISR ','spctuu'
      WRITE(IOUT,BXL1F) scutuu,' Min invariant mass uu or dd ','scutuu'
      ELSE
      WRITE(IOUT,BXTXT) '-----> INACTIVE:                        '
      ENDIF
      WRITE(IOUT,BXTXT) '                                        '
      WRITE(IOUT,BXTXT) '[GCEE] e+e-x+x- (not including e-nu-e-nu):'
      IF (xgcee) THEN
      WRITE(IOUT,BXL1F) eemminee,'Min energy e-               ','eemmie'
      WRITE(IOUT,BXL1F) eepminee,'Min energy e+               ','eepmie'
      WRITE(IOUT,BXL1F) efmminee,'Min energy fermion x        ','efmmie'
      WRITE(IOUT,BXL1F) efpminee,'Min energy antifermion x    ','efpmie'
      WRITE(IOUT,BXL1F) eemmaxee,'Max energy e-               ','eemmae'
      WRITE(IOUT,BXL1F) eepmaxee,'Max energy e+               ','eepmae'
      WRITE(IOUT,BXL1F) efmmaxee,'Max energy fermion x        ','efmmae'
      WRITE(IOUT,BXL1F) efpmaxee,'Max energy antifermion x    ','efpmae'
      WRITE(IOUT,BXL1F) seeminee,'Min inv. mass e+e-          ','seemie'
      WRITE(IOUT,BXL1F) seemaxee,'Max inv. mass e+e-          ','seemae'
      WRITE(IOUT,BXL1F) sffminee,'Min inv. mass x+x-          ','sffmie'
      WRITE(IOUT,BXL1F) sffmaxee,'Max inv. mass x+x-          ','sffmae'
      WRITE(IOUT,BXL1F) cemminee,'Min cos theta e-            ','cemmie'
      WRITE(IOUT,BXL1F) cepminee,'Min cos theta e+            ','cepmie'
      WRITE(IOUT,BXL1F) cfmminee,'Min cos theta fermion x     ','cfmmie'
      WRITE(IOUT,BXL1F) cfpminee,'Min cos theta antifermion x ','cfpmie'
      WRITE(IOUT,BXL1F) cemmaxee,'Max cos theta e-            ','cemmae'
      WRITE(IOUT,BXL1F) cepmaxee,'Max cos theta e+            ','cepmae'
      WRITE(IOUT,BXL1F) cfmmaxee,'Max cos theta fermion x     ','cfmmae'
      WRITE(IOUT,BXL1F) cfpmaxee,'Max cos theta antifermion x ','cfpmae'
      WRITE(IOUT,BXL1F) ceeminee,'Min cos theta e+e-          ','ceemie'
      WRITE(IOUT,BXL1F) ceemaxee,'Max cos theta e+e-          ','ceemae'
      WRITE(IOUT,BXL1F) cffminee,'Min cos theta x+x-          ','cffmie'
      WRITE(IOUT,BXL1F) cffmaxee,'Max cos theta x+x-          ','cffmae'
      WRITE(IOUT,BXL1F) eexminee,'Min energy e- or e+ (3 on 4)','eexmie'
      WRITE(IOUT,BXL1F) eexmaxee,'Max energy e- or e+ (3 on 4)','eexmie'
      WRITE(IOUT,BXL1F) cexminee,'Min cos th e- or e+ (3 on 4)','cexmie'
      WRITE(IOUT,BXL1F) cexmaxee,'Max cos th e- or e+ (3 on 4)','cexmae'
      ELSE
      WRITE(IOUT,BXTXT) '-----> INACTIVE:                        '
      ENDIF
      WRITE(IOUT,BXCLO)
C
C Initialise statistics
C
      nphspace(1) = 0
      nphspace(2) = 0
      nphspace(3) = 0
      nphspace(4) = 0
      nphspace(5) = 0
      nselecto(1) = 0
      nselecto(2) = 0
      nselecto(3) = 0
      nselecto(4) = 0
      nkwctot(1)  = 0
      nkwctot(2)  = 0
      nkwctot(3)  = 0
      nkwctpt     = 0
      nkwctww     = 0
      nkwctzz     = 0
      nkwcte1     = 0
      nkwcte2     = 0
      nkwctuu     = 0
      nkwctee     = 0
      nevovrwgt   = 0
      nevnegwgt   = 0
C Return
      RETURN
      END

************************************************************************

      SUBROUTINE KRLW03INI_JETSET(xpar)
C--------------------------------------------------------------------
C Initialize Jetset stuff for KRLW03
C A.Valassi 2001
C Input: 
C - INOUT common block
C - KORALW XPAR array
C Output:
C - modified PART bank
C - modified Jetset common blocks
C--------------------------------------------------------------------
      IMPLICIT NONE
      INTEGER npar
      PARAMETER (npar=10000)
      DOUBLE PRECISION xpar(npar) ! array for input parameters
C Input/output units
      INTEGER          inut, iout
      COMMON / INOUT / INUT, IOUT
C Banks PART and KLIN
      INTEGER napart, naklin
C Jetset commons
      INTEGER L1MST, L1PAR
      INTEGER L2PAR, L2PARF
      PARAMETER (L1MST=200, L1PAR=200)
      PARAMETER (L2PAR=500, L2PARF=2000 )
      INTEGER MSTU, MSTJ
      REAL    PARU, PARJ
      INTEGER KCHG
      REAL    PMAS, PARF, VCKM
      INTEGER MDCY, MDME, KFDP
      REAL    BRAT
      COMMON /LUDAT1/ MSTU(L1MST),PARU(L1PAR),MSTJ(L1MST),PARJ(L1PAR)
      COMMON /LUDAT2/ KCHG(L2PAR,3),PMAS(L2PAR,4),PARF(L2PARF),VCKM(4,4)
      COMMON /LUDAT3/ 
     &     MDCY(L2PAR,3),MDME(L2PARF,2),BRAT(L2PARF),KFDP(L2PARF,5)
C Set Jetset masses and widths
      INTEGER lucomp
      INTEGER namind
      INTEGER kgpart
      INTEGER JPART, IPART, KPART, IANTI, KAPAR
      REAL MAS, WID
C Inhibit decays
      INTEGER nlink
      INTEGER LPDEC
      PARAMETER (LPDEC = 48)
      INTEGER NODEC(LPDEC)
      INTEGER MXDEC, KNODEC, IDEC, JIDB
C BOS stuff
      INTEGER    LBCS
      PARAMETER (LBCS=1000)
      COMMON /BCS/ IW(LBCS)
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C BOS macros
      INTEGER    LMHLEN
      PARAMETER (LMHLEN=2)
      INTEGER ID, NRBOS, L
      INTEGER LCOLS, LROWS, KNEXT, KROW, LFRWRD, LFRROW, ITABL
      REAL RTABL
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
C Initialization particle data  mod BB march 98
C
      CALL KXL74A (naPART,naKLIN)
      IF (naPART.LE.0 .OR. naKLIN.LE.0) THEN
        WRITE (IOUT,
     &       '(1X,''ASKUSI :error in PART or KLIN bank - STOP - '',2I3)'
     &       ) naPART, naKLIN
        STOP
      ENDIF
C
C Modify Lund masses according to input masses
C
      PMAS(LUCOMP(23),1) = xpar( 4) ! AMAZ
      PMAS(LUCOMP(24),1) = xpar( 6) ! AMAW
      PMAS(LUCOMP(25),1) = xpar(11) ! AMAH
      PMAS(LUCOMP( 7),1) =     170. ! next generation quarks
      PMAS(LUCOMP( 8),1) =     300. ! "
C
C Make sure that masses and width in PART bank are consistent
C Function KGPART returns ALEPH code corresponding to LUND code required
C Z0(lund code=23) top(lund code=6) Higgs(lund code=25) a1(lund code=20213)
C
      JPART = IW(NAMIND('PART'))
C
      IPART = KGPART(23)
      IF (IPART.GT.0)  THEN
        MAS = PMAS(LUCOMP(23),1)
        KPART = KROW(JPART,IPART)
        RW(KPART+6) = MAS
        IANTI = ITABL(JPART,IPART,10)
        IF (IANTI.NE.IPART) THEN
          KAPAR = KROW(JPART,IANTI)
          RW(KAPAR+6) = MAS
        ENDIF
      ENDIF
C
      IPART = KGPART(6)
      IF (IPART.GT.0)  THEN
        MAS = PMAS(LUCOMP( 6),1)
        KPART = KROW(JPART,IPART)
        RW(KPART+6) = MAS
        IANTI = ITABL(JPART,IPART,10)
        IF (IANTI.NE.IPART) THEN
          KAPAR = KROW(JPART,IANTI)
          RW(KAPAR+6) = MAS
        ENDIF
      ENDIF
C
      IPART = KGPART(25)
      IF (IPART.GT.0)  THEN
        MAS = PMAS(LUCOMP(25),1)
        KPART = KROW(JPART,IPART)
        RW(KPART+6) = MAS
        IANTI = ITABL(JPART,IPART,10)
        IF (IANTI.NE.IPART) THEN
          KAPAR = KROW(JPART,IANTI)
          RW(KAPAR+6) = MAS
        ENDIF
      ENDIF
C
      IPART = KGPART(20213)
      IF (IPART.GT.0)  THEN
        MAS = PMAS(LUCOMP(20213),1)
        WID = PMAS(LUCOMP(20213),2)
        KPART = KROW(JPART,IPART)
        RW(KPART+6) = MAS
        RW(KPART+9) = WID
        IANTI = ITABL(JPART,IPART,10)
        IF (IANTI.NE.IPART) THEN
          KAPAR = KROW(JPART,IANTI)
          RW(KAPAR+6) = MAS
          RW(KAPAR+9) = WID
        ENDIF
      ENDIF
C
C Inhibit decays
C
      MXDEC=KNODEC(NODEC,LPDEC)
      MXDEC=MIN(MXDEC,LPDEC)
      IF (MXDEC.GT.0) THEN
        DO IDEC=1,MXDEC
          IF (NODEC(IDEC).GT.0) THEN
            JIDB = NLINK('MDC1',NODEC(IDEC))
            IF (JIDB.EQ.0) MDCY(LUCOMP(NODEC(IDEC)),1)=0
          ENDIF
        END DO
      ENDIF
C
C Keep infos on fragmentation
C
      MSTU(17) = 1
C Return
      RETURN
      END

************************************************************************

      SUBROUTINE KRLW03INI_KANDY(xpar)
C--------------------------------------------------------------------
C Initialize KANDY stuff for KRLW03
C A.Valassi 2001
C B.Bloch sept 2001 make fifo directory run dependent
C Input:
C - XPAR array
C - KandY user data cards
C - /INOUT/  input/output information 
C Output:
C - modified XPAR array
C--------------------------------------------------------------------
      IMPLICIT NONE
      INTEGER npar
      PARAMETER (npar=10000)
      DOUBLE PRECISION xpar(npar) ! array for input parameters
C Input/output units
      INTEGER          inut, iout
      COMMON / INOUT / INUT, IOUT
C KANDY common
      INTEGER ikandy            ! 0=off 1=weightedKandy 2=unweightedKandy
      CHARACTER*200 chywexe     ! full path to YFSWW executable
      CHARACTER*200 chywout     ! full path to output file for YFSWW
      CHARACTER*200 ch4vect     ! full path to FIFO file to exchange 4vectors
      CHARACTER*200 chwtext     ! full path to FIFO file to exchange weights
      COMMON / K3ANDY / ikandy, chywexe, chywout, ch4vect, chwtext
C Cards YFSW and YOUT
      CHARACTER*4  CNAME        ! ACDARG input:  card name
      CHARACTER*10 DTYPE        ! ACDARG input:  default file type (ignored)
      PARAMETER (dtype=' ')
      CHARACTER*4  DMODE        ! ACDARG input:  IBM-VM mode (ignored)
      PARAMETER (dmode=' ')
      CHARACTER*80 FNAME        ! ACDARG output: file name
      CHARACTER*10 ATYPE        ! ACDARG output: Aleph type (ignored)
      CHARACTER*4  FDEVI        ! ACDARG output: device type (ignored)
      INTEGER      ier          ! ACDARG output: 0=OK, #0=problems
C BOS stuff
      INTEGER    LBCS
      PARAMETER (LBCS=1000)
      COMMON /BCS/ IW(LBCS)
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C Card YUNW
      INTEGER namind
      INTEGER NAYUNW, JYUNW
C System calls
      INTEGER system            ! intrinsic system function
      INTEGER isys              ! error return code
C Filename manipulations 
      INTEGER lnblnk            ! external function (remove trailing blanks)
      CHARACTER*80  chaleph     ! ALEPH directory
      CHARACTER*80  chuser      ! user name
      CHARACTER*200 chfifo      ! subdirectory of /tmp/ where FIFO are stored
      CHARACTER*80  chos        ! OS name
      INTEGER NARUN,JRUN,numrun
      character*4 cfromi,charun
      external cfromi
C  get run number in numrun
      NARUN = NAMIND('RUN ')
      JRUN  = IW(NARUN)
      IF(JRUN.NE.0) THEN
        charun = '0000'
        numrun = IW(JRUN+1)
        call csetdi(numrun,charun,1,4)
        print *,' run number is ',numrun,' caract ',charun
      ENDIF
C
C YFSWW is invoked only if card YFSW is present
C Card read using ACDARG (as in PHOT02 generator for card GMAP)
C
      cname = 'YFSW'
      CALL ACDARG(CNAME,DTYPE,DMODE,FNAME,ATYPE,FDEVI,ier)
      IF     (ier.LT.0) THEN
* ier<0 means that no card was found: skip Kandy
        ikandy = 0              ! no Kandy
        WRITE(iout,*) '_KRLW03INI_KANDY Card YFSW not found'
        WRITE(iout,*) '==> No O(alpha) reweighting with YFSWW'
      ELSE
* ier>=0 means that a card was found (with or without errors)
        ikandy = 1              ! unweighted Koralw, weighted Kandy events
        WRITE(iout,*) '_KRLW03INI_KANDY Card YFSW found: ier =',ier
        IF (ier.EQ.0) THEN
          IF (atype.EQ.' ') THEN
* ier=0 is an Alephlib success status code, but filetype is empty
* for us, this means that no filename was given
            WRITE(iout,*) '--> No filename given in card'
            CALL getenv('ALEPH',chaleph)
            chywexe = chaleph(1:lnblnk(chaleph))//'/ywrewt.exe'
            WRITE(iout,*) '==> Execute Kandy default executable:' 
            WRITE(iout,*) chywexe(1:lnblnk(chywexe))
          ELSE
* ier=0 and an Aleph file type (NATIVE, EPIO, EDIR, DAF, CARDS, HIS)
* for us, this is not what we want (we need an executable)
            WRITE(iout,*) '--> Filename given in card:'
            WRITE(iout,*) fname(1:lnblnk(fname))
            WRITE(iout,*) '--> Executable name has a reserved type:'
            WRITE(iout,*) atype(1:lnblnk(atype))
            WRITE(iout,*) '==> ERROR invalid YFSW card' 
            STOP
          ENDIF
* ier=1 is an Alephlib "error" code: not NATIVE, EPIO, EDIR, DAF, CARDS, HIS
* for us this is the good case instead!
        ELSEIF (ier.EQ.1) THEN
          WRITE(iout,*) '--> Filename given in card:'
          WRITE(iout,*) fname(1:lnblnk(fname))
          chywexe = fname(1:lnblnk(fname))
        ELSE
          WRITE(iout,*) '==> ERROR invalid YFSW card, ier=', ier 
          STOP
        ENDIF
* Check if the required executable exists
        WRITE(iout,*) 
     &       '_KRLW03INI_KANDY Kandy will run YFSWW executable:' 
        WRITE(iout,*) chywexe(1:lnblnk(chywexe))
        isys = system('test -x '//chywexe(1:lnblnk(chywexe)))
        IF (isys.NE.0) THEN
          WRITE(iout,*) 
     &         '==> ERROR file does not exist or is not executable' 
          WRITE(iout,*) 
     &         '==> ERROR isys = ', isys 
          STOP
        ENDIF
      ENDIF
C
C YFSWW by default generates unweighted Koralw events without O(alpha) radcor
C -> however, the O(alpha) weight is stored in bank KWGT for accepted events
C -> faster (by a factor 4!!), but best description given by weighted events 
C If card YUNW is present, unweighted events have O(alpha) corrections
C -> this option sends to YFSWW every event before rejection in Koralw
C -> slower, but best description is exactly that from the output events
C
      IF (ikandy.GT.0) THEN
        NAYUNW = NAMIND('YUNW')
        JYUNW  = IW(NAYUNW)
        IF(JYUNW.NE.0) THEN
          ikandy = 2            ! unweighted Kandy events
        ENDIF
      ENDIF
C
C Check if KandY mode and modify XPAR parameters if necessary
C      
      xpar(1082) = 0            ! K: do not read 4vectors from disk
      xpar(1086) = 0            ! K: do not write weights to disk
      IF     (ikandy.EQ.0) THEN
        xpar(1087) = 0          ! K: do not write 4vectors to disk
        xpar(1088) = 0          ! K: do not read weights from disk
      ELSEIF (ikandy.EQ.1) THEN
        xpar(1087) = 0          ! K: write 4vectors to disk is KRLW03-based
        xpar(1088) = 0          ! K: read weights from disk is KRLW03-based
      ELSE
        xpar(1087) = 3          ! K: write 4vectors to disk (format 3)
        IF ( xpar(1088).NE.1 .AND. xpar(1088).NE.2 )THEN
          xpar(1088) = 1        ! K: read weights from disk (1=add, 2=mult)
        ENDIF
      ENDIF
C
C Remaining code only executed for KandY
C
      IF (ikandy.EQ.0) GOTO 999
      WRITE (iout,*) '_KRLW03INI_KANDY WELCOME TO KANDY!'
C
C Output file of YFSWW is determined by data card YOUT
C If no card is specified, output will be on the same unit as KRLW03...
C
      chywout = ' '
      cname = 'YOUT'
      CALL ACDARG(CNAME,DTYPE,DMODE,FNAME,ATYPE,FDEVI,ier)
      IF     (ier.LT.0) THEN
* ier<0 means that no card was found: output on same unit as KRLW03
        WRITE(iout,*) '_KRLW03INI_KANDY Card YOUT not found'
        WRITE(iout,*) '==> YFSWW output on same files as KRLW03'
      ELSE
* ier>=0 means that a card was found (with or without errors)
        WRITE(iout,*) '_KRLW03INI_KANDY Card YOUT found: ier =',ier
        IF (ier.EQ.0) THEN
          IF (atype.EQ.' ') THEN
* ier=0 is an Alephlib success status code, but filetype is empty
* for us, this means that no filename was given
            WRITE(iout,*) '--> No filename given in card'
            chywout = 'out.ywrewt' ! YFSWW output file 
            WRITE(iout,*) '==> YFSWW output on default logfile:' 
            WRITE(iout,*) chywout(1:lnblnk(chywout))
          ELSE
* ier=0 and an Aleph file type (NATIVE, EPIO, EDIR, DAF, CARDS, HIS)
* for us, this is not what we want (we need a text logfile)
            WRITE(iout,*) '--> Filename given in card:'
            WRITE(iout,*) fname(1:lnblnk(fname))
            WRITE(iout,*) '--> Filename has a reserved type:'
            WRITE(iout,*) atype(1:lnblnk(atype))
            WRITE(iout,*) '==> ERROR invalid YOUT card' 
            STOP
          ENDIF
* ier=1 is an Alephlib "error" code: not NATIVE, EPIO, EDIR, DAF, CARDS, HIS
* for us this is the good case instead!
        ELSEIF (ier.EQ.1) THEN
          WRITE(iout,*) '--> Filename given in card:'
          WRITE(iout,*) fname(1:lnblnk(fname))
          chywout = fname(1:lnblnk(fname))
        ELSE
          WRITE(iout,*) '==> ERROR invalid YOUT card, ier=', ier 
          STOP
        ENDIF
* Check if the required output file exists
        WRITE(iout,*) 
     &       '_KRLW03INI_KANDY Kandy will put YFSWW output on file:' 
        WRITE(iout,*) chywout(1:lnblnk(chywout))
        isys = system('test -e '//chywout(1:lnblnk(chywout)))
        IF (isys.EQ.0) THEN
          WRITE(iout,*) 
     &         '==> ERROR file already exists, isys =', isys 
          STOP
        ELSE
          WRITE(iout,*) 
     &         '==> New file will be created, isys =', isys 
        ENDIF
        isys = system('touch '//chywout(1:lnblnk(chywout)))
        IF (isys.NE.0) THEN
          WRITE(iout,*) 
     &         '==> ERROR cannot create output file, isys =', isys 
          STOP
        ENDIF
      ENDIF
C
C Make FIFO files for UNIX pipes between the two executables
* Get "unique" names for the FIFO files in the /tmp directory
* -> I could not manage to run the standard C library mkstemp under Fortran
* -> To link it I defined a mkstemp_ C function, but the executable crashes
* => The name is unique to a user as it contains the USER environment variable 
* => The name is unique to a host as it is created in the local /tmp/ directory
* => However, one user cannot run more than one KandY process on a given host
* Also notice that only one KandY process (on any host/platform) can run in a 
* given AFS directory at a time (files like 4vect.data.in must be unique...)
      CALL getenv('USER', chuser)
CBB      chfifo  = '/tmp/'//chuser(1:lnblnk(chuser))//'/FIFO/'
      chfifo  = '/tmp/'//chuser(1:lnblnk(chuser))//'/FIFO'//charun//'/'
      ch4vect = chfifo(1:lnblnk(chfifo))//'4vect.data.XXXXXX'
      chwtext = chfifo(1:lnblnk(chfifo))//'wtext.data.XXXXXX'
* Make FIFO files
      isys = system('mkdir -p '//chfifo(1:lnblnk(chfifo)))
      WRITE(iout,*) 
     &     '_KRLW03INI_KANDY Creating FIFO files for KandY in '
     &     //chfifo(1:lnblnk(chfifo))
      isys = system('\rm -f '//ch4vect(1:lnblnk(ch4vect)))
      isys = system('\rm -f '//chwtext(1:lnblnk(chwtext)))
      isys = system('mkfifo '//ch4vect(1:lnblnk(ch4vect)))
      isys = system('mkfifo '//chwtext(1:lnblnk(chwtext)))
* KORALW output (4vectors) and input (weights)
      isys = system('\rm -f 4vect.data.out')
      isys = system('ln -sf '//ch4vect(1:lnblnk(ch4vect))
     &     //' 4vect.data.out')
      isys = system('\rm -f wtext.data.in')
      isys = system('ln -sf '//chwtext(1:lnblnk(chwtext))
     &     //' wtext.data.in')
* YFSWW input (4vectors) and output (weights)
      isys = system('\rm -f 4vect.data.in')
      isys = system('ln -sf '//ch4vect(1:lnblnk(ch4vect))
     &     //' 4vect.data.in')
      isys = system('\rm -f wtext.data.out')
      isys = system('ln -sf '//chwtext(1:lnblnk(chwtext))
     &     //' wtext.data.out')
C
C Now start YFSWW      
C
      WRITE(iout,*) 
     &     '_KRLW03INI_KANDY Running YFSWW in the background:'
      IF (chywout.EQ.' ') THEN
        WRITE(iout,*) chywexe(1:lnblnk(chywexe))//'&'
        isys = system(chywexe(1:lnblnk(chywexe))//'&')
      ELSE
        isys = system('\rm -f '//chywout(1:lnblnk(chywout)))
        WRITE(iout,*) chywexe(1:lnblnk(chywexe))//'>&'
     &       //chywout(1:lnblnk(chywout))//'&'
        CALL getenv('OS', chos)
        IF (chos .EQ. 'OSF1') THEN
          WRITE(iout,*) 
     &         '_KRLW03INI_KANDY Unable to redirect stderr on OSF1'
          WRITE(iout,*) 
     &         '_KRLW03INI_KANDY Only stdout will be redirected'
          WRITE(iout,*) chywexe(1:lnblnk(chywexe))//'>'
     &         //chywout(1:lnblnk(chywout))//'&'
          isys = system(chywexe(1:lnblnk(chywexe))//'>'
     &         //chywout(1:lnblnk(chywout))//'&')
        ELSE
          isys = system(chywexe(1:lnblnk(chywexe))//'&>' ! crashes on OSF1!!
     &         //chywout(1:lnblnk(chywout))//'&')
        ENDIF
      ENDIF
      IF (isys.NE.0) THEN
        WRITE(iout,*) 
     &       '_KRLW03INI_KANDY Could not launch YFSWW'
        STOP
      ENDIF
C
C Write out xpar array to FIFO to have consistent inputs
C FIFO files have limited size: start writing after launching the YFSWW slave!
C
      WRITE (iout,*) 
     &     '_KRLW03INI_KANDY Writing YFSWW input parameters to FIFO'
      CALL writer_xpar(npar, xpar)
      WRITE (iout,*) 
     &     '_KRLW03INI_KANDY Initialisation completed'
C
C Return
C
 999  CONTINUE
      RETURN
      END

************************************************************************

      SUBROUTINE KRLW03INI_TAUOLA
C--------------------------------------------------------------------
C Initialize TAUOLA stuff for KRLW03
C A.Valassi 2001
C Input:
C - TAUBRA and TAUKLE common blocks
C - GKBR bank
C - INOUT common block
C Output:
C - TAUBRA and TAUKLE common blocks
C - KORL bank
C--------------------------------------------------------------------
      IMPLICIT NONE
C Input/output units
      INTEGER          inut, iout
      COMMON / INOUT / INUT, IOUT
C TAUOLA commons
      INTEGER           JLIST,NCHAN
      REAL*4            GAMPRT
      COMMON / TAUBRA / GAMPRT(30),JLIST(30),NCHAN
      REAL*4            BRA1,BRK0,BRK0B,BRKS
      COMMON / TAUKLE / BRA1,BRK0,BRK0B,BRKS
C BOS stuff
      INTEGER    LBCS
      PARAMETER (LBCS=1000)
      COMMON /BCS/ IW(LBCS)
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C GKBR bank
      INTEGER namind
      INTEGER nagkbr, jgkbr
      INTEGER nlen
      INTEGER ichan
C KORL bank
      INTEGER ncol, nrow
      INTEGER jkorl, altabl
      REAL tabl(200)
C
C  Possibly update branching ratios  with card GKBR
C
      NAGKBR = NAMIND('GKBR')
      JGKBR = IW(NAGKBR)
      IF(JGKBR.NE.0) THEN
* check consistency of length
        NLEN = IW(JGKBR)
        IF ( NLEN .NE. NCHAN+4 ) THEN
          WRITE (IW(6),'(1X,'' Inconsistent number of Brs should be'',
     $         I5,'' is '',I5)') NCHAN, NLEN-4
          CALL EXIT
        ENDIF
* modify BR's
        BRA1   = RW(JGKBR+1)
        BRK0   = RW(JGKBR+2)
        BRK0B  = RW(JGKBR+3)
        BRKS   = RW(JGKBR+4)
        DO 51 ICHAN = 1, NCHAN
          GAMPRT(ICHAN) = RW(JGKBR+4+ICHAN)
 51     CONTINUE
        IF ( GAMPRT(1).NE.1.) THEN
          DO 52 ICHAN = 1, NCHAN
           GAMPRT(ICHAN) = GAMPRT(ICHAN)/GAMPRT(1)
 52      CONTINUE
       ENDIF
      ENDIF
C
C   Store TAUOLA version and branching ratios in header bank KORL
C
      NCOL = NCHAN+5
      NROW = 1
      TABL(1) = 2.5             ! TAUOLA version (dummy!)
      TABL(2) = BRA1
      TABL(3) = BRK0
      TABL(4) = BRK0B
      TABL(5) = BRKS
      DO 57 ICHAN = 1, NCHAN
        TABL(5+ICHAN) = GAMPRT(ICHAN)
 57   CONTINUE
      JKORL = ALTABL('KORL',NCOL,NROW,TABL,'2I,(F)','C')
C Return
      RETURN
      END

************************************************************************

      SUBROUTINE KKWGT(ist)
      IMPLICIT none
      INTEGER ist
C --------------------------------------------------------------------
C B.Bloch March 2000
C Store interesting weights for each event in bank KWGT. 
C If all ok ist=1; if one or more booking problems, ist=0.
C---------------------------------------------------------------------
C A.Valassi June 2001
C Adapt to KRLW03 with 4f/CC3/NC2 and Coulomb/screened ratios
C Adapt to Kandy with external YFSWW weights for NL terms
C---------------------------------------------------------------------
C A.Valassi August 2001
C Upgrade to version 1.53.1 (see demo.yfsww/RELEASE.NOTES)
C Save the two extra weights with the singleW corrections
C---------------------------------------------------------------------
      INTEGER     len      ! maximum number of auxiliary weights in WtSet
      PARAMETER ( len = 100)
      DOUBLE PRECISION wtmain, wtcrud, wtset(len)
      REAL weik
      INTEGER ind, kwgtbk
      REAL*8 kwgtcoulomb
      COMMON/KWGTCOUL/kwgtcoulomb(3)                                   !cav
      REAL*8 kwgtyfsww
      COMMON/KWGTYFSW/kwgtyfsww                                        !cav
      REAL*4  VRTEX, SDVRT, XVRT, SXVRT, ECMI
      INTEGER NEVENT, IFVRT
      COMMON / KGCOMM / 
     &     VRTEX(4), SDVRT(3), XVRT(3), SXVRT(3), ECMI, 
     &     NEVENT(9), IFVRT
      INTEGER ikandy            ! 0=off 1=weightedKandy 2=unweightedKandy
      CHARACTER*200 chywexe     ! full path to YFSWW executable
      CHARACTER*200 chywout     ! full path to output file for YFSWW
      CHARACTER*200 ch4vect     ! full path to FIFO file to exchange 4vectors
      CHARACTER*200 chwtext     ! full path to FIFO file to exchange weights
      COMMON / K3ANDY / ikandy, chywexe, chywout, ch4vect, chwtext
c initialise output
      ist = 1
C Retrieve wtset from KORALW
C Weights in wtset are filled in KW_make
      CALL kw_getwtall (wtmain, wtcrud, wtset)
C Is internal Born CC03 weight positive and non-zero? 
C Interesting quantities are ratios with respect to this internal Born CC03
      IF      (wtset(1).LT.0d0) THEN
        ist=0
        PRINT *, ' '
        PRINT *, '_KKWGT Event with NEGATIVE WEIGHT!'
        PRINT *, '_KKWGT Weight = ', wtset(1)
        GOTO 999
      ELSE IF (wtset(1).EQ.0d0) THEN
        ist=0
        PRINT *, ' '
        PRINT *, '_KKWGT Event with weight=0 (outside acceptance)'
        GOTO 999
      ENDIF
C Store 4f weights with different ISR radiative corrections
C The interesting quantities are the ratios to wtset(1)
C => Weights, computed in routine betar, are normalised to 0th order:
C => hence, 4f ratios wtset(1-4)/wtset(1) = CC3 ratios wtset(9-6)/wtset(9)
C => and it is enough to store the four 4f weights wtset(1-4)
C Notice that the ratios are NOT the same anymore when YFSWW reweighting 
C is introduced in the additive way, because wtEXT=(1+deltaNL) is computed 
C in YFSWW as (ISR3+NL)/(ISR3): 
C => wtcc3_xx' = wtcc3_xx + wtcc3_3rd * (wtEXT-1) 
C => wt_4f_xx' = wt_4f_xx + wtcc3_3rd * (wtEXT-1) 
C where all quantities_xx for ISR order_xx are proportional to (1+deltaISR_xx),
C but this is not true anymore for quantities_xx' that also have NL terms.
C It is then better to define the ISR ratios at the best level (= full 4f!)
      weik = wtset(1)           ! 4f 0th order (Born, no ISR)
      ind = kwgtbk(1,1,weik)
      if (ind.le.0) ist=0
      weik = wtset(2)           ! 4f 1st order
      ind = kwgtbk(2,2,weik)
      if (ind.le.0) ist=0
      weik = wtset(3)           ! 4f 2nd order
      ind = kwgtbk(3,3,weik)
      if (ind.le.0) ist=0
      weik = wtset(4)           ! 4f 3rd order
      ind = kwgtbk(4,4,weik)
      if (ind.le.0) ist=0
C Store Coulomb weights (NB the weight for Coulomb off is 1)
      weik = kwgtcoulomb(2)     ! ratio Coulomb on (not screened) / off 
      ind = kwgtbk(5,101,weik)
      if (ind.le.0) ist=0
      weik = kwgtcoulomb(3)     ! ratio Coulomb on (screened)     / off
      ind = kwgtbk(6,102,weik)
      if (ind.le.0) ist=0
C External matrix elements chain:
C -> KW_make
C ---> calls KW_model_4f
C -----> calls ampext (only for Key4f>0) which calls amp4f
C Store CC3 weight (with no ISR) for the internal CC3 matrix element
C The interesting quantities are the ratios to wtset(1), the 4f weight
C Keep the same order as in KRLW02: store wtset(1) twice, with labels 1 and 51!
      weik = wtset(9)           ! 0th order CC3(internal)
      ind = kwgtbk(7,50,weik)
      if (ind.le.0) ist=0
      weik = wtset(1)           ! 0th order 4f(internal)
      ind = kwgtbk(8,51,weik)
      if (ind.le.0) ist=0
C Store CC3 and NC2 weight (with no ISR) for the external matrix elements
C These two weights will be 0 unless Key4f>0
C Labels 50 and 53 should give very similar (but not identical) results
      weik = wtset(49)          ! 0th order NC2(external)
      ind = kwgtbk(9,52,weik)
      if (ind.le.0) ist=0
      weik = wtset(48)          ! 0th order CC3(external)
      ind = kwgtbk(10,53,weik)
      if (ind.le.0) ist=0
C Store the two extra weights for singleW
C These two weights should be 1 unless Key4f>0...?
C Weights 60/61 are the actual weights applied (depending on angular cutoff)
      weik = wtset(20)          ! wtcort - modified t-channel brems. (APPLIED)
      ind = kwgtbk(11,60,weik)
      if (ind.le.0) ist=0
      weik = wtset(21)          ! wtrcct - run. alpha QED at scale t (APPLIED)
      ind = kwgtbk(12,61,weik)
C Weights 62/63 are the weights, independently of whether they were applied
      if (ind.le.0) ist=0
      weik = wtset(22)          ! wtcort - modified t-channel brems.
      ind = kwgtbk(13,62,weik)
      if (ind.le.0) ist=0
      weik = wtset(23)          ! wtrcct - run. alpha QED at scale t
      ind = kwgtbk(14,63,weik)
      if (ind.le.0) ist=0
C Store the external weight from YFSWW. Remember, this is normalised as 
C wtext=(ISR3+NL)/(ISR3) and is used as such in the additive correction.
      IF (ikandy.GT.0) then
        weik = kwgtyfsww        ! YFSWW (1+NL) normalised to 3rd order CC3
        ind = kwgtbk(15,90,weik)
        if (ind.le.0) ist=0
      ENDIF
c Printout debug information
      IF ( mod( nevent(2)+1, 10**INT(log(1.*nevent(2)+1)/log(10.)) 
     &     ).EQ.0 ) THEN
        PRINT *, 
     &       '_KKWGT 0th, 1st, 2nd, 3rd /0th :',
     &       wtset(1)/wtset(1),
     &       wtset(2)/wtset(1),
     &       wtset(3)/wtset(1),
     &       wtset(4)/wtset(1)
        PRINT *, 
     &       '_KKWGT Coulomb full, screened /off:',
     &       kwgtcoulomb(2),
     &       kwgtcoulomb(3)
        PRINT *, 
     &       '_KKWGT CC3int, CC3ext, NC2ext /4f:',
     &       wtset( 9)/wtset(1),
     &       wtset(48)/wtset(1),
     &       wtset(49)/wtset(1)
        PRINT *, 
     &       '_KKWGT SingleW wtcort, wtrcct:',
     &       wtset(22),
     &       wtset(23)
        PRINT *, 
     &       '_KKWGT APPLIED wtcort, wtrcct:',
     &       wtset(20),
     &       wtset(21),
     &       ' (1=fail tAngMax)'
        PRINT *, 
     &       '_KKWGT (1+NL) from YFSWW:',
     &       kwgtyfsww
      ENDIF
c Return
 999  CONTINUE
      RETURN
      END

************************************************************************

      SUBROUTINE krlw03_bookhis
      IMPLICIT none
      call hbook1  (121,'W- generated mass ',100,0.,150.,0.)
      call hbook1  (122,'W+ generated mass ',100,0.,150.,0.)
      call hbook1  (14,'Energy fermion 1',100,0.,250.,0.)
      call hbook1  (24,'Energy fermion 2',100,0.,250.,0.)
      call hbook1  (34,'Energy fermion 3',100,0.,250.,0.)
      call hbook1  (44,'Energy fermion 4',100,0.,250.,0.)
      call hbook1  (16,'Theta fermion 1',90,0.,180.,0.)
      call hbook1  (26,'Theta fermion 2',90,0.,180.,0.)
      call hbook1  (36,'Theta fermion 3',90,0.,180.,0.)
      call hbook1  (46,'Theta fermion 4',90,0.,180.,0.)
      call hbook1  (19,
     +     'Flavour (pdg-code) fermion 1',33,-16.5,16.5,0.)
      call hbook1  (29,
     +     'Flavour (pdg-code) fermion 2',33,-16.5,16.5,0.)
      call hbook1  (39,
     +     'Flavour (pdg-code) fermion 3',33,-16.5,16.5,0.)
      call hbook1  (49,
     +     'Flavour (pdg-code) fermion 4',33,-16.5,16.5,0.)
      call hbook1 (125,'Invariant mass fermions 1-2',100,0.,250.,0.)
      call hbook1 (135,'Invariant mass fermions 1-3',100,0.,250.,0.)
      call hbook1 (145,'Invariant mass fermions 1-4',100,0.,250.,0.)
      call hbook1 (235,'Invariant mass fermions 2-3',100,0.,250.,0.)
      call hbook1 (245,'Invariant mass fermions 2-4',100,0.,250.,0.)
      call hbook1 (345,'Invariant mass fermions 3-4',100,0.,250.,0.)
      call hbook1 (601,'Number of ISR photons',20,-0.5,19.5,0.)
      call hbook1 (602,'Total energy of ISR photons',70,0.,70.,0.)
      call hbook1 (603,'Transverse component of ISR momentum',
     +     100,0.,20.,0.)
      return
      end

************************************************************************

      SUBROUTINE krlw03_fillhis
      IMPLICIT none
C KORALW event properties
      INTEGER iflav(4)
      DOUBLE PRECISION amdec(4)
      COMMON / DECAYS / IFLAV, AMDEC
C KORALW event kinematics
      INTEGER nphot
      DOUBLE PRECISION  QEFF1, QEFF2, SPHUM, SPHOT
      DOUBLE PRECISION  Q1, Q2, P1, P2, P3, P4
      COMMON / momset / qeff1(4),qeff2(4),sphum(4),sphot(100,4),nphot
      COMMON / momdec / q1(4),q2(4),p1(4),p2(4),p3(4),p4(4)
C Histograms
      DOUBLE PRECISION SUMISR(4),themin,angarb,pt2,em12,em34,qadra
      real*4 dum
      INTEGER iphot, i4
      REAL bcosd, xcos
      bcosd(xcos)= 57.29577951*acos(xcos) ! macro
C
      themin = 1.d-6
      angarb = SIN(themin)**2
      pt2=0d0
      IF(abs(iflav(1)) .NE. 12  .AND.  abs(iflav(1)) .NE. 14
     $  .AND.  abs(iflav(1)) .NE. 16  .AND.
     $ (p1(1)**2+p1(2)**2)/(p1(1)**2+p1(2)**2+p1(3)**2) .GT. angarb )
     $  pt2=pt2+p1(1)**2+p1(2)**2

      IF(abs(iflav(2)) .NE. 12  .AND.  abs(iflav(2)) .NE. 14
     $  .AND.  abs(iflav(2)) .NE. 16  .AND.
     $ (p2(1)**2+p2(2)**2)/(p2(1)**2+p2(2)**2+p2(3)**2) .GT. angarb )
     $  pt2=pt2+p2(1)**2+p2(2)**2

       IF(abs(iflav(3)) .NE. 12  .AND.  abs(iflav(3)) .NE. 14
     $  .AND.  abs(iflav(3)) .NE. 16  .AND.
     $ (p3(1)**2+p3(2)**2)/(p3(1)**2+p3(2)**2+p3(3)**2) .GT. angarb )
     $  pt2=pt2+p3(1)**2+p3(2)**2

      IF(abs(iflav(4)) .NE. 12  .AND.  abs(iflav(4)) .NE. 14
     $  .AND.  abs(iflav(4)) .NE. 16  .AND.
     $ (p4(1)**2+p4(2)**2)/(p4(1)**2+p4(2)**2+p4(3)**2) .GT. angarb )
     $  pt2=pt2+p4(1)**2+p4(2)**2
      call hfill(106,real(pt2),dum,1.)
C  mee for accepted eexx events
      IF (iflav(2) .EQ. -11) then
          em12 = qadra(p1,p2)
          call hfill(108,real(em12),dum,1.)
      ENDIF
      IF (iflav(3) .EQ. 11) THEN
           em34 = qadra(p3,p4)
           call hfill(108,real(em34),dum,1.)
      ENDIF

      if (pt2.gt.0d0) return
      call hfill (14,real(p1(4)),0.,1.)
      call hfill (24,real(p2(4)),0.,1.)
      call hfill (34,real(p3(4)),0.,1.)
      call hfill (44,real(p4(4)),0.,1.)
      call hfill (121,real(sqrt(q1(4)*q1(4)
     &     -q1(3)*q1(3)-q1(2)*q1(2)-q1(1)*q1(1))),0.,1.)
      call hfill (122,real(sqrt(q2(4)*q2(4)
     &     -q2(3)*q2(3)-q2(2)*q2(2)-q2(1)*q2(1))),0.,1.)
      call hfill (16,
     &     bcosd(real( p1(3)/sqrt(p1(1)**2+p1(2)**2+p1(3)**2) )),
     &     0.,1.)
      call hfill (26,
     &     bcosd(real( p2(3)/sqrt(p2(1)**2+p2(2)**2+p2(3)**2) )),
     &     0.,1.)
      call hfill (36,
     &     bcosd(real( p3(3)/sqrt(p3(1)**2+p3(2)**2+p3(3)**2) )),
     &     0.,1.)
      call hfill (46,
     &     bcosd(real( p4(3)/sqrt(p4(1)**2+p4(2)**2+p4(3)**2) )),
     &     0.,1.)
      call hfill (19,real(iflav(1)),0.,1.)
      call hfill (29,real(iflav(2)),0.,1.)
      call hfill (39,real(iflav(3)),0.,1.)
      call hfill (49,real(iflav(4)),0.,1.)
      call hfill (125,
     &     real(sqrt( (p1(4)+p2(4))**2 -
     &     (p1(1)+p2(1))**2 -
     &     (p1(2)+p2(2))**2 -
     &     (p1(3)+p2(3))**2   )), 0., 1.)
      call hfill (135,
     &     real(sqrt( (p1(4)+p3(4))**2 -
     &     (p1(1)+p3(1))**2 -
     &     (p1(2)+p3(2))**2 -
     &     (p1(3)+p3(3))**2   )), 0., 1.)
      call hfill (145,
     &     real(sqrt( (p1(4)+p4(4))**2 -
     &     (p1(1)+p4(1))**2 -
     &     (p1(2)+p4(2))**2 -
     &     (p1(3)+p4(3))**2   )), 0., 1.)
      call hfill (235,
     &     real(sqrt( (p2(4)+p3(4))**2 -
     &     (p2(1)+p3(1))**2 -
     &     (p2(2)+p3(2))**2 -
     &     (p2(3)+p3(3))**2   )), 0., 1.)
      call hfill (245,
     &     real(sqrt( (p2(4)+p4(4))**2 -
     &     (p2(1)+p4(1))**2 -
     &     (p2(2)+p4(2))**2 -
     &     (p2(3)+p4(3))**2   )), 0., 1.)
      call hfill (345,
     &     real(sqrt( (p3(4)+p4(4))**2 -
     &     (p3(1)+p4(1))**2 -
     &     (p3(2)+p4(2))**2 -
     &     (p3(3)+p4(3))**2   )), 0., 1.)
      do i4 = 1, 4
        sumisr(i4) = 0d0
        do iphot = 1, nphot
          sumisr(i4) = sumisr(i4) + sphot (iphot,i4)
        end do
      end do
      call hfill (601,real(nphot),0.,1.)
      call hfill (602,real(sumisr(4)),0.,1.)
      call hfill (603,real(sqrt(sumisr(1)**2+sumisr(2)**2)),0.,1.)
      return
      end

************************************************************************

      SUBROUTINE KW4FBK(ist)
      IMPLICIT none
      INTEGER ist
C------------------------------------------------------------
C B.Bloch Dec 2000
C Book bank KW4F with 4-fermions and ISR photons 
C kinematics for later use (YFSWW reweighting)
C Output: ist=0 if ok, non 0 otherwise
C------------------------------------------------------
C KORALW event properties
      INTEGER iflav(4)
      DOUBLE PRECISION amdec(4)
      COMMON / DECAYS / IFLAV, AMDEC
C KORALW event kinematics
      INTEGER nphot
      DOUBLE PRECISION  QEFF1, QEFF2, SPHUM, SPHOT
      DOUBLE PRECISION  Q1, Q2, P1, P2, P3, P4
      COMMON / momset / qeff1(4),qeff2(4),sphum(4),sphot(100,4),nphot
      COMMON / momdec / q1(4),q2(4),p1(4),p2(4),p3(4),p4(4)
C Bank KW4F (kw4fjj.h)
      INTEGER   JKW4PX,  JKW4PY,  JKW4PZ,  JKW4MA,  JKW4PN,  LKW4FA
      PARAMETER(JKW4PX=1,JKW4PY=2,JKW4PZ=3,JKW4MA=4,JKW4PN=5,LKW4FA=5)
C Fill the bank
      INTEGER nent
      INTEGER jkw4f, kkw4f
      INTEGER iph
      INTEGER idumm
C BOS stuff
      INTEGER    LBCS
      PARAMETER (LBCS=1000)
      COMMON /BCS/ IW(LBCS)
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C BOS macros
      INTEGER    LMHLEN,   LMHCOL,   LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
      INTEGER ID, NRBOS, L
      INTEGER LCOLS, LROWS, KNEXT, KROW, LFRWRD, LFRROW, ITABL
      REAL RTABL
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
C Create the KW4F bank
C
      IST = 0
      nent = NPHOT+4
      CALL AUBOS('KW4F',0,nent*LKW4FA+LMHLEN,JKW4F,IDUMM)
      IF (JKW4F.LE.0) GO TO 999
      IW(JKW4F+LMHCOL) = LKW4FA
      IW(JKW4F+LMHROW) = 4 + NPHOT
      CALL BKFMT('KW4F','2I,(4F,I)')
      CALL BLIST(IW,'E+','KW4F')
C
C  Fill the KW4F bank
C
      KKW4F = KROW(JKW4F,1)
      RW(KKW4F+JKW4PX)   = SNGL(p1(1))
      RW(KKW4F+JKW4PY)   = SNGL(p1(2))
      RW(KKW4F+JKW4PZ)   = SNGL(p1(3))
      RW(KKW4F+JKW4MA)   = SNGL(amdec(1))
      IW(KKW4F+JKW4PN)   = IFLAV(1)
      KKW4F = KROW(JKW4F,2)
      RW(KKW4F+JKW4PX)   = SNGL(p2(1))
      RW(KKW4F+JKW4PY)   = SNGL(p2(2))
      RW(KKW4F+JKW4PZ)   = SNGL(p2(3))
      RW(KKW4F+JKW4MA)   = SNGL(amdec(2))
      IW(KKW4F+JKW4PN)   = IFLAV(2)
      KKW4F = KROW(JKW4F,3)
      RW(KKW4F+JKW4PX)   = SNGL(p3(1))
      RW(KKW4F+JKW4PY)   = SNGL(p3(2))
      RW(KKW4F+JKW4PZ)   = SNGL(p3(3))
      RW(KKW4F+JKW4MA)   = SNGL(amdec(3))
      IW(KKW4F+JKW4PN)   = IFLAV(3)
      KKW4F = KROW(JKW4F,4)
      RW(KKW4F+JKW4PX)   = SNGL(p4(1))
      RW(KKW4F+JKW4PY)   = SNGL(p4(2))
      RW(KKW4F+JKW4PZ)   = SNGL(p4(3))
      RW(KKW4F+JKW4MA)   = SNGL(amdec(4))
      IW(KKW4F+JKW4PN)   = IFLAV(4)
      do iph = 1, nphot
        KKW4F = KROW(JKW4F,4+iph)
        RW(KKW4F+JKW4PX)   = SNGL(sphot(iph,1))
        RW(KKW4F+JKW4PY)   = SNGL(sphot(iph,2))
        RW(KKW4F+JKW4PZ)   = SNGL(sphot(iph,3))
        RW(KKW4F+JKW4MA)   = 0.
        IW(KKW4F+JKW4PN)   = 22
      enddo
C
C Return
C
      RETURN
  999 ist = 1
      RETURN
      END

************************************************************************

      DOUBLE PRECISION FUNCTION qnorm(v)
      IMPLICIT NONE
      DOUBLE PRECISION v(4)
      qnorm = dsqrt( v(1)**2 + v(2)**2 + v(3)**2 )
      RETURN
      END

************************************************************************

      SUBROUTINE writer_xpar (npar, xpar)
      IMPLICIT none
      INTEGER npar
      DOUBLE PRECISION xpar(*)
      INTEGER ipar
      INTEGER          inut, iout
      COMMON / INOUT / INUT, IOUT
c open file
      WRITE (iout,*) '_WRITER_XPAR starting'
      OPEN(22,file='4vect.data.out')
      WRITE (iout,*) 
     &     '_WRITER_XPAR opened file 4vect.data.out on unit 22'
c write array to file
      DO ipar = 1, npar
        WRITE (22,100) xpar(ipar)
*       WRITE (iout,*) ipar, xpar(ipar)
      END DO
 100  FORMAT (1x,e26.18)
      CLOSE (22)
      WRITE (iout,*) 
     &     '_WRITER_XPAR closed unit 22'
      WRITE (iout,*) '_WRITER_XPAR exiting'
      RETURN
      END

******************************************************************************
* A.Valassi June 2001
* Determines whether a 4f final state flavour is compatible to WW
* and swaps the flavours and 4momenta to reorder the 4f as WW daughters.
*
* INPUT:  iflav(4)   flavours in PDG numbering scheme 
* INPUT:  p1-p4      4momenta in double precision
* OUTPUT: isww       >0 if compatible to a WW, =0 otherwise
* OUTPUT: iszz       >0 if compatible to a ZZ, =0 otherwise
*                    =1 ZZ order is unambiguous (two different pairs, eg eeuu)
*                    =2 ZZ order is ambiguous (two equal pairs, eg eeee)
* OUTPUT: iflavw(4)  flavours in WW order (or original order if not a WW) 
* OUTPUT: p1w-p4w    4momenta in WW order (or original order if not a WW) 
*
******************************************************************************
* Written for Koralw1.52, but it works for any input in PDG numbering scheme!
******************************************************************************

      SUBROUTINE WW_SWAPPER(iflav, p1, p2, p3, p4, isww, iszz,
     &     iflavw, p1w, p2w, p3w, p4w)
      IMPLICIT none
      INTEGER iflav(4)
      DOUBLE PRECISION p1(4),  p2(4),  p3(4),  p4(4)
      INTEGER isww, iszz
      INTEGER iflavw(4)
      DOUBLE PRECISION p1w(4), p2w(4), p3w(4), p4w(4)
      INTEGER i4ww(4), i4zz(4)
      DOUBLE PRECISION p4mu(4,4)
      INTEGER i4, imu
      CALL WWORZZ(iflav, isww, iszz, i4ww, i4zz)
      IF (isww.EQ.1) THEN
        DO imu = 1, 4
          p4mu(1,imu) = p1(imu)
          p4mu(2,imu) = p2(imu)
          p4mu(3,imu) = p3(imu)
          p4mu(4,imu) = p4(imu)
        END DO
        DO imu = 1, 4
          p1w(imu) = p4mu(i4ww(1),imu)
          p2w(imu) = p4mu(i4ww(2),imu)
          p3w(imu) = p4mu(i4ww(3),imu)
          p4w(imu) = p4mu(i4ww(4),imu)
        END DO
        DO i4 = 1, 4
          iflavw(i4) = iflav(i4ww(i4))
        END DO
      ELSE
        DO imu = 1, 4
          p1w(imu) = 0
          p2w(imu) = 0
          p3w(imu) = 0
          p4w(imu) = 0
        END DO
        DO i4 = 1, 4
          iflavw(i4) = 0
        END DO
      ENDIF
      RETURN
      END

******************************************************************************
* A.Valassi June 2001
* Determines whether a 4f final state flavour is compatible to WW or ZZ
* and returns the indices necessary to reorder the 4f as WW/ZZ daughters.
*
* INPUT:  iflav(4)   flavours in PDG numbering scheme 
* OUTPUT: isww       >0 if compatible to a WW, =0 otherwise
* OUTPUT: iszz       >0 if compatible to a ZZ, =0 otherwise
*                    =1 ZZ order is unambiguous (two different pairs, eg eeuu)
*                    =2 ZZ order is ambiguous (two equal pairs, eg eeee)
* OUTPUT: i4ww(4)    => iflav(i4ww(i)) is the WW order; =(0,0,0,0) if not a WW
*         iflav(i4ww(1)) =     fermion decay product of W-/Z1 (    quark d)
*         iflav(i4ww(2)) = antifermion decay product of W-/Z2 (antiquark u)
*         iflav(i4ww(3)) =     fermion decay product of W+/Z2 (    quark u)
*         iflav(i4ww(4)) = antifermion decay product of W+/Z1 (antiquark d)
* OUTPUT: i4zz(4)    => iflav(i4zz(i)) is the ZZ order; =(0,0,0,0) if not a ZZ
*         iflav(i4zz(1)) =     fermion decay product of Z1/W1 (    quark d)
*         iflav(i4zz(2)) = antifermion decay product of Z1/W2 (antiquark d)
*         iflav(i4zz(3)) =     fermion decay product of Z2/W2 (    quark u)
*         iflav(i4zz(4)) = antifermion decay product of Z2/W1 (antiquark u)
*
******************************************************************************
* Written for Koralw1.52, but it works for any input in PDG numbering scheme!
******************************************************************************

      SUBROUTINE WWORZZ(iflav, isww, iszz, i4ww, i4zz)
      IMPLICIT none
      INTEGER iflav(4), isww, iszz, i4ww(4), i4zz(4)
      INTEGER j4
      INTEGER i4ferm(2), i4fbar(2), nferm, nfbar
      INTEGER ispairaz
      INTEGER ispairaw
      INTEGER iz11, iz22, iz12, iz21
      INTEGER iw11, iw22, iw12, iw21
c initialise output
      isww = 0
      iszz = 0
      DO j4 = 1, 4
        i4ww(j4) = 0
        i4zz(j4) = 0
      END DO
c first check that the input makes sense
      DO j4 = 1, 4
        IF (iflav(j4).EQ.0) THEN
          WRITE (6,*) '_WWORZZ called with input flavour = 0'
          WRITE (6,*) '_WWORZZ iflav', iflav
          WRITE (6,*) '_WWORZZ CATASTROPHIC ERROR'
          STOP
        ENDIF
      END DO
c first look for fermions and antifermions
      nferm = 0
      nfbar = 0
      DO j4 = 1, 4
        IF (iflav(j4).GT.0) THEN
          nferm = nferm+1
          i4ferm(nferm) = j4
        ELSE
          nfbar = nfbar+1
          i4fbar(nfbar) = j4
        ENDIF
      END DO
      IF (nferm.ne.2 .OR. nfbar.NE.2) THEN
        WRITE (6,*) '_WWORZZ not 2 fermions and 2 antifermions'
        WRITE (6,*) '_WWORZZ #fermions, #antifermions:', nferm, nfbar
        WRITE (6,*) '_WWORZZ iflav', iflav
        WRITE (6,*) '_WWORZZ CATASTROPHIC ERROR'
        STOP
      ENDIF
c check if this is a ZZ
      iz11 = ispairaz(iflav(i4ferm(1)),iflav(i4fbar(1)))
      iz22 = ispairaz(iflav(i4ferm(2)),iflav(i4fbar(2)))
      iz12 = ispairaz(iflav(i4ferm(1)),iflav(i4fbar(2)))
      iz21 = ispairaz(iflav(i4ferm(2)),iflav(i4fbar(1)))
      IF ( iz11.EQ.1 .AND. iz22.EQ.1 ) THEN
        iszz = 1                ! unambiguous ordering (for now!)
        i4zz(1) = i4ferm(1)
        i4zz(2) = i4fbar(1)
        i4zz(3) = i4ferm(2)
        i4zz(4) = i4fbar(2)
      ENDIF
      IF ( iz12.EQ.1 .AND. iz21.EQ.1 ) THEN
        IF (iszz.EQ.0) THEN
          iszz = 1              ! unambiguous ordering
          i4zz(1) = i4ferm(1)
          i4zz(2) = i4fbar(2)
          i4zz(3) = i4ferm(2)
          i4zz(4) = i4fbar(1)
        ELSE
          iszz = 2              ! ambiguous ordering, keep the first one
        ENDIF
      ENDIF
c check if this is a WW
      iw11 = ispairaw(iflav(i4ferm(1)),iflav(i4fbar(1)))
      iw22 = ispairaw(iflav(i4ferm(2)),iflav(i4fbar(2)))
      iw12 = ispairaw(iflav(i4ferm(1)),iflav(i4fbar(2)))
      iw21 = ispairaw(iflav(i4ferm(2)),iflav(i4fbar(1)))
      IF(     iw11.EQ.-1 .AND. iw22.EQ.+1 ) THEN
        isww = 1
        i4ww(1) = i4ferm(1)
        i4ww(2) = i4fbar(1)
        i4ww(3) = i4ferm(2)
        i4ww(4) = i4fbar(2)
      ELSEIF( iw22.EQ.-1 .AND. iw11.EQ.+1 ) THEN
        isww = 1
        i4ww(1) = i4ferm(2)
        i4ww(2) = i4fbar(2)
        i4ww(3) = i4ferm(1)
        i4ww(4) = i4fbar(1)
      ELSEIF( iw12.EQ.-1 .AND. iw21.EQ.+1 ) THEN
        isww = 1
        i4ww(1) = i4ferm(1)
        i4ww(2) = i4fbar(2)
        i4ww(3) = i4ferm(2)
        i4ww(4) = i4fbar(1)
      ELSEIF( iw21.EQ.-1 .AND. iw12.EQ.+1 ) THEN
        isww = 1
        i4ww(1) = i4ferm(2)
        i4ww(2) = i4fbar(1)
        i4ww(3) = i4ferm(1)
        i4ww(4) = i4fbar(2)
      ENDIF
c catastrophic error if neither a WW nor a ZZ
      IF (iszz.EQ.0 .AND. isww.EQ.0) THEN
        WRITE (6,*) '_WWORZZ neither a WW nor a ZZ'
        WRITE (6,*) '_WWORZZ iw11, iw12, iw21, iw22', 
     &       iw11, iw12, iw21, iw22
        WRITE (6,*) '_WWORZZ iflav', iflav
        WRITE (6,*) '_WWORZZ CATASTROPHIC ERROR'
        STOP
      ENDIF
      RETURN
      END

******************************************************************************
* A.Valassi June 2001
* Checks whether a fermion-antifermion pair is compatible to a Z
* INPUT:  fermion and antifermion PDG numbers
* OUTPUT: 1=Z; 0=not a Z
******************************************************************************
* Written for Koralw1.52, but it works for any input in PDG numbering scheme!
******************************************************************************

      INTEGER FUNCTION ispairaz (iferm, ifbar)
      IMPLICIT none
      INTEGER iferm, ifbar
c catastrophic error if not a fermion and an antifermion
      IF ( iferm*ifbar.GE.0 ) THEN
        WRITE (6,*) '_ISPAIRAZ not a fermion and an antifermion'
        WRITE (6,*) '_ISPAIRAZ iferm, ifbar', iferm, ifbar
        WRITE (6,*) '_ISPAIRAZ CATASTROPHIC ERROR'
        STOP
      ENDIF
c now check for a Z
      ispairaz = 0
      IF ( 
     &     (iferm.EQ. 1 .AND. ifbar.EQ. -1) .OR. ! d   dbar
     &     (iferm.EQ. 2 .AND. ifbar.EQ. -2) .OR. ! u   ubar
     &     (iferm.EQ. 3 .AND. ifbar.EQ. -3) .OR. ! s   sbar
     &     (iferm.EQ. 4 .AND. ifbar.EQ. -4) .OR. ! c   cbar
     &     (iferm.EQ. 5 .AND. ifbar.EQ. -5) .OR. ! b   bbar
     &     (iferm.EQ. 6 .AND. ifbar.EQ. -6) .OR. ! t   tbar (virtual!)
     &     (iferm.EQ.11 .AND. ifbar.EQ.-11) .OR. ! e-  e+
     &     (iferm.EQ.12 .AND. ifbar.EQ.-12) .OR. ! nue nue~
     &     (iferm.EQ.13 .AND. ifbar.EQ.-13) .OR. ! m-  m+
     &     (iferm.EQ.14 .AND. ifbar.EQ.-14) .OR. ! num num~
     &     (iferm.EQ.15 .AND. ifbar.EQ.-15) .OR. ! t-  t+
     &     (iferm.EQ.16 .AND. ifbar.EQ.-16)      ! nut nut~
     &     ) THEN
        ispairaz = 1
      ENDIF
      RETURN
      END

******************************************************************************
* A.Valassi June 2001
* Checks whether a fermion-antifermion pair is compatible to a W- or a W+
* INPUT:  fermion and antifermion PDG numbers
* OUTPUT: 1=W+; -1=W-; 0=neither
******************************************************************************
* Written for Koralw1.52, but it works for any input in PDG numbering scheme!
******************************************************************************

      INTEGER FUNCTION ispairaw (iferm, ifbar)
      IMPLICIT none
      INTEGER iferm, ifbar
      INTEGER icharge
      INTEGER iwmferm, iwmfbar
c catastrophic error if not a fermion and an antifermion
      IF ( iferm*ifbar.GE.0 ) THEN
        WRITE (6,*) '_ISPAIRAW not a fermion and an antifermion'
        WRITE (6,*) '_ISPAIRAW iferm, ifbar', iferm, ifbar
        WRITE (6,*) '_ISPAIRAW CATASTROPHIC ERROR'
        STOP
      ENDIF
c first check for W-
      ispairaw = 0
      icharge  = -1             ! first check for W-
      iwmferm  = iferm          ! ferm for W- hypothesis
      iwmfbar  = ifbar          ! fbar for W- hypothesis
 10   CONTINUE
      IF ( 
     &     (iwmferm.EQ. 1 .AND. iwmfbar.EQ. -2) .OR. ! d  ubar
     &     (iwmferm.EQ. 1 .AND. iwmfbar.EQ. -4) .OR. ! d  cbar
     &     (iwmferm.EQ. 1 .AND. iwmfbar.EQ. -6) .OR. ! d  tbar
     &     (iwmferm.EQ. 3 .AND. iwmfbar.EQ. -2) .OR. ! s  ubar
     &     (iwmferm.EQ. 3 .AND. iwmfbar.EQ. -4) .OR. ! s  cbar
     &     (iwmferm.EQ. 3 .AND. iwmfbar.EQ. -6) .OR. ! s  tbar
     &     (iwmferm.EQ. 5 .AND. iwmfbar.EQ. -2) .OR. ! b  ubar
     &     (iwmferm.EQ. 5 .AND. iwmfbar.EQ. -4) .OR. ! b  cbar
     &     (iwmferm.EQ. 5 .AND. iwmfbar.EQ. -6) .OR. ! b  tbar
     &     (iwmferm.EQ.11 .AND. iwmfbar.EQ.-12) .OR. ! e- nue
     &     (iwmferm.EQ.13 .AND. iwmfbar.EQ.-14) .OR. ! m- num
     &     (iwmferm.EQ.15 .AND. iwmfbar.EQ.-16)      ! t- nut
     &     ) THEN
        ispairaw = icharge
      ELSEIF (icharge.EQ.-1) THEN
        icharge  = +1           ! now check for W+
        iwmferm  = -ifbar       ! ferm for W- hypothesis is anti(fbar)
        iwmfbar  = -iferm       ! fbar for W- hypothesis is anti(ferm)
        GOTO 10
      ENDIF
      RETURN
      END

******************************************************************************
* A.Valassi June 2001
* Post-generation reweighting of KRLW03 events with YFSWW O(alpha) weights
* INPUT:  iend 0(normal event), 1(end of run)
* INPUT:  from KW_ getters
* OUTPUT: kwgtyfsww external weight = (ISR3+NL)/(ISR3)
******************************************************************************

      SUBROUTINE kandypost(iend)
      IMPLICIT none
      INTEGER iend
      REAL*8 kwgtyfsww
      COMMON/KWGTYFSW/kwgtyfsww                                        !cav
      INTEGER iflav(4)
      REAL*8  amdec(4)
      REAL*8  p1(4), p2(4), p3(4), p4(4)   
      INTEGER nphot
      REAL*8  sphot(100,4)
      REAL*8  wtkarl
      INTEGER isww, iszz
      INTEGER iflavw(4)
      REAL*8  p1w(4), p2w(4), p3w(4), p4w(4)
      INTEGER i_writ_4v
      PARAMETER (i_writ_4v=3)   ! 3(short format + end of run marker)
      INTEGER i_read_wt
      PARAMETER (i_read_wt=1)   ! 1(add) or 2(mult) are equivalent here
      REAL*8  wtset2(100), wtext
      INTEGER iev
      DATA iev/0/
      SAVE iev
      IF (iend.EQ.0) THEN
        IF (iev.EQ.0)
     &       WRITE (6,*) '_KANDYPOST processing first event'
        iev=iev+1
        CALL KW_GetIflav(iflav,amdec)
        CALL KW_GetMomDec(p1,p2,p3,p4)
        CALL WW_SWAPPER(iflav, p1, p2, p3, p4, isww, iszz,
     &       iflavw, p1w, p2w, p3w, p4w)
        IF (isww.EQ.1) THEN
          CALL KW_GetPhotAll(nphot,sphot)
          wtkarl=1              ! set>0 is enough
          CALL writer_4v(iflavw,p1w,p2w,p3w,p4w,sphot,nphot,wtkarl,
     $         i_writ_4v,iend)
          CALL reader_wt(i_read_wt,wtset2,wtEXT)
        ELSE
          wtext=1
        ENDIF
        kwgtyfsww = wtext 
      ELSEIF (iend.EQ.1) THEN
        WRITE (6,*) '_KANDYPOST finalising'
        CALL writer_4v
     &       (iflavw,p1w,p2w,p3w,p4w,sphot,nphot,wtkarl, ! all dummy for iend=1
     &       i_writ_4v,iend)
      ELSE
        WRITE (6,*) '_KANDYPOST invalid option'
        STOP
      ENDIF
      RETURN
      END

******************************************************************************
* A.Valassi June 2001
* Cross-section monitoring (on Kingal accepted events only)
* Normalisation is relative to principal event weight (=1 for unweighted evts!)
* INPUT:  imode = -1(init), 0(event), 1(end)
* INPUT:  through KW_GetWtAll and common KWGTYFSW
* OUTPUT: dump results
******************************************************************************

      SUBROUTINE xsecmon(imode)
      IMPLICIT none
      INTEGER imode
c Number of xsecs monitored
      INTEGER id
      INTEGER nid
      PARAMETER(nid=11)
c Xsec and Nevt monitoring
      INTEGER ntot
      REAL*8  wtot(nid), wtot2(nid)
      SAVE    ntot, wtot, wtot2
      REAL*8  weight
C KORALW switches
      INCLUDE 'KW.h'
      INTEGER            KeyRad,KeyPhy,KeyTek,KeyMis,KeyDwm,KeyDwp
      COMMON / KeyKey /  KeyRad,KeyPhy,KeyTek,KeyMis,KeyDwm,KeyDwp
      INTEGER KeyCul
C Koralw weights
      REAL*8 wtmain, wtcrud, wtset(100)
C KANDY common
      INTEGER ikandy            ! 0=off 1=weightedKandy 2=unweightedKandy
      CHARACTER*200 chywexe     ! full path to YFSWW executable
      CHARACTER*200 chywout     ! full path to output file for YFSWW
      CHARACTER*200 ch4vect     ! full path to FIFO file to exchange 4vectors
      CHARACTER*200 chwtext     ! full path to FIFO file to exchange weights
      COMMON / K3ANDY / ikandy, chywexe, chywout, ch4vect, chwtext
C KINGAL Common block KGCOMM
      REAL*4  VRTEX, SDVRT, XVRT, SXVRT, ECMI
      INTEGER NEVENT, IFVRT
      COMMON / KGCOMM / 
     &     VRTEX(4), SDVRT(3), XVRT(3), SXVRT(3), ECMI, 
     &     NEVENT(9), IFVRT
      INTEGER nacc0, nacc1
c YFSWW external weight
      REAL*8 kwgtyfsww
      COMMON/KWGTYFSW/kwgtyfsww                                        !cav
c Coulomb weights
      REAL*8 kwgtcoulomb
      COMMON/KWGTCOUL/kwgtcoulomb(3)                                   !cav
c Crude xsection from KORALW
      DOUBLE PRECISION xcrude, xcvesk, dumm1 
c Best xsection from KORALW and GLIB
      DOUBLE PRECISION averwt, errela, evtot
      DOUBLE PRECISION xsecnor0,  xerrnor0  ! Normalisation (all gen evts)
      DOUBLE PRECISION xsecnor1,  xerrnor1  ! Normalisation (Kingal acc evts)
      DOUBLE PRECISION xsec(nid), xerr(nid) ! User-defined
C
C Initialise
C
      IF     (imode.EQ.-1) THEN
        WRITE (6,*) '_XSECMON initialising'
        ntot = 0
        DO id = 1, nid
          wtot(id)  = 0
          wtot2(id) = 0
        END DO
C
C Event
C
      ELSEIF (imode.EQ.0) THEN
        IF (ntot.EQ.0)
     &  WRITE (6,*) '_XSECMON processing first event'
        ntot = ntot+1
        CALL KW_getwtall(wtmain, wtcrud, wtset)
        IF (wtset(1).LE.0) THEN ! this is impossible as KKWGT fails before!
          WRITE (6,*) '_XSECMON wtset(1)<0.. should not be here!'
          STOP
        ENDIF
* 1. Best (4f, usually) cross-section
        id = 1
        weight = wtmain
        wtot(id)  = wtot(id)  + weight
        wtot2(id) = wtot2(id) + weight**2
* 2. Internal CC3 cross-section
        id = 2
        weight = wtmain * wtset(9)/wtset(1)
        wtot(id)  = wtot(id)  + weight
        wtot2(id) = wtot2(id) + weight**2
* 3. Grace CC3
* Assume 4f production
        IF (m_key4f.EQ.1) THEN
        id = 3
        weight = wtmain * wtset(48)/wtset(1) 
        wtot(id)  = wtot(id)  + weight
        wtot2(id) = wtot2(id) + weight**2
        ENDIF
* 4. Grace NC2
        IF (m_key4f.EQ.1) THEN
        id = 4
        weight = wtmain * wtset(49)/wtset(1)
        wtot(id)  = wtot(id)  + weight
        wtot2(id) = wtot2(id) + weight**2
        ENDIF
* 5. Internal CC3 with O(alpha) multiplicative
        IF (ikandy.NE.0) THEN
        id = 5
        weight = wtmain * wtset(9)/wtset(1) * kwgtyfsww
        wtot(id)  = wtot(id)  + weight
        wtot2(id) = wtot2(id) + weight**2
        ENDIF
* 6. 4f with O(alpha) additive
* Assume 3rd order ISR with 4f calculation, and post-generation Kandy.
* In general I should use wtset(6)/wtset(m_i_prwt)
* - I assume m_i_prwt=4 for 3rd order, so I should use wtset(6)/wtset(4)
* Here I use the Born ratio wtset(9)/wtset(1)
* - I assume post-generation Kandy, so cc3/4f is same at any order, 9/1=6/4!
        IF (ikandy.EQ.1 .AND. m_key4f.NE.0 
     &                  .AND. m_KeyISR.NE.0 .AND. m_i_prwt.EQ.4) THEN
        id = 6
        weight = wtmain * ( 1 + (kwgtyfsww-1) *
     &       wtset(9)/wtset(1) ) ! use CC3/4f Born ratio instead of 3rd order
        wtot(id)  = wtot(id)  + weight
        wtot2(id) = wtot2(id) + weight**2
        ENDIF
* 7. 4f with O(alpha) multiplicative
        IF (ikandy.EQ.1 .AND. m_key4f.NE.0 
     &                  .AND. m_KeyISR.NE.0 .AND. m_i_prwt.EQ.4) THEN
        id = 7
        weight = wtmain * kwgtyfsww
        wtot(id)  = wtot(id)  + weight
        wtot2(id) = wtot2(id) + weight**2
        ENDIF
* 8. Internal CC3 with unscreened Coulomb
* Assume ikandy<2. In this case, KW_Make sets ("~" indicates proportionality):
* - wtset(1) ~ "wtborn"   [+ISR] ~ wtbo4f 
* - wtset(9) ~ "wtbornww" [+ISR] ~ wtboww
* (NB The "wtborn" above is not the same as below).
* Also assume 4f on and couplings off. In this case, KW_model_4f sets
* - wtboww = wtborn*cul 
* - wtbo4f = wtmod4f*wt_qcd + wtborn*(cul-1) (WW or WW/ZZ overlap)
* - wtbo4f = wtmod4f*wt_qcd                  (ZZ only)
* To equalise the formulas for WW and ZZ, I defined kwgtcoulomb(i)=1 for ZZ:
* - wtset(1) ~ wtmod4f*wt_qcd + wtborn*(cul-1)
* - wtset(9) ~ wtborn*cul
* Assuming "cul3" = screened Coulomb kwgtcoulomb(3) is used for cul,
* - wtset(1) = A * ( wtmod4f*wt_qcd + wtborn*(cul3-1))
* - wtset(9) = A * (                  wtborn*(cul3  ))
* If I now want to use a different Coulomb cul, I need to do:
* - A*wtborn = wtset(9)/cul3
* - A*wtborn*(cul3-1) = wtset(9)*(cul3-1)/cul3
* - A*wtmod4f*wt_qcd = wtset(1) - wtset(9)*(cul3-1)/cul3
* And the new wtset(1) and (9) are
* - wtset(9)' = wtset(9)*cul/cul3
* - wtset(1)' = wtset(1) - wtset(9)*(cul3-1)/cul3 + wtset(9)*(cul-1)/cul3
*             = wtset(1) + wtset(9)*(cul/cul3-1)
* For internal CC3, the formula is valid of course for any ikandy or Key4f
        KeyCul = MOD(KeyRad,10000)/1000
        IF (KeyCul.EQ.2 .AND. m_KeyAcc.EQ.0) THEN
        id = 8
        weight = wtmain * wtset(9)/wtset(1)
     &       * kwgtcoulomb(2)/kwgtcoulomb(3) ! wtset(9)'=wtset(9)*cul/cul3
        wtot(id)  = wtot(id)  + weight
        wtot2(id) = wtot2(id) + weight**2
        ENDIF
* 9. Internal CC3 with Coulomb off
        IF (KeyCul.EQ.2 .AND. m_KeyAcc.EQ.0) THEN
        id = 9
        weight = wtmain * wtset(9)/wtset(1) 
     &       * kwgtcoulomb(1)/kwgtcoulomb(3) ! wtset(9)'=wtset(9)*cul/cul3
        wtot(id)  = wtot(id)  + weight
        wtot2(id) = wtot2(id) + weight**2
        ENDIF
*10. 4f with Coulomb unscreened
        IF (m_Key4f.EQ.1 .AND. ikandy.LT.2 
     &       .AND. KeyCul.EQ.2 .AND. m_KeyAcc.EQ.0) THEN
        id = 10
        weight = wtmain*( 1+wtset(9)/wtset(1) ! wt(1)'=wt(1)+wt(9)*(cul/cul3-1)
     &       *(kwgtcoulomb(2)/kwgtcoulomb(3)-1) )
        wtot(id)  = wtot(id)  + weight
        wtot2(id) = wtot2(id) + weight**2
        ENDIF
*11. 4f with Coulomb off
        IF (m_Key4f.EQ.1 .AND. ikandy.LT.2 
     &       .AND. KeyCul.EQ.2 .AND. m_KeyAcc.EQ.0) THEN
        id = 11
        weight = wtmain*( 1+wtset(9)/wtset(1) ! wt(1)'=wt(1)+wt(9)*(cul/cul3-1)
     &       *(kwgtcoulomb(1)/kwgtcoulomb(3)-1) ) 
        wtot(id)  = wtot(id)  + weight
        wtot2(id) = wtot2(id) + weight**2
        ENDIF
C
C Finalise
C
      ELSEIF (imode.EQ.1) THEN
        WRITE (6,*)
        WRITE (6,*) '_XSECMON finalising'
        IF (ntot.EQ.0) THEN
          WRITE (6,*) '_XSECMON No events processed?'
          GOTO 999
        ENDIF
        CALL karlud(1,xcrude,xcvesk,dumm1)
        IF (m_KeyWgt.EQ.0) THEN
* Unweigtd evts: normalisation of wtmain is relative to the best  x-section
          CALL gmonit(1,idyfs+80,averwt,errela,evtot)
          xsecnor0 = xcrude*averwt
          xerrnor0 = xsecnor0*errela ! ignore error on xcrude
        ELSE
* Weighted evts: normalisation of wtmain is relative to the crude x-section
          xsecnor0 = xcrude
          xerrnor0 = 0               ! ignore error on xcrude
        ENDIF
* Get the number of Kingal events generated so far
* Unweighted and weighted KORALW events:
* -  nacc0 is the number of events within the acceptance
* -  nacc1 is the number of these written to file
* -  nacc0-nacc1 are the events with problems or weight=0
* => USE NACC0 TO NORMALISE THE ANALYSIS!!!
* (also use it to compute the errors, else they are underestimated!)
        nacc0 = NEVENT(1)       ! #evts within the acceptance
        nacc1 = NEVENT(2)       ! #evts on file (no problems and wt>0)
        IF (nacc0.EQ.0) THEN
          WRITE (6,*) '_XSECMON No events accepted???'
          GOTO 999
        ENDIF
        xsecnor1 = xsecnor0 * nacc1/nacc0
        xerrnor1 = xerrnor0 * nacc1/nacc0
* Compute the xsections
        DO id = 1, nid
          averwt   = wtot(id)/ntot
          xsec(id) = xsecnor1*averwt
          IF (xsec(id).GT.0) THEN
            errela = dsqrt( max(0d0, 
     &           wtot2(id)/wtot(id)**2-1d0/ntot*nacc1/nacc0) )
            xerr(id) = xsec(id) * dsqrt(
     &           errela**2 + xerrnor1**2/xsecnor1**2 )
          ELSE
            xerr(id) = 0
          ENDIF
        END DO
C Dump all xsection
        WRITE (6,*)
     &       '=====================================',
     &       '====================================='
        WRITE (6,*)
     &       ' Various xsections for Kingal events '
        IF (m_KeyWgt.EQ.0) THEN
        WRITE (6,'(1x,a,i9,a)')
     &       ' from ', ntot, ' unweighted events'
        WRITE (6,*)
     &       ' (STATISTICAL PRECISION MAY BE LOW!) '
        ELSE
        WRITE (6,'(1x,a,i9,a)')
     &       ' from ', ntot, ' weighted events'
        ENDIF
        WRITE (6,*)
     &       '=====================================',
     &       '====================================='
 123    FORMAT(a38, f14.7, ' +- ', f14.7, ' pb')
        WRITE (6,123)
     &       ' Normalization x-section:', xsecnor0, xerrnor0
        WRITE (6,'(a38,i14)')
     &       ' Kingal events generated:', nacc0
        WRITE (6,'(a38,i14)')
     &       ' Kingal events accepted: ', nacc1
        WRITE (6,123)
     &       ' XSECMON norm. x-section:', xsecnor1, xerrnor1
        WRITE (6,*)
     &       '=====================================',
     &       '====================================='
        WRITE (6,123)
     &       ' Best          x-section:', xsec(1), xerr(1)
        WRITE (6,123)
     &       ' Internal CC3  x-section:', xsec(2), xerr(2)
        WRITE (6,*)
     &       '=====================================',
     &       '====================================='
        IF (m_key4f.EQ.1) THEN
        WRITE (6,123)
     &       ' Grace    CC3  x-section:', xsec(3), xerr(3)
        WRITE (6,123)
     &       ' Grace    NC2  x-section:', xsec(4), xerr(4)
        WRITE (6,*)
     &       '=====================================',
     &       '====================================='
        ENDIF
        IF (ikandy.NE.0) THEN
        WRITE (6,123)
     &       ' Internal CC3  x-section:', xsec(2), xerr(2)
        WRITE (6,123)
     &       ' IntCC3 + O(a) x-section:', xsec(5), xerr(5)
        WRITE (6,123)
     &       ' IntCC3: O(a) difference:', xsec(5)-xsec(2), 0
        WRITE (6,*)
     &       '=====================================',
     &       '====================================='
        ENDIF
        IF (ikandy.EQ.1 .AND. m_key4f.NE.0 
     &                  .AND. m_KeyISR.NE.0 .AND. m_i_prwt.EQ.4) THEN
        WRITE (6,123)
     &       ' Best          x-section:', xsec(1), xerr(1)
        WRITE (6,123)
     &       ' 4f + O(a)add  x-section:', xsec(6), xerr(6)
        WRITE (6,123)
     &       ' 4f: O(a)add difference: ', xsec(6)-xsec(1), 0
        WRITE (6,123)
     &       ' 4f + O(a)mult x-section:', xsec(7), xerr(7)
        WRITE (6,*)
     &       '=====================================',
     &       '====================================='
        ENDIF
        IF (keycul.EQ.2 .AND. m_KeyAcc.EQ.0) THEN
        WRITE (6,123)
     &       ' Internal CC3  x-section:', xsec(2), xerr(2)
        WRITE (6,123)
     &       ' IntCC3 Coul unscreened: ', xsec(8), xerr(8)
        WRITE (6,123)
     &       ' IntCC3 Coul OFF:        ', xsec(9), xerr(9)
        WRITE (6,123)
     &       ' IntCC3 CulUn difference:', xsec(8)-xsec(2), 0
        WRITE (6,123)
     &       ' IntCC3 CulOF difference:', xsec(9)-xsec(2), 0
        WRITE (6,*)
     &       '=====================================',
     &       '====================================='
        ENDIF
        IF (m_Key4f.EQ.1 .AND. ikandy.LT.2 
     &       .AND. KeyCul.EQ.2 .AND. m_KeyAcc.EQ.0) THEN
        WRITE (6,123)
     &       ' Best          x-section:', xsec(1), xerr(1)
        WRITE (6,123)
     &       ' 4f Coul unscreened:     ', xsec(10), xerr(10)
        WRITE (6,123)
     &       ' 4f Coul OFF:            ', xsec(11), xerr(11)
        WRITE (6,123)
     &       ' 4f CulUn difference:    ', xsec(10)-xsec(1), 0
        WRITE (6,123)
     &       ' 4f CulOF difference:    ', xsec(11)-xsec(1), 0
        WRITE (6,*)
     &       '=====================================',
     &       '====================================='
        ENDIF
C
C Exit
C
      ELSE
        WRITE (6,*) '_XSECMON invalid option'
        STOP
      ENDIF
 999  CONTINUE
      RETURN
      END

******************************************************************************
