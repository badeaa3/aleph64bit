C*EI
C*DK LKPRIN
C*DF UNIX
      SUBROUTINE LKPRIN(COMAND)
C -----------------------------------------------------
C ----------------------------------------------------
C*IF .NOT.DOC
C*CA BCS
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
      COMMON /BCS/   IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
C*CC BCS
C*CA LKFIL
      COMMON/LKFIL/SEQFIL,DIRFIL,FLGFIL(3)
     &            ,LTERM,LCARD,LDBAS,LUFMT,LOUT
     &            ,LFILE(3)
     &            ,LINDAT,LINSEL,LUTDAT,LUTSEL
      LOGICAL SEQFIL,DIRFIL,FLGFIL
      COMMON/FILCAR/SEQNAM,DIRNAM,FILNAM(3)
      CHARACTER*80 SEQNAM,DIRNAM,FILNAM
C*CC LKFIL
      CHARACTER COMAND*80,FILENM*80
C -----------------------------------------------------
      IF (.NOT.FLGFIL(2)) CALL LKOPWR(COMAND,'CARD',132)
      IW(6)=LFILE(2)
      CALL DLUNP (IW(6))
      CALL LKBANK(COMAND)
      IW(6)=6
      CALL DLUNP (IW(6))
      RETURN
      END
