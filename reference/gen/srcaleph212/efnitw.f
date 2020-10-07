      SUBROUTINE EFNITW(X,SYSTM,CL,RW,ST,SC,MD,PL,WRONG)
C.----------------------------------------------------------------------
CKEY ECALDES TOWER ROW COLUMN STACK / USER
C     H.Videau      Creation 24/11/88      Modification 14/03/90
C! Finds column, row and stack numbers
C  The same routine as EFNDTW except the wrong flag which is here an
C  integer
C  Looks for the column,the row and the stack containing the point X.
C   Input :
C           X       point coordinates in the Aleph system  REAL
C           SYSTM   the reference system (not implemented) CHARACTER*5
C   Output:
C           SC    subcomponent number    INTEGER
C           MD    module number          INTEGER
C           CL    column number   i      INTEGER
C           RW    row   number    j      INTEGER
C           ST    stack number    k      INTEGER
C           PL    plane number           INTEGER
C           WRONG error flag :           INTEGER
C                                      0  CORRECT
C                                      1  wrong SUBCOMPONENT
C                                      2  wrong MODULE
C                                      3  wrong REGION
C                                      4  wrong COLUMN
C                                      5  wrong PLANE
C                                      6  wrong ROW
C                                      7  wrong STACK
C ACHTUNG!!! the notion of i and j is different in Ecal and Hcal
C   Calls: EPLSCC,EPLSCN, EPLSQL
C   Called by USER
C.----------------------------------------------------------------------
      IMPLICIT LOGICAL(A-Z)
      SAVE
CD ECGN
C   Modification 14/03/90
      INTEGER ECALID,ECALLS,ECALLP,ECALSC,ECALSY,ECALMD,ECALPL,ECALST
      INTEGER ECALCL,ECALRG,ECALSS,ECALRW,ECALXW,ECALEC,ECALXG,ECALNP
      INTEGER ECALPR,ECALAL,ECALC1,ECALC2,ECALM1,ECALM2
      PARAMETER (ECALLS=4,  ECALLP=2,  ECALSC=3, ECALSY=2,ECALMD=12)
      PARAMETER (ECALPL=45, ECALST=3,  ECALCL=84,ECALRG=4,ECALSS=2 )
      PARAMETER (ECALRW=218,ECALXW=228,ECALEC=2, ECALXG=7,ECALNP=8 )
      REAL ECALBL,ECALBO,ECALEI,ECALEW,ECALEL,ECALGP,ECALWS,ECALAP
      REAL ECALDM,ECALTI
      COMMON/ECALCC/ ECALID,ECALPR,ECALBL,ECALBO,ECALEI,ECALEW,ECALEL,
     & ECALGP,ECALWS,ECALAP,ECALAL,ECALDM(ECALLS,ECALLS),ECALTI,
     & ECALC1,ECALC2,ECALM1,ECALM2
CD EALI
      INTEGER NEALI
      PARAMETER (NEALI=ECALMD*ECALSC)
      INTEGER EALIID
      REAL EALIAM,EALITD,EALIMP,EALIPL,EALISE,EALICL,EALIRW,EALILP
      COMMON/EALICC/EALIID(ECALMD,ECALSC),
     &              EALIAM(ECALLS,ECALLS,ECALMD,ECALSC),
     &              EALITD(ECALLS,ECALLS,ECALMD,ECALSC),
     &              EALIMP(ECALLS-1,   4,ECALMD,ECALSC),
     &              EALIPL(ECALLS,ECALLP,ECALMD,ECALSC),
     &              EALISE(ECALLS,ECALMD,ECALSC),
     &              EALICL(ECALLS,ECALLP,ECALMD,ECALSC),
     &              EALIRW(ECALLS,ECALLP,ECALSS,ECALMD,ECALSC),
     &              EALILP(ECALLS,ECALNP,ECALMD,ECALSC)
CD EBPL
C   Modification 14/03/90
      INTEGER NEBPL
      PARAMETER (NEBPL=7)
      INTEGER EBPLID,EBPLVL
      REAL EBPLLF
      COMMON/EBPLCC/EBPLID(NEBPL),EBPLVL(2,NEBPL),EBPLLF(ECALLS,NEBPL)
CD ECMT
      INTEGER NECMT
      PARAMETER (NECMT=161)
      REAL ECMTMP
      INTEGER ECMTID,ECMTCP,ECMTEL
      COMMON/ECMTCC/ECMTID(NECMT),ECMTMP(NECMT),ECMTCP(NECMT),
     &             ECMTEL(NECMT)
CD ECNC
      INTEGER NECNC
      PARAMETER (NECNC=40)
      INTEGER ECNCID,ECNCEC,ECNCEQ,ECNCET
      COMMON/ECNCCC/ECNCID(NECNC),ECNCEC(NECNC),ECNCEQ(NECNC),
     &              ECNCET(NECNC)
CD ECOL
      INTEGER ECOLID,ECOLER
      REAL ECOLPC
      COMMON/ECOLCC/ECOLID(ECALCL),ECOLPC(ECALLP,ECALCL),ECOLER(ECALCL)
CD ECRP
      INTEGER NECRP
      PARAMETER (NECRP=20)
      INTEGER ECRPID,ECRPEC,ECRPET,ECRPP1,ECRPP2,ECRPP3
      COMMON/ECRPCC/ECRPID(NECRP),ECRPEC(NECRP),ECRPET(NECRP),
     &             ECRPP1(NECRP),ECRPP2(NECRP),ECRPP3(NECRP)
CD EECB
      INTEGER EECBID
      REAL EECBDM
      COMMON/EECBCC/EECBID,EECBDM(ECALLS,ECALLS)
CD EFAC
      INTEGER NEFAC
      PARAMETER (NEFAC=60)
      INTEGER EFACID,EFACEA,EFACEC,EFACEF,EFACET
      COMMON/EFACCC/EFACID(NEFAC),EFACEA(NEFAC),EFACEC(NEFAC),
     &              EFACEF(NEFAC),EFACET(NEFAC)
CD ELNF
      INTEGER NELNF
      PARAMETER (NELNF=93)
      INTEGER ELNFID
      CHARACTER*16 ELNFNM
      REAL ELNFLF
      COMMON/ELNFCC/ELNFID(NELNF),ELNFLF(ECALLS,NELNF)
      COMMON/ELNFCH/ELNFNM(NELNF)
CD ELOC
       INTEGER ELOCID,ELOCEM,ELOCES
       REAL ELOCPL,ELOCCL,ELOCRW,ELOCLP,ELOCSE
       COMMON/ELOCCC/ELOCID,ELOCPL(ECALLS,ECALLP),
     & ELOCCL(ECALLS,ECALLP),ELOCRW(ECALLS,ECALLP,ECALSS),
     & ELOCLP(ECALLS,ECALNP),ELOCSE(ECALLS),ELOCEM,ELOCES
CD ELTY
      INTEGER NELTY
      PARAMETER (NELTY=14)
      INTEGER ELTYID,ELTYEA,ELTYEF,ELTYET
      COMMON/ELTYCC/ELTYID(NELTY),ELTYEA(NELTY),ELTYEF(NELTY),
     &              ELTYET(NELTY)
CD EMAT
      INTEGER NEMAT
      PARAMETER (NEMAT=86)
      INTEGER EMATID,EMATMI
      CHARACTER*16 EMATMN
      REAL EMATAW,EMATAN,EMATDE,EMATRL,EMATAL
      COMMON/EMATCC/EMATID(NEMAT),EMATMI(NEMAT),EMATAW(NEMAT),
     &   EMATAN(NEMAT),EMATDE(NEMAT),EMATRL(NEMAT),EMATAL(NEMAT)
      COMMON/EMATCH/EMATMN(NEMAT)
CD EMOD
      INTEGER EMODID
      REAL EMODDM,EMODPC,EMODRW
      COMMON/EMODCC/EMODID(ECALMD),EMODDM(ECALLS,ECALLS,ECALMD),
     &      EMODPC(ECALLP,ECALMD)
CD EPHY
      INTEGER NEPHY,LEPHY
      PARAMETER (NEPHY=38)
      INTEGER EPHYID,EPHYEQ,EPHYES,EPHYVL
      CHARACTER*16 EPHYNM
      REAL EPHYLE,EPHYAN
      COMMON/EPHYCC/LEPHY,EPHYID(NEPHY),EPHYEQ(NEPHY),EPHYES(NEPHY),
     &              EPHYVL(2,NEPHY),EPHYLE(ECALLS-1,NEPHY),
     &              EPHYAN(ECALLS-1,NEPHY)
      COMMON/EPHYCH/EPHYNM(NEPHY)
CD EPLN
      INTEGER EPLNID,EPLNES,EPLNPI,EPLNPS
      COMMON/EPLNCC/EPLNID(ECALPL),EPLNES(ECALPL),EPLNPI(ECALPL),
     & EPLNPS(ECALPL)
CD EPSC
      INTEGER EPSCID,EPSCEP,EPSCES
      REAL EPSCPC
      COMMON/EPSCCC/EPSCID(ECALPL+1,ECALSC),
     &              EPSCPC(ECALLP,ECALPL+1,ECALSC),
     &              EPSCEP(ECALPL+1,ECALSC),EPSCES(ECALPL+1,ECALSC)
CD EPTY
      INTEGER EPTYID,EPTYNB,EPTYEP,EPTYEQ
      REAL EPTYFS
      COMMON/EPTCC/EPTYID(ECALPL,ECALSY),EPTYNB(ECALPL,ECALSY),
     &EPTYFS(ECALPL,ECALSY),EPTYEP(ECALPL,ECALSY),EPTYEQ(ECALPL,ECALSY)
CD EQTY
      INTEGER NEQTY
      PARAMETER (NEQTY=2)
      INTEGER EQTYID,EQTYMN
      CHARACTER*16 EQTYNM
      REAL EQTYTP
      COMMON/EQTYCC/EQTYID(NEQTY),EQTYMN(NEQTY),EQTYTP(ECALLS-1,4,NEQTY)
      COMMON/EQTYCH/EQTYNM(NEQTY)
CD EREG
      INTEGER EREGID,EREGCN,EREGFR,EREGLS
      COMMON/EREGCC/EREGID(ECALRG),EREGCN(ECALRG),EREGFR(ECALRG),
     &             EREGLS(ECALRG)
CD EROW
C   Modification 14/03/90
      INTEGER EROWID,EROWEX
      COMMON/EROWCC/EROWID(ECALRW+1),EROWEX(ECALRW+1)
CD ESCO
C   Modification 14/03/90
      INTEGER ESCOID,ESCOCF,ESCORF,ESCORL,ESCOEC,ESCOEQ,ESCOET
      INTEGER ESCOFR,ESCOLS,ESCOS1,ESCOS2,ESCORR
      CHARACTER*16 ESCONM
      REAL ESCOLI,ESCOMD
      COMMON/ESCOCC/ESCOID(ECALSC),ESCOLI(ECALLS,ECALSC),
     &ESCOMD(ECALLS,ECALLP,ECALSC),ESCOCF(ECALSC),ESCORF(ECALSC),
     &ESCORL(ECALSC),ESCOEC(ECALSC),ESCOEQ(ECALSC),ESCOET(ECALSC),
     &ESCOFR(ECALSC),ESCOLS(ECALSC),ESCOS1(ECALSC),ESCOS2(ECALSC),
     &ESCORR(ECALLP,ECALSC)
      COMMON/ESCOCH/ESCONM(ECALSC)
CD ESEC
      INTEGER ESECID,ESECSR,ESECEQ
      REAL ESECDM
      COMMON/ESECCC/ESECID(ECALSS),ESECSR(ECALSS),ESECEQ(ECALSS),
     &              ESECDM(ECALLS,ECALLS,ECALSS)
CD ESLO
      INTEGER ESLOID,ESLOEA,ESLOEM,ESLOEQ,ESLOES
      REAL ESLOPS,ESLOAG
      CHARACTER*16 ESLONM
      COMMON/ESLOCC/ESLOID(ECALMD,ECALSC),
     &              ESLOPS(ECALLS-1,ECALMD,ECALSC),
     &              ESLOAG(ECALLS-1,ECALMD,ECALSC),
     &              ESLOEA(ECALMD,ECALSC),ESLOEM(ECALMD,ECALSC),
     &              ESLOEQ(ECALMD,ECALSC),ESLOES(ECALMD,ECALSC)
      COMMON/ESLOCH/ESLONM(ECALMD,ECALSC)
CD ESSC
      INTEGER ESSCID,ESSCES,ESSCST
      REAL ESSCPP,ESSCPC,ESSCPS
      COMMON/ESSCCC/ESSCID(ECALST,ECALSC),ESSCPP(ECALLS,ECALST,ECALSC),
     & ESSCPC(ECALLP,ECALST,ECALSC),ESSCPS(ECALLP,ECALST,ECALSC),
     & ESSCES(ECALST,ECALSC),ESSCST(ECALST,ECALSC)
CD ESTK
      INTEGER ESTKID,ESTKFR,ESTKLS
      COMMON/ESTKCC/ESTKID(ECALST),ESTKFR(ECALST),ESTKLS(ECALST)
CD ESTY
      INTEGER ESTYID,ESTYEQ,ESTYES
      REAL ESTYWF,ESTYPF
      COMMON/ESTYCC/ESTYID(ECALST,NEQTY),
     & ESTYWF(ECALLS,ECALST,NEQTY),ESTYPF(ECALLS,ECALST,NEQTY),
     & ESTYEQ(ECALST,NEQTY),ESTYES(ECALST,NEQTY)
CD ETSC
      INTEGER ETSCID,ETSCEB,ETSCEC
      REAL    ETSCDM,ETSCAF
      CHARACTER*16 ETSCNM
      COMMON/ETSCCC/ETSCID(ECALSY),ETSCEB(ECALSY),ETSCEC(ECALSY),
     & ETSCDM(ECALLS,ECALLS,ECALSY),ETSCAF(ECALSY)
      COMMON/ETSCCH/ETSCNM(ECALSY)
CD ETYV
      INTEGER NETYV
      PARAMETER (NETYV=2)
      INTEGER ETYVID,ETYVFC,ETYVCR,ETYVNG,ETYVFT,ETYVFR,ETYVFF,
     &        ETYVLT,ETYVLR,ETYVLF
      COMMON/ETYVCC/ETYVID(NETYV),ETYVFC(NETYV),ETYVCR(NETYV),
     &              ETYVNG(NETYV),ETYVFT(NETYV),ETYVFR(NETYV),
     &ETYVFF(NETYV),ETYVLT(NETYV),ETYVLR(NETYV),ETYVLF(NETYV)
CD EVLF
      INTEGER NEVLF
      PARAMETER (NEVLF=292)
      REAL EVLFSG
      INTEGER EVLFID,EVLFEA,EVLFEL,EVLFEV
      COMMON/EVLFCC/EVLFID(NEVLF),EVLFSG(NEVLF),EVLFEA(NEVLF),
     &             EVLFEL(NEVLF),EVLFEV(NEVLF)
CD EVLS
      INTEGER EVLSID,EVLSVL,EVLSZN
      CHARACTER*16 EVLSNM
      COMMON/EVLSCC/EVLSID(ECALNP,ECALSC),
     &             EVLSVL(ECALNP,ECALSC),EVLSZN(ECALNP,ECALSC)
      COMMON/EVLSCH/EVLSNM(ECALNP,ECALSC)
CD EVOL
      INTEGER NEVOL
      PARAMETER (NEVOL=43)
      INTEGER EVOLID,EVOLEM,EVOLEQ,EVOLET,EVOLFR,EVOLLS
      CHARACTER*16 EVOLNM
      COMMON/EVOLCC/EVOLID(NEVOL),EVOLEM(NEVOL),EVOLEQ(NEVOL),
     &              EVOLET(NEVOL),EVOLFR(NEVOL),EVOLLS(NEVOL)
      COMMON/EVOLCH/EVOLNM(NEVOL)
CD EXRG
C   Modification 14/03/90
      INTEGER EXRGID,EXRGER,EXRGFR,EXRGLS
      REAL    EXRGPC
      COMMON/EXRGCC/EXRGID(ECALXG+1),EXRGPC(ECALLP,ECALXG+1),
     & EXRGER(ECALXG+1),EXRGFR(ECALXG+1),EXRGLS(ECALXG+1)
CD EXRO
C   Modification 14/03/90
      INTEGER EXROID,EXROER,EXROES
      REAL EXROPC
      COMMON/EXROCC/EXROID(ECALXW),EXROER(ECALXW),EXROES(ECALXW),
     & EXROPC(ECALLP,ECALXW+3)
C
C   Input variables
      REAL X(ECALLS-1)
      CHARACTER*(*) SYSTM
C   Output variables
      INTEGER SC,MD,CL,RW,ST,PL,WRONG
C   Called functions
      INTEGER EPLSCC,EPLSCN, EPLSQL
C   Locales
      INTEGER RG,SS,BARIL,I,LRW
      REAL LOC1,LOC2,TEST
      PARAMETER (BARIL=2)
C---------------------------------
      WRONG=0
C----------------------------------
C    search for the subcomponent
C  --    SC = EFNDSC( X)  --
      SC=ECALSC
      DO 1 I=1,ECALSC-1
        IF(ESCOLI(1,I)*X(1)+ESCOLI(2,I)*X(2)+
     &     ESCOLI(3,I)*X(3)+ESCOLI(4,I)    .LT.0.) SC=I
 1    CONTINUE
C  error diagnostic
      IF(SC.EQ.0) THEN
                  WRONG=1
                  GO TO 999
                  END IF
C----------------------------------
C   search for the module
C  --    MD = EFNDMD( SC,X)   --
       MD=EPLSCC(ESCOMD(1,1,SC),ECALMD,EMODPC(1,1),X)
C  error diagnostic
      IF(MD.EQ.0.OR.MD.GT.ECALMD) THEN
                  WRONG=2
                  GO TO 999
                  END IF
C----------------------------------
                         IF(SC.EQ.BARIL) THEN
                               RG=ECALRG
                               SS=1
                                         ELSE
C  --------------------------------
C    search for the sector
C  --    SS=EFNDSS(SC,MD,X,SYSTM)  --
      IF(X(1)*EALISE(1,MD,SC)+X(2)*EALISE(2,MD,SC)+
     &   X(3)*EALISE(3,MD,SC)+     EALISE(4,MD,SC).LE.0)
     &THEN
          SS=1
      ELSE
          SS=2
      END IF
C ------------------------------------
C   search for the region
C  --    RG=EFNDRG(SC,MD,X,SYSTM)  --
         RG=EPLSCN(EALIRW(1,1,SS,MD,SC),ECALXG+1,EXRGPC(1,1),X)
         IF(RG.GT.0.AND.RG.LT.ECALXG+1) THEN
                        RG=EXRGER(RG)
                            ELSE
C  error diagnostic
                        WRONG=3
                        RG=1
                            END IF
                                         END IF
C
C---------------------------------
C   search for the column
C  --    CL=EFNDCL(SC,MD,X,SYSTM)  --
C  finds the column in the region
       CL=EPLSQL(EALICL(1,1,MD,SC),EREGCN(RG)+1,ECOLPC(1,EREGFR(RG)),X)
C  error diagnostic
      IF( CL.GE.EREGCN(RG)+1 .OR. CL.LE.0 ) THEN
                   WRONG = 4
                   END IF
C
C  Takes into account the offset in the numbering of the columns
C  between the end caps and the barrel
      CL=CL+NINT((MD-1+.5*ESCOCF(SC))*EREGCN(RG))
      IF(CL.LE.0)   CL=CL+ECALMD*EREGCN(RG)
      IF(CL.GT.ECALMD*EREGCN(RG)) CL=CL-ECALMD*EREGCN(RG)
C---------------------------------
C  recherche du plan
C --     PL=EFNDPL(SC,MD,X,SYSTM)  --
       PL=EPLSQL(EALIPL(1,1,MD,SC),ECALPL+1,EPSCPC(1,1,SC),X)
         IF(PL.EQ.0.OR.PL.GE.ECALPL+1) THEN
                     WRONG=5
                     END IF
C
C--------------------------------
C   search for the row
C --     RW=EFNDLG(SC,MD,X,SYSTM)  --
        LRW=ESCOLS(SC)-ESCOFR(SC)+1
      RW=EPLSQL(EALIRW(1,1,SS,MD,SC),LRW,EXROPC(1,ESCOFR(SC)),X)
C    point hors limites
      IF(RW.GE.LRW.OR.RW.LE.0) THEN
                   WRONG = 6
      RW=RW+ESCORF(SC)
                                ELSE
C      introduction de l'offset de sous-composante.
      RW=RW+ESCORF(SC)
C   traitement des zones pathologiques du baril.
                  IF(SC.EQ.BARIL.AND.PL.NE.0)   THEN
      IF(RW.LE.EPLNPI(ECALPL).OR.RW.GE.EPLNPS(ECALPL)) THEN
         IF(RW.GE.EPLNPS(ECALPL)) RW=MIN(RW,EPLNPS(PL))
         IF(RW.LE.EPLNPI(ECALPL)) RW=MAX(RW,EPLNPI(PL))
                                                       END IF
                                               END IF
                                END IF
C
C--------------------------------
C   Search for the stack
C  --    ST=EFNDST(SC,MD,X,SYSTM)  --
      IF(PL.EQ.0) THEN
                  ST = 0
                 WRONG=7
              ELSE IF(PL.EQ.ECALPL+1) THEN
                  ST=ECALST+1
                   WRONG = 7
                  ELSE
              ST=EPLNES(PL)
       LOC1= EALIPL(1,1,MD,SC)*X(1)+EALIPL(2,1,MD,SC)*X(2)+
     &       EALIPL(3,1,MD,SC)*X(3)+EALIPL(4,1,MD,SC)
       LOC2= EALIPL(1,2,MD,SC)*X(1)+EALIPL(2,2,MD,SC)*X(2)+
     &       EALIPL(3,2,MD,SC)*X(3)+EALIPL(4,2,MD,SC)
       TEST= -ESSCPS(1,ST,SC) * LOC2 + ESSCPS(2,ST,SC) * LOC1
                  END IF
C--------------------------------
 999   CONTINUE
      END
