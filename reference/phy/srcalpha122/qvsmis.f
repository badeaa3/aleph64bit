      SUBROUTINE QVSMIS(ITK,VTX,D0V,Z0V,R3D)
CKEY  QVSRCH / INTERNAL
C ----------------------------------------------------------------------
C! Calculates vertex miss distance
C  Author : T. MATTISON  U.A.BARCELONA/SLAC  1 DECEMBER 1992
C
C  Input Arguments :
C  *  ITK IS ALPHA TRACK NUMBER
C  *  VTX() IS VERTEX COORDINATES
C  Output Arguments :
C  *  D0V IS D0 WITH RESPECT TO VERTEX
C  *  Z0V IS Z0 WITH RESPECT TO VERTEX
C  *  R3D IS 3D MISS DISTANCE
C
C ----------------------------------------------------------------------
      DIMENSION VTX(3)
C-------------------- /QCDE/ --- COMMONs, DIMENSIONs, etc. ------------
C Start of QCDESH ----------------------- Description in QDATA ---------
      PARAMETER (KCQDET=34, KCQFPA=8, KCQPAR=10, KCQVEC=73, KCQVRT=30,
     & KHE=1, KHMU=2, KHPI=3, KHK=4, KHP=5, KHPHOT=1, KHNHAD=2,
     & KMONTE=-2, KRECO=-1, KLOCKM=14, KSOVT=1, KSCHT=2, KSIST=3,
     & KSAST=4, KSEHT=5, KSV0T=6, KSDCT=7, KSEFT=8, KSNET=9, KSGAT=10,
     & KSJET=11, KSMCT=12, KSREV=13,
     & KSMCV=14, KUNDEF=-12344321, QQPI=3.141593, QQE=2.718282,
     & QQ2PI=QQPI*2., QQPIH=QQPI/2., QQRADP=180./QQPI, QQC=2.997925E10,
     & QQH=6.582173E-25, QQHC=QQH*QQC, QQIRP=.00029979)
      CHARACTER CQDATE*8, CQDWRK*80, CQFHIS*80, CQFOUT*80, CQFWRK*80,
     & CQHTIT*80, CQSEC*3, CQTIME*8, CQUNPK*30, CQVERS*6, CQRLST*800,
     & CQELST*800
      COMMON /QCDEC/ CQDATE, CQDWRK, CQFHIS, CQFOUT, CQFWRK, CQHTIT,
     & CQSEC(14), CQTIME, CQUNPK, CQVERS, CQRLST, CQELST
      COMMON /QCDE/ QELEP, QMFLD ,QMFLDC, QTIME, QTIMEI, QTIMEL,
     & QTIMES, QTIMET, QDHEEC, QDHEEL, QDHEPF, QDHETH, QDHEPH, QDHEEF,
     & QDHEET, QDHET1, QDHEP1, QDHET2, QDHEP2, QDHEE1, QDHEE2, QDHEE3,
     & QKEVRN, QKEVWT, QVXNOM, QVYNOM, QVZNOM, QVXNSG, QVYNSG, QVZNSG,
     & QINLUM, QRINLN, QRINLU, QDBOFS, QEECWI(36), QVXBOM, QVYBOM,
     & QSILUM, QRSLLU, QRSLBK, QRSLEW , QVTXBP(3), QVTEBP(3), QVTSBP(3)
      COMMON /QCDE/  KFOVT, KLOVT, KNOVT, KFCHT, KLCHT, KNCHT, KFIST,
     & KLIST, KNIST, KFAST, KLAST, KNAST, KFEHT, KLEHT, KNEHT, KFV0T,
     & KLV0T, KNV0T, KFDCT, KLDCT, KNDCT, KFEFT, KLEFT, KNEFT, KFNET,
     & KLNET, KNNET, KFGAT, KLGAT, KNGAT, KFJET, KLJET, KNJET, KFMCT,
     & KLMCT, KNMCT, KFREV, KLREV, KNREV, KFMCV, KLMCV, KNMCV, KLUST,
     & KLUSV, KFFRT, KLFRT, KFFRV, KLFRV, KNRET, KNCOT, KFFRD,
     & KLFJET,KLLJET,KLNJET
      COMMON /QCDE/ KBIT(32), KCLACO(KCQFPA), KCLAFR(KCQFPA), KCLARM
     & (KCQFPA), KDEBUG, KEVT, KEXP, KFFILL, KFEOUT, KJOPTN(2,2),
     & KLEOUT, KLROUT, KLOCK0(KLOCKM,2), KLOCK1(KLOCKM,2), KLOCK2(
     & KLOCKM,2), KMATIX(6,6), KMQFPA, KNEFIL, KNEOUT, KNEVT, KNPAST,
     & KNQDET, KNQFPA, KNQLIN, KNQMTX, KNQPAR, KNQPST, KNREIN, KNREOU,
     & KOQDET, KOQFPA, KOQLIN, KOQMTL, KOQMTS, KOQPAR, KOQPBT, KOQPLI,
     & KOQTRA, KOQVEC, KOQVRT, KQPAR, KQVEC, KQVRT, KQWRK, KQZER, KRUN,
     & KSTATU, KTDROP, KUCARD, KUCONS, KUHIST, KUINPU, KUOUTP, KUPRNT,
     & KUPTER, KDEBU1, KDEBU2, KNWRLM, KEFOPT, KUEDIN, KUEDOU, KURTOX,
     & KUCAR2, KNHDRN, KNBHAB, KSBHAB, KRSLLQ, KRSLNB
      COMMON /QCDE/ INDATA
      COMMON /QCDE/ KRINNE, KRINNF, KRINDC, KRINDQ, KRINNZ, KRINNB,
     & KRINBM, KRINFR, KRINLR, KRINLF
      COMMON /QCDE/ KEVERT, KEVEDA, KEVETI, KEVEMI(4), KEVETY, KEVEES,
     & KDHEFP, KDHENP, KDHENM, KKEVNT, KKEVNV, KKEVID, KDHENX, KDHENV,
     & KDHENJ, KREVDS, KXTET1, KXTET2, KXTEL2, KXTCGC, KXTCLL, KXTCBN,
     & KXTCCL, KXTCHV, KXTCEN, KCLASW, KERBOM, KBPSTA
      DIMENSION KLOCUS(3,14)
      EQUIVALENCE (KLOCUS(1,1),KFOVT), (KFOVT,KFRET), (KLIST,KLRET),
     & (KFIST,KFCOT), (KLAST,KLCOT)
      COMMON /QCDE/ XCOPYJ, XFLIAC, XHISTO, XLREV(2), XLREV2(2), XMCEV,
     & XMINI, XSYNTX, XWREVT, XWRRUN, XFILMC, XFILCH, XFILV0, XFILCO,
     & XFILEF, XFILPC, XFILGA, XFILJE,
     & XPRHIS, XFILL, XVITC, XVTPC, XVECAL, XVLCAL, XVTPCD,
     & XVSATR, XVHCAL, XHVTRG, XSREC, XWMINI, XIOKLU, XIOKSI, XFRF2,
     & XNSEQ, XVDOK, XFRF0, XFMUID, XFILEM, XWNANO, XROKSI, XGETBP,
     & XJTHRU
      LOGICAL XCOPYJ, XFLIAC, XHISTO, XLREV, XLREV2, XMCEV, XMINI,
     & XSYNTX, XWREVT, XWRRUN, XFILMC, XFILCH, XFILV0, XFILCO, XFILEF,
     & XFILPC, XPRHIS, XFILL, XVITC, XVTPC, XVECAL, XVLCAL, XVTPCD,
     & XVSATR, XVHCAL, XHVTRG, XSREC, XWMINI, XIOKLU, XFRF2, XFILJE,
     & XNSEQ, XFILGA, XVDOK, XFRF0, XFMUID, XFILEM, XWNANO, XIOKSI,
     & XROKSI, XGETBP, XJTHRU
C-------------------- /NANCOM/ --- NanoDst steering -------------------
C! XNANO   .TRUE. if input is a NanoDst (in NANO or EPIO format, dependi
C!                   XNANOR)
C!
      LOGICAL XNANO
      COMMON /NANCOM/XNANO
C--------------------- end of NANCOM ----------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
      INTEGER IW
      REAL RW(10000)
      COMMON /BCS/ IW(10000)
      EQUIVALENCE (RW(1),IW(1))
C------------------ /QCNAMI/ --- name indices -------------------------
      COMMON /QCNAMI/ NAAFID,NAAJOB,NAASEV,NABCNT,NABHIT,NABOMB,
     1 NABOME,NABOMP,NABOMR,NABPTR,NADCAL,NADCRL,NADECO,NADEID,NADENF,
     2 NADEVT,NADEWI,NADFMC,NADFOT,NADGAM,NADHCO,NADHEA,NADHRL,NADJET,
     3 NADMID,NADMJT,NADMUO,NADNEU,NADPOB,NADRES,NADTBP,NADTMC,NADTRA,
     4 NADVER,NADVMC,NAECRQ,NAECTE,NAEGID,NAEGPC,NAEIDT,NAEJET,NAERRF,
     5 NAETDI,NAETKC,NAEVEH,NAEWHE,NAFICL,NAFKIN,NAFPOI,NAFPOL,NAFRFT,
     6 NAFRID,NAFRTL,NAFSTR,NAFTCL,NAFTCM,NAFTOC,NAFTTM,NAFVCL,NAFVER,
     7 NAFZFR,NAHCCV,NAHCTE,NAHINF,NAHMAD,NAHPDI,NAHROA,NAHSDA,NAHTUB,
     8 NAIASL,NAIPJT,NAIRJT,NAITCO,NAITMA,NAIXTR,NAIZBD,NAJBER,NAJEST,
     9 NAJSUM,NAKEVH,NAKINE,NAKJOB,NAKLIN,NAKPOL,NAKRUN,NALIDT,NALOLE,
     A NALUPA,NAMCAD,NAMHIT,NAMTHR,NAMUDG,NAMUEX,NAOSTS,NAPART,NAPASL,
     B NAPCHY,NAPCOB,NAPCOI,NAPCPA,NAPCQA,NAPCRL,NAPECO,NAPEHY,NAPEID,
     C NAPEMH,NAPEPT,NAPEST,NAPEWI,NAPFER,NAPFHR,NAPFRF,NAPFRT,NAPHCO,
     D NAPHER,NAPHHY,NAPHMH,NAPHST,NAPIDI,NAPITM,NAPLID,NAPLPD,NAPLSD,
     E NAPMSK,NAPNEU,NAPPDS,NAPPOB,NAPPRL,NAPRTM,NAPSCO,NAPSPO,NAPSTR,
     F NAPT2X,NAPTBC,NAPTCO,NAPTEX,NAPTMA,NAPTML,NAPTNC,NAPTST,NAPVCO,
     G NAPYER,NAPYFR,NAPYNE,NAQDET,NAQFPA,NAQLIN,NAQMTL,NAQMTS,NAQPAR,
     H NAQPBT,NAQPLI,NAQTRA,NAQVEC,NAQVRT,NAQWRK,NAQZER,NAREVH,NARHAH,
     I NARTLO,NARTLS,NARUNH,NARUNR,NASFTR,NATEXS,NATGMA,NATMTL,NATPCO,
     J NAVCOM,NAVCPL,NAVDCO,NAVDHT,NAVDXY,NAVDZT,NAVERT,NAVFHL,NAVFLG,
     K NAVFPH,NAVHLS,NAVPLH,NAX1AD,NAX1SC,NAX1TI,NAX2DF,NAX3EC,NAX3EW,
     L NAX3HC,NAX3IT,NAX3L2,NAX3LU,NAX3TM,NAX3TO,NAX3TP,NAX3X3,NAXTBN,
     M NAXTBP,NAXTCN,NAXTEB,NAXTOP,NAXTRB,NAYV0V,NAZPFR,NAEFOL,NAMUID,
     N NAPGID,NAPGPC,NAPGAC,NAPMSC,NAPTHR,NANBIP,NAPDLT,NAPMLT,NAPLJT
C--------------------- end of QCNAMI ----------------------------------
C------------------ /QQQQJJ/ --- HAC parameters for ALPHA banks -------
      PARAMETER (JQVEQX= 1,JQVEQY= 2,JQVEQZ= 3,JQVEQE= 4,JQVEQM= 5,
     & JQVEQP= 6,JQVECH= 7,JQVETN= 8,JQVESC= 9,JQVEKS=10,JQVECL=11,
     & JQVEPA=12,JQVEQD=13,JQVENP=14,JQVESP=15,JQVEOV=16,JQVEEV=17,
     & JQVEND=18,JQVEDL=19,JQVENO=20,JQVEOL=21,JQVENM=22,JQVEML=23,
     & JQVEBM=24,JQVELK=38,JQVEDB=39,JQVEZB=40,JQVESD=41,JQVESZ=42,
     & JQVECB=43,JQVEEM=44,JQVECF=54,JQVEEW=55,JQVEUS=56)
      PARAMETER ( JQVRVX=1,JQVRVY=2,JQVRVZ=3,JQVRVN=4,JQVRTY=5,
     1   JQVRIP=6,JQVRND=7,JQVRDL=8,JQVRAY=9,JQVRAF=10,JQVREM=11,
     2   JQVRCF=17,JQVRET=18)
      PARAMETER ( JQDEAF= 1,JQDEAL= 2,JQDENT= 3,JQDEAT= 4,JQDELT= 8,
     &  JQDEAE= 9,JQDEAH=10,JQDEAM=11,JQDECF=12,JQDEEC=13,JQDEHC=14,
     &  JQDEET=15,JQDEFI=16,JQDENF=17,JQDEFL=18,JQDENE=19,JQDEEL=20,
     &  JQDENH=21,JQDEHL=22,JQDELH=23,JQDEEF=24,JQDEPC=25,JQDEEG=26,
     &  JQDEMU=27,JQDEDX=28,JQDEPG=29,JQDEPD=30,JQDEPM=31)
      PARAMETER ( JQPAGN=1, JQPANA=2, JQPACO=5, JQPAMA=6, JQPACH=7,
     & JQPALT=8,JQPAWI=9,JQPAAN=10)
C--------------------- end of QCDESH ----------------------------------
      EXTERNAL CQPART, CQTPN, XCEQAN, XLUMOK, XPEQAN, XPEQOR, XPEQU,
     & XVDEOK, LLUMOK, SLUMOK
      CHARACTER * 12 CQPART, CQTPN
      LOGICAL XCAL, XCEQAN, XCEQOR, XCEQU, XECAL, XEID, XFRF, XHCAL,
     & XHMA, XLOCK, XLOCKN, XMC, XLUMOK, XMCA, XPEO, XPHO, XPEQAN,
     & XPEQOR, XPEQU, XSAME, XSIG, XTEX, XPEC, XPEP, XPHC, XYV0,
     & XFRIQF, XEFO, XPCQ, XEGP, XMUI, XVDEOK, XPGP, LLUMOK, SLUMOK,
     & XPGAC, XLEPTG, XLEPTH
      REAL PI, TWOPI, PIBY2, PIBY3, PIBY4, PIBY6, PIBY8, PIBY12
      REAL RADEG, DEGRA
      REAL CLGHT, ALDEDX
      INTEGER NBITW, NBYTW, LCHAR
      PARAMETER (PI=3.141592653589)
      PARAMETER (RADEG=180./PI, DEGRA=PI/180.)
      PARAMETER (TWOPI = 2.*PI , PIBY2 = PI/2., PIBY4 = PI/4.)
      PARAMETER (PIBY6 = PI/6. , PIBY8 = PI/8.)
      PARAMETER (PIBY12= PI/12., PIBY3 = PI/3.)
      PARAMETER (CLGHT = 29.9792458, ALDEDX = 0.000307)
      PARAMETER (NBITW = 32 , NBYTW = NBITW/8 , LCHAR = 4)
      INTEGER JEFOPX,JEFOPY,JEFOPZ,JEFOEW,JEFOWE,JEFOTY,JEFOLE,JEFOLT,
     +          JEFOLH,JEFOLC,JEFOLJ,LEFOLA
      PARAMETER(JEFOPX=1,JEFOPY=2,JEFOPZ=3,JEFOEW=4,JEFOWE=5,JEFOTY=6,
     +          JEFOLE=7,JEFOLT=8,JEFOLH=9,JEFOLC=10,JEFOLJ=11,
     +          LEFOLA=11)
      INTEGER JEGPPX,JEGPPY,JEGPPZ,JEGPR1,JEGPR2,JEGPF4,JEGPDM,JEGPST,
     +          JEGPQU,JEGPPE,LEGPCA
      PARAMETER(JEGPPX=1,JEGPPY=2,JEGPPZ=3,JEGPR1=4,JEGPR2=5,JEGPF4=6,
     +          JEGPDM=7,JEGPST=8,JEGPQU=9,JEGPPE=10,LEGPCA=10)
      INTEGER JEIDIF,JEIDR1,JEIDR2,JEIDR3,JEIDR4,JEIDR5,JEIDR6,JEIDR7,
     +          JEIDEC,JEIDIP,JEIDE1,JEIDE2,JEIDE3,JEIDFR,JEIDPE,LEIDTA
      PARAMETER(JEIDIF=1,JEIDR1=2,JEIDR2=3,JEIDR3=4,JEIDR4=5,JEIDR5=6,
     +          JEIDR6=7,JEIDR7=8,JEIDEC=9,JEIDIP=10,JEIDE1=11,
     +          JEIDE2=12,JEIDE3=13,JEIDFR=14,JEIDPE=15,LEIDTA=15)
      INTEGER JFRFIR,JFRFTL,JFRFP0,JFRFD0,JFRFZ0,JFRFAL,JFRFEM,JFRFC2,
     +          JFRFDF,JFRFNO,LFRFTA
      PARAMETER(JFRFIR=1,JFRFTL=2,JFRFP0=3,JFRFD0=4,JFRFZ0=5,JFRFAL=6,
     +          JFRFEM=7,JFRFC2=28,JFRFDF=29,JFRFNO=30,LFRFTA=30)
      INTEGER JFRIBP,JFRIDZ,JFRIBC,JFRIDC,JFRIPE,JFRIPM,JFRIPI,JFRIPK,
     +          JFRIPP,JFRINK,JFRIQF,LFRIDA
      PARAMETER(JFRIBP=1,JFRIDZ=2,JFRIBC=3,JFRIDC=4,JFRIPE=5,JFRIPM=6,
     +          JFRIPI=7,JFRIPK=8,JFRIPP=9,JFRINK=10,JFRIQF=11,
     +          LFRIDA=11)
      INTEGER JFRTIV,JFRTNV,JFRTII,JFRTNI,JFRTNE,JFRTIT,JFRTNT,JFRTNR,
     +          LFRTLA
      PARAMETER(JFRTIV=1,JFRTNV=2,JFRTII=3,JFRTNI=4,JFRTNE=5,JFRTIT=6,
     +          JFRTNT=7,JFRTNR=8,LFRTLA=8)
      INTEGER JHMANF,JHMANE,JHMANL,JHMAMH,JHMAIG,JHMAED,JHMACS,JHMAND,
     +          JHMAIE,JHMAIT,JHMAIF,JHMATN,LHMADA
      PARAMETER(JHMANF=1,JHMANE=2,JHMANL=3,JHMAMH=4,JHMAIG=5,JHMAED=6,
     +          JHMACS=7,JHMAND=8,JHMAIE=9,JHMAIT=10,JHMAIF=11,
     +          JHMATN=12,LHMADA=12)
      INTEGER JMCANH,JMCADH,JMCADC,JMCAAM,JMCAAC,JMCATN,LMCADA
      PARAMETER(JMCANH=1,JMCADH=3,JMCADC=5,JMCAAM=7,JMCAAC=8,JMCATN=9,
     +          LMCADA=9)
      INTEGER JMUIIF,JMUISR,JMUIDM,JMUIST,JMUITN,LMUIDA
      PARAMETER(JMUIIF=1,JMUISR=2,JMUIDM=3,JMUIST=4,JMUITN=5,LMUIDA=5)
      INTEGER JPCQNA,JPCQPX,JPCQPY,JPCQPZ,JPCQEN,LPCQAA
      PARAMETER(JPCQNA=1,JPCQPX=2,JPCQPY=3,JPCQPZ=4,JPCQEN=5,LPCQAA=5)
      INTEGER JPDLPA,JPDLJT,JPDLPI,JPDLPE,JPDLVP,JPDLFR,LPDLTA
      PARAMETER (JPDLPA=1,JPDLJT=2,JPDLPI=3,JPDLPE=4,JPDLVP=5,
     &           JPDLFR=6,LPDLTA=6)
      INTEGER JPECER,JPECE1,JPECE2,JPECTH,JPECPH,JPECEC,JPECKD,JPECCC,
     +          JPECRB,JPECPC,LPECOA
      PARAMETER(JPECER=1,JPECE1=2,JPECE2=3,JPECTH=4,JPECPH=5,JPECEC=6,
     +          JPECKD=7,JPECCC=8,JPECRB=9,JPECPC=10,LPECOA=10)
      INTEGER JPEPT1,JPEPP1,JPEPT3,JPEPP3,LPEPTA
      PARAMETER(JPEPT1=1,JPEPP1=2,JPEPT3=3,JPEPP3=4,LPEPTA=4)
      INTEGER JPGAEC,JPGATC,JPGAPC,JPGAR1,JPGAR2,JPGAF4,JPGADM,JPGAST,
     +          JPGAQU,JPGAQ1,JPGAQ2,JPGAM1,JPGAM2,JPGAMA,JPGAER,JPGATR,
     +          JPGAPR,JPGAEF,JPGAGC,JPGAZS,JPGAPL,JPGAPH,JPGAPN,JPGAFA,
     +          JPGAPE,LPGACA
      PARAMETER(JPGAEC=1,JPGATC=2,JPGAPC=3,JPGAR1=4,JPGAR2=5,JPGAF4=6,
     +          JPGADM=7,JPGAST=8,JPGAQU=9,JPGAQ1=10,JPGAQ2=11,
     +          JPGAM1=12,JPGAM2=13,JPGAMA=14,JPGAER=15,JPGATR=16,
     +          JPGAPR=17,JPGAEF=18,JPGAGC=19,JPGAZS=20,JPGAPL=21,
     +          JPGAPH=22,JPGAPN=23,JPGAFA=24,JPGAPE=25,LPGACA=25)
      INTEGER JPGPEC,JPGPTC,JPGPPC,JPGPR1,JPGPR2,JPGPF4,JPGPDM,JPGPST,
     +          JPGPQU,JPGPQ1,JPGPQ2,JPGPM1,JPGPM2,JPGPMA,JPGPER,JPGPTR,
     +          JPGPPR,JPGPPE,LPGPCA
      PARAMETER(JPGPEC=1,JPGPTC=2,JPGPPC=3,JPGPR1=4,JPGPR2=5,JPGPF4=6,
     +          JPGPDM=7,JPGPST=8,JPGPQU=9,JPGPQ1=10,JPGPQ2=11,
     +          JPGPM1=12,JPGPM2=13,JPGPMA=14,JPGPER=15,JPGPTR=16,
     +          JPGPPR=17,JPGPPE=18,LPGPCA=18)
      INTEGER JPHCER,JPHCTH,JPHCPH,JPHCEC,JPHCKD,JPHCCC,JPHCRB,JPHCNF,
     +          JPHCPC,LPHCOA
      PARAMETER(JPHCER=1,JPHCTH=2,JPHCPH=3,JPHCEC=4,JPHCKD=5,JPHCCC=6,
     +          JPHCRB=7,JPHCNF=8,JPHCPC=9,LPHCOA=9)
      INTEGER JPMLFL,JPMLPO,JPMLCH,JPMLSP,JPMLLE,JPMLME,JPMLKT,JPMLFR,
     +          LPMLTA
      PARAMETER (JPMLFL=1,JPMLPO=2,JPMLCH=3,JPMLSP=4,JPMLLE=5,
     &           JPMLME=6,JPMLKT=7,JPMLFR=8,LPMLTA=8)
      INTEGER JTEXSI,JTEXTM,JTEXTL,JTEXNS,JTEXAD,JTEXTN,JTEXSF,LTEXSA
      PARAMETER(JTEXSI=1,JTEXTM=2,JTEXTL=3,JTEXNS=4,JTEXAD=5,JTEXTN=6,
     +          LTEXSA=6)
      INTEGER JYV0K1,JYV0K2,JYV0VX,JYV0VY,JYV0VZ,JYV0VM,JYV0PX,JYV0PY,
     +          JYV0PZ,JYV0PM,JYV0X1,JYV0X2,JYV0XM,JYV0C2,JYV0IC,JYV0P1,
     +          JYV0P2,JYV0EP,JYV0DM,JYV0S1,JYV0S2,LYV0VA
      PARAMETER(JYV0K1=1,JYV0K2=2,JYV0VX=3,JYV0VY=4,JYV0VZ=5,JYV0VM=6,
     +          JYV0PX=12,JYV0PY=13,JYV0PZ=14,JYV0PM=15,JYV0X1=21,
     +          JYV0X2=22,JYV0XM=23,JYV0C2=26,JYV0IC=27,JYV0P1=28,
     +          JYV0P2=31,JYV0EP=34,JYV0DM=55,JYV0S1=56,JYV0S2=57,
     +          LYV0VA=57)
C--------------------- end of QCDE ------------------------------------
C-------------------- /QMACRO/ --- statement functions ----------------
C - # of words/row in bank with index ID
      LCOLS(ID) = IW(ID+LMHCOL)
C - # of rows in bank with index ID
      LROWS(ID) = IW(ID+LMHROW)
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
C-------------------- /QCFUNC/ --- statement functions for ALPHA banks
      KJQDET(KI)=IW(KOQVEC+KI*KCQVEC+JQVEQD)
      QSQT(QF)=SIGN(SQRT(ABS(QF)),QF)
      QP(KI)=RW(KOQVEC+KI*KCQVEC+JQVEQP)
      QX(KI)=RW(KOQVEC+KI*KCQVEC+JQVEQX)
      QY(KI)=RW(KOQVEC+KI*KCQVEC+JQVEQY)
      QZ(KI)=RW(KOQVEC+KI*KCQVEC+JQVEQZ)
      QE(KI)=RW(KOQVEC+KI*KCQVEC+JQVEQE)
      QM(KI)=RW(KOQVEC+KI*KCQVEC+JQVEQM)
      QCH(KI)=RW(KOQVEC+KI*KCQVEC+JQVECH)
      KCH(KI)=NINT (QCH(KI))
      QCT(KI)=QZ(KI)/QP(KI)
      QDB(KI)=RW(KOQVEC+KI*KCQVEC+JQVEDB)
      QZB(KI)=RW(KOQVEC+KI*KCQVEC+JQVEZB)
      QDBS2(KI)=RW(KOQVEC+KI*KCQVEC+JQVESD)
      QZBS2(KI)=RW(KOQVEC+KI*KCQVEC+JQVESZ)
      QBC2(KI)=RW(KOQVEC+KI*KCQVEC+JQVECB)
      QSIG(KI,KI1,KI2)=RW(KOQVEC+KI*KCQVEC+KMATIX(KI1,KI2)+JQVEEM)
      XSIG(KI)=RW(KOQVEC+KI*KCQVEC+JQVEEM).GE.0.
      QSMAT(KI,KI1)=RW(KOQVEC+KI*KCQVEC+KI1+JQVEEM)
      QSIGX(KI)=QSQT(QSMAT(KI,0))
      QSIGY(KI)=QSQT(QSMAT(KI,2))
      QSIGZ(KI)=QSQT(QSMAT(KI,5))
      QSIGEE(KI)=RW(KOQVEC+KI*KCQVEC+JQVEEM+9)
      QSIGE(KI)=QSQT(QSIGEE(KI))
      QSIGPP(KI)=(QX(KI)**2*QSMAT(KI,0)+QY(KI)**2*QSMAT(KI,2)+
     & QZ(KI)**2*QSMAT(KI,5)+2.*(QX(KI)*(QY(KI)*QSMAT(KI,1)+
     & QZ(KI)*QSMAT(KI,3))+QY(KI)*QZ(KI)*QSMAT(KI,4)))/QP(KI)**2
      QSIGP(KI)=QSQT(QSIGPP(KI))
      QSIGMM(KI)=QM(KI)*(QE(KI)**2*QSMAT(KI,9)+QX(KI)**2*QSMAT(KI,0)+
     & QY(KI)**2*QSMAT(KI,2)+QZ(KI)**2*QSMAT(KI,5)+2.*(QX(KI)*(QY(KI)*
     & QSMAT(KI,1)+QZ(KI)*QSMAT(KI,3))+QY(KI)*QZ(KI)*QSMAT(KI,4)-
     & QE(KI)*(QX(KI)*QSMAT(KI,6)+QY(KI)*QSMAT(KI,7)+
     & QZ(KI)*QSMAT(KI,8))))/AMAX1(QM(KI)**3,1.E-16)
      QSIGM(KI)=QSQT(QSIGMM(KI))
      QMCHIF(KI)=RW(KOQVEC+KI*KCQVEC+JQVECF)
      QPH(KI)=ATG(QY(KI),QX(KI))
      QPT(KI)=SQRT(QX(KI)**2+QY(KI)**2)
      KTN(KI)=IW(KOQVEC+KI*KCQVEC+JQVETN)
      KMC(KI)=KCLARM(IW(KOQVEC+KI*KCQVEC+JQVECL))
      KBMASK(KI,KI1)=IW(KOQVEC+KI*KCQVEC+KI1+JQVEBM-1)
      KCALFL(KI)=IW(KJQDET(KI)+JQDECF)
      KCHGD(KI,KI1)=IW(KOQLIN+KI1+IW(KJQDET(KI)+JQDEFL))
      KCLASS(KI)=KCLACO(IW(KOQVEC+KI*KCQVEC+JQVECL))
      KDAU(KI,KI1)=IW(KOQLIN+KI1+IW(KOQVEC+KI*KCQVEC+JQVEDL))
      KECAL(KI,KI1)=IW(KOQLIN+KI1+IW(KJQDET(KI)+JQDEEL))
      KENDV(KI)=IW(KOQVEC+KI*KCQVEC+JQVEEV)
      KFOLLO(KI)=IW(KOQVEC+KI*KCQVEC+JQVENP)
C
      KHCAL(KI,KI1)=IW(KOQLIN+KI1+IW(KJQDET(KI)+JQDEHL))
      KLUNDS(KI)=IW(KOQVEC+KI*KCQVEC+JQVEKS)
      KNCHGD(KI)=IW(KJQDET(KI)+JQDENF)
      KNECAL(KI)=IW(KJQDET(KI)+JQDENE)
      KNHCAL(KI)=IW(KJQDET(KI)+JQDENH)
      KNMOTH(KI)=IW(KOQVEC+KI*KCQVEC+JQVENO)
      KMOTH(KI,KI1)=IW(KOQLIN+KI1+IW(KOQVEC+KI*KCQVEC+JQVEOL))
      KMTCH(KI,KI1)=IW(KOQMTL+KI1+IW(KOQVEC+KI*KCQVEC+JQVEML))
      KNDAU(KI)=IW(KOQVEC+KI*KCQVEC+JQVEND)
      KNMTCH(KI)=IW(KOQVEC+KI*KCQVEC+JQVENM)
      KORIV(KI)=IW(KOQVEC+KI*KCQVEC+JQVEOV)
      KSAME(KI)=IW(KOQVEC+KI*KCQVEC+JQVESP)
      KSMTCH(KI,KI1)=IW(KOQMTS+KI1+IW(KOQVEC+KI*KCQVEC+JQVEML))
      KSTABC(KI)=IW(KOQVEC+KI*KCQVEC+JQVESC)
      KTPCOD(KI)=IW(KOQVEC+KI*KCQVEC+JQVEPA)
      XLOCKN(KI,KI1)=IAND(KBMASK(KI,KI1),KLOCK0(KI1,KMC(KI))).NE.0
      XLOCK(KI)=IW(KOQVEC+KI*KCQVEC+JQVELK).NE.0.OR.XLOCKN(KI,1).OR.
     & XLOCKN(KI,2).OR.XLOCKN(KI,3).OR.XLOCKN(KI,4).OR.
     & XLOCKN(KI,5).OR.XLOCKN(KI,6).OR.XLOCKN(KI,7).OR.
     & XLOCKN(KI,8).OR.XLOCKN(KI,9).OR.XLOCKN(KI,10).OR.
     & XLOCKN(KI,11).OR.XLOCKN(KI,12).OR.XLOCKN(KI,13).OR.
     & XLOCKN(KI,14)
      XMC(KI)=KCLARM(IW(KOQVEC+KI*KCQVEC+JQVECL)).NE.1
      QRDFL(KI,KI1)=RW(KOQVEC+KI*KCQVEC+JQVEUS+KI1-1)
      KRDFL(KI,KI1)=IW(KOQVEC+KI*KCQVEC+JQVEUS+KI1-1)
      XCAL(KI)=IW(KJQDET(KI)+JQDECF).NE.0
      XECAL(KI)=IABS(IW(KJQDET(KI)+JQDECF)).EQ.1
      XHCAL(KI)=IABS(IW(KJQDET(KI)+JQDECF)).EQ.2
C
      QVX(KI)=RW(KOQVRT+KI*KCQVRT+JQVRVX)
      QVY(KI)=RW(KOQVRT+KI*KCQVRT+JQVRVY)
      QVZ(KI)=RW(KOQVRT+KI*KCQVRT+JQVRVZ)
      KVN(KI)=IW(KOQVRT+KI*KCQVRT+JQVRVN)
      KVTYPE(KI)=IW(KOQVRT+KI*KCQVRT+JQVRTY)
      KVINCP(KI)=IW(KOQVRT+KI*KCQVRT+JQVRIP)
      KVNDAU(KI)=IW(KOQVRT+KI*KCQVRT+JQVRND)
      KVYV0V(KI)=IW(KOQVRT+KI*KCQVRT+JQVRAY)
      KVFVER(KI)=IW(KOQVRT+KI*KCQVRT+JQVRAF)
      KVDAU(KI,KI1)=IW(KOQLIN+KI1+IW(KOQVRT+KI*KCQVRT+JQVRDL))
      QVEM(KI,KI1,KI2)=RW(KOQVRT+KI*KCQVRT+KMATIX(KI1,KI2)+JQVREM)
      QVCHIF(KI)=RW(KOQVRT+KI*KCQVRT+JQVRCF)
      QVDIF2(KI1,KI2)=SQRT((QVX(KI1)-QVX(KI2))**2+(QVY(KI1)-
     &QVY(KI2))**2)
      QVDIF3(KI1,KI2)=SQRT((QVX(KI1)-QVX(KI2))**2+(QVY(KI1)-
     &QVY(KI2))**2+ (QVZ(KI1)-QVZ(KI2))**2)
C
      QMSQ2(KI1,KI2)=(QE(KI1)+QE(KI2))**2-(QX(KI1)+QX(KI2))**2-
     & (QY(KI1)+QY(KI2))**2-(QZ(KI1)+QZ(KI2))**2
      QMSQ3(KI1,KI2,KI3)=(QE(KI1)+QE(KI2)+QE(KI3))**2-
     & (QX(KI1)+QX(KI2)+QX(KI3))**2-(QY(KI1)+QY(KI2)+QY(KI3))**2-
     & (QZ(KI1)+QZ(KI2)+QZ(KI3))**2
      QMSQ4(KI1,KI2,KI3,KI4)=(QE(KI1)+QE(KI2)+QE(KI3)+QE(KI4))**2-
     & (QX(KI1)+QX(KI2)+QX(KI3)+QX(KI4))**2-(QY(KI1)+QY(KI2)+
     & QY(KI3)+QY(KI4))**2-(QZ(KI1)+QZ(KI2)+QZ(KI3)+QZ(KI4))**2
      QM2(KI1,KI2)=QSQT(QMSQ2(KI1,KI2))
      QM3(KI1,KI2,KI3)=QSQT(QMSQ3(KI1,KI2,KI3))
      QM4(KI1,KI2,KI3,KI4)=QSQT(QMSQ4(KI1,KI2,KI3,KI4))
      QDMSQ(KI1,KI2)=(QE(KI1)-QE(KI2))**2-(QX(KI1)-QX(KI2))**2-
     & (QY(KI1)-QY(KI2))**2-(QZ(KI1)-QZ(KI2))**2
      QBETA(KI)=QP(KI)/QE(KI)
      QGAMMA(KI)=1./SQRT((1.-QBETA(KI))*(1.+QBETA(KI)))
      QDOT3(KI1,KI2)=QX(KI1)*QX(KI2)+QY(KI1)*QY(KI2)+QZ(KI1)*QZ(KI2)
      QDOT4(KI1,KI2)=QE(KI1)*QE(KI2)-QDOT3(KI1,KI2)
      QCOSA(KI1,KI2)=QDOT3(KI1,KI2)/(QP(KI1)*QP(KI2))
      QPPAR(KI1,KI2)=QDOT3(KI1,KI2)/QP(KI2)
      QPPER(KI1,KI2)=SQRT((QY(KI1)*QZ(KI2)-QZ(KI1)*QY(KI2))**2+
     & (QZ(KI1)*QX(KI2)-QX(KI1)*QZ(KI2))**2+
     & (QX(KI1)*QY(KI2)-QY(KI1)*QX(KI2))**2)/QP(KI2)
      XSAME(KI1,KI2)=IAND(KBMASK(KI1,1),KBMASK(KI2,1)).NE.0.OR.
     & IAND(KBMASK(KI1,2),KBMASK(KI2,2)).NE.0.OR.
     & IAND(KBMASK(KI1,3),KBMASK(KI2,3)).NE.0.OR.
     & IAND(KBMASK(KI1,4),KBMASK(KI2,4)).NE.0.OR.
     & IAND(KBMASK(KI1,5),KBMASK(KI2,5)).NE.0.OR.
     & IAND(KBMASK(KI1,6),KBMASK(KI2,6)).NE.0.OR.
     & IAND(KBMASK(KI1,7),KBMASK(KI2,7)).NE.0.OR.
     & IAND(KBMASK(KI1,8),KBMASK(KI2,8)).NE.0.OR.
     & IAND(KBMASK(KI1,9),KBMASK(KI2,9)).NE.0.OR.
     & IAND(KBMASK(KI1,10),KBMASK(KI2,10)).NE.0
C
      QCMASS(KI)=RW(KOQPAR+KI*KCQPAR+JQPAMA)
      QCCHAR(KI)=RW(KOQPAR+KI*KCQPAR+JQPACH)
      QCLIFE(KI)=RW(KOQPAR+KI*KCQPAR+JQPALT)
      QCWIDT(KI)=RW(KOQPAR+KI*KCQPAR+JQPAWI)
      XCEQOR(KI,KI1)=KTPCOD(KI).EQ.KI1.OR.
     & KTPCOD(KI).EQ.IW(KOQPAR+KI1*KCQPAR+JQPAAN)
      XCEQU(KI,KI1)=KTPCOD(KI).EQ.KI1
C    QCFDET
      XFRF(KI)=IW(KJQDET(KI)+JQDEAF).NE.KQZER
      QFRFIR(KI)=RW(IW(KJQDET(KI)+JQDEAF)+JFRFIR)
      QFRFTL(KI)=RW(IW(KJQDET(KI)+JQDEAF)+JFRFTL)
      QFRFP0(KI)=RW(IW(KJQDET(KI)+JQDEAF)+JFRFP0)
      QFRFD0(KI)=RW(IW(KJQDET(KI)+JQDEAF)+JFRFD0)
      QFRFZ0(KI)=RW(IW(KJQDET(KI)+JQDEAF)+JFRFZ0)
      QFRFAL(KI)=RW(IW(KJQDET(KI)+JQDEAF)+JFRFAL)
      QFRFEM(KI,KI1,KI2)=RW(IW(KJQDET(KI)+JQDEAF)+
     & KMATIX(KI1,KI2)+JFRFEM)
      QFRFC2(KI)=RW(IW(KJQDET(KI)+JQDEAF)+JFRFC2)
      KFRFDF(KI)=IW(IW(KJQDET(KI)+JQDEAF)+JFRFDF)
      KFRFNO(KI)=IW(IW(KJQDET(KI)+JQDEAF)+JFRFNO)
C
      KFRTNV(KI)=IW(IW(KJQDET(KI)+JQDEAL)+JFRTNV)
      KFRTNI(KI)=IW(IW(KJQDET(KI)+JQDEAL)+JFRTNI)
      KFRTNE(KI)=IW(IW(KJQDET(KI)+JQDEAL)+JFRTNE)
      KFRTNT(KI)=IW(IW(KJQDET(KI)+JQDEAL)+JFRTNT)
      KFRTNR(KI)=IW(IW(KJQDET(KI)+JQDEAL)+JFRTNR)
C
      KFRIBP(KI)=IW(IW(KJQDET(KI)+JQDEFI)+JFRIBP)
      KFRIDZ(KI)=IW(IW(KJQDET(KI)+JQDEFI)+JFRIDZ)
      KFRIBC(KI)=IW(IW(KJQDET(KI)+JQDEFI)+JFRIBC)
      KFRIDC(KI)=IW(IW(KJQDET(KI)+JQDEFI)+JFRIDC)
      QFRIPE(KI)=RW(IW(KJQDET(KI)+JQDEFI)+JFRIPE)
      QFRIPM(KI)=RW(IW(KJQDET(KI)+JQDEFI)+JFRIPM)
      QFRIPI(KI)=RW(IW(KJQDET(KI)+JQDEFI)+JFRIPI)
      QFRIPK(KI)=RW(IW(KJQDET(KI)+JQDEFI)+JFRIPK)
      QFRIPP(KI)=RW(IW(KJQDET(KI)+JQDEFI)+JFRIPP)
      QFRINK(KI)=RW(IW(KJQDET(KI)+JQDEFI)+JFRINK)
      KFRIQF(KI)=IW(IW(KJQDET(KI)+JQDEFI)+JFRIQF)
      XFRIQF(KI)=KFRIQF(KI).EQ.1.OR.KFRIQF(KI).EQ.3
C
      KNTEX(KI)=IW(KJQDET(KI)+JQDENT)
      XTEX(KI)=IW(KJQDET(KI)+JQDENT).NE.0
      KTEXSI(KI,KI1)=IW(IW(KJQDET(KI)+KI1+JQDENT)+JTEXSI)
      QTEXTM(KI,KI1)=RW(IW(KJQDET(KI)+KI1+JQDENT)+JTEXTM)
      QTEXTL(KI,KI1)=RW(IW(KJQDET(KI)+KI1+JQDENT)+JTEXTL)
      KTEXNS(KI,KI1)=IW(IW(KJQDET(KI)+KI1+JQDENT)+JTEXNS)
      QTEXAD(KI,KI1)=RW(IW(KJQDET(KI)+KI1+JQDENT)+JTEXAD)
C
      XEID(KI)=IW(KJQDET(KI)+JQDEAE).NE.KQZER
      KEIDIF(KI)=IW(IW(KJQDET(KI)+JQDEAE)+JEIDIF)
      QEIDRI(KI,KI1)=RW(IW(KJQDET(KI)+JQDEAE)+KI1+JEIDR1-1)
      QEIDEC(KI)=RW(IW(KJQDET(KI)+JQDEAE)+JEIDEC)
      KEIDIP(KI)=IW(IW(KJQDET(KI)+JQDEAE)+JEIDIP)
      QEIDEI(KI,KI1)=RW(IW(KJQDET(KI)+JQDEAE)+KI1+JEIDE1-1)
C
      XHMA(KI)=IW(KJQDET(KI)+JQDEAH).NE.KQZER
      KHMANF(KI)=IW(IW(KJQDET(KI)+JQDEAH)+JHMANF)
      KHMANE(KI)=IW(IW(KJQDET(KI)+JQDEAH)+JHMANE)
      KHMANL(KI)=IW(IW(KJQDET(KI)+JQDEAH)+JHMANL)
      KHMAMH(KI)=IW(IW(KJQDET(KI)+JQDEAH)+JHMAMH)
      KHMAIG(KI)=IW(IW(KJQDET(KI)+JQDEAH)+JHMAIG)
      QHMAED(KI)=RW(IW(KJQDET(KI)+JQDEAH)+JHMAED)
      QHMACS(KI)=RW(IW(KJQDET(KI)+JQDEAH)+JHMACS)
      KHMAND(KI)=IW(IW(KJQDET(KI)+JQDEAH)+JHMAND)
      KHMAIE(KI)=IW(IW(KJQDET(KI)+JQDEAH)+JHMAIE)
      KHMAIT(KI)=IW(IW(KJQDET(KI)+JQDEAH)+JHMAIT)
      KHMAIF(KI)=IW(IW(KJQDET(KI)+JQDEAH)+JHMAIF)
C
      XMCA(KI)=IW(KJQDET(KI)+JQDEAM).NE.KQZER
      KMCANH(KI,KI1)=IW(IW(KJQDET(KI)+JQDEAM)+KI1+JMCANH-1)
      QMCADH(KI,KI1)=RW(IW(KJQDET(KI)+JQDEAM)+KI1+JMCADH-1)
      QMCADC(KI,KI1)=RW(IW(KJQDET(KI)+JQDEAM)+KI1+JMCADC-1)
      QMCAAM(KI)=RW(IW(KJQDET(KI)+JQDEAM)+JMCAAM)
      QMCAAC(KI)=RW(IW(KJQDET(KI)+JQDEAM)+JMCAAC)
C
      XMUI(KI)=IW(KJQDET(KI)+JQDEMU).NE.KQZER
      KMUIIF(KI)=IW(IW(KJQDET(KI)+JQDEMU)+JMUIIF)
      QMUISR(KI)=RW(IW(KJQDET(KI)+JQDEMU)+JMUISR)
      QMUIDM(KI)=RW(IW(KJQDET(KI)+JQDEMU)+JMUIDM)
      KMUIST(KI)=IW(IW(KJQDET(KI)+JQDEMU)+JMUIST)
      KMUITN(KI)=IW(IW(KJQDET(KI)+JQDEMU)+JMUITN)
C
      XPEC(KI)=IW(KJQDET(KI)+JQDEEC).NE.KQZER
      QPECER(KI)=RW(IW(KJQDET(KI)+JQDEEC)+JPECER)
      QPECE1(KI)=RW(IW(KJQDET(KI)+JQDEEC)+JPECE1)
      QPECE2(KI)=RW(IW(KJQDET(KI)+JQDEEC)+JPECE2)
      QPECTH(KI)=RW(IW(KJQDET(KI)+JQDEEC)+JPECTH)
      QPECPH(KI)=RW(IW(KJQDET(KI)+JQDEEC)+JPECPH)
      QPECEC(KI)=RW(IW(KJQDET(KI)+JQDEEC)+JPECEC)
      KPECKD(KI)=IW(IW(KJQDET(KI)+JQDEEC)+JPECKD)
      KPECCC(KI)=IW(IW(KJQDET(KI)+JQDEEC)+JPECCC)
      KPECRB(KI)=IW(IW(KJQDET(KI)+JQDEEC)+JPECRB)
      KPECPC(KI)=IW(IW(KJQDET(KI)+JQDEEC)+JPECPC)
C
      XPEP(KI)=IW(KJQDET(KI)+JQDEET).NE.KQZER
      QPEPT1(KI)=RW(IW(KJQDET(KI)+JQDEET)+JPEPT1)
      QPEPP1(KI)=RW(IW(KJQDET(KI)+JQDEET)+JPEPP1)
      QPEPT3(KI)=RW(IW(KJQDET(KI)+JQDEET)+JPEPT3)
      QPEPP3(KI)=RW(IW(KJQDET(KI)+JQDEET)+JPEPP3)
C
      XPHC(KI)=IW(KJQDET(KI)+JQDEHC).NE.KQZER
      QPHCER(KI)=RW(IW(KJQDET(KI)+JQDEHC)+JPHCER)
      QPHCTH(KI)=RW(IW(KJQDET(KI)+JQDEHC)+JPHCTH)
      QPHCPH(KI)=RW(IW(KJQDET(KI)+JQDEHC)+JPHCPH)
      QPHCEC(KI)=RW(IW(KJQDET(KI)+JQDEHC)+JPHCEC)
      KPHCKD(KI)=IW(IW(KJQDET(KI)+JQDEHC)+JPHCKD)
      KPHCCC(KI)=IW(IW(KJQDET(KI)+JQDEHC)+JPHCCC)
      KPHCRB(KI)=IW(IW(KJQDET(KI)+JQDEHC)+JPHCRB)
      KPHCPC(KI)=IW(IW(KJQDET(KI)+JQDEHC)+JPHCPC)
C
      XEFO(KI)=IW(KJQDET(KI)+JQDEEF).NE.KQZER
      QEFOWE(KI)=RW(IW(KJQDET(KI)+JQDEEF)+JEFOWE)
      KEFOTY(KI)=IW(IW(KJQDET(KI)+JQDEEF)+JEFOTY)
      KEFOLE(KI)=IW(IW(KJQDET(KI)+JQDEEF)+JEFOLE)
      KEFOLT(KI)=IW(IW(KJQDET(KI)+JQDEEF)+JEFOLT)
      KEFOLH(KI)=IW(IW(KJQDET(KI)+JQDEEF)+JEFOLH)
      KEFOLC(KI)=IW(IW(KJQDET(KI)+JQDEEF)+JEFOLC)
      KEFOLJ(KI)=IW(IW(KJQDET(KI)+JQDEEF)+JEFOLJ)
C
      XPCQ(KI)=IW(KJQDET(KI)+JQDEPC).NE.KQZER
      KPCQNA(KI)=IW(IW(KJQDET(KI)+JQDEPC)+JPCQNA)
C
      XEGP(KI)=IW(KJQDET(KI)+JQDEEG).NE.KQZER
      QEGPR1(KI)=RW(IW(KJQDET(KI)+JQDEEG)+JEGPR1)
      QEGPR2(KI)=RW(IW(KJQDET(KI)+JQDEEG)+JEGPR2)
      QEGPF4(KI)=RW(IW(KJQDET(KI)+JQDEEG)+JEGPF4)
      QEGPDM(KI)=RW(IW(KJQDET(KI)+JQDEEG)+JEGPDM)
      KEGPST(KI)=IW(IW(KJQDET(KI)+JQDEEG)+JEGPST)
      KEGPQU(KI)=IW(IW(KJQDET(KI)+JQDEEG)+JEGPQU)
      KEGPPE(KI)=IW(IW(KJQDET(KI)+JQDEEG)+JEGPPE)
C
      XPGP(KI)=IW(KJQDET(KI)+JQDEPG).NE.KQZER.AND.IW(NAPGPC).GT.0
      QPGPR1(KI)=RW(IW(KJQDET(KI)+JQDEPG)+JPGPR1)
      QPGPR2(KI)=RW(IW(KJQDET(KI)+JQDEPG)+JPGPR2)
      QPGPF4(KI)=RW(IW(KJQDET(KI)+JQDEPG)+JPGPF4)
      QPGPDM(KI)=RW(IW(KJQDET(KI)+JQDEPG)+JPGPDM)
      QPGPST(KI)=RW(IW(KJQDET(KI)+JQDEPG)+JPGPST)
      QPGPQ1(KI)=RW(IW(KJQDET(KI)+JQDEPG)+JPGPQ1)
      QPGPQ2(KI)=RW(IW(KJQDET(KI)+JQDEPG)+JPGPQ2)
      QPGPM1(KI)=RW(IW(KJQDET(KI)+JQDEPG)+JPGPM1)
      QPGPM2(KI)=RW(IW(KJQDET(KI)+JQDEPG)+JPGPM2)
      QPGPMA(KI)=RW(IW(KJQDET(KI)+JQDEPG)+JPGPMA)
      QPGPER(KI)=RW(IW(KJQDET(KI)+JQDEPG)+JPGPER)
      QPGPTR(KI)=RW(IW(KJQDET(KI)+JQDEPG)+JPGPTR)
      QPGPPR(KI)=RW(IW(KJQDET(KI)+JQDEPG)+JPGPPR)
      KPGPQU(KI)=IW(IW(KJQDET(KI)+JQDEPG)+JPGPQU)
      KPGPPE(KI)=IW(IW(KJQDET(KI)+JQDEPG)+JPGPPE)
      XPGAC(KI)=IW(KJQDET(KI)+JQDEPG).NE.KQZER.AND.IW(NAPGAC).GT.0
      KPGAST(KI)=IW(IW(KJQDET(KI)+JQDEPG)+JPGAST)
      QPGAEF(KI)=RW(IW(KJQDET(KI)+JQDEPG)+JPGAEF)
      QPGAGC(KI)=RW(IW(KJQDET(KI)+JQDEPG)+JPGAGC)
      QPGAZS(KI)=RW(IW(KJQDET(KI)+JQDEPG)+JPGAZS)
      QPGAPL(KI)=RW(IW(KJQDET(KI)+JQDEPG)+JPGAPL)
      QPGAPH(KI)=RW(IW(KJQDET(KI)+JQDEPG)+JPGAPH)
      KPGAPN(KI)=IW(IW(KJQDET(KI)+JQDEPG)+JPGAPN)
      KPGAFA(KI)=IW(IW(KJQDET(KI)+JQDEPG)+JPGAFA)
      KPGAPE(KI)=IW(IW(KJQDET(KI)+JQDEPG)+JPGAPE)
C
C
      XYV0(KI)=KVYV0V(KENDV(KI)).NE.0
      KYV0K1(KI)=IW(KVYV0V(KENDV(KI))+JYV0K1)
      KYV0K2(KI)=IW(KVYV0V(KENDV(KI))+JYV0K2)
      QYV0VX(KI)=RW(KVYV0V(KENDV(KI))+JYV0VX)
      QYV0VY(KI)=RW(KVYV0V(KENDV(KI))+JYV0VY)
      QYV0VZ(KI)=RW(KVYV0V(KENDV(KI))+JYV0VZ)
      QYV0X1(KI)=RW(KVYV0V(KENDV(KI))+JYV0X1)
      QYV0X2(KI)=RW(KVYV0V(KENDV(KI))+JYV0X2)
      QYV0C2(KI)=RW(KVYV0V(KENDV(KI))+JYV0C2)
      KYV0IC(KI)=IW(KVYV0V(KENDV(KI))+JYV0IC)
      QYV0DM(KI)=RW(KVYV0V(KENDV(KI))+JYV0DM)
      QYV0S1(KI)=RW(KVYV0V(KENDV(KI))+JYV0S1)
      QYV0S2(KI)=RW(KVYV0V(KENDV(KI))+JYV0S2)
C
      XLEPTG(KI)=IW(KJQDET(KI)+JQDEPD).NE.KQZER
      KLEPPA(KI)=IW(IW(KJQDET(KI)+JQDEPD)+JPDLPA)
      KLEPJT(KI)=IW(IW(KJQDET(KI)+JQDEPD)+JPDLJT)+KLFJET-1
      QLEPPI(KI)=RW(IW(KJQDET(KI)+JQDEPD)+JPDLPI)
      QLEPPE(KI)=RW(IW(KJQDET(KI)+JQDEPD)+JPDLPE)
      KLEPVP(KI)=IW(IW(KJQDET(KI)+JQDEPD)+JPDLVP)
C
      XLEPTH(KI)=IW(KJQDET(KI)+JQDEPM).NE.KQZER
      KLEPFL(KI)=IW(IW(KJQDET(KI)+JQDEPM)+JPMLFL)
      KLEPPO(KI)=IW(IW(KJQDET(KI)+JQDEPM)+JPMLPO)
      KLEPCH(KI)=IW(IW(KJQDET(KI)+JQDEPM)+JPMLCH)
      KLEPSP(KI)=IW(IW(KJQDET(KI)+JQDEPM)+JPMLSP)
      KLEPLE(KI)=IW(IW(KJQDET(KI)+JQDEPM)+JPMLLE)
      KLEPME(KI)=IW(IW(KJQDET(KI)+JQDEPM)+JPMLME)
      KLEPKT(KI)=IW(IW(KJQDET(KI)+JQDEPM)+JPMLKT)
C---------------------  end of QMACRO ---------------------------------
C ----------------------------------------------------------------------
C
C XY TRACK DIRECTION
      P0=QFRFP0(ITK)
      SP=SIN(P0)
      CP=COS(P0)
C
C TRACK POSITION AT CLOSEST APPROACH TO ALEPH Z AXIS
      D0=QFRFD0(ITK)
      X0= D0*SP
      Y0=-D0*CP
      Z0=QFRFZ0(ITK)
C
C ROTATE VERTEX TO SYSTEM WHERE TRACK PHI=0
      XV= CP*VTX(1)+SP*VTX(2)
      YV=-SP*VTX(1)+CP*VTX(2)
C
C D0 WITH RESPECT TO VERTEX
      D0V=D0+YV
C
C CURVATURE CORRECTION
      RINV=QFRFIR(ITK)
      D0V=D0V-.5*RINV*XV**2
C
C Z0 AT POINT OF CLOSEST APPROACH TO XV,YV AXIS
      TL=QFRFTL(ITK)
      ZV=Z0+TL*XV
C
C LONGITUDINAL VERTEX MISS
      Z0V=ZV-VTX(3)
C
C ANGLE FROM BEAM DIRECTION
      STH=1./SQRT(1.+TL**2)
      CTH=TL*STH
C
C TRACK DIRECTION AT CLOSEST APPROACH
      DX=CP*STH
      DY=SP*STH
      DZ=CTH
C
C FIND 3D POINT OF CLOSEST APPROACH TO VERTEX
C TRACK LINE IS X+S*D=(X0,Y0,X0)+S*(DX,DY,DZ)
C VERTEX POINT IS V=VTX(1,2,3)
C     DIST**2=(X+S*D-V)**2
C     D/DS   = 2 (X+SMIN*D-V) DOT D = 0
C     SMIN   = ((V-X) DOT D) / (D DOT D) = (V-X) DOT D
C
      SMIN=(VTX(1)-X0)*DX + (VTX(2)-Y0)*DY + (VTX(3)-Z0)*DZ
C
C SHORTEST VECTOR FROM TRACK TO VERTEX
      XC=X0+SMIN*DX-VTX(1)
      YC=Y0+SMIN*DY-VTX(2)
      ZC=Z0+SMIN*DZ-VTX(3)
C
C 3D DISTANCE FROM VERTEX
      R3D=SQRT(XC**2+YC**2+ZC**2)
C
      RETURN
      END
