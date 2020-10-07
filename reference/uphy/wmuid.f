C*******************************************************************
      SUBROUTINE WMUID(ITK,CUT1,CUT2,MUFL1,MUFL2,HMAP,JN,
     &                    PJCAL,PCALE,IER)
C*******************************************************************
C
C   MUON SELECTION WITH HCAL WIRE ENERGY
C   Stefania Salomone 30/7/1993
C------------------------------------------------------------------------
C
C   INPUT:
C
C   ITK         Charged track number
C   CUT1        Cut for the single plane HCAL wire energy
C   CUT2        Cut for the total HCAL wire energy
C
C   OUTPUT:
C
C   MUFL1             Muon identifier
C               0     no
C               1     yes
C
C   MUFL2             Muon identifier
C               0     no
C               1     yes
C
C   HMAP              Bit pattern of the HCAL wire energies over CUT1
C   JN                Number of crossed planes
C   PJCAL(12)/R       Single crossed plane energies
C                     (only the first JN are filled)
C   PCALE/R           Total HCAL wire energy
C   IER               Error code
C
C-----------------------------------------------------------------------
C   The identification requires:
C
C   MUFL1 : An energy deposition in each crossed HCAL plane < CUT1
C           A total energy plane deposition < CUT2
C
C   MUFL2 : An energy deposition in the 7th-12th HCAL planes < CUT1
C-----------------------------------------------------------------------
C   IMPORTANT: it is necessary to link
C              the JULIA library
C-----------------------------------------------------------------------
C--------------------Official cuts--------------------------------------
C       CUT1 / 2.4 /
C       CUT2 / 10. /
C-----------------------------------------------------------------------

      IMPLICIT NONE
      INCLUDE '/aleph/phy/qdecl.inc'
      INCLUDE '/aleph/phy/qcde.inc'
C------------------------------------------------------------------------
      REAL EVECB(12),EVECE(12)
      INTEGER NEXB(12),NEXE(12)
      REAL PJCAL(12)
      REAL PCALE
      REAL CUT1
      REAL CUT2
      INTEGER HMAP
      INTEGER MUFL1
      INTEGER MUFL2
      INTEGER JN,ITK,I,K,KK,LL,LO,IK,IU,IER
C--------------------------------------------------------------------------
      INCLUDE '/aleph/phy/qmacro.inc'
C--------------------------------------------------------------------------
      HMAP=0
      IER=0

C-----------------------------------------------------------------------
      CALL HPLAND

C-----------------------------------------------------------------------

      CALL HCALWIRE(ITK,EVECB,EVECE,NEXB,NEXE,IER)

C----------------singol planes energy-----------------------------------

      JN=0
      CALL VZERO(PJCAL,12)

      DO KK=1,12
        IF (NEXB(KK).EQ.1) THEN
          JN=JN+1
          PJCAL(JN)=EVECB(KK)
        END IF
      END DO
      DO LL=1,12
        IF (NEXE(LL).EQ.1) THEN
          JN=JN+1
          PJCAL(JN)=EVECE(LL)
        END IF
      END DO

C-----------total energy in the wires of HCAL--------------------------

      PCALE=0
      IF(JN.NE.0) THEN
        DO LO=1,JN
          PCALE=PCALE+PJCAL(LO)
        END DO
      END IF

C------------HCAL identification---------------------------------------


      MUFL1=1
      MUFL2=1
      IF(JN.NE.0) THEN

        DO IK=1,JN
          IF (PJCAL(IK).GE.CUT1) THEN
            MUFL1=0
            HMAP=IBSET(HMAP,IK-1)
          ENDIF
        END DO

        DO IU=7,12
          IF (PJCAL(IU).GE.CUT1) THEN
            MUFL2=0
          ENDIF
        END DO

      END IF

      IF (PCALE.GE.CUT2) THEN
        MUFL1=0
      END IF

C-------------------------------------------------------------------------

  999 RETURN
      END

C----------------------------------------------------------------------

*=============================================================================
C######################################################################

*=============================================================================
C!==============================================================
      SUBROUTINE HCALWIRE(ITRA,EVECB,EVECE,NEXB,NEXE,IER)
C!==============================================================
C
C---------------------------------------------------------------
C
C     HCAL wire energy for a given alpha charged track
C
C---------------------------------------------------------------
C
C-------------------------------------------------------------------*
C    Inputs:                                                        *
C             ITRA  = Charged track                                 *
C    Ouputs:                                                        *
C             EVECB = Real vector 12 elements. Energy in each       *
C                     barrel plane for that track                   *
C             NEXB  = Integer vector 12 elements. If element        *
C                     equal to 1 than that plane is geometrically   *
C                     allowed to fire (barrel).                     *
C             EVECE = Real vector 12 elements. Energy in each       *
C                     endcap plane for that track                   *
C             NEXE  = Integer vector 12 elements. If element        *
C                     equal to 1 than that plane is geometrically   *
C                     allowed to fire (endcaps).                    *
C             IER   = Error flag                                    *
C
C********************************************************************
C     Stefania Salomone     30/7/1993
C
C     Input banks: TREX
C--------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE '/aleph/phy/qdecl.inc'
      INCLUDE '/aleph/phy/qcde.inc'

      REAL EPLANE(24,12),EPLAEA(6,12),EPLAEB(6,12)
      COMMON/HDPLA/EPLANE,EPLAEA,EPLAEB
      INTEGER    NPLANB(24,12),NPLANE(6,12)
      REAL    EVECB(12),EVECE(12)
      INTEGER NEXB(12),NEXE(12)

      REAL ZSIGN
      INTEGER IENDCAP

      INTEGER ITRA,IER,ITR,JTREX,NTREX,IREGION,ILAYER,JZONE,IMODUL,
     &        IPLAN,I,J,NLINK,K

      INTEGER JIMODUL(2)
      INCLUDE '/aleph/phy/qmacro.inc'

C----------initialization---------------------------------------------

      CALL VZERO(NPLANB,288)
      CALL VZERO(NPLANE,72)
      CALL VZERO(EVECB,12)
      CALL VZERO(EVECE,12)
      CALL VZERO(NEXB,12)
      CALL VZERO(NEXE,12)
      CALL VZERO(JIMODUL,2)
      IENDCAP=0

C--------read the bank TREX for that charged track---------------------

      ITR=ITRA-50

C!------Create the TREX bank-------------------------------------------

        CALL FTRACK
        CALL HMFIND

C!---------------------------------------------------------------------
        JTREX=NLINK('TREX',ITR)
        IF(JTREX.EQ.0) THEN
          IER=1
          WRITE(6,*) 'BANCA TREX MANCANTE KRUN=',KRUN,' KEVT=',KEVT
          RETURN
        END IF
C!---------------------------------------------------------------------
C!---------------------------------------------------------------------
      NTREX=LROWS(JTREX)

C-------loop over the extrapolated points along the track------------

      DO J=1,NTREX

C-------If one track point has a negative z coordinate-----------------
C       the endcap of interest is the endcap B

        ZSIGN=RTABL(JTREX,J,3)
        IF(ZSIGN.LT.0.0) THEN
          IENDCAP=2
        END IF

C---------------------------------------------------------------------
        IREGION=ITABL(JTREX,J,8)
        IF(IREGION.LT.0) THEN
          WRITE(*,*) 'IREGION LESS THAN 0'
          WRITE(*,*) 'KEVT=',KEVT
        END IF
        ILAYER=ITABL(JTREX,J,9)

        JZONE=IREGION/100
        IMODUL=MOD(IREGION,100)
        IF(IMODUL.GT.12) THEN
          WRITE(*,*) 'IMODUL GREATER THAN 12'
          WRITE(*,*) 'KEVT=',KEVT
        END IF
        IF (BTEST(ILAYER,0)) THEN
          IPLAN=(ILAYER+1)/2
        ELSE
          IPLAN=(ILAYER+2)/2
        END IF


C-----------barrel (notch=32) ---------------------------------

        IF (JZONE.EQ.31.OR.JZONE.EQ.32) THEN

          JIMODUL(1)=IMODUL*2-2
          IF(JIMODUL(1).EQ.0) THEN
            JIMODUL(1)=24
          END IF
          JIMODUL(2)=IMODUL*2-1

          DO K=1,2

            IF (JIMODUL(K).GE.1.AND.JIMODUL(K).LE.24.AND.IPLAN.GE.1.
     &        AND.IPLAN.LE.12) THEN
              NPLANB(JIMODUL(K),IPLAN)=1
              NEXB(IPLAN)=1
            END IF

          END DO

C-----------endcaps-----------------------------------------------

        ELSEIF (JZONE.EQ.33.OR.JZONE.EQ.34) THEN

          IF (BTEST(IMODUL,0)) THEN

            JIMODUL(1)=(IMODUL+1)/2-1
            IF(JIMODUL(1).EQ.0) THEN
              JIMODUL(1)=6
            END IF
            JIMODUL(2)=(IMODUL+1)/2

            DO K=1,2

              IF (JIMODUL(K).GE.1.AND.JIMODUL(K).LE.6.AND.IPLAN.GE.1.
     &          AND.IPLAN.LE.12) THEN
                NPLANE(JIMODUL(K),IPLAN)=1
                NEXE(IPLAN)=1
              END IF

            END DO

          ELSE

            IMODUL=IMODUL/2
            IF (IMODUL.GE.1.AND.IMODUL.LE.6.AND.IPLAN.GE.1.
     &        AND.IPLAN.LE.12) THEN
              NPLANE(IMODUL,IPLAN)=1
              NEXE(IPLAN)=1
            END IF

          END IF

        END IF


      END DO

C------fill the energy vectors by the common HDPLA of HPLAND----------

      DO I=1,24
        DO J=1,12
          IF(NPLANB(I,J).EQ.1) EVECB(J)=EVECB(J)+EPLANE(I,J)
        END DO
      END DO

C-------------endcaps-------------------------------------------------

      IF (IENDCAP.EQ.2) THEN
        DO I=1,6
          DO J=1,12
            IF(NPLANE(I,J).EQ.1) EVECE(J)=EVECE(J)+EPLAEB(I,J)
          END DO
        END DO
      ELSE
        DO I=1,6
          DO J=1,12
            IF(NPLANE(I,J).EQ.1) EVECE(J)=EVECE(J)+EPLAEA(I,J)
          END DO
        END DO
      END IF

C------------------------------------------------------------------

  999 RETURN
      END

C!==================================================================
*
C********************************************************************
      SUBROUTINE HPLAND
C********************************************************************
C!HCAL wire planes decoding routine.                                *
C                                                                   *
C    Author : R.Tenchini                                            *
C                  18.7.91                                          *
C                  MODIFIED 11.1.93                                 *
C                  Modified 13.9.94 (S.Salomone)
C    Input bank : HPDI                                              *
C                                                                   *
C    Ouput in common HDPLA containig the calibrated                 *
C          energy in each of the 12 planes of the                   *
C          24 barrel modules, of the 6 modules of                   *
C          endcap A and the 6 of encap B                            *
C                                                                   *
C********************************************************************
      INCLUDE '/aleph/phy/qcde.inc'
      INCLUDE '/aleph/phy/qhac.inc'
      COMMON/HDPLA/EPLANE(24,12),EPLAEA(6,12),EPLAEB(6,12)
      PARAMETER (CAL90=1.83)
      PARAMETER (C91EA0=1.43)
      PARAMETER (C91BA=2.18,C91EA=3.40,C91EB=3.40)
      PARAMETER (C92BA=2.16,C92EA=2.19,C92EB=2.22)
      PARAMETER (C93BA=2.14,C93EA=2.17,C93EB=2.21)
C CALIBRATION WITH DIMUONS
C     PARAMETER (C91BA=1.88,C91EA=3.98,C91EB=3.98)
C     PARAMETER (C92BA=1.90,C92EA=2.14,C92EB=2.14)
      INCLUDE '/aleph/phy/qmacro.inc'
C-----------------------------------------------------------------------
      KHPDI=NLINK('HPDI',0)
      IF(KHPDI.EQ.0) RETURN
      NHPDI=LROWS(KHPDI)
      LHPDI=LCOLS(KHPDI)
      CALL VZERO(EPLANE,288)
      CALL VZERO(EPLAEA,72)
      CALL VZERO(EPLAEB,72)
      IF(XMCEV) THEN
        PLCBA=1.
        PLCEA=1.
        PLCEB=1.
        KAJOB=NLINK('AJOB',0)
        IGVER=ITABL(KAJOB,1,9)
      ELSE
        PLCBA=C91BA
        PLCEA=C91EA
        PLCEB=C91EB
        IF(KRUN.LT.10000) PLCBA=CAL90
        IF(KRUN.LT.11671) PLCEA=C91EA0
        IF(KRUN.GT.14207) THEN
           PLCBA=C92BA
           PLCEA=C92EA
           PLCEB=C92EB
        ENDIF
        IF(KRUN.GT.20164) THEN
           PLCBA=C93BA
           PLCEA=C93EA
           PLCEB=C93EB
        ENDIF
      ENDIF
      DO 100 I=1,NHPDI
        IADD=ITABL(KHPDI,I,JHPDPA)
        IF(.NOT.XMCEV.AND.KRUN.LT.10000) THEN
          IF(IADD.LE.10000) THEN
            IMODUL=(IADD-1)/12+1
            ICHK  =MOD(IMODUL,2)
            IF(ICHK.EQ.0) THEN
              IMODUL=IMODUL-1
            ELSE
              IMODUL=IMODUL+1
            ENDIF
            IPLAN=MOD(IADD,12)
            IF(IPLAN.EQ.0) IPLAN=12
            IPLAN=13-IPLAN
            ICHK  =MOD(IPLAN,2)
            IF(ICHK.EQ.0) THEN
              IPLAN=IPLAN-1
            ELSE
              IPLAN=IPLAN+1
            ENDIF
            ISUBD=2
          ELSE
            IPLAN=IBITS(IADD,0,8)
            IMODUL=IBITS(IADD,8,8)
            IMODUL=IMODUL+1
            ISUBD=IBITS(IADD,16,8)
          ENDIF
        ELSE
          IPLAN=IBITS(IADD,0,8)
          IMODUL=IBITS(IADD,8,8)
          ISUBD=IBITS(IADD,16,8)

          IF((XMCEV.AND.IGVER.LT.242.AND.ISUBD.NE.2).OR.
     &       (.NOT.XMCEV.AND.KRUN.GE.14209.AND.ISUBD.NE.2).OR.
     &       (XMCEV.AND.IGVER.GE.253.AND.ISUBD.NE.2)) THEN

            IF(IPLAN.GE.2.AND.IPLAN.LE.21) THEN
              IPLAN=IPLAN/2+1
            ENDIF
            IF(IPLAN.EQ.22) IPLAN=12
          ENDIF
        ENDIF
        IF(ISUBD.EQ.2) THEN
          ENER=ITABL(KHPDI,I,JHPDED)/(1000.*PLCBA)
          IF(IMODUL.GE.1.AND.IMODUL.LE.24.
     &      AND.IPLAN.GE.1.AND.IPLAN.LE.12) THEN
            EPLANE(IMODUL,IPLAN)=ENER
          ENDIF
        ELSEIF(ISUBD.EQ.1) THEN
          ENER=ITABL(KHPDI,I,JHPDED)/(1000.*PLCEA)
          IF(IMODUL.GE.1.AND.IMODUL.LE.6.
     &      AND.IPLAN.GE.1.AND.IPLAN.LE.12) THEN
            EPLAEA(IMODUL,IPLAN)=ENER+EPLAEA(IMODUL,IPLAN)
          ENDIF
        ELSEIF(ISUBD.EQ.3) THEN
          ENER=ITABL(KHPDI,I,JHPDED)/(1000.*PLCEB)
          IF(IMODUL.GE.1.AND.IMODUL.LE.6.
     &      AND.IPLAN.GE.1.AND.IPLAN.LE.12) THEN
            EPLAEB(IMODUL,IPLAN)=ENER+EPLAEB(IMODUL,IPLAN)
          ENDIF
        ENDIF
  100 CONTINUE
      RETURN
      END

