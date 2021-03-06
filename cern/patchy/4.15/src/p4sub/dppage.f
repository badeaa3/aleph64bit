CDECK  ID>, DPPAGE.
      SUBROUTINE DPPAGE

      COMMON /QBCD/  IQNUM2(11),IQLETT(26),IQNUM(10),IQPLUS
     +,              IQMINS,IQSTAR,IQSLAS,IQOPEN,IQCLOS,IQDOLL,IQEQU
     +,              IQBLAN,IQCOMA,IQDOT,IQAPO,  IQCROS
      COMMON /QHEADP/IQHEAD(20),IQDATE,IQTIME,IQPAGE,NQPAGE(4)
      PARAMETER      (IQBITW=32, IQBITC=8, IQCHAW=4)
      COMMON /QMACH/ NQBITW,NQCHAW,NQLNOR,NQLMAX,NQLPTH,NQRMAX,QLPCT
     +,              NQOCT(3),NQHEX(3),NQOCTD(3)
      COMMON /QUNIT/ IQREAD,IQPRNT,IQPR2,IQLOG,IQPNCH,IQTTIN,IQTYPE
     +,              IQDLUN,IQFLUN,IQHLUN,IQCLUN,  NQUSED
      COMMON /DPWORK/JDPMKT(2),JDPMK(2),JDECKN,MMLEV,MMACT, LEAD(14)
     +,              MTAIL(36),LTAIL(36), IDDEPP(2),IDDEPD(2),IDDEPZ(2)
     +,              JNUMM,KNUMM(5), JDEC,KDEC(5), JNUM,KNUM(5)
      PARAMETER      (IQBDRO=25, IQBMAR=26, IQBCRI=27, IQBSYS=31)
      COMMON /QBITS/ IQDROP,IQMARK,IQCRIT,IQZIM,IQZIP,IQSYS
                         DIMENSION    IQUEST(30)
                         DIMENSION                 LQ(99), IQ(99), Q(99)
                         EQUIVALENCE (QUEST,IQUEST),    (LQUSER,LQ,IQ,Q)
      COMMON //      QUEST(30),LQUSER(7),LQMAIN,LQSYS(24),LQPRIV(7)
     +,              LQ1,LQ2,LQ3,LQ4,LQ5,LQ6,LQ7,LQSV,LQAN,LQDW,LQUP
     +, KADRV(9), LEXD,LEXH,LEXP,LPAM,LDECO, LADRV(14)
     +, NVOPER(6),MOPTIO(31),JANSW,JCARD,NDECKR,NVUSEB(14),MEXDEC(6)
     +, NVINC(6),NVUTY(16),NVIMAT(6),NVACT(6),NVGARB(6),NVWARN(6)
     +, NVARRQ(6),NVARR(10),IDARRV(10),NVARRI(12),NVCCP(10)
     +, NVDEP(19),MDEPAR,NVDEPL(6),  MWK(80),MWKX(80)
      DIMENSION      IDD(2),             IDP(2),             IDF(2)
      EQUIVALENCE
     +       (IDD(1),IDARRV(1)), (IDP(1),IDARRV(3)), (IDF(1),IDARRV(5))
C--------------    END CDE                             -----------------  ------

C     EQUIVALENCE (LEADCC,LEAD(3))                                      A5,A10
C     EQUIVALENCE (LEADCC,LEAD(5))                                      A8
      EQUIVALENCE (LEADCC,LEAD(1))                                      A4,A6

 9001 FORMAT                (1H1,I4,61X,3H P=,2A4,3H D=,2A4,1X,I2,
     F21X,4HPAGE,I4/1X)
 9002 FORMAT (1X/1X,I4,A5,A4,2X,50(1H=),3H P=,2A4,3H D=,2A4,4H  1 ,
     F28(1H=)/1X)
 9003 FORMAT   (1H1,I4,A5,A4,2X,50(1H=),3H P=,2A4,3H D=,2A4,4H  1 ,
     F19(1H=),5H PAGE,I4/1X)


C------            DECK WITH +LIST SELECTION

      NLU = NQUSED
      IF (NVDEPL(5).EQ.0)    GO TO 16
      IF (NVDEPL(5).GE.0)    GO TO 11
      NLU = NLU + MAX (NVDEPL(5),NQLNOR-NQLMAX)
      GO TO 12
   11 NLU = NLU + MIN (NVDEPL(5),3)
   12 NVDEPL(5) = 0
   16 IF (NVDEPL(1).EQ.0)    GO TO 21

C--                NEW PAGE, NOT FIRST OF CURRENT DECK

   18 IF (NLU.LT.NQLNOR)     RETURN
      IF (NQUSED.GT.NQLMAX)  GO TO 29
      NQPAGE(2)= NQPAGE(2) + 1
      WRITE (IQPRNT,9001) NDECKR,IDP,IDD,IQPAGE,NQPAGE(2)
      IQPAGE= IQPAGE + 1
      NQUSED= NQLPTH + 2
      LEADCC= IQBLAN
      RETURN

C-------           PAGE 1 FOR DECK WITH +LIST SELECTION

   21 IF (MEXDEC(4).EQ.0)            GO TO 41
      IF (MOPTIO(3)+NVDEPL(4).NE.0)  GO TO 24
      IF (NVDEPL(2).GE.12)           GO TO 27

C--                PAGE 1 WITHOUT EJECT

   24 MARG = 12
   25 IF (NLU+MARG.GE.NQLNOR)  GO TO 27
      WRITE (IQPRNT,9002) NDECKR,IDF,IDP,IDD
      NQUSED= NQUSED + 3
      IQPAGE= 2
      NVDEPL(1)= 1
      RETURN

C--                PAGE 1 WITH EJECT

   27 IF (NQUSED.GT.NQLMAX)  GO TO 29
      NQPAGE(2) = NQPAGE(2) + 1
      WRITE (IQPRNT,9003) NDECKR,IDF,IDP,IDD,NQPAGE(2)
      NQUSED= NQLPTH + 2
      IQPAGE= 2
      NVDEPL(1)= 1
      RETURN

   29 NQUSED = NQUSED - NQLMAX
      NLU    = NLU    - NQLMAX
      GO TO 16

C-------           PAGE 1 FOR DECK WITHOUT +LIST, MESSAGE PRINT

   41 MARG = 6
      GO TO 25
      END
