
;----------------------------------------------------------------------
; This function takes a list of 1D arrays and combines them into
; a single 2D array padded with missing values as necessary.
;----------------------------------------------------------------------

function combine_in_one_array(xlist[1]:list)
begin
  nitems = ListCount(xlist)

  max_npts = 0
  type = "float"
  do n=0,nitems-1
    max_npts = max((/max_npts,dimsizes(xlist[n])/))
    if(typeof(xlist[n]).eq."double") then
      type = "double"
    end if
  end do

  x = new((/nitems,max_npts/),type)
  do n=0,nitems-1
    npts = dimsizes(xlist[n])
    x(n,0:npts-1) = xlist[n]    
  end do

  return(x)  
end


;----------------------------------------------------------------------
; Main code
;----------------------------------------------------------------------
begin
  NPTS  = 500
  PI100 = 0.031415926535898

;
; Generate 4 X/Y arrays that each have a different number of
; points, but whose X values are all in the same range.
;
  x1 = ispan(0,NPTS-1,1)
  x2 = ispan(0,NPTS-1,2)    ; half as many as x1
  x3 = ispan(0,NPTS-1,3)    ; third as many as x1
  x4 = ispan(0,NPTS-1,4)    ; quarter as many as x1

  y1 = sin(PI100*x1)
  y2 = sin(2^(PI100*x2))
  y3 = sin(4*sqrt(fabs(PI100*x3)))
  y4 = sin((PI100*x4)^2/7.)

  print("x1/y1 has " + dimsizes(x1) + " points")
  print("x2/y2 has " + dimsizes(x2) + " points")
  print("x3/y3 has " + dimsizes(x3) + " points")
  print("x4/y4 has " + dimsizes(x4) + " points")

;---Combine into 4 x npts arrays with missing values
  x = combine_in_one_array([/x1,x2,x3,x4/])
  y = combine_in_one_array([/y1,y2,y3,y4/])

  colors = (/"purple","green3","navyblue","brown"/)
  labels = (/ "y1",   "y2",    "y3",      "y4"/)

  wks = gsn_open_wks("x11","xy")

;---Set resources common to all four plots
  res                        = True

  res@gsnMaximize            = True

  res@vpWidthF               = 0.8        ; Make plots wider than 
  res@vpHeightF              = 0.25       ; they are high.

  res@trYMinF                = min(y)-1.1 ; leave room for a legend

  res@xyMonoDashPattern      = True       ; all solid lines
  res@xyLineThicknessF       = 5.0        ; 5x as thick
  res@xyLineColors           = colors

;---Customize the XY plot legend
  res@pmLegendDisplayMode    = "Always"            ; turn on legend
  res@pmLegendParallelPosF   = 0.9                 ; move legend right
  res@pmLegendOrthogonalPosF = -0.55               ; move legend up
  res@pmLegendWidthF         = 0.05                ; Change width and
  res@pmLegendHeightF        = 0.08                ; height of legend.
  res@lgPerimOn              = False               ; turn off box around
  res@lgLabelFontHeightF     = 0.01                ; label font height
  res@xyExplicitLabels       = labels              ; explicit labels

  res@tiMainString           = "Curves added via 2D array"

  plot = gsn_csm_xy(wks,x,y,res)
end

