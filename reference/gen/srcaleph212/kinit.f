      SUBROUTINE KINIT (LBCS,LBASE,LCARD,LOUT,LWRT,FMT)
C -----------------------------------------------------------------
C - F.Ranjard - 870504    modified 870924 B.Bloch for Data Base
C - Modified JULY88 B.Bloch for Data Base access and KJOB Bank
C! Initialize event interface package
CKEY KINE KINGAL INIT  /   INTERNAL
C  MUST be called by the user once per job
C  can be called a 2nd times if the user has modified some parameters
C  by data cards.
C  if 1st entry then
C     initialize the BOS array with LBCS words
C     if LCARD.ne.0 then read data cards and RETURN
C  endif
C  if 1st entry and LCARD.eq.0  or  if 2nd entry and LCARD.ne.0  then
C     read the data base from LBASE unit to get PART bank
C     stop if no PART bank
C     if LOUT.ne.0 then set BOS output unit = LOUT
C     if LWRT.ne.0 then initialize BOS writing unit LWRT
C     book and fill RUNH and KRUN banks with default values
C  endif
C  if 3rd entry then STOP
C
C - structure: SUBROUTINE subprogram
C              User Entry Name: KINIT
C              External References: BOS/BKFMT/BLIST/BREADC/BUNIT(BOS77)
C                                   ACDARG/AFILOU/AOPDBS/AOPEN/AOPENW/
C                                   ADBVER/JUNIDB/
C                                   BKINJB/
C                                   ALRUNH/ALKRUN/ALKJOB(ALEPHLIB)
C              Comdecks referenced: BCS, KIPARA,BMACRO
C
C - usage  : CALL KINIT (LBCS,LBASE,LCARD,LOUT,LWRT,FMT)
C - Input  : LBCS   = BOS array length (at least 10000 words)
C            LBASE  = data base logical unit (not used)
C            LCARD  = data card log. unit ( 0 means no data card)
C            LOUT   = print out unit      ( 0 means no printout)
C            LWRT   = output file unit    ( 0 means no output file)
C            FMT    = output file format    ( 'EPIO' or ' '='NATI')
C            LOUT, LWRT, FMT could be overwritten by data card
C
      SAVE
      CHARACTER*(*) FMT
      CHARACTER*60  TITLE
      CHARACTER     TFNAM*60,TATYP*60,TDEVI*60
      INTEGER ALKJOB,ALRUNH,ALKRUN,ALRUNR
      INTEGER ALGTDB
      EXTERNAL ALGTDB
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON /BCS/   IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
CKEY KINE KINGAL DEFAULT
      PARAMETER (LHKIN=3, LPKIN=5, LKVX=2, LHVER=3, LPVER=5, LVKI=50)
      PARAMETER (LGDCA=32)
      PARAMETER (LRPART=200, LCKLIN=1)
      PARAMETER (LRECL=16020, LRUN=1, LEXP=1001, LRTYP=1000)
      CHARACTER*60 LTITL
      PARAMETER (LUCOD=0, LNOTRK=100, LTITL='KINGAL run')
      PARAMETER (LUTRK=350)
      PARAMETER (BFIEL=15., CFIEL=BFIEL*3.E-4)
      DATA IFI /0/
C!    set of intrinsic functions to handle BOS banks
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
C -------------------------------------------------------------------
      IFI = IFI + 1
      IF (IFI-2) 1,2,3
    1 CONTINUE
C - BOS initialization
C
      CALL BOS (IW,LBCS)
      IF (LCARD .GT. 0) IW(5) = LCARD
C
      CALL BKFMT ('VERT','3I,4F,(I)')
      CALL BKFMT ('KINE','3I,4F,(I)')
C
      CALL BLIST (IW,'C=','RUNRRUNHKRUNKJOBPART')
      CALL BLIST (IW,'E=','EVEHKEVHVERTKINE')
C
C - Get ALEPHLIB version #
      CALL ALVERS (ALEFV)
C
C - Initialize default values
C
      IRUN = LRUN
      IEXP = LEXP
      IRTYP = LRTYP
      IUCOD = LUCOD
      NOTRK = LNOTRK
      TITLE = LTITL
C
C - Read data cards if required
C
      IF (LCARD .GT.0) THEN
        CALL BREADC
        GOTO 999
      ENDIF
C
    2 CONTINUE
      IF (IFI.EQ.2 .AND. LCARD.EQ.0) GOTO 999
C
C - Set logical units according to data cards if any
C
      IF (LOUT  .GT. 0) IW(6) = LOUT
C
C - Initialize output file LWRT
      JFILO = IW(NAMIND('FILO'))
      IF (JFILO .NE. 0) THEN
        CALL AFILOU (TFNAM,TATYP,TDEVI,IRET)
        IF (IRET.NE.0) THEN
           WRITE (IW(6),'(/1X,''KINIT: wrong output file name'',
     &      '' (AFILOU) - STOP'',I4)') IRET
           CALL EXIT
        ENDIF
        IF (LWRT .EQ. 0) LWRT = 2
C
C Open the output file :
        CALL AOPENW (LWRT,TFNAM,TATYP,TDEVI,IRET)
        IF (IRET.NE.0) THEN
           WRITE (IW(6),'(/1X,''KINIT: cannot open output file'',
     &        '' (AFILOU) - STOP'',I4)') IRET
           CALL EXIT
        ENDIF
      ELSE
        LREC = LRECL
        IF (FMT .NE. 'EPIO') LREC = LRECL/2
        CALL BUNIT (LWRT,FMT,LREC)
      ENDIF
C
C - Read the data base to get the 'PART' bank
C
      LBAS = JUNIDB(0)
C
C   Open DAF once for all
      CALL AOPDBS ('   ',IRETD)
      IF (IRETD.NE.0) THEN
         WRITE (IW(6),'(/1X,''KINIT: NO data base (AOPDBS) - STOP'')')
         CALL EXIT
      ENDIF
C   Get ADBSCONS DAF version # and date of last change
      CALL ADBVER (IVERS,IDATE)
C   Get PART bank from the DAF
      IREDB=MDARD(IW,LBAS,'PART',0)
      IF (IREDB.LE.0) THEN
C     error in reading data base - STOP
         WRITE (IW(6),'(/1X,''error in reading data base - STOP'',
     &                      I3)') IREDB
         CALL EXIT
      ENDIF
      IF (LCOLS(IREDB).EQ.8) THEN
         CALL BKFMT('PART','2I,(I,3A,I,3F)')
      ELSEIF (LCOLS(IREDB).EQ.10) THEN
         CALL BKFMT ('PART','2I,(I,3A,I,4F,I)')
      ENDIF
C
C - Fill RUNR, RUNH and KRUN banks with default values
C
      IRUNR = ALRUNR (IEXP,IRUN)
      IF (IRUNR .LE. 0) THEN
C     error in filling RUNR bank - STOP
        WRITE (IW(6),'(/1X,''not enough space for RUNR - STOP'')')
        CALL EXIT
      ENDIF
      IRUNH = ALRUNH (IRUN,IEXP,IRTYP)
      IF (IRUNH .LE. 0) THEN
C     error in filling RUNH bank - STOP
        WRITE (IW(6),'(/1X,''not enough space for RUNH - STOP'')')
        CALL EXIT
      ENDIF
      IKRUN = ALKRUN (IUCOD,NOTRK,TITLE)
      IF (IKRUN .LE. 0) THEN
C     error in filling KRUN bank - STOP
        WRITE (IW(6),'(/1X,''not enough space for KRUN - STOP'')')
        CALL EXIT
      ENDIF
      IKJOB = ALKJOB (IVERS,IDATE)
      IF (IKJOB .LE. 0) THEN
C     error in filling KJOB bank - STOP
        WRITE (IW(6),'(/1X,''not enough space for KJOB - STOP'')')
        CALL EXIT
      ENDIF
      GOTO 999
C
    3 CONTINUE
      WRITE (IW(6),'(/1X,''too many entries in KINIT - STOP'')')
      CALL EXIT
C
  999 RETURN
      END