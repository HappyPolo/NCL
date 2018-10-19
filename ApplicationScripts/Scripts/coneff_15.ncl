;----------------------------------------------------------------------
; coneff_15.ncl
;
; Concepts illustrated:
;   - Controlling which contour lines get drawn
;   - Generating dummy data using "generate_2d_array"
;   - Explicitly setting contour levels
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 or newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

; Generate some dummy data.
  data = generate_2d_array(10, 12, -20., 17., 0, (/129,129/))

  wks = gsn_open_wks("png","coneff") ; Send graphics to PNG file

; Set up resources.
  res                     = True

  res@gsnMaximize         = True

  res@cnFillOn            = True        ; Turn on contour fill
  res@cnFillPalette       = "amwg"      ; Set color map
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = fspan(-17.5,15,14)

; Control which contour lines get drawn.
  res@cnLevelFlags        = (/"LineOnly","NoLine","NoLine","NoLine", \
                              "LineOnly","NoLine","LineOnly","NoLine", \
                              "LineOnly","NoLine","NoLine","NoLine", \
                              "LineOnly","NoLine"/)

  plot = gsn_csm_contour(wks,data,res)  ; Create filled contours

end
