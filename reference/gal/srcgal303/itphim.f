      SUBROUTINE ITPHIM(NHIT,TMEXP,ITRGR,ITRGZ)
C.
C...ITPHIM  2.00  890417  13:34                       R.Beuselinck
C.
C!  Fill the 192 ITC trigger masks.
C.
C.  The trigger pattern for one sector is stored in arrays IGRPA and
C.  INWA giving the first wire number used and the number of wires
C.  respectively for each of the 8 layers (this includes the half-cell
C.  overlapping patterns).
C.  The pattern of each sector repeats LPSCT times around the chamber.
C.
C.  The digitisations are copied into an array with built in "wrap"
C.  to avoid complicating the algorithm.
C.
C.  Calling arguments:
C.  NHIT  - Array of hit flag for each wire (=1 if hit).       (INPUT)
C.  TMEXP - Array of expanded time differences for each wire.  (INPUT)
C.  ITRGR - Array of trigger mask results (8-bit address)     (OUTPUT)
C.  ITRGZ - Array of theta bin numbers for Z-trigger result.  (OUTPUT)
C.
C-----------------------------------------------------------------------
      PARAMETER (LPSCT=48, LPICW=8, LPSEC=6, LPMSK=LPSCT*LPSEC)
      REAL    TMEXP(8,0:145), TZM(30)
      INTEGER NHIT(8,0:145), ITRGR(LPMSK), ITRGZ(LPMSK), IBTT(8)
      INTEGER IGRPA(LPICW,LPSEC), INWA(LPICW,LPSEC), NHZ(LPICW)
      INTEGER IBASE(LPICW)
      SAVE IBTT, IBASE, IGRPA, INWA
      DATA IBTT/1,2,4,8,16,32,64,128/
      DATA IBASE/4*2,4*3/
C
C--  Define wire grouping for the trigger.  There is an overlap
C--  by half a cell to provide full coverage.
C--  This set is valid for the configuration 4*96 + 4*144 cells.
C--
C--  Algorithm:  Project outer 144 segments onto inner layers
C--  and produce the closest match possible onto the inner wires
C--  such that one or two wires from each layer are used.
C--
      DATA IGRPA/1,1,1,1, 1,1,1,1,
     1           1,1,1,1, 2,1,2,1,
     1           2,1,2,1, 2,2,2,2,
     1           2,2,2,2, 3,2,3,2,
     1           2,2,2,2, 3,3,3,3,
     1           3,2,3,2, 4,3,4,3/
C
      DATA INWA/2,1,2,1, 2,1,2,1,
     1          2,1,2,1, 1,2,1,2,
     1          1,2,1,2, 2,1,2,1,
     1          2,1,2,1, 1,2,1,2,
     1          2,1,2,1, 2,1,2,1,
     1          1,2,1,2, 1,2,1,2/
C
C--  Calculate the trigger sums by a standard algorithm driven by
C--  tables mapping the wires used in each trigger element.
C--
      CALL VZERO(ITRGR,LPMSK)
      CALL VZERO(ITRGZ,LPMSK)
C
C--  Loop over repeated sectors.
C--
      DO 400 I=1,LPSCT
C--     Loop over trigger elements within one large sector.
        DO 300 K=1,LPSEC
          IT = (I-1)*LPSEC + K
          NWZ = 0
          CALL VZERO(NHZ,LPICW)
C--       Loop over planes for one trigger element.
          DO 200 J=1,LPICW
C--         Base address for sector wire nos.
            IB = (I-1)*IBASE(J)
C--         No. of wires ORed on this layer.
            NLA = INWA(J,K)
C--         Address of 1st wire used.
            IADA = IGRPA(J,K) + IB
C--         Add to count for R-PHI trigger and store times for 3D trig.
            IF (NLA.EQ.1) THEN
C--           Case 1.  One wire contributes for this layer.
              IF (NHIT(J,IADA).NE.0) THEN
                ITRGR(IT) = ITRGR(IT) + IBTT(J)
                NHZ(J) = 1
                NWZ = NWZ + 1
                TZM(NWZ) = TMEXP(J,IADA)
              ENDIF
            ELSE IF (NLA.EQ.2) THEN
C--           Case 2.  Two wires may contribute for this layer.
              N2 = NHIT(J,IADA) + NHIT(J,IADA+1)
              IF (N2.NE.0) THEN
                ITRGR(IT) = ITRGR(IT) + IBTT(J)
                NHZ(J) = N2
                IF (NHIT(J,IADA).GT.0) THEN
                  NWZ = NWZ + 1
                  TZM(NWZ) = TMEXP(J,IADA)
                ENDIF
                IF (NHIT(J,IADA+1).GT.0) THEN
                  NWZ = NWZ + 1
                  TZM(NWZ) = TMEXP(J,IADA+1)
                ENDIF
              ENDIF
            ENDIF
  200     CONTINUE
C
C--       Evaluate the time coincidence for this mask and store the
C--       theta bin number in ITRGZ if the 3D trigger conditions are
C--       satisfied.
C--
          CALL ITZCOI(NWZ,NHZ,TZM,ITRGZ(IT))
  300   CONTINUE
  400 CONTINUE
      END
