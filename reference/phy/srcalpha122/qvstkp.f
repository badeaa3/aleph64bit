      SUBROUTINE QVSTKP(ITK,PVTX,DJET,
     > XP,DXDT,D2XDT2,ZP,DZDT,D2ZDT2,VXP,VZP,VXZ)
CKEY  QVSRCH / INTERNAL
C ----------------------------------------------------------------------
C! Returns polynomial describing track ITK in vertex-jet coord. system
C  Author : T. MATTISON  U.A.BARCELONA/SLAC  1 DECEMBER 1992
C
C  Input Arguments :
C  *  ITK IS ALPHA TRACK INDEX
C  *  PVTX() IS XYZ OF POINT (PRIMARY VERTEX) IN ALEPH SYSTEM
C  *  DJET() IS NORMALIZED JET DIRECTION VECTOR
C  Output Arguments :
C  *  XP IS THE R-PHI-LIKE COORDINATE IN THE TRANSLATED, ROTATED SYSTEM
C        WHERE THE TRACK INTECEPTS THE PLANE THROUGH PVTX()
C        WITH NORMAL VECTOR DJET
C  *  DXDT IS THE SLOPE OF THE TRACK IN THE ROTATED X DIRECTION
C        (I.E., RELATIVE TO THE DJET DIRECTION)
C  *  D2XDT2 IS THE 2D DERIVATIVE (CURVATURE) OF THE TRACK
C        X(T) = XP + DXDT*T + .5*D2XDT2*T*T
C  *  ZP,DZDT ARE THE ANALOGS OF XP,DXDT FOR Z-LIKE COORDINATE
C  *  D2ZDT2 IS THE Z CURVATURE (NONZERO IF DJET(3) IS NONZERO)
C         Z(T) = ZP + DZDT*T + .5*D2ZDT2*T*T
C  *  VXP,VZP ARE THE VARIANCES (NOT ERRORS!) ON XP,ZP
C  *  VXZ IS THE COVARIANCE
C
C ----------------------------------------------------------------------
      DIMENSION PVTX(3),DJET(3)
      DIMENSION XYZA(3),DIRA(3),CRVA(3)
      DIMENSION XYZJ(3),DIRJ(3),CRVJ(3)
      DIMENSION XYZS(3),DIRS(3)
      DIMENSION WTMA(3,3),WTMJ(3,3)
C ----------------------------------------------------------------------
C
C GET VECTORS DESCRIBING TRACK IN ALEPH SYSTEM
      CALL QVSTKV(ITK,XYZA,DIRA,CRVA)
C
C GET WEIGHT MATRIX IN ALEPH SYSTEM
      CALL QVSTKW(ITK,DIRA,WTMA)
C
C TRANSLATE AND ROTATE POINT CLOSEST TO Z AXIS
      CALL YVSTRJ(PVTX,DJET,XYZA,XYZJ)
C ROTATE TRACK DIRECTION
      CALL YVSRTJ(DJET,DIRA,DIRJ)
C ROTATE TRACK CURVATURE
      CALL YVSRTJ(DJET,CRVA,CRVJ)
C
C ROTATE WEIGHT MATRIX
      CALL YVSRMJ(DJET,WTMA,WTMJ)
C
C CHECK TRACK ANGLE IN JET SYSTEM
      IF (ABS(DIRJ(3)) .LT. 0.1) THEN
C TRACK IS NOT FAR FROM NORMAL TO JET DIRECTION
C
C    WE ONLY CARE ABOUT A FEW MM OF TRACK NEAR THE JET AXIS
C       AND WE CAN NEGLECT CURVATURE FOR THIS,
C    BUT THE POINT OF INTERSECTION WITH JET PLANE MAY BE FAR AWAY
C       AND CURVATURE IS A NUISANCE FOR THAT,
C       SINCE POINT XYZJ IS PROBABLY ONLY A FEW MM FROM (0,0,0
C        WE'RE BETTER OFF WITH A STRAIGHT LINE THAT IS LOCALLY GOOD
C
C SET CURVATURE TO ZERO
        CRVJ(1)=0.
        CRVJ(2)=0.
        CRVJ(3)=0.
      ENDIF
C
C FIND S0 = STEP IN SPACE THAT TAKES TRACK TO
C THE PLANE THROUGH PVTX NORMAL TO JET
      CALL YVSTP0(XYZJ,DIRJ,CRVJ,S0,IERR0)
C
C CHECK RESULT
      IF (IERR0 .EQ. 2) THEN
C TRACK CURVED AWAY FROM THE PLANE
C S0 WAS CALCULATED WITH ZERO CURVATURE
C SET CURVATURE TO ZERO
        CRVJ(1)=0.
        CRVJ(2)=0.
        CRVJ(3)=0.
C
      ELSEIF (IERR0 .EQ. 1) THEN
C CURVATURE AND SLOPE BOTH ZERO (THIRD COMPONENT, ANYWAY)
C S0 WAS NOT CALCULATED
C SET CURVATURE TO ZERO
        CRVJ(1)=0.
        CRVJ(2)=0.
        CRVJ(3)=0.
C ADD SOME FAKE ANGLE
        DIRJ(3)=1.E-6
C FIND INTERCEPT NEGLECTING CURVATURE
        S0=-XYZJ(3)/DIRJ(3)
      ENDIF
C
C SWIM TRACK TO PLANE
      CALL YVSWIM(S0,XYZJ,DIRJ,CRVJ,XYZS,DIRS)
C
C COORDINATES OF TRACK AT PLANE
      XP=XYZS(1)
      ZP=XYZS(2)
C
C MOTION IN JET DIRECTION PER CM OF SPACE LENGTH
      DTDS=DIRS(3)
C AVOID BLOWUPS
      IF (DTDS .EQ. 0.) DTDS=1.E-6
      DSDT=1./DTDS
C
C CHANGES IN X,Z PER CM ALONG JET DIRECTION
      DXDT=DIRS(1)*DSDT
      DZDT=DIRS(2)*DSDT
      D2XDT2=CRVJ(1)*DSDT*DSDT
      D2ZDT2=CRVJ(2)*DSDT*DSDT
C
C FIND TRACK ERROR**2 IN JET SYSTEM
      CALL YVSTKE(WTMJ,VXP,VZP,VXZ)
C
      RETURN
      END
