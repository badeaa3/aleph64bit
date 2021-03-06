*DK itzcoi
      SUBROUTINE ITZCOI(NWZ,NHZ,TZM,IBIN)
C.
C...ITZCOI  1.00  860610  20:36                         R.Beuselinck
C.
C!  Calculate the 3D trigger result for a single mask using the time
C.  difference values for the hit wires of the mask plus additional
C.  constraints on the allowed layer combinations for the correlated
C.  R-phi-Z trigger.
C.
C.  If the trigger condition is satisfied then the theta bin number is
C.  returned in IBIN, otherwise zero is returned.
C.
C.  Calling arguments:
C.  NWZ  - Total number of hit wires in the mask.              (INPUT)
C.  NHZ  - Number of hit wires in each layer (array).          (INPUT)
C.  TZM  - Time difference values (array of NWZ times).        (INPUT)
C.  IBIN - ITC theta bin number for success, or zero.         (OUTPUT)
C.
C-----------------------------------------------------------------------
#ifndef DOC
#include "iocom.h"
#include "jobcom.h"
#include "itexpc.h"
#include "ittrgc.h"
C
C--  Declare calling arguments.
C--
      INTEGER NHZ(8), NWZ, IBIN
      REAL    TZM(*)
C
C--  Declare local variables.
C--
      INTEGER LAYER(30), IUPDN(30), IORD(30), NLUP(8), IBTT(8)
      REAL    EDGES(30)
      LOGICAL DEBTR
      SAVE IBTT
      DATA IBTT/1,2,4,8,16,32,64,128/
C
      DEBTR = FDEBJO .AND. (ICITJO(2).GE.2)
      IBIN = 0
      CLOCK = CLGOIT
C
C--  Do a preliminary check in case we don't have enough hit wires
C--  to satisfy the trigger.
C--
      NTEST = 0
      DO 20 I=1,8
        IF (NHZ(I).GT.0) NTEST = NTEST + IBTT(I)
   20 CONTINUE
      IDEB = ITZMSK(NTEST)
      IF (ITZMSK(NTEST).EQ.0) GO TO 999
C
C--  Calculate the edges of all the expanded pulses and remember which
C--  layer each one belongs to.
C--
      J = 0
      DO 40 I=1,8
        IF (NHZ(I).GT.0) THEN
          DO 30 II=1,2*NHZ(I)
            LAYER(J+II) = I
   30     CONTINUE
          J = J + 2*NHZ(I)
        ENDIF
   40 CONTINUE
C
      DO 50 I=1,NWZ
        I2 = (I-1)*2
        LAY = LAYER(I2+1)
        EDGES(I2+1) = TZM(I) - PLENIT(LAY)
        EDGES(I2+2) = TZM(I) + PLENIT(LAY)
        IUPDN(I2+1) = 1
        IUPDN(I2+2) = -1
   50 CONTINUE
C
C--  Sort the rising and falling edges by increasing time.
C--
      CALL SORTZV(EDGES,IORD,2*NWZ,1,0,0)
      CALL VZERO(NLUP,8)
      NPBEF = IFIX( (EDGES(IORD(1))-CLOCK)/CLOKIT )
      TGO = NPBEF*CLOKIT + CLOCK
      NCLOK = IFIX( (EDGES(IORD(2*NWZ))-EDGES(IORD(1)))/CLOKIT ) + 1
      TICK = TGO
      TRIGT = 0.
C
C--  Search through the ordered pulse edges in steps of the clock pulse
C--  to find the first instant that the trigger is satisfied.
C--
      NEXT = 1
      DO 80 I=1,NCLOK
        TICK = TICK + CLOKIT
C
C--     Adjust current result for the edges we passed during the
C--     current clock tick.
C--
   60   IF (EDGES(IORD(NEXT)).LT.TICK) THEN
          LAY = LAYER(IORD(NEXT))
          NLUP(LAY) = NLUP(LAY) + IUPDN(IORD(NEXT))
          NTEST = 0
          DO 70 IL=1,8
            IF (NLUP(IL).GT.0) NTEST = NTEST + IBTT(IL)
   70     CONTINUE
C
C--       Stop searching if we have found a valid result.
C--
          IF (ITZMSK(NTEST).NE.0) THEN
            TRIGT = TICK
            GO TO 100
          ENDIF
C
C--       Setup the next edge to be tested.  Exit if none are left.
C--
          NEXT = NEXT + 1
          IF (NEXT.GT.2*NWZ) GO TO 100
          GO TO 60
        ENDIF
   80 CONTINUE
C
C--  Find the theta bin number for this trigger. (0 => no trigger).
C--
  100 IF (TRIGT.EQ.0) GO TO 999
      CALL ITBINT(TRIGT,IBIN)
  999 CONTINUE
C
C--  Detailed debug printout of 3D trigger. (Debug level 2).
C--
      IF (DEBTR) THEN
        WRITE(LOUTIO,1000) IBIN, NWZ, NHZ, (TZM(I),I=1,NWZ)
        IF (IDEB.NE.0) THEN
          WRITE(LOUTIO,1001) TRIGT, (IORD(I),I=1,2*NWZ)
          WRITE(LOUTIO,1002) (EDGES(I),I=1,2*NWZ)
        ENDIF
      ENDIF
 1000 FORMAT(' ITZCOI: ',2I3,1X,8I1,T25,10F10.4,/(T25,10F10.4))
 1001 FORMAT('  TRIGT =',F10.4,' IORD =',30I3)
 1002 FORMAT('  EDGES: ',10F10.4)
      END
#endif
