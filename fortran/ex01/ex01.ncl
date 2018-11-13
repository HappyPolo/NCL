external EX01 "./ex01.so"
 
begin
;
; calculate three values of a quadratic equation
;
   nump = 3
   x = (/ -1., 0.0, 1.0 /)
   qval = new(nump,float)              
   EX01::cquad(-1, 2, 3, nump, x, qval) ; call the new NCL version of
                                        ; your original Fortran subroutine
   print("Polynomial value = " + qval)
 
;
; calculate an arc length.
;
   xc = (/ 0., 1., 2. /)
   yc = (/ 0., 1., 0. /)
   arclen = EX01::arcln(nump,xc,yc)     ; call the new NCL version of
                                        ; your original Fortran function
   print("Arc length = " + arclen)
 
end
