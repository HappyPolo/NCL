;**********************************************************************
; poly_15.ncl
;
; Concepts illustrated:
;   - Drawing polymarkers at station locations 
;**********************************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"


  latN = 46.0
  latS = 24.0
  lonL  = -113.
  lonR  = -87.

  nsta  = 100
  lat   = random_uniform( 30 , latN, nsta)
  lon   = random_uniform(lonL, lonR, nsta)

  wks = gsn_open_wks("png","polyg") ; send graphics to PNG file

  res                             = True
  res@gsnFrame                    = False   ; So we can draw markers
  res@gsnMaximize                 = True    ; affects ps, eps, pdf only
  res@gsnPaperOrientation         = "portrait"  ; force portrait 

  res@tiMainString                = "Simulated Locations"

  res@mpMinLatF                   = latS    ; range to zoom in on
  res@mpMaxLatF                   = latN 
  res@mpMinLonF                   = lonL
  res@mpMaxLonF                   = lonR
  res@mpCenterLonF                = (lonL+lonR)*0.5

  res@mpFillOn                    = False
  res@mpOutlineDrawOrder          = "PostDraw"
  res@mpFillDrawOrder             = "PreDraw"
  res@mpOutlineBoundarySets       = "GeophysicalAndUSStates"
  res@mpUSStateLineColor          = "Gray10"
  res@mpUSStateLineDashPattern    = 2

  res@pmTickMarkDisplayMode       = "Always"
;
; Draw the map (frame won't get advanced because gsnFrame was set to False).
;
  map = gsn_csm_map(wks,res)
;
; Draw markers on the plot in the lat/lon locations.
;
  mkres               = True
  mkres@gsMarkerIndex = 16     ; Filled circle
  mkres@gsMarkerSizeF = 0.03

  map@locations = gsn_add_polymarker(wks,map,lon,lat,mkres)

  draw(map)
  frame(wks)   ; Now advance the frame.
