; ===========================================
; conLev_1.ncl
;
; Concepts illustrated:
;   - Setting contour levels using a min/max contour level and a spacing
;   - Zooming in on a particular area on a cylindrical equidistant map
;
; ===========================================
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

begin
  f      = addfile ("b003_TS_200-299.nc", "r")
  x      = f->TS(43,:,:)       ;Grab 43rd timestep (=year 243)

  x = x-273.15

  wks = gsn_open_wks("png","conLev")       ; send graphics to PNG file

  res           = True
  res@mpFillOn = True			  ; turn on the map filling resource
  res@mpFillColors = (/ "transparent","transparent","gray","transparent"/)	  ; color the continents gray
  res@mpMinLatF = -70.			  ; set the minimum latitude = -70.
  res@mpMaxLatF = 70.			  ; set the maximum latitude = 70.

  res@cnLevelSelectionMode = "ManualLevels"	; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = -5.			; set the minimum contour level
  res@cnMaxLevelValF  = 30.			; set the maximum contour level
  res@cnLevelSpacingF = 5.			; set the interval between contours
  plot = gsn_csm_contour_map_ce(wks,x,res)    
end     
