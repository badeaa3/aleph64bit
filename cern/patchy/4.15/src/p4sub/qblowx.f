CDECK  ID>, QBLOWX.
      SUBROUTINE QBLOWX (LN)

C-    QBLOW AND QNAME WITH LEGALITY CHECK
C-    FORTRAN VERSION FOR MINIMAL PACKING,  WORD-SIZE 32 BITS OR MORE

      PARAMETER      (NQFNAE=2, NQFNAD=1, NQFNAU=3)
      PARAMETER      (IQFSTR=19, NQFSTR=6,  IQFSYS=25, NQFSYS=8)
      COMMON /MQCF/  NQNAME,NQNAMD,NQNAMU, IQSTRU,NQSTRU, IQSYSB,NQSYSB
      COMMON /MQCMOV/NQSYSS
      COMMON /MQCM/         NQSYSR,NQSYSL,NQLINK,LQWORG,LQWORK,LQTOL
     +,              LQSTA,LQEND,LQFIX,NQMAX, NQRESV,NQMEM,LQADR,LQADR2
      COMMON /QCN/   IQLS,IQID,IQNL,IQNS,IQND,IQFOUL
      PARAMETER      (IQBITW=32, IQBITC=8, IQCHAW=4)
      COMMON /QMACH/ NQBITW,NQCHAW,NQLNOR,NQLMAX,NQLPTH,NQRMAX,QLPCT
     +,              NQOCT(3),NQHEX(3),NQOCTD(3)
      PARAMETER      (IQBDRO=25, IQBMAR=26, IQBCRI=27, IQBSYS=31)
      COMMON /QBITS/ IQDROP,IQMARK,IQCRIT,IQZIM,IQZIP,IQSYS
                         DIMENSION    IQUEST(30)
                         DIMENSION                 LQ(99), IQ(99), Q(99)
                         EQUIVALENCE (QUEST,IQUEST),    (LQUSER,LQ,IQ,Q)
      COMMON //      QUEST(30),LQUSER(7),LQMAIN,LQSYS(24),LQPRIV(7)
     +,              LQ1,LQ2,LQ3,LQ4,LQ5,LQ6,LQ7,LQSV,LQAN,LQDW,LQUP
C--------------    END CDE                             -----------------  ------



      L = LN + 1
      IF (LQ(L).GE.0)  GO TO 91
      IQNL= JBYT (LQ(L),22,9)
      IQNS= JBYT (LQ(L),16,6)
      IQND= JBYT (LQ(L),1,15)
      IQLS= L + IQNL + 1
      IF (IQNL.LT.IQNS)  GO TO 91
      IF (IQLS+IQND.GE.NQMAX)  GO TO 91
      IF (JBYT(IQ(IQLS),IQSTRU,NQSTRU).NE.IQNS)  GO TO 91
C     IF (JBYT(IQ(IQLS),34,9)         .NE.IQNL)  GO TO 91               B48M
      IQID= LQ(LN)
      IDF = JBYT (IQID,NQBITW-7,8)
      IF (IDF.EQ.0)    GO TO 91
      IF (IDF.EQ.255)  GO TO 91
      IQFOUL= 0
      RETURN

   91 IQFOUL= -1
      RETURN
      END
