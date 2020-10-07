      SUBROUTINE TPISOL(IARR,NTOT,NGAP,IOFF1,NLEN,NISOL,MXISOL)
C--------------------------------------------------------------------
C!  Take the signal in IARR and find isolated analog pulses.
C!  One pulse is 'isolated' from another when the last time bin of
C!  the first is farther away from the first time bin of the second
C!  than the length of the gap NGAP.
C
C  Called from:  TORAWO, TSRESP
C  Calls:        None
C
C  Inputs:   PASSED:  --IARR,   array containing the full signal
C                     --NTOT,   length of the full signal
C                     --NGAP,   length of gap allowed between non-zero
C                               bins before we call a pulse isolated
C                     --MXISOL, max number of isolated pulses allowed
C
C  Outputs:  PASSED:  --NISOL,  number of isolated pulses
C                     --IOFF1,  offset from IARR(1) of 1st bin of
C                               each isolated pulse
C                     --NLEN,   length of each isolated pulse
C  D. DeMille
C
      DIMENSION IARR(NTOT)
      DIMENSION IOFF1(MXISOL),NLEN(MXISOL)
      LOGICAL LOUT
C
C  number of pulses = 0; lout true means we are not now in a pulse,
C  false means we are in the midst of a pulse
C
      NISOL = 0
      LOUT = .TRUE.
C
C  count the number of contiguous zeros in the pulse as we go
C
      NCON0 = 0
C
      DO 1 J = 1, NTOT
C
         IF ( IARR(J) .GT. 0 ) THEN
C
C  This bin has non-zero content.  The number of consistent zeros must
C  then be zero.
C
            NCON0 = 0
C
C  See if we have been outside an isolated pulse.  If so, we now have
C  begun a new isolated pulse; therefore we turn the 'outside of pulse'
C  flag off, update the number of pulses, and set the first bin of this
C  isolated pulse.  Note that we set IOFF1 = J - 1 since what we really
C  want is the offset of the first bin from the beginning of the pulse.
C
            IF ( LOUT ) THEN
               LOUT = .FALSE.
C
C  Make sure we're not going beyond the max. number of isolated pulses
C  If we have more than MXISOL isolated pulses, put all of what's left
C  in IARR into the last pulse.
C
               IF ( NISOL .EQ. MXISOL ) GOTO 2
C
               NISOL = NISOL + 1
               IOFF1(NISOL) = J - 1
            ENDIF
C
         ELSE
C
C  This bin contains a zero.  Increment the number of contiguous zeros.
C
            NCON0 = NCON0 + 1
C
C  If we have reached the gap length and have begun making isolated
C  pulses, then the latest isolated pulse ended when this latest string
C  of contiguous zeros began.  Therefore, we know and should set the
C  length of the latest isolated pulse, and we also need to turn the
C  'outside of pulse' flag on.
C
            IF ( NCON0 .EQ. NGAP .AND. NISOL .GT. 0 ) THEN
               NLEN(NISOL) = J - NGAP - IOFF1(NISOL)
               LOUT = .TRUE.
            ENDIF
C
         ENDIF
C
C  Next bin
C
 1    CONTINUE
C
C  If we end in a pulse, we will not fill the length of the last pulse
C  in the loop above.  Take care of this case.
C
 2    IF ( .NOT. LOUT ) NLEN(NISOL) = NTOT - IOFF1(NISOL)
C
      RETURN
      END
