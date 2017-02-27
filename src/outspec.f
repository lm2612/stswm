      SUBROUTINE OUTSPEC(ZETASC,DIVSC,PHISC,PHIBAR,OCTR)
C                                                                              
C OUTPUT SPECTRAL FIELDS TO SIMPLE FORMAT FILE
C
C CALLED BY: STSWM
C CALLS: 
C
C REVISIONS:
C 02-02-2017 INTRODUCED (J. METHVEN)
C
C---- Model Parameters -------------------------------------------------
C
      INCLUDE 'params.i'
C
C---- Common Blocks ----------------------------------------------------
C
C Constants
      INCLUDE 'consts.i'
C
C------------ Arguments ------------------------------------------------
C
C     Input
C
C VORTICITY COEFFICIENTS
      COMPLEX ZETASC(NALP)
C DIVERGENCE COEFFICIENTS
      COMPLEX DIVSC(NALP)
C GEOPOTENTIAL COEFFICIENTS
      COMPLEX PHISC(NALP)
C GLOBAL MEAN STEADY GEOPOTENTIAL
      REAL PHIBAR
C ARRAY INDICES
      INTEGER LDIAG(0:NN,2)
C LABEL FOR SPECTRAL OUTPUT RECORD
      INTEGER OCTR
C
C------ Local Parameters -----------------------------------------------
C
      REAL PI
      PARAMETER (PI=3.141592653589793)
      INTEGER NCHSPEC,NVAR,IOFFSET,IOUT
      CHARACTER*40 FILESPEC
C
C----- Executable Statements -------------------------------------------
C    
C     ADD STEADY STATE GLOBAL AVERAGE FLOW PHIBAR
C     ASSOC. LEGENDRE POLYNOMIAL P(m=0,n=0) = 1/2*SQRT(2)
C
      PHISC(1) = PHISC(1) + PHIBAR*SQRT(2.0)                                    C                                             
C----- Write the spectral arrays to a formatted file
C
      NVAR=3
      NCHSPEC=13
      FILESPEC='specout_n'
      IOFFSET=10
      IOUT=100000+OCTR
      WRITE(FILESPEC(IOFFSET:IOFFSET+5),'(I6)') IOUT
      OPEN(NCHSPEC,FILE=FILESPEC,FORM='FORMATTED')
      WRITE(NCHSPEC,'(I8)') OCTR
      WRITE(NCHSPEC,'(2I8)') NALP,NVAR
      WRITE(NCHSPEC,'(8E15.6)') PHISC
      WRITE(NCHSPEC,'(8E15.6)') ZETASC
      WRITE(NCHSPEC,'(8E15.6)') DIVSC
      CLOSE(NCHSPEC)
C
      RETURN                                                                    
      END                                                                       
