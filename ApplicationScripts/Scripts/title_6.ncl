;----------------------------------------------------------------------
; title_6.ncl
;
; Concepts illustrated:
;   - Changing the location of the three gsnXXXXString subtitles
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;---Read in netCDF file
  a = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/uv300.nc","r")
  u = a->U(0,:,8)

  wks = gsn_open_wks("png","title")               ; send graphics to PNG file

  res                 = True                      ; plot mods desired

; if your data has a long_name and units attribute, they will be placed in
; the left and right string respectively. You can over ride this by 
; setting the string to a null string: 
; res@gsnLeftString   = ""

  res@gsnLeftString   = "LeftString"              ; add the gsn titles
  res@gsnCenterString = "CenterString"
  res@gsnRightString  = "RightString"
  res@gsnStringFont = "helvetica-bold"			; set gsnLeft/Center/RightString font
  										; to helvetica-bold from default.
  
  res@gsnLeftStringFontHeightF   = 0.015		; instead of using txFontHeightF or gsnStringFontHeightF 
  res@gsnCenterStringFontHeightF = 0.02			; to set the gsnLeft/Center/RightString font heights,
  res@gsnRightStringFontHeightF  = 0.025		; individually set each string's font height.

  res@tiMainString    = "main title"              ; add main title
  res@tiMainFont      = "helvetica"			; set main title to helvetica

  plot=gsn_csm_xy(wks,u&lat,u,res)                ; create xy plot
end
