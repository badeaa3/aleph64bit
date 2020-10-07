C-----------------------------------------------------------------------
C  A  L  E  P  H   I  N  S  T  A  L  L  A  T  I  O  N    N  O  T  E  S |
C                                                                      |
C    ORIGINAL CODE : GGMJ01     FROM A.J. FINCH                        |
C    TRANSMITTED BY : A.J FINCH  June 1993                             |
C    modifications to the code ( description,author,date):             |
C                                                                      |
C   1. Modified FUNCTION DRN , DRNSET                                  |
C      Adapted to KINMAR: Set ENTRY DRNSET to interface with RMARIN    |
C      and DRN to RNDM       B. Bloch       June 1993                  |
C   2. Change BSTIME to use TIMAL routines instead of CLOCK with gives |
C      troubles on IBM as it was setup   . B. Bloch June 1993          |
C   3. Change TIMAL to TIMEL routines for UNix B. Bloch  August 1999   |
C-----------------------------------------------------------------------
      SUBROUTINE BASES( FXN )
C
C***********************************************************************
C*                                                                     *
C*============================                                         *
C*    SUBROUTINE BASES( FXN )                                          *
C*============================                                         *
C*((Function))                                                         *
C*    Subroutine performs N-dimensional Monte Carlo integration        *
C*    for four vector generation of simulated events                   *
C*                                                                     *
C*       IFLAG = 0 ; First Trial of Defining Grid                      *
C*       IFLAG = 1 ; First Trial of Data Accumulation                  *
C*       IFLAG = 2 ; Second Trial of Defining Grid                     *
C*       IFLAG = 3 ; Second Trial of Data Accumulation                 *
C*                                                                     *
C*    Coded   by S.Kawabata    July 1980 at DESY, Hamburg              *
C*    Last update by S.Kawabata Oct 1985 at KEK.                       *
C*    Changed for INTEL         Nov.1991 at KEK.                       *
C*    Changed for nCUBE         Nov.1991 at KEK.                       *
C*    Changed for AP1000        Dec.1991 at KEK.                       *
C*    Update for printouts of histograms and convergencey list
C*           by S.Kawabata      May.1992 at KEK
C*                                                                     *
C***********************************************************************
C
C
      IMPLICIT REAL*8 (A-H,O-Z)
      REAL*4   SETIM,UTIME,TIM1,TIM2,RTIM
      PARAMETER (MXDIM = 25, NDMX = 50, LENG = 17000)
      COMMON /BASE0/ SETIM,UTIME,IFLAG,NPRINT,IBASES
      COMMON /BASE1/ XL(MXDIM),XU(MXDIM),NDIM,NSNG,
     .               IG(MXDIM),NCALL
      COMMON /BASE2/ ACC1,ACC2,ITMX1,ITMX2
      COMMON /BASE3/ SI,SI2,SWGT,SCHI,SCALLS,ATACC,NSU,IT,WGT
      COMMON /BASE4/ XI(NDMX,MXDIM),DX(MXDIM),DXD(LENG),DXP(LENG),
     .               ND,NG,NPG,MA(MXDIM)
      PARAMETER (ITM = 50)
      REAL*4   TIME,EFF,WRONG,TRSLT,TSTD,PCNT
      COMMON /BASE5/ ITRAT(ITM),TIME(ITM),EFF(ITM),WRONG(ITM),
     .       RESLT(ITM),ACSTD(ITM),TRSLT(ITM),TSTD(ITM),PCNT(ITM)
      COMMON /BASE6/ D(NDMX,MXDIM)
      COMMON /BSRSLT/AVGI,SD,CHI2A,STIME,ITF
      COMMON /LOOP0/ LOOPC,IRCODE
C
      REAL*8  X(MXDIM)
      INTEGER KG(MXDIM),IA(MXDIM)
C
*     integer id_node, pid, no_node, all_node
*     integer type_time, type_flag, type_loop, type_data, type_hist
*     COMMON/NINFO/ id_node, pid, no_node, all_node,
*    .              type_time, type_flag, type_loop, type_data,
*    .              type_hist
*     real*4  test_time
C
*     PARAMETER (ISIZE = 34000)
*     COMMON /BSWORK/ IWORK(ISIZE)
*     REAL*8 WORK(ISIZE/2)
*     EQUIVALENCE (IWORK(1),WORK(1))
C
*      REAL*8  TX(2)
      INTEGER NSNODE(2,512),NEFF(2)
      REAL*4  TIM0
      DATA  ONE/ 1.0/, ZERO/0.0/, N0/0/, N1/1/, N2/2/, HUNDRT/100.0/
      DATA  NDM0 / 0/, NDM1/ 0/, NDM2/ 0/
C
*#ifdef DEBUG
C*monitor by T.ISHIKAWA
*      REAL*4 C0TIME,WTIME
*      COMMON/MONITR/ MNGOOD(512,100),C0TIME(100)
*#endif
C*
      IBASES  = 1
      MPRINT  = ABS(NPRINT)
C
C===============================================================
C                 Initialization Part
C===============================================================
C
C  -------------------------------------------------------------
C           Define the number of hypercubes
C -------------------------------------------------------------
      IF( IFLAG .LE. N0 ) THEN
         CALL BSINIT
      ELSEIF( NDM2 .NE. 1 ) THEN
         NDM2  = 1
      ENDIF
C
C
*#ifdef INTEL
*      call gsync()
*#endif
      CALL BSTIME( TIM0, 1 )
C
*#ifdef INTEL
*      call gshigh(TIM0,1,WTIME)
*#elif NCUBE
*      call nbrdcst(TIM0,1*4)
*#elif AP
*      call c2brd(0,TIM0,1*4,nrsize)
**       TIMECL = TIM0
*       call c2fmax(TIMECL,id_node,TIM0,max_id,ir)
*#endif
C  -----------------------------------------------------------------
      XND     = ND
      NSP     = NG**NSNG
      XJAC    = 1.0
      DO  5 I = 1, NDIM
         XJAC = XJAC*DX(I)
    5 CONTINUE
      CALLS   = NSP*NPG
      DXG     = 1.0/NG
      DV2G    = DXG**(2*NSNG)/NPG/NPG/(NPG-1)
      DXG     = DXG*XND
C**
*      NONODE  = no_node
       NONODE  = 1
C**
      MEX     = MOD(NSP,NONODE)
      NPERCP  = NSP/NONODE
      NSPT    = 0
      DO  15 NODEX = 1,NONODE
         NSPS  = NSPT + 1
         NSPT  = NSPT + NPERCP
         IF( NODEX .LE. MEX ) NSPT = NSPT + 1
         NSNODE(1,NODEX) = NSPS
         NSNODE(2,NODEX) = NSPT
   15 CONTINUE
C**
      NEND    = N0
      ITOVER  = N0
      ATACC   = ZERO
      IF(IFLAG .EQ. N0 .OR. IFLAG .EQ. N1 ) THEN
         DO 10 J  = N1,NSP
           DXD(J) = ZERO
           DXP(J) = ZERO
   10    CONTINUE
         ISTEP   = IFLAG
         IT1   = N1
         SI    = ZERO
         SI2   = ZERO
         SWGT  = ZERO
         SCHI  = ZERO
C        -----------
         CALL BHRSET
C        -----------
         NSU     = N0
         SCALLS= ZERO
      ELSE
          IF(    IFLAG .EQ. 2 ) THEN
                 ISTEP  = N0
          ELSEIF(IFLAG .EQ. 3 ) THEN
                 ISTEP  = N1
          ELSE
*            if( id_node .eq. 0 ) then
                 WRITE(6,9000) IFLAG
 9000            FORMAT(1X,'BASES Error; Illegal FLAG =',I3 )
*            endif
C                *****************
                       STOP
C                *****************
          ENDIF
          IT1   = IT + 1
      ENDIF
      ITMX   = ITMX1
      ACC    = ACC1*0.01
      IF( ISTEP .EQ. N1 ) THEN
         ITMX = ITMX2
         ACC  = ACC2*0.01
      ENDIF
C  -----------------------------------------------------------------
      IF( NDIM .NE. NDM0 ) THEN
*#ifdef NCUBE
*         call nglobal()
*#else
*         if( id_node .eq. 0 ) then
*#endif
              MCALL  = CALLS
              CALL BSPRNT( 4, MCALL, IDUM2, IDUM3, IDUM4 )
*#ifdef NCUBE
*          call nlocal()
*#else
*          endif
*#endif
          NDM0  = NDIM
      ENDIF
C
C====================================================================
C               Main Integration Loop
C====================================================================
C
      CALL BSPRNT( 5, MPRINT, ISTEP, IDUM3, IDUM4 )
      NEGFLG     = 0
      DO 500  IT = IT1,ITMX
         SCALLS  = SCALLS + CALLS
         NGOOD = N0
         NEGTIV= N0
*#ifdef INTEL
*         call led(1)
*         call gsync()
*#endif
         CALL BSTIME( TIM1, 1 )
C         print *,'TIM1 = ',IT,id_node,TIM1
*#ifdef INTEL
*         call gshigh(TIM1,1,WTIME)
C         if( id_node .eq. 0 ) print *,'max TIM1 = ',TIM1
*#elif NCUBE
*         call nbrdcst(TIM1,1*4)
*#elif AP
C*        call c2brd(0,TIM1,1*4,nrsize)
*         TIMECL = TIM1
*         call c2fmax(TIMECL,id_node,TIM1,max_id,ir)
*#endif
         TI    = ZERO
         TSI   = TI
         IF( ISTEP .EQ. N0 ) THEN
             DO 200 J= N1,NDIM
             DO 200 I=1,ND
                D(I,J)= TI
  200        CONTINUE
         ENDIF
C---------------------------------------------------------------------
C            Accumulate Events  for all cubes
C---------------------------------------------------------------------
C        Dividing sampling points to all nodes 0 => 15
C*
          NODEX  = 1
*         NODEX  = id_node
*         if( id_node .eq. 0 ) NODEX = no_node
C======================================================================
C        Distributing hyper cubes to 16 nodes
C           NSNODE(1,NODEX)   : 1st cube number
C           NSNODE(2,NODEX)   : Last cube number
C                    NODEX    : node number 1 => 16(=0)
C======================================================================
            NSP1  = NSNODE(1,NODEX)
C*
*            if( NSP1 .GT. 1 ) then
*                 call drloop(ndim*npg*(nsp1-1))
*c                do 201 nl = 1, ndim*npg*(nsp1-1)
*c                  xdummy = drn(dummy)
*c 201            continue
*            endif
C*
            NSP2  = NSNODE(2,NODEX)
            DO 400 NCB = NSP1, NSP2
               FB      = 0.0
               F2B     = 0.0
               NP      = NCB - 1
               IF( NSNG .GT. 1 ) THEN
                   DO 210 J = 1,NSNG-1
                      NUM   = MOD(NP,MA(J+1))
                      KG(J) = NUM/MA(J) + 1
  210              CONTINUE
               ENDIF
               KG(NSNG)      = NP/MA(NSNG) + 1
               DO 300 NTY = 1,NPG
                  WGT   = XJAC
                  DO 250 J= 1,NDIM
                     IF( J .LE. NSNG ) THEN
                         XN  = (KG(J)-DRN(DUMY))*DXG+1.D0
                     ELSE
                         XN  = ND*DRN(DUMY)+1.D0
                     ENDIF
                     IA(J)   = XN
                     IAJ     = IA(J)
                     IF( IAJ .EQ. 1) THEN
                         XO  = XI(IAJ,J)
                         RC  = (XN-IA(J))*XO
                     ELSE
                         XO  = XI(IAJ,J)-XI(IAJ-1,J)
                         RC  = XI(IAJ-1,J)+(XN-IAJ)*XO
                     ENDIF
                     X(J)    = XL(J)+RC*DX(J)
                     WGT     = WGT*XO*XND
  250             CONTINUE
                  FXG  = FXN(X)*WGT
                  IF( FXG .NE. 0.0 ) THEN
                      NGOOD = NGOOD + 1
                      IF( ISTEP .EQ. 1 ) THEN
                          DXD(NCB) = DXD(NCB) + FXG
                          IF( FXG .GT. DXP(NCB) ) DXP(NCB) = FXG
                      ENDIF
                      IF( FXG .LT. 0.0 ) THEN
                          NEGTIV= NEGTIV+ 1
                          IF( NEGFLG .EQ. 0 ) THEN
*                         WRITE(6,9200) IT,id_node
                          WRITE(6,9200) IT,NONODE
 9200                     FORMAT(1X,
     .                        '******* WARNING FROM BASES ********',
     .                        '***********',
     .                    /1X,'*  Negative FUNCTION at IT =',I3,1X,
     .                        ', node = ',I3,1X,'*',
     .                    /1X,'***********************************',
     .                        '***********')
                          NEGFLG  = 1
                          ENDIF
                      ENDIF
                  ENDIF
                  F2    = FXG*FXG
                  FB    = FB + FXG
                  F2B   = F2B + F2
                  IF( ISTEP .EQ. 0 ) THEN
                      DO 260  J = 1,NDIM
                         D(IA(J),J)= D(IA(J),J)+F2
  260                 CONTINUE
                  ENDIF
C
C                 PRINT *,'F,F2  = ',F,F2
C
  300          CONTINUE
C     -----------------------------------------------------------
               F2B   = DSQRT(F2B*NPG)
               F2S   = (F2B-FB)*(F2B+FB)
               TI    = TI+FB
               TSI   = TSI + F2S
C
  400       CONTINUE
C*
*            if( NSP2 .LT. NSP ) then
*                call drloop(ndim*npg*(nsp-nsp2))
*c               do 401 nl = ndim*npg*nsp2+1, ndim*npg*nsp
*c                   xdummy = drn(dummy)
*c 401           continue
*            endif
C*
C======================================================================
         NEFF(1) = NGOOD
         NEFF(2) = NEGTIV
*#ifdef DEBUG
C*test by T.ISHIKAWA
*         MNGOOD(id_node+1,IT) = NGOOD
*c         CALL BSTIME(test_time,1)
*c         i_unit = 30 + mynode()
*c         write(i_unit,9981) IT,id_node,NEFF,test_time
*c 9981    format(1H ,'IT=',I3,'node=',I3,'NEFF ',I10,I2,
*c     &              ' node time =',F9.3)
*C          print *,' neff ',id_node,neff
*#endif
C
C
C
*#ifdef INTEL
*         call gisum( NEFF, 2, IWORK)
*#elif AP
*         call c2isum( NGOOD  , NEFF(1) , IR )
*         call c2isum( NEGTIV , NEFF(2) , IR )
*#elif NCUBE
*         call isumrn( NEFF , 2 )
*#endif
C         print *,' after isumrn ',id_node,neff
C
*         TX(1) = TI
*         TX(2) = TSI
*#ifdef INTEL
*         call gdsum(   TX, 2, WORK)
*#elif AP
*         call c2dsum( TI , TX(1), IR)
*         call c2dsum( TSI, TX(2), IR)
*#elif NCUBE
*         call dsumrn( TX , 2 )
*#endif
C
*         if( ISTEP .EQ. 0 ) then
*              NOWORK = NDMX*NDIM
*#ifdef INTEL
*             call gdsum( D, NOWORK, WORK)
*#elif AP
*             do 460 I = 1 , NDMX
*             do 460 J = 1 , NDIM
*             call c2dsum(D(I,J),DTMP,IR)
*             D(I,J) = DTMP
* 460         continue
*#elif NCUBE
*             call dsumrn( D , NOWORK)
*#endif
*         endif
C
C---------------------------------------------------------------------
C           Compute Result of this Iteration
C--------------------------------------------------------------------
C
C
         CALL BHSAVE
C
C
*#ifdef INTEL
*         call gsync()
*#endif
         CALL BSTIME( TIM2, 1 )
*c         print *,'TIM2 = ',IT,id_node,TIM2
*#ifdef INTEL
*         call gshigh(TIM2,1,WTIME)
*c         if( id_node .eq. 0 ) print *,'max TIM2 = ',TIM2
*#elif NCUBE
*         call nbrdcst(TIM2,1*4)
*#elif AP
**         call c2brd(0,TIM2,1*4,nrsize)
*         TIMECL = TIM2
*         call c2fmax(TIMECL,id_node,TIM2,max_id,ir)
*#endif
*         if( id_node .eq. 0 ) then
*             TI     = TX(1)
*             TSI    = TX(2)
*             NGOOD  = NEFF(1)
*             NEGTIV = NEFF(2)
C
             TI    = TI/CALLS
             TSI   = TSI*DV2G
             TI2   = TI*TI
C
C%           CALL BHSAVE
             CALL BHSAVE
C
             IF( NGOOD .LE. 10 ) THEN
              WRITE(6,9250)
 9250         FORMAT(1X,'******** FATAL ERROR IN BASES **************',
     .        /1X,'There are no enough good points in this iteration.',
     .        /1X,'This job was forced stop.')
C             *****************
                    STOP
C             *****************
             ENDIF
C
             WGT   = ONE/TSI
             SI    = SI+TI*WGT
             SWGT  = SWGT+WGT
             SCHI  = SCHI+TI2*WGT
             AVGI  = SI/SWGT
             CHI2A = ZERO
             IF(IT .GT. N1 ) CHI2A = (SCHI - SI*AVGI)/(IT-.999)
             SD    = DSQRT(ONE/SWGT)
C
C  -------------------------------------------------------------------
C           Check remaining CPU time for the next iteration
C  -------------------------------------------------------------------
CTI             CALL BSTIME( TIM2, 1 )
                CALL BSTIME( TIM2, 1 )
             TSI   = DSQRT(TSI)
             ITX         = MOD( IT, ITM)
             IF( ITX .EQ. 0 ) ITX = ITM
             ITRAT(ITX)  = IT
             TIME (ITX)  = TIM2
             EFF  (ITX)  = NGOOD/CALLS*HUNDRT
             WRONG(ITX)  = NEGTIV/CALLS*HUNDRT
             RESLT(ITX)  = AVGI
             ACSTD(ITX)  = SD
             TRSLT(ITX)  = TI
             TACC        = ABS(TSI/TI*HUNDRT)
             TSTD (ITX)  = TACC
             PCNT (ITX)  = ABS(SD/AVGI*HUNDRT)
             CALL BSPRNT ( 6, MPRINT, ISTEP, IDUM3, IDUM4 )
*         endif
*#ifdef DEBUG
*         if(id_node.eq.0)C0TIME(ITX)         = TIM2
*#endif
         STIME = TIM2 - TIM0
         UTIME = (TIM2-TIM1)*1.1
         RTIM  = SETIM - TIM2
         IF(RTIM .LE. UTIME) ITOVER = N1
C
C  -------------------------------------------------------------------
C           Check cumulative accuracy and  the iteration number.
C  -------------------------------------------------------------------
*         if( id_node .eq. 0 ) then
             SDAV  = SD/AVGI
             IF((ABS(SDAV) .LE. ACC)) NEND = N1
*#ifdef INTEL
*             call csend(type_flag, NEND, 1*4, all_node, pid )
*         else
*             call crecv( type_flag, NEND, 1*4 )
*#endif
*         endif
*#ifdef NCUBE
*         call nbrdcst(NEND,1*4)
*#elif AP
*         call c2brd(0,NEND,1*4,nrsize)
*#endif
         IF( NEND .EQ. N1 ) GO TO 600
         IF( ISTEP .LE. N0 ) THEN
C  ------------------------------------------------------------------
C          Test Temporary Accuracy  whether it becoms stable.
C  ------------------------------------------------------------------
*             if( id_node .eq. 0 ) then
                 AACC = ABS(TACC-ATACC)/TACC
                 IF( AACC .LE. 0.01) NSU = NSU + N1
                 IF( AACC .GT. 0.01) NSU = N0
                 ATACC = TACC
                 IF( NSU .GT. 3 ) NEND = N1
*#ifdef INTEL
*                 call csend(type_flag, NEND, 1*4, all_node, pid )
*             else
*                 call crecv( type_flag, NEND, 1*4 )
*#endif
*             endif
*#ifdef NCUBE
*             call nbrdcst(NEND,1*4)
*#elif AP
*             call c2brd(0,NEND,1*4,nrsize)
*#endif
C*           debug
C*             print *,'it,nend',id_node,it,nend
             IF( NEND .EQ. N1 ) GO TO 600
C  ------------------------------------------------------------------
C        Smoothing the Distribution D(I,J) and refine the grids
C  ------------------------------------------------------------------
C                -----------
                 CALL BSGDEF
C                -----------
         ENDIF
C --------------------------------------------------------------------
C         Test the Flag NEND ; If NEND = (1/2) = (Time out/ Converge)
C---------------------------------------------------------------------
C
         IF( ITOVER .EQ. N1 ) GO TO 600
C
  500 CONTINUE
      IT    = IT - N1
      NEND  = N1
C
C  ===================================================================
C                   Termination of BASES
C  ===================================================================
C  -------------------------------------------------------------------
C                   Print out
C              Convergency Behavior and result
C  -------------------------------------------------------------------
C
  600 CONTINUE
*      CALL BHSUM
*#ifdef INTEL
*      call gdsum(DXD, NSP, WORK )
*      call gdsum(DXP, NSP, WORK )
*#endif
*#ifdef NCUBE
*      call nglobal()
*#else
*      if( id_node .eq. 0 ) then
*#endif
       CALL BSPRNT( 7, MPRINT, ISTEP, NEND, NDM1 )
*#ifdef NCUBE
*      call nlocal()
*#else
*      endif
*#endif
C
C  -----------------------------------------------------------------
C                     Time out ?
C  -----------------------------------------------------------------
C
      IF( ITOVER .EQ. N1 ) THEN
          IF( ISTEP .GE. N0 ) THEN
              IF( ISTEP .EQ. N0) THEN
                  IFLAG = N2
C                 -----------
                  CALL BSGDEF
C                 -----------
               ENDIF
               IF( ISTEP .EQ. N1) IFLAG = 3
          ENDIF
      ENDIF
C
C -------------------------------------------------------------------
C                      END OF BASES ( Convergence )
C -------------------------------------------------------------------
C
      IF( NEND .EQ. N1 ) THEN
          IF( ISTEP .EQ. N0) THEN
              IFLAG   = N1
          ELSE
              IFLAG   = N0
              ITF     = IT
          ENDIF
      ENDIF
C
      RETURN
      END
      SUBROUTINE BSORDR(VAL, F2, ORDER, IORDR)
C***********************************************************************
C*                                                                     *
C*=============================================                        *
C*    SUBROUTINE BSORDR( VAL, F2, ORDER, IORDR)                        *
C*=============================================                        *
C*((Function))                                                         *
C*    To resolve the real number VAL into mantester and exponent parts.*
C*  When VAL = 1230.0 is given, output are                             *
C*        F2 = 1.2  and ORDER = 4.0.                                   *
C*((Input))                                                            *
C*  VAL  : Real*8 value                                                *
C*((Output))                                                           *
C*  F2   : The upper two digits is given                               *
C*  ORDER: Order is given                                              *
C*  IORDR: Exponent is given                                           *
C*((Author))                                                           *
C*  S.Kawabata                                                         *
C*                                                                     *
C***********************************************************************
      IMPLICIT REAL*8 (A-H,O-Z)
      IF( VAL .NE. 0.0 ) THEN
          ORDER    =  LOG10( VAL )
          IORDR    =  INT( ORDER )
          IF( ORDER .LT. 0.0 ) IORDR = IORDR - 1
          ORDER  = 10.0**IORDR
          F2     = VAL/ORDER
      ELSE
          IORDR  = 0
          ORDER  = 1.0
          F2    = 0.0
      ENDIF
      RETURN
      END
      SUBROUTINE BSPRNT( ID, IP1, IP2, IP3, IP4 )
      IMPLICIT REAL*8 (A-H,O-Z)
      REAL*4 SETIM,UTIME
      PARAMETER (MXDIM = 25, NDMX = 50, LENG = 17000)
      COMMON /BASE0/ SETIM,UTIME,IFLAG,NPRINT
      COMMON /BASE1/ XL(MXDIM),XU(MXDIM),NDIM,NSNG,
     .               IG(MXDIM),NCALL
      COMMON /BASE2/ ACC1,ACC2,ITMX1,ITMX2
      COMMON /BASE3/ SI,SI2,SWGT,SCHI,SCALLS,ATACC,NSU,IT,WGT
      COMMON /BASE4/ XI(NDMX,MXDIM),DX(MXDIM),DXD(LENG),DXP(LENG),
     .               ND,NG,NPG,MA(MXDIM)
      PARAMETER (ITM = 50)
      REAL*4   TIME,EFF,WRONG,TRSLT,TSTD,PCNT
      COMMON /BASE5/ ITRAT(ITM),TIME(ITM),EFF(ITM),WRONG(ITM),
     .       RESLT(ITM),ACSTD(ITM),TRSLT(ITM),TSTD(ITM),PCNT(ITM)
      COMMON /BSRSLT/AVGI,SD,CHI2A,STIME,ITF
      COMMON /LOOP0/ LOOPC,IRCODE
      COMMON /LOOP1/ LOOP,MXLOOP
      CHARACTER*51 ICH(2)
*     IPRNT = ( 0 / Any others ) = FACOM / UNIX
      INTEGER UNIX
      COMMON /BSCNTL/ UNIX,NLOOP,MLOOP
C
      DATA  N1 /1/
      DATA  ICH / 'Convergency Behavior for the Grid Optimization Step',
     .            'Convergency Behavior for the Integration Step      '/
*
      GO TO ( 100, 200, 300, 400, 500, 600, 700 ), ID
C----------------------------------------------------------- BSMAIN
  100       MNLOOP = IP1
            MXLOOP = IP2
            IF( UNIX .EQ. 0 ) WRITE(6,9600)
            WRITE(6,9100) MNLOOP,MXLOOP,NPRINT,IFLAG,SETIM
 9100       FORMAT(22X,
     .            '*************************************',
     .       /22X,'*   Input Parameters for this JOB   *',
     .       /22X,'*                                   *',
     .       /22X,'*  Current Loop Count =',I12     ,' *',
     .       /22X,'*  Maximum Loop Count =',I12     ,' *',
     .       /22X,'*  Print Flag         =',I12     ,' *',
     .       /22X,'*  JOB Input Flag     =',I12     ,' *',
C    .       /22X,'*  CPU Time Limit     =',F12.3   ,' *',
     .       /22X,'*  CPU Time Limit     =',E12.4   ,' *',
     .       /22X,'*                                   *',
     .       /22X,'*************************************')
          RETURN
C----------------------------------------------------------- BSMAIN
  200     IF( UNIX .EQ. 0 ) WRITE(6,9600)
          WRITE(6,9200)  LOOP, IFLAG
 9200     FORMAT(/1H1,20X,
     .            '****** CPU Time out  *********',
     .       /21X,'  Next Loop Count =',I5,
     .       /21X,'  Next Input Flag =',I5)
          RETURN
C----------------------------------------------------------- BSMAIN
  300     IF( UNIX .EQ. 0 ) WRITE(6,9600)
          WRITE(6,9300)  MXLOOP
 9300     FORMAT(20X,
     .         '****** END OF BASES LOOP *********',
     .    /21X,'  MAX. LOOP COUNT =',I5)
          RETURN
C----------------------------------------------------------- BASES
  400     MCALL = IP1
              WRITE(6,9400)  NDIM,NSNG,ITMX1,ITMX2,ACC1,ACC2,
     .                       MCALL,NG,ND
 9400         FORMAT(//20X,
     .             '******************************************',
     .        /20X,'*    INPUT PARAMETERS FOR BASES          *',
     .        /20X,'*                                        *',
     .        /20X,'* NDIM  =',I9,   '  NSNG  =',I9,   '     *',
     .        /20X,'* ITMX1 =',I9,   '  ITMX2 =',I9,   '     *',
     .        /20X,'* ACC1  = ',G9.3, ' ACC2  = ',G9.3, '    *',
     .        /20X,'* NCALL =',I9,   '                       *',
     .        /20X,'* NG    =',I9,   '  ND    =',I9,   '     *')
              DO 450 I = 1,NDIM
                 WRITE(6,9420) I,XL(I),I,XU(I),I,IG(I)
 9420            FORMAT(20X,
     .                '* XL(',I3,' )= ',G15.6,   '              *',
     .           /20X,'* XU(',I3,' )= ',G15.6,      ' IG(',
     .                                           I3,' )= ',I2,' *')
  450         CONTINUE
              WRITE(6,9450)
 9450         FORMAT(20X,
     .             '*                                        *',
     .        /20X,'******************************************')
          RETURN
C----------------------------------------------------------- BASES
  500     CONTINUE
C- AJF EDITED THIS OUT 11/8/92 IF( UNIX .EQ. 0 )    RETURN
          MPRINT = IP1
          ISTEP  = IP2
          IF( MPRINT. GE. 4 .OR.
     .      ( MPRINT .GE. 3 .AND. ISTEP .EQ. N1)) THEN
              IFJ  = MOD( IFLAG, 2) + 1
              WRITE(6,9500) ICH(IFJ)
 9500         FORMAT(15X,A)
              WRITE(6,9570)
              WRITE(6,9550)
 9550         FORMAT(1X,'<-  Result of  an iteration  ->',
     .               2X,'<-     Cumulative Result     ->',
     .               1X,'< CPU  time >',
     .              /1X,' IT Eff R_Neg   Estimate  Acc %',
     .               2X,'Estimate(+- Error )order  Acc %',
     .               1X,'( H: M: Sec )')
              WRITE(6,9570)
 9570         FORMAT(1X,7('----------'),'--------')
          ENDIF
          RETURN
C----------------------------------------------------------- BASES
  600    CONTINUE
C IF( UNIX .EQ. 0 ) RETURN
          MPRINT = IP1
          ISTEP  = IP2
          IF( MPRINT. GE. 4 .OR.
     .      ( MPRINT .GE. 3 .AND. ISTEP .EQ. N1)) THEN
              ITX = MOD( IT, ITM)
              IF( ITX .EQ. 0 ) ITX = ITM
              CALL BSLIST( ITX )
          ENDIF
          RETURN
C----------------------------------------------------------- BASES
  700    MPRINT = IP1
         ISTEP  = IP2
         NEND   = IP3
         NDM1   = IP4
         ITX  = MOD( IT, ITM )
         IF( ITX .EQ. 0 ) ITX = ITM
         IF( MPRINT. GE. 4 .OR.
     .     ( MPRINT .GE. 3 .AND. ISTEP .EQ. N1)) THEN
             IF( UNIX .EQ. 0 ) THEN
                 IF( ITRAT(1) .EQ. 1 ) THEN
                     NDEV   = 1
                 ELSE
                     NDEV   = 2
                     ITFN   = ITM
                     ITMN   = 10000
                     DO 610 I = 1,ITM
                        IF( ITRAT(I) .LT. ITMN ) THEN
                            ITST = I
                            ITMN = ITRAT(I)
                        ENDIF
  610                CONTINUE
                     IF( ITST .EQ. 1 ) NDEV = 1
                 ENDIF
                 WRITE(6,9600)
 9600            FORMAT(/1H1,//1H )
                 IFJ  = MOD( IFLAG, 2) + 1
                 WRITE(6,9500) ICH(IFJ)
                 WRITE(6,9570)
                 WRITE(6,9550)
                 WRITE(6,9570)
C
  625            IF( NDEV .EQ. 1 ) THEN
                     ITST = 1
                     ITFN = ITX
                 ENDIF
                 DO 650 I = ITST, ITFN
                    CALL BSLIST( I )
  650            CONTINUE
                 NDEV  = NDEV - 1
                 IF( NDEV .GT. 0 ) GO TO 625
                 WRITE(6,9570)
            ELSE
                 WRITE(6,9570)
            ENDIF
         ENDIF
C  -------------------------------------------------------------------
C                      Print out the result
C  -------------------------------------------------------------------
         IF( (MPRINT .GT. 0 .AND. MPRINT .LE. 2) .AND.
     .       ISTEP .EQ. N1 .AND. NEND .EQ. N1 ) THEN
            IF(  NDIM .NE. NDM1 ) THEN
               IF( UNIX .EQ. 0 ) WRITE(6,9600)
               WRITE(6,9650)
 9650          FORMAT(
     .             15X,'Results of Integration',
     .            /10X,'+----+-----------+-----------+',
     .                 '-----------+-----------+-----+',
     .            /10X,'|Loop|  Estimate |  St-Dev.  |',
     .                 ' Chi**2/IT |  CPU Time |  IT |',
     .            /10X,'+----+-----------+-----------+',
     .                 '-----------+-----------+-----+')
               IP4   = NDIM
            ENDIF
            WRITE(6,9660) LOOPC,AVGI,SD,CHI2A,STIME,IT
 9660       FORMAT(10X,'|',I3,' |',4(G10.4,' |'),I4,' |',
     .            /10X,'+----+-----------+-----------+',
     .                 '-----------+-----------+-----+')
         ENDIF
C
         IF( MPRINT .GE. 5 .OR.
     .     ( MPRINT .GE. 3 .AND. ISTEP.EQ. N1 ) .OR.
     .     ( MPRINT .EQ. 2 .AND. ISTEP.EQ. N1 .AND. NEND .EQ. N1 )) THEN
C            -----------
             CALL BHPLOT
C            -----------
         ENDIF
      RETURN
      END
      SUBROUTINE BSLIST( I )
      IMPLICIT REAL*8 (A-H,O-Z)
      PARAMETER (ITM = 50)
      REAL*4   TIME,EFF,WRONG,TRSLT,TSTD,PCNT
      COMMON /BASE5/ ITRAT(ITM),TIME(ITM),EFF(ITM),WRONG(ITM),
     .       RESLT(ITM),ACSTD(ITM),TRSLT(ITM),TSTD(ITM),PCNT(ITM)
      INTEGER  HOUR
      DATA HOUR, MINUT, N100/ 360000, 6000, 100 /
      ISEC  = TIME(I)*N100
      IH    = 0
      MN    = IH
      IF( ISEC .GE. MINUT ) THEN
          ITIME = ISEC
          IF( ISEC .GE. HOUR ) THEN
              IH    = ITIME/HOUR
              IHX   = IH*HOUR
              ITIME = ITIME - IHX
              ISEC  = ISEC - IHX
          ENDIF
          MN    = ITIME/MINUT
          ISEC  = ISEC - MN*MINUT
      ENDIF
      IS1  = ISEC/N100
      IS2  = MOD( ISEC, N100)
      RE  = RESLT(I)
      AC  = ABS(ACSTD(I))
      ARE = ABS(RE)
      IF( ARE .GE. AC) THEN
          CALL BSORDR( ARE, F2, ORDER, IORDR)
      ELSE
          CALL BSORDR(  AC, F2, ORDER, IORDR )
      ENDIF
      RE  = RE/ORDER
      AC  = AC/ORDER
      IEFF = EFF(I)
      WRITE(6,9631) ITRAT(I),IEFF,WRONG(I),TRSLT(I),TSTD(I),
     .              RE,AC,IORDR,PCNT(I),IH,MN,IS1,IS2
 9631 FORMAT(I4,I4,F6.2,1P,E11.3, 0P,1X,F6.3,
     .              F10.6,'(+-',F8.6,')E',I3.2,1X,F6.3,
     .          1X,I3,':',I2,':',I2,'.',I2.2)
C     WRITE(6,9631) ITRAT(I),IH,MN,IS1,IS2,IEFF,WRONG(I),
C    .              RE,AC,IORDR,
C    .              TRSLT(I),TSTD(I),PCNT(I)
C9631 FORMAT(I4,1X,I3,':',I2.2,':',I2.2,'.',I2.2,I4,F6.2,
C    .              F10.6,'(+-',F8.6,')E',I3.2,
C    .       1P,E11.3, 0P,2(1X,F6.3))
      RETURN
      END
      SUBROUTINE BSGDEF
C***********************************************************************
C*                                                                     *
C*========================                                             *
C*    SUBROUTINE BSGDEF                                                *
C*========================                                             *
C*((Function))                                                         *
C*    Refine the grid sizes                                            *
C*                                                                     *
C*    Coded   by S.Kawabata    Aug. 1984 at Nagoya Univ.               *
C*    Last update              Oct. 1985 at KEK                        *
C*                                                                     *
C***********************************************************************
C
C
      IMPLICIT REAL*8 (A-H,O-Z)
      PARAMETER (MXDIM = 25, NDMX = 50, LENG = 17000)
      COMMON /BASE1/ XL(MXDIM),XU(MXDIM),NDIM,NSNG,
     .               IG(MXDIM),NCALL
      COMMON /BASE4/ XI(NDMX,MXDIM),DX(MXDIM),DXD(LENG),DXP(LENG),
     .               ND,NG,NPG,MA(MXDIM)
      COMMON /BASE6/ D(NDMX,MXDIM)
      DIMENSION  XIN(NDMX),R(NDMX),DT(MXDIM)
      DATA ALPH / 1.5 /,ONE/1.0/,ZERO/0.0/,N0/0/,N1/1/
C
C======= SMOOTHING THE FUNCTION D(I,J)
C
        CLOGE   = 1.0D0/LOG(10.0D0)
        NDM     = ND-1
        DO 780 J= N1,NDIM
         IF( IG(J) .EQ. 1 ) THEN
          XO    = D(1,J)
          XN    = D(2,J)
          D(1,J)= (XO+XN)/2.
          DT(J) = D(1,J)
          DO 710 I=2,NDM
            D(I,J)= XO+XN
            XO    = XN
            XN    = D(I+N1,J)
            D(I,J)= (D(I,J)+XN)/3.
            DT(J) = DT(J)+D(I,J)
  710     CONTINUE
          D(ND,J) = 0.5*(XN+XO)
          DT(J)   = DT(J)+D(ND,J)
C
C=========== REDEFINE THE GRID
C
          DTLOG   = LOG(DT(J))
          DT10    = CLOGE*DTLOG
          RC    = ZERO
          DO 730 I= N1,ND
            R(I)  = ZERO
            IF(D(I,J) .GT. ZERO) THEN
               DILOG = LOG(D(I,J))
               IF( DT10 - CLOGE*DILOG  .LE. 70.0 ) THEN
                   XO    = DT(J)/D(I,J)
                   R(I)  = ((XO-ONE)/(XO*(DTLOG-DILOG)))**ALPH
               ELSE
                   XO    = DT(J)/D(I,J)
                   R(I)  = (DTLOG-DILOG)**(-ALPH)
               ENDIF
            ENDIF
            RC    = RC+R(I)
  730     CONTINUE
          RC    = RC/ND
          K     = N0
          XN    = N0
          DR    = XN
          I     = K
  740  K     = K + N1
          DR    = DR+R(K)
          XO    = XN
          XN    = XI(K,J)
  750 IF(RC.GT.DR)GO TO 740
          I     = I + N1
          DR    = DR-RC
          XIN(I)= XN-(XN-XO)*DR/R(K)
      IF(I.LT.NDM)GO TO 750
          DO 760 I= N1,NDM
            XI(I,J)= XIN(I)
  760     CONTINUE
          XI(ND,J)= ONE
         ENDIF
  780   CONTINUE
C
      RETURN
      END
      SUBROUTINE BSINIT
C***********************************************************************
C*                                                                     *
C*========================                                             *
C*    SUBROUTINE BSINIT                                                *
C*========================                                             *
C*((Function))                                                         *
C*     Initialization of Bases progam                                  *
C*     This is called only when IFLAG=0.                               *
C*     ( IFLAG = 0 ; First Trial of Defining Grid step )               *
C*                                                                     *
C*    Changed by S.Kawabata    Aug. 1984 at Nagoya Univ.               *
C*    Last update              Oct. 1985 at KEK                        *
C*                                                                     *
C***********************************************************************
C
      IMPLICIT REAL*8 (A-H,O-Z)
      PARAMETER (MXDIM = 25, NDMX = 50, LENG = 17000)
      COMMON /BASE1/ XL(MXDIM),XU(MXDIM),NDIM,NSNG,
     .               IG(MXDIM),NCALL
      COMMON /BASE3/ SI,SI2,SWGT,SCHI,SCALLS,ATACC,NSU,IT
      COMMON /BASE4/ XI(NDMX,MXDIM),DX(MXDIM),DXD(LENG),DXP(LENG),
     .               ND,NG,NPG,MA(MXDIM)
      DIMENSION  XIN(NDMX)
      DATA  ONE/ 1.0/
C
C---------------------------------------------------------------
C           Set initial seeds of random number generator
C---------------------------------------------------------------
CAJF REMOVED ISEED= 12345
C
CAJF REMOVED     CALL DRNSET( ISEED )
C
C---------------------------------------------------------------
C           Define the number of grids and sub-regions
C---------------------------------------------------------------
C==> Determine NG : Number of grids
          NG    = (NCALL/2.)**(1./NSNG)
         IF(NG .GT. 25) NG  = 25
  100    IF(NG .LT.  2) NG  =  1
         IF(NG**NSNG .GT. LENG) THEN
            NG  = NG - 1
            GO TO 100
         ENDIF
C
C==> Determine ND : Number of sub-regions
          M     = NDMX/NG
          ND    = M*NG
C
C==> Determine NPG: Number of sampling points per subhypercube
          NSP   = NG**NSNG
          NPG   = NCALL/NSP
          XI(1,1)= ONE
          MA(1)  = 1
          DX(1)  = XU(1)-XL(1)
          IF( NDIM .GT. 1 ) THEN
              DO 130 J = 2,NDIM
                 XI(1,J)= ONE
                 DX(J)  = XU(J)-XL(J)
                 IF( J .LE. NSNG ) THEN
                    MA(J)  = NG*MA(J-1)
                 ENDIF
  130         CONTINUE
          ENDIF
C
C---------------------------------------------------------------
C           Set size of subregions uniform
C---------------------------------------------------------------
          NDM   = ND-1
          RC    = ONE/ND
          DO 155 J =1,NDIM
             K     = 0
             XN    = 0.
             DR    = XN
             I     = K
  140        K     = K+1
             DR    = DR+ONE
             XO    = XN
             XN    = XI(K,J)
  145       IF(RC .GT. DR) GO TO 140
             I     = I+1
             DR    = DR-RC
             XIN(I)= XN-(XN-XO)*DR
            IF(I .LT. NDM) GO TO 145
             DO 150 I  = 1,NDM
                XI(I,J)= XIN(I)
  150        CONTINUE
             XI(ND,J)  = ONE
  155     CONTINUE
C
      RETURN
      END
C
      SUBROUTINE BSMAIN( FXN )
C***********************************************************************
C*========================                                             *
C* SUBROUTINE BSMAIN(FXN)                                              *
C*========================                                             *
C*        Main Program for the Integration progam BASES, which         *
C*     is new version of VEGAS.                                        *
C*     In terms of this program Integration can be done, furthermore   *
C*     a probability distribution can be made for the event generation.*
C*     The event geration is done by program SPRING.                   *
C*     For running BASES, there are four options.                      *
C*         IFLAG =  0 : First trial for defining grids.                *
C*         IFLAG =  1 : First trial for event accumulation.            *
C*         IFLAG =  2 : Second or more trial for defining grids.       *
C*         IFLAG =  3 : Second or more trial for accumulation.         *
C*                                                                     *
C*((Input)) from Unit 5 as card image                                  *
C*     NLOOP, MLOOP          Current loop count, Maximum loop count    *
C*     NPRINT                print option flag                         *
C*     IFLAG                 BASES input flag                          *
C*     SETIME                CPU time limit in minute                  *
C*      At the end of job, the job termination code is given, if it    *
C*      terminates by time limit. For the next submission the next     *
C*      loop count and input flag shuld be given.                      *
C*     NDIM  : Dimension of the integration                            *
C*     NTRIAL: Number of sampling points per cube. normally 2.         *
C*     ITMX* : Number of iteration                                     *
C*     ACC*  : Required accuracies                                     *
C*     XL(10): Lower limits of the integration variabels               *
C*     XU(10): upper limits of the integration variabels               *
C*                                                                     *
C*       Coded by S.Kawabata         May '85                           *
C*       Changed for Intel           Nov.'91                           *
C*       Changed for nCUBE,AP1000    Dec.'91                           *
C*                                                                     *
C*       Directive name for preprocessor  (cpp)                        *
C*       INTEL, AP, NCUBE                                              *
C*       without name, a source for a single CPU machine will be       *
C*       generated.                                                    *
C***********************************************************************
C
      IMPLICIT REAL*8 (A-H,O-Z)
      EXTERNAL FXN
      REAL*4 SETIM,TIME,RTIME,UTIME
      PARAMETER (MXDIM = 25)
      COMMON /BASE0/ SETIM,UTIME,IFLAG,NPRINT
      COMMON /BASE1/ XL(MXDIM),XU(MXDIM),NDIM,NSNG,
     .               IG(MXDIM),NCALL
      COMMON /BASE2/ ACC1,ACC2,ITMX1,ITMX2
      COMMON /LOOP0/ LOOPC,IRCODE
      COMMON /LOOP1/ LOOP,MXLOOP
      COMMON /XHCNTL/ LOCK
      INTEGER UNIX
      COMMON /BSCNTL/ UNIX, NLOOP, MLOOP
*      INTEGER LOOPX(2)
*      integer id_node, pid, no_node, all_node
*      integer type_time, type_flag, type_loop, type_data, type_hist
*      COMMON/NINFO/ id_node, pid, no_node, all_node,
*     .              type_time, type_flag, type_loop, type_data,
*     .              type_hist
*#ifdef DEBUG
C*monitor by T.ISHIKAWA
*      REAL*4 WTIME
*      REAL*4 C0TIME
*      COMMON/MONITR/ MNGOOD(512,100),C0TIME(100)
*      INTEGER IWORK(512)
*#endif
C*
*      type_time = 1
*      type_flag = 2
*      type_loop = 3
*      type_data = 4
*      type_hist = 5
C
*#ifdef INTEL
*      id_node  = mynode()
*      pid      = mypid()
*      no_node  = numnodes()
*      all_node = -1
*#elif AP
*      call cgcid(id_node)
*      call cgtid(pid)
*      call cgncl(no_node)
*#elif NCUBE
*      id_node  = mynode()
*      pid      = mypid()
*      no_node  = nnodes()
*#else
C**** for single CPU machine.
*      id_node  = 0
*      pid      = 0
*      no_node  = 1
*#endif
C
*#ifdef DEBUG
*      do 9871 iiii=1,100
*      do 9871 kkkk=1,512
*        mngood(kkkk,iiii) =0
* 9871 continue
*#endif
C
C      UNIX  = 0
C
C ---------------------------------------------------------------
C          Initialize timer
C ---------------------------------------------------------------
C
C by TI. reset timer for all nodes
C
      CALL BSTIME( TIME, 0 )
*#ifdef INTEL
*
*      if( id_node .eq. 0 ) then
*
*         call csend( type_time,TIME, 1*4, all_node, pid)
*
*      else
*
*         call crecv( type_time, TIME, 1*4 )
*
*      endif
*#elif NCUBE
*      call nbrdcst(TIME,1*4)
*#elif AP
*      call c2brd(0,TIME,1*4,nrsize)
*#endif
C
C ---------------------------------------------------------------
C          Set BASES parameters equal to default values
C ---------------------------------------------------------------
C
       LOCK   =  0
C       NDIM   = -1
       NSNG   =  1
C       ITMX1  = 15
C       ITMX2  = 100
C       NCALL  = 1000
C       ACC1   = 0.2
C       ACC2   = 0.01
       DO 100 J = 1,MXDIM
          IG(J) = 1
  100  CONTINUE
C
*#ifdef INTEL
*      if( id_node .eq. 0 ) then
C
C          READ( 5, * ) NLOOP, MLOOP
*          LOOPX(1) = NLOOP
*          LOOPX(2) = MLOOP
*
*          call csend( type_time,LOOPX, 2*4, all_node, pid)
*
*      else
*
*          call crecv( type_time, LOOPX, 2*4 )
*
*          NLOOP = LOOPX(1)
*          MLOOP = LOOPX(2)
*
*      endif
*#elif AP
*      NLOOP = 1
*      MLOOP = 1
*#elif NCUBE
*      call nglobal()
*      READ( 5, * ) NLOOP, MLOOP
*      call nlocal()
*#else
*      READ( 5, * ) NLOOP, MLOOP
*#endif
*
CTI      write(6,*) id_node, NLOOP, MLOOP
*
*#ifdef INTEL
*      if( id_node .eq. 0 ) then
C          READ( 5, * ) NPRINT
*          call csend( type_time,NPRINT, 1*4 , all_node, pid)
*      else
*
*          call crecv( type_time,NPRINT, 1*4 )
*      endif
*#elif AP
*      NPRINT = 4
*#elif NCUBE
*      call nglobal()
*      READ( 5, * ) NPRINT
*      call nlocal()
*#else
*      READ( 5, * ) NPRINT
*#endif
*
CTI      write(6,*) ' NPRINT = ',id_node,NPRINT
*
*#ifdef INTEL
*      if( id_node .eq. 0 ) then
*
C          READ( 5, * ) IFLAG
*          call csend( type_time,IFLAG, 1*4 , all_node, pid)
*      else
*
*          call crecv( type_time, IFLAG, 1*4 )
*
*      endif
*#elif AP
*      IFLAG = 0
*#elif NCUBE
*      call nglobal()
*      READ( 5, * ) IFLAG
*      call nlocal()
*#else
*      READ( 5, * ) IFLAG
*#endif
*
CTI      write(6,*) ' IFLAG = ',id_node,IFLAG
*
*#ifdef INTEL
*      if( id_node .eq. 0 ) then
*
C          READ( 5, * ) SETIM
*
*          call csend( type_time,SETIM, 1*4, all_node, pid)
*
*      else
*
*          call crecv( type_time, SETIM, 1*4 )
*
*      endif
*#elif AP
*      SETIM = 1000000.
*#elif NCUBE
*      call nglobal()
*      READ( 5, * ) SETIM
*      call nlocal()
*#else
*      READ( 5, * ) SETIM
*#endif
*
CTI      write(6,*) ' SETIM = ',id_node,SETIM
*
C
       IF(   IFLAG .EQ.   0 ) THEN
               IF( NLOOP .LE. 0 ) THEN
*#ifdef NCUBE
*                 call nglobal()
*#else
*                 if( id_node .eq. 0 ) then
*#endif
                   WRITE(6,9000) NLOOP
 9000              FORMAT(1X,'*** Illegal LOOP count (',I3,' ) ***')
*#ifdef NCUBE
*                 call nlocal()
*#else
*                 endif
*#endif
                   STOP
               ENDIF
               MNLOOP = NLOOP
               MXLOOP = MLOOP
               LOOPC  = NLOOP
               CALL BSUSRI
       ELSEIF( IFLAG .GT. 0 ) THEN
C         Read Temporary Result from Disk File
C                   -----------
                    CALL BSREAD
C                   -----------
                    MNLOOP = LOOP
                    LOOPC  = LOOP
                    LOCK   = 1
                    CALL BSUSRI
                    LOCK   = 0
       ELSE
               WRITE(6,9100) IFLAG
 9100          FORMAT(1X,'***** ILLEGAL INPUT IFAG (',I3,' ) *****')
           STOP
       ENDIF
C
*#ifdef NCUBE
*       call nglobal()
*#else
*       if( id_node .eq. 0 ) then
*#endif
            CALL BSPRNT( 1, MNLOOP, MXLOOP, IDUM3, IDUM4 )
*#ifdef NCUBE
*       call nlocal()
*#else
*       endif
*#endif
       SETIM  = SETIM*60.0 - 5.
C
C
       DO 5000 LOOP = MNLOOP, MXLOOP
C
C  -----------------------------------------------------
C     Defining grids or just for integration
C  -----------------------------------------------------
             IF( IFLAG .LE. 0 .OR. IFLAG .EQ. 2 ) THEN
C
                 CALL BASES( FXN )
*#ifdef INTEL
*                 if( id_node .eq. 0 ) then
*                     call csend( type_time,IFLAG, 1*4, all_node, pid)
*
*                 else
*
*                     call crecv( type_time, IFLAG, 1*4 )
*
*                 endif
*#elif AP
*                 call c2brd(0,IFLAG,1*4,nrsize)
*#elif NCUBE
*                 call nbrdcst(IFLAG,1*4)
*#endif
C
                 IF(IFLAG.NE.1) GO TO 7000
C
*#ifdef INTEL
C by TI. syncronization:
C        LED(1) --> green led on
*                 call led(1)
*                 call gsync()
*#endif
C
                 CALL BSTIME( TIME, 1 )
C                 if( id_node .eq. 0 ) then
C
C#ifdef INTEL
C                     call csend( type_time,TIME, 1*4, all_node, pid)
C
C                 else
C
C                     call crecv( type_time, TIME, 1*4 )
C#endif
C                 endif
*#ifdef INTEL
*                 call gshigh(TIME,1,WTIME)
*#elif NCUBE
*                 call nbrdcst(TIME,1*4)
*                 TIMECL = TIME
*                 call c2fmax(TIMECL,id_node,TIME,max_id,ir)
*#elif AP
*                 call c2brd(0,TIME,1*4,nrsize)
*#endif
                 RTIME = SETIM - TIME
                 IF(RTIME .LT. UTIME ) GO TO 7000
             ENDIF
*#ifdef DEBUG
*             do 9887 iiii = 1 , itmx1
*             call gisum( mngood(1,iiii) , no_node , iwork)
*               if( id_node.eq.0 ) then
*                 write(6,9889) iiii,c0time(iiii),
*     &           (mngood(kkkk,iiii),kkkk=1,no_node)
*               endif
* 9887        continue
* 9889          format(1H ,I2,1X,F9.2,1X,64I4)
*      if( id_node .eq. 0 ) then
*      do 9873 iiii=1,itmx1-1
* 9873 print *,c0time(iiii+1)-c0time(iiii)
*      endif
*      do 9872 iiii=1,100
*      do 9872 kkkk=1,512
*        mngood(kkkk,iiii) =0
* 9872 continue
*#endif
C
C  ----------------------------------------------------
C     Accumulation to make probability distribution
C  ----------------------------------------------------
C
             CALL BASES( FXN )
C
*#ifdef DEBUG
*             do 9888 iiii = 1 , itmx2
*                 call gisum( mngood(1,iiii) , no_node , iwork)
*               if( id_node.eq.0 ) then
*                 write(6,9889) iiii,c0time(iiii),
*     &           (mngood(kkkk,iiii),kkkk=1,no_node)
*               endif
* 9888        continue
*      if( id_node .eq. 0 ) then
*      do 9870 iiii=1,itmx1-1
* 9870 print *,c0time(iiii+1)-c0time(iiii)
*      endif
*#endif
C
*#ifdef INTEL
*             if( id_node .eq. 0 ) then
*
*                 call csend( type_time,IFLAG, 1*4, all_node, pid)
*
*             else
*
*                 call crecv( type_time, IFLAG, 1*4 )
*
*             endif
*#elif NCUBE
*             call nbrdcst(IFLAG,1*4)
*#elif AP
*             call c2brd(0,IFLAG,1*4,nrsize)
*#endif
             IF( IFLAG .NE. 0 ) GO TO 7000
C
*             if( id_node .eq. 0 ) then
               IF( NPRINT .LE. 0 )  CALL USROUT
*             endif
C
*#ifdef INTEL
*             call gsync()
*#endif
             CALL BSTIME( TIME, 1 )
             RTIME = SETIM - TIME
             IF(LOOP .EQ. MXLOOP ) GO TO 8000
*#ifdef INTEL
*             if( id_node .eq. 0 ) then
*                 call csend( type_time,UTIME, 1*4, all_node, pid)
*             else
*                 call crecv( type_time, UTIME, 1*4 )
*             endif
*#elif NCUBE
*             call nbrdcst(UTIME,1*4)
*#elif AP
*             call c2brd(0,UTIME,1*4,nrsize)
*#endif
             IF(RTIME .LT. UTIME ) GO TO 6000
             LOOPC = LOOP + 1
             CALL BSUSRI
 5000  CONTINUE
C
       GO TO 8000
C
 6000  LOOP  = LOOP + 1
C
 7000 CONTINUE
*#ifdef NCUBE
*      call nglobal()
*#else
*      if( id_node .eq. 0 ) then
*#endif
          CALL BSPRNT(2, IDUM1, IDUM2, IDUM3, IDUM4 )
*#ifdef NCUBE
*      call nlocal()
*#else
*      endif
*#endif
       GO TO 8500
C
 8000 CONTINUE
*#ifdef NCUBE
*      call nglobal()
*#else
*      if( id_node .eq. 0 ) then
*#endif
          CALL BSPRNT ( 3, IDUM1, IDUM2, IDUM3, IDUM4 )
*#ifdef NCUBE
*      call nlocal()
*#else
*      endif
*#endif
 8500 CONTINUE
*#ifndef AP
*      if( id_node .eq. 0 ) then
         CALL BSWRIT
*      endif
*#endif
      RETURN
      END
      SUBROUTINE BATIME( TIME, IFLG )
C***********************************************************************
C*=================================                                    *
C* SUBROUTINE BSTIME( TIME, IFLG )                                     *
C*=================================                                    *
C*((Purpose))                                                          *
C*        Interface routine to get used CPU time from FORTRAN          *
C*        Library routine CLOCK etc.                                   *
C*((Input))                                                            *
C*        IFLG  : Flag                                                 *
C*          IFLG = 0 : Initialization of clock routine.                *
C*          IFLG = 1 : Get used CPU time.                              *
C*((Output))                                                           *
C*        TIME  : Used CPU time in second.                             *
C*                                                                     *
C*       Coded by S.Kawabata        Oct. '85                           *
C*                                                                     *
C***********************************************************************
C
      IF( IFLG .NE. 0 ) THEN
C                                 FACOM Only
          CALL CLOCK( TIME, 0, 1 )
C                                 HITAC Only
C         CALL CLOCK( TIME, 5 )
C
C     ELSE
C                                 HITAC Only
C         CALL CLOCK
C
      ENDIF
C
      RETURN
      END
      SUBROUTINE BsTIME( TIME, IFLG )
C***********************************************************************
C*=================================                                    *
C* SUBROUTINE BSTIME( TIME, IFLG )                                     *
C*=================================                                    *
C*((Purpose))                                                          *
C*        Interface routine to get used CPU time from FORTRAN          *
C*        Library routine TIMAX etc.                                   *
C*        replace by TIMEX  BBL august 1999
C*((Input))                                                            *
C*        IFLG  : Flag                                                 *
C*          IFLG = 0 : Initialization of clock routine.                *
C*          IFLG = 1 : Get used CPU time.                              *
C*((Output))                                                           *
C*        TIME  : Used CPU time in second.                             *
C***********************************************************************
      IF( IFLG .NE. 0 ) THEN
C
         CALL TIMEX(TIME2)
         TIME = TIME2-TIME1
      ELSE
         CALL TIMEX(TIME1)
      ENDIF
C
      RETURN
      END
      SUBROUTINE BSUSRI
C***********************************************************************
C*===================                                                  *
C* SUBROUTINE BSUSRI                                                   *
C*===================                                                  *
C*((Purpose))                                                          *
C*        Call USERIN and check user's initialization parameters.      *
C*                                                                     *
C*       Coded by S.Kawabata        Oct. '85                           *
C*                                                                     *
C***********************************************************************
C
      IMPLICIT REAL*8 (A-H,O-Z)
      PARAMETER ( MXDIM = 25)
      COMMON /BASE1/ XL(MXDIM),XU(MXDIM),NDIM,NSNG,
     .               IG(MXDIM),NCALL
      COMMON /LOOP0/ LOOPC,IRCODE
C*  Initialization of Histogram buffer (for default )
      PARAMETER (NHIST = 10, NSCAT = 5 )
      COMMON /PLOTB/ IBUF( 281*NHIST + 2527*NSCAT + 281 )
      CALL BHINIT( NHIST, NSCAT )
C
      DO 100 I = 1,MXDIM
         XU(I)  = -10000.0D0
  100 CONTINUE
C
      CALL USERIN
C
      IF( NDIM .LT. 1) THEN
          WRITE(6,9200)
 9200     FORMAT(1X,'Error in USERIN; NDIM was not set.')
          STOP
      ENDIF
      DO 200 I = 1,NDIM
         IF( XU(I) .LE. -10000.0) THEN
             WRITE(6,9400) I,I
 9400        FORMAT(1X,'Error in USERIN; XL(',I2,
     .                '), XU(',I2,') were not set.')
             STOP
         ENDIF
  200 CONTINUE
C
      IF( NSNG .LT.   0) THEN
          NSNG = MIN( NDIM, 10)
      ELSE
     .IF( NSNG .GT. 10) THEN
          WRITE(6,9500) NSNG
 9500     FORMAT(1X,'Error in USERIN; Too large NSNG',
     .              /1X,'NSNG must be less than 11 ||')
          STOP
      ENDIF
C
      RETURN
      END
      SUBROUTINE ARNSET( ISEED )
C**********************************************************************
C*============================                                        *
C* Subroutine DRNSET( ISEED )                                         *
C*============================                                        *
C*((Purpose))                                                         *
C*  Initialization routine of                                         *
C*         Machine-independent Random number generator                *
C*         General purpose Version,  OK as long as >= 32 bits         *
C*((Arguement))                                                       *
C*  ISEED: SEED                                                       *
C*                                                                    *
C**********************************************************************
      COMMON/RANDM/RDM(31),RM1,RM2,IA1,IC1,M1,IX1,
     .                             IA2,IC2,M2,IX2,
     .                             IA3,IC3,M3,IX3
      IA1 =    1279
      IC1 =  351762
      M1  = 1664557
      IA2 =    2011
      IC2 =  221592
      M2  = 1048583
      IA3 =   15091
      IC3 =    6171
      M3  =   29201
C Initialization
      IX1  = MOD( ISEED, M1 )
      IX1  = MOD( IA1*IX1+IC1, M1 )
      IX2  = MOD( IX1, M2 )
      IX1  = MOD( IA1*IX1+IC1, M1 )
      IX3  = MOD( IX1,M3)
      RM1  = 1./FLOAT(M1)
      RM2  = 1./FLOAT(M2)
      DO 100 J = 1,31
         IX1   = MOD( IA1*IX1+IC1, M1 )
         IX2   = MOD( IA2*IX2+IC2, M2 )
         RDM(J)= ( FLOAT(IX1)+FLOAT(IX2)*RM2 )*RM1
  100 CONTINUE
      RETURN
      END
      SUBROUTINE DRNSET( ISEED )
C**********************************************************************
C*============================                                        *
C* Subroutine DRNSET( ISEED )                                         *
C*============================                                        *
C*((Purpose))                                                         *
C*  Initialization routine of                                         *
C*         Machine-independent Random number generator                *
C*         General purpose Version,  OK as long as >= 32 bits         *
C*((Arguement))                                                       *
C*  ISEED: SEED                                                       *
C*                                                                    *
C**********************************************************************
      CALL RDMIN(ISEED)
      RETURN
      END
      REAL*8 FUNCTION ARN(ISEED)
C**********************************************************************
C*======================                                              *
C* FUNCTION DRN( ISEED)                                               *
C*======================                                              *
C*  Machine-independent Random number generator                       *
C*     General purpose Version,  OK as long as >= 32 bits             *
C*((Arguement))                                                       *
C*  ISEED: Seed                                                       *
C*                                                                    *
C**********************************************************************
      COMMON/RANDM/RDM(31),RM1,RM2,IA1,IC1,M1,IX1,
     .                             IA2,IC2,M2,IX2,
     .                             IA3,IC3,M3,IX3
C Generate Next number in sequence
      IX1    = MOD( IA1*IX1+IC1, M1 )
      IX2    = MOD( IA2*IX2+IC2, M2 )
      IX3    = MOD( IA3*IX3+IC3, M3 )
      J      = 1 + (31*IX3)/M3
      ARN    = RDM(J)
      RDM(J) = ( FLOAT(IX1)+FLOAT(IX2)*RM2 )*RM1
C Omit following statement if function arguement passed by value:
      ISEED = IX1
      RETURN
      END
      REAL*8 FUNCTION DRN(ISEED)
C**********************************************************************
C*======================                                              *
C* FUNCTION DRN( ISEED)                                               *
C*======================                                              *
C*  Machine-independent Random number generator                       *
C*     General purpose Version,  OK as long as >= 32 bits             *
C*((Arguement))                                                       *
C*  ISEED: Seed                                                       *
C*                                                                    *
C**********************************************************************
      DRN    = DBLE ( RNDM(DUM))
      RETURN
      END
C***********************************************************************
C*===================                                                  *
C* SUBROUTINE SPEVNT                                                   *
C*===================                                                  *
C*       By this subroutine, make the four vectors of the event        *
C*       and output them into the Data_Bank_system.                    *
C*       When user uses the Handypack, then fill the histograms.       *
C*                                                                     *
C*       Coded by S.Kawabata        September '84                      *
C*                                                                     *
C***********************************************************************
C
CCC   SUBROUTINE SPEVNT
C
C
CCC   RETURN
CCC   END
C***********************************************************************
C*===================                                                  *
C* SUBROUTINE SPINIT                                                   *
C*===================                                                  *
C*        Initialization program for the Event Generation.             *
C*       By this calling the initialization of Handypack and           *
C*       Data_Bank system etc. should be done.                         *
C*                                                                     *
C*       Coded by S.Kawabata        September '84                      *
C*                                                                     *
C***********************************************************************
C
C      SUBROUTINE SPINIT
C
C
C      RETURN
C      END
C
C***********************************************************************
C*===================                                                  *
C* SUBROUTINE SPMAIN                                                   *
C*===================                                                  *
C*        Main Program for the Event generation program SPRING.        *
C*                                                                     *
C*       Coded by S.Kawabata        September '84                      *
C*                                                                     *
C***********************************************************************
C
C      SUBROUTINE SPMAIN(FUNC, MXTRY )
C
C      IMPLICIT REAL*8 (A-H,O-Z)
C      EXTERNAL FUNC
C      REAL*4   SETIME,TIME1,TIME2,UTIME,XTIME,DTIME,CTIME
C      COMMON /BASE0/ NDUM(4),IBASES
C      COMMON/LOOP1/ LOOP,MXLOOP
C      COMMON/LOOP0/ LOOPC,IRCODE
C      COMMON/XHCNTL/ LOCK
C
C      IBASES = 0
C  -----------------------------------------------------
C      Initialization for SPRING and User function F
C  -----------------------------------------------------
C
C       CALL BSTIME( CTIME, 0 )
C
C       UTIME   = 0.0
C       CTIME   = 0.0
C
C       READ( 5, * ) MXEVNT
C
C       READ( 5, * ) SETIME
C
C      SETIME = SETIME*60.0 - 5.0
C
C  -----------------------------------------------------
C     Read the probability distribution from disk file
C  -----------------------------------------------------
C
C       CALL BSREAD
C
C       LOCK = 1
C       LOOPC= LOOP
C       CALL USERIN
C       LOCK = 0
C
C       CALL SPINIT
C
C       NBIN    = MXTRY
C       IF( MXTRY .GT. 50 ) NBIN = 50
C       TRYMX   = MXTRY + 1
C       CALL XHINIT( -10, 1.0, TRYMX, NBIN,
C    .  '************* Number of trials to get an event *************')
C      CALL SHRSET
C
C  -----------------------------------------------------
C                Event generation
C  -----------------------------------------------------
C
C       DO 1000 NEVENT = 1, MXEVNT
C
C 500        CALL BSTIME( TIME1, 1 )
C
C            CALL SPRING( FUNC, MXTRY, IRET)
C
C            CALL BSTIME( TIME2, 1 )
C
C            DTIME   = TIME2 - TIME1
C            CTIME   = CTIME + DTIME
C            XTIME   = DTIME* 1.1
C            IF( XTIME .GT. UTIME ) UTIME = XTIME
C            IF( (SETIME-TIME2) .LE. UTIME )  GO TO 2000
C
C            RET    = IRET
C
C            CALL XHFILL( -10, RET, 1.0D0)
C
C            IF( IRET .GT. 0 .AND. IRET .LE. MXTRY ) THEN
C              CALL SPEVNT
C            ENDIF
C
C            CALL SHUPDT
C
C            IF( IRET .GT. MXTRY ) GO TO 500
C
C1000   CONTINUE
C2000   NEVENT = NEVENT - 1
C
C       IF( NEVENT .GT. 0 ) THEN
C         WRITE(6,9500) NEVENT,CTIME,TIME2
C9500     FORMAT(/1H1,//1H ,
C    .           /20X,'*************************************',
C    .           /20X,'*                                   *',
C    .           /20X,'*      END   OF   SPRING            *',
C    .           /20X,'*                                   *',
C    .           /20X,'*   No. of Generated events         *',
C    .           /20X,'*   ',6X,I10,7X,          '         *',
C    .           /20X,'*                                   *',
C    .           /20X,'*   Net CPU time for generation     *',
C    .           /20X,'*         ',F10.3, ' seconds        *',
C    .           /20X,'*                                   *',
C    .           /20X,'*   GO time                         *',
C    .           /20X,'*         ',F10.3, ' seconds        *',
C    .           /20X,'*                                   *',
C    .           /20X,'*************************************')
C
C         CALL SHPLOT
C
C       ELSE
C         WRITE(6,9600)
C9600     FORMAT(/1H1,//1H ,
C    .    /10X,'*************************************************',
C    .    /10X,'*                                               *',
C    .    /10X,'*   There is no event generated by the SPRING.  *',
C    .    /10X,'*                                               *',
C    .    /10X,'*************************************************')
C       ENDIF
C
C       CALL SPTERM
C
C     RETURN
CC    END
C***********************************************************************
C*====================================                                 *
C* SUBROUTINE SPRING( F, MXTRY, NTRY )                                 *
C*====================================                                 *
C*                                                                     *
C*     Generation of events according to the probability density       *
C*     which is stored in a disk file.                                 *
C*                                                                     *
C*    Coded   by S.Kawabata   at July,1980                             *
C*    Update     S.Kawabata   September '84                            *
C*                                                                     *
C***********************************************************************
C
       SUBROUTINE SPRING(F,MXTRY,NTRY)
C
C
      IMPLICIT REAL*8 (A-H,O-Z)
      PARAMETER (MXDIM = 25, NDMX = 50, LENG = 17000)
      COMMON /BASE1/ XL(MXDIM),XU(MXDIM),NDIM,NSNG,
     .               IG(MXDIM),NCALL
      COMMON /BASE2/ ACC1,ACC2,ITMX1,ITMX2
      COMMON /BASE3/ SI,SI2,SWGT,SCHI,SCALLS,ATACC,NSU,IT
      COMMON /BASE4/ XI(NDMX,MXDIM),DX(MXDIM),DXD(LENG),DXP(LENG),
     .               ND,NG,NPG,MA(MXDIM)
      DIMENSION Y(MXDIM),KG(MXDIM)
      DATA ONE/1.0D0/
      DATA INIT /0/
      IF(INIT .EQ. 0) THEN
         XND     = ND
         DXG     = XND/NG
         NSP     = NG**NSNG
         XJAC    = 1.0
         DO 50 I = 1, NDIM
            XJAC = XJAC*DX(I)
   50    CONTINUE
         DO 100  I = 2,NSP
           DXD( I ) = DXD( I-1 ) + DXD( I )
  100    CONTINUE
         DXMAX   = DXD(NSP)
         INIT  = 1
      ENDIF
C
C
      RX    = DRN(DUMY)*DXMAX
C
C  -------------- Binary Search  --------------------------------
C
      IPMIN = 1
      IPMAX = NSP
C
 300  IC    = (IPMIN+IPMAX)/2
        IF(RX .LT. DXD(IC)) THEN
          IPMAX = IC
        ELSE
          IPMIN = IC
        ENDIF
      IF(IPMAX-IPMIN .GT.  2) GO TO 300
C
      IC    = IPMIN-1
 350  IC    = IC+1
      IF(DXD(IC) .LT. RX) GO TO 350
C
C --------------------------------------------------------------------
C      Identify the hypecube number from sequential number IC
C --------------------------------------------------------------------
C
       FMAX  = DXP(IC)
C
       IX    = IC-1
       KG(NSNG) = IX/MA(NSNG) + 1
       IF( NSNG .GT. 1 ) THEN
           DO 400 J = 1,NSNG-1
              NUM   = MOD(IX,MA(J+1))
              KG(J) = NUM/MA(J) + 1
  400      CONTINUE
       ENDIF
C
C  ------------------------------------------------------------------
C                     Sample and test a event
C  ------------------------------------------------------------------
C
      DO 600 NTRY = 1,MXTRY
        WGT   = XJAC
        DO 550 J=1,NDIM
          IF( J .LE. NSNG) THEN
             XN    = (KG(J)-DRN(DUMY))*DXG+ONE
          ELSE
             XN    = ND*DRN(DUMY) + ONE
          ENDIF
          IAJ   = XN
          IF(IAJ .EQ. 1) THEN
            XO    = XI(IAJ,J)
            RC    = (XN-IAJ)*XO
          ELSE
            XO    = XI(IAJ,J)-XI(IAJ-1,J)
            RC    = XI(IAJ-1,J)+(XN-IAJ)*XO
          ENDIF
          Y(J)  = XL(J) + RC*DX(J)
          WGT   = WGT*XO*XND
  550   CONTINUE
C
        FX    = F(Y)*WGT
        FUNCT = FX/FMAX
C
        IF(FX .GT. 0.0 ) THEN
          IF( DRN(DUMY) .LE. FUNCT ) GO TO 700
        ENDIF
C
        CALL SHCLER
C
  600 CONTINUE
      NTRY  = 2*MXTRY
  700 RETURN
C
C 1000 WRITE(6,9600) KG
 9600 FORMAT(1X,'*** PRODUCTION ERROR IA =',10I5)
C      NTRY = -1
C      RETURN
      END
C***********************************************************************
C*===================                                                  *
C* SUBROUTINE SPTERM                                                   *
C*===================                                                  *
C*       By this subroutine, make termination of the Data_Bank_System  *
C*       and Handypack etc.                                            *
C*       When you don't need such routines, keep this just dummy.      *
C*                                                                     *
C*       Coded by S.Kawabata        September '84                      *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE SPTERM
C
C
      RETURN
      END
C
C***********************************************************************
C*===================                                                  *
C* SUBROUTINE USROUT                                                   *
C*===================                                                  *
C*        Print BASES results for user option.                         *
C*                                                                     *
C***********************************************************************
C
C     SUBROUTINE USROUT
C
C     RETURN
C     END
************************************************************************
*                =====================================                 *
                   SUBROUTINE BHINIT( MAXLH, MAXDH )
*                =====================================                 *
*                                                                      *
* ((Purpose))                                                          *
*    Initialization program for  histograms and scatter plots.         *
*    This program is called by USERIN.                                 *
* ((Arguments))                                                        *
*    MAXLH  : Maximum number of the linear histograms                  *
*    MAXDH  : Maximum number of the scatter plots                      *
*                                                                      *
* (( Common /PLOTH/ ))                                                 *
*                                                                      *
*    NW                     : Total number of words of used buffer     *
*                                                                      *
*    NHIST                  : Number of Histograms                     *
*    NSCAT                  : Number of Scat_Plots                     *
*                                                                      *
*   -----------------                                                  *
*     Hashing Table                                                    *
*   -----------------                                                  *
*                                                                      *
*        XHASH(1,i)      : Number of histograms for the i-th class     *
*        XHASH(2,i) = K  : Serial number of histograms                 *
*                     |                                                *
*              MAPL(1,K) = ID  : Histogram ID                          *
*              MAPL(2,K) = IP1 : the 1st pointer to the K-th buffer    *
*              MAPL(3,K) = IP2 : the 2nd pointer to the K-th buffer    *
*              MAPL(4,K) = IP3 : the 3rd pointer to the K-th buffer    *
*                                                                      *
* (( Common /PLOTB/ ))                                                 *
*                                                                      *
*   --------------------                                               *
*     Histogram buffer                                                 *
*   --------------------                                               *
*                                                                      *
*    IP1  = NW + 1                                                     *
*           NW = NW + 281    : Updated NW                              *
*       BUFF( IP1 )          = Xmin                                    *
*       BUFF( IP1 + 1 )      = Xmax                                    *
*       IBUF( IP1 + 2 )      = No. of bins                             *
*       BUFF( IP1 + 3 )      = Bin width                               *
*    IP2  = IP1 + 4                                                    *
*       IBUF(   IP2       )                                            *
*          => IBUF( +  51 )  = No. of sampling points                  *
*       BUFF(   IP2 +  52)                                             *
*          => BUFF( + 103 )  = Sum of Fi for the current IT            *
*       BUFF(   IP2 + 104)                                             *
*          => BUFF( + 155 )  = Sum of Fi**2 for the current IT         *
*       BUFF(   IP2 + 156)                                             *
*          => BUFF( + 207 )  = Sum of Fi for total                     *
*       BUFF(   IP2 + 208)                                             *
*          => BUFF( + 259 )  = Sum of Fi**2 for total                  *
*    IP3  = IP1 + 264                                                  *
*       IBUF( IP3 )          = Tag for spring                          *
*       IBUF( IP3   +  1 )                                             *
*          => IBUF( + 16 )   = Title of this histogram                 *
*                                                                      *
*   --------------------                                               *
*     Scat_Plot buffer                                                 *
*   --------------------                                               *
*                                                                      *
* IP1   = NW + 1                                                       *
*         NW  = NW + 2527                                              *
*       BUFF( IP1 )          = Xmin                                    *
*       BUFF( IP1 + 1 )      = Xmax                                    *
*       IBUF( IP1 + 2 )      = No. of bins for X                       *
*       BUFF( IP1 + 3 )      = Bin width for X                         *
*       BUFF( IP1 + 4 )      = Ymin                                    *
*       BUFF( IP1 + 5 )      = Ymax                                    *
*       IBUF( IP1 + 6 )      = No. of bins for Y                       *
*       BUFF( IP1 + 7 )      = Bin width for Y                         *
* IP2   = IP1 + 8                                                      *
*       BUFF(   IP2       )  = No. of sampling points                  *
*       BUFF(   IP2 +   1 )                                            *
*          => BUFF( +2500 )  = Sum of Fi                               *
* IP3   = IP1 + 2509                                                   *
*       IBUF( IP3 )          = X-Tag for spring                        *
*       IBUF( IP3   +  1 )   = Y-Tag for spring                        *
*       IBUF( IP3   +  2 )                                             *
*          => IBUF( + 17 )   = Title of this histogram                 *
*                                                                      *
*  ((Author))                                                          *
*    S.Kawabata    June '90 at KEK                                     *
*                                                                      *
************************************************************************
      PARAMETER ( ILH = 50, IDH = 50 )
      INTEGER*4 XHASH,DHASH,MAXL,NHIST,MAPL,IFBASE,MAXD,NSCAT,MAPD
      COMMON/PLOTH/ XHASH(ILH,13),DHASH(IDH,14),IFBASE(ILH),
     .              MAXL, NHIST, MAPL(4,ILH),
     .              MAXD, NSCAT, MAPD(4,IDH),
     .              NW
      PARAMETER ( ISL = 281 )
      COMMON/PLOTB/ BUFF( ISL )
      INTEGER  IBUF( ISL )
      EQUIVALENCE (IBUF(1),BUFF(1))
      COMMON/XHCNTL/ LOCK
*                                                                      *
*--------------------------- Entry point ------------------------------*
*                                                                      *
         IF( MAXLH .GT. ILH ) THEN
             WRITE(6,9000)
 9000        FORMAT(1X,'Too many histogram buffer are required ||')
             STOP
         ELSEIF( MAXD .GT. IDH ) THEN
             WRITE(6,9100)
 9100        FORMAT(1X,'Too many Scat_Plot buffer are required ||')
         ENDIF
         MAXL   = MAXLH + 1
         MAXD   = MAXDH
         IF( LOCK .NE. 0 ) RETURN
         NW     = 0
         DO 50 I = 1, 13
           XHASH(1,I) = 0
           DHASH(1,I) = 0
   50    CONTINUE
         NHIST    = 0
         NSCAT    = 0
         DO 100 I = 1, ILH
           MAPL(1,I)= 0
  100    CONTINUE
         DO 200 I = 1, IDH
           MAPD(1,I)= 0
  200    CONTINUE
C
      RETURN
      END
************************************************************************
*                       ======================                         *
                           SUBROUTINE BHPLOT
*                       ======================                         *
* ((Purpose))                                                          *
*     Interface routine to print histograms and scatter plots.         *
*     Routines XHPLOT and DHPLOT are called to print them.             *
* ((Author))                                                           *
*     S.Kawabata  June '90  at KEK                                     *
************************************************************************
      PARAMETER ( ILH = 50, IDH = 50 )
      INTEGER*4 XHASH,DHASH,MAXL,NHIST,MAPL,IFBASE,MAXD,NSCAT,MAPD
      COMMON/PLOTH/ XHASH(ILH,13),DHASH(IDH,14),IFBASE(ILH),
     .              MAXL, NHIST, MAPL(4,ILH),
     .              MAXD, NSCAT, MAPD(4,IDH),
     .              NW
*                                                                      *
*--------------------------- Entry point ------------------------------*
*    =============                                                     *
      CALL XHCHCK
*    =============
      IF( NHIST .LE. 0 ) THEN
         WRITE(6,9000)
 9000    FORMAT(1X,'No Histogram')
      ELSE
         DO 500 J = 1, NHIST
            IFBASE(J) = 1
*          =====================
            CALL XHPLOT( 0, J )
*          =====================
  500    CONTINUE
      ENDIF
*    =============
      CALL DHPLOT
*    =============
      RETURN
      END
************************************************************************
*                         ====================                         *
                            SUBROUTINE BHRSET
*                         ====================                         *
* ((Purpose))                                                          *
*     To reset contents of histograms and scatter plots.               *
* ((Author))                                                           *
*     S.Kawabata  June '90 at KEK                                      *
************************************************************************
      PARAMETER ( ILH = 50, IDH = 50 )
      INTEGER*4 XHASH,DHASH,MAXL,NHIST,MAPL,IFBASE,MAXD,NSCAT,MAPD
      COMMON/PLOTH/ XHASH(ILH,13),DHASH(IDH,14),IFBASE(ILH),
     .              MAXL, NHIST, MAPL(4,ILH),
     .              MAXD, NSCAT, MAPD(4,IDH),
     .              NW
      PARAMETER ( ISL = 281 )
      COMMON/PLOTB/ BUFF( ISL )
      INTEGER  IBUF( ISL )
      EQUIVALENCE (IBUF(1),BUFF(1))
*                                                                      *
*--------------------------- Entry point ------------------------------*
*                                                                      *
*-------------------------- Clear Histograms --------------------------*
*                                                                      *
         DO 200 J    = 1, NHIST
           IP2       = MAPL(3,J)
           DO 100 I  = IP2,IP2+259
             IBUF(I) = 0
  100      CONTINUE
           IFBASE(J) = 0
  200    CONTINUE
*                                                                      *
*-------------------------- Clear Scat. Plots -------------------------*
*                                                                      *
         DO 500  J   = 1, NSCAT
           IP2       = MAPD(3,J)
           DO 400  I = IP2,IP2+2500
             IBUF(I) = 0.0
  400      CONTINUE
  500    CONTINUE
*                                                                      *
      RETURN
      END
************************************************************************
*                        =====================                         *
                           SUBROUTINE BHSAVE
*                        =====================                         *
* ((Purpose))                                                          *
*     To save contents of temporary buffers to the histogram buffers,  *
*     in order to avoid the precision problem.                         *
* ((Author))                                                           *
*     S.Kawabata  June '90 at KEK                                      *
************************************************************************
      PARAMETER ( ILH = 50, IDH = 50 )
      INTEGER*4 XHASH,DHASH,MAXL,NHIST,MAPL,IFBASE,MAXD,NSCAT,MAPD
      COMMON/PLOTH/ XHASH(ILH,13),DHASH(IDH,14),IFBASE(ILH),
     .              MAXL, NHIST, MAPL(4,ILH),
     .              MAXD, NSCAT, MAPD(4,IDH),
     .              NW
      PARAMETER ( ISL = 281 )
      COMMON/PLOTB/ BUFF( ISL )
      INTEGER  IBUF( ISL )
      EQUIVALENCE (IBUF(1),BUFF(1))
*                                                                      *
*--------------------------- Entry point ------------------------------*
*                                                                      *
      DO 200 J = 1, NHIST
         IP2   = MAPL(3,J)
         NC    = IBUF( MAPL(2,J)+2 ) + 1
         IB1   = IP2 + 52
         IB2   = IB1 + 52
         DO 100 I = 0,NC
            I1    = I + IB1
            I2    = I1 + 104
            BUFF(I2)  = BUFF(I2) + BUFF(I1)
            BUFF(I1)  = 0.0
            I1    = I + IB2
            I2    = I1 + 104
            BUFF(I2)  = BUFF(I2) + BUFF(I1)
            BUFF(I1)  = 0.0
  100    CONTINUE
  200 CONTINUE
C
      RETURN
      END
C=EXPAND 'MSYK.BASES.HIST80.FORT(BSREAD)'
C=EXPAND 'MSYK.BASES.HIST80.FORT(BSWRIT)'
************************************************************************
*              =======================================                 *
                 SUBROUTINE DHFILL( ID, DX, DY, FX )
*              =======================================                 *
* ((Function))                                                         *
*     To fill scatter plot                                             *
*   This routine identifies the bin number which is to be updated      *
*   with weight FX*WGT.  Up to five points per plot are able to        *
*   be stacked before calling BHUPDT or SHUPDT.                        *
* ((Input))                                                            *
*   ID    : Histogram identification number                            *
*   DX    : Input x value                                              *
*   DY    : Input y value                                              *
*   FX    : Input value of the function                                *
* ((Author))                                                           *
*   S.Kawabata         June '90 at KEK                                 *
*                                                                      *
************************************************************************
      REAL*8 DX, DY, FX
      REAL*8 SI,SI2,SWGT,SCHI,SCALLS,ATACC,WGT
      COMMON /BASE0/ SETIM,UTIME,IFLAG,NPRINT,IBASES
      COMMON /BASE3/ SI,SI2,SWGT,SCHI,SCALLS,ATACC,NSU,IT,WGT
      PARAMETER ( ILH = 50, IDH = 50 )
      INTEGER*4 XHASH,DHASH,MAXL,NHIST,MAPL,IFBASE,MAXD,NSCAT,MAPD
      COMMON/PLOTH/ XHASH(ILH,13),DHASH(IDH,14),IFBASE(ILH),
     .              MAXL, NHIST, MAPL(4,ILH),
     .              MAXD, NSCAT, MAPD(4,IDH),
     .              NW
      PARAMETER ( ISL = 281 )
      COMMON/PLOTB/ BUFF( ISL )
      INTEGER  IBUF( ISL )
      EQUIVALENCE (IBUF(1),BUFF(1))
*                                                                      *
*--------------------------- Entry point ------------------------------*
*                                                                      *
*======================================================================*
*               Find the scatter plot ID in the table                  *
*======================================================================*
*                                                                      *
      IF( NSCAT .GT. 0 ) THEN
          I  = IABS(MOD( ID, 13 )) + 1
          IF( DHASH(1, I) .EQ. 1 ) THEN
            IF( ID .EQ. MAPD( 1, DHASH(2,I))) THEN
                ISCAT = DHASH(2,I)
                GO TO 200
            ENDIF
          ELSEIF( DHASH(1, I) .GT. 1 ) THEN
            DO 100 K = 2, DHASH(1,I)+1
               IF( ID .EQ. MAPD( 1, DHASH(K,I))) THEN
                   ISCAT = DHASH(K,I)
                   GO TO 200
               ENDIF
  100       CONTINUE
          ENDIF
      ENDIF
C     WRITE(6,9000) ID
C9000 FORMAT(1X,'No Scat_Plot corresponds to ID =',I5,
C    .      /1X,' This call is neglected !!!')
      RETURN
*                                                                      *
*======================================================================*
*               Determine the bin numbers for x and y                  *
*======================================================================*
*                                                                      *
  200 X     = DX*1.0
      Y     = DY*1.0
          IP1   = MAPD(2,ISCAT)
          XMIN  = BUFF(IP1)
          XMAX  = BUFF(IP1+1)
          MXBIN = IBUF(IP1+2)
          DEV   = BUFF(IP1+3)
          IX    =   0
          IY    =   0
          IF( X .GE. XMIN .AND. X .LE. XMAX ) THEN
              IX   = INT( (X - XMIN)/DEV+ 1.0 )
              IF( IX .GT. MXBIN ) IX =   0
          ENDIF
C
          IF( IX .GT. 0 ) THEN
              YMIN  = BUFF(IP1+4)
              YMAX  = BUFF(IP1+5)
              MYBIN = IBUF(IP1+6)
              DEV   = BUFF(IP1+7)
              IF( Y .GE. YMIN .AND. Y .LE. YMAX ) THEN
                  IY   = INT((Y - YMIN)/DEV + 1.0)
                 IF( IY .GT. MYBIN ) THEN
                     IX  =  0
                     IY  =  0
                 ENDIF
              ENDIF
          ENDIF
*                                                                      *
*======================================================================*
*               Fill the scatter plot ID                               *
*======================================================================*
*----------------------------------------------------------------------*
*               For BASES                                              *
*----------------------------------------------------------------------*
*                                                                      *
      IF( IBASES .EQ. 1 ) THEN
          IF( IY .GT. 0 ) THEN
              IP2       = MAPD(3,ISCAT)
              IBUF(IP2) = SCALLS
              IP2       = IX + MXBIN*(IY - 1) + IP2
              BUFF(IP2) = BUFF(IP2) + FX*WGT
          ENDIF
*----------------------------------------------------------------------*
*               For SPRING                                             *
*----------------------------------------------------------------------*
*                                                                      *
      ELSE
          IP3         = MAPD(4,ISCAT)
          IBUF(IP3)   = IX
          IBUF(IP3+1) = IY
      ENDIF
      RETURN
      END
************************************************************************
*  =================================================================== *
      SUBROUTINE DHINIT(ID,DXMIN,DXMAX,NXBIN,DYMIN,DYMAX,NYBIN,TNAME)
*  =================================================================== *
* ((Function))                                                         *
*     To define a scatter plot                                         *
* ((Input))                                                            *
*    ID   : scatter plot identification number                         *
*    DXMIN: Lower limit of X for the scatter plot                      *
*    DXMAX: Upper limit of X for the scatter plot                      *
*    NXBIN: Number of bins of X for the plot (Max. is 50 )             *
*    DYMIN: Lower limit of Y for the scatter plot                      *
*    DYMAX: Upper limit of Y for the scatter plot                      *
*    NYBIN: Number of bins of Y for the plot (Max. is 50 )             *
*    TNAME: Title of the plot in the character string (upto 64         *
*            characters)                                               *
* ((Author))                                                           *
*    S.Kawabata     June '90 at KEK                                    *
*                                                                      *
************************************************************************
      REAL*8 DXMIN,DXMAX,DYMIN,DYMAX
      CHARACTER*(*) TNAME
      CHARACTER*64 NAME
      PARAMETER ( ILH = 50, IDH = 50 )
      INTEGER*4 XHASH,DHASH,MAXL,NHIST,MAPL,IFBASE,MAXD,NSCAT,MAPD
      COMMON/PLOTH/ XHASH(ILH,13),DHASH(IDH,14),IFBASE(ILH),
     .              MAXL, NHIST, MAPL(4,ILH),
     .              MAXD, NSCAT, MAPD(4,IDH),
     .              NW
      PARAMETER ( ISL = 281 )
      COMMON/PLOTB/ BUFF( ISL )
      INTEGER  IBUF( ISL )
      EQUIVALENCE (IBUF(1),BUFF(1))
      COMMON/XHCNTL/ LOCK
*                                                                      *
*--------------------------- Entry point ------------------------------*
*                                                                      *
*======================================================================*
*               Find the scatter plot ID in the table                  *
*======================================================================*
*                                                                      *
      IF( NSCAT .GE. MAXD ) THEN
          IF( LOCK .NE. 0 ) RETURN
          WRITE(6,9000) NSCAT,ID
 9000     FORMAT(1X,'Numberof Scat_plots exceeds ',I3,' at ID = ',I3,
     .            /1X,'This call is neglected.')
          RETURN
      ENDIF
      I  = IABS(MOD( ID, 13 )) + 1
      IF( DHASH(1, I) .EQ. 1 ) THEN
            IF( ID .EQ. MAPD( 1, DHASH(2,I))) THEN
                IF( LOCK .NE. 0 ) RETURN
                WRITE(6,9100) ID
 9100           FORMAT(1X,'Scat Plot ID (',I3,' ) exists already.'
     .                /1X,' This call is neglected.')
                RETURN
            ENDIF
      ELSEIF( DHASH(1, I) .GT. 1 ) THEN
          DO 100 K = 2, DHASH(1,I)+1
            IF( ID .EQ. MAPD( 1, DHASH(K,I))) THEN
                IF( LOCK .NE. 0 ) RETURN
                WRITE(6,9100) ID
                RETURN
            ENDIF
  100    CONTINUE
      ENDIF
      XMIN  = DXMIN*1.0
      XMAX  = DXMAX*1.0
      YMIN  = DYMIN*1.0
      YMAX  = DYMAX*1.0
      IF(MAXD .GT. IDH ) THEN
         WRITE(6,9200) ID
 9200    FORMAT(1X,'Number of Scat_Plots exceeds 10 at ID =',I5,
     .         /1X,' This call is neglected.')
         RETURN
      ELSEIF(NXBIN .GT. 50 .OR. NYBIN .GT. 50 ) THEN
         WRITE(6,9300) NXBIN,NYBIN,ID
 9300    FORMAT(1X,'Bin size (',2I3,' )  exceeds 50 at ID =',I5,
     .         /1X,' This call is neglected .')
         RETURN
      ELSEIF(XMIN  .GE. XMAX .OR. YMIN .GE. YMAX) THEN
         WRITE(6,9400) ID,XMIN,XMAX,YMIN,YMAX
 9400    FORMAT(1X,'Lower limit is larger than upper at SC_PL ID =',I5,
     .         /1X,' This call is neglected .',
     .         /1X,' XMIN =',G13.4,' XMAX =',G13.4,
     .         /1X,' YMIN =',G13.4,' YMAX =',G13.4)
         RETURN
      ENDIF
      IF(DHASH(1,I) .GE. 49 ) THEN
         WRITE(6,9500) I
 9500    FORMAT(1X,I5,'-th Hash table overflow',
     .         /1X,' This call is neglected.')
         RETURN
      ENDIF
*                                                                      *
*======================================================================*
*            Initialization of new scatter plot                        *
*======================================================================*
*                                                                      *
      NSCAT        = NSCAT + 1
      DHASH(1,I)   = DHASH(1,I) + 1
      K            = DHASH(1,I) + 1
      DHASH(K,I)   = NSCAT
      IP1    = NW + 1
         NW  = NW + 2527
         MAPD(1,NSCAT)  = ID
         MAPD(2,NSCAT)  = IP1
         BUFF(IP1     ) = XMIN
         BUFF(IP1 +  1) = XMAX
         IBUF(IP1 +  2) = NXBIN
         DEV            = XMAX - XMIN
         BUFF(IP1 +  3) = DEV/NXBIN
         BUFF(IP1 +  4) = YMIN
         BUFF(IP1 +  5) = YMAX
         IBUF(IP1 +  6) = NYBIN
         DEV            = YMAX - YMIN
         BUFF(IP1 +  7) = DEV/NYBIN
      IP2   = IP1 + 8
         MAPD(3,NSCAT)  = IP2
         IBUF(IP2     ) = 0
      IP3   = IP1 + 2509
         MAPD(4,NSCAT)  = IP3
         IBUF(IP3     ) =  0
         IBUF(IP3 +  1) =  0
         I1   = IP3 + 2
         I2   = I1 + 15
         NAME = TNAME
         READ(NAME,9800) (BUFF(I),I=I1,I2)
 9800    FORMAT(16A4)
      RETURN
      END
************************************************************************
*                        =====================                         *
                           SUBROUTINE DHPLOT
*                        =====================                         *
* ((Purpose))                                                          *
*      To print scatter plots for BASES and SPRING                     *
*                                                                      *
* ((Author))                                                           *
*       S.Kawabata    June '90                                         *
*                                                                      *
************************************************************************
      PARAMETER ( ILH = 50, IDH = 50 )
      INTEGER*4 XHASH,DHASH,MAXL,NHIST,MAPL,IFBASE,MAXD,NSCAT,MAPD
      COMMON/PLOTH/ XHASH(ILH,13),DHASH(IDH,14),IFBASE(ILH),
     .              MAXL, NHIST, MAPL(4,ILH),
     .              MAXD, NSCAT, MAPD(4,IDH),
     .              NW
      PARAMETER ( ISL = 281 )
      COMMON/PLOTB/ BUFF( ISL )
      INTEGER  IBUF( ISL )
      EQUIVALENCE (IBUF(1),BUFF(1))
      COMMON /BSCNTL/ INTV, IPNT, NLOOP, MLOOP
      CHARACTER*1  PLUS,MINUS,BLNK,STAR,NUM(0:9),NEG(0:9),SHARP,PNT
      REAL*4       X(50)
      CHARACTER*1 CHARR(50), CN
      CHARACTER*80 FORM1,FORM
      DATA  PLUS /'+'/, MINUS /'-'/, BLNK /' '/, STAR /'*'/
      DATA  SHARP /'#'/,  PNT /'.'/
      DATA  NUM  / '0','1','2','3','4','5','6','7','8','9'/
      DATA  NEG  / '-','a','b','c','d','e','f','g','h','i'/
*                                                                      *
*--------------------------- Entry point ------------------------------*
*                                                                      *
      CN   = CHAR(12)
      IF( NSCAT .GT. 0 ) THEN
         DO 900 ISCAT = 1, NSCAT
            IP3   = MAPD(4,ISCAT)
            IF( IPNT .EQ. 0 ) THEN
                WRITE(6,9010)
            ELSE
                WRITE(6,9020) CN
            ENDIF
 9010       FORMAT(/1H1)
 9020       FORMAT(A1)
            WRITE(6,9100) MAPD(1,ISCAT),(BUFF(I), I=IP3+2,IP3+17)
 9100       FORMAT(/5X,'Scat_Plot (ID =',I3,' ) for ',16A4,/)
            IP1   = MAPD(2,ISCAT)
            XL    = BUFF(IP1)
            XU    = BUFF(IP1+1)
            NX    = IBUF(IP1+2)
            DX    = BUFF(IP1+3)
            XM    = ABS(XU)
            XX    = ABS(XL)
            IF( XX .GT. XM ) XM = XX
            CALL XHORDR( XU, FX, XORD, IXORD)
            YL    = BUFF(IP1+4)
            YU    = BUFF(IP1+5)
            NY    = IBUF(IP1+6)
            DY    = BUFF(IP1+7)
            MIDY  = NY/2
            IF( MIDY .EQ. 0 ) MIDY = 1
            YM    = ABS(YU)
            YY    = ABS(YL)
            IF( YY .GT. YM ) YM = YY
            CALL XHORDR( YM, FY, YORD, IYORD)
            IP2   = MAPD(3,ISCAT)
            NTOTAL= IBUF(IP2)
            VMAX  = BUFF(IP2+1)
            VMIN  = VMAX
            DO 100 J = 0,NY-1
               IB    = NX*J + IP2
               DO 100 I = 1,NX
                  VLS    = BUFF( I + IB )
                  IF( VLS .GT. VMAX ) VMAX = VLS
                  IF( VLS .LT. VMIN ) VMIN = VLS
  100       CONTINUE
***
            IF( VMAX .EQ. 0.0 .AND. VMIN .EQ. 0.0 ) THEN
                VMAX  = 10.0
                VMIN  = 0.0
            ENDIF
***
            IF( VMAX .GT. -VMIN ) THEN
                UNIT = ABS(VMAX)/11.0
            ELSE
                UNIT = ABS(VMIN)/11.0
            ENDIF
            WRITE(FORM1,9200) NX
*9200       FORMAT('(7X,''E'',I3,3X,''+'',',I2,'(''--''),''-+'')')
 9200       FORMAT('(7X,''E'',I3,3X,''+'',',I2,'(''-''),''+'')')
            WRITE(6,FORM1) IYORD
            DO 300 L = NY-1,0,-1
               IB     = NX*L + IP2
               DO 200 I = 1,NX
                 XNUM   = BUFF( I + IB )/UNIT
                 IF( XNUM .LT. 0 0 ) THEN
                     NUMB   = XNUM - 1.0
                     IF(     NUMB .GE. -1 )THEN
                             CHARR(I) = MINUS
                     ELSEIF( NUMB .GE. -10 ) THEN
                            CHARR(I) = NEG(-NUMB-1)
                     ELSE
                            CHARR(I) = SHARP
                     ENDIF
                 ELSE
                     NUMB   = XNUM + 1.0
                     IF(     XNUM .EQ. 0.0 ) THEN
                             CHARR(I) = BLNK
                     ELSEIF( NUMB .LE.  1 ) THEN
                             CHARR(I) = PLUS
                             IF( VMIN .GE. 0.0 ) CHARR(I) = PNT
                     ELSEIF( NUMB .LE. 10 ) THEN
                             CHARR(I) = NUM(NUMB-1)
                     ELSE
                             CHARR(I) = STAR
                     ENDIF
                 ENDIF
  200          CONTINUE
               Y   = (L*DY + YL)/YORD
               IF( L .EQ. MIDY ) THEN
                   WRITE(FORM,9300) NX
*9300              FORMAT('(5X,F6.3,'' Y I'',',I2,'(1X,A1),'' I'')')
 9300              FORMAT('(5X,F6.3,'' Y I'',',I2,'A1,''I'')')
               ELSE
                   WRITE(FORM,9310) NX
*9310              FORMAT('(5X,F6.3,''   I'',',I2,'(1X,A1),'' I'')')
 9310              FORMAT('(5X,F6.3,''   I'',',I2,'A1,''I'')')
               ENDIF
               WRITE(6,FORM) Y,(CHARR(M),M=1,NX)
  300       CONTINUE
            WRITE(6,FORM1) IYORD
            NXH   = NX/2
            IF( NXH .EQ. 0 ) NXH = 1
            WRITE(FORM,9400) NXH
*           WRITE(FORM,9400) NX
 9400       FORMAT('(6X,''Low-'',5X,',I2,'X,''X'')')
            WRITE(6,FORM)
            XORD     = XORD*10.
            DO 400 I = 1, NX
               X(I)  = ((I-1)*DX + XL)/XORD
               IF( X(I) .LT. 0.0 ) THEN
                   CHARR(I)  = MINUS
                   X(I)      = -X(I)
               ELSE
                   CHARR(I)  = BLNK
               ENDIF
  400       CONTINUE
            WRITE(FORM1,9500) NX
*9500       FORMAT('(6X,''Edge'',5X,',I2,'(1X,A1))')
 9500       FORMAT('(6X,''Edge'',5X,',I2,'A1)')
            WRITE(6,FORM1) (CHARR(M),M=1,NX)
            XORD      = 1.0
            DO 600 I  = 1,5
               IF( I .EQ. 2 ) THEN
                   WRITE(FORM,9602) NX
 9602              FORMAT('(7X,''E'',I3,4X',I2,
     .                    '(''.''))')
                   WRITE(6,FORM) IXORD
               ELSE
                   DO 500 J = 1, NX
                      XX        = X(J)*10.0
                      NUMB      = XX
                      CHARR(J)  = NUM(NUMB)
                      X(J)      = XX - FLOAT(NUMB)
  500              CONTINUE
                   IF(     I .EQ. 4 ) THEN
                           WRITE(FORM,9604) NX
 9604                      FORMAT('(7X,''Low-'',4X,',I2,
     .                            'A1)')
                   ELSEIF( I .EQ. 5 ) THEN
                           WRITE(FORM,9605) NX
 9605                      FORMAT('(7X,''Edge'',4X,',I2,
     .                            'A1)')
                   ELSE
                           WRITE(FORM,9601) NX
 9601                      FORMAT('(15X,',I2,
     .                            'A1)')
                   ENDIF
                   WRITE(6,FORM) (CHARR(M),M=1,NX)
               ENDIF
  600       CONTINUE
  900    CONTINUE
      ENDIF
C
      RETURN
      END
C***********************************************************************
C*=======================                                              *
C*    SUBROUTINE SHCLER                                                *
C*=======================                                              *
C*((FUNCTION))                                                         *
C*    To cancel the update of histograms and scatter plots in case     *
C*  of the trial was rejected.                                         *
C*((Author))                                                           *
C*    S.Kawabata June '90 at KEK                                       *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE SHCLER
      PARAMETER ( ILH = 50, IDH = 50 )
      INTEGER*4 XHASH,DHASH,MAXL,NHIST,MAPL,IFBASE,MAXD,NSCAT,MAPD
      COMMON/PLOTH/ XHASH(ILH,13),DHASH(IDH,14),IFBASE(ILH),
     .              MAXL, NHIST, MAPL(4,ILH),
     .              MAXD, NSCAT, MAPD(4,IDH),
     .              NW
      PARAMETER ( ISL = 281 )
      COMMON/PLOTB/ BUFF( ISL )
      INTEGER  IBUF( ISL )
      EQUIVALENCE (IBUF(1),BUFF(1))
      IF( NHIST .GT. 0 ) THEN
         DO 200  J   = 1, NHIST
           IP3       = MAPL(3,J)
           IBUF(IP3) = -1
  200    CONTINUE
      ENDIF
C
      IF( NSCAT .GT. 0 ) THEN
         DO 500   K    = 1, NSCAT
           IP3         = MAPD(4,K)
           IBUF(IP3)   =  0
           IBUF(IP3+1) =  0
  500    CONTINUE
      ENDIF
C
      RETURN
      END
C***********************************************************************
C*=======================                                              *
C*    SUBROUTINE SHPLOT                                                *
C*=======================                                              *
C*((Function))                                                         *
C*    To print histograms and scatter plots defined by XHINIT and      *
C*  DHINIT.                                                            *
C*    For the original histograms, a special histograms are printd     *
C*  by this routine. For the additional histograms and scatter plots   *
C*  routines XHPLOT and DHPLOT are called.                             *
C*((Author))                                                           *
C*    S.Kawabata   June '90 at KEK                                     *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE SHPLOT
C
      REAL*8         SI,SI2,SWGT,SCHI,SCALLS,ATACC,WGT
      COMMON /BASE3/ SI,SI2,SWGT,SCHI,SCALLS,ATACC,NSU,IT,WGT
      PARAMETER ( ILH = 50, IDH = 50 )
      INTEGER*4 XHASH,DHASH,MAXL,NHIST,MAPL,IFBASE,MAXD,NSCAT,MAPD
      COMMON/PLOTH/ XHASH(ILH,13),DHASH(IDH,14),IFBASE(ILH),
     .              MAXL, NHIST, MAPL(4,ILH),
     .              MAXD, NSCAT, MAPD(4,IDH),
     .              NW
      PARAMETER ( ISL = 281 )
      COMMON/PLOTB/ BUFF( ISL )
      INTEGER  IBUF( ISL )
      EQUIVALENCE (IBUF(1),BUFF(1))
      COMMON /BSCNTL/ INTV, IPNT, NLOOP, MLOOP
      CHARACTER*50 CHARR,CHR1
      CHARACTER*52 SCALE
      REAL  VAL(0:51),VLOG(0:51)
      REAL  VERR(0:51)
      CHARACTER*1  BLNK,STAR,CROS,AI,CN
      DATA  YMAX / 50/, BLNK /' '/, STAR /'*'/, CROS /'O'/
      DATA  AI /'I'/
      CN  = CHAR(12)
      CALL XHCHCK
      IF( NHIST .GT. 0 ) THEN
         NTOTAL= SCALLS
         DO 500 IHIST = 1, NHIST
          IF(MAPL(1,IHIST) .EQ. -10 ) GO TO 500
          IF(IFBASE(IHIST) .EQ. 1 ) THEN
            IP3  = MAPL(4,IHIST)
            IF( IPNT .EQ. 0 ) THEN
                WRITE(6,9010)
            ELSE
                WRITE(6,9020) CN
            ENDIF
 9010       FORMAT(/1H1)
 9020       FORMAT(A1)
            WRITE(6,9050) MAPL(1,IHIST),(BUFF(I), I=IP3+1,IP3+15)
 9050       FORMAT(1X,'Original Histogram (ID =',I3,' ) for ',15A4)
            IP1   = MAPL(2,IHIST)
            XMIN  = BUFF(IP1)
            XMAX  = BUFF(IP1+1)
            NXBIN = IBUF(IP1+2) + 1
            DEV   = BUFF(IP1+3)
            VMAX  = 0.0
            VORG  = 0.0
            VEVT  = 0.0
            FACT       = 1./(NTOTAL*DEV)
            IP2   = MAPL(3,IHIST)
            IPX   = IP2 + 52
            IPF   = IP2 + 156
            IPF2  = IPF + 52
            VAL(0)     = BUFF(IPF)/NTOTAL
            VAL(NXBIN) = BUFF(IPF+NXBIN)/NTOTAL
            DO  50 I   = 1,NXBIN-1
                TX     = BUFF(I+IPF)
                NX     = IBUF(I+IP2)
                VLS    = TX*FACT
                IF( VMAX .LT. VLS ) VMAX = VLS
                VAL(I) = VLS
                IF( NX .GT. 1 ) THEN
                  DEV2   =  NX*BUFF(I+IPF2)-TX*TX
                  IF( DEV2 .LE. 0.0 ) THEN
                      VERR(I)= 0.0
                  ELSE
                      VERR(I)= FACT*SQRT( DEV2/( NX-1 ))
                  ENDIF
                ELSEIF( NX .EQ. 1 ) THEN
                  VERR(I)= VLS
                ELSE
                  VERR(I)= 0.0
                ENDIF
                VORG   = VLS + VORG
                VEVT   = BUFF(I+IPX) + VEVT
   50       CONTINUE
            NTOT   = VEVT
            IF( VMAX .LE. 0.0 .AND. VEVT .GT. 0.0 ) THEN
                  WRITE(6,9060) IHIST
 9060             FORMAT(/5X,'***************************************',
     .                   /5X,'* Since BASES has no entry            *',
     .                   /5X,'*     in the histogram ID(',I6,' ),   *',
     .                   /5X,'*  an additional hist. is given       *',
     .                   /5X,'*     in the next page in stead.      *',
     .                   /5X,'***************************************')
C
                  CALL XHPLOT( 1, IHIST )
C
                  GO TO 500
            ELSEIF( VEVT .LE. 0) THEN
                  WRITE(6,9070) IHIST
 9070             FORMAT(/5X,'***************************************',
     .                   /5X,'*    SPRING has no entry              *',
     .                   /5X,'*     in the histogram ID(',I6,' )    *',
     .                   /5X,'***************************************')
                  GO TO 500
            ENDIF
            VNORM = VORG/VEVT
            XNORM = VNORM*DEV
            VLMAX = ALOG10(VMAX)
            VLMIN = VLMAX
            DO  60 I = 0,NXBIN
              IF( VAL(I) .GT. 0.0 ) THEN
                  VLS   = ALOG10( VAL(I) )
                 IF( I .GT. 0 .AND. I .LT. NXBIN ) THEN
                    IF( VLS .LT. VLMIN ) VLMIN = VLS
                 ENDIF
                 VLOG(I)  = VLS
              ELSE
                 VLOG(I)  = 0.0
              ENDIF
   60       CONTINUE
C
             VXMAX = VLMAX
             IF( VLMIN .LT. 0.0) THEN
                VXMIN = IFIX(VLMIN) - 1.0
             ELSE
                VXMIN = IFIX(VLMIN)
             ENDIF
             CALL XHRNGE( 1, VXMIN, VXMAX, VLMIN, VLMAX, VLSTP)
             UNITL = (VLMAX-VLMIN)/YMAX
C
             CALL XHSCLE( 1, VLMIN, VLMAX, VLSTP, UNITL, SCALE, CHR1)
C
C
             WRITE(6,9150) NTOT
 9150        FORMAT(1X,'Total =',I10,' events',
     .              3X,'"*" : Orig. Dist. in Log Scale.')
             VXMIN = 10.0**VLMIN
             WRITE(6,9200) SCALE
 9200        FORMAT(1X,'    x      d(Sig/dx)  dN/dx',A52)
             WRITE(6,9250)  CHR1
 9250        FORMAT(1X,
     .             '+--------+----------+-------+',
     .       A50 )
C
            VX    = ABS(XMAX)
            XM    = ABS(XMIN)
            IF( XM .GT. VX ) VX = XM
            CALL XHORDR( VX, F2, ORD, IORD )
            DO 200 I = 0,NXBIN
              RNORM = VNORM
              IF( I .EQ. 0 .OR. I .EQ. NXBIN ) RNORM = XNORM
              VX    = VAL(I)
              XL     = BUFF( I + IPX )
              NX     = XL
              IF( VX .GT. 0.0 ) THEN
                 NUMBL  = (VLOG(I) - VLMIN)/UNITL + 1.0
              ELSE
                 NUMBL  = 0
              ENDIF
              IF( NX .GT. 0 ) THEN
                 NUMB   = ( LOG10( XL*RNORM ) - VLMIN)/UNITL + 1.0
                 ERL    = SQRT(XL)
                 DERL   = (XL + ERL)*RNORM
                 NERUP  = ( LOG10( DERL ) - VLMIN)/UNITL + 1.0
                 DERL   = (XL - ERL)*RNORM
                 IF( DERL .GT. 0.0 ) THEN
                     NERLW  = ( LOG10( DERL ) - VLMIN)/UNITL + 1.0
                 ELSE
                     NERLW  = 0
                 ENDIF
              ELSE
                 NUMB   = 0
                 NERUP  = 0
                 NERLW  = 0
              ENDIF
              IF( NUMB  .GT. 50 ) NUMB = 50
              IF( NUMBL .GT. 50 ) NUMBL= 50
              DO 100 K = 1,50
                IF( K .LE. NUMBL) THEN
                  CHARR(K:K) = STAR
                ELSE
                  IF( K .EQ. 50 ) THEN
                    CHARR(K:K) = AI
                  ELSE
                    CHARR(K:K) = BLNK
                  ENDIF
                ENDIF
C
                IF(     K .EQ. NUMB ) THEN
                        CHARR(K:K) = CROS
                        IF( K .EQ. NERUP .AND. K .EQ. NERLW ) GO TO 100
                ENDIF
                IF(     K .EQ. NERUP ) THEN
                        CHARR(K:K) = '>'
                ELSEIF( K .EQ. NERLW ) THEN
                        CHARR(K:K) = '<'
                ENDIF
  100         CONTINUE
              CALL XHORDR( VX, F2, ORDER, IORDR )
             IF( I .EQ. 0 .OR. I .EQ. NXBIN ) THEN
                 WRITE(6,9300) IORD,F2,IORDR,NX,CHARR
 9300            FORMAT(1X,'I   E',I3,' I',F6.3,'E',I3,'I',
     .                                            I7,'I',A50)
             ELSE
                   XM    = (XMIN + DEV*(I-1))/ORD
                   WRITE(6,9340) XM,F2,IORDR,NX,CHARR
 9340              FORMAT(1X,'I ',F6.3,' I',F6.3,'E',I3,'I',
     .                                        I7,'I',A50)
             ENDIF
  200       CONTINUE
             WRITE(6,9250)  CHR1
             WRITE(6,9260)
 9260    FORMAT(1X,
     .       '    x      d(Sig/dx)  dN/dx',4X,
     .       '"O" : Generated Events.',
     .       '( Arbitrary unit in Log )')
C
           ELSE
C
              CALL XHPLOT( 1, IHIST )
C
           ENDIF
  500    CONTINUE
      ENDIF
C
      CALL DHPLOT
C
      DO 600 IHIST = 1, NHIST
         IF( MAPL(1,IHIST) .EQ. -10 ) THEN
             CALL XHPLOT( -10, IHIST )
             GO TO 700
         ENDIF
  600 CONTINUE
  700 CONTINUE
C
      RETURN
      END
C***********************************************************************
C*=======================                                              *
C*    SUBROUTINE SHRSET                                                *
C*=======================                                              *
C*((Function))                                                         *
C*    To reset the content of histograms and scatter plots.            *
C*((Author))                                                           *
C*    S.Kawabata   June '90 at KEK                                     *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE SHRSET
      PARAMETER ( ILH = 50, IDH = 50 )
      INTEGER*4 XHASH,DHASH,MAXL,NHIST,MAPL,IFBASE,MAXD,NSCAT,MAPD
      COMMON/PLOTH/ XHASH(ILH,13),DHASH(IDH,14),IFBASE(ILH),
     .              MAXL, NHIST, MAPL(4,ILH),
     .              MAXD, NSCAT, MAPD(4,IDH),
     .              NW
      PARAMETER ( ISL = 281 )
      COMMON/PLOTB/ BUFF( ISL )
      INTEGER  IBUF( ISL )
      EQUIVALENCE (IBUF(1),BUFF(1))
      IF( NHIST .GT. 0 ) THEN
         DO 100 IHIST = 1, NHIST
            IP2       = MAPL(3,IHIST) + 52
            IP3       = MAPL(4,IHIST)
            IBUF(IP3) = -1
            DO 100 I = 0,51
               BUFF(I+IP2) = 0.0
  100      CONTINUE
      ENDIF
C
      IF( NSCAT .GT. 0 ) THEN
         DO 400   ISCAT = 1, NSCAT
            IP3         = MAPD(4,ISCAT)
            IBUF(IP3)   = 0
            IBUF(IP3+1) = 0
            IP2         = MAPD(3,ISCAT)
            IBUF(IP2)   = 0
            DO 400   I  = IP2+1,IP2+2500
               BUFF(I)  = 0.0
  400      CONTINUE
      ENDIF
C
      RETURN
      END
C***********************************************************************
C*=======================                                              *
C*    SUBROUTINE SHUPDT                                                *
C*=======================                                              *
C*((Function))                                                         *
C*    To update histograms and scatter plots with unit weight.         *
C*  The bin number to be updated is marked by XHFILL and DHFILL.       *
C*((Author))                                                           *
C*    S.Kawabata  June '90 at KEK                                      *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE SHUPDT
      PARAMETER ( ILH = 50, IDH = 50 )
      INTEGER*4 XHASH,DHASH,MAXL,NHIST,MAPL,IFBASE,MAXD,NSCAT,MAPD
      COMMON/PLOTH/ XHASH(ILH,13),DHASH(IDH,14),IFBASE(ILH),
     .              MAXL, NHIST, MAPL(4,ILH),
     .              MAXD, NSCAT, MAPD(4,IDH),
     .              NW
      PARAMETER ( ISL = 281 )
      COMMON/PLOTB/ BUFF( ISL )
      INTEGER  IBUF( ISL )
      EQUIVALENCE (IBUF(1),BUFF(1))
      IF( NHIST .GT. 0 ) THEN
         DO 150   IHIST   = 1, NHIST
            IP3       = MAPL(4,IHIST)
            IX        = IBUF(IP3)
            IF( IX .GE. 0 ) THEN
                IP       = IX + MAPL(3,IHIST) + 52
                BUFF(IP) = BUFF(IP) + 1.
                IBUF(IP3)  = -1
            ENDIF
  150    CONTINUE
      ENDIF
C
      IF( NSCAT .GT. 0 ) THEN
         DO 250   ISCAT   = 1, NSCAT
            IP3         = MAPD(4,ISCAT)
            IX          = IBUF(IP3)
            IF( IX .GT. 0 ) THEN
                IP1   = MAPD(2,ISCAT)
                MXBIN = IBUF(IP1+2)
                MYBIN = IBUF(IP1+6)
                IP2       = MAPD(3,ISCAT)
                IBUF(IP2) = IBUF(IP2) + 1
                IY        = IBUF(IP3+1)
                IF( IX .GT. 0 .AND. IX .LE. MXBIN .AND.
     .              IY .GT. 0 .AND. IY .LE. MYBIN ) THEN
                    IP       = IX + MXBIN*(IY-1) + IP2
                    BUFF(IP) = BUFF(IP) + 1.0
                ENDIF
                IBUF(IP3)   =  0
                IBUF(IP3+1) =  0
           ENDIF
C
  250    CONTINUE
      ENDIF
C
      RETURN
      END
C***********************************************************************
C*=========================                                            *
C*    SUBROUTINE XHCHCK                                                *
C*=========================                                            *
C*((Purpose))                                                          *
C*     To check the contents of the histogram table                    *
C*                                                                     *
C*((Author))                                                           *
C*      S.Kawabata    June '90                                         *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE XHCHCK
C
      PARAMETER ( ILH = 50, IDH = 50 )
      INTEGER*4 XHASH,DHASH,MAXL,NHIST,MAPL,IFBASE,MAXD,NSCAT,MAPD
      COMMON/PLOTH/ XHASH(ILH,13),DHASH(IDH,14),IFBASE(ILH),
     .              MAXL, NHIST, MAPL(4,ILH),
     .              MAXD, NSCAT, MAPD(4,IDH),
     .              NW
      PARAMETER ( ISL = 281 )
      COMMON/PLOTB/ BUFF( ISL )
      INTEGER  IBUF( ISL )
      EQUIVALENCE (IBUF(1),BUFF(1))
      COMMON /BSCNTL/ INTV, IPNT, NLOOP, MLOOP
      CHARACTER*1 CN
      CN  = CHAR(12)
      IF( IPNT .EQ. 0 ) THEN
          WRITE(6,9000)
      ELSE
          WRITE(6,9010) CN
      ENDIF
 9000 FORMAT(/1H1)
 9010 FORMAT(A1)
      WRITE(6,9050) NW
 9050 FORMAT(
     . //5X,'*********  Contents of the histogram Header *********',
     .     //1X,'(1) Actual Buffer size     = ',I6,' Words')
      WRITE(6,9100) MAXL,NHIST
 9100 FORMAT(1X,'(2) Contents of Histograms ',
     .      /1X,'    Max. No. of Histograms = ',I6,
     .      /1X,'    Number   of Histograms = ',I6)
      IF( NHIST .GT. 0 ) THEN
          WRITE(6,9200)
 9200     FORMAT(1X,'   ID     X_min        X_max    X_bin',
     .              ' Hash Hst#')
          DO 200 I = 1, 13
             NT    = XHASH(1,I)
             IF( NT .GT. 0 ) THEN
                 DO 100 J = 2, NT+1
                    K     = XHASH(J,I)
                    IP1   = MAPL(2,K)
                    IP3   = MAPL(4,K)
                    XMIN  = BUFF(IP1)
                    XMAX  = BUFF(IP1+1)
                    NBIN  = IBUF(IP1+2)
                    WRITE(6,9300) MAPL(1,K),XMIN,XMAX,NBIN,I,NT,K
 9300               FORMAT(1X,I5,1X,1PE12.4,1X,E12.4,I5,2I3,I5)
  100            CONTINUE
             ENDIF
  200     CONTINUE
      ENDIF
      WRITE(6,9400) MAXD,NSCAT
 9400 FORMAT(1X,'(3) Contents of Scatter Plots',
     .      /1X,'    Max. No. of Scat_Plots = ',I6,
     .      /1X,'    Number   of Scat_Plots = ',I6)
      IF( NSCAT .GT. 0 ) THEN
          WRITE(6,9500)
 9500     FORMAT(1X,'   ID      X_min   ',
     .              '     X_max   X-Bin    Y_min   ',
     .              '     Y_max   Y_Bin Hash Hst#')
          DO 400 I = 1, 13
             NT    = DHASH(1,I)
             IF( NT .GT. 0 ) THEN
                 DO 300 J = 2, NT+1
                    K     = DHASH(J,I)
                    IP1   = MAPD(2,K)
                    IP3   = MAPD(4,K)
                    XMIN  = BUFF(IP1)
                    XMAX  = BUFF(IP1+1)
                    NXBN  = IBUF(IP1+2)
                    YMIN  = BUFF(IP1+4)
                    YMAX  = BUFF(IP1+5)
                    NYBN  = IBUF(IP1+6)
                    WRITE(6,9600) MAPD(1,K),XMIN,XMAX,NXBN,
     .                            YMIN,YMAX,NYBN,I,NT,K
 9600               FORMAT(1X,I5,1X,1PE12.4,1X,E12.4,I5,
     .                                 E12.4,1X,E12.4,I5,2I3,I5)
  300            CONTINUE
             ENDIF
  400     CONTINUE
      ENDIF
      RETURN
      END
C***********************************************************************
C*=================================                                    *
C*    SUBROUTINE XHFILL(ID, DX, FX)                                    *
C*=================================                                    *
C*((Function))                                                         *
C*    To fill histograms.                                              *
C*  This routine identifies the bin number which is to be updated      *
C*  with weight FX*WGT.  Up to five points per histogram are able      *
C*  to be stacked before calling BHUPDT or SHUPDT.                     *
C*((Input))                                                            *
C*  ID    : Histogram identification number                            *
C*  DX    : Input value                                                *
C*  FX    : Input value of the function                                *
C*((Author))                                                           *
C*  S.Kawabata         June '90 at KEK                                 *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE XHFILL(ID, DX, FX )
C
      REAL*8 DX,FX
      REAL*8 SI,SI2,SWGT,SCHI,SCALLS,ATACC,WGT
      COMMON /BASE0/ SETIM,UTIME,IFLAG,NPRINT,IBASES
      COMMON /BASE3/ SI,SI2,SWGT,SCHI,SCALLS,ATACC,NSU,IT,WGT
      PARAMETER ( ILH = 50, IDH = 50 )
      INTEGER*4 XHASH,DHASH,MAXL,NHIST,MAPL,IFBASE,MAXD,NSCAT,MAPD
      COMMON/PLOTH/ XHASH(ILH,13),DHASH(IDH,14),IFBASE(ILH),
     .              MAXL, NHIST, MAPL(4,ILH),
     .              MAXD, NSCAT, MAPD(4,IDH),
     .              NW
      PARAMETER ( ISL = 281 )
      COMMON/PLOTB/ BUFF( ISL )
      INTEGER  IBUF( ISL )
      EQUIVALENCE (IBUF(1),BUFF(1))
C
      IF( NHIST .GT. 0 ) THEN
C
          I  = IABS(MOD( ID, 13 )) + 1
          IF( XHASH(1, I) .EQ. 1 ) THEN
            IF( ID .EQ. MAPL( 1, XHASH(2,I))) THEN
                IHIST = XHASH(2,I)
                GO TO 200
            ENDIF
          ELSEIF( XHASH(1, I) .GT. 1 ) THEN
            DO 100 K = 2, XHASH(1,I)+1
               IF( ID .EQ. MAPL( 1, XHASH(K,I))) THEN
                   IHIST = XHASH(K,I)
                   GO TO 200
               ENDIF
  100       CONTINUE
          ENDIF
      ENDIF
C     WRITE(6,9000) ID
C9000 FORMAT(1X,'No Histogram corresponds to ID =',I5,
C    .      /1X,' This call is neglected.')
      RETURN
C
  200 X     = DX*1.0
          IX    = -1
          IP1   = MAPL(2,IHIST)
          XMIN  = BUFF(IP1)
          XMAX  = BUFF(IP1+1)
          NXBIN = IBUF(IP1+2)
          DEV   = BUFF(IP1+3)
          IF(     X .LT. XMIN ) THEN
                  IX   = 0
          ELSEIF( X .GT. XMAX ) THEN
                 IX   = NXBIN + 1
          ELSE
                 IX   = INT((X - XMIN)/DEV + 1.0)
                 IF( IX .GT. NXBIN ) IX = NXBIN
          ENDIF
      IF( IBASES .EQ. 1 ) THEN
          IP2       = MAPL(3,IHIST) + IX
          IBUF(IP2) = IBUF(IP2) + 1
          FXWGT     = FX*WGT
          IP2       = IP2 + 52
          BUFF(IP2) = BUFF(IP2) + FXWGT
          IP2       = IP2 + 52
          BUFF(IP2) = BUFF(IP2) + FXWGT*FXWGT
      ELSE
         IP3        =  MAPL(4,IHIST)
         IBUF(IP3)  = IX
      ENDIF
C
      RETURN
      END
C   =====================================
      SUBROUTINE XHGRID( LUNIT )
C   =====================================
C
      IMPLICIT REAL*8 (A-H,O-Z)
      PARAMETER (MXDIM = 50, NDMX = 50, LENG = 32768)
      COMMON /BASE1/ XL(MXDIM),XU(MXDIM),NDIM,NWILD,
     .               IG(MXDIM),NCALL
      COMMON /BASE4/ XI(NDMX,MXDIM),DX(MXDIM),DXD(LENG),DXP(LENG),
     .               ND,NG,NPG,MA(MXDIM)
      COMMON /BASE6/ D(NDMX,MXDIM)
      CHARACTER*50 WINDOW(8)
      DATA WINDOW /'SET WINDOW X FROM  1.0 TO  5.0 Y FROM  8.0 TO 11.5',
     .             'SET WINDOW X FROM  5.5 TO  9.5 Y FROM  8.0 TO 11.5',
     .             'SET WINDOW X FROM 10.0 TO 14.0 Y FROM  8.0 TO 11.5',
     .             'SET WINDOW X FROM 14.5 TO 18.5 Y FROM  8.0 TO 11.5',
     .             'SET WINDOW X FROM  1.0 TO  5.0 Y FROM  3.0 TO  6.5',
     .             'SET WINDOW X FROM  5.5 TO  9.5 Y FROM  3.0 TO  6.5',
     .             'SET WINDOW X FROM 10.0 TO 14.0 Y FROM  3.0 TO  6.5',
     .             'SET WINDOW X FROM 14.5 TO 18.5 Y FROM  3.0 TO  6.5'/
      REAL*4 X(8),Y(8)
      DATA X     /  2.0, 6.5, 11.0, 15.5, 2.0, 6.5, 11.0, 15.5 /
      DATA Y     /  4*7.5, 4*2.5/
      NO     = 0
      XND    = FLOAT(ND)
      MPAGE  = (NDIM-1)/8 + 1
      DO 1000 NPAGE = 1, MPAGE
         NFIGS = 8
         IF( NPAGE .EQ. MPAGE ) NFIGS = MOD(NDIM, 8)
         IF( NFIGS .GT. 0 ) THEN
            WRITE( LUNIT, 9000)
 9000       FORMAT(1X,'NEW FRAME')
            WRITE( LUNIT, 9001)
 9001       FORMAT(1X,'SET FONT DUPLEX')
            WRITE( LUNIT, 9002)
 9002       FORMAT(1X,'SET SIZE 20 BY 14.00')
            DO 500 NF = 1, NFIGS
               NO    = NO + 1
               WRITE( LUNIT, 9003) WINDOW(NF)
 9003          FORMAT(1X,A)
               WRITE( LUNIT, 9004) XND
 9004          FORMAT(1X,'SET LIMIT X FROM 0.0 TO ',G12.4,
     .               /1X,'SET LABEL LEFT OFF')
               WRITE( LUNIT, 9005)
 9005          FORMAT(1X,'SET INTENSITY 4',
     .               /1X,'SET TICK SIZE 0.04',
     .               /1X,'SET ORDER X Y ')
               DO 200 I = 1, ND
                  WRITE( LUNIT, 9006) FLOAT(I),D(I,NO)
 9006             FORMAT(1X,2G12.4)
  200          CONTINUE
               WRITE( LUNIT, 9007)
 9007          FORMAT(1X,'HIST')
               WRITE( LUNIT, 9008 ) X(NF),Y(NF),NF
 9008          FORMAT(1X,'TITLE ',2G12.4,''' Dim # ', I3)
  500       CONTINUE
         ENDIF
 1000 CONTINUE
      RETURN
      END
C***********************************************************************
C*===============================================                      *
C*    SUBROUTINE XHINIT(ID,DXMIN,DXMAX,NBIN,TNAME)                     *
C*===============================================                      *
C*((Function))                                                         *
C*    To define a histogram.                                           *
C*((Input))                                                            *
C*   ID   : Histogram identification number                            *
C*   DXMIN: Lower limit of the histogram                               *
C*   DXMAX: Upper limit of the histogram                               *
C*   NBIN : Number of bins for the histogram (Max. is 50 )             *
C*   TNAME: Title of the histogram in the character string (upto 64    *
C*           characters)                                               *
C*((Author))                                                           *
C*   S.Kawabata    June '90                                            *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE XHINIT(ID,DXMIN,DXMAX,NBIN,TNAME)
C
      REAL*8 DXMIN, DXMAX
      CHARACTER*(*) TNAME
      CHARACTER*68  NAME
      PARAMETER ( ILH = 50, IDH = 50 )
      INTEGER*4 XHASH,DHASH,MAXL,NHIST,MAPL,IFBASE,MAXD,NSCAT,MAPD
      COMMON/PLOTH/ XHASH(ILH,13),DHASH(IDH,14),IFBASE(ILH),
     .              MAXL, NHIST, MAPL(4,ILH),
     .              MAXD, NSCAT, MAPD(4,IDH),
     .              NW
      PARAMETER ( ISL = 281 )
      COMMON/PLOTB/ BUFF( ISL )
      INTEGER  IBUF( ISL )
      EQUIVALENCE (IBUF(1),BUFF(1))
      COMMON/XHCNTL/ LOCK
C
      IF((NHIST .GE. MAXL-1) .AND. (ID .GT. 0) ) THEN
          IF( LOCK .NE. 0 ) RETURN
          WRITE(6,9000) MAXL-1,ID
 9000     FORMAT(1X,'Number of Histograms exceeds',I3,' at ID =',I5,
     .          /1X,' This call is neglected.')
         RETURN
      ENDIF
      I  = IABS(MOD( ID, 13 )) + 1
      IF( XHASH(1, I) .EQ. 1 ) THEN
            IF( ID .EQ. MAPL( 1, XHASH(2,I))) THEN
                IF( LOCK .NE. 0 ) RETURN
                WRITE(6,9100) ID
 9100           FORMAT(1X,'HISTOGRAM ID (',I3,' ) exists already.'
     .                /1X,' This call is neglected.')
                RETURN
            ENDIF
      ELSEIF( XHASH(1, I) .GT. 1 ) THEN
          DO 100 K = 2, XHASH(1,I)+1
            IF( ID .EQ. MAPL( 1, XHASH(K,I))) THEN
                IF( LOCK .NE. 0 ) RETURN
                WRITE(6,9100) ID
                RETURN
            ENDIF
  100    CONTINUE
      ENDIF
      XMIN  = DXMIN*1.0
      XMAX  = DXMAX*1.0
      IF(NBIN  .GT. 50 ) THEN
         WRITE(6,9200) NBIN,ID
 9200    FORMAT(1X,'Bin size (',I3,' )  exceeds 50 at ID =',I5,
     .         /1X,' This call is neglected.')
         RETURN
      ENDIF
      IF(XMIN  .GE. XMAX ) THEN
         WRITE(6,9300) ID
 9300    FORMAT(1X,'Lower limit is larger than upper at ID =',I5,
     .         /1X,' This call is neglected.')
         RETURN
      ENDIF
      IF(XHASH(1,I) .GE. 49 ) THEN
         WRITE(6,9400) I
 9400    FORMAT(1X,I5,'-th Hash table overflow',
     .         /1X,' This call is neglected.')
         RETURN
      ENDIF
      NHIST        = NHIST + 1
      XHASH(1,I)   = XHASH(1,I) + 1
      K            = XHASH(1,I) + 1
      XHASH(K,I)   = NHIST
      IP1    = NW + 1
         NW  = NW + 281
         MAPL(1,NHIST)  = ID
         MAPL(2,NHIST)  = IP1
         BUFF(IP1     ) = XMIN
         BUFF(IP1 +  1) = XMAX
         IBUF(IP1 +  2) = NBIN
         DEV            = XMAX - XMIN
         BUFF(IP1 +  3) = DEV/NBIN
      IP2   = IP1 + 4
         MAPL(3,NHIST)  = IP2
      IP3   = IP1 + 264
         MAPL(4,NHIST)  = IP3
         IBUF(IP3)      = -1
         I1   = IP3 + 1
         I2   = I1 + 15
         NAME = TNAME
         READ(NAME,9800) (BUFF(I),I=I1,I2)
 9800    FORMAT(16A4)
C
 1000 CONTINUE
      RETURN
      END
C***********************************************************************
C*                                                                     *
C*=============================================                        *
C*    SUBROUTINE XHORDR( VAL, F2, ORDER, IORDR)                        *
C*=============================================                        *
C*((Function))                                                         *
C*    To resolve the real number VAL into mantester and exponent parts.*
C*  When VAL = 1230.0 is given, output are                             *
C*        F2 = 1.2  and ORDER = 4.0.                                   *
C*((Input))                                                            *
C*  VAL  : Real*4 value                                                *
C*((Output))                                                           *
C*  F2   : The upper two digits is given                               *
C*  ORDER: Order is given                                              *
C*  IORDR: Exponent is given                                           *
C*((Author))                                                           *
C*  S.Kawabata                                                         *
C*                                                                     *
C***********************************************************************
      SUBROUTINE XHORDR(VAL, F2, ORDER, IORDR)
      IF( VAL .NE. 0.0 ) THEN
          ORDER    =  LOG10( VAL )
          IORDR    =  INT( ORDER )
          IF( ORDER .LT. 0.0 ) IORDR = IORDR - 1
          ORDER  = 10.0**IORDR
          F2     = VAL/ORDER
      ELSE
          IORDR  = 0
          ORDER  = 1.0
          F2    = 0.0
      ENDIF
      RETURN
      END
C***********************************************************************
C*======================================                               *
C*    SUBROUTINE XHPLOT( IFG,  IHIST )                                 *
C*=====================================                                *
C*((Purpose))                                                          *
C*     To print histograms for BASES and SPRING.                       *
C*((Input))                                                            *
C*     IFG  : Flag which indicats whether this is called by BASES      *
C*            or SPRING.  IFG = ( 0 / anyother) = ( By BASES/ SPRING)  *
C*     IHIST: Serial number of the histogram                           *
C*                                                                     *
C*((Author))                                                           *
C*      S.Kawabata    June '90 at KEK                                  *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE XHPLOT( IFG, IHIST )
C
      REAL*8         SI,SI2,SWGT,SCHI,SCALLS,ATACC,WGT
      COMMON /BASE3/ SI,SI2,SWGT,SCHI,SCALLS,ATACC,NSU,IT,WGT
      PARAMETER ( ILH = 50, IDH = 50 )
      INTEGER*4 XHASH,DHASH,MAXL,NHIST,MAPL,IFBASE,MAXD,NSCAT,MAPD
      COMMON/PLOTH/ XHASH(ILH,13),DHASH(IDH,14),IFBASE(ILH),
     .              MAXL, NHIST, MAPL(4,ILH),
     .              MAXD, NSCAT, MAPD(4,IDH),
     .              NW
      PARAMETER ( ISL = 281 )
      COMMON/PLOTB/ BUFF( ISL )
      INTEGER  IBUF( ISL )
      EQUIVALENCE (IBUF(1),BUFF(1))
      COMMON /BSCNTL/ INTV, IPNT, NLOOP, MLOOP
      REAL  VAL(0:51),VLOG(0:51),VERR(0:51)
      CHARACTER*50 CHARR,CHAR1
      CHARACTER*52 SCALE
      CHARACTER*1  BLNK,STAR,OO,AI,CN
      DATA  YMAX / 50/
      DATA  BLNK /' '/, STAR /'*'/, OO /'O'/, AI /'I'/
      CN    = CHAR(12)
      IP3   = MAPL(4,IHIST)
      IF(     IFG .EQ. 0 ) THEN
            IF( IPNT .EQ. 0 ) THEN
                WRITE(6,9000)
            ELSE
                WRITE(6,9005) CN
            ENDIF
 9000       FORMAT(/1H1)
 9005       FORMAT(A1)
            WRITE(6,9100) MAPL(1,IHIST),(BUFF(I),I=IP3+1,IP3+16)
 9100       FORMAT(1X,'Histogram (ID =',I3,' ) for ',16A4)
      ELSEIF( IFG .EQ. -10 ) THEN
            IF( IPNT .EQ. 0 ) THEN
                WRITE(6,9000)
            ELSE
                WRITE(6,9005) CN
            ENDIF
            WRITE(6,9102) (BUFF(I),I=IP3+1,IP3+16)
 9102       FORMAT(5X,16A4)
      ELSE
            IF( IPNT .EQ. 0 ) THEN
                WRITE(6,9000)
            ELSE
                WRITE(6,9005) CN
            ENDIF
            WRITE(6,9105) MAPL(1,IHIST),(BUFF(I),I=IP3+1,IP3+16)
 9105       FORMAT(
     .      1X,'Additional Histogram (ID =',I3,' ) for ',16A4)
      ENDIF
      IP1   = MAPL(2,IHIST)
      XMIN  = BUFF(IP1)
      XMAX  = BUFF(IP1+1)
      NXBIN = IBUF(IP1+2) + 1
      DEV   = BUFF(IP1+3)
      IP2   = MAPL(3,IHIST)
      IF( IFG .EQ. 0 ) THEN
          NTOTAL     = SCALLS
          FACT       = 1./(NTOTAL*DEV)
          IPF   = IP2 + 156
          IPF2  = IPF + 52
          VAL(0)     = BUFF(IPF)/NTOTAL
          VAL(NXBIN) = BUFF(IPF+NXBIN)/NTOTAL
          VMAX       = FACT*BUFF(IPF+1)
          VMIN       = VMAX
          DO  50 I   = 1,NXBIN-1
              TX     = BUFF(I+IPF)
              NX     = IBUF(I+IP2)
              VLS    = TX*FACT
              IF( VMAX .LT. VLS ) VMAX = VLS
              IF( VMIN .GT. VLS ) VMIN = VLS
              VAL(I) = VLS
              IF( NX .GT. 1 ) THEN
                  DEV2   =  NX*BUFF(I+IPF2)-TX*TX
                  IF( DEV2 .LE. 0.0 ) THEN
                      VERR(I)= 0.0
                  ELSE
                      VERR(I)= FACT*SQRT( DEV2/( NX-1 ))
                  ENDIF
              ELSEIF( NX .EQ. 1 ) THEN
                  VERR(I)= VLS
              ELSE
                  VERR(I)= 0.0
              ENDIF
   50     CONTINUE
      ELSE
          IPX   = IP2 + 52
          VAL(0)     = BUFF(IPX)
          VAL(NXBIN) = BUFF(IPX+NXBIN)
          NTOTAL     = VAL(0) + VAL(NXBIN)
          VMIN       = 0.0
          VMAX       = VMIN
          DO  55 I   = 1,NXBIN-1
              VLS    = BUFF(I+IPX)
              NTOTAL = VLS + NTOTAL
              IF( VMAX .LT. VLS ) VMAX = VLS
              VAL(I) = VLS
              IF( VLS .GT. 0.0 ) THEN
                  VERR(I) = SQRT(VLS)
              ELSE
                  VERR(I) = 0.0
              ENDIF
   55     CONTINUE
       ENDIF
***
       IF( VMAX .EQ. 0.0 .AND. VMIN .EQ. 0.0) THEN
           V0 = VAL(0)
           VM = VAL(NXBIN)
           IF( V0 .GE. 0.0 .AND. VM .GE. 0.0 ) THEN
               VMIN  = 0.0
               IF( V0 .GT. VM  ) THEN
                   VMAX = V0
               ELSE
                   VMAX = VM
               ENDIF
           ELSEIF( V0 .LT. 0.0 .AND. VM .LT. 0.0 ) THEN
               VMAX  = 0.0
               IF( V0 .LT. VM ) THEN
                   VMIN  = V0
               ELSE
                   VMIN  = VM
               ENDIF
           ELSEIF( V0 .GT. VM ) THEN
               VMAX  = V0
               VMIN  = VM
           ELSE
               VMAX  = VM
               VMIN  = V0
           ENDIF
       ENDIF
***
       IF( VMIN .GE. 0.0 ) THEN
C//VV
           IF( VMAX .GT. 0.0 ) THEN
               VLMAX = LOG10(VMAX)
           ELSE
               VLMAX = 2.0
           ENDIF
C//
           VLMIN = VLMAX
           DO  60 I = 0,NXBIN
               IF( VAL(I) .GT. 0.0 ) THEN
                   VLS   = LOG10( VAL(I) )
                   IF( I .GT. 0 .AND. I .LT. NXBIN ) THEN
                       IF( VLS .LT. VLMIN ) VLMIN = VLS
                   ENDIF
                   VLOG(I)  = VLS
C//VV
C              ELSE
C                  VLOG(I)  = 0.0
               ENDIF
   60      CONTINUE
           IF( VLMIN .LT. 0.0) THEN
               VXMIN = IFIX(VLMIN) - 1.0
           ELSE
               VXMIN = IFIX(VLMIN)
           ENDIF
           VXMAX = VLMAX
           IFLG  = 1
           CALL XHRNGE( IFLG, VXMIN, VXMAX, VLMIN, VLMAX, VLSTP )
           UNITL = (VLMAX-VLMIN)/YMAX
       ENDIF
       IFLG   = 0
       IF( VMAX .GT. 0.0 ) THEN
           IF( VMIN .GE. 0.0 ) THEN
               VXMAX  = 1.2*VMAX
               VXMIN  = 0.0
               CALL XHRNGE( IFLG, VXMIN, VXMAX, VMIN, VMAX, VSTP )
           ELSE
               VXMAX  = 1.1*VMAX
               VXMIN  = 1.1*VMIN
               CALL XHRNGE( IFLG, VXMIN, VXMAX, VMIN, VMAX, VSTP )
           ENDIF
       ELSE
          VXMAX  = 0.0
          VXMIN  = 1.1*VMIN
          CALL XHRNGE( IFLG, VXMIN, VXMAX, VMIN, VMAX, VSTP )
       ENDIF
       UNIT  = (VMAX-VMIN)/YMAX
       CALL XHSCLE( IFLG, VMIN, VMAX, VSTP, UNIT, SCALE, CHAR1 )
C
C
       IF( IFG .EQ. 0 ) THEN
           WRITE(6,9150)
 9150      FORMAT(30X,'Linear Scale indicated by "*"')
           WRITE(6,9200) SCALE
 9200      FORMAT(1X,'    x      d(Sigma)/dx    ',A52)
           WRITE(6,9250)  CHAR1
 9250      FORMAT(1X,
     .                '+-------+------------------+',
     .           A50 )
       ELSE
             WRITE(6,9210) NTOTAL
 9210        FORMAT(1X,'Total =',I10,' events',
     .        3X,'"*" : No. of events in Linear scale.')
             WRITE(6,9205) SCALE
 9205        FORMAT(1X,'    x      Lg(dN/dx)  dN/dx',A52)
             WRITE(6,9251)  CHAR1
 9251        FORMAT(1X,
     .             '+--------+----------+-------+',
     .       A50 )
       ENDIF
       VX    = ABS(XMAX)
       XM    = ABS(XMIN)
       IF( XM .GT. VX ) VX = XM
       CALL XHORDR( VX, F2, ORD, IORD )
       IF( VMIN .LT. 0.0 ) THEN
           V1    = VMIN
           NUMBL = 1
           DO 150 I = 1, 80
              V2    = V1 + UNIT
              IF( V1 .LE. 0.0 .AND. V2 .GE. 0.0 ) THEN
                  NUMBL  = I
                  GO TO 180
              ENDIF
              V1    = V2
  150      CONTINUE
       ENDIF
  180  DO 300 I = 0,NXBIN
          VX   = VAL(I)
          IF( VMIN .GE. 0.0 ) THEN
              IF( VX .GT. 0.0 ) THEN
                  NUMBL  = (VLOG(I) - VLMIN)/UNITL + 1.0
                  NUMB   = VX/UNIT + 1.0
              ELSE
                  NUMBL  = 0
                  NUMB   = 0
              ENDIF
              IF( NUMB .GT. 50 ) NUMB = 50
              IF( NUMBL.GT. 50 ) NUMBL= 50
              DO 200 K = 1,50
                 IF(     ( K .GT. NUMBL) .AND. (K .GT. NUMB ) ) THEN
                           IF( K .EQ. 50 ) THEN
                               CHARR(K:K) = AI
                           ELSE
                               CHARR(K:K) = BLNK
                           ENDIF
                 ELSEIF( ( K .LE. NUMBL) .AND. (K .GT. NUMB )) THEN
                           CHARR(K:K) = OO
                 ELSEIF( ( K .GT. NUMBL) .AND. (K .LE. NUMB )) THEN
                           CHARR(K:K) = STAR
                 ELSEIF( ( K .LE. NUMBL) .AND. (K .LE. NUMB)) THEN
                           IF( NUMB .GE. NUMBL ) THEN
                               CHARR(K:K) = OO
                           ELSE
                               CHARR(K:K) = STAR
                           ENDIF
                 ENDIF
  200         CONTINUE
          ELSE
              V1          = VMIN
              NHIG        = 1
              DO 220  J = 1, 50
                 V2     = V1 + UNIT
                 IF( VX .GE. V1 .AND. VX .LT. V2 ) THEN
                     NHIG   = J
                     GO TO 240
                 ENDIF
                 V1    = V2
  220         CONTINUE
  240         NLOW   = NUMBL
              IF( NHIG .LT. NLOW) THEN
                  NX    = NHIG
                  NHIG  = NLOW
                  NLOW  = NX
              ENDIF
              DO 250 K = 1, 49
                 IF(     K .EQ. NUMBL ) THEN
                         CHARR(K:K) = AI
                 ELSEIF( K .GT. NHIG ) THEN
                         CHARR(K:K) = BLNK
                 ELSEIF( K .LT. NLOW ) THEN
                         CHARR(K:K) = BLNK
                 ELSE
                     IF( K .EQ. NHIG .AND. K .EQ. NLOW) THEN
                         CHARR(K:K) = AI
                     ELSE
                         CHARR(K:K) = STAR
                     ENDIF
                 ENDIF
  250         CONTINUE
              CHARR(50:50) = AI
          ENDIF
          IF( IFG .EQ. 0 ) THEN
              NX     = IBUF(I+IP2)
              VX     = VAL(I)
              VX1    = VX
              IF( VX .LT. 0.0 ) VX1 = -VX
              IF( I .EQ. 0 .OR. I. EQ. NXBIN ) THEN
                  CALL XHORDR( VX1, F2, ORDER, IORDR )
                  F2     = VX/ORDER
                  WRITE(6,9300) IORD,F2,IORDR,CHARR
 9300             FORMAT(1X,'I  E',I3,' I',F6.3,8X,'E',I3,
     .                                     'I',A50)
              ELSE
                  XM    = (XMIN + DEV*(I-1))/ORD
                  VE     = VERR(I)
                  IF( VE .GT. VX1 ) THEN
                      CALL XHORDR(  VE, F2, ORDER, IORDR )
                  ELSE
                      CALL XHORDR( VX1, F2, ORDER, IORDR )
                  ENDIF
                  F2   = VX/ORDER
                  VE   = VE/ORDER
                  WRITE(6,9340) XM,F2,VE,IORDR,CHARR
 9340             FORMAT(1X,'I', F6.3,' I',F6.3,'+-',F5.3,' E',I3,
     .                                    'I',A50)
             ENDIF
          ELSE
             NX  = VAL(I)
             VX     = VAL(I)
             VX1    = VX
             IF( VX .LT. 0.0 ) VX1 = -VX
             CALL XHORDR( VX1, F2, ORDER, IORDR )
             F2     = VX/ORDER
             IF( I .EQ. 0 .OR. I .EQ. NXBIN ) THEN
                 WRITE(6,9400) IORD,F2,IORDR,NX,CHARR
 9400            FORMAT(1X,'I   E',I3,' I',F6.3,'E',I3,'I',
     .                                            I7,'I',A50)
             ELSE
                   XM  = (XMIN + DEV*(I - 1))/ORD
                   WRITE(6,9440) XM,F2,IORDR,NX,CHARR
 9440              FORMAT(1X,'I ',F6.3,' I',F6.3,'E',I3,'I',
     .                                        I7,'I',A50)
             ENDIF
          ENDIF
  300  CONTINUE
       IF( VMIN .GE. 0.0 ) THEN
           CALL XHSCLE( 1, VLMIN, VLMAX, VLSTP, UNITL, SCALE, CHAR1)
           VXMIN  = 10**VLMIN
       ENDIF
       IF( IFG .EQ. 0 ) THEN
           WRITE(6,9250) CHAR1
           IF( VMIN .GE. 0.0 ) THEN
               WRITE(6,9200) SCALE
               WRITE(6,9260)
 9260          FORMAT(30X,'Logarithmic Scale indicated by "O"')
           ELSE
               WRITE(6,9200) SCALE
           ENDIF
       ELSE
           WRITE(6,9251) CHAR1
           WRITE(6,9205) SCALE
           WRITE(6,9360)
 9360      FORMAT(30X,'"O" : No. of Events in Log. scale.')
       ENDIF
C
  500  CONTINUE
      RETURN
      END
C***********************************************************************
C*                                                                     *
C*============================================================         *
C*  SUBROUTINE XHRNGE( IFLG, VMIN, VMAX, VTMIN, VTMAX, STEP)           *
C*============================================================         *
C*((Function))                                                         *
C*    Determine the vertical range of the histogram.                   *
C*((Input))                                                            *
C*    IFLG   : Flag which indicates whether logarithmic or linear      *
C*             scale.  IFLG = ( 1 / any other ) = ( log / linear )     *
C*    VMIN,VMAX : Minimum and maximum values of vertical window.       *
C*((Output))                                                           *
C*    VTMIN,VTMAX : Minimum and maxmum values of optimized vertical    *
C*                  window.                                            *
C*    STEP   : step of scale for the optimized vertical window         *
C*((Author))                                                           *
C*    S.Kawabata    Oct '85  at KEK                                    *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE XHRNGE( IFLG, VMIN, VMAX, VTMIN, VTMAX, STEP)
C
C     IFLG =    1 : Log scale
C            other: Linear scale
C
      PARAMETER ( NBIN  = 25 )
      REAL    WIND(NBIN),STP1(NBIN),STP2(NBIN)
C
      DATA WIND/
     .   1.00, 1.10, 1.20, 1.30, 1.40, 1.50, 1.60, 1.80, 2.00,  2.20,
     .   2.50, 2.70, 3.00, 3.30, 3.60, 4.00, 4.50, 5.00, 5.50,  6.00,
     .   6.50, 7.00, 8.00, 9.00, 10.0/
*     DATA STP1/
*    .   0.20, 0.22, 0.30, 0.26, 0.28, 0.30, 0.32, 0.36, 0.40,  0.44,
*    .   0.50, 0.54, 0.60, 0.66, 0.60, 0.80, 0.90, 1.00, 1.10,  1.00,
*    .   1.30, 1.00, 1.60, 1.80, 2.00/
      DATA STP1/
     .   0.250,0.275,0.300,0.325,0.350,0.375,0.400,0.450,0.500,0.550,
     .   0.625,0.675,0.750,0.825,0.900,1.000,1.125,1.250,1.375,1.500,
     .   1.625,1.750,2.000,2.250,2.500/
      DATA STP2/
     .   1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00,  1.00,
     .   1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00, 1.00,  2.00,
     .   2.00, 2.00, 2.00, 2.00, 2.00/
C
          XMAX   = VMAX
          XMIN   = VMIN
          IFLAG  = IFLG
          IF( IFLG .NE. 1 .AND. VMIN .LT. 0.0 ) THEN
              IF( VMAX .LE. 0.0 )THEN
                  IFLAG  = 2
                  XMAX  = - VMIN
                  XMIN  =  0.0
              ELSE
                  AVMIN  = - VMIN
                  XMIN  =0.0
                  IF( VMAX .GE. AVMIN ) THEN
                      IFLAG  = 3
                      XMAX  = VMAX
                      XMIN1 = AVMIN
                  ELSE
                      IFLAG  = 4
                      XMAX  = AVMIN
                      XMIN1 = VMAX
                  ENDIF
              ENDIF
          ENDIF
          DSCALE = XMAX - XMIN
          CALL XHORDR( DSCALE, DSF2, DSORDR, IORD)
          DO 100 I = 2, 25
             IF( DSF2 .GE. WIND(I-1) .AND.
     .           DSF2 .LE. WIND( I )       ) GO TO 200
 100      CONTINUE
          I = 25
C
 200      CONTINUE
          XMAX = WIND(I)*DSORDR + XMIN
          IF(     DSORDR .GE. 10.0 .OR. IFLG .NE. 1 ) THEN
                  STEP1  = STP1(I)
                  STEP   = STEP1*DSORDR
          ELSE
                  STEP1  = STP2(I)
                  STEP   = STEP1
          ENDIF
          IF(     IFLAG .LE. 1 ) THEN
                  VTMAX  = XMAX
                  VTMIN  = XMIN
          ELSEIF( IFLAG .EQ. 2 ) THEN
                  VTMAX  = XMIN
                  VTMIN  = -XMAX
          ELSE
                  XPLUS   = 0.0
                  DO 300 J = 1, 10
                     XPLUS = XPLUS + STEP
                     IF( XPLUS .GT. XMIN1 ) GO TO 400
 300              CONTINUE
 400              XMIN = XPLUS
                  XMAX = XMAX
                  IF( IFIX((WIND(I)+0.1)/STEP1)+J .GT. 7 ) THEN
                      STEP = 2.0*STEP
                  ENDIF
                  IF( IFLAG .EQ. 3 ) THEN
                      VTMAX  = XMAX
                      VTMIN  = -XMIN
                  ELSE
                      VTMAX  = XMIN
                      VTMIN  = -XMAX
                  ENDIF
          ENDIF
C
      RETURN
      END
C***********************************************************************
C*==================================                                   *
C*    SUBROUTINE XHSAVE( LUNIT, ID )                                   *
C*==================================                                   *
C*((Purpose))                                                          *
C*     To write the ID-th histogram on the unit LUNIT.                 *
C*((Input))                                                            *
C*     LUNIT: Logical unit number                                      *
C*     ID   : Historgram ID                                            *
C*                                                                     *
C*((Author))                                                           *
C*      S.Kawabata   June '90 at KEK                                   *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE XHSAVE( LUNIT, ID )
C
      REAL*8         SI,SI2,SWGT,SCHI,SCALLS,ATACC,WGT
      COMMON /BASE3/ SI,SI2,SWGT,SCHI,SCALLS,ATACC,NSU,IT,WGT
      PARAMETER ( ILH = 50, IDH = 50 )
      INTEGER*4 XHASH,DHASH,MAXL,NHIST,MAPL,IFBASE,MAXD,NSCAT,MAPD
      COMMON/PLOTH/ XHASH(ILH,13),DHASH(IDH,14),IFBASE(ILH),
     .              MAXL, NHIST, MAPL(4,ILH),
     .              MAXD, NSCAT, MAPD(4,IDH),
     .              NW
      PARAMETER ( ISL = 281 )
      COMMON/PLOTB/ BUFF( ISL )
      INTEGER  IBUF( ISL )
      EQUIVALENCE (IBUF(1),BUFF(1))
C
      IF( NHIST .GT. 0 ) THEN
C
          I  = IABS(MOD( ID, 13 )) + 1
          IF( XHASH(1, I) .EQ. 1 ) THEN
            IF( ID .EQ. MAPL( 1, XHASH(2,I))) THEN
                IHIST = XHASH(2,I)
                GO TO 200
            ENDIF
          ELSEIF( XHASH(1, I) .GT. 1 ) THEN
            DO 100 K = 2, XHASH(1,I)+1
               IF( ID .EQ. MAPL( 1, XHASH(K,I))) THEN
                   IHIST = XHASH(K,I)
                   GO TO 200
               ENDIF
  100       CONTINUE
          ENDIF
      ENDIF
      WRITE(6,9000) ID
 9000 FORMAT(1X,'************* Warning from XHSAVE *************',
     .      /1X,' Histogram ID(',I5,' ) is illegal.',
     .      /1X,' This call is neglected.',
     .      /1X,'**********************************************')
      RETURN
  200 NTOTAL= SCALLS
      IP1   = MAPL(2,IHIST)
      XMIN  = BUFF(IP1)
      XMAX  = BUFF(IP1+1)
      NXBIN = IBUF(IP1+2)
      DEV   = BUFF(IP1+3)
      IP2   = MAPL(3,IHIST)
      IP3   = MAPL(4,IHIST)
      WRITE(6,9200) ID,LUNIT,(BUFF(I),I=IP3+1,IP3+15),
     .              NTOTAL,NXBIN,DEV
 9200 FORMAT(/1H1,
     .      1X,'** Histogram ID(',I5,' ) was saved in Unit(',I2,') **',
     .      /1X,'Title : ',15A4,
     .      /1X,'Entries     =',I10,
     .      /1X,'No. of bins =',I10,'  Width =',G13.4)
      WRITE( LUNIT, 9300) ID
 9300 FORMAT('(...... ID =',I5,' ......')
      WRITE( LUNIT, 9400)
 9400 FORMAT(1X,'NEW FRAME',
     .      /1X,'SET FONT DUPLEX')
      WRITE( LUNIT, 9500) (BUFF(I), I=IP3+1,IP3+15)
 9500 FORMAT(1X,'TITLE TOP ','''',15A4,'''')
      WRITE( LUNIT, 9600) XMIN,XMAX
 9600 FORMAT(1X,'SET LIMIT X FROM ',G12.4,'TO ',G12.4)
      WRITE( LUNIT, 9700)
 9700 FORMAT(1X,'SET INTENSITY 4',
     .      /1X,'SET TICK SIZE 0.04',
     .      /1X,'SET ORDER X Y DY')
      IPF   = IP2 + 156
      IPF2  = IPF + 52
      FACT       = 1./(NTOTAL*DEV)
      DO 400 I = 1, NXBIN
         TX     = BUFF(I+IPF)
         NX     = IBUF(I+IP2)
         VLS    = TX*FACT
         IF( NX .GT. 1 ) THEN
             DEV2   =  NX*BUFF(I+IPF2)-TX*TX
             IF( DEV2 .LE. 0.0 ) THEN
                 VER = 0.0
             ELSE
                 VER = FACT*SQRT( DEV2/( NX-1 ))
             ENDIF
         ELSEIF( NX .EQ. 1 ) THEN
             VER = VLS
         ELSE
             VER = 0.0
         ENDIF
         XX     = XMIN + DEV*(FLOAT(I) - 0.5)
         WRITE( LUNIT, 9800) XX, VLS, VER
 9800    FORMAT(1X,E11.4,3X,E14.7,3X,E14.7)
  400 CONTINUE
      WRITE( LUNIT, 9900)
 9900 FORMAT( 1X,'HIST')
      RETURN
      END
C
C***********************************************************************
C*                                                                     *
C*===================================================================  *
C*  SUBROUTINE XHSCLE( IFLG,VMIN,VMAX,VSTP,UNIT,SCALE,CHAR)            *
C*===================================================================  *
C*((Function))                                                         *
C*    Determine the vertical scale and make it's format                *
C*((Input))                                                            *
C*    IFLG   : Flag which indicates whether logarithmic or linear      *
C*             scale.  IFLG = ( 1 / any other ) = ( log / linear )     *
C*    VMIN,VMAX : Minimum and maximum values of vertical window.       *
C*    VSTEP  : Step of unit scale                                      *
C*    UNIT   : Unit of one mark *(or o)                                *
C*((Output))                                                           *
C*    NSCL   : Number of scale mark                                    *
C*    NBLK   : Number of blanks between scale marks                    *
C*    CHAR   : Format of scale                                         *
C*((Author))                                                           *
C*    S.Kawabata    Oct '85  at KEK                                    *
C*                                                                     *
C***********************************************************************
      SUBROUTINE XHSCLE( IFLG,VMIN,VMAX,VSTP,UNIT,SCALE,CHAR)
C
      CHARACTER*50 CHAR
      CHARACTER*52 SCALE
      CHARACTER*1 PLUS,MINUS
      DATA PLUS /'+'/, MINUS /'-'/
C     IFLG =    1 : Log scale
C            other: Linear scale
      WRITE(SCALE,9000)
 9000 FORMAT(5('          '))
      IF( IFLG .EQ. 1 ) THEN
          SC  = 10.**VMIN
      ELSE
          SC  = VMIN
      ENDIF
      WRITE(SCALE(1:8),9100) SC
 9100 FORMAT(1P,E8.1)
      I2    = 8
      STV   = VSTP + VMIN
      STV1  = STV
      VAL1  = VMIN
      CHAR(50:50) = PLUS
      DO  100   I = 1, 49
          VAL2    = VAL1 + UNIT
          IF( STV .GE. VAL1 .AND. STV .LT. VAL2 ) THEN
              CHAR(I:I)  = PLUS
              NSCL       = NSCL + 1
              IF( IFLG .EQ. 1 ) THEN
                 SC          = 10.0**STV
              ELSE
                 IF(     STV1 .EQ. 0.0 ) THEN
                         SC           = STV
                 ELSEIF( ABS(STV/STV1) .LT. 1.E-2 ) THEN
                         SC           = 0.0
                 ELSE
                         SC          = STV
                 ENDIF
                 STV1       = STV
              ENDIF
              STV  = STV + VSTP
              IF( I2 .LT. I-1 ) THEN
                  I2   = I + 8
                  IF( I2 .LE. 52 ) THEN
                      WRITE(SCALE(I+1:I2),9100) SC
                  ENDIF
              ENDIF
          ELSE
              CHAR(I:I) = MINUS
          ENDIF
          VAL1      = VAL2
  100 CONTINUE
C
      IF( NSCL .EQ. 0 ) THEN
          IF( IFLG .EQ. 1 ) THEN
             SC       = 10.0**VMAX
          ELSE
             SC       = VMAX
          ENDIF
          WRITE(SCALE(44:52),9100) SC
      ENDIF
C
      RETURN
      END
C
C***********************************************************************
C*                                                                     *
C*========================                                             *
C*    SUBROUTINE BSREAD                                                *
C*========================                                             *
C*((Function))                                                         *
C*    READ TEMPORARY RESULT FROM DISK FILE                             *
C*((Auther))                                                           *
C*    S.Kawabata    June '90 at KEK                                    *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE BSREAD
C
      IMPLICIT REAL*8 (A-H,O-Z)
      PARAMETER (MXDIM = 25, NDMX = 50, LENG = 17000)
      PARAMETER (ITM  = 50 )
      COMMON /BASE1/ ND1(5*MXDIM+3)
      COMMON /BASE2/ ND2(6)
      COMMON /BASE3/ ND3(14)
      COMMON /BASE4/ ND4(2*MXDIM*(NDMX+1)+4*LENG+MXDIM+3)
      COMMON /BASE5/ ND5(11*ITM)
      COMMON /RANDM/ ND6(45)
      PARAMETER(LREC=8010)
      INTEGER BUF(LREC-1)
      PARAMETER ( ILH = 50, IDH = 50 )
      COMMON /PLOTH/ NPH(18*(ILH+IDH)+4),NW
      PARAMETER ( ISL = 281 )
      COMMON/PLOTB/ IBUF( ISL )
      COMMON /LOOP1/ LP1(2)
      INTEGER  IBUF2(50)
C-------------MNJPRM   file-----------------------------------
C***********************************************************************
C*
C*  common /MNJPRM/
C*
C*  job parameters for mini-jet event generation.
C*
C***********************************************************************
C*
      COMMON /MNJPRM/ NGNTYP, NGNPRC, NQSSRC, NUMFLV,
     >                XXLAM,  XLAM, XXLAM2, XLAM2,
     >                YMAX3, YMAX4,
     >                NDISTR,
     >                NGMINS, NGPLUS,
     >                IHIS
C*
      INTEGER*4  NGNTYP, NGNPRC
C*
C*  NGNTYP = 0  ; Generate all type.
C*         = 1  ; Generate one resolved process.
C*         = 2  ; Generate two resolved process
C*         = 3  ; Generate only one sub-process specified by NGNPRC
C*  NGNPRC = 1 to 12 ; Generate the single subprocess whose process
C*                     ID is NGNPRC
C*
      INTEGER*4  NQSSRC
C*
C*  NQSSRC = 0  ; Q^2 = \hat(S)
C*         = 1  ; Q^2 = Pt^2
C*
      INTEGER*4  NUMFLV
C*
C*  NUMFLV; Number of flavour to generate.
C*         = 0  ; Nflv= 5 when QSQ > 500, =4 when 500 > QSQ > 50
C*         = 3  ; Always NFLV = 3
C*         = 4  ; Always NFLV = 4
C*         = 5  ; Always NFLV = 5
C*
      REAL*8  XXLAM, XLAM
      REAL*8  XXLAM2, XLAM2
C*
C*  XXLAM  ; Lambda to be used to calculate alpha_S
C*  XLAM   ; Lambda to be used to calculate parton density function.
C*
      INTEGER*4  NDISTR
C*
C*    NDISTR ; Parton distribution function of photon
C*      = 0 ; DG, select automatically according to the qsquare.
C*      = 1 ; DG with Nflv=3
C*      = 2 ; DG with Nflv=4
C*      = 3 ; DG with Nflv=5
C*      = 4 ; LAC, SET-I
C*      = 5 ; LAC, SET-II
C*      = 6 ; LAC, SET-III
C*      = 7 ; DO
C*      = 8 ; DO + VMD
C*      = 9 ; Modified DO + VMD
C*
      INTEGER*4 NGMINS, NGPLUS
C
C     NGMINS  : Source of photon beam
C         0=Bremstraulung from e-, 1=Beamstrulung from e-
C     NGPLUS  : Source of photon beam
C         0=Bremstraulung from e+, 1=Beamstrulung from e+
C
      REAL*8    YMAX3, YMAX4
C  YMAX3  : Maximum rapidity to accept event for jet-3
C  YMAX4  : Maximum rapidity to accept event for jet-4
      INTEGER*4 IHIS
C  IHIS   : Flag controlling histogramming 1=YES 0=NO
C-------------MNJPID   file-----------------------------------
      INTEGER*4  NTPJLC
      COMMON / MNJPID / NTPJLC
C
C ... NTPJLC ... Particle ID code.
C     = 0 for TOPAZ ID
C     = 1 for JLC ID
C
C-------------EVTPRM   file-----------------------------------
      REAL*8          RS, EMINS, EPLUS, EBEAM, XG(25), EGAM1, EGAM2
     >              , CS, EHAT, EGAM10, EGAM20, PTMIN
      INTEGER*4       NRTYPE, NRDUMY, NPRC, INDX
      COMMON /EVTPRM/ RS, EMINS, EPLUS, EBEAM, XG  , EGAM1, EGAM2
     >              , NRTYPE, NRDUMY
     >              , CS, EHAT, EGAM10, EGAM20, PTMIN
     >              , NPRC, INDX
C
C   RS     ; Center of mass  energy
C   EMINS  ; not used
C   EPLUS  ;
C   EBEAM  ; Beam energy
C   XG(0)  ; Randum variables for event generation/
C
C   CS     ; Cos(th) of the event
C   EHAT   ; CMS Energy (Hard Collision)
C
C   EGAM10 ; X1*EBEAM
C   EGAM20 ; X2*EBEAM
C   EGAM1  ; X1*X3*EBEAM
C   EGAM2  ; X2*X4*EBEAM
C   PTMIN  ; Minimum Pt of a jet.
      REWIND 23
CORIGINAL      READ(23) ND1,ND2,ND3,ND4,ND5,ND6,NPH,LP1
       CALL  MCGRBL  (23,ND1,LREC,5*MXDIM+3,BUF)
       CALL  MCGRBL  (23,ND2,LREC,6,BUF)
       CALL  MCGRBL  (23,ND3,LREC,14,BUF)
       CALL  MCGRBL  (23,ND4,LREC,(2*MXDIM*(NDMX+1)+4*LENG+MXDIM+3),BUF)
       CALL  MCGRBL  (23,ND5,LREC,11*ITM,BUF)
       CALL  MCGRBL  (23,ND6,LREC,45,BUF)
       CALL  MCGRBL  (23,NPH,LREC,(18*(ILH+IDH)+4),BUF)
       CALL  MCGRBL  (23,LP1,LREC,2,BUF)
CORIGINAL      READ(23) NW,(IBUF(I),I=1,NW)
      CALL  MCGRBL  (23,NW,LREC,1,BUF)
      CALL  MCGRBL  (23,IBUF,LREC,NW,BUF)
C
C - READ ALSO THE MJGEN PARAMETERS
C
CORIGINAL      READ(23,END=999)NW2,(IBUF2(I),I=1,NW2)
      CALL  MCGRBL  (23,NW2,LREC,1,BUF)
      CALL  MCGRBL  (23,IBUF2,LREC,NW2,BUF)
      IVRSIN=IBUF2(1)
      EBEAM =IBUF2(2)/1000.0
      PTMIN =IBUF2(3)/1000.0
      NGNTYP = IBUF2(4)
      NGNPRC = IBUF2(5)
      NQSSRC= IBUF2(6)
      NUMFLV = IBUF2(7)
      NDISTR = IBUF2(8)
      NGMINS = IBUF2(9)
      NGPLUS = IBUF2(10)
      XLAM   = IBUF2(11)/1000.0
      XXLAM  = IBUF2(12)/1000.0
      YMAX3  = IBUF2(13)/1000.0
      YMAX4  = IBUF2(14)/1000.0
999   RETURN
      END
C***********************************************************************
C*                                                                     *
C*========================                                             *
C*    SUBROUTINE BSWRIT                                                *
C*========================                                             *
C*((Purpose))                                                          *
C*    Read temporary result from disk file.                            *
C*((Auther))                                                           *
C*    S.Kawabata  June '90 at KEK                                      *
C*                                                                     *
C***********************************************************************
C
      SUBROUTINE BSWRIT
      IMPLICIT REAL*8 (A-H,O-Z)
      PARAMETER (MXDIM = 25, NDMX = 50, LENG = 17000)
      PARAMETER (ITM  = 50 )
      COMMON /BASE1/ ND1(5*MXDIM+3)
      COMMON /BASE2/ ND2(6)
      COMMON /BASE3/ ND3(14)
      COMMON /BASE4/ ND4(2*MXDIM*(NDMX+1)+4*LENG+MXDIM+3)
      COMMON /BASE5/ ND5(11*ITM)
      COMMON /RANDM/ ND6(45)
      PARAMETER ( ILH = 50, IDH = 50 )
      COMMON /PLOTH/ NPH(18*(ILH+IDH)+4),NW
      PARAMETER ( ISL = 281 )
      COMMON/PLOTB/ IBUF( ISL )
      COMMON /LOOP1/ LP1(2)
      INTEGER  IBUF2(50)
C-------------MNJPRM   file-----------------------------------
C***********************************************************************
C*
C*  common /MNJPRM/
C*
C*  job parameters for mini-jet event generation.
C*
C***********************************************************************
C*
      COMMON /MNJPRM/ NGNTYP, NGNPRC, NQSSRC, NUMFLV,
     >                XXLAM,  XLAM, XXLAM2, XLAM2,
     >                YMAX3, YMAX4,
     >                NDISTR,
     >                NGMINS, NGPLUS,
     >                IHIS
C*
      INTEGER*4  NGNTYP, NGNPRC
C*
C*  NGNTYP = 0  ; Generate all type.
C*         = 1  ; Generate one resolved process.
C*         = 2  ; Generate two resolved process
C*         = 3  ; Generate only one sub-process specified by NGNPRC
C*  NGNPRC = 1 to 12 ; Generate the single subprocess whose process
C*                     ID is NGNPRC
C*
      INTEGER*4  NQSSRC
C*
C*  NQSSRC = 0  ; Q^2 = \hat(S)
C*         = 1  ; Q^2 = Pt^2
C*
      INTEGER*4  NUMFLV
C*
C*  NUMFLV; Number of flavour to generate.
C*         = 0  ; Nflv= 5 when QSQ > 500, =4 when 500 > QSQ > 50
C*         = 3  ; Always NFLV = 3
C*         = 4  ; Always NFLV = 4
C*         = 5  ; Always NFLV = 5
C*
      REAL*8  XXLAM, XLAM
      REAL*8  XXLAM2, XLAM2
C*
C*  XXLAM  ; Lambda to be used to calculate alpha_S
C*  XLAM   ; Lambda to be used to calculate parton density function.
C*
      INTEGER*4  NDISTR
C*
C*    NDISTR ; Parton distribution function of photon
C*      = 0 ; DG, select automatically according to the qsquare.
C*      = 1 ; DG with Nflv=3
C*      = 2 ; DG with Nflv=4
C*      = 3 ; DG with Nflv=5
C*      = 4 ; LAC, SET-I
C*      = 5 ; LAC, SET-II
C*      = 6 ; LAC, SET-III
C*      = 7 ; DO
C*      = 8 ; DO + VMD
C*      = 9 ; Modified DO + VMD
C*
      INTEGER*4 NGMINS, NGPLUS
C
C     NGMINS  : Source of photon beam
C         0=Bremstraulung from e-, 1=Beamstrulung from e-
C     NGPLUS  : Source of photon beam
C         0=Bremstraulung from e+, 1=Beamstrulung from e+
C
      REAL*8    YMAX3, YMAX4
C  YMAX3  : Maximum rapidity to accept event for jet-3
C  YMAX4  : Maximum rapidity to accept event for jet-4
      INTEGER*4 IHIS
C  IHIS   : Flag controlling histogramming 1=YES 0=NO
C-------------MNJPID   file-----------------------------------
      INTEGER*4  NTPJLC
      COMMON / MNJPID / NTPJLC
C
C ... NTPJLC ... Particle ID code.
C     = 0 for TOPAZ ID
C     = 1 for JLC ID
C
C-------------EVTPRM   file-----------------------------------
      REAL*8          RS, EMINS, EPLUS, EBEAM, XG(25), EGAM1, EGAM2
     >              , CS, EHAT, EGAM10, EGAM20, PTMIN
      INTEGER*4       NRTYPE, NRDUMY, NPRC, INDX
      COMMON /EVTPRM/ RS, EMINS, EPLUS, EBEAM, XG  , EGAM1, EGAM2
     >              , NRTYPE, NRDUMY
     >              , CS, EHAT, EGAM10, EGAM20, PTMIN
     >              , NPRC, INDX
C
C   RS     ; Center of mass  energy
C   EMINS  ; not used
C   EPLUS  ;
C   EBEAM  ; Beam energy
C   XG(0)  ; Randum variables for event generation/
C
C   CS     ; Cos(th) of the event
C   EHAT   ; CMS Energy (Hard Collision)
C
C   EGAM10 ; X1*EBEAM
C   EGAM20 ; X2*EBEAM
C   EGAM1  ; X1*X3*EBEAM
C   EGAM2  ; X2*X4*EBEAM
C   PTMIN  ; Minimum Pt of a jet.
      COMMON/CMJIF/ISTATS(100),IVERS
C
C LREC HERE IS NUMBER OF I*4 WORDS  IN NATIVE BOS FILE RECORDS
C AJF
      PARAMETER(LREC=8010)
      INTEGER BUF(LREC-1)
      REWIND 23
c - original ...
c      WRITE(23) ND1,ND2,ND3,ND4,ND5,ND6,NPH,LP1
       CALL  MCGWBL  (23,ND1,LREC,5*MXDIM+3,BUF)
       CALL  MCGWBL  (23,ND2,LREC,6,BUF)
       CALL  MCGWBL  (23,ND3,LREC,14,BUF)
       CALL  MCGWBL  (23,ND4,LREC,(2*MXDIM*(NDMX+1)+4*LENG+MXDIM+3),BUF)
       CALL  MCGWBL  (23,ND5,LREC,11*ITM,BUF)
       CALL  MCGWBL  (23,ND6,LREC,45,BUF)
       CALL  MCGWBL  (23,NPH,LREC,(18*(ILH+IDH)+4),BUF)
       CALL  MCGWBL  (23,LP1,LREC,2,BUF)
      IF(NW .EQ. 0 ) NW = ISL
      CALL  MCGWBL  (23,NW,LREC,1,BUF)
      CALL  MCGWBL  (23,IBUF,LREC,NW,BUF)
CORIGINAL      WRITE(23) NW,(IBUF(I),I=1,NW)
C
      IBUF2(1)=IVERS
      IBUF2(2)=EBEAM  *1000.0
      IBUF2(3)=PTMIN  *1000.0
      IBUF2(4)=NGNTYP
      IBUF2(5)=NGNPRC
      IBUF2(6)=NQSSRC
      IBUF2(7)=NUMFLV
      IBUF2(8)=NDISTR
      IBUF2(9)=NGMINS
      IBUF2(10)=NGPLUS
      IBUF2(11)=XLAM  *1000.0
      IBUF2(12)=XXLAM *1000.0
      IBUF2(13)=YMAX3 *1000.0
      IBUF2(14)=YMAX4 *1000.0
      NW2 = 14
C      WRITE(23) NW2,(IBUF2(I),I=1,NW)
      CALL  MCGWBL  (23,NW2,LREC,1,BUF)
      CALL  MCGWBL  (23,IBUF2,LREC,NW2,BUF)
      CALL  MCGWFL  (23,BUF,LREC)
      RETURN
      END
      SUBROUTINE  MCGRBL(IUNIT,IARRAY,LREC,LEN,BUF)
C
C READ IN IARRAY IN LREC LENGTH CHUNKS
C  The idea is to pack data into standard NATIVE file
C to save space
C
      INTEGER IUNIT,IARRAY(LEN),BUF(LREC-1),LEN
      INTEGER IPOINT
      SAVE    IPOINT
      DATA    IPOINT/0/
C
C READ IN THE FIRST RECORD
C
      IF(IPOINT.EQ.0)READ(IUNIT)J,(BUF(K),K=1,J)
      IF(LEN.GT.0)THEN
C
C LOOP OVER ARRAY TO BE FILLED
C
            DO 10 I = 1,LEN
                  IPOINT = IPOINT + 1
C
C IF BUFFER IS EXHAUSTED
C
                  IF(IPOINT.GT.LREC-1)THEN
C
C READ NEXT RECORD
C
                        READ(IUNIT)J,(BUF(K),K=1,J)
                        IPOINT = 1
                  ENDIF
C
C FILL ELEMENTS OF ARRAY
C
                  IARRAY(I) = BUF(IPOINT)
10          CONTINUE
      ENDIF
      RETURN
      END
      SUBROUTINE  MCGWBL(IUNIT,IARRAY,LREC,LEN,BUF)
C WRITE OUT IARRAY IN <= LREC LENGTH CHUNKS
      INTEGER IUNIT,IARRAY(LEN),BUF(LREC-1),LEN
      INTEGER IPOINT
      SAVE    IPOINT
      DATA    IPOINT/0/
      IF(LEN.GT.0)THEN
C
C LOOP OVER ARRAY BEING WRITTEN
C
            DO 10 I = 1,LEN
                  IPOINT = IPOINT + 1
C
C IF BUFFER IS FULL
C
                  IF(IPOINT.GT.LREC-1)THEN
C
C WRITE IT OUT, AND RESET POINTER TO
C BUFFER
                        WRITE(IUNIT)LREC-1,BUF
                        IPOINT = 1
                  ENDIF
                  BUF(IPOINT) = IARRAY(I)
10          CONTINUE
      ENDIF
      RETURN
      ENTRY MCGWFL(IUNIT,BUF,LREC)
C
C FLUSH BUFFER TO FILE
C
            WRITE(IUNIT)IPOINT,(BUF(J),J=1,IPOINT)
      RETURN
      END
C234567890---------2---------3---------4---------5---------6---------7--
C
C FUNCTION CROSS
C
C234567890---------2---------3---------4---------5---------6---------7--
C
      REAL*8 FUNCTION FNCMNJ(X)
C
      IMPLICIT REAL*8 (A-H,O-Z)
      REAL*8  X(25)
C
C-------------EVTPRM   file-----------------------------------
      REAL*8          RS, EMINS, EPLUS, EBEAM, XG(25), EGAM1, EGAM2
     >              , CS, EHAT, EGAM10, EGAM20, PTMIN
      INTEGER*4       NRTYPE, NRDUMY, NPRC, INDX
      COMMON /EVTPRM/ RS, EMINS, EPLUS, EBEAM, XG  , EGAM1, EGAM2
     >              , NRTYPE, NRDUMY
     >              , CS, EHAT, EGAM10, EGAM20, PTMIN
     >              , NPRC, INDX
C
C   RS     ; Center of mass  energy
C   EMINS  ; not used
C   EPLUS  ;
C   EBEAM  ; Beam energy
C   XG(0)  ; Randum variables for event generation/
C
C   CS     ; Cos(th) of the event
C   EHAT   ; CMS Energy (Hard Collision)
C
C   EGAM10 ; X1*EBEAM
C   EGAM20 ; X2*EBEAM
C   EGAM1  ; X1*X3*EBEAM
C   EGAM2  ; X2*X4*EBEAM
C   PTMIN  ; Minimum Pt of a jet.
C-------------MNJPRM   file-----------------------------------
C***********************************************************************
C*
C*  common /MNJPRM/
C*
C*  job parameters for mini-jet event generation.
C*
C***********************************************************************
C*
      COMMON /MNJPRM/ NGNTYP, NGNPRC, NQSSRC, NUMFLV,
     >                XXLAM,  XLAM, XXLAM2, XLAM2,
     >                YMAX3, YMAX4,
     >                NDISTR,
     >                NGMINS, NGPLUS,
     >                IHIS
C*
      INTEGER*4  NGNTYP, NGNPRC
C*
C*  NGNTYP = 0  ; Generate all type.
C*         = 1  ; Generate one resolved process.
C*         = 2  ; Generate two resolved process
C*         = 3  ; Generate only one sub-process specified by NGNPRC
C*  NGNPRC = 1 to 12 ; Generate the single subprocess whose process
C*                     ID is NGNPRC
C*
      INTEGER*4  NQSSRC
C*
C*  NQSSRC = 0  ; Q^2 = \hat(S)
C*         = 1  ; Q^2 = Pt^2
C*
      INTEGER*4  NUMFLV
C*
C*  NUMFLV; Number of flavour to generate.
C*         = 0  ; Nflv= 5 when QSQ > 500, =4 when 500 > QSQ > 50
C*         = 3  ; Always NFLV = 3
C*         = 4  ; Always NFLV = 4
C*         = 5  ; Always NFLV = 5
C*
      REAL*8  XXLAM, XLAM
      REAL*8  XXLAM2, XLAM2
C*
C*  XXLAM  ; Lambda to be used to calculate alpha_S
C*  XLAM   ; Lambda to be used to calculate parton density function.
C*
      INTEGER*4  NDISTR
C*
C*    NDISTR ; Parton distribution function of photon
C*      = 0 ; DG, select automatically according to the qsquare.
C*      = 1 ; DG with Nflv=3
C*      = 2 ; DG with Nflv=4
C*      = 3 ; DG with Nflv=5
C*      = 4 ; LAC, SET-I
C*      = 5 ; LAC, SET-II
C*      = 6 ; LAC, SET-III
C*      = 7 ; DO
C*      = 8 ; DO + VMD
C*      = 9 ; Modified DO + VMD
C*
      INTEGER*4 NGMINS, NGPLUS
C
C     NGMINS  : Source of photon beam
C         0=Bremstraulung from e-, 1=Beamstrulung from e-
C     NGPLUS  : Source of photon beam
C         0=Bremstraulung from e+, 1=Beamstrulung from e+
C
      REAL*8    YMAX3, YMAX4
C  YMAX3  : Maximum rapidity to accept event for jet-3
C  YMAX4  : Maximum rapidity to accept event for jet-4
      INTEGER*4 IHIS
C  IHIS   : Flag controlling histogramming 1=YES 0=NO
C-------------MNJTYP   file-----------------------------------
C MNJTYP file.
C ... sub-process information data.
C
C     NCDATA(0,,) = Cross section formula for the sub-process.
C           (1,,) = Parton ID of initial-1
C           (2,,) =              initial-2
C           (3,,) = Parton ID of final-1
C           (4,,) =              final-2
C
      PARAMETER (MX$PRC=44)
      PARAMETER (MAXPRC=MX$PRC*5)
      INTEGER*4  NCDATA(0:4,5,MX$PRC)
      INTEGER*4  KCDATA(0:4,MAXPRC)
      EQUIVALENCE (KCDATA(0,1), NCDATA(0,1,1))
C
CAJF - I SET NCDATA(0,1:5,1) TO ZERO TOTURN OFF THE QPM COMPONENT
C 1   gamma + gamma --> q + qbar
      DATA (((NCDATA(I,J,K),I=0,4),J=1,5),K=1,7)/
     > 0,22,22,1,-1,   0,22,22,2,-2,  0,22,22,3,-3,
     > 0,22,22,4,-4,   0,22,22,5,-5,
C
C 2a  gamma +q ---> gluon + q
     > 2,22,1,21,1,    2,22,2,21,2,   2,22,3,21,3,
     > 2,22,4,21,4,    2,22,5,21,5,
C
C 2b  gamma + qbar ---> gluon + qbar
     > 2,22,-1,21,-1,  2,22,-2,21,-2,  2,22,-3,21,-3,
     > 2,22,-4,21,-4,  2,22,-5,21,-5,
C
C 2c  q + gamma --> q + gluon
     >-2,1,22,1,21,    -2,2,22,2,21,   -2,3,22,3,21,
     >-2,4,22,4,21,    -2,5,22,5,21,
C
C 2d  qbar + gamma --> qbar + gluon
     >-2,-1,22,-1,21,  -2,-2,22,-2,21,   -2,-3,22,-3,21,
     >-2,-4,22,-4,21,  -2,-5,22,-5,21,
C
C 3a  gamma + gluon --> q + qbar
     > 3,22,21,1,-1,    3,22,21,2,-2,    3,22,21,3,-3,
     > 3,22,21,4,-4,    3,22,21,5,-5,
C
C 3b  gluon + gamma --> q + qbar
     >-3,21,22,1,-1,   -3,21,22,2,-2,    -3,21,22,3,-3 ,
     >-3,21,22,4,-4,   -3,21,22,5,-5          /
C 5/18/92 : costh distribution should be symmetry for replacement of
C            q_i and q_j.
C 4/5 q_i + q_j --> q_i + q_j
C     DATA (((NCDATA(I,J,K),I=0,4),J=1,5),K=8,12)/
C    >4,1,1,1,1,   5,1,2,1,2,   5,1,3,1,3,  5,1,4,1,4,  5,1,5,1,5,
C    >5,2,1,2,1,   4,2,2,2,2,   5,2,3,2,3,  5,2,4,2,4,  5,2,5,2,5,
C    >5,3,1,3,1,   5,3,2,3,2,   4,3,3,3,3,  5,3,4,3,4,  5,3,5,3,5,
C    >5,4,1,4,1,   5,4,2,4,2,   5,4,3,4,3,  4,4,4,4,4,  5,4,5,4,5,
C    >5,5,1,5,1,   5,5,2,5,2,   5,5,3,5,3,  5,5,4,5,4,  4,5,5,5,5/
      DATA (((NCDATA(I,J,K),I=0,4),J=1,5),K=8,12)/
     > 4,1,1,1,1,  5,1,2,1,2,   5,1,3,1,3,  5,1,4,1,4,  5,1,5,1,5,
     >-5,2,1,2,1,  4,2,2,2,2,   5,2,3,2,3,  5,2,4,2,4,  5,2,5,2,5,
     >-5,3,1,3,1, -5,3,2,3,2,   4,3,3,3,3,  5,3,4,3,4,  5,3,5,3,5,
     >-5,4,1,4,1, -5,4,2,4,2,  -5,4,3,4,3,  4,4,4,4,4,  5,4,5,4,5,
     >-5,5,1,5,1, -5,5,2,5,2,  -5,5,3,5,3, -5,5,4,5,4,  4,5,5,5,5/
C
C 6/8 q_i + bar(q_j) --> q_i + bar(q_j)
      DATA (((NCDATA(I,J,K),I=0,4),J=1,5),K=13,17)/
     >6,1,-1,1,-1, 8,1,-2,1,-2, 8,1,-3,1,-3, 8,1,-4,1,-4, 8,1,-5,1,-5,
     >8,2,-1,2,-1, 6,2,-2,2,-2, 8,2,-3,2,-3, 8,2,-4,2,-4, 8,2,-5,2,-5,
     >8,3,-1,3,-1, 8,3,-2,3,-2, 6,3,-3,3,-3, 8,3,-4,3,-4, 8,3,-5,3,-5,
     >8,4,-1,4,-1, 8,4,-2,4,-2, 8,4,-3,4,-3, 6,4,-4,4,-4, 8,4,-5,4,-5,
     >8,5,-1,5,-1, 8,5,-2,5,-2, 8,5,-3,5,-3, 8,5,-4,5,-4, 6,5,-5,5,-5/
C 6/8 bar(q_i) + q_j --> bar(q_i) + q_j
      DATA (((NCDATA(I,J,K),I=0,4),J=1,5),K=18,22)/
     >-6,-1,1,-1,1,-8,-1,2,-1,2,-8,-1,3,-1,3,-8,-1,4,-1,4,-8,-1,5,-1,5,
     >-8,-2,1,-2,1,-6,-2,2,-2,2,-8,-2,3,-2,3,-8,-2,4,-2,4,-8,-2,5,-2,5,
     >-8,-3,1,-3,1,-8,-3,2,-3,2,-6,-3,3,-3,3,-8,-3,4,-3,4,-8,-3,5,-3,5,
     >-8,-4,1,-4,1,-8,-4,2,-4,2,-8,-4,3,-4,3,-6,-4,4,-4,4,-8,-4,5,-4,5,
     >-8,-5,1,-5,1,-8,-5,2,-5,2,-8,-5,3,-5,3,-8,-5,4,-5,4,-6,-5,5,-5,5/
C 5/18/92 : costh distribution should be symmetry for replacement of
C            q_i and q_j.
C 4/5 bar(q_i) + bar(q_j) --> bar(q_i) + bar(q_j)
C     DATA (((NCDATA(I,J,K),I=0,4),J=1,5),K=23,27)/
C    >4,-1,-1,-1,-1,   5,-1,-2,-1,-2,   5,-1,-3,-1,-3,
C    >                 5,-1,-4,-1,-4,   5,-1,-5,-1,-5,
C    >5,-2,-1,-2,-1,   4,-2,-2,-2,-2,   5,-2,-3,-2,-3,
C    >                 5,-2,-4,-2,-4,   5,-2,-5,-2,-5,
C    >5,-3,-1,-3,-1,   5,-3,-2,-3,-2,   4,-3,-3,-3,-3,
C    >                 5,-3,-4,-3,-4,   5,-3,-5,-3,-5,
C    >5,-4,-1,-4,-1,   5,-4,-2,-4,-2,   5,-4,-3,-4,-3,
C    >                 4,-4,-4,-4,-4,   5,-4,-5,-4,-5,
C    >5,-5,-1,-5,-1,   5,-5,-2,-5,-2,   5,-5,-3,-5,-3,
C    >                 5,-5,-4,-5,-4,   4,-5,-5,-5,-5/
      DATA (((NCDATA(I,J,K),I=0,4),J=1,5),K=23,27)/
     > 4,-1,-1,-1,-1,   5,-1,-2,-1,-2,   5,-1,-3,-1,-3,
     >                  5,-1,-4,-1,-4,   5,-1,-5,-1,-5,
     >-5,-2,-1,-2,-1,   4,-2,-2,-2,-2,   5,-2,-3,-2,-3,
     >                  5,-2,-4,-2,-4,   5,-2,-5,-2,-5,
     >-5,-3,-1,-3,-1,  -5,-3,-2,-3,-2,   4,-3,-3,-3,-3,
     >                  5,-3,-4,-3,-4,   5,-3,-5,-3,-5,
     >-5,-4,-1,-4,-1,  -5,-4,-2,-4,-2,  -5,-4,-3,-4,-3,
     >                  4,-4,-4,-4,-4,   5,-4,-5,-4,-5,
     >-5,-5,-1,-5,-1,  -5,-5,-2,-5,-2,  -5,-5,-3,-5,-3,
     >                 -5,-5,-4,-5,-4,   4,-5,-5,-5,-5/
C ... first line is gluon + gluon --> gluon + gluon
C
C 7a  q_i + bar(q_i) --> q_j + bar(q_j)
      DATA (((NCDATA(I,J,K),I=0,4),J=1,5),K=28,32)/
     >12,21,21,21,21, 7,1,-1,2,-2,  7,1,-1,3,-3,
     >                7,1,-1,4,-4,  7,1,-1,5,-5,
     > 7,2,-2,1,-1,   0,0, 0,0, 0,  7,2,-2,3,-3,
     >                7,2,-2,4,-4,  7,2,-2,5,-5,
     > 7,3,-3,1,-1,   7,3,-3,2,-2,  0,0, 0,0, 0,
     >                7,3,-3,4,-4,  7,3,-3,5,-5,
     > 7,4,-4,1,-1,   7,4,-4,2,-2,  7,4,-4,3,-3,
     >                0,0, 0,0, 0,  7,4,-4,5,-4,
     > 7,5,-5,1,-1,   7,5,-5,2,-2,  7,5,-5,3,-3,
     >                7,5,-5,4,-4,  0,0, 0,0, 0 /
C 7b  bar(q_i) + q_i --> bar(q_j) + q_j
      DATA (((NCDATA(I,J,K),I=0,4),J=1,5),K=33,37)/
     > 0,0, 0,0, 0,  -7,-1,1,-2,2,  -7,-1,1,-3,3,
     >               -7,-1,1,-4,4,  -7,-1,1,-5,5,
     >-7,-2,2,-1,1,   0,0, 0,0, 0,  -7,-2,2,-3,3,
     >               -7,-2,2,-4,4,  -7,-2,2,-5,5,
     >-7,-3,3,-1,1,  -7,-3,3,-2,2,   0, 0,0, 0,0,
     >               -7,-3,3,-4,4,  -7,-3,3,-5,5,
     >-7,-4,4,-1,1,  -7,-4,4,-2,2,  -7,-4,4,-3,3,
     >                0,0, 0,0, 0,  -7,-4,4,-5,4,
     >-7,-5,5,-1,1,  -7,-5,5,-2,2,  -7,-5,5,-3,3,
     >               -7,-5,5,-4,4,   0, 0,0, 0,0 /
      DATA (((NCDATA(I,J,K),I=0,4),J=1,5),K=38,43)/
C 9a  q_i + bar(q_i) --> gluon + gluon
     > 9,1,-1,21,21,  9,2,-2,21,21, 9,3,-3,21,21,
     >                9,4,-4,21,21, 9,5,-5,21,21,
C 9b  bar(q_i) + q_i --> gluon + gluon
     >-9,-1,1,21,21,  -9,-2,2,21,21, -9,-3,3,21,21,
     >                -9,-4,4,21,21, -9,-5,5,21,21,
C 10a q_i + gluon ---> q_i + gluon
     > 10,1,21,1,21,  10,2,21,2,21, 10,3,21,3,21,
     >                10,4,21,4,21, 10,5,21,5,21,
C 10b bar(q_i) + gluon ---> bar(q_i) + gluon
     > 10,-1,21,-1,21,  10,-2,21,-2,21, 10,-3,21,-3,21,
     >                  10,-4,21,-4,21, 10,-5,21,-5,21,
C 10c gluon + q_i ---> gluon + q_i
     >-10,21,1,21,1,  -10,21,2,21,2, -10,21,3,21,3,
     >                -10,21,4,21,4, -10,21,5,21,5,
C 10d gluon + bar(q_i) ---> bar(q_i) + gluon
     >-10,21,-1,21,-1,  -10,21,-2,21,-2, -10,21,-3,21,-3,
     >                  -10,21,-4,21,-4, -10,21,-5,21,-5/
      DATA ((NCDATA(I,J,44),I=0,4),J=1,5)/
C 11  gluon + gluon ---> q + qbar
     > 11,21,21,1,-1,  11,21,21,2,-2,  11,21,21,3,-3,
     >                 11,21,21,4,-4,  11,21,21,5,-5 /
C
C
      DATA    GEV2PB/0.38927D+9/
      DATA    PI/3.14159265/
      DATA    IFIRST/1/
C
C
C ======================================================================
C
C ----------------------------------------------------------------------
C (1) Initialization at the very begining of the job.
C ----------------------------------------------------------------------
C
      IF( IFIRST .EQ. 1 ) THEN
        PI     = ACOS(-1.)
        TWOPI  = 2.*PI
        ALPHA  = 1./137.0359895
        AME    = 0.51099906D-3
        AME2   = AME*AME
        S      = (2.*EBEAM)**2
        PTMAX  = EBEAM
        SPNFCT = 1
        FACTOR = SPNFCT*GEV2PB
        ROTS   = 2.*EBEAM
        XXMIN  = (PTMIN/EBEAM)**2
        X1MIN  = XXMIN
        X1MAX  = 1.0D0 - 1.D-4
        X1WID  = X1MAX - X1MIN
        X2MIN  = XXMIN
        X2MAX  = 1.0D0 - 1.D-4
        X2WID  = X2MAX - X2MIN
        X3MIN  = XXMIN
        X3MAX  = 1.0D0 - 1.D-4
        X3WID  = X3MAX - X3MIN
        X4MIN  = XXMIN
        X4MAX  = 1.0D0 - 1.D-4
        X4WID  = X4MAX - X4MIN
        CSMAX  = SQRT( (EBEAM-PTMIN)*(EBEAM+PTMIN)/EBEAM/EBEAM )
        CSMIN  = -CSMAX
        CSWID  =  CSMAX- CSMIN
        XLAM2  = XLAM*XLAM
        XXLAM2 = XXLAM*XXLAM
        STHR1 =  50.
        STHR2 = 500.
C
C ... Calculate Lamda^2 for 3 flavour and 5 flavour.
C
        ALPHAS = 12.*PI/((33.-2*4)*DLOG(STHR1/XXLAM2))
        XXLM23 = STHR1/DEXP( 12.D0*PI/(ALPHAS*27.D0) )
        ALPHAS = 12.*PI/((33.-2*4)*DLOG(STHR2/XXLAM2))
        XXLM25 = STHR2/DEXP( 12.D0*PI/(ALPHAS*23.D0) )
        XXLM03 = SQRT(XXLM23)
        XXLM05 = SQRT(XXLM25)
C        PRINT *,' LAMBDA FOR 3 FLAVOUR =',XXLM03
C        PRINT *,' LAMBDA FOR 4 FLAVOUR =',XXLAM
C        PRINT *,' LAMBDA FOR 5 FLAVOUR =',XXLM05
        IFIRST = 0
      ENDIF
C
C ----------------------------------------------------------------------
C (2) Set Beam energy and flux factor.
C ----------------------------------------------------------------------
C
      FNCMNJ = 0
      X1    = X1MIN + X1WID*X(1)
      X2    = X2MIN + X2WID*X(2)
      SHAT  = X1*X2*S
C      EHATT = (X1+X2)*EBEAM
C      SHAT  = EHATT**2
      IF( SQRT(SHAT)*0.5 .LT. PTMIN ) RETURN
C
C Get weight of the photon.
C
      IF( NGMINS.EQ.0 ) THEN
        IF( EBEAM.LT.50.D0) THEN
        CALL MNJGAM(1, X1, EBEAM, F1)
        ELSE
          CALL MNJGAM(2,X1,EBEAM,F1)
        ENDIF
      ELSE
        IF( EBEAM.LT.200. ) THEN
          CALL MNJGAM(11, X1, EBEAM, F1)
        ELSEIF( EBEAM.LT.400. ) THEN
          CALL MNJGAM(12, X1, EBEAM, F1)
        ELSEIF( EBEAM.LT.600. ) THEN
          CALL MNJGAM(13, X1, EBEAM, F1)
        ELSE
          CALL MNJGAM(14, X1, EBEAM, F1)
        ENDIF
      ENDIF
C
      IF( NGPLUS.EQ.0 ) THEN
        IF( EBEAM.LT.50.D0) THEN
        CALL MNJGAM(1, X2, EBEAM, F2)
        ELSE
           CALL MNJGAM(2,X2,EBEAM,F2)
        ENDIF
      ELSE
        IF( EBEAM.LT.200. ) THEN
          CALL MNJGAM(11, X2, EBEAM, F2)
        ELSEIF( EBEAM.LT.400. ) THEN
          CALL MNJGAM(12, X2, EBEAM, F2)
        ELSEIF( EBEAM.LT.600. ) THEN
          CALL MNJGAM(13, X2, EBEAM, F2)
        ELSE
          CALL MNJGAM(14, X2, EBEAM, F2)
        ENDIF
      ENDIF
C      CALL XHFILL(100,X1, F1 )
C      CALL XHFILL(100,X2, F2 )
C
C ... Decide the process
C
      X3    = X3MIN + X3WID*X(3)
      X4    = X4MIN + X4WID*X(4)
      FNCMNJ = 0
      DIRECT = 0
      ONERES = 0
      TWORES = 0
CC    DO 200 INDX = 1, MAXPRC
C
C ... Decide the process
C
      XMULT = FLOAT(MAXPRC)
      INDX  = XMULT*X(6)+1.
      INDX  = MIN(MAX(1,INDX),MAXPRC)
C
      NPRC  = KCDATA(0,INDX)
      IAPRC = IABS(NPRC)
      IF( IAPRC.EQ.0 )                        RETURN
C
C .. To select the type of event to generate.
C
      IF( NGNTYP .NE. 0 ) THEN
        IF( NGNTYP .EQ. 1 ) THEN
            IF( IAPRC.NE.2 .AND. IAPRC.NE.3 ) RETURN
        ELSEIF( NGNTYP.EQ.2 ) THEN
            IF( IAPRC.LE.3 )                  RETURN
        ELSE
            IF( IAPRC.NE.NGNPRC )             RETURN
        ENDIF
      ENDIF
      EGAM1 = X1*EBEAM
      EGAM2 = X2*EBEAM
      EGAM10= X1*EBEAM
      EGAM20= X2*EBEAM
      IF( KCDATA(1,INDX).NE.22) THEN
             SHAT  = SHAT*X3
             EGAM1 = X1*X3*EBEAM
      ENDIF
      IF( KCDATA(2,INDX).NE.22) THEN
        SHAT  = SHAT*X4
        EGAM2 = X2*X4*EBEAM
      ENDIF
C      EHATT =  EGAM1 + EGAM2
C      SHAT  = EHATT**2
C      WRITE(6,*)' SHATOR ',SHATOR,' SHAT ',SHAT
      IF( SQRT(SHAT)*0.5 .LT. PTMIN ) RETURN
C
C We take q-sqare = Shat
C
      CS    = CSMIN + CSWID*X(5)
      EHAT  = 0.5*SQRT(SHAT)
      PT    = EHAT*SQRT((1.D0-CS)*(1.D0+CS))
      IF( PT.LT.PTMIN ) RETURN
      IF( NQSSRC .EQ. 0 ) THEN
        QSQ   = SHAT*0.25
      ELSE
        QSQ   = PT*PT
      ENDIF
C
C ... calculate the rapidity of jet to make a cut
C
      BETAF  = (EGAM1-EGAM2)/(EGAM1+EGAM2)
C      BETAFH = DTANH(BETAF)
C      PZCM   = EHAT*CS
C      Y3CM   = DTANH(PZCM/EHAT)
C      Y3LAB  = Y3CM + BETAFH
C      Y4CM   = -Y3CM
C      Y4LAB  = Y4CM + BETAFH
      BETAFH  = 0.5D0*DLOG( (1.+BETAF)/(1.-BETAF) )
      PZCM    = EHAT*CS
      Y3CM    = 0.5D0*DLOG( (1+CS)/(1-CS) )
      Y4CM    = -Y3CM
      Y3LAB   = Y3CM + BETAFH
      Y4LAB   = Y4CM + BETAFH
      IF( ABS(Y3LAB).GT.YMAX3 ) RETURN
      IF( ABS(Y4LAB).GT.YMAX4 ) RETURN
C     PRINT *,' '
C     PRINT *,' EGAM1, EGAM2=',EGAM1,EGAM2
C     PRINT *,' BETAFH=',BETAFH,' PZCM=',PZCM,' EHAT=',EHAT,' CS+',CS
C    >       ,' Y3CM,Y4CM=',Y3CM,Y4CM
C     PRINT *,' Y3LAB,Y4LAB=',Y3LAB,Y4LAB
C     IF(ABS(Y3LAB).GT.YMAX3.AND.ABS(Y4LAB).GT.YMAX4) RETURN
C
C   Decide # of flavour according to the Q^2
C
      IF( NUMFLV .EQ. 0 ) THEN
        NFLV =   3
        IF( QSQ  .GT. STHR1) NFLV = 4
        IF( QSQ  .GT. STHR2) NFLV = 5
      ELSE
        NFLV = NUMFLV
      ENDIF
      NFE  = NFLV - 2
C
C .. Remove flavour production below threshold.
C
        IAD1 = IABS(KCDATA(1,INDX))
        IAD2 = IABS(KCDATA(2,INDX))
        IAD3 = IABS(KCDATA(3,INDX))
        IAD4 = IABS(KCDATA(4,INDX))
        IF( IAD1.GT.NFLV.AND.KCDATA(1,INDX).LT.10) RETURN
        IF( IAD2.GT.NFLV.AND.KCDATA(2,INDX).LT.10) RETURN
        IF( IAD3.GT.NFLV.AND.KCDATA(3,INDX).LT.10) RETURN
        IF( IAD4.GT.NFLV.AND.KCDATA(4,INDX).LT.10) RETURN
C
C     Calculate structure function, when initial parton is quark or g
C
      IF( IAD1.EQ.22 ) THEN
        F3 = 1.D0
      ELSE
        IF(NDISTR.EQ.0) THEN
          ITYP = 1
          IF( QSQ .GT. STHR1 ) ITYP = 2
          IF( QSQ .GT. STHR2 ) ITYP = 3
CC        CALL MNJPRB(ITYP, NFLV, QSQ, X3, XLAM2, F3 )
          CALL MNJPRB(ITYP, IAD1, QSQ, X3, XLAM2, F3 )
        ELSE
CC        CALL MNJPRB(NDISTR, NFLV, QSQ, X3, XLAM2, F3 )
          CALL MNJPRB(NDISTR, IAD1, QSQ, X3, XLAM2, F3 )
        ENDIF
      ENDIF
C
      IF( IAD2.EQ.22 ) THEN
        F4 = 1.D0
      ELSE
        IF(NDISTR.EQ.0) THEN
          ITYP = 1
          IF( QSQ .GT. STHR1 ) ITYP = 2
          IF( QSQ .GT. STHR2 ) ITYP = 3
CC        CALL MNJPRB(ITYP, NFLV, QSQ, X4, XLAM2, F4 )
          CALL MNJPRB(ITYP, IAD2, QSQ, X4, XLAM2, F4 )
        ELSE
CC        CALL MNJPRB(NDISTR, NFLV, QSQ, X4, XLAM2, F4 )
          CALL MNJPRB(NDISTR, IAD2, QSQ, X4, XLAM2, F4 )
        ENDIF
      ENDIF
C
C
C Differential cross section of the sub-process
C
        CALL MNJCRS( KCDATA(0,INDX), EHAT, CS, NFLV, DSDCS )
C ... Weight factor according to the quark charge
C
        IF( NFLV.EQ.3 ) THEN
          ALPHAS = 12.*PI/((33.-2*NFLV)*DLOG(QSQ/XXLM23)*0.12)
        ELSEIF( NFLV.EQ.5 ) THEN
          ALPHAS = 12.*PI/((33.-2*NFLV)*DLOG(QSQ/XXLM25)*0.12)
        ELSE
          ALPHAS = 12.*PI/((33.-2*NFLV)*DLOG(QSQ/XXLAM2)*0.12)
        ENDIF
        IF( IAPRC.EQ.1 ) THEN
          IF( MOD(IAD3,2).EQ.1 ) THEN
            F5 = (1./3.)**4
          ELSE
            F5 = (2./3.)**4
          ENDIF
        ELSEIF( IAPRC.EQ.2 ) THEN
          IADT = IABS(KCDATA(1,INDX))
          IF( IADT .GT. 10 ) IADT = IABS(KCDATA(2,INDX))
          IF( MOD(IADT,2).EQ.1 ) THEN
            F5 = (1./3.)**2
          ELSE
            F5 = (2./3.)**2
          ENDIF
          F5 = F5*ALPHAS
        ELSEIF( IAPRC.EQ.3 ) THEN
          IF( MOD(IAD3,2).EQ.1 ) THEN
            F5 = (1./3.)**2
          ELSE
            F5 = (2./3.)**2
          ENDIF
          F5 = F5*ALPHAS
        ELSE
          F5 = ALPHAS*ALPHAS
        ENDIF
        YACOB = X1WID*X2WID*CSWID*X3WID*X4WID*XMULT
        FNCMNJ= F1*F2*DSDCS*YACOB*F3*F4*F5
CC    PRINT *,'
        IF( FNCMNJ.LT. 0.0D0 ) THEN
          FUNC = 0.0
C          PRINT *,' '
C          PRINT *,' FUNC =',FNCMNJ
C          PRINT *,' X(1:3)=',X(1),X(2),X(3),X(4),X(5)
C          PRINT *,' F1   =',F1
C          PRINT *,' F2   =',F2
C          PRINT *,' F3   =',F3
C          PRINT *,' F4   =',F4
C          PRINT *,' F5   =',F5
C          PRINT *,' SHAT =',SHAT
C          PRINT *,' DSDCS=',DSDCS
C          PRINT *,' NPRC =',NPRC
C          PRINT *,' INDX =',INDX,' KCDATA=',(KCDATA(I,INDX),I=0,4)
C          PRINT *,' YACOB=',YACOB
C          PRINT *,' PT   =',PT
C          PRINT *,' X1   =',X1
C          PRINT *,' X2   =',X2
C          PRINT *,' X3   =',X3
C          PRINT *,' X4   =',X4
        ENDIF
      XG(1)  = X(1)
      XG(2)  = X(2)
      XG(3)  = X(3)
      XG(4)  = X(4)
      XG(5)  = X(5)
      XG(6)  = X(6)
      XG(21) = X1
      XG(22) = X2
      XG(23) = X3
      XG(24) = X4
C
C ----------------------------------------------------------------------
C (8) Histograming
C ----------------------------------------------------------------------
C
      WGG    = SQRT( X1*X2*S )
      IF(IHIS.EQ.1)THEN
      CALL XHFILL(1,X(1), FNCMNJ )
      CALL XHFILL(2,X(2), FNCMNJ)
      CALL XHFILL(3,X(3), FNCMNJ)
      CALL XHFILL(4,X(4), FNCMNJ)
      CALL XHFILL(5,X(5), FNCMNJ)
      CALL XHFILL(6,X(6), FNCMNJ)
CC    CALL XHFILL(4,WGG, FNCMNJ )
      CALL XHFILL(11,PT , FNCMNJ )
      XMJJ = SQRT(SHAT)
      CALL XHFILL(12,XMJJ, FNCMNJ )
C
      IF( IAPRC.EQ.1 ) THEN
        CALL XHFILL(13,PT,FNCMNJ)
      ELSEIF( IAPRC.EQ.2.OR.IAPRC.EQ.3 ) THEN
        CALL XHFILL(14,PT,FNCMNJ)
      ELSE
        CALL XHFILL(15,PT,FNCMNJ)
      ENDIF
C     IF( IAPRC.EQ.1 ) THEN
C       CALL XHFILL(21, PT, FNCMNJ)
C     ELSEIF( IAPRC.EQ.2 ) THEN
C       CALL XHFILL(22, PT, FNCMNJ)
C     ELSEIF( IAPRC.EQ.3 ) THEN
C       CALL XHFILL(23, PT, FNCMNJ)
C     ELSEIF( IAPRC.GE.4 ) THEN
C       CALL XHFILL(24, PT, FNCMNJ)
C     ENDIF
C      PTLOG = DLOG10(PT)
C      CALL XHFILL(20, PTLOG, FNCMNJ)
C      IF( IAPRC.EQ.1 ) THEN
C        CALL XHFILL(21, PTLOG, FNCMNJ)
C      ELSEIF( IAPRC.EQ.2.OR.IAPRC.EQ.3 ) THEN
C        CALL XHFILL(22, PTLOG, FNCMNJ)
C      ELSEIF( IAPRC.GE.4 ) THEN
C        CALL XHFILL(23, PTLOG, FNCMNJ)
C        IF( NFLV.EQ.3 ) CALL XHFILL(24,PTLOG,FNCMNJ)
C        IF( NFLV.EQ.4 ) CALL XHFILL(25,PTLOG,FNCMNJ)
C        IF( NFLV.EQ.5 ) CALL XHFILL(26,PTLOG,FNCMNJ)
C      ENDIF
C
C      CALL XHFILL( 16, DFLOAT(IAPRC), FNCMNJ )
C      CALL XHFILL( 17, Y3LAB, FNCMNJ )
C      CALL XHFILL( 17, Y4LAB, FNCMNJ )
C      NSKIP = 0
C      IF( NSKIP.EQ.0 ) THEN
C      IF( IAPRC .NE. 1 ) THEN
C       CALL XHFILL(30+IAPRC, PT, FNCMNJ)
C        CALL XHFILL(30+IAPRC, PTLOG, FNCMNJ)
C      ENDIF
C      ENDIF
C
C      IF( PTMIN.LT.3.9) THEN
C        IF( ABS(F3-1.D0).GT.1.D-6 ) THEN
C          IF( PT.GT.3.0 .AND. PT.LT.4.0 ) THEN
C            CALL XHFILL(51,X1,FNCMNJ)
C            CALL XHFILL(52,X3,FNCMNJ)
C            CALL DHFILL(55,X1,X3,FNCMNJ)
C            IF( IAD1.GT.10 ) THEN
C              CALL XHFILL(57,X3,FNCMNJ)
C            ELSE
C              CALL XHFILL(58,X3,FNCMNJ)
C            ENDIF
C          ENDIF
C          IF( PT.GT.7.  .AND. PT.LT.8.  ) THEN
C            CALL XHFILL(53,X1,FNCMNJ)
C            CALL XHFILL(54,X3,FNCMNJ)
C            CALL DHFILL(56,X1,X3,FNCMNJ)
C          ENDIF
C        ENDIF
C      ENDIF
      ENDIF
      RETURN
      END
C
      SUBROUTINE USERIN
C
      IMPLICIT REAL*8 (A-H,O-Z)
      COMMON /BASE1/ XL(25),XU(25),NDIM,NGDIM,IG(25),NCALL
      COMMON /BASE2/ ACC1,ACC2,ITMX1,ITMX2
      COMMON /LOOP0/ LOOP
C-------------EVTPRM   file-----------------------------------
      REAL*8          RS, EMINS, EPLUS, EBEAM, XG(25), EGAM1, EGAM2
     >              , CS, EHAT, EGAM10, EGAM20, PTMIN
      INTEGER*4       NRTYPE, NRDUMY, NPRC, INDX
      COMMON /EVTPRM/ RS, EMINS, EPLUS, EBEAM, XG  , EGAM1, EGAM2
     >              , NRTYPE, NRDUMY
     >              , CS, EHAT, EGAM10, EGAM20, PTMIN
     >              , NPRC, INDX
C
C   RS     ; Center of mass  energy
C   EMINS  ; not used
C   EPLUS  ;
C   EBEAM  ; Beam energy
C   XG(0)  ; Randum variables for event generation/
C
C   CS     ; Cos(th) of the event
C   EHAT   ; CMS Energy (Hard Collision)
C
C   EGAM10 ; X1*EBEAM
C   EGAM20 ; X2*EBEAM
C   EGAM1  ; X1*X3*EBEAM
C   EGAM2  ; X2*X4*EBEAM
C   PTMIN  ; Minimum Pt of a jet.
C-------------MNJPRM   file-----------------------------------
C***********************************************************************
C*
C*  common /MNJPRM/
C*
C*  job parameters for mini-jet event generation.
C*
C***********************************************************************
C*
      COMMON /MNJPRM/ NGNTYP, NGNPRC, NQSSRC, NUMFLV,
     >                XXLAM,  XLAM, XXLAM2, XLAM2,
     >                YMAX3, YMAX4,
     >                NDISTR,
     >                NGMINS, NGPLUS,
     >                IHIS
C*
      INTEGER*4  NGNTYP, NGNPRC
C*
C*  NGNTYP = 0  ; Generate all type.
C*         = 1  ; Generate one resolved process.
C*         = 2  ; Generate two resolved process
C*         = 3  ; Generate only one sub-process specified by NGNPRC
C*  NGNPRC = 1 to 12 ; Generate the single subprocess whose process
C*                     ID is NGNPRC
C*
      INTEGER*4  NQSSRC
C*
C*  NQSSRC = 0  ; Q^2 = \hat(S)
C*         = 1  ; Q^2 = Pt^2
C*
      INTEGER*4  NUMFLV
C*
C*  NUMFLV; Number of flavour to generate.
C*         = 0  ; Nflv= 5 when QSQ > 500, =4 when 500 > QSQ > 50
C*         = 3  ; Always NFLV = 3
C*         = 4  ; Always NFLV = 4
C*         = 5  ; Always NFLV = 5
C*
      REAL*8  XXLAM, XLAM
      REAL*8  XXLAM2, XLAM2
C*
C*  XXLAM  ; Lambda to be used to calculate alpha_S
C*  XLAM   ; Lambda to be used to calculate parton density function.
C*
      INTEGER*4  NDISTR
C*
C*    NDISTR ; Parton distribution function of photon
C*      = 0 ; DG, select automatically according to the qsquare.
C*      = 1 ; DG with Nflv=3
C*      = 2 ; DG with Nflv=4
C*      = 3 ; DG with Nflv=5
C*      = 4 ; LAC, SET-I
C*      = 5 ; LAC, SET-II
C*      = 6 ; LAC, SET-III
C*      = 7 ; DO
C*      = 8 ; DO + VMD
C*      = 9 ; Modified DO + VMD
C*
      INTEGER*4 NGMINS, NGPLUS
C
C     NGMINS  : Source of photon beam
C         0=Bremstraulung from e-, 1=Beamstrulung from e-
C     NGPLUS  : Source of photon beam
C         0=Bremstraulung from e+, 1=Beamstrulung from e+
C
      REAL*8    YMAX3, YMAX4
C  YMAX3  : Maximum rapidity to accept event for jet-3
C  YMAX4  : Maximum rapidity to accept event for jet-4
      INTEGER*4 IHIS
C  IHIS   : Flag controlling histogramming 1=YES 0=NO
C-------------MNJPID   file-----------------------------------
      INTEGER*4  NTPJLC
      COMMON / MNJPID / NTPJLC
C
C ... NTPJLC ... Particle ID code.
C     = 0 for TOPAZ ID
C     = 1 for JLC ID
C
C-------------MNJTYP   file-----------------------------------
C MNJTYP file.
C ... sub-process information data.
C
C     NCDATA(0,,) = Cross section formula for the sub-process.
C           (1,,) = Parton ID of initial-1
C           (2,,) =              initial-2
C           (3,,) = Parton ID of final-1
C           (4,,) =              final-2
C
      PARAMETER (MX$PRC=44)
      PARAMETER (MAXPRC=MX$PRC*5)
      INTEGER*4  NCDATA(0:4,5,MX$PRC)
      INTEGER*4  KCDATA(0:4,MAXPRC)
      EQUIVALENCE (KCDATA(0,1), NCDATA(0,1,1))
C
CAJF - I SET NCDATA(0,1:5,1) TO ZERO TOTURN OFF THE QPM COMPONENT
C 1   gamma + gamma --> q + qbar
      DATA (((NCDATA(I,J,K),I=0,4),J=1,5),K=1,7)/
     > 0,22,22,1,-1,   0,22,22,2,-2,  0,22,22,3,-3,
     > 0,22,22,4,-4,   0,22,22,5,-5,
C
C 2a  gamma +q ---> gluon + q
     > 2,22,1,21,1,    2,22,2,21,2,   2,22,3,21,3,
     > 2,22,4,21,4,    2,22,5,21,5,
C
C 2b  gamma + qbar ---> gluon + qbar
     > 2,22,-1,21,-1,  2,22,-2,21,-2,  2,22,-3,21,-3,
     > 2,22,-4,21,-4,  2,22,-5,21,-5,
C
C 2c  q + gamma --> q + gluon
     >-2,1,22,1,21,    -2,2,22,2,21,   -2,3,22,3,21,
     >-2,4,22,4,21,    -2,5,22,5,21,
C
C 2d  qbar + gamma --> qbar + gluon
     >-2,-1,22,-1,21,  -2,-2,22,-2,21,   -2,-3,22,-3,21,
     >-2,-4,22,-4,21,  -2,-5,22,-5,21,
C
C 3a  gamma + gluon --> q + qbar
     > 3,22,21,1,-1,    3,22,21,2,-2,    3,22,21,3,-3,
     > 3,22,21,4,-4,    3,22,21,5,-5,
C
C 3b  gluon + gamma --> q + qbar
     >-3,21,22,1,-1,   -3,21,22,2,-2,    -3,21,22,3,-3 ,
     >-3,21,22,4,-4,   -3,21,22,5,-5          /
C 5/18/92 : costh distribution should be symmetry for replacement of
C            q_i and q_j.
C 4/5 q_i + q_j --> q_i + q_j
C     DATA (((NCDATA(I,J,K),I=0,4),J=1,5),K=8,12)/
C    >4,1,1,1,1,   5,1,2,1,2,   5,1,3,1,3,  5,1,4,1,4,  5,1,5,1,5,
C    >5,2,1,2,1,   4,2,2,2,2,   5,2,3,2,3,  5,2,4,2,4,  5,2,5,2,5,
C    >5,3,1,3,1,   5,3,2,3,2,   4,3,3,3,3,  5,3,4,3,4,  5,3,5,3,5,
C    >5,4,1,4,1,   5,4,2,4,2,   5,4,3,4,3,  4,4,4,4,4,  5,4,5,4,5,
C    >5,5,1,5,1,   5,5,2,5,2,   5,5,3,5,3,  5,5,4,5,4,  4,5,5,5,5/
      DATA (((NCDATA(I,J,K),I=0,4),J=1,5),K=8,12)/
     > 4,1,1,1,1,  5,1,2,1,2,   5,1,3,1,3,  5,1,4,1,4,  5,1,5,1,5,
     >-5,2,1,2,1,  4,2,2,2,2,   5,2,3,2,3,  5,2,4,2,4,  5,2,5,2,5,
     >-5,3,1,3,1, -5,3,2,3,2,   4,3,3,3,3,  5,3,4,3,4,  5,3,5,3,5,
     >-5,4,1,4,1, -5,4,2,4,2,  -5,4,3,4,3,  4,4,4,4,4,  5,4,5,4,5,
     >-5,5,1,5,1, -5,5,2,5,2,  -5,5,3,5,3, -5,5,4,5,4,  4,5,5,5,5/
C
C 6/8 q_i + bar(q_j) --> q_i + bar(q_j)
      DATA (((NCDATA(I,J,K),I=0,4),J=1,5),K=13,17)/
     >6,1,-1,1,-1, 8,1,-2,1,-2, 8,1,-3,1,-3, 8,1,-4,1,-4, 8,1,-5,1,-5,
     >8,2,-1,2,-1, 6,2,-2,2,-2, 8,2,-3,2,-3, 8,2,-4,2,-4, 8,2,-5,2,-5,
     >8,3,-1,3,-1, 8,3,-2,3,-2, 6,3,-3,3,-3, 8,3,-4,3,-4, 8,3,-5,3,-5,
     >8,4,-1,4,-1, 8,4,-2,4,-2, 8,4,-3,4,-3, 6,4,-4,4,-4, 8,4,-5,4,-5,
     >8,5,-1,5,-1, 8,5,-2,5,-2, 8,5,-3,5,-3, 8,5,-4,5,-4, 6,5,-5,5,-5/
C 6/8 bar(q_i) + q_j --> bar(q_i) + q_j
      DATA (((NCDATA(I,J,K),I=0,4),J=1,5),K=18,22)/
     >-6,-1,1,-1,1,-8,-1,2,-1,2,-8,-1,3,-1,3,-8,-1,4,-1,4,-8,-1,5,-1,5,
     >-8,-2,1,-2,1,-6,-2,2,-2,2,-8,-2,3,-2,3,-8,-2,4,-2,4,-8,-2,5,-2,5,
     >-8,-3,1,-3,1,-8,-3,2,-3,2,-6,-3,3,-3,3,-8,-3,4,-3,4,-8,-3,5,-3,5,
     >-8,-4,1,-4,1,-8,-4,2,-4,2,-8,-4,3,-4,3,-6,-4,4,-4,4,-8,-4,5,-4,5,
     >-8,-5,1,-5,1,-8,-5,2,-5,2,-8,-5,3,-5,3,-8,-5,4,-5,4,-6,-5,5,-5,5/
C 5/18/92 : costh distribution should be symmetry for replacement of
C            q_i and q_j.
C 4/5 bar(q_i) + bar(q_j) --> bar(q_i) + bar(q_j)
C     DATA (((NCDATA(I,J,K),I=0,4),J=1,5),K=23,27)/
C    >4,-1,-1,-1,-1,   5,-1,-2,-1,-2,   5,-1,-3,-1,-3,
C    >                 5,-1,-4,-1,-4,   5,-1,-5,-1,-5,
C    >5,-2,-1,-2,-1,   4,-2,-2,-2,-2,   5,-2,-3,-2,-3,
C    >                 5,-2,-4,-2,-4,   5,-2,-5,-2,-5,
C    >5,-3,-1,-3,-1,   5,-3,-2,-3,-2,   4,-3,-3,-3,-3,
C    >                 5,-3,-4,-3,-4,   5,-3,-5,-3,-5,
C    >5,-4,-1,-4,-1,   5,-4,-2,-4,-2,   5,-4,-3,-4,-3,
C    >                 4,-4,-4,-4,-4,   5,-4,-5,-4,-5,
C    >5,-5,-1,-5,-1,   5,-5,-2,-5,-2,   5,-5,-3,-5,-3,
C    >                 5,-5,-4,-5,-4,   4,-5,-5,-5,-5/
      DATA (((NCDATA(I,J,K),I=0,4),J=1,5),K=23,27)/
     > 4,-1,-1,-1,-1,   5,-1,-2,-1,-2,   5,-1,-3,-1,-3,
     >                  5,-1,-4,-1,-4,   5,-1,-5,-1,-5,
     >-5,-2,-1,-2,-1,   4,-2,-2,-2,-2,   5,-2,-3,-2,-3,
     >                  5,-2,-4,-2,-4,   5,-2,-5,-2,-5,
     >-5,-3,-1,-3,-1,  -5,-3,-2,-3,-2,   4,-3,-3,-3,-3,
     >                  5,-3,-4,-3,-4,   5,-3,-5,-3,-5,
     >-5,-4,-1,-4,-1,  -5,-4,-2,-4,-2,  -5,-4,-3,-4,-3,
     >                  4,-4,-4,-4,-4,   5,-4,-5,-4,-5,
     >-5,-5,-1,-5,-1,  -5,-5,-2,-5,-2,  -5,-5,-3,-5,-3,
     >                 -5,-5,-4,-5,-4,   4,-5,-5,-5,-5/
C ... first line is gluon + gluon --> gluon + gluon
C
C 7a  q_i + bar(q_i) --> q_j + bar(q_j)
      DATA (((NCDATA(I,J,K),I=0,4),J=1,5),K=28,32)/
     >12,21,21,21,21, 7,1,-1,2,-2,  7,1,-1,3,-3,
     >                7,1,-1,4,-4,  7,1,-1,5,-5,
     > 7,2,-2,1,-1,   0,0, 0,0, 0,  7,2,-2,3,-3,
     >                7,2,-2,4,-4,  7,2,-2,5,-5,
     > 7,3,-3,1,-1,   7,3,-3,2,-2,  0,0, 0,0, 0,
     >                7,3,-3,4,-4,  7,3,-3,5,-5,
     > 7,4,-4,1,-1,   7,4,-4,2,-2,  7,4,-4,3,-3,
     >                0,0, 0,0, 0,  7,4,-4,5,-4,
     > 7,5,-5,1,-1,   7,5,-5,2,-2,  7,5,-5,3,-3,
     >                7,5,-5,4,-4,  0,0, 0,0, 0 /
C 7b  bar(q_i) + q_i --> bar(q_j) + q_j
      DATA (((NCDATA(I,J,K),I=0,4),J=1,5),K=33,37)/
     > 0,0, 0,0, 0,  -7,-1,1,-2,2,  -7,-1,1,-3,3,
     >               -7,-1,1,-4,4,  -7,-1,1,-5,5,
     >-7,-2,2,-1,1,   0,0, 0,0, 0,  -7,-2,2,-3,3,
     >               -7,-2,2,-4,4,  -7,-2,2,-5,5,
     >-7,-3,3,-1,1,  -7,-3,3,-2,2,   0, 0,0, 0,0,
     >               -7,-3,3,-4,4,  -7,-3,3,-5,5,
     >-7,-4,4,-1,1,  -7,-4,4,-2,2,  -7,-4,4,-3,3,
     >                0,0, 0,0, 0,  -7,-4,4,-5,4,
     >-7,-5,5,-1,1,  -7,-5,5,-2,2,  -7,-5,5,-3,3,
     >               -7,-5,5,-4,4,   0, 0,0, 0,0 /
      DATA (((NCDATA(I,J,K),I=0,4),J=1,5),K=38,43)/
C 9a  q_i + bar(q_i) --> gluon + gluon
     > 9,1,-1,21,21,  9,2,-2,21,21, 9,3,-3,21,21,
     >                9,4,-4,21,21, 9,5,-5,21,21,
C 9b  bar(q_i) + q_i --> gluon + gluon
     >-9,-1,1,21,21,  -9,-2,2,21,21, -9,-3,3,21,21,
     >                -9,-4,4,21,21, -9,-5,5,21,21,
C 10a q_i + gluon ---> q_i + gluon
     > 10,1,21,1,21,  10,2,21,2,21, 10,3,21,3,21,
     >                10,4,21,4,21, 10,5,21,5,21,
C 10b bar(q_i) + gluon ---> bar(q_i) + gluon
     > 10,-1,21,-1,21,  10,-2,21,-2,21, 10,-3,21,-3,21,
     >                  10,-4,21,-4,21, 10,-5,21,-5,21,
C 10c gluon + q_i ---> gluon + q_i
     >-10,21,1,21,1,  -10,21,2,21,2, -10,21,3,21,3,
     >                -10,21,4,21,4, -10,21,5,21,5,
C 10d gluon + bar(q_i) ---> bar(q_i) + gluon
     >-10,21,-1,21,-1,  -10,21,-2,21,-2, -10,21,-3,21,-3,
     >                  -10,21,-4,21,-4, -10,21,-5,21,-5/
      DATA ((NCDATA(I,J,44),I=0,4),J=1,5)/
C 11  gluon + gluon ---> q + qbar
     > 11,21,21,1,-1,  11,21,21,2,-2,  11,21,21,3,-3,
     >                 11,21,21,4,-4,  11,21,21,5,-5 /
C
      DATA IFIRST/1/
CC    EXTERNAL EPABLK
C
C=====< Entry Point >===================================================
C
C*********************************************************
C*         Initialization of Histogram buffer            *
C*********************************************************
      PARAMETER (NHIST = 50, NSCAT = 10 )
      COMMON /PLOTB/ IBUF( 281*NHIST + 2527*NSCAT + 281 )
      CALL BHINIT( NHIST, NSCAT )
C* *******************************************************
C
C
C      IF( IFIRST .EQ. 1 ) THEN
C          READ(9,*) NCALL
C        READ(9,*) ITMX1, ITMX2
C        READ(9,*) ACC1, ACC2
C
        PRINT *,' Parameters for BASES'
        PRINT *,'     NCALL =',NCALL
        PRINT *,'     ITMX1 =',ITMX1,'   ITMX2=',ITMX2
        PRINT *,'     ACC1  =',ACC1, '   ACC2 =',ACC2
        PRINT *,' '
        PRINT *,' Generate mini-jet event due to mini-jet.'
C        EBEAM   = 30.
C      READ(9,*) EBEAM
        PRINT *,' EBEAM =',EBEAM,' GeV'
C        READ(9,*) PTMIN
        PRINT *,' PTMIN =',PTMIN,' GeV'
C        READ(9,*) NGNTYP
C        READ(9,*) NGNPRC
C        READ(9,*) NQSSRC
C        READ(9,*) NUMFLV
C        READ(9,*) NDISTR
C        READ(9,*) NGMINS
C        READ(9,*) NGPLUS
C        READ(9,*) XLAM
C        READ(9,*) XXLAM
C        READ(9,*) YMAX3
C        READ(9,*) YMAX4
C        READ(9,*) NTPJLC
        XLAM2  = XLAM*XLAM
        XXLAM2 = XXLAM*XXLAM
        IFIRST = 0
C
        PRINT *,'***** Other input parameters. ***********'
        PRINT *,' NGNTYP=',NGNTYP,'(Generated event type.)'
        PRINT *,'       =0 To generate all type events.'
        PRINT *,'       =1 To generate only one resolved process.'
        PRINT *,'       =2 To generate only two resolved process.'
        PRINT *,'       =3 To generate single subprocess specified ',
     >                         ' by NGNPRC.'
        PRINT *,' NGNPRC=',NGNPRC,' (Subprocess type',
     >                         ' Valid when NGNTYP=3)'
        PRINT *,'       = 1 ;  gamma + gamma --> q + qbar '
        PRINT *,'       = 2 ;  gamma + q     --> gluon + q'
        PRINT *,'       = 3 ;  gamma + gluon --> q + qbar '
        PRINT *,'       = 4 ;  q_i + q_i     --> q_i + q_i '
        PRINT *,'       = 5 ;  q_i + q_j     --> q_i + q_j '
        PRINT *,'       = 6 ;  q_i + bar(q_i)--> q_i + bar(q_i)'
        PRINT *,'       = 7 ;  q_i + bar(q_i)--> q_j + bar(q_j)'
        PRINT *,'       = 8 ;  q_i + bar(q_j)--> q_i + bar(q_j)'
        PRINT *,'       = 9 ;  q_i + bar(q_i)--> gluon + gluon '
        PRINT *,'       =10 ;  q   + gluon   --> q + gluon '
        PRINT *,'       =11 ;  gluon + gluon --> q + qbar    '
        PRINT *,'       =12 ;  gluon + gluon --> gluon + gluon '
        PRINT *,' NQSSRC=',NQSSRC,' (How to calculate Q^2)'
        PRINT *,'       = 0 ;  Q^2 = \hat(S)'
        PRINT *,'       = 1 ;  Q^2 = Pt^2   '
        PRINT *,' NUMFLV=',NUMFLV,' # of flavour to generate'
        PRINT *,'       = 0 ;  Nflv=5 when QSQ>500, =4 when 500>QSQ>50',
     >                       ' else 3'
        PRINT *,'       = 1 ;  Nflv=3 fixed.'
        PRINT *,'       = 2 ;  Nflv=4 fixed.'
        PRINT *,'       = 3 ;  Nflv=5 fixed.'
        PRINT *,' NDISTR=',NDISTR,' Parton distribution function '
        PRINT *,'       = 0 ; DG, select automatically',
     >                 'according to the qsquare.         '
        PRINT *,'       = 1 ; DG with Nflv=3              '
        PRINT *,'       = 2 ; DG with Nflv=4              '
        PRINT *,'       = 3 ; DG with Nflv=5              '
        PRINT *,'       = 4 ; LAC, SET-I                  '
        PRINT *,'       = 5 ; LAC, SET-II                 '
        PRINT *,'       = 6 ; LAC, SET-III                '
        PRINT *,'       = 7 ; DO                          '
        PRINT *,'       = 8 ; DO + VMD                    '
        PRINT *,'       = 9 ; Modified DO + VMD           '
        PRINT *,'       =10 ; Gordon and Storrow          '
        PRINT *,' NGMINS=',NGMINS,'Photon source from e- beam',
     >           '(0=Bremstrulung, 1=Beamstrulung)'
        PRINT *,' NGPLUS=',NGPLUS,'Photon source from e+ beam',
     >           '(0=Bremstrulung, 1=Beamstrulung)'
        PRINT *,' XLAM  =',XLAM,'(GeV^2) Lambda value to calculate ',
     >                          ' Parton density function.'
        PRINT *,' XXLAM =',XXLAM,'(GeV^2) Lambda value to calculate ',
     >                          ' Alpha_S'
        PRINT *,' YMAX3 =',YMAX3,'Rapidity max for jet-3'
        PRINT *,' YMAX4 =',YMAX4,'Rapidity max for jet-4'
Cc        PRINT *,' Event generation mode =',NTPJLC
Cc        PRINT *,'    = 0 ; Topaz ID '
Cc        PRINT *,'    = 1 ; JLC   ID '
C*
C      ENDIF
C
      RS      = 2.*EBEAM
C
C Description of the variables.
C
C  X(1) ; X1 for the photon energy emitted from e-
C  X(2) ; X2 for the photon energy emitted from e+
C  X(3) ; X3 for the parton energy of X1 photon
C  X(4) ; X4 for the parton energy of X2 photon
C  X(5) ; Cos(th) in sub-process rest frame.
C
      DO 100 I = 1, 6
        XL(I) = 0.D0
        XU(I) = 1.D0
100   CONTINUE
C
      NDIM  =      6
      NGDIM =      NDIM
C
C ... Histogram definition.
C
C
C      PRINT *,'Going to start call of XHINIT'
      S     = RS*RS
      IF(IHIS.EQ.1)THEN
      CALL XHINIT(1,  0.0D0 , XU(1), 50,'X1  ')
C      PRINT *,'First XHINIT ...'
      CALL XHINIT(2,  0.0D0 , XU(2), 50, 'X2  ')
      CALL XHINIT(3,  0.0D0 , XU(3), 50,'X3  ')
      CALL XHINIT(4,  0.0D0 , XU(4), 50,'X4  ')
      CALL XHINIT(5,  0.0D0 , XU(5), 50,'X5  ')
      CALL XHINIT(6,  0.0D0 , XU(6), 50,'X6  ')
C      CALL XHINIT(100, 0.D0,  1.D0,  50,'Lumi function')
      IF( EBEAM .LT. 40. ) THEN
        CALL XHINIT(11, 0.D0, 25.D0,  50,'Pt')
        CALL XHINIT(12, 5.D0, 35.D0,  30,'M_jj (GeV)')
        CALL XHINIT(13, 0.D0, 25.D0,  50,'Pt(for Direct)')
        CALL XHINIT(14, 0.D0, 25.D0,  50,'Pt(for 1 resolved)')
        CALL XHINIT(15, 0.D0, 25.D0,  50,'Pt(for two resolved)')
C        CALL XHINIT(16, 0.D0, 20.D0,  20,'S of each ds/do type@')
      ELSE
        CALL XHINIT(11, 1.D0,  5.D0,  50,'Pt')
        CALL XHINIT(12, 0.D0,100.D0,  50,'M_jj (GeV)')
        CALL XHINIT(13, 1.D0,  5.D0,  50,'Pt(for Direct)')
        CALL XHINIT(14, 1.D0,  5.D0,  50,'Pt(for 1 resolved)')
        CALL XHINIT(15, 1.D0,  5.D0,  50,'Pt(for two resolved)')
C        CALL XHINIT(16, 0.D0, 20.D0,  20,'S of each ds/do type')
C        CALL XHINIT(17, -5.D0, 5.D0,  50, 'Rapidity distr.')
          XBMIN = DLOG10(PTMIN)
C         XBMAX = DLOG10(EBEAM)
          XBMAX = DLOG10(40.0D0)
C        CALL XHINIT(20, XBMIN, XBMAX, 50, 'Pt(for all) log scale')
C        CALL XHINIT(21, XBMIN, XBMAX, 50, 'Pt(For Direct log scale')
C        CALL XHINIT(22, XBMIN, XBMAX, 50, 'Pt(for 1Res. log scale')
C        CALL XHINIT(23, XBMIN, XBMAX, 50, 'Pt(for 2Res. log scale')
C        CALL XHINIT(24, XBMIN, XBMAX, 50, 'Pt(for 2Res. (uds)')
C        CALL XHINIT(25, XBMIN, XBMAX, 50, 'Pt(for 2Res. (c)')
C        CALL XHINIT(26, XBMIN, XBMAX, 50, 'Pt(for 2Res. (b)')
C       CALL XHINIT(20, 0.D0, 25.D0,  50,'Pt(for all )')
C       CALL XHINIT(21, 0.D0, 25.D0,  50,'Pt(for Direct)')
C       CALL XHINIT(22, 0.D0, 25.D0,  50,'Pt(for gamma+q)')
C       CALL XHINIT(23, 0.D0, 25.D0,  50,'Pt(for gamma+gluon)')
C       CALL XHINIT(24, 0.D0, 25.D0,  50,'Pt(for q/g + q/g)')
C      ENDIF
C      NSKIP = 0
C      IF( NSKIP .EQ. 0 ) THEN
C        CALL XHINIT(32,XBMIN,XBMAX,50,'Pt(for Process ID=2)')
C        CALL XHINIT(33,XBMIN,XBMAX,50,'Pt(for Process ID=3)')
C        CALL XHINIT(34,XBMIN,XBMAX,50,'Pt(for Process ID=4)')
C        CALL XHINIT(35,XBMIN,XBMAX,50,'Pt(for Process ID=5)')
C        CALL XHINIT(36,XBMIN,XBMAX,50,'Pt(for Process ID=6)')
C        CALL XHINIT(37,XBMIN,XBMAX,50,'Pt(for Process ID=7)')
C        CALL XHINIT(38,XBMIN,XBMAX,50,'Pt(for Process ID=8)')
C        CALL XHINIT(39,XBMIN,XBMAX,50,'Pt(for Process ID=9)')
C        CALL XHINIT(40,XBMIN,XBMAX,50,'Pt(for Process ID=10)')
C        CALL XHINIT(41,XBMIN,XBMAX,50,'Pt(for Process ID=11)')
C        CALL XHINIT(42,XBMIN,XBMAX,50,'Pt(for Process ID=12)')
C      ENDIF
C      IF( PTMIN.LT.3.9D0 ) THEN
C        CALL XHINIT(51, 0.D0,  1.D0,  50,'X1 for Pt 3-4GeV@')
C        CALL XHINIT(52, 0.D0,  1.D0,  50,'X3 for Pt 3-4GeV@')
C        CALL XHINIT(53, 0.D0,  1.D0,  50,'X1 for Pt 7-8GeV@')
C        CALL XHINIT(54, 0.D0,  1.D0,  50,'X3 for Pt 7-8GeV@')
C        CALL DHINIT(55, 0.0D0, 1.0D0  , 50,
C     >                  0.0D0, 1.0D0  , 50, 'X1 vs X3 for Pt=3-4GeV@')
C        CALL DHINIT(56, 0.0D0, 1.0D0  , 50,
C     >                  0.0D0, 1.0D0  , 50, 'X1 vs X3 for Pt=7-8GeV@')
C        CALL XHINIT(57, 0.D0,  1.D0,  50,'X3 for Pt 3-4GeV@ for g')
C        CALL XHINIT(58, 0.D0,  1.D0,  50,'X3 for Pt 3-4GeV@ for q')
C      ENDIF
      ENDIF
      ENDIF
C      PRINT *,'End of Userin'
C
      RETURN
      END
C
C234567890---------2---------3---------4---------5---------6---------7--
C
C USROUT
C
C234567890---------2---------3---------4---------5---------6---------7--
C
      SUBROUTINE USROUT
C
      COMMON /LOOP0/ LOOPC
      REAL*8 AVG1, SD, CHI2A,CPU
      COMMON /BSRSLT/AVG1,SD,CHI2A,CPU,ITF
C
      DATA IFG / 0/
C
C      CALL XHSAVE(24,11)
C      CALL XHSAVE(24,12)
C      CALL XHSAVE(24,13)
C      CALL XHSAVE(24,14)
C      CALL XHSAVE(24,15)
C      CALL XHSAVE(24,20)
C      CALL XHSAVE(24,21)
C      CALL XHSAVE(24,22)
C      CALL XHSAVE(24,23)
C      CALL XHSAVE(24,24)
C      CALL XHSAVE(24,25)
C      CALL XHSAVE(24,26)
C
C      CALL XHSAVE(24, 32)
C      CALL XHSAVE(24, 33)
C      CALL XHSAVE(24, 34)
C      CALL XHSAVE(24, 35)
C      CALL XHSAVE(24, 36)
C      CALL XHSAVE(24, 37)
C      CALL XHSAVE(24, 38)
C      CALL XHSAVE(24, 39)
C      CALL XHSAVE(24, 40)
C      CALL XHSAVE(24, 41)
C      CALL XHSAVE(24, 42)
C
C      CALL XHSAVE(24, 51)
C      CALL XHSAVE(24, 52)
C      CALL XHSAVE(24, 53)
C      CALL XHSAVE(24, 54)
C
      RETURN
      END
C***********************************************************************
C*
C* ---------------------------------------------======
C*  Subroutine MNJCRS(NPROC, EHAT, COSTH, NFLAV, DSDCS )
C* ---------------------------------------------======
C*(Function)
C*  Calculate sub-process cross section.
C*(Input)
C*  NPROC  ; Process ID.
C*            1 = gamma + gamma   ---> q qbar
C*            2 = gamma + q       ---> gluon + q
C*           -2 = q + gamma       ---> gluon + q
C*            3 = gamma + gluon   ---> q + qbar
C*           -3 = gluon + gamma   ---> q + qbar
C*            4 = q_i   + q_i     ---> q_i + q_i
C*            5 = q_i   + q_j     ---> q_i + q_j
C*            6 = q_i + \bar(q_i) ---> q_i + \bar(q_i)
C*            7 = q_i + \bar(q_i) ---> q_j + \bar(q_j)
C*            8 = q_i + \bar(q_j) ---> q_i + \bar(q_j)
C*           -8 = :bar(q_j) + q_i ---> q_i + \bar(q_j)
C*            9 = q_i + \bar(q_i) ---> gluon + gluon
C*           -9 = :rar(q_i) + q_i ---> gluon + gluon
C*           10 = q_i + gluon     ---> q_i + gluon
C*          -10 = gluon + q_i     ---> q_i + gluon
C*           11 = gluon + gluon   ---> q_i + q_i
C*           12 = gluon + gluon   ---> gluon + gluon
C*   EHAT ; Center of mass energy
C*   COSTH ; production angle in CM system
C*   NFLAV ; # of flavour (3 or 4 or 5 )
C*
C*(Output)
C*   DSDCS ; dsigma/dcos(th)      (pb)
C*
C*(Author)
C*   A. Miyamoto   19-Nov-1991  Original version.
C*
C*********************************************************************
C*
      SUBROUTINE MNJCRS( NPROC, EHAT, COSTH, NFLAV, DSDCS )
      IMPLICIT REAL*8 (A-H,O-Z)
      PARAMETER (GEV2PB=0.38927E+9)
      PARAMETER (ALPHA=1./137.0359895)
      PARAMETER (PI=3.14159265358979323846)
      PARAMETER (TWOPI=2.*PI)
C
C======< Entry Point >===============================================
C
      IPROC = IABS(NPROC)
      CS    = COSTH
      IF( NPROC.LT.0 ) CS = -COSTH
      S = 4.*EHAT*EHAT
      T = -0.5*S*(1.-CS)
      U = -0.5*S*(1.+CS)
      ALPHAS = 0.12
C
C ... Switch according to the process
C
C gamma + gamma --> q + qbar
      IF( IPROC .EQ. 1 ) THEN
        DSDCS = PI*ALPHA*ALPHA/S*3.
     >        *(T/U +U/T)
C
C gamma + q --> gluon + q
      ELSEIF( IPROC .EQ. 2 ) THEN
        DSDCS = -4.*PI*ALPHA*ALPHAS/(3.*S)
     >          *(T/S+S/T)
C
C gamma + gluon --> q + qbar
      ELSEIF( IPROC .EQ. 3 ) THEN
        DSDCS = 0.5*PI*ALPHA*ALPHAS/S
     >          *(U/T+T/U)
C       DSDCS = TWOPI*ALPHA*ALPHAS/S
C    >          *(U/T+T/U)
C
C q_i + q_i --> q_i + q_i
      ELSEIF( IPROC .EQ. 4 ) THEN
        DSDCS = 0.5*PI*ALPHAS*ALPHAS/S
     >         *( 4./9.*( (S*S+U*U)/(T*T) + (S*S+T*T)/(U*U) )
     >            -8./27.*S*S/(U*T) )
        DSDCS = 0.5*DSDCS
C
C q_i + q_j --> q_i + q_j
      ELSEIF( IPROC .EQ. 5 ) THEN
        DSDCS = 0.5*PI*ALPHAS*ALPHAS/S
     >         *4./9.*(S*S+U*U)/(T*T)
C
C q_i + bar(q_i) --> q_i + bar(q_i)
      ELSEIF( IPROC .EQ. 6 ) THEN
        DSDCS = 0.5*PI*ALPHAS*ALPHAS/S
     >         *( 4./9.*( (S*S+U*U)/(T*T) + (T*T+U*U)/(S*S) )
     >           - 8./27.*U*U/(S*T) )
C
C q_i + bar(q_i)  ---> q_j + bar(q_j)
      ELSEIF( IPROC .EQ. 7 ) THEN
        DSDCS = 0.5*PI*ALPHAS*ALPHAS/S
     >          *4./9.*( (T*T+U*U)/(S*S) )
C
C q_i + bar(q_j) --> q_i + bar(q_j)
      ELSEIF( IPROC .EQ. 8 ) THEN
        DSDCS = 0.5*PI*ALPHAS*ALPHAS/S
     >          *4./9.*(S*S+U*U)/(T*T)
C
C q_i + bar(q_i) --> gluon + gluon
      ELSEIF( IPROC .EQ. 9 ) THEN
        DSDCS = 0.5*PI*ALPHAS*ALPHAS/S
     >        *( 32./27.*(U*U+T*T)/(U*T) - 8./3.*(U*U+T*T)/(S*S) )
C
C q_i + gluon ---> q_i + gluon
      ELSEIF( IPROC .EQ. 10 ) THEN
        DSDCS = 0.5*PI*ALPHAS*ALPHAS/S
     >        *( -4./9.*(U*U+S*S)/(U*S) + (U*U+S*S)/(T*T) )
C
C gluon + gluon ---> q_i + bar(q_i)
      ELSEIF( IPROC .EQ. 11 ) THEN
        DSDCS = 0.5*PI*ALPHAS*ALPHAS/S
     >        *(  1./6.*(U*U+T*T)/(U*T) - 3./8.*(U*U+T*T)/(S*S) )
        DSDCS = 0.5*DSDCS
C
C gluon + gluon ---> gluon + gluon
      ELSEIF( IPROC .EQ. 12 ) THEN
        DSDCS = 0.5*PI*ALPHAS*ALPHAS/S
     >        *4.5*(3.-U*T/(S*S) - U*S/(T*T) - S*T/(U*U) )
        DSDCS = 0.5*DSDCS
      ELSE
        PRINT *,'%Error in MNJCRS ... Invalid NPROC is specified.',
     >          ' NPROC=',NPROC
      ENDIF
C
      DSDCS = DSDCS * GEV2PB
      RETURN
      END
C***********************************************************************
C*
C*    ------------------------------------=====
C*    Subroutine MNJGAM( NTYPE, X, EBEAM, FX )
C*    ------------------------------------=====
C*
C*(Function)
C*    Get weight of phton spectrum.
C*(Input)
C*    NTYPE  : Type of Photon spectrum
C*      = 1 for DG type Bremstrahlung spectrum
C*      = 2 for Bremstrahlung spectrum used by DG in the study for LC
C*      =10 for Flat beam Beamstrahlungf spectrum
C*      =11 for JLC Beamstrahlung spectrum at Ebeam=150GeV
C*      =12 for JLC Beamstrahlung spectrum at Ebeam=250GeV
C*      =13 for JLC Beamstrahlung spectrum at Ebeam=500GeV
C*      =14 for JLC Beamstrahlung spectrum at Ebeam=750GeV
C*      =21 for New Beamstrahlung spectrum at Ebeam=150GeV
C*      =22 for New Beamstrahlung spectrum at Ebeam=150GeV
C*    X      : Real*8 randum variable from 0 to 1.
C*             Photon Energy=X*Ebeam
C*    EBEAM  : Beam energy in GeV unit, required when NTYPE=1
C*(Output)
C*    FX     : Weight for the photon. 0 to 1.
C*(Author)
C*    A.Miyamoto  9-Feb,1992  Original version.
C*               18-Jul-1998  Add NEW JLC parameters.
C*
C***********************************************************************
C
      SUBROUTINE MNJGAM( NTYPE, X, EBEAM, FX )
C
      IMPLICIT REAL*8 (A-H,O-Z)
      PARAMETER (PI=3.14159265,
     >           TWOPI=2*PI,
     >           ALPHA = 1./137.0359895 ,
     >           AME    = 0.51099906D-3 ,
     >           AME2   = AME*AME )
      PARAMETER (ONEO3  = 1.D0/3.D0,
     >           TWOO3  = 2.D0/3.D0 )
      PARAMETER (RECLAS=2.81794092D-13)
C ... JLC Beam parameters.
      REAL*8   BEAMPR(7,4)
      DATA BEAMPR/
     >  150., 433.D-7, 5.91D-7, 142.D-4, 1.14D10, 1.38D33, 1.18,
     >  250., 335.D-7, 4.48D-7, 152.D-4, 1.18D10, 2.39D33, 1.51,
     >  500., 372.D-7, 3.16D-7, 113.D-4, 1.82D10, 8.76D33, 1.80,
     >  750., 561.D-7, 2.87D-7,  95.D-4, 2.40D10, 12.7D33, 1.45 /
      REAL*8   BEAMP(7,8)
      DATA BEAMP/
CC   >  150., 184.D-7, 3.1D-7,  96.D-4, 0.59D10,  6.1D33, 1.5 ,
CC   >  250., 167.D-7, 2.2D-7,  50.D-4, 0.56D10, 12.7D33, 1.35 /
     >  150., 335.D-7, 3.9D-7,  70.8D-4, 0.89D10,  5.87D33, 1.12 ,
     >  250., 260.D-7, 3.0D-7,  72.8D-4, 0.89D10,  9.75D33, 1.37 ,
     >  150., 335.D-7, 3.92D-7,  80.D-4, 1.56D10,  3.1D33, 1.80 ,
     >  250., 301.D-7, 3.04D-7,  80.D-4, 1.30D10,  4.4D33, 1.62 ,
     >  150., 335.D-7, 3.92D-7,  80.D-4, 1.00D10,  5.9D33, 1.19 ,
     >  250., 260.D-7, 3.04D-7,  80.D-4, 1.00D10,  9.7D33, 1.44 ,
     >  150., 335.D-7, 3.92D-7,  85.D-4, 0.63D10,  3.5D33, 0.80 ,
     >  250., 260.D-7, 3.04D-7,  67.D-4, 0.63D10,  6.3D33, 0.95 /
      DATA IOBEAM/0/
      DATA JOBEAM/0/
C
C ======================================================================
C
C ----------------------------------------------------------------------
C (1) Switch according to the type of Photon spectrum.
C ----------------------------------------------------------------------
C
C ... DG type Bremstrahlung spectrum.
C
      IF( NTYPE.EQ.1 ) THEN
        FX    = ALPHA/(PI*X)*
     >        ( (1.D0+(1.D0-X)**2)*(DLOG(EBEAM/AME)-0.5D0)
     >        + X**2*0.5D0*(DLOG(2.D0*(1.D0-X)/X)+1.D0)
     >        + (2.D0-X)**2*0.5D0*DLOG(2*(1.D0-X)/(2.D0-X))
     >      )
C
C ... DG type Bremstrahlung spectrum used for the background
C     study for Linear Collier.
C
      ELSEIF( NTYPE.EQ.2 ) THEN
        FX    = 0.85D0*ALPHA/(PI*X)*DLOG(EBEAM/AME)
     >            *(1.D0+(1.D0-X)**2)
C
C ... Flux for photon-photon collision.
C
      ELSEIF( NTYPE.EQ.3 ) THEN
      IF( X.LT.0.8 ) THEN
       FX = 0.0
        ELSE
       FX = 5.0
      ENDIF
C
C
C ... Flat beam spectrum used by DG.
C
      ELSEIF( NTYPE.EQ.10 ) THEN
        IF( X.GT.0.84 ) THEN
       FX = 0.0D0
      ELSE
       FX = (2.25D0-DSQRT(X/0.166D0))*(((1.D0-X)/X)**TWOO3)
        ENDIF
C
C ... JLC Beamstraulung spectrum.
C     Average Photon spectrum during the collision.
C
      ELSEIF( NTYPE.GE.11.AND.NTYPE.LE.14) THEN
      NBEAM = NTYPE - 10
      IF( NBEAM.NE.IOBEAM ) THEN
       IOBEAM = NBEAM
          E0 = BEAMPR(1,NBEAM)
          R0 = E0/AME
          UPSBAR = 5./6.*RECLAS*RECLAS*R0*BEAMPR(5,NBEAM)/
     >        (ALPHA*BEAMPR(4,NBEAM)*(BEAMPR(2,NBEAM)+BEAMPR(3,NBEAM)))
          XNCL = 1.06*ALPHA*RECLAS*BEAMPR(5,NBEAM)*
     >         2./(BEAMPR(2,NBEAM)+BEAMPR(3,NBEAM))
          XNGAM = XNCL/SQRT( 1.D0+UPSBAR**TWOO3)
          XKAPPA= 2.D0/(3.D0*UPSBAR)
CUX2        IGAM = GAMMA(ONEO3, GAMVAL )
          GAMVAL = DGAMMA(ONEO3)
          FACT  = XKAPPA**ONEO3/GAMVAL
        ENDIF
        G = 1.D0 - ( 0.5D0*(1+X)*XNCL/XNGAM + 0.5D0*(1-X) )
     >           * (1-X)**TWOO3
        FX= FACT/(X**TWOO3 * (1.D0-X)**ONEO3) *DEXP(-XKAPPA*X/(1-X))
     >    * ( (1-1./6./SQRT(XKAPPA))/G
     >          *(1-(1-DEXP(-G*XNGAM))/(G*XNGAM))
     >        + 1./6./SQRT(XKAPPA)
     >          *(1.-(1.-DEXP(-XNGAM))/XNGAM)   )
C
C  New Beam parameter set.
C
      ELSEIF( NTYPE.GE.21.AND.NTYPE.LE.28) THEN
      NBEAM = NTYPE - 20
      IF( NBEAM.NE.JOBEAM ) THEN
       JOBEAM = NBEAM
          E0 = BEAMP(1,NBEAM)
          R0 = E0/AME
          UPSBAR = 5./6.*RECLAS*RECLAS*R0*BEAMP(5,NBEAM)/
     >        (ALPHA*BEAMP(4,NBEAM)*(BEAMP(2,NBEAM)+BEAMP(3,NBEAM)))
          XNCL = 1.06*ALPHA*RECLAS*BEAMP(5,NBEAM)*
     >         2./(BEAMP(2,NBEAM)+BEAMP(3,NBEAM))
          XNGAM = XNCL/SQRT( 1.D0+UPSBAR**TWOO3)
          XKAPPA= 2.D0/(3.D0*UPSBAR)
CUX2      IGAM = GAMMA(ONEO3, GAMVAL )
          GAMVAL = DGAMMA(ONEO3)
          FACT  = XKAPPA**ONEO3/GAMVAL
        ENDIF
        G = 1.D0 - ( 0.5D0*(1+X)*XNCL/XNGAM + 0.5D0*(1-X) )
     >           * (1-X)**TWOO3
        FX= FACT/(X**TWOO3 * (1.D0-X)**ONEO3) *DEXP(-XKAPPA*X/(1-X))
     >    * ( (1-1./6./SQRT(XKAPPA))/G
     >          *(1-(1-DEXP(-G*XNGAM))/(G*XNGAM))
     >        + 1./6./SQRT(XKAPPA)
     >          *(1.-(1.-DEXP(-XNGAM))/XNGAM)   )
      ENDIF
      IF(FX.EQ.0.0)FX=1E-10
      RETURN
      END
C***********************************************************************
C*
C* ----------------------------------------------=====
C*  Subroutine MNJPRB(NTYP, NFLV, QSQ, X, XLAM2, PROB)
C* ----------------------------------------------=====
C*(Function)
C*   Calculate parton density inside photon.
C*(Input)
C*   NTYP ; Type of model to be used for the parton density function.
C*      = 1 ; DG with Nflv=3
C*      = 2 ; DG with Nflv=4
C*      = 3 ; DG with Nflv=5
C*      = 4 ; LAC, SET-I
C*      = 5 ; LAC, SET-II
C*      = 6 ; LAC, SET-III
C*      = 7 ; DO
C*      = 8 ; DO + VMD
C*      = 9 ; Modified DO + VMD
C*   NFLV ; Parton ID, should be >0 1(d),2(u),3(s),4(c),5(b),21(g)
C*          otherwise PROB=1.0
C*   QSQ  ; QSQ of the process (GeV^2)
C*   X    ; Bjorken X
C*   XLAM2 ; Lambda^2 (GeV^2)
C*
C*(Output)
C*   PROB  ; Probability to find parton of energy X
C*(Author)
C*   A. Miyamoto  24-Jan-1992  ; Original version.
C*(Modified)
C*   A.J.Finch     6-Jun-1993  ; Added Gordon and Storrow 
C*
C***********************************************************************
C
      SUBROUTINE MNJPRB(NTYP, NFLV, QSQ, X, XLAM2, PROB)
      IMPLICIT REAL*8 (A-H,O-Z)
C
      REAL*8     XPDF(0:5)
      PARAMETER  (ALPHA=1./137.0359895)
      PARAMETER  (PI=3.141592654)
      PARAMETER  (TWOPI=2.*PI)
      PARAMETER  (E2UP=4./9., E2DOWN=1./9.)
      REAL*8     CHSQ(5)
      DATA  CHSQ/E2DOWN, E2UP, E2DOWN, E2UP, E2DOWN/
C
C ======< Entry Point >================================================
C
C ------------------------------------------------------
C --- Skip in case of direct process
C ------------------------------------------------------
C
      IF( NFLV.EQ.22 ) THEN
        PROB = 1.0D0
        RETURN
      ENDIF
C
C
C ------------------------------------------------------
C (1) DG parametrization.
C ------------------------------------------------------
C
      IF( NTYP .GE.1.AND.NTYP.LE.3 ) THEN
        NFE = NTYP
        IF( NFLV.EQ.21 ) THEN
          TLOG = DLOG(QSQ/XLAM2)
          CALL PYSTGA(NFE,X,TLOG,XPGL,XPQU,XPQD)
          PROB   = XPGL*ALPHA/X
        ELSE
          TLOG = DLOG(QSQ/XLAM2)
          CALL PYSTGA(NFE,X,TLOG,XPGL,XPQU,XPQD)
          IF( MOD(NFLV,2).EQ.1 ) THEN
            PROB = XPQD*ALPHA/X
          ELSE
            PROB = XPQU*ALPHA/X
          ENDIF
        ENDIF
C
C ------------------------------------------------------
C (2) LAC parametrization.
C ------------------------------------------------------
C
      ELSEIF( NTYP.GE.4 .AND. NTYP.LE.6 ) THEN
        IF( QSQ.GE.1.0D5 .OR.
     >      (NTYP.EQ.4.AND.QSQ.LE.4.0D0) .OR.
     >      (NTYP.EQ.5.AND.QSQ.LE.1.0D0) .OR.
     >      (NTYP.EQ.6.AND.QSQ.LE.4.0D0) )  THEN
          PROB = 0.0
        ELSEIF( NFLV.EQ.21 ) THEN
          CALL PHLAC(NTYP-3, X, QSQ, XPDF )
          PROB = XPDF(0)/X
        ELSE
          CALL PHLAC(NTYP-3, X, QSQ, XPDF )
          PROB = XPDF(NFLV)/X
        ENDIF
C
C ------------------------------------------------------
C (3) DO parametrization.
C ------------------------------------------------------
C
      ELSEIF( NTYP.EQ.7) THEN
        TRM1   = ( 1.81 - 1.67*X + 2.16*X*X )*X**0.70
     >         / (1. - 0.4*LOG(1.-X) )
        TRM2   = 0.0038*(1.-X)**1.82/(X**1.18)
        TOTWPI = LOG(QSQ/XLAM2)/TWOPI*ALPHA/X
        IF( NFLV.EQ.21 ) THEN
          PROB = TOTWPI*0.194*(1-X)**1.03/(X**0.97)
        ELSE
          PROB = TOTWPI*(CHSQ(NFLV)*TRM1 + TRM2 )
        ENDIF
C
C ------------------------------------------------------
C (4) DO + VMD
C ------------------------------------------------------
C
      ELSEIF( NTYP.EQ.8) THEN
        TOTWPI = LOG(QSQ/XLAM2)/TWOPI*ALPHA/X
        IF( NFLV.EQ.21 ) THEN
          PROB = TOTWPI*0.194*(1-X)**1.03/(X**0.97)
          PROB = PROB + ALPHA*2.*(1.-X)**3/X
        ELSE
          TRM1   = ( 1.81 - 1.67*X + 2.16*X*X )*X**0.70
     >           / (1. - 0.4*LOG(1.-X) )
          TRM2   = 0.0038*(1.-X)**1.82/(X**1.18)
          PROB = TOTWPI*(CHSQ(NFLV)*TRM1 + TRM2)
          IF( NFLV.LT.4 ) THEN
            QVMD = ALPHA*(5./16.*(1.-X)/SQRT(X) + 0.1/X*(1-X)**5)
            PROB = PROB + QVMD
          ENDIF
        ENDIF
C
C ------------------------------------------------------
C (5) Modified DO + VMD
C ------------------------------------------------------
C
      ELSEIF( NTYP.EQ.9 ) THEN
        IF( NFLV.EQ.21 ) THEN
          TOTWPI = LOG(QSQ/XLAM2)/TWOPI*ALPHA/X
          PROB = TOTWPI*0.194*(1-X)**1.03/(X**0.97)
          PROB = PROB + ALPHA*2.*(1.-X)**3/X
        ELSE
          IF( X.GT.0.05 ) THEN
            TRM1   = ( 1.81 - 1.67*X + 2.16*X*X )*X**0.70
     >             / (1. - 0.4*LOG(1.-X) )
            TRM2   = 0.0038*(1.-X)**1.82/(X**1.18)
            TOTWPI = LOG(QSQ/XLAM2)/TWOPI*ALPHA/X
            PROB   = TOTWPI*(CHSQ(NFLV)*TRM1 + TRM2)
          ELSE
            XX     = 0.05
            TRM1   = ( 1.81 - 1.67*XX + 2.16*XX*XX )*XX**0.70
     >             / (1. - 0.4*LOG(1.-XX) )
            TRM2   = 0.0038*(1.-XX)**1.82/(XX**1.18)
            T      = LOG(QSQ/XLAM2)
            TOTWPI = T/TWOPI*ALPHA
            PR05   = TOTWPI*(CHSQ(NFLV)*TRM1 + TRM2)
            CIQ    = PR05/T*(0.05**1.6)
            PROB    = CIQ*T*X**(-1.6)
          ENDIF
          IF( NFLV.LT.4 ) THEN
            QVMD   = ALPHA*(5./16.*(1.-X)/SQRT(X) + 0.1/X*(1-X)**5)
            PROB   = PROB + QVMD
          ENDIF
        ENDIF
C
C ------------------------------------------------------
C (6) GORDON AND STORROW HIGHER ORDER
C ------------------------------------------------------
C
      ELSEIF( NTYP.EQ.10) THEN
        CALL      PHOGS2(X,QSQ,  U,D,S,C,B,G)
C*   NFLV ; Parton ID, should be >0 1(d),2(u),3(s),4(c),5(b),21(g)
        GANDS = 0.0000001
        IF(NFLV.EQ.1)GANDS = U
        IF(NFLV.EQ.2)GANDS = D
        IF(NFLV.EQ.3)GANDS = S
        IF(NFLV.EQ.4)GANDS = C
        IF(NFLV.EQ.5)GANDS = B
        IF(NFLV.EQ.21)GANDS = G

        PROB =  GANDS

      ENDIF
C
C
C
      RETURN
      END
C Date:    MON, 13 JAN 92 14:25:48 MEZ
C From:    Krzysztof Charchula <F1PCHA@DHHDESY3.BITNET>
C To:       <TAYM@JPNKEKTR.BITNET>
C Subject: LAC
C
C   Involved subroutine
C      Sub. PHLAC
C           PHLAC1
C           PHLAC2
C      Func. PHFINT
C
C
C********************************************************************
C* PHOPDF 1.0 (May 1991)                                            *
C* ---------------------                                            *
C*                                                                  *
C*    Parametrization of parton distribution functions              *
C*    in the photon (LO analysis) - full  solution of AP eq.!       *
C*                                                                  *
C* authors: H.Abramowicz, K.Charchula and A.Levy  (LAC)             *
C*                 /Phys. Lett. B 269 (1991) 458/                   *
C*                                                                  *
C* Prepared by:                                                     *
C*             Krzysztof Charchula, DESY                            *
C*             bitnet: F1PCHA@DHHDESY3                              *
C*             decnet: 13313::CHARCHULA                             *
C********************************************************************
      SUBROUTINE PHLAC(ISET,X,Q2,XPDF)
C...ISET   Q20(GEV2)  comments
C...------------------------------------------------------------
C... 1        4        xG(x,Q20)-->x**(-0.34) (fitted) at low x
C... 2        4        xG(x,Q20)-->const (fixed) at low x
C... 3        1        as result--very hard gluons
C...------------------------------------------------------------
C...X          - Bjorken x variable
C...Q2         - square of momentum scale (in GeV**2)
C...XPDF(0:5)  - vector containing X*p(x,Q2), where:
C...               IPDF =  0 1 2 3 4 5
C...             flavour=  g d u s c b
C...             p_bar=p (p=u,d,s,c)
C...LAMBDA=0.2 GeV, Nf=4  (i.e. xb=0)
C...range of validity:
C...    10**-4 < X  < 1
C...     4(1)  < Q2 < 10**5 GeV**2
C...REAL*8 version
      IMPLICIT REAL*8(A-H,O-Z)
      DIMENSION XPDF(0:5)
      DATA XMIN/1.D-04/,XMAX/1./,Q2MIN/4./,Q2MIN3/1./,Q2MAX/1.D5/
C...initialization
       DO  5 JF=0,5
         XPDF(JF)=0.
 5     CONTINUE
C...check of ISET range
       IF ((ISET.LE.0).OR.(ISET.GT.3)) THEN
         WRITE(*,*) 'Error in PHLAC: ISET out of range'
         RETURN
       ENDIF
C...check range in X
       IF ((X.LT.XMIN).OR.(X.GE.XMAX)) THEN
         WRITE(*,*) 'Error in PHLAC: X out ouf range'
         RETURN
       ENDIF
C...check range in Q2
       IF ((ISET.LE.2).AND.(Q2.LT.Q2MIN)) THEN
         WRITE(*,*) 'Error in PHLAC: Q2 < Q2MIN'
         RETURN
       ENDIF
       IF ((ISET.EQ.3).AND.(Q2.LT.Q2MIN3)) THEN
         WRITE(*,*) 'Error in PHLAC: Q2 < Q2MIN'
         RETURN
       ENDIF
       IF (Q2.GT.Q2MAX) THEN
         WRITE(*,*) 'Error in PHLAC: Q2 > Q2MAX'
         RETURN
       ENDIF
       IF (ISET.EQ.1) CALL PHLAC1(X,Q2,XPDF)
       IF (ISET.EQ.2) CALL PHLAC2(X,Q2,XPDF)
       IF (ISET.EQ.3) CALL PHLAC3(X,Q2,XPDF)
      RETURN
      END
C-----------------------------------------------
      SUBROUTINE PHLAC1(X,Q2,XPDF)
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER(IX=100,IQ=7,NARG=2,NFUN=4)
      DIMENSION XT(IX),Q2T(IQ),ARG(NARG),NA(NARG),ENT(IX+IQ)
      DIMENSION XPV(IX,IQ,0:NFUN),XPDF(0:5)
C...100 x valuse; in (D-4,.77) log spaced (78 points)
C...              in (.78,.995) lineary spaced (22 points)
      DATA Q2T/4.,10.,50.,1.D2,1.D3,1.D4,1.D5/
      DATA  XT/
     &0.1000D-03,0.1123D-03,0.1262D-03,0.1417D-03,0.1592D-03,0.1789D-03,
     &0.2009D-03,0.2257D-03,0.2535D-03,0.2848D-03,0.3199D-03,0.3593D-03,
     &0.4037D-03,0.4534D-03,0.5093D-03,0.5722D-03,0.6427D-03,0.7220D-03,
     &0.8110D-03,0.9110D-03,0.1023D-02,0.1150D-02,0.1291D-02,0.1451D-02,
     &0.1629D-02,0.1830D-02,0.2056D-02,0.2310D-02,0.2594D-02,0.2914D-02,
     &0.3274D-02,0.3677D-02,0.4131D-02,0.4640D-02,0.5212D-02,0.5855D-02,
     &0.6577D-02,0.7388D-02,0.8299D-02,0.9323D-02,0.1047D-01,0.1176D-01,
     &0.1321D-01,0.1484D-01,0.1667D-01,0.1873D-01,0.2104D-01,0.2363D-01,
     &0.2655D-01,0.2982D-01,0.3350D-01,0.3763D-01,0.4227D-01,0.4748D-01,
     &0.5334D-01,0.5992D-01,0.6731D-01,0.7560D-01,0.8493D-01,0.9540D-01,
     &0.1072D+00,0.1204D+00,0.1352D+00,0.1519D+00,0.1706D+00,0.1917D+00,
     &0.2153D+00,0.2419D+00,0.2717D+00,0.3052D+00,0.3428D+00,0.3851D+00,
     &0.4326D+00,0.4859D+00,0.5458D+00,0.6131D+00,0.6887D+00,0.7737D+00,
     &0.7837D+00,0.7937D+00,0.8037D+00,0.8137D+00,0.8237D+00,0.8337D+00,
     &0.8437D+00,0.8537D+00,0.8637D+00,0.8737D+00,0.8837D+00,0.8937D+00,
     &0.9037D+00,0.9137D+00,0.9237D+00,0.9337D+00,0.9437D+00,0.9537D+00,
     &0.9637D+00,0.9737D+00,0.9837D+00,0.9937D+00/
C...place for DATA blocks
      DATA (XPV(I,1,0),I=1,100)/
     &0.1565D+01,0.1506D+01,0.1448D+01,0.1391D+01,0.1338D+01,0.1286D+01,
     &0.1236D+01,0.1189D+01,0.1143D+01,0.1098D+01,0.1056D+01,0.1015D+01,
     &0.9745D+00,0.9371D+00,0.9004D+00,0.8646D+00,0.8312D+00,0.7984D+00,
     &0.7665D+00,0.7365D+00,0.7073D+00,0.6785D+00,0.6518D+00,0.6254D+00,
     &0.5998D+00,0.5756D+00,0.5519D+00,0.5287D+00,0.5068D+00,0.4854D+00,
     &0.4644D+00,0.4443D+00,0.4249D+00,0.4058D+00,0.3872D+00,0.3694D+00,
     &0.3519D+00,0.3348D+00,0.3181D+00,0.3020D+00,0.2861D+00,0.2705D+00,
     &0.2553D+00,0.2413D+00,0.2263D+00,0.2118D+00,0.1980D+00,0.1843D+00,
     &0.1706D+00,0.1573D+00,0.1442D+00,0.1315D+00,0.1190D+00,0.1070D+00,
     &0.9501D-01,0.8376D-01,0.7302D-01,0.6278D-01,0.5319D-01,0.4429D-01,
     &0.3613D-01,0.2884D-01,0.2246D-01,0.1692D-01,0.1231D-01,0.8569D-02,
     &0.5692D-02,0.3556D-02,0.2071D-02,0.1106D-02,0.5306D-03,0.2221D-03,
     &0.7821D-04,0.2192D-04,0.4488D-05,0.5808D-06,0.3699D-07,0.6624D-09,
     &0.3750D-09,0.2067D-09,0.1106D-09,0.5732D-10,0.2868D-10,0.1378D-10,
     &0.6286D-11,0.2737D-11,0.1123D-11,0.4323D-12,0.1545D-12,0.5043D-13,
     &0.1478D-13,0.3800D-14,0.8317D-15,0.1485D-15,0.2036D-16,0.1950D-17,
     &0.1118D-18,0.2870D-20,0.1704D-22,0.0000D+00/
      DATA (XPV(I,1,1),I=1,100)/
     &0.2916D-06,0.3304D-06,0.3747D-06,0.4246D-06,0.4815D-06,0.5462D-06,
     &0.6192D-06,0.7024D-06,0.7966D-06,0.9039D-06,0.1025D-05,0.1163D-05,
     &0.1321D-05,0.1499D-05,0.1701D-05,0.1932D-05,0.2193D-05,0.2490D-05,
     &0.2828D-05,0.3212D-05,0.3647D-05,0.4146D-05,0.4707D-05,0.5351D-05,
     &0.6077D-05,0.6906D-05,0.7851D-05,0.8925D-05,0.1014D-04,0.1153D-04,
     &0.1311D-04,0.1490D-04,0.1695D-04,0.1927D-04,0.2191D-04,0.2492D-04,
     &0.2834D-04,0.3223D-04,0.3666D-04,0.4169D-04,0.4740D-04,0.5389D-04,
     &0.6128D-04,0.6966D-04,0.7921D-04,0.9006D-04,0.1023D-03,0.1163D-03,
     &0.1321D-03,0.1500D-03,0.1703D-03,0.1933D-03,0.2192D-03,0.2485D-03,
     &0.2817D-03,0.3190D-03,0.3609D-03,0.4080D-03,0.4608D-03,0.5198D-03,
     &0.5859D-03,0.6591D-03,0.7400D-03,0.8298D-03,0.9282D-03,0.1036D-02,
     &0.1153D-02,0.1280D-02,0.1415D-02,0.1558D-02,0.1706D-02,0.1859D-02,
     &0.2011D-02,0.2158D-02,0.2291D-02,0.2397D-02,0.2457D-02,0.2434D-02,
     &0.2424D-02,0.2411D-02,0.2397D-02,0.2381D-02,0.2362D-02,0.2341D-02,
     &0.2317D-02,0.2291D-02,0.2262D-02,0.2230D-02,0.2194D-02,0.2154D-02,
     &0.2110D-02,0.2060D-02,0.2006D-02,0.1944D-02,0.1874D-02,0.1795D-02,
     &0.1702D-02,0.1592D-02,0.1567D-02,0.9891D-03/
      DATA (XPV(I,1,2),I=1,100)/
     &0.1611D-06,0.1839D-06,0.2101D-06,0.2397D-06,0.2738D-06,0.3129D-06,
     &0.3572D-06,0.4081D-06,0.4661D-06,0.5325D-06,0.6084D-06,0.6950D-06,
     &0.7944D-06,0.9077D-06,0.1037D-05,0.1186D-05,0.1355D-05,0.1550D-05,
     &0.1771D-05,0.2025D-05,0.2315D-05,0.2649D-05,0.3027D-05,0.3464D-05,
     &0.3959D-05,0.4528D-05,0.5180D-05,0.5926D-05,0.6776D-05,0.7751D-05,
     &0.8869D-05,0.1014D-04,0.1161D-04,0.1328D-04,0.1519D-04,0.1738D-04,
     &0.1988D-04,0.2274D-04,0.2602D-04,0.2976D-04,0.3404D-04,0.3893D-04,
     &0.4452D-04,0.5090D-04,0.5821D-04,0.6657D-04,0.7608D-04,0.8693D-04,
     &0.9936D-04,0.1135D-03,0.1296D-03,0.1479D-03,0.1688D-03,0.1925D-03,
     &0.2195D-03,0.2501D-03,0.2847D-03,0.3239D-03,0.3682D-03,0.4180D-03,
     &0.4743D-03,0.5371D-03,0.6071D-03,0.6855D-03,0.7721D-03,0.8679D-03,
     &0.9724D-03,0.1086D-02,0.1208D-02,0.1338D-02,0.1472D-02,0.1609D-02,
     &0.1742D-02,0.1864D-02,0.1962D-02,0.2019D-02,0.2006D-02,0.1875D-02,
     &0.1850D-02,0.1823D-02,0.1794D-02,0.1762D-02,0.1728D-02,0.1691D-02,
     &0.1651D-02,0.1609D-02,0.1563D-02,0.1514D-02,0.1462D-02,0.1405D-02,
     &0.1345D-02,0.1280D-02,0.1209D-02,0.1133D-02,0.1051D-02,0.9598D-03,
     &0.8591D-03,0.7454D-03,0.6438D-03,0.3654D-03/
      DATA (XPV(I,1,3),I=1,100)/
     &0.3274D-03,0.3407D-03,0.3547D-03,0.3691D-03,0.3843D-03,0.4000D-03,
     &0.4163D-03,0.4333D-03,0.4510D-03,0.4693D-03,0.4885D-03,0.5084D-03,
     &0.5291D-03,0.5506D-03,0.5730D-03,0.5963D-03,0.6205D-03,0.6456D-03,
     &0.6717D-03,0.6989D-03,0.7270D-03,0.7564D-03,0.7866D-03,0.8183D-03,
     &0.8507D-03,0.8847D-03,0.9198D-03,0.9561D-03,0.9936D-03,0.1032D-02,
     &0.1073D-02,0.1114D-02,0.1157D-02,0.1200D-02,0.1245D-02,0.1292D-02,
     &0.1339D-02,0.1387D-02,0.1436D-02,0.1486D-02,0.1537D-02,0.1588D-02,
     &0.1639D-02,0.1693D-02,0.1742D-02,0.1792D-02,0.1842D-02,0.1889D-02,
     &0.1933D-02,0.1974D-02,0.2011D-02,0.2043D-02,0.2070D-02,0.2090D-02,
     &0.2098D-02,0.2100D-02,0.2091D-02,0.2069D-02,0.2034D-02,0.1984D-02,
     &0.1918D-02,0.1835D-02,0.1738D-02,0.1621D-02,0.1490D-02,0.1344D-02,
     &0.1189D-02,0.1026D-02,0.8614D-03,0.7006D-03,0.5505D-03,0.4173D-03,
     &0.3076D-03,0.2258D-03,0.1743D-03,0.1526D-03,0.1584D-03,0.1876D-03,
     &0.1921D-03,0.1968D-03,0.2016D-03,0.2066D-03,0.2117D-03,0.2169D-03,
     &0.2222D-03,0.2276D-03,0.2331D-03,0.2385D-03,0.2441D-03,0.2495D-03,
     &0.2550D-03,0.2603D-03,0.2654D-03,0.2702D-03,0.2746D-03,0.2783D-03,
     &0.2811D-03,0.2822D-03,0.3078D-03,0.2079D-03/
      DATA (XPV(I,1,4),I=1,100)/
     &0.1280D-03,0.1332D-03,0.1387D-03,0.1444D-03,0.1503D-03,0.1565D-03,
     &0.1629D-03,0.1696D-03,0.1765D-03,0.1837D-03,0.1913D-03,0.1991D-03,
     &0.2072D-03,0.2157D-03,0.2245D-03,0.2337D-03,0.2433D-03,0.2532D-03,
     &0.2636D-03,0.2743D-03,0.2855D-03,0.2971D-03,0.3092D-03,0.3218D-03,
     &0.3347D-03,0.3483D-03,0.3624D-03,0.3770D-03,0.3920D-03,0.4077D-03,
     &0.4239D-03,0.4407D-03,0.4581D-03,0.4759D-03,0.4944D-03,0.5134D-03,
     &0.5330D-03,0.5531D-03,0.5736D-03,0.5947D-03,0.6162D-03,0.6379D-03,
     &0.6601D-03,0.6836D-03,0.7055D-03,0.7279D-03,0.7508D-03,0.7728D-03,
     &0.7940D-03,0.8146D-03,0.8342D-03,0.8524D-03,0.8689D-03,0.8834D-03,
     &0.8941D-03,0.9028D-03,0.9080D-03,0.9090D-03,0.9056D-03,0.8971D-03,
     &0.8831D-03,0.8635D-03,0.8385D-03,0.8068D-03,0.7698D-03,0.7276D-03,
     &0.6819D-03,0.6336D-03,0.5849D-03,0.5382D-03,0.4968D-03,0.4641D-03,
     &0.4444D-03,0.4423D-03,0.4636D-03,0.5150D-03,0.6053D-03,0.7458D-03,
     &0.7649D-03,0.7844D-03,0.8043D-03,0.8247D-03,0.8455D-03,0.8667D-03,
     &0.8883D-03,0.9100D-03,0.9320D-03,0.9540D-03,0.9761D-03,0.9981D-03,
     &0.1020D-02,0.1041D-02,0.1062D-02,0.1081D-02,0.1098D-02,0.1113D-02,
     &0.1124D-02,0.1129D-02,0.1231D-02,0.8316D-03/
      DATA (XPV(I,2,0),I=1,100)/
     &0.2212D+01,0.2119D+01,0.2028D+01,0.1939D+01,0.1857D+01,0.1776D+01,
     &0.1698D+01,0.1624D+01,0.1553D+01,0.1484D+01,0.1419D+01,0.1356D+01,
     &0.1294D+01,0.1237D+01,0.1181D+01,0.1127D+01,0.1076D+01,0.1027D+01,
     &0.9785D+00,0.9336D+00,0.8899D+00,0.8471D+00,0.8075D+00,0.7686D+00,
     &0.7310D+00,0.6957D+00,0.6613D+00,0.6278D+00,0.5965D+00,0.5661D+00,
     &0.5364D+00,0.5083D+00,0.4813D+00,0.4551D+00,0.4298D+00,0.4058D+00,
     &0.3825D+00,0.3599D+00,0.3382D+00,0.3174D+00,0.2974D+00,0.2780D+00,
     &0.2592D+00,0.2421D+00,0.2243D+00,0.2074D+00,0.1915D+00,0.1760D+00,
     &0.1608D+00,0.1463D+00,0.1324D+00,0.1192D+00,0.1064D+00,0.9439D-01,
     &0.8268D-01,0.7190D-01,0.6185D-01,0.5247D-01,0.4390D-01,0.3611D-01,
     &0.2914D-01,0.2306D-01,0.1786D-01,0.1344D-01,0.9848D-02,0.7000D-02,
     &0.4846D-02,0.3270D-02,0.2179D-02,0.1460D-02,0.1009D-02,0.7343D-03,
     &0.5643D-03,0.4488D-03,0.3576D-03,0.2761D-03,0.1995D-03,0.1267D-03,
     &0.1190D-03,0.1115D-03,0.1041D-03,0.9690D-04,0.8988D-04,0.8302D-04,
     &0.7627D-04,0.6975D-04,0.6340D-04,0.5723D-04,0.5123D-04,0.4542D-04,
     &0.3981D-04,0.3439D-04,0.2918D-04,0.2419D-04,0.1944D-04,0.1495D-04,
     &0.1075D-04,0.6861D-05,0.3406D-05,0.5274D-06/
      DATA (XPV(I,2,1),I=1,100)/
     &0.1934D-01,0.1855D-01,0.1777D-01,0.1701D-01,0.1631D-01,0.1562D-01,
     &0.1494D-01,0.1432D-01,0.1370D-01,0.1310D-01,0.1254D-01,0.1200D-01,
     &0.1146D-01,0.1097D-01,0.1048D-01,0.1000D-01,0.9557D-02,0.9122D-02,
     &0.8698D-02,0.8300D-02,0.7912D-02,0.7530D-02,0.7176D-02,0.6826D-02,
     &0.6487D-02,0.6168D-02,0.5856D-02,0.5551D-02,0.5264D-02,0.4985D-02,
     &0.4712D-02,0.4451D-02,0.4202D-02,0.3959D-02,0.3723D-02,0.3500D-02,
     &0.3284D-02,0.3075D-02,0.2874D-02,0.2684D-02,0.2502D-02,0.2326D-02,
     &0.2160D-02,0.2010D-02,0.1857D-02,0.1716D-02,0.1588D-02,0.1467D-02,
     &0.1354D-02,0.1252D-02,0.1160D-02,0.1080D-02,0.1011D-02,0.9547D-03,
     &0.9083D-03,0.8767D-03,0.8586D-03,0.8538D-03,0.8634D-03,0.8871D-03,
     &0.9256D-03,0.9785D-03,0.1046D-02,0.1127D-02,0.1222D-02,0.1329D-02,
     &0.1448D-02,0.1578D-02,0.1715D-02,0.1859D-02,0.2008D-02,0.2158D-02,
     &0.2307D-02,0.2450D-02,0.2584D-02,0.2700D-02,0.2788D-02,0.2821D-02,
     &0.2820D-02,0.2817D-02,0.2812D-02,0.2806D-02,0.2798D-02,0.2788D-02,
     &0.2776D-02,0.2762D-02,0.2745D-02,0.2725D-02,0.2702D-02,0.2676D-02,
     &0.2645D-02,0.2609D-02,0.2568D-02,0.2519D-02,0.2461D-02,0.2392D-02,
     &0.2304D-02,0.2214D-02,0.2038D-02,0.1660D-02/
      DATA (XPV(I,2,2),I=1,100)/
     &0.1934D-01,0.1855D-01,0.1777D-01,0.1701D-01,0.1631D-01,0.1562D-01,
     &0.1494D-01,0.1431D-01,0.1370D-01,0.1310D-01,0.1254D-01,0.1200D-01,
     &0.1146D-01,0.1096D-01,0.1048D-01,0.1000D-01,0.9555D-02,0.9120D-02,
     &0.8695D-02,0.8297D-02,0.7909D-02,0.7526D-02,0.7172D-02,0.6822D-02,
     &0.6483D-02,0.6162D-02,0.5850D-02,0.5544D-02,0.5256D-02,0.4976D-02,
     &0.4702D-02,0.4441D-02,0.4190D-02,0.3945D-02,0.3708D-02,0.3483D-02,
     &0.3266D-02,0.3054D-02,0.2851D-02,0.2659D-02,0.2473D-02,0.2295D-02,
     &0.2124D-02,0.1970D-02,0.1813D-02,0.1667D-02,0.1533D-02,0.1406D-02,
     &0.1286D-02,0.1177D-02,0.1077D-02,0.9879D-03,0.9093D-03,0.8417D-03,
     &0.7835D-03,0.7391D-03,0.7071D-03,0.6872D-03,0.6807D-03,0.6873D-03,
     &0.7074D-03,0.7409D-03,0.7879D-03,0.8480D-03,0.9206D-03,0.1005D-02,
     &0.1101D-02,0.1206D-02,0.1319D-02,0.1437D-02,0.1558D-02,0.1676D-02,
     &0.1786D-02,0.1880D-02,0.1947D-02,0.1969D-02,0.1924D-02,0.1773D-02,
     &0.1748D-02,0.1721D-02,0.1691D-02,0.1660D-02,0.1627D-02,0.1592D-02,
     &0.1555D-02,0.1515D-02,0.1473D-02,0.1429D-02,0.1382D-02,0.1332D-02,
     &0.1279D-02,0.1222D-02,0.1162D-02,0.1098D-02,0.1028D-02,0.9527D-03,
     &0.8688D-03,0.7804D-03,0.6649D-03,0.4897D-03/
      DATA (XPV(I,2,3),I=1,100)/
     &0.1968D-01,0.1890D-01,0.1814D-01,0.1740D-01,0.1671D-01,0.1604D-01,
     &0.1538D-01,0.1477D-01,0.1418D-01,0.1359D-01,0.1305D-01,0.1253D-01,
     &0.1202D-01,0.1154D-01,0.1108D-01,0.1062D-01,0.1020D-01,0.9794D-02,
     &0.9396D-02,0.9025D-02,0.8666D-02,0.8313D-02,0.7989D-02,0.7671D-02,
     &0.7364D-02,0.7078D-02,0.6800D-02,0.6530D-02,0.6279D-02,0.6037D-02,
     &0.5802D-02,0.5581D-02,0.5371D-02,0.5168D-02,0.4973D-02,0.4791D-02,
     &0.4616D-02,0.4448D-02,0.4290D-02,0.4140D-02,0.3998D-02,0.3862D-02,
     &0.3733D-02,0.3622D-02,0.3502D-02,0.3391D-02,0.3291D-02,0.3192D-02,
     &0.3095D-02,0.3004D-02,0.2916D-02,0.2830D-02,0.2745D-02,0.2662D-02,
     &0.2572D-02,0.2486D-02,0.2397D-02,0.2302D-02,0.2203D-02,0.2098D-02,
     &0.1984D-02,0.1863D-02,0.1735D-02,0.1597D-02,0.1451D-02,0.1298D-02,
     &0.1142D-02,0.9853D-03,0.8318D-03,0.6865D-03,0.5549D-03,0.4424D-03,
     &0.3541D-03,0.2939D-03,0.2636D-03,0.2636D-03,0.2924D-03,0.3480D-03,
     &0.3556D-03,0.3634D-03,0.3713D-03,0.3793D-03,0.3875D-03,0.3956D-03,
     &0.4039D-03,0.4120D-03,0.4203D-03,0.4282D-03,0.4362D-03,0.4438D-03,
     &0.4511D-03,0.4579D-03,0.4641D-03,0.4694D-03,0.4735D-03,0.4760D-03,
     &0.4749D-03,0.4752D-03,0.4578D-03,0.3923D-03/
      DATA (XPV(I,2,4),I=1,100)/
     &0.1947D-01,0.1869D-01,0.1792D-01,0.1717D-01,0.1646D-01,0.1578D-01,
     &0.1511D-01,0.1449D-01,0.1389D-01,0.1329D-01,0.1274D-01,0.1220D-01,
     &0.1168D-01,0.1119D-01,0.1071D-01,0.1024D-01,0.9809D-02,0.9384D-02,
     &0.8970D-02,0.8582D-02,0.8205D-02,0.7835D-02,0.7492D-02,0.7155D-02,
     &0.6828D-02,0.6521D-02,0.6223D-02,0.5931D-02,0.5657D-02,0.5393D-02,
     &0.5134D-02,0.4889D-02,0.4653D-02,0.4425D-02,0.4205D-02,0.3997D-02,
     &0.3796D-02,0.3602D-02,0.3416D-02,0.3241D-02,0.3072D-02,0.2910D-02,
     &0.2755D-02,0.2618D-02,0.2475D-02,0.2342D-02,0.2220D-02,0.2103D-02,
     &0.1991D-02,0.1887D-02,0.1789D-02,0.1699D-02,0.1614D-02,0.1536D-02,
     &0.1460D-02,0.1393D-02,0.1331D-02,0.1273D-02,0.1220D-02,0.1169D-02,
     &0.1122D-02,0.1077D-02,0.1035D-02,0.9924D-03,0.9517D-03,0.9118D-03,
     &0.8737D-03,0.8375D-03,0.8050D-03,0.7782D-03,0.7598D-03,0.7539D-03,
     &0.7655D-03,0.8012D-03,0.8696D-03,0.9820D-03,0.1152D-02,0.1396D-02,
     &0.1427D-02,0.1459D-02,0.1492D-02,0.1525D-02,0.1558D-02,0.1592D-02,
     &0.1625D-02,0.1659D-02,0.1692D-02,0.1724D-02,0.1757D-02,0.1787D-02,
     &0.1817D-02,0.1845D-02,0.1869D-02,0.1891D-02,0.1907D-02,0.1915D-02,
     &0.1910D-02,0.1909D-02,0.1831D-02,0.1563D-02/
      DATA (XPV(I,3,0),I=1,100)/
     &0.3308D+01,0.3150D+01,0.2995D+01,0.2845D+01,0.2706D+01,0.2570D+01,
     &0.2439D+01,0.2318D+01,0.2200D+01,0.2086D+01,0.1980D+01,0.1877D+01,
     &0.1778D+01,0.1685D+01,0.1596D+01,0.1510D+01,0.1429D+01,0.1352D+01,
     &0.1277D+01,0.1207D+01,0.1140D+01,0.1074D+01,0.1014D+01,0.9560D+00,
     &0.8999D+00,0.8477D+00,0.7974D+00,0.7487D+00,0.7036D+00,0.6603D+00,
     &0.6186D+00,0.5793D+00,0.5421D+00,0.5064D+00,0.4722D+00,0.4403D+00,
     &0.4097D+00,0.3805D+00,0.3528D+00,0.3267D+00,0.3020D+00,0.2783D+00,
     &0.2558D+00,0.2356D+00,0.2151D+00,0.1960D+00,0.1783D+00,0.1614D+00,
     &0.1452D+00,0.1302D+00,0.1160D+00,0.1028D+00,0.9044D-01,0.7901D-01,
     &0.6820D-01,0.5850D-01,0.4968D-01,0.4167D-01,0.3454D-01,0.2823D-01,
     &0.2273D-01,0.1806D-01,0.1416D-01,0.1093D-01,0.8342D-02,0.6321D-02,
     &0.4798D-02,0.3669D-02,0.2855D-02,0.2271D-02,0.1847D-02,0.1524D-02,
     &0.1262D-02,0.1035D-02,0.8272D-03,0.6323D-03,0.4496D-03,0.2797D-03,
     &0.2619D-03,0.2446D-03,0.2277D-03,0.2113D-03,0.1953D-03,0.1798D-03,
     &0.1645D-03,0.1498D-03,0.1356D-03,0.1218D-03,0.1085D-03,0.9565D-04,
     &0.8330D-04,0.7145D-04,0.6013D-04,0.4938D-04,0.3923D-04,0.2974D-04,
     &0.2099D-04,0.1303D-04,0.6225D-05,0.9782D-06/
      DATA (XPV(I,3,1),I=1,100)/
     &0.5631D-01,0.5377D-01,0.5129D-01,0.4888D-01,0.4664D-01,0.4445D-01,
     &0.4233D-01,0.4035D-01,0.3843D-01,0.3656D-01,0.3482D-01,0.3313D-01,
     &0.3148D-01,0.2994D-01,0.2845D-01,0.2700D-01,0.2565D-01,0.2434D-01,
     &0.2307D-01,0.2188D-01,0.2072D-01,0.1960D-01,0.1855D-01,0.1753D-01,
     &0.1655D-01,0.1563D-01,0.1474D-01,0.1387D-01,0.1306D-01,0.1227D-01,
     &0.1151D-01,0.1080D-01,0.1011D-01,0.9451D-02,0.8816D-02,0.8220D-02,
     &0.7648D-02,0.7097D-02,0.6576D-02,0.6084D-02,0.5618D-02,0.5172D-02,
     &0.4750D-02,0.4374D-02,0.3996D-02,0.3647D-02,0.3330D-02,0.3034D-02,
     &0.2756D-02,0.2506D-02,0.2281D-02,0.2081D-02,0.1906D-02,0.1756D-02,
     &0.1627D-02,0.1527D-02,0.1453D-02,0.1402D-02,0.1377D-02,0.1376D-02,
     &0.1398D-02,0.1442D-02,0.1507D-02,0.1591D-02,0.1692D-02,0.1808D-02,
     &0.1936D-02,0.2075D-02,0.2220D-02,0.2370D-02,0.2522D-02,0.2675D-02,
     &0.2827D-02,0.2977D-02,0.3127D-02,0.3276D-02,0.3425D-02,0.3559D-02,
     &0.3572D-02,0.3583D-02,0.3593D-02,0.3601D-02,0.3608D-02,0.3613D-02,
     &0.3616D-02,0.3616D-02,0.3614D-02,0.3609D-02,0.3600D-02,0.3586D-02,
     &0.3568D-02,0.3542D-02,0.3510D-02,0.3467D-02,0.3412D-02,0.3340D-02,
     &0.3240D-02,0.3140D-02,0.2881D-02,0.2260D-02/
      DATA (XPV(I,3,2),I=1,100)/
     &0.5631D-01,0.5377D-01,0.5129D-01,0.4888D-01,0.4664D-01,0.4445D-01,
     &0.4233D-01,0.4035D-01,0.3843D-01,0.3656D-01,0.3481D-01,0.3312D-01,
     &0.3147D-01,0.2994D-01,0.2845D-01,0.2700D-01,0.2565D-01,0.2433D-01,
     &0.2306D-01,0.2187D-01,0.2072D-01,0.1959D-01,0.1855D-01,0.1752D-01,
     &0.1654D-01,0.1562D-01,0.1472D-01,0.1385D-01,0.1304D-01,0.1226D-01,
     &0.1149D-01,0.1077D-01,0.1009D-01,0.9422D-02,0.8784D-02,0.8185D-02,
     &0.7608D-02,0.7054D-02,0.6527D-02,0.6030D-02,0.5558D-02,0.5105D-02,
     &0.4676D-02,0.4292D-02,0.3905D-02,0.3547D-02,0.3219D-02,0.2910D-02,
     &0.2620D-02,0.2356D-02,0.2115D-02,0.1897D-02,0.1703D-02,0.1533D-02,
     &0.1382D-02,0.1258D-02,0.1158D-02,0.1080D-02,0.1025D-02,0.9926D-03,
     &0.9811D-03,0.9900D-03,0.1018D-02,0.1064D-02,0.1125D-02,0.1200D-02,
     &0.1286D-02,0.1381D-02,0.1481D-02,0.1583D-02,0.1683D-02,0.1776D-02,
     &0.1857D-02,0.1917D-02,0.1949D-02,0.1938D-02,0.1870D-02,0.1718D-02,
     &0.1695D-02,0.1670D-02,0.1644D-02,0.1617D-02,0.1589D-02,0.1559D-02,
     &0.1527D-02,0.1494D-02,0.1459D-02,0.1423D-02,0.1385D-02,0.1344D-02,
     &0.1302D-02,0.1256D-02,0.1208D-02,0.1157D-02,0.1101D-02,0.1040D-02,
     &0.9712D-03,0.9017D-03,0.7902D-03,0.5856D-03/
      DATA (XPV(I,3,3),I=1,100)/
     &0.5668D-01,0.5415D-01,0.5169D-01,0.4930D-01,0.4707D-01,0.4490D-01,
     &0.4280D-01,0.4084D-01,0.3894D-01,0.3708D-01,0.3536D-01,0.3369D-01,
     &0.3207D-01,0.3056D-01,0.2909D-01,0.2766D-01,0.2634D-01,0.2505D-01,
     &0.2381D-01,0.2264D-01,0.2152D-01,0.2042D-01,0.1941D-01,0.1842D-01,
     &0.1747D-01,0.1658D-01,0.1572D-01,0.1489D-01,0.1411D-01,0.1337D-01,
     &0.1264D-01,0.1196D-01,0.1131D-01,0.1069D-01,0.1009D-01,0.9533D-02,
     &0.8998D-02,0.8483D-02,0.7997D-02,0.7540D-02,0.7105D-02,0.6689D-02,
     &0.6295D-02,0.5947D-02,0.5588D-02,0.5256D-02,0.4952D-02,0.4661D-02,
     &0.4382D-02,0.4123D-02,0.3879D-02,0.3650D-02,0.3434D-02,0.3232D-02,
     &0.3033D-02,0.2850D-02,0.2676D-02,0.2508D-02,0.2345D-02,0.2186D-02,
     &0.2029D-02,0.1875D-02,0.1723D-02,0.1569D-02,0.1416D-02,0.1264D-02,
     &0.1115D-02,0.9718D-03,0.8371D-03,0.7147D-03,0.6091D-03,0.5242D-03,
     &0.4643D-03,0.4324D-03,0.4307D-03,0.4600D-03,0.5208D-03,0.6116D-03,
     &0.6232D-03,0.6348D-03,0.6465D-03,0.6582D-03,0.6698D-03,0.6813D-03,
     &0.6927D-03,0.7037D-03,0.7145D-03,0.7247D-03,0.7344D-03,0.7433D-03,
     &0.7512D-03,0.7579D-03,0.7629D-03,0.7658D-03,0.7660D-03,0.7620D-03,
     &0.7516D-03,0.7414D-03,0.6912D-03,0.5511D-03/
      DATA (XPV(I,3,4),I=1,100)/
     &0.5645D-01,0.5392D-01,0.5144D-01,0.4905D-01,0.4681D-01,0.4462D-01,
     &0.4251D-01,0.4054D-01,0.3863D-01,0.3676D-01,0.3503D-01,0.3335D-01,
     &0.3171D-01,0.3018D-01,0.2870D-01,0.2726D-01,0.2592D-01,0.2462D-01,
     &0.2335D-01,0.2217D-01,0.2103D-01,0.1992D-01,0.1889D-01,0.1788D-01,
     &0.1691D-01,0.1600D-01,0.1512D-01,0.1426D-01,0.1347D-01,0.1270D-01,
     &0.1195D-01,0.1125D-01,0.1058D-01,0.9929D-02,0.9308D-02,0.8726D-02,
     &0.8167D-02,0.7630D-02,0.7121D-02,0.6641D-02,0.6185D-02,0.5749D-02,
     &0.5336D-02,0.4968D-02,0.4595D-02,0.4249D-02,0.3933D-02,0.3635D-02,
     &0.3352D-02,0.3093D-02,0.2854D-02,0.2635D-02,0.2436D-02,0.2256D-02,
     &0.2089D-02,0.1945D-02,0.1818D-02,0.1706D-02,0.1610D-02,0.1528D-02,
     &0.1458D-02,0.1400D-02,0.1353D-02,0.1314D-02,0.1283D-02,0.1259D-02,
     &0.1242D-02,0.1231D-02,0.1228D-02,0.1235D-02,0.1254D-02,0.1291D-02,
     &0.1351D-02,0.1446D-02,0.1586D-02,0.1789D-02,0.2074D-02,0.2452D-02,
     &0.2500D-02,0.2547D-02,0.2594D-02,0.2642D-02,0.2689D-02,0.2735D-02,
     &0.2781D-02,0.2826D-02,0.2869D-02,0.2910D-02,0.2950D-02,0.2985D-02,
     &0.3017D-02,0.3044D-02,0.3065D-02,0.3076D-02,0.3077D-02,0.3062D-02,
     &0.3020D-02,0.2980D-02,0.2782D-02,0.2225D-02/
      DATA (XPV(I,4,0),I=1,100)/
     &0.3752D+01,0.3563D+01,0.3380D+01,0.3204D+01,0.3040D+01,0.2881D+01,
     &0.2728D+01,0.2585D+01,0.2448D+01,0.2314D+01,0.2191D+01,0.2072D+01,
     &0.1957D+01,0.1850D+01,0.1747D+01,0.1648D+01,0.1556D+01,0.1467D+01,
     &0.1381D+01,0.1302D+01,0.1226D+01,0.1152D+01,0.1084D+01,0.1018D+01,
     &0.9554D+00,0.8969D+00,0.8408D+00,0.7867D+00,0.7367D+00,0.6889D+00,
     &0.6429D+00,0.5998D+00,0.5591D+00,0.5202D+00,0.4832D+00,0.4487D+00,
     &0.4159D+00,0.3845D+00,0.3551D+00,0.3274D+00,0.3013D+00,0.2764D+00,
     &0.2529D+00,0.2319D+00,0.2108D+00,0.1912D+00,0.1731D+00,0.1560D+00,
     &0.1397D+00,0.1246D+00,0.1106D+00,0.9755D-01,0.8546D-01,0.7436D-01,
     &0.6395D-01,0.5468D-01,0.4632D-01,0.3879D-01,0.3214D-01,0.2631D-01,
     &0.2126D-01,0.1701D-01,0.1348D-01,0.1056D-01,0.8234D-02,0.6412D-02,
     &0.5029D-02,0.3987D-02,0.3214D-02,0.2636D-02,0.2192D-02,0.1833D-02,
     &0.1527D-02,0.1252D-02,0.9989D-03,0.7610D-03,0.5388D-03,0.3334D-03,
     &0.3120D-03,0.2911D-03,0.2708D-03,0.2511D-03,0.2319D-03,0.2132D-03,
     &0.1950D-03,0.1774D-03,0.1603D-03,0.1439D-03,0.1280D-03,0.1127D-03,
     &0.9795D-04,0.8387D-04,0.7044D-04,0.5771D-04,0.4573D-04,0.3455D-04,
     &0.2427D-04,0.1497D-04,0.7094D-05,0.1118D-05/
      DATA (XPV(I,4,1),I=1,100)/
     &0.7267D-01,0.6928D-01,0.6597D-01,0.6277D-01,0.5978D-01,0.5687D-01,
     &0.5406D-01,0.5144D-01,0.4890D-01,0.4643D-01,0.4414D-01,0.4191D-01,
     &0.3975D-01,0.3774D-01,0.3579D-01,0.3389D-01,0.3213D-01,0.3042D-01,
     &0.2877D-01,0.2723D-01,0.2574D-01,0.2428D-01,0.2294D-01,0.2163D-01,
     &0.2037D-01,0.1919D-01,0.1805D-01,0.1695D-01,0.1592D-01,0.1493D-01,
     &0.1397D-01,0.1306D-01,0.1220D-01,0.1138D-01,0.1059D-01,0.9845D-02,
     &0.9136D-02,0.8456D-02,0.7814D-02,0.7210D-02,0.6639D-02,0.6096D-02,
     &0.5583D-02,0.5128D-02,0.4672D-02,0.4253D-02,0.3873D-02,0.3519D-02,
     &0.3189D-02,0.2893D-02,0.2627D-02,0.2391D-02,0.2185D-02,0.2009D-02,
     &0.1858D-02,0.1741D-02,0.1654D-02,0.1594D-02,0.1563D-02,0.1558D-02,
     &0.1580D-02,0.1625D-02,0.1693D-02,0.1781D-02,0.1887D-02,0.2008D-02,
     &0.2141D-02,0.2284D-02,0.2434D-02,0.2587D-02,0.2742D-02,0.2898D-02,
     &0.3053D-02,0.3209D-02,0.3370D-02,0.3537D-02,0.3715D-02,0.3891D-02,
     &0.3909D-02,0.3925D-02,0.3940D-02,0.3954D-02,0.3967D-02,0.3977D-02,
     &0.3985D-02,0.3990D-02,0.3993D-02,0.3992D-02,0.3987D-02,0.3977D-02,
     &0.3961D-02,0.3938D-02,0.3907D-02,0.3863D-02,0.3806D-02,0.3729D-02,
     &0.3619D-02,0.3510D-02,0.3213D-02,0.2499D-02/
      DATA (XPV(I,4,2),I=1,100)/
     &0.7267D-01,0.6928D-01,0.6597D-01,0.6277D-01,0.5978D-01,0.5687D-01,
     &0.5406D-01,0.5144D-01,0.4890D-01,0.4643D-01,0.4413D-01,0.4191D-01,
     &0.3974D-01,0.3773D-01,0.3578D-01,0.3389D-01,0.3213D-01,0.3042D-01,
     &0.2876D-01,0.2722D-01,0.2573D-01,0.2427D-01,0.2293D-01,0.2162D-01,
     &0.2035D-01,0.1917D-01,0.1803D-01,0.1693D-01,0.1590D-01,0.1490D-01,
     &0.1394D-01,0.1303D-01,0.1217D-01,0.1134D-01,0.1055D-01,0.9801D-02,
     &0.9086D-02,0.8401D-02,0.7753D-02,0.7143D-02,0.6564D-02,0.6013D-02,
     &0.5492D-02,0.5026D-02,0.4559D-02,0.4128D-02,0.3735D-02,0.3366D-02,
     &0.3020D-02,0.2707D-02,0.2422D-02,0.2165D-02,0.1936D-02,0.1736D-02,
     &0.1559D-02,0.1413D-02,0.1295D-02,0.1202D-02,0.1135D-02,0.1092D-02,
     &0.1073D-02,0.1077D-02,0.1101D-02,0.1143D-02,0.1201D-02,0.1274D-02,
     &0.1357D-02,0.1448D-02,0.1543D-02,0.1639D-02,0.1732D-02,0.1817D-02,
     &0.1888D-02,0.1938D-02,0.1960D-02,0.1941D-02,0.1870D-02,0.1725D-02,
     &0.1703D-02,0.1680D-02,0.1656D-02,0.1631D-02,0.1604D-02,0.1577D-02,
     &0.1548D-02,0.1517D-02,0.1485D-02,0.1452D-02,0.1417D-02,0.1380D-02,
     &0.1341D-02,0.1299D-02,0.1255D-02,0.1207D-02,0.1156D-02,0.1098D-02,
     &0.1033D-02,0.9674D-03,0.8541D-03,0.6354D-03/
      DATA (XPV(I,4,3),I=1,100)/
     &0.7305D-01,0.6967D-01,0.6638D-01,0.6319D-01,0.6022D-01,0.5733D-01,
     &0.5454D-01,0.5194D-01,0.4942D-01,0.4697D-01,0.4470D-01,0.4249D-01,
     &0.4035D-01,0.3836D-01,0.3644D-01,0.3457D-01,0.3283D-01,0.3115D-01,
     &0.2952D-01,0.2801D-01,0.2655D-01,0.2512D-01,0.2381D-01,0.2253D-01,
     &0.2130D-01,0.2016D-01,0.1905D-01,0.1798D-01,0.1698D-01,0.1603D-01,
     &0.1511D-01,0.1424D-01,0.1341D-01,0.1262D-01,0.1187D-01,0.1116D-01,
     &0.1049D-01,0.9841D-02,0.9231D-02,0.8659D-02,0.8117D-02,0.7599D-02,
     &0.7111D-02,0.6679D-02,0.6237D-02,0.5829D-02,0.5456D-02,0.5100D-02,
     &0.4761D-02,0.4448D-02,0.4155D-02,0.3882D-02,0.3626D-02,0.3388D-02,
     &0.3157D-02,0.2947D-02,0.2749D-02,0.2560D-02,0.2381D-02,0.2208D-02,
     &0.2041D-02,0.1879D-02,0.1722D-02,0.1566D-02,0.1413D-02,0.1263D-02,
     &0.1119D-02,0.9814D-03,0.8540D-03,0.7401D-03,0.6436D-03,0.5684D-03,
     &0.5183D-03,0.4963D-03,0.5046D-03,0.5445D-03,0.6168D-03,0.7197D-03,
     &0.7326D-03,0.7455D-03,0.7585D-03,0.7712D-03,0.7840D-03,0.7964D-03,
     &0.8087D-03,0.8205D-03,0.8319D-03,0.8426D-03,0.8525D-03,0.8614D-03,
     &0.8691D-03,0.8752D-03,0.8793D-03,0.8807D-03,0.8787D-03,0.8717D-03,
     &0.8570D-03,0.8420D-03,0.7795D-03,0.6128D-03/
      DATA (XPV(I,4,4),I=1,100)/
     &0.7282D-01,0.6943D-01,0.6613D-01,0.6293D-01,0.5995D-01,0.5705D-01,
     &0.5425D-01,0.5164D-01,0.4911D-01,0.4664D-01,0.4436D-01,0.4214D-01,
     &0.3998D-01,0.3798D-01,0.3604D-01,0.3416D-01,0.3240D-01,0.3071D-01,
     &0.2906D-01,0.2753D-01,0.2605D-01,0.2461D-01,0.2328D-01,0.2198D-01,
     &0.2073D-01,0.1957D-01,0.1844D-01,0.1735D-01,0.1633D-01,0.1535D-01,
     &0.1441D-01,0.1352D-01,0.1267D-01,0.1186D-01,0.1108D-01,0.1035D-01,
     &0.9656D-02,0.8988D-02,0.8358D-02,0.7765D-02,0.7204D-02,0.6669D-02,
     &0.6164D-02,0.5715D-02,0.5262D-02,0.4844D-02,0.4464D-02,0.4105D-02,
     &0.3767D-02,0.3460D-02,0.3177D-02,0.2920D-02,0.2687D-02,0.2479D-02,
     &0.2287D-02,0.2123D-02,0.1980D-02,0.1856D-02,0.1752D-02,0.1664D-02,
     &0.1592D-02,0.1534D-02,0.1490D-02,0.1456D-02,0.1432D-02,0.1417D-02,
     &0.1410D-02,0.1411D-02,0.1420D-02,0.1440D-02,0.1475D-02,0.1528D-02,
     &0.1609D-02,0.1726D-02,0.1895D-02,0.2133D-02,0.2459D-02,0.2886D-02,
     &0.2938D-02,0.2991D-02,0.3043D-02,0.3095D-02,0.3146D-02,0.3196D-02,
     &0.3246D-02,0.3294D-02,0.3340D-02,0.3382D-02,0.3423D-02,0.3458D-02,
     &0.3490D-02,0.3514D-02,0.3531D-02,0.3537D-02,0.3529D-02,0.3502D-02,
     &0.3443D-02,0.3384D-02,0.3138D-02,0.2476D-02/
      DATA (XPV(I,5,0),I=1,100)/
     &0.5090D+01,0.4807D+01,0.4532D+01,0.4269D+01,0.4025D+01,0.3790D+01,
     &0.3565D+01,0.3357D+01,0.3158D+01,0.2966D+01,0.2789D+01,0.2619D+01,
     &0.2456D+01,0.2306D+01,0.2162D+01,0.2024D+01,0.1896D+01,0.1775D+01,
     &0.1658D+01,0.1551D+01,0.1449D+01,0.1350D+01,0.1260D+01,0.1174D+01,
     &0.1092D+01,0.1017D+01,0.9446D+00,0.8759D+00,0.8129D+00,0.7532D+00,
     &0.6963D+00,0.6436D+00,0.5942D+00,0.5475D+00,0.5035D+00,0.4630D+00,
     &0.4248D+00,0.3887D+00,0.3552D+00,0.3241D+00,0.2952D+00,0.2679D+00,
     &0.2425D+00,0.2201D+00,0.1979D+00,0.1776D+00,0.1591D+00,0.1419D+00,
     &0.1258D+00,0.1112D+00,0.9780D-01,0.8557D-01,0.7444D-01,0.6440D-01,
     &0.5515D-01,0.4707D-01,0.3992D-01,0.3359D-01,0.2809D-01,0.2335D-01,
     &0.1929D-01,0.1591D-01,0.1311D-01,0.1080D-01,0.8928D-02,0.7425D-02,
     &0.6231D-02,0.5269D-02,0.4486D-02,0.3833D-02,0.3270D-02,0.2770D-02,
     &0.2314D-02,0.1893D-02,0.1501D-02,0.1135D-02,0.7972D-03,0.4881D-03,
     &0.4561D-03,0.4250D-03,0.3947D-03,0.3653D-03,0.3368D-03,0.3092D-03,
     &0.2821D-03,0.2562D-03,0.2311D-03,0.2068D-03,0.1835D-03,0.1611D-03,
     &0.1396D-03,0.1192D-03,0.9970D-04,0.8133D-04,0.6411D-04,0.4814D-04,
     &0.3357D-04,0.2049D-04,0.9589D-05,0.1523D-05/
      DATA (XPV(I,5,1),I=1,100)/
     &0.1266D+00,0.1201D+00,0.1139D+00,0.1078D+00,0.1022D+00,0.9680D-01,
     &0.9156D-01,0.8670D-01,0.8201D-01,0.7747D-01,0.7327D-01,0.6921D-01,
     &0.6529D-01,0.6166D-01,0.5816D-01,0.5478D-01,0.5165D-01,0.4863D-01,
     &0.4572D-01,0.4302D-01,0.4044D-01,0.3792D-01,0.3561D-01,0.3338D-01,
     &0.3124D-01,0.2925D-01,0.2735D-01,0.2551D-01,0.2381D-01,0.2218D-01,
     &0.2062D-01,0.1916D-01,0.1779D-01,0.1647D-01,0.1522D-01,0.1406D-01,
     &0.1296D-01,0.1192D-01,0.1094D-01,0.1003D-01,0.9174D-02,0.8369D-02,
     &0.7616D-02,0.6954D-02,0.6299D-02,0.5702D-02,0.5167D-02,0.4674D-02,
     &0.4219D-02,0.3817D-02,0.3459D-02,0.3147D-02,0.2878D-02,0.2651D-02,
     &0.2460D-02,0.2315D-02,0.2210D-02,0.2140D-02,0.2107D-02,0.2106D-02,
     &0.2137D-02,0.2196D-02,0.2281D-02,0.2387D-02,0.2512D-02,0.2652D-02,
     &0.2804D-02,0.2964D-02,0.3128D-02,0.3295D-02,0.3463D-02,0.3634D-02,
     &0.3808D-02,0.3993D-02,0.4196D-02,0.4430D-02,0.4706D-02,0.5014D-02,
     &0.5048D-02,0.5080D-02,0.5111D-02,0.5140D-02,0.5168D-02,0.5193D-02,
     &0.5215D-02,0.5233D-02,0.5248D-02,0.5257D-02,0.5261D-02,0.5258D-02,
     &0.5247D-02,0.5225D-02,0.5191D-02,0.5140D-02,0.5069D-02,0.4968D-02,
     &0.4823D-02,0.4671D-02,0.4254D-02,0.3263D-02/
      DATA (XPV(I,5,2),I=1,100)/
     &0.1266D+00,0.1201D+00,0.1139D+00,0.1078D+00,0.1022D+00,0.9679D-01,
     &0.9156D-01,0.8670D-01,0.8201D-01,0.7747D-01,0.7326D-01,0.6921D-01,
     &0.6528D-01,0.6166D-01,0.5815D-01,0.5477D-01,0.5164D-01,0.4862D-01,
     &0.4571D-01,0.4301D-01,0.4042D-01,0.3790D-01,0.3559D-01,0.3335D-01,
     &0.3121D-01,0.2922D-01,0.2731D-01,0.2547D-01,0.2377D-01,0.2214D-01,
     &0.2058D-01,0.1911D-01,0.1773D-01,0.1641D-01,0.1515D-01,0.1399D-01,
     &0.1288D-01,0.1182D-01,0.1083D-01,0.9913D-02,0.9047D-02,0.8227D-02,
     &0.7461D-02,0.6782D-02,0.6109D-02,0.5493D-02,0.4936D-02,0.4419D-02,
     &0.3940D-02,0.3509D-02,0.3121D-02,0.2776D-02,0.2470D-02,0.2205D-02,
     &0.1972D-02,0.1782D-02,0.1628D-02,0.1507D-02,0.1418D-02,0.1359D-02,
     &0.1328D-02,0.1323D-02,0.1340D-02,0.1377D-02,0.1429D-02,0.1495D-02,
     &0.1570D-02,0.1651D-02,0.1733D-02,0.1813D-02,0.1887D-02,0.1950D-02,
     &0.1998D-02,0.2025D-02,0.2028D-02,0.2000D-02,0.1934D-02,0.1821D-02,
     &0.1805D-02,0.1788D-02,0.1770D-02,0.1751D-02,0.1732D-02,0.1712D-02,
     &0.1691D-02,0.1668D-02,0.1645D-02,0.1620D-02,0.1594D-02,0.1566D-02,
     &0.1536D-02,0.1503D-02,0.1467D-02,0.1428D-02,0.1384D-02,0.1333D-02,
     &0.1271D-02,0.1209D-02,0.1082D-02,0.8147D-03/
      DATA (XPV(I,5,3),I=1,100)/
     &0.1270D+00,0.1206D+00,0.1143D+00,0.1083D+00,0.1027D+00,0.9728D-01,
     &0.9207D-01,0.8723D-01,0.8256D-01,0.7804D-01,0.7386D-01,0.6983D-01,
     &0.6593D-01,0.6233D-01,0.5885D-01,0.5549D-01,0.5239D-01,0.4939D-01,
     &0.4651D-01,0.4384D-01,0.4128D-01,0.3880D-01,0.3652D-01,0.3431D-01,
     &0.3221D-01,0.3025D-01,0.2838D-01,0.2657D-01,0.2490D-01,0.2331D-01,
     &0.2178D-01,0.2036D-01,0.1901D-01,0.1773D-01,0.1651D-01,0.1538D-01,
     &0.1431D-01,0.1329D-01,0.1233D-01,0.1144D-01,0.1061D-01,0.9815D-02,
     &0.9073D-02,0.8419D-02,0.7762D-02,0.7159D-02,0.6612D-02,0.6098D-02,
     &0.5612D-02,0.5170D-02,0.4761D-02,0.4384D-02,0.4038D-02,0.3721D-02,
     &0.3420D-02,0.3151D-02,0.2904D-02,0.2675D-02,0.2463D-02,0.2266D-02,
     &0.2081D-02,0.1908D-02,0.1746D-02,0.1589D-02,0.1442D-02,0.1302D-02,
     &0.1172D-02,0.1053D-02,0.9463D-03,0.8557D-03,0.7842D-03,0.7348D-03,
     &0.7109D-03,0.7155D-03,0.7513D-03,0.8206D-03,0.9250D-03,0.1061D-02,
     &0.1078D-02,0.1094D-02,0.1110D-02,0.1126D-02,0.1141D-02,0.1156D-02,
     &0.1170D-02,0.1183D-02,0.1196D-02,0.1207D-02,0.1217D-02,0.1225D-02,
     &0.1231D-02,0.1235D-02,0.1235D-02,0.1231D-02,0.1222D-02,0.1205D-02,
     &0.1177D-02,0.1147D-02,0.1049D-02,0.8076D-03/
      DATA (XPV(I,5,4),I=1,100)/
     &0.1268D+00,0.1203D+00,0.1141D+00,0.1080D+00,0.1024D+00,0.9699D-01,
     &0.9176D-01,0.8691D-01,0.8223D-01,0.7769D-01,0.7350D-01,0.6945D-01,
     &0.6554D-01,0.6192D-01,0.5843D-01,0.5506D-01,0.5194D-01,0.4893D-01,
     &0.4603D-01,0.4334D-01,0.4077D-01,0.3826D-01,0.3597D-01,0.3374D-01,
     &0.3162D-01,0.2964D-01,0.2775D-01,0.2592D-01,0.2423D-01,0.2262D-01,
     &0.2108D-01,0.1963D-01,0.1826D-01,0.1696D-01,0.1572D-01,0.1457D-01,
     &0.1348D-01,0.1245D-01,0.1148D-01,0.1058D-01,0.9728D-02,0.8927D-02,
     &0.8178D-02,0.7517D-02,0.6860D-02,0.6260D-02,0.5718D-02,0.5215D-02,
     &0.4746D-02,0.4325D-02,0.3945D-02,0.3604D-02,0.3300D-02,0.3034D-02,
     &0.2794D-02,0.2595D-02,0.2428D-02,0.2288D-02,0.2176D-02,0.2089D-02,
     &0.2024D-02,0.1980D-02,0.1955D-02,0.1945D-02,0.1948D-02,0.1963D-02,
     &0.1990D-02,0.2028D-02,0.2077D-02,0.2140D-02,0.2220D-02,0.2326D-02,
     &0.2465D-02,0.2653D-02,0.2905D-02,0.3246D-02,0.3695D-02,0.4254D-02,
     &0.4321D-02,0.4386D-02,0.4451D-02,0.4514D-02,0.4577D-02,0.4636D-02,
     &0.4694D-02,0.4748D-02,0.4799D-02,0.4844D-02,0.4884D-02,0.4917D-02,
     &0.4943D-02,0.4957D-02,0.4959D-02,0.4943D-02,0.4907D-02,0.4841D-02,
     &0.4729D-02,0.4609D-02,0.4221D-02,0.3255D-02/
      DATA (XPV(I,6,0),I=1,100)/
     &0.6237D+01,0.5864D+01,0.5504D+01,0.5161D+01,0.4844D+01,0.4540D+01,
     &0.4250D+01,0.3983D+01,0.3728D+01,0.3484D+01,0.3260D+01,0.3047D+01,
     &0.2842D+01,0.2655D+01,0.2476D+01,0.2305D+01,0.2149D+01,0.2000D+01,
     &0.1859D+01,0.1729D+01,0.1606D+01,0.1488D+01,0.1381D+01,0.1279D+01,
     &0.1183D+01,0.1094D+01,0.1011D+01,0.9315D+00,0.8593D+00,0.7912D+00,
     &0.7268D+00,0.6675D+00,0.6124D+00,0.5606D+00,0.5121D+00,0.4678D+00,
     &0.4264D+00,0.3876D+00,0.3518D+00,0.3190D+00,0.2886D+00,0.2603D+00,
     &0.2341D+00,0.2112D+00,0.1888D+00,0.1684D+00,0.1501D+00,0.1333D+00,
     &0.1177D+00,0.1036D+00,0.9087D-01,0.7939D-01,0.6905D-01,0.5982D-01,
     &0.5142D-01,0.4414D-01,0.3777D-01,0.3217D-01,0.2734D-01,0.2318D-01,
     &0.1963D-01,0.1666D-01,0.1417D-01,0.1208D-01,0.1035D-01,0.8900D-02,
     &0.7693D-02,0.6662D-02,0.5773D-02,0.4987D-02,0.4279D-02,0.3629D-02,
     &0.3029D-02,0.2471D-02,0.1953D-02,0.1472D-02,0.1029D-02,0.6270D-03,
     &0.5855D-03,0.5451D-03,0.5059D-03,0.4679D-03,0.4310D-03,0.3953D-03,
     &0.3604D-03,0.3269D-03,0.2945D-03,0.2634D-03,0.2334D-03,0.2046D-03,
     &0.1771D-03,0.1509D-03,0.1260D-03,0.1026D-03,0.8070D-04,0.6045D-04,
     &0.4202D-04,0.2555D-04,0.1191D-04,0.1897D-05/
      DATA (XPV(I,6,1),I=1,100)/
     &0.1781D+00,0.1684D+00,0.1591D+00,0.1501D+00,0.1418D+00,0.1337D+00,
     &0.1260D+00,0.1189D+00,0.1120D+00,0.1054D+00,0.9931D-01,0.9344D-01,
     &0.8779D-01,0.8258D-01,0.7757D-01,0.7276D-01,0.6832D-01,0.6405D-01,
     &0.5996D-01,0.5619D-01,0.5258D-01,0.4909D-01,0.4591D-01,0.4283D-01,
     &0.3990D-01,0.3720D-01,0.3462D-01,0.3214D-01,0.2986D-01,0.2770D-01,
     &0.2563D-01,0.2370D-01,0.2190D-01,0.2019D-01,0.1857D-01,0.1708D-01,
     &0.1567D-01,0.1434D-01,0.1310D-01,0.1196D-01,0.1090D-01,0.9901D-02,
     &0.8978D-02,0.8170D-02,0.7379D-02,0.6665D-02,0.6029D-02,0.5448D-02,
     &0.4919D-02,0.4455D-02,0.4047D-02,0.3695D-02,0.3396D-02,0.3149D-02,
     &0.2945D-02,0.2795D-02,0.2690D-02,0.2626D-02,0.2604D-02,0.2618D-02,
     &0.2666D-02,0.2744D-02,0.2850D-02,0.2977D-02,0.3122D-02,0.3283D-02,
     &0.3453D-02,0.3631D-02,0.3813D-02,0.3996D-02,0.4182D-02,0.4372D-02,
     &0.4572D-02,0.4792D-02,0.5045D-02,0.5351D-02,0.5725D-02,0.6156D-02,
     &0.6204D-02,0.6250D-02,0.6295D-02,0.6337D-02,0.6377D-02,0.6413D-02,
     &0.6446D-02,0.6474D-02,0.6498D-02,0.6514D-02,0.6523D-02,0.6523D-02,
     &0.6513D-02,0.6488D-02,0.6447D-02,0.6385D-02,0.6296D-02,0.6169D-02,
     &0.5986D-02,0.5790D-02,0.5259D-02,0.4013D-02/
      DATA (XPV(I,6,2),I=1,100)/
     &0.1781D+00,0.1684D+00,0.1591D+00,0.1501D+00,0.1418D+00,0.1337D+00,
     &0.1260D+00,0.1189D+00,0.1120D+00,0.1054D+00,0.9930D-01,0.9343D-01,
     &0.8778D-01,0.8257D-01,0.7756D-01,0.7274D-01,0.6830D-01,0.6403D-01,
     &0.5994D-01,0.5617D-01,0.5255D-01,0.4906D-01,0.4587D-01,0.4280D-01,
     &0.3987D-01,0.3716D-01,0.3457D-01,0.3209D-01,0.2981D-01,0.2764D-01,
     &0.2556D-01,0.2363D-01,0.2181D-01,0.2009D-01,0.1846D-01,0.1696D-01,
     &0.1554D-01,0.1420D-01,0.1295D-01,0.1179D-01,0.1071D-01,0.9697D-02,
     &0.8753D-02,0.7923D-02,0.7107D-02,0.6365D-02,0.5699D-02,0.5086D-02,
     &0.4521D-02,0.4018D-02,0.3569D-02,0.3171D-02,0.2823D-02,0.2522D-02,
     &0.2261D-02,0.2049D-02,0.1878D-02,0.1744D-02,0.1647D-02,0.1582D-02,
     &0.1547D-02,0.1538D-02,0.1553D-02,0.1587D-02,0.1636D-02,0.1697D-02,
     &0.1765D-02,0.1837D-02,0.1909D-02,0.1977D-02,0.2038D-02,0.2086D-02,
     &0.2120D-02,0.2137D-02,0.2134D-02,0.2109D-02,0.2062D-02,0.1987D-02,
     &0.1976D-02,0.1965D-02,0.1953D-02,0.1941D-02,0.1928D-02,0.1914D-02,
     &0.1899D-02,0.1884D-02,0.1867D-02,0.1848D-02,0.1828D-02,0.1806D-02,
     &0.1782D-02,0.1754D-02,0.1723D-02,0.1688D-02,0.1646D-02,0.1596D-02,
     &0.1533D-02,0.1467D-02,0.1321D-02,0.9997D-03/
      DATA (XPV(I,6,3),I=1,100)/
     &0.1785D+00,0.1689D+00,0.1595D+00,0.1506D+00,0.1423D+00,0.1342D+00,
     &0.1266D+00,0.1194D+00,0.1126D+00,0.1060D+00,0.9992D-01,0.9408D-01,
     &0.8845D-01,0.8327D-01,0.7828D-01,0.7350D-01,0.6908D-01,0.6484D-01,
     &0.6078D-01,0.5703D-01,0.5345D-01,0.4999D-01,0.4684D-01,0.4379D-01,
     &0.4090D-01,0.3822D-01,0.3567D-01,0.3322D-01,0.3097D-01,0.2884D-01,
     &0.2680D-01,0.2490D-01,0.2312D-01,0.2144D-01,0.1984D-01,0.1837D-01,
     &0.1699D-01,0.1567D-01,0.1445D-01,0.1332D-01,0.1227D-01,0.1128D-01,
     &0.1035D-01,0.9539D-02,0.8732D-02,0.7995D-02,0.7330D-02,0.6710D-02,
     &0.6131D-02,0.5606D-02,0.5125D-02,0.4686D-02,0.4286D-02,0.3924D-02,
     &0.3584D-02,0.3285D-02,0.3013D-02,0.2764D-02,0.2538D-02,0.2330D-02,
     &0.2139D-02,0.1964D-02,0.1804D-02,0.1652D-02,0.1512D-02,0.1383D-02,
     &0.1266D-02,0.1162D-02,0.1073D-02,0.1000D-02,0.9475D-03,0.9178D-03,
     &0.9140D-03,0.9394D-03,0.9971D-03,0.1091D-02,0.1222D-02,0.1386D-02,
     &0.1405D-02,0.1424D-02,0.1442D-02,0.1460D-02,0.1477D-02,0.1494D-02,
     &0.1510D-02,0.1524D-02,0.1537D-02,0.1549D-02,0.1558D-02,0.1565D-02,
     &0.1570D-02,0.1571D-02,0.1567D-02,0.1558D-02,0.1542D-02,0.1516D-02,
     &0.1476D-02,0.1432D-02,0.1303D-02,0.9967D-03/
      DATA (XPV(I,6,4),I=1,100)/
     &0.1783D+00,0.1686D+00,0.1592D+00,0.1503D+00,0.1420D+00,0.1339D+00,
     &0.1262D+00,0.1191D+00,0.1122D+00,0.1056D+00,0.9955D-01,0.9369D-01,
     &0.8805D-01,0.8285D-01,0.7785D-01,0.7305D-01,0.6862D-01,0.6436D-01,
     &0.6028D-01,0.5652D-01,0.5292D-01,0.4944D-01,0.4627D-01,0.4321D-01,
     &0.4029D-01,0.3760D-01,0.3503D-01,0.3256D-01,0.3030D-01,0.2814D-01,
     &0.2609D-01,0.2417D-01,0.2238D-01,0.2068D-01,0.1907D-01,0.1759D-01,
     &0.1619D-01,0.1486D-01,0.1363D-01,0.1250D-01,0.1144D-01,0.1044D-01,
     &0.9519D-02,0.8711D-02,0.7914D-02,0.7191D-02,0.6544D-02,0.5949D-02,
     &0.5400D-02,0.4912D-02,0.4476D-02,0.4091D-02,0.3753D-02,0.3461D-02,
     &0.3203D-02,0.2994D-02,0.2824D-02,0.2687D-02,0.2583D-02,0.2509D-02,
     &0.2462D-02,0.2439D-02,0.2438D-02,0.2455D-02,0.2487D-02,0.2534D-02,
     &0.2594D-02,0.2666D-02,0.2752D-02,0.2854D-02,0.2977D-02,0.3129D-02,
     &0.3321D-02,0.3571D-02,0.3898D-02,0.4329D-02,0.4884D-02,0.5555D-02,
     &0.5632D-02,0.5708D-02,0.5783D-02,0.5856D-02,0.5926D-02,0.5993D-02,
     &0.6056D-02,0.6115D-02,0.6168D-02,0.6214D-02,0.6254D-02,0.6283D-02,
     &0.6301D-02,0.6305D-02,0.6291D-02,0.6256D-02,0.6193D-02,0.6090D-02,
     &0.5930D-02,0.5755D-02,0.5242D-02,0.4010D-02/
      DATA (XPV(I,7,0),I=1,100)/
     &0.7226D+01,0.6770D+01,0.6333D+01,0.5916D+01,0.5533D+01,0.5167D+01,
     &0.4820D+01,0.4501D+01,0.4197D+01,0.3907D+01,0.3643D+01,0.3391D+01,
     &0.3151D+01,0.2932D+01,0.2724D+01,0.2526D+01,0.2345D+01,0.2174D+01,
     &0.2012D+01,0.1864D+01,0.1724D+01,0.1590D+01,0.1470D+01,0.1356D+01,
     &0.1248D+01,0.1150D+01,0.1057D+01,0.9701D+00,0.8910D+00,0.8168D+00,
     &0.7469D+00,0.6829D+00,0.6237D+00,0.5684D+00,0.5169D+00,0.4702D+00,
     &0.4266D+00,0.3861D+00,0.3490D+00,0.3152D+00,0.2841D+00,0.2552D+00,
     &0.2287D+00,0.2056D+00,0.1833D+00,0.1631D+00,0.1451D+00,0.1286D+00,
     &0.1134D+00,0.9989D-01,0.8770D-01,0.7678D-01,0.6701D-01,0.5835D-01,
     &0.5051D-01,0.4375D-01,0.3785D-01,0.3267D-01,0.2821D-01,0.2435D-01,
     &0.2104D-01,0.1823D-01,0.1585D-01,0.1380D-01,0.1205D-01,0.1054D-01,
     &0.9237D-02,0.8080D-02,0.7048D-02,0.6110D-02,0.5249D-02,0.4452D-02,
     &0.3711D-02,0.3023D-02,0.2385D-02,0.1794D-02,0.1252D-02,0.7601D-03,
     &0.7095D-03,0.6603D-03,0.6126D-03,0.5662D-03,0.5213D-03,0.4779D-03,
     &0.4354D-03,0.3948D-03,0.3555D-03,0.3177D-03,0.2813D-03,0.2465D-03,
     &0.2131D-03,0.1814D-03,0.1514D-03,0.1231D-03,0.9674D-04,0.7237D-04,
     &0.5023D-04,0.3050D-04,0.1418D-04,0.2263D-05/
      DATA (XPV(I,7,1),I=1,100)/
     &0.2263D+00,0.2134D+00,0.2010D+00,0.1891D+00,0.1781D+00,0.1675D+00,
     &0.1573D+00,0.1480D+00,0.1390D+00,0.1304D+00,0.1225D+00,0.1149D+00,
     &0.1076D+00,0.1009D+00,0.9446D-01,0.8830D-01,0.8265D-01,0.7723D-01,
     &0.7206D-01,0.6730D-01,0.6277D-01,0.5840D-01,0.5443D-01,0.5061D-01,
     &0.4699D-01,0.4365D-01,0.4048D-01,0.3745D-01,0.3468D-01,0.3205D-01,
     &0.2955D-01,0.2724D-01,0.2508D-01,0.2304D-01,0.2112D-01,0.1936D-01,
     &0.1771D-01,0.1615D-01,0.1472D-01,0.1340D-01,0.1217D-01,0.1103D-01,
     &0.9985D-02,0.9072D-02,0.8184D-02,0.7387D-02,0.6683D-02,0.6045D-02,
     &0.5467D-02,0.4966D-02,0.4530D-02,0.4157D-02,0.3846D-02,0.3593D-02,
     &0.3387D-02,0.3241D-02,0.3146D-02,0.3095D-02,0.3088D-02,0.3119D-02,
     &0.3187D-02,0.3286D-02,0.3412D-02,0.3561D-02,0.3727D-02,0.3908D-02,
     &0.4098D-02,0.4295D-02,0.4495D-02,0.4698D-02,0.4903D-02,0.5117D-02,
     &0.5346D-02,0.5605D-02,0.5913D-02,0.6292D-02,0.6763D-02,0.7310D-02,
     &0.7371D-02,0.7430D-02,0.7487D-02,0.7541D-02,0.7592D-02,0.7638D-02,
     &0.7681D-02,0.7717D-02,0.7747D-02,0.7769D-02,0.7783D-02,0.7784D-02,
     &0.7772D-02,0.7743D-02,0.7695D-02,0.7620D-02,0.7512D-02,0.7358D-02,
     &0.7137D-02,0.6896D-02,0.6255D-02,0.4763D-02/
      DATA (XPV(I,7,2),I=1,100)/
     &0.2263D+00,0.2134D+00,0.2010D+00,0.1891D+00,0.1780D+00,0.1675D+00,
     &0.1573D+00,0.1480D+00,0.1390D+00,0.1304D+00,0.1225D+00,0.1149D+00,
     &0.1076D+00,0.1009D+00,0.9444D-01,0.8828D-01,0.8263D-01,0.7721D-01,
     &0.7203D-01,0.6727D-01,0.6273D-01,0.5836D-01,0.5439D-01,0.5056D-01,
     &0.4694D-01,0.4360D-01,0.4042D-01,0.3738D-01,0.3460D-01,0.3197D-01,
     &0.2946D-01,0.2714D-01,0.2497D-01,0.2291D-01,0.2098D-01,0.1921D-01,
     &0.1754D-01,0.1597D-01,0.1451D-01,0.1317D-01,0.1193D-01,0.1076D-01,
     &0.9687D-02,0.8745D-02,0.7825D-02,0.6993D-02,0.6250D-02,0.5570D-02,
     &0.4947D-02,0.4395D-02,0.3905D-02,0.3475D-02,0.3100D-02,0.2779D-02,
     &0.2500D-02,0.2276D-02,0.2097D-02,0.1957D-02,0.1856D-02,0.1789D-02,
     &0.1752D-02,0.1742D-02,0.1755D-02,0.1786D-02,0.1832D-02,0.1888D-02,
     &0.1951D-02,0.2017D-02,0.2081D-02,0.2140D-02,0.2190D-02,0.2230D-02,
     &0.2256D-02,0.2268D-02,0.2266D-02,0.2252D-02,0.2228D-02,0.2192D-02,
     &0.2187D-02,0.2181D-02,0.2175D-02,0.2168D-02,0.2160D-02,0.2152D-02,
     &0.2143D-02,0.2132D-02,0.2120D-02,0.2107D-02,0.2091D-02,0.2074D-02,
     &0.2053D-02,0.2029D-02,0.2000D-02,0.1966D-02,0.1924D-02,0.1872D-02,
     &0.1804D-02,0.1733D-02,0.1564D-02,0.1186D-02/
      DATA (XPV(I,7,3),I=1,100)/
     &0.2267D+00,0.2139D+00,0.2014D+00,0.1896D+00,0.1786D+00,0.1680D+00,
     &0.1579D+00,0.1485D+00,0.1396D+00,0.1310D+00,0.1231D+00,0.1155D+00,
     &0.1083D+00,0.1016D+00,0.9519D-01,0.8906D-01,0.8343D-01,0.7804D-01,
     &0.7290D-01,0.6817D-01,0.6366D-01,0.5932D-01,0.5538D-01,0.5158D-01,
     &0.4799D-01,0.4469D-01,0.4154D-01,0.3854D-01,0.3579D-01,0.3319D-01,
     &0.3072D-01,0.2843D-01,0.2629D-01,0.2427D-01,0.2237D-01,0.2063D-01,
     &0.1899D-01,0.1745D-01,0.1602D-01,0.1470D-01,0.1348D-01,0.1233D-01,
     &0.1127D-01,0.1034D-01,0.9420D-02,0.8586D-02,0.7837D-02,0.7144D-02,
     &0.6498D-02,0.5917D-02,0.5388D-02,0.4909D-02,0.4474D-02,0.4084D-02,
     &0.3720D-02,0.3402D-02,0.3116D-02,0.2856D-02,0.2623D-02,0.2412D-02,
     &0.2219D-02,0.2045D-02,0.1888D-02,0.1743D-02,0.1611D-02,0.1491D-02,
     &0.1385D-02,0.1294D-02,0.1218D-02,0.1160D-02,0.1123D-02,0.1110D-02,
     &0.1122D-02,0.1165D-02,0.1242D-02,0.1357D-02,0.1512D-02,0.1701D-02,
     &0.1723D-02,0.1744D-02,0.1765D-02,0.1785D-02,0.1804D-02,0.1822D-02,
     &0.1839D-02,0.1854D-02,0.1868D-02,0.1880D-02,0.1889D-02,0.1895D-02,
     &0.1898D-02,0.1896D-02,0.1889D-02,0.1876D-02,0.1853D-02,0.1819D-02,
     &0.1768D-02,0.1711D-02,0.1554D-02,0.1185D-02/
      DATA (XPV(I,7,4),I=1,100)/
     &0.2265D+00,0.2136D+00,0.2012D+00,0.1893D+00,0.1783D+00,0.1677D+00,
     &0.1575D+00,0.1482D+00,0.1392D+00,0.1306D+00,0.1227D+00,0.1151D+00,
     &0.1078D+00,0.1012D+00,0.9474D-01,0.8860D-01,0.8296D-01,0.7755D-01,
     &0.7239D-01,0.6764D-01,0.6312D-01,0.5876D-01,0.5480D-01,0.5099D-01,
     &0.4738D-01,0.4406D-01,0.4090D-01,0.3788D-01,0.3512D-01,0.3250D-01,
     &0.3002D-01,0.2771D-01,0.2556D-01,0.2353D-01,0.2162D-01,0.1987D-01,
     &0.1822D-01,0.1667D-01,0.1524D-01,0.1392D-01,0.1270D-01,0.1156D-01,
     &0.1051D-01,0.9590D-02,0.8693D-02,0.7884D-02,0.7166D-02,0.6509D-02,
     &0.5909D-02,0.5380D-02,0.4911D-02,0.4502D-02,0.4147D-02,0.3845D-02,
     &0.3583D-02,0.3375D-02,0.3211D-02,0.3085D-02,0.2996D-02,0.2940D-02,
     &0.2914D-02,0.2914D-02,0.2939D-02,0.2982D-02,0.3044D-02,0.3121D-02,
     &0.3212D-02,0.3318D-02,0.3438D-02,0.3577D-02,0.3739D-02,0.3934D-02,
     &0.4176D-02,0.4483D-02,0.4880D-02,0.5394D-02,0.6046D-02,0.6819D-02,
     &0.6907D-02,0.6993D-02,0.7077D-02,0.7157D-02,0.7235D-02,0.7308D-02,
     &0.7377D-02,0.7439D-02,0.7495D-02,0.7542D-02,0.7580D-02,0.7605D-02,
     &0.7617D-02,0.7611D-02,0.7584D-02,0.7530D-02,0.7441D-02,0.7306D-02,
     &0.7101D-02,0.6875D-02,0.6245D-02,0.4762D-02/
C..fetching pdfs
      DATA XMIN/1.D-04/,XMAX/1./
      IF ((X.LT.XMIN).OR.(X.GE.XMAX)) THEN
        WRITE(6,*) 'LAC: x outside the range, x= ',X
        RETURN
      ENDIF
      DO  5 IP=0,5
        XPDF(IP)=0.
 5    CONTINUE
      DO 2 I=1,IX
        ENT(I)=LOG10(XT(I))
  2   CONTINUE
      NA(1)=IX
      NA(2)=IQ
      DO 3 I=1,IQ
        ENT(IX+I)=LOG10(Q2T(I))
   3  CONTINUE
      ARG(1)=LOG10(X)
      ARG(2)=LOG10(Q2)
C..VARIOUS FLAVOURS (u-->2,d-->1)
      XPDF(0)=PHFINT(NARG,ARG,NA,ENT,XPV(1,1,0))
      XPDF(1)=PHFINT(NARG,ARG,NA,ENT,XPV(1,1,2))
      XPDF(2)=PHFINT(NARG,ARG,NA,ENT,XPV(1,1,1))
      XPDF(3)=PHFINT(NARG,ARG,NA,ENT,XPV(1,1,3))
      XPDF(4)=PHFINT(NARG,ARG,NA,ENT,XPV(1,1,4))
      RETURN
      END
C-------------------------------------------------------------
      SUBROUTINE PHLAC2(X,Q2,XPDF)
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER(IX=100,IQ=7,NARG=2,NFUN=4)
      DIMENSION XT(IX),Q2T(IQ),ARG(NARG),NA(NARG),ENT(IX+IQ)
      DIMENSION XPV(IX,IQ,0:NFUN),XPDF(0:5)
C...100 x valuse; in (D-4,.77) log spaced (78 points)
C...              in (.78,.995) lineary spaced (22 points)
      DATA Q2T/4.,10.,50.,1.D2,1.D3,1.D4,1.D5/
      DATA  XT/
     &0.1000D-03,0.1123D-03,0.1262D-03,0.1417D-03,0.1592D-03,0.1789D-03,
     &0.2009D-03,0.2257D-03,0.2535D-03,0.2848D-03,0.3199D-03,0.3593D-03,
     &0.4037D-03,0.4534D-03,0.5093D-03,0.5722D-03,0.6427D-03,0.7220D-03,
     &0.8110D-03,0.9110D-03,0.1023D-02,0.1150D-02,0.1291D-02,0.1451D-02,
     &0.1629D-02,0.1830D-02,0.2056D-02,0.2310D-02,0.2594D-02,0.2914D-02,
     &0.3274D-02,0.3677D-02,0.4131D-02,0.4640D-02,0.5212D-02,0.5855D-02,
     &0.6577D-02,0.7388D-02,0.8299D-02,0.9323D-02,0.1047D-01,0.1176D-01,
     &0.1321D-01,0.1484D-01,0.1667D-01,0.1873D-01,0.2104D-01,0.2363D-01,
     &0.2655D-01,0.2982D-01,0.3350D-01,0.3763D-01,0.4227D-01,0.4748D-01,
     &0.5334D-01,0.5992D-01,0.6731D-01,0.7560D-01,0.8493D-01,0.9540D-01,
     &0.1072D+00,0.1204D+00,0.1352D+00,0.1519D+00,0.1706D+00,0.1917D+00,
     &0.2153D+00,0.2419D+00,0.2717D+00,0.3052D+00,0.3428D+00,0.3851D+00,
     &0.4326D+00,0.4859D+00,0.5458D+00,0.6131D+00,0.6887D+00,0.7737D+00,
     &0.7837D+00,0.7937D+00,0.8037D+00,0.8137D+00,0.8237D+00,0.8337D+00,
     &0.8437D+00,0.8537D+00,0.8637D+00,0.8737D+00,0.8837D+00,0.8937D+00,
     &0.9037D+00,0.9137D+00,0.9237D+00,0.9337D+00,0.9437D+00,0.9537D+00,
     &0.9637D+00,0.9737D+00,0.9837D+00,0.9937D+00/
C...place for DATA blocks
      DATA (XPV(I,1,0),I=1,100)/
     &0.2589D+00,0.2589D+00,0.2588D+00,0.2587D+00,0.2587D+00,0.2586D+00,
     &0.2584D+00,0.2584D+00,0.2583D+00,0.2581D+00,0.2580D+00,0.2578D+00,
     &0.2576D+00,0.2574D+00,0.2572D+00,0.2568D+00,0.2566D+00,0.2562D+00,
     &0.2558D+00,0.2554D+00,0.2549D+00,0.2543D+00,0.2537D+00,0.2530D+00,
     &0.2522D+00,0.2514D+00,0.2504D+00,0.2492D+00,0.2480D+00,0.2467D+00,
     &0.2451D+00,0.2433D+00,0.2414D+00,0.2392D+00,0.2368D+00,0.2341D+00,
     &0.2312D+00,0.2278D+00,0.2241D+00,0.2201D+00,0.2157D+00,0.2108D+00,
     &0.2054D+00,0.2001D+00,0.1934D+00,0.1864D+00,0.1791D+00,0.1711D+00,
     &0.1623D+00,0.1531D+00,0.1433D+00,0.1330D+00,0.1223D+00,0.1113D+00,
     &0.9973D-01,0.8835D-01,0.7705D-01,0.6593D-01,0.5527D-01,0.4522D-01,
     &0.3597D-01,0.2775D-01,0.2067D-01,0.1471D-01,0.9973D-02,0.6363D-02,
     &0.3799D-02,0.2083D-02,0.1036D-02,0.4560D-03,0.1731D-03,0.5432D-04,
     &0.1340D-04,0.2403D-05,0.2784D-06,0.1701D-07,0.3872D-09,0.1511D-11,
     &0.6880D-12,0.3018D-12,0.1271D-12,0.5114D-13,0.1959D-13,0.7089D-14,
     &0.2386D-14,0.7514D-15,0.2177D-15,0.5781D-16,0.1392D-16,0.2956D-17,
     &0.5413D-18,0.8284D-19,0.1017D-19,0.9439D-21,0.6099D-22,0.2408D-23,
     &0.4675D-25,0.2960D-27,0.2410D-30,0.0000D+00/
      DATA (XPV(I,1,1),I=1,100)/
     &0.3845D-05,0.4208D-05,0.4608D-05,0.5043D-05,0.5522D-05,0.6047D-05,
     &0.6619D-05,0.7247D-05,0.7934D-05,0.8688D-05,0.9512D-05,0.1041D-04,
     &0.1141D-04,0.1249D-04,0.1367D-04,0.1498D-04,0.1640D-04,0.1796D-04,
     &0.1967D-04,0.2154D-04,0.2359D-04,0.2585D-04,0.2830D-04,0.3102D-04,
     &0.3396D-04,0.3720D-04,0.4076D-04,0.4466D-04,0.4891D-04,0.5358D-04,
     &0.5871D-04,0.6431D-04,0.7047D-04,0.7720D-04,0.8457D-04,0.9266D-04,
     &0.1015D-03,0.1112D-03,0.1219D-03,0.1335D-03,0.1462D-03,0.1602D-03,
     &0.1755D-03,0.1923D-03,0.2106D-03,0.2306D-03,0.2526D-03,0.2766D-03,
     &0.3028D-03,0.3314D-03,0.3627D-03,0.3968D-03,0.4340D-03,0.4744D-03,
     &0.5184D-03,0.5662D-03,0.6182D-03,0.6743D-03,0.7351D-03,0.8007D-03,
     &0.8715D-03,0.9472D-03,0.1028D-02,0.1115D-02,0.1206D-02,0.1303D-02,
     &0.1404D-02,0.1510D-02,0.1619D-02,0.1731D-02,0.1844D-02,0.1957D-02,
     &0.2068D-02,0.2173D-02,0.2271D-02,0.2355D-02,0.2418D-02,0.2443D-02,
     &0.2442D-02,0.2440D-02,0.2437D-02,0.2432D-02,0.2426D-02,0.2419D-02,
     &0.2410D-02,0.2400D-02,0.2387D-02,0.2372D-02,0.2355D-02,0.2335D-02,
     &0.2312D-02,0.2285D-02,0.2253D-02,0.2216D-02,0.2172D-02,0.2119D-02,
     &0.2054D-02,0.1973D-02,0.2027D-02,0.1319D-02/
      DATA (XPV(I,1,2),I=1,100)/
     &0.3745D-05,0.4096D-05,0.4482D-05,0.4901D-05,0.5362D-05,0.5868D-05,
     &0.6418D-05,0.7021D-05,0.7680D-05,0.8403D-05,0.9192D-05,0.1005D-04,
     &0.1100D-04,0.1203D-04,0.1317D-04,0.1440D-04,0.1576D-04,0.1724D-04,
     &0.1886D-04,0.2063D-04,0.2257D-04,0.2471D-04,0.2702D-04,0.2957D-04,
     &0.3233D-04,0.3538D-04,0.3871D-04,0.4236D-04,0.4633D-04,0.5068D-04,
     &0.5546D-04,0.6066D-04,0.6637D-04,0.7260D-04,0.7941D-04,0.8687D-04,
     &0.9503D-04,0.1039D-03,0.1137D-03,0.1243D-03,0.1360D-03,0.1487D-03,
     &0.1626D-03,0.1779D-03,0.1944D-03,0.2126D-03,0.2325D-03,0.2540D-03,
     &0.2776D-03,0.3033D-03,0.3313D-03,0.3619D-03,0.3951D-03,0.4312D-03,
     &0.4704D-03,0.5130D-03,0.5593D-03,0.6092D-03,0.6634D-03,0.7217D-03,
     &0.7848D-03,0.8522D-03,0.9245D-03,0.1002D-02,0.1084D-02,0.1171D-02,
     &0.1262D-02,0.1357D-02,0.1455D-02,0.1555D-02,0.1656D-02,0.1754D-02,
     &0.1847D-02,0.1930D-02,0.1995D-02,0.2033D-02,0.2025D-02,0.1941D-02,
     &0.1924D-02,0.1906D-02,0.1887D-02,0.1865D-02,0.1842D-02,0.1817D-02,
     &0.1789D-02,0.1759D-02,0.1727D-02,0.1692D-02,0.1654D-02,0.1612D-02,
     &0.1566D-02,0.1516D-02,0.1460D-02,0.1399D-02,0.1329D-02,0.1251D-02,
     &0.1159D-02,0.1050D-02,0.9681D-03,0.5785D-03/
      DATA (XPV(I,1,3),I=1,100)/
     &0.3363D-03,0.3490D-03,0.3624D-03,0.3761D-03,0.3904D-03,0.4053D-03,
     &0.4206D-03,0.4367D-03,0.4532D-03,0.4704D-03,0.4882D-03,0.5067D-03,
     &0.5259D-03,0.5458D-03,0.5664D-03,0.5878D-03,0.6100D-03,0.6330D-03,
     &0.6567D-03,0.6814D-03,0.7069D-03,0.7334D-03,0.7606D-03,0.7890D-03,
     &0.8180D-03,0.8483D-03,0.8795D-03,0.9116D-03,0.9447D-03,0.9788D-03,
     &0.1014D-02,0.1050D-02,0.1087D-02,0.1125D-02,0.1164D-02,0.1203D-02,
     &0.1244D-02,0.1284D-02,0.1326D-02,0.1368D-02,0.1410D-02,0.1452D-02,
     &0.1494D-02,0.1538D-02,0.1577D-02,0.1616D-02,0.1655D-02,0.1692D-02,
     &0.1724D-02,0.1754D-02,0.1780D-02,0.1800D-02,0.1816D-02,0.1825D-02,
     &0.1823D-02,0.1815D-02,0.1797D-02,0.1768D-02,0.1727D-02,0.1673D-02,
     &0.1605D-02,0.1524D-02,0.1431D-02,0.1322D-02,0.1203D-02,0.1073D-02,
     &0.9373D-03,0.7978D-03,0.6600D-03,0.5285D-03,0.4089D-03,0.3059D-03,
     &0.2241D-03,0.1662D-03,0.1329D-03,0.1233D-03,0.1354D-03,0.1682D-03,
     &0.1731D-03,0.1782D-03,0.1836D-03,0.1891D-03,0.1949D-03,0.2008D-03,
     &0.2070D-03,0.2134D-03,0.2200D-03,0.2268D-03,0.2339D-03,0.2411D-03,
     &0.2486D-03,0.2563D-03,0.2643D-03,0.2724D-03,0.2808D-03,0.2895D-03,
     &0.2984D-03,0.3075D-03,0.3530D-03,0.2469D-03/
      DATA (XPV(I,1,4),I=1,100)/
     &0.1032D-03,0.1071D-03,0.1112D-03,0.1155D-03,0.1199D-03,0.1245D-03,
     &0.1292D-03,0.1341D-03,0.1392D-03,0.1445D-03,0.1501D-03,0.1558D-03,
     &0.1617D-03,0.1679D-03,0.1743D-03,0.1809D-03,0.1878D-03,0.1949D-03,
     &0.2023D-03,0.2100D-03,0.2179D-03,0.2262D-03,0.2348D-03,0.2437D-03,
     &0.2528D-03,0.2623D-03,0.2721D-03,0.2823D-03,0.2928D-03,0.3036D-03,
     &0.3148D-03,0.3264D-03,0.3383D-03,0.3505D-03,0.3631D-03,0.3760D-03,
     &0.3892D-03,0.4027D-03,0.4165D-03,0.4306D-03,0.4448D-03,0.4592D-03,
     &0.4737D-03,0.4892D-03,0.5033D-03,0.5177D-03,0.5324D-03,0.5463D-03,
     &0.5595D-03,0.5723D-03,0.5841D-03,0.5949D-03,0.6045D-03,0.6125D-03,
     &0.6179D-03,0.6219D-03,0.6234D-03,0.6220D-03,0.6177D-03,0.6100D-03,
     &0.5989D-03,0.5841D-03,0.5662D-03,0.5443D-03,0.5194D-03,0.4919D-03,
     &0.4629D-03,0.4332D-03,0.4045D-03,0.3785D-03,0.3573D-03,0.3434D-03,
     &0.3399D-03,0.3503D-03,0.3796D-03,0.4345D-03,0.5257D-03,0.6703D-03,
     &0.6906D-03,0.7115D-03,0.7333D-03,0.7557D-03,0.7789D-03,0.8029D-03,
     &0.8279D-03,0.8535D-03,0.8800D-03,0.9073D-03,0.9354D-03,0.9645D-03,
     &0.9944D-03,0.1025D-02,0.1057D-02,0.1090D-02,0.1123D-02,0.1158D-02,
     &0.1193D-02,0.1230D-02,0.1412D-02,0.9878D-03/
      DATA (XPV(I,2,0),I=1,100)/
     &0.6395D+00,0.6278D+00,0.6160D+00,0.6041D+00,0.5928D+00,0.5814D+00,
     &0.5700D+00,0.5591D+00,0.5481D+00,0.5371D+00,0.5266D+00,0.5160D+00,
     &0.5053D+00,0.4952D+00,0.4850D+00,0.4747D+00,0.4649D+00,0.4551D+00,
     &0.4451D+00,0.4357D+00,0.4261D+00,0.4164D+00,0.4073D+00,0.3979D+00,
     &0.3886D+00,0.3795D+00,0.3704D+00,0.3612D+00,0.3523D+00,0.3433D+00,
     &0.3342D+00,0.3252D+00,0.3163D+00,0.3072D+00,0.2980D+00,0.2889D+00,
     &0.2796D+00,0.2702D+00,0.2607D+00,0.2511D+00,0.2413D+00,0.2313D+00,
     &0.2212D+00,0.2115D+00,0.2006D+00,0.1898D+00,0.1790D+00,0.1679D+00,
     &0.1563D+00,0.1447D+00,0.1330D+00,0.1213D+00,0.1095D+00,0.9788D-01,
     &0.8613D-01,0.7497D-01,0.6426D-01,0.5408D-01,0.4462D-01,0.3598D-01,
     &0.2826D-01,0.2161D-01,0.1605D-01,0.1149D-01,0.7956D-02,0.5325D-02,
     &0.3488D-02,0.2266D-02,0.1508D-02,0.1060D-02,0.8015D-03,0.6446D-03,
     &0.5352D-03,0.4451D-03,0.3626D-03,0.2837D-03,0.2078D-03,0.1348D-03,
     &0.1269D-03,0.1193D-03,0.1117D-03,0.1043D-03,0.9709D-04,0.9000D-04,
     &0.8299D-04,0.7618D-04,0.6953D-04,0.6302D-04,0.5666D-04,0.5047D-04,
     &0.4444D-04,0.3859D-04,0.3291D-04,0.2744D-04,0.2219D-04,0.1717D-04,
     &0.1243D-04,0.7989D-05,0.3996D-05,0.6174D-06/
      DATA (XPV(I,2,1),I=1,100)/
     &0.5642D-02,0.5571D-02,0.5499D-02,0.5424D-02,0.5354D-02,0.5281D-02,
     &0.5207D-02,0.5136D-02,0.5064D-02,0.4989D-02,0.4918D-02,0.4845D-02,
     &0.4770D-02,0.4698D-02,0.4624D-02,0.4547D-02,0.4473D-02,0.4397D-02,
     &0.4319D-02,0.4243D-02,0.4164D-02,0.4083D-02,0.4004D-02,0.3922D-02,
     &0.3837D-02,0.3754D-02,0.3668D-02,0.3579D-02,0.3491D-02,0.3401D-02,
     &0.3308D-02,0.3214D-02,0.3120D-02,0.3022D-02,0.2923D-02,0.2824D-02,
     &0.2723D-02,0.2620D-02,0.2517D-02,0.2414D-02,0.2311D-02,0.2207D-02,
     &0.2103D-02,0.2008D-02,0.1905D-02,0.1806D-02,0.1713D-02,0.1622D-02,
     &0.1534D-02,0.1452D-02,0.1377D-02,0.1309D-02,0.1250D-02,0.1201D-02,
     &0.1160D-02,0.1132D-02,0.1117D-02,0.1114D-02,0.1126D-02,0.1151D-02,
     &0.1190D-02,0.1242D-02,0.1308D-02,0.1385D-02,0.1472D-02,0.1569D-02,
     &0.1672D-02,0.1782D-02,0.1895D-02,0.2009D-02,0.2124D-02,0.2239D-02,
     &0.2351D-02,0.2460D-02,0.2567D-02,0.2671D-02,0.2770D-02,0.2853D-02,
     &0.2860D-02,0.2865D-02,0.2870D-02,0.2874D-02,0.2877D-02,0.2878D-02,
     &0.2878D-02,0.2876D-02,0.2872D-02,0.2865D-02,0.2856D-02,0.2843D-02,
     &0.2826D-02,0.2805D-02,0.2777D-02,0.2743D-02,0.2699D-02,0.2643D-02,
     &0.2566D-02,0.2487D-02,0.2308D-02,0.1892D-02/
      DATA (XPV(I,2,2),I=1,100)/
     &0.5642D-02,0.5571D-02,0.5498D-02,0.5424D-02,0.5353D-02,0.5281D-02,
     &0.5206D-02,0.5136D-02,0.5063D-02,0.4989D-02,0.4917D-02,0.4844D-02,
     &0.4769D-02,0.4697D-02,0.4622D-02,0.4546D-02,0.4472D-02,0.4395D-02,
     &0.4317D-02,0.4240D-02,0.4162D-02,0.4080D-02,0.4000D-02,0.3918D-02,
     &0.3833D-02,0.3749D-02,0.3663D-02,0.3573D-02,0.3485D-02,0.3394D-02,
     &0.3300D-02,0.3205D-02,0.3109D-02,0.3011D-02,0.2910D-02,0.2810D-02,
     &0.2707D-02,0.2603D-02,0.2497D-02,0.2392D-02,0.2286D-02,0.2179D-02,
     &0.2072D-02,0.1974D-02,0.1866D-02,0.1763D-02,0.1665D-02,0.1569D-02,
     &0.1475D-02,0.1387D-02,0.1304D-02,0.1229D-02,0.1161D-02,0.1102D-02,
     &0.1050D-02,0.1012D-02,0.9843D-03,0.9685D-03,0.9656D-03,0.9754D-03,
     &0.9981D-03,0.1033D-02,0.1080D-02,0.1138D-02,0.1206D-02,0.1282D-02,
     &0.1364D-02,0.1451D-02,0.1541D-02,0.1631D-02,0.1719D-02,0.1803D-02,
     &0.1878D-02,0.1939D-02,0.1980D-02,0.1991D-02,0.1957D-02,0.1849D-02,
     &0.1831D-02,0.1811D-02,0.1790D-02,0.1767D-02,0.1743D-02,0.1717D-02,
     &0.1688D-02,0.1658D-02,0.1625D-02,0.1590D-02,0.1553D-02,0.1512D-02,
     &0.1468D-02,0.1420D-02,0.1367D-02,0.1309D-02,0.1244D-02,0.1172D-02,
     &0.1087D-02,0.9940D-03,0.8584D-03,0.6289D-03/
      DATA (XPV(I,2,3),I=1,100)/
     &0.5990D-02,0.5932D-02,0.5873D-02,0.5812D-02,0.5755D-02,0.5698D-02,
     &0.5639D-02,0.5584D-02,0.5528D-02,0.5471D-02,0.5417D-02,0.5362D-02,
     &0.5305D-02,0.5253D-02,0.5198D-02,0.5142D-02,0.5090D-02,0.5035D-02,
     &0.4979D-02,0.4926D-02,0.4871D-02,0.4814D-02,0.4760D-02,0.4703D-02,
     &0.4645D-02,0.4588D-02,0.4530D-02,0.4468D-02,0.4409D-02,0.4347D-02,
     &0.4283D-02,0.4218D-02,0.4153D-02,0.4085D-02,0.4015D-02,0.3945D-02,
     &0.3872D-02,0.3797D-02,0.3721D-02,0.3644D-02,0.3565D-02,0.3483D-02,
     &0.3401D-02,0.3326D-02,0.3236D-02,0.3148D-02,0.3063D-02,0.2974D-02,
     &0.2882D-02,0.2790D-02,0.2696D-02,0.2602D-02,0.2506D-02,0.2410D-02,
     &0.2307D-02,0.2208D-02,0.2106D-02,0.2001D-02,0.1894D-02,0.1784D-02,
     &0.1669D-02,0.1551D-02,0.1430D-02,0.1303D-02,0.1172D-02,0.1039D-02,
     &0.9062D-03,0.7748D-03,0.6491D-03,0.5328D-03,0.4303D-03,0.3456D-03,
     &0.2823D-03,0.2428D-03,0.2282D-03,0.2383D-03,0.2730D-03,0.3327D-03,
     &0.3409D-03,0.3492D-03,0.3578D-03,0.3664D-03,0.3754D-03,0.3844D-03,
     &0.3936D-03,0.4028D-03,0.4122D-03,0.4214D-03,0.4309D-03,0.4400D-03,
     &0.4492D-03,0.4580D-03,0.4665D-03,0.4743D-03,0.4813D-03,0.4872D-03,
     &0.4894D-03,0.4958D-03,0.4830D-03,0.4112D-03/
      DATA (XPV(I,2,4),I=1,100)/
     &0.5746D-02,0.5678D-02,0.5610D-02,0.5539D-02,0.5472D-02,0.5404D-02,
     &0.5334D-02,0.5268D-02,0.5200D-02,0.5130D-02,0.5064D-02,0.4996D-02,
     &0.4925D-02,0.4858D-02,0.4789D-02,0.4718D-02,0.4650D-02,0.4579D-02,
     &0.4506D-02,0.4436D-02,0.4363D-02,0.4287D-02,0.4214D-02,0.4138D-02,
     &0.4060D-02,0.3982D-02,0.3902D-02,0.3819D-02,0.3737D-02,0.3653D-02,
     &0.3565D-02,0.3476D-02,0.3386D-02,0.3294D-02,0.3198D-02,0.3103D-02,
     &0.3005D-02,0.2905D-02,0.2803D-02,0.2701D-02,0.2597D-02,0.2491D-02,
     &0.2384D-02,0.2285D-02,0.2175D-02,0.2067D-02,0.1964D-02,0.1859D-02,
     &0.1754D-02,0.1653D-02,0.1555D-02,0.1459D-02,0.1368D-02,0.1282D-02,
     &0.1198D-02,0.1122D-02,0.1052D-02,0.9883D-03,0.9310D-03,0.8798D-03,
     &0.8347D-03,0.7955D-03,0.7619D-03,0.7321D-03,0.7064D-03,0.6839D-03,
     &0.6649D-03,0.6491D-03,0.6373D-03,0.6309D-03,0.6320D-03,0.6435D-03,
     &0.6699D-03,0.7168D-03,0.7928D-03,0.9097D-03,0.1084D-02,0.1336D-02,
     &0.1369D-02,0.1403D-02,0.1438D-02,0.1473D-02,0.1510D-02,0.1546D-02,
     &0.1583D-02,0.1621D-02,0.1658D-02,0.1696D-02,0.1734D-02,0.1771D-02,
     &0.1808D-02,0.1843D-02,0.1877D-02,0.1908D-02,0.1936D-02,0.1958D-02,
     &0.1969D-02,0.1988D-02,0.1933D-02,0.1674D-02/
      DATA (XPV(I,3,0),I=1,100)/
     &0.1386D+01,0.1342D+01,0.1299D+01,0.1256D+01,0.1215D+01,0.1174D+01,
     &0.1134D+01,0.1096D+01,0.1059D+01,0.1022D+01,0.9870D+00,0.9524D+00,
     &0.9181D+00,0.8858D+00,0.8538D+00,0.8222D+00,0.7924D+00,0.7628D+00,
     &0.7337D+00,0.7062D+00,0.6791D+00,0.6520D+00,0.6268D+00,0.6016D+00,
     &0.5770D+00,0.5536D+00,0.5305D+00,0.5077D+00,0.4861D+00,0.4649D+00,
     &0.4439D+00,0.4238D+00,0.4042D+00,0.3849D+00,0.3660D+00,0.3479D+00,
     &0.3300D+00,0.3124D+00,0.2953D+00,0.2787D+00,0.2625D+00,0.2464D+00,
     &0.2306D+00,0.2161D+00,0.2007D+00,0.1859D+00,0.1717D+00,0.1576D+00,
     &0.1437D+00,0.1303D+00,0.1173D+00,0.1047D+00,0.9264D-01,0.8116D-01,
     &0.7004D-01,0.5986D-01,0.5046D-01,0.4185D-01,0.3414D-01,0.2734D-01,
     &0.2148D-01,0.1659D-01,0.1262D-01,0.9443D-02,0.7030D-02,0.5248D-02,
     &0.3988D-02,0.3111D-02,0.2508D-02,0.2082D-02,0.1760D-02,0.1496D-02,
     &0.1262D-02,0.1046D-02,0.8417D-03,0.6478D-03,0.4647D-03,0.2925D-03,
     &0.2744D-03,0.2566D-03,0.2393D-03,0.2224D-03,0.2059D-03,0.1898D-03,
     &0.1740D-03,0.1587D-03,0.1439D-03,0.1295D-03,0.1155D-03,0.1020D-03,
     &0.8898D-04,0.7644D-04,0.6443D-04,0.5299D-04,0.4215D-04,0.3199D-04,
     &0.2259D-04,0.1402D-04,0.6692D-05,0.1051D-05/
      DATA (XPV(I,3,1),I=1,100)/
     &0.2133D-01,0.2081D-01,0.2030D-01,0.1978D-01,0.1929D-01,0.1880D-01,
     &0.1831D-01,0.1784D-01,0.1738D-01,0.1691D-01,0.1646D-01,0.1602D-01,
     &0.1557D-01,0.1515D-01,0.1472D-01,0.1430D-01,0.1389D-01,0.1348D-01,
     &0.1308D-01,0.1269D-01,0.1229D-01,0.1190D-01,0.1152D-01,0.1114D-01,
     &0.1076D-01,0.1040D-01,0.1003D-01,0.9657D-02,0.9299D-02,0.8941D-02,
     &0.8582D-02,0.8229D-02,0.7881D-02,0.7532D-02,0.7185D-02,0.6846D-02,
     &0.6509D-02,0.6172D-02,0.5842D-02,0.5519D-02,0.5201D-02,0.4886D-02,
     &0.4579D-02,0.4296D-02,0.4000D-02,0.3718D-02,0.3455D-02,0.3201D-02,
     &0.2956D-02,0.2729D-02,0.2520D-02,0.2329D-02,0.2158D-02,0.2010D-02,
     &0.1879D-02,0.1777D-02,0.1699D-02,0.1646D-02,0.1618D-02,0.1614D-02,
     &0.1634D-02,0.1676D-02,0.1738D-02,0.1817D-02,0.1911D-02,0.2016D-02,
     &0.2129D-02,0.2248D-02,0.2370D-02,0.2492D-02,0.2615D-02,0.2736D-02,
     &0.2859D-02,0.2984D-02,0.3117D-02,0.3264D-02,0.3430D-02,0.3609D-02,
     &0.3628D-02,0.3646D-02,0.3663D-02,0.3678D-02,0.3693D-02,0.3706D-02,
     &0.3716D-02,0.3725D-02,0.3731D-02,0.3733D-02,0.3732D-02,0.3726D-02,
     &0.3714D-02,0.3695D-02,0.3669D-02,0.3631D-02,0.3579D-02,0.3508D-02,
     &0.3406D-02,0.3304D-02,0.3023D-02,0.2344D-02/
      DATA (XPV(I,3,2),I=1,100)/
     &0.2133D-01,0.2081D-01,0.2030D-01,0.1978D-01,0.1929D-01,0.1880D-01,
     &0.1831D-01,0.1784D-01,0.1737D-01,0.1691D-01,0.1646D-01,0.1602D-01,
     &0.1557D-01,0.1515D-01,0.1472D-01,0.1430D-01,0.1389D-01,0.1348D-01,
     &0.1307D-01,0.1268D-01,0.1229D-01,0.1189D-01,0.1151D-01,0.1113D-01,
     &0.1075D-01,0.1038D-01,0.1001D-01,0.9643D-02,0.9283D-02,0.8924D-02,
     &0.8563D-02,0.8208D-02,0.7857D-02,0.7506D-02,0.7155D-02,0.6813D-02,
     &0.6473D-02,0.6132D-02,0.5797D-02,0.5469D-02,0.5146D-02,0.4825D-02,
     &0.4510D-02,0.4221D-02,0.3916D-02,0.3626D-02,0.3352D-02,0.3087D-02,
     &0.2830D-02,0.2590D-02,0.2366D-02,0.2159D-02,0.1971D-02,0.1803D-02,
     &0.1652D-02,0.1527D-02,0.1425D-02,0.1346D-02,0.1290D-02,0.1257D-02,
     &0.1245D-02,0.1254D-02,0.1281D-02,0.1324D-02,0.1379D-02,0.1445D-02,
     &0.1517D-02,0.1594D-02,0.1672D-02,0.1748D-02,0.1819D-02,0.1882D-02,
     &0.1933D-02,0.1969D-02,0.1983D-02,0.1969D-02,0.1915D-02,0.1799D-02,
     &0.1781D-02,0.1762D-02,0.1741D-02,0.1720D-02,0.1697D-02,0.1672D-02,
     &0.1646D-02,0.1618D-02,0.1588D-02,0.1556D-02,0.1522D-02,0.1486D-02,
     &0.1446D-02,0.1403D-02,0.1356D-02,0.1304D-02,0.1247D-02,0.1181D-02,
     &0.1105D-02,0.1025D-02,0.8897D-03,0.6390D-03/
      DATA (XPV(I,3,3),I=1,100)/
     &0.2170D-01,0.2120D-01,0.2069D-01,0.2019D-01,0.1972D-01,0.1924D-01,
     &0.1877D-01,0.1832D-01,0.1787D-01,0.1742D-01,0.1699D-01,0.1657D-01,
     &0.1614D-01,0.1573D-01,0.1533D-01,0.1492D-01,0.1454D-01,0.1415D-01,
     &0.1377D-01,0.1340D-01,0.1303D-01,0.1266D-01,0.1231D-01,0.1195D-01,
     &0.1160D-01,0.1126D-01,0.1092D-01,0.1057D-01,0.1024D-01,0.9910D-02,
     &0.9576D-02,0.9250D-02,0.8928D-02,0.8605D-02,0.8283D-02,0.7969D-02,
     &0.7655D-02,0.7340D-02,0.7030D-02,0.6725D-02,0.6424D-02,0.6122D-02,
     &0.5826D-02,0.5553D-02,0.5258D-02,0.4974D-02,0.4704D-02,0.4437D-02,
     &0.4170D-02,0.3915D-02,0.3668D-02,0.3430D-02,0.3202D-02,0.2984D-02,
     &0.2768D-02,0.2570D-02,0.2382D-02,0.2202D-02,0.2032D-02,0.1870D-02,
     &0.1715D-02,0.1568D-02,0.1427D-02,0.1289D-02,0.1156D-02,0.1027D-02,
     &0.9038D-03,0.7871D-03,0.6800D-03,0.5851D-03,0.5058D-03,0.4453D-03,
     &0.4065D-03,0.3917D-03,0.4024D-03,0.4400D-03,0.5058D-03,0.6008D-03,
     &0.6130D-03,0.6252D-03,0.6375D-03,0.6499D-03,0.6623D-03,0.6745D-03,
     &0.6867D-03,0.6987D-03,0.7104D-03,0.7216D-03,0.7325D-03,0.7425D-03,
     &0.7518D-03,0.7598D-03,0.7664D-03,0.7709D-03,0.7727D-03,0.7706D-03,
     &0.7622D-03,0.7542D-03,0.7051D-03,0.5640D-03/
      DATA (XPV(I,3,4),I=1,100)/
     &0.2144D-01,0.2093D-01,0.2041D-01,0.1990D-01,0.1942D-01,0.1893D-01,
     &0.1844D-01,0.1798D-01,0.1752D-01,0.1706D-01,0.1662D-01,0.1618D-01,
     &0.1574D-01,0.1532D-01,0.1490D-01,0.1448D-01,0.1408D-01,0.1367D-01,
     &0.1327D-01,0.1288D-01,0.1250D-01,0.1211D-01,0.1174D-01,0.1136D-01,
     &0.1099D-01,0.1063D-01,0.1026D-01,0.9898D-02,0.9545D-02,0.9192D-02,
     &0.8837D-02,0.8488D-02,0.8143D-02,0.7798D-02,0.7453D-02,0.7116D-02,
     &0.6779D-02,0.6443D-02,0.6112D-02,0.5786D-02,0.5465D-02,0.5145D-02,
     &0.4831D-02,0.4541D-02,0.4234D-02,0.3939D-02,0.3661D-02,0.3389D-02,
     &0.3122D-02,0.2871D-02,0.2632D-02,0.2409D-02,0.2200D-02,0.2009D-02,
     &0.1830D-02,0.1675D-02,0.1538D-02,0.1418D-02,0.1319D-02,0.1236D-02,
     &0.1171D-02,0.1122D-02,0.1087D-02,0.1064D-02,0.1051D-02,0.1047D-02,
     &0.1050D-02,0.1061D-02,0.1079D-02,0.1105D-02,0.1142D-02,0.1194D-02,
     &0.1267D-02,0.1372D-02,0.1520D-02,0.1729D-02,0.2019D-02,0.2410D-02,
     &0.2459D-02,0.2509D-02,0.2559D-02,0.2609D-02,0.2659D-02,0.2708D-02,
     &0.2757D-02,0.2805D-02,0.2853D-02,0.2898D-02,0.2942D-02,0.2982D-02,
     &0.3020D-02,0.3052D-02,0.3079D-02,0.3097D-02,0.3105D-02,0.3097D-02,
     &0.3063D-02,0.3033D-02,0.2839D-02,0.2269D-02/
      DATA (XPV(I,4,0),I=1,100)/
     &0.1713D+01,0.1653D+01,0.1593D+01,0.1534D+01,0.1478D+01,0.1423D+01,
     &0.1369D+01,0.1318D+01,0.1268D+01,0.1219D+01,0.1172D+01,0.1126D+01,
     &0.1081D+01,0.1038D+01,0.9964D+00,0.9552D+00,0.9163D+00,0.8781D+00,
     &0.8407D+00,0.8054D+00,0.7708D+00,0.7365D+00,0.7045D+00,0.6729D+00,
     &0.6421D+00,0.6129D+00,0.5844D+00,0.5563D+00,0.5298D+00,0.5040D+00,
     &0.4786D+00,0.4543D+00,0.4309D+00,0.4080D+00,0.3857D+00,0.3645D+00,
     &0.3437D+00,0.3235D+00,0.3039D+00,0.2850D+00,0.2668D+00,0.2489D+00,
     &0.2315D+00,0.2155D+00,0.1989D+00,0.1830D+00,0.1679D+00,0.1532D+00,
     &0.1388D+00,0.1250D+00,0.1118D+00,0.9925D-01,0.8729D-01,0.7605D-01,
     &0.6530D-01,0.5557D-01,0.4669D-01,0.3863D-01,0.3151D-01,0.2530D-01,
     &0.1999D-01,0.1560D-01,0.1206D-01,0.9245D-02,0.7105D-02,0.5513D-02,
     &0.4368D-02,0.3544D-02,0.2948D-02,0.2497D-02,0.2133D-02,0.1819D-02,
     &0.1533D-02,0.1267D-02,0.1016D-02,0.7782D-03,0.5551D-03,0.3467D-03,
     &0.3248D-03,0.3035D-03,0.2826D-03,0.2623D-03,0.2426D-03,0.2233D-03,
     &0.2044D-03,0.1862D-03,0.1685D-03,0.1514D-03,0.1348D-03,0.1188D-03,
     &0.1033D-03,0.8856D-04,0.7444D-04,0.6102D-04,0.4836D-04,0.3654D-04,
     &0.2566D-04,0.1580D-04,0.7467D-05,0.1177D-05/
      DATA (XPV(I,4,1),I=1,100)/
     &0.2961D-01,0.2879D-01,0.2797D-01,0.2716D-01,0.2638D-01,0.2562D-01,
     &0.2485D-01,0.2413D-01,0.2341D-01,0.2269D-01,0.2201D-01,0.2134D-01,
     &0.2066D-01,0.2003D-01,0.1939D-01,0.1875D-01,0.1815D-01,0.1755D-01,
     &0.1695D-01,0.1638D-01,0.1582D-01,0.1525D-01,0.1471D-01,0.1417D-01,
     &0.1363D-01,0.1311D-01,0.1260D-01,0.1209D-01,0.1159D-01,0.1110D-01,
     &0.1061D-01,0.1014D-01,0.9670D-02,0.9205D-02,0.8745D-02,0.8300D-02,
     &0.7859D-02,0.7423D-02,0.6997D-02,0.6583D-02,0.6178D-02,0.5780D-02,
     &0.5394D-02,0.5041D-02,0.4673D-02,0.4326D-02,0.4002D-02,0.3692D-02,
     &0.3395D-02,0.3121D-02,0.2869D-02,0.2641D-02,0.2438D-02,0.2262D-02,
     &0.2107D-02,0.1986D-02,0.1894D-02,0.1830D-02,0.1795D-02,0.1787D-02,
     &0.1806D-02,0.1849D-02,0.1914D-02,0.1997D-02,0.2095D-02,0.2205D-02,
     &0.2323D-02,0.2447D-02,0.2573D-02,0.2700D-02,0.2827D-02,0.2953D-02,
     &0.3082D-02,0.3216D-02,0.3362D-02,0.3530D-02,0.3726D-02,0.3944D-02,
     &0.3968D-02,0.3990D-02,0.4012D-02,0.4032D-02,0.4051D-02,0.4068D-02,
     &0.4083D-02,0.4095D-02,0.4104D-02,0.4109D-02,0.4110D-02,0.4106D-02,
     &0.4095D-02,0.4076D-02,0.4048D-02,0.4007D-02,0.3951D-02,0.3872D-02,
     &0.3759D-02,0.3643D-02,0.3325D-02,0.2555D-02/
      DATA (XPV(I,4,2),I=1,100)/
     &0.2961D-01,0.2879D-01,0.2797D-01,0.2715D-01,0.2638D-01,0.2561D-01,
     &0.2485D-01,0.2413D-01,0.2341D-01,0.2269D-01,0.2201D-01,0.2133D-01,
     &0.2066D-01,0.2002D-01,0.1938D-01,0.1875D-01,0.1815D-01,0.1754D-01,
     &0.1695D-01,0.1637D-01,0.1581D-01,0.1524D-01,0.1470D-01,0.1415D-01,
     &0.1362D-01,0.1310D-01,0.1258D-01,0.1207D-01,0.1157D-01,0.1108D-01,
     &0.1059D-01,0.1011D-01,0.9639D-02,0.9172D-02,0.8708D-02,0.8258D-02,
     &0.7813D-02,0.7372D-02,0.6940D-02,0.6520D-02,0.6109D-02,0.5703D-02,
     &0.5308D-02,0.4946D-02,0.4568D-02,0.4209D-02,0.3874D-02,0.3550D-02,
     &0.3237D-02,0.2948D-02,0.2678D-02,0.2430D-02,0.2205D-02,0.2006D-02,
     &0.1826D-02,0.1678D-02,0.1556D-02,0.1460D-02,0.1392D-02,0.1348D-02,
     &0.1329D-02,0.1332D-02,0.1354D-02,0.1393D-02,0.1446D-02,0.1508D-02,
     &0.1578D-02,0.1651D-02,0.1724D-02,0.1795D-02,0.1860D-02,0.1916D-02,
     &0.1960D-02,0.1988D-02,0.1995D-02,0.1975D-02,0.1918D-02,0.1805D-02,
     &0.1788D-02,0.1770D-02,0.1750D-02,0.1729D-02,0.1708D-02,0.1684D-02,
     &0.1660D-02,0.1633D-02,0.1605D-02,0.1575D-02,0.1543D-02,0.1508D-02,
     &0.1471D-02,0.1430D-02,0.1385D-02,0.1336D-02,0.1281D-02,0.1218D-02,
     &0.1144D-02,0.1067D-02,0.9312D-03,0.6726D-03/
      DATA (XPV(I,4,3),I=1,100)/
     &0.2998D-01,0.2918D-01,0.2837D-01,0.2758D-01,0.2682D-01,0.2607D-01,
     &0.2532D-01,0.2461D-01,0.2391D-01,0.2321D-01,0.2255D-01,0.2189D-01,
     &0.2124D-01,0.2062D-01,0.2000D-01,0.1939D-01,0.1881D-01,0.1823D-01,
     &0.1765D-01,0.1711D-01,0.1656D-01,0.1602D-01,0.1550D-01,0.1499D-01,
     &0.1447D-01,0.1398D-01,0.1350D-01,0.1301D-01,0.1254D-01,0.1208D-01,
     &0.1161D-01,0.1116D-01,0.1072D-01,0.1028D-01,0.9842D-02,0.9419D-02,
     &0.9000D-02,0.8583D-02,0.8174D-02,0.7776D-02,0.7384D-02,0.6996D-02,
     &0.6616D-02,0.6268D-02,0.5896D-02,0.5541D-02,0.5206D-02,0.4876D-02,
     &0.4551D-02,0.4242D-02,0.3945D-02,0.3662D-02,0.3393D-02,0.3138D-02,
     &0.2890D-02,0.2664D-02,0.2453D-02,0.2253D-02,0.2067D-02,0.1893D-02,
     &0.1730D-02,0.1576D-02,0.1432D-02,0.1293D-02,0.1161D-02,0.1035D-02,
     &0.9167D-03,0.8059D-03,0.7058D-03,0.6185D-03,0.5474D-03,0.4952D-03,
     &0.4650D-03,0.4588D-03,0.4786D-03,0.5261D-03,0.6032D-03,0.7103D-03,
     &0.7238D-03,0.7373D-03,0.7508D-03,0.7642D-03,0.7777D-03,0.7909D-03,
     &0.8039D-03,0.8165D-03,0.8288D-03,0.8404D-03,0.8514D-03,0.8613D-03,
     &0.8702D-03,0.8774D-03,0.8828D-03,0.8855D-03,0.8849D-03,0.8794D-03,
     &0.8664D-03,0.8526D-03,0.7906D-03,0.6244D-03/
      DATA (XPV(I,4,4),I=1,100)/
     &0.2972D-01,0.2890D-01,0.2809D-01,0.2728D-01,0.2651D-01,0.2575D-01,
     &0.2499D-01,0.2427D-01,0.2356D-01,0.2284D-01,0.2217D-01,0.2150D-01,
     &0.2083D-01,0.2019D-01,0.1956D-01,0.1893D-01,0.1834D-01,0.1774D-01,
     &0.1715D-01,0.1658D-01,0.1602D-01,0.1546D-01,0.1492D-01,0.1439D-01,
     &0.1386D-01,0.1335D-01,0.1284D-01,0.1233D-01,0.1184D-01,0.1135D-01,
     &0.1087D-01,0.1039D-01,0.9930D-02,0.9468D-02,0.9010D-02,0.8565D-02,
     &0.8125D-02,0.7688D-02,0.7260D-02,0.6843D-02,0.6433D-02,0.6029D-02,
     &0.5635D-02,0.5273D-02,0.4893D-02,0.4531D-02,0.4191D-02,0.3861D-02,
     &0.3540D-02,0.3240D-02,0.2958D-02,0.2695D-02,0.2452D-02,0.2232D-02,
     &0.2027D-02,0.1851D-02,0.1698D-02,0.1567D-02,0.1459D-02,0.1373D-02,
     &0.1307D-02,0.1259D-02,0.1229D-02,0.1211D-02,0.1206D-02,0.1212D-02,
     &0.1226D-02,0.1247D-02,0.1277D-02,0.1316D-02,0.1368D-02,0.1436D-02,
     &0.1529D-02,0.1656D-02,0.1832D-02,0.2076D-02,0.2410D-02,0.2849D-02,
     &0.2903D-02,0.2958D-02,0.3013D-02,0.3067D-02,0.3121D-02,0.3174D-02,
     &0.3227D-02,0.3278D-02,0.3327D-02,0.3374D-02,0.3419D-02,0.3459D-02,
     &0.3494D-02,0.3524D-02,0.3546D-02,0.3557D-02,0.3555D-02,0.3534D-02,
     &0.3481D-02,0.3429D-02,0.3184D-02,0.2507D-02/
      DATA (XPV(I,5,0),I=1,100)/
     &0.2770D+01,0.2649D+01,0.2529D+01,0.2413D+01,0.2304D+01,0.2198D+01,
     &0.2094D+01,0.1997D+01,0.1902D+01,0.1810D+01,0.1724D+01,0.1640D+01,
     &0.1558D+01,0.1481D+01,0.1407D+01,0.1334D+01,0.1266D+01,0.1201D+01,
     &0.1137D+01,0.1077D+01,0.1019D+01,0.9629D+00,0.9107D+00,0.8597D+00,
     &0.8105D+00,0.7646D+00,0.7201D+00,0.6769D+00,0.6367D+00,0.5980D+00,
     &0.5605D+00,0.5252D+00,0.4916D+00,0.4592D+00,0.4281D+00,0.3990D+00,
     &0.3711D+00,0.3442D+00,0.3187D+00,0.2947D+00,0.2718D+00,0.2498D+00,
     &0.2289D+00,0.2101D+00,0.1910D+00,0.1731D+00,0.1566D+00,0.1408D+00,
     &0.1257D+00,0.1117D+00,0.9867D-01,0.8653D-01,0.7529D-01,0.6501D-01,
     &0.5545D-01,0.4701D-01,0.3952D-01,0.3288D-01,0.2715D-01,0.2225D-01,
     &0.1814D-01,0.1478D-01,0.1208D-01,0.9909D-02,0.8219D-02,0.6899D-02,
     &0.5872D-02,0.5047D-02,0.4368D-02,0.3783D-02,0.3261D-02,0.2780D-02,
     &0.2333D-02,0.1914D-02,0.1522D-02,0.1155D-02,0.8143D-03,0.5006D-03,
     &0.4680D-03,0.4362D-03,0.4053D-03,0.3753D-03,0.3461D-03,0.3178D-03,
     &0.2901D-03,0.2634D-03,0.2377D-03,0.2128D-03,0.1888D-03,0.1657D-03,
     &0.1436D-03,0.1225D-03,0.1025D-03,0.8355D-04,0.6581D-04,0.4937D-04,
     &0.3437D-04,0.2094D-04,0.9768D-05,0.1553D-05/
      DATA (XPV(I,5,1),I=1,100)/
     &0.6050D-01,0.5833D-01,0.5619D-01,0.5409D-01,0.5210D-01,0.5014D-01,
     &0.4822D-01,0.4640D-01,0.4462D-01,0.4287D-01,0.4121D-01,0.3959D-01,
     &0.3799D-01,0.3648D-01,0.3500D-01,0.3354D-01,0.3216D-01,0.3080D-01,
     &0.2947D-01,0.2822D-01,0.2698D-01,0.2576D-01,0.2462D-01,0.2348D-01,
     &0.2237D-01,0.2132D-01,0.2029D-01,0.1927D-01,0.1830D-01,0.1736D-01,
     &0.1643D-01,0.1554D-01,0.1468D-01,0.1384D-01,0.1301D-01,0.1223D-01,
     &0.1147D-01,0.1072D-01,0.1001D-01,0.9326D-02,0.8669D-02,0.8032D-02,
     &0.7423D-02,0.6873D-02,0.6313D-02,0.5792D-02,0.5314D-02,0.4862D-02,
     &0.4437D-02,0.4053D-02,0.3705D-02,0.3395D-02,0.3124D-02,0.2892D-02,
     &0.2694D-02,0.2542D-02,0.2430D-02,0.2354D-02,0.2316D-02,0.2312D-02,
     &0.2341D-02,0.2397D-02,0.2478D-02,0.2579D-02,0.2696D-02,0.2825D-02,
     &0.2961D-02,0.3102D-02,0.3244D-02,0.3387D-02,0.3531D-02,0.3677D-02,
     &0.3831D-02,0.3999D-02,0.4196D-02,0.4435D-02,0.4730D-02,0.5071D-02,
     &0.5109D-02,0.5145D-02,0.5181D-02,0.5214D-02,0.5246D-02,0.5274D-02,
     &0.5300D-02,0.5322D-02,0.5340D-02,0.5352D-02,0.5358D-02,0.5357D-02,
     &0.5347D-02,0.5325D-02,0.5291D-02,0.5238D-02,0.5164D-02,0.5059D-02,
     &0.4907D-02,0.4746D-02,0.4309D-02,0.3281D-02/
      DATA (XPV(I,5,2),I=1,100)/
     &0.6050D-01,0.5833D-01,0.5619D-01,0.5408D-01,0.5209D-01,0.5014D-01,
     &0.4822D-01,0.4640D-01,0.4462D-01,0.4286D-01,0.4121D-01,0.3958D-01,
     &0.3798D-01,0.3647D-01,0.3499D-01,0.3353D-01,0.3215D-01,0.3079D-01,
     &0.2946D-01,0.2820D-01,0.2697D-01,0.2574D-01,0.2460D-01,0.2346D-01,
     &0.2235D-01,0.2129D-01,0.2026D-01,0.1924D-01,0.1827D-01,0.1732D-01,
     &0.1639D-01,0.1549D-01,0.1463D-01,0.1378D-01,0.1295D-01,0.1216D-01,
     &0.1139D-01,0.1063D-01,0.9910D-02,0.9216D-02,0.8547D-02,0.7898D-02,
     &0.7274D-02,0.6709D-02,0.6132D-02,0.5593D-02,0.5094D-02,0.4620D-02,
     &0.4170D-02,0.3759D-02,0.3382D-02,0.3040D-02,0.2734D-02,0.2465D-02,
     &0.2226D-02,0.2030D-02,0.1871D-02,0.1746D-02,0.1654D-02,0.1594D-02,
     &0.1562D-02,0.1555D-02,0.1571D-02,0.1603D-02,0.1649D-02,0.1705D-02,
     &0.1765D-02,0.1828D-02,0.1889D-02,0.1946D-02,0.1994D-02,0.2033D-02,
     &0.2060D-02,0.2071D-02,0.2065D-02,0.2038D-02,0.1987D-02,0.1896D-02,
     &0.1883D-02,0.1868D-02,0.1853D-02,0.1837D-02,0.1820D-02,0.1802D-02,
     &0.1783D-02,0.1762D-02,0.1739D-02,0.1715D-02,0.1689D-02,0.1661D-02,
     &0.1629D-02,0.1595D-02,0.1556D-02,0.1513D-02,0.1464D-02,0.1406D-02,
     &0.1336D-02,0.1263D-02,0.1120D-02,0.8288D-03/
      DATA (XPV(I,5,3),I=1,100)/
     &0.6090D-01,0.5875D-01,0.5662D-01,0.5453D-01,0.5256D-01,0.5062D-01,
     &0.4871D-01,0.4691D-01,0.4515D-01,0.4341D-01,0.4178D-01,0.4017D-01,
     &0.3859D-01,0.3710D-01,0.3564D-01,0.3420D-01,0.3284D-01,0.3151D-01,
     &0.3020D-01,0.2897D-01,0.2776D-01,0.2656D-01,0.2544D-01,0.2433D-01,
     &0.2324D-01,0.2221D-01,0.2120D-01,0.2021D-01,0.1926D-01,0.1834D-01,
     &0.1744D-01,0.1657D-01,0.1572D-01,0.1490D-01,0.1410D-01,0.1333D-01,
     &0.1258D-01,0.1185D-01,0.1114D-01,0.1046D-01,0.9808D-02,0.9169D-02,
     &0.8554D-02,0.7996D-02,0.7417D-02,0.6872D-02,0.6364D-02,0.5875D-02,
     &0.5402D-02,0.4961D-02,0.4545D-02,0.4157D-02,0.3795D-02,0.3461D-02,
     &0.3143D-02,0.2860D-02,0.2602D-02,0.2365D-02,0.2152D-02,0.1957D-02,
     &0.1780D-02,0.1620D-02,0.1474D-02,0.1339D-02,0.1214D-02,0.1100D-02,
     &0.9956D-03,0.9020D-03,0.8211D-03,0.7547D-03,0.7054D-03,0.6757D-03,
     &0.6684D-03,0.6859D-03,0.7308D-03,0.8062D-03,0.9148D-03,0.1055D-02,
     &0.1072D-02,0.1089D-02,0.1105D-02,0.1121D-02,0.1137D-02,0.1153D-02,
     &0.1167D-02,0.1182D-02,0.1195D-02,0.1207D-02,0.1217D-02,0.1226D-02,
     &0.1233D-02,0.1237D-02,0.1239D-02,0.1235D-02,0.1227D-02,0.1211D-02,
     &0.1184D-02,0.1153D-02,0.1055D-02,0.8147D-03/
      DATA (XPV(I,5,4),I=1,100)/
     &0.6062D-01,0.5845D-01,0.5631D-01,0.5421D-01,0.5223D-01,0.5028D-01,
     &0.4836D-01,0.4655D-01,0.4478D-01,0.4302D-01,0.4138D-01,0.3976D-01,
     &0.3816D-01,0.3666D-01,0.3518D-01,0.3372D-01,0.3235D-01,0.3100D-01,
     &0.2967D-01,0.2842D-01,0.2719D-01,0.2597D-01,0.2484D-01,0.2371D-01,
     &0.2260D-01,0.2155D-01,0.2052D-01,0.1951D-01,0.1855D-01,0.1761D-01,
     &0.1668D-01,0.1579D-01,0.1493D-01,0.1409D-01,0.1327D-01,0.1248D-01,
     &0.1172D-01,0.1097D-01,0.1025D-01,0.9561D-02,0.8895D-02,0.8249D-02,
     &0.7629D-02,0.7067D-02,0.6490D-02,0.5951D-02,0.5451D-02,0.4976D-02,
     &0.4523D-02,0.4107D-02,0.3724D-02,0.3375D-02,0.3059D-02,0.2780D-02,
     &0.2527D-02,0.2317D-02,0.2141D-02,0.1997D-02,0.1886D-02,0.1803D-02,
     &0.1748D-02,0.1717D-02,0.1709D-02,0.1717D-02,0.1741D-02,0.1778D-02,
     &0.1825D-02,0.1883D-02,0.1951D-02,0.2031D-02,0.2127D-02,0.2246D-02,
     &0.2396D-02,0.2592D-02,0.2852D-02,0.3200D-02,0.3657D-02,0.4230D-02,
     &0.4298D-02,0.4365D-02,0.4432D-02,0.4498D-02,0.4563D-02,0.4625D-02,
     &0.4685D-02,0.4741D-02,0.4795D-02,0.4843D-02,0.4887D-02,0.4923D-02,
     &0.4951D-02,0.4968D-02,0.4973D-02,0.4961D-02,0.4927D-02,0.4864D-02,
     &0.4754D-02,0.4636D-02,0.4245D-02,0.3267D-02/
      DATA (XPV(I,6,0),I=1,100)/
     &0.3742D+01,0.3556D+01,0.3375D+01,0.3200D+01,0.3037D+01,0.2878D+01,
     &0.2725D+01,0.2582D+01,0.2444D+01,0.2310D+01,0.2185D+01,0.2065D+01,
     &0.1949D+01,0.1840D+01,0.1736D+01,0.1635D+01,0.1541D+01,0.1451D+01,
     &0.1364D+01,0.1283D+01,0.1205D+01,0.1130D+01,0.1061D+01,0.9934D+00,
     &0.9293D+00,0.8698D+00,0.8128D+00,0.7578D+00,0.7071D+00,0.6586D+00,
     &0.6121D+00,0.5687D+00,0.5278D+00,0.4887D+00,0.4517D+00,0.4173D+00,
     &0.3846D+00,0.3535D+00,0.3244D+00,0.2973D+00,0.2717D+00,0.2475D+00,
     &0.2247D+00,0.2045D+00,0.1843D+00,0.1656D+00,0.1486D+00,0.1327D+00,
     &0.1176D+00,0.1039D+00,0.9130D-01,0.7978D-01,0.6928D-01,0.5984D-01,
     &0.5118D-01,0.4366D-01,0.3707D-01,0.3131D-01,0.2638D-01,0.2219D-01,
     &0.1867D-01,0.1577D-01,0.1341D-01,0.1147D-01,0.9882D-02,0.8574D-02,
     &0.7485D-02,0.6547D-02,0.5722D-02,0.4975D-02,0.4289D-02,0.3649D-02,
     &0.3052D-02,0.2495D-02,0.1975D-02,0.1492D-02,0.1045D-02,0.6378D-03,
     &0.5956D-03,0.5547D-03,0.5148D-03,0.4761D-03,0.4386D-03,0.4023D-03,
     &0.3667D-03,0.3326D-03,0.2997D-03,0.2679D-03,0.2373D-03,0.2080D-03,
     &0.1800D-03,0.1533D-03,0.1280D-03,0.1041D-03,0.8181D-04,0.6122D-04,
     &0.4250D-04,0.2581D-04,0.1200D-04,0.1914D-05/
      DATA (XPV(I,6,1),I=1,100)/
     &0.9375D-01,0.8988D-01,0.8607D-01,0.8236D-01,0.7887D-01,0.7546D-01,
     &0.7213D-01,0.6901D-01,0.6596D-01,0.6297D-01,0.6018D-01,0.5745D-01,
     &0.5478D-01,0.5228D-01,0.4984D-01,0.4745D-01,0.4522D-01,0.4304D-01,
     &0.4091D-01,0.3892D-01,0.3697D-01,0.3506D-01,0.3329D-01,0.3155D-01,
     &0.2986D-01,0.2827D-01,0.2672D-01,0.2520D-01,0.2378D-01,0.2241D-01,
     &0.2106D-01,0.1979D-01,0.1857D-01,0.1738D-01,0.1624D-01,0.1516D-01,
     &0.1412D-01,0.1312D-01,0.1217D-01,0.1127D-01,0.1041D-01,0.9586D-02,
     &0.8807D-02,0.8113D-02,0.7414D-02,0.6771D-02,0.6188D-02,0.5645D-02,
     &0.5140D-02,0.4689D-02,0.4287D-02,0.3934D-02,0.3630D-02,0.3376D-02,
     &0.3163D-02,0.3005D-02,0.2894D-02,0.2825D-02,0.2798D-02,0.2809D-02,
     &0.2854D-02,0.2930D-02,0.3031D-02,0.3152D-02,0.3289D-02,0.3437D-02,
     &0.3593D-02,0.3752D-02,0.3913D-02,0.4075D-02,0.4238D-02,0.4408D-02,
     &0.4592D-02,0.4800D-02,0.5051D-02,0.5364D-02,0.5755D-02,0.6211D-02,
     &0.6262D-02,0.6311D-02,0.6359D-02,0.6403D-02,0.6446D-02,0.6484D-02,
     &0.6519D-02,0.6549D-02,0.6574D-02,0.6591D-02,0.6601D-02,0.6601D-02,
     &0.6590D-02,0.6564D-02,0.6521D-02,0.6456D-02,0.6363D-02,0.6231D-02,
     &0.6041D-02,0.5835D-02,0.5289D-02,0.4021D-02/
      DATA (XPV(I,6,2),I=1,100)/
     &0.9375D-01,0.8987D-01,0.8607D-01,0.8236D-01,0.7887D-01,0.7545D-01,
     &0.7213D-01,0.6900D-01,0.6595D-01,0.6296D-01,0.6017D-01,0.5744D-01,
     &0.5477D-01,0.5227D-01,0.4983D-01,0.4744D-01,0.4520D-01,0.4302D-01,
     &0.4089D-01,0.3889D-01,0.3695D-01,0.3504D-01,0.3326D-01,0.3151D-01,
     &0.2982D-01,0.2823D-01,0.2667D-01,0.2515D-01,0.2373D-01,0.2235D-01,
     &0.2100D-01,0.1972D-01,0.1849D-01,0.1729D-01,0.1614D-01,0.1505D-01,
     &0.1400D-01,0.1299D-01,0.1202D-01,0.1110D-01,0.1023D-01,0.9390D-02,
     &0.8591D-02,0.7874D-02,0.7152D-02,0.6483D-02,0.5870D-02,0.5295D-02,
     &0.4756D-02,0.4268D-02,0.3824D-02,0.3427D-02,0.3075D-02,0.2770D-02,
     &0.2501D-02,0.2282D-02,0.2106D-02,0.1968D-02,0.1869D-02,0.1802D-02,
     &0.1766D-02,0.1756D-02,0.1768D-02,0.1797D-02,0.1838D-02,0.1888D-02,
     &0.1942D-02,0.1997D-02,0.2048D-02,0.2094D-02,0.2132D-02,0.2160D-02,
     &0.2176D-02,0.2180D-02,0.2171D-02,0.2150D-02,0.2114D-02,0.2055D-02,
     &0.2046D-02,0.2037D-02,0.2026D-02,0.2015D-02,0.2003D-02,0.1990D-02,
     &0.1976D-02,0.1960D-02,0.1943D-02,0.1924D-02,0.1903D-02,0.1879D-02,
     &0.1852D-02,0.1822D-02,0.1788D-02,0.1748D-02,0.1701D-02,0.1644D-02,
     &0.1574D-02,0.1500D-02,0.1342D-02,0.1006D-02/
      DATA (XPV(I,6,3),I=1,100)/
     &0.9417D-01,0.9031D-01,0.8652D-01,0.8282D-01,0.7935D-01,0.7595D-01,
     &0.7264D-01,0.6954D-01,0.6651D-01,0.6354D-01,0.6076D-01,0.5805D-01,
     &0.5540D-01,0.5292D-01,0.5050D-01,0.4814D-01,0.4593D-01,0.4376D-01,
     &0.4166D-01,0.3968D-01,0.3777D-01,0.3588D-01,0.3413D-01,0.3240D-01,
     &0.3074D-01,0.2917D-01,0.2764D-01,0.2614D-01,0.2474D-01,0.2339D-01,
     &0.2206D-01,0.2080D-01,0.1960D-01,0.1843D-01,0.1730D-01,0.1623D-01,
     &0.1520D-01,0.1420D-01,0.1324D-01,0.1234D-01,0.1147D-01,0.1064D-01,
     &0.9841D-02,0.9125D-02,0.8394D-02,0.7713D-02,0.7085D-02,0.6486D-02,
     &0.5916D-02,0.5390D-02,0.4900D-02,0.4449D-02,0.4033D-02,0.3655D-02,
     &0.3301D-02,0.2989D-02,0.2709D-02,0.2456D-02,0.2232D-02,0.2031D-02,
     &0.1851D-02,0.1692D-02,0.1550D-02,0.1421D-02,0.1305D-02,0.1201D-02,
     &0.1109D-02,0.1030D-02,0.9637D-03,0.9133D-03,0.8806D-03,0.8682D-03,
     &0.8786D-03,0.9148D-03,0.9803D-03,0.1079D-02,0.1214D-02,0.1381D-02,
     &0.1401D-02,0.1420D-02,0.1439D-02,0.1457D-02,0.1475D-02,0.1492D-02,
     &0.1508D-02,0.1523D-02,0.1537D-02,0.1549D-02,0.1559D-02,0.1567D-02,
     &0.1572D-02,0.1573D-02,0.1570D-02,0.1562D-02,0.1546D-02,0.1521D-02,
     &0.1481D-02,0.1437D-02,0.1308D-02,0.1001D-02/
      DATA (XPV(I,6,4),I=1,100)/
     &0.9387D-01,0.9000D-01,0.8620D-01,0.8249D-01,0.7901D-01,0.7560D-01,
     &0.7228D-01,0.6916D-01,0.6611D-01,0.6313D-01,0.6034D-01,0.5762D-01,
     &0.5495D-01,0.5246D-01,0.5002D-01,0.4764D-01,0.4541D-01,0.4324D-01,
     &0.4112D-01,0.3912D-01,0.3719D-01,0.3528D-01,0.3351D-01,0.3177D-01,
     &0.3009D-01,0.2850D-01,0.2695D-01,0.2544D-01,0.2402D-01,0.2265D-01,
     &0.2131D-01,0.2003D-01,0.1881D-01,0.1763D-01,0.1648D-01,0.1540D-01,
     &0.1436D-01,0.1335D-01,0.1239D-01,0.1148D-01,0.1061D-01,0.9775D-02,
     &0.8982D-02,0.8272D-02,0.7555D-02,0.6890D-02,0.6283D-02,0.5712D-02,
     &0.5175D-02,0.4690D-02,0.4249D-02,0.3854D-02,0.3504D-02,0.3199D-02,
     &0.2930D-02,0.2712D-02,0.2536D-02,0.2398D-02,0.2298D-02,0.2232D-02,
     &0.2197D-02,0.2189D-02,0.2207D-02,0.2243D-02,0.2296D-02,0.2364D-02,
     &0.2444D-02,0.2535D-02,0.2639D-02,0.2757D-02,0.2893D-02,0.3057D-02,
     &0.3260D-02,0.3518D-02,0.3853D-02,0.4291D-02,0.4854D-02,0.5537D-02,
     &0.5617D-02,0.5695D-02,0.5771D-02,0.5846D-02,0.5918D-02,0.5987D-02,
     &0.6052D-02,0.6113D-02,0.6168D-02,0.6217D-02,0.6258D-02,0.6289D-02,
     &0.6309D-02,0.6315D-02,0.6304D-02,0.6270D-02,0.6208D-02,0.6107D-02,
     &0.5948D-02,0.5772D-02,0.5256D-02,0.4016D-02/
      DATA (XPV(I,7,0),I=1,100)/
     &0.4620D+01,0.4371D+01,0.4130D+01,0.3898D+01,0.3682D+01,0.3473D+01,
     &0.3273D+01,0.3087D+01,0.2908D+01,0.2735D+01,0.2576D+01,0.2422D+01,
     &0.2274D+01,0.2137D+01,0.2006D+01,0.1879D+01,0.1763D+01,0.1651D+01,
     &0.1544D+01,0.1444D+01,0.1350D+01,0.1258D+01,0.1175D+01,0.1095D+01,
     &0.1018D+01,0.9480D+00,0.8808D+00,0.8166D+00,0.7576D+00,0.7016D+00,
     &0.6483D+00,0.5987D+00,0.5524D+00,0.5085D+00,0.4671D+00,0.4289D+00,
     &0.3930D+00,0.3591D+00,0.3276D+00,0.2984D+00,0.2712D+00,0.2456D+00,
     &0.2218D+00,0.2008D+00,0.1801D+00,0.1612D+00,0.1440D+00,0.1281D+00,
     &0.1133D+00,0.9995D-01,0.8778D-01,0.7678D-01,0.6687D-01,0.5803D-01,
     &0.5000D-01,0.4309D-01,0.3706D-01,0.3181D-01,0.2732D-01,0.2349D-01,
     &0.2025D-01,0.1754D-01,0.1529D-01,0.1336D-01,0.1174D-01,0.1033D-01,
     &0.9116D-02,0.8022D-02,0.7032D-02,0.6118D-02,0.5270D-02,0.4476D-02,
     &0.3736D-02,0.3047D-02,0.2407D-02,0.1812D-02,0.1266D-02,0.7693D-03,
     &0.7181D-03,0.6683D-03,0.6199D-03,0.5730D-03,0.5276D-03,0.4835D-03,
     &0.4405D-03,0.3993D-03,0.3595D-03,0.3212D-03,0.2843D-03,0.2490D-03,
     &0.2153D-03,0.1832D-03,0.1528D-03,0.1242D-03,0.9750D-04,0.7288D-04,
     &0.5054D-04,0.3065D-04,0.1424D-04,0.2274D-05/
      DATA (XPV(I,7,1),I=1,100)/
     &0.1273D+00,0.1215D+00,0.1159D+00,0.1104D+00,0.1052D+00,0.1002D+00,
     &0.9538D-01,0.9084D-01,0.8644D-01,0.8214D-01,0.7814D-01,0.7426D-01,
     &0.7047D-01,0.6695D-01,0.6352D-01,0.6020D-01,0.5710D-01,0.5408D-01,
     &0.5116D-01,0.4843D-01,0.4580D-01,0.4321D-01,0.4083D-01,0.3850D-01,
     &0.3626D-01,0.3416D-01,0.3213D-01,0.3016D-01,0.2832D-01,0.2655D-01,
     &0.2484D-01,0.2322D-01,0.2168D-01,0.2020D-01,0.1878D-01,0.1745D-01,
     &0.1618D-01,0.1496D-01,0.1381D-01,0.1273D-01,0.1172D-01,0.1075D-01,
     &0.9841D-02,0.9037D-02,0.8237D-02,0.7506D-02,0.6849D-02,0.6244D-02,
     &0.5686D-02,0.5195D-02,0.4761D-02,0.4386D-02,0.4068D-02,0.3807D-02,
     &0.3592D-02,0.3439D-02,0.3337D-02,0.3281D-02,0.3270D-02,0.3299D-02,
     &0.3364D-02,0.3460D-02,0.3582D-02,0.3724D-02,0.3881D-02,0.4050D-02,
     &0.4225D-02,0.4404D-02,0.4584D-02,0.4766D-02,0.4952D-02,0.5148D-02,
     &0.5364D-02,0.5615D-02,0.5922D-02,0.6309D-02,0.6796D-02,0.7362D-02,
     &0.7425D-02,0.7486D-02,0.7545D-02,0.7600D-02,0.7653D-02,0.7701D-02,
     &0.7744D-02,0.7781D-02,0.7812D-02,0.7833D-02,0.7846D-02,0.7846D-02,
     &0.7833D-02,0.7803D-02,0.7751D-02,0.7673D-02,0.7561D-02,0.7402D-02,
     &0.7174D-02,0.6925D-02,0.6273D-02,0.4767D-02/
      DATA (XPV(I,7,2),I=1,100)/
     &0.1273D+00,0.1215D+00,0.1158D+00,0.1104D+00,0.1052D+00,0.1002D+00,
     &0.9537D-01,0.9083D-01,0.8643D-01,0.8213D-01,0.7813D-01,0.7424D-01,
     &0.7046D-01,0.6693D-01,0.6351D-01,0.6018D-01,0.5707D-01,0.5406D-01,
     &0.5113D-01,0.4840D-01,0.4576D-01,0.4318D-01,0.4079D-01,0.3846D-01,
     &0.3621D-01,0.3411D-01,0.3207D-01,0.3009D-01,0.2825D-01,0.2647D-01,
     &0.2475D-01,0.2312D-01,0.2157D-01,0.2008D-01,0.1865D-01,0.1730D-01,
     &0.1602D-01,0.1478D-01,0.1362D-01,0.1252D-01,0.1148D-01,0.1049D-01,
     &0.9553D-02,0.8720D-02,0.7889D-02,0.7124D-02,0.6429D-02,0.5782D-02,
     &0.5181D-02,0.4640D-02,0.4154D-02,0.3722D-02,0.3342D-02,0.3014D-02,
     &0.2728D-02,0.2498D-02,0.2314D-02,0.2171D-02,0.2067D-02,0.1998D-02,
     &0.1960D-02,0.1948D-02,0.1958D-02,0.1984D-02,0.2021D-02,0.2066D-02,
     &0.2114D-02,0.2162D-02,0.2206D-02,0.2245D-02,0.2275D-02,0.2296D-02,
     &0.2307D-02,0.2309D-02,0.2304D-02,0.2293D-02,0.2279D-02,0.2254D-02,
     &0.2250D-02,0.2244D-02,0.2239D-02,0.2232D-02,0.2225D-02,0.2216D-02,
     &0.2207D-02,0.2195D-02,0.2183D-02,0.2168D-02,0.2151D-02,0.2131D-02,
     &0.2108D-02,0.2081D-02,0.2049D-02,0.2010D-02,0.1964D-02,0.1906D-02,
     &0.1832D-02,0.1753D-02,0.1576D-02,0.1190D-02/
      DATA (XPV(I,7,3),I=1,100)/
     &0.1277D+00,0.1220D+00,0.1163D+00,0.1108D+00,0.1057D+00,0.1007D+00,
     &0.9591D-01,0.9139D-01,0.8700D-01,0.8272D-01,0.7874D-01,0.7488D-01,
     &0.7111D-01,0.6761D-01,0.6420D-01,0.6090D-01,0.5781D-01,0.5482D-01,
     &0.5192D-01,0.4921D-01,0.4660D-01,0.4403D-01,0.4167D-01,0.3937D-01,
     &0.3714D-01,0.3506D-01,0.3305D-01,0.3110D-01,0.2928D-01,0.2752D-01,
     &0.2582D-01,0.2422D-01,0.2269D-01,0.2122D-01,0.1980D-01,0.1848D-01,
     &0.1721D-01,0.1598D-01,0.1483D-01,0.1374D-01,0.1270D-01,0.1171D-01,
     &0.1077D-01,0.9936D-02,0.9091D-02,0.8309D-02,0.7592D-02,0.6916D-02,
     &0.6277D-02,0.5693D-02,0.5155D-02,0.4662D-02,0.4213D-02,0.3808D-02,
     &0.3432D-02,0.3104D-02,0.2813D-02,0.2553D-02,0.2325D-02,0.2122D-02,
     &0.1944D-02,0.1788D-02,0.1651D-02,0.1528D-02,0.1420D-02,0.1325D-02,
     &0.1243D-02,0.1175D-02,0.1122D-02,0.1084D-02,0.1065D-02,0.1067D-02,
     &0.1092D-02,0.1144D-02,0.1228D-02,0.1347D-02,0.1506D-02,0.1698D-02,
     &0.1720D-02,0.1741D-02,0.1763D-02,0.1783D-02,0.1803D-02,0.1821D-02,
     &0.1838D-02,0.1854D-02,0.1868D-02,0.1880D-02,0.1890D-02,0.1897D-02,
     &0.1900D-02,0.1898D-02,0.1892D-02,0.1878D-02,0.1856D-02,0.1823D-02,
     &0.1771D-02,0.1715D-02,0.1557D-02,0.1187D-02/
      DATA (XPV(I,7,4),I=1,100)/
     &0.1274D+00,0.1216D+00,0.1160D+00,0.1105D+00,0.1054D+00,0.1004D+00,
     &0.9553D-01,0.9099D-01,0.8660D-01,0.8231D-01,0.7831D-01,0.7443D-01,
     &0.7065D-01,0.6713D-01,0.6371D-01,0.6039D-01,0.5729D-01,0.5428D-01,
     &0.5137D-01,0.4864D-01,0.4601D-01,0.4343D-01,0.4105D-01,0.3873D-01,
     &0.3649D-01,0.3439D-01,0.3236D-01,0.3039D-01,0.2856D-01,0.2679D-01,
     &0.2507D-01,0.2345D-01,0.2191D-01,0.2043D-01,0.1901D-01,0.1767D-01,
     &0.1640D-01,0.1517D-01,0.1401D-01,0.1293D-01,0.1190D-01,0.1091D-01,
     &0.9989D-02,0.9167D-02,0.8345D-02,0.7590D-02,0.6907D-02,0.6271D-02,
     &0.5680D-02,0.5152D-02,0.4677D-02,0.4258D-02,0.3891D-02,0.3578D-02,
     &0.3306D-02,0.3092D-02,0.2925D-02,0.2801D-02,0.2718D-02,0.2672D-02,
     &0.2660D-02,0.2677D-02,0.2720D-02,0.2784D-02,0.2866D-02,0.2964D-02,
     &0.3075D-02,0.3198D-02,0.3335D-02,0.3488D-02,0.3663D-02,0.3870D-02,
     &0.4121D-02,0.4436D-02,0.4840D-02,0.5361D-02,0.6022D-02,0.6806D-02,
     &0.6896D-02,0.6983D-02,0.7069D-02,0.7151D-02,0.7230D-02,0.7305D-02,
     &0.7376D-02,0.7439D-02,0.7497D-02,0.7546D-02,0.7585D-02,0.7612D-02,
     &0.7625D-02,0.7620D-02,0.7595D-02,0.7541D-02,0.7454D-02,0.7319D-02,
     &0.7113D-02,0.6886D-02,0.6254D-02,0.4765D-02/
C..fetching pdfs
      DATA XMIN/1.D-04/,XMAX/1./
      IF ((X.LT.XMIN).OR.(X.GE.XMAX)) THEN
        WRITE(6,*) 'LAC: x outside the range, x= ',X
        RETURN
      ENDIF
      DO  5 IP=0,5
        XPDF(IP)=0.
 5    CONTINUE
      DO 2 I=1,IX
        ENT(I)=LOG10(XT(I))
  2   CONTINUE
      NA(1)=IX
      NA(2)=IQ
      DO 3 I=1,IQ
        ENT(IX+I)=LOG10(Q2T(I))
   3  CONTINUE
      ARG(1)=LOG10(X)
      ARG(2)=LOG10(Q2)
C..VARIOUS FLAVOURS (u-->2,d-->1)
      XPDF(0)=PHFINT(NARG,ARG,NA,ENT,XPV(1,1,0))
      XPDF(1)=PHFINT(NARG,ARG,NA,ENT,XPV(1,1,2))
      XPDF(2)=PHFINT(NARG,ARG,NA,ENT,XPV(1,1,1))
      XPDF(3)=PHFINT(NARG,ARG,NA,ENT,XPV(1,1,3))
      XPDF(4)=PHFINT(NARG,ARG,NA,ENT,XPV(1,1,4))
      RETURN
      END
C--------------------------------------------------------------
      SUBROUTINE PHLAC3(X,Q2,XPDF)
      IMPLICIT REAL*8(A-H,O-Z)
      PARAMETER(IX=100,IQ=7,NARG=2,NFUN=4)
      DIMENSION XT(IX),Q2T(IQ),ARG(NARG),NA(NARG),ENT(IX+IQ)
      DIMENSION XPV(IX,IQ,0:NFUN),XPDF(0:5)
C...100 x valuse; in (D-4,.77) log spaced (78 points)
C...              in (.78,.995) lineary spaced (22 points)
      DATA Q2T/1.,10.,50.,1.D2,1.D3,1.D4,1.D5/
      DATA  XT/
     &0.1000D-03,0.1123D-03,0.1262D-03,0.1417D-03,0.1592D-03,0.1789D-03,
     &0.2009D-03,0.2257D-03,0.2535D-03,0.2848D-03,0.3199D-03,0.3593D-03,
     &0.4037D-03,0.4534D-03,0.5093D-03,0.5722D-03,0.6427D-03,0.7220D-03,
     &0.8110D-03,0.9110D-03,0.1023D-02,0.1150D-02,0.1291D-02,0.1451D-02,
     &0.1629D-02,0.1830D-02,0.2056D-02,0.2310D-02,0.2594D-02,0.2914D-02,
     &0.3274D-02,0.3677D-02,0.4131D-02,0.4640D-02,0.5212D-02,0.5855D-02,
     &0.6577D-02,0.7388D-02,0.8299D-02,0.9323D-02,0.1047D-01,0.1176D-01,
     &0.1321D-01,0.1484D-01,0.1667D-01,0.1873D-01,0.2104D-01,0.2363D-01,
     &0.2655D-01,0.2982D-01,0.3350D-01,0.3763D-01,0.4227D-01,0.4748D-01,
     &0.5334D-01,0.5992D-01,0.6731D-01,0.7560D-01,0.8493D-01,0.9540D-01,
     &0.1072D+00,0.1204D+00,0.1352D+00,0.1519D+00,0.1706D+00,0.1917D+00,
     &0.2153D+00,0.2419D+00,0.2717D+00,0.3052D+00,0.3428D+00,0.3851D+00,
     &0.4326D+00,0.4859D+00,0.5458D+00,0.6131D+00,0.6887D+00,0.7737D+00,
     &0.7837D+00,0.7937D+00,0.8037D+00,0.8137D+00,0.8237D+00,0.8337D+00,
     &0.8437D+00,0.8537D+00,0.8637D+00,0.8737D+00,0.8837D+00,0.8937D+00,
     &0.9037D+00,0.9137D+00,0.9237D+00,0.9337D+00,0.9437D+00,0.9537D+00,
     &0.9637D+00,0.9737D+00,0.9837D+00,0.9937D+00/
C...place for DATA blocks
      DATA (XPV(I,1,0),I=1,100)/
     &0.1007D-27,0.2075D-27,0.4426D-27,0.1128D-26,0.2333D-26,0.4999D-26,
     &0.1271D-25,0.2627D-25,0.5632D-25,0.1431D-24,0.2954D-24,0.6358D-24,
     &0.1610D-23,0.3324D-23,0.7182D-23,0.1813D-22,0.3751D-22,0.8117D-22,
     &0.2043D-21,0.4240D-21,0.9144D-21,0.2316D-20,0.4799D-20,0.1038D-19,
     &0.2610D-19,0.5465D-19,0.1173D-18,0.2878D-18,0.6255D-18,0.1334D-17,
     &0.3132D-17,0.7205D-17,0.1536D-16,0.3447D-16,0.8339D-16,0.1787D-15,
     &0.3904D-15,0.9044D-15,0.2099D-14,0.4566D-14,0.1007D-13,0.2303D-13,
     &0.5384D-13,0.1169D-12,0.2617D-12,0.5847D-12,0.1299D-11,0.2924D-11,
     &0.6607D-11,0.1484D-10,0.3329D-10,0.7451D-10,0.1668D-09,0.3728D-09,
     &0.8458D-09,0.1887D-08,0.4199D-08,0.9410D-08,0.2093D-07,0.4670D-07,
     &0.1044D-06,0.2319D-06,0.5128D-06,0.1139D-05,0.2523D-05,0.5592D-05,
     &0.1232D-04,0.2713D-04,0.5944D-04,0.1298D-03,0.2819D-03,0.6094D-03,
     &0.1307D-02,0.2770D-02,0.5792D-02,0.1188D-01,0.2357D-01,0.4425D-01,
     &0.4717D-01,0.5016D-01,0.5322D-01,0.5631D-01,0.5943D-01,0.6254D-01,
     &0.6564D-01,0.6864D-01,0.7153D-01,0.7424D-01,0.7672D-01,0.7888D-01,
     &0.8063D-01,0.8185D-01,0.8240D-01,0.8208D-01,0.8066D-01,0.7779D-01,
     &0.7302D-01,0.6561D-01,0.5572D-01,0.3029D-01/
      DATA (XPV(I,1,1),I=1,100)/
     &0.3424D-05,0.3802D-05,0.4225D-05,0.4691D-05,0.5211D-05,0.5789D-05,
     &0.6428D-05,0.7141D-05,0.7930D-05,0.8809D-05,0.9783D-05,0.1086D-04,
     &0.1207D-04,0.1340D-04,0.1488D-04,0.1653D-04,0.1836D-04,0.2039D-04,
     &0.2264D-04,0.2513D-04,0.2790D-04,0.3099D-04,0.3439D-04,0.3819D-04,
     &0.4236D-04,0.4701D-04,0.5217D-04,0.5789D-04,0.6419D-04,0.7118D-04,
     &0.7893D-04,0.8747D-04,0.9693D-04,0.1073D-03,0.1188D-03,0.1315D-03,
     &0.1455D-03,0.1608D-03,0.1777D-03,0.1962D-03,0.2163D-03,0.2384D-03,
     &0.2625D-03,0.2888D-03,0.3171D-03,0.3478D-03,0.3809D-03,0.4162D-03,
     &0.4540D-03,0.4939D-03,0.5361D-03,0.5801D-03,0.6258D-03,0.6727D-03,
     &0.7196D-03,0.7668D-03,0.8129D-03,0.8568D-03,0.8974D-03,0.9335D-03,
     &0.9636D-03,0.9862D-03,0.1001D-02,0.1005D-02,0.9999D-03,0.9845D-03,
     &0.9605D-03,0.9293D-03,0.8945D-03,0.8601D-03,0.8315D-03,0.8149D-03,
     &0.8173D-03,0.8465D-03,0.9115D-03,0.1023D-02,0.1196D-02,0.1446D-02,
     &0.1479D-02,0.1512D-02,0.1545D-02,0.1579D-02,0.1613D-02,0.1648D-02,
     &0.1682D-02,0.1716D-02,0.1750D-02,0.1784D-02,0.1816D-02,0.1848D-02,
     &0.1878D-02,0.1905D-02,0.1930D-02,0.1951D-02,0.1967D-02,0.1975D-02,
     &0.1973D-02,0.1954D-02,0.2080D-02,0.1381D-02/
      DATA (XPV(I,1,2),I=1,100)/
     &0.3137D-05,0.3480D-05,0.3862D-05,0.4284D-05,0.4753D-05,0.5276D-05,
     &0.5851D-05,0.6493D-05,0.7202D-05,0.7991D-05,0.8865D-05,0.9833D-05,
     &0.1091D-04,0.1210D-04,0.1342D-04,0.1489D-04,0.1651D-04,0.1831D-04,
     &0.2031D-04,0.2252D-04,0.2496D-04,0.2770D-04,0.3069D-04,0.3403D-04,
     &0.3770D-04,0.4178D-04,0.4629D-04,0.5128D-04,0.5678D-04,0.6286D-04,
     &0.6959D-04,0.7699D-04,0.8517D-04,0.9415D-04,0.1040D-03,0.1149D-03,
     &0.1269D-03,0.1400D-03,0.1543D-03,0.1699D-03,0.1870D-03,0.2055D-03,
     &0.2256D-03,0.2475D-03,0.2709D-03,0.2962D-03,0.3232D-03,0.3518D-03,
     &0.3821D-03,0.4137D-03,0.4468D-03,0.4807D-03,0.5153D-03,0.5499D-03,
     &0.5835D-03,0.6162D-03,0.6464D-03,0.6732D-03,0.6954D-03,0.7116D-03,
     &0.7207D-03,0.7212D-03,0.7125D-03,0.6928D-03,0.6625D-03,0.6217D-03,
     &0.5720D-03,0.5149D-03,0.4540D-03,0.3931D-03,0.3368D-03,0.2895D-03,
     &0.2557D-03,0.2384D-03,0.2393D-03,0.2595D-03,0.2999D-03,0.3616D-03,
     &0.3697D-03,0.3780D-03,0.3863D-03,0.3948D-03,0.4033D-03,0.4119D-03,
     &0.4205D-03,0.4291D-03,0.4376D-03,0.4459D-03,0.4541D-03,0.4619D-03,
     &0.4694D-03,0.4763D-03,0.4825D-03,0.4878D-03,0.4917D-03,0.4938D-03,
     &0.4932D-03,0.4886D-03,0.5200D-03,0.3453D-03/
      DATA (XPV(I,1,3),I=1,100)/
     &0.2308D-04,0.2495D-04,0.2699D-04,0.2918D-04,0.3156D-04,0.3413D-04,
     &0.3690D-04,0.3990D-04,0.4315D-04,0.4666D-04,0.5045D-04,0.5454D-04,
     &0.5898D-04,0.6376D-04,0.6894D-04,0.7454D-04,0.8058D-04,0.8711D-04,
     &0.9416D-04,0.1018D-03,0.1100D-03,0.1189D-03,0.1284D-03,0.1388D-03,
     &0.1499D-03,0.1620D-03,0.1749D-03,0.1889D-03,0.2039D-03,0.2201D-03,
     &0.2376D-03,0.2562D-03,0.2763D-03,0.2979D-03,0.3210D-03,0.3457D-03,
     &0.3721D-03,0.4003D-03,0.4303D-03,0.4623D-03,0.4961D-03,0.5318D-03,
     &0.5697D-03,0.6100D-03,0.6513D-03,0.6947D-03,0.7400D-03,0.7864D-03,
     &0.8337D-03,0.8816D-03,0.9298D-03,0.9773D-03,0.1024D-02,0.1068D-02,
     &0.1107D-02,0.1144D-02,0.1174D-02,0.1196D-02,0.1210D-02,0.1213D-02,
     &0.1203D-02,0.1180D-02,0.1144D-02,0.1091D-02,0.1024D-02,0.9420D-03,
     &0.8495D-03,0.7483D-03,0.6436D-03,0.5407D-03,0.4459D-03,0.3649D-03,
     &0.3034D-03,0.2653D-03,0.2522D-03,0.2644D-03,0.3011D-03,0.3617D-03,
     &0.3698D-03,0.3781D-03,0.3864D-03,0.3948D-03,0.4034D-03,0.4119D-03,
     &0.4205D-03,0.4291D-03,0.4376D-03,0.4459D-03,0.4541D-03,0.4619D-03,
     &0.4694D-03,0.4763D-03,0.4825D-03,0.4878D-03,0.4917D-03,0.4938D-03,
     &0.4932D-03,0.4886D-03,0.5200D-03,0.3453D-03/
      DATA (XPV(I,1,4),I=1,100)/
     &0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,
     &0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,
     &0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,
     &0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,
     &0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,
     &0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,
     &0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,
     &0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,
     &0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,
     &0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,
     &0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,
     &0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,
     &0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,
     &0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,
     &0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,
     &0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00,
     &0.0000D+00,0.0000D+00,0.0000D+00,0.0000D+00/
      DATA (XPV(I,2,0),I=1,100)/
     &0.1356D+00,0.1323D+00,0.1291D+00,0.1259D+00,0.1228D+00,0.1197D+00,
     &0.1167D+00,0.1138D+00,0.1109D+00,0.1080D+00,0.1053D+00,0.1026D+00,
     &0.9987D-01,0.9730D-01,0.9474D-01,0.9219D-01,0.8977D-01,0.8736D-01,
     &0.8497D-01,0.8269D-01,0.8043D-01,0.7816D-01,0.7603D-01,0.7390D-01,
     &0.7178D-01,0.6977D-01,0.6777D-01,0.6577D-01,0.6388D-01,0.6200D-01,
     &0.6014D-01,0.5833D-01,0.5657D-01,0.5483D-01,0.5311D-01,0.5146D-01,
     &0.4983D-01,0.4821D-01,0.4664D-01,0.4512D-01,0.4362D-01,0.4214D-01,
     &0.4069D-01,0.3940D-01,0.3797D-01,0.3660D-01,0.3532D-01,0.3404D-01,
     &0.3275D-01,0.3151D-01,0.3030D-01,0.2912D-01,0.2796D-01,0.2684D-01,
     &0.2569D-01,0.2463D-01,0.2359D-01,0.2257D-01,0.2160D-01,0.2066D-01,
     &0.1976D-01,0.1891D-01,0.1812D-01,0.1738D-01,0.1671D-01,0.1612D-01,
     &0.1563D-01,0.1526D-01,0.1503D-01,0.1498D-01,0.1516D-01,0.1561D-01,
     &0.1641D-01,0.1763D-01,0.1929D-01,0.2127D-01,0.2302D-01,0.2306D-01,
     &0.2284D-01,0.2255D-01,0.2220D-01,0.2178D-01,0.2128D-01,0.2071D-01,
     &0.2004D-01,0.1930D-01,0.1846D-01,0.1753D-01,0.1651D-01,0.1539D-01,
     &0.1417D-01,0.1285D-01,0.1144D-01,0.9945D-02,0.8364D-02,0.6719D-02,
     &0.5030D-02,0.3305D-02,0.1711D-02,0.2728D-03/
      DATA (XPV(I,2,1),I=1,100)/
     &0.1580D-02,0.1552D-02,0.1523D-02,0.1495D-02,0.1467D-02,0.1440D-02,
     &0.1413D-02,0.1387D-02,0.1362D-02,0.1336D-02,0.1312D-02,0.1288D-02,
     &0.1264D-02,0.1241D-02,0.1219D-02,0.1197D-02,0.1176D-02,0.1155D-02,
     &0.1135D-02,0.1117D-02,0.1098D-02,0.1080D-02,0.1064D-02,0.1049D-02,
     &0.1034D-02,0.1020D-02,0.1008D-02,0.9958D-03,0.9857D-03,0.9769D-03,
     &0.9690D-03,0.9629D-03,0.9585D-03,0.9556D-03,0.9542D-03,0.9553D-03,
     &0.9582D-03,0.9630D-03,0.9702D-03,0.9801D-03,0.9924D-03,0.1007D-02,
     &0.1025D-02,0.1048D-02,0.1070D-02,0.1097D-02,0.1127D-02,0.1160D-02,
     &0.1196D-02,0.1235D-02,0.1276D-02,0.1320D-02,0.1366D-02,0.1414D-02,
     &0.1462D-02,0.1511D-02,0.1560D-02,0.1607D-02,0.1653D-02,0.1695D-02,
     &0.1734D-02,0.1768D-02,0.1797D-02,0.1821D-02,0.1840D-02,0.1856D-02,
     &0.1870D-02,0.1884D-02,0.1902D-02,0.1930D-02,0.1971D-02,0.2031D-02,
     &0.2118D-02,0.2236D-02,0.2391D-02,0.2582D-02,0.2803D-02,0.3029D-02,
     &0.3052D-02,0.3073D-02,0.3094D-02,0.3113D-02,0.3130D-02,0.3145D-02,
     &0.3158D-02,0.3169D-02,0.3176D-02,0.3181D-02,0.3181D-02,0.3178D-02,
     &0.3168D-02,0.3153D-02,0.3129D-02,0.3095D-02,0.3049D-02,0.2984D-02,
     &0.2897D-02,0.2785D-02,0.2548D-02,0.2093D-02/
      DATA (XPV(I,2,2),I=1,100)/
     &0.1579D-02,0.1550D-02,0.1522D-02,0.1493D-02,0.1465D-02,0.1438D-02,
     &0.1410D-02,0.1384D-02,0.1358D-02,0.1332D-02,0.1308D-02,0.1283D-02,
     &0.1259D-02,0.1236D-02,0.1213D-02,0.1190D-02,0.1168D-02,0.1147D-02,
     &0.1126D-02,0.1107D-02,0.1087D-02,0.1068D-02,0.1051D-02,0.1033D-02,
     &0.1017D-02,0.1001D-02,0.9867D-03,0.9726D-03,0.9600D-03,0.9484D-03,
     &0.9374D-03,0.9279D-03,0.9197D-03,0.9125D-03,0.9065D-03,0.9024D-03,
     &0.8996D-03,0.8981D-03,0.8984D-03,0.9006D-03,0.9045D-03,0.9099D-03,
     &0.9175D-03,0.9288D-03,0.9391D-03,0.9521D-03,0.9677D-03,0.9844D-03,
     &0.1002D-02,0.1021D-02,0.1041D-02,0.1062D-02,0.1083D-02,0.1104D-02,
     &0.1122D-02,0.1140D-02,0.1155D-02,0.1167D-02,0.1174D-02,0.1176D-02,
     &0.1172D-02,0.1162D-02,0.1145D-02,0.1122D-02,0.1092D-02,0.1058D-02,
     &0.1021D-02,0.9837D-03,0.9493D-03,0.9211D-03,0.9026D-03,0.8966D-03,
     &0.9045D-03,0.9256D-03,0.9554D-03,0.9845D-03,0.9981D-03,0.9751D-03,
     &0.9694D-03,0.9631D-03,0.9561D-03,0.9485D-03,0.9402D-03,0.9313D-03,
     &0.9217D-03,0.9114D-03,0.9006D-03,0.8890D-03,0.8766D-03,0.8634D-03,
     &0.8493D-03,0.8341D-03,0.8175D-03,0.7990D-03,0.7783D-03,0.7539D-03,
     &0.7241D-03,0.6938D-03,0.6252D-03,0.4746D-03/
      DATA (XPV(I,2,3),I=1,100)/
     &0.1607D-02,0.1581D-02,0.1554D-02,0.1528D-02,0.1503D-02,0.1478D-02,
     &0.1454D-02,0.1431D-02,0.1408D-02,0.1386D-02,0.1365D-02,0.1344D-02,
     &0.1324D-02,0.1306D-02,0.1288D-02,0.1270D-02,0.1254D-02,0.1239D-02,
     &0.1224D-02,0.1211D-02,0.1198D-02,0.1186D-02,0.1177D-02,0.1168D-02,
     &0.1160D-02,0.1154D-02,0.1149D-02,0.1145D-02,0.1143D-02,0.1142D-02,
     &0.1143D-02,0.1145D-02,0.1150D-02,0.1156D-02,0.1163D-02,0.1173D-02,
     &0.1185D-02,0.1198D-02,0.1214D-02,0.1231D-02,0.1250D-02,0.1271D-02,
     &0.1294D-02,0.1321D-02,0.1346D-02,0.1373D-02,0.1403D-02,0.1432D-02,
     &0.1461D-02,0.1490D-02,0.1518D-02,0.1545D-02,0.1570D-02,0.1592D-02,
     &0.1607D-02,0.1620D-02,0.1626D-02,0.1625D-02,0.1616D-02,0.1598D-02,
     &0.1569D-02,0.1531D-02,0.1485D-02,0.1427D-02,0.1362D-02,0.1290D-02,
     &0.1216D-02,0.1143D-02,0.1074D-02,0.1015D-02,0.9689D-03,0.9403D-03,
     &0.9308D-03,0.9395D-03,0.9616D-03,0.9867D-03,0.9986D-03,0.9752D-03,
     &0.9695D-03,0.9631D-03,0.9561D-03,0.9485D-03,0.9402D-03,0.9313D-03,
     &0.9217D-03,0.9114D-03,0.9006D-03,0.8890D-03,0.8766D-03,0.8634D-03,
     &0.8493D-03,0.8341D-03,0.8175D-03,0.7990D-03,0.7783D-03,0.7539D-03,
     &0.7241D-03,0.6938D-03,0.6252D-03,0.4746D-03/
      DATA (XPV(I,2,4),I=1,100)/
     &0.1415D-02,0.1387D-02,0.1359D-02,0.1331D-02,0.1305D-02,0.1278D-02,
     &0.1251D-02,0.1225D-02,0.1199D-02,0.1173D-02,0.1149D-02,0.1124D-02,
     &0.1099D-02,0.1076D-02,0.1052D-02,0.1028D-02,0.1006D-02,0.9831D-03,
     &0.9605D-03,0.9389D-03,0.9174D-03,0.8956D-03,0.8752D-03,0.8546D-03,
     &0.8341D-03,0.8146D-03,0.7951D-03,0.7757D-03,0.7572D-03,0.7389D-03,
     &0.7206D-03,0.7031D-03,0.6861D-03,0.6692D-03,0.6527D-03,0.6371D-03,
     &0.6218D-03,0.6068D-03,0.5925D-03,0.5789D-03,0.5660D-03,0.5535D-03,
     &0.5418D-03,0.5324D-03,0.5217D-03,0.5124D-03,0.5048D-03,0.4977D-03,
     &0.4913D-03,0.4863D-03,0.4825D-03,0.4799D-03,0.4788D-03,0.4791D-03,
     &0.4802D-03,0.4834D-03,0.4882D-03,0.4945D-03,0.5024D-03,0.5120D-03,
     &0.5231D-03,0.5359D-03,0.5503D-03,0.5660D-03,0.5831D-03,0.6017D-03,
     &0.6218D-03,0.6436D-03,0.6672D-03,0.6934D-03,0.7230D-03,0.7576D-03,
     &0.7992D-03,0.8507D-03,0.9158D-03,0.9997D-03,0.1110D-02,0.1257D-02,
     &0.1276D-02,0.1296D-02,0.1316D-02,0.1336D-02,0.1357D-02,0.1378D-02,
     &0.1400D-02,0.1421D-02,0.1443D-02,0.1465D-02,0.1488D-02,0.1509D-02,
     &0.1531D-02,0.1551D-02,0.1571D-02,0.1589D-02,0.1603D-02,0.1614D-02,
     &0.1612D-02,0.1626D-02,0.1559D-02,0.1269D-02/
      DATA (XPV(I,3,0),I=1,100)/
     &0.3292D+00,0.3189D+00,0.3087D+00,0.2986D+00,0.2890D+00,0.2796D+00,
     &0.2703D+00,0.2615D+00,0.2529D+00,0.2443D+00,0.2363D+00,0.2283D+00,
     &0.2205D+00,0.2131D+00,0.2058D+00,0.1986D+00,0.1918D+00,0.1851D+00,
     &0.1785D+00,0.1722D+00,0.1661D+00,0.1600D+00,0.1544D+00,0.1487D+00,
     &0.1432D+00,0.1380D+00,0.1329D+00,0.1278D+00,0.1231D+00,0.1184D+00,
     &0.1138D+00,0.1094D+00,0.1051D+00,0.1010D+00,0.9689D-01,0.9302D-01,
     &0.8924D-01,0.8553D-01,0.8196D-01,0.7853D-01,0.7521D-01,0.7196D-01,
     &0.6881D-01,0.6600D-01,0.6297D-01,0.6010D-01,0.5743D-01,0.5479D-01,
     &0.5218D-01,0.4969D-01,0.4729D-01,0.4498D-01,0.4274D-01,0.4060D-01,
     &0.3844D-01,0.3644D-01,0.3453D-01,0.3267D-01,0.3091D-01,0.2922D-01,
     &0.2762D-01,0.2611D-01,0.2471D-01,0.2338D-01,0.2216D-01,0.2105D-01,
     &0.2007D-01,0.1922D-01,0.1851D-01,0.1795D-01,0.1755D-01,0.1732D-01,
     &0.1724D-01,0.1727D-01,0.1727D-01,0.1699D-01,0.1590D-01,0.1312D-01,
     &0.1266D-01,0.1217D-01,0.1165D-01,0.1110D-01,0.1053D-01,0.9921D-02,
     &0.9286D-02,0.8628D-02,0.7952D-02,0.7250D-02,0.6536D-02,0.5804D-02,
     &0.5069D-02,0.4328D-02,0.3596D-02,0.2876D-02,0.2183D-02,0.1530D-02,
     &0.9314D-03,0.4198D-03,0.1184D-03,0.0000D+00/
      DATA (XPV(I,3,1),I=1,100)/
     &0.5070D-02,0.4938D-02,0.4806D-02,0.4675D-02,0.4552D-02,0.4429D-02,
     &0.4308D-02,0.4193D-02,0.4079D-02,0.3966D-02,0.3860D-02,0.3755D-02,
     &0.3650D-02,0.3552D-02,0.3454D-02,0.3358D-02,0.3268D-02,0.3178D-02,
     &0.3090D-02,0.3008D-02,0.2926D-02,0.2846D-02,0.2771D-02,0.2698D-02,
     &0.2626D-02,0.2559D-02,0.2494D-02,0.2430D-02,0.2371D-02,0.2315D-02,
     &0.2261D-02,0.2210D-02,0.2163D-02,0.2118D-02,0.2077D-02,0.2040D-02,
     &0.2006D-02,0.1975D-02,0.1948D-02,0.1926D-02,0.1907D-02,0.1892D-02,
     &0.1882D-02,0.1880D-02,0.1876D-02,0.1879D-02,0.1887D-02,0.1899D-02,
     &0.1914D-02,0.1934D-02,0.1958D-02,0.1986D-02,0.2017D-02,0.2051D-02,
     &0.2085D-02,0.2123D-02,0.2163D-02,0.2202D-02,0.2240D-02,0.2278D-02,
     &0.2314D-02,0.2347D-02,0.2379D-02,0.2407D-02,0.2433D-02,0.2459D-02,
     &0.2485D-02,0.2515D-02,0.2551D-02,0.2597D-02,0.2657D-02,0.2738D-02,
     &0.2843D-02,0.2978D-02,0.3148D-02,0.3354D-02,0.3592D-02,0.3839D-02,
     &0.3864D-02,0.3888D-02,0.3911D-02,0.3931D-02,0.3950D-02,0.3967D-02,
     &0.3980D-02,0.3991D-02,0.3999D-02,0.4002D-02,0.4000D-02,0.3993D-02,
     &0.3978D-02,0.3956D-02,0.3922D-02,0.3876D-02,0.3812D-02,0.3724D-02,
     &0.3606D-02,0.3465D-02,0.3134D-02,0.2451D-02/
      DATA (XPV(I,3,2),I=1,100)/
     &0.5067D-02,0.4935D-02,0.4803D-02,0.4672D-02,0.4548D-02,0.4425D-02,
     &0.4303D-02,0.4188D-02,0.4074D-02,0.3960D-02,0.3853D-02,0.3747D-02,
     &0.3642D-02,0.3543D-02,0.3445D-02,0.3347D-02,0.3256D-02,0.3165D-02,
     &0.3075D-02,0.2991D-02,0.2908D-02,0.2826D-02,0.2749D-02,0.2673D-02,
     &0.2599D-02,0.2529D-02,0.2461D-02,0.2393D-02,0.2331D-02,0.2270D-02,
     &0.2211D-02,0.2155D-02,0.2102D-02,0.2052D-02,0.2003D-02,0.1958D-02,
     &0.1916D-02,0.1876D-02,0.1839D-02,0.1805D-02,0.1774D-02,0.1746D-02,
     &0.1720D-02,0.1702D-02,0.1681D-02,0.1664D-02,0.1651D-02,0.1640D-02,
     &0.1629D-02,0.1622D-02,0.1616D-02,0.1612D-02,0.1608D-02,0.1605D-02,
     &0.1598D-02,0.1593D-02,0.1586D-02,0.1577D-02,0.1564D-02,0.1547D-02,
     &0.1525D-02,0.1499D-02,0.1470D-02,0.1434D-02,0.1396D-02,0.1355D-02,
     &0.1314D-02,0.1274D-02,0.1240D-02,0.1211D-02,0.1192D-02,0.1184D-02,
     &0.1185D-02,0.1194D-02,0.1206D-02,0.1211D-02,0.1198D-02,0.1157D-02,
     &0.1150D-02,0.1143D-02,0.1135D-02,0.1127D-02,0.1119D-02,0.1110D-02,
     &0.1101D-02,0.1091D-02,0.1081D-02,0.1070D-02,0.1059D-02,0.1046D-02,
     &0.1033D-02,0.1018D-02,0.1001D-02,0.9817D-03,0.9590D-03,0.9316D-03,
     &0.8950D-03,0.8607D-03,0.7722D-03,0.5564D-03/
      DATA (XPV(I,3,3),I=1,100)/
     &0.5100D-02,0.4971D-02,0.4841D-02,0.4713D-02,0.4592D-02,0.4472D-02,
     &0.4353D-02,0.4242D-02,0.4131D-02,0.4022D-02,0.3919D-02,0.3817D-02,
     &0.3716D-02,0.3622D-02,0.3529D-02,0.3438D-02,0.3352D-02,0.3268D-02,
     &0.3185D-02,0.3108D-02,0.3032D-02,0.2958D-02,0.2889D-02,0.2822D-02,
     &0.2757D-02,0.2696D-02,0.2638D-02,0.2582D-02,0.2530D-02,0.2481D-02,
     &0.2433D-02,0.2390D-02,0.2350D-02,0.2312D-02,0.2277D-02,0.2246D-02,
     &0.2218D-02,0.2192D-02,0.2169D-02,0.2150D-02,0.2133D-02,0.2119D-02,
     &0.2108D-02,0.2104D-02,0.2095D-02,0.2090D-02,0.2089D-02,0.2088D-02,
     &0.2086D-02,0.2085D-02,0.2084D-02,0.2082D-02,0.2079D-02,0.2073D-02,
     &0.2061D-02,0.2047D-02,0.2028D-02,0.2003D-02,0.1971D-02,0.1931D-02,
     &0.1884D-02,0.1830D-02,0.1769D-02,0.1701D-02,0.1628D-02,0.1553D-02,
     &0.1478D-02,0.1406D-02,0.1341D-02,0.1286D-02,0.1244D-02,0.1217D-02,
     &0.1205D-02,0.1204D-02,0.1210D-02,0.1212D-02,0.1199D-02,0.1157D-02,
     &0.1150D-02,0.1143D-02,0.1135D-02,0.1127D-02,0.1119D-02,0.1110D-02,
     &0.1101D-02,0.1091D-02,0.1081D-02,0.1070D-02,0.1059D-02,0.1046D-02,
     &0.1033D-02,0.1018D-02,0.1001D-02,0.9817D-03,0.9590D-03,0.9316D-03,
     &0.8950D-03,0.8607D-03,0.7722D-03,0.5564D-03/
      DATA (XPV(I,3,4),I=1,100)/
     &0.4904D-02,0.4772D-02,0.4641D-02,0.4511D-02,0.4387D-02,0.4264D-02,
     &0.4143D-02,0.4028D-02,0.3914D-02,0.3800D-02,0.3692D-02,0.3586D-02,
     &0.3480D-02,0.3380D-02,0.3281D-02,0.3182D-02,0.3089D-02,0.2997D-02,
     &0.2905D-02,0.2819D-02,0.2733D-02,0.2648D-02,0.2568D-02,0.2488D-02,
     &0.2409D-02,0.2335D-02,0.2261D-02,0.2189D-02,0.2120D-02,0.2052D-02,
     &0.1986D-02,0.1922D-02,0.1860D-02,0.1800D-02,0.1741D-02,0.1686D-02,
     &0.1632D-02,0.1579D-02,0.1529D-02,0.1481D-02,0.1435D-02,0.1391D-02,
     &0.1350D-02,0.1315D-02,0.1276D-02,0.1242D-02,0.1212D-02,0.1184D-02,
     &0.1157D-02,0.1135D-02,0.1115D-02,0.1098D-02,0.1085D-02,0.1075D-02,
     &0.1067D-02,0.1064D-02,0.1064D-02,0.1068D-02,0.1076D-02,0.1087D-02,
     &0.1101D-02,0.1119D-02,0.1141D-02,0.1165D-02,0.1193D-02,0.1223D-02,
     &0.1256D-02,0.1292D-02,0.1332D-02,0.1375D-02,0.1424D-02,0.1482D-02,
     &0.1551D-02,0.1637D-02,0.1748D-02,0.1896D-02,0.2095D-02,0.2365D-02,
     &0.2400D-02,0.2434D-02,0.2470D-02,0.2506D-02,0.2542D-02,0.2578D-02,
     &0.2614D-02,0.2649D-02,0.2685D-02,0.2718D-02,0.2752D-02,0.2783D-02,
     &0.2812D-02,0.2837D-02,0.2858D-02,0.2872D-02,0.2878D-02,0.2872D-02,
     &0.2841D-02,0.2821D-02,0.2656D-02,0.2138D-02/
      DATA (XPV(I,4,0),I=1,100)/
     &0.4299D+00,0.4154D+00,0.4011D+00,0.3870D+00,0.3736D+00,0.3605D+00,
     &0.3476D+00,0.3355D+00,0.3236D+00,0.3118D+00,0.3007D+00,0.2898D+00,
     &0.2791D+00,0.2690D+00,0.2591D+00,0.2494D+00,0.2402D+00,0.2312D+00,
     &0.2223D+00,0.2140D+00,0.2059D+00,0.1978D+00,0.1902D+00,0.1828D+00,
     &0.1755D+00,0.1687D+00,0.1619D+00,0.1553D+00,0.1491D+00,0.1430D+00,
     &0.1371D+00,0.1314D+00,0.1259D+00,0.1206D+00,0.1154D+00,0.1104D+00,
     &0.1056D+00,0.1009D+00,0.9641D-01,0.9210D-01,0.8793D-01,0.8386D-01,
     &0.7994D-01,0.7643D-01,0.7269D-01,0.6916D-01,0.6587D-01,0.6264D-01,
     &0.5946D-01,0.5644D-01,0.5353D-01,0.5074D-01,0.4805D-01,0.4548D-01,
     &0.4290D-01,0.4053D-01,0.3826D-01,0.3607D-01,0.3399D-01,0.3201D-01,
     &0.3012D-01,0.2836D-01,0.2672D-01,0.2516D-01,0.2372D-01,0.2241D-01,
     &0.2123D-01,0.2018D-01,0.1927D-01,0.1850D-01,0.1787D-01,0.1737D-01,
     &0.1696D-01,0.1658D-01,0.1608D-01,0.1522D-01,0.1354D-01,0.1041D-01,
     &0.9954D-02,0.9473D-02,0.8976D-02,0.8461D-02,0.7931D-02,0.7386D-02,
     &0.6825D-02,0.6255D-02,0.5681D-02,0.5098D-02,0.4516D-02,0.3934D-02,
     &0.3362D-02,0.2799D-02,0.2258D-02,0.1742D-02,0.1262D-02,0.8280D-03,
     &0.4482D-03,0.1620D-03,0.2992D-04,0.0000D+00/
      DATA (XPV(I,4,1),I=1,100)/
     &0.7160D-02,0.6955D-02,0.6751D-02,0.6550D-02,0.6360D-02,0.6172D-02,
     &0.5986D-02,0.5810D-02,0.5637D-02,0.5466D-02,0.5304D-02,0.5145D-02,
     &0.4987D-02,0.4839D-02,0.4693D-02,0.4548D-02,0.4413D-02,0.4279D-02,
     &0.4148D-02,0.4024D-02,0.3903D-02,0.3783D-02,0.3672D-02,0.3563D-02,
     &0.3456D-02,0.3356D-02,0.3259D-02,0.3163D-02,0.3075D-02,0.2990D-02,
     &0.2908D-02,0.2831D-02,0.2758D-02,0.2689D-02,0.2624D-02,0.2565D-02,
     &0.2509D-02,0.2458D-02,0.2411D-02,0.2370D-02,0.2334D-02,0.2302D-02,
     &0.2275D-02,0.2259D-02,0.2241D-02,0.2229D-02,0.2226D-02,0.2226D-02,
     &0.2229D-02,0.2239D-02,0.2253D-02,0.2272D-02,0.2295D-02,0.2322D-02,
     &0.2348D-02,0.2381D-02,0.2415D-02,0.2449D-02,0.2485D-02,0.2519D-02,
     &0.2554D-02,0.2586D-02,0.2618D-02,0.2648D-02,0.2676D-02,0.2705D-02,
     &0.2736D-02,0.2770D-02,0.2812D-02,0.2864D-02,0.2931D-02,0.3017D-02,
     &0.3129D-02,0.3270D-02,0.3447D-02,0.3662D-02,0.3913D-02,0.4178D-02,
     &0.4205D-02,0.4231D-02,0.4256D-02,0.4279D-02,0.4299D-02,0.4318D-02,
     &0.4333D-02,0.4345D-02,0.4353D-02,0.4357D-02,0.4355D-02,0.4348D-02,
     &0.4332D-02,0.4307D-02,0.4271D-02,0.4220D-02,0.4151D-02,0.4055D-02,
     &0.3924D-02,0.3774D-02,0.3409D-02,0.2626D-02/
      DATA (XPV(I,4,2),I=1,100)/
     &0.7157D-02,0.6952D-02,0.6748D-02,0.6546D-02,0.6356D-02,0.6167D-02,
     &0.5981D-02,0.5805D-02,0.5631D-02,0.5458D-02,0.5296D-02,0.5136D-02,
     &0.4978D-02,0.4828D-02,0.4681D-02,0.4535D-02,0.4398D-02,0.4263D-02,
     &0.4130D-02,0.4005D-02,0.3882D-02,0.3760D-02,0.3646D-02,0.3534D-02,
     &0.3424D-02,0.3321D-02,0.3220D-02,0.3120D-02,0.3028D-02,0.2938D-02,
     &0.2850D-02,0.2767D-02,0.2688D-02,0.2612D-02,0.2538D-02,0.2470D-02,
     &0.2405D-02,0.2343D-02,0.2285D-02,0.2231D-02,0.2181D-02,0.2133D-02,
     &0.2090D-02,0.2055D-02,0.2017D-02,0.1983D-02,0.1956D-02,0.1929D-02,
     &0.1905D-02,0.1883D-02,0.1864D-02,0.1846D-02,0.1830D-02,0.1815D-02,
     &0.1797D-02,0.1781D-02,0.1764D-02,0.1744D-02,0.1722D-02,0.1696D-02,
     &0.1666D-02,0.1633D-02,0.1597D-02,0.1556D-02,0.1513D-02,0.1468D-02,
     &0.1425D-02,0.1383D-02,0.1346D-02,0.1316D-02,0.1295D-02,0.1283D-02,
     &0.1281D-02,0.1284D-02,0.1288D-02,0.1286D-02,0.1269D-02,0.1228D-02,
     &0.1222D-02,0.1215D-02,0.1208D-02,0.1201D-02,0.1194D-02,0.1186D-02,
     &0.1177D-02,0.1169D-02,0.1159D-02,0.1149D-02,0.1139D-02,0.1127D-02,
     &0.1114D-02,0.1100D-02,0.1083D-02,0.1063D-02,0.1040D-02,0.1012D-02,
     &0.9728D-03,0.9358D-03,0.8403D-03,0.6078D-03/
      DATA (XPV(I,4,3),I=1,100)/
     &0.7192D-02,0.6990D-02,0.6788D-02,0.6589D-02,0.6402D-02,0.6216D-02,
     &0.6033D-02,0.5861D-02,0.5691D-02,0.5523D-02,0.5365D-02,0.5209D-02,
     &0.5055D-02,0.4912D-02,0.4770D-02,0.4630D-02,0.4499D-02,0.4370D-02,
     &0.4244D-02,0.4126D-02,0.4011D-02,0.3896D-02,0.3791D-02,0.3688D-02,
     &0.3587D-02,0.3494D-02,0.3403D-02,0.3314D-02,0.3233D-02,0.3154D-02,
     &0.3078D-02,0.3008D-02,0.2941D-02,0.2878D-02,0.2818D-02,0.2764D-02,
     &0.2713D-02,0.2664D-02,0.2620D-02,0.2581D-02,0.2544D-02,0.2510D-02,
     &0.2480D-02,0.2460D-02,0.2433D-02,0.2411D-02,0.2394D-02,0.2377D-02,
     &0.2359D-02,0.2343D-02,0.2328D-02,0.2312D-02,0.2295D-02,0.2276D-02,
     &0.2251D-02,0.2225D-02,0.2195D-02,0.2158D-02,0.2116D-02,0.2067D-02,
     &0.2012D-02,0.1950D-02,0.1883D-02,0.1810D-02,0.1733D-02,0.1655D-02,
     &0.1578D-02,0.1505D-02,0.1440D-02,0.1385D-02,0.1342D-02,0.1314D-02,
     &0.1298D-02,0.1293D-02,0.1292D-02,0.1288D-02,0.1269D-02,0.1228D-02,
     &0.1222D-02,0.1215D-02,0.1208D-02,0.1201D-02,0.1194D-02,0.1186D-02,
     &0.1177D-02,0.1169D-02,0.1159D-02,0.1149D-02,0.1139D-02,0.1127D-02,
     &0.1114D-02,0.1100D-02,0.1083D-02,0.1063D-02,0.1040D-02,0.1012D-02,
     &0.9728D-03,0.9358D-03,0.8403D-03,0.6078D-03/
      DATA (XPV(I,4,4),I=1,100)/
     &0.6994D-02,0.6789D-02,0.6586D-02,0.6385D-02,0.6194D-02,0.6006D-02,
     &0.5820D-02,0.5644D-02,0.5470D-02,0.5297D-02,0.5135D-02,0.4974D-02,
     &0.4815D-02,0.4665D-02,0.4516D-02,0.4369D-02,0.4231D-02,0.4094D-02,
     &0.3959D-02,0.3831D-02,0.3705D-02,0.3580D-02,0.3463D-02,0.3347D-02,
     &0.3233D-02,0.3125D-02,0.3019D-02,0.2914D-02,0.2815D-02,0.2718D-02,
     &0.2623D-02,0.2532D-02,0.2444D-02,0.2359D-02,0.2276D-02,0.2197D-02,
     &0.2121D-02,0.2047D-02,0.1976D-02,0.1909D-02,0.1845D-02,0.1784D-02,
     &0.1726D-02,0.1676D-02,0.1623D-02,0.1575D-02,0.1532D-02,0.1492D-02,
     &0.1455D-02,0.1422D-02,0.1393D-02,0.1368D-02,0.1348D-02,0.1332D-02,
     &0.1318D-02,0.1311D-02,0.1309D-02,0.1310D-02,0.1316D-02,0.1327D-02,
     &0.1342D-02,0.1361D-02,0.1385D-02,0.1412D-02,0.1443D-02,0.1477D-02,
     &0.1514D-02,0.1556D-02,0.1601D-02,0.1650D-02,0.1706D-02,0.1772D-02,
     &0.1851D-02,0.1951D-02,0.2081D-02,0.2254D-02,0.2490D-02,0.2807D-02,
     &0.2848D-02,0.2888D-02,0.2930D-02,0.2971D-02,0.3012D-02,0.3053D-02,
     &0.3094D-02,0.3133D-02,0.3173D-02,0.3210D-02,0.3246D-02,0.3278D-02,
     &0.3308D-02,0.3332D-02,0.3351D-02,0.3361D-02,0.3360D-02,0.3343D-02,
     &0.3298D-02,0.3256D-02,0.3045D-02,0.2439D-02/
      DATA (XPV(I,5,0),I=1,100)/
     &0.8093D+00,0.7773D+00,0.7460D+00,0.7153D+00,0.6865D+00,0.6584D+00,
     &0.6309D+00,0.6051D+00,0.5800D+00,0.5553D+00,0.5323D+00,0.5098D+00,
     &0.4878D+00,0.4672D+00,0.4471D+00,0.4274D+00,0.4091D+00,0.3911D+00,
     &0.3737D+00,0.3573D+00,0.3414D+00,0.3257D+00,0.3112D+00,0.2970D+00,
     &0.2832D+00,0.2703D+00,0.2577D+00,0.2454D+00,0.2339D+00,0.2228D+00,
     &0.2120D+00,0.2017D+00,0.1919D+00,0.1824D+00,0.1732D+00,0.1646D+00,
     &0.1562D+00,0.1481D+00,0.1404D+00,0.1331D+00,0.1261D+00,0.1193D+00,
     &0.1128D+00,0.1070D+00,0.1010D+00,0.9529D-01,0.9002D-01,0.8489D-01,
     &0.7989D-01,0.7519D-01,0.7070D-01,0.6643D-01,0.6235D-01,0.5848D-01,
     &0.5466D-01,0.5115D-01,0.4783D-01,0.4465D-01,0.4164D-01,0.3880D-01,
     &0.3612D-01,0.3361D-01,0.3128D-01,0.2906D-01,0.2701D-01,0.2510D-01,
     &0.2335D-01,0.2174D-01,0.2025D-01,0.1888D-01,0.1761D-01,0.1640D-01,
     &0.1519D-01,0.1391D-01,0.1244D-01,0.1063D-01,0.8288D-02,0.5319D-02,
     &0.4959D-02,0.4600D-02,0.4241D-02,0.3887D-02,0.3536D-02,0.3192D-02,
     &0.2851D-02,0.2522D-02,0.2202D-02,0.1896D-02,0.1603D-02,0.1327D-02,
     &0.1069D-02,0.8328D-03,0.6188D-03,0.4316D-03,0.2725D-03,0.1444D-03,
     &0.4859D-04,0.5429D-05,0.0000D+00,0.1955D-04/
      DATA (XPV(I,5,1),I=1,100)/
     &0.1593D-01,0.1538D-01,0.1484D-01,0.1431D-01,0.1382D-01,0.1333D-01,
     &0.1285D-01,0.1239D-01,0.1195D-01,0.1151D-01,0.1110D-01,0.1070D-01,
     &0.1031D-01,0.9936D-02,0.9572D-02,0.9216D-02,0.8882D-02,0.8554D-02,
     &0.8234D-02,0.7934D-02,0.7641D-02,0.7352D-02,0.7084D-02,0.6821D-02,
     &0.6565D-02,0.6326D-02,0.6094D-02,0.5867D-02,0.5655D-02,0.5452D-02,
     &0.5254D-02,0.5067D-02,0.4891D-02,0.4722D-02,0.4560D-02,0.4411D-02,
     &0.4269D-02,0.4134D-02,0.4008D-02,0.3894D-02,0.3787D-02,0.3688D-02,
     &0.3598D-02,0.3527D-02,0.3450D-02,0.3386D-02,0.3335D-02,0.3289D-02,
     &0.3249D-02,0.3219D-02,0.3197D-02,0.3182D-02,0.3175D-02,0.3175D-02,
     &0.3176D-02,0.3186D-02,0.3202D-02,0.3221D-02,0.3244D-02,0.3270D-02,
     &0.3298D-02,0.3328D-02,0.3361D-02,0.3394D-02,0.3429D-02,0.3468D-02,
     &0.3511D-02,0.3560D-02,0.3617D-02,0.3686D-02,0.3770D-02,0.3875D-02,
     &0.4005D-02,0.4169D-02,0.4375D-02,0.4632D-02,0.4943D-02,0.5288D-02,
     &0.5325D-02,0.5361D-02,0.5394D-02,0.5426D-02,0.5455D-02,0.5481D-02,
     &0.5503D-02,0.5521D-02,0.5534D-02,0.5542D-02,0.5542D-02,0.5535D-02,
     &0.5517D-02,0.5487D-02,0.5443D-02,0.5379D-02,0.5292D-02,0.5171D-02,
     &0.5002D-02,0.4819D-02,0.4353D-02,0.3292D-02/
      DATA (XPV(I,5,2),I=1,100)/
     &0.1593D-01,0.1538D-01,0.1484D-01,0.1431D-01,0.1381D-01,0.1332D-01,
     &0.1284D-01,0.1238D-01,0.1194D-01,0.1150D-01,0.1109D-01,0.1069D-01,
     &0.1029D-01,0.9919D-02,0.9554D-02,0.9196D-02,0.8860D-02,0.8530D-02,
     &0.8207D-02,0.7904D-02,0.7608D-02,0.7315D-02,0.7045D-02,0.6777D-02,
     &0.6517D-02,0.6273D-02,0.6035D-02,0.5802D-02,0.5584D-02,0.5373D-02,
     &0.5168D-02,0.4973D-02,0.4787D-02,0.4607D-02,0.4434D-02,0.4272D-02,
     &0.4116D-02,0.3966D-02,0.3825D-02,0.3692D-02,0.3565D-02,0.3445D-02,
     &0.3331D-02,0.3234D-02,0.3130D-02,0.3035D-02,0.2951D-02,0.2869D-02,
     &0.2790D-02,0.2718D-02,0.2650D-02,0.2586D-02,0.2526D-02,0.2469D-02,
     &0.2409D-02,0.2356D-02,0.2303D-02,0.2249D-02,0.2195D-02,0.2140D-02,
     &0.2084D-02,0.2027D-02,0.1970D-02,0.1911D-02,0.1852D-02,0.1794D-02,
     &0.1739D-02,0.1688D-02,0.1643D-02,0.1604D-02,0.1574D-02,0.1551D-02,
     &0.1534D-02,0.1523D-02,0.1512D-02,0.1500D-02,0.1483D-02,0.1462D-02,
     &0.1459D-02,0.1456D-02,0.1453D-02,0.1450D-02,0.1446D-02,0.1442D-02,
     &0.1438D-02,0.1433D-02,0.1427D-02,0.1421D-02,0.1413D-02,0.1404D-02,
     &0.1393D-02,0.1380D-02,0.1364D-02,0.1343D-02,0.1318D-02,0.1285D-02,
     &0.1239D-02,0.1192D-02,0.1073D-02,0.7970D-03/
      DATA (XPV(I,5,3),I=1,100)/
     &0.1597D-01,0.1542D-01,0.1488D-01,0.1436D-01,0.1386D-01,0.1337D-01,
     &0.1290D-01,0.1245D-01,0.1201D-01,0.1157D-01,0.1117D-01,0.1077D-01,
     &0.1038D-01,0.1001D-01,0.9654D-02,0.9302D-02,0.8972D-02,0.8649D-02,
     &0.8334D-02,0.8038D-02,0.7750D-02,0.7466D-02,0.7204D-02,0.6946D-02,
     &0.6696D-02,0.6462D-02,0.6234D-02,0.6012D-02,0.5805D-02,0.5606D-02,
     &0.5412D-02,0.5230D-02,0.5056D-02,0.4889D-02,0.4729D-02,0.4580D-02,
     &0.4438D-02,0.4301D-02,0.4173D-02,0.4053D-02,0.3939D-02,0.3831D-02,
     &0.3729D-02,0.3644D-02,0.3549D-02,0.3463D-02,0.3387D-02,0.3312D-02,
     &0.3238D-02,0.3168D-02,0.3101D-02,0.3036D-02,0.2971D-02,0.2907D-02,
     &0.2838D-02,0.2771D-02,0.2702D-02,0.2630D-02,0.2555D-02,0.2476D-02,
     &0.2393D-02,0.2308D-02,0.2221D-02,0.2130D-02,0.2040D-02,0.1951D-02,
     &0.1867D-02,0.1788D-02,0.1718D-02,0.1659D-02,0.1610D-02,0.1574D-02,
     &0.1547D-02,0.1529D-02,0.1515D-02,0.1501D-02,0.1484D-02,0.1462D-02,
     &0.1459D-02,0.1456D-02,0.1453D-02,0.1450D-02,0.1446D-02,0.1442D-02,
     &0.1438D-02,0.1433D-02,0.1427D-02,0.1421D-02,0.1413D-02,0.1404D-02,
     &0.1393D-02,0.1380D-02,0.1364D-02,0.1343D-02,0.1318D-02,0.1285D-02,
     &0.1239D-02,0.1192D-02,0.1073D-02,0.7970D-03/
      DATA (XPV(I,5,4),I=1,100)/
     &0.1576D-01,0.1522D-01,0.1468D-01,0.1415D-01,0.1365D-01,0.1316D-01,
     &0.1268D-01,0.1222D-01,0.1178D-01,0.1134D-01,0.1093D-01,0.1052D-01,
     &0.1013D-01,0.9753D-02,0.9387D-02,0.9027D-02,0.8689D-02,0.8357D-02,
     &0.8032D-02,0.7727D-02,0.7428D-02,0.7132D-02,0.6858D-02,0.6586D-02,
     &0.6323D-02,0.6074D-02,0.5831D-02,0.5593D-02,0.5369D-02,0.5152D-02,
     &0.4939D-02,0.4738D-02,0.4544D-02,0.4357D-02,0.4175D-02,0.4005D-02,
     &0.3840D-02,0.3681D-02,0.3530D-02,0.3388D-02,0.3253D-02,0.3123D-02,
     &0.3000D-02,0.2895D-02,0.2783D-02,0.2682D-02,0.2593D-02,0.2508D-02,
     &0.2428D-02,0.2357D-02,0.2294D-02,0.2239D-02,0.2192D-02,0.2153D-02,
     &0.2118D-02,0.2095D-02,0.2079D-02,0.2071D-02,0.2071D-02,0.2078D-02,
     &0.2093D-02,0.2115D-02,0.2144D-02,0.2178D-02,0.2219D-02,0.2264D-02,
     &0.2316D-02,0.2372D-02,0.2434D-02,0.2502D-02,0.2580D-02,0.2672D-02,
     &0.2784D-02,0.2928D-02,0.3119D-02,0.3377D-02,0.3729D-02,0.4189D-02,
     &0.4246D-02,0.4303D-02,0.4359D-02,0.4415D-02,0.4470D-02,0.4524D-02,
     &0.4576D-02,0.4626D-02,0.4674D-02,0.4717D-02,0.4757D-02,0.4790D-02,
     &0.4817D-02,0.4835D-02,0.4841D-02,0.4833D-02,0.4805D-02,0.4749D-02,
     &0.4653D-02,0.4545D-02,0.4183D-02,0.3280D-02/
      DATA (XPV(I,6,0),I=1,100)/
     &0.1231D+01,0.1178D+01,0.1126D+01,0.1075D+01,0.1027D+01,0.9810D+00,
     &0.9360D+00,0.8939D+00,0.8530D+00,0.8132D+00,0.7760D+00,0.7400D+00,
     &0.7048D+00,0.6721D+00,0.6402D+00,0.6093D+00,0.5805D+00,0.5525D+00,
     &0.5253D+00,0.5000D+00,0.4755D+00,0.4515D+00,0.4294D+00,0.4078D+00,
     &0.3869D+00,0.3675D+00,0.3487D+00,0.3304D+00,0.3134D+00,0.2970D+00,
     &0.2811D+00,0.2662D+00,0.2519D+00,0.2382D+00,0.2250D+00,0.2127D+00,
     &0.2008D+00,0.1894D+00,0.1786D+00,0.1684D+00,0.1587D+00,0.1493D+00,
     &0.1404D+00,0.1325D+00,0.1242D+00,0.1166D+00,0.1095D+00,0.1026D+00,
     &0.9603D-01,0.8984D-01,0.8397D-01,0.7840D-01,0.7313D-01,0.6816D-01,
     &0.6329D-01,0.5884D-01,0.5463D-01,0.5064D-01,0.4689D-01,0.4336D-01,
     &0.4003D-01,0.3692D-01,0.3405D-01,0.3131D-01,0.2878D-01,0.2641D-01,
     &0.2422D-01,0.2217D-01,0.2026D-01,0.1847D-01,0.1676D-01,0.1509D-01,
     &0.1343D-01,0.1172D-01,0.9883D-02,0.7845D-02,0.5581D-02,0.3172D-02,
     &0.2910D-02,0.2656D-02,0.2408D-02,0.2169D-02,0.1937D-02,0.1717D-02,
     &0.1503D-02,0.1304D-02,0.1115D-02,0.9399D-03,0.7768D-03,0.6289D-03,
     &0.4947D-03,0.3769D-03,0.2741D-03,0.1885D-03,0.1190D-03,0.6665D-04,
     &0.2993D-04,0.1309D-04,0.5951D-05,0.8951D-05/
      DATA (XPV(I,6,1),I=1,100)/
     &0.2693D-01,0.2590D-01,0.2489D-01,0.2390D-01,0.2298D-01,0.2207D-01,
     &0.2118D-01,0.2035D-01,0.1954D-01,0.1874D-01,0.1800D-01,0.1728D-01,
     &0.1656D-01,0.1590D-01,0.1525D-01,0.1462D-01,0.1402D-01,0.1344D-01,
     &0.1288D-01,0.1235D-01,0.1184D-01,0.1134D-01,0.1087D-01,0.1041D-01,
     &0.9974D-02,0.9562D-02,0.9162D-02,0.8773D-02,0.8412D-02,0.8064D-02,
     &0.7726D-02,0.7409D-02,0.7109D-02,0.6821D-02,0.6545D-02,0.6290D-02,
     &0.6047D-02,0.5816D-02,0.5600D-02,0.5401D-02,0.5215D-02,0.5039D-02,
     &0.4878D-02,0.4745D-02,0.4605D-02,0.4483D-02,0.4379D-02,0.4284D-02,
     &0.4198D-02,0.4126D-02,0.4065D-02,0.4016D-02,0.3978D-02,0.3950D-02,
     &0.3926D-02,0.3916D-02,0.3914D-02,0.3919D-02,0.3932D-02,0.3950D-02,
     &0.3974D-02,0.4003D-02,0.4038D-02,0.4077D-02,0.4120D-02,0.4169D-02,
     &0.4224D-02,0.4287D-02,0.4360D-02,0.4445D-02,0.4547D-02,0.4671D-02,
     &0.4824D-02,0.5016D-02,0.5261D-02,0.5573D-02,0.5961D-02,0.6401D-02,
     &0.6449D-02,0.6495D-02,0.6539D-02,0.6580D-02,0.6619D-02,0.6653D-02,
     &0.6683D-02,0.6708D-02,0.6727D-02,0.6738D-02,0.6742D-02,0.6735D-02,
     &0.6716D-02,0.6682D-02,0.6630D-02,0.6554D-02,0.6450D-02,0.6305D-02,
     &0.6100D-02,0.5879D-02,0.5316D-02,0.4016D-02/
      DATA (XPV(I,6,2),I=1,100)/
     &0.2692D-01,0.2589D-01,0.2488D-01,0.2389D-01,0.2297D-01,0.2206D-01,
     &0.2117D-01,0.2034D-01,0.1953D-01,0.1873D-01,0.1798D-01,0.1726D-01,
     &0.1654D-01,0.1588D-01,0.1522D-01,0.1459D-01,0.1399D-01,0.1341D-01,
     &0.1284D-01,0.1231D-01,0.1180D-01,0.1129D-01,0.1082D-01,0.1036D-01,
     &0.9909D-02,0.9490D-02,0.9083D-02,0.8686D-02,0.8316D-02,0.7959D-02,
     &0.7611D-02,0.7283D-02,0.6970D-02,0.6668D-02,0.6378D-02,0.6106D-02,
     &0.5845D-02,0.5595D-02,0.5358D-02,0.5135D-02,0.4923D-02,0.4720D-02,
     &0.4529D-02,0.4363D-02,0.4187D-02,0.4026D-02,0.3880D-02,0.3739D-02,
     &0.3603D-02,0.3478D-02,0.3360D-02,0.3248D-02,0.3143D-02,0.3044D-02,
     &0.2944D-02,0.2853D-02,0.2766D-02,0.2680D-02,0.2597D-02,0.2515D-02,
     &0.2435D-02,0.2356D-02,0.2280D-02,0.2204D-02,0.2130D-02,0.2060D-02,
     &0.1995D-02,0.1934D-02,0.1881D-02,0.1834D-02,0.1795D-02,0.1764D-02,
     &0.1739D-02,0.1720D-02,0.1706D-02,0.1698D-02,0.1697D-02,0.1707D-02,
     &0.1708D-02,0.1709D-02,0.1711D-02,0.1711D-02,0.1712D-02,0.1712D-02,
     &0.1712D-02,0.1710D-02,0.1708D-02,0.1704D-02,0.1700D-02,0.1692D-02,
     &0.1683D-02,0.1670D-02,0.1653D-02,0.1631D-02,0.1603D-02,0.1564D-02,
     &0.1512D-02,0.1455D-02,0.1312D-02,0.9886D-03/
      DATA (XPV(I,6,3),I=1,100)/
     &0.2696D-01,0.2594D-01,0.2493D-01,0.2395D-01,0.2302D-01,0.2212D-01,
     &0.2124D-01,0.2041D-01,0.1960D-01,0.1881D-01,0.1807D-01,0.1735D-01,
     &0.1664D-01,0.1598D-01,0.1533D-01,0.1470D-01,0.1411D-01,0.1354D-01,
     &0.1298D-01,0.1246D-01,0.1195D-01,0.1145D-01,0.1099D-01,0.1054D-01,
     &0.1010D-01,0.9691D-02,0.9294D-02,0.8909D-02,0.8550D-02,0.8204D-02,
     &0.7868D-02,0.7552D-02,0.7251D-02,0.6962D-02,0.6684D-02,0.6425D-02,
     &0.6177D-02,0.5939D-02,0.5714D-02,0.5503D-02,0.5303D-02,0.5111D-02,
     &0.4930D-02,0.4774D-02,0.4606D-02,0.4452D-02,0.4312D-02,0.4176D-02,
     &0.4042D-02,0.3918D-02,0.3798D-02,0.3683D-02,0.3571D-02,0.3464D-02,
     &0.3351D-02,0.3245D-02,0.3141D-02,0.3035D-02,0.2930D-02,0.2823D-02,
     &0.2716D-02,0.2609D-02,0.2504D-02,0.2398D-02,0.2295D-02,0.2196D-02,
     &0.2104D-02,0.2019D-02,0.1944D-02,0.1879D-02,0.1825D-02,0.1782D-02,
     &0.1749D-02,0.1725D-02,0.1708D-02,0.1698D-02,0.1697D-02,0.1707D-02,
     &0.1708D-02,0.1709D-02,0.1711D-02,0.1711D-02,0.1712D-02,0.1712D-02,
     &0.1712D-02,0.1710D-02,0.1708D-02,0.1704D-02,0.1700D-02,0.1692D-02,
     &0.1683D-02,0.1670D-02,0.1653D-02,0.1631D-02,0.1603D-02,0.1564D-02,
     &0.1512D-02,0.1455D-02,0.1312D-02,0.9886D-03/
      DATA (XPV(I,6,4),I=1,100)/
     &0.2676D-01,0.2573D-01,0.2472D-01,0.2373D-01,0.2280D-01,0.2189D-01,
     &0.2101D-01,0.2018D-01,0.1936D-01,0.1857D-01,0.1782D-01,0.1709D-01,
     &0.1638D-01,0.1571D-01,0.1506D-01,0.1442D-01,0.1382D-01,0.1324D-01,
     &0.1267D-01,0.1213D-01,0.1161D-01,0.1110D-01,0.1063D-01,0.1016D-01,
     &0.9714D-02,0.9291D-02,0.8880D-02,0.8479D-02,0.8104D-02,0.7741D-02,
     &0.7388D-02,0.7054D-02,0.6735D-02,0.6427D-02,0.6131D-02,0.5854D-02,
     &0.5587D-02,0.5331D-02,0.5088D-02,0.4860D-02,0.4644D-02,0.4438D-02,
     &0.4244D-02,0.4076D-02,0.3901D-02,0.3742D-02,0.3601D-02,0.3468D-02,
     &0.3343D-02,0.3232D-02,0.3133D-02,0.3046D-02,0.2971D-02,0.2908D-02,
     &0.2852D-02,0.2812D-02,0.2784D-02,0.2766D-02,0.2760D-02,0.2764D-02,
     &0.2779D-02,0.2803D-02,0.2838D-02,0.2881D-02,0.2931D-02,0.2989D-02,
     &0.3054D-02,0.3126D-02,0.3205D-02,0.3293D-02,0.3394D-02,0.3513D-02,
     &0.3660D-02,0.3850D-02,0.4103D-02,0.4446D-02,0.4907D-02,0.5494D-02,
     &0.5564D-02,0.5634D-02,0.5703D-02,0.5770D-02,0.5836D-02,0.5899D-02,
     &0.5960D-02,0.6016D-02,0.6069D-02,0.6115D-02,0.6155D-02,0.6187D-02,
     &0.6208D-02,0.6216D-02,0.6209D-02,0.6180D-02,0.6125D-02,0.6033D-02,
     &0.5886D-02,0.5722D-02,0.5226D-02,0.4038D-02/
      DATA (XPV(I,7,0),I=1,100)/
     &0.1677D+01,0.1599D+01,0.1523D+01,0.1449D+01,0.1381D+01,0.1314D+01,
     &0.1249D+01,0.1189D+01,0.1131D+01,0.1074D+01,0.1022D+01,0.9709D+00,
     &0.9215D+00,0.8757D+00,0.8313D+00,0.7884D+00,0.7484D+00,0.7098D+00,
     &0.6725D+00,0.6378D+00,0.6043D+00,0.5717D+00,0.5418D+00,0.5126D+00,
     &0.4847D+00,0.4586D+00,0.4335D+00,0.4092D+00,0.3867D+00,0.3651D+00,
     &0.3443D+00,0.3247D+00,0.3062D+00,0.2884D+00,0.2714D+00,0.2555D+00,
     &0.2403D+00,0.2257D+00,0.2120D+00,0.1991D+00,0.1868D+00,0.1751D+00,
     &0.1640D+00,0.1541D+00,0.1439D+00,0.1345D+00,0.1258D+00,0.1174D+00,
     &0.1094D+00,0.1019D+00,0.9482D-01,0.8815D-01,0.8185D-01,0.7594D-01,
     &0.7018D-01,0.6493D-01,0.5999D-01,0.5532D-01,0.5095D-01,0.4685D-01,
     &0.4299D-01,0.3941D-01,0.3609D-01,0.3294D-01,0.3001D-01,0.2728D-01,
     &0.2475D-01,0.2237D-01,0.2014D-01,0.1804D-01,0.1603D-01,0.1408D-01,
     &0.1216D-01,0.1023D-01,0.8245D-02,0.6190D-02,0.4106D-02,0.2133D-02,
     &0.1935D-02,0.1745D-02,0.1564D-02,0.1393D-02,0.1230D-02,0.1078D-02,
     &0.9340D-03,0.8018D-03,0.6796D-03,0.5685D-03,0.4677D-03,0.3782D-03,
     &0.2992D-03,0.2312D-03,0.1736D-03,0.1264D-03,0.8864D-04,0.6022D-04,
     &0.3944D-04,0.2460D-04,0.1450D-04,0.2966D-05/
      DATA (XPV(I,7,1),I=1,100)/
     &0.3968D-01,0.3804D-01,0.3644D-01,0.3488D-01,0.3341D-01,0.3198D-01,
     &0.3060D-01,0.2930D-01,0.2803D-01,0.2680D-01,0.2565D-01,0.2453D-01,
     &0.2343D-01,0.2242D-01,0.2142D-01,0.2046D-01,0.1956D-01,0.1868D-01,
     &0.1783D-01,0.1704D-01,0.1627D-01,0.1552D-01,0.1483D-01,0.1415D-01,
     &0.1350D-01,0.1289D-01,0.1231D-01,0.1174D-01,0.1121D-01,0.1070D-01,
     &0.1021D-01,0.9747D-02,0.9311D-02,0.8894D-02,0.8496D-02,0.8127D-02,
     &0.7777D-02,0.7443D-02,0.7132D-02,0.6844D-02,0.6574D-02,0.6320D-02,
     &0.6086D-02,0.5889D-02,0.5684D-02,0.5503D-02,0.5347D-02,0.5204D-02,
     &0.5072D-02,0.4959D-02,0.4862D-02,0.4780D-02,0.4712D-02,0.4660D-02,
     &0.4612D-02,0.4585D-02,0.4569D-02,0.4563D-02,0.4568D-02,0.4582D-02,
     &0.4605D-02,0.4636D-02,0.4677D-02,0.4723D-02,0.4776D-02,0.4838D-02,
     &0.4908D-02,0.4987D-02,0.5076D-02,0.5180D-02,0.5302D-02,0.5448D-02,
     &0.5628D-02,0.5855D-02,0.6147D-02,0.6522D-02,0.6993D-02,0.7534D-02,
     &0.7594D-02,0.7651D-02,0.7705D-02,0.7756D-02,0.7805D-02,0.7847D-02,
     &0.7886D-02,0.7917D-02,0.7942D-02,0.7958D-02,0.7964D-02,0.7958D-02,
     &0.7937D-02,0.7898D-02,0.7839D-02,0.7751D-02,0.7629D-02,0.7460D-02,
     &0.7219D-02,0.6959D-02,0.6295D-02,0.4764D-02/
      DATA (XPV(I,7,2),I=1,100)/
     &0.3967D-01,0.3803D-01,0.3643D-01,0.3486D-01,0.3340D-01,0.3197D-01,
     &0.3058D-01,0.2928D-01,0.2801D-01,0.2678D-01,0.2562D-01,0.2450D-01,
     &0.2341D-01,0.2239D-01,0.2139D-01,0.2042D-01,0.1952D-01,0.1864D-01,
     &0.1779D-01,0.1699D-01,0.1622D-01,0.1546D-01,0.1476D-01,0.1408D-01,
     &0.1342D-01,0.1280D-01,0.1221D-01,0.1163D-01,0.1109D-01,0.1057D-01,
     &0.1006D-01,0.9587D-02,0.9136D-02,0.8701D-02,0.8285D-02,0.7896D-02,
     &0.7524D-02,0.7166D-02,0.6828D-02,0.6511D-02,0.6211D-02,0.5923D-02,
     &0.5651D-02,0.5414D-02,0.5166D-02,0.4937D-02,0.4730D-02,0.4531D-02,
     &0.4339D-02,0.4161D-02,0.3994D-02,0.3837D-02,0.3689D-02,0.3551D-02,
     &0.3412D-02,0.3287D-02,0.3168D-02,0.3053D-02,0.2944D-02,0.2838D-02,
     &0.2736D-02,0.2639D-02,0.2547D-02,0.2456D-02,0.2371D-02,0.2290D-02,
     &0.2216D-02,0.2149D-02,0.2089D-02,0.2036D-02,0.1992D-02,0.1956D-02,
     &0.1927D-02,0.1907D-02,0.1898D-02,0.1901D-02,0.1923D-02,0.1966D-02,
     &0.1971D-02,0.1977D-02,0.1982D-02,0.1987D-02,0.1991D-02,0.1995D-02,
     &0.1998D-02,0.1999D-02,0.2000D-02,0.1999D-02,0.1996D-02,0.1990D-02,
     &0.1981D-02,0.1968D-02,0.1951D-02,0.1927D-02,0.1894D-02,0.1851D-02,
     &0.1790D-02,0.1723D-02,0.1556D-02,0.1179D-02/
      DATA (XPV(I,7,3),I=1,100)/
     &0.3972D-01,0.3809D-01,0.3648D-01,0.3492D-01,0.3346D-01,0.3204D-01,
     &0.3065D-01,0.2936D-01,0.2810D-01,0.2686D-01,0.2572D-01,0.2460D-01,
     &0.2351D-01,0.2250D-01,0.2151D-01,0.2055D-01,0.1965D-01,0.1878D-01,
     &0.1793D-01,0.1714D-01,0.1638D-01,0.1563D-01,0.1494D-01,0.1427D-01,
     &0.1362D-01,0.1301D-01,0.1243D-01,0.1186D-01,0.1133D-01,0.1082D-01,
     &0.1033D-01,0.9865D-02,0.9426D-02,0.9004D-02,0.8600D-02,0.8223D-02,
     &0.7863D-02,0.7517D-02,0.7191D-02,0.6885D-02,0.6594D-02,0.6316D-02,
     &0.6054D-02,0.5826D-02,0.5584D-02,0.5361D-02,0.5158D-02,0.4962D-02,
     &0.4770D-02,0.4591D-02,0.4421D-02,0.4258D-02,0.4102D-02,0.3953D-02,
     &0.3801D-02,0.3660D-02,0.3523D-02,0.3387D-02,0.3255D-02,0.3124D-02,
     &0.2996D-02,0.2871D-02,0.2751D-02,0.2632D-02,0.2519D-02,0.2411D-02,
     &0.2313D-02,0.2223D-02,0.2143D-02,0.2074D-02,0.2017D-02,0.1971D-02,
     &0.1935D-02,0.1911D-02,0.1899D-02,0.1901D-02,0.1923D-02,0.1966D-02,
     &0.1971D-02,0.1977D-02,0.1982D-02,0.1987D-02,0.1991D-02,0.1995D-02,
     &0.1998D-02,0.1999D-02,0.2000D-02,0.1999D-02,0.1996D-02,0.1990D-02,
     &0.1981D-02,0.1968D-02,0.1951D-02,0.1927D-02,0.1894D-02,0.1851D-02,
     &0.1790D-02,0.1723D-02,0.1556D-02,0.1179D-02/
      DATA (XPV(I,7,4),I=1,100)/
     &0.3951D-01,0.3787D-01,0.3626D-01,0.3470D-01,0.3324D-01,0.3181D-01,
     &0.3042D-01,0.2912D-01,0.2785D-01,0.2661D-01,0.2546D-01,0.2434D-01,
     &0.2324D-01,0.2222D-01,0.2122D-01,0.2025D-01,0.1935D-01,0.1847D-01,
     &0.1761D-01,0.1681D-01,0.1604D-01,0.1528D-01,0.1458D-01,0.1389D-01,
     &0.1323D-01,0.1261D-01,0.1201D-01,0.1142D-01,0.1088D-01,0.1036D-01,
     &0.9848D-02,0.9370D-02,0.8915D-02,0.8477D-02,0.8057D-02,0.7665D-02,
     &0.7290D-02,0.6930D-02,0.6592D-02,0.6274D-02,0.5975D-02,0.5689D-02,
     &0.5422D-02,0.5191D-02,0.4951D-02,0.4734D-02,0.4541D-02,0.4361D-02,
     &0.4191D-02,0.4042D-02,0.3908D-02,0.3791D-02,0.3689D-02,0.3604D-02,
     &0.3528D-02,0.3474D-02,0.3435D-02,0.3410D-02,0.3400D-02,0.3403D-02,
     &0.3420D-02,0.3450D-02,0.3493D-02,0.3545D-02,0.3608D-02,0.3680D-02,
     &0.3761D-02,0.3850D-02,0.3949D-02,0.4059D-02,0.4184D-02,0.4334D-02,
     &0.4519D-02,0.4757D-02,0.5073D-02,0.5499D-02,0.6065D-02,0.6768D-02,
     &0.6851D-02,0.6932D-02,0.7012D-02,0.7089D-02,0.7164D-02,0.7236D-02,
     &0.7303D-02,0.7366D-02,0.7422D-02,0.7470D-02,0.7510D-02,0.7539D-02,
     &0.7554D-02,0.7553D-02,0.7532D-02,0.7484D-02,0.7404D-02,0.7276D-02,
     &0.7082D-02,0.6866D-02,0.6248D-02,0.4789D-02/
C..fetching pdfs
      DATA XMIN/1.D-04/,XMAX/1./
      IF ((X.LT.XMIN).OR.(X.GE.XMAX)) THEN
        WRITE(6,*) 'LAC: x outside the range, x= ',X
        RETURN
      ENDIF
      DO  5 IP=0,5
        XPDF(IP)=0.
 5    CONTINUE
      DO 2 I=1,IX
        ENT(I)=LOG10(XT(I))
  2   CONTINUE
      NA(1)=IX
      NA(2)=IQ
      DO 3 I=1,IQ
        ENT(IX+I)=LOG10(Q2T(I))
   3  CONTINUE
      ARG(1)=LOG10(X)
      ARG(2)=LOG10(Q2)
C..VARIOUS FLAVOURS (u-->2,d-->1)
      XPDF(0)=PHFINT(NARG,ARG,NA,ENT,XPV(1,1,0))
      XPDF(1)=PHFINT(NARG,ARG,NA,ENT,XPV(1,1,2))
      XPDF(2)=PHFINT(NARG,ARG,NA,ENT,XPV(1,1,1))
      XPDF(3)=PHFINT(NARG,ARG,NA,ENT,XPV(1,1,3))
      XPDF(4)=PHFINT(NARG,ARG,NA,ENT,XPV(1,1,4))
      RETURN
      END
C--------------------------------------------------------------
C
C Multidimensional Linear Interpolation/ CERNLIB:E104/
C
C   AUTHOR C. LETERTRE.
C   MODIFIED BY B. SCHORR, 1.07.1982.
C
      FUNCTION PHFINT(NARG,ARG,NA,ENT,TABLE)
C
           IMPLICIT REAL*8 (A-H,O-Z)
           INTEGER   NA(NARG)
           INTEGER   INDEX(32)
CTAYM      DIMENSION ARG(NARG),ENT(9),TABLE(9),WEIGHT(32)
           DIMENSION ARG(NARG),ENT(*),TABLE(*),WEIGHT(32)
           PHFINT =  0.
           IF(NARG .LT. 1  .OR.  NARG .GT. 5)  RETURN
           LMAX      =  0
           ISTEP     =  1
           KNOTS     =  1
           INDEX(1)  =  1
           WEIGHT(1) =  1.
           DO 100    N  =  1, NARG
              X     =  ARG(N)
              NDIM  =  NA(N)
              LOCA  =  LMAX
              LMIN  =  LMAX + 1
              LMAX  =  LMAX + NDIM
              IF(NDIM .GT. 2)  GOTO 10
              IF(NDIM .EQ. 1)  GOTO 100
              H  =  X - ENT(LMIN)
              IF(H .EQ. 0.)  GOTO 90
              ISHIFT  =  ISTEP
              IF(X-ENT(LMIN+1) .EQ. 0.)  GOTO 21
              ISHIFT  =  0
              ETA     =  H / (ENT(LMIN+1) - ENT(LMIN))
              GOTO 30
   10         LOCB  =  LMAX + 1
   11         LOCC  =  (LOCA+LOCB) / 2
              IF(X-ENT(LOCC))  12, 20, 13
   12         LOCB  =  LOCC
              GOTO 14
   13         LOCA  =  LOCC
   14         IF(LOCB-LOCA .GT. 1)  GOTO 11
              LOCA    =  MIN0( MAX0(LOCA,LMIN), LMAX-1 )
              ISHIFT  =  (LOCA - LMIN) * ISTEP
              ETA     =  (X - ENT(LOCA)) / (ENT(LOCA+1) - ENT(LOCA))
              GOTO 30
   20         ISHIFT  =  (LOCC - LMIN) * ISTEP
   21         DO 22  K  =  1, KNOTS
                 INDEX(K)  =  INDEX(K) + ISHIFT
   22            CONTINUE
              GOTO 90
   30         DO 31  K  =  1, KNOTS
                 INDEX(K)         =  INDEX(K) + ISHIFT
                 INDEX(K+KNOTS)   =  INDEX(K) + ISTEP
                 WEIGHT(K+KNOTS)  =  WEIGHT(K) * ETA
                 WEIGHT(K)        =  WEIGHT(K) - WEIGHT(K+KNOTS)
   31            CONTINUE
              KNOTS  =  2*KNOTS
   90         ISTEP  =  ISTEP * NDIM
  100         CONTINUE
           DO 200    K  =  1, KNOTS
              I  =  INDEX(K)
              PHFINT =  PHFINT+ WEIGHT(K) * TABLE(I)
  200         CONTINUE
           RETURN
           END
      SUBROUTINE PYSTGA(NFE,X,T,XPGL,XPQU,XPQD)
      IMPLICIT REAL*8 (A-H,O-Z)
C...Gives photon structure function; external to PYSTFU since it
C...may be called several times for convolution of photon structure
C...functions with photons in electron structure function.
C
C This subroutine is picked up from PYTHIA55 in T#FP.PYTHIA55.FORT
C Reference will be found in ;
C           M.Drees and K.Grassie, Z.Phys.C28(1985)451-462.
C
C Valid Q^2 range ; 1 < Q^2 < 10000
C
C(Input)
C    NFE  ; # of flaours
C           =1 for 1 < Q^2 50 GeV^2
C           =2 for 20 < Q^2 < 500 GeV^2
C           =3 for 200 < Q^2 < 10000 GeV^2
C         Note the overlap of Q^2 range, which gives the smooth curve.
C    X
C    T    ; = log(Q^2/L^2), where L=0.4GeV
C(Output)
C    XPGL ; Gluon contents of photon
C    XPQU ; up type quark contents of photon
C    XPQD ; down type quark contents of photon
C
C(Comments added by A.Miyamoto  15-Nov-1991 )
C
C
C
      DIMENSION DGAG(4,3),DGBG(4,3),DGCG(4,3),DGAN(4,3),DGBN(4,3),
     &DGCN(4,3),DGDN(4,3),DGEN(4,3),DGAS(4,3),DGBS(4,3),DGCS(4,3),
     &DGDS(4,3),DGES(4,3)
C...The following data lines are coefficients needed in the
C...Drees and Grassie photon structure function parametrizations.
      DATA DGAG/-.207E0,.6158E0,1.074E0,0.E0,.8926E-2,.6594E0,
     &.4766E0,.1975E-1,.03197E0,1.018E0,.2461E0,.2707E-1/
      DATA DGBG/-.1987E0,.6257E0,8.352E0,5.024E0,.5085E-1,.2774E0,
     &-.3906E0,-.3212E0,-.618E-2,.9476E0,-.6094E0,-.1067E-1/
      DATA DGCG/5.119E0,-.2752E0,-6.993E0,2.298E0,-.2313E0,.1382E0,
     &6.542E0,.5162E0,-.1216E0,.9047E0,2.653E0,.2003E-2/
      DATA DGAN/2.285E0,-.1526E-1,1330.E0,4.219E0,-.3711E0,1.061E0,
     &4.758E0,-.1503E-1,15.8E0,-.9464E0,-.5E0,-.2118E0/
      DATA DGBN/6.073E0,-.8132E0,-41.31E0,3.165E0,-.1717E0,.7815E0,
     &1.535E0,.7067E-2,2.742E0,-.7332E0,.7148E0,3.287E0/
      DATA DGCN/-.4202E0,.1778E-1,.9216E0,.18E0,.8766E-1,.2197E-1,
     &.1096E0,.204E0,.2917E-1,.4657E-1,.1785E0,.4811E-1/
      DATA DGDN/-.8083E-1,.6346E0,1.208E0,.203E0,-.8915E0,.2857E0,
     &2.973E0,.1185E0,-.342E-1,.7196E0,.7338E0,.8139E-1/
      DATA DGEN/.5526E-1,1.136E0,.9512E0,.1163E-1,-.1816E0,.5866E0,
     &2.421E0,.4059E0,-.2302E-1,.9229E0,.5873E0,-.79E-4/
      DATA DGAS/16.69E0,-.7916E0,1099.E0,4.428E0,-.1207E0,1.071E0,
     &1.977E0,-.8625E-2,6.734E0,-1.008E0,-.8594E-1,.7625E-1/
      DATA DGBS/.176E0,.4794E-1,1.047E0,.25E-1,25.E0,-1.648E0,
     &-.1563E-1,6.438E0,59.88E0,-2.983E0,4.48E0,.9686E0/
      DATA DGCS/-.208E-1,.3386E-2,4.853E0,.8404E0,-.123E-1,1.162E0,
     &.4824E0,-.11E-1,-.3226E-2,.8432E0,.3616E0,.1383E-2/
      DATA DGDS/-.1685E-1,1.353E0,1.426E0,1.239E0,-.9194E-1,.7912E0,
     &.6397E0,2.327E0,-.3321E-1,.9475E0,-.3198E0,.2132E-1/
      DATA DGES/-.1986E0,1.1E0,1.136E0,-.2779E0,.2015E-1,.9869E0,
     &-.7036E-1,.1694E-1,.1059E0,.6954E0,-.6663E0,.3683E0/
C...Photon structure function from Drees and Grassie.
C...Allowed variable range: 1 GeV^2 < Q^2 < 10000 GeV^2.
      X1=1.-X
C...Evaluate gluon content.
      DGA=DGAG(1,NFE)*T**DGAG(2,NFE)+DGAG(3,NFE)*T**(-DGAG(4,NFE))
      DGB=DGBG(1,NFE)*T**DGBG(2,NFE)+DGBG(3,NFE)*T**(-DGBG(4,NFE))
      DGC=DGCG(1,NFE)*T**DGCG(2,NFE)+DGCG(3,NFE)*T**(-DGCG(4,NFE))
      XPGL=DGA*X**DGB*X1**DGC
C...Evaluate up- and down-type quark content.
      DGA=DGAN(1,NFE)*T**DGAN(2,NFE)+DGAN(3,NFE)*T**(-DGAN(4,NFE))
      DGB=DGBN(1,NFE)*T**DGBN(2,NFE)+DGBN(3,NFE)*T**(-DGBN(4,NFE))
      DGC=DGCN(1,NFE)*T**DGCN(2,NFE)+DGCN(3,NFE)*T**(-DGCN(4,NFE))
      DGD=DGDN(1,NFE)*T**DGDN(2,NFE)+DGDN(3,NFE)*T**(-DGDN(4,NFE))
      DGE=DGEN(1,NFE)*T**DGEN(2,NFE)+DGEN(3,NFE)*T**(-DGEN(4,NFE))
      XPQN=X*(X**2+X1**2)/(DGA-DGB*LOG(X1))+DGC*X**DGD*X1**DGE
      DGA=DGAS(1,NFE)*T**DGAS(2,NFE)+DGAS(3,NFE)*T**(-DGAS(4,NFE))
      DGB=DGBS(1,NFE)*T**DGBS(2,NFE)+DGBS(3,NFE)*T**(-DGBS(4,NFE))
      DGC=DGCS(1,NFE)*T**DGCS(2,NFE)+DGCS(3,NFE)*T**(-DGCS(4,NFE))
      DGD=DGDS(1,NFE)*T**DGDS(2,NFE)+DGDS(3,NFE)*T**(-DGDS(4,NFE))
      DGE=DGES(1,NFE)*T**DGES(2,NFE)+DGES(3,NFE)*T**(-DGES(4,NFE))
      DGF=9.
      IF(NFE.EQ.2) DGF=10.
      IF(NFE.EQ.3) DGF=55./6.
      XPQS=DGF*X*(X**2+X1**2)/(DGA-DGB*LOG(X1))+DGC*X**DGD*X1**DGE
      IF(NFE.LE.1) THEN
        XPQU=(XPQS+9.*XPQN)/6.
        XPQD=(XPQS-4.5*XPQN)/6.
      ELSEIF(NFE.EQ.2) THEN
        XPQU=(XPQS+6.*XPQN)/8.
        XPQD=(XPQS-6.*XPQN)/8.
      ELSE
        XPQU=(XPQS+7.5*XPQN)/10.
        XPQD=(XPQS-5.*XPQN)/10.
      ENDIF
      RETURN
      END
CC********************************************************************CC
C*                                                                    *C
C*==========================--===                                     *C
C*  Subroutine UBSTBK(PB,PR,PA)                                       *C
C*==========================--===                                     *C
C*                                                                    *C
C* (Purpose)                                                          *C
C*    routine to transform PB(4) in PR(4)-rest frame to PA(4)         *C
C*    in PR(4)-moving frame.                                          *C
C* (Inputs)                                                           *C
C*     PB(4) = 4-vector of a particle in PR-rest frame.               *C
C*     PR(4) = 4-vector of a reference particle.                      *C
C* (Output)                                                           *C
C*     PA(4) = 4-vector of a particle in PR-moving frame.             *C
C* (Relation)                                                         *C
C*    Calls                                                           *C
C*       UCONJ4, UBSTFD                                               *C
C* (Update Record)                                                    *C
C*    7/29/85  K. Fujii  Original version.                            *C
C*                                                                    *C
CC********************************************************************CC
C
C ============================--===
      SUBROUTINE UBSTBK(PB,PR,PA)
C ============================--===
C
      DIMENSION PB(4),PR(4),PA(4),PRNV(4)
      CALL UCONJ4(PR,PRNV)
      CALL UBSTFD(PB,PRNV,PA)
      RETURN
      END
CC********************************************************************CC
C*                                                                    *C
C*=======================--====                                       *C
C*  Subroutine UCONJ4(P1,P2)                                          *C
C*=======================--====                                       *C
C*                                                                    *C
C* (Purpose)                                                          *C
C*   Take Lorentz conjugate.                                          *C
C* (Input)                                                            *C
C*       P1(4) = an input 4-vector.                                   *C
C* (Output)                                                           *C
C*       P2(4) = its Lorentz conjugated 4-vector                      *C
C* (Relation)                                                         *C
C*   Calls                                                            *C
C*       USCLM3                                                       *C
C* (Update Record)                                                    *C
C*    7/29/85  K. Fujii  Original version.                            *C
C*                                                                    *C
CC********************************************************************CC
C
C =========================--====
      SUBROUTINE UCONJ4(P1,P2)
C =========================--====
C
      DIMENSION P1(4),P2(4)
      P2(4)=P1(4)
      CALL USCLM3(-1.,P1(1),P2(1))
      RETURN
      END
CC********************************************************************CC
C*                                                                    *C
C* =======================--==                                        *C
C*  Subroutine USCLM3(A,X,AX)                                         *C
C* =======================--==                                        *C
C*                                                                    *C
C*    1) Purpose                                                      *C
C*        Multiplies X by a scalar A.                                 *C
C*    2) I/O specification                                            *C
C*        Input                                                       *C
C*          A      ; a scalar number                                  *C
C*          X(3)   ; 3-dim. vector                                    *C
C*        Output                                                      *C
C*          AX(3)  ; A*X(*)                                           *C
C*    4) Update record                                                *C
C*         6/12/85 TKSF Original version.                             *C
C*                                                                    *C
CC********************************************************************CC
C
C* =========================--==
      SUBROUTINE USCLM3(A,X,AX)
C* =========================--==
C
      DIMENSION X(3),AX(3)
C
      DO 10 I=1,3
        AX(I) = A*X(I)
 10   CONTINUE
C
      RETURN
      END
CC********************************************************************CC
C*                                                                    *C
C*==========================--===                                     *C
C*  Subroutine UBSTFD(PB,PR,PA)                                       *C
C*==========================--===                                     *C
C*                                                                    *C
C* (Purpose)                                                          *C
C*    routine to transform PB(4) to PR(4)-rest frame ,PA(4).          *C
C* (Inputs)                                                           *C
C*     PB(4) = 4-vector of a particle.                                *C
C*     PR(4) = 4-vector of a reference particle.                      *C
C* (Output)                                                           *C
C*     PA(4) = 4-vector of a particle in PR-rest frame.               *C
C* (Relation)                                                         *C
C*     Calls                                                          *C
C*        UDOT4                                                       *C
C* (Update Record)                                                    *C
C*    7/29/85  K. Fujii  Original version.                            *C
C*                                                                    *C
CC********************************************************************CC
C
C ============================--===
      SUBROUTINE UBSTFD(PB,PR,PA)
C ============================--===
C
      DIMENSION PB(4),PR(4),PA(4)
      AM=UDOT4(PR,PR)
      IF(AM.LE.0.) GO TO 9999
      AM=SQRT(AM)
      PA4=UDOT4(PB,PR)/AM
      A=(PB(4)+PA4)/(PR(4)+AM)
      PA(4)=PA4
      DO 10 I=1,3
      PA(I)=PB(I)-A*PR(I)
   10 CONTINUE
      RETURN
C
 9999 WRITE(6,*) ' >>>> Error in UBSTFD. -ve mass squared.>>>'
C
      END
CC********************************************************************CC
C*                                                                    *C
C*===========-----=======                                             *C
C*  Function UDOT4(A,B)                                               *C
C*===========-----=======                                             *C
C*                                                                    *C
C* (Purpose)                                                          *C
C*    routine to calculate invariant 4-scalar product.                *C
C* (Inputs)                                                           *C
C*      A(4), B(4) :  2 4-vectors.                                    *C
C* (Output)                                                           *C
C*      UDOT4      :  A(4)*B(4)-UDOT3(A(1),B(1))                      *C
C* (Update Record)                                                    *C
C*   7/29/85  K. Fujii  Original version.                             *C
C*                                                                    *C
CC********************************************************************CC
C
C =============-----=======
      FUNCTION UDOT4(A,B)
C =============-----=======
C
      DIMENSION A(4),B(4)
      UDOT4=A(4)*B(4)
      DO 10 I=1,3
      UDOT4=UDOT4-A(I)*B(I)
   10 CONTINUE
      RETURN
      END
      SUBROUTINE PHOGS2(X,Q2,U,D,S,C,B,G)
*****************************************************************
* Subroutine returns the parton distributions in the photon in  *
* higher  order. u,d etc. gives the actual distributions and    *
* not x times the distributions; Q2 means Q^2. The distributions*
* are valid for 5.0e^-4< x < 1.0 and 5.3 GeV^2 < Q^2 < 1.0e^8.  *
* if higher Q^2 or lower x is required, these may be obtained   *
* from the authors on request.                                  *
* Lionel Gordon July 1991 : Gordon@uk.ac.man.ph.v2              *
*****************************************************************
      IMPLICIT  REAL*8(A-H,O-Z)
      PARAMETER(NP=78,NQ=11,NARG=2)
      COMMON/CGSDAT/ SIG(NP,NQ),QNS(NP,NQ),GL(NP,NQ)
      DIMENSION Y(NP)
      DIMENSION XT(NARG),NA(NARG),A(NP+NQ),QT(NQ)
      EXTERNAL XCOR,SETGS3

      SAVE Y,ICALL
      DATA QT /5.3D0,20.0D0,50.0D0,1.0D2,5.0D2,1.0D3,1.0D4,1.0D5,
     * 1.0D6,1.0D7,1.0D8/
******************************************************************
*if x is out of range
      U = 0.0
      D = 0.0
      S = 0.0
      C = 0.0
      B = 0.0
      G = 0.0
       IF((X.LT.5.0D-4).OR.(X.GT.0.95D0)) GOTO 90
*******************************************************************
       IF (ICALL.NE.1) THEN
* get the x coordinates
       CALL XCOR(Y,NP)
        ICALL=1
        END IF
*
      DO 30 IX=1,NP
        A(IX)=Y(IX)
   30 CONTINUE
      DO 40 IQ=1,NQ
        A(NP+IQ)=QT(IQ)
   40 CONTINUE
*
      NA(1)=NP
      NA(2)=NQ  
       XT(1)=X
       XT(2)=Q2
      XSIG=FINT(2,XT,NA,A,SIG)
      XQNS=FINT(2,XT,NA,A,QNS)
        G =FINT(2,XT,NA,A,GL)
*
      IF (Q2.LT.50.0D0) THEN 
C Use three flavour evolution. 
       U=(XSIG+9.0D0*XQNS)/6.0D0
       D=(XSIG-4.5D0*XQNS)/6.0D0
       S=D
       C=0.0D0
       B=0.0D0
*      
      ELSE IF((Q2.GT.50.0D0).AND.(Q2.LT.250.0D0)) THEN
C Use four flavour evolution 
      U=(XSIG+6.0D0*XQNS)/8.0D0
      D=(XSIG-6.0D0*XQNS)/8.0D0
      S=D
      C=U
      B=0.0D0
      ELSE
C Use five flavour evolution
      U=(XSIG+7.5D0*XQNS)/10.0D0
      D=(XSIG-5.0D0*XQNS)/10.0D0
      S=D
      C=U
      B=D
      ENDIF
 90   RETURN
      END
      BLOCK DATA SETGS3
      IMPLICIT  REAL*8(A-H,O-Z)
      COMMON/CGSDAT/X1(76),X2(76),X3(76),X4(76),X5(76),X6(76),
     1X7(76),X8(76),X9(76),X10(76),X11(76),X12(76),X13(76),
     1X14(76),X15(76),X16(76),X17(76),X18(76),X19(76),X20(76),
     1X21(76),X22(76),X23(76),X24(76),X25(76),X26(76),X27(76),
     1X28(76),X29(76),X30(76),X31(76),X32(76),X33(76),X34(68)

      DATA X 1/
     1   6.065650    ,   2.088165    ,   1.280238    ,  0.9302918    ,
     1  0.7341829    ,  0.6084410    ,  0.5207982    ,  0.4561276    ,
     1  0.4063894    ,  0.3669108    ,  0.2430186    ,  0.1877330    ,
     1  0.1536570    ,  0.1307466    ,  0.1142303    ,  0.1016919    ,
     1  9.1824383E-02,  8.3837993E-02,  7.7232063E-02,  7.1669787E-02,
     1  6.6916473E-02,  6.2803216E-02,  5.9205659E-02,  5.6029748E-02,
     1  5.3203389E-02,  5.0670139E-02,  4.8385251E-02,  4.6312671E-02,
     1  3.9639950E-02,  3.4731269E-02,  3.0962721E-02,  2.7958600E-02,
     1  2.5508121E-02,  2.3467820E-02,  2.1740520E-02,  2.0261120E-02,
     1  1.8979279E-02,  1.7860260E-02,  1.6876670E-02,  1.6007900E-02,
     1  1.5237720E-02,  1.4553230E-02,  1.3944190E-02,  1.3402170E-02,
     1  1.2920360E-02,  1.2493100E-02,  1.2115690E-02,  1.1784200E-02,
     1  1.1495290E-02,  1.1246160E-02,  1.1034380E-02,  1.0857900E-02,
     1  1.0714930E-02,  1.0603910E-02,  1.0523480E-02,  1.0472440E-02,
     1  1.0449720E-02,  1.0454350E-02,  1.0485460E-02,  1.0542220E-02,
     1  1.0623830E-02,  1.0729520E-02,  1.0858500E-02,  1.0950560E-02,
     1  1.1051160E-02,  1.1160040E-02,  1.1276930E-02,  1.1401470E-02,
     1  1.1533270E-02,  1.1671830E-02,  1.1816470E-02,  1.1966280E-02,
     1  1.2119800E-02,  1.2272990E-02,  1.2431370E-02,  1.2523280E-02/
      DATA X 2/
     1  1.2347910E-02,  1.2112140E-02,   14.81312    ,   4.225006    ,
     1   2.383706    ,   1.639148    ,   1.240866    ,  0.9945472    ,
     1  0.8279024    ,  0.7080337    ,  0.6178786    ,  0.5477297    ,
     1  0.3377715    ,  0.2498051    ,  0.1978402    ,  0.1642276    ,
     1  0.1407451    ,  0.1233648    ,  0.1099809    ,  9.9350482E-02,
     1  9.0703093E-02,  8.3529383E-02,  7.7480227E-02,  7.2308272E-02,
     1  6.7833833E-02,  6.3922822E-02,  6.0473621E-02,  5.7407670E-02,
     1  5.4663248E-02,  5.2191179E-02,  4.4347670E-02,  3.8684819E-02,
     1  3.4400601E-02,  3.1020120E-02,  2.8286161E-02,  2.6025079E-02,
     1  2.4121379E-02,  2.2499129E-02,  2.1099890E-02,  1.9884139E-02,
     1  1.8820820E-02,  1.7886849E-02,  1.7064160E-02,  1.6338451E-02,
     1  1.5698440E-02,  1.5134880E-02,  1.4640300E-02,  1.4208490E-02,
     1  1.3834280E-02,  1.3513360E-02,  1.3242030E-02,  1.3017140E-02,
     1  1.2836000E-02,  1.2696250E-02,  1.2595820E-02,  1.2532890E-02,
     1  1.2505820E-02,  1.2513130E-02,  1.2553500E-02,  1.2625690E-02,
     1  1.2728530E-02,  1.2860950E-02,  1.3021890E-02,  1.3210340E-02,
     1  1.3425320E-02,  1.3572740E-02,  1.3729910E-02,  1.3896610E-02,
     1  1.4072660E-02,  1.4257840E-02,  1.4452020E-02,  1.4655100E-02,
     1  1.4867100E-02,  1.5088220E-02,  1.5318900E-02,  1.5559540E-02/
      DATA X 3/
     1  1.5815720E-02,  1.6048649E-02,  1.6222630E-02,  1.6615819E-02,
     1   9.293111    ,   3.339304    ,   2.067960    ,   1.502766    ,
     1   1.183022    ,  0.9783799    ,  0.8352991    ,  0.7298861    ,
     1  0.6490827    ,  0.5845310    ,  0.3837406    ,  0.2960849    ,
     1  0.2420744    ,  0.2061101    ,  0.1803555    ,  0.1609060    ,
     1  0.1457158    ,  0.1334649    ,  0.1232904    ,  0.1147711    ,
     1  0.1075640    ,  0.1012721    ,  9.5873907E-02,  9.0988472E-02,
     1  8.6721793E-02,  8.2940288E-02,  7.9428963E-02,  7.6301463E-02,
     1  6.6243261E-02,  5.8714509E-02,  5.2959319E-02,  4.8347849E-02,
     1  4.4563029E-02,  4.1398302E-02,  3.8703881E-02,  3.6374308E-02,
     1  3.4347311E-02,  3.2578040E-02,  3.1015320E-02,  2.9626479E-02,
     1  2.8393490E-02,  2.7296299E-02,  2.6316751E-02,  2.5438830E-02,
     1  2.4651900E-02,  2.3955980E-02,  2.3342401E-02,  2.2792900E-02,
     1  2.2314910E-02,  2.1923721E-02,  2.1608140E-02,  2.1354260E-02,
     1  2.1145010E-02,  2.0972131E-02,  2.0837391E-02,  2.0738060E-02,
     1  2.0669920E-02,  2.0630831E-02,  2.0616479E-02,  2.0618061E-02,
     1  2.0628391E-02,  2.0641111E-02,  2.0652451E-02,  2.0654449E-02,
     1  2.0646131E-02,  2.0636970E-02,  2.0609491E-02,  2.0558780E-02,
     1  2.0480519E-02,  2.0378530E-02,  2.0229550E-02,  2.0029761E-02/
      DATA X 4/
     1  1.9757731E-02,  1.9362951E-02,  1.8845521E-02,  1.8049579E-02,
     1  1.6761150E-02,  1.4562510E-02,   29.89254    ,   8.486094    ,
     1   4.705948    ,   3.188108    ,   2.384678    ,   1.892738    ,
     1   1.562856    ,   1.327437    ,   1.151646    ,   1.015645    ,
     1  0.6146161    ,  0.4499378    ,  0.3538099    ,  0.2923728    ,
     1  0.2498652    ,  0.2185992    ,  0.1946893    ,  0.1757937    ,
     1  0.1604877    ,  0.1478390    ,  0.1372090    ,  0.1281479    ,
     1  0.1203243    ,  0.1135013    ,  0.1074955    ,  0.1021628    ,
     1  9.7393431E-02,  9.3105540E-02,  7.9521753E-02,  6.9705971E-02,
     1  6.2275078E-02,  5.6396492E-02,  5.1625419E-02,  4.7660202E-02,
     1  4.4302821E-02,  4.1424479E-02,  3.8924851E-02,  3.6736481E-02,
     1  3.4806740E-02,  3.3096351E-02,  3.1574190E-02,  3.0216200E-02,
     1  2.9003520E-02,  2.7919229E-02,  2.6949840E-02,  2.6085939E-02,
     1  2.5316190E-02,  2.4626389E-02,  2.4024550E-02,  2.3525581E-02,
     1  2.3115231E-02,  2.2779001E-02,  2.2505760E-02,  2.2289259E-02,
     1  2.2129331E-02,  2.2022730E-02,  2.1965619E-02,  2.1957699E-02,
     1  2.1997960E-02,  2.2083109E-02,  2.2210380E-02,  2.2376960E-02,
     1  2.2587020E-02,  2.2740031E-02,  2.2905730E-02,  2.3087120E-02,
     1  2.3284070E-02,  2.3494760E-02,  2.3723761E-02,  2.3967849E-02/
      DATA X 5/
     1  2.4232781E-02,  2.4517810E-02,  2.4828481E-02,  2.5169710E-02,
     1  2.5568120E-02,  2.6023811E-02,  2.6611401E-02,  2.7781690E-02,
     1   46.18080    ,   12.73584    ,   6.897929    ,   4.587731    ,
     1   3.381126    ,   2.651696    ,   2.167241    ,   1.824850    ,
     1   1.571178    ,   1.376090    ,  0.8112021    ,  0.5851333    ,
     1  0.4550185    ,  0.3731124    ,  0.3170887    ,  0.2763102    ,
     1  0.2453717    ,  0.2210806    ,  0.2014971    ,  0.1854069    ,
     1  0.1719627    ,  0.1605255    ,  0.1507296    ,  0.1421624    ,
     1  0.1346727    ,  0.1280525    ,  0.1220999    ,  0.1167827    ,
     1  0.1000133    ,  8.7907299E-02,  7.8784272E-02,  7.1573026E-02,
     1  6.5722778E-02,  6.0865950E-02,  5.6757271E-02,  5.3234901E-02,
     1  5.0179549E-02,  4.7510762E-02,  4.5161560E-02,  4.3083619E-02,
     1  4.1240890E-02,  3.9602909E-02,  3.8144790E-02,  3.6845971E-02,
     1  3.5690770E-02,  3.4669969E-02,  3.3770930E-02,  3.2976381E-02,
     1  3.2288659E-02,  3.1716350E-02,  3.1241089E-02,  3.0846439E-02,
     1  3.0523861E-02,  3.0267149E-02,  3.0073229E-02,  2.9937450E-02,
     1  2.9854709E-02,  2.9821690E-02,  2.9834339E-02,  2.9886751E-02,
     1  2.9973591E-02,  3.0089520E-02,  3.0232349E-02,  3.0332500E-02,
     1  3.0436510E-02,  3.0547591E-02,  3.0660881E-02,  3.0774301E-02/
      DATA X 6/
     1  3.0884590E-02,  3.0994020E-02,  3.1095279E-02,  3.1189339E-02,
     1  3.1271771E-02,  3.1333931E-02,  3.1390648E-02,  3.1420220E-02,
     1  3.1460121E-02,  3.1791709E-02,   58.93127    ,   15.83552    ,
     1   8.463400    ,   5.576946    ,   4.080611    ,   3.181088    ,
     1   2.586669    ,   2.168283    ,   1.859430    ,   1.622807    ,
     1  0.9429896    ,  0.6736690    ,  0.5199088    ,  0.4238146    ,
     1  0.3584874    ,  0.3111752    ,  0.2754281    ,  0.2474715    ,
     1  0.2250217    ,  0.2066313    ,  0.1913020    ,  0.1783039    ,
     1  0.1671840    ,  0.1574975    ,  0.1490360    ,  0.1415660    ,
     1  0.1348752    ,  0.1289001    ,  0.1101170    ,  9.6632458E-02,
     1  8.6500198E-02,  7.8511238E-02,  7.2044186E-02,  6.6683590E-02,
     1  6.2154699E-02,  5.8277521E-02,  5.4917410E-02,  5.1984102E-02,
     1  4.9404170E-02,  4.7124159E-02,  4.5103449E-02,  4.3308370E-02,
     1  4.1711830E-02,  4.0291362E-02,  3.9029591E-02,  3.7915122E-02,
     1  3.6934279E-02,  3.6069840E-02,  3.5322201E-02,  3.4697421E-02,
     1  3.4176640E-02,  3.3743359E-02,  3.3389669E-02,  3.3109281E-02,
     1  3.2898162E-02,  3.2751221E-02,  3.2663152E-02,  3.2630101E-02,
     1  3.2647721E-02,  3.2710262E-02,  3.2812338E-02,  3.2948561E-02,
     1  3.3116210E-02,  3.3234179E-02,  3.3358291E-02,  3.3490729E-02/
      DATA X 7/
     1  3.3627711E-02,  3.3767279E-02,  3.3906471E-02,  3.4046870E-02,
     1  3.4182768E-02,  3.4315020E-02,  3.4440480E-02,  3.4554109E-02,
     1  3.4669790E-02,  3.4777518E-02,  3.4929819E-02,  3.5431288E-02,
     1   105.5808    ,   26.82932    ,   13.94875    ,   9.016710    ,
     1   6.499412    ,   5.003829    ,   4.025714    ,   3.343064    ,
     1   2.842955    ,   2.462716    ,   1.387883    ,  0.9710444    ,
     1  0.7369921    ,  0.5929472    ,  0.4962908    ,  0.4270351    ,
     1  0.3751792    ,  0.3349671    ,  0.3029397    ,  0.2768761    ,
     1  0.2552737    ,  0.2370774    ,  0.2215643    ,  0.2081516    ,
     1  0.1964665    ,  0.1861850    ,  0.1770428    ,  0.1688894    ,
     1  0.1434479    ,  0.1254004    ,  0.1119368    ,  0.1013838    ,
     1  9.2885412E-02,  8.5868679E-02,  7.9960249E-02,  7.4918769E-02,
     1  7.0560403E-02,  6.6763259E-02,  6.3431010E-02,  6.0492780E-02,
     1  5.7893489E-02,  5.5588901E-02,  5.3543881E-02,  5.1729329E-02,
     1  5.0122119E-02,  4.8704419E-02,  4.7458921E-02,  4.6367530E-02,
     1  4.5424450E-02,  4.4628300E-02,  4.3959539E-02,  4.3401580E-02,
     1  4.2946380E-02,  4.2586450E-02,  4.2315271E-02,  4.2126201E-02,
     1  4.2012729E-02,  4.1969199E-02,  4.1989770E-02,  4.2067949E-02,
     1  4.2197369E-02,  4.2371430E-02,  4.2584751E-02,  4.2734690E-02/
      DATA X 8/
     1  4.2893950E-02,  4.3062311E-02,  4.3236911E-02,  4.3415319E-02,
     1  4.3594342E-02,  4.3772999E-02,  4.3946739E-02,  4.4113830E-02,
     1  4.4270299E-02,  4.4412009E-02,  4.4543002E-02,  4.4658821E-02,
     1  4.4800300E-02,  4.5190562E-02,   157.6617    ,   38.68541    ,
     1   19.78188    ,   12.64162    ,   9.031486    ,   6.901991    ,
     1   5.517890    ,   4.556793    ,   3.855926    ,   3.325383    ,
     1   1.840164    ,   1.271493    ,  0.9552516    ,  0.7624074    ,
     1  0.6340090    ,  0.5425936    ,  0.4745191    ,  0.4219958    ,
     1  0.3803591    ,  0.3466116    ,  0.3187415    ,  0.2953521    ,
     1  0.2754635    ,  0.2583326    ,  0.2434399    ,  0.2303669    ,
     1  0.2187841    ,  0.2084679    ,  0.1764247    ,  0.1538522    ,
     1  0.1370931    ,  0.1240067    ,  0.1135038    ,  0.1048552    ,
     1  9.7589523E-02,  9.1403417E-02,  8.6065248E-02,  8.1422217E-02,
     1  7.7354252E-02,  7.3772967E-02,  7.0609339E-02,  6.7808449E-02,
     1  6.5326788E-02,  6.3128360E-02,  6.1184190E-02,  5.9470680E-02,
     1  5.7966631E-02,  5.6651872E-02,  5.5515282E-02,  5.4549418E-02,
     1  5.3734161E-02,  5.3052329E-02,  5.2494340E-02,  5.2050930E-02,
     1  5.1713381E-02,  5.1473320E-02,  5.1322609E-02,  5.1253621E-02,
     1  5.1258650E-02,  5.1329572E-02,  5.1458132E-02,  5.1635671E-02/
      DATA X 9/
     1  5.1853690E-02,  5.2005962E-02,  5.2166689E-02,  5.2333880E-02,
     1  5.2503981E-02,  5.2673269E-02,  5.2837271E-02,  5.2992191E-02,
     1  5.3131729E-02,  5.3250082E-02,  5.3338759E-02,  5.3387560E-02,
     1  5.3386521E-02,  5.3315692E-02,  5.3170782E-02,  5.3023379E-02,
     1   214.0912    ,   51.20706    ,   25.87715    ,   16.40320    ,
     1   11.64555    ,   8.853699    ,   7.047054    ,   5.797109    ,
     1   4.888587    ,   4.202940    ,   2.296647    ,   1.573305    ,
     1   1.173696    ,  0.9315756    ,  0.7712347    ,  0.6575760    ,
     1  0.5732574    ,  0.5084242    ,  0.4571906    ,  0.4157796    ,
     1  0.3816664    ,  0.3531073    ,  0.3288700    ,  0.3080420    ,
     1  0.2899643    ,  0.2741223    ,  0.2601163    ,  0.2476557    ,
     1  0.2090732    ,  0.1820191    ,  0.1620007    ,  0.1464104    ,
     1  0.1339278    ,  0.1236690    ,  0.1150648    ,  0.1077506    ,
     1  0.1014476    ,  9.5972262E-02,  9.1180831E-02,  8.6967453E-02,
     1  8.3249383E-02,  7.9960987E-02,  7.7050328E-02,  7.4474350E-02,
     1  7.2198197E-02,  7.0192903E-02,  6.8433218E-02,  6.6896260E-02,
     1  6.5566219E-02,  6.4430557E-02,  6.3468233E-02,  6.2661037E-02,
     1  6.1997332E-02,  6.1465859E-02,  6.1055701E-02,  6.0756639E-02,
     1  6.0558759E-02,  6.0452379E-02,  6.0427699E-02,  6.0474571E-02/
      DATA X10/
     1  6.0582530E-02,  6.0740590E-02,  6.0936529E-02,  6.1072171E-02,
     1  6.1213531E-02,  6.1357051E-02,  6.1497640E-02,  6.1629958E-02,
     1  6.1748229E-02,  6.1845440E-02,  6.1912581E-02,  6.1939351E-02,
     1  6.1911561E-02,  6.1810911E-02,  6.1612379E-02,  6.1274901E-02,
     1  6.0742259E-02,  5.9931930E-02,   274.1096    ,   64.25571    ,
     1   32.17454    ,   20.26772    ,   14.32000    ,   10.84398    ,
     1   8.602262    ,   7.055698    ,   5.934431    ,   5.090187    ,
     1   2.755311    ,   1.875444    ,   1.391756    ,   1.100116    ,
     1  0.9077632    ,  0.7718564    ,  0.6713176    ,  0.5942087    ,
     1  0.5334144    ,  0.4843759    ,  0.4440552    ,  0.4103581    ,
     1  0.3818032    ,  0.3573045    ,  0.3360674    ,  0.3174801    ,
     1  0.3010706    ,  0.2864847    ,  0.2414257    ,  0.2099336    ,
     1  0.1866905    ,  0.1686237    ,  0.1541835    ,  0.1423333    ,
     1  0.1324067    ,  0.1239783    ,  0.1167225    ,  0.1104258    ,
     1  0.1049204    ,  0.1000833    ,  9.5818073E-02,  9.2048533E-02,
     1  8.8714316E-02,  8.5765094E-02,  8.3160058E-02,  8.0865093E-02,
     1  7.8851111E-02,  7.7092528E-02,  7.5568870E-02,  7.4262612E-02,
     1  7.3151790E-02,  7.2217263E-02,  7.1445107E-02,  7.0821747E-02,
     1  7.0333578E-02,  6.9968723E-02,  6.9715917E-02,  6.9563143E-02/
      DATA X11/
     1  6.9498338E-02,  6.9508933E-02,  6.9582589E-02,  6.9707043E-02,
     1  6.9862597E-02,  6.9967851E-02,  7.0076667E-02,  7.0183903E-02,
     1  7.0279703E-02,  7.0356868E-02,  7.0412166E-02,  7.0432268E-02,
     1  7.0405953E-02,  7.0318170E-02,  7.0148848E-02,  6.9871724E-02,
     1  6.9444656E-02,  6.8807177E-02,  6.7848079E-02,  6.6343412E-02,
     1   337.1538    ,   77.72972    ,   38.63046    ,   24.21099    ,
     1   17.03953    ,   12.86234    ,   10.17592    ,   8.326851    ,
     1   6.989035    ,   5.983618    ,   3.214868    ,   2.177278    ,
     1   1.609106    ,   1.267856    ,   1.043501    ,  0.8853900    ,
     1  0.7686830    ,  0.6793509    ,  0.6090437    ,  0.5524220    ,
     1  0.5059347    ,  0.4671349    ,  0.4342943    ,  0.4061528    ,
     1  0.3817828    ,  0.3604743    ,  0.3416809    ,  0.3249890    ,
     1  0.2735150    ,  0.2376255    ,  0.2111894    ,  0.1906710    ,
     1  0.1742932    ,  0.1608679    ,  0.1496328    ,  0.1401016    ,
     1  0.1319030    ,  0.1247939    ,  0.1185825    ,  0.1131282    ,
     1  0.1083215    ,  0.1040759    ,  0.1003230    ,  9.7003967E-02,
     1  9.4071522E-02,  9.1486961E-02,  8.9218549E-02,  8.7239869E-02,
     1  8.5524023E-02,  8.4045477E-02,  8.2783557E-02,  8.1719823E-02,
     1  8.0838099E-02,  8.0121078E-02,  7.9549924E-02,  7.9112291E-02/
      DATA X12/
     1  7.8798316E-02,  7.8592658E-02,  7.8480117E-02,  7.8444868E-02,
     1  7.8474604E-02,  7.8562818E-02,  7.8662880E-02,  7.8721397E-02,
     1  7.8789286E-02,  7.8859143E-02,  7.8900620E-02,  7.8904226E-02,
     1  7.8889683E-02,  7.8821197E-02,  7.8689642E-02,  7.8474760E-02,
     1  7.8150623E-02,  7.7687196E-02,  7.7013567E-02,  7.6065756E-02,
     1  7.4661553E-02,  7.2463982E-02,  1.6735110E-02,  1.0360230E-02,
     1  8.3886869E-03,  7.3353890E-03,  6.6539398E-03,  6.1661350E-03,
     1  5.7942928E-03,  5.4983469E-03,  5.2553299E-03,  5.0509102E-03,
     1  4.3140231E-03,  3.9181332E-03,  3.6403660E-03,  3.4307679E-03,
     1  3.2640500E-03,  3.1262699E-03,  3.0092350E-03,  2.9076750E-03,
     1  2.8180580E-03,  2.7379040E-03,  2.6654070E-03,  2.5992200E-03,
     1  2.5383099E-03,  2.4818771E-03,  2.4292851E-03,  2.3800230E-03,
     1  2.3336730E-03,  2.2898940E-03,  2.1354540E-03,  2.0055959E-03,
     1  1.8934190E-03,  1.7945550E-03,  1.7063410E-03,  1.6269070E-03,
     1  1.5549220E-03,  1.4894450E-03,  1.4297330E-03,  1.3752390E-03,
     1  1.3255250E-03,  1.2802430E-03,  1.2391130E-03,  1.2019010E-03,
     1  1.1684150E-03,  1.1384930E-03,  1.1119960E-03,  1.0888060E-03,
     1  1.0688190E-03,  1.0519460E-03,  1.0381070E-03,  1.0272301E-03,
     1  1.0192510E-03,  1.0141140E-03,  1.0117620E-03,  1.0121480E-03/
      DATA X13/
     1  1.0152240E-03,  1.0209450E-03,  1.0292680E-03,  1.0401510E-03,
     1  1.0535470E-03,  1.0694140E-03,  1.0877040E-03,  1.1083640E-03,
     1  1.1313340E-03,  1.1468329E-03,  1.1631870E-03,  1.1803739E-03,
     1  1.1983650E-03,  1.2171280E-03,  1.2366200E-03,  1.2567900E-03,
     1  1.2775650E-03,  1.2988460E-03,  1.3204750E-03,  1.3420030E-03,
     1  1.3640480E-03,  1.3786490E-03,  1.3634940E-03,  1.3415710E-03,
     1  2.4002330E-02,  1.4755050E-02,  1.1990140E-02,  1.0519520E-02,
     1  9.5669189E-03,  8.8830646E-03,  8.3599715E-03,  7.9421578E-03,
     1  7.5978232E-03,  7.3071779E-03,  6.2495512E-03,  5.6732930E-03,
     1  5.2648350E-03,  4.9539921E-03,  4.7050519E-03,  4.4982028E-03,
     1  4.3217251E-03,  4.1680448E-03,  4.0320670E-03,  3.9101872E-03,
     1  3.7997700E-03,  3.6988449E-03,  3.6058971E-03,  3.5197409E-03,
     1  3.4394360E-03,  3.3642210E-03,  3.2934749E-03,  3.2266860E-03,
     1  2.9915131E-03,  2.7946411E-03,  2.6254880E-03,  2.4772980E-03,
     1  2.3458810E-03,  2.2282740E-03,  2.1223410E-03,  2.0265521E-03,
     1  1.9396869E-03,  1.8608380E-03,  1.7892621E-03,  1.7243690E-03,
     1  1.6656700E-03,  1.6127580E-03,  1.5652890E-03,  1.5229681E-03,
     1  1.4855430E-03,  1.4527900E-03,  1.4245140E-03,  1.4005400E-03,
     1  1.3807120E-03,  1.3648870E-03,  1.3529330E-03,  1.3447320E-03/
      DATA X14/
     1  1.3401700E-03,  1.3391420E-03,  1.3415460E-03,  1.3472870E-03,
     1  1.3562730E-03,  1.3684120E-03,  1.3836140E-03,  1.4017900E-03,
     1  1.4228540E-03,  1.4467140E-03,  1.4732810E-03,  1.4912200E-03,
     1  1.5101590E-03,  1.5300780E-03,  1.5509550E-03,  1.5727750E-03,
     1  1.5955210E-03,  1.6191890E-03,  1.6437820E-03,  1.6693270E-03,
     1  1.6958750E-03,  1.7234760E-03,  1.7527570E-03,  1.7794110E-03,
     1  1.7995070E-03,  1.8439980E-03,  3.1382661E-02,  1.9948659E-02,
     1  1.6622100E-02,  1.4842080E-02,  1.3684040E-02,  1.2838670E-02,
     1  1.2198180E-02,  1.1683200E-02,  1.1244940E-02,  1.0885400E-02,
     1  9.5314020E-03,  8.7511344E-03,  8.2062762E-03,  7.7832751E-03,
     1  7.4358052E-03,  7.1446360E-03,  6.8931221E-03,  6.6723530E-03,
     1  6.4755050E-03,  6.2975409E-03,  6.1348551E-03,  5.9849769E-03,
     1  5.8468101E-03,  5.7185791E-03,  5.5981162E-03,  5.4848022E-03,
     1  5.3782049E-03,  5.2765808E-03,  4.9156472E-03,  4.6119899E-03,
     1  4.3483572E-03,  4.1152160E-03,  3.9063548E-03,  3.7178830E-03,
     1  3.5464950E-03,  3.3895769E-03,  3.2450610E-03,  3.1115529E-03,
     1  2.9884509E-03,  2.8750100E-03,  2.7702311E-03,  2.6732830E-03,
     1  2.5834979E-03,  2.4994139E-03,  2.4206671E-03,  2.3502710E-03,
     1  2.2865720E-03,  2.2229860E-03,  2.1667490E-03,  2.1293061E-03/
      DATA X15/
     1  2.1063660E-03,  2.0927980E-03,  2.0838620E-03,  2.0772619E-03,
     1  2.0737920E-03,  2.0732731E-03,  2.0753329E-03,  2.0791909E-03,
     1  2.0842431E-03,  2.0903980E-03,  2.0973389E-03,  2.1045031E-03,
     1  2.1104149E-03,  2.1128841E-03,  2.1142701E-03,  2.1156280E-03,
     1  2.1138871E-03,  2.1098880E-03,  2.1044570E-03,  2.0940171E-03,
     1  2.0774291E-03,  2.0558720E-03,  2.0256960E-03,  1.9842740E-03,
     1  1.9264980E-03,  1.8390430E-03,  1.6974290E-03,  1.4539430E-03,
     1  4.2225961E-02,  2.7117319E-02,  2.2547631E-02,  2.0068290E-02,
     1  1.8438401E-02,  1.7251231E-02,  1.6332360E-02,  1.5590820E-02,
     1  1.4973360E-02,  1.4447510E-02,  1.2491800E-02,  1.1394860E-02,
     1  1.0601890E-02,  9.9887215E-03,  9.4915954E-03,  9.0745213E-03,
     1  8.7156892E-03,  8.4016547E-03,  8.1224041E-03,  7.8710224E-03,
     1  7.6426100E-03,  7.4331458E-03,  7.2398861E-03,  7.0605958E-03,
     1  6.8934280E-03,  6.7366152E-03,  6.5888362E-03,  6.4494112E-03,
     1  5.9580570E-03,  5.5461042E-03,  5.1924409E-03,  4.8823762E-03,
     1  4.6068048E-03,  4.3593892E-03,  4.1354569E-03,  3.9316169E-03,
     1  3.7452469E-03,  3.5743651E-03,  3.4172670E-03,  3.2726100E-03,
     1  3.1393189E-03,  3.0165140E-03,  2.9034649E-03,  2.7995310E-03,
     1  2.7041410E-03,  2.6172239E-03,  2.5370270E-03,  2.4598311E-03/
      DATA X16/
     1  2.3926201E-03,  2.3454840E-03,  2.3129859E-03,  2.2895939E-03,
     1  2.2721870E-03,  2.2591639E-03,  2.2510469E-03,  2.2476800E-03,
     1  2.2487880E-03,  2.2542330E-03,  2.2638519E-03,  2.2774190E-03,
     1  2.2947509E-03,  2.3156649E-03,  2.3401950E-03,  2.3572459E-03,
     1  2.3753559E-03,  2.3949600E-03,  2.4157700E-03,  2.4377210E-03,
     1  2.4610830E-03,  2.4856499E-03,  2.5116459E-03,  2.5392659E-03,
     1  2.5685520E-03,  2.6005821E-03,  2.6371579E-03,  2.6776290E-03,
     1  2.7287400E-03,  2.8346381E-03,  5.2219719E-02,  3.3514939E-02,
     1  2.8033970E-02,  2.5071859E-02,  2.3124769E-02,  2.1699760E-02,
     1  2.0601559E-02,  1.9712280E-02,  1.8964190E-02,  1.8333539E-02,
     1  1.5962031E-02,  1.4607030E-02,  1.3632070E-02,  1.2873070E-02,
     1  1.2252740E-02,  1.1730450E-02,  1.1279610E-02,  1.0883400E-02,
     1  1.0530040E-02,  1.0211120E-02,  9.9203968E-03,  9.6532200E-03,
     1  9.4064986E-03,  9.1772350E-03,  8.9627076E-03,  8.7612905E-03,
     1  8.5716723E-03,  8.3920937E-03,  7.7578551E-03,  7.2264089E-03,
     1  6.7693810E-03,  6.3689412E-03,  6.0136979E-03,  5.6957770E-03,
     1  5.4091769E-03,  5.1494241E-03,  4.9130539E-03,  4.6974742E-03,
     1  4.5005828E-03,  4.3206960E-03,  4.1564079E-03,  4.0064380E-03,
     1  3.8696979E-03,  3.7449489E-03,  3.6315599E-03,  3.5306020E-03/
      DATA X17/
     1  3.4407710E-03,  3.3580731E-03,  3.2874879E-03,  3.2365799E-03,
     1  3.1993161E-03,  3.1703301E-03,  3.1480431E-03,  3.1314499E-03,
     1  3.1205520E-03,  3.1149969E-03,  3.1143511E-03,  3.1181369E-03,
     1  3.1259190E-03,  3.1373680E-03,  3.1521199E-03,  3.1697501E-03,
     1  3.1896201E-03,  3.2028719E-03,  3.2165810E-03,  3.2309929E-03,
     1  3.2452100E-03,  3.2594600E-03,  3.2738380E-03,  3.2874369E-03,
     1  3.3000309E-03,  3.3119919E-03,  3.3226500E-03,  3.3321481E-03,
     1  3.3404939E-03,  3.3468520E-03,  3.3553620E-03,  3.3983320E-03,
     1  5.8743682E-02,  3.7697628E-02,  3.1536300E-02,  2.8202901E-02,
     1  2.6008440E-02,  2.4401771E-02,  2.3160711E-02,  2.2154870E-02,
     1  2.1309830E-02,  2.0595061E-02,  1.7907031E-02,  1.6372420E-02,
     1  1.5264450E-02,  1.4401730E-02,  1.3697040E-02,  1.3103580E-02,
     1  1.2591390E-02,  1.2141320E-02,  1.1740020E-02,  1.1377970E-02,
     1  1.1048100E-02,  1.0745110E-02,  1.0465340E-02,  1.0205410E-02,
     1  9.9623594E-03,  9.7342664E-03,  9.5195770E-03,  9.3164369E-03,
     1  8.5998829E-03,  8.0003953E-03,  7.4859071E-03,  7.0360280E-03,
     1  6.6377530E-03,  6.2819938E-03,  5.9619071E-03,  5.6724120E-03,
     1  5.4095541E-03,  5.1703509E-03,  4.9523469E-03,  4.7535910E-03,
     1  4.5724781E-03,  4.4075618E-03,  4.2576171E-03,  4.1213622E-03/
      DATA X18/
     1  3.9980621E-03,  3.8884019E-03,  3.7911150E-03,  3.7026750E-03,
     1  3.6274060E-03,  3.5718540E-03,  3.5300469E-03,  3.4968171E-03,
     1  3.4709561E-03,  3.4516021E-03,  3.4386241E-03,  3.4316301E-03,
     1  3.4301539E-03,  3.4337270E-03,  3.4419040E-03,  3.4543071E-03,
     1  3.4705400E-03,  3.4901670E-03,  3.5125960E-03,  3.5277500E-03,
     1  3.5435909E-03,  3.5602599E-03,  3.5770859E-03,  3.5942029E-03,
     1  3.6116249E-03,  3.6286940E-03,  3.6452410E-03,  3.6615250E-03,
     1  3.6771190E-03,  3.6923201E-03,  3.7074699E-03,  3.7227180E-03,
     1  3.7439619E-03,  3.8061589E-03,  8.1025593E-02,  5.1805388E-02,
     1  4.3304719E-02,  3.8700130E-02,  3.5660509E-02,  3.3433668E-02,
     1  3.1706128E-02,  3.0304009E-02,  2.9128660E-02,  2.8128570E-02,
     1  2.4366761E-02,  2.2222230E-02,  2.0665251E-02,  1.9452929E-02,
     1  1.8464061E-02,  1.7631330E-02,  1.6913220E-02,  1.6282620E-02,
     1  1.5720880E-02,  1.5214650E-02,  1.4754060E-02,  1.4331620E-02,
     1  1.3941790E-02,  1.3579930E-02,  1.3242140E-02,  1.2925550E-02,
     1  1.2627810E-02,  1.2346650E-02,  1.1358150E-02,  1.0534980E-02,
     1  9.8322602E-03,  9.2209848E-03,  8.6826626E-03,  8.2041733E-03,
     1  7.7757882E-03,  7.3903599E-03,  7.0422250E-03,  6.7270878E-03,
     1  6.4413738E-03,  6.1822422E-03,  5.9473729E-03,  5.7347328E-03/
      DATA X19/
     1  5.5425921E-03,  5.3694039E-03,  5.2140332E-03,  5.0761942E-03,
     1  4.9545900E-03,  4.8466451E-03,  4.7548581E-03,  4.6831118E-03,
     1  4.6260380E-03,  4.5792018E-03,  4.5419158E-03,  4.5134891E-03,
     1  4.4934689E-03,  4.4813058E-03,  4.4764141E-03,  4.4782320E-03,
     1  4.4862069E-03,  4.4997870E-03,  4.5184209E-03,  4.5415210E-03,
     1  4.5684152E-03,  4.5868158E-03,  4.6062111E-03,  4.6265111E-03,
     1  4.6473299E-03,  4.6685622E-03,  4.6900129E-03,  4.7112638E-03,
     1  4.7320588E-03,  4.7522541E-03,  4.7714650E-03,  4.7896621E-03,
     1  4.8068468E-03,  4.8232209E-03,  4.8435372E-03,  4.8936112E-03,
     1  0.1040283    ,  6.6138409E-02,  5.5203371E-02,  4.9283199E-02,
     1  4.5371450E-02,  4.2505480E-02,  4.0278040E-02,  3.8469430E-02,
     1  3.6954790E-02,  3.5662871E-02,  3.0803630E-02,  2.8036101E-02,
     1  2.6023149E-02,  2.4456641E-02,  2.3180190E-02,  2.2105930E-02,
     1  2.1180321E-02,  2.0368170E-02,  1.9645359E-02,  1.8994629E-02,
     1  1.8403189E-02,  1.7861310E-02,  1.7361689E-02,  1.6898289E-02,
     1  1.6466239E-02,  1.6061720E-02,  1.5681600E-02,  1.5323080E-02,
     1  1.4065690E-02,  1.3022480E-02,  1.2135300E-02,  1.1366410E-02,
     1  1.0691760E-02,  1.0094180E-02,  9.5610088E-03,  9.0829646E-03,
     1  8.6526452E-03,  8.2644243E-03,  7.9136379E-03,  7.5965519E-03/
      DATA X20/
     1  7.3100971E-03,  7.0516262E-03,  6.8188822E-03,  6.6099339E-03,
     1  6.4232219E-03,  6.2577599E-03,  6.1120731E-03,  5.9839692E-03,
     1  5.8746170E-03,  5.7860850E-03,  5.7136491E-03,  5.6534698E-03,
     1  5.6049041E-03,  5.5671991E-03,  5.5396631E-03,  5.5215680E-03,
     1  5.5121649E-03,  5.5107391E-03,  5.5165542E-03,  5.5288621E-03,
     1  5.5468869E-03,  5.5698110E-03,  5.5967132E-03,  5.6150900E-03,
     1  5.6343358E-03,  5.6542000E-03,  5.6742900E-03,  5.6942841E-03,
     1  5.7137851E-03,  5.7322490E-03,  5.7491292E-03,  5.7638190E-03,
     1  5.7754712E-03,  5.7832049E-03,  5.7857712E-03,  5.7814210E-03,
     1  5.7699601E-03,  5.7602781E-03,  0.1275606    ,  8.0612533E-02,
     1  6.7172498E-02,  5.9904631E-02,  5.5101741E-02,  5.1583592E-02,
     1  4.8847131E-02,  4.6625141E-02,  4.4765349E-02,  4.3177310E-02,
     1  3.7205949E-02,  3.3808030E-02,  3.1335451E-02,  2.9412590E-02,
     1  2.7847189E-02,  2.6530709E-02,  2.5397271E-02,  2.4403561E-02,
     1  2.3519890E-02,  2.2725010E-02,  2.2003161E-02,  2.1342410E-02,
     1  2.0733600E-02,  2.0169379E-02,  1.9643789E-02,  1.9152099E-02,
     1  1.8690391E-02,  1.8255301E-02,  1.6732279E-02,  1.5472360E-02,
     1  1.4403970E-02,  1.3480580E-02,  1.2672550E-02,  1.1958650E-02,
     1  1.1323270E-02,  1.0755000E-02,  1.0244660E-02,  9.7853234E-03/
      DATA X21/
     1  9.3712294E-03,  8.9977477E-03,  8.6610606E-03,  8.3578937E-03,
     1  8.0854669E-03,  7.8414036E-03,  7.6237069E-03,  7.4308449E-03,
     1  7.2610872E-03,  7.1123191E-03,  6.9847368E-03,  6.8791430E-03,
     1  6.7913048E-03,  6.7177848E-03,  6.6578118E-03,  6.6104950E-03,
     1  6.5749269E-03,  6.5501910E-03,  6.5353522E-03,  6.5295040E-03,
     1  6.5317149E-03,  6.5410021E-03,  6.5563498E-03,  6.5766778E-03,
     1  6.6007129E-03,  6.6170078E-03,  6.6338582E-03,  6.6508218E-03,
     1  6.6674249E-03,  6.6831470E-03,  6.6973530E-03,  6.7092539E-03,
     1  6.7179552E-03,  6.7223739E-03,  6.7210272E-03,  6.7120488E-03,
     1  6.6926992E-03,  6.6587310E-03,  6.6043008E-03,  6.5211039E-03,
     1  0.1514974    ,  9.5177233E-02,  7.9178073E-02,  7.0538603E-02,
     1  6.4830743E-02,  6.0651090E-02,  5.7399228E-02,  5.4759089E-02,
     1  5.2550230E-02,  5.0663181E-02,  4.3570459E-02,  3.9537989E-02,
     1  3.6604028E-02,  3.4324020E-02,  3.2469358E-02,  3.0910740E-02,
     1  2.9569799E-02,  2.8395001E-02,  2.7351050E-02,  2.6412670E-02,
     1  2.5561109E-02,  2.4782199E-02,  2.4064980E-02,  2.3400730E-02,
     1  2.2782389E-02,  2.2204310E-02,  2.1661820E-02,  2.1150939E-02,
     1  1.9365359E-02,  1.7891690E-02,  1.6644839E-02,  1.5569520E-02,
     1  1.4630470E-02,  1.3802420E-02,  1.3066820E-02,  1.2410110E-02/
      DATA X22/
     1  1.1821370E-02,  1.1292320E-02,  1.0816160E-02,  1.0387380E-02,
     1  1.0001380E-02,  9.6542649E-03,  9.3427524E-03,  9.0639610E-03,
     1  8.8154506E-03,  8.5952682E-03,  8.4014107E-03,  8.2316352E-03,
     1  8.0853980E-03,  7.9626068E-03,  7.8593511E-03,  7.7724191E-03,
     1  7.7008209E-03,  7.6435129E-03,  7.5994749E-03,  7.5675612E-03,
     1  7.5465669E-03,  7.5354329E-03,  7.5330320E-03,  7.5380919E-03,
     1  7.5493501E-03,  7.5655570E-03,  7.5847539E-03,  7.5975191E-03,
     1  7.6106321E-03,  7.6230960E-03,  7.6345601E-03,  7.6442808E-03,
     1  7.6513411E-03,  7.6545598E-03,  7.6526720E-03,  7.6443041E-03,
     1  7.6271929E-03,  7.5984579E-03,  7.5538680E-03,  7.4865660E-03,
     1  7.3851622E-03,  7.2250650E-03,  0.1757520    ,  0.1098005    ,
     1  9.1199674E-02,  8.1170328E-02,  7.4547201E-02,  6.9699340E-02,
     1  6.5927483E-02,  6.2865853E-02,  6.0305230E-02,  5.8117241E-02,
     1  4.9897380E-02,  4.5228161E-02,  4.1832171E-02,  3.9194990E-02,
     1  3.7051380E-02,  3.5251129E-02,  3.3703301E-02,  3.2348119E-02,
     1  3.1144639E-02,  3.0063530E-02,  2.9083060E-02,  2.8186770E-02,
     1  2.7361929E-02,  2.6598429E-02,  2.5888121E-02,  2.5224401E-02,
     1  2.4601890E-02,  2.4015959E-02,  2.1970620E-02,  2.0285759E-02,
     1  1.8862801E-02,  1.7637691E-02,  1.6569570E-02,  1.5629111E-02/
      DATA X23/
     1  1.4794860E-02,  1.4051150E-02,  1.3385230E-02,  1.2787460E-02,
     1  1.2250150E-02,  1.1766920E-02,  1.1332260E-02,  1.0941720E-02,
     1  1.0591640E-02,  1.0278380E-02,  9.9989790E-03,  9.7514642E-03,
     1  9.5335664E-03,  9.3425699E-03,  9.1773923E-03,  9.0374406E-03,
     1  8.9188637E-03,  8.8184578E-03,  8.7348502E-03,  8.6669801E-03,
     1  8.6141266E-03,  8.5747810E-03,  8.5471002E-03,  8.5300906E-03,
     1  8.5225329E-03,  8.5225943E-03,  8.5288072E-03,  8.5403472E-03,
     1  8.5529182E-03,  8.5605374E-03,  8.5693756E-03,  8.5759787E-03,
     1  8.5812993E-03,  8.5843112E-03,  8.5835336E-03,  8.5768439E-03,
     1  8.5626319E-03,  8.5401554E-03,  8.5058408E-03,  8.4557813E-03,
     1  8.3844597E-03,  8.2823345E-03,  8.1329802E-03,  7.8957845E-03,
     1   27.35557    ,   8.723419    ,   5.101070    ,   3.575869    ,
     1   2.739483    ,   2.212711    ,   1.851154    ,   1.587975    ,
     1   1.388031    ,   1.231104    ,  0.7523072    ,  0.5472383    ,
     1  0.4246642    ,  0.3446542    ,  0.2884674    ,  0.2467923    ,
     1  0.2146909    ,  0.1892241    ,  0.1685560    ,  0.1514659    ,
     1  0.1371127    ,  0.1248987    ,  0.1143875    ,  0.1052530    ,
     1  9.7247086E-02,  9.0177663E-02,  8.3893538E-02,  7.8274056E-02,
     1  6.0773749E-02,  4.8552979E-02,  3.9634850E-02,  3.2850411E-02/
      DATA X24/
     1  2.7567260E-02,  2.3359921E-02,  1.9946439E-02,  1.7142260E-02,
     1  1.4805750E-02,  1.2841750E-02,  1.1175680E-02,  9.7524170E-03,
     1  8.5289916E-03,  7.4715479E-03,  6.5535530E-03,  5.7532541E-03,
     1  5.0532599E-03,  4.4391430E-03,  3.8990171E-03,  3.4229481E-03,
     1  3.0025649E-03,  2.6308210E-03,  2.3016760E-03,  2.0099899E-03,
     1  1.7513240E-03,  1.5218520E-03,  1.3182550E-03,  1.1376360E-03,
     1  9.7747787E-04,  8.3556498E-04,  7.0996251E-04,  5.9896789E-04,
     1  5.0108612E-04,  4.1500450E-04,  3.3957069E-04,  2.9737910E-04,
     1  2.5873270E-04,  2.2343050E-04,  1.9129080E-04,  1.6214819E-04,
     1  1.3585421E-04,  1.1227580E-04,  9.1294278E-05,  7.2803530E-05,
     1  5.6705259E-05,  4.2899901E-05,  3.1292439E-05,  2.1631900E-05,
     1  1.3489280E-05,  4.3736750E-06,   74.86941    ,   19.41606    ,
     1   10.44092    ,   6.947249    ,   5.124557    ,   4.017803    ,
     1   3.279824    ,   2.755364    ,   2.365005    ,   2.064071    ,
     1   1.183329    ,  0.8258573    ,  0.6197465    ,  0.4896833    ,
     1  0.4008395    ,  0.3364129    ,  0.2877548    ,  0.2498206    ,
     1  0.2195174    ,  0.1948200    ,  0.1743523    ,  0.1571487    ,
     1  0.1425133    ,  0.1299312    ,  0.1190152    ,  0.1094682    ,
     1  0.1010585    ,  9.3603097E-02,  7.0825733E-02,  5.5352241E-02/
      DATA X25/
     1  4.4339351E-02,  3.6131911E-02,  2.9865179E-02,  2.4961740E-02,
     1  2.1046501E-02,  1.7878771E-02,  1.5275020E-02,  1.3114800E-02,
     1  1.1304370E-02,  9.7754933E-03,  8.4755681E-03,  7.3635830E-03,
     1  6.4078011E-03,  5.5824071E-03,  4.8670252E-03,  4.2448849E-03,
     1  3.7023150E-03,  3.2279980E-03,  2.8124771E-03,  2.4478720E-03,
     1  2.1274791E-03,  1.8456520E-03,  1.5975510E-03,  1.3790410E-03,
     1  1.1865640E-03,  1.0170410E-03,  8.6781348E-04,  7.3656160E-04,
     1  6.2127021E-04,  5.2017742E-04,  4.3174220E-04,  3.5461489E-04,
     1  2.8761051E-04,  2.5040630E-04,  2.1652020E-04,  1.8574161E-04,
     1  1.5787649E-04,  1.3274570E-04,  1.1018340E-04,  9.0035697E-05,
     1  7.2159193E-05,  5.6418241E-05,  4.2682579E-05,  3.0822790E-05,
     1  2.0703230E-05,  1.2141990E-05,  4.9615651E-06,  0.0000000E+00,
     1   99.85361    ,   23.10114    ,   11.82869    ,   7.627649    ,
     1   5.494513    ,   4.227000    ,   3.395676    ,   2.813688    ,
     1   2.385734    ,   2.059616    ,   1.130697    ,  0.7670979    ,
     1  0.5624516    ,  0.4361399    ,  0.3514833    ,  0.2909869    ,
     1  0.2459586    ,  0.2112534    ,  0.1837747    ,  0.1616210    ,
     1  0.1434916    ,  0.1283524    ,  0.1154861    ,  0.1045397    ,
     1  9.5157467E-02,  8.7015979E-02,  7.9874627E-02,  7.3564947E-02/
      DATA X26/
     1  5.4526370E-02,  4.1896451E-02,  3.3055268E-02,  2.6564781E-02,
     1  2.1679340E-02,  1.7908540E-02,  1.4939200E-02,  1.2573950E-02,
     1  1.0654280E-02,  9.0778116E-03,  7.7713500E-03,  6.6812830E-03,
     1  5.7651680E-03,  4.9904818E-03,  4.3322388E-03,  3.7697700E-03,
     1  3.2870460E-03,  2.8716540E-03,  2.5132080E-03,  2.2027290E-03,
     1  1.9330130E-03,  1.6982059E-03,  1.4929650E-03,  1.3130580E-03,
     1  1.1556940E-03,  1.0177670E-03,  8.9575863E-04,  7.8766362E-04,
     1  6.9219572E-04,  6.0754258E-04,  5.3214788E-04,  4.6471419E-04,
     1  4.0421361E-04,  3.4989571E-04,  3.0073570E-04,  2.7230359E-04,
     1  2.4560661E-04,  2.2030360E-04,  1.9645689E-04,  1.7378631E-04,
     1  1.5247249E-04,  1.3210300E-04,  1.1270250E-04,  9.4385301E-05,
     1  7.6954413E-05,  6.0423430E-05,  4.4805471E-05,  3.0146810E-05,
     1  1.6664349E-05,  4.8574730E-06,   123.0775    ,   29.70967    ,
     1   15.41149    ,   10.01293    ,   7.254667    ,   5.606328    ,
     1   4.521039    ,   3.758285    ,   3.195698    ,   2.765911    ,
     1   1.532368    ,   1.044215    ,  0.7681583    ,  0.5970331    ,
     1  0.4818864    ,  0.3994197    ,  0.3378464    ,  0.2903118    ,
     1  0.2526959    ,  0.2223137    ,  0.1973353    ,  0.1764963    ,
     1  0.1588972    ,  0.1438706    ,  0.1309197    ,  0.1196648    /
      DATA X27/
     1  0.1098106    ,  0.1011247    ,  7.4935131E-02,  5.7490770E-02,
     1  4.5302920E-02,  3.6362849E-02,  2.9643580E-02,  2.4462311E-02,
     1  2.0381371E-02,  1.7123669E-02,  1.4478770E-02,  1.2310870E-02,
     1  1.0514950E-02,  9.0153981E-03,  7.7542309E-03,  6.6867219E-03,
     1  5.7786158E-03,  5.0022388E-03,  4.3359431E-03,  3.7619430E-03,
     1  3.2659289E-03,  2.8362090E-03,  2.4630260E-03,  2.1382810E-03,
     1  1.8550690E-03,  1.6076480E-03,  1.3912400E-03,  1.2017750E-03,
     1  1.0357540E-03,  8.9018169E-04,  7.6249317E-04,  6.5046398E-04,
     1  5.5218040E-04,  4.6598131E-04,  3.9042739E-04,  3.2426679E-04,
     1  2.6641239E-04,  2.3404309E-04,  2.0433270E-04,  1.7710580E-04,
     1  1.5218490E-04,  1.2941311E-04,  1.0864760E-04,  8.9759436E-05,
     1  7.2630668E-05,  5.7156001E-05,  4.3240561E-05,  3.0800598E-05,
     1  1.9756750E-05,  1.0042650E-05,  1.6276661E-06,  0.0000000E+00,
     1   216.6799    ,   46.68130    ,   23.18680    ,   14.67344    ,
     1   10.43191    ,   7.943884    ,   6.329528    ,   5.208444    ,
     1   4.390163    ,   3.770310    ,   2.028064    ,   1.356770    ,
     1  0.9831431    ,  0.7552890    ,  0.6039667    ,  0.4967034    ,
     1  0.4173046    ,  0.3564903    ,  0.3086819    ,  0.2703070    ,
     1  0.2389568    ,  0.2129282    ,  0.1910425    ,  0.1724437    /
      DATA X28/
     1  0.1564870    ,  0.1426762    ,  0.1306276    ,  0.1200429    ,
     1  8.8367358E-02,  6.7494974E-02,  5.3049579E-02,  4.2528879E-02,
     1  3.4672938E-02,  2.8647980E-02,  2.3923909E-02,  2.0167951E-02,
     1  1.7126950E-02,  1.4639240E-02,  1.2580780E-02,  1.0862840E-02,
     1  9.4175152E-03,  8.1926910E-03,  7.1486481E-03,  6.2533468E-03,
     1  5.4818960E-03,  4.8140660E-03,  4.2335708E-03,  3.7270670E-03,
     1  3.2834839E-03,  2.8936930E-03,  2.5500450E-03,  2.2462129E-03,
     1  1.9769231E-03,  1.7376640E-03,  1.5245340E-03,  1.3342950E-03,
     1  1.1642320E-03,  1.0119480E-03,  8.7539549E-04,  7.5281039E-04,
     1  6.4269762E-04,  5.4379762E-04,  4.5497919E-04,  4.0416550E-04,
     1  3.5674730E-04,  3.1252971E-04,  2.7135969E-04,  2.3309620E-04,
     1  1.9764990E-04,  1.6488360E-04,  1.3472010E-04,  1.0712880E-04,
     1  8.2050778E-05,  5.9477999E-05,  3.9426021E-05,  2.1958191E-05,
     1  7.2156781E-06,  0.0000000E+00,   261.0377    ,   55.17038    ,
     1   27.17897    ,   17.11137    ,   12.12016    ,   9.202744    ,
     1   7.315240    ,   6.007488    ,   5.054904    ,   4.334537    ,
     1   2.317788    ,   1.544586    ,   1.115647    ,  0.8549424    ,
     1  0.6822623    ,  0.5601225    ,  0.4698735    ,  0.4008628    ,
     1  0.3466962    ,  0.3032722    ,  0.2678341    ,  0.2384503    /
      DATA X29/
     1  0.2137761    ,  0.1928262    ,  0.1748654    ,  0.1593326    ,
     1  0.1457940    ,  0.1339110    ,  9.8413073E-02,  7.5075127E-02,
     1  5.8959000E-02,  4.7240760E-02,  3.8504381E-02,  3.1812530E-02,
     1  2.6570629E-02,  2.2405980E-02,  1.9035989E-02,  1.6280601E-02,
     1  1.4001230E-02,  1.2099010E-02,  1.0498510E-02,  9.1418279E-03,
     1  7.9849102E-03,  6.9922688E-03,  6.1363559E-03,  5.3947759E-03,
     1  4.7495370E-03,  4.1859122E-03,  3.6917089E-03,  3.2568821E-03,
     1  2.8730270E-03,  2.5331890E-03,  2.2315260E-03,  1.9630990E-03,
     1  1.7236701E-03,  1.5096751E-03,  1.3181040E-03,  1.1463360E-03,
     1  9.9213200E-04,  8.5356733E-04,  7.2899810E-04,  6.1702909E-04,
     1  5.1643403E-04,  4.5887459E-04,  4.0514921E-04,  3.5505291E-04,
     1  3.0841041E-04,  2.6506869E-04,  2.2491001E-04,  1.8779900E-04,
     1  1.5364270E-04,  1.2238541E-04,  9.3964103E-05,  6.8355977E-05,
     1  4.5563509E-05,  2.5636940E-05,  8.6946666E-06,  0.0000000E+00,
     1   435.3956    ,   86.90373    ,   41.80924    ,   25.93665    ,
     1   18.17709    ,   13.68754    ,   10.80662    ,   8.823803    ,
     1   7.387858    ,   6.307271    ,   3.316495    ,   2.186219    ,
     1   1.565027    ,   1.191056    ,  0.9452117    ,  0.7723572    ,
     1  0.6452820    ,  0.5485501    ,  0.4729392    ,  0.4125369    /
      DATA X30/
     1  0.3633965    ,  0.3227885    ,  0.2887921    ,  0.2600014    ,
     1  0.2353754    ,  0.2141261    ,  0.1956462    ,  0.1794612    ,
     1  0.1313303    ,  9.9878579E-02,  7.8278556E-02,  6.2636293E-02,
     1  5.1018909E-02,  4.2147141E-02,  3.5213951E-02,  2.9716160E-02,
     1  2.5273381E-02,  2.1644890E-02,  1.8645000E-02,  1.6141851E-02,
     1  1.4035320E-02,  1.2248710E-02,  1.0723790E-02,  9.4138011E-03,
     1  8.2825376E-03,  7.3005832E-03,  6.4443750E-03,  5.6946911E-03,
     1  5.0356579E-03,  4.4542360E-03,  3.9395508E-03,  3.4825869E-03,
     1  3.0757100E-03,  2.7125201E-03,  2.3876079E-03,  2.0963510E-03,
     1  1.8348150E-03,  1.5996170E-03,  1.3878690E-03,  1.1970850E-03,
     1  1.0251290E-03,  8.7016128E-04,  7.3060882E-04,  6.5060949E-04,
     1  5.7580951E-04,  5.0596509E-04,  4.4081680E-04,  3.8017429E-04,
     1  3.2385491E-04,  2.7169159E-04,  2.2355730E-04,  1.7933280E-04,
     1  1.3894700E-04,  1.0234890E-04,  6.9528949E-05,  4.0544230E-05,
     1  1.5545709E-05,  0.0000000E+00,   646.1963    ,   122.8761    ,
     1   58.00315    ,   35.56541    ,   24.71753    ,   18.49166    ,
     1   14.52216    ,   11.80446    ,   9.845208    ,   8.376540    ,
     1   4.348077    ,   2.842571    ,   2.021111    ,   1.530201    ,
     1   1.209350    ,  0.9847733    ,  0.8203104    ,  0.6955385    /
      DATA X31/
     1  0.5983037    ,  0.5208333    ,  0.4579583    ,  0.4061219    ,
     1  0.3628156    ,  0.3262112    ,  0.2949560    ,  0.2680304    ,
     1  0.2446509    ,  0.2242050    ,  0.1635950    ,  0.1241562    ,
     1  9.7172327E-02,  7.7683412E-02,  6.3245222E-02,  5.2240908E-02,
     1  4.3654531E-02,  3.6854770E-02,  3.1364258E-02,  2.6882481E-02,
     1  2.3178849E-02,  2.0089449E-02,  1.7489130E-02,  1.5282670E-02,
     1  1.3398100E-02,  1.1778160E-02,  1.0378430E-02,  9.1618327E-03,
     1  8.0993259E-03,  7.1680709E-03,  6.3482458E-03,  5.6231529E-03,
     1  4.9810349E-03,  4.4114152E-03,  3.9026679E-03,  3.4466090E-03,
     1  3.0381950E-03,  2.6718001E-03,  2.3421319E-03,  2.0451180E-03,
     1  1.7772700E-03,  1.5356659E-03,  1.3175691E-03,  1.1203110E-03,
     1  9.4252778E-04,  8.4054703E-04,  7.4468477E-04,  6.5586192E-04,
     1  5.7213643E-04,  4.9428939E-04,  4.2202021E-04,  3.5482229E-04,
     1  2.9303081E-04,  2.3558379E-04,  1.8323721E-04,  1.3572531E-04,
     1  9.2987131E-05,  5.5140601E-05,  2.2440539E-05,  0.0000000E+00,
     1   887.7358    ,   161.9629    ,   75.27982    ,   45.72807    ,
     1   31.56858    ,   23.49486    ,   18.37359    ,   14.88208    ,
     1   12.37404    ,   10.49981    ,   5.395572    ,   3.504703    ,
     1   2.478795    ,   1.869240    ,   1.472646    ,   1.196022    /
      DATA X32/
     1  0.9940447    ,  0.8412092    ,  0.7223719    ,  0.6278800    ,
     1  0.5513343    ,  0.4883356    ,  0.4357847    ,  0.3914376    ,
     1  0.3536189    ,  0.3210715    ,  0.2928437    ,  0.2681946    ,
     1  0.1952974    ,  0.1479759    ,  0.1156999    ,  9.2430606E-02,
     1  7.5217873E-02,  6.2117349E-02,  5.1909111E-02,  4.3836590E-02,
     1  3.7317649E-02,  3.1990401E-02,  2.7597681E-02,  2.3944961E-02,
     1  2.0866970E-02,  1.8248949E-02,  1.6009210E-02,  1.4085870E-02,
     1  1.2428350E-02,  1.0982230E-02,  9.7126896E-03,  8.6030569E-03,
     1  7.6250890E-03,  6.7490260E-03,  5.9828088E-03,  5.3218110E-03,
     1  4.7207102E-03,  4.1649840E-03,  3.6704571E-03,  3.2310940E-03,
     1  2.8342670E-03,  2.4759390E-03,  2.1526159E-03,  1.8629270E-03,
     1  1.6019800E-03,  1.3602930E-03,  1.1452950E-03,  1.0234161E-03,
     1  9.0258737E-04,  8.0289069E-04,  6.9724949E-04,  6.0191762E-04,
     1  5.1588740E-04,  4.3346349E-04,  3.6266580E-04,  2.8846911E-04,
     1  2.2434370E-04,  1.6678900E-04,  1.1476610E-04,  6.8635061E-05,
     1  2.8805380E-05,  0.0000000E+00,   1155.378    ,   203.3927    ,
     1   93.32840    ,   56.25666    ,   38.62542    ,   28.62582    ,
     1   22.30954    ,   18.01812    ,   14.94452    ,   12.65347    ,
     1   6.450140    ,   4.168181    ,   2.935698    ,   2.206814    /
      DATA X33/
     1   1.734274    ,   1.405613    ,   1.166189    ,  0.9854434    ,
     1  0.8450831    ,  0.7336177    ,  0.6435294    ,  0.5694727    ,
     1  0.5076579    ,  0.4556479    ,  0.4114122    ,  0.3733182    ,
     1  0.3402504    ,  0.3115122    ,  0.2266835    ,  0.1713871    ,
     1  0.1339078    ,  0.1069155    ,  8.6935662E-02,  7.1746998E-02,
     1  5.9941899E-02,  5.0646689E-02,  4.3106049E-02,  3.6879729E-02,
     1  3.1817731E-02,  2.7698120E-02,  2.4189210E-02,  2.1158461E-02,
     1  1.8560950E-02,  1.6346140E-02,  1.4460100E-02,  1.2789580E-02,
     1  1.1293420E-02,  1.0006190E-02,  8.8681262E-03,  7.7897869E-03,
     1  6.9045229E-03,  6.2510609E-03,  5.5975011E-03,  4.8986198E-03,
     1  4.2948038E-03,  3.7840069E-03,  3.3179370E-03,  2.8938721E-03,
     1  2.5103409E-03,  2.1813309E-03,  1.8907360E-03,  1.5845520E-03,
     1  1.3347390E-03,  1.2044040E-03,  1.0309980E-03,  9.6657983E-04,
     1  8.1604719E-04,  6.9745298E-04,  6.0981372E-04,  5.0809782E-04,
     1  4.5356760E-04,  3.3907109E-04,  2.6162050E-04,  1.9633760E-04,
     1  1.3600360E-04,  8.1938277E-05,  3.4951219E-05,  0.0000000E+00,
     1   1445.374    ,   246.6208    ,   111.9399    ,   67.04169    ,
     1   45.82131    ,   33.84002    ,   26.29850    ,   21.18931    ,
     1   17.53891    ,   14.82375    ,   7.507156    ,   4.830741    /
      DATA X34/
     1   3.390712    ,   2.542411    ,   1.993933    ,   1.613477    ,
     1   1.336708    ,   1.128552    ,  0.9665902    ,  0.8378928    ,
     1  0.7346384    ,  0.6497681    ,  0.5779003    ,  0.5181314    ,
     1  0.4681676    ,  0.4248763    ,  0.3867162    ,  0.3542832    ,
     1  0.2586619    ,  0.1942811    ,  0.1517285    ,  0.1211197    ,
     1  9.8273538E-02,  8.0925167E-02,  6.7542493E-02,  5.7168569E-02,
     1  4.8566151E-02,  4.1141469E-02,  3.5463691E-02,  3.1280670E-02,
     1  2.7477279E-02,  2.3963051E-02,  2.1025360E-02,  1.8572681E-02,
     1  1.6504480E-02,  1.4610560E-02,  1.2852850E-02,  1.1390550E-02,
     1  1.0078700E-02,  8.6697415E-03,  7.6756072E-03,  7.2683268E-03,
     1  6.6642780E-03,  5.7230750E-03,  4.9448721E-03,  4.3521458E-03,
     1  3.8114670E-03,  3.3077761E-03,  2.8392631E-03,  2.4929640E-03,
     1  2.2130080E-03,  1.7640500E-03,  1.4943780E-03,  1.4044630E-03,
     1  1.0775370E-03,  1.2039690E-03,  9.2901592E-04,  7.5804692E-04,
     1  7.1806152E-04,  5.7975308E-04,  6.2475522E-04,  3.9058449E-04,
     1  2.9338320E-04,  2.2592751E-04,  1.5966150E-04,  9.7406679E-05,
     1  4.1206360E-05,  1.4518970E-06,  0.0000000E+00,  0.0000000E+00/
      END
      SUBROUTINE XCOR(Y,NP)
      IMPLICIT REAL*8(A-H,O-Z)
      DIMENSION Y(NP)
      N=1
      DO 10 IX=1,20,2
         Y(N)=DBLE(IX)/2000.0D0
      N=N+1
   10 CONTINUE
      DO 20 IX=30,200,10
         Y(N)=DBLE(IX)/2000.0D0
          N=N+1
   20 CONTINUE
      DO 30 IX=240,1600,40
         Y(N)=DBLE(IX)/2000.0D0
      N=N+1
   30 CONTINUE
      DO 40 IX=1625,1980,25
         Y(N)=DBLE(IX)/2000.0D0
      N=N+1
   40 CONTINUE
      RETURN
      END
*****************************************************************
      FUNCTION FINT(NARG,ARG,NENT,ENT,TABLE)
      IMPLICIT REAL*8(A-H,O-Z)
* CERN LIBRARY ROUTINE E104
      DIMENSION ARG(5),NENT(5),ENT(10),TABLE(10)
      DIMENSION D(5),NCOMB(5),IENT(5)
      KD=1
      M=1
      JA=1
         DO 5 I=1,NARG
      NCOMB(I)=1
      JB=JA-1+NENT(I)
         DO 2 J=JA,JB
      IF (ARG(I).LE.ENT(J)) GO TO 3
    2 CONTINUE
      J=JB
    3 IF (J.NE.JA) GO TO 4
      J=J+1
    4 JR=J-1
      D(I)=(ENT(J)-ARG(I))/(ENT(J)-ENT(JR))
      IENT(I)=J-JA
      KD=KD+IENT(I)*M
      M=M*NENT(I)
    5 JA=JB+1
      FINT=0.
   10 FAC=1.
      IADR=KD
      IFADR=1
         DO 15 I=1,NARG
      IF (NCOMB(I).EQ.0) GO TO 12
      FAC=FAC*(1.-D(I))
      GO TO 15
   12 FAC=FAC*D(I)
      IADR=IADR-IFADR
   15 IFADR=IFADR*NENT(I)
      FINT=FINT+FAC*TABLE(IADR)
      IL=NARG
   40 IF (NCOMB(IL).EQ.0) GO TO 80
      NCOMB(IL)=0
      IF (IL.EQ.NARG) GO TO 10
      IL=IL+1
         DO 50  K=IL,NARG
   50 NCOMB(K)=1
      GO TO 10
   80 IL=IL-1
      IF(IL.NE.0) GO TO 40
      RETURN
      END
