      SUBROUTINE UTCBLK(ICHIN,NWORD)
C.
C! - Blank a string of 32-bit words
C! - This subroutine is needed since VBLANK doesn't work properly for
C! - characters on VAX.
C.
C. - Author   : A. Putzer  - 87/08/18
C.
C.
C.   Arguments: -  ICHIN CHA*4 (input/output) Character string to be
C.                                            "blanked"
C.              -  NWORD INTE  (input) Number of 32-bit words to be
C.                                     "blanked"
C.  Comment   :    The order of the arguments which does not correspond
C.                to the ALEPH rules is kept as for the original VBLANK
C.
C ---------------------------------------------------------------------
      CHARACTER*4 ICHIN(*),BLANK
      DATA BLANK/'    '/
      DO 100  I=1,NWORD
 100  ICHIN(I) = BLANK
      RETURN
      END
