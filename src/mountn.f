      SUBROUTINE MOUNTN
C
C
C THIS ROUTINE EDITS MOUNTAIN HEIGHT AS REQUIRED AFTER
C 20 DAYS. BEFORE 20 DAYS, WE USE SYMMETRIC TOPOGRAPHY
C FOR SPIN-UP TO STEADY STATE. THEN IT IS CHANGED TO 
C ASYMMETRIC TOPOGRAPHY HERE WHICH IS CALLED IN STSWM
C SEE EQUATIONS 5 AND 6 IN THUBURN AND LAGNEAU 1999
C
C NOTE THERE IS A TIME VARYING COMPONENT  SO THIS MUST
C BE CALLED EACH TIMESTEP TO UPDATE MOUNT
C 
C MOUNT IS SET IN INIT.F AND IS STORED IN FINIT.I.
C
C CALLED BY: STSWM
C CALLS: GLAT, GLON
C
C REVISIONS:
C 31-03-17 CREATED BY LAURA MANSFIELD
C 
C-----Model Parameters -----------------------------------
C
C
      INCLUDE 'params.i'
C
C---- Common Blocks --------------------------------------
C
C CONSTANTS AND TIMESTEPS
      INCLUDE 'consts.i'
C INITIAL CONDITIONS- INCLUDING MOUNT
      INCLUDE 'finit.i'
C
C
C----Local Parameters ------------------------------------
C
      REAL PI
      PARAMETER (PI=3.141592653589793)
C
C----Local Variables -------------------------------------
C
C     TEMPORARIES
C     
      INTEGER I,J
      REAL RLON, RLAT, MOUNTA, HSYM, HBAMP, 
     $     HB, HC, HASYM, COST, SINT, HA, TAUTMP
C
      REAL MOUNTTMP(NLON+2,NLAT)
C---- External Functions ---------------------------------
C
C     GRID LATITUDE AND LONGITUDE
C
      EXTERNAL GLAT, GLON
      REAL GLAT, GLON
C
C---- Executable Statements ------------------------------
C
C
C      WRITE(6,*) 'UPDATE SURFACE TOPOGRAPHY'
C
C     
C     SET ZONALLY SYMMETRIC PART HSYM WITH HEIGHT 
C     MOUNTA = 2500M AS BEFORE
C     NOW ALSO ADD ASYMMETRIC PART HASYM WHICH INCLUDES 
C     TIME COMPONENT
C
C     TIME COMPONENT REPEATS WITH 20 DAY PERIOD
C     INTRODUCE TAUTMP FOR THIS. MEASURED IN DAYS
C
      TAUTMP = MOD(TAU/24.0,20.0)
C
      MOUNTA = 2500.0
      DO 200 J=1,NLAT
         RLAT = GLAT(J)
         HSYM=MOUNTA*(1-EXP(-0.69*((RLAT-PI/2.0)/(PI/6.0))**2))
         DO 100 I=1,NLON
            RLON = GLON(I)
C     TIME DEPENDENT TERM (A)
            IF (TAUTMP .LT. 4.0) THEN
               HA = 0.5 * (1-COS(PI*TAUTMP/4.0))
            ELSE IF (TAUTMP .LT. 16.0) THEN
               HA = 1.0
            ELSE 
               HA = 0.5 * (1+COS(PI*(TAUTMP-16.0)/4.0))
            ENDIF
C     LATITUDE DEPENDENT TERM (B)
            IF (RLAT .GT. 0.0) THEN
               COST = COS(RLAT)
               SINT = SIN(RLAT)
               HBAMP=((COST/SINT)*(SIN(PI/4.0)/COS(PI/4.0)))**2
               HB = HBAMP*EXP(1-HBAMP)
            ELSE
               HB = 0.0
            ENDIF
C     LONGITUDE DEPENDENT TERM (C)
            HC = SIN(RLON)
            HASYM = 720.0*HA*HB*HC
            MOUNT(I,J) = HSYM+HASYM
            MOUNTTMP(I,J)=MOUNT(I,J)
 100      CONTINUE
 200    CONTINUE
C
C     UPDATE SPECTRAL COEFFICIENTS
        CALL SHTRNS(1,1,-1,MOUNTTMP,TOPOSC)
C
C      
        RETURN
C
C
        END
