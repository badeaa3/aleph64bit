          REAL FUNCTION HTXSPL(IDHEI,ILAY)
C-----------------------------------------------------------
CKEY HCALDES HCAL EIGHTFOLD TUBE LENGTH /USER
C
C!  Return the difference in lenght from one wire and the following
C!  in a double_eightfold
C!
C!                          Author: G.Catanesi 5/06/89
C!
C!         INPUT:
C!                IDHEI/I = double eightfold#
C!                ILAY/I  = layer#
C!
C-----------------------------------------------------------
C!    GEOMETRY COMMONS FOR HADRON CALORIMETER
      PARAMETER( LPHC=3,LSHC=3,LPECA=1,LPECB=3,LPBAR=2)
      PARAMETER( LHCNL=23,LHCSP=2,LHCTR=62,LHCRE=3)
      PARAMETER (LHCNO = 3)
      PARAMETER( LPHCT = 4)
      PARAMETER( LPHCBM = 24,LPHCES = 6)
      COMMON /HCALGE/HCRMIN(LSHC),HCRMAX(LSHC),HCZMIN(LSHC),HCZMAX(LSHC)
     &              , NHCSUB,NHCTWR,NHCPHC,NHCREF,IHCTID(LHCRE-1)
     &              , HCTUTH,HCIRTH,HCLSLA,NHCPLA(LPHC),HCTIRF(LPHC)
     &              , HCSMTH
      COMMON / HBAR / NHCBMO,NHCBFS,NHCBBS,NHCBLA,HCLTNO(LHCNO)
     &              , HCWINO(LHCNO),HCDEWI,NHBLA2,NHBLI3,NHBLO3
     &              , NEITHC(LHCNL),NEITSP(LHCNL,LHCSP)
     &              , HCSPLT(LHCNL,LHCSP), HFSPBL,HFSRBL,HCPHOF
C
      COMMON /HEND/  HCDREC,HCDSTP,HCAPSL,HFSPEC,NHCSEX
     &           ,NHCEFS,NHCEBS,NHCTRE,NHCINL,NHCOUL
     &           ,NHCIND,NHCOUD
C
       PARAMETER (LHCBL=4,LHCEI=10,LHCEO=20,LHNLA=4)
      COMMON /HCCONS/ HCTHRF,HCRSIZ,HCZSIZ,NHCBAR,NHCECA
     &               ,NHCEIT,HCEIWI,HCDOWI,HCTUGA,HCSEPO
     &               ,HCSABL,HCSAEC,HCTUEN,XLNHCE(LHCBL)
     &               ,HCTLEI(LHNLA,LHCEI),HCTLEO(LHNLA,LHCEO)
     &               ,HCTAEI(LHCEI),HCTAEO(LHCEO),HTINBL,HTINEC(2)
     &               ,HTPIEC,HTPOEC,HBWREC,HBWCEC(2),HBSREC
     &               ,HBSCEC,HBWRBL,HBSCBL,NHMBDF(2),NHTY4D
     &               ,NHTY3D,NHTY2D,NHMBFL(2),NHBDOU,NHDLEC
     &               ,NHDET0,NHDEBS,NHL8EC(LHCNL-1),HCTUSH,XHCSHI(LHCBL)

      PARAMETER (LHCTR1=LHCTR+1)
      COMMON /HCSEVA/ NTHCFI(LHCRE),HCAPDE(LPHCT),HCFITW(LHCRE)
     &               ,HCBLSP(LHCNL,LHCSP),NHCTU1(LHCNL),HCTHUL(LHCTR1)
     &               ,PHCTOR(LHCTR),IHCREG(LHCTR)
     &               ,HCLARA(LHCNL),HCLAWI(LHCNL)
     &               ,YBAST1,YBARMX,ZENST1,ZENDMX
     &               ,XBARR0,XENDC0
C
C
            HTXSPL  = 0.
C
            IF(ILAY.LE.NHCINL)THEN
               HTXSPL = HCTLEI(1,IDHEI) - HCTLEI(4,IDHEI)
            ELSE
               HTXSPL = HCTLEO(1,IDHEI) - HCTLEO(4,IDHEI)
C
C  Special tratement for layer 8
C
               IF(ILAY.EQ.NHDLEC)THEN
                 IF(IDHEI.EQ.3)THEN
                    HTXSPL = HCTLEO(1,14) - HCTLEO(4,14)
                 ENDIF
                 IF(IDHEI.EQ.7)THEN
                    HTXSPL = HCTLEO(1,16) - HCTLEO(4,16)
                 ENDIF
                 IF(IDHEI.EQ.13)THEN
                    HTXSPL = HCTLEI(1,9) - HCTLEI(4,9)
                 ENDIF
                 IF(IDHEI.EQ.18)THEN
                    HTXSPL = 0.
                 ENDIF
               ENDIF
            ENDIF
C
            HTXSPL = ABS(HTXSPL/(2*NHCEIT))
C
            RETURN
            END
