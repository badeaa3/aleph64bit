      SUBROUTINE EVOLCR(VOLNAM,LEPLAN,PLANES,LEPOIN,CORNER)
C.----------------------------------------------------------------------
CKEY ECALDES VOLUME CORNER PLANE / USER
C     H.Videau      creation 28/04/87   modification 8/04/87
C! Computes volume corners from the planes.
C  Computes the corners of a volume named VOLNAM for which the limiting
C  planes are given in PLANES. There are LEPLAN planes and LEPOIN corne
C  It computes the corners as intersection of the three planes related
C  to that corner by the relationships ECRP to EFTY named
C  ECRPP1, ECRPP2, ECRPP3.
C   Input :
C           VOLNAM   Name of the volume             character*16
C           LEPLAN   Number of planes               integer
C           PLANES   4 coefficients of the planes   real
C   Output:
C           LEPOIN  Number of corners computed
C           CORNER  3 coordinates of corners in SYSTEM ref. system
C   Calls: VECT4
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
C    Variables d'input
        CHARACTER*16 VOLNAM
        INTEGER LEPLAN
        REAL PLANES(ECALLS,*)
C     Variables d'output
        INTEGER LEPOIN
        REAL CORNER(ECALLS-1,*)
C     Locales
        INTEGER I,J,IDEVOL,ECECRP
        REAL CORPRO(ECALLS,20),FNOR
C
      LEPOIN=0
C  Get the volume from VOLNAM
      DO 1 I=1,NEVOL
        IF(VOLNAM.EQ.EVOLNM(I)) GO TO 3
 1    CONTINUE
C  Erreur
      GO TO 999
 3    CONTINUE
      IDEVOL=EVOLID(I)
C
C    Loop over the corners by type
      DO 4 I=1,NECRP
      IF(ECRPET(I).NE.EVOLET(IDEVOL)) GO TO 4
        LEPOIN=LEPOIN+1
        ECECRP=ECRPEC(I)
        CALL VECT4(CORPRO(1,ECECRP),PLANES(1,ECRPP1(I)),
     &             PLANES(1,ECRPP2(I)),PLANES(1,ECRPP3(I)))
C    test sur corpro(4) et le cas echeant division pour normer le point
        IF(CORPRO(4,ECECRP).NE.0.) THEN
                FNOR=1./CORPRO(4,ECECRP)
                DO 2 J=1,ECALLS-1
                CORNER(J,ECECRP)=FNOR*CORPRO(J,ECECRP)
 2              CONTINUE
        END IF
 4      CONTINUE
C
C   Close
 999    CONTINUE
        END
