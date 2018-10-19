;----------------------------------------------------------------------
; axes_7.ncl
;
; Concepts illustrated:
;   - Generating a contour plot with irregular x and y axes
;   - Linearizing the X axis
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Generate some dummy data with irregular X and Y values
  x    = (/1,5,10,15,20,30,40,50,60,70/)
  y    = (/100,200,500,1000,1500,2000,2500/)
  nx   = dimsizes(x)
  ny   = dimsizes(y)
  data = generate_2d_array(10, 12, 0.6, 0.5, 0, (/ny,nx/))

  data!0 = "y"
  data!1 = "x"
  data&x = x
  data&y = y

;---Start the graphics
  wks = gsn_open_wks("png","axes")

;---Set up resources
  res                     = True

  res@gsnMaximize         = True
  res@vpWidthF            = 0.8         ; Make the plot wider than it 
  res@vpHeightF           = 0.5         ; is high.

  res@cnFillOn            = True        ; Turn on contour fill
  res@cnLinesOn           = False       ; Turn off contour lines
  res@lbOrientation       = "vertical"

;---Explicitly label X and Y with the same values used for the coordinate arrays
  res@tmXBMode            = "Explicit"
  res@tmXBValues          = data&x
  res@tmXBLabels          = ""+data&x

  res@tmYLMode            = "Explicit"
  res@tmYLValues          = data&y
  res@tmYLLabels          = ""+data&y

;---Draw the original plot with the X and Y labels regulary spaced
  res@tiMainString        = "X labels are equally spaced"
  plot = gsn_csm_contour(wks,data,res)

;---Linearize the X axis.
  res@gsnXAxisIrregular2Linear = True
  res@tiMainString        = "X labels are not equally spaced"
  plot = gsn_csm_contour(wks,data,res)
  
end
