*DK tpasig
      SUBROUTINE TPASIG
C -------------------------------------------------------------------
C - TPC user operations after event tracking
C! Compress and sort TCP banks
C. - Called from          ASASIG                     from GALEPH.HLB
C -------------------------------------------------------------------
#ifndef DOC
      SAVE
#include "jobcom.h"
#include "jqcom.h"
#include "iocom.h"
#include "tpgpar.h"
#include "tpstat.h"
      DIMENSION NPHR(LTPDRO),NTHR(LTTROW)
#include "tpnamc.h"
C -------------------------------------------------------------------
C
C   Reduce size of banks if possible
C
      CALL AUBPRS ('TPTETPHTTPHETTHTTTHE')
C
C  Accumulate some statistics for the run summary
C  Count hits on each padrow and track entries
C  (at this stage, hits are stored in chronological
C  order for each track)
C
      KHTP = IW(NATPHT)
      IF (KHTP.GT.0) THEN
         IBIN = IUCHAN(FLOAT(IW(KHTP+2)),0.,100.,10)
         IF (IBIN.GT.0) JTPSTA (IBIN) = JTPSTA (IBIN) + 1
         ITLAST = 0
         NTRK = 0
      DO 10 K=1,LTPDRO
  10     NPHR(K)=0
         DO 5 J= 1,IW(KHTP + 2)
            KH = KHTP + 2 + (J-1)*IW(KHTP+1)
            IT =   IW(KH + 1)
            IROW = IW(KH + 2)/100000
            NPHR(IROW) = NPHR(IROW) + 1
            IF (IT.NE.ITLAST) NTRK = NTRK + 1
            ITLAST = IT
5        CONTINUE
         IBIN = IUCHAN(FLOAT(NTRK),0.,10.,10)
         IF (IBIN.GT.0) JTPSTA (22+IBIN) = JTPSTA (22+IBIN) + 1
      ENDIF
C  Trigger pad hits
      KHTT = IW(NATTHT)
      IF (KHTT.GT.0) THEN
         IBIN = IUCHAN(FLOAT(IW(KHTT+2)),0.,100.,10)
         IF (IBIN.GT.0) JTPSTA (11+IBIN) = JTPSTA (11+IBIN) + 1
         ITLAST = 0
         NTRK = 0
         DO 20 K=1,LTTROW
  20     NTHR(K)=0
         DO 6 J= 1,IW(KHTT + 2)
            KH = KHTT + 2 + (J-1)*IW(KHTT+1)
            IT =   IW(KH + 1)
            IROW = IW(KH + 2)/100000
            NTHR(IROW) = NTHR(IROW) + 1
            IF (IT.NE.ITLAST) NTRK = NTRK + 1
            ITLAST = IT
 6       CONTINUE
C Get track statistics from trigger pad hits if pad hits not available
         IF (KHTP.EQ.0) THEN
            IBIN = IUCHAN(FLOAT(NTRK),0.,10.,10)
            IF (IBIN.GT.0) JTPSTA (22+IBIN) = JTPSTA (22+IBIN) + 1
         ENDIF
      ENDIF
C
C  Sort hit banks and their TE references
C
      CALL TPHSRT(NATPHT,NATPHE)
      CALL TPHSRT(NATTHT,NATTHE)
C
C Get statistics on BOS size of banks created by TPC
C
      IF(KHTP.GT.0)
     &     JTPSTA(34) = MAX (JTPSTA(34),IW(KHTP+LMHROW))
      IF(KHTT.GT.0)
     &     JTPSTA(35) = MAX (JTPSTA(35),IW(KHTT+LMHROW))
      KTPTE = IW(NATPTE)
      IF(KTPTE.GT.0)
     &     JTPSTA (36) = MAX (JTPSTA(36),IW(KTPTE+LMHROW))
      KTPHE = IW(NATPHE)
      IF(KTPHE.GT.0)
     &     JTPSTA(37) = MAX (JTPSTA(37),IW(KTPHE+LMHROW))
      KTTHE = IW(NATTHE)
      IF(KTTHE.GT.0)
     &     JTPSTA(38) = MAX (JTPSTA(38),IW(KTTHE+LMHROW))
C Debug printout
C
      IF (FDEBJO .AND. IPRIJO(3).EQ.1) THEN
         IF(ICTPJO(2).GT.0) THEN
            WRITE(LOUTIO,810) NPHR
            CALL TPRHIT('TPHT')
         ENDIF
         IF(ICTPJO(3).GT.0) THEN
            WRITE(LOUTIO,811) NTHR
            CALL TPRHIT('TTHT')
         ENDIF
      ENDIF
 810  FORMAT (/1X,'+++TPASIG+++ TPC pad hits on each row         ',21I4)
 811  FORMAT (/1X,'+++TPASIG+++ TPC trigger pad hits on each row ',19I4)
C
      RETURN
      END
#endif
