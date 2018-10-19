;*******************************************
; getdomain.ncl
;********************************************
; RCM is consistent in its domain in the sense that once you pick the 
; region to work with,i.e. continental US,then the domain remains fixed.
; However, if you change the horizontal resolution or different region,
; the domain changes accordingly.
;
; If you don't know the min/max lat/lon of the rcm domain you are
; using, here is how you can get them.
;********************************************
; In RCM2, the lat/lon data is only located on the first data file. 
; Note also that the last point is bad, so we just look at the 0 - (N-2)
; points.

begin
   f   = "OUT.1982110010"
   tmp = craybinrecread(f,6,(/121,78/),"float") ;  read in lat
   print(max(tmp(0:119,0:76)))                  ;  max lat
   print(min(tmp(0:119,0:76)))		        ;  min lat


   tmp = craybinrecread(f,7,(/121,78/),"float") ;  read in lon
   print(max(tmp(0:119,0:76)))                  ;  max lon
   print(min(tmp(0:119,0:76)))		        ;  min lon

end





