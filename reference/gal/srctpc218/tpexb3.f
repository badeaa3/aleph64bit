      SUBROUTINE TPEXB3(XEX,WSTEP,XX1,XX3,TT1,TT3)
C
C! Fast sim : Routine to determine ExB shift of the two points
C  parameterizing a super-broken segment. This routine is
C  used in most cases, except for the first and last segment
C  of a given track element.
C
C
C  Called from:   T2TRAN
C  Calls:         none
C
C
C=======================================================================
C  The results are valid only in the following assumptions:
C
C  Drift Field 110 V/cm
C  Gas Mix     9% CH4 91% Argon
C  SW voltage of about 1300 V
C
C  Grids geometry as in Aleph TPC proposal i.e.
C  sw pitch 0.4 cm, 0grid pitch 0.1 cm, gating grid pitch 0.2 cm.
C  distances of the three grids from the pad plane 0.4,0.8,1.3 cm.
C
C  Magnetic field and gating grid voltages according to ITYP
C
C=======================================================================
C
C  Input:    PASSED    :  --LDEB, transport debug level
C                         --WSTEP, ditance between two wires in cm
C            FASTER    :  --XPROP,  proportion of collected electrons
C                         --XXXX,   shift along the wire in cm as
C                                   a function of the segment inclina-
C                                   tion with respect to the wire
C                         --TTTT,   delay due to the ExB effect
C                         --XEX, segment extremities coordinates
C            TPCOND.INC   --CFIELD, magnetic field value
C
C
C  Outputs:  PASSED    :  --XXX1,XXX3, positions of the two points
C                                      along the wire
C                         --TTT1,TTT3, time of the two points
C=====================================================================
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
      COMMON /AVLNCH/ NPOLYA,AMPLIT,GRANNO(1000)
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
C
C  FASTER : variables used in fast simulation
C
      COMMON / LANDAU / NITLAN,NITIND,INTWRD
      COMMON / EXBEFF / XPROP,TTTT,XXXX(1001),XSHFT(50)
      COMMON / EVT / IEVNT,ISECT
      COMMON / T3TR / JSEGT,NSEGT,ITYPE,WIRRAD(4),WIRPHI(4)
     &               ,AVTIM(4),NELE(4),NCL,SIGT(4)
      COMMON / TPSG / CC(3),XX(3),TOTDIS,XLEN,ISTY,IE
      COMMON / XBIN / IBIN(4),NAVBIN(4),NB
      DIMENSION XEX(4,4)
      PARAMETER (SQ2=1.4142136,SQ3=1.7320508)
      DATA ICALL/0/,BNOM/15./,ASL,BSL/.01,-5.01/
      IF(ICALL.EQ.0) THEN
C
C YQM = Y position of the 2 points with respect to the wire
C X5  = ExB shift of this point for a slope 5 segment in XY plan
C       (useful for slope > 5 segment)
C
       YQM   = WSTEP/2./SQ3
       X5    = ( XXXX(1001) - 5.*YQM ) *CFIELD/BNOM
       ICALL = 1
      ENDIF
C
C  Determine super broken segment slope in XY plan
C    1st half :
C
      Y12    =   XEX(2,2)-XEX(1,2)
      SL1    = ( XEX(2,1)-XEX(1,1) ) / Y12
      ISL1   = ( SL1 - BSL ) / ASL
C
C    2nd half :
C
      Y32    =   XEX(3,2)-XEX(2,2)
      SL3    = ( XEX(3,1)-XEX(2,1) ) / Y32
      ISL3   = ( SL3 - BSL ) / ASL
C
C  Then compute the corresponding mean shifts
C      1st point :
C
      IF (ABS(SL1) .LE. 5.) THEN
C       Slope less than 5.
        XGAP = (XXXX(ISL1) - YQM*SL1) * CFIELD/BNOM + YQM*SL1
        XX1  =  -    XGAP        * SIGN(1.,Y12) + XEX(2,1)
      ELSE
C       Slope larger than 5.
        XX1  =  - (SL1*YQM + X5) * SIGN(1.,Y12) + XEX(2,1)
      ENDIF
C
C      2nd point :
C
      IF (ABS(SL3) .LE. 5.) THEN
C       Slope less than 5.
        XGAP = (XXXX(ISL3) - YQM*SL3) * CFIELD/BNOM + YQM*SL3
        XX3  =       XGAP        * SIGN(1.,Y32) + XEX(2,1)
      ELSE
C       Slope larger than 5.
        XX3  =    (SL3*YQM + X5) * SIGN(1.,Y32) + XEX(2,1)
      ENDIF
C
C  Shift delay
C
      TT1    = TTTT
      TT3    = TTTT
C
C  Charge renormalization according to the grid configuration
C
      XEX(4,1) = XEX(4,1)*XPROP
      XEX(4,2) = XEX(4,2)*XPROP
      RETURN
      END
