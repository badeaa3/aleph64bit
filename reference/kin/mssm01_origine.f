*CMZ :  1.00/00 14/04/95  18.46.23  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
CYG       PROGRAM MSSMSUSY
CYG  
CYG CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
CYG C  Version 1.00
CYG C
CYG C                                 Authors S.Katsanevas- S. Melachroinos
CYG C
CYG C Based essentially on the formulas of A.Bartl et al to be found in
CYG C
CYG C 1) Signatures for chargino production Z. Phys C. 30, 441-449 (1986)
CYG C 2) Production and decay of neutralinos Nuclear Physics B278 (1986) 1-2
CYG C 3) Gaugino-Higsino mixing in selectron-sneutrino pair production
CYG C                                       Z. Phys. C 34, 411-417 (1987)
CYG C 4) Production and decay of SUSY particles   HEPHYPUB-1991-566
CYG C 5) Chargino production at LEP200           Z. Phys C55, 257 (1992)
CYG C
CYG CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
CYG  
CYG       IMPLICIT DOUBLE PRECISION (A-H,O-Z)
CYG  
CYG       real*4  rgmaum,rgmaur,rgm0,rgtanb,rgatri,rfmsq,rfmstopl,rfmstopr,
CYG      +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan(6)
CYG       common /rkey/rgmaum,rgmaur,rgm0,rgtanb,rgatri,
CYG      +        rfmsq,rfmstopl,rfmstopr,
CYG      +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan
CYG  
CYG       common/steer/gmaum,gmaur,gm0,gtanb,gatri,
CYG      +fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu
CYG       common/mds/modes,MIX
CYG  
CYG       logical zino,wino,sele,smuo,stau,snu,squa,stopa,sbota
CYG       common/sparc/ zino,wino,sele,smuo,stau,snu,squa,stopa,sbota
CYG       logical wrt,scan,lepi
CYG       common/str/wrt,scan,lepi
CYG       COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
CYG       COMMON/ISR/ QK(4)
CYG       COMMON /CONST/ idbg,igener,irad
CYG  
CYG       COMMON/INDEXX/index,index1,index2,nevt
CYG       COMMON/FINDEX/fmpr1,fmpr2,XCROST,APRO
CYG       common/mixings/cosphimix,facqcd,fgama,spartmas,ratq
CYG  
CYG       COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
CYG      +FLC(12),FRC(12),gms(12),echar(12)
CYG  
CYG       common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
CYG      +,cosmi(12)
CYG  
CYG  
CYG       COMMON/XCROS/xgaug(8),xeta(8)
CYG       common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
CYG  
CYG  
CYG       DOUBLE PRECISION gM(50),gmu(50)
CYG       real*4 step1,step2,sma,scros(13),scrost,scrost1,scosa,amp
CYG       real*4 sela(6)
CYG  
CYG  
CYG       dimension iffl(12)
CYG       CHARACTER*5 LBLIN,LBLIN1,SSID
CYG  
CYG       external gensel,gensmu,gensnue,gensnu,photi
CYG       external sigma
CYG  
CYG       common/brsum/ brsum(5,6,6),brsuma(6)
CYG  
CYG       common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
CYG      +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
CYG  
CYG  
CYG  
CYG c******************************************
CYG c STAGE 1        Read data cards          *
CYG c******************************************
CYG c
CYG c open data file
CYG c
CYG       OPEN(1,FILE='susygen.dat',STATUS='NEW',FORM='FORMATTED')
CYG c
CYG c changes by L.DUFLOT for HP, decomment them out
CYG c
CYG c      OPEN(5,FILE='susygen.cards',STATUS='OLD')
CYG c      call initc
CYG  
CYG  
CYG       call scards
CYG       call sbook
CYG  
CYG C
CYG C scan
CYG C
CYG       icmu=rvscan(1)
CYG       step1=(rvscan(3)-rvscan(2))/float(icmu-1)
CYG       icM=rvscan(4)
CYG       step2=(rvscan(6)-rvscan(5))/float(icM-1)
CYG  
CYG       if(icmu*icM.gt.0)then
CYG         do imu = 1,icmu
CYG         gmu(imu)=rvscan(2)+(imu-1)*step1
CYG         enddo
CYG         do iM = 1,icM
CYG         gM(iM)=rvscan(5)+(iM-1)*step2
CYG         enddo
CYG       endif
CYG  
CYG  
CYG       igeneralM=0
CYG    10 continue
CYG  
CYG       igeneralM=igeneralM+1
CYG  
CYG       if(scan)then
CYG         gmaum=gM(igeneralM)
CYG         rgmaum=real(gmaum)
CYG       endif
CYG  
CYG       igeneralmu=0
CYG  
CYG    20 continue
CYG  
CYG       igeneralmu=igeneralmu+1
CYG  
CYG       if(scan)then
CYG         gmaur=gmu(igeneralmu)
CYG         rgmaur=real(gmaur)
CYG       endif
CYG  
CYG  
CYG c******************************************
CYG c STAGE 2   Define masses and BR          *
CYG c******************************************
CYG c
CYG       S=ECM**2
CYG       ROOTS=DSQRT(S)
CYG       ebeam=ecm/2.
CYG  
CYG       if(scan) print *,' M  ',gmaum,' mu ',gmaur
CYG  
CYG  
CYG       CALL SUSANA(GMAUM,GMAUR,GTANB,Gm0,Gatri,mfail)
CYG  
CYG c
CYG c plot masses....
CYG c
CYG  
CYG       if(scan)then
CYG         do 30  k=1,3
CYG           ki=k
CYG           if(k.eq.3)ki=5
CYG           sma=xgaug(ki)
CYG    30   call hf2(400+k,rgmaur,rgmaum,sma)
CYG       endif
CYG  
CYG       if(mfail.eq.1)go to 270
CYG  
CYG c******************************************
CYG c STAGE 3   Calculate cross sections      *
CYG c           and generate                  *
CYG c******************************************
CYG  
CYG c
CYG c choose the specific process
CYG c
CYG  
CYG C
CYG C NEUTRALINOS
CYG C
CYG       if(zino)then
CYG         index=1
CYG         ihi=0
CYG         do 50 i=1,4
CYG           do 50 j=1,i
CYG             ihi=ihi+1
CYG             index1=i+70
CYG             index2=j+70
CYG             fmpr1=ssmass(index1)
CYG             fmpr2=ssmass(index2)
CYG             if(fmpr1+fmpr2.gt.ECM)go to 50
CYG             if(irad.eq.0)xcrost=photi(index1,index2)
CYG             IF(IRAD.EQ.1) CALL REMT1(EBEAM,SIGMA)
CYG  
CYG             nevt=xcrost*flum
CYG             if(xcrost.eq.0.)go to 50
CYG             lblin=ssid(index1)
CYG             lblin1=ssid(index2)
CYG             print *,LBLIN,LBLIN1,' sigma ',XCROST,' events ',NEVT
CYG             WRITE(1,10000) LBLIN,LBLIN1,XCROST,NEVT
CYG             scros(ihi)=xcrost*1000.
CYG  
CYG             apro=2.d0
CYG             do 40 kap=1,20
CYG               cosa=-1.d0+(kap-1)*.1d0
CYG               AMP = GENPHO(index1,index2,cosa)/xcrost
CYG               if(amp.gt.apro)apro=amp
CYG               scosa=cosa
CYG    40       call hf1(1000+ihi,scosa,amp)
CYG  
CYG             if(igener.eq.1) call mssm_gene
CYG  
CYG    50   continue
CYG       endif
CYG C
CYG C CHARGINOS
CYG C
CYG       if(wino)then
CYG         index=2
CYG         ihi=10
CYG         do 70 i=1,2
CYG           do 70 j=1,i
CYG             ihi=ihi+1
CYG             index1=(i+74)
CYG             index2=-(j+74)
CYG             fmpr1=ssmass(index1)
CYG             fmpr2=ssmass(index2)
CYG             if(fmpr1+fmpr2.gt.ECM)go to 70
CYG             if(irad.eq.0)xcrost=chargi(index1,index2)
CYG             IF(IRAD.EQ.1) CALL REMT1(EBEAM,SIGMA)
CYG             if(xcrost.eq.0.)go to 70
CYG             nevt=xcrost*flum
CYG             lblin=ssid(index1)
CYG             lblin1=ssid(index2)
CYG             print *,LBLIN,LBLIN1,' sigma ',XCROST,' events ',NEVT
CYG             WRITE(1,10000) LBLIN,LBLIN1,XCROST,NEVT
CYG             scros(ihi)=xcrost*1000.
CYG  
CYG             apro=2.d0
CYG             do 60 kap=1,20
CYG               cosa=-1.d0+(kap-1)*.1d0
CYG               AMP = GENCHAR(index1,index2,cosa)/xcrost
CYG               if(amp.gt.apro)apro=amp
CYG               scosa=cosa
CYG    60       call hf1(1000+ihi,scosa,amp)
CYG  
CYG             if(igener.eq.1) call mssm_gene
CYG  
CYG    70   continue
CYG       endif
CYG  
CYG       if(scan)then
CYG c
CYG c cross section scan x01x01, x01x02, x+1x-1
CYG c
CYG  
CYG         do 80  ihi=1,3
CYG           khi=ihi
CYG           if(ihi.eq.3)khi=11
CYG    80   call hf2(100+ihi,rgmaur,rgmaum,scros(khi))
CYG  
CYG c
CYG c BR scan of x01xo2
CYG c
CYG         sela(1)=brsum(1,1,2)*100.
CYG         sela(2)=brsum(2,1,2)*100.
CYG         sela(3)=brsum(3,1,2)*100.
CYG         sela(4)=brsum(4,5,2)*100.
CYG         sela(5)=brsum(5,5,2)*100.
CYG  
CYG         do 90  loi=1,5
CYG    90   call hf2(500+loi,rgmaur,rgmaum,sela(loi))
CYG  
CYG c
CYG c BR scan of x+1x-1
CYG c
CYG  
CYG         sela(1)=brsum(4,1,5)*100.
CYG         sela(2)=brsum(5,1,5)*100.
CYG         sela(3)=brsum(4,2,5)*100.
CYG         sela(4)=brsum(5,2,5)*100.
CYG  
CYG         do 100 loi=1,4
CYG   100   call hf2(600+loi,rgmaur,rgmaum,sela(loi))
CYG  
CYG       endif
CYG  
CYG C
CYG C SPARTICLES
CYG C
CYG       index=3
CYG  
CYG C***********************************************************************
CYG  
CYG       if(snu)then
CYG         nfla=3
CYG         iffl(1)=3
CYG         iffl(2)=7
CYG         iffl(3)=11
CYG         do 120 ka=1,nfla
CYG           k=iffl(ka)
CYG           k1=mod(k-1,4)+1
CYG  
CYG           do 120 l=1,1
CYG  
CYG             index1=ispa(k,l)
CYG             index2=-index1
CYG             if(index1.eq.0)go to 120
CYG  
CYG             fmpr1=ssmass(index1)
CYG             fmpr2=ssmass(index2)
CYG             if(fmpr1+fmpr2.gt.ECM)go to 120
CYG  
CYG             fgama=fgamc(k)
CYG             spartmas=fmpr1
CYG             ratq=ratqa(k)
CYG             cosphimix=1.
CYG             facqcd=0.
CYG  
CYG             if(k.eq.3.and.irad.eq.0)xCROSt=ssdint(-1.d0,gensnue,1.D0)
CYG             if(k.ne.3.and.irad.eq.0)xCROSt=ssdint(-1.D0,gensnu,1.D0)
CYG             IF(IRAD.EQ.1) CALL REMT1(EBEAM,SIGMA)
CYG  
CYG             if(xcrost.eq.0.)go to 120
CYG  
CYG             nevt=xcrost*flum
CYG             lblin=ssid(index1)
CYG             lblin1=ssid(index2)
CYG             print *,LBLIN,LBLIN1,' sigma ',XCROST,' events ',NEVT
CYG             WRITE(1,10000) LBLIN,LBLIN1,XCROST,NEVT
CYG  
CYG             apro=1.
CYG             do 110 kap=1,20
CYG               cosa=-1.d0+(kap-1)*.1d0
CYG               scosa=cosa
CYG  
CYG               if(k.eq.3)then
CYG                 AMP = GENSNUE(cosa)/xcrost
CYG                 if(amp.gt.apro)apro=amp
CYG               else
CYG                 AMP = GENSNU(cosa)/xcrost
CYG                 if(amp.gt.apro)apro=amp
CYG               endif
CYG  
CYG               if(k.eq.3)then
CYG                 call hf1(2001,scosa,amp)
CYG               endif
CYG  
CYG               if(k.eq.7)then
CYG                 call hf1(2002,scosa,amp)
CYG               endif
CYG  
CYG   110       continue
CYG  
CYG             if(scan)then
CYG               scrost=xcrost*1000.
CYG               call hf2(201,rgmaur,rgmaum,scrost)
CYG  
CYG  
CYG               if(k.eq.3)then
CYG  
CYG                 scrost1=fmal(3)
CYG                 call hf2(111,rgmaur,rgmaum,scrost1)
CYG  
CYG                 scrost= brspa(1,3)+brspa(2,3)+brspa(3,3)+brspa(4,3)+
CYG      +          brspa(5,3)+brspa(6,3)
CYG                 scrost1=0.
CYG                 if(scrost.ne.0.)scrost1=brspa(1,3)/scrost*100.
CYG                 call hf2(301,rgmaur,rgmaum,scrost1)
CYG                 if(scrost.ne.0.)scrost1=brspa(2,3)/scrost*100.
CYG                 call hf2(302,rgmaur,rgmaum,scrost1)
CYG                 if(scrost.ne.0.)scrost1=brspa(5,3)/scrost*100.
CYG                 call hf2(303,rgmaur,rgmaum,scrost1)
CYG               endif
CYG             endif
CYG  
CYG             if(igener.eq.1) call mssm_gene
CYG   120   continue
CYG       endif
CYG  
CYG C***********************************************************************
CYG       if(sele)then
CYG         nfla=1
CYG         iffl(1)=4
CYG  
CYG         do 140 ka=1,nfla
CYG           k=iffl(ka)
CYG           k1=mod(k-1,4)+1
CYG           do 140 l=1,2
CYG             index1=ispa(k,l)
CYG             index2=-index1
CYG             if(index1.eq.0)go to 140
CYG  
CYG             fmpr1=ssmass(index1)
CYG             fmpr2=ssmass(index2)
CYG             if(fmpr1+fmpr2.gt.ECM)go to 140
CYG  
CYG             spartmas=fmpr1
CYG             ratq=ratqa(k)
CYG             facqcd=0.
CYG  
CYG             if(l.eq.1)then
CYG               fgama=fgamc(k)
CYG               cosphimix=1.d0
CYG             else
CYG               fgama=fgamcr(k)
CYG               cosphimix=0.
CYG             endif
CYG             if(irad.eq.0)xCROSt=ssdint(-1.d0,gensel,1.d0)
CYG             IF(IRAD.EQ.1) CALL REMT1(EBEAM,SIGMA)
CYG  
CYG             if(xcrost.eq.0.)go to 140
CYG  
CYG             nevt=xcrost*flum
CYG             lblin=ssid(index1)
CYG             lblin1=ssid(index2)
CYG             print *,LBLIN,LBLIN1,' sigma ',XCROST,' events ',NEVT
CYG             WRITE(1,10000) LBLIN,LBLIN1,XCROST,NEVT
CYG  
CYG             apro=2.d0
CYG             do 130 kap=1,20
CYG               cosa=-1.d0+(kap-1)*.1d0
CYG               scosa=cosa
CYG               AMP = GENSEL(cosa)/xcrost
CYG               if(amp.gt.apro)apro=amp
CYG               call hf1(2002+l,scosa,amp)
CYG   130       continue
CYG  
CYG             if(scan)then
CYG               scrost=xcrost*1000.
CYG               call hf2(202,rgmaur,rgmaum,scrost)
CYG  
CYG               IF(L.EQ.1)THEN
CYG                 scrost= brspa(1,4)+brspa(2,4)+brspa(3,4)+brspa(4,4)+
CYG      +          brspa(5,4)+brspa(6,4)
CYG                 scrost1=0.
CYG                 if(scrost.ne.0.)scrost1=brspa(1,4)/scrost*100.
CYG                 call hf2(311,rgmaur,rgmaum,scrost1)
CYG                 if(scrost.ne.0.)scrost1=brspa(2,4)/scrost*100.
CYG                 call hf2(312,rgmaur,rgmaum,scrost1)
CYG                 if(scrost.ne.0.)scrost1=brspa(5,4)/scrost*100.
CYG                 call hf2(313,rgmaur,rgmaum,scrost1)
CYG               ELSE
CYG                 scrost= brspa(1,16)+brspa(2,16)+brspa(3,16) +brspa(4,
CYG      +          16)+brspa(5,16)+brspa(6,16)
CYG                 scrost1=0.
CYG                 if(scrost.ne.0.)scrost1=brspa(1,16)/scrost*100.
CYG                 call hf2(321,rgmaur,rgmaum,scrost1)
CYG                 if(scrost.ne.0.)scrost1=brspa(2,16)/scrost*100.
CYG                 call hf2(322,rgmaur,rgmaum,scrost1)
CYG                 if(scrost.ne.0.)scrost1=brspa(5,16)/scrost*100.
CYG                 call hf2(323,rgmaur,rgmaum,scrost1)
CYG               ENDIF
CYG               scrost1=fmal(4)
CYG               call hf2(112,rgmaur,rgmaum,scrost1)
CYG               scrost1=fmar(4)
CYG               call hf2(113,rgmaur,rgmaum,scrost1)
CYG             endif
CYG  
CYG             if(igener.eq.1) call mssm_gene
CYG   140   continue
CYG  
CYG         index=3
CYG  
CYG         index1=51
CYG         index2=-57
CYG         fmpr1=ssmass(index1)
CYG         fmpr2=ssmass(index2)
CYG         if(fmpr1+fmpr2.gt.ECM)go to 160
CYG         spartmas=fmpr1
CYG         ratq=ratqa(4)
CYG         cosphimix=1.
CYG         facqcd=0.
CYG         if(irad.eq.0)xCROSt=genselrs(dummy)
CYG         IF(IRAD.EQ.1) CALL REMT1(EBEAM,SIGMA)
CYG  
CYG         if(xcrost.eq.0.)go to 160
CYG  
CYG         nevt=xcrost*flum
CYG         lblin=ssid(index1)
CYG         lblin1=ssid(index2)
CYG         print *,LBLIN,LBLIN1,' sigma ',XCROST,' events ',NEVT
CYG         WRITE(1,10000) LBLIN,LBLIN1,XCROST,NEVT
CYG  
CYG         apro=2.d0
CYG         do 150 kap=1,20
CYG           cosa=-1.d0+(kap-1)*.1d0
CYG           scosa=cosa
CYG           AMP = GENSELR(cosa)/xcrost
CYG           if(amp.gt.apro)apro=amp
CYG           call hf1(2005,scosa,amp)
CYG   150   continue
CYG  
CYG         if(scan)then
CYG           scrost=xcrost
CYG           call hf2(202,rgmaur,rgmaum,scrost)
CYG         endif
CYG  
CYG         if(igener.eq.1) call mssm_gene
CYG  
CYG   160   continue
CYG  
CYG       endif
CYG  
CYG C***********************************************************************
CYG  
CYG       if(smuo)then
CYG         nfla=1
CYG         iffl(1)=8
CYG         do 180 ka=1,nfla
CYG  
CYG           k=iffl(ka)
CYG           k1=mod(k-1,4)+1
CYG  
CYG           do 180 l=1,2
CYG             index1=ispa(k,l)
CYG             index2=-index1
CYG             if(index1.eq.0)go to 180
CYG  
CYG             fmpr1=ssmass(index1)
CYG             fmpr2=ssmass(index2)
CYG  
CYG             if(fmpr1+fmpr2.gt.ECM)go to 180
CYG  
CYG             spartmas=fmpr1
CYG             ratq=ratqa(k)
CYG             facqcd=0.
CYG  
CYG             if(l.eq.1)then
CYG               fgama=fgamc(k)
CYG               cosphimix=1.d0
CYG             else
CYG               fgama=fgamcr(k)
CYG               cosphimix=0.
CYG             endif
CYG  
CYG  
CYG             if(irad.eq.0)xCROSt=gensmus(dummy)
CYG             IF(IRAD.EQ.1) CALL REMT1(EBEAM,SIGMA)
CYG  
CYG             if(xcrost.eq.0.)go to 180
CYG  
CYG             nevt=xcrost*flum
CYG             lblin=ssid(index1)
CYG             lblin1=ssid(index2)
CYG             print *,LBLIN,LBLIN1,' sigma ',XCROST,' events ',NEVT
CYG             WRITE(1,10000) LBLIN,LBLIN1,XCROST,NEVT
CYG  
CYG             apro=2.d0
CYG             do 170 kap=1,20
CYG               cosa=-1.d0+(kap-1)*.1d0
CYG               scosa=cosa
CYG               AMP = GENSMU(cosa)/xcrost
CYG               if(amp.gt.apro)apro=amp
CYG               call hf1(2005+l,scosa,amp)
CYG   170       continue
CYG  
CYG             if(igener.eq.1) call mssm_gene
CYG   180   continue
CYG       endif
CYG  
CYG C***********************************************************************
CYG  
CYG  
CYG  
CYG       if(stau)then
CYG         nfla=1
CYG         iffl(1)=12
CYG         do 200 ka=1,nfla
CYG  
CYG           k=iffl(ka)
CYG           k1=mod(k-1,4)+1
CYG  
CYG           do 200 l=1,2
CYG             index1=ispa(k,l)
CYG             index2=-index1
CYG             if(index1.eq.0)go to 200
CYG  
CYG             fmpr1=ssmass(index1)
CYG             fmpr2=ssmass(index2)
CYG             if(fmpr1+fmpr2.gt.ECM)go to 200
CYG  
CYG             spartmas=fmpr1
CYG             ratq=ratqa(k)
CYG             facqcd=0.
CYG  
CYG             if(l.eq.1)then
CYG               fgama=fgamc(k)
CYG             else
CYG               fgama=fgamcr(k)
CYG             endif
CYG  
CYG  
CYG             if(irad.eq.0)xCROSt=gensmus(dummy)
CYG  
CYG             IF(IRAD.EQ.1) CALL REMT1(EBEAM,SIGMA)
CYG             nevt=xcrost*flum
CYG  
CYG             if(xcrost.eq.0.)go to 200
CYG  
CYG             lblin=ssid(index1)
CYG             lblin1=ssid(index2)
CYG             print *,LBLIN,LBLIN1,' sigma ',XCROST,' events ',NEVT
CYG             WRITE(1,10000) LBLIN,LBLIN1,XCROST,NEVT
CYG  
CYG             apro=2.d0
CYG             do 190 kap=1,20
CYG               cosa=-1.d0+(kap-1)*.1d0
CYG               scosa=cosa
CYG               AMP = GENSMU(cosa)/xcrost
CYG               if(amp.gt.apro)apro=amp
CYG               call hf1(2007+l,scosa,amp)
CYG   190       continue
CYG  
CYG             if(igener.eq.1) call mssm_gene
CYG  
CYG   200   continue
CYG       endif
CYG  
CYG       if(sbota)then
CYG         nfla=1
CYG         iffl(1)=10
CYG         do 220 ka=1,nfla
CYG  
CYG           k=iffl(ka)
CYG           k1=mod(k-1,4)+1
CYG  
CYG           do 220 l=1,2
CYG             index1=ispa(k,l)
CYG             index2=-index1
CYG             if(index1.eq.0)go to 220
CYG  
CYG             fmpr1=ssmass(index1)
CYG             fmpr2=ssmass(index2)
CYG             if(fmpr1+fmpr2.gt.ECM)go to 220
CYG  
CYG  
CYG  
CYG             spartmas=fmpr1
CYG             ratq=ratqa(k)
CYG             facqcd=1.d0
CYG  
CYG             if(l.eq.1)then
CYG               fgama=fgamc(k)
CYG             else
CYG               fgama=fgamcr(k)
CYG             endif
CYG  
CYG  
CYG             if(irad.eq.0)xCROSt=gensmus(dummy)
CYG  
CYG             IF(IRAD.EQ.1) CALL REMT1(EBEAM,SIGMA)
CYG  
CYG             if(xcrost.eq.0.)go to 220
CYG  
CYG             nevt=xcrost*flum
CYG             lblin=ssid(index1)
CYG             lblin1=ssid(index2)
CYG             print *,LBLIN,LBLIN1,' sigma ',XCROST,' events ',NEVT
CYG             WRITE(1,10000) LBLIN,LBLIN1,XCROST,NEVT
CYG  
CYG             apro=2.d0
CYG             do 210 kap=1,20
CYG               cosa=-1.d0+(kap-1)*.1d0
CYG               scosa=cosa
CYG               AMP = GENSMU(cosa)/xcrost
CYG               if(amp.gt.apro)apro=amp
CYG               call hf1(2009+l,scosa,amp)
CYG   210       continue
CYG  
CYG             if(scan)then
CYG               IF(L.EQ.1)THEN
CYG                 scrost=xcrost*1000.
CYG                 call hf2(121,rgmaur,rgmaum,scrost)
CYG                 scrost= brspa(1,10)+brspa(2,10)+brspa(3,10)+ brspa(4,
CYG      +          10)+brspa(5,10)+brspa(6,10)
CYG                 scrost1=0.
CYG                 if(scrost.ne.0.)scrost1=brspa(1,10)/scrost*100.
CYG                 call hf2(331,rgmaur,rgmaum,scrost1)
CYG                 if(scrost.ne.0.)scrost1=brspa(2,10)/scrost*100.
CYG                 call hf2(332,rgmaur,rgmaum,scrost1)
CYG                 if(scrost.ne.0.)scrost1=brspa(5,10)/scrost*100.
CYG                 call hf2(333,rgmaur,rgmaum,scrost1)
CYG               ELSE
CYG                 scrost=xcrost*1000.
CYG                 call hf2(122,rgmaur,rgmaum,scrost)
CYG                 scrost= brspa(1,22)+brspa(2,22)+brspa(3,22)+ brspa(4,
CYG      +          22)+brspa(5,22)+brspa(6,22)
CYG                 scrost1=0.
CYG                 if(scrost.ne.0.)scrost1=brspa(1,22)/scrost*100.
CYG                 call hf2(341,rgmaur,rgmaum,scrost1)
CYG                 if(scrost.ne.0.)scrost1=brspa(2,22)/scrost*100.
CYG                 call hf2(342,rgmaur,rgmaum,scrost1)
CYG                 if(scrost.ne.0.)scrost1=brspa(5,22)/scrost*100.
CYG                 call hf2(343,rgmaur,rgmaum,scrost1)
CYG               ENDIF
CYG  
CYG               scrost1=fmal(10)
CYG               call hf2(114,rgmaur,rgmaum,scrost1)
CYG               scrost1=fmar(10)
CYG               call hf2(115,rgmaur,rgmaum,scrost1)
CYG  
CYG             endif
CYG  
CYG             if(igener.eq.1) call mssm_gene
CYG   220   continue
CYG       endif
CYG  
CYG  
CYG       if(stopa)then
CYG         nfla=1
CYG         iffl(1)=9
CYG  
CYG         do 240 ka=1,nfla
CYG  
CYG           k=iffl(ka)
CYG           k1=mod(k-1,4)+1
CYG  
CYG           do 240 l=1,2
CYG             index1=ispa(k,l)
CYG             index2=-index1
CYG             if(index1.eq.0)go to 240
CYG             fmpr1=ssmass(index1)
CYG             fmpr2=ssmass(index2)
CYG  
CYG  
CYG             if(fmpr1+fmpr2.gt.ECM)go to 240
CYG  
CYG             spartmas=fmpr1
CYG             ratq=ratqa(k)
CYG             facqcd=1.d0
CYG  
CYG             if(l.eq.1)then
CYG               fgama=fgamc(k)
CYG             else
CYG               fgama=fgamcr(k)
CYG             endif
CYG  
CYG             if(irad.eq.0)xCROSt=gensmus(dummy)
CYG             IF(IRAD.EQ.1) CALL REMT1(EBEAM,SIGMA)
CYG  
CYG             if(xcrost.eq.0.)go to 240
CYG             nevt=xcrost*flum
CYG             lblin=ssid(index1)
CYG             lblin1=ssid(index2)
CYG             print *,LBLIN,LBLIN1,' sigma ',XCROST,' events ',NEVT
CYG             WRITE(1,10000) LBLIN,LBLIN1,XCROST,NEVT
CYG  
CYG             apro=2.d0
CYG             do 230 kap=1,20
CYG               cosa=-1.d0+(kap-1)*.1d0
CYG               scosa=cosa
CYG               AMP = GENSMU(cosa)/xcrost
CYG               if(amp.gt.apro)apro=amp
CYG               call hf1(2011+l,scosa,amp)
CYG   230       continue
CYG  
CYG             if(scan)then
CYG               IF(L.EQ.1)THEN
CYG                 scrost=xcrost*1000.
CYG                 call hf2(123,rgmaur,rgmaum,scrost)
CYG                 scrost= brspa(1,9)+brspa(2,9)+brspa(3,9)+ brspa(4,9)+
CYG      +          brspa(5,9)+brspa(6,9)
CYG                 scrost1=0.
CYG                 if(scrost.ne.0.)scrost1=brspa(1,9)/scrost*100.
CYG                 call hf2(351,rgmaur,rgmaum,scrost1)
CYG                 if(scrost.ne.0.)scrost1=brspa(2,9)/scrost*100.
CYG                 call hf2(352,rgmaur,rgmaum,scrost1)
CYG                 if(scrost.ne.0.)scrost1=brspa(5,9)/scrost*100.
CYG                 call hf2(353,rgmaur,rgmaum,scrost1)
CYG               ELSE
CYG                 scrost=xcrost*1000.
CYG                 call hf2(124,rgmaur,rgmaum,scrost)
CYG                 scrost= brspa(1,21)+brspa(2,21)+brspa(3,21)+ brspa(4,
CYG      +          21)+brspa(5,21)+brspa(6,21)
CYG                 scrost1=0.
CYG                 if(scrost.ne.0.)scrost1=brspa(1,21)/scrost*100.
CYG                 call hf2(361,rgmaur,rgmaum,scrost1)
CYG                 if(scrost.ne.0.)scrost1=brspa(2,21)/scrost*100.
CYG                 call hf2(362,rgmaur,rgmaum,scrost1)
CYG                 if(scrost.ne.0.)scrost1=brspa(5,21)/scrost*100.
CYG                 call hf2(363,rgmaur,rgmaum,scrost1)
CYG               ENDIF
CYG               scrost1=fmal(9)
CYG               call hf2(116,rgmaur,rgmaum,scrost1)
CYG               scrost1=fmar(9)
CYG               call hf2(117,rgmaur,rgmaum,scrost1)
CYG             endif
CYG  
CYG             if(igener.eq.1) call mssm_gene
CYG   240   continue
CYG       endif
CYG  
CYG  
CYG C**********************************************************
CYG       if(squa)then
CYG         nfla=4
CYG         iffl(1)=1
CYG         iffl(2)=2
CYG         iffl(3)=5
CYG         iffl(4)=6
CYG         do 260 ka=1,nfla
CYG  
CYG           k=iffl(ka)
CYG           k1=mod(k-1,4)+1
CYG  
CYG           do 260 l=1,2
CYG             index1=ispa(k,l)
CYG             index2=-index1
CYG             if(index1.eq.0)go to 260
CYG  
CYG             fmpr1=ssmass(index1)
CYG             fmpr2=ssmass(index2)
CYG             if(fmpr1+fmpr2.gt.ECM)go to 260
CYG  
CYG             spartmas=fmpr1
CYG             ratq=ratqa(k)
CYG             facqcd=1.d0
CYG  
CYG             if(l.eq.1)then
CYG               fgama=fgamc(k)
CYG               cosphimix=1.d0
CYG             else
CYG               fgama=fgamcr(k)
CYG               cosphimix=0.
CYG             endif
CYG  
CYG             if(irad.eq.0)xCROSt=gensmus(dummy)
CYG  
CYG             IF(IRAD.EQ.1) CALL REMT1(EBEAM,SIGMA)
CYG  
CYG             if(xcrost.eq.0.)go to 260
CYG  
CYG             nevt=xcrost*flum
CYG             lblin=ssid(index1)
CYG             lblin1=ssid(index2)
CYG             print *,LBLIN,LBLIN1,' sigma ',XCROST,' events ',NEVT
CYG             WRITE(1,10000) LBLIN,LBLIN1,XCROST,NEVT
CYG  
CYG             apro=2.d0
CYG             do 250 kap=1,20
CYG               cosa=-1.d0+(kap-1)*.1d0
CYG               scosa=cosa
CYG               AMP = GENSMU(cosa)/xcrost
CYG               if(amp.gt.apro)apro=amp
CYG               call hf1(2013+l,scosa,amp)
CYG   250       continue
CYG  
CYG             if(igener.eq.1) call mssm_gene
CYG   260   continue
CYG       endif
CYG  
CYG   270 continue
CYG  
CYG  
CYG       if(scan)then
CYG  
CYG         if(igeneralM.lt.icM.or.igeneralmu.lt.icmu)then
CYG           if(igeneralmu.lt.icmu)goto 20
CYG           if(igeneralM.lt.icM )goto 10
CYG         endif
CYG  
CYG       endif
CYG  
CYG   280 continue
CYG  
CYG       call susend
CYG  
CYG 10000   FORMAT(1X,' Cross section in pb ',2(A5,2X),E15.5,' events ',i10)
CYG  
CYG       STOP
CYG       END
*CMZ :  1.00/00 14/04/95  18.39.54  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      subroutine susend
      logical wrt,scan,lepi
      common/str/wrt,scan,lepi
      call hrput(0,' susygen.hist ','n')
      return
      end
*CMZ :  1.00/00 14/04/95  18.39.54  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
CYG       subroutine scards
CYG  
CYG ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
CYG c  READ STEERING CARDS                                        c
CYG ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
CYG  
CYG       IMPLICIT DOUBLE PRECISION (A-H,O-Z)
CYG  
CYG c
CYG c parameters
CYG c
CYG       real*4  rgmaum,rgmaur,rgm0,rgtanb,rgatri,rfmsq,rfmstopl,rfmstopr,
CYG      +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan(6)
CYG       common /rkey/rgmaum,rgmaur,rgm0,rgtanb,rgatri,
CYG      +        rfmsq,rfmstopl,rfmstopr,
CYG      +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan
CYG  
CYG       common/steer/gmaum,gmaur,gm0,gtanb,gatri,
CYG      +fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu
CYG       common/mds/modes,mix
CYG c
CYG c  produce what ?
CYG c
CYG       logical zino,wino,sele,smuo,stau,snu,squa,stopa,sbota
CYG       common/sparc/ zino,wino,sele,smuo,stau,snu,squa,stopa,sbota
CYG c
CYG c
CYG c
CYG       COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
CYG       COMMON/ISR/ QK(4)
CYG       COMMON /CONST/ idbg,igener,irad
CYG  
CYG       logical wrt,scan,lepi
CYG       common/str/wrt,scan,lepi
CYG  
CYG  
CYG       common/decsel/idecsel(18)
CYG       real*4 phimix,stop1
CYG       common/stopmix/phimix,stop1
CYG  
CYG  
CYG  
CYG       call vzero(rvscan,6)
CYG  
CYG       CALL FFINIT(0)
CYG c
CYG c 3 modes of running
CYG C modes=1  5 input values
CYG C      =2  sfermion masses given
CYG C      =3  gluino mass and not M is given
CYG  
CYG       MODES=1
CYG       CALL FFKEY('MODES',modes ,1,'INTE')
CYG  
CYG c
CYG c first mode
CYG c
CYG       rgmaum=90.
CYG       CALL FFKEY('M',rgmaum,  1,'REAL')
CYG       rgmaur=90.
CYG       CALL FFKEY('mu',rgmaur,  1,'REAL')
CYG       rgm0=90.
CYG       CALL FFKEY('m0',rgm0,  1,'REAL')
CYG       tanb=4.
CYG       CALL FFKEY('tanb',rgtanb,  1,'REAL')
CYG       A=0.
CYG       CALL FFKEY('A',rgatri,  1,'REAL')
CYG c
CYG c second mode
CYG c
CYG       rfmsq=1000.
CYG       CALL FFKEY('MSQUARK',rfmsq,  1,'REAL')
CYG       rfmstopl=1000.
CYG       CALL FFKEY('MLSTOP',rfmstopl,  1,'REAL')
CYG       rfmstopr=1000.
CYG       CALL FFKEY('MRSTOP',rfmstopr,  1,'REAL')
CYG       rfmsell=1000.
CYG       CALL FFKEY('MLSEL',rfmsell,  1,'REAL')
CYG       rfmselr=1000.
CYG       CALL FFKEY('MRSEL',rfmselr,  1,'REAL')
CYG       rfmsnu=1000.
CYG       CALL FFKEY('MSNU',rfmsnu,  1,'REAL')
CYG       mix=0
CYG       CALL FFKEY('MIX',MIX,1,'INTE')
CYG       phimix=0.
CYG       CALL FFKEY('PHIMIX',phimix,  1,'REAL')
CYG       stop1=0.
CYG       CALL FFKEY('MSTOP1',stop1,  1,'REAL')
CYG c
CYG c Generate what ?
CYG c
CYG       CALL FFKEY('ZINO',zino,  1,'LOGIC')
CYG       CALL FFKEY('WINO',wino,  1,'LOGIC')
CYG       CALL FFKEY('SELECTRON',sele,  1,'LOGIC')
CYG       CALL FFKEY('SMUON',smuo,  1,'LOGIC')
CYG       CALL FFKEY('STAU',stau,  1,'LOGIC')
CYG       CALL FFKEY('SNU',snu,  1,'LOGIC')
CYG       CALL FFKEY('SQUARK',squa,  1,'LOGIC')
CYG       CALL FFKEY('SSTOP',stopa,  1,'LOGIC')
CYG       CALL FFKEY('SBOTTOM',sbota,  1,'LOGIC')
CYG c
CYG c Running conditions
CYG c
CYG       CALL FFKEY('ECM',recm,  1,'REAL')
CYG       CALL FFKEY('LUMINOSITY',rflum,  1,'REAL')
CYG       CALL FFKEY('ISR',irad,1,'INTE')
CYG       CALL FFKEY('GENER',igener,1,'INTE')
CYG       CALL FFKEY('DECSEL',idecsel,  18,'INTE')
CYG       CALL FFKEY('DEBUG',idbg ,1,'INTE')
CYG       call ffkey('LUWRIT',wrt,1,'LOGIC')
CYG       call ffkey('SCAN',scan,1,'LOGIC')
CYG       call ffkey('VSCAN',rvscan,6,'REAL')
CYG       call ffkey('LEPI',lepi,1,'LOGIC')
CYG  
CYG       CALL FFGO
CYG  
CYG       gmaum=dble(rgmaum)
CYG       gmaur=dble(rgmaur)
CYG       gm0=dble(rgm0)
CYG       gtanb=dble(rgtanb)
CYG       gatri=dble(rgatri)
CYG  
CYG       fmsq=dble(rfmsq)
CYG       fmstopl=dble(rfmstopl)
CYG       fmstopr=dble(rfmstopr)
CYG       fmsell=dble(rfmsell)
CYG       fmselr=dble(rfmselr)
CYG       fmsnu=dble(rfmsnu)
CYG       fmglu=dble(rfmglu)
CYG  
CYG       ecm=dble(recm)
CYG       flum=dble(rflum)
CYG  
CYG       if(modes.eq.3)gmaum=0.3*fmglu
CYG  
CYG       return
CYG       end
*CMZ :  1.00/00 14/04/95  18.46.24  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
CYG       SUBROUTINE SUSANA(AMGAUG,AMR,TANA,am0,aatri,mfail)
CYG  
CYG C********************************************************************
CYG C initialization routine of susy generator
CYG C                                         author S.Katsanevas
CYG C********************************************************************
CYG  
CYG       IMPLICIT DOUBLE PRECISION (A-H,O-Z)
CYG  
CYG       COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
CYG      +FLC(12),FRC(12),gms(12),echar(12)
CYG  
CYG       COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
CYG  
CYG       common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
CYG      +,cosmi(12)
CYG  
CYG  
CYG       COMMON /CONST/ idbg,igener,irad
CYG  
CYG       COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
CYG  
CYG       logical wrt,scan,lepi
CYG       common/str/wrt,scan,lepi
CYG  
CYG  
CYG  
CYG       DIMENSION T3(12)
CYG c
CYG c reorder sparticles and particles
CYG c
CYG       common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
CYG  
CYG       mfail=0
CYG C
CYG C initialize Euclidian constants
CYG C
CYG       PI = 3.1415926535D0
CYG       twopi=2.*pi
CYG C
CYG C initialize SM constants
CYG C
CYG  
CYG       ALPHA=1.D0/127.9D0
CYG       FMZ=91.19D0
CYG       GAMMAZ=2.497D0
CYG       GAMMAW=2.01D0
CYG       FMW=80.2
CYG       SIN2W=.231243D0
CYG       SINW=DSQRT(SIN2W)
CYG       COSW=DSQRT(1.-SIN2W)
CYG       E2=4.D0*PI*ALPHA
CYG       G2=E2/SIN2W
CYG  
CYG       DO 10 I=1,12
CYG  
CYG         IF(MOD(I-1,4).EQ.0)ECHAR(I)=2./3.
CYG         IF(MOD(I-1,4).EQ.1)ECHAR(I)=-1./3.
CYG  
CYG         IF(MOD(I-1,4).EQ.2)ECHAR(I)=0
CYG         IF(MOD(I-1,4).EQ.3)ECHAR(I)=-1.
CYG  
CYG         IF(MOD(I-1,2).EQ.0)T3(I)=1./2.
CYG         IF(MOD(I-1,2).EQ.1)T3(I)=-1./2.
CYG  
CYG         FLC(I)=T3(I)-ECHAR(I)*SINW**2
CYG         FRC(I)=-ECHAR(I)*SINW**2
CYG    10 CONTINUE
CYG  
CYG C
CYG C initialize  MSSM constants
CYG C
CYG C gaugino mass
CYG       FMGAUG=AMGAUG
CYG       FMR=AMR
CYG       FM0=am0
CYG       TANB=TANA
CYG       COSB=1./DSQRT(1.D0+TANB**2)
CYG       SINB=TANB*COSB
CYG       ATRI = aatri
CYG  
CYG  
CYG       WRITE(1,10000) FMGAUG,FMR,FM0,TANB,atri,gms(9) ,ecm,flum,irad
CYG  
CYG 10000 FORMAT(' INPUTS:'/
CYG      +' M       =',F10.3,'   mu       =',F10.3/
CYG      +' m0      =',F10.3,'   TANB     =',F10.3,/
CYG      +' A       =',F10.3,'   mtop     =',F10.3,/
CYG      +' Ecm     =',F10.3,'  Luminosity=',F10.3,
CYG      +' RAD CORR=',i3/)
CYG  
CYG C
CYG C calculate the mass and mixings of the sparticles
CYG C
CYG  
CYG  
CYG  
CYG       CALL sfermion(mfail)
CYG  
CYG       if(mfail.eq.1)return
CYG  
CYG C
CYG C calculate the mass and mixings of gauginos
CYG C
CYG       CALL gaugino(mfail)
CYG       if(mfail.eq.1)return
CYG c
CYG c LEP limits
CYG c
CYG       if(LEPI)call leplim(mfail)
CYG  
CYG       if(mfail.eq.1)return
CYG  
CYG c
CYG c calculate decay BR
CYG c
CYG       CALL branch
CYG  
CYG  
CYG       RETURN
CYG       END
*CMZ :  1.00/00 14/04/95  18.46.24  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
CYG       SUBROUTINE SFERMION(mfail)
CYG  
CYG C********************************************************************
CYG C calculates sparticle masses
CYG C                                         author S.Katsanevas
CYG C********************************************************************
CYG  
CYG       IMPLICIT DOUBLE PRECISION (A-H,O-Z)
CYG  
CYG * Keys
CYG       real*4  rgmaum,rgmaur,rgm0,rgtanb,rgatri,rfmsq,rfmstopl,rfmstopr,
CYG      +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan(6)
CYG       common /rkey/rgmaum,rgmaur,rgm0,rgtanb,rgatri,
CYG      +        rfmsq,rfmstopl,rfmstopr,
CYG      +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan
CYG  
CYG       logical wrt,scan,lepi
CYG       common/str/wrt,scan,lepi
CYG  
CYG  
CYG       COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
CYG      +FLC(12),FRC(12),gms(12),echar(12)
CYG  
CYG       COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
CYG  
CYG       common/spartcl/fmal(12),fmar(12),ratq(12),fgamc(12),fgamcr(12)
CYG      +,cosmi(12)
CYG       dimension fm1(12),fm2(12)
CYG  
CYG  
CYG       common/steer/gmaum,gmaur,gm0,gtanb,gatri,
CYG      +fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu
CYG       common/mds/modes,MIX
CYG  
CYG       real*4 phimix,stop1
CYG       common/stopmix/phimix,stop1
CYG  
CYG  
CYG       common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
CYG       data fmal/12*1./
CYG       data fmar/12*1./
CYG  
CYG       call smgut
CYG c
CYG c inexistent snu right
CYG c
CYG       fmar(3) =10000.
CYG       fmar(7) =10000.
CYG       fmar(11)=10000.
CYG  
CYG       COS2B=ABS(COSB**2-SINB**2)
CYG  
CYG       do 10 k=1,12
CYG  
CYG         IF(FMAL(K).LE.0.)then
CYG           write(1,*) ' sfermionL negative ',k,fmal(k)
CYG           if(scan)then
CYG           else
CYG             STOP 99
CYG           endif
CYG         endif
CYG  
CYG         IF(FMAR(K).LE.0.)then
CYG           write(1,*) ' sfermionR negative ',k,fmar(k)
CYG           if(scan)then
CYG           else
CYG             STOP 99
CYG           endif
CYG         endif
CYG  
CYG         if(fmal(k).lt.1.)fmal(k)=1.
CYG         if(fmar(k).lt.1.)fmar(k)=1.
CYG    10 continue
CYG  
CYG  
CYG       if(modes.eq.1)go to 30
CYG  
CYG       do 20 i=1,3
CYG c
CYG c up
CYG c
CYG         fmar(1+(i-1)*4)=fmsq
CYG         fmal(1+(i-1)*4)=fmsq
CYG c
CYG c down
CYG c
CYG         fmar(2+(i-1)*4)=fmsq
CYG         fmal(2+(i-1)*4)=fmsq
CYG c
CYG c neutrino
CYG c
CYG         fmal(3+(i-1)*4)=fmsnu
CYG c
CYG c electron
CYG c
CYG         fmar(4+(i-1)*4)=fmselr
CYG         fmal(4+(i-1)*4)=fmsell
CYG  
CYG    20 continue
CYG  
CYG       fmal(9)=fmstopl
CYG       fmar(9)=fmstopr
CYG  
CYG    30 continue
CYG  
CYG c
CYG c mixings
CYG c
CYG       DO 40 i=1,12
CYG         fm1(i)=fmal(i)**2
CYG         fm2(i)=fmar(i)**2
CYG  
CYG         costh=1.
CYG  
CYG         if(i.ge.9.and.MIX.ne.0)then
CYG  
CYG           ctanb=tanb
CYG           if(mod(i,2).eq.1)ctanb=1./tanb
CYG           ALT=((ATRI+FMR*CTANB))
CYG c
CYG c mixing for the 3d family
CYG c
CYG           sums=fmal(i)**2+fmar(i)**2
CYG           difs=fmal(i)**2-fmar(i)**2
CYG           delta=difs**2+4.d0*alt**2*gms(i)**2
CYG           if(delta.ne.0.)then
CYG             FM1(I)=0.5D0*(sums-dsqrt(delta))
CYG             FM2(I)=0.5D0*(sums+dsqrt(delta))
CYG             cos2th=difs/dsqrt(delta)
CYG             costh=(1+COS2TH)/2.
CYG             if(costh.ne.0.)costh=dsqrt(costh)
CYG           endif
CYG  
CYG c
CYG c overwrite stop mixing angle
CYG c
CYG c provision to read in stop mass and mixing
CYG c
CYG           if(stop1.gt.0..and.i.eq.9)then
CYG             phimix=phimix*3.1415926535/180.
CYG             phamix=dble(phimix)
CYG             costh=cos(phamix)
CYG             tanth=tan(phamix)
CYG             fm1(i)=stop1**2
CYG             fm2(i)=stop1**2+4.d0*alt*gms(i)*tanth
CYG           endif
CYG  
CYG         endif
CYG  
CYG  
CYG         COSMI(I)=costh
CYG         ratq(i)=-(ECHAR(I))
CYG         FGAMC(i) =(FLC(I)-FRC(I))*COSMI(I)**2+FRC(I)
CYG         FGAMCR(i)=(FRC(I)-FLC(I))*COSMI(I)**2+FLC(I)
CYG  
CYG  
CYG         IF(FM1(I).LE.0.)then
CYG           write(1,*) ' sfermion1 negative ',I,fm1(I)
CYG           mfail=1
CYG         else
CYG           FM1(I)=DSQRT(FM1(I))
CYG         endif
CYG  
CYG         IF(FM2(I).LE.0.)then
CYG           write(1,*) ' sfermion2 negative ',I,fm2(I)
CYG           mfail=1
CYG         else
CYG           FM2(I)=DSQRT(FM2(I))
CYG         endif
CYG  
CYG         if(I.lt.9)go to 40
CYG  
CYG         fmal(I)=fm1(I)
CYG         fmar(I)=fm2(I)
CYG  
CYG    40 CONTINUE
CYG  
CYG  
CYG       write (1,*) ' Sparticle masses '
CYG       write (1,10000) ' SUPR ',fmar(1),' SUPL ',fmal(1)
CYG       write (1,10000) ' SDNR ',fmar(2),' SDNL ',fmal(2)
CYG       write (1,10000) ' SELR ',fmar(4),' SELL ',fmal(4)
CYG       write (1,10000) ' SNU ',fmal(3)
CYG       write (1,10000) ' STP1 ',fmal(9) ,' STP2 ',fmar(9)
CYG       write (1,10000) ' SBT1 ',fmal(10),' SBT2 ',fmar(10)
CYG       write (1,10000) ' STA1 ',fmal(12),' STA2 ',fmar(12)
CYG  
CYG 10000 FORMAT(/a5,f10.0,a7,f10.0)
CYG  
CYG  
CYG       RETURN
CYG       END
*CMZ :  1.00/00 14/04/95  18.46.24  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      SUBROUTINE smgut
 
C********************************************************************
C Computes mass of leptons and squarks
C from a given set of SUSY parameters
C********************************************************************
C by S.Ambrosanio (1994)
C********************************************************************
 
      IMPLICIT DOUBLE PRECISION (A-H,K-Z)
 
      COMMON/SM/MW,MZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +     FLC(12),FRC(12),
     +     MUP,MDO,MVE,ME,MCH,MST,MVMU,MMU,MTOP,MBO,MVTAU,MTAU,
     +     echar(12)
 
      common/steer/m2,mu,m0,tgb,gatri,
     +     fmsq,fmstopl,fmstopr,fmsell,fmselr,fmsnu,fmglu
 
      PARAMETER(
     +     ALFGUT = .041, MGUT = 2.D+16,
     +     ALFEM = 1./127.9, ALFSTR = 0.118,
     +     ALF1 = 1.6981D-2, ALF2 = 3.3613D-2,
     +     SIN2WI=.2324)
 
      PARAMETER (T3V = 1./2., T3LL = -1./2., T3LR = 0.,
     +     T3UL = 1./2., T3DL = -1./2., T3QR = 0.,
     +     QV = 0., QL = -1., QU = 2./3., QD = -1./3.,
     +     B1 = 33./5., B2 = 1., B3 = -3.)
      PARAMETER (DELALF = 1)
 
      common/spartcl/
     +     msupl,msdol,msve,msel,mschl,msstl,msvmu,msmul,mstopl,
     +     msbol,msvtau,mstaul,
     +     msupr,msdor,msver,mser,mschr,msstr,msvmur,msmur,mstopr,
     +     msbor,msvtaur,mstaur,
     +     cosmi(12),ratq(12),fgamc(12),fgamcr(12)
 
      dimension fspart(24)
      equivalence(fspart(1),msupl)
 
      COMMON/SFERMIX/MSTAU1,MSTAU2,MSTOP1,MSTOP2,MSBO1,MSBO2
 
      COMMON/SFLOOP/ILOOP
 
 
 
      ALFA1(Q)= ALF1/(1.-B1*TD(Q)*ALF1/2./PI)
      ALFA2(Q)= ALF2/(1.-B2*TD(Q)*ALF2/2./PI)
      ALFA3(Q)= ALFSTR/(1.-B3*TD(Q)*ALFSTR/2./PI)
 
      C1(Q) = (2./11.)*(M2/ALF2)**2*
     +     (ALFGUT**2-ALFA1(Q)**2)
      C2(Q) = (3./2.)*(M2/ALF2)**2*
     +     (ALFGUT**2-ALFA2(Q)**2)
      C3(Q) =  (8./9.)*(M2/ALF2)**2*
     +     (ALFA3(Q)**2-ALFGUT**2)
 
      do 10 k=1,24
   10 fspart(k)=MZ
 
      SIN2W = SIN2WI-1.03D-7*(MTOP**2-138.**2)
      COS2W = 1.-SIN2W
 
      SINB  = TGB/SQRT(1. + TGB**2)
      COSB  =  1./SQRT(1. + TGB**2)
      SIN2B =  2.*TGB/(1. + TGB**2)
      COS2B = (1. - TGB**2)/(1. + TGB**2)
 
c       M12 = (ALFGUT/ALF2)*M2
c       M3  = (ALFSTR/ALF2)*M2
c       M1  = (5./3.)*(SIN2W/COS2W)*M2
 
      ZV  = T3V -QV*SIN2W
      ZLL = T3LL-QL*SIN2W
      ZLR = -(T3LR-QL*SIN2W)
      ZUL =   T3UL-QU*SIN2W
      ZUR = -(T3QR-QU*SIN2W)
      ZDL =   T3DL-QD*SIN2W
      ZDR = -(T3QR-QD*SIN2W)
 
      IORDER  = 0
   20 IORDER  = IORDER + 1
 
      MSVE2 = MVE**2+M0**2
     +     +C2(MSVE)+(1./4.)*C1(MSVE)
     +     +ZV*MZ**2*COS2B
      IF (MSVE2.LE.0.0) THEN
        IF (IORDER.GT.ILOOP) THEN
          MSVE = 1.D-08
        ELSE
          MSVE = MZ
        ENDIF
      ELSE
        MSVE = SQRT(MSVE2)
      ENDIF
      MSVMU  = MSVE
      MSVTAU = MSVE
 
      MSEL = SQRT(ME**2+M0**2
     +     +C2(MSEL)+(1./4.)*C1(MSEL)
     +     +ZLL*MZ**2*COS2B)
      MSMUL  = MSEL
      MSTAUL = SQRT(MTAU**2+M0**2
     +     +C2(MSTAUL)+(1./4.)*C1(MSTAUL)
     +     +ZLL*MZ**2*COS2B)
 
      MSER = SQRT(ME**2+M0**2
     +     +C1(MSER)
     +     +ZLR*MZ**2*COS2B)
      MSMUR   = MSER
      MSTAUR  = SQRT(MTAU**2+M0**2
     +     +C1(MSTAUR)
     +     +ZLR*MZ**2*COS2B)
 
      MSUPL2 = MUP**2+M0**2
     +     +C3(MSUPL)+C2(MSUPL)+(1./36.)*C1(MSUPL)
     +     +ZUL*MZ**2*COS2B
      IF (MSUPL2.LE.0.0) THEN
        IF (IORDER.GT.ILOOP) THEN
          MSUPL = 1.D-08
        ELSE
          MSUPL = MZ
        ENDIF
      ELSE
        MSUPL = SQRT(MSUPL2)
      ENDIF
      MSCHL   = MSUPL
 
C     MSTOPL2  = MSUPL**2+(MH20Q-MU**2
C     .      -MSEL**2-ZLL*MZ**2*COS2B)/3.+MTOP**2
C     IF (MSTOPL2.LE.0.0) THEN
C      IF (IORDER.GT.ILOOP) THEN
C       MSTOPL = 1.D-08
C      ELSE
C       MSTOPL = MZ
C      ENDIF
C     ELSE
C      MSTOPL  = SQRT(MSTOPL2)
C     ENDIF
 
      MSUPR2 = MUP**2+M0**2
     +     +C3(MSUPR)+(4./9.)*C1(MSUPR)
     +     +ZUR*MZ**2*COS2B
      IF (MSUPR2.LE.0.0) THEN
        IF (IORDER.GT.ILOOP) THEN
          MSUPR = 1.D-08
        ELSE
          MSUPR = MZ
        ENDIF
      ELSE
        MSUPR = SQRT(MSUPR2)
      ENDIF
      MSCHR   = MSUPR
C     MSTOPR2  = MSUPR**2+2.*(MH20Q-MU**2
C     .      -MSEL**2-ZLL*MZ**2*COS2B)/3.+MTOP**2
C     IF (MSTOPR2.LE.0.0) THEN
C      IF (IORDER.GT.ILOOP) THEN
C       MSTOPR = 1.D-08
C      ELSE
C       MSTOPR = MZ
C      ENDIF
C     ELSE
C      MSTOPR  = SQRT(MSTOPR2)
C     ENDIF
 
      MSDOL = SQRT(MDO**2+M0**2
     +     +C3(MSDOL)+C2(MSDOL)+(1./36.)*C1(MSDOL)
     +     +ZDL*MZ**2*COS2B)
      MSSTL   = MSDOL
 
C     MSBOL2   = MSDOL**2+(MH20Q-MU**2
C     .      -MSEL**2-ZLL*MZ**2*COS2B)/3.
C     IF (MSBOL2.LE.0.0) THEN
C      MSBOL   = MSDOL
C     ELSE
C      MSBOL   = SQRT(MSBOL2)
C     ENDIF
 
      MSDOR = SQRT(MDO**2+M0**2
     +     +C3(MSDOR)+(1./9.)*C1(MSDOR)
     +     +ZDR*MZ**2*COS2B)
      MSSTR   = MSDOR
 
      MSBOR2 = MBO**2+M0**2
     +     +C3(MSBOR)+(1./9.)*C1(MSBOR)
     +     +ZDR*MZ**2*COS2B
      IF (MSBOR2.LE.0.0) THEN
        MSBOR = MSDOR
      ELSE
        MSBOR = SQRT(MSBOR2)
      ENDIF
 
      IF (IORDER.LE.ILOOP) GOTO 20
 
      MSBOL=MSDOL
      MSTOPL=MSUPL
      MSTOPR=MSUPR
 
      RETURN
 
      END
*CMZ :  1.00/00 14/04/95  18.39.55  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      function td(q)
 
      IMPLICIT DOUBLE PRECISION (A-H,K-Z)
 
      COMMON/SM/MW,MZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +     FLC(12),FRC(12),
     +     MUP,MDO,MVE,ME,MCH,MST,MVMU,MMU,MTOP,MBO,MVTAU,MTAU,
     +     echar(12)
 
      TD = LOG(Q/MZ)
 
c     TU(Q) = 2.*LOG(MGUT/Q)
 
      return
      end
*CMZ :  1.00/00 14/04/95  18.46.24  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      SUBROUTINE gaugino(mfail)
 
 
C********************************************************************
C calculates gaugino masses and mixings
C                                         author S.Katsanevas
C********************************************************************
 
 
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
 
C Keys
      real*4  rgmaum,rgmaur,rgm0,rgtanb,rgatri,rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan(6)
      common /rkey/rgmaum,rgmaur,rgm0,rgtanb,rgatri,
     +        rfmsq,rfmstopl,rfmstopr,
     +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum,rvscan
      logical wrt,scan,lepi
      common/str/wrt,scan,lepi
 
 
 
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
 
      real*4 zr,was,esa
      COMMON/XCROS/xgaug(8),xeta(8)
      COMMON/NEUMIX/ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      COMMON/CHANEU/oijlp(4,2),oijrp(4,2)
 
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)
 
 
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
 
      COMMON /CONST/ idbg,igener,irad
 
      REAL*4 FMA(4,4),WR(4),vtemp(4),work(16)
 
c      real*4 weight
 
      sin2w=sinw**2
      sin2beta=2.*sinb*cosb
      cos2beta=cosb**2-sinb**2
 
 
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C neutralino part
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
 
 
      FMGAUG1=FMGAUG*5./3.*SINW**2/COSW**2
 
CYG       write(1,10000) FMGAUG1
10000 format(//' GAUGINO U(1) = ',F10.3/)
 
      FMA(1,1)= FMGAUG1*COSW**2+FMGAUG*SINW**2
      FMA(2,1)= (FMGAUG-FMGAUG1)*SINW*COSW
      FMA(3,1)= 0.
      FMA(4,1)= 0.
      FMA(1,2)= (FMGAUG-FMGAUG1)*SINW*COSW
      FMA(2,2)= FMGAUG1*SINW**2+FMGAUG*COSW**2
      FMA(3,2)= FMw/cosw
      FMA(4,2)= 0.
      FMA(1,3)= 0.
      FMA(2,3)= FMw/cosw
      FMA(3,3)=   FMR*SIN2BETA
      FMA(4,3)= - FMR*COS2BETA
      FMA(1,4)= 0.
      FMA(2,4)= 0.
      FMA(3,4)= - FMR*COS2BETA
      FMA(4,4)= - FMR*SIN2BETA
 
      CALL EISRS1(4,4,FMA,WR,ZR,IERR,WORK)
      IF(IERR.NE.0)RETURN
 
      DO 10 K=1,4
        WAS(K)=ABS(WR(K))
        ESA(K)=SIGN(1.,WR(K))
   10 CONTINUE
 
C
C       Sort eigenvectors and eigenvalues according to masses
C
      DO 30 I=1,3
        DO 20 J=I+1,4
          IF (was(i).GT.was(j)) THEN
            call ucopy(zr(1,j),vtemp,4)
            TEMP=abs(was(J))
            temp1=esa(j)
            call ucopy(zr(1,i),zr(1,j),4)
            Was(J)=Was(I)
            esa(j)=esa(i)
            call ucopy(vtemp,zr(1,i),4)
            Was(I)=TEMP
            esa(i)=temp1
          END IF
   20   CONTINUE
   30 CONTINUE
 
 
c
c
c voijl,voijr are Bartl's o-double-prime ij left + right
c
      do 40 i=1,4
        do 40 j=1,4
 
 
          A1=-(ZR(3,i)*ZR(3,j)-ZR(4,i)*ZR(4,j))*COS2BETA
          A2=-(ZR(3,i)*ZR(4,j)+ZR(4,i)*ZR(3,j))*SIN2BETA
 
          VOIJL(i,j)=(A1+A2)/2.
          VOIJR(i,j)=-VOIJL(i,j)
   40 CONTINUE
 
CYG       if(idbg.eq.1)write (1,10100) VOIJL
10100 FORMAT(2X,' Neutralino OIJL matrix ',4F10.3)
 
 
      DO 50  i=1,4
        do 50  l=1,4
 
 
          GFIL(i,l)= -DSQRT(2.D0)*(FLC(l)*ZR(2,i)/COSW-FRC(l)*ZR(1,i)/
     +    SINW)
          GFIR(i,l)= DSQRT(2.D0)*FRC(l)*(ZR(2,i)/COSW-ZR(1,i)/SINW)
 
   50 CONTINUE
 
CYG       if(idbg.eq.1)write (1,10200) GFIL
CYG       if(idbg.eq.1)write (1,10300) GFIR
10200 FORMAT(/2X,' Neutralino GFIL ',4F10.3)
10300 FORMAT(/2X,' Neutralino GFIR ',4F10.3)
 
 
CYG       WRITE(1,10400) was,esa
10400 FORMAT(/' NEUTRALINO MASSES  =',4F10.3,
     +       /' NEUTRALINO ETA     =',4F10.3)
 
      DO 60  J=1,4
CYG         WRITE(1,10500) J,(zr(k,j),K=1,4)
10500   FORMAT(' EIGENVECTOR  ',I1,'     =',4F10.3)
   60 CONTINUE
 
 
C********************************************************
C
C chargino part
C
C********************************************************
 
      DELTA1=dsqrt((FMGAUG-FMR)**2+2.D0*FMW**2*(1.+sin2beta))
      DELTA2=dsqrt((FMGAUG+FMR)**2+2.D0*FMW**2*(1.-sin2beta))
 
      FMM1=0.5*(delta1-delta2)
      FMM2=0.5*(delta1+delta2)
      FM(1)=ABS(FMM1)
      FM(2)=ABS(FMM2)
      ETA(1)=dsign(1.d0,fmm1)
      ETA(2)=dsign(1.d0,fmm2)
 
 
      w1=fmgaug**2-fmr**2-2.d0*fmw**2*cos2beta
      w2=fmgaug**2-fmr**2+2.d0*fmw**2*cos2beta
      welta=(fmgaug**2+fmr**2+2.d0*fmw**2)**2
     +-4.d0*(fmgaug*fmr-fmw**2*sin2beta)**2
      if(welta.le.0.)welta=0.0001
      welta=dsqrt(welta)
      ea=fmgaug*sinb+fmr*cosb
      eb=fmgaug*cosb+fmr*sinb
 
      if(tanb.ge.1)then
        th1=1.
        th2=dsign(1.d0,eb)
        th3=dsign(1.d0,ea)
        th4=1.
      else
        th1=dsign(1.d0,eb)
        th2=1.
        th3=1.
        th4=dsign(1.d0,ea)
      endif
 
      if(dabs(w1).gt.welta)then
        asign=dsign(1.d0,w1)
        w1=welta*asign
        if(idbg.eq.1)write (6,10600) w1,welta
10600 FORMAT(1X,' ERROR in Gaugino w1 ',2f10.2)
        w1=welta
      endif
      if(dabs(w2).gt.welta)then
        asign=dsign(1.d0,w2)
        w2=welta*asign
        if(idbg.eq.1)write (6,10700) w2,welta
10700 FORMAT(1X,' ERROR in Gaugino w2 ',2f10.2)
        w2=welta
      endif
 
      u(1,2)= th1*dsqrt(1.d0+w1/welta)/dsqrt(2.d0)
      u(2,1)=u(1,2)
      u(2,2)= th2*dsqrt(1.d0-w1/welta)/dsqrt(2.d0)
      u(1,1)=-u(2,2)
 
      v(2,1)=th3*dsqrt(1.d0+w2/welta)/dsqrt(2.d0)
      v(1,2)=-v(2,1)
      v(2,2)=th4*dsqrt(1.d0-w2/welta)/dsqrt(2.d0)
      v(1,1)=v(2,2)
 
 
      OIJL(1,1)=0.25d0-cosw**2+w2/4.d0/welta
      OIJL(2,2)=0.25d0-cosw**2-w2/4.d0/welta
      OIJL(1,2)=-fmw*ea/dsqrt(2.d0)/welta
      OIJL(2,1)=OIJL(1,2)
 
      OIJR(1,1)=0.25d0-cosw**2+w1/4.d0/welta
      OIJR(2,2)=0.25d0-cosw**2-w1/4.d0/welta
      OIJR(1,2)=fmw*eb/dsqrt(2.d0)/welta
      OIJR(2,1)=OIJR(1,2)
 
CYG       WRITE(1,10800) fm,eta
10800 FORMAT(/' CHARGINO MASSES    =',2F10.3,
     +        /' CHARGINO ETA      =',2F10.3/)
 
CYG       Write (1,*) ' U matrix ','  WINO   ',' HIGGSINO '
CYG       Write (1,10900) U
CYG       Write (1,*) ' V matrix ','  WINO   ',' HIGGSINO '
CYG       Write (1,11000) V
 
CYG       if(idbg.eq.1)Write (1,11100) OIJL
CYG       if(idbg.eq.1)Write (1,11200) OIJR
 
10900 FORMAT(' W1SS+    ',2F10.3,/' W2SS+    ',2F10.3/)
11000 FORMAT(' W1SS-    ',2F10.3,/' W2SS-    ',2F10.3/)
 
11100 FORMAT(/2X,' Chargino OIJL matrix ',4F10.3)
11200 FORMAT(/2X,' Chargino OIJR matrix ',4F10.3)
 
 
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
C neutralino/chargino part
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
 
      do 70 I=1,4
        do 70 J=1,2
 
 
          A1=-(ZR(4,i)*COSB-ZR(3,i)*SINB)*V(J,2)/SQRT(2.)
          B1= (ZR(4,i)*SINB+ZR(3,i)*COSB)*U(J,2)/SQRT(2.)
          A2=(ZR(1,i)*SINW+ZR(2,i)*COSW)*V(J,1)
          B2=(ZR(1,i)*SINW+ZR(2,i)*COSW)*U(J,1)
 
          OIJLP(I,J)=A1+A2
          OIJRP(I,J)=B1+B2
   70 CONTINUE
 
CYG       if(idbg.eq.1)write (1,11300) oijlp,oijrp
11300 FORMAT(2X,' Neutralino/Chargino OIJL matrix ',4F10.3)
 
c
c will be changed
c
      do 80 k=1,4
        xgaug(k)=was(k)
        xeta(k)=esa(k)
   80 continue
 
      do 90 k=1,2
        xgaug(k+4)=fm(k)
        xeta(k+4)=eta(k)
        xgaug(k+6)=fm(k)
        xeta(k+6)=eta(k)
   90 continue
 
      if(xgaug(1).gt.xgaug(5))then
CYG         write(1,11400) xgaug(1),xgaug(5)
11400 FORMAT(1X,' bad point: neutralino ',f5.1,' > chargino ',f5.1)
        call hf2(201,rgmaur,rgmaum,1.)
        mfail=1
      endif
 
      do 100 ko=1,12
        if(xgaug(1).gt.fmal(ko))then
CYG           write(1,11500) xgaug(1),ko,fmal(ko)
11500 FORMAT(1X,' bad point: neutralino ',f5.1,' > spart ',i5,f5.1)
          call hf2(201,rgmaur,rgmaum,1.)
          mfail=1
        endif
 
  100 continue
 
      do 110 ko=1,12
        if(xgaug(1).gt.fmar(ko))then
 
CYG           write(1,11600) xgaug(1),ko,fmal(ko)
11600 FORMAT(1X,' bad point: neutralino ',f5.1,' > spart ',i5,f5.1)
          call hf2(201,rgmaur,rgmaum,1.)
          mfail=1
        endif
 
  110 continue
 
      RETURN
      END
*CMZ :  1.00/00 14/04/95  18.46.25  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      subroutine baer
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      real*4 zr,was,esa
      COMMON/NEUMIX/ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      COMMON/CHANEU/oijlp(4,2),oijrp(4,2)
      real*4 vo(4,4),uo(4,4),z(4,4)
      real*4 junk(4,4)
      common/jnk/junk
c
c matrix for change of base ( Baer et al base )
c
      uo(1,1)=cosw
      uo(1,2)=sinw
      uo(1,3)=0
      uo(1,4)=0
      uo(2,1)=-sinw
      uo(2,2)=cosw
      uo(2,3)=0
      uo(2,4)=0
      uo(3,1)=0
      uo(3,2)=0
      uo(3,3)=cosb
      uo(3,4)=-sinb
      uo(4,1)=0
      uo(4,2)=0
      uo(4,3)=sinb
      uo(4,4)=cosb
      vo(1,1)=cosw
      vo(1,2)=-sinw
      vo(1,3)=0
      vo(1,4)=0
      vo(2,1)=sinw
      vo(2,2)=cosw
      vo(2,3)=0
      vo(2,4)=0
      vo(3,1)=0
      vo(3,2)=0
      vo(3,3)=cosb
      vo(3,4)=sinb
      vo(4,1)=0
      vo(4,2)=0
      vo(4,3)=-sinb
      vo(4,4)=cosb
 
      do 10  i=1,4
        do 10  j=1,4
          z(i,j)=0.
          do 10  k=1,4
            z(i,j)=z(i,j)+junk(i,k)*uo(k,j)
   10 continue
      do 20  i=1,4
        do 20  j=1,4
          junk(i,j)=0.
          do 20  k=1,4
            junk(i,j)=junk(i,j)+vo(i,k)*zr(k,j)
   20 continue
 
      DO 30  J=1,4
CYG         WRITE(1,10000) J,(junk(k,j),K=1,4)
10000   FORMAT(' Baers EIGENVECTOR ',I1,'     =',4F10.5)
   30 CONTINUE
c
c phiplus=gammal of Baer
c phiminus=gammar of Baer
c But the definition of U and V as a
c function of phi+,phi-  inverted .
c
      PHIM=PI/2.
      PHIP=PI/2.
      IF(U(1,1).NE.0.)phim=atan(u(1,2)/u(1,1))
      IF(V(1,1).NE.0.)phip=atan(v(1,2)/v(1,1))
      if(phim.lt.0.)phim=phim+pi
      if(phip.lt.0.)phip=phip+pi
 
CYG       WRITE(1,10100) phip,phim
10100 FORMAT(/' CHARGINO PHI+,-   =',2F10.3)
 
      return
      end
*CMZ :  1.00/00 14/04/95  18.39.55  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      subroutine leplim(mfail)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON/XCROS/xgaug(8),xeta(8)
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
 
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)
 
c
c only neutralinos for the time being
c
c FNAL limit
      if(tanb.ge.2.d0.and.fmgaug.le.30.d0)mfail=1
c LEPI limit
      if(tanb.ge.2.d0.and.xgaug(1).le.20.d0)mfail=1
      return
      end
*CMZ :  1.00/00 14/04/95  18.46.25  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
CYG       subroutine branch
CYG  
CYG       IMPLICIT DOUBLE PRECISION (A-H,O-Z)
CYG  
CYG       common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
CYG      +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
CYG  
CYG       COMMON/OUTMAP/ND,NDIM0,XI(50,10)
CYG  
CYG       COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
CYG  
CYG       COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
CYG      +FLC(12),FRC(12),gms(12),echar(12)
CYG  
CYG       common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
CYG      +,cosmi(12)
CYG  
CYG       common/stulim/smin,smax,tmin,tmax,umin,umax
CYG  
CYG       real ala1,ala2,rfm0
CYG  
CYG       real*4 zr,was,esa
CYG  
CYG       COMMON/NEUMIX/ ZR(4,4),was(4),ESA(4),
CYG      +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
CYG       COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
CYG  
CYG       COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
CYG  
CYG       common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
CYG      +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
CYG c
CYG C index1 =1,6 daughter particles
CYG c index2 =1,6 parent   particles
CYG c i1 =1,6 for 6 kinds of couplings uu,dd,vv,ll,ud,lv
CYG  
CYG  
CYG       COMMON/SDECAY/DAS,DBS,DCS,DATL,DAUL,DATUL,DASTL,DBSTL,DASUL,
CYG      +DBSUL,DATR,DAUR,DATUR,DASTR,DBSTR,DASUR,DBSUR,xdec(17,64)
CYG       DIMENSION CURRENT(17)
CYG       EQUIVALENCE (CURRENT(1),DAS)
CYG  
CYG       COMMON /CONST/ idbg,igener,irad
CYG  
CYG  
CYG       COMMON/XCROS/xgaug(8),xeta(8)
CYG  
CYG       common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
CYG       common/curind/index1,index2,i1
CYG  
CYG  
CYG       logical logvar
CYG       logical hexist
CYG       external hexist
CYG       external sbrdec
CYG       real hbfun2,sbrdec
CYG       external wsc,brodec1,brodec2,brodec3
CYG  
CYG       dimension x(2)
CYG  
CYG c
CYG c  sparticle widths
CYG c
CYG C carefull formulas below valid only for stop/bottom  below top
CYG C
CYG  
CYG       do 50 k=1,12
CYG         cos2=cosmi(k)**2
CYG         sin2=1.d0-cos2
CYG         widfr(k)=0.
CYG         widfl(k)=0.
CYG  
CYG         do 10 l=1,4
CYG           index=70+l
CYG           fmii=ssmass(index)
CYG           brspa(l,k)=0
CYG           ik1=idecs(k,1)
CYG           fmpart=ssmass(ik1)
CYG           if(fmal(k).le.(fmii+fmpart))go to 10
CYG           const=g2/16.d0/pi/fmal(k)**3*(fmal(k)**2-fmii**2)**2
CYG           k1=mod(k-1,4)+1
CYG           brspa(l,k)=const*(gfil(l,k1)**2*cos2+gfir(l,k1)**2*sin2)
CYG c
CYG c different stop/sbottom
CYG c
CYG           if(k.eq.9.or.k.eq.10) brspa(l,k)=0.0000000003d0/fmal(k)**3*
CYG      +    (fmal(k)**2-fmii**2)**2
CYG c
CYG           widfl(k)=widfl(k)+brspa(l,k)
CYG    10   continue
CYG  
CYG         do 20 l=5,6
CYG           index=70+l
CYG           fmii=ssmass(index)
CYG           brspa(l,k)=0
CYG           ik1=idecs(k,2)
CYG           fmpart=ssmass(ik1)
CYG           if(fmal(k).le.(fmii+fmpart))go to 20
CYG           const=g2/16.d0/pi/fmal(k)**3*(fmal(k)**2-fmii**2)**2
CYG           k1=mod(k-1,2)+1
CYG           if(k1.eq.1)brspa(l,k)=const*v(l-4,1)**2*cos2
CYG           if(k1.eq.2)brspa(l,k)=const*u(l-4,1)**2*cos2
CYG           widfl(k)=widfl(k)+brspa(l,k)
CYG    20   continue
CYG  
CYG         do 30 l=1,4
CYG           brspa(l,k+12)=0
CYG           index=70+l
CYG           fmii=ssmass(index)
CYG           ik1=idecs(k,1)
CYG           fmpart=ssmass(ik1)
CYG           if(fmar(k).le.(fmii+fmpart))go to 30
CYG           k1=mod(k-1,4)+1
CYG           const=g2/16.d0/pi/fmar(k)**3*(fmar(k)**2-fmii**2)**2
CYG           brspa(l,k+12)=const*(gfil(l,k1)**2*sin2+gfir(l,k1)**2*cos2)
CYG c
CYG c different stop sbottom
CYG c
CYG           if(k.eq.9.or.k.eq.10) brspa(l,k+12)=0.0000000003d0/fmar(k)**
CYG      +    3*(fmar(k)**2-fmii**2)**2
CYG c
CYG           widfr(k)=widfr(k)+brspa(l,k)
CYG    30   continue
CYG  
CYG         do 40 ki=9,9
CYG           do 40 l=5,6
CYG             brspa(l,ki+12)=0
CYG             index=70+l
CYG             fmii=ssmass(index)
CYG             ik1=idecs(ki,1)
CYG             fmpart=ssmass(ik1)
CYG             if(fmar(k).le.(fmii+fmpart))go to 40
CYG             k1=mod(ki-1,4)+1
CYG             const=g2/16.d0/pi/fmar(ki)**3*(fmar(ki)**2-fmii**2)**2
CYG             brspa(l,ki+12)=const*v(l-4,2)**2*gms(9)**2/fmw**2/sinb**2/
CYG      +      2.d0
CYG             brspa(l,ki+12)=brspa(l,ki+12)*cos2
CYG             widfr(ki)=widfr(ki)+brspa(l,ki)
CYG    40   continue
CYG  
CYG    50 continue
CYG  
CYG  
CYG       write (1,*) ' Sparticle widths  (GeV) '
CYG       write (1,10000) ' SUPR ',widfl(1),' SUPL ',widfr(1)
CYG       write (1,10000) ' SDNR ',widfl(2),' SDNL ',widfr(2)
CYG       write (1,10000) ' SELR ',widfl(4),' SELL ',widfr(4)
CYG       write (1,10000) ' SNU ',widfl(3)
CYG       write (1,10000) ' STPL ',widfl(9) ,' STPR ',widfr(9)
CYG       write (1,10000) ' SBTL ',widfl(10),' SBTR ',widfr(10)
CYG       write (1,10000) ' STAL ',widfl(12),' STAR ',widfr(12)
CYG  
CYG 10000 FORMAT(/a5,f20.10,a7,f20.10)
CYG  
CYG       call wiconst
CYG  
CYG       fma=ssmass(71)
CYG       fmb=ssmass(75)
CYG  
CYG       indx=0
CYG  
CYG       do 80 index1=1,6
CYG         do 80 index2=1,6
CYG           do 80 i1=1,18
CYG  
CYG  
CYG             brgaug(i1,index2,index1)=0.
CYG  
CYG c
CYG c products
CYG c
CYG             li1=mod(i1-1,6)+1
CYG             nc=lind(li1,index2,index1)
CYG             if(nc.eq.0)go to 80
CYG c
CYG             fmi=ssmass(70+index1)
CYG             fmk=ssmass(70+index2)
CYG  
CYG  
CYG             if(index1.le.4.and.(fmi+fma).gt.ecm)go to 80
CYG             if(index1.gt.4.and.(fmi+fmb).gt.ecm)go to 80
CYG  
CYG c
CYG c find mass of 2 fermion products
CYG c
CYG             imk1=kl(1,i1)
CYG             imk2=kl(2,i1)
CYG  
CYG             fml1=ssmass(imk1)
CYG             fml2=ssmass(imk2)
CYG  
CYG c
CYG c check whether I have enough energy to produce them
CYG c
CYG             q=fmi-fmk-fml1-fml2
CYG             if(q.le.0.)go to 80
CYG  
CYG             smin=(fml1+fml2)**2
CYG             smax=(fmi-fmk)**2
CYG  
CYG             umin=(fmk+fml2)**2
CYG             umax=(fmi-fml1)**2
CYG  
CYG             tmin=(fmk+fml1)**2
CYG             tmax=(fmi-fml2)**2
CYG  
CYG  
CYG             if(smin.ge.smax)go to 80
CYG             if(umin.ge.umax)go to 80
CYG             if(tmin.ge.tmax)go to 80
CYG  
CYG c
CYG c intermediate particles
CYG c
CYG  
CYG             fms=fmz
CYG             gw=fmz*gammaz
CYG  
CYG             if(index2.gt.4.and.index1.le.4)then
CYG               fms=fmw
CYG               gw=fmw*gammaw
CYG             endif
CYG  
CYG             if(index1.gt.4.and.index2.le.4)then
CYG               fms=fmw
CYG               gw=fmw*gammaw
CYG             endif
CYG  
CYG  
CYG             lk1= klap(1,i1)
CYG             lk2= klap(2,i1)
CYG  
CYG  
CYG             do 60 k=1,12
CYG               if(ispa(k,1).eq.lk1)then
CYG  
CYG                 fmelt=fmal(k)
CYG                 fmert=fmar(k)
CYG                 fmeltw=widfl(k)*fmelt
CYG                 fmertw=widfr(k)*fmert
CYG c
CYG c different for 3d generation because of mixing.
CYG c
CYG                 if(k.ge.9)then
CYG                   cos2=cosmi(k)**2
CYG                   sin2=1.d0-cos2
CYG                   fmelt=dsqrt(fmal(k)**2*cos2+fmar(k)*sin2)
CYG                   fmert=dsqrt(fmar(k)**2*cos2+fmal(k)*sin2)
CYG                   fmeltw=(widfl(k)*cos2+widfr(k)*sin2)*fmelt
CYG                   fmertw=(widfr(k)*cos2+widfl(k)*sin2)*fmert
CYG                 endif
CYG  
CYG               endif
CYG               if(ispa(k,1).eq.lk2)then
CYG                 fmelu=fmal(k)
CYG                 fmeru=fmar(k)
CYG                 fmeluw=widfl(k)*fmelu
CYG                 fmeruw=widfr(k)*fmeru
CYG c
CYG c different for 3d generation because of mixing.
CYG c
CYG                 if(k.ge.9)then
CYG                   cos2=cosmi(k)**2
CYG                   sin2=1.d0-cos2
CYG                   fmelu=dsqrt(fmal(k)**2*cos2+fmar(k)*sin2)
CYG                   fmeru=dsqrt(fmar(k)**2*cos2+fmal(k)*sin2)
CYG                   fmeluw=(widfl(k)*cos2+widfr(k)*sin2)*fmelu
CYG                   fmeruw=(widfr(k)*cos2+widfl(k)*sin2)*fmeru
CYG                 endif
CYG               endif
CYG  
CYG    60       continue
CYG  
CYG  
CYG             etai=xeta(index1)
CYG             etak=xeta(index2)
CYG c
CYG c decay constants
CYG c
CYG             do 70 j=1,17
CYG    70       current(j)=xdec(j,nc)
CYG  
CYG             fa1=ssdint(smin,wsc,smax)
CYG  
CYG c      call VEGAS(brodec1,0.005d0,2,5000,20,0,0,avgi1,SD1,IT1)
CYG c      call VEGAS(brodec2,0.005d0,2,5000,20,0,0,avgi2,SD2,IT2)
CYG c      call VEGAS(brodec3,0.005d0,2,5000,20,0,0,avgi3,SD3,IT3)
CYG c      avgi=avgi1+avgi2+avgi3
CYG c      if(avgi.eq.0.)go to 4
CYG c      diff=(avgi-fa1)/fa1*100.
CYG c      idiff=diff
CYG c      if(dabs(diff).gt.2.d0)then
CYG c      print *,' WARNING '
CYG c      print *,' vegas differs from analytical by ',idiff,'%'
CYG c      print *,' vegas ',avgi,it1,it2,it3
CYG c      print *,' analytical ',fa1
CYG c      print *,' decay type  ',index1,index2,i1
CYG c      endif
CYG  
CYG             brgaug(i1,index2,index1)=fa1
CYG  
CYG             if(igener.eq.0)go to 80
CYG c
CYG c prepare throwing matrix
CYG c
CYG             indx=indx+1
CYG             if(indx.gt.168)then
CYG               print *,' error more than 168 BR '
CYG               stop 99
CYG             endif
CYG  
CYG             linda(i1,index2,index1)=indx
CYG  
CYG c      gentl(1,1,indx)=smin
CYG c      gentl(2,1,indx)=smax
CYG c      gentl(1,2,indx)=umin
CYG c      gentl(2,2,indx)=umax
CYG c      do 441 li=1,50
CYG c      sb=xi(li,1)*(smax-smin)+smin
CYG c      ub=xi(li,2)*(umax-umin)+umin
CYG c      gent(li,1,indx)=sb
CYG c      gent(li,2,indx)=ub
CYG c 441  continue
CYG  
CYG             nbin1=30
CYG             nbin2=30
CYG             logvar=hexist(indx)
CYG             if(logvar)call hdelet(indx)
CYG             call hbfun2(indx,' ',nbin1,sngl(smin),sngl(smax) ,nbin2,
CYG      +      sngl(umin),sngl(umax),sbrdec)
CYG  
CYG    80 continue
CYG  
CYG  
CYG       CALL INTERF
CYG  
CYG       return
CYG       end
*CMZ :  1.00/00 14/04/95  18.39.55  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      real function sbrdec(sb,ub)
      real sb,ub
      double precision Dsb,Dub,brdec
      external brdec
      Dsb = DBLE(sb)
      Dub = DBLE(ub)
      Sbrdec = SNGL(brdec(Dsb,Dub))
      end
*CMZ :  1.00/00 14/04/95  18.39.55  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      double precision function brdec(sb,ub)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON/SDECAY/DAS,DBS,DCS,DATL,DAUL,DATUL,DASTL,DBSTL,DASUL,
     +DBSUL,DATR,DAUR,DATUR,DASTR,DBSTR,DASUR,DBSUR,xdec(17,64)
 
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
 
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
 
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
      dimension x(2)
 
 
      brdec=0.
c
c  u= charged slepton
c
      GW1 = ((SB+FML2**2-FML1**2)/(2.*DSQRT(SB))+
     +        (FMI**2-FMK**2-SB) /(2.*DSQRT(SB)))**2
      GW2 = ((SB+FML2**2-FML1**2)**2/(4.*SB)-FML2**2)
      GW3 = ((FMI**2-SB-FMK**2)**2/(4.*SB)-FMK**2)
      if(GW2.le.0..or.GW3.le.0.)return
      GW2 = DSQRT(GW2)
      GW3 = DSQRT(GW3)
      UMIN = GW1-(GW2+GW3)**2
      UMAX = GW1-(GW2-GW3)**2
      if(umin.ge.umax)return
      if(ub.le.umin.or.ub.ge.umax)return
      TB = FMI**2+FMK**2+FML1**2+FML2**2-SB-UB
 
 
c      GW1 = ((SB+FML1**2-FML2**2)/(2.*DSQRT(SB))+
c     +        (FMI**2-FMK**2-SB) /(2.*DSQRT(SB)))**2
c      GW2 = ((SB+FML1**2-FML2**2)**2/(4.*SB)-FML1**2)
c      GW3 = ((FMI**2-SB-FMK**2)**2/(4.*SB)-FMK**2)
c      if(GW2.le.0..or.GW3.le.0.)return
C      GW2 = DSQRT(GW2)
C      GW3 = DSQRT(GW3)
c      TMIN = GW1-(GW2+GW3)**2
c      TMAX = GW1-(GW2-GW3)**2
c      if(tmin.ge.tmax)return
c      if(tb.lt.tmin.or.tb.gt.tmax)return
c      UB = FMI**2+FMK**2+FML1**2+FML2**2-SB-TB
 
      fmi2=fmi**2
      fmk2=fmk**2
      sba=2.*etai*etak*fmi*fmk*sb
      tba=(fmi2-tb)*(tb-fmk2)
      uba=(fmi2-ub)*(ub-fmk2)
 
      tubal1=(tb-fmelt**2)*(ub-fmelu**2)+fmeluw*fmeltw
      subal1=(sb-fms**2)*(ub-fmelu**2)+fmeluw*gw
      tsbal1=(tb-fmelt**2)*(sb-fms**2)+fmeltw*gw
      tubar1=(tb-fmert**2)*(ub-fmeru**2)+fmertw*fmeruw
      tsbar1=(tb-fmert**2)*(sb-fms**2)+fmertw*gw
      subar1=(sb-fms**2)*(ub-fmeru**2)+fmeruw*gw
 
      tbmert=(tb-fmert**2)**2+fmertw**2
      tbmelt=(tb-fmelt**2)**2+fmeltw**2
      ubmeru=(ub-fmeru**2)**2+fmeruw**2
      ubmelu=(ub-fmelu**2)**2+fmeluw**2
      sbfms= (sb-fms**2)**2  +gw**2
 
      tubal=tbmelt*ubmelu
      subal=sbfms*ubmelu
      tsbal=sbfms*tbmelt
 
      tubar=tbmert*ubmeru
      subar=sbfms*ubmeru
      tsbar=sbfms*tbmert
 
      ws=(das*tba+dbs*uba+dcs*sba)/sbfms
      wt=datl*tba/tbmelt+datr*tba/tbmert
      wu=daul*uba/ubmelu+daur*uba/ubmeru
 
      wtu=datul*sba*tubal1/tubal
     +   +datur*sba*tubar1/tubar
      wst=(2.*dastl*tba+dbstl*sba)*tsbal1/tsbal
     +   +(2.*dastr*tba+dbstr*sba)*tsbar1/tsbar
      wsu=(2.*dasul*uba+dbsul*sba)*subal1/subal
     +   +(2.*dasur*uba+dbsur*sba)*subar1/subar
 
      brdec=ws+wt+wu+wtu+wst+wsu
 
      brdec=brdec*alpha**2/32./pi/sinw**4/fmi**3
      return
      end
*CMZ :  1.00/00 14/04/95  18.44.37  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      double precision function brodec1(x)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
 
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
 
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
      dimension x(2)
 
      brodec1=0.
 
      smin=(fml1+fml2)**2
      smax=(fmi-fmk)**2
 
      smin1=datan((smin-fms**2)/gw)
      smax1=datan((smax-fms**2)/gw)
      s=smin1+(smax1-smin1)*x(1)
      sb=fms**2+gw*dtan(s)
 
      tmin=(fmk+fml1)**2
      tmax=(fmi-fml2)**2
      if(fmert.le.fmelt)then
        fmt=fmert
        fmtw=fmertw
      else
        fmt=fmelt
        fmtw=fmeltw
      endif
 
      tmin1=datan((tmin-fmt**2)/fmtw)
      tmax1=datan((tmax-fmt**2)/fmtw)
      t=tmin1+(tmax1-tmin1)*x(2)
      tb=fmt**2+fmtw*dtan(t)
 
      BRODEC1=brdec1(sb,tb)
      sa=(smax1-smin1)*(tmax1-tmin1)
      sa=sa*(gw**2+(sb-fms**2)**2)/gw*(fmtw**2+(tb-fmt**2)**2)/fmtw
      BRODEC1=BRODEC1*sa
 
 
      return
      end
*CMZ :  1.00/00 14/04/95  18.44.37  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      double precision function brodec2(x)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
 
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
 
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
      dimension x(2)
      brodec2=0.
 
      smin=(fml1+fml2)**2
      smax=(fmi-fmk)**2
 
      smin1=datan((smin-fms**2)/gw)
      smax1=datan((smax-fms**2)/gw)
      s=smin1+(smax1-smin1)*x(1)
      sb=fms**2+gw*dtan(s)
 
      umin=(fmk+fml2)**2
      umax=(fmi-fml1)**2
      if(fmeru.le.fmelu)then
        fmu=fmeru
        fmuw=fmeruw
      else
        fmu=fmelu
        fmuw=fmeluw
      endif
      umin1=datan((umin-fmu**2)/fmuw)
      umax1=datan((umax-fmu**2)/fmuw)
      u=umin1+(umax1-umin1)*x(2)
      ub=fmu**2+fmuw*dtan(u)
 
      BRODEC2=brdec2(sb,ub)
      sa=(smax1-smin1)*(umax1-umin1)
      sa=sa*(gw**2+(sb-fms**2)**2)/gw*(fmuw**2+(ub-fmu**2)**2)/fmuw
      BRODEC2=BRODEC2*sa
 
      return
      end
*CMZ :  1.00/00 14/04/95  18.44.37  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      double precision function brodec3(x)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
 
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
 
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
      dimension x(2)
      brodec3=0.
 
      umin=(fmk+fml2)**2
      umax=(fmi-fml1)**2
      if(fmeru.le.fmelu)then
        fmu=fmeru
        fmuw=fmeruw
      else
        fmu=fmelu
        fmuw=fmeluw
      endif
      umin1=datan((umin-fmu**2)/fmuw)
      umax1=datan((umax-fmu**2)/fmuw)
      u=umin1+(umax1-umin1)*x(2)
      ub=fmu**2+fmuw*dtan(u)
 
      tmin=(fmk+fml1)**2
      tmax=(fmi-fml2)**2
      if(fmert.le.fmelt)then
        fmt=fmert
        fmtw=fmertw
      else
        fmt=fmelt
        fmtw=fmeltw
      endif
      tmin1=datan((tmin-fmt**2)/fmtw)
      tmax1=datan((tmax-fmt**2)/fmtw)
      t=tmin1+(tmax1-tmin1)*x(1)
      tb=fmt**2+fmtw*dtan(t)
 
      BRODEC3=brdec3(tb,ub)
      sa=(tmax1-tmin1)*(umax1-umin1)
      sa=sa*(fmtw**2+(tb-fmt**2)**2)/fmtw*(fmuw**2+(ub-fmu**2)**2)/fmuw
      BRODEC3=BRODEC3*sa
 
      return
      end
*CMZ :  1.00/00 14/04/95  18.39.56  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      double precision function brdec1(sb,tb)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON/SDECAY/DAS,DBS,DCS,DATL,DAUL,DATUL,DASTL,DBSTL,DASUL,
     +DBSUL,DATR,DAUR,DATUR,DASTR,DBSTR,DASUR,DBSUR,xdec(17,64)
 
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
 
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
 
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
      dimension x(2)
 
      brdec1=0.
 
      GW1 = ((SB+FML1**2-FML2**2)/(2.*DSQRT(SB))+
     +        (FMI**2-FMK**2-SB) /(2.*DSQRT(SB)))**2
      GW2 = ((SB+FML1**2-FML2**2)**2/(4.*SB)-FML1**2)
      GW3 = ((FMI**2-SB-FMK**2)**2/(4.*SB)-FMK**2)
      if(GW2.le.0..or.GW3.le.0.)return
      GW2 = DSQRT(GW2)
      GW3 = DSQRT(GW3)
      TMIN = GW1-(GW2+GW3)**2
      TMAX = GW1-(GW2-GW3)**2
      if(tmin.ge.tmax)return
      if(tb.le.tmin.or.tb.ge.tmax)return
      UB = FMI**2+FMK**2+FML1**2+FML2**2-SB-TB
 
      fmi2=fmi**2
      fmk2=fmk**2
      sba=2.*etai*etak*fmi*fmk*sb
      uba=(fmi2-ub)*(ub-fmk2)
      tba=(fmi2-tb)*(tb-fmk2)
 
      tsbal1=(tb-fmelt**2)*(sb-fms**2)+fmeltw*gw
      tsbar1=(tb-fmert**2)*(sb-fms**2)+fmertw*gw
      tbmert=(tb-fmert**2)**2+fmertw**2
      tbmelt=(tb-fmelt**2)**2+fmeltw**2
      sbfms= (sb-fms**2)**2  +gw**2
      tsbal=sbfms*tbmelt
      tsbar=sbfms*tbmert
 
      ws=(das*tba+dbs*uba+dcs*sba)/sbfms
      wt=datl*tba/tbmelt+datr*tba/tbmert
      wst=(2.*dastl*tba+dbstl*sba)*tsbal1/tsbal
     +   +(2.*dastr*tba+dbstr*sba)*tsbar1/tsbar
 
      brdec1=ws+wt+wst
      brdec1=brdec1*alpha**2/32./pi/sinw**4/fmi**3
      return
      end
*CMZ :  1.00/00 14/04/95  18.39.56  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      double precision function brdec2(sb,ub)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON/SDECAY/DAS,DBS,DCS,DATL,DAUL,DATUL,DASTL,DBSTL,DASUL,
     +DBSUL,DATR,DAUR,DATUR,DASTR,DBSTR,DASUR,DBSUR,xdec(17,64)
 
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
 
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
 
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
      dimension x(2)
 
      brdec2=0.
c
c  u= charged slepton
 
      GW1 = ((SB+FML2**2-FML1**2)/(2.*DSQRT(SB))+
     +        (FMI**2-FMK**2-SB) /(2.*DSQRT(SB)))**2
      GW2 = ((SB+FML2**2-FML1**2)**2/(4.*SB)-FML2**2)
      GW3 = ((FMI**2-SB-FMK**2)**2/(4.*SB)-FMK**2)
      if(GW2.le.0..or.GW3.le.0.)return
      GW2 = DSQRT(GW2)
      GW3 = DSQRT(GW3)
      UMIN = GW1-(GW2+GW3)**2
      UMAX = GW1-(GW2-GW3)**2
      if(umin.ge.umax)return
      if(ub.le.umin.or.ub.ge.umax)return
      TB = FMI**2+FMK**2+FML1**2+FML2**2-SB-UB
 
      fmi2=fmi**2
      fmk2=fmk**2
      sba=2.*etai*etak*fmi*fmk*sb
      tba=(fmi2-tb)*(tb-fmk2)
      uba=(fmi2-ub)*(ub-fmk2)
 
      subal1=(sb-fms**2)*(ub-fmelu**2)+fmeluw*gw
      subar1=(sb-fms**2)*(ub-fmeru**2)+fmeruw*gw
      ubmeru=(ub-fmeru**2)**2+fmeruw**2
      ubmelu=(ub-fmelu**2)**2+fmeluw**2
      sbfms= (sb-fms**2)**2  +gw**2
      subal=sbfms*ubmelu
      subar=sbfms*ubmeru
 
      wu=daul*uba/ubmelu+daur*uba/ubmeru
      wsu=(2.*dasul*uba+dbsul*sba)*subal1/subal
     +   +(2.*dasur*uba+dbsur*sba)*subar1/subar
 
      brdec2=wu+wsu
      brdec2=brdec2*alpha**2/32./pi/sinw**4/fmi**3
      return
      end
*CMZ :  1.00/00 14/04/95  18.39.56  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      double precision function brdec3(tb,ub)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON/SDECAY/DAS,DBS,DCS,DATL,DAUL,DATUL,DASTL,DBSTL,DASUL,
     +DBSUL,DATR,DAUR,DATUR,DASTR,DBSTR,DASUR,DBSUR,xdec(17,64)
 
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
 
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
 
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
      dimension x(2)
 
      brdec3=0.
c
c  u= charged slepton
c
      smin=(fml1+fml2)**2
      smax=(fmi-fmk)**2
      SB = FMI**2+FMK**2+FML1**2+FML2**2-TB-UB
      if(sb.le.smin.or.sb.ge.smax)return
 
      GW1 = ((SB+FML2**2-FML1**2)/(2.*DSQRT(SB))+
     +        (FMI**2-FMK**2-SB) /(2.*DSQRT(SB)))**2
      GW2 = ((SB+FML2**2-FML1**2)**2/(4.*SB)-FML2**2)
      GW3 = ((FMI**2-SB-FMK**2)**2/(4.*SB)-FMK**2)
      if(GW2.le.0..or.GW3.le.0.)return
      GW2 = DSQRT(GW2)
      GW3 = DSQRT(GW3)
      UMIN = GW1-(GW2+GW3)**2
      UMAX = GW1-(GW2-GW3)**2
      if(umin.ge.umax)return
      if(ub.le.umin.or.ub.ge.umax)return
 
      GW1 = ((SB+FML1**2-FML2**2)/(2.*DSQRT(SB))+
     +        (FMI**2-FMK**2-SB) /(2.*DSQRT(SB)))**2
      GW2 = ((SB+FML1**2-FML2**2)**2/(4.*SB)-FML1**2)
      GW3 = ((FMI**2-SB-FMK**2)**2/(4.*SB)-FMK**2)
      if(GW2.le.0..or.GW3.le.0.)return
      GW2 = DSQRT(GW2)
      GW3 = DSQRT(GW3)
      TMIN = GW1-(GW2+GW3)**2
      TMAX = GW1-(GW2-GW3)**2
      if(tmin.ge.tmax)return
      if(tb.le.tmin.or.tb.ge.tmax)return
 
      fmi2=fmi**2
      fmk2=fmk**2
      sba=2.*etai*etak*fmi*fmk*sb
      tba=(fmi2-tb)*(tb-fmk2)
      uba=(fmi2-ub)*(ub-fmk2)
 
      tubal1=(tb-fmelt**2)*(ub-fmelu**2)+fmeluw*fmeltw
      tubar1=(tb-fmert**2)*(ub-fmeru**2)+fmertw*fmeruw
      tbmert=(tb-fmert**2)**2+fmertw**2
      tbmelt=(tb-fmelt**2)**2+fmeltw**2
      ubmeru=(ub-fmeru**2)**2+fmeruw**2
      ubmelu=(ub-fmelu**2)**2+fmeluw**2
 
      tubal=tbmelt*ubmelu
      tubar=tbmert*ubmeru
 
      wtu=datul*sba*tubal1/tubal+datur*sba*tubar1/tubar
 
      brdec3=wtu
      brdec3=brdec3*alpha**2/32./pi/sinw**4/fmi**3
 
      return
      end
*CMZ :  1.00/00 14/04/95  18.46.25  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      SUBROUTINE WICONST
 
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
 
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
 
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
 
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)
 
 
      real*4 zr,was,esa
 
      COMMON/NEUMIX/ ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      COMMON/CHANEU/oijlp(4,2),oijrp(4,2)
 
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
 
      COMMON/SDECAY/DAS,DBS,DCS,DATL,DAUL,DATUL,DASTL,DBSTL,DASUL,
     +DBSUL,DATR,DAUR,DATUR,DASTR,DBSTR,DASUR,DBSUR,XDEC(17,64)
      DIMENSION CURRENT(17)
      EQUIVALENCE (CURRENT(1),DAS)
 
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
 
      COMMON/XCROS/xgaug(8),xeta(8)
 
      COMMON /CONST/ idbg,igener,irad
 
 
C 64 entries
C first   24 concern decays of neutralinos to neutralinos 6*4
C second  32 concern neutralinos to charginos
C last     8 concern decays of charginos to charginos
C
c
C  X0i --- > X0k Z0
C
      do 10   i=1,6
        do 10   j=1,6
          do 10   k=1,6
   10 lind(i,j,k)=0
 
      nc=0
c loop over father
      do 30 i=2,4
        k1=i-1
c loop over son
        do 30 k=1,k1
c loop over lepton kind
          do 30 l=1,4
 
            col=3.
            if(l.gt.2)col=1.
 
            nc=nc+1
            lind(l,i,k)=0
            lind(l,k,i)=nc
 
            das=col*4.*voijl(k,i)**2*(flc(l)**2+frc(l)**2)/cosw**4
            dbs=das
            dcs=das
 
            datl=col*(gfil(k,l)*gfil(i,l))**2
            daul=datl
            datul=datl
 
            datr=col*(gfir(k,l)*gfir(i,l))**2
            daur=datr
            datur=datr
 
            dastl=col*2.*gfil(k,l)*gfil(i,l)*voijl(k,i)*flc(l)/cosw**2
            dbstl=dastl
            dasul=dastl
            dbsul=dastl
 
            dastr=col*2.*gfir(k,l)*gfir(i,l)*voijr(k,i)*frc(l)/cosw**2
            dbstr=dastr
            dasur=dastr
            dbsur=dastr
 
            do 20 j=1,17
   20       xdec(j,nc)=current(j)
 
   30 continue
c
c
C  X0i --- > X+k W-
c
 
c loop over neutralinos
      do 50 i=1,4
c loop over charginos
        do 50 k=1,2
c loop over quarks/leptons
          do 50 lin=5,6
 
            fmi=xgaug(i)
            fmk=xgaug(k+4)
 
            l=1
            if(lin.eq.6)l=3
 
            col=3.
            if(l.gt.2)col=1.
 
            nc=nc+1
 
            if(xgaug(i).le.xgaug(k+4))lind(lin,i,k+4)=nc
            if(xgaug(i).gt.xgaug(k+4))lind(lin,k+4,i)=nc
 
            das=col*2.*oijlp(i,k)**2
            dbs=col*2.*oijrp(i,k)**2
            dcs=-col*2.*oijrp(i,k)*oijlp(i,k)
 
            datl=col*(gfil(i,l)*v(k,1))**2
            daul=col*(gfil(i,l+1)*u(k,1))**2
            datul=col*gfil(i,l)*gfil(i,l+1)*v(k,1)*u(k,1)
 
            datr=0.
            daur=0.
            datur=0.
 
            dastl=-dsqrt(2.d0)*col*gfil(i,l)*v(k,1)*oijlp(i,k)
            dbstl= dsqrt(2.d0)*col*gfil(i,l)*v(k,1)*oijrp(i,k)
            dasul= dsqrt(2.d0)*col*gfil(i,l+1)*u(k,1)*oijrp(i,k)
            dbsul=-dsqrt(2.d0)*col*gfil(i,l+1)*u(k,1)*oijlp(i,k)
 
            dastr=0.
            dbstr=0.
            dasur=0.
            dbsur=0.
            do 40 j=1,17
   40       xdec(j,nc)=current(j)
   50 continue
 
C
c
c  x+i --- > X+k z0
c
      i=2
      k=1
      do 70 l=1,4
        col=3.
        if(l.gt.2)col=1.
 
        up=float(mod(l,2))
        nc=nc+1
        lind(l,k+4,i+4)=nc
 
        das=col*4.*((oijl(i,k)*flc(l))**2+(oijr(i,k)*frc(l))**2)
     +  /cosw**4
        dbs=col*4.*((oijr(i,k)*flc(l))**2+(oijl(i,k)*frc(l))**2)
     +  /cosw**4
        dcs=-col*4.*(flc(l)**2+frc(l)**2)*oijl(i,k)*oijr(i,k)/cosw**4
 
        datl =col*(1.-up)*(v(k,1)*v(i,1))**2
        daul =col*up*(u(k,1)*u(i,1))**2
        datul=0.
        dastl= 2.*col*(1.-up)*v(k,1)*v(i,1)*oijl(i,k)*flc(l)/cosw**2
        dbstl=-2.*col*(1.-up)*v(k,1)*v(i,1)*oijr(i,k)*flc(l)/cosw**2
        dasul=-2.*col*up*u(k,1)*u(i,1)*oijr(i,k)*flc(l)/cosw**2
        dbsul= 2.*col*up*u(k,1)*u(i,1)*oijl(i,k)*flc(l)/cosw**2
        datr=0.
        daur=0.
        datur=0.
        dastr=0.
        dbstr=0.
        dasur=0.
        dbsur=0.
        do 60 j=1,17
   60   xdec(j,nc)=current(j)
   70 continue
c
 
 
      return
      end
*CMZ :  1.00/00 14/04/95  18.46.25  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
CYG       subroutine interf
CYG  
CYG       PARAMETER (NOUT=33)
CYG       INTEGER IDOUT(NOUT)
CYG  
CYG       SAVE /SSMODE/
CYG C          SM ( JETSET 7.03 ) ident code definitions.
CYG       INTEGER IDUP,IDDN,IDST,IDCH,IDBT,IDTP
CYG       INTEGER IDNE,IDE,IDNM,IDMU,IDNT,IDTAU
CYG       INTEGER IDGL,IDGM,IDW,IDZ
CYG  
CYG       PARAMETER (IDUP=2,IDDN=1,IDST=3,IDCH=4,IDBT=5,IDTP=6)
CYG       PARAMETER (IDNE=12,IDE=11,IDNM=14,IDMU=13,IDNT=16,IDTAU=15)
CYG       PARAMETER (IDGL=21,IDGM=22,IDW=24,IDZ=23)
CYG  
CYG       PARAMETER (ISUPL=42,ISDNL=41,ISSTL=43,ISCHL=44,ISBTL=45,ISTPL=46)
CYG       PARAMETER (ISNEL=52,ISEL=51,ISNML=54,ISMUL=53,ISNTL=56,ISTAUL=55)
CYG       PARAMETER (ISUPR=48,ISDNR=47,ISSTR=49,ISCHR=50,ISBTR=61,ISTPR=62)
CYG       PARAMETER (ISER=57,ISMUR=58,ISTAUR=59)
CYG       PARAMETER (ISGL=70)
CYG       PARAMETER (ISZ1=71,ISZ2=72,ISZ3=73,ISZ4=74,ISW1=75,ISW2=76)
CYG       PARAMETER (ISWN1=77,ISWN2=78,ISHL=25,ISHH=35,ISHA=36,ISHC=37)
CYG  
CYG       DATA IDOUT/
CYG      +ISZ1,ISZ2,ISZ3,ISZ4,ISW1,ISW2,
CYG      +ISGL,ISUPL,ISDNL,ISSTL,ISCHL,ISBTL,ISTPL,ISUPR,ISDNR,
CYG      +ISSTR,ISCHR,ISBTR,ISTPR,ISEL,ISMUL,ISTAUL,ISNEL,ISNML,ISNTL,
CYG      +ISER,ISMUR,ISTAUR,ISHL,ISHH,ISHA,ISHC,IDTP/
CYG  
CYG  
CYG C          MXSS                 = maximum number of modes
CYG C          NSSMOD               = number of modes
CYG C          ISSMOD               = initial particle
CYG C          JSSMOD               = final particles
CYG C          GSSMOD               = width
CYG C          BSSMOD               = branching ratio
CYG       INTEGER MXSS
CYG       PARAMETER (MXSS=2000)
CYG       COMMON/SSMODE/NSSMOD,ISSMOD(MXSS),JSSMOD(5,MXSS)
CYG       COMMON/SSMOD1/GSSMOD(MXSS),BSSMOD(MXSS)
CYG       INTEGER NSSMOD,ISSMOD,JSSMOD
CYG       DOUBLE PRECISION GSSMOD,BSSMOD
CYG  
CYG       double precision fms,fmi,fmk,fml1,fml2,etai,etak,brspa
CYG      +,brgaug,fmelt,fmert,fmelu,fmeru
CYG  
CYG       common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
CYG      +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
CYG  
CYG       double precision fmal,fmar,cosmi,ratqa,fgamc,fgamcr
CYG  
CYG       common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
CYG      +,cosmi(12)
CYG  
CYG  
CYG  
CYG       DOUBLE PRECISION flum,ECM,s,roots,T,Q,Q2,EN
CYG       COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
CYG  
CYG       DOUBLE PRECISION XGAUG,XETA,brtot
CYG       COMMON/XCROS/xgaug(8),xeta(8)
CYG  
CYG       common/ubra/ndeca(-80:80)
CYG       common/ubra1/brtot(2,50,-80:80)
CYG C
CYG C      brgaug(i,j,k) is the integrated branching ratios for gauginos
CYG C      i is one of the 18 patterns uu,dd,ll,vv,ud,lv x3 generations
CYG C      j is one of the son gauginos
CYG C      k is one of the father gauginos
CYG C
CYG       common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
CYG       common/decsel/idecsel(18)
CYG  
CYG       n=0
CYG       do 30 k=1,6
CYG         do 20 j=1,6
CYG           do 10 i=1,18
CYG             if(brgaug(i,j,k).eq.0)go to 10
CYG             if(i.le.18)then
CYG               if(idecsel(i).eq.0)go to 10
CYG               n=n+1
CYG               issmod(n)=70+k
CYG               jssmod(1,n)=70+j
CYG               jssmod(2,n)=-kl(2,i)
CYG               jssmod(3,n)=-kl(1,i)
CYG               if(k.eq.5.or.k.eq.6)jssmod(2,n)=kl(1,i)
CYG               if(k.eq.5.or.k.eq.6)jssmod(3,n)=kl(2,i)
CYG               gssmod(n)=brgaug(i,j,k)
CYG             endif
CYG  
CYG    10     continue
CYG    20   continue
CYG    30 continue
CYG  
CYG C
CYG C      brspa(i,j) is the integrated branching ratios for sparticles
CYG C      i is one of the 8 gaugino decays
CYG C      j are the sparticle codes 12 left + 12 right
CYG  
CYG       do 50 j=1,24
CYG         do 40 i=1,6
CYG           if(brspa(i,j).eq.0.)go to 40
CYG           n=n+1
CYG           il=mod(j-1,12)+1
CYG           kla=(j-1)/12+1
CYG           issmod(n) =ispa(il,kla)
CYG           jssmod(1,n)=70+i
CYG           jssmod(2,n)=idecs(il,1)
CYG           if(i.gt.4)jssmod(2,n)=idecs(il,2)
CYG           jssmod(3,n)=0
CYG           gssmod(n)=brspa(i,j)
CYG  
CYG    40   continue
CYG    50 continue
CYG  
CYG       nssmod=n
CYG  
CYG  
CYG       WRITE(1,10000)
CYG 10000 FORMAT(/' PARENT -->     DAUGHTERS',14X,'WIDTH (KeV) ',7X,
CYG      +'BRANCHING RATIO'/)
CYG  
CYG C          Write all modes
CYG  
CYG       DO 60  J=1,NOUT
CYG  
CYG         call ssnorm(idout(j))
CYG  
CYG         CALL SSPRT(IDOUT(J))
CYG  
CYG    60 CONTINUE
CYG  
CYG       CALL NEWSUM
CYG  
CYG c
CYG c integrate the branching ratios
CYG c
CYG       do 70  k=41,76
CYG    70 call sstot(k)
CYG  
CYG       return
CYG       end
*CMZ :  1.00/00 14/04/95  18.44.38  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
CYG       CHARACTER*5 FUNCTION SSID(ID)
CYG C-----------------------------------------------------------------------
CYG C
CYG C     Return character name for ID, assuming the default IDENT codes
CYG C     are used in /SSTYPE/.
CYG C                                      modified ISAJET
CYG C-----------------------------------------------------------------------
CYG  
CYG       common/ludat4/chaf(500)
CYG       character chaf*8
CYG  
CYG       CHARACTER*5 LABEL(-80:80)
CYG       SAVE LABEL
CYG  
CYG  
CYG       DATA LABEL(0)/'     '/
CYG  
CYG       DATA (LABEL(J),J=1,10)
CYG      +/'DN   ','UP   ','ST   ','CH   ','BT   ','TP   '
CYG      +,'ERROR','ERROR','ERROR','ERROR'/
CYG       DATA (LABEL(J),J=-1,-10,-1)
CYG      +/'DB   ','UB   ','SB   ','CB   ','BB   ','TB   '
CYG      +,'ERROR','ERROR','ERROR','ERROR'/
CYG  
CYG       DATA (LABEL(J),J=11,20)
CYG      +/'E-   ','NUE  ','MU-  ','NUM  ','TAU- ','NUT  '
CYG      +,'ERROR','ERROR','ERROR','ERROR'/
CYG       DATA (LABEL(J),J=-11,-20,-1)
CYG      +/'E+   ','ANUE ','MU+  ','ANUM ','TAU+ ','ANUT '
CYG      +,'ERROR','ERROR','ERROR','ERROR'/
CYG  
CYG       DATA (LABEL(J),J=21,30)
CYG      +/'GLUON','GAMMA','Z0   ','W+   ','H0L  ','ERROR'
CYG      +,'ERROR','ERROR','ERROR','ERROR'/
CYG       DATA (LABEL(J),J=-21,-30,-1)
CYG      +/'GLUON','GAMMA','Z0   ','W-   ','H0L  ','ERROR'
CYG      +,'ERROR','ERROR','ERROR','ERROR'/
CYG  
CYG       DATA (LABEL(J),J=31,40)
CYG      +/'ERROR','ERROR','ERROR','ERROR','H0H  ','A0   '
CYG      +,'H+   ','ERROR','ERROR','ERROR'/
CYG       DATA (LABEL(J),J=-31,-40,-1)
CYG      +/'ERROR','ERROR','ERROR','ERROR','H0H  ','A0   '
CYG      +,'H-   ','ERROR','ERROR','ERROR'/
CYG  
CYG       DATA (LABEL(J),J=41,50)
CYG      +/'DNL  ','UPL  ','STL ','CHL  ','BT1  ','TP1  '
CYG      +,'DNR  ','UPR  ','STR  ','CHR  '/
CYG       DATA (LABEL(J),J=-41,-50,-1)
CYG      +/'DNLb ','UPLb ','STLb ','CHLb ','BT1b ','TP1b '
CYG      +,'DNRb ','UPRb ','STRb ','CHRb '/
CYG  
CYG       DATA (LABEL(J),J=51,60)
CYG      +     /'EL-  ','NUEL ','MUL- ','NUML ','TAU1-','NUTL '
CYG      +     ,'ER-  ','MUR- ','TAU2-','ERROR'/
CYG       DATA (LABEL(J),J=-51,-60,-1)
CYG      +     /'EL+  ','ANUEL','MUL+ ','ANUML','TAU1+','ANUTL'
CYG      +     ,'ER+  ','MUR+ ','TAU2+','ERROR'/
CYG  
CYG       DATA (LABEL(J),J=61,70)
CYG      +/'BT2  ','TP2  ','BTL  ','TPL  ','TAUL ','BTR  '
CYG      +,'TPR  ','TAUR ','ERROR','GLSS '/
CYG       DATA (LABEL(J),J=-61,-70,-1)
CYG      +/'BT2b ','TP2b ','BTLb ','TPLb ','TAULb','BTRb '
CYG      +,'TPRb ','TAURb','ERROR','GLSS '/
CYG  
CYG       DATA (LABEL(J),J=71,80)
CYG      +/'Z1SS ','Z2SS ','Z3SS ','Z4SS ','W1SS+','W2SS+'
CYG      +,'W1SS-','W2SS-','ERROR','ERROR'/
CYG       DATA (LABEL(J),J=-71,-80,-1)
CYG      +/'Z1SS ','Z2SS ','Z3SS ','Z4SS ','W1SS-','W2SS-'
CYG      +,'W1SS+','W2SS+','ERROR','ERROR'/
CYG  
CYG       IF(IABS(ID).GT.80) THEN
CYG         WRITE(1,*) 'SSID: ID = ',ID
CYG         STOP99
CYG       ENDIF
CYG  
CYG       if(id.ne.0)then
CYG         id1=iabs(id)
CYG         chaf(id1)=label(id1)
CYG       endif
CYG  
CYG       SSID=LABEL(ID)
CYG       RETURN
CYG       END
*CMZ :  1.00/00 14/04/95  18.46.25  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      SUBROUTINE SSPRT(ID)
 
C-----------------------------------------------------------------------
C
C     Print decay modes for ID. Note these need not be contiguous,
C     so the loop is over all modes in /SSMODE/.
C
C-----------------------------------------------------------------------
 
      COMMON/SSLUN/LOUT
      INTEGER LOUT
      SAVE /SSLUN/
C          MXSS                 = maximum number of modes
C          NSSMOD               = number of modes
C          ISSMOD               = initial particle
C          JSSMOD               = final particles
C          GSSMOD               = width
C          BSSMOD               = branching ratio
      INTEGER MXSS
      PARAMETER (MXSS=2000)
      COMMON/SSMODE/NSSMOD,ISSMOD(MXSS),JSSMOD(5,MXSS)
      COMMON/SSMOD1/GSSMOD(MXSS),BSSMOD(MXSS)
      INTEGER NSSMOD,ISSMOD,JSSMOD
      DOUBLE PRECISION GSSMOD,BSSMOD
 
      DOUBLE PRECISION flum,ecm,s,roots,t,q,q2,en
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
 
      SAVE /SSMODE/
C
      INTEGER ID,I,K,NOUT
      CHARACTER*5 SSID,LBLIN,LBLOUT(3)
C
 
      widthqq=0.
      brqq=0.
      widthll=0.
      brll=0.
      widthvv=0.
      brvv=0.
      widthlv=0.
      brlv=0.
 
      NOUT=0
      DO 20  I=1,NSSMOD
        IF(iabs(ISSMOD(I)).NE.ID) GO TO 20
        NOUT=NOUT+1
        LBLIN=SSID(ISSMOD(I))
        DO 10  K=1,3
   10   LBLOUT(K)=SSID(JSSMOD(K,I))
 
c
c Gamma in KeV
c
        gssmod(i)=gssmod(i)*1000000.d0
 
CYG         WRITE(1,10000) LBLIN,(LBLOUT(K),K=1,3), GSSMOD(I),BSSMOD(I)
 
10000   FORMAT(1X,A5,'  -->  ',3(A5,2X),f20.3,f10.3)
 
   20 CONTINUE
C
CYG       IF(NOUT.GT.0) WRITE(1,*) ' '
C
      RETURN
      END
*CMZ :  1.00/00 14/04/95  18.46.25  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      subroutine newsum
 
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
 
      common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
     +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
 
      character*5 gaugi(6),signa(5)
 
      data gaugi/'Z1SS ','Z2SS ','Z3SS ','Z4SS ','W1SS ','W2SS '/
      DATA SIGNA/'QQBAR','L+L- ','VVBAR','L+-V ',' QQP '/
 
      common/brsum/ brsum(5,6,6),brsuma(6)
 
      do 10 k1=1,6
        do 10 k2=1,6
          do 10 k3=1,5
   10 brsum(k3,k2,k1)=0.
 
 
      do 60 l1=1,6
        brsuma(l1)=0.
 
        do 30 l2=1,6
          do 20 l3=1,18
            l4=mod(l3-1,6)+1
            if(l4.eq.1.or.l4.eq.2)l5=3
            if(l4.eq.3)l5=2
            if(l4.eq.4)l5=1
            if(l4.eq.6)l5=4
            if(l4.eq.5)l5=5
 
            fact=1.
            if(l2.gt.4.and.l4.gt.4)fact=2.
 
            brsum(l5,l2,l1)=brsum(l5,l2,l1)+brgaug(l3,l2,l1)*fact
            brsuma(l1)=brsuma(l1)+brgaug(l3,l2,l1)*fact
 
   20     continue
   30   continue
 
        if(brsuma(l1).gt.0.)then
          do 50 l2=1,6
            do 40 l5=1,5
              brsum(l5,l2,l1)=brsum(l5,l2,l1)/brsuma(l1)
   40       continue
   50     continue
        endif
 
   60 continue
 
CYG       WRITE (1,10200)' SIGNA ',signa
 
      DO 70 L1=2,6
 
CYG         WRITE (1,10100) GAUGI(L1)
 
        DO 70 L2=1,6
          stum= BRSUM(1,l2,L1)+BRSUM(2,l2,L1)+BRSUM(3,l2,L1)+BRSUM(4,
     +    l2,L1) +BRSUM(5,L2,L1)
          if(stum.ne.0.)then
CYG             WRITE(1,10000) GAUGI(l2), BRSUM(1,l2,L1),BRSUM(2,l2,L1),
CYG      +      BRSUM(3,l2,L1),BRSUM(4,l2,L1), BRSUM(5,L2,L1)
10000 FORMAT(A7,5F7.3)
          endif
   70 continue
 
10100 FORMAT('DECAYS OF ',A7)
10200 FORMAT(6A7)
 
      return
      end
*CMZ :  1.00/00 14/04/95  18.46.25  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      SUBROUTINE SSTOT(ID)
 
C-----------------------------------------------------------------------
C
C     Integrate decay modes for ID.
C     Fill array ndeca(80),brtot(2,50,80) with integrated decay modes
C     ndeca(j) is the number of possible decays for sparticle j
C     brtot(1,i,j) indicates the pointer to ssmode
C     brtot(2,i,j) indicates the integrated branching fraction
C     i loops over possible decays
C     j loops over sparticles
C-----------------------------------------------------------------------
 
c      SAVE /SSLUN/
C          MXSS                 = maximum number of modes
C          NSSMOD               = number of modes
C          ISSMOD               = initial particle
C          JSSMOD               = final particles
C          GSSMOD               = width
C          BSSMOD               = branching ratio
      INTEGER MXSS
      PARAMETER (MXSS=2000)
      COMMON/SSMODE/NSSMOD,ISSMOD(MXSS),JSSMOD(5,MXSS)
      COMMON/SSMOD1/GSSMOD(MXSS),BSSMOD(MXSS)
      INTEGER NSSMOD,ISSMOD,JSSMOD
      DOUBLE PRECISION GSSMOD,BSSMOD
      SAVE /SSMODE/
C
      DOUBLE PRECISION brtot
      common/ubra/ndeca(-80:80)
      common/ubra1/brtot(2,50,-80:80)
C
C  carefull we assume that particles are contained within  80
C
      kd=iabs(id)
CYG       if(kd.lt.1.or.kd.gt.80) write(1,*) ' error in SSTOT '
 
      brtot(1,1,id)=0
      brtot(2,1,id)=0
 
      NOUT=0
      DO 10  I=1,NSSMOD
        IF(iabs(ISSMOD(I)).NE.ID) GO TO 10
 
        nout=nout+1
        brtot(1,nout,id)=i
 
        if(nout.eq.1)then
          brtot(2,1,id)=bssmod(i)
        else
          brtot(2,nout,id)=bssmod(i)+brtot(2,nout-1,id)
        endif
 
   10 CONTINUE
 
      ndeca(id)=nout
 
      RETURN
      END
*CMZ :  1.00/00 14/04/95  18.44.38  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      double precision function SSMASS(IDA)
C-----------------------------------------------------------------------
C          Give mass  for ID
C-----------------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
 
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)
 
 
      real*4 zr,was,esa
 
      COMMON/NEUMIX/ ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
 
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      COMMON/CHANEU/oijlp(4,2),oijrp(4,2)
 
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
 
      double precision m0,m2,mu,tgb,delalf,ma,mtop,mlh,mhh,mhpm
      COMMON/PARMS/M0,M2,MU,TGB,MTOP,DELALF,MA
      COMMON/HMASS/MLH,MHH,MHPM
 
      common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
 
      ssmass=-1.
 
      id=iabs(ida)
 
      if(id.lt.40)then
c      PARAMETER (IDUP=2,IDDN=1,IDST=3,IDCH=4,IDBT=5,IDTP=6)
        if(id.eq.1)ssmass=gms(2)
        if(id.eq.2)ssmass=gms(1)
        if(id.eq.3)ssmass=gms(6)
        if(id.eq.4)ssmass=gms(5)
        if(id.eq.5)ssmass=gms(10)
        if(id.eq.6)ssmass=gms(9)
c      PARAMETER (IDNE=12,IDE=11,IDNM=14,IDMU=13,IDNT=16,IDTAU=15)
        if(id.eq.11)ssmass=gms(4)
        if(id.eq.12)ssmass=gms(3)
        if(id.eq.13)ssmass=gms(8)
        if(id.eq.14)ssmass=gms(7)
        if(id.eq.15)ssmass=gms(12)
        if(id.eq.16)ssmass=gms(11)
c      PARAMETER (IDGL=21,IDGM=22,IDW=24,IDZ=23)
        if(id.eq.21)ssmass=0.
        if(id.eq.22)ssmass=0.
        if(id.eq.23)ssmass=fmz
        if(id.eq.24)ssmass=fmw
c
c higgses
c
c      PARAMETER (ISHL=25,ISHH=35,ISHA=36,ISHC=37)
        if(id.eq.25)ssmass=mlh
        if(id.eq.35)ssmass=mhh
        if(id.eq.36)ssmass=ma
        if(id.eq.37)ssmass=mhpm
      else
 
c      PARAMETER (ISGL=70)
        if(id.eq.70)ssmass=was(1)/0.303
c      PARAMETER (ISZ1=71,ISZ2=72,ISZ3=73,ISZ4=74,ISW1=75,ISW2=76)
        if(id.ge.71.and.id.le.74)then
          ssmass=was(id-70)
          return
        endif
 
c      PARAMETER (ISW1=75,ISW2=76,ISWN1=77,ISWN2=78)
        if(id.eq.77)id=75
        if(id.eq.78)id=76
        if(id.ge.75.and.id.le.76)then
          ssmass=FM(id-74)
          return
        endif
 
        if(id.gt.40.and.id.lt.70)then
 
c      PARAMETER (ISUPL=42,ISDNL=41,ISSTL=43,ISCHL=44,ISBTL=45,ISTPL=46)
          if(id.eq.41)ssmass=fmal(2)
          if(id.eq.42)ssmass=fmal(1)
          if(id.eq.43)ssmass=fmal(6)
          if(id.eq.44)ssmass=fmal(5)
          if(id.eq.45)ssmass=fmal(10)
          if(id.eq.46)ssmass=fmal(9)
c      PARAMETER (ISUPR=48,ISDNR=47,ISSTR=49,ISCHR=50)
          if(id.eq.47)ssmass=fmar(2)
          if(id.eq.48)ssmass=fmar(1)
          if(id.eq.49)ssmass=fmar(6)
          if(id.eq.50)ssmass=fmar(5)
 
c      PARAMETER (ISNEL=52,ISEL=51,ISNML=54,ISMUL=53,ISNTL=56,ISTAUL=55)
          if(id.eq.51)ssmass=fmal(4)
          if(id.eq.52)ssmass=fmal(3)
          if(id.eq.53)ssmass=fmal(8)
          if(id.eq.54)ssmass=fmal(7)
          if(id.eq.55)ssmass=fmal(12)
          if(id.eq.56)ssmass=fmal(11)
 
c      PARAMETER (ISER=57,ISMUR=58,ISTAUR=59)
          if(id.eq.57)ssmass=fmar(4)
          if(id.eq.58)ssmass=fmar(8)
          if(id.eq.59)ssmass=fmar(12)
 
c      PARAMETER (ISBTR=61,ISTPR=62)
          if(id.eq.61)ssmass=fmar(10)
          if(id.eq.62)ssmass=fmar(9)
 
 
        endif
 
      endif
 
 
CYG       if(ssmass.lt.0.)write(1,*) ' error in ssmass  unknown code ',ida
 
      RETURN
      END
*CMZ :  1.00/00 14/04/95  18.46.26  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      SUBROUTINE SSNORM(ID)
C-----------------------------------------------------------------------
C          Normalize branching ratios for ID
C                                      modified ISAJET
C-----------------------------------------------------------------------
      IMPLICIT NONE
      COMMON/SSLUN/LOUT
      INTEGER LOUT
      SAVE /SSLUN/
C          MXSS                 = maximum number of modes
C          NSSMOD               = number of modes
C          ISSMOD               = initial particle
C          JSSMOD               = final particles
C          GSSMOD               = width
C          BSSMOD               = branching ratio
      INTEGER MXSS
      PARAMETER (MXSS=2000)
      COMMON/SSMODE/NSSMOD,ISSMOD(MXSS),JSSMOD(5,MXSS)
      COMMON/SSMOD1/GSSMOD(MXSS),BSSMOD(MXSS)
      INTEGER NSSMOD,ISSMOD,JSSMOD
      DOUBLE PRECISION GSSMOD,BSSMOD
      SAVE /SSMODE/
C
      INTEGER ID,I
      REAL GAMSUM
C
      GAMSUM=0
      DO 10  I=1,NSSMOD
        IF(ISSMOD(I).EQ.ID) GAMSUM=GAMSUM+GSSMOD(I)
   10 CONTINUE
      IF(GAMSUM.EQ.0) RETURN
      DO 20  I=1,NSSMOD
        IF(ISSMOD(I).EQ.ID) BSSMOD(I)=GSSMOD(I)/GAMSUM
   20 CONTINUE
      RETURN
      END
*CMZ :  1.00/00 14/04/95  18.46.26  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
CYG       SUBROUTINE mssm_gene
CYG  
CYG       IMPLICIT DOUBLE PRECISION (A-H,O-Z)
CYG  
CYG  
CYG       COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
CYG       COMMON/INDEXX/index,index1,index2,nevt
CYG       COMMON/FINDEX/fmpr1,fmpr2,XCROST,APRO
CYG  
CYG  
CYG       COMMON/ISR/ QK(4)
CYG       COMMON /CONST/ idbg,igener,irad
CYG  
CYG       real erad,srad
CYG       common/srada/erad(100),srad(100)
CYG       logical wrt,scan,lepi
CYG       common/str/wrt,scan,lepi
CYG  
CYG       external gensel,gensmu,gensnue,gensnu,photi
CYG  
CYG       common/kev/jev
CYG C
CYG C       MAXIMUM OF  PRODUCTION, UNIFORM STEP SAMPLING
CYG C
CYG       if(nevt.lt.1)return
CYG  
CYG       if(irad.eq.1)then
CYG         STEP = 2.
CYG         NSORT =ecm/step
CYG         ZSLEPT = 0.
CYG         DO 10 J=1,NSORT
CYG           ZSLEPT = ZSLEPT+STEP
CYG           s=zslept**2
CYG           roots=dsqrt(s)
CYG           if(index.eq.1)amplit=photi(index1,index2)
CYG           if(index.eq.2)amplit=chargi(index1,index2)
CYG           if(index.eq.3)then
CYG             IF(INDEX1.EQ.51.or.index1.eq.57)then
CYG               if(index1.eq.-index2)amplit=ssdint(-1.d0,gensel,1.d0)
CYG               if(index1.ne.-index2)amplit=genselrs(dummy)
CYG             elseif(index1.eq.52)then
CYG               amplit=ssdint(-1.d0,gensnue,1.d0)
CYG             elseif(index1.eq.54.or.index1.eq.56)then
CYG               amplit=ssdint(-1.d0,gensnu,1.d0)
CYG             else
CYG               amplit=gensmus(dummy)
CYG             endif
CYG           endif
CYG           erad(j)=real(roots)
CYG           srad(j)=real(amplit)
CYG           if(srad(j).ne.0.)write(1,10000) erad(j),srad(j)
CYG 10000 format('  ECM =  ',f10.3,'  CROSS SECTION =  ',f10.3)
CYG    10   CONTINUE
CYG       endif
CYG  
CYG  
CYG       s=ecm**2
CYG  
CYG       nfail=0
CYG  
CYG       DO 30 JEV=1,NEVT
CYG  
CYG    20   continue
CYG  
CYG         CALL suseve(ifail)
CYG  
CYG         if(ifail.eq.1)then
CYG           nfail=nfail+1
CYG           if(nfail.gt.1000)then
CYG             print *,' warning nfail = ',nfail,' event = ',jev
CYG             print *,' ********  Event skipped  ******** '
CYG             nfail=0
CYG             goto 30
CYG           endif
CYG           go to 20
CYG         endif
CYG  
CYG c
CYG c
CYG c write Lund common LUJETS to LUNIT
CYG c
CYG         if(wrt) CALL SXWRLU(12)
CYG  
CYG         call user
CYG  
CYG    30 CONTINUE
CYG  
CYG  
CYG       RETURN
CYG       END
*CMZ :  1.00/00 14/04/95  18.39.57  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      subroutine user
      COMMON/LUJETS/N,K(4000,5),P(4000,5),V(4000,5)
      COMMON/INDEXX/index,index1,index2,nevt
      dimension sum(4)
      return
      end
*CMZ :  1.00/00 14/04/95  18.46.26  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      DOUBLE PRECISION FUNCTION PHOTI(IN1,IN2)
C********************************************************************
C production cross section for neutralinos
C                                         author S.Katsanevas
C********************************************************************
 
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
 
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
 
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
 
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)
 
 
      real*4 zr,was,esa
 
      COMMON/NEUMIX/ ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
 
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
 
      i1=iabs(in1)-70
      i2=iabs(in2)-70
 
      PHOTI=0.
      DIJ=1.
      FMEL=FMAL(4)
      FMER=FMAR(4)
      IF(I1.NE.I2)DIJ=0.
      Q2=(S-(WAS(I1)+WAS(I2))**2)
      IF(Q2.LE.0)RETURN
      Q2=(S-(WAS(I1)+WAS(I2))**2)*(S-(WAS(I1)-WAS(I2))**2)/4.D0/S
      Q=DSQRT(Q2)
      EN(1)=DSQRT(Q2+WAS(I1)**2)
      EN(2)=DSQRT(Q2+WAS(I2)**2)
C
C phase space
C
      DL=(S+2.D0*FMEL**2-WAS(I1)**2-WAS(I2)**2)/2.D0/S
      DR=(S+2.D0*FMER**2-WAS(I1)**2-WAS(I2)**2)/2.D0/S
 
      DLA=DL-Q/ROOTS
      DRA=DR-Q/ROOTS
      IF(DLA.eq.0.)DLA=0.00001
      IF(DRA.eq.0.)DRA=0.00001
      AL=DLOG(ABS((DL+Q/ROOTS)/DLA))
      AR=DLOG(ABS((DR+Q/ROOTS)/DRA))
 
      GAM=(EN(1)*EN(2)+Q2/3.D0-esa(i1)*esa(i2)*WAS(I1)*WAS(I2))
      GAML=1.D0-2.D0*DL-esa(i1)*esa(i2)*WAS(I1)*WAS(I2)/S/DL
      GAMR=1.D0-2.D0*DR-esa(i1)*esa(i2)*WAS(I1)*WAS(I2)/S/DR
C
C propagators
C
      DZ2=1.D0/((S-FMZ**2)**2+FMZ**2*GAMMAZ**2)
      REDZ=(S-FMZ**2)*DZ2
C
C couplings
C
      FLE=FLC(4)
      FRE=FRC(4)
      CLR=FLE**2+FRE**2
C
C z propagator
C
      SIZ=G2**2*DZ2/4.D0/PI/COSW**4*Q/ROOTS
      SZ=SIZ*VOIJL(I1,I2)**2*CLR*GAM*0.389D+9
C
C sel propagator
C
      SDLA=S*DL**2-Q2
      SDRA=S*DR**2-Q2
      if(SDLA.EQ.0)SDLA=0.0001
      if(SDRA.EQ.0)SDRA=0.0001
 
      SEL=G2**2/16.D0/PI*Q/S/ROOTS
      A1=(EN(1)*EN(2)-S*DL+Q2)/SDLA+2.D0+ROOTS/2.D0/Q*GAML*AL
      A2=(EN(1)*EN(2)-S*DR+Q2)/SDRA+2.D0+ROOTS/2.D0/Q*GAMR*AR
      S1=(A1*gFIL(I1,4)**2*gFIL(I2,4)**2+A2*gFIR(I1,4)**2*gFIR(I2,4)**2)
      SEL=SEL*s1*0.389D+9
C
C z-sel interference
C
      SZSEL=-G2**2/8.D0/PI/COSW**2*Q/ROOTS*REDZ*VOIJL(I1,I2)
      A1=((EN(1)*EN(2)-S*DL*(1.D0-DL)-esa(i1)*esa(i2)*WAS(I1)*WAS(I2))
     +*AL/Q/ROOTS+2.D0*(1.-DL))*FLE*gFIL(I1,4)*gFIL(I2,4)
      A2=((EN(1)*EN(2)-S*DR*(1.D0-DR)-esa(i1)*esa(i2)*WAS(I1)*WAS(I2))
     +*AR/Q/ROOTS+2.D0*(1.-DR))*FRE*gFIR(I1,4)*gFIR(I2,4)
      SZSEL=SZSEL*(A1-A2)*0.389D+9
C
C total
C
C      write (6,*) ' z      neutralino ',sz
C      write (6,*) ' snu    neutralino ',sel
C      write (6,*) ' z-snu  neutralino ',szsel
 
      PHOTI=(SZ+SEL+SZSEL)/2.D0*(2.D0-DIJ)
 
      if(photi.lt.0.)then
        write (6,10000) photi
10000 FORMAT(1X,' ERROR in photi cross section ',f8.2)
        photi=0.
      endif
 
      RETURN
      END
*CMZ :  1.00/00 14/04/95  18.39.57  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      DOUBLE PRECISION FUNCTION GENPHO(IN1,IN2,COSTHE)
C********************************************************************
C production cross section ds/dcostheta for neutralinos
C                                         author S.Katsanevas
C********************************************************************
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
 
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
 
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)
 
 
      real*4 zr,was,esa
 
      COMMON/NEUMIX/ ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
 
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
 
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
 
      i1=iabs(in1)-70
      i2=iabs(in2)-70
 
      GENPHO=0.
      DIJ=1.
      FMEL=FMAL(4)
      FMER=FMAR(4)
      IF(I1.NE.I2)DIJ=0.
      Q2=(S-(WAS(I1)+WAS(I2))**2)
      IF(Q2.LE.0)RETURN
      Q2=(S-(WAS(I1)+WAS(I2))**2)*(S-(WAS(I1)-WAS(I2))**2)/4.D0/S
      Q=DSQRT(Q2)
      EN(1)=DSQRT(Q2+WAS(I1)**2)
      EN(2)=DSQRT(Q2+WAS(I2)**2)
C
C calculation of t,u
 
      T=WAS(I1)**2-ROOTS*(EN(1)-Q*COSTHE)
      UMAN=WAS(I1)**2+WAS(I2)**2-S-T
C
C phase space
C
      SGU=(WAS(I1)**2-UMAN)*(WAS(I2)**2-UMAN)
      SGT=(WAS(I1)**2-T)*(WAS(I2)**2-T)
      SGS=ESA(I1)*ESA(I2)*was(I1)*was(I2)*S
C
C propagators
C
      DZ2=1.D0/((S-FMZ**2)**2+FMZ**2*GAMMAZ**2)
      REDZ=(S-FMZ**2)*DZ2
 
      DSELT1=(T-FMEL**2)
      DSELU1=(UMAN-FMEL**2)
      DSERT1=(T-FMER**2)
      DSERU1=(UMAN-FMER**2)
 
      DSELT=1.D0/DSELT1
      DSELU=1.D0/DSELU1
      DSERT=1.D0/DSERT1
      DSERU=1.D0/DSERU1
C
C couplings
C
      FLE=FLC(4)
      FRE=FRC(4)
      CLR=FLE**2+FRE**2
 
C
C z propagator
C
C
      CONZ=G2**2*DZ2/16.D0/PI/COSW**4/S**2
      SZ=CONZ*VOIJL(I1,I2)**2*CLR*0.389D+9*(SGT+SGU-2.D0*SGS)
C
C sel propagator
C
      CONSEL=G2**2/64.D0/PI/S**2
      A1=gFIL(I1,4)**2*gFIL(I2,4)**2*(DSELT**2*SGT+DSELU**2*SGU-
     +2.D0*DSELT*DSELU*SGS)
      A2=gFIR(I1,4)**2*gFIR(I2,4)**2*(DSERT**2*SGT+DSERU**2*SGU-
     +2.D0*DSERT*DSERU*SGS)
      SEL=CONSEL*0.389D+9*(A1+A2)
C
C z-sel interference
C
      CONSZ=G2**2/16.D0/PI/COSW**2/S**2*REDZ*VOIJL(I1,I2)
      A1=FLE*gFIL(I1,4)*gFIL(I2,4)*(DSELT*(SGT-SGS)+DSELU*(SGU-SGS))
      A2=FRE*gFIR(I1,4)*gFIR(I2,4)*(DSERT*(SGT-SGS)+DSERU*(SGU-SGS))
      SZSEL=CONSZ*(A1-A2)*0.389D+9
C
C total
C
      GENPHO=(SZ+SEL+SZSEL)/2.D0*(2.D0-DIJ)*ROOTS*Q
 
      IF(GENPHO.LT.0.)GENPHO=0.
 
      RETURN
      END
*CMZ :  1.00/00 14/04/95  18.46.26  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      DOUBLE PRECISION FUNCTION CHARGI(IN1,IN2)
C********************************************************************
C production cross section for charginos
C                                         author S.Katsanevas
C********************************************************************
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
 
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
 
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
 
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)
 
 
      real*4 zr,was,esa
 
      COMMON/NEUMIX/ ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
 
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
 
      i1=iabs(in1)-74
      i2=iabs(in2)-74
 
      CHARGI=0.
      DIJ=1.
 
      FMNU=FMAL(3)
 
      IF(I1.NE.I2)DIJ=0.
      Q2=(S-(FM(I1)+FM(I2))**2)
      if(Q2.LE.0.)return
      Q2=(S-(FM(I1)+FM(I2))**2)*(S-(FM(I1)-FM(I2))**2)/4.D0/S
      Q=DSQRT(Q2)
      EN(1)=DSQRT(Q2+FM(I1)**2)
      EN(2)=DSQRT(Q2+FM(I2)**2)
C
C phase space
C
      AL=(2.D0*FMNU**2+S-FM(I1)**2-FM(I2)**2)/2.D0/FMNU**2
      BL=Q*ROOTS/FMNU**2
      ALBL=Al-BL
      IF(ALBL.EQ.0)ALBL=0.00001
      AR=DLOG(ABS((AL+BL)/ALBL))
      H=2.D0*Q*ROOTS-2.D0*Q2*AL/BL+
     +  (EN(1)*EN(2)+Q2*AL**2/BL**2-Q*ROOTS*AL/BL)*AR
      GAM=(EN(1)*EN(2)+Q2/3.D0+FM(I1)*FM(I2))
C
C propagators
C
      DZ2=1.D0/((S-FMZ**2)**2+FMZ**2*GAMMAZ**2)
      REDZ=(S-FMZ**2)*DZ2
 
C
C z propagator
C
C
      CONZ=G2**2*DZ2/8.D0/PI/COSW**4*Q/ROOTS
      FLE=FLC(4)
      FRE=FRC(4)
      CLR=FLE**2+FRE**2
      A1=(OIJL(I1,I2)**2+OIJR(I1,I2)**2)*CLR*(EN(1)*EN(2)+Q2/3.D0)
      A2=2.D0*OIJL(I1,I2)*OIJR(I1,I2)*CLR*ETA(I1)*ETA(I2)*FM(I1)*FM(I2)
      SZ=CONZ*(A1+A2)*0.389D+9
C
C gamma propagator
C
      SG=E2**2/2.D0/PI*Q*ROOTS/S**3*DIJ*GAM*0.389D+9
C
C snu propagator
C
      CONU=G2**2*V(I1,1)**2*V(I2,1)**2/32.D0/PI/FMNU**4*Q/ROOTS
      A1=(EN(1)*EN(2)+Q2-Q*ROOTS*AL/BL)/(AL**2-BL**2)+2.D0*Q2/BL**2
      A2=(Q*ROOTS-2.D0*Q2*AL/BL)*AR/2.D0/BL**2
      SNU=CONU*(A1+A2)*0.389D+9
C
C gamma-z interference
C
      SGZ=E2*G2/4.D0/PI/COSW**2*Q*ROOTS/S**2*REDZ*DIJ*(FLE+FRE)*GAM*
     +(OIJL(I1,I2)+OIJR(I1,I2))*0.389D+9
C
C gamma-snu interference
C
      COSG=-E2*G2*V(I1,1)**2/16.D0/PI*DIJ/S**2*(H+FM(I1)*FM(I2)*AR)
      SGSNU=COSG*0.389D+9
C
C z-snu interference
C
      COSZS=-G2**2*V(I1,1)*V(I2,1)/16.D0/PI/COSW**2*REDZ/S*FLE
      A1=OIJL(I1,I2)*H+OIJR(I1,I2)*ETA(I1)*ETA(I2)*FM(I1)*FM(I2)*AR
      SZSNU=COSZS*A1*0.389D+9
C
C total
C
C      write (6,*) ' gamma    chargino ',sg
C      write (6,*) ' z         chargino ',sz
C      write (6,*) ' snu       chargino ',snu
C      write (6,*) ' gamma-z   chargino ',sgz
C      write (6,*) ' gamma-snu chargino ',sgsnu
C      write (6,*) ' z-snu      chargino ',szsnu
 
      CHARGI=(SG+SZ+SNU+SGZ+SGSNU+SZSNU)
 
      if(chargi.lt.0.)then
        write (6,10000) chargi
10000 FORMAT(1X,' ERROR in chargi cross section ',f8.2)
        chargi=0.
      endif
 
      RETURN
      END
*CMZ :  1.00/00 14/04/95  18.39.57  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      DOUBLE PRECISION FUNCTION GENCHAR(IL1,IL2,COSTHE)
C********************************************************************
C production cross section ds/dcostheta for charginos
C                                         author S.Katsanevas
C********************************************************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
 
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
 
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
 
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)
 
 
      real*4 zr,was,esa
 
      COMMON/NEUMIX/ ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
 
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
 
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
 
 
      I1=iabs(IL1)-74
      I2=iabs(IL2)-74
 
      GENCHAR=0.
      DIJ=1.
      FMNU=FMAL(3)
 
      IF(I1.NE.I2)DIJ=0.
      Q2=(S-(FM(I1)+FM(I2))**2)
      if(Q2.LE.0.)return
      Q2=(S-(FM(I1)+FM(I2))**2)*(S-(FM(I1)-FM(I2))**2)/4.D0/S
      IF(Q2.LE.0.)RETURN
      Q=DSQRT(Q2)
      EN(1)=DSQRT(Q2+FM(I1)**2)
      EN(2)=DSQRT(Q2+FM(I2)**2)
 
C
C calculation of t,u
 
      T=FM(I1)**2-ROOTS*(EN(1)-Q*COSTHE)
      UMAN=FM(I1)**2+FM(I2)**2-S-T
C
C phase space
C
      SGU=(FM(I1)**2-UMAN)*(FM(I2)**2-UMAN)
      SGT=(FM(I1)**2-T)*(FM(I2)**2-T)
      SGS=ETA(I1)*ETA(I2)*FM(I1)*FM(I2)*S
 
C
C propagators
C
      DZ2=1.D0/((S-FMZ**2)**2+FMZ**2*GAMMAZ**2)
      DNU1=T-FMNU**2
      IF(DNU1.EQ.0)DNU1=0.00001D0
      DNU=1./DNU1
      REDZ=(S-FMZ**2)*DZ2
 
C
C couplings
C
      FLE=FLC(4)
      FRE=FRC(4)
      CLR =FLE**2+FRE**2
      CLR1=FLE**2-FRE**2
 
C
C
C gamma propagator
C
 
 
      SG=E2**2/8.D0/PI/S**4*DIJ*0.389D+9*(SGU+SGT+2.D0*SGS)
 
C
C
C z propagator
C
C
      CONZ=G2**2*DZ2/32.D0/PI/COSW**4/S**2
      A1=(OIJL(I1,I2)**2+OIJR(I1,I2)**2)*CLR*(SGU+SGT)
      A2=4.D0*OIJL(I1,I2)*OIJR(I1,I2)*CLR*SGS
      A3=-(OIJL(I1,I2)**2-OIJR(I1,I2)**2)*CLR1*(SGU-SGT)
      SZ=CONZ*(A1+A2+A3)*0.389D+9
 
C snu propagator
C
      SNU=G2**2*V(I1,1)**2*V(I2,1)**2*DNU**2/64.D0/PI/S**2*SGT
     +*0.389D+9
C
C gamma-z interference
C
      A1=(FLE+FRE)*(OIJL(I1,I2)+OIJR(I1,I2))*(SGU+SGT+2.D0*SGS)
      A2=-(FLE-FRE)*(OIJL(I1,I2)-OIJR(I1,I2))*(SGU-SGT)
      SGZ=E2*G2/16.D0/PI/COSW**2/S**3*REDZ*DIJ*0.389D+9*(A1+A2)
C
C gamma-snu interference
C
      SGSNU=E2*G2*DNU*V(I1,1)**2/16.D0/PI*DIJ/S**3*0.389D+9*
     +(SGT+SGS)
C
C z-snu interference
C
      COZNU=G2**2*V(I1,1)*V(I2,1)/16.D0/PI/COSW**2*REDZ*DNU/S**2
      A1=OIJL(I1,I2)*SGT+OIJR(I1,I2)*SGS
      SZSNU=COZNU*A1*0.389D+9*FLE
 
C
C total
C
      GENCHAR=(SG+SZ+SNU+SGZ+SGSNU+SZSNU)*ROOTS*Q
 
      if(GENCHAR.lt.0.)GENCHAR=0.
 
      RETURN
      END
*CMZ :  1.00/00 14/04/95  18.46.26  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      DOUBLE PRECISION FUNCTION GENSEL(COSTHE)
C********************************************************************
C production cross section for selectrons
C                                         author S.Katsanevas
C********************************************************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
 
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
 
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
 
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)
 
      real*4 zr,was,esa
 
      COMMON/NEUMIX/ ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
 
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
 
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
 
      DIMENSION DK(4),dk1(4)
 
      common/mixings/cosphi,facqcd,fgam,selm,ratq
C
C cosphimix = 1  left
C cosphimix = 0  right
C
 
      GENSEL=0.
      FLE=FLC(4)
      FRE=FRC(4)
 
      Q2=(S-4.D0*SELM**2)/4.D0
      IF(Q2.LE.0.)RETURN
      Q=DSQRT(Q2)
      EN(1)=DSQRT(Q2+SELM**2)
      EN(2)=DSQRT(Q2+SELM**2)
 
      sinphi=dsqrt(1.d0-cosphi**2)
C
C calculation of t,u
 
      T=SELM**2-ROOTS*(EN(1)-Q*COSTHE)
      UMAN=2.D0*SELM**2-S-T
C
C phase space
C
      SGUT=(UMAN*T-SELM**4)
C
C propagators
C
      DZ2=1.D0/((S-FMZ**2)**2+FMZ**2*GAMMAZ**2)
      REDZ=(S-FMZ**2)*DZ2
 
 
      DSUMR=0.
      DSUML=0.
      DSUMLR=0.
      DMONSTR=0.
      DSUMLRA=0.
      DO 20 K=1,4
 
        DK1(K)=(T-WAS(K)**2)
 
        if(dk1(k).eq.0.)THEN
          dk1(k)=0.001
        ENDIF
 
        DK(K)=1.D0/dk1(k)
        DSUMR=DSUMR+DK(K)*gFIR(k,4)**2
        DSUML=DSUML+DK(K)*gFIL(k,4)**2
        DSUMLR=DSUMLR+
     +    DK(K)*(COSPHI**2*gFIL(k,4)**2+SINPHI**2*gFIR(k,4)**2)
        DSUMLRA=DSUMLRA+DK(K)*
     +  (FLE*COSPHI**2*gFIL(k,4)**2+FRE*SINPHI**2*gFIR(k,4)**2)
 
        DO 10 L=1,4
          DMONSTR=DMONSTR+Was(K)*Was(L)*esa(k)*esa(l)
     + *DK(K)*DK(L)*gFIR(k,4)*gFIL(k,4)*gFIR(l,4)*gFIL(l,4)
   10   CONTINUE
 
   20 CONTINUE
 
 
C
C couplings
C
 
      CLR =FLE**2+FRE**2
 
C
C
C gamma propagator
C
C
      SG=E2**2/8.D0/PI/S**4*SGUT*0.389D+9
C
C z propagator
C
      SZ=G2**2/16.D0/PI/S**2/COSW**4*SGUT*DZ2*CLR*FGAM**2*0.389D+9
C
C gamma-z interference
C
      SGZ=E2*G2/8.D0/PI/S**3/COSW**2*SGUT*FGAM*(FLE+FRE)*
     +REDZ*0.389D+9
C
C neutralino propagator
C
      SCHI=G2**2/64.D0/PI/S**2*
     +(SGUT*(COSPHI**4*DSUML**2+SINPHI**4*DSUMR**2)
     ++2.D0*SINPHI**2*COSPHI**2*S*DMONSTR)*0.389D+9
C
C gamma-neutralino
C
      SGCHI=E2*G2/16.D0/PI/S**3*SGUT*DSUMLR*0.389D+9
C
C  z - neutralino
C
      SZCHI=G2**2/16.D0/PI/S**2/COSW**2*SGUT*FGAM*REDZ*DSUMLRA*
     +0.389D+9
C
C total
C
      SS=SZ+SG+SGZ
 
C      write (6,*) ' s channel    selec     ',ss
C      write (6,*) ' chargino     selec     ',schi
C      write (6,*) ' charg-gam    selec     ',sgchi
C      write (6,*) ' charg-z      selec     ',szchi
 
      GENSEL=(SG+SZ+SCHI+SGZ+SGCHI+SZCHI)*ROOTS*Q
      iF(GENSEL.LT.0.)GENSEL=0.
 
      RETURN
      END
*CMZ :  1.00/00 14/04/95  18.46.26  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      DOUBLE PRECISION FUNCTION GENSELR(COSTHE)
 
C********************************************************************
C production cross section for selectrons (left +right)
C                                         author S.Katsanevas
C********************************************************************
 
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
 
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
 
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
 
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)
 
      real*4 zr,was,esa
 
      COMMON/NEUMIX/ ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
 
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
 
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
 
      DIMENSION DK(4),dk1(4)
 
      common/mixings/cosphi,facqcd,fgam,selm,ratq
C
C cosphimix = 1  left
C cosphimix = 0  right
C
 
      GENSELR=0.
      XPCM   = XLAMDA (s,fmal(4)**2,fmar(4)**2)/ (2. * roots)
      IF(XPCM.LE.0.)RETURN
 
      Q=XPCM
 
      EN(1)=DSQRT(XPCM**2+fmal(4)**2)
      EN(2)=DSQRT(XPCM**2+fmar(4)**2)
 
C
C calculation of t
C
      T=fmal(4)**2-ROOTS*(EN(1)-xpcm*COSTHE)
      DMONSTR1=0.
      DO 20 K=1,4
        DK1(K)=(T-WAS(K)**2)
        if(dk1(k).eq.0.)THEN
          dk1(k)=0.001
        ENDIF
        DK(K)=1.D0/dk1(k)
        DO 10 L=1,4
          DMONSTR1=DMONSTR1+Was(K)*Was(L)*esa(k)*esa(l)
     + *DK(K)*DK(L)*gFIR(k,4)*gFIL(k,4)*gFIR(l,4)*gFIL(l,4)
   10   CONTINUE
   20 CONTINUE
 
      T=fmar(4)**2-ROOTS*(EN(2)-xpcm*COSTHE)
      DMONSTR2=0.
      DO 40 K=1,4
        DK1(K)=(T-WAS(K)**2)
        if(dk1(k).eq.0.)THEN
          dk1(k)=0.001
        ENDIF
        DK(K)=1.D0/dk1(k)
        DO 30 L=1,4
          DMONSTR2=DMONSTR2+Was(K)*Was(L)*esa(k)*esa(l)
     + *DK(K)*DK(L)*gFIR(k,4)*gFIL(k,4)*gFIR(l,4)*gFIL(l,4)
   30   CONTINUE
   40 CONTINUE
 
      dmonstr=dmonstr1+dmonstr2
 
      genselr=G2**2/64.D0/PI/S**2*S*DMONSTR*0.389D+9
      GENSELR=genselr*ROOTS*Q
      iF(GENSELR.LT.0.)GENSELR=0.
 
      RETURN
      END
*CMZ :  1.00/00 14/04/95  18.46.26  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      DOUBLE PRECISION FUNCTION GENSELRS(dummy)
 
C********************************************************************
C production cross section for selectrons (left +right)
C                                         author S.Katsanevas
C********************************************************************
 
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
 
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
 
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
 
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)
 
      real*4 zr,was,esa
 
      COMMON/NEUMIX/ ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
 
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
 
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
 
      DIMENSION DK(4),dk1(4)
 
      common/mixings/cosphi,facqcd,fgam,selm,ratq
C
C cosphimix = 1  left
C cosphimix = 0  right
C
 
      GENSELRS=0.
      XPCM   = XLAMDA (s,fmal(4)**2,fmar(4)**2)/ (2. * roots)
      IF(XPCM.LE.0.)RETURN
 
      EN(1)=DSQRT(XPCM**2+fmal(4)**2)
      EN(2)=DSQRT(XPCM**2+fmar(4)**2)
 
C
C calculation of t
C
 
      TMIN1=fmal(4)**2-ROOTS*(EN(1)+xpcm)
      TMIN2=fmar(4)**2-ROOTS*(EN(2)+xpcm)
 
      TMax1=fmal(4)**2-ROOTS*(EN(1)-xpcm)
      TMax2=fmar(4)**2-ROOTS*(EN(2)-xpcm)
 
      DMONSTR1=0.
      DO 20 K=1,4
        dmonstr1=dmonstr1+Was(K)**2*gFIR(k,4)**2*gFIL(k,4)**2 *(tmax1-
     +  tmin1)/(tmin1-was(k)**2)/(tmax1-was(k)**2)
        DO 10 L=1,4
          if(k.eq.l)go to 10
          dm=was(k)**2-was(l)**2
          if(dm.eq.0.)go to 10
          dmonstr1=dmonstr1+Was(K)*Was(L)*esa(k)*esa(l) *gFIR(k,4)*
     +    gFIL(k,4)*gFIR(l,4)*gFIL(l,4) *dlog( (tmax1-was(k)**2)*
     +    (tmin1-was(l)**2) /(tmin1-was(k)**2)/(tmax1-was(l)**2) )/dm
   10   CONTINUE
   20 CONTINUE
 
      DMONSTR2=0.
      DO 40 K=1,4
        dmonstr2=dmonstr2+Was(K)**2*gFIR(k,4)**2*gFIL(k,4)**2 *(tmax2-
     +  tmin2)/(tmin2-was(k)**2)/(tmax2-was(k)**2)
        DO 30 L=1,4
          if(k.eq.l)go to 30
          dm=was(k)**2-was(l)**2
          if(dm.eq.0.)go to 30
          dmonstr2=dmonstr2+Was(K)*Was(L)*esa(k)*esa(l) *gFIR(k,4)*
     +    gFIL(k,4)*gFIR(l,4)*gFIL(l,4) *dlog( (tmax2-was(k)**2)*
     +    (tmin2-was(l)**2) /(tmin2-was(k)**2)/(tmax2-was(l)**2) )/dm
   30   CONTINUE
   40 CONTINUE
 
      dmonstr=dmonstr1+dmonstr2
 
      genselrs=G2**2/64.D0/PI/S**2*S*DMONSTR*0.389D+9
      iF(GENSELRs.LT.0.)GENSELRs=0.
 
      RETURN
      END
*CMZ :  1.00/00 14/04/95  18.44.39  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      DOUBLE PRECISION FUNCTION GENSMU(COSTHE)
C********************************************************************
C production cross section for smuons
C                                         author S.Katsanevas
C********************************************************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
 
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
 
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
 
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)
 
 
      real*4 zr,was,esa
 
      COMMON/NEUMIX/ ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
 
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
 
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
 
 
      common/mixings/cosphi,facqcd,fgam,selm,ratq
 
      xlam=.270d0
      alphas = alfas(s,xlam,5)
      alphaem= alfaem(s)
 
      E2=4.D0*PI*ALPHAEM
      G2=E2/SINW**2
 
 
      GENSMU=0.
 
      costhe=-1.+2.*costhe
 
      BETA = 1.d0 - (4.d0*selm**2 /s)
      IF( BETA .LE. 0. ) THEN
        RETURN
      ELSE
        BETA = DSQRT( BETA )
      ENDIF
 
 
      Q2=(S-4.D0*SELM**2)/4.D0
      IF(Q2.LE.0.)RETURN
      Q=DSQRT(Q2)
 
      EN(1)=DSQRT(Q2+SELM**2)
      EN(2)=DSQRT(Q2+SELM**2)
 
C calculation of t,u
 
      T=SELM**2-ROOTS*(EN(1)-Q*COSTHE)
 
      UMAN=2.D0*SELM**2-S-T
 
C
C phase space
C
      SGUT=(UMAN*T-SELM**4)
C
C propagators
C
      DZ2=1.D0/((S-FMZ**2)**2+FMZ**2*GAMMAZ**2)
      REDZ=(S-FMZ**2)*DZ2
C
C couplings
C
      FLE=FLC(4)
      FRE=FRC(4)
      CLR =FLE**2+FRE**2
 
C
C gamma propagator
C
      SG=ratq**2*E2**2/8.D0/PI/S**4*SGUT*0.389D+9
C
C z propagator
C
      SZ=G2**2/16.D0/PI/S**2/COSW**4*SGUT*DZ2*CLR*
     +FGAM**2*0.389D+9
C
C
C gamma-z interference
C
 
      SGZ=ratq*E2*G2/8.D0/PI/S**3/COSW**2*SGUT*FGAM*(FLE+FRE)*
     +REDZ*0.389D+9
C
C total
C
C      write (6,*) ' z      smuon     ',sz
C      write (6,*) ' gam    smuon     ',sg
C      write (6,*) ' z-gam  smuon     ',sgz
 
      if(facqcd.eq.1.d0)then
        F = PI**2 / (2.d0*BETA) - (1.d0+BETA )*(PI**2/2.-3.d0)/2.d0
        FQCD = 1.d0 + (4.d0*ALPHAS/(3.d0*PI))*F
        phase = 3.d0 * FQCD
        GENSMU=(SG+SZ+SGZ)*phase
      else
        GENSMU=SG+SZ+SGZ
      endif
 
      GENSMU=(SG+SZ+SGZ)*ROOTS*Q*2.
 
      iF(GENSMU.LT.0.)GENSMU=0.
 
      RETURN
      END
*CMZ :  1.00/00 14/04/95  18.44.39  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      DOUBLE PRECISION FUNCTION GENSMUS(dummy)
C********************************************************************
C production cross section for smuons
C                                         author S.Katsanevas
C********************************************************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
 
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
 
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
 
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)
 
 
      real*4 zr,was,esa
 
      COMMON/NEUMIX/ ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
 
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
 
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
 
 
      common/mixings/cosphi,facqcd,fgam,selm,ratq
 
 
      xlam=.270d0
      alphas = alfas(s,xlam,5)
      alphaem= alfaem(s)
 
      E2=4.D0*PI*ALPHAEM
      G2=E2/SINW**2
 
      GENSMUS=0.
 
      BETA = 1.d0 - (4.d0*selm**2 /s)
      IF( BETA .LE. 0. ) THEN
        RETURN
      ELSE
        BETA = DSQRT( BETA )
      ENDIF
 
      SGUT=BETA**3*S**3/6.D0
 
C
C propagators
C
      DZ2=1.D0/((S-FMZ**2)**2+FMZ**2*GAMMAZ**2)
      REDZ=(S-FMZ**2)*DZ2
C
C couplings
C
      FLE=FLC(4)
      FRE=FRC(4)
      CLR =FLE**2+FRE**2
 
      SCON=E2**2/8.D0/PI/S**4*SGUT*0.389D+9
C
C gamma propagator
C
      SG=SCON*ratq**2
C
C z propagator
C
      SZ=SCON*S**2*DZ2*CLR*FGAM**2/2.D0/SINW**4/COSW**4
C
C
C gamma-z interference
C
 
      SGZ=SCON*ratq*S*REDZ*FGAM*(FLE+FRE)/SINW**2/COSW**2
 
C
C total
C
C      write (6,*) ' z      smuon     ',sz
C      write (6,*) ' gam    smuon     ',sg
C      write (6,*) ' z-gam  smuon     ',sgz
 
      if(facqcd.eq.1.d0)then
        F = PI**2 / (2.d0*BETA) - (1.d0+BETA )*(PI**2/2.-3.d0)/2.d0
        FQCD = 1.d0 + (4.d0*ALPHAS/(3.d0*PI))*F
        phase = 3.d0 * FQCD
        GENSMUS=(SG+SZ+SGZ)*phase
      else
        GENSMUS=SG+SZ+SGZ
      endif
 
      iF(GENSMUS.LT.0.)GENSMUS=0.
 
      RETURN
      END
*CMZ :  1.00/00 14/04/95  18.39.58  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      function alfas(q2,xlam,inf)
      implicit real*8 (a-h,o-z)
      data olam/0.d0/,pi/3.14159d0/
      data xmb/5.d0/,xmc/1.5d0/
      if(xlam.ne.olam) then
        olam = xlam
        b5  = (33-2*5)/pi/12
        bp5 = (153 - 19*5) / pi / 2 / (33 - 2*5)
        b4  = (33-2*4)/pi/12
        bp4 = (153 - 19*4) / pi / 2 / (33 - 2*4)
        b3  = (33-2*3)/pi/12
        bp3 = (153 - 19*3) / pi / 2 / (33 - 2*3)
        xlc = 2 * log(xmc/xlam)
        xlb = 2 * log(xmb/xlam)
        xllc = log(xlc)
        xllb = log(xlb)
        c45  =  1/( 1/(b5 * xlb) - xllb*bp5/(b5 * xlb)**2 )
     #        - 1/( 1/(b4 * xlb) - xllb*bp4/(b4 * xlb)**2 )
        c35  =  1/( 1/(b4 * xlc) - xllc*bp4/(b4 * xlc)**2 )
     #        - 1/( 1/(b3 * xlc) - xllc*bp3/(b3 * xlc)**2 ) + c45
      endif
      q   = sqrt(q2)
      xlq = 2 * log( q/xlam )
      xllq = log( xlq )
      nf = inf
      if( nf .lt. 0) then
        if( q .gt. xmb ) then
          nf = 5
        elseif( q .gt. xmc ) then
          nf = 4
        else
          nf = 3
        endif
      endif
      if    ( nf .eq. 5 ) then
        alfas = 1/(b5 * xlq) -  bp5/(b5 * xlq)**2 * xllq
      elseif( nf .eq. 4 ) then
        alfas = 1/( 1/(1/(b4 * xlq) - bp4/(b4 * xlq)**2 * xllq) + c45 )
      elseif( nf .eq. 3 ) then
        alfas = 1/( 1/(1/(b3 * xlq) - bp3/(b3 * xlq)**2 * xllq) + c35 )
      else
        print *,'error in alfa: unimplemented # of light flavours',nf
        stop
      endif
      return
      end
*CMZ :  1.00/00 14/04/95  18.39.58  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      function alfaem(q2)
      implicit real*8 (a-z)
      data zm/91.19d0/,ooaz/128.87d0/,pi/3.14159d0/
      nc=3
      xlq = log(q2/zm**2)
      b = 3 + 3*nc*(1d0/3d0)**2 + 2*nc*(2d0/3d0)**2
      ooa = ooaz - 2d0/3d0/pi * b * xlq
      alfaem = 1/ooa
      end
*CMZ :  1.00/00 14/04/95  18.46.26  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      DOUBLE PRECISION FUNCTION GENSNUE(COSTHE)
C********************************************************************
C
C production cross section for snues
C
C                                         author S.Katsanevas
C********************************************************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
 
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
 
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
 
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)
 
      real*4 zr,was,esa
 
      COMMON/NEUMIX/ ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
 
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
      DIMENSION DK(2),dk1(2)
 
C
      GENSNUE=0
 
      FMNU=FMAL(3)
 
      Q2=(S-4.D0*FMNU**2)/4.D0
 
      IF(Q2.LE.0.)RETURN
      Q=DSQRT(Q2)
      EN(1)=DSQRT(Q2+FMNU**2)
      EN(2)=DSQRT(Q2+FMNU**2)
 
C
C calculation of t,u
 
      T=FMNU**2-ROOTS*(EN(1)-Q*COSTHE)
 
      UMAN=2.D0*FMNU**2-S-T
C
C phase space
C
      SGUT=(UMAN*T-FMNU**4)
C
C propagators
C
      DZ2=1.D0/((S-FMZ**2)**2+FMZ**2*GAMMAZ**2)
      REDZ=(S-FMZ**2)*DZ2
      DSUM=0.
      DO 10 K=1,2
        DK1(K)=(T-FM(K)**2)
        if(dk1(k).eq.0.)dk1(k)=0.001
        DK(K)=1.D0/dk1(k)
        DSUM=DSUM+DK(K)*V(K,1)**2
   10 CONTINUE
 
C
C z propagator
C
      FLE=FLC(4)
      FRE=FRC(4)
      CLR =FLE**2+FRE**2
 
      CON=G2**2/64.D0/PI/S**2*SGUT*0.389D+9
 
      SZ=CON*DZ2*CLR/COSW**4
C
C chargino propagator
C
      SCHI=CON*DSUM**2
C
C chargino-z interference
C
      SCHZ=CON*REDZ*DSUM*2.d0*FLE/COSW**2
C
C total
C
 
C      write (6,*) ' z           snu ',sz
C      write (6,*) ' chargino    snu ',schi
C      write (6,*) ' z-chargino  snu ',schz
 
      GENSNUE=(SZ+SCHI+SCHZ)*ROOTS*Q
 
      iF(GENSNUE.LT.0.)GENSNUE=0.
 
      RETURN
      END
*CMZ :  1.00/00 14/04/95  18.39.58  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      DOUBLE PRECISION FUNCTION GENSNU(COSTHE)
C********************************************************************
C
C production cross section for snus
C
C                                         author S.Katsanevas
C********************************************************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
 
      COMMON/MSSM/TANB,SINB,COSB,FMGAUG,FMR,FM0,ATRI
      common/spartcl/fmal(12),fmar(12),ratqa(12),fgamc(12),fgamcr(12)
     +,cosmi(12)
 
      real*4 zr,was,esa
 
      COMMON/NEUMIX/ ZR(4,4),was(4),ESA(4),
     +VOIJL(4,4),VOIJR(4,4),gfir(4,4),gfil(4,4)
      COMMON/CHAMIX/ OIJL(2,2),OIJR(2,2),V(2,2),U(2,2),FM(2),ETA(2)
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
 
 
C
C attention force mass of nu
C
 
      GENSNU=0.
 
      FMNU=FMAL(3)
 
      Q2=(S-4.D0*FMNU**2)/4.D0
      IF(Q2.LE.0.)RETURN
      Q=DSQRT(Q2)
      EN(1)=DSQRT(Q2+FMNU**2)
      EN(2)=DSQRT(Q2+FMNU**2)
 
C
C calculation of t,u
 
      T=FMNU**2-ROOTS*(EN(1)-Q*COSTHE)
      UMAN=2.D0*FMNU**2-S-T
C
C phase space
C
      SGUT=(UMAN*T-FMNU**4)
C
C propagators
C
      DZ2=1.D0/((S-FMZ**2)**2+FMZ**2*GAMMAZ**2)
      REDZ=(S-FMZ**2)*DZ2
 
C
C z propagator
C
      FLE=FLC(4)
      FRE=FRC(4)
      CLR =FLE**2+FRE**2
 
      CON=G2**2/64.D0/PI/S**2*SGUT*0.389D+9
 
      SZ=CON*DZ2*CLR/COSW**4
 
      GENSNU=SZ*ROOTS*Q
      iF(GENSNU.LT.0.)GENSNU=0.
 
      RETURN
      END
*CMZ :  1.00/00 14/04/95  18.46.26  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      SUBROUTINE suseve(ifail)
 
C----------------------------------------------------------------------
C-
C-   GENERATE AN EVENT
C-
 
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      COMMON/INDEXX/index,index1,index2,nevt
      COMMON/FINDEX/fmpr1,fmpr2,XCROST,APRO
 
 
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
 
 
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
 
      COMMON/XCROS/xgaug(8),xeta(8)
 
      REAL*4 RNDM
 
      real*4 amp1
 
      integer*4 lindex(3)
 
      COMMON /PARTC / PV(5,20),IFLAV(20,2),NFLAV
 
      COMMON/ISR/ QK(4)
 
      CHARACTER*5 LBLIN,SSID
 
      COMMON /CONST/ idbg,igener,irad
 
      real as,radfun,ampl,hrndm1
      external ampl
 
      ifail=1
 
      ntry=0
 
   10 continue
 
C...Generate event with radiative photon.
      IF(IRAD.EQ.1) THEN
        CALL REMT2(QK)
        E=ecm/2.D0
        s=ecm**2*(1.-QK(4)/E)
        ROOTS=DSQRT(S)
      ELSE
C...Generate event without radiative photon.
        s=ECM**2
        ROOTS=ECM
        QK(1) = 0.0000D0
        QK(2) = 0.0000D0
        QK(3) = 0.0001D0
        QK(4) = 0.0001D0
      ENDIF
 
      IFLAG=0
      nflav=0
 
      XPCM   = XLAMDA (roots**2,fmpr1**2,fmpr2**2)/ (2. * roots)
 
      ntry=ntry+1
      if(ntry.gt.10000)then
CYG         write(1,*) ' more than 10000 tries in REMT2 loop '
        return
      endif
      if(xpcm.eq.0..and.irad.eq.1)go to 10
c
c generate ds/dcostheta
c
      call hbfun1(9999,' ',50,-1.,1.,ampl)
      cthcm=hrndm1(9999)
      call hdelet(9999)
 
      PHCM  = TWOPI * dble(RNDM(0))
      STHCM = DSQRT( 1. - CTHCM**2 )
      CPHCM = DCOS( PHCM )
      SPHCM = DSIN( PHCM )
 
      CALL sdecay2 ( XPCM,CTHCM,PHCM,fmpr1,PV(1,1))
 
      lblin=ssid(index1)
 
      IFLAV(1,1)=INDEX1
      IFLAV(1,2)=0
 
      nflav=nflav+1
C
C     Here the three body decay of the FIRST product is generated.
C
 
      NC1=1
 
      LINDEX1=INDEX1
 
 
   20 continue
 
      call decabr(lindex1,nbod,lindex,adeca)
 
      if(nbod.ne.1)then
 
        if(nbod.eq.3)then
 
          CALL smbod3(PV(1,nc1),lindex1,PV(1,nc1+1),PV(1,nc1+2),PV(1,
     +    nc1+3),lindex,adeca,kfail)
          if(kfail.eq.1)return
        endif
 
        if(nbod.eq.2)then
          CALL smbod2(PV(1,nc1),lindex1,PV(1,nc1+1),PV(1,nc1+2),
     +    lindex,kfail)
          if(kfail.eq.1)return
        endif
        nflav=nflav+nbod
        do 30 k=1,nbod
          lblin=ssid(LINDEX(K))
          IFLAV(nc1+k,1)=lindex(k)
          IFLAV(nc1+k,2)=nc1
   30   continue
        nc1=nc1+nbod
        lindex1=lindex(nbod)
c
c cascade the decays
c
        go to 20
 
      endif
 
      nc1=nc1+1
      nflav=nflav+1
      CALL sdecay2 (-XPCM,CTHCM,PHCM,fmpr2,PV(1,nc1))
 
      lblin=ssid(index2)
 
      IFLAV(nc1,1)=INDEX2
      IFLAV(nc1,2)=0
 
      LINDEX2=INDEX2
 
   40 continue
 
      call decabr(lindex2,nbod,lindex,adeca)
 
 
      if(nbod.ne.1)then
 
 
        if(nbod.eq.3)then
          CALL smbod3(PV(1,nc1),lindex2,PV(1,nc1+1),PV(1,nc1+2),PV(1,
     +    nc1+3),lindex,adeca,kfail)
          if(kfail.eq.1)return
        endif
 
        if(nbod.eq.2)then
          CALL smbod2(PV(1,nc1),lindex2,PV(1,nc1+1),PV(1,nc1+2),
     +    lindex,kfail)
          if(kfail.eq.1)return
        endif
 
        nflav=nflav+nbod
        do 50 k=1,nbod
          lblin=ssid(LINDEX(K))
          IFLAV(nc1+k,1)=lindex(k)
          IFLAV(nc1+k,2)=nc1
   50   continue
 
        nc1=nc1+nbod
        lindex2=lindex(nbod)
c
c cascade the decays
c
        go to 40
 
      endif
 
      IF(IRAD.EQ.1.and.qk(4).gt.0.001)THEN
        do 60  lp=1,3
   60   qk(lp)=-qk(lp)
 
        do 70  k=1,nflav
          CALL REMT3(QK,PV(1,k),PV(1,k))
   70   continue
 
        nflav=nflav+1
 
        do 80 k=1,4
   80   pv(k,nflav)=qk(k)
 
        pv(5,nflav)=0.
 
        iflav(nflav,1)=22
        iflav(nflav,2)=0
 
      ENDIF
 
      call sfragment(ifail)
 
 
      END
*CMZ :  1.00/00 14/04/95  18.44.39  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      real function ampl(cthcm)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      REAL CTHCM
      COMMON/INDEXX/index,index1,index2,nevt
      DCTHCM=CTHCM
      if(index.eq.1)AMP   = GENPHO(index1,index2,DCTHCM)
      if(index.eq.2)AMP   = GENCHAR(index1,index2,DCTHCM)
      if(index.eq.3)then
        IF(INDEX1.EQ.51.or.index1.eq.57)then
          if(index1.eq.-index2)AMP = GENSEL(DCTHCM)
          if(index1.ne.-index2)AMP = GENSELR(DCTHCM)
        elseif(index1.eq.52)then
          AMP = GENSNUE(DCTHCM)
        elseif(index1.eq.54.or.index1.eq.56)then
          AMP = GENSNU(DCTHCM)
        else
          AMP = GENSMU(DCTHCM)
        endif
      endif
      ampl=amp
      return
      end
*CMZ :  1.00/00 14/04/95  18.39.58  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      function radfun(s)
      common/srada/erad(100),srad(100)
      radfun=divdif(srad,erad,100,s,1)
      if(radfun.lt.0.)radfun=0.
      return
      end
*CMZ :  1.00/00 14/04/95  18.46.27  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      SUBROUTINE DECABR(lindex1,nbod,lindex2,adeca)
C
C randomly generates a gaugino or spaticle decay to a nbod=1,2,3 mode
C nbod=1 means no decay
C lindex2 contains the decay particles list
C
 
C          MXSS                 = maximum number of modes
C          NSSMOD               = number of modes
C          ISSMOD               = initial particle
C          JSSMOD               = final particles
C          GSSMOD               = width
C          BSSMOD               = branching ratio
      INTEGER MXSS
      PARAMETER (MXSS=2000)
 
      COMMON/SSMODE/NSSMOD,ISSMOD(MXSS),JSSMOD(5,MXSS)
      COMMON/SSMOD1/GSSMOD(MXSS),BSSMOD(MXSS)
      INTEGER NSSMOD,ISSMOD,JSSMOD
      DOUBLE PRECISION GSSMOD,BSSMOD
      integer*4 kindex(3),lindex2(3)
      real fm(3)
 
      DOUBLE PRECISION brtot,adeca
      common/ubra/ndeca(-80:80)
      common/ubra1/brtot(2,50,-80:80)
 
      call vzero(lindex2,3)
      kin=0
 
      mindex1=iabs(lindex1)
 
      if(mindex1.lt.1.or.mindex1.gt.80)then
CYG         write(1,*)' error in lindex1 in decabr ',mindex1
        stop99
      endif
 
      nbod=1
      nm=ndeca(mindex1)
      lindex2(1)=lindex1
      if(nm.lt.1)return
 
      CHAN=RNDM(0)*brtot(2,nm,mindex1)
 
      do 10 j=1,nm
        if(chan.lt.brtot(2,j,mindex1))go to 20
   10 continue
   20 continue
 
      index=brtot(1,j,mindex1)
 
CYG      if(issmod(index).ne.mindex1)
CYG      +write(1,*)' error lindex1/issmod in decabr ',issmod(index),mindex1
 
 
      adeca=brtot(2,j,mindex1)
 
      nbod=3
      call ucopy(jssmod(1,index),kindex,3)
      if(kindex(3).eq.0)nbod=2
 
      kferm=0
      do 40 k=1,nbod
        if(iabs(kindex(k)).gt.40)go to 30
        kferm=kferm+1
        fm(kferm)=ssmass(kindex(k))
        lindex2(kferm)=kindex(k)
        if(lindex1.lt.0)lindex2(kferm)=-kindex(k)
        go to 40
   30   kin=k
   40 continue
 
      fm(kferm+1)=ssmass(kindex(kin))
      lindex2(kferm+1)=kindex(kin)
      if(lindex1.lt.0)lindex2(kferm+1)=-kindex(kin)
 
      RETURN
      END
*CMZ :  1.00/00 14/04/95  18.39.59  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      SUBROUTINE smbod2(pin,indin,p1,p2,lindex2,ifail)
 
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
 
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
 
      DIMENSION BETA(3)
      DOUBLE PRECISION pin(5),p1(5),p2(5)
      real rndm
 
      integer lindex2(3)
 
C
C attention top decays to s
C
      ifail=1
 
      selema=ssmass(indin)
      FMASS  =ssMASS(lindex2(1))
      fmk=ssmass(lindex2(2))
 
      XPS1 = XLAMDA (SELEMA**2,FMASS**2,fmk**2) / (2. * SELEMA)
 
      if(xps1.le.0)return
 
      PHCM    = TWOPI*dble(RNDM(0))
      CTHCM   =-1.+2.*dble(RNDM(0))
      STHCM   = dsqrt(1.-cthcm**2)
 
      p1(1)=xps1*sthcm*cos(phcm)
      p1(2)=xps1*sthcm*sin(phcm)
      p1(3)=xps1*cthcm
      p1(4)=dsqrt(xps1**2+fmass**2)
      p1(5)=fmass
      p2(1)=-p1(1)
      p2(2)=-p1(2)
      p2(3)=-p1(3)
      p2(4)=dsqrt(xps1**2+fmk**2)
      p2(5)=fmk
 
C
C         BOOST THE ELECTRONS 4-MOMENTA
C
      BETA(1) = Pin(1) / Pin(4)
      BETA(2) = Pin(2) / Pin(4)
      BETA(3) = Pin(3) / Pin(4)
      CALL BOOSTSUSY (P1,BETA)
      CALL BOOSTSUSY (P2,BETA)
 
      ifail=0
 
      return
      END
*CMZ :  1.00/00 14/04/95  18.46.27  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      SUBROUTINE smbod3(PIN,indin,PP1,PP2,PP3,IND,adeca,ifail)
*
C****************   IT GENERATES THREE BODY DECAY
*
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
 
      COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
     +FLC(12),FRC(12),gms(12),echar(12)
 
      integer ind(3)
      DOUBLE PRECISION BETA(3)
      DOUBLE PRECISION PIN(5),P1(5),P2(5),P3(5)
      DOUBLE PRECISION        PP1(5),PP2(5),PP3(5)
      DOUBLE PRECISION adeca
 
      common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
     +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
      real*4 rndm,rsb,rub
 
      dimension z(2)
 
      common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
 
c
c s = the W*,Z* combination
c t = the up combination
c u = the down combination
c
      ifail=1
 
      fmi=ssmass(indin)
      fml1=ssmass(ind(1))
      fml2=ssmass(ind(2))
      fmk=ssmass(ind(3))
c
c translete back codes to kfcur
c
      index1=iabs(indin)-70
      k1=iabs(ind(1))
      k2=iabs(ind(2))
      index2=iabs(ind(3))-70
 
 
      do 10 kfcur=1,18
        ik1=iabs(kl(1,kfcur))
        ik2=iabs(kl(2,kfcur))
        if((k1.eq.ik1.and.k2.eq.ik2).or. (k1.eq.ik2.and.k2.eq.ik1))go
     +  to 20
   10 continue
   20 continue
 
 
 
      ntry=0
   30 continue
 
      ntry=ntry+1
      if(ntry.gt.1000)then
CYG         write (1,*) ' Warning > 1000 in smbod3 '
        return
      endif
 
      if(kfcur.gt.18)then
CYG         write(1,*)' error in branch logic kf ',kfcur,indin,ind(3)
CYG         write(1,*)' error in branch logic kf ',ind(1),ind(2)
        stop99
      endif
 
      indx=linda(kfcur,index2,index1)
 
c      call  gveg(z,gent(1,1,indx),gentl(1,1,indx))
c      sb=z(1)
c      ub=z(2)
 
 
      call hrndm2(indx,rsb,rub)
      sb=dble(rsb)
      ub=dble(rub)
 
c
c  u= charged slepton
c
      GW1 = ((SB+FML2**2-FML1**2)/(2.*DSQRT(SB))+
     +        (FMI**2-FMK**2-SB) /(2.*DSQRT(SB)))**2
      GW2 = ((SB+FML2**2-FML1**2)**2/(4.*SB)-FML2**2)
      GW3 = ((FMI**2-SB-FMK**2)**2/(4.*SB)-FMK**2)
      if(GW2.le.0..or.GW3.le.0)go to 30
      GW2 = DSQRT(GW2)
      GW3 = DSQRT(GW3)
      UMIN = GW1-(GW2+GW3)**2
      UMAX = GW1-(GW2-GW3)**2
      if(umin.ge.umax)go to 30
      if(ub.lt.umin.or.ub.gt.umax)go to 30
 
*
      TB=FMI**2+FMK**2+fml1**2+fml2**2-SB-UB
 
      P1(4)=(FMI**2+fml1**2-UB)/2./fmi
      P2(4)=(FMI**2+fml2**2-TB)/2./fmi
*
      C12    = fmi**2-fmk**2-2.*fmi*(P1(4)+P2(4))
      C12    = .5*C12/(P1(4)*P2(4))+1.
      IF(ABS(C12).GT.1.)GO TO 30
      CT1    = -1.+2.*dble(RNDM(0))
      FI2    = TWOPI*dble(RNDM(0))
 
      CF2    = COS(FI2)
      SF2    = SIN(FI2)
      ST1    = SQRT(1.D0-CT1**2)
      S12    = SQRT(1.D0-C12**2)
      PP=(P1(4)**2-fml1**2)
 
      IF(PP.LT.0.)GO TO 30
      PP=SQRT(PP)
      P1(1)  = PP*ST1
      P1(2)  = 0.0
      P1(3)  = PP*CT1
      P1(5)  = fml1
C
      PP=(P2(4)**2-fml2**2)
      IF(PP.LT.0.)GO TO 30
      PP=SQRT(PP)
      P2(1)  = PP*(S12*CF2*CT1+C12*ST1)
      P2(2)  = PP*S12*SF2
      P2(3)  = PP*(C12*CT1-S12*CF2*ST1)
      P2(5)  = fml2
C
      P3(4)  = fmi-P1(4)-P2(4)
      P3(1)  = -P1(1)-P2(1)
      P3(2)  = -P2(2)
      P3(3)  = -P1(3)-P2(3)
      P3(5)  = fmk
 
C
C      Here we rotate of phi1 the particles from the gaugino decay.
C
 
      FI    = TWOPI*dble(RNDM(0))
      CF    = COS( FI )
      SF    = SIN( FI )
      CALL TRASQU(P1,PP1,CF,SF)
      CALL TRASQU(P2,PP2,CF,SF)
      CALL TRASQU(P3,PP3,CF,SF)
C
C      Here we rotate the GAUGINO vector of theta and phi
C
      pmom=sqrt(pin(1)**2+pin(2)**2+pin(3)**2)
      px=pin(1)/pmom
      py=pin(2)/pmom
      CTHCM=pin(3)/pmom
      PHCM  = atan2(py,px)
 
      STHCM = SQRT( 1. - CTHCM**2 )
      CPHCM = COS( PHCM )
      SPHCM = SIN( PHCM )
 
      CALL TRASLA( PP1,CTHCM,STHCM,CPHCM,SPHCM )
      CALL TRASLA( PP2,CTHCM,STHCM,CPHCM,SPHCM )
      CALL TRASLA( PP3,CTHCM,STHCM,CPHCM,SPHCM )
C
C      Here we boost the particles from the wino to the c. of m. frame.
C
      BETA(1) = Pin(1) / Pin(4)
      BETA(2) = Pin(2) / Pin(4)
      BETA(3) = Pin(3) / Pin(4)
 
      CALL BOOSTSUSY (PP1,BETA)
      CALL BOOSTSUSY (PP2,BETA)
      CALL BOOSTSUSY (PP3,BETA)
 
      ifail=0
 
      return
 
 
      END
*CMZ :  1.00/00 14/04/95  18.46.27  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
CYG       SUBROUTINE sfragment(IFLAG)
CYG C*
CYG C*
CYG       COMMON/LUJETS/N,K(4000,5),P(4000,5),V(4000,5)
CYG       DOUBLE PRECISION PV
CYG       COMMON /PARTC / PV(5,20),IFLAV(20,2),NFLAV
CYG       COMMON /CONST/ idbg,igener,irad
CYG  
CYG  
CYG       DOUBLE PRECISION  DBE(3)
CYG  
CYG       dimension qp(4),qm(4)
CYG       dimension ijon(2,10),erd(10)
CYG  
CYG  
CYG    10 CONTINUE
CYG  
CYG       if(nflav.eq.0)return
CYG  
CYG C...Reset commonblock LUJETS.
CYG  
CYG       DO 20  I=1,20
CYG         DO 20  J=1,5
CYG           K(I,J)=0
CYG           P(I,J)=0.
CYG    20 V(I,J)=0.
CYG  
CYG C...Store PARTICLES
CYG  
CYG       ISTR=0
CYG  
CYG       njon=0
CYG       DO 60 NC=1,NFLAV
CYG  
CYG         K(NC,1)=1
CYG  
CYG         K(NC,2)=IFLAV(NC,1)
CYG  
CYG         if(iabs(iflav(nc,1)).ge.40)k(nc,1)=21
CYG  
CYG         K(NC,3)=IFLAV(NC,2)
CYG  
CYG         DO 30  J=1,5
CYG    30   P(NC,j)=PV(J,NC)
CYG  
CYG         N=NC
CYG  
CYG         IF(iabs(K(NC-1,2)).LT.10.AND.iabs(K(NC,2)).LT.10)THEN
CYG  
CYG           DO 40  J=1,4
CYG             QP(J)=p(nc,j)
CYG    40     QM(J)=P(nc-1,j)
CYG  
CYG           DO 50  J=1,3
CYG    50     DBE(J)=(QP(J)+QM(J))/(QP(4)+QM(4))
CYG  
CYG           CALL LUDBRB(NC-1,NC,0.,0.,-DBE(1),-DBE(2),-DBE(3))
CYG  
CYG           ERED=P(NC-1,4)+P(NC,4)
CYG  
CYG           K1=IFLAV(NC,1)
CYG           K2=IFLAV(NC-1,1)
CYG  
CYG           njon=njon+1
CYG           ijon(1,njon)=nc-1
CYG           ijon(2,njon)=nc
CYG           erd(njon)=ered
CYG  
CYG           IF(ERED.LT.ULMASS(k1)+ulmass(k2)) write(1,*)' ER ',ERED
CYG  
CYG           THE=ULANGL(P(NC-1,3),SQRT(P(NC-1,1)**2+P(NC-1,2)**2))
CYG           PHI=ULANGL(P(NC-1,1),P(NC-1,2))
CYG  
CYG           CALL LU2ENT(-(NC-1),k1,k2,ERED)
CYG  
CYG           CALL LUDBRB(NC-1,NC,THE,PHI,DBE(1),DBE(2),DBE(3))
CYG  
CYG         ENDIF
CYG  
CYG  
CYG    60 CONTINUE
CYG  
CYG  
CYG C...Shower, fragment and decay.
CYG  
CYG       if(njon.gt.0)then
CYG         do 70 jj=1,njon
CYG    70   CALL LUSHOW(ijon(1,jj),ijon(2,jj),ERD(jj))
CYG       endif
CYG  
CYG       CALL LUEXEC
CYG  
CYG       if(idbg.eq.1)call lulist(1)
CYG  
CYG       iflag=0
CYG  
CYG       RETURN
CYG       END
*CMZ :  1.00/00 14/04/95  18.39.59  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      SUBROUTINE ROTSUSY(PIN,COSTH,PHI,POUT)
 
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C
C
      DIMENSION PIN(5),POUT(5)
C
C
C
      SINTH = DSQRT (1. - COSTH**2)
      SINPH = DSIN (PHI)
      COSPH = DCOS (PHI)
      POUT(1)   = (PIN(3)  *SINTH + PIN(1)  *COSTH)*COSPH
     +-PIN(2)  *SINPH
      POUT(2)   = (PIN(3)  *SINTH + PIN(1)  *COSTH)*SINPH
     ++PIN(2)  *COSPH
      POUT(3)   = (PIN(3)  *COSTH - PIN(1)  *SINTH)
      POUT(4) = PIN(4)
      POUT(5) = PIN(5)
      RETURN
      END
*CMZ :  1.00/00 14/04/95  18.44.40  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      SUBROUTINE BOOSTSUSY (PV,BST)
C----------------------------------------------------------------------
C-
C-   PV --> PV' (BOOSTED BY BST)
C-
C-   NB.  PV   (PX,PY,PZ,E,M)
C-        BST  (BX,BY,BZ)
C-
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION PV(5),BST(3)
C
 
      BB2 = BST(1)**2 + BST(2)**2 + BST(3)**2
 
      if(BB2.ge.1.d0)then
CYG         write(1,*)' error in boostsusy ',BB2
        bb2=0.99999d0
      endif
 
      GAM = 1. / DSQRT (1. - BB2)
      TM1 = BST(1) * PV(1) + BST(2) * PV(2) + BST(3) * PV(3)
      TM2 = GAM * TM1 / (GAM + 1.)  + PV(4)
      PV(4) = GAM * (PV(4) + TM1)
      DO 10 J=1,3
   10 PV(J) = PV(J) + GAM * BST(J) * TM2
      END
*CMZ :  1.00/00 14/04/95  18.39.59  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      SUBROUTINE sdecay2 (PM,COST,PHI,XM,PV)
C----------------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DIMENSION PV(5)
      SOST = DSQRT (1. - COST**2)
      PV(3) = PM * COST
      PV(1) = PM * SOST * DCOS (PHI)
      PV(2) = PM * SOST * DSIN (PHI)
      PV(4) = DSQRT (PM**2 + XM**2)
      PV(5) = XM
      END
*CMZ :  1.00/00 14/04/95  18.44.40  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      DOUBLE PRECISION FUNCTION XLAMDA (A,B,C)
C----------------------------------------------------------------------
C-
C-   X = SQRT (AA + BB + CC - 2AB - 2AC - 2AC)
C-
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
 
      xlamda=0.d0
 
      X = A * A + B * B + C * C
      Y = A * B + A * C + B * C
      if(x-2.d0*y.lt.0.)return
 
      aa=dsqrt(a)
      bb=dsqrt(b)
      cc=dsqrt(c)
      if(aa.lt.bb+cc)return
 
      XLAMDA = DSQRT (X - 2. d0* Y)
      END
*CMZ :  1.00/00 14/04/95  18.39.59  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      SUBROUTINE TRASQU(P1,P2,CF,SF)
C******** IT ROTATES WITH RESPECT TO THE Z AXIS
 
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
 
C
      DIMENSION P1(5),P2(5)
C
      P2(1)=P1(1)*CF+P1(2)*SF
      P2(2)=P1(2)*CF-P1(1)*SF
      P2(3)=P1(3)
      P2(4)=P1(4)
      P2(5)=P1(5)
      END
*CMZ :  1.00/00 14/04/95  18.46.27  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      SUBROUTINE TRASLA(P2,CT,ST,CF,SF)
C*****
C***** IT ROTATES THE VECTORS
C***** OF THE ANGLES THETA AND PHI
C
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
 
      DIMENSION P1(5),P2(5)
      do 10 k=1,3
   10 p1(k)=p2(k)
C
      P2(3)=P1(3)*CT-P1(1)*ST
      PP=P1(1)*CT+P1(3)*ST
C
      P2(1)=PP*CF-P1(2)*SF
      P2(2)=P1(2)*CF+PP*SF
C
      END
*CMZ :  1.00/00 14/04/95  18.46.27  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
CDECK  ID>, SSDINT.
      DOUBLE PRECISION FUNCTION SSDINT(XL,F,XR)
C-----------------------------------------------------------------------
C     Integrate double precision F over double precision (XL,XR)
C     Note quadrature constants R and W have been converted to explicit
C     double precision (.xxxxxDxx) form.
C
C     Bisset's XINTH
C-----------------------------------------------------------------------
      IMPLICIT NONE
      COMMON/SSLUN/LOUT
      INTEGER LOUT
      SAVE /SSLUN/
      EXTERNAL F
      INTEGER NMAX
      DOUBLE PRECISION TOLABS,TOLREL,XLIMS(100)
      DOUBLE PRECISION R(93),W(93)
      INTEGER PTR(4),NORD(4)
      INTEGER ICOUNT
      DOUBLE PRECISION XL,XR,F
      DOUBLE PRECISION AA,BB,TVAL,VAL,TOL
      INTEGER NLIMS,I,J,KKK
C
      DATA PTR,NORD/4,10,22,46,  6,12,24,48/
      DATA (R(KKK),KKK=1,48)/
     + .2386191860D0,.6612093865D0,.9324695142D0,.1252334085D0,
     + .3678314990D0,.5873179543D0,.7699026742D0,.9041172563D0,
     + .9815606342D0,.0640568929D0,.1911188675D0,.3150426797D0,
     + .4337935076D0,.5454214714D0,.6480936519D0,.7401241916D0,
     + .8200019860D0,.8864155270D0,.9382745520D0,.9747285560D0,
     + .9951872200D0,.0323801710D0,.0970046992D0,.1612223561D0,
     + .2247637903D0,.2873624873D0,.3487558863D0,.4086864820D0,
     + .4669029048D0,.5231609747D0,.5772247261D0,.6288673968D0,
     + .6778723796D0,.7240341309D0,.7671590325D0,.8070662040D0,
     + .8435882616D0,.8765720203D0,.9058791367D0,.9313866907D0,
     + .9529877032D0,.9705915925D0,.9841245837D0,.9935301723D0,
     + .9987710073D0,.0162767488D0,.0488129851D0,.0812974955D0/
      DATA (R(KKK),KKK=49,93)/
     + .1136958501D0,.1459737146D0,.1780968824D0,.2100313105D0,
     + .2417431561D0,.2731988126D0,.3043649444D0,.3352085229D0,
     + .3656968614D0,.3957976498D0,.4254789884D0,.4547094222D0,
     + .4834579739D0,.5116941772D0,.5393881083D0,.5665104186D0,
     + .5930323648D0,.6189258401D0,.6441634037D0,.6687183100D0,
     + .6925645366D0,.7156768123D0,.7380306437D0,.7596023411D0,
     + .7803690438D0,.8003087441D0,.8194003107D0,.8376235112D0,
     + .8549590334D0,.8713885059D0,.8868945174D0,.9014606353D0,
     + .9150714231D0,.9277124567D0,.9393703398D0,.9500327178D0,
     + .9596882914D0,.9683268285D0,.9759391746D0,.9825172636D0,
     + .9880541263D0,.9925439003D0,.9959818430D0,.9983643759D0,
     + .9996895039/
      DATA (W(KKK),KKK=1,48)/ .4679139346D0,.3607615730D0,
     +.1713244924D0,.2491470458D0, .2334925365D0,.2031674267D0,
     +.1600783285D0,.1069393260D0, .0471753364D0,.1279381953D0,
     +.1258374563D0,.1216704729D0, .1155056681D0,.1074442701D0,
     +.0976186521D0,.0861901615D0, .0733464814D0,.0592985849D0,
     +.0442774388D0,.0285313886D0, .0123412298D0,.0647376968D0,
     +.0644661644D0,.0639242386D0, .0631141923D0,.0620394232D0,
     +.0607044392D0,.0591148397D0, .0572772921D0,.0551995037D0,
     +.0528901894D0,.0503590356D0, .0476166585D0,.0446745609D0,
     +.0415450829D0,.0382413511D0, .0347772226D0,.0311672278D0,
     +.0274265097D0,.0235707608D0, .0196161605D0,.0155793157D0,
     +.0114772346D0,.0073275539D0, .0031533461D0,.0325506145D0,
     +.0325161187D0,.0324471637D0/
      DATA (W(KKK),KKK=49,93)/
     + .0323438226D0,.0322062048D0,.0320344562D0,.0318287589D0,
     + .0315893308D0,.0313164256D0,.0310103326D0,.0306713761D0,
     + .0302999154D0,.0298963441D0,.0294610900D0,.0289946142D0,
     + .0284974111D0,.0279700076D0,.0274129627D0,.0268268667D0,
     + .0262123407D0,.0255700360D0,.0249006332D0,.0242048418D0,
     + .0234833991D0,.0227370697D0,.0219666444D0,.0211729399D0,
     + .0203567972D0,.0195190811D0,.0186606796D0,.0177825023D0,
     + .0168854799D0,.0159705629D0,.0150387210D0,.0140909418D0,
     + .0131282296D0,.0121516047D0,.0111621020D0,.0101607705D0,
     + .0091486712D0,.0081268769D0,.0070964708D0,.0060585455D0,
     + .0050142027D0,.0039645543D0,.0029107318D0,.0018539608D0,
     + .0007967921/
C
      DATA TOLABS,TOLREL,NMAX/1.D-35,5.D-5,100/
C
      SSDINT=0
      NLIMS=2
      XLIMS(1)=XL
      XLIMS(2)=XR
      ICOUNT=0
C
   10 AA=(XLIMS(NLIMS)-XLIMS(NLIMS-1))/2
      BB=(XLIMS(NLIMS)+XLIMS(NLIMS-1))/2
      TVAL=0
      DO 20 I=1,3
   20 TVAL=TVAL+W(I)*(F(BB+AA*R(I))+F(BB-AA*R(I)))
      TVAL=TVAL*AA
      DO 40 J=1,4
        VAL=0
        DO 30 I=PTR(J),PTR(J)-1+NORD(J)
          ICOUNT=ICOUNT+1
          IF(ICOUNT.GT.1E5) THEN
CYG             WRITE(1,*) 'ERROR IN SSDINT: SET SSDINT TO ZERO'
            SSDINT=0.
            RETURN
          ENDIF
   30   VAL=VAL+W(I)*(F(BB+AA*R(I))+F(BB-AA*R(I)))
        VAL=VAL*AA
        TOL=MAX(TOLABS,TOLREL*ABS(VAL))
        IF(ABS(TVAL-VAL).LT.TOL) THEN
          SSDINT=SSDINT+VAL
          NLIMS=NLIMS-2
          IF (NLIMS.NE.0) GO TO 10
          RETURN
        ENDIF
   40 TVAL=VAL
      IF(NMAX.EQ.2) THEN
        SSDINT=VAL
        RETURN
      END IF
      IF(NLIMS.GT.(NMAX-2)) THEN
CYG         WRITE(1,10000) 'ERROR IN SSDINT: SSDINT,NMAX,BB-AA,BB+AA='
CYG      +  ,SSDINT,NMAX,BB-AA,BB+AA
        RETURN
      ENDIF
      XLIMS(NLIMS+1)=BB
      XLIMS(NLIMS+2)=BB+AA
      XLIMS(NLIMS)=BB
      NLIMS=NLIMS+2
      GO TO 10
C
10000 FORMAT (' SSDINT FAILS, SSDINT,NMAX,XL,XR=',G15.7,I5,2G15.7)
      END
*CMZ :  1.00/00 14/04/95  18.39.59  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      DOUBLE PRECISION FUNCTION SPECTR(XK,S,FAC)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      EXTERNAL SIGMA
C DEFINITION OF BREMSSTRAHLUNG SPECTRUM
      SPECTR=FAC*(1.+(1.-XK)**2)/XK*SIGMA(S*(1.-XK))
      RETURN
      END
*CMZ :  1.00/00 14/04/95  18.46.27  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      SUBROUTINE REMT1(EBEAMX,CROSS)
C THIS PART INITIALIZES THE INITIAL-STATE RADIATOR.
C IT CALCULATES SOME QUANTITIES, AND PERFORMS THE
C NUMERICAL INTEGRATION OVER THE PHOTON SPECTRUM.
C EBEAMX=BEAM ENERGY (IN GEV)
C CROSS=NONRADIATIVE CROSS SECTION, TO BE DEFINED
C       WITH ONE VARIABLE: CROSS(S),
C       WHERE S IS THE INVARIANT MASS OF THE E+E- PAIR.
 
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      DIMENSION X(5000),F(5000),A(5000),Y(5000),Z(5000),XNEW(5000)
c      DIMENSION X(1000),F(1000),A(1000),Y(1000),Z(1000),XNEW(1000)
      DIMENSION QK(4),QIN(4),QOUT(4)
      real*4 rndm
      EXTERNAL SPECTR,CROSS
      SAVE EBEAM
 
      COMMON/INDEX/index,index1,index2,nevt
      COMMON/FINDEX/fmpr1,fmpr2,XCROST,APRO
 
 
C
C INITIALIZE A FEW QUANTITIES AND CONSTANTS
      EBEAM = EBEAMX
      S  = 4.D0*EBEAM**2
      XPS= (.511D-03/EBEAM)**2/2.
      XPT= (2.+XPS)/XPS
      XPL= DLOG(XPT)
      PI = 4.*DATAN(1.D0)
      TPI= 2.*PI
c      ALF= 1./137.036D0
      ALF= 1./137.D0
 
      alf=alfaem(s)
 
      FAC= ALF/PI*(XPL-1.)
      XKC= DEXP( - ( PI/(2.*ALF) + 3./4.*XPL + PI**2/6. - 1. )
     +            /( XPL - 1. )                           )
c      WRITE(6,1) EBEAM,S,XPS,XPT,XPL,PI,TPI,ALF,FAC,XKC
10000 FORMAT(1H0,80(1H=),/,
     +  '0INITIALIZATION OF ROUTINE PACKAGE REMT:',/,
     +  '0BEAM ENERGY  : ',F7.3,' GEV',/,
     +2('0CONSTANTS    : ',4D15.6,/),
     +  '0MINIMAL BREMSSTRAHLUNG ENERGY : ',D10.4,' * EBEAM')
C
C PARAMETERS OF NUMERICAL INTEGRATION STEP
      X1   = XKC
      XN   = 1.-400./S
      N    = 500
      ITER = 6
c      WRITE(6,2) X1,XN,N,ITER
10100 FORMAT('0PARAMETERS OF SPECTRUM INTEGRATION:',/,
     +       '0LOWEST  K VALUE   : ',D10.3,/,
     +       '0HIGHEST K VALUE   : ',D10.3,/,
     +       '0NO. OF POINTS     : ',I5,/,
     +       '0NO. OF ITERATIONS : ',I3)
C
C INITIALIZE BY CHOOSING EQUIDISTANT X VALUES
      IT=0
      M=N-1
      DX=(XN-X1)/DFLOAT(M)
      X(1)=X1
      DO 10  I=2,N
   10 X(I)=X(I-1)+DX
C
C STARTING POINT FOR ITERATIONS
 
   20 CONTINUE
C
C CALCULATE FUNCTION VALUES
      DO 30  I=1,N
   30 F(I)=SPECTR(X(I),S,FAC)
C
C CALCULATE BIN AREAS
      DO 40  I=1,M
   40 A(I)=(X(I+1)-X(I))*(F(I+1)+F(I))/2.d0
C
C CALCULATE CUMULATIVE SPECTRUM Y VALUES
      Y(1)=0.D0
      DO 50  I=2,N
   50 Y(I)=Y(I-1)+A(I-1)
C
C PUT EQUIDISTANT POINTS ON Y SCALE
      DZ=Y(N)/DFLOAT(M)
      Z(1)=0.D0
      DO 60  I=2,N
   60 Z(I)=Z(I-1)+DZ
C
C DETERMINE SPACING OF Z POINTS IN BETWEEN Y POINTS
C FROM THIS, DETERMINE NEW X VALUES AND FINALLY REPLACE OLD VALUES
      XNEW(1)=X(1)
      XNEW(N)=X(N)
      K=1
      DO 90  I=2,M
   70   IF( Y(K+1) .GT. Z(I) ) GOTO 80
        K=K+1
        GOTO 70
   80   R= ( Z(I) - Y(K) ) / ( Y(K+1) - Y(K) )
   90 XNEW(I) = X(K) + ( X(K+1)-X(K) )*R
      DO 100 I=1,N
  100 X(I)=XNEW(I)
C
C CHECK ON END OF ITERATIONS AND RETURN
      IT=IT+1
c      WRITE(6,3) IT,Y(M)
10200 FORMAT('0ITERATION NO.=',I3,'  INTEGRAL =',D15.6)
      IF(IT.LT.ITER) GOTO 20
C
C PRESENT RESULTS IN FORM OF CORRECTION
 
      SIG0 = CROSS(S)
 
      SIG1 = Y(M)
 
      xcrost=sig1
 
      DELT = (SIG1/SIG0-1.)*100.
CYG       WRITE(1,10300) SIG0,SIG1,DELT
10300 FORMAT(
     +       ' NONRADIATIVE CROSS SECTION :',D15.6,/,
     +       '    RADIATIVE CROSS SECTION :',D15.6,/,
     +       '    RADIATIVE CORRECTION    :',F10.3,' %')
      RETURN
 
 
 
      ENTRY REMT2(QK)
C THIS PART GENERATES A BREMSSTRAHLUNG PHOTON
C AND CALCULATES WHICH BEAM AXIS TO CHOOSE FOR
C THE GENERATION OF THE 'NONRADIATIVE' CROSS SECTION.
C THE PHOTON ENERGY SPECTRUM MUST HAVE BEEN EXAMINED
C BY CALLING ENTRY 'REMT1' BEFORE THE FIRST CALL TO
C THIS ENTRY.
C
C INITIALIZE FLAG FOR REMT3
      IR=0
C
C GENERATE PHOTON ENERGY FROM CUMULATIVE SPECTRUM BINS
      R=dfloat(M)*dble(rndm(0))
      I=IDINT(R)
      S=R-dfloat(I)
      XK = X(I+1) + S*( X(I+2)-X(I+1) )
C
C GENERATE AZIMUTHAL SCATTERING ANGLE OF THE PHOTON
      FG=TPI*dble(rndm(0))
C
C GENERATE COSINE OF POLAR SCATTERING ANGLE OF THE PHOTON
  110 IT=IT+1
      V= XPS * ( XPT**dble(rndm(0)) - 1.d0 )
      W= XPS + V*(1.d0-.5d0*V)
      W= dble(rndm(0))/(1.d0-(XK*XK*W+2.*XPS*(1.d0-XK)/W)/(1.d0+
     +(1.d0-XK)**2))
      IF(W.GT.1.D0) GOTO 110
      W= -1.d0 + 2.d0*W
      CG=DSIGN(1.d0-V,W)
C
C CHOOSE WHICH OF THE TWO Z AXES SHOULD BE CONSIDERED
      CH=-1.
      IF(DABS(W).LT.(1./(1.+(1.-2./(1.+XK*CG/(2.-XK)))**2))) CH=+1.
C
C CONSTRUCT PHOTON FOUR-MOMENTUM
      SG=DSQRT(V*(2.d0-V))
      QK(4)=XK*EBEAM
      if(qk(4).lt.0.0001)qk(4)=0.0001
      QK(1)=QK(4)*SG*DCOS(FG)
      QK(2)=QK(4)*SG*DSIN(FG)
      QK(3)=QK(4)*CG
C
      RETURN
C
      ENTRY REMT3(QK,QIN,QOUT)
C THIS PART PERFORMS THE ROTATIONS AND BOOSTS OF THE I.S.R.
C FORMALISM AFTER THE USER'S BLACK BOX HAS RUN AN EVENT.
C THE INPUT VECTOR (FROM USERS BLACK BOX) IS QIN;
C THE RESULTING VECTOR IN THE LAB FRAME IS QOUT.
C
C INITIALIZATION PART: ONCE FOR EVERY GENERATED PHOTON MOMENTUM
      IF(IR.NE.0) GOTO 120
      IR=1
 
      ads=qk(1)**2+qk(2)**2
      if(ads.le.0.d0)ads=0.0000000001d0
 
C
C CALCULATE ROTATTION PARAMETERS FOR BEAM DIRECTION IN C.M.S.
      XKP = DSQRT( ads )
      XKM = 2.d0* DSQRT( EBEAM*(EBEAM-QK(4)) )
      XKD = 2.d0*EBEAM - QK(4) + XKM
      XKA = ( CH + QK(3)/XKD )/XKM
      XKB = DSQRT( (1.+XKA*QK(3))**2 + (XKA*XKP)**2 )
      S1  = XKA*XKP/XKB
      C1  = (1.d0+XKA*QK(3))/XKB
      S2  = QK(1)/XKP
      C2  = QK(2)/XKP
      YK=QK(4)**2- ads -QK(3)**2
      Y1=C1**2+S1**2-1.d0
      Y2=C2**2+S2**2-1.d0
C
C ROTATE INPUT VECTOR QIN(I) TO CORRESPOND WITH CHOZEN Z-AXIS
  120 QQ =  C1*QIN(2) + S1*QIN(3)
      QZ = -S1*QIN(2) + C1*QIN(3)
      QX =  C2*QIN(1) + S2*QQ
      QY = -S2*QIN(1) + C2*QQ
C
C BOOST ROTATED VECTOR TO LAB FRAME VECTOR QOUT
      QOUT4   =((XKD-XKM)*QIN(4)-QK(1)*QX-QK(2)*QY-QK(3)*QZ)/XKM
      QQ     =(QIN(4)+QOUT4)/XKD
      QOUT(1)= QX - QK(1)*QQ
      QOUT(2)= QY - QK(2)*QQ
      QOUT(3)= QZ - QK(3)*QQ
      QOUT(4)= QOUT4
 
      RETURN
      END
*CMZ :  1.00/00 14/04/95  18.46.27  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      DOUBLE PRECISION FUNCTION SIGMA(SHAT)
 
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      COMMON/INDEXX/index,index1,index2,nevt
      COMMON/FINDEX/fmpr1,fmpr2,XCROST,APRO
 
      COMMON/KINEM/flum,ecm,s,roots,T,Q,Q2,EN(2)
 
      common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
      external gensel,genselrs,gensmu,gensnue,gensnu,photi,chargi
 
      roots=dsqrt(shat)
      S=shat
 
      if(index.eq.1)then
        xcrost=photi(index1,index2)
      endif
 
      if(index.eq.2)then
        xcrost=chargi(index1,index2)
      endif
 
      if(index.eq.3)then
        mindex1=iabs(index1)
        mindex2=iabs(index2)
 
        if(mindex1.eq.51.and.mindex2.ne.mindex1)then
          xCROSt=genselrs(dummy)
        else
 
          do 10 k=1,12
            do 10 l=1,2
              k1=mod(k-1,4)+1
 
              if(index1.ne.ispa(k,l))go to 10
 
              if(k.eq.3)xCROSt=ssdint(-1.d0,gensnue,1.D0)
              if(k.eq.4)xCROSt=ssdint(-1.d0,gensel,1.d0)
              if(k.ne.4.and.k1.ne.3)xCROSt=gensmus(dummy)
              if(k.ne.3.and.k1.eq.3)xCROSt=ssdint(-1.D0,gensnu,1.D0)
 
   10     continue
        endif
      endif
 
      sigma=xcrost
CYG       if(sigma.lt.0)write(1,*)' negative cros section ? ',xcrost
      if(sigma.lt.0)sigma=0.
 
      RETURN
      END
*CMZ :  1.00/00 14/04/95  18.40.00  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      SUBROUTINE SXWRLU (LUNIT)
C
C...SXWRLU  FOR WRITING EVENTS FROM LUND COMMON BLOCK OUT ON EXTERNAL FI
C.
C.  ARGUMENTS    CALL SXWRLU (LUNIT)
C.          LUNIT     LOGICAL UNIT FOR WRITING EVENTS
C.
C.  FORMATS: (NON-PORTABLE!!!)
C.        EVENT RECORDS, IN THE FOLLOWING
C.        FORMAT (ONE RECORD PER EVENT):
C.
C.    WORD 0 : N                    (I)
C.         1 : K(1,1)               (I) \
C.         2 : K(1,2)               (I)  \
C.         3 : K(1,3)               (I)   \
C.         4 : K(1,4)               (I)    \
C.         5 : K(1,5)               (I)     \
C.         6 : P(1,1)               (F)      \
C.         7 : P(1,2)               (F)       \
C.         8 : P(1,3)               (F)        >  REPEATED N TIMES
C.         9 : P(1,4)               (F)       /
C.        10 : P(1,5)               (F)      /
C.        11 : V(1,1)               (F)     /
C.        12 : V(1,2)               (F)    /
C.        13 : V(1,3)               (F)   /
C.        14 : V(1,4)               (F)  /
C.        15 : V(1,5)               (F) /
C.        16 : K(2,1)
C.       ...
C.     N*7-1 : P(N,4)
C.       N*7 : P(N,5)
C.
C.
C.----------------------------------------------------------------------
      COMMON/LUJETS/N,K(4000,5),P(4000,5),V(4000,5)
      SAVE /LUJETS/
C
C
C   WRITE EVENT DATA
C
   10 CONTINUE
 
      if(N.eq.0)return
 
      WRITE (LUNIT)
     +     N,((K(I,J),J=1,5),(P(I,J),J=1,5),(V(I,J),J=1,5),I=1,N)
      RETURN
      END
*CMZ :  1.00/00 14/04/95  18.44.40  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
CYG       subroutine sbook
CYG  
CYG C Keys
CYG       logical wrt,scan,lepi
CYG       common/str/wrt,scan,lepi
CYG  
CYG       real*4  rgmaum,rgmaur,rgm0,rgtanb,rgatri,rfmsq,rfmstopl,rfmstopr,
CYG      +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum
CYG      +        ,vscan(6) ! only in histobook rvscan --> vscan, sorry
CYG       common /rkey/rgmaum,rgmaur,rgm0,rgtanb,rgatri,
CYG      +        rfmsq,rfmstopl,rfmstopr,
CYG      +        rfmsell,rfmselr,rfmsnu,rfmglu,recm,rflum
CYG      +        ,vscan    ! only in histobook rvscan --> vscan, sorry
CYG  
CYG C ntuple
CYG       common/pawc/hmemor(300000)
CYG  
CYG       logical zino,wino,sele,smuo,stau,snu,squa,stopa,sbota
CYG       common/sparc/ zino,wino,sele,smuo,stau,snu,squa,stopa,sbota
CYG  
CYG       call hlimit(300000)
CYG  
CYG  
CYG       if(scan)then
CYG c
CYG c scan histos
CYG c
CYG c
CYG c gauginos
CYG c
CYG c
CYG c masses
CYG c
CYG         call hbook2(401,' mass x01 ', int(vscan(1)),vscan(2),vscan(3),
CYG      +  int(vscan(4)),vscan(5),vscan(6),0.)
CYG         call hbook2(402,' mass x02  ', int(vscan(1)),vscan(2),vscan(3),
CYG      +  int(vscan(4)),vscan(5),vscan(6),0.)
CYG         call hbook2(403,' mass x+1  ', int(vscan(1)),vscan(2),vscan(3),
CYG      +  int(vscan(4)),vscan(5),vscan(6),0.)
CYG  
CYG         if(zino.or.wino)then
CYG  
CYG c
CYG c cross sections
CYG c
CYG           call hbook2(101,' cs x01x01 ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG           call hbook2(102,' cs x01x02 ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG           call hbook2(103,' cs x+1x-1 ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG  
CYG c
CYG c BR
CYG c
CYG c x02 BR
CYG  
CYG           call hbook2(501,' x02 BR to x01qqbar ', int(vscan(1)),
CYG      +    vscan(2),vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG           call hbook2(502,' x02 BR to x01l+l-  ', int(vscan(1)),
CYG      +    vscan(2),vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG           call hbook2(503,' x02 BR to x01vv  ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG           call hbook2(504,' x02 BR to x-1x-l+v ', int(vscan(1)),
CYG      +    vscan(2),vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG           call hbook2(505,' x02 BR to x-1x-qqp  ', int(vscan(1)),
CYG      +    vscan(2),vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG  
CYG c
CYG c x+1 BR
CYG c
CYG           call hbook2(601,' x+1 BR to x01x-l+v ', int(vscan(1)),
CYG      +    vscan(2),vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG           call hbook2(602,' x+1 BR to x01x-qqp  ', int(vscan(1)),
CYG      +    vscan(2),vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG           call hbook2(603,' x+1 BR to x02x-l+v ', int(vscan(1)),
CYG      +    vscan(2),vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG           call hbook2(604,' x+1 BR to x02x-qqp  ', int(vscan(1)),
CYG      +    vscan(2),vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG  
CYG         endif
CYG  
CYG c
CYG c sfermions
CYG c
CYG         if(snu)then
CYG           call hbook2(111,' snu MASS ', int(vscan(1)),vscan(2),vscan(3)
CYG      +    , int(vscan(4)),vscan(5),vscan(6),0.)
CYG  
CYG c
CYG c CR
CYG c
CYG           call hbook2(201,' cs snu ', int(vscan(1)),vscan(2),vscan(3),
CYG      +    int(vscan(4)),vscan(5),vscan(6),0.)
CYG  
CYG c
CYG c BR
CYG c
CYG           call hbook2(301,' snu BR to x01 ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG           call hbook2(302,' snu BR to x02  ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG           call hbook2(303,' snu BR to X+1  ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG  
CYG         endif
CYG  
CYG         if(sele)then
CYG  
CYG           call hbook2(112,' SEL MASS ', int(vscan(1)),vscan(2),vscan(3)
CYG      +    , int(vscan(4)),vscan(5),vscan(6),0.)
CYG  
CYG           call hbook2(113,' SER MASS ', int(vscan(1)),vscan(2),vscan(3)
CYG      +    , int(vscan(4)),vscan(5),vscan(6),0.)
CYG  
CYG           call hbook2(202,' cs sel ', int(vscan(1)),vscan(2),vscan(3),
CYG      +    int(vscan(4)),vscan(5),vscan(6),0.)
CYG  
CYG           call hbook2(311,' sel BR to x01 ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG           call hbook2(312,' sel BR to x02  ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG           call hbook2(313,' sel BR to X+1  ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG  
CYG           call hbook2(321,' ser BR to x01 ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG           call hbook2(322,' ser BR to x02  ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG           call hbook2(323,' ser BR to X+1  ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG  
CYG         endif
CYG  
CYG         if(sbota)then
CYG           call hbook2(121,' cs botl ', int(vscan(1)),vscan(2),vscan(3),
CYG      +    int(vscan(4)),vscan(5),vscan(6),0.)
CYG           call hbook2(122,' cs botr ', int(vscan(1)),vscan(2),vscan(3),
CYG      +    int(vscan(4)),vscan(5),vscan(6),0.)
CYG  
CYG           call hbook2(114,' SBOTL MASS ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG  
CYG           call hbook2(115,' SBOTR MASS ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG  
CYG           call hbook2(331,' sbotl BR to x01 ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG           call hbook2(332,' sbotl BR to x02  ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG           call hbook2(333,' sbotl BR to X+1  ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG  
CYG           call hbook2(341,' sbotr BR to x01 ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG           call hbook2(342,' sbotr BR to x02  ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG           call hbook2(343,' sbotr BR to X+1  ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG  
CYG         endif
CYG  
CYG         if(stopa)then
CYG  
CYG           call hbook2(123,' cs stopl ', int(vscan(1)),vscan(2),vscan(3)
CYG      +    , int(vscan(4)),vscan(5),vscan(6),0.)
CYG           call hbook2(124,' cs stopr ', int(vscan(1)),vscan(2),vscan(3)
CYG      +    , int(vscan(4)),vscan(5),vscan(6),0.)
CYG  
CYG           call hbook2(116,' STOPL MASS ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG  
CYG           call hbook2(117,' STOPL MASS ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG  
CYG  
CYG           call hbook2(351,' stopl BR to x01 ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG           call hbook2(352,' stopl BR to x02  ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG           call hbook2(353,' stopl BR to X+1  ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG  
CYG           call hbook2(361,' sbtopr BR to x01 ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG           call hbook2(362,' sbtor BR to x02  ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG           call hbook2(363,' stopr BR to X+1  ', int(vscan(1)),vscan(2),
CYG      +    vscan(3), int(vscan(4)),vscan(5),vscan(6),0.)
CYG  
CYG         endif
CYG  
CYG       else
CYG c
CYG c no scan histos
CYG c
CYG         if(zino)then
CYG           call hbook1(1001,' costh x01x01 ',20,-1.,1.,0.)
CYG           call hbook1(1002,' costh x01x02 ',20,-1.,1.,0.)
CYG           call hbook1(1003,' costh x01x03 ',20,-1.,1.,0.)
CYG           call hbook1(1004,' costh x01x04 ',20,-1.,1.,0.)
CYG           call hbook1(1005,' costh x02x02 ',20,-1.,1.,0.)
CYG           call hbook1(1006,' costh x02x03 ',20,-1.,1.,0.)
CYG           call hbook1(1007,' costh x02x04 ',20,-1.,1.,0.)
CYG           call hbook1(1008,' costh x03x03 ',20,-1.,1.,0.)
CYG           call hbook1(1009,' costh x03x04 ',20,-1.,1.,0.)
CYG           call hbook1(1010,' costh x04x04 ',20,-1.,1.,0.)
CYG  
CYG         endif
CYG  
CYG         if(wino)then
CYG           call hbook1(1011,' costh x+1x-1 ',20,-1.,1.,0.)
CYG           call hbook1(1012,' costh x+1x-2 ',20,-1.,1.,0.)
CYG           call hbook1(1013,' costh x+2x-2 ',20,-1.,1.,0.)
CYG  
CYG         endif
CYG  
CYG         if(snu)then
CYG           call hbook1(2001,' costh snue ',20,-1.,1.,0.)
CYG           call hbook1(2002,' costh snu ',20,-1.,1.,0.)
CYG  
CYG         endif
CYG  
CYG         if(sele)then
CYG           call hbook1(2003,' costh sel ',20,-1.,1.,0.)
CYG           call hbook1(2004,' costh ser ',20,-1.,1.,0.)
CYG           call hbook1(2005,' costh selr ',20,-1.,1.,0.)
CYG  
CYG         endif
CYG  
CYG         if(smuo)then
CYG           call hbook1(2006,' costh smul ',20,-1.,1.,0.)
CYG           call hbook1(2007,' costh smur ',20,-1.,1.,0.)
CYG  
CYG         endif
CYG  
CYG         if(stau)then
CYG           call hbook1(2008,' costh staul ',20,-1.,1.,0.)
CYG           call hbook1(2009,' costh staur ',20,-1.,1.,0.)
CYG  
CYG         endif
CYG  
CYG         if(sbota)then
CYG           call hbook1(2010,' costh sbotl ',20,-1.,1.,0.)
CYG           call hbook1(2011,' costh sbotr ',20,-1.,1.,0.)
CYG  
CYG         endif
CYG  
CYG         if(stopa)then
CYG           call hbook1(2012,' costh stopl ',20,-1.,1.,0.)
CYG           call hbook1(2013,' costh stopr ',20,-1.,1.,0.)
CYG  
CYG         endif
CYG  
CYG         if(squa)then
CYG           call hbook1(2014,' costh squa ',20,-1.,1.,0.)
CYG           call hbook1(2015,' costh squa ',20,-1.,1.,0.)
CYG  
CYG         endif
CYG  
CYG         CALL hbook1(1101,' amp/apro ',100,0.,2.,0.)
CYG         CALL hbook1(1111,' ntries ',100,0.,1000.,0.)
CYG  
CYG       endif
CYG       return
CYG       end
*CMZ :  1.00/00 14/04/95  18.40.00  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
CYG       double precision FUNCTION wsc(sb)
CYG       IMPLICIT DOUBLE PRECISION (A-H,O-Z)
CYG  
CYG       COMMON/SDECAY/DAS,DBS,DCS,DATL,DAUL,DATUL,DASTL,DBSTL,DASUL,
CYG      +DBSUL,DATR,DAUR,DATUR,DASTR,DBSTR,DASUR,DBSUR,xdec(17,64)
CYG  
CYG       COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
CYG      +FLC(12),FRC(12),gms(12),echar(12)
CYG  
CYG       common/variables/fms,fmi,fmk,fml1,fml2,etai,etak,brspa(6,48),
CYG      +lind(6,6,6),brgaug(23,6,6),fmelt,fmert,fmelu,fmeru
CYG  
CYG       common/widths/gw,widfl(12),widfr(12),fmeltw,fmertw,fmeluw,fmeruw,
CYG      +gent(50,2,168),gentl(2,2,168),linda(18,6,6)
CYG       common/mass/sfmi,sfmk,sfms,sgw,sfmelt,sfmelu,alt,alu,c0
CYG  
CYG       wsc=0.
CYG  
CYG       sfmi=fmi
CYG       sfmk=fmk
CYG       sfms=fms
CYG       sgw=gw
CYG  
CYG       c0=fmi**2+fmk**2+fml1**2+fml2**2
CYG c
CYG c t sneutrino
CYG c
CYG       GW1 = ((SB+FML1**2-FML2**2)/(2.*DSQRT(SB))+
CYG      +        (FMI**2-FMK**2-SB) /(2.*DSQRT(SB)))**2
CYG       GW2 = ((SB+FML1**2-FML2**2)**2/(4.*SB)-FML1**2)
CYG       GW3 = ((FMI**2-SB-FMK**2)**2/(4.*SB)-FMK**2)
CYG       if(GW2.le.0..or.GW3.le.0.)return
CYG       GW2 = DSQRT(GW2)
CYG       GW3 = DSQRT(GW3)
CYG       TMIN = GW1-(GW2+GW3)**2
CYG       TMAX = GW1-(GW2-GW3)**2
CYG c
CYG c  u= charged slepton
CYG c
CYG       GW1 = ((SB+FML2**2-FML1**2)/(2.*DSQRT(SB))+
CYG      +        (FMI**2-FMK**2-SB) /(2.*DSQRT(SB)))**2
CYG       GW2 = ((SB+FML2**2-FML1**2)**2/(4.*SB)-FML2**2)
CYG       GW3 = ((FMI**2-SB-FMK**2)**2/(4.*SB)-FMK**2)
CYG       if(GW2.le.0..or.GW3.le.0.)return
CYG       GW2 = DSQRT(GW2)
CYG       GW3 = DSQRT(GW3)
CYG       UMIN = GW1-(GW2+GW3)**2
CYG       UMAX = GW1-(GW2-GW3)**2
CYG  
CYG c
CYG c s channel integrals
CYG c
CYG  
CYG       f1=ff1(sb,tmax)-ff1(sb,tmin)
CYG       f2=ff1(sb,umax)-ff1(sb,umin)
CYG       f3=ff2(sb,tmax)-ff2(sb,tmin)
CYG  
CYG       wsc1=das*f1+dbs*f2+2.*dcs*etai*etak*fmi*fmk*f3
CYG c
CYG c t channel
CYG c
CYG  
CYG       sfmelt=fmelt
CYG       alt=fmeltw
CYG       f4l=ff3(sb,tmax)-ff3(sb,tmin)
CYG  
CYG       sfmelt=fmert
CYG       alt=fmertw
CYG       f4r=ff3(sb,tmax)-ff3(sb,tmin)
CYG  
CYG       wsc2=datl*f4l+datr*f4r
CYG c
CYG c u channel
CYG c
CYG       sfmelt=fmelu
CYG       alt=fmeluw
CYG       f5l=ff3(sb,umax)-ff3(sb,umin)
CYG  
CYG       sfmelt=fmeru
CYG       alt=fmeruw
CYG       f5r=ff3(sb,umax)-ff3(sb,umin)
CYG  
CYG       wsc3=daul*f5l+daur*f5r
CYG  
CYG c
CYG c st channel
CYG c
CYG  
CYG       sfmelt=fmelt
CYG       alt=fmeltw
CYG       f4l=ff3(sb,tmax)-ff3(sb,tmin)
CYG       f6l=ff4(sb,tmax)-ff4(sb,tmin)
CYG       f7l=ff5(sb,tmax)-ff5(sb,tmin)
CYG  
CYG       sfmelt=fmert
CYG       alt=fmertw
CYG       f4r=ff3(sb,tmax)-ff3(sb,tmin)
CYG       f6r=ff4(sb,tmax)-ff4(sb,tmin)
CYG       f7r=ff5(sb,tmax)-ff5(sb,tmin)
CYG  
CYG       wsc4=2.*dastl*f7l+dastl*gw*f4l/((sb-fms**2)**2+gw**2)
CYG      +    +2.*dbstl*etai*etak*fmi*fmk*sb*f6l
CYG      +    +2.*dastr*f7r+dastr*gw*f4r/((sb-fms**2)**2+gw**2)
CYG      +    +2.*dbstr*etai*etak*fmi*fmk*sb*f6r
CYG c
CYG c su channel
CYG c
CYG  
CYG       sfmelt=fmelu
CYG       alt=fmeluw
CYG       f5l=ff3(sb,umax)-ff3(sb,umin)
CYG       f8l=ff4(sb,umax)-ff4(sb,umin)
CYG       f9l=ff5(sb,umax)-ff5(sb,umin)
CYG  
CYG       sfmelt=fmeru
CYG       alt=fmeruw
CYG       f5r=ff3(sb,umax)-ff3(sb,umin)
CYG       f8r=ff4(sb,umax)-ff4(sb,umin)
CYG       f9r=ff5(sb,umax)-ff5(sb,umin)
CYG  
CYG       wsc5=2.*dasul*f9l+dasul*gw*f5l/((sb-fms**2)**2+gw**2)
CYG      +    +2.*dbsul*etai*etak*fmi*fmk*sb*f8l
CYG      +    +2.*dasur*f9r+dasur*gw*f5r/((sb-fms**2)**2+gw**2)
CYG      +    +2.*dbsur*etai*etak*fmi*fmk*sb*f8r
CYG  
CYG  
CYG c
CYG c tu channel integrals
CYG c
CYG       sfmelt=fmelt
CYG       alt=fmeltw
CYG       sfmelu=fmelu
CYG       alu=fmeluw
CYG       altl=alt
CYG       alul=alu
CYG       f01l=ff6(sb,tmax)-ff6(sb,tmin)
CYG       f02l=ff7(sb,tmax)-ff7(sb,tmin)
CYG  
CYG       sfmelt=fmert
CYG       alt=fmertw
CYG       sfmelu=fmeru
CYG       alu=fmeruw
CYG       altr=alt
CYG       alur=alu
CYG       f01r=ff6(sb,tmax)-ff6(sb,tmin)
CYG       f02r=ff7(sb,tmax)-ff7(sb,tmin)
CYG  
CYG       wsc6=2.*datul*etai*etak*fmi*fmk*sb*(altl*alul*f01l+f02l)
CYG      +    +2.*datur*etai*etak*fmi*fmk*sb*(altr*alur*f01r+f02r)
CYG  
CYG       wsc=wsc1+wsc2+wsc3+wsc4+wsc5+wsc6
CYG       wsc=wsc*alpha**2/32./pi/sinw**4/fmi**3
CYG  
CYG       RETURN
CYG       END
*CMZ :  1.00/00 14/04/95  18.40.00  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      double precision FUNCTION FF1(s,t)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      common/mass/fmi,fmk,fms,gw,fmelt,fmelu,alt,alu,c0
      fmikt=(2*t**2+6*fmi**2*fmk**2-3*(fmi**2+fmk**2)*t)
      alfms=(s-fms**2)**2+gw**2
      ff1=-t*fmikt/6./alfms
      return
      end
*CMZ :  1.00/00 14/04/95  18.40.00  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      double precision FUNCTION FF2(s,t)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      common/mass/fmi,fmk,fms,gw,fmelt,fmelu,alt,alu,c0
      alfms=(s-fms**2)**2+gw**2
      ff2=s*t/alfms
      return
      end
*CMZ :  1.00/00 14/04/95  18.40.00  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      double precision FUNCTION FF3(s,t)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      common/mass/fmi,fmk,fms,gw,fmelt,fmelu,alt,alu,c0
      att=datan((t-fmelt**2)/alt)
      algt=dlog((t-fmelt**2)**2+alt**2)
      dikl=(fmelt**2-fmk**2)*(fmi**2-fmelt**2)
      eikl=(fmk**2+fmi**2-2.*fmelt**2)
      ff3=(-2.*alt*t+2.*att*(alt**2+dikl)+alt*algt*eikl)/(2.*alt)
      return
      end
*CMZ :  1.00/00 14/04/95  18.40.00  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      double precision FUNCTION FF4(s,t)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      common/mass/fmi,fmk,fms,gw,fmelt,fmelu,alt,alu,c0
      attr=datan(alt/(t-fmelt**2))
      algt=dlog((t-fmelt**2)**2+alt**2)
      alfms=(s-fms**2)**2+gw**2
      bb1=-2.*gw*attr+(s-fms**2)*algt
      ff4=bb1/2./alfms
      return
      end
*CMZ :  1.00/00 14/04/95  18.40.00  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      double precision FUNCTION FF5(s,t)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      common/mass/fmi,fmk,fms,gw,fmelt,fmelu,alt,alu,c0
      att=datan((t-fmelt**2)/alt)
      algt=dlog((t-fmelt**2)**2+alt**2)
      dikl=(fmelt**2-fmk**2)*(fmi**2-fmelt**2)
      eikl=(fmk**2+fmi**2-fmelt**2)
      alfms=(s-fms**2)**2+gw**2
      bb2=2.*eikl*t-t**2-2.*alt*(fmk**2+fmi**2-2*fmelt**2)*att
     +    +(alt**2+dikl)*algt
      ff5=(s-fms**2)*bb2/2./alfms
      return
      end
*CMZ :  1.00/00 14/04/95  18.40.00  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      double precision FUNCTION FF6(s,t)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      common/mass/fmi,fmk,fms,gw,fmelt,fmelu,alt,alu,c0
      att=datan((t-fmelt**2)/alt)
      atu=datan((t+fmelu**2-c0+s)/alu)
      algt=dlog((t-fmelt**2)**2+alt**2)
      algu=dlog((t-(c0-s-fmelu**2))**2+alu**2)
      dtu=c0-s-fmelt**2-fmelu**2
      etu1=(fmelt**2+fmelu**2)**2-2*(c0-s)*(fmelt**2+fmelu**2)
     +    +((c0-s)**2+alu**2-alt**2)
      etu2=(fmelt**2+fmelu**2)**2-2*(c0-s)*(fmelt**2+fmelu**2)
     +    +((c0-s)**2+alt**2-alu**2)
      ftu1=(fmelt**2+fmelu**2)**2+(alt-alu)**2
     +    +(c0-s)*(c0-s-2*(fmelt**2+fmelu**2))
      ftu2=(fmelt**2+fmelu**2)**2+(alt+alu)**2
     +    +(c0-s)*(c0-s-2*(fmelt**2+fmelu**2))
      ff6=(alu*att*etu1+alt*atu*etu2+alu*alt*dtu
     +   *(algt-algu))/alu/alt/ftu1/ftu2
      return
      end
*CMZ :  1.00/00 14/04/95  18.40.00  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      double precision FUNCTION FF7(s,t)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      common/mass/fmi,fmk,fms,gw,fmelt,fmelu,alt,alu,c0
      att=datan((t-fmelt**2)/alt)
      atu=datan((t+fmelu**2-c0+s)/alu)
      algt=dlog((t-fmelt**2)**2+alt**2)
      algu=dlog((t-(c0-s-fmelu**2))**2+alu**2)
      etu1=(fmelt**2+fmelu**2)**2-2*(c0-s)*(fmelt**2+fmelu**2)
     +    +((c0-s)**2+alt**2-alu**2)
      etu2=(fmelt**2+fmelu**2)**2-2*(c0-s)*(fmelt**2+fmelu**2)
     +    +((c0-s)**2+alu**2-alt**2)
      ftu1=(fmelt**2+fmelu**2)**2+(alt-alu)**2
     +    +(c0-s)*(c0-s-2*(fmelt**2+fmelu**2))
      ftu2=(fmelt**2+fmelu**2)**2+(alt+alu)**2
     +    +(c0-s)*(c0-s-2*(fmelt**2+fmelu**2))
      gtu=(alt**2+alu**2)*(c0-s-fmelt**2-fmelu**2)
     +   -3.*(fmelt**2+fmelu**2)*((c0-s)**2+fmelt**2*fmelu**2)
     +   +3.*(c0-s)*(fmelt**2+fmelu**2)**2-(fmelt**6+fmelu**6)+(c0-s)**3
      ff7=(-2.*alt*etu1*att-2.*alu*etu2*atu
     +   +gtu*(algt-algu))/2./ftu1/ftu2
      return
      end
*CMZ :  1.00/00 14/04/95  19.00.47  by  Unknown
*-- Author :    Stavros Katsanevas   14/04/95
      SUBROUTINE INBOOK(NOW,FF,PDX,IGRAPH)
C   08/02/85 602032337  MEMBER NAME  INBOOK   (S)           FORTRAN
C ===================================================================
C
C     INTERFACE ROUTINE BETWEEN VEGAS AND HBOOK.
C                                M.MARTINEZ  DESY-85
C
C
C ===================================================================
C
C A)  NOW   =/=2 NORMAL BOOKKEPING
C           =  2 STOP  (TO PRINT THE HISTOGRAMS YOU MUST CALL HISTDO
C                  IN THE MAIN PROGRAM)
C
C     FF    = FUNCTION VALUE (CORRECTED BY THE SIZE OF THE
C                  INTEGRATION INTERVAL)
C
C     PDX   = SIZE OF THE INTEGRATION INTERVAL
C
C     IGRAPH=1  ONLY STATISTICS ABOUT THE INTEGRATION
C           =10 ONLY HISTOGRAMS BUT NOT STATISTICS
C
C
C
C B)  READING FORMAT FOR THE HISTOGRAM INFORMATION:
C
C   /         READ 550,NLS
C   /   550   FORMAT(I2)
C   /         READ 570,SMI(I),SMA(I),NLP(I),LDUM,LL,(LEXT(J),J=1,8)
C   /   570   FORMAT(2E12.4,3I2,8A4)
C
C
C         NLS  = # OF HISTOGRAMS  (<=10)
C
C         SMI  = MINIMUM VALUE
C
C         SMA  = MAXIMUM VALUE
C
C         NLP  = # BINS
C
C         LDUM = HISTOGRAM INFORMATION CHOICES
C              IF( | LDUMM | > 10 ) --> USUAL INFORMATION
C              IF( | LDUMM | < 10 AND ...
C                    LDUMM  > -1  --> INTEGRATED INFORMATION
C                    LDUMM  <  1  --> ERROR INFORMATION
C
C         LL   = HISTOGRAM SCALE CHOICES
C              IF( LL > 0 ) --> LINEAL SCALE
C              IF( LL < 0 ) --> LOGARITMIC SCALE
C
C         LEXT = TEXT
C
C =================================================================
C
C.... A) INBOOK ---> BOOKING THE HISTOGRAMS  =========================
C
      IMPLICIT double precision(A-G,O-Z)
      REAL*4 XX,YY,ZSIG,EIT,EIA
      COMMON/PAWC/HMEMOR(30000)
      COMMON/RESULT1/CHI2A,Y,SI,U,V
      COMMON/INPARM1/ALPH
      COMMON/RESULT2/IT0
      COMMON/INPARM/ITMX0
 
      COMMON /LPLOT/XL(10)
      DIMENSION NLP(10),SMA(10),SMI(10),DEL(10),ZSIG(50),LEXT(8)
      DIMENSION NLSN(50,10),MLSN(50,10),XLS(50,10),YLS(50,10)
      DIMENSION XLSS(50,10),YLSS(50,10),EIT(100),EIA(100)
CC
      CALL HLIMIT(30000)
 
      IF(IGRAPH.EQ.10)GO TO 10
      ZIT=ITMX0+1.
      CALL HBOOK1(777,'PARTIAL INTEGRAL EVOLUTION',ITMX0,1.,ZIT,0.)
      CALL HBOOK1(778,'ACCUMULATED INTEGRAL EVOLUTION',ITMX0,1.,ZIT,0.)
      CALL HBOOK1(779,'CHI**2 EVOLUTION',ITMX0,1.,ZIT,0.)
      IF(IGRAPH.EQ.1)RETURN
   10 CONTINUE
 
      NLS=10
      DO 20  I=1,NLS
        II=10*I
        NLP(I)=40
        SMI(I)=0.
        SMA(I)=1.
        CALL HBOOK1(II,' ',NLP(I),SMI(I),SMA(I),0.)
        DEL(I)=(SMA(I)-SMI(I))/NLP(I)
   20 CONTINUE
      RETURN
C
C.... B) REBOOK --> RESETING STORAGE MATRICES AFTER EACH ITERATION ===
C
      ENTRY REBOOK(NOW,FF,PDX,IGRAPH)
      IF(IGRAPH.EQ.1)RETURN
      DO 30  I=1,NLS
        NLPS=NLP(I)+2
        DO 30  J=1,NLPS
          XLS(J,I)=0.
          XLSS(J,I)=0.
          NLSN(J,I)=0
   30 CONTINUE
      RETURN
C
C.... C) XBOOK ---> FILLING STORAGE MATRICES =========================
C
      ENTRY XBOOK(NOW,FF,PDX,IGRAPH)
      IF(IGRAPH.EQ.1)RETURN
      IF(FF.LT.0.D0)PRINT 10000
10000 FORMAT('    WARNING !!!!  ======  FUN < 0 ')
      DO 50  I=1,NLS
        NLPS=(XL(I)-SMI(I))/DEL(I)+1.
        IF(NLPS.LT.0)NLPS=0
        IF(NLPS.GT.NLP(I))NLPS=NLP(I)+1
        NLPS=NLPS+1
        FUN=FF/DEL(I)
        XLS(NLPS,I)=XLS(NLPS,I)+FUN
        IF(PDX.EQ.0.D0)GO TO 40
        XLSS(NLPS,I)=XLSS(NLPS,I)+FUN*FUN/PDX
   40   NLSN(NLPS,I)=NLSN(NLPS,I)+1
   50 CONTINUE
      RETURN
C
C.... D1) BOOKIT ---> ACCUMULATING ITERATIONS INFORMATION ============
C
      ENTRY BOOKIT(NOW,FF,PDX,IGRAPH)
      IF(IGRAPH.EQ.10)GO TO 60
      ZIT0=1.*IT0
      EIT(IT0)=V
      CALL HF1(777,ZIT0,U)
      EIA(IT0)=SI
      CALL HF1(778,ZIT0,Y)
      CALL HF1(779,ZIT0,CHI2A)
      IF(IGRAPH.EQ.1.AND.NOW.NE.2)RETURN
      IF(IGRAPH.EQ.1.AND.NOW.EQ.2)GOTO 160
C
   60 CONTINUE
      DO 70  I=1,NLS
        NLPS=NLP(I)+2
        DO 70  J=1,NLPS
          DEN=XLSS(J,I)-XLS(J,I)*XLS(J,I)
          IF(DEN.GT.1.D20)DEN=1.D20
          IF(DEN.LT.1.D-20)DEN=1.D-20
          XLSS(J,I)=0.
          IF(DEN.NE.0.D0)XLSS(J,I)=1./DEN
   70 CONTINUE
C
      IF(KK.GT.0)GO TO 90
      DO 80  I=1,NLS
        NLPS=NLP(I)+2
        DO 80  J=1,NLPS
          MLSN(J,I)=NLSN(J,I)
          YLS(J,I)=XLS(J,I)
          YLSS(J,I)=XLSS(J,I)
   80 CONTINUE
      GO TO 120
   90 VBEF=VTOT
      VU=(V/U)**2
      BE1=U*U
      BE2=Y*Y
      DO 110 I=1,NLS
        NLPS=NLP(I)+2
        DO 110 J=1,NLPS
          IF(NLSN(J,I).EQ.0) GO TO 110
          IF(MLSN(J,I).EQ.0) GO TO 100
          AL1=VU/NLSN(J,I)
          AL2=VBEF/MLSN(J,I)
          MLSN(J,I)=MLSN(J,I)+NLSN(J,I)
          YLS(J,I)=(AL2*XLS(J,I)+AL1*YLS(J,I))/(AL1+AL2)
C     YLSS(J,I)=(BE2*YLSS(J,I)+BE1*XLSS(J,I))/(BE2+BE1)
          YLSS(J,I)=YLSS(J,I)+XLSS(J,I)
          GO TO 110
  100     MLSN(J,I)=NLSN(J,I)
          YLS(J,I)=XLS(J,I)
          YLSS(J,I)=XLSS(J,I)
  110 CONTINUE
  120 CONTINUE
      VTOT=(SI/Y)**2
CC
      KK=KK+1
      IF(NOW.NE.2)RETURN
CC
C
C.... D2) BOOKIT ---> FILLING AND PRINTING HISTOGRAMS ================
C
      DO 150 I=1,NLS
        NLPS=NLP(I)+2
        NHI=10*I
        DO 140 J=1,NLPS
          XX=SNGL(SMI(I)+DEL(I)*(J-1.5))
          YY=SNGL(YLS(J,I))
          CALL HF1(NHI,XX,YY)
          JJ=J-1
          IF(JJ.EQ.0.OR.JJ.GT.NLP(I))GO TO 130
          ZSIG(JJ)=0.
          IF(MLSN(J,I).NE.0.AND.YLSS(J,I).NE.0.D0) ZSIG(JJ)=SNGL(1./
     +    DSQRT(YLSS(J,I)*MLSN(J,I)))
  130     CONTINUE
  140   CONTINUE
        CALL HPAKE(NHI,ZSIG)
  150 CONTINUE
      IF(IGRAPH.EQ.10)GOTO 170
C
  160 CALL HPAKE(777,EIT)
      CALL HPAKE(778,EIA)
  170 CONTINUE
 
      RETURN
      END
*CMZ :  1.00/00 14/04/95  18.46.28  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      SUBROUTINE VEGAS(FXN,ACC,NDIM,NCALL,ITMX,NPRN,IGRAPH,sgv,sdd,itt)
C   01/12/84 602042308  MEMBER NAME  VEGAS    (S)           FORTRAN
C ===================================================================
C
C     VEGAS VERSION INCLUDING HBOOK CALLS POSSIBILITY,
C     SIMPLIFIED BUT MORE CLEAR AND EQUALLY EFFICIENT.
C
C                              M.MARTINEZ  DESY-85
C ===================================================================
C
C     FXN   = FUNCTION TO BE INTEGRATED/MAPPED
C     ACC   = RELATIVE ACCURACY REQUESTED
C     NDIM  = # DIMENSIONS
C     NCALL = MAXIMUM TOTAL # OF CALLS TO THE FUNCTION PER ITERATION
C     ITMX  = MAXIMUM # OF ITERATIONS ALLOWED
C     NPRN  = PRINTOUT LEVEL:
C             =0  ONLY FINAL RESULTS
C            >=1  ADDITIONNALLY INF. ABOUT INPUT PARAMETERS
C            >=2  ADDITIONNALLY INF. ABOUT ACCUMULATED VALUES
C                  PER ITERATION.
C            >=3  ADDITIONNALLY INF. ABOUT PARTIAL VALUES
C                  PER ITERATION.
C            >=5  ADDITIONNALLY INF. ABOUT FINAL BIN DISTRIBUTION
C                  (NUMERICAL MAPPING).
C     IGRAPH= HISTOGRAMMATION LEVEL:
C             =0  NO HISTOGRAMS AT ALL
C             =1  ONLY STATISTICS ABOUT THE INTEGRATION
C             =10 ONLY HISTOGRAMS DEFINED BUT NOT STATISTICS
C
C
C ===================================================================
 
      IMPLICIT double precision(A-H,O-Z)
      COMMON/RESULT1/CHI2A,Y,SI,U,V
      COMMON/INPARM1/ALPH
      COMMON/RESULT2/IT0
      COMMON/INPARM/ITMX0
 
      COMMON/OUTMAP/ND,NDIM0,XI(50,10)
 
      DIMENSION X(10),XIN(50),R(50),IA(10),D(50,10)
      DATA ALPH0/1.5/,INIT/0/
 
      dimension xio(50,10)
      equivalence(xi(1,1),xio(1,1))
 
      ND=50
C===========================================================
C A))  INITIALIZING SOME VARIABLES
C===========================================================
      ITMX0=ITMX
      NDIM0=NDIM
      IF(ALPH.EQ.0.)ALPH=ALPH0
 
      CALLS=dble(NCALL)
 
      XND=ND
      NDM=ND-1
      IF(IGRAPH.NE.0)CALL INBOOK(0,FUN,WEIGHT,IGRAPH)
C.............................................
C  INITIALIZING CUMMULATIVE VARIABLES
C.............................................
      IT=0
      SI=0.
      SI2=0.
      SWGT=0.
      SCHI=0.
      SCALLS=0.
      NZEROT=0
      FMAXT=0.
      FMINT=1.D20
C.............................................
C  DEFINING THE INITIAL INTERVALS DISTRIBUTION
C.............................................
      RC=1./XND
      DO 10 J=1,NDIM
        XI(ND,J)=1.
        DR=0.
        DO 10 I=1,NDM
          DR=DR+RC
          XI(I,J)=DR
   10 CONTINUE
c      IF(INIT.EQ.0)PRINT 407
      INIT=1
      IF(NPRN.GE.1)PRINT 10100,NDIM,NCALL,ITMX,ND
C===========================================================
C B))  ITERATIONS LOOP
C===========================================================
   20 IT=IT+1
C.............................................
C  INITIALIZING ITERATION VARIABLES
C.............................................
      TI=0.
      SFUN2=0.
      NZERO=0
      FMAX=0.
      FMIN=1.D20
      DO 30 J=1,NDIM
        DO 30 I=1,ND
          D(I,J)=0.
   30 CONTINUE
      IF(IGRAPH.NE.0)CALL REBOOK(0,FUN,WEIGHT,IGRAPH)
      DO 60 JJ=1,NCALL
        WGT=1.
C.............................................
C  COMPUTING THE POINT POSITION
C.............................................
        DO 40 J=1,NDIM
          XN=rndm(0)*XND+1.
          IA(J)=XN
          XIM1=0.
          IF(IA(J).GT.1)XIM1=XI(IA(J)-1,J)
          XO=XI(IA(J),J)-XIM1
          X(J)=XIM1+(XN-IA(J))*XO
          WGT=WGT*XO*XND
   40   CONTINUE
C.............................................
C  COMPUTING THE FUNCTION VALUE
C.............................................
        FUN=FXN(X)
c      if(fun.le.1.E-11)fun=0.
        IF(FMAX.LT.FUN)FMAX=FUN
        IF(FMIN.GT.FUN)FMIN=FUN
        FUN=FUN*WGT/CALLS
        IF(FUN.NE.0.)NZERO=NZERO+1
        FUN2=FUN*FUN
        WEIGHT=WGT/CALLS
        IF(IGRAPH.NE.0)CALL XBOOK(0,FUN,WEIGHT,IGRAPH)
        TI=TI+FUN
        SFUN2=SFUN2+FUN2
        DO 50 J=1,NDIM
          IAJ=IA(J)
          D(IAJ,J)=D(IAJ,J)+FUN2
   50   CONTINUE
   60 CONTINUE
C.............................................
C  COMPUTING THE INTEGRAL AND ERROR VALUES
C.............................................
      IF (SFUN2.NE.0.)GO TO 70
      PRINT 10800
      sgv=0.
      return
   70 CONTINUE
      TI2=TI*TI
      TICAL=(SFUN2*CALLS-TI2)/(CALLS-1.)
c melachroinos corrections
      TSI=0.
      IF(TICAL.GT.0)TSI=DSQRT((SFUN2*CALLS-TI2)/(CALLS-1.))
c
      WGT=TI2/TSI**2
      SI=SI+TI*WGT
      SI2=SI2+TI2
      SWGT=SWGT+WGT
      SCHI=SCHI+TI2*WGT
      SCALLS=SCALLS+CALLS
      AVGI=SI/SWGT
      SD=SWGT*IT/SI2
      CHI2A=0.
      IF(IT.GT.1)CHI2A=SD*(SCHI/SWGT-AVGI*AVGI)/(IT-1)
      SD=1./DSQRT(SD)
      ERR=SD*100./AVGI
      NZEROT=NZEROT+NZERO
      IF(FMAXT.LT.FMAX)FMAXT=FMAX
      IF(FMINT.GT.FMIN)FMINT=FMIN
      IT0=IT
C.............................................
C  PRINTING AND HISTOGRAMMING
C.............................................
      sgv=avgi
 
      IF(NPRN.GE.2)PRINT 10200,IT,AVGI,SD,ERR
      IF(NPRN.GE.3)PRINT 10300,TI,TSI,NZERO,FMIN,FMAX,CHI2A
      IF(NPRN.LT.5) GO TO 100
      DO 90 J=1,NDIM
        PRINT 10400,J
        XIN(1)=XI(1,J)
        DO 80   L=2,ND
   80   XIN(L)=XI(L,J)-XI(L-1,J)
   90 PRINT 10500,(XI(I,J),XIN(I),D(I,J),I=1,ND)
  100 CONTINUE
      IF(DABS(SD/AVGI).GT.DABS(ACC).AND.IT.LT.ITMX)GO TO 110
      NPIT=IT*NCALL
      EFF=NZEROT*100./NPIT
      IF(NPRN.GE.2)PRINT 10600,NPIT,NZEROT,EFF,FMINT,FMAXT
c      PRINT 777,AVGI,SD,CHI2A
      SDD=SD
      ITT=IT
      IF(IGRAPH.NE.0)CALL BOOKIT(2,FUN,WEIGHT,IGRAPH)
      RETURN
  110 CONTINUE
      IF(IGRAPH.NE.0)CALL BOOKIT(0,FUN,WEIGHT,IGRAPH)
C===========================================================
C C))  REDEFINING THE GRID
C===========================================================
C.............................................
C  SMOOTHING THE F**2 VALUED STORED FOR EACH INTERVAL
C.............................................
      DO 130 J=1,NDIM
        XO=D(1,J)
        XN=D(2,J)
        D(1,J)=(XO+XN)/2.
        X(J)=D(1,J)
        DO 120 I=2,NDM
          D(I,J)=XO+XN
          XO=XN
          XN=D(I+1,J)
          D(I,J)=(D(I,J)+XN)/3.
          X(J)=X(J)+D(I,J)
  120   CONTINUE
        D(ND,J)=(XN+XO)/2.
        X(J)=X(J)+D(ND,J)
  130 CONTINUE
C.............................................
C  COMPUTING THE 'IMPORTANCE FUNCTION' OF EACH INTERVAL
C.............................................
      DO 190 J=1,NDIM
        RC=0.
        DO 150 I=1,ND
          R(I)=0.
          IF(D(I,J).LE.0.) GO TO 140
          XO=X(J)/D(I,J)
          R(I)=((XO-1.)/XO/DLOG(XO))**ALPH
  140     RC=RC+R(I)
  150   CONTINUE
C.............................................
C  REDEFINING THE SIZE OF EACH INTERVAL
C.............................................
        RC=RC/XND
        K=0
        XN=0.
        DR=0.
        I=0
  160   K=K+1
        DR=DR+R(K)
        XO=XN
        XN=XI(K,J)
  170   IF(RC.GT.DR) GO TO 160
        I=I+1
        DR=DR-RC
        XIN(I)=XN-(XN-XO)*DR/R(K)
        IF(I.LT.NDM) GO TO 170
        DO 180 I=1,NDM
          XI(I,J)=XIN(I)
  180   CONTINUE
        XI(ND,J)=1.
  190 CONTINUE
C
      GO TO 20
C===========================================================
C D))  FORMATS FOR THE PRINTOUTS
C===========================================================
10000 FORMAT('1  %%%%  ROUTINE "VEGAS" V.1-85 FROM P.G.LEPAGE',
     + '    (MOD.BY M.MARTINEZ)'/)
10100 FORMAT('0  %%%%  INTEGRATION PARAMETERS :'/
     + '   # DIMENSIONS                =',I8/,
     + '   # CALLS TO F PER ITERATION  =',I8/,
     + '   # ITERATIONS MAXIMUM        =',I8/,
     + '   # BINS IN EACH DIMENSION    =',I8)
10200 FORMAT(//' ITER. NO',I3,' ACC.RESULTS==> INT =',G14.5,'+/-',G10.4,
     + '   % ERROR=',G10.2)
10300 FORMAT(/20X,'ITER.RESULTS=',G14.5,'+/-',G10.4,
     + '   (F=/=0)=',I6/20X,'   FMIN=',G10.4,'   FMAX=',G10.4,
     + '   CHI**2=',G10.2)
10400 FORMAT(14H0DATA FOR AXIS,I2 /
     + 7X,'X',9X,'DELT X',6X,'SIG(F2)',
     + 13X,'X',9X,'DELT X',6X,'SIG(F2)'/)
10500 FORMAT(1X,3G12.4,5X,3G12.4)
10600 FORMAT(//'  %%%% FINAL INFORMATION : IN TOTAL '/
     + '  #FUNCTION CALLS =',I6,'  #(F=/=0) =',I6,'  % =',G10.4/
     + 5X,'  FMIN=',G10.4,'   FMAX=',G10.4)
10700 FORMAT(' '//' ',30('+'),' FINAL RESULT ',30('+')//
     + ' INTEGRAL VALUE =',G14.5,'+/-',G10.4,6X,
     + ' ( CHI**2=',G10.4,')'//' ',74('+'))
10800 FORMAT(//
     + '  ## WARNING: IN "VEGAS" THE VALUE OF THE INTEGRAL'/
     + '  IS EXACTLY ZERO, SO NO EVOLUTION OF THE DENSITY '/
     + '  DISTRIBUTION CAN BE EXPECTED ---> PROGRAM STOP ')
      END
*CMZ :  1.00/00 14/04/95  18.46.28  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
      subroutine GVEG(Z,xi,xlim)
C===========================================================
C   SUBROUTINE TO USE THE VEGAS-COMPUTED GRID TO
C   Generate partial distributions
C
C                                S. Katsanevas
C===========================================================
      IMPLICIT double precision(A-H,O-Z)
      DIMENSION Z(10),XI(50,2),xlim(2,2)
      real rndm
      data nd,ndim/50,2/
 
      DO 10 I=1,NDIM
        XJ=dble(rndm(0))*ND+1
        J=XJ
        if(j.gt.nd+1)j=nd+1
        XI0=1.0001*xlim(1,I)
        XIM=0.9999*xlim(2,i)
        IF(j.gt.1)XI0=XI(J-1,I)
        if(j.le.50)XIM=XI(j,i)
        DD=XIM-XI0
        Z(I)=XI0+DD*(XJ-J)
   10 CONTINUE
      RETURN
      END
*CMZ :  1.00/00 14/04/95  18.46.28  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
C***********************************************************************
CYG       block data susygdat
CYG  
CYG       IMPLICIT DOUBLE PRECISION (A-H,O-Z)
CYG  
CYG c
CYG c reorder sparticles and particles
CYG c
CYG  
CYG       common/reorder/ispa(12,2),kl(2,18),klap(2,18),idecs(12,2)
CYG  
CYG  
CYG       COMMON/SM/FMW,FMZ,GAMMAZ,GAMMAW,SINW,COSW,ALPHA,E2,G2,PI,TWOPI,
CYG      +FLC(12),FRC(12),gms(12),echar(12)
CYG  
CYG  
CYG  
CYG        common/spartcl/fmal(12),fmar(12),ratq(12),fgamc(12),fgamcr(12)
CYG      +,cosmi(12)
CYG  
CYG  
CYG        COMMON/SFLOOP/ILOOP
CYG c
CYG c reorder sparticles and particles
CYG c
CYG c      PARAMETER (IDUP=2,IDDN=1,IDST=3,IDCH=4,IDBT=5,IDTP=6)
CYG c      PARAMETER (IDNE=12,IDE=11,IDNM=14,IDMU=13,IDNT=16,IDTAU=15)
CYG  
CYG       data kl/2,-2,1,-1,12,-12,11,-11,2,-1,12,-11,
CYG      +        4,-4,3,-3,14,-14,13,-13,4,-3,14,-13,
CYG      +        6,-6,5,-5,16,-16,15,-15,6,-5,16,-15/
CYG  
CYG c      PARAMETER (ISUPL=42,ISDNL=41,ISSTL=43,ISCHL=44,ISBTL=45,ISTPL=46)
CYG c      PARAMETER (ISNEL=52,ISEL=51,ISNML=54,ISMUL=53,ISNTL=56,ISTAUL=55)
CYG c      PARAMETER (ISUPR=48,ISDNR=47,ISSTR=49,ISCHR=50,ISBTR=61,ISTPR=62)
CYG c      PARAMETER (ISER=57,ISMUR=58,ISTAUR=59)
CYG  
CYG       data ispa/42,41,52,51,44,43,54,53,46,45,56,55,
CYG      +          48,47, 0,57,50,49, 0,58,62,61, 0,59/
CYG  
CYG  
CYG  
CYG       data klap/42,42,41,41,52,52,51,51,42,41,52,51,
CYG      +          44,44,43,43,54,54,53,53,44,43,54,53,
CYG      +          46,46,45,45,56,56,55,55,46,45,56,55/
CYG  
CYG       data idecs/2,1,12,11,4,3,14,13,4,5,16,15,
CYG      +           1,2,11,12,3,4,13,14,5,6,15,16/
CYG  
CYG  
CYG C
CYG C STANDARD PARTICLE MASSES
CYG C
CYG  
CYG       DATA GMS/.0099d0,.0056d0,0.d0,.0005d0,1.35d0,
CYG      +         .199d0,0.d0,.105d0,174.d0,5.d0,0.d0,1.777d0/
CYG  
CYG       data fmal/12*1.d0/
CYG       data fmar/12*1.d0/
CYG       data iloop/1/
CYG  
CYG  
CYG       end
*CMZ :  1.00/00 14/04/95  18.40.01  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
CDECK  ID>, PYDATA.
C*********************************************************************
 
CYG       BLOCK DATA PYDATA
CYG  
CYG C...Give sensible default values to all status codes and parameters.
CYG       COMMON/PYSUBS/MSEL,MSUB(200),KFIN(2,-40:40),CKIN(200)
CYG       COMMON/PYPARS/MSTP(200),PARP(200),MSTI(200),PARI(200)
CYG       COMMON/PYINT1/MINT(400),VINT(400)
CYG       COMMON/PYINT2/ISET(200),KFPR(200,2),COEF(200,20),ICOL(40,4,2)
CYG       COMMON/PYINT3/XSFX(2,-40:40),ISIG(1000,3),SIGH(1000)
CYG       COMMON/PYINT4/WIDP(21:40,0:40),WIDE(21:40,0:40),WIDS(21:40,3)
CYG       COMMON/PYINT5/NGEN(0:200,3),XSEC(0:200,3)
CYG       COMMON/PYINT6/PROC(0:200)
CYG       CHARACTER PROC*28
CYG       COMMON/PYINT7/SIGT(0:6,0:6,0:5)
CYG       SAVE /PYSUBS/,/PYPARS/,/PYINT1/,/PYINT2/,/PYINT3/,/PYINT4/,
CYG      &/PYINT5/,/PYINT6/,/PYINT7/
CYG  
CYG C...Default values for allowed processes and kinematics constraints.
CYG       DATA MSEL/1/
CYG       DATA MSUB/200*0/
CYG       DATA ((KFIN(I,J),J=-40,40),I=1,2)/16*0,4*1,4*0,6*1,5*0,5*1,0,
CYG      &5*1,5*0,6*1,4*0,4*1,16*0,16*0,4*1,4*0,6*1,5*0,5*1,0,5*1,5*0,
CYG      &6*1,4*0,4*1,16*0/
CYG       DATA CKIN/
CYG      &   2.0, -1.0,  0.0, -1.0,  1.0,  1.0, -10.,  10., -10.,  10.,
CYG      1  -10.,  10., -10.,  10., -10.,  10., -1.0,  1.0, -1.0,  1.0,
CYG      2   0.0,  1.0,  0.0,  1.0, -1.0,  1.0, -1.0,  1.0,   0.,   0.,
CYG      3   2.0, -1.0,   0.,   0.,  0.0, -1.0,  0.0, -1.0,   0.,   0.,
CYG      4  12.0, -1.0, 12.0, -1.0, 12.0, -1.0, 12.0, -1.0,   0.,   0.,
CYG      5   0.0, -1.0,  0.0, -1.0,  0.0, -1.0,   0.,   0.,   0.,   0.,
CYG      6   140*0./
CYG  
CYG C...Default values for main switches and parameters. Reset information.
CYG       DATA (MSTP(I),I=1,100)/
CYG      &     3,    1,    2,    0,    0,    0,    0,    0,    0,    0,
CYG      1     1,    0,    1,    0,    0,    0,    0,    0,    0,    0,
CYG      2     1,    0,    1,    0,    0,    0,    0,    0,    0,    1,
CYG      3     1,    2,    0,    1,    0,    2,    1,    5,    0,    0,
CYG      4     1,    1,    3,    7,    3,    1,    1,    2,    2,    0,
CYG      5     9,    1,    1,    1,    1,    1,    1,    6,    0,    0,
CYG      6     1,    3,    2,    2,    1,    1,    2,    0,    0,    0,
CYG      7     1,    0,    0,    0,    0,    0,    0,    0,    0,    0,
CYG      8     1,    1,  100,    0,    0,    0,    0,    0,    0,    0,
CYG      9     1,    4,    1,    0,    0,    0,    0,    0,    0,    0/
CYG       DATA (MSTP(I),I=101,200)/
CYG      &     3,    1,    0,    0,    0,    0,    0,    0,    0,    0,
CYG      1     1,    1,    1,    0,    0,    0,    0,    0,    0,    0,
CYG      2     0,    1,    2,    1,    1,   20,    0,    0,   10,    0,
CYG      3     0,    4,    0,    1,    0,    0,    0,    0,    0,    0,
CYG      4     0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
CYG      5     0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
CYG      6     0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
CYG      7     0,    2,    0,    0,    0,    0,    0,    0,    0,    0,
CYG      8     5,  702, 1994,   02,   13,  400,    0,    0,    0,    0,
CYG      9     0,    0,    0,    0,    0,    0,    0,    0,    0,    0/
CYG       DATA (PARP(I),I=1,100)/
CYG      &  0.25,  10.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,
CYG      1    0.,   0.,  1.0, 0.01,  0.5,  1.0,   0.,   0.,   0.,   0.,
CYG      2    0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,
CYG      3   1.5,  2.0, 0.075,  0.,  0.2,   0.,  2.0, 0.70, 0.006,  0.,
CYG      4  0.02,  2.0, 0.10, 1000., 2054., 123., 246., 0.,   0.,   0.,
CYG      5   1.0,   0.,   0.,   0.,   0.,   0.,   0.,   0.,  1.0,   0.,
CYG      6  0.25,  1.0, 0.25,  1.0,  2.0, 1E-3,  4.0, 1E-3,   0.,   0.,
CYG      7   4.0,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,
CYG      8  1.40, 1.55,  0.5,  0.2, 0.33, 0.66,  0.7,  0.5,   0.,   0.,
CYG      9  0.44, 0.20,  2.0,  1.0,   0.,  3.0,  1.0, 0.75, 0.44,  2.0/
CYG       DATA (PARP(I),I=101,200)/
CYG      &   0.5, 0.28,  1.0,   0.,   0.,   0.,   0.,   0.,   0.,   0.,
CYG      1   2.0,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,
CYG      2   1.0,  0.4,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,
CYG      3  0.01,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,
CYG      4    0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,
CYG      5    0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,
CYG      6  2.20, 23.6, 18.4, 11.5,   0.,   0.,   0.,   0.,   0.,   0.,
CYG      7    0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,
CYG      8    0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,
CYG      9    0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0./
CYG       DATA MSTI/200*0/
CYG       DATA PARI/200*0./
CYG       DATA MINT/400*0/
CYG       DATA VINT/400*0./
CYG  
CYG C...Constants for the generation of the various processes.
CYG       DATA (ISET(I),I=1,100)/
CYG      &    1,    1,    1,   -1,    3,   -1,   -1,    3,   -2,    2,
CYG      1    2,    2,    2,    2,    2,    2,   -1,    2,    2,    2,
CYG      2   -1,    2,    2,    2,    2,    2,   -1,    2,    2,    2,
CYG      3    2,   -1,    2,    2,    2,    2,   -1,   -1,   -1,   -1,
CYG      4   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
CYG      5   -1,   -1,    2,    2,   -1,   -1,   -1,    2,   -1,   -1,
CYG      6   -1,   -1,   -1,   -1,   -1,   -1,   -1,    2,    2,    2,
CYG      7    4,    4,    4,   -1,   -1,    4,    4,   -1,   -1,    2,
CYG      8    2,    2,    2,    2,    2,    2,    2,    2,    2,   -2,
CYG      9    0,    0,    0,    0,    0,    9,   -2,   -2,   -2,   -2/
CYG       DATA (ISET(I),I=101,200)/
CYG      &   -1,    1,    1,   -2,   -2,   -2,   -2,   -2,   -2,    2,
CYG      1    2,    2,    2,    2,    2,   -1,   -1,   -1,   -2,   -2,
CYG      2    5,    5,    5,    5,   -2,   -2,   -2,   -2,   -2,   -2,
CYG      3    6,   -2,   -2,   -2,   -2,   -2,   -2,   -2,   -2,   -2,
CYG      4    1,    1,    1,    1,    1,   -2,    1,    1,    1,   -2,
CYG      5    1,    1,    1,   -2,   -2,    1,    1,    1,   -2,   -2,
CYG      6    2,    2,    2,    2,    2,    2,   -2,   -2,   -2,   -2,
CYG      7    2,    2,    5,    5,   -2,    2,    2,    5,    5,   -2,
CYG      8    5,    5,   -2,   -2,   -2,    5,    5,   -2,   -2,   -2,
CYG      9   -2,   -2,   -2,   -2,   -2,   -2,   -2,   -2,   -2,   -2/
CYG       DATA ((KFPR(I,J),J=1,2),I=1,50)/
CYG      &   23,    0,   24,    0,   25,    0,   24,    0,   25,    0,
CYG      &   24,    0,   23,    0,   25,    0,    0,    0,    0,    0,
CYG      1    0,    0,    0,    0,   21,   21,   21,   22,   21,   23,
CYG      1   21,   24,   21,   25,   22,   22,   22,   23,   22,   24,
CYG      2   22,   25,   23,   23,   23,   24,   23,   25,   24,   24,
CYG      2   24,   25,   25,   25,    0,   21,    0,   22,    0,   23,
CYG      3    0,   24,    0,   25,    0,   21,    0,   22,    0,   23,
CYG      3    0,   24,    0,   25,    0,   21,    0,   22,    0,   23,
CYG      4    0,   24,    0,   25,    0,   21,    0,   22,    0,   23,
CYG      4    0,   24,    0,   25,    0,   21,    0,   22,    0,   23/
CYG       DATA ((KFPR(I,J),J=1,2),I=51,100)/
CYG      5    0,   24,    0,   25,    0,    0,    0,    0,    0,    0,
CYG      5    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
CYG      6    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
CYG      6    0,    0,    0,    0,   21,   21,   24,   24,   23,   24,
CYG      7   23,   23,   24,   24,   23,   24,   23,   25,   22,   22,
CYG      7   23,   23,   24,   24,   24,   25,   25,   25,    0,  211,
CYG      8    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
CYG      8  443,   21,10441,   21,20443,   21,  445,   21,    0,    0,
CYG      9    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
CYG      9    0,    0,    0,    0,    0,    0,    0,    0,    0,    0/
CYG       DATA ((KFPR(I,J),J=1,2),I=101,150)/
CYG      &   23,    0,   25,    0,   25,    0,    0,    0,    0,    0,
CYG      &    0,    0,    0,    0,    0,    0,    0,    0,   22,   25,
CYG      1   21,   25,    0,   25,   21,   25,   22,   22,   21,   22,
CYG      1   22,   23,   23,   23,   24,   24,    0,    0,    0,    0,
CYG      2   25,    6,   25,    6,   25,    0,   25,    0,    0,    0,
CYG      2    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
CYG      3   23,    5,    0,    0,    0,    0,    0,    0,    0,    0,
CYG      3    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
CYG      4   32,    0,   34,    0,   37,    0,   40,    0,   39,    0,
CYG      4    0,    0,    7,    0,    8,    0,   38,    0,    0,    0/
CYG       DATA ((KFPR(I,J),J=1,2),I=151,200)/
CYG      5   35,    0,   35,    0,   35,    0,    0,    0,    0,    0,
CYG      5   36,    0,   36,    0,   36,    0,    0,    0,    0,    0,
CYG      6    6,   37,   39,    0,   39,   39,   39,   39,   11,    0,
CYG      6   11,    0,    0,    0,    0,    0,    0,    0,    0,    0,
CYG      7   23,   35,   24,   35,   35,    0,   35,    0,    0,    0,
CYG      7   23,   36,   24,   36,   36,    0,   36,    0,    0,    0,
CYG      8   35,    6,   35,    6,    0,    0,    0,    0,    0,    0,
CYG      8   36,    6,   36,    6,    0,    0,    0,    0,    0,    0,
CYG      9    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
CYG      9    0,    0,    0,    0,    0,    0,    0,    0,    0,    0/
CYG       DATA COEF/4000*0./
CYG       DATA (((ICOL(I,J,K),K=1,2),J=1,4),I=1,40)/
CYG      1 4,0,3,0,2,0,1,0,3,0,4,0,1,0,2,0,2,0,0,1,4,0,0,3,3,0,0,4,1,0,0,2,
CYG      2 3,0,0,4,1,4,3,2,4,0,0,3,4,2,1,3,2,0,4,1,4,0,2,3,4,0,3,4,2,0,1,2,
CYG      3 3,2,1,0,1,4,3,0,4,3,3,0,2,1,1,0,3,2,1,4,1,0,0,2,2,4,3,1,2,0,0,1,
CYG      4 3,2,1,4,1,4,3,2,4,2,1,3,4,2,1,3,3,4,4,3,1,2,2,1,2,0,3,1,2,0,0,0,
CYG      5 4,2,1,0,0,0,1,0,3,0,0,3,1,2,0,0,4,0,0,4,0,0,1,2,2,0,0,1,4,4,3,3,
CYG      6 2,2,1,1,4,4,3,3,3,3,4,4,1,1,2,2,3,2,1,3,1,2,0,0,4,2,1,4,0,0,1,2,
CYG      7 4,0,0,0,4,0,1,3,0,0,3,0,2,4,3,0,3,4,0,0,1,0,0,1,0,0,3,4,2,0,0,2,
CYG      8 3,0,0,0,1,0,0,0,0,0,3,0,2,0,0,0,2,0,3,1,2,0,0,0,3,2,1,0,1,0,0,0,
CYG      9 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
CYG      & 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0/
CYG  
CYG C...Character constants: name of processes.
CYG       DATA PROC(0)/                    'All included subprocesses   '/
CYG       DATA (PROC(I),I=1,20)/
CYG      1'f + f~ -> gamma*/Z0         ',  'f + f~'' -> W+/-             ',
CYG      2'f + f~ -> H0                ',  'gamma + W+/- -> W+/-        ',
CYG      3'Z0 + Z0 -> H0               ',  'Z0 + W+/- -> W+/-           ',
CYG      4'                            ',  'W+ + W- -> H0               ',
CYG      5'                            ',  'f + f'' -> f + f'' (QFD)      ',
CYG      6'f + f'' -> f + f'' (QCD)      ','f + f~ -> f'' + f~''          ',
CYG      7'f + f~ -> g + g             ',  'f + f~ -> g + gamma         ',
CYG      8'f + f~ -> g + Z0            ',  'f + f~'' -> g + W+/-         ',
CYG      9'f + f~ -> g + H0            ',  'f + f~ -> gamma + gamma     ',
CYG      &'f + f~ -> gamma + Z0        ',  'f + f~'' -> gamma + W+/-     '/
CYG       DATA (PROC(I),I=21,40)/
CYG      1'f + f~ -> gamma + H0        ',  'f + f~ -> Z0 + Z0           ',
CYG      2'f + f~'' -> Z0 + W+/-        ', 'f + f~ -> Z0 + H0           ',
CYG      3'f + f~ -> W+ + W-           ',  'f + f~'' -> W+/- + H0        ',
CYG      4'f + f~ -> H0 + H0           ',  'f + g -> f + g              ',
CYG      5'f + g -> f + gamma          ',  'f + g -> f + Z0             ',
CYG      6'f + g -> f'' + W+/-          ', 'f + g -> f + H0             ',
CYG      7'f + gamma -> f + g          ',  'f + gamma -> f + gamma      ',
CYG      8'f + gamma -> f + Z0         ',  'f + gamma -> f'' + W+/-      ',
CYG      9'f + gamma -> f + H0         ',  'f + Z0 -> f + g             ',
CYG      &'f + Z0 -> f + gamma         ',  'f + Z0 -> f + Z0            '/
CYG       DATA (PROC(I),I=41,60)/
CYG      1'f + Z0 -> f'' + W+/-         ', 'f + Z0 -> f + H0            ',
CYG      2'f + W+/- -> f'' + g          ', 'f + W+/- -> f'' + gamma      ',
CYG      3'f + W+/- -> f'' + Z0         ', 'f + W+/- -> f'' + W+/-       ',
CYG      4'f + W+/- -> f'' + H0         ', 'f + H0 -> f + g             ',
CYG      5'f + H0 -> f + gamma         ',  'f + H0 -> f + Z0            ',
CYG      6'f + H0 -> f'' + W+/-         ', 'f + H0 -> f + H0            ',
CYG      7'g + g -> f + f~             ',  'g + gamma -> f + f~         ',
CYG      8'g + Z0 -> f + f~            ',  'g + W+/- -> f + f~''         ',
CYG      9'g + H0 -> f + f~            ',  'gamma + gamma -> f + f~     ',
CYG      &'gamma + Z0 -> f + f~        ',  'gamma + W+/- -> f + f~''     '/
CYG       DATA (PROC(I),I=61,80)/
CYG      1'gamma + H0 -> f + f~        ',  'Z0 + Z0 -> f + f~           ',
CYG      2'Z0 + W+/- -> f + f~''        ', 'Z0 + H0 -> f + f~           ',
CYG      3'W+ + W- -> f + f~           ',  'W+/- + H0 -> f + f~''        ',
CYG      4'H0 + H0 -> f + f~           ',  'g + g -> g + g              ',
CYG      5'gamma + gamma -> W+ + W-    ',  'gamma + W+/- -> Z0 + W+/-   ',
CYG      6'Z0 + Z0 -> Z0 + Z0          ',  'Z0 + Z0 -> W+ + W-          ',
CYG      7'Z0 + W+/- -> Z0 + W+/-      ',  'Z0 + Z0 -> Z0 + H0          ',
CYG      8'W+ + W- -> gamma + gamma    ',  'W+ + W- -> Z0 + Z0          ',
CYG      9'W+/- + W+/- -> W+/- + W+/-  ',  'W+/- + H0 -> W+/- + H0      ',
CYG      &'H0 + H0 -> H0 + H0          ',  'q + gamma -> q'' + pi+/-     '/
CYG       DATA (PROC(I),I=81,100)/
CYG      1'q + q~ -> Q + Q~, massive   ',  'g + g -> Q + Q~, massive    ',
CYG      2'f + q -> f'' + Q, massive    ', 'g + gamma -> Q + Q~, massive',
CYG      3'gamma + gamma -> F + F~, mas',  'g + g -> J/Psi + g          ',
CYG      4'g + g -> chi_0c + g         ',  'g + g -> chi_1c + g         ',
CYG      5'g + g -> chi_2c + g         ',  '                            ',
CYG      6'Elastic scattering          ',  'Single diffractive (XB)     ',
CYG      7'Single diffractive (AX)     ',  'Double  diffractive         ',
CYG      8'Low-pT scattering           ',  'Semihard QCD 2 -> 2         ',
CYG      9'                            ',  '                            ',
CYG      &'                            ',  '                            '/
CYG       DATA (PROC(I),I=101,120)/
CYG      1'g + g -> gamma*/Z0          ',  'g + g -> H0                 ',
CYG      2'gamma + gamma -> H0         ',  '                            ',
CYG      3'                            ',  '                            ',
CYG      4'                            ',  '                            ',
CYG      5'                            ',  'f + f~ -> gamma + H0        ',
CYG      6'f + f~ -> g + H0            ',  'q + g -> q + H0             ',
CYG      7'g + g -> g + H0             ',  'g + g -> gamma + gamma      ',
CYG      8'g + g -> g + gamma          ',  'g + g -> gamma + Z0         ',
CYG      9'g + g -> Z0 + Z0            ',  'g + g -> W+ + W-            ',
CYG      &'                            ',  '                            '/
CYG       DATA (PROC(I),I=121,140)/
CYG      1'g + g -> Q + Q~ + H0        ',  'q + q~ -> Q + Q~ + H0       ',
CYG      2'f + f'' -> f + f'' + H0       ',
CYG      2'f + f'' -> f" + f"'' + H0     ',
CYG      3'                            ',  '                            ',
CYG      4'                            ',  '                            ',
CYG      5'                            ',  '                            ',
CYG      6'g + g -> Z0 + q + q~        ',  '                            ',
CYG      7'                            ',  '                            ',
CYG      8'                            ',  '                            ',
CYG      9'                            ',  '                            ',
CYG      &'                            ',  '                            '/
CYG       DATA (PROC(I),I=141,160)/
CYG      1'f + f~ -> gamma*/Z0/Z''0     ', 'f + f~'' -> W''+/-            ',
CYG      2'f + f~'' -> H+/-             ', 'f + f~'' -> R                ',
CYG      3'q + l -> LQ                 ',  '                            ',
CYG      4'd + g -> d*                 ',  'u + g -> u*                 ',
CYG      5'g + g -> eta_techni         ',  '                            ',
CYG      6'f + f~ -> H''0               ', 'g + g -> H''0                ',
CYG      7'gamma + gamma -> H''0        ', '                            ',
CYG      8'                            ',  'f + f~ -> A0                ',
CYG      9'g + g -> A0                 ',  'gamma + gamma -> A0         ',
CYG      &'                            ',  '                            '/
CYG       DATA (PROC(I),I=161,180)/
CYG      1'f + g -> f'' + H+/-          ', 'q + g -> LQ + l~            ',
CYG      2'g + g -> LQ + LQ~           ',  'q + q~ -> LQ + LQ~          ',
CYG      3'f + f~ -> f'' + f~'' (gamma/Z)',
CYG      3'f +f~'' -> f" + f~"'' (W)     ',
CYG      4'                            ',  '                            ',
CYG      5'                            ',  '                            ',
CYG      6'f + f~ -> Z0 + H''0          ', 'f + f~'' -> W+/- + H''0       ',
CYG      7'f + f'' -> f + f'' + H''0      ',
CYG      7'f + f'' -> f" + f"'' + H''0    ',
CYG      8'                            ',  'f + f~ -> Z0 + A0           ',
CYG      9'f + f~'' -> W+/- + A0        ',
CYG      9'f + f'' -> f + f'' + A0       ',
CYG      &'f + f'' -> f" + f"'' + A0     ',
CYG      &'                            '/
CYG       DATA (PROC(I),I=181,200)/
CYG      1'g + g -> Q + Q~ + H''0       ',  'q + q~ -> Q + Q~ + H''0      ',
CYG      2'                            ',  '                            ',
CYG      3'                            ',  'g + g -> Q + Q~ + A0        ',
CYG      4'q + q~ -> Q + Q~ + A0       ',  '                            ',
CYG      5'                            ',  '                            ',
CYG      6'                            ',  '                            ',
CYG      7'                            ',  '                            ',
CYG      8'                            ',  '                            ',
CYG      9'                            ',  '                            ',
CYG      &'                            ',  '                            '/
CYG  
CYG C...Cross sections and slope offsets.
CYG       DATA SIGT/294*0./
CYG  
CYG       END
*CMZ :  1.00/00 14/04/95  18.40.01  by  Stavros Katsanevas
*-- Author :    Stavros Katsanevas   14/04/95
CDECK  ID>, LUDATA.
C*********************************************************************
 
CYG       BLOCK DATA LUDATA
CYG  
CYG C...Purpose: to give default values to parameters and particle and
CYG C...decay data.
CYG       COMMON/LUDAT1/MSTU(200),PARU(200),MSTJ(200),PARJ(200)
CYG       COMMON/LUDAT2/KCHG(500,3),PMAS(500,4),PARF(2000),VCKM(4,4)
CYG       COMMON/LUDAT3/MDCY(500,3),MDME(2000,2),BRAT(2000),KFDP(2000,5)
CYG       COMMON/LUDAT4/CHAF(500)
CYG       CHARACTER CHAF*8
CYG       COMMON/LUDATR/MRLU(6),RRLU(100)
CYG       SAVE /LUDAT1/,/LUDAT2/,/LUDAT3/,/LUDAT4/,/LUDATR/
CYG  
CYG C...LUDAT1, containing status codes and most parameters.
CYG       DATA MSTU/
CYG      &    0,    0,    0, 4000,10000,  500, 2000,    0,    0,    2,
CYG      1    6,    1,    1,    0,    1,    1,    0,    0,    0,    0,
CYG      2    2,   10,    0,    0,    1,   10,    0,    0,    0,    0,
CYG      3    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
CYG      4    2,    2,    1,    4,    2,    1,    1,    0,    0,    0,
CYG      5   25,   24,    0,    1,    0,    0,    0,    0,    0,    0,
CYG      6    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
CYG      7  30*0,
CYG      &    1,    0,    0,    0,    0,    0,    0,    0,    0,    0,
CYG      1    1,    5,    3,    5,    0,    0,    0,    0,    0,    0,
CYG      2  60*0,
CYG      8    7,  401, 1994,   02,   11,  700,    0,    0,    0,    0,
CYG      9    0,    0,    0,    0,    0,    0,    0,    0,    0,    0/
CYG       DATA PARU/
CYG      & 3.1415927, 6.2831854, 0.1973, 5.068, 0.3894, 2.568,   4*0.,
CYG      1 0.001, 0.09, 0.01,  0.,   0.,   0.,   0.,   0.,   0.,   0.,
CYG      2   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,
CYG      3   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,
CYG      4  2.0,  1.0, 0.25,  2.5, 0.05,   0.,   0., 0.0001, 0.,   0.,
CYG      5  2.5,  1.5,  7.0,  1.0,  0.5,  2.0,  3.2,   0.,   0.,   0.,
CYG      6  40*0.,
CYG      & 0.00729735, 0.232, 0., 0., 0.,  0.,   0.,   0.,   0.,   0.,
CYG      1 0.20, 0.25,  1.0,  4.0,  10.,   0.,   0.,   0.,   0.,   0.,
CYG      2 -0.693, -1.0, 0.387, 1.0, -0.08, -1.0, 1.0, 1.0, 1.0,   0.,
CYG      3  1.0, -1.0,  1.0, -1.0,  1.0,   0.,   0.,   0.,   0.,   0.,
CYG      4  5.0,  1.0,  1.0,   0.,  1.0,  1.0,   0.,   0.,   0.,   0.,
CYG      5  1.0,   0.,   0.,   0., 1000., 1.0,  1.0,  1.0,  1.0,   0.,
CYG      6  1.0,  1.0,  1.0,  1.0,  1.0,   0.,   0.,   0.,   0.,   0.,
CYG      7  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,   0.,   0.,   0.,
CYG      8  1.0,  1.0,  1.0,  0.0,  0.0,  1.0,  1.0,  0.0,  0.0,   0.,
CYG      9   0.,   0.,   0.,   0.,  1.0,   0.,   0.,   0.,   0.,   0./
CYG       DATA MSTJ/
CYG      &    1,    3,    0,    0,    0,    0,    0,    0,    0,    0,
CYG      1    4,    2,    0,    1,    0,    0,    0,    0,    0,    0,
CYG      2    2,    1,    1,    2,    1,    2,    2,    0,    0,    0,
CYG      3    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
CYG      4    2,    2,    4,    2,    5,    3,    3,    0,    0,    0,
CYG      5    0,    3,    0,    0,    0,    0,    0,    0,    0,    0,
CYG      6  40*0,
CYG      &    5,    2,    7,    5,    1,    1,    0,    2,    0,    2,
CYG      1    0,    0,    0,    0,    1,    1,    0,    0,    0,    0,
CYG      2  80*0/
CYG       DATA PARJ/
CYG      & 0.10, 0.30, 0.40, 0.05, 0.50, 0.50, 0.50,   0.,   0.,   0.,
CYG      1 0.50, 0.60, 0.75,   0.,   0.,   0.,   0.,  1.0,  1.0,   0.,
CYG      2 0.36,  1.0, 0.01,  2.0,  1.0,  0.4,   0.,   0.,   0.,   0.,
CYG      3 0.10,  1.0,  0.8,  1.5,   0.,  2.0,  0.2,  2.5,  0.6,   0.,
CYG      4  0.3, 0.58,  0.5,  0.9,  0.5,  1.0,  1.0,  1.0,   0.,   0.,
CYG      5 0.77,0.77,0.77,-0.05,-0.005,-0.00001,-0.00001,-0.00001,1.0,0.,
CYG      6  4.5,  0.7,  0., 0.003,  0.5,  0.5,   0.,   0.,   0.,   0.,
CYG      7  10., 1000., 100., 1000., 0.,  0.7,  10.,   0.,   0.,   0.,
CYG      8 0.29,  1.0,  1.0,   0.,  10.,  10.,   0.,   0.,   0.,   0.,
CYG      9 0.02,  1.0,  0.2,   0.,   0.,   0.,   0.,   0.,   0.,   0.,
CYG      &   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,
CYG      1   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,
CYG      2  1.0, 0.25,91.187,2.489, 0.01, 2.0,  1.0, 0.25,0.002,   0.,
CYG      3   0.,   0.,   0.,   0., 0.01, 0.99,   0.,   0.,  0.2,   0.,
CYG      4  60*0./
CYG  
CYG C...LUDAT2, with particle data and flavour treatment parameters.
CYG       DATA (KCHG(I,1),I=   1, 500)/-1,2,-1,2,-1,2,-1,2,2*0,-3,0,-3,0,
CYG      &-3,0,-3,6*0,3,9*0,3,2*0,3,0,-1,44*0,2,-1,2,-1,2,3,11*0,3,0,2*3,0,
CYG      &3,0,3,0,3,10*0,3,0,2*3,0,3,0,3,0,3,10*0,3,0,2*3,0,3,0,3,0,3,10*0,
CYG      &3,0,2*3,0,3,0,3,0,3,10*0,3,0,2*3,0,3,0,3,0,3,10*0,3,0,2*3,0,3,0,
CYG      &3,0,3,70*0,3,0,3,28*0,3,2*0,3,8*0,-3,8*0,3,0,-3,0,3,-3,3*0,3,6,0,
CYG      &3,5*0,-3,0,3,-3,0,-3,4*0,-3,0,3,6,-3,0,3,-3,0,-3,0,3,6,0,3,5*0,
CYG      &-3,0,3,-3,0,-3,114*0/
CYG       DATA (KCHG(I,2),I=   1, 500)/8*1,12*0,2,16*0,2,1,50*0,-1,410*0/
CYG       DATA (KCHG(I,3),I=   1, 500)/8*1,2*0,8*1,5*0,1,9*0,1,2*0,1,0,2*1,
CYG      &41*0,1,0,7*1,10*0,10*1,10*0,10*1,10*0,10*1,10*0,10*1,10*0,10*1,
CYG      &10*0,10*1,70*0,3*1,22*0,1,5*0,1,0,2*1,6*0,1,0,2*1,6*0,2*1,0,5*1,
CYG      &0,6*1,4*0,6*1,4*0,16*1,4*0,6*1,114*0/
CYG       DATA (PMAS(I,1),I=   1, 500)/0.0099,0.0056,0.199,1.35,5.,160.,
CYG      &2*250.,2*0.,0.00051,0.,0.1057,0.,1.777,0.,250.,5*0.,91.187,80.25,
CYG      &80.,6*0.,500.,900.,500.,3*300.,350.,200.,5000.,60*0.,0.1396,
CYG      &0.4977,0.4936,1.8693,1.8645,1.9688,5.2787,5.2786,5.47972,6.594,
CYG      &0.135,0.5475,0.9578,2.9788,9.4,320.,2*500.,2*0.,0.7669,0.8961,
CYG      &0.8916,2.0101,2.0071,2.11,2*5.325,5.5068,6.602,0.7683,0.782,
CYG      &1.0194,3.0969,9.4603,320.,2*500.,2*0.,1.232,2*1.29,2*2.424,2.536,
CYG      &2*5.73,5.97,7.3,1.232,1.17,1.4,3.46,9.875,320.,2*500.,2*0.,0.983,
CYG      &2*1.429,2*2.272,2.5,2*5.68,5.92,7.25,0.9827,1.,1.4,3.4151,9.8598,
CYG      &320.,2*500.,2*0.,1.26,2*1.402,2*2.372,2.56,2*5.78,6.02,7.3,1.26,
CYG      &1.282,1.42,3.5106,9.8919,320.,2*500.,2*0.,1.318,1.432,1.425,
CYG      &2*2.46,2.61,2*5.83,6.07,7.35,1.318,1.275,1.525,3.5562,9.9132,
CYG      &320.,2*500.,2*0.,2*0.4977,8*0.,3.686,3*0.,10.0233,70*0.,1.1156,
CYG      &5*0.,2.2849,0.,2.473,2.466,6*0.,5.641,0.,2*5.84,6*0.,0.9396,
CYG      &0.9383,0.,1.1974,1.1926,1.1894,1.3213,1.3149,0.,2.4525,2.4529,
CYG      &2.4527,2*2.55,2.73,4*0.,3*5.8,2*5.96,6.12,4*0.,1.234,1.233,1.232,
CYG      &1.231,1.3872,1.3837,1.3828,1.535,1.5318,1.6724,3*2.5,2*2.63,2.8,
CYG      &4*0.,3*5.81,2*5.97,6.13,114*0./
CYG       DATA (PMAS(I,2),I=   1, 500)/22*0.,2.489,2.066,88*0.,0.0002,
CYG      &0.001,6*0.,0.149,0.0505,0.0498,7*0.,0.151,0.00843,0.0044,7*0.,
CYG      &0.155,2*0.09,2*0.02,0.,4*0.05,0.155,0.36,0.08,2*0.01,5*0.,0.057,
CYG      &2*0.287,7*0.05,0.057,0.,0.25,0.014,6*0.,0.4,2*0.174,7*0.05,0.4,
CYG      &0.024,0.06,0.0009,6*0.,0.11,0.109,0.098,2*0.019,5*0.02,0.11,
CYG      &0.185,0.076,0.002,146*0.,4*0.12,0.0394,0.036,0.0358,0.0099,
CYG      &0.0091,131*0./
CYG       DATA (PMAS(I,3),I=   1, 500)/22*0.,2*20.,88*0.,0.002,0.005,6*0.,
CYG      &0.4,2*0.2,7*0.,0.4,0.1,0.015,7*0.,0.25,0.005,0.01,2*0.08,0.,
CYG      &4*0.1,0.25,0.2,0.001,2*0.02,5*0.,0.05,2*0.4,6*0.1,2*0.05,0.,0.35,
CYG      &0.05,6*0.,3*0.3,2*0.1,0.03,4*0.1,0.3,0.05,0.02,0.001,6*0.,0.25,
CYG      &4*0.12,5*0.05,0.25,0.17,0.2,0.01,146*0.,4*0.14,0.04,2*0.035,
CYG      &2*0.05,131*0./
CYG       DATA (PMAS(I,4),I=   1, 500)/12*0.,658650.,0.,0.0914,68*0.,0.1,
CYG      &0.387,15*0.,7804.,0.,3709.,0.32,0.1259,0.135,3*0.387,0.15,110*0.,
CYG      &15500.,26.75,83*0.,78.88,5*0.,0.057,0.,0.025,0.09,6*0.,0.387,0.,
CYG      &2*0.387,9*0.,44.3,0.,23.95,49.1,86.9,6*0.,0.13,9*0.,0.387,13*0.,
CYG      &24.60001,130*0./
CYG       DATA PARF/
CYG      &  0.5, 0.25,  0.5, 0.25,   1.,  0.5,   0.,   0.,   0.,   0.,
CYG      1  0.5,   0.,  0.5,   0.,   1.,   1.,   0.,   0.,   0.,   0.,
CYG      2  0.5,   0.,  0.5,   0.,   1.,   1.,   0.,   0.,   0.,   0.,
CYG      3  0.5,   0.,  0.5,   0.,   1.,   1.,   0.,   0.,   0.,   0.,
CYG      4  0.5,   0.,  0.5,   0.,   1.,   1.,   0.,   0.,   0.,   0.,
CYG      5  0.5,   0.,  0.5,   0.,   1.,   1.,   0.,   0.,   0.,   0.,
CYG      6 0.75,  0.5,   0., 0.1667, 0.0833, 0.1667, 0., 0., 0.,   0.,
CYG      7   0.,   0.,   1., 0.3333, 0.6667, 0.3333, 0., 0., 0.,   0.,
CYG      8   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,
CYG      9   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,
CYG      & 0.325, 0.325, 0.5, 1.6,  5.0,   0.,   0.,   0.,   0.,   0.,
CYG      1   0., 0.11, 0.16, 0.048, 0.50, 0.45, 0.55, 0.60,  0.,   0.,
CYG      2  0.2,  0.1,   0.,   0.,   0.,   0.,   0.,   0.,   0.,   0.,
CYG      3  1870*0./
CYG       DATA ((VCKM(I,J),J=1,4),I=1,4)/
CYG      1  0.95113,  0.04884,  0.00003,  0.00000,
CYG      2  0.04884,  0.94940,  0.00176,  0.00000,
CYG      3  0.00003,  0.00176,  0.99821,  0.00000,
CYG      4  0.00000,  0.00000,  0.00000,  1.00000/
CYG  
CYG C...LUDAT3, with particle decay parameters and data.
CYG       DATA (MDCY(I,1),I=   1, 500)/5*0,3*1,6*0,1,0,1,5*0,3*1,6*0,1,0,1,
CYG      &2*0,4*1,42*0,7*1,12*0,1,0,15*1,2*0,18*1,2*0,18*1,2*0,18*1,2*0,
CYG      &18*1,2*0,18*1,3*0,1,8*0,1,3*0,1,70*0,1,5*0,1,0,2*1,6*0,1,0,2*1,
CYG      &9*0,5*1,0,6*1,4*0,6*1,4*0,16*1,4*0,6*1,114*0/
CYG       DATA (MDCY(I,2),I=   1, 500)/1,9,17,25,33,41,50,60,2*0,70,74,76,
CYG      &81,83,124,126,132,2*0,135,144,156,172,192,6*0,209,0,231,254,274,
CYG      &292,301,304,305,42*0,314,315,319,328,331,336,338,11*0,358,359,
CYG      &361,367,430,491,524,560,596,635,666,668,675,681,682,683,684,685,
CYG      &2*0,686,688,691,694,697,699,700,701,702,703,704,708,713,721,724,
CYG      &733,734,735,2*0,736,737,742,747,749,751,753,755,757,759,761,762,
CYG      &765,769,770,771,772,773,2*0,774,775,777,779,781,783,785,787,789,
CYG      &791,793,794,799,804,806,808,809,810,2*0,811,813,815,817,819,821,
CYG      &823,825,827,829,831,833,846,850,852,854,855,856,2*0,857,863,873,
CYG      &884,892,900,904,912,920,924,928,936,945,951,953,955,956,957,2*0,
CYG      &958,966,8*0,968,3*0,979,70*0,993,5*0,997,0,1073,1074,6*0,1075,0,
CYG      &1092,1093,9*0,1094,1096,1097,1100,1101,0,1103,1104,1105,1106,
CYG      &1107,1108,4*0,1109,1110,1111,1112,1113,1114,4*0,1115,1116,1119,
CYG      &1122,1123,1126,1129,1132,1134,1136,1140,1141,1142,1143,1145,1147,
CYG      &4*0,1148,1149,1150,1151,1152,1153,114*0/
CYG       DATA (MDCY(I,3),I=   1, 500)/5*8,9,2*10,2*0,4,2,5,2,41,2,6,3,2*0,
CYG      &9,12,16,20,17,6*0,22,0,23,20,18,9,3,1,9,42*0,1,4,9,3,5,2,20,11*0,
CYG      &1,2,6,63,61,33,2*36,39,31,2,7,6,5*1,2*0,2,3*3,2,5*1,4,5,8,3,9,
CYG      &3*1,2*0,1,2*5,7*2,1,3,4,5*1,2*0,1,9*2,1,2*5,2*2,3*1,2*0,11*2,13,
CYG      &4,2*2,3*1,2*0,6,10,11,2*8,4,2*8,2*4,8,9,6,2*2,3*1,2*0,8,2,8*0,11,
CYG      &3*0,14,70*0,4,5*0,76,0,2*1,6*0,17,0,2*1,9*0,2,1,3,1,2,0,6*1,4*0,
CYG      &6*1,4*0,1,2*3,1,3*3,2*2,4,3*1,2*2,1,4*0,6*1,114*0/
CYG       DATA (MDME(I,1),I=   1,2000)/6*1,-1,7*1,-1,7*1,-1,7*1,-1,7*1,-1,
CYG      &7*1,-1,1,-1,8*1,2*-1,8*1,2*-1,61*1,-1,2*1,-1,6*1,2*-1,7*1,2*-1,
CYG      &3*1,-1,6*1,2*-1,6*1,2*-1,3*1,-1,3*1,-1,3*1,5*-1,3*1,-1,6*1,2*-1,
CYG      &3*1,-1,11*1,2*-1,6*1,8*-1,3*1,-1,3*1,-1,3*1,5*-1,3*1,4*-1,6*1,
CYG      &2*-1,3*1,-1,5*1,-1,8*1,2*-1,3*1,-1,9*1,-1,3*1,-1,9*1,2*-1,2*1,-1,
CYG      &16*1,-1,2*1,3*-1,1665*1/
CYG       DATA (MDME(I,2),I=   1,2000)/75*102,42,6*102,2*42,2*0,7*41,2*0,
CYG      &24*41,6*102,45,29*102,8*32,8*0,16*32,4*0,8*32,4*0,32,4*0,8*32,
CYG      &14*0,16*32,7*0,8*32,4*0,32,7*0,8*32,4*0,32,5*0,4*32,5*0,3*32,0,
CYG      &6*32,3*0,12,2*42,2*11,9*42,2*45,31,2*45,2*33,31,2*45,20*46,7*0,
CYG      &24*42,41*0,16*42,46*0,10*42,20*0,2*13,14*42,16*0,48,3*13,16*42,
CYG      &16*0,48,3*13,16*42,19*0,48,3*13,2*42,0,2*11,28*42,0,2,4*0,2,8*0,
CYG      &12,32,86,87,88,3,0,2*3,0,2*3,0,2*3,0,3,6*0,3,3*0,1,0,3,2*0,2*3,
CYG      &3*0,1,4*0,12,3*0,4*32,2*4,86,87,88,33*0,12,32,86,87,88,31*0,12,0,
CYG      &32,86,87,88,40*0,12,0,32,86,87,88,95*0,12,0,32,86,87,88,2*0,4*42,
CYG      &6*0,12,11*0,4*32,2*4,9*0,14*42,52*0,10*13,2*84,3*42,8*0,48,3*13,
CYG      &2*42,2*85,14*0,84,5*0,85,886*0/
CYG       DATA (BRAT(I)  ,I=   1, 439)/75*0.,1.,6*0.,0.179,0.178,0.116,
CYG      &0.235,0.005,0.056,0.018,0.023,0.011,2*0.004,0.0067,0.014,2*0.002,
CYG      &2*0.001,0.0022,0.054,0.002,0.016,0.005,0.011,0.0101,5*0.006,
CYG      &0.002,2*0.001,5*0.002,6*0.,1.,29*0.,0.15394,0.11936,0.15394,
CYG      &0.11926,0.15254,3*0.,0.03368,0.06664,0.03368,0.06664,0.03368,
CYG      &0.06664,2*0.,0.3214,0.0165,2*0.,0.0165,0.3207,2*0.,0.00001,
CYG      &0.00059,6*0.,3*0.1081,3*0.,0.0003,0.048,0.8705,4*0.,0.0002,
CYG      &0.0603,0.,0.0199,0.0008,3*0.,0.143,0.111,0.143,0.111,0.143,0.085,
CYG      &2*0.,0.03,0.058,0.03,0.058,0.03,0.058,8*0.,0.25,0.01,2*0.,0.01,
CYG      &0.25,4*0.,0.24,5*0.,3*0.08,6*0.,0.01,0.08,0.82,5*0.,0.09,11*0.,
CYG      &0.01,0.08,0.82,5*0.,0.09,9*0.,1.,6*0.,0.01,0.98,0.01,1.,4*0.215,
CYG      &2*0.,2*0.07,0.,1.,2*0.08,0.76,0.08,2*0.105,0.04,0.5,0.08,0.14,
CYG      &0.01,0.015,0.005,1.,3*0.,1.,4*0.,1.,0.25,0.01,2*0.,0.01,0.25,
CYG      &4*0.,0.24,5*0.,3*0.08,0.,1.,2*0.5,0.635,0.212,0.056,0.017,0.048,
CYG      &0.032,0.07,0.065,2*0.005,2*0.011,5*0.001,0.07,0.065,2*0.005,
CYG      &2*0.011,5*0.001,0.026,0.019,0.066,0.041,0.045,0.076,0.0073,
CYG      &2*0.0047,0.026,0.001,0.0006,0.0066,0.005,2*0.003,2*0.0006,
CYG      &2*0.001,0.006,0.005,0.012,0.0057,0.067,0.008,0.0022,0.027,0.004,
CYG      &0.019,0.012,0.002,0.009,0.0218,0.001,0.022,0.087,0.001,0.0019,
CYG      &0.0015,0.0028,0.034,0.027,2*0.002,2*0.004,2*0.002,0.034,0.027/
CYG       DATA (BRAT(I)  ,I= 440, 655)/2*0.002,2*0.004,2*0.002,0.0365,
CYG      &0.045,0.073,0.062,3*0.021,0.0061,0.015,0.025,0.0088,0.074,0.0109,
CYG      &0.0041,0.002,0.0035,0.0011,0.001,0.0027,2*0.0016,0.0018,0.011,
CYG      &0.0063,0.0052,0.018,0.016,0.0034,0.0036,0.0009,0.0006,0.015,
CYG      &0.0923,0.018,0.022,0.0077,0.009,0.0075,0.024,0.0085,0.067,0.0511,
CYG      &0.017,0.0004,0.0028,0.01,2*0.02,0.03,2*0.005,2*0.02,0.03,2*0.005,
CYG      &0.015,0.037,0.028,0.079,0.095,0.052,0.0078,4*0.001,0.028,0.033,
CYG      &0.026,0.05,0.01,4*0.005,0.25,0.0952,0.02,0.055,2*0.005,0.008,
CYG      &0.012,0.02,0.055,2*0.005,0.008,0.012,0.01,0.03,0.0035,0.011,
CYG      &0.0055,0.0042,0.009,0.018,0.015,0.0185,0.0135,0.025,0.0004,
CYG      &0.0007,0.0008,0.0014,0.0019,0.0025,0.4291,0.08,0.07,0.02,0.015,
CYG      &0.005,0.02,0.055,2*0.005,0.008,0.012,0.02,0.055,2*0.005,0.008,
CYG      &0.012,0.01,0.03,0.0035,0.011,0.0055,0.0042,0.009,0.018,0.015,
CYG      &0.0185,0.0135,0.025,0.0004,0.0007,0.0008,0.0014,0.0019,0.0025,
CYG      &0.4291,0.08,0.07,0.02,0.015,0.005,0.02,0.055,2*0.005,0.008,0.012,
CYG      &0.02,0.055,2*0.005,0.008,0.012,0.01,0.03,0.0035,0.011,0.0055,
CYG      &0.0042,0.009,0.018,0.015,0.0185,0.0135,0.025,2*0.0002,0.0007,
CYG      &2*0.0004,0.0014,0.001,0.0009,0.0025,0.4291,0.08,0.07,0.02,0.015,
CYG      &0.005,0.047,0.122,0.006,0.012,0.035,0.012,0.035,0.003,0.007,0.15,
CYG      &0.037,0.008,0.002,0.05,0.015,0.003,0.001,0.014,0.042,0.014,0.042/
CYG       DATA (BRAT(I)  ,I= 656, 931)/0.24,0.065,0.012,0.003,0.001,0.002,
CYG      &0.001,0.002,0.014,0.003,0.988,0.012,0.389,0.319,0.2367,0.049,
CYG      &0.005,0.001,0.0003,0.441,0.206,0.3,0.03,0.022,0.001,5*1.,0.99955,
CYG      &0.00045,0.665,0.333,0.002,0.666,0.333,0.001,0.65,0.3,0.05,0.56,
CYG      &0.44,5*1.,0.99912,0.00079,0.00005,0.00004,0.888,0.085,0.021,
CYG      &2*0.003,0.49,0.344,3*0.043,0.023,0.013,0.001,0.0627,0.0597,
CYG      &0.8776,3*0.027,0.015,0.045,0.015,0.045,0.77,0.029,4*1.,0.28,0.14,
CYG      &0.313,0.157,0.11,0.28,0.14,0.313,0.157,0.11,0.667,0.333,0.667,
CYG      &0.333,2*0.5,0.667,0.333,0.667,0.333,4*0.5,1.,0.333,0.334,0.333,
CYG      &4*0.25,6*1.,0.667,0.333,0.667,0.333,0.667,0.333,0.667,0.333,
CYG      &2*0.5,0.667,0.333,0.667,0.333,4*0.5,1.,0.52,0.26,0.11,2*0.055,
CYG      &0.62,0.31,0.035,2*0.0175,0.007,0.993,0.02,0.98,3*1.,2*0.5,0.667,
CYG      &0.333,0.667,0.333,0.667,0.333,0.667,0.333,2*0.5,0.667,0.333,
CYG      &0.667,0.333,6*0.5,3*0.12,0.097,0.043,4*0.095,4*0.03,4*0.25,0.273,
CYG      &0.727,0.35,0.65,3*1.,2*0.35,0.144,0.105,0.048,0.003,0.333,0.166,
CYG      &0.168,0.084,0.087,0.043,0.059,2*0.029,0.002,0.332,0.166,0.168,
CYG      &0.084,0.086,0.043,0.059,2*0.029,2*0.002,0.3,0.15,0.16,0.08,0.13,
CYG      &0.06,0.08,0.04,0.3,0.15,0.16,0.08,0.13,0.06,0.08,0.04,2*0.3,
CYG      &2*0.2,0.3,0.15,0.16,0.08,0.13,0.06,0.08,0.04,0.3,0.15,0.16,0.08,
CYG      &0.13,0.06,0.08,0.04,2*0.3,2*0.2,2*0.3,2*0.2,2*0.35,0.144,0.105/
CYG       DATA (BRAT(I)  ,I= 932,2000)/0.024,2*0.012,0.003,0.566,0.283,
CYG      &0.069,0.028,0.023,2*0.0115,0.005,0.003,0.356,2*0.178,0.28,
CYG      &2*0.004,0.135,0.865,0.22,0.78,3*1.,0.217,0.124,2*0.193,2*0.135,
CYG      &0.002,0.001,0.686,0.314,2*0.0083,0.1866,0.324,0.184,0.027,0.001,
CYG      &0.093,0.087,0.078,0.0028,3*0.014,0.008,0.024,0.008,0.024,0.425,
CYG      &0.02,0.185,0.088,0.043,0.067,0.066,0.641,0.357,2*0.001,0.018,
CYG      &2*0.005,0.003,0.002,2*0.006,0.018,2*0.005,0.003,0.002,2*0.006,
CYG      &0.0066,0.025,0.016,0.0088,2*0.005,0.0058,0.005,0.0055,4*0.004,
CYG      &2*0.002,2*0.004,0.003,0.002,2*0.003,3*0.002,2*0.001,0.002,
CYG      &2*0.001,2*0.002,0.0013,0.0018,5*0.001,4*0.003,2*0.005,2*0.002,
CYG      &2*0.001,2*0.002,2*0.001,0.2432,0.057,2*0.035,0.15,2*0.075,0.03,
CYG      &2*0.015,2*1.,2*0.105,0.04,0.0077,0.02,0.0235,0.0285,0.0435,
CYG      &0.0011,0.0022,0.0044,0.4291,0.08,0.07,0.02,0.015,0.005,2*1.,
CYG      &0.999,0.001,1.,0.516,0.483,0.001,1.,0.995,0.005,13*1.,0.331,
CYG      &0.663,0.006,0.663,0.331,0.006,1.,0.88,2*0.06,0.88,2*0.06,0.88,
CYG      &2*0.06,0.667,2*0.333,0.667,0.676,0.234,0.085,0.005,3*1.,4*0.5,
CYG      &7*1.,847*0./
CYG       DATA (KFDP(I,1),I=   1, 507)/21,22,23,4*-24,25,21,22,23,4*24,25,
CYG      &21,22,23,4*-24,25,21,22,23,4*24,25,21,22,23,4*-24,25,21,22,23,
CYG      &4*24,25,37,21,22,23,4*-24,25,2*-37,21,22,23,4*24,25,2*37,22,23,
CYG      &-24,25,23,24,-12,22,23,-24,25,23,24,-12,-14,35*16,22,23,-24,25,
CYG      &23,24,-89,22,23,-24,25,-37,23,24,37,1,2,3,4,5,6,7,8,21,1,2,3,4,5,
CYG      &6,7,8,11,13,15,17,1,2,3,4,5,6,7,8,11,12,13,14,15,16,17,18,4*-1,
CYG      &4*-3,4*-5,4*-7,-11,-13,-15,-17,1,2,3,4,5,6,7,8,11,13,15,17,21,
CYG      &2*22,23,24,1,2,3,4,5,6,7,8,11,12,13,14,15,16,17,18,24,37,2*23,25,
CYG      &35,4*-1,4*-3,4*-5,4*-7,-11,-13,-15,-17,3*24,1,2,3,4,5,6,7,8,11,
CYG      &13,15,17,21,2*22,23,24,23,25,36,1,2,3,4,5,6,7,8,11,13,15,17,21,
CYG      &2*22,23,24,23,-1,-3,-5,-7,-11,-13,-15,-17,24,5,6,21,2,1,2,3,4,5,
CYG      &6,11,13,15,82,-11,-13,2*2,-12,-14,-16,2*-2,2*-4,-2,-4,2*89,37,
CYG      &2*-89,2*5,-37,2*89,4*-1,4*-3,4*-5,4*-7,-11,-13,-15,-17,-13,130,
CYG      &310,-13,3*211,12,14,11*-11,11*-13,-311,-313,-311,-313,-20313,
CYG      &2*-311,-313,-311,-313,2*111,2*221,2*331,2*113,2*223,2*333,-311,
CYG      &-313,2*-321,211,-311,-321,333,-311,-313,-321,211,2*-321,2*-311,
CYG      &-321,211,113,8*-11,8*-13,-321,-323,-321,-323,-311,2*-313,-311,
CYG      &-313,2*-311,-321,-10323,-321,-323,-321,-311,2*-313,211,111,333,
CYG      &3*-321,-311,-313,-321,-313,310,333,211,2*-321,-311,-313,-311,211,
CYG      &-321,3*-311,211,113,321,-15,5*-11,5*-13,221,331,333,221,331,333/
CYG       DATA (KFDP(I,1),I= 508, 924)/10221,211,213,211,213,321,323,321,
CYG      &323,2212,221,331,333,221,2*2,6*12,6*14,2*16,3*-411,3*-413,2*-411,
CYG      &2*-413,2*441,2*443,2*20443,2*2,2*4,2,4,6*12,6*14,2*16,3*-421,
CYG      &3*-423,2*-421,2*-423,2*441,2*443,2*20443,2*2,2*4,2,4,6*12,6*14,
CYG      &2*16,3*-431,3*-433,2*-431,2*-433,3*441,3*443,3*20443,2*2,2*4,2,4,
CYG      &16,2*4,2*12,2*14,2*16,4*2,4*4,2*-11,2*-13,2*-1,2*-3,2*-11,2*-13,
CYG      &2*-1,3*22,111,211,2*22,211,22,211,111,3*22,111,82,21,3*0,2*211,
CYG      &321,3*311,2*321,421,2*411,2*421,431,511,521,531,541,211,111,13,
CYG      &11,211,22,211,2*111,321,130,-213,113,213,211,22,111,11,13,82,11,
CYG      &13,15,1,2,3,4,21,22,3*0,223,321,311,323,313,2*311,321,313,323,
CYG      &321,423,2*413,2*423,413,523,2*513,2*523,2*513,523,223,213,113,
CYG      &-213,313,-313,323,-323,82,21,3*0,221,321,2*311,321,421,2*411,421,
CYG      &411,421,521,2*511,2*521,2*511,521,221,211,111,321,130,310,211,
CYG      &111,321,130,310,443,82,553,21,3*0,113,213,323,2*313,323,423,
CYG      &2*413,2*423,413,523,2*513,2*523,2*513,523,213,-213,10211,10111,
CYG      &-10211,2*221,213,2*113,-213,2*321,2*311,313,-313,323,-323,443,82,
CYG      &553,21,3*0,213,113,221,223,321,211,321,311,323,313,323,313,321,
CYG      &4*311,321,313,323,313,323,311,4*321,421,411,423,413,423,413,421,
CYG      &2*411,421,413,423,413,423,411,2*421,411,423,413,521,511,523,513,
CYG      &523,513,521,2*511,521,513,523,513,523,511,2*521,511,523,513,511/
CYG       DATA (KFDP(I,1),I= 925,2000)/521,513,523,213,-213,221,223,321,
CYG      &130,310,111,211,111,2*211,321,130,310,221,111,321,130,310,221,
CYG      &211,111,443,82,553,21,3*0,111,211,-12,12,-14,14,211,111,211,111,
CYG      &11,13,82,4*443,10441,20443,445,441,11,13,15,1,2,3,4,21,22,2*553,
CYG      &10551,20553,555,2212,2*2112,-12,7*-11,7*-13,2*2224,2*2212,2*2214,
CYG      &2*3122,2*3212,2*3214,5*3222,4*3224,2*3322,3324,2*2224,7*2212,
CYG      &5*2214,2*2112,2*2114,2*3122,2*3212,2*3214,2*3222,2*3224,4*2,3,
CYG      &2*2,1,2*2,2*0,-12,-14,-16,5*4122,441,443,20443,2*-2,2*-4,-2,-4,
CYG      &2*0,2112,-12,3122,2212,2112,2212,3*3122,3*4122,4132,4232,0,
CYG      &3*5122,5132,5232,0,2112,2212,2*2112,2212,2112,2*2212,3122,3212,
CYG      &3112,3122,3222,3112,3122,3222,3212,3322,3312,3322,3312,3122,3322,
CYG      &3312,-12,3*4122,2*4132,2*4232,4332,3*5122,5132,5232,5332,847*0/
CYG       DATA (KFDP(I,2),I=   1, 476)/3*1,2,4,6,8,1,3*2,1,3,5,7,2,3*3,2,4,
CYG      &6,8,3,3*4,1,3,5,7,4,3*5,2,4,6,8,5,3*6,1,3,5,7,6,5,3*7,2,4,6,8,7,
CYG      &4,6,3*8,1,3,5,7,8,5,7,2*11,12,11,12,2*11,2*13,14,13,14,13,11,13,
CYG      &-211,-213,-211,-213,-211,-213,3*-211,-321,-323,-321,-323,3*-321,
CYG      &4*-211,-213,-211,-213,-211,-213,-211,-213,-211,-213,6*-211,2*15,
CYG      &16,15,16,15,18,2*17,18,17,2*18,2*17,-1,-2,-3,-4,-5,-6,-7,-8,21,
CYG      &-1,-2,-3,-4,-5,-6,-7,-8,-11,-13,-15,-17,-1,-2,-3,-4,-5,-6,-7,-8,
CYG      &-11,-12,-13,-14,-15,-16,-17,-18,2,4,6,8,2,4,6,8,2,4,6,8,2,4,6,8,
CYG      &12,14,16,18,-1,-2,-3,-4,-5,-6,-7,-8,-11,-13,-15,-17,21,22,2*23,
CYG      &-24,-1,-2,-3,-4,-5,-6,-7,-8,-11,-12,-13,-14,-15,-16,-17,-18,-24,
CYG      &-37,22,25,2*36,2,4,6,8,2,4,6,8,2,4,6,8,2,4,6,8,12,14,16,18,23,22,
CYG      &25,-1,-2,-3,-4,-5,-6,-7,-8,-11,-13,-15,-17,21,22,2*23,-24,2*25,
CYG      &36,-1,-2,-3,-4,-5,-6,-7,-8,-11,-13,-15,-17,21,22,2*23,-24,25,2,4,
CYG      &6,8,12,14,16,18,25,-5,-6,21,11,-3,-4,-5,-6,-7,-8,-13,-15,-17,-82,
CYG      &12,14,-1,-3,11,13,15,1,4,3,4,1,3,5,3,5,6,4,21,22,4,7,5,2,4,6,8,2,
CYG      &4,6,8,2,4,6,8,2,4,6,8,12,14,16,18,14,2*0,14,111,211,111,-11,-13,
CYG      &11*12,11*14,2*211,2*213,211,20213,2*321,2*323,211,213,211,213,
CYG      &211,213,211,213,211,213,211,213,3*211,213,211,2*321,8*211,2*113,
CYG      &2*211,8*12,8*14,2*211,2*213,2*111,221,2*113,223,333,20213,211,
CYG      &2*321,323,2*311,313,-211,111,113,2*211,321,2*211,311,321,310,211/
CYG       DATA (KFDP(I,2),I= 477, 857)/-211,4*211,321,4*211,113,2*211,-321,
CYG      &16,5*12,5*14,3*211,3*213,211,2*111,2*113,2*-311,2*-313,-2112,
CYG      &3*321,323,2*-1,6*-11,6*-13,2*-15,211,213,20213,211,213,20213,431,
CYG      &433,431,433,311,313,311,313,311,313,-1,-4,-3,-4,-1,-3,6*-11,
CYG      &6*-13,2*-15,211,213,20213,211,213,20213,431,433,431,433,321,323,
CYG      &321,323,321,323,-1,-4,-3,-4,-1,-3,6*-11,6*-13,2*-15,211,213,
CYG      &20213,211,213,20213,431,433,431,433,221,331,333,221,331,333,221,
CYG      &331,333,-1,-4,-3,-4,-1,-3,-15,-3,-1,2*-11,2*-13,2*-15,-1,-4,-3,
CYG      &-4,-3,-4,-1,-4,2*12,2*14,2,3,2,3,2*12,2*14,2,1,22,11,22,111,-211,
CYG      &211,11,-211,13,-211,111,113,223,22,111,-82,21,3*0,111,22,-211,
CYG      &111,22,211,111,22,211,111,22,111,6*22,-211,22,-13,-11,-211,111,
CYG      &-211,2*111,-321,310,211,111,2*-211,221,22,-11,-13,-82,-11,-13,
CYG      &-15,-1,-2,-3,-4,2*21,3*0,211,-213,113,-211,111,223,213,113,211,
CYG      &111,223,211,111,-211,111,321,311,-211,111,211,111,-321,-311,411,
CYG      &421,111,-211,111,211,-311,311,-321,321,-82,21,3*0,211,-211,111,
CYG      &211,111,211,111,-211,111,311,321,-211,111,211,111,-321,-311,411,
CYG      &421,111,-211,111,-321,130,310,-211,111,-321,130,310,22,-82,22,21,
CYG      &3*0,211,111,-211,111,211,111,211,111,-211,111,321,311,-211,111,
CYG      &211,111,-321,-311,411,421,-211,211,-211,111,2*211,111,-211,211,
CYG      &111,211,-321,2*-311,-321,-311,311,-321,321,22,-82,22,21,3*0,111/
CYG       DATA (KFDP(I,2),I= 858,2000)/3*211,-311,22,-211,111,-211,111,
CYG      &-211,211,-213,113,223,221,211,111,211,111,2*211,213,113,223,221,
CYG      &22,211,111,211,111,4*211,-211,111,-211,111,-211,211,-211,211,321,
CYG      &311,321,311,-211,111,-211,111,-211,211,-211,2*211,111,211,111,
CYG      &4*211,-321,-311,-321,-311,411,421,411,421,-211,211,111,211,-321,
CYG      &130,310,22,-211,111,2*-211,-321,130,310,221,111,-321,130,310,221,
CYG      &-211,111,22,-82,22,21,3*0,111,-211,11,-11,13,-13,-211,111,-211,
CYG      &111,-11,-13,-82,211,111,221,111,4*22,-11,-13,-15,-1,-2,-3,-4,
CYG      &2*21,211,111,3*22,-211,111,22,11,7*12,7*14,-321,-323,-311,-313,
CYG      &-311,-313,211,213,211,213,211,213,111,221,331,113,223,111,221,
CYG      &113,223,321,323,321,-211,-213,111,221,331,113,223,333,10221,111,
CYG      &221,331,113,223,211,213,211,213,321,323,321,323,321,323,311,313,
CYG      &311,313,2*-1,-3,-1,2203,3201,3203,2203,2101,2103,2*0,11,13,15,
CYG      &-211,-213,-20213,-431,-433,3*3122,1,4,3,4,1,3,2*0,-211,11,22,111,
CYG      &211,22,-211,111,22,-211,111,211,2*22,0,-211,111,211,2*22,0,
CYG      &2*-211,111,22,111,211,22,211,2*-211,2*111,-211,2*211,111,211,
CYG      &-211,2*111,211,-321,-211,111,11,-211,111,211,111,22,111,2*22,
CYG      &-211,111,211,3*22,847*0/
CYG       DATA (KFDP(I,3),I=   1, 944)/75*0,14,6*0,2*16,2*0,5*111,310,130,
CYG      &2*0,2*111,310,130,321,113,211,223,221,2*113,2*211,2*223,2*221,
CYG      &2*113,221,113,2*213,-213,195*0,4*3,4*4,1,4,3,2*2,10*81,25*0,-211,
CYG      &3*111,-311,-313,-311,-321,-313,-323,111,221,331,113,223,-311,
CYG      &-313,-311,-321,-313,-323,111,221,331,113,223,22*0,111,113,2*211,
CYG      &-211,-311,211,111,3*211,-211,7*211,-321,-323,-311,-321,-313,-323,
CYG      &-211,-213,-321,-323,-311,-321,-313,-323,-211,-213,22*0,111,113,
CYG      &-311,2*-211,211,-211,310,-211,2*111,211,2*-211,-321,-211,2*211,
CYG      &-211,111,-211,2*211,0,221,331,333,321,311,221,331,333,321,311,
CYG      &20*0,3,0,-411,-413,-10413,-10411,-20413,-415,-411,-413,-10413,
CYG      &-10411,-20413,-415,-411,-413,16*0,-4,-1,-4,-3,2*-2,-421,-423,
CYG      &-10423,-10421,-20423,-425,-421,-423,-10423,-10421,-20423,-425,
CYG      &-421,-423,16*0,-4,-1,-4,-3,2*-2,-431,-433,-10433,-10431,-20433,
CYG      &-435,-431,-433,-10433,-10431,-20433,-435,-431,-433,19*0,-4,-1,-4,
CYG      &-3,2*-2,3*0,441,443,441,443,441,443,-4,-1,-4,-3,-4,-3,-4,-1,531,
CYG      &533,531,533,3,2,3,2,511,513,511,513,1,2,0,-11,0,2*111,-211,-11,
CYG      &11,-13,2*221,3*0,111,27*0,111,2*0,22,111,5*0,111,12*0,2*21,103*0,
CYG      &-211,2*111,-211,3*111,-211,111,211,14*0,111,6*0,111,-211,8*0,111,
CYG      &-211,9*0,111,-211,111,-211,4*0,111,-211,111,-211,8*0,111,-211,
CYG      &111,-211,4*0,111,-211,111,-211,11*0,-211,6*0,111,211,4*0,111/
CYG       DATA (KFDP(I,3),I= 945,2000)/13*0,2*111,211,-211,211,-211,7*0,
CYG      &-211,111,13*0,2*21,-211,111,6*0,2212,3122,3212,3214,2112,2114,
CYG      &2212,2112,3122,3212,3214,2112,2114,2212,2112,52*0,3*3,1,8*0,
CYG      &3*4122,8*0,4,1,4,3,2*2,3*0,2112,43*0,3322,861*0/
CYG       DATA (KFDP(I,4),I=   1,2000)/88*0,3*111,8*0,-211,0,-211,3*0,111,
CYG      &2*-211,0,111,0,2*111,113,221,111,-213,-211,211,195*0,13*81,41*0,
CYG      &111,211,111,211,7*0,111,211,111,211,35*0,2*-211,2*111,211,111,
CYG      &-211,2*211,2*-211,2*0,-211,111,-211,111,4*0,-211,111,-211,111,
CYG      &34*0,111,-211,3*111,3*-211,2*111,3*-211,4*0,-321,-311,3*0,-321,
CYG      &-311,20*0,-3,31*0,6*1,30*0,6*2,33*0,6*3,9*0,8*4,4*0,4*-5,4*0,
CYG      &2*-5,7*0,-11,264*0,111,-211,4*0,111,57*0,-211,111,5*0,-211,111,
CYG      &52*0,2101,2103,2*2101,19*0,6*2101,909*0/
CYG       DATA (KFDP(I,5),I=   1,2000)/90*0,111,16*0,111,7*0,111,0,2*111,
CYG      &303*0,-211,2*111,-211,111,-211,111,54*0,111,-211,3*111,-211,111,
CYG      &1510*0/
CYG  
CYG C...LUDAT4, with character strings.
CYG       DATA (CHAF(I)  ,I=   1, 281)/'d','u','s','c','b','t','l','h',
CYG      &2*' ','e','nu_e','mu','nu_mu','tau','nu_tau','chi','nu_chi',
CYG      &2*' ','g','gamma','Z','W','H',2*' ','reggeon','pomeron',2*' ',
CYG      &'Z''','Z"','W''','H''','A','H','eta_tech','LQ_ue','R',40*' ',
CYG      &'specflav','rndmflav','phasespa','c-hadron','b-hadron',
CYG      &'t-hadron','l-hadron','h-hadron','Wvirt','diquark','cluster',
CYG      &'string','indep.','CMshower','SPHEaxis','THRUaxis','CLUSjet',
CYG      &'CELLjet','table',' ','pi',2*'K',2*'D','D_s',2*'B','B_s','B_c',
CYG      &'pi','eta','eta''','eta_c','eta_b','eta_t','eta_l','eta_h',2*' ',
CYG      &'rho',2*'K*',2*'D*','D*_s',2*'B*','B*_s','B*_c','rho','omega',
CYG      &'phi','J/psi','Upsilon','Theta','Theta_l','Theta_h',2*' ','b_1',
CYG      &2*'K_1',2*'D_1','D_1s',2*'B_1','B_1s','B_1c','b_1','h_1','h''_1',
CYG      &'h_1c','h_1b','h_1t','h_1l','h_1h',2*' ','a_0',2*'K*_0',2*'D*_0',
CYG      &'D*_0s',2*'B*_0','B*_0s','B*_0c','a_0','f_0','f''_0','chi_0c',
CYG      &'chi_0b','chi_0t','chi_0l','chi_0h',2*' ','a_1',2*'K*_1',
CYG      &2*'D*_1','D*_1s',2*'B*_1','B*_1s','B*_1c','a_1','f_1','f''_1',
CYG      &'chi_1c','chi_1b','chi_1t','chi_1l','chi_1h',2*' ','a_2',
CYG      &2*'K*_2',2*'D*_2','D*_2s',2*'B*_2','B*_2s','B*_2c','a_2','f_2',
CYG      &'f''_2','chi_2c','chi_2b','chi_2t','chi_2l','chi_2h',2*' ','K_L',
CYG      &'K_S',8*' ','psi''',3*' ','Upsilon''',45*' ','pi_diffr'/
CYG       DATA (CHAF(I)  ,I= 282, 500)/'n_diffr','p_diffr','rho_diff',
CYG      &'omega_di','phi_diff','J/psi_di',18*' ','Lambda',5*' ',
CYG      &'Lambda_c',' ',2*'Xi_c',6*' ','Lambda_b',' ',2*'Xi_b',6*' ','n',
CYG      &'p',' ',3*'Sigma',2*'Xi',' ',3*'Sigma_c',2*'Xi''_c','Omega_c',
CYG      &4*' ',3*'Sigma_b',2*'Xi''_b','Omega_b',4*' ',4*'Delta',
CYG      &3*'Sigma*',2*'Xi*','Omega',3*'Sigma*_c',2*'Xi*_c','Omega*_c',
CYG      &4*' ',3*'Sigma*_b',2*'Xi*_b','Omega*_b',114*' '/
CYG  
CYG C...LUDATR, with initial values for the random number generator.
CYG       DATA MRLU/19780503,0,0,97,33,0/
CYG  
CYG       END
