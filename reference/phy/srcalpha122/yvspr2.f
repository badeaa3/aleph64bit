      SUBROUTINE YVSPR2(F1,F2,NU1,NV,NU2,MU1,MV,MU2,
     > IERR,U1M,U1E,VM,VE,U2M,U2E,F1M,F2M)
CKEY  QVSRCH / INTERNAL
C ----------------------------------------------------------------------
C! Fits combined paraboloid to 2 2-d functions
C  Author : T. MATTISON  U.A.BARCELONA/SLAC  1 DECEMBER 1992
C
C  Input Arguments :
C  *  F1 IS FIRST FUNCTION, STORED AS IF DIMENSIONED F1(NU1,NV)
C  *  F2(NU2,NV) IS ANALOGOUS
C  *  NU1,NV,NU2 ARE THE DIMENSIONS
C  *  MU1,MV,MU2 ARE THE COORDINATES OF THE MAXIMUM
C        MUST BE >1, < DIMENSION
C  Output Arguments :
C  *  IERR=0 FOR OK, 1 FOR MATRIX PROBLEM, 2 FOR MAXIMUM PROBLEMS
C  *  U1M IS THE FRACTION OF A BIN TO THE INTERPOLATED MAXIMUM
C       FOR THE U VARIABLE IN F1
C  *  U1E IS THE ERROR (HALF LOG-LIKELIHOOD UNIT) IN BIN UNITS
C  *  U1M,U2E ARE ANALOGOUS FOR THE U2 VARIABLE IN F2
C  *  VM,VE ARE ANALOGOUS FOR THE COMMON VARIABLE V
C        ERRORS CAN BE NEGATIVE IF IERR .NE. 0
C  *  F1M IS VALUE OF F1 AT THE MAXIMUM POINT, SIMILAR FOR F2M
C
C ----------------------------------------------------------------------
      DIMENSION F1(*),F2(*)
      DIMENSION P1(6),P2(6)
      DIMENSION WM(3,3),RH(3),SL(3),ER(3),WK(3)
C ----------------------------------------------------------------------

C FIND PARABOLOID PARAMETERS FOR F1
      CALL YVSPAR(F1,NU1,MU1,MV,P1)
C AND FOR F2
      CALL YVSPAR(F2,NU2,MU2,MV,P2)
C FILL WEIGHT MATRIX FOR COMBINED FIT
C ORDER IS U1,U2,V
      WM(1,1)=2.*P1(1)
      WM(2,2)=2.*P2(1)
      WM(3,3)=2.*(P1(4)+P2(4))
      WM(1,2)=0.
      WM(2,1)=0.
      WM(1,3)=P1(6)
      WM(3,1)=P1(6)
      WM(2,3)=P2(6)
      WM(3,2)=P2(6)
C FILL RIGHT-HAND-SIDE VECTOR
      RH(1)=-P1(2)
      RH(2)=-P2(2)
      RH(3)=-(P1(5)+P2(5))
C CHECK FOR PATHOLOGICAL MATRIX
      IERR=0
      DO 150 I=1,3
      IF (WM(I,I) .GE. 0.) THEN
C CURVATURE IS WRONG SIGN!
        IERR=2
C DON'T MOVE FROM CELL CENTER
        SL(I)=0.
        ER(I)=-1.
C NEGATIVE ERROR, STILL DEPENDING ON CURVATURE
        IF (WM(I,I) .NE. 0.) ER(I)=-1./SQRT(WM(I,I))
      ELSE
C SOLVE IGNORING CORRELATIONS
        SL(I)=RH(I)/WM(I,I)
        ER(I)=1./SQRT(-WM(I,I))
      ENDIF
  150 CONTINUE
      IF (IERR .EQ. 0) THEN
C FIND DETERMINANT AND FACTOR MATRIX (BEFORE INVERTING)
        CALL RFACT(3,WM,3,WK,IFAIL,DET,JFAIL)
C CHECK FOR TROUBLE
        IF (IFAIL .NE. 0) THEN
C MATRIX IS SINGULAR
          IERR=1
        ELSE
C FIND THE SOLUTION
          CALL RFEQN(3,WM,3,WK,1,RH)
C FIND THE ERRORS
          CALL RFINV(3,WM,3,WK)
C CHECK FOR NONSENSE ERRORS
          DO 250 I=1,3
            IF (WM(I,I) .GT. 0.) THEN
              IERR=1
C NEGATIVE ERROR
              ER(I)=-SQRT(WM(I,I))
C LEAVE THE OLD APPROXIMATE SOLUTION
            ELSE
C             USE THE SOLUTION AND ERROR
              ER(I)=SQRT(-WM(I,I))
              SL(I)=RH(I)
            ENDIF
  250     CONTINUE
        ENDIF
      ENDIF
C COPY SOLUTION AND ERRORS
      U1M=SL(1)
      U2M=SL(2)
      VM=SL(3)
      U1E=ER(1)
      U2E=ER(2)
      VE=ER(3)
C CALCULATE FUNCTION VALUES
      F1M=P1(1)*U1M*U1M + P1(2)*U1M + P1(3) +
     >    P1(4)*VM*VM   + P1(5)*VM  + P1(6)*U1M*VM
      F2M=P2(1)*U2M*U2M + P2(2)*U2M + P2(3) +
     >    P2(4)*VM*VM   + P2(5)*VM  + P2(6)*U2M*VM
      RETURN
      END
