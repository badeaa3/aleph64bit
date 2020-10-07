      SUBROUTINE EDWBRU
C-----------------------------------------------------------------
C!  SIMULATE NOISE ON WIRE READOUT
C
C   AUTHOR   : B. MICHEL, D. PALLIN 05/89
C   MODIFIED :
C   Called by : ECDIGI
C   Calls     : EPRIMI  from this HLB
C             : RANNOR       Genlib
C----------------------------------------------------------------
      SAVE
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
      PARAMETER (LPS1=6, LPS2=300)
      COMMON /ECNAMC/   NAETHT, NAEWHT, NAETTD, NAEWTD, NAETDI, NAEWDI
     &                , NAEWHE
     &                , NAETTR, NAEWTR, NAENDI
     &                , IDPSIG, IDEWTM, IDETTM
     &                , NAESHI, NAEWHI
C
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON /BCS/   IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
      PARAMETER (LSTCK=3,LPHI=384,LTHET=228)
      PARAMETER (LWPLA=45,LMODU=12,LCOMP=3)
      PARAMETER (NTHSG=12,NPHSG=24)
      PARAMETER(JEWDMN=1,JEWDPD=2,JEWDSS=47,LEWDIA=54)
      COMMON/EWTMCO/IWIRES(LWPLA+9,LMODU*LCOMP)
C
C NOISE PER PLANE AND FOR THE SUM IN KEV
C ST3EC1 , ST3BA1 : SAMPLING IN STACK 3 FOR END-CAPS AND BARREL
      PARAMETER (NTMODU = LCOMP * LMODU)
      PARAMETER(PLCOHE=300,PLUNCO=1000,SMCOHE=17100,SMUNCO=7550)
      DIMENSION JSUM(NTMODU),SAMTIM(8),SAMSUM(8)
      EXTERNAL EPRIMI
      DATA(SAMTIM(I),I=1,8)/0.,512.,1024.,1536.,2048.,2560.,3072.,3584./
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
      DO 11 I=1,8
   11 SAMSUM(I) = 0.
      DO 12 I=1,NTMODU
      DO 12 J=1,LEWDIA
   12 IWIRES(J,I) = 0
      DO 5 J=1,NTMODU
      JSUM(J) = 0
 5    IWIRES(1,J)=J
C
      KEWHT=IW(NAEWHT)
      IF(KEWHT.EQ.0)GO TO  13
      NEWHT=LROWS(KEWHT)
C
      DO 1 J=1,NEWHT
      KLINE=KROW(KEWHT,J)
      JJ=IW(KLINE+1)
      DO 1 I=2,LWPLA + 1
      IWIRES(I,JJ)=IW(KLINE+I)
      JSUM(JJ)=JSUM(JJ)+IWIRES(I,JJ)
C Stack 3
      IF(I.GE.35)                   THEN
         IF(JJ.LT.13.OR.JJ.GT.24)THEN
C            End caps
             IWIRES(I,JJ)=NINT(REAL(IWIRES(I,JJ))/ST3EC1)
         ELSE
C            Barrel
             IWIRES(I,JJ)=NINT(REAL(IWIRES(I,JJ))/ST3BA1)
         ENDIF
C
       ENDIF
 1    CONTINUE
 13   CONTINUE
C
C   Add analog sum sampling
C
      OFFSET=EPRIMI(SAMTIM(1))
      DO 2 J=1,NTMODU
        DO 3 K=2,8
        SAMSUM(K)=FLOAT(JSUM(J))*(EPRIMI(SAMTIM(K))-OFFSET)
 3      IWIRES(K+46,J)=IFIX(SAMSUM(K))
C
C   Noise simulation
C
      CALL RANNOR(SIG1,SIG2)
      PLCO=PLCOHE*SIG1
      SMCO=SMCOHE*SIG1
      DO 4 K=2,LEWDIA
      CALL RANNOR(SIG1,SIG2)
      IF(K.LT.JEWDSS)        THEN
                PLUN=PLUNCO*SIG1
                BRUIT=PLCO+PLUN
      ELSE
                SMUN=SMUNCO*SIG2
                BRUIT=SMCO+SMUN
      ENDIF
 4    IWIRES(K,J)=IWIRES(K,J)+IFIX(BRUIT)
 2    CONTINUE
C
      RETURN
      END
