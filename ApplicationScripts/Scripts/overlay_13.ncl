;----------------------------------------------------------------------
; overlay_12.ncl
;
; Concepts illustrated:
;   - Overlaying filled contour plots with different axes ranges
;   - Explicitly setting contour levels
;   - Selecting a different color map for each contour plot
;   - Explicitly setting axes ranges for contour plots
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;----------------------------------------------------------------------


begin
;---Generate some dummy data with different axis ranges
  nx = 100
  ny = 100
  data1 = generate_2d_array(10, 12,  0,  60, 0, (/nx,ny/))
  data2 = generate_2d_array( 9, 11, 50, 100, 0, (/nx,ny/))

  x1 = fspan(20,70,nx)  ; Make X axis shorter for first plot
  y1 = fspan(1,25,ny)   ; Make Y axis longer for first plot

  x2 = fspan(0,80,nx)  ; Make X axis longer for second plot
  y2 = fspan(5,20,ny)  ; Make Y axis shorter for second plot

  data1!0 = "y"
  data1!1 = "x"
  data2!0 = "y"
  data2!1 = "x"
  data1&x = x1
  data1&y = y1
  data2&x = x2
  data2&y = y2

;---For contour levels later
  levels1 = ispan(0,60,10)
  levels2 = ispan(50,100,10)

;---Start the graphics
  wks = gsn_open_wks("png","overlay")

  res                      = True
  res@gsnDraw              = False
  res@gsnFrame             = False
  res@cnFillOn             = True
  res@cnLevelSelectionMode = "ExplicitLevels"

;---Create two copies of first plot
  res@cnLevels       = levels1
  res@cnFillPalette  = "GreenYellow"
  res@lbOrientation  = "Horizontal"
  res@tiMainString   = "BlueRed plot too long in X axis"
  plot1a = gsn_csm_contour(wks,data1,res)
  plot1b = gsn_csm_contour(wks,data1,res)

;---Create two copies of second plot
  res@cnLevels       := levels2
  res@cnFillPalette  = "BlueRed"
  res@lbOrientation  = "Vertical"
  res@tiMainString   = "GreenYellow plot too long in Y axis"
  plot2a = gsn_csm_contour(wks,data2,res)
  plot2b = gsn_csm_contour(wks,data2,res)

;--Make copies of both plot, but with X/Y axes large enough for both plots
  res@trXMinF        = floor(min((/min(x1),min(x2)/)))-1    ; The -1/+1 adds an extra margin, just for fun
  res@trXMaxF        = ceil(max((/max(x1),max(x2)/)))+1
  res@trYMinF        = floor(min((/min(y1),min(y2)/)))-1
  res@trYMaxF        = ceil(max((/max(y1),max(y2)/)))+1

;---First plot with fixed axes
  res@cnLevels       := levels1
  res@tiMainString   = "Axes expanded to include space for both plots"
  res@cnFillPalette  = "GreenYellow"
  res@lbOrientation  = "Horizontal"
  plot1c = gsn_csm_contour(wks,data1,res)

;---Second plot with fixed axes
  res@cnLevels       := levels2
  res@cnFillPalette  = "BlueRed"
  res@lbOrientation  = "Vertical"
  plot2c = gsn_csm_contour(wks,data2,res)

;---Overlay plot2a on plot1a
  overlay(plot1a,plot2a)
  draw(plot1a)
  frame(wks)

;---Overlay plot1b on plot2b
  overlay(plot2b,plot1b)
  draw(plot2b)
  frame(wks)

;---Overlay plot1c on plot2c (X/Y axes have been expanded)
  overlay(plot2c,plot1c)
  draw(plot2c)
  frame(wks)
end
