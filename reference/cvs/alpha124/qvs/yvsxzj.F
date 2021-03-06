      SUBROUTINE YVSXZJ(NGTK,JGTK,PVTX,EVTX,DJET,JET,EJET,SGMX,
     > NBX,XL,XH,NBZ,ZL,ZH,NBT,TL,TH,VLF,
     > XV,EXV,ZV,EZV,TV,ETV,DLLX,DLLZ)
CKEY  QVSRCH / INTERNAL
C ------------------------------------------------------------------------------
C! Finds X,Z,and T of secondary vertex
C     IN VERTEX-JET COORDINATE SYSTEM (T MEANS ALONG JET DIRECTION)
C     USING SAMPLED MAXIMUM LIKELIHOOD FIT TO PROJECTIONS
C  Author : T. MATTISON  U.A.BARCELONA/SLAC  1 DECEMBER 1992
C
C  Input Arguments :
C  *  JGTK IS ARRAY CONTAINING A LIST OF NGTK TRACKS
C  *  PVTX() IS COORDINATE OF PRIMARY VERTEX IN ALEPH COORDINATES
C  *  EVTX() IS ERROR IN PVTX
C  *  DJET() IS TWO NORMALIZED 3-VECTOR JET DIRECTIONS
C        MUST BE NORMALIZED TO 1 (NOT CHECKED HERE)
C  *  JET IS WHICH JET TO DO (1 OR 2)
C  *  EJET IS ERROR IN JET ANGLE
C  *  SGMX IS GAUSSIAN RANGE OF ERRORS (CONSIDERED FLAT BEYOND THIS)
C  *  NBX,XL,XH ARE BINS, LOW AND HIGH LIMITS FOR VERTEX X
C  *  NBZ,ZL,ZH ARE SAME FOR VERTEX Z
C  *  NBT,TL,TH ARE SAME FOR DECAY LENGTH IN DJET DIRECTION
C  *  VLF((NBX+NBZ)*NBT) IS SAMPLED LOG-LIKELIHOOD ARRAY
C
C  Output Arguments :
C  *  XV,ZV,EXV,EZV ARE X AND Z VERTEX AND ERROR NORMAL TO DJET(,JET)
C        IN THE ROTATED AND TRANSLATED COORDINATE SYSTEM
C  *  TV,ETV IS THE DECAY LENGTH AND ERROR
C        IN THE DJET(,JET) DIRECTION
C  *  VLF CONTAINS 2 2-DIMENSIONAL SAMPLED LOG-LIKELIHOOD FUNCTIONS:
C        VLFX(NBX,NBT),VLFZ(NBZ,NBT)
C  *  DLLX,DLLZ ARE VALUES OF LIKELIHOOD FUNCTIONS AT THE COMBINED PEAK
C        WHICH IS ALSO THE DIFFERENCE IN LOG-LIKELIHOOD BETWEEN
C        PRESENCE AND ABSENCE OF THE SECONDARY VERTEX
C        IN THE TWO PROJECTIONS
C
C ------------------------------------------------------------------------------
#ifndef DOC
      DIMENSION JGTK(*),PVTX(3),EVTX(3),DJET(3,2)
      DIMENSION VLF(*)
C ------------------------------------------------------------------------------
C CLEAR LIKELIHOOD FUNCTION
      CALL UZERO(VLF,1,(NBX+NBZ)*NBT)
C
C CALCULATE PRIMARY VERTEX ERRORS IN ROTATED SYSTEM
      CALL YVSPVE(EVTX,DJET(1,JET),EX,EZ,ET)
C
C ENTER PRIMARY VERTEX AND JET ERRORS AS A PSEUDO-TRACK
C ZERO INTERCEPT AND SLOPE, ERROR GROWS WITH DISTANCE
C CUTOFF AT SGMX, ENTERED IN BOTH X AND Z PROJECTIONS
      CALL YVSVJE(EX,EJET,SGMX,NBX,XL,XH,NBT,TL,TH,VLF(1))
      CALL YVSVJE(EZ,EJET,SGMX,NBZ,ZL,ZH,NBT,TL,TH,VLF(NBX*NBT+1))
C
C CLEAR LIKELIHOOD SUMS FOR HYPOTHESIS OF NO-SECONDARY
      VLFX=0.
      VLFZ=0.
C FIND BIN WIDTHS
      BWX=(XH-XL)/NBX
      BWZ=(ZH-ZL)/NBZ
      BWT=(TH-TL)/NBT
      SGMX2=SGMX**2
C
C LOOP OVER TRACKS
      DO 250 JTK=1,NGTK
        ITK=JGTK(JTK)
C
C CHECK IF TRACK IS IN DESIRED JET
        CALL QVSTKJ(ITK,DJET,ITKJ)
        IF (ITKJ .EQ. JET) THEN
C
C GET TRACK DESCRIPTION POLYNOMIAL, ERRORS
          CALL QVSTKP(ITK,PVTX,DJET(1,JET),
     >     XP,DXDT,D2XDT2,ZP,DZDT,D2ZDT2,VXP,VZP,VXZ)
C
C ADD VERTEX ERRORS IN QUADRATURE
          VXP=VXP+EX**2+(ET*DXDT)**2
          VZP=VZP+EZ**2+(ET*DZDT)**2
C
C LIMIT ERRORS TO BIN SIZES
          EXP=MAX(SQRT(VXP),ABS(BWX),ABS(BWT*DXDT))
          EZP=MAX(SQRT(VZP),ABS(BWZ),ABS(BWT*DZDT))
C
C FIND HOW FAR TRACK IS FROM (0,0) AT T=0 (TRANSFORMED PRIMARY
          DX2=XP**2/EXP**2
          DZ2=ZP**2/EZP**2
C ADD TO NULL-HYPOTHESIS SUMS
          VLFX=VLFX-.5*MIN(DX2,SGMX2)
          VLFZ=VLFZ-.5*MIN(DZ2,SGMX2)
C
C ONLY LET TRACK CONTRIBUTE WHEN CLOSER TO
C HYPOTHETICAL SECONDARY THAN TO PRIMARY VERTEX
C USING 2-D MISS DISTANCE LETS VIEWS HELP EACH OTHER
C BUT MAKES NEGATIVE DLL POSSIBLE
          SIGL=MIN(SQRT(DX2+DZ2),SGMX)
C
C ADD TRACK TO LIKELIHOOD FUNCTIONS
C    X PROJECTION
          CALL YVSLFL(NBX,XL,XH,XP,EXP,SIGL,NBT,TL,TH,
     >      DXDT,D2XDT2,VLF(1))
C
C    Z PROJECTION
          CALL YVSLFL(NBZ,ZL,ZH,ZP,EZP,SIGL,NBT,TL,TH,
     >      DZDT,D2ZDT2,VLF(NBX*NBT+1))
C
        ENDIF
  250 CONTINUE
C
C GIVE UP IF NO TRACKS IN THE HEMISPHERE
      IF (VLFX .EQ. 0.) THEN
        EXV=-999.
        EZV=-999.
        ETV=-999.
        DLLX=-999.
        DLLZ=-999.
        RETURN
      ENDIF
C
C FIND CONSISTENT PEAK IN THE 2 LIKELIHOOD FUNCTIONS
      CALL YVSCM2(VLF(1),VLF(NBX*NBT+1),
     > NBX,NBT,NBZ,MBX,MBT,MBZ)
C
C FIT PARABOLOIDS TO PEAKS TO INTERPOLATE AND GET ERRORS
      CALL YVSPR2(VLF(1),VLF(NBX*NBT+1),
     > NBX,NBT,NBZ,MBX,MBT,MBZ,
     > IERR,XV,EXV,TV,ETV,ZV,EZV,FXT,FZT)
C
C CONVERT TO EXTERNAL UNITS
      XV=XL+(MBX-.5+XV)*BWX
      ZV=ZL+(MBZ-.5+ZV)*BWZ
      TV=TL+(MBT-.5+TV)*BWT
      EXV=EXV*ABS(BWX)
      EZV=EZV*ABS(BWZ)
      ETV=ETV*ABS(BWT)
C
C FIND LIKELIHOOD CONTRIBUTION FROM PRIMARY+JET
      EX2=EX**2+(EJET*TV)**2
      PJX=.5*MIN(XV**2/EX2,SGMX2)
      EZ2=EZ**2+(EJET*TV)**2
      PJZ=.5*MIN(ZV**2/EZ2,SGMX2)
C
C LIKELIHOOD DIFFERENCES FOR PROJECTIONS
      DLLX=FXT+PJX-VLFX
      DLLZ=FZT+PJZ-VLFZ
C
      RETURN
      END
#endif
