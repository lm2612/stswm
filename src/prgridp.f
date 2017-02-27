      SUBROUTINE PRGRIDP(PHI,PANL,U,V,ZETA,DIV,L3D,LN,GCTR)
C                                                                              
C OUTPUT GRID POINT FIELDS TO SIMPLE FORMAT FILE
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
C Plotting Data
      INCLUDE 'complt.i'
C Workspace
      INCLUDE 'wrkspc.i'
C
C------------ Arguments ------------------------------------------------
C
C     Input
C
C HEIGHT FIELD
      REAL PHI(NLON+2,NLAT)
C ANALYTIC HEIGHT FIELD (CASE 1 OVERLAYED PLOTS)
      REAL PANL(NLON+2,NLAT)
C EASTWARD WIND FIELD
      REAL U(NLON+2,NLAT)
C NORTHWARD WIND FIELD
      REAL V(NLON+2,NLAT)
C VORTICITY FIELD
      REAL ZETA(NLON+2,NLAT,L3D)
C DIVERGENCE FIELD
      REAL DIV(NLON+2,NLAT,L3D)
C NUMBER OF TIMELEVELS 
C     (=1 IF CALLED FROM SUBROUTINE ERRANL FOR ANALYTIC SOL. AND ERROR,
C      =LVLS IF CALLED FROM MAIN PROGRAM FOR COMPUTED FIELDS)
      INTEGER L3D
C CURRENT INDEX OF PROGNOSTIC VARIABLES
      INTEGER LN
C LABEL FOR GRIDDED OUTPUT RECORD
      INTEGER GCTR
C
C------ Local Parameters -----------------------------------------------
C
      REAL PI
      PARAMETER (PI=3.141592653589793)
      INTEGER NCHGRID,NVAR,IOFFSET,IOUT
      CHARACTER*40 FILEGRID
C
C----- External Functions ----------------------------------------------
C
C     LATITUDES OF GRID
C
      EXTERNAL GLAT,GLON
      REAL GLAT,GLON
      REAL ALAT(NLAT),ALON(NLON)
C
C----- Executable Statements -------------------------------------------
C                                                                               
C     MODEL CHARACTERIZATION
C
      WRITE(MODEL,600) ICOND,CHEXP,STRUNC,TAU,INT(DT)
  600 FORMAT('TEST ',I2,',EXP.',A4,',',A6,',T=',F5.1,',DT=',I4)
C
C---- Setup longitude and latitude arrays for output
C
      DO I=1,NLON
         ALON(I) = GLON(I)*180./PI
      ENDDO
      DO J=1,NLAT
         ALAT(J) = GLAT(J)*180./PI
      ENDDO
C
C----- Write the grid-point arrays to a formatted file
C
      NVAR=5
      NCHGRID=12
      FILEGRID='gridout_n'
      IOFFSET=10
      IOUT=100000+GCTR
      WRITE(FILEGRID(IOFFSET:IOFFSET+5),'(I6)') IOUT
      OPEN(NCHGRID,FILE=FILEGRID,FORM='FORMATTED')
      WRITE(NCHGRID,'(I8)') GCTR
      WRITE(NCHGRID,'(3I8)') NLON,NLAT,NVAR
      WRITE(NCHGRID,'(8E15.6)') ALAT
      WRITE(NCHGRID,'(8E15.6)') ALON
      WRITE(NCHGRID,'(8E15.6)') PHI
      WRITE(NCHGRID,'(8E15.6)') ZETA
      WRITE(NCHGRID,'(8E15.6)') DIV
      WRITE(NCHGRID,'(8E15.6)') U
      WRITE(NCHGRID,'(8E15.6)') V
      CLOSE(NCHGRID)
C
      RETURN                                                                    
      END                                                                       
