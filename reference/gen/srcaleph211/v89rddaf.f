      SUBROUTINE V89RDDAF(LUN,IRUN,IFLAG)
C-----------------------------------------------------------------------
C! Read VDET constants from Data Base and fill /VDGEOS/ COMMON
CKEY VD89DES READ DBASE
C!
C!  Author         G.Triggiani    17/02/87
C!                 Completely rewritten for 1990 by Paolo Cattaneo 1/5/9
C!                 Bug fixed by John Walsh 1-11-90
C!                 Small change to face Z dimension  Dave Brown 29-9-92
C!
C!  Input :        LUN            Logical unit number of DAF file
C!                 IRUN           Run number
C!
C!  Output :       IFLAG          = 1 if routine ends successfully
C!                                = 0 if an error occourred
C!
C!  Description
C!  ===========
C!  Check existence of the banks in BOS common and their validity range.
C!  If they do not exist yet or are no longer valid try to load them
C!  from the data base file. IFLAG is set to 0 if an error occours.
C!  The routine extracts from Mini-Vertex banks all quantities needed
C!  to fill the /VDGEOS/ COMMON.
C!  Some of the variables are just copied from banks, some others are
C!  computed in this routine. If some error is found in the geometrical
C!  values IFLAG is set to 0
C!
C!  Called by :    VDET initialisation routine
C!  Calls     :    FUNCTION ALGTDB               from ALEPHLIB
C!
C-----------------------------------------------------------------------
      SAVE
C
C! define universal constants
      REAL PI, TWOPI, PIBY2, PIBY3, PIBY4, PIBY6, PIBY8, PIBY12
      REAL RADEG, DEGRA
      REAL CLGHT, ALDEDX
      PARAMETER (PI=3.141592653589)
      PARAMETER (RADEG=180./PI, DEGRA=PI/180.)
      PARAMETER (TWOPI = 2.*PI , PIBY2 = PI/2., PIBY4 = PI/4.)
      PARAMETER (PIBY6 = PI/6. , PIBY8 = PI/8.)
      PARAMETER (PIBY12= PI/12., PIBY3 = PI/3.)
      PARAMETER (CLGHT = 29.9792458, ALDEDX = 0.000307)
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON /BCS/   IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
C! VDET JULIA geometry constants
      INTEGER JVDL, JGEO, JSLOM, JSLOI, JWAFN
      PARAMETER (JVDL=2,JGEO=2,JSLOM=15,JSLOI=12,JWAFN=4)
      INTEGER NPSLLY,JSLOGM
      REAL VJRIOL,VJBIGZ,VJPHIZ,VJFPHI,VJUACT,VJWACT,VJZOFF
      COMMON /VDJGEO/  NPSLLY(JVDL),JSLOGM(JSLOM,JVDL),
     &                 VJRIOL(JVDL),VJBIGZ,VJPHIZ(JVDL),VJFPHI(JVDL),
     &                 VJWACT(JGEO),VJUACT(JGEO),VJZOFF(JWAFN,JGEO)
C! VDET UFTKAL geometry constants
      INTEGER KVDL, KFACE, KBPIP
      PARAMETER (KVDL=2, KFACE=15, KBPIP=2)
      INTEGER KDIVPV,KBPSTP
      REAL VKRF,VKUWID,VKZWID,VKPHIF,VKPHIN,UKRVAC,UKSVAC,UKSVD
      REAL UKRITC,UKSITC,UKRTPC,UKSTPC,UKSPITC,UKSPTPC
      REAL UKZICA, UKRIICA, UKROICA, UKSICA
      REAL UKZOCA, UKRIOCA, UKROOCA, UKSOCA
      COMMON /VFTKAL/ KDIVPV(KVDL),VKRF(KFACE,KVDL),VKUWID(KFACE,KVDL),
     &                VKZWID(KFACE,KVDL),VKPHIF(KFACE,KVDL),
     &                VKPHIN(KFACE,KVDL),KBPSTP,
     &                UKRVAC(KBPIP),UKSVAC(KBPIP),UKSVD(KBPIP),
     &                UKRITC,UKSITC,UKRTPC,UKSTPC,UKSPITC,UKSPTPC,
     &                UKZICA(KBPIP),UKZOCA(KBPIP),UKRIICA(KBPIP),
     &                UKRIOCA(KBPIP),UKROICA(KBPIP),UKROOCA(KBPIP),
     &                UKSICA(KBPIP),UKSOCA(KBPIP)
C! read-out geometry constants for VDET.
      INTEGER NSLOM,NWAFN,NWAFM,NGEOM,LVDCC,LVDNC,LVDL,NSLOI
C
      INTEGER NDIVZV,NDIVPV,NCERVZ
      INTEGER NSTPVD,NSTZVD,NVDPPI,NVDZPI,IOPZVD
      INTEGER NSLOCO,NSLOGM,NSLOME,NSLOWA,NSLOEL,NGEOWA
      INTEGER NVDLAY,NVDSLG,NVDMEC,NVDWAF,IPSIGN,IZSIGN
      INTEGER NSLOAD
C
      REAL VDWLEN,VDPPIT,VDZPIT,VDDIPP,VDDIPZ,VDDIZP,VDDIZZ
      REAL VDCRHO,ACTPVD,ACTZVD,VDTHCK,VDPSDM,VDBXTH,VDZOFF
      REAL VDPOFF,VDCPHI,VDTILT,ZWAFVD,VDAPPL,VDDEPL,VDLESP,VDLESZ
      REAL VDSTPH,VDSTZE,VDCEZO,VDCCCP,VDCCCZ,VDNCCP,VDNCCZ
C
      PARAMETER (LVDL=2, LVDCC=7, LVDNC=3)
      PARAMETER (NSLOM=15, NSLOI=12, NWAFN=4,NWAFM=4, NGEOM=4)
      COMMON /VDGEOS/ NDIVZV(NGEOM) , NDIVPV(LVDL) , NCERVZ(NGEOM),
     &                VDWLEN(2,NWAFM), VDPPIT(NWAFM) , VDZPIT(NWAFM),
     &                VDDIPP(NWAFM) , VDDIPZ(NWAFM) , VDDIZP(NWAFM),
     &                VDDIZZ(NWAFM), VDCRHO(NSLOM,LVDL), NSTPVD(NWAFM),
     &                NSTZVD(NWAFM) , ACTPVD(NWAFM) , ACTZVD(NWAFM) ,
     &                VDTHCK(NWAFM) , VDPSDM(NGEOM) ,  VDBXTH(NGEOM) ,
     &                VDZOFF(NWAFN,NGEOM) , VDPOFF(NSLOM,LVDL) ,
     &                VDCPHI(NSLOM,LVDL) , VDTILT(NSLOM,LVDL) ,
     &                ZWAFVD(NWAFN,NSLOM,LVDL), VDAPPL(NWAFM),
     &                VDDEPL(NWAFM) , VDLESP(NWAFM) , VDLESZ (NWAFM),
     &                VDSTPH(NWAFM) , VDSTZE(NWAFM) , NVDPPI(NWAFM),
     &                NVDZPI(NWAFM), VDCEZO(NWAFM,NGEOM), IOPZVD(LVDL),
     &                VDCCCP(NWAFM,0:LVDCC), VDCCCZ(NWAFM,0:LVDCC),
     &                VDNCCP(NWAFM,0:LVDNC), VDNCCZ(NWAFM,0:LVDNC),
     &                NSLOCO(NSLOM,LVDL) , NSLOGM(NSLOM,LVDL) ,
     &                NSLOME(NSLOM,LVDL) , NSLOWA(NSLOM,LVDL) ,
     &                NSLOEL(NSLOM,LVDL) , NGEOWA(NGEOM) ,
     &                NVDLAY, NVDSLG, NVDMEC, NVDWAF ,
     &                IPSIGN(4,2) , IZSIGN(4,2) , NSLOAD(NSLOM,LVDL)
C
      PARAMETER (NMEC = 4 )
      COMMON /VDSUPP/ VDAPLN(NMEC,2) , VMETIL(NMEC,2) , VDSPTR(NMEC) ,
     &                VDSPER(NMEC,2) ,  VDSPCB(NMEC) , VDSPCA(NMEC) ,
     &                VDSPCR(NMEC) ,  VDSPCT(NMEC) , VDSPSA(NMEC) ,
     &                VDSPGA(NMEC) ,  VDSPSP(NMEC) , NVDSPS(NMEC) ,
     &                VDHYL1 , VDHYL2 , VDHYL3 , VDHYL4 , VDHYL5 ,
     &                VDHYCE , VDHYCW , VDHYCL , VDHYCT ,
     &                VDHYST(NMEC) , VDALIR , VDALOR , VDALLA ,
     &                VDALTC , VDALTA , VDSPAT
      PARAMETER(JVWGNS=1,JVWGDI=3,JVWGRS=5,JVWGRP=7,JVWGSL=9,JVWGTK=11,
     +          JVWGAV=12,JVWGDV=13,LVWGMA=13)
      PARAMETER(JVHYLO=1,JVHYLT=2,JVHYLH=3,JVHYLF=4,JVHYLI=5,JVHYCE=6,
     +          JVHYCW=7,JVHYCL=8,JVHYCT=9,JVHYSP=10,LVHYBA=11)
      PARAMETER(JVDMAL=1,JVDMTI=3,JVDMTR=5,JVDMER=6,JVDMCB=8,JVDMCA=9,
     +          JVDMCR=10,JVDMCT=11,JVDMSA=12,JVDMGA=13,JVDMSP=14,
     +          JVDMNS=15,LVDMEA=15)
      PARAMETER(JVGMNW=1,JVGMSD=2,JVGMNC=4,JVGMVW=5,JVGMVZ=6,LVGMDA=6)
      PARAMETER(JVZEWP=1,JVZECP=5,LVZEWA=6)
      PARAMETER(JVCONF=1,JVCOOR=2,JVCONS=3,LVCODA=3)
      PARAMETER(JVDSSI=1,JVDSDP=2,JVDSVC=3,JVDSVD=4,JVDSVE=5,JVDSVG=6,
     +          LVDSLA=6)
C
      INTEGER  ALGTDB, NAMIND, GTSTUP
C
      CHARACTER*36 LIST1
C
      DATA LIST1 /'VGMDVWGMVDMEVZEWVCODVDSLVHYBVDSIVDRL'/
      DATA IVDSTP / -1/
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
C
      LOUT  = IW(6)
      IFLAG = 1
C
C - get setup code
C
      IGET  = GTSTUP ('VD',IRUN)
      IF (IGET.LE.0) GOTO 998
      IF (IVDSTP.EQ.IGET) RETURN
      IVDSTP = IGET
      IRET = ALGTDB (LUN,LIST1,-IVDSTP)
C
C?----First get the indexes to banks just read in
C
      KMD = IW(NAMIND('VGMD'))
      IF (KMD.EQ.0) GOTO 998
      KOD = IW(NAMIND('VCOD'))
      IF (KOD.EQ.0) GOTO 998
      KSL = IW(NAMIND('VDSL'))
      IF (KSL.EQ.0) GOTO 998
      KME = IW(NAMIND('VDME'))
      IF (KME.EQ.0) GOTO 998
      KGM = IW(NAMIND('VWGM'))
      IF (KGM.EQ.0) GOTO 998
      KEW = IW(NAMIND('VZEW'))
      IF (KEW.EQ.0) GOTO 998
      KYB = IW(NAMIND('VHYB'))
      IF (KYB.EQ.0) GOTO 998
      KSI = IW(NAMIND('VDSI'))
      IF (KSI.EQ.0) GOTO 998
      KRL = IW(NAMIND('VDRL'))
      IF (KRL.EQ.0) GOTO 998
C
C?----Initialize the variables function of phi at zero
C
      CALL VZERO(VDPOFF,LVDL*NSLOM)
      CALL VZERO(NSLOCO,LVDL*NSLOM)
      CALL VZERO(NSLOGM,LVDL*NSLOM)
      CALL VZERO(NSLOME,LVDL*NSLOM)
      CALL VZERO(NSLOEL,LVDL*NSLOM)
      CALL VZERO(NSLOWA,LVDL*NSLOM)
      CALL VZERO(VDTILT,LVDL*NSLOM)
      CALL VZERO(VDCRHO,LVDL*NSLOM)
      CALL VZERO(VDCPHI,LVDL*NSLOM)
      CALL VZERO(ZWAFVD,NWAFN*LVDL*NSLOM)
C
C?----Set variables in /VDGEOS/ needed by Geant3 description of VDET
C

      NVDLAY = LROWS(KOD)
      NVDSLG = LROWS(KMD)
      NVDMEC = LROWS(KME)
      NVDWAF = LROWS(KGM)
C
C?----Now the variables relates to the slot geometry.
C?----First set the number of crystals in Z
C
      DO 400 IG = 1,NVDSLG
        NDIVZV(IG) = ITABL(KMD,IG,1)
        VDPSDM(IG) = RTABL(KMD,IG,3)
        NCERVZ(IG) = ITABL(KMD,IG,4)
        NGEOWA(IG) = ITABL(KMD,IG,6)
        DO 500 IWAF = 1, NDIVZV(IG)
          VDZOFF(IWAF,IG) = RTABL(KEW,ITABL(KMD,IG,5),IWAF)
  500   CONTINUE
        DO 550 ICER = 1, NCERVZ(IG)
          VDCEZO(ICER,IG) = RTABL(KEW,ITABL(KMD,IG,5),NDIVZV(IG)+ICER)
  550   CONTINUE
  400 CONTINUE
C
      ISL = 1
      IPT = 1
      DO 200 IL = 1,NVDLAY
        NDIVPV(IL) = ITABL(KOD,IL,1)
        IOPZVD(IL) = ITABL(KOD,IL,2)
C
        DO 150 IWAF = 1, NDIVZV(1)
          IPSIGN(IWAF,IL) = ITABL(KSI,1,IWAF+NDIVZV(1)*(IL-1))
          IZSIGN(IWAF,IL) = ITABL(KSI,2,IWAF+NDIVZV(1)*(IL-1))
  150   CONTINUE
        DO 100 IPH = 1,NDIVPV(IL)
          NSLOAD(IPH,IL) = ITABL(KSL,IPT,1) - (IL-1)*NSLOI
          VDPOFF(NSLOAD(IPH,IL),IL) = RTABL(KSL,IPT,2)
          NSLOCO(NSLOAD(IPH,IL),IL) = ITABL(KSL,IPT,3)
          NSLOGM(NSLOAD(IPH,IL),IL) = ITABL(KSL,IPT,4)
          NSLOME(NSLOAD(IPH,IL),IL) = ITABL(KSL,IPT,5)
          NSLOEL(NSLOAD(IPH,IL),IL) = ITABL(KSL,IPT,6)
          NSLOWA(NSLOAD(IPH,IL),IL) = ITABL(KMD,
     &                                NSLOGM(NSLOAD(IPH,IL),IL),6)
          IPT = IPT+1
  100   CONTINUE
  200 CONTINUE
C
C?----Set dimensional quantities related with wafer strip structures
C
      DO 600 IWAF = 1,NVDWAF
C
C?----Set wafer width, strips number, read-out and strip pitch , strip l
C
        NSTZVD (IWAF) = ITABL (KGM,IWAF, 1)
        NSTPVD (IWAF) = ITABL (KGM,IWAF, 2)
        VDWLEN (1,IWAF) = RTABL (KGM,IWAF,3)
        VDWLEN (2,IWAF) = RTABL (KGM,IWAF,4)
        NVDZPI (IWAF) = ITABL (KGM,IWAF,5)
        NVDPPI (IWAF) = ITABL (KGM,IWAF,6)
        VDZPIT (IWAF) = RTABL (KGM,IWAF,7)
        VDSTZE (IWAF) = VDZPIT(IWAF) / NVDZPI(IWAF)
        VDPPIT (IWAF) = RTABL (KGM,IWAF,8)
        VDSTPH (IWAF) = VDPPIT(IWAF) / NVDPPI(IWAF)
        VDLESZ (IWAF) = RTABL (KGM,IWAF,9)
        VDLESP (IWAF) = RTABL (KGM,IWAF,10)
        VDTHCK (IWAF) = RTABL (KGM,IWAF,11)
        VDDEPL(IWAF) = RTABL(KGM, IWAF,JVWGDV)
        VDAPPL(IWAF) = RTABL(KGM, IWAF,JVWGAV)
C
C?----Set active zone sizes and gaps within crystals
C
        ACTPVD (IWAF) = VDPPIT(IWAF)*(NSTPVD(IWAF)-1)
        ACTZVD (IWAF) = VDZPIT(IWAF)*(NSTZVD(IWAF)-1)
C
C?----Set insensitive edges size
C
        VDDIPP (IWAF) = 0.5*(VDWLEN(1,IWAF)-ACTPVD(IWAF))
        VDDIZZ (IWAF) = 0.5*(VDWLEN(2,IWAF)-ACTZVD(IWAF))
        VDDIPZ (IWAF) = VDWLEN(1,IWAF) - VDLESP (IWAF)
        VDDIZP (IWAF) = VDWLEN(2,IWAF) - VDLESZ (IWAF)
C
        IF (VDDIPP(IWAF).LT.0.  .OR.
     &       VDDIPZ(IWAF).LT.0.  .OR.
     &       VDDIZP(IWAF).LT.0.  .OR.
     &       VDDIZZ(IWAF).LT.0.)  THEN
          WRITE(LOUT,982)
          GO TO 999
        ENDIF
  600 CONTINUE
C
C?----Fill /VDSUPP/ with variables concerning the support stucture
C
C Read the variables related to the hybrids structure
C
      VDHYL1 = RTABL(KYB,1,1)
      VDHYL2 = RTABL(KYB,1,2)
      VDHYL3 = RTABL(KYB,1,3)
      VDHYL4 = RTABL(KYB,1,4)
      VDHYL5 = RTABL(KYB,1,5)
      VDHYCE = RTABL(KYB,1,6)
      VDHYCW = RTABL(KYB,1,7)
      VDHYCL = RTABL(KYB,1,8)
      VDHYCT = RTABL(KYB,1,9)
      VDHYST(1) = RTABL(KYB,1,10)
      VDHYST(2) = RTABL(KYB,1,11)
      DO 40 IG = 1,NVDSLG
        IF(IG.EQ.1) THEN
          VDBXTH(IG) = (VDHYCT + VDHYCE + VDHYST(1) + VDHYCE)/2.
        ELSE
          VDBXTH(IG) = (VDHYCT + VDHYCE + VDHYST(2) + VDHYCE)/2.
        ENDIF
   40 CONTINUE
C
      DO 50 IM = 1,NVDMEC
        VDAPLN(IM,1) = RTABL(KME,IM, 1)
        VDAPLN(IM,2) = RTABL(KME,IM, 2)
        VMETIL(IM,1) = RTABL(KME,IM, 3)
        VMETIL(IM,2) = RTABL(KME,IM, 4)
        VDSPTR(IM)   = RTABL(KME,IM, 5)
        VDSPER(IM,1) = RTABL(KME,IM, 6)
        VDSPER(IM,2) = RTABL(KME,IM, 7)
        VDSPCB(IM) = RTABL(KME,IM, 8)
        VDSPCA(IM) = RTABL(KME,IM, 9)
        VDSPCR(IM) = RTABL(KME,IM, 10)
        VDSPCT(IM) = RTABL(KME,IM, 11)
        VDSPSA(IM) = RTABL(KME,IM, 12)
        VDSPGA(IM) = RTABL(KME,IM, 13)
        VDSPSP(IM) = RTABL(KME,IM, 14)
        NVDSPS(IM) = ITABL(KME,IM, 15)
C
C This section calculates some of the arrays of VDGEOS.
C In particular, VDCRHO, VDCPHI, and VDTILT are calculated inside the
C following loop. The primary database inputs are
C VDAPLN, which is the perpendicular distance from the VDET center
C         to a face.
C VDPOFF  is the azimuthal angle of the perpendicular.
C VMETIL  is the angle between the perpendicular  and a segment that pas
C         through the origin and the mid-point of the mechanical edge.
C
C The calculated quantities are
C VDCRHO  the radius of the center of the wafer.
C VDCPHI  the azimuthal angle of the wafer center.
C VDTILT  the angle between the wafer normal and a segment connecting
C         the VDET origin with the wafer center.
C
        DO 310 IL = 1,NVDLAY
          DO 300 IPH = 1,NDIVPV(IL)
            IF(NSLOME(NSLOAD(IPH,IL),IL).EQ.IM) THEN
C
C OFF is the distance along the normal to the wafer from the mechanical
C edge to the wafer center. VDHYST is the famous spacer thickness.
C VDHYCE is the thickness of the cermaics, and VDTHCK is the thickness
C of the silicon wafer. The spacer thickness is different for MPI and
C Pisa, and the overall sign of OFF depends on the layer.
C
              IF(NSLOGM(NSLOAD(IPH,IL),IL).EQ.1) THEN
                OFF = (2*IL-3)*(VDHYST(1) + VDHYCE+
     &                 VDTHCK(NSLOGM(NSLOAD(IPH,IL),IL))/2.)
              ELSE
                OFF = (2*IL-3)*(VDHYST(2) + VDHYCE+
     &                 VDTHCK(NSLOGM(NSLOAD(IPH,IL),IL))/2.)
              ENDIF
C
C RWAF and YWAF are the R and R-phi components, repspectively, of the
C segment connecting the origin and the wafer center. This in a local
C coordinate system in which phi=pi/2 coincides with the perpendicular.
C
              RWAF=VDAPLN(NSLOME(NSLOAD(IPH,IL),IL),IL) + OFF
              YWAF=VDAPLN(NSLOME(NSLOAD(IPH,IL),IL),IL)*
     &             TAN(VMETIL(IM,IL))
C
              VDCRHO(NSLOAD(IPH,IL),IL)=SQRT(RWAF**2 + YWAF**2)
C
              VDTILT(NSLOAD(IPH,IL),IL)=ATAN(YWAF/RWAF)
C
              VDCPHI(NSLOAD(IPH,IL),IL)=VDPOFF(NSLOAD(IPH,IL),IL) -
     &             VDTILT(NSLOAD(IPH,IL),IL)
C
            ENDIF
  300     CONTINUE
  310   CONTINUE
   50 CONTINUE
C
C?----Set Z offsets for wafer centers and sensitive edges
C
      IPT = 1
      DO 700 IL = 1, NVDLAY
        DO 750 IPH = 1,NDIVPV(IL)
          DO 800 IWAF = 1,NDIVZV(NSLOGM(NSLOAD(IPH,IL),IL))
            ZWAFVD(IWAF,NSLOAD(IPH,IL),IL) = VDZOFF(IWAF,NSLOGM
     &       (NSLOAD(IPH,IL),IL))- ACTZVD(NSLOWA(NSLOAD(IPH,IL),IL))/2.
            IPT = IPT + 1
  800     CONTINUE
  750   CONTINUE
  700 CONTINUE
C
C - fill /VDJGEO/ for JULIA
C
      IF (ITABL(KOD,1,JVCONS).GT.1) THEN
         NPSLLY(1) = ITABL(KOD,1,JVCONS)
         NPSLLY(2) = ITABL(KOD,2,JVCONS)
      ELSE
         IF (IVDSTP.LE.2) THEN
            NPSLLY(1) = NSLOI
            NPSLLY(2) = NSLOM
         ELSE
            NPSLLY(1) = NDIVPV(1)
            NPSLLY(2) = NSLOM
         ENDIF
      ENDIF
      DO 420 IL=1,LVDL
         DO 410 J=1,NSLOM
            JSLOGM(J,IL) = MIN (NSLOGM(J,IL),2)
 410     CONTINUE
 420  CONTINUE
      CALL UCOPY (VDZOFF,VJZOFF,JWAFN*JGEO)
C
C Approximate radii of the faces- just use the first face of each layer
C  Use the NSLOAD array to find the first face in each layer
C
        VJRIOL(1)  =  VDCRHO(NSLOAD(1,1),1)
        VJRIOL(2)  =  VDCRHO(NSLOAD(1,2),2)
C
C  Oversized length in zed, used in cylindrical extrapolation-
C  essentially, add to the active area a buffer for the non-active
C  areas (~5 cm).
C
        ITYPE = JSLOGM(NSLOAD(1,1),1)
        VJBIGZ = VDZOFF(NWAFN,1) + ACTZVD(ITYPE)/2. + 5.
C
C  Gross phi subtended by each face (not counting overlapps)
C
        VJPHIZ(1) = TWOPI/REAL(NPSLLY(1))
        VJPHIZ(2) = TWOPI/REAL(NPSLLY(2))
C
C  Now the phi at the center of the first wafer of each layer- here
C  the absence of a first face in the outer layer is more annoying,
C  requiring the stupidly complicated arrangement following; but there's
C  really no other way.
C
        VJFPHI(1) = VDCPHI(NSLOAD(1,1),1)- (NSLOAD(1,1)-1)*VJPHIZ(1)
        VJFPHI(2) = VDCPHI(NSLOAD(1,2),2)- (NSLOAD(1,2)-1)*VJPHIZ(2)
C
C  Active area of the wafers- here, take the largest possible size
C  between the phi and Z sides (IE U direction active length on the
C  phi side comes from the # of phi strips, on the Z side from the
C  length of the Z strips). Divide by two, to make later comparisons eas
C  Also add 1 strip width, just to be careful (alignment should be <50
C  microns at this stage).  This separately for the various wafer types.
C
        DO 20 ITYPE=1,JGEO
          VJUACT(ITYPE) = MAX(ACTPVD(ITYPE),VDLESZ(ITYPE))/2. + .01
          VJWACT(ITYPE) = MAX(ACTZVD(ITYPE),VDLESP(ITYPE))/2. + .01
  20    CONTINUE
C
C ===================================================================
C
C - fill /VFTKAL/ for the VDET kalman filter routine
C
      DO  190  J = 1, KVDL
        KDIVPV(J)= NDIVPV(J)
        DO  180  IFACE = 1, KDIVPV(J)
          I    = NSLOAD(IFACE,J)
          NS   = NSLOGM(I,J)
          VKRF(IFACE,J)   = VDCRHO(I,J)
          VKUWID(IFACE,J) = VDPSDM(NS)
          VKZWID(IFACE,J) = ABS(VDCEZO(2,NS)-VDCEZO(1,NS))
     +                          + VDHYL3 + 2.*VDHYL4
          VKPHIF(IFACE,J) = VDCPHI(I,J)
          VKPHIN(IFACE,J) = VDPOFF(I,J)
 180    CONTINUE
 190  CONTINUE
C
C - get beam pipe setup code
C
      KBPSTP  = GTSTUP ('BP',IRUN)
      IF (KBPSTP.LE.0) THEN
C      wrong setup code
         WRITE (IW(6),281) KBPSTP
         IFLAG = 0
         RETURN
      ENDIF
C
C ======================================================================
C
      RETURN
C
C - error : missing banks
C
  998 CONTINUE
      WRITE (LOUT,981)   IVDSTP, IGET
  999 IFLAG = 0
      RETURN
C
  281 FORMAT(1X,'+++V89RDDAF+++  wrong BPIP setup code = ',I5)
  981 FORMAT(1X,'+++V89RDDAF+++ Error during VDET banks loading ',
     &    ' missing banks or wrong setup code -  setup code ',
     &    'old and new = ',2I5)
  982 FORMAT(1X,'+++V89RDDAF+++ Incompatible crystal-strips size')
      END
