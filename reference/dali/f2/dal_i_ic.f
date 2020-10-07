*DK DIN
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DIN
CH
      SUBROUTINE DIN
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C!:
C    Inputs    :
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
*CA DALLCO
C     INCLUDE 'DALI_CF.INC'
C------------------------------------------------------------------- DO
      COMMON /DOPR1T/ TPLNDO(-2:11)
      COMMON /DOPR2T/ TAREDO( 0:14)
      COMMON /DOPR3T/ TZOODO( 0: 1)
      COMMON /DOPR4T/ TPICDO,THLPDO,TNAMDO
      CHARACTER *2 TPLNDO,TAREDO,TZOODO,TPICDO,THLPDO,TNAMDO
C------------------------------------------------------------------- DO
C     +++++++++++++++++++++++++ IWUSDO,IWARDO not used in ATLANTIS
      COMMON /DOPR1C/IMAXDO,IWUSDO,IWARDO,IAREDO,IPICDO,IZOMDO,IDU2DO(2)
      COMMON /DOPR2C/ PICNDO
C
C-------------------End of DALI_CF commons----------------
      EXTERNAL SIND,COSD,ACOSD,TAND,ATAND,ATAN2D! Not implemented in g77
      CHARACTER *2 TANSW
      CHARACTER *8 TIM
      LOGICAL FCHG
      CHARACTER *49 T1
C
C              123456789 123456789 123456789 123456789 123456789
      DATA T1/'P?:  Introduction'/
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
  930 CALL DTYPT('TYPE',TPICDO, 0    ,  0   ,  0   ,  ' ' ,T1)
  936 FCHG=.FALSE.
      CALL DGZOOM(6,IAREDO,0,0)
      CALL DOPER(1,1,
     &  1,0,' ',0,
     &  1,0,' ',0,
     &  NEXEC,FCHG,TANSW)
      GO TO (910,920,930,930),NEXEC
  910 RETURN
  920 CALL DO_STR('TI: time = ')
      IF(TANSW.EQ.'TI') THEN
        CALL TIME(TIM)
        CALL DWRT(TIM)
        GO TO 930
      END IF
      IF(TANSW.EQ.'X?') GO TO 930
      CALL DWR_IC(TANSW)
      GO TO 936
      END

*DK DQTIH
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++          DQTIH
CH
      SUBROUTINE DQTIH(TITLE,TCOM)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C
C    Created by C.Grab   5-Jul-1989  Original version
C    Updated by C.Grab  13-Sep-1989  Add trigger and detetor bits
C    Updated by C.Grab  26-Oct-1989  Add separate bit assignment for fields
C
C
C!:  Purpose : Extract information from various event banks and then
C              put it into the DALI display title area
C
C ---------------------------------------------------------------------
C     INCLUDE 'DALI_CF.INC'
C------------------------------------------------------------------- DU
      PARAMETER (MPNPDU=60)
      REAL DACUDU
      COMMON /DUSDAC/ NUNIDU,
     1 WAITDU,ECCHDU,BOXSDU,ECSQDU,HCSQDU,
     1 HIMXDU,RESCDU,SLOWDU,WISUDU,SETTDU,
     1 USLVDU,SYLRDU,SDATDU,RZDHDU,ROTADU,
     1 SCMMDU,CLMMDU,CUMMDU,WIMIDU,CCMIDU,
     1 ECMIDU,HCMIDU,SHTFDU(2)    ,FTDZDU,
     1 FRNLDU,DACUDU,SHECDU,SHHCDU,DRLIDU,
     1 SQLCDU,CHLCDU,HEADDU,VRDZDU,CHHCDU,
     1 AREADU,DFWIDU(0:1)  ,DFLGDU,PBUGDU,
     1 CHTFDU,RNCLDU,PR43DU,PR44DU,PR45DU,
     1 DSOFDU,TPOFDU,ROVDDU,ROECDU,ROHCDU,
     1 HSTRDU,REALDU,PR53DU,PR54DU,PR55DU,
     1 PR56DU(4),                  PR60DU
      DIMENSION PARADU(MPNPDU)
      EQUIVALENCE (PARADU,WAITDU)
      COMMON /DUSDA2/PLIMDU(2,MPNPDU)
      COMMON /DUSDAT/ TPR1DU(MPNPDU)
      CHARACTER *2 TPR1DU
C------------------------------------------------------------------- DE
C     ++++++++++++++++++++++++++++++ used in ATLANTIS , NRECDE not used here
      COMMON /DEVTIC/NFILDE,IRUNDE(2),IEVTDE(2),LNINDE(2),LCLSDE,NRECDE
      COMMON /DEVTIT/TFINDE(2)
      CHARACTER *80 TFINDE
C------------------------------------------------------------------- DA
      COMMON /DALEF1/ENFLDA
C
C-------------------End of DALI_CF commons----------------
      EXTERNAL SIND,COSD,ACOSD,TAND,ATAND,ATAN2D! Not implemented in g77
      DATA GECM/1./
      CHARACTER *106 TITLE,TCOM
      CHARACTER *3 DT3
      CHARACTER *4 DT4
      CHARACTER *5 DT5
      CHARACTER *6 DT6,T6
      CHARACTER *8 DQH8,T8
      LOGICAL BTEST
* jvw
*      common /jvw/itimeveh
* jvw
C
      DATA D0CUT,Z0CUT,NTPCO,ANGCUT/2.,10.,4,.95/
      PARAMETER (BFIELD=15.0,CLGHT=29.9792458)
C
      INCLUDE 'A_BCS.INC'
      INCLUDE 'A_DHEAJJ.INC'
      INCLUDE 'A_EVEHJJ.INC'
      INCLUDE 'A_FRFTJJ.INC'
      INCLUDE 'A_BMACRO.INC'
      DATA PZ/0./
C
C --------------------------------------------------------------------------
C ==>  First line:
C          1         2         3         4         5
C 12345678901234567890123456789012345678901234567890123456789
C DALI_A7     Ecm=12345 Ech=1234 Efl=1234 Ewi=1234 Eha=1234
C 1   2       3         4        5        6        7     <== bit assignment
C                                         1
C 6         7         8         9         0
C 0123456789O123456789012345678901234567890123456
C FILENAME 89-08-15 15:30 Run=1234567 Evt=1234567
C 8        9              10                             <== bit assignment
C
C --------------------------------------------------------------------------
C ==>  Second line:
C          1         2         3         4         5
C 12345678901234567890123456789012345678901234567890123456789
C             Nch=123   EV1=1234 EV2=1234 EV3=1234 ThT=1234
C 11          12        13                         16   <== bit assignment
C
C                                         1
C 6         7         8         9         0
C 0123456789O123456789012345678901234567890123456
C                    Trig=FFFFFFFF  DtHV=FFFFFFFF
C   Tbit1=FFFFFFFF  Tbit2=FFFFFFFF  Detb=FFFFFFFF
C   17              18              19<== bit assignment
C
C
C  -------------------------------------------------------------------------
      NUM = 0
      IF (IW(30).NE.12345) RETURN
C
C  Check the global flag for header-display:  FLAG = HEADDU
C  Bits (assignments shown above) set means do NOT display this item.
C  So flag=0 means display ALL.
C
      IFHED = INT(HEADDU)
C
C *** Get Filename, run and event number :
      IF (.NOT.BTEST(IFHED,8)) CALL DEVNAM(TITLE(60:67))
C      IF (.NOT.BTEST(IFHED,10)) THEN
C         TITLE(N84:N84+23)='Run='//DT8(FLOAT(IRUNDE(1)))
C     &               //'Evt='//DT8(FLOAT(IEVTDE(1)))
C      ENDIF
C
C ***   EVEH    ***        Event time and date
C
C Is the bank EVEH existing ?
 100  CONTINUE
      KEVEH=IW(NAMIND('EVEH'))
      IF (KEVEH.LE.0) GOTO 200
C
C -- Centre of mass energy:
C     XECM =  IW(KEVEH+13)/1000000.
C     IF (XECM.GT.10. .AND. XECM.LT.100.) THEN
C     IF (.NOT.(BTEST(IFHED,3))) TITLE(13:21)='ECM='//DT5(XECM)
C     ENDIF

      IF (.NOT.(BTEST(IFHED,3))) THEN
        XECM=GECM*ALELEP(IRUNDE(1))
        TITLE(13:21)='ECM='//DT5(XECM)
      END IF
C
C  --- Date and Time:
      IF (.NOT.(BTEST(IFHED,9))) THEN
         IDAT =  IW(KEVEH+JEVEDA)
         ITIM =  IW(KEVEH+JEVETI)
*         itimeveh=itim
         IF(IDAT.NE.0) THEN

C          T6 = DT6(FLOAT(IDAT))
           WRITE(T6,2001) IDAT
 2001      FORMAT(I6.6)

           TCOM(69:76) = T6(1:2)//'-'//T6(3:4)//'-'//T6(5:6)
         END IF
         IF(ITIM.NE.0) THEN
           WRITE(T8,1007) ITIM
 1007      FORMAT(I8)
C           TITLE(78:82) = T8(1:2)//':'//T8(3:4)
*           TCOM(78:88)=T8(1:2)//':'//T8(3:4)//':'//T8(5:6)//'.'//T8(7:8)
           TCOM(78:82)=T8(1:2)//':'//T8(3:4)
        END IF
      ENDIF
C
C
C
C ***   DHEA  : Event Topology variables :
C
C Is the bank DHEA existing ?
 200  CONTINUE
      KDHEA=IW(NAMIND('DHEA'))
      JDHEA = KDHEA + LMHLEN
      IF (KDHEA.EQ.0) GOTO 250
C REset everything if bank doesn not exist:
         XDHEC =  0.
         XDHEL =  0.
C        XDHEF =  0.
         XDHTH =  0.
         XDHPH =  0.
         XDHT1 =  0.
         XDHE1 =  0.
         XDHE2 =  0.
         XDHE3 =  0.
         XHADR =  0.
         IDHNT =  0
         IDHNN =  0
C
C  Total energy of charged tracks :
         XDHEC =  RTABL(KDHEA,1,JDHEEC)
C  Total energy of neutral cal. objects:
         XDHEL =  RTABL(KDHEA,1,JDHEEL)
C
C  Energy flow :
C        XDHEF =  RTABL(KDHEA,1,JDHEEF)

C  Energy flow direction  ( THETA, PHI) :
         XDHTH =  RTABL(KDHEA,1,JDHETH)
         XDHPH =  RTABL(KDHEA,1,JDHEPH)
C
C  Theta angle of thrust axis:
         XDHT1 =  RTABL(KDHEA,1,JDHET1)
CXX         XDHP1  =  RTABL(KDHEA,1,JDHEP1)   ! Phi of thrust axis
C  Eigenvalue for Thrust axis, major and minor axis :
         XDHE1 =  RTABL(KDHEA,1,JDHEE1)
         XDHE2 =  RTABL(KDHEA,1,JDHEE2)
         XDHE3 =  RTABL(KDHEA,1,JDHEE3)
C
C Now fill header values :
      IF (.NOT.(BTEST(IFHED,5))) TITLE(32:39)='Efl='//DT4(ENFLDA)
C  Presently combine all eigenvalues into one bit (but leave bits reserved)
      IF (.NOT.(BTEST(IFHED,13))) THEN
          TCOM(23:30)='EV1='//DT4(XDHE1)
          TCOM(32:39)='EV2='//DT4(XDHE2)
          TCOM(41:48)='EV3='//DT4(XDHE3)
      ENDIF
      IF (.NOT.(BTEST(IFHED,16))) TCOM(50:57)='ThT='//DT4(XDHT1)
C
 250   CONTINUE
C
C  ***  ECAL total wire energy :
C
      IF (.NOT.(BTEST(IFHED,6))) THEN
C  Calculation adapted from J.K.-Julia routine.
         KPEWI=IW(NAMIND('PEWI'))
         IF(KPEWI.LE.0) KPEWI=IW(NAMIND('PWEI'))
         EEWIRE=0.
         EWA=0.
         EWB=0.
         EWBA=0.
         IF(KPEWI.NE.0)THEN
             IF(IW(KPEWI).GT.2)THEN
                 NMOD=IW(KPEWI+LMHROW)
                 DO 284 I=1,NMOD
                 DO 283 M=1,45
                 MODU=ITABL(KPEWI,I,1)
                 E=ITABL(KPEWI,I,1+M)/1000000.
                 EEWIRE=EEWIRE+E
                 IF(MODU.LT.13)EWA=EWA+E
                 IF(MODU.GT.24)EWB=EWB+E
                 IF(MODU.GT.12.AND.MODU.LT.25)EWBA=EWBA+E
  283            CONTINUE
  284            CONTINUE
             ENDIF
         ENDIF
         TITLE(41:48)='Ewi='//DT4(EEWIRE)
      ENDIF
C
C
C  ***  HCAL total TOWER energy :
C
      IF (.NOT.(BTEST(IFHED,7))) THEN
           CALL DVPHCO( XHADR,ESWIR)
           TITLE(50:57)='Eha='//DT4(XHADR)
      ENDIF
C
C
C  ***  Charged tracks : number of good ones and momentum:
C
C Do calc. only if either of the values should be displayed
      IF (BTEST(IFHED,4).AND.BTEST(IFHED,12)) GOTO 290
      XPCHG = 0.
      NUMTR = 0
      NGOOD = 0
      JFRFT=IW(NAMIND('FRFT'))
      JPFRT=IW(NAMIND('PFRT'))
      IF (JFRFT.EQ.0) GOTO 290
      NUMTR = LROWS(JFRFT)
C
      DO 285 N=1,NUMTR
         AIR = -RTABL(JFRFT,N,JFRFIR)
         TL = RTABL(JFRFT,N,JFRFTL)
         RHO = 1./ABS(AIR)
         PT = BFIELD*RHO*CLGHT/100000.
         THETA = ATAN2(1.,TL)
         STHET = SIN(THETA)
         PTOT = PT/STHET
C
         D0 = ABS(RTABL(JFRFT,N,JFRFD0))
         Z0 = ABS(RTABL(JFRFT,N,JFRFZ0))
C
C     Add cut on number of TPC hits:
         IF (JPFRT.EQ.0) THEN
            NH = 0
         ELSE
            NH = ITABL(JPFRT,N,4)
         ENDIF
         IF(NH.LT.NTPCO) GOTO 285
C
         IF (D0.GT.D0CUT.OR.Z0.GT.Z0CUT)GOTO 285
         IF (PTOT.EQ.0 .OR. ABS(PZ/PTOT).GT.ANGCUT)GOTO 285
            NGOOD = NGOOD +1
            XPCHG = XPCHG + PTOT
 285  CONTINUE
      IF (.NOT.(BTEST(IFHED,4)))  TITLE(23:30)='Pch='//DT4(XPCHG)
      IF (.NOT.(BTEST(IFHED,12))) TCOM(13:19)='Nch='//DT3(FLOAT(NGOOD))
 290  CONTINUE

C
C ***   XTEB    ***        Trigger bits
C
 300  CONTINUE
      IF (.NOT.(BTEST(IFHED,18))) THEN
         KXTEB=IW(NAMIND('XTEB'))
         JXTEB= KXTEB + LMHLEN
         IF(KXTEB.NE.0) THEN
            ITRB1 = IW(JXTEB+1)
            ITRB2 = IW(JXTEB+2)
            ITRB3 = IW(JXTEB+3)
            TCOM(79:91)='Trig='//DQH8(ITRB3)
CC           TCOM(62:75)='Tbit1='//DQH8(ITRB1)
CC           TCOM(78:91)='Tbit2='//DQH8(ITRB2)
         ENDIF
      ENDIF
C
C
C ***   REVH   ***        Detector ON/OFF -HV bits
C
 400  CONTINUE
      IF (.NOT.(BTEST(IFHED,19))) THEN
         KREVH=IW(NAMIND('REVH'))
         JREVH= KREVH + LMHLEN
         IF(KREVH.EQ.0) NUM=0
         IDTB1 = IW(JREVH+1)
         TCOM(94:106)='Detb='//DQH8(IDTB1)
      ENDIF
C
 500  CONTINUE
 999  CONTINUE
      RETURN
      END
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      CHARACTER *(*) FUNCTION DQH8(IN)
C
C     Created by C.Grab    14-Sep-1989
C
C     Convert integer numbers into <=32 bits hexadec. character strings
C     Use internal file I/O :
C     AS:   string = dth8( ivar )
C
C ---------------------------------------------------------------------
      CHARACTER *8 DTT
      DTT = '00000000'
      WRITE(DTT,1010) IN
      DQH8 = DTT
 1010 FORMAT(Z8)
      RETURN
      END
*DK DQ_HEADER
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ DQ_HEADER
CH
      SUBROUTINE DQ_HEADER
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C
C     INCLUDE 'DALI_CF.INC'
C------------------------------------------------------------------- DB
      PARAMETER (MBNCDB=27)
      COMMON /DBOS1C/ BNUMDB(4,MBNCDB)
      COMMON /DBOS2C/ NUMBDB,FVERDB,FKINDB,ITCODB,TPADDB,TBCODB,
     &                       TPCODB,ESDADB,HSDADB,HTUBDB,MHITDB,
     &                       FRFTDB,FRTLDB,FTCLDB,FICLDB,PYERDB,
     &                       FRIDDB,PLSDDB,PECODB,PEWDDB,RECODB,
     &                       VDZTDB,VDXYDB,CRFTDB,NRFTDB,VDCODB,
     &                       VCPLDB,YKNVDB
      INTEGER         NUMBDB,FVERDB,FKINDB,ITCODB,TPADDB,TBCODB,
     &                       TPCODB,ESDADB,HSDADB,HTUBDB,MHITDB,
     &                       FRFTDB,FRTLDB,FTCLDB,FICLDB,PYERDB,
     &                       FRIDDB,PLSDDB,PECODB,PEWDDB,RECODB,
     &                       VDZTDB,VDXYDB,CRFTDB,NRFTDB,VDCODB,
     &                       VCPLDB,YKNVDB
      COMMON /DBOS3C/ IFULDB
C
C-------------------End of DALI_CF commons----------------
      EXTERNAL SIND,COSD,ACOSD,TAND,ATAND,ATAN2D! Not implemented in g77
      CALL DQTIT(IFULDB)
      END

*DK DQTIT
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DQTIT
CH
      SUBROUTINE DQTIT(IFULL)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
C
C    Created by H.Drevermann                   28-JUL-1988
C    Updated by C.Grab                         18-Aug-1989
C
C!:
C ---------------------------------------------------------------------
*CA DALLCO
C     TITLE
C     INCLUDE 'DALI_CF.INC'
C------------------------------------------------------------------- DG
      COMMON /DGRDEC/
     1      HMINDG(0:14),VMINDG(0:14),
     1      HLOWDG(0:14),VLOWDG(0:14),HHGHDG(0:14),VHGHDG(0:14)
      COMMON /DGRDET/ TGRADG
      CHARACTER *3 TGRADG
C------------------------------------------------------------------- DU
      PARAMETER (MPNPDU=60)
      REAL DACUDU
      COMMON /DUSDAC/ NUNIDU,
     1 WAITDU,ECCHDU,BOXSDU,ECSQDU,HCSQDU,
     1 HIMXDU,RESCDU,SLOWDU,WISUDU,SETTDU,
     1 USLVDU,SYLRDU,SDATDU,RZDHDU,ROTADU,
     1 SCMMDU,CLMMDU,CUMMDU,WIMIDU,CCMIDU,
     1 ECMIDU,HCMIDU,SHTFDU(2)    ,FTDZDU,
     1 FRNLDU,DACUDU,SHECDU,SHHCDU,DRLIDU,
     1 SQLCDU,CHLCDU,HEADDU,VRDZDU,CHHCDU,
     1 AREADU,DFWIDU(0:1)  ,DFLGDU,PBUGDU,
     1 CHTFDU,RNCLDU,PR43DU,PR44DU,PR45DU,
     1 DSOFDU,TPOFDU,ROVDDU,ROECDU,ROHCDU,
     1 HSTRDU,REALDU,PR53DU,PR54DU,PR55DU,
     1 PR56DU(4),                  PR60DU
      DIMENSION PARADU(MPNPDU)
      EQUIVALENCE (PARADU,WAITDU)
      COMMON /DUSDA2/PLIMDU(2,MPNPDU)
      COMMON /DUSDAT/ TPR1DU(MPNPDU)
      CHARACTER *2 TPR1DU
C------------------------------------------------------------------  DC
C     HARD WIRED IN P_DALB_ALEPH.FOR           !!!
C     ++++++++++++++++++++++++++ *12 TFILDC
      COMMON /DCFTVT/ TFILDC,TITLDC,TDEFDC,TNAMDC
      CHARACTER  *8 TFILDC
      CHARACTER *10 TITLDC
      CHARACTER  *3 TDEFDC
      CHARACTER  *4 TNAMDC
C------------------------------------------------------------------- DD
      PARAMETER (MPNPDD=154)
      COMMON /DDECO1/
     &  MXSADD,MXLUDD,MXVDDD,MXITDD,MXTPDD,ICLVDD,ICBPDD,
     &  ICSADD,ICLUDD,ICVDDD,ICITDD,ICTPDD,ICECDD,ICMADD,
     &  ICHCDD,ICM1DD,ICM2DD,ICBWDD,ICBGDD,ICBADD,ICCNDD,
     &  MODEDD,NUPODD,ISTYDD,LIDTDD,LITRDD,LIGLDD,ISTHDD,
     &  ICFRDD,ICTXDD,ICALDD,ICHDDD,LCBWDD,ICRZDD,ICLFDD,
     &  ICVXDD,LCDUDD,LCVDDD,LCV1DD,LCITDD,LCIUDD,LCNBDD,
     &  LCNCDD,LCNIDD,LCSHDD,LCSLDD,LCSADD,LCSRDD,LCSSDD,
     &  LCSDDD,LCTPDD,LCTBDD,LCTCDD,LCTFDU,LCTUDD,LCTRDD,
     &  LCTWDD,LCLGDD,LCLCDD,LCLHDD,LCLKDD(1:3)         ,
     &  LCEODD,LCEGDD,LCECDD,LCELDD,LCEKDD(1:3)         ,
     &  LCESDD,LCWEDD(3)           ,LCEFDD,LCMUDD(2)    ,
     &  LCHGDD,LCHCDD,LCHLDD,LCHTDD(4)                  ,
     &  NCOLDD(8)                  ,LDUMDD(5)    ,MOLTDD,
     &  JSTRDD,JSSADD,JSVDDD,JSITDD,JSTPDD,JSLCDD,JSECDD,
     &  JSEODD,JSHCDD,JSD1DD(5)                         ,
     &  JSD2DD(4)                  ,KCBPDD,KCSADD,KCLUDD,
     &  KCVDDD,KCITDD,KCTPDD,KCECDD,KCMADD,KCHCDD,KCM1DD,
     &  KCM2DD,KCLGDD,K129DD,KSDBDD,KSAIDD,KSAODD,KSLBDD,
     &  K134DD(6),                                K140DD,
     &  NFVHDD,NFVCDD,NFVEDD,NFITDD,NFTPDD,NFECDD,NFHTDD,
     &  N148DD,NFTRDD,N150DD,N151DD,N152DD,N153DD,N154DD
      COMMON /DDECO2/ PDCODD(4,MPNPDD)
      COMMON /DDECO3/ DLINDD
      COMMON /DDECOT/ TDCODD(MPNPDD)
      CHARACTER *2 TDCODD
C------------------------------------------------------------------- DW
      PARAMETER (MPOSDW=30,MPNWDW=12,MNUWDW=14)
      COMMON /DWINDC/NWINDW(0:MPNWDW,0:MPNWDW),
     &  NEXTDW(0:MPNWDW),LASTDW(0:MPNWDW),
     &  POSIDW(MPOSDW)
      COMMON /DWINDO/TWINDW(0:MNUWDW)
      CHARACTER *1 TWINDW
C------------------------------------------------------------------- DE
C     ++++++++++++++++++++++++++++++ used in ATLANTIS , NRECDE not used here
      COMMON /DEVTIC/NFILDE,IRUNDE(2),IEVTDE(2),LNINDE(2),LCLSDE,NRECDE
      COMMON /DEVTIT/TFINDE(2)
      CHARACTER *80 TFINDE
C
C-------------------End of DALI_CF commons----------------
      EXTERNAL SIND,COSD,ACOSD,TAND,ATAND,ATAN2D! Not implemented in g77
      CHARACTER *(*) TIN
      CHARACTER *8 DT8
      CHARACTER *6 DT6
      DATA N23/23/
      CHARACTER *106 TITLE,TCOM
      CHARACTER *24 TRUN
C                123456789 123456789 1234
      DATA TRUN/'Run=12345678Evt=123456  '/
      DATA PRUN/193./
      LOGICAL BTEST
C     DATA POSTI/130./,HPOSA/40./,VPOSA/2./
      DATA POSTI/122./,HPOSA/40./,VPOSA/2./
C
C  -------------------------------------------------------------------------
      IF(VHGHDG(13).EQ.0.) RETURN
      IFHED = INT(HEADDU)
      TITLE=' '
      TCOM=' '
      IF (.NOT.BTEST(IFHED,1)) TITLE(1:4)=TFILDC(1:4)
      IF (.NOT.BTEST(IFHED,2)) TITLE(5:7)=TFILDC(5:7)
      IF(IFULL.EQ.1) THEN
         CALL DQTIH(TITLE,TCOM)
         CALL DWRT_SETUP('TERMINAL=OFF')
         CALL DWRT(TITLE(60:106))
         CALL DWRT_SETUP('TERMINAL=LAST')
      END IF
      MM=1
      GO TO 10
CH..............---
CH
CH
CH
CH
CH
CH
CH --------------------------------------------------------------------  DQTIC
CH
      ENTRY DQTIC(ILET,TIN)
CH
CH --------------------------------------------------------------------
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C!:
C    Inputs    :
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
C     TITLE + COMMENT
C Only allowed if flag set OFF for other quantities
      IFHED = INT(HEADDU)
      IF (IFHED.EQ.0) THEN
         TCOM=' '
         TCOM(1:ILET)=TIN(1:ILET)
         MM=ILET
      ENDIF
CH..............---
CH
CH
CH
CH
CH
CH
CH --------------------------------------------------------------------  DQTIN
CH
      ENTRY DQTIN
CH
CH --------------------------------------------------------------------
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C!:
C    Inputs    :
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
C     TITLE + COM. NEW
      IF(VHGHDG(13).EQ.0.) RETURN
   10 CALL DQCL(13)
      CALL DQLEVL(ICHDDD)
      HCMT=0.5
      IF(HHGHDG(13).LE.HHGHDG(12)) THEN
        LHD=76
      ELSE
        LHD=106
      END IF
      CALL DGTEXT(HMINDG(13)+POSTI,VMINDG(13)+POSIDW(13),TITLE,LHD)
      CALL DGTEXT(HMINDG(13)+POSTI,VMINDG(13)+POSIDW(12),TCOM, LHD)
      IFHED = INT(HEADDU)
      IF (.NOT.BTEST(IFHED,10)) THEN
        TRUN( 5:12)=DT8(FLOAT(IRUNDE(1)))
        TRUN(17:N23-1)=DT6(FLOAT(IEVTDE(1)))
        CALL DJAUNM(TRUN(N23:N23))
        CALL DGTEXT(HHGHDG(13)-PRUN,VMINDG(13)+POSIDW(13),TRUN,24)
      END IF
      IF(PDCODD(4,ICALDD).GE.0.) THEN
        HA=HMINDG(13)+VHGHDG(13)-VMINDG(13)
        CALL DGFISH(0)
        CALL DGALEF(IFIX(PDCODD(2,ICALDD)),
     &    HMINDG(13),VMINDG(13),HA,VHGHDG(13))
        CALL DGFISH(2)
      END IF
      CALL DGALPH(IFIX(PDCODD(2,ICHDDD)),
     &  HMINDG(13)+HPOSA,VMINDG(13)+VPOSA)
CBSN     &  HMINDG(13)+HPOSA,VHGHDG(13)-VPOSA)
      CALL DQFR(13)
      END
C
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
      SUBROUTINE DVPHCO ( ESUMH , ESWIR)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C
C    Created by C.Grab  27-Sep-1989  Original version,
C                                    (consulted by M.N.Minard)
C    A few mistakes corrected by D. Schlatter (B.S. Nilsson) on 28-Jan-1993
C
C
C!:  Purpose : Calculate total HCAL energy for all towers that correspond
C              to reasonable wire values.
C
      INCLUDE 'A_BCS.INC'
      INCLUDE 'A_PCRLJJ.INC'
      INCLUDE 'A_PHCOJJ.INC'
      INCLUDE 'A_PPOBJJ.INC'
      INCLUDE 'A_BMACRO.INC'
      ESUMH = 0.
      KPCRL = IW (NAMIND('PCRL'))
      NPCRL = 0
      IF (KPCRL.NE.0)NPCRL = LROWS(KPCRL)
      NAPPOB = NAMIND ('PPOB')
      KPPOB = IW (NAPPOB)
      NPPOB = 0
      IF (KPPOB.NE.0) NPPOB = LROWS (KPPOB)
      NAPHCO = NAMIND ('PHCO')
      KPHCO = IW ( NAPHCO)
      NPHCO = 0
      ESWIR = 0.
      IF ( KPHCO.NE.0 ) NPHCO = LROWS ( KPHCO)
      IF ( NPHCO.EQ.0) GO TO 900
C
      DO 10 IPHCO = 1,NPHCO
         ESWI = 0.
C
         DO 15 IPCRL = 1, NPCRL
            IF ( ITABL(KPCRL,IPCRL,JPCRPH).EQ.IPHCO) THEN
               IPPOB = ITABL(KPCRL,IPCRL,JPCRPP)
               IF ( IPPOB.NE.0 ) ESWI = ESWI + RTABL(KPPOB,IPPOB,JPPODE)
            ENDIF
 15      CONTINUE
C
         IF ( ESWI.EQ.0) GO TO 10
         ESWIR = ESWI + ESWIR
         ESUMH = ESUMH + RTABL ( KPHCO,IPHCO,JPHCEC )
 10   CONTINUE
 900  CONTINUE
      RETURN
      END
