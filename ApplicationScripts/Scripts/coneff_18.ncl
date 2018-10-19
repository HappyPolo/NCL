;----------------------------------------------------------------------
; coneff_18.ncl 
;
; Concepts illustrated:
;   - 
;   - 
;   - 
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 or newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
;---read in zonal winds
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(1,:,:)                                ; July zonal winds
  v = a->V(1,:,:)                                ; July zonal winds

  wks  = gsn_open_wks("x11","coneff") ; send graphics to PNG file

  res                 = True
  res@gsnMaximize     = True       ; maximize in frame
  res@cnLinesOn       = False
  res@cnLineLabelsOn  = False
  
  res1 = res
  res1@cnFillOn        = True
  res1@cnFillPalette   = "BlueYellowRed"   ; change the color palette
  res1@tiMainString    = "Color contours mask filled land"
  res1@mpFillDrawOrder = "Draw"

  plot1 = gsn_csm_contour_map(wks,u,res1)

  res2 = res
  plot2 = gsn_csm_contour(wks,u,res2)

  opt = True
  opt@gsnShadeFillType = "pattern"       ; pattern fill
  opt@gsnShadeLow = 17                   ; use pattern 17
  opt@gsnShadeHigh = -1
 
  plot2 = gsn_contour_shade(plot2,0.0,0.20,opt)
  overlay(plot1,plot2)
  draw(plot1)
  frame(wks)
end
