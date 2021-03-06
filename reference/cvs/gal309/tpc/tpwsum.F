*DK tpwsum
      SUBROUTINE TPWSUM
C -------------------------------------------------------------------
C. - M. MERMIKIDES   860415
C! Brief run summary for TPC
C. - Called by      ASCRUN                          from GALEPH.HLB
C  - Modifications:
C       1. D.Cowen/P.Janot 30-6-88  --  Add TPCSIM closings.
C       2. P.Janot         30-9-88  --  Add time statistics.
C -------------------------------------------------------------------
#ifndef DOC
      SAVE
#include "jqcom.h"
#include "jobcom.h"
#include "iocom.h"
#include "tpstat.h"
      DIMENSION IBIN(11)
C
      WRITE(LOUTIO,801)
C
C If TPCSIM was used, call its closing routine, and
C let 'em know it was used!
C
      IF ( ICTPJO(7).GT.0 ) THEN
         CALL TGFINI
         WRITE(LOUTIO,800) TVERJO
C Time statistics
         TIME = 0.
         NEV = NEVTJO
         IF (NEV.GT.0) TIME = RTPSTA(44)/FLOAT(NEV)
         WRITE(LOUTIO,799) TIME
      ENDIF
C
      WRITE (LOUTIO,802) (ICTPJO(K),K=1,3)
      IF (ICTPJO(4).EQ.0) THEN
         WRITE(LOUTIO,803)
      ELSE
         WRITE(LOUTIO,804)
      ENDIF
      IF (LVELJO(3).LT.2) THEN
         WRITE(LOUTIO,805)
      ELSEIF (LVELJO(3).EQ.2) THEN
         WRITE(LOUTIO,806)
      ENDIF
C
C Statistics on hits
C
      WRITE(LOUTIO,807)
      IF (ICTPJO(2).GT.0) WRITE(LOUTIO,808) (JTPSTA (M),M=1,11)
      IF (ICTPJO(3).GT.0) WRITE(LOUTIO,809) (JTPSTA (M),M=12,22)
C
C Statistics on tracks
C
      WRITE(LOUTIO,810)( JTPSTA (22+M),M=1,11)
C
C Statistics on BOS size
C
      WRITE(LOUTIO,811)( JTPSTA (33+M),M=1,5)
C
 800  FORMAT(//,17x,'*******************************************',/
     &          17x,'*                                         *',/
     &          17x,'*   TPCSIM Version ',F4.2,' ran successfully  *',/
     &          17x,'*                                         *',/
     &          17x,'*******************************************',//)
 799  FORMAT(1X,'Time spent per event = ',F9.3,
     .            ' secs during TPC digitization ' )
 801  FORMAT(1H1,//,10X,'RUN SUMMARY FOR TPC',//)
  802   FORMAT(1X,'simulation level for wires, pads, trigger pads ',3I2)
 803  FORMAT(/,' Track elements have not been saved')
 804  FORMAT(/,' Track elements have been saved')
 805  FORMAT(/,' Simple endplate geometry requested')
 806  FORMAT(/,' Detailed endplate geometry requested')
  807   FORMAT(//,'  Hit multiplicity  ',
     & '  100  200  300  400  500  600  700  800  900 1000  >1000',/)
 808  FORMAT(2X,'PADS' ,14X,11I5)
 809  FORMAT(2X,'TRIGGER PADS',6X,11I5)
 810  FORMAT(//,'  Track entries     ',
     & '    10   20   30   40   50   60   70   80   90  100  >100',/,
     &      20X,11I5)
 811  FORMAT(//,'  maximum # of entries in     TPHT     TTHT     TPTE'
     &,'     TPHE     TTHE' /25X,5I9 )
C
      RETURN
      END
#endif
