*DK DAE
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DAE
CH
      SUBROUTINE DAE
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C!:
C    Inputs    :
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      CHARACTER *4 DT4
      DATA IVNT/9/,INO/0/
      PARAMETER (MP2=10)
      CHARACTER *2 TANSW,TP1(1),TP2(MP2),TLAST
      DATA TLAST/'WF'/
      DIMENSION PR2(4,MP2)
      DATA TP1/'NH'/
      DATA TP2/'NF','DT','DZ','D1','D2','DA','DF','CO','RO','FS'/
      DATA PR2/9.,92.,99.,0., .01,2.,99.,1., -999.,0.,999.,0.,
     &  -9.,2.,99.,0.,  0.,16.,99.,0., 0.,1.,99.,0., 0.,10.,99.,0.,
     &  0.,12.,15.,0., 1.,180.,9999.,1.,  -99.,1.,99.,-1./
      DIMENSION LCTE(0:7)
      DATA LCTE/8,12,10,13,9,14,11,15/,NCTE/6/,ROMID/105./
      DATA RM/170./
      LOGICAL FCHG
      DATA LC5/5/,LC7/7/,LC8/8/,LC9/9/
      CHARACTER *49 T1,T2,T3,T4
C              123456789 123456789 123456789 123456789 123456789
      DATA T1/'P?: ev=12 tr=1234 NH$12345 sum=12345  file: NF_12'/
      DATA T2/'   "CH": col=col(te) DT$123  "CZ": DZ_1234  CO_12'/ 
      DATA T3/'CLean/UnClean: D1_123 D2_123 DA_123 DF_123'/
      DATA T4/'XY compression and skew ("CR") : RO$1234 FS$123'/ 

C
  930 CALL DTSTOI('A',T1, 'ev=',  NEV,2)
      CALL DTSTOI('A',T1, 'tr=',NUMTR,4)
      CALL DTSTOI('A',T1,'sum=', LAST,5)
      CALL DTYPT('SAVE',  ' ' ,1,3,             PR2,TP2,T1)
      CALL DTYPT('TYPE',TPICDO,1,1,BNUMDB(1,TPCODB),TP1,T1)
      CALL DTYPT('TYPE',  ' ' ,1,MP2,           PR2,TP2,T2)
      CALL DTYPT('TYPE',  ' ' ,1,MP2,           PR2,TP2,T3)
      CALL DTYPT('TYPE',  ' ' ,1,MP2,           PR2,TP2,T4)
  936 FCHG=.FALSE.
      CALL DOPER(1,0,
     &  1,1,TP1,BNUMDB(1,TPCODB),
     &  1,MP2,TP2,PR2,
     &  NEXEC,FCHG,TANSW)
      GO TO (910,920,930,940),NEXEC
  910 RETURN
  920 TLAST=TANSW
      IF(TANSW.EQ.'W0') THEN
        CALL=DVTPCL(0)
        VRDZDV=0.
        TANSW='WF'
      END IF
      IF(TANSW.EQ.'WF') THEN
        FTDZ=FTDZDU
        FTDZDU=0.
        VRDZ=VRDZDU
        VRDZDU=-1.
        DO N=1,8
          CALL=DVTPST(N,J)
        END DO
        FTDZDU=FTDZ
        VRDZDU=VRDZ
        CALL=DVTPST(IVNTDV,IVNT)
        NUM=BNUMDB(2,TPCODB)
        IF(NW.EQ.0) THEN
          LAST=0
          NUMTR=0
          NEV=0
        END IF
        NW=PR2(2,1)
        NLT=0
        NEV=NEV+1
        DO K=1,NUM
          NT=NTPCDV(IVNT,K)
          WRITE(NW,1000) (VTPCDV(N,K),N=1,8),NT,NEV
 1000     FORMAT(1X,8(F8.3, ',' ),I3,',',I2)
          IF(NT.NE.NLT.AND.NT.GT.0) THEN
            NUMTR=NUMTR+1
            NLT=NT
          END IF
        END DO
        LAST=LAST+NUM
        CALL DWRT(DT4(BNUMDB(2,TPCODB))//' hits added.')
        GO TO 930
      END IF
      IF(TANSW.EQ.'CF') THEN
        CLOSE(UNIT=NW)
        CALL DWRT('File closed.')
        NW=0
        GO TO 930
      END IF
      IF(TANSW.EQ.'RF') THEN
        NUMTR=0
        NLT=0
        NR=PR2(2,1)
        DO K=1,MTPCDV
          READ(NR,1000,END=922) (VTPCDV(N,K),N=1,8),NTPCDV(IVNT,K),NEV
          VTPCDV(IVDIDV,K)=VTPCDV(IVTEDV,K)
          NT=NTPCDV(IVNT,K)
          IF(NT.EQ.0) THEN
            NCTPDC(K)=LC8
          ELSE
C           ............. EXAMPLE: track 12 gets color 12
            NCTPDC(K)=LC9+MOD(NT+LC5,LC7)
          END IF
          IF(NT.NE.NLT.AND.NT.GT.0) THEN
            NUMTR=NUMTR+1
            NLT=NT
          END IF
        END DO
        K=K+1
  922   LAST=K-1
        DO N=1,MBNCDB
          BNUMDB(4,N)=-1.
          BNUMDB(2,N)=0.
        END DO
        BNUMDB(2,TPCODB)=LAST
        BNUMDB(3,TPCODB)=LAST
        BNUMDB(4,TPCODB)=1.
        CALL=DVTPS1(DUMMY)
        CALL VZERO(COLRDT,999)
        FNOCDC=.TRUE.
        FVTPDC=.TRUE.
        CALL DWRT('TPC hits stored')
        CLOSE(UNIT=NR)
        GO TO 930
      END IF
      IF(TANSW.EQ.'CR') THEN
        DO K=1,LAST
          VTPCDV(IVXXDV,K)=VTPCDV(IVRODV,K)*COSD(VTPCDV(IVFIDV,K))
          VTPCDV(IVYYDV,K)=VTPCDV(IVRODV,K)*SIND(VTPCDV(IVFIDV,K))
        END DO
        IF(PR2(4,9).EQ.1.) THEN
          A=PR2(2,9)
          Q=RM/(A+RM)
          Q2CPT=0.
          ASRM=0.
          IF(PR2(4,10).EQ.1.) THEN
            IF(PR2(2,10).NE.0.) THEN
              CCC=-1./(0.003*1.5)
              Q2CPT=1./(2.*CCC*PR2(2,10))
              ASRM=ASIN(ROMID*Q2CPT)
            END IF
          END IF
          DO K=1,LAST
            RS=(A+VTPCDV(IVRODV,K))*Q
            H=VTPCDV(IVRODV,K)
            FS=VTPCDV(IVFIDV,K)-PIFCDK*(ASIN(H*Q2CPT)-ASRM)
            VTPCDV(IVXXDV,K)=RS*COSD(FS)
            VTPCDV(IVYYDV,K)=RS*SIND(FS)
          END DO
        END IF
        GO TO 930
      END IF
      IF(TANSW.EQ.'CH') THEN
  923   IF(PR2(4,2).GT.0.) THEN
          Q=1./PR2(2,2)
          DO K=1,LAST
            ITE=VTPCDV(IVDIDV,K)*Q
            NCTPDC(K)=LCTE(MOD(ITE,NCTE))
          END DO
          FVTPDC=.TRUE.
        ELSE
          FVTPDC=.FALSE.
        END IF
        CALL DSC0
        GO TO 930
      END IF
      IF(TANSW.EQ.'CN') THEN
        NCOL=PR2(2,8)
        DO K=1,LAST
          NCTPDC(K)=NCOL
        END DO
        FVTPDC=.TRUE.
        CALL DSC0
        GO TO 930
      END IF
      IF(TANSW.EQ.'CZ') THEN
        DZ=PR2(2,3)
        DO K=1,LAST
          VTPCDV(IVTEDV,K)=ATAN2(VTPCDV(IVRODV,K),
     &                           VTPCDV(IVZZDV,K)-DZ)*PIDGDK
          VTPCDV(IVDIDV,K)=VTPCDV(IVTEDV,K)
        END DO
        CALL DWRT('DZ changed')
        GO TO 930
      END IF
      IF(TANSW.EQ.'RE') THEN
        NCUT=0
        DR1=PR2(2,4)
        DR2=PR2(2,5)
        DTS=PR2(2,6)
        DFS=PR2(2,7)
        DO K=1,LAST
          VTPCDV(IVTEDV,K)=-128.
        END DO
        DO K=1,LAST-1
          DO N=K+1,LAST
            DR=ABS(VTPCDV(IVRODV,K)-VTPCDV(IVRODV,N))
            IF(DR.GT.DR1.AND.DR.LT.DR2) THEN
              DT=ABS(VTPCDV(IVDIDV,K)-VTPCDV(IVDIDV,N))
              IF(DT.LT.DTS) THEN
                DF=ABS(VTPCDV(IVFIDV,K)-VTPCDV(IVFIDV,N))
                IF(DF.LT.DFS) THEN
                  VTPCDV(IVTEDV,K)=VTPCDV(IVDIDV,K)
                  VTPCDV(IVTEDV,N)=VTPCDV(IVDIDV,N)
                  GO TO 800
                END IF
              END IF
            END IF
          END DO
          NCUT=NCUT+1
  800   END DO
        WRITE(TXTADW,1800) NCUT
 1800   FORMAT(I6,' noise hits')
        CALL DWRC
        GO TO 930
      END IF
      IF(TANSW.EQ.'TN') THEN
        DO K=1,LAST
          IF(VTPCDV(IVTEDV,K).EQ.-128.) THEN
            VTPCDV(IVTEDV,K)=VTPCDV(IVDIDV,K)
          ELSE
            VTPCDV(IVTEDV,K)=-128.
          END IF
        END DO
        GO TO 930
      END IF
      IF(TANSW.EQ.'IN') THEN
        DO K=1,LAST
          VTPCDV(IVTEDV,K)=VTPCDV(IVDIDV,K)
        END DO
        GO TO 930
      END IF
      CALL DWR_IC(TANSW)
      GO TO 936
  940 TANSW=TLAST
      GO TO 920
      END
*DK DAPD
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DAPD
CH
      SUBROUTINE DAPD
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C!:
C    Inputs    :
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      LOGICAL FOUT,FUSFI,FUSTE
      DIMENSION HRB(4),VRB(4)
      CALL DQCL(IAREDO)
      CALL DQWIL(W0)
      IF(NOCLDT.EQ.0) CALL DQFFWI(IFIX(PDCODD(2,ICTPDD)))
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_PFI,J_PTE'
      CALL DPARAM(11
     &  ,J_PFI,J_PTE)
      TPARDA=
     &  'J_AHM,J_ADH,J_AVM,J_ADV,J_AAL,J_AVV,J_AHV,J_ATH,J_ATV'
      CALL DPARAM(35
     &  ,J_AHM,J_ADH,J_AVM,J_ADV,J_AAL,J_AVV,J_AHV,J_ATH,J_ATV)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      DH=0.5*PARADA(2,J_ADH)
      IF(PARADA(4,J_ADV).LT.0.) THEN
        DV=DH
      ELSE
        DV=0.5*PARADA(2,J_ADV)
      END IF
      CALL DQRER(0,
     &  PARADA(2,J_AHM)-DH,PARADA(2,J_AVM)-DV,
     &  PARADA(2,J_AHM)+DH,PARADA(2,J_AVM)+DV,
     &  HRB,VRB)
      CALL DQRU(HRB,VRB)
      CALL DSCTP
      CALL DV0(TPCODB,NUM1,NUM2,FOUT)
      IF(FOUT) GO TO 9
      CALL DCUTTF(FUSFI,FC1,FC2,FUSTE,TC1,TC2)
C//   CALL DQPD0(MSYMDL(MTPCDL,0),WDSNDL(2,4,MTPCDL),0.)
      CALL DPAR_SET_SY(62,0.)
      FIMID=PARADA(2,J_PFI)
      TEMID=PARADA(2,J_PTE)
      NH=ABS(PARADA(2,J_AHV))
      NV=ABS(PARADA(2,J_AVV))
      SH=SIGN(1.,PARADA(2,J_AHV))
      SV=SIGN(1.,PARADA(2,J_AVV))
      AL=PARADA(2,J_AAL)
      CA=COSD(AL)
      SA=SIND(AL)
      IF(PARADA(4,J_ATH).EQ.1.) THEN
        TH=PARADA(2,J_ATH)
      ELSE
        TH=0.
      END IF
      IF(PARADA(4,J_ATH).EQ.1.) THEN
        TV=PARADA(2,J_ATV)
      ELSE
        TV=0.
      END IF
      DO K=NUM1,NUM2
        IF(FCUHDT) THEN
          CALL=DVTPNT(K,NTRK)
          IF(FNOHDT(NTRK)) GO TO 300
        END IF
        IF(FUSTE) THEN
          TE=DVTP(IVTEDV,K)
          IF(TE.LT.TC1.OR.TE.GT.TC2) GO TO 300
        END IF
        IF(FUSFI) THEN
          FI=DFINXT(FIMID,DVTP(IVFIDV,K))
          IF(FI.LT.FC1.OR.FI.GT.FC2) GO TO 300
        END IF
        IF(FVTPDC) CALL DGLEVL(NCTPDC(K))
        T=DVTP(IVTEDV,K)-TEMID
        X=SH*DVTP(NH,K)
        Y=SV*DVTP(NV,K)
        H= X*CA+Y*SA+TH*T
        V=-X*SA+Y*CA+TV*T
        IF(FPIKDP) THEN
          CALL DQPIK(H,V)
        ELSE
          CALL DQPD(H,V)
        END IF
  300 END DO
    9 CALL DQFR(IAREDO)
      CALL DPCSAR
      END
*DK DAREA
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DAREA
CH
      SUBROUTINE DAREA(A1,A,N1,N2,NAR,NYES)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C!:  RETURN NUMBER OF WINDOW
C    Inputs    :A=operator input must start with letter A1
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      CHARACTER *(*) A
      CHARACTER *1 A1
      DATA NOF/1/,NLET/6/,DVIRT/35./
      DIMENSION IWCH(0:12)
C               W 1 2 3 4 5 6 U D  L  M  R  S
C               W 3 4 5 6 2 1 D U  M  R  S  L
C               0 1 2 3 4 5 6 7 8  9 10 11 12
      DATA IWCH/0,3,4,5,6,2,1,8,7,10,11,12, 9/
      CHARACTER *1 T789(7:9)
      DATA T789/'7','8','9'/
      LOGICAL NYES
      NYES=.FALSE.
      IF(A1.EQ.'D'.AND.A.EQ.'C*') A='D*'

      IF(A(1:1).EQ.A1.AND.A(2:2).EQ.'.') THEN
        NYES=.TRUE.
        RETURN
      END IF

      IF(A.EQ.A1//'*') THEN
        CALL DGCURG(HW,VW)
        IF(HW.LE.0.OR.HW.GT.HHGHDG(13).OR.
     &     VW.LE.0.OR.VW.GT.VHGHDG(13)) THEN
          CALL DWRT('Set pointer to center of window to be selected.#')
          RETURN
        END IF
        IF(     VW.GT.VMINDG(13)) THEN
C         ............................................. virtual windows 7,8,9
          IF(A1.EQ.'C'.OR.A1.EQ.'G') THEN
            DH=(HHGHDG(13)-HMINDG(13))/3.
            HH=HMINDG(13)
            DO N=7,9
              HH=HH+DH
              IF(HW.LT.HH) THEN
                A=A1//T789(N)
                GO TO 5
              END IF
            END DO
C           ....... nyes = false is right, to go in doper into the right loop.
          END IF
          RETURN
        ELSE IF(VW.GT.VHGHDG(0)-DVIRT) THEN
          NAR=0
        ELSE 
          DMIN=9999999.
          DO K=1,12
            HC=0.5*(HMINDG(K)+HHGHDG(K))
            VC=0.5*(VMINDG(K)+VHGHDG(K))
            D=(HC-HW)**2+(VC-VW)**2
            IF(D.LT.DMIN) THEN
              NAR=K
              DMIN=D
            END IF
          END DO
        END IF
        NYES=.TRUE.
        A(2:2)=TWINDW(NAR)
    5   CALL DWR_BACKSPACE_SLASH(NLET)
        CALL DWR_ADD(A)
        RETURN
      END IF
      IF(A1.EQ.'W'.AND.NOF.LE.0) RETURN
      IF(A1.EQ.'W') THEN
        IF(     A.EQ.'W+'.OR.A.EQ.'w+') THEN
          IAREDO=IAREDO+1
          IF(IAREDO.GT.12) IAREDO=0
          NYES=.TRUE.
          RETURN
        ELSE IF(A.EQ.'W-'.OR.A.EQ.'w-') THEN
          IAREDO=IAREDO-1
          IF(IAREDO.LT.0) IAREDO=12
          NYES=.TRUE.
          RETURN
        ELSE IF(A.EQ.'W%'.OR.A.EQ.'w%') THEN
          IAREDO=IWCH(IAREDO)
          NYES=.TRUE.
          RETURN
        END IF
      END IF
      IF(A(1:1).NE.A1) RETURN
      DO N=N1,N2
        IF(A(2:2).EQ.TWINDW(N)) THEN
          NAR=N
          NYES=.TRUE.
          RETURN
        END IF
      END DO
      RETURN
CH..............---
CH
CH
CH
CH
CH
CH
CH --------------------------------------------------------------------  DAREAS
CH
      ENTRY DAREAW(IWOF)
CH
CH --------------------------------------------------------------------
CH
C     Switch off on window selection in DOPER.
      NOF=IWOF
      END
*DK DASHYP
CH..............***
CH
CH
CH
CH
CH
CH
CH ********************************************************************  DASHYP
CH
      FUNCTION DASHYP(A)
CH
CH ********************************************************************
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C!:
C    Inputs    :
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
      DASHYP=ALOG(A+SQRT(A**2+1))
      RETURN
      END
*DK D3MIX
CH..............***
CH
CH
CH
CH
CH
CH
CH ********************************************************************  D3MIX
CH
      FUNCTION D3MIX(F,D)
CH
CH ********************************************************************
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C!:  D3MIX=MIN(MAX(F(1),F(2)+D),F(3))
C    Inputs    : F(1)=MINIMUM , F(2)=VALUE , F(3)= MAXIMUM
C    Outputs   : D3MIX
C
C ---------------------------------------------------------------------
      DIMENSION F(3)
      D3MIX=MIN(MAX(F(1),F(2)+D),F(3))
      RETURN
      END
*DK DAPPE
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DAPPE
CH
      SUBROUTINE DAPPE(TPR)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C_CG 11-May-1989   C.Grab  Adapted to CERNVM
C
C!:
C    DRAW ECAL HITS IN ALL PROJECTIONS
C ---------------------------------------------------------------------
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      DIMENSION HM(5),VM(5),HW(5),VW(5),VO(5)
      DATA SHRNK/.8/
      DIMENSION QXY(3,2)
C      DATA QXY/0.974, 0.966, 0.968,
C     &         1.052, 1.068, 1.074/
C     ...... QXY(3,2) is set experimentally to 1.074 to get hits long enough.
      DIMENSION Z1(3),Z2(3),R1(3),R2(3),Y(-1:1)
C     253,267,282,301
      DATA Z1/253.,269.,284./
      DATA Z2/265.,280.,301./
      DATA T180/180./,SMALL/1./
C     186,197,213,235
      DATA R1/190.,200.,215./
      DATA R2/196.,211.,230./
      CHARACTER *2 TPR
      CHARACTER *4 TST
      DIMENSION ICAR(8)
      LOGICAL FOUT,FREAL
      EQUIVALENCE (KPIKDP,K)
      DATA F180/180./,FOVER/40./,NFISH/2/
      CALL DV0(ESDADB,NUM1,NUM2,FOUT)
      IF(FOUT) RETURN
      IF(NFISH.GE.0) CALL DGFISH(NFISH)
      CALL DCUTFT(FS1,FS2,FC1,FC2,TS1,TS2,TC1,TC2)
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TSUBDJ='DAPPE'
      TPARDA=
     &  'J_PFY,J_PFI,J_PTE,J_PTO'
      CALL DPARAM(11
     &  ,J_PFY,J_PFI,J_PTE,J_PTO)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      FIMID=PARADA(2,J_PFI)
      IF(IZOMDO.EQ.0) THEN
        FIM=180.
      ELSE
        FIM=FIMID
      END IF
      TEMID=PARADA(2,J_PTE)
      IF     (TPR.EQ.'YX') THEN
        NPR=1
        CALL DPAR_GET_REAL(82,'QXY',6,QXY)
      ELSE IF(TPR.EQ.'RZ') THEN
        IF(PARADA(4,J_PTE).NE.0.) THEN
C         ...................................... SIGNED RHO
          FMIN=FIMID-90.
          FMAX=FIMID+90.
        ELSE
C         ...................................... POSITIVE RHO
          FMIN=-1024.
          FMAX= 1024.
        END IF
        QPI=1./PIFCDK
        IF(REALDU.GT.0.) THEN
          FREAL=.TRUE.
        ELSE
          FREAL=.FALSE.
        END IF
        NPR=2
      ELSE IF(TPR.EQ.'FR') THEN
        CALL DPAR_GET_REAL(82,'QXY',6,QXY)
        NPR=3
      ELSE IF(TPR.EQ.'FZ') THEN
        NPR=4
      ELSE IF(TPR.EQ.'YZ') THEN
        CALL DPARGV(82,'QYZ',2,QYZ)
        SF=SIND(PARADA(2,J_PFY))
        CF=COSD(PARADA(2,J_PFY))
        NPR=5
      END IF
      QPI=SHRNK/PIFCDK
      IF(IZOMDO.EQ.0) THEN
        TST='AREA'
      ELSE
        SCAL=MAX(ABS(AHSCDQ),ABS(AVSCDQ),ABS(BHSCDQ),ABS(BVSCDQ))
        IF(SCAL.LT.SMALL.AND.PARADA(2,J_PTO).GT.T180) THEN
          TST='AREA'
        ELSE
          TST='AR+L'
        END IF
      END IF
      CALL DSET_ECAL_COL(MODE,NUCOL,ICCN,ICAR)
      CALL DPAR_SET_CO(53,'CFR')
      LFRA=MAX(1,ICOLDP)
C     .............................. 1 loop only for: pick, frames
      IF(FPIKDP.OR.
     &  ( (.NOT.FMONDT).AND.ICOLDP.GE.0..AND.TST.EQ.'AREA') ) THEN
        CALL DQPO0('AREA',ICOLDP,0,' ')
        DO 200 K=NUM1,NUM2
          CALL DCUTEC(K,FOUT)
          IF(FOUT) GO TO 200
          TE=DVEC(IVTEDV,K)
          IF(TE.LT.TC1.OR.TE.GT.TC2) GO TO 200
          FI=DFINXT(FIMID,DVEC(IVFIDV,K))
          IF(FI.LT.FC1.OR.FI.GT.FC2) GO TO 200
          JJ=DVEC(IVJJDV,K)
          KK=DVEC(IVKKDV,K)
C                XY  RZ  FR  FZ  YZ
          GO TO(210,220,230,240,250), NPR
C         ............................................................ XY
  210     IF(JJ.LT.51.OR.JJ.GT.178) GO TO 200
          H=DVEC(IVXXDV,K)
          V=DVEC(IVYYDV,K)
          DF=DVEC(IVDFDV,K)
          D=DVEC(IVRODV,K)*DF*QPI
          FI30=FLOAT((IFIX(DVEC(IVFIDV,K)+2.)/30)*30+13)
          DH=D*SIND(FI30)
          DV=D*COSD(FI30)
          HM(1)=(H-DH)*QXY(KK,1)
          HM(2)=(H+DH)*QXY(KK,1)
          VM(1)=(V+DV)*QXY(KK,1)
          VM(2)=(V-DV)*QXY(KK,1)
          HM(3)=HM(2)*QXY(KK,2)
          VM(3)=VM(2)*QXY(KK,2)
          HM(4)=HM(1)*QXY(KK,2)
          VM(4)=VM(1)*QXY(KK,2)
          GO TO 290
C         ............................................................ RZ
  220     IF(FI.GE.FMIN.AND.FI.LE.FMAX) THEN
            SIG= 1.
          ELSE
            SIG=-1.
          END IF
          IF(FREAL) THEN
            DT=DVEC(IVDTDV,K)
          ELSE
            CALL=DVEC2(JJ,KK)
            TE=DVEC(IVTEDV,-1)
            DT=DVEC(IVDTDV,-1)
          END IF
          T1=TAND(TE-DT)
          T2=TAND(TE+DT)
          IF(JJ.LT.51) THEN
C           ............................................... RIGHT ENDCAP (Z>0)
            ZZ1=Z1(KK)
            ZZ2=Z2(KK)
            GO TO 221
          ELSE IF(JJ.GT.178) THEN
C           ............................................... LEFT ENDCAP (Z<0)
            ZZ1=-Z1(KK)
            ZZ2=-Z2(KK)
            GO TO 221
          ELSE
C           ............................................... BARREL
            T1=1./T1
            T2=1./T2
            HM(1)=R1(KK)*T1
            HM(2)=R1(KK)*T2
            HM(3)=R2(KK)*T2
            HM(4)=R2(KK)*T1
            VM(1)=SIG*R1(KK)
            VM(2)=VM(1)
            VM(3)=SIG*R2(KK)
            VM(4)=VM(3)
          END IF
          GO TO 290
C         ............................................... BOTH ENCAPS
  221     T1=T1*SIG
          T2=T2*SIG
          HM(1)=ZZ1
          HM(2)=ZZ2
          HM(3)=ZZ2
          HM(4)=ZZ1
          VM(1)=ZZ1*T1
          VM(2)=ZZ2*T1
          VM(3)=ZZ2*T2
          VM(4)=ZZ1*T2
          GO TO 290
C         ............................................................ FR
  230     IF(JJ.LT.51.OR.JJ.GT.178) GO TO 200
          H=DVEC(IVXXDV,K)
          V=DVEC(IVYYDV,K)
          DF=DVEC(IVDFDV,K)
          D=DVEC(IVRODV,K)*DF*QPI
          FI30=FLOAT((IFIX(DVEC(IVFIDV,K)+2.)/30)*30+13)
          DH=D*SIND(FI30)
          DV=D*COSD(FI30)
          HW(1)=(H-DH)*QXY(KK,1)
          HW(2)=(H+DH)*QXY(KK,1)
          VW(1)=(V+DV)*QXY(KK,1)
          VW(2)=(V-DV)*QXY(KK,1)
          HW(3)=HW(2)*QXY(KK,2)
          VW(3)=VW(2)*QXY(KK,2)
          HW(4)=HW(1)*QXY(KK,2)
          VW(4)=VW(1)*QXY(KK,2)
          IF(IZOMDO.EQ.0) THEN
            FIM=F180
          ELSE
            FIM=FI
          END IF
          DO I=1,4
            HM(I)=SQRT(HW(I)*HW(I)+VW(I)*VW(I))
            VM(I)=ATAN2(VW(I),HW(I))*PIFCDK
            VM(I)=DFINXT(FIM,VM(I))
            VO(I)=VM(I)+360.
          END DO
          GO TO 280
C         ............................................................ FZ
  240     IF(JJ.LT.51) THEN
C           ............................................... RIGHT ENDCAP (Z>0)
            ZZ1=Z1(KK)
            ZZ2=Z2(KK)
          ELSE IF(JJ.GT.178) THEN
C           ............................................... LEFT ENDCAP (Z<0)
            ZZ1=-Z1(KK)
            ZZ2=-Z2(KK)
          ELSE
            GO TO 200
          END IF
C         ............................................... BOTH ENCAPS
          HM(1)=ZZ1
          HM(2)=ZZ2
          HM(3)=ZZ2
          HM(4)=ZZ1
          DF=DVEC(IVDFDV,K)
          D=DF*SHRNK
          IF(IZOMDO.EQ.0) FI=DFINXT(F180,FI)
          VM(1)=FI-D
          VM(2)=VM(1)
          VM(3)=FI+D
          VM(4)=VM(3)
          IF(IZOMDO.EQ.0) THEN
            DO I=1,4
              VO(I)=VM(I)+360.
            END DO
          END IF
          GO TO 290
C         ............................................................ YZ
  250     IF(JJ.LT.51) THEN
C           ............................................... RIGHT ENDCAP (Z>0)
            ZZ1=Z1(KK)
            ZZ2=Z2(KK)
          ELSE IF(JJ.GT.178) THEN
C           ............................................... LEFT ENDCAP (Z<0)
            ZZ1=-Z1(KK)
            ZZ2=-Z2(KK)
          ELSE
            GO TO 200
          END IF
C         ............................................... BOTH ENCAPS
          HM(1)=ZZ1
          HM(2)=ZZ2
          HM(3)=ZZ2
          HM(4)=ZZ1
          II=DVEC(IVIIDV,K)
          DO I=-1,1
            CALL=DVEC1(II+I,JJ,KK)
            Y(I)=-SF*DVEC(IVXXDV,-1)+CF*DVEC(IVYYDV,-1)
          END DO
          Z=DVEC(IVZZDV,K)
          VY1=Y(0)+QYZ*(Y(0)-Y(-1))
          VY2=Y(0)+QYZ*(Y(0)-Y( 1))
          VM(1)=VY1*ZZ1/Z
          VM(2)=VY1*ZZ2/Z
          VM(3)=VY2*ZZ2/Z
          VM(4)=VY2*ZZ1/Z
          GO TO 290
  280     IF(FPIKDP) THEN
            HPIK=0.5*(HM(1)+HM(3))
            VPIK=0.5*(VM(1)+VM(3))
            CALL DQPIF(HPIK,VPIK)
            GO TO 200
          END IF
          CALL DQPOLF(HM,VM)
          IF(IZOMDO.EQ.0.AND.FI.LT.FOVER) CALL DQPOLF(HM,VO)
          GO TO 200
  290     IF(FPIKDP) THEN
            HPIK=0.5*(HM(1)+HM(3))
            VPIK=0.5*(VM(1)+VM(3))
            CALL DQPIK(HPIK,VPIK)
            GO TO 200
          END IF
          CALL DQPOLF(HM,VM)
  200   CONTINUE
        IF(FPIKDP) RETURN
      END IF
C     ........................................................ COLOR LOOP
      IF(ICCN.GE.0) CALL DQPO0(TST,ICCN,LFRA,' ')
      DO 2 L=1,NUCOL
C       ..................................... MODE =-1 : COLOR=LAYER
C       ..................................... MODE = 0 : COLOR=CONSTANT
C       ..................................... MODE = 1 : COLOR=ENERGY
        IF(MODE.EQ.1) CALL DQPO0(TST,ICAR(L),LFRA,' ')
        DO 300 K=NUM1,NUM2
          IF(MODE)301,302,303
  301     CALL DQPO0(TST,ICAR(NCECDC(K)),LFRA,' ')
          GO TO 302
  303     IF(NCECDC(K).NE.L) GO TO 300
  302     CALL DCUTEC(K,FOUT)
          IF(FOUT) GO TO 300
          KK=DVEC(IVKKDV,K)
          TE=DVEC(IVTEDV,K)
          IF(TE.LT.TC1.OR.TE.GT.TC2) GO TO 300
          FI=DFINXT(FIMID,DVEC(IVFIDV,K))
          IF(FI.LT.FC1.OR.FI.GT.FC2) GO TO 300
          JJ=DVEC(IVJJDV,K)
C                XY RZ FR FZ YZ
          GO TO (310,320,330,340,350), NPR
C         ............................................................ XY
  310     IF(JJ.LT.51.OR.JJ.GT.178) GO TO 300
          H=DVEC(IVXXDV,K)
          V=DVEC(IVYYDV,K)
          DF=DVEC(IVDFDV,K)
          D=DVEC(IVRODV,K)*DF*QPI
          FI30=FLOAT((IFIX(DVEC(IVFIDV,K)+2.)/30)*30+13)
          DH=D*SIND(FI30)
          DV=D*COSD(FI30)
          HM(1)=(H-DH)*QXY(KK,1)
          HM(2)=(H+DH)*QXY(KK,1)
          VM(1)=(V+DV)*QXY(KK,1)
          VM(2)=(V-DV)*QXY(KK,1)
          HM(3)=HM(2)*QXY(KK,2)
          VM(3)=VM(2)*QXY(KK,2)
          HM(4)=HM(1)*QXY(KK,2)
          VM(4)=VM(1)*QXY(KK,2)
          GO TO 390
C         ............................................................ RZ
  320     IF(FI.GE.FMIN.AND.FI.LE.FMAX) THEN
            SIG= 1.
          ELSE
            SIG=-1.
          END IF
          IF(FREAL) THEN
            DT=DVEC(IVDTDV,K)
          ELSE
            CALL=DVEC2(JJ,KK)
            TE=DVEC(IVTEDV,-1)
            DT=DVEC(IVDTDV,-1)
          END IF
          T1=TAND(TE-DT)
          T2=TAND(TE+DT)
          IF(JJ.LT.51) THEN
C           ............................................... RIGHT ENDCAP (Z>0)
            ZZ1=Z1(KK)
            ZZ2=Z2(KK)
            GO TO 321
          ELSE IF(JJ.GT.178) THEN
C           ............................................... LEFT ENDCAP (Z<0)
            ZZ1=-Z1(KK)
            ZZ2=-Z2(KK)
            GO TO 321
          ELSE
C           ............................................... BARREL
            T1=1./T1
            T2=1./T2
            HM(1)=R1(KK)*T1
            HM(2)=R1(KK)*T2
            HM(3)=R2(KK)*T2
            HM(4)=R2(KK)*T1
            VM(1)=SIG*R1(KK)
            VM(2)=VM(1)
            VM(3)=SIG*R2(KK)
            VM(4)=VM(3)
          END IF
          GO TO 390
C         ............................................... BOTH ENCAPS
  321     T1=T1*SIG
          T2=T2*SIG
          HM(1)=ZZ1
          HM(2)=ZZ2
          HM(3)=ZZ2
          HM(4)=ZZ1
          VM(1)=ZZ1*T1
          VM(2)=ZZ2*T1
          VM(3)=ZZ2*T2
          VM(4)=ZZ1*T2
          GO TO 390
C         ............................................................ FR
  330     IF(JJ.LT.51.OR.JJ.GT.178) GO TO 300
          H=DVEC(IVXXDV,K)
          V=DVEC(IVYYDV,K)
          DF=DVEC(IVDFDV,K)
          D=DVEC(IVRODV,K)*DF*QPI
          FI30=FLOAT((IFIX(DVEC(IVFIDV,K)+2.)/30)*30+13)
          IF(IZOMDO.EQ.0) FI30=DFINXT(F180,FI30)
          DH=D*SIND(FI30)
          DV=D*COSD(FI30)
          HW(1)=(H-DH)*QXY(KK,1)
          HW(2)=(H+DH)*QXY(KK,1)
          VW(1)=(V+DV)*QXY(KK,1)
          VW(2)=(V-DV)*QXY(KK,1)
          HW(3)=HW(2)*QXY(KK,2)
          VW(3)=VW(2)*QXY(KK,2)
          HW(4)=HW(1)*QXY(KK,2)
          VW(4)=VW(1)*QXY(KK,2)
          IF(IZOMDO.EQ.0) THEN
            FIM=F180
          ELSE
            FIM=FI
          END IF
          DO I=1,4
            HM(I)=SQRT(HW(I)*HW(I)+VW(I)*VW(I))
            VM(I)=ATAN2(VW(I),HW(I))*PIFCDK
            VM(I)=DFINXT(FIM,VM(I))
            VO(I)=VM(I)+360.
          END DO
          GO TO 380
C         ............................................................ FZ
  340     IF(JJ.LT.51) THEN
C           ............................................... RIGHT ENDCAP (Z>0)
            ZZ1=Z1(KK)
            ZZ2=Z2(KK)
          ELSE IF(JJ.GT.178) THEN
C           ............................................... LEFT ENDCAP (Z<0)
            ZZ1=-Z1(KK)
            ZZ2=-Z2(KK)
          ELSE
            GO TO 300
          END IF
C         ............................................... BOTH ENCAPS
          HM(1)=ZZ1
          HM(2)=ZZ2
          HM(3)=ZZ2
          HM(4)=ZZ1
          DF=DVEC(IVDFDV,K)
          D=DF*SHRNK
          IF(IZOMDO.EQ.0) FI=DFINXT(F180,FI)
          VM(1)=FI-D
          VM(2)=VM(1)
          VM(3)=FI+D
          VM(4)=VM(3)
          IF(IZOMDO.EQ.0) THEN
            DO I=1,4
              VO(I)=VM(I)+360.
            END DO
          END IF
          GO TO 390
C         ............................................................ YZ
  350     IF(JJ.LT.51) THEN
C           ............................................... RIGHT ENDCAP (Z>0)
            ZZ1=Z1(KK)
            ZZ2=Z2(KK)
          ELSE IF(JJ.GT.178) THEN
C           ............................................... LEFT ENDCAP (Z<0)
            ZZ1=-Z1(KK)
            ZZ2=-Z2(KK)
          ELSE
            GO TO 300
          END IF
C         ............................................... BOTH ENCAPS
          HM(1)=ZZ1
          HM(2)=ZZ2
          HM(3)=ZZ2
          HM(4)=ZZ1
          II=DVEC(IVIIDV,K)
          DO I=-1,1
            CALL=DVEC1(II+I,JJ,KK)
            Y(I)=-SF*DVEC(IVXXDV,-1)+CF*DVEC(IVYYDV,-1)
          END DO
          Z=DVEC(IVZZDV,K)
          VY1=Y(0)+QYZ*(Y(0)-Y(-1))
          VY2=Y(0)+QYZ*(Y(0)-Y( 1))
          VM(1)=VY1*ZZ1/Z
          VM(2)=VY1*ZZ2/Z
          VM(3)=VY2*ZZ2/Z
          VM(4)=VY2*ZZ1/Z
          GO TO 390
  380     HM(5)=HM(1)
          VM(5)=VM(1)
          VO(5)=VO(1)
          CALL DQPOL(5,HM,VM)
          IF(IZOMDO.EQ.0.AND.FI.LT.FOVER) CALL DQPOL(5,HM,VO)
          GO TO 300
  390     HM(5)=HM(1)
          VM(5)=VM(1)
          CALL DQPOL(5,HM,VM)
  300   CONTINUE
    2 CONTINUE
      IF(TPR.EQ.'RZ') CALL DGDERZ(PARADA(4,J_PTE))
      END
*DK DAPEO
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DAPEO
CH
      SUBROUTINE DAPEO(TPR)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C!:Draw points of fitted coordinates in All Projections
C    Inputs    :
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      DIMENSION ICOL(8)
C               WH RE GR BL OR CY MG YE
      DIMENSION R1(2),R2(2),Z1(2),Z2(2)
      DATA R1,R2/0.,177.,184.,229./,Z1,Z2/0.,220.,251.,303./
      DATA FCOR/2./
      CHARACTER *2 TPR
      CHARACTER *3 DT3,T3
      CHARACTER * 40 TEOB
      CHARACTER * 7 TBAR,TEND
      DATA TEOB /'Ecal ojects are drawn if they ly in the '/
      DATA TBAR /'barrel.'/
      DATA TEND /'endcap.'/
      DATA SC/50./,T36/38./,T144/142./,N1/1/,N3/3/
      DATA DRSET/0.5/,PFAC/6./,N16/16/
      DATA D90/90./,FOVER/40./
      DIMENSION JFR(6),JTO(6)
      DATA JFR/1,1,1,2,2,2/
      DATA JTO/1,2,2,1,2,2/
      DATA IDEB,MDEB/0,0/
      EQUIVALENCE (KPIKDP,K)
      LOGICAL FOUT,FUSFI,FUSTE,FCHIM,FV
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TSUBDJ='DAPEO'
      TPARDA=
     &  'J_PFY,J_PFI,J_PTE,J_PHI,J_RAL'
      CALL DPARAM(10
     &  ,J_PFY,J_PFI,J_PTE,J_PHI,J_RAL)

      TPARDA=
     &  'J_HEO,J_HCN'
      CALL DPARAM(20
     &  ,J_HEO,J_HCN)

      TPARDA=
     &  'J_SVS,J_SSZ,J_SSS,J_SWI'
      CALL DPARAM(69
     &  ,J_SVS,J_SSZ,J_SSS,J_SWI)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      IF(TPR.EQ.'FT'.OR.TPR.EQ.'CH') THEN
        FECADR=.TRUE.
      ELSE IF(TPR.EQ.'RO') THEN
        FECADR=.TRUE.
        IF(PARADA(4,J_HEO).NE.1.) RETURN
      ELSE
        IF(PARADA(4,J_HEO).NE.1.) RETURN
      END IF
      CALL DV0(PECODB,NUM1,NUM2,FOUT)
      IF(FOUT) RETURN
      MOSY=PARADA(2,J_SVS)
      CALL DCUTTF(FUSFI,FC1,FC2,FUSTE,TC1,TC2)
      FIMID=PARADA(2,J_PFI)
      TEMID=PARADA(2,J_PTE)
      NEO=PARADA(2,J_HEO)
      NFR=JFR(NEO)
      NTO=JTO(NEO)
C     ..................................................... SET UP PROJECTIONS
      IF     (TPR.EQ.'YX') THEN
        IF((.NOT.FPIKDP).OR.FPIMDP) CALL DWRT(TEOB//TBAR)
        NPR=1
      ELSE IF(TPR.EQ.'RZ') THEN
        IF(PARADA(4,J_PTE).NE.0.) THEN
          FMIN=FIMID-90.
          FMAX=FIMID+90.
        ELSE
          FMIN=-999.
          FMAX= 999.
        END IF
        NPR=2
        RC=R2(NTO)
        IF(NTO.EQ.2) RC=RC/COSD(15.)
      ELSE IF(TPR.EQ.'FT'.AND.MOSY.EQ.2) THEN
        FCHIM=.FALSE.
C//     CALL DQSQ0(WDSNDL(2,5,MECADL)*ECSQDU,SHTFDU)
        CALL DQSQ0(PARADA(2,J_SSS)*ECSQDU,SHTFDU)
        NPR=3
      ELSE IF(TPR.EQ.'FT'.OR.TPR.EQ.'CH') THEN
        FCHIM=.TRUE.
        QE=PARADA(2,J_PHI)*ECCHDU
C//     CALL DQCH0(QE,WDSNDL(2,7,MECADL))
        CALL DQCH0(QE,PARADA(2,J_SWI))
        T3=DT3(SC/QE)
        CALL DGLEVL(8)
        CALL DQSCE(T3//'Gev EO',9,SC)
        SCALDS(IAREDO,MSECDS)=QE
        NPR=3
      ELSE IF(TPR.EQ.'FR') THEN
        IF((.NOT.FPIKDP).OR.FPIMDP) CALL DWRT(TEOB//TBAR)
        NPR=4
      ELSE IF(TPR.EQ.'FZ') THEN
        IF((.NOT.FPIKDP).OR.FPIMDP) CALL DWRT(TEOB//TEND)
        NPR=5
      ELSE IF(TPR.EQ.'YZ') THEN
        IF((.NOT.FPIKDP).OR.FPIMDP) CALL DWRT(TEOB//TEND)
        SF=SIND(PARADA(2,J_PFY))
        CF=COSD(PARADA(2,J_PFY))
        NPR=6
      ELSE IF(TPR.EQ.'RO') THEN
        SF=SIND(FIMID)
        CF=COSD(FIMID)
        ST=SIND(90.-PARADA(2,J_PTE))
        CT=COSD(90.-PARADA(2,J_PTE))
        SG=SIND(PARADA(2,J_RAL))
        CG=COSD(PARADA(2,J_RAL))
        CALL DQPOC(0.,0.,HD0,VD0,FOUT)
C//     CALL DQPD0(MIN(IDPAR(J_SSY),8)),WDSNDL(2,4,MTPCDL),0.)
        CALL DPAR_SET_SY(69,0.)
C//     DRSTP=WDSNDL(2,4,MTPCDL)*DRSET
        DRSTP=PARADA(2,J_SSZ)*DRSET
        NPR=8
      END IF
      IF(NPR.NE.3) CALL DPAR_SET_WIDTH(69,'SLI',0,' ')
      IF(FPIKDP) THEN
        MOCO=0
      ELSE
        CALL DSC_CONST(FV,NCOL)
        IF(NCOL.GE.0) THEN
          MOCO=0
        ELSE
          CALL DPARGI(70,'FEO',MOCO)
          IF(MOCO.EQ.0) THEN
C           ................................................ CONSTANT COLOR
            CALL DPAR_SET_CO(53,'CEO')
          ELSE IF(MOCO.EQ.1) THEN
C           ................................................ COLOR(ENERGY)
            CALL DPAR_GET_ARRAY(47,'CC1',8,ICOL)
            CALL DPARGV(70,'FFO',2,EFAC)
          ELSE IF(MOCO.EQ.2) THEN
C           ................................................ COLOR(CUT)
            CALL DPAR_GET_ARRAY(53,'CE1',2,ICOL)
            CALL DPARGV(70,'FCO',2,ENCUT)
          ELSE
C           ................................................ COLOR(NT)
            CALL DPARGI(46,'CNU',NUCOL)
            NUCOL=MIN(8,NUCOL)
            CALL DPAR_GET_ARRAY(46,'CC1',NUCOL,ICOL)
          END IF
        END IF
      END IF
C     ...................................................... LOOP OVER OBJECTS
      DO 200 K=NUM1,NUM2
        IF(NFR.EQ.1) THEN
          IDENT=DVEO(N16,K)
          IF(IDENT.EQ.N1.OR.IDENT.EQ.N3) GO TO 200
        END IF
        FI=DVEO(IVFIDV,K)
        TE=DVEO(IVTEDV,K)
        IF(TE.LT.TC1.OR.TE.GT.TC2) GO TO 200
        FC=DFINXT(FIMID,FI)
        IF(FC.LT.FC1.OR.FC.GT.FC2) GO TO 200
        E=DVEO(IVENDV,K)
        IF(PARADA(4,J_HCN).EQ.1.) THEN
          ECUT=PARADA(2,J_HCN)
          IF(     ECUT.GT.0.) THEN
            IF(E.LT. ECUT) GO TO 200
          ELSE IF(ECUT.LT.0.) THEN
            IF(E.GT.-ECUT) GO TO 200
          END IF
        END IF
        IF(MOCO.EQ.1) THEN
          CALL DSCLOG(E,EFAC,ICOL,NCOL)
          CALL DGLEVL(NCOL)
        ELSE IF(MOCO.EQ.2) THEN
          IF(E.LT.ENCUT) THEN
            CALL DGLEVL(ICOL(1))
          ELSE
            CALL DGLEVL(ICOL(2))
          END IF
        ELSE IF(MOCO.EQ.3) THEN
          NCOL=ICOL(1+MOD(K,NUCOL))
          CALL DGLEVL(NCOL)
        END IF
        GO TO (201,202,203,204,205,206,201,208) NPR
C        ................................................................. YX
  201   IF(TE.LT.T36.OR.TE.GT.T144) THEN
          IF(NFR.NE.1.OR.NTO.NE.1) GO TO 200
          RC=Z1(2)*ABS(TAND(TE))
        ELSE
          FS=MOD(FI+FCOR,30.)-15.
          RC=R2(NTO)/COSD(FS)
        END IF
        CF=COSD(FI)
        SF=SIND(FI)
        H1=R1(NFR)*CF
        V1=R1(NFR)*SF
        H2=RC*CF
        V2=RC*SF
        GO TO 280
C         ...................................................... RZ(SIGNED RHO)
  202   IF(TE.LT.T36)THEN
          H1=Z1(NFR)
          H2=Z2(NTO)
          TT=TAND(TE)
          V1=H1*TT
          V2=H2*TT
        ELSE IF(TE.GT.T144) THEN
          H1=-Z1(NFR)
          H2=-Z2(NTO)
          TT=TAND(TE)
          V1=H1*TT
          V2=H2*TT
        ELSE
          V1=R1(NFR)
          V2=RC
          TT=COSD(TE)/SIND(TE)
          H1=V1*TT
          H2=V2*TT
        END IF
        IF(FI.LT.FMIN.OR.FI.GT.FMAX) THEN
          V1=-V1
          V2=-V2
        END IF
        GO TO 280
C       ................................................................. FT
  203   H=-TE
        IF(FPIKDP) THEN
          CALL DQPIF(H,FI)
        ELSE
          IF(FCHIM) THEN
            CALL DQCH(H,FI,E)
            IF(IZOMDO.EQ.0) CALL DQCH(H,FI+360.,E)
          ELSE
            IF(MDEB.EQ.0) THEN
              CALL DQSR(H,FI,E)
              IF(IZOMDO.EQ.0.AND.FI.LT.FOVER)
     &          CALL DQSR(H,FI+360.,E)
            ELSE
              CALL DQSQ(H,FI,E,D90,D90)
              IF(IZOMDO.EQ.0.AND.FI.LT.FOVER)
     &          CALL DQSQ(H,FI+360.,E,D90,D90)
            END IF
          END IF
        END IF
        GO TO 200
C       ................................................................. FR
  204   IF(TE.LT.T36.OR.TE.GT.T144) THEN
          IF(NFR.NE.1.OR.NTO.NE.1) GO TO 200
          H2=Z1(2)*ABS(TAND(TE))
        ELSE
          FS=MOD(FI+FCOR,30.)-15.
          H2=R2(NTO)/COSD(FS)
        END IF
        H1=R1(NFR)
        GO TO 270
C       ................................................................. FZ
  205   IF(TE.GE.T36.AND.TE.LE.T144) GO TO 200
        IF(TE.LT.90.) THEN
          H1=Z1(NFR)
          H2=Z2(NTO)
        ELSE
          H1=-Z1(NFR)
          H2=-Z2(NTO)
        END IF
        GO TO 270
C       ................................................................. YZ
  206   IF(TE.GE.T36.AND.TE.LE.T144) GO TO 200
        IF(TE.LT.90.) THEN
          H1=Z1(NFR)
          H2=Z2(NTO)
        ELSE
          H1=-Z1(NFR)
          H2=-Z2(NTO)
        END IF
        R=SIND(TE)
        Z=COSD(TE)
        X=R*COSD(FI)
        Y=R*SIND(FI)
        V=-SF*X+CF*Y
        QVZ=V/Z
        V1=QVZ*H1
        V2=QVZ*H2
        GO TO 280
CC        ................................................................. PP
C  207   IF(TE.LT.T36.OR.TE.GT.T144) GO TO 200
C        FS=MOD(FI+FCOR,30.)-15.
C        RC=R2(NTO)/COSD(FS)
C        CF=COSD(FI)
C        SF=SIND(FI)
C        H1=R1(NFR)*CF
C        V1=R1(NFR)*SF
C        H2=RC*CF
C        V2=RC*SF
C        CALL DPERS(H1,V1)
C        CALL DPERS(H2,V2)
C        GO TO 280
C       .................................................. RO: MOMENTUM VECTOR
  208   E=DVEO(IVENDV,K)*PFAC
        RO=E*SIND(TE)
        Z0=E*COSD(TE)
        Y0=RO*SIND(FI)
        X0=RO*COSD(FI)
        X2= CF*X0+SF*Y0
        Y2=-SF*X0+CF*Y0
        H = CT*X2+ST*Z0
        Z3=-ST*X2+CT*Z0
        V = CG*Y2+SG*Z3
        IF(IDEB.NE.0) THEN
          CALL DQL2E(0.,0.,H,V)
          GO TO 200
        END IF
        DU=SQRT(H*H+V*V)
        IF(DU.GT.0.) THEN
          CALL DQPOC(H,V,HD,VD,FOUT)
          DHD=HD-HD0
          DVD=VD-VD0
          DD=SQRT(DHD*DHD+DVD*DVD)
          JPO=DD/DRSTP
          IF(JPO.GE.1) THEN
            QRO=DRSTP/DD
            DHU=H*QRO
            DVU=V*QRO
            DRU=DU*QRO
            HRO=DHU
            VRO=DVU
            DO 708 J=1,JPO
              IF(FPIKDP) THEN
                CALL DQPIK(HRO,VRO)
              ELSE
                CALL DQPD(HRO,VRO)
              END IF
              HRO=HRO+DHU
              VRO=VRO+DVU
  708       CONTINUE
          END IF
        END IF
        GO TO 200
C       ........................................................ VERTICAL = FI
  270   IF(FPIKDP) THEN
          CALL DQPIF(H1,FI)
          CALL DQPIF(H2,FI)
        ELSE
          CALL DQL2E(H1,FI,H2,FI)
          IF(IZOMDO.EQ.0) CALL DQL2E(H1,FI+360.,H2,FI+360.)
        END IF
        GO TO 200
C       ............................................................... OTHERS
  280   IF(FPIKDP) THEN
          IF(NFR.EQ.2) CALL DQPIK(H1,V1)
          CALL DQPIK(H2,V2)
        ELSE
          CALL DQL2E(H1,V1,H2,V2)
        END IF
  200 CONTINUE
      CALL DPAR_SET_TR_WIDTH
      END
*DK DAPEF
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DAPEF
CH
      SUBROUTINE DAPEF(TPR)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C!:Draw points of fitted coordinates in All Projections
C    Inputs    :
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      DIMENSION ICOL(8)
C               WH RE GR BL OR CY MG YE
      DIMENSION RA(0:4),ZA(0:4)
C             0   T3   E0   E3   H1
      DATA RA/0.,178.,185.,237.,298./
      DATA ZA/0.,220.,252.,303.,365./

      DATA FCOR/2./
      CHARACTER *2 TPR
      CHARACTER *3 DT3,T3
      CHARACTER *1 TEF(0:8)
      DATA TEF/4*' ','X','0',3*'-'/
      DATA SC/50./,T38/38./,T142/142./,N1/1/,N3/3/
      DATA TBAR1/ 40./,TECP1/ 45./
      DATA TBAR2/140./,TECP2/135./
      DATA DRSET/0.5/,PFAC/6./,N16/16/
      DATA DHTX/-7./,DVTX/0./
      DATA D90/90./,FOVER/40./
      DIMENSION JFR(6),JTO(6)
      DATA JFR/0,0,0,1,1,1/
      DATA JTO/2,3,4,2,3,4/
      DATA IDEB,MDEB/0,0/
      EQUIVALENCE (KPIKDP,K)
      LOGICAL FOUT,FUSFI,FUSTE,FCHIM
      IF(FMISDA) CALL DAC_DRAW_MISSING_VECTOR(TPR)
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TSUBDJ='DAPEF'
      TPARDA=
     &  'J_PFY,J_PFI,J_PTE,J_PHI,J_RAL'
      CALL DPARAM(10
     &  ,J_PFY,J_PFI,J_PTE,J_PHI,J_RAL)

      TPARDA=
     &  'J_HEO,J_HCN'
      CALL DPARAM(20
     &  ,J_HEO,J_HCN)

      TPARDA=
     &  'J_SVS,J_SSZ,J_SSS'
      CALL DPARAM(69
     &  ,J_SVS,J_SSZ,J_SSS)

      TPARDA=
     &  'J_SWI'
      CALL DPARAM(68
     &  ,J_SWI)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      IF(PARADA(4,J_HEO).NE.2.) RETURN
      MDLRDP=7000
      CALL DV_QVEC_IN(NFSTDA,NLSTDA)
      IF(NFSTDA(5).EQ.0.OR.NFSTDA(5).GT.NLSTDA(5)) RETURN
      IF(FPIMDP) THEN
        IF((MDLPDP.NE.7000.AND.MDLPDP.NE.7001).OR.
     &    NPIKDP.LT.NFSTDA(5).OR.
     &    NPIKDP.GT.NLSTDA(5)) RETURN
        NUM1=NPIKDP
        NUM2=NPIKDP
      ELSE
        NUM1=NFSTDA(5)
        NUM2=NLSTDA(5)
      END IF
      MOSY=PARADA(2,J_SVS)
      CALL DCUTTF(FUSFI,FC1,FC2,FUSTE,TC1,TC2)
      FIMID=PARADA(2,J_PFI)
      TEMID=PARADA(2,J_PTE)
      NEO=PARADA(2,J_HEO)
C     ................. NE0                         NFR NTO
C     .................  1 = N1 from  0 to E0        0   2
C     .................  2 = N2 from  0 to E3        0   3
C     .................  3 = N3 from  0 to E0 or H1  0   4 E0 if type 4
C     .................  4 = S1 from T3 to E0        1   2
C     .................  5 = S2 from T3 to E3        1   3
C     .................  6 = S3 from T3 to E0 or H1  1   4 E0 if type 4
      NFR=JFR(NEO)
      NTO=JTO(NEO)
C     ..................................................... SET UP PROJECTIONS
      IF     (TPR.EQ.'YX') THEN
        NPR=1
      ELSE IF(TPR.EQ.'RZ') THEN
        IF(PARADA(4,J_PTE).NE.0.) THEN
          FMIN=FIMID-90.
          FMAX=FIMID+90.
        ELSE
          FMIN=-999.
          FMAX= 999.
        END IF
        NPR=2
C        RC=RA(NTO)
C        IF(NTO.EQ.2) RC=RC/COSD(15.)
      ELSE IF(TPR.EQ.'FT'.AND.MOSY.EQ.2) THEN
        FCHIM=.FALSE.
        CALL DQSQ0(PARADA(2,J_SSS)*ECSQDU,SHTFDU)
        NPR=3
      ELSE IF(TPR.EQ.'FT'.OR.TPR.EQ.'CH') THEN
        FCHIM=.TRUE.
        QE=PARADA(2,J_PHI)*ECCHDU
        CALL DQCH0(QE,PARADA(2,J_SWI))
        CALL DQTXT0(DHTX,DVTX)
        T3=DT3(SC/QE)
        CALL DGLEVL(8)
        CALL DQSCE(T3//'Gev EO',9,SC)
        SCALDS(IAREDO,MSECDS)=QE
        NPR=3
      ELSE IF(TPR.EQ.'FR') THEN
        NPR=4
      ELSE IF(TPR.EQ.'FZ') THEN
        NPR=5
      ELSE IF(TPR.EQ.'YZ') THEN
        SF=SIND(PARADA(2,J_PFY))
        CF=COSD(PARADA(2,J_PFY))
        NPR=6
      ELSE IF(TPR.EQ.'RO') THEN
        TPR=' '
        CALL DPARGV(15,'RSP',2,PFAC)
        SF=SIND(FIMID)
        CF=COSD(FIMID)
        ST=SIND(90.-PARADA(2,J_PTE))
        CT=COSD(90.-PARADA(2,J_PTE))
        SG=SIND(PARADA(2,J_RAL))
        CG=COSD(PARADA(2,J_RAL))
        CALL DQPOC(0.,0.,HD0,VD0,FOUT)
        NPR=8
      END IF
      IF(NPR.NE.3) CALL DPAR_SET_WIDTH(68,'SLI',0,' ')
      IF(.NOT.FPIKDP) CALL DAC_COL_EF_0
C     ...................................................... LOOP OVER OBJECTS
      DO 200 K=NUM1,NUM2
        CALL DV_QVEC_VECTOR_POL(K,P,FI,TE,IC,NCOL1,NCOL2)
        IF(IC.NE.0.AND.NPR.NE.8) GO TO 200
        IF(TE.LT.TC1.OR.TE.GT.TC2) GO TO 200
        FC=DFINXT(FIMID,FI)
        IF(FC.LT.FC1.OR.FC.GT.FC2) GO TO 200
        IF(PARADA(4,J_HCN).EQ.1.) THEN
          ECUT=PARADA(2,J_HCN)
          IF(     ECUT.GT.0.) THEN
            IF(P.LT. ECUT) GO TO 200
          ELSE IF(ECUT.LT.0.) THEN
            IF(P.GT.-ECUT) GO TO 200
          END IF
        END IF
        CALL DAC_COL_EF(K,KCOL)
        IF(KCOL.LT.0) GO TO 200
        CALL DGLEVL(KCOL)
        CALL DV_QVEC_EF_ITYPE(K,ITYPE)
        ITO=NTO
        IF(NTO.EQ.4.AND.ITYPE.EQ.4) ITO=3
        TT=TAND(TE)
        H1=0.
        V1=0.
        GO TO (201,202,203,204,205,206,201,208) NPR
C        ................................................................. YX
  201   IF(TE.GE.TBAR1.AND.TE.LE.TBAR2) THEN
C         .......................................... if barrel all
          FS=MOD(FI+FCOR,30.)-15.
          RO=RA(ITO)/COSD(FS)
        ELSE
C         .......................... if endcap, no endcap tracks from T3
C         .......................... tracks stop at end of tpc
          IF(NFR.EQ.1) GO TO 200
          RO=ZA(1)*ABS(TT)
        END IF
        CF=COSD(FI)
        SF=SIND(FI)
        IF(NFR.EQ.1) THEN
          H1=RA(NFR)*CF
          V1=RA(NFR)*SF
        END IF
        H2=RO*CF
        V2=RO*SF
        GO TO 280
C       ...................................................... RZ(SIGNED RHO)
  202   IF(NFR.EQ.1) THEN
C         .................................................. FROM
          V1=ZA(NFR)*ABS(TT)
          IF(V1.GT.RA(NFR)) THEN
C           .................................. barrel
            V1=RA(NFR)
            H1=V1/TT
          ELSE
C           .................................. endcap
            H1=ZA(NFR)
            IF(TE.GT.90.) H1=-H1
          END IF
        END IF
C       .................................................. TO
        V2=ZA(NTO)*ABS(TT)
        IF(V2.GT.RA(ITO)) THEN
C         .................................. barrel
          V2=RA(ITO)
          H2=V2/TT
        ELSE
C         .................................. endcap
          H2=ZA(ITO)
          IF(TE.GT.90.) H2=-H2
        END IF
        IF(FI.LT.FMIN.OR.FI.GT.FMAX) THEN
          V1=-V1
          V2=-V2
        END IF
        GO TO 280
C       ................................................................. FT
  203   H=-TE
        IF(FPIKDP) THEN
          CALL DQCH_PI(H,FI,P)
          IF(IZOMDO.EQ.0) CALL DQCH_PI(H,FI+360.,P)
        ELSE
          IF(FCHIM) THEN
            CALL DQCH(H,FI,P)
            CALL DQTXTS(H,FI,TEF(ITYPE),1)
            IF(IZOMDO.EQ.0) THEN
              CALL DQCH(H,FI+360.,P)
              CALL DQTXTS(H,FI+360.,TEF(ITYPE),1)
            END IF
          ELSE
            IF(MDEB.EQ.0) THEN
              CALL DQSR(H,FI,P)
              IF(IZOMDO.EQ.0.AND.FI.LT.FOVER)
     &          CALL DQSR(H,FI+360.,P)
            ELSE
              CALL DQSQ(H,FI,P,D90,D90)
              IF(IZOMDO.EQ.0.AND.FI.LT.FOVER)
     &          CALL DQSQ(H,FI+360.,P,D90,D90)
            END IF
          END IF
        END IF
        GO TO 200
C       ................................................................. FR
  204   IF(TE.GE.TBAR1.AND.TE.LE.TBAR2) THEN
C         .......................................... if barrel all
          FS=MOD(FI+FCOR,30.)-15.
          H2=RA(ITO)/COSD(FS)
        ELSE
C         .......................................... if endcap
C         ............................... no endcap tracks from T3
          IF(NFR.EQ.1) GO TO 200
          H2=ZA(1)*ABS(TT)
        END IF
        H1=RA(NFR)
        GO TO 270
C       ................................................................. FZ
  205   IF(TE.GE.TECP1.AND.TE.LE.TECP2) THEN
          IF(NFR.EQ.1) GO TO 200
          H2=ZA(1)
          IF(TE.GT.90.) H2=-H2
        ELSE
          H1=ZA(NFR)
          H2=ZA(ITO)
          IF(TE.GT.90.) THEN
            H1=-H1
            H2=-H2
          END IF
        END IF
        GO TO 270
C       ................................................................. YZ
  206   IF(TE.GE.TECP1.AND.TE.LE.TECP2) THEN
C         ....................... barrel: tracks stop at tpc end in 3D
          IF(NFR.EQ.1) GO TO 200
          RO=RA(1)
          H2=RO/TT
          X=RO*COSD(FI)
          Y=RO*SIND(FI)
          V2=-SF*X+CF*Y
        ELSE
C         .................................................... endcap
          IF(NFR.EQ.1) THEN
            H1=ZA(1)
            IF(TE.GT.90.) H1=-H1
            RO=H1*TT
            X=RO*COSD(FI)
            Y=RO*SIND(FI)
            V1=-SF*X+CF*Y
          END IF
          H2=ZA(ITO)
          IF(TE.GT.90.) H2=-H2
          RO=H2*TT
          X=RO*COSD(FI)
          Y=RO*SIND(FI)
          V2=-SF*X+CF*Y
        END IF
        GO TO 280
C       .................................................. RO: MOMENTUM VECTOR
  208   R=P*PFAC
        RO=R*SIND(TE)
        Z0=R*COSD(TE)
        Y0=RO*SIND(FI)
        X0=RO*COSD(FI)
        X2= CF*X0+SF*Y0
        Y2=-SF*X0+CF*Y0
        H = CT*X2+ST*Z0
        Z3=-ST*X2+CT*Z0
        V = CG*Y2+SG*Z3
        CALL DQL2EP(0.,0.,H,V)
        GO TO 200
C       ........................................................ VERTICAL = FI
  270   CALL DQL2EP(H1,FI,H2,FI)
        IF(IZOMDO.EQ.0) CALL DQL2EP(H1,FI+360.,H2,FI+360.)
        GO TO 200
  280   CALL DQL2EP(H1,V1,H2,V2)
  200   CONTINUE
C
CC       ........................................................ VERTICAL = FI
C  270   IF(FPIKDP) THEN
C          CALL DQPIF(H1,FI)
C          CALL DQPIF(H2,FI)
C        ELSE
C          CALL DQL2E(H1,FI,H2,FI)
C          IF(IZOMDO.EQ.0) CALL DQL2E(H1,FI+360.,H2,FI+360.)
C        END IF
C        GO TO 200
CC       ............................................................... OTHERS
C  280   IF(FPIKDP) THEN
C          IF(NFR.EQ.2) CALL DQPIK(H1,V1)
C          CALL DQPIK(H2,V2)
C        ELSE
C          CALL DQL2E(H1,V1,H2,V2)
C        END IF
C  200 CONTINUE
C
      CALL DPAR_SET_TR_WIDTH
      END
*DK DAPETR
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DAPETR
CH
      SUBROUTINE DAPETR(TPR)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C!:  Extrapolate tracks to end of HCAL in Y/X and rho/Z.
C    Inputs    :
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      EQUIVALENCE (KPIKDP,N)
      CHARACTER *2 TPR
      LOGICAL FOUT,FUSFI,FUSTE,FLIST
      DATA N3/3/,NRZ/100/,NXY/20/
      DIMENSION H(2),V(2),XYZ(3)
      IF(IHTRDO(1).LE.1.OR.IHTRDO(1).GT.3.OR.IHTRDO(4).LT.8) RETURN
      IF(IHTRDO(1).GE.6) RETURN
      IF(TPR.EQ.'YX') THEN
        CALL DTEX(FLIST)
        IF(FLIST) RETURN
      END IF
      CALL DSCTR
      CALL DV0(FRFTDB,NUM1,NUM2,FOUT)
      IF(FOUT) RETURN
      CALL DCUTTF(FUSFI,FC1,FC2,FUSTE,TC1,TC2)
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TSUBDJ='DAPETR'
      TPARDA=
     &  'J_PFI,J_PTE'
      CALL DPARAM(11
     &  ,J_PFI,J_PTE)

      TPARDA=
     &  'J_MRO,J_MZZ'
      CALL DPARAM(82
     &  ,J_MRO,J_MZZ)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      FMID=PARADA(2,J_PFI)
      IF(TPR.EQ.'RZ'.AND.PARADA(4,J_PTE).NE.0.) THEN
        FUSFI=.TRUE.
        FMIN=FMID-90.
        FMAX=FMID+90.
      END IF
      DO 1 N=NUM1,NUM2
        IF(FNOTDT(N)) GO TO 1
C       ........................................ track has endpoint
        IF(KINVDT(1,N).GT.0) GO TO 1
        CALL DVETR0(N,KP,XYZ)
        IF(KP.EQ.0) THEN
          IF(NUM1.EQ.NUM2)
     &      CALL DWRT('No track extrapolation available.')
          GO TO 1
        END IF
        IF(FUSTE) THEN
          TE=DVCORD(XYZ,IVTEDV)
          IF(TE.LT.TC1.OR.TE.GT.TC2) GO TO 1
        END IF
        IF(FUSFI) THEN
          FI=DFINXT(FMID,DVCORD(XYZ,IVFIDV))
          IF(FI.LT.FC1.OR.FI.GT.FC2) GO TO 1
        END IF
        IF(FVTRDC) CALL DGLEVL(NCTRDC(N))
        IF     (TPR.EQ.'YX') THEN
          H(1)=XYZ(1)
          V(1)=XYZ(2)
          DO I=N3,KP
            CALL DVETR(I,XYZ)
            H(2)=XYZ(1)
            V(2)=XYZ(2)
            IF(FPIKDP) THEN
              CALL DQPIK(H(2),V(2))
            ELSE
              CALL DQLIE(H,V)
              IF(I.EQ.KP.AND.IHTRDO(4).EQ.9)
     &          CALL D_AP_EXTR_LINE(H,V,PARADA(2,J_MRO),NXY)
              H(1)=H(2)
              V(1)=V(2)
            END IF
          END DO
        ELSE IF(TPR.EQ.'RZ') THEN
          SIGD=1.
          IF(PARADA(4,J_PTE).NE.0..AND.
     &      (FI.LT.FMIN.OR.FI.GT.FMAX)) SIGD=-1.
          H(1)=XYZ(3)
          V(1)=SIGD*DVCORD(XYZ,IVRODV)
          DO I=3,KP
            CALL DVETR(I,XYZ)
            H(2)=XYZ(3)
            V(2)=SIGD*DVCORD(XYZ,IVRODV)
            IF(FPIKDP) THEN
              CALL DQPIK(H(2),V(2))
            ELSE
              CALL DQLIE(H,V)
              IF(I.EQ.KP.AND.IHTRDO(4).EQ.9)
     &          CALL D_AP_EXTR_LINE(H,V,PARADA(2,J_MZZ),NRZ)
              H(1)=H(2)
              V(1)=V(2)
            END IF
          END DO
        END IF
    1 CONTINUE
      END
*DK D_AP_EXTR_LINE
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ D_AP_EXTR_LINE
CH
      SUBROUTINE D_AP_EXTR_LINE(H,V,DR,NP)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
      DIMENSION H(2),V(2)
      DH=H(2)-H(1)
      DV=V(2)-V(1)
      RH=SQRT(DH*DH+DV*DV)
      IF(RH.GT.0.) THEN
        DH=DR*DH/RH
        DV=DR*DV/RH
        H1=H(1)
        V1=V(1)
        DO N=2,NP
          H2=H1+DH
          V2=V1+DV
          CALL DQL2E(H1,V1,H2,V2)
        END DO
      END IF
      END
*DK DAPPT
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DAPPT
CH
      SUBROUTINE DAPPT(TPR,DFU,NBNK,LAYVD)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C!:Draw points (TPCO,TBCO,MHIT,TPAD) in All Projections
C    Inputs    :
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      EXTERNAL DFU
      CHARACTER *(*) TPR
      DATA W2/2./
      IF(NBNK.NE.MHITDB) THEN
        NGRC=52
        NGRS=62
      ELSE
        NGRC=55
        NGRS=65
      END IF
C     next 2 lines are used by J_PAR_CHECK
CJ_IN NGRC=55
CJ_IN NGRS=65
      IF(.NOT.FPIKDP.AND.
     &  TPR.NE.'VP') THEN
        CALL DPARGV(NGRC,'CFR',4,C4)
        IF(C4.GT.0.) THEN
          PCN2=PDCODD(2,ICCNDD)
          PCN4=PDCODD(4,ICCNDD)
          CALL DPARGV(NGRC,'CFR',2,C2)
          PDCODD(2,ICCNDD)=C2
          PDCODD(4,ICCNDD)=1.
C//       WID=WDSNDL(2,4,M)
C//       WDSNDL(2,4,M)=WID+2.*W2
          CALL DPARGV(NGRS,'SSZ',2,WID)
          CALL DPARGV(NGRS,'SFR',2,W2)
          CALL DPARSV(NGRS,'SSZ',2,WID+2.*W2)
          CALL DAPPT1(TPR,DFU,NBNK,LAYVD,NGRS,NGRC)
          PDCODD(2,ICCNDD)=PCN2
          PDCODD(4,ICCNDD)=PCN4
C//       WDSNDL(2,4,M)=WID
          CALL DPARSV(NGRS,'SSZ',2,WID)
        END IF
      END IF
      CALL DAPPT1(TPR,DFU,NBNK,LAYVD,NGRS,NGRC)
      END
*DK DAPPT1
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DAPPT1
CH
      SUBROUTINE DAPPT1(TPR,DFU,NBNK,LAYVD,NGRS,NGRC)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C!:Draw points (TPCO,TBCO,MHIT,TPAD) in All Projections
C    Inputs    :
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      EXTERNAL DFU
      CHARACTER *2 TPR
      DATA QCP/-0.012883/,FOVER/40./
      DATA QCPE/-0.0002/
      EQUIVALENCE (KPIKDP,K)
      DATA M1/8/,M2/8/
      DATA CMPIX/32./,TECL/60./,TECH/120./,ZMAX/217./
      DIMENSION ROVD(2,2)
      DATA DRT/30./,DARO/0.1/,SCRO0/20./,DROST/0./
      DATA DFJ/1./
C     ......................... CHANGE NPR FOR PULL WITH ONE LINE VIA LFT=0,1,2
C     ...................................... LFT=0: NORMAL
C     ...................................... LFT=1: 1 LINE   FT(PU#0)
C     ...................................... LFT=2: RHO INSTEAD OF B:  FT(PU#0)
      DIMENSION NFT(0:2)
      DATA NFT/4,20,21/
      DATA IDEB /0/
      DATA JDEB /0/
      DATA LFT /0/
      DATA RDEB /0./
      DATA QVSK0/0.1/
      DATA QPTT/10./,ROMID/105./
      LOGICAL FOUT,FCOL,FUSFI,FUSTE,FCUT,FSKEW
C     ............................ ONLY RESIDUALS ARE DRAWN BUT NOT OTHER HITS
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TSUBDJ='DAPPT1'
      TPARDA=
     &  'J_PFY,J_PFI,J_PTE,J_PPU,J_VSK_J_PGA,J_RAL,J_RSV,J_RRM,J_RES'
      CALL DPARAM(10
     &  ,J_PFY,J_PFI,J_PTE,J_PPU,J_VSK,J_PGA,J_RAL,J_RSV,J_RRM,J_RES)
      TPARDA=
     &  'J_REY'
      CALL DPARAM(15
     &  ,J_REY)
      TPARDA=
     &  'J_STC'
      CALL DPARAM(31
     &  ,J_STC)
      TPARDA=
     &  'J_SSY,J_SSZ'
      CALL DPARAM(NGRS
     &  ,J_SSY,J_SSZ)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      IF(FGRYDR.AND.NBNK.NE.MHITDB.AND.PARADA(4,J_STC).LT.0.) RETURN
C     .............................................. SET UP COLORS ; LAYER ON?
      FCOL=.FALSE.
      ML=MTPCDL
      IF(FPIKDP) THEN
        IF(NBNK.EQ.MHITDB) THEN
          IF(.NOT.FMDEDR) RETURN
        ELSE IF(NBNK.EQ.VDXYDB) THEN
          IF(.NOT.FVDEDR) RETURN
        ELSE
          IF(.NOT.FTPCDR) RETURN
        END IF
      ELSE
        IF     (NBNK.EQ.TPCODB) THEN
          CALL DSCTP
          FCOL=FVTPDC
        ELSE IF(NBNK.EQ.TBCODB) THEN
          IF(.NOT.FTPCDR) RETURN
          CALL DQLEVH(LCTBDD)
        ELSE IF(NBNK.EQ.TPADDB) THEN
          IF(.NOT.FTPCDR) RETURN
          CALL DQLEVH(LCTPDD)
        ELSE IF(NBNK.EQ.MHITDB) THEN
          IF(.NOT.FMDEDR) RETURN
          CALL DQLEVH(LCMUDD(1))
          ML=MMDEDL
C        ELSE IF(NBNK.EQ.VDCODB) THEN
C          IF(.NOT.FVDEDR) RETURN
C          IF(IHACDV.EQ.1) RETURN
C          IF(IHACDV.NE.2.AND.LAYER.GT.2) RETURN
C          CALL DQLEVH(LCVDDD)
C          ML=MVDEDL
C        ELSE IF(NBNK.EQ.VDXYDB) THEN
C          IF(.NOT.FVDEDR) RETURN
C          CALL DQLEVH(LCVDDD)
C          ML=MVDEDL
        END IF
      END IF
C     ........................................................ INITIALISE BANK
    1 CALL DV0(NBNK,NUM1,NUM2,FOUT)
      IF(FOUT) RETURN
C     ....................................................... SET UP FI/TE CUT
      IF(NBNK.EQ.VDXYDB) THEN
        FUSFI=.FALSE.
        FUSTE=.FALSE.
        FC1=-1024.
        FC2= 1024.
        TC1=-1024.
        TC2= 1024.
      ELSE
        CALL DCUTTF(FUSFI,FC1,FC2,FUSTE,TC1,TC2)
      END IF
      FIMID=PARADA(2,J_PFI)
      TEMID=PARADA(2,J_PTE)
C     ........................... The selection between barrel and endcap hits
C     ................................ for the muons is done via the teta cut.
      IF(NBNK.EQ.MHITDB) FUSTE=.TRUE.
      SYSIZ=PARADA(2,J_SSZ)
      FIOVR=FOVER
C     ..................................................... SET UP PROJECTIONS
      IF     (TPR.EQ.'YX') THEN
C//     CALL DQPD0(MSYMDL(ML,0),WDSNDL(2,4,ML),0.)
        FIOVR=0.
        NPR=1
      ELSE IF(TPR.EQ.'RZ') THEN
C//     CALL DQPD0(MSYMDL(ML,0),WDSNDL(2,4,ML),0.)
        FIOVR=0.
        IF(PARADA(4,J_PTE).NE.0.) THEN
          FUSFI=.TRUE.
          FMIN=FIMID-90.
          FMAX=FIMID+90.
          NPR=2
        ELSE
          NPR=3
        END IF
      ELSE IF(TPR.EQ.'FT') THEN
        QUVD=0.
        IF(COLIDF(4,6).NE.1.) THEN
C//       CALL DQPD0(MSYMDL(ML,0),WDSNDL(2,4,ML),FOVER)
        ELSE
C//       CALL DQPD0(MSYMDL(ML,0),COLIDF(2,6),FOVER)
          IF(TNAMDO.EQ.'SY') CALL DWRT
     &      ('Set size in FT  ("GT:FT") via: "SZ=" or "SZ=OF"#')
          SYSIZ=COLIDF(2,6)
        END IF
        FUSFI=.TRUE.
        FUSTE=.TRUE.
        IF(PARADA(4,J_PPU).EQ.1.) THEN
          PU=QCP*PARADA(2,J_PPU)
          IF(PARADA(2,J_PPU).GE.0) THEN
            NPR=NFT(LFT)
          ELSE
            NPR=20
          END IF
        ELSE
          PU=0.
          NPR=NFT(0)
        END IF
        IF(PARADA(4,J_VSK).EQ.1.) THEN
          QVSK=PARADA(2,J_VSK)*QVSK0
        ELSE
          QVSK=0.
        END IF
        IF(IZOMDO.EQ.0) FIMID=180.
        IF(LAYVD.EQ.0) THEN
          DRO=DROST
          NPR=15
        ELSE IF(LAYVD.LE.2) THEN
          FUSTE=.TRUE.
          CALL DGIVDR(ROVD)
          DRO=0.5*(ROVD(1,LAYVD)+ROVD(2,LAYVD))
          NPR=15
C?        GO TO 3
        END IF
      ELSE IF(TPR.EQ.'VP') THEN
        QUVD=0.
        IF(FPIKDP) RETURN
        IF(IZOMDO.EQ.0) THEN
C//       CALL DQPD0(MSYMDL(ML,0),WDSNDL(2,4,ML),FOVER)
        ELSE
C//       CALL DQPD0(MSYMDL(ML,0),WDSNDL(2,4,ML),0.)
          FIOVR=0.
        END IF
        FCOL=.FALSE.
        FUSFI=.TRUE.
        FUSTE=.TRUE.
        PU=QCP*PARADA(2,J_PPU)
        IF(PARADA(4,J_VSK).EQ.1.) THEN
          QVSK=PARADA(2,J_VSK)
        ELSE
          QVSK=0.
        END IF
        CALL DGLEVL(IFIX(COLIDF(2,4)))
        IF(IZOMDO.EQ.0) FIMID=180.
        NPR=5
      ELSE IF(TPR.EQ.'FR') THEN
        QUVD=1.
C//     CALL DQPD0(MSYMDL(ML,0),WDSNDL(2,4,ML),FOVER)
        FUSFI=.TRUE.
        IF(IZOMDO.EQ.0) FIMID=180.
        CALL DPARGV(11,'PPT',4,PPT4)
        FSKEW=.FALSE.
        IF(PPT4.EQ.2.) THEN
          CALL DPARGV(11,'PPT',2,PPT2)
          IF(PPT2.NE.0.) THEN
            PTS=QPTT/PPT2
            CCC=-1./(0.003*1.5)
            Q2CPT=1./(2.*CCC*PTS)
            ASRM=ASIN(ROMID*Q2CPT)
            FSKEW=.TRUE.
          END IF
        END IF
        NPR=7
      ELSE IF(TPR.EQ.'FZ') THEN
C//     CALL DQPD0(MSYMDL(ML,0),WDSNDL(2,4,ML),FOVER)
        FUSFI=.TRUE.
        IF(IZOMDO.EQ.0) FIMID=180.
        NPR=8
      ELSE IF(TPR.EQ.'YZ') THEN
C//     CALL DQPD0(MSYMDL(ML,0),WDSNDL(2,4,ML),0.)
        FIOVR=0.
        SF=SIND(PARADA(2,J_PFY))
        CF=COSD(PARADA(2,J_PFY))
        IF(PARADA(4,J_PFY).NE.1.) THEN
          NPR=9
        ELSE
          IF(PARADA(4,J_PGA).EQ.1.) THEN
            SG=SIND(PARADA(2,J_PGA))
            CG=COSD(PARADA(2,J_PGA))
            QG=1./(SG+CG)
            FUSFI=.TRUE.
            FMIN=FIMID-90.
            FMAX=FIMID+90.
            NPR=12
          ELSE
            NPR=9
          END IF
        END IF
      ELSE IF(TPR.EQ.'HF') THEN
C//     CALL DQPD0(MSYMDL(ML,0),WDSNDL(2,4,ML),FOVER)
        FUSFI=.TRUE.
        NPR=10
      ELSE IF(TPR.EQ.'RO'.OR.TPR.EQ.'3D'.OR.TPR.EQ.'RS') THEN
        QUVD=0.
C//     CALL DQPD0(MSYMDL(ML,0),WDSNDL(2,4,ML),0.)
        FIOVR=0.
        SF=SIND(FIMID)
        CF=COSD(FIMID)
        ST=SIND(90.-PARADA(2,J_PTE))
        CT=COSD(90.-PARADA(2,J_PTE))
        SG=SIND(PARADA(2,J_RAL))
        CG=COSD(PARADA(2,J_RAL))
        IF(PARADA(4,J_RES).EQ.1.) THEN
          ES= PARADA(2,J_RES)*CMPIX/AHSCDQ
          EY=-PARADA(2,J_REY)*CMPIX/AHSCDQ
        END IF
        IF(FPIKDP.OR.TPR.EQ.'RO') THEN
          NPR=11
        ELSE IF(TPR.EQ.'RS') THEN
          CALL DGLEVL(IFIX(COLIDF(2,4)))
          FCOL=.FALSE.
          SD=SIND(PARADA(2,J_RAL)+DARO)
          CD=COSD(PARADA(2,J_RAL)+DARO)
          SCRO=PARADA(2,J_RSV)*SCRO0
          NPR=17
        ELSE
          CALL DGLEVL(IFIX(COLIDF(2,4)))
C         CALL DQLEVL(LCTGDD)
          FCOL=.FALSE.
          NSIDE=PARADA(2,J_RRM)-6.
          NPR=18
        END IF
      ELSE IF(TPR.EQ.'EC') THEN
C//     CALL DQPD0(MSYMDL(ML,0),WDSNDL(2,4,ML),0.)
        FIOVR=0.
        FUSTE=.TRUE.
        FUSFI=.TRUE.
        PU=QCPE*PARADA(2,J_PPU)
        NPR=13
      ELSE IF(TPR.EQ.'EV') THEN
        IF(FPIKDP) RETURN
        FCOL=.FALSE.
        CALL DGLEVL(IFIX(COLIDF(2,4)))
C//     CALL DQPD0(MSYMDL(ML,0),WDSNDL(2,4,ML),0.)
        FIOVR=0.
        FUSTE=.TRUE.
        FUSFI=.TRUE.
        PU=QCPE*PARADA(2,J_PPU)
        NPR=14
      ELSE IF(TPR.EQ.'RT') THEN
        IF(COLIDF(4,6).NE.1.) THEN
C//       CALL DQPD0(MSYMDL(ML,0),WDSNDL(2,4,ML),FOVER)
        ELSE
C//       CALL DQPD0(MSYMDL(ML,0),COLIDF(2,6),FOVER)
          SYSIZ=COLIDF(2,6)
        END IF
        FUSFI=.TRUE.
        FUSTE=.TRUE.
        IF(IZOMDO.EQ.0.AND.PARADA(4,J_PTE).NE.0.) THEN
          FMIN=FIMID-90.
          FMAX=FIMID+90.
        ELSE
          FMIN=-1024.
          FMAX= 1024.
        END IF
        NPR=16
      END IF
      CALL DQPD0(IDPAR(J_SSY),SYSIZ,FIOVR)
C     ======================================================= FAST DRAW OF TPCO
      IF(SLOWDU.EQ.0..AND.NBNK.EQ.TPCODB.AND.NUM2.LE.MTPCDV.
     &  AND.NPR.LE.14) THEN
C       .......................................... SET UP TPCO COORDINATE ARRAY
        IF(FCUHDT) CALL=DVTPST(IVNTDV,IVNT)
        IF(FUSFI ) CALL=DVTPST(IVFIDV,IVFI)
        IF(FUSTE ) CALL=DVTPST(IVTEDV,IVTE)
        GO TO (101,102,102,104,104,104,107,108,109,110,109,112) NPR
C       ................................................................... YX
  101   CALL=DVTPST(IVXXDV,IVXX)
        CALL=DVTPST(IVYYDV,IVYY)
        GO TO 180
C       ................................................................... RZ
  102   CALL=DVTPST(IVRODV,IVRO)
        CALL=DVTPST(IVZZDV,IVZZ)
        GO TO 180
C       ................................................................... FT
  104   CALL=DVTPST(IVTEDV,IVTE)
        CALL=DVTPST(IVRBDV,IVRB)
        GO TO 180
C       ................................................................... FR
  107   CALL=DVTPST(IVRODV,IVRO)
        GO TO 180
C       ................................................................... FZ
  108   CALL=DVTPST(IVZZDV,IVZZ)
        GO TO 180
C       ................................................................ YZ,RO
  109   CALL=DVTPST(IVXXDV,IVXX)
        CALL=DVTPST(IVYYDV,IVYY)
        CALL=DVTPST(IVZZDV,IVZZ)
        GO TO 180
C       ................................................................... HF
  110   CALL=DVTPST(IVRBDV,IVRB)
        GO TO 180
C       ................................................................ YZ->RZ
  112   CALL=DVTPST(IVXXDV,IVXX)
        CALL=DVTPST(IVYYDV,IVYY)
        CALL=DVTPST(IVZZDV,IVZZ)
        CALL=DVTPST(IVRODV,IVRO)
C       ............................................................ FAST LOOP
  180   DO 200 K=NUM1,NUM2
          IF(FCUHDT) THEN
            IF(FNOHDT(NTPCDV(IVNT,K))) GO TO 200
          END IF
          IF(FUSTE) THEN
            TE=VTPCDV(IVTEDV,K)
            IF(TE.LT.TC1.OR.TE.GT.TC2) GO TO 200
          END IF
          IF(FUSFI) THEN
            FI=DFINXT(FIMID,VTPCDV(IVFIDV,K))
            IF(FI.LT.FC1.OR.FI.GT.FC2) GO TO 200
          END IF
          IF(FCOL) CALL DGLEVL(NCTPDC(K))
          GO TO (201,202,203,204,205,206,207,208,209,210,
     &           211,212) NPR
C         ................................................................. YX
  201     IF(RDEB.GT.0.) THEN
            H=(RDEB+VTPCDV(IVRO,K))*COSD(VTPCDV(IVFI,K))
            V=(RDEB+VTPCDV(IVRO,K))*SIND(VTPCDV(IVFI,K))
            GO TO 280
          END IF
          H=VTPCDV(IVXX,K)
          V=VTPCDV(IVYY,K)
          GO TO 280
C         ...................................................... RZ(SIGNED RHO)
  202     H=VTPCDV(IVZZ,K)
          IF(FI.GE.FMIN.AND.FI.LE.FMAX) THEN
            V=VTPCDV(IVRO,K)
          ELSE
            V=-VTPCDV(IVRO,K)
          END IF
          GO TO 280
C         .................................................... RZ(POSITIVE RHO)
  203     H=VTPCDV(IVZZ,K)
          V=VTPCDV(IVRO,K)
          GO TO 280
C         ............................................................ FT(PU#0)
  204     B=VTPCDV(IVRB,K)
          DPU=PU*B
          H=-TE
          V=FI-QVSK*B
          IF(FPIKDP) THEN
            CALL DQPIF(H+DPU,V)
            CALL DQPIF(H-DPU,V)
          ELSE
            CALL DQPD(H+DPU,V)
            CALL DQPD(H-DPU,V)
            IF(IZOMDO.EQ.0.AND.FI.LE.FOVER) THEN
              CALL DQPD(H+DPU,V+360.)
              CALL DQPD(H-DPU,V+360.)
            END IF
          END IF
          GO TO 200
C         ...................................................... FT(PULL-LINES)
  205     DPU=PU*VTPCDV(IVRB,K)
          CALL DQLHE(-TE-DPU,-TE+DPU,FI)
          GO TO 200
C         ............................................................ FT(PU=0)
  206     H=-TE
          GO TO 290
C         ................................................................. FR
C  207     IF(LDEB.EQ.9.AND.FRPRDP) THEN
C            X=VTPCDV(IVXX,K)
C            Y=VTPCDV(IVYY,K)
C            CALL DRPR(X,Y,H,FI)
C          ELSE
C            H=VTPCDV(IVRO,K)
C          END IF
  207     H=VTPCDV(IVRO,K)
          IF(FSKEW) THEN
            SKV=-PIFCDK*(ASIN(H*Q2CPT)-ASRM)
            FI=FI+SKV
          END IF
          GO TO 290
C         ................................................................. FZ
  208     H=VTPCDV(IVZZ,K)
          GO TO 290
C         ................................................................. YZ
  209     H=VTPCDV(IVZZ,K)
          V=-SF*VTPCDV(IVXX,K)+CF*VTPCDV(IVYY,K)
          GO TO 280
C         ................................................................. HF
  210     H=DVTP(IVRB,K)
          GO TO 290
C         ................................................................. RO
  211     X1=VTPCDV(IVXX,K)
          Y1=VTPCDV(IVYY,K)
          Z1=VTPCDV(IVZZ,K)
C         .................................................... X2= CF*X1+SF*Y1
C         .................................................... Y2=-X1*SF+CF*Y1
C         .................................................... Z2= Z1
C         .................................................... X3= CT*X2+ST*Z2
C         .................................................... Y3= Y2
C         .................................................... Z3=-ST*X2+CT*Z2
C         ...................................................H=X4= X3
C         .................................................. V=Y4= CG*Y3+SG*Z3
C         .................................................... Z4=-SG*Y3+CG*Z3
          X2= CF*X1+SF*Y1
          Y2=-SF*X1+CF*Y1
          H = CT*X2+ST*Z1
          Z3=-ST*X2+CT*Z1
          V = CG*Y2+SG*Z3
          IF(PARADA(4,J_RES).EQ.1.) THEN
            W=-SG*Y2+CG*Z3
            ESW=ES+W
            H=H+(EY-H)*W/ESW
            V=V*ES/ESW
          END IF
          GO TO 280
C         ............................................................. YZ=>RZ
  212     H=VTPCDV(IVZZ,K)
          VY=-SF*VTPCDV(IVXX,K)+CF*VTPCDV(IVYY,K)
          IF(FI.GE.FMIN.AND.FI.LE.FMAX) THEN
            VR=VTPCDV(IVRO,K)
          ELSE
            VR=-VTPCDV(IVRO,K)
          END IF
          V=QG*(CG*VY+SG*VR)
  280     IF(FPIKDP) THEN
            CALL DQPIK(H,V)
          ELSE
            CALL DQPD(H,V)
          END IF
          GO TO 200
  290     IF(FPIKDP) THEN
            CALL DQPIF(H,FI)
          ELSE
            CALL DQPD(H,FI)
            IF(IZOMDO.EQ.0.AND.FI.LE.FOVER) CALL DQPD(H,FI+360.)
          END IF
  200   CONTINUE
      ELSE
C       ============= SLOW DRAW OF TPCO(WITHOUT TRACK-CUTS),TBCO,TPAD,MHIT,VDXY
    3   IF(NBNK.EQ.TPCODB) THEN
          FCUT=FCUHDT
        ELSE
          FCUT=.FALSE.
        END IF
        DO 300 K=NUM1,NUM2
          IF(SLOWDU.EQ.2.) CALL DWAIT
          IF(FCUT) THEN
            CALL=DVTPNT(K,NTRK)
            IF(FNOHDT(NTRK)) GO TO 300
          END IF
          IF(FUSTE) THEN
            TE=DFU(IVTEDV,K)
            IF(TE.LT.TC1.OR.TE.GT.TC2) GO TO 300
          END IF
          IF(FUSFI) THEN
            FI=DFINXT(FIMID,DFU(IVFIDV,K))
            IF(FI.LT.FC1.OR.FI.GT.FC2) GO TO 300
          END IF
          IF(FCOL) THEN
            CALL DGLEVL(NCTPDC(K))
          ELSE IF(NBNK.EQ.VDXYDB) THEN
            KSECT=DVVDXY(IVKKDV,K)
            NCOL=MOD(KSECT,M1)+M2
            CALL DGLEVL(NCOL)
          ELSE IF(NBNK.EQ.VDCODB) THEN
            DIR=DVVDC(14,K)
            IF(QUVD.NE.0.AND.DIR.NE.QUVD.AND.DIR.NE.3.) GO TO 300
            NTRVD=DVVDC(IVNTDV,K)
            IF(FVTRDC) CALL DGLEVL(NCTRDC(NTRVD))
          END IF
          IF(NBNK.EQ.MHITDB) THEN
            YLOCAL=DVMD(IVLVDV,K)
            IF(YLOCAL.EQ.0.) THEN
              SUBC=DVMD(IVNNDV,K)
              IF(SUBC.LE.2.) THEN
C                IF(IDEB.EQ.0.OR.IAREDO.NE.1) GO TO 300
                GO TO 300
              ELSE
                IF(TPR.NE.'YX'.AND.TPR.NE.'FR') THEN
C                  IF(IDEB.EQ.0.OR.IAREDO.NE.1) GO TO 300
                  GO TO 300
                END IF
              END IF
            END IF
          END IF
          GO TO (301,302,303,304,305,306,307,308,309,310,
     &           311,312,313,314,315,316,317,318,319,320,
     &           321) NPR
C         ................................................................. YX
  301     H=DFU(IVXXDV,K)
          V=DFU(IVYYDV,K)
          GO TO 380
C         ...................................................... RZ(SIGNED RHO)
  302     H=DFU(IVZZDV,K)
          IF(FI.GE.FMIN.AND.FI.LE.FMAX) THEN
            V=DFU(IVRODV,K)
          ELSE
            V=-DFU(IVRODV,K)
          END IF
          GO TO 380
C         .................................................... RZ(POSITIVE RHO)
  303     H=DFU(IVZZDV,K)
          V=DFU(IVRODV,K)
          GO TO 380
C         ............................................................ FT(PU#0)
  304     DPU=PU*DFU(IVRBDV,K)
          H=-TE
          IF(FPIKDP) THEN
            CALL DQPIF(H+DPU,FI)
            CALL DQPIF(H-DPU,FI)
          ELSE
            CALL DQPD(H+DPU,FI)
            CALL DQPD(H-DPU,FI)
            IF(IZOMDO.EQ.0.AND.FI.LE.FOVER) THEN
              CALL DQPD(H+DPU,FI+360.)
              CALL DQPD(H-DPU,FI+360.)
            END IF
          END IF
          GO TO 300
C         ...................................................... FT(PULL-LINES)
  305     DPU=PU*DFU(IVRBDV,K)
          CALL DQLHE(-TE-DPU,-TE+DPU,FI)
          GO TO 300
C         ............................................................ FT(PU=0)
  306     H=-TE
          GO TO 390
C         ................................................................. FR
  307     H=DFU(IVRODV,K)
          GO TO 390
C         ................................................................. FZ
  308     H=DFU(IVZZDV,K)
          GO TO 390
C         ................................................................. YZ
  309     H=DFU(IVZZDV,K)
          V=-SF*DFU(IVXXDV,K)+CF*DFU(IVYYDV,K)
          GO TO 380
C         ................................................................. HF
  310     H=DFU(IVRBDV,K)
          GO TO 390
C         ................................................................. RO
  311     X1=DFU(IVXXDV,K)
          Y1=DFU(IVYYDV,K)
          Z1=DFU(IVZZDV,K)
          X2= CF*X1+SF*Y1
          Y2=-SF*X1+CF*Y1
          H = CT*X2+ST*Z1
          Z3=-ST*X2+CT*Z1
          V = CG*Y2+SG*Z3
          GO TO 380
C         ............................................................. YZ=>RZ
  312     H=DFU(IVZZ,K)
          VY=-SF*DFU(IVXX,K)+CF*DFU(IVYY,K)
          IF(FI.GE.FMIN.AND.FI.LE.FMAX) THEN
            VR= DFU(IVRO,K)
          ELSE
            VR=-DFU(IVRO,K)
          END IF
          V=QG*(CG*VY+SG*VR)
          GO TO 380
  313     IF(TE.GT.TECL.AND.TE.LT.TECH) GO TO 300
          Z=DFU(IVZZDV,K)
          IF(IDEB.EQ.0) THEN
            DZ=PU*DFU(IVRBDV,K)*DFU(IVRODV,K)/Z
          ELSE
            DZ=PU*(ZMAX-ABS(Z))
          END IF
          Z=ABS(Z-VRDZDV)
          H=DFU(IVXXDV,K)/Z
          V=DFU(IVYYDV,K)/Z
          DH=DZ*COSD(FI)
          DV=DZ*SIND(FI)
          IF(FPIKDP) THEN
            CALL DQPIK(H-DH,V-DV)
            CALL DQPIK(H+DH,V+DV)
          ELSE
            CALL DQPD(H-DH,V-DV)
            CALL DQPD(H+DH,V+DV)
          END IF
          GO TO 300
  314     IF(TE.GT.TECL.AND.TE.LT.TECH) GO TO 300
          Z=DFU(IVZZDV,K)
          IF(IDEB.EQ.0) THEN
            DZ=PU*DFU(IVRBDV,K)*DFU(IVRODV,K)/Z
          ELSE
            DZ=PU*(ZMAX-ABS(Z))
          END IF
          Z=ABS(Z-VRDZDV)
          H=DFU(IVXXDV,K)/Z
          V=DFU(IVYYDV,K)/Z
          DH=DZ*COSD(FI)
          DV=DZ*SIND(FI)
          CALL DQL2E(H-DH,V-DV,H+DH,V+DV)
          GO TO 300
  315     XX=DFU(IVXXDV,K)-VRTXDV
          YY=DFU(IVYYDV,K)-VRTYDV
          ZZ=DFU(IVZZDV,K)-VRDZDV
          RO=SQRT(XX*XX+YY*YY)
          DPU=PU*(RO-DRO)/SIND(TE)
          H=-DATN2D(RO,ZZ)
          FI=DATN2D(YY,XX)
          FI=DFINXT(FIMID,FI)
          IF(FPIKDP) THEN
            CALL DQPIF(H+DPU,FI)
            CALL DQPIF(H-DPU,FI)
          ELSE
            CALL DQPD(H+DPU,FI)
            CALL DQPD(H-DPU,FI)
            IF(IZOMDO.EQ.0.AND.FI.LE.FOVER) THEN
              CALL DQPD(H+DPU,FI+360.)
              CALL DQPD(H-DPU,FI+360.)
            END IF
          END IF
          GO TO 300
  316     H=-TE
          IF(FI.GE.FMIN.AND.FI.LE.FMAX) THEN
            V=-DRT+DFU(IVRODV,K)
          ELSE
            V= DRT-DFU(IVRODV,K)
          END IF
          GO TO 380
C         ...................................................... RO with speed
  317     X1=DFU(IVXXDV,K)
          Y1=DFU(IVYYDV,K)
          Z1=DFU(IVZZDV,K)
          X2= CF*X1+SF*Y1
          Y2=-SF*X1+CF*Y1
          H = CT*X2+ST*Z1
          Z3=-ST*X2+CT*Z1
          V = CG*Y2+SG*Z3
          V1= CD*Y2+SD*Z3
          V2=V+SCRO*(V1-V)
          CALL DQL2E(H,V,H,V2)
          GO TO 300
C         ..........................RO: DRAW LINE DOWN TO X,Z ... PLANE Y1=0 ..
  318     X1=DFU(IVXXDV,K)
          Y1=DFU(IVYYDV,K)
          Z1=DFU(IVZZDV,K)
          X2= CF*X1+SF*Y1
          Y2=-SF*X1+CF*Y1
          H = CT*X2+ST*Z1
          Z3=-ST*X2+CT*Z1
          V = CG*Y2+SG*Z3
          GO TO (601,602,603) NSIDE
  601     X1=0.
          GO TO 609
  602     Y1=0.
          GO TO 609
  603     Z1=0.
  609     X2= CF*X1+SF*Y1
          Y2=-SF*X1+CF*Y1
          H2= CT*X2+ST*Z1
          Z3=-ST*X2+CT*Z1
          V2= CG*Y2+SG*Z3
          CALL DQL2E(H,V,H2,V2)
          GO TO 300
  319     H=DFU(IVXXDV,K)
          V=DFU(IVYYDV,K)
          CALL DQPD(H,V)
          FI=DFINXT(FIMID,DFU(IVFIDV,K))
          RJ=DFU(IVRODV,K)
          IF     (FI.LT.FMIN) THEN
            DO FF=FI,FMIN,DFJ
              HJ=RJ*COSD(FF)
              VJ=RJ*SIND(FF)
              CALL DQL2E(H,V,HJ,VJ)
              H=HJ
              V=VJ
            END DO
          ELSE IF(FI.LT.FIMID) THEN
            DO FF=FI,FMIN,-DFJ
              HJ=RJ*COSD(FF)
              VJ=RJ*SIND(FF)
              CALL DQL2E(H,V,HJ,VJ)
              H=HJ
              V=VJ
            END DO
          ELSE IF(FI.LT.FMAX) THEN
            DO FF=FI,FMAX,DFJ
              HJ=RJ*COSD(FF)
              VJ=RJ*SIND(FF)
              CALL DQL2E(H,V,HJ,VJ)
              H=HJ
              V=VJ
            END DO
          ELSE
            DO FF=FI,FMAX,-DFJ
              HJ=RJ*COSD(FF)
              VJ=RJ*SIND(FF)
              CALL DQL2E(H,V,HJ,VJ)
              H=HJ
              V=VJ
            END DO
          END IF
          GO TO 300
C         ....................................................1 LINE   FT(PU#0)
  320     DPU=-PU*DFU(IVRBDV,K)
          H=-TE
          IF(FPIKDP) THEN
            CALL DQPIF(H+DPU,FI)
          ELSE
            CALL DQPD(H+DPU,FI)
            IF(IZOMDO.EQ.0.AND.FI.LE.FOVER) THEN
              CALL DQPD(H+DPU,FI+360.)
            END IF
          END IF
          GO TO 300
C         ..........................................RHO INSTEAD OF B:  FT(PU#0)
  321     DPU=PU*DFU(IVRODV,K)
          H=-TE
          IF(FPIKDP) THEN
            CALL DQPIF(H+DPU,FI)
          ELSE
            CALL DQPD(H+DPU,FI)
            IF(IZOMDO.EQ.0.AND.FI.LE.FOVER) THEN
              CALL DQPD(H+DPU,FI+360.)
            END IF
          END IF
          GO TO 300
  380     IF(FPIKDP) THEN
            CALL DQPIK(H,V)
          ELSE
            CALL DQPD(H,V)
          END IF
          GO TO 300
  390     IF(FPIKDP) THEN
            CALL DQPIF(H,FI)
          ELSE
            CALL DQPD(H,FI)
            IF(IZOMDO.EQ.0.AND.FI.LE.FOVER) CALL DQPD(H,FI+360.)
          END IF
  300   CONTINUE
      END IF
      IF(JDEB.EQ.0.AND.NBNK.EQ.TPCODB.AND.FX11DT) CALL DQCHKX
      END
*DK DAP_TR
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DAP_TR
CH
      SUBROUTINE DAP_TR
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C!:
C    Inputs    :
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      EQUIVALENCE (KPIKDP,N)
      DIMENSION DLIN(2),ICOL(2)
      LOGICAL FOUT,FKALM,DVM0
      LOGICAL DCCVX
      EXTERNAL DVTR0
      FKALM=.FALSE.
      IF(FPIKDP) THEN
        IF(IHTRDO(2).GE.4) FKALM=.TRUE.
      ELSE
        IF(IHTRDO(2).EQ.6) THEN
          CALL DAP_KALMAN_HE
          RETURN
        ELSE IF (IHTRDO(2).GE.4) THEN
          CALL DAP_KALMAN_CH
          RETURN
        END IF
      END IF
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_PFY,J_PFI,J_PTE,J_RAL'
      CALL DPARAM(10
     &  ,J_PFY,J_PFI,J_PTE,J_RAL)
      TPARDA=
     &  'J_CCN,J_CFR'
      CALL DPARAM(58
     &  ,J_CCN,J_CFR)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      IF(IHTRDO(2).LE.2.OR.FKALM) THEN
        CALL DV0(FRFTDB,NUM1,NUM2,FOUT)
        IF(FOUT) RETURN
        MODEDT=1
      ELSE
        MODEDT=2
        TEMID=PARADA(2,J_PTE)
        CALL DMCNVX(NVTX1)
        IF(NVTX1.LE.0) RETURN
      END IF
      IF(     TPICDO.EQ.'YZ') THEN
        SF=SIND(PARADA(2,J_PFY))
        CF=COSD(PARADA(2,J_PFY))
      ELSE IF(TPICDO.EQ.'RO') THEN
        SF=SIND(PARADA(2,J_PFI))
        CF=COSD(PARADA(2,J_PFI))
        ST=SIND(90.-PARADA(2,J_PTE))
        CT=COSD(90.-PARADA(2,J_PTE))
        SG=SIND(PARADA(2,J_RAL))
        CG=COSD(PARADA(2,J_RAL))
      END IF
      CALL DAPTRN(TPICDO,0)
C
C      DLIN=DLINDD
C      IF(FPIKDP) THEN
C        M1=1
C        M2=1
C        FVTRDC=.FALSE.
C      ELSE
C        M2=2
C        CALL DPAR_SET_CO(58,'CFR')
C        IF(ICOLDP.GE.0) THEN
C          M1=1
C          FVTRDC=.FALSE.
C          DLINDD=DLINDD+2.*PARADA(2,J_SFR)
C        ELSE
C          M1=2
C          CALL DSCTR
C        END IF
C      END IF
C
      CALL DAP_SET_TR(J_CFR,J_CCN,DLIN,ICOL,M2)
      DO M=1,M2
        DLINDD=DLIN(M)
        IF(ICOL(M).GE.0) CALL DGLEVL(ICOL(M))
        IF(MODEDT.EQ.1) THEN
          DO 1 N=NUM1,NUM2
            IF(FNOTDT(N)) GO TO 1
            IF(ICOL(M).LT.0) CALL DGLEVL(NCTRDC(N))
            CALL DVTRV(N)
            CALL DVXT(N,XYZVDT)
            CALL DAP_1_TR(SF,CF,ST,CT,SG,CG)
            CALL DAPTRN('TPICDO',N)
    1     CONTINUE
        ELSE
          TEMID=PARADA(2,J_PTE)
          CALL DMCNVX(NVTX1)
          IF(NVTX1.LE.0) RETURN
          DO 12 NV=1,NVTX1
            CALL DMCVX(NV,KT1,KT2)
            IF(KT2.LE.0) GO TO 12
            DO 11 N=KT1,KT2
              IF(DVM0(N)) GO TO 11
              CALL DMCTR(N,FOUT)
              IF(FOUT) GO TO 11
              CALL DAP_1_TR(SF,CF,ST,CT,SG,CG)
   11       CONTINUE
   12     CONTINUE
        END IF
        CALL DSCTR
      END DO
      IF(MODEDT.EQ.2.AND.(.NOT.FPIKDP)) THEN
        IF(NVTX1.LE.0) RETURN
        CALL DPAR_SET_CO(49,'CMC')
        IF(ICOLDP.LT.0) RETURN
        CALL DPARGV(67,'SSY',2,SYMB)
        CALL DPARGV(67,'SSZ',2,SYSZ)
        MSYMB=SYMB
        CALL DQPD0(MSYMB,SZVXDT*BOXSDU*SYSZ,0.)
        DO 13 N=1,NVTX1
          IF(FMVXDT(N)) THEN
            CALL DVMCVX(N,KDUM1,KDUM2,KDUM3,VTX1DT)
            IF(DCCVX(VTX1DT)) GO TO 13
            H=VTX1DT(1)
            V=VTX1DT(2)
            CALL DQPD(H,V)
          END IF
   13   CONTINUE
      END IF
      END
*DK DAP_1_TR
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DAP_1_TR
CH
      SUBROUTINE DAP_1_TR(SF,CF,ST,CT,SG,CG)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
      INCLUDE 'DALI_CF.INC'
      IF(     TPICDO.EQ.'YX') THEN
        CALL DYX1TR(SP)
      ELSE IF(TPICDO.EQ.'YZ') THEN
        CALL DYZ1TR(SF,CF)
      ELSE IF(TPICDO.EQ.'FR') THEN
        CALL DFR1TR
      ELSE IF(TPICDO.EQ.'FZ') THEN
        CALL DFZ1TR
      ELSE IF(TPICDO.EQ.'RZ') THEN
        CALL DRZ1TR
      ELSE IF(TPICDO.EQ.'RO') THEN
        CALL DRO1TR(SF,CF,ST,CT,SG,CG)
      END IF
      END
*DK DAP_TR_FRAME
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++ DAP_TR_FRAME
CH
      SUBROUTINE DAP_SET_TR(JCFR,JCTR,DLIN,ICOL,M2)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C     ........................... Setup width and color for tracks and frames
C
      INCLUDE 'DALI_CF.INC'
      DIMENSION DLIN(2),ICOL(2)
      IF(FPIKDP) THEN
        M2=1
        ICOL(1)=-1
      ELSE
        CALL DSCTR
        CALL DPARGV(87,'STR',2,D)
        IF(PARADA(4,JCFR).GT.0.) THEN
          ICOL(1)=PARADA(2,JCFR)
          M2=2
          CALL DPARGV(87,'SFR',2,W)
          DLIN(1)=D+W*2.
          DLIN(2)=D
        ELSE
          M2=1
          DLIN(1)=D
        END IF
        IF(PARADA(4,JCTR).GT.0.) THEN
          ICOL(M2)=PARADA(2,JCTR)
C         ................................... brain test with RO stereo
          IF(FLEYDB) THEN
            CALL DPAR_SET_CO(48,'CLE')
            IF(ICOLDP.GT.0) ICOL(M2)=ICOLDP
          END IF
        ELSE
          IF(FVTRDC) THEN
            ICOL(M2)=-1
          ELSE
            ICOL(M2)=PARADA(2,JCTR)
          END IF
        END IF
      END IF
      END
*DK DAPVC
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DAPVC
CH
      SUBROUTINE DAPVC(TPR,LAYVD)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C!:Draw points (VDCO) in All Projections
C    Inputs    :
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
CCC      CHARACTER *2 TPR,DT2
      CHARACTER *2 TPR
      DATA QCP/-0.012883/,FOVER/40./
      EQUIVALENCE (KPIKDP,K)
      DIMENSION ROVD(2,2)
      DIMENSION WA(2),MA(2),MX(2),MR(2),MC(2),LCOL(2)
      DATA MA/8,8/,MX/8,3/,MR/8,6/,MC/8,3/
      DATA DWR/0./,DWX/2./,DWC/1./,LCOL/1,8/,J1/1/
      LOGICAL FOUT,FCOL(2),FCOLT,FUSFI,FUSTE
      DATA FCOL(1)/.FALSE./
      IF(.NOT.FVDEDR) RETURN
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TSUBDJ='DAPVC'
      TPARDA=
     &  'J_PFI,J_PTE,J_PPU,J_RAL'
      CALL DPARAM(10
     &  ,J_PFI,J_PTE,J_PPU,J_RAL)
      TPARDA=
     &  'J_HVD'
      CALL DPARAM(20
     &  ,J_HVD)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      IF(PARADA(4,J_HVD).EQ.0) RETURN
      CALL DPARGV(60,'SFR',2,DFRAM)
      MOHT=PARADA(4,J_HVD)
      FCOL(2)=.FALSE.
      IF(.NOT.FPIKDP) THEN
C       ........................................ setup colors
        CALL DSC_CONST(FCOL,NCOL)
        IF(NCOL.GE.0) THEN
          LCOL(2)=NCOL
        ELSE
          CALL DPARGI(70,'FVC',MO)
          IF(MO.EQ.0) THEN
C           ............................................ constant color
            CALL DPARGI(50,'CCO',LCOL(2))
          ELSE
C           ............................................ color = track color
            FCOL(2)=.TRUE.
            CALL DPARGI(50,'CUH',NCTRDC(0))
            CALL DSCTR0(FCOLT,NCOL)
          END IF
        END IF
      END IF
C     ........................................................ INITIALISE BANK
    1 CALL DV0(VDCODB,NUM1,NUM2,FOUT)
      IF(FOUT) RETURN
C     ....................................................... SET UP FI/TE CUT
      CALL DCUTTF(FUSFI,FC1,FC2,FUSTE,TC1,TC2)
      FIMID=PARADA(2,J_PFI)
      TEMID=PARADA(2,J_PTE)
C     ..................................................... SET UP PROJECTIONS
      CALL DPARGV(60,'SSZ',2,WA(2))
      IF     (TPR.EQ.'YX') THEN
        NPR=1
      ELSE IF(TPR.EQ.'RZ') THEN
        IF(PARADA(4,J_PTE).NE.0.) THEN
          FUSFI=.TRUE.
          FMIN=FIMID-90.
          FMAX=FIMID+90.
          NPR=2
        ELSE
          NPR=3
        END IF
      ELSE IF(TPR.EQ.'FT') THEN
        FUSFI=.TRUE.
        IF(PARADA(4,J_PPU).EQ.1.) THEN
          FUSTE=.TRUE.
          PU=QCP*PARADA(2,J_PPU)
        ELSE
          PU=0.
        END IF
        IF(IZOMDO.EQ.0) FIMID=180.
        FUSTE=.TRUE.
        CALL DGIVDR(ROVD)
        DRO=0.5*(ROVD(1,LAYVD)+ROVD(2,LAYVD))
        IF(PARADA(2,J_HVD).NE.0.) MOHT=MAX(2,MOHT)
        NPR=4
      ELSE IF(TPR.EQ.'FZ') THEN
        FUSFI=.TRUE.
        IF(IZOMDO.EQ.0) FIMID=180.
        IF(PARADA(2,J_HVD).NE.0.) MOHT=MAX(2,MOHT)
        NPR=7
      ELSE IF(TPR.EQ.'FR') THEN
        FUSFI=.TRUE.
        IF(IZOMDO.EQ.0) FIMID=180.
        NPR=5
      ELSE IF(TPR.EQ.'RO') THEN
        SF=SIND(FIMID)
        CF=COSD(FIMID)
        ST=SIND(90.-PARADA(2,J_PTE))
        CT=COSD(90.-PARADA(2,J_PTE))
        SG=SIND(PARADA(2,J_RAL))
        CG=COSD(PARADA(2,J_RAL))
        NPR=6
      END IF
      WA(1)=WA(2)+2.*DFRAM
      CALL DPARGV(60,'SSC',2,SYMB)
      MA(2)=SYMB
      CALL DPARGV(50,'CFR',4,CFR4)
      IF(CFR4.LT.0.) THEN
        I1=2
      ELSE
        I1=J1
        CALL DPARGI(50,'CFR',LCOL(1))
      END IF
      DO I=I1,2
        CALL DGLEVL(LCOL(I))
        WX=WA(I)+DWX
        WR=WA(I)+DWR
        WC=WA(I)+DWC
        DO 300 K=NUM1,NUM2
          NTRVD=DVVDC(IVNTDV,K)
          IF(FCUHDT.AND.FNOHDT(NTRVD)) GO TO 300
          IF(FUSTE) THEN
            TE=DVVDC(IVTEDV,K)
            IF(TE.LT.TC1.OR.TE.GT.TC2) GO TO 300
          END IF
          IF(FUSFI) THEN
            FI=DFINXT(FIMID,DVVDC(IVFIDV,K))
            IF(FI.LT.FC1.OR.FI.GT.FC2) GO TO 300
          END IF
          IF(FCOL(I)) CALL DGLEVL(NCTRDC(NTRVD))
          DIR=DVVDC(14,K)
          IF(MOHT.EQ.3.AND.DIR.EQ.3.) GO TO 300
          IF(DIR.EQ.3.) CALL DQPD0(MA(I),WA(I),FOVER)
C                 YX SRZ +RZ  FT VFT  FR  RO
          GO TO (301,302,303,304,305,306,307) NPR
C         ................................................................. YX
  301     IF(DIR.EQ.1.) THEN
            CALL DQPD0(MR(I),WR,FOVER)
          ELSE IF(DIR.EQ.2.) THEN
            IF(MOHT.EQ.1) GO TO 300
            CALL DQPD0(MX(I),WX,FOVER)
          END IF
          H=DVVDC(IVXXDV,K)
          V=DVVDC(IVYYDV,K)
          GO TO 380
C         ...................................................... RZ(SIGNED RHO)
  302     IF(DIR.EQ.2.) THEN
            CALL DQPD0(MR(I),WR,FOVER)
          ELSE IF(DIR.EQ.1.) THEN
            IF(MOHT.EQ.1) GO TO 300
            CALL DQPD0(MX(I),WX,FOVER)
          END IF
          H=DVVDC(IVZZDV,K)
          IF(FI.GE.FMIN.AND.FI.LE.FMAX) THEN
            V=DVVDC(IVRODV,K)
          ELSE
            V=-DVVDC(IVRODV,K)
          END IF
          GO TO 380
C         .................................................. RZ(POSITIVE RHO)
  303     IF(DIR.EQ.2.) THEN
            CALL DQPD0(MR(I),WR,FOVER)
          ELSE IF(DIR.EQ.1.) THEN
            IF(MOHT.EQ.1) GO TO 300
            CALL DQPD0(MX(I),WX,FOVER)
          END IF
          H=DVVDC(IVZZDV,K)
          V=DVVDC(IVRODV,K)
          GO TO 380
C         .......................................................... FT (FR=V#)
  304     LAYER=DVVDC(13,K)
          IF(LAYER.LT.LAYVD) GO TO 300
          IF(PARADA(2,J_HVD).NE.0..AND.LAYER.NE.LAYVD) GO TO 300
          IF(DIR.EQ.3.) THEN
            IF(MOHT.EQ.3) GO TO 300
          ELSE
            IF(MOHT.EQ.1) GO TO 300
            CALL DQPD0(MR(I),WR,FOVER)
          END IF
          XX=DVVDC(IVXXDV,K)-VRTXDV
          YY=DVVDC(IVYYDV,K)-VRTYDV
          ZZ=DVVDC(IVZZDV,K)-VRDZDV
          RO=SQRT(XX*XX+YY*YY)
          DPU=PU*(RO-DRO)/SIND(TE)
          H=-DATN2D(RO,ZZ)
          FI=DATN2D(YY,XX)
          FI=DFINXT(FIMID,FI)
          IF(FPIKDP) THEN
            CALL DQPIF(H+DPU,FI)
            CALL DQPIF(H-DPU,FI)
          ELSE
            CALL DQPD(H+DPU,FI)
            CALL DQPD(H-DPU,FI)
            IF(IZOMDO.EQ.0.AND.FI.LE.FOVER) THEN
              CALL DQPD(H+DPU,FI+360.)
              CALL DQPD(H-DPU,FI+360.)
            END IF
          END IF
          GO TO 300
C         ............................................................... FR
  305     IF(DIR.EQ.1.) THEN
            CALL DQPD0(MR(I),WR,FOVER)
          ELSE IF(DIR.EQ.2.) THEN
            IF(MOHT.EQ.1) GO TO 300
            CALL DQPD0(MX(I),WX,FOVER)
          END IF
          H=DVVDC(IVRODV,K)
          IF(FPIKDP) THEN
            CALL DQPIF(H,FI)
          ELSE
            CALL DQPD(H,FI)
            IF(IZOMDO.EQ.0.AND.FI.LE.FOVER) CALL DQPD(H,FI+360.)
          END IF
          GO TO 300
C         ............................................................... RO
  306     IF(DIR.NE.3.) THEN
            IF(MOHT.EQ.1) GO TO 300
            CALL DQPD0(MC(I),WC,FOVER)
          END IF
          X1=DVVDC(IVXXDV,K)
          Y1=DVVDC(IVYYDV,K)
          Z1=DVVDC(IVZZDV,K)
          X2= CF*X1+SF*Y1
          Y2=-SF*X1+CF*Y1
          H = CT*X2+ST*Z1
          Z3=-ST*X2+CT*Z1
          V = CG*Y2+SG*Z3
          GO TO 380
C         .......................................................... FZ (FR=V#)
  307     LAYER=DVVDC(13,K)
          IF(LAYER.LT.LAYVD) GO TO 300
          IF(PARADA(2,J_HVD).NE.0..AND.LAYER.NE.LAYVD) GO TO 300
          IF(DIR.EQ.3.) THEN
            IF(MOHT.EQ.3) GO TO 300
          ELSE
            IF(MOHT.EQ.1) GO TO 300
            CALL DQPD0(MR(I),WR,FOVER)
          END IF
          FI=DVVDC(IVFIDV,K)
          V=DFINXT(FIMID,FI)
          H=DVVDC(IVZZDV,K)
          IF(FPIKDP) THEN
            CALL DQPIF(H,V)
          ELSE
            CALL DQPD(H,V)
            IF(IZOMDO.EQ.0.AND.V.LE.FOVER) CALL DQPD(H,V+360.)
          END IF
          GO TO 300
  380     IF(FPIKDP) THEN
            CALL DQPIK(H,V)
          ELSE
            CALL DQPD(H,V)
          END IF
  300   CONTINUE
        IF(FPIKDP) RETURN
      END DO
      END
*DK
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DAPPV
CH
      SUBROUTINE DAPPV(TPR,LAYER)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C!:Draw strips (VD) in All Projections
C    Inputs    :
C    Outputs   :
C
C    Called by :
C    FI,TE cuts cannot be done, as they are useless in the picture plane
C    and impossibble (2D data) in depth.
C ---------------------------------------------------------------------
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      DIMENSION IP(2)
      DATA IP/8,4/
C               FACEDV(SIDE,X or Y,PHI,LAYER)
      DIMENSION FACE(2,2,15,2)
      EQUIVALENCE (FACE,CRILDV)
      CHARACTER *2 TPR
      DATA FOVER/40./,F320/320./
      EQUIVALENCE (KPIKDP,K)
      DIMENSION ICOL(0:6)
      DATA IR1,IR2/4,9/
      DATA NP/12/
      DIMENSION MFRW(4)
      DATA MFRW/-1,-1,0,0/
      DIMENSION NWCU(8,2)
      DATA NWCU/1,1,3,3,0,0,1,3,
     &          2,2,4,4,0,0,2,4/

      LOGICAL FOUT,FCOL,FCOLT,FUSFI,FUSTE,FMOD,FGHST,FDASH
C     ............................ ONLY RESIDUALS ARE DRAWN BUT NOT OTHER HITS
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TSUBDJ='DAPPV'
      TPARDA=
     &  'J_PFI,J_PTE,J_FFA,J_FWA'
      CALL DPARAM(10
     &  ,J_PFI,J_PTE,J_FFA,J_FWA)
      TPARDA=
     &  'J_HVD'
      CALL DPARAM(20
     &  ,J_HVD)
      TPARDA=
     &  'J_STC'
      CALL DPARAM(31
     &  ,J_STC)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      IF(FGRYDR.AND.PARADA(4,J_STC).LT.0.) RETURN
C     .............................................. SET UP COLORS ; LAYER ON?
      IF(.NOT.FVDEDR) RETURN
      IF(PARADA(2,J_HVD).EQ.0.) RETURN

      CALL DPARGI(87,'SDA',NDASH)
      NDASH=2*NDASH

      MOHT=PARADA(2,J_HVD)
      FCOL=.FALSE.
      IF(PARADA(4,J_FWA).GT.0.) THEN
        NFACE=PARADA(2,J_FFA)
        NWAFR=PARADA(2,J_FWA)
        IF(     NWAFR.EQ.7) THEN
          NWFR1=1
          NWFR2=NWAFDV/2
        ELSE IF(NWAFR.EQ.8) THEN
          NWFR1=NWAFDV/2+1
          NWFR2=NWAFDV
        ELSE
          NWFR1=NWAFR
          NWFR2=NWAFR
        END IF
        IF(NWAFDV.EQ.4) THEN
          NWCU1=NWCU(NWAFR,1)
          NWCU2=NWCU(NWAFR,2)
        ELSE
          NWCU1=NWFR1
          NWCU2=NWFR2
        END IF
        FMOD=.TRUE.
      ELSE
        FMOD=.FALSE.
      END IF
      IF(.NOT.FPIKDP) THEN
C       ........................................ setup colors
        CALL DSC_CONST(FCOL,NCOL)
        IF(NCOL.LT.0) THEN
          CALL DPARGI(70,'FVD',MO)
          IF(MO.EQ.0) THEN
C           ............................................ constant color
            FCOL=.FALSE.
            CALL DPAR_SET_CO(50,'CHI')
          ELSE IF(MO.EQ.1) THEN
C           ............................................ color = track color
            FCOL=.TRUE.
            CALL DPARGI(50,'CUH',NCTRDC(0))
            CALL DSCTR0(FCOLT,NCOL)
          ELSE
C           ......................................... color of modul
            FCOL=.TRUE.
            CALL DPARGI(46,'CNU',NUCOL)
            NUCOL=MIN(7,NUCOL)
            CALL DPAR_GET_ARRAY(46,'CC1',NUCOL,ICOL)
          END IF
        END IF
      ELSE
        FCOL=.FALSE.
      END IF
      CALL DPARGI(83,'VNV',NP)
      FIMID=PARADA(2,J_PFI)
      TEMID=PARADA(2,J_PTE)
      IF(NWAFDV.GE.6) THEN
        NEWVD=2
      ELSE
        NEWVD=1
      END IF
C     ..................................................... SET UP PROJECTIONS
      FGHST=.FALSE.
      IF     (TPR.EQ.'YX') THEN
        CALL DV0(VDXYDB,NUM1,NUM2,FOUT)
        IF(FOUT) RETURN
        CALL DPAR_SET_SY(60,0.)
        NPR=1
      ELSE IF(TPR.EQ.'FR') THEN
        CALL DV0(VDXYDB,NUM1,NUM2,FOUT)
        IF(FOUT) RETURN
        CALL DPAR_SET_SY(60,FOVER)
        FUSFI=.TRUE.
        IF(IZOMDO.EQ.0) FIMID=180.
        NPR=2
      ELSE IF(TPR.EQ.'FI') THEN
        IF(FPIKDP.AND.LORPDP.EQ.2) RETURN
        CALL DV0(VDXYDB,NUM1,NUM2,FOUT)
        IF(FOUT) RETURN
        FUSFI=.TRUE.
        IF(IZOMDO.EQ.0) FIMID=180.
        MOHT=1
        NPR=3
        FGHST=.TRUE.
      ELSE IF(TPR.EQ.'TE') THEN
        IF(FPIKDP.AND.LORPDP.EQ.2) RETURN
        CALL DV0(VDZTDB,NUM1,NUM2,FOUT)
        IF(FOUT) RETURN
        FUSTE=.TRUE.
        IF(IZOMDO.EQ.0) THEN
          FIMID=180.
          FUSFI=.TRUE.
        END IF
        Q=1./FLOAT(NP)
        MOHT=1
        NPR=5
        FGHST=.TRUE.
      ELSE IF(TPR.EQ.'FZ') THEN
        IF(FPIKDP.AND.LORPDP.EQ.2) RETURN
        CALL DV0(VDXYDB,NUM1,NUM2,FOUT)
        IF(FOUT) RETURN
        FUSFI=.TRUE.
        IF(IZOMDO.EQ.0) FIMID=180.
        NPR=4
        MOHT=1
        FGHST=.TRUE.
      ELSE IF(TPR.EQ.'ZZ') THEN
        IF(FPIKDP.AND.LORPDP.EQ.2) RETURN
        CALL DV0(VDZTDB,NUM1,NUM2,FOUT)
        IF(FOUT) RETURN
        MOHT=1
        NPR=7
        FGHST=.TRUE.
      ELSE IF(TPR.EQ.'RZ') THEN
        CALL DV0(VDZTDB,NUM1,NUM2,FOUT)
        IF(FOUT) RETURN
        IF(PARADA(4,J_PTE).NE.0.) THEN
          FUSFI=.TRUE.
          FMIN=FIMID-90.
          FMAX=FIMID+90.
        ELSE
          FMAX= 999.
          FMIN=-999.
        END IF
        NPR=6
      END IF
      IF(NWAFDV.LT.6) FGHST=.FALSE.
      CALL DPAR_SET_WIDTH(60,'SWI',87,'SDW')
C     FACE:IVNNDV   LAYER:IVKKDV   WAFER (2 WAFERS = 1 MODULE): IVJJDV
C     IN XY: WAFER =1 OR 4
      DO L=1,2
        DO 300 K=NUM1,NUM2
          IF(NPR.LE.4) THEN
            NTRVD=DVVDXY(IVNTDV,K)
            IF(L.EQ.1) THEN
              IF(NTRVD.GT.0) GO TO 300
            ELSE
              IF(NTRVD.LE.0) GO TO 300
            END IF
            IL=DVVDXY(IVKKDV,K)
            NF=DVVDXY(IVNNDV,K)
            NW=DVVDXY(IVJJDV,K)
          ELSE
            NTRVD=DVVDRZ(IVNTDV,K,1)
            IF(L.EQ.1) THEN
              IF(NTRVD.GT.0) GO TO 300
            ELSE
              IF(NTRVD.LE.0) GO TO 300
            END IF
            IL=DVVDRZ(IVKKDV,K,1)
            NF=DVVDRZ(IVNNDV,K,1)
            NW=DVVDRZ(IVJJDV,K,1)
          END IF
          FDASH=.FALSE.
          IF(NTRVD.LT.0) THEN
            IF(FGHST) THEN
              FDASH=.TRUE.
              NTRVD=-NTRVD
            ELSE
              NTRVD=0
            END IF
          END IF
          IF(FCUHDT.AND.FNOHDT(NTRVD)) GO TO 300
          IF(MOHT.EQ.2.AND.NTRVD.NE.0) GO TO 300
          IF(MOHT.EQ.3.AND.NTRVD.EQ.0) GO TO 300
          IF(FCOL) THEN
            IF(MO.EQ.2) THEN
              MODUL=2*NF+MFRW(NW)
              NCOL=MOD(MODUL,NUCOL)
              CALL DGLEVL(ICOL(NCOL))
            ELSE
              CALL DGLEVL(NCTRDC(NTRVD))
            END IF
          END IF
C                 YX  FR  FI  FZ  TE  RZ  ZZ
          GO TO (301,302,303,304,305,306,307) NPR
C       ................................................................... YX
  301     H=DVVDXY(IVXXDV,K)
          V=DVVDXY(IVYYDV,K)
          IF(FPIKDP) THEN
            CALL DQPIK(H,V)
          ELSE
            CALL DQPD(H,V)
          END IF
          GO TO 300
C         ................................................................. FR
  302     H=DVVDXY(IVRODV,K)
          FI=DVVDXY(IVFIDV,K)
          V=DFINXT(FIMID,FI)
          IF(FPIKDP) THEN
            CALL DQPIF(H,V)
          ELSE
            CALL DQPD(H,V)
            IF(IZOMDO.EQ.0.AND.V.LE.FOVER) CALL DQPD(H,V+360.)
          END IF
          GO TO 300
C         ............................................................. FI (FT)
  303     IF(IL.NE.LAYER) GO TO 300
          XX=DVVDXY(IVXXDV,K)-VRTXDV
          YY=DVVDXY(IVYYDV,K)-VRTYDV
          FI=DATN2D(YY,XX)
          V=DFINXT(FIMID,FI)
          RO=SQRT(XX*XX+YY*YY)
          IF(NWAFDV.EQ.4) THEN
            IF(NW.LE.2) THEN
              NV1=1
              NV2=2
            ELSE
              NV1=3
              NV2=4
            END IF
          ELSE
            NV1=NW
            NV2=NW
          END IF
          IF(FDASH) CALL DGDASH(NDASH,IP)
          DO NV=NV1,NV2
            H1=-DATN2D(RO,ZLFTDV(NV,IL)-VRDZDV)
            H2=-DATN2D(RO,ZRGTDV(NV,IL)-VRDZDV)
            CALL DQL2EP(H1,V,H2,V)
            IF(IZOMDO.EQ.0.AND.FI.LE.FOVER) THEN
              V360=V+360.
              CALL DQL2EP(H1,V360,H2,V360)
              CALL DQL2EP(H3,V360,H4,V360)
            END IF
          END DO
          IF(FDASH) CALL DGDASH(0,0)
          GO TO 300
C         ............................................................. FI (FZ)
  304     IF(IL.NE.LAYER) GO TO 300
          IF(FMOD) THEN
            IF(NF.NE.NFACE) GO TO 300
            IF(NW.LT.NWCU1.OR.
     &         NW.GT.NWCU2) GO TO 300
          END IF
          UU=DVVDXY(10,K)
          FIM=FIMDDV(NF,IL)
          IF(IZOMDO.NE.0) FIM=DFINXT(FIMID,FIM)
          V=FIMDDV(NF,IL)+UU*FISCDV
          IF(NWAFDV.EQ.4) THEN
            IF(NW.LE.2) THEN
              NV1=1
              NV2=2
            ELSE
              NV1=3
              NV2=4
            END IF
          ELSE
            NV1=NW
            NV2=NW
          END IF
          IF(FDASH) CALL DGDASH(NDASH,IP)
          DO NV=NV1,NV2
            CALL DQL2EP(ZLFTDV(NV,IL),V,ZRGTDV(NV,IL),V)
          END DO
          IF(V.LE.FOVER) THEN
            V=V+360.
            DO NV=NV1,NV2
              CALL DQL2EP(ZLFTDV(NV,IL),V,ZRGTDV(NV,IL),V)
            END DO
          END IF
          IF(FDASH) CALL DGDASH(0,0)
          GO TO 300
C         ............................................................. TE (FT)
  305     IF(IL.NE.LAYER) GO TO 300
          X1=FACE(1,1,NF,IL)-VRTXDV
          X2=FACE(1,2,NF,IL)-VRTXDV
          Y1=FACE(2,1,NF,IL)-VRTYDV
          Y2=FACE(2,2,NF,IL)-VRTYDV
          ZZ=DVVDRZ(IVZZDV,K,1)-VRDZDV
          DX=(X2-X1)*Q
          DY=(Y2-Y1)*Q
          X=X1
          Y=Y1
          RO1=SQRT(X*X+Y*Y)
          F1=DATN2D(Y,X)
          F0=F1
          T1=DATN2D(RO1,ZZ)
          IDASH=1
          DO 700 N=1,NP
            X=X+DX
            Y=Y+DY
            RO2=SQRT(X*X+Y*Y)
            F2=DFINXT(F0,DATN2D(Y,X))
            T2=DATN2D(RO2,ZZ)
            IDASH=-IDASH
            IF(.NOT.FDASH.OR.MOD(N,2).NE.0) THEN
              CALL DQL2EP(-T1,F1,-T2,F2)
              IF(F0.LT.FOVER) THEN
                CALL DQL2EP(-T1,F1+360.,-T2,F2+360.)
              ELSE IF(F0.GT.F320) THEN
                CALL DQL2EP(-T1,F1-360.,-T2,F2-360.)
              END IF
            END IF
            T1=T2
            F1=F2
  700     CONTINUE
          GO TO 300
C         ................................................................. RZ
  306     H=DVVDRZ(IVZZDV,K,1)
          FI=DFINXT(FIMID,DVVDRZ(IVFIDV,K,1))
          IF(FI.GE.FMIN.AND.FI.LE.FMAX) THEN
            V1=DVVDRZ(IR1,K,1)
            V2=DVVDRZ(IR2,K,1)
          ELSE
            V1=-DVVDRZ(IR1,K,1)
            V2=-DVVDRZ(IR2,K,1)
          END IF
          IF(FPIKDP) THEN
            CALL DQPIK(H,V1)
            CALL DQPIK(H,V2)
          ELSE
            CALL DQL2E(H,V1,H,V2)
          END IF
          GO TO 300
C         ............................................................. ZZ (FZ)
  307     IF(IL.NE.LAYER) GO TO 300
          IF(FMOD) THEN
            IF(NF.NE.NFACE) GO TO 300
            IF(NW.LT.NWCU1.OR.
     &         NW.GT.NWCU2) GO TO 300
          END IF
          UU=DVVDRZ(10,K,1)
          ZZ=ZOFWDV(NW)+UU
          DF=FISCDV*DLFIDV(NF,IL)
          F1=FIMDDV(NF,IL)-DF
          F2=FIMDDV(NF,IL)+DF
          IF(FDASH) CALL DGDASH(NDASH,IP)
          CALL DQL2EP(ZZ,F1,ZZ,F2)
          IF(F1.LT.FOVER) THEN
            CALL DQL2EP(ZZ,F1+360.,ZZ,F2+360.)
          ELSE IF(F2.GT.F320) THEN
            CALL DQL2EP(ZZ,F1-360.,ZZ,F2-360.)
          END IF
          IF(FDASH) CALL DGDASH(0,0)
          GO TO 300
  300   CONTINUE
      END DO
      CALL DPAR_SET_TR_WIDTH
      END
*DK DAPTRF
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DAPTRF
CH
      SUBROUTINE DAPTRF(TPR)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C!:Draw points of fitted coordinates in All Projections
C      The points result from the Fit of one track from the Lohse routines.
C    Inputs    :
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      CHARACTER *2 TPR
C
      COMMON / INFDAL / NLOW, NHIGH, XSTS, XME, RF, IUSED, VMEAS
C
      PARAMETER (MPT=40)
      INTEGER IUSED(MPT)
      DOUBLE PRECISION XSTS(5,MPT),XME(2,MPT),RF(MPT),VMEAS(2,2,MPT)
      DATA PIDEG/57.29577951/
      DATA ZMAX/217./,RMAX/170.622/
      DATA QCP/-0.012883/,FOVER/40./,QS/2./
      EQUIVALENCE (KPIKDP,K)
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TSUBDJ='DAPTRF'
      TPARDA=
     &  'J_PFY,J_PFI,J_PTE,J_PPU,J_RAL'
      CALL DPARAM(10
     &  ,J_PFY,J_PFI,J_PTE,J_PPU,J_RAL)
      TPARDA=
     &  'J_STC'
      CALL DPARAM(31
     &  ,J_STC)
      TPARDA=
     &  'J_SSY,J_SSZ'
      CALL DPARAM(62
     &  ,J_SSY,J_SSZ)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      IF(.NOT.FGRYDR) THEN
        PARADA(2,J_STC)=0.
        RETURN
      END IF
      NTR=PARADR(2,1)
      CALL DVFTR(NTR,NPNTDR)
      NUM1=1
      NUM2=NPNTDR
      IF(FPIKDP) THEN
        IF(PARADA(2,J_STC).NE.PARADR(2,1)) THEN
          CALL DWRT('Track not active. Select track in RS.')
          RETURN
        END IF
        IF(FPIMDP) THEN
          IF(MDLPDP.NE.1000+NTR) THEN
            CALL DWRT('Wrong track.')
            RETURN
          END IF
          NUM1=NPIKDP
          NUM2=NPIKDP
        ELSE
          MDLRDP=1000+NTR
        END IF
      ELSE
        IF(FGRYDR) THEN
          PARADA(2,J_STC)=PARADR(2,1)
          PARADA(4,J_STC)=PARADR(4,2)
        ELSE
          PARADA(2,J_STC)=0.
          PARADA(4,J_STC)=0.
        END IF
      END IF
      FIMID=PARADA(2,J_PFI)
      TEMID=PARADA(2,J_PTE)
C//   CALL DQPD0(MSYMDL(MTPCDL,0),QS*WDSNDL(2,4,MTPCDL),0.)
      CALL DQPD0(IDPAR(J_SSY),QS*PARADA(2,J_SSZ),0.)
C     ..................................................... SET UP PROJECTIONS
      IF     (TPR.EQ.'YX') THEN
        NPR=1
      ELSE IF(TPR.EQ.'RZ') THEN
        IF(PARADA(4,J_PTE).NE.0.) THEN
          FMIN=FIMID-90.
          FMAX=FIMID+90.
          NPR=2
        ELSE
          NPR=3
        END IF
      ELSE IF(TPR.EQ.'FT') THEN
        IF(PARADA(4,J_PPU).EQ.1.) THEN
          PU=QCP*PARADA(2,J_PPU)
          NPR=4
        ELSE
          PU=0.
          NPR=6
        END IF
        IF(IZOMDO.EQ.0) FIMID=180.
      ELSE IF(TPR.EQ.'FR') THEN
        IF(IZOMDO.EQ.0) FIMID=180.
        NPR=7
      ELSE IF(TPR.EQ.'FZ') THEN
        IF(IZOMDO.EQ.0) FIMID=180.
        NPR=8
      ELSE IF(TPR.EQ.'YZ') THEN
        SF=SIND(PARADA(2,J_PFY))
        CF=COSD(PARADA(2,J_PFY))
C        CF=COSD(FIMID)
        NPR=9
      ELSE IF(TPR.EQ.'HF') THEN
        CALL DWRT('Hits with residual colours are not drawn in HF.')
        RETURN
      ELSE IF(TPR.EQ.'RO') THEN
        SF=SIND(FIMID)
        CF=COSD(FIMID)
        ST=SIND(90.-PARADA(2,J_PTE))
        CT=COSD(90.-PARADA(2,J_PTE))
        SG=SIND(PARADA(2,J_RAL))
        CG=COSD(PARADA(2,J_RAL))
        NPR=11
      END IF
      DO 200 K=NUM1,NUM2
C       IF(IUSED(K).NE.1) GO TO 200
        CALL DRSRTN(RF(K),IH,NDEV,LEV)
        CALL DGLEVL(LEV)
        FI_7=PIDEG*XME(1,K)/RF(K)
        FI=DFINXT(FIMID,FI_7)

C
C       ...................................................... XME(1)=rho*phi
C       ...................................................... XME(2)=Z
C       ......................................................    RF = rho
C
        GO TO (201,202,203,204,204,206,207,208,209,209,211) NPR
C       ................................................................. YX
  201   RO=RF(K)
        H=RO*COSD(FI)
        V=RO*SIND(FI)
        GO TO 280
C        ...................................................... RZ(SIGNED RHO)
  202   H=XME(2,K)
        IF(FI.GE.FMIN.AND.FI.LE.FMAX) THEN
          V= RF(K)
        ELSE
          V=-RF(K)
        END IF
        GO TO 280
C         .................................................... RZ(POSITIVE RHO)
  203   H=XME(2,K)
        V=RF(K)
        GO TO 280
C       ............................................................ FT(PU#0)
  204   IF(NDEV.NE.3) GO TO 300
        RO=RF(K)
        Z=XME(2,K)
        ZA=ABS(Z)
        D0=SQRT(Z**2+RO**2)
        IF(RO*ZMAX.GT.ZA*RMAX) THEN
           B=D0*(RMAX/RO-1.)
        ELSE
           B=D0*(ZMAX/ZA-1.)
        END IF
        DPU=PU*B
        TEDZ=DATN2D(RO,Z-VRDZDV)
        IF(TEDZ.LE.90.) THEN
          TE=TEDZ-QTETDV*TEDZ
        ELSE
          TE=TEDZ-QTETDV*(180.-TEDZ)
        END IF
        H=-TE
        IF(FPIKDP) THEN
          CALL DQPIF(H+DPU,FI)
          CALL DQPIF(H-DPU,FI)
        ELSE
          CALL DQPD(H+DPU,FI)
          CALL DQPD(H-DPU,FI)
          IF(IZOMDO.EQ.0.AND.FI.LE.FOVER) THEN
            CALL DQPD(H+DPU,FI+360.)
            CALL DQPD(H-DPU,FI+360.)
          END IF
        END IF
        GO TO 200
C       ............................................................ FT(PU=0)
  206   IF(NDEV.NE.3) GO TO 300
        RO=RF(K)
        Z=XME(2,K)
        H=-DATN2D(RO,Z)
        GO TO 290
C       ................................................................. FR
  207   H=RF(K)
        GO TO 290
C       ................................................................. FZ
  208   H=XME(2,K)
        GO TO 290
C       ................................................................. YZ
  209   H=XME(2,K)
        RO=RF(K)
        X=RO*COSD(FI)
        Y=RO*SIND(FI)
        V=-SF*X+CF*Y
        GO TO 280
C       ................................................................. RO
  211   Z1=XME(2,K)
        RO=RF(K)
        X1=RO*COSD(FI)
        Y1=RO*SIND(FI)
C       .................................................... X2= CF*X1+SF*Y1
C       .................................................... Y2=-X1*SF+CF*Y1
C       .................................................... Z2= Z1
C       .................................................... X3= CT*X2+ST*Z2
C       .................................................... Y3= Y2
C       .................................................... Z3=-ST*X2+CT*Z2
C       ...................................................H=X4= X3
C       .................................................. V=Y4= CG*Y3+SG*Z3
C       .................................................... Z4=-SG*Y3+CG*Z3
        X2= CF*X1+SF*Y1
        Y2=-SF*X1+CF*Y1
        H = CT*X2+ST*Z1
        Z3=-ST*X2+CT*Z1
        V = CG*Y2+SG*Z3
        GO TO 280
  280   IF(FPIKDP) THEN
          CALL DQPIK(H,V)
        ELSE
          CALL DQPD(H,V)
        END IF
        GO TO 200
  290   IF(FPIKDP) THEN
          CALL DQPIF(H,FI)
        ELSE
          CALL DQPD(H,FI)
          IF(IZOMDO.EQ.0.AND.FI.LE.FOVER) CALL DQPD(H,FI+360.)
        END IF
  200 CONTINUE
  300 RETURN
      END
*DK DATN2D
CH..............***
CH
CH
CH
CH
CH
CH
CH ********************************************************************  DATN2D
CH
      FUNCTION DATN2D(Y,X)
CH
CH ********************************************************************
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C!:
C    Inputs    :
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
      DATA PIDEG/57.29577951/
      IF(Y.EQ.0..AND.X.EQ.0.) GO TO 9
      DATN2D=PIDEG*ATAN2(Y,X)
      IF(DATN2D.LT.0.) DATN2D=DATN2D+360.
      RETURN
    9 DATN2D=0.
      RETURN
      END
*DK DAPTRN
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DAPTRF
CH
      SUBROUTINE DAPTRN(TPR,NTR)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C  DRAW TRACK NUMBER AT LAST POINT OF TRACK
C    Inputs    :PROJECTION AND TRACK NUMBER
C ---------------------------------------------------------------------
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      CHARACTER *2 TPR,DT2,TR
      LOGICAL FOUT,FTPC,FIN,FSR,FANG
      DATA FOVER/40./,F360/360./
C// ?      DATA DFT/-1.5/,ML/0/
      DATA DFT/-1.5/
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TSUBDJ='DAPTRN'
      TPARDA=
     &  'J_PFY,J_PFI,J_PTE,J_RAL'
      CALL DPARAM(10
     &  ,J_PFY,J_PFI,J_PTE,J_RAL)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      IF(NTR.EQ.0) THEN
        FIMID=PARADA(2,J_PFI)
        TEMID=PARADA(2,J_PTE)
        IF(TPR(1:1).EQ.'F') THEN
          FANG=.TRUE.
          IF(IZOMDO.EQ.0) FIMID=180.
        ELSE
          FANG=.FALSE.
        END IF
        FOUT=.TRUE.
        IF(FPIKDP.OR.NTRNDS.EQ.0) RETURN
        CALL DV0(TPCODB,N1,N2,FOUT)
        IF(N2.EQ.0) GO TO 9
        CALL=DVCHT0(NUM)
        IF(NUM.EQ.0) GO TO 9
        FOUT=.FALSE.
        IF(TPR.EQ.'RZ') THEN
          IF(PARADA(4,J_PTE).NE.0.) THEN
            FSR=.TRUE.
            FMIN=FIMID-90.
            FMAX=FIMID+90.
          ELSE
            FSR=.FALSE.
          END IF
        ELSE IF(TPR.EQ.'YZ') THEN
          SF=SIND(PARADA(2,J_PFY))
          CF=COSD(PARADA(2,J_PFY))
        ELSE IF(TPR.EQ.'3D'.OR.TPR.EQ.'RS') THEN
          FOUT=.TRUE.
        ELSE IF(TPR.EQ.'RO') THEN
C// ??    CALL DQPD0(MSYMDL(ML,0),WDSNDL(2,4,ML),0.)
          SF=SIND(FIMID)
          CF=COSD(FIMID)
          ST=SIND(90.-TEMID)
          CT=COSD(90.-TEMID)
          SG=SIND(PARADA(2,J_RAL))
          CG=COSD(PARADA(2,J_RAL))
        END IF
        RETURN
      END IF
      IF(FOUT) RETURN
      CALL DVTRLP(NTR,NLAST,FTPC)
      IF(.NOT.FTPC) RETURN
      IF(TPR.EQ.'YX') THEN
        H=DVTP(IVXXDV,NLAST)
        V=DVTP(IVYYDV,NLAST)
      ELSE IF(TPR.EQ.'RZ') THEN
        FI=DFINXT(FIMID,DVTP(IVFIDV,NLAST))
        H=DVTP(IVZZDV,NLAST)
        V=DVTP(IVRODV,NLAST)
        IF(FSR.AND.(FI.LT.FMIN.OR.FI.GT.FMAX)) V=-V
      ELSE IF(TPR.EQ.'FT') THEN
        H=-DVTP(IVTEDV,NLAST)-DFT
        V= DVTP(IVFIDV,NLAST)
      ELSE IF(TPR.EQ.'FR') THEN
        H=DVTP(IVRODV,NLAST)
        V=DVTP(IVFIDV,NLAST)
      ELSE IF(TPR.EQ.'FZ') THEN
        H=DVTP(IVZZDV,NLAST)
        V=DVTP(IVFIDV,NLAST)
      ELSE IF(TPR.EQ.'YZ') THEN
        H=DVTP(IVZZDV,NLAST)
        V=-SF*DVTP(IVXXDV,NLAST)+CF*DVTP(IVYYDV,NLAST)
      ELSE IF(TPR.EQ.'RO') THEN
        X1=DVTP(IVXXDV,NLAST)
        Y1=DVTP(IVYYDV,NLAST)
        Z1=DVTP(IVZZDV,NLAST)
        X2= CF*X1+SF*Y1
        Y2=-SF*X1+CF*Y1
        H = CT*X2+ST*Z1
        Z3=-ST*X2+CT*Z1
        V = CG*Y2+SG*Z3
      END IF
      CALL DQPOC(H,V,HH,VV,FIN)
      IF(FIN) THEN
        TR=DT2(FLOAT(NTR))
        CALL DGTEXT(HH,VV,TR,2)
      END IF
      IF(FANG.AND.VV.LT.FOVER) THEN
        CALL DQPOC(H,V+F360,HH,VV,FIN)
        IF(FIN) THEN
          TR=DT2(FLOAT(NTR))
          CALL DGTEXT(HH,VV,TR,2)
        END IF
      END IF
      RETURN
    9 CALL DWRT(' TPCO or FRTL or FTCL are missing!')
      END
*DK DAP_KNV
CH..............***
CH
CH
CH
CH
CH
CH
CH ****************************************************************  DAP_KNV
CH
      SUBROUTINE DAP_KNV(TIN,LAYVD)
CH
CH ********************************************************************
CH
C ---------------------------------------------------------------------
C
C    draw kink and nuclear interaction vertices
C
C    Inputs    : projection
C
      INCLUDE 'DALI_CF.INC'
      CHARACTER *2 TIN
      DIMENSION HEL(61),VEL(61),HAX(2,2),VAX(2,2),XYZ(3)
      DIMENSION SCA(2,3)
      DATA QCP/-0.012883/,FOVER/40./,DROST/0./
      DATA ROPHI/10./,ROFR/6./
      DIMENSION ROVD(2,2)
      LOGICAL FOUT
      IF(BNUMDB(4,YKNVDB).LE.0.) RETURN
      NVX=BNUMDB(2,YKNVDB)
      IF(NVX.EQ.0) RETURN
      IF(FPIKDP) RETURN
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TSUBDJ='DAP_KNV'
      TPARDA=
     &  'J_PFY,J_PFI,J_PTE,J_PPU,J_RAL'
      CALL DPARAM(10
     &  ,J_PFY,J_PFI,J_PTE,J_PPU,J_RAL)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      IF(TIN.EQ.'RO') THEN
        SCA(1,1)=SIND(    PARADA(2,J_PFI))
        SCA(2,1)=COSD(    PARADA(2,J_PFI))
        SCA(1,2)=SIND(90.-PARADA(2,J_PTE))
        SCA(2,2)=COSD(90.-PARADA(2,J_PTE))
        SCA(1,3)=SIND(    PARADA(2,J_RAL))
        SCA(2,3)=COSD(    PARADA(2,J_RAL))
      ELSE IF(TIN.EQ.'FT') THEN
        IF(PARADA(4,J_PPU).EQ.1.) THEN
          PU=QCP*PARADA(2,J_PPU)
        ELSE
          PU=0.
        END IF
        SCA(1,1)=VRDZDV
        IF(LAYVD.EQ.0) THEN
          DRO=DROST
        ELSE IF(LAYVD.LE.2) THEN
          CALL DGIVDR(ROVD)
          DRO=0.5*(ROVD(1,LAYVD)+ROVD(2,LAYVD))
        END IF
      ELSE IF(TIN.EQ.'RZ') THEN
        IF(PARADA(4,J_PTE).NE.0.) THEN
          FIMID=PARADA(2,J_PFI)
          FMIN=FIMID-90.
          FMAX=FIMID+90.
        ELSE
          FMIN=-999.
          FMAX= 999.
        END IF
      ELSE IF(TIN.EQ.'YZ') THEN
C       ................................... Y'=-SIN*X+COS*Y
        SCA(1,1)=SIND(PARADA(2,J_PFY))
        SCA(2,1)=COSD(PARADA(2,J_PFY))
      END IF
      DO 1 N=1,NVX
        CALL DVX1(N,2,FOUT,DUM)
        IF(FOUT) GO TO 1
        CALL DVKNV(N,XYZ)
        IF(TIN.EQ.'RO') THEN
          X2= SCA(2,1)*XYZ(1)+SCA(1,1)*XYZ(2)
          Y2=-SCA(1,1)*XYZ(1)+SCA(2,1)*XYZ(2)
          H = SCA(2,2)*X2    +SCA(1,2)*XYZ(3)
          Z3=-SCA(1,2)*X2    +SCA(2,2)*XYZ(3)
          V = SCA(2,3)*Y2    +SCA(1,3)*Z3
          CALL DQPD(H,V)
        ELSE IF(TIN.EQ.'FT') THEN
          RO=DVCORD(XYZ,IVRODV)
          IF(RO.LT.ROPHI) GO TO 1
          TE=DATN2D(RO,XYZ(3)-VRDZDV)
          IF(TE.LE.90.) THEN
            DH=QTETDV*TE
          ELSE
            DH=QTETDV*(180.-TE)
          END IF
          FI=DVCORD(XYZ,IVFIDV)
          IF(LAYVD.GT.2) THEN
            DPU=PU*DVCORD(XYZ,IVRBDV)
          ELSE
            DPU=PU*(RO-DRO)/SIND(TE)
          END IF
          CALL DQPD(-TE+DH-DPU,FI)
          CALL DQPD(-TE+DH+DPU,FI)
          IF(IZOMDO.EQ.0.AND.FI.LE.FOVER) THEN
            CALL DQPD(-TE+DH-DPU,FI+360.)
            CALL DQPD(-TE+DH+DPU,FI+360.)
          END IF
        ELSE IF(TIN.EQ.'FZ') THEN
          RO=DVCORD(XYZ,IVRODV)
          IF(RO.GT.ROPHI) THEN
            FI=DVCORD(XYZ,IVFIDV)
            CALL DQPD(XYZ(3),FI)
            IF(IZOMDO.EQ.0.AND.FI.LE.FOVER) CALL DQPD(XYZ(3),FI+360.)
          END IF
        ELSE IF(TIN.EQ.'FR') THEN
          RO=DVCORD(XYZ,IVRODV)
          IF(RO.GE.ROFR) THEN
            FI=DVCORD(XYZ,IVFIDV)
            CALL DQPD(RO,FI)
            IF(IZOMDO.EQ.0.AND.FI.LE.FOVER) CALL DQPD(RO,FI+360.)
          END IF
        ELSE IF(TIN.EQ.'RZ') THEN
          RO=DVCORD(XYZ,IVRODV)
          FI=DVCORD(XYZ,IVFIDV)
          FI=DFINXT(FIMID,FI)
          IF(FI.LT.FMIN.OR.FI.GT.FMAX) RO=-RO
          CALL DQPD(XYZ(3),RO)
        ELSE IF(TIN.EQ.'YZ') THEN
          V=-SCA(1,1)*XYZ(1)+SCA(2,1)*XYZ(2)
          CALL DQPD(XYZ(3),V)
        ELSE IF(TIN.EQ.'YX') THEN
          CALL DQPD(XYZ(1),XYZ(2))
        END IF
    1 CONTINUE
      END
*DK DAPVX
CH..............***
CH
CH
CH
CH
CH
CH
CH ********************************************************************  DAPVX
CH
      SUBROUTINE DAPVX(TIN,LAYVD)
CH
CH ********************************************************************
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C!:  draw error ellipse of vertices in PYER
C    Inputs    : projection
C
      INCLUDE 'DALI_CF.INC'
CCC      CHARACTER *2 TPR,TIN
      CHARACTER *2 TIN
      DIMENSION HEL(61),VEL(61),HAX(2,2),VAX(2,2),XYZ(3)
      DIMENSION SCA(2,3)
      DATA QCP/-0.012883/,FOVER/40./,DROST/0./
      DATA ROPHI/10./,ROFR/6./
      DIMENSION ROVD(2,2)
      LOGICAL FOUT
      IF(BNUMDB(4,PYERDB).LE.0.) RETURN
      NVX=BNUMDB(2,PYERDB)
      IF(NVX.EQ.0) RETURN
      IF(FPIKDP) RETURN
      SOLD=-1.
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TSUBDJ='DAPVX'
      TPARDA=
     &  'J_PFY,J_PFI,J_PTE,J_PPU,J_RAL'
      CALL DPARAM(10
     &  ,J_PFY,J_PFI,J_PTE,J_PPU,J_RAL)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      IF(TIN.EQ.'RO') THEN
        SCA(1,1)=SIND(    PARADA(2,J_PFI))
        SCA(2,1)=COSD(    PARADA(2,J_PFI))
        SCA(1,2)=SIND(90.-PARADA(2,J_PTE))
        SCA(2,2)=COSD(90.-PARADA(2,J_PTE))
        SCA(1,3)=SIND(    PARADA(2,J_RAL))
        SCA(2,3)=COSD(    PARADA(2,J_RAL))
      ELSE IF(TIN.EQ.'FT') THEN
        IF(PARADA(4,J_PPU).EQ.1.) THEN
          PU=QCP*PARADA(2,J_PPU)
        ELSE
          PU=0.
        END IF
        SCA(1,1)=VRDZDV
        IF(LAYVD.EQ.0) THEN
          DRO=DROST
        ELSE IF(LAYVD.LE.2) THEN
          CALL DGIVDR(ROVD)
          DRO=0.5*(ROVD(1,LAYVD)+ROVD(2,LAYVD))
        END IF
      ELSE IF(TIN.EQ.'RZ') THEN
        IF(PARADA(4,J_PTE).NE.0.) THEN
          FIMID=PARADA(2,J_PFI)
          FMIN=FIMID-90.
          FMAX=FIMID+90.
        ELSE
          FMIN=-999.
          FMAX= 999.
        END IF
      ELSE IF(TIN.EQ.'YZ') THEN
C       ................................... Y'=-SIN*X+COS*Y
        SCA(1,1)=SIND(PARADA(2,J_PFY))
        SCA(2,1)=COSD(PARADA(2,J_PFY))
      END IF
      DO 1 N=1,NVX
        CALL DVX1(N,1,FOUT,SIGMA)
        IF(FOUT) GO TO 1
        IF(SIGMA.NE.SOLD) THEN
          SOLD=SIGMA
          IF(SIGMA.EQ.0) THEN
            CALL DVVX0(' ',N2,SIGMA,SCA)
          ELSE
            CALL DVVX0(TIN,N2,SIGMA,SCA)
          END IF
        END IF
        CALL DVVX(N,HAX,VAX,HEL,VEL,ARG,XYZ)
        IF(SIGMA.EQ.0.) THEN
          IF(TIN.EQ.'RO') THEN
            X2= SCA(2,1)*XYZ(1)+SCA(1,1)*XYZ(2)
            Y2=-SCA(1,1)*XYZ(1)+SCA(2,1)*XYZ(2)
            H = SCA(2,2)*X2    +SCA(1,2)*XYZ(3)
            Z3=-SCA(1,2)*X2    +SCA(2,2)*XYZ(3)
            V = SCA(2,3)*Y2    +SCA(1,3)*Z3
            CALL DQPD(H,V)
          ELSE IF(TIN.EQ.'FT') THEN
            RO=DVCORD(XYZ,IVRODV)
            IF(RO.LT.ROPHI) GO TO 1
            TE=DATN2D(RO,XYZ(3)-VRDZDV)
            IF(TE.LE.90.) THEN
              DH=QTETDV*TE
            ELSE
              DH=QTETDV*(180.-TE)
            END IF
            FI=DVCORD(XYZ,IVFIDV)
            IF(LAYVD.GT.2) THEN
              DPU=PU*DVCORD(XYZ,IVRBDV)
            ELSE
              DPU=PU*(RO-DRO)/SIND(TE)
            END IF
            CALL DQPD(-TE+DH-DPU,FI)
            CALL DQPD(-TE+DH+DPU,FI)
            IF(IZOMDO.EQ.0.AND.FI.LE.FOVER) THEN
              CALL DQPD(-TE+DH-DPU,FI+360.)
              CALL DQPD(-TE+DH+DPU,FI+360.)
            END IF
          ELSE IF(TIN.EQ.'FZ') THEN
            RO=DVCORD(XYZ,IVRODV)
            IF(RO.GT.ROPHI) THEN
              FI=DVCORD(XYZ,IVFIDV)
              CALL DQPD(XYZ(3),FI)
              IF(IZOMDO.EQ.0.AND.FI.LE.FOVER) CALL DQPD(XYZ(3),FI+360.)
            END IF
          ELSE IF(TIN.EQ.'FR') THEN
C           CALL DVVX(N,HAX,VAX,HEL,VEL,ARG,XYZ)
            RO=DVCORD(XYZ,IVRODV)
            IF(RO.GE.ROFR) THEN
              FI=DVCORD(XYZ,IVFIDV)
              CALL DQPD(RO,FI)
              IF(IZOMDO.EQ.0.AND.FI.LE.FOVER) CALL DQPD(RO,FI+360.)
            END IF
          ELSE IF(TIN.EQ.'RZ') THEN
            RO=DVCORD(XYZ,IVRODV)
            FI=DVCORD(XYZ,IVFIDV)
            FI=DFINXT(FIMID,FI)
            IF(FI.LT.FMIN.OR.FI.GT.FMAX) RO=-RO
            CALL DQPD(XYZ(3),RO)
          ELSE IF(TIN.EQ.'YZ') THEN
            V=-SCA(1,1)*XYZ(1)+SCA(2,1)*XYZ(2)
            CALL DQPD(XYZ(3),V)
          ELSE IF(TIN.EQ.'YX') THEN
            CALL DQPD(XYZ(1),XYZ(2))
          END IF
        ELSE
          FPOS=999.
          IF(TIN.EQ.'FT') THEN
            FPOS=DVCORD(XYZ,IVFIDV)
            IF(LAYVD.GT.2) THEN
              DPU=PU*DVCORD(XYZ,IVRBDV)
            ELSE
              RO=DVCORD(XYZ,IVRODV)
              IF(RO.LT.ROPHI) GO TO 1
              TE=DATN2D(RO,XYZ(3)-VRDZDV)
              DPU=PU*(RO-DRO)/SIND(TE)
            END IF
            DO L=1,61
              HEL(L)=-HEL(L)+DH+DPU
            END DO
            IF(DPU.NE.0.) THEN
              CALL DAPVEL(HEL,VEL,FPOS)
              DPU=2.*DPU
              DO L=1,61
                HEL(L)=HEL(L)-DPU
              END DO
            END IF
          ELSE IF(TIN.EQ.'FZ') THEN
            RO=DVCORD(XYZ,IVRODV)
            IF(RO.LT.ROPHI) GO TO 1
            FPOS=DVCORD(XYZ,IVFIDV)
          ELSE IF(TIN.EQ.'FR') THEN
            RO=DVCORD(XYZ,IVRODV)
            IF(RO.LT.ROFR) GO TO 1
            FPOS=DVCORD(XYZ,IVFIDV)
          ELSE IF(TIN.EQ.'RZ') THEN
            RO=DVCORD(XYZ,IVRODV)
            FI=DVCORD(XYZ,IVFIDV)
            FI=DFINXT(FIMID,FI)
            IF(FI.LT.FMIN.OR.FI.GT.FMAX) THEN
              DO L=1,61
                VEL(L)=-VEL(L)
              END DO
            END IF
          END IF
          CALL DAPVEL(HEL,VEL,FPOS)
        END IF
    1 CONTINUE
      END
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DAPTN
CH
      SUBROUTINE DAPTN(TPR)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      CHARACTER *(*) TPR
      DIMENSION H(2),V(2)
      DIMENSION IP(2,2)
      DATA IP/8,4 , 4,4/
      IF(FPIKDP) RETURN

      CALL DPARGI(87,'SDA',NDASH)
      NDASH=2*NDASH

      CALL DVXTN
      IF(NTRKDN.LE.0) RETURN
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TSUBDJ='DAPTN'
      TPARDA=
     &  'J_PFY,J_PFI,J_PTE,J_RAL'
      CALL DPARAM(10
     &  ,J_PFY,J_PFI,J_PTE,J_RAL)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      IF(TPR.EQ.'YZ') THEN
        SF=SIND(PARADA(2,J_PFY))
        CF=COSD(PARADA(2,J_PFY))
      ELSE IF(TPR.EQ.'RO') THEN
        SF=SIND(    PARADA(2,J_PFI))
        CF=COSD(    PARADA(2,J_PFI))
        ST=SIND(90.-PARADA(2,J_PTE))
        CT=COSD(90.-PARADA(2,J_PTE))
        SG=SIND(    PARADA(2,J_RAL))
        CG=COSD(    PARADA(2,J_RAL))
      END IF
      DO K=1,NTRKDN
        IF(ICOLDN(K).GE.0) THEN
          CALL DGDASH(NDASH,IP(1,IDSHDN(K)))
          IF(ICOLDN(K).EQ.0) THEN
            CALL DGLEVL(8)
          ELSE
            CALL DGLEVL(ICOLDN(K))
          END IF
          DO I=1,2
            IF(TPR.EQ.'YX') THEN
              H(I)=XYZTDN(1,I,K)
              V(I)=XYZTDN(2,I,K)
            ELSE IF(TPR.EQ.'YZ') THEN
              H(I)=XYZTDN(3,I,K)
              V(I)=-SF*XYZTDN(1,I,K)+CF*XYZTDN(2,I,K)
            ELSE IF(TPR.EQ.'RO') THEN
              X1=XYZTDN(1,I,K)
              Y1=XYZTDN(2,I,K)
              Z1=XYZTDN(3,I,K)
              X2  = CF*X1+SF*Y1
              Y2  =-SF*X1+CF*Y1
              H(I)= CT*X2+ST*Z1
              Z3  =-ST*X2+CT*Z1
              V(I)= CG*Y2+SG*Z3
            END IF
          END DO
          CALL DQLIE(H,V)
        END IF
      END DO
      CALL DGDASH(0,0)
      END
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DAPTN
CH
      SUBROUTINE DAP_V0_TR(TPR)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      CHARACTER *(*) TPR
      DIMENSION XYZ(3,2),PXYZ(3),XYZ0(3)   
C     ...................... XYZ0 = vertex position, XYZ(*,1) = V0 position
C     ......................  XYZ(*,2) nearest point to vertex
      DIMENSION H(2),V(2)
      DIMENSION IP(2)
      DATA IP/8,6/
      CALL DPARGI(20,'HV0',IHV0)
      IF(IHV0.EQ.0) RETURN
      IF(FPIKDP) RETURN
      CALL DVKN_V0_TR_0(NUM)
      IF(NUM.LE.0) RETURN
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TSUBDJ='DAPTN'
      TPARDA=
     &  'J_PFY,J_PFI,J_PTE,J_RAL'
      CALL DPARAM(10
     &  ,J_PFY,J_PFI,J_PTE,J_RAL)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::

      CALL DPARGI(87,'SDA',NDASH)
      NDASH=2*NDASH

      IF(TPR.EQ.'YZ') THEN
        SF=SIND(PARADA(2,J_PFY))
        CF=COSD(PARADA(2,J_PFY))
      ELSE IF(TPR.EQ.'RO') THEN
        SF=SIND(    PARADA(2,J_PFI))
        CF=COSD(    PARADA(2,J_PFI))
        ST=SIND(90.-PARADA(2,J_PTE))
        CT=COSD(90.-PARADA(2,J_PTE))
        SG=SIND(    PARADA(2,J_RAL))
        CG=COSD(    PARADA(2,J_RAL))
      END IF
      CALL DGDASH(NDASH,IP)
      CALL DPAR_SET_CO(58,'CV0')
      IF(ICOLDP.GE.0) THEN
        IF(IHTRDO(3).EQ.1) THEN
          CALL VZERO(XYZ0,3)
        ELSE
          CALL DVX_PR_VERTEX(XYZ0)
        END IF
        DO K=1,NUM
C         ............ TRACK IS POINTING TO XYZ WITHH MOMENTUM PXYZ
          CALL DVKN_V0_TR(K,XYZ,PXYZ)
          SS=0
          S2=0
          DO J=1,3
            SS=SS+PXYZ(J)*(XYZ0(J)-XYZ(J,1))
            S2=S2+PXYZ(J)*PXYZ(J)
          END DO
          IF(S2.GT.0.) THEN
            U=SS/S2
            DO J=1,3
              XYZ(J,2)=XYZ(J,1)+PXYZ(J)*U
            END DO
            DO I=1,2
              IF(TPR.EQ.'YX') THEN
                H(I)=XYZ(1,I)
                V(I)=XYZ(2,I)
              ELSE IF(TPR.EQ.'YZ') THEN
                H(I)=XYZ(3,I)
                V(I)=-SF*XYZ(1,I)+CF*XYZ(2,I)
              ELSE IF(TPR.EQ.'RO') THEN
                X1=XYZ(1,I)
                Y1=XYZ(2,I)
                Z1=XYZ(3,I)
                X2  = CF*X1+SF*Y1
                Y2  =-SF*X1+CF*Y1
                H(I)= CT*X2+ST*Z1
                Z3  =-ST*X2+CT*Z1
                V(I)= CG*Y2+SG*Z3
              END IF
            END DO
            CALL DQLIE(H,V)
          END IF
        END DO
      END IF
      CALL DGDASH(0,0)
      END
*DK DAPVEL
CH..............***
CH
CH
CH
CH
CH
CH
CH ********************************************************************  DAPVEL
CH
      SUBROUTINE DAPVEL(HEL,VEL,FI)
CH
CH ********************************************************************
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C!:
C    Inputs    :
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
      INCLUDE 'DALI_CF.INC'
      DIMENSION HEL(61),VEL(61)
      DATA FOVER/40./
      DO L=1,60
        CALL DQLIE(HEL(L),VEL(L))
      END DO
      IF(IZOMDO.EQ.0.AND.FI.LE.FOVER) THEN
        DO L=1,61
          VEL(L)=VEL(L)+360.
        END DO
        DO L=1,60
          CALL DQLIE(HEL(L),VEL(L))
        END DO
      END IF
      END
*DK DPERS0
CH..............***
CH
CH
CH
CH
CH
CH
CH ********************************************************************  DPERS0
CH
      SUBROUTINE DRPRS0(FIM)
CH
CH ********************************************************************
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C!:
C    Inputs    :
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
      INCLUDE 'DALI_CF.INC'
      DATA DR/0./,IDEB/0/
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TSUBDJ='DRPRS0'
      TPARDA=
     &  'J_PTO,J_PDS'
      CALL DPARAM(11
     &  ,J_PTO,J_PDS)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      IF(IDEB.EQ.0.AND.
     &  PARADA(4,J_PDS).NE.1..OR.PARADA(2,J_PDS).LE.0.) THEN
        FRPRDP=.FALSE.

        FRPRDP=.TRUE.
        FIMID=FIM
        R2 = PARADA(2,J_PTO)
        R1 = PARADA(2,J_PDS)
        Q=R2/(1.-R1/R2)
      END IF
      RETURN
CH..............---
CH
CH
CH
CH
CH
CH
CH --------------------------------------------------------------------  DPERS
CH
      ENTRY DRPR(XX,YY,RO,FI)
CH
CH --------------------------------------------------------------------
CH
      X=XX-VRTXDV
      Y=YY-VRTYDV
      FI=DFINXT(FIMID,DATN2D(Y,X))
      RO=SQRT(X*X+Y*Y)
      RO=Q*(1.-R1/(RO+DR))
      END
*DK DADVD
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DADVD
CH
      SUBROUTINE DADVD(LAYER)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C               FACEDV(SIDE,X or Y,PHI,LAYER)
C     DRAW VERTEX-DETECTOR IN FZ
      INCLUDE 'DALI_CF.INC'
      CHARACTER *4 TSTYL(0:3),TST
      DATA  TSTYL /'LINB','LINC','AR+L','AREA' /
      DATA DHL/1./,D1/-2./,D3/3./,D5/5./,D8/8./
      DIMENSION FACE(2,2,15,2)
      EQUIVALENCE (FACE,CRILDV)
      DIMENSION H(5),V(5)
      DATA N1/-1/,N2/3/
      CHARACTER *1 TZ(6)
      DATA TZ/'1','2','3','4','5','6'/
      CHARACTER *2 TNUM
      LOGICAL FNPM,FNZM
      IF(FPIKDP.OR.(.NOT.FEVDDV)) RETURN
      NC1 = PDCODD(2,ICVDDD)
      NC2 = PDCODD(2,KCVDDD)
      TST = TSTYL(IFIX(PDCODD(2,ISTYDD)))
      DLINDD=PDCODD(2,LIDTDD)
      CALL DOFISH('VD','FZ')
      IF(TST.EQ.'LINB') THEN
        CALL DQPO0( TST,0,NC2,'NSKP')
      ELSE IF(TST.EQ.'LINC') THEN
        CALL DQPO0( TST,0,NC1,'NSKP')
      ELSE
        CALL DQPO0(TST,NC1,NC2,'NSKP')
      END IF
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TSUBDJ='DADVD'
      TPARDA=
     &  'J_PFI,J_FFA,J_FWA'
      CALL DPARAM(10
     &  ,J_PFI,J_FFA,J_FWA)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      IF(PARADA(4,J_FWA).GT.0.) THEN
        NF1=PARADA(2,J_FFA)
        NF2=NF1
        NWFR1=PARADA(2,J_FWA)
        IF(     NWFR1.EQ.7) THEN
          NWFR1=1
          NWFR2=NWAFDV/2
        ELSE IF(NWFR1.EQ.8) THEN
          NWFR1=NWAFDV/2+1
          NWFR2=NWAFDV
        ELSE
          NWFR2=NWFR1
        END IF
      ELSE
        NF1=N1
        NF2=NTOTDV(LAYER)+N2
        NWFR1=1
        NWFR2=NWAFDV
      END IF
      DO NF=NF1,NF2
        KF=1+MOD(NF+NTOTDV(LAYER)-1,NTOTDV(LAYER))
        DF=DLFIDV(NF,LAYER)*FISCDV
        IF(IZOMDO.EQ.0) THEN
          FIM=FIMDDV(NF,LAYER)
        ELSE
          FIM=DFINXT(PARADA(2,J_PFI),FIMDDV(NF,LAYER))
        END IF
        V(1)=FIM+DF
        V(3)=FIM-DF
        V(2)=V(1)
        V(4)=V(3)
        V(5)=V(1)
        DO NZ=NWFR1,NWFR2
          H(1)=ZLFTDV(NZ,LAYER)
          H(3)=ZRGTDV(NZ,LAYER)
          H(2)=H(3)
          H(4)=H(1)
          H(5)=H(1)
          CALL DQPOL(5,H,V)
          IF(PARADA(4,J_FWA).LT.0.)
     &      CALL DQL2E(H(1)-DHL,V(1),H(2)+DHL,V(2))
        END DO
      END DO
      CALL DQLEVL(ICTXDD)
      NF1=N1
      NF2=NTOTDV(LAYER)+N2
      FNPM=.TRUE.
      DO NF=NF1,NF2
        KF=1+MOD(NF+NTOTDV(LAYER)-1,NTOTDV(LAYER))
        VT=BVSCDQ*FIMDDV(NF,LAYER)+CVSCDQ
        IF(VT.GT.VLOWDG(IAREDO).AND.VT+D8.LT.VHGHDG(IAREDO)) THEN
          WRITE(TNUM,1000) KF
 1000     FORMAT(I2)
          IF(KF.LE.9) THEN
            CALL DGTEXT(HMINDG(IAREDO)+D3,VT,TNUM(2:2),1)
          ELSE
            CALL DGTEXT(HMINDG(IAREDO)+D1,VT,TNUM,2)
          END IF
          FNPM=.FALSE.
        END IF
      END DO
      FNZM=.TRUE.
      DO NZ=NWFR1,NWFR2
        HT=AHSCDQ*ZOFWDV(NZ)+CHSCDQ
        IF(HT.GT.HLOWDG(IAREDO).AND.HT+D8.LT.HHGHDG(IAREDO)) THEN
          CALL DGTEXT(HT,VMINDG(IAREDO)+D5,TZ(NZ),1)
          FNZM=.FALSE.
        END IF
      END DO
      IF(FNZM.OR.FNPM) THEN
        HM=0.5*(HHGHDG(IAREDO)+HLOWDG(IAREDO))
        VM=0.5*(VHGHDG(IAREDO)+VLOWDG(IAREDO))
        CALL DQINV(IAREDO,HM,VM,HT,VT)
        IF(FNPM) THEN
          D=9999.
          DO K=NF1,NF2
            DD=ABS(FIMDDV(K,LAYER)-VT)
            IF(DD.LT.D) THEN
              NF=K
              D=DD
            END IF
          END DO
          KF=1+MOD(NF+NTOTDV(LAYER)-1,NTOTDV(LAYER))
        END IF
        IF(FNPM) THEN
          D=9999.
          DO K=NF1,NF2
            DD=ABS(FIMDDV(K,LAYER)-VT)
            IF(DD.LT.D) THEN
              NF=K
              D=DD
            END IF
          END DO
          KF=1+MOD(NF+NTOTDV(LAYER)-1,NTOTDV(LAYER))
        END IF
        WRITE(TNUM,1000) KF
        IF(KF.LE.9) THEN
          CALL DGTEXT(HMINDG(IAREDO)+D3,VM,TNUM(2:2),1)
        ELSE
          CALL DGTEXT(HMINDG(IAREDO)+D1,VM,TNUM,2)
        END IF
        IF(FNZM) THEN
          D=9999.
          DO K=NWFR1,NWFR2
            DD=ABS(ZOFWDV(K)-HT)
            IF(DD.LT.D) THEN
              NZ=K
              D=DD
            END IF
          END DO
          CALL DGTEXT(HM,VMINDG(IAREDO)+D5,TZ(NZ),1)
        END IF
      END IF
      DLINDD=PDCODD(2,LITRDD)
      END
*DK DOVDLF
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DOVDLF
CH
      SUBROUTINE DGVDLF
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C     CALCULATE LINEAR SCALE OF LOCAL VD COORDINATES TO PHI
      INCLUDE 'DALI_CF.INC'
C      PARAMETER (NWAF=4, NMOD=15,  NVIEW=2,  NLAYER=2)
C      REAL PHIPOS(NMOD,NLAYER)
C      REAL ZPOS  (NWAF,NMOD,NLAYER)
C      INTEGER NPhi_Strips(NMOD,NLAYER)
C      INTEGER NZ_Strips  (NWAF,NMOD,NLAYER)
C      COMMON/MVDGEOM/PHIPOS,ZPOS,NPhi_Strips,NZ_Strips
      DIMENSION FACE(2,2,15,2),RL(2),DF(2)
      EQUIVALENCE (FACE,CRILDV)
      DATA NTOTDV/9,15/
      DATA QDF/2.1/
      DIMENSION ISNV(8)
      DATA ISNV/-1,-1,-1, 1, 1, 1,-1, 1/  ! New VDET
C               -1,-1, 1, 1,      -1, 1     Old VDET only NSNV(3) is different
C     .......................... OLD VDET CODE
      DATA DLSTDV/0.01/
      DQ=0.5*DLSTDV
C     ..........................
      DO L=1,2
        DQF=0.5*PFRSDV(L)
        DQZ=0.5*PZRSDV(L)
C       .......................... OLD VDET CODE
        IF(DQF.EQ.0.) QF=DQ
        IF(DQZ.EQ.0.) DQZ=DQ
C       ..........................
        DO NF=NTOTDV(L),1,-1
C         ................................................... PHI
          X1=FACE(1,1,NF,L)
          X2=FACE(1,2,NF,L)
          Y1=FACE(2,1,NF,L)
          Y2=FACE(2,2,NF,L)
          XM=0.5*(X2+X1)
          YM=0.5*(Y2+Y1)
          FIMDDV(NF,L)=DATN2D(YM,XM)
          DLFIDV(NF,L)=DQF*NFRSDV(L)
        END DO
        FIMDDV(1,2)=FIMDDV(1,2)-360.
        DO NF=-2,0
          FIMDDV(NF,L)=FIMDDV(NF+NTOTDV(L),L)-360.
          DLFIDV(NF,L)=DLFIDV(NF+NTOTDV(L),L)
        END DO
        DO NF=NTOTDV(L)+1,NTOTDV(L)+3
          FIMDDV(NF,L)=FIMDDV(NF-NTOTDV(L),L)+360.
          DLFIDV(NF,L)=DLFIDV(NF-NTOTDV(L),L)
        END DO
        F2=DATN2D(Y2,X2)
        F2=DFINXT(FIMDDV(1,L),F2)
        DF(L)=ABS(F2-FIMDDV(1,L))
        RL(L)=SQRT((X2-XM)**2+(Y2-YM)**2)
C       ................................................... Z
        DO NZ=1,NWAFDV
          DZ=DQZ*NZRSDV(L)
          ZLFTDV(NZ,L)=ZOFWDV(NZ)-DZ
          ZRGTDV(NZ,L)=ZOFWDV(NZ)+DZ
        END DO
      END DO
      RETURN
CH..............---
CH
CH
CH
CH
CH
CH
CH --------------------------------------------------------------------  DOVDSC
CH
      ENTRY DGVDSC(LAYER)
CH
CH --------------------------------------------------------------------
CH
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TSUBDJ='DGVDSC'
      TPARDA=
     &  'J_FWA,J_FDL'
      CALL DPARAM(16
     &  ,J_FWA,J_FDL)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      IF(PARADA(4,J_FWA).LT.0..AND.
     &  PARADA(4,J_FDL).GT.0.) THEN
        R=RL(LAYER)+PARADA(2,J_FDL)
      ELSE
        R=RL(LAYER)
      END IF
      FISCDV=DF(LAYER)/R
      RETURN
CH.............---
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DADVDM
CH
      ENTRY DADVDM
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C     CHANGE CURRENT PARAMETERS TO JUST DISPLAY SELECTED WAFER
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TSUBDJ='DADVDM'
      TPARDA=
     &  'J_PFI,J_PDF,J_PTE,J_PFR,J_PTO,J_FLA,J_FFA,J_FWA,J_FTO,J_FTN'
      CALL DPARAM(10
     &  ,J_PFI,J_PDF,J_PTE,J_PFR,J_PTO,J_FLA,J_FFA,J_FWA,J_FTO,J_FTN)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      CALL DPARGV(97,'DFZ',2,DFZ)
      L=PARADA(2,J_FLA)
      NFACE=PARADA(2,J_FFA)
      NWAFR=PARADA(2,J_FWA)
      IF(PARADA(2,J_PTE).EQ.90.) PARADA(2,J_PTE)=89.
      IF(PARADA(2,J_PTE).GT.90.)
     &   PARADA(2,J_PTE)=180.-PARADA(2,J_PTE)
      IF(NWAFR.GT.6) THEN
        IF(NWAFDV.EQ.4) THEN
          CALL DPARGV(82,'TVO',2,PTO)
        ELSE
          CALL DPARGV(82,'TVN',2,PTO)
        END IF
        IF(NWAFR.EQ.7) THEN
          PARADA(2,J_PTO)=DFZ*0.5
          PARADA(2,J_PFR)=-PTO
        ELSE
          PARADA(2,J_PFR)=-DFZ*0.5
          PARADA(2,J_PTO)=PTO
        END IF
      ELSE
        PARADA(2,J_PFR)=ZLFTDV(NWAFR,L)-DFZ
        PARADA(2,J_PTO)=ZRGTDV(NWAFR,L)+DFZ
      END IF
      FISC=DF(L)/RL(L)
      PARADA(2,J_PFI)=FIMDDV(NFACE,L)
      PARADA(2,J_PDF)=FISC*QDF*DLFIDV(NFACE,L)
C     Theta defines left or right
C      IF(NWAFDV.EQ.4.AND.NWAFR.EQ.3) THEN
C        IS=1
C      ELSE
C        IS=ISNV(NWAFR)
C      END IF
C      IF(IS.LT.0.) THEN
C        IF(PARADA(2,J_PTE).LT.90.)
C     &    PARADA(2,J_PTE)=180.-PARADA(2,J_PTE)
C      ELSE
C        IF(PARADA(2,J_PTE).GT.90.)
C     &    PARADA(2,J_PTE)=180.-PARADA(2,J_PTE)
C      END IF
      PARADA(4,J_FWA)=1.
      END
*DK DAP_KALMAN_CH
CH..............+++
CH
CH
CH
CH
CH
CH
CH +++++++++++++++++++++++++++++++++++++++++++++++++++++++ DAP_KALMANN_CH
CH
      SUBROUTINE DAP_KALMAN_CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C!:Draw points of fitted coordinates in All Projections
C      The points result from the Fit of one track from the Lohse routines.
C    Inputs    :
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
C
      COMMON / INFDAL / NLOW, NHIGH, XSTS, XME, RF, IUSED, VMEAS
C
      PARAMETER (MPT=40)
      INTEGER IUSED(MPT)
      DOUBLE PRECISION XSTS(5,MPT),XME(2,MPT),RF(MPT),VMEAS(2,2,MPT)
      DATA PIDEG/57.29577951/
      DATA ZMAX/217./,RMAX/170.622/
      DATA QCP/-0.012883/,FOVER/40./
      PARAMETER (MPTOT=999)
      DIMENSION FI(MPTOT),RO(MPTOT),ZZ(MPTOT),NPOS(99)
      LOGICAL FOUT,FP2
      IF(IHTRDO(2).LT.4) RETURN
      CALL DSCTR
      CALL DV0(FRFTDB,NUM1,NTR,FOUT)
      NTR=MIN(NTR,99)
      IF(FOUT) RETURN
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TSUBDJ='D_AP_KALM'
      TPARDA=
     &  'J_PFY,J_PFI,J_PTE,J_PPU,J_RAL'
      CALL DPARAM(10
     &  ,J_PFY,J_PFI,J_PTE,J_PPU,J_RAL)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      IF(IHTRDO(2).NE.IHOLD) THEN
        CALL DWRT('Kalman filter recalculated. Wait')
        IHOLD=IHTRDO(2)
        KPNT=0
        DO N=1,NTR
          CALL DVFTR(N,NPNT)
          NPOS(N)=KPNT+1
          IF(NPNT.GT.0) THEN
            IF(KPNT.GE.MPTOT) GO TO 1
            DO K=1,NPNT
              IF(IHTRDO(2).EQ.4) THEN
                KPNT=KPNT+1
                FI(KPNT)=PIDEG*XME(1,K)/RF(K)
                ZZ(KPNT)=XME(2,K)
                RO(KPNT)=RF(K)
              ELSE IF(IUSED(K).EQ.1) THEN
                KPNT=KPNT+1
                FI(KPNT)=PIDEG*XSTS(1,K)/RF(K)
                ZZ(KPNT)=XSTS(2,K)
                RO(KPNT)=RF(K)
              END IF
            END DO
          END IF
        END DO
    1   NPOS(NTR+1)=KPNT+1
        CALL DWRT('Calculation finished.')
      END IF
      FIMID=PARADA(2,J_PFI)
      TEMID=PARADA(2,J_PTE)
C     ................................................... SET UP PROJECTIONS
      IF     (TPICDO.EQ.'YX') THEN
        NPR=1
      ELSE IF(TPICDO.EQ.'RZ') THEN
        IF(PARADA(4,J_PTE).NE.0.) THEN
          FMIN=FIMID-90.
          FMAX=FIMID+90.
          NPR=2
        ELSE
          NPR=3
        END IF
      ELSE IF(TPICDO.EQ.'FT') THEN
        IF(PARADA(4,J_PPU).EQ.1.) THEN
          PU=QCP*PARADA(2,J_PPU)
          NPR=4
        ELSE
          PU=0.
          NPR=6
        END IF
        IF(IZOMDO.EQ.0) FIMID=180.
      ELSE IF(TPICDO.EQ.'FR') THEN
        IF(IZOMDO.EQ.0) FIMID=180.
        NPR=7
      ELSE IF(TPICDO.EQ.'FZ') THEN
        IF(IZOMDO.EQ.0) FIMID=180.
        NPR=8
      ELSE IF(TPICDO.EQ.'YZ') THEN
        SF=SIND(PARADA(2,J_PFY))
        CF=COSD(PARADA(2,J_PFY))
        NPR=9
      ELSE IF(TPICDO.EQ.'RO') THEN
        SF=SIND(FIMID)
        CF=COSD(FIMID)
        ST=SIND(90.-PARADA(2,J_PTE))
        CT=COSD(90.-PARADA(2,J_PTE))
        SG=SIND(PARADA(2,J_RAL))
        CG=COSD(PARADA(2,J_RAL))
        NPR=11
      ELSE
        CALL DWRT('wrong projection#')
        RETURN
      END IF
      DO 600 N=1,NTR
        IF(FNOTDT(N)) GO TO 600
        IF(FVTRDC) CALL DGLEVL(NCTRDC(N))
        FP2=.FALSE.
        NUM1=NPOS(N)
        NUM2=NPOS(N+1)-1
        DO 200 K=NUM1,NUM2
C
C         .................................................... XME(1)=rho*phi
C         .................................................... XME(2)=Z
C         ....................................................    RF = rho
C
          F2=DFINXT(FIMID,FI(K))
          GO TO (201,202,203,204,204,206,207,208,209,209,211) NPR
C         ............................................................... YX
  201     H2=RO(K)*COSD(F2)
          V2=RO(K)*SIND(F2)
          IF(FP2) GO TO 280
          H1=H2
          V1=V2
          GO TO 200
C         ..................................................... RZ(SIGNED RHO)
  202     H2=ZZ(K)
          IF(F2.GE.FMIN.AND.F2.LE.FMAX) THEN
            V2= RO(K)
            IS2=1
          ELSE
            V2=-RO(K)
            IS2=-1
          END IF
          IF(FP2.AND.IS1.EQ.IS2) CALL DQL2E(H1,V1,H2,V2)
          H1=H2
          V1=V2
          IS1=IS2
          GO TO 200
C         .................................................... RZ(POSITIVE RHO)
  203     H2=ZZ(K)
          V2=RO(K)
          IF(FP2) GO TO 280
          H1=H2
          V1=V2
          GO TO 200
C         .......................................................... FT(PU#0)
C 204     IF(NDEV.NE.3) GO TO 300
  204     R=RO(K)
          Z=ZZ(K)
          ZA=ABS(Z)
          D0=SQRT(Z**2+R**2)
          IF(R*ZMAX.GT.ZA*RMAX) THEN
            B=D0*(RMAX/R-1.)
          ELSE
            B=D0*(ZMAX/ZA-1.)
          END IF
          DPU=PU*B
          TEDZ=DATN2D(R,Z-VRDZDV)
          IF(TEDZ.LE.90.) THEN
            TE=TEDZ-QTETDV*TEDZ
          ELSE
            TE=TEDZ-QTETDV*(180.-TEDZ)
          END IF
          H2L=-TE-DPU
          H2R=-TE+DPU
          IF(FP2) THEN
            CALL DQL2E(H1L,F1,H2L,F2)
            CALL DQL2E(H1R,F1,H2R,F2)
            IF(IZOMDO.EQ.0.AND.F2.LE.FOVER) THEN
              CALL DQL2E(H1L,F1+360.,H2L,F2+360.)
              CALL DQL2E(H1R,F1+360.,H2R,F2+360.)
            END IF
          END IF
          H1L=H2L
          H1R=H2R
          F1=F2
          GO TO 200
C         .......................................................... FT(PU=0)
C 206     IF(NDEV.NE.3) GO TO 300
  206     H2=-DATN2D(RO(K),ZZ(K))
          IF(FP2) GO TO 290
          H1=H2
          F1=F2
          GO TO 200
C         ............................................................... FR
  207     H2=RO(K)
          IF(FP2) GO TO 290
          H1=H2
          F1=F2
          GO TO 200
C         ............................................................... FZ
  208     H2=ZZ(K)
          IF(FP2) GO TO 290
          H1=H2
          F1=F2
          GO TO 200
C         ............................................................... YZ
  209     H2=ZZ(K)
          R=RO(K)
          X=R*COSD(F2)
          Y=R*SIND(F2)
          V2=-SF*X+CF*Y
          IF(FP2) GO TO 280
          H1=H2
          V1=V2
          GO TO 200
C         ............................................................... RO
  211     Z1=ZZ(K)
          R=RO(K)
          X1=R*COSD(F2)
          Y1=R*SIND(F2)
C         .................................................... X2= CF*X1+SF*Y1
C         .................................................... Y2=-X1*SF+CF*Y1
C         .................................................... Z2= Z1
C         .................................................... X3= CT*X2+ST*Z2
C         .................................................... Y3= Y2
C         .................................................... Z3=-ST*X2+CT*Z2
C         ...................................................H=X4= X3
C         .................................................. V=Y4= CG*Y3+SG*Z3
C         .................................................... Z4=-SG*Y3+CG*Z3
          X2= CF*X1+SF*Y1
          Y2=-SF*X1+CF*Y1
          H2= CT*X2+ST*Z1
          Z3=-ST*X2+CT*Z1
          V2= CG*Y2+SG*Z3
          IF(FP2) GO TO 280
          H1=H2
          V1=V2
          GO TO 200
  280     CALL DQL2E(H1,V1,H2,V2)
          H1=H2
          V1=V2
          GO TO 200
  290     CALL DQL2E(H1,F1,H2,F2)
          IF(IZOMDO.EQ.0.AND.F2.LE.FOVER)
     &      CALL DQL2E(H1,F1+360.,H2,F2+360.)
          H1=H2
          F1=F2
          GO TO 200
  200     FP2=.TRUE.
        CONTINUE
  600 CONTINUE
      CALL DQCHKX
      RETURN
      ENTRY DAP_KALMANN_TRACKS_IN
      IHOLD=-99
      END
*DK DAP_KALMANN_HE
CH..............+++
CH
CH
CH
CH
CH
CH
CH +++++++++++++++++++++++++++++++++++++++++++++++++++++++ DAP_KALMAN_HE
CH
      SUBROUTINE DAP_KALMAN_HE
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C!:Draw points of fitted coordinates in All Projections
C      The points result from the Fit of one track from the Lohse routines.
C    Inputs    :
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
C
      DATA ZMAX/217./,RMAX/170.622/
      DATA QCP/-0.012883/,NPMAX/60/,FOVER/40./
      DIMENSION DLIN(2),ICOL(2)
      LOGICAL FOUT,FUSFI,FUSTE,FPO(2)
      CALL DSCTR
      CALL DV0(FRFTDB,NUM1,NUM2,FOUT)
      IF(FOUT) RETURN
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_PFY,J_PFI,J_PTE,J_PPU,J_RAL'
      CALL DPARAM(10
     &  ,J_PFY,J_PFI,J_PTE,J_PPU,J_RAL)
      TPARDA=
     &  'J_SSY,J_SSZ'
      CALL DPARAM(87
     &  ,J_SSY,J_SSZ)
      TPARDA=
     &  'J_CKA,J_CKP,J_CKF'
      CALL DPARAM(58
     &  ,J_CKA,J_CKP,J_CKF)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      CALL DCUTTF(FUSFI,FC1,FC2,FUSTE,TC1,TC2)
      FIMID=PARADA(2,J_PFI)
      TEMID=PARADA(2,J_PTE)
C     ................................................... SET UP PROJECTIONS
      IF     (TPICDO.EQ.'YX') THEN
        NPR=1
      ELSE IF(TPICDO.EQ.'RZ') THEN
        IF(PARADA(4,J_PTE).NE.0.) THEN
          FMIN=FIMID-90.
          FMAX=FIMID+90.
        ELSE
          FMIN=-9999.
          FMAX=9999.
        END IF
        NPR=2
      ELSE IF(TPICDO.EQ.'FT') THEN
        IF(PARADA(4,J_PPU).EQ.1.) THEN
          PU=QCP*PARADA(2,J_PPU)
        ELSE
          PU=0.
        END IF
        IF(IZOMDO.EQ.0) FIMID=180.
        NPR=3
      ELSE IF(TPICDO.EQ.'FR') THEN
        IF(IZOMDO.EQ.0) FIMID=180.
        NPR=4
      ELSE IF(TPICDO.EQ.'FZ') THEN
        IF(IZOMDO.EQ.0) FIMID=180.
        NPR=5
      ELSE IF(TPICDO.EQ.'YZ') THEN
        SF=SIND(PARADA(2,J_PFY))
        CF=COSD(PARADA(2,J_PFY))
        NPR=6
      ELSE IF(TPICDO.EQ.'RO') THEN
        SF=SIND(FIMID)
        CF=COSD(FIMID)
        ST=SIND(90.-PARADA(2,J_PTE))
        CT=COSD(90.-PARADA(2,J_PTE))
        SG=SIND(PARADA(2,J_RAL))
        CG=COSD(PARADA(2,J_RAL))
        NPR=7
      ELSE
        CALL DWRT('wrong projection#')
        RETURN
      END IF
      CALL DAP_SET_TR(J_CKF,J_CKA,DLIN,ICOL,M2)
      IF(PARADA(4,J_SSY).GE.0.) THEN
        NSYMB=PARADA(2,J_SSY)
        SYSIZ=PARADA(2,J_SSZ)
        CALL DQPD0(NSYMB,SYSIZ,0.)
        IF(PARADA(4,J_CKP).GT.0.) THEN
          ICOKP=PARADA(2,J_CKP)
          IF(ICOL(M2).EQ.ICOPK) ICOPK=-1
        ELSE
          ICOKP=-1
        END IF
        FPO(1)=.FALSE.
        FPO(M2)=.TRUE.
      ELSE
        FPO(1)=.FALSE.
        FPO(2)=.FALSE.
      END IF
      CALL DPARGV(83,'ONK',2,PNU)
      NUP=PNU
      DO M=1,M2
        DLINDD=DLIN(M)
        IF(ICOL(M).GE.0) CALL DGLEVL(ICOL(M))
        DO 10 NT=NUM1,NUM2
          IF(FNOTDT(NT)) GO TO 10
          IF(ICOL(M).LT.0) CALL DGLEVL(NCTRDC(NT))
          CALL DVFTR(NT,NPNT)
          I=1
          DO 200 NP=1,NPMAX
            P2=GET_KALMAN_T(I)
            IF(I.EQ.0) GO TO 10
            DP=P2/PNU
            X1=GET_KALMAN_X(0.)
            Y1=GET_KALMAN_Y(0.)
            Z1=GET_KALMAN_Z(0.)
            CALL DPOLCO(X1,Y1,Z1,R1,T1,F1)
            IF(T1.LT.TC1.OR.T1.GT.TC2) GO TO 200
            F1=DFINXT(FIMID,F1)
            IF(F1.LT.FC1.OR.F1.GT.FC2) GO TO 200
            IF(FPO(M)) THEN
              XP=X1
              YP=Y1
              ZP=Z1
              RP=R1
              FP=F1
            END IF
            P=0.
            IF(ICOL(M).LT.0.AND.ICOKP.GT.0) CALL DGLEVL(NCTRDC(NT))
            GO TO (201,202,203,204,205,206,207) NPR
C            ............................................................... YX
  201       DO J=1,NUP
              P=P+DP
              X2=GET_KALMAN_X(P)
              Y2=GET_KALMAN_Y(P)
              CALL DQL2E(X1,Y1,X2,Y2)
              X1=X2
              Y1=Y2
            END DO
            IF(FPO(M)) THEN
              IF(ICOKP.GE.0) CALL DGLEVL(ICOKP)
              CALL DQPD(XP,YP)
            END IF
            GO TO 200
C           ..................................................... RZ
  202       IF(F1.LT.FMIN.OR.F1.GT.FMAX) R1=-R1
            RP=R1
            DO J=1,NUP
              P=P+DP
              X2=GET_KALMAN_X(P)
              Y2=GET_KALMAN_Y(P)
              Z2=GET_KALMAN_Z(P)
              R2=SQRT(X2*X2+Y2*Y2)
              IF(R1.LT.0.) R2=-R2
              CALL DQL2E(Z1,R1,Z2,R2)
              Z1=Z2
              R1=R2
            END DO
            IF(FPO(M)) THEN
              IF(ICOKP.GE.0) CALL DGLEVL(ICOKP)
              CALL DQPD(ZP,RP)
            END IF
            GO TO 200
C           .......................................................... FT
  203       DO J=0,NUP
              X2=GET_KALMAN_X(P)
              Y2=GET_KALMAN_Y(P)
              Z2=GET_KALMAN_Z(P)
              CALL DPOLCO(X2,Y2,Z2,R2,T2,F2)
              F2=DFINXT(F1,F2)
              ZA=ABS(Z2)
              D0=SQRT(Z2*Z2+R2*R2)
              IF(R2*ZMAX.GT.ZA*RMAX) THEN
                B=D0*(RMAX/R2-1.)
              ELSE
                B=D0*(ZMAX/ZA-1.)
              END IF
              DPU=PU*B
              TEDZ=DATN2D(R2,Z2-VRDZDV)
              IF(TEDZ.LE.90.) THEN
                TE=TEDZ-QTETDV*TEDZ
              ELSE
                TE=TEDZ-QTETDV*(180.-TEDZ)
              END IF
              H2L=-TE-DPU
              H2R=-TE+DPU
              IF(J.NE.0) THEN
                CALL DQL2E(H1L,F1,H2L,F2)
                CALL DQL2E(H1R,F1,H2R,F2)
                IF(F1.EQ.FOVER) THEN
                  CALL DQL2E(H1L,F1+360.,H2L,F2+360.)
                  CALL DQL2E(H1R,F1+360.,H2R,F2+360.)
                END IF
              ELSE IF(FPO(M)) THEN
                HLP=H2L
                HRP=H2R
                F2P=F2
              END IF
              H1L=H2L
              H1R=H2R
              F1=F2
              P=P+DP
            END DO
            IF(FPO(M)) THEN
              IF(ICOKP.GE.0) CALL DGLEVL(ICOKP)
              CALL DQPD(HLP,F2P)
              CALL DQPD(HRP,F2P)
              IF(IZOMDO.EQ.0.AND.F2P.LT.FOVER) THEN
                F360=F2P+360.
                CALL DQPD(HLP,F360)
                CALL DQPD(HRP,F360)
              END IF
            END IF
            GO TO 200
C           ............................................................... FR
  204       DO J=1,NUP
              P=P+DP
              X2=GET_KALMAN_X(P)
              Y2=GET_KALMAN_Y(P)
              R2=SQRT(X2*X2+Y2*Y2)
              F2=DATN2D(Y2,X2)
              F2=DFINXT(F1,F2)
              CALL DQL2E(R1,F1,R2,F2)
              IF(IZOMDO.EQ.0.AND.F2.LE.FOVER)
     &          CALL DQL2E(R1,F1+360.,R2,F2+360.)
              R1=R2
              F1=F2
            END DO
            IF(FPO(M)) THEN
              IF(ICOKP.GE.0) CALL DGLEVL(ICOKP)
              CALL DQPD(RP,FP)
              IF(IZOMDO.EQ.0.AND.FP.LT.FOVER) CALL DQPD(RP,FP+360.)
            END IF
            GO TO 200
C           ............................................................... FZ
  205       DO J=1,NUP
              P=P+DP
              X2=GET_KALMAN_X(P)
              Y2=GET_KALMAN_Y(P)
              Z2=GET_KALMAN_Z(P)
              F2=DATN2D(Y2,X2)
              F2=DFINXT(F1,F2)
              CALL DQL2E(Z1,F1,Z2,F2)
              IF(IZOMDO.EQ.0.AND.F2.LE.FOVER)
     &          CALL DQL2E(Z1,F1+360.,Z2,F2+360.)
              Z1=Z2
              F1=F2
            END DO
            IF(FPO(M)) THEN
              IF(ICOKP.GE.0) CALL DGLEVL(ICOKP)
              CALL DQPD(ZP,FP)
              IF(IZOMDO.EQ.0.AND.FP.LT.FOVER) CALL DQPD(ZP,FP+360.)
            END IF
            GO TO 200
C           ............................................................... YZ
  206       V1=-SF*X1+CF*Y1
            VP=V1
            DO J=1,NUP
              P=P+DP
              X2=GET_KALMAN_X(P)
              Y2=GET_KALMAN_Y(P)
              Z2=GET_KALMAN_Z(P)
              V2=-SF*X2+CF*Y2
              CALL DQL2E(Z1,V1,Z2,V2)
              V1=V2
              Z1=Z2
            END DO
            IF(FPO(M)) THEN
              IF(ICOKP.GE.0) CALL DGLEVL(ICOKP)
              CALL DQPD(ZP,VP)
            END IF
            GO TO 200
C           ............................................................... RO
  207       DO J=0,NUP
              X1=GET_KALMAN_X(P)
              Y1=GET_KALMAN_Y(P)
              Z1=GET_KALMAN_Z(P)
C             .................................................. X2= CF*X1+SF*Y1
C             .................................................. Y2=-X1*SF+CF*Y1
C             .................................................. Z2= Z1
C             .................................................. X3= CT*X2+ST*Z2
C             .................................................. Y3= Y2
C             .................................................. Z3=-ST*X2+CT*Z2
C             .................................................H=X4= X3
C             ................................................ V=Y4= CG*Y3+SG*Z3
C             .................................................. Z4=-SG*Y3+CG*Z3
              X2= CF*X1+SF*Y1
              Y2=-SF*X1+CF*Y1
              H2= CT*X2+ST*Z1
              Z3=-ST*X2+CT*Z1
              V2= CG*Y2+SG*Z3
              IF(J.GT.0) THEN
                CALL DQL2E(H1,V1,H2,V2)
              ELSE IF(FPO(M)) THEN
                HP=H1
                VP=V1
              END IF
              H1=H2
              V1=V2
              P=P+DP
            END DO
            IF(FPO(M)) THEN
              IF(ICOKP.GE.0) CALL DGLEVL(ICOKP)
              CALL DQPD(HP,VP)
            END IF
  200     CONTINUE
          CALL DQCHKX
   10   CONTINUE
      END DO
      END
