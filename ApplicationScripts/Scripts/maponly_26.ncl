;----------------------------------------------------------------------
; maponly_26.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Drawing a default cylindrical equidistant map
;   - Drawing a map using the medium resolution map outlines
;   - Drawing Caribbean Islands
;   - Turning on map tickmark labels with degree symbols
;   - Zooming in on Caribbean Islands
;----------------------------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
  wks  = gsn_open_wks("png","maponly")  ; send graphics to PNG file

  res                       = True
  res@gsnMaximize           = True

  res@mpMinLatF             =  10.
  res@mpMaxLatF             =  30.
  res@mpMinLonF             = -90.
  res@mpMaxLonF             = -68.

  res@mpDataBaseVersion     = "MediumRes"
  res@mpDataSetName         = "Earth..4"
  res@mpOutlineBoundarySets = "National"
  res@mpOutlineSpecifiers   = (/ "United States", "Mexico", "Canada"/) + " : States"

  res@mpOutlineOn           = True
  res@mpOceanFillColor      = "lightblue"
  res@mpInlandWaterFillColor= "lightblue"
  res@mpLandFillColor       = "tan"

  res@pmTickMarkDisplayMode = "Always"     ; Nicer tickmarks

  plot = gsn_csm_map_ce(wks,res)

;---Zoom in a little more
  res@mpMinLatF             =  23.3
  res@mpMaxLatF             =  26.
  res@mpMinLonF             = -78.5
  res@mpMaxLonF             = -75

  plot = gsn_csm_map_ce(wks,res)

end
