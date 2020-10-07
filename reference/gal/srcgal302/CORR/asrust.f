      SUBROUTINE ASRUST
C ----------------------------------------------------------------------
C. - F.RANJARD - 850325
C! Build the galeph run header banks
C    ATIT,ACUT,AFID,ARUN,APRO,AJOB,AKIN,ASIM
C
C - modified by : F.Ranjard -911002
C                 modified word(JAJOSD) in AJOB bank
C                 the word contains 1 bit per detector starting
C                 at bit 0. The bit is set to 1 if the detector
C                 was selected on the SETS data card.
C                 add SICAL run conditions in ARUN bank
C
C. - called by    ASIRUN                           from this .HLB
C. - Calls        BLIST                            from BOS.HLB
C                 UCOPY, BUNCH                     from CERNlibs
C.
C -----------------------------------------------------
      SAVE
      PARAMETER (KGWBK=69000,KGWRK=5200)
      COMMON /GCBANK/   NGZEBR,GVERSN,GZVERS,IGXSTO,IGXDIV,IGXCON,
     &                  GFENDQ(16),LGMAIN,LGR1,GWS(KGWBK)
      DIMENSION IGB(1),GB(1),LGB(8000),IGWS(1)
      EQUIVALENCE (GB(1),IGB(1),LGB(9)),(LGB(1),LGMAIN),(IGWS(1),GWS(1))
C
      COMMON/GCLINK/JGDIGI,JGDRAW,JGHEAD,JGHITS,JGKINE,JGMATE,JGPART
     +        ,JGROTM,JGRUN,JGSET,JGSTAK,JGGSTA,JGTMED,JGTRAC,JGVERT
     +        ,JGVOLU,JGXYZ,JGPAR,JGPAR2,JGSKLT
C
C - GALEPH   30.2   950512  18:17:44
      PARAMETER (GALVER=30.2)
      PARAMETER (CORVER=2.0)
*?          corrections in VDET (MANOJ302)
C
      PARAMETER (LFIL=6)
      COMMON /IOCOM/   LGETIO,LSAVIO,LGRAIO,LRDBIO,LINPIO,LOUTIO
      DIMENSION LUNIIO(LFIL)
      EQUIVALENCE (LUNIIO(1),LGETIO)
      COMMON /IOKAR/   TFILIO(LFIL),TFORIO(LFIL)
      CHARACTER TFILIO*60, TFORIO*4
C
      PARAMETER (LOFFMC = 1000)
      PARAMETER (LHIS=20, LPRI=20, LTIM=6, LPRO=6, LRND=3)
      PARAMETER (LBIN=20, LST1=LBIN+3, LST2=3)
      PARAMETER (LSET=15, LTCUT=5, LKINP=20)
      PARAMETER (LDET=9,  LGEO=LDET+4, LBGE=LGEO+5)
      PARAMETER (LCVD=10, LCIT=10, LCTP=10, LCEC=15, LCHC=10, LCMU=10)
      PARAMETER (LCLC=10, LCSA=10, LCSI=10)
      COMMON /JOBCOM/   JDATJO,JTIMJO,VERSJO
     &                 ,NEVTJO,NRNDJO(LRND),FDEBJO,FDISJO
     &                 ,FBEGJO(LDET),TIMEJO(LTIM),NSTAJO(LST1,LST2)
     &                 ,IDB1JO,IDB2JO,IDB3JO,IDS1JO,IDS2JO
     &                 ,MBINJO(LST2),MHISJO,FHISJO(LHIS)
     &                 ,IRNDJO(LRND,LPRO)
     &                 ,IPRIJO(LPRI),MSETJO,IRUNJO,IEXPJO,AVERJO
     3                 ,MPROJO,IPROJO(LPRO),MGETJO,MSAVJO,TIMLJO,IDATJO
     5                 ,TCUTJO(LTCUT),IBREJO,NKINJO,BKINJO(LKINP),IPACJO
     6                 ,IDETJO(LDET),IGEOJO(LGEO),LVELJO(LGEO)
     7                 ,ICVDJO(LCVD),ICITJO(LCIT),ICTPJO(LCTP)
     8                 ,ICECJO(LCEC),ICHCJO(LCHC),ICLCJO(LCLC)
     9                 ,ICSAJO(LCSA),ICMUJO(LCMU),ICSIJO(LCSI)
     &                 ,FGALJO,FPARJO,FXXXJO,FWRDJO,FXTKJO,FXSHJO,CUTFJO
     &                 ,IDAFJO,IDCHJO,TVERJO
      LOGICAL FDEBJO,FDISJO,FHISJO,FBEGJO,FGALJO,FPARJO,FXXXJO,FWRDJO
     &       ,FXTKJO,FXSHJO
      COMMON /JOBKAR/   TITLJO,TSETJO(LSET),TPROJO(LPRO)
     1                 ,TKINJO,TGEOJO(LBGE),TRUNJO
      CHARACTER TRUNJO*60
      CHARACTER*4 TKINJO,TPROJO,TSETJO,TITLJO*40
      CHARACTER*2 TGEOJO
C
      PARAMETER (LERR=20)
      COMMON /JOBERR/   ITELJO,KERRJO,NERRJO(LERR)
      COMMON /JOBCAR/   TACTJO
      CHARACTER*6 TACTJO
C
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON /BCS/   IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
      PARAMETER(JACUMN=1,JACUGC=2,JACUEC=3,JACUHC=4,JACUNC=5,JACUMC=6,
     +          LACUTA=6)
      PARAMETER(JAFIAR=1,JAFIAZ=2,JAFIMF=3,JAFIBE=4,LAFIDA=4)
      PARAMETER(JAJOBM=1,JAJORM=2,JAJOGI=3,JAJOSO=4,JAJOSD=5,JAJOGC=6,
     +          JAJOJD=7,JAJOJT=8,JAJOGV=9,JAJOAV=10,JAJOFT=11,
     +          JAJOFS=12,JAJOFC=13,JAJODV=14,JAJODD=15,JAJOTV=16,
     +          JAJOCV=17,JAJOGN=18,LAJOBA=18)
      PARAMETER(JAKIKT=1,JAKIKP=2,LAKINA=9)
      PARAMETER(JAPRPF=1,JAPRRG=2,LAPROA=4)
      PARAMETER(JARURC=1,LARUNA=10)
      PARAMETER(JASERG=1,LASEVA=3)
      PARAMETER(JATIRT=1,LATITA=1)
      PARAMETER (JASIYM=1,LASIMA=1)
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
C
      COMMON/ALFGEO/ALRMAX,ALZMAX,ALFIEL,ALECMS
C
      INTEGER IDET(LDET)
      EXTERNAL NAMIND
C ----------------------------------------------------------------------
C
C - get indices of Axxx banks
      JATIT = IW(NAMIND('ATIT'))
      JAKIN = IW(NAMIND('AKIN'))
      JACUT = IW(NAMIND('ACUT'))
      JAFID = IW(NAMIND('AFID'))
      JAJOB = IW(NAMIND('AJOB'))
      JARUN = IW(NAMIND('ARUN'))
      JAPRO = IW(NAMIND('APRO'))
      CALL BLIST (IW,'C+','ATITAKINACUTAFIDAJOBARUNAPRO')
      CALL BKFMT ('ACUT','2I,(A,5F)')
      CALL BKFMT ('AFID','2I,(F)')
      CALL BKFMT ('AJOB','I')
      CALL BKFMT ('AKIN','2I,A,(F)')
      CALL BKFMT ('APRO','I')
      CALL BKFMT ('ARUN','I')
      CALL BKFMT ('ATIT','2I,(A)')
C
C - Build ASIM with date of the geometry
C
      IF (IW(NAMIND('ASIM')).EQ.0) THEN
         CALL ALBOS ('ASIM',0,LASIMA+LMHLEN,JASIM,IGARB)
         IW(JASIM+LMHCOL) = LASIMA
         IW(JASIM+LMHROW) = 1
         IW(JASIM+LMHLEN+JASIYM) = IDATJO
         CALL BKFMT ('ASIM','I')
      ENDIF
      CALL BLIST (IW,'C+','ASIM')
C
C - Build AJOB with all job flags set by data cards
      CALL ALBOS ('AJOB',0,LAJOBA+LMHLEN,JAJOB,IGARB)
      IW(JAJOB+LMHCOL) = LAJOBA
      IW(JAJOB+LMHROW) = 1
      KAJOB = JAJOB + LMHLEN
      IW(KAJOB+JAJOBM) = IBREJO
      IW(KAJOB+JAJORM) = IPACJO
      IW(KAJOB+JAJOJD) = JDATJO
      IW(KAJOB+JAJOJT) = JTIMJO
      IW(KAJOB+JAJOGV) = NINT(VERSJO*10.)
      IW(KAJOB+JAJOAV) = NINT(AVERJO*10.)
      IW(KAJOB+JAJOGI) = MGETJO
      IW(KAJOB+JAJOSO) = MSAVJO
      DO 10 I=1,LDET
         IDET(I) = 0
         IF (IDETJO(I).NE.0) IDET(I) = 1
 10   CONTINUE
      CALL BUNCH (IDET,IW(KAJOB+JAJOSD),LDET,1)
      CALL BUNCH (IGEOJO,IW(KAJOB+JAJOGC),LGEO,1)
      IF (FXTKJO) IW(KAJOB+JAJOFT) = 1
      IF (FXSHJO) IW(KAJOB+JAJOFS) = 1
      IW(KAJOB+JAJOFC) = NINT(CUTFJO*1000.)
      IW(KAJOB+JAJODV) = IDAFJO
      IW(KAJOB+JAJODD) = IDCHJO
      IW(KAJOB+JAJOTV) = NINT(TVERJO*100.)
      IW(KAJOB+JAJOCV) = NINT(CORVER*100.)
      IW(KAJOB+JAJOGN) = INT(GVERSN*10000.)
C
C - Build  ATIT with the run title
      IF (JATIT .EQ. 0) THEN
         IF (TRUNJO.NE.' ') THEN
            LTIT = (LENOCC(TRUNJO)+3)/4
            CALL ALBOS ('ATIT',0,LTIT+LMHLEN,JATIT,IGARB)
            IW(JATIT+LMHCOL) = 1
            IW(JATIT+LMHROW) = LTIT
            KATIT = JATIT + LMHLEN
            CALL ALINST(TRUNJO,IW(KATIT+JATIRT),LTIT)
         ENDIF
      ENDIF
C
C - Build  ACUT with the tracking cuts
      CALL ALBOS ('ACUT',0,LACUTA+LMHLEN,JACUT,IGARB)
      IW(JACUT+LMHCOL) = LACUTA
      IW(JACUT+LMHROW) = 1
      KACUT = JACUT + LMHLEN
      IW(KACUT+JACUMN) = INTCHA ('ALEF')
      CALL UCOPY (TCUTJO,RW(KACUT+JACUGC),LTCUT)
C
C - Build AFID with ALFGEO common variables
      CALL ALBOS ('AFID',0,LAFIDA+LMHLEN,JAFID,IGARB)
      IW(JAFID+LMHCOL) = LAFIDA
      IW(JAFID+LMHROW) = 1
      KAFID = JAFID + LMHLEN
      RW(KAFID+JAFIAR) = ALRMAX
      RW(KAFID+JAFIAZ) = ALZMAX
      RW(KAFID+JAFIMF) = ALFIEL
      RW(KAFID+JAFIBE) = ALECMS
C
C - Build APRO with process flags and random generator rootsk
      CALL ALBOS ('APRO',0,LAPROA*LPRO+LMHLEN,JAPRO,IGARB)
      IW(JAPRO+LMHCOL) = LAPROA
      IW(JAPRO+LMHROW) = LPRO
      KAPRO = JAPRO + LMHLEN
      DO 1 I=1,LPRO
         IW(KAPRO+JAPRPF) = IPROJO(I)
         IW(KAPRO+JAPRRG) = IRNDJO(1,I)
         IW(KAPRO+JAPRRG+1) = IRNDJO(2,I)
         IW(KAPRO+JAPRRG+2) = IRNDJO(3,I)
  1   KAPRO = KAPRO + LAPROA
C
C - Build AKIN with the kinematic parameters
      LKIN = MIN (LKINP,NKINJO)
      IF (LKIN .GT. 0) THEN
         IF (JAKIN .EQ. 0) THEN
            CALL ALBOS ('AKIN',0,LKIN+1+LMHLEN,JAKIN,IGARB)
            IW(JAKIN+LMHCOL) = 1
            IW(JAKIN+LMHROW) = LKIN+1
         ENDIF
         KAKIN = JAKIN + LMHLEN
         IW(KAKIN+JAKIKT) = INTCHA (TKINJO)
         CALL UCOPY (BKINJO,RW(KAKIN+JAKIKP),LKIN)
      ENDIF
C
C - Build ARUN with the detector run conditions
      LARUN = MAX (LCVD,LCIT,LCTP,LCEC,LCLC,LCSA,LCHC,LCMU)
      CALL ALBOS ('ARUN',0,LARUN*LDET+LMHLEN,JARUN,IGARB)
      IW(JARUN+LMHCOL) = LARUN
      IW(JARUN+LMHROW) = LDET
      KARUN = JARUN + LMHLEN
      CALL UCOPY (ICVDJO,IW(KARUN+JARURC),LCVD)
      KARUN = KARUN + LARUN
      CALL UCOPY (ICITJO,IW(KARUN+JARURC),LCIT)
      KARUN = KARUN + LARUN
      CALL UCOPY (ICTPJO,IW(KARUN+JARURC),LCTP)
      KARUN = KARUN + LARUN
      CALL UCOPY (ICECJO,IW(KARUN+JARURC),LCEC)
      KARUN = KARUN + LARUN
      CALL UCOPY (ICLCJO,IW(KARUN+JARURC),LCLC)
      KARUN = KARUN + LARUN
      CALL UCOPY (ICSAJO,IW(KARUN+JARURC),LCSA)
      KARUN = KARUN + LARUN
      CALL UCOPY (ICHCJO,IW(KARUN+JARURC),LCHC)
      KARUN = KARUN + LARUN
      CALL UCOPY (ICMUJO,IW(KARUN+JARURC),LCMU)
      KARUN = KARUN + LARUN
      CALL UCOPY (ICSIJO,IW(KARUN+JARURC),LCSI)
C
C - End
 999  CONTINUE
      RETURN
       END
