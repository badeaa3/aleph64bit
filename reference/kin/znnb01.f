      SUBROUTINE ASKUSE(IDPR,ISTA,NITR,NIVX,ECMS,WEIT)
C-----------------------------------------------------------------------
C Event generation
C-----------------------------------------------------------------------
      DIMENSION qg(4),qz(4),qn(4),qb(4)
      DIMENSION ptrak(4,2)
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON / BCS / IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
      PARAMETER (L1MST=200, L1PAR=200)
      PARAMETER (L2PAR=500, L2PARF=2000 )
      PARAMETER (LJNPAR=4000)
      COMMON /LUDAT1/ MSTU(L1MST),PARU(L1PAR),MSTJ(L1MST),PARJ(L1PAR)
      COMMON /LUDAT2/ KCHG(L2PAR,3),PMAS(L2PAR,4),PARF(L2PARF),VCKM(4,4)
      COMMON /LUDAT3/ MDCY(L2PAR,3),MDME(L2PARF,2),BRAT(L2PARF),
     &                KFDP(L2PARF,5)
      COMMON /LUDAT4/ CHAF(L2PAR)
      CHARACTER*8 CHAF
      COMMON /LUJETS/ N7LU,K7LU(LJNPAR,5),P7LU(LJNPAR,5),V7LU(LJNPAR,5)
C
C
      COMMON / miscl / tabl(20),ecm,sigt,
     &                 loutbe,idb1,idb2,nevent(11)
      COMMON / VERTX / IFVRT,XVRT(3),SXVRT(3),sdvrt(3),vrtx(4)
      INTEGER loutbe,idb1,idb2,nevent,IFVRT
      REAL*4 sdvrt,vrtx,tabl,XVRT,SXVRT
      REAL*4 amarset
      external amarset
C
C  Initialization ASKUSE's arguments
C
      ista = 0
      nitr = 0
      nivx = 0
      ecms = ecm
      weit = 1.
      sbeam = ecm**2
      n7lu = 0
      idpr = 0
C
C  Smear vertex position
C
      CALL rannor (rx,ry)
      CALL rannor (rz,dum)
      vrtx(1) = rx*sdvrt(1)
      vrtx(2) = ry*sdvrt(2)
      vrtx(3) = rz*sdvrt(3)
      vrtx(4) = 0.
      IF ( IFVRT.ge.2) then
         CALL RANNOR(RXX,RYY)
         CALL RANNOR(RZZ,DUM)
         VRTX(1) = VRTX(1) + RXX*SXVRT(1)
         VRTX(2) = VRTX(2) + RYY*SXVRT(2)
         VRTX(3) = VRTX(3) + RZZ*SXVRT(3)
      ENDIF
      IF ( IFVRT.ge.1) then
         VRTX(1) = VRTX(1) + XVRT(1)
         VRTX(2) = VRTX(2) + XVRT(2)
         VRTX(3) = VRTX(3) + XVRT(3)
      ENDIF
C
C  Store beam particles also in bos banks
C
      ipart = kgpart(11)
      DO 2 itr = 1,2
         DO 9 i=1,4
 9       ptrak(i,itr) = 0.
         ipart = kgpart(11)
         ptrak(3,itr) = 0.5*ecm
         IF ( itr .EQ. 2 ) THEN
           ipart = kgpart(-11)
           ptrak(3,itr) =- 0.5*ecm
         ENDIF
         ptrak(4,itr) = 0.
         ist=kbkine(-itr,ptrak(1,itr),ipart,0)
         IF ( ist .LE. 0 ) THEN
            ista = -2
            GO TO 998
         ENDIF
  2   CONTINUE
C
C  Now generate the event
C
      nevent(1) = nevent(1) + 1
C      WRITE(6,*) 'Event : ',nevent(1)
      call znnbge(ecms,qg,qz,qn,qb)
C
C  Radiative photon in the initial state ?
C
      n7lu = n7lu + 1
      kfg = 22
      CALL hhlu1(n7lu,kfg,qg(1),qg(2),qg(3),qg(4))
      k7lu(n7lu,1) = 1
      k7lu(n7lu,3) = 0
      nrad = 1
C
C  Fill the Z
C
      kfz = 23
      n7lu = n7lu + 1
      CALL hhlu1(n7lu,kfz,qz(1),qz(2),qz(3),qz(4))
      k7lu(n7lu,1) = 1
      k7lu(n7lu,3) = 0
C
C   Fill the neutrinos
C
      kfn = 12
      n7lu = n7lu + 1
      CALL hhlu1(n7lu,kfn,qn(1),qn(2),qn(3),qn(4))
      k7lu(n7lu,1) = 1
      k7lu(n7lu,3) = 0
C
      kfb = -12
      n7lu = n7lu + 1
      CALL hhlu1(n7lu,kfb,qb(1),qb(2),qb(3),qb(4))
      k7lu(n7lu,1) = 1
      k7lu(n7lu,3) = 0
C   switch to second random sequence
      am = amarset(1)
      n7sav = n7lu
C
C  Other decays and fragmentation
C
      CALL luexec
      idpr = abs(k7lu(n7sav+1,2))
      call hfill(10001,float(idpr),dum,1.)
C
C  Listing of the event
C
      IF ( nevent(1) .GE. idb1 .AND.
     .     nevent(1) .LE. idb2 ) CALL lulist(1)
C
C      Call the specific routine KXL7AL to fill BOS banks
C
      CALL kxl7al (vrtx,ist,nivx,nitr)
      ista = ist
C
C  Event counters
C
  998 IF ( ist .EQ. 0 ) nevent(2) = nevent(2) + 1
      IF ( ist .GT. 0) THEN
        nevent(3) = nevent(3) + 1
        nevent(4) = nevent(4) + 1
        WRITE(6,*) 'Evt ',nevent(1),' ist = ',ist
        CALL lulist(1)
      ELSEIF ( ist .LT. 0) THEN
        nevent(3) = nevent(3) + 1
        nevent(4-ist) = nevent(4-ist) + 1
      ENDIF
C
C    look at event content
      CALL LUTABU(11)
      CALL LUTABU(21)
      RETURN
      END
      SUBROUTINE ASKUSI(ICODE)
C-----------------------------------------------------------------------
C
C
C-----------------------------------------------------------------------
C
      PARAMETER(lpdec=48)
      PARAMETER(igcod=5040)
      INTEGER nodec(lpdec)
      INTEGER altabl,namind,alrlep
      EXTERNAL altabl,namind,alrlep
      REAL*4 ecm
      REAL*8 w,z,w2,z2,wd2,zd2,xw,alfwem,cost2,fconv
      REAL*8 s,rs
      COMMON / znnpar / w,z,w2,z2,wd2,zd2,xw,alfwem,cost2,fconv
      COMMON / pars / s,rs
      PARAMETER (PI=3.1415926535897932364,PI2=PI*PI,PI4=PI2*PI2)
      PARAMETER (TWOPI = 2.*PI , PIBY2 = PI/2., PIBY4 = PI/4.)
      PARAMETER (PIBY6 = PI/6. , PIBY8 = PI/8.)
      PARAMETER (PIBY12= PI/12., PIBY3 = PI/3.)
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON / BCS / IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
      PARAMETER (L1MST=200, L1PAR=200)
      PARAMETER (L2PAR=500, L2PARF=2000 )
      PARAMETER (LJNPAR=4000)
      COMMON /LUDAT1/ MSTU(L1MST),PARU(L1PAR),MSTJ(L1MST),PARJ(L1PAR)
      COMMON /LUDAT2/ KCHG(L2PAR,3),PMAS(L2PAR,4),PARF(L2PARF),VCKM(4,4)
      COMMON /LUDAT3/ MDCY(L2PAR,3),MDME(L2PARF,2),BRAT(L2PARF),
     &                KFDP(L2PARF,5)
      COMMON /LUDAT4/ CHAF(L2PAR)
      CHARACTER*8 CHAF
      COMMON /LUJETS/ N7LU,K7LU(LJNPAR,5),P7LU(LJNPAR,5),V7LU(LJNPAR,5)
C
C
      COMMON / miscl / tabl(20),ecm,sigt,
     &                 loutbe,idb1,idb2,nevent(11)
      COMMON / VERTX / IFVRT,XVRT(3),SXVRT(3),sdvrt(3),vrtx(4)
      INTEGER loutbe,idb1,idb2,nevent,IFVRT
      REAL*4 sdvrt,vrtx,tabl,XVRT,SXVRT
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
      loutbe = IW(6)
C...Set generator code
      icode = igcod
      WRITE (loutbe,'(30X,''W E L C O M E   T O   Z N N B 0 1 '',/,
     $                30X,''**********************************'',/,
     $                30X,'' Generator code  is  # '',I10       ,/,
     $     30x,'' last modification December 20,2000'',/)') ICODE
C...Create the KLIN bank and complete the PART bank
      CALL kxl7pa(ipart,iklin)
      IF( ipart .LE . 0 .OR. iklin .LE. 0 ) THEN
        WRITE(loutbe,1000) ipart,iklin
 1000   FORMAT(1X,'+++ASKUSI+++ ERROR FILLING PART OR KLIN---STOP'
     $  ,2I5)
        STOP
      ENDIF
C Read the generator parameters
      ngene = NAMIND('GENE')
      jgene = IW(ngene)
      IF(jgene.NE.0) THEN
        ecm    =      RW(jgene+1)
        amz    =      RW(jgene+2)
        gmz    =      RW(jgene+3)
        sw2    =      RW(jgene+4)
      ELSE
        ecm = 500.
        amz = 91.2
        gmz = 2.5
        sw2 = .230
      ENDIF
C
      pmas(23,1) = amz
      pmas(23,2) = gmz
      parj( 102) = sw2
C
      TABL(1)  = ecm
      TABL(2)  = amz
      TABL(3)  = gmz
      TABL(4)  = sw2
C...Initialize ZZNB
      Z=amz/1000.
      XW=sw2
      W=Z*SQRT(1.-xw)
      W2=W**2
      Z2=Z**2
      WD2=1./W2
      ZD2=1./Z2
      ALFWEM=ulalem(ecm**2)
      COST2=(PI*ALFWEM/XW)**3/(1.-XW)
      FCONV=0.3893796623D+03
      CALL znnbin(ecm)
C...Fill back the Higgs masses into the PART bank
      napar = NAMIND('PART')
      jpart = IW(napar)
C...For Z
      ipart = kgpart(23)
      rw(jpart+lmhlen+(ipart-1)*iw(jpart+1)+6) = pmas(23,1)
C...For top
      ipart = kgpart(6)
      rw(jpart+lmhlen+(ipart-1)*iw(jpart+1)+6) = pmas(6,1)
      ianti = ITABL(jpart,ipart,10)
      kapar = krow(jpart,ianti)
      rw(kapar+6)=pmas(6,1)
C...Get list of lund particle # which should not be decayed
      mxdec = KNODEC(nodec,lpdec)
      mxdec = MIN(mxdec,lpdec)
C...Inhibit lund decays which should be done in galeph
      IF ( mxdec .GT. 0 ) THEN
        DO 10 i=1,mxdec
          IF ( nodec(i) .GT. 0 ) THEN
            jidb = NLINK('MDC1',nodec(i))
            IF ( jidb .eq. 0 ) mdcy(lucomp(nodec(i)),1) = 0
          ENDIF
   10   CONTINUE
      ENDIF
C...Vertex smearing and offset
      sdvrt(1) = 0.035
      sdvrt(2) = 0.0012
      sdvrt(3) = 1.28
      jsvrt = NLINK('SVRT',0)
      IF ( jsvrt .NE. 0 ) THEN
        sdvrt(1) = RW(jsvrt+1)
        sdvrt(2) = RW(jsvrt+2)
        sdvrt(3) = RW(jsvrt+3)
      ENDIF
C   get an offset for position of interaction point
C   if needed get a smearing on this position
C   XVRT    x      y      z    ( sz    sy    sz)
C
      call vzero(XVRT,3)
      CALL VZERO(SXVRT,3)
      IFVRT = 0
      NAXVRT=NAMIND('XVRT')
      JXVRT=IW(NAXVRT)
      IF (JXVRT.NE.0) THEN
          IFVRT = 1
          XVRT(1)=RW(JXVRT+1)
          XVRT(2)=RW(JXVRT+2)
          XVRT(3)=RW(JXVRT+3)
          IF ( IW(JXVRT).gt.3) then
             IFVRT = 2
             SXVRT(1)=RW(JXVRT+4)
             SXVRT(2)=RW(JXVRT+5)
             SXVRT(3)=RW(JXVRT+6)
          ENDIF
      ENDIF
      tabl(5) = sdvrt(1)
      tabl(6) = sdvrt(2)
      tabl(7) = sdvrt(3)
      TABL(8) = XVRT(1)
      TABL(9) = XVRT(2)
      TABL(10) = XVRT(3)
      TABL(11) = sXVRT(1)
      TABL(12) = sXVRT(2)
      TABL(13) = sXVRT(3)
C
C  Fill the KPAR bank with the generator parameters
C
       jkpar = altabl('KPAR',13,1,tabl,'2I,(F)','C')
C  Fill RLEP bank
       iebeam = NINT(ecm*500)
       jrlep = alrlep(iebeam,'    ',0,0,0)
C...Debug flags
      jdebu = IW(NAMIND('DEBU'))
      IF ( jdebu .GT. 0 ) THEN
        idb1 = IW(jdebu+1)
        idb2 = IW(jdebu+2)
      ENDIF
C
C  Initialize events counters
C
       DO 11 i = 1,11
   11  nevent(i) = 0
C
C  Print PART and KLIN banks
C
C     CALL PRPART
C
      CALL PRTABL('KPAR',0)
      CALL PRTABL('RLEP',0)
C
      CALL hbook1(10000,'Weight',100,0.,1.,0.)
      CALL hbook1(10001,'Z final state',20,0.,20.,0.)
C
C  book event content machinery
      CALL LUTABU(10)
      CALL LUTABU(20)
C
      RETURN
      END
***************************************************************
C       This is the trans.mom. distribution
      DOUBLE PRECISION FUNCTION DISTRPT (PT)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      REAL*4 ecm
      REAL*8 w,z,w2,z2,wd2,zd2,xw,alfwem,cost2,fconv
      REAL*8 s,rs
      COMMON / znnpar / w,z,w2,z2,wd2,zd2,xw,alfwem,cost2,fconv
      COMMON / pars / s,rs
      PARAMETER (PI=3.1415926535897932364,PI2=PI*PI,PI4=PI2*PI2)
      PARAMETER (TWOPI = 2.*PI , PIBY2 = PI/2., PIBY4 = PI/4.)
      PARAMETER (PIBY6 = PI/6. , PIBY8 = PI/8.)
      PARAMETER (PIBY12= PI/12., PIBY3 = PI/3.)
      EXTERNAL FSUB1
      DIMENSION XX(2)
C
C       YMAX is the maximum of the absolute value of the rapidity
C
      X=(S+Z2)/(2.*RS*SQRT(PT**2+Z2))
      YMAX=LOG(X+SQRT(X**2-1.))
      YMIN=0.
C
      XX(2) = PT
      DISTRPT = 2.* DGMLT1(FSUB1,YMIN,YMAX,10,6,XX)
C
      RETURN
      END
**************************************************************
**************************************************************
C  The following subroutine gives the double distribution
C  in the transverse momemtum and rapidity of Z boson, well
C  normalized in units of pb/TeV.
C  It's expressed as a function of the three invariants: S,CP,CM

      DOUBLE PRECISION FUNCTION DISTRPTY (PT,Y)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      REAL*4 ecm
      REAL*8 w,z,w2,z2,wd2,zd2,xw,alfwem,cost2,fconv
      REAL*8 s,rs
      COMMON / znnpar / w,z,w2,z2,wd2,zd2,xw,alfwem,cost2,fconv
      COMMON / pars / s,rs
      PARAMETER (PI=3.1415926535897932364,PI2=PI*PI,PI4=PI2*PI2)
      PARAMETER (TWOPI = 2.*PI , PIBY2 = PI/2., PIBY4 = PI/4.)
      PARAMETER (PIBY6 = PI/6. , PIBY8 = PI/8.)
      PARAMETER (PIBY12= PI/12., PIBY3 = PI/3.)
C
      AMT=SQRT(Z2+PT**2)
      EZ=AMT*COSH(Y)
      PZ=SQRT(EZ**2-Z2)
      CTHZ=AMT*SINH(Y)/PZ

C       ----------------------------------------
      CP=RS*(EZ+PZ*CTHZ)
      CM=RS*(EZ-PZ*CTHZ)
C       this are the two main Lorentz-invariants
C       expressed in the C.o.M. frame
C       ---------------------------------------

      C2=CP*CM-S*Z2
      C0=S*(S+Z2-CP-CM)

      AP=S*(CP-Z2)
      AM=S*(CM-Z2)

      BP=2.*S*(C2+CP*(CP-Z2)-Z2*(S-CM))
      BM=2.*S*(C2+CM*(CM-Z2)-Z2*(S-CP))

      RPCM=CM*(S-CM)-C2
      RMCP=CP*(S-CP)-C2

      ALWS=C2+W2*(2.*S+2.*W2-CP-CM)
      ALWP=RMCP+W2*(CP+CM)
      ALWM=RPCM+W2*(CP+CM)

      ALPWP=AP+W2*(CP+CM)
      ALPWM=AM+W2*(CP+CM)

      BEWS=W2**2*(S+W2-CP)*(S+W2-CM)
      BEWP=S*W2*Z2*(S+W2-CP)
      BEWM=S*W2*Z2*(S+W2-CM)

      OGP=LOG(1.+(S-CP)/W2)
      OGM=LOG(1.+(S-CM)/W2)
      OGS=LOG(2.*EZ*(EZ+PZ)/Z2-1.)

      OGWP=LOG(ALWP*(ALWP+SQRT(ALWP**2-4.*BEWP))/2./BEWP-1.)
      OGWM=LOG(ALWM*(ALWM+SQRT(ALWM**2-4.*BEWM))/2./BEWM-1.)
      OGWS=LOG(ALWS*(ALWS+SQRT(ALWS**2-4.*BEWS))/2./BEWS-1.)

      OGPWP=LOG(ALPWP*(ALPWP+SQRT(ALPWP**2-4.*BEWM))/2./BEWM-1.)
      OGPWM=LOG(ALPWM*(ALPWM+SQRT(ALPWM**2-4.*BEWP))/2./BEWP-1.)

C       =======================================
C       Analytic expressions for the integrals
C       on neutrinos variables
C       =======================================

      AI1P=-OGP/(S-CP)
      AI1M=-OGM/(S-CM)
      AI1S=OGS/(2.*RS*PZ)

      AI2P=S*Z2/BEWP
      AI2M=S*Z2/BEWM

      AI3P=-OGPWP/SQRT(ALPWP**2-4.*BEWM)
      AI3M=-OGPWM/SQRT(ALPWM**2-4.*BEWP)
      AI3S=OGWS/SQRT(ALWS**2-4.*BEWS)

      AI4P=-OGWP/SQRT(ALWP**2-4.*BEWP)
      AI4M=-OGWM/SQRT(ALWM**2-4.*BEWM)

      AI5P=((C0+W2*(S-CP))/(S+W2-CP)-(C2+W2*(S-CP))/W2
     *    -((S-CM)*(C2+W2*(S-CM))+W2*(C2-C0))*AI3S)/(ALWS**2-4.*BEWS)
      AI5M=((C0+W2*(S-CM))/(S+W2-CM)-(C2+W2*(S-CM))/W2
     *    -((S-CP)*(C2+W2*(S-CP))+W2*(C2-C0))*AI3S)/(ALWS**2-4.*BEWS)

      AI6S=((S-CP)**2/(W2*(S+W2-CP))+(S-CM)**2/(W2*(S+W2-CM))
     *    -12.*C0*C2/(ALWS**2-4.*BEWS)
     *    +(2.*(C2-C0)+6.*C0*C2*ALWS/(ALWS**2-4.*BEWS))*AI3S)
     *    /(ALWS**2-4.*BEWS)
      AI6P=(4.*PZ**2/Z2+(S-CM)**2/(W2*(S+W2-CM))
     *    -12.*C0*C2/(ALPWP**2-4.*BEWM)
     *    -(2.*(AP-RPCM)+6.*C0*C2*ALPWP/(ALPWP**2-4.*BEWM))*AI3P)
     *    /(ALPWP**2-4.*BEWM)
      AI6M=(4.*PZ**2/Z2+(S-CP)**2/(W2*(S+W2-CP))
     *    -12.*C0*C2/(ALPWM**2-4.*BEWP)
     *    -(2.*(AM-RMCP)+6.*C0*C2*ALPWM/(ALPWM**2-4.*BEWP))*AI3M)
     *    /(ALPWM**2-4.*BEWP)

      AI7P=(AP/W2-RPCM/(S+W2-CM)-(BP/2.+4.*S*PZ**2*W2)*AI3P)
     *    /(ALPWP**2-4.*BEWM)
      AI7M=(AM/W2-RMCP/(S+W2-CP)-(BM/2.+4.*S*PZ**2*W2)*AI3M)
     *    /(ALPWM**2-4.*BEWP)

      AI8P=(2.*W2+2.*(S+W2-CM)-2.*EZ*ALPWP/(Z2*RS)
     *    +(W2*(AP-RPCM)+(S-CM)*AP)*AI3P)/(ALPWP**2-4.*BEWM)
      AI8M=(2.*W2+2.*(S+W2-CP)-2.*EZ*ALPWM/(Z2*RS)
     *    +(W2*(AM-RMCP)+(S-CP)*AM)*AI3M)/(ALPWM**2-4.*BEWP)

      AI9P=(C2*OGP-(C2-C0)*(1.-W2*OGP/(S-CP)))/(S-CP)**2
      AI9M=(C2*OGM-(C2-C0)*(1.-W2*OGM/(S-CM)))/(S-CM)**2

      AI10P=-(C2*(S-CP)/W2+(C2-C0)*(1.-(1.+W2/(S-CP))*OGP))
     *    /((S-CP)**2*(S+W2-CP))
      AI10M=-(C2*(S-CM)/W2+(C2-C0)*(1.-(1.+W2/(S-CM))*OGM))
     *    /((S-CM)**2*(S+W2-CM))

      AI11P=(AP-RPCM-BP*AI1S/2.)/4./S/PZ**2
      AI11M=(AM-RMCP-BM*AI1S/2.)/4./S/PZ**2
C     =======================================================

      SD=1./S
      CPD=1./CP
      CMD=1./CM
      CSD=1./(CP+CM)
      CSZD=1./(2.*Z2-CP-CM)
      CPZD=1./(Z2-CP)
      CMZD=1./(Z2-CM)

C       ======================================================
C        Here we define ELMS that is the square of the matrix
C        element (averaged
C        and summed over the spins) integrated over the
C        neutrino variables. It is symmetric in the CP-CM
C        exchange (cos(thetaZ) --> -cos(thetaZ))
C        and is proportional to the invariant distribution
C        Ez*(dsigma/d3pz)
C       ======================================================
C       Output of the SCOONSCHIP program

      XTOTAL=0.
      TLPART= -2.*SD
      XTOTAL=XTOTAL+TLPART
      HDPART=(XW-1./2)
      TLPART= 4.*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=(XW-1./2)*(1.-XW)
      TLPART= -8.*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=(1.-XW)
      TLPART= 4.*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=(1.-XW)**2
      TLPART= -4.*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=-8.*CPZD*(XW-1./2)
      XTOTAL=XTOTAL+HDPART
      HDPART=8.*CPZD*(XW-1./2)*(1.-XW)
      XTOTAL=XTOTAL+HDPART
      HDPART=4.*CPZD*(XW-1./2)**2
      XTOTAL=XTOTAL+HDPART
      HDPART=CPZD**2*(XW-1./2)**2
      TLPART= -4.*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=-8.*CMZD*(XW-1./2)
      XTOTAL=XTOTAL+HDPART
      HDPART=8.*CMZD*(XW-1./2)*(1.-XW)
      XTOTAL=XTOTAL+HDPART
      HDPART=4.*CMZD*(XW-1./2)**2
      XTOTAL=XTOTAL+HDPART
      HDPART=CMZD**2*(XW-1./2)**2
      TLPART= -4.*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=CSZD*(XW-1./2)**2
      TLPART= 4.*CP*ZD2 +4.*CM*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=CSZD*CPZD*(XW-1./2)**2
      TLPART= -4.*CM -4.*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=CSZD*CMZD*(XW-1./2)**2
      TLPART= -4.*CP -4.*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=CSD
      TLPART= -1.*CP*ZD2 -1.*CM*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1P
      TLPART= 1./2.*S*ZD2 -1./2.*CM*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1P*(XW-1./2)
      TLPART= -2. +2.*S*ZD2 -4.*CP*ZD2 +2.*CM*ZD2 +4.*W2*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1P*(XW-1./2)*(1.-XW)
      TLPART= 4. -4.*S*ZD2 +8.*CP*ZD2 -4.*CM*ZD2 -8.*W2*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1P*(XW-1./2)**2
      TLPART= 2.*S*ZD2 -2.*CM*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1P*(1.-XW)
      TLPART= 2. +2.*S*ZD2 -4.*CP*ZD2 +2.*CM*ZD2 +4.*W2*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1P*(1.-XW)**2
      TLPART= -4. -2.*S*ZD2 +4.*CP*ZD2 -2.*CM*ZD2 -4.*W2*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1P*CPZD*(XW-1./2)
      TLPART= -4.*S -4.*W2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1P*CPZD*(XW-1./2)*(1.-XW)
C      TLPART= 4.*S +8.*W2 +4.*Z2B
C     Z2b not defined .... should it be Z2 ?  BB sept 98
      TLPART= 4.*S +8.*W2 +4.*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1P*CMZD*(XW-1./2)
      TLPART= -6.*S +4.*CP -8.*W2 -2.*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1P*CMZD*(XW-1./2)*(1.-XW)
      TLPART= 16.*S -12.*CP +16.*W2 +4.*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1P*CMZD*(XW-1./2)**2
      TLPART= 4.*S -8.*CP +8.*W2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1P*CMZD**2*(XW-1./2)**2
      TLPART= -8.*S*Z2 +8.*CP*Z2 -8.*W2*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1P*CSZD*(XW-1./2)**2
      TLPART= 16.*S +4.*S*CP*ZD2 +4.*S*CM*ZD2 -4.*CP -4.*CP*CM*ZD2
     1  +4.*CP*W2*ZD2 -4.*CP**2*ZD2 -8.*CM +4.*CM*W2*ZD2 +4.*W2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1P*CSZD*CPZD*(XW-1./2)**2
      TLPART= -12.*S*CM +4.*S*W2 -4.*S*Z2 +8.*S**2 -4.*CM*W2
     1  +8.*CM*Z2 -8.*W2*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1P*CSZD*CMZD*(XW-1./2)**2
      TLPART= -12.*S*CP +4.*S*W2 -4.*S*Z2 +8.*S**2 -8.*CP*W2
     1  +4.*CP*Z2 +4.*CP**2 -4.*W2*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1P*CSD
      TLPART= -1.*S*CP*ZD2 -1.*S*CM*ZD2 +1.*CP*CM*ZD2 -1.*CP*W2*ZD2
     1  +1.*CP**2*ZD2 -1.*CM*W2*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1M
      TLPART= 1./2.*S*ZD2 -1./2.*CP*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1M*(XW-1./2)
      TLPART= -2. +2.*S*ZD2 +2.*CP*ZD2 -4.*CM*ZD2 +4.*W2*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1M*(XW-1./2)*(1.-XW)
      TLPART= 4. -4.*S*ZD2 -4.*CP*ZD2 +8.*CM*ZD2 -8.*W2*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1M*(XW-1./2)**2
      TLPART= 2.*S*ZD2 -2.*CP*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1M*(1.-XW)
      TLPART= 2. +2.*S*ZD2 +2.*CP*ZD2 -4.*CM*ZD2 +4.*W2*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1M*(1.-XW)**2
      TLPART= -4. -2.*S*ZD2 -2.*CP*ZD2 +4.*CM*ZD2 -4.*W2*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1M*CPZD*(XW-1./2)
      TLPART= -6.*S +4.*CM -8.*W2 -2.*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1M*CPZD*(XW-1./2)*(1.-XW)
      TLPART= 16.*S -12.*CM +16.*W2 +4.*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1M*CPZD*(XW-1./2)**2
      TLPART= 4.*S -8.*CM +8.*W2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1M*CPZD**2*(XW-1./2)**2
      TLPART= -8.*S*Z2 +8.*CM*Z2 -8.*W2*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1M*CMZD*(XW-1./2)
      TLPART= -4.*S -4.*W2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1M*CMZD*(XW-1./2)*(1.-XW)
      TLPART= 4.*S +8.*W2 +4.*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1M*CSZD*(XW-1./2)**2
      TLPART= 16.*S +4.*S*CP*ZD2 +4.*S*CM*ZD2 -8.*CP -4.*CP*CM*ZD2
     1  +4.*CP*W2*ZD2 -4.*CM +4.*CM*W2*ZD2 -4.*CM**2*ZD2 +4.*W2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1M*CSZD*CPZD*(XW-1./2)**2
      TLPART= -12.*S*CM +4.*S*W2 -4.*S*Z2 +8.*S**2 -8.*CM*W2
     1  +4.*CM*Z2 +4.*CM**2 -4.*W2*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1M*CSZD*CMZD*(XW-1./2)**2
      TLPART= -12.*S*CP +4.*S*W2 -4.*S*Z2 +8.*S**2 -4.*CP*W2
     1  +8.*CP*Z2 -8.*W2*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1M*CSD
      TLPART= -1.*S*CP*ZD2 -1.*S*CM*ZD2 +1.*CP*CM*ZD2 -1.*CP*W2*ZD2
     1  -1.*CM*W2*ZD2 +1.*CM**2*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=8.*AI1S*(XW-1./2)
      XTOTAL=XTOTAL+HDPART
      HDPART=-8.*AI1S*(1.-XW)
      XTOTAL=XTOTAL+HDPART
      HDPART=AI1S*CPZD*(XW-1./2)
      TLPART= 20.*S -8.*CM +16.*W2 +4.*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1S*CMZD*(XW-1./2)
      TLPART= 20.*S -8.*CP +16.*W2 +4.*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI1S*CSD
      TLPART= 4.*S -4.*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI2P
      TLPART= -1./2.*S*CP*ZD2 -1./2.*S*CM*ZD2 +1./2.*S*W2*ZD2
     1  +1./2.*S**2*ZD2 -1.*CP +1./2.*CP*CM*ZD2 -1./2.*CM*W2*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI2P*(XW-1./2)
      TLPART= 2.*S*CP*ZD2 +2.*S*CM*ZD2 -2.*S*W2*ZD2 -2.*S**2*ZD2
     1  +2.*CP -2.*CP*CM*ZD2 +2.*CM*W2*ZD2 -2.*W2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI2P*(XW-1./2)*(1.-XW)
      TLPART= -4.*S*CP*ZD2 -4.*S*CM*ZD2 +4.*S*W2*ZD2 +4.*S**2*ZD2
     1  -4.*CP +4.*CP*CM*ZD2 -4.*CM*W2*ZD2 +8.*W2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI2P*(XW-1./2)**2
      TLPART= -2.*S*CP*ZD2 -2.*S*CM*ZD2 +2.*S*W2*ZD2 +2.*S**2*ZD2
     1  +2.*CP*CM*ZD2 -2.*CM*W2*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI2P*(1.-XW)
      TLPART= 2.*S*CP*ZD2 +2.*S*CM*ZD2 -2.*S*W2*ZD2 -2.*S**2*ZD2
     1  +4.*CP -2.*CP*CM*ZD2 +2.*CM*W2*ZD2 +2.*W2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI2P*(1.-XW)**2
      TLPART= -2.*S*CP*ZD2 -2.*S*CM*ZD2 +2.*S*W2*ZD2 +2.*S**2*ZD2
     1  -4.*CP +2.*CP*CM*ZD2 -2.*CM*W2*ZD2 -4.*W2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI2P*CMZD*(XW-1./2)
      TLPART= 2.*S*CP -6.*S*W2 +4.*CP*W2 -2.*CP**2 -2.*W2*Z2
     1  -4.*W2**2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI2P*CMZD*(XW-1./2)*(1.-XW)
      TLPART= -4.*S*CP +12.*S*W2 +4.*S*Z2 -8.*CP*W2 -4.*CP*Z2
     1  +4.*CP**2 +4.*W2*Z2 +8.*W2**2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI2P*CMZD*(XW-1./2)**2
      TLPART= -4.*S*CP +4.*S*W2 -8.*CP*W2 +4.*CP**2 +4.*W2**2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI2P*CMZD**2*(XW-1./2)**2
      TLPART= 8.*S*CP*Z2 -8.*S*W2*Z2 -4.*S**2*Z2 +8.*CP*W2*Z2
     1  -4.*CP**2*Z2 -4.*W2**2*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI2M
      TLPART= -1./2.*S*CP*ZD2 -1./2.*S*CM*ZD2 +1./2.*S*W2*ZD2
     1  +1./2.*S**2*ZD2 +1./2.*CP*CM*ZD2 -1./2.*CP*W2*ZD2 -1.*CM
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI2M*(XW-1./2)
      TLPART= 2.*S*CP*ZD2 +2.*S*CM*ZD2 -2.*S*W2*ZD2 -2.*S**2*ZD2
     1  -2.*CP*CM*ZD2 +2.*CP*W2*ZD2 +2.*CM -2.*W2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI2M*(XW-1./2)*(1.-XW)
      TLPART= -4.*S*CP*ZD2 -4.*S*CM*ZD2 +4.*S*W2*ZD2 +4.*S**2*ZD2
     1  +4.*CP*CM*ZD2 -4.*CP*W2*ZD2 -4.*CM +8.*W2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI2M*(XW-1./2)**2
      TLPART= -2.*S*CP*ZD2 -2.*S*CM*ZD2 +2.*S*W2*ZD2 +2.*S**2*ZD2
     1  +2.*CP*CM*ZD2 -2.*CP*W2*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI2M*(1.-XW)
      TLPART= 2.*S*CP*ZD2 +2.*S*CM*ZD2 -2.*S*W2*ZD2 -2.*S**2*ZD2
     1  -2.*CP*CM*ZD2 +2.*CP*W2*ZD2 +4.*CM +2.*W2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI2M*(1.-XW)**2
      TLPART= -2.*S*CP*ZD2 -2.*S*CM*ZD2 +2.*S*W2*ZD2 +2.*S**2*ZD2
     1  +2.*CP*CM*ZD2 -2.*CP*W2*ZD2 -4.*CM -4.*W2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI2M*CPZD*(XW-1./2)
      TLPART= 2.*S*CM -6.*S*W2 +4.*CM*W2 -2.*CM**2 -2.*W2*Z2
     1  -4.*W2**2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI2M*CPZD*(XW-1./2)*(1.-XW)
      TLPART= -4.*S*CM +12.*S*W2 +4.*S*Z2 -8.*CM*W2 -4.*CM*Z2
     1  +4.*CM**2 +4.*W2*Z2 +8.*W2**2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI2M*CPZD*(XW-1./2)**2
      TLPART= -4.*S*CM +4.*S*W2 -8.*CM*W2 +4.*CM**2 +4.*W2**2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI2M*CPZD**2*(XW-1./2)**2
      TLPART= 8.*S*CM*Z2 -8.*S*W2*Z2 -4.*S**2*Z2 +8.*CM*W2*Z2
     1  -4.*CM**2*Z2 -4.*W2**2*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI3P
      TLPART= 1.*CM +1.*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI3P*(XW-1./2)
      TLPART= 8.*S*CPD*W2 +4.*S**2*CPD -2.*CM +4.*CPD*W2**2 -2.*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI3P*(1.-XW)
      TLPART= 6.*S*CM*CPD -4.*S*CM*CPD**2*W2 +2.*S*CM*CPD**2*Z2
     1  -16.*S*CPD*W2 -6.*S*CPD*Z2 +8.*S*CPD**2*W2*Z2
     1  +8.*S*CPD**2*W2**2 -2.*S*CPD**2*Z2**2 -4.*S**2*CPD
     1  +4.*S**2*CPD**2*W2 -2.*CM +10.*CM*CPD*W2 +2.*CM*CPD*Z2
     1  -2.*CM*CPD**2*W2*Z2 -4.*CM*CPD**2*W2**2 -2.*CM**2*CPD
     1  +2.*CM**2*CPD**2*W2 -14.*CPD*W2*Z2 -12.*CPD*W2**2
     1  +8.*CPD**2*W2**2*Z2 +4.*CPD**2*W2**3 -2.*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI3P*CPZD*(XW-1./2)
      TLPART= -4.*S*CM +16.*S*W2 +4.*S**2 -8.*CM*W2 +2.*CM**2
     1  +8.*W2*Z2 +12.*W2**2 +2.*Z2**2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI3P*CMZD*(XW-1./2)
      TLPART= 12.*S*CPD*W2**2 +12.*S**2*CPD*W2 +4.*S**3*CPD
     1  +4.*CPD*W2**3
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI3P*CSD
      TLPART= -1.*S*CM -2.*S*CM*CPD*W2 -1.*S*CM*CPD*Z2
     1  +2.*S*CPD*W2**2 +1.*S*CPD*Z2**2 -1.*S*Z2 -2.*S**2*CM*CPD
     1  +4.*S**2*CPD*W2 +2.*S**2*CPD*Z2 +2.*S**3*CPD +1.*CM*CPD*W2*Z2
     1  -1.*CM*W2 -1.*CM**2*CPD*W2 -2.*CPD*W2**2*Z2 -1.*W2*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI3M
      TLPART= 1.*CP +1.*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI3M*(XW-1./2)
      TLPART= 8.*S*CMD*W2 +4.*S**2*CMD -2.*CP +4.*CMD*W2**2 -2.*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI3M*(1.-XW)
      TLPART= 6.*S*CP*CMD -4.*S*CP*CMD**2*W2 +2.*S*CP*CMD**2*Z2
     1  -16.*S*CMD*W2 -6.*S*CMD*Z2 +8.*S*CMD**2*W2*Z2
     1  +8.*S*CMD**2*W2**2 -2.*S*CMD**2*Z2**2 -4.*S**2*CMD
     1  +4.*S**2*CMD**2*W2 -2.*CP +10.*CP*CMD*W2 +2.*CP*CMD*Z2
     1  -2.*CP*CMD**2*W2*Z2 -4.*CP*CMD**2*W2**2 -2.*CP**2*CMD
     1  +2.*CP**2*CMD**2*W2 -14.*CMD*W2*Z2 -12.*CMD*W2**2
     1  +8.*CMD**2*W2**2*Z2 +4.*CMD**2*W2**3 -2.*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI3M*CPZD*(XW-1./2)
      TLPART= 12.*S*CMD*W2**2 +12.*S**2*CMD*W2 +4.*S**3*CMD
     1  +4.*CMD*W2**3
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI3M*CMZD*(XW-1./2)
      TLPART= -4.*S*CP +16.*S*W2 +4.*S**2 -8.*CP*W2 +2.*CP**2
     1  +8.*W2*Z2 +12.*W2**2 +2.*Z2**2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI3M*CSD
      TLPART= -1.*S*CP -2.*S*CP*CMD*W2 -1.*S*CP*CMD*Z2
     1  +2.*S*CMD*W2**2 +1.*S*CMD*Z2**2 -1.*S*Z2 -2.*S**2*CP*CMD
     1  +4.*S**2*CMD*W2 +2.*S**2*CMD*Z2 +2.*S**3*CMD +1.*CP*CMD*W2*Z2
     1  -1.*CP*W2 -1.*CP**2*CMD*W2 -2.*CMD*W2**2*Z2 -1.*W2*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI3S*(XW-1./2)
      TLPART= -8.*S -4.*S*CP*ZD2 -4.*S*CM*ZD2 +8.*S*CPD*W2
     1  +8.*S*CMD*W2 +8.*S*W2*ZD2 +4.*S**2*CPD +4.*S**2*CMD
     1  +4.*S**2*ZD2 +4.*CP*CM*ZD2 -4.*CP*W2*ZD2 -4.*CM*W2*ZD2
     1  +4.*CPD*W2**2 +4.*CMD*W2**2 -8.*W2 +4.*W2**2*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI3S*(XW-1./2)*(1.-XW)
      TLPART= 8.*S*CP*ZD2 +8.*S*CM*ZD2 -16.*S*W2*ZD2 -8.*S**2*ZD2
     1  +8.*CP -8.*CP*CM*ZD2 +8.*CP*W2*ZD2 +8.*CM +8.*CM*W2*ZD2
     1  -8.*W2**2*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI3S*(1.-XW)
      TLPART= 16.*S +6.*S*CP*CMD -4.*S*CP*CMD**2*W2
     1  +2.*S*CP*CMD**2*Z2 -4.*S*CP*ZD2 +6.*S*CM*CPD -4.*S*CM*CPD**2*W2
     1  +2.*S*CM*CPD**2*Z2 -4.*S*CM*ZD2 -16.*S*CPD*W2 -6.*S*CPD*Z2
     1  +8.*S*CPD**2*W2*Z2 +8.*S*CPD**2*W2**2 -2.*S*CPD**2*Z2**2
     1  -16.*S*CMD*W2 -6.*S*CMD*Z2 +8.*S*CMD**2*W2*Z2
     1  +8.*S*CMD**2*W2**2 -2.*S*CMD**2*Z2**2 +8.*S*W2*ZD2 -4.*S**2*CPD
     1  +4.*S**2*CPD**2*W2 -4.*S**2*CMD +4.*S**2*CMD**2*W2 +4.*S**2*ZD2
     1  -10.*CP +4.*CP*CM*ZD2 +10.*CP*CMD*W2 +2.*CP*CMD*Z2
     1  -2.*CP*CMD**2*W2*Z2 -4.*CP*CMD**2*W2**2 -4.*CP*W2*ZD2
     1  -2.*CP**2*CMD +2.*CP**2*CMD**2*W2
      TLPART=TLPART -10.*CM +10.*CM*CPD*W2 +2.*CM*CPD*Z2
     1  -2.*CM*CPD**2*W2*Z2 -4.*CM*CPD**2*W2**2 -4.*CM*W2*ZD2
     1  -2.*CM**2*CPD +2.*CM**2*CPD**2*W2 -14.*CPD*W2*Z2 -12.*CPD*W2**2
     1  +8.*CPD**2*W2**2*Z2 +4.*CPD**2*W2**3 -14.*CMD*W2*Z2
     1  -12.*CMD*W2**2 +8.*CMD**2*W2**2*Z2 +4.*CMD**2*W2**3 +20.*W2
     1  +4.*W2**2*ZD2 +12.*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI3S*(1.-XW)**2
      TLPART= -16.*S +4.*S*CP*ZD2 +4.*S*CM*ZD2 -8.*S*W2*ZD2
     1  -4.*S**2*ZD2 +12.*CP -4.*CP*CM*ZD2 +4.*CP*W2*ZD2 +12.*CM
     1  +4.*CM*W2*ZD2 -16.*W2 -4.*W2**2*ZD2 -14.*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI3S*CPZD*(XW-1./2)
      TLPART= 4.*S*CM +12.*S*CMD*W2**2 -16.*S*W2 -8.*S**2
     1  +12.*S**2*CMD*W2 +4.*S**3*CMD +4.*CM*W2 +4.*CMD*W2**3
     1  -8.*W2**2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI3S*CPZD*(XW-1./2)*(1.-XW)
      TLPART= -4.*S*CM +24.*S*W2 +4.*S*Z2 +8.*S**2 -12.*CM*W2
     1  -8.*CM*Z2 +12.*W2*Z2 +16.*W2**2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI3S*CMZD*(XW-1./2)
      TLPART= 4.*S*CP +12.*S*CPD*W2**2 -16.*S*W2 -8.*S**2
     1  +12.*S**2*CPD*W2 +4.*S**3*CPD +4.*CP*W2 +4.*CPD*W2**3
     1  -8.*W2**2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI3S*CMZD*(XW-1./2)*(1.-XW)
      TLPART= -4.*S*CP +24.*S*W2 +4.*S*Z2 +8.*S**2 -12.*CP*W2
     1  -8.*CP*Z2 +12.*W2*Z2 +16.*W2**2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI3S*CSZD*(XW-1./2)**2
      TLPART= -16.*S*CP -8.*S*CP*CM*ZD2 +8.*S*CP*W2*ZD2
     1  -4.*S*CP**2*ZD2 -16.*S*CM +8.*S*CM*W2*ZD2 -4.*S*CM**2*ZD2
     1  +32.*S*W2 +8.*S*Z2 +24.*S**2 +4.*S**2*CP*ZD2 +4.*S**2*CM*ZD2
     1  -8.*CP*CM*W2*ZD2 +4.*CP*CM**2*ZD2 -12.*CP*W2 +4.*CP*W2**2*ZD2
     1  +4.*CP**2 +4.*CP**2*CM*ZD2 -4.*CP**2*W2*ZD2 -12.*CM*W2
     1  +4.*CM*W2**2*ZD2 +4.*CM**2 -4.*CM**2*W2*ZD2 +8.*W2**2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI3S*CSZD*CPZD*(XW-1./2)**2
      TLPART= -24.*S*CM*W2 +4.*S*CM*Z2 +8.*S*CM**2 -8.*S*W2*Z2
     1  +8.*S*W2**2 -16.*S**2*CM +16.*S**2*W2 +8.*S**3 +12.*CM*W2*Z2
     1  -8.*CM*W2**2 +4.*CM**2*W2 -4.*CM**2*Z2 -8.*W2**2*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI3S*CSZD*CMZD*(XW-1./2)**2
      TLPART= -24.*S*CP*W2 +4.*S*CP*Z2 +8.*S*CP**2 -8.*S*W2*Z2
     1  +8.*S*W2**2 -16.*S**2*CP +16.*S**2*W2 +8.*S**3 +12.*CP*W2*Z2
     1  -8.*CP*W2**2 +4.*CP**2*W2 -4.*CP**2*Z2 -8.*W2**2*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI3S*CSD
      TLPART= 2.*S*CP*CM*ZD2 -2.*S*CP*CMD*W2 -1.*S*CP*CMD*Z2
     1  -2.*S*CP*W2*ZD2 +1.*S*CP**2*ZD2 -2.*S*CM*CPD*W2 -1.*S*CM*CPD*Z2
     1  -2.*S*CM*W2*ZD2 +1.*S*CM**2*ZD2 +2.*S*CPD*W2**2 +1.*S*CPD*Z2**2
     1  +2.*S*CMD*W2**2 +1.*S*CMD*Z2**2 -4.*S*W2 -2.*S*Z2 -4.*S**2
     1  -2.*S**2*CP*CMD -1.*S**2*CP*ZD2 -2.*S**2*CM*CPD -1.*S**2*CM*ZD2
     1  +4.*S**2*CPD*W2 +2.*S**2*CPD*Z2 +4.*S**2*CMD*W2 +2.*S**2*CMD*Z2
     1  +2.*S**3*CPD +2.*S**3*CMD +2.*CP*CM +2.*CP*CM*W2*ZD2
     1  -1.*CP*CM**2*ZD2 +1.*CP*CMD*W2*Z2 -1.*CP*W2 -1.*CP*W2**2*ZD2
     1  -1.*CP*Z2 +1.*CP**2 -1.*CP**2*CM*ZD2
      TLPART=TLPART -1.*CP**2*CMD*W2 +1.*CP**2*W2*ZD2
     1  +1.*CM*CPD*W2*Z2 -1.*CM*W2 -1.*CM*W2**2*ZD2 -1.*CM*Z2 +1.*CM**2
     1  -1.*CM**2*CPD*W2 +1.*CM**2*W2*ZD2 -2.*CPD*W2**2*Z2
     1  -2.*CMD*W2**2*Z2 +2.*W2*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI4P*(XW-1./2)
      TLPART= 8.*S -8.*S*CPD*W2 -4.*S**2*CPD -4.*CP -4.*CPD*W2**2
     1  +8.*W2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI4P*(1.-XW)
      TLPART= -8.*S -6.*S*CM*CPD +4.*S*CM*CPD**2*W2
     1  -2.*S*CM*CPD**2*Z2 +16.*S*CPD*W2 +6.*S*CPD*Z2
     1  -8.*S*CPD**2*W2*Z2 -8.*S*CPD**2*W2**2 +2.*S*CPD**2*Z2**2
     1  +4.*S**2*CPD -4.*S**2*CPD**2*W2 +4.*CP +6.*CM -10.*CM*CPD*W2
     1  -2.*CM*CPD*Z2 +2.*CM*CPD**2*W2*Z2 +4.*CM*CPD**2*W2**2
     1  +2.*CM**2*CPD -2.*CM**2*CPD**2*W2 +14.*CPD*W2*Z2 +12.*CPD*W2**2
     1  -8.*CPD**2*W2**2*Z2 -4.*CPD**2*W2**3 -12.*W2 -6.*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI4P*CMZD*(XW-1./2)
      TLPART= -12.*S*CP -12.*S*CPD*W2**2 +24.*S*W2 +12.*S**2
     1  -12.*S**2*CPD*W2 -4.*S**3*CPD -12.*CP*W2 +4.*CP**2
     1  -4.*CPD*W2**3 +12.*W2**2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI4P*CSD
      TLPART= -2.*S*CP -1.*S*CM +2.*S*CM*CPD*W2 +1.*S*CM*CPD*Z2
     1  -2.*S*CPD*W2**2 -1.*S*CPD*Z2**2 +4.*S*W2 +1.*S*Z2 +4.*S**2
     1  +2.*S**2*CM*CPD -4.*S**2*CPD*W2 -2.*S**2*CPD*Z2 -2.*S**3*CPD
     1  -1.*CP*CM +1.*CP*Z2 -1.*CM*CPD*W2*Z2 +1.*CM*W2 +1.*CM*Z2
     1  -1.*CM**2 +1.*CM**2*CPD*W2 +2.*CPD*W2**2*Z2 -3.*W2*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI4M*(XW-1./2)
      TLPART= 8.*S -8.*S*CMD*W2 -4.*S**2*CMD -4.*CM -4.*CMD*W2**2
     1  +8.*W2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI4M*(1.-XW)
      TLPART= -8.*S -6.*S*CP*CMD +4.*S*CP*CMD**2*W2
     1  -2.*S*CP*CMD**2*Z2 +16.*S*CMD*W2 +6.*S*CMD*Z2
     1  -8.*S*CMD**2*W2*Z2 -8.*S*CMD**2*W2**2 +2.*S*CMD**2*Z2**2
     1  +4.*S**2*CMD -4.*S**2*CMD**2*W2 +6.*CP -10.*CP*CMD*W2
     1  -2.*CP*CMD*Z2 +2.*CP*CMD**2*W2*Z2 +4.*CP*CMD**2*W2**2
     1  +2.*CP**2*CMD -2.*CP**2*CMD**2*W2 +4.*CM +14.*CMD*W2*Z2
     1  +12.*CMD*W2**2 -8.*CMD**2*W2**2*Z2 -4.*CMD**2*W2**3 -12.*W2
     1  -6.*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI4M*CPZD*(XW-1./2)
      TLPART= -12.*S*CM -12.*S*CMD*W2**2 +24.*S*W2 +12.*S**2
     1  -12.*S**2*CMD*W2 -4.*S**3*CMD -12.*CM*W2 +4.*CM**2
     1  -4.*CMD*W2**3 +12.*W2**2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI4M*CSD
      TLPART= -1.*S*CP +2.*S*CP*CMD*W2 +1.*S*CP*CMD*Z2 -2.*S*CM
     1  -2.*S*CMD*W2**2 -1.*S*CMD*Z2**2 +4.*S*W2 +1.*S*Z2 +4.*S**2
     1  +2.*S**2*CP*CMD -4.*S**2*CMD*W2 -2.*S**2*CMD*Z2 -2.*S**3*CMD
     1  -1.*CP*CM -1.*CP*CMD*W2*Z2 +1.*CP*W2 +1.*CP*Z2 -1.*CP**2
     1  +1.*CP**2*CMD*W2 +1.*CM*Z2 +2.*CMD*W2**2*Z2 -3.*W2*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI5P*(XW-1./2)*(1.-XW)
      TLPART= 4.*S*CP +4.*S*CM -4.*S*Z2 -4.*S**2 +4.*CP*W2 -4.*CP**2
     1  +4.*W2**2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI5P*(1.-XW)
      TLPART= -2.*S*CP +4.*S*CP*CMD*W2 -2.*S*CP*CMD*Z2 -2.*S*CM
     1  -8.*S*CMD*W2*Z2 -8.*S*CMD*W2**2 +2.*S*CMD*Z2**2 +8.*S*W2
     1  +2.*S*Z2 +2.*S**2 -4.*S**2*CMD*W2 +2.*CP*CMD*W2*Z2
     1  +4.*CP*CMD*W2**2 -2.*CP*W2 -2.*CP*Z2 +2.*CP**2 -2.*CP**2*CMD*W2
     1  -4.*CM*W2 -8.*CMD*W2**2*Z2 -4.*CMD*W2**3 +6.*W2*Z2 +6.*W2**2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI5P*(1.-XW)**2
      TLPART= 4.*S*CP +4.*S*CM -16.*S*W2 -6.*S*Z2 -4.*S**2 +4.*CP*W2
     1  +6.*CP*Z2 -4.*CP**2 +12.*CM*W2 -14.*W2*Z2 -12.*W2**2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI5P*CMZD*(XW-1./2)*(1.-XW)
      TLPART= -8.*S*CP*W2 -4.*S*CP*Z2 +8.*S*W2*Z2 +16.*S*W2**2
     1  +8.*S**2*W2 -12.*CP*W2*Z2 -8.*CP*W2**2 +4.*CP**2*W2
     1  +4.*CP**2*Z2 +8.*W2**2*Z2 +8.*W2**3
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI5M*(XW-1./2)*(1.-XW)
      TLPART= 4.*S*CP +4.*S*CM -4.*S*Z2 -4.*S**2 +4.*CM*W2 -4.*CM**2
     1  +4.*W2**2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI5M*(1.-XW)
      TLPART= -2.*S*CP -2.*S*CM +4.*S*CM*CPD*W2 -2.*S*CM*CPD*Z2
     1  -8.*S*CPD*W2*Z2 -8.*S*CPD*W2**2 +2.*S*CPD*Z2**2 +8.*S*W2
     1  +2.*S*Z2 +2.*S**2 -4.*S**2*CPD*W2 -4.*CP*W2 +2.*CM*CPD*W2*Z2
     1  +4.*CM*CPD*W2**2 -2.*CM*W2 -2.*CM*Z2 +2.*CM**2 -2.*CM**2*CPD*W2
     1  -8.*CPD*W2**2*Z2 -4.*CPD*W2**3 +6.*W2*Z2 +6.*W2**2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI5M*(1.-XW)**2
      TLPART= 4.*S*CP +4.*S*CM -16.*S*W2 -6.*S*Z2 -4.*S**2 +12.*CP*W2
     1  +4.*CM*W2 +6.*CM*Z2 -4.*CM**2 -14.*W2*Z2 -12.*W2**2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI5M*CPZD*(XW-1./2)*(1.-XW)
      TLPART= -8.*S*CM*W2 -4.*S*CM*Z2 +8.*S*W2*Z2 +16.*S*W2**2
     1  +8.*S**2*W2 -12.*CM*W2*Z2 -8.*CM*W2**2 +4.*CM**2*W2
     1  +4.*CM**2*Z2 +8.*W2**2*Z2 +8.*W2**3
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI6S*(1.-XW)**2
      TLPART= 8.*S*CP*W2 -2.*S*CP*Z2 +8.*S*CM*W2 -2.*S*CM*Z2
     1  -12.*S*W2*Z2 -16.*S*W2**2 +4.*S*Z2**2 -8.*S**2*W2 +2.*S**2*Z2
     1  -2.*CP*CM*Z2 +6.*CP*W2*Z2 +8.*CP*W2**2 -4.*CP**2*W2
     1  +6.*CM*W2*Z2 +8.*CM*W2**2 -4.*CM**2*W2 -14.*W2**2*Z2 -8.*W2**3
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI6P
      TLPART= -2.*S*W2*Z2 -1.*S**2*Z2 -1.*W2**2*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI6M
      TLPART= -2.*S*W2*Z2 -1.*S**2*Z2 -1.*W2**2*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI7P
      TLPART= 1.*S*CM +1.*S*Z2 +1.*CM*W2 +1.*W2*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI7P*(XW-1./2)
      TLPART= -2.*S*CM -2.*S*Z2 -2.*CM*W2 -2.*W2*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI7P*(1.-XW)
      TLPART= -2.*S*CM +4.*S*CM*CPD*W2 -2.*S*CM*CPD*Z2
     1  -8.*S*CPD*W2*Z2 -8.*S*CPD*W2**2 +2.*S*CPD*Z2**2 -2.*S*Z2
     1  -4.*S**2*CPD*W2 +2.*CM*CPD*W2*Z2 +4.*CM*CPD*W2**2 -2.*CM*W2
     1  -2.*CM**2*CPD*W2 -8.*CPD*W2**2*Z2 -4.*CPD*W2**3 -2.*W2*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI7P*CPZD*(XW-1./2)
      TLPART= -4.*S*CM*W2 +4.*S*CM*Z2 +8.*S*W2**2 +4.*S**2*W2
     1  -4.*S**2*Z2 -4.*CM*W2**2 +2.*CM**2*W2 +2.*W2*Z2**2 +4.*W2**2*Z2
     1  +4.*W2**3
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI7M
      TLPART= 1.*S*CP +1.*S*Z2 +1.*CP*W2 +1.*W2*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI7M*(XW-1./2)
      TLPART= -2.*S*CP -2.*S*Z2 -2.*CP*W2 -2.*W2*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI7M*(1.-XW)
      TLPART= -2.*S*CP +4.*S*CP*CMD*W2 -2.*S*CP*CMD*Z2
     1  -8.*S*CMD*W2*Z2 -8.*S*CMD*W2**2 +2.*S*CMD*Z2**2 -2.*S*Z2
     1  -4.*S**2*CMD*W2 +2.*CP*CMD*W2*Z2 +4.*CP*CMD*W2**2 -2.*CP*W2
     1  -2.*CP**2*CMD*W2 -8.*CMD*W2**2*Z2 -4.*CMD*W2**3 -2.*W2*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI7M*CMZD*(XW-1./2)
      TLPART= -4.*S*CP*W2 +4.*S*CP*Z2 +8.*S*W2**2 +4.*S**2*W2
     1  -4.*S**2*Z2 -4.*CP*W2**2 +2.*CP**2*W2 +2.*W2*Z2**2 +4.*W2**2*Z2
     1  +4.*W2**3
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI8P
      TLPART= -2.*S*Z2 -2.*W2*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI8M
      TLPART= -2.*S*Z2 -2.*W2*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI9P
      TLPART= 1./2.*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI9P*(XW-1./2)
      TLPART= -2.*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI9P*(XW-1./2)*(1.-XW)
      TLPART= 4.*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI9P*(XW-1./2)**2
      TLPART= 2.*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI9P*(1.-XW)
      TLPART= -2.*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI9P*(1.-XW)**2
      TLPART= 2.*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=-4.*AI9P*CMZD*(XW-1./2)**2
      XTOTAL=XTOTAL+HDPART
      HDPART=4.*AI9P*CSZD*(XW-1./2)**2
      XTOTAL=XTOTAL+HDPART
      HDPART=AI9P*CSZD*CPZD*(XW-1./2)**2
      TLPART= 4.*S -4.*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI9P*CSZD*CMZD*(XW-1./2)**2
      TLPART= 4.*S -4.*CP
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI9M
      TLPART= 1./2.*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI9M*(XW-1./2)
      TLPART= -2.*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI9M*(XW-1./2)*(1.-XW)
      TLPART= 4.*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI9M*(XW-1./2)**2
      TLPART= 2.*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI9M*(1.-XW)
      TLPART= -2.*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI9M*(1.-XW)**2
      TLPART= 2.*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=-4.*AI9M*CPZD*(XW-1./2)**2
      XTOTAL=XTOTAL+HDPART
      HDPART=4.*AI9M*CSZD*(XW-1./2)**2
      XTOTAL=XTOTAL+HDPART
      HDPART=AI9M*CSZD*CPZD*(XW-1./2)**2
      TLPART= 4.*S -4.*CM
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI9M*CSZD*CMZD*(XW-1./2)**2
      TLPART= 4.*S -4.*Z2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI10P
      TLPART= 1./2.*S*ZD2 -1./2.*CP*ZD2 +1./2.*W2*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI10P*(XW-1./2)
      TLPART= -2.*S*ZD2 +2.*CP*ZD2 -2.*W2*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI10P*(XW-1./2)*(1.-XW)
      TLPART= 4.*S*ZD2 -4.*CP*ZD2 +4.*W2*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI10P*(XW-1./2)**2
      TLPART= 2.*S*ZD2 -2.*CP*ZD2 +2.*W2*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI10P*(1.-XW)
      TLPART= -2.*S*ZD2 +2.*CP*ZD2 -2.*W2*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI10P*(1.-XW)**2
      TLPART= 2.*S*ZD2 -2.*CP*ZD2 +2.*W2*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI10P*CMZD*(XW-1./2)
      TLPART= 2.*S -2.*CP
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI10P*CMZD*(XW-1./2)*(1.-XW)
      TLPART= -4.*S +4.*CP
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI10P*CMZD*(XW-1./2)**2
      TLPART= -4.*S +4.*CP -4.*W2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI10M
      TLPART= 1./2.*S*ZD2 -1./2.*CM*ZD2 +1./2.*W2*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI10M*(XW-1./2)
      TLPART= -2.*S*ZD2 +2.*CM*ZD2 -2.*W2*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI10M*(XW-1./2)*(1.-XW)
      TLPART= 4.*S*ZD2 -4.*CM*ZD2 +4.*W2*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI10M*(XW-1./2)**2
      TLPART= 2.*S*ZD2 -2.*CM*ZD2 +2.*W2*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI10M*(1.-XW)
      TLPART= -2.*S*ZD2 +2.*CM*ZD2 -2.*W2*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI10M*(1.-XW)**2
      TLPART= 2.*S*ZD2 -2.*CM*ZD2 +2.*W2*ZD2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI10M*CPZD*(XW-1./2)
      TLPART= 2.*S -2.*CM
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI10M*CPZD*(XW-1./2)*(1.-XW)
      TLPART= -4.*S +4.*CM
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=AI10M*CPZD*(XW-1./2)**2
      TLPART= -4.*S +4.*CM -4.*W2
      XTOTAL=XTOTAL+HDPART*TLPART
      HDPART=4.*AI11P*CPZD*(XW-1./2)
      XTOTAL=XTOTAL+HDPART
      HDPART=4.*AI11P*CMZD*(XW-1./2)
      XTOTAL=XTOTAL+HDPART
      HDPART=4.*AI11M*CPZD*(XW-1./2)
      XTOTAL=XTOTAL+HDPART
      HDPART=4.*AI11M*CMZD*(XW-1./2)
      XTOTAL=XTOTAL+HDPART


C       ***************************
      ELMS=32.*PI*COST2*XTOTAL
C       ***************************

C       The following is the invariant distribution
C       Ez*(dsigma/d3pz) in TeV^-2
C       ***************************
      DISTRINV=ELMS/(4.*PI)**5/S
C       ***************************

C        The following is dsigma/dpt dy in (pb/TeV).
C        The factor 2pi is due to the integral on
C        the Z azimut
C       *******************************************
      DISTRPTY=FCONV*DISTRINV*2.*PI*PT
C       *******************************************

      RETURN
      END
*******************************************************************
C       This is the rapidity distribution
      DOUBLE PRECISION FUNCTION DISTRY(Y)

      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      REAL*4 ecm
      REAL*8 w,z,w2,z2,wd2,zd2,xw,alfwem,cost2,fconv
      REAL*8 s,rs
      COMMON / znnpar / w,z,w2,z2,wd2,zd2,xw,alfwem,cost2,fconv
      COMMON / pars / s,rs
      PARAMETER (PI=3.1415926535897932364,PI2=PI*PI,PI4=PI2*PI2)
      PARAMETER (TWOPI = 2.*PI , PIBY2 = PI/2., PIBY4 = PI/4.)
      PARAMETER (PIBY6 = PI/6. , PIBY8 = PI/8.)
      PARAMETER (PIBY12= PI/12., PIBY3 = PI/3.)
      EXTERNAL FSUB2
      DIMENSION XX(2)
C
C       PTMAX is the max. value of the trans.mom.
C
      PTMAX=SQRT(((S+Z2)/(2*RS*COSH(Y)))**2-Z2)
      PTMIN = 0.
C
      XX(2) = Y
      DISTRY = 2.* DGMLT1(FSUB2,PTMIN,PTMAX,10,6,XX)
C
      RETURN
      END
**************************************************************
C  The following function is used for checking the integral

      DOUBLE PRECISION FUNCTION DISTRYPT (Y,PT)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      EXTERNAL DISTRPTY
C
      DISTRYPT = DISTRPTY (PT,Y)
C
      RETURN
      END
      SUBROUTINE dsigma(s1,qz,qn,qb)
      REAL*4 ecm
      REAL*8 w,z,w2,z2,wd2,zd2,xw,alfwem,cost2,fconv
      REAL*8 s,rs
      COMMON / znnpar / w,z,w2,z2,wd2,zd2,xw,alfwem,cost2,fconv
      COMMON / pars / s,rs
      PARAMETER (PI=3.1415926535897932364,PI2=PI*PI,PI4=PI2*PI2)
      PARAMETER (TWOPI = 2.*PI , PIBY2 = PI/2., PIBY4 = PI/4.)
      PARAMETER (PIBY6 = PI/6. , PIBY8 = PI/8.)
      PARAMETER (PIBY12= PI/12., PIBY3 = PI/3.)
      REAL*8 y, pt, distrpty
      DIMENSION qz(4), qn(4), qb(4)
      PARAMETER(nstep=20)
      COMMON / crocro / ecs(nstep),crs(nstep)
      COMMON / poidsm / wmax,wtot,wtot2,ntry,nacc
C
C
      S=S1/1E6
      RS = SQRT(S)
C
      YMAX=LOG(RS/Z)
  100 Y = YMAX*RNDM(dum1)
C
      PTMAX=SQRT(((S+Z2)/(2*RS*COSH(Y)))**2-Z2)
      PT = PTMAX*RNDM(dum2)
C
      weight = 2.*distrpty(pt,y) * ptmax * ymax
      wnorm = weight*crs(nstep)/sigma(s1)
      CALL hfill(10000,wnorm,0.,1.)
      IF ( wnorm .GT. WMAX ) THEN
C        wmax = wnorm                  ! Avoid this.
        WRITE(6,*)
     &  '+++ Warning +++ Weight = ',wnorm/wmax,' * Wmax'
        WRITE(6,*) '(For ecm,pt,y = ',SQRT(s1),pt,y,')'
      ENDIF
C
      PHI = 2.*PI*RNDM(dum3)
C
      IF ( RNDM(dum4) .GT. .5 ) y = -y
C
      ntry = ntry + 1
      wtot = wtot + weight
      wtot2 = wtot2 + weight**2
CPJ      IF ( weight/wmax .LT. RNDM(weight) ) GOTO 100 ! (Ducon)
      IF ( wnorm/wmax .LT. RNDM(dum5) ) GOTO 100
      nacc = nacc + 1
C      IF ( nacc/1000*1000 .EQ. nacc ) WRITE(6,*) 'Event : ',nacc
C
      ET  = 1000. * SQRT(PT**2+Z2)
      QZ(1) = PT*COS(PHI)*1000.
      QZ(2) = PT*SIN(PHI)*1000.
      QZ(3) = ET * ( EXP(Y) - 1. ) / ( 2. * EXP(Y/2.) )
      QZ(4) = SQRT(ET**2+QZ(3)**2)
C
      RETURN
      END
      SUBROUTINE FSUB1(M,U1,F1,XX)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      DIMENSION U1(M), F1(M), XX(2)
      DO 1 L = 1, M
      XX(1) = U1(L)
    1 F1(L) = DISTRYPT(XX(1),XX(2))
      RETURN
      END
CPJ
      SUBROUTINE FSUB2(M,U1,F1,XX)
      IMPLICIT DOUBLE PRECISION(A-H,O-Z)
      DIMENSION U1(M), F1(M), XX(2)
      DO 1 L = 1, M
      XX(1) = U1(L)
    1 F1(L) = DISTRPTY(XX(1),XX(2))
      RETURN
      END
      SUBROUTINE hhlu1(ipa,kf,px,py,pz,pe)
C------------------------------------------------------------------
C  Add one entry to the LUND event record
C
C  Patrick Janot -- 26 Aug 1991
C------------------------------------------------------------------
      PARAMETER (L1MST=200, L1PAR=200)
      PARAMETER (L2PAR=500, L2PARF=2000 )
      PARAMETER (LJNPAR=4000)
      COMMON /LUDAT1/ MSTU(L1MST),PARU(L1PAR),MSTJ(L1MST),PARJ(L1PAR)
      COMMON /LUDAT2/ KCHG(L2PAR,3),PMAS(L2PAR,4),PARF(L2PARF),VCKM(4,4)
      COMMON /LUDAT3/ MDCY(L2PAR,3),MDME(L2PARF,2),BRAT(L2PARF),
     &                KFDP(L2PARF,5)
      COMMON /LUDAT4/ CHAF(L2PAR)
      CHARACTER*8 CHAF
      COMMON /LUJETS/ N7LU,K7LU(LJNPAR,5),P7LU(LJNPAR,5),V7LU(LJNPAR,5)
C
C
      pm=ulmass(kf)
      DO 100 J=1,5
      k7lu(ipa,j)=0
      p7lu(ipa,j)=0.
  100 v7lu(ipa,j)=0.
C...Store parton/particle in K and P vectors.
      k7lu(ipa,1)=1
      k7lu(ipa,2)=kf
      p7lu(ipa,5)=pm
      p7lu(ipa,4)=SQRT(px**2+py**2+pz**2+pm**2)
      p7lu(ipa,1)=px
      p7lu(ipa,2)=py
      p7lu(ipa,3)=pz
C
  999 RETURN
      END
      SUBROUTINE REMT1(EBEAM,CROSS,STHR,INDEX,sig1)
C-----------------------------------------------------------------------
C THIS PART INITIALIZES THE INITIAL-STATE RADIATOR.
C IT CALCULATES SOME QUANTITIES, AND PERFORMS THE
C NUMERICAL INTEGRATION OVER THE PHOTON SPECTRUM.
C EBEAM=BEAM ENERGY (IN GEV)
C CROSS=NONRADIATIVE CROSS SECTION, TO BE DEFINED
C       WITH ONE VARIABLE: CROSS(S),
C       WHERE S IS THE INVARIANT MASS OF THE E+E- PAIR.
C STHR =THE KINEMATICAL THRESHOLD, I.E. THE LOWEST ALLOWED
C       VALUE OF S FOR WHICH THE NONRADIATIVE PROCESS CAN
C       TAKE PLACE ( IN GEV**2 )
C
C
C 851015 A. SCHWARZ. HAVE TO CALL REMT1 ALWAYS WHEN MASS
C        OF Z0-DECAY PRODUCTS CHANGES, SINCE THRESHOLD CHANGES
C        AS WELL; DIMENSION OF X(1000) CHANGED TO X(1000,10)
C
C-----------------------------------------------------------------------
C     IMPLICIT REAL*8(A-H,O-Z)
      REAL*4 EBEAM,STHR,sig1
      REAL*4 RNDM
      external cross,rndm
      DIMENSION X(1000,10),F(1000),A(1000),Y(1000),Z(1000),XNEW(1000)
      DIMENSION QK(4),QIN(4),QOUT(4),qk1(4),qka(4)
      DATA INIT/0/
C     DIMENSION MINDEX(12)
C     DATA MINDEX/2,1,3,1,4,1,5,6,7,8,9,10/
C
C DEFINITION OF BREMSSTRAHLUNG SPECTRUM
      SPECTR(XK)=FAC*(1.+(1.-XK)**2)/XK*CROSS(S*(1.-XK))
C        Store EBEAM into local variable EBEA for later use
      EBEA = EBEAM
C INITIALIZE A FEW QUANTITIES AND CONSTANTS
      S  = 4.*EBEAM**2
      XPS= (.511D-03/EBEAM)**2/2.
      XPT= (2.+XPS)/XPS
      XPL= ALOG(XPT)
      PI = 4.*ATAN(1.D0)
      TPI= 2.*PI
      ALF= 1./137.036D0
      FAC= ALF/PI*(XPL-1.)
      XKC= EXP( - ( PI/(2.*ALF) + 3./4.*XPL + PI**2/6. - 1. )
     .            /( XPL - 1. )                           )
      IF(INIT.GT.0) GO TO 800
      INIT = 1
      PRINT 1,EBEAM,XKC
    1 FORMAT(
     .  '0INITIALIZATION OF ROUTINE HIGGZ0 (PACKAGE REMT):',/,
     .  '0BEAM ENERGY  : ',F7.3,' GEV',/,
     .  ' MINIMAL BREMSSTRAHLUNG ENERGY : ',E10.4,' * EBEAM')
  800 CONTINUE
C
C PARAMETERS OF NUMERICAL INTEGRATION STEP
      N    = 500
      ITER = 6
      X1   = XKC
      XN   = 1.-STHR/S
      PRINT 2,X1,XN,N,ITER
    2 FORMAT(' PARAMETERS OF SPECTRUM INTEGRATION:',/,
     .       ' LOWEST  K VALUE   : ',E10.3,/,
     .       ' HIGHEST K VALUE   : ',E10.3,/,
     .       ' NO. OF POINTS     : ',I5,/,
     .       ' NO. OF ITERATIONS : ',I3)
C
C INITIALIZE BY CHOOSING EQUIDISTANT X VALUES
      IT=0
      M=N-1
      DX=(XN-X1)/FLOAT(M)
      X(1,INDEX)=X1
      DO 101 I=2,N
  101 X(I,INDEX)=X(I-1,INDEX)+DX
C
C STARTING POINT FOR ITERATIONS
  100 CONTINUE
C
C CALCULATE FUNCTION VALUES
      DO 102 I=1,N
  102 F(I)=SPECTR(X(I,INDEX))
C
C CALCULATE BIN AREAS
      DO 103 I=1,M
  103 A(I)=(X(I+1,INDEX)-X(I,INDEX))*(F(I+1)+F(I))/2.
C
C CALCULATE CUMULATIVE SPECTRUM Y VALUES
      Y(1)=0.D0
      DO 104 I=2,N
  104 Y(I)=Y(I-1)+A(I-1)
C
C PUT EQUIDISTANT POINTS ON Y SCALE
      DZ=Y(N)/FLOAT(M)
      Z(1)=0.D0
      DO 105 I=2,N
  105 Z(I)=Z(I-1)+DZ
C
C DETERMINE SPACING OF Z POINTS IN BETWEEN Y POINTS
C FROM THIS, DETERMINE NEW X VALUES AND FINALLY REPLACE OLD VALUES
      XNEW(1)=X(1,INDEX)
      XNEW(N)=X(N,INDEX)
      K=1
      DO 108 I=2,M
  106 IF( Y(K+1) .GT. Z(I) ) GOTO 107
      K=K+1
      GOTO 106
  107 R= ( Z(I) - Y(K) ) / ( Y(K+1) - Y(K) )
  108 XNEW(I) = X(K,INDEX) + ( X(K+1,INDEX)-X(K,INDEX) )*R
      DO 109 I=1,N
  109 X(I,INDEX)=XNEW(I)
C
C CHECK ON END OF ITERATIONS AND RETURN
      IT=IT+1
      PRINT 3,IT,Y(M)
    3 FORMAT('0ITERATION NO.=',I3,'  INTEGRAL =',E15.6)
      IF(IT.LT.ITER) GOTO 100
C
C PRESENT RESULTS IN FORM OF CORRECTION
      SIG0 = CROSS(S)
      SIG1 = Y(M)
      DELT = (SIG1/SIG0-1.)*100.
C     IF(INIT.GT.1) RETURN
C     INIT = 2
      PRINT 4,SIG0,SIG1,DELT
    4 FORMAT('0RESULTS OF THE INITIALIZATION STEP :',/,
     .       '0NONRADIATIVE CROSS SECTION :',E15.6,/,
     .       '    RADIATIVE CROSS SECTION :',E15.6,/,
     .       '    RADIATIVE CORRECTION    :',F10.3,' %',/,
     .       ' ',127(1H=))
      RETURN
      ENTRY REMT2(QK1,IDEC)
C-----------------------------------------------------------------------
C THIS PART GENERATES A BREMSSTRAHLUNG PHOTON
C AND CALCULATES WHICH BEAM AXIS TO CHOOSE FOR
C THE GENERATION OF THE 'NONRADIATIVE' CROSS SECTION.
C THE PHOTON ENERGY SPECTRUM MUST HAVE BEEN EXAMINED
C BY CALLING ENTRY 'REMT1' BEFORE THE FIRST CALL TO
C THIS ENTRY.
C-----------------------------------------------------------------------
C
C INITIALIZE FLAG FOR REMT3
C     INDX = MINDEX(IDEC)
      INDX = IDEC
      IR=0
C
C GENERATE PHOTON ENERGY FROM CUMULATIVE SPECTRUM BINS
      R=M*RNDM(1.)
      I=INT(R)
      S=R-I
      XK = X(I+1,INDX) + S*( X(I+2,INDX)-X(I+1,INDX) )
C
C GENERATE AZIMUTHAL SCATTERING ANGLE OF THE PHOTON
      FG=TPI*RNDM(1.)
C
C GENERATE COSINE OF POLAR SCATTERING ANGLE OF THE PHOTON
  201 IT=IT+1
      V= XPS * ( XPT**RNDM(2.) - 1. )
      W= XPS + V*(1.-.5*V)
      W= RNDM(3.)/(1.-(XK*XK*W+2.*XPS*(1.-XK)/W)/(1.+(1.-XK)**2))
      IF(W.GT.1.) GOTO 201
      W= -1. + 2.*W
      CG=SIGN(1.-V,W)
C
C CHOOSE WHICH OF THE TWO Z AXES SHOULD BE CONSIDERED
                                                            CH=-1.
      IF(ABS(W).LT.(1./(1.+(1.-2./(1.+XK*CG/(2.-XK)))**2))) CH=+1.
C
C CONSTRUCT PHOTON FOUR-MOMENTUM
      SG=SQRT(V*(2.-V))
      QK1(4)=XK*EBEA
      QK1(1)=QK1(4)*SG*COS(FG)
      QK1(2)=QK1(4)*SG*SIN(FG)
      QK1(3)=QK1(4)*CG
C - Correction for UNIX !!!
      CALL ucopy(qk1(1),qka(1),4)
C
      RETURN
C
      ENTRY REMT3(QIN,QOUT)
C-----------------------------------------------------------------------
C THIS PART PERFORMS THE ROTATIONS AND BOOSTS OF THE I.S.R.
C FORMALISM AFTER THE USER'S BLACK BOX HAS RUN AN EVENT.
C THE INPUT VECTOR (FROM USERS BLACK BOX) IS QIN;
C THE RESULTING VECTOR IN THE LAB FRAME IS QOUT.
C-----------------------------------------------------------------------
C
C INITIALIZATION PART: ONCE FOR EVERY GENERATED PHOTON MOMENTUM
      IF(IR.NE.0) GOTO 301
      IR=1
      CALL ucopy(qka(1),qk(1),4)
C
C CALCULATE ROTATTION PARAMETERS FOR BEAM DIRECTION IN C.M.S.
      XKP = SQRT( QK(1)**2 + QK(2)**2 )
      XKM = 2.* SQRT( EBEA*(EBEA-QK(4)) )
      XKD = 2.*EBEA - QK(4) + XKM
      XKA = ( CH + QK(3)/XKD )/XKM
      XKB = SQRT( (1.+XKA*QK(3))**2 + (XKA*XKP)**2 )
      S1  = XKA*XKP/XKB
      C1  = (1.+XKA*QK(3))/XKB
      S2  = QK(1)/XKP
      C2  = QK(2)/XKP
      YK=QK(4)**2-QK(1)**2-QK(2)**2-QK(3)**2
      Y1=C1**2+S1**2-1.
      Y2=C2**2+S2**2-1.
C
C ROTATE INPUT VECTOR QIN(I) TO CORRESPOND WITH CHOZEN Z-AXIS
  301 QQ =  C1*QIN(2) + S1*QIN(3)
      QZ = -S1*QIN(2) + C1*QIN(3)
      QX =  C2*QIN(1) + S2*QQ
      QY = -S2*QIN(1) + C2*QQ
C
C BOOST ROTATED VECTOR TO LAB FRAME VECTOR QOUT
      QOUT(4)=((XKD-XKM)*QIN(4)-QK(1)*QX-QK(2)*QY-QK(3)*QZ)/XKM
      QQ     =(QIN(4)+QOUT(4))/XKD
      QOUT(1)= QX - QK(1)*QQ
      QOUT(2)= QY - QK(2)*QQ
      QOUT(3)= QZ - QK(3)*QQ
C
      RETURN
      END
      FUNCTION sigma(s)
      PARAMETER(nstep=20)
      COMMON / crocro / ecs(nstep),crs(nstep)
      COMMON / poidsm / wmax,wtot,wtot2,ntry,nacc
C
      ecm = SQRT(s)
      DO istep = 1, nstep
        IF ( ecm .LE. ecs(istep) ) GOTO 2
      ENDDO
    2 a = (crs(istep)-crs(istep-1))/(ecs(istep)-ecs(istep-1))
      b = crs(istep) - a*ecs(istep)
      sigma = a * ecm + b
      RETURN
      END
      SUBROUTINE USCJOB
C-----------------------------------------------------------------------
C
C   Routine for printout at the end of a run
C
C-----------------------------------------------------------------------
C
      COMMON / miscl / tabl(20),ecm,sigt,
     &                 loutbe,idb1,idb2,nevent(11)
      COMMON / VERTX / IFVRT,XVRT(3),SXVRT(3),sdvrt(3),vrtx(4)
      INTEGER loutbe,idb1,idb2,nevent,IFVRT
      REAL*4 sdvrt,vrtx,tabl,XVRT,SXVRT
      PARAMETER(nstep=20)
      COMMON / crocro / ecs(nstep),crs(nstep)
      COMMON / poidsm / wmax,wtot,wtot2,ntry,nacc
C
C
C Print event counters
C
       WRITE(LOUTBE,101)
  101  FORMAT(//20X,'EVENTS STATISTICS',
     &         /20X,'*****************')
       WRITE(LOUTBE,102) NEVENT(1),NEVENT(2),NEVENT(3)
  102  FORMAT(/5X,'# OF GENERATED EVENTS                      = ',I10,
     &        /5X,'# OF ACCEPTED  EVENTS                      = ',I10,
     &        /5X,'# OF REJECTED  EVENTS (ISTA # 0 in ASKUSE) = ',I10)
       WRITE(LOUTBE,103)
  103  FORMAT(//20X,'ERRORS STATISTICS',
     &         /20X,'*****************')
       WRITE(LOUTBE,104) (NEVENT(I),I=4,11)
  104  FORMAT(/10X,'IR= 1 LUND ERROR unknown part   # OF REJECT = ',I10,
     &        /10X,'IR= 2 KINE/VERT banks missing   # OF REJECT = ',I10,
     &        /10X,'IR= 3 no space for VERT/KINE    # OF REJECT = ',I10,
     &        /10X,'IR= 4 LUND ERROR too many tracks# OF REJECT = ',I10,
     &        /10X,'IR= 5 LUND ERROR Beam wrong pos # OF REJECT = ',I10,
     &        /10X,'IR= 6 LUND ERROR Status code >5 # OF REJECT = ',I10,
     &        /10X,'IR= 7 free for user             # OF REJECT = ',I10,
     &        /10X,'IR= 8 free for user             # OF REJECT = ',I10)
C
      call ugtsec
      sigto = wtot/FLOAT(ntry)
      dsig  = SQRT((wtot2/FLOAT(ntry) - sigto**2)/FLOAT(ntry))
      WRITE(6,*) '-----------------------------------'
      WRITE(6,*) ' Generated cross section : '
      WRITE(6,*) ' Sigma = ',sigto,' +/- ',dsig,' pb'
      WRITE(6,*) ' this is only a cross check of the '
      WRITE(6,*) ' initial value, USE cross section  '
      WRITE(6,*) ' value from initialization step    '
      WRITE(6,*) ' Sigma = ',sigt
      WRITE(6,*) '-----------------------------------'
C   print out event content summary
      CALL LUTABU(12)
      CALL LUTABU(22)
      RETURN
      END
      SUBROUTINE UGTSEC
C -------------------------------------------------------------
C     B.Bloch vreate x-section bank December 2000
C -------------------------------------------------------------
      PARAMETER(igcod=5040)
      PARAMETER ( IVER = 100  )
C
      COMMON / miscl / tabl(20),ecm,sigt,
     &                 loutbe,idb1,idb2,nevent(11)
      COMMON / VERTX / IFVRT,XVRT(3),SXVRT(3),sdvrt(3),vrtx(4)
      INTEGER loutbe,idb1,idb2,nevent,IFVRT
      REAL*4 sdvrt,vrtx,tabl,XVRT,SXVRT
      PARAMETER(nstep=20)
      COMMON / crocro / ecs(nstep),crs(nstep)
      COMMON / poidsm / wmax,wtot,wtot2,ntry,nacc
C
C Print cross-section (MC and Semi-analytical calculations)
C ans store it in KSEC bank
      NTOT = NEVENT(1)
      XTOT = wtot/FLOAT(ntry)
      RTOT = SQRT((wtot2/FLOAT(ntry) - xtot**2)/FLOAT(ntry))
      XTOT = sigt
      XTOT = XTOT /1000.
      RTOT = RTOT/1000.
      IS = 1
      IDC = IGCOD
      IVERS = IVER
      NACC = NTOT
      XACC = XTOT
      RACC = RTOT
      isec = KSECBK(IS,IDC,IVERS,NTOT,NACC,XTOT,RTOT,XACC,RACC)
      CALL PRTABL('KSEC',0)
      RETURN
      END
      SUBROUTINE znnbge(ecms,qg,qz,qn,qb)
C-----------------------------------------------------------------------
C
C   Compute Higgs production cross sections with initial state
C   radiation and beamstrahlung effects.
C   Event generation
C
C   Patrick Janot -- 27 Aug 1991
C----------------------------------------------------------------------
      DIMENSION qg(4),qz(4),qn(4),qb(4)
      DIMENSION rz(4),rn(4),rb(4)
      LOGICAL first
      DATA first/.TRUE./
      PARAMETER (L1MST=200, L1PAR=200)
      PARAMETER (L2PAR=500, L2PARF=2000 )
      PARAMETER (LJNPAR=4000)
      COMMON /LUDAT1/ MSTU(L1MST),PARU(L1PAR),MSTJ(L1MST),PARJ(L1PAR)
      COMMON /LUDAT2/ KCHG(L2PAR,3),PMAS(L2PAR,4),PARF(L2PARF),VCKM(4,4)
      COMMON /LUDAT3/ MDCY(L2PAR,3),MDME(L2PARF,2),BRAT(L2PARF),
     &                KFDP(L2PARF,5)
      COMMON /LUDAT4/ CHAF(L2PAR)
      CHARACTER*8 CHAF
      COMMON /LUJETS/ N7LU,K7LU(LJNPAR,5),P7LU(LJNPAR,5),V7LU(LJNPAR,5)
C
C
      COMMON / miscl / tabl(20),ecm,sigt,
     &                 loutbe,idb1,idb2,nevent(11)
      COMMON / VERTX / IFVRT,XVRT(3),SXVRT(3),sdvrt(3),vrtx(4)
      INTEGER loutbe,idb1,idb2,nevent,IFVRT
      REAL*4 sdvrt,vrtx,tabl,XVRT,SXVRT
      EXTERNAL sigma
C
      s = ecms**2
      e = ecms/2.
      CALL vzero(qg(1),4)
      CALL vzero(qz(1),4)
      CALL vzero(qn(1),4)
      CALL vzero(qb(1),4)
      CALL vzero(rz(1),4)
      CALL vzero(rn(1),4)
      CALL vzero(rb(1),4)
C
C  First compute the total cross section with Brems- or beams-strahlung
C  (if requested)
C
      IF ( first ) THEN
C
        sthr = (pmas(23,1)+2.)**2
        CALL remt1(e,sigma,sthr,1,cross)
        first = .FALSE.
        sigt = cross
      ENDIF
C
C  Event generation
C
      CALL remt2(qg,1)
      s1 = s * (1.-qg(4)/e)
      CALL dsigma(s1,rz,rn,rb)
C
      CALL remt3(rz,qz)
C      CALL remt3(rn,qn)
C      CALL remt3(rb,qb)
C
C  End of event generation
      RETURN
      END
      SUBROUTINE znnbin(ecm)
      REAL*4 ecm
      REAL*8 w,z,w2,z2,wd2,zd2,xw,alfwem,cost2,fconv
      REAL*8 s,rs
      COMMON / znnpar / w,z,w2,z2,wd2,zd2,xw,alfwem,cost2,fconv
      COMMON / pars / s,rs
      PARAMETER (PI=3.1415926535897932364,PI2=PI*PI,PI4=PI2*PI2)
      PARAMETER (TWOPI = 2.*PI , PIBY2 = PI/2., PIBY4 = PI/4.)
      PARAMETER (PIBY6 = PI/6. , PIBY8 = PI/8.)
      PARAMETER (PIBY12= PI/12., PIBY3 = PI/3.)
      REAL*8 y, pt, distrpty
      PARAMETER(nstep=20)
      COMMON / crocro / ecs(nstep),crs(nstep)
      COMMON / poidsm / wmax,wtot,wtot2,ntry,nacc
C
C      EXTERNAL wy
C
      crs(nstep) = znnbsi(ecm)
      ecs(nstep) = ecm
      WRITE(6,*) 'The born-level cross section is : ',crs(nstep),' pb'
C
      emin = 93.
      emax = ecm
      DO istep = 1, nstep-1
        ecs(istep) = emin + FLOAT(istep-1)/FLOAT(nstep-1)*(emax-emin)
        crs(istep) = znnbsi(ecs(istep))
C        WRITE(6,*) 'ECM, Cross section : ',ecs(istep),crs(istep)
      ENDDO
C
      rs = ecm/1000.
      s =rs**2
C
      wmax = 0.
      ymax=LOG(rs/z)
      ny = 100
      npt = 100
      DO iy = 1, ny
        y = ymax*FLOAT(iy)/FLOAT(ny)
        ptmax =  ( (s+z2)/(2*rs*COSH(y)) )**2-z2
C
       IF ( ptmax .GT. 0. ) THEN
          ptmax = SQRT( ptmax )
        ELSE
          ptmax = 0.
        ENDIF
C
        DO ipt = 1, npt
          pt = ptmax*FLOAT(ipt)/FLOAT(npt)
          wpt = 2. * distrpty(pt,y) * ymax * ptmax
          IF ( wpt .GT. wmax ) wmax = wpt
        ENDDO
      ENDDO
      wmax = wmax * 1.001
      WRITE(6,*) ' Poids maximum : ',wmax
      WRITE(6,*) ' For y and pt = ',y,pt
C
      wtot = 0.
      wtot2 = 0.
      ntry = 0
      nacc = 0
C
      RETURN
      END
      FUNCTION ZNNBSI(ecm)
********************************************************************
C Computes the total cross-section for the process
C e+e- --> Z nu nubar (neglecting Z-exchange diagrams and keeping
C all the W-exchange ones). Output in the file FOR080.DAT
********************************************************************
C   by S.Ambrosanio and B.Mele (1991)
********************************************************************
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      REAL*4 znnbsi
      REAL*4 ecm
      REAL*8 w,z,w2,z2,wd2,zd2,xw,alfwem,cost2,fconv
      REAL*8 s,rs
      COMMON / znnpar / w,z,w2,z2,wd2,zd2,xw,alfwem,cost2,fconv
      COMMON / pars / s,rs
      PARAMETER (PI=3.1415926535897932364,PI2=PI*PI,PI4=PI2*PI2)
      PARAMETER (TWOPI = 2.*PI , PIBY2 = PI/2., PIBY4 = PI/4.)
      PARAMETER (PIBY6 = PI/6. , PIBY8 = PI/8.)
      PARAMETER (PIBY12= PI/12., PIBY3 = PI/3.)
      EXTERNAL DISTRPT,DISTRY
C
      RS = ecm/1000.
      S=RS**2
C
C       limits on ABS(rapidity) and transverse momentum of the Z boson:
C
      YMXABS=LOG(RS/Z)
      PTMXABS=(S-Z2)/2./RS
C
C       Here one computes the total cross-section integrating
C       dsigma/dpt dy with two different orders of the integration
C       variables (as a check of the integral)
C
      SIGTOTPT=DGAUSS(DISTRPT,0.D0,PTMXABS,1.D-1)
      SIGTOTY =DGAUSS(DISTRY,0.D0,YMXABS,1.D-1)
      DIFF=(SIGTOTPT-SIGTOTY)/SIGTOTY
      znnbsi = (sigtotpt+sigtoty)/2.
      RETURN
      END
