;***********************************************
; color_6.ncl
;
; Concepts illustrated:
;   - Selecting a different color map
;   - Explicitly setting contour levels to uneven levels
;   - Changing the center longitude for a cylindrical equidistant projection
;   - Turning off contour lines
;   - Spanning the full color map for contour fill
;
;***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
;
; This file still has to be loaded manually
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl" 

begin
;************************************************
; Read the file
;************************************************
  in    = addfile("80.nc","r")
  TS    = in->TS
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","color")             ; send graphics to PNG file
  res                      = True               ; plot mods desired
  res@tiMainString         = "Explicit Contour Levels"

  res@cnFillOn             = True               ; turn on color fill
  res@cnFillPalette        = "gui_default"      ; set color map
  res@cnLinesOn            = False              ; turn off contour lines

  res@lbOrientation        = "vertical"         ; vertical label bars

  res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  res@cnLevels            = (/232.7,234.2,238,240,244,248.4,252,258.3,276,286.5,292.1,300,306/)

  res@mpFillOn             = False              ; turn off gray continents
  res@mpCenterLonF         = 180                ; Centers the plot at 180 

  plot = gsn_csm_contour_map(wks,TS(0,:,:), res)   ; create plot
  
end
