      INTEGER FUNCTION EQEDGE(XINE,DISTAN,PHIEDG)
C -------------------------------------------------------------------
CKEY ECALDES CLUSTER CRACK OVERLAP / USER
C     S.Loucatos     creation February 89
C                                  H. Videau modification 14 mars 90
C! Check position  of one point wrt cracks, overlap, fwd hole
C  Can be used to check energy measurement of a cluster given by
C  its barycentre coordinates.
C   Input  :
C            XINE(3) Point.
C   Output: Quality flag for Energy meas/t:
C            EQEDGE:      0     =  OK
C                     bit 0 set = point in the phi crack
C                     bit 1 set =   "    "  "  Overlap BL-EC
C                     bit 2 set =   "    "  "  EC edge towards beam hole
C                     bit 3 set =   "  outside EMCAL theta,phi range
C
C            DISTAN: distance to the closest lateral edge   REAL
C            PHIEDG: -1 if closest is phi inf               REAL
C                     1 if closest is phi sup.
C  This can be combined with the sign of the track and the sign of the
C  field to know if the track is entering the module or getting out.
C   Calls: EINTST,EFNDTW,EVOLPL
C   Called by USER
C   ---------------------------------------------------------
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
C  Input
         REAL XINE(3)
C  Output
         REAL DISTAN,PHIEDG
C  External
         LOGICAL EINTST
C  Locales
         INTEGER IBQUAL,CL,RW,ST,SC,MD,PL,BARIL,LEPLAN,IPL
         REAL PLANES(4,8),DISTINF,DISTSUP,DIST
         CHARACTER*12 WRONG,VOLNAM
         INTEGER PHIINF(ECALST,ECALSC),PHISUP(ECALST,ECALSC),LEDGE
         REAL LOWCUT,HIGCUT
C  Initialisations
         DATA BARIL/2/,LEDGE/1/
        DATA PHIINF/3,3,3,3,3,7,4,4,4/
        DATA PHISUP/4,4,4,4,4,8,3,3,3/
C To be taken from cards or from the data base !!!!!!!!!!!!!!!!!
         DATA LOWCUT,HIGCUT/1.5,4.5/
C  Execution
C     Good energy measurement
         IBQUAL = 0
          DISTAN=100000.
      CALL EFNDTW(XINE,'ALEPH',CL,RW,ST,SC,MD,PL,WRONG)
C
C  Out of theta,phi,stack range
         IF(.NOT.EINTST(RW,CL,ST))THEN
                   IBQUAL= IBQUAL+8
                   GO TO 777
                                  ENDIF
C
C  Check of the distance to the edges of the sensitive region
         IF(SC.EQ.BARIL) THEN
               VOLNAM='B sensitive'
                         ELSE
               VOLNAM='E sensitive'
                         END IF
         CALL EVOLPL(VOLNAM,SC,MD,LEPLAN,PLANES)
C
C     Lower EC edge
         IF(SC.NE.BARIL) THEN
         DISTAN=PLANES(1,LEDGE)*XINE(1)+PLANES(2,LEDGE)*XINE(2)+
     &          PLANES(3,LEDGE)*XINE(3)+PLANES(4,LEDGE)
         IF(DISTAN.LT.HIGCUT)IBQUAL=IBQUAL+4
                         END IF
C
C     Cracks in phi
         IPL=PHIINF(ST,SC)
         DISTINF=PLANES(1,IPL)*XINE(1)+PLANES(2,IPL)*XINE(2)+
     &           PLANES(3,IPL)*XINE(3)+PLANES(4,IPL)
         IPL=PHISUP(ST,SC)
         DISTSUP=PLANES(1,IPL)*XINE(1)+PLANES(2,IPL)*XINE(2)+
     &           PLANES(3,IPL)*XINE(3)+PLANES(4,IPL)
         IF(ABS(DISTSUP).LT.ABS(DISTINF))THEN
                       DIST=DISTSUP
                       PHIEDG=1.
                                         ELSE
                       DIST=DISTINF
                       PHIEDG=-1.
                                         END IF
         IF(DIST.LT.HIGCUT)IBQUAL=IBQUAL+1
C
C     Overlap EC-Barrel
      IF (RW.GE.ESCOFR(BARIL)-1-ESCORL(BARIL).AND.
     &    RW.LT.ESCOFR(BARIL)-1+ESCORL(BARIL).OR.
     &    RW.GE.ESCOLS(BARIL)-2-ESCORL(BARIL).AND.
     &    RW.LT.ESCOLS(BARIL)-2+ESCORL(BARIL)) THEN
                                IBQUAL=IBQUAL+2
                                        ENDIF
         IF(ABS(DIST).LT.ABS(DISTAN))DISTAN=DIST
 777     CONTINUE
         EQEDGE = IBQUAL
         END
