;*************************************************
; proj_3.ncl
;
; Concepts illustrated:
;   - Drawing filled contours over an orthographic map
;   - Changing the center latitude and longitude for an orthographic projection
;   - Turning off map fill
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
;************************************************
; read in data
;************************************************
  t = a->TS(0,:,:)                                
;************************************************
; create plot
;************************************************
  wks = gsn_open_wks("png","proj")          ; send graphics to PNG file


  res                   = True
  res@mpProjection      = "Orthographic"       ; choose projection
  res@mpPerimOn         = False             ; turn off box around plot
  res@mpFillOn          = False
  res@mpCenterLonF      = -120.             ; choose center lon
  res@mpCenterLatF      = 50.               ; choose center lat

  res@cnFillOn          = True              ; color plot desired
  res@cnFillPalette     = "gui_default"     ; select color map
  res@cnLineLabelsOn    = False             ; turn off contour line labels
  res@cnLinesOn         = False             ; turn off contour lines

;  res@lbLabelFontHeightF  = 0.015           ; label bar font height
 
  res@tiMainString       = "Example of Orthographic Projection"   ; add a title
;  res@tiMainFontHeightF  = .018                               ; font height

  plot = gsn_csm_contour_map(wks,t,res)  ; create the plot
end
