; ***********************************************
; scatter_1.ncl
;
; Concepts illustrated:
;   - Drawing a scatter plot
;   - Changing the markers in an XY plot
;   - Changing the marker color in an XY plot
;   - Changing the marker size in an XY plot
;   - Generating dummy data using "random_chi"
;
; ***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************
begin
;************************************************
; Generate some random data
;************************************************
  random_setallseed(36484749, 9494848)   ; Set seeds (suggested, NOT required)
  t = random_chi(2.0, 50)

;************************************************
; plotting parameters
;************************************************
  wks   = gsn_open_wks ("png","scatter")           ; send graphics to PNG file

  res                   = True                     ; plot mods desired
  res@gsnMaximize       = True                     ; maximize plot
  res@tiMainString      = "Scatter Plot"           ; add title
  res@xyMarkLineMode    = "Markers"                ; choose to use markers
  res@xyMarkers         =  16                      ; choose type of marker  
  res@xyMarkerColor     = "NavyBlue"               ; Marker color
  res@xyMarkerSizeF     = 0.01                     ; Marker size (default 0.01)

  plot  = gsn_csm_y (wks,t,res)                    ; create plot

end
