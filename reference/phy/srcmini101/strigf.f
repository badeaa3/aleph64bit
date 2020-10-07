      SUBROUTINE STRIGF(IRUN,TLCAL,TRAND,TPHYS,TSCAL,FAIL)
C-------------------------------------------------------------
C!  - Return trigger type for current event
C!
C!    Author B.Bloch-Devaux may 92
C!                      Use ALTRIG to access Trigger bits
C!    Input:  IRUN
C!    Output: TLCAL - Trigger is any LCAL trigger
C!            TRAND - Trigger is random   trigger
C!            TPHYS - Trigger is any physics trigger
C!            TSCAL - Trigger is any SICAL  trigger
C!            FAIL  - no trigger info
C?
C!======================================================================
      SAVE
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON /BCS/   IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
      LOGICAL TLCAL,TRAND,TPHYS,TSCAL(4),FAIL
      DIMENSION MASK(3)
      INTEGER ALTRIG
      EXTERNAL ALTRIG
      DATA LRUN/-99999/
C-----------------------------------------------------------------
      FAIL = .TRUE.
      NTRBIT=0
C
C     set up trigger masks if new run
C
      IF(LRUN.NE.IRUN)THEN
        CALL STMASK(IRUN,MASKL,MASKR,MASKP,MASKS,MASK)
        LRUN=IRUN
      ENDIF
C
C?      Get Trigger Bit Pattern
C
      IF( ALTRIG(IT1,IT2,IL2).GT.0 )THEN
        FAIL=.FALSE.
        NTRBIT=IL2
      ELSE
        JKEVEH = IW(NAMIND('EVEH'))
        IF ( JKEVEH.GT.0) THEN
          FAIL=.FALSE.
          NTRBIT = IW(JKEVEH+7)
        ENDIF
      ENDIF
C
      TLCAL=IAND(NTRBIT,MASKL).NE.0
      TRAND=IAND(NTRBIT,MASKR).NE.0
      TPHYS=IAND(NTRBIT,MASKP).NE.0
      TSCAL(1)=IAND(NTRBIT,MASKS).NE.0
      TSCAL(2)=IAND(NTRBIT,MASK(1)).NE.0
      TSCAL(3)=IAND(NTRBIT,MASK(2)).NE.0
      TSCAL(4)=IAND(NTRBIT,MASK(3)).NE.0
C
  999 RETURN
      END
