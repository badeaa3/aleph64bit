c----------------------------------------------
c     Initialzation table generated by grcpar
c----------------------------------------------
      parameter( maxact =  84 )
      parameter( maxdi4 =  27 )
      parameter( maxdr8 =  56 )
      parameter( maxdc8 =   1 )
       character*12 grcpky(0:maxact-1)
            integer i4data(0:maxdi4-1)
             real*8 r8data(0:maxdr8-1)
        character*8 c8data(0:maxdc8-1)
      common /cgrcky/ grcpky
      common /cgrci4/ i4data
      common /cgrcr8/ r8data
      common /cgrcc8/ c8data
      common /cgrcwk/ ikyadr(0:maxact-1),ikytyp(0:maxact-1),
     .                keytch(0:maxact-1)

