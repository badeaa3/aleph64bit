      SUBROUTINE UTBKPR(IBKNA,IBSNR,IRWNR,LUNDA,LUNPR,IFLAG)
C ---------------------------------------------------------------------
C.
C! - Print the content of tables in memory
C.
C. - Author   : A. Putzer  - 87/10/12
C. - Modified : A. Putzer  - 87/11/20
C.
C.
C.   Arguments: -  IBKNA (input) Name of the bank wanted (or 'ALL ')
C.              -                (or 'X   ' for all banks starting
C.              -                with X)
C.              -  IBSNR (input) BOS NR (or 0 for all)
C.                               ignored if more than one table
C.                               requested
C.              -  IRWNR (input) Row NR (or 0 for all)
C.                               ignored if more than one table
C.                               requested
C.              -  LUNDA (input) Unit number for the d/a file
C.              -  LUNPR (input) Unit for print out
C.              -  IFLAG(output) Error flag  = 0 ok
C.                                            -1 No format info on d/a
C.                                            -2 No info for this table
C.                                            -3 Table not on this d/a
C.                                            -4 Table empty
C.
C ---------------------------------------------------------------------
      SAVE
C - Column numbers in the TAB2 table for
C           Table ID, Table name
      PARAMETER (JTABID = 1, JTABNA = 2)
C - Maximum number of colums which can be printed horizontally
      PARAMETER (NCOMX = 9)
C
      CHARACTER*4 IBALL,IBKNA,ITANA,IBKXX,IITCA
      CHARACTER*1 IBKN1(4),BLK1,ITAN1(4)
      LOGICAL WILDF
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON /BCS/   IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
      EQUIVALENCE (IBKXX,IBKN1(1))
      EQUIVALENCE (ITANA,ITAN1(1))
      EXTERNAL MDARD,NDANR,NDROP
      CHARACTER*4 CTABL ,CHAINT
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
C...............
      DATA IOUDA/0/,BLK1/' '/
      DATA IBALL/'ALL '/,IITCA/'ITCA'/
      INDC = MDARD(IW,LUNDA,'COL2',0)
C
      IFLAG = 0
C
C - Drop banks TAB2 and COL2 if the d/a unit has changed
C - otherwise BOS will not copy the banks from d/a to memory!
C
      IF (IOUDA.NE.LUNDA) THEN
        IND = NDROP('TAB2',0)
        IND = NDROP('COL2',0)
      ENDIF
      IOUDA = LUNDA
C
C - Get Bank TAB2 from d/a file into memory
C
      INDT = MDARD(IW,LUNDA,'TAB2',0)
C
C - Is table information in this daf at all?
C
      IF (INDT.EQ.0) THEN
        IFLAG = -1
        WRITE(LUNPR,6000)
 6000   FORMAT(//' * UTBKPR * --> No table information on this DAF',//)
        GO TO 999
      ENDIF
      NROWT = LROWS(INDT)
C
C - Get Bank COL2 from d/a file into memory
C
      INDC = MDARD(IW,LUNDA,'COL2',0)
      IF (INDC.EQ.0) THEN
        IFLAG = -1
        WRITE(LUNPR,6001)
 6001   FORMAT(//' * UTBKPR * -> No Column information on this DAF',//)
        GO TO 999
      ENDIF
C
C - Check if a wild character is used ?
C
      IBKXX = IBKNA
      IF(IBKN1(2).EQ.BLK1) THEN
        WILDF = .TRUE.
      ELSE
        WILDF = .FALSE.
      ENDIF
C
C - Loop over all tables on which information exists on d/a file
C
      ICOUN = 0
      DO 100 I = 1,NROWT
        ITAID = ITABL(INDT,I,JTABID)
        ITANA = CTABL(INDT,I,JTABNA)
C
C - Table  'ITCA' cannot be printed > 256 colums !!!
C
        IF (ITANA.EQ.IITCA) GO TO 100
C
        IF (ITANA.EQ.IBKNA.OR.IBKNA.EQ.IBALL.OR.
     +      (WILDF.AND.IBKN1(1).EQ.ITAN1(1))) THEN
          ICOUN = ICOUN + 1
C
C - Check if bank is in memory
C
          INDB = IW(NAMIND(ITANA))
C
C - Does this bank exist ?
C
          IF (INDB.EQ.0) THEN
            IF (IBKNA.EQ.IBALL.OR.WILDF) GO TO 100
            IFLAG = -3
            WRITE(LUNPR,6003) IBKNA
 6003       FORMAT(//' * UTBKPR * --> Table ',A4,' not in memory',//)
            GO TO 999
          ELSE
            NRLO = IW(INDB-2)
            IMFLG = 2
            NCOLB = LCOLS(INDB)
            NROWB = LROWS(INDB)
C
C- Check if bank is filled
C
            IF (NROWB.EQ.0) THEN
              IF (IBKNA.EQ.IBALL.OR.WILDF) GO TO 100
              IFLAG = -4
              WRITE(LUNPR,6004) IBKNA
 6004         FORMAT(//' * UTBKPR * --> Table ',A4,' empty',//)
              GO TO 999
            ELSE
C
C - Decide on print format (horizontal or vertical)
C
              IF (NCOLB.LE.NCOMX) THEN
                CALL UTAHOR(ITANA,ITAID,NRLO,IMFLG,INDB,INDC,LUNPR)
              ELSE
                CALL UTAVER(ITANA,ITAID,NRLO,IMFLG,INDB,INDC,LUNPR)
              ENDIF
            ENDIF
          ENDIF
        ENDIF
 100  CONTINUE
C
C - Check if column information was stored for a selected table
C
      IF (ICOUN.EQ.0) THEN
        IF (IBKNA.EQ.IBALL.OR.WILDF) GO TO 999
        IFLAG = -2
        WRITE(LUNPR,6002) IBKNA
 6002   FORMAT(//' * UTBKPR * -> No Column info. for table ',A4,//)
      ENDIF
 999  CONTINUE
      RETURN
      END
