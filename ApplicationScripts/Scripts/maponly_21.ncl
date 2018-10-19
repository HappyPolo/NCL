;================================================;
;  maponly_21.ncl
;================================================;
;
; Concepts illustrated:
;   - Removing geophysical line boundaries between continents
;
;================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  wks = gsn_open_wks("png","maponly")  ; send graphics to PNG file

  res = True
  res@mpOutlineOn           = True
  res@mpMaxLatF             = 25.0
  res@mpMinLatF             = 5.0
  res@mpMinLonF             = -95.0
  res@mpMaxLonF             = -60.0
  res@pmTickMarkDisplayMode = "Always"   ; nicer tickmarks

  res@mpOutlineBoundarySets = "Geophysical"
  res@mpDataSetName         = "Earth..4" 
  res@mpDataBaseVersion     = "MediumRes"
  res@tiMainString          = "American continents with lines dividing them"
  plot  = gsn_csm_map(wks,res)

  res@mpOutlineBoundarySets = "NoBoundaries"
  res@mpOutlineSpecifiers   = "Land" 
  res@tiMainString          = "American continents without lines dividing them"
  plot2  = gsn_csm_map(wks,res)
end 
