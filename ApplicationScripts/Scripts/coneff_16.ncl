;----------------------------------------------------------------------
; coneff_16.ncl 
;
; Concepts illustrated:
;   - Showing features of the new color display model
;   - Using cnFillPalette to assign a color palette to contours
;   - Drawing partially transparent filled contours
;----------------------------------------------------------------------
; Important note: in NCL V6.3.0 and earlier, there's a bug in which the
; colors in the labelbar do not correctly reflect the opacity applied
; to the filled contours.  This bug has been fixed in NCL V6.4.0.
; Set res@lbOverrideFillOpacity = True if you don't want the labelbar
; colors to have the opacity applied.
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

  wks  = gsn_open_wks("png","coneff") ; send graphics to PNG file

  res                 = True
  res@gsnMaximize     = True       ; maximize in frame
  res@cnLinesOn       = False
  res@cnFillOn        = True
  res@cnFillPalette   = "BlueYellowRed"   ; change the color palette
  res@tiMainString    = "Color contours mask filled land"

  plot = gsn_csm_contour_map(wks,u,res)

  res@cnFillOpacityF = 0.3
  res@tiMainString   = "Color contours are partially transparent"

  plot = gsn_csm_contour_map(wks,u,res)
end
