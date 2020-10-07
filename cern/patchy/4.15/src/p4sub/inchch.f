CDECK  ID>, INCHCH.
      SUBROUTINE INCHCH

C-    DECODE C/C-CHARCTER SUBSTITUTION CODE
C-    TO PREPARE SUBSTITUTION CONTROL INFORMATION IN /CCHCH/

      COMMON /QBCD/  IQNUM2(11),IQLETT(26),IQNUM(10),IQPLUS
     +,              IQMINS,IQSTAR,IQSLAS,IQOPEN,IQCLOS,IQDOLL,IQEQU
     +,              IQBLAN,IQCOMA,IQDOT,IQAPO,  IQCROS
      COMMON /QUNIT/ IQREAD,IQPRNT,IQPR2,IQLOG,IQPNCH,IQTTIN,IQTYPE
     +,              IQDLUN,IQFLUN,IQHLUN,IQCLUN,  NQUSED
      COMMON /CCHCH/ IFORPL,NOTHCC,MORGCC(6),MREPCC(6)
      COMMON /LUNSLN/NSTRM,NBUFCI,LUNVL(3),LUNVN(9),NOPTVL(4),NCHCH(6)
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
C--------------    END CDE                             -----------------  ------
      DIMENSION    M(14), MCHCH(7)
      EQUIVALENCE (M(1),IQUEST(11))
      DATA  MCHCH  /1H+,1H-,1H*,1H&,1H!,1H?,1HC/

      CALL VZERO (IFORPL,14)
      CALL UBLOW (NCHCH(1),M(1),14)

   14 CALL SBIT0 (MOPTIO(31),3)
   15 CALL ULEFT (M(1),1,14)
      IF (M(1).NE.IQLETT(1)) GO TO 17
      M(1) = IQBLAN
      GO TO 15

   17 JTK = 0

C----              ANALYSE PAIRS OF CHARACTERS

   21 JOLD = IUCOMP (M(JTK+1),MCHCH(1),7)
      JNEW = IUCOMP (M(JTK+2),MCHCH(1),7)
      IF (JOLD.EQ.0)  JOLD=IUCOMP(M(JTK+1),IQNUM(2),7)
      IF (JNEW.EQ.0)  JNEW=IUCOMP(M(JTK+2),IQNUM(2),7)
      IF (JOLD.EQ.0)         GO TO 31
      IF (JNEW.EQ.0)         GO TO 31
      IF (JOLD.NE.1)         GO TO 24
      IFORPL = MCHCH(JNEW)
      GO TO 27

   24 NOTHCC = NOTHCC + 1
      MORGCC(NOTHCC) = MCHCH(JOLD)
      MREPCC(NOTHCC) = MCHCH(JNEW)
   27 JTK = JTK + 2
      IF (NOTHCC.LT.6)       GO TO 21

C--                PRINT SUBSTITUTIONS TO BE DONE

   31 WRITE (IQPRNT,9031)
      IF (IFORPL.EQ.0)       GO TO 33
      WRITE (IQPRNT,9032)    MCHCH(1),IFORPL
   33 IF (NOTHCC.EQ.0)       RETURN
      WRITE (IQPRNT,9032)   (MORGCC(J),MREPCC(J),J=1,NOTHCC)
      RETURN

 9031 FORMAT (1X)
 9032 FORMAT (' CONTROL-CHARACTER SUBSTITUTION,  CHANGE  ',A2,3HTO ,A1)
      END
