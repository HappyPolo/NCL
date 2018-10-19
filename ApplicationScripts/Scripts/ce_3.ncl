;*************************************************
; ce_3.ncl
;
; Concepts illustrated:
;   - Drawing color-filled contours over a cylindrical equidistant map
;   - Selecting a different color map
;   - Changing the contour level spacing
;   - Turning off contour lines
;   - Comparing styles of map tickmarks labels
;   - Changing the stride of the labelbar labels
;   - Zooming in on a particular area on the map
;   - Turning off the addition of a longitude cyclic point
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
;************************************************
begin
;************************************************
; open file and read in data
;************************************************
  in = addfile("h_avg_Y0191_D000.00.nc","r")
  t  = in->T
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png" ,"ce")      ; send graphics to PNG file

  res                       = True     ; plot mods desired

  res@gsnMaximize           = True     ; Make plot fit the frame
  res@cnFillOn              = True     ; turn on color fill
  res@cnLinesOn             = False    ; turn of contour lines
  res@cnLevelSpacingF       = 0.5      ; contour spacing
  res@cnFillPalette         = "BlAqGrYeOrRe"
  res@lbOrientation         = "Vertical"

  res@gsnAddCyclic          = False    ; data already has cyclic point
				       ; this must also be set for any zoom

;
; Note that the gsn_csm_*map* templates automatically set 
; res@mpLimitMode="LatLon" for you. If you are plotting a 
; different projection, you may have to set this resource.
;
  res@mpMinLatF            = -60      ; range to zoom in on
  res@mpMaxLatF            =  30.
  res@mpMinLonF            =  30.
  res@mpMaxLonF            = 120.

  res@tiMainString = "Default map tickmark labels"
  plot = gsn_csm_contour_map(wks,t(0,0,{-60:30},{30:120}), res)

  res@tiMainString          = "pmTickMarkDisplayMode = 'Always'"
  res@pmTickMarkDisplayMode = "Always"; use NCL default lat/lon labels
  res@pmTitleZone           = 4
  plot = gsn_csm_contour_map(wks,t(0,0,{-60:30},{30:120}), res)


end
