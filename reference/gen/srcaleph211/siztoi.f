      SUBROUTINE SIZTOI(ZPOS,IST,IMD)
C.---------------------------------------------------------------------
CKEY SCALDES ENCODE  / USER
C     B.BLOCH       Marh 93
C! Find z layer and module   from Z position
C   Input :
C          ZPOS     Z coordinate  of space point
C   Output:
C          IST       corresponding Z bin  IF < 0  : outside detector
C          IMD       corresponding Module number
C   Called by USER program
C.---------------------------------------------------------------------
      COMMON/SIGECO/NMODSI,NRBNSI,NPBNSI,NZBNSI,RMINSI(2),RMAXSI(2),
     $              Z0SNSI(2),ZWIDSI,ZWRFSI,ZWRLSI,ZWFRSI,ZWFLSI,
     $              ZWBKSI,ZWLASI,OVLPSI,DPOSSI(3,2),GAPXSI(2),
     $              PHSHFT(3,2),RADSTP,PHISTP,ISINUM(12,2)
      PARAMETER ( EPS  = 0.001 )
C GET module
      IMD = 1
      IF ( ZPOS.LT.0.) IMD = 2
      Z = ABS(ZPOS)
      IST = INT((Z+EPS-Z0SNSI(IMD)-DPOSSI(3,IMD))/ZWIDSI)+1
      IF ( IST.LE.0 .OR. IST.GT.NZBNSI) GO TO 999
      RETURN
 999  IST = -1
      RETURN
      END
