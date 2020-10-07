      SUBROUTINE VDHTER (IWAFA,PV,PU,PW,U,W,SIGNU,SIGNW,UERR2,WERR2)
C ----------------------------------------------------------------------
CKEY VDETDES ALIGN JULIA / USER
C!  Compute the VDET hit error given wafer info and track direction
C - Dave Brown - 910430
C - Modified to use new geometry package, S. Wasserbaech, March 1995
C - Modified to call VGCRMT for VALC info, A. Bonissent, March 1995
C
C   This uses a simple theoretical model to compute the hit errors
C   given the signal/noise, and other parameters (see VDET ALIGNMENT
C   ALEPHNOTE of 1991).  Dave Brown, 7-2-91
C
C - Input:
C   IWAFA        / I  Decimal wafer address
C   PV,PU,PW     / R  Track momentum vector at wafer in wafer frame
C   U,W          / R  Hit coordinates in wafer system
C   SIGNU,SIGNW  / R  Signal/noise on U,W side
C
C - Output:
C   UERR2,WERR2  / R  SQUARED hit errors in U,W direction
C ----------------------------------------------------------------------
C     IMPLICIT NONE
      SAVE SPRED, ROT12
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
C! Parameters used in the alignment geometrical package
      INTEGER LVEMLN, LVTFOR, LVTEXP, JVTFTR, JVTFRO, JVTFEM,
     &        JVTETR, JVTERO, JVTEEM
      PARAMETER( JVTFTR=1, JVTFRO=4, JVTFEM=7,
     &           JVTETR=1, JVTERO=4, JVTEEM=13,
     &           LVEMLN=21, LVTFOR=LVEMLN+JVTFEM-1,
     &           LVTEXP=LVEMLN+JVTEEM-1 )
C
C     (Other dimension parameters are defined in VGLOBL.)
C
      REAL VTEXPD, VTEXPI, RFDIST
      COMMON /VGPAAL/ VTEXPD(LVTEXP,NVFLMX,NVWFMX,NVLAYR),
     &                VTEXPI(LVTEXP,NVFLMX,NVWFMX,NVLAYR),
     &                RFDIST(NVFLMX,NVWFMX,NVLAYR)
C
C  Arguments:
C
      INTEGER IWAFA
      REAL PV, PU, PW, U, W, SIGNU, SIGNW, UERR2, WERR2
C
C  Local variables
C
      INTEGER IRET, IDUM1, IDUM2, IER
      INTEGER VROSTM, VPHSTM
      REAL RPITU, FPITU, RPITW, FPITW
      REAL COSW, SINW, COSU, SINU
      REAL UERRP,UERRN,WERRP,WERRN,UERRA,WERRA,VERRA
      REAL CORMAT(6,6)
      REAL SPRED,ROT12
C
C  Shower spread factor- this should be computed from the pulseheight,
C  but for now we take a nominal value.  We also need sqrt(12).
C
      DATA SPRED/1.5/
      DATA ROT12/3.46410/
C
C ----------------------------------------------------------------------
C
C  Get the readout and floating strip pitches, U and W direction:
C
      IRET = VROSTM(VVIEWP,IDUM1,RPITU,IDUM2)
      IRET = VROSTM(VVIEWZ,IDUM1,RPITW,IDUM2)
      IRET = VPHSTM(VVIEWP,IDUM1,FPITU)
      IRET = VPHSTM(VVIEWZ,IDUM1,FPITW)
C
C  Compute the cosine/sines
C
      COSW = SQRT( MAX(1./(1.+ (PW/PV)**2),0.0) )
      SINW = SQRT( MAX(1. - COSW**2,0.0) )
      COSU = SQRT( MAX(1./(1.+ (PU/PV)**2),0.0) )
      SINU = SQRT( MAX(1. - COSU**2,0.0) )
C
C  Resolution due to strip pitch
C
      UERRP = FPITU*COSU/ROT12
      WERRP = FPITW*COSW/ROT12
C
C  Resolution due to noise
C
      UERRN = (RPITU/SIGNU)*
     &  ( (1.0 + SPRED*SINU)/SQRT(1.+SINU**2 + SINW**2) )
      WERRN = (RPITW/SIGNW)*
     &  ( (1.0 + SPRED*SINW)/SQRT(1.+SINU**2 + SINW**2) )
C
C  Resolution due to alignment.
C  CORMAT is the error correlation matrix from the
C  VALC bank (local alignment).  By definition, the error on the
C  global alignment is 0.
C
      CALL VGCRMT(IWAFA,CORMAT,IER)
      IF (IER .EQ. 0) THEN
C
C  Compute first directly the errors in the V,U, and W directions.
C  This is a full 1st order calculation using the full error correlation
C  matrix of the local alignment.
C  Note that this depends on the local position of the hits
C
        VERRA = CORMAT(1,1)
     &  + CORMAT(6,6)*U**2
     &  + CORMAT(5,5)*W**2
     &  -2*CORMAT(6,1)*U
     &  +2*CORMAT(5,1)*W
     &  -2*CORMAT(6,5)*U*W
C
        UERRA = CORMAT(2,2)
     &  + CORMAT(4,4)*W**2
     &  -2*CORMAT(4,2)*W
C
        WERRA = CORMAT(2,2)
     &  + CORMAT(4,4)*U**2
     &  +2*CORMAT(4,3)*U
C
C  Now, transfer the V error onto the U and W directions,
C  depending on the track direction:
C
        UERRA = UERRA + VERRA*(PU/PV)**2
        WERRA = WERRA + VERRA*(PW/PV)**2
      ELSE
        UERRA = 0.
        WERRA = 0.
      ENDIF
C
C  Add in quadrature
C
      UERR2 = UERRP**2 + UERRN**2 + UERRA
      WERR2 = WERRP**2 + WERRN**2 + WERRA
C
      RETURN
      END
