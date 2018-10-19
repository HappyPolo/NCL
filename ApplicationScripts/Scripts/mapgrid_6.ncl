;--------------------------------------------------
; mapgrid_6.ncl
;--------------------------------------------------
; Concepts illustrated:
;   - Adding latitude labels to a stereographic map
;   - Drawing a lat/lon grid
;   - Attaching text strings to a map
;   - Changing the map grid lines to dashed lines
;--------------------------------------------------
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   

begin
  wks  = gsn_open_wks("png","mapgrid")          ; send graphics to PNG file
 
  res                        = True 
  res@gsnMaximize            = True
  res@gsnDraw                = False
  res@gsnFrame               = False

  res@mpProjection           = "Stereographic"
  res@mpCenterLatF           = 90               ; Centered over north pole
  res@mpLimitMode            = "LatLon"
  res@mpMinLatF              = 0.0

  res@pmTickMarkDisplayMode  = "Always"         ; Nicer tickmark labels
  res@mpGridAndLimbOn        = True             ; Turn on lat/lon grid
  res@mpGridLineDashPattern  = 2                ; Dashed lines

  plot = gsn_csm_map(wks,res)                   ; Create plot

;---Create lat/lon arrays for location of latitude labels.
  lats = ispan(15,90,15)
  nlat = dimsizes(lats)
  lons = new(nlat,integer)
  lons = 0

;---Resources for text strings
  txres               = True
  txres@txFontHeightF = 0.015
  dum = gsn_add_text(wks,plot,""+lats,lons,lats,txres)

;---Drawing the plot will draw the attached latitude labels
  draw(plot)
  frame(wks)
end
