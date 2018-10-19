undef("mon_fullyear")
function mon_fullyear(x:numeric, opt)

; Expand a variable containing monthly data and to full (12 month) years
; The added months will be set to _FillValue.

; Example: Take a variable that may span (say) 
; 190308 to 201105 and expand it to span 190301 to 201112. 
; The extra values will be filled with _FillValue.
;
; This assumes that the input variable will have a 
; time coordinate variable with units acceptable to cd_calendar

begin
  dimx  = dimsizes(x)          ; dimsizes x
  rankx = dimsizes(dimx)       ; rank of x

  if (rankx.gt.4) then
      print("mon_fullyear_n: currently this function only works up to rank 4")
      exit
  end if

;;if (.not.(ndim.eq.0 .or. (ndim.eq.1 .and. rankx.eq.5))) then
  if (ndim.ne.0) then
      print("mon_fullyear_n: currently this function only works on the left [0] dimimension")
      exit
  end if

  dnamx = getvardims( x )      ; dimension names

  ntimx = dimx(0)              ; # input time steps
  ymdhms= cd_calendar(x&$dnamx(0)$, 0)
 
  yyyy  = toint( ymdhms(:,0) )
  mm    = toint( ymdhms(:,1) )

  nmos  = 12
  if ((ntimx%nmos).eq.0 .and. mm(0).eq.1 .and. mm(ntimx-1).eq.nmos) then
     ;x@year_mon = YYYY*100 + MM 
      return(x)                ; must be full years
  end if 
                               ; must be partial year
  dd    = toint( ymdhms(:,2) )
  hh    = toint( ymdhms(:,3) )
  mn    = toint( ymdhms(:,4) )
  sc    =        ymdhms(:,5)  

  tunits= x&$dnamx(0)$@units

  yrStrt= yyyy(0)
  yrLast= yyyy(ntimx-1)

  mmStrt= mm(0)
  mmLast= mm(ntimx-1)

  NYRS  = yrLast-yrStrt+1
  NTIM  = NYRS*nmos            ; full year-month
  
  YYYY  = new( NTIM, "integer" , "No_FillValue")
  MM    = new( NTIM, "integer" , "No_FillValue")
  DD    = new( NTIM, "integer" , "No_FillValue")
  HH    = new( NTIM, "integer" , "No_FillValue")
  MN    = new( NTIM, "integer" , "No_FillValue")
  SC    = new( NTIM, typeof(sc), "No_FillValue")

  nStrt = 0
  nLast = nmos-1
  do year=yrStrt,yrLast
     YYYY(nStrt:nLast) = year
     MM(nStrt:nLast)   = ispan(1,nmos,1) 
     DD(nStrt:nLast)   = 1 
     HH(nStrt:nLast)   = 0 
     MN(nStrt:nLast)   = 0
     SC(nStrt:nLast)   = 0

     nStrt = nStrt+nmos
     nLast = nLast+nmos
  end do
  
  TIME  =  (/ cd_inv_calendar(YYYY,MM,DD,HH,MN,SC,tunits, 0) /)
  TIME@units = tunits
  TIME!0     = dnamx(0)
  TIME&$dnamx(0)$ =  TIME        ; make coordinate variable

  DIMX    = dimx
  DIMX(0) = NTIM
  X     = new (DIMX, typeof(x), getFillValue(x))

  nStrt = ind(YYYY.eq.yrStrt .and. MM.eq.mmStrt)
  nLast = ind(YYYY.eq.yrLast .and. MM.eq.mmLast)
  
  if (rankx.eq.1) then
      X(nStrt:nLast) = (/ x /)
     else if (rankx.eq.2) then
         X(nStrt:nLast,:) = (/ x /)
         copy_VarCoords(x(0,:), X(0,:))
     else if (rankx.eq.3) then
         X(nStrt:nLast,:,:)   = (/ x /)
         copy_VarCoords(x(0,:,:), X(0,:,:))
     else if (rankx.eq.4) then
         X(nStrt:nLast,:,:,:) = (/ x /)
         copy_VarCoords(x(0,:,:,:), X(0,:,:,:))
     end if
     end if
     end if
  end if

  copy_VarAtts(x, X)
  X!0          = dnamx(0)
  X&$dnamx(0)$ = TIME

  return(X)
  
end
