C     DAL_X.FOR
C     =========
C
C     V1A  2.May 89   C.Grab
C     V1B  8.MAY 89   CHG      Added DALI_MU.INC with the IMPLICITs removed
C
C
C     Block data statments for the DALI-batch mode files, that are to
C     be run on the IBM.
C
C -------------------------------------------------------------------
C     Here are all the commons :
      BLOCK DATA DALBX
C     INCLUDE 'DALI_CF.INC'
C------------------------------------------------------------------- DA
      PARAMETER (MLINDA=199,MCALDA=-99,MTOTDA=299,MLSTDA=9)
      COMMON /DALCA1/
     &  IALPDA(MCALDA:MLINDA),
     &  ILSTDA(MCALDA:MLINDA),
     &  FSELDA(MCALDA:MLINDA)
      LOGICAL FSELDA
      COMMON /DALCA2/TNAMDA(MCALDA:-1),TLSTDA(0:MLSTDA)
      CHARACTER *2 TLSTDA
      CHARACTER *5 TNAMDA
      COMMON /DALCA3/NCALDA,NLINDA,FMISDA
      LOGICAL FMISDA
      COMMON /DALCA4/IOCODA(0:MLSTDA)
      COMMON /DALCA5/ICORDA(MTOTDA,MCALDA:-1),NCORDA(MCALDA:-1)
      COMMON /DALCA6/TCORDA(MTOTDA,MCALDA:-1)
      CHARACTER *2 TCORDA
      COMMON /DALCA7/NFSTDA(MLSTDA),NLSTDA(MLSTDA)
C     0 = working list, 1 to 9 = alpha lists
      COMMON /DALCA8/FIRODA,TERODA
C------------------------------------------------------------------- DF
      COMMON /DFNEWF/ FNOFDF
      LOGICAL FNOFDF
C------------------------------------------------------------------- DP
      COMMON /DPERSC/ FRPRDP,FBUGDP,FFDRDP
      LOGICAL FRPRDP,FBUGDP,FFDRDP
C------------------------------------------------------------------- D0
      COMMON /D0PLAF/ TPLFD0,TWRTD0
      CHARACTER *6 TPLFD0
      CHARACTER *1 TWRTD0
      COMMON /D0PFLG/ FTRMD0,FLOGD0,FPROD0,FSOLD0
      LOGICAL FTRMD0,FLOGD0,FPROD0,FSOLD0
C------------------------------------------------------------------- DB
      COMMON /DBOSUN/ LUNEDB
C------------------------------------------------------------------- DP
      PARAMETER (MAXPDP=120,M11PDP=131)
      COMMON /DPICT/ TPICDP(-10:MAXPDP)
      CHARACTER *2 TPICDP
C------------------------------------------------------------------- DF
      COMMON /DFARBE/ TCOLDF(0:31)
      CHARACTER *2 TCOLDF
C------------------------------------------------------------------- DR
      COMMON /DRNG1C/
     &  FNOPDR,FVDEDR,FITCDR,FTPCDR,FECADR,FHCADR,FMDEDR
      LOGICAL
     &  FNOPDR,FVDEDR,FITCDR,FTPCDR,FECADR,FHCADR,FMDEDR
      COMMON /DRNG2C/DET1DR(6),DET2DR(6)
C------------------------------------------------------------------  DC
C     HARD WIRED IN P_DALB_ALEPH.FOR           !!!
C     ++++++++++++++++++++++++++ *12 TFILDC
      COMMON /DCFTVT/ TFILDC,TITLDC,TDEFDC,TNAMDC
      CHARACTER  *8 TFILDC
      CHARACTER *10 TITLDC
      CHARACTER  *3 TDEFDC
      CHARACTER  *4 TNAMDC
C------------------------------------------------------------------- D0
      COMMON /D0STRT/ TISTD0
      CHARACTER *20 TISTD0
C------------------------------------------------------------------- DO
C     +++++++++++++++++++++++++ IWUSDO,IWARDO not used in ATLANTIS
      COMMON /DOPR1C/IMAXDO,IWUSDO,IWARDO,IAREDO,IPICDO,IZOMDO,IDU2DO(2)
      COMMON /DOPR2C/ PICNDO
C------------------------------------------------------------------- DW
      COMMON /DWUSED/  JWUSDW
C------------------------------------------------------------------- DB
      COMMON /DBTROE/ FLEYDB
      LOGICAL FLEYDB
C------------------------------------------------------------------- DO
      COMMON /DOPR1T/ TPLNDO(-2:11)
      COMMON /DOPR2T/ TAREDO( 0:14)
      COMMON /DOPR3T/ TZOODO( 0: 1)
      COMMON /DOPR4T/ TPICDO,THLPDO,TNAMDO
      CHARACTER *2 TPLNDO,TAREDO,TZOODO,TPICDO,THLPDO,TNAMDO
C------------------------------------------------------------------- DE
      COMMON /DECAEN/ FECEDE,ENECDE(7)
      LOGICAL FECEDE
C------------------------------------------------------------------- DE
C     ++++++++++++++++++++++++++++++ used in ATLANTIS , NRECDE not used here
      COMMON /DEVTIC/NFILDE,IRUNDE(2),IEVTDE(2),LNINDE(2),LCLSDE,NRECDE
      COMMON /DEVTIT/TFINDE(2)
      CHARACTER *80 TFINDE
C------------------------------------------------------------------- DH
      COMMON /DHELPT/ TAN1DH,TPRGDH,TLT3DH
      CHARACTER *1 TPRGDH,TLT3DH
      CHARACTER *3 TAN1DH
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
C------------------------------------------------------------------- DI
      COMMON /DINPUC/ IFILDI,IEVEDI,ZOFFDI,
     1 KVDEDI,KITCDI,KTPCDI,KECADI,KHCADI,KMDEDI
C------------------------------------------------------------------- DV
      COMMON /DVARIC/
     1      IVXXDV,IVYYDV,IVZZDV,IVRODV,IVFIDV,IVTEDV,IVDIDV,IVRBDV,
     1      IVLVDV,IVDFDV,IVDTDV,IVENDV,IVIIDV,IVJJDV,IVKKDV,IVNNDV,
     1      IVLLDV,IVNTDV,IVU1DV,IVU2DV
C------------------------------------------------------------------- DK
      COMMON /DKNSTC/ PIFCDK,RMAXDK,ZMAXDK,TCO1DK,TCO2DK,
     1   ROTODK(-1:10),ZZTODK(-1:10),ZMTODK(-1:10),DMAXDK,RMINDK,
     1   RLOWDK
C------------------------------------------------------------------- DK
      COMMON /DKONST/ PIDGDK
      DOUBLE PRECISION PIDGDK
C------------------------------------------------------------------- DV
      COMMON /DVARIT/ TVRNDV(0:20)
      CHARACTER *2 TVRNDV
C------------------------------------------------------------------- DK
      COMMON /DKNEWC/ KNECDK(45:52,3,4:5)
C------------------------------------------------------------------- DW
      PARAMETER (MPOSDW=30,MPNWDW=12,MNUWDW=14)
      COMMON /DWINDC/NWINDW(0:MPNWDW,0:MPNWDW),
     &  NEXTDW(0:MPNWDW),LASTDW(0:MPNWDW),
     &  POSIDW(MPOSDW)
      COMMON /DWINDO/TWINDW(0:MNUWDW)
      CHARACTER *1 TWINDW
C------------------------------------------------------------------- DT
      COMMON /DTVCCC/ DUMYDT(4),
     1         HUMIDT,HUMADT,VUMIDT,VUMADT,
     1         NSQUDT,NOBJDT,NOCLDT,HPOSDT,VPOSDT,
     1         FPOSDT,TPOSDT,AROTDT,RPOSDT,NTVIDT,
     1         FPRIDT,FRETDT,FBLWDT,FMONDT,F256DT,
     1         FX11DT
      LOGICAL  FPRIDT,FRETDT,FBLWDT,FMONDT,F256DT,FX11DT
C------------------------------------------------------------------- DT
      COMMON /DTESCT/ TREVDT,TULIDT,TNORDT
      CHARACTER *4 TREVDT,TNORDT
      CHARACTER *8 TULIDT
C------------------------------------------------------------------- DD
      COMMON /DDEFCO/ RDCODD(0:127),GRCODD(0:127),BLCODD(0:127),
     &  LTABDD(0:127)
      COMMON /DDEFCD/ RDCDDD(0:127),GRCDDD(0:127),BLCDDD(0:127)
      COMMON /DDEFCP/ RDCPDD(0:127),GRCPDD(0:127),BLCPDD(0:127)
      COMMON /DDEFCF/ FPCODD
      LOGICAL FPCODD
      COMMON /DDEFCN/ NUMCDD
C------------------------------------------------------------------- DP
      COMMON /DPICKC/ FPIKDP,FPIMDP,DPIKDP,HPIKDP,VPIKDP,
     1                              HHPKDP,VVPKDP,EVARDP(20,3),
     1 KPIKDP,NPIKDP,MDLRDP,MDLPDP,FKTRDP,FNTRDP,KSUPDP,NSUPDP
C     +++++++++++++++++++ FTRKDP,IOTRDP used in ATLANTIS
      COMMON /DPICK1/ IPTNDP,FTRKDP,IOTRDP
      LOGICAL FPIKDP,FPIMDP,FTRKDP
C------------------------------------------------------------------- DO
      COMMON /DOPR4C/ NOARDO,
     1  NTF1DO,NSP1DO,IRZ1DO,IHTRDO(8)
      COMMON /DOPR5C/ FGETDO
      LOGICAL FGETDO
C------------------------------------------------------------------- DF
      PARAMETER (MCOLDF=10)
      COMMON /DFTCLC/ COLIDF(4,MCOLDF),COLMDF(4,3)
C------------------------------------------------------------------- DL
      PARAMETER (MPNPDL=62,MPDVDL=6,MPWDDL=8,MPRADL=8)
      COMMON /DLUTSC/MNUMDL,MVDEDL,MITCDL,MTPCDL,MECADL,MHCADL,MMDEDL,
     1  MGRCDL(MPDVDL),MVARDL(MPDVDL,2),MODEDL(MPDVDL,2),
     1  MCOLDL(MPDVDL),MSYMDL(MPDVDL,0:1),
     1  MLABDL(MPDVDL),MDUMDL,
     1  WDSNDL(4,MPWDDL,MPDVDL),RAMPDL(4,MPRADL,MPDVDL,2)
C     COMMON /DLUTSC/MNUMDL,MVDEDL,MITCDL,MTPCDL,MECADL,MHCADL,MMDEDL,
C    1  MGRCDL(MPDVDL),
C    1  MCOLDL(MPDVDL),
C    1  MLABDL(MPDVDL),MDUMDL
C------------------------------------------------------------------- DT
      PARAMETER (MTRKDT=401,MMCTDT=500)
      COMMON /DTRK1C/ FCUTDT,FNOTDT(   0   :MTRKDT),
     &                FCUHDT,FNOHDT(-MTRKDT:MTRKDT)
      LOGICAL FCUTDT,FNOTDT,FCUHDT,FNOHDT
      COMMON /DTRK2C/ VTX1DT(3),VTX2DT(3),PTRADT(3),CLTMDT(3),FVTXDT
      LOGICAL FVTXDT
      COMMON /DTRK6C/ FRFTDT(6),XYZVDT(3)
      COMMON /DTRK7C/ N3DIDT,FZTRDT,NSVXDT,KINVDT(2,MTRKDT)
      LOGICAL FZTRDT
      COMMON /DTRK3C/ MODEDT,TPHEDT(5)
      COMMON /DTRK4C/ FMCCDT,FMNTDT(MMCTDT),FMVXDT(100)
      LOGICAL FMCCDT,FMNTDT,FMVXDT
      COMMON /DTRK5C/ SZVXDT,NCVXDT
      COMMON /DTRK1T/ TGFTDT,TGTLDT,TGCLDT
      CHARACTER *4 TGFTDT,TGTLDT,TGCLDT
C PARAMETER (MTRKDT=100,MMCTDT=500) is found in:
C C_DALBC.FOR,C_DALBD.FOR,C_DALBH.FOR,C_DALBM.FOR,C_DALBR.FOR,C_DALBT.FOR
C C_DALBV.FOR,C_DALBX.FOR,C_DALBY.FOR,C_DALIA.FOR,C_DALID.FOR,C_DALIR.FOR
C C_DALIS.FOR,C_DALIV.FOR,N_DALBA.FOR,N_DALBF.FOR,US3.FOR
C------------------------------------------------------------------- DR
      COMMON /DRESIC/ NPNTDR,FGRYDR,PARADR(4,3)
      LOGICAL FGRYDR
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
C------------------------------------------------------------------- DQ
      COMMON /DQQQ1C/ AHSCDQ,BHSCDQ,CHSCDQ,AVSCDQ,BVSCDQ,CVSCDQ
      COMMON /DQQQ2C/ DMAXDQ
      COMMON /DQQQ3C/ FPRSDQ,FPSQDQ
      LOGICAL FPRSDQ,FPSQDQ
      COMMON /DQQQ4C/ PRSHDQ,PRSVDQ,PRS1DQ,PRS2DQ,PRV1DQ
      COMMON /DQQQ5C/ HUSRDQ(4,0:12),VUSRDQ(4,0:12)
C------------------------------------------------------------------- DG
      COMMON /DGRDEC/
     1      HMINDG(0:14),VMINDG(0:14),
     1      HLOWDG(0:14),VLOWDG(0:14),HHGHDG(0:14),VHGHDG(0:14)
      COMMON /DGRDET/ TGRADG
      CHARACTER *3 TGRADG
C------------------------------------------------------------------- DM
      COMMON /DMACRC/ FMACDM,NLETDM,FMOPDM,FMINDM,FANIDM,FNTADM,
     &  FINMDM
      LOGICAL FMACDM,FMOPDM,FMINDM,FANIDM,FNTADM,FINMDM
C
C-------------------End of DALI_CF commons----------------
      INCLUDE 'DALI_MU.INC'
C -------------------------------------------------------------------
      DATA ILSTDA/MTOTDA*0/
      DATA TLSTDA/'US','CH','IS','AS','V0','EF','NE','GA','JE','MC'/
C -------------------------------------------------------------------
C     DATA FEXADL/.FALSE./
      DATA FNOFDF/.TRUE./
      DATA FFDRDP/.FALSE./
      DATA TWRTD0/'0'/
      DATA LUNEDB/100/
      DATA TPICDP/M11PDP*'  '/
C_CG
C_CG    --- Data statements OF routine  DDRFLG     ---
C_CG
      DATA TCOLDF/'BG','BL','TP','IT','EC','HC','HH','GY',
     &            'WH','GN','YE','BR','RD','MA','CY','BL',
     &            16 * 'bw'/
      DATA DET1DR/ 1.,  3.,  5.,  9., 13., 16./
      DATA DET2DR/ 2.,  4.,  8., 12., 15., 18./
C_CG
C_CG    --- Data statements OF routine  DDATIN     ---
C_CG
C     change version in MMX.1, MMX.COM, LOGIN.COM
      DATA TFILDC/'DALI_F2.'/,TISTD0/' '/,TNAMDC/'DALI'/
      DATA IWUSDO/0/,IWARDO/-1/,JWUSDW/0/
      DATA FLEYDB/.FALSE./
      DATA FPROD0/.TRUE./,FTRMD0/.TRUE./,FLOGD0/.TRUE./
      DATA TAREDO(13)/'WH'/
      DATA TAREDO(14)/'WC'/
      DATA FECEDE/.FALSE./
      DATA TFINDE /' ',' '/
      DATA TAN1DH/'   '/
      DATA NUNIDU/54/
      DATA TPR1DU/MPNPDU*' '/
      DATA KVDEDI/1/,KITCDI/2/,KTPCDI/3/,KECADI/4/,KHCADI/7/,KMDEDI/9/
      DATA  IVXXDV,IVYYDV,IVZZDV,IVRODV,IVFIDV,IVTEDV,IVDIDV
     1  /      1,     2,     3,     4,     5,     6,     7/
      DATA  IVRBDV,IVLVDV,IVDFDV,IVDTDV
     1  /      8,     9,     10,    11/
      DATA  IVENDV,IVIIDV,IVJJDV,IVKKDV,IVNNDV,IVLLDV
     1  /      12,    13,    14,    15,    16,    17/
      DATA  IVNTDV,IVU1DV,IVU2DV
     1  /      18,    19,    20/
      DATA PIFCDK/57.29577951/
      DATA PIDGDK/57.29577951/
      DATA RMAXDK,ZMAXDK/170.622,217./,RMINDK/31.64/,RLOWDK/5./
      DATA ROTODK/0.,11.,
     1  30., 95.,148.,180.,200.,220.,240.,382.,480.,595./
      DATA ZZTODK/0.,0.,
     1  30., 95.,160.,225.,265.,285.,310.,425.,500.,610./
      DATA ZMTODK/0.,0.,
     1  225.,225.,225.,225.,265.,285.,310.,425.,500.,610./
      DATA TVRNDV/'NH',
     1  'XX','YY','ZZ','RO','FI','TE','DI',
     1  'BB','**','DF','DT' ,
     1  'EN','II','JJ','KK','NN','LL',
     1  'NT','CL','U2'/
      DATA KNECDK/     4, 5, 5, 5, 6, 6, 6,-4,
     1  5, 6, 6, 6,-5,-5,-5,-5,
     1  6,-6,-6,-6,-6,-6,-6,-6,
     1  -4, 4, 4, 4, 4, 4, 4, 4,
     1  -5,-5,-5,-5, 5, 5, 5, 5,
     1  -6,-6,-6,-6,-6,-6,-6, 6/
      DATA NEXTDW/0, 3, 1, 5, 2, 6, 4, 0, 0, 0, 0, 0, 0/
      DATA LASTDW/0, 2, 4, 1, 6, 3, 5, 0, 0, 0, 0, 0, 0/
      DATA FRETDT/.FALSE./,FBLWDT/.FALSE./
      DATA TREVDT/' [7m'/,TULIDT/' [0m [4m'/,TNORDT/' [0m'/
C_CG
C_CG    --- Data statements OF routine  DGINIT     ---
C_CG
      DATA LTABDD/ 1,13, 2, 6, 3, 5, 7, 8,14, 4,11,10,16,12,15, 9,
     &                         112*0/
C                  0  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15
C_CG
C_CG    --- The following var are inc. in dali_cf.inc
C_CG
      CHARACTER *1 TW(0:14)
      DIMENSION  IF(0:12),
     &  I1(0:12),I2(0:12),I3(0:12),I4(0:12),I5(0:12),I6(0:12),
     &  IU(0:12),ID(0:12),IL(0:12),IM(0:12),IR(0:12),IS(0:12)
      EQUIVALENCE (TWINDW,TW)
      EQUIVALENCE (NWINDW( 0, 0),IF)
      EQUIVALENCE (NWINDW( 0, 1),I1)
      EQUIVALENCE (NWINDW( 0, 2),I2)
      EQUIVALENCE (NWINDW( 0, 3),I3)
      EQUIVALENCE (NWINDW( 0, 4),I4)
      EQUIVALENCE (NWINDW( 0, 5),I5)
      EQUIVALENCE (NWINDW( 0, 6),I6)
      EQUIVALENCE (NWINDW( 0, 7),IU)
      EQUIVALENCE (NWINDW( 0, 8),ID)
      EQUIVALENCE (NWINDW( 0, 9),IL)
      EQUIVALENCE (NWINDW( 0,10),IM)
      EQUIVALENCE (NWINDW( 0,11),IR)
      EQUIVALENCE (NWINDW( 0,12),IS)
C     DATA NW/ 0 , 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 ,10 ,11 ,12/
      DATA IF/ 1 ,-2 ,-2 ,-2 ,-2 ,-2 ,-2 ,-2 ,-2 ,-2 ,-2 ,-2 ,-2/
      DATA I1/-1 , 1 , 0 , 0 , 0 , 0 , 0 ,-1 , 0 ,-1 , 0 , 0 ,-1/
      DATA I2/-1 , 0 , 1 , 0 , 0 , 0 , 0 , 0 ,-1 ,-1 , 0 , 0 ,-1/
      DATA I3/-1 , 0 , 0 , 1 , 0 , 0 , 0 ,-1 , 0 , 0 ,-1 , 0 ,-1/
      DATA I4/-1 , 0 , 0 , 0 , 1 , 0 , 0 , 0 ,-1 , 0 ,-1 , 0 ,-1/
      DATA I5/-1 , 0 , 0 , 0 , 0 , 1 , 0 , 0 , 0 , 0 , 0 ,-1 , 0/
      DATA I6/-1 , 0 , 0 , 0 , 0 , 0 , 1 , 0 , 0 , 0 , 0 ,-1 , 0/
      DATA IU/-1 ,-2 , 0 ,-2 , 0 , 0 , 0 , 1 , 0 ,-1 ,-1 , 0 ,-1/
      DATA ID/-1 , 0 ,-2 , 0 ,-2 , 0 , 0 , 0 , 1 ,-1 ,-1 , 0 ,-1/
C
      DATA IL/-1 ,-2 ,-2 , 0 , 0 , 0 , 0 ,-1 ,-1 , 1 , 0 , 0 ,-1/
C
      DATA IM/-1 , 0 , 0 ,-2 ,-2 , 0 , 0 ,-1 ,-1 , 0 , 1 , 0 ,-1/
      DATA IR/-1 , 0 , 0 , 0 , 0 ,-2 ,-2 , 0 , 0 , 0 , 0 , 1 , 0/
      DATA IS/-1 ,-2 ,-2 ,-2 ,-2 , 0 , 0 ,-2 ,-2 ,-2 ,-2 , 0 , 1/
      DATA TW/'W','1','2','3','4','5','6','U','D','L','M','R','S',
     &  'H','C'/
C
      DATA FPIKDP,FPIMDP/2*.FALSE./,IPTNDP/0/
      DATA NTF1DO,NSP1DO,IRZ1DO/1,2,3/
      DATA COLIDF/0.,0.,15.,-1., 0.,2.,15.,-1.,
     1  0.,4.,15.,-1. ,-15.,2.,15.,-1., 0.,2.,15.,-1., 0.,5.,99.,-1.,
     1  16*0./
C
C
C
C_CG
C_CG    --- Data statements OF routine     DGLTPC  ---
C_CG    ---  Definitions of detector geometry - will be removed a.s.a.
C_CG         the database structure is implemented. (from file DALBV.FOR).
C_CG
      PARAMETER (LISMAX=1000, LTPDCH= 64,LTPD = 20,LTSECT= 36,LTPDRO=
     +  21,LTTROW=19, LTCNT = 10,LTHIDI= 600,LTCLDI= 300,LTPUDI=100,
     +  LTSROW=12,LTWIRE=200,LTSTYP=4,LTLRLW=2, LTCOOW= 9,LTCLUW= 15,
     +  LTPULW= 5,LTPRLW= 4, LTCRLW= 2,LTPDNB=8, LTSLOT=12, LTCORN=5,
     +  LTTPAD= 4)
      COMMON /DPGEOM/RTPCMN,RTPCMX,ZTPCMX,DRTPMN,DRTPMX,DZTPMX,
     *  TPPROW(LTPDRO),TPTROW(LTTROW),NTSECT,NTPROW,
     *  NTPCRN(LTSTYP),TPCORN(2,LTCORN,LTSTYP),
     *  TPPHI0(LTSLOT*LTSTYP),ITPTYP(LTSLOT*LTSTYP),
     *  ITPSEC(LTSLOT*LTSTYP)
C
      COMMON/DVTGEO/ RADIDV(21),PHI0DV(18),FROWDV(18,12),NPADDV(18,12),
     +  ZTPCDV,TBINDV,VELODV
C
C_CG
      DATA RTPCMN /31.64000/
      DATA RTPCMX /177.9000/
      DATA ZTPCMX /220.0000/
      DATA DRTPMN /0.640000/
      DATA DRTPMX /2.200000/
      DATA DZTPMX /20.00000/
C_CG
      DATA TPPROW(1) /        39.87100 /
      DATA TPPROW(2) /        46.27100 /
      DATA TPPROW(3) /        52.67100 /
      DATA TPPROW(4) /        59.07100 /
      DATA TPPROW(5) /        65.47100 /
      DATA TPPROW(6) /        71.87100 /
      DATA TPPROW(7) /        78.27100 /
      DATA TPPROW(8) /        84.67101 /
      DATA TPPROW(9) /        91.07101 /
      DATA TPPROW(10) /       100.2220 /
      DATA TPPROW(11) /       106.6220 /
      DATA TPPROW(12) /       113.0220 /
      DATA TPPROW(13) /       119.4220 /
      DATA TPPROW(14) /       125.8220 /
      DATA TPPROW(15) /       132.2220 /
      DATA TPPROW(16) /       138.6220 /
      DATA TPPROW(17) /       145.0220 /
      DATA TPPROW(18) /       151.4220 /
      DATA TPPROW(19) /       157.8220 /
      DATA TPPROW(20) /       164.2220 /
      DATA TPPROW(21) /       170.6220 /
      DATA TPTROW(1) /        43.07100 /
      DATA TPTROW(2) /        49.47100 /
      DATA TPTROW(3) /        55.87100 /
      DATA TPTROW(4) /        62.27100 /
      DATA TPTROW(5) /        68.67101 /
      DATA TPTROW(6) /        75.07101 /
      DATA TPTROW(7) /        81.47101 /
      DATA TPTROW(8) /        87.87101 /
      DATA TPTROW(9) /        103.4220 /
      DATA TPTROW(10) /       109.8220 /
      DATA TPTROW(11) /       116.2220 /
      DATA TPTROW(12) /       122.6220 /
      DATA TPTROW(13) /       129.0220 /
      DATA TPTROW(14) /       135.4220 /
      DATA TPTROW(15) /       141.8220 /
      DATA TPTROW(16) /       148.2220 /
      DATA TPTROW(17) /       154.6220 /
      DATA TPTROW(18) /       161.0220 /
      DATA TPTROW(19) /       167.4220 /
      DATA NTSECT /   36 /
      DATA NTPROW /   21 /
      DATA NTPCRN(1) /        4 /
      DATA NTPCRN(2) /        5 /
      DATA NTPCRN(3) /        5 /
      DATA NTPCRN(4) /        0 /
      DATA TPCORN(1,1,1) /    34.99910 /
      DATA TPCORN(2,1,1) /    9.378200 /
      DATA TPCORN(1,2,1) /    30.31000 /
      DATA TPCORN(2,2,1) /    17.50000 /
      DATA TPCORN(1,3,1) /    82.01760 /
      DATA TPCORN(2,3,1) /    47.35000 /
      DATA TPCORN(1,4,1) /    94.70000 /
      DATA TPCORN(2,4,1) /    25.37480 /
      DATA TPCORN(1,5,1) /    0.0000000 /
      DATA TPCORN(2,5,1) /    0.0000000 /
      DATA TPCORN(1,1,2) /    94.70000 /
      DATA TPCORN(2,1,2) /    25.37480 /
      DATA TPCORN(1,2,2) /    142.7851 /
      DATA TPCORN(2,2,2) /    38.25910 /
      DATA TPCORN(1,3,2) /    142.7851 /
      DATA TPCORN(2,3,2) /    44.50290 /
      DATA TPCORN(1,4,2) /    167.3754 /
      DATA TPCORN(2,4,2) /    51.09280 /
      DATA TPCORN(1,5,2) /    173.5029 /
      DATA TPCORN(2,5,2) /    22.84210 /
      DATA TPCORN(1,1,3) /    94.70000 /
      DATA TPCORN(2,1,3) /    25.37480 /
      DATA TPCORN(1,2,3) /    142.7851 /
      DATA TPCORN(2,2,3) /    38.25910 /
      DATA TPCORN(1,3,3) /    145.9070 /
      DATA TPCORN(2,3,3) /    32.85180 /
      DATA TPCORN(1,4,3) /    170.4975 /
      DATA TPCORN(2,4,3) /    39.44080 /
      DATA TPCORN(1,5,3) /    173.5029 /
      DATA TPCORN(2,5,3) /    22.84210 /
      DATA TPCORN(1,1,4) /    0.0000000 /
      DATA TPCORN(2,1,4) /    0.0000000 /
      DATA TPCORN(1,2,4) /    0.0000000 /
      DATA TPCORN(2,2,4) /    0.0000000 /
      DATA TPCORN(1,3,4) /    0.0000000 /
      DATA TPCORN(2,3,4) /    0.0000000 /
      DATA TPCORN(1,4,4) /    0.0000000 /
      DATA TPCORN(2,4,4) /    0.0000000 /
      DATA TPCORN(1,5,4) /    0.0000000 /
      DATA TPCORN(2,5,4) /    0.0000000 /
      DATA TPPHI0(1) /        0.5235988 /
      DATA TPPHI0(2) /        1.570796 /
      DATA TPPHI0(3) /        2.617994 /
      DATA TPPHI0(4) /        3.665192 /
      DATA TPPHI0(5) /        4.712389 /
      DATA TPPHI0(6) /        5.759587 /
      DATA TPPHI0(7) /        0.0000000 /
      DATA TPPHI0(8) /        0.5235988 /
      DATA TPPHI0(9) /        1.047198 /
      DATA TPPHI0(10) /       1.570796 /
      DATA TPPHI0(11) /       2.094395 /
      DATA TPPHI0(12) /       2.617994 /
      DATA TPPHI0(13) /       3.141593 /
      DATA TPPHI0(14) /       3.665192 /
      DATA TPPHI0(15) /       4.188790 /
      DATA TPPHI0(16) /       4.712389 /
      DATA TPPHI0(17) /       5.235988 /
      DATA TPPHI0(18) /       5.759587 /
      DATA TPPHI0(19) /       0.5235988 /
      DATA TPPHI0(20) /       1.570796 /
      DATA TPPHI0(21) /       2.617994 /
      DATA TPPHI0(22) /       3.665192 /
      DATA TPPHI0(23) /       4.712389 /
      DATA TPPHI0(24) /       5.759587 /
      DATA TPPHI0(25) /       0.0000000 /
      DATA TPPHI0(26) /       0.5235988 /
      DATA TPPHI0(27) /       1.047198 /
      DATA TPPHI0(28) /       1.570796 /
      DATA TPPHI0(29) /       2.094395 /
      DATA TPPHI0(30) /       2.617994 /
      DATA TPPHI0(31) /       3.141593 /
      DATA TPPHI0(32) /       3.665192 /
      DATA TPPHI0(33) /       4.188790 /
      DATA TPPHI0(34) /       4.712389 /
      DATA TPPHI0(35) /       5.235988 /
      DATA TPPHI0(36) /       5.759587 /
      DATA TPPHI0(37) /       0.0000000 /
      DATA TPPHI0(38) /       0.0000000 /
      DATA TPPHI0(39) /       0.0000000 /
      DATA TPPHI0(40) /       0.0000000 /
      DATA TPPHI0(41) /       0.0000000 /
      DATA TPPHI0(42) /       0.0000000 /
      DATA TPPHI0(43) /       0.0000000 /
      DATA TPPHI0(44) /       0.0000000 /
      DATA TPPHI0(45) /       0.0000000 /
      DATA TPPHI0(46) /       0.0000000 /
      DATA TPPHI0(47) /       0.0000000 /
      DATA TPPHI0(48) /       0.0000000 /
      DATA ITPTYP(1) /        1 /
      DATA ITPTYP(2) /        1 /
      DATA ITPTYP(3) /        1 /
      DATA ITPTYP(4) /        1 /
      DATA ITPTYP(5) /        1 /
      DATA ITPTYP(6) /        1 /
      DATA ITPTYP(7) /        2 /
      DATA ITPTYP(8) /        3 /
      DATA ITPTYP(9) /        2 /
      DATA ITPTYP(10) /       3 /
      DATA ITPTYP(11) /       2 /
      DATA ITPTYP(12) /       3 /
      DATA ITPTYP(13) /       2 /
      DATA ITPTYP(14) /       3 /
      DATA ITPTYP(15) /       2 /
      DATA ITPTYP(16) /       3 /
      DATA ITPTYP(17) /       2 /
      DATA ITPTYP(18) /       3 /
      DATA ITPTYP(19) /       1 /
      DATA ITPTYP(20) /       1 /
      DATA ITPTYP(21) /       1 /
      DATA ITPTYP(22) /       1 /
      DATA ITPTYP(23) /       1 /
      DATA ITPTYP(24) /       1 /
      DATA ITPTYP(25) /       2 /
      DATA ITPTYP(26) /       3 /
      DATA ITPTYP(27) /       2 /
      DATA ITPTYP(28) /       3 /
      DATA ITPTYP(29) /       2 /
      DATA ITPTYP(30) /       3 /
      DATA ITPTYP(31) /       2 /
      DATA ITPTYP(32) /       3 /
      DATA ITPTYP(33) /       2 /
      DATA ITPTYP(34) /       3 /
      DATA ITPTYP(35) /       2 /
      DATA ITPTYP(36) /       3 /
      DATA ITPTYP(37) /       0 /
      DATA ITPTYP(38) /       0 /
      DATA ITPTYP(39) /       0 /
      DATA ITPTYP(40) /       0 /
      DATA ITPTYP(41) /       0 /
      DATA ITPTYP(42) /       0 /
      DATA ITPTYP(43) /       0 /
      DATA ITPTYP(44) /       0 /
      DATA ITPTYP(45) /       0 /
      DATA ITPTYP(46) /       0 /
      DATA ITPTYP(47) /       0 /
      DATA ITPTYP(48) /       0 /
      DATA ITPSEC(1) /        1 /
      DATA ITPSEC(2) /        2 /
      DATA ITPSEC(3) /        3 /
      DATA ITPSEC(4) /        4 /
      DATA ITPSEC(5) /        5 /
      DATA ITPSEC(6) /        6 /
      DATA ITPSEC(7) /        1 /
      DATA ITPSEC(8) /        1 /
      DATA ITPSEC(9) /        2 /
      DATA ITPSEC(10) /       2 /
      DATA ITPSEC(11) /       3 /
      DATA ITPSEC(12) /       3 /
      DATA ITPSEC(13) /       4 /
      DATA ITPSEC(14) /       4 /
      DATA ITPSEC(15) /       5 /
      DATA ITPSEC(16) /       5 /
      DATA ITPSEC(17) /       6 /
      DATA ITPSEC(18) /       6 /
      DATA ITPSEC(19) /       7 /
      DATA ITPSEC(20) /       8 /
      DATA ITPSEC(21) /       9 /
      DATA ITPSEC(22) /       10 /
      DATA ITPSEC(23) /       11 /
      DATA ITPSEC(24) /       12 /
      DATA ITPSEC(25) /       7 /
      DATA ITPSEC(26) /       7 /
      DATA ITPSEC(27) /       8 /
      DATA ITPSEC(28) /       8 /
      DATA ITPSEC(29) /       9 /
      DATA ITPSEC(30) /       9 /
      DATA ITPSEC(31) /       10 /
      DATA ITPSEC(32) /       10 /
      DATA ITPSEC(33) /       11 /
      DATA ITPSEC(34) /       11 /
      DATA ITPSEC(35) /       12 /
      DATA ITPSEC(36) /       12 /
      DATA ITPSEC(37) /       0 /
      DATA ITPSEC(38) /       0 /
      DATA ITPSEC(39) /       0 /
      DATA ITPSEC(40) /       0 /
      DATA ITPSEC(41) /       0 /
      DATA ITPSEC(42) /       0 /
      DATA ITPSEC(43) /       0 /
      DATA ITPSEC(44) /       0 /
      DATA ITPSEC(45) /       0 /
      DATA ITPSEC(46) /       0 /
      DATA ITPSEC(47) /       0 /
      DATA ITPSEC(48) /       0 /
C_CG
C_CG
C_CG    --- Data statements OF routine     DLCOLH  ---
C_CG
      DATA DMAXDK/276.045045/
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C_CG
C_CG    --- Data statements OF routine  DLUTIN     ---
C_CG
      DATA MVDEDL/1/,MITCDL/2/,MTPCDL/3/,MECADL/4/,MHCADL/5/,
     1  MMDEDL/6/
C
C WI
C//   DATA (WDSNDL(2,1,N),N=1,6)/2*22.5,4*0.5/
C//   DATA (WDSNDL(3,1,N),N=1,6)/6*999./
C OS
C//   DATA (WDSNDL(1,2,N),N=1,6)/6*-999./
C//   DATA (WDSNDL(3,2,N),N=1,6)/6*9999./
C AM
C//   DATA (WDSNDL(1,3,N),N=1,6)/6*1./
C//   DATA (WDSNDL(2,3,N),N=1,6)/6*8./
C//   DATA (WDSNDL(3,3,N),N=1,6)/6*15./
C SZ
C//   DATA (WDSNDL(2,4,N),N=1,6)/6*10./
C//   DATA (WDSNDL(3,4,N),N=1,6)/6*99./
C SS
C//   DATA (WDSNDL(1,5,N),N=1,6)/6*.001/
C//   DATA (WDSNDL(3,5,N),N=1,6)/6*99./
C SH
C//   DATA (WDSNDL(1,6,N),N=1,6)/6*-9999./
C//   DATA (WDSNDL(3,6,N),N=1,6)/6* 9999./
C//   DATA (WDSNDL(4,6,N),N=1,6)/6*-1./
C ST
C//   DATA (WDSNDL(1,7,N),N=1,6)/6*-9999./
C//   DATA (WDSNDL(3,7,N),N=1,6)/6* 9999./
C//   DATA (WDSNDL(4,7,N),N=1,6)/6*-1./
C FA
C//   DATA (WDSNDL(1,8,N),N=1,6)/6*0.01/
C//   DATA (WDSNDL(2,8,N),N=1,6)/6*1./
C//   DATA (WDSNDL(3,8,N),N=1,6)/6*999./
C
C//   DATA (((RAMPDL(1,N,J,K),N=1,MPRADL),J=1,MPDVDL),K=1,2)/96*-99./
C//   DATA (((RAMPDL(3,N,J,K),N=1,MPRADL),J=1,MPDVDL),K=1,2)/96*999./
C//   DATA (RAMPDL(2,N,4,1),N=1,8)/0.,3.,8.,15.,24.,35.,48.,63./
C//   DATA (RAMPDL(2,N,5,1),N=1,8)/0.,3.,8.,15.,24.,35.,48.,63./
C//   DATA (RAMPDL(2,N,4,2),N=1,8)/0.,0.,0.,4.,5.,6.,0.,0./
C//   DATA (RAMPDL(2,N,5,2),N=1,8)/0.,0.,7.,0.,0.,8.,0.,0./
C
      DATA MGRCDL/6*2/
C//   DATA MVARDL/3*6,2*12,6,  2*1,18,2*15,1/
C//   DATA MODEDL/3*3,2*2 ,3,  2*1,5,3*1/
C//   DATA MSYMDL/ 6*1,        2*1,1,3,6,1/
      DATA MCOLDL/6*8/
      DATA MLABDL/6*1/
      DATA SZVXDT/80./,NCVXDT/8/
C_CG
C_CG    --- Data statements OF routine  DOPRIN     ---
C_CG
C      DATA PARADO/
CC          RM
C     1  0.,0.,2.,0.,
CC          DD               SS             CC
C     1  1.,40.,170.,0.,  0.,0.,999.,1., 0.,0.,999.,1.,
CC            GA                   AF
C     1  -999.,0.,999.,0.,  -999.,190.,999.,0.,
CC          DF               SF              CF              LF
C     1  1.,40.,170.,0., 0.,0.,999.,-1., 0.,0.,999.,-1., 1.,1.,999.,0.,
CC          AT
C     1  0.,100.,180.,0.,
CC          DT               ST              CT              LT
C     1  1.,40.,170.,0., 0.,0.,999.,-1., 0.,0.,999.,-1., 1.,1.,999.,0.,
CC          PL                     P1                  P2
C     1  1.,1003.,0.,0.,     1., 1001.,  0.,0.,   1.,1004.,  0.,0.,
CC           FR                    TO
C     1  -999.,0.,999.,0.,      1.,1004.,999.,0.,
CC            PU                    SK              CE
C     1  -99.,0.,99.,-1.,  -99.,0.,999.,-1.,   -99.,0.,999.,-1.,
CC            SC                  SP              AS
C     1  0.,0.,99.,-1.,  -99.,0.,999.,-1.,  0.1,1.,99.,0.,
CC            IN                  DG         DUMMY
C     1  0.,111.,999.,0., 0.,10.,90.,0., 0.,0.,99.,1.,
CC              MP         7*DUMMY *4         RU
C     1  -99.,10.,99.,0.,  28*0.,           -999.,0.,999.,0.,
CC            DL                  NT                 ND (in LT)
C     1  0.0001,0.2,99.,0.,   1.,1.,99.,0.,        1.,1.,3.,0.,
CC            MUL             DUMMY *4
C     1  1., 1., 4., 0.,        4*0.,
CC            MI                  MA
C     1  -999.,0.,999.,0.,  -999.,0.,999.,0.,
CC            XX                  YY                ZZ
C     1  -999.,0.,9999.,0.,  0.,0.,999.,0.,  0.,0.,999.,-1.,
CC           RO               DR             HCO
C     1  1.,1.,4.,0.,   0.1,50.,99.,0., -15.,-8.,15.,0.,
CC           CM                P0               HDZ
C     1  -9.,0.,99.,-1.,-9999.,999.,9999.,-1., -999.,0.,999.,-1.,
CC           HDR              HF1            HF2
C     1  -999.,0.,999.,-1., 0.,0.,360.,-1., 0.,360.,360.,-1.,
CC           HT1              HT2            HST
C     1  0.,0.,180.,-1., 0.,180.,180.,-1., -99.,1.,999.,-1.,
CC           HSH              HDE            ZO
C     1  -9999.,1.,9999.,-1., 1.,3.,8.,0., -1.,0.,1.,-1.,
CC           HSE              HRN            HCH
C     1  0.,0.,36.,-1.,  0.,0.,22.,-1.,  -1.,0.,1.,-1.,
CC          HLI             HCE             HCL
C     1  0.,0.,0.,0., -99.,0.,9999.,-1.,  0.,0.,999.,-1.,
CC      DUMMY *4
C     1  4*0./
      DATA TZOODO/'NZ','ZO'/
      DATA TPLNDO/'V1','V2','IT',
     1  'T0','T1','T2','T3','E1','E2','E3','H1','H2','M1','M2'/
      DATA IAREDO/12/
C_CG
C_CG    --- Data statements OF routine      DRZCC  ---
C_CG
C
C     DATA STATEMENTS OT RS
C
      DATA PARADR/0.,0.,999.,0.,  0.,7.,15.,1., 0.,8.,15.,-1./
      DATA FGRYDR/.FALSE./
C
C_CG
C_CG    --- Data statements OF routine     DEVSET  ---
C_CG
      DATA (BNUMDB(4,J),J=1,MBNCDB)/MBNCDB*1./
      DIMENSION NUMBO(0:MBNCDB)
      EQUIVALENCE (NUMBO,NUMBDB)
      DATA NUMBO/MBNCDB,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,
     &  20,21,22,23,24,25,26,27/
C_CG
C_CG    --- Data statements OF routine     DVPADF  ---
C_CG
C     ................. DATA ZTPCDV,TBINDV,VELODV / 220., 100.0, .00505/
C     .................. 27.1.94 : velodv changed by advice of D.Casper
      DATA ZTPCDV,TBINDV,VELODV / 220., 100.0, .0052/
      DATA RADIDV / 39.871,46.271,52.671,59.071,65.471,71.871,
     +  78.271,84.671,91.071,100.222,106.622,113.022,119.422,
     +  125.822,132.222,138.622,145.022,151.422,157.822,164.222,
     +  170.622 /
      DATA FROWDV / 6*0.495883, 12*0.250771, 6*0.499716, 12*0.251433,
     +  6*0.502617, 12*0.252020, 6*0.504890, 12*0.252544, 6*0.506719,
     +  12*0.253015, 6*0.508222, 12*0.253440, 6*0.509479, 12*0.253826,
     +  6*0.510546, 12*0.254178, 6*0.511463, 0.294335, 0.214665,
     +  0.294335, 0.214665, 0.294335, 0.214665, 0.294335, 0.214665,
     +  0.294335, 0.214665, 0.294335, 0.214665, 6*0.0, 0.293016,
     +  0.216577, 0.293016, 0.216577, 0.293016, 0.216577,0.293016,
     +  0.216577, 0.293016, 0.216577, 0.293016, 0.216577, 6*0.0,
     +  0.291799, 0.218339, 0.291799, 0.218339, 0.291799, 0.218339,
     +  0.291799, 0.218339, 0.291799, 0.218339, 0.291799, 0.218339,
     +  6*0.0, 0.290674, 0.219969, 0.290674, 0.219969, 0.290674,
     +  0.219969, 0.290674, 0.219969, 0.290674, 0.219969, 0.290674,
     +  0.219969 /
      DATA NPADDV / 6*59, 12*75, 6*69, 12*80, 6*79, 12*85, 6*89, 12*90,
     +  6*99, 12*95, 6*109, 12*100, 6*119, 12*105, 6*129, 12*110, 6*139,
     +  133, 97, 133, 97, 133, 97, 133, 97, 133, 97, 133, 97, 6*0, 138,
     +  102, 138,102, 138,102, 138,102, 138,102, 138,102, 6*0, 143,107,
     +  143,107, 143,107, 143,107, 143,107, 143,107, 6*0, 148,112,
     +  148,112, 148,112, 148,112, 148,112, 148,112 /
      DATA PHI0DV / 0.523599, 1.570796, 2.617993, 3.665191, 4.712388,
     +  5.759585, 0.0, 0.523599, 1.047197, 1.570796, 2.094395, 2.617993,
     +  3.141592, 3.665191, 4.188789, 4.712388, 5.2355987, 5.759585 /
C_CG
C_CG    --- Data statements OF routine     DYXDIS  ---
C_CG
      DATA DMAXDQ/2./
C_CG
C_CG    --- Data statements OF routine     DGINIT  ---
C_CG         -- is in dali_cf
      DATA TGRADG/'GKS'/
C_CG
C_CG    --------------------------------------------------------
C_CG
C_CG  -- Following is the init. done in DALI_MU.INC  ---
C_CG     (should be redone, once DALI_MU is updated).
C_CG
C_CG
      DATA FECXY/'X','Y','X','Y','X','Y','X','Y','X','Y',
     &           'X','Y','X','Y','X','Y'/
      DATA UBFUL,UBRIN,UBROU/694.0,470.0,522.0/
      DATA UBRTK,UMATK,UECTK/8.8,2*9.0/
      DATA UMAUM/347.0,366.0/
      DATA UBAWB/12*247.7,254.0,5*276.0,2*254.0,3*276.0,254.0/
      DATA UMAZW/8*145.6,245.8,145.6,9*162.3,8*145.6,245.8,145.6,
     &           9*162.3/
      DATA UMAWZ/245.8,329.3,245.8,329.3,245.8,329.3,245.8,362.7,
     &           479.6,362.7,262.5,362.7,262.5,362.7,262.5,362.7,
     &           262.5,429.5,429.5,245.8,329.3,245.8,329.3,245.8,
     &           329.3,245.8,362.7,479.6,362.7,262.5,362.7,262.5,
     &           362.7,262.5,362.7,262.5,429.5,429.5/
      DATA UMARM/495.0,506.0,495.0,506.0,495.0,506.0,495.0,506.0,
     &           495.5,506.0,548.0,556.0,548.0,556.0,548.0,556.0,
     &           548.0,556.0,556.0,495.0,506.0,495.0,506.0,495.0,
     &           506.0,495.0,506.0,495.5,506.0,548.0,556.0,548.0,
     &           556.0,548.0,556.0,548.0,556.0,556.0/
      DATA UECXW/460.8,595.2,460.8,595.2,518.4,652.8,518.4,652.8,
     &           460.8,595.2,460.8,595.2,518.4,652.8,518.4,652.8/
      DATA UECYW/596.5,462.9,479.6,346.0,646.6,513.0,529.7,396.1,
     &           479.6,462.9,596.5,346.0,529.7,513.0,646.6,396.1/
      DATA UECXC/297.6,-231.2,-297.6,231.2,326.4,-260.0,-326.4,260.0,
     &           297.6,231.2,-297.6,-231.2,326.4,260.0,-326.4,-260.0/
      DATA UECYC/231.9,298.6,-173.4,-240.2,256.9,323.7,-198.4,-265.3,
     &           -173.4,298.6,231.9,-240.2,-198.4,323.7,256.9,-265.3/
      DATA UECZE/494.9,494.9,494.9,494.9,530.9,530.9,530.9,530.9,
     &           494.9,494.9,494.9,494.9,530.9,530.9,530.9,530.9/
      DATA BRTF/
     &    54.7, 14.6, 54.7,345.4,125.3,345.4,125.3, 14.6, 54.7, 14.6,
     &    54.7, 44.6, 54.7, 15.4,125.3, 15.4,125.3, 44.6, 54.7, 44.6,
     &    54.7, 74.6, 54.7, 45.4,125.3, 45.4,125.3, 74.6, 54.7, 74.6,
     &    54.7,104.6, 54.7, 75.4,125.3, 75.4,125.3,104.6, 54.7,104.6,
     &    54.7,134.6, 54.7,105.4,125.3,105.4,125.3,134.6, 54.7,134.6,
     &    54.7,164.6, 54.7,135.4,125.3,135.4,125.3,164.6, 54.7,164.6,
     &    54.7,194.6, 54.7,165.4,125.3,165.4,125.3,194.6, 54.7,194.6,
     &    54.7,224.6, 54.7,195.4,125.3,195.4,125.3,224.6, 54.7,224.6,
     &    54.7,254.6, 54.7,225.4,125.3,225.4,125.3,254.6, 54.7,254.6,
     &    54.7,284.6, 54.7,255.4,125.3,255.4,125.3,284.6, 54.7,284.6,
     &    54.7,314.6, 54.7,285.4,125.3,285.4,125.3,314.6, 54.7,314.6,
     &    54.7,344.6, 54.7,315.4,125.3,315.4,125.3,344.6, 54.7,344.6,
     &    57.3, 13.6, 57.3,346.4,122.7,346.4,122.7, 13.6, 57.3, 13.6,
     &    57.5, 44.7, 57.5, 15.3,122.5, 15.3,122.5, 44.7, 57.5, 44.7,
     &    57.5, 74.7, 57.5, 45.3,122.5, 45.3,122.5, 74.7, 57.5, 74.7,
     &    57.5,104.7, 57.5, 75.3,122.5, 75.3,122.5,104.7, 57.5,104.7,
     &    57.5,134.7, 57.5,105.3,122.5,105.3,122.5,134.7, 57.5,134.7,
     &    57.5,164.7, 57.5,135.3,122.5,135.3,122.5,164.7, 57.5,164.7,
     &    57.3,193.6, 57.3,166.4,122.7,166.4,122.7,193.6, 57.3,193.6,
     &    57.3,223.6, 57.3,196.4,122.7,196.4,122.7,223.6, 57.3,223.6,
     &    57.5,254.7, 57.5,225.3,122.5,225.3,122.5,254.7, 57.5,254.7,
     &    57.5,284.7, 57.5,255.3,122.5,255.3,122.5,284.7, 57.5,284.7,
     &    57.5,314.7, 57.5,285.3,122.5,285.3,122.5,314.7, 57.5,314.7,
     &    57.3,343.6, 57.3,316.4,122.7,316.4,122.7,343.6, 57.3,343.6/
      DATA STTF/
     &   125.3, 75.6,126.1, 86.5,121.8, 86.5,121.9, 89.6, 58.1, 89.6,
     &    58.2, 86.5, 53.9, 86.5, 54.7, 75.6,125.3, 75.6,
     &   125.3,104.4,126.1, 93.5,121.8, 93.5,121.9, 90.4, 58.1, 90.4,
     &    58.2, 93.5, 53.9, 93.5, 54.7,104.4,125.3,104.4,
     &   122.6, 75.5,123.4, 86.9,119.2, 86.9,119.2, 89.6, 60.8, 89.6,
     &    60.8, 86.9, 56.6, 86.9, 57.4, 75.5,122.6, 75.5,
     &   122.6,104.5,123.4, 93.1,119.2, 93.1,119.2, 90.4, 60.8, 90.4,
     &    60.8, 93.1, 56.6, 93.1, 57.4,104.5,122.6,104.5/
      DATA SBTF/
     &   108.0,225.4,108.0,254.6, 72.0,254.6, 72.0,225.4,108.0,225.4,
     &   125.4,225.4,125.4,254.6,116.6,254.6,116.6,225.4,125.4,225.4,
     &    63.4,225.4, 63.4,254.6, 54.6,254.6, 54.6,225.4, 63.4,225.4,
     &   108.0,285.4,108.0,314.6, 72.0,314.6, 72.0,285.4,108.0,285.4,
     &   125.4,285.4,125.4,314.6,116.6,314.6,116.6,285.4,125.4,285.4,
     &    63.4,285.4, 63.4,314.6, 54.6,314.6, 54.6,285.4, 63.4,285.4,
     &   106.3,225.3,106.3,254.7, 73.7,254.7, 73.7,225.3,106.3,225.3,
     &   122.6,225.3,122.6,254.7,114.3,254.7,114.3,225.3,122.6,225.3,
     &    65.7,225.3, 65.7,254.7, 57.4,254.7, 57.4,225.3, 65.7,225.3,
     &   106.3,285.3,106.3,314.7, 73.7,314.7, 73.7,285.3,106.3,285.3,
     &   122.6,285.3,122.6,314.7,114.3,314.7,114.3,285.3,122.6,285.3,
     &    65.7,285.3, 65.7,314.7, 57.4,314.7, 57.4,285.3, 65.7,285.3/
      DATA UATF/
     &    46.2,346.2, 56.0,346.2, 56.0, 13.8, 46.2, 13.8, 46.2,346.2,
     &    47.4, 12.1, 57.1, 12.1, 57.1, 47.9, 47.4, 47.9, 47.4, 12.1,
     &    46.2, 46.2, 56.0, 46.2, 56.0, 73.8, 46.2, 73.8, 46.2, 46.2,
     &    47.4, 72.1, 57.1, 72.1, 57.1,107.9, 47.4,107.9, 47.4, 72.1,
     &    46.2,106.2, 56.0,106.2, 56.0,133.8, 46.2,133.8, 46.2,106.2,
     &    47.4,132.1, 57.1,132.1, 57.1,167.9, 47.4,167.9, 47.4,132.1,
     &    46.2,166.2, 56.0,166.2, 56.0,193.8, 46.2,193.8, 46.2,166.2,
     &    47.7,190.4, 57.4,190.4, 57.4,229.6, 47.7,229.6, 47.7,190.4,
     &    43.1,244.4, 58.0,244.4, 58.0,295.6, 43.1,295.6, 43.1,244.4,
     &    47.7,310.4, 57.4,310.4, 57.4,349.6, 47.7,349.6, 47.7,310.4,
     &    48.1,346.6, 58.6,346.6, 58.6, 13.4, 48.1, 13.4, 48.1,346.6,
     &    49.2, 12.1, 59.5, 12.1, 59.5, 47.9, 49.2, 47.9, 49.2, 12.1,
     &    48.1, 46.6, 58.6, 46.6, 58.6, 73.4, 48.1, 73.4, 48.1, 46.6,
     &    49.2, 72.1, 59.5, 72.1, 59.5,107.9, 49.2,107.9, 49.2, 72.1,
     &    48.1,106.6, 58.6,106.6, 58.6,133.4, 48.1,133.4, 48.1,106.6,
     &    49.2,132.1, 59.5,132.1, 59.5,167.9, 49.2,167.9, 49.2,132.1,
     &    48.1,166.6, 58.6,166.6, 58.6,193.4, 48.1,193.4, 48.1,166.6,
     &    49.7,189.0, 60.0,189.0, 60.0,231.0, 49.7,231.0, 49.7,189.0,
     &    49.7,309.0, 60.0,309.0, 60.0,351.0, 49.7,351.0, 49.7,309.0/
      DATA UBTF/
     &   133.8, 13.8,124.0, 13.8,124.0,346.2,133.8,346.2,133.8, 13.8,
     &   132.6, 47.9,122.9, 47.9,122.9, 12.1,132.6, 12.1,132.6, 47.9,
     &   133.8, 73.8,124.0, 73.8,124.0, 46.2,133.8, 46.2,133.8, 73.8,
     &   132.6,107.9,122.9,107.9,122.9, 72.1,132.6, 72.1,132.6,107.9,
     &   133.8,133.8,124.0,133.8,124.0,106.2,133.8,106.2,133.8,133.8,
     &   132.6,167.9,122.9,167.9,122.9,132.1,132.6,132.1,132.6,167.9,
     &   133.8,193.8,124.0,193.8,124.0,166.2,133.8,166.2,133.8,193.8,
     &   132.3,229.6,122.6,229.6,122.6,190.4,132.3,190.4,132.3,229.6,
     &   136.9,295.6,122.0,295.6,122.0,244.4,136.9,244.4,136.9,295.6,
     &   132.3,349.6,122.6,349.6,122.6,310.4,132.3,310.4,132.3,349.6,
     &   131.9, 13.4,121.4, 13.4,121.4,346.6,131.9,346.6,131.9, 13.4,
     &   130.8, 47.9,120.5, 47.9,120.5, 12.1,130.8, 12.1,130.8, 47.9,
     &   131.9, 73.4,121.4, 73.4,121.4, 46.6,131.9, 46.6,131.9, 73.4,
     &   130.8,107.9,120.5,107.9,120.5, 72.1,130.8, 72.1,130.8,107.9,
     &   131.9,133.4,121.4,133.4,121.4,106.6,131.9,106.6,131.9,133.4,
     &   130.8,167.9,120.5,167.9,120.5,132.1,130.8,132.1,130.8,167.9,
     &   131.9,193.4,121.4,193.4,121.4,166.6,131.9,166.6,131.9,193.4,
     &   130.3,231.0,120.0,231.0,120.0,189.0,130.3,189.0,130.3,231.0,
     &   130.3,351.0,120.0,351.0,120.0,309.0,130.3,309.0,130.3,351.0/
      DATA ECTF1/
     &    10.7, 315.4,  12.4, 322.7,  14.2, 328.3,  16.0, 332.5,
     &    17.9, 335.8,  19.8, 338.4,  21.7, 340.5,  23.6, 342.3,
     &    25.4, 343.7,  27.2, 345.0,  28.9, 346.1,  30.6, 347.0,
     &    32.2, 347.8,  33.8, 348.6,  35.3, 349.2,  36.8, 349.8,
     &    38.2, 350.3,  39.6, 350.8,  40.9, 351.2,  42.2, 351.6,
     &    43.4, 351.9,  44.6, 352.3,  45.7, 352.6,  46.8, 352.8,
     &    46.9,  82.8,  45.5,  82.4,  44.0,  82.0,  42.5,  81.6,
     &    40.8,  81.0,  39.1,  80.5,  37.3,  79.8,  35.4,  79.1,
     &    33.4,  78.2,  31.4,  77.2,  29.2,  76.1,  27.0,  74.7,
     &    24.6,  72.9,  22.3,  70.8,  19.8,  68.1,  17.4,  64.5,
     &    15.0,  59.7,  12.6,  53.0,  10.5,  43.3,   8.8,  29.1,
     &     7.8,   9.7,   7.8, 347.8,   8.9, 329.0,  10.7, 315.4,
     &    10.7,  45.3,   8.9,  58.9,   7.8,  77.7,   7.8,  99.5,
     &     8.7, 118.9,  10.4, 133.2,  12.6, 142.9,  14.9, 149.7,
     &    17.3, 154.5,  19.8, 158.0,  22.2, 160.8,  24.6, 162.9,
     &    26.9, 164.6,  29.1, 166.0,  31.3, 167.2,  33.4, 168.2,
     &    35.3, 169.1,  37.2, 169.8,  39.0, 170.5,  40.8, 171.0,
     &    42.4, 171.5,  44.0, 172.0,  45.5, 172.4,  46.9, 172.8,
     &    46.9,  82.9,  45.8,  82.6,  44.7,  82.3,  43.5,  82.0,
     &    42.3,  81.6,  41.0,  81.2,  39.7,  80.8,  38.3,  80.3,
     &    36.9,  79.8,  35.4,  79.2,  33.9,  78.6,  32.3,  77.9,
     &    30.7,  77.0,  29.0,  76.1,  27.2,  75.0,  25.4,  73.8,
     &    23.6,  72.3,  21.8,  70.5,  19.9,  68.4,  18.0,  65.8,
     &    16.1,  62.5,  14.2,  58.3,  12.4,  52.7,  10.7,  45.3/
      DATA ECTF2/
     &    10.7, 135.3,  12.4, 142.7,  14.2, 148.2,  16.0, 152.5,
     &    17.9, 155.7,  19.8, 158.4,  21.7, 160.5,  23.6, 162.3,
     &    25.4, 163.7,  27.2, 165.0,  28.9, 166.1,  30.6, 167.0,
     &    32.2, 167.8,  33.8, 168.5,  35.3, 169.2,  36.8, 169.8,
     &    38.2, 170.3,  39.6, 170.8,  40.9, 171.2,  42.2, 171.6,
     &    43.4, 171.9,  44.6, 172.3,  45.7, 172.6,  46.8, 172.8,
     &    40.0, 260.8,  38.6, 260.3,  37.1, 259.7,  35.6, 259.2,
     &    34.0, 258.5,  32.3, 257.7,  30.6, 256.9,  28.9, 255.9,
     &    27.1, 254.7,  25.2, 253.4,  23.3, 251.8,  21.4, 249.9,
     &    19.4, 247.6,  17.5, 244.7,  15.5, 241.0,  13.6, 236.2,
     &    11.8, 229.8,  10.1, 221.1,   8.8, 209.4,   7.9, 194.2,
     &     7.7, 176.7,   8.2, 159.8,   9.2, 145.9,  10.7, 135.3,
     &    10.7, 225.3,   8.9, 238.9,   7.8, 257.7,   7.8, 279.5,
     &     8.7, 298.9,  10.4, 313.1,  12.6, 322.9,  14.9, 329.6,
     &    17.3, 334.5,  19.8, 338.0,  22.2, 340.7,  24.6, 342.9,
     &    26.9, 344.6,  29.1, 346.0,  31.3, 347.2,  33.4, 348.2,
     &    35.3, 349.1,  37.2, 349.8,  39.0, 350.4,  40.8, 351.0,
     &    42.4, 351.5,  44.0, 352.0,  45.5, 352.4,  46.9, 352.8,
     &    40.0, 260.9,  38.9, 260.5,  37.9, 260.2,  36.8, 259.8,
     &    35.7, 259.3,  34.6 ,258.9,  33.4, 258.4,  32.2, 257.8,
     &    31.0, 257.2,  29.8, 256.6,  28.5, 255.8,  27.2, 255.0,
     &    25.9, 254.1,  24.5, 253.0,  23.1, 251.9,  21.7, 250.5,
     &    20.3, 248.9,  18.9, 247.1,  17.5, 245.0,  16.0, 242.5,
     &    14.6, 239.4,  13.3, 235.7,  12.0, 231.1,  10.7, 225.3/
      DATA ECTF3/
     &    10.0, 315.3,  11.8, 323.5,  13.7, 329.4,  15.7, 333.8,
     &    17.7, 337.1,  19.7, 339.7,  21.7, 341.8,  23.7, 343.6,
     &    25.6, 345.0,  27.4, 346.2,  29.3, 347.2,  31.0, 348.1,
     &    32.7, 348.9,  34.4, 349.6,  36.0, 350.2,  37.5, 350.7,
     &    39.0, 351.2,  40.4, 351.6,  41.7, 352.0,  43.0, 352.4,
     &    44.3, 352.7,  45.5, 353.0,  46.6, 353.3,  47.7, 353.5,
     &    47.5,  83.4,  46.1,  83.1,  44.6,  82.7,  43.1,  82.3,
     &    41.4,  81.8,  39.7,  81.3,  37.9,  80.7,  36.0,  80.1,
     &    34.0,  79.3,  32.0,  78.4,  29.8,  77.3,  27.5,  76.1,
     &    25.2,  74.5,  22.8,  72.6,  20.3,  70.2,  17.8,  67.0,
     &    15.3,  62.7,  12.9,  56.7,  10.6,  47.8,   8.7,  34.4,
     &     7.4,  14.9,   7.2, 351.4,   8.2, 330.3,  10.0, 315.3,
     &    10.0,  45.3,   8.2,  60.5,   7.2,  81.8,   7.4, 105.6,
     &     8.7, 125.0,  10.7, 138.3,  13.0, 147.1,  15.5, 153.1,
     &    18.0, 157.3,  20.5, 160.4,  23.0, 162.8,  25.5, 164.7,
     &    27.8, 166.2,  30.1, 167.5,  32.2, 168.5,  34.3, 169.4,
     &    36.3, 170.2,  38.2, 170.8,  40.0, 171.4,  41.7, 171.9,
     &    43.4, 172.4,  44.9, 172.8,  46.4, 173.1,  47.8, 173.5,
     &    47.5,  83.5,  46.4,  83.2,  45.2,  82.9,  44.0,  82.6,
     &    42.8,  82.3,  41.5,  81.9,  40.1,  81.5,  38.7,  81.1,
     &    37.3,  80.6,  35.7,  80.1,  34.2,  79.5,  32.5,  78.8,
     &    30.8,  78.0,  29.1,  77.1,  27.3,  76.1,  25.4,  74.9,
     &    23.5,  73.4,  21.6,  71.7,  19.6,  69.6,  17.6,  67.0,
     &    15.6,  63.7,  13.7,  59.3,  11.8,  53.4,  10.0,  45.3/
      DATA ECTF4/
     &    10.0, 135.3,  11.8, 143.5,  13.7, 149.4,  15.7, 153.8,
     &    17.7, 157.1,  19.7, 159.7,  21.7, 161.8,  23.7, 163.5,
     &    25.6, 165.0,  27.4, 166.2,  29.3, 167.2,  31.0, 168.1,
     &    32.7, 168.9,  34.4, 169.5,  36.0, 170.2,  37.5, 170.7,
     &    39.0, 171.2,  40.4, 171.6,  41.7, 172.0,  43.0, 172.4,
     &    44.3, 172.7,  45.5, 173.0,  46.6, 173.3,  47.7, 173.5,
     &    41.2, 261.7,  39.8, 261.3,  38.3, 260.8,  36.8, 260.3,
     &    35.2, 259.7,  33.5, 259.1,  31.8, 258.3,  30.0, 257.5,
     &    28.2, 256.5,  26.3, 255.3,  24.4, 253.9,  22.4, 252.2,
     &    20.4, 250.2,  18.3, 247.7,  16.2, 244.5,  14.2, 240.3,
     &    12.2, 234.7,  10.4, 226.9,   8.8, 215.9,   7.7, 200.9,
     &     7.2, 182.3,   7.5, 163.1,   8.5, 147.1,  10.0, 135.3,
     &    10.0, 225.4,   8.2, 240.5,   7.2, 261.8,   7.4, 285.6,
     &     8.7, 305.0,  10.7, 318.3,  13.0, 327.1,  15.5, 333.1,
     &    18.0, 337.3,  20.5, 340.4,  23.0, 342.8,  25.5, 344.7,
     &    27.8, 346.2,  30.1, 347.5,  32.2, 348.5,  34.3, 349.4,
     &    36.3, 350.2,  38.2, 350.8,  40.0, 351.4,  41.7, 351.9,
     &    43.4, 352.4,  44.9, 352.8,  46.4, 353.1,  47.8, 353.5,
     &    41.2, 261.8,  40.1, 261.5,  39.0, 261.2,  37.9, 260.8,
     &    36.8, 260.4,  35.6, 260.0,  34.4, 259.6,  33.1, 259.0,
     &    31.8, 258.5,  30.5, 257.8,  29.1, 257.2,  27.8, 256.4,
     &    26.3, 255.5,  24.9, 254.5,  23.4, 253.4,  21.9, 252.1,
     &    20.4, 250.5,  18.9, 248.7,  17.3, 246.6,  15.8, 244.0,
     &    14.3, 240.8,  12.8, 236.9,  11.3, 231.8,  10.0, 225.4/
      DATA ECTF5/
     &   169.3,  44.7, 167.6,  37.3, 165.8,  31.8, 164.0,  27.5,
     &   162.1,  24.3, 160.2,  21.6, 158.3,  19.5, 156.4,  17.7,
     &   154.6,  16.3, 152.8,  15.0, 151.1,  13.9, 149.4,  13.0,
     &   147.8,  12.2, 146.2,  11.5, 144.7,  10.8, 143.2,  10.2,
     &   141.8,   9.7, 140.4,   9.2, 139.1,   8.8, 137.8,   8.4,
     &   136.6,   8.1, 135.4,   7.7, 134.3,   7.4, 133.2,   7.2,
     &   140.0, 279.2, 141.4, 279.7, 142.9, 280.3, 144.4, 280.8,
     &   146.0, 281.5, 147.7, 282.3, 149.4, 283.1, 151.1, 284.1,
     &   152.9, 285.3, 154.8, 286.6, 156.7, 288.2, 158.6, 290.1,
     &   160.6, 292.4, 162.5, 295.3, 164.5, 299.0, 166.4, 303.8,
     &   168.2, 310.2, 169.9, 318.9, 171.2, 330.6, 172.1, 345.8,
     &   172.3,   3.3, 171.8,  20.2, 170.8,  34.1, 169.3,  44.7,
     &   169.3, 134.7, 171.1, 121.1, 172.2, 102.3, 172.2,  80.5,
     &   171.3,  61.1, 169.6,  46.8, 167.4,  37.1, 165.1,  30.3,
     &   162.7,  25.5, 160.2,  22.0, 157.8,  19.2, 155.4,  17.1,
     &   153.1,  15.4, 150.9,  14.0, 148.7,  12.8, 146.6,  11.8,
     &   144.7,  10.9, 142.8,  10.2, 141.0,   9.5, 139.2,   9.0,
     &   137.6,   8.5, 136.0,   8.0, 134.5,   7.6, 133.1,   7.2,
     &   133.1,  97.1, 134.2,  97.4, 135.3,  97.7, 136.5,  98.0,
     &   137.7,  98.4, 139.0,  98.8, 140.3,  99.2, 141.7,  99.7,
     &   143.1, 100.2, 144.6, 100.8, 146.1, 101.4, 147.7, 102.1,
     &   149.3, 103.0, 151.0, 103.9, 152.8, 105.0, 154.6, 106.2,
     &   156.4, 107.7, 158.2, 109.5, 160.1, 111.6, 162.0, 114.2,
     &   163.9, 117.5, 165.8, 121.7, 167.6, 127.3, 169.3, 134.7/
      DATA ECTF6/
     &   169.3, 224.6, 167.6, 217.3, 165.8, 211.7, 164.0, 207.5,
     &   162.1, 204.2, 160.2, 201.6, 158.3, 199.5, 156.4, 197.7,
     &   154.6, 196.3, 152.8, 195.0, 151.1, 193.9, 149.4, 193.0,
     &   147.8, 192.2, 146.2, 191.4, 144.7, 190.8, 143.2, 190.2,
     &   141.8, 189.7, 140.4, 189.2, 139.1, 188.8, 137.8, 188.4,
     &   136.6, 188.1, 135.4, 187.7, 134.3, 187.4, 133.2, 187.2,
     &   133.1,  97.2, 134.5,  97.6, 136.0,  98.0, 137.5,  98.5,
     &   139.2,  99.0, 140.9,  99.5, 142.7, 100.2, 144.6, 100.9,
     &   146.6, 101.8, 148.6, 102.8, 150.8, 103.9, 153.0, 105.3,
     &   155.4, 107.1, 157.7, 109.2, 160.2, 111.9, 162.6, 115.5,
     &   165.0, 120.3, 167.4, 127.0, 169.5, 136.7, 171.2, 150.9,
     &   172.2, 170.3, 172.2, 192.2, 171.1, 211.0, 169.3, 224.6,
     &   169.3, 314.7, 171.1, 301.1, 172.2, 282.3, 172.2, 260.5,
     &   171.3, 241.1, 169.6, 226.9, 167.4, 217.1, 165.1, 210.4,
     &   162.7, 205.5, 160.2, 202.0, 157.8, 199.3, 155.4, 197.1,
     &   153.1, 195.4, 150.9, 194.0, 148.7, 192.8, 146.6, 191.8,
     &   144.7, 190.9, 142.8, 190.2, 141.0, 189.6, 139.2, 189.0,
     &   137.6, 188.5, 136.0, 188.0, 134.5, 187.6, 133.1, 187.2,
     &   140.0, 279.1, 141.1, 279.5, 142.1, 279.8, 143.2, 280.2,
     &   144.3, 280.7, 145.4, 281.1, 146.6, 281.6, 147.8, 282.2,
     &   149.0, 282.8, 150.2, 283.4, 151.5, 284.2, 152.8, 285.0,
     &   154.1, 285.9, 155.5, 287.0, 156.9, 288.1, 158.3, 289.5,
     &   159.7, 291.1, 161.1, 292.9, 162.5, 295.0, 164.0, 297.5,
     &   165.4, 300.6, 166.7, 304.3, 168.0, 308.9, 169.3, 314.7/
      DATA ECTF7/
     &   170.0,  44.7, 168.2,  36.5, 166.3,  30.6, 164.3,  26.2,
     &   162.3,  22.9, 160.3,  20.3, 158.3,  18.2, 156.3,  16.5,
     &   154.4,  15.0, 152.6,  13.8, 150.7,  12.8, 149.0,  11.9,
     &   147.3,  11.1, 145.6,  10.5, 144.0,   9.8, 142.5,   9.3,
     &   141.0,   8.8, 139.6,   8.4, 138.3,   8.0, 137.0,   7.6,
     &   135.7,   7.3, 134.5,   7.0, 133.4,   6.7, 132.3,   6.5,
     &   138.8, 278.3, 140.2, 278.7, 141.7, 279.2, 143.2, 279.7,
     &   144.8, 280.3, 146.5, 280.9, 148.2, 281.7, 150.0, 282.5,
     &   151.8, 283.5, 153.7, 284.7, 155.6, 286.1, 157.6, 287.8,
     &   159.6, 289.8, 161.7, 292.3, 163.8, 295.5, 165.8, 299.7,
     &   167.8, 305.3, 169.6, 313.1, 171.2, 324.1, 172.3, 339.1,
     &   172.8, 357.7, 172.5,  16.9, 171.5,  32.9, 170.0,  44.7,
     &   170.0, 134.7, 171.8, 119.5, 172.8,  98.2, 172.6,  74.4,
     &   171.3,  55.0, 169.3,  41.7, 167.0,  32.9, 164.5,  26.9,
     &   162.0,  22.7, 159.5,  19.6, 157.0,  17.2, 154.5,  15.3,
     &   152.2,  13.8, 149.9,  12.5, 147.8,  11.5, 145.7,  10.6,
     &   143.7,   9.8, 141.8,   9.2, 140.0,   8.6, 138.3,   8.1,
     &   136.6,   7.6, 135.1,   7.2, 133.6,   6.9, 132.2,   6.5,
     &   132.5,  96.5, 133.6,  96.8, 134.8,  97.1, 136.0,  97.4,
     &   137.2,  97.7, 138.5,  98.1, 139.9,  98.5, 141.3,  98.9,
     &   142.7,  99.4, 144.3,  99.9, 145.8, 100.5, 147.5, 101.2,
     &   149.2, 102.0, 150.9, 102.9, 152.7, 103.9, 154.6, 105.1,
     &   156.5, 106.6, 158.4, 108.3, 160.4, 110.4, 162.4, 113.0,
     &   164.4, 116.3, 166.3, 120.7, 168.2, 126.6, 170.0, 134.7/
      DATA ECTF8/
     &   170.0, 224.7, 168.2, 216.5, 166.3, 210.6, 164.3, 206.2,
     &   162.3, 202.9, 160.3, 200.3, 158.3, 198.2, 156.3, 196.4,
     &   154.4, 195.0, 152.6, 193.8, 150.7, 192.8, 149.0, 191.9,
     &   147.3, 191.1, 145.6, 190.4, 144.0, 189.8, 142.5, 189.3,
     &   141.0, 188.8, 139.6, 188.4, 138.3, 188.0, 137.0, 187.6,
     &   135.7, 187.3, 134.5, 187.0, 133.4, 186.7, 132.3, 186.5,
     &   132.5,  96.6, 133.9,  96.9, 135.4,  97.3, 136.9,  97.7,
     &   138.6,  98.2, 140.3,  98.7, 142.1,  99.3, 144.0,  99.9,
     &   146.0, 100.7, 148.0, 101.6, 150.2, 102.7, 152.5, 103.9,
     &   154.8, 105.5, 157.2, 107.4, 159.7, 109.8, 162.2, 113.0,
     &   164.7, 117.3, 167.1, 123.3, 169.4, 132.2, 171.3, 145.6,
     &   172.6, 165.1, 172.8, 188.6, 171.8, 209.7, 170.0, 224.7,
     &   170.0, 314.6, 171.8, 299.5, 172.8, 278.2, 172.6, 254.4,
     &   171.3, 235.0, 169.3, 221.7, 167.0, 212.9, 164.5, 206.9,
     &   162.0, 202.7, 159.5, 199.6, 157.0, 197.2, 154.5, 195.3,
     &   152.2, 193.8, 149.9, 192.5, 147.8, 191.5, 145.7, 190.6,
     &   143.7, 189.8, 141.8, 189.2, 140.0, 188.6, 138.3, 188.1,
     &   136.6, 187.6, 135.1, 187.2, 133.6, 186.9, 132.2, 186.5,
     &   138.8, 278.2, 139.9, 278.5, 141.0, 278.8, 142.1, 279.2,
     &   143.2, 279.6, 144.4, 280.0, 145.6, 280.4, 146.9, 281.0,
     &   148.2, 281.5, 149.5, 282.2, 150.9, 282.8, 152.2, 283.6,
     &   153.7, 284.5, 155.1, 285.5, 156.6, 286.6, 158.1, 287.9,
     &   159.6, 289.5, 161.1, 291.3, 162.7, 293.4, 164.2, 296.0,
     &   165.7, 299.2, 167.2, 303.1, 168.7, 308.2, 170.0, 314.6/
C_CG
C_CG
      DATA FANIDM /.FALSE./
      DATA FNTADM /.FALSE./
      END
*DK US0
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  US0
CH
      SUBROUTINE US0
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C ---------------------------------------------------------------------
*CA DALLCO
C     INCLUDE 'DALI_CF.INC'
C------------------------------------------------------------------- DO
      COMMON /DOPR1T/ TPLNDO(-2:11)
      COMMON /DOPR2T/ TAREDO( 0:14)
      COMMON /DOPR3T/ TZOODO( 0: 1)
      COMMON /DOPR4T/ TPICDO,THLPDO,TNAMDO
      CHARACTER *2 TPLNDO,TAREDO,TZOODO,TPICDO,THLPDO,TNAMDO
C
C-------------------End of DALI_CF commons----------------
      EXTERNAL SIND,COSD,ACOSD,TAND,ATAND,ATAN2D! Not implemented in g77
CH
      ENTRY US1
CH
      ENTRY US2
CH
      ENTRY US3
CH
      ENTRY US4
CH
      ENTRY US5
CH
C      ENTRY US6
CH
      ENTRY US7
CH
      ENTRY US8
CH
      ENTRY US9
CH
      ENTRY DCJ
CH
      CALL DWRT('> non existent user processor for '//TPICDO)
      END
*DK US0D
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  US0D
CH
      SUBROUTINE US0D
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------

C
C    Created by H.Drevermann                   28-JUL-1988
C
C ---------------------------------------------------------------------
*CA DALLCO
C     INCLUDE 'DALI_CF.INC'
C
C-------------------End of DALI_CF commons----------------
      EXTERNAL SIND,COSD,ACOSD,TAND,ATAND,ATAN2D! Not implemented in g77
CH
      ENTRY US1D
CH
      ENTRY US2D
CH
      ENTRY US3D
CH
      ENTRY US4D
CH
      ENTRY US5D
CH
      ENTRY US6D
CH
      ENTRY US7D
CH
      ENTRY US8D
CH
      ENTRY US9D
CH
      END


      SUBROUTINE US6
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
C------------------------------------------------------------------- DV
      COMMON /DVARIC/
     1      IVXXDV,IVYYDV,IVZZDV,IVRODV,IVFIDV,IVTEDV,IVDIDV,IVRBDV,
     1      IVLVDV,IVDFDV,IVDTDV,IVENDV,IVIIDV,IVJJDV,IVKKDV,IVNNDV,
     1      IVLLDV,IVNTDV,IVU1DV,IVU2DV
C------------------------------------------------------------------- DG
      COMMON /DGRDEC/
     1      HMINDG(0:14),VMINDG(0:14),
     1      HLOWDG(0:14),VLOWDG(0:14),HHGHDG(0:14),VHGHDG(0:14)
      COMMON /DGRDET/ TGRADG
      CHARACTER *3 TGRADG
C------------------------------------------------------------------- DT
      PARAMETER (MTRKDT=401,MMCTDT=500)
      COMMON /DTRK1C/ FCUTDT,FNOTDT(   0   :MTRKDT),
     &                FCUHDT,FNOHDT(-MTRKDT:MTRKDT)
      LOGICAL FCUTDT,FNOTDT,FCUHDT,FNOHDT
      COMMON /DTRK2C/ VTX1DT(3),VTX2DT(3),PTRADT(3),CLTMDT(3),FVTXDT
      LOGICAL FVTXDT
      COMMON /DTRK6C/ FRFTDT(6),XYZVDT(3)
      COMMON /DTRK7C/ N3DIDT,FZTRDT,NSVXDT,KINVDT(2,MTRKDT)
      LOGICAL FZTRDT
      COMMON /DTRK3C/ MODEDT,TPHEDT(5)
      COMMON /DTRK4C/ FMCCDT,FMNTDT(MMCTDT),FMVXDT(100)
      LOGICAL FMCCDT,FMNTDT,FMVXDT
      COMMON /DTRK5C/ SZVXDT,NCVXDT
      COMMON /DTRK1T/ TGFTDT,TGTLDT,TGCLDT
      CHARACTER *4 TGFTDT,TGTLDT,TGCLDT
C PARAMETER (MTRKDT=100,MMCTDT=500) is found in:
C C_DALBC.FOR,C_DALBD.FOR,C_DALBH.FOR,C_DALBM.FOR,C_DALBR.FOR,C_DALBT.FOR
C C_DALBV.FOR,C_DALBX.FOR,C_DALBY.FOR,C_DALIA.FOR,C_DALID.FOR,C_DALIR.FOR
C C_DALIS.FOR,C_DALIV.FOR,N_DALBA.FOR,N_DALBF.FOR,US3.FOR
C------------------------------------------------------------------- DV
C      PARAMETER (MTPCDV=2752)
      PARAMETER (MTPCDV=50000)
      COMMON /DVSTPC/ VTPCDV(11,MTPCDV)
      DIMENSION NTPCDV(11,MTPCDV)
      EQUIVALENCE (VTPCDV,NTPCDV)
      PARAMETER (MITCDV=960)
      COMMON /DVSITC/ VITCDV(11,MITCDV)
      DIMENSION NITCDV(11,MITCDV)
      EQUIVALENCE (VITCDV,NITCDV)
C------------------------------------------------------------------- DW
      COMMON /DWORKT/ TXTADW
      CHARACTER *80 TXTADW
      CHARACTER *1 TXT1DW(80)
      EQUIVALENCE (TXTADW,TXT1DW)
C
C-------------------End of DALI_CF commons----------------
      EXTERNAL SIND,COSD,ACOSD,TAND,ATAND,ATAN2D! Not implemented in g77

      DATA DV/13./ DH/220./

      CALL DQFWIA(8)
      CALL DV0(TPCODB,NUM1,NUM2,FOUT)
      CALL=DVTPST(IVXXDV,IVXX)
      CALL=DVTPST(IVYYDV,IVYY)
      CALL=DVTPST(IVZZDV,IVZZ)
      CALL=DVTPST(IVNTDV,IVNT)
      CALL DGLEVL(1)
      V=VHGHDG(12)
      L=0
      DO 200 K=NUM1,NUM2
        IF(FCUHDT) THEN
          IF(FNOHDT(NTPCDV(IVNT,K))) GO TO 200
        END IF
        I=MOD(L,3)
        IF(I.EQ.0) V=V-DV
        WRITE(TXTADW,1000) NTPCDV(IVNT,K),VTPCDV(IVXX,K),
     &    VTPCDV(IVYY,K),VTPCDV(IVZZ,K)
 1000   FORMAT(I4,3F7.1)
        H=HMINDG(12)+I*DH
        CALL DGTEXT(H,V,TXTADW,25)
        L=L+1
  200 CONTINUE
      END
