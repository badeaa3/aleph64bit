      SUBROUTINE HCGEST
C --------------------------------------------
C
C! Implements the module GENERATE HSTREAMER
C! Saturation effects are handled in this routine
C!
C!       Authors :G.Catanesi,G.Zito 86/05/21
C!       Modified:G.Catanesi        87/01/17
C!
C!      Input bank : JDHCSE McHcTubesSegment
C!      Output bank: JDHCHI  McHcHits
C!
C!       -Called by :HCASIG
C!      -Calls      :HCNSTR from this .HLB
C!                   SORTRQ from CERNLIB
C-------------------------------------------------------
      SAVE
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON /BCS/   IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
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
      PARAMETER (LFIL=6)
      COMMON /IOCOM/   LGETIO,LSAVIO,LGRAIO,LRDBIO,LINPIO,LOUTIO
      DIMENSION LUNIIO(LFIL)
      EQUIVALENCE (LUNIIO(1),LGETIO)
      COMMON /IOKAR/   TFILIO(LFIL),TFORIO(LFIL)
      CHARACTER TFILIO*60, TFORIO*4
C
      COMMON /HCCOUN/NHCC01,NHCC02,NHCC03,NHCC04,NHCC05,HCEAVE ,HCANST,
     +               HCEPOR(3) ,FHCDEB,FHCDB1,FHCDB2
      LOGICAL FHCDEB,FHCDB1,FHCDB2
C
      PARAMETER(NHTTR=192,NHWTR=36)
      PARAMETER (MHCSE=200)
      PARAMETER(MHCTH=300)
      COMMON /HCNAMC/NAHTHT,NAHWHT,NAHTTR,NAHWTR,NAHTDI,NAHWDI, NAHTDT,
     &               NAHTTD,NAHWDT,NAHWTD,NAHPDI,NAHPHT,NAHLWD,
     &               JDHCSE,JDHCHI,JDHCTH
      PARAMETER(JHCSTN=1,JHCSLN=2,JHCSMN=3,JHCSPN=4,JHCSTA=5,JHCSTX=6,
     +          JHCSTY=7,JHCSPW=8,JHCSXA=9,JHCSYA=10,JHCSZA=11,
     +          JHCSTR=12,JHCSHT=13,JHCSFT=14,JHCSFS=15,LHCSEA=15)
      PARAMETER(JHCHTS=1,JHCHSY=2,JHCHSP=3,JHCHNS=4,LHCHIA=4)
      INTEGER HCNSTR
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
C        Loop on Tube segments (track elements intersecting
C            single tube)
C
      NHCSE = LROWS (JDHCSE)
C
C     Order track elements intersecting the same tube in the
C       y coordinate
C
      KHCSE = JDHCSE + LMHLEN
      IPREV = 0
      NELEM = 0
      DO 10 I = 1, NHCSE
         IF( IW(KHCSE+5).EQ.IPREV) THEN
            NELEM = NELEM + 1
         ELSE
            IF(NELEM.GT.1) CALL SORTRQ(IW(IEL1),LHCSEA,NELEM,7)
            IEL1 = KHCSE + 1
            IPREV = IW(KHCSE+5)
            NELEM = 1
         ENDIF
         KHCSE = KHCSE + LHCSEA
   10 CONTINUE
      IF(NELEM.GT.1) CALL SORTRQ(IW(IEL1),LHCSEA,NELEM,7)
      KHCSE = JDHCSE + LMHLEN
      IPREV = 0
      NHCHI = 0
      DO 30 I=1, NHCSE
         IF(IW(KHCSE+5).EQ.IPREV) THEN
C
C takes in account saturation effect
C
            Y1=RW(KHCHI+2)
            DY1=RW(KHCHI+3)
            Y2=RW(KHCSE+7)
            DY2=RW(KHCSE+8)
            DYT = (DY1 + DY2)/2.
            IF(DYT .GT. ABS(Y2-Y1))THEN
               DYMAX = MAX(DY1,DY2)
               IF(DYT*2.GT.DYMAX)THEN
                  RW(KHCHI+3) = DYT + ABS(Y2-Y1)
                  IF(Y1.GT.Y2)THEN
                     RW(KHCHI+2) = Y2+ABS(Y1-Y2)/2.
                  ELSE
                     RW(KHCHI+2) = Y2-ABS(Y1-Y2)/2.
                  ENDIF
               ELSE
                  RW(KHCHI+3) = DYMAX
                  IF(DY1.GE.DY2)THEN
                     RW(KHCHI+2) = Y1
                  ELSE
               RW(KHCHI+2)=Y2
                  ENDIF
               ENDIF
               GOTO 20
            ENDIF
         ENDIF
C
         NHCHI = NHCHI + 1
         KHCHI = KROW (JDHCHI,NHCHI)
         IW(KHCHI+1) = I
         RW(KHCHI+2) = RW(KHCSE+7)
         RW(KHCHI+3) = RW(KHCSE+8)
         IPREV = IW(KHCSE+5)
   20    IW(KHCSE+13) = NHCHI
   30 KHCSE = KHCSE + LHCSEA
      IW(JDHCHI+2) = NHCHI
C
      KHCHI = JDHCHI + LMHLEN
      DO 40 I=1,NHCHI
         IW(KHCHI+4) = HCNSTR (RW(KHCHI+3))
   40 KHCHI = KHCHI + LCOLS(JDHCHI)
C
C
      IF(FHCDB1)THEN
         WRITE(LOUTIO,500) NHCHI
         KHCHI = JDHCHI + LMHLEN
         WRITE (LOUTIO,510) (IW(K+1),RW(K+2),RW(K+3),IW(K+4) ,K=KHCHI,
     +   KHCHI+NHCHI*LHCHIA-1,LHCHIA)
      ENDIF
      RETURN
  500 FORMAT (/1X,'+++HCGEST+++ HCHI  McHcHits ',I5/
     +' Seg#   YStreamer   Proj.on.wi  #ofStreamer')
  510 FORMAT (I5,F11.2,F12.2,I10)
      END
