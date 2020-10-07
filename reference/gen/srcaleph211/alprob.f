      SUBROUTINE ALPROB(KSEED,NUMRND,RND)
C----------------------------------------------------------------------
C
CKEY MUONID / INTERNAL
C
C!  - Get a random number RND which depends on run,event number as well
C!    as seed KSEED
C!
C!   Author   :- G.Taylor             4-FEB-1992
C!
C!   Inputs:  KSEED/I  Event specific seed
C!            NUMRND/I Number of random numbers needed
C!   Outputs: RND /R   A Random number uniformally distrubuted between
C!                     zero and one
C!======================================================================
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON /BCS/   IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
      SAVE IUSED,RNVEC,ISEED
      PARAMETER(LVEC=200)
      REAL RNVEC(LVEC)
      DATA LSEED/0/
C-----------------------------------------------------------------------
      CALL ABRUEV (KRUN,KNEVT)
      ISEED=1000*KRUN+KNEVT+100*KSEED
      IF(ISEED.NE.LSEED) THEN
        LSEED=ISEED
        IUSED=0
        CALL RMARIN(ISEED,0,0)
        CALL RANMAR(RNVEC,MIN(LVEC,NUMRND))
      ENDIF
      RND = RNVEC(MOD(IUSED,LVEC)+1)
      IUSED=IUSED+1
      RETURN
      END
