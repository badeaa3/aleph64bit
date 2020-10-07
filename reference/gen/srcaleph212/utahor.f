      SUBROUTINE UTAHOR(ITANA,ITAID,NRLO,IMFLG,INDB,INDC,LUNPR)
C ---------------------------------------------------------------------
C.
C! - Print the the table body horizontally
C.
C. - Author   : A. Putzer  - 87/08/14
C. - Modified : A. Putzer  - 89/03/14
C.
C.
C.   Arguments: -  ITANA CHA*4 (input) Name of the bank wanted
C.              -  ITAID INTE  (input) Table (ADAMO) ID
C.              -  NRLO  INTE  (input) NR (BOS) for the current table
C.              -  IMFLG INTE  (input)
C.                             1 = Table taken from d/a file
C.                             2 = Table taken from memory
C.              -  INDB  INTE  (input) INDEX (BOS) for the current table
C.              -  INDC  INTE  (input) INDEX (BOS) for the .COL table
C.              -  LUNPR INTE  (input) Unit number for print output
C.
C ---------------------------------------------------------------------
      SAVE
C - Column numbers in the .COL table for
C           Column Name, Type, Format, TableID
      PARAMETER (JCOLNA = 2, JCOLTY = 6, JCOLFO = 7, JCOLTI = 9)
C - Storage dimension
      PARAMETER (JSTOR = 27)
      DIMENSION ISTOR(JSTOR),FMT(63),FMT2(JSTOR)
C
      CHARACTER*4 ITANA,ICOLT,FMT,IOPBR,ICLBR
      CHARACTER*4 IIMPL,FMT2,ISTOR,IIGEN
      CHARACTER*4 ICH16,ICHA8
      CHARACTER*6 JCOL
      CHARACTER*12 IDASH,JCONT
      CHARACTER*14 COLNA,FORMA
      CHARACTER*24 IFHOR
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON /BCS/   IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
      CHARACTER*4 CTABL,CHAINT
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
C - Lth CHAR*4 element of the NRBOSth row of the bank with index ID
      CTABL(ID,NRBOS,L) = CHAINT(IW(ID+LMHLEN+(NRBOS-1)*IW(ID+1)+L))
C.................
      DATA IOPBR/'(1X,'/,ICLBR/'   )'/
      DATA IIMPL/'IMPL'/,ICH16/'CH16'/,ICHA8/'CHA8'/
      DATA IIGEN/'GEN '/
      DATA IFHOR/'''| Row ='',I7,1X,''|'' '/
      DATA COLNA/' Column Name  '/,FORMA/'  Format      '/
      DATA JCOL /' Col ='/,IDASH/'-----------|'/
      DATA JCONT/'      =     '/
C
      IFLAG = 0
      CALL UTCBLK(FMT  ,63)
      CALL UTCBLK(FMT2 ,JSTOR)
      FMT( 1) = IOPBR
      FMT(63) = ICLBR
      NCOLB = LCOLS(INDB)
      NROWB = LROWS(INDB)
      NCOLC = LCOLS(INDC)
      NROWC = LROWS(INDC)
      CALL UTAHDR(ITANA,NRLO,IMFLG,NCOLB,NROWB,1,LUNPR)
      ICMIN = 1
      ICMAX = NCOLB
      WRITE(LUNPR,6004) ( JCOL,ICOL ,ICOL=ICMIN,ICMAX)
 6004 FORMAT(1X,'|              |',
     +             9(A6,I4,' |'))
      WRITE(LUNPR,6005) ((IDASH),I=ICMIN,ICMAX)
 6005 FORMAT(1X,'|--------------|',9A12)
C
C- Get colum specs. for this table from .COL
C
      IDC = 0
      NCC = 0
      KK = 1
      JJ = 8
      CALL UTCCOP(IFHOR,FMT(2),6)
      LL = INDC + LMHLEN - NCOLC
C
C - Loop over the rows in .COL
C
 200    IDC = IDC + 1
        LL = LL + NCOLC
        IF (ITABL(INDC,IDC,JCOLTI).NE.ITAID) GO TO 200
        ICOLT = CTABL(INDC,IDC,JCOLTY)
        IF (ICOLT.EQ.IIMPL) GO TO 200
        NCC = NCC + 1
        DO 635 IJ = 1,3
 635      ISTOR(KK+IJ-1) = CTABL(INDC,IDC,JCOLNA+IJ-1)
        IF (ICOLT.EQ.ICH16) ICOLT=IIGEN
        FMT2(KK) = CTABL(INDC,IDC,JCOLFO)
        FMT2(KK+1) = CTABL(INDC,IDC,JCOLFO+1)
        CALL UTCOFO(ICOLT,FMT2(KK),FMT(JJ))
        IF (ICOLT.EQ.IIGEN) THEN
          CALL UTCCOP(FMT(JJ),FMT(JJ+ 5),5)
          CALL UTCCOP(FMT(JJ),FMT(JJ+10),5)
          CALL UTCCOP(FMT(JJ),FMT(JJ+15),5)
          CALL UTCCOP(JCONT,FMT2(KK+3),3)
          CALL UTCCOP(JCONT,FMT2(KK+6),3)
          CALL UTCCOP(JCONT,FMT2(KK+9),3)
          CALL UTCCOP(JCONT,ISTOR(KK+3),3)
          CALL UTCCOP(JCONT,ISTOR(KK+6),3)
          CALL UTCCOP(JCONT,ISTOR(KK+9),3)
          JJ = JJ+15
          KK = KK+9
          NCC= NCC+3
        ELSEIF (ICOLT.EQ.ICHA8) THEN
          CALL UTCCOP(FMT(JJ),FMT(JJ+ 5),5)
          CALL UTCCOP(JCONT,FMT2(KK+3),3)
          CALL UTCCOP(JCONT,ISTOR(KK+3),3)
          JJ = JJ+5
          KK = KK+3
          NCC= NCC+1
        ENDIF
        IF (NCC.LT.NCOLB) THEN
          KK=KK+3
          JJ = JJ+5
          GO TO 200
        ENDIF
      WRITE(LUNPR,6010) COLNA,(ISTOR(I),I=1,3*NCOLB)
 6010 FORMAT(1X,'|',A14,'|',9(1X,2A4,A2,'|'))
      WRITE(LUNPR,6010) FORMA,(FMT2(I),I=1,3*NCOLB)
      WRITE(LUNPR,6005) ((IDASH),I=ICMIN,ICMAX)
      WRITE(LUNPR,FMT,ERR=199) (JJ,(IW(INDB+2+(JJ-1)*NCOLB+II),
     +                          II = 1,NCOLB)      ,JJ=1,NROWB)
 199  CONTINUE
      WRITE(LUNPR,6005) ((IDASH),I=ICMIN,ICMAX)
      RETURN
      END
