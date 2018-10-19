;*************************************************
; trick_2.ncl
; use of ind and ind_resolve
;*************************************************
begin
  a = addfile("atmos.nc","r")
  t = a->TS
  printVarSummary(t)
;*************************************************
; use ind to determine index locations where temp
; is greater than 305. ind only works on one dimensional
; arrays so we have to change the multi-dimensional 
; array to a one dimensional one using ndtooned
;*************************************************
  loc = ind( ndtooned(t) .gt. 305.) 
  print(loc)
;*************************************************
; now we would like to do something with these locations.
; we can use ind_resolve to take this 1D array and have
; it apply to our original 4D array.
;*************************************************
  indx  = ind_resolve(loc,dimsizes(t))
  print(indx)
  dims  = dimsizes(indx)     
  npts  = dims(0)                 ; number of points in t > 305
  ndim  = dims(1)                 ; rank of original array  
;*************************************************
; we can take the values of the second dimension of
; indx to locate the 3D locations within the original 
; grid and set those to missing.
;*************************************************
  do n=0,npts-1
     t(indx(n,0),indx(n,1),indx(n,2)) = -999.
  end do

end


