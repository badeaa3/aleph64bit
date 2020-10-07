CDECK  ID>, YSHANL.
      SUBROUTINE YSHANL

C-    ANALYZE TAG-SELECTOR CARD IN BUFFER AT LEVEL 'LEV'

      COMMON /QBCD/  IQNUM2(11),IQLETT(26),IQNUM(10),IQPLUS
     +,              IQMINS,IQSTAR,IQSLAS,IQOPEN,IQCLOS,IQDOLL,IQEQU
     +,              IQBLAN,IQCOMA,IQDOT,IQAPO,  IQCROS
      PARAMETER      (IQBITW=32, IQBITC=8, IQCHAW=4)
      COMMON /QMACH/ NQBITW,NQCHAW,NQLNOR,NQLMAX,NQLPTH,NQRMAX,QLPCT
     +,              NQOCT(3),NQHEX(3),NQOCTD(3)
      COMMON /QUNIT/ IQREAD,IQPRNT,IQPR2,IQLOG,IQPNCH,IQTTIN,IQTYPE
     +,              IQDLUN,IQFLUN,IQHLUN,IQCLUN,  NQUSED
      PARAMETER      (IQBDRO=25, IQBMAR=26, IQBCRI=27, IQBSYS=31)
      COMMON /QBITS/ IQDROP,IQMARK,IQCRIT,IQZIM,IQZIP,IQSYS
                         DIMENSION    IQUEST(30)
                         DIMENSION                 LQ(99), IQ(99), Q(99)
                         EQUIVALENCE (QUEST,IQUEST),    (LQUSER,LQ,IQ,Q)
      COMMON //      QUEST(30),LQUSER(7),LQMAIN,LQSYS(24),LQPRIV(7)
     +,              LQ1,LQ2,LQ3,LQ4,LQ5,LQ6,LQ7,LQSV,LQAN,LQDW,LQUP
     +, KADRV(14),LADRV(11),LCCIX,LBUF,LLAST
     +, NVOPER(6),MOPTIO(31),JANSW,JCARD,NDECKR,NVUSEX(20)
     +, NVINC(6),NVUTY(17),IDEOF(9),NVPROX(6),LOGLVG,LOGLEV,NVWARX(6)
     +, NVOLDQ(6), NVOLD(10), IDOLDV(10), NVARRI(12), NVCCP(10)
     +, NVNEW(10), IDNEWV(10), NVNEWL(6),  MWK(80),MWKX(80)
     +,    NINDX,NTOTCC,LEV,NCHTAG,NWWTAG
C--------------    END CDE                             -----------------  ------

      EQUIVALENCE (LINDX,LQMAIN)
      EQUIVALENCE (LKARD,LQUSER(2)),(LMAC,LQUSER(3))

      DIMENSION MNAMES(4), MSEPS(5), MID(3), MACTAG(2)
      DATA      MNAMES /4HTAG ,1,1,2H**/
      DATA      MSEPS  /1H-,1H$,1H+,1H,,1H./
      DATA      MID    /3HNO ,3HMAC,3HYES/
      DATA      MACTAG /4HMAC ,4HTAG /  ,  KSMAC /1/

C--      START NEW CARD, SPACE OVER 'MACRO' OR 'TAG' , ELSE ASSUME 'TAG'

      LMAC  = 0
      LKD   = IQ(LKARD-LEV)

      IF (IQ(LKD).NE.0)      GO TO 11
      CALL UBUNCH (IQ(LKD+1),IQUEST(1),3)
      J         = IUFIND (IQUEST(1),MACTAG(1),1,2)
      IQ(LKD-2) = MIN  (J-1,1)
      IF (J.EQ.3)            GO TO 11
      IQ(LKD)   = IUFIND (IQCOMA,IQ(LKD+1),1,10)

   11 LCHOLD = LKD + IQ(LKD  )
      LCHEND = LKD + IQ(LKD-1)
      IFLAG =        IQ(LKD-2)

C--        START OF TAG

   12 LCHOLD = LCHOLD + 1
      IF (LCHOLD.GT.LCHEND)  RETURN
      J = IUCOMP (IQ(LCHOLD),MSEPS,5)
      IF (J.EQ.0)            GO TO 18
      IF (J.GE.4)            GO TO 13
      IFLAG = J - 2
      GO TO 12
   13 IF (J.EQ.4)            GO TO 12
      RETURN

C--        T A G   COLLECTION

   18 LCHNEW = LCHOLD - 1
   19 LCHNEW = LCHNEW + 1
      IF (LCHNEW.GT.LCHEND)  GO TO 23

      J = IUCOMP (IQ(LCHNEW),MSEPS,5)
      IF (J.EQ.0)            GO TO 19

C--        TERMINATOR FOUND

   23 NCH = LCHNEW - LCHOLD
      IF (IFLAG.EQ.0)        GO TO 50

C--        TAG FOUND. SET UP POINTER IN INDEX AND LIFT ITS BANK

      IFIRST = IQ(LCHOLD)
      IF (NINDX.EQ.0)        GO TO 30
      J = IUCOMP (IFIRST,IQ(LINDX+1),NINDX)
      IF (J.NE.0)            GO TO 35

   30 NINDX = NINDX + 1
      IQ(LINDX+NINDX) = IFIRST
      J = NINDX

   35 K = LINDX - J
      MNAMES(4) = NCH+ 1
      CALL LIFTBK (L,K,0,MNAMES(1),0)
      IQ(L+1) = NCH - 1
      IQ(L+2) = IFLAG
      IF (NCH.EQ.1)          GO TO 36
      CALL UCOPY (IQ(LCHOLD+1),IQ(L+3),NCH-1)
   36 N = LCHOLD + NCH - 1
      IF (LOGLEV.GE.1)
     +             WRITE (IQPRNT,9036) MID(IFLAG+2),(IQ(J),J=LCHOLD,N)
      LCHOLD = LCHNEW - 1
      GO TO 12


C--------- LABEL IS A MACRO. SEARCH APPROPRIATE BANK

   50 IQ(LKD  ) = LCHNEW - LKD
      IQ(LKD-2) = 0
      IQUEST(12) = IQBLAN                                               -A8M
      CALL UBUNCH (IQ(LCHOLD),IQUEST(11),NCH)

C     LMAC = LQFIND   (IQUEST(11),1,KSMAC,KF)                            A8M
      LMAC = LQLONG (2,IQUEST(11),1,KSMAC,KF)                           -A8M
      IF (LMAC.EQ.0)         GO TO 70
      RETURN

C--        MACRO BANK NOT FOUND. FATAL ERROR

   70 CALL UBLOW (IQUEST(11),IQUEST(1),NCH)
      WRITE (IQPRNT,9070) (IQUEST(J),J=1,NCH)
      CALL PABEND

 9036 FORMAT(6X,1H.,A3,2H. ,10A1)
 9070 FORMAT (1X/17H UNDEFINED MACRO ,8A1)
      END
