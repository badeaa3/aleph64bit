      CLOSE(LUN)
C - KRECL is the block length in bytes
      KRECL = KBYTREC ('DAF','DISK')
C - LWRDS is the block length in words
      LWRDS = KRECL/NBYTW
C - MRECL is the block length in the unit required by the machine
#if defined(ALEPH_DEC) || defined(ALEPH_SGI)
      MRECL = LWRDS
#else
      MRECL = KRECL
#endif
      OPEN(LUN,STATUS='OLD',FILE=TFIL,ACCESS='DIRECT',
     +     RECL=MRECL,IOSTAT=IST,ERR=98)
      


