      FUNCTION CASHEM(S,INIT)
C -----------------------------------------------------------
CKEY CALO GEANTINO E.M.
C - M.N.Minard
C!
C - Input   : INIT   / I = initialisation flag
C           : S      / R = track length
C - Output  : CASHEM / R =
C ------------------------------------------------------------
      SAVE
      PARAMETER(LTYPEL=48, LTYPME=49, LTYPBA=50, LTYPAN=51, LTYPGA=52)
      COMMON / CAPANO / NATGER,METHCO,TOTNRJ,TINOX0,TINOL0,EMGNRJ,
     + EMALFA,EMBETA,EMALM1,EMAEXP,EMFACT,EMUDP0,EMUDP2, HADNRJ,HALPHA,
     + HABETA,HADRAY,HAPUIS,HGAMMA,SMAXLR,SMAXLA
       COMMON / CANAME / EMNAME
       CHARACTER*4 EMNAME
C
C -------------------------------------------------------------
      IF( INIT .EQ.  0) ALONEN = EMBETA ** EMALFA / GAMMA( EMALFA ) *
     +EMGNRJ
C ----- Parametrisation longitudinale de galeph normalisee.
      IF( S .LE. . 0001) GO TO 10
      X = EMBETA * S
      A = -X +  EMALM1  * ALOG(S)
      IF(ABS(A) .GT. 100.) GO TO 10
      CASHEM = EXP(A) * ALONEN
      GO TO 20
   10 CASHEM = 0.
   20 IF (CASHEM .LT. 0.00001) CASHEM = 0.00001
      RETURN
      END
