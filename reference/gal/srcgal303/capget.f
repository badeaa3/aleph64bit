      SUBROUTINE CAPGET
C ------------------------------------------------------------------
C - F.Ranjard - 880505
C! Geantino track element : get CAPA bank
C! IF 1st entry (bank does not exist) THEN
C!    create the CAPA bank with the bank# = track# IGTRA
C!    fill it with the shower parameters
C! ELSE
C!    increment the total rad. length and abs. length
C!    copy the CAPA bank to common /CAPANO/
C! ENDIF
C - called by GUSTEP                                from this .HLB
C - calls ALBOS, ALTELL                             from ALEPHLIB
C         CAHPAR, CAEPAR, CAPSTO                    from this .HLB
C ========================================================
      SAVE
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON /BCS/   IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
      PARAMETER(JCAPST=1,JCAPPT=2,JCAPTE=3,JCAPTX=4,JCAPTL=5,JCAPEM=6,
     +          JCAPEA=7,JCAPEB=8,JCAPA1=9,JCAPER=10,JCAPEF=11,
     +          JCAPED=12,JCAPEZ=13,JCAPHE=14,JCAPHA=15,JCAPHB=16,
     +          JCAPHD=17,JCAPHP=18,JCAPGA=19,JCAPSX=20,JCAPSA=21,
     +          JCAPNA=22,LCAPAA=22)
      PARAMETER(LTYPEL=48, LTYPME=49, LTYPBA=50, LTYPAN=51, LTYPGA=52)
      COMMON / CAPANO / NATGER,METHCO,TOTNRJ,TINOX0,TINOL0,EMGNRJ,
     + EMALFA,EMBETA,EMALM1,EMAEXP,EMFACT,EMUDP0,EMUDP2, HADNRJ,HALPHA,
     + HABETA,HADRAY,HAPUIS,HGAMMA,SMAXLR,SMAXLA
       COMMON / CANAME / EMNAME
       CHARACTER*4 EMNAME
C
C
C ----- Version du 16/03/87
      COMMON / EHPASH /
     1 RHODEP,PARGV1,ENMAX1,ENMAX2,PARGV2,NRAPID,RHOVIT(14),
     2 FASTNR(14),FLUCT1(14),FLUCT2(14),EMINPI(14),EPICUT(14),
     3 EMINLO,ETRANS,ASURB1(5),ASURB2(5),UNSRB1(5),UNSRB2(5),
     4 SIGMA1(5),SIGMA2(5),SIGMB1(5),SIGMB2(5),SIGMA3(5),SIGMB3(5),
     5 SEUSIG,USAMIN,USAMAX,BSUMIN,BETMIN,BETMAX,
     6 ZONSH1,ZONSH2,DEPMIN,
     7 EMINRA,EXPRD0,EXPRD1,RFACT0,RFACT1,KPAMAX,X1MAXI,EPSRAD,
     8 EMFRAC,ALPHA0,ALPHA1,BETAH0,BETAH1,RAYHA0,RAYHA1,PUISH0,
     9 PARGVH,NRJHAD,IPLMIN(14),IPLMAX(14),DESATU,FNFRAG,
     + ECHMX,ECHDC,EKEVH,ECHDN,ERADMX,
     + ERMAX,ETANG,ERHMX,EZMAX,EDSELM,EDSHAD,ECUTTE,
     + ST3BA0,ST3EC0,ST3BA1,ST3EC1,ST3BA2,ST3EC2
      COMMON / EHPADA /
     1   CNRJDA,C1PRDA,C2PRDA,C3PRDA,PIMADA,ANRJDA,A1PRDA,A2PRDA,
     2   A3PRDA,A4PRDA,A5PRDA,AMRJDA
      COMMON/GCMATE/NGMAT,NGAMAT(5),GA,GZ,GDENS,GRADL,GABSL
C
      COMMON/GCKINE/IGKINE,GPKINE(10),IGTRA,IGSTAK,IGVERT,IGPART,IGTRTY
     +              ,NGAPAR(5),GMASS,GCHARG,GTLIFE,GVERT(3),GPVERT(4)
     +              ,IGPAOL
C
      COMMON/GCTRAK/GVECT(7),GETOT,GEKIN,GVOUT(7),NGMEC,LGMEC(30)
     &,NGAMEC(30),NGSTEP,MGXNST,GDESTP,GDESTL,GSAFET,GSLENG,GSTEP,GSNEXT
     &,GSFIEL,GTOFG,GEKRAT,GUPWGH,IGNEXT,IGNWVO,IGSTOP,IGAUTO,IGEKBI
     &,IGLOSL,IGMULL,IGNGOT,NGLDOW,NGLVIN,NGLVSA,IGSTRY
C
       CHARACTER*4 CHAINT
       EXTERNAL CHAINT
C -------------------------------------------------------------------
         JCAPA = NLINK ('CAPA',IGTRA)
         IF (JCAPA .EQ. 0.) THEN
            CALL ALBOS ('CAPA',IGTRA,LCAPAA+LMHLEN,JCAPA,IGARB)
            IW(JCAPA+LMHCOL) = LCAPAA
            IW(JCAPA+LMHROW) = 1
            CALL BLIST (IW,'T+','CAPA')
            CALL CAHPAR (GETOT,IGPART)
            CALL CAEPAR
            CALL CAPSTO (IGTRA)
         ELSE
            KCAPA = JCAPA + LMHLEN
C
C-          TEST IF ELECTRON GEANTINO ABSORBED
C
            RW(KCAPA+JCAPTX) = RW(KCAPA+JCAPTX) + GSTEP/GRADL
            RW(KCAPA+JCAPTL) = RW(KCAPA+JCAPTL) + GSTEP/GABSL
C              fill common /CAPANO/
            NATGER = IW(KCAPA+JCAPST)
            METHCO = IW(KCAPA+JCAPPT)
            TOTNRJ = RW(KCAPA+JCAPTE)
            TINOX0 = RW(KCAPA+JCAPTX)
            TINOL0 = RW(KCAPA+JCAPTL)
            EMGNRJ = RW(KCAPA+JCAPEM)
            EMALFA = RW(KCAPA+JCAPEA)
            EMBETA = RW(KCAPA+JCAPEB)
            EMALM1 = RW(KCAPA+JCAPA1)
            EMAEXP = RW(KCAPA+JCAPER)
            EMFACT = RW(KCAPA+JCAPEF)
            EMUDP0 = RW(KCAPA+JCAPED)
            EMUDP2 = RW(KCAPA+JCAPEZ)
            HADNRJ = RW(KCAPA+JCAPHE)
            HALPHA = RW(KCAPA+JCAPHA)
            HABETA = RW(KCAPA+JCAPHB)
            HADRAY = RW(KCAPA+JCAPHD)
            HAPUIS = RW(KCAPA+JCAPHP)
            HGAMMA = RW(KCAPA+JCAPGA)
            EMNAME = CHAINT(IW(KCAPA+JCAPNA))
            SMAXLR = RW(KCAPA+JCAPSX)
            SMAXLA = RW(KCAPA+JCAPSA)
            CALL CAABSB(EMGNRJ,EMBETA,EMALFA,TINOX0,IER)
            IF ( IER.NE.0) THEN
               IGSTOP = 3
               GO TO 999
            ENDIF
         ENDIF
 999     CONTINUE
         RETURN
      END