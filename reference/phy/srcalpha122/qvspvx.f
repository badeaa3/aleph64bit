      SUBROUTINE QVSPVX(BPOS,BSIZ,TSMR,PVTX,EPVTX,IERR)
CKEY  QVSRCH / INTERNAL
C ----------------------------------------------------------------------
C! Finds primary vertex and 2 jet directions in preparation for QVSTVX
C  Called from QVSRCH
C
C  Author : T. MATTISON  U.A.BARCELONA/SLAC  1 DECEMBER 1992
C
C  Input Arguments :
C  *  BPOS() IS BEAM POSITION
C       BPOS(2) MUST BE AN ACCURATE BEAM Y COORDINATE,
C       I.E., QVYNOM OR OUTPUT FROM GETBP
C       BPOS(1),BPOS(3) ARE ONLY USED FOR X AND Z TRACK CUTS
C  *  BSIZ() IS SIZE OF LUMINOUS REGION (1 SIGMA)
C  *  TSMR IS ADDITIONAL SMEARING FOR TRACKS
C       .0100 CM (100 MICRONS) MAKES ERRORS FAIRLY HONEST ON B EVENTS
C       .0000 CM GIVES BETTER RESOLUTION IN UDS EVENTS
C  Output Arguments :
C  *  PVTX() IS PRIMARY VERTEX IN ALEPH XYZ COORDINATES
C  *  EPVTX() IS ERROR (NOT VARIANCE) IN PVTX
C       MAY BE NEGATIVE, INDICATING A PROBLEM, NOT NECESSARILY SEVERE,
C       IN FINDING THE PRIMARY VERTEX
C  *  EPVTX(2) IS COPY OF BSIZ(2)
C  *  IERR IS ERROR FLAG WORD
C       0 FOR OK
C       1 FOR QUESTIONABLE PRIMARY VERTEX
C       2 FOR NOT ENOUGH TRACKS FOR PRIMARY VERTEX
C
C ----------------------------------------------------------------------
      DIMENSION BPOS(3),BSIZ(3),PVTX(3),EPVTX(3)
C  LENGTH OF GOOD-TRACK LIST
      PARAMETER (MGTK=100)
      DIMENSION JGTK(MGTK)
C  NUMBER OF POINTS IN X SCAN
      PARAMETER (LBX=50)
C  NUMBER OF POINTS IN Z SCAN
      PARAMETER (LBZ=50)
C  SIZE NEEDED FOR TWO DIMENSIONAL LIKELIHOOD FUNCTION
C  PLUS SCRATCH SPACE
      PARAMETER (LVLF=LBX*LBZ+LBX+LBZ)
C ----------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
      INTEGER IW
      REAL RW(10000)
      COMMON /BCS/ IW(10000)
      EQUIVALENCE (RW(1),IW(1))
      COMMON /YVSWRK/ IPTR
C ----------------------------------------------------------------------
      IERR=0
C
C  MAKE GOOD TRACK LIST FOR COARSE Z VERTEX
      CALL QVSGTL0(BPOS,MGTK,NGTK,JGTK)
C  BAIL OUT IF NO TRACKS
      IF (NGTK .LT. 1) THEN
        IERR=2
        RETURN
      ENDIF
C
C  GET SOME WORK SPACE
      IPTR=0
      LEN=LVLF
      CALL QVSWBK(LEN,'QVSP')
C
C  FIRST FIND COARSE Z POSITION OF EVENT
C  NUMBER OF POINTS
      NB=100
C  SCAN RANGE: BPOS +/- 3 SIGMA
      ZL=BPOS(3)-3.*BSIZ(3)
      ZH=BPOS(3)+3.*BSIZ(3)
C  IGNORE TRACKS BEYOND 3 SIGMA
      SGMX=3.
C  FIND COARSE Z VERTEX BY 1 DIMENSIONAL SCAN
      CALL YVSZVC(BPOS,NGTK,JGTK,SGMX,NB,ZL,ZH,RW(IPTR+1),ZVC,EZVC)
C
C  BAIL OUT IF IT FAILED
      IF (EZVC .LT. 0.) THEN
        IERR=2
        GOTO 999
      ENDIF
C
C  CENTER THINGS ON THE BEAM
      PVTX(1)=BPOS(1)
      PVTX(2)=BPOS(2)
C  AND THE COARSE Z FOUND ABOVE
      PVTX(3)=ZVC
C  MAKE NEW GOOD TRACK LIST
      CALL QVSGTL1(PVTX,MGTK,NGTK,JGTK)
C  BAIL OUT IF NO TRACKS
      IF (NGTK .LT. 1) THEN
        IERR=2
        GOTO 999
      ENDIF
C
C  CONTROL PARAMETERS FOR PRIMARY VERTEX SCAN
C  NUMBER OF POINTS IN X SCAN
      NBX=LBX
C  SCAN RANGE IN X: +/- 500 MICRONS
C  CENTERED ON BPOS
      XL=BPOS(1)-.0500
      XH=BPOS(1)+.0500
C  SCAN POINTS IN Z
      NBZ=LBZ
C  SCAN RANGE IN Z: +/- 500 MICRONS
C  OR 3 SIGMA OF COARSE VERTEX
      DZ=MAX(.0500,3.*EZVC)
C  CENTERED ON COARSE Z FOUND ABOVE
      ZL=ZVC-DZ
      ZH=ZVC+DZ
C  CUT OFF TRACKS AT 3 SIGMA
      SGMX=3.
C
C  FIND X AND Z OF PRIMARY VERTEX BY PROJECTING TRACKS TO BEAM PLANE
      CALL YVSXZB(BPOS,BSIZ,NGTK,JGTK,TSMR,SGMX,
     > NBX,XL,XH,NBZ,ZL,ZH,RW(IPTR+1),
     > PVTX(1),EPVTX(1),PVTX(3),EPVTX(3),PKVL)
C
      IF (EPVTX(1) .LT. 0. .OR. EPVTX(3) .LT. 0.) THEN
        IERR=1
      ENDIF
C
C  NOMINAL ERROR (BEAM HEIGHT) IN Y
      EPVTX(2)=BSIZ(2)
C
  999 CONTINUE
C  DROP WORK BANK
      CALL WDROP(IW,IPTR)
C
      RETURN
      END
