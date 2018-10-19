;----------------------------------------------------------------------
; coneff_17.ncl
;
; Concepts illustrated:
;   - Turning on color for a "constant field" contour plot
;   - Turning off the "constant field" label
;
;----------------------------------------------------------------------
; This script will produce the warning:
;
;  warning:ContourPlotInitialize: scalar field is constant; no contour 
;            lines will appear; use cnConstFEnableFill to enable fill
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 or newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
;---Generate a dummy 2D array that is constant.
  data = new((/20,20/),float)
  data = 9.5

  wks = gsn_open_wks("png","coneff")    ; Send graphics to PNG file

  res                     = True
  res@gsnMaximize         = True
  res@cnFillOn            = True        ; Turn on contour fill
  res@cnFillPalette       = "amwg"      ; Set color map

;---First plot
  res@tiMainString = "Plot area should be all white"
  plot = gsn_csm_contour(wks,data,res)

;---Second plot
;
; By setting cnConstFEnableFill to True, your entire plot area will be
; filled in the appropriate color based on your contour levels.
; 
  res@cnConstFEnableFill           = True
  res@cnConstFLabelBackgroundColor = "transparent"         ; Default is white
  res@tiMainString                 = "Plot area should be all tan"
  plot = gsn_csm_contour(wks,data,res)

  res@tiMainString      = "'Constant field' label should be gone"
  res@cnConstFLabelOn  = False          ; Turn off the "constant field" label in the middle of the plot
  plot = gsn_csm_contour(wks,data,res)
end
