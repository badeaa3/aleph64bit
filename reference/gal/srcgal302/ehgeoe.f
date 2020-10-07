      SUBROUTINE EHGEOE (ILAY,X,Y,Z,U,V,W,ZSEP,XSEP,YTB,DTB,MFLSI)
C.----------------------------------------------------------------
C R.CLIFFT                            Mod. Rumpf
C! Edges geom for end cap mod.
C *** CALCULATE EDGES GEOMETRY FOR END CAP MODULES
C Calls EHPETA
C.-----------------------------------------------------------------
      SAVE
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
C
C
      DATA NCALL /0/
        IF(NCALL.EQ.0)          THEN
        NCALL = 1
        DTB=0.
        YTB=0.
        TPHB2=TAN(PIBY12)
        CALL EHPETA(XMAX,YMAX1,YMAX2,ZMAX)
      ENDIF
      MFLSI=0
C
      IVSI=SIGN(1.,V)
      IF(ILAY.EQ.1)  THEN
        YMAX=YMAX1
      ELSE
        YMAX=YMAX2
      ENDIF
C
C *** EDGE SEPERATION FOR CURRENT COORDS
C
      XEDG=XMAX-(ZMAX-Z)*TPHB2
      XSEPC=XEDG- ABS(X)
      ZSEPC=ZMAX-ABS(Z)
C
C *** EDGE SEPERATION AT BACK OR FRONT OF MODULE
C
      YTB=YMAX-IVSI*Y
      YB=IVSI*YMAX
      TH=ACOS(V)
      PH=ATAN2(W,U)
      TANTH = TAN(TH)
      ZB=Z+YTB*TANTH*SIN(PH)
      XB=X+YTB*TANTH*COS(PH)
      XSEPB=XEDG-ABS(XB)
      ZSEPB=ZMAX-ABS(ZB)
C
      IF(XSEPB.LE.0..OR.ZSEPB.LE.0..OR.XSEPC.LE.0..OR.ZSEPC.LE.0.)
     &   RETURN
      XSEP=0.5*(XSEPC+XSEPB)
      ZSEP=0.5*(ZSEPC+ZSEPB)
C
C *** CALCULATE PATH LENGTH IN MODULE
C
      DTB=SQRT((X-XB)**2+(Y-YB)**2+(Z-ZB)**2)
      MFLSI=1
C
      RETURN
      END
