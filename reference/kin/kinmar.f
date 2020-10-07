      SUBROUTINE ALSEED(IRGEN,ISEED1,ISEED2)
C-----------------------------------------------------------------------
C - Author : B.Bloch-Devaux -890201
C! returns original seeds from RANMAR random generator
C  mod march 98 : introduce flag to get two different sequences running
C
C - Structure : SUBROUTINE subprogram
C               User Entry Name :ALSEED
C               External references :RMARUT
C               Comdecks references : none
C - Input : none
C - Output : IRGEN = generator ident (3 is RANMAR)
C            ISEED1= first original seed
C            ISEED2= second original seed
C
C-----------------------------------------------------------------------
      common/iflmar/iflrn,nr0,nr1
      IRGEN = 3
      if ( iflrn.eq.0) then
         CALL RMARUT(IS1,IS2,IS3)
      else if ( iflrn.eq.1) then
         call AMARUT(IS1,IS2,IS3)
      endif
      ISEED1 = IS1/30082
      ISEED2 = IS1 - 30082*ISEED1
      RETURN
      END
      SUBROUTINE RDMIN(ISEED)
C-----------------------------------------------------------------------
C - Author : B.Bloch-Devaux -890201
C
C!Interface from RDMIN to RMARIN (RANMAR initialization)
C   First initialization or re-initialization
C 1.-Primary initialization by using RMAR data card with two
C  arguments (ISEED1,ISEED2) which are mandatory.
C    ISEED1 must be in the range of 100 values designated for each
C collaborating institution. The range of ISEED2 is 0 <= ISEED2 <= 30081
C This allows 3008200 independent sequences per collaborating institutio
C To be coherent with latest version of RANMAR from Fred James (Jan 89)
C the 3 values to be input to RMARIN are computed from(ISEED1,ISEED2)
C 2.- Re-initialization by using RINI data card with three
C  arguments (ISEED1,ISEED2,ISEED3) which are mandatory.
C  RINI has priority over RMAR card
C  If no RINI nor RMAR card is found, default init values are used
C
C   mod march 98 : possibility of two different running sequences
C - Structure : SUBROUTINE program
C               User Entry Name :RDMIN
C               External references :NAMIND(BOS77),RMARIN
C               Comdecks references : BCS
C - Input : ISEED   dummy
C - Output : none
C
C----------------------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW  ,LBCS
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2, LBCS=1000)
C
      COMMON /BCS/   IW(LBCS )
      INTEGER IW
      REAL RW(LBCS)
      EQUIVALENCE (RW(1),IW(1))
C
      INTEGER ISEED,MXSEED
      PARAMETER ( MXSEED = 30000)
C
      LOGICAL FIRST
      DATA FIRST/.TRUE./
C
      IF (FIRST) THEN
        FIRST = .FALSE.
        KRINI=IW(NAMIND('RINI'))
        IF (KRINI.LE.0) THEN
C  No reprocess required, look for initialisation
          KRMAR=IW(NAMIND('RMAR'))
          ISEED3 = 19
          ISEED4 = 17
          IF (KRMAR.LE.0) THEN
            WRITE(IW(6),101)
            ISEED1 = 1802
            ISEED2 = 9373
          ELSE
            LNRMAR = IW(KRMAR)
            IF (LNRMAR.LT.2) THEN
               WRITE(IW(6),102)
               CALL EXIT
            ENDIF
            ISEED1 = IW(KRMAR+1)
            ISEED2 = IW(KRMAR+2)
            WRITE (IW(6),801) ISEED1,ISEED2
            IF ( ISEED1.GT.MXSEED ) GO TO 999
            IF ( ISEED2.GT.MXSEED ) GO TO 999
            IF (LNRMAR.GE.4) THEN
               ISEED3 = IW(KRMAR+3)
               ISEED4 = IW(KRMAR+4)
               WRITE (IW(6),803) ISEED3,ISEED4
               IF ( ISEED3.GT.MXSEED ) GO TO 999
               IF ( ISEED4.GT.MXSEED ) GO TO 999
            IF ((ISEED3.eq.ISEED1).and.(ISEED4.eq.ISEED2)) GO TO 999
            ENDIF
          ENDIF
          IJKLI = ISEED1*30082 + ISEED2
          NTOTI = 0
          NTOTN = 0
          IJKLI2 = ISEED3*30082 + ISEED4
          NTOTI2 = 0
          NTOTN2 = 0
        ELSE
C Reprocessing required
            LNRINI = IW(KRINI)
            IF (LNRINI.LT.3) THEN
               WRITE(IW(6),103)
               CALL EXIT
            ENDIF
            IJKLI = IW(KRINI+1)
            NTOTI = IW(KRINI+2)
            NTOTN = IW(KRINI+3)
            IF (LNRINI.GE.6) THEN
               IJKLI2 = IW(KRINI+4)
               NTOTI2 = IW(KRINI+5)
               NTOTN2 = IW(KRINI+6)
            ENDIF
        ENDIF
        WRITE (IW(6),802) IJKLI,NTOTI,NTOTN
        CALL RMARIN(IJKLI,NTOTI,NTOTN)
        WRITE (IW(6),804) IJKLI2,NTOTI2,NTOTN2
        CALL AMARIN(IJKLI2,NTOTI2,NTOTN2)
      ENDIF
C
      RETURN
C
 101  FORMAT(' RDMIN -- RMAR data card is missing! use defaults')
 102  FORMAT(' RDMIN -- RMAR Less than two input seeds !')
 103  FORMAT(' RDMIN -- RINI less than three input seeds for RANMAR!')
 801  FORMAT(/3X,' RANMAR Input seeds ',2I8)
 802  FORMAT(/3X,' RANMAR Input seeds RMARIN ',3I8)
 803  FORMAT(/3X,' 2nd RANMAR Input seeds ',2I8)
 804  FORMAT(/3X,' 2nd RANMAR Input seeds RMARIN ',3I8)
 999  WRITE ( IW(6),'(1X,'' MAXIMUM  seed allowed is '',I6)') MXSEED
      CALL EXIT
      END
      FUNCTION RNDM(DUMMY)
C-----------------------------------------------------------------------
C - Author : B.Bloch-Devaux -890201
C!Interface from RNDM to RANMAR.
C act as a server of  20 numbers from one RANMAR call
C
C   mod march 98 : possibility of 2 different RANMAR running sequences
C   mod October 2000 : add argument to entry RRESET ( linux compiler)
C
C - Structure : REAL FUNCTION subprogram
C               User Entry Name :RNDM,RRESET
C               External references :RANMAR
C               Comdecks references : none
C - Input : DUMMY   dummy
C - Output : Real value between 0. and 1.
C
C-----------------------------------------------------------------------
      common/iflmar/iflrn,nr0,nr1
      PARAMETER ( LEN = 20,len2 = 20)
      DIMENSION RVEC(LEN),rvec2(len2)
      DATA NR,nr2/ 20,20/
      if ( iflrn.eq.0) then
         IF(NR.EQ.LEN) THEN
           CALL RANMAR(RVEC,LEN)
           NR=0
         ENDIF
         NR=NR+1
         RNDM=RVEC(NR)
         nr0 = nr
      else if ( iflrn.eq.1) then
         IF(NR2.EQ.LEN2) THEN
           CALL AlMAR(RVEC2,LEN2)
           NR2=0
         ENDIF
         NR2=NR2+1
         RNDM=RVEC2(NR2)
         nr1 = nr2
      endif
      RETURN
      ENTRY RRESET(DUMMY)
      if ( iflrn.eq.0) then
         NR = LEN
         nr0 = nr
      else if ( iflrn.eq.1) then
         nr2 = len2
         nr1 = nr2
      endif
      RNDM = 0.
      RETURN
      END
      SUBROUTINE RDMOUT(ISEED)
C-----------------------------------------------------------------------
C - Author : B.Bloch-Devaux -890201
C! Interface from RDMOUT to RMARUT (RANMAR seeds ouput routine)
C
C   mod March 98 : possibility of 2 different running RANMAR sequences
C - Structure : SUBROUTINE subprogram
C               User Entry Name :RDMOUT
C               External references :RMARUT,RRESET
C               Comdecks references : none
C - Input : none
C - Output : Array of generator seeds (integer)
C
C-----------------------------------------------------------------------
      common/iflmar/iflrn,nr0,nr1
      INTEGER ISEED(*)
C
      ISEED(1)= 0
      ISEED(3)= 0
      ISEED(2)= 0
      if ( iflrn.eq.0 ) then
         CALL RMARUT(ISEED(1),ISEED(2),ISEED(3))
         dum =  RRESET(dum2)
      else if ( iflrn.eq.1 ) then
         CALL AMARUT(ISEED(1),ISEED(2),ISEED(3))
         dum =  RRESET(dum2)
      endif
      RETURN
      END
      SUBROUTINE RANMAR(RVEC,LENV)
C------------------------------------------------------------------
C!Universal random number generator proposed by Marsaglia and Zaman
C in report FSU-SCRI-87-50
C        modified by F. James, 1988 and 1989, to generate a vector
C        of pseudorandom numbers RVEC of length LENV, and to put in
C        the COMMON block everything needed to specify currrent state,
C        and to add input and output entry points RMARIN, RMARUT.
C--------------------------------------------------------------------
      DIMENSION RVEC(*)
      COMMON/RASET1/U(97),C,I97,J97
      PARAMETER (MODCNS=1000000000)
      DATA NTOT,NTOT2,IJKL/-1,0,0/
C
      IF (NTOT .GE. 0)  GO TO 50
C
C        Default initialization. User has called RANMAR without RMARIN.
      IJKL = 54217137
      NTOT = 0
      NTOT2 = 0
      KALLED = 0
      GO TO 1
C
      ENTRY      RMARIN(IJKLIN, NTOTIN,NTOT2N)
C         Initializing routine for RANMAR, may be called before
C         generating pseudorandom numbers with RANMAR. The input
C         values should be in the ranges:  0<=IJKLIN<=900 OOO OOO
C                                          0<=NTOTIN<=999 999 999
C                                          0<=NTOT2N<<999 999 999!
C To get the standard values in Marsaglia's paper, IJKLIN=54217137
C                                            NTOTIN,NTOT2N=0
      IJKL = IJKLIN
      NTOT = MAX(NTOTIN,0)
      NTOT2= MAX(NTOT2N,0)
      KALLED = 1
C          always come here to initialize
    1 CONTINUE
      IJ = IJKL/30082
      KL = IJKL - 30082*IJ
      I = MOD(IJ/177, 177) + 2
      J = MOD(IJ, 177)     + 2
      K = MOD(KL/169, 178) + 1
      L = MOD(KL, 169)
      WRITE(6,201) IJKL,NTOT,NTOT2
 201  FORMAT(1X,' RANMAR INITIALIZED: ',I10,2X,2I10)
      DO 2 II= 1, 97
      S = 0.
      T = .5
      DO 3 JJ= 1, 24
         M = MOD(MOD(I*J,179)*K, 179)
         I = J
         J = K
         K = M
         L = MOD(53*L+1, 169)
         IF (MOD(L*M,64) .GE. 32)  S = S+T
    3    T = 0.5*T
    2 U(II) = S
      TWOM24 = 1.0
      DO 4 I24= 1, 24
    4 TWOM24 = 0.5*TWOM24
      C  =   362436.*TWOM24
      CD =  7654321.*TWOM24
      CM = 16777213.*TWOM24
      I97 = 97
      J97 = 33
C       Complete initialization by skipping
C            (NTOT2*MODCNS + NTOT) random numbers
      DO 45 LOOP2= 1, NTOT2+1
      NOW = MODCNS
      IF (LOOP2 .EQ. NTOT2+1)  NOW=NTOT
      IF (NOW .GT. 0)  THEN
       WRITE (6,'(A,I15)') ' RMARIN SKIPPING OVER ',NOW
       DO 40 IDUM = 1, NTOT
       UNI = U(I97)-U(J97)
       IF (UNI .LT. 0.)  UNI=UNI+1.
       U(I97) = UNI
       I97 = I97-1
       IF (I97 .EQ. 0)  I97=97
       J97 = J97-1
       IF (J97 .EQ. 0)  J97=97
       C = C - CD
       IF (C .LT. 0.)  C=C+CM
   40  CONTINUE
      ENDIF
   45 CONTINUE
      IF (KALLED .EQ. 1)  RETURN
C
C          Normal entry to generate LENV random numbers
   50 CONTINUE
      DO 100 IVEC= 1, LENV
      UNI = U(I97)-U(J97)
      IF (UNI .LT. 0.)  UNI=UNI+1.
      U(I97) = UNI
      I97 = I97-1
      IF (I97 .EQ. 0)  I97=97
      J97 = J97-1
      IF (J97 .EQ. 0)  J97=97
      C = C - CD
      IF (C .LT. 0.)  C=C+CM
      UNI = UNI-C
      IF (UNI .LT. 0.) UNI=UNI+1.
C        Replace exact zeroes by uniform distr. *2**-24
         IF (UNI .EQ. 0.)  THEN
         UNI = TWOM24*U(2)
C             An exact zero here is very unlikely, but let's be safe.
         IF (UNI .EQ. 0.) UNI= TWOM24*TWOM24
         ENDIF
      RVEC(IVEC) = UNI
  100 CONTINUE
      NTOT = NTOT + LENV
         IF (NTOT .GE. MODCNS)  THEN
         NTOT2 = NTOT2 + 1
         NTOT = NTOT - MODCNS
         ENDIF
      RETURN
C           Entry to output current status
      ENTRY RMARUT(IJKLUT,NTOTUT,NTOT2T)
      IJKLUT = IJKL
      NTOTUT = NTOT
      NTOT2T = NTOT2
      RETURN
      END
      SUBROUTINE ALMAR(RVEC,LENV)
C------------------------------------------------------------------
C!Universal random number generator proposed by Marsaglia and Zaman
C in report FSU-SCRI-87-50
C        modified by F. James, 1988 and 1989, to generate a vector
C        of pseudorandom numbers RVEC of length LENV, and to put in
C        the COMMON block everything needed to specify currrent state,
C        and to add input and output entry points RMARIN, RMARUT.
C    B. Bloch March 98
C        clone copy of RANMAR with a different common to have a 2nd
C        independent sequence
C--------------------------------------------------------------------
      DIMENSION RVEC(*)
      COMMON/ARSET1/U(97),C,I97,J97
      PARAMETER (MODCNS=1000000000)
      DATA NTOT,NTOT2,IJKL/-1,0,0/
      DATA ipr/-1/
C
      IF (NTOT .GE. 0)  GO TO 50
C
C        Default initialization. User has called RANMAR without RMARIN.
      IJKL = 54217137
      NTOT = 0
      NTOT2 = 0
      KALLED = 0
      GO TO 1
C
      ENTRY      AMARIN(IJKLIN, NTOTIN,NTOT2N)
C         Initializing routine for RANMAR, may be called before
C         generating pseudorandom numbers with RANMAR. The input
C         values should be in the ranges:  0<=IJKLIN<=900 OOO OOO
C                                          0<=NTOTIN<=999 999 999
C                                          0<=NTOT2N<<999 999 999!
C To get the standard values in Marsaglia's paper, IJKLIN=54217137
C                                            NTOTIN,NTOT2N=0
      IJKL = IJKLIN
      NTOT = MAX(NTOTIN,0)
      NTOT2= MAX(NTOT2N,0)
      KALLED = 1
C          always come here to initialize
    1 CONTINUE
      IJ = IJKL/30082
      KL = IJKL - 30082*IJ
      I = MOD(IJ/177, 177) + 2
      J = MOD(IJ, 177)     + 2
      K = MOD(KL/169, 178) + 1
      L = MOD(KL, 169)
      if ( ipr.lt.10) then     !  print only first 10 inits
      WRITE(6,201) IJKL,NTOT,NTOT2
 201  FORMAT(1X,' 2nd RANMAR INITIALIZED: ',I10,2X,2I10)
        ipr = ipr + 1
      endif
      DO 2 II= 1, 97
      S = 0.
      T = .5
      DO 3 JJ= 1, 24
         M = MOD(MOD(I*J,179)*K, 179)
         I = J
         J = K
         K = M
         L = MOD(53*L+1, 169)
         IF (MOD(L*M,64) .GE. 32)  S = S+T
    3    T = 0.5*T
    2 U(II) = S
      TWOM24 = 1.0
      DO 4 I24= 1, 24
    4 TWOM24 = 0.5*TWOM24
      C  =   362436.*TWOM24
      CD =  7654321.*TWOM24
      CM = 16777213.*TWOM24
      I97 = 97
      J97 = 33
C       Complete initialization by skipping
C            (NTOT2*MODCNS + NTOT) random numbers
      DO 45 LOOP2= 1, NTOT2+1
      NOW = MODCNS
      IF (LOOP2 .EQ. NTOT2+1)  NOW=NTOT
      IF (NOW .GT. 0)  THEN
       IF(ipr.lt.10)WRITE(6,'(A,I15)') ' RMARIN SKIPPING OVER ',NOW
       DO 40 IDUM = 1, NTOT
       UNI = U(I97)-U(J97)
       IF (UNI .LT. 0.)  UNI=UNI+1.
       U(I97) = UNI
       I97 = I97-1
       IF (I97 .EQ. 0)  I97=97
       J97 = J97-1
       IF (J97 .EQ. 0)  J97=97
       C = C - CD
       IF (C .LT. 0.)  C=C+CM
   40  CONTINUE
      ENDIF
   45 CONTINUE
      IF (KALLED .EQ. 1)  RETURN
C
C          Normal entry to generate LENV random numbers
   50 CONTINUE
      DO 100 IVEC= 1, LENV
      UNI = U(I97)-U(J97)
      IF (UNI .LT. 0.)  UNI=UNI+1.
      U(I97) = UNI
      I97 = I97-1
      IF (I97 .EQ. 0)  I97=97
      J97 = J97-1
      IF (J97 .EQ. 0)  J97=97
      C = C - CD
      IF (C .LT. 0.)  C=C+CM
      UNI = UNI-C
      IF (UNI .LT. 0.) UNI=UNI+1.
C        Replace exact zeroes by uniform distr. *2**-24
         IF (UNI .EQ. 0.)  THEN
         UNI = TWOM24*U(2)
C             An exact zero here is very unlikely, but let's be safe.
         IF (UNI .EQ. 0.) UNI= TWOM24*TWOM24
         ENDIF
      RVEC(IVEC) = UNI
  100 CONTINUE
      NTOT = NTOT + LENV
         IF (NTOT .GE. MODCNS)  THEN
         NTOT2 = NTOT2 + 1
         NTOT = NTOT - MODCNS
         ENDIF
      RETURN
C           Entry to output current status
      ENTRY AMARUT(IJKLUT,NTOTUT,NTOT2T)
      IJKLUT = IJKL
      NTOTUT = NTOT
      NTOT2T = NTOT2
      RETURN
      END
      REAL FUNCTION AMARSET(IFL)
C-----------------------------------------------------------------------
C - Author : B.Bloch-Devaux -980312
C!Interface from RNDM to RANMAR.
C   swiches from 1 RANMAR sequence to another
C
C - Structure : REAL FUNCTION subprogram
C               User Entry Name :AMARSET 
C               External references : none
C               Comdecks references : IFLMAR ( internal)
C - Input : switch value  0 to switch to 1st sequence, >=1 for 2nd
C - Output : Real value of switch ( 0. or 1.)
C
C-
C-----------------------------------------------------------------------
      common/iflmar/iflrn,nr0,nr1
      iflrn = ifl
      If ( ifl.gt.1) iflrn = 1
      If ( ifl.lt.0) iflrn = 0
      AMARSET = float(iflrn)
      RETURN
      END
