      SUBROUTINE FYKINE(DROP,GARB,IBFUL)
C ------------------------------------------------------
CKEY FYXX MCARLO KINE / USER
C - F.Ranjard - 871202             B.Bloch 901010
C! translate KINGAL or GALEPH banks to equivalent Fxxx MC banks
C The banks are KINE,VERT,KHIS,KVOL,KPOL,KZFR-->FKIN,FVER,FVOL,FPOL,FZFR
C Drop tracks and vertices depending on flags set at beginning of run
C through a call to FYIRUN : A CALL TO FYIRUN IS MANDATORY.
C If there is a problem with space, the old banks are not dropped.
C
C - input arguments :
C        DROP     = character flag
C                   if = 'DROP' then drop KINE,VERT,KHIS,KVOL,KPOL and
C                               KZFR banks
C        GARB     = character flag
C                   if = 'GARB' then make a garbage collection
C
C - output argument :
C        IBFUL    = -1 means not enough space in BOS array
C
C - this routine must be called once per event after reading
C - USER routine
      SAVE
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON /BCS/   IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
      PARAMETER (LWORDB = 65536)
      PARAMETER (MAXMCX = 1000, MAXMES = 500)
      COMMON /FYRELA/ IHTYPE,ICALTO
     &               ,ITRCAL(MAXMES),ICALTR(2,MAXMES)
     &               ,LTKNUM,LVXNUM,IMEATR,KINTRK,KINVER
     &               ,FSHDRO,FTKDRO,CUTRAC,BFLCLT,ENMINC
     &               ,INDKIN,INDVER,JDKEKS,JDVNFO,JDVOUT
     &               ,JDKOFN,JDKNFO
      LOGICAL FSHDRO,FTKDRO
      PARAMETER (LFXWBK = 7)
      INTEGER  JDFXWB(LFXWBK)
      EQUIVALENCE (JDFXWB(1),INDKIN)
      COMMON /FYCHAR/ ELISAD
      CHARACTER*48 ELISAD
      CHARACTER*(*) DROP,GARB
      DATA IONC /0/
C -------------------------------------------------------------
C
      IF (IONC.EQ.0) THEN
         NKINE = NAMIND('KINE')
         IONC = 1
      ENDIF
C Test if the KINE banks are present. Do nothing if not.
      IF (IW(NKINE).LE.0)  GOTO 991
C - initialize the event
      IBFUL = 0
      CALL FYINEV(IBFUL)
      IF (IBFUL .EQ. -1)  GOTO 990
C
C - Build a tree of mother and daugther tracks in JDMOTH,JDTREE
C   from KINE and VERT which content tracks and vertices to be kept
C   fill JDKOFN which gives the old KINE# for each new track# and
C        JDKNFO which gives the new track# for each old KINE#
C   JDMOTH and JDTREE are dropped before return
      CALL FYTREE (IBFUL)
      IF (IBFUL .EQ. -1) GOTO 990
C
C - Fill FKIN, FVER, FVOL,FPOI using KINE,VERT and all working banks
      CALL FYFKIN(IBFUL)
      IF (IBFUL .EQ. -1)  GOTO 990
C
C
C - tidy
C
C - Drop work banks and temporary banks
      IF (DROP .EQ. 'DROP') CALL BDROP (IW,'KINEVERTKHISKVOLKPOLKZFR')
      IF (GARB .EQ. 'GARB') CALL BGARB (IW)
C
 990  CONTINUE
C
C - workbanks
      IW(1) = LFXWBK
      CALL WDROP(IW,JDFXWB)
C
  991 CONTINUE
      END
