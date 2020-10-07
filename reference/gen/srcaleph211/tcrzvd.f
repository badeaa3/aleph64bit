      SUBROUTINE TCRZVD(IEND,ZOLD,ZNEW)
C---------------------------------------------------------------------
C! Correct z coordinates for new drift velocity and t0 values
CKEY TPC Z /INERNAL
C!    Author:    F. Sefkow      3-02-92
C!    Modified:  W. Wiedenmann  3-02-92
C!               F. Ranjard    24-02-92
C!    Input:  IEND     /I         TPC side (A=1,B=2)
C!            ZOLD     /R         old z coordinate
C!    Output: ZNEW     /R         new z coordinate
C!
C!    Description:
C!    Get old and new drift velocity and t0 and correct Z coordinate
C!    with these values.
C!    If drift velocity or old T0 is not found STATUS is set to wrong
C!    for the full run: Z-coordinates will not be corrected.
C!    If new T0 is not found it is assumed to be equal to old T0 and the
C!    STATUS is OK.
C!
C!    Called by TUN1NC
C
C-----------------------------------------------------------------------
      SAVE
C
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON /BCS/   IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
      PARAMETER(JJCODX=1,JJCODY=2,JJCODZ=3,JJCOGT=4,JJCODB=5,JJCOEZ=8,
     +          LJCONA=9)
      PARAMETER(JT0GID=1,JT0GVR=2,JT0GGT=4,JT0GA1=5,JT0GA2=6,JT0GA3=7,
     +          JT0GAW=8,JT0GOF=9,LT0GLA=9)
C
      INTEGER AGETDB
      REAL DVZ(2), DVZOLD(2), DVA(3), DVB(3)
      DATA NJCON /0/
C
C!    set of intrinsic functions to handle BOS banks
C - # of words/row in bank with index ID
      LCOLS(ID) = IW(ID+1)
C - # of rows in bank with index ID
      LROWS(ID) = IW(ID+2)
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
C -----------------------------------------------------------------
C
      IF (NJCON .EQ. 0) THEN
        NJCON=NAMIND('JCON')
        NTSIM=NAMIND('TSIM')
        IRLST=0
        ISTATUS = 1
      ENDIF
C
C++   Set ZNEW=ZOLD , return if MC data
C
      ZNEW = ZOLD
      IF (IW(NTSIM).NE.0) RETURN
C
C++   Get the current run number
C
      CALL ABRUEV (IRUN,IEVT)
C
      IF (IRLST.NE.IRUN) THEN
          IRLST=IRUN
C
C-------  old drift velocity and t0 from JULIA constants bank JCON
C         if not found return with wrong STATUS
C
          KJCON=IW(NJCON)
          IF (KJCON.EQ.0) GOTO 998
          DVZOLD(1) = RTABL( KJCON,1, JJCODZ)
          T0OLD = RTABL( KJCON,1, JJCOGT)
          IF (LCOLS(KJCON).GT.JJCOGT) THEN
             DVZOLD(2) = RTABL(KJCON,1,JJCODB+2)
          ELSE
             DVZOLD(2) = DVZOLD(1)
          ENDIF
C
C-------  new drift velocity, if not found return with wrong STATUS
C
          CALL TPDVEL ('POT',DVA,DVB,IER)
          IF (IER.NE.0) GOTO 998
          DVZ(1) = DVA(3)
          DVZ(2) = DVB(3)
C
C-------  new t0 shift, if not found take the old one
C
          T0NEW= GTT0GL(IRUN)
          IF (T0NEW.EQ.0.) T0NEW = T0OLD
C      status is OK
          ISTATUS = 0
      ENDIF
C
C++   Make transformation if STATUS is OK
C
      IF (ISTATUS.EQ.0) ZNEW = (ZOLD/DVZOLD(IEND)+T0OLD-T0NEW)*DVZ(IEND)
      RETURN
C
C - wrong status
 998  ISTATUS = 1
      END
