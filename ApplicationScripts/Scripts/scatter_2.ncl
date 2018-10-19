; ***********************************************
; scatter_2.ncl
;
; Concepts illustrated:
;   - Drawing a scatter plot
;   - Changing the markers in an XY plot
;   - Changing the marker color in an XY plot
;   - Changing the marker size in an XY plot
;   - Rotating markers in an XY plot
;   - Creating your own markers for an XY plot
;   - Generating dummy data using "random_normal"
;   - Clipping markers outside the viewport
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
  t = random_uniform(0,100.,75)

  wks   = gsn_open_wks ("png","scatter")            ; send graphics to PNG file

;************************************************
; Create your own markers using NhlNewMarker .
; You can use any one of the characters in
; the font tables at:
; 
; http://www.ncl.ucar.edu/Document/Graphics/font_tables.shtml
;
; Here we'll use character "p" in font table 35, which is a clover.
;
; The arguments for this function are:
;
; wks
; marker_string[*]
; font_table_number
; x-offset
; y-offset
; aspect_ratio
; size
; angle

; You may have to play with the numbers a but to get the size and 
; shape you desire. On the documentation page for NhlNewMarker:
;
;  http://www.ncl.ucar.edu/Document/Functions/Built-in/NhlNewMarker.shtml
;
; there is a table of values for the current marker set to give you
; an idea of where to start.
;
; Note that we are rotating the marker clockwise 45 degrees.
;
  clover = NhlNewMarker(wks, "p", 35, 0.0, 0.0, 1.3125, 1.5, -45.0)

;************************************************
; plotting parameters
;************************************************
  res                   = True                     ; plot mods desired
  res@gsnMaximize       = True                     ; maximize plot
  res@tiMainString      = "Make your own marker"
  res@xyMarkLineMode    = "Markers"                ; choose to use markers
  res@xyMarkers         =  clover                  ; choose type of marker  
  res@xyMarkerColor     = "ForestGreen"            ; Marker color
  res@xyMarkerSizeF     = 0.01                     ; Marker size (default 0.01)

  plot  = gsn_csm_y (wks,t,res)                    ; Create and draw plot

  res@vpClipOn          = True                     ; Clip any markers outside
                                                   ; the viewport
  res@tiMainString = "Clipping markers outside the viewport"
  plot  = gsn_csm_y (wks,t,res)                    ; Create and draw plot

end
