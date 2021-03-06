

      SUBROUTINE TSCNST
C--------------------------------------------------------------------
C! Define constants used in TPC digitization
C  Called from:  TSINIT
C  M. Mermikides  (derived from former block data)
C  Modifications :
C    1. D. Cowen   17 May 1988  --Change DEMIN from .0025 to .0135
C                                 to avoid pad saturation
C    2. P. Janot   18 May 1988  --Change EBINC and CONCLU values
C                                 and add the parameter POWERC to
C                                 reproduce the TPC 90 data.
C    3. D. Cowen   7 July 1988  --Re-do POIFAC and GAMVAL using
C                                 values from Baruzzi CERN/EF
C                                 82-12.  Make MXGAMV=8 to
C                                 improve smoothness of dE/dx
C                                 curve.
C    4. D. Casper  6 OCT 1992     make polya shape changable
C--------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON /BCS/   IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
C
C  TPCONS contains physical constants for TPC simulation
C
      COMMON /DELTA/ CDELTA,DEMIN,DEMAX,DELCLU,RADFAC,CYLFAC
      PARAMETER (MXGAMV = 8)
      COMMON /TGAMM/ GAMVAL(MXGAMV),GAMLOG(MXGAMV),POIFAC(MXGAMV),
     &               POIMAX,POIMIN,CFERMI,CA,CB,POIRAT,POICON
      PARAMETER (MXBINC = 20)
      COMMON /CLUST/ EBINC(MXBINC),CONCLU,WRKFUN,MXCL,CKNMIN,CFANO,CRUTH
     &              ,POWERC
      COMMON /AVALA/ THETA,ETHETA
      COMMON /TPTIME/ NTMXSH,NTMXNO,NTMXAN,NTMXDI,NTSCAN,NTBNAS,NTBAPD
      COMMON /TPELEC/ TPRPAR,TPRSER,TPCFET,TCFEED,TMVPEL,TSIGMX,NTPBIT
C
C
C  TPCOND  conditions under which this simulation
C  will be performed
C
      COMMON /DEBUGS/ NTPCDD,NCALDD,NTPCDT,NCALDT,NTPCDA,NCALDA,
     &                NTPCDC,NCALDC,NTPCDS,NCALDS,NTPCDE,NCALDE,
     &                NTPCDI,NCALDI,NTPCSA,NCALSA,NTPCDR,NCALDR,
     &                LTDEBU
      LOGICAL LTDEBU
      COMMON /SIMLEV/ ILEVEL
      CHARACTER*4 ILEVEL
      COMMON /GENRUN/ NUMRUN,MXEVNT,NFEVNT,INSEED(3),LEVPRO
      COMMON /RFILES/ TRKFIL,DIGFIL,HISFIL
      CHARACTER*64 TRKFIL,DIGFIL,HISFIL
      COMMON /TLFLAG/ LTWDIG,LTPDIG,LTTDIG,LWREDC,FTPC90,LPRGEO,
     &                LHISST,LTPCSA,LRDN32,REPIO,WEPIO,LDROP,LWRITE
      COMMON /TRANSP/ MXTRAN,CFIELD,BCFGEV,BCFMEV,
     &                        DRFVEL,SIGMA,SIGTR,ITRCON
      COMMON /TPCLOK/ TPANBN,TPDGBN,NLSHAP,NSHPOF
      COMMON /AVLNCH/ NPOLYA,AMPLIT
      COMMON /COUPCN/ CUTOFF,NCPAD,EFFCP,SIGW,SIGH,HAXCUT
      COMMON /TGCPCN/ TREFCP,SIGR,SIGARC,RAXCUT,TCSCUT
      COMMON /DEFAUL/ PEDDEF,SPEDEF,SGADEF,SDIDEF,WPSCAL,NWSMAX,THRZTW,
     &                LTHRSH,NPRESP,NPOSTS,MINLEN,
     &                LTHRS2,NPRES2,NPOST2,MINLE2
      COMMON /SHAOPT/ WIRNRM,PADNRM,TRGNRM
C
      LOGICAL LTWDIG,LTPDIG,LTTDIG,LPRGEO,
     &        LWREDC,LTPCSA,LHISST,FTPC90,LRND32,
     &        REPIO,WEPIO,LDROP,LWRITE
C
      LOGICAL LTDIGT(3)
      EQUIVALENCE (LTWDIG,LTDIGT(1))
C
      REAL FACNRM(3)
      EQUIVALENCE (WIRNRM,FACNRM(1))
C
      PARAMETER (MAXTAB = 50000)
      COMMON /POLTAB/ZZUSE(MAXTAB),NTAB
      COMMON /WRKSPC/  ZZTMP(10000),ZZI(10000)
C
      DIMENSION EBIN(20)
C
      DATA EBIN/.802,.879,.899,.912,.920,.926,.931,.937,.945,.954,.961,
     *          .966,.970,.973,.9758,.978,.980,.9817,.9832,.9845/
C
      CALL UCOPY(EBIN,EBINC,20)
      CONCLU = 0.370
      POWERC = 2.0
      WRKFUN = 26.4E-6
      MXCL = 100
      CKNMIN = 1.6E-5
      CFANO = 0.18
      CRUTH = 1.23E-4
C  Values of gamma chosen to give integer beta-gammas
      GAMVAL(1) = 3.64
      GAMVAL(2) = 8.062
      GAMVAL(3) = 20.025
      GAMVAL(4) = 70.01
      GAMVAL(5) = 200.
      GAMVAL(6) = 500.
      GAMVAL(7) = 2000.
      GAMVAL(8) = 5000.
      DO 1 I = 1, MXGAMV
         GAMLOG(I) = ALOG10(GAMVAL(I))
    1 CONTINUE
C  Values from Baruzzi
      POIFAC(1) = 1.00
      POIFAC(2) = 1.065
      POIFAC(3) = 1.199
      POIFAC(4) = 1.378
      POIFAC(5) = 1.515
      POIFAC(6) = 1.583
      POIFAC(7) = 1.643
      POIFAC(8) = 1.643
C
      POIMAX = 100.
      POIMIN = 26.6
      POICON = 26.6
      CFERMI = 1.643
      CA = 5.26772E 3
      CB = 2.18858E-1
      POIRAT = 11.0904
      THETA = 0.4
      ETHETA = 1.4918
C Lookup table for electron avalanche
      NTAB = 0
      ZZTOT = 0.
      DO IX = 1, 10000
          XX = (FLOAT(IX)-0.5)/10000.
          ZZI(IX) = -ALOG(XX)
          ZZCHI = ETHETA * (ZZI(IX)**THETA)
     1                        * EXP(-THETA*ZZI(IX))
          ZZTMP(IX) = ZZCHI
          ZZTOT = ZZTOT + ZZCHI
      ENDDO
      SCALE = ZZTOT/MAXTAB
      DO IX = 1, 10000
          NADD = ZZTMP(IX)/SCALE
          IF(NADD.GT.0)THEN
             IF(NTAB + NADD .LE. MAXTAB)THEN
                DO J = NTAB+1, NTAB + NADD
                    ZZUSE(J) = ZZI(IX) * AMPLIT
                ENDDO
                NTAB = NTAB + NADD
             ELSE
                WRITE(6,10)IX
                CALL ALTELL ('TSCNST: not enough space in /POLTAB/',0,
     &                       'STOP')
             ENDIF
          ENDIF
      ENDDO
C
C Delta-ray treatment
C
      CDELTA = 1.E-7
      DEMIN = 0.0135
      DEMAX = 1.0
      DELCLU = 0.01
      RADFAC = 1.5
      CYLFAC = 1.5
C
C  TPRSER and TPCFET have been chosen arbitrarily to make the noise
C  spectrum fit the experimental values.  TPCFET is
C  much larger than would otherwise be expected. (i.e., 10E-12)
C
      TPRPAR = 2.0E6
      TPRSER = 107.
      TPCFET = 37.5E-12
      TCFEED = 1.0E-12
      TMVPEL = 1.64E-3
      TSIGMX = 2000.
      NTPBIT = 8
C
C  Number of time bins for various signal types.  Note that NTSCAN, the
C  number of divisions of the analog signal collection time, and NTBNAS,
C  the number of time bins in each division, must multiply together to
C  equal NTMXAN, the number of time bins in the full analog signal.
C
      NTMXSH = 160
      NTMXNO = 2400
      NTMXAN = 1024
      NTMXDI = 512
      NTSCAN = 4
      NTBNAS = 256
      NTBAPD = 2
C
 10   FORMAT(1X,'TSCNST: No space in ZZ array.Terminating at IX=',I8)
      END
