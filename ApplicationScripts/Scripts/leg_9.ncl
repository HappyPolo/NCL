;*******************************************************
; leg_9.ncl
;
; Concepts illustrated:
;   - Drawing a legend outside an XY plot
;   - Changing the order of items inside a legend
;   - Moving a legend closer to a plot
;   - Customizing the labels in a legend
;
;*******************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  npts = 10
  y = new((/4,npts/),float)

  y(0,:) = random_uniform( 20., 50.,npts)
  y(1,:) = random_uniform( 25., 55.,npts)
  y(2,:) = random_uniform( 22., 50.,npts)
  y(3,:) = random_uniform( 24., 49.,npts)

  wks = gsn_open_wks("png","leg") ; send graphics to PNG file  

  res                        = True
  res@gsnMaximize            = True       ; Maximize plot in frame.

  res@xyMarkLineModes        = (/"Lines"/)         ; line style
  res@xyLineThicknessF       = 2.5                 ; line thickness

  res@xyLineColors           = (/"brown","green","blue","red"/)
  res@xyExplicitLegendLabels = (/"line 1","line 2","line 3","line 4"/)

  res@pmLegendDisplayMode    = "Always"   ; Display a legend.
  res@lgPerimOn              = False      ; No legend perimeter.
  res@pmLegendOrthogonalPosF = -0.05      ; Move closer to plot

  res@tiMainString = "Default legend ordering"    ; Title

  plot = gsn_csm_y(wks,y,res)

  res@tiMainString = "Reverse legend ordering"    ; Title
  res@lgItemOrder  = (/ 3,2,1,0 /)   ; Reorder the legends

  plot = gsn_csm_y(wks,y,res)
end
