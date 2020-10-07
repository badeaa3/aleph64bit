      SUBROUTINE MUINCB(ISLOT,IPLANE,NSTRPF,NAST,NBUS,NSTRPB,IFLAG)
C-----------------------------------------------------------
C!  Transforms barrel slot and strip nb. to astros and bus nb.
C
C  Author :   A. Antonelli, F. Bossi 1 July 89
C.  -Called by MUDGTZ                  from this .HLB
C.  -Calls none
C.
C-----------------------------------------------------------
      INTEGER LMHLEN, LMHCOL, LMHROW
      PARAMETER (LMHLEN=2, LMHCOL=1, LMHROW=2)
C
      COMMON /BCS/   IW(1000)
      INTEGER IW
      REAL RW(1000)
      EQUIVALENCE (RW(1),IW(1))
C
      PARAMETER (NHTIN = 40 , INCHT = 10 , NAVTD = 4)
      COMMON/MUNAMC/ NAMUHT,NAMUDI,NAMUDT,NAMUTD,NAMUDG
     +             , NAMUOG,NAMBAG,NAMBSG,NAMBTG,NAMBBG
     +             , NAMECG,NAMEBG,NAMETG,NAMESG
     +             , NAMMAG,NAMMBG,NAMMTG,NAMMSG
     &             , JDMUST,JDMTHT
C
C! The parameters needed by the geometry routine AGMUCH
      PARAMETER (NMBIN = 12, NMBOU = 12 )
      PARAMETER (NMMIN = 10, NMMOU =  9, NMMA = NMMIN+NMMOU, IMMBT =  9)
      PARAMETER (NMCIN = 4, NMCOU = 4, NMCA = NMCIN+NMCOU)
      PARAMETER (NMMBI = NMMA+NMMIN, NMCBI = NMCA+NMCIN)
      COMMON /MUG1PR/   MMADPR(12,4)
C
      PARAMETER(JMUOID=1,JMUOVR=2,JMUONS=4,JMUOWI=5,JMUOHE=6,JMUOTU=7,
     +          JMUOAC=8,JMUOSP=9,JMUODI=10,JMUODE=11,JMUOXS=12,
     +          JMUOYS=13,JMUOSE=14,JMUOET=15,JMUOEX=16,JMUOEY=17,
     +          JMUOX1=18,JMUOX2=19,JMUOX3=20,JMUOX4=21,JMUOY1=22,
     +          JMUOY2=23,JMUOY3=24,JMUOY4=25,LMUOGA=25)
      PARAMETER(JMBAID=1,JMBAVR=2,JMBASU=4,JMBANB=5,JMBATH=6,JMBALE=7,
     +          JMBAR1=8,JMBAR2=9,JMBAPD=10,JMBAY1=11,JMBAY2=12,
     +          LMBAGA=12)
      PARAMETER(JMBSID=1,JMBSVR=2,JMBSNO=4,JMBSVO=5,JMBSZC=6,JMBSRC=7,
     +          JMBSDE=8,JMBST1=9,JMBST2=10,JMBSTA=11,JMBSNA=12,
     +          JMBSK1=13,JMBSK2=14,LMBSGA=14)
      PARAMETER(JMBTID=1,JMBTVR=2,JMBTNA=4,JMBTZB=5,JMBTRB=6,JMBTY1=7,
     +          JMBTY2=8,JMBTNX=9,JMBTZT=10,JMBTRT=11,JMBTW1=12,
     +          LMBTGA=12)
      PARAMETER(JMBBID=1,JMBBVR=2,JMBBB1=4,JMBBL1=5,JMBBU1=6,JMBBB2=7,
     +          JMBBL2=8,JMBBU2=9,JMBBB3=10,JMBBL3=11,JMBBU3=12,
     +          JMBBB4=13,JMBBL4=14,JMBBU4=15,JMBBP3=16,JMBBP4=17,
     +          LMBBGA=17)
      PARAMETER(JMECID=1,JMECVR=2,JMECSU=4,JMECNS=5,JMECZI=6,JMECZE=7,
     +          JMECPD=8,JMECTH=9,JMECDZ=10,JMECXO=11,LMECGA=11)
      PARAMETER(JMEBID=1,JMEBVR=2,JMEBB1=4,JMEBL1=5,JMEBU1=6,JMEBB2=7,
     +          JMEBL2=8,JMEBU2=9,JMEBB3=10,JMEBL3=11,JMEBU3=12,
     +          JMEBB4=13,JMEBL4=14,JMEBU4=15,LMEBGA=15)
      PARAMETER(JMETID=1,JMETVR=2,JMETNA=4,JMETXB=5,JMETYB=6,JMETX1=7,
     +          JMETX2=8,JMETYS=9,JMETPI=10,JMETNX=11,JMETNY=12,
     +          JMETNP=13,JMETN2=14,JMETN1=15,JMETLE=16,LMETGA=40)
      PARAMETER(JMESID=1,JMESVR=2,JMESNO=4,JMESXC=5,JMESYC=6,JMESZC=7,
     +          JMESTA=8,JMESNA=9,JMESK1=10,JMESK2=11,LMESGA=11)
      PARAMETER(JMMAID=1,JMMAVR=2,JMMASU=4,JMMANS=5,JMMAZ0=6,JMMAPD=7,
     +          JMMATH=8,JMMAPI=9,JMMADS=10,JMMAZ1=11,JMMATB=12,
     +          LMMAGA=12)
      PARAMETER(JMMBID=1,JMMBVR=2,JMMBNO=4,JMMBB1=5,JMMBO1=6,JMMBB2=7,
     +          JMMBO2=8,JMMBB3=9,JMMBO3=10,JMMBB4=11,JMMBO4=12,
     +          JMMBB5=13,JMMBO5=14,JMMBL1=15,JMMBU1=16,JMMBL2=17,
     +          JMMBU2=18,JMMBL3=19,JMMBU3=20,JMMBL4=21,JMMBU4=22,
     +          JMMBL5=23,JMMBU5=24,JMMBL6=25,JMMBU6=26,JMMBL7=27,
     +          JMMBU7=28,JMMBL8=29,JMMBU8=30,JMMBL9=31,JMMBU9=32,
     +          JMMBL0=33,JMMBU0=34,LMMBGA=34)
      PARAMETER(JMMTID=1,JMMTVR=2,JMMTNA=4,JMMTZB=5,JMMTRB=6,JMMTZT=7,
     +          JMMTRT=8,JMMTNX=9,LMMTGA=9)
      PARAMETER(JMMSID=1,JMMSVR=2,JMMSNO=4,JMMSL1=5,JMMSL2=6,JMMSR1=7,
     +          JMMSR2=8,JMMSTL=9,JMMSRL=10,JMMSNY=11,JMMSX1=12,
     +          JMMSX2=13,JMMSDZ=14,JMMSZC=15,JMMSRC=16,JMMSDE=17,
     +          JMMSNA=18,JMMSTA=19,JMMSOS=20,JMMSVO=21,JMMSK1=22,
     +          JMMSK2=23,LMMSGA=23)
C
      SAVE
      PARAMETER (NROW=34,NCOL=3,NROW1=26,NCOL1=16)
C
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
C!     INDICES OF MUON-BANKS FOR USE WITHIN ROUTINES
      JMBAG = IW(NAMBAG)
      JMUOG = IW(NAMUOG)
      JMBBG = IW(NAMBBG)
      JMBSG = IW(NAMBSG)
      JMBTG = IW(NAMBTG)
C
      JMECG = IW(NAMECG)
      JMEBG = IW(NAMEBG)
      JMETG = IW(NAMETG)
      JMESG = IW(NAMESG)
C
      JMMAG = IW(NAMMAG)
      JMMBG = IW(NAMMBG)
      JMMTG = IW(NAMMTG)
      JMMSG = IW(NAMMSG)
C
C
C........ Read astros type and astros number
        NTPAS= ITABL(JMBSG,ISLOT,JMBSTA)
        NAST = ITABL(JMBSG,ISLOT,JMBSNA)
C.......     Bus type      1= X1 =1    Nb. in MUHT
C                          2= Y1 =2
C                          3= X2 =4
C                          4= Y2 =3
C                          5= X3 =1
C                          6= Y3 =2
C                          7= X4 =4
C                          8= Y4 =3
C.......
        NBUSTY= IPLANE+4
        IF(ISLOT.LE.17) NBUSTY= IPLANE
        IF(IPLANE.EQ.3) NBUSTY = NBUSTY + 1
        IF(IPLANE.EQ.4) NBUSTY = NBUSTY - 1
C
        IREM=MOD(NBUSTY,2)
        JMPK2 = ITABL(JMBSG,ISLOT,JMBSK2)
C
        IF(IREM.GT.0) THEN
C
C       The readout direction for x strip is not always the same
C
             IF(ISLOT.GT.17) THEN
                 MSLOT = ISLOT-17
             ELSE
                 MSLOT=ISLOT
             ENDIF
             IF(MSLOT.EQ.12.OR.MSLOT.EQ.16) GO TO 2
             IF(MSLOT.EQ.1.OR.MSLOT.GE.8) THEN
                NMAX = ITABL(JMBTG,JMPK2,JMBTNX)
                NSTRPF = -(NSTRPF-NMAX)-1
             ENDIF
 2           CONTINUE
        ELSE
C
C       The readout direction for x strip is not always the same
C
             IF(ISLOT.GE.12.AND.ISLOT.LE.14) THEN
                 IF(NBUSTY.EQ.4.OR.NBUSTY.EQ.8) THEN
                   NMAX = ITABL(JMBTG,JMPK2,JMBTY1)
                   NSTRPF = -(NSTRPF-NMAX)-1
                 ENDIF
              ELSE
                 IF(NBUSTY.EQ.2.OR.NBUSTY.EQ.6) THEN
                    NMAX = ITABL(JMBTG,JMPK2,JMBTY1)
                    NSTRPF = -(NSTRPF-NMAX)-1
                 ENDIF
              ENDIF
        ENDIF
C
C       Astros type and astros number for slot 4D
C
        IF(NAST.NE.0) GO TO 100
        IF(NBUSTY.EQ.2.OR.NBUSTY.EQ.4) THEN
            NTPAS=3
            NAST = 126
        ELSE
            NTPAS=4
             NAST = 128
        END IF
100     CONTINUE
C
        KK=0
        NBUS=0
        NSTRPB=0
        IFLAG = 0
        INAS = 3*(NTPAS-1)
        DO 1 J=1,NROW1
        IFIND = ITABL(JMBBG,J,JMBBB1+INAS)
        IF(IFIND.NE.NBUSTY) GO TO 1
C.                 Bus x or type 2
        IF(IREM.GT.0.OR.NTPAS.EQ.2) THEN
                IPOIN=0
C.                 Type 4
                IF(NTPAS.EQ.4) THEN
                        IPTSLO = ITABL(JMBBG,J,JMBBP4)
                        IF(IPTSLO.NE.ISLOT) GO TO 1
                        NBUS=(J-1)/2
                 ELSE
C                   Slot 9, 11 A
                        IF(ISLOT.EQ.10.OR.ISLOT.EQ.14.OR.
     &                     ISLOT.EQ.27.OR.ISLOT.EQ.31) IPOIN=4
C                   Slot 9, 11 B
                        IF(ISLOT.EQ.12.OR.ISLOT.EQ.16.OR.
     &                     ISLOT.EQ.29.OR.ISLOT.EQ.33) IPOIN=8
                        MROW = J+IPOIN
                        NBUS = ITABL(JMBBG,MROW,JMBBID) - 1
                ENDIF
                LIN = ITABL(JMBBG,J+IPOIN,JMBBL1+INAS)
                LFIN= ITABL(JMBBG,J+IPOIN,JMBBU1+INAS)
                NDIFF=LFIN-LIN+1
                IF(NSTRPF.GT.NDIFF) GO TO 200
C
                NSTRPB= LIN+NSTRPF
                IFLAG = 1
                GO TO 200
C
        ELSE
C                   Bus Y
C                   Type 3 ,4
                IF(NTPAS.EQ.3) THEN
                      IPTSLO=ITABL(JMBBG,J,JMBBP3)
                      IF(IPTSLO.NE.ISLOT) GO TO 1
                END IF
                IF(NTPAS.EQ.4) THEN
                      IPTSLO=ITABL(JMBBG,J,JMBBP4)
                      IF(IPTSLO.NE.ISLOT) GO TO 1
                END IF
                KK=KK+1
                IF(KK.EQ.1)NSTPF1=NSTRPF+ITABL(JMBBG,J,JMBBL1+INAS)
                NFIN=ITABL(JMBBG,J,JMBBU1+INAS)
                IF(NSTPF1.GT.NFIN) GO TO 1
                NBUS=J-1
                IF(NTPAS.EQ.4) NBUS=J-3
                NSTRPB=NSTPF1-ITABL(JMBBG,J,JMBBL1+INAS)
                IF(KK.EQ.1) NSTRPB=NSTPF1
                IFLAG = 1
                GO TO 200
        END IF
1       CONTINUE
200     CONTINUE
        RETURN
        END
