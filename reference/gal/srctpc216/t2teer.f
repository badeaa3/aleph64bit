      SUBROUTINE T2TEER
C
C! Main steering routine for semi-detailed TPC simulation, to
C  produce analog and/or digitized signals on the pads, wires,
C  and/or trigger-pads
C
C  Called from:   TPMAIN (Main program)
C  Calls:         RDMIN,TORDEV,BDROP,TPBRTP,TPBRTK,TIMEL,TPGETR,
C                 T2DEDX,T2TRAN,TSPCPL,TSTCPL,TPSGNL,WDROP,
C                 TPOPSG,TSRESP,TWRRED,TPENSC,TSWREV
C
C  A. Caldwell, D. DeMille, P. Janot
C ----------------------------------------------------------------------
C  Modifications :
C            1. P. Janot  23 Mar 1988 -- Drop Track Element BANKs
C            2. P. Janot  05 May 1988 -- Add a loop over affected
C                                        time bins to reproduce
C                                        the pulse length.
C            3. D. Cowen  13 Jul 1988 -- Be sure to skip to the
C                                        next sector, after cleaning
C                                        previous one, as advertised.
C            4. D. Cowen  21 Oct 1988 -- Call TDEBUG only if requested.
C            5. P. Janot  04 mar 1988 -- Do a garbage collection
C                                        after each sector.
C            6. P. Janot  05 mar 1988 -- Set to zero NLPHIT
C                                 and NTPHIT (otherwise these
C                                 variables are not initialized and
C                                 lead to an infinite loop in TPSGNL)
C            5. F.Ranjard 28 Mar 1989 -- add an argument in TDEBUG.
C                                        call RDMIN when INSEED(1).NE.0
C            6. Z.FENG    28 Apr 1991 -- replace TSWRED WITH TWRRED
C            7. D. Casper -- add 2% smearing of dE/dx event by
C               event to simulate pressure variations and other
C               systematics.
C            7. D. Casper -- add 2% smearing of dE/dx event by
C               event to simulate pressure variations and other
C               systematics.
C ----------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON /BCS/   IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
C
C  TPCBOS contains parameters for handling BOS banks used in the
C  generation of analog and digitized signals in the TPC
C  NCHAN = number of channel types for analog signals and digitizations
C  at present, NCHAN = 3; 1 = wires, 2 = pads, 3 = trigger pads.
      PARAMETER ( NCHAN = 3 )
C
C  Work bank id's.  INDREF(ich) = index for signal reference bank for
C  channel of type ich; INDSIG = index for signal bank for current
C  channel.  IDCLUS = index for cluster bank
C
      COMMON/WORKID/INDREF(NCHAN),INDSIG,IDCLUS,ITSHAP,ITDSHP,
     *              ITPNOI,ITSNOI,ITPULS,ITMADC,INDBRT,INDHL,INDDI
C
C  Parameters for analog signal work banks:  for each type of channel,
C  include max number of channels, default number of channels in
C  signal bank, and number of channels by which to extend signal bank
C  if it becomes full; also keep counter for number of blocks actually
C  filled in signal bank
C
      COMMON/ANLWRK/MAXNCH(NCHAN),NDEFCH,NEXTCH,NTSGHT
C
C  Parameters for digitises (TPP) output banks
C
      COMMON/DIGBNK/NDIDEF(3),NDIEXT(3)
C
C  Hit list and digitization bank parameters: for each type of channel
C  include name nam, default length ndd, and length of extension nde.
C
      COMMON/TPBNAM/DIGNAM(2*NCHAN)
      CHARACTER*4 DIGNAM
C  Name index for track element bank
      COMMON/TPNAMI/NATPTE
C
C
C  TPCOND  conditions under which this simulation
C  will be performed
C
      COMMON /DEBUGS/ NTPCDD,NCALDD,NTPCDT,NCALDT,NTPCDA,NCALDA,
     &                NTPCDC,NCALDC,NTPCDS,NCALDS,NTPCDE,NCALDE,
     &                NTPCDI,NCALDI,NTPCSA,NCALSA,NTPCDR,NCALDR,
     &                LTDEBU
      LOGICAL LTDEBU
      COMMON /SIMLEV/ ILEVEL
      CHARACTER*4 ILEVEL
      COMMON /GENRUN/ NUMRUN,MXEVNT,NFEVNT,INSEED(3),LEVPRO
      COMMON /RFILES/ TRKFIL,DIGFIL,HISFIL
      CHARACTER*64 TRKFIL,DIGFIL,HISFIL
      COMMON /TLFLAG/ LTWDIG,LTPDIG,LTTDIG,LWREDC,FTPC90,LPRGEO,
     &                LHISST,LTPCSA,LRDN32,REPIO,WEPIO,LDROP,LWRITE
      COMMON /TRANSP/ MXTRAN,CFIELD,BCFGEV,BCFMEV,
     &                        DRFVEL,SIGMA,SIGTR,ITRCON
      COMMON /TPCLOK/ TPANBN,TPDGBN,NLSHAP,NSHPOF
      COMMON /AVLNCH/ NPOLYA,AMPLIT
      COMMON /COUPCN/ CUTOFF,NCPAD,EFFCP,SIGW,SIGH,HAXCUT
      COMMON /TGCPCN/ TREFCP,SIGR,SIGARC,RAXCUT,TCSCUT
      COMMON /DEFAUL/ PEDDEF,SPEDEF,SGADEF,SDIDEF,WPSCAL,NWSMAX,THRZTW,
     &                LTHRSH,NPRESP,NPOSTS,MINLEN,
     &                LTHRS2,NPRES2,NPOST2,MINLE2
      COMMON /SHAOPT/ WIRNRM,PADNRM,TRGNRM
C
      LOGICAL LTWDIG,LTPDIG,LTTDIG,LPRGEO,
     &        LWREDC,LTPCSA,LHISST,FTPC90,LRND32,
     &        REPIO,WEPIO,LDROP,LWRITE
C
      LOGICAL LTDIGT(3)
      EQUIVALENCE (LTWDIG,LTDIGT(1))
C
      REAL FACNRM(3)
      EQUIVALENCE (WIRNRM,FACNRM(1))
C
C
C  TPCONS contains physical constants for TPC simulation
C
      COMMON /DELTA/ CDELTA,DEMIN,DEMAX,DELCLU,RADFAC,CYLFAC
      PARAMETER (MXGAMV = 8)
      COMMON /TGAMM/ GAMVAL(MXGAMV),GAMLOG(MXGAMV),POIFAC(MXGAMV),
     &               POIMAX,POIMIN,CFERMI,CA,CB,POIRAT,POICON
      PARAMETER (MXBINC = 20)
      COMMON /CLUST/ EBINC(MXBINC),CONCLU,WRKFUN,MXCL,CKNMIN,CFANO,CRUTH
     &              ,POWERC
      COMMON /AVALA/ THETA,ETHETA
      COMMON /TPTIME/ NTMXSH,NTMXNO,NTMXAN,NTMXDI,NTSCAN,NTBNAS,NTBAPD
      COMMON /TPELEC/ TPRPAR,TPRSER,TPCFET,TCFEED,TMVPEL,TSIGMX,NTPBIT
C
C  TRAKEL:  track parameters for dE/dX and carrying around broken
C  tracks
C
      COMMON/TRAKEL/NTRK,X(3),VECT(3),ABSMOM,SEGLEN,TOF,AMASS,CHARGE,
     *              RAD,CENT(2),DELPSI,PSI1,ALPH01,ALPH02
C - MXBRK = 2* MAX(NLINES(1..3)) + 2 , NLINES= 8,10,10 in /SCTBND/
      PARAMETER (MXBRK=22, MXBRTE=MXBRK/2)
      COMMON/BRKNTK/XB(3,6),VECTB(3,6),SEGLNB(6)
      COMMON / HISCOM / IHDEDX,IHTRAN,IHAVAL,IHCOUP,IHTRCP,IHBOS,IHTOT
      PARAMETER (LTPDRO=21,LTTROW=19,LTSROW=12,LTWIRE=200,LTSTYP=3,
     +           LTSLOT=12,LTCORN=6,LTSECT=LTSLOT*LTSTYP,LTTPAD=4,
     +           LMXPDR=150,LTTSRW=11)
C
      COMMON /TPGEOM/RTPCMN,RTPCMX,ZTPCMX,DRTPMN,DRTPMX,DZTPMX,
     &               TPFRDZ,TPFRDW,TPAVDZ,TPFOF1,TPFOF2,TPFOF3,
     &               TPPROW(LTPDRO),TPTROW(LTTROW),NTSECT,NTPROW,
     &               NTPCRN(LTSTYP),TPCORN(2,LTCORN,LTSTYP),
     &               TPPHI0(LTSECT),TPCPH0(LTSECT),TPSPH0(LTSECT),
     &               ITPTYP(LTSECT),ITPSEC(LTSECT),IENDTP(LTSECT)
C
C
C  FASTER : variables used in fast simulation
C
      COMMON / LANDAU / NITLAN,NITIND,INTWRD
      COMMON / EXBEFF / XPROP,TTTT,XXXX(1001),XSHFT(50)
      COMMON / EVT / IEVNT,ISECT
      COMMON / T3TR / JSEGT,NSEGT,ITYPE,WIRRAD(4),WIRPHI(4)
     &               ,AVTIM(4),NELE(4),NCL,SIGT(4)
      COMMON / TPSG / CC(3),XX(3),TOTDIS,XLEN,ISTY,IE
      COMMON / XBIN / IBIN(4),NAVBIN(4),NB
      DIMENSION XEX(4,4)
      PARAMETER (SQ2=1.4142136,SQ3=1.7320508)
C
C  CHANNL carries the analog signals on all channels due to one
C  wire avalanche
C
C  Wire avalanche information
C  NAVELE     -- The charge from an avalanche
C  IBIN1  -- The first bin to get charge
C
      COMMON / AVALAN / NAVELE,IBIN1
C
C  Long pad coupling information
C  MPPUL   -- The array containing the coupled avalanches
C  NAMP   -- Pad 'name' generating this pulse
C            = (pad row-1)*150 + pad number
C
      PARAMETER (MXPHIT=15)
      COMMON / PADPUL / MPPUL(MXPHIT),NAMP(MXPHIT)
C
C  Trigger pad coupling information
C  MTPUL   -- The array containing the coupled avalanches
C  NAMT   -- Pad 'name' generating this pulse
C            = (tpad row# - 1)*(max # tpads/row) + tpad number
C
      PARAMETER (MXTHIT=2)
      COMMON / TRGPUL / MTPUL(MXTHIT),NAMT(MXTHIT)
      DATA NLPHIT,NTPHIT/0,0/
C
C TLIM = Tolerance used in time limit test. (CPU timing units)
C
      DATA TLIM/5./
C
C  Set the random seed for the beginning of this run
C
        IF (INSEED(1).NE.0) CALL RDMIN(INSEED)
C
C  Loop over events
C
      NLEVNT = NFEVNT + MXEVNT - 1
      DO 6 IEVNT = NFEVNT,NLEVNT
C
C  Read in event header and track element banks for this event.
C  IRET = 1 means we've tried to read a non existing event. Then
C  we've reached the end of the run and we write out C list. If we
C  have succesfully read an event, set up parameters for breaking tracks
C  at sector boundaries and get the number of track elements NTREL.
C
        CALL TORDEV(IEVNT,IRET)
        IF ( IRET .EQ. 1 ) THEN
            WRITE(6,30)
  30        FORMAT(1X,'Try to read a non-existing event'/
     &             1X,'       Run end reached')
            GOTO 999
        ENDIF
C
C  Drop fake coordinate banks
C
        IND = NLINK('TPCO',0)
        IF(IND.NE.0) THEN
           CALL BDROP(IW,'TPCOTPCHTCRL')
        ENDIF
C
C  add 2% smearing of ionization in quadrature event by event
C
        CALL RANNOR(FL1,FL2)
        POIMIN = POICON * (1.+0.0165*FL1)
C
C  Write out RUNH, EVEH, and TPTE banks for each event
C  if requested (for standalone version only!)
C
        IF (LTDEBU) CALL TDEBUG (IEVNT)
C
C  Setup work bank for broken track elements
C
        CALL TPBRTP(NTREL,IERR)
        IF (IERR .NE. 0) GOTO 998
C
C  Loop over sectors
C
        DO 5 ISECT = 1, 36
C
C  Get the sector type
C
          ITYPE = ITPTYP(ISECT)
          MISECT = ISECT
          IF(ISECT.GT.18) MISECT = ISECT-18
C
C  Loop over track segments in event
C
          DO 4 ISEG = 1, NTREL
C
C  Find track parameters and break track element at sector boundaries
C
            CALL TPBRTK(ISECT,ITYPE,MISECT,ISEG,NBRTRE)
C
C  Loop over broken track elements (i.e., track elements which lie
C  entirely in sector isect)
C
            DO 3 IBRTRE = 1, NBRTRE
C
C  Check CPU time remaining; exit if insufficient.
C
                  CALL TIMEL(TLEFT)
                  IF(TLEFT.LT.TLIM) THEN
                     WRITE( 6,10008) IEVNT,ISECT
10008                FORMAT(1X,'******* TIME LIMIT REACHED *******'/
     *                         '*** JOB TERMINATED PREMATURELY ***',/
     *                      1X,'Current event  No. : ',I5/
     *                      1X,'Current sector No. : ',I5)
                     GOTO 999
                  ENDIF
C
C  Load parameters for this broken track element into a common for the
C  dE/dX routine
C
              CALL TPGETR(IBRTRE)
C
C  Now generate the dE/dx for this track.  The dE/dx is discrete unless
C  the formation of primaries becomes too large, in which case it is
C  done continuously. For the continuous case, the clusters are formed
C  at fixed intervals.  The cluster size is set to account correctly for
C  the dE/dx.
C  The number and coordinates of super-broken segments are also
C  determined, to put the right charge on each wire.
C  If IRETD = 1 there is not enough space to extend signal bank.
C  Go to next sector. If IRETD = 2, there is not enough space to
C  extend cluster bank. Go to next broken segment.
C
              CALL T2DEDX(IRETD)
C
              IF (IRETD .EQ. 1) GOTO 99
              IF (IRETD .EQ. 2) THEN
                CALL WDROP(IW,IDCLUS)
                GOTO 4
              ENDIF
C
C  Loop over super-broken segments along this broken track segment
C
              DO 2 JSEGT =  1,NSEGT
C
C  Get pointer to this super-broken segment in segment bank.
C
                INDEX = 2 + IDCLUS + (JSEGT-1)*10
                IF(IW(INDEX+10).EQ.1.AND.JSEGT.NE.NSEGT) GOTO 2
C

C   Now transport the NCL clusters to the endplate,taking into
C   account the ExB effect and the diffusion.
C
                CALL T2TRAN(IWIR)
                IF(IWIR.EQ.0) GOTO 2
C
C  Loop over clusters in super-broken segment
C
                DO 1 JCL = 1 , NCL
C
C  Form the avalanche at the wire for each arriving cluster.
C  IRETA = 1 means that the avalanche is in an illegal time bin
C
                  IF(NELE(JCL).EQ.0) GOTO 1
C
C  Determine the wire signal length (in time) for each arriving
C  cluster. Then form the avalanche at the wire and share the
C  released charge between the time bins. IRETA = 1 means that
C  the avalanche is in illegal time bins.
C
                  CALL TPAVAL(JCL,IRETA)
                  IF ( IRETA .EQ. 1) GOTO 1
C
C  If the long pads and/or the trigger pads are 'on', couple each
C  avalanche to the appropriate pads.
C
                  IF ( LTPDIG )
     &            CALL TSPCPL(ISECT,ITYPE,WIRRAD(JCL),WIRPHI(JCL),
     &                        NLPHIT)
                  IF ( LTTDIG )
     &            CALL TSTCPL(ITYPE,WIRRAD(JCL),WIRPHI(JCL),NTPHIT)
C
C  Loop over affected time bins
C
                  DO 11 IB = 1,NB
                    IBIN1     = IBIN(IB)
                    NAVELE    = NAVBIN(IB)
C
C  Add the signal to the ones that already exist
C  If there is not enough space to extend signal bank, skip processing
C  of analog signal for this sector.
C
                    CALL TPSGNL(IWIR,NLPHIT,NTPHIT,IRETS)
                    IF(IRETS.EQ.1) GOTO 99
C
C  End loop over time bins
C
11                CONTINUE
C
C  End loop over clusters in segment
C
 1              CONTINUE
C
C  End loop over super-broken segments
C
 2            CONTINUE
C
C  End loop over broken track elements
C
              CALL WDROP(IW,IDCLUS)
 3          CONTINUE
C
C  End loop over full track elements
C
 4        CONTINUE
C
C  Now we have analog signals for this sector. Compress out the
C  signal bank and save them if we want to.  Skip to next sector
C  on error return.
C
          CALL TPOPSG(NTSGHT,IERR)
          IF (IERR .EQ. 1) GOTO 99
C
C  If we want digitizations, process the signals from this sector
C  through the electronics
C
          IF ( LTWDIG .OR. LTPDIG .OR. LTTDIG )
     *       CALL TSRESP(ISECT,ITYPE)
C
C  End of sector; clean out sector-dependent banks and counters
C
   99     CALL TPENSC
          CALL BGARB(IW)
C
C  Next sector
C
 5      CONTINUE
C
C  Do wire data reduction if requested, and drop sector wire digitisings
C
          CALL TWRRED(IER)
          IF (IER.EQ.1) THEN
            CALL ALTELL('TWRRED: No Run header found',0,'FATAL')
          ELSEIF (IER.EQ.2) THEN
            CALL ALTELL('TWRRED: Database Bank missing',0,'FATAL')
          ELSEIF (IER.EQ.5) THEN
            CALL ALTELL('TWRRED: BOS run out of space',1,'NEXT')
          ELSEIF (IER.EQ.6) THEN
            CALL ALTELL('TWRRED: NO pedestal Info found',0,'FATAL')
          ELSEIF (IER.EQ.7) THEN
            CALL ALTELL('TWRRED: missing TSWP Bank in DBASE',0,
     &                          'FATAL')
          ENDIF
          CALL BLIST(IW,'E+','TRIRTRDITSIRTSDI')
          CALL BDROP(IW,'TWIRTWDI')
C
C  Drop track element BANKS
C
  998   CONTINUE
        IF(LDROP) CALL BDROP(IW,'TPTETTHETTHTTPHE')
C
C  End of event; write out and drop the event-dependent stuff
C  Also drop TWDI bank from E-list if wire data reduction was
C  requested.
C
        CALL WDROP(IW,INDBRT)
C
        IF (LTWDIG.AND.LWREDC) THEN
           CALL BLIST(IW,'E-','TWDI')
        ENDIF
C
        CALL TSWREV(IEVNT)
        CALL BGARB(IW)
C
C  Get next event
C
 6    CONTINUE
C_______________________________________________________________________
C
 102  FORMAT('/',' !!!!!!!!!!   TRACK SEGMENT:',I4,'  TRACK:',I4,
     *            '   NOT PROCESSED  !!!!!!!!!!!','1')
C
 999  CONTINUE
      RETURN
      END
