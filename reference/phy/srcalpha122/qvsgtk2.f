      LOGICAL FUNCTION QVSGTK2(ITK,VTX,DKL)
CKEY  QVSRCH / INTERNAL
C ----------------------------------------------------------------------
C! Track cuts for track-vertex-association
C     QVSGTK2 IS A FUNCTION NOT A SUBROUTINE
C  Author : T. MATTISON  U.A.BARCELONA/SLAC  1 DECEMBER 1992
C
C  Input Arguments :
C     ITK IS ALPHA TRACK NUMBER
C     VTX() IS PRIMARY VERTEX COORDINATES FOR CUTS
C     DKL IS DECAY DISTANCE (USED TO LOOSEN IMPACT PARAMETER CUTS)
C  Output Arguments :
C     RETURNS QVSGTK2=.TRUE. OR .FALSE.
C
C ----------------------------------------------------------------------
      DIMENSION VTX(3)
      LOGICAL GTK,QVSGTK
C ----------------------------------------------------------------------
C
C SET CUTS
C MINIMUM TPC HITS
      MNTP=4
C MAXIMUM COS-THETA
      CTMX=1.
C MAXIMUM DISTANCE FROM VTX X-Y AXIS
      D0MX=1.
C MAXIMUM DISTANCE FROM VTX Z COORDINATE
      Z0MX=1.
C MAXIMUM 3D DISTANCE FROM VTX
C (OR D0 IF CUT IS LESS THAN 3 TIMES Z0 ERROR)
      RVMX=999.
C MINIMUM TOTAL MOMENTUM
      PMIN=0.
C MAXIMUM CHI-SQUARE PER DEGREE OF FREEDOM
      CPDMX=4.
C
C USE GENERIC TRACK CUT FUNCTION
      GTK=QVSGTK(ITK,VTX,MNTP,CTMX,D0MX,Z0MX,RVMX,PMIN,CPDMX)
C
C ASSUME BAD TRACK
      QVSGTK2=.FALSE.
C
C PUNT IF TRACK FAILS LOOSE CUTS
      IF (.NOT. GTK) RETURN
C
C GET D0,Z0 WITH RESPECT TO PRIMARY VERTEX, AND 3D DISTANCE
      CALL QVSMIS(ITK,VTX,D0V,Z0V,R3D)
C
C IMPACT PARAMETER CUT: 3MM OR DECAY LENGTH
      DCUT=MAX(0.3,ABS(DKL))
C
C REQUIRE CLOSE IN AT LEAST ONE PROJECTION
      IF (ABS(D0V) .GT. DCUT .AND. ABS(Z0V) .GT. DCUT) RETURN
C
C MUST BE OK
      QVSGTK2=.TRUE.
C
      RETURN
      END
