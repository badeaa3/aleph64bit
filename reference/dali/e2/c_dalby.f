*DK DYX1TR
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYX1TR
CH
      SUBROUTINE DYX1TR
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
      EXTERNAL DYXDIS
      DIMENSION FFRTO(7)
C                VX VD IT T0 T3 E1 E3
      DATA FFRTO/0.,0.,3.,4.,5.,6.,7./
      DATA IPDEB/0/
      LOGICAL FBAR(2),FOUT
      LOGICAL DCCTR
      IF(MODEDT.NE.2) THEN
         CALL=DHELX0(FFRTO(2),FFRTO(3),FFRTO(4),FFRTO(6),FBAR)
      ELSE
         FFRTO(2)=0.
         CALL=DHELX1(FFRTO(3),FFRTO(4),FFRTO(6),FBAR,FOUT)
         IF(FOUT) RETURN
      END IF
      IF(DCCTR(FFRTO(4),FFRTO(5))) RETURN
      IHTFR=MIN(IHTRDO(3),7)
      IHTTO=MIN(IHTRDO(4),7)
      IF(IHTFR.GE.IHTTO) RETURN
      F1=FFRTO(IHTFR)
      H1=DHELIX(F1,IVXXDV)
      V1=DHELIX(F1,IVYYDV)
C      IF(FPRSDP) CALL DPERS(H1,V1)
      F2=FFRTO(IHTTO)
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_PTO'
      CALL DPARAM(11
     &  ,J_PTO)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      IF(PARADA(2,J_PTO).GE.1001.AND.
     &  PARADA(2,J_PTO).LE.1004.)THEN
         F2=MIN(F2,FFRTO(5))
      ELSE
         IF(.NOT.FBAR(1)) THEN
            F2=MIN(F2,FFRTO(5))
         END IF
      END IF
      IF(F1.GE.F2) RETURN
C                               IF(FPIKDP.AND.IPDEB.EQ.1) THEN
C                                 CALL DYXPIT(F1,F2)
C                               ELSE
      H2=DHELIX(F2,IVXXDV)
      V2=DHELIX(F2,IVYYDV)
      CALL DDRAWA(DYXDIS,F1,H1,V1,F2,H2,V2)
C                               END IF
      END
*DK DYXCC
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYXCC
CH
      SUBROUTINE DYXCC(SP)
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
C     Routine to connect ITC and TPC tracks(rho-z projection).-ecb
C     for each track, connect last ITC coor. to first TPC coor.
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      DIMENSION H(2),V(2)
      EQUIVALENCE (KPIKDP,K)
      LOGICAL FOUT
      IF(FPIKDP) RETURN
      CALL DSCTR
      CALL DV0(FRTLDB,NUM1,NTRK,FOUT)
      IF(FOUT) RETURN
      CALL DV0(ITCODB,NUM1I,NUM2I,FOUT)
      IF(FOUT) RETURN
      CALL DV0(TPCODB,NUM1,NUM2,FOUT)
      IF(FOUT) RETURN
      CALL DCUTFT(FP1,FP2,FC1,FC2,TP1,TP2,TC1,TC2)
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_PFI,J_PTE'
      CALL DPARAM(11
     &  ,J_PFI,J_PTE)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      FIMID=PARADA(2,J_PFI)
      TEMID=PARADA(2,J_PTE)
      DO 3 M=1,NTRK
         IF(FCUTDT) THEN
            IF(FNOTDT(M)) GO TO 3
         END IF
C      Find numbers of ITC and TPC coordinates for track M
         CALL DVCHCC(M,K1,K2,NFI)
         IF(K1.EQ.0) GO TO 3
C         CALL DLCOLT(M,NCOL)
C         IF(NCOL.EQ.0) GO TO 3
C         IF(ICOL.NE.0) CALL DGLEVL(ICOL)
         IF(FVTRDC) CALL DGLEVL(NCTRDC(M))
         I=0
         TE=DVIT(IVTEDV,K2,NFI)
         IF(TE.LT.TC1.OR.TE.GT.TC2) THEN
            I=0
            GO TO 1
         END IF
         FI=DFINXT(FIMID,DVIT(IVFIDV,K2,NFI))
         IF(FI.LT.FC1.OR.FI.GT.FC2) THEN
            I=0
            GO TO 1
         END IF
         I=I+1
         H(I)=DVIT(IVXXDV,K2,NFI)
         V(I)=DVIT(IVYYDV,K2,NFI)
         TE=DVTP(IVTEDV,K1)
         IF(TE.LT.TC1.OR.TE.GT.TC2) THEN
            I=0
            GO TO 1
         END IF
         FI=DFINXT(FIMID,DVTP(IVFIDV,K1))
         IF(FI.LT.FC1.OR.FI.GT.FC2) THEN
            I=0
            GO TO 1
         END IF
         I=I+1
         H(I)=DVTP(IVXXDV,K1)
         V(I)=DVTP(IVYYDV,K1)
         IF(I.EQ.2) CALL DQLIE(H,V)
    1 CONTINUE
    3 CONTINUE
      END
*DK DYXCHD
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYXCHD
CH
      SUBROUTINE DYXCHD(F1,H1,V1,F2,H2,V2,FM,HM,VM,D,FC)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C    Modifications:
C_CG     8-May-1989 C.Grab  Adapted to CERNVM
C
C
C!:
C    Inputs    :
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      LOGICAL FC
      IF(FC) THEN
         FKTRDP=FM
         CALL DQL2E(H1,V1,HM,VM)
         CALL DQL2E(HM,VM,H2,V2)
         RETURN
      END IF
      FM=0.5*(F1+F2)
      CALL DYXCI(FM,HM,VM)
      DHU=H2-H1
      DVU=V2-V1
      DH21=AHSCDQ*DHU+BHSCDQ*DVU
      DV21=AVSCDQ*DHU+BVSCDQ*DVU
      DHU=HM-H1
      DVU=VM-V1
      DHM1=AHSCDQ*DHU+BHSCDQ*DVU
      DVM1=AVSCDQ*DHU+BVSCDQ*DVU
      DM=(DV21*DHM1-DH21*DVM1)**2/(DV21**2+DH21**2)
      IF(D.LT.DMAXDQ.AND.DM.LT.DMAXDQ) THEN
         FKTRDP=FM
         CALL DQL2E(H1,V1,H2,V2)
         FC=.FALSE.
      ELSE
         FC=.TRUE.
         D=DM
      END IF
      END
*DK DYXCIR
CH
      SUBROUTINE DYXCI0(XP,YP,F1,F2,F3)
C----------------------------------------------------------------------
C!  -
C!
C!   Author   :- Paul Colas            26-AUG-1989
C!
C!   Inputs: XP(3), YP(3) : coordinates of the 3 points to interpolate
C!                          with a circle
C!
C!
C!   Outputs: F1,F2,F3    : phi angles of the three points in the frame
C!                          defined by the center of the circle, in a
C!                          suitable determination for drawing.
C!
C!   Libraries required: none
C!
C!   Description
C!   ===========
C!   Finds the circle which interpolates the three given points.
C?
C!======================================================================
*IF .NOT.DOC
      INCLUDE 'DALI_CF.INC'
      DIMENSION XP(3),YP(3)
      IF(YP(1).EQ.YP(2)) THEN
           YP(1)=YP(1)+0.0001
           XP(1)=XP(1)-0.0001
           ENDIF
      IF(YP(2).EQ.YP(3)) THEN
           YP(2)=YP(2)+0.0002
           XP(2)=XP(2)+0.0002
           ENDIF
      AA=-(XP(2)-XP(1))/(YP(2)-YP(1))
      CC=-(XP(3)-XP(2))/(YP(3)-YP(2))
      BB=( (YP(2)+YP(1))+(XP(2)+XP(1))*(XP(2)-XP(1))/(YP(2)-YP(1)) )/2.
      DD=( (YP(3)+YP(2))+(XP(3)+XP(2))*(XP(3)-XP(2))/(YP(3)-YP(2)) )/2.
      IF(AA.EQ.CC) AA=AA+0.00001
      X0=(DD-BB)/(AA-CC)
      Y0=(AA*DD-BB*CC)/(AA-CC)
      F1=ATAN2( YP(1)-Y0 , XP(1)-X0 )
      F2=ATAN2( YP(2)-Y0 , XP(2)-X0 )
      F3=ATAN2( YP(3)-Y0 , XP(3)-X0 )
C SOME LOGIC TO CHOOSE AN EASY-TO-USE DETERMINATION OF THE ANGLES
C Start from the (0,2pi) determination of the angles
      IF(F1.LT.0.) F1=F1+6.2831853
      IF(F2.LT.0.) F2=F2+6.2831853
      IF(F3.LT.0.) F3=F3+6.2831853
C then distinguish 6 cases
      IF(F1.LT.F3 .AND. F3.LT.F2) THEN
         F1=F1+6.2831853
       ELSE IF (F2.LT.F3 .AND. F3.LT.F1) THEN
         F2=F2+6.2831853
         F3=F3+6.2831853
       ELSE IF (F3.LT.F1 .AND. F1.LT.F2) THEN
         F3=F3+6.2831853
       ELSE IF (F2.LT.F1 .AND. F1.LT.F3) THEN
         F1=F1+6.2831853
         F2=F2+6.2831853
       ENDIF
CHECK RADIUS = CSTT
      R1=SQRT((XP(1)-X0)**2+(YP(1)-Y0)**2)
      R2=SQRT((XP(2)-X0)**2+(YP(2)-Y0)**2)
      R3=SQRT((XP(3)-X0)**2+(YP(3)-Y0)**2)
      R0= (R1+R2+R3) / 3.
      RETURN
      ENTRY DYXCI(FI,X,Y)
C----------------------------------------------------------------------
C!  -
C!
C!   Author   :- Paul Colas            26-AUG-1989
C!
C!   Input: FI : phi angle of the point of the circle found above you
C!               want the cartesian coordinates
C!
C!
C!   Outputs: x,y : coordinates of the points define by angle phi
C!
C!   Libraries required: none
C!
C!   Description
C!   ===========
C!   Finds the coordinates of the point of the above found circle defined
C!   by its phi angle.
C?
C!======================================================================
*IF .NOT.DOC
      X=X0+COS(FI)*R0
      Y=Y0+SIN(FI)*R0
C      IF(FPRSDP) CALL DPERS(X,Y)
  999 RETURN
      END
*DK DYXD
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYXD
CH
      SUBROUTINE DYXD
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
      INCLUDE 'DALI_EX.INC'
      LOGICAL FEMTY
      CHARACTER *2 TH,TV
      DIMENSION SCA(4)
C      DATA QSP/-0.001/,TOSIC/16./,S1/1./
      DATA TOSIC/16./,S1/1./
      DIMENSION HRB(4),VRB(4),PNOPS(4)
      DATA PNOPS/0.,0.,0.,-1./
      CHARACTER *2 TX,TY
      PARAMETER (TX='X'//(''''))
      PARAMETER (TY='Y'//(''''))
C                                       clear window
      CALL DQCL(IAREDO)
C                                       set up perspective deformation
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_PFI,J_PFR,J_PTO,J_PAS,J_PDS,J_PSW,J_PHM'
      CALL DPARAM(10
     &  ,J_PFI,J_PFR,J_PTO,J_PAS,J_PDS,J_PSW,J_PHM)
      TPARDA=
     &  'J_CFL'
      CALL DPARAM(40
     &  ,J_CFL)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      IF(ABS(PARADA(4,J_CFL)).EQ.1.
     &  .AND.PARADA(2,J_PTO).GT.DSOFDU) THEN
        CALL DQPRS0(PARADA(1,J_PDS))
      ELSE
        CALL DQPRS0(PNOPS)
      END IF
      DFWI=DFWIDU(IZOMDO)
      IF(FPRSDQ) DFWIDU(IZOMDO)=MOD(DFWI,100.)-MOD(DFWI,10.)
      CALL DQWIL(MOD(DFWIDU(IZOMDO),10.))
C                                       setup of detector flags
      CALL DDRFLG
C                                       no detector selected from>to
      IF(FNOPDR) GO TO 99
      RFR=PARADA(2,J_PFR)
      RTO=PARADA(2,J_PTO)
      CALL DGRBST(HRB,VRB,FEMTY)
      IF(FEMTY) THEN
        IF(IZOMDO.EQ.0) THEN
C                                       no zoom
C                                       calculate user range
          CALL DQRER(1,RTO,0.,0.,0.,HRB,VRB)
C                                       calculate scaling
          SCA(1)=HRB(1)
          SCA(2)=HRB(3)
          SCA(3)=VRB(1)
          SCA(4)=VRB(3)
          IROTA=ROTADU
          IF(IAREDO.NE.IROTA.AND.IROTA.LT.13) THEN
            TH='X '
            TV='Y '
            FIWE=0.
          ELSE
C           .......................................... rotiere xy fur WR AND WW
            TH=TX
            TV=TY
            FIWE=PARADA(2,J_PFI)+180.
            FI=PARADA(2,J_PFI)-90.
            SF=SIND(FI)
            CF=COSD(FI)
            IF(IAREDO.EQ.0) THEN
              SF=1.5*SF
              CF=1.5*CF
            END IF
            DO 700 K=1,4
              HHH   = SF*HRB(K)+CF*VRB(K)
              VRB(K)=-CF*HRB(K)+SF*VRB(K)
              HRB(K)=HHH
  700       CONTINUE
          END IF
        ELSE
C                                       calculate user area for zooming
          CALL DFRRCB(HRB,VRB)
          CALL DYXRCB(HRB,VRB,TH,TV,SCA)
          IF(TH.EQ.'X ') THEN
            FIWE=0.
          ELSE
            FIWE=9999.
          END IF
        END IF
      END IF
C                                       calculate 2-d linear transformation
      CALL DQRUPR(HRB,VRB)
C     SET UP ENERGY SCALING + X-SCALING IF NO TIC MARKS
      RPOSDT=RTO
C      IF(IZOMDO.EQ.0.OR.PARADO(4,IPSPDO).LT.0.) THEN
C         SP=0.
C      ELSE
C         SP=QSP*PARADO(2,IPSPDO)
C      END IF
C                               unpack data vector (=ihtrdo)(hits,tracks ....)
      CALL DHTINP
      CALL DCTYP0(1)
C                                       draw manual track
      IF(IHTRDO(1).EQ.0) THEN
         CALL DYXET1(SP)
         CALL DQFR(IAREDO)
         GO TO 999
      END IF
      IF(ABS(PARADA(4,J_CFL)).NE.2.) THEN
        IF(PDCODD(4,KSAODD).EQ.1.) THEN
          CALL DQSHA0(PDCODD(2,KSDBDD),
     &                PDCODD(2,KSAIDD),
     &                PDCODD(2,KSAODD),
     &                PDCODD(2,KSLBDD))
          CALL DODITC('SYX')
          CALL DODTPC('SYX')
          CALL DODECA('SYX','BARREL')
          CALL DODHCA('SYX','BARREL')
        ELSE
          CALL DODMAG(' YX')
        END IF
        CALL DODBPI(' YX')
        CALL DODTPC(' YX')
        CALL DODVDT(' YX')
        CALL DODITC(' YX')
        CALL DODECA(' YX','BARREL')
        CALL DODHCA(' YX','BARREL')
        CALL DODMUD(' YX','BAR+MA',0)
        CALL DQMID
C       SET UP ENERGY SCALING + X-SCALING IF NO TIC MARKS
        CALL DQSC0('2 SC')
        CALL DAPEF('YX')
        IF(IHTRDO(1).GE.2.AND.IHTRDO(1).LT.6) THEN
           IF(IHTRDO(2).EQ.1) THEN
C                                       draw connected tpc hits
              IF(FTPCDR) CALL DYXTT(SP)
              IF(FITCDR) THEN
C                                       draw connected itc hits
                CALL DYXTI(SP)
C                                       draw connected tpc-itchits
                CALL DYXCC(SP)
              END IF
            ELSE
C                                       draw Julia tracks
               CALL DAP_TR
C              ........................ draw V0 tracks
               CALL DAP_V0_TR('YX')
C              ........................ draw tracks calculated in VX
               CALL DAPTN('YX')
C            END IF
           END IF
        END IF
        IF(IHTRDO(1).LE.2) THEN
C                                         draw vertex detector hits
          CALL DAPPV('YX',0)
          CALL DAPVC('YX',0)
C                                       draw itc hitc
          IF(FITCDR) CALL DYF_IT_HI
          IF(IHTRDO(6).LE.1) THEN
            CALL DAPPT('YX',DVTP,TPCODB,0)
          ELSE IF(IHTRDO(6).EQ.2) THEN
            CALL DAPPT('YX',DVPADA,TPADDB,0)
          ELSE IF(IHTRDO(6).EQ.3) THEN
            CALL DAPPT('YX',DVTP,TBCODB,0)
          END IF
        END IF
C                                         draw primary vertex
        CALL DAPVX('YX',LDUM)
        CALL DAP_KNV('YX',LDUM)
C       IF(BNUMDB(2,PYERDB).NE.0.) CALL DQVRT(VRTXDV,VRTYDV)
C                                         draw 0,0
C
C                                         set ups histogram size
        IF(FECADR.AND.ABS(PARADA(4,J_PSW)).NE.1.) THEN
          IRHST=1
        ELSE
          IRHST=2
        END IF
C                                         HCAL HISTOGRAM AREAS
        IF(FHCADR.AND.PARADA(2,J_PHM).GT.0.) CALL DYXHH(IRHST,2)
C                                         ECAL
        IF(FECADR) THEN
           CALL DAPEO('YX')
           IF(ABS(PARADA(4,J_PSW)).EQ.1.) THEN
C            NO WIRES ; pads and maybe histogram outside
             IF(PARADA(4,J_PHM).EQ.1.) THEN
               CALL DAPPE('YX')
               IF(PARADA(2,J_PHM).GT.0.) CALL DYXHE(2)
             ELSE
               IF(PARADA(2,J_PHM).GT.0.) CALL DYXHE(1)
             END IF
           ELSE
C            wires    ; pads or histogram inside
             CALL DYXWE(FIWE)
             IF(PARADA(2,J_PHM).GT.0.) THEN
               CALL DYXHE(IRHST)
             ELSE
               CALL DAPPE('YX')
             END IF
           END IF
        END IF
C                                         HCAL HISTOGRAM LINES
        IF(FHCADR.AND.PARADA(2,J_PHM).GT.0.) CALL DYXHH(IRHST,1)
C                                         HCAL PADS AND TUBES
        IF(FHCADR) THEN
          IF(PARADA(2,J_PHM).LE.0.) CALL DYXPH(SP)
          CALL DAPETR('YX')
          CALL DYXTH
        END IF
C                                         MUONS
        CALL=DVMDCU(1.)
        CALL DAPPT('YX',DVMD,MHITDB,0)
        CALL DAPTRF('YX')
        IF(FPIKDP) GO TO 999
C                                         write text und scaling ...
        IF(PARADA(2,J_PTO).GT.200.) THEN
          IF(PARADA(2,J_PHM).EQ.1.) THEN
C                        123456789 123456789
            CALL DCTYEX('YX endcap histogram',19)
          ELSE IF(PARADA(2,J_PHM).EQ.2.) THEN
            CALL DCTYEX('YX hist.of BA.+E.C.',19)
          ELSE IF(PARADA(2,J_PHM).EQ.3.) THEN
            CALL DCTYEX('YX barrel histogram',19)
          END IF
        ELSE
          CALL DCTYEX('YX   ',5)
        END IF
      ELSE
        IF(PARADA(2,J_PTO).GT.TOSIC) THEN
          CALL DODLCA(' YX')
          CALL DODSIC(' YX')
          STY=PDCODD(2,ISTYDD)
          IF(STY.GE.2.) THEN
            PDCODD(2,ISTYDD)=S1
            CALL DODLCA(' YX')
            PDCODD(2,ISTYDD)=STY
          END IF
          CALL DECGL('EC')
          CALL DECPL('EC')
          CALL DSCD1('YX')
        ELSE
          CALL DODSIC(' YX')
          CALL DSCD1('YX')
        END IF
      END IF
      IF(FEMTY) THEN
        CALL DQSCA('H',SCA(1),SCA(2),'cm',2,TH,2)
        CALL DQSCA('V',SCA(3),SCA(4),'cm',2,TV,2)
      ELSE
C       ...................................... 3 point rubber band
        CALL DGRBSC(HRB,VRB,SCA,HDUM,VDUM,PARADA(2,J_PAS))
        CALL DQSCA('H',SCA(1),SCA(2),'cm',2,' ',0)
        CALL DQSCA('V',SCA(3),SCA(4),'cm',2,' ',0)
      END IF
C                                       write color scale
      IF(PARADA(2,J_PTO).LT.1005.) THEN
         CALL DLSITX(MTPCDL)
      ELSE IF(PARADA(2,J_PTO).LT.1008.) THEN
         CALL DLSITX(MECADL)
      ELSE
         CALL DLSITX(MHCADL)
      END IF
C                                       finish = draw frame
   99 CALL DQFR(IAREDO)
C                                       store parameters (pstods)
      CALL DPCSAR
  999 DFWIDU(IZOMDO)=DFWI
      END
*DK DYXDIS
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYXDIS
CH
      SUBROUTINE DYXDIS(F1,H1,V1,F2,H2,V2,FM,HM,VM,D,FC)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C    Modifications:
C_CG     8-May-1989 C.Grab  Adapted to CERNVM
C
C
C!:
C    Inputs    :
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      LOGICAL FC
      IF(FC) THEN
         FKTRDP=FM
         CALL DQL2EP(H1,V1,HM,VM)
         CALL DQL2EP(HM,VM,H2,V2)
         RETURN
      END IF
      FM=0.5*(F1+F2)
      HM=DHELIX(FM,IVXXDV)
      VM=DHELIX(FM,IVYYDV)
      DHU=H2-H1
      DVU=V2-V1
      IF(DHU.EQ.0..AND.DVU.EQ.0.) THEN
        FKTRDP=FM
        FC=.FALSE.
        RETURN
      END IF
      DH21=AHSCDQ*DHU+BHSCDQ*DVU
      DV21=AVSCDQ*DHU+BVSCDQ*DVU
      DHU=HM-H1
      DVU=VM-V1
      DHM1=AHSCDQ*DHU+BHSCDQ*DVU
      DVM1=AVSCDQ*DHU+BVSCDQ*DVU
      DM=(DV21*DHM1-DH21*DVM1)**2/(DV21**2+DH21**2)
      IF(D.LT.DMAXDQ.AND.DM.LT.DMAXDQ) THEN
         FKTRDP=FM
         CALL DQL2EP(H1,V1,H2,V2)
         FC=.FALSE.
      ELSE
         FC=.TRUE.
         D=DM
      END IF
      END
*DK DYXET1
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYXET1
CH
      SUBROUTINE DYXET1(SP)
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
      MODEDT=1
      CALL DCIRCL
      CALL DQLEVL(LCNCDD)
      CALL DVXT(0,XYZVDT)
      CALL DYX1TR
      END
*DK DYXETA
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYXETA
CH
      SUBROUTINE DYXETA(SP)
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
      DATA W2/2./
      LOGICAL FOUT,DVM0
      LOGICAL DCCVX
      EXTERNAL DVTR0
      CALL DAPTRN('YX',0)
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_PTE'
      CALL DPARAM(11
     &  ,J_PTE)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      IF(IHTRDO(2).LE.2) THEN
         CALL DSCTR
         CALL DV0(FRFTDB,NUM1,NUM2,FOUT)
         IF(FOUT) RETURN
         MODEDT=1
         IF(.NOT.FPIKDP.AND.PDCODD(4,NFTRDD).GT.0.) THEN
           CALL DQLEVL(NFTRDD)
           DLINDD=DLINDD+W2
           DO 301 N=NUM1,NUM2
             IF(FNOTDT(N)) GO TO 301
             CALL DVTRV(N)
             CALL DVXT(N,XYZVDT)
             CALL DYX1TR
  301      CONTINUE
           DLINDD=DLINDD-W2
         END IF
         DO 1 N=NUM1,NUM2
            IF(FNOTDT(N)) GO TO 1
            IF(FVTRDC) CALL DGLEVL(NCTRDC(N))
            CALL DVTRV(N)
            CALL DVXT(N,XYZVDT)
            CALL DYX1TR
            CALL DAPTRN('YX',N)
    1    CONTINUE
      ELSE
         CALL DQLEVL(LCNCDD)
         MODEDT=2
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
               CALL DYX1TR
   11       CONTINUE
   12    CONTINUE
         IF(.NOT.FPIKDP) THEN
            IF(NVTX1.LE.0) RETURN
            CALL DPAR_SET_CO(49,'CMC')
            IF(ICOLDP.LT.0) RETURN
            CALL DPARGV(67,'SSY',2,SYMB)
            CALL DPARGV(67,'SSZ',2,SYSZ)
            MSYMB=SYMB
            CALL DQPD0(MSYMB,SZVXDT*BOXSDU*SYSZ,0.)
C//         DS=SZVXDT*BOXSDU*WDSNDL(2,4,MTPCDL)
C//         CALL DQPD0(3,DS,0.)
            DO 13 N=1,NVTX1
               IF(FMVXDT(N)) THEN
                  CALL DVMCVX(N,KDUM1,KDUM2,KDUM3,VTX1DT)
                  IF(DCCVX(VTX1DT)) GO TO 13
                  H=VTX1DT(1)
                  V=VTX1DT(2)
                  CALL DQPD(H,V)
               END IF
   13       CONTINUE
         END IF
      END IF
      END
*DK DYXHE
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYXHE
CH
      SUBROUTINE DYXHE(IRHST)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C_CG 11-May-1989   C.Grab  Adapted to CERNVM
C
C!:
C    Inputs    :
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      CHARACTER *3 DT3,T3
      DIMENSION H1(12),V1(12),DH(12),DV(12)
      DIMENSION EBOR(2),QSCL(2)
      DATA FS0/-1.83/,QSCL/45.,55./FSTEP/0.9375/,F32/32.15/
C     ... THE ECAL HISTOGRAMS AND HITS GET ALIGNED BY CHANGING EXPERIMANTALLY:
C     ... FS0 = -.2   -->  FS0=-1.83   and  F32 = 32.  -->  F32 = 32.15 ??
      DATA EBOR/183.,229.44/,DR/2./,DLIN/1./
      DIMENSION HIST(384)
      EQUIVALENCE (KPIKDP,I)
      DIMENSION HAR(4),VAR(4)
      LOGICAL FOUT,FDUM,FPRS
      EXTERNAL DVEC
C_CG
      IF(PDCODD(4,LCECDD).EQ.-1.) RETURN
      IF(FPIMDP) RETURN
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_PFI,J_PTE,J_PSE,J_PHM'
      CALL DPARAM(10
     &  ,J_PFI,J_PTE,J_PSE,J_PHM)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      IF(ABS(PARADA(2,J_PSE)).LT.0.001) RETURN
      CALL DV0(ESDADB,NUM1,NUM2,FOUT)
      IF(FOUT) RETURN
      CALL DPAR_SET_WIDTH(63,'SHL',0,'***')
      FPRS=FPRSDQ
      CALL DQPRSF('OFF')
      CALL DCUTFT(FS1,FS2,FC1,FC2,TS1,TS2,TC1,TC2)
      FIMID=PARADA(2,J_PFI)
      TEMID=PARADA(2,J_PTE)
      CALL VZERO(HIST,384)
      MODE=PARADA(2,J_PHM)-2.
      DO 1 K=NUM1,NUM2
         CALL DCUTEC(K,FOUT)
         IF(FOUT) GO TO 1
         TE=DVEC(IVTEDV,K)
         IF(TE.LT.TC1.OR.TE.GT.TC2) GO TO 1
         FI=DFINXT(FIMID,DVEC(IVFIDV,K))
         IF(FI.LT.FC1.OR.FI.GT.FC2) GO TO 1
         JJ=DVEC(IVJJDV,K)
         II=DVEC(IVIIDV,K)
         E =DVEC(IVENDV,K)
         IF     (JJ.GE.51.AND.JJ.LE.178) THEN
C          BARREL : I=1,384
           IF(MODE.GE.0.) HIST(II)=HIST(II)+E
         ELSE IF(JJ.GE.41.AND.JJ.LE.188) THEN
C          ENDCAP : I=1,384
           IF(MODE.LE.0.) HIST(II)=HIST(II)+E
         ELSE IF(JJ.GE.25.AND.JJ.LE.204) THEN
C          ENDCAP : I=1,288
           IF(MODE.LE.0) THEN
             M=MOD(II,3)
             IF(M.EQ.0) THEN
               EQ=E*0.25
               N=(4*II  )/3
               HIST(N-1)=HIST(N-1)+EQ
               HIST(N  )=HIST(N  )+E-EQ
             ELSE IF(M.EQ.1) THEN
               EQ=E*0.25
               N=(4*II-1)/3
               HIST(N+1)=HIST(N+1)+EQ
               HIST(N  )=HIST(N  )+E-EQ
             ELSE
               E=E*0.5
               N=(4*II-2)/3
               HIST(N+1)=HIST(N+1)+E
               HIST(N  )=HIST(N  )+E
             END IF
           END IF
         ELSE IF(JJ.GE.9.AND.JJ.LE.220) THEN
C          ENDCAP : I=1,192
           IF(MODE.LE.0) THEN
             E=E*0.5
             N=2*II
             HIST(N  )=HIST(N  )+E
             HIST(N-1)=HIST(N-1)+E
           END IF
         ELSE
C          ENDCAP : I=1,96
           IF(MODE.LE.0) THEN
             N2=4*II
             E=E*0.25
             DO 701 N=N2-3,N2
               HIST(N)=HIST(N)+E
  701        CONTINUE
           END IF
         END IF
    1 CONTINUE
      IF(PARADA(4,J_PSE).EQ.-1.) THEN
         EMAX=.01
         DO 2 I=1,384
            IF(HIST(I).GT.EMAX) EMAX=HIST(I)
    2    CONTINUE
         IF(EMAX.GT.0.) PARADA(2,J_PSE)=EMAX/SHECDU
      END IF
      EMAX=PARADA(2,J_PSE)
      Q=QSCL(IRHST)/EMAX
C     SCALDS(IAREDO,MSECDS)=Q*AHSCDQ
      IF(IOLD.NE.IRHST) THEN
         IOLD=IRHST
         FS=FS0+15.
         R0=EBOR(IRHST)/COSD(15.)+DR
         DO 3 IS=1,12
            H1(IS)=R0*COSD(FS-15.)
            V1(IS)=R0*SIND(FS-15.)
            H2    =R0*COSD(FS+15.)
            V2    =R0*SIND(FS+15.)
            DH(IS)=(H2-H1(IS))/F32
            DV(IS)=(V2-V1(IS))/F32
            FS=FS+30.
    3    CONTINUE
      END IF
      IF(HIMXDU.EQ.0.) THEN
        HIMAX=999.
      ELSE
        HIMAX=QSCL(IRHST)+0.01
      END IF
      IF(FPIKDP) THEN
        MDLRDP=2010
        MODD=1
      ELSE
        CALL DQRA0(2,LCECDD)
        MODD=1
        PES=PDCODD(2,LCESDD)
        IF(PDCODD(2,ISTYDD).GE.2..AND.
     &    (SQRT(AHSCDQ*AHSCDQ+BHSCDQ*BHSCDQ).GT.PES.OR.
     &     SQRT(AVSCDQ*AVSCDQ+BVSCDQ*BVSCDQ).GT.PES)) MODD=2
      END IF
      DLINDD=DLIN
      DO 31 M=1,MODD
        I=0
        FS=FS0
        DO 32 IS=1,12
          H=H1(IS)
          V=V1(IS)
C         SF=SIND(FS)
C         CF=COSD(FS)
          DF=FSTEP*0.5
          DO 33 II=1,32
            HH=H+DH(IS)
            VV=V+DV(IS)
            I=I+1
            IF(HIST(I).NE.0.) THEN
              EN=Q*HIST(I)
              HP=H
              VP=V
              HHP=HH
              VVP=VV
              IF(FPRS) THEN
                CALL DQPRS(HP,VP)
                CALL DQPRS(HHP,VVP)
              END IF
              HAR(1)= HP
              VAR(1)= VP
              CFE=COSD(FS+DF)*EN
              SFE=SIND(FS+DF)*EN
              HAR(2)= HP+CFE
              VAR(2)= VP+SFE
              HAR(3)=HHP+CFE
              VAR(3)=VVP+SFE
              HAR(4)=HHP
              VAR(4)=VVP
              IF(FPIKDP) THEN
                CALL DQPIK(0.5*(HAR(1)+HAR(4)),0.5*(VAR(1)+VAR(4)))
              ELSE
                CALL DQRAR(HAR,VAR)
              END IF
            END IF
            DF=DF+FSTEP
            H=HH
            V=VV
   33     CONTINUE
          FS=FS+30.
   32   CONTINUE
        CALL DQRA0(1,LCELDD)
   31 CONTINUE
      DLINDD=PDCODD(2,LITRDD)
      IF(.NOT.FPIKDP) THEN
        H=Q*PARADA(2,J_PSE)*COSD(PARADA(2,J_PFI))
        V=Q*PARADA(2,J_PSE)*SIND(PARADA(2,J_PFI))
        CALL DQPOC(0.,0.,H0,V0,FDUM)
        CALL DQPOC(H,V,HH,VV,FDUM)
        T3=DT3(PARADA(2,J_PSE))
        E=SQRT((HH-H0)**2+(VV-V0)**2)
        CALL DQSCE(T3//'Gev EC',9,E)
        SCALDS(IAREDO,MSECDS)=E/PARADA(2,J_PSE)
      END IF
      CALL DQPRSF('LAST')
      CALL DPAR_SET_TR_WIDTH
      RETURN
CH..............---
CH
CH
CH
CH
CH
CH
CH --------------------------------------------------------------------  DYXHEP
CH
      ENTRY DYXHEP(NTOWR)
CH
CH --------------------------------------------------------------------
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C!:  CALLED BY PICKING: TYPE HIST(1,NTOWR)
C    Inputs    :$ OF TORWE
C    Outputs   :NO
C
C    Called by :
C ---------------------------------------------------------------------
      CALL DYXHPI(HIST,384,NTOWR,'EC')
      END
*DK DYXHH
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYXHH
CH
      SUBROUTINE DYXHH(IRHST,LORA)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C_CG 11-May-1989   C.Grab  Adapted to CERNVM
C
C!:
C    Inputs    :LORA = LINE (1) OR AREA (2)
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      CHARACTER *3 DT3,T3
      DIMENSION QSCL(2)
      DATA QSCL/44,55/
      DIMENSION H1(13),V1(13),DH(12),DV(12)
      DATA HBIR,HBOR/297.3,468.4/,DHB/1./
      DATA QK/1./,FSTEP/3.75/
      DIMENSION HAR(4),VAR(4)
      DIMENSION HIST(97)
      DATA STH/-1/,JMAX/64/
      EQUIVALENCE (KPIKDP,I)
      LOGICAL FOUT,FDUM,FPRS,FSTRT
      DATA FSTRT/.TRUE./
      EXTERNAL DVHC
      IF(PDCODD(4,LCHCDD).EQ.-1.) RETURN
      IF(FPIMDP) RETURN
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_PFI,J_PTE,J_PSH,J_PHM'
      CALL DPARAM(10
     &  ,J_PFI,J_PTE,J_PSH,J_PHM)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      IF(.NOT.FPIKDP) THEN
        CALL DPAR_SET_WIDTH(64,'SHL',0,'***')
        IF(HSTRDU.EQ.0.) THEN
          IF(LORA.EQ.1) THEN
            IF(PDCODD(2,LCHLDD).EQ.0.) RETURN
            IF(PDCODD(2,LCHLDD).GT.0..AND.PDCODD(2,ISTYDD).GT.1) THEN
C             .............................................. AREA LINES
              CALL DQRA0(1,LCHLDD)
              MODD=1
            ELSE
C             .............................................. SHORT LINES
              CALL DQLEVL(LCHLDD)
              MODD=2
            END IF
          ELSE
            IF(PDCODD(2,LCHCDD).EQ.0..OR.PDCODD(2,ISTYDD).LE.1.) RETURN
C           ...................................................... AREAS
            CALL DQRA0(2,LCHCDD)
            MODD=1
          END IF
        ELSE
          IF(LORA.EQ.2) THEN
C           .................................................... NO AREAS
            IF(HSTRDU.GT.2) RETURN
C           ...................................................... AREAS
            CALL DQRA0(2,LCHCDD)
            MODD=1
          ELSE
C           .................................................... NO LINES
            IF(     HSTRDU.EQ.2) RETURN
            IF(     HSTRDU.EQ.1.OR.HSTRDU.EQ.4) THEN
C             .............................................. SHORT LINES
              CALL DQLEVL(LCHLDD)
              MODD=2
            ELSE IF(HSTRDU.EQ.3..OR.HSTRDU.EQ.5.) THEN
C             .............................................. AREA LINES
              CALL DQRA0(1,LCHLDD)
              MODD=1
              IF(   HSTRDU.EQ.5.) THEN
                PARADA(4,J_PSH)=1.
                JJSKL=1
              END IF
            END IF
          END IF
        END IF
      ELSE
        MODD=1
      END IF
      CALL DV0(HSDADB,NUM1,NUM2,FOUT)
      IF(FOUT) RETURN
      MDLRDP=2000
      FPRS=FPRSDQ
      CALL DQPRSF('OFF')
      CALL DCUTFT(FS1,FS2,FC1,FC2,TS1,TS2,TC1,TC2)
      FIMID=PARADA(2,J_PFI)
      TEMID=PARADA(2,J_PTE)
C     ........................................... CALCULATE HISTOGRAM POSITION
      IF(FSTRT) THEN
        FSTRT=.FALSE.
        FS=0.
        DO IS=1,12
          H1(IS)=COSD(FS-15.)
          V1(IS)=SIND(FS-15.)
          H2    =COSD(FS+15.)
          V2    =SIND(FS+15.)
          DH(IS)=(H2-H1(IS))/8.
          DV(IS)=(V2-V1(IS))/8.
          FS=FS+30.
        END DO
        H1(13)=H1(1)
        V1(13)=V1(1)
      END IF
C     ................................................... CALCULATE HISTOGRAM
      MODE=PARADA(2,J_PHM)-2.
  444 CALL VZERO(HIST,97)
      DO 1 K=NUM1,NUM2
         TE=DVHC(IVTEDV,K)
         IF(TE.LT.TC1.OR.TE.GT.TC2) GO TO 1
         FI=DFINXT(FIMID,DVHC(IVFIDV,K))
         IF(FI.LT.FC1.OR.FI.GT.FC2) GO TO 1
         NN=DVHC(IVNNDV,K)
         II=DVHC(IVIIDV,K)
         JJ=DVHC(IVJJDV,K)
         IF(HSTRDU.EQ.5.AND.JJ.NE.JJSKL) GO TO 1
         E =DVHC(IVENDV,K)
         IF     (NN.EQ.2) THEN
C          .................................................. BARREL : I=1,96
           IF(MODE.GE.0.) HIST(II)=HIST(II)+E
         ELSE IF(JJ.GE.11.AND.JJ.LE.52) THEN
C          .................................................. ENDCAP : I=1,96
           IF(MODE.LE.0.) HIST(II)=HIST(II)+E
         ELSE IF(JJ.GE. 5.AND.JJ.LE.58) THEN
C          .................................................. ENDCAP : I=1,48
           IF(MODE.LE.0) THEN
             E=E*0.5
             N=2*II
             HIST(N  )=HIST(N  )+E
             HIST(N-1)=HIST(N-1)+E
           END IF
         ELSE
C          ................................................... ENDCAP : I=1,24
           IF(MODE.LE.0) THEN
             N2=4*II
             E=E*0.25
             DO 701 N=N2-3,N2
               HIST(N)=HIST(N)+E
  701        CONTINUE
           END IF
         END IF
    1 CONTINUE
      HIST(97)=HIST(1)
      QK=(HBIR+0.5*PDCODD(2,ISTHDD)*(HBOR-HBIR))/COSD(15.)
      IF(PARADA(4,J_PSH).EQ.-1.) THEN
         EMAX=.01
         DO 3 I=1,96
           IF(HIST(I).GT.EMAX) EMAX=HIST(I)
    3    CONTINUE
         PARADA(2,J_PSH)=EMAX/SHHCDU
      END IF
      EMAX=PARADA(2,J_PSH)
      Q=QSCL(IRHST)/EMAX
      IF(HIMXDU.EQ.0.) THEN
        HIMAX=999.
      ELSE
        HIMAX=QSCL(IRHST)+DHB+0.001
      END IF
C     ......................................................... DRAW HISTOGRAM
      I=92
      FS=-15.
      EN=Q*HIST(96)
      CF=COSD(FS)
      SF=SIND(FS)
      CFE=CF*EN
      SFE=SF*EN
      HL=H1(1)*QK+CFE
      VL=V1(1)*QK+SFE
      ENL=0.
C     .................................... DRAW HISTOGRAM (AREA OR AREA LINES)
      IF(MODD.EQ.1) THEN
        DLINDD=PDCODD(2,LIGLDD)
        DO 16 IS=1,12
          H=H1(IS)*QK
          V=V1(IS)*QK
          HP=H
          VP=V
          IF(FPRS) THEN
            CALL DQPRS(HP,VP)
          END IF
          SH=DH(IS)*QK
          SV=DV(IS)*QK
          DF=FSTEP*0.5
          DO 15 II=1,8
            I=MOD(I,96)+1
            EN=Q*HIST(I)+DHB
            IF(EN.GT.HIMAX) EN=HIMAX
            HAR(1)=HP
            VAR(1)=VP
            HAR(2)=HP+CF*EN
            VAR(2)=VP+SF*EN
            CF=COSD(FS+DF)
            SF=SIND(FS+DF)
            H=H+SH
            V=V+SV
            HP=H
            VP=V
            IF(FPRS) THEN
              CALL DQPRS(HP,VP)
            END IF
            HAR(4)=HP
            VAR(4)=VP
            HAR(3)=HP+CF*EN
            VAR(3)=VP+SF*EN
            IF(FPIKDP) THEN
              CALL DQPIK(0.5*(HAR(1)+HAR(4)),0.5*(VAR(1)+VAR(4)))
            ELSE
              IF(EN.GT.DHB) CALL DQRAR(HAR,VAR)
            END IF
            DF=DF+FSTEP
   15     CONTINUE
          FS=FS+30.
   16   CONTINUE
      ELSE
C       .......................................... DRAW OUTER HISTOGRAM LINES
        DLINDD=PDCODD(2,LIDTDD)
        DO 6 IS=1,12
          H=H1(IS)*QK
          V=V1(IS)*QK
          HP=H
          VP=V
          IF(FPRS) THEN
            CALL DQPRS(HP,VP)
          END IF
          SH=DH(IS)*QK
          SV=DV(IS)*QK
          DF=FSTEP*0.5
          DO 5 II=1,8
            I=MOD(I,96)+1
            EN=Q*HIST(I)+DHB
            IF(EN.GT.HIMAX) EN=HIMAX
            HR=HP+CF*EN
            VR=VP+SF*EN
            IF(EN.GT.DHB.OR.ENL.GT.DHB)
     &        CALL DQL2E(HL,VL,HR,VR)
            ENL=EN
            CF=COSD(FS+DF)
            SF=SIND(FS+DF)
            H=H+SH
            V=V+SV
            HP=H
            VP=V
            IF(FPRS) THEN
              CALL DQPRS(HP,VP)
            END IF
            HL=HP+CF*EN
            VL=VP+SF*EN
            IF(EN.GT.DHB) CALL DQL2E(HR,VR,HL,VL)
            DF=DF+FSTEP
    5     CONTINUE
          FS=FS+30.
    6   CONTINUE
      END IF
      IF(HSTRDU.EQ.5..AND.JJSKL.LT.JMAX) THEN
        JJSKL=JJSKL+1
        GO TO 444
      END IF
      DLINDD=PDCODD(2,LITRDD)
      IF((.NOT.FPIKDP).AND.(LORA.EQ.1.OR.FBLWDT)) THEN
        H=Q*PARADA(2,J_PSH)*COSD(PARADA(2,J_PFI))
        V=Q*PARADA(2,J_PSH)*SIND(PARADA(2,J_PFI))
        CALL DQPOC(0.,0.,H0,V0,FDUM)
        CALL DQPOC(H,V,HH,VV,FDUM)
        E=SQRT((HH-H0)**2+(VV-V0)**2)
        T3=DT3(PARADA(2,J_PSH))
        CALL DQSCE(T3//'Gev HC',9,E)
        SCALDS(IAREDO,MSHCDS)=E/PARADA(2,J_PSH)
      END IF
      IF(FPRS) STH=-9.
      CALL DPAR_SET_TR_WIDTH
      CALL DQPRSF('LAST')
      RETURN
CH..............---
CH
CH
CH
CH
CH
CH
CH --------------------------------------------------------------------  DYXHHP
CH
      ENTRY DYXHHP(NTOWR)
CH
CH --------------------------------------------------------------------
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C!:  CALLED BY PICKING: TYPE HIST(1,NTOWR)
C    Inputs    :$ OF TORWE
C    Outputs   :NO
C
C    Called by :
C ---------------------------------------------------------------------
      CALL DYXHPI(HIST,96,NTOWR,'HC')
      END
*DK DYXHPI
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYXHPI
CH
      SUBROUTINE DYXHPI(HIST,NHIST,NTOWR,TC)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C_CG 11-May-1989   C.Grab  Adapted to CERNVM
C
C!:
C    Inputs    :
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      CHARACTER *2 DT2,TC
      CHARACTER *3 DT3
      CHARACTER *4 DT4
      CHARACTER *49 T
      DIMENSION HIST(*)
C        123456789 123456789 123456789 123456789 123456789
      T='YX:HC:Energy of tower  123=12.4  Sum(12)=12.4 GeV'
      T( 4: 5)=TC
      T(24:26)=DT3(FLOAT(NTOWR))
      T(28:31)=DT4(HIST(NTOWR))
      STW=0.
      SUM=0.
      J1=0
      DO JU=NTOWR,NHIST
        IF(HIST(JU).EQ.0.) GO TO 101
        SUM=SUM+HIST(JU)
        STW=STW+1.
      END DO
      DO J1=1,NTOWR-1
        IF(HIST(J1).EQ.0.) GO TO 101
        SUM=SUM+HIST(J1)
        STW=STW+1.
      END DO
  101 DO JD=NTOWR-1,J1+1,-1
        IF(HIST(JD).EQ.0.) GO TO 102
        SUM=SUM+HIST(JD)
        STW=STW+1.
      END DO
      DO J2=NHIST,JU+1,-1
        IF(HIST(J2).EQ.0) GO TO 102
        SUM=SUM+HIST(J2)
        STW=STW+1.
      END DO
  102 T(38:39)=DT2(STW)
      T(42:45)=DT4(SUM)
      CALL DWRT(T)
      END
*DK DYXPH
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYXPH
CH
      SUBROUTINE DYXPH(SP)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C_CG 11-May-1989   C.Grab  Adapted to CERNVM
C
C!:
C    Inputs    :
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      DIMENSION HL(2),VL(2)
      EQUIVALENCE (KPIKDP,K)
      DATA SHRNK /.8/
      LOGICAL FOUT
      EXTERNAL DVHC
C
      CALL DSCHC
      CALL DV0(HSDADB,NUM1,NUM2,FOUT)
      IF(FOUT) RETURN
      CALL DCUTFT(FS1,FS2,FC1,FC2,TS1,TS2,TC1,TC2)
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_PFI,J_PTE'
      CALL DPARAM(11
     &  ,J_PFI,J_PTE)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      FIMID=PARADA(2,J_PFI)
      TEMID=PARADA(2,J_PTE)
      QPI=SHRNK/PIFCDK
      DO 1 K=NUM1,NUM2
C         K=NORDDC(N)
C         IF(FPIMDP.AND.K.NE.NPIKDP) GO TO 1
         CALL DCUTHC(K,FOUT)
         IF(FOUT) GO TO 1
         TE=DVHC(IVTEDV,K)
         IF(TE.LT.TC1.OR.TE.GT.TC2) GO TO 1
         FI=DFINXT(FIMID,DVHC(IVFIDV,K))
         IF(FI.LT.FC1.OR.FI.GT.FC2) GO TO 1
C         CALL DLCOLH(DVHC,MHCADL,K,NCOL)
C         IF(NCOL.EQ.0) GO TO 1
         IF(FVHCDC) CALL DGLEVL(NCHCDC(K))
         NN=DVHC(IVNNDV,K)
         IF(NN.NE.2) GO TO 1
         H=DVHC(IVXXDV,K)
         V=DVHC(IVYYDV,K)
C         IF(FPRSDP) CALL DPERS(H,V)
C         IF(SP.NE.0.) THEN
C            Q=(1.+SP*(DVHC(IVTEDV,K)-TEMID))
C            H=H*Q
C            V=V*Q
C         END IF
         IF(FPIKDP) THEN
            CALL DQPIK(H,V)
         ELSE
            D=DVHC(IVRODV,K)*DVHC(IVDFDV,K)*QPI
            FI30=FLOAT((IFIX(DVHC(IVFIDV,K)+15.)/30)*30)
            DH=D*SIND(FI30)
            DV=D*COSD(FI30)
            HL(1)=H+DH
            HL(2)=H-DH
            VL(1)=V-DV
            VL(2)=V+DV
            CALL DQLIE(HL,VL)
         END IF
    1 CONTINUE
      RETURN
      END
*DK DYF_IT_HI
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYF_IT_HI
CH
      SUBROUTINE DYF_IT_HI
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C_CG 11-May-1989   C.Grab  Adapted to CERNVM, + bug-fix in loops;
C
C!:
C    ITC hits are drawn in YX and FR. 
C    If WI=ON : a line connecting the 2 solutions is drawn
C    If SY=ON : the assosiated hit is drawn
C                  unassociated hits are only drwan as lines
C               The data with (GT:SY:LW:DW=x) DW is NOT used.
C    Called by :
C ---------------------------------------------------------------------
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      EQUIVALENCE (KPIKDP,K)
      DIMENSION H(2),V(2),VV(2)
      LOGICAL FOUT,FYX,FSYM,FLIN
      EXTERNAL DVIT
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_PFI,J_PTE'
      CALL DPARAM(11
     &  ,J_PFI,J_PTE)
      TPARDA=
     &  'J_STC'
      CALL DPARAM(31
     &  ,J_STC)
      TPARDA=
     &  'J_SSY,J_SWI'
      CALL DPARAM(61
     &  ,J_SSY,J_SWI)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      IF(FGRYDR.AND.PARADA(4,J_STC).LT.0.) RETURN
      CALL DSCIT(IVNT)
      CALL DV0(ITCODB,NUM1,NUM2,FOUT)
      IF(FOUT) RETURN
      CALL=DVITST(IVNTDV,IVNT1,IVNT2)
      CALL DCUTFT(FS1,FS2,FC1,FC2,TS1,TS2,TC1,TC2)
      IF(IZOMDO.EQ.0) THEN
        FIMID=180.
      ELSE
        FIMID=PARADA(2,J_PFI)
      END IF
      TEMID=PARADA(2,J_PTE)
C     ...................................................... SETUP SYMBOLS
      FSYM=.FALSE.
      DUMMY=DVIC0(NICC)
      IF(NICC.GT.0.AND.PARADA(4,J_SSY).GE.0.) FSYM=.TRUE.
      IF(PARADA(4,J_SWI).LT.0.) THEN
        FLIN=.FALSE.
      ELSE
        FLIN=.TRUE.
        DLINDD=PARADA(2,J_SWI)
      END IF
      IF((.NOT.FSYM).AND.(.NOT.FLIN)) RETURN
      CALL DPAR_SET_SY(61,FOVER)
      IF(TPICDO.EQ.'YX') THEN
        FYX=.TRUE.
        FOVER=-999.
      ELSE
        FYX=.FALSE.
        IF(IZOMDO.NE.0) FOVER=-999.
      END IF
      DO 1 K=NUM1,NUM2
        IF(FCUHDT) THEN
          NTRIT=DVIT(IVNTDV,K)
          IF(FNOHDT(NTRIT)) GO TO 1
        END IF
C       .............................................T1=DVIT(IVTEDV,K,1)
C       .............................................T2=DVIT(IVTEDV,K,2)
        F1=DFINXT(FIMID,DVIT(IVFIDV,K,1))
        F2=DFINXT(F1   ,DVIT(IVFIDV,K,2))
        IF( (F1.LT.FC1.AND.F2.LT.FC1).OR.
     &      (F1.GT.FC2.AND.F2.GT.FC2) ) GO TO 1
        IF(FVITDC) CALL DGLEVL(NCITDC(K))
        IF(FYX) THEN
          H(1)=DVIT(IVXXDV,K,1)
          H(2)=DVIT(IVXXDV,K,2)
          V(1)=DVIT(IVYYDV,K,1)
          V(2)=DVIT(IVYYDV,K,2)
          IF(FLIN) THEN
            CALL DQLIEP(H,V)
            IF(FPIKDP) GO TO 1
          END IF
        ELSE
          H(1)=DVIT(IVRODV,K,1)
          H(2)=H(1)
          V(1)=F1
          V(2)=F2
          IF(FLIN) THEN
            CALL DQLIEP(H,V)
            IF(F1.LT.FOVER) THEN
              VV(1)=V(1)+360.
              VV(2)=V(2)+360.
              CALL DQLIEP(H,VV)
            END IF
            IF(FPIKDP) GO TO 1
          END IF
        END IF
        IF(FSYM) THEN
          IF(FVITDC) CALL DGLEVL(NCITDC(K))
C          IF(     NITCDV(IVNT1,K).NE.0) THEN
C            N=1
C          ELSE IF(NITCDV(IVNT2,K).NE.0) THEN
C            N=2
C          ELSE
C            GO TO 1
C          END IF
          IF(FYX) THEN
            HICC=DVIC(IVXXDV,K)
            VICC=DVIC(IVYYDV,K)
          ELSE
            HICC=DVIC(IVRODV,K)
            VICC=DFINXT(FIMID,DVIC(IVFIDV,K))
          END IF
          IF(FPIKDP) THEN
            IF(FYX) THEN
              CALL DQPIK(HICC,VICC)
            ELSE
              CALL DQPIF(HICC,VICC)
            END IF
          ELSE
            CALL DQPD(HICC,VICC)
            IF(VICC.LE.FOVER) CALL DQPD(HICC,VICC+360.)
          END IF
        END IF
    1 CONTINUE
      CALL DPAR_SET_TR_WIDTH
      END
C*DK DYXPIT
CCH..............+++
CCH
CCH
CCH
CCH
CCH
CCH
CCH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYXPIT
CCH
C      SUBROUTINE DYXPIT(F1,F2)
CCH
CCH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CCH
CC ---------------------------------------------------------------------
CC
CC    Created by H.Drevermann                   28-JUL-1988
CC
CC!:
CC    Inputs    :
CC    Outputs   :
CC
CC    Called by :
CC ---------------------------------------------------------------------
C*CA DALLCO
C      INCLUDE 'DALI_CF.INC'
CC      DATA FP/20./,KP/20/
CC      DF=(F2-F1)/FP
CC      F=F1
CC      DO 700 K=1,KP
CC        F=F+DF
CC        H=DHELIX(F,IVXXDV)
CC        V=DHELIX(F,IVYYDV)
CC        CALL DQPIK(H,V)
CC  700 CONTINUE
C      DF=F2-F1
C      DO 700 K=1,MTRSDP
C        F=F1+TRSTDP(K)*DF
C        H=DHELIX(F,IVXXDV)
C        V=DHELIX(F,IVYYDV)
C        CALL DQPIK(H,V)
C  700 CONTINUE
C      END
*DK DYXRCB
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYXRCB
CH
      SUBROUTINE DYXRCB(HRB,VRB,TH,TV,S)
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
C     Rubberband: from Cone to Box
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      DIMENSION HRB(4),VRB(4),S(4)
      CHARACTER *2 TH,TV
      CHARACTER *2 TX,TY
      PARAMETER (TX='X'//(''''))
      PARAMETER (TY='Y'//(''''))
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_PFI,J_PFR,J_PTO,J_PAS,J_PBM'
      CALL DPARAM(11
     &  ,J_PFI,J_PFR,J_PTO,J_PAS,J_PBM)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      FI=PARADA(2,J_PFI)
      R1=PARADA(2,J_PFR)
      R2=PARADA(2,J_PTO)
      CF=COSD(FI)
      SF=SIND(FI)
      IF(PARADA(2,J_PBM).LT.5.) THEN
         RM=0.5*(R1+R2)
         HM=RM*CF
         VM=RM*SF
         D2=0.5*(R2-R1)
         IF(TH.EQ.'**') THEN
           SH=1.
           SV=1.
         ELSE
           CALL DQRHV(SH,SV)
         END IF
         DH=SH*D2
         DV=SV*D2
         HRB(1)=HM-DH
         HRB(2)=HM+DH
         HRB(3)=HRB(2)
         HRB(4)=HRB(1)
         VRB(1)=VM-DV
         VRB(2)=VRB(1)
         VRB(3)=VM+DV
         VRB(4)=VRB(3)
         IF(TH.NE.'**') THEN
           TH='X '
           TV='Y '
           S(1)=HRB(1)
           S(2)=HRB(3)
           S(3)=VRB(1)
           S(4)=VRB(3)
         END IF
      ELSE
         HM1=R1*CF
         VM1=R1*SF
         HM2=R2*CF
         VM2=R2*SF
         IF(PARADA(2,J_PAS).EQ.0.) THEN
            D2=0.5*(R2-R1)
         ELSE
            D2=0.5*(R2-R1)/PARADA(2,J_PAS)
         END IF
         DH=D2*SF
         DV=D2*CF
         HRB(1)=HM1+DH
         HRB(2)=HM2+DH
         HRB(3)=HM2-DH
         HRB(4)=HM1-DH
         VRB(1)=VM1-DV
         VRB(2)=VM2-DV
         VRB(3)=VM2+DV
         VRB(4)=VM1+DV
         IF(TH(1:1).NE.'*') THEN
           TH=TX
           TV=TY
           S(1)=R1
           S(2)=R2
           S(4)=D2*SV
           S(3)=-S(4)
         END IF
      END IF
      END
*DK DYXTH
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYXTH
CH
      SUBROUTINE DYXTH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C    Inputs    :
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
C//      DATA W2/2./
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_SSZ,J_SFR'
      CALL DPARAM(64
     &  ,J_SSZ,J_SFR)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      IF(.NOT.FPIKDP.AND.
     &  PDCODD(4,NFHTDD).GT.0.)THEN
        PCN2=PDCODD(2,ICCNDD)
        PCN4=PDCODD(4,ICCNDD)
        PDCODD(2,ICCNDD)=PDCODD(2,NFHTDD)
        PDCODD(4,ICCNDD)=1.
C//     WHC=WDSNDL(2,4,MHCADL)
C//     WDSNDL(2,4,MHCADL)=WHC+W2
        WHC=PARADA(2,J_SSZ)
        PARADA(2,J_SSZ)=WHC+PARADA(2,J_SFR)
        CALL DYXTH1
        PDCODD(2,ICCNDD)=PCN2
        PDCODD(4,ICCNDD)=PCN4
C//     WDSNDL(2,4,MHCADL)=WHC
        PARADA(2,J_SSZ)=WHC
      END IF
      CALL DYXTH1
      END
*DK DYXTH1
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYXTH1
CH
      SUBROUTINE DYXTH1
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
C     DATA PIDGDK/57.29577951/
C     DATA MSAR/8/
      DATA BPTCH/1.025/,BROW1/298.9/,BDROW/7.2/
      EQUIVALENCE (KPIKDP,K)
      LOGICAL FOUT
      CALL DV0(HTUBDB,NUM1,NUM2,FOUT)
      IF(FOUT) RETURN
      CALL DQLEVH(LCHTDD(4))
      CALL DPAR_SET_SY(64,0.)
      BP2=BPTCH/2.
      DO 1 K=NUM1,NUM2
        IF(DVHT(13,K).NE.2)GO TO 1
        IMN=DVHT(12,K)
        IF(IMN.EQ.24)IMN=0
        IMN2=INT(IMN/2)
        PHI0=30.*IMN2/PIDGDK
        IF(MOD(IMN,2).NE.0) THEN
          ISGN=-1
        ELSE
          ISGN=1
        END IF
C       Y0=305.+(DVHT(11,K)-1)*7.
        Y0=BROW1+(DVHT(11,K)-1)*BDROW
        X0=DVHT(1,K)*ISGN
C
C        KKMAX = INT((DVHT(10,K)+.0001)/1.025)
C        Modified 24.11.95 by Venturi         
C
C LOOP ON HITS IN CLUSTER
C
C         DO 10 KK = -KKMAX/2,KKMAX/2
C
        KKMAX=DVHT(10,K)
        IF(MOD(KKMAX,2).EQ.0) THEN
          X=X0-BPTCH* KKMAX   /2+BP2
        ELSE
          X=X0-BPTCH*(KKMAX-1)/2
        END IF
        DO KK=1,KKMAX
          H = X * SIN (PHI0) + Y0 * COS(PHI0)
          V =-X * COS (PHI0) + Y0 * SIN(PHI0)
          IF(FPIKDP) THEN
            CALL DQPIK(H,V)
          ELSE
            CALL DQPD(H,V)
          END IF
          X=X+BPTCH
        END DO
    1 CONTINUE
      RETURN
      END
*DK DYXTI
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYXTI
CH
      SUBROUTINE DYXTI(SP)
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
      DIMENSION H(2),V(2)
      EQUIVALENCE (KPIKDP,K)
      LOGICAL FOUT
      CALL DSCTR
      CALL DV0(FRTLDB,NUM1,NTRK,FOUT)
      IF(FOUT) RETURN
      CALL DV0(ITCODB,NUM1,NUM2,FOUT)
      IF(FOUT) RETURN
      CALL DCUTFT(FP1,FP2,FC1,FC2,TP1,TP2,TC1,TC2)
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_PFI,J_PTE'
      CALL DPARAM(11
     &  ,J_PFI,J_PTE)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      FIMID=PARADA(2,J_PFI)
      TEMID=PARADA(2,J_PTE)
C      CALL DLHITR('TR',MTPCDL,icol)
      DO 3 M=1,NTRK
         IF(FCUTDT) THEN
            IF(FNOTDT(M)) GO TO 3
         END IF
         CALL=DVCHI(M,NUM)
         IF(NUM.LE.0) GO TO 3
         IF(FVTRDC) CALL DGLEVL(NCTRDC(M))
         I=0
    2    DO 1 KIND=1,NUM
C           Resolve l/r ambiguity
            K=IDVCHI(KIND)
            IF(K.GT.0) THEN
               NFI=1
            ELSE
               NFI=2
               K=-K
            END IF
            TE=DVIT(IVTEDV,K,NFI)
C           IF(TE.LT.TC1.OR.TE.GT.TC2) THEN
C              I=0
C              GO TO 1
C           END IF
            FI=DFINXT(FIMID,DVIT(IVFIDV,K,NFI))
            IF(FI.LT.FC1.OR.FI.GT.FC2) THEN
               I=0
               GO TO 1
            END IF
            I=I+1
            H(I)=DVIT(IVXXDV,K,NFI)
            V(I)=DVIT(IVYYDV,K,NFI)
C            IF(FPRSDP) CALL DPERS(H(I),V(I))
C            IF(SP.NE.0.) THEN
C               Q=(1.+SP*(DVIT(IVTEDV,K,NFI)-TEMID))
C               H(I)=H(I)*Q
C               V(I)=V(I)*Q
C            END IF
            IF(FPIKDP) THEN
               CALL DQPIK(H,V)
               I=0
               GO TO 1
            END IF
C           if this is not the first coordinate on the track, connect previous
C           point to current point.  -ecb
            IF(I.EQ.2) THEN
               CALL DQLIE(H,V)
               I=1
               H(1)=H(2)
               V(1)=V(2)
            END IF
    1    CONTINUE
    3 CONTINUE
      END
*DK DYXTT
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYXTT
CH
      SUBROUTINE DYXTT(SP)
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
      EXTERNAL DYXCHD
      DIMENSION H(300),V(300),FI(300),TE(300)
      EQUIVALENCE (KPIKDP,K)
      LOGICAL FOUT
      CALL DSCTR
      CALL DV0(FRTLDB,NUM1,NTRK,FOUT)
      IF(FOUT) RETURN
      CALL DV0(TPCODB,NUM0,NUM2,FOUT)
      IF(FOUT) RETURN
C      CALL DVTQ0(NUM2)
C      IF(NUM2.EQ.0) RETURN
      CALL DCUTFT(FP1,FP2,FC1,FC2,TP1,TP2,TC1,TC2)
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_PFI,J_PTE'
      CALL DPARAM(11
     &  ,J_PFI,J_PTE)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      FIMID=PARADA(2,J_PFI)
      TEMID=PARADA(2,J_PTE)
      DO 3 M=1,NTRK
         IF(FCUTDT) THEN
            IF(FNOTDT(M)) GO TO 3
         END IF
         CALL=DVCHT(M,NUM)
         IF(NUM.LE.0) GO TO 3
         NUM=MIN(NUM,300)
         IF(FVTRDC) CALL DGLEVL(NCTRDC(M))
         IF(FPIKDP) THEN
           DO 31 KIND=1,NUM
              K=IDVCHT(KIND)
              IF(FPIMDP.AND.K.NE.NPIKDP) GO TO 31
              TP=DVTP(IVTEDV,K)
              IF(TP.LT.TC1.OR.TP.GT.TC2) GO TO 31
              FP=DFINXT(FIMID,DVTP(IVFIDV,K))
              IF(FP.LT.FC1.OR.FP.GT.FC2) GO TO 31
              HPIK=DVTP(IVXXDV,K)
              VPIK=DVTP(IVYYDV,K)
              CALL DQPIK(HPIK,VPIK)
   31      CONTINUE
           GO TO 3
         END IF
    2    DO 1 KIND=1,NUM
            K=IDVCHT(KIND)
            TE(KIND)=DVTP(IVTEDV,K)
            FI(KIND)=DFINXT(FIMID,DVTP(IVFIDV,K))
            H (KIND)=DVTP(IVXXDV,K)
            V (KIND)=DVTP(IVYYDV,K)
    1    CONTINUE
         IF(TE(1).GE.TC1.AND.TE(1).LE.TC2.AND.
     &      TE(2).GE.TC1.AND.TE(2).LE.TC2.AND.
     &      FI(1).GE.FC1.AND.FI(1).LE.FC2.AND.
     &      FI(2).GE.FC1.AND.FI(2).LE.FC2) THEN
            CALL DYXCI0(H,V,F1,F2,F3)
            CALL DDRAWA(DYXCHD,F1,H(1),V(1),F2,H(2),V(2))
         END IF
         DO 4 K=1,NUM-2
           IF(TE(K+1).GE.TC1.AND.TE(K+1).LE.TC2.AND.
     &        TE(K+2).GE.TC1.AND.TE(K+2).LE.TC2.AND.
     &        FI(K+1).GE.FC1.AND.FI(K+1).LE.FC2.AND.
     &        FI(K+2).GE.FC1.AND.FI(K+2).LE.FC2) THEN
              CALL DYXCI0(H(K),V(K),F1,F2,F3)
              CALL DDRAWA(DYXCHD,F2,H(K+1),V(K+1),F3,H(K+2),V(K+2))
           END IF
    4    CONTINUE
    3 CONTINUE
      END
*DK DYXWE
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYXWE
CH
      SUBROUTINE DYXWE(FIWE)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
      INCLUDE 'DALI_CF.INC'
      EQUIVALENCE (KPIKDP,MD)
      CHARACTER *1 TS(3)
      DATA TS/'+','-',' '/
      CHARACTER *3 DT3,T3
      DIMENSION EWIR(45),WIR(45),RO(3)
      DATA RMID/232./,QBIN/1.5/,QSET/1./,FSTRT/-37./
      DIMENSION M1(3),M2(3)
      DATA M1/ 1,25,13/
      DATA M2/12,36,24/
      LOGICAL FOUT
      DATA Q10/1.0154/
      CALL DV0(PEWDDB,NUM1,NUM,FOUT)
      IF(FOUT) RETURN
      RO(1)=RMID*Q10
      RO(2)=RO(1)
      RO(3)=RMID
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_PNB,J_PSW,J_PBW,J_PMW'
      CALL DPARAM(12
     &  ,J_PNB,J_PSW,J_PBW,J_PMW)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      IF(PARADA(4,J_PNB).EQ.1.) THEN
        NBIN=PARADA(2,J_PNB)
      ELSE
        S=MIN(SQRT(AHSCDQ**2+BHSCDQ**2),SQRT(AVSCDQ**2+BVSCDQ**2))
        IF(S.NE.0.) THEN
          NBIN=QBIN/S
        ELSE
          NBIN=5
        END IF
        PARADA(2,J_PNB)=NBIN
      END IF
      NBIN=MAX(1,NBIN)
      CALL DVEWMX(NBIN,EMAX)
      IF(EMAX.EQ.0.) RETURN
      BW=PARADA(2,J_PBW)
      FI=FSTRT
      NSTEP=NBIN-1
      Q=0.

      IF(FPIKDP) THEN
        DO MS=1,3
          DO MD=M1(MS),M2(MS)
            JBIN=0
            FI=FI+30.
            CALL DVEW(MD,NWIR,WIR)
            IF(NWIR.GT.0) THEN
              IF(FIWE.NE.9999.) THEN
                FFI=FI-FIWE
              ELSE
                FFI=0.
              END IF
              H=RO(MS)*COSD(FI)
              V=RO(MS)*SIND(FI)
              JBIN=NWIR/NBIN
              CALL DQHI2_PICK(H,V,JBIN,BW,FFI)
            END IF
          END DO
          FI=FI-350.
        END DO
        RETURN
      END IF

      DO 111 MS=1,3
        CALL DQLEVL(LCWEDD(MS))
        DO 1 MD=M1(MS),M2(MS)
          JBIN=0
          FI=FI+30.
          CALL DVEW(MD,NWIR,WIR)
          IF(NWIR.EQ.0) GO TO 1
          ESEC=0.
          DO 7 KS =1,NWIR
            ESEC=ESEC+WIR(KS)
    7     CONTINUE
          IF(PARADA(4,J_PMW).EQ.1..AND.
     &       1000.*PARADA(2,J_PMW).GT.ESEC) GO TO 1
          DO 2 KB=1,NWIR,NBIN
            JBIN=JBIN+1
            EWIR(JBIN)=0.
            DO 3 K=KB,MIN(NWIR,KB+NSTEP)
               EWIR(JBIN)=EWIR(JBIN)+WIR(K)
    3       CONTINUE
    2     CONTINUE
          IF(Q.EQ.0.) THEN
            EMX=QSET*FLOAT(JBIN)
            IF(PARADA(4,J_PSW).LT.0.) PARADA(2,J_PSW)=0.001*EMAX
C            Q=EMX/(1000.*PARADO(2,IPSWDO))
            Q=EMX/PARADA(2,J_PSW)
C           SCALDS(IAREDO,MSWIDS)=Q
            Q=0.001*Q
C            IF(PARADO(4,IPSWDO).GT.0.) THEN
C              Q=0.001*EMX/PARADO(2,IPSWDO)
C            ELSE
C              Q=0.001*EMX/EMAX
C              PARADO(2,IPSWDO)=EMAX
C            END IF
          END IF
          DO 4 K=1,JBIN
            EWIR(K)=EWIR(K)*Q
    4     CONTINUE
          IF(HIMXDU.EQ.1.) THEN
            DO 14 K=1,JBIN
              EWIR(K)=MIN(EMX,EWIR(K))
   14       CONTINUE
          END IF
          H=RO(MS)*COSD(FI)
          V=RO(MS)*SIND(FI)
C          IF(FPRSDP) CALL DPERS(H,V)
          IF(FIWE.NE.9999.) THEN
            FFI=FI-FIWE
          ELSE
            FFI=0.
          END IF
          CALL DQHI2(H,V,EWIR,JBIN,BW,FFI,TS(MS))
    1   CONTINUE
        FI=FI-350.
  111 CONTINUE
      CALL DQLEVL(ICTXDD)
      PSW=ABS(PARADA(2,J_PSW))
      T3=DT3(PSW)
      CALL DQSCE(T3//'Gev EW',9,EMX)
      SCALDS(IAREDO,MSWIDS)=EMX/PSW
      END
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYXWE_PICK
CH
      SUBROUTINE DYXWE_PICK(MD)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
      INCLUDE 'DALI_CF.INC'
      DIMENSION WIR(45)
      CALL DVEW(MD,NWIR,WIR)
      SW=0.
      EM=0.
      DO N=1,NWIR
        SW=SW+WIR(N)
        EM=MAX(EM,WIR(N))
      END DO
      SW=SW*0.001
      EM=EM*0.001
      WRITE(TXTADW,1000) MD,SW,EM
 1000 FORMAT('wire modul',I3,' sum =',F6.3,' GeV max =',F6.3,' GeV')
      CALL DWRC
      END
*DK DYZ1TR
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYZ1TR
CH
      SUBROUTINE DYZ1TR(SA,CA)
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
      EXTERNAL DYZDIS
      DATA IPDEB/0/
      LOGICAL FBAR(2),FOUT
      LOGICAL DCCTR
      DIMENSION FFRTO(7)
C                VX VD IT T0 T3 E1 E3
      DATA FFRTO/0.,0.,3.,4.,5.,6.,7./
      IF(MODEDT.NE.2) THEN
         CALL=DHELX0(FFRTO(2),FFRTO(3),FFRTO(4),FFRTO(6),FBAR)
      ELSE
         FFRTO(2)=0.
         CALL=DHELX1(FFRTO(3),FFRTO(4),FFRTO(6),FBAR,FOUT)
         IF(FOUT) RETURN
      END IF
      IF(DCCTR(FFRTO(4),FFRTO(5))) RETURN
      IHTFR=MIN(IHTRDO(3),7)
      IHTTO=MIN(IHTRDO(4),7)
      IF(IHTFR.GE.IHTTO) RETURN
      F1=FFRTO(IHTFR)
      H1=DHELIX(F1,IVZZDV)
      V1=-SA*DHELIX(F1,IVXXDV)+CA*DHELIX(F1,IVYYDV)
      F2=FFRTO(IHTTO)
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_PTO'
      CALL DPARAM(11
     &  ,J_PTO)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      IF(PARADA(2,J_PTO).GE.1001.AND.
     &  PARADA(2,J_PTO).LE.1004.) THEN
         F2=MIN(F2,FFRTO(5))
      ELSE
         IF(FBAR(1)) THEN
            F2=MIN(F2,FFRTO(5))
         END IF
      END IF
      IF(F1.GE.F2) RETURN
      IF(FPIKDP.AND.IPDEB.EQ.1) THEN
        CALL DYZPIT(F1,F2,SA,CA)
      ELSE
        H2=DHELIX(F2,IVZZDV)
        V2=-SA*DHELIX(F2,IVXXDV)+CA*DHELIX(F2,IVYYDV)
        CALL DYZDS0(SA,CA)
        CALL DDRAWA(DYZDIS,F1,H1,V1,F2,H2,V2)
      END IF
      END
*DK DYZD
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYZD
CH
      SUBROUTINE DYZD
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
      INCLUDE 'DALI_EX.INC'
      LOGICAL FEMTY
      DATA E0/225./
      DIMENSION SCA(4)
      DIMENSION HRB(4),VRB(4)
      CHARACTER *2 TY
      PARAMETER (TY ='Y'//(''''))

      CHARACTER *3 DT3,TFY
      CHARACTER *24 TSUB
C                123456789 123456789 1234
      DATA TSUB/'Y"=cos(120)*Y-sin(120)*X'/

      CALL DQCL(IAREDO)
      CALL DQWIL(MOD(DFWIDU(IZOMDO),10.))
      CALL DDRFLG
      IF(FNOPDR) GO TO 99
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_PFY,J_PFR,J_PTO,J_PGA'
      CALL DPARAM(10
     &  ,J_PFY,J_PFR,J_PTO,J_PGA)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      RFR=PARADA(2,J_PFR)
      RTO=PARADA(2,J_PTO)
      CALL DGRBST(HRB,VRB,FEMTY)
      IF(FEMTY) THEN
        IF(IZOMDO.EQ.0) THEN
          CALL DQRER(0,-RTO,-RTO,RTO,RTO,HRB,VRB)
        ELSE
C                                       calculate user area for zooming
          CALL DYZRCB(HRB,VRB)
        END IF
      END IF
      CALL DQRU(HRB,VRB)
      SA=SIND(PARADA(2,J_PFY))
      CA=COSD(PARADA(2,J_PFY))
      FZTRDT=.TRUE.
      CALL DHTINP
      IF(IHTRDO(1).NE.1.OR.
     &   PARADA(2,J_PTO).GT.E0.OR.IHTRDO(6).NE.1)
     &   PARADA(4,J_PGA)=-1.
      CALL DCTYP0(1)
      CALL DODTPC(' YZ')
      CALL DODECA(' YZ','endcap')
      CALL DODHCA(' YZ','endcap')
      CALL DODMUD(' YZ','ENDCAP',0)
      CALL DQMID
      CALL DAPEF('YZ')
      CALL DQSC0('2 SC')
      IF(IHTRDO(1).EQ.0) THEN
         CALL DYZET1(SA,CA,SP)
         CALL DQFR(IAREDO)
         RETURN
      END IF
      IF(IHTRDO(1).GE.2.AND.IHTRDO(1).LT.6) THEN
         IF(IHTRDO(2).EQ.1) THEN
            CALL DYZTT(SA,CA,SP)
C        ELSE IF(IHTRDO(2).GE.4) THEN
C           CALL D_AP_KALMAN_TR
         ELSE
           CALL DAP_TR
C          ........................ draw V0 tracks
           CALL DAP_V0_TR('YZ')
C          ........................ draw tracks calculated in VX
           CALL DAPTN('YZ')
         END IF
      END IF
      IF(IHTRDO(1).LE.2) THEN
        IF(IHTRDO(6).LE.1) THEN
          CALL DAPPT('YZ',DVTP,TPCODB,0)
        ELSE IF(IHTRDO(6).EQ.2) THEN
          CALL DAPPT('YZ',DVPADA,TPADDB,0)
        ELSE IF(IHTRDO(6).EQ.3) THEN
          CALL DAPPT('YZ',DVTP,TBCODB,0)
        END IF
      END IF
      CALL DAPVX('YZ',LDUM)
      CALL DAP_KNV('YZ',LDUM)
      IF(PARADA(2,J_PTO).GE.1005..OR.PARADA(2,J_PTO).LT.1000.) THEN
         CALL DAPEO('YZ')
         CALL DAPPE('YZ')
      END IF
      IF(PARADA(2,J_PTO).GE.1008..OR.PARADA(2,J_PTO).LT.1000.) THEN
         CALL DYZPH(SA,CA,SP)
         CALL DYZTH(SA,CA,SP)
      END IF
      IF(PARADA(2,J_PTO).GE.1010..OR.PARADA(2,J_PTO).LT.1000.) THEN
         CALL=DVMDCU(2.)
         CALL DAPPT('YZ',DVMD,MHITDB,0)
      END IF
      CALL DAPTRF('YZ')
      IF(FPIKDP) RETURN
      IF(PARADA(2,J_PTO).LT.1005.) THEN
         CALL DLSITX(MTPCDL)
      ELSE IF(PARADA(2,J_PTO).LT.1008.) THEN
         CALL DLSITX(MECADL)
      ELSE
         CALL DLSITX(MHCADL)
      END IF

      TFY=DT3(PARADA(2,J_PFY))
      TSUB( 1: 2)=TY
      TSUB( 8:10)=TFY
      TSUB(19:21)=TFY
      CALL DCTYEX(TSUB,24)

      IF(FEMTY) THEN
        CALL DQSCA('H',HRB(1),HRB(2),'cm',2,'Z',1)
        CALL DQSCA('V',VRB(2),VRB(3),'cm',2,TY,2)
      ELSE
        CALL DGRBSC(HRB,VRB,SCA,HDUM,VDUM,PDUM)
        CALL DQSCA('H',SCA(1),SCA(2),'cm',2,' ',0)
        CALL DQSCA('V',SCA(3),SCA(4),'cm',2,' ',0)
      END IF
99    CALL DQFR(IAREDO)
      CALL DPCSAR
      RETURN
      END
*DK DYZDIS
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYZDIS
CH
      SUBROUTINE DYZDIS(F1,H1,V1,F2,H2,V2,FM,HM,VM,D,FC)
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
      LOGICAL FC
      IF(FC) THEN
         FKTRDP=FM
         CALL DQL2EP(H1,V1,HM,VM)
         CALL DQL2EP(HM,VM,H2,V2)
         RETURN
      END IF
      FM=0.5*(F1+F2)
      HM=DHELIX(FM,IVZZDV)
      VM=-SA*DHELIX(FM,IVXXDV)+CA*DHELIX(FM,IVYYDV)
      DHU=H2-H1
      DVU=V2-V1
      DH21=AHSCDQ*DHU+BHSCDQ*DVU
      DV21=AVSCDQ*DHU+BVSCDQ*DVU
      DHU=HM-H1
      DVU=VM-V1
      DHM1=AHSCDQ*DHU+BHSCDQ*DVU
      DVM1=AVSCDQ*DHU+BVSCDQ*DVU
      DM=(DV21*DHM1-DH21*DVM1)**2/(DV21**2+DH21**2)
      IF(D.LT.DMAXDQ.AND.DM.LT.DMAXDQ) THEN
         FKTRDP=FM
         CALL DQL2EP(H1,V1,H2,V2)
         FC=.FALSE.
      ELSE
         FC=.TRUE.
         D=DM
      END IF
      RETURN
CH..............---
CH
CH
CH
CH
CH
CH
CH --------------------------------------------------------------------  DYZDS0
CH
      ENTRY DYZDS0(SS,CC)
CH
CH --------------------------------------------------------------------
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
      SA=SS
      CA=CC
      END
*DK DYZET1
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYZET1
CH
      SUBROUTINE DYZET1(SA,CA,SP)
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
      MODEDT=1
      CALL DCIRCL
      CALL DQLEVL(LCNCDD)
      CALL DVXT(0,XYZVDT)
      CALL DYZ1TR(SA,CA)
      END
*DK DYZETA
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYZETA
CH
      SUBROUTINE DYZETA(SA,CA,SP)
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
      DATA W2/2./
      LOGICAL FOUT,DVM0
      LOGICAL DCCVX
      EXTERNAL DVTR0
      CALL DAPTRN('YZ',0)
      CALL DSCTR
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_PTE'
      CALL DPARAM(11
     &  ,J_PTE)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      IF(IHTRDO(2).LE.2) THEN
         CALL DV0(FRFTDB,NUM1,NUM2,FOUT)
         IF(FOUT) RETURN
         MODEDT=1
         IF(.NOT.FPIKDP.AND.PDCODD(4,NFTRDD).GT.0.) THEN
           CALL DQLEVL(NFTRDD)
           DLINDD=DLINDD+W2
           DO 301 N=NUM1,NUM2
             IF(FNOTDT(N)) GO TO 301
             CALL DVTRV(N)
             CALL DVXT(N,XYZVDT)
             CALL DYZ1TR(SA,CA)
  301      CONTINUE
           DLINDD=DLINDD-W2
         END IF
         DO 1 N=NUM1,NUM2
           IF(FNOTDT(N)) GO TO 1
           IF(FVTRDC) CALL DGLEVL(NCTRDC(N))
           CALL DVTRV(N)
           CALL DVXT(N,XYZVDT)
           CALL DYZ1TR(SA,CA)
           CALL DAPTRN('YZ',N)
    1    CONTINUE
      ELSE
         CALL DQLEVL(LCNCDD)
         MODEDT=2
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
               CALL DYZ1TR(SA,CA)
   11       CONTINUE
   12    CONTINUE
         IF(.NOT.FPIKDP) THEN
            IF(NVTX1.LE.0) RETURN
            CALL DPAR_SET_CO(49,'CMC')
            IF(ICOLDP.LT.0) RETURN
            CALL DPARGV(67,'SSY',2,SYMB)
            CALL DPARGV(67,'SSZ',2,SYSZ)
            MSYMB=SYMB
            CALL DQPD0(MSYMB,SZVXDT*BOXSDU*SYSZ,0.)
C//         DS=SZVXDT*BOXSDU*WDSNDL(2,4,MTPCDL)
C//         CALL DQPD0(3,DS,0.)
C           CALL DGLEVL(NCVXDT)
            DO 13 N=1,NVTX1
               IF(FMVXDT(N)) THEN
                  CALL DVMCVX(N,KDUM1,KDUM2,KDUM3,VTX1DT)
                  IF(DCCVX(VTX1DT)) GO TO 13
                  H=VTX1DT(3)
                  V=-SA*VTX1DT(1)+CA*VTX1DT(2)
                  TE=DVCORD(VTX1DT,IVTEDV)
C                  IF(SP.NE.0.) THEN
C                     Q=1.+SP*(TE-TEMID)
C                     H=H*Q
C                     V=V*Q
C                  END IF
                  CALL DQPD(H,V)
               END IF
   13       CONTINUE
         END IF
      END IF
      END
*DK DYZRBC
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYZRBC
CH
      SUBROUTINE DYZRCB(HRB,VRB)
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
      DIMENSION HRB(4),VRB(4)
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_PTE,J_PFR,J_PTO,J_PAS,J_PBM,J_RDY'
      CALL DPARAM(10
     &  ,J_PTE,J_PFR,J_PTO,J_PAS,J_PBM,J_RDY)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      IF(PARADA(2,J_PTE).LE.90.) THEN
        HRB(1)=PARADA(2,J_PFR)
        HRB(2)=PARADA(2,J_PTO)
      ELSE
        IF(PARADA(2,J_PBM).EQ.2.) THEN
          HRB(1)=-PARADA(2,J_PFR)
          HRB(2)=-PARADA(2,J_PTO)
        ELSE
          HRB(1)=-PARADA(2,J_PTO)
          HRB(2)=-PARADA(2,J_PFR)
        END IF
      END IF
      HRB(3)=HRB(2)
      HRB(4)=HRB(1)
      DV=0.5*ABS(HRB(3)-HRB(1))
      IF(PARADA(2,J_PBM).NE.3.) DV=DV/PARADA(2,J_PAS)
      VRB(1)=PARADA(2,J_RDY)-DV
      VRB(2)=VRB(1)
      VRB(3)=PARADA(2,J_RDY)+DV
      VRB(4)=VRB(3)
      END
*DK DYZPH
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYZPH
CH
      SUBROUTINE DYZPH(SA,CA,SP)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C_CG 11-May-1989   C.Grab  Adapted to CERNVM
C
C!:
C    Inputs    :
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      DIMENSION HL(2),VL(2)
      EQUIVALENCE (KPIKDP,K)
      DATA SHRNK /.8/
      LOGICAL FOUT
      EXTERNAL DVHC
C_CG
      CALL DSCHC
      CALL DV0(HSDADB,NUM1,NUM2,FOUT)
      IF(FOUT) RETURN
C      CALL DORCAL
      CALL DCUTFT(FS1,FS2,FC1,FC2,TS1,TS2,TC1,TC2)
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_PFY,J_PTE'
      CALL DPARAM(11
     &  ,J_PFY,J_PTE)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      FIMID=PARADA(2,J_PFY)
      TEMID=PARADA(2,J_PTE)
      QPI=SHRNK/PIFCDK
      DO 1 K=NUM1,NUM2
         IF(FPIMDP.AND.K.NE.NPIKDP) GO TO 1
         CALL DCUTHC(K,FOUT)
         IF(FOUT) GO TO 1
         TE=DVHC(IVTEDV,K)
         IF(TE.LT.TC1.OR.TE.GT.TC2) GO TO 1
         FI=DFINXT(FIMID,DVHC(IVFIDV,K))
         IF(FI.LT.FC1.OR.FI.GT.FC2) GO TO 1
         IF(FVHCDC) CALL DGLEVL(NCHCDC(K))
         NN=DVHC(IVNNDV,K)
         IF(NN.EQ.2) GO TO 1
         H=DVHC(IVZZDV,K)
         V=-SA*DVHC(IVXXDV,K)+CA*DVHC(IVYYDV,K)
C         IF(SP.NE.0.) THEN
C            Q=1.+SP*(TE-TEMID)
C            H=H*Q
C            V=V*Q
C         END IF
         IF(FPIKDP) THEN
            CALL DQPIK(H,V)
         ELSE
            D=DVHC(IVRODV,K)*DVHC(IVDFDV,K)*QPI
            HL(1)=H
            HL(2)=H
            VL(1)=V-D
            VL(2)=V+D
            CALL DQLIE(HL,VL)
         END IF
    1 CONTINUE
      RETURN
      END
*DK DYZPIT
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYZPIT
CH
      SUBROUTINE DYZPIT(F1,F2,SA,CA)
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
C      DATA FP/20./,KP/20/
C      DF=(F2-F1)/FP
C      F=F1
C      DO 700 K=1,KP
C        F=F+DF
      DF=F2-F1
      DO 700 K=1,MTRSDP
        F=F1+TRSTDP(K)*DF
        H=DHELIX(F,IVZZDV)
        V=-SA*DHELIX(F,IVXXDV)+CA*DHELIX(F,IVYYDV)
        CALL DQPIK(H,V)
  700 CONTINUE
      END
*DK DY2TH
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYZTH
CH
      SUBROUTINE DYZTH(SA,CA,SP)
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------
C
C    Created by H.Drevermann                   28-JUL-1988
C
C    Inputs    :
C    Outputs   :
C
C    Called by :
C ---------------------------------------------------------------------
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_SSZ,J_SFR'
      CALL DPARAM(64
     &  ,J_SSZ,J_SFR)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      IF(.NOT.FPIKDP.AND.
     &  PDCODD(4,NFHTDD).GT.0.)THEN
        PCN2=PDCODD(2,ICCNDD)
        PCN4=PDCODD(4,ICCNDD)
        PDCODD(2,ICCNDD)=PDCODD(2,NFHTDD)
        PDCODD(4,ICCNDD)=1.
        WHC=PARADA(2,J_SSZ)
        PARADA(2,J_SSZ)=WHC+PARADA(2,J_SFR)
        CALL DYZTH1
        PDCODD(2,ICCNDD)=PCN2
        PDCODD(4,ICCNDD)=PCN4
        PARADA(2,J_SSZ)=WHC
      END IF
      CALL DYZTH1(SA,CA,SP)
      END
*DK DYZTH1
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYZTH1
CH
      SUBROUTINE DYZTH1(SA,CA,SP)
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
      EQUIVALENCE (KPIKDP,K)
      DATA BPTCH/1.025/
      DATA EPTCH/1.031/,EDROW/7.2/,EROW1/321.1/
      LOGICAL FOUT
      CALL DV0(HTUBDB,NUM1,NUM2,FOUT)
      IF(FOUT) RETURN
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_PFY,J_PTE'
      CALL DPARAM(11
     &  ,J_PFY,J_PTE)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      PHI=PARADA(2,J_PFY)
      PHM=MOD(PHI,180.)
      IF(PHM.NE.0..AND.PHM.NE.60..AND.PHM.NE.120.)RETURN
      IPHM=1+IFIX(PHM)/60
      CALL DQLEVH(LCHTDD(IPHM))
      CALL DPAR_SET_SY(64,0.)
      BP2=BPTCH/2.
C
C LOOP ON CLUSTERS
C
      DO 1 K=NUM1,NUM2
         ISBC=DVHT(13,K)
         ICASE=0
         IF(ISBC.EQ.2)GO TO 1
         IF(PHM.EQ.0.)GO TO 111
         ICASE=1
         IF(ISBC.EQ.1)THEN
            IF(PHM.NE.60.)GO TO 1
         ELSE
            IF(PHM.NE.120.)GO TO 1
         END IF
  111    IMN=DVHT(12,K)
         IF(ICASE.EQ.1)THEN
            IF(IMN.NE.2.AND.IMN.NE.5)GO TO 1
         ELSE
            IF(IMN.EQ.2.OR.IMN.EQ.5)GO TO 1
         END IF
         IF(IMN.EQ.2.OR.IMN.EQ.1.OR.IMN.EQ.3) THEN
            ISGN=1
         ELSE
            ISGN=-1
         END IF
         IF(PHI.EQ.240..OR.PHI.EQ.120..OR.PHI.EQ.180.)ISGN=-ISGN
         IF(PARADU(44).NE.0.) THEN
           IF(PARADA(2,J_PTE).GT.90..AND.IZOMDO.EQ.1)ISGN=-ISGN
         END IF
         H=EROW1+(DVHT(11,K)-1.)*EDROW
         IF(ISBC.EQ.3)H=-H
         Y0=DVHT(1,K)*ISGN
C
C        KKMAX = INT((DVHT(10,K)+.0001)/1.025)
C        Modified 24.11.95 by Venturi         
C
C LOOP ON HITS IN CLUSTER
C
C         DO 10 KK = -KKMAX/2,KKMAX/2
C
         KKMAX=DVHT(10,K)
         IF(MOD(KKMAX,2).EQ.0) THEN
           V=Y0-EPTCH* KKMAX   /2+BP2
         ELSE
           V=Y0-EPTCH*(KKMAX-1)/2
         END IF
C
C LOOP ON HITS IN CLUSTER
C
         DO KK=1,KKMAX
           IF(FPIKDP) THEN
             CALL DQPIK(H,V)
           ELSE
             CALL DQPD(H,V)
           END IF
           V=V+BPTCH
         END DO
    1 CONTINUE
      RETURN
      END
*DK DYZTT
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DYZTT
CH
      SUBROUTINE DYZTT(SA,CA,SP)
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
      DIMENSION H(2),V(2)
      EQUIVALENCE (K,KPIKDP)
      LOGICAL FOUT
      CALL DSCTR
      CALL DV0(FRTLDB,NUM1,NTRK,FOUT)
      IF(FOUT) RETURN
      CALL DV0(TPCODB,NUM0,NUM2,FOUT)
      IF(FOUT) RETURN
C     CALL DVTQ0(NUM2)
C     IF(NUM2.EQ.0) RETURN
      CALL DCUTFT(FP1,FP2,FC1,FC2,TP1,TP2,TC1,TC2)
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_PFY,J_PTE'
      CALL DPARAM(11
     &  ,J_PFY,J_PTE)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      FIMID=PARADA(2,J_PFY)
      TEMID=PARADA(2,J_PTE)
      DO 3 M=1,NTRK
         IF(FCUTDT) THEN
            IF(FNOTDT(M)) GO TO 3
         END IF
         CALL=DVCHT(M,NUM)
         IF(NUM.LE.0) RETURN
         IF(FVTRDC) CALL DGLEVL(NCTRDC(M))
C         CALL DLCOLT(M,NCOL)
C         IF(NCOL.EQ.0) GO TO 3
C         IF(ICOL.NE.0) CALL DGLEVL(ICOL)
         I=0
    2    DO 1 KIND=1,NUM
            K=IDVCHT(KIND)
            IF(FPIMDP.AND.K.NE.NPIKDP) GO TO 1
            TE=DVTP(IVTEDV,K)
            IF(TE.LT.TC1.OR.TE.GT.TC2) THEN
               I=0
               GO TO 1
            END IF
            FI=DFINXT(FIMID,DVTP(IVFIDV,K))
            IF(FI.LT.FC1.OR.FI.GT.FC2) THEN
               I=0
               GO TO 1
            END IF
            I=I+1
            H(I)=DVTP(IVZZDV,K)
            V(I)=-SA*DVTP(IVXXDV,K)+CA*DVTP(IVYYDV,K)
C            IF(SP.NE.0.) THEN
C               Q=1.+SP*(TE-TEMID)
C               H(I)=H(I)*Q
C               V(I)=V(I)*Q
C            END IF
            IF(FPIKDP) THEN
               CALL DQPIK(H,V)
               I=0
            ELSE IF(I.EQ.2) THEN
               CALL DQLIE(H,V)
               I=1
               H(1)=H(2)
               V(1)=V(2)
            END IF
    1    CONTINUE
    3 CONTINUE
      END
