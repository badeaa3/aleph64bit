      LOGICAL FUNCTION QVSGTK0(ITK,VTX)
CKEY  QVSRCH / INTERNAL
C ----------------------------------------------------------------------
C! Track cuts for coarse z vertex
C     QVSGTK0 IS A FUNCTION NOT A SUBROUTINE
C  Author : T. MATTISON  U.A.BARCELONA/SLAC  1 DECEMBER 1992
C
C  Input Arguments :
C  *  ITK IS ALPHA TRACK NUMBER
C  *  VTX() IS PRIMARY VERTEX COORDINATES FOR CUTS
C  Output Arguments :
C  *  RETURNS QVSGTK0=.TRUE. OR .FALSE.
C
C ----------------------------------------------------------------------
      DIMENSION VTX(3)
      LOGICAL QVSGTK
C ----------------------------------------------------------------------
C
C MINIMUM TPC HITS
      MNTP=4
C MAXIMUM COS-THETA
      CTMX=1.
C MAXIMUM DISTANCE FROM VTX X-Y AXIS
      D0MX=.3
C MAXIMUM DISTANCE FROM VTX Z COORDINATE
      Z0MX=5.
C MAXIMUM 3D DISTANCE FROM VTX
      RVMX=10.
C MINIMUM TOTAL MOMENTUM
      PMIN=0.
C MAXIMUM CHI-SQUARE PER DEGREE OF FREEDOM
      CPDMX=4.
C
C USE GENERIC TRACK CUT FUNCTION
      QVSGTK0=QVSGTK(ITK,VTX,MNTP,CTMX,D0MX,Z0MX,RVMX,PMIN,CPDMX)
C
      RETURN
      END