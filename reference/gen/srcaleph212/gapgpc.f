      SUBROUTINE GAPGPC
C----------------------------------------------------------------------
C!  - Build PGPC bank (result of GAMPEC)
C!          EGPR bank (list of photon tower)
C!   Author   :  MN Minard             27-JAN-1993
CKEY GAMPACK PGPC EGPR
C?
C!======================================================================
      PARAMETER(JPGPEC=1,JPGPTC=2,JPGPPC=3,JPGPR1=4,JPGPR2=5,JPGPF4=6,
     +          JPGPDM=7,JPGPST=8,JPGPQU=9,JPGPQ1=10,JPGPQ2=11,
     +          JPGPM1=12,JPGPM2=13,JPGPMA=14,JPGPER=15,JPGPTR=16,
     +          JPGPPR=17,JPGPPE=18,LPGPCA=18)
      PARAMETER(JEGPPR=1,JEGPGR=2,LEGPRA=2)
      PARAMETER(JEGRSE=1,JEGRC1=2,JEGRC2=3,JEGRC3=4,JEGRCU=5,JEGRDS=6,
     &          JEGR12=7,JEGR23=8,LEGRPA=8)
      PARAMETER(JPECER=1,JPECE1=2,JPECE2=3,JPECTH=4,JPECPH=5,JPECEC=6,
     +          JPECKD=7,JPECCC=8,JPECRB=9,JPECPC=10,LPECOA=10)
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON /BCS/   IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
C --- max number of STOREYS per PHOTON
      PARAMETER ( NSTTTT = 500    )
C --- max number of photon per peco cluster
      PARAMETER ( NFPHOT = 20     )
      COMMON/GASTIN/ LGASTO(NFPHOT,NSTTTT) , NNSTGA(NFPHOT)
      DIMENSION STACE(6),BARY(4)
      PARAMETER ( EMIN0 = 0.25 , NFOMAX = 20 , NGAMVE = 20 )
      PARAMETER ( PSATU = 0.00078 )
      DIMENSION GAMVE(NGAMVE,NFOMAX) , GAMCE(NGAMVE,NFOMAX)
      DATA NAPEST,NAPECO,NAPGPC,NAEGPR,NAEGRP /5*0/
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
C ---------------------------------------------------------------------
C-  Set name index
C
      IF (NAPEST.EQ.0) THEN
        NAPEST = NAMIND('PEST')
        NAPECO = NAMIND('PECO')
        NAPGPC = NAMIND('PGPC')
        NAEGPR = NAMIND('EGPR')
        NAEGRP = NAMIND('EGRP')
        KEGRP  = IW(NAEGRP)
        IF (KEGRP.EQ.0) THEN
          LRCONS = JUNIDB(0)
          KEGRP = MDARD(IW,LRCONS,'EGRP',0)
        ENDIF
        IF (KEGRP.EQ.0) THEN
          EMIN = EMIN0
        ELSE
          EMIN = RTABL(KEGRP,1,JEGRCU)
        ENDIF
      ENDIF
C
C-    Built EGAM
C
      KPECO = IW(NAPECO)
      NPECO = 0
      IF ( KPECO.NE.0 ) NPECO = LROWS(KPECO)
      NGAMX = 3*NPECO
C
C-    Built EGPC bank
C
      KPGPC = NDROP('PGPC',0)
      NLENG = NGAMX*LPGPCA+LMHLEN
      CALL AUBOS('PGPC',0,NLENG,KPGPC,IGARB)
      IF (IGARB.EQ.2) GO TO 998
      IW(KPGPC+LMHCOL) = LPGPCA
      IW(KPGPC+LMHROW) = 0
      IF ( IGARB.NE.0) KPECO = IW(NAPECO)
C
C-    Built EGPR bank
C
      KEGPR = NDROP('EGPR',0)
      KPEST = IW(NAPEST)
      NPEST = 0
      IF (KPEST.NE.0) NPEST = LROWS(KPEST)
      NLENG = NPEST*LEGPRA + LMHLEN
      CALL AUBOS('EGPR',0,NLENG,KEGPR,IGARB)
      IF(IGARB.EQ.2) GO TO 998
      IF ( IGARB.NE.0) THEN
         KPECO = IW(NAPECO)
         KPGPC = IW(NAPGPC)
         KPEST = IW(NAPEST)
      ENDIF
      IW(KEGPR+LMHROW) = 0
      IW(KEGPR+LMHCOL) = LEGPRA
C
C-    Now loop on PECO and fill PGPC
C
      INRES = 0
      NGAM = 0
      DO IPECO=1,NPECO
        IF( RTABL(KPECO,IPECO,JPECEC).GT.EMIN ) THEN
          CALL GAMPEX (IPECO,EMIN,NGAMVE*NFOMAX,NNGA,GAMVE,GAMCE,IRTG)
          IF ( IRTG.GE.0.AND.NNGA.GT.0) THEN
            IF ( NGAM+NNGA.GT.NGAMX) THEN
              NGAMX = NGAMX+NNGA + 10
              NLENG = NGAMX*LPGPCA+LMHLEN
              CALL AUBOS('PGPC',0,NLENG,KPGPC,IGARB)
              IF ( IGARB.EQ.2) GO TO 998
              IF ( IGARB.NE.0) THEN
                KPECO = IW(NAPECO)
                KEGPR = IW(NAEGPR)
                KPEST = IW(NAPEST)
              ENDIF
            ENDIF
            DO IGAM = 1,NNGA
              JPGPC = KROW(KPGPC,IGAM+NGAM)
              RW(JPGPC+JPGPEC) = GAMVE(1,IGAM)*GAMVE(4,IGAM)
              RW(JPGPC+JPGPTC) = GAMVE(2,IGAM)
              RW(JPGPC+JPGPPC) = GAMVE(3,IGAM)
              RW(JPGPC+JPGPR1) = GAMVE(9,IGAM)
              RW(JPGPC+JPGPR2) = GAMVE(10,IGAM)
              RW(JPGPC+JPGPF4) = GAMVE(6,IGAM)
              RW(JPGPC+JPGPDM) = GAMVE(16,IGAM)
              RW(JPGPC+JPGPST) = GAMVE(8,IGAM)
              IW(JPGPC+JPGPQU) = INT(GAMVE(13,IGAM))
     &        +INT(GAMVE(11,IGAM))*100
              RW(JPGPC+JPGPQ1) = GAMVE(7,IGAM)
              RW(JPGPC+JPGPQ2) = GAMVE(20,IGAM)
              RW(JPGPC+JPGPM1) = GAMCE(1,IGAM)
              RW(JPGPC+JPGPM2) = GAMCE(2,IGAM)
              RW(JPGPC+JPGPMA) = GAMCE(20,IGAM)
C
C-           Correct for leakage  & saturation
C
              EGRAW = GAMVE(12,IGAM)
              STACE(1) = EGRAW
              STACE(2) = 0.
              STACE(3) = 0.
              BARY(1) = GAMVE(17,IGAM)
              BARY(2) = GAMVE(18,IGAM)
              MTC = 0
              CORLK = 1.
              CALL ECLEAK(MTC,STACE,BARY,MTC,CORLK)
              CALL ABRUEV (NRUN,NEVT)
              CORSAT = 1.
              IF (NRUN.GT.2000) CORSAT  =  1. + PSATU * EGRAW *CORLK
              COROV = GAMCE(19,IGAM)
              RW(JPGPC+JPGPER) = GAMVE(12,IGAM)*CORSAT*CORLK*COROV
              RW(JPGPC+JPGPTR) = GAMVE(17,IGAM)
              RW(JPGPC+JPGPPR) = GAMVE(18,IGAM)
              IW(JPGPC+JPGPPE) = IPECO
              NSTEG = NNSTGA(IGAM)
              DO ISTEG = 1,NSTEG
                JEGPR = KROW(KEGPR,ISTEG+INRES)
                IW(JEGPR+JEGPGR) = IGAM+NGAM
                IW(JEGPR+JEGPPR) = LGASTO(IGAM,ISTEG)
              ENDDO
              INRES = INRES + NSTEG
              IW(KEGPR+LMHROW) = IW(KEGPR+LMHROW)+NSTEG
            ENDDO
            NGAM = NGAM + NNGA
            IW(KPGPC+LMHROW) = IW(KPGPC+LMHROW)+NNGA
          ENDIF
        ENDIF
      ENDDO
      CALL AUBPRS('PGPCEGPR')
C
  998 RETURN
      END
