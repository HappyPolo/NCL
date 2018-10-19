; ***********************************************
; polyg_7.ncl
;
; Concepts illustrated:
;   - Drawing a scatter plot
;   - Creating your own filled box markers
;   - Changing the marker color in a map plot
;
; ***********************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;************************************************
begin
;************************************************
; read in data
;************************************************
 f     = addfile ("AtmJan360.nc","r")
 t     = f->T                                     ; get t data
;************************************************
; plotting parameters
;************************************************
 wks   = gsn_open_wks ("png","polyg")             ; send graphics to PNG file

 res                   = True                     ; plot mods desired
 res@tiMainString      = "Scatter Plot"           ; add title
 res@xyMarkLineModes   = "Markers"                ; choose which have markers
 res@tmLabelAutoStride = True                     ; nice tick mark labels
;************************************************
; now create our own markers using NhlNewMarker 
; available since ncl version 4.2.0.a030
;************************************************
; the arguments for this function are:
; wks
; marker_string[*]
; font_table_number
; x-offset
; y-offset
; aspect_ratio
; size
; angle

; this example will create filled squares. You will have to play with
; the numbers a but to get the size and shape you desire. On the
; documentation page for NhlNewMarker, there is a table of values for
; the current marker set, to give you an idea of where to start.

  res@xyMarkerColor = "blue"
  res@tiMainString  = "Make your own marker"
  res@xyMarkers     = NhlNewMarker(wks, "^", 19, 0.0, 0.0, 1.3125, 1.5, 0.0)
  plot              = gsn_csm_xy (wks,t&time,t(:,0,{2},{82}),res) 

end
