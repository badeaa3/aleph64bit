*CD hcpara
      PARAMETER (LPHC=3,LSHC=3,LPECA=1,LPECB=3,LPBAR=2)
      PARAMETER (LHCNL=23,LHCSP=2,LHCTR=62,LHCRE=3)
      PARAMETER (LHCNO = 3)
      PARAMETER (LPHCT = 4)
      PARAMETER (LPHCBM = 24,LPHCES = 6)
#if defined(DOC)
C!    Parameters for Hadron Calorimeter
        LPHC  numer of subdetectors (3)
        LSHC  number of subparts (3)
        LPECA identification number for endcap A (1)
        LPECB identification number for endcap B (3)
        LPBAR identification number for barrel (2)
        LHCNL # of planes (barrel) (23)
        LHCSP # max of spacers in a plane (barrel) (2)
        LHCTR  # of tower rows (62)
        LHCRE  # of theta regions (3)
        LHCNO  # of notches (3)
        LPHCT # of iron spacers in end-cap sextants
        LPHCBM # of Barrel Modules (24)
        LPHCES # of end-cap petals (6)
#endif
