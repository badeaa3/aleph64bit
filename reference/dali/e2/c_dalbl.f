Cc DQPD1 => DPAR_SET_SY
*DK DLSITX
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DLSITX
CH
      SUBROUTINE DLSITX(NDEV)
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
      END
*DK DLTAWP
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DLTAWP
CH
      SUBROUTINE DLTAWP(K, ITRK,ZFIT,DZ)
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
C     ----------------------------------
C
C       LT:Assign Wire to Pads
C! Associate a given wire hit (K) with a pad track (ITRK).
C!
C! INPUT :  K      = Wire hit
C! OUTPUT:  ITRK   = Label of matched laser track (pad).
C!                 = 0 if match is beyond the tolerance DZMAX.
C!          ZFIT   = Fitted Z coordinate on track.
C!          DZ     = Z residual.
C
      COMMON /DLSTRC/
     &  AXYFDL(30),BXYFDL(30),CXYFDL(30),
     &  AZRFDL(30),BZRFDL(30),CZRFDL(30),
     &  FILADL(30),TELADL(30),
     &  NTRKDL(3,0:9),
     &  NSTRDL, NWIRDL(3),WIRRDL(6000),WIRZDL(6000),WIREDL(6000)
      COMMON /DLSTRT/TTRKDL(0:30)
      CHARACTER *2 TTRKDL
      DATA DZMAX / 10. /
C
C++   Loop over laser tracks and find track which gives the smallest
C++   residual.
C
      DZOLD = 999.
      IOLD = 0
      DO 100 I=1,5
         DZ = ABS( WIRZDL(K) - (AZRFDL(I)*WIRRDL(K)+BZRFDL(I)) )
         IF(DZ.GE.DZOLD) GOTO 100
         IF(DZ.GT.DZMAX) GOTO 100
         DZOLD = DZ
         IOLD = I
  100 CONTINUE
C
      ITRK = IOLD
      IF(ITRK.EQ.0)  RETURN
      ZFIT = AZRFDL(ITRK)*WIRRDL(K) + BZRFDL(ITRK)
      DZ = WIRZDL(K) - ZFIT
C
      RETURN
      END
*DK DLTD
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DLTD
CH
      SUBROUTINE DLTD
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
C     ---------------------
C
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      INCLUDE 'DALI_EX.INC'
      COMMON /DLSTRC/
     &  AXYFDL(30),BXYFDL(30),CXYFDL(30),
     &  AZRFDL(30),BZRFDL(30),CZRFDL(30),
     &  FILADL(30),TELADL(30),
     &  NTRKDL(3,0:9),
     &  NSTRDL, NWIRDL(3),WIRRDL(6000),WIRZDL(6000),WIREDL(6000)
      COMMON /DLSTRT/TTRKDL(0:30)
      CHARACTER *2 TTRKDL
      CHARACTER *3 DT3
      CHARACTER *30 TXT
      DATA ZMAX/250./,RMIN/20./,RMAX/190./
      DATA ZMATP/220./,RMITP/31.64/,RMATP/177.9/
      DATA RO1/30./,RO2/180./
      LOGICAL FOUT
      DIMENSION HRB(4),VRB(4),HH(2),VV(2)
      CHARACTER *3 TFOP(3)
      DATA TFOP/' 90','210','330'/
      CALL DQCL(IAREDO)
      CALL DQWIL(11.)
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_LDS,J_LDL,J_LNT,J_LDI,J_LFI'
      CALL DPARAM(34
     &  ,J_LDS,J_LDL,J_LNT,J_LDI,J_LFI)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      NDIR=PARADA(2,J_LDI)
C         '    D=dY''                D=dZ',30)
C         '    Z+123*dY'' phi=123'
C          123456789 123456789 123456789
      TXT='               phi=123'
      TXT(20:22)=TFOP(JFI)
      IF(NDIR.LE.3) THEN
        IF(NDIR.NE.2) THEN
C                                                       DY
          IF(NDIR.EQ.3) CALL DLTRUH(1,0.5)
          CALL DV0(TPCODB,NUM1,NUM2,FOUT)
          IF(FOUT) GO TO 98
          CALL=DVCHT0(NTRK)
          IF(NTRK.EQ.0) GO TO 98
          IF(PARADA(4,J_LNT).EQ.1.) THEN
            NTRK=PARADA(2,J_LNT)
            CALL=DVCHT(NTRK,NUM)
            IF(NUM.LE.1) GO TO 98
            CALL DLTDY(NTRK,NUM)
          ELSE
            JFI=PARADA(2,J_LFI)
            IF(PARADA(4,J_LFI).GE.0.) THEN
              IT=5
            ELSE
              IT=0
            END IF
            DO 710 I=1,5
              NTRK=NTRKDL(JFI,IT)
              IT=IT+1
              IF(NTRK.EQ.0) GO TO 710
              CALL=DVCHT(NTRK,NUM)
              IF(NUM.LE.1) GO TO 98
              CALL DLTRUV(I,0.2)
              CALL DLTDY(NTRK,NUM)
  710       CONTINUE
            CALL DLTRUV(0,0.)
          END IF
          CALL DQSCA('H',RO1,RO2,'cm',2,'&r',1)
        END IF
        IF(NDIR.NE.1) THEN
C                                                       DZ
          IF(NDIR.EQ.3) CALL DLTRUH(2,0.5)
          CALL DV0(TPCODB,NUM1,NUM2,FOUT)
          IF(FOUT) GO TO 98
          CALL=DVCHT0(NTRK)
          IF(NTRK.EQ.0) GO TO 98
          IF(PARADA(4,J_LNT).EQ.1.) THEN
            NTRK=PARADA(2,J_LNT)
            CALL=DVCHT(NTRK,NUM)
            IF(NUM.LE.1) GO TO 98
            CALL DLTDZ(NTRK,NUM)
          ELSE
            JFI=PARADA(2,J_LFI)
            IF(PARADA(4,J_LFI).GE.0.) THEN
              IT=5
            ELSE
              IT=0
            END IF
            DO 720 I=1,5
              NTRK=NTRKDL(JFI,IT)
              IT=IT+1
              IF(NTRK.EQ.0) GO TO 720
              CALL=DVCHT(NTRK,NUM)
              IF(NUM.LE.1) GO TO 720
              CALL DLTRUV(I,0.2)
              CALL DLTDZ(NTRK,NUM)
  720       CONTINUE
            CALL DLTRUV(0,0.)
          END IF
          CALL DQSCA('H',RO1,RO2,'cm',2,'&r',1)
        END IF
        CALL DLTRUH(0,0.)
        DL=PARADA(2,J_LDL)*10.
        IF(NDIR.EQ.1) then
          CALL DQSCA('V',0.,DL,'cm',2,'dY''',4)
        ELSE IF(NDIR.EQ.2) THEN
          CALL DQSCA('V',0.,DL,'cm',2,'dZ',2)
        ELSE
          HH(1)=0.5*(HLOWDG(IAREDO)+HHGHDG(IAREDO))
          HH(2)=HH(1)
          VV(1)=VLOWDG(IAREDO)
          VV(2)=VHGHDG(IAREDO)
          CALL DQLEVL(ICFRDD)
          CALL DGDRAW(2,HH,VV)
          CALL DQSCA('V',0.,DL,'cm',2,'D',1)
        END IF
        IF(NDIR.EQ.1) THEN
          CALL DCTYEX('LT '//TXT,25)
        ELSE IF(NDIR.EQ.2) THEN
          CALL DCTYEX('LT '//TXT,25)
        ELSE IF(NDIR.EQ.3) THEN
          TXT( 5:10)='D=dY'''
          TXT(27:30)='D=dZ'
          CALL DCTYEX('LT '//TXT,33)
        END IF
      ELSE IF(NDIR.LE.8) THEN
C                                                       RY,RZ
        CALL DV0(TPCODB,NUM1,NUM2,FOUT)
        IF(FOUT) GO TO 98
        CALL=DVCHT0(NTRK)
        IF(NTRK.EQ.0) GO TO 98
        CALL DQRER(0,-ZMAX,RMIN,ZMAX,RMAX,HRB,VRB)
        CALL DQRU(HRB,VRB)
        IF(PARADA(4,J_LNT).EQ.1.) THEN
          NTRK=PARADA(2,J_LNT)
          CALL=DVCHT(NTRK,NUM)
          IF(NUM.LE.1) GO TO 98
          IF(NDIR.EQ.4) THEN
            CALL DLTRY(NTRK,NUM,ZMAX)
          ELSE
            CALL DLTRZ(NTRK,NUM,ZMAX)
          END IF
        ELSE
          JFI=PARADA(2,J_LFI)
          DO 730 I=0,9
            NTRK=NTRKDL(JFI,I)
            IF(NTRK.EQ.0) GO TO 730
            CALL=DVCHT(NTRK,NUM)
            IF(NUM.LE.1) GO TO 730
            IF(NDIR.EQ.4) THEN
              CALL DLTRY(NTRK,NUM,ZMAX)
            ELSE
              CALL DLTRZ(NTRK,NUM,ZMAX)
            END IF
  730     CONTINUE
        END IF
        IF(FPIKDP) GO TO 98
        CALL DGLEVL(4)
        CALL DQREC(-ZMATP,RMITP,ZMATP,RMATP)
        DZ=PARADA(2,J_LDS)
        CALL DQSCA('H',-DZ,DZ,'cm',2,'dZ',2)
        CALL DQSCA('V',VRB(2),VRB(3),'cm',2,'&r',1)
        TXT(5:12)='Z+123*dZ'
        TXT(7: 9)=DT3(ZMAX/PARADA(2,J_LDS))
        IF(NDIR.EQ.4) TXT(12:14)='Y'''
        CALL DCTYEX('LT '//TXT,25)
      END IF
   98 CALL DLTRUH(0,0.)
      CALL DQFR(IAREDO)
      END
*DK DLTDY
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DLTDY
CH
      SUBROUTINE DLTDY(ITRK,NUM,ZMAX)
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
C     ------------------------------------
C
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      INCLUDE 'DALI_EX.INC'
      COMMON /DLSTRC/
     &  AXYFDL(30),BXYFDL(30),CXYFDL(30),
     &  AZRFDL(30),BZRFDL(30),CZRFDL(30),
     &  FILADL(30),TELADL(30),
     &  NTRKDL(3,0:9),
     &  NSTRDL, NWIRDL(3),WIRRDL(6000),WIRZDL(6000),WIREDL(6000)
      COMMON /DLSTRT/TTRKDL(0:30)
      CHARACTER *2 TTRKDL
      DIMENSION X(21),Y(21),R(21),Z(21),
     &  H(21),V(21),KBOS(21)
      DIMENSION HH(2),V0(2),VV(2),HRB(4),VRB(4)
      DATA RO1/30./,RO2/180./
      CHARACTER *17 TXT
      CHARACTER *3 DT3
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_LDL,J_LNT'
      CALL DPARAM(34
     &  ,J_LDL,J_LNT)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      CALL DSCTP
      DO   700  KIND=1,NUM
         K=IDVCHT(KIND)
         X(KIND)=DVTP(IVXXDV,K)
         Y(KIND)=DVTP(IVYYDV,K)
         R(KIND)=DVTP(IVRODV,K)
         Z(KIND)=DVTP(IVZZDV,K)
         KBOS(KIND)=K
  700 CONTINUE
      DL=PARADA(2,J_LDL)
C         CALL LFIT(X,Y,NUM,1,AXY,BXY,CXY)
C      FI =MOD(3600.+DATN2D(AXYFDL(ITRK),1.)   ,360.)
C      FI1=MOD(3600.+DATN2D(Y(1),X(1)),360.)
C      IF(ABS(FI-FI1).GT.90.) FI = AMOD(FI+180.,360.)
      FI=FILADL(ITRK)
      SF=SIND(FI)
      CF=COSD(FI)
      X1=RO1*CF
      Y1=AXYFDL(ITRK)*X1+BXYFDL(ITRK)
      X2=RO2*CF
      Y2=AXYFDL(ITRK)*X2+BXYFDL(ITRK)
      CALL DQROT0(FI)
      CALL DQROT(X1,Y1,H1,V1)
      CALL DQROT(X2,Y2,H2,V2)
      DO   710  K=1,NUM
         CALL DQROT(X(K),Y(K),H(K),V(K))
         V(K)=V(K)-V1
  710 CONTINUE
      IF(H2.GT.H1) THEN
         HH(1)=H1
         HH(2)=H2
      ELSE
         HH(1)=H2
         HH(2)=H1
      END IF
      CALL DQRER(0,HH(1),-DL,HH(2),DL,HRB,VRB)
      CALL DQRU(HRB,VRB)
      IF(FPIKDP) THEN
         DO   720  K=1,NUM
            KPIKDP=KBOS(K)
            IF(FPIMDP.AND.KPIKDP.NE.NPIKDP) GO TO 720
            CALL DQPIK(H(K),V(K))
  720    CONTINUE
         RETURN
      END IF
      CALL DGLEVL(2)
      CALL DQLIE(HH,V0)
      CALL DGLEVL(5)
      DO   730  K=1,NUM-1
         CALL DQLIE(H(K),V(K))
  730 CONTINUE
      CALL DSCTP
      DO   740  K=1,NUM
C        CALL DLCOLH(DVTP,MTPCDL,KBOS(K),NCOL)
         IF(FVTPDC) CALL DGLEVL(NCTPDC(KBOS(K)))
         CALL DQL2E(H(K),0.,H(K),V(K))
  740 CONTINUE
      IFI=FI
      IF(PARADA(4,J_LNT).NE.1.) THEN
         HH(1)=HLOWDG(IAREDO)
         HH(2)=HHGHDG(IAREDO)
         VV(1)=VLOWDG(IAREDO)
         VV(2)=VLOWDG(IAREDO)
         CALL DQLEVL(ICFRDD)
         CALL DGDRAW(2,HH,VV)
         VV(1)=VHGHDG(IAREDO)
         VV(2)=VHGHDG(IAREDO)
         CALL DGDRAW(2,HH,VV)
      ELSE
C//      IF(MODEDL(MTPCDL,2).NE.1.OR.MSYMDL(MTPCDL,0).NE.1) THEN
C//         CALL DQPD0(MSYMDL(MTPCDL,0),WDSNDL(2,4,MTPCDL),0.)
            CALL DPAR_SET_SY(62,0.)         
            DO   750  K=1,NUM
C              CALL DLCOLH(DVTP,MTPCDL,KBOS(K),NCOL)
               IF(FVTPDC) CALL DGLEVL(NCTPDC(KBOS(K)))
               CALL DQPD(H(K),V(K))
  750       CONTINUE
C//      END IF
      END IF
C          123456789 1234567
      TXT='U1 te=123 rms=123'
      TXT( 1: 2)=TTRKDL(ITRK)
      TXT( 7: 9)=DT3(TELADL(ITRK))
      TXT(15:17)=DT3(CXYFDL(ITRK))
      CALL DQLEVL(ICTXDD)
      CALL DGTEXT(HLOWDG(IAREDO),VLOWDG(IAREDO),TXT,17)
      END
*DK DLTDZ
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DLTDZ
CH
      SUBROUTINE DLTDZ(ITRK,NUM,ZMAX)
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
C     ------------------------------------
C
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      INCLUDE 'DALI_EX.INC'
      COMMON /DLSTRC/
     &  AXYFDL(30),BXYFDL(30),CXYFDL(30),
     &  AZRFDL(30),BZRFDL(30),CZRFDL(30),
     &  FILADL(30),TELADL(30),
     &  NTRKDL(3,0:9),
     &  NSTRDL, NWIRDL(3),WIRRDL(6000),WIRZDL(6000),WIREDL(6000)
      COMMON /DLSTRT/TTRKDL(0:30)
      CHARACTER *2 TTRKDL
      DIMENSION X(21),Y(21),R(21),Z(21),KBOS(21)
      DIMENSION HH(2),VV(2),HRB(4),VRB(4)
      DATA RO1/30./,RO2/180./
      DATA CTTVDU/0./
      DATA HMID/0./
      CHARACTER *17 TXT
      CHARACTER *3 DT3
      DO   700  KIND=1,NUM
         K=IDVCHT(KIND)
         X(KIND)=DVTP(IVXXDV,K)
         Y(KIND)=DVTP(IVYYDV,K)
         R(KIND)=DVTP(IVRODV,K)
         Z(KIND)=DVTP(IVZZDV,K)
         KBOS(KIND)=K
  700 CONTINUE
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_LDL,J_LNT,J_LDI'
      CALL DPARAM(34
     &  ,J_LDL,J_LNT,J_LDI)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      DL=PARADA(2,J_LDL)
      CALL DQRER(0,RO1,-DL,RO2,DL,HRB,VRB)
      CALL DQRU(HRB,VRB)
C      CALL LFIT(R,Z,NUM,1,AZR,BZR,CZR)
C         TE=DATN2D(1.,AZR)
      TE=TELADL(ITRK)
      IF(FPIKDP) THEN
         DO   760  K=1,NUM
            KPIKDP=KBOS(K)
            IF(FPIMDP.AND.KPIKDP.NE.NPIKDP) GO TO 760
            DZ=Z(K) - ( AZRFDL(ITRK)*R(K)+BZRFDL(ITRK) )
            CALL DQPIK(R(K),DZ)
  760    CONTINUE
         RETURN
      END IF
      CALL DGLEVL(2)
      CALL DQL2E(RO1,0.,RO2,0.)
      CALL DGLEVL(5)
      DO   770  K=1,NUM-1
         VV(1)=Z(K  ) - ( AZRFDL(ITRK)*R(K  )+BZRFDL(ITRK) )
         VV(2)=Z(K+1) - ( AZRFDL(ITRK)*R(K+1)+BZRFDL(ITRK) )
         CALL DQLIE(R(K),VV)
  770 CONTINUE
      CALL DSCTP
      DO   780  K=1,NUM
         IF(FVTPDC) CALL DGLEVL(NCTPDC(KBOS(K)))
C        CALL DLCOLH(DVTP,MTPCDL,KBOS(K),NCOL)
         DZ=Z(K) - ( AZRFDL(ITRK)*R(K)+BZRFDL(ITRK) )
         CALL DQL2E(R(K),0.,R(K),DZ)
  780 CONTINUE
      ITE=TE
      IF(PARADA(4,J_LNT).NE.1.) THEN
         HH(1)=HLOWDG(IAREDO)
         HH(2)=HHGHDG(IAREDO)
         VV(1)=VLOWDG(IAREDO)
         VV(2)=VLOWDG(IAREDO)
         CALL DQLEVL(ICFRDD)
         CALL DGDRAW(2,HH,VV)
         VV(1)=VHGHDG(IAREDO)
         VV(2)=VHGHDG(IAREDO)
         CALL DGDRAW(2,HH,VV)
      ELSE
C//      IF(MODEDL(MTPCDL,2).NE.1.OR.MSYMDL(MTPCDL,0).NE.1) THEN
C//         CALL DQPD0(MSYMDL(MTPCDL,0),WDSNDL(2,4,MTPCDL),0.)
            CALL DPAR_SET_SY(62,0.)         
            DO   790  K=1,NUM
               IF(FVTPDC) CALL DGLEVL(NCTPDC(KBOS(K)))
C              CALL DLCOLH(DVTP,MTPCDL,KBOS(K),NCOL)
               DZ=Z(K) - ( AZRFDL(ITRK)*R(K)+BZRFDL(ITRK) )
               CALL DQPD(R(K),DZ)
  790       CONTINUE
C//      END IF
      END IF
C          123456789 1234567
      TXT='          rms=123'
      NDIR=PARADA(2,J_LDI)
      IF(NDIR.EQ.2) THEN
        TXT( 1: 2)=TTRKDL(ITRK)
        TXT( 7: 9)=DT3(TELADL(ITRK))
      END IF
      TXT(15:17)=DT3(CZRFDL(ITRK))
      CALL DGLEVL(IFIX(CTTVDU))
      CALL DGTEXT(HLOWDG(IAREDO),VLOWDG(IAREDO),TXT,17)
       IF(NDIR.EQ.3) THEN
         CALL DQLEVL(ICFRDD)
         HH(1)=HMID
         HH(2)=HMID
         VV(1)=VLOWDG(IAREDO)
         VV(2)=VHGHDG(IAREDO)
         CALL DGDRAW(2,HH,VV)
      END IF
      END
*DK DLTRUH
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DLTRUH
CH
      SUBROUTINE DLTRUH(NH,QH)
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
C     ------------------------------------
C
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      LOGICAL FSET
      DATA FSET /.FALSE./
      IF(FSET) THEN
        HHGHDG(IAREDO)=HHGH
        HLOWDG(IAREDO)=HLOW
      END IF
      IF(NH.EQ.0) THEN
        FSET=.FALSE.
      ELSE
        FSET=.TRUE.
        HHGH=HHGHDG(IAREDO)
        HLOW=HLOWDG(IAREDO)
        DH=(HHGHDG(IAREDO)-HLOWDG(IAREDO))*QH
        HLOWDG(IAREDO)=HLOW+FLOAT(NH-1)*DH
        HHGHDG(IAREDO)=HLOWDG(IAREDO)+DH
      END IF
      END
*DK DLTRUV
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DLTRUV
CH
      SUBROUTINE DLTRUV(NV,QV)
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
C     ------------------------------------
C
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      LOGICAL FSET
      DATA FSET /.FALSE./
      IF(FSET) THEN
        VHGHDG(IAREDO)=VHGH
        VLOWDG(IAREDO)=VLOW
      END IF
      IF(NV.EQ.0) THEN
        FSET=.FALSE.
      ELSE
        FSET=.TRUE.
        VHGH=VHGHDG(IAREDO)
        VLOW=VLOWDG(IAREDO)
        DV=(VHGHDG(IAREDO)-VLOWDG(IAREDO))*QV
        VHGHDG(IAREDO)=VHGH-FLOAT(NV-1)*DV
        VLOWDG(IAREDO)=VHGHDG(IAREDO)-DV
      END IF
      END
*DK DLTRY
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DLTRY
CH
      SUBROUTINE DLTRY(ITRK,NUM,ZMAX)
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
C     ------------------------------------
C
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      INCLUDE 'DALI_EX.INC'
      COMMON /DLSTRC/
     &  AXYFDL(30),BXYFDL(30),CXYFDL(30),
     &  AZRFDL(30),BZRFDL(30),CZRFDL(30),
     &  FILADL(30),TELADL(30),
     &  NTRKDL(3,0:9),
     &  NSTRDL, NWIRDL(3),WIRRDL(6000),WIRZDL(6000),WIREDL(6000)
      COMMON /DLSTRT/TTRKDL(0:30)
      CHARACTER *2 TTRKDL
      DIMENSION X(21),Y(21),R(21),Z(21),
     &  H(21),V(21),KBOS(21)
      DATA RO1/30./,RO2/180./,DZL/32./,CF/0./
      DO   700  KIND=1,NUM
         K=IDVCHT(KIND)
         X(KIND)=DVTP(IVXXDV,K)
         Y(KIND)=DVTP(IVYYDV,K)
         R(KIND)=DVTP(IVRODV,K)
         Z(KIND)=DVTP(IVZZDV,K)
         KBOS(KIND)=K
  700 CONTINUE
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_LDS,J_LDL'
      CALL DPARAM(34
     &  ,J_LDS,J_LDL)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      DL=PARADA(2,J_LDL)
      Q=ZMAX/PARADA(2,J_LDS)
C     CALL LFIT(R,Z,NUM,1,AZR,BZR,CZR)
      IF(FPIKDP) THEN
        DO 900  K=1,NUM
           KPIKDP=KBOS(K)
           IF(FPIMDP.AND.KPIKDP.NE.NPIKDP) GO TO 900
           CALL DQPIK(Z(K),R(K))
           DZ=(Z(K)-AZRFDL(ITRK)*R(K)-BZRFDL(ITRK))*Q
           CALL DQPIK(Z(K),R(K))
  900   CONTINUE
        RETURN
      END IF
      Z1=BZRFDL(ITRK)
      RR2=2.*RO2
      Z2=AZRFDL(ITRK)*RR2+BZRFDL(ITRK)
      CALL DGLEVL(4)
      CALL DQL2E(Z1,0.,Z2,RR2)
      RR2=RO2
      RR2=RO2
      Z2=AZRFDL(ITRK)*RR2+BZRFDL(ITRK)
      IF(Z2.LT.-ZMAX+DZL) THEN
        Z2=-ZMAX
        RR2=(Z2-BZRFDL(ITRK))/AZRFDL(ITRK)-DZL
      ELSE IF(Z2.GT.ZMAX-DZL) THEN
        Z2=ZMAX-DZL
        RR2=(Z2-BZRFDL(ITRK))/AZRFDL(ITRK)-DZL
      END IF
      CALL DGLEVL(8)
      CALL DQTXT(Z2,RR2,TTRKDL(ITRK),2)
C      CALL LFIT(X,Y,NUM,1,AXY,BXY,CXY)
C      FI =MOD(3600.+DATN2D(AXY,1.)   ,360.)
C      FI1=MOD(3600.+DATN2D(Y(1),X(1)),360.)
C      IF(ABS(FI-FI1).GT.90.) FI = AMOD(FI+180.,360.)
      FI=FILADL(ITRK)
      SF=SIND(FI)
      X1=RO1*CF
      Y1=AXYFDL(ITRK)*X1+BXYFDL(ITRK)
      CALL DQROT0(FI)
      CALL DQROT(X1,Y1,H1,V1)
      DO   910  K=1,NUM
         CALL DQROT(X(K),Y(K),H(K),V(K))
         V(K)=V(K)-V1
  910 CONTINUE
      CALL DSCTP
      DO   920  K=1,NUM
         ZZ=AZRFDL(ITRK)*R(K)+BZRFDL(ITRK)
         DZ=V(K)*Q
         IF(FVTPDC) CALL DGLEVL(NCTPDC(KBOS(K)))
C        CALL DLCOLH(DVTP,MTPCDL,KBOS(K),NCOL)
         CALL DQL2E(ZZ,R(K),ZZ+DZ,R(K))
  920 CONTINUE
      END
*DK DLTRZ
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DLTRZ
CH
      SUBROUTINE DLTRZ(ITRK,NUM,ZMAX)
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
C     ------------------------------------
C
*CA DALLCO
      INCLUDE 'DALI_CF.INC'
      INCLUDE 'DALI_EX.INC'
      COMMON /DLSTRC/
     &  AXYFDL(30),BXYFDL(30),CXYFDL(30),
     &  AZRFDL(30),BZRFDL(30),CZRFDL(30),
     &  FILADL(30),TELADL(30),
     &  NTRKDL(3,0:9),
     &  NSTRDL, NWIRDL(3),WIRRDL(6000),WIRZDL(6000),WIREDL(6000)
      COMMON /DLSTRT/TTRKDL(0:30)
      CHARACTER *2 TTRKDL
      DIMENSION X(21),Y(21),R(21),Z(21),
     &  H(21),V(21),KBOS(21)
      DATA RO2/180./,DZL/32./
      DO   700  KIND=1,NUM
         K=IDVCHT(KIND)
         X(KIND)=DVTP(IVXXDV,K)
         Y(KIND)=DVTP(IVYYDV,K)
         R(KIND)=DVTP(IVRODV,K)
         Z(KIND)=DVTP(IVZZDV,K)
         KBOS(KIND)=K
  700 CONTINUE
C     :::::::::::::::::::::::::::::::::::::::::::::::::::::::
      TPARDA=
     &  'J_LDS,J_LDL'
      CALL DPARAM(34
     &  ,J_LDS,J_LDL)
C     ::.::::::::::::::::::::::::::::::::::::::::::::::::::::
      DL=PARADA(2,J_LDL)
      Q=ZMAX/PARADA(2,J_LDS)
C      CALL LFIT(R,Z,NUM,1,AZR,BZR,CZR)
      IF(FPIKDP) THEN
         DO   800  K=1,NUM
            KPIKDP=KBOS(K)
            IF(FPIMDP.AND.KPIKDP.NE.NPIKDP) GO TO 800
            CALL DQPIK(Z(K),R(K))
            DZ=(Z(K)-AZRFDL(ITRK)*R(K)-BZRFDL(ITRK))*Q
            CALL DQPIK(Z(K)+DZ,R(K))
  800    CONTINUE
         RETURN
      END IF
      Z1=BZRFDL(ITRK)
      RR2=2.*RO2
      Z2=AZRFDL(ITRK)*RR2+BZRFDL(ITRK)
      CALL DGLEVL(4)
      CALL DQL2E(Z1,0.,Z2,RR2)
      RR2=RO2
      Z2=AZRFDL(ITRK)*RR2+BZRFDL(ITRK)
      IF(Z2.LT.-ZMAX+DZL) THEN
        Z2=-ZMAX
        RR2=(Z2-BZRFDL(ITRK))/AZRFDL(ITRK)-DZL
      ELSE IF(Z2.GT.ZMAX-DZL) THEN
        Z2=ZMAX-DZL
        RR2=(Z2-BZRFDL(ITRK))/AZRFDL(ITRK)-DZL
      END IF
      CALL DGLEVL(8)
      CALL DQTXT(Z2,RR2,TTRKDL(ITRK),2)
      CALL DSCTP
      DO   820  K=1,NUM
        ZZ=AZRFDL(ITRK)*R(K)+BZRFDL(ITRK)
        DZ=(Z(K)-ZZ)*Q
        IF(FVTPDC) CALL DGLEVL(NCTPDC(KBOS(K)))
C       CALL DLCOLH(DVTP,MTPCDL,KBOS(K),NCOL)
        CALL DQL2E(ZZ,R(K),ZZ+DZ,R(K))
  820 CONTINUE
C//   IF(MODEDL(MTPCDL,2).NE.1.OR.MSYMDL(MTPCDL,1).NE.1) THEN
C//     CALL DQPD0(MSYMDL(MTPCDL,0),WDSNDL(2,4,MTPCDL),0.)
        CALL DPAR_SET_SY(62,0.)         
        DO   830  K=1,NUM
           IF(FVTPDC) CALL DGLEVL(NCTPDC(KBOS(K)))
C          CALL DLCOLH(DVTP,MTPCDL,KBOS(K),NCOL)
           ZZ=AZRFDL(ITRK)*R(K)+BZRFDL(ITRK)
           CALL DQPD(H(K),V(K))
  830   CONTINUE
C//   END IF
      END
*DK DLUTIN
CH..............+++
CH
CH
CH
CH
CH
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  DLUTIN
CH
      SUBROUTINE DLUTIN
CH
CH ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CH
C ---------------------------------------------------------------------

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
C_CG      DATA MVDEDL/1/,MITCDL/2/,MTPCDL/3/,MECADL/4/,MHCADL/5/,
C_CG     1  MMDEDL/6/
C WI
C_CG  DATA (WDSNDL(2,1,N),N=1,6)/2*22.5,4*0.5/
C_CG  DATA (WDSNDL(3,1,N),N=1,6)/6*999./
C OS
C_CG  DATA (WDSNDL(1,2,N),N=1,6)/6*-999./
C_CG  DATA (WDSNDL(3,2,N),N=1,6)/6*9999./
C AM
C_CG  DATA (WDSNDL(1,3,N),N=1,6)/6*1./
C_CG  DATA (WDSNDL(2,3,N),N=1,6)/6*8./
C_CG  DATA (WDSNDL(3,3,N),N=1,6)/6*15./
C SZ
C_CG  DATA (WDSNDL(2,4,N),N=1,6)/6*10./
C_CG  DATA (WDSNDL(3,4,N),N=1,6)/6*99./
C DG
C_CG  DATA (WDSNDL(1,5,N),N=1,6)/6*2./
C_CG  DATA (WDSNDL(3,5,N),N=1,6)/6*8./
C SH
C_CG  DATA (WDSNDL(1,6,N),N=1,6)/6*-9999./
C_CG  DATA (WDSNDL(3,6,N),N=1,6)/6* 9999./
C_CG  DATA (WDSNDL(4,6,N),N=1,6)/6*-1./
C ST
C_CG  DATA (WDSNDL(1,7,N),N=1,6)/6*-9999./
C_CG  DATA (WDSNDL(3,7,N),N=1,6)/6* 9999./
C_CG  DATA (WDSNDL(4,7,N),N=1,6)/6*-1./
C FA
C_CG  DATA (WDSNDL(1,8,N),N=1,6)/6*0.01/
C_CG  DATA (WDSNDL(2,8,N),N=1,6)/6*1./
C_CG  DATA (WDSNDL(3,8,N),N=1,6)/6*999./
C
C_CG  DATA (((RAMPDL(1,N,J,K),N=1,MPRADL),J=1,MPDVDL),K=1,2)/96*-99./
C_CG  DATA (((RAMPDL(3,N,J,K),N=1,MPRADL),J=1,MPDVDL),K=1,2)/96*999./
C_CG  DATA (RAMPDL(2,N,4,1),N=1,8)/0.,3.,8.,15.,24.,35.,48.,63./
C_CG  DATA (RAMPDL(2,N,5,1),N=1,8)/0.,3.,8.,15.,24.,35.,48.,63./
C_CG  DATA (RAMPDL(2,N,4,2),N=1,8)/0.,0.,0.,4.,5.,6.,0.,0./
C_CG  DATA (RAMPDL(2,N,5,2),N=1,8)/0.,0.,7.,0.,0.,8.,0.,0./
C
C_CG  DATA MGRCDL/6*2/
C_CG  DATA MVARDL/3*6,2*12,6,  2*1,18,2*15,1/
C_CG  DATA MODEDL/3*3,2*2 ,3,  2*1,5,3*1/
C_CG  DATA MSYMDL/ 6*1,        2*1,1,3,6,1/
C_CG  DATA MCOLDL/6*8/
C_CG  DATA MLABDL/6*1/
C_CG  DATA SZVXDT/80./,NCVXDT/8/
      END
