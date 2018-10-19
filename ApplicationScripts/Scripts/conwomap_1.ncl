;----------------------------------------------------------------------
;  conwomap_1.ncl
;
; Concepts illustrated: 
;   - Drawing a simple line contour plot
;   - Drawing a line contour plot with multiple colors
;   - Increasing the thickness of contour lines
;----------------------------------------------------------------------
; Note that the default plot uses the long_name and
; units of the variable as labels.

; In this file, the coordinate variables of the data are listed as 
; lat and lon, but they are really just index points, which makes this
; data suitable for plotting without a map.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
;----------------------------------------------------------------------
begin
;--- Open file and read in data
  f    = addfile("cone.nc","r")
  u  = f->u(4,:,:)                

  wks  = gsn_open_wks("png","conwomap")    ; send graphics to PNG file
  plot = gsn_csm_contour(wks,u,False)      ; contour the variable

;---Set some resources for color contour lines
  res                  = True
  res@cnMonoLineColor  = False           ; Tells NCL not to draw contour lines in one color
  res@cnLineColors     = span_color_rgba ("NCV_jet",11)   ; NCV_jet has 256 colors; span it to get 11 colors
  res@cnLineThicknessF = 5.0             ; Make lines thicker

  plot = gsn_csm_contour(wks,u,res)

end
