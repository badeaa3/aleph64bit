CDECK  ID>, FRCETA.
      SUBROUTINE FRCETA (KARD)

C-    READ 1 CARD FROM CETA BUFFER, READ FROM TAPE

      COMMON /QBCD/  IQNUM2(11),IQLETT(26),IQNUM(10),IQPLUS
     +,              IQMINS,IQSTAR,IQSLAS,IQOPEN,IQCLOS,IQDOLL,IQEQU
     +,              IQBLAN,IQCOMA,IQDOT,IQAPO,  IQCROS
      COMMON /QUNIT/ IQREAD,IQPRNT,IQPR2,IQLOG,IQPNCH,IQTTIN,IQTYPE
     +,              IQDLUN,IQFLUN,IQHLUN,IQCLUN,  NQUSED
      COMMON /ARRCOM/LUNPAM,NCHKD,NWKD,NCARDP,NAREOF,NSKIPR,KDHOLD(20)
     +,              NTRUNC,IPROMU,IPROMI
      COMMON /COMCET/INILEV,NWCEIN,NCHCEU,NWCEU
     +,              NWCEBA,IPAKCE(5),IPAKKD(5),JPOSA1,MXINHO
     +,              LCESAV(4)
      PARAMETER      (KDNWT=20, KDNWT1=19,KDNCHW=4, KDBITS=8)
      PARAMETER      (KDPOST=25,KDBLIN=32,KDMARK=0, KDSUB=63,JPOSIG=1)
      COMMON /KDPKCM/KDBLAN,KDEOD(2)
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
     +, NVOLDQ(4),MVOLD1,MVOLDN,  NVOLD(7),NRTOLD,NROLD,MAXEOF
     +, IDOLDV(8),JPDOLD,JOLD, NVARRI(9),LARX,LARXE,LINBIN, NVCCP(10)
     +, NVNEW(7),NRTNEW,NRNEW,LLASTN, IDNEWV(8),JPDNEW,NDKNEW
     +, NVNEWL(3),NCDECK,JNEW,MODEPR,  MWK(80),MWKX(80)
      EQUIVALENCE (LORGH,LQPRIV(1)), (LORGI,LQPRIV(2))
     +,           (LXREF,LQPRIV(3)), (LTOCE,LQPRIV(4))
     +,           (LCETA,LQPRIV(7))
      EQUIVALENCE (LSTART,LCESAV(1)), (LEND, LCESAV(2))
     +,           (LSTORE,LCESAV(3)), (LTAKE,LCESAV(4))
C--------------    END CDE                             --------------
      EQUIVALENCE (LUNOLD,NVOLD(1))
      EQUIVALENCE (NCH,NCHKD)
      DIMENSION    KARD(80)

      DATA    NERR /0/,   NEOF /0/

C--   ACTION REQUEST THRU  NCHKD=NCH

C-              OTHER  DELIVER NEXT CARD
C-                 -3  SKIP CURRENT CETA-SECTION
C-                 -4  SKIP TO NEXT FILE MARK ON CETA TAPE
C-                 -5  INITIALISE  FRCETA
C-                     MEASURE RECORD SIZE IF U-OPTION


C--   STATUS REPLY THRU  NCHKD

C-                +VE  LENGTH OF CARD DELIVERED
C-                 -2  END OF CETA-SECTION


      IF (NCH.LT.-2)         GO TO 71


C----------------  TRANSLATE 1 CARD  FROM  CETA  ------------------

      IF (IQ(LTAKE).EQ.0)    GO TO 51
   21 NCH = 0

C----              DO NEXT CHARACTER

   22 LTAKE = LTAKE + 1
      JCETA = IQ(LTAKE-1)
      IF (JCETA.EQ.0)        GO TO 37
      JCETU = IQ(LXREF+JCETA)
      IF (JCETU.GE.256)      GO TO 24
      NCH      = NCH + 1
      MWK(NCH) = IQ(LORGH+JCETU)
      GO TO 22

   24 IF (JCETA.EQ.62)       GO TO 33

C--                CETA C/CODE  ->  INTERNAL  UP UP X

   30 JCETU = MAX (JCETU-1000,0)
      IF (JCETU.EQ.0)        GO TO 35
      MWK(NCH+1) = IQ(LORGH+62)
      MWK(NCH+2) = IQ(LORGH+62)
      MWK(NCH+3) = IQ(LORGH+JCETU)
      NCH = NCH + 3
      GO TO 22

C--                CETA  UP UP X  ->  INTERNAL C/CODE

   33 JCETU = 62
      IF (IQ(LTAKE)  .NE.JCETA)  GO TO 35
      JCETA = IQ(LTAKE+1)
      JCETA = IQ(LXREF+JCETA+512)
      IF (JCETA.EQ.0)            GO TO 35
      LTAKE = LTAKE + 2
      JCETU = IQ(LXREF+JCETA)
      IF (JCETU.GE.256)          GO TO 30
   35 NCH      = NCH + 1
      MWK(NCH) = IQ(LORGH+JCETU)
      GO TO 22

C----              CARD COMPLETE

   37 NCARDP = NCARDP + 1
      NWKD   = 1
      IF (NCH.LT.KDNCHW)     GO TO 39
      IF (NCH.GE.150)        GO TO 62
      NWKD   = KDNWT
      IF (NCH.GE.77)         GO TO 39
      NWKD = (NCH-1)/4 + 1
      IF (NCH.NE. 4*NWKD)    GO TO 39

      NWKD     = NWKD + 1
      NCH      = NCH  + 1
      MWK(NCH) = IQBLAN

   39 CALL UBUNCH (MWK(1),KARD(1),NCH)
      IF (NWKD.EQ.KDNWT)     RETURN
      CALL SBYT (KDMARK,KARD(NWKD),KDPOST,KDBITS)
      RETURN


C------------      READING NEXT CETA RECORD  ------------------------

C--                READ ERROR

   42 NROLD = NROLD + 1
      NERR  = NERR  + 1
      WRITE (IQPRNT,9042) NROLD
      IF (NERR.LT.7)         GO TO 51
      GO TO 69

C--                EOF

   44 IF (NCH.EQ.-4)         GO TO 45
      NEOF = 7
      WRITE (IQPRNT,9044)
   45 IQ(LTAKE) = 0
      NCH = -2
      RETURN

   46 IF(NEOF.EQ.-1)         GO TO 59
      GO TO 45

C--                SPECIAL READING MODES

   47 IF   (NCH+4)           75,51,48
   48 IF (IQ(LREAD).EQ.0)    GO TO 45

C----              READ NEXT CETA RECORD

   51 IF (NEOF.NE.0)         GO TO 46

      LREAD  = LCETA + 3612 - NWCEU
      NWCEIN = NWCEU
      JREC   = NROLD + 1

      IF (MOPTIO(1).EQ.0)    GO TO 56
      READ (LUNOLD,REC=JREC,IOSTAT=ISTAT) (IQ(J+LREAD-1),J=1,NWCEIN)
      IF (ISTAT.EQ.0)        GO TO 58
      WRITE (IQPRNT,9054) ISTAT,ISTAT
 9054 FORMAT (1X/' ****** Stop for read error on d/a CETA file,'
     F /' ****** IOSTAT=',Z16,' hex = ',I12,' decimal')
      CALL PABEND
   56 CONTINUE
      CALL XINBF (LUNOLD,IQ(LREAD),NWCEIN)
      IF   (NWCEIN.EQ.0)          GO TO 44
      IF   (NWCEIN.LT.0)          GO TO 42

   58 NROLD = NROLD + 1
      NERR  = 0
      IF (NCH.LT.-2)         GO TO 47

C--                UNPACK CETA RECORD

   59 IF (NWCEIN.NE.NWCEU)   GO TO 61
      LTAKE = LCETA
      NEOF  = 0
      CALL UPKBYT (IQ(LREAD),1,IQ(LTAKE),NCHCEU,IPAKCE(1))
      IQ(LTAKE+NCHCEU)   = 0
      IQ(LTAKE+NCHCEU+1) = 0
      IF (IQ(LTAKE).NE.0)    GO TO 21
      NCH = -2
      RETURN

C----              CETA FORMAT TROUBLE

   61 WRITE (IQPRNT,9061) NWCEIN,NWCEU
 9061 FORMAT (1X/' *** CETA RECORD WITH',I5,' SHOULD HAVE',I5,' WORDS')
      GO TO 69

   62 WRITE (IQPRNT,9062) NCH
 9062 FORMAT (1X/' *** CETA LINE OF',I5,' CHARACTERS SEEN !')

   69 WRITE (IQPRNT,9069)
 9069 FORMAT (1X/' *** PROBABLY NOT A CETA TAPE.')
      CALL PABEND

C------------      SPECIAL MODE ENTRIES      ------------------------
C-                 NCH = -3  SKIP CURRENT CETA-SECTION
C-                       -4  SKIP TO NEXT FILE MARK ON CETA TAPE
C-                       -5  INITIALISE  FRCETA

   71 LTAKE = LCETA
      IQ(LTAKE) = 0
      IF (NCH.GE.-4)         GO TO 51

   75 CONTINUE
   99 RETURN

 9042 FORMAT (1X/1X,20(1H*),'   READ ERROR WITH CETA-RECORD',I6,
     F', RECORD SKIPPED.  VERY DANGEROUS  *******'/1X)
 9044 FORMAT (1X/1X,20(1H*),'   UNEXPECTED EOF.'/1X)
      END
