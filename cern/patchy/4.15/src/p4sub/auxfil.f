CDECK  ID>, AUXFIL.
      SUBROUTINE AUXFIL (IOUSEP,LUNV,NAMEP)

C-    EXQ IOFILE, FOLLOW UPDATE OF LUN-AREA + PRINT MESSAGE

      COMMON /QBCD/  IQNUM2(11),IQLETT(26),IQNUM(10),IQPLUS
     +,              IQMINS,IQSTAR,IQSLAS,IQOPEN,IQCLOS,IQDOLL,IQEQU
     +,              IQBLAN,IQCOMA,IQDOT,IQAPO,  IQCROS
      COMMON /QUNIT/ IQREAD,IQPRNT,IQPR2,IQLOG,IQPNCH,IQTTIN,IQTYPE
     +,              IQDLUN,IQFLUN,IQHLUN,IQCLUN,  NQUSED
      COMMON /IOFCOM/IOTALL,IOTOFF,IOTON,IOSPEC,IOPARF(5),IOMODE(12)
      PARAMETER      (IQBDRO=25, IQBMAR=26, IQBCRI=27, IQBSYS=31)
      COMMON /QBITS/ IQDROP,IQMARK,IQCRIT,IQZIM,IQZIP,IQSYS
                         DIMENSION    IQUEST(30)
                         DIMENSION                 LQ(99), IQ(99), Q(99)
                         EQUIVALENCE (QUEST,IQUEST),    (LQUSER,LQ,IQ,Q)
      COMMON //      QUEST(30),LQUSER(7),LQMAIN,LQSYS(24),LQPRIV(7)
     +,              LQ1,LQ2,LQ3,LQ4,LQ5,LQ6,LQ7,LQSV,LQAN,LQDW,LQUP
C--------------    END CDE                             -----------------  ------
      DIMENSION    IOUSEP(9), LUNV(9), NAMEP(9)
      DIMENSION    LUNARE(9), MUNIT(2),  MVPRS(7), MVPR(11)
      EQUIVALENCE (MVPRS(1),MVPR(1),IQUEST(11)), (JUNIT,IOMODE(3))
      EQUIVALENCE (IDSTR,LUNARE(6)), (NEOF,LUNARE(7))
     +,           (NRECT,LUNARE(8)), (NREC,LUNARE(9))
      DATA  MUNIT  /4H RCR, 4H CAR/


C---- FILE DESCRIPTION VECTOR
C-
C-           LUNV (1)  FORTRAN LOGICAL UNIT USED IN READ/WRITE STATEMENT
C-                (3)  LUN= OR FILE=  PARAMETER
C-                (5)  IO-TYPE
C-                (6)  STREAM-NAME FOR PRINTING
C-                (7)  NUMBER OF FILES FINISHED READING
C-                (8)  TOTAL NUMBER OF RECORDS READ ON BIG-FILE
C-                     UP-DATED AT THE END OF EACH INDIVIDUAL FILE
C-                     RESET TO ZERO ON REWIND
C-                     = NEGATIVE: BIG-FILE NOT YET REFERENCED
C-                (9) NUMBER OF RECORDS READ ON CURRENT FILE


      IOUSE = IOUSEP(1)
      NAME  = NAMEP(1)
      CALL UCOPY  (LUNV(1),LUNARE(1),9)
      CALL IOFILE (IOUSE,LUNARE(1))
      IF (IOMODE(9).EQ.0)    GO TO 31


C-------           INITIAL REWIND
C- 1 ATT, 2 RES, 3 CAR, 4 DET, 5 EOF, 6 HOLD, 7 OUT, 8 CE, 9 INI, 10 FIN

C--              PERMANENTLY RECORD 'CARDS', 'OUTPUT', 'CETA', STREAM-ID

      CALL SBIT (IOMODE(3),LUNARE(5),3)
      CALL SBIT (IOMODE(7),LUNARE(5),7)
      CALL SBIT (IOMODE(8),LUNARE(5),8)
      IF (NAME.EQ.0)         GO TO 24
      IDSTR=NAME

   24 MVPR(7) = IDSTR
      WRITE (IQPRNT,9024) MVPRS
      GO TO 46

C-------           INTERMEDIATE FILE OR FINAL REWIND

   31 MVPR(7) = IDSTR
      IF (NREC.NE.0)         GO TO 33
      WRITE (IQPRNT,9024) MVPRS
      GO TO 45

   33 NRECT   = NRECT + NREC
      NEOF    = NEOF + 1
      MVPR(8) = NEOF
      MVPR(9) = NREC
      MVPR(10)= MUNIT(JUNIT+1)
      MVPR(11)= NRECT
      WRITE (IQPRNT,9034) MVPR

   45 IF (IOMODE(10).EQ.0)   GO TO 49
      IF (IOMODE(11).NE.0)   GO TO 46
      IF (IOMODE(6).NE.0)    GO TO 49
      NRECT = -1
      IF (IOMODE(4).NE.0)    GO TO 47
   46 NRECT = 0
   47 NEOF  = 0
   49 NREC  = 0
      CALL UCOPY (LUNARE(1),LUNV(1),9)
      RETURN

C9024 FORMAT (1X,6A1,2H ',A5,1H')                                       -A4
C9034 FORMAT (1X,6A1,2H ',A5,14H'   AFTER FILE,I3,6H  WITH,I6,A4,3HDS,, -A4
C    FI6,7H TOTAL.)                                                     -A4
 9024 FORMAT (1X,6A1,2H ',A4,1H')                                        A4
 9034 FORMAT (1X,6A1,2H ',A4,14H'   AFTER FILE,I3,6H  WITH,I6,A4,3HDS,,  A4
     FI6,7H TOTAL.)                                                      A4
      END
