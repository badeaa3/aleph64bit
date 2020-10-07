                 ==================================

          This is the first part of the BOS source file
          =============================================

This file contains the source for the complete BOS system for several
types of machines. The BOS source file contains at present just above
9 k card records and contains macros (e.g. common decks).
The source file has to be used as input to the well-known
preprocessor BCM, which produces the required machine version and
expands the macros.
The expanded source file is above 10 k cards.

BCM is a 500 card records program, written in standard FORTRAN77 and
requiring no additional library routines. It produces on FORTRAN unit 1
a file for FORTRAN77 compilation. An example for a BCM job is given
here:
   //F14BLOBS  JOB  ,CLASS=A,TIME=(0,30)
   /*JOBPARM LINES=30
   //* --------------------------------------------------------
   //*   B C M   PREPROCESSOR
   //*
   //   EXEC JFORTCLG
         BCM SOURCE
   //G.SYSIN DD *
   *VERSION IBM
   *READ 8
   //* OUTPUT FILE FOR FORTRAN77 CMPILATION
   //G.FT01F001 DD DSN=&&COMP,UNIT=FAST,SPACE=(CYL,(5,1),RLSE),
   //   DCB=(RECFM=FB,LRECL=80,BLKSIZE=2960),DISP=(NEW,PASS)
   //* INPUT FILE 8 = BOS (BCM-)SOURCE FILE
   //G.FT08F001 DD DSN=...,DISP=(OLD,KEEP)
   //* --------------------------------------------------------
   //*   F O R T R A N 7 7   COMPILATION
   //*
   // EXEC JFORTC
   //C.SYSIN DD DSN=&&COMP,DISP=(OLD,DELETE)

EXPORT of BOS          <<<<<======================<<<<<

The simplest way to export BOS is via EARN/BITNET. There are the two
possibilities:
  1) Complete, expanded version for one machine
  2) BCM- and BOS source (all versions)
There are less card records in possibility 2.). It may be necessary
to cut for transmission the complete file into several pieces.
Anyone, who receives the BOS file should agree, that
his name/instition is recorded with the first (comment) part of the
source file. This will simplify messages on updates etc.

Name and Earn-adress of the author are:
    V. Blobel
    F14BLO@DHHDESY3

    this is the end of the first part of the BOS source file
    ========================================================


The order in the BOS source file is as follows:
   this text
   Machine dependent macros
   Machine independent macros
   Subprogram decks

Control cards for machine versions:
 *VERSION IBM               (for IBM version)
 *VERSION IBM DESYIBM       (for IBM version at DESY)
 *VERSION VAX               (for VAX version)
 *VERSION GOULD             (for GOULD version)
 *VERSION CRAY              (for CRAY version)   NOT YET TESTED
 *VERSION APOLLO            (for APOLLO version) NOT YET TESTED


      This file contains three subroutines for short test of the
      BOS system.

      Subr. TESTB1 makes some calls to create banks and to print
      something.
      Subr. TESTB2 uses IO, it creates some banks, and writes
      some records using sequential files (BREAD,BWRITE).
      Units 1 and 2 are used. Note that you may need
      OPEN statements or JCL DD cards for these units. BUNIT
      is not called, therefore the default output mode is
      used, but can be changed to 'EPIO' by BUNIT calls in the
      MAIN program.
      This file  D O E S   N O T  contain a MAIN program, and
      the subroutine do not initialize BOS. The following
      MAIN program will do:

     PROGRAM TEST
     COMMON/BCS/IW(10000)
     CALL   BOS(IW,10000)
     CALL TESTB1
     CALL TESTB2
     STOP
     END

      Subr. TESTB3 initializes units 17 and 18 as direct access files,
      each with 100 records of 4000 bytes. In addition it uses the
      sequential file 19. Open statements or DD - cards are
      necessary as above.
      Some banks are written to unit 17 (da), then the da-ds is
      copied to the sequntial file 19, and the banks are loaded
      to unit 18 (da).

changes - june 87
On some machines there are special options in the open statement
for direct access (machine dependent). For direct access there
are OPEN statements in the subroutines INITDA AND BDABF. If these
do not work properly, the user may use his own local OPEN stmt
before the call od these subroutines. The subroutines will
recognize, that the units are already open and will not use
an additional OPEN statement.

The datasetname (argument DSN) has always to be specified.
A blank DSN (Manual) is not allowed.
Default is shared access. If exclusive access is required,
the user has to define
      IW(1)=1
before the call of BDABF.

NOTE ON POSSIBLE DIRECT ACCESS IO FOR EVENTS:

WRITE:
mofify BOSWR, check DIRECT by INQUIRE
add directory bank of buffer length for triples
   (nrun,nevt,irec)
write the directory bank, if full or at data end
add records to existing data set?

READ:
modify BOSRD, check DIRECT by INQUIRE
read like sequential data set, if used without BSEQR
With BSEQR: use (aleady existing data cards)
   SEVT nrun nevt nevt ...
to position file by call from BSEQR

WRITE SEVT:
introduce new subroutine WSEVT to add current event nr to
internal bank, with is written at data end to unit 6 (?) or
another unit.

Questions:
DISP=SHR possible with open (withoout JCL) ?
Optical disk with WRITE ONCE ?
Program crash during write - no directory written ?
                * * *
Changes 8. August 1988

1) Bank printout changed
   BBUFM modified (use of conversion routines instead of FORMAT stmt)
   CNVL  added (conversion routines)
   PNVI  added (conversion routines)
   PNVF  added (conversion routines)
   PNVZ  added (conversion routines)


2) Format free input changed
   CNVCHA modified (now longer strings and hex input possible)

3) Bank format routines modified
   BKFMT added (J and K code added)
   FPRNN added (format conversion)
   FPRNT added (user routine for printing)
   TRFMT added (format conversion)
   TRFMTRadded (routine for printing)

4) New IO mode - text records for all type of data
   BTEBF, BTERD, BTEWR, BTEWS

5) Utility routines for data copy
   BKTOAR, BKFRAR - for machine inependent transport of
                    non-standard arrays
   BKTOP, BKFRP   - for copy of vectors to/from banks

6) Free format input extended
   BREADC, MREADC

7) Direct access routines
   ALmost all modified
   BDAWA, BDAWE added - for faster writing of banks

8) ABBINS and ABBNIN added for record handling

9) BOSIO modified because of more IO modes

10) Selection of records using select files
   BSELW, BSELR added to write, read select files
   BOSRD, BOSWR, BREAD, BWRITE, BWRSB, BUNIT, BBFRD modified
   Format handling in IO modified
   BBEPF, BBFMT, BBOSF modified
   BSEQR modified

11) BOS (initialization modified)
   fast initialization for secondary arrays with negative common length
         (reduced book keeping)
   named banks start on a page boundary

