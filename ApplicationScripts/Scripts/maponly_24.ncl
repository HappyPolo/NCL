;================================================;
;  maponly_24.ncl
;================================================;
;
; Concepts illustrated:
;   - Adding minor tickmarks to a map
;   - Creating tickmark objects using gsn_csm_blank_plot
;   - Changing the length of tickmarks
;   - Using "getvalues" to retrieve resource values
;   - Using "setvalues" to change the main title of an existing plot
;   - Explicitly setting tickmarks on the X and Y axes
;   - Overlaying a blank plot on a map plot in order to customize tickmarks
;
;================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  wks = gsn_open_wks("png","maponly")     ; send graphics to PNG file

;---Set up some map resources.
  minlat = 55
  maxlat = 70
  minlon =  4
  maxlon = 20

;---Resource list for map plot.
  mpres                       = True

  mpres@gsnMaximize           = True
;  mpres@gsnDraw               = False
;  mpres@gsnFrame              = False

  mpres@mpFillOn              = False
  mpres@mpLimitMode           = "LatLon"
  mpres@mpMinLonF             =  minlon
  mpres@mpMaxLonF             =  maxlon
  mpres@mpMinLatF             =  minlat
  mpres@mpMaxLatF             =  maxlat
  mpres@mpGeophysicalLineThicknessF = 2.0

  mpres@pmTickMarkDisplayMode = "Always"    ; Nice tickmark labels

  mpres@tiMainString          = "Minor tickmarks are not available"

  map                         = gsn_csm_map(wks,mpres)

;---Retrieve tickmark lengths.
  getvalues map
    "tmXBMajorLengthF" : xlength
    "tmYRMajorLengthF" : ylength
  end getvalues

;---Resource list for blank plot.
  bres                          = True

  bres@gsnDraw                  = False

;---Use same min/max axes values as map.
  bres@trXMinF                  = minlon
  bres@trXMaxF                  = maxlon
  bres@trYMinF                  = minlat
  bres@trYMaxF                  = maxlat

;---Set resources to indicate where to put new tickmarks
  bres@tmXBMode                 = "Explicit"
  bres@tmYLMode                 = "Explicit"
  bres@tmXBValues               = ispan(minlon,maxlon,1)
  bres@tmYLValues               = ispan(minlat,maxlat,1)

;---Set resources to create shorter tickmarks
  bres@tmXBMajorLengthF         = xlength/2.
  bres@tmYLMajorLengthF         = ylength/2.
  bres@tmXBMajorOutwardLengthF  = xlength/2.
  bres@tmYLMajorOutwardLengthF  = ylength/2.

;---Set resources to turn off labels on bottom/left, and ticks on top/right
  bres@tmXBLabelsOn             = False
  bres@tmYLLabelsOn             = False
  bres@tmXTOn                   = False
  bres@tmYROn                   = False

;---Make sure tickmarks stay with blank plot
  bres@tfDoNDCOverlay           = True

;---Change the title
  setvalues map
    "tiMainString" : "Minor tickmarks now available"
  end setvalues

  blank_plot = gsn_csm_blank_plot(wks,bres)

  overlay(map,blank_plot)
  draw(map)
  frame(wks)

end
