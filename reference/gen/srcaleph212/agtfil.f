      SUBROUTINE AGTFIL (CARD,FLGIO,LUN,IER)
C ----------------------------------------------------------------
C - F.Ranjard - 891208
CKEY ALEF OPEN READ WRITE / USER
C! open a file given on data card
C
C - Input  : CARD   / CHA4  = data card name
C            FLGIO  / CHA4  = 'READ' or 'WRIT'
C            LUN    / I     = logical unit number
C - Output : IER    / I     = return code
C                             = 0 means OK
C                             = -1 no such data card
C  check that the data card CARD is present.
C  if it it there get the fname,ftype,fdevice
C  open the file on unit # LUN in FLGIO (READ or WRITe) mode
C ----------------------------------------------------------------
      CHARACTER*(*) CARD, FLGIO
      CHARACTER*80 FNAM,FDEV
      CHARACTER*4 ATYP
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON /BCS/   IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
C -----------------------------------------------------------------
C
      IER = 0
C - get data card CARD
      CALL ACDARG (CARD,'  ','*',FNAM,ATYP,FDEV,IER)
      IF (IER.EQ.-1) RETURN
C
C - open the file
      LE = LNBLNK(FNAM)
      IF (FLGIO.EQ.'READ') CALL AOPEN (LUN,FNAM(1:LE),ATYP,FDEV,IER)
      IF (FLGIO.EQ.'WRIT') CALL AOPENW(LUN,FNAM(1:LE),ATYP,FDEV,IER)
C
C - if open failed write a message
      IF (IER.NE.0.AND.IW(6).GT.0) THEN
         CALL AWERRC (IW(6),'AGTFIL',FNAM,IER)
      ENDIF
C
      END
