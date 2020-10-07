      SUBROUTINE V0DKPT(IFRFT,IROW,NAMB,DK,VCOS)
CKEY   QIPBTAG / INTERNAL
C ----------------------------------------------------------------------
C! Crude topological vertex, to seed other calculations
C  Called from QFNDV0
C  Author                                                D. Brown 6-9-93
C ----------------------------------------------------------------------
      IMPLICIT NONE
C
C  Global includes
C
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
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
      INTEGER IW
      REAL RW(10000)
      COMMON /BCS/ IW(10000)
      EQUIVALENCE (RW(1),IW(1))
      INTEGER LCOLS, LROWS, KROW, KNEXT, ITABL,LFRWRD, LFRROW
      REAL RTABL
      INTEGER ID, NRBOS, L
C
C  Inputs; track numbers
C
      INTEGER IFRFT,IROW(2)
C
C  Output; number of solutions, decay point and track momenta at
C  those points
C
      INTEGER NAMB
      REAL DK(3,2),VCOS(2)
C
C  Local variables
C
      INTEGER ITRK,JTRK,IAMB
      REAL thecos
      REAL R(2),D0(2),P0(2),TANL(2),Z0(2)
      REAL DEL(2),CP0(2),SP0(2),CP(2),SP(2),ARC(2)
      REAL X(2),Y(2),Z(2),DIST
      REAL XC(2),YC(2),P(2),COSL(2),SINL(2),ABR(2)
      REAL DHAT(2)
      REAL DELTA,XCR,ALPHA,BETA,GAMMA
      REAL RSIGN(2)/1.0,-1.0/,MAXD/20./
C
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
C ----------------------------------------------------------------------
C  Start
C
      NAMB = 0
C
C  Unpack the track parameters
C
      DO ITRK=1,2
        R(ITRK) = 1./RTABL(IFRFT,IROW(ITRK),1)
        TANL(ITRK) = RTABL(IFRFT,IROW(ITRK),2)
        P0(ITRK) = RTABL(IFRFT,IROW(ITRK),3)
        CP0(ITRK) = COS(P0(ITRK))
        SP0(ITRK) = SIN(P0(ITRK))
        COSL(ITRK) = 1.0/SQRT(1.0+TANL(ITRK)**2)
        SINL(ITRK) = TANL(ITRK)*COSL(ITRK)
        D0(ITRK) = RTABL(IFRFT,IROW(ITRK),4)
        Z0(ITRK) = RTABL(IFRFT,IROW(ITRK),5)
C
C  Compute some stuff
C
        ABR(ITRK) = ABS(R(ITRK))
        DEL(ITRK) = R(ITRK)-D0(ITRK)
        XC(ITRK) =  -DEL(ITRK)*SP0(ITRK)
        YC(ITRK) =   DEL(ITRK)*CP0(ITRK)
      END DO
      DELTA = SQRT( (XC(1)-XC(2))**2 + (YC(1)-YC(2))**2)
C
C  Separate the cases by the distance between circle centers
C
      IF(DELTA.GT.ABR(1)+ABR(2)-1.0)THEN
C
C  Tracks dont touch; find their closest approach points
C
        DO ITRK=1,2
          JTRK = MOD(ITRK,2)+1
          SP(ITRK) =  SIGN(1.0,R(ITRK))*(XC(JTRK)-XC(ITRK))/DELTA
          CP(ITRK) = -SIGN(1.0,R(ITRK))*(YC(JTRK)-YC(ITRK))/DELTA
          P(ITRK) = ATAN2(SP(ITRK),CP(ITRK))
          IF(ABS(P(ITRK)-P0(ITRK)).GT.PI)THEN
            IF(P(ITRK).GT.P0(ITRK))THEN
              P(ITRK) = P(ITRK)-TWOPI
            ELSE
              P(ITRK) = P(ITRK)+TWOPI
            END IF
          END IF
          ARC(ITRK) = (P(ITRK)-P0(ITRK))*R(ITRK)
          X(ITRK) = XC(ITRK)+R(ITRK)*SP(ITRK)
          Y(ITRK) = YC(ITRK)-R(ITRK)*CP(ITRK)
          Z(ITRK) = Z0(ITRK) + TANL(ITRK)*ARC(ITRK)
        END DO
C
C  Record the point
C
        DIST = SQRT((X(1)-X(2))**2+(Y(1)-Y(2))**2+
     &        (Z(1)-Z(2))**2)
        IF(DIST.LT.MAXD)THEN
          NAMB = NAMB + 1
          DK(1,NAMB) = (X(1)+X(2))/2.
          DK(2,NAMB) = (Y(1)+Y(2))/2.
          DK(3,NAMB) = (Z(1)+Z(2))/2.
C
C  Get the track directions dot productat this point
C
          VCOS(NAMB) = COSL(1)*COSL(2)*(CP(1)*CP(2)+SP(1)*SP(2))+
     &          SINL(1)*SINL(2)
        END IF
      ELSE IF(DELTA+MIN(ABR(1),ABR(2)).GT.MAX(ABR(1),ABR(2))+1.0)THEN
C
C  The tracks touch in 2 places; find them
C
C
C  Prevent from rounding errors in special cases
C  (especially two back-to-back tracks)
C
        thecos = COS(P0(1)-P0(2))
        IF     ( ABS(thecos) .LT. 0.999 ) THEN
          XCR = DEL(1)**2 + DEL(2)**2
     &          - 2.*DEL(1)*DEL(2)*thecos
        ELSEIF ( thecos .GE. 0.999 ) THEN
          XCR = (DEL(1)-DEL(2))**2
     &          + 2.*DEL(1)*DEL(2)*(1.-thecos)
        ELSEIF ( thecos .LE. -.999 ) THEN
          XCR = (DEL(1)+DEL(2))**2
     &          - 2.*DEL(1)*DEL(2)*(1.+thecos)
        ELSE
        ENDIF
C
        ALPHA = (R(1)**2-R(2)**2 - XCR)/(2.*R(2))
        BETA = DEL(1)*CP0(1)-DEL(2)*CP0(2)
        GAMMA = DEL(1)*SP0(1)-DEL(2)*SP0(2)
C
C Protect against neg've SQRT
C
        IF ( ABS(xcr-alpha**2) .LE. 1E-3 ) xcr = alpha**2
        IF ( xcr-alpha**2 .LT. -1E-3 ) THEN
          WRITE (IW(6),*) 'SQRT Warning in V0DKPT +++ Call an expert'
          WRITE (IW(6),*) 'xcr,alpha**2 : '
          WRITE (IW(6),*) xcr,alpha**2
          xcr = alpha**2
        ENDIF
C
C  There are 2 solutions; try them both
C
        DO IAMB=1,2
          IF(ABS(GAMMA).GT.1.0)THEN
            CP(2) = (ALPHA*BETA + RSIGN(IAMB)*
     &            GAMMA*SQRT(XCR-ALPHA**2))/XCR
            SP(2) = (ALPHA - BETA*CP(2))/GAMMA
          ELSE
            SP(2) = (ALPHA*GAMMA + RSIGN(IAMB)*
     &            BETA*SQRT(XCR-ALPHA**2))/XCR
            CP(2) = (ALPHA - GAMMA*SP(2))/BETA
          END IF
          CP(1) = (R(2)*CP(2)+DEL(1)*CP0(1)-DEL(2)*CP0(2))/R(1)
          SP(1) = (R(2)*SP(2)+DEL(1)*SP0(1)-DEL(2)*SP0(2))/R(1)
C
C  Find the separation in Z at this point
C
          DO ITRK=1,2
            P(ITRK) = ATAN2(SP(ITRK),CP(ITRK))
            IF(ABS(P(ITRK)-P0(ITRK)).GT.PI)THEN
              IF(P(ITRK).GT.P0(ITRK))THEN
                P(ITRK) = P(ITRK)-TWOPI
              ELSE
                P(ITRK) = P(ITRK)+TWOPI
              END IF
            END IF
            ARC(ITRK) = (P(ITRK)-P0(ITRK))*R(ITRK)
            Z(ITRK) = Z0(ITRK) + TANL(ITRK)*ARC(ITRK)
          END DO
C
C  Record the point
C
          DIST = ABS(Z(1)-Z(2))
          IF(DIST.LT.MAXD)THEN
            NAMB = NAMB + 1
            DK(1,NAMB) =  R(1)*SP(1)-DEL(1)*SP0(1)
            DK(2,NAMB) = -R(1)*CP(1)+DEL(1)*CP0(1)
            DK(3,NAMB) = (Z(1)+Z(2))/2.
C
C  Get the track directions dot productat this point
C
            VCOS(NAMB) = COSL(1)*COSL(2)*(CP(1)*CP(2)+SP(1)*SP(2))+
     &            SINL(1)*SINL(2)
          END IF
        END DO
      ELSE
C
C  The tracks are 'inside' one another.  This needs a special solution
C
        IF(ABR(1).GT.ABR(2))THEN
          DHAT(1) = (XC(2)-XC(1))/DELTA
          DHAT(2) = (YC(2)-YC(1))/DELTA
        ELSE
          DHAT(1) = (XC(1)-XC(2))/DELTA
          DHAT(2) = (YC(1)-YC(2))/DELTA
        END IF
        DO ITRK=1,2
          SP(ITRK) =  SIGN(1.0,R(ITRK))*DHAT(1)
          CP(ITRK) = -SIGN(1.0,R(ITRK))*DHAT(2)
          P(ITRK) = ATAN2(SP(ITRK),CP(ITRK))
          IF(ABS(P(ITRK)-P0(ITRK)).GT.PI)THEN
            IF(P(ITRK).GT.P0(ITRK))THEN
              P(ITRK) = P(ITRK)-TWOPI
            ELSE
              P(ITRK) = P(ITRK)+TWOPI
            END IF
          END IF
          ARC(ITRK) = (P(ITRK)-P0(ITRK))*R(ITRK)
          X(ITRK) = XC(ITRK)+R(ITRK)*SP(ITRK)
          Y(ITRK) = YC(ITRK)-R(ITRK)*CP(ITRK)
          Z(ITRK) = Z0(ITRK) + TANL(ITRK)*ARC(ITRK)
        END DO
C
C  Record the point
C
        DIST = SQRT((X(1)-X(2))**2+(Y(1)-Y(2))**2+
     &        (Z(1)-Z(2))**2)
        IF(DIST.LT.MAXD)THEN
          NAMB = NAMB + 1
          DK(1,NAMB) = (X(1)+X(2))/2.
          DK(2,NAMB) = (Y(1)+Y(2))/2.
          DK(3,NAMB) = (Z(1)+Z(2))/2.
C
C  Get the track directions dot productat this point
C
          VCOS(NAMB) = COSL(1)*COSL(2)*(CP(1)*CP(2)+SP(1)*SP(2))+
     &          SINL(1)*SINL(2)
        END IF
      END IF
      RETURN
      END
