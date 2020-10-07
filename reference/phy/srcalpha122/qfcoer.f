      SUBROUTINE QFCOER(NTK1,NTK2,IREL1,IREL2)
CKEY FILL CAL /INTERNAL
C----------------------------------------------------------------------
C! Set up relations for calorimeter objects
C
C  auxiliary to  QFCOBJ
C                                                    J.Boucrot  23.9.93
C----------------------------------------------------------------------
      SAVE
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
C----------------------------------------------------------------------
      IF (KNQLIN + IW(IREL1) .GE. IW(KOQLIN))
     &  CALL QSBANK ('QLIN',KNQLIN+IW(IREL1)+500)
      DO 810 N = 1, IW(IREL1)
C       Take care of double counting in PCRL :
        IF (IW(KOQLIN+IW(IREL1+1)+N) .EQ. NTK2)  GO TO 999
  810 IW(KOQLIN+KNQLIN+N) = IW(KOQLIN+IW(IREL1+1)+N)
      IW(IREL1) = IW(IREL1) + 1
      IW(IREL1+1) = KNQLIN
      KNQLIN = KNQLIN + IW(IREL1)
      IW(KOQLIN+KNQLIN) = NTK2
C
C       now, the reverse relation :
C
      IF (KNQLIN + IW(IREL2) .GE. IW(KOQLIN))
     &    CALL QSBANK ('QLIN',KNQLIN+IW(IREL2)+500)
      DO 820 N=1, IW(IREL2)
  820 IW(KOQLIN+KNQLIN+N) = IW(KOQLIN+IW(IREL2+1)+N)
      IW(IREL2) = IW(IREL2) + 1
      IW(IREL2+1) = KNQLIN
      KNQLIN = KNQLIN + IW(IREL2)
      IW(KOQLIN+KNQLIN) = NTK1
C
 999  CONTINUE
      END
