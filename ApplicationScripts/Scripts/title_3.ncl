;----------------------------------------------------------------------
; title_3.ncl
;
; Concepts illustrated:
;   - Drawing subtitles at the top of a plot
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

; if your data has a long_name and units attribute, they will be placed in
; the left and right string respectively. You can over ride this by 
; setting the string to a null string: 
; res@gsnLeftString   = ""

  res@gsnLeftString   = "LeftString"               ; add the gsn titles
  res@gsnCenterString = "centerstring"
  res@gsnRightString  = "RightString"

  plot=gsn_csm_xy(wks,u&lat,u,res)                 ; create xy plot

end
