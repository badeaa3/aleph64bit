      COMMON/TALIGN/ ASTOGL(3,3,LTSECT),DSTOGL(3,LTSECT),
     &               AGLTOS(3,3,LTSECT),DGLTOS(3,LTSECT),
     &               TAPRRD(LTPDRO,LTSTYP),TAPRPH(LTPDRO,LTSTYP),
     &               ASTOTP(3,3,LTSECT),DSTOTP(3,LTSECT),
     &               ATPTOS(3,3,LTSECT),DTPTOS(3,LTSECT)
C
#if defined(DOC)
C-----------------------------------------------------------------------
C Alignment matrices for transforming cartesian coordinates from the
C TPC sector frames to the global frame and vice-versa.  Here, the
C sector frame is defined to have its origin at the center of
C curvature of the sector padrows.  The x axis is along the sector
C symmetry axis, and the z axis is opposite the drift direction.
C Note that for endplate A, at positive z, the sector z axis is
C approximately opposite that of the global system.
C
C Matrices to go between global ALEPH system and sector system:
C
C ASTOGL(i,j,islot) = rotation from sector frame to global frame
C DSTOGL(i,islot)   = translation from sector frame to global frame
C AGLTOS(i,islot)   = rotation from global frame to sector frame
C DGLTOS(i,islot)   = translation from global frame to sector frame
C
C Matrices to go between TPC system and sector system:
C
C ASTOTP(i,j,islot) = rotation from sector frame to TPC frame
C DSTOTP(i,islot)   = translation from sector frame to TPC frame
C ATPTOS(i,j,islot) = rotation from TPC frame to sector frame
C DTPTOS(i,islot)   = translation from TPC frame to sector frame
C
C To transform the coordinate Xs from sector to global:
C
C          Xg(i)= ASTOGL(i,j)*Xs(j) + DSTOGL(i)
C
C To transform the coordinate Xg from global to sector:
C
C          Xs(i)= AGLTOS(i,j)*Xg(j) + DGLTOS(i)
C
C    TAPRRD(irow,ist)=  padrow offset in radius
C    TAPRPH(irow,ist)=  padrow offset in phi
C
C-----------------------------------------------------------------------
#endif
