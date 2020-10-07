      SUBROUTINE  VTLINK(ITK)
C-------------------------------------------------------------
C!Track link with vertex detector clusters
CKEY VDET TRACK
C
C  Author      : B. Mours     901001
C  modified by : B, Mours     910918
C     adjust error for large pulses or double pulses
C  modified by : B, Mours     911023
C     do not associate half VDET hit to track without ITC hit
C  modified by : B, Mours     920213
C     change the definition of large pulses for increased errors
C  modified by : D Brown,   920927
C     Small change in logic for large pulseheight error assignment
C  input is the track number . (in FRFT bank)
C   Use extrapolated TPC+ITC tracks to the VDET. Do Track cluster
C   association and fill the VTMA bank.
C  modified by : A. Bonissent  950714
C     Use (year sensitive) subroutine to check that hits
C     in the two views are in the same wafer/module
C
C
C-------------------------------------------------------------
      SAVE
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON /BCS/   IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
      COMMON /VTKREC/  NLAYER,NULINK,NWLINK,IGRBMX,IERVTR,IOFVCL
     +                ,NARCVD
      INTEGER NLAYER,NULINK,NWLINK,IGRBMX,IERVTR,IOFVCL,NARCVD
      COMMON /VTRPAR/ MAXCLS,MAXCOM,IVFRFT,C2PRCL,SEACUT,CI2CUT,
     +                BIGERR,PULMIN,USNOIS,WSNOIS,HBIGER,NLYRMX
     +    ,           ELARP2,ESPLP2,DRESIU,DRESOU,DRESLW,DRESOW,CH2AMB
      INTEGER MAXCOM,MAXCLS,IVFRFT,NLYRMX
      REAL C2PRCL,SEACUT,CI2CUT,BIGERR,PULMIN,HBIGER
      REAL ELARP2,ESPLP2,DRESIU,DRESOU,DRESLW,DRESOW,CH2AMB
      PARAMETER(JVTMNL=1,JVTMNU=2,JVTMNW=3,JVTMC2=4,JVTMIT=5,JVTMFR=6,
     +          JVTMUW=7,JVTMWW=11,JVTMIU=15,JVTMIW=19,JVTMWI=23,
     +          JVTMR0=27,JVTMPH=31,JVTMZ0=35,JVTMUC=39,JVTMWC=43,
     +          JVTMSU=47,JVTMSW=51,JVTMCO=55,LVTMAA=58)
      PARAMETER(JVTSC2=1,JVTSCI=2,LVTSCA=5)
      PARAMETER(JVDXXC=1,JVDXYC=2,JVDXUC=3,JVDXSX=4,JVDXSY=5,JVDXSU=6,
     +          JVDXPH=7,JVDXQF=8,JVDXNA=9,JVDXIP=10,JVDXIW=11,
     +          JVDXIH=12,LVDXYA=12)
      PARAMETER(JVDZZC=1,JVDZWC=2,JVDZSZ=3,JVDZSW=4,JVDZPH=5,JVDZQF=6,
     +          JVDZNA=7,JVDZIP=8,JVDZIW=9,JVDZIH=10,LVDZTA=10)
      PARAMETER(JVTUWI=1,JVTUCI=5,JVTUUC=9,JVTUSU=13,JVTURC=17,
     +          JVTUPH=21,JVTURE=25,LVTUCA=28)
      PARAMETER(JVTWWI=1,JVTWCI=5,JVTWWC=9,JVTWSW=13,JVTWZC=17,
     +          JVTWRE=21,LVTWCA=24)
      PARAMETER(JFRTIV=1,JFRTNV=2,JFRTII=3,JFRTNI=4,JFRTNE=5,JFRTIT=6,
     +          JFRTNT=7,JFRTNR=8,LFRTLA=8)
      INTEGER JVTXWI,JVTXHF,JVTXUC,JVTXWC,JVTXSU,JVTXSW,
     +          JVTXUW,JVTXXC,JVTXYC,JVTXZC,JVTXPV,
     +          JVTXPU,JVTXPW,JVTXUR,JVTXUT,JVTXUP,
     +          JVTXUD,JVTXUZ,JVTXWR,JVTXWT,JVTXWP,
     +          JVTXWD,JVTXWZ,LVTXTA
      PARAMETER(JVTXWI=1,JVTXHF=2,JVTXUC=3,JVTXWC=4,JVTXSU=5,JVTXSW=6,
     +          JVTXUW=7,JVTXXC=8,JVTXYC=9,JVTXZC=10,JVTXPV=11,
     +          JVTXPU=12,JVTXPW=13,JVTXUR=14,JVTXUT=15,JVTXUP=16,
     +          JVTXUD=17,JVTXUZ=18,JVTXWR=19,JVTXWT=20,JVTXWP=21,
     +          JVTXWD=22,JVTXWZ=23,LVTXTA=23)
C
C!    local common to store work bank indices
      INTEGER KWSRT,KVTUC,KVTWC,KVTS0,KVTS1
      COMMON /VTBOS/ KWSRT, KVTUC, KVTWC, KVTS0, KVTS1
C
C  Local variables
C
      INTEGER NVTUC,NVTWC,KVTXT,JVTUC,JVTWC,JVTXT,JVTMA,KVTMA,NVTMA
      INTEGER IL,ICOMB,NXY,NZT,NCOMB,IZT,ICLSU,ICLSW,IDWFU,IDWW,NWAF
     +       ,NU,NW,NUW
      REAL    SIGMU,SIGMW,VUW(3),XYZ(3),SU(4),SW(4)
      REAL PCOR(4)
C - bit 0 (ISEPBT=1) is set in the VDXY and VDZT quality flag
C   to indicate a separated hit
      INTEGER ISEPBT
      PARAMETER (ISEPBT=1)
      LOGICAL FIRST
      DATA FIRST/.TRUE./
C
C  Include explicitly the JULIA *CD BOSEXT 5-2-91 D.BROWN
C
      EXTERNAL NLINK,NAMIND,NBANK,CHAINT,INTCHA,NDROP
      CHARACTER*4 CHAINT
      INTEGER NLINK,NAMIND,NBANK,INTCHA,NDROP
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
C
C - 1st entry
C
      IF (FIRST) THEN
         NVTMA = NAMIND('VTMA')
         NFRTL = NAMIND('FRTL')
         FIRST = .FALSE.
      ENDIF
C
C - reset the number og good clusters to 0
C
      KVTMA = IW(NVTMA)
      IW(KVTMA+LMHROW) = 0
C
C-- check if Extrapolation bank there for this track
C
      IF(NLINK('VTXT',ITK).EQ.0) GO TO 999
      IF(NLINK('VTER',ITK).EQ.0) GO TO 999
C
C
      CALL VZERO (IW(KVTUC+LMHCOL+1),IW(KVTUC)-LMHCOL)
      CALL VZERO (IW(KVTWC+LMHCOL+1),IW(KVTWC)-LMHCOL)
      CALL VZERO (IW(KVTS0+LMHCOL+1),IW(KVTS0)-LMHCOL)
      CALL VZERO (IW(KVTS1+LMHCOL+1),IW(KVTS1)-LMHCOL)
C
C-- do cluster association in U and W plan separetly
C
      CALL VTCLAS(ITK,0,NXY)
      CALL VTCLAS(ITK,1,NZT)
C
C-- do the space association: Loop over all possible U/W combinaisons,
C   compute the overall chisquare and store the good one in VTMA.
C   (remember: the last combinaison IXY=NXY & IZT=NZT is empty,
C   so we don't load it)
C
      KFRTL = IW(NFRTL)
      NITC  = ITABL(KFRTL,ITK,JFRTNI)
      KVTMA = IW(NVTMA)
      NCOMB = NXY*NZT-1
      IW(KVTMA+LMHROW) = 0
      IF(NCOMB.LE.0)             GO TO 999
      IF(NCOMB.GT.MAXCOM*MAXCOM) GO TO 999
      CALL VZERO (IW(KVTMA+LMHLEN+1),NCOMB*LVTMAA)
C
      KVTXT = NLINK('VTXT',ITK)
      DO 50 IL=1,NLAYER
         JVTXT = KROW(KVTXT,IL)
         CALL VDHTER(IW(JVTXT+JVTXWI),RW(JVTXT+JVTXPV),
     +               RW(JVTXT+JVTXPU),RW(JVTXT+JVTXPW),
     +               RW(JVTXT+JVTXUC),RW(JVTXT+JVTXWC),
     +               USNOIS,WSNOIS,SU(IL),SW(IL))
         PTOT = SQRT(RW(JVTXT+JVTXPV)**2 +
     +               RW(JVTXT+JVTXPU)**2 +
     +               RW(JVTXT+JVTXPW)**2 )
         PCOR(IL) =  ABS(RW(JVTXT+JVTXPV)) / PTOT
         JVTXT = JVTXT + LCOLS(KVTXT)
  50  CONTINUE
C
      DO 200 IXY = 1,NXY
        DO 200 IZT = 1,NZT
          IF(IXY.EQ.NXY .AND. IZT.EQ.NZT) GO TO 200
C
C-- check if the XY and ZT wafer are the same
C (remember there is only 2 wafers address in z for yx but 4 for zt)
C
          DO 100 IL = 1,NLAYER
            ICLSU = IW(KROW(KVTS0,IXY)+JVTSCI+IL-1)
            ICLSW = IW(KROW(KVTS1,IZT)+JVTSCI+IL-1)
            IF(RW(KROW(KVTUC,ICLSU)+JVTUSU+IL-1).GT.HBIGER) GO TO 100
            IF(RW(KROW(KVTWC,ICLSW)+JVTWSW+IL-1).GT.HBIGER) GO TO 100
            IDWFU = IW(KROW(KVTUC,ICLSU)+JVTUWI+IL-1)
            IDWFW = IW(KROW(KVTWC,ICLSW)+JVTWWI+IL-1)
C
C Check that u- and w-cluster are in the same module,
C VRMWF transforms the wafer identifier into a u module identifier.
C
            CALL VRMWF(IDWFW,2,IROM)
            IF(IDWFU.NE.IROM) GO TO 200
  100     CONTINUE
C
C
C-- remove track with only half a VDET cluster to reduce missaciation
C   (we cut a harder for track without ITC hits to remove conversion)
C
          IF(NLAYER.GE.2) THEN
            NU  = 0
            NW  = 0
            NUW = 0
            DO 130 IL = 1,NLAYER
              ICLSU = IW(KROW(KVTS0,IXY)+JVTSCI+IL-1)
              ICLSW = IW(KROW(KVTS1,IZT)+JVTSCI+IL-1)
              SIGMU = RW(KROW(KVTUC,ICLSU)+JVTUSU+IL-1)
              SIGMW = RW(KROW(KVTWC,ICLSW)+JVTWSW+IL-1)
              IF(SIGMU.LT.HBIGER) NU = NU+1
              IF(SIGMW.LT.HBIGER) NW = NW+1
              IF(SIGMU.LT.HBIGER .AND.
     +           SIGMW.LT.HBIGER) NUW = NUW+1
  130       CONTINUE
            IF(NU+NW.LE.1) GO TO 200
            IF(NITC.EQ.0 .AND. NUW.LE.0 .AND. MAX(NU,NW).LE.1) GO TO 200
          ENDIF
C
C-- load cluster values into VTMA bank
C
          ICOMB = LROWS(KVTMA) + 1
          IW(KVTMA+LMHROW) = ICOMB
          JVTMA = KROW(KVTMA,ICOMB)
          IW(JVTMA+JVTMNL) = NLAYER
          IW(JVTMA+JVTMNU) = 0
          IW(JVTMA+JVTMNW) = 0
          RW(JVTMA+JVTMC2) = 0.
          IW(JVTMA+JVTMIT) = ITK
          DO 150 IL=1,NLAYER
            ICLSU = IW(KROW(KVTS0,IXY)+JVTSCI+IL-1)
            ICLSW = IW(KROW(KVTS1,IZT)+JVTSCI+IL-1)
            JVTUC = KROW(KVTUC,ICLSU)
            JVTWC = KROW(KVTWC,ICLSW)
            IW(JVTMA+JVTMUW+IL-1) = IW(JVTUC+JVTUWI+IL-1)
            IW(JVTMA+JVTMWW+IL-1) = IW(JVTWC+JVTWWI+IL-1)
            IW(JVTMA+JVTMIU+IL-1) = IW(JVTUC+JVTWCI+IL-1)
            IW(JVTMA+JVTMIW+IL-1) = IW(JVTWC+JVTUCI+IL-1)
C
C-- convert U,W to x,y,z using alignement
C
            NWAF = IW(JVTMA+JVTMWW+IL-1)
            VUW(1) = 0.
            VUW(2) = RW(JVTUC+JVTUUC+IL-1)
            VUW(3) = RW(JVTWC+JVTWWC+IL-1)
            CALL VGWFXY(IW(JVTMA+JVTMWW+IL-1),VUW,XYZ)
            RW(JVTMA+JVTMUC+IL-1) = VUW(2)
            RW(JVTMA+JVTMWC+IL-1) = VUW(3)
            RW(JVTMA+JVTMR0+IL-1) = SQRT(XYZ(1)**2+XYZ(2)**2)
            RW(JVTMA+JVTMPH+IL-1) = ATAN2(XYZ(2),XYZ(1))
            RW(JVTMA+JVTMZ0+IL-1) = XYZ(3)
C
            SIGMU = RW(JVTUC+JVTUSU+IL-1)
            SIGMW = RW(JVTWC+JVTWSW+IL-1)
            IF(SIGMU.LT.HBIGER) SIGMU = SU(IL)
            IF(SIGMW.LT.HBIGER) SIGMW = SW(IL)
C
C           Check if we should increase U error
C           (for double pulse or too big pulses)
C
            PULSU = 0.
            IWAF = IW(JVTUC+JVTUWI+IL-1)
            ICL  = IW(JVTUC+JVTUCI+IL-1)
            KVDXY = NLINK('VDXY',IWAF)
            IF(KVDXY.NE.0 .AND. ICL.GT.0) THEN
              IQFLG = ITABL(KVDXY,ICL,JVDXQF)
              IF(IAND(IQFLG,ISEPBT).NE.0) SIGMU = ESPLP2
              PULSU = RTABL(KVDXY,ICL,JVDXPH)*PCOR(IL)
            ENDIF
C
C          Check if we should increase W error
C
            PULSW = 0.
            IWAF = IW(JVTWC+JVTWWI+IL-1)
            ICL  = IW(JVTWC+JVTWCI+IL-1)
            KVDZT = NLINK('VDZT',IWAF)
            IF(KVDZT.NE.0 .AND. ICL.GT.0) THEN
              IQFLG = ITABL(KVDZT,ICL,JVDZQF)
              IF(IAND(IQFLG,ISEPBT).NE.0) SIGMW = ESPLP2
              PULSW = RTABL(KVDZT,ICL,JVDZPH)*PCOR(IL)
            ENDIF
C
            IF(ABS(PULSU-PULSW).GT..35*PULMIN .AND.
     +         MIN(PULSU,PULSW).GT.1..AND.
     +         MAX(PULSU,PULSW).GT.PULMIN) THEN
C
C  Pulseheights don't match, and at least 1 is large;  Increase
C  the error for the larger pulseheight hit as for a double hit.
C
              IF(PULSU.GT.PULSW)THEN
                SIGMU = ELARP2
              ELSE
                SIGMW = ELARP2
              END IF
            ENDIF
C
            RW(JVTMA+JVTMSU+IL-1) = SIGMU
            RW(JVTMA+JVTMSW+IL-1) = SIGMW
            IF(SIGMU.LT.HBIGER) IW(JVTMA+JVTMNU) = IW(JVTMA+JVTMNU)+1
            IF(SIGMW.LT.HBIGER) IW(JVTMA+JVTMNW) = IW(JVTMA+JVTMNW)+1
            RW(JVTMA+JVTMCO+IL-1) = 0.
 150      CONTINUE
C
 200    CONTINUE
C
C
 999  CONTINUE
      RETURN
C
      END
