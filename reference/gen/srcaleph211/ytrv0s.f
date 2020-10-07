      SUBROUTINE YTRV0S(IER)
C
C----------------------------------------------------------*
C!    Reconstruct V0 decays
CKEY YTOP
C!    Author :     G. Lutz   30/11/87
C!    Modified :   M. Bosman 01/12/88
C!    Rewritten :  G. Lutz     /02/91
C!    Modified :   M. Bosman 11/07/91
C!    Corrected:   W.Manner  28/02/92
C!    Modified  :  G. Lutz   30/03/92
C!    Modified  :  G. Lutz    1/10/92
C!    Modified  :  W.Manner   2/03/93
C!
C!
C!    Description
C!    ===========
C!    This routine looks for V0 candidates
C!
C!---------------------------------------------------------*
      SAVE
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON /BCS/   IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
      PARAMETER(JFRFIR=1,JFRFTL=2,JFRFP0=3,JFRFD0=4,JFRFZ0=5,JFRFAL=6,
     +          JFRFEM=7,JFRFC2=28,JFRFDF=29,JFRFNO=30,LFRFTA=30)
      PARAMETER(JFRIBP=1,JFRIDZ=2,JFRIBC=3,JFRIDC=4,JFRIPE=5,JFRIPM=6,
     +          JFRIPI=7,JFRIPK=8,JFRIPP=9,JFRINK=10,JFRIQF=11,
     +          LFRIDA=11)
      PARAMETER(JFRTIV=1,JFRTNV=2,JFRTII=3,JFRTNI=4,JFRTNE=5,JFRTIT=6,
     +          JFRTNT=7,JFRTNR=8,LFRTLA=8)
      PARAMETER(JPYETY=1,JPYEVX=2,JPYEVY=3,JPYEVZ=4,JPYEVM=5,JPYEC2=11,
     +          JPYEDF=12,LPYERA=12)
      PARAMETER(JPYFTN=1,JPYFVN=2,LPYFRA=2)
      PARAMETER(JYNFMO=1,JYNFTL=2,JYNFP0=3,JYNFD0=4,JYNFZ0=5,JYNFEM=6,
     +          JYNFC2=21,JYNFDF=22,JYNFCH=23,JYNFND=24,JYNFPT=25,
     +          JYNFNM=26,JYNFPM=27,JYNFPV=28,JYNFPC=29,LYNFTA=29)
      PARAMETER(JYNTMT=1,JYNTDT=2,JYNTTT=3,JYNTMA=4,
     &     JYNTBP=5,JYNTIM=6,JYNTPI=7,LYNTRA=7)
      PARAMETER(JYNMMT=1,JYNMPA=2,JYNMMA=3,JYNMEM=4,
     &     JYNMVD=5,JYNMSC=6,JYNMIC=7,JYNMNA=8,JYNMPR=9,LYNMAA=10)
      PARAMETER(JYNPPX=1,JYNPPY=2,JYNPPZ=3,LYNPEA=3)
C! YTOP array dimensions
      PARAMETER(NMSIZZ=31,MKDIMM=6,MAXTRK=186,MAXHLX=124,MAXNTR=62,
     &  MXVTOP=10,MXMULS=10,MAXVXP=50,MAXEXC=60,MXVTYP=2)
C! YTOP particle masses
      PARAMETER(    JPAFEP=1,JPAFEM=2,JPAFMP=3,JPAFMM=4,
     &              JPAFPP=5,JPAFPM=6,JPAFKP=7,JPAFKM=8,
     &              JPAFPR=9,JPAFPB=10,JPAFPH=11,JPAFPZ=12,
     &              JPAFKZ=13,JPAFLA=14,JPAFLB=15   )
      COMMON/YPMASS/ YPMASS(20)
C! YTOP parameters
      COMMON/YPARTO/DHXLIM,CHISEL,PMINSE,PIDACP,BFIELD,
     &       MNTHPV,MXTSPV, PMINRQ,PMINRA,
     &       CHVXCO,CHPTCO,RVACCO,AMCTCO,DZMXCO,NAMXCO,EPLOCO,EPHICO,
     &       CHVXV0,CHPTV0,CHVSV0,CHMLV0,DZMXV0,NAMXV0,
     &       PIPKV0,PRPLV0,PIPLV0,
     &       LBCRFD,LRYOLD,LRFRF2,
     &       LRPVTX,LRSVTX,LVBCR0,LRMVPV,LRLPVX,LCONVS,LVZERS,LRUSER
      LOGICAL LBCRFD,LRYOLD,LRFRF2
      LOGICAL LRPVTX,LRSVTX,LVBCR0,LRMVPV,LRLPVX,LCONVS,LVZERS,LRUSER
C! YTOP summary
      COMMON /YSUMTO/NEPVTO,NRPVTO,ATPVTO,AMPVTO,ACPVTO,APPVTO(3),
     +               NRCOTO,AMCOTO,ACCOTO,ARCOTO,
     +               NRK0TO,AMK0TO,ACK0TO,ATK0TO,
     +               NRLATO,AMLATO,ACLATO,ATLATO,
     +               NRLBTO,AMLBTO,ACLBTO,ATLBTO,
     +               KYFLAG(20)
C! YTOP track parameters
      COMMON/YTRKTO/NGTRTO,IPTRTO(MAXTRK),
     &              PTRECT(MAXTRK),PRECTO(MAXTRK),
     &              KPIDF0(MAXTRK),KPORF0(MAXTRK)
C
C! YTOP vertex parameters
      COMMON/YVTXTO/ NEVTOP,NVXTOP,NVXLOT,
     &  VXTOP0(3,MXVTOP,MXVTYP),VVXTOP(6,MXVTOP,MXVTYP),
     &  CHVTOP(MXVTOP,MXVTYP),DRVTOP(MXVTOP,MXVTYP),
     &  MULTVX(MXVTOP,MXVTYP),
     &  IXTRVT(MKDIMM,MXVTOP,MXVTYP),IXVQLI(MAXTRK,MXVTOP),
     &  CHIVXI(MAXTRK,MXVTOP),
     &  NLOTRK,ILOTRK(MAXTRK),
     &  JTRVXA(MAXTRK,MXVTYP),NTRVXA(MAXTRK,MXVTYP),
     &  NEVVTX(3,MXVTOP),NMULVX(MXMULS,MXVTYP),
     &  NMULTA(MXVTOP,MXVTYP),MULMAT(MXMULS,MXMULS)
C! beam crossing position
      COMMON/YBCRTO/BCROSS(3),VBCROS(6)
C
C     VZERO SEARCH
      REAL XYZCO(3,4),RADC1(4),RADC2(4),FIICO(4),ZETCO(4)
      REAL XIMPA(MAXTRK,2)
      DIMENSION VXIN(3),VVXIN(6),IXHX(2),AMHX(2),
     &                           IXNU(2),AMNU(2),TNUI(5,2),VTNUI(15,2),
     &                           AMPC(2,5),
     &                           VXOUT(3),VVXOU(6),HXOU(5,2),VHXOU(15,
     &                           2),
     &                           TNUO(5,2),VTNUO(15,2),
     &                           PSUM(3),VPSUM(6),VPSVX(3,3),
     &                           AMASS(5),DMASS(5),VMVX(3,5),VMPS(3,5),
     &                           VHXIN(15,MAXTRK,2),BMASS(5),EMASS(5)
      DIMENSION VXOU2(3),VVXO2(6)
      DIMENSION VTX2(3),VARV2(6)
      DIMENSION VTOL(3),VAROL(6)
      DIMENSION WTX(3),VARWX(6)
      DIMENSION IPTR(MAXTRK)
C
C     BEAM CROSSING AND DECAY VERTEX
      DIMENSION VTXX(3,2),VVTXX(6,2)
      DIMENSION ITADD(MAXTRK)
C
C     V0 SEARCH
      DIMENSION IMASS(4),IBVD(2)
      DIMENSION AMNOM(5),VTXSTT(3,2)
C
C  99.9% CONFIDENCE LIMITS FOR N DEGREES OF FREEDOM
      DIMENSION CONLM(20)
      DIMENSION TRACK(5),VTRACK(15)
      DIMENSION JA(5),CHIMP(2)
C
      LOGICAL LVAPC,LVAPP
      LOGICAL LMRK
      LOGICAL LACC
      LOGICAL LGARB
      LOGICAL LV0SMC
C
      LOGICAL LDMP1,LDMP2
      LOGICAL LFIRST
      CHARACTER*4 VZFL
C
      DATA LFIRST/.TRUE./
      DATA LDMP1/.FALSE./,LDMP2/.FALSE./
C
C     dimension of buffer for track error matrix
      DATA LVHXIN /15/
C
C     maximum chisq for vertex candidates ************
C     for rejection of tracks far off in z0
      DATA RMAX/180./,PSMAX/0.3/
C     MAX. # OF ADDITIONAL TRACKS PASSING THROUGH V0 VERTEX
C
C     min. vzero chisq vertex dist. from beam crossing
C     maximum chisq for pointing chisq of V0's to BCRO
C     CHISQ LIMIT OF MASS DEVIATION
C
      DATA CONLM/10.8,13.8,16.3,18.5,20.5,22.5,24.3,26.1,27.8,29.6,
     1            31.3,32.9,34.5,36.1,37.7,39.2,40.8,42.3,43.8,45.3/
C
C     calculate approx. vtx in yfthvx
      DATA LVAPC/.TRUE./
C
      DATA LV0SMC/.FALSE./
C
C!    set of intrinsic functions to handle BOS banks
C - # of words/row in bank with index ID
      LCOLS(ID) = IW(ID+1)
C - # of rows in bank with index ID
      LROWS(ID) = IW(ID+2)
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
C
C ---------------------------------------------------------------
C-- Define the logical unit for printout
C
      LOUT = IW(6)
C
C
      ICVZR=ICVZR+1
C
      IER = 0
C
      IF(LFIRST) THEN
C     GENERATE MARKERS
        CALL YMKZER(1,NMSIZZ,MKPI)
        CALL YMKSET(1,NMSIZZ,MKPI,JPAFPP)
        CALL YMKSET(1,NMSIZZ,MKPI,JPAFPM)
        CALL YMKZER(1,NMSIZZ,MKPIP)
        CALL YMKSET(1,NMSIZZ,MKPIP,JPAFPP)
        CALL YMKSET(1,NMSIZZ,MKPIP,JPAFPM)
        CALL YMKSET(1,NMSIZZ,MKPIP,JPAFPR)
        CALL YMKSET(1,NMSIZZ,MKPIP,JPAFPB)
        CALL YMKZER(1,NMSIZZ,MKLAM)
        CALL YMKSET(1,NMSIZZ,MKLAM,JPAFPR)
        CALL YMKSET(1,NMSIZZ,MKLAM,JPAFPM)
        CALL YMKZER(1,NMSIZZ,MKLAB)
        CALL YMKSET(1,NMSIZZ,MKLAB,JPAFPB)
        CALL YMKSET(1,NMSIZZ,MKLAB,JPAFPP)
        LFIRST=.FALSE.
      ENDIF
C
C-- Initialize bank pointers
      CALL YDEFRF(KFRFT0,KFRFT,KFRTL,IFAIL)
      IF(IFAIL.NE.0) GOTO 999
C
C-- Add multiple scattering component to ITC-TPC track errors
C-- and copy them to an array
C multiple scattering in THE FOLLOWING SECTION is slightly incorrect
C when e.g. vertex is in ITC but no ITC hits are found (FRFT0 gets
C errors at first measured point on track)
      IF(KFRFT0.EQ.0) THEN
        DO I=1,LROWS(KFRFT)
          IF(I.LE.MAXTRK) THEN
            IFRFT=KROW(KFRFT,I)
            DO J=1,15
              VHXIN(J,I,1)=RW(IFRFT+JFRFEM+J-1)
            ENDDO
          ENDIF
        ENDDO
      ELSE
        DO 40 I=1,LROWS(KFRFT0)
          IF(I.GT.MAXTRK) GOTO 40
          IFRFT0=KROW(KFRFT0,I)
          DO 41 J=1,15
   41     VHXIN(J,I,1)=RW(IFRFT0+JFRFEM+J-1)
          NITC=ITABL(KFRTL,I,JFRTNI)
   40   CONTINUE
      ENDIF
C-- save ITC-TPC-VDET track errors
C-- check that VDET track bank exists
      IF(KFRFT.EQ.KFRFT0) GOTO 44
      DO 42 I=1,LROWS(KFRFT)
        IFRFT=KROW(KFRFT,I)
        IF(I.GT.MAXTRK) GOTO 42
        DO 43 J=1,15
   43   VHXIN(J,I,2)=RW(IFRFT+JFRFEM+J-1)
   42 CONTINUE
   44 CONTINUE
C
C find k0's and lambdas
C     select tracks compatible with pion or proton assignement
      II=0
      KODE=0
      DO 70 K=1,NGTRTO
        I=IPTRTO(K)
        IF(I.EQ.0) GOTO 70
C     reject itc only tracks
        KODE=1
        IF(ITABL(KFRTL,I,JFRTNT)+ITABL(KFRTL,I,JFRTNV).EQ.0) GO TO 69
C
C     REJECT TRACKS ORIGINATING FROM GAMMA CONVERSIONS
        CALL YMKAND(1,NMSIZZ,JPAFPH,KPORF0(I),IDUM,LMRK)
        KODE=2
        IF(.NOT.LMRK) GO TO 69
C
C     reject tracks with large z-distance from beam crossing
        Z0=RTABL(KFRFT,I,JFRFZ0)
        DZ0=SQRT(RTABL(KFRFT,I,JFRFEM+14))
        TANTH=RTABL(KFRFT,I,JFRFTL)
        SINTH=TANTH/SQRT(1.+TANTH**2)
        DZMAX=PSMAX/ABS(PRECTO(I))*RMAX/SINTH**2 + DZMXV0
        KODE=3
        IF(ABS(Z0).GT.(DZMAX+3.*DZ0)) GO TO 69
C     REQUIRE POSSIBLE PION OR PROTON ASSIGNEMENT
        CALL YMKAND(1,NMSIZZ,MKPIP,KPIDF0(I),IDUM,LMRK)
        KODE=4
        IF(.NOT.LMRK) THEN
          II=II+1
          IPTR(II)=I
          GO TO 70
        ENDIF
 69     CONTINUE
   70 CONTINUE
C     LOOP OVER PAIRS WITH OPPOSITE CHARGE
      IF(II.LT.2) GO TO 82
CALCULATE IMPACT PARAMETER CHISQ FOR FRFT 0 AND 2
      DO 85 I=1,II
        IIP=IPTR(I)
        KFRFTT=KFRFT
        DO 84 IFR=2,1,-1
          IF(IFR.EQ.1)KFRFTT=KFRFT0
          IF(IFR.EQ.2.AND.KFRFT0.EQ.KFRFT) GO TO 84
          IF(IFR.EQ.1.AND.KFRFT0.EQ.0) GO TO 84
          CALL YFTVTR(1,1,0,.FALSE.,BCROSS,VBCROS,IIP,
     &      LCOLS(KFRFTT),LVHXIN,
     &      RW(KFRFTT+LMHLEN+JFRFIR),VHXIN(1,1,IFR),
     &      IDUM,IDUM,IDUM,DUM,DUM,WTX,VARWX,XIMPA(IIP,IFR),IFAIL)
          XIMPA(IIP,1)=XIMPA(IIP,IFR)
   84   CONTINUE
        IF(LDMP2)
     +       WRITE(LOUT,'('' TRK '',I3,'' IMPAR '',2F9.4)')
     +       IIP,(XIMPA(IIP,IFR),IFR=1,2)
   85 CONTINUE
C
      II1=II-1
      DO 81 I=1,II1
        I1=I+1
        IIP=IPTR(I)
        DO 90 J=I1,II
          IP=IIP
          JJP=IPTR(J)
          VZFL='PREP'
          JP=JJP
          IF(PRECTO(IP)*PRECTO(JP).GT.0.) THEN
            GO TO 80
          ENDIF
          IF(PRECTO(IP).LT.0.) THEN
C     TAKE POSITIVE PARTICLE FIRST
            IP=JJP
            JP=IIP
          ENDIF
          IXHX(1)=IP
          IXHX(2)=JP
C     CHECK IF MASS ASSIGNENT IS COMPATIBLE WITH K0   OR LAMBDA
          CALL YMKORR(1,NMSIZZ,KPIDF0(IP),KPIDF0(JP),KPOR)
          NPIDC=0
          KFRID=IW(NAMIND('FRID'))
          CALL YMKAND(1,NMSIZZ,MKPI,KPOR,KPTST,LMRK)
          IF(KPTST.EQ.MKPI) THEN
            IF(RTABL(KFRID,IP,JFRIPI).GE.PIPKV0.AND.
     &        RTABL(KFRID,JP,JFRIPI).GE.PIPKV0) THEN
              NPIDC=NPIDC+1
              AMPC(1,NPIDC)=YPMASS(JPAFPP)
              AMPC(2,NPIDC)=YPMASS(JPAFPM)
              IMASS(NPIDC)=JPAFKZ
              AMNOM(NPIDC)=YPMASS(JPAFKZ)
            ENDIF
          ENDIF
          CALL YMKAND(1,NMSIZZ,MKLAM,KPOR,KPTST,LMRK)
          IF(KPTST.EQ.MKLAM) THEN
            IF(RTABL(KFRID,IP,JFRIPP).GE.PRPLV0.AND.
     &        RTABL(KFRID,JP,JFRIPI).GE.PIPLV0) THEN
              NPIDC=NPIDC+1
              AMPC(1,NPIDC)=YPMASS(JPAFPR)
              AMPC(2,NPIDC)=YPMASS(JPAFPM)
              IMASS(NPIDC)=JPAFLA
              AMNOM(NPIDC)=YPMASS(JPAFLA)
            ENDIF
          ENDIF
          CALL YMKAND(1,NMSIZZ,MKLAB,KPOR,KPTST,LMRK)
          IF(KPTST.EQ.MKLAB) THEN
            IF(RTABL(KFRID,IP,JFRIPI).GE.PIPLV0.AND.
     &        RTABL(KFRID,JP,JFRIPP).GE.PRPLV0) THEN
              NPIDC=NPIDC+1
              AMPC(1,NPIDC)=YPMASS(JPAFPP)
              AMPC(2,NPIDC)=YPMASS(JPAFPB)
              IMASS(NPIDC)=JPAFLB
              AMNOM(NPIDC)=YPMASS(JPAFLB)
            ENDIF
          ENDIF
          IF(NPIDC.EQ.0)  THEN
            GO TO 80
          ENDIF
C
C  FIT VERTEX ONLY
          KFRFTU=KFRFT
          IF(KFRFT0.NE.0) KFRFTU=KFRFT0
C CHECK IF VDET TRACKS AVAILABLE
          KMAL=2
          IF(KFRFT.EQ.KFRFT0) KMAL=1
          IYSTFL=0
C SET FLAGS AND CHISQ,S
          CHVX2=-1.
          CHIVS=-1.
          NADD=-1.
          CHIFM=-1.
          CHIS2=-1.
          VZFL='REJE'
          CALL YSTVTX(IXHX,
     +      RW(KFRFTU+LMHLEN+JFRFIR+LCOLS(KFRFTU)*(IXHX(1)-1)),
     +      RW(KFRFTU+LMHLEN+JFRFIR+LCOLS(KFRFTU)*(IXHX(2)-1)),
     +IFLAG,ISTO,VTXSTT,IBVD,LDMP1)
          IYSTFL=IFLAG
C DEBUG----------------------------------
          IF(IFLAG.NE.0) GO TO 80
          LVAPP=.FALSE.
          IF(ISTO.NE.1) LVAPP=.TRUE.
          KOFRF=1
          CHOL=100000.
          DO 60 MAL=1,KMAL
C  FIRST FIT VERTEX WITH FRFT NUMBER 0 IE TRACKS WITHOUT VDET HITS
C
            CALL YFTVTR(0,2,0,LVAPP,VTXSTT,DUMY,IXHX,
     &        LCOLS(KFRFTU),LVHXIN,
     &        RW(KFRFTU+LMHLEN+JFRFIR),VHXIN(1,1,MAL),
     &        IDUM,IDUM,IDUM,DUM,DUM,VTX2,VARV2,CHVX2,IFAIL)
C
C STORE VALUES WITHOUT VDET
            IF(MAL.EQ.1) THEN
              CALL UCOPY( VTX2,VTOL,3)
              CALL UCOPY( VARV2,VAROL,6)
              CHOL=CHVX2
              KFOL=KFRFTU
              KOFL=KOFRF
            ENDIF
            NAL=MAL
C NOW LOOK IF WE HAVE VDET HITS BEHIND THE VERTEX
            IF(MAL.EQ.2.OR.KMAL.EQ.1) GO TO 60
            RVE=SQRT(VTX2(1)**2+VTX2(2)**2)
            CALL YVDCOF(IXHX(1),NUMC1,XYZCO,RADC1,FIICO,ZETCO,NCOM1,
     &        LDMP2)
            CALL YVDCOF(IXHX(2),NUMC2,XYZCO,RADC2,FIICO,ZETCO,NCOM2,
     &        LDMP2)
C IF BOTH TRACKS HAVE 2 COMPLETE HITS CONTINUE IN ANY CASE
            IF(NCOM1.GE.2.AND.NCOM2.GE.2) GO TO 59
C IF BOTH TRACKS HAVE NO HIT INFORMATION (MINI) REFIT IF RADIUS < 6 CM
            IF(NCOM1.EQ.-1.AND.NCOM2.EQ.-1) THEN
              IF(RVE.LE.6.) GO TO 59
              GO TO 61
            ENDIF
C OTHERWISE, IF THE VDET HITS ARE IN FRONT OF THE FOUND VTX IGNORE THEM
            IF(NUMC1.GT.0 .AND. RADC1(1).LT.RVE) GOTO 61
            IF(NUMC2.GT.0 .AND. RADC2(1).LT.RVE) GOTO 61
            IF(NUMC1.EQ.0 .AND. NUMC2.EQ.0) GO TO 61
   59       CONTINUE
C REFIT INCLUDING VDET HITS
            KFRFTU=KFRFT
            KOFRF=2
   60     CONTINUE
   61     CONTINUE
C
          IF(IFAIL.NE.0.OR.CHVX2.GT.CHVXV0) GO TO 80
C     REQUIRE VERTEX SEPARATED FROM BEAM CROSSING
          DVX2=0.
          DO JJ=1,3
            VTXX(JJ,1)=BCROSS(JJ)
            VTXX(JJ,2)=VTX2(JJ)
            DVX2=DVX2+(VTX2(JJ)-BCROSS(JJ))**2
          ENDDO
          VDIST=SQRT(DVX2)
          DO JJ=1,6
            VVTXX(JJ,1)=VBCROS(JJ)
            VVTXX(JJ,2)=VARV2(JJ)
          ENDDO
C STORE IMPACT PARAMETER CHISQ IN CHIMP
          CHIMP(1)=XIMPA(IXHX(1),KOFRF)
          CHIMP(2)=XIMPA(IXHX(2),KOFRF)
          DO ISP=1,2
            IF(LDMP2)
     +        WRITE(LOUT,'('' TRK '',I3,'' IMPAR '',F19.4,2I5)')
     +        IXHX(ISP),CHIMP(ISP),IFAIL,KOFRF
          ENDDO


          CALL YFTVTR(2,0,0,.FALSE.,VTXX,VVTXX,IDUM,
     &      IDUM,IDUM,
     &      DUM,DUM,
     &      IDUM,IDUM,IDUM,DUM,DUM,WTX,VARWX,CHIVS ,IFAIL)
          IF(CHIVS.LT.CHVSV0) THEN
            GO TO 80
          ENDIF
C
C
C     REJECT V0'S WITH ADDITIONAL TRACKS PASSING THROUGH VERTEX
C
          NADD=0
          DO KK=1,II
            KP=IPTR(KK)
            IF(IP.NE.KP.AND.JP.NE.KP) THEN
              CALL YFTVTR(1,1,0,.FALSE.,VTX2,VARV2,KP,
     &          LCOLS(KFRFTU),LVHXIN,
     &          RW(KFRFTU+LMHLEN+JFRFIR),VHXIN(1,1,KOFRF),
     &          IDUM,IDUM,IDUM,DUM,DUM,WTX,VARWX,CHISA,IFAIL)
              IF(CHISA.LT.CONLM(2)) THEN
                NADD=NADD+1
                ITADD(NADD)=KP
                IF(NADD.GT.NAMXV0) THEN
                  GO TO 80
                ENDIF
              ENDIF
            ENDIF
          ENDDO
C
C  FIT VERTEX AND MASS
          CALL YFMVTR(0,2,0,.FALSE.,.TRUE.,.TRUE.,.TRUE. ,
     &      VTX2,VVXIN,IXHX,
     &      LCOLS(KFRFTU),LVHXIN,
     &      RW(KFRFTU+LMHLEN+JFRFIR),VHXIN(1,1,KOFRF),
     &      IXNU,
     &      NSNU,NSVNU,TNUI,VTNUI,
     &      NPIDC,AMPC,
     &      VXOUT,VVXOU,HXOU,VHXOU,TNUO,VTNUO,
     &      PSUM,VPSUM,VPSVX,
     &      AMASS,DMASS,VMVX,VMPS,
     &      CHISQ,IFAIL)
C
          IF(IFAIL.GT.0) GOTO 80
C
          CALL YTPAR(0,VXOUT,VVXOU,PSUM,VPSUM,VPSVX,
     &      TRACK,VTRACK,IFAIL)
          IF(IFAIL.GT.0) GOTO 80
C
C POINTING CHISQ OF RECONSTRUCTED V0 W.R.T BCRO
          IXNU(1)=1
          CALL YFTVTR(1,0,1,.FALSE.,BCROSS,VBCROS,
     &      IDUM,IDUM,IDUM,
     &      DUM,DUM,
     &      IXNU,5,15,TRACK,VTRACK,VXOU2,VVXO2,CHIS2,IFAIL)
          IF(IFAIL.GT.0)GOTO 80
C-- CUT ON THE POINTING CHISQ (2 D.O.F.)
          IF(CHIS2.GT.CHPTV0) GOTO 80
C
C
C-----FLAG FOR LATER BANK STORAGE
          LACC=.FALSE.
C
          NA=0
          DO 79 IA=1,NPIDC
C
            XML=CHMLV0*DMASS(IA)**2
            IF(XML.LT.0.) XML=0.25**2
            IF(((AMASS(IA)-AMNOM(IA))**2).GT.XML) THEN
            ELSE
C
              IF(LV0SMC) THEN
C  MASS CONSTRAINED VERTEX FIT
C
                AMCON=YPMASS(IMASS(IA))
                DMCON=AMAX1(0.1E-3,ABS(AMASS(IA)-AMCON)/10.)
                DMQCON=2.*AMCON*DMCON
                CALL YFVMC(0,2,0,.FALSE.,
     &            VTX2,VVXIN,IXHX,
     &            LCOLS(KFRFTU),LVHXIN,
     &            RW(KFRFTU+LMHLEN+JFRFIR),VHXIN(1,1,KOFRF),
     &            IXNU,
     &            NSNU,NSVNU,TNUI,VTNUI,
     &            AMPC(1,IA),AMCON,DMQCON,
     &            VXOUT,VVXOU,HXOU,VHXOU,TNUO,VTNUO,
     &            PSUM,VPSUM,VPSVX,
     &            BMASS,EMASS,
     &            CHISQ,IFAIL)
C
                 IF(IFAIL.NE.0.OR.CHISQ.GT.CHVXV0) GO TO 79
C
              ENDIF
C
              NA=NA+1
              JA(NA)=IA
              CALL YMKSET(1,NMSIZZ,KPORF0(IP),IMASS(IA))
              CALL YMKSET(1,NMSIZZ,KPORF0(JP),IMASS(IA))
C  ---
              LACC=.TRUE.
              VZFL='ACCE'
C  ---
            ENDIF
   79     CONTINUE
C-----
          IF (LACC) THEN
C-- save the reconstructed V0-vertex in the bank PYER
C----- output to BOS-BANK PYER
            LGARB=.FALSE.
C           KPYER=IW(NAMIND('PYER'))
            KPYER=NLINK('PYER',0)
            IF(KPYER.GT.0) THEN
C----- bank already exists
              KLAST = LROWS(KPYER)+1
            ELSE
              KLAST = 1
            ENDIF
            KYWI  = LPYERA*KLAST
C----- we book here the space for the bank
            CALL AUBOS('PYER',0,LMHLEN+KYWI,KPYER,IRET)
C----- ? no space
            IF(IRET.EQ.2) GOTO 997
            IF(IRET.EQ.1) LGARB=.TRUE.
            IW(KPYER+LMHCOL) = LPYERA
            IW(KPYER+LMHROW) = KLAST
C-----?
            IPYER = KROW(KPYER,KLAST)
C----- store information
C----- type of Vertex 1 main 2=v0 3=main vtx for 2-prongs
C                            4=gamma conversion
            IW(IPYER+JPYETY)      = 2
C-- copy the vertex position
            CALL UCOPY(VXOUT(1),RW(IPYER+JPYEVX),3)
C-- copy the variances
C----- covariance matrix 1 2 4
C                          3 5
C                            6
            CALL UCOPY(VVXOU(1),RW(IPYER+JPYEVM),6)
C-- copy the chisq
C----- C2 Chisquare 0.0 ...255.
            RW(IPYER+JPYEC2) = CHISQ
C-- copy the number of degrees of freedom,
C--   2x2 for each track - 3 for vertex constraint
            IW(IPYER+JPYEDF) = 1


C----- still to do

C-- save the track indices belonging to the secondary vertex
C-- in the bank PYFR
            KPYFR=IW(NAMIND('PYFR'))
            IF(KPYFR.GT.0) THEN
C----- bank already exists
              NRPYF = LROWS(KPYFR)+2
            ELSE
              NRPYF = 2
            ENDIF
            CALL AUBOS('PYFR',0,LMHLEN+LPYFRA*NRPYF,KPYFR,IRET)
            IF(IRET.EQ.2) GOTO 996
            IF(IRET.EQ.1) LGARB=.TRUE.
            IW(KPYFR+LMHCOL) = LPYFRA
            IW(KPYFR+LMHROW) = NRPYF
            DO 300 ITR = 1,2
              IPYFR = KROW(KPYFR,ITR+NRPYF-2)
C----- Vertex number
              IW(IPYFR+JPYFVN) = KLAST
C----- Track number
              IW(IPYFR+JPYFTN) = IXHX(ITR)
  300       CONTINUE
C
C-- save the incoming v0-track in the bank ynft
C      output to bos-bank pyer
            KYNFT=IW(NAMIND('YNFT'))
            IF(KYNFT.GT.0) THEN
C      bank already exists
              KLAST = LROWS(KYNFT)+1
            ELSE
              KLAST = 1
            ENDIF
C
C  INDEX OF NEUTRAL TRACK
            INU=KLAST
C  SET PARTICLE IDENTIFICATION FLAG
            JP=INU+MAXHLX
            DO IJ=1,NA
              IA=JA(IJ)
              CALL YMKSET(1,NMSIZZ,KPIDF0(JP),IMASS(IA))
            ENDDO
C
            KYWI  = LYNFTA*KLAST
C      WE BOOK HERE THE SPACE FOR THE BANK
            CALL AUBOS('YNFT',0,LMHLEN+KYWI,KYNFT,IRET)
C      ? NO SPACE
            IF(IRET.EQ.2) GOTO 995
            IF(IRET.EQ.1) LGARB=.TRUE.
            IW(KYNFT+LMHCOL) = LYNFTA
            IW(KYNFT+LMHROW) = KLAST
C
            IYNFT = KROW(KYNFT,KLAST)
C      store information
C-- copy the track parameters
            CALL UCOPY(TRACK(1),RW(IYNFT+JYNFMO),5)
C-- copy the variances
C      covariance matrix 1 2 4 7 11
C                          3 5 8 12
C                            6 9 13
C                             10 14
C                                15
            CALL UCOPY(VTRACK(1),RW(IYNFT+JYNFEM),15)
C-- copy the chisq
C      C2 Chisquare
            RW(IYNFT+JYNFC2) = CHISQ
C-- copy the # of deg. of freedom, 2 x ntr - 3 (+1 for mass constraint)
            IW(IYNFT+JYNFDF) = 1
            IF(LV0SMC) IW(IYNFT+JYNFDF) = 2
C
C-- particle charge
            IW(IYNFT+JYNFCH) = 0
C-- number of daughter tracks
            IW(IYNFT+JYNFND) = 2
C-- number of mass assignements
            IW(IYNFT+JYNFNM) = NA
C-- pointing chisq
            RW(IYNFT+JYNFPC) = CHIS2
C
C-- fill daughter track bank  YNTR
            KYNTR=IW(NAMIND('YNTR'))
            IF(KYNTR.GT.0) THEN
C      bank already exists
              KLAST = LROWS(KYNTR)+2*NA
            ELSE
              KLAST = 2*NA
            ENDIF
            KYWI  = LYNTRA*KLAST
C      we book here the space for the bank
            CALL AUBOS('YNTR',0,LMHLEN+KYWI,KYNTR,IRET)
C      ? no space
            IF(IRET.EQ.2) GOTO 995
            IF(IRET.EQ.1) LGARB=.TRUE.
            IW(KYNTR+LMHCOL) = LYNTRA
            IW(KYNTR+LMHROW) = KLAST
C
            IYNTR = KROW(KYNTR,KLAST-2*NA+1)
C      store information
            DO 331 IM=1,NA
              DO 330 ITR=1,2
C-- save the mother track number
                IW(IYNTR+LYNTRA*((IM-1)*2+ITR-1)+JYNTMT) = LROWS(KYNFT)
C-- save the daughter track number
                IW(IYNTR+LYNTRA*((IM-1)*2+ITR-1)+JYNTDT) = IXHX(ITR)
C-- save the daughter track type
                IW(IYNTR+LYNTRA*((IM-1)*2+ITR-1)+JYNTTT) = 1
C-- save the VDET bit pattern
                IW(IYNTR+LYNTRA*((IM-1)*2+ITR-1)+JYNTBP) = 0
                IF(KOFRF.EQ.2)
     +            IW(IYNTR+LYNTRA*((IM-1)*2+ITR-1)+JYNTBP) = IBVD(ITR)
C-- save the impact parameter chisq
                RW(IYNTR+LYNTRA*((IM-1)*2+ITR-1)+JYNTIM) = CHIMP(ITR)

  330         CONTINUE
C-- save the mass assign to the daughter using ALEPH particle table
C-- positive particle comes in first position
C-- check if first particle is pion or proton (code 3 or 5 according
C--                                            to G.Lutz nomenclature)
              IF(AMPC(1,JA(IM)).EQ.YPMASS(JPAFPP))
     &          IW(IYNTR+LYNTRA*(IM-1)*2+JYNTMA) = 8
              IF(AMPC(1,JA(IM)).EQ.YPMASS(JPAFPR))
     &          IW(IYNTR+LYNTRA*(IM-1)*2+JYNTMA) = 14
              IF(AMPC(2,JA(IM)).EQ.YPMASS(JPAFPM))
     &          IW(IYNTR+LYNTRA*((IM-1)*2+1)+JYNTMA) = 9
              IF(AMPC(2,JA(IM)).EQ.YPMASS(JPAFPB))
     &          IW(IYNTR+LYNTRA*((IM-1)*2+1)+JYNTMA) = 15
  331       CONTINUE
C
C
C-- fill 3-momentum bank  YNPE
            KYNPE=IW(NAMIND('YNPE'))
            IF(KYNPE.GT.0) THEN
C      bank already exists
              KLAST = LROWS(KYNPE)+1
            ELSE
              KLAST = 1
            ENDIF
            KYWI  = LYNPEA*KLAST
C      we book here the space for the bank
            CALL AUBOS('YNPE',0,LMHLEN+KYWI,KYNPE,IRET)
C      ? no space
            IF(IRET.EQ.2) GOTO 995
            IF(IRET.EQ.1) LGARB=.TRUE.
            IW(KYNPE+LMHCOL) = LYNPEA
            IW(KYNPE+LMHROW) = KLAST
C
            IYNPE=KROW(KYNPE,KLAST)
C      store information
            CALL UCOPY(PSUM,RW(IYNPE+JYNPPX),3)
C
C-- fill  mass assignment bank  YNMA
            KYNMA=IW(NAMIND('YNMA'))
            IF(KYNMA.GT.0) THEN
C      bank already exists
              KLAST = LROWS(KYNMA)+NA
            ELSE
              KLAST = NA
            ENDIF
            KYWI  = LYNMAA*KLAST
C      we book here the space for the bank
            CALL AUBOS('YNMA',0,LMHLEN+KYWI,KYNMA,IRET)
C      ? no space
            IF(IRET.EQ.2) GOTO 995
            IF(IRET.EQ.1) LGARB=.TRUE.
            IW(KYNMA+LMHCOL) = LYNMAA
            IW(KYNMA+LMHROW) = KLAST
C
            IYNMA = KROW(KYNMA,KLAST-NA+1)
C      store information
            DO 340 IM = 1,NA
C-- save the mother track number
              IW(IYNMA+LYNMAA*(IM-1)+JYNMMT) = LROWS(KYNFT)
C-- save the particle assignment :
C-- first case K0 short
              IF(AMPC(1,JA(IM)).EQ.YPMASS(JPAFPP).AND.AMPC(2,JA(IM)).EQ.
     *          YPMASS(JPAFPM))
     &          IW(IYNMA+LYNMAA*(IM-1)+JYNMPA) =16
C-- second case anti-lamda0
              IF(AMPC(1,JA(IM)).EQ.YPMASS(JPAFPP).AND.AMPC(2,JA(IM)).EQ.
     *          YPMASS(JPAFPB))
     &          IW(IYNMA+LYNMAA*(IM-1)+JYNMPA) =26
C-- THIRD CASE LAMDA0
              IF(AMPC(1,JA(IM)).EQ.YPMASS(JPAFPR).AND.AMPC(2,JA(IM)).EQ.
     +          YPMASS(JPAFPM))
     &          IW(IYNMA+LYNMAA*(IM-1)+JYNMPA) =18
C-- save the mass
              RW(IYNMA+LYNMAA*(IM-1)+JYNMMA) = AMASS(JA(IM))
C-- save the error on the mass
              RW(IYNMA+LYNMAA*(IM-1)+JYNMEM) = DMASS(JA(IM))
C-- save the vertex distance
              RW(IYNMA+LYNMAA*(IM-1)+JYNMVD) = VDIST
C-- save the chisq vertex separation
              RW(IYNMA+LYNMAA*(IM-1)+JYNMSC) = CHIVS
C-- save the impact parameter chisq
              RW(IYNMA+LYNMAA*(IM-1)+JYNMIC) = CHIS2
C-- save the numb. of add. tracks in V0 vertex
              IW(IYNMA+LYNMAA*(IM-1)+JYNMNA) = NADD
C-- save the particle assignment probability of V0 decay tracks
C   (positive track first)
C-- first case K0 short
              IF(AMPC(1,JA(IM)).EQ.YPMASS(JPAFPP).AND.AMPC(2,JA(IM)).EQ.
     *          YPMASS(JPAFPM))THEN
                IW(IYNMA+LYNMAA*(IM-1)+JYNMPR) = RTABL(KFRID,IXHX(1),
     &            JFRIPI)
                IW(IYNMA+LYNMAA*(IM-1)+JYNMPR+1)=RTABL(KFRID,IXHX(2),
     &            JFRIPI)
              ENDIF
C-- second case anti-lamda0
              IF(AMPC(1,JA(IM)).EQ.YPMASS(JPAFPP).AND.AMPC(2,JA(IM)).EQ.
     *          YPMASS(JPAFPB))THEN
                IW(IYNMA+LYNMAA*(IM-1)+JYNMPR) = RTABL(KFRID,IXHX(1),
     &            JFRIPI)
                IW(IYNMA+LYNMAA*(IM-1)+JYNMPR+1)=RTABL(KFRID,IXHX(2),
     &            JFRIPP)
              ENDIF
C-- THIRD CASE LAMDA0
              IF(AMPC(1,JA(IM)).EQ.YPMASS(JPAFPR).AND.AMPC(2,JA(IM)).EQ.
     +          YPMASS(JPAFPM))THEN
                IW(IYNMA+LYNMAA*(IM-1)+JYNMPR) = RTABL(KFRID,IXHX(1),
     &            JFRIPP)
                IW(IYNMA+LYNMAA*(IM-1)+JYNMPR+1)=RTABL(KFRID,IXHX(2),
     &            JFRIPI)
              ENDIF
  340       CONTINUE
C
C-- save relative pointers in between banks
C-- watch for garbage collection
            IF(LGARB) THEN
C       KPYER=IW(NAMIND('PYER'))
              KPYER=NLINK('PYER',0)
              KYNFT=IW(NAMIND('YNFT'))
              KYNTR=IW(NAMIND('YNTR'))
              KYNMA=IW(NAMIND('YNMA'))
            ENDIF
            LPYER=LROWS(KPYER)
            IPYER=KROW(KPYER,LPYER)
            LYNFT=LROWS(KYNFT)
            IYNFT=KROW(KYNFT,LYNFT)
            LYNMA=LROWS(KYNMA)
            IYNMA=KROW(KYNMA,LYNMA-NA+1)
            LYNTR=LROWS(KYNTR)
            IYNTR=KROW(KYNTR,LYNTR-NA*2+1)
C      IW(IPYER+JPYEPR)=LYNFT
            IW(IYNFT+JYNFPV)=LPYER
            IW(IYNFT+JYNFPM)=LYNMA-NA+1
            IW(IYNFT+JYNFPT)=LYNTR-NA*2+1
            DO 350 IM=1,NA
              IW(IYNMA+LYNMAA*(IM-1)+JYNMMT)=LYNFT
              DO 351 ITR=1,2
  351         IW(IYNTR+LYNTRA*((IM-1)*2+ITR-1)+JYNTMT)=LYNFT
  350       CONTINUE
C  --- end of bank output
C
            DO 1340 IM = 1,NA
C--   fill the summary information
C-- first case K0 short
              IF(AMPC(1,JA(IM)).EQ.YPMASS(JPAFPP).AND.AMPC(2,JA(IM)).EQ.
     *          YPMASS(JPAFPM)) THEN
                NRK0TO = NRK0TO + 1
                PPS =  SQRT(PSUM(1)**2+PSUM(2)**2+PSUM(3)**2)
                AMK0TO = AMK0TO + PPS
                ACK0TO = ACK0TO + CHISQ
                ATK0TO = ATK0TO + VDIST*
     &            YPMASS(JPAFKZ)/SQRT(YPMASS(JPAFKZ)**2+PPS**2)/3.E+10
              ENDIF
C-- second case anti-lamda0
              IF(AMPC(1,JA(IM)).EQ.YPMASS(JPAFPP).AND.AMPC(2,JA(IM)).EQ.
     *          YPMASS(JPAFPB)) THEN
                NRLBTO = NRLBTO + 1
                PPS =  SQRT(PSUM(1)**2+PSUM(2)**2+PSUM(3)**2)
                AMLBTO = AMLBTO + PPS
                ACLBTO = ACLBTO + CHISQ
                ATLBTO = ATLBTO + VDIST*
     &            YPMASS(JPAFLB)/SQRT(YPMASS(JPAFLB)**2+PPS**2)/3.E+10
              ENDIF
C-- THIRD CASE LAMDA0
              IF(AMPC(1,JA(IM)).EQ.YPMASS(JPAFPR).AND.AMPC(2,JA(IM)).EQ.
     +          YPMASS(JPAFPM)) THEN
                NRLATO = NRLATO + 1
                PPS =  SQRT(PSUM(1)**2+PSUM(2)**2+PSUM(3)**2)
                AMLATO = AMLATO + PPS
                ACLATO = ACLATO + CHISQ
                ATLATO = ATLATO + VDIST*
     &            YPMASS(JPAFLA)/SQRT(YPMASS(JPAFLA)**2+PPS**2)/3.E+10
              ENDIF
 1340       CONTINUE
C
          ENDIF
C  ---
   80     CONTINUE
   90   CONTINUE
   81 CONTINUE
   82 CONTINUE
C
      RETURN
C
  995 CALL ALTELL('YTRV0S :  no space to create bank YNFT  IER=0',0,
     &   ' RETURN ')
      GOTO 1000
  996 CALL ALTELL('YTRV0S :  no space to create bank PYFR  IER=0',0,
     &   ' RETURN ')
      GOTO 1000
  997 CALL ALTELL('YTRV0S :  no space to create bank PYER IER=0',0,
     &   ' RETURN ')
      GOTO 1000
  999 WRITE(LOUT,*) 'YTRV0S :  THE POINTER KFRFT IS 0 RETURN IER=1'
C
 1000 IER=1
      RETURN
      END
