;----------------------------------------------------------------------
; title_1.ncl
;
; Concepts illustrated:
;   - Adding a main title
;   - Adding titles to the X/Y axes
;   - Left or right justifying titles
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

  res                 = True                       ; plot mods desired

  res@tiMainString    = "This is the main title"   ; add titles
  res@tiXAxisString   = "This is the X Axis title"  
  res@tiYAxisString   = "This is the Y Axis title"

  plot = gsn_csm_xy(wks,u&lat,u,res)   ; Draw first plot

  res@tiMainString         = "Main title left-justified"
  res@tiMainJust           = "CenterLeft"
  res@tiMainPosition       = "Left"

  res@tiXAxisString        = "X Axis title right justified"  
  res@tiXAxisJust          = "CenterRight"
  res@tiXAxisPosition      = "Right"

  res@tiYAxisString        = "Y Axis title left justified on right side"
  res@tiYAxisJust          = "CenterLeft"
  res@tiYAxisSide          = "Right"
  res@tiYAxisPosition      = "Bottom"

  plot = gsn_csm_xy(wks,u&lat,u,res)   ; Draw second plot
end
