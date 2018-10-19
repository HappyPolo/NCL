;================================================;
;  mptick_3.ncl
;================================================;
;
; Concepts illustrated:
;   - Zooming in on a particular area on a cylindrical equidistant map
;   - Drawing a default cylindrical equidistant map
;   - Drawing a map using the high resolution map outlines
;   - Turning on map tickmark labels with degree symbols
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; ================================================;
begin
  wks  = gsn_open_wks("png","mptick")             ; send graphics to PNG file

  res                       = True                ; plot mods desired
  res@pmTickMarkDisplayMode = "Always"            ; turn on built-in tickmarks

  res@mpMinLonF            = -65                  ; set min lon
  res@mpMaxLonF            = -63                  ; set max lon
  res@mpMinLatF            =  10.                 ; set min lat
  res@mpMaxLatF            =  11.                 ; set max lat

  res@mpDataBaseVersion    = "HighRes"            ; turn on highres coastline

  res@tiMainString         = "Built-in tickmarks that include minutes"
 
  plot = gsn_csm_map_ce(wks,res)                  ; draw global map
end
