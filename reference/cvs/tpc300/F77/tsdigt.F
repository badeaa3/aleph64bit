*DK tsdigt
      SUBROUTINE TSDIGT(KCHAN,IADC1,NLADC)
C--------------------------------------------------------------------
C!  Digitization of the analog signal
C
C  Called from:  TSRESP
C  Calls:        RANNOR, RNDM
C
C  Inputs:   PASSED:      --IADC1, the first bin of the signal
C                         --NLADC, the number of bins in the signal
C                         --KCHAN, channel type 1=wire,2=pad,3=trig
C            BANKS:       --work bank id ITMADC, containing the shaped
C                           signal
C            TPCONS.INC:  --TSIGMX, max. value of the shaping signal
C                         --NTPBIT, num. of bits in the FADC
C            TPCOND.INC:  --SDIDEF, differential nonlinearity level
C                         --SGADEF, sigma for gain variation
C                         --SPEDEF, sigma for pedestal variation
C                         --PEDDEF, pedestal
C  Outputs:  BANKS:       --id ITMADC, the digitized signal;
C                           IW(ITMADC+I) = signal in Ith bin
C
C  Written by A. Peisert
C  Version 1.0  12.12.84
C  Version 1.1   1.11.85  D.D.
C
C  Modifications:
C
C  1. D. Casper 12 Oct 92 - alter treatment of pedestals, and diff.
C     non-linearity.  Make variation for pads half that for wires.
C
#include "bcs.h"
#include "tpcbos.h"
#include "tpcons.h"
#include "tpcond.h"
C
      LOGICAL LDBI2,LDBI3,LGPVR,LDFNL
C
      DATA ICALL/0/
C
C  Debug levels
C
      ICALL = ICALL + 1
      LDBI2 = ( NTPCDI .GE. 2 .AND. ICALL .LE. NCALDI )
      LDBI3 = ( NTPCDI .GE. 3 .AND. ICALL .LE. NCALDI )
C
C  If this is the first call, set up constants
C
      IF ( ICALL .EQ. 1 ) THEN
C
         MAXDIG = 2**NTPBIT - 1
         SDIFF = SDIDEF * TSIGMX / FLOAT(MAXDIG)
C
         LGPVR = ( SGADEF .NE. 0. .OR. SPEDEF .NE. 0. )
         LDFNL = ( SDIDEF .NE. 0. )
C
         IF ( LDBI2 ) WRITE(6,104) PEDDEF,SPEDEF,100.*SGADEF,SDIDEF
C
      ENDIF
C
C  Now we need to add the pedestal, as well as the gain variation,
C  pedestal variation, and differential nonlinearity to the shaped
C  signal.  The gain and pedestal variation should be the same
C  throughout each pulse, so get random numbers for these variations on
C  this pulse now.
C
      IF ( LGPVR ) THEN
         CALL RANNOR(RGAVR,RPDVR)
         IF(KCHAN.EQ.2)THEN
             RGAVR = RGAVR * 0.5
             RPDVR = RPDVR * 0.5
         ENDIF
      ELSE
         RGAVR = 0.
         RPDVR = 0.
      ENDIF
      IF( LDFNL ) THEN
          IF(KCHAN.EQ.2)THEN
              RDIFNL = SDIFF * 0.5
          ELSE
              RDIFNL = SDIFF
          ENDIF
      ELSE
           RDIFNL = 0.
      ENDIF
C
      DO 11 I = 1,NLADC
C
         IBK = IADC1 + I
C
C  Include gain variation
C
         RW(ITMADC+IBK) = RW(ITMADC+IBK) * (1. + SGADEF*RGAVR)
C
C  Add pedestal and pedestal variation
C
         RW(ITMADC+IBK) = RW(ITMADC+IBK) + PEDDEF
         RW(ITMADC+IBK) = RW(ITMADC+IBK) + RPDVR*SPEDEF
C
C  Differential nonlinearity; this changes with every time bucket
C
         IF ( LDFNL ) RW(ITMADC+IBK) =
     1    RW(ITMADC+IBK) + (RNDM(I) - 0.5) * RDIFNL * RW(ITMADC+IBK)
C
C  Now do the digitization using the calculated parameters and
C  keeping within range.
C
         IW(ITMADC+IBK) =  INT( MAXDIG * RW(ITMADC+IBK) / TSIGMX )
         IF ( IW(ITMADC+IBK) .LT. 0 )      IW(ITMADC+IBK) = 0
         IF ( IW(ITMADC+IBK) .GT. MAXDIG ) IW(ITMADC+IBK) = MAXDIG
C
 11   CONTINUE
C
      RETURN
C_______________________________________________________________________
C
 104  FORMAT(/,' +++TSDIGT+++     ADC analog pedestal = ',F6.3,
     &        /'                  VOLTS with sigma    = ',F6.3,
     &        /'                  GAIN variation      = ',F6.3,' %',
     &        /'           Diff. nonlinearity of FADC = ',F5.2,
     &                                                  ' LSB',//)
C
      END
