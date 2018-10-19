;----------------------------------------------------------------------
; title_8.ncl
;
; Concepts illustrated:
;   - Moving the X and Y axis strings to a different side
;   - Changing the angle of the X axis string
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Read in netCDF file
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(0,:,8)

  wks = gsn_open_wks("png","title")         ; send graphics to PNG file

  res                 = True                ; plot mods desired
  res@gsnLeftString   = "LeftString"        ; add the gsn/ti titles
  res@gsnCenterString = "CenterString"
  res@gsnRightString  = "RightString"
  res@tiYAxisString   = "YAxisString"
  res@tiXAxisString   = "XAxisString"
  res@tiXAxisSide     = "Top"			    ; draw the X-axis title above the plot
  res@tiYAxisSide     = "Right"		    ; draw the Y-axis title to the right of the plot
  res@tiYAxisAngleF   = 270			    ; rotate the Y-axis title 270 degrees

  plot=gsn_csm_xy(wks,u&lat,u,res)                ; create xy plot
end
