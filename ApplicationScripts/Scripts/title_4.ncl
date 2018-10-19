;----------------------------------------------------------------------
; title_4.ncl
;
; Concepts illustrated:
;   - Changing the font height of the main title
;   - Changing the font height of the X/Y axis titles
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Read in netCDF file
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(0,:,8)

  wks = gsn_open_wks("png","title")                ; send graphics to PNG file

  res                    = True                    ; plot mods desired

  res@tiMainString       = "main title: 0.05"            ; add titles
  res@tiXAxisString      = "X Axis title: default"  
  res@tiYAxisString      = "Y Axis title: 0.02"

  res@tiMainFontHeightF  = 0.05                    ; change font heights
;  res@tiXAxisFontHeightF = 0.1
  res@tiYAxisFontHeightF = 0.02

  plot=gsn_csm_xy(wks,u&lat,u,res)                 ; create xy plot

end
