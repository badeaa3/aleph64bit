      SUBROUTINE YVSZVC(PVXY,NGTK,JGTK,SGMX,NB,ZL,ZH,VLF,ZV,EZV)
CKEY  QVSRCH / INTERNAL
C ----------------------------------------------------------------------
C! Finds coarse z vertex by sampled likelihood fit
C     TO TRACK IMPACT PARAMETERS WITH BEAM AXIS
C  Author : T. MATTISON  U.A.BARCELONA/SLAC  1 DECEMBER 1992
C
C  Input Arguments :
C  *  PVXY() IS X,Y COORDINATES OF BEAM AXIS
C  *  JGTK() CONTAINS LIST OF TRACK INDICES
C  *  NGTK IS NUMBER OF TRACKS
C  *  VLF() IS WORK ARRAY VLF, LENGTH AT LEAST NB
C  *  SGMX IS NUMBER OF SIGMAS AWAY FROM Z0 THAT ARE GAUSSIAN
C       (ASSUMED FLAT BEYOND THIS)
C  *  NB IS NUMBER OF BINS
C  *  ZL, ZH ARE LOW AND HIGH LIMITS OF SEARCH FOR VERTEX Z
C  Output Arguments :
C  *  ZV IS THE RESULT, EZV IS THE ERROR
C  *  VLF CONTAINS LOG-LIKELIHOOD FUNCTION
C
C ----------------------------------------------------------------------
      DIMENSION PVXY(2),JGTK(*),VLF(*)
C ----------------------------------------------------------------------
C CLEAR LIKELIHOOD FUNCTION
      CALL UZERO(VLF,1,NB)
C SET ERROR NEGATIVE (FAILURE FLAG)
      EZV=-1.
C CHECK FOR TRACKS
      IF (NGTK .LT. 1) RETURN
C BIN WIDTH
      BW=(ZH-ZL)/NB
C LOOP OVER TRACKS
      DO 250 JTK=1,NGTK
        ITK=JGTK(JTK)
C FIND ZB, THE Z AT CLOSEST APPROACH TO BEAM AXIS
C AND VZB, THE VARIANCE (SIGMA-SQUARED)
        CALL QVSZ0B(ITK,PVXY,ZB,VZB)
C ERROR IN ZB, COMBINED WITH BIN SIZE
        EZB=MAX(SQRT(VZB),ABS(BW))
C ADD TRACK TO LIKELIHOOD FUNCTION
        CALL YVSLF1(NB,ZL,ZH,ZB,EZB,SGMX,VLF)
  250 CONTINUE
C FIND MAXIMUM LIKELIHOOD Z VALUE
      CALL YVSML1(NB,ZL,ZH,VLF,ZV,EZV,VLFM)
      RETURN
      END
