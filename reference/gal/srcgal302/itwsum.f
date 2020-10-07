      SUBROUTINE ITWSUM
C.
C...ITWSUM  1.00  880407  15:11                        R.Beuselinck
C.
C!  Print run summary for ITC.
C.
C-----------------------------------------------------------------------
      SAVE
      PARAMETER (LFIL=6)
      COMMON /IOCOM/   LGETIO,LSAVIO,LGRAIO,LRDBIO,LINPIO,LOUTIO
      DIMENSION LUNIIO(LFIL)
      EQUIVALENCE (LUNIIO(1),LGETIO)
      COMMON /IOKAR/   TFILIO(LFIL),TFORIO(LFIL)
      CHARACTER TFILIO*60, TFORIO*4
C
      COMMON/ITSUMC/NEVHIT,NEVDIT,NTCUIT,NHCUIT,NDCUIT,DIGHIT,
     +      NTSMIT(10),NHSMIT(10),NDSMIT(10),NDHSIT(10)
      INTEGER NEVHIT,NEVDIT,NTCUIT,NHCUIT,NDCUIT,
     +      NTSMIT,NHSMIT,NDSMIT,NDHSIT
      REAL DIGHIT
C
C
      WRITE(LOUTIO,1000) NEVHIT, NEVDIT
      WRITE(LOUTIO,1001) NTSMIT
      WRITE(LOUTIO,1002) NHSMIT
      WRITE(LOUTIO,1003) NDSMIT
      WRITE(LOUTIO,1004) NDHSIT
C
 1000 FORMAT('1ITC Run Summary'//
     +' # events with ITC hits   = ',I10/
     +' # events with ITC digits = ',I10)
 1001 FORMAT(//' Number of track elements per event:'//
     +' Range   0       10        20        30        40        50',
     +'        60        70        80        90'/
     +' Entries ',1X,I6,9I10)
 1002 FORMAT(//' Number of hits per event:'//
     +' Range   0       50       100       150       200       250',
     +'       300       400       600       800'/
     +' Entries ',1X,I6,9I10)
 1003 FORMAT(//' Number of digits per event:'//
     +' Range   0       50       100       150       200       250',
     +'       300       400       600       800'/
     +' Entries ',1X,I6,9I10)
 1004 FORMAT(//' Fraction of hits giving digits per event:'//
     +' Range   0.      .2        .4        .6        .7       .75',
     +'        .8       .85        .9       .95        1.'/
     +' Entries ',1X,I6,9I10)
      END
