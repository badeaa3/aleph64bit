      SUBROUTINE VGBRUT(ICOMP, SOLVED)
C ---------------------------------------------------------------------
C! Try to solve a VDET pat. rec. component by "brute force."
CKEY VGLOB VDET TRACK
C
C      Paul Rensing   - 29-3-95
C
C This routine solves the combinatorial problem by "brute force",
C      ie. complete enumeration. However, it first checks if the 
C      component is "diagonal", that is, the obvious solution is
C      feasible and is therefore the solution. If so, it simplely
C      produces a single solution and returns. If the component is
C      small enough, it finds all solutions (maximum number MAXSOLN)
C      which are with FINALPRB of the best.
C
C  INPUT:
C      INTEGER ICOMP    - the number of the component to solve
C OUTPUT:
C      LOGICAL SOLVED   - .TRUE. if solved
C      Banks VGHC and VGXC, NR=ICOMP are created if SOLVED is .TRUE.
C ------------------------------------------------------------------
#ifndef DOC
      IMPLICIT NONE
C
C Function parameters
C
      INTEGER ICOMP
      LOGICAL SOLVED
C
C  Global includes
C
#include "bcs.h"
#include "vglbcm.h"
C
C HAC parameters
C
#include "vctljj.h"
#include "vm5cjj.h"
#include "vghcjj.h"
#include "vgxcjj.h"
#include "vggwjj.h"
#include "vdgcjj.h"
#include "vdxyjj.h"
#include "vdztjj.h"
C
C  Function calls
C
      INTEGER NDROP, NLINK, NBANK, NAMIND, VDYEAR
      EXTERNAL NDROP, NLINK, NBANK, NAMIND, VDYEAR
C
C local variables
C
      integer indhmap
      integer indvm
      integer indsoln
      integer indo, indxs, indss
      integer indVDGC, year, namVDGC
      integer indtrk
      integer hit, wafer, bank
      integer ITrk, NTrk
      integer i, j, k, isoln
      integer nsoln
      integer jvgxc, jvghc
      integer layer, view, grk
      integer col
      integer iinc
      integer indVDXZ
      integer row
      real worst
      real ph1
      real logP, logPMax
      real size
      Character*4 VDHitBnk(NVIEW)
      Integer nassCol(NVIEW)
      integer indVGGW, pckhit, hitId, jVGGW
      logical print_it
      integer namVTDP,indVTDP,itdp,itvtdp,irun,ievt
      integer iret
C
      SAVE namVDGC, VDHitBnk, nassCol
C
#include "bmacrod.h"
C
      DATA namVDGC/0/
      DATA VDHitBnk/'VDZT','VDXY'/
      DATA nassCol/JVDZNA, JVDXNA/
C
C  Inline functions
C
#include "bmacro.h"
C
C First, find the list of tracks and hits in each view/layer.
C
      if (namVDGC .eq. 0) then
         namVDGC = NAMIND('VDGC')
         namVTDP = NAMIND('VTDP')
      end if
C
      print_it = .false.
      solved = .false.
      logPMax = 1.0E10
      NSoln = 0
C
C Determine VDET year
C
      year = VDYEAR()
      if (year .eq. 95) Then
         indVDGC = IW(namVDGC)
         if (indVDGC .le. 0) then
            call RERROR('VGBRUT', -10, ' Missing VDGC bank')
            goto 999
         end if
      end if
C
C Pick up the list of tracks and the lists of hits in each layer/view
C
      indtrk = NLINK('VCTL', ICOMP)
      ntrk = LROWS(indtrk)
C
C Create the output banks at maximum size
C
      INDSS = NBANK('VGHC', ICOMP, LMHLEN + LVGHCA*ntrk*MAXSOLN)
      INDXS = NBANK('VGXC', ICOMP, LMHLEN + LVGXCA*MAXSOLN)
      IF (INDXS .EQ. 0 .OR. INDSS .EQ. 0) THEN
         CALL RERROR('VGBRUT', -1, ' Out of memory')
         GOTO 999
      END IF
      IW(INDSS + LMHCOL) = LVGHCA
      IW(INDSS + LMHROW) = 0
      IW(INDXS + LMHCOL) = LVGXCA
      IW(INDXS + LMHROW) = 0
C
C Create a temporary bank to hold the solution internally
C
      indo = NBANK('VGXX', 1, LMHLEN + MAXSOLN*(1 + NTrk))
      IF (indo .eq. 0) THEN
         CALL RERROR('VGBRUT',-1,' Out of memory')
         GOTO 999
      END IF
      IW(INDO + LMHCOL) = 1 + NTRK
      IW(INDO + LMHROW) = 0
C
C Create various temporary banks
C
      indvm = NBANK('VGXX', 2, NTrk)
      indhmap = NBANK('VGXX', 3, NTrk)
      indsoln = NBANK('VGXX', 4, NTrk)
      if (indvm.le.0 .or. indhmap.le.0 .or. indsoln.le.0) then
         call rerror('VGBRUT',-1,' Out of memory')
         goto 999
      end if
C
C Pick up the VGGW bank for work space
C
      indVGGW = NLINK('VGGW', 0)
      if (indVGGW .le. 0) then
         call RERROR('VGBRUT', -13,' Missing VGGW bank')
         goto 999
      end if
      call vzero(IW(indVGGW+LMHLEN+1), LROWS(indVGGW)*LCOLS(indVGGW))
C
C See if printout is requested for a track in this event
C
      indVTDP = 0
      if (IW(namVTDP).gt.0) then
        call abruev(irun,ievt)
        indVTDP = NLINK('VTDP',ievt)
      endif
C
C Pick up all the needed VM5C banks. Initialize solution indices.
C Compute the size of the component (number of permutations)
C
      size = 1.0
      do itrk = 1, ntrk
         iw(indsoln+itrk) = 1
         IW(indvm+itrk) = NLINK('VM5C', ITABL(indtrk,itrk,JVCTTR))
         Size = Size * FLOAT(LROWS(IW(indvm+itrk)))
         if (indVTDP.gt.0 .and. .not.print_it) then
            do itvtdp = 1, IW(indVTDP)
                itdp = IW(indVTDP+itvtdp)
                if (itdp .eq. ITABL(indtrk,itrk,jvcttr))print_it=.true.
            enddo
         endif
      end do
      if (print_it) write(iw(6),1) icomp
 1    format(1X,'VGBRUT - Component: ',I6)
C
C For only one track, skip all the bookkeeping needed for constraints.
C
      IF (NTRK .EQ. 1) GOTO 10
C
C Create a map, parallel to VM5C, which maps the global hit # to the hit
C     number within the component (ie. index into indhcnt, etc.). For
C     all hits in the component, find the maximum normalized pulse
C     height. This may tell us if the pulse is definitely a single hit.
C
      DO ITrk = 1, NTRK
         IW(Indhmap+Itrk) = NBANK('VGXX', 200+ITrk,
     $        LMHLEN + 8*LROWS(IW(Indvm+Itrk)))
         IF (IW(Indhmap+Itrk) .EQ. 0 ) THEN
            CALL RERROR('VGBRUT', -1,' out of memory')
            GOTO 999
         END IF
         IW(IW(Indhmap+Itrk)+LMHROW) = LROWS(IW(Indvm+Itrk))
         IW(IW(Indhmap+Itrk)+LMHCOL) = 8

         DO J = 1, LROWS(IW(Indvm+Itrk))
            Do Layer = 1, NLAYER
               do grk = 1, NGRK
                  Do View = 1, NVIEW
                     col = (Layer-1)*4 + (grk-1)*2 + (View-1)
                     pckhit = ITABL(IW(Indvm+Itrk), J, JVM5HW+col)
                     if (pckhit .le. 0) then
                        IW(KROW(IW(Indhmap+Itrk),J)+col+1) = 0
                     else
                        call VHitID(pckhit, view, hitId)
                        IW(KROW(IW(Indhmap+Itrk),J)+col+1) = hitId
C
                        jVGGW = KROW(indVGGW,hitId)
                        if (year .eq. 95) then
                          RW(jVGGW + JVGGPH) =
     $                          RTABL(IndVDGC,hitID,jVDGPH)
                        else
                          if (RTABL(IW(Indvm+Itrk), J, JVM5PH+col) .gt.
     $                       RW(jVGGW + JVGGPH)) then
                            RW(jVGGW + JVGGPH) =
     $                          RTABL(IW(Indvm+Itrk), J, JVM5PH+col)
                          endif
                        end if
C
C Find out how many times the hit has already been used.
C
                        call VHUpRm(pckhit, view, hit, bank)
                        indVDXZ = NLINK(VDHitBnk(view), bank)
                        IW(KROW(indVGGW,hitId)+JVGGNA) =
     $                       max( IW(KROW(indVGGW,hitId)+JVGGNA),
     $                       abs(ITABL(indVDXZ, hit, nassCol(view))) )
                        if (year .eq. 95)
     $                       IW(KROW(indVGGW,hitId)+JVGGNA) =
     $                       max( IW(KROW(indVGGW,hitId)+JVGGNA),
     $                       abs(ITABL(indVDGC, hitId, JVDGNA)) )
                     end if
                  end do
               end do
            end do
         end do
      END DO
C
C convert the maximum normalize ph. into a possible number of track
C     associations.
C
      DO I = 1, LROWS(indVGGW)
         IF (RTABL(indVGGW,I,JVGGPH) .LT. PHTHRN) THEN
            IW(KROW(indVGGW,I) + JVGGHL) = 1
         ELSE
            IW(KROW(indVGGW,I) + JVGGHL) = 2
         END IF
      END DO
C
C
C Loop through all cases
C
C build a valid solution
C
 10   CONTINUE
C
C dump the current solution if dummy cares
C
      if (print_it) then
        do i = 1, ntrk
          write(iw(6),2) ITABL(indtrk,i,jvcttr),(ITABL(IW(indVM+i),
     &          IW(indSoln+i),jvm5hw+j),j=0,7)
        enddo
 2      format(1x,'VGBRUT - Track ',I3,': ',8(I8,2X))
      endif
      IINC = NTRK
      IF (NTRK .EQ. 1) GOTO 20
      DO I = 1, LROWS(indVGGW)
         jVGGW = KROW(indVGGW,I)
         IW(jVGGW + JVGGHC) = IW(jVGGW + JVGGNA)
         IW(jVGGW + JVGGX1) = 0
         IW(jVGGW + JVGGX2) = 0
      END DO

      DO ITrk = 1, NTRK
         DO J = 1, NGRK*NLAYER*NVIEW
C           local hit number (within component)
            HIT = ITABL(IW(Indhmap+Itrk),IW(Indsoln+Itrk),J)
            IF (HIT .GT. 0) THEN
               jVGGW = KROW(indVGGW,hit)
               IF (IW(jVGGW + JVGGHC) .LT. IW(jVGGW + JVGGHL) ) THEN
                  IW(jVGGW + JVGGHC) = IW(jVGGW + JVGGHC) + 1
               ELSE
C
C                 This solution is no good. Increment the counters
                  IINC = ITrk
                  if (print_it) then
                    write(iw(6),3) hit
 3                  format(1X,'VGBRUT - Solution discarded; too many ',
     &                  'hits for PH ',I10)
                  endif
                  GOTO 151
               END IF
C
C Count the difference in pulse height between this hit and its partner.
C
               k = MOD(J,2)*2 - 1
               IW(jVGGW + JVGGX1 + IW(jVGGW+JVGGHC)-1) = 
     $              ITABL(IW(Indhmap+Itrk),Iw(Indsoln+Itrk),J+k)
            END IF
         END DO
      END DO
C
C Check that the double hits are much bigger than their (single) partners.
C Some double hits maybe have been assigned first in a previous
C     component, so start checking at IW(jVGGW + JVGGNA)+1.
C
      do i = 1, LROWS(indVGGW)
         jVGGW = KROW(indVGGW,i)
         if (IW(jVGGW + JVGGHC) .gt. 1) then
            ph1 = RW(jVGGW + JVGGPH)
            do j = IW(jVGGW + JVGGNA)+1, 2
               hitId = IW(jVGGW + JVGGX1 + j-1)
               if (hitId .gt. 0 .and.
     $              ITABL(indVGGW,hitID,JVGGHC) .eq. 1) then
                  if (ph1 - RTABL(indVGGW,hitID,JVGGPH)
     $                  .lt. PHDIFF2V) then
                      if (print_it) then
                        write(iw(6),4) hitID
 4                      format(1X,'VGBRUT - Solution discarded, ',
     $                      'PH/partner too low ',I10)
                      endif
                      goto 151
                  endif
               end if
            end do
         end if
      end do
C
C The hits are assigned within the constraints, so this is a valid solution
C
 20   CONTINUE
      logP = 0.0
      DO ITrk = 1, NTRK
         logP = logP + RTABL(IW(Indvm+Itrk), IW(Indsoln+Itrk),
     $        JVM5CP)
      END DO
C
C keep the solution only if it a less than the current maximum chi^2
C
      IF (logP .LE. logPMax) THEN
         if (LROWS(indo) .lt. MAXSOLN) then
            IW(indo + LMHROW) = IW(indo + LMHROW) + 1
            row = IW(indo + LMHROW)
         else
            worst = -1.0
            do j = 1, LROWS(indo)
               if (rtabl(indo,j,1) .gt. worst) then
                  worst = RTABL(indo,j,1)
                  row = j
               end if
            end do
         end if
         j = KROW(indo,row)
         RW(j+1) = logP
         do ITrk = 1, NTrk
            IW(j + 1 + ITrk) = IW(indsoln+itrk)
         END DO
         if (print_it) then
            write(iw(6),5) row,logP,MIN(9999999.,logPMax)
 5          format(1X,'VGBRUT - Solution kept in row',I6,
     $          ' logP=',F12.5,' max=', F12.5)
         endif
C
         IF ( (LOGP + NTrk * FINALPRB) .lt. logPMAX) THEN
            logPMAX = LOGP + NTrk * FINALPRB
            if (print_it) then
                write(iw(6),6) logPMax
 6              format(1X,'VGBRUT - logPMAX decreased to ',F12.5)
            endif
         END IF
      else
C
C If we reject the solution because the Chi^2 is too high, then any track
C     (starting from end) with index == 1 cannot be improved. Thus,
C     first track (from high end) with an index > 1 is the first
C     suspect, but you therefore increment the one below that. (Very
C     complicated, I know, but think about it first.)
C
C  ** This would be equivalent to testing the partial sum of the chi^2
C     and forcing an increment when it crosses the maximum. However, we
C     wish to be able to weight the individual chi^2 to form the total,
C     so this must be delayed until now.
C
C  ** Note that this does not work if the total objective does not always
C     increase when the solution index of any track increases.
C
         if (print_it) then
            write(iw(6),7)
 7          format(1X,'VGBRUT - Solution rejected for high chi^2.')
         endif
         do k = NTrk, 1, -1
            if (IW(indSoln+K) .gt. 1) then
               iinc = K - 1
               goto 151
            end if
         end do
      END IF
C
C Increment the indices and go on to the next solution
C If the size is too big, do not go on. Thus, we only test the first
C     solution to see if the component is diagonal.
C
 151  continue
       if (size .lt. MAXBRTSZ) then
         DO K = IINC,1,-1
            IF (IW(indSoln+K) .LT. LROWS(IW(indvm+K))) THEN
               IW(indSoln+K) = IW(indSoln+K) + 1
               DO L = K+1, NTrk
                  IW(indSoln+L) = 1
               END DO
               GOTO 10
            END IF
         END DO
      end if
C
C We have processed all combinations. 
C 
C Sort the chi^2 values and keep only those below the cut.
C
 100  CONTINUE
      NSOLN = LROWS(indo)
      IF (NSOLN .EQ. 0) THEN
         solved = .FALSE.
         goto 999
      else
         solved = .TRUE.
      end if
C
      CALL SORTRQ(RW(indo+LMHLEN+1),1+NTRK,NSOLN,1)
      logPMax = RTABL(indo,1,1) + NTrk * FINALPRB
      DO I = 2, NSOLN
         IF (RTABL(indo,i,1) .GT. logPMax) THEN
            NSOLN = I-1
            GOTO 200
         END IF
      END DO
 200  CONTINUE
C
C Copy the solutions into the output banks
C
      DO ISoln = 1, NSoln
         JVGXC = KNEXT(INDXS)

         RW(JVGXC + JVGXCH) = RTABL(INDO,isoln,1)
         IW(JVGXC + JVGXNT) = ntrk
         IW(INDXS + LMHROW) = IW(INDXS + LMHROW) + 1
C
C Dump the final answer if needed
C
         if (print_it .and. (ISoln.eq.1)) then
            write(iw(6),8) rtabl(indo,isoln,1)
 8          format(1X,'VGBRUT - Final logP=',F12.5)
         endif
         DO Itrk = 1, ntrk
            JVGHC = KNEXT(INDSS)
            IW(JVGHC + JVGHSN) = ISoln
            IW(JVGHC + JVGHTN) = ITABL(indtrk,itrk,1)
            if (print_it .and. (isoln.eq.1))then
                write(iw(6),9) ITABL(indtrk,itrk,jvcttr)
 9              format(1X,'VGBRUT - Track: ',I6)
            endif
            k = itabl(INDO,isoln,1+itrk)
            Do j = 1, NVIEW*NLAYER*NGRK
               IW(JVGHC + JVGHH1 + j-1) =
     $              ITABL(IW(indvm+itrk),k,JVM5HW+j-1)
CC     $              MAX(0, ITABL(IW(indvm+itrk),k,JVM5HW+j-1))
                if (print_it.and.(isoln.eq.1)) then
                    write(iw(6),11) j,IW(JVGHC + JVGHH1 + j-1)
 11                 format(1X,'VGBRUT - Hit ',I6,' is ',I10)
                endif
            end do

            IW(INDSS + LMHROW) = IW(INDSS + LMHROW) + 1
         END DO
      END DO
C
C Final clean up
C
 999  CONTINUE
C
C Shrink the output banks to the correct size
C
      If (NSoln .gt. 0) then
         INDSS = NBANK('VGHC', ICOMP, LMHLEN + LVGHCA*ntrk*NSoln)
         INDXS = NBANK('VGXC', ICOMP, LMHLEN + LVGXCA*NSoln)
      Else
         iret = NDROP('VGHC', ICOMP)
         iret = NDROP('VGXC', ICOMP)
      End If
C      
      CALL BDROP(IW, 'VGXX')
C      
      RETURN
      END
#endif
