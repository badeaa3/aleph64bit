      SUBROUTINE EBDEVI( NATU , ENER , ALPH , BETA , ECAR )
C-----------------------------------------------------
C   AUTHOR   : J.Badier    17/04/89
C! Standard deviation of a shower from the mean distribution.
CKEY PHOTONS GAMMA DEVIATION / INTERNAL
C
C   Input :   NATU      Type of initial particle
C                   1 : Electron ( E > .1 Gev )
C                   2 : Photon.
C                   3 : Pi0.
C                   4 : Electron ( E < .1 Gev )
C                   5 : Pi0 from an interacting hadron.
C             ENER      Initial particle energy in Gev.
C             ALPH      Alpha shower parameter.
C             BETA      Beta shower parameter.
C
C   Output :  ECAR(1)   Standard deviation of 1. / Alpha.
C             ECAR(2)   Standard deviation of Beta / Alpha.
C                       Both set to 10. if uncalculable.
C
C   BANKS :
C     INPUT   : EGPA    Parameters of a mean shower.
C     OUTPUT  : NONE
C     CREATED : NONE
C
C   Called by EBPRGA
C ----------------------------------------------------
      SAVE
C
      DIMENSION  ECAR(*)
C   Energy limits related to the EGPA bank.
      PARAMETER ( EMIN = .05 , ETRA = .1 , SEUS = .5 )
      PARAMETER(JEGPAB=1,JEGPOB=3,JEGPSI=5,LEGPAA=10)
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON /BCS/   IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
      EXTERNAL NAMIND
      DATA ENDT / 0. /  , KTYP / 0 / , NEGPA/0/
C!    set of intrinsic functions to handle BOS banks
C - # of words/row in bank with index ID
      LCOLS(ID) = IW(ID+1)
C - # of rows in bank with index ID
      LROWS(ID) = IW(ID+2)
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
C
C =========================================================
      IF (NEGPA .EQ. 0) NEGPA = NAMIND ('EGPA')
      KEGPA = IW(NEGPA)
      IF (KEGPA .EQ. 0) GO TO 101
      IF (ENER .LT. EMIN .OR. ALPH .LE. 0.) GO TO 101
      IF (NATU .LE. 0 .OR. NATU .GT. 5) GO TO 101
C
      IF( ENER .NE. ENDT .OR. NATU .NE. KTYP ) THEN
C   First pass with this energy.
        ENDT = ENER
        ENLG = ALOG( ENDT )
C
        IF (ENDT  .LT. ETRA .AND. NATU .EQ. 1) THEN
C   Low energy electron.
          KTYP = 4
        ELSE
          KTYP = NATU
        ENDIF
C ----- Shower parameters.
        ASB  = RTABL(KEGPA,KTYP,JEGPAB) +
     +           ENLG * RTABL(KEGPA,KTYP,JEGPAB + 1)
        USB  = RTABL(KEGPA,KTYP,JEGPOB) +
     +           ENLG * RTABL(KEGPA,KTYP,JEGPOB + 1)
C ----- Calculate 1./Alpha and Beta/Alpha which are uncorrelated.
        USRA = USB / ASB
        BSRA = 1./ ASB
C ----- Estimation of the errors to the square.
        IF (ENER .GT. SEUS ) THEN
          DUSA = RTABL(KEGPA,KTYP,JEGPSI) +
     +     RTABL(KEGPA,KTYP,JEGPSI + 1) / ENDT
          DBSA = RTABL(KEGPA,KTYP,JEGPSI + 3) +
     +     RTABL(KEGPA,KTYP,JEGPSI + 4) / ENDT
        ELSE
          DUSA = RTABL(KEGPA,KTYP,JEGPSI + 2)
          DBSA = RTABL(KEGPA,KTYP,JEGPSI + 5)
        ENDIF
        SUSA = SQRT( DUSA )
        SBSA = SQRT( DBSA )
      ENDIF
C
C   Shower measured parameters.
      USAM = 1./ ALPH
      BSAM = BETA / ALPH
C   Deviations.
      ECAR(1) = ( USAM / USRA - 1. ) / SUSA
      ECAR(2) = ( BSAM / BSRA - 1. ) / SBSA
      RETURN
C ======================== error ===========================
C   Energy too small
  101 CONTINUE
      ECAR(1) = 10.
      ECAR(2) = 10.
      END
