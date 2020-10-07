C! 1st entry in E_set
 * corr file 310.1
    EFIXI99: Drop run header bank EDDB at start of 1999 (M.-N.Minard)

 ! JULIA 310
    EFOLMK,ESVETO : Increase energy cut to 250 GeV  (M.-N.Minard)

 * corr file 308.02
    EPRTPC : Protect against divide by zero (M.Cattaneo)

 ! JULIA 307
    ECSW94 : EXIT JULIA if EAGC cards are missing when required
             (1994 raw data, run range 25000-25893)                (M.Cattaneo)

 * corr file 305.02
    ECLAMP : Rescale cut to effective threshold. Affects MC only (M.N.Minard)
    ECMOD  : Bug fix for overlap region (G.Taylor)

 ! JULIA 305
    EINIRU : Remove 'Temporary' (since before 1993!) call to EFIX  (M.Cattaneo)
    EFIX   : DELETED from library (was supposed to be temporary fix pending
             Alephlib fix, and did not have intended effect)       (M.Cattaneo)
    ETHRES : Rename 'LOCAL' common for work bank indices to 
             something more unique (CMETHR)                        (M.Cattaneo)
    E4BARY,E4FDIJ,EFIJOB : fix variable type inconsistencies in 
                           function calls, for Linux               (A.Waananen)

 * corr file 304.01
    EBOXHI : Remove CALL from function references, for Linux. (A.Waananen)

 * corr file 303.06
    EPRTPC : Comment call to UFITQL (results are never used!!) (M.Cattaneo)

 ! JULIA 302 (Tracking upgrade)
    EPRTPC : Extrapolate to ECAL from outermost TPC coordinate. (D.Casper)
             Do not extrapolate incoming tracks of kink.
             Can be disabled with ENKF card.

 * corr file 283.01
   ECCLUS : Change level of error 1 from Fatal to Warning

 ! JULIA 282
   EGETDS : Replace LENOCC by LNBLNK (M.Cattaneo, July 1996)

 * corr file 280.01
   E4FNEC : protect against divide by A(1)=0.   (D.Pallin, Mar 96)
   ECGFLW : protect against bad MonteCarlo data (M.Cattaneo, Mar 96)
   EPADCL : protect against bad MonteCarlo data (M.Cattaneo, Mar 96)

 ! JULIA 280

   EIDEDX : call TPDHYP('WIRE', instead of TIDHYP. (FLR)
   ECSW94,ECBOOK,ELECID : opening "'" should have a closing "'" within
           the same line for cvs (F. Ranjard, Feb 96)
 ! JULIA 279

 * corr file 278.1
   ECSW1093 : move DATA statement just before BMACRO to allow
             compilation in Linox (P. Comas, Oct 95)
 ! JULIA 278

 * corr file 277.3
   ECFIBT : PWEI bank corrected for calibration and change fatal
           error by warning error when EWDI does not exist
           (M.N.Minard, Aug 95)
   ECFILS : change fatal error by warning error when EWDI does not
           exist (M.N.Minard, Aug 95)
   ECHEDC : bug fix when applying calibration (M.N. Minard, Aug 95)
 ! JULIA 277
 * corr file 276.4
   EDWIJJ,PWEIJJ : new common decks added (M.N. Minard, May 95)
   EWDIFP : addapt to bunch trains and use of PWEI
                  (M.N. Minard, Apr 95)
   ECERAS,CPADWR : use of PWEI (M.N. Minard, Apr 95)
   ECFILS : check the Pastis configuration - 1995 and call ECFIBT
           (M.N. Minard, Apr 95)
   EPADCL,EWIRCL,ETDIFP,ECHEDC,ECHICA : addapt to bunch trains
                                (M.N. Minard, Apr 95)
   ECFIBT : new routine for wires banks analysis in bunch trains
           (M.N. Minard, Apr 95)
 ! JULIA 276
   EFIXI94: artificially built EKLS bank of zero length to put to
           zero the number of killed channels (M.N.Minard, Apr 1994)

 * corr file 275.4
   ECCLUS : ESDA internal storey bank used in clusterisation is dropped
           when cluster bank is dropped (M.N. Minard, Feb 1995)
 ! JULIA 275
   EAGCJJ : new common deck added (M.N. Minard, Oct 1994)
   EGETDS : for 94 running drop EKLS EKPL wrong on the header (same)
   EPREDA : in case of raw data from run range 1994 (<25854)
           swap gain map of endcap A (same)
   EFIXI94: new subroutine to drop EKLS EKPL banks (same)
   ECSW94 : new subroutine to swap gain for ETDI, active only on 1994
           raw data run<25894 (same)
 ! JULIA 274
 * corr file 273.1
   EQRUNQ : changes due to new ECAL banks (May 1994)
   EFERRR : changes due to new ECAL banks (May 1994)
   EPREDA : changes due to new ECAL banks (May 1994)
   EAUTOP : new subroutine to decode banks EHWI and EHPA and
           summarize (condense) into arrays NAUTO and NAUTOW
   ECXMOD : (new) decode the EHPA data word and convert into a module
           number
 ! JULIA 273
 ! JULIA 272
 * corr file 271.8
   ERCUPI : initialize ICOR=0 which means returns from ERCUPR
            without correcting ETDI energies.
   ERCUPR : returns immediately when ICOR=0
   ESWPST : returns immediately if MC data
 * corr file 271.7
   ECSW1093 : new routine to fix ETDI swapping in end-cap for runs
              22793-22880.
   EPREDA   : call ECSW1093.
 * corr file 271.6
   ECTRAP : protection against invalid storey address.
 * corr file 271.5
   ECLONGI : new stuff.
