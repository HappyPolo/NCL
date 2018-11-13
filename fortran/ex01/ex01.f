      SUBROUTINE CQUAD (A, B, C, NQ, X, QUAD)
      REAL X(NQ),QUAD(NQ)
C
C  Calculate quadratic polynomial values.
C
      DO 10 I=1,NQ
        QUAD(I) = A*X(I)**2 + B*X(I) + C
 10      CONTINUE
C
      RETURN
      END
      FUNCTION ARCLN (NUMPNT, POINTX, POINTY)
      DIMENSION POINTX(NUMPNT),POINTY(NUMPNT)
C
C  Calculate arc lengths.
C
      IF (NUMPNT .LT. 2) THEN
        PRINT *, 'ARCLN: Number of points must be at least 2'
        STOP
      ENDIF
      ARCLN = 0.
      DO 10 I=2,NUMPNT
        PDIST = SQRT((POINTX(I)-POINTX(I-1))**2 + 
     +                        (POINTY(I)-POINTY(I-1))**2)
        ARCLN = ARCLN + PDIST
 10      CONTINUE
C
      RETURN
      END
