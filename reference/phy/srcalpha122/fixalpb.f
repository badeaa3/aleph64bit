      SUBROUTINE FIXALPB (IRUN)
CKEY RUN /INTERNAL
C ----------------------------------------------------------------------
C! fix ALPB beam position banks
C!                                      Author: S.Wasserbaech 24.04.95
C!
C! If (real data) .and. (ALPB exists) .and. (julia vers .lt. 276) then
C!   If (ALP1 exists for this setup code) then
C!     If (IRUN appears in ALP1) then
C!       Fix the bank:
C!       Make sure the first row is not null
C!       Replace first-event-number in last row if necessary
C!       If (dbas version .lt. 198) then scale y uncertainty
C!     Else
C!       Set the number of rows in ALPB equal to zero
C!     Endif
C!   Endif
C! Endif
C!
C ----------------------------------------------------------------------
      IMPLICIT NONE
      SAVE NARHAH, INDX0, MESS, DEBUG
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
      INTEGER IW
      REAL RW(10000)
      COMMON /BCS/ IW(10000)
      EQUIVALENCE (RW(1),IW(1))
      INTEGER JALPC1,LALP1A
      PARAMETER(JALPC1=1,LALP1A=1)
      INTEGER JALPFE,JALPXP,JALPXE,JALPYP,JALPYE,LALPBA
      PARAMETER(JALPFE=1,JALPXP=2,JALPXE=3,JALPYP=4,JALPYE=5,LALPBA=5)
      INTEGER JRHAPN,JRHAPD,JRHAPH,JRHAPV,JRHAAV,JRHADV,JRHADD,JRHANI,
     +          JRHANO,JRHACV,JRHANU,LRHAHA
      PARAMETER(JRHAPN=1,JRHAPD=3,JRHAPH=4,JRHAPV=5,JRHAAV=6,JRHADV=7,
     +          JRHADD=8,JRHANI=9,JRHANO=10,JRHACV=11,JRHANU=12,
     +          LRHAHA=12)
      INTEGER LCOLS, LROWS, KROW, KNEXT, ITABL,LFRWRD, LFRROW
      REAL RTABL
      INTEGER ID, NRBOS, L
C
C     Arguments:
      INTEGER IRUN
C
C     Local variable declarations:
      INTEGER KALPB, NARHAH, KRHAH, NRHAH, IRHAH, IJCOR, ISET
      INTEGER KALP1, I, INDX, INDX0, I1, I2, IM, KROW1, ICOL, IFEVL
      INTEGER J, IDBVER, NLINK, GTSTUP, NAMIND, ISHFT, JRUN
      LOGICAL MESS, MODIFY, DEBUG
      LOGICAL THISRUN, HIGHER, LOWER
      CHARACTER*8 PRNAM
      CHARACTER*4 CHAINT
C
      DATA NARHAH / 0 /
      DATA INDX0 / -1 /
      DATA MESS / .FALSE. /
      DATA DEBUG / .FALSE. /
C - # of words/row in bank with index ID
      LCOLS(ID) = IW(ID+LMHCOL)
C - # of rows in bank with index ID
      LROWS(ID) = IW(ID+LMHROW)
C - index of next row in the bank with index ID
      KNEXT(ID) = ID + LMHLEN + IW(ID+1)*IW(ID+2)
C - index of row # NRBOS in the bank with index ID
      KROW(ID,NRBOS) = ID + LMHLEN + IW(ID+1)*(NRBOS-1)
C - # of free words in the bank with index ID
      LFRWRD(ID) = ID + IW(ID) - KNEXT(ID)
C - # of free rows in the bank with index ID
      LFRROW(ID) = LFRWRD(ID) / LCOLS(ID)
C - Lth integer element of the NRBOSth row of the bank with index ID
      ITABL(ID,NRBOS,L) = IW(ID+LMHLEN+(NRBOS-1)*IW(ID+1)+L)
C - Lth real element of the NRBOSth row of the bank with index ID
      RTABL(ID,NRBOS,L) = RW(ID+LMHLEN+(NRBOS-1)*IW(ID+1)+L)
C
C     Logical functions for searching in ALP1:
C     THISRUN(I,JRUN) = .TRUE. if the run at index I of ALP1 is JRUN
C     HIGHER(I,JRUN)  = .TRUE. if the run at index I of ALP1
C                        is greater than JRUN
C     LOWER(I,JRUN)   = .TRUE. if the run at index I of ALP1
C                        is less than JRUN
      THISRUN(I,JRUN) = (ISHFT(ITABL(KALP1,I,JALPC1),-16) .EQ. JRUN)
      HIGHER(I,JRUN)  = (ISHFT(ITABL(KALP1,I,JALPC1),-16) .GT. JRUN)
      LOWER(I,JRUN)   = (ISHFT(ITABL(KALP1,I,JALPC1),-16) .LT. JRUN)
C ----------------------------------------------------------------------
C
      MODIFY = .FALSE.
      IF (DEBUG)
     >      WRITE (IW(6),'(A,I6)') ' Fixalpb called for IRUN =', IRUN
C
C     Real data?
      IF (IRUN .GT. 2000) THEN
C
C     Is ALPB present?
        KALPB = NLINK('ALPB',IRUN)
        IF (KALPB .GT. 0) THEN
C
C     Is Julia version < 276.01?
          IJCOR = 0
          IF (NARHAH .EQ. 0) NARHAH = NAMIND('RHAH')
          KRHAH = IW(NARHAH)
          NRHAH = 0
          IF (KRHAH .GT. 0) NRHAH = LROWS(KRHAH)
          DO IRHAH=NRHAH,1,-1
            PRNAM(1:4) = CHAINT(ITABL(KRHAH,IRHAH,JRHAPN))
            PRNAM(5:8) = CHAINT(ITABL(KRHAH,IRHAH,JRHAPN+1))
            IF (PRNAM .EQ. 'JULIA') THEN
              IJCOR = ITABL(KRHAH,IRHAH,JRHACV)
              IDBVER = ITABL(KRHAH,IRHAH,JRHADV)
              GO TO 10
            ENDIF
          ENDDO
          CALL QMTERM('_FIXALPB_ Unable to get Julia version number.')
          GO TO 1000
C
 10       CONTINUE
          IF (IJCOR .LT. 27601) THEN
C
C     Get setup code.  Does the corresponding ALP1 exist?
            ISET = GTSTUP('BE',IRUN)
            IF (ISET .LT. 0) THEN
              CALL QMTERM('_FIXALPB_ Unable to get setup code.')
              GO TO 1000
            ENDIF
            KALP1 = NLINK('ALP1',ISET)
            IF (KALP1 .GT. 0) THEN
C
C     Look for this run in ALP1.
C     First try location INDX0+1:
              IF ((INDX0 .GE. 0) .AND. (INDX0 .LT. LROWS(KALP1))) THEN
                IF (THISRUN(INDX0+1,IRUN)) THEN
                  INDX = INDX0 + 1
                  GO TO 50
                ENDIF
              ENDIF
C
C     Binary search:
              I1 = 1
              IF (HIGHER(I1,IRUN)) GO TO 1000
              IF (THISRUN(I1,IRUN)) THEN
                INDX = I1
                GO TO 50
              ENDIF
              I2 = LROWS(KALP1)
              IF (LOWER(I2,IRUN)) GO TO 1000
              IF (THISRUN(I2,IRUN)) THEN
                INDX = I2
                GO TO 50
              ENDIF
C
 20           CONTINUE
              IF (I1 .GE. I2-1) GO TO 1000
              IM = (I1 + I2)/2
              IF (THISRUN(IM,IRUN)) THEN
                INDX = IM
                GO TO 50
              ELSEIF (HIGHER(IM,IRUN)) THEN
                I2 = IM
                GO TO 20
              ELSE
                I1 = IM
                GO TO 20
              ENDIF
C
C     Fix ALPB, if necessary:
 50           CONTINUE
              INDX0 = INDX
              IF (DEBUG) THEN
                WRITE (IW(6),'(A,I6,A,I7,I12)') ' Fixalpb> Run', IRUN,
     >               ' found in ALP1:', INDX, ITABL(KALP1,INDX,JALPC1)
                WRITE (IW(6),'(/A,I6)')
     >               ' Fixalpb> Existing ALPB for run', IRUN
                DO I=1,LROWS(KALPB)
                  WRITE (IW(6),'(I6,4I10)') (ITABL(KALPB,I,J), J=1,5)
                ENDDO
              ENDIF
C
C     Check for and repair null first row:
              IF ((LROWS(KALPB) .EQ. 2) .AND.
     >            (ITABL(KALPB,2,JALPFE) .EQ. 1)) THEN
C     Copy second row into first row:
                MODIFY = .TRUE.
                KROW1 = KROW(KALPB,1)
                DO ICOL=1,LCOLS(KALPB)
                  IW(KROW1+ICOL) = ITABL(KALPB,2,ICOL)
                ENDDO
                IW(KALPB+LMHROW) = 1
              ENDIF
C
C     Modify the first event in the last row, if necessary:
              IFEVL = IAND(ITABL(KALP1,INDX,JALPC1),65535)
              IF ((IFEVL .NE. 0) .AND.
     >            (ITABL(KALPB,LROWS(KALPB),JALPFE) .NE. IFEVL)) THEN
                MODIFY = .TRUE.
                IW(KROW(KALPB,LROWS(KALPB))+JALPFE) = IFEVL
              ENDIF
C
C     Scale y uncertainties:
              IF (IDBVER .LT. 198) THEN
                MODIFY = .TRUE.
                DO I=1,LROWS(KALPB)
                  IW(KROW(KALPB,I)+JALPYE) =
     >                        NINT(1.36*FLOAT(ITABL(KALPB,I,JALPYE)))
                ENDDO
              ENDIF
C
              IF (DEBUG) THEN
                WRITE (IW(6),'(/A,I6)')
     >             ' Fixalpb> New ALPB for run', IRUN
                DO I=1,LROWS(KALPB)
                  WRITE (IW(6),'(I6,4I10)') (ITABL(KALPB,I,J), J=1,5)
                ENDDO
              ENDIF
C
            ENDIF
          ENDIF
        ENDIF
      ENDIF
      GO TO 2000
C
C     Clear ALPB (set the number of rows equal to zero):
 1000 CONTINUE
      IW(KALPB+LMHROW) = 0
      MODIFY = .TRUE.
      IF (DEBUG) WRITE (IW(6),'(A)') ' Fixalpb> ALPB cleared.'
C
 2000 CONTINUE
C     If ALPB was modified, print a warning message (once):
      IF (MODIFY .AND. (.NOT. MESS)) THEN
        MESS = .TRUE.
        WRITE (IW(6),'(/4(8X,A/))')
     >'+------------------------------------------------------------+',
     >'|     FIXALPB called to fix ALPB (beam position) banks.      |',
     >'|    !!!! Output banks are not equal to input banks !!!!     |',
     >'+------------------------------------------------------------+'
      ENDIF
C
      RETURN
      END
