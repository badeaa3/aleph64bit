      SUBROUTINE ABOPEN (CASE,JRET)
C --------------------------------------------------------------
C - F.Ranjard - 900927          from H.Albrecht
CKEY ALPHARD OPEN
C! DALI open files (open in interactive mode)
C
C - Input   : CASE   / A4 = 'BOTH' open next FILI and FILO cards
C                           'FILI' open next FILI or FILM card
C                           'FILO' open next FILO card
C - Output  : JRET   / I  = 5  means files are opened
C                           6  no more input file
C                          13  error in FILI card
C                          14  cannot open input file
C                          15  error in FILO card
C                          16  cannot open output file
C - ENTRY ABSTUN (LINDAT,LINSEL,LUTDAT,LUTSEL)
C   to set logical units to these values
C   LOOK internal use only
C ----------------------------------------------------------------
      CHARACTER*(*) CASE
      INTEGER ACARD1
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON /BCS/   IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
      COMMON /ABRCOM/ BATCH,INIT,CLOSE1,CLOSE2,FWFILM
     &               ,IUNDAT(2),IUTDAT(5),IUNSEL,IUNSE2,IUTSEL
     &               ,MASKA,MASKW
     &               ,WLIST,TLIST
      LOGICAL BATCH, INIT, CLOSE1, CLOSE2, FWFILM
      CHARACTER*1   TLIST, WLIST
C
      DATA NCLAS / 0/
C ---------------------------------------------------------------
C - 1st entry
      IF (NCLAS .EQ. 0) THEN
         NCLAS = NAMIND ('CLAS')
         IFWITH = 0
         CLOSE1 = .FALSE.
         FWFILM = .FALSE.
C----Clear card counter
        IDUM=ACARD1('    ')
C----set logical units to 0
        IUNDAT(1) = 0
        IUNSEL = 0
        IUNSE2 = 0
        IUTDAT(1) = 0
        IUTSEL = 0
      ENDIF
C
C - next entry
C
      IRET = 5
      CALL BDROP (IW,'FILM')
      IF (CLOSE1.AND.IFWITH.EQ.0) CALL BCLAST (IUTSEL)
C --
      IF (CASE.EQ.'BOTH' .OR. CASE.EQ.'FILI') THEN
C----   Open  input files
C             IER=0  OK
C             IER=-1 cannot open input file
C             IER=-2 problem getting FILM card
C             IER=-3 no more FILI card
C             IER>0  FILI or FILM card error
         CALL AOPERD(IUNDAT, IUNSEL, IUNSE2, IER )
         IF(IER.NE.0) GOTO 100
      ENDIF
C --
      IF (CASE.EQ.'BOTH' .OR. CASE.EQ.'FILO') THEN
C----   Open  output files
C             IER=0  OK
C             IER=-1 cannot open output file
C             IER>0  FILO card error
         CALL AOPEWR(IUNDAT, IUTSEL, IUTDAT, IER )
         IF (IER.NE.0) IER = IER+30
         CALL AOPEWW(IFWITH)
      ENDIF
C --
C----Tell BOS what to do, in case of select files
C----so far, only one input/output stream for select files
      LOUT = 0
      IF (IUTSEL.NE.0) LOUT = IUTDAT(1)
      CALL BISELU(IUNDAT,IUNSEL,IUNSE2,LOUT)
C
 100  IFLG = IER
      IF (IFLG .EQ. 0)  THEN
         IF (IUTSEL .NE. 0) THEN
C          set write-EDIR flag
            CLOSE1 = .TRUE.
C          if EDIR is on input set write-FILM flag
C          the FILM card will be written when the 1st event is
C          selected (1st call to ABWSEL)
            IF (IFWITH.EQ.0) FWFILM = .TRUE.
         ENDIF
C      class word is probably cleared (?!?!!!),  set it again ...
         JCLAS = IW(NCLAS)
         IF (JCLAS .NE. 0)  THEN
            DO 510 NP=1,IW(JCLAS)
  510       CALL BCLASR (IW(JCLAS+NP))
         ENDIF
         GO TO 900
C
      ELSEIF (IFLG .EQ.-3)  THEN
C       No more input files :
           IRET = 6
      ELSEIF (IFLG.NE.-1 .AND. IFLG .LT. 10)  THEN
C       Error in FILI cards or cannot get FILM card
           IRET = 13
      ELSE
         CLOSE1 = .FALSE.
         IF (IFLG .EQ. -1)  THEN
C         Cannot open input file :
            IRET = 14
         ELSEIF (IFLG .GT. 30)  THEN
C         Error in FILO cards :
            IRET = 15
         ELSE
C         Cannot open output file :
            IRET = 16
         ENDIF
      ENDIF
C
  900 CONTINUE
      JRET = IRET
      RETURN
C -------------------------------------------------------------
C
      ENTRY ABSTUN (LINDAT,LINSEL,LUTDAT,LUTSEL)
      IUNDAT(1) = LINDAT
      IUNSEL = LINSEL
      IUTDAT(1) = LUTDAT
      IUTSEL = LUTSEL
      RETURN
C -------------------------------------------------------------
      END
