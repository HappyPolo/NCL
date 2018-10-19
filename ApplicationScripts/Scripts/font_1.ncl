;***********************************************
; font_1.ncl
;
; Concepts illustrated:
;   - Increasing the font size of the gsnXXXXString subtitles
;   - Setting color maps using the new standard
;
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"  
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"  
;************************************************
begin
;************************************************
; read in netCDF file
;************************************************
  a = addfile("atmos.nc","r")
  data = a->VT(0,5,:,:)                                
;************************************************
; create default plot
;************************************************
  wks = gsn_open_wks("png","font")                ; send graphics to PNG file

  res                 = True                      ; plot mods desired
  res@cnFillOn        = True                      ; turn on color
  res@cnFillPalette   = "wgne15"                  ; set color map

  res@lbOrientation   = "Vertical"                ; vertical label bar

  plot = gsn_csm_contour_map_ce(wks,data,res)     ; create plot

; now change the size of the left and center string labels
  res@gsnStringFontHeightF = 0.025
  plot = gsn_csm_contour_map(wks,data,res)     ; create plot

end



