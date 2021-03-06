      SUBROUTINE EVAL(DIVSC,ZETASC,PHISC,MMH,NNH,KKH,A,ALPHA,
     $           OMEGA,LAMBDA,THETA,DIV,ZETA,PHI,U,V)
C
C ENCAPSULATED CODE FOR RECOVERING HIGH RESOLUTION SOLUTION
C AT ARBITRARY POINT ON SPHERE.
C                   
C CALLED BY: ANLYTC
C CALLS: DCEPS,DCALP,DFTFAX,DTRNS,DUV
C
C REVISIONS:
C 7-10-92 CHANGE TO CCM CODING CONVENTIONS (R. JAKOB)
C
C---- Model Parameters -------------------------------------------------
C
      INCLUDE 'params.i'
C
C------------ Arguments ------------------------------------------------
C
C     Input
C
C SPECTRAL COEFFICIENT FIELDS
      COMPLEX ZETASC(*),DIVSC(*),PHISC(*)
C SPECTRAL SPACE DIMENSIONS
      INTEGER MMH,NNH,KKH
C EARTH RADIUS
      REAL A
C ROTATION ANKLE
      REAL ALPHA
C EARTH ROTATION RATE
      REAL OMEGA
C POSITION ON SPHERE (LONGITUDE,LATITUDE)
      REAL LAMBDA,THETA
C
C     Output
C
C DIVERGENCE
      REAL DIV
C VORTICITY
      REAL ZETA
C HEIGHT
      REAL PHI
C EASTWARD WIND
      REAL U
C NORTHWARD WIND
      REAL V
C
C----- Local Parameters ------------------------------------------------
C
C     UNDEFINED VALUE (USED FOR INITIAL CALL OF ROUTINE)
      REAL UNDEF
      PARAMETER (UNDEF=1.E-30)
C
C     KEEP OLD ARGUMENT VALUES TO SAVE RECOMPUTATION IF THEY
C     HAVEN'T CHANGED SINCE LAST CALL
C
C     ROTATION ANKLE (REMEMBER PREVIOUS VALUE)
C
      REAL AOLD
      SAVE AOLD
C     
C     SPECTRAL SPACE (REMEMBER PREVIOUS VALUE)
C     
      INTEGER MMOLD,NNOLD,KKOLD
      SAVE MMOLD,NNOLD,KKOLD
C
C     POSITION (REMEMBER PREVIOUS VALUE)
C
      REAL LAMOLD,THEOLD
      SAVE LAMOLD,THEOLD
C
C     LOCAL VARIABLES
C
C     ARRAY DIMENSIONS
C
      INTEGER NFCH
C
C     ARRAY INDEX FOR SPECTRAL COEFFICIENTS
C
      INTEGER LDIAG(0:MAXH,2)
      INTEGER LROW(0:MAXH,2)
      SAVE LDIAG,LROW
C
C     INVERSE FOURIER TRANSFORM
C
      REAL TRIGS(MAXH+1,2)
      SAVE TRIGS
C
C     RECURRENCE COEFFICIENTS FOR LEGENDRE POLYNOMIALS
C
      REAL CMN(NALPH),DMN(NALPH),EMN(NALPH)
      SAVE CMN,DMN,EMN
C
C     RECURRENCE COEFFICIENTS FOR DERIVATIVE
C
      REAL EPSIL(NALPH)
      SAVE EPSIL
C
C     VALUE OF POLYNOMIALS AND DERIVATIVES
C
      REAL ALP(NALPH),DALP(NALPH)
      SAVE ALP,DALP
C
C     SCALING FACTOR FOR U,V
C
      REAL ANNP1(MAXH)
      SAVE ANNP1
C
C     CORIOLIS COEFFICIENT
C
      REAL CORSC1,CORSC2
      SAVE CORSC1,CORSC2
C
C     TEMPORARIES
C
      INTEGER N
C
C----- Initialized Variables -------------------------------------------
C
C     INITIAL (UNDEFINED) VALUES FOR MODEL PARAMETERS
C
      DATA AOLD /UNDEF/
      DATA MMOLD,NNOLD,KKOLD /0,0,0/
      DATA LAMOLD,THEOLD /UNDEF,UNDEF/
C
C----- Executable Statements -------------------------------------------
C
C     NUMBER OF FOURIER COEFFICIENTS
C
      NFCH=(MMH+1) - AMAX0(MMH-KKH, 0)
C
C     COEFFICIENT AND INDEX ARRAYS FOR LEGENDRE TRANSFORM     
C
C     CHECK FOR SUFFICIENT STORAGE (PARAMETER MAX CORRECTLY SPECIFIED)
C
      IF (NALPH .LT. (MMH+1)*(KKH+1)-(MMH*MMH+MMH)/2-1) THEN
         WRITE (0,2) MAXH
    2    FORMAT(/,' STSWM: FATAL ERROR IN SUBROUTINE EVAL:',/,
     $          ' PARAMETER MAXH TOO SMALL SPECIFIED FOR BELOUSOV',
     $          ' RECURRENCE; MAXH = ', I10)
         STOP
      ELSE
         IF ((MMH .NE. MMOLD) .OR. (NNH .NE. NNOLD) .OR.
     $       (KKH .NE. KKOLD)) THEN
C
C           TRUNCATION-DEPENDENT COEFFICIENTS
C
            CALL DCEPS(MAXH,MMH,NNH,KKH,CMN,DMN,EMN,EPSIL,LROW,LDIAG)
C
C           FACTOR FOR ROUTINE UV
C
            DO 10 N = 1,KKH
               ANNP1(N) = A/REAL(N*(N+1))
   10       CONTINUE
            MMOLD = MMH
            NNOLD = NNH
            KKOLD = KKH
         ENDIF
      ENDIF
C
C     ROTATED CORIOLIS TERMS
C
      IF (ALPHA .NE. AOLD) THEN
C        WAVE M=0, N=1
         CORSC1 = SQRT(8.0/3.0)*OMEGA*COS(ALPHA)
C        WAVE M=1, N=1
         CORSC2 = - SQRT(4.0/3.0)*OMEGA*SIN(ALPHA)
         AOLD = ALPHA
      ENDIF
C
C     COMPUTE DISCRETE FOURIER COEFFICIENTS
C     FOR LONGITUDE LAMBDA
C
      IF (LAMBDA .NE. LAMOLD) THEN
         CALL DFTFAX(MAXH,NFCH,LAMBDA,TRIGS)
         LAMOLD = LAMBDA
      ENDIF
C
C     COMPUTE ASSOCIATED LEGENDRE POLYNOMIALS FOR LATITUTE THETA
C
      IF (THETA .NE. THEOLD) THEN
         CALL DCALP(MMH,NNH,KKH,CMN,DMN,EMN,EPSIL,LROW,LDIAG,ABS(THETA),
     $              ALP,DALP)
         THEOLD = THETA
      ENDIF
C
C     EVALUATE FIELD AT CHOSEN POINT BY 
C     INVERSE LEGENDRE TRANSFORM FOLLOWED BY INVERSE FOURIER TRANSFORM
C
      CALL DTRNS(NNH,PHISC,LDIAG,TRIGS,ALP,THETA,PHI)
      CALL DTRNS(NNH,ZETASC,LDIAG,TRIGS,ALP,THETA,ZETA)
      CALL DTRNS(NNH,DIVSC,LDIAG,TRIGS,ALP,THETA,DIV)
      CALL DUV(NNH,DIVSC,ZETASC,LDIAG,TRIGS,ALP,DALP,ANNP1,
     $         CORSC1,CORSC2,THETA,U,V)
C
      RETURN
C
      END
