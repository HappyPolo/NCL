;----------------------------------------------------------------------
; newcolor_6.ncl
;
; Concepts illustrated:
;   - Showing features of the new color display model
;   - Drawing partially transparent filled contours
;   - Using opacity to emphasize or subdue overlain features
;   - Using cnFillPalette to assign a color palette to contours
;----------------------------------------------------------------------
; Important note: in NCL V6.3.0 and earlier, there's a bug in which the
; colors in the labelbar do not correctly reflect the opacity applied
; to the filled contours.  This bug has been fixed in NCL V6.4.0.
; Set res@lbOverrideFillOpacity = True if you don't want the labelbar
; colors to have the opacity applied.
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
;---read in zonal winds
  a   = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u   = a->U(1,:,:)

;---Graphics
  wks  = gsn_open_wks("png","newcolor")  ; send graphics to PNG file

;---Set resources common to both plots
  res                        = True

  res@gsnFrame               = False
  res@gsnDraw                = False

  res@cnLevelSelectionMode   = "ExplicitLevels"
  res@cnLevels               = ispan(-12,40,2)

  res@cnFillOn               = True
  res@cnFillPalette          = "BlueYellowRed"

  res@cnLinesOn              = False
  res@cnLineLabelsOn         = False
  res@cnInfoLabelOn          = False

;---Set resources for contour/map plot only
  bres                   = res
  bres@gsnMaximize       = True    ; Make sure you only maximize this
                                   ; plot, and not the overlay plot
  bres@mpFillOn          = False 
  bres@tiMainString      = "Use transparency to de-emphasize a particular area"
  bres@cnFillOpacityF    = 0.5     ; Half transparent

  base_plot = gsn_csm_contour_map(wks,u,bres)

;---Set resources for contour plot only
  ores                = res
  ores@cnFillOpacityF = 1.0     ; Fully opaque
  ores@gsnRightString = ""
  ores@gsnLeftString  = ""
  ores@lbLabelBarOn   = False   ; Turn off labelbar

  overlay_plot = gsn_csm_contour(wks,u({-30:30},{-120:120}),ores)

  overlay(base_plot,overlay_plot)

  draw(base_plot)
  frame(wks)

;---Create the plot again, but with no transparency
  delete(bres@cnFillOpacityF)
  plot = gsn_csm_contour_map(wks,u,bres)

;---Set resources for a partially transparent polygon.
  gnres                = True
  gnres@gsFillOpacityF = 0.6          ; mostly opaque
  gnres@gsFillColor    = "white"

  lat_box = (/ -30,-30, 30,  30, -30/)
  lon_box = (/-120,120,120,-120,-120/)

  gsid = gsn_add_polygon(wks,plot,lon_box,lat_box,gnres)

  draw(plot)
  frame(wks)

end
