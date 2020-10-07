      INTEGER FUNCTION VVUWXY (VUW,JWAF,XYZ)
C ----------------------------------------------------------------------
CKEY VDETDES TRANSFORM / USER
C!  Transform wafer coordinates into ALEPH coordinates
C - Joe Rothberg and Rainer Wallny, 15 January 1994
C
C - Input:
C   VUW(3) / R  Coordinates of point in wafer system
C   JWAF   / I  Global wafer index
C
C - Output:
C   VVUWXY / I  = VDOK if successful
C               = VDERR if error occurred
C   XYZ(3) / R  Coordinates of point in ALEPH system
C ----------------------------------------------------------------------
C     IMPLICIT NONE
C!    Parameters for VDET geometry package
C ----------------------------------------------------------------------
C
C     Labels for return codes:
C
      INTEGER VDERR, VDOK
      PARAMETER (VDERR = -1)
      PARAMETER (VDOK  = 1)
C
C     Labels for views:
C
      INTEGER VVIEWZ, VVIEWP
      PARAMETER (VVIEWZ = 1)
      PARAMETER (VVIEWP = 2)
C
C     Fixed VDET geometry parameters:
C
      INTEGER NVLAYR, NVMODF, NVVIEW, NPROMM, IROMAX
      PARAMETER (NVLAYR = 2)
      PARAMETER (NVMODF = 2)
      PARAMETER (NVVIEW = 2)
      PARAMETER (NPROMM = 1)
      PARAMETER (IROMAX = 4)
C
C     Array dimensions:
C
      INTEGER NVWMMX, NVWFMX, NVFLMX, NVFMAX, NVMMAX, NVWMAX
      INTEGER NVZRMX, NVPRMX
      PARAMETER (NVWMMX = 3)
      PARAMETER (NVWFMX = NVWMMX*NVMODF)
      PARAMETER (NVFLMX = 15)
      PARAMETER (NVFMAX = 24)
      PARAMETER (NVMMAX = NVFMAX*NVMODF)
      PARAMETER (NVWMAX = NVFMAX*NVWFMX)
      PARAMETER (NVZRMX = NVFMAX*IROMAX)
      PARAMETER (NVPRMX = NVMMAX*NPROMM)
C
C!    Common for miscellaneous calculated VDET geometry quantities
C ----------------------------------------------------------------------
      REAL RVDMIN, RVDMAX, ZVDMAX, WAXCEN, WAYCEN, WAZCEN
      REAL WARHOC, WAPHIC, CPHIOF, SPHIOF, TNWTLT, AMXSRZ, AMXSRP
      REAL BMXSRZ, BMXSRP
      INTEGER NZSROM, NPSROM, NZSMOD, NPSMOD, NPRSSC, NZROMM
      INTEGER MSVWAF, MSVNST, ISSLAY, ISSNST
      LOGICAL LZMULT
C
      COMMON / VDETGE / RVDMIN, RVDMAX, ZVDMAX,
     >                  WAXCEN(NVWMAX), WAYCEN(NVWMAX), WAZCEN(NVWMAX),
     >                  WARHOC(NVFMAX), WAPHIC(NVFMAX), CPHIOF(NVFMAX),
     >                  SPHIOF(NVFMAX), TNWTLT(NVLAYR), AMXSRZ, AMXSRP,
     >                  BMXSRZ, BMXSRP, NZSROM, NPSROM, NZSMOD, NPSMOD,
     >                  NPRSSC, NZROMM, LZMULT, MSVWAF, MSVNST, ISSLAY,
     >                  ISSNST
C
C!    Common for lookup tables for index manipulation
C ----------------------------------------------------------------------
      INTEGER IVSTUP, NMODUL, NWAFER, NFACEL, NWAFEM, JJFACM, JJMODW
      INTEGER JIFACF, JIMODM, JIWAFW, IJFACE, IJMODU, IJWAFR, JIWFFW
      INTEGER IJWFFR
      CHARACTER*4 TXMODU
C
      COMMON / VGINDX / IVSTUP, NMODUL, NWAFER, NFACEL(NVLAYR),
     >                  NWAFEM, JJFACM(NVMMAX), JJMODW(NVWMAX),
     >                  JIFACF(NVFMAX), JIMODM(NVMMAX),
     >                  JIWAFW(NVWMAX), IJFACE(NVLAYR,NVFLMX),
     >                  IJMODU(NVLAYR,NVFLMX,NVMODF),
     >                  IJWAFR(NVLAYR,NVFLMX,NVMODF,NVWMMX),
     >                  JIWFFW(NVWMAX), IJWFFR(NVLAYR,NVFLMX,NVWFMX),
     >                  TXMODU(NVLAYR,NVFMAX,NVMODF)
C
C
      REAL VUW(3)
      REAL XYZ(3)
      INTEGER JWAF
      INTEGER VJFACW
C
C     Local variables
      INTEGER JFAC
C
C ----------------------------------------------------------------------
C
C check validity of arguments
C
      IF (JWAF .GE. 1 .AND. JWAF .LE. NWAFER) THEN
C
        JFAC = VJFACW(JWAF)
C
C        do the rotation
C
C        [x']    [cos(phi) -sin(phi) 0]   [v]
C        [y']  = [sin(phi)  cos(phi) 0] * [u]
C        [z']    [   0          0    1]   [w]
C
C and do the translation
C
C        [x]    [x']   [x wafer center]
C        [y]  = [y'] + [y wafer center]
C        [z]    [z']   [z wafer center]
C
        XYZ(1) = CPHIOF(JFAC)*VUW(1)-SPHIOF(JFAC)*VUW(2)+WAXCEN(JWAF)
        XYZ(2) = SPHIOF(JFAC)*VUW(1)+CPHIOF(JFAC)*VUW(2)+WAYCEN(JWAF)
        XYZ(3) = VUW(3)+WAZCEN(JWAF)
C
        VVUWXY = VDOK
C
      ELSE
C
C     argument JWAF out of range
C
        CALL VZERO(XYZ,3)
        VVUWXY = VDERR
C
      ENDIF
C
      RETURN
      END