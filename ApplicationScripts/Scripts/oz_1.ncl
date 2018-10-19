;----------------------------------------------------------------------
; oz_1
;
; Concepts illustrated:
;   - Creating a map of Australia
;----------------------------------------------------------------------

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  wks = gsn_open_wks("ps","oz")

  res                       = True
  res@gsnMaximize           = True

  res@mpOutlineOn           = True         ; Turn on map outlines
  res@mpFillOn              = False        ; Turn off map fill

  res@mpDataBaseVersion     = "MediumRes"  ; Medium resolution database

  res@mpDataSetName         = "Earth..4"   ; This database contains
                                           ; divisions for countries
                                           ; like Australia, China.

  res@mpOutlineBoundarySets = "AllBoundaries"


  res@pmTickMarkDisplayMode = "Always"     ; Nicer tickmark labels

;---Zoom in on area of interest
  res@mpLimitMode           = "LatLon"
  res@mpMinLatF             = -45
  res@mpMaxLatF             =  -6
  res@mpMinLonF             = 110
  res@mpMaxLonF             = 155

;---Main title
  res@tiMainString          = "Map of Australia using 'medium' res database"
  res@tiMainFont            = "helvetica"   ; Default is helvetica-bold
  res@tiMainFontHeightF     = 0.015

  map = gsn_csm_map(wks,res)    ; Draw the map

end
