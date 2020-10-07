      SUBROUTINE ERDDAF(LUNDAF,IRUN,IGOOD)
C.---------------------------------------------------------------------
CKEY ECALDES READ DAF BANKS / USER
C     M.Rumpf        June  88      Modification H Videau 14/03/90
C! ECALDES interface with DAF
C  Fill ECALDES commons from direct access file.
C   Input :
C          LUNDAF Logical Unit for DAF
C          IRUN   Run number
C   Output:
C          IGOOD (0 = error,  1 = OK)
C   Called by USER program before ECDFRD
C   Calls: ALGTDB                    from ALEPHLIB
C.---------------------------------------------------------------------
      SAVE
C! define universal constants
      REAL PI, TWOPI, PIBY2, PIBY3, PIBY4, PIBY6, PIBY8, PIBY12
      REAL RADEG, DEGRA
      REAL CLGHT, ALDEDX
      PARAMETER (PI=3.141592653589)
      PARAMETER (RADEG=180./PI, DEGRA=PI/180.)
      PARAMETER (TWOPI = 2.*PI , PIBY2 = PI/2., PIBY4 = PI/4.)
      PARAMETER (PIBY6 = PI/6. , PIBY8 = PI/8.)
      PARAMETER (PIBY12= PI/12., PIBY3 = PI/3.)
      PARAMETER (CLGHT = 29.9792458, ALDEDX = 0.000307)
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON /BCS/   IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
C! global ECAL data base HAC parameters
      PARAMETER(JEALID=1,JEALAM=2,JEALTD=18,JEALMP=34,JEALPL=46,
     +          JEALSE=54,JEALCL=58,JEALRW=66,JEALLP=82,LEALIA=113)
      PARAMETER(JEBPID=1,JEBPVR=2,JEBPLF=4,LEBPLA=7)
      PARAMETER(JECGID=1,JECGLS=2,JECGLP=3,JECGSC=4,JECGSY=5,JECGMD=6,
     +          JECGPL=7,JECGST=8,JECGCL=9,JECGRG=10,JECGSS=11,
     +          JECGRW=12,JECGXW=13,JECGEC=14,JECGXG=15,JECGNP=16,
     +          JECGPR=17,JECGBL=18,JECGBO=19,JECGEI=20,JECGEW=21,
     +          JECGEL=22,JECGGP=23,JECGWS=24,JECGAP=25,JECGAL=26,
     +          JECGDM=27,JECGTI=43,JECGC1=44,JECGC2=45,JECGM1=46,
     +          JECGM2=47,JECGR1=48,JECGR2=49,LECGNA=49)
      PARAMETER(JECMID=1,JECMMP=2,JECMCP=3,JECMEL=4,LECMTA=4)
      PARAMETER(JECNID=1,JECNEC=2,JECNEQ=3,JECNET=4,LECNCA=4)
      PARAMETER(JECOID=1,JECOPC=2,JECOER=4,LECOLA=4)
      PARAMETER(JECRID=1,JECREC=2,JECRET=3,JECRP1=4,JECRP2=5,JECRP3=6,
     +          LECRPA=6)
      PARAMETER(JEECID=1,JEECDM=2,LEECBA=17)
      PARAMETER(JEFAID=1,JEFAEA=2,JEFAEC=3,JEFAEF=4,JEFAET=5,LEFACA=5)
      PARAMETER(JELNID=1,JELNNM=2,JELNLF=6,LELNFA=9)
      PARAMETER(JELTID=1,JELTEA=2,JELTEF=3,JELTET=4,LELTYA=4)
      PARAMETER(JEMAID=1,JEMAMI=2,JEMAMN=3,JEMAAW=7,JEMAAN=8,JEMADE=9,
     +          JEMARL=10,JEMAAL=11,LEMATA=11)
      PARAMETER(JEMOID=1,JEMODM=2,JEMOPC=18,LEMODA=19)
      PARAMETER(JEPHID=1,JEPHVR=2,JEPHNM=4,JEPHEQ=8,JEPHES=9,JEPHLE=10,
     +          JEPHAN=13,LEPHYA=15)
      PARAMETER(JEPLID=1,JEPLES=2,JEPLPI=3,JEPLPS=4,LEPLNA=4)
      PARAMETER(JEPSID=1,JEPSPC=2,JEPSEP=4,JEPSES=5,LEPSCA=5)
      PARAMETER(JEPTID=1,JEPTNB=2,JEPTFS=3,JEPTEP=4,JEPTEQ=5,LEPTYA=5)
      PARAMETER(JEQTID=1,JEQTNM=2,JEQTMN=6,JEQTTP=7,LEQTYA=18)
      PARAMETER(JEREID=1,JERECN=2,JEREFR=3,JERELS=4,LEREGA=4)
      PARAMETER(JEROID=1,JEROPC=2,JEROEX=4,LEROWA=4)
      PARAMETER(JESCID=1,JESCNM=2,JESCLI=6,JESCMD=10,JESCCF=18,
     +          JESCRF=19,JESCRL=20,JESCEC=21,JESCEQ=22,JESCET=23,
     +          JESCFR=24,JESCLS=25,JESCS1=26,JESCS2=27,LESCOA=27)
      PARAMETER(JESEID=1,JESESR=2,JESEEQ=3,JESEDM=4,LESECA=19)
      PARAMETER(JESLID=1,JESLNM=2,JESLEA=6,JESLEM=7,JESLEQ=8,JESLES=9,
     +          LESLOA=9)
      PARAMETER(JESSID=1,JESSPP=2,JESSPC=6,JESSPS=8,JESSES=10,JESSST=11,
     +          LESSCA=11)
      PARAMETER(JESTID=1,JESTWF=2,JESTPF=6,JESTEQ=10,JESTES=11,
     +          LESTYA=11)
      PARAMETER(JETSID=1,JETSNM=2,JETSEB=6,JETSEC=7,JETSDM=8,JETSAF=24,
     +          LETSCA=24)
      PARAMETER(JETYID=1,JETYFC=2,JETYCR=3,JETYNG=4,JETYFT=5,JETYFR=6,
     +          JETYFF=7,JETYLT=8,JETYLR=9,JETYLF=10,LETYVA=10)
      PARAMETER(JEVOID=1,JEVONM=2,JEVOEM=6,JEVOEQ=7,JEVOET=8,JEVOFR=9,
     +          JEVOLS=10,LEVOLA=10)
      PARAMETER(JEXRID=1,JEXRPC=2,JEXRER=4,JEXRFR=5,JEXRLS=6,LEXRGA=6)
CD EVLFJJ
      PARAMETER(JEVLFI=1,JEVLSG=2,JEVLEA=3,JEVLEL=4,JEVLEV=5)
CD EVLSJJ
      PARAMETER(JEVLSI=1,JEVLNM=2,JEVLVL=6,JEVLZN=7)
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
C- First fill ECAL Bos banks from direct access file
C
      CHARACTER ECBANK * 112
      CHARACTER * 4 CHA4(4),CHAINT
      INTEGER LUNDAF,IRUN,IGOOD
      INTEGER ALGTDB,NAMIND
      INTEGER INDEC
      INTEGER JEBPL,JECGN,JECMT,JECNC,JECOL,JECRP,JEECB
      INTEGER JEFAC,JELNF,JELTY,JEMAT,JEPHY,JEPLN
      INTEGER JEPSC,JEPTY,JEQTY,JEROW,JESCO,JESEC
      INTEGER JESLO,JESSC,JESTY,JETSC,JEVLF
      INTEGER JEVLS,JEVOL,JEXRG,JEXRO
C
      EXTERNAL ALGTDB
C
      INTEGER I,J,NC,NR,NRCUR
C
C- List of ECbanks names from data base
      DATA ECBANK/
     & 'EBPLECGNECMTECNCECOLECRPEECBEFACELNFELTYEMATEPHYEPLNEPSCEPTYEQTY
     &EROWESCOESECESLOESSCESTYETSCEVLFEVLSEVOLEXRGEXRO'/
C
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
C
C- Read Banks for ECAL from d/a file into memory
C
      IGOOD = 1
C
         INDEC = ALGTDB(LUNDAF,ECBANK,IRUN)
         IF(INDEC .EQ. 0) GO TO 998
C
C Now fill ECAL commons from banks
C
C  ... Bank EBPL
C
      JEBPL = IW(NAMIND('EBPL'))
      NC = LCOLS(JEBPL)
      NR = LROWS(JEBPL)
      IF (NR.GT.NEBPL)                GO TO 998
      DO 10 I = 1,NR
         EBPLID(I) = ITABL(JEBPL,I,JEBPID)
         EBPLVL(1,I) = ITABL(JEBPL,I,JEBPVR)
         EBPLVL(2,I) = ITABL(JEBPL,I,JEBPVR+1)
         DO 11 J = 1,ECALLS
           EBPLLF(J,I) = RTABL(JEBPL,I,JEBPLF+J-1)
   11    CONTINUE
   10 CONTINUE
      EBPLLF(1,6)=0.
      EBPLLF(2,6)=0.
      EBPLLF(3,6)=1.
      EBPLLF(4,6)=-6.4
      EBPLLF(1,7)=0.
      EBPLLF(2,7)=0.
      EBPLLF(3,7)=1.
      EBPLLF(4,7)=+6.4
C
C
C  ... Bank ECGN (ex ECAL)
C
      JECGN = IW(NAMIND('ECGN'))
      NR = LROWS(JECGN)
      IF(NR.NE.1)                  GO TO 998
C
      ECALID =    ITABL(JECGN,1,JECGID)
C Following variables defined by PARAMETER statements
C     ECALLS =    ITABL(JECGN,1,JECGLS)
C     ECALLP =    ITABL(JECGN,1,JECGLP)
C     ECALSC =    ITABL(JECGN,1,JECGSC)
C     ECALSY =    ITABL(JECGN,1,JECGSY)
C     ECALMD =    ITABL(JECGN,1,JECGMD)
C     ECALPL =    ITABL(JECGN,1,JECGPL)
C     ECALST =    ITABL(JECGN,1,JECGST)
C     ECALCL =    ITABL(JECGN,1,JECGCL)
C     ECALRG =    ITABL(JECGN,1,JECGRG)
C     ECALSS =    ITABL(JECGN,1,JECGSS)
C     ECALRW =    ITABL(JECGN,1,JECGRW)
C     ECALXW =    ITABL(JECGN,1,JECGXW)
C     ECALEC =    ITABL(JECGN,1,JECGEC)
C     ECALXG =    ITABL(JECGN,1,JECGXG)
C     ECALNP =    ITABL(JECGN,1,JECGNP)
C
      ECALPR =    ITABL(JECGN,1,JECGPR)
      DO 20 I = 1,ECALLS
        DO 21 J = 1,ECALLS
          ECALDM(J,I) = RTABL(JECGN,1,JECGPR+J+ ECALLS * (I-1))
   21   CONTINUE
   20 CONTINUE
C
      ECALBL =    RTABL(JECGN,1,JECGBL)
      ECALBO =    RTABL(JECGN,1,JECGBO)
      ECALEI =    RTABL(JECGN,1,JECGEI)
      ECALEW =    RTABL(JECGN,1,JECGEW)
      ECALEL =    RTABL(JECGN,1,JECGEL)
      ECALGP =    RTABL(JECGN,1,JECGGP)
      ECALWS =    RTABL(JECGN,1,JECGWS)
      ECALAP =    RTABL(JECGN,1,JECGAP)
      ECALAL =    ITABL(JECGN,1,JECGAL)
C
      ECALTI =    RTABL(JECGN,1,JECGTI)
      ECALC1 =    ITABL(JECGN,1,JECGC1)
      ECALC2 =    ITABL(JECGN,1,JECGC2)
      ECALM1 =    ITABL(JECGN,1,JECGM1)
      ECALM2 =    ITABL(JECGN,1,JECGM2)
C
C  ... Bank ECMT
C
      JECMT = IW(NAMIND('ECMT'))
      NC = LCOLS(JECMT)
      NR = LROWS(JECMT)
      IF(NR.NE.NECMT)                 GO TO 998
      DO 30 I = 1,NR
         ECMTID(I) = ITABL(JECMT,I,JECMID)
         ECMTMP(I) = RTABL(JECMT,I,JECMMP)
         ECMTCP(I) = ITABL(JECMT,I,JECMCP)
         ECMTEL(I) = ITABL(JECMT,I,JECMEL)
   30 CONTINUE
C
C  ... Bank ECNC
C
      JECNC = IW(NAMIND('ECNC'))
      NC = LCOLS(JECNC)
      NR = LROWS(JECNC)
      IF(NR.NE.NECNC)                 GO TO 998
      DO 40 I = 1,NR
         ECNCID(I) = ITABL(JECNC,I,JECNID)
         ECNCEC(I) = ITABL(JECNC,I,JECNEC)
         ECNCEQ(I) = ITABL(JECNC,I,JECNEQ)
         ECNCET(I) = ITABL(JECNC,I,JECNET)
   40 CONTINUE
C
C  ... Bank ECOL
C
      JECOL = IW(NAMIND('ECOL'))
      NC = LCOLS(JECOL)
      NR = LROWS(JECOL)
      IF(NR.NE.ECALCL)                GO TO 998
      DO 50 I = 1,NR
         ECOLID(I) = ITABL(JECOL,I,JECOID)
         ECOLPC(1,I) = RTABL(JECOL,I,JECOPC)
         ECOLPC(2,I) = RTABL(JECOL,I,JECOPC+1)
         ECOLER(I) = ITABL(JECOL,I,JECOER)
   50 CONTINUE
C
C  ... Bank ECRP
C
      JECRP = IW(NAMIND('ECRP'))
      NC = LCOLS(JECRP)
      NR = LROWS(JECRP)
      IF(NR.NE.NECRP)                 GO TO 998
      DO 60 I = 1,NR
         ECRPID(I) = ITABL(JECRP,I,JECRID)
         ECRPEC(I) = ITABL(JECRP,I,JECREC)
         ECRPET(I) = ITABL(JECRP,I,JECRET)
         ECRPP1(I) = ITABL(JECRP,I,JECRP1)
         ECRPP2(I) = ITABL(JECRP,I,JECRP2)
         ECRPP3(I) = ITABL(JECRP,I,JECRP3)
   60 CONTINUE
C
C  ... Bank EECB
C
      JEECB = IW(NAMIND('EECB'))
      NC = LCOLS(JEECB)
      NR = LROWS(JEECB)
      IF(NR.NE.1)                   GO TO 998
      IF(NC.NE.1+ECALLS*ECALLS)     GO TO 998
      EECBID = ITABL(JEECB,1,JEECID)
      DO 70 I = 1,ECALLS
        DO 71 J = 1,ECALLS
         EECBDM(J,I) =RTABL(JEECB,1,JEECDM-1+J + ECALLS*(I-1))
   71   CONTINUE
   70 CONTINUE
C
C  ... Bank EFAC
C
      JEFAC = IW(NAMIND('EFAC'))
      NC = LCOLS(JEFAC)
      NR = LROWS(JEFAC)
      IF(NR.NE.NEFAC)                 GO TO 998
      DO 80 I = 1,NR
         EFACID(I) = ITABL(JEFAC,I,JEFAID)
         EFACEA(I) = ITABL(JEFAC,I,JEFAEA)
         EFACEC(I) = ITABL(JEFAC,I,JEFAEC)
         EFACEF(I) = ITABL(JEFAC,I,JEFAEF)
         EFACET(I) = ITABL(JEFAC,I,JEFAET)
   80 CONTINUE
C
C  ... Bank ELNF
C
      JELNF = IW(NAMIND('ELNF'))
      NC = LCOLS(JELNF)
      NR = LROWS(JELNF)
      IF (NR.NE.NELNF)                GO TO 998
      DO 90 I = 1,NR
         ELNFID(I) = ITABL(JELNF,I,JELNID)
         DO 91 J=1,ECALLS
           ELNFLF(J,I) = RTABL(JELNF,I,JELNLF-1+J)
   91    CONTINUE
         DO 92 K = 1,4
           CHA4(K) = CHAINT(ITABL(JELNF,I,JELNNM-1+K))
   92    CONTINUE
      ELNFNM(I) = CHA4(1)//CHA4(2)//CHA4(3)//CHA4(4)
   90 CONTINUE
C
C  ... Bank ELTY
C
      JELTY = IW(NAMIND('ELTY'))
      NC = LCOLS(JELTY)
      NR = LROWS(JELTY)
      IF(NR.NE.NELTY)                 GO TO 998
      DO 100 I = 1,NR
         ELTYID(I) = ITABL(JELTY,I,JELTID)
         ELTYEA(I) = ITABL(JELTY,I,JELTEA)
         ELTYEF(I) = ITABL(JELTY,I,JELTEF)
         ELTYET(I) = ITABL(JELTY,I,JELTET)
  100 CONTINUE
C
C  ... Bank EMAT
C
      JEMAT = IW(NAMIND('EMAT'))
      NC = LCOLS(JEMAT)
      NR = LROWS(JEMAT)
      IF(NR.NE.NEMAT)                 GO TO 998
      DO 110 I = 1,NR
         EMATID(I) = ITABL(JEMAT,I,JEMAID)
         EMATMI(I) = ITABL(JEMAT,I,JEMAMI)
         EMATAW(I) = RTABL(JEMAT,I,JEMAAW)
         EMATAN(I) = RTABL(JEMAT,I,JEMAAN)
         EMATDE(I) = RTABL(JEMAT,I,JEMADE)
         EMATRL(I) = RTABL(JEMAT,I,JEMARL)
         EMATAL(I) = RTABL(JEMAT,I,JEMAAL)
         DO 109 K = 1,4
           CHA4(K) = CHAINT(ITABL(JEMAT,I,JEMAMN-1+K))
  109    CONTINUE
      EMATMN(I) = CHA4(1)//CHA4(2)//CHA4(3)//CHA4(4)
  110 CONTINUE
C
C  ... Bank EPHY
C
      JEPHY = IW(NAMIND('EPHY'))
      NC = LCOLS(JEPHY)
      NR = LROWS(JEPHY)
      IF(NR.GT.NEPHY)                 GO TO 998
      LEPHY=NR
      DO 120 I = 1,NR
         EPHYID(I) = ITABL(JEPHY,I,JEPHID)
         EPHYEQ(I) = ITABL(JEPHY,I,JEPHEQ)
         EPHYES(I) = ITABL(JEPHY,I,JEPHES)
         EPHYVL(1,I) = ITABL(JEPHY,I,JEPHVR)
         EPHYVL(2,I) = ITABL(JEPHY,I,JEPHVR+1)
         DO 121 J=1,ECALLS-1
           EPHYLE(J,I) = RTABL(JEPHY,I,JEPHLE-1+J)
           EPHYAN(J,I) = RTABL(JEPHY,I,JEPHAN-1+J)
  121    CONTINUE
         DO 123 K = 1,4
           CHA4(K) = CHAINT(ITABL(JEPHY,I,JEPHNM-1+K))
  123    CONTINUE
      EPHYNM(I) = CHA4(1)//CHA4(2)//CHA4(3)//CHA4(4)
  120 CONTINUE
C
C  ... Bank EPLN
C
      JEPLN = IW(NAMIND('EPLN'))
      NC = LCOLS(JEPLN)
      NR = LROWS(JEPLN)
      IF(NR.NE.ECALPL)                GO TO 998
      DO 130 I = 1,NR
         EPLNID(I) = ITABL(JEPLN,I,JEPLID)
         EPLNES(I) = ITABL(JEPLN,I,JEPLES)
         EPLNPI(I) = ITABL(JEPLN,I,JEPLPI)
         EPLNPS(I) = ITABL(JEPLN,I,JEPLPS)
  130 CONTINUE
C
C  ... Bank EPSC
C
      JEPSC = IW(NAMIND('EPSC'))
      NC = LCOLS(JEPSC)
      NR = LROWS(JEPSC)
      IF(NR.NE.(ECALPL+1)*ECALSC)     GO TO 998
      DO 140 I = 1,ECALSC
         DO 141 J=1,ECALPL+1
           NRCUR = (ECALPL+1)*(I-1) + J
           EPSCID(J,I) = ITABL(JEPSC,NRCUR,JEPSID)
           EPSCPC(1,J,I) = RTABL(JEPSC,NRCUR,JEPSPC)
           EPSCPC(2,J,I) = RTABL(JEPSC,NRCUR,JEPSPC+1)
           EPSCEP(J,I) = ITABL(JEPSC,NRCUR,JEPSEP)
           EPSCES(J,I) = ITABL(JEPSC,NRCUR,JEPSES)
  141    CONTINUE
  140 CONTINUE
C
C  ... Bank EPTY
C
      JEPTY = IW(NAMIND('EPTY'))
      NC = LCOLS(JEPTY)
      NR = LROWS(JEPTY)
      IF(NR.NE.ECALPL*ECALSY)         GO TO 998
      DO 150 I = 1,ECALSY
         DO 151 J=1,ECALPL
           NRCUR = ECALPL*(I-1) + J
           EPTYID(J,I) = ITABL(JEPTY,NRCUR,JEPTID)
           EPTYNB(J,I) = ITABL(JEPTY,NRCUR,JEPTNB)
           EPTYFS(J,I) = RTABL(JEPTY,NRCUR,JEPTFS)
           EPTYEP(J,I) = ITABL(JEPTY,NRCUR,JEPTEP)
           EPTYEQ(J,I) = ITABL(JEPTY,NRCUR,JEPTEQ)
  151    CONTINUE
  150 CONTINUE
C
C  ... Bank EQTY
C
      JEQTY = IW(NAMIND('EQTY'))
      NC = LCOLS(JEQTY)
      NR = LROWS(JEQTY)
      IF(NR.NE.NEQTY)                 GO TO 998
      DO 160 I = 1,NR
         EQTYID(I) = ITABL(JEQTY,I,JEQTID)
         EQTYMN(I) = ITABL(JEQTY,I,JEQTMN)
        DO 161 K = 1,4
         DO 162 J=1,ECALLS-1
           EQTYTP(J,K,I) = RTABL(JEQTY,I,JEQTTP-1+J+
     &                       (ECALLS-1)*(K-1))
  162    CONTINUE
  161   CONTINUE
        DO 163 K = 1,4
          CHA4(K) = CHAINT(ITABL(JEQTY,I,JEQTNM-1+K))
  163   CONTINUE
        EQTYNM(I) = CHA4(1)//CHA4(2)//CHA4(3)//CHA4(4)
  160 CONTINUE
C
C  ... Bank EROW
C
      JEROW = IW(NAMIND('EROW'))
      NC = LCOLS(JEROW)
      NR = LROWS(JEROW)
      IF(NR.NE.ECALRW+1)              GO TO 998
      DO 170 I = 1,NR
         EROWID(I) = ITABL(JEROW,I,JEROID)
         EROWEX(I) = ITABL(JEROW,I,JEROEX)
  170 CONTINUE
C
C  ... Bank ESCO
C
      JESCO = IW(NAMIND('ESCO'))
      NC = LCOLS(JESCO)
      NR = LROWS(JESCO)
      IF(NR.NE.ECALSC)                GO TO 998
      DO 180 I = 1,NR
         ESCOID(I) = ITABL(JESCO,I,JESCID)
         DO 181 J=1,ECALLS
           ESCOLI(J,I) = RTABL(JESCO,I,JESCLI-1+J)
           ESCOMD(J,1,I) = RTABL(JESCO,I,JESCMD-1+J)
           ESCOMD(J,2,I) = RTABL(JESCO,I,JESCMD-1+J+ECALLS)
  181    CONTINUE
         ESCOCF(I) = ITABL(JESCO,I,JESCCF)
         ESCORF(I) = ITABL(JESCO,I,JESCRF)
         ESCORL(I) = ITABL(JESCO,I,JESCRL)
         ESCOEC(I) = ITABL(JESCO,I,JESCEC)
         ESCOEQ(I) = ITABL(JESCO,I,JESCEQ)
         ESCOET(I) = ITABL(JESCO,I,JESCET)
C         ESCOFR(I) = ITABL(JESCO,I,JESCFR)
C         ESCOLS(I) = ITABL(JESCO,I,JESCLS)
         ESCOS1(I) = ITABL(JESCO,I,JESCS1)
         ESCOS2(I) = ITABL(JESCO,I,JESCS2)
         DO 183 K = 1,4
           CHA4(K) = CHAINT(ITABL(JESCO,I,JESCNM-1+K))
  183    CONTINUE
         ESCONM(I) = CHA4(1)//CHA4(2)//CHA4(3)//CHA4(4)
  180 CONTINUE
C introduction ad hoc des plans de base pour la definition des lignes.
         ESCORR(1,1)=2
         ESCORR(2,1)=6
         ESCORR(1,2)=2
         ESCORR(2,2)=3
         ESCORR(1,3)=2
         ESCORR(2,3)=7
C
C  ... Bank ESEC
C
      JESEC = IW(NAMIND('ESEC'))
      NC = LCOLS(JESEC)
      NR = LROWS(JESEC)
      IF(NR.NE.ECALSS)                GO TO 998
      DO 190 I = 1,NR
         ESECID(I) = ITABL(JESEC,I,JESEID)
         ESECSR(I) = ITABL(JESEC,I,JESESR)
         ESECEQ(I) = ITABL(JESEC,I,JESEEQ)
         DO 191 J=1,ECALLS
           DO 192 K=1,ECALLS
         ESECDM(K,J,I) =RTABL(JESEC,I,JESEDM-1+K+ECALLS*(J-1))
  192      CONTINUE
  191    CONTINUE
  190 CONTINUE
C
C  ... Bank ESLO
C
      JESLO = IW(NAMIND('ESLO'))
      NC = LCOLS(JESLO)
      NR = LROWS(JESLO)
      IF(NR.NE.ECALMD*ECALSC)         GO TO 998
      DO 200 I = 1,ECALSC
        DO 201 J=1,ECALMD
         NRCUR  = J+ECALMD*(I-1)
         ESLOID(J,I) = ITABL(JESLO,NRCUR,JESLID)
         ESLOEA(J,I) = ITABL(JESLO,NRCUR,JESLEA)
         ESLOEM(J,I) = ITABL(JESLO,NRCUR,JESLEM)
         ESLOEQ(J,I) = ITABL(JESLO,NRCUR,JESLEQ)
         ESLOES(J,I) = ITABL(JESLO,NRCUR,JESLES)
         DO 203 K = 1,4
           CHA4(K) = CHAINT(ITABL(JESLO,NRCUR,JESLNM-1+K))
  203    CONTINUE
         ESLONM(J,I) = CHA4(1)//CHA4(2)//CHA4(3)//CHA4(4)
  201   CONTINUE
  200 CONTINUE
C
C  ... Bank ESSC
C
      JESSC = IW(NAMIND('ESSC'))
      NC = LCOLS(JESSC)
      NR = LROWS(JESSC)
      IF(NR.NE.ECALST*ECALSC)         GO TO 998
      DO 210 I = 1,ECALSC
        DO 211 J=1,ECALST
         NRCUR =J+ECALST*(I-1)
         ESSCID(J,I) = ITABL(JESSC,NRCUR,JESSID)
         DO 212 K=1,ECALLS
           ESSCPP(K,J,I) = RTABL(JESSC,NRCUR,JESSPP-1+K)
  212    CONTINUE
         DO 213 K=1,ECALLP
           ESSCPC(K,J,I) = RTABL(JESSC,NRCUR,JESSPC-1+K)
           ESSCPS(K,J,I) = RTABL(JESSC,NRCUR,JESSPS-1+K)
  213    CONTINUE
         ESSCES(J,I) = ITABL(JESSC,NRCUR,JESSES)
         ESSCST(J,I) = ITABL(JESSC,NRCUR,JESSST)
  211   CONTINUE
  210 CONTINUE
C
C  ... Bank ESTY
C
      JESTY = IW(NAMIND('ESTY'))
      NC = LCOLS(JESTY)
      NR = LROWS(JESTY)
      IF(NR.NE.NEQTY*ECALST)          GO TO 998
      DO 220 I = 1,NEQTY
        DO 221 J=1,ECALST
         NRCUR=J+ECALST*(I-1)
         ESTYID(J,I) = ITABL(JESTY,NRCUR,JESTID)
         DO 222 K=1,ECALLS
           ESTYWF(K,J,I) = RTABL(JESTY,NRCUR,JESTWF-1+K)
           ESTYPF(K,J,I) = RTABL(JESTY,NRCUR,JESTPF-1+K)
  222    CONTINUE
         ESTYEQ(J,I) = ITABL(JESTY,NRCUR,JESTEQ)
         ESTYES(J,I) = ITABL(JESTY,NRCUR,JESTES)
  221   CONTINUE
  220 CONTINUE
C
C  ... Bank ETSC
C
      JETSC = IW(NAMIND('ETSC'))
      NC = LCOLS(JETSC)
      NR = LROWS(JETSC)
      IF(NR.NE.ECALSY)                GO TO 998
      DO 230 I = 1,NR
         ETSCID(I) = ITABL(JETSC,I,JETSID)
         ETSCEB(I) = ITABL(JETSC,I,JETSEB)
         ETSCEC(I) = ITABL(JETSC,I,JETSEC)
         DO 231 J=1,ECALLS
           DO 232 K=1,ECALLS
         ETSCDM(K,J,I) =RTABL(JETSC,I,JETSDM-1+K+ECALLS*(J-1))
  232      CONTINUE
  231    CONTINUE
         ETSCAF(I) = RTABL(JETSC,I,JETSAF)
         DO 233 K = 1,4
           CHA4(K) = CHAINT(ITABL(JETSC,I,JETSNM-1+K))
  233    CONTINUE
         ETSCNM(I) = CHA4(1)//CHA4(2)//CHA4(3)//CHA4(4)
  230 CONTINUE
C
C  ... Bank EVLF
C
      JEVLF = IW(NAMIND('EVLF'))
      NC = LCOLS(JEVLF)
      NR = LROWS(JEVLF)
      IF(NR.NE.NEVLF)                 GO TO 998
      DO 240 I = 1,NR
         EVLFID(I) = ITABL(JEVLF,I,JEVLFI)
         EVLFSG(I) = ITABL(JEVLF,I,JEVLSG)
         EVLFEA(I) = ITABL(JEVLF,I,JEVLEA)
         EVLFEL(I) = ITABL(JEVLF,I,JEVLEL)
         EVLFEV(I) = ITABL(JEVLF,I,JEVLEV)
  240 CONTINUE
C
C  ... Bank EVLS
C
      JEVLS = IW(NAMIND('EVLS'))
      NC = LCOLS(JEVLS)
      NR = LROWS(JEVLS)
      IF(NR.NE.ECALSC*ECALNP)         GO TO 998
      DO 250 I = 1,ECALSC
         DO 251 J=1,ECALNP
           NRCUR = J+ECALNP*(I-1)
           EVLSID(J,I) = ITABL(JEVLS,NRCUR,JEVLSI)
           DO 253 K = 1,4
             CHA4(K) = CHAINT(ITABL(JEVLS,NRCUR,JEVLNM-1+K))
  253      CONTINUE
           EVLSNM(J,I) = CHA4(1)//CHA4(2)//CHA4(3)//CHA4(4)
           EVLSVL(J,I) = ITABL(JEVLS,NRCUR,JEVLVL)
           EVLSZN(J,I) = ITABL(JEVLS,NRCUR,JEVLZN)
  251    CONTINUE
  250 CONTINUE
C
C  ... Bank EVOL
C
      JEVOL = IW(NAMIND('EVOL'))
      NC = LCOLS(JEVOL)
      NR = LROWS(JEVOL)
      IF(NR.NE.NEVOL)                 GO TO 998
      DO 260 I = 1,NR
         EVOLID(I) = ITABL(JEVOL,I,JEVOID)
         DO 263 K = 1,4
           CHA4(K) = CHAINT(ITABL(JEVOL,I,JEVONM-1+K))
  263    CONTINUE
         EVOLNM(I) = CHA4(1)//CHA4(2)//CHA4(3)//CHA4(4)
         EVOLEM(I) = ITABL(JEVOL,I,JEVOEM)
         EVOLEQ(I) = ITABL(JEVOL,I,JEVOEQ)
         EVOLET(I) = ITABL(JEVOL,I,JEVOET)
         EVOLFR(I) = ITABL(JEVOL,I,JEVOFR)
         EVOLLS(I) = ITABL(JEVOL,I,JEVOLS)
  260 CONTINUE
C
C  ... Bank EXRG
C
      JEXRG = IW(NAMIND('EXRG'))
      NC = LCOLS(JEXRG)
      NR = LROWS(JEXRG)
      IF (NR.NE.ECALXG+1)             GO TO 998
      DO 270 I = 1,NR
         EXRGID(I) = ITABL(JEXRG,I,JEXRID)
         EXRGPC(1,I) = RTABL(JEXRG,I,JEXRPC)
         EXRGPC(2,I) = RTABL(JEXRG,I,JEXRPC+1)
         EXRGER(I) = ITABL(JEXRG,I,JEXRER)
  270 CONTINUE
C
C  ... Bank EXRO
C
      JEXRO = IW(NAMIND('EXRO'))
      NC = LCOLS(JEXRO)
      NR = LROWS(JEXRO)
      IF (NR.NE.ECALXW)               GO TO 998
      DO 280 I = 1,NR
         EXROID(I) = ITABL(JEXRO,I,1)
         EXROER(I) = ITABL(JEXRO,I,2)
         EXROES(I) = ITABL(JEXRO,I,3)
  280 CONTINUE
C
      RETURN
  998 IGOOD  = 0
      END
