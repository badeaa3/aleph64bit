      SUBROUTINE YVSRMI(DIR,A,B)
CKEY  QVSRCH / INTERNAL
C ----------------------------------------------------------------------
C! Inverse-rotates covariance or weight matrix
C  Author : T. MATTISON  U.A.BARCELONA/SLAC  1 DECEMBER 1992
C
C  Input Arguments :
C  *  DIR() IS NORMALIZED DIRECTION VECTOR
C  *  A(,) IS MATRIX IN COORDINATE SYSTEM WHERE DIR=(0,0,1)
C  Output Argument :
C     B(,) IS OUTPUT MATRIX
C
C ----------------------------------------------------------------------
      DIMENSION DIR(3),A(3,3),B(3,3)
      DIMENSION ROT(3,3),TMP(3,3)
      REAL*8 ARJM,SUM
C ----------------------------------------------------------------------
C
C MAKE (FORWARD) ROTATION MATRIX
      CALL YVSROM(DIR,ROT)
C
C COPY INPUT (IN CASE IT IS SAME AS OUTPUT)
      CALL UCOPY(A,TMP,9)
C
C MULTIPLY MATRICES
      DO 450 N=1,3
        DO 350 M=1,3
          SUM=0.
          DO 250 J=1,3
C FORWARD ON RIGHT
            ARJM=TMP(J,1)
            ARJM=ARJM*ROT(1,M)+TMP(J,2)*ROT(2,M)+TMP(J,3)*ROT(3,M)
C TRANSPOSE ON LEFT
            SUM=SUM+ROT(J,N)*ARJM
  250     CONTINUE
          B(M,N)=SUM
  350   CONTINUE
  450 CONTINUE
      RETURN
      END
