CDECK  ID>, NOMEM.
      SUBROUTINE NOMEM

      COMMON /MQCMOV/NQSYSS
      COMMON /MQCM/         NQSYSR,NQSYSL,NQLINK,LQWORG,LQWORK,LQTOL
     +,              LQSTA,LQEND,LQFIX,NQMAX, NQRESV,NQMEM,LQADR,LQADR2
      COMMON /QUNIT/ IQREAD,IQPRNT,IQPR2,IQLOG,IQPNCH,IQTTIN,IQTYPE
     +,              IQDLUN,IQFLUN,IQHLUN,IQCLUN,  NQUSED
      PARAMETER      (IQBDRO=25, IQBMAR=26, IQBCRI=27, IQBSYS=31)
      COMMON /QBITS/ IQDROP,IQMARK,IQCRIT,IQZIM,IQZIP,IQSYS
                         DIMENSION    IQUEST(30)
                         DIMENSION                 LQ(99), IQ(99), Q(99)
                         EQUIVALENCE (QUEST,IQUEST),    (LQUSER,LQ,IQ,Q)
      COMMON //      QUEST(30),LQUSER(7),LQMAIN,LQSYS(24),LQPRIV(7)
     +,              LQ1,LQ2,LQ3,LQ4,LQ5,LQ6,LQ7,LQSV,LQAN,LQDW,LQUP
     +, KADRV(9), LEXD,LEXH,LEXP,LPAM,LDECO, LADRV(14)
     +, NVOPER(6),MOPTIO(31),JANSW,JCARD,NDECKR,NVUSEB(14),MEXDEC(6)
     +, NVINC(6),NVUTY(16),NVIMAT(6),NVACT(6),NVGARB(6),NVWARN(6)
     +, NVARRQ(6),NVARR(10),IDARRV(10),NVARRI(12),NVCCP(10)
     +, NVDEP(19),MDEPAR,NVDEPL(6),  MWK(80),MWKX(80)
      DIMENSION      IDD(2),             IDP(2),             IDF(2)
      EQUIVALENCE
     +       (IDD(1),IDARRV(1)), (IDP(1),IDARRV(3)), (IDF(1),IDARRV(5))
C--------------    END CDE                             -----------------  ------


      WRITE (IQPRNT,9000) IDP,IDD
      WRITE (IQPRNT,9001) NQMAX,NVGARB(1),NVGARB(3)
      CALL PABEND

C9000 FORMAT ('0***  PATCHY STUCK FOR MEMORY IN P=',A8,3H D=,A8)         A8M
C9000 FORMAT ('0***  PATCHY STUCK FOR MEMORY IN P=',A6,A2,3H D=,A6,A2)   A6
C9000 FORMAT ('0***  PATCHY STUCK FOR MEMORY IN P=',A5,A3,3H D=,A5,A3)   A5
 9000 FORMAT ('0***  PATCHY STUCK FOR MEMORY IN P=',2A4,3H D=,2A4)       A4
 9001 FORMAT (6X,'PRESENT SIZE OF STORE     =',I6
     F/6X,'GAP AT START OF DECK WAS  =',I6
     F/6X,'GAP SECURITY IS SET TO    =',I6)
      END