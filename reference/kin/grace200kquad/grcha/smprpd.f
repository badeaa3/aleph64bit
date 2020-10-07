************************************************************************
      SUBROUTINE SMPRPD(APROP, AMOMQ, AMASSQ, AMAG)
      implicit real(16)(a-h,o-z)
      implicit integer (i-n)
      complex(16) APROP
      real(16)     AMOMQ, AMASSQ, AMAG
! This common can be everywhere, contains various switches
      COMMON / KeyKey /  KeyRad,KeyPhy,KeyTek,KeyMis,KeyDwm,KeyDwp
      save
*
*    Calculate denominator of propagator.
*
*     APROP  : in/out : product of denominator of propagators.
*     AMOMP  : input  : square of mementum.
*     AMASSQ : input  : square of mass.
*     AMAG   : input  : mass * width.
*-----------------------------------------------------------------------
      KeyWu  = MOD(KeyPhy,1000000)/100000
      KeyZet = MOD(KeyPhy,1000)/100
      if (keywu.ne.keyzet) write(*,*) 'I do not like key-wu-zet; smprpd'
      if (keywu.ne.keyzet) stop
      IF (AMOMQ .GT. 0) THEN
       IF ((AMASSQ.GT.100q0).and.(keywu.ne.1)) THEN
        APROP = - APROP*DCMPLX(AMOMQ - AMASSQ,amomq/amassq* AMAG)
       ELSE
        APROP = - APROP*DCMPLX(AMOMQ - AMASSQ, AMAG)
       ENDIF
      ELSE
        APROP = - APROP*DCMPLX(AMOMQ - AMASSQ, 0.0q0)
!        APROP = - APROP*DCMPLX(AMOMQ - AMASSQ, AMAG)
      ENDIF
 
*     CALL CTIME('SMPRPD')
      RETURN
      END
